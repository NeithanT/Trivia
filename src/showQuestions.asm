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
    file_name       db  "src/saves/questions.txt", 0
    file_descriptor db 0
    
.UDATA
    buffer      resb 10000

.CODE

    global show_quest

    show_quest:
        mov EAX, 5 ; Load syscall number for open (0x05)
        mov EBX, file_name ; Point to questions.txt filename
        mov ECX, 0 ; Set flags to 0 for read-only access
        mov EDX, 0 ; No special file mode bits needed
        int 0x80 ; Execute syscall to open the file

        mov [file_descriptor], AL ; Store low byte of file descriptor

        mov EAX, 3 ; Load syscall number for read (0x03)
        mov EBX, [file_descriptor] ; Get the file descriptor
        mov ECX, buffer ; Point to the buffer for file contents
        mov EDX, 10000 ; Read up to 10000 bytes from file
        int 0x80 ; Execute syscall to read entire file into buffer
        
        mov [buffer + EAX], BYTE 0 ; Null-terminate the buffer at position EAX (bytes read)

        mov ESI, buffer ; Point to start of buffer

    find_question:
        cmp BYTE [ESI], 0 ; Check if we reached end of buffer (null terminator)
        je done ; If at end, display is complete

        cmp BYTE [ESI], ':' ; Check if current character is ':' (question delimiter)
        je find_end ; If ':' found, we found a question to display
        inc ESI ; Move to next character
        jmp find_question ; Continue searching

    find_end:
        inc ESI ; Move past ':', now at the correct answer character
        inc ESI ; Move past answer, now at newline character
        inc ESI ; Move past newline, now at the start of question '['
        mov EDI, ESI ; Copy pointer to EDI for finding the end of question
        jmp find_end_loop ; Begin searching for end marker

    find_end_loop:
        inc EDI ; Move to next character
        cmp BYTE [EDI], ']' ; Check if current character is ']' (question end marker)
        je print ; If found, we've reached the end of this question
        cmp BYTE [EDI], 0 ; Check if we reached end of buffer (null terminator)
        je done ; If at end, something is wrong with format but exit
        jmp find_end_loop ; Continue searching for end marker

    print:
        mov [EDI], BYTE 0 ; Replace ']' with null terminator to end string
        PutStr ESI ; Display the question text
        mov [EDI], BYTE ']' ; Restore the ']' character back to original
        mov ESI, EDI ; Move to the position of ']'
        inc ESI ; Move past ']' to next character
        jmp find_question ; Continue to find and display next question

    done:
        ret ; Return from function