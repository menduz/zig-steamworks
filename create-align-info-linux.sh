#!/usr/bin/env bash
set -euo pipefail

JS="${JS:-bun}"

"$JS" generate-align.js steamworks/public/steam/steam_api.json x86_64-linux-gnu > steamworks/align-info-linux.json
