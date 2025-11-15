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
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_name ; Point to questions.txt filename
        mov ECX, 0 ; Set flags to 0 for read-only access
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open the file

        mov EBX, EAX ; Move the returned file descriptor from EAX to EBX
        mov EAX, 3 ; Load syscall number for read (0x03)
        mov ECX, buffer ; Point to the buffer for file contents
        mov EDX, 100 ; Read only first 100 bytes (enough for question count)
        int 0x80 ; Execute syscall to read from file

        mov ESI, buffer ; Point to start of buffer
        mov EAX, 0 ; Initialize EAX as accumulator for the number

    read_loop:
        cmp BYTE [ESI], ':' ; Look for ':' delimiter that marks question count
        je read_amt ; If found, start parsing the number
        inc ESI ; Move to next character
        jmp read_loop ; Continue searching

    read_amt:
        inc ESI ; Move past the ':' to the first digit
        cmp BYTE [ESI], '0' ; Check if current byte is less than '0'
        jl end_num ; If so, we've finished reading the number
        cmp BYTE [ESI], '9' ; Check if current byte is greater than '9'
        jg end_num ; If so, we've finished reading the number
        mov ECX, 10 ; Load 10 for multiplication
        mul CX ; Multiply EAX by 10 (shift digits left)
        add AL, BYTE [ESI] ; Add the ASCII character to AL
        sub EAX, '0' ; Convert ASCII digit to numeric value by subtracting '0'
        jmp read_amt ; Continue reading next digit

    end_num:
        push EAX ; Save the question count on stack
        mov EAX, 6 ; Load syscall number for close (0x06)
        int 0x80 ; Execute syscall to close the file
        pop EAX ; Restore the question count to EAX
        ret ; Return from function with question count in EAX

    get_question:
        pusha ; Save all general-purpose registers on stack
        call get_amt_questions ; Get total question count (result in EAX)
        mov [amt_questions], EAX ; Store the question count in memory

        jmp open_file ; Jump to open the seenQuestions.txt file

    try_again:
        mov EAX, 6 ; Load syscall number for close (0x06)
        int 0x80 ; Execute syscall to close the file

    open_file:
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_answers ; Point to seenQuestions.txt filename
        mov ECX, 0 ; Set flags to 0 for read-only access
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open the file

        mov [file_descriptor], EAX ; Store the returned file descriptor

    read:
        mov EAX, 3 ; Load syscall number for read (0x03)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to the buffer for file contents
        mov EDX, 1000 ; Read up to 1000 bytes from file
        int 0x80 ; Execute syscall to read from file

    get_rand_loop:
        mov EAX, [amt_questions] ; Load the question count
        call get_rand ; Generate random number from 0 to count-1 (result in EAX)
        mov [current_quest], EAX ; Store the randomly selected question number
        
        mov ESI, buffer ; Point to start of buffer (list of seen questions)
        mov EAX, 0 ; Initialize EAX as accumulator for parsing numbers

        jmp check_if_question ; Begin checking if this question was already shown

    next_num:
        mov EAX, 0 ; Reset number accumulator for next number
        inc ESI ; Move to next character in buffer

    check_if_question:
        cmp BYTE [ESI], 0 ; Check if we reached end of buffer (null terminator)
        je done ; If at end, the question hasn't been seen yet
        cmp BYTE [ESI], ',' ; Check if current character is a comma delimiter
        je analyze ; If comma found, compare the parsed number with selected question

        imul EAX, 10 ; Multiply accumulator by 10 to shift digits left
        add AL, BYTE [ESI] ; Add current ASCII character to AL
        sub EAX, '0' ; Convert ASCII digit to numeric value
        inc ESI ; Move to next character
        jmp check_if_question ; Continue parsing next digit

    analyze:
        cmp EAX, [current_quest] ; Compare parsed number with the randomly selected question
        je get_rand_loop ; If equal, question already seen, get another random number

        jmp next_num ; Move to next comma-separated number in the list
        
    done:
        mov EAX, [current_quest] ; Load the selected question number into EAX
        call append_amt ; Append this question number to seenQuestions.txt
        call append_comma ; Append a comma delimiter
        popa ; Restore all saved general-purpose registers

        mov EAX, [current_quest] ; Load the selected question number into EAX
        call read_question ; Read and display the question from questions.txt
        ret ; Return from function

