const stm32 = @import("stm32");

const gpio_o: *volatile stm32.GPIO_TypeDef = stm32.GPIOO_S;
const pwr: *volatile stm32.PWR_TypeDef = stm32.PWR_S;
const rcc: *volatile stm32.RCC_TypeDef = stm32.RCC_S;
const systick: *volatile stm32.SysTick_Type = stm32.SysTick;

const hsi_hz: u32 = 64_000_000;

var ticks: u32 = 0;

pub fn systick_handler() callconv(.c) void {
    ticks += 1;
}

pub fn kernel_main() noreturn {
    init_ld1();

    systick.LOAD = hsi_hz / 1000 - 1;
    systick.VAL = 0;
    systick.CTRL = stm32.SysTick_CTRL_CLKSOURCE_Msk | stm32.SysTick_CTRL_TICKINT_Msk | stm32.SysTick_CTRL_ENABLE_Msk;

    for (0..5) |_| {
        turn_on_ld1();
        delay_ms(500);
        turn_off_ld1();
        delay_ms(500);
    }

    systick.CTRL = 0;
    while (true) asm volatile ("wfi");
}

fn delay_ms(ms: u32) void {
    for (0..ms) |_| {
        while ((systick.CTRL & stm32.SysTick_CTRL_COUNTFLAG_Msk) == 0) {}
    }
}

fn init_ld1() void {
    enable_ld1_clocks();

    pwr.SVMCR3 |= stm32.PWR_SVMCR3_VDDIO2SV;

    turn_off_ld1();
    gpio_o.OTYPER &= ~stm32.GPIO_OTYPER_OT1;
    gpio_o.MODER = (gpio_o.MODER & ~stm32.GPIO_MODER_MODE1) | stm32.GPIO_MODER_MODE1_0;
}

fn enable_ld1_clocks() void {
    rcc.AHB4ENSR = stm32.RCC_AHB4ENSR_GPIOOENS | stm32.RCC_AHB4ENSR_PWRENS;
    _ = rcc.AHB4ENR;
}

fn turn_on_ld1() void {
    gpio_o.BSRR = stm32.GPIO_BSRR_BS1;
}

fn turn_off_ld1() void {
    gpio_o.BSRR = stm32.GPIO_BSRR_BR1;
}
