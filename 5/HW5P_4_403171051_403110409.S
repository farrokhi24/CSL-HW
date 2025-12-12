    .data
buffer:         .space 128
outbuf:         .space 64
minus_2_31:     .asciiz "-2147483648"
newline:        .asciiz "\n"

    .text
    .globl __start

__start:
    li      $v0, 4003
    li      $a0, 0
    la      $a1, buffer
    li      $a2, 128
    syscall

    la      $a0, buffer
    jal     parse_signed
    move    $s0, $v0
    move    $a0, $v1

    jal     parse_signed
    move    $s1, $v0

    move    $a0, $s0
    move    $a1, $s1
    jal     power_rec

    move    $a0, $v0
    jal     print_signed

    li      $v0, 4001
    li      $a0, 0
    syscall

power_rec:
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)
    sw      $a0, 8($sp)
    sw      $a1, 4($sp)

    beq     $a1, $zero, pr_ret1
    li      $t0, 1
    beq     $a1, $t0, pr_retbase

    srl     $a1, $a1, 1
    jal     power_rec
    move    $t0, $v0

    move    $a0, $t0
    move    $a1, $t0
    mult    $a0, $a1
    mflo    $t0

    lw      $t1, 4($sp)
    andi    $t1, $t1, 1
    beq     $t1, $zero, pr_even

    lw      $t2, 8($sp)
    move    $a0, $t0
    move    $a1, $t2
    mult    $a0, $a1
    mflo    $t0

pr_even:
    move    $v0, $t0
    j       pr_done

pr_ret1:
    li      $v0, 1
    j       pr_done

pr_retbase:
    move    $v0, $a0

pr_done:
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16
    jr      $ra

parse_signed:
    move    $t9, $a0
    li      $v0, 0
    li      $t8, 0

ps_skip:
    lb      $t0, 0($t9)
    beq     $t0, 0, ps_done_skip
    li      $t1, ' '
    beq     $t0, $t1, ps_nextch
    li      $t1, '\t'
    beq     $t0, $t1, ps_nextch
    li      $t1, '\n'
    beq     $t0, $t1, ps_nextch
    j       ps_check_sign

ps_nextch:
    addi    $t9, $t9, 1
    j       ps_skip

ps_done_skip:
    move    $v1, $t9
    jr      $ra

ps_check_sign:
    lb      $t0, 0($t9)
    li      $t1, '-'
    beq     $t0, $t1, ps_negative
    li      $t1, '+'
    beq     $t0, $t1, ps_plus
    j       ps_read

ps_negative:
    li      $t8, 1
    addi    $t9, $t9, 1
    j       ps_read

ps_plus:
    addi    $t9, $t9, 1
    j       ps_read

ps_read:
    lb      $t0, 0($t9)
    beq     $t0, 0, ps_done
    li      $t1, '0'
    blt     $t0, $t1, ps_done
    li      $t1, '9'
    bgt     $t0, $t1, ps_done

    li      $t2, 10
    multu   $v0, $t2
    mflo    $v0
    addi    $t3, $t0, -48
    addu    $v0, $v0, $t3

    addi    $t9, $t9, 1
    j       ps_read

ps_done:
    beq     $t8, $zero, ps_pos
    negu    $v0, $v0

ps_pos:
    move    $v1, $t9
    jr      $ra

print_signed:
    li      $t0, 0x80000000
    beq     $a0, $t0, pspec

    la      $t9, outbuf
    addi    $t9, $t9, 64
    sb      $zero, -1($t9)

    move    $t0, $a0
    li      $t8, 0
    bltz    $t0, pn
    j       pcvt

pn:
    li      $t8, 1
    negu    $t0, $t0

pcvt:
    beq     $t0, $zero, pzero

ploop:
    li      $t7, 10
    divu    $t0, $t7
    mfhi    $t1
    mflo    $t0
    addi    $t1, $t1, '0'
    addi    $t9, $t9, -1
    sb      $t1, 0($t9)
    bne     $t0, $zero, ploop
    j       pdone

pzero:
    addi    $t9, $t9, -1
    li      $t1, '0'
    sb      $t1, 0($t9)

pdone:
    beq     $t8, $zero, pnos
    addi    $t9, $t9, -1
    li      $t1, '-'
    sb      $t1, 0($t9)

pnos:
    li      $v0, 4004
    li      $a0, 1
    move    $a1, $t9
    la      $t7, outbuf
    addi    $t7, $t7, 64
    subu    $a2, $t7, $t9
    syscall

    li      $v0, 4004
    li      $a0, 1
    la      $a1, newline
    li      $a2, 1
    syscall
    jr      $ra

pspec:
    li      $v0, 4004
    li      $a0, 1
    la      $a1, minus_2_31
    li      $a2, 12
    syscall

    li      $v0, 4004
    li      $a0, 1
    la      $a1, newline
    li      $a2, 1
    syscall
    jr      $ra