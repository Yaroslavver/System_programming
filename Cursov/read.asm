format ELF64
public _start
include 'func.asm'

section '.bss' writable
    filename db 'vopros.txt',0
    filemode db 'r',0
    
    filehandle dq ?
    argv rq 5
    
    question_buffer rb 256
    option1_buffer rb 256
    option2_buffer rb 256
    option3_buffer rb 256
    correct_answer_buffer rb 8

    buffer rb 2

_start:
    mov rax, 2          ;системный вызов открытия файла
    mov rsi, 0o         ;Права только на чтение
    mov [rdi], filename;сюда передать имя файла для чтания
    syscall
    cmp rax, 0          ;если вернулось отрицательное значение,
    jl close              ;то произошла ошибка открытия файла, также завершаем работу
    
    mov r8, rax         ;сохраняем файловый дескриптор
    
    .loop_read:         ;начинаем цикл чтения из файла
        mov rax, 0      ;номер системного вызова чтения
        mov rdi, r8     ;загружаем файловый дескриптор
        mov rsi, buffer ;указываем, куда помещать прочитанные данные
        mov rdx, 1      ;устанавливаем количество считываемых данных
        syscall         ;выполняем системный вызов read
        cmp rax, 0      ;если прочитано 0 байт, то достигли конца файла 
        
        je close       ;выходим из цикла чтения

        mov byte [rsi+rax], 0   ;добавляем в буффер конец строки
        mov rbx, rsi

        mov rsi, rbp
        call print_str
        
        xor rax, rax
        .find:
            mov bl, byte [rsi]
            movzx rax, bl

            cmp rax, 65 ;A
            je .loop_read
            cmp rax, 69 ;E
            je .loop_read

close:
  mov rdi, r8
  mov rax, 3
  syscall
  call exit