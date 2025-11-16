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

    mov EAX, 5 ; open file
    mov EBX, file_name ; questions.txt
    mov ECX, 0 ; read-only
    mov EDX, 0 ; no flags
    int 0x80 ; open

    mov [file_descriptor], AL ; save fd

    mov EAX, 3 ; read
    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; buffer
    mov EDX, 10000 ; read a lot
    int 0x80 ; read
    
    mov [buffer + EAX], BYTE 0 ; null terminate

    mov ESI, buffer ; start
    mov EDX, -1 ; header flag

find_question:

    cmp BYTE [ESI], 0 ; end?
    je done ; yep

    cmp BYTE [ESI], ':' ; ':' ?
    je found_delimiter ; yep
    inc ESI ; next
    jmp find_question ; continue

found_delimiter:

    cmp EDX, -1 ; skipped header?
    jne find_end ; already did
    mov EDX, 0 ; mark skipped
    inc ESI ; skip
    jmp find_question ; continue

find_end:

    inc ESI ; skip ':'
    inc ESI ; skip answer
    inc ESI ; skip newline
    mov EDI, ESI ; start of question
    jmp find_end_loop ; find end

find_end_loop:

    inc EDI ; next
    cmp BYTE [EDI], ']' ; end marker?
    je print ; yep
    cmp BYTE [EDI], 0 ; end?
    je done ; yep
    jmp find_end_loop ; continue

print:
    mov [EDI], BYTE 0 ; null
    PutStr ESI ; show question
    mov [EDI], BYTE ']' ; restore
    mov ESI, EDI ; to ']'
    inc ESI ; past it
    jmp find_question ; next

done:
    ret