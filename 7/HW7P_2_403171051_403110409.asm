section .data
    fmt_in      db "%s", 0
    fmt_out     db "%s", 10, 0

section .bss
    str1        resb 100005
    str2        resb 100005
    result      resb 100010
    res_ptr     resq 1

section .text
    global main
    extern scanf
    extern printf
    extern strlen

recursive_add:
    push rbp
    mov rbp, rsp
    
    cmp rdi, str1
    jl .check_str2
    jmp .process
.check_str2:
    cmp rsi, str2
    jl .check_carry
    jmp .process
.check_carry:
    test rdx, rdx
    jnz .process
    leave
    ret

.process:
    xor r8, r8
    cmp rdi, str1
    jl .skip1
    movzx r8, byte [rdi]
    sub r8, '0'
    dec rdi
.skip1:
    xor r9, r9
    cmp rsi, str2
    jl .skip2
    movzx r9, byte [rsi]
    sub r9, '0'
    dec rsi
.skip2:
    add r8, r9
    add r8, rdx
    
    mov rax, r8
    xor rdx, rdx
    mov r10, 10
    div r10
    
    push rdx
    mov rdx, rax
    call recursive_add
    
    pop rdx
    add dl, '0'
    mov rbx, [res_ptr]
    mov [rbx], dl
    inc qword [res_ptr]
    mov rbx, [res_ptr]
    mov byte [rbx], 0
    
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    
    lea rdi, [fmt_in]
    lea rsi, [str1]
    xor eax, eax
    call scanf
    
    lea rdi, [fmt_in]
    lea rsi, [str2]
    xor eax, eax
    call scanf
    
    lea rdi, [str1]
    call strlen
    mov r12, rax
    
    lea rdi, [str2]
    call strlen
    mov r13, rax
    
    lea rdi, [str1 + r12 - 1]
    lea rsi, [str2 + r13 - 1]
    xor rdx, rdx
    lea rax, [result]
    mov [res_ptr], rax
    
    call recursive_add
    
    lea rdi, [fmt_out]
    lea rsi, [result]
    xor eax, eax
    call printf
    
    xor eax, eax
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits