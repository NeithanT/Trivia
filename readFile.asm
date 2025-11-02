;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01------------------------------
;---------Neithan Vargas Vargas, Carné: 2025149384----------
;---2025/11/07 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac" ; Incluir macros para entrada y salida de datos

.DATA

    mode_msg    db "Seleccione el modo", 0
    mode_prompt db "Modos: 1- con distincion de mayuscula 2- sin distincion: ", 0
    msg_prompt  db "Ingrese el texto[Ctr+D para salir]: ", 0
    space_msg   db "espacios=", 0
    newline_msg db "enters=", 0 
    tab_msg     db "tabs=", 0
    eof_msg     db "EOF Encontrado", 0
    error_msg   db "Opcion invalida!", 0
    char_output db ": ", 0
    file_name   db "intro.txt", 0
    
.UDATA
    buffer  resb 1000

.CODE

    .STARTUP

        ;open	man/ cs/	0x05	const char *filename	int flags	umode_t mode
        ;
        ;
        ;

        mov EAX, 5      ; open mode
        mov EBX, file_name
        mov ECX, 0 ; no idea
        mov EDX, 0 ; no idea
        int 0x80

        ;
        ;
        ;
        ;

        mov EBX, EAX ; move the file descriptor
        mov EAX, 3  ; read mode
        mov ECX, buffer
        mov EDX, 1000
        int 0x80

        PutStr buffer
        nwln

    
    done:
        nwln    ; Imprime un salto de linea antes de finalizar
        .EXIT   ; Finaliza el programa