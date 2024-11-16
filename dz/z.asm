format elf64

public create_array
public free_memory
public edit
public count_prost
public count_chet
public get_nechet


array_begin rq 1
count rq 1
size_elem = 8

create_array:
	mov [count], rdi
	mov r12, rdi
	;; Получаем начальное значение адреса кучи
	xor rdi, rdi
	mov rax, 12
	syscall
	mov [array_begin], rax
	mov rdi, [array_begin]
	add rdi, [count]
	mov rax, 12
	syscall
	mov rax, array_begin
	ret

edit:
	xor rbx, rbx
	.loop:

		mov rcx, array_begin
		
		mov rax, rbx
		mov rdx, size_elem
		mul rdx
		
		add rcx, rax
		push rbx
		push rcx
		call random
		pop rcx
		pop rbx
		mov qword [rcx], rax

		inc rbx
		
		mov rax, r12
		
		cmp rbx, rax
		jne .loop
	ret


f  db "/dev/urandom",0
number rq 1
; rax - output
random:
   mov rdi, f
   mov rax, 2
   mov rsi, 0o
   syscall
   cmp rax, 0
   jl exit
   mov r8, rax

   mov rax, 0
   mov rdi, r8
   mov rsi, number
   mov rdx, 1
   syscall
   
   mov rax, [number]
   push rax

   mov rax, 3
   mov rdi, r8
   syscall

   pop rax
   ret



count_prost:
	xor rbx, rbx
	xor rsi, rsi
	.loop_prost:
		mov rcx, array_begin
		
		mov rax, rbx
		mov rdx, size_elem
		mul rdx
		
		add rcx, rax
		
		mov rax, qword [rcx]
		push rsi
		push rbx
		call is_prost
		pop rbx
		pop rsi
		;mov rax, rax
		add rsi, rax
		

		inc rbx
		mov rax, r12
		
		cmp rbx, rax
		jne .loop_prost
	mov rax, rsi
	ret



count_chet:
	xor rbx, rbx
	xor rsi, rsi
	mov rbx, -1
	.loop_chet:
		inc rbx
		cmp rbx, r12
		je .skip_chet

		mov rcx, array_begin
		mov rax, rbx
		mov rdx, size_elem
		mul rdx
		add rcx, rax
		mov rax, qword [rcx]

		push rbx
		push rsi
		push rcx
		push rax
			mov rcx, 2
			mov rax, rax
			xor rdx, rdx
			div rcx
		pop rax
		pop rcx
		pop rsi
		pop rbx
			cmp rdx, 0			
			jne .loop_chet

		;mov rax, rax
		inc rsi
		cmp rbx, r12
		jne .loop_chet
	.skip_chet:
		mov rax, rsi
		ret


get_nechet:
	xor rdi, rdi
	mov rax, 12
	syscall
	ret
	xor rbx, rbx
	xor rsi, rsi
	mov rbx, -1
	.loop_chet:
		inc rbx
		cmp rbx, r12
		je .skip_chet

		mov rcx, array_begin
		mov rax, rbx
		mov rdx, size_elem
		mul rdx
		add rcx, rax
		mov rax, qword [rcx]

		push rbx
		push rsi
		push rcx
		push rax
			mov rcx, 2
			mov rax, rax
			xor rdx, rdx
			div rcx
		pop rax
		pop rcx
		pop rsi
		pop rbx
			cmp rdx, 1		
			jne .loop_chet

		;mov rax, rax
		inc rsi

		cmp rbx, r12
		jne .loop_chet
	.skip_chet:
		mov rax, rsi
		ret



;rax - input, output
is_prost:
	mov rsi, rax
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

free_memory:
	xor rdi,[array_begin]
	mov rax, 12
	syscall
	ret


exit:
    mov rax, 60
    xor rdi, rdi
    syscall
