# 403171051, 403110409

.data
    string: .space 10001 # buffer for input string
    .align 2
    array: .space 4000 # store up to 1000 integers
    newline: .asciiz "\n"

.text
.globl main

main:
    li $v0, 8 # input string
    la $a0, string
    li $a1, 10001
    syscall

    la $t0, string # address of string
    la $t1, array # address of array
    
    li $t2, 0 # current number
    
    li $t3, 0 # if the current character is in a number, equals 1, otherwise 0
    
    li $t7, 0 # array length

loop1:
    lb $t4, 0($t0) # load character
    beqz $t4, parse_finish # end of string

    li $t5, '0'
    li $t6, '9'
    blt $t4, $t5, not_digit
    bgt $t4, $t6, not_digit

    li $t3, 1 # set inside a number
    sub $t4, $t4, $t5 # digit = char - '0' in $t4
    mul $t2, $t2, 10
    add $t2, $t2, $t4
    j next_char

not_digit:
    beq $t3, $zero, next_char
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    addi $t7, $t7, 1
    li $t2, 0
    li $t3, 0

next_char:
    addi $t0, $t0, 1
    j loop1

parse_finish:
    beq $t3, $zero, start_count
    sw $t2, 0($t1)
    addi $t7, $t7, 1

start_count:
    la $t0, array # reset pointer to array start
    li $t8, 0 # maximum count
    li $t9, 0 # the number with maximum count

    li $s0, 0

loop2: # count number of array[i] duplicates
    bge $s0, $t7, print_result
    lw $s1, 0($t0) # load array[i]
    li $s2, 0 # count = 0

    la  $s3, array
    li  $s4, 0

loop3:
    bge $s4, $t7, done3
    lw  $s5, 0($s3)
    beq $s5, $s1, increment_count
    j next3

increment_count:
    addi $s2, $s2, 1

next3:
    addi $s3, $s3, 4
    addi $s4, $s4, 1
    j loop3

done3:
    # if current number's count is larger than the previous maximum count
    bgt $s2, $t8, update_max
    j next2

update_max:
    move $t8, $s2 # maximum count
    move $t9, $s1 # value with maximum count

next2:
    addi $t0, $t0, 4
    addi $s0, $s0, 1
    j loop2

print_result:
    li $v0, 1
    move $a0, $t9
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall
