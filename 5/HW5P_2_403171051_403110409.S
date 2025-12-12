.data

.align 2
read_buffer: .space 2048
read_ptr: .word 0
read_end: .word 0

.align 2
print_buffer: .space 15
space_char: .byte 32, 0
newline_char: .byte 10, 0
merge_label: .asciiz "Merged Array: "

.text
.globl __start

__start:
    jal read_int
    move $s0, $v0
    li $t0, 10000
    bgt $s0, $t0, exit_program
    blez $s0, print_array_and_exit
    sll $a0, $s0, 2
    li $v0, 9
    syscall
    move $s1, $v0
    move $a0, $s1
    move $a1, $s0
    jal read_array

    move $a0, $s1
    move $a1, $s0
    jal merge_sort

print_array_and_exit:
    move $a0, $s1
    move $a1, $s0
    jal print_array

exit_program:
    li $v0, 4001
    li $a0, 0
    syscall


read_buffer_fill:
    li $v0, 4004
    li $a0, 0
    la $a1, read_buffer
    li $a2, 2048
    syscall
    la $t0, read_ptr
    sw $zero, 0($t0)
    la $t0, read_end
    sw $v0, 0($t0)
    jr $ra


read_char:
    la $t0, read_ptr
    lw $t1, 0($t0)
    la $t2, read_end
    lw $t2, 0($t2)
    bge $t1, $t2, refill_and_check
    la $a0, read_buffer
    add $a0, $a0, $t1
    lbu $v0, 0($a0)
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    jr $ra
    
refill_and_check:
    jal read_buffer_fill
    beqz $v0, eof_return
    j read_char
    
eof_return:
    move $v0, $zero
    jr $ra


read_int:
    addi $sp, $sp, -8
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    li $s2, 0
    li $s3, 1

read_int_skip_ws:
    jal read_char
    move $t0, $v0
    beqz $t0, read_int_done
    li $t1, 32
    beq $t0, $t1, read_int_skip_ws
    li $t1, 9
    beq $t0, $t1, read_int_skip_ws
    li $t1, 10
    beq $t0, $t1, read_int_skip_ws
    li $t1, 13
    beq $t0, $t1, read_int_skip_ws
    li $t1, 45
    beq $t0, $t1, read_int_neg
    li $t1, 43
    beq $t0, $t1, read_int_start_digits
    j read_int_process_digit

read_int_neg:
    li $s3, -1
    j read_int_next_char

read_int_start_digits:
read_int_next_char:
    jal read_char
    move $t0, $v0
    beqz $t0, read_int_done

read_int_process_digit:
    li $t1, 48
    blt $t0, $t1, read_int_not_digit
    li $t1, 57
    bgt $t0, $t1, read_int_not_digit
    li $t1, 48
    sub $t0, $t0, $t1
    sll $t1, $s2, 3
    sll $t2, $s2, 1
    add $s2, $t1, $t2
    add $s2, $s2, $t0
    j read_int_next_char

read_int_not_digit:
read_int_done:
    mul $v0, $s2, $s3
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    addi $sp, $sp, 8
    jr $ra


read_array:
    move $t0, $zero

read_array_loop:
    beq $t0, $a1, read_array_done
    sll $t1, $t0, 2
    add $t1, $a0, $t1
    jal read_int
    sw $v0, 0($t1)
    addi $t0, $t0, 1
    j read_array_loop

read_array_done:
    jr $ra


print_char:
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    li $v0, 4004
    li $a0, 1
    move $a1, $sp
    li $a2, 1
    syscall
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra


print_string:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t0, $a0 

print_string_loop:
    lbu $a0, 0($t0) 
    beqz $a0, print_string_done 
    
    jal print_char
    addi $t0, $t0, 1
    j print_string_loop

print_string_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


print_int:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)
    move $s2, $a0
    li $s3, 0
    bge $s2, $zero, print_int_check_zero
    li $s3, 1
    sub $s2, $zero, $s2
print_int_check_zero:
    bnez $s2, print_int_convert
    li $a0, 48
    jal print_char
    j print_int_done
print_int_convert:
    la $t0, print_buffer
print_int_digit_loop:
    addi $t0, $t0, -1
    li $t2, 10
    div $s2, $t2
    mfhi $t1
    mflo $s2
    li $t2, 48
    add $t1, $t1, $t2
    sb $t1, 0($t0)
    bnez $s2, print_int_digit_loop
    beqz $s3, print_int_print_buffer
    addi $t0, $t0, -1
    li $t1, 45
    sb $t1, 0($t0)
