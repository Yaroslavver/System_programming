format elf64
public _start
include 'func.asm'


_start:
  mov rax, [rsp + 16]
    
    mov rsi, rax
    call str_number

  xor r12, r12
  xor r13, r13
  xor r14, r14
  dec r13
  .go:
    inc r14
    inc r13
    cmp r13, 4
    jne @f
    xor r13, r13
    @@:
    


    cmp r13, 0
    je .splus
    cmp r13, 1
    je .splus
    cmp r13, 2
    je .sminus
    cmp r13, 3
    je .sminus

    .splus:
      add r12, r14
      cmp r14, rax
      je @f
      jmp .go
    .sminus:
      sub r12, r14
      cmp r14, rax
      je @f
      jmp .go
    

    
    @@:
      mov rax, r12
      call print
  
   call exit
   

place db ?
msg db "-", 0
  
print:
    cmp rax, 0
    jge @f
    push rax
    mov rax, 4
    mov rbx, 1
    mov rcx, msg
    add rcx, rdx
    mov rdx, 2
    int 0x80
    pop rax

    neg rax

    @@:
    mov rcx, 10
    xor rbx, rbx
    iter1:
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax, 0
      ;call print_str
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
