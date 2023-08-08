const std = @import("std");
const builtin = @import("builtin");
const steam_linker = @import("./linker.zig");

// TODO(build-system): this is needed because lib2.linkLibrary(lib)
// will not add the library path transitively to lib3.linkLibrary(lib2)
pub fn addLibraryPath(compile: *std.build.CompileStep) void {
    if (compile.target.os_tag != null) {
        if (compile.target.os_tag.? == .windows) {
            compile.step.dependOn(&compile.step.owner.addInstallBinFile(.{ .path = "steamworks/public/steam/lib/win64/sdkencryptedappticket64.dll" }, "sdkencryptedappticket64.dll").step);
            compile.step.dependOn(&compile.step.owner.addInstallBinFile(.{ .path = "steamworks/redistributable_bin/win64/steam_api64.dll" }, "steam_api64.dll").step);
            compile.addLibraryPath(.{ .path = sdkPath("/steamworks/public/steam/lib/win64") });
            compile.addLibraryPath(.{ .path = sdkPath("/steamworks/redistributable_bin/win64") });
        }
    } else {
        std.debug.panic("Invalid target {any}\n", .{compile.target});
    }
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("steamworks", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    var lib = b.addStaticLibrary(.{
        .name = "steamworks",
        .root_source_file = .{ .path = "src/steam.cpp" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibCpp();

    // Generate flags.
    var flagContainer = std.ArrayList([]const u8).init(std.heap.page_allocator);
    if (optimize != .Debug) flagContainer.append("-Os") catch unreachable;
    flagContainer.append("-Wno-return-type-c-linkage") catch unreachable;
    flagContainer.append("-fno-sanitize=undefined") catch unreachable;
    flagContainer.append("-Wgnu-alignof-expression") catch unreachable;
    flagContainer.append("-Wno-gnu") catch unreachable;
    addLibraryPath(lib);

    if (lib.target.os_tag != null) {
        if (lib.target.os_tag.? == .macos) {
            b.installBinFile("steamworks/redistributable_bin/osx/libsteam_api.dylib", "libsteam_api.dylib");
            b.installBinFile("steamworks/public/steam/lib/osx/libsdkencryptedappticket.dll", "libsdkencryptedappticket.dylib");
            lib.linkSystemLibrary("steamworks/public/steam/lib/osx/libsdkencryptedappticket.dylib");
            lib.linkSystemLibrary("steamworks/redistributable_bin/osx/libsteam_api.dylib");
        } else if (lib.target.os_tag.? == .linux) {
            b.installBinFile("steamworks/redistributable_bin/linux64/libsteam_api.so", "libsteam_api.so");
            b.installBinFile("steamworks/public/steam/lib/linux64/libsdkencryptedappticket.so", "libsdkencryptedappticket.so");
            lib.linkSystemLibrary("steamworks/public/steam/lib/linux64/libsdkencryptedappticket.so");
            lib.linkSystemLibrary("steamworks/redistributable_bin/linux64/libsteam_api.so");
        } else if (lib.target.os_tag.? == .windows) {
            lib.linkSystemLibraryNeeded("sdkencryptedappticket64");
            lib.linkSystemLibraryNeeded("steam_api64");
        } else {
            @panic("Invalid target platform");
        }
    } else {
        std.debug.panic("Invalid target {any}\n", .{lib.target});
    }

    // Include dirs.
    lib.addIncludePath(.{ .path = "steamworks/public/steam" });
    lib.addCSourceFiles(&.{"src/steam.cpp"}, flagContainer.items);

    b.installArtifact(lib);

    // link steamworks to this executable
    try build_example_project(b, module, target, optimize, lib);

    // create test step
    try test_step(b, module, target, optimize, lib);

    try build_aux_cli(b, target, optimize, lib);
}

fn build_example_project(b: *std.Build, module: *std.Build.Module, target: std.zig.CrossTarget, optimize: std.builtin.Mode, lib: *std.build.Step.Compile) !void {
    const test_exe = b.addExecutable(.{
        .name = "example",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "example/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    addLibraryPath(test_exe);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(test_exe);
    test_exe.addModule("steamworks", module);
    test_exe.linkLibrary(lib);

    try steam_linker.copy(comptime steam_linker.thisDir() ++ "/src", "zig-out/bin", "steam_appid.txt");
}

fn build_aux_cli(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.Mode, lib: *std.build.Step.Compile) !void {
    const test_exe = b.addExecutable(.{
        .name = "aux-cli",
        .target = target,
        .optimize = optimize,
    });

    test_exe.linkLibC();
    addLibraryPath(test_exe);
    // Generate flags.
    var flagContainer = std.ArrayList([]const u8).init(std.heap.page_allocator);
    if (optimize != .Debug) flagContainer.append("-Os") catch unreachable;
    flagContainer.append("-Wno-return-type-c-linkage") catch unreachable;
    flagContainer.append("-fno-sanitize=undefined") catch unreachable;
    flagContainer.append("-Wgnu-alignof-expression") catch unreachable;
    flagContainer.append("-Wno-gnu") catch unreachable;

    test_exe.addIncludePath(.{ .path = "steamworks/public/steam" });
    test_exe.addCSourceFiles(&.{"src/steam-aux.cpp"}, flagContainer.items);

    test_exe.linkLibrary(lib);

    var run_step = b.step("aux", "Builds the auxiliary executable used to extract alignment information");
    run_step.dependOn(&test_exe.step);
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).

    run_step.dependOn(&b.addInstallArtifact(test_exe, .{}).step);
}

fn test_step(b: *std.Build, module: *std.Build.Module, target: std.zig.CrossTarget, optimize: std.builtin.Mode, lib: *std.build.Step.Compile) !void {
    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = if (builtin.os.tag == .windows) "src/tests-win.zig" else "src/tests-unix.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.addModule("steamworks", module);
    main_tests.linkLibrary(lib);

    addLibraryPath(main_tests);

    var run_unit_tests = b.addRunArtifact(main_tests);
    run_unit_tests.cwd = b.exe_dir;

    var run_step = b.step("test", "Run the app");
    run_step.dependOn(&run_unit_tests.step);
}
