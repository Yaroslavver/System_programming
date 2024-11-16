format ELF64
public _start

input dq 255

_start:
    call read
    call str_number
    
    ;call print
    mov rbx, 0  ; число от 1 до n
    mov rcx, 0  ; кол-во хороших чисел
    mov rsi, rax
    ;add rsi, 1
    @@:
        inc rbx
        cmp rbx, rsi  ; если число больше n, то завершаем процесс
        jg @f

        ; ___________________ПРОВЕРКА НА НЕДЕЛИМОСТЬ НА 3________________
        push rcx
        mov rax, rbx
        mov rcx, 3

        call del
        pop rcx
        
        cmp rdx, 0
        je @b        ; если число делится, то берём следующее число


        ; ___________________ПРОВЕРКА НА НЕДЕЛИМОСТЬ НА 7________________
        push rcx
        mov rax, rbx
        mov rcx, 7

        call del
        pop rcx
        ;mov rax, rdx
        
        cmp rdx, 0
        je @b        ; если число делится, то берём следующее число
        
        ; ___________________ПРОВЕРКА НА ДЕЛИМОСТЬ НА 5________________
        push rcx
        mov rax, rbx
        mov rcx, 5

        call del
        pop rcx
        
        cmp rdx, 0
        jne @b        ; если число не делится, то берём следующее число

        ;mov rax, rbx
        ;push rbx
        ;push rcx
        ;call print    ; пишем число
        ;pop rcx
        ;pop rbx
        
        ;____________________КОНЦОВКА_____________________

        add rcx, 1
    
        cmp rbx, rsi
        jne @b

    @@:
        mov rax, rcx
        push rbx
        call print    ; пишем количество
        pop rbx
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
    ;mov rax, input
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
    jg      .finished ;если вышел за рамки 48-57 (0-9), то завершаем процесс
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
