format elf64
public _start

include 'func.asm'


_start:
  mov rax, 14
  call is_prost
  call print
  call exit

;rax - input, output
is_prost:
	mov rsi, rax ; сохранить в rdx
	xor rbx, rbx
  inc rbx
	.iter_prost:
    inc rbx

    cmp rbx, rsi
    jge .prost
    
    xor rdx, rdx
		mov rax, rsi
		mov rcx, rbx
		div rcx

		cmp rdx, 0
		je .neprost
		jne .iter_prost

	.prost:
		mov rax, 1
		ret
	.neprost:
		mov rax, 0
		ret


place db ?
  
print:
push rax
push rbx
push rcx
push rdx
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
 pop rdx
 pop rcx
 pop rbx
 pop rax
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
