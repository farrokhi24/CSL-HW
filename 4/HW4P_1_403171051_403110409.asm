# 403171051, 403110409

.data
buffer: .space 40
add_str: .asciiz "add $"
sub_str: .asciiz "sub $"
and_str: .asciiz "and $"
or_str:  .asciiz "or $"
nor_str: .asciiz "nor $"
slt_str: .asciiz "slt $"
space:   .asciiz " $"


.text
.globl main
main:
    la $a0, buffer
    li $a1, 40
    li $v0, 8
    syscall

    la $t1, buffer
    li $t0, 0
    li $t2, 32

convert_loop:
    lb $t3, 0($t1)
    beqz $t3, done_convert
    sll $t0, $t0, 1
    li $t4, 49
    beq $t3, $t4, add_one
    j next_bit

add_one:
    addi $t0, $t0, 1

next_bit:
    addi $t1, $t1, 1
    addi $t2, $t2, -1
    bgtz $t2, convert_loop

done_convert:
    andi $t5, $t0, 0x3F
    srl $t6, $t0, 11
    andi $t6, $t6, 0x1F
    srl $t7, $t0, 21
    andi $t7, $t7, 0x1F
    srl $t8, $t0, 16
    andi $t8, $t8, 0x1F

    li $v0, 4
    beq $t5, 32, print_add
    beq $t5, 34, print_sub
    beq $t5, 36, print_and
    beq $t5, 37, print_or
    beq $t5, 39, print_nor
    beq $t5, 42, print_slt
    j exit

print_add:
    li $v0, 4
    la $a0, add_str
    syscall
    j print_regs
print_sub:
    li $v0, 4
    la $a0, sub_str
    syscall
    j print_regs
print_and:
    li $v0, 4
    la $a0, and_str
    syscall
    j print_regs
print_or:
    li $v0, 4
    la $a0, or_str
    syscall
    j print_regs
print_nor:
    li $v0, 4
    la $a0, nor_str
    syscall
    j print_regs
print_slt:
    li $v0, 4
    la $a0, slt_str
    syscall
    j print_regs

print_regs:
    li $v0, 1
    move $a0, $t6
    syscall
    li $v0, 4
    la $a0, space
    syscall
    li $v0, 1
    move $a0, $t7
    syscall
    li $v0, 4
    la $a0, space
    syscall
    li $v0, 1
    move $a0, $t8
    syscall
    j exit

exit:
    li $v0, 10
    syscall