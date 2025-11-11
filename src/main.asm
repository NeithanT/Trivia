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
    option_play         db 9, 9, "1 - Jugar Partida", 0
    option_change       db 9, 9, "2 - Agregar Pregunta", 0
    option_questions    db 9, 9, "3 - Ver Puntajes", 0
    option_exit         db 9, 9, "4 - Salir", 0
    option_ask          db 9, 9, "Escoge una opcion: ", 0
    option_not_valid    db 9, 9, "Opcion Invalida", 0

    ask_players         db 9, 9, "Cantidad de Jugadores[1-4]:", 0
    end_add             db 9, 9, "Se termino agregar preguntas", 0
    end_questions       db 9, 9, "Fin de Preguntas", 0

.UDATA
    answer              resw 1

.CODE

    extern show_intro
    extern play_game
    extern add_question
    extern show_scores

    .STARTUP
        call show_intro

    show_menu:
        nwln
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
        je start_game
        cmp DL, '2'
        je add_questions
        cmp DL, '3'
        je see_score
        cmp DL, '4'
        je done
        jmp not_valid

    start_game:
        PutStr ask_players
        jmp ask_player_count

    not_valid_player_count:
        PutStr  option_not_valid
        nwln

    ask_player_count:
        GetInt AX

        cmp AX, 1
        jl not_valid
        cmp AX, 4
        jg not_valid

    valid_player_count:

        call play_game
        jmp show_menu

    add_questions:

        call add_question
        jmp show_menu

    see_score:
        call show_scores
        jmp show_menu
    
    done:
        nwln
        .EXIT