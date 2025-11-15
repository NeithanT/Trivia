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
    option_play         db 9, 9, "1 - Jugar Partida", 0
    option_change       db 9, 9, "2 - Agregar Pregunta", 0
    option_questions    db 9, 9, "3 - Ver Preguntas", 0
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
    extern show_quest

        .STARTUP
        call show_intro ; Display the introduction screen to the user

    show_menu:
        nwln ; Print a blank line for readability
        PutStr option_play ; Display option 1: Play Game
        nwln
        PutStr option_change ; Display option 2: Add Question
        nwln
        PutStr option_questions ; Display option 3: View Questions
        nwln
        PutStr option_exit ; Display option 4: Exit
        nwln
        jmp ask_option ; Jump to get user input

    not_valid:
        PutStr option_not_valid ; Display error message for invalid option
        nwln

    ask_option:
        PutStr option_ask ; Prompt user to enter a menu option
        GetCh DL ; Read a single character from user into DL
        cmp DL, '1' ; Check if user entered '1' (Play Game option)
        je start_game
        cmp DL, '2' ; Check if user entered '2' (Add Question option)
        je add_questions
        cmp DL, '3' ; Check if user entered '3' (View Questions option)
        je see_questions
        cmp DL, '4' ; Check if user entered '4' (Exit option)
        je done
        jmp not_valid ; If invalid, display error and loop back

    start_game:
        PutStr ask_players ; Prompt for number of players
        jmp ask_player_count ; Jump to validate and retrieve player count

    not_valid_player_count:
        PutStr  option_not_valid ; Display error message for invalid player count
        nwln

    ask_player_count:
        GetInt AX ; Read integer from user (number of players) into AX

        cmp AX, 1 ; Check if player count is less than 1
        jl not_valid
        cmp AX, 4 ; Check if player count is greater than 4
        jg not_valid

    valid_player_count:

        call play_game ; Call game function with player count in AX
        jmp show_menu ; Return to main menu after game ends

    add_questions:

        call add_question ; Call add_question function to allow user to add new questions
        jmp show_menu ; Return to main menu after adding question

    see_questions:
        call show_quest ; Call show_quest function to display all questions
        jmp show_menu ; Return to main menu
    
    done:
        nwln ; Print blank line before exiting
        .EXIT ; Exit the program