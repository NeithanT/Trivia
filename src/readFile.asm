;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/12 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac"

; NOT USED

.DATA

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

        mov EAX, 6  ; close file !
        int 0x80
    
    done:
        nwln    ; Imprime un salto de linea antes de finalizar
        .EXIT   ; Finaliza el programa