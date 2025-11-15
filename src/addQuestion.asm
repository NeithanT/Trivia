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
    ask_type        db 9, 9, "Que tipo de pregunta va a ser:", 0
    multi           db 9, 9, "1 - Opcion Multiple", 0
    true_false      db 9, 9, "2 - Verdadero o Falso", 0
    option          db 9, 9, "Ingrese una opcion:", 0
    invalid_opt     db 9, 9, "Opcion Invalida", 0
    ask_question    db 9, 9, "Ingresa la Pregunta: ", 0
    ask_answer      db 9, 9, "Opcion #", 0
    ask_correct     db 9, 9, "Respuesta correcta: ", 0
    ask_true_false  db 9, 9, "Es Verdadera o Falsa:", 0
    true            db 9, 9, "A) Verdadero", 0
    false           db 9, 9, "B) Falso", 0

    added           db 9, 9, "Se agrego pregunta correctamente", 0

    correct_save    db "Respuesta correcta:", 0
    true_save       db "A) Verdadero", 0
    false_save      db "B) Falso", 0

    close_question  db ']'
    double_point    db ':'
    newline         db 10

.UDATA

    question    resb 100
    answer      resb 200
    correct_ans resb 1
    small_buff  resb 5

.CODE

    extern change_count

    global add_question

add_question:
    mov EAX, 5 ; Load syscall number for open (0x05)
    mov EBX, file_name ; Point to questions.txt filename

    mov ECX, 1025 ; Set flags to 1025 (write | append mode to add at end)
    mov EDX, 0 ; No special file mode bits needed
    int 0x80 ; Execute syscall to open file in append mode

    mov [file_descriptor], EAX ; Store the returned file descriptor

    PutStr ask_type ; Prompt user for question type
    nwln ; Print newline
    jmp put_options ; Jump to display question type options

invalid:
    PutStr invalid_opt ; Display error message for invalid option
    nwln ; Print newline

put_options: 
    PutStr multi ; Display option 1: Multiple Choice
    nwln ; Print newline
    PutStr true_false ; Display option 2: True/False
    nwln ; Print newline

    PutStr option ; Prompt user to enter their choice
    GetInt AX ; Read integer choice from user into AX

    cmp AX, 1 ; Check if choice is 1 (multiple choice)
    je multiple_option ; If yes, go to multiple choice handler
    cmp AX, 2 ; Check if choice is 2 (true/false)
    je true_false_label ; If yes, go to true/false handler

    jmp invalid ; If neither, display error and loop

ask_quest:
    PutStr ask_question ; Prompt user to enter the question
    GetStr question, 100 ; Read question string into buffer (max 100 bytes)
    ret ; Return from function
    
count_chars:
    mov EAX, 0 ; Initialize character counter to 0

count_chars_loop:
    cmp BYTE [ECX], 0 ; Check if current byte is null terminator
    je count_done ; If yes, we've counted all characters
    inc ECX ; Move to next character
    inc EAX ; Increment counter
    jmp count_chars_loop ; Continue counting

count_done:
    ret ; Return with character count in EAX

multiple_option:
    call ask_quest ; Get the question from user
    mov EBX, answer ; Point to answer buffer
    mov CL, 'A' ; Initialize option letter to 'A'

multiple_loop:
    cmp CL, 'E' ; Check if we've asked all 4 options (A, B, C, D)
    je ask_correct_label ; If yes, ask for correct answer
    PutStr ask_answer ; Display "Opcion #"
    PutCh CL ; Display current option letter (A, B, C, or D)
    PutCh ':' ; Display colon
    PutCh ' ' ; Display space for readability
    GetStr EBX, 50 ; Read option text into buffer (max 50 bytes)
    inc CL ; Move to next letter (A->B, B->C, etc.)
    add EBX, 50 ; Move buffer pointer to next option storage
    jmp multiple_loop ; Continue asking for next option

invalid_correct:
    PutStr invalid_opt ; Display error message
    nwln ; Print newline

ask_correct_label:
    PutStr ask_correct ; Prompt user to enter the correct answer letter
    GetCh BL ; Read one character (A, B, C, or D) into BL
    cmp BL, 'A' ; Check if answer is 'A' (minimum valid)
    jl invalid_correct ; If less than 'A', invalid
    cmp BL, 'D' ; Check if answer is 'D' (maximum valid)
    jg invalid_correct ; If greater than 'D', invalid

