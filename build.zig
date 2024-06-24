const std = @import("std");
const jetzig = @import("jetzig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ClinicBro",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zqlite_a = b.dependency("zqlite", .{
        .target = target,
        .optimize = optimize,
    });
    const zqlite = zqlite_a.module("zqlite");
    zqlite.addIncludePath(zqlite_a.path("lib/sqlite3/"));
    exe.root_module.addImport("zqlite", zqlite);
    exe.addLibraryPath(b.path("./"));
    exe.linkSystemLibrary("sqlite3");

    const pg = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("pg", pg.module("pg"));

    // ^ Add all dependencies before `jetzig.jetzigInit()` ^

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
