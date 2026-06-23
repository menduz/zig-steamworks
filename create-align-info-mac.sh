#!/usr/bin/env bash
set -euo pipefail

JS="${JS:-bun}"
TARGET="${TARGET:-native}"

"$JS" generate-align.js steamworks/public/steam/steam_api.json "$TARGET" > steamworks/align-info-macos.json
