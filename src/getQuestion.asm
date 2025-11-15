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

    mov EAX, 5 ; gotta open the questions file
    mov EBX, file_name ; point to the filename
    mov ECX, 0 ; read-only mode
    mov EDX, 0 ; no extra flags

    int 0x80 ; fire it up


    mov EBX, EAX ; file descriptor is back
    mov EAX, 3 ; time to read some bytes
    mov ECX, buffer ; dump into buffer
    mov EDX, 100 ; read first 100 bytes, should be enough

    int 0x80 ; read it


    mov ESI, buffer ; start parsing the buffer
    mov EAX, 0 ; gonna build the number here


read_loop:

    cmp BYTE [ESI], ':' ; looking for the colon
    je read_amt ; found it, parse next
    inc ESI ; next char
    jmp read_loop ; keep going


read_amt:

    inc ESI ; skip the ':'
    cmp BYTE [ESI], '0' ; check if it's a digit
    jl end_num ; not a digit, done
    cmp BYTE [ESI], '9'
    jg end_num ; not a digit

    mov ECX, 10 ; multiply by 10
    mul CX ; shift left
    add AL, BYTE [ESI] ; add the digit
    sub EAX, '0' ; convert to number
    jmp read_amt ; next digit


end_num:

    push EAX ; save the count

    mov EAX, 6 ; close the file
    int 0x80 ; close it
    pop EAX ; get count back
    ret ; done, count in EAX

get_question:

    pusha ; save all registers
    call get_amt_questions ; how many questions total?
    mov [amt_questions], EAX ; remember that
    jmp open_file ; go open the seen file


try_again:

    mov EAX, 6 ; close the seen file first

    mov EBX, [file_descriptor] ; the fd
    int 0x80 ; close it

open_file:

    mov EAX, 5 ; open the seen questions file
    mov EBX, file_answers ; filename
    mov ECX, 0 ; read-only
    mov EDX, 0 ; no flags
    int 0x80 ; open it

    mov [file_descriptor], EAX ; save fd

read:

    mov EAX, 3 ; read the seen list

    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; into buffer
    mov EDX, 1000 ; read up to 1000 bytes
    int 0x80 ; read it


get_rand_loop:

    mov EAX, [amt_questions] ; total questions
    call get_rand ; get random index

    add EAX, 1 ; make it 1-based

    mov [current_quest], EAX ; save the pick
    ; make sure it's valid

    cmp EAX, 1
    jl get_rand_loop ; too low, retry
    cmp EAX, [amt_questions]
    jge get_rand_loop ; too high, retry

    mov ESI, buffer ; start of seen list
    mov EAX, 0 ; for parsing

    jmp check_if_question ; check if seen


next_num:
    xor EAX, EAX ; reset
    inc ESI ; next char

check_if_question:

    cmp BYTE [ESI], 0 ; end of buffer?
    je done ; not seen, good
    cmp BYTE [ESI], ',' ; end of number?
    je analyze ; compare it
    ; parse the digit
    imul EAX, EAX, 10 ; *10
    xor ECX, ECX ; clear
    mov CL, [ESI] ; get char
    sub ECX, '0' ; to number
    add EAX, ECX ; add to EAX
    inc ESI ; next
    jmp check_if_question ; continue

analyze:

    cmp EAX, [current_quest] ; is it our pick?
    je get_rand_loop ; yep, already seen, retry

    jmp next_num ; nope, check next

    
done:
    ; close the seen file
    mov EAX, 6 ; close
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; close

    mov EAX, [current_quest] ; the question
    call append_amt ; add to seen list
    call append_comma ; add comma

    popa ; restore

    mov EAX, [current_quest] ; question number
    call read_question ; read and display

    ret ; all done


