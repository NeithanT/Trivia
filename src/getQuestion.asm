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

    file_name       db "src/saves/questions.txt", 0
    file_answers    db "src/saves/seenQuestions.txt", 0
    file_descriptor dd 0
    amt_questions   dd 0
    current_quest   dd 0
    
.UDATA

    buffer          resb 1000


.CODE

    extern read_question
    extern get_rand

    global get_question
    global get_amt_questions
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

        mov EBX, EAX    ; the file descriptor returns in EAX

        mov EAX, 3          ; sys_read
        mov ECX, buffer ; buffer pointer
        mov EDX, 100    ; amount of bytes
        int 0x80   

        mov ESI, buffer  ; the index for chars
        mov EAX, 0

    read_loop:

        ; look for a : that's where the amount of questions are

        cmp BYTE [ESI], ':'
        je read_amt
        inc ESI
        jmp read_loop

    read_amt:

        inc ESI ; get the first num
        cmp BYTE [ESI], '0'
        jl end_num
        cmp BYTE [ESI], '9'
        jg end_num
        mov ECX, 10
        mul CX
        add AL, BYTE [ESI] ; the number now is in EAX
        sub EAX, '0'
        jmp read_amt

    end_num:
        push EAX
        mov EAX, 6          ; sys_close
        int 0x80
        pop EAX
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

        mov [file_descriptor], EAX ; move the file descriptor

    read:

        mov EAX, 3          ; sys_read
        mov EBX, [file_descriptor]
        mov ECX, buffer ; buffer pointer
        mov EDX, 1000    ; amount of bytes
        int 0x80

    get_rand_loop:

        mov EAX, [amt_questions]
        call get_rand   ; get's a random number in EAX, in range from 0 to EAX -1, cool!
        ; time to check if that questions has already appeared
        mov [current_quest], EAX ; save the question
        
        mov ESI, buffer
        mov EAX, 0

        jmp check_if_question

    next_num:

        mov EAX, 0
        inc ESI

    check_if_question:

        cmp BYTE [ESI], 0    ; check if the buffer ended
        je done
        cmp BYTE [ESI], ','
        je analyze

        imul EAX, 10 ; account for the index
        ; We have to read the number at ESI, The numbers are separated by a comma, so
        
        add AL, BYTE [ESI]  ; account for the index
        sub EAX, '0'
        inc ESI
        jmp check_if_question

    analyze:

        cmp EAX, [current_quest]
        je get_rand_loop

        jmp next_num ; go to check the next in seenQuestions otherwise
        
    done:

        mov EAX, [current_quest]
        call read_question
        ret

