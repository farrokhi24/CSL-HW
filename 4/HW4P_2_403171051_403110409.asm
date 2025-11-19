# 403171051, 403110409

.data
    mask: .byte 0x1F, 0x2B, 0x3C, 0x4D, 0x55
    string: .space 101 # buffer for string input

.text
.globl main

.macro encrypt_char(%reg_k, %reg_char, %reg_mask)
    add $t4, %reg_char, %reg_k # x + k
    xor $t4, $t4, %reg_mask # (x + k) ⊕ mask
    mul $t5, %reg_k, %reg_k # k * k
    add $t4, $t4, $t5 # ((x + k) ⊕ mask) + (k * k)
    
    # mod 256: keep 8 least significant bits
    andi $t4, $t4, 0xFF
    
    move $a0, $t4
    li $v0, 34 # print hexadecimal ## MOSHKEL INJA ##
    syscall
.end_macro

main:
    li $v0, 5 # input int
    syscall
    move $t0, $v0 # k in $t0
    
    la $t1, string # string address in $t1
    li $v0, 8 # input string
    move $a0, $t1
    li $a1, 101
    syscall

    la $t2, mask # mask[0] base address
    li $t7, 0 # mask_index = 0
loop:
    lb $t4, 0($t1) # current char in $t4
    li $t8, '\n'
    beq $t4, $t8, exit # if char == '\n': exit

    # mask[mask_index] in $t3
    lb $t3, 0($t2)
    encrypt_char($t0, $t4, $t3)

    # character address
    addi $t1, $t1, 1

    # mask address
    addi $t2, $t2, 1
    addi $t7, $t7, 1
    li $t8, 5
    bne $t7, $t8, loop
    # if mask_index == 5: mask_index = 0
    la $t2, mask
    li $t7, 0
    j loop

exit:
    li $v0, 10
    syscall
    
# printed: 0x0000006b0x0000005a0x000000660x000000550x0000003a0x0000005c0x000000780x000000640x000000550x00000055
# should be: 6b5a66553a5c78645555 (any 0x000000 removed)