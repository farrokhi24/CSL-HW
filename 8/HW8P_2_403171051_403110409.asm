global main
extern scanf
extern printf

section .data
    fmt_n db "%d", 0
    fmt_p db "%lf %lf %lf", 0
    fmt_out db "%.6lf", 10, 0
    inf dq 1.0e300

section .bss
    N resd 1
    points resq 300
    min_d resq 1

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rdi, [rel fmt_n]
    lea rsi, [rel N]
    xor eax, eax
    call scanf

    lea r12, [rel points]

    xor r13d, r13d
.read_loop:
    cmp r13d, [rel N]
    jge .read_done

    mov rax, r13
    imul rax, 24

    lea rdi, [rel fmt_p]
    lea rsi, [r12 + rax]
    lea rdx, [r12 + rax + 8]
    lea rcx, [r12 + rax + 16]
    xor eax, eax
    call scanf

    inc r13d
    jmp .read_loop

.read_done:
    movsd xmm0, [rel inf]
    movsd [rel min_d], xmm0

    xor r8d, r8d
.outer_loop:
    cmp r8d, [rel N]
    jge .print_result

    mov r9d, r8d
    inc r9d

.inner_loop:
    cmp r9d, [rel N]
    jge .next_i

    mov rax, r8
    imul rax, 24

    mov rbx, r9
    imul rbx, 24

    movsd xmm0, [r12 + rax]
    movsd xmm1, [r12 + rax + 8]
    movsd xmm2, [r12 + rax + 16]

    movsd xmm3, [r12 + rbx]
    movsd xmm4, [r12 + rbx + 8]
    movsd xmm5, [r12 + rbx + 16]

    subsd xmm0, xmm3
    mulsd xmm0, xmm0

    subsd xmm1, xmm4
    mulsd xmm1, xmm1

    subsd xmm2, xmm5
    mulsd xmm2, xmm2

    addsd xmm0, xmm1
    addsd xmm0, xmm2
    sqrtsd xmm0, xmm0

    movsd xmm6, [rel min_d]
    ucomisd xmm0, xmm6
    jae .skip_update
    movsd [rel min_d], xmm0

.skip_update:
    inc r9d
    jmp .inner_loop

.next_i:
    inc r8d
    jmp .outer_loop

.print_result:
    lea rdi, [rel fmt_out]
    movsd xmm0, [rel min_d]
    mov eax, 1
    call printf

    leave
    ret
