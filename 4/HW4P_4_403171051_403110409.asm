# 403171051, 403110409

swap_by_indices:
    # store registers on stack: $s0, $s1, $s2, $s3, $ra
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    # parameters:
    move $s0, $a0 # A base address
    move $s1, $a1 # B base address
    move $s2, $a2 # index list base address
    move $s3, $a3 # number of swaps to be done

loop:
    beqz $s3, end # if nothing left to swap go to end

    lw $t0, 0($s2) # index to be swapped in $t0
    addi $t0, $t0, -1 # convert to zero based index
    bltz $t0, next_index # if index >= 0
    sll $t0, $t0, 2 # 4 * index

    addu $t1, $s0, $t0 # address of A[index] in $t1
    lw $t2, 0($t1) # value of A[index] in $t2
    addu $t3, $s1, $t0 # address of B[index] in $t3
    lw $t4, 0($t3) # value of B[index] in $t4
    sw $t4, 0($t1) # store value of B[index] in address of A[index]
    sw $t2, 0($t3) # store value of A[index] in address of B[index]

next_index:
    addi $s2, $s2, 4 # address of list[index + 1]
    addi $s3, $s3, -1 # number of swaps left
    j loop

end:
    # restore registers from stack:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addi $sp, $sp, 24 # restore stack pointer
    jr $ra # return
    nop