.text
.global main

.section .rodata
    fmt_nq:         .asciz "%ld %ld"
    fmt_elem:       .asciz "%ld"
    fmt_cmd:        .asciz "%s"
    fmt_two_ints:   .asciz "%ld %ld"
    fmt_out_val:    .asciz "%ld\n"
    fmt_show_num:   .asciz "%ld"
    fmt_show_space: .asciz " "
    fmt_show_nl:    .asciz "\n"
    cmd_sum:        .asciz "sum"
    cmd_reverse:    .asciz "reverse"
    cmd_max:        .asciz "max"
    cmd_compress:   .asciz "compress"
    cmd_show:       .asciz "show"

.text
main:
    stp x29, x30, [sp, -80]!
    mov x29, sp
    stp x19, x20, [sp, 16]
    stp x21, x22, [sp, 32]

    ldr x0, =fmt_nq
    add x1, x29, 48
    add x2, x29, 56
    bl scanf

    ldr x19, [x29, 48]
    cbz x19, skip_malloc
    lsl x0, x19, #3
    bl malloc
    str x0, [x29, 64]
    mov x20, x0
    b input_elements_start

skip_malloc:
    str xzr, [x29, 64]
    mov x20, xzr

input_elements_start:
    mov x21, #0
input_elements_loop:
    cmp x21, x19
    bge command_processing_start
    ldr x0, =fmt_elem
    add x1, x20, x21, lsl #3
    bl scanf
    add x21, x21, #1
    b input_elements_loop

command_processing_start:
    ldr x22, [x29, 56]

execute_commands_loop:
    cbz x22, cleanup_and_exit
    sub x22, x22, #1
    ldr x0, =fmt_cmd
    add x1, x29, 16
    bl scanf
    add x1, x29, 16
    ldr x0, =cmd_sum
    bl strcmp
    cbz x0, handle_sum_cmd
    add x1, x29, 16
    ldr x0, =cmd_reverse
    bl strcmp
    cbz x0, handle_reverse_cmd
    add x1, x29, 16
    ldr x0, =cmd_max
    bl strcmp
    cbz x0, handle_max_cmd
    add x1, x29, 16
    ldr x0, =cmd_compress
    bl strcmp
    cbz x0, handle_compress_cmd
    add x1, x29, 16
    ldr x0, =cmd_show
    bl strcmp
    cbz x0, handle_show_cmd
    b execute_commands_loop

handle_sum_cmd:
    bl read_range_indices
    bl calculate_sum
    ldr x0, =fmt_out_val
    mov x1, x2
    bl printf
    b execute_commands_loop

handle_max_cmd:
    bl read_range_indices
    bl find_max_in_range
    ldr x0, =fmt_out_val
    mov x1, x2
    bl printf
    b execute_commands_loop

handle_reverse_cmd:
    bl read_range_indices
    bl reverse_array_segment
    b execute_commands_loop

handle_compress_cmd:
    bl read_range_indices
    bl execute_compress_operation
    str x0, [x29, 64]
    mov x20, x0
    str x1, [x29, 48]
    mov x19, x1
    b execute_commands_loop

handle_show_cmd:
    bl display_array_contents
    b execute_commands_loop

cleanup_and_exit:
    ldr x0, [x29, 64]
    cbz x0, final_ret
    bl free
final_ret:
    mov x0, #0
    ldp x21, x22, [sp, 32]
    ldp x19, x20, [sp, 16]
    ldp x29, x30, [sp], 80
    ret

read_range_indices:
    stp x29, x30, [sp, -32]!
    mov x29, sp
    ldr x0, =fmt_two_ints
    add x1, sp, 16
    add x2, sp, 24
    bl scanf
    ldr x0, [sp, 16]
    ldr x1, [sp, 24]
    ldp x29, x30, [sp], 32
    ret

calculate_sum:
    mov x2, #0
    mov x3, x0
sum_iterator:
    cmp x3, x1
    bgt sum_finished
    ldr x4, [x20, x3, lsl #3]
    add x2, x2, x4
    add x3, x3, #1
    b sum_iterator
sum_finished:
    ret

find_max_in_range:
    ldr x2, [x20, x0, lsl #3]
    add x3, x0, #1
max_iterator:
    cmp x3, x1
    bgt max_finished
    ldr x4, [x20, x3, lsl #3]
    cmp x4, x2
    csel x2, x4, x2, gt
    add x3, x3, #1
    b max_iterator
max_finished:
    ret

reverse_array_segment:
    cmp x0, x1
    bge reverse_finished
    ldr x2, [x20, x0, lsl #3]
    ldr x3, [x20, x1, lsl #3]
    str x3, [x20, x0, lsl #3]
    str x2, [x20, x1, lsl #3]
    add x0, x0, #1
    sub x1, x1, #1
    b reverse_array_segment
reverse_finished:
    ret

execute_compress_operation:
    stp x29, x30, [sp, -64]!
    mov x29, sp
    stp x24, x25, [sp, 16]
    stp x26, x27, [sp, 32]
    stp x28, x21, [sp, 48]
    mov x24, x0
    mov x25, x1
    bl calculate_sum
    sub x3, x25, x24
    add x3, x3, #1
    sdiv x26, x2, x3
    msub x4, x26, x3, x2
    cbz x4, skip_floor_correction
    eor x5, x2, x3
    tbnz x5, 63, floor_down
    b skip_floor_correction
floor_down:
    sub x26, x26, #1
skip_floor_correction:
    sub x27, x19, x3
    add x27, x27, #1
    lsl x0, x27, #3
    bl malloc
    mov x28, x0
    mov x3, #0
copy_prefix:
    cmp x3, x24
    bge copy_prefix_done
    ldr x4, [x20, x3, lsl #3]
    str x4, [x28, x3, lsl #3]
    add x3, x3, #1
    b copy_prefix
copy_prefix_done:
    str x26, [x28, x24, lsl #3]
    add x3, x25, #1
    add x4, x24, #1
copy_suffix:
    cmp x3, x19
    bge copy_suffix_done
    ldr x5, [x20, x3, lsl #3]
    str x5, [x28, x4, lsl #3]
    add x3, x3, #1
    add x4, x4, #1
    b copy_suffix
copy_suffix_done:
    mov x0, x20
    bl free
    mov x0, x28
    mov x1, x27
    ldp x28, x21, [sp, 48]
    ldp x26, x27, [sp, 32]
    ldp x24, x25, [sp, 16]
    ldp x29, x30, [sp], 64
    ret

display_array_contents:
    stp x29, x30, [sp, -32]!
    mov x29, sp
    stp x19, x21, [sp, 16]
    mov x21, #0
display_loop:
    cmp x21, x19
    bge display_done
    ldr x0, =fmt_show_num
    ldr x1, [x20, x21, lsl #3]
    bl printf
    add x21, x21, #1
    cmp x21, x19
    bge display_done
    ldr x0, =fmt_show_space
    bl printf
    b display_loop
display_done:
    ldr x0, =fmt_show_nl
    bl printf
    ldp x19, x21, [sp, 16]
    ldp x29, x30, [sp], 32
    ret