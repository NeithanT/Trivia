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

    file_name   db "src/saves/seenQuestions.txt", 0

.CODE

    global wipe_file

    wipe_file:
        mov EAX, 5 ; open file
        mov EBX, file_name ; seenQuestions.txt
        mov ECX, 512 ; truncate flag
        mov EDX, 0 ; no modes
        int 0x80 ; open and wipe
        ret