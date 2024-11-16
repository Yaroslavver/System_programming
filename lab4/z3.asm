format ELF64
public _start

input dq 255

_start:
    call read
    call str_number
    
    mov rbx, 0   ; число от 1 до n
    mov rsi, rax
    @@:
        inc rbx
        cmp rbx, rsi  ; если число больше n, то завершаем процесс
        jg @f

        ;____________________ПОЛУЧЕНИЕ ПОСЛЕДНИХ ЦИФР____________________
        mov rax, rbx
        mov rcx, 10
        xor rdx, rdx
        div rcx
        push rdx   ; последнее число

        mov rax, rax
        mov rcx, 10
        xor rdx, rdx
        div rcx
        push rdx ; предпоследнее число        

        ; ___________________ПРОВЕРКА НА НЕДЕЛИМОСТЬ_________________
        ; Проверка на деление на ноль
        pop rdx
        cmp rdx, 0
        je @b

        mov rax, rbx
        mov rcx, rdx
        call del
        cmp rdx, 0
        jne @b        ; если число не делится, то берём следующее число

        ; ___________________ВТОРАЯ ПРОВЕРКА НА НЕДЕЛИМОСТЬ_________________
        ; Проверка на деление на ноль
        pop rdx
        cmp rdx, 0
        je @b

        mov rax, rbx
        mov rcx, rdx
        call del
        cmp rdx, 0
        jne @b        ; если число не делится, то берём следующее число
        
        ;____________________КОНЦОВКА_____________________
        mov rax, rbx
        push rbx
        call print
        pop rbx
    
        cmp rsi, rbx
        jg @b
    @@:
        call exit


; input = rax, rcx
; output: rax, rdx
del:
    xor rdx, rdx
    div rcx
    ret


read:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 255
    syscall
    ret


place db ?
print:
    mov rcx, 10
    xor rbx, rbx
    iter1:
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax, 0
    jne iter1
    iter2:
      pop rax
      call print_symbl
      dec rbx
      cmp rbx, 0
    jne iter2
 mov rax, 0xA
 call print_symbl
 ret

print_symbl:
     push rbx
     push rdx
     push rcx
     push rax
     push rax
     mov rax, 4
     mov rbx, 1
     pop rdx
     mov [place], dl
     mov rcx, place
     mov rdx, 1
     int 0x80
     pop rax
     pop rcx
     pop rdx
     pop rbx
     ret

;Function converting the string to the number
;input rsi - place of memory of begin string
;output rax - the number from the string
str_number:
    push rcx
    push rbx
    xor rax,rax
    xor rcx,rcx
.loop:
    xor     rbx, rbx
    mov     bl, byte [rsi+rcx]
    cmp     bl, 48
    jl      .finished
    cmp     bl, 57
    jg      .finished
    sub     bl, 48
    add     rax, rbx
    mov     rbx, 10
    mul     rbx
    inc     rcx
    jmp     .loop
.finished:
    cmp     rcx, 0
    je      .restore
    mov     rbx, 10
    div     rbx
.restore:
    pop rbx
    pop rcx
    ret

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
