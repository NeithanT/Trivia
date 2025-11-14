;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/15 , II Periodo, Profesor: MS.c Esteban Arias---



%include "io.mac"

.DATA

    file_descriptor dd 0
    file_name       db "src/saves/questions.txt", 0
    ask_type        db 9, 9, "Que tipo de pregunta va a ser:", 0
    multi           db 9, 9, "1 - Opcion Multiple", 0
    true_false      db 9, 9, "2 - Verdadero o Falso", 0
    option          db 9, 9, "Ingrese una opcion:", 0
    invalid_opt     db 9, 9, "Opcion Invalida", 0
    ask_question    db 9, 9, "Ingresa la Pregunta: ", 0
    ask_answer      db 9, 9, "Opcion #", 0
    ask_correct     db 9, 9, "Respuesta correcta: ", 0
    ask_true_false  db 9, 9, "Es Verdadera o Falsa:", 0
    true            db 9, 9, "A) Verdadero", 0
    false           db 9, 9, "B) Falso", 0

    added           db 9, 9, "Se agrego pregunta correctamente", 0

    correct_save    db "Respuesta correcta:", 0
    true_save       db "A) Verdadero", 0
    false_save      db "B) Falso", 0

    close_question  db ']'
    double_point    db ':'
    newline         db 10

.UDATA

    question    resb 100
    answer      resb 200
    correct_ans resb 1
    small_buff  resb 5

.CODE

    extern change_count

    global add_question

add_question:

    mov EAX, 5      ; open mode
    mov EBX, file_name

    ; The writing is complicated. Apparently, write is with 1
    ; and append has the identifier of 1024, you combine them
    ; and you use the 1025 ...
    mov ECX, 1025 ; append mode with write
    mov EDX, 0

    int 0x80

    mov [file_descriptor], EAX ; move the file descriptor

    ; The objective is to ask for a question
    ; save it at the end
    ; and update the number of questions at the start of the file

    PutStr ask_type
    nwln
    jmp put_options

invalid:

    PutStr invalid_opt
    nwln

put_options: 

    PutStr multi
    nwln
    PutStr true_false
    nwln

    PutStr option
    GetInt AX 

    cmp AX, 1
    je multiple_option
    cmp AX, 2
    je true_false_label

    jmp invalid

ask_quest:

    PutStr ask_question
    GetStr question, 100 ; constant buffer size of 100 bytes
    ret
    
count_chars:

    mov EAX, 0

count_chars_loop:

    cmp BYTE [ECX], 0
    je count_done
    inc ECX
    inc EAX
    jmp count_chars_loop

count_done:

    ret

    ; this is going to count the len of the string in ECX

multiple_option:

    call ask_quest
    mov EBX, answer
    mov CL, 'A'

multiple_loop:

    cmp CL, 'E' 
    je ask_correct_label ; already asked all questions
    PutStr ask_answer
    PutCh CL
    PutCh ':'
    PutCh ' ' ; cheap way to put a space 
    GetStr  EBX, 50
    inc CL
    add EBX, 50
    jmp multiple_loop

invalid_correct:

    PutStr invalid_opt
    nwln

ask_correct_label:
    ; now, its time to ask for which of the inputted options
    ; is the correct one
    PutStr ask_correct
    GetCh BL
    cmp BL, 'A'
    jl invalid_correct
    cmp BL, 'D'
    jg invalid_correct

write_multiple:

    ; time to write the Respuesta correcta:
    mov [correct_ans], BL ; save the correct answer

    call write_newline

    mov ECX, correct_save
    call count_chars
    mov ECX, correct_save
    mov EDX, EAX

    mov EAX, 4
    mov EBX, [file_descriptor]
    int 0x80

    ; wrote the Respuesta correcta, now for the actual correct answer
    
    mov EAX, 4
    mov EBX, [file_descriptor]
    mov ECX, correct_ans
    mov EDX, 1
    int 0x80

    call write_newline

    mov [small_buff], BYTE 'A' ; i need the registers
    mov [small_buff + 1], BYTE ')'
    mov [small_buff + 2], BYTE ' '
    mov [small_buff + 3], BYTE 0

    mov ECX, answer

write_multiple_loop:

    cmp AL, 'E'
    je write_done

    push ECX

    mov EAX, 4
    mov EBX, [file_descriptor]
    mov ECX, small_buff
    mov EDX, 3
    int 0x80

    pop ECX
    push ECX
    call count_chars
    mov EDX, EAX
    pop ECX

    mov EAX, 4
    mov EBX, [file_descriptor]
    int 0x80

    push ECX
    call write_newline
    pop ECX

    add ECX, 50 ; next answer

    mov AL, BYTE [small_buff]
    inc AL
    mov [small_buff], AL
    
    jmp write_multiple_loop
    
true_false_label:

    call ask_quest  
    PutStr ask_true_false
    nwln
    PutStr true
    nwln
    PutStr false
    nwln
    jmp ask_ans_true_false

not_valid_tf:

    PutStr invalid
    nwln

ask_ans_true_false:

    PutStr ask_correct
    GetCh AL
    cmp AL, 'A'
    je save_true_false
    cmp AL, 'B'
    je save_true_false

    jmp not_valid_tf

save_true_false:

    mov [correct_ans], AL ; move the correct answer

    call write_newline
 
    mov ECX, correct_save
    call count_chars
    mov ECX, correct_save
    mov EDX, EAX

    ; write syscall
    mov EAX, 4
    mov EBX, [file_descriptor]
    int 0x80

    ; Now the respueta correcta is in the text file, time to copy
    ; the actual correct response
    mov EAX, 4
    mov ECX, correct_ans
    mov EDX, 1 ; only write the correct answer plus the newline!
    int 0x80

    call write_newline

    ; now is time to write the question and answer

    mov ECX, question
    call count_chars
    mov ECX, question ; the question pointer
    mov EDX, EAX

    mov EAX, 4
    mov EBX, [file_descriptor]
    int 0x80

    call write_newline

    ; now is time to write Verdadero, Falso and ]

    mov ECX, true_save
    call count_chars
    mov ECX, true_save
    mov EDX, EAX

    mov EAX, 4
    mov EBX, [file_descriptor]
    int 0x80
    ; wrote true

    call write_newline

    ; now is time to write false

    mov ECX, false_save
    call count_chars
    mov ECX, false_save
    mov EDX, EAX

    mov EAX, 4
    mov EBX, [file_descriptor]
    int 0x80
    ; wrote false

    call write_newline


write_done:

    mov EAX, 4 ; write syscall
    mov EBX, [file_descriptor]
    mov ECX, close_question
    mov EDX, 1
    int 0x80

    jmp close_file

write_newline:

    mov EAX, 4
    mov EBX, [file_descriptor]
    mov ECX, newline
    mov EDX, 1
    int 0x80
    ret

close_file:
    mov EAX, 6          ; sys_close
    mov EBX, [file_descriptor]
    int 0x80

done:
    
    call change_count

    nwln
    PutStr added
    nwln
    ret