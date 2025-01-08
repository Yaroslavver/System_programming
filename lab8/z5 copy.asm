format ELF64

public _start
extrn getcos
extrn printf

_start:
    mov rdi, 3
    call getcos
    mov rax, rax
    movq xmm0, rax
    call printf
    ;call print
    call exit


exit:
	mov rax, 0x3c
	mov rdi, 0
	syscall


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