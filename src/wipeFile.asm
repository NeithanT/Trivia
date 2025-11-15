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
        ; syscall to open file
        ;                   eax     ebx                     ecx         edx
        ;open	man/ cs/	0x05	const char *filename	int flags	umode_t mode

        mov EAX, 5      ; open mode
        mov EBX, file_name

        ; opening the file in truncate mode, it wipes the file
        mov ECX, 512 ; truncate mode / wipe
        mov EDX, 0
        int 0x80

        ret