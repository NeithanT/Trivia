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
    file_name       db  "src/saves/questions.txt", 0
    file_descriptor db 0
    
.UDATA
    buffer      resb 10000

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
        mov EDX, 10000    ; amount of bytes
        int 0x80
        ; EAX now has the number of bytes read
        mov [buffer + EAX], BYTE 0 ; Null-terminate the buffer

        mov ESI, buffer

    find_question:
        cmp BYTE [ESI], 0   ; End of buffer
        je done

        cmp BYTE [ESI], ':'
        je find_end
        inc ESI
        jmp find_question

    find_end:
        inc ESI ; skip ':', now at the answer
        inc ESI ; skip answer, now at the endline
        inc ESI ; skip endline, now at the start of the question '['
        mov EDI, ESI
        jmp find_end_loop

    find_end_loop:
        inc EDI
        cmp BYTE [EDI], ']'
        je print
        cmp BYTE [EDI], 0
        je done ; End of buffer, something is wrong with the format but we exit
        jmp find_end_loop

    print:
        mov [EDI], BYTE 0
        PutStr ESI
        mov [EDI], BYTE ']'
        mov ESI, EDI
        inc ESI ; Move past ']'
        jmp find_question


    done:

        ret