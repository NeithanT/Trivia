;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/12 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac"

global file_descriptor

.DATA
    file_name       db "src/saves/questions.txt", 0
    search_str      db "Opcion correcta:", 0
    question_num    dd 0
    file_descriptor dd 0
    correct_ans     db 0

.UDATA
    buffer          resb 100

.CODE

    global read_question

    read_question:

        mov [question_num], EAX ; the wanted question to print

    open_file:
        push EBX
        push ECX
        push EDX
        ; syscall to open a file
        ;                   eax     ebx                     ecx         edx
        ;open	man/ cs/	0x05	const char *filename	int flags	umode_t mode
        mov EAX, 5      ; open mode
        mov EBX, file_name  ; pass the file/direction
        mov ECX, 0 ; read only
        mov EDX, 0 ; no special modes
        int 0x80

        mov [file_descriptor], EAX  ;move the id of the file

        ; Syscall to read from File, the entries are:
        ;                   eax     ebx                     ecx         edx
        ;read	man/ cs/	0x03    unsigned int fd	        char *buf	size_t count
        ;read all the file basically

    read_file:

        mov EAX, 3          ; sys_read
        mov EBX, [file_descriptor]  ; the fd
        mov ECX, buffer ; buffer pointer
        mov EDX, 100    ; amount of bytes
        int 0x80        ; interruption to read 100 bytes
        
    start_read:

        mov ESI, buffer     ; pointer to buffer
        mov ECX, -1         ; count the questions, start at -1 to account 
        ; for the initial : of the amount of questions in the questions.txt
        jmp read_loop

    read_loop:

        cmp byte [ESI], 0   ; EOF Token
        je close_file       ; End read

        cmp byte [ESI], ':' ; Check if question start
        je found_question

        inc ESI             ; go to the next char
        jmp read_loop       ; repeat

    found_question:

        inc ECX ; increase the question counter
        inc ESI ; go to the next byte
        cmp ECX, [question_num] ; check if it is the question we need
        jl read_loop
        ; the format of the file is, that after every :, there is the correct answer
        ; it can be A, B, C, D, let's move that into a memory segment
        
        mov EDI, [ESI]  ; Save the answer in EDI
        mov [correct_ans], EDI  ; Save the correct answer!
        inc ESI ; go to the next character, the question starts now
        ; now where are using a kind of two pointer technique
        ; ESI being LEFT, EDI being right
        mov EDI, ESI    ; copy pointer

    find_end:

        cmp byte [EDI], 0   ; this means we have read but not to the end of the question
        je print_question

        cmp byte [EDI], ']'
        je found_end

        inc EDI
        jmp find_end

    found_end:

        mov byte [EDI], 0   ;EDI points to 0
        PutStr ESI
        
        mov byte [EDI], ']' ;restore it back to end
        jmp close_file

    print_question:

        PutStr ESI

    read_left:

        mov EAX, 3          ; sys_read
        mov EBX, [file_descriptor]  ; the fd
        mov ECX, buffer ; buffer pointer
        mov EDX, 100    ; amount of bytes
        int 0x80        ; interruption to read 100 bytes

        mov ESI, buffer
        mov ESI, buffer
        jmp find_end

    close_file:
        ; Close the file
        mov EAX, 6          ; sys_close
        mov EBX, [file_descriptor]
        int 0x80

    end_parse:
        mov EAX, [correct_ans]
        ret
