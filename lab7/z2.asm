;fasm z2.asm; ld z2.o; ./a.out
format ELF64
include 'func.asm'

public _start

THREAD_FLAGS = 2147585792
ARRLEN = 685

section '.bss' writable
    array rb ARRLEN
    digits rq 10
    buffer rb 10
    f db "/dev/random", 0
    stack1 rq 4096
    msg1 db "Пятое число после минимального:", 0xA, 0
    msg2 db "Кол-во чисел, сумма цифр которых кратна 3:", 0xA, 0
    msg3 db "Медиана:", 0xA, 0
    msg4 db "0.75 квантиль:", 0xA, 0
    space db " ", 0

section '.text' executable
_start:
    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    mov r8, rax

    mov rax, 0
    mov rdi, r8
    mov rsi, array
    mov rdx, ARRLEN
    syscall

    ; Фильтрация данных
    .sort_loop:
        call sort
        cmp rax, 0
        jne .sort_loop

    mov rcx, ARRLEN
    .print:
        dec rcx
        xor rax, rax
        mov al, [array + rcx]
        mov rsi, buffer
        call number_str
        call print_str
        mov rsi, space
        call print_str
        inc rcx
    loop .print

    call new_line

    ; для пятого числа после минимального
    mov rax, 57
    syscall

    cmp rax, 0
    je .5min

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall


    ; сумма цифр которых кратна 3
    mov rax, 57
    syscall

    cmp rax, 0
    je .div3

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    ;  медианы
    mov rax, 57
    syscall

    cmp rax, 0
    je .mediana

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    ; квантиль
    mov rax, 57
    syscall

    cmp rax, 0
    je .quantil

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    call exit

.5min:
    mov rsi, msg1
    call print_str

    xor rax, rax
    mov al, [array + 5]
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.mediana:
    mov rsi, msg3
    call print_str

    xor rax, rax
    mov al, [array + 343]
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.quantil:
    mov rsi, msg4
    call print_str

    xor rdx, rdx
    xor rax, rax

    mov rax, ARRLEN
    mov r8, 4
    div r8
    mov r8, rax

    mov rax, ARRLEN
    sub rax, r8

    mov al, [array + rax]
    movzx r8, al

    xor rax, rax
    mov rax, r8
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.div3:
    mov rsi, msg2
    call print_str

    xor r8, r8
    xor rax, rax
    xor r9, r9

    .iter:
        xor rbx, rbx
        xor rax, rax
        xor rdx, rdx
        mov al, [array + r9]
        mov rbx, 3
        div rbx

        inc r9

        cmp rdx, 0
        jne .iter

        inc r8
        cmp r9, ARRLEN
        jl .iter

    xor rax, rax
    mov rax, r8
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

sort:
    xor rax, rax
    mov rsi, array
    mov rcx, ARRLEN
    dec rcx
    .checkfilt:
        mov dl, [rsi]
        mov dh, [rsi+1]
        cmp dl, dh
        jbe .ok

        mov [rsi], dh
        mov [rsi+1], dl
        inc rax

        .ok:
        inc rsi
    loop .checkfilt
    ret