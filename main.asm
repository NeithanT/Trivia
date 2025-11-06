;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/07 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac" ; Incluir macros para entrada y salida de datos

.DATA
    option_play         db 9, "1 - Jugar Partida", 0
    option_change       db 9, "2 - Agregar Pregunta", 0
    option_questions    db 9, "3 - Ver Preguntas", 0
    option_exit         db 9, "4 - Salir", 0
    option_ask          db 9, "Escoge una opcion: ", 0
    option_not_valid    db 9, "Opcion Invalida", 0

    intro   db "hello", 0
    tab     db 9

.UDATA
    answer  resw 1

.CODE

    extern show_menu

    .STARTUP
        call show_menu

    show_intro:
        PutStr option_play
        nwln
        PutStr option_change
        nwln
        PutStr option_questions
        nwln
        PutStr option_exit
        nwln
        jmp ask_option

    not_valid:
        PutStr option_not_valid
        nwln

    ask_option:
        PutStr option_ask
        GetCh DL
        cmp DL, '1'
        je play_game
        cmp DL, '2'
        je add_question
        cmp DL, '3'
        je see_questions
        cmp DL, '4'
        je done
        jmp not_valid

    play_game:
    
    add_question:

    see_questions:
    
    done:
        nwln
        .EXIT