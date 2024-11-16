format ELF64
public _start

symboln db 0xA, 0
array db 12 dup ';'
symbolnone db ?

_start:
    mov rdx, 12  ; string m
    mov rcx, 25  ; line k

    .iter1:
        dec rcx
        push rcx
        mov rdx, 12
        .iter2:
            dec rdx
            mov al, [array+rdx]

            push rdx
            call print_symbol
            pop rdx
            
            cmp rdx, 0
            jne .iter2
        
        push rdx
        call print_symbol_n
        pop rdx
        
        pop rcx
        cmp rcx, 0
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