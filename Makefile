LEVEL := Debug
TARGET := native

ZIG := /usr/local/lib/zig/lib

build: build-source
	@echo '=================== BeginBuild ==================='
	zig build -Dtarget=$(TARGET) -Doptimize=$(LEVEL) -freference-trace --verbose
	@echo '===================  EndBuild  ==================='

build-source:
	node generate.js steamworks/public/steam/steam_api.json
	zig fmt src
	zig build test -freference-trace --verbose --summary all -Dtarget=$(TARGET) --verbose-link

test-docker:
	node generate.js steamworks/public/steam/steam_api.json
	zig fmt src
	zig build run -freference-trace --verbose --summary all

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

.PHONY: build