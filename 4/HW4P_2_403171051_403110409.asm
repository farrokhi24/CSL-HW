# 403171051, 403110409

.text

.globl main
main:
    li $v0, 5
    syscall # input int
    move $t0, $v0 # k in $t0
    
    li $v0, 8
    syscall # input string
    move $t1, $v0 # string in $t1
    
    li $v0, 10
    syscall
