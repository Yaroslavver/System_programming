format ELF64
include 'func.asm'
public _start

section '.bss' writable
    input rb 2048
    msg_hi db "Это платформа тестирования по программе ''Системное программирование''.", 0xA, 0
    msg_menu_1 db "Введите 1 для прохождения тестирования", 0xA, 0
    msg_menu_2 db "Введите 2 для изменения теста", 0xA, 0
    msg_menu_3 db "Введите 3 для выхода из программы тестирования", 0xA, 0
    msg_nice db "Верно!", 0xA, 0
    msg_1 db "1", 0xA, 0

    file_descriptor dq ?
    read_buffer rb 2048  ; Буфер чтения
    current_pos dq ?    ; текущая позиция в буфере
    bytes_read dq ? ; колво прочитанных байт
    filename db "vopros.txt", 0
    error_msg db "Ошибка открытия файла вопросов", 0xA, 0

    line_counter dq ?     ; счетчик строк
    prompt_buffer rb 2048  ; Буфер для строки с приглашением
    msg_continue db "[Нажмите Enter для перехода к следующему вопросу...]", 0xA, 0
    msg_group1 db "__________ Вопрос __________", 0xA, 0
    msg_group2 db "Ваш ответ (1, 2 или 3):", 0xA, 0

    msg_groups db "Введите количество вопросов для теста: ", 0
    msg_line1 db "Введите вопрос: ", 0
    msg_line2 db "Введите вариант ответа 1: ", 0
    msg_line3 db "Введите вариант ответа 2: ", 0
    msg_line4 db "Введите вариант ответа 3: ", 0
    msg_line5 db "Введите номер правильного ответа (1, 2 или 3): ", 0
    msg_done db "Данные успешно записаны в файл", 0xA, 0
    newline db 0xA

    correct_answers dq 0    ;  верные ответы
    wrong_answers dq 0      ; неверные ответы
    user_answer rb 2048      ; ответ пользователя
    current_question rb 2048 ; текущий вопрос

    msg_ask_answer db "Введите ваш ответ: ", 0
    msg_correct db "Правильно!", 0xA, 0
    msg_wrong db "Неправильно! Правильный ответ: ", 0
    msg_statistics db "______ Результаты тестирования ______", 0xA, 0
    msg_total_questions db "    Всего вопросов: ", 0
    msg_correct_count db "    Правильных ответов: ", 0
    msg_wrong_count db "    Неверных ответов: ", 0
    msg_grade db "Ваша оценка: ", 0
    msg_percent db "%", 0xA, 0

    option_prefix db "1. ", 0  ; Шаблон будет изменяться

    lines_array dq 1000 dup (?)  ; массив указателей на строки
    question_ptrs dq 200 dup (?)  ; указатели на группы вопросов
    question_count dq 0   ; колво вопросов
    current_question_index dq 0  ; текущий индекс вопроса

    f db "/dev/urandom",0
    number rb 1

