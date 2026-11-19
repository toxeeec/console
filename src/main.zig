export var result: u32 = 0;

export fn _start() noreturn {
    const output: *volatile u32 = &result;
    output.* = 0x12345678;
    while (true) {}
}
