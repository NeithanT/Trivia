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
    file_name       db  "src/saves/questions.txt", 0
    file_descriptor db 0
    
.UDATA
    buffer      resb 100

.CODE

    global show_quest

    show_quest:

        mov EAX, 5          ; open mode
        mov EBX, file_name  ; pass the file/direction
        mov ECX, 0          ; no modes
        mov EDX, 0          ; read only
        int 0x80

        mov [file_descriptor], AL

        mov EAX, 3          ; sys_read
        mov EBX, [file_descriptor]  ; the fd
        mov ECX, buffer ; buffer pointer
        mov EDX, 30    ; amount of bytes
        int 0x80
        ; account for the starting empty line

    read:

        mov EAX, 3          ; sys_read
        mov EBX, [file_descriptor]  ; the fd
        mov ECX, buffer ; buffer pointer
        mov EDX, 100    ; amount of bytes
        int 0x80        ; interruption to read 100 bytes


        mov ESI, buffer
        cmp BYTE [ESI], 0
        je done

    find_question:

        cmp BYTE [ESI], ':'
        je find_end
        cmp BYTE [ESI], 0   ; the buffer ended
        je read             ; read more bytes
        inc ESI
        jmp find_question

    find_end:
        inc ESI ; skip to the next, the answer
        cmp BYTE [ESI], 0    ; check if the buffer ended
        je read_more
        inc ESI ; NOW, it should be in the endline
        cmp BYTE [ESI], 0    ; check if the buffer ended
        je read_more
        inc ESI ; NOW, it should be in theee start of the question
        cmp BYTE [ESI], 0    ; check if the buffer ended
        je read_more
        mov EDI, ESI
        jmp find_end_loop

    read_more:

        PutStr ESI
        mov EAX, 3          ; sys_read
        mov EBX, [file_descriptor]  ; the fd
        mov ECX, buffer ; buffer pointer
        mov EDX, 50    ; amount of bytes
        int 0x80        ; interruption to read 100 bytes

        mov ESI, buffer
        mov EDI, ESI

    find_end_loop:
        inc EDI
        cmp BYTE [EDI], ']'
        je print
        cmp BYTE [EDI], 0
        je read_more
        jmp find_end_loop

    print:

        mov [EDI], BYTE 0
        PutStr ESI
        mov [EDI], BYTE ']'
        mov ESI, EDI
        jmp find_question


    done:

        ret