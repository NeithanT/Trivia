;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/12 , II Periodo, Profesor: MS.c Esteban Arias---



%include "io.mac"

.DATA
    file_name       db "src/saves/questions.txt", 0
    ask_type        db 9, 9, "Que tipo de pregunta va a ser:", 0
    multi           db 9, "1 - Opcion Multiple", 0
    true_false      db 9, "2 - Verdadero o Falso", 0
    option          db 9, "Ingrese una opcion:", 0
    ask_question    db 9, "Ingresa la Pregunta: ", 0
    ask_answer      db 9, "Respuesta #", 0
    ask_correct     db 9, "Respuesta Correcta:"
.UDATA

    question    resb 100
    answer      resb 100

.CODE

    global add_question

add_question:


    ; The objective is to ask for a question
    ; save it at the end
    ; and update the number of questions at the start of the file


    mov EAX, 5      ; open mode
    mov EBX, file_name

    ; The writing is complicated. Apparently, write is with 1
    ; and append has the identifier of 1024, you combine them
    ; and you use the 1025 ...
    mov ECX, 1025 ; append mode with write
    mov EDX, 0

    int 0x80

    mov EBX, EAX ; move the file descriptor

    PutStr ask_type
    nwln

    invalid:
    

    put_options:

    PutStr multi
    nwln
    PutStr true_false
    nwln

    PutStr option
    GetInt AX 

    cmp AX, 1
    je multiple_option:
    cmp AX, 2
    je true_false

    jmp invalid
    ret