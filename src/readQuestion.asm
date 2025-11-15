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
    search_str      db "Opcion correcta:", 0
    question_num    dd 0
    file_descriptor dd 0
    correct_ans     db 0

.UDATA
    buffer          resb 10000

.CODE

    global read_question

    read_question:
        mov [question_num], EAX ; Store the requested question number

    open_file:
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_name ; Point to questions.txt filename
        mov ECX, 0 ; Set flags to 0 for read-only access
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open the file

        mov [file_descriptor], EAX ; Store the returned file descriptor

    read_file:
        mov EAX, 3 ; Load syscall number for read (0x03)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to the buffer for file contents
        mov EDX, 10000 ; Read up to 10000 bytes from file
        int 0x80 ; Execute syscall to read entire file into buffer
        
    start_read:
        mov ESI, buffer ; Point to start of buffer
        mov ECX, -1 ; Initialize question counter to -1 (accounts for initial ':')
        jmp read_loop ; Begin searching for the requested question

    read_loop:
        cmp byte [ESI], 0 ; Check if we reached end of buffer (null terminator)
        je close_file ; If at end, close file (something went wrong)

        cmp byte [ESI], ':' ; Check if current character is ':' (question delimiter)
        je found_question ; If ':' found, we found a question boundary

        inc ESI ; Move to next character
        jmp read_loop ; Continue searching

    found_question:
        inc ECX ; Increment question counter
        inc ESI ; Move past ':' to the correct answer character

        cmp ECX, [question_num] ; Compare current question index with requested question
        jl read_loop ; If less than requested, continue searching for next question
        
        mov EDI, [ESI] ; Load the correct answer character into EDI
        mov [correct_ans], EDI ; Save the correct answer character in memory
        inc ESI ; Move past answer character to the question text
        
        mov EDI, ESI ; Copy current pointer to EDI for finding end of question

    find_end:
        cmp byte [EDI], 0 ; Check if we reached end of buffer (null terminator)
        je print_question ; If at end, we've found all text for this question

        cmp byte [EDI], ']' ; Check if we reached the question end marker ']'
        je found_end ; If found, truncate the string here

        inc EDI ; Move to next character
        jmp find_end ; Continue searching for end marker

    found_end:
        mov byte [EDI], 0 ; Replace ']' with null terminator to end string
        PutStr ESI ; Display the question text
        
        mov byte [EDI], ']' ; Restore the ']' character back to original position
        jmp close_file ; Jump to close file

    print_question:
        PutStr ESI ; Display the question text

    read_left:
        mov EAX, 3 ; Load syscall number for read (0x03)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to the buffer for file contents
        mov EDX, 100 ; Read up to 100 more bytes (if question was cut off)
        int 0x80 ; Execute syscall to read from file

        mov ESI, buffer ; Point to start of newly read buffer
        mov ESI, buffer ; Duplicate (redundant but kept from original)
        jmp find_end ; Continue finding the end of the question

    close_file:
        mov EAX, 6 ; Load syscall number for close (0x06)
        mov EBX, [file_descriptor] ; Get the file descriptor
        int 0x80 ; Execute syscall to close the file

    end_parse:
        mov EAX, [correct_ans] ; Load the correct answer character into EAX
        ret ; Return from function with correct answer in EAX
