format ELF64
public _start

_start:
    mov rax, [rsp + 16]
    mov rbx, [rsp + 24]
    
    mov rsi, rax
    call str_number
    mov rbp, rax

    mov rsi, rbx
    call str_number
    mov rdi, rax

    ; n = rbp; k = rdi;

    xor rbx, rbx ; - сумма
    xor rcx, rcx
    .iter:
        cmp rbp, rcx
        jb .iter2
        inc rcx
        
        mov rax, rcx
        push rcx
        push rbx
        call sum
        pop rbx
        pop rcx
        
        cmp rsi, rdi
        jne .iter

        add rbx, rcx

        cmp rcx, rbp
        jb .iter


    .iter2:
        mov rax, rbx
        call print
    call exit


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


sum:
    xor rsi, rsi
    mov rcx, 10
    xor rbx, rbx
    iter0:
      xor rdx, rdx
      div rcx
      add rsi, rdx
      ;push rdx
      inc rbx
      cmp rax, 0
    jne iter0
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

exit:
    mov rax,1
    mov rbx,0
    int 0x80