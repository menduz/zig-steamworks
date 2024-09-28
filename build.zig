const std = @import("std");
const builtin = @import("builtin");

// TODO(build-system): this is needed because lib2.linkLibrary(lib)
// will not add the library path transitively to lib3.linkLibrary(lib2)
pub fn addLibraryPath(b: *std.Build, compile: *std.Build.Step.Compile) void {
    if (compile.root_module.resolved_target != null and compile.root_module.resolved_target.?.result.os.tag == .macos) {
        compile.step.dependOn(&compile.step.owner.addInstallBinFile(b.path("steamworks/redistributable_bin/osx/libsteam_api.dylib"), "libsteam_api.dylib").step);
        compile.step.dependOn(&compile.step.owner.addInstallLibFile(b.path("steamworks/public/steam/lib/osx/libsdkencryptedappticket.dylib"), "libsdkencryptedappticket.dylib").step);

        compile.addLibraryPath(b.path("steamworks/public/steam/lib/osx"));
        compile.addLibraryPath(b.path("steamworks/redistributable_bin/osx"));
    } else if (compile.root_module.resolved_target != null and compile.root_module.resolved_target.?.result.os.tag == .windows) {
        compile.step.dependOn(&compile.step.owner.addInstallBinFile(b.path("steamworks/public/steam/lib/win64/sdkencryptedappticket64.dll"), "sdkencryptedappticket64.dll").step);
        compile.step.dependOn(&compile.step.owner.addInstallBinFile(b.path("steamworks/redistributable_bin/win64/steam_api64.dll"), "steam_api64.dll").step);
        compile.addLibraryPath(b.path("steamworks/public/steam/lib/win64"));
        compile.addLibraryPath(b.path("steamworks/redistributable_bin/win64"));
    } else {
        compile.step.dependOn(&compile.step.owner.addInstallBinFile(b.path("steamworks/redistributable_bin/linux64/libsteam_api.so"), "libsteam_api.so").step);
        compile.step.dependOn(&compile.step.owner.addInstallBinFile(b.path("steamworks/public/steam/lib/linux64/libsdkencryptedappticket.so"), "libsdkencryptedappticket.so").step);
        compile.addLibraryPath(b.path("steamworks/public/steam/lib/linux64"));
        compile.addLibraryPath(b.path("steamworks/redistributable_bin/linux64"));
        // instructs the binary to load libraries from the local path
    }
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
        .root_source_file = b.path("src/main.zig"),
    });

    var lib = b.addStaticLibrary(.{
        .name = "steamworks",
        // .root_source_file = b.path("src/steam.cpp"),
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

    addLibraryPath(b, lib);

    if (lib.root_module.resolved_target != null and lib.root_module.resolved_target.?.result.os.tag == .windows) {
        lib.linkSystemLibrary("sdkencryptedappticket64");
        lib.linkSystemLibrary("steam_api64");
    } else {
        lib.linkSystemLibrary("sdkencryptedappticket");
        lib.linkSystemLibrary("steam_api");
    }

    // Include dirs.
    lib.addIncludePath(b.path("steamworks/public/steam"));
    lib.addCSourceFiles(.{ .files = &.{"src/steam.cpp"}, .flags = flagContainer.items });

    b.installArtifact(lib);

    // link steamworks to this executable
    try build_example_project(b, module, target, optimize, lib);

    // create test step
    try test_step(b, module, target, optimize, lib);

    try build_aux_cli(b, target, optimize, lib);
}

fn build_example_project(b: *std.Build, module: *std.Build.Module, target: std.Build.ResolvedTarget, optimize: std.builtin.Mode, lib: *std.Build.Step.Compile) !void {
    const test_exe = b.addExecutable(.{
        .name = "example",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("example/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    addLibraryPath(b, test_exe);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(test_exe);
    test_exe.root_module.addImport("steamworks", module);
    test_exe.linkLibrary(lib);
}

fn build_aux_cli(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, lib: *std.Build.Step.Compile) !void {
    const test_exe = b.addExecutable(.{
        .name = "aux-cli",
        .target = target,
        .optimize = optimize,
    });

    test_exe.linkLibC();
    addLibraryPath(b, test_exe);
    // Generate flags.
    var flagContainer = std.ArrayList([]const u8).init(std.heap.page_allocator);
    if (optimize != .Debug) flagContainer.append("-Os") catch unreachable;
    flagContainer.append("-Wno-return-type-c-linkage") catch unreachable;
    flagContainer.append("-fno-sanitize=undefined") catch unreachable;
    flagContainer.append("-Wgnu-alignof-expression") catch unreachable;
    flagContainer.append("-Wno-gnu") catch unreachable;

    test_exe.addIncludePath(b.path("steamworks/public/steam"));
    test_exe.addCSourceFiles(.{ .files = &.{"src/steam-aux.cpp"}, .flags = flagContainer.items });

    test_exe.linkLibrary(lib);

    var run_step = b.step("aux", "Builds the auxiliary executable used to extract alignment information");
    run_step.dependOn(&test_exe.step);
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).

    run_step.dependOn(&b.addInstallArtifact(test_exe, .{}).step);
}

fn test_step(b: *std.Build, module: *std.Build.Module, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, lib: *std.Build.Step.Compile) !void {
    const main_tests = b.addTest(.{
        .root_source_file = b.path(if (builtin.os.tag == .windows) "src/tests-win.zig" else "src/tests-unix.zig"),
        .target = target,
        .optimize = optimize,
    });

    main_tests.root_module.addImport("steamworks", module);
    main_tests.linkLibrary(lib);

    addLibraryPath(b, main_tests);

    if (main_tests.root_module.resolved_target == null or main_tests.root_module.resolved_target.?.result.os.tag == .linux) {
        // since .so files are not copied to the test binary folder, we specify an extra rpath for these
        main_tests.addRPath(b.path("steamworks/public/steam/lib/linux64"));
        main_tests.addRPath(b.path("steamworks/redistributable_bin/linux64"));
    }

    var run_unit_tests = b.addRunArtifact(main_tests);
    run_unit_tests.cwd = .{ .cwd_relative = b.exe_dir };
    run_unit_tests.step.dependOn(&b.addInstallBinFile(b.path("src/steam_appid.txt"), "steam_appid.txt").step);

    var run_step = b.step("test", "Run the app");
    run_step.dependOn(&run_unit_tests.step);
}
