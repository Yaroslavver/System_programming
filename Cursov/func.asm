;Function exit
exit:
	mov rax, 0x3c
	mov rdi, 0
	syscall

;Function printing of string
;input rsi - place of memory of begin string
print_str:
    push rax
    push rdi
    push rdx
    push rcx
    mov rax, rsi
    call len_str
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

;The function makes new line
new_line:
   push rax
   push rdi
   push rsi
   push rdx
   push rcx
   mov rax, 0xA
   push rax
   mov rdi, 1
   mov rsi, rsp
   mov rdx, 1
   mov rax, 1
   syscall
   pop rax
   pop rcx
   pop rdx
   pop rsi
   pop rdi
   pop rax
   ret


;The function finds the length of a string
;input rax - place of memory of begin string
;output rax - length of the string
len_str:
  push rdx
  mov rdx, rax
  .iter:
      cmp byte [rax], 0
      je .next
      inc rax
      jmp .iter
  .next:
     sub rax, rdx
     pop rdx
     ret


;Function converting the string to the number
;input rsi - place of memory of begin string
;output rax - the number from the string
str_number:
    push rcx
    push rbx

    xor rax,rax
    xor rcx,rcx
.loop:
    xor     rbx, rbx
    mov     bl, byte [rsi+rcx]
    cmp     bl, 48
    jl      .finished
    cmp     bl, 57
    jg      .finished

    sub     bl, 48
    add     rax, rbx
    mov     rbx, 10
    mul     rbx
    inc     rcx
    jmp     .loop

.finished:
    cmp     rcx, 0
    je      .restore
    mov     rbx, 10
    div     rbx

.restore:
    pop rbx
    pop rcx
    ret

;The function converts the nubmer to string
;input rax - number
;rsi -address of begin of string
number_str:
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rbx, 10
  .loop_1:
    xor rdx, rdx
    div rbx
    add rdx, 48
    push rdx
    inc rcx
    cmp rax, 0
    jne .loop_1
  xor rdx, rdx
  .loop_2:
    pop rax
    mov byte [rsi+rdx], al
    inc rdx
    dec rcx
    cmp rcx, 0
  jne .loop_2
  mov byte [rsi+rdx], 0   
  pop rdx
  pop rcx
  pop rbx
  ret


;The function realizates user input from the keyboard
;input: rsi - place of memory saved input string 
input_keyboard:
  push rax
  push rdi
  push rdx

  mov rax, 0
  mov rdi, 0
  mov rdx,  2048
  syscall

  xor rcx, rcx
  .loop:
     mov al, [rsi+rcx]
     inc rcx
     cmp rax, 0x0A
     jne .loop
  dec rcx
  mov byte [rsi+rcx], 0
  
  pop rdx
  pop rdi
  pop rax
  ret



; Function to open a file
; Input: rsi - pointer to filename
;        rdx - flags (O_RDONLY, etc)
; Output: rax - file descriptor or error code
open_file:
    mov rax, 2      ; sys_open
    mov rdi, rsi    ; filename
    mov rsi, rdx    ; flags
    mov rdx, 0644o  ; mode (if creating)
    syscall
    ret

; Function to close a file
; Input: rdi - file descriptor
close_file:
    mov rax, 3      ; sys_close
    syscall
    ret

; Function to read a line from file
; Input: rdi - file descriptor
;        rsi - buffer to store line
;        rdx - buffer size
; Output: rax - bytes read (0 if EOF), buffer filled with line
read_line:
    push rbx
    push r12
    push r13
    
    mov r12, rdi    ; file descriptor
    mov r13, rsi    ; destination buffer
    xor rbx, rbx    ; bytes read counter
    
    .read_loop:
        ; Check if we have data in buffer
        mov rax, [current_pos]
        cmp rax, [bytes_read]
        jge .refill_buffer
        
        ; Get next character from buffer
        mov rsi, read_buffer
        add rsi, [current_pos]
        mov al, [rsi]
        inc qword [current_pos]
        
        ; Store character in output buffer
        mov [r13], al
        inc r13
        inc rbx
        
        ; Check for newline or buffer full
        cmp al, 0xA  ; newline
        je .line_complete
        cmp rbx, rdx
        jge .line_complete
        
        jmp .read_loop
    
    .refill_buffer:
        ; Read more data from file
        mov rax, 0      ; sys_read
        mov rdi, r12    ; file descriptor
        mov rsi, read_buffer
        mov rdx, 2048   ; buffer size
        syscall
        
        cmp rax, 0
        jle .eof_reached
        
        mov [bytes_read], rax
        mov qword [current_pos], 0
        jmp .read_loop
    
    .line_complete:
        mov byte [r13], 0  ; null-terminate
        mov rax, rbx
        jmp .done
    
    .eof_reached:
        mov rax, rbx
        cmp rax, 0
        je .done
        mov byte [r13], 0  ; null-terminate last line
    
    .done:
        pop r13
        pop r12
        pop rbx
        ret




