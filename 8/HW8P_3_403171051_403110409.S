.section .bss
    .lcomm input1, 6
    .lcomm input2, 6
    .lcomm output, 5

.section .data
    newline: .byte 10

.section .text
    .globl main

main:
    stmg   %r11, %r15, 88(%r15)
    aghi   %r15, -160

    lghi   %r1, 3
    lghi   %r2, 0
    larl   %r3, input1
    lghi   %r4, 5
    svc    0

    lghi   %r1, 3
    lghi   %r2, 0
    larl   %r3, input2
    lghi   %r4, 5
    svc    0

    larl   %r2, input1
    brasl  %r14, parse_float
    lgr    %r6, %r2

    larl   %r2, input2
    brasl  %r14, parse_float
    lgr    %r7, %r2

    agr    %r6, %r7

    lgr    %r2, %r6
    brasl  %r14, encode_float
    lgr    %r8, %r2

    larl   %r2, output
    lgr    %r1, %r8
    srl    %r1, 3
    nilf   %r1, 1
    brasl  %r14, write_bit
    lgr    %r1, %r8
    srl    %r1, 2
    nilf   %r1, 1
    brasl  %r14, write_bit
    lgr    %r1, %r8
    srl    %r1, 1
    nilf   %r1, 1
    brasl  %r14, write_bit
    lgr    %r1, %r8
    nilf   %r1, 1
    brasl  %r14, write_bit

    lghi   %r1, 4
    lghi   %r2, 1
    larl   %r3, output
    lghi   %r4, 4
    svc    0

    lghi   %r1, 4
    lghi   %r2, 1
    larl   %r3, newline
    lghi   %r4, 1
    svc    0

    lghi   %r1, 1
    lghi   %r2, 0
    svc    0

parse_float:
    lghi   %r3, 0
    lghi   %r4, 0
parse_loop:
    llgc   %r5, 0(%r4,%r2)
    chi    %r5, 48
    jl     parse_done
    chi    %r5, 49
    jh     parse_done
    aghi   %r5, -48
    sll    %r3, 1
    or     %r3, %r5
    aghi   %r4, 1
    chi    %r4, 4
    jl     parse_loop
parse_done:
    lgr    %r10, %r3
    srl    %r10, 3
    lgr    %r11, %r3
    srl    %r11, 1
    nilf   %r11, 3
    lgr    %r12, %r3
    nilf   %r12, 1
    chi    %r11, 0
    je     is_denorm_in
    aghi   %r12, 2
    aghi   %r11, -1
    sll    %r12, 0(%r11)
    j      check_sign
is_denorm_in:
    j      check_sign
check_sign:
    chi    %r10, 1
    jne    pos_val
    lcr    %r12, %r12
pos_val:
    lgr    %r2, %r12
    br     %r14

encode_float:
    lghi   %r3, 0
    ltr    %r2, %r2
    jhe    pos_enc
    lghi   %r3, 8
    lcr    %r2, %r2
pos_enc:
    chi    %r2, 0
    je     ret_zero
    chi    %r2, 12
    jh     set_max
    chi    %r2, 8
    jnl    encode_exp3
    chi    %r2, 4
    jnl    encode_exp2
    chi    %r2, 2
    jnl    encode_exp1
    lghi   %r4, 0
    lgr    %r5, %r2
    j      combine
encode_exp3:
    lghi   %r4, 6
    lghi   %r5, 0
    chi    %r2, 12
    jl     combine
    lghi   %r5, 1
    j      combine
encode_exp2:
    lghi   %r4, 4
    lghi   %r5, 0
    chi    %r2, 6
    jl     combine
    lghi   %r5, 1
    j      combine
encode_exp1:
    lghi   %r4, 2
    lghi   %r5, 0
    chi    %r2, 3
    jl     combine
    lghi   %r5, 1
    j      combine
set_max:
    lghi   %r4, 6
    lghi   %r5, 1
    j      combine
ret_zero:
    lghi   %r2, 0
    br     %r14
combine:
    or     %r3, %r4
    or     %r3, %r5
    lgr    %r2, %r3
    br     %r14

write_bit:
    aghi   %r1, 48
    stc    %r1, 0(%r2)
    aghi   %r2, 1
    br     %r14