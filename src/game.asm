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
    player_num  db 9, "Jugador #", 0
    ask_name    db 9, "Ingresa tu nombre: ", 0
    ask_answer  db 9, "Tu respuesta [A | B | C | D]: ", 0
    correct_ans db 9, "La respuesta correcta era:"
    correct_msg db 9, "Correcta!", 0
    wrong_msg   db 9, "Incorrecta!", 0
    score_msg   db 9, "Puntuacion: ", 0
    end_game    db 9, "Se termino el juego", 0
    amt_ques    dd 10
    amt_players dw 0
    score       dw 0
    scores      dw 0, 0, 0, 0
    turns       dd 10
    score_table dw 100, 100, 100, 100, 100, 200, 200, 200, 300, 300

    here1       db "it got here 1", 0

    here2       db "here 2", 0

    here3       db "here 3", 0

    here4       db "here 4", 0

    here5       db "here 5", 0

    here6       db "here 6", 0

    here7       db "here 7", 0

    here8       db "here 8", 0

    here9       db "here 9", 0

    here10      db "here 10", 0

    here11      db "here 11", 0

    here12      db "here 12", 0

    here13      db "here 13", 0

    here14      db "here 14", 0

    here15      db "here 15", 0

.UDATA
    answer      resb 1
    names       resb 80

.CODE

    extern get_question
    extern wipe_file

    global play_game

play_game:
    PutStr here1
    nwln
    mov [amt_players], AX   ; AX must have the amount of players for the call
    call wipe_file  ; wipes the seenAnswer txt, note that AX is gone now!
    mov ECX, 0 ; ECX is going to be our turn counter
    mov EDX, 0 ; EDX is the index for player, stays at 0 for single
    cmp word [amt_players], 1   ; check to redirect to which mode
    jg multiplayer ; redirect in case there is more than 1 player

multiplayer:

ask_player_name:

    inc EDX
    PutStr player_num
    PutLInt EDX
    PutStr ask_name
    
    GetStr EBX, 19
    nwln
    cmp EDX, [amt_players]
    jge turns_start
    add EBX, 20 ; go to the next name
    jmp ask_player_name

turns_start:

    PutStr here8

    nwln

    mov EBX, 0 ; this is the counter for turns

turn_loop:
    cmp EBX, 10
    jge show_scores
    inc EBX
    mov EDX, 0 ; back to player 0

;Al completarse la partida de 10 preguntas el juego terminará, mostrando
;los puntos obtenidos y el ranking (si hay múltiples jugadores). Un jugador
;podrá terminar cuando lo desee, en ese momento se brindarán los puntos
;acumulados y el ranking (si hay múltiples jugadores).

play_loop:
    
    call get_question   ; now the correct answer is in AH
    PutStr ask_answer
    GetCh AL
    mov [answer], AL
    nwln
    cmp AH, byte [answer]
    je increase_score
    ; else the answer is incorrect

incorrect:

    PutStr wrong_msg
    nwln
    PutStr correct_ans
    PutCh AH 
    nwln
    inc EDX
    cmp EDX, [amt_players]
    jge turn_loop

increase_score:

    ; The turn is in EBX so, we're adding score depending on the turn
    ; first 5 turns 100, 6,7,8 for 200 and 9, 10 for 300
    ; for this, is better to use the score_table, if not, we would need
    ; a lot of comparisons
    ; index * 2 will get us the byte number
    dec EBX ; adjust for index
    mov AX, [score_table + EBX * 2] ; indirect based index addressing
    inc EBX ; restore EBX

    add word [scores + EDX * 2], AX ; add score
    inc EDX
    jmp play_loop

show_scores:
    PutStr end_game
    nwln
    mov ECX, 0 ; player counter
    
show_scores_loop:
    cmp ECX, [amt_players]
    jge done
    
    PutStr score_msg
    mov AX, [scores + ECX * 2]
    PutInt AX
    nwln
    inc ECX
    jmp show_scores_loop

done:
    ret