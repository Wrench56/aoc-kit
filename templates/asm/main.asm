extern strtoull
extern printf

%include "utils.inc"
default rel

section .data
    pstr db "Length: %u", 10, 0

section .text
global entry
entry:
    ; Get input length (rounded up to the next 16 byte boundry)
    mov             arg(1), [rsi + 8]
    xor             arg(2), arg(2)
    mov             arg(3), 10
    call            strtoull
    add             rax, 15
    and             rax, -16

    ; The beginning of the input file
    mov             arg(1), [rsi + 16]

    xor             eax, eax
    ret
