const fs = require('fs')
const path = require('path')

const [nodeBinary, jsFile, json] = process.argv

if (!json || !json.endsWith('steam_api.json')) {
  throw new Error(`Please provide a path to steam_api.json as first argument`)
}

const data = require(path.resolve(json));

const outFileCpp = 'src/steam-aux.cpp'

const cpp = [
  '// this file is autogenerated by generate-aux.js - https://github.com/menduz/zig-steamworks',
  `#include <cstdio>`,
  `#include <concepts>`,
  `#include <type_traits>`,

  `#import "steam_api.h"`,
  `#import "steam_gameserver.h"`,
  `#import "steamdatagram_tickets.h"`,
]

// cleanup
{
  data.callback_structs = data.callback_structs.filter($ => {
    if ($.struct == 'PS3TrophiesInstalled_t') return false
    if ($.struct == 'GSStatsUnloaded_t') return false
    return true
  })
}

var isFirst = true

const deny_list = ['SteamNetworkingFakeIPResult_t']

function writeDumpStruct(struct) {
  const structName = struct.struct

  if (deny_list.includes(structName)) return


  { // struct
    const comma = isFirst ? '' : ',' 
    if(isFirst) isFirst = false;
    cpp.push(`  // ${structName}`)
    cpp.push(`  { std::fprintf(stdout, "${comma}\\"${structName}\\": {");`)

    { // fields
      cpp.push(`    { std::fprintf(stdout, "\\"fields\\": [");`);

      cpp.push(`      struct ${structName}    *p_${structName} = 0;`)

      struct.fields.forEach((f, i) => {
        const comma = i == struct.fields.length - 1 ? '' : ',\\n'

        cpp.push(`      std::fprintf(stdout, "  {\\"field\\": \\"${f.fieldname}\\", \\"size\\": %d, \\"align\\": %d}${comma}", sizeof(p_${structName}->${f.fieldname}), alignof(p_${structName}->${f.fieldname}));`);
      })

      cpp.push(`      std::fprintf(stdout, "],\\n");`)
      cpp.push(`    }`)
    }

    cpp.push(`    std::fprintf(stdout, "  \\"size\\": %d, \\"align\\": %d \\n", sizeof(${structName}), alignof(${structName}));`);

    cpp.push(`    std::fprintf(stdout, "}\\n");`)
    cpp.push(`  }`)
  }
}

{
  // cpp.push(`extern "C" int dump_all() {`)
  cpp.push(`int main() {`)
  cpp.push(`  std::fprintf(stdout, "{\\n");`);
  [...data.callback_structs, ...data.structs].forEach(writeDumpStruct);
  cpp.push(
    `  std::fprintf(stdout, "}\\n");`,
    `  return 0;`,
    `}`)
}

fs.writeFileSync(outFileCpp, cpp.join('\n'))