format elf64

public create_array
public free_memory
public edit
	
array_begin rq 1
count rq 1
size_elem = 8

create_array:
	mov [count], rdi
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
	;;mov [array_begin + size_elem], 5
	xor rax, rax ;; counter
	.loop:
		mov [array_begin + rax*size_elem], 5
		jne .loop
	ret


free_memory:
	xor rdi,[array_begin]
	mov rax, 12
	syscall
	ret