; Function to create/truncate and open file for writing
; Input: rsi - filename, rdx - flags (O_WRONLY|O_CREAT|O_TRUNC)
; Output: rax - file descriptor
create_file:
    mov rax, 2        ; sys_open
    mov rdi, rsi      ; filename
    mov rsi, rdx      ; flags
    mov rdx, 0644o    ; mode
    syscall
    ret

; Function to write to file
; Input: rdi - file descriptor, rsi - buffer, rdx - length
write_file:
    mov rax, 1        ; sys_write
    syscall
    ret



; Функция сравнения строк (игнорирует завершающие пробелы и переводы строк)
; Вход: rsi - строка пользователя, rdi - правильный ответ
; Выход: rax - 1 если равны, 0 если не равны
compare_strings:
    push rsi
    push rdi
    push rbx
    push rcx
    
    ; Пропускаем ведущие пробелы в ответе пользователя
    .skip_leading_user:
        mov bl, [rsi]
        cmp bl, ' '
        jne .skip_leading_correct
        inc rsi
        jmp .skip_leading_user

    .skip_leading_correct:
        ; Пропускаем ведущие пробелы в правильном ответе
        mov cl, [rdi]
        cmp cl, ' '
        jne .compare_loop
        inc rdi
        jmp .skip_leading_correct

    .compare_loop:
        mov bl, [rsi]
        mov cl, [rdi]
        
        ; Пропускаем пробелы и переводы строк в ответе пользователя
        cmp bl, ' '
        je .skip_user_char
        cmp bl, 0xA
        je .skip_user_char
        
        ; Пропускаем пробелы и переводы строк в правильном ответе
        cmp cl, ' '
        je .skip_correct_char
        cmp cl, 0xA
        je .skip_correct_char
        
        ; Сравниваем символы
        cmp bl, cl
        jne .not_equal
        
        ; Проверяем конец строки
        test bl, bl
        jz .equal
        
        inc rsi
        inc rdi
        jmp .compare_loop

    .skip_user_char:
        inc rsi
        jmp .compare_loop

    .skip_correct_char:
        inc rdi
        jmp .compare_loop

    .equal:
        mov rax, 1
        jmp .compare_done
        
    .not_equal:
        xor rax, rax
        
    .compare_done:
        pop rcx
        pop rbx
        pop rdi
        pop rsi
        ret


; Функция удаления завершающего перевода строки
; Вход: rdi - строка
trim_newline:
    push rax
    push rdi
        
    .find_end:
        mov al, [rdi]
        test al, al
        jz .check_prev
        inc rdi
        jmp .find_end
        
    .check_prev:
        dec rdi
        cmp byte [rdi], 0xA
        jne .done
        mov byte [rdi], 0
        
    .done:
        pop rdi
        pop rax
        ret

  ; Функция копирования строки
  ; Вход: rdi - куда копировать, rsi - откуда копировать
  copy_string:
      push rax
      push rdi
      push rsi
      
  .copy_loop:
      mov al, [rsi]
      mov [rdi], al
      inc rsi
      inc rdi
      test al, al
      jnz .copy_loop
      
      pop rsi
      pop rdi
      pop rax
      ret

input_keyboard_answer:
    push rax
    push rdi
    push rdx

    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rdx, 2048        ; max length
    syscall

    ; Находим и удаляем символ новой строки
    mov rdi, rsi
    add rdi, rax
    dec rdi
    cmp byte [rdi], 0xA
    jne .done_input
    mov byte [rdi], 0
    
.done_input:
    pop rdx
    pop rdi
    pop rax
    ret


  ; Функция вычисления оценки в процентах
  ; Вход: correct_answers, wrong_answers
  ; Выход: rax - процент правильных ответов
  calculate_grade:
      push rbx
      push rdx
      
      mov rax, [correct_answers]
      add rax, [wrong_answers]  ; Всего вопросов
      mov rbx, rax
      mov rax, [correct_answers]
      mov rdx, 100
      mul rdx
      div rbx
      
      pop rdx
      pop rbx
      ret