const child_process = require('child_process')
const fs = require('fs')
const os = require('os')
const path = require('path')

const [,, jsonPath, target = 'native'] = process.argv

if (!jsonPath || !jsonPath.endsWith('steam_api.json')) {
  throw new Error('Usage: bun generate-align.js steamworks/public/steam/steam_api.json [zig-target]')
}

const steamHeadersDir = path.dirname(path.resolve(jsonPath))
const data = require(path.resolve(jsonPath))
const incompleteStructs = new Set([
  'SteamDatagramHostedAddress',
  'SteamDatagramGameCoordinatorServerLogin',
])

const manualStructs = {
  SteamDatagramHostedAddress: {
    fields: [
      { field: 'm_cbSize', size: 4, align: 4 },
      { field: 'm_data', size: 128, align: 1 },
    ],
    size: 132,
    align: 4,
  },
  SteamDatagramGameCoordinatorServerLogin: {
    fields: [
      { field: 'm_identity', size: 136, align: 1 },
      { field: 'm_routing', size: 132, align: 4 },
      { field: 'm_nAppID', size: 4, align: 4 },
      { field: 'm_rtime', size: 4, align: 4 },
      { field: 'm_cbAppData', size: 4, align: 4 },
      { field: 'm_appData', size: 2048, align: 1 },
    ],
    size: 2328,
    align: 4,
  },
}

const structs = [...data.callback_structs, ...data.structs]
  .filter((item) => !incompleteStructs.has(item.struct))

const source = [
  '#define private public',
  '#include "steam_api.h"',
  '#include "steam_gameserver.h"',
  '#include "steamnetworkingfakeip.h"',
]

if (fs.existsSync(path.join(steamHeadersDir, 'steamdatagram_tickets.h'))) {
  source.push('#include "steamdatagram_tickets.h"')
}

source.push('#undef private')

for (const [index, item] of structs.entries()) {
  const structName = item.struct
  source.push(`extern "C" __attribute__((used)) const unsigned zigsw_${index}_size = sizeof(${structName});`)
  source.push(`extern "C" __attribute__((used)) const unsigned zigsw_${index}_align = alignof(${structName});`)

  for (const [fieldIndex, field] of item.fields.entries()) {
    const memberExpr = structName == 'SteamNetworkingConfigValue_t' && field.fieldname == 'm_int64'
      ? 'm_val.m_int64'
      : field.fieldname
    source.push(`extern "C" __attribute__((used)) const unsigned zigsw_${index}_f${fieldIndex}_size = sizeof(((${structName}*)0)->${memberExpr});`)
    source.push(`extern "C" __attribute__((used)) const unsigned zigsw_${index}_f${fieldIndex}_align = alignof(((${structName}*)0)->${memberExpr});`)
  }
}

const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'zig-steamworks-align-'))
const cppPath = path.join(tmpDir, 'align.cpp')
const llPath = path.join(tmpDir, 'align.ll')
fs.writeFileSync(cppPath, source.join('\n'))

const args = [
  'c++',
  '-std=c++20',
  '-Wno-gnu-alignof-expression',
  '-I', steamHeadersDir,
  '-S',
  '-emit-llvm',
  cppPath,
  '-o', llPath,
]

if (target != 'native') {
  args.splice(1, 0, '-target', target)
}

child_process.execFileSync('zig', args, { stdio: ['ignore', 'ignore', 'inherit'] })

const values = new Map()
for (const line of fs.readFileSync(llPath, 'utf8').split('\n')) {
  const match = /^@(\w+) = .*?\bconstant i(?:32|64) (\d+),/.exec(line)
  if (match) values.set(match[1], Number(match[2]))
}

const output = {}
for (const [index, item] of structs.entries()) {
  output[item.struct] = {
    fields: item.fields.map((field, fieldIndex) => ({
      field: field.fieldname,
      size: values.get(`zigsw_${index}_f${fieldIndex}_size`),
      align: values.get(`zigsw_${index}_f${fieldIndex}_align`),
    })),
    size: values.get(`zigsw_${index}_size`),
    align: values.get(`zigsw_${index}_align`),
  }
}

Object.assign(output, manualStructs)

process.stdout.write(JSON.stringify(output, null, 2))
process.stdout.write('\n')
