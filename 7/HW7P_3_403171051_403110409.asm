BITS 64
DEFAULT REL

section .text
global blend_sse
global blend_avx

blend_sse:
    test rcx, rcx
    jz .done_sse

.loop_sse:
    movdqa xmm0, [rdi]
    movdqa xmm1, [rsi]

    movdqa xmm2, xmm0
    paddsw xmm2, xmm1

    movdqa xmm3, xmm0
    psubsw xmm3, xmm1

    movdqa xmm4, xmm0
    pcmpgtw xmm4, xmm1

    pand xmm3, xmm4
    pandn xmm4, xmm2
    por xmm3, xmm4

    movdqa [rdx], xmm3

    add rdi, 16
    add rsi, 16
    add rdx, 16
    sub rcx, 8
    jnz .loop_sse

.done_sse:
    ret


blend_avx:
    test rcx, rcx
    jz .done_avx

.loop_avx:
    vmovdqa ymm0, [rdi]
    vmovdqa ymm1, [rsi]

    vpaddsw ymm2, ymm0, ymm1
    vpsubsw ymm3, ymm0, ymm1

    vpcmpgtw ymm4, ymm0, ymm1

    vpand ymm3, ymm3, ymm4
    vpandn ymm4, ymm4, ymm2
    vpor ymm3, ymm3, ymm4

    vmovdqa [rdx], ymm3

    add rdi, 32
    add rsi, 32
    add rdx, 32
    sub rcx, 16
    jnz .loop_avx

.done_avx:
    vzeroupper
    ret
