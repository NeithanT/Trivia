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

    mov [question_num], EAX ; remember which question

open_file:

    mov EAX, 5 ; open the file
    mov EBX, file_name ; questions.txt
    mov ECX, 0 ; read-only
    mov EDX, 0 ; no flags
    int 0x80 ; open it

    mov [file_descriptor], EAX ; save fd

read_file:

    mov EAX, 3 ; read
    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; into buffer
    mov EDX, 10000 ; read a lot
    int 0x80 ; read file
    
start_read:

    mov ESI, buffer ; start at buffer
    mov ECX, 0 ; question count 0
    mov EDX, -1 ; header skip flag
    jmp read_loop ; start loop

read_loop:

    cmp byte [ESI], 0 ; end of file?
    je close_file ; yep, done

    cmp byte [ESI], ':' ; found ':' ?
    je found_question ; yep

    inc ESI ; next char
    jmp read_loop ; continue

found_question:

    cmp EDX, -1 ; skipped header?
    jne skip_first ; already did
    mov EDX, 0 ; mark skipped
    inc ESI ; skip header
    jmp read_loop ; continue

skip_first:

    inc ECX ; count question
    inc ESI ; to answer letter

    cmp ECX, [question_num] ; is this the one?
    jne read_loop ; nope
    
    movzx EDI, byte [ESI] ; get answer
    mov [correct_ans], DI ; save it
    inc ESI ; to question text
    
    mov EDI, ESI ; find end

find_end:

    cmp byte [EDI], 0 ; end?
    je print_question ; yep

    cmp byte [EDI], ']' ; end marker?
    je found_end ; yep

    inc EDI ; next
    jmp find_end ; continue

found_end:

    mov byte [EDI], 0 ; null terminate
    PutStr ESI ; print question
    
    mov byte [EDI], ']' ; restore
    jmp close_file ; done

print_question:

    PutStr ESI ; print it

read_left:

    mov EAX, 3 ; read more
    mov EBX, [file_descriptor] ; fd
    mov ECX, buffer ; buffer
    mov EDX, 100 ; more bytes
    int 0x80 ; read

    mov ESI, buffer ; new start
    jmp find_end ; find end

close_file:

    mov EAX, 6 ; close
    mov EBX, [file_descriptor] ; fd
    int 0x80 ; close

end_parse:

    mov EAX, [correct_ans] ; return answer
    ret
