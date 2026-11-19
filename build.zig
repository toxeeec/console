const std = @import("std");

pub fn build(b: *std.Build) void {
    const object = b.addObject(.{
        .name = "console",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.resolveTargetQuery(.{
                .cpu_arch = .thumb,
                .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m55 },
                .os_tag = .freestanding,
                .abi = .eabi,
            }),
            .optimize = b.standardOptimizeOption(.{}),
        }),
    });
    const install = b.addInstallFile(object.getEmittedBin(), "console.o");
    b.getInstallStep().dependOn(&install.step);
}
