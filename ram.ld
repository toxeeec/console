ENTRY(_start)

MEMORY {
    CODE (rx)  : ORIGIN = 0x34180400, LENGTH = 255K
    DATA  (rw) : ORIGIN = 0x341C0000, LENGTH = 256K
}

SECTIONS {
    .text         : { *(.text .text.*) }         > CODE
    .rodata       : { *(.rodata .rodata.*) }     > CODE
    .ARM.exidx    : { *(.ARM.exidx*) }           > CODE
    .data         : { *(.data .data.*) }         > DATA
    .bss (NOLOAD) : { *(.bss .bss.*) *(COMMON) } > DATA

    .stack (NOLOAD) : ALIGN(8) {
        . += 4K;
        __stack_top = .;
    } > DATA
}
