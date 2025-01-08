; fasm z.asm; ld z.o; ./a.out
; b.out

format ELF64
include 'func.asm'
public _start

section '.bss' writable
    arg1 db "file1", 0
    arg2 db "file2", 0
    arg3 db "output2", 0
    argv rq 5
    input rb 100

section '.text' executable
_start:
    .loop:
        mov rsi, input
        call input_keyboard

        mov rax, 57
        syscall
        cmp rax, 0
        jne .wait

        mov rax, 59
        mov rdi, input
        mov [argv], input
        mov [argv+8], arg1
        mov [argv+16], arg2
        mov [argv+24], arg3
        mov [argv+32], 0
        mov rsi, argv  
        syscall
        call exit

        .wait:
        mov rax, 61
        mov rdi, -1
        mov rdx, 0
        mov r10, 0
        syscall
        jmp .loop