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
        push EAX ; Save the question number to append on stack
        
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_append ; Point to seenQuestions.txt filename
        mov ECX, 1025 ; Set flags to 1025 (write | append mode)
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open file in append mode

        mov [file_descriptor], EAX ; Store the returned file descriptor

        jmp write_question_num ; Jump to write the question number

    append_comma:
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_append ; Point to seenQuestions.txt filename
        mov ECX, 1025 ; Set flags to 1025 (write | append mode)
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open file in append mode

        mov [file_descriptor], EAX ; Store the returned file descriptor

        mov EAX, 4 ; Load syscall number for write (0x04)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, comma ; Point to comma character
        mov EDX, 1 ; Write exactly 1 byte
        int 0x80 ; Execute syscall to write comma to file

        mov EAX, 6 ; Load syscall number for close (0x06)
        mov EBX, [file_descriptor] ; Get the file descriptor
        int 0x80 ; Execute syscall to close the file
        ret ; Return from function

    change_count:
        call get_amt_questions ; Get the current question count into EAX
        inc EAX ; Increment count for the newly added question
        push EAX ; Save the new count on stack
        
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_name ; Point to questions.txt filename
        mov ECX, 2 ; Set flags to 2 (read/write mode, no truncate)
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open the file

        mov [file_descriptor], EAX ; Store the returned file descriptor

        mov ESI, buffer ; Point to start of buffer
        mov EAX, 0 ; Initialize EAX as accumulator

    read_loop:
        mov EAX, 3 ; Load syscall number for read (0x03)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to the buffer for file contents
        mov EDX, 1 ; Read exactly 1 byte
        int 0x80 ; Execute syscall to read one character
        
        cmp BYTE [buffer], ':' ; Check if current byte is ':' (count delimiter)
        je write_count ; If ':' found, start writing the new count
        jmp read_loop ; Continue reading until ':' is found

    write_count:
        xor EBX, EBX ; Clear EBX (will be digit counter)
        xor EDX, EDX ; Clear EDX
        pop EAX ; Restore the new count from stack
        
        jmp convert_string_loop ; Jump to convert number to ASCII string

    convert_string_loop:
        xor EDX, EDX ; Clear EDX before division
        mov ECX, 10 ; Load 10 for division (for base-10 conversion)
        div ECX ; Divide EAX by 10, quotient in EAX, remainder in EDX

        add DL, '0' ; Convert remainder to ASCII digit by adding '0'
        mov [buffer + EBX], DL ; Store ASCII digit in buffer
        inc EBX ; Increment digit counter
        cmp EAX, 0 ; Check if quotient is 0 (all digits processed)
        je exchange ; If 0, begin reversing the digits
        jmp convert_string_loop ; Continue processing next digit

    exchange:
        mov [len], EBX ; Store the number of digits in len
        mov EAX, EBX ; Copy digit count to EAX
        xor EDX, EDX ; Clear EDX
        mov ECX, 2 ; Load 2 for division (for finding middle point)
        div ECX ; Divide by 2 to find middle

        mov ESI, [len] ; Load digit count into ESI
        dec ESI ; Decrement to get last index (since 0-based)
        mov EDI, 0 ; Initialize left pointer to start (0)

    exchange_loop:
        cmp EAX, 0 ; Check if we've swapped enough pairs (EAX is half the length)
        je write_number ; If 0, all digits are now in correct order
        
        mov BL, [buffer + ESI] ; Load rightmost unconverted digit
        mov DL, [buffer + EDI] ; Load leftmost unconverted digit
        xchg BL, DL ; Exchange the two digits
        mov [buffer + ESI], BL ; Store swapped right digit
        mov [buffer + EDI], DL ; Store swapped left digit
        inc EDI ; Move left pointer right
        dec ESI ; Move right pointer left
        dec EAX ; Decrement iteration counter
        jmp exchange_loop ; Continue swapping

    write_number:
        mov EAX, 4 ; Load syscall number for write (0x04)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to the buffer with ASCII digits
        mov EDX, [len] ; Write exactly [len] bytes (number of digits)
        int 0x80 ; Execute syscall to write count to file

        mov EAX, 6 ; Load syscall number for close (0x06)
        mov EBX, [file_descriptor] ; Get the file descriptor
        int 0x80 ; Execute syscall to close the file

        ret ; Return from function

    write_question_num:
        ; Convert question number from stack to ASCII string and write
        pop EAX ; Get the question number to write
        
        xor EBX, EBX ; Clear digit counter
        
    convert_to_string:
        xor EDX, EDX ; Clear EDX before division
        mov ECX, 10 ; Load 10 for division (for base-10 conversion)
        div ECX ; Divide EAX by 10, remainder in EDX
        
        add DL, '0' ; Convert remainder to ASCII digit
        mov [buffer + EBX], DL ; Store digit in buffer
        inc EBX ; Increment digit counter
        cmp EAX, 0 ; Check if all digits are processed
        je reverse_string ; If 0, reverse the string
        jmp convert_to_string ; Continue processing
        
    reverse_string:
        mov [len], EBX ; Store digit count
        mov ESI, [len] ; Load digit count
        dec ESI ; Get last index
        mov EDI, 0 ; Initialize left pointer
        
    reverse_loop:
        cmp ESI, EDI ; Check if we've reversed all digits
        jle write_to_file ; If SI <= DI, reversing is complete
        
        mov CL, [buffer + ESI] ; Load right digit
        mov AL, [buffer + EDI] ; Load left digit
        mov [buffer + ESI], AL ; Store swapped left to right
        mov [buffer + EDI], CL ; Store swapped right to left
        dec ESI ; Move right pointer left
        inc EDI ; Move left pointer right
        jmp reverse_loop ; Continue reversing
        
    write_to_file:
        mov EAX, 4 ; Load syscall number for write (0x04)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to buffer with ASCII digits
        mov EDX, [len] ; Write exactly [len] bytes
        int 0x80 ; Execute syscall to write number to file
        
        mov EAX, 6 ; Load syscall number for close (0x06)
        mov EBX, [file_descriptor] ; Get the file descriptor
        int 0x80 ; Execute syscall to close the file
        ret ; Return from function