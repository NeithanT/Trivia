;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/12 , II Periodo, Profesor: MS.c Esteban Arias---


%include "io.mac"

.DATA

.UDATA

.CODE

    global show_questions

    ; The objective is to show all the questions
    ; but without the answer, just like a check
    ; While reading there's is also the ] that has to be taken into count for ending

    show_questions:
        
        ret