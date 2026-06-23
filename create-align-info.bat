@echo off
setlocal

if "%JS%"=="" set JS=bun
if "%TARGET%"=="" set TARGET=x86_64-windows-gnu

%JS% generate-align.js steamworks/public/steam/steam_api.json %TARGET% > steamworks\align-info-windows.json || exit /b 1
