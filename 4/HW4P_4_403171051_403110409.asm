# 403171051, 403110409

swap_by_indices:
    # store registers on stack: $s0, $s1, $s2, $s3, $s4, $ra
    addi $sp, $sp, -24 # 6 registers each 4 bytes
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $ra, 0($sp)

    # parameters:
    move $s0, $a0 # A base address
    move $s1, $a1 # B base address
    move $s2, $a2 # index list base address
    move $s3, $a3 # number of swaps to be done

    # if nothing left to swap go to end
    beq $s3, $zero, end

    lw $t0, 0($s2) # index to be swapped in $t0
    addi $t0, $t0, -1 # convert to zero based index
    
    sll $t0, $t0, 2 # 4 * index
    addu $t1, $s0, $t0   # address of A[index] in $t1
    lw $t2, 0($t1) # value of A[index] in $t2
    addu $t3, $s1, $t0   # address of B[index] in $t3
    lw $t4, 0($t3) # value of B[index] in $t4
    sw $t4, 0($t1) # store value of B[index] in address of A[index]
    sw $t2, 0($t3) # store value of A[index] in address of B[index]

    # recursive:
    move $a0, $s0 # A
    move $a1, $s1 # B
    addi $a2, $s2, 4 # next index in list
    addi $a3, $s3, -1 # number of swaps left
    jal swap_by_indices

end:
    # restore registers from stack:
    lw $ra, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    
    addi $sp, $sp, 24 # restore stack pointer
    
    jr $ra # return
