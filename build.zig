const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "flare",
        .root_module = mod,
    });

    exe.root_module.link_libcpp = true;
    exe.root_module.link_libc = true;

    // ------------------------------------------------------------
    // Include paths
    // ------------------------------------------------------------

    exe.root_module.addIncludePath(b.path("src"));

    exe.root_module.addIncludePath(b.path("deps/SDL2/include"));
    exe.root_module.addIncludePath(b.path("deps/SDL2_image/include"));
    exe.root_module.addIncludePath(b.path("deps/SDL2_mixer/include"));
    exe.root_module.addIncludePath(b.path("deps/SDL2_ttf/include"));

    // ------------------------------------------------------------
    // Library paths
    // ------------------------------------------------------------

    exe.root_module.addLibraryPath(b.path("deps/SDL2/lib/x64"));
    exe.root_module.addLibraryPath(b.path("deps/SDL2_image/lib/x64"));
    exe.root_module.addLibraryPath(b.path("deps/SDL2_mixer/lib/x64"));
    exe.root_module.addLibraryPath(b.path("deps/SDL2_ttf/lib/x64"));

    // ------------------------------------------------------------
    // Collect all Flare .cpp files
    // ------------------------------------------------------------

    const cwd = std.Io.Dir.cwd();

    var src_dir = cwd.openDir(b.graph.io, "src", .{
        .iterate = true,
    }) catch @panic("Could not open src directory");

    defer src_dir.close(b.graph.io);

    var cpp_files = std.ArrayList([]const u8).empty;

    var iterator = src_dir.iterate();

    while (iterator.next(b.graph.io) catch @panic("Could not iterate src")) |entry| {
        if (entry.kind != .file)
            continue;

        if (!std.mem.endsWith(u8, entry.name, ".cpp"))
            continue;

        const path = b.fmt("src/{s}", .{entry.name});

        cpp_files.append(
            b.allocator,
            path,
        ) catch @panic("Out of memory");
    }

    exe.root_module.addCSourceFiles(.{
        .files = cpp_files.items,
        .flags = &.{
            "-std=c++17",
        },
    });

    // ------------------------------------------------------------
    // SDL
    // ------------------------------------------------------------

    exe.root_module.linkSystemLibrary("SDL2", .{
        .use_pkg_config = .no,
    });

    exe.root_module.linkSystemLibrary("SDL2main", .{
        .use_pkg_config = .no,
    });

    exe.root_module.linkSystemLibrary("SDL2_image", .{
        .use_pkg_config = .no,
    });

    exe.root_module.linkSystemLibrary("SDL2_mixer", .{
        .use_pkg_config = .no,
    });

    exe.root_module.linkSystemLibrary("SDL2_ttf", .{
        .use_pkg_config = .no,
    });

    b.installArtifact(exe);
}
