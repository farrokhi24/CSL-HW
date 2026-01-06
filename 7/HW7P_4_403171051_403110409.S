.global _start

.section .bss
input_buf: .skip 32
out_buf:   .skip 32

.section .text

_start:
    mov x0, 0
    ldr x1, =input_buf
    mov x2, 32
    mov x8, 63
    svc 0

    ldr x1, =input_buf
    mov x0, 0

parse_loop:
    ldrb w2, [x1], #1
    cmp w2, #'0'
    blt parse_done
    cmp w2, #'9'
    bgt parse_done
    sub w2, w2, #'0'
    mov x3, 10
    mul x0, x0, x3
    add x0, x0, x2
    b parse_loop

parse_done:
    mov x20, x0
    mov x21, 2

main_loop:
    cmp x21, x20
    bge exit
    mov x22, 2
    mov x23, 1

prime_test:
    mul x24, x22, x22
    cmp x24, x21
    bgt prime_done
    udiv x25, x21, x22
    mul x25, x25, x22
    cmp x25, x21
    beq not_prime
    add x22, x22, 1
    b prime_test

not_prime:
    mov x23, 0

prime_done:
    cmp x23, 1
    bne next_i
    mov x0, x21
    bl print_number
    mov x0, 1
    ldr x1, =space
    mov x2, 1
    mov x8, 64
    svc 0

next_i:
    add x21, x21, 1
    b main_loop

exit:
    mov x0, 0
    mov x8, 93
    svc 0

print_number:
    ldr x1, =out_buf
    add x1, x1, 31
    mov x2, 0

pn_loop:
    mov x3, 10
    udiv x4, x0, x3
    msub x5, x4, x3, x0
    add x5, x5, #'0'
    strb w5, [x1], #-1
    mov x0, x4
    add x2, x2, 1
    cbnz x0, pn_loop

    add x1, x1, 1
    mov x0, 1
    mov x8, 64
    svc 0
    ret

.section .rodata
space: .ascii " "
