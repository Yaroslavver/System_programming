format ELF64

	public _start

	extrn initscr
	extrn start_color
	extrn init_pair
	extrn getmaxx
	extrn getmaxy
	extrn raw
	extrn noecho
	extrn keypad
	extrn stdscr
	extrn move
	extrn getch
	extrn clear
	extrn addch
	extrn refresh
	extrn endwin
	extrn exit
	extrn color_pair
	extrn insch
	extrn cbreak
	extrn timeout
	extrn mydelay
	extrn setrnd
	extrn get_random


	section '.bss' writable
	
	xmax dq 1
	ymax dq 1
	rand_x dq 1
	rand_y dq 1
	palette dq 1
	count dq 1

	section '.data' writable

	digit db '0123456789'
	place db ?
	minus db "-", 0

	section '.text' executable
	
_start:
	;; Инициализация
	call initscr

	;; Размеры экрана
	xor rdi, rdi
	mov rdi, [stdscr]
	call getmaxx
	mov [xmax], rax
	call getmaxy
	mov [ymax], rax

	call start_color

	;; Желтый цвет
	mov rdx, 0x3
	mov rsi,0x0
	mov rdi, 0x1
	call init_pair

	;; Белый цвет
	mov rdx, 0xf
	mov rsi,0xf
	mov rdi, 0x2
	call init_pair

	call refresh
	call noecho
	call cbreak
	call setrnd

	;; Начальная инициализация палитры
	call get_digit
	or rax, 0x100
	mov [palette], rax
	mov [count], 0
        
	
	xor rbp, rbp ; расстояние
	xor r12, r12 ; направление
	xor r13, r13 ; ось x
	xor r14, r14 ; ось y
	mov rbp, 1
	;; Главный цикл программы
	mov r12, 0

mloop:
	; start init	

	@@:
	cmp r12, 0
	je .right
	cmp r12, 1
	je .left
	jmp @f
	
	.right:
		inc r13
		cmp r13, rbp
		jg .plusdist
		jmp @f
	.left:
		dec r13
		neg r13
		cmp r13, rbp
		neg r13
		jl .plusdist2
		jmp @f

	.plusdist:
		inc rbp ; plus distance
		inc r12
		cmp r12, 2
		je .reset
		;jmp mloop
		jmp @f
		.reset:
			xor r12, r12
		;jmp mloop
		jmp @f
	.plusdist2:
		inc rbp ; plus distance
		inc r12
		cmp r12, 2
		je .reset2
		jmp mloop
		;jmp @f
		.reset2:
			xor r12, r12
		jmp mloop
		jmp @f

	@@:
	mov rax, [xmax]
	mov rcx, 2
	xor rdx, rdx
	div rcx
	; rax - центр экрана по x
	;add rax, r13

	push rdx
	push rcx
	push rax
		mov rax, rbp
		mov rcx, 2
		xor rdx, rdx
		div rcx
		mov rdx, rax
    pop rax
		add rax, r13
		sub rax, rdx
	pop rcx
	pop rdx

	mov [rand_x], rax



	
	mov rax, [ymax]
	mov rcx, 2
	xor rdx, rdx
	div rcx
	; rax - центр экрана по y
	;add rax, r14

	push rdx
	push rcx
	push rax
	mov rax, rbp
	mov rcx, 2
    xor rdx, rdx
    div rcx
	mov rdx, rax
    pop rax
	add rax, r14
	sub rax, rdx
	pop rcx
	pop rdx

	mov [rand_y], rax
	
	;; Перемещаем курсор в случайную позицию
	mov rdi, [rand_y]
	mov rsi, [rand_x]
	call move



	mov rax, [palette]
	and rax, 0x100
	
	cmp r12, 0
	je @f
	cmp r12, 2
	je @f
	call get_digit
	or rax, 0x100
	mov [palette],rax
	jmp yy
	@@:
	call get_digit
	or rax, 0x200
	mov [palette],rax
	yy:
	mov  rdi,[palette]
	call addch


	mov rdi, 0
	mov rsi, 100
	call move

	cmp r12, 0
	je .debug0

	cmp r12, 1
	je .debug1

	.debug0:
		push rax
		mov rax, r13
		jmp @f
	.debug1:
		push rax
		mov rax, r13
		jmp @f
	@@:
	;mov rax, rbp
	call print
	pop rax
	

	
	;; Задержка
	mov rdi,500000
	call mydelay

	;; Обновляем экран и количество выведенных знакомест в заданной палитре
	call refresh
	mov r8, [count]
	inc r8
	mov [count], r8

	;; Анализируем текущее значение r8=[count]
	call analiz
    
    ;;Задаем таймаут для getch
	mov rdi, 1
	call timeout
	call getch
    
    ;;Анализируем нажатую клавишу
	cmp rax, 'p'
	je next
	jmp mloop
next:	
	call endwin
	call exit

;;Анализируем количество выведенных знакомест в заданной палитре, меняем палитру, если количество больше 10000
analiz:
	cmp r8, 10000
	jl .p
	mov r8,[palette]
	and r8, 0x100 
	cmp r8, 0x100
	je .pp
	call get_digit
	or rax, 0x100
	mov [palette], rax
	xor r8, r8
	mov [count],r8
	ret
	.pp:
	call get_digit
	or rax, 0x200
	mov [palette], rax
	xor r8, r8
	mov [count], r8
	ret
	.p:
	 ret

;;Выбираем случайную цифру
get_digit:
	push rcx
	push rdx
	call get_random
	mov rcx, 10
	xor rdx, rdx
	div rcx
	xor rax,rax
	mov al, [digit + rdx]
	pop rdx
	pop rcx
	ret



print:
	cmp rax, 0
	jge @f
	neg rax
	mov rax, 4
    mov rbx, 1
    mov rcx, minus
    mov rdx, 2
    int 0x80

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