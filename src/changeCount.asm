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

    file_descriptor dd 0
    file_name       db "src/saves/questions.txt", 0
    file_append     db "src/saves/seenQuestions.txt", 0
    len             dd 0
    comma           db ','

.UDATA

    buffer          resb 100
    num             resb 10

.CODE

    extern get_amt_questions

    global change_count
    global append_amt
    global append_comma

append_amt:

    push EAX ; save the question number


    mov EAX, 5 ; time to open the file
    mov EBX, file_append ; point to seenQuestions.txt

    mov ECX, 1025 ; append mode
    mov EDX, 0 ; no special flags
    int 0x80 ; open it

    mov [file_descriptor], EAX ; save fd

    jmp write_question_num ; go write the number

append_comma:

    mov EAX, 5 ; open the file
    mov EBX, file_append ; seenQuestions.txt

    mov ECX, 1025 ; append mode
    mov EDX, 0 ; no flags
    int 0x80 ; open

    mov [file_descriptor], EAX ; save fd

    mov EAX, 4 ; write syscall
    mov EBX, [file_descriptor] ; fd
    mov ECX, comma ; comma char
    mov EDX, 1 ; 1 byte
    int 0x80 ; write comma

    mov EAX, 6 ; close
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; close
    ret

change_count:

    call get_amt_questions ; get current count
    inc EAX ; add one for new question
    push EAX ; save new count

    mov EAX, 5 ; open questions.txt
    mov EBX, file_name ; filename

    mov ECX, 2 ; read/write mode
    mov EDX, 0 ; no flags
    int 0x80 ; open

    mov [file_descriptor], EAX ; save fd

    mov ESI, buffer ; buffer start
    mov EAX, 0 ; accumulator

read_loop:

    mov EAX, 3 ; read syscall
    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; buffer
    mov EDX, 1 ; 1 byte
    int 0x80 ; read char

    cmp BYTE [buffer], ':' ; is it ':'?
    je write_count ; yep, write new count
    jmp read_loop ; keep reading

write_count:

    xor EBX, EBX ; clear digit counter
    xor EDX, EDX ; clear
    pop EAX ; get new count

    jmp convert_string_loop ; convert to string

convert_string_loop:

    xor EDX, EDX ; clear for div
    mov ECX, 10 ; base 10
    div ECX ; divide

    add DL, '0' ; to ascii
    mov [buffer + EBX], DL ; store digit
    inc EBX ; next
    cmp EAX, 0 ; done?
    je exchange ; yep, reverse
    jmp convert_string_loop ; next digit

exchange:

    mov [len], EBX ; save length
    mov EAX, EBX ; copy
    xor EDX, EDX ; clear
    mov ECX, 2 ; half
    div ECX ; find middle

    mov ESI, [len] ; length
    dec ESI ; last index
    mov EDI, 0 ; start

exchange_loop:

    cmp EAX, 0 ; done swapping?
    je write_number ; yep

    mov BL, [buffer + ESI] ; right digit
    mov DL, [buffer + EDI] ; left digit
    xchg BL, DL ; swap
    mov [buffer + ESI], BL ; store
    mov [buffer + EDI], DL ; store
    inc EDI ; move left
    dec ESI ; move right
    dec EAX ; count down
    jmp exchange_loop ; next

write_number:

    mov EAX, 4 ; write
    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; digits
    mov EDX, [len] ; length
    int 0x80 ; write

    mov EAX, 6 ; close
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; close

    ret

write_question_num:

    pop EAX ; get question number

    xor EBX, EBX ; digit counter

convert_to_string:

    xor EDX, EDX ; clear
    mov ECX, 10 ; base 10
    div ECX ; divide

    add DL, '0' ; ascii
    mov [buffer + EBX], DL ; store
    inc EBX ; next
    cmp EAX, 0 ; done?
    je reverse_string ; yep
    jmp convert_to_string ; next

reverse_string:

    mov [len], EBX ; length
    mov ESI, [len] ; length
    dec ESI ; last
    mov EDI, 0 ; start

reverse_loop:

    cmp ESI, EDI ; crossed?
    jle write_to_file ; done

    mov CL, [buffer + ESI] ; right
    mov AL, [buffer + EDI] ; left
    mov [buffer + ESI], AL ; swap
    mov [buffer + EDI], CL ; swap
    dec ESI ; move
    inc EDI ; move
    jmp reverse_loop ; next

write_to_file:

    mov EAX, 4 ; write
    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; digits
    mov EDX, [len] ; length
    int 0x80 ; write

    mov EAX, 6 ; close
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; close
    ret