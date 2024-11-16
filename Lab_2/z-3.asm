format ELF64
public _start

symboln db 0xA, 0
array db 300 dup ';'
symbolnone db ?

_start:
    mov rcx, 0  ; count
    mov rdx, 0  ; len

    .iter1:
        inc rdx
        push rdx
        .iter2:
            dec rdx
            mov al, [array+rcx]
            push rcx
            push rdx
            
            call print_symbol
            pop rdx
            pop rcx

            inc rcx

            cmp rdx, 0
            jne .iter2

        pop rdx

        push rdx
        push rcx
        call print_symbol_n
        pop rcx
        pop rdx

        cmp rcx, 300
        jne .iter1
    call exit

print_symbol:
    mov [symbolnone], al
    mov rax, 4
    mov rbx, 1
    mov rcx, symbolnone
    mov rdx, 1
    int 0x80
    ret

print_symbol_n:
    mov rax, 4
    mov rbx, 1
    mov rcx, symboln
    mov rdx, 1
    int 0x80
    ret

exit:
    mov rax, 1
    mov rbx, 0
    int 0x80