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
    nwln ; Print blank line
    mov [amt_players], AX ; Store the number of players from AX parameter
    call wipe_file ; Clear the seenQuestions.txt file to reset seen questions
    
    mov word [scores], 0 ; Initialize player 1 score to 0
    mov word [scores + 2], 0 ; Initialize player 2 score to 0
    mov word [scores + 4], 0 ; Initialize player 3 score to 0
    mov word [scores + 6], 0 ; Initialize player 4 score to 0
    
    mov EBX, names ; Point to start of names buffer
    mov EDX, 0 ; Initialize player counter to 0

ask_player_name:
    inc EDX ; Increment player counter (1-based display)
    PutStr player_num ; Display "Jugador #"
    PutLInt EDX ; Display current player number
    PutStr ask_name ; Prompt for player name
    GetStr EBX, 19 ; Read player name (max 19 bytes + null terminator = 20)
    nwln ; Print newline
    
    cmp EDX, [amt_players] ; Check if we've asked all players for their names
    jge turns_start ; If yes, begin game turns
    add EBX, 20 ; Move to next name buffer position (each name slot is 20 bytes)
    jmp ask_player_name ; Continue asking for next player's name

turns_start:
    mov EBX, 0 ; Initialize turn counter to 0 (questions asked so far)

turn_loop:
    cmp EBX, [amt_ques] ; Check if we've asked all 10 questions
    jge show_scores ; If yes, show final leaderboard
    mov EDX, 0 ; Reset player counter to 0 (start with player 1)

play_loop:
    push EDX ; Save current player index
    push EBX ; Save current question index

    nwln ; Print blank line
    PutStr player_num ; Display "Jugador #"
    inc EDX ; Increment to 1-based for display
    PutLInt EDX ; Display player number
    nwln ; Print newline
    dec EDX ; Decrement back to 0-based index

    pop EBX ; Restore question index
    pop EDX ; Restore player index
    
    push EDX ; Save player index again
    push EBX ; Save question index again

    call get_question ; Get next question and correct answer into EAX
    mov [answer], AL ; Store the correct answer character

    pop EBX ; Restore question index
    pop EDX ; Restore player index
    
    PutStr ask_answer ; Prompt user for their answer
    GetCh AL ; Read one character (A, B, C, D, or 0) into AL
    nwln ; Print newline
    
    cmp AL, '0' ; Check if user entered '0' (quit game early)
    je show_scores ; If yes, jump to show final scores
    
    cmp AL, byte [answer] ; Compare user answer with correct answer
    je increase_score ; If equal, process correct answer

; If we reach here, the answer is incorrect
incorrect:
    PutStr wrong_msg ; Display "Incorrecta!"
    nwln ; Print newline
    PutStr correct_ans ; Display "La respuesta correcta era:"
    PutCh [answer] ; Display the correct answer
    nwln ; Print newline
    inc EDX ; Move to next player
    cmp EDX, [amt_players] ; Check if all players answered this question
    jge next_turn ; If yes, move to next question
    jmp play_loop ; If no, ask next player

increase_score:
    PutStr correct_msg ; Display "Correcta!"
    nwln ; Print newline
    
    push EDX ; Save player index
    mov AX, [score_table + EBX * 2] ; Get points for current question (EBX is question index)
    PutStr points_add ; Display "Puntos ganados:"
    PutInt AX ; Display the points earned
    nwln ; Print newline
    pop EDX ; Restore player index
    
    add AX, word [scores + EDX * 2] ; Add earned points to current player's score
    mov [scores + EDX * 2], AX ; Store updated score
    
    inc EDX ; Move to next player
    cmp EDX, [amt_players] ; Check if all players answered this question
    jge next_turn ; If yes, move to next question
    jmp play_loop ; If no, ask next player

next_turn:
    inc EBX ; Increment to next question
    jmp turn_loop ; Continue game loop

show_scores:
    nwln ; Print blank line
    PutStr end_game ; Display "Se termino el juego"
    nwln ; Print newline
    PutStr leaderboard ; Display "====Puntuaciones===="
    nwln ; Print newline

loop_scores:
    mov EBX, 0 ; Initialize count of scores already displayed
    
find_next_max:
    mov AX, -1 ; Initialize AX to -1 (marker for "no unshown score found")
    mov EDX, -1 ; Initialize EDX to -1 (no player found yet)
    mov ECX, 0 ; Initialize player counter to 0
    
get_max_score:
    cmp ECX, [amt_players] ; Check if we've checked all players
    jge show_current_max ; If yes, display the highest score found
    
    mov SI, [scores + ECX * 2] ; Load current player's score
    
    cmp SI, -1 ; Check if score is marked as already shown (-1)
    je skip_to_next_player ; If yes, skip this player
    
    cmp EDX, -1 ; Check if we've found a player yet (EDX == -1 means no)
    jne compare_with_current_max ; If EDX != -1, compare scores
    mov AX, SI ; Take this player's score as the current maximum
    mov EDX, ECX ; Save this player's index
    jmp skip_to_next_player ; Continue to next player

compare_with_current_max:
    cmp SI, AX ; Compare new score (SI) with current max score (AX) using signed comparison
    jle skip_to_next_player ; If SI <= AX, skip this player

    mov AX, SI ; New max found, update AX with this score
    mov EDX, ECX ; Save index of this player as new max
    
skip_to_next_player:
    inc ECX ; Move to next player
    jmp get_max_score ; Continue checking scores

show_current_max:
    cmp EDX, -1 ; Check if we found any unshown player (EDX will be -1 if all shown)
    je done ; If all shown, we're done displaying leaderboard
    
    inc EBX ; Increment count of displayed scores
    PutStr player_num ; Display "Jugador #"
    mov ECX, EBX ; Load display rank into ECX
    PutLInt ECX ; Display rank number
    PutCh ' ' ; Display space
    
    push EAX ; Save the score on stack
    push EBX ; Save display rank on stack
    push EDX ; Save player index on stack

    mov ECX, EDX ; Copy player index to ECX
    mov EAX, 20 ; Load offset per player (20 bytes per name)
    imul ECX, EAX ; Multiply player index by 20 to get buffer offset
    lea EBX, [names + ECX] ; Calculate address of this player's name

    PutStr EBX ; Display player name

    pop EDX ; Restore player index
    pop EBX ; Restore display rank
    pop EAX ; Restore the score
    nwln ; Print newline
    
    PutStr score_msg ; Display "Puntuacion:"
    PutInt AX ; Display the score value
    nwln ; Print newline
    nwln ; Print another newline for spacing
    
    mov word [scores + EDX * 2], -1 ; Mark this score as shown by setting to -1
    
    cmp EBX, [amt_players] ; Check if we've displayed all players
    jge done ; If yes, we're finished
    jmp find_next_max ; If no, find and display next highest score

done:
    ret ; Return from function