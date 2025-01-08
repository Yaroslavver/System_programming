format elf64

public _start

include 'func.asm'

section '.bss' writable
buffer rb 200
number rb 100
lesserBuf rb 100

f db "/dev/random", 0
rand dq ?
s dq ?
client1 dq ?
client2 dq ?
len_array dq 12 dup (0)
msg_1 db 'Error bind', 0xa, 0
msg_3 db 'New connection on port ', 0
msg_4 db 'Successfull listen', 0xa, 0

struc sockaddr
{
  .sin_family dw 2   ; AF_INET
  .sin_port dw 0x3d9 ; port 55555
  .sin_addr dd 0     ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}
addrstr sockaddr
addrlen = $ - addrstr
	
section '.text' executable
_start:	


mov rax, 2
mov rdi, f
mov rsi, 0o
syscall
mov [rand], rax
mov rdi, 2 ;AF_INET - IP v4 
mov rsi, 1 ;seq_packet
mov rdx, 0 ;default
mov rax, 41
syscall
mov [s], rax

;connecting
mov rax, 49; SYS_BIND
mov rdi, [s]; listening socket fd
mov rsi, addrstr; sockaddr_in struct
mov rdx, addrlen; length of sockaddr_in
syscall

cmp rax, 0
jl _bind_error

;listen
mov rax, 50 ;sys_listen
mov rdi, [s] ;дескриптор
mov rsi, 2  ; количество клиентов
syscall
cmp rax, 0
jl  _bind_error
;accept
mov rax, 43
mov rdi, [s]
mov rsi, 0
mov rdx, 0
syscall
mov [client1], rax
mov rax, 43
mov rdi, [s]
mov rsi, 0
mov rdx, 0
syscall
mov [client2], rax

;initial random numbers
call rand_num
add r8, rax
mov r10, rax
call rand_num
add r9, rax
mov r13, rax

mov rax, '2'
mov [lesserBuf], al
mov rax, 1
mov rdi, [client2]
mov rsi, lesserBuf
mov rdx, 100
syscall

loop1:d
    mov rax, '1'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall

    mov rsi, buffer
    mov rax, r8
    call number_str
    mov rax, 1
    mov rdi, [client1]
    mov rsi, buffer
    mov rdx, 100
    syscall

    mov rsi, buffer
    mov rax, r10
    call number_str
    mov rax, 1
    mov rdi, [client1]
    mov rsi, buffer
    mov rdx, 100
    syscall

_read1:
mov rax, 0 ;номер системного вызова чтения
mov rdi, [client1] ;загружаем файловый дескриптор
mov rsi, buffer ;указываем, куда помещать прочитанные данные
mov rdx, 100 ;устанавливаем количество считываемых данных
syscall ;выполняем системный вызов read

;;Если клиент ничего не прислал, продолжаем
cmp rax, 0
je _read1
mov rsi, buffer
call str_number
cmp rax, 0
je next
call rand_num
mov r10, rax
add r8, rax
cmp r8, 21
jl loop1
mov rax, '3'
mov [lesserBuf], al
mov rax, 1
mov rdi, [client1]
mov rsi, lesserBuf
mov rdx, 100
syscall

mov rsi, buffer
mov rax, r8
call number_str
mov rax, 1
mov rdi, [client1]
mov rsi, buffer
mov rdx, 100
syscall

next:
mov rax, '2'
mov [lesserBuf], al
mov rax, 1
mov rdi, [client1]
mov rsi, lesserBuf
mov rdx, 100
syscall

loop2:
    mov rax, '1'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    mov rsi, buffer
    mov rax, r9
    call number_str
    mov rax, 1
    mov rdi, [client2]
    mov rsi, buffer
    mov rdx, 100
    syscall
    mov rsi, buffer
    mov rax, r13
    call number_str
    mov rax, 1
    mov rdi, [client2]
    mov rsi, buffer
    mov rdx, 100
    syscall

_read2:
    mov rax, 0 ;номер системного вызова чтения
    mov rdi, [client2] ;загружаем файловый дескриптор
    mov rsi, buffer ;указываем, куда помещать прочитанные данные
    mov rdx, 100 ;устанавливаем количество считываемых данных
    syscall ;выполняем системный вызов read
        
    ;;Если клиент ничего не прислал, продолжаем
    cmp rax, 0
    je _read2
    mov rsi, buffer
    call str_number
    cmp rax, 0
    je res
    call rand_num
    mov r13, rax
    add r9, rax
    cmp r9, 21
    jl loop2
    mov rax, '3'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    mov rsi, buffer
    mov rax, r9
    call number_str
    mov rax, 1
    mov rdi, [client2]
    mov rsi, buffer
    mov rdx, 100
    syscall

;results
res:
    cmp r8, 21
    jnl notless1
    mov rax, 21
    sub rax, r8
    mov r8, rax

notless1:
    sub r8, 21

    cmp r9, 21
    jnl notless2
    mov rax, 21
    sub rax, r9
    mov r9, rax

notless2:
    sub r9, 21

    cmp r8, r9
    jl win1
    cmp r8, r9
    jg win2
    mov rax, '7'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    mov rax, '7'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    jmp fin

win1:
    mov rax, '8'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    mov rax, '9'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    jmp fin

win2:
    mov rax, '9'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    mov rax, '8'
    mov [lesserBuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lesserBuf
    mov rdx, 100
    syscall
    jmp fin

fin:
    ;closing
    mov rax, 3
    mov rdi, [rand]
    syscall
    mov rax, 3
    mov rdi, [s]
    syscall
    mov rax, 3
    mov rdi, [client1]
    syscall
    mov rax, 3
    mov rdi, [client2]
    syscall

    call exit

rand_num:
    rand_num_loop:
    mov rax, 0
    mov rdi, [rand]
    mov rsi, number
    mov rdx, 2
    syscall
    mov al, [number]
    mov rbx, 8
    xor rdx, rdx
    div rbx
    mov rax, rdx
    add rax, 4
    mov rbx, [len_array+rax]
    cmp rbx, 4
    jg rand_num_loop
    inc [len_array+rax]
    ret

_bind_error:
mov rsi, msg_1
call print_str
call exit