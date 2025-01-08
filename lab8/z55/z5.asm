;gcc -c formula.c -o formula.o; fasm z5.asm; ld z5.o formula.o  -lc -lm -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o a


format elf64
public _start

extrn scanf
extrn printf
extrn exact_value

include 'func.asm'

section '.data' writeable
    f db "n", 0x9, "|знач. x", 0x9, 0x9, "|точность", 0xa, "%d", 0x9,"|%f", 0x9,"|%f", 0xa, 0
    input_f db "%lf", 0
    prt db "%f", 0xa, 0
    prtn db "%d", 0xa, 0
    temp dq 1.0
    n dq 1.0
    xxx dq 1.0
    result dq 1
    result2 dq 1
    total dq 1
    ideal dq 1
    precision dq 0.00001
    difference dq 1

section '.bss' writable
    x rq 1

section '.text' executable

_start:
    ; scanf
    mov rdi, input_f
    mov rsi, x
    movq xmm0, rsi
    mov rax, 1
    call scanf

    mov rdi, input_f
    mov rsi, precision
    movq xmm0, rsi
    mov rax, 1
    call scanf

    movq xmm0, [x]
    call exact_value
    movq [ideal], xmm0

    ; printf
    mov rdi, prt
    movq xmm0, [ideal]
    mov rax, 1
    call printf ; вывод из си формулы

    movq xmm0, [x]
    movq [total], xmm0

    xor rdx, rdx
    mov rdx, 1 ;0
   
    loopp:
        mov [n], rdx
        push rdx
        mov rax, 2
        mov rbx, [n]
        mul rbx
        add rax, 1
        mov [temp], rax ; 2n+1
        pop rdx

        movq xmm0, [x]
        movq [xxx], xmm0

        ffree st0
        ffree st1
        fld [xxx]
        fld [temp]
        
        fmul st0, st1
        fcos
        fstp [result]

        ffree st0
        ffree st1
        fld [temp]
        fld [temp]

        fmul st0, st1
        fstp [result2]

        ffree st0
        ffree st1
        fld [result2]
        fld [result]
        fdiv st0, st1
        fstp [result]

        ffree st0
        ffree st1
        fld [total]
        fld [result]
        fadd st0, st1
        fstp [total]

        ffree st0
        ffree st1
        fld [total]
        fld [ideal]
        fsub st0, st1
        fstp [difference]

        ffree st0
        fld [difference]
        fabs
        fstp [difference]

        inc rdx

        ffree st0
        ffree st1
        fld [precision]
        fld [difference]
        fcomi st0, st1
    ja loopp

    mov [n], rdx

    movq xmm0, [total]
    mov rsi, [n]
    movq xmm1, [precision]
    mov rdi, f
    call printf


    mov rax, 60
    mov rdi, 0
    syscall