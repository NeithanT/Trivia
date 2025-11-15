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

    file_name       db "src/saves/questions.txt", 0
    file_answers    db "src/saves/seenQuestions.txt", 0
    file_descriptor dd 0
    amt_questions   dd 0
    current_quest   dd 0
    
.UDATA

    buffer          resb 1000


.CODE

    extern read_question
    extern get_rand
    extern append_amt
    extern append_comma

    global get_question
    global get_amt_questions
    
    get_amt_questions:

    mov EAX, 5 ; syscall open (0x05) - open the file
    mov EBX, file_name ; point EBX at questions.txt (filename)
    mov ECX, 0 ; flags=0 -> read-only mode
    mov EDX, 0 ; no special mode flags
    int 0x80 ; call kernel to open the file

    mov EBX, EAX ; file descriptor back in EBX
    mov EAX, 3 ; syscall read (0x03) - start reading
    mov ECX, buffer ; buffer where we dump the file
    mov EDX, 100 ; read first 100 bytes (should hold the count)
        int 0x80 ; Execute syscall to read from file

    mov ESI, buffer ; start scanning from buffer start
    mov EAX, 0 ; clear EAX - we'll build the number here

    read_loop:

    cmp BYTE [ESI], ':' ; searching for ':' - that's where the count lives
    je read_amt ; found it? let's read the number next
    inc ESI ; skip to next char
        jmp read_loop ; Continue searching

    read_amt:
    inc ESI ; move past ':' to the first digit
    cmp BYTE [ESI], '0' ; is the byte a digit? less than '0' stops parsing
    jl end_num ; not a digit? we're done reading the number
    cmp BYTE [ESI], '9' ; greater than '9' also stops parsing
    jg end_num ; not a digit? end the number parsing
    mov ECX, 10 ; use 10 to shift the digits left
    mul CX ; EAX = EAX * 10
    add AL, BYTE [ESI] ; add ascii digit
    sub EAX, '0' ; ascii -> numeric
        jmp read_amt ; Continue reading next digit

    end_num:
    push EAX ; save the count on the stack
    mov EAX, 6 ; syscall close (0x06)
    int 0x80 ; close the file descriptor
    pop EAX ; pop the count back into EAX
        ret ; Return from function with question count in EAX

    get_question:
    
    pusha ; save registers
    call get_amt_questions ; ask how many questions we have
    mov [amt_questions], EAX ; stash the question count away

    jmp open_file ; next: open the seen list file

    try_again:
    mov EAX, 6 ; syscall close - close it if we try again
    mov EBX, [file_descriptor] ; the descriptor we want to close
    int 0x80 ; Execute syscall to close the file

    open_file:
    mov EAX, 5 ; syscall open - open seenQuestions
    mov EBX, file_answers ; filename for the seen list
    mov ECX, 0 ; read-only flags
    mov EDX, 0 ; no special modes
        int 0x80 ; Execute syscall to open the file

    mov [file_descriptor], EAX ; save the fd - we'll use it

    read:
    mov EAX, 3 ; syscall read - read the seen list
    mov EBX, [file_descriptor] ; fd for the seen list file
    mov ECX, buffer ; buffer to put the seen list
    mov EDX, 1000 ; read a chunk (up to 1000 bytes)
        int 0x80 ; Execute syscall to read from file

    get_rand_loop:
    mov EAX, [amt_questions] ; how many total questions are there
    call get_rand ; grab a random index in the range
    add EAX, 1 ; Convert 0-based index to 1-based (file uses 1-based indexing)
    mov [current_quest], EAX ; remember this pick
        
    ; quick sanity check - make sure this pick is legit
    cmp EAX, 1 ; is it less than 1? (shouldn't be, now 1-based)
    jl get_rand_loop ; nope, try again
    cmp EAX, [amt_questions] ; check if it's within the count
    jge get_rand_loop ; if out of range, spin again
        
    mov ESI, buffer ; start scanning the list of seen questions
    mov EAX, 0 ; clear EAX - we'll parse a number now

    jmp check_if_question ; let's see if we've already shown it

    next_num:
    xor EAX, EAX    ; clear EAX - start parsing next number
    inc ESI ; go to the next char in the buffer

    check_if_question:
    cmp BYTE [ESI], 0 ; hit the end? no seen match found
    je done ; end of the list, that means it's fresh
    cmp BYTE [ESI], ',' ; comma? we finished a number
    je analyze ; time to compare the parsed number

    ; Parse a digit: EAX = EAX * 10 + digit
    imul EAX, EAX, 10    ; shift digits left (EAX *= 10)
    xor ECX, ECX          ; clear ECX so only CL gets set next
    mov CL, [ESI]        ; put ascii char in CL
    sub ECX, '0'    ; ascii -> number
    add EAX, ECX    ; add the digit into EAX
        
    inc ESI ; move to next char
    jmp check_if_question ; keep parsing if the number's not ended

    analyze:
    cmp EAX, [current_quest] ; does this seen number match our pick?
    je get_rand_loop ; yeah, already seen—reroll and try again

    jmp next_num ; nope, check the next number in the list
        
    done:
    ; close the seen list file now that we're done reading
    mov EAX, 6 ; syscall close - clean up
    mov EBX, [file_descriptor] ; the descriptor we opened earlier
    int 0x80 ; call kernel to close the file
        
    mov EAX, [current_quest] ; put the selected question back into EAX
    call append_amt ; append this pick to the seen list
    call append_comma ; add a comma after it
    popa ; pop regs back to normal

    mov EAX, [current_quest] ; back to EAX with the chosen number
    call read_question ; read and show the question to the players
        ret ; Return from function

