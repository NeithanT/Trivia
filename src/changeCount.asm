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
    file_append     db "src/saves/seenQuestions.txt", 0
    len             dd 0
    comma           db ','

.UDATA

    buffer          resb 100
    num             resb 10

.CODE

    extern get_amt_questions

    global change_count
    global append_amt
    global append_comma

    append_amt:

        push EAX
        ; time to append it to seenQuestions.txt
        mov EAX, 5      ; open mode
        mov EBX, file_append

        ; The writing is complicated. Apparently, write is with 1
        ; and append has the identifier of 1024, you combine them
        ; and you use the 1025 ...
        mov ECX, 1025 ; append mode with write
        mov EDX, 0

        int 0x80

        mov [file_descriptor], EAX

        ; write the questions with a , 

        jmp write_amt

    append_comma:

        ; time to append it to seenQuestions.txt
        mov EAX, 5      ; open mode
        mov EBX, file_append

        ; The writing is complicated. Apparently, write is with 1
        ; and append has the identifier of 1024, you combine them
        ; and you use the 1025 ...
        mov ECX, 1025 ; append mode with write
        mov EDX, 0

        int 0x80

        mov [file_descriptor], EAX

        mov EAX, 4
        mov EBX, [file_descriptor]
        mov ECX, comma
        mov EDX, 1
        int 0x80

        mov EAX, 6
        mov EBX, [file_descriptor]
        int 0x80
        ; close the file!
        ; just writes a , 

        ret

    change_count:

        call get_amt_questions
        inc EAX ; account for the written question
        push EAX ; save it for future use
        ; time to write it back

        mov EAX, 5 ; open mode
        mov EBX, file_name
        mov ECX, 2  ; read and write mode
        mov EDX, 0
        int 0x80

        ; the file descriptor is now in EAX
        mov [file_descriptor], EAX

        ; now, we need to know where the first :
        ; to change the number


        mov ESI, buffer  ; the index for chars
        mov EAX, 0

    read_loop:

        mov EAX, 3  ; sys_read
        mov EBX, [file_descriptor]
        mov ECX, buffer ; buffer pointer
        mov EDX, 1    ; amount of bytes
        int 0x80   
        ; look for a : that's where the amount of questions are

        cmp BYTE [buffer], ':'
        je write_amt
        jmp read_loop   ; go read the next byte

    write_amt:

        xor EBX, EBX
        xor EDX, EDX
        pop EAX ; the amount of questions
        ; now the file descriptor points at :, the next byte
        ; we write to, is going to be the number,
        ; we do not need checks as the number will always have
        ; the same or more digits than before!
        ; we need to do a conversion from the number in EAX
        ; to string 

    convert_string_loop:

        xor EDX, EDX
        mov ECX, 10
        div ECX

        add DL, '0' ; now we got the ASCII value of the last digit
        mov [buffer + EBX], DL
        inc EBX
        cmp EAX, 0 ; that means, the digit in DX is the last! 
        je exchange
        jmp convert_string_loop

    exchange:

        mov [len], EBX
        mov EAX, EBX
        xor EDX, EDX
        mov ECX, 2
        div ECX

        mov ESI, [len]
        dec ESI ; get the last index
        mov EDI, 0 ; the left pointer!
        ; now the length/2 is in EAX

    exchange_loop:

        cmp EAX, 0
        je write

        mov BL, [buffer + ESI]
        mov DL, [buffer + EDI]
        xchg BL, DL
        mov [buffer + ESI], BL
        mov [buffer + EDI], DL
        inc EDI
        dec ESI
        dec EAX
        jmp exchange_loop

    write:

        mov EAX, 4  ; sys_write
        mov EBX, [file_descriptor]
        mov ECX, buffer ; buffer pointer
        mov EDX, [len]    ; amount of bytes
        int 0x80

        mov EAX, 6
        mov EBX, [file_descriptor]
        int 0x80

        ret