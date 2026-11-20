const kernel = @import("kernel.zig");

export fn _start() noreturn {
    kernel.kernel_main();
}
