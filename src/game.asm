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
    ask_answer  db "Tu respuesta [A | B | C | D]: ", 0
    correct_msg db "Correcta!", 0
    wrong_msg   db "Incorrecta!", 0
    score_msg   db "Puntuacion: ", 0
    end_game    db 9, "Se termino el juego", 0
    amt_players dw 0
    score       dw 0
    scores      dw 0, 0, 0, 0
    turns       dd 10

.UDATA
    answer  resb 1
    names   resb 80

.CODE

    extern get_question
    extern wipe_file

    global play_game

play_game:
    mov [amt_players], AX   ; AX must have the amount of players for the call
    call wipe_file  ; wipes the seenAnswer txt, note that AX is gone now!
    mov ECX, 0 ; ECX is going to be our turn counter
    cmp word [amt_players], 1
    jg multiplayer

one_player:
    call get_question
    jmp done

multiplayer:
    xor EDX, EDX ; EDX is the index of player ... from 0 to AX / amt_players
    call get_question ; the correct answer of the question should be in EAX now!
    inc EDX
    jmp done

done:
    ret