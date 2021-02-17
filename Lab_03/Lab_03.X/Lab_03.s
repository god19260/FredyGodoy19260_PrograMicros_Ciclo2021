
; Autor: Fredy Josue Godoy Lucero - 19260
; Laboratorio No. 03 - Programación de Microcontraladores


    
processor 16F887
#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = ON           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = ON             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

; Variables a usar
PSECT udata_bank0
Contador: DS 1
  
PSECT code, delta=2, abs
ORG 100h
 
main:
    BANKSEL OSCCON
    bcf     IRCF0
    bcf     IRCF1
    bsf     IRCF2
    
    
    BANKSEL ANSEL
    clrf     ANSEL
    clrf     ANSELH
    
    BANKSEL TRISA
    bsf     TRISA,0      ; se define el pin 0 de PORTA como entrada 
    bsf     TRISA,1      ; se define el pin 1 de PORTA como entrada 
    bcf     TRISC,0      ; se definen los pines 0-3 de PORTC como salidas
    bcf     TRISC,1
    bcf     TRISC,2
    bcf     TRISC,3
    bcf     TRISD,0      ; se definen los pines 0-7 de PORTD como salidas
    bcf     TRISD,1
    bcf     TRISD,2
    bcf     TRISD,3
    bcf     TRISD,4
    bcf     TRISD,5
    bcf     TRISD,6
    bcf     TRISE,0
    
    
    movlw   00000111B
    movwf   OPTION_REG   ; Se selecciona un preescaler de 256
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    clrf    TMR0
    movlw   1010000B
    movwf   INTCON

tabla:
    
    andlw 0x0F
    ADDWF PCL,0;W = offset
    retlw 01110110B ; Cero
    retlw 00000110B ;Uno
    retlw 01011011B ;Dos
    retlw 01001111B ;Tres
    retlw 01100110B ;Cuatro
    retlw 01101101B ;Cinco
    retlw 01111101B ;Seis 
    retlw 00000111B ;Siete
    retlw 01111111B ;Ocho
    retlw 01100111B ;Nueve
    retlw 01110111B ;A
    retlw 01111100B ;B
    retlw 00111001B ;C
    retlw 01011110B ;D
    retlw 01111001B ;E
    retlw 01110001B ;F
loop:      
    incf   PORTC,1
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    ;bcf    PORTE,0 
       
    goto    loop
Contadores_Iguales:
    bsf  PORTE,0
    clrf PORTC
    goto loop
    
Temporizador_65ms:
    ;movlw  PORTC
    ;andwf  PORTD,0
    
    btfss  PORTA,0       ; verificar si B1 esta presionado 
    call   Incremento
    btfss  PORTA,1       ; verificar si B2 esta presionado 
    call   Decremento
    movlw  11000001B     ; 193
    movwf  TMR0
    bcf    INTCON,2
    btfss  INTCON,2
    goto   $-1
    return

Incremento:
    btfss  PORTA,0       ; verificar si B1 esta presionado 
    goto   $-1
    incf   PORTD, 1
    movf   Contador
    call   tabla
    movwf  PORTD
    goto   loop
Decremento:
    btfss  PORTA,1       ; verificar si B2 esta presionado 
    goto   $-1
    decf   PORTD,1
    movf   Contador
    call   tabla
    movwf  PORTD
    goto   loop
    
cero:
    clrf    PORTD
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 01110110B ; Cero
Uno:
    clrf    PORTD
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    ;bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ;00000110B ;Uno
    goto loop
Dos:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos 
    
    goto loop
Tres:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    goto loop
Cuatro:
    clrf    PORTD
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    goto loop
Cinco:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    goto loop
Seis:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    goto loop
Siete:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    ;bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    goto loop
Ocho:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    goto loop
Nueve:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    goto loop
A:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    ; 01110111B ;Diez
    goto loop
B:
    clrf    PORTD
    ;bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    ; 01110111B ;A
    ; 01111100B ;B
    goto loop
C:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    ;bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    ; 01110111B ;A
    ; 01111100B ;B
    ; 00111001B ;C
    goto loop
D:
    clrf    PORTD
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    ; 01110111B ;A
    ; 01111100B ;B
    ; 00111001B ;C
    ; 01011110B ;D
    goto loop
E:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    ; 01110111B ;A
    ; 01111100B ;B
    ; 00111001B ;C
    ; 01011110B ;D
    ; 01111001B ;E
    goto loop
F_:
    clrf    PORTD
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    ; 01110110B ; Cero
    ; 00000110B ;Uno
    ; 01011011B ;Dos
    ; 01001111B ;Tres
    ; 01100110B ;Cuatro
    ; 01101101B ;Cinco
    ; 01111101B ;Seis 
    ; 00000111B ;Siete
    ; 01111111B ;Ocho
    ; 01100111B ;Nueve
    ; 01110111B ;A
    ; 01111100B ;B
    ; 00111001B ;C
    ; 01011110B ;D
    ; 01111001B ;E
    ; 01110001B ;F
    goto loop
 
end