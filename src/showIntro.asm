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

    file_name   db "src/saves/intro.txt", 0
    file_size   dd 1200

.UDATA

    buffer  resb 1200

.CODE

    global show_intro

show_intro:

    mov EAX, 5 ; open file
    mov EBX, file_name ; intro.txt
    mov ECX, 0 ; read-only
    mov EDX, 0 ; no flags
    int 0x80 ; open
    
    mov EBX, EAX ; fd to EBX
    mov EAX, 3 ; read
    mov ECX, buffer ; buffer
    mov EDX, [file_size] ; 1200 bytes
    int 0x80 ; read

    PutStr buffer ; show intro

done:

    mov EAX, 6  ; close
    int 0x80

    ret