print_int_print_buffer:
    la $t1, print_buffer
print_int_print_loop:
    bge $t0, $t1, print_int_done
    lbu $a0, 0($t0)
    bnez $a0, print_int_call_print_char
    j print_int_done
print_int_call_print_char:
    jal print_char
    addi $t0, $t0, 1
    j print_int_print_loop
print_int_done:
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra


print_subarray:
    # $a0: start_ptr, $a1: n
    addi $sp, $sp, -8
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0 # array_ptr
    move $s1, $a1 # n
    move $t0, $zero # i = 0

print_subarray_loop:
    beq $t0, $s1, print_subarray_done
    sll $t1, $t0, 2
    add $t1, $s0, $t1
    lw $a0, 0($t1)
    jal print_int
    addi $t1, $t0, 1
    beq $t1, $s1, print_subarray_no_space
    lb $a0, space_char
    jal print_char

print_subarray_no_space:
    addi $t0, $t0, 1
    j print_subarray_loop

print_subarray_done:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


print_array:
    move $t0, $zero

print_array_loop:
    beq $t0, $a1, print_array_done
    sll $t1, $t0, 2
    add $t1, $a0, $t1
    lw $a0, 0($t1)
    jal print_int
    addi $t1, $t0, 1
    beq $t1, $a1, print_array_no_space
    lb $a0, space_char
    jal print_char

print_array_no_space:
    addi $t0, $t0, 1
    j print_array_loop

print_array_done:
    lb $a0, newline_char
    jal print_char
    jr $ra


merge_sort:
    li $t0, 1
    ble $a1, $t0, merge_sort_done
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    move $s0, $a0
    move $s1, $a1
    li $t0, 2
    div $s1, $t0
    mflo $s2
    move $a0, $s0
    move $a1, $s2
    jal merge_sort
    sll $t0, $s2, 2
    add $a0, $s0, $t0
    sub $a1, $s1, $s2
    jal merge_sort
    move $a0, $s0
    move $a1, $s2
    sub $a2, $s1, $s2
    jal merge
    
    # DEBUG: Print merged result
    move $a0, $s0
    la $a1, merge_label
    jal print_string
    move $a0, $s0
    move $a1, $s1
    jal print_subarray
    lb $a0, newline_char
    jal print_char
    
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
merge_sort_done:
    jr $ra


merge:
    addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    add $s6, $s1, $s2
    sll $t0, $s6, 2
    sub $sp, $sp, $t0
    move $s7, $sp
    li $s3, 0
    li $s4, 0
    li $s5, 0
    sll $t0, $s1, 2
    add $t0, $s0, $t0
    move $t9, $t0

merge_loop:
    beq $s3, $s1, copy_right_remaining
    beq $s4, $s2, copy_left_remaining
    sll $t0, $s3, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)
    sll $t0, $s4, 2
    add $t0, $t9, $t0
    lw $t2, 0($t0)
    bge $t1, $t2, use_left
    move $t3, $t2
    addi $s4, $s4, 1
    j store_to_temp
use_left:
    move $t3, $t1
    addi $s3, $s3, 1
store_to_temp:
    sll $t0, $s5, 2
    add $t0, $s7, $t0
    sw $t3, 0($t0)
    addi $s5, $s5, 1
    j merge_loop

copy_left_remaining:
    beq $s3, $s1, copy_to_original_array
    sll $t0, $s3, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)
    sll $t0, $s5, 2
    add $t0, $s7, $t0
    sw $t1, 0($t0)
    addi $s3, $s3, 1
    addi $s5, $s5, 1
    j copy_left_remaining

copy_right_remaining:
    beq $s4, $s2, copy_to_original_array
    sll $t0, $s4, 2
    add $t0, $t9, $t0
    lw $t2, 0($t0)
    sll $t0, $s5, 2
    add $t0, $s7, $t0
    sw $t2, 0($t0)
    addi $s4, $s4, 1
    addi $s5, $s5, 1
    j copy_right_remaining

copy_to_original_array:
    li $t0, 0

copy_back_loop:
    beq $t0, $s6, merge_done
    sll $t1, $t0, 2
    add $t2, $s7, $t1
    lw $t3, 0($t2)
    add $t2, $s0, $t1
    sw $t3, 0($t2)
    addi $t0, $t0, 1
    j copy_back_loop

merge_done:
    sll $t0, $s6, 2
    add $sp, $sp, $t0
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra
