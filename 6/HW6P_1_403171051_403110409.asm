section .data
    fmt_in  db "%s", 0
    fmt_out db "%u", 10, 0

section .bss
    expr    resb 100005
    pos     resq 1

section .text
    global main
    extern scanf
    extern printf

solve:
    push rbp
    mov rbp, rsp

    mov rsi, [pos]
    lea rdi, [expr]
    movzx rbx, byte [rdi + rsi]
    
    inc qword [pos]

    cmp bl, '+'
    je .is_plus
    cmp bl, '-'
    je .is_minus
    cmp bl, '*'
    je .is_mul

    sub bl, '0'
    mov eax, ebx
    jmp .done

.is_plus:
    call solve
    push rax
    call solve
    pop rdx
    add eax, edx
    jmp .done

.is_minus:
    call solve
    push rax
    call solve
    mov ecx, eax
    pop rax
    sub eax, ecx
    jmp .done

.is_mul:
    call solve
    push rax
    call solve
    pop rdx
    imul eax, edx
    jmp .done

.done:
    leave
    ret

main:
    push rbp
    mov rbp, rsp

    lea rdi, [fmt_in]
    lea rsi, [expr]
    xor eax, eax
    call scanf

    mov qword [pos], 0

    call solve

    lea rdi, [fmt_out]
    mov esi, eax
    xor eax, eax
    call printf

    xor eax, eax
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits