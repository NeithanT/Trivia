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

    file.txt        db  "src/saves/scores.txt", 0
    no_scores_msg   db  9, "No hay puntajes registrados", 0
    scores_title    db  9, "=== TABLA DE PUNTAJES ===", 0
    name_label      db  9, "Nombre: ", 0
    score_label     db  9, "Puntaje: ", 0
    read_buffer     db  2048 dup(0)
    
.UDATA
    temp_name       resb 21     ; temporary name buffer
    
.CODE

    global show_scores

show_scores:
    pushad
    
    ; Open file for reading
    mov EAX, 5
    mov EBX, file.txt
    mov ECX, 0                  ; read only
    mov EDX, 0
    int 0x80
    
    cmp EAX, 0
    jl no_scores                ; file doesn't exist or error
    
    mov ESI, EAX                ; save file descriptor
    
    ; Read file content
    mov EAX, 3                  ; read
    mov EBX, ESI
    mov ECX, read_buffer
    mov EDX, 2048
    int 0x80
    
    mov EDI, EAX                ; save bytes read
    
    ; Close file
    mov EAX, 6
    mov EBX, ESI
    int 0x80
    
    ; Check if file is empty
    cmp EDI, 0
    je no_scores
    
    ; Display title
    nwln
    PutStr scores_title
    nwln
    nwln
    
    ; Parse and display scores
    mov ESI, read_buffer        ; source pointer
    mov ECX, 1                  ; position counter
    
display_loop:
    cmp byte [ESI], 0
    je display_done
    
    ; Look for "name:"
    cmp byte [ESI], 'n'
    jne skip_char
    cmp byte [ESI+1], 'a'
    jne skip_char
    cmp byte [ESI+2], 'm'
    jne skip_char
    cmp byte [ESI+3], 'e'
    jne skip_char
    cmp byte [ESI+4], ':'
    jne skip_char
    
    ; Found "name:", display position
    push ECX
    PutLInt ECX
    PutCh '.'
    PutCh ' '
    pop ECX
    
    ; Skip "name:" and read the name
    add ESI, 5
    mov EDI, temp_name
    
read_name:
    lodsb
    cmp AL, 10                  ; newline
    je name_displayed
    cmp AL, 0
    je name_displayed
    mov [EDI], AL
    inc EDI
    jmp read_name
    
name_displayed:
    mov byte [EDI], 0           ; null terminate
    
    ; Display name
    PutStr temp_name
    PutCh ' '
    PutCh '-'
    PutCh ' '
    
    ; Now look for "score:"
find_score:
    cmp byte [ESI], 0
    je display_done
    cmp byte [ESI], 's'
    jne skip_score_char
    cmp byte [ESI+1], 'c'
    jne skip_score_char
    cmp byte [ESI+2], 'o'
    jne skip_score_char
    cmp byte [ESI+3], 'r'
    jne skip_score_char
    cmp byte [ESI+4], 'e'
    jne skip_score_char
    cmp byte [ESI+5], ':'
    jne skip_score_char
    
    ; Found "score:", read the number
    add ESI, 6                  ; skip "score:"
    mov EAX, 0                  ; accumulator
    
read_score:
    lodsb
    cmp AL, '0'
    jb score_displayed
    cmp AL, '9'
    ja score_displayed
    sub AL, '0'
    movzx EBX, AL
    imul EAX, 10
    add EAX, EBX
    jmp read_score
    
score_displayed:
    PutLInt EAX
    nwln
    inc ECX
    jmp display_loop
    
skip_score_char:
    inc ESI
    jmp find_score
    
skip_char:
    inc ESI
    jmp display_loop
    
no_scores:
    nwln
    PutStr no_scores_msg
    nwln
    
display_done:
    popad
    ret