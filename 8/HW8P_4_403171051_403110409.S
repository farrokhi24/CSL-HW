.section .bss
    .lcomm buffer, 514
    .lcomm out_buf, 16

.section .data
    nl: .byte 10

.section .text
    .globl main

main:
    stmg   %r11, %r15, 88(%r15)
    aghi   %r15, -160

    lghi   %r1, 3
    lghi   %r2, 0
    larl   %r3, buffer
    lghi   %r4, 514
    svc    0
    
    lgr    %r10, %r2
    aghi   %r10, -1
    lghi   %r11, 0

find_space:
    larl   %r1, buffer
    llgc   %r3, 0(%r11, %r1)
    chi    %r3, 32
    je     found_space
    aghi   %r11, 1
    cr     %r11, %r10
    jl     find_space
    j      exit_prog

found_space:
    lgr    %r4, %r11
    lgr    %r5, %r11
    aghi   %r5, 1
    lgr    %r6, %r10
    sr     %r6, %r5

    lghi   %r8, 0
    lgr    %r7, %r4
    sr     %r7, %r6
    jl     print_res

    lghi   %r11, 0
outer_loop:
    lghi   %r12, 0
inner_loop:
    lgr    %r1, %r11
    ar     %r1, %r12
    larl   %r2, buffer
    llgc   %r3, 0(%r1, %r2)
    lgr    %r13, %r5
    ar     %r13, %r12
    llgc   %r14, 0(%r13, %r2)
    cr     %r3, %r14
    jne    next_i
    aghi   %r12, 1
    cr     %r12, %r6
    jl     inner_loop
    aghi   %r8, 1
next_i:
    aghi   %r11, 1
    cr     %r11, %r7
    jle    outer_loop

print_res:
    lgr    %r2, %r8
    brasl  %r14, int_to_str
    lgr    %r4, %r2
    lghi   %r1, 4
    lghi   %r2, 1
    larl   %r3, out_buf
    svc    0
    lghi   %r1, 4
    lghi   %r2, 1
    larl   %r3, nl
    lghi   %r4, 1
    svc    0

exit_prog:
    lghi   %r1, 1
    lghi   %r2, 0
    svc    0

int_to_str:
    larl   %r1, out_buf
    aghi   %r1, 15
    lghi   %r0, 0
    stc    %r0, 0(%r1)
    lghi   %r5, 10
    
    ltr    %r2, %r2
    jnz    conv_loop
    aghi   %r1, -1
    lghi   %r0, 48
    stc    %r0, 0(%r1)
    j      done_conv
conv_loop:
    aghi   %r1, -1
    lgr    %r3, %r2
    lghi   %r2, 0
    dlgr   %r2, %r5
    lgr    %r13, %r2
    aghi   %r13, 48
    stc    %r13, 0(%r1)
    lgr    %r2, %r3
    ltgr   %r2, %r2
    jnz    conv_loop
done_conv:
    lgr    %r2, %r1
    larl   %r3, out_buf
    lghi   %r4, 0
move_loop:
    llgc   %r0, 0(%r2)
    stc    %r0, 0(%r4, %r3)
    aghi   %r4, 1
    aghi   %r2, 1
    ltr    %r0, %r0
    jnz    move_loop
    aghi   %r4, -1
    lgr    %r2, %r4
    br     %r14