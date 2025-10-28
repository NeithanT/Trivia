;----------Instituto Tecnológico de Costa Rica--------------
;----------Campus Tecnológico Central Cartago---------------
;---------Escuela de Ingeniería en Computación--------------
;-------Curso IC-3101 Arquitectura de Computadoras----------
;--------------------Tarea #03------------------------------
;---------Neithan Vargas Vargas, Carné: 2025149384----------
;---2025/10/19 , II Periodo, Profesor: MS.c Esteban Arias---

%include "io.mac" ; Incluir macros para entrada y salida de datos

.DATA

    mode_msg    db "Seleccione el modo", 0
    mode_prompt db "Modos: 1- con distincion de mayuscula 2- sin distincion: ", 0
    msg_prompt  db "Ingrese el texto[Ctr+D para salir]: ", 0
    space_msg   db "espacios=", 0
    newline_msg db "enters=", 0 
    tab_msg     db "tabs=", 0
    eof_msg     db "EOF Encontrado", 0
    error_msg   db "Opcion invalida", 0
    char_output db ": ", 0
    
.UDATA
    input_char  resb 1
    buffer      resb 256
    char_counts resb 256
    buffer_len  resd 1
    mode        resd 1

.CODE

    .STARTUP
        mov ESI, 0              ; Inicializa el contador del buffer en 0
        PutStr msg_prompt       ; Muestra el mensaje para ingresar texto
        mov EBX, 0              ; 0 para stdin
        mov ECX, input_char     ; Apunta a guardar en input
        mov EDX, 1              ; buffer len, solo 1 char
        

    read_loop:
        mov EAX, 3              ; Indicar un sys_read
        int 0x80                ; syscall en IA 32, 80 viene de 8086
        
        cmp EAX, 0              ; Verifica si se alcanzó EOF
        je select_mode          ; Si se alcanzó EOF, salte
        
        mov AL, [input_char]    ; Carga el carácter leído en AL
        mov BYTE [buffer + ESI], AL ; Almacena el carácter en el buffer
        
        inc ESI                 ; Ir al siguiente caracter
        cmp ESI, 256            ; size del buffer
        jge select_mode         ; si se llena el buffer
        
        jmp read_loop ; Vuelve a leer otro carácter

    select_mode:
        mov [buffer_len], ESI   ; Guarda la longitud del buffer
        nwln                    ; separar para seleccionar modo
        PutStr eof_msg          ; Muestra el mensaje de EOF encontrado
        nwln                    ; separar
        PutStr mode_msg         ; Muestra el mensaje para seleccionar el modo
        nwln                    ; separar \n
        jmp select_mode_loop    ; Salta al bucle para seleccionar el modo


    select_mode_loop:
        PutStr mode_prompt      ; Muestra las opciones de modo
        GetInt AX               ; Lee la opción seleccionada
        mov [mode], EAX         ; Almacena la opción seleccionada
        cmp EAX, 1              ; Compara si es el modo 1
        je count_chars          ; Si es el modo 1, salta a contar caracteres
        cmp EAX, 2              ; Compara si es el modo 2
        je convert_capital      ; Si es el modo 2, salta a convertir a minúsculas
        jmp error_tag           ; Si no es válido, salta a mostrar error

    error_tag:
        PutStr error_msg    ; Muestra el mensaje de error
        nwln                ; separa
        jmp select_mode_loop ; Vuelve a mostrar las opciones de modo

    convert_capital:
        mov ESI, 0 ; caso 2 sin distincion, iniciar buffer

    convert_capital_loop:
        cmp ESI, [buffer_len]   ; Compara si se alcanzó el final del buffer
        jge count_chars         ; salte a contar chars
        
        mov AL, [buffer + ESI]  ; Carga el carácter actual
        cmp AL, 'A'             ; Compara si es mayus
        jl skip_convert         ; si no, siguiente char
        cmp AL, 'Z'             ; Compara si es mayor que 'Z'
        jg skip_convert         ; Si es mayor que 'Z', salta
        ; Osea, que este en el rango ['A','Z']
        add AL, 32 ; Convierte a minus sumando 32
        mov [buffer + ESI], AL ; Almacena el carácter devuelta
        
    skip_convert:
        inc ESI                 ; siguiente char
        jmp convert_capital_loop ; repita

    count_chars:

        mov EDI, 0 ;  indice a 0
    init_counts:
        mov BYTE [char_counts + EDI], 0 ; inicializar char_counts to 0
        inc EDI                         ; siguiente char
        cmp EDI, 256 ; repetir 256 veces
        jl init_counts ; repetir
        
        mov ESI, 0 ;proximo indice en 0

    count_chars_loop:

        cmp ESI, [buffer_len]   ; Compara si se alcanzó el final del buffer
        jge print_chars         ; Si se alcanzó, salta a imprimir los caracteres
        
        ; Get character and increment its count
        mov BYTE AL, [buffer + ESI] ; Carga el carácter actual
        mov BYTE BL, [char_counts + EAX] ; Carga el count del char actual
        inc BL ; incremente el count
        mov BYTE [char_counts + EAX], BL ; Almacena el count
        
        inc ESI ; siguiente char
        jmp count_chars_loop ; loop

    print_chars:
        mov ESI, 0 ; contador en  0

    print_chars_loop:
        cmp ESI, 256 ; contador hasta el final
        jge done ; hasta que se acabe
        
        mov BYTE AL, [char_counts + ESI] ; Carga el conteo del carácter actual
        cmp AL, 0 ; Compara si el conteo es 0
        je next_char ; Si es0 ese char, siga con el siguiente
        
        ; caracteres especiales
        cmp ESI, 32         ; espacios ...
        je print_space ; si es espacio
        cmp ESI, 9          ; tabs
        je print_tab ; Si es un tabs
        cmp ESI, 10         ; \n
        je print_enter ; si son newline
        
        
        mov EAX, ESI ; cargar en registro general
        PutCh AL ; imprime el ch
        PutStr char_output ; Imprime el separador :
        movzx EAX, BYTE [char_counts + ESI] ; el conteo
        PutInt AX ; Imprime el conteo
        nwln ; Imprime un salto de línea
        jmp next_char ; sig char
        
    print_space:

        PutStr space_msg ; espacios =
        movzx EAX, BYTE [char_counts + ESI] ; Carga el conteo de espacios
        PutInt AX ; Imprime el conteo de espacios
        nwln ; Imprime un salto de línea
        jmp next_char ; sig char
        
    print_tab:
        PutStr tab_msg ; tabs =
        movzx EAX, BYTE [char_counts + ESI] ; Carga el conteo de tabs
        PutInt AX ; Imprime el conteo de tabs
        nwln ; Imprime un salto de línea
        jmp next_char ; sig char
        
    print_enter:
        PutStr newline_msg ; enters =
        movzx EAX, BYTE [char_counts + ESI] ; Carga el conteo de enters
        PutInt AX ; Imprime el conteo de enters
        nwln ; Imprime un salto de línea
        jmp next_char ; sig char
        
    next_char:
        inc ESI ; sig char
        jmp print_chars_loop ; repetir loop
        
    done:
        nwln    ; Imprime un salto de linea antes de finalizar
        .EXIT   ; Finaliza el programa