section '.text' executable
_start:
    .menu_loop:
        mov rsi, msg_hi
        call print_str
        mov rsi, msg_menu_1
        call print_str
        mov rsi, msg_menu_2
        call print_str
        mov rsi, msg_menu_3
        call print_str

        mov rsi, input
        call input_keyboard

        ;mov rsi, input
        ;call print_str

        cmp byte [rsi], '1'
        je .test

        cmp byte [rsi], '2'
        je .create

        cmp byte [rsi], '3'
        je .close
        
        call exit

        
    .test:
        mov rsi, filename
        mov rdx, 0
        call open_file
        cmp rax, 0
        jl .open_error
        mov [file_descriptor], rax

        call load_all_questions
        call shuffle_questions

        mov rdi, [file_descriptor]
        call close_file

        call shuffle_questions

        mov qword [current_question_index], 0

    .question_loop:
        mov rax, [current_question_index]
        cmp rax, [question_count]
        jge .read_done
        mov rbx, [question_ptrs + rax*8]
        call process_question
        inc qword [current_question_index]
        jmp .question_loop

        .read_done:
            mov rdi, [file_descriptor]
            call close_file

            call new_line
            mov rsi, msg_statistics
            call print_str
            
            ; Всего вопросов
            mov rsi, msg_total_questions
            call print_str
            mov rax, [correct_answers]
            add rax, [wrong_answers]
            mov rsi, input
            call number_str
            mov rsi, input
            call print_str
            call new_line
            
            ; Правильные ответы
            mov rsi, msg_correct_count
            call print_str
            mov rax, [correct_answers]
            mov rsi, input
            call number_str
            mov rsi, input
            call print_str
            call new_line
            
            ; Неправильные ответы
            mov rsi, msg_wrong_count
            call print_str
            mov rax, [wrong_answers]
            mov rsi, input
            call number_str
            mov rsi, input
            call print_str
            call new_line
            
            ; Оценка в процентах
            mov rsi, msg_grade
            call print_str
            call calculate_grade
            mov rsi, input
            call number_str
            mov rsi, input
            call print_str
            mov rsi, msg_percent
            call print_str

            ;сбрасываем значения
            mov qword [correct_answers], 0
            mov qword [wrong_answers], 0
            
            call new_line
            ; Возвращаемся в меню
            jmp .menu_loop
        
        .open_error:
            mov rsi, error_msg
            call print_str
            jmp .menu_loop


    .create:
        ; Запрашиваем количество групп
        mov rsi, msg_groups
        call print_str
        
        ; Читаем количество групп
        mov rsi, input
        call input_keyboard
        call str_number
        mov rbx, rax
        
        ; Создаем/очищаем файл
        mov rsi, filename
        mov rdx, 03101o
        ;or  rcx, 0100o
        ;or  rcx, 01000o
        ;mov rdx, 0101o

        call create_file
        mov r12, rax      ; дескриптор в r12
        
        xor r13, r13      ; Счетчик групп вопросов
        .group_loop:
            cmp r13, rbx
            jge .groups_done
            
            mov rsi, msg_line1
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            mov rsi, msg_line2
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            mov rsi, msg_line3
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            mov rsi, msg_line4
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            mov rsi, msg_line5
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            call new_line
            inc r13       ; Увеличиваем счетчик групп
            jmp .group_loop
        
        .groups_done:
            ; Закрываем файл
            mov rdi, r12
            call close_file
            
            ; Сообщение об успехе
            mov rsi, msg_done
            call print_str
            
            ; Возврат в меню
            jmp .menu_loop


    .close:
        call exit

    
; Вспомогательная функция для записи строки в файл
; Input: rsi - строка (с нулевым окончанием), r12 - file descriptor
write_line_to_file:
    push rsi
    push rdx
    
    ; Вычисляем длину строки
    mov rax, rsi
    call len_str
    
    ; Записываем строку
    mov rdi, r12
    mov rdx, rax
    call write_file
    
    ; Записываем символ новой строки
    mov rdi, r12
    mov rsi, newline
    mov rdx, 1
    call write_file
    
    pop rdx
    pop rsi
    ret




; перемешивает массив question_ptrs
shuffle_questions:
    push rbx
    push r12
    push r13

    mov rbx, [question_count]
    test rbx, rbx
    jz .end

    dec rbx
    .loop:
        call random
        xor rdx, rdx
        mov rcx, rbx
        inc rcx
        div rcx
        mov r12, rdx

        ; Обмен указателей question_ptrs[i] и question_ptrs[j]
        mov r13, [question_ptrs + rbx*8]
        mov rcx, [question_ptrs + r12*8]
        mov [question_ptrs + rbx*8], rcx
        mov [question_ptrs + r12*8], r13

        dec rbx
        jns .loop

    .end:
        pop r13
        pop r12
        pop rbx
        ret



;обрабатывает один вопрос по индексу в lines_array

