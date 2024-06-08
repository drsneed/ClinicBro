const std = @import("std");
const builtin = @import("builtin");
const jetzig = @import("jetzig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "testserver.live",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const zqlite = b.dependency("zqlite", .{
        .target = target,
        .optimize = optimize,
    }).module("zqlite");
    zqlite.addCSourceFile(.{
        .file = b.path("src/sql/sqlite3.c"),
        .flags = &[_][]const u8{
            "-DSQLITE_DQS=0",
            "-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1",
            "-DSQLITE_USE_ALLOCA=1",
            "-DSQLITE_THREADSAFE=1",
            "-DSQLITE_TEMP_STORE=3",
            "-DSQLITE_ENABLE_API_ARMOR=1",
            "-DSQLITE_ENABLE_UNLOCK_NOTIFY",
            "-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1",
            "-DSQLITE_DEFAULT_FILE_PERMISSIONS=0600",
            "-DSQLITE_OMIT_DECLTYPE=1",
            "-DSQLITE_OMIT_DEPRECATED=1",
            "-DSQLITE_OMIT_LOAD_EXTENSION=1",
            "-DSQLITE_OMIT_PROGRESS_CALLBACK=1",
            "-DSQLITE_OMIT_SHARED_CACHE",
            "-DSQLITE_OMIT_TRACE=1",
            "-DSQLITE_OMIT_UTF16=1",
            "-DHAVE_USLEEP=0",
        },
    });
    zqlite.addIncludePath(b.path("src/sql"));
    exe.linkLibC();
    exe.root_module.addImport("zqlite", zqlite);

    // const zdt = b.dependency("zdt", .{
    //     .target = target,
    //     .optimize = optimize,
    // }).module("zdt");

    // exe.root_module.addImport("zdt", zdt);

    // To standardize development, maybe you should use `lazyDependency()` instead of `dependency()`
    // more info to see: https://ziglang.org/download/0.12.0/release-notes.html#toc-Lazy-Dependencies
    // const zig_webui = b.dependency("zig-webui", .{
    //     .target = target,
    //     .optimize = optimize,
    //     .enable_tls = false, // whether enable tls support
    //     .is_static = true, // whether static link
    // });

    // // add module
    // exe.root_module.addImport("webui", zig_webui.module("webui"));

    // All dependencies **must** be added to imports above this line.

    try jetzig.jetzigInit(b, exe, .{});

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
