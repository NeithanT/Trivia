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
    file_answers    db "src/saves/seenQuestions.txt"
    amt_questions   dd 0
    current_quest   dd 0

.UDATA
    buffer          resb 100


.CODE

    extern read_question
    extern get_rand

    global get_question
    ; The purpose is to print a question
    ; and return the correct answer in EAX
    ; it needs the checks to verify the questions has not been seen before
    ; AAAAAND ... when that happens call read_question
    
    get_amt_questions:

        mov EAX, 5      ; open mode
        mov EBX, file_name  ; pass the file/direction
        mov ECX, 0 ; read only
        mov EDX, 0 ; no special modes
        int 0x80

        mov EBX, EAX    ; the file descriptor

        mov EAX, 3          ; sys_read
        mov ECX, buffer ; buffer pointer
        mov EDX, 100    ; amount of bytes
        int 0x80   

        ; look for a :
        mov ESI, buffer  ; the index for chars
        mov EAX, 0

    read_loop:

        cmp BYTE [ESI], ':'
        je read_amt
        inc ESI
        jmp read_loop

    read_amt:
        mov ECX, 10
        mul CX  ; multiply EAX by 10 to adjust for the system number
        inc ESI ; get the first num
        cmp BYTE [ESI], '0'
        jl end_num
        cmp BYTE [ESI], '9'
        jg end_num
        mov AL, BYTE [ESI] ; the number now is in EAX
        sub EAX, '0'
        jmp read_amt

    end_num:
        mov EAX, 6          ; sys_close
        int 0x80
        ret

    get_question:

        call get_amt_questions ; the amt of questions should NOW be in EAX
        mov [amt_questions], EAX

        jmp open_file

    try_again:

        mov EAX, 6          ; sys_close
        int 0x80 
        ; close the file for no errors and try again from zero!

    open_file:

        mov EAX, 5      ; open mode
        mov EBX, file_answers  ; pass the file/direction
        mov ECX, 0 ; read only
        mov EDX, 0 ; no special modes
        int 0x80

        mov EBX, EAX ; move the file descriptor

    get_rand_loop:

        mov EAX, [amt_questions]
        call get_rand   ; get's a random number in EAX, in range from 0 to EAX -1, cool!
        ; time to check if that questions has already appeared
        mov [current_quest], EAX ; save the question

    read:

        mov EAX, 3          ; sys_read
        mov ECX, buffer ; buffer pointer
        mov EDX, 100    ; amount of bytes
        int 0x80   

        mov ESI, buffer
        cmp BYTE [ESI], 0    ; check if the file ended even while reading more
        jmp done    ; go to end

    check_if_question:

        imul EAX, 10 ; account for the index
        ; We have to read the number at ESI, The numbers are separated by a command, so
        cmp BYTE [ESI], 0    ; check if the buffer ended
        je read ; read the next 100 bytes
        cmp BYTE [ESI], '0'  ; check for weird chars for some reason 
        jl analyze      ; jump to the cmp between EAX and the questions
        cmp BYTE [ESI], '9'
        jg analyze
        cmp BYTE [ESI], ','
        je analyze

        add AL, BYTE [ESI]  ; account for the index
        sub EAX, '0'
        inc ESI
        jmp check_if_question

    analyze:
        inc ESI

        cmp EAX, [current_quest]
        je try_again

        jmp check_if_question ; go to check the next in seenQuestions otherwise

        
    done:
        mov EAX, [current_quest]
        call read_question
        ret

