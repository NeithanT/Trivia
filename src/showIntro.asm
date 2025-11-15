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
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_name ; Point to the filename string for intro.txt
        mov ECX, 0 ; Set flags to 0 for read-only access
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open the file
        
        mov EBX, EAX ; Move the returned file descriptor from EAX to EBX
        mov EAX, 3 ; Load syscall number for read (0x03)
        mov ECX, buffer ; Point to the buffer where file contents will be read
        mov EDX, [file_size] ; Load the maximum bytes to read (1200 bytes)
        int 0x80 ; Execute syscall to read entire intro file into buffer

        PutStr buffer ; Display the intro text from buffer to user

    done:

        mov EAX, 6  ; close file !
        int 0x80

        ret
    