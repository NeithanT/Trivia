%include "io.mac"

.DATA
    file_name       db "questions.txt", 0
    search_str      db "Opcion correcta:", 0
    question_num    dd 0
    file_descriptor              dd 0

.UDATA
    buffer          resb 10000
    correct_ans     resd 1

.CODE

    .STARTUP

    mov EAX, 1          ;number of question
    mov [question_num], EAX

    ; syscall to open a file
    ;                   eax     ebx                     ecx         edx
    ;open	man/ cs/	0x05	const char *filename	int flags	umode_t mode
    mov EAX, 5      ; open mode
    mov EBX, file_name
    mov ECX, 0 ; read only
    mov EDX, 0 ; no special mode
    int 0x80

    mov [file_descriptor], EAX  ;move the id of the file

    ; Syscall to read from File, the entries are:
    ;                   eax     ebx                     ecx         edx
    ;read	man/ cs/	0x03    unsigned int fd	        char *buf	size_t count
    ;read all the file basically
    mov EAX, 3          ; sys_read
    mov EBX, [file_descriptor]  ; the fd
    mov ECX, buffer ; buffer pointer
    mov EDX, 10000  ; amount of bytes
    int 0x80
    
    mov ESI, buffer     ; pointer to buffer
    mov ECX, 0          ; count the questions

read_loop:
    cmp byte [ESI], 0   ;EOF Token
    je close_file        ;End read

    cmp byte [ESI], ':' ;Check if question start
    je found_question

    inc ESI             ; go to the next char
    jmp read_loop       ; repeat

found_question:
    inc ECX
    inc ESI
    cmp ECX, [question_num]
    jl read_loop
    ; the format of the file is, that after every :, there is the correct answer
    ; it can be A, B, C, D, let's move that into a memory segment
    
    mov EDI, ESI            ;Save the answer
    mov ESI, [ESI]
    mov [correct_ans], ESI  ; Save the correct answer!
    mov ESI, EDI ; restore the pointer
    inc ESI

find_end:
    cmp byte [EDI], 0
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

close_file:
    ; Close the file
    mov EAX, 6          ; sys_close
    mov EBX, [file_descriptor]
    int 0x80

end_parse:
    .EXIT
