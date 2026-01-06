section .bss
    in_buf   resb 1024
    out_buf  resb 1024

section .text
    global _start

_start:
    mov rax, 0          
    mov rdi, 0          
    lea rsi, [in_buf]
    mov rdx, 1024
    syscall
    
    mov r12, rax        
    mov rcx, rax        
    
    lea rsi, [in_buf]   
    lea rdi, [out_buf]  
    cld                 

.convert_loop:
    test rcx, rcx
    jz .print

    lodsb               
    cmp al, 'a'
    jb .store
    cmp al, 'z'
    ja .store
    sub al, 32          

.store:
    stosb               
    dec rcx
    jmp .convert_loop

.print:
    mov rax, 1          
    mov rdi, 1          
    lea rsi, [out_buf]
    mov rdx, r12        
    syscall

    mov rax, 60         
    xor rdi, rdi
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits