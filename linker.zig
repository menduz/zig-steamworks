const std = @import("std");

pub fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

/// Link and compile the steamworks library. Also copy the redistributable files to the out-dir
pub fn linkSteamLibrary(b: *std.build.Builder, exe: *std.build.LibExeObjStep) !*std.build.LibExeObjStep {
    const steamworksPath = "steamworks";
    var steam = b.addStaticLibrary(.{
        .name = "steamworks",
        .root_source_file = .{ .path = comptime thisDir() ++ "/src/main.cpp" },
        .target = exe.target,
        .optimize = exe.optimize,
    });
    steam.linkLibC();
    steam.linkLibCpp();

    // Generate flags.
    var flagContainer = std.ArrayList([]const u8).init(std.heap.page_allocator);
    if (exe.optimize != .Debug) flagContainer.append("-Os") catch unreachable;
    flagContainer.append("-Wno-return-type-c-linkage") catch unreachable;
    flagContainer.append("-fno-sanitize=undefined") catch unreachable;

    // const lib = b.addStaticLibrary(.{
    //     .name = "mach-glfw",
    //     .root_source_file = .{ .path = "stub.c" },
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib.linkLibrary(b.dependency("glfw", .{
    //     .target = lib.target,
    //     .optimize = lib.optimize,
    // }).artifact("glfw"));

    if (exe.target.os_tag != null) {
        if (exe.target.os_tag.? == .macos) {
            //try copy(steamworksPath ++ "/redistributable_bin/osx", "zig-out/bin", "libsteam_api.dylib");
            //try copy(steamworksPath ++ "/public/steam/lib/osx", "zig-out/bin", "libsdkencryptedappticket.dylib");
            steam.linkSystemLibrary(steamworksPath ++ "/public/steam/lib/osx/libsdkencryptedappticket.dylib");
            steam.linkSystemLibrary(steamworksPath ++ "/redistributable_bin/osx/libsteam_api.dylib");
        } else if (exe.target.os_tag.? == .linux) {
            //try copy(steamworksPath ++ "/redistributable_bin/linux64", "zig-out/bin", "libsteam_api.so");
            //try copy(steamworksPath ++ "/public/steam/lib/linux64", "zig-out/bin", "libsdkencryptedappticket.so");
            steam.linkSystemLibrary(steamworksPath ++ "/public/steam/lib/linux64/libsdkencryptedappticket.so");
            steam.linkSystemLibrary(steamworksPath ++ "/redistributable_bin/linux64/libsteam_api.so");
        } else if (exe.target.os_tag.? == .windows) {
            //try copy(steamworksPath ++ "/public/steam/lib/win64", "zig-out/bin", "sdkencryptedappticket64.dll");
            // try copy(steamworksPath ++ "/public/steam/lib/win64", "zig-out/bin", "sdkencryptedappticket64.lib");
            //try copy(steamworksPath ++ "/redistributable_bin/win64", "zig-out/bin", "steam_api64.dll");
            // try copy(steamworksPath ++ "/redistributable_bin/win64", "zig-out/bin", "steam_api64.lib");
            steam.addLibraryPath(.{ .path = steamworksPath ++ "/public/steam/lib/win64" });
            steam.addLibraryPath(.{ .path = steamworksPath ++ "/redistributable_bin/win64" });
            steam.linkSystemLibrary("sdkencryptedappticket64");
            steam.linkSystemLibrary("steam_api64");
            // b.installLibFile(src_path: []const u8, dest_rel_path: []const u8)
        }
    }

    // Include dirs.
    steam.addIncludePath(.{ .path = steamworksPath ++ "/public/steam" });

    // Add C
    steam.addCSourceFiles(&.{comptime thisDir() ++ "/src/steam.cpp"}, flagContainer.items);
    b.installArtifact(steam);

    return steam;
}

pub const AddContentErrors = error{ PermissionError, WriteError, FileError, FolderError, RecursionError };
const fs = std.fs;
pub fn copy(from: []const u8, to: []const u8, filename: []const u8) AddContentErrors!void {
    fs.cwd().makePath(to) catch return error.FolderError;
    var source = fs.cwd().openDir(from, .{}) catch return error.FileError;
    var dest = fs.cwd().openDir(to, .{}) catch return error.FileError;

    var sfile = source.openFile(filename, .{}) catch return error.FileError;
    defer sfile.close();
    var dfile = dest.openFile(filename, .{}) catch {
        source.copyFile(filename, dest, filename, .{}) catch return error.PermissionError;
        std.debug.print("  COPY: {s}/{s} to {s}/{s}\n", .{ from, filename, to, filename });
        return;
    };

    var sstat = sfile.stat() catch return error.FileError;
    var dstat = dfile.stat() catch return error.FileError;

    if (sstat.mtime > dstat.mtime) {
        dfile.close();
        dest.deleteFile(filename) catch return error.PermissionError;
        source.copyFile(filename, dest, filename, .{}) catch return error.PermissionError;
        std.debug.print("  REPLACE: {s}/{s} to {s}/{s}\n", .{ from, filename, to, filename });
    } else {
        defer dfile.close();
        std.debug.print("  SKIP: {s}/{s}\n", .{ from, filename });
    }
}
