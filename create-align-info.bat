node generate-aux.js steamworks/public/steam/steam_api.json
zig build aux --summary all -Dtarget=x86_64-windows-gnu
cd zig-out\bin
.\aux-cli.exe > ..\..\steamworks\align-info-windows.json