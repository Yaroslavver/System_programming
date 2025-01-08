format elf64
public _start
include 'func.asm'

section '.bss' writable

buffer rb 100
msg_wait db "Сейчас ходит другой игрок", 0
msg_win db "Вы выиграли", 0
msg_loose db "Вы проиграли", 0
msg_score db "Текущий результат: ", 0
msg_last db "Ваша карта: ", 0
msg_options db "1 - взять новую карту. 0 - закончить ход.", 0
msg_over db "У вас больше 21 очка, а именно ", 0
msg_draw db "Ничья", 0
msg_4 db 'Error connect', 0xa, 0
msg_1 db 'Error bind', 0xa, 0
  
struc sockaddr_client
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x6d9     ; port
  .sin_addr dd 0           ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}

addrstr_client sockaddr_client 
addrlen_client = $ - addrstr_client
  
struc sockaddr_server 
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x3d9     ; port 55555
  .sin_addr dd 0           ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}

addrstr_server sockaddr_server 
addrlen_server = $ - addrstr_server

section '.text' executable

_start:

mov rdi, 2 ;AF_INET - IP v4 
mov rsi, 1
mov rdx, 0
mov rax, 41
syscall
mov r9, rax

mov rax, 49              ; SYS_BIND
mov rdi, r9              ; дескриптор сервера
mov rsi, addrstr_client  ; sockaddr_in struct
mov rdx, addrlen_client  ; length of sockaddr_in
syscall

cmp rax, 0
jl _bind_error
    
;;Подключаемся к серверу
mov rax, 42 ;sys_connect
mov rdi, r9 ;дескриптор
mov rsi, addrstr_server 
mov rdx, addrlen_server
syscall

cmp rax, 0
jl  _connect_error

;loop
_read:
mov rax, 0 ;номер системного вызова чтения
mov rdi, r9 ;загружаем файловый дескриптор
mov rsi, buffer ;указываем, куда помещать прочитанные данные
mov rdx, 100 ;устанавливаем количество считываемых данных
syscall ;выполняем системный вызов read
      
;;Если сервер ничего не прислал, продолжаем
cmp rax, 0
je _read
mov rsi, buffer
call str_number
cmp rax, 2
je waiting
cmp rax, 1
je printing
cmp rax, 3
je overflow
cmp rax, 7
je draw
cmp rax, 8
je win
cmp rax, 9
je loose
mov rsi, msg_wait
call print_str
call new_line
jmp _read

waiting:
mov rsi, msg_wait
call print_str
call new_line
jmp _read

printing:
mov rsi, msg_score
call print_str
_data_wait:
mov rax, 0
mov rdi, r9
mov rsi, buffer
mov rdx, 100
syscall
cmp rax, 0
je _data_wait
mov rsi, buffer
call print_str
call new_line
mov rsi, msg_last
call print_str
_data_wait2:
mov rax, 0
mov rdi, r9
mov rsi, buffer
mov rdx, 100
syscall
cmp rax, 0
je _data_wait2
mov rsi, buffer
call print_str
call new_line
mov rsi, msg_options
call print_str
call new_line
mov rsi, buffer

call input_keyboard
mov rax, 1
mov rdi, r9
mov rsi, buffer
mov rdx, 100
syscall

jmp _read

overflow:
mov rsi, msg_over
call print_str
_data_wait3:
mov rax, 0
mov rdi, r9
mov rsi, buffer
mov rdx, 100
syscall
cmp rax, 0
je _data_wait3
mov rsi, buffer
call print_str
call new_line

jmp _read

draw:
mov rsi, msg_draw
call print_str
call new_line
jmp fin

win:
mov rsi, msg_win
call print_str
call new_line
jmp fin

loose:
mov rsi, msg_loose
call print_str
call new_line
jmp fin

fin:
mov rdi, r9
mov rax, 3
syscall
    
call exit

_bind_error:
mov rsi, msg_1
call print_str
call exit
   
_connect_error:
mov rsi, msg_4
call print_str
call exit