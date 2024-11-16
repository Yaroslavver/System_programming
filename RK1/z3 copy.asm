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
    mov r9,[rsp+16]    ;загружаем адрес имени файла из стека

    mov rax, rdi
    call read
    call eclose

read:
    push rdi
    push rbp
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10

    mov rdi, rax        ;передали имя второго файла

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
        
        je .stopclose       ;выходим из цикла чтения

        mov byte [rsi+rax], 0   ;добавляем в буффер конец строки
        
        xor rax, rax
        .find:
            mov bl, byte [rsi]
            movzx rax, bl

            mov rax, rax
            call print

            cmp rax, 32 ; сравниваем символ из первого и второго файлов
            jne .loop_read ;если разные, то пропустить

            mov rbx, rsi
            call write     ;иначе записать символ в файл
        
        jmp .loop_read  ;продолжаем цикл чтения
    .stopclose:
        call close
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rbp
    pop rdi
    ret


write:
    push rdi
    push rbp
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10
    
    mov rdi, r9
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
    
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rbp
    pop rdi
    ret



place db ?
print:
push rdi
    push rbp
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10
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
 pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rbp
    pop rdi
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