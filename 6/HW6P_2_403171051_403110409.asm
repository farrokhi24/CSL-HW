section .data
    minus_one db "-1", 10

section .bss
    memory     resq 65536
    visited    resb 65536
    out_buf    resb 64
    in_buffer  resb 8192
    in_pos     resq 1
    in_len     resq 1

section .text
    global _start

_start:
    mov qword [in_pos], 0
    mov qword [in_len], 0

    call read_uint
    mov r12, rax

.load_loop:
    test r12, r12
    jz .get_start
    call read_uint
    mov r13, rax
    call read_uint
    mov r14, rax
    and r13, 0xFFFF
    mov [memory + r13*8], r14
    dec r12
    jmp .load_loop

.get_start:
    call read_uint
    mov r12, rax

.traverse:
    and r12, 0xFFFF
    cmp byte [visited + r12], 1
    je .not_found
    mov byte [visited + r12], 1

    mov r13, [memory + r12*8]
    test r13, r13
    jz .not_found

    mov rax, r13
    and rax, 0xFFFF
    mov r14, [memory + rax*8]

    mov rax, r14
    and rax, 0xFFFF
    mov r15, [memory + rax*8]

    test r13, r13
    jz .step_next
    test r14, r14
    jz .step_next
    test r15, r15
    jz .step_next

    mov rdx, r13
    add rdx, r14
    cmp rdx, r15
    jne .step_next

    mov rax, r15
    and rax, 0xFFFF
    mov rax, [memory + rax*8]
    and rax, 0xFFFF
    mov rax, [memory + rax*8]

    test rax, rax
    jnz .print_ok

    mov rax, 1
    mov rdi, 1
    lea rsi, [minus_one]
    mov rdx, 3
    syscall
    jmp .exit

.print_ok:
    mov rdi, rax
    call print_uint
    jmp .exit

.step_next:
    mov r12, r13
    jmp .traverse

.not_found:
    mov rax, 1
    mov rdi, 1
    lea rsi, [minus_one]
    mov rdx, 3
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall

get_char:
    mov rax, [in_pos]
    cmp rax, [in_len]
    jb .buf
    mov rax, 0
    mov rdi, 0
    lea rsi, [in_buffer]
    mov rdx, 8192
    syscall
    test rax, rax
    jle .eof
    mov [in_len], rax
    mov qword [in_pos], 0
.buf:
    mov rax, [in_pos]
    movzx rax, byte [in_buffer + rax]
    inc qword [in_pos]
    ret
.eof:
    mov rax, -1
    ret

read_uint:
    push rbx
    xor rbx, rbx
.skip:
    call get_char
    cmp rax, -1
    je .done
    cmp al, '0'
    jb .skip
    cmp al, '9'
    ja .skip
.read:
    sub al, '0'
    imul rbx, 10
    add rbx, rax
    call get_char
    cmp al, '0'
    jb .done
    cmp al, '9'
    ja .done
    jmp .read
.done:
    mov rax, rbx
    pop rbx
    ret

print_uint:
    test rdi, rdi
    jnz .nz
    mov rax, 1
    mov rdi, 1
    mov byte [out_buf], '0'
    mov byte [out_buf + 1], 10
    lea rsi, [out_buf]
    mov rdx, 2
    syscall
    ret

.nz:
    mov rax, rdi
    lea rdi, [out_buf + 63]
    mov byte [rdi], 10
    mov rbx, 10
.conv:
    dec rdi
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi], dl
    test rax, rax
    jnz .conv
    mov rsi, rdi
    lea rdx, [out_buf + 64]
    sub rdx, rsi
    mov rax, 1
    mov rdi, 1
    syscall
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
