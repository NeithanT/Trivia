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
    name_prefix     db  "name:", 0
    score_prefix    db  "score:", 0
    newline         db  10, 0
    read_buffer     db  2048 dup(0)
    write_buffer    db  2048 dup(0)
    num_buffer      db  12 dup(0)
    
.UDATA
    ; Array to hold scores and names (max 14 entries: 10 existing + 4 new)
    all_scores      resw 14     ; scores (word = 2 bytes each)
    all_names       resb 280    ; names (20 bytes each, 14 entries)
    total_entries   resd 1      ; total number of score entries
    
.CODE

    global save_score

save_score:
    ; Parameters:
    ; EBX = pointer to scores array (new scores)
    ; AX = number of players (new players)
    ; EDX = pointer to names array (new names)
    
    pushad
    mov word [total_entries], 0
    
    ; Save parameters
    push EBX                    ; save scores pointer
    push EDX                    ; save names pointer
    movzx ECX, AX               ; save number of new players
    push ECX
    
    ; Step 1: Read existing scores from file
    call read_scores_from_file
    
    ; Step 2: Add new scores
    pop ECX                     ; restore number of new players
    pop EDX                     ; restore names pointer
    pop EBX                     ; restore scores pointer
    
    call add_new_scores
    
    ; Step 3: Sort all scores using insertion sort (descending)
    call insertion_sort
    
    ; Step 4: Keep only top 10
    cmp word [total_entries], 10
    jle write_scores
    mov word [total_entries], 10
    
write_scores:
    ; Step 5: Write scores back to file
    call write_scores_to_file
    
    popad
    ret

; ==================== Read scores from file ====================
read_scores_from_file:
    pushad
    
    ; Open file for reading
    mov EAX, 5
    mov EBX, file.txt
    mov ECX, 0                  ; read only
    mov EDX, 0
    int 0x80
    
    cmp EAX, 0
    jl read_done                ; file doesn't exist or error
    
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
    
    ; Parse the buffer
    mov ESI, read_buffer        ; source pointer
    mov EDI, 0                  ; entry counter
    
parse_file:
    cmp byte [ESI], 0
    je read_done
    
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
    
    ; Found "name:", now read the name
    add ESI, 5                  ; skip "name:"
    mov EBX, EDI
    imul EBX, 20                ; 20 bytes per name
    lea EBX, [all_names + EBX]
    
read_name_loop:
    lodsb
    cmp AL, 10                  ; newline
    je name_done
    cmp AL, 0
    je name_done
    mov [EBX], AL
    inc EBX
    jmp read_name_loop
    
name_done:
    mov byte [EBX], 0           ; null terminate
    
    ; Now look for "score:"
find_score:
    cmp byte [ESI], 0
    je read_done
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
    
read_score_loop:
    lodsb
    cmp AL, '0'
    jb score_done
    cmp AL, '9'
    ja score_done
    sub AL, '0'
    movzx ECX, AL
    imul EAX, 10
    add EAX, ECX
    jmp read_score_loop
    
score_done:
    mov EBX, EDI
    mov word [all_scores + EBX*2], AX
    inc EDI
    mov [total_entries], EDI
    jmp parse_file
    
skip_score_char:
    inc ESI
    jmp find_score
    
skip_char:
    inc ESI
    jmp parse_file
    
read_done:
    popad
    ret

; ==================== Add new scores ====================
add_new_scores:
    ; EBX = pointer to new scores
    ; EDX = pointer to new names
    ; ECX = number of new players
    
    pushad
    mov ESI, EBX                ; source scores
    mov EDI, EDX                ; source names
    mov ECX, ECX                ; counter
    mov EBX, [total_entries]    ; current entry index
    
add_loop:
    cmp ECX, 0
    je add_done
    
    ; Copy score
    mov AX, [ESI]
    mov word [all_scores + EBX*2], AX
    
    ; Copy name (20 bytes)
    push ECX
    push ESI
    mov ESI, EDI                ; source name
    push EBX
    imul EBX, 20
    lea ECX, [all_names + EBX]  ; destination
    pop EBX
    mov DH, 20                  ; counter
    
copy_name:
    lodsb
    mov [ECX], AL
    inc ECX
    dec DH
    jnz copy_name
    
    pop ESI
    pop ECX
    
    ; Move to next entry
    add ESI, 2                  ; next score (word)
    add EDI, 20                 ; next name
    inc EBX                     ; next entry
    dec ECX
    jmp add_loop
    
add_done:
    mov [total_entries], EBX
    popad
    ret

; ==================== Insertion Sort (descending) ====================
insertion_sort:
    pushad
    
    mov ECX, 1                  ; start from second element
    
outer_loop:
    cmp ECX, [total_entries]
    jge sort_done
    
    ; Save current element
    mov EBX, ECX
    mov AX, word [all_scores + EBX*2]   ; key score
    push EAX
    
    ; Save current name
    imul EBX, 20
    lea ESI, [all_names + EBX]
    sub EBX, EBX
    imul ECX, 20
    lea EDI, [all_names + ECX]
    
    ; Temporarily store name
    push ECX
    mov ECX, 20
    sub ESP, 20
    mov EDI, ESP
    
