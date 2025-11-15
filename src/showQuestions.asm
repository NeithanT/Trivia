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
        mov EAX, 5 ; Get ready to open the file
        mov EBX, file_name ; Point to the questions file
        mov ECX, 0 ; Open it just for reading
        mov EDX, 0 ; No fancy stuff needed
        int 0x80 ; Open the file

        mov [file_descriptor], AL ; Save the file handle

        mov EAX, 3 ; Get ready to read
        mov EBX, [file_descriptor] ; Use our file handle
        mov ECX, buffer ; Read into our buffer
        mov EDX, 10000 ; Read a bunch of bytes
        int 0x80 ; Read the whole file
        
        mov [buffer + EAX], BYTE 0 ; Mark the end of what we read

        mov ESI, buffer ; Start from the beginning
        mov EDX, -1 ; Use EDX to remember if we skipped the header

    find_question:
        cmp BYTE [ESI], 0 ; Check if we're at the end
        je done ; If we're done, wrap it up

        cmp BYTE [ESI], ':' ; Look for ':' markers
        je found_delimiter ; Found a ':' - that's a marker
        inc ESI ; Keep going
        jmp find_question ; Keep looking

    found_delimiter:
        cmp EDX, -1 ; check if we skipped question
        jne find_end ; If we already did the first one, show this question
        mov EDX, 0 ; Remember we skipped the header
        inc ESI ; Skip the header marker
        jmp find_question ; Keep looking for real questions

    find_end:
        inc ESI ; Skip the ':' and get to the answer
        inc ESI ; Skip the answer letter
        inc ESI ; Skip the newline, now at the question
        mov EDI, ESI ; Set up to find where the question ends
        jmp find_end_loop ; Start looking for the end

    find_end_loop:
        inc EDI ; Keep going
        cmp BYTE [EDI], ']' ; Look for the end marker ']'
        je print ; Found it, stop here
        cmp BYTE [EDI], 0 ; Check if we're at the end
        je done ; If we're done, wrap it up
        jmp find_end_loop ; Keep looking for the end

    print:
        mov [EDI], BYTE 0 ; Mark the end of the text
        PutStr ESI ; Show the question
        mov [EDI], BYTE ']' ; Put the ']' back
        mov ESI, EDI ; Jump to where the ']' was
        inc ESI ; Skip past the ']'
        jmp find_question ; Keep going to the next question

    done:
        ret ; We're done here