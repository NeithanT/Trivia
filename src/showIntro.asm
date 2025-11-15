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

    file_name   db "src/saves/intro.txt", 0
    file_size   dd 1200
.UDATA

    buffer  resb 1200

.CODE

    global show_intro

    show_intro:

        ; Syscall to open File, in the linux documentation the entries are:
        ;                   eax     ebx                     ecx         edx
        ;open	man/ cs/	0x05	const char *filename	int flags	umode_t mode

        mov EAX, 5      ; Identifier for eax
        mov EBX, file_name  ; the filename
        mov ECX, 0  ; 0 for read
        mov EDX, 0  ; no extra modes
        int 0x80    ; syscall with the 0x80 interrupt for linux
        
        ; Syscall to read from File, in the linux documentation the entries are:
        ;                   eax     ebx                     ecx         edx
        ;read	man/ cs/	0x03    unsigned int fd	        char *buf	size_t count

        ; Syscalls return to EAX for some strange reason
        ; So the File Descriptor is now in EAX
        mov EBX, EAX    ; move the file descriptor to EBX
        mov EAX, 3      ; read syscall
        mov ECX, buffer ; pointer to the buffer
        mov EDX, [file_size]   ; read everything pretty much
        int 0x80

        PutStr buffer   ; print the intro

    done:

        mov EAX, 6  ; close file !
        int 0x80

        ret
    