#!/bin/sh
set -eu

elf=$1
symbols=$(nm -n "$elf")
address() {
    printf '%s\n' "$symbols" | awk -v name="$1" '
        $3 == name { print "0x" $1; found = 1; exit }
        END { if (!found) { print "Missing ELF symbol: " name > "/dev/stderr"; exit 1 } }
    '
}
entry=$(address reset_handler)
stack=$(address __stack_top)
load_start=$(address __sram_load_start)
load_end=$(address __sram_load_end)

export FIRMWARE_ELF="$elf"
exec openocd -f "$2" \
    -c 'init; targets stm32n6x.cpu; reset halt' \
    -c "load_image \$::env(FIRMWARE_ELF) 0 elf $load_start $load_end" \
    -c "reg sp $stack; resume $entry; shutdown"
