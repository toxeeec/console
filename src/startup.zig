const kernel = @import("kernel.zig");
const stm32 = @import("stm32");

extern var __stack_top: u8;

const Handler = *const fn () callconv(.c) void;

const VectorTable = extern struct {
    initial_sp: *const u8,
    reset: *const fn () callconv(.c) noreturn,
    nmi: Handler,
    hard_fault: Handler,
    mem_manage: Handler,
    bus_fault: Handler,
    usage_fault: Handler,
    secure_fault: Handler,
    reserved_8_10: [3]u32,
    svc: Handler,
    debug_monitor: Handler,
    reserved_13: u32,
    pend_sv: Handler,
    sys_tick: Handler,
    irq_handlers: [195]?Handler,
};

export const vector_table: VectorTable linksection(".isr_vector") = .{
    .initial_sp = &__stack_top,
    .reset = &reset_handler,
    .nmi = &default_handler,
    .hard_fault = &default_handler,
    .mem_manage = &default_handler,
    .bus_fault = &default_handler,
    .usage_fault = &default_handler,
    .secure_fault = &default_handler,
    .reserved_8_10 = .{ 0, 0, 0 },
    .svc = &default_handler,
    .debug_monitor = &default_handler,
    .reserved_13 = 0,
    .pend_sv = &default_handler,
    .sys_tick = &default_handler,
    .irq_handlers = blk: {
        var handlers: [195]?Handler = @splat(&default_handler);
        // Reserved IRQ numbers in the STM32N657 vector table.
        for ([_]usize{ 1, 9, 15, 17, 41, 49, 50, 51, 192 }) |irq| {
            handlers[irq] = null;
        }
        break :blk handlers;
    },
};

export fn reset_handler() noreturn {
    const scb: *volatile stm32.SCB_Type = stm32.SCB;
    scb.VTOR = @intFromPtr(&vector_table);
    asm volatile (
        \\dsb sy
        \\isb sy
        ::: .{ .memory = true });

    kernel.kernel_main();
}

fn default_handler() callconv(.c) void {
    while (true) {}
}
