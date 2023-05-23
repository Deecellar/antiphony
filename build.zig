const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const serial = b.dependency("s2s", .{});
    const s2s = serial.module("s2s");

    const linux_example = b.addExecutable(.{
        .name = "socketpair-example",
        .root_source_file = .{
            .path = "examples/linux.zig",
        },
        .optimize = mode,
        .target = target,
    });
    const antiphony_module = b.addModule("antiphony", .{
        .source_file = .{ .path = "src/antiphony.zig" },
        .dependencies = &.{.{
            .name = "s2s",
            .module = s2s,
        }},
    });

    linux_example.addModule("antiphony", antiphony_module);
    b.installArtifact(linux_example);

    const main_tests = b.addTest(.{
        .name = "antiphony",
        .root_source_file = .{ .path = "src/antiphony.zig" },
        .target = target,
        .optimize = mode,
    });
    main_tests.addModule("s2s", s2s);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