process_question:
    push r12
    push r13
    push r14
    ; rbx содержит индекс начала вопроса в lines_array
    mov r12, rbx
    ; Вывод заголовка вопроса
    mov rsi, msg_group1
    call print_str
    ; Вывод вопроса (первая строка)
    mov rsi, [lines_array + r12*8]
    call print_str
    call new_line
    ; Вывод вариантов ответа 1, 2, 3
    mov r13, 1  ; номер варианта

    .answer_loop:
        cmp r13, 3
        jg .answers_done
        ; формируем пункты
        mov [option_prefix], r13b
        add byte [option_prefix], '0'
        mov byte [option_prefix+1], '.'
        mov byte [option_prefix+2], ' '
        mov byte [option_prefix+3], 0
        
        mov rsi, option_prefix
        call print_str
        
        ;ответ
        mov rax, r12
        add rax, r13  ; r12 +1, +2, +3
        mov rsi, [lines_array + rax*8]
        call print_str
        call new_line
        inc r13
        jmp .answer_loop

    .answers_done:
        ; Получаем правильный ответ
        mov rsi, [lines_array + (r12+4)*8]
        mov rdi, current_question
        call copy_string

        ; запрос ответа пользователя
        mov rsi, msg_ask_answer
        call print_str
        mov rsi, user_answer
        call input_keyboard_answer
        mov rdi, user_answer
        call trim_newline

        ; Сравнение ответов
        mov rsi, user_answer
        mov rdi, current_question
        call compare_strings
        cmp rax, 1
        je .answer_correct

        ; Неправильный ответ
        inc qword [wrong_answers]
        mov rsi, msg_wrong
        call print_str
        mov rsi, current_question
        call print_str
        call new_line
        jmp .continue

    .answer_correct:
        inc qword [correct_answers]
        mov rsi, msg_correct
        call print_str
    .continue:
        call new_line
        ; ждем пользователя, чтобы нажал Enter
        mov rsi, msg_continue
        call print_str
        mov rsi, prompt_buffer
        call input_keyboard
        pop r14
        pop r13
        pop r12
        ret

; Находим следующий символ новой строки в буфере
; rdi - начало. rsi - конец буфера. Выход rdx указатель на \n или конец
find_next_newline:
    mov rdx, rdi
    .loop:
    cmp rdx, rsi
    jge .done
    cmp byte [rdx], 0xA
    je .done
    inc rdx
    jmp .loop
    .done:
    ret
; прочитать весь файл в буфер для загрузки
;rdi - дескриптор, rsi - буфер, rdx - размер. rax - прочитано байт
read_entire_file:
    mov rax, 0  ; sys_read
    syscall
    ret



; все вопросы из файла в lines_array. формируем question_ptrs
load_all_questions:
    push r12
    push r13
    push r14
    push r15
    ; Читаем весь файл в read_buffer
    mov rdi, [file_descriptor]
    mov rsi, read_buffer
    mov rdx, 2048
    call read_entire_file
    mov [bytes_read], rax
    ; Разбиваем буфер на строки и сохраняем в lines_array
    mov r12, read_buffer  ; текущая позиция
    mov r13, read_buffer
    add r13, rax          ; конец буфера
    xor r14, r14          ; счетчик строк
    .parse_lines:
        cmp r12, r13
        jge .parse_done
        ; Находим конец строки
        mov rdi, r12
        mov rsi, r13
        call find_next_newline
        ; rdx - указатель на \n или конец данных
        ; Сохраняем указатель на строку
        mov [lines_array + r14*8], r12
        ; Заменяем \n на 0
        mov byte [rdx], 0
        ; Переходим к следующей строке
        mov r12, rdx
        inc r12
        inc r14
        jmp .parse_lines
    .parse_done:
        ; Группируем строки по 5 в question_ptrs
        xor rcx, rcx  ; счетчик вопросов
        xor rbx, rbx  ; индекс в lines_array
    .group_loop:
        mov rax, rbx
        add rax, 4
        cmp rax, r14
        jge .group_done  ; не хватает строк для полного вопроса
        ; Сохраняем индекс начала группы из 5 строк
        mov [question_ptrs + rcx*8], rbx
        inc rcx
        add rbx, 5
        jmp .group_loop
    .group_done:
        mov [question_count], rcx
        pop r15
        pop r14
        pop r13
        pop r12
        ret



; Генерация случайного числа в rax случайный байт
random:
    mov rax, 2               ; sys_open
    mov rdi, f
    mov rsi, 0
    syscall
    cmp rax, 0
    jl .error
    mov r8, rax              ; Сохраняем дескриптор файла

    mov rax, 0
    mov rdi, r8              ; дескриптор
    mov rsi, number          ; буфер
    mov rdx, 1               ; размер
    syscall

    mov rax, 3        ; закрыть
    mov rdi, r8
    syscall

    ; Возвращаем результат
    movzx rax, byte [number]
    ret

.error:
    mov rsi, error_msg       ; ошибка
    call print_str
    call exit