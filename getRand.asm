;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01------------------------------
;---------Neithan Vargas Vargas, Carné: 2025149384----------
;---2025/11/07 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac" ; Incluir macros para entrada y salida de datos

.DATA

    file_name   db "intro.txt", 0
    
.UDATA
    buffer  resb 1000

.CODE

    .STARTUP
        ;                   eax     ebx
        ;time	man/ cs/	0x0d	time_t *tloc

        mov EAX, 13  ; syscall for time (returns seconds since epoch)
        mov EBX, 0   ; NULL pointer
        int 0x80

        PutLInt EAX
        nwln
        
        mov     ECX, 5
        div ECX

        PutInt CX
        nwln
        PutInt AX
        nwln
    done:
        nwln    ; Imprime un salto de linea antes de finalizar
        .EXIT   ; Finaliza el programa