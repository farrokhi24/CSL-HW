# 403171051, 403110409

#######test#########

.data
    arrA:    .word 1, 2, 3, 4, 5
    nA:      .word 5
    arrB:    .word 6, 7, 8, 9, 10, 11
    nB:      .word 6
    indices: .word 2, 4, 5
    nSwaps:  .word 3
    lblA:    .asciiz "A: "
    lblB:    .asciiz "B: "
    sep:     .asciiz ", "
    nl:      .asciiz "\n"

.text
.globl main

main:
    la $a0, arrA
    la $a1, arrB
    la $a2, indices
    lw $a3, nSwaps
    jal swap_by_indices
    la $a0, arrA
    lw $a1, nA
    la $a2, lblA
    jal print_fmt
    la $a0, arrB
    lw $a1, nB
    la $a2, lblB
    jal print_fmt
    li $v0, 10
    syscall
print_fmt:
    move $t0, $a0
    move $t1, $a1
    li $v0, 4
    move $a0, $a2
    syscall
loop:
    li $v0, 1
    lw $a0, 0($t0)
    syscall
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    beqz $t1, done
    li $v0, 4
    la $a0, sep
    syscall
    j loop
done:
    li $v0, 4
    la $a0, nl
    syscall
    jr $ra
    
###################
    
swap_by_indices:
    move $t0, $a0
    move $t1, $a1
    
    # swap first index (TODO)
    lw $t3, 0($a2)   # index to be swapped
    sll $t3, $t3, 2  # index * 4
    add $a0, $a0, $t3 # address of A[index]
    lw $t2, 0($a0)   # value of A[index]
    add $a1, $a1, $t3 # address of B[index]
    lw $t4, 0($a1)   # value of B[index]
    
    sw $t2, 0($a1)   # store A value in B
    sw $t4, 0($a0)   # store B value in A
    
    move $a0, $t0
    move $a1, $t1
    jr $ra