section .data
    input_format db "%ld", 0
    output_format db "%ld^%ld", 0
    separator db "*", 0
    newline db 10, 0
    
section .bss
    n resq 1
    
section .text
    extern printf
    extern scanf
    global main

factor:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    cmp rbx, 1
    je factor_done
    mov rax, r12
    mul r12
    cmp rax, rbx
    jg n_is_prime
    xor rdx, rdx
    mov rax, rbx
    div r12
    cmp rdx, 0
    jne try_next_factor
    xor r14, r14
    
divide_loop:
    inc r14
    mov rbx, rax
    xor rdx, rdx
    mov rax, rbx
    div r12
    cmp rdx, 0
    je divide_loop
    cmp r13, 1
    je print_without_separator
    mov rdi, separator
    xor rax, rax
    call printf
    
print_without_separator:
    mov rdi, output_format
    mov rsi, r12
    mov rdx, r14
    xor rax, rax
    call printf
    mov rdi, rbx
    mov rsi, r12
    mov rdx, 0
    call factor
    jmp factor_done
    
try_next_factor:
    inc r12
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call factor
    jmp factor_done
    
n_is_prime:
    cmp r13, 1
    je print_prime_without_separator
    mov rdi, separator
    xor rax, rax
    call printf
    
print_prime_without_separator:
    mov rdi, output_format
    mov rsi, rbx
    mov rdx, 1
    xor rax, rax
    call printf
    
factor_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    mov rdi, input_format
    mov rsi, n
    xor rax, rax
    call scanf
    mov rdi, [n]
    mov rsi, 2
    mov rdx, 1
    call factor
    mov rdi, newline
    xor rax, rax
    call printf
    xor rax, rax
    mov rsp, rbp
    pop rbp
    ret

section .note.GNU-stack noalloc noexec progbits
