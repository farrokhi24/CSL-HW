.data
.text
.globl main
main:
    li $v0, 5
    syscall
    move $t0, $v0 #a 

    li $v0, 5
    syscall
    move $t1, $v0 #b

    add $t4, $t0, $t1 #a+b
    sub $t2, $t0, $t1 #a-b
    sra $t3, $t2, 31  #if a-b positive, 0. if negative, 1111 1111 1111 1111. 
    sub $t5, $t1, $t0 #b-a

    not $t9, $t3       #if a-b positive, 1111 1111 1111 1111. if negative, 0. 
    and $t6, $t2, $t9  #if a-b positive, a-b and if negative 0.
    and $t7, $t5, $t3  #if a-b positive, 0 and if negative, b-a.
    or  $t8, $t6, $t7  # |a-b|

    add $t9, $t4, $t8  # a+b + |a-b|
    srl $t9, $t9, 1    #(a+b + |a-b|)/2

    li $v0, 1
    move $a0, $t9
    syscall

    li $v0, 10
    syscall
