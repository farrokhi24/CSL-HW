section .data
fmt_n:   db "%d",0
fmt_in:  db "%d",0
fmt_out: db "%d ",0
fmt_nl:  db 10,0

section .bss
n:       resq 1
matrix:  resq 10000

section .text
global main
extern scanf
extern printf
default rel

main:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    lea rdi, [fmt_n]
    lea rsi, [n]
    xor eax, eax
    call scanf

    mov r15, [n]
    test r15, r15
    jle .done

    lea r14, [matrix]

    xor rbx, rbx
.read_loop:
    mov rax, r15
    imul rax, r15
    cmp rbx, rax
    jge .read_done

    lea rdi, [fmt_in]
    lea rsi, [r14 + rbx*8]
    xor eax, eax
    call scanf

    inc rbx
    jmp .read_loop

.read_done:
    xor r12, r12
.t_i:
    cmp r12, r15
    jge .t_done

    mov r13, r12
    inc r13
.t_j:
    cmp r13, r15
    jge .t_next_i

    mov rax, r12
    imul rax, r15
    add rax, r13
    mov rcx, [r14 + rax*8]

    mov rdx, r13
    imul rdx, r15
    add rdx, r12
    mov rsi, [r14 + rdx*8]

    mov [r14 + rax*8], rsi
    mov [r14 + rdx*8], rcx

    inc r13
    jmp .t_j

.t_next_i:
    inc r12
    jmp .t_i
.t_done:

    xor r12, r12
.rev_row:
    cmp r12, r15
    jge .print

    xor r13, r13
    mov rbx, r15
    dec rbx
.rev_col:
    cmp r13, rbx
    jge .rev_next

    mov rax, r12
    imul rax, r15
    add rax, r13
    mov rcx, [r14 + rax*8]

    mov rdx, r12
    imul rdx, r15
    add rdx, rbx
    mov rsi, [r14 + rdx*8]

    mov [r14 + rax*8], rsi
    mov [r14 + rdx*8], rcx

    inc r13
    dec rbx
    jmp .rev_col

.rev_next:
    inc r12
    jmp .rev_row

.print:
    xor r12, r12
.p_row:
    cmp r12, r15
    jge .done

    xor r13, r13
.p_col:
    cmp r13, r15
    jge .newline

    lea rdi, [fmt_out]
    mov rax, r12
    imul rax, r15
    add rax, r13
    mov rsi, [r14 + rax*8]
    xor eax, eax
    call printf

    inc r13
    jmp .p_col

.newline:
    lea rdi, [fmt_nl]
    xor eax, eax
    call printf

    inc r12
    jmp .p_row

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits