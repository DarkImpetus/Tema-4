
name "calc2"
  
  
;INSTITUTO TECNOLOGICO SUPERIOR DE VALLADOLID
;ASIGNATURA: LENGUAJES Y AUTOMATAS II
;DOCENTE: JOSE LEONEL PECH MAY 
;PROYECTO: "CALCULADORA EN LENGUAJE ENSAMBLADOR"
;ALUMNOS: 
;        -EDOARDO MARTIN RICALDE CHE
;        -VICTOR MANUEL AVILA HIPOLITO 
;
;FECHA DE ENTREGA: 01/06/2020

;===============================================
; calculadora simple por comandos (+,-,*,/) 
; ejemplo de un calculo:
; entrada 1 <- numero:   10 
; entrada 2 <- operador: - 
; entrada 3 <- numero:   5 
; ------------------- 
;     10 - 5 = 5 
; salida  -> numero:   5 

;==============================================

; este macro imprime un caracter en AL y avanza 
; la posicion actual del cursor 

PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 100h

jmp inicio

; definicion de variables: 
msg0 db "nota: esta calculadora funciona solo con valores enteros.",0Dh,0Ah
msg1 db 0Dh,0Ah, 0Dh,0Ah, 'introduzca el primer numero: $'
msg2 db "introduzca el numero del operador:    +(1)  -(2)  *(3)  /(4)     : $"
msg3 db "introduzca el segundo numero: $"
msg4 db  0dh,0ah , 'el resultado aproximado de mi calculo es : $' 
msg5 db  0dh,0ah ,'fin del programa, presione cualquier tecla para salir... ', 0Dh,0Ah, '$'
err1 db  "operador invalido!", 0Dh,0Ah , '$'
smth db  " y algo.... $"

; el operador puede ser: 
;"1" para sumar
;"2" para restar
;"3" para multiplicar
;"4" para dividir
;"q" para salir a la mitad del programa.

;Cabe destacar, que se opto por opciones numericas en vez de los simbolos de los operandos
;porque el teclado debe tener las teclas especificas para esos simbolos (vienen en un "Teclado numerico")
;esto porque el programa no acepta combinaciones para hacer aparecer los simbolos
;es decir,pondra otro signo si usamos SHIFT + 7 para poner el simbolo (/)
;usar numeros en vez de simbolos asegura que el programa funcione en cualquier computadora
;una opcion es activar el teclado en pantalla para conseguir el teclado numerico
;pero al ser muy engorroso y estorbar en la pantalla, se decidio utilizar la opcion mas facil.
opr db '?'

; primer y segundo numero:
num1 dw ?
num2 dw ?


inicio:
mov dx, offset msg0 ;agrego el mensaje que se va a mostrar
mov ah, 9
int 21h             ;interrupcion para mostrar en pantalla

; llamado a la funcion que recibe el numero de varios digitos
; desde el teclado y almacena el resultado en el registro cx:

call leer_num

; almacenar primer numero:
mov num1, cx 


; nueva linea:
putc 0Dh
putc 0Ah


lea dx, msg2    ;agrego el mensaje que se va a mostrar
mov ah, 09h     ; salida de cadena en ds:dx
int 21h         ;interrupcion para mostrar en pantalla


; recibe el operador:
mov ah, 1   ; entrada de un solo caracter al registro AL.
int 21h
mov opr, al


; nueva linea:
putc 0Dh
putc 0Ah


cmp opr, 'q'      ; si el operador es "q" saldra del programa. 
je salir

cmp opr, '1'
jb opr_equivocado
cmp opr, '4'
ja opr_equivocado


; salida de una cadena en ds:dx
lea dx, msg3
mov ah, 09h
int 21h  


; recibe el numero de varios digitos
; desde el teclado y almacena 
; el resultado en el registro cx:

call leer_num


; almacena el segundo numero:
mov num2, cx 


lea dx, msg4
mov ah, 09h      ; salida de la cadena en ds:dx
int 21h  


; calcular:

cmp opr, '1'
je hacer_sumas

cmp opr, '2'
je hacer_restas

cmp opr, '3'
je hacer_mults

cmp opr, '4'
je hacer_divs


; si ninguno de los de arriba....
opr_equivocado:
lea dx, err1
mov ah, 09h     ; salida de la cadena en ds:dx
int 21h  


salir:
; salida de la cadena en ds:dx
lea dx, msg5
mov ah, 09h
int 21h  


; esperar por una tecla cualquiera...
mov ah, 0
int 16h


ret  ; regresa el control al SO.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hacer_sumas: ;aqui se realizan las sumas


mov ax, num1         ;muevo el valor del primer numero a ax
add ax, num2         ;a ax le sumo el valor del segundo numero
call imprimir_num    ; imprime el valor de ax.

jmp salir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hacer_restas: ;aqui se realizan las restas

mov ax, num1         ;muevo el valor del primer numero a ax
sub ax, num2         ;;a ax le resto el valor del segundo numero
call imprimir_num    ; imprime el valor de ax.

jmp salir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hacer_mults: ;aqui se realizan las multiplicaciones

mov ax, num1
imul num2 ; (dx ax) = ax * num2. 
call imprimir_num    ; imprime el valor de ax.
; dx es ignorado (la calculadora funciona solo con numeros pequenios).

jmp salir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hacer_divs:
; dx es ignorado (la calculadora funciona solo con numeros pequenios).
mov dx, 0
mov ax, num1
idiv num2  ; ax = (dx ax) / num2.
cmp dx, 0
jnz approx
call imprimir_num    ; imprime el valor de ax.
jmp salir
approx:
call imprimir_num    ; imprime el valor de ax.
lea dx, smth
mov ah, 09h    ; salida de la cadena en ds:dx
int 21h  
jmp salir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; recibe el numero de varios digitos desde el teclado,
; y almacena el resultado en el registro cx:
LEER_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reiniciar bandera:
        MOV     CS:hacer_menos, 0

sig_digito:

        ; recibe el caracter desde el teclado 
        ;hacia AL:
        MOV     AH, 00h
        INT     16h
        ; y lo imprime:
        MOV     AH, 0Eh
        INT     10h

        ; checa por "RESTA":
        CMP     AL, '-'
        JE      setear_menos

        ; checa introduccion de "ENTER":
        CMP     AL, 0Dh  ; retorno de carro?
        JNE     no_cr
        JMP     detener_entrada
no_cr:


        CMP     AL, 8                   ; 'BACKSPACE' presionado?
        JNE     backspace_checado
        MOV     DX, 0                   ; remover el ultimo digito por
        MOV     AX, CX                  ; division:
        DIV     CS:diez                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; limpiar posicion.
        PUTC    8                       ; backspace de nuevo.
        JMP     sig_digito
backspace_checado:


        ; permite solo digitos:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remover_no_digito
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digito
remover_no_digito:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; eliminar el ultimo "no-digito" introducido.
        PUTC    8       ; backspace de nuevo.        
        JMP     sig_digito ; esperar por la siguiente entrada.       
ok_digito:


        ; multiplicar CX por 10 (primera vez que el resultado es cero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:diez                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; checar si el numero es demasiado grande
        ; (el resultado deberia de ser de 16 bits)
        CMP     DX, 0
        JNE     muy_grande

        ; convertir desde codigo ASCII:
        SUB     AL, 30h

        ; aniadir AL a CX:
        MOV     AH, 0
        MOV     DX, CX      ; respaldar, en caso de que el resultado sea demasiado grande.
        ADD     CX, AX
        JC      muy_grande2    ; salta si el numero es muy grande.

        JMP     sig_digito

setear_menos:
        MOV     CS:hacer_menos, 1
        JMP     sig_digito

muy_grande2:
        MOV     CX, DX      ; restaura el valor respaldado antes de aniadir.
        MOV     DX, 0       ; DX era cero antes del respaldo!
muy_grande:
        MOV     AX, CX
        DIV     CS:diez  ; revertie el ultimo DX:AX = AX*10, hacer AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; limpiar el ultimo digito recibido.
        PUTC    8       ; backspace de nuevo.        
        JMP     sig_digito ; esperar por un "Enter"/"Backspace".
        
        
detener_entrada:
        ; checar bandera:
        CMP     CS:hacer_menos, 0
        JE      no_menos
        NEG     CX
no_menos:

        POP     SI
        POP     AX
        POP     DX
        RET
hacer_menos      DB      ?       ; usado como bandera.
LEER_NUM        ENDP





; este procedimiento imprime el numero en AX,
; usado con PRINT_NUM_UNS  para imprimir los numeros marcados:
IMPRIMIR_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     no_cero

        PUTC    '0'
        JMP     imprimido

    no_cero:
        ; el chequeo de signo de AX,
        ; hacerlo absoluto si es negativo:
        CMP     AX, 0
        JNS     positivo
        NEG     AX

        PUTC    '-'

    positivo:
        CALL    IMPRIMIR_NUM_UNS

    imprimido:
        POP     AX
        POP     DX
        RET
IMPRIMIR_NUM       ENDP



; este procedimiento imprime un numero sin signos
; en AX (no solo un digito)
; los valores permitidos estan entre 0 y 65535 (FFFF)
IMPRIMIR_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; bandera para prevenir imprimir ceros antes del numero:
        MOV     CX, 1

        ; (resultado de "/ 10000" siempre es menor o igual a 9).
        MOV     BX, 10000       ; 2710h - divisor.

        ; AX es cero?
        CMP     AX, 0
        JZ      imprimir_cero

comenzar_impresion:

        ; check divisor (si es cero ir a end_print):
        CMP     BX,0
        JZ      fin_impresion

        ; evitar imprimir ceros antes del numero:
        CMP     CX, 0
        JE      calc
        ; si AX<BX entonces el resultado de DIV sera cero:
        CMP     AX, BX
        JB      saltar
calc:
        MOV     CX, 0   ; setear bandera.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=resto).

        ; imprimir ultimo digito
        ; AH siempre es CERO, asi que es ignorado
        ADD     AL, 30h    ; convertir a codigo ASCII.
        PUTC    AL


        MOV     AX, DX  ; obtener el residuo de la ultima division.

saltar:
        ; calcular BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:diez  ; AX = DX:AX / 10   (DX=resto).
        MOV     BX, AX
        POP     AX

        JMP     comenzar_impresion
        
imprimir_cero:
        PUTC    '0'
        
fin_impresion:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
IMPRIMIR_NUM_UNS   ENDP



diez             DW      10      ; usado como multiplicador/divisor por SCAN_NUM y PRINT_NUM_UNS.







OBTEN_CADENA      PROC    NEAR
PUSH    AX
PUSH    CX
PUSH    DI
PUSH    DX

MOV     CX, 0                   ; contador de caracteres.

CMP     DX, 1                   ; buffer muy pequenio?
JBE     vacia_buffer            ;

DEC     DX                      ; reservar espacio para el ultimo cero.


;============================
; bucle eterno para recibir
; y procesar cuando se presione una tecla:

espera_por_tecla:

    MOV     AH, 0                   ; recibe la tecla preionada.
    INT     16h

    CMP     AL, 0Dh                  ; 'RETURN' presionado?
    JZ      exit_OBTEN_CADENA


    CMP     AL, 8                   ; 'BACKSPACE' presionado?
    JNE     aniadir_al_buffer
    JCXZ    espera_por_tecla            ; nada para remover!
    DEC     CX
    DEC     DI
    PUTC    8                       ; backspace.
    PUTC    ' '                     ; limpia la posicion.
    PUTC    8                       ; backspace de nuevo.
    JMP     espera_por_tecla

aniadir_al_buffer:

        CMP     CX, DX          ; buffer lleno?
        JAE     espera_por_tecla    ; de ser asi, esperar por 'BACKSPACE' o 'RETURN'...

        MOV     [DI], AL
        INC     DI
        INC     CX
        
        ; imprime la tecla:
        MOV     AH, 0Eh
        INT     10h

JMP     espera_por_tecla
;============================

exit_OBTEN_CADENA:

; terminar por nulo:
MOV     [DI], 0

vacia_buffer: ;Elimina todo lo que hay en la variables 

POP     DX
POP     DI
POP     CX
POP     AX
RET
OBTEN_CADENA      ENDP