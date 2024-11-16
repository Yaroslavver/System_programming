format elf64
public _start

include 'func.asm'


buffer rb 2
buffer2 rb 2

_start:
    pop rcx     ;читаем количество параметров командной строки
    cmp rcx, 3  ;если один параметр(имя исполняемого файла)
    jne l1      ;завершаем работу
    
    mov rdi,[rsp+8]     ;загружаем адрес имени файла из стека
    mov rbp,[rsp+16]    ;загружаем адрес имени файла из стека

    mov rax, 2          ;системный вызов открытия файла
    mov rsi, 0o         ;Права только на чтение
    syscall
    cmp rax, 0          ;если вернулось отрицательное значение,
    jl l1              ;то произошла ошибка открытия файла, также завершаем работу
    
    mov r8, rax         ;сохраняем файловый дескриптор
    
    .loop_read:         ;начинаем цикл чтения из файла
        mov rax, 0      ;номер системного вызова чтения
        mov rdi, r8     ;загружаем файловый дескриптор
        mov rsi, buffer ;указываем, куда помещать прочитанные данные
        mov rdx, 1      ;устанавливаем количество считываемых данных
        syscall         ;выполняем системный вызов read
        cmp rax, 0      ;если прочитано 0 байт, то достигли конца файла 
        
        je eclose       ;выходим из цикла чтения

        mov byte [rsi+rax], 0   ;добавляем в буффер конец строки
        mov rbx, rsi
        call write
        
        xor rax, rax
        .find:
            mov bl, byte [rsi]
            movzx rax, bl

            cmp rax, 65 ;A
            je .loop_read
            cmp rax, 69 ;E
            je .loop_read
            cmp rax, 73 ;I
            je .loop_read
            cmp rax, 79 ;O
            je .loop_read
            cmp rax, 85 ;U
            je .loop_read

            cmp rax, 97 ;a
            je .loop_read
            cmp rax, 101 ;e
            je .loop_read
            cmp rax, 105 ;i
            je .loop_read
            cmp rax, 111 ;o
            je .loop_read
            cmp rax, 117 ;u
            je .loop_read

            mov rbx, rsi
            call write

            ;call print_str
        
        jmp .loop_read  ;продолжаем цикл чтения
    call eclose

write:
    push rdi
    push rbp
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    
    mov rdi, rbp
    mov rax, 2 
  
    mov rsi, 1078
    mov rdx, 777o
    syscall
    cmp rax, 0
    jl l1
    
    ;;Сохраняем файловый дескриптор
    mov r8, rax
    mov rsi, rbx


    mov rax, buffer2
    call len_str
    mov rdx, rax
    mov [buffer2+rdx], 0
    inc rdx
   
    mov rax, 1
    mov rdi, r8
    mov rsi, buffer
    syscall

    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rbp
    pop rdi
    ret


eclose:
  mov rdi, r8
  mov rax, 3
  syscall
  call exit

l1:
  call exit


close:
  mov rdi, r8
  mov rax, 3
  syscall
  ret