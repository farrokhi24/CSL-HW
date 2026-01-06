section .data
    msg_ok      db "MISSION OK"
    len_ok      equ $ - msg_ok
    msg_low     db "LOW BATTERY"
    len_low     equ $ - msg_low

section .text
    global _start

_start:
    mov r12, 50

.main_loop:
    cmp r12, 1
    jl .out_of_battery

    mov rax, 100
    syscall
    sub r12, 1

    cmp rax, 2
    je .handle_destination

    cmp rax, 1
    je .handle_jump

.handle_move:
    cmp r12, 2
    jl .out_of_battery
    mov rax, 101
    mov rdi, 0
    syscall
    sub r12, 2
    jmp .main_loop

.handle_jump:
    cmp r12, 2
    jl .out_of_battery
    mov rax, 101
    mov rdi, 1
    syscall
    sub r12, 2
    jmp .main_loop

.handle_destination:
    cmp r12, 2
    jl .out_of_battery
    mov rax, 101
    mov rdi, 0
    syscall
    sub r12, 2
    
    mov rax, 102
    mov rdi, msg_ok
    mov rsi, len_ok
    syscall

.out_of_battery:
    mov rax, 102
    mov rdi, msg_low
    mov rsi, len_low
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits