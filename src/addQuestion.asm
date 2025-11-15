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

    mov EAX, 5 ; time to open the file
    mov EBX, file_name ; point to questions.txt

    mov ECX, 1025 ; append mode, add to end
    mov EDX, 0 ; no special flags
    int 0x80 ; open it

    mov [file_descriptor], EAX ; save the fd

    PutStr ask_type ; ask what type of question
    nwln
    jmp put_options ; show the options

invalid:
    PutStr invalid_opt ; oops, invalid choice
    nwln

put_options: 
    PutStr multi ; option 1: multiple choice
    nwln
    PutStr true_false ; option 2: true or false
    nwln

    PutStr option ; pick one
    GetInt AX ; get the choice

    cmp AX, 1 ; is it 1?
    je multiple_option ; yep, multiple
    cmp AX, 2 ; is it 2?
    je true_false_label ; yep, true/false

    jmp invalid ; nope, try again

ask_quest:
    PutStr ask_question ; what's the question?
    GetStr question, 100 ; read it
    ret
    
count_chars:
    mov EAX, 0 ; start counting

count_chars_loop:
    cmp BYTE [ECX], 0 ; end of string?
    je count_done ; yep
    inc ECX ; next char
    inc EAX ; count up
    jmp count_chars_loop ; keep going

count_done:
    ret

multiple_option:
    call ask_quest ; get the question
    mov EBX, answer ; buffer for answers
    mov CL, 'A' ; start with A

multiple_loop:
    cmp CL, 'E' ; done all 4?
    je ask_correct_label ; yep, ask correct
    PutStr ask_answer ; option #
    PutCh CL ; the letter
    PutCh ':' ; colon
    PutCh ' ' ; space
    GetStr EBX, 50 ; read the answer
    inc CL ; next letter
    add EBX, 50 ; next buffer slot
    jmp multiple_loop ; next one

invalid_correct:
    PutStr invalid_opt ; invalid
    nwln

ask_correct_label:
    PutStr ask_correct ; which is correct?
    GetCh BL ; get the letter
    cmp BL, 'A' ; too low?
    jl invalid_correct ; yep
    cmp BL, 'D' ; too high?
    jg invalid_correct ; yep

write_multiple:

    mov [correct_ans], BL ; save it
    call write_newline ; newline

    mov ECX, correct_save ; "Respuesta correcta:"
    call count_chars ; length
    mov ECX, correct_save ; again
    mov EDX, EAX ; length

    mov EAX, 4 ; write syscall
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; write it

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    mov ECX, correct_ans ; the letter
    mov EDX, 1 ; 1 byte
    int 0x80 ; write

    call write_newline ; newline

    mov ECX, question ; the question
    call count_chars ; length
    mov ECX, question
    mov EDX, EAX

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    int 0x80 ; write question

    call write_newline ; newline

    mov [small_buff], BYTE 'A' ; start with A
    mov [small_buff + 1], BYTE ')' ; )
    mov [small_buff + 2], BYTE ' ' ; space
    mov [small_buff + 3], BYTE 0 ; null

    mov ECX, answer ; answers buffer

write_multiple_loop:

    cmp AL, 'E' ; done?
    je write_done ; yep

    push ECX ; save
    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    mov ECX, small_buff ; "A) "
    mov EDX, 3 ; 3 bytes
    int 0x80 ; write

    pop ECX ; restore
    push ECX ; save again
    call count_chars ; length of answer
    mov EDX, EAX ; length

    pop ECX ; restore

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    int 0x80 ; write answer

    push ECX ; save
    call write_newline ; newline
    pop ECX ; restore

    add ECX, 50 ; next answer

    mov AL, BYTE [small_buff] ; current letter
    inc AL ; next
    mov [small_buff], AL ; update
    
    jmp write_multiple_loop ; next
    
true_false_label:
    call ask_quest ; get the question
    PutStr ask_true_false ; true or false?
    nwln
    PutStr true ; A) True
    nwln
    PutStr false ; B) False
    nwln
    jmp ask_ans_true_false ; get correct

not_valid_tf:
    PutStr invalid ; invalid
    nwln

ask_ans_true_false:
    PutStr ask_correct ; correct one?
    GetCh AL ; get A or B
    cmp AL, 'A' ; A?
    je save_true_false ; yep
    cmp AL, 'B' ; B?
    je save_true_false ; yep

    jmp not_valid_tf ; nope

save_true_false:
    mov [correct_ans], AL ; save

    call write_newline ; newline
 
    mov ECX, correct_save ; "Respuesta correcta:"
    call count_chars ; length
    mov ECX, correct_save ; again
    mov EDX, EAX ; length

    mov EAX, 4 ; write syscall
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; write label

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    mov ECX, correct_ans ; the letter
    mov EDX, 1 ; 1 byte
    int 0x80 ; write answer

    call write_newline ; newline

    mov ECX, question ; the question
    call count_chars ; length
    mov ECX, question
    mov EDX, EAX

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    int 0x80 ; write question

    call write_newline ; newline

    mov ECX, true_save ; "A) Verdadero"
    call count_chars ; length
    mov ECX, true_save
    mov EDX, EAX

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    int 0x80 ; write true option

    call write_newline ; newline

    mov ECX, false_save ; "B) Falso"
    call count_chars ; length
    mov ECX, false_save
    mov EDX, EAX

    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    int 0x80 ; write false option

    call write_newline ; newline

write_done:
    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    mov ECX, close_question ; ']'
    mov EDX, 1 ; 1 byte
    int 0x80 ; write end marker

    jmp close_file ; close up

write_newline:
    mov EAX, 4 ; write
    mov EBX, [file_descriptor]
    mov ECX, newline ; newline char
    mov EDX, 1 ; 1 byte
    int 0x80 ; write it
    ret

close_file:
    mov EAX, 6 ; close
    mov EBX, [file_descriptor]
    int 0x80 ; close

done:
    call change_count ; update count

    nwln
    PutStr added ; success
    nwln
    ret