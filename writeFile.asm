;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01------------------------------
;---------Neithan Vargas Vargas, Carné: 2025149384----------
;---2025/11/07 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac" ; Incluir macros para entrada y salida de datos

.DATA

    file_name   db "example.txt", 0
    buffer      db "Hello, testing to write"

.CODE

    .STARTUP

        ;open	man/ cs/	0x05	const char *filename	int flags	umode_t mode
        ;
        ;
        ;

        mov EAX, 5      ; open mode
        mov EBX, file_name
        mov ECX, 1 ; write only mode
        mov EDX, 0 ; no idea
        int 0x80

        ;
        ;
        ;
        ;

        mov EBX, EAX ; move the file descriptor
        mov EAX, 4  ; write mode
        mov ECX, buffer
        mov EDX, 23
        int 0x80

        mov EAX, 6  ; close file !
        int 0x80

    
    done:
        nwln    ; Imprime un salto de linea antes de finalizar
        .EXIT   ; Finaliza el programa