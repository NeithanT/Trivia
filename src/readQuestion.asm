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
        mov [question_num], EAX ; Remember which question we want

    open_file:
        mov EAX, 5 ; Get ready to open the file
        mov EBX, file_name ; Point to the questions file
        mov ECX, 0 ; Open it just for reading
        mov EDX, 0 ; No fancy stuff needed
        int 0x80 ; Open the file

        mov [file_descriptor], EAX ; Save the file handle

    read_file:
        mov EAX, 3 ; Get ready to read
        mov EBX, [file_descriptor] ; Use our file handle
        mov ECX, buffer ; Read into our buffer
        mov EDX, 10000 ; Read a bunch of bytes
        int 0x80 ; Read the whole file
        
    start_read:
        mov ESI, buffer ; Start from the beginning
        mov ECX, 0 ; Start counting questions at 0
        mov EDX, -1 ; Use EDX to remember if we skipped the header
        jmp read_loop ; Start looking for our question

    read_loop:
        cmp byte [ESI], 0 ; Check if we're at the end
        je close_file ; If we're done, close up

        cmp byte [ESI], ':' ; Look for ':' markers
        je found_question ; Found a ':' - that's a marker

        inc ESI ; Keep going
        jmp read_loop ; Keep looking

    found_question:
        cmp EDX, -1 ; Did we skip the header yet?
        jne skip_first ; If we already did the first one
        mov EDX, 0 ; Remember we skipped the header
        inc ESI ; Skip the header marker
        jmp read_loop ; Keep looking for real questions

    skip_first:
        inc ECX ; Count this as a real question (1-based indexing)
        inc ESI ; Skip the ':' and get to the answer letter

        cmp ECX, [question_num] ; Check if this is the question we want
        jne read_loop ; If not, keep looking for the right one (exact match required)
        
        movzx EDI, byte [ESI] ; Grab the answer letter
        mov [correct_ans], DI ; Save the answer for later
        inc ESI ; Move on to the question text
        
        mov EDI, ESI ; Set up to find where the question ends

    find_end:
        cmp byte [EDI], 0 ; Check if we're at the end
        je print_question ; If we're done, we have the question

        cmp byte [EDI], ']' ; Look for the end marker ']'
        je found_end ; Found it, stop here

        inc EDI ; Keep going
        jmp find_end ; Keep looking for the end

    found_end:
        mov byte [EDI], 0 ; Mark the end of the text
        PutStr ESI ; Show the question
        
        mov byte [EDI], ']' ; Put the ']' back
        jmp close_file ; Close up shop

    print_question:
        PutStr ESI ; Show the question

    read_left:
        mov EAX, 3 ; Get ready to read more
        mov EBX, [file_descriptor] ; Use our file handle
        mov ECX, buffer ; Read into our buffer
        mov EDX, 100 ; Read a bit more if needed
        int 0x80 ; Read more

        mov ESI, buffer ; Start from the new stuff
        jmp find_end ; Keep looking for the end

    close_file:
        mov EAX, 6 ; Get ready to close
        mov EBX, [file_descriptor] ; Use our file handle
        int 0x80 ; Close the file

    end_parse:
        mov EAX, [correct_ans] ; Get the answer ready
        ret ; Send back the answer
