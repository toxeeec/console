const kernel = @import("kernel.zig");

extern var __stack_top: u8;

const VectorTable = extern struct {
    initial_sp: *const u8,
    reset: *const fn () callconv(.c) noreturn,
};

export const vector_table: VectorTable linksection(".isr_vector") = .{
    .initial_sp = &__stack_top,
    .reset = &reset_handler,
};

export fn reset_handler() noreturn {
    kernel.kernel_main();
}
