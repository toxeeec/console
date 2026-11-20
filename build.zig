const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m55 },
        .os_tag = .freestanding,
        .abi = .eabi,
    });
    const optimize = b.standardOptimizeOption(.{});
    const device_include = b.graph.environ_map.get("STM32N6_INCLUDE") orelse @panic("STM32N6_INCLUDE is missing");
    const core_include = b.graph.environ_map.get("CMSIS_CORE_INCLUDE") orelse @panic("CMSIS_CORE_INCLUDE is missing");
    const cmsis = b.addTranslateC(.{
        .root_source_file = .{ .cwd_relative = b.pathJoin(&.{ device_include, "stm32n657xx.h" }) },
        .target = target,
        .optimize = optimize,
        .link_libc = false,
    });
    cmsis.addIncludePath(.{ .cwd_relative = core_include });
    cmsis.defineCMacro("CPU_IN_SECURE_STATE", "1");

    const exe = b.addExecutable(.{
        .name = "console",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/startup.zig"),
            .target = target,
            .optimize = optimize,
            .strip = false, // The RAM launcher reads the ELF symbol table.
        }),
    });
    exe.root_module.addImport("stm32", cmsis.createModule());
    exe.entry = .{ .symbol_name = "_start" };
    exe.link_gc_sections = true;
    exe.setLinkerScript(b.path("ram.ld"));

    const install = b.addInstallFile(exe.getEmittedBin(), "console.elf");
    b.getInstallStep().dependOn(&install.step);

    const launch = b.addSystemCommand(&.{"sh"});
    launch.addFileArg(b.path("scripts/run-from-sram.sh"));
    launch.addFileArg(exe.getEmittedBin());
    launch.addFileArg(b.path("probe.cfg"));
    launch.has_side_effects = true;
    b.step("run", "Load the firmware into SRAM and start it").dependOn(&launch.step);
}
