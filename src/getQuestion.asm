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

    extern read_question

    global get_question
    ; The purpose is to print a question
    ; and return the correct answer in EAX
    ; it needs the checks to verify the questions has not been seen before
    ; AAAAAND ... when that happens call read_question
    
    get_question:

