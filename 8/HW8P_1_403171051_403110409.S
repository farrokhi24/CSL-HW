    .text
    .align 4
    .global main

main:
    stmg    %r6, %r15, 48(%r15)
    lgr     %r1, %r15
    aghi    %r15, -176
    stg     %r1, 0(%r15)

    larl    %r10, stations
    xc      0(32,%r10), 0(%r10)

    lghi    %r2, 0
    brasl   %r14, fflush

input_loop:
    brasl   %r14, getchar
    
    chi     %r2, -1
    je      do_exit

    lgr     %r13, %r2
    
    chi     %r13, 32
    je      input_loop
    chi     %r13, 10
    je      input_loop
    chi     %r13, 13
    je      input_loop

    chi     %r13, 'q'
    je      do_exit

    chi     %r13, 'a'
    je      handle_a

    chi     %r13, 't'
    je      handle_t

    chi     %r13, 'd'
    je      handle_d

    j       input_loop

handle_a:
    mvi     0(%r10), 1
    j       input_loop

handle_t:
    lghi    %r2, 31
t_loop:
    chi     %r2, 0
    jle     t_done
    
    lgr     %r3, %r2
    aghi    %r3, -1
    
    llgc    %r4, 0(%r3, %r10)
    stc     %r4, 0(%r2, %r10)
    
    aghi    %r2, -1
    j       t_loop
t_done:
    mvi     0(%r10), 0
    j       input_loop

handle_d:
    larl    %r2, fmt_in
    la      %r3, 160(%r15)
    brasl   %r14, scanf
    
    lg      %r7, 160(%r15)
    lgr     %r8, %r7

search_bus:
    cghi    %r8, 0
    jl      not_found
    
    chi     %r8, 31
    jh      not_found

    llgc    %r4, 0(%r8, %r10)
    chi     %r4, 1
    je      found_bus
    
    aghi    %r8, -1
    j       search_bus

found_bus:
    sgr     %r7, %r8
    lgr     %r3, %r7
    j       print_res

not_found:
    lghi    %r3, -1

print_res:
    larl    %r2, fmt_out
    brasl   %r14, printf
    
    lghi    %r2, 0
    brasl   %r14, fflush
    j       input_loop

do_exit:
    lghi    %r2, 0
    lmg     %r6, %r15, 224(%r15)
    br      %r14

.data
    .align 8
stations:   .fill 32, 1, 0
    .align 8
fmt_in:     .asciz "%ld"
fmt_out:    .asciz "%lld\n"
