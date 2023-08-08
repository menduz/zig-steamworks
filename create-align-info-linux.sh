node generate-aux.js steamworks/public/steam/steam_api.json
zig build aux -Dtarget=x86_64-linux-gnu
cd zig-out/bin
./aux-cli > ../../steamworks/align-info-linux.json