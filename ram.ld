ENTRY(reset_handler)

MEMORY {
    CODE (rx)  : ORIGIN = 0x34180400, LENGTH = 255K
    DATA  (rw) : ORIGIN = 0x341C0000, LENGTH = 256K
}

__sram_load_start = ORIGIN(CODE);
__sram_load_end = ORIGIN(DATA) + LENGTH(DATA);
__stack_size = 4K;

SECTIONS {
    .isr_vector ORIGIN(CODE) : { KEEP(*(.isr_vector)) }            > CODE

    .text                    : { *(.text .text.*) }                > CODE
    .rodata                  : { *(.rodata .rodata.*) }            > CODE
    .ARM.extab               : { *(.ARM.extab .ARM.extab.*) }      > CODE
    .ARM.exidx               : { *(.ARM.exidx*) }                  > CODE
    .data                    : { *(.data .data.*) }                > DATA
    .bss (NOLOAD)            : { *(.bss .bss.*) *(COMMON) }        > DATA

    .stack (ORIGIN(DATA) + LENGTH(DATA) - __stack_size) (NOLOAD) : ALIGN(8) {
        . += __stack_size;
        __stack_top = .;
    } > DATA
}
