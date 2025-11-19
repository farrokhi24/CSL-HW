.data
.text
.globl main

main:
    li   $v0, 5
    syscall
    move $t0, $v0

    li   $v0, 5
    syscall
    move $t1, $v0

    li   $v0, 5
    syscall
    move $t2, $v0

    mul  $t3, $t1, $t1
    mul  $t4, $t0, $t2
    sll  $t4, $t4, 2
    sub  $t4, $t3, $t4

    sra  $t5, $t4, 31

    subu $t8, $zero, $t4
    or   $t9, $t4, $t8
    sra  $t9, $t9, 31
    not  $t6, $t9

    li   $t7, 2
    add  $t7, $t7, $t5
    add  $t7, $t7, $t5
    add  $t7, $t7, $t6

    li   $v0, 1
    move $a0, $t7
    syscall

    li   $v0, 10
    syscall
