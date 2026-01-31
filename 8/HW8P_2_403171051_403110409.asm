section .data
    fmt_n   db "%d", 0
    fmt_p   db "%lf %lf %lf", 0
    fmt_out db "%.6lf", 10, 0
    inf     dq 1.0e300

section .bss
    N       resd 1
    points  resq 300
    min_d   resq 1

section .text
    global main
    extern scanf
    extern printf

main:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    lea rdi, [fmt_n]
    lea rsi, [N]
    xor eax, eax
    call scanf

    xor r12, r12
.read_loop:
    mov eax, [N]
    cmp r12d, eax
    jge .init_min

    mov rax, r12
    imul rax, 24
    lea rbx, [points + rax]

    lea rdi, [fmt_p]
    lea rsi, [rbx]
    lea rdx, [rbx + 8]
    lea rcx, [rbx + 16]
    xor eax, eax
    call scanf

    inc r12
    jmp .read_loop

.init_min:
    movsd xmm0, [inf]
    movsd [min_d], xmm0

    xor r8, r8
.outer:
    mov eax, [N]
    cmp r8d, eax
    jge .print_res

    mov r9, r8
    inc r9
.inner:
    mov eax, [N]
    cmp r9d, eax
    jge .next_i

    mov rax, r8
    imul rax, 24
    lea rsi, [points + rax]

    mov rbx, r9
    imul rbx, 24
    lea rdi, [points + rbx]

    movsd xmm0, [rsi]
    subsd xmm0, [rdi]
    mulsd xmm0, xmm0

    movsd xmm1, [rsi + 8]
    subsd xmm1, [rdi + 8]
    mulsd xmm1, xmm1

    movsd xmm2, [rsi + 16]
    subsd xmm2, [rdi + 16]
    mulsd xmm2, xmm2

    addsd xmm0, xmm1
    addsd xmm0, xmm2
    sqrtsd xmm0, xmm0

    movsd xmm6, [min_d]
    ucomisd xmm0, xmm6
    jae .skip_upd
    movsd [min_d], xmm0

.skip_upd:
    inc r9
    jmp .inner

.next_i:
    inc r8
    jmp .outer

.print_res:
    lea rdi, [fmt_out]
    movsd xmm0, [min_d]
    mov eax, 1
    call printf

    xor eax, eax
    pop r12
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits