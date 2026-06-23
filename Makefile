LEVEL := Debug
TARGET := native
JS ?= bun

ZIG := /usr/local/lib/zig/lib

build:
	@echo '=================== BeginBuild ==================='
	zig build -Dtarget=$(TARGET) -Doptimize=$(LEVEL) -freference-trace --verbose
	@echo '===================  EndBuild  ==================='

generate:
	$(JS) generate.js steamworks/public/steam/steam_api.json
	zig fmt src

align-linux:
	$(JS) generate-align.js steamworks/public/steam/steam_api.json x86_64-linux-gnu > steamworks/align-info-linux.json

align-macos:
	$(JS) generate-align.js steamworks/public/steam/steam_api.json aarch64-macos-none > steamworks/align-info-macos.json

align-windows:
	$(JS) generate-align.js steamworks/public/steam/steam_api.json x86_64-windows-gnu > steamworks/align-info-windows.json

align: align-linux align-macos align-windows

build-source: generate
	zig build test -freference-trace --verbose --summary all -Dtarget=$(TARGET) --verbose-link

test-docker:
	$(JS) generate.js steamworks/public/steam/steam_api.json
	zig fmt src
	zig build run -freference-trace --verbose --summary all
test-docker1:
	$(JS) generate.js steamworks/public/steam/steam_api.json
	zig fmt src
	zig build -Dtarget=$(TARGET)

cross:
	@$(MAKE) build TARGET=aarch64-macos-none 
	@$(MAKE) build TARGET=x86_64-macos-none
	@$(MAKE) build TARGET=x86_64-linux-gnu
	@$(MAKE) build TARGET=x86_64-windows-gnu

# join both aarch64 and x86 macOS binaries into an "universal binary"
# NOTE: this step requires a cross compilation to happen (make cross)
link-universal:
	lipo -create -output zig-out/bin/steam_demo_universal zig-out/bin/steam_demo_x86 zig-out/bin/steam_demo_arm

clean:
	rm -rf zig-cache
	rm -rf zig-out

.PHONY: build generate align align-linux align-macos align-windows build-source test-docker test-docker1 cross link-universal clean
