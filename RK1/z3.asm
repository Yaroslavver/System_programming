format elf64
public _start

include 'func.asm'

f  db "/dev/urandom",0
number rq 1
placerd rb 100

_start:
  call random
  call print
  call exit


random:
   mov rdi, f
   mov rax, 2
   mov rsi, 0o
   syscall 
   cmp rax, 0 
   jl l1
   mov r8, rax

   mov rax, 0 ;
   mov rdi, r8
   mov rsi, number
   mov rdx, 1
   syscall
   
   mov rax, [number]
   push rax
   ;mov rsi, placerd
   ;call number_str
   ;call print_str
   ;call new_line
   
   mov rax, 3
   mov rdi, r8
   syscall
   pop rax
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



l1:
  call exit