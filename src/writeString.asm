;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Proyecto #01---------------------------
;---------Neithan Vargas Vargas, carne: 2025149384----------
;---------Fabricio Hernandez, carne: 2025106763-------------
;---2025/11/12 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac"

.DATA

    file.txt    db  "src/saves/scores.txt", 0
    num_buffer  db  12 dup(0)
    read_buffer db  1024 dup(0)
    result      dd  0
    
.CODE

    global write_number
    global read_number


    write_number:

        pushad
        ; Convert EAX to string in num_buffer
        mov edi, num_buffer + 11
        mov byte [edi], 0  ; null terminator
        dec edi
        mov ecx, 10
        mov ebx, eax  ; save original
        test eax, eax
        jz zero_case

    convert_loop:
        xor edx, edx
        div ecx
        add dl, '0'
        mov [edi], dl
        dec edi
        test eax, eax
        jnz convert_loop
        inc edi
        jmp write_to_file

    zero_case:
        mov byte [edi], '0'
        inc edi

    write_to_file:
        ; Calculate length
        mov edx, num_buffer + 11
        sub edx, edi
        ; Open file
        mov EAX, 5
        mov EBX, file.txt
        mov ECX, 1025  ; append + write
        mov EDX, 0
        int 0x80
        ; Write
        mov EBX, EAX  ; fd
        mov EAX, 4
        mov ECX, edi
        ; edx already has length
        int 0x80
        ; Close
        mov EAX, 6
        int 0x80
        popad
        ret

    read_number:
        ; Assumes n in EBX (1-based index)
        pushad
        mov dword [result], 0
        ; Open file for reading
        mov EAX, 5
        mov EBX, file.txt
        mov ECX, 0  ; read only
        mov EDX, 0
        int 0x80
        mov ESI, EAX  ; fd
        mov EAX, 3  ; read
        mov ECX, read_buffer
        mov EDX, 1024
        int 0x80
        ; Close file
        mov EAX, 6
        int 0x80
        ; Parse
        mov ESI, read_buffer
        mov ECX, 0  ; number counter
        mov EAX, 0  ; current number

    parse_loop:
        lodsb
        cmp AL, 0
        je end_parse
        cmp AL, 10  ; newline
        je check_number
        cmp AL, '0'
        jb parse_loop
        cmp AL, '9'
        ja parse_loop
        sub AL, '0'
        movzx EDX, AL
        imul EAX, 10
        add EAX, EDX
        jmp parse_loop

    check_number:
        inc ECX
        cmp ECX, EBX
        jne reset_current
        mov [result], EAX

    reset_current:
        mov EAX, 0
        jmp parse_loop

    end_parse:
        cmp EAX, 0
        je done
        inc ECX
        cmp ECX, EBX
        jne done
        mov [result], EAX
        
    done:
        mov EAX, [result]
        popad
        ret