save_name:
    lodsb
    mov [EDI], AL
    inc EDI
    loop save_name
    
    pop ECX
    mov EBX, ECX
    mov EAX, EBX
    mov EBX, 20
    xor EDX, EDX
    div EBX                     ; back to index
    
    ; Insert into sorted portion
    mov EDX, EBX
    dec EDX                     ; j = i - 1
    
inner_loop:
    cmp EDX, 0
    jl insert_position
    
    ; Compare scores (descending, so check if previous < current)
    mov DI, word [all_scores + EDX*2]
    mov SI, word [ESP + 20]     ; key score
    cmp DI, SI
    jge insert_position         ; if prev >= current, position found
    
    ; Shift score
    mov AX, word [all_scores + EDX*2]
    mov word [all_scores + EDX*2 + 2], AX
    
    ; Shift name
    push ESI
    push EDI
    mov ESI, EDX
    imul ESI, 20
    lea ESI, [all_names + ESI]
    mov EDI, EDX
    inc EDI
    imul EDI, 20
    lea EDI, [all_names + EDI]
    push ECX
    mov ECX, 20
    rep movsb
    pop ECX
    pop EDI
    pop ESI
    
    dec EDX
    jmp inner_loop
    
insert_position:
    inc EDX
    
    ; Insert key score
    pop EAX
    mov word [all_scores + EDX*2], AX
    
    ; Insert key name
    imul EDX, 20
    lea EDI, [all_names + EDX]
    mov ESI, ESP
    push ECX
    mov ECX, 20
    rep movsb
    pop ECX
    add ESP, 20
    
    inc ECX
    jmp outer_loop
    
sort_done:
    popad
    ret

; ==================== Write scores to file ====================
write_scores_to_file:
    pushad
    
    ; Truncate file first
    mov EAX, 5
    mov EBX, file.txt
    mov ECX, 577                ; O_WRONLY | O_CREAT | O_TRUNC
    mov EDX, 0644o              ; permissions
    int 0x80
    
    mov ESI, EAX                ; file descriptor
    
    ; Close to truncate
    mov EAX, 6
    mov EBX, ESI
    int 0x80
    
    ; Build write buffer
    mov EDI, write_buffer
    mov ECX, 0                  ; entry counter
    
build_buffer:
    cmp ECX, [total_entries]
    jge buffer_done
    
    ; Write "name:"
    push ECX
    push ESI
    mov ESI, name_prefix
    
copy_name_prefix:
    lodsb
    cmp AL, 0
    je name_prefix_done
    stosb
    jmp copy_name_prefix
    
name_prefix_done:
    pop ESI
    pop ECX
    
    ; Write name
    push ECX
    push ESI
    mov EBX, ECX
    imul EBX, 20
    lea ESI, [all_names + EBX]
    
copy_name_to_buffer:
    lodsb
    cmp AL, 0
    je name_to_buffer_done
    stosb
    jmp copy_name_to_buffer
    
name_to_buffer_done:
    pop ESI
    pop ECX
    
    ; Write newline
    mov AL, 10
    stosb
    
    ; Write "score:"
    push ECX
    push ESI
    mov ESI, score_prefix
    
copy_score_prefix:
    lodsb
    cmp AL, 0
    je score_prefix_done
    stosb
    jmp copy_score_prefix
    
score_prefix_done:
    pop ESI
    pop ECX
    
    ; Convert score to string
    push ECX
    push ESI
    mov AX, word [all_scores + ECX*2]
    movzx EAX, AX
    mov ESI, num_buffer + 11
    mov byte [ESI], 0
    dec ESI
    mov EBX, 10
    
convert_score:
    xor EDX, EDX
    div EBX
    add DL, '0'
    mov [ESI], DL
    dec ESI
    test EAX, EAX
    jnz convert_score
    inc ESI
    
    ; Copy number to buffer
copy_number:
    lodsb
    cmp AL, 0
    je number_done
    stosb
    jmp copy_number
    
number_done:
    pop ESI
    pop ECX
    
    ; Write newline
    mov AL, 10
    stosb
    
    inc ECX
    jmp build_buffer
    
buffer_done:
    ; Null terminate
    mov byte [EDI], 0
    
    ; Calculate length
    mov EDX, EDI
    sub EDX, write_buffer
    
    ; Open file for writing
    mov EAX, 5
    mov EBX, file.txt
    mov ECX, 1025               ; O_WRONLY | O_APPEND
    int 0x80
    
    mov ESI, EAX                ; file descriptor
    
    ; Write buffer
    mov EAX, 4
    mov EBX, ESI
    mov ECX, write_buffer
    ; EDX already has length
    int 0x80
    
    ; Close file
    mov EAX, 6
    mov EBX, ESI
    int 0x80
    
    popad
    ret