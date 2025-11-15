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
        mov [question_size], EAX
        ; Divide by amount of questions
        ; To get the modulo after
        rdtsc           ; gets the current clock cycle in EAX:EDX
        xor EDX, EDX    ; only get the last part in EAX! otherwise floating point error
        mov ECX, [question_size]    ; Move the amount of Questions
        div ECX  ; now the modulo or residue, should be in EDX!
        ; let's move it to EAX!
    
        mov EAX, EDX
        
        ret