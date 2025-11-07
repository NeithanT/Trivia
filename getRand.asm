;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01------------------------------
;---------Neithan Vargas Vargas, Carné: 2025149384----------
;---2025/11/12 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac"

.DATA

    file_name       db "intro.txt", 0
    question_size   dd  30
    eax_help        db "A VALUE:", 0
    edx_help        db "D VALUE:", 0

.CODE

    .STARTUP
    
        ; Divide by amount of questions
        ; To get the modulo after
        rdtsc
        xor EDX, EDX    ; only get the last part in EAX
        mov ECX, [question_size] 
        PutLInt ECX
        div ECX

        nwln
        PutStr eax_help
        nwln
        PutLInt EAX
        nwln
        PutStr edx_help
        nwln
        PutLInt EDX

    done:
        nwln    ; Imprime un salto de linea antes de finalizar
        .EXIT   ; Finaliza el programa