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
    ask_answer  db 9, "Tu respuesta [0 para terminar]: ", 0
    correct_ans db 9, "La respuesta correcta era: ", 0
    correct_msg db 9, "Correcta!", 0
    wrong_msg   db 9, "Incorrecta!", 0
    points_add  db 9, "Puntos ganados: ", 0
    score_msg   db 9, "Puntuacion: ", 0
    end_game    db 9, "Se termino el juego", 0
    leaderboard db 9, "====Puntuaciones====", 0
    tab         db 9
    amt_ques    dd 10
    amt_players dw 0
    score       dw 0
    scores      dw 0, 0, 0, 0
    turns       dd 10
    score_table dw 100, 100, 100, 100, 100, 200, 200, 200, 300, 300

.UDATA

    answer      resb 1
    names       resb 80

.CODE

    extern get_question
    extern wipe_file
    global play_game

play_game:

    nwln
    mov [amt_players], AX   ; AX must have the amount of players for the call
    call wipe_file  ; wipes the seenAnswer txt
    
    ; Initialize name buffer pointer
    mov EBX, names
    mov EDX, 0 ; EDX is the player counter

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
    mov EBX, 0 ; this is the counter for turns (0-based)

turn_loop:
    cmp EBX, [amt_ques]
    jge show_scores
    mov EDX, 0 ; back to player 0

play_loop:
    ; Display current player info
    push EDX
    push EBX

    nwln
    PutStr player_num
    inc EDX
    PutLInt EDX
    nwln
    dec EDX

    pop EBX
    pop EDX
    
    push EDX
    push EBX

    call get_question   ; now the correct answer is in EAX
    mov [answer], AL

    pop EBX
    pop EDX
    
    PutStr ask_answer
    GetCh AL
    nwln
    
    cmp AL, '0'
    je show_scores
    
    cmp AL, byte [answer]
    je increase_score

; else the answer is incorrect
incorrect:

    PutStr wrong_msg
    nwln
    PutStr correct_ans
    PutCh [answer]
    nwln
    inc EDX
    cmp EDX, [amt_players]
    jge next_turn
    jmp play_loop

increase_score:
    PutStr correct_msg
    nwln
    
    ; Get points from score_table (EBX is 0-based turn index)
    push EDX
    mov AX, [score_table + EBX * 2]
    PutStr points_add
    PutInt AX
    nwln
    pop EDX
    
    ; Add score to current player
    ; EDX is now guaranteed to be correct because we saved/restored it
    add AX, word [scores + EDX * 2]
    mov [scores + EDX * 2], AX
    
    inc EDX
    cmp EDX, [amt_players]
    jge next_turn
    jmp play_loop

next_turn:
    inc EBX
    jmp turn_loop

show_scores:
    nwln
    PutStr end_game
    nwln
    PutStr leaderboard
    nwln

loop_scores:
    mov EBX, 0 ; player count shown so far
    
find_next_max:

    mov EAX, -1  ; start with -1 to find any score greater
    mov EDX, 0   ; index of max score player
    mov ECX, 0   ; player counter for the loop
    
get_max_score:

    cmp ECX, [amt_players]
    jge show_current_max
    
    ; Compare current max (AX) with scores[ECX] (SI)
    ; This is a signed comparison
    mov SI, [scores + ECX * 2]
    cmp AX, SI
    jge next_player ; jge is a SIGNED jump (Jump if Greater or Equal)
    
    ; New max found
    movsx EAX, SI ; Sign-extend new max into EAX
    mov EDX, ECX  ; Save index of new max player
    
next_player:

    inc ECX
    jmp get_max_score

show_current_max:
    ; Check if we found a valid score (EAX will be -1 if all are shown)
    cmp EAX, 0
    jl done
    
    ; Show this player's score
    inc EBX
    PutStr player_num
    PutLInt EBX
    PutCh ' '
    
    ; Calculate name address: names + (EDX * 20)
    push EAX
    push EBX

    mov EAX, EDX
    mov EBX, 20
    mul EBX
    mov EBX, names
    add EBX, EAX

    PutStr EBX

    pop EBX
    pop EAX
    nwln
    
    PutStr score_msg
    PutInt AX ; Print the score (AX is low 16 bits of EAX)
    nwln
    nwln
    
    ; Mark this score as shown by setting it to -1
    mov word [scores + EDX * 2], -1
    
    cmp EBX, [amt_players]
    jge done
    jmp find_next_max

done:

    ret