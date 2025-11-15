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
    question_size   dd  0   ; store the amount of questions to get the modulo
    ; could have in .UDATA a resd but oh well
    
.CODE

    global get_rand

    get_rand:
        mov [question_size], EAX ; Save the max value for modulo operation
        rdtsc ; Get current CPU clock cycle into EAX:EDX (64-bit value split)
        xor EDX, EDX ; Clear EDX to only use the lower 32-bit clock value in EAX
        mov ECX, [question_size] ; Load the question count into ECX for division
        div ECX ; Divide EAX by ECX, remainder stored in EDX
        mov EAX, EDX ; Move the modulo result from EDX to EAX as return value
        ret ; Return from function with random number (0 to question_size-1) in EAX