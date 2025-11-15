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
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_name ; Point to the filename string for seenQuestions.txt
        mov ECX, 512 ; Set flags to 512 (O_TRUNC) to truncate/wipe the file
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open and truncate the file
        ret ; Return from function