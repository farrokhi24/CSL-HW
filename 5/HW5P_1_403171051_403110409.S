# 403171051, 403110409

.data
    scan_fmt:  .asciiz "%d"
    print_fmt: .asciiz "%d\n"
    n_val:     .word 0

.text
.globl main

recursive_pow2:
    addi  $sp, $sp, -12
    sw    $ra, 8($sp)
    sw    $a0, 4($sp)

    beq   $a0, $zero, return_1

    li    $t9, 31
    beq   $a0, $t9, return_2147483647

    li    $t9, 1
    beq   $a0, $t9, return_2

    addi  $a0, $a0, -1
    jal   recursive_pow2

    addu  $v0, $v0, $v0
    j     rec_end

return_1:
    li    $v0, 1
    j     rec_end

return_2:
    li    $v0, 2
    j     rec_end

return_2147483647:
    lui   $v0, 0x7FFF
    ori   $v0, $v0, 0xFFFF
    move  $a1, $v0
    la    $a0, print_fmt
    jal   printf

    jal exit

rec_end:
    lw    $ra, 8($sp)
    addi  $sp, $sp, 12
    jr    $ra


main:
    addi  $sp, $sp, -8
    sw    $ra, 4($sp)

    la    $a0, scan_fmt
    la    $a1, n_val
    jal   scanf

    lw    $a0, n_val
    jal   recursive_pow2

    addi  $v0, $v0, -1

    move  $a1, $v0
    la    $a0, print_fmt
    jal   printf

    li    $a0, 0
    jal   exit