# karatsuba.S - Karatsuba multiplication for two 16-bit unsigned integers
# بدون استفاده از دستورات ضرب (mul/mult/multu/madd و غیره ممنوع)
# با libc لینک می‌شود

    .data
scan_fmt:   .asciiz "%u %u"
print_fmt:  .asciiz "%u\n"
a:          .word 0
b:          .word 0

    .text
    .globl main

# int main()
main:
    # ذخیره ra و fp
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $fp, 0($sp)
    move    $fp, $sp

    # خواندن دو عدد از ورودی
    la      $a0, scan_fmt
    la      $a1, a
    la      $a2, b
    jal     scanf

    # فراخوانی karatsuba_multiply(a, b, 16)
    lw      $a0, a
    lw      $a1, b
    li      $a2, 16                 # طول اعداد: 16 بیت
    jal     karatsuba_multiply

    # چاپ نتیجه
    move    $a0, $v0
    la      $a1, print_fmt
    jal     printf

    # خروج
    li      $v0, 0
    lw      $ra, 4($sp)
    lw      $fp, 0($sp)
    addiu   $sp, $sp, 8
    jr      $ra


# int karatsuba_multiply(unsigned int a, unsigned int b, int length)
# $a0 = a, $a1 = b, $a2 = length (in bits)
# بازگشت در $v0
karatsuba_multiply:
    # ذخیره ra و آرگومان‌ها
    addiu   $sp, $sp, -40
    sw      $ra, 36($sp)
    sw      $s0, 32($sp)    # a
    sw      $s1, 28($sp)    # b
    sw      $s2, 24($sp)    # length
    sw      $s3, 20($sp)    # m
    sw      $s4, 16($sp)    # a1
    sw      $s5, 12($sp)    # b1
    sw      $s6, 8($sp)     # z0
    sw      $s7, 4($sp)     # z2

    move    $s0, $a0        # s0 = a
    move    $s1, $a1        # s1 = b
    move    $s2, $a2        # s2 = length

    # اگر length <= 8، از ضرب ساده استفاده کن (base case)
    slti    $t0, $s2, 9
    bne     $t0, $zero, base_case

    # m = length / 2
    srl     $s3, $s2, 1     # m = length >> 1

    # a1 = a >> m
    move    $t0, $s0        # t0 = a
    srlv    $s4, $t0, $s3   # a1 = a >> m
    move    $t1, $s4        # t1 = a1

    # a0 = a & ((1<<m)-1)
    li      $t2, 1
    sllv    $t2, $t2, $s3
    addiu   $t2, $t2, -1    # mask = (1<<m)-1
    and     $t0, $t0, $t2   # a0 = a & mask

    # b1 = b >> m
    move    $t3, $s1        # t3 = b
    srlv    $s5, $t3, $s3   # b1 = b >> m
    move    $t4, $s5        # t4 = b1

    # b0 = b & mask
    and     $t3, $t3, $t2   # b0 = b & mask
    move    $t6, $t3        # t6 = b0

    # p = a0 + a1
    addu    $t8, $t0, $t1   # p = a0 + a1

    # q = b0 + b1
    addu    $t9, $t3, $t4   # q = b0 + b1

    # فراخوانی بازگشتی z2 = karatsuba(a1, b1, m)
    move    $a0, $t1        # a1
    move    $a1, $t4        # b1
    move    $a2, $s3        # m
    jal     karatsuba_multiply
    move    $s7, $v0        # s7 = z2

    # فراخوانی بازگشتی z0 = karatsuba(a0, b0, m)
    move    $a0, $t0        # a0
    move    $a1, $t6        # b0
    move    $a2, $s3        # m
    jal     karatsuba_multiply
    move    $s6, $v0        # s6 = z0

    # فراخوانی بازگشتی z1 = karatsuba(p, q, m)
    move    $a0, $t8        # p
    move    $a1, $t9        # q
    move    $a2, $s3        # m
    jal     karatsuba_multiply
    move    $t5, $v0        # t5 = z1 = (a0+a1)*(b0+b1)

    # z1 = z1 - z2 - z0
    subu    $t5, $t5, $s7   # z1 -= z2
    subu    $t5, $t5, $s6   # z1 -= z0

    # محاسبه نتیجه نهایی:
    # result = z2 << (2*m) + z1 << m + z0

    # z2 << (2*m)
    sllv    $v0, $s7, $s3   # z2 << m
    sllv    $v0, $v0, $s3   # z2 << (2*m)

    # z1 << m
    sllv    $t0, $t5, $s3

    # جمع همه
    addu    $v0, $v0, $t0   # += z1 << m
    addu    $v0, $v0, $s6   # += z0

    j       karatsuba_return

base_case:
    # base case: ضرب ساده با جمع متوالی (بدون mul!)
    li      $v0, 0          # result = 0
    move    $t0, $s1        # t0 = b (counter)
base_loop:
    beq     $t0, $zero, base_done
    addu    $v0, $v0, $s0   # result += a
    addiu   $t0, $t0, -1
    j       base_loop
base_done:

karatsuba_return:
    lw      $ra, 36($sp)
    lw      $s0, 32($sp)
    lw      $s1, 28($sp)
    lw      $s2, 24($sp)
    lw      $s3, 20($sp)
    lw      $s4, 16($sp)
    lw      $s5, 12($sp)
    lw      $s6, 8($sp)
    lw      $s7, 4($sp)
    addiu   $sp, $sp, 40
    jr      $ra