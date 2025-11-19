# 403171051, 403110409

.data
    yes: .asciiz "YES"
    no: .asciiz "NO"

.text
.globl main

main:
    li $v0, 5
    syscall # input int
    move $t1, $v0
    li $v0, 5
    syscall
    move $t2, $v0
    li $v0, 5
    syscall
    move $t3, $v0
    
    mul $t4, $t1, $t1 # $t4 = $t1^2
    mul $t5, $t2, $t2 # $t5 = $t2^2
    mul $t6, $t3, $t3 # $t6 = $t3^2
    
    add $t7, $t4, $t5 # $t7 = $t1^2 + $t2^2
    sub $t8, $t7, $t6 # $t8 = ($t1^2 + $t2^2) - $t3^2
    sra $t9, $t8, 31 # $t9 is 0 if $t8 is positive and 0x11111111 if negative
    andi $t1, $t9, 1 # $t1 is 1 if $t1^2 + $t2^2 < $t3^2 and 0 if $t1^2 + $t2^2 >= $t3^2
    
    add $t7, $t4, $t6
    sub $t8, $t7, $t5
    sra $t9, $t8, 31
    andi $t2, $t9, 1
    
    add $t7, $t5, $t6
    sub $t8, $t7, $t4
    sra $t9, $t8, 31
    andi $t3, $t9, 1
    
    or $t4, $t1, $t2
    or $t4, $t4, $t3
    
    la $a0, no
    la $t5, yes
    
    # if $t4 is 1 save yes in $a0
    sub $t6, $t5, $a0 # $t6 = address of no - address of yes
    mul $t7, $t6, $t4
    add $a0, $a0, $t7      # $a0 = address of yes + difference * $t4
    
    li $v0, 4
    syscall # print string
    
    li $v0, 10
    syscall