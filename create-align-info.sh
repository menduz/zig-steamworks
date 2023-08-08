node generate.js steamworks/public/steam/steam_api.json
node generate-aux.js steamworks/public/steam/steam_api.json
zig build aux -Dtarget=aarch64-macos-none
cd zig-out/bin
./aux-cli > ../../steamworks/align-info-macos.json