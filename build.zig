const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
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
    exe.entry = .{ .symbol_name = "_start" };
    exe.link_gc_sections = true;
    exe.setLinkerScript(b.path("ram.ld"));

    const install = b.addInstallFile(exe.getEmittedBin(), "console.elf");
    b.getInstallStep().dependOn(&install.step);
}
