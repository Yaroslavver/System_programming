; fasm z.asm; ld z.o; ./a.out
; b.out

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
    read_buffer rb 2048  ; Буфер для чтения файла
    current_pos dq ?     ; Текущая позиция в буфере
    bytes_read dq ?      ; Количество прочитанных байт
    filename db "vopros.txt", 0
    error_msg db "Ошибка открытия файла вопросов", 0xA, 0

    line_counter dq ?     ; Счетчик строк
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

    correct_answers dq 0    ; Счетчик верных ответов
    wrong_answers dq 0      ; Счетчик неверных ответов
    user_answer rb 2048      ; Буфер для ответа пользователя
    current_question rb 2048 ; Текущий вопрос (5-я строка)

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

    
    .nice:
        mov rsi, msg_nice
        call print_str
        jmp .read_loop
        
    .test:
        ; Открываем файл
        mov rsi, filename
        mov rdx, 0           ; O_RDONLY
        call open_file
        cmp rax, 0
        jl .open_error
        mov [file_descriptor], rax
        
        ; Инициализируем счетчик строк
        mov qword [line_counter], 0
        
        .read_loop:
            ; Читаем строку из файла
            mov rdi, [file_descriptor]
            mov rsi, input      ; Буфер для строки
            mov rdx, 2048        ; Размер буфера
            call read_line
            cmp rax, 0          ; Проверяем конец файла
            je .read_done
            
            ; Увеличиваем счетчик строк
            inc qword [line_counter]
            
            ; Проверяем позицию строки
            mov rax, [line_counter]
            mov rdx, 0
            mov rcx, 5
            div rcx             ; Делим на 5, остаток в rdx
            
            ; Обрабатываем группы строк
            cmp rdx, 0
            je .fifth_line
            cmp rdx, 1
            je .first_line
            
            ; Выводим вопросы (строки 2-4)
            
            ;mov rsi, msg_percent
            ;call print_str

            ;mov rsi, input
            ;call print_str
            ;call new_line
            ;jmp .read_loop

            ; Обработка строк 2-4 (варианты ответов)
            mov rbx, rdx
            sub rbx, 1          ; теперь rbx =1,2,3
            
            ; делаем пункты "1. ", "2. ", "3. "
            mov [option_prefix], bl
            add byte [option_prefix], '0' ; преобразуем число в символ
            mov byte [option_prefix+1], '.'
            mov byte [option_prefix+2], ' '
            mov byte [option_prefix+3], 0
            
            ; Вывод ответов
            mov rsi, option_prefix
            call print_str
            mov rsi, input
            call print_str
            call new_line
            jmp .read_loop
            
        .first_line:
            ; Начало новой группы - выводим заголовок
            call new_line
            mov rsi, msg_group1
            call print_str
            
            ; Выводим первый вопрос (без номера)
            mov rsi, input
            call print_str
            call new_line
            jmp .read_loop
            
            
        .fifth_line:
            ; Сохраняем правильный ответ (удаляем завершающий перевод строки)
            mov rdi, current_question
            mov rsi, input
            call copy_string
            ; Удаляем завершающий перевод строки в правильном ответе
            mov rdi, current_question
            call trim_newline
            
            
            ; Запрашиваем ответ
            mov rsi, msg_ask_answer
            call print_str
            mov rsi, user_answer
            call input_keyboard_answer
            ; Удаляем завершающий перевод строки в ответе пользователя
            mov rdi, user_answer
            call trim_newline
            
            ; Сравниваем ответы
            mov rsi, user_answer
            mov rdi, current_question
            call compare_strings
            cmp rax, 1
            je .answer_correct
            
            call new_line
            
            ; Неправильный ответ
            inc qword [wrong_answers]
            mov rsi, msg_wrong
            call print_str
            mov rsi, current_question
            call print_str
            call new_line
            jmp .continue_test
            
        .answer_correct:
            ; Правильный ответ
            inc qword [correct_answers]
            mov rsi, msg_correct
            call print_str
            
        .continue_test:
            ; Ждем нажатия Enter для продолжения
            mov rsi, msg_continue
            call print_str
            mov rsi, prompt_buffer
            call input_keyboard
            jmp .read_loop
        
        .read_done:
            ; Закрываем файл
            mov rdi, [file_descriptor]
            call close_file
            
            ; Выводим статистику
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
        call str_number   ; Преобразуем в число (результат в rax)
        mov rbx, rax      ; Сохраняем количество групп в rbx
        
        ; Создаем/очищаем файл
        mov rsi, filename
        mov rdx, 03101o  ; O_WRONLY|O_CREAT|O_TRUNC
        ;or  rcx, 0100o     ;if it doesn't exist create the file
        ;or  rcx, 01000o      ;truncate
        ;mov rdx, 0101o

        call create_file
        mov r12, rax      ; Сохраняем дескриптор файла в r12
        
        ; Цикл по группам
        xor r13, r13      ; Счетчик групп
        .group_loop:
            cmp r13, rbx
            jge .groups_done
            
            ; Запрос строки 1
            mov rsi, msg_line1
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            ; Запрос строки 2
            mov rsi, msg_line2
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            ; Запрос строки 3
            mov rsi, msg_line3
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            ; Запрос строки 4
            mov rsi, msg_line4
            call print_str
            mov rsi, input
            call input_keyboard
            call write_line_to_file
            
            ; Запрос строки 5 (особой)
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
    call len_str      ; Результат в rax
    
    ; Записываем строку
    mov rdi, r12      ; file descriptor
    mov rdx, rax      ; длина
    call write_file
    
    ; Записываем символ новой строки
    mov rdi, r12
    mov rsi, newline
    mov rdx, 1
    call write_file
    
    pop rdx
    pop rsi
    ret


