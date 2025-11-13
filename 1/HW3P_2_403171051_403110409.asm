# 403171051, 403110409

.text
.globl main

.macro right_bit()
    andi $t1, $t0, 1 # right bit of $t0 is saved in $t1
    add $t2, $t2, $t1
    srl $t0, $t0, 1
.end_macro

main:
    li $v0, 5
    syscall # input int
    move $t0, $v0 # input is in $t0
    li $t2, 0 # $t2 is counter for 1s
    
    # 32 times
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()
    right_bit()

    li $v0, 1
    move $a0, $t2
    syscall # print int $t2 

    li $v0, 10
    syscall