write_multiple:
    mov [correct_ans], BL ; Store the correct answer letter in memory

    call write_newline ; Write newline to file

    mov ECX, correct_save ; Point to "Respuesta correcta:" string
    call count_chars ; Get length of the string (result in EAX)
    mov ECX, correct_save ; Point to string again
    mov EDX, EAX ; Move character count to EDX for syscall

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to write label

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    mov ECX, correct_ans ; Point to the correct answer letter
    mov EDX, 1 ; Write exactly 1 byte (single letter)
    int 0x80 ; Execute syscall to write answer

    call write_newline ; Write newline to file

    mov [small_buff], BYTE 'A' ; Initialize buffer with 'A'
    mov [small_buff + 1], BYTE ')' ; Add ')'
    mov [small_buff + 2], BYTE ' ' ; Add space
    mov [small_buff + 3], BYTE 0 ; Add null terminator

    mov ECX, answer ; Point to start of answers buffer

write_multiple_loop:
    cmp AL, 'E' ; Check if we've written all 4 options
    je write_done ; If yes, finish writing

    push ECX ; Save answers buffer pointer

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    mov ECX, small_buff ; Point to "X) " prefix
    mov EDX, 3 ; Write exactly 3 bytes
    int 0x80 ; Execute syscall to write option prefix

    pop ECX ; Restore answers buffer pointer
    push ECX ; Save it again for next iteration
    call count_chars ; Get length of current option answer (result in EAX)
    mov EDX, EAX ; Move character count to EDX

    pop ECX ; Restore answers buffer pointer

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to write answer text

    push ECX ; Save buffer pointer
    call write_newline ; Write newline to file
    pop ECX ; Restore buffer pointer

    add ECX, 50 ; Move to next option (each option is 50 bytes)

    mov AL, BYTE [small_buff] ; Get current letter from small_buff
    inc AL ; Increment letter (A->B, B->C, etc.)
    mov [small_buff], AL ; Store incremented letter
    
    jmp write_multiple_loop ; Continue writing next option
    
true_false_label:
    call ask_quest ; Get the question from user
    PutStr ask_true_false ; Prompt for true/false selection
    nwln ; Print newline
    PutStr true ; Display "A) Verdadero"
    nwln ; Print newline
    PutStr false ; Display "B) Falso"
    nwln ; Print newline
    jmp ask_ans_true_false ; Jump to get the correct answer

not_valid_tf:
    PutStr invalid ; Display error message (invalid reference)
    nwln ; Print newline

ask_ans_true_false:
    PutStr ask_correct ; Prompt for correct answer
    GetCh AL ; Read one character (A or B) into AL
    cmp AL, 'A' ; Check if answer is 'A' (True)
    je save_true_false ; If yes, proceed to save
    cmp AL, 'B' ; Check if answer is 'B' (False)
    je save_true_false ; If yes, proceed to save

    jmp not_valid_tf ; If neither, display error

save_true_false:
    mov [correct_ans], AL ; Store the correct answer letter

    call write_newline ; Write newline to file
 
    mov ECX, correct_save ; Point to "Respuesta correcta:" string
    call count_chars ; Get length of string (result in EAX)
    mov ECX, correct_save ; Point to string again
    mov EDX, EAX ; Move character count to EDX

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to write label

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    mov ECX, correct_ans ; Point to the correct answer letter
    mov EDX, 1 ; Write exactly 1 byte
    int 0x80 ; Execute syscall to write answer

    call write_newline ; Write newline to file

    mov ECX, question ; Point to the question text
    call count_chars ; Get length of question (result in EAX)
    mov ECX, question ; Point to question again
    mov EDX, EAX ; Move character count to EDX

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to write question

    call write_newline ; Write newline to file

    mov ECX, true_save ; Point to "A) Verdadero" string
    call count_chars ; Get length of string (result in EAX)
    mov ECX, true_save ; Point to string again
    mov EDX, EAX ; Move character count to EDX

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to write true option

    call write_newline ; Write newline to file

    mov ECX, false_save ; Point to "B) Falso" string
    call count_chars ; Get length of string (result in EAX)
    mov ECX, false_save ; Point to string again
    mov EDX, EAX ; Move character count to EDX

    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to write false option

    call write_newline ; Write newline to file

write_done:
    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    mov ECX, close_question ; Point to ']' character (question end marker)
    mov EDX, 1 ; Write exactly 1 byte
    int 0x80 ; Execute syscall to write end marker

    jmp close_file ; Jump to close file

write_newline:
    mov EAX, 4 ; Load syscall number for write (0x04)
    mov EBX, [file_descriptor] ; Get the file descriptor
    mov ECX, newline ; Point to newline character (ASCII 10)
    mov EDX, 1 ; Write exactly 1 byte
    int 0x80 ; Execute syscall to write newline
    ret ; Return from function

close_file:
    mov EAX, 6 ; Load syscall number for close (0x06)
    mov EBX, [file_descriptor] ; Get the file descriptor
    int 0x80 ; Execute syscall to close the file

done:
    call change_count ; Update the question count in questions.txt

    nwln ; Print newline
    PutStr added ; Display success message
    nwln ; Print newline
    ret ; Return from function