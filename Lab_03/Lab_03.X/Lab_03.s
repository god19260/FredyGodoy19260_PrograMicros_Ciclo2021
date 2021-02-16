
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
PSECT udata_bank0
  Contador: DS 4 ; 4 bits
PSECT code, delta=2, abs
ORG 100h
main:
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
    bcf     TRISD,7
    
    movlw   00000111B
    movwf   OPTION_REG   ; Se selecciona un preescaler de 256
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    TMR0
    movlw   1010000B
    movwf   INTCON
  
loop:
    ;incf   PORTC, 1
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
    call   Temporizador_65ms
     
    goto    loop

Temporizador_65ms:
    btfss  PORTA,0       ; verificar si B1 esta presionado 
    call Incremento
    btfss  PORTA,1       ; verificar si B2 esta presionado 
    call Decremento
    movlw  11000001B
    movwf  TMR0
    bcf    INTCON,2
    btfss  INTCON,2
    goto   $-1
    return

Incremento:
    btfss  PORTA,0       ; verificar si B1 esta presionado 
    goto   $-1
    incf   PORTC, 1
    goto   loop
Decremento:
    btfss  PORTA,1       ; verificar si B2 esta presionado 
    goto   $-1
    decf   Contador,1
    goto   loop
    
    
Uno:
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    ;bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Dos:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Tres:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Cuatro:
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Cinco:
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Seis:
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Siete:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    ;bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Ocho:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
Nueve:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    ;bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
A:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
B:
    bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
C:
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
D:
    ;bsf     PORTD,0  ; Horizontal Arriba
    bsf     PORTD,1  ; Derecha Arriba
    bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    ;bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
E:
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
F_:
    bsf     PORTD,0  ; Horizontal Arriba
    ;bsf     PORTD,1  ; Derecha Arriba
    ;bsf     PORTD,2  ; Derecha Abajo
    ;bsf     PORTD,3  ; Horizontal Abajo
    bsf     PORTD,4  ; Izquierda Abajo
    bsf     PORTD,5  ; Izquierda Arriba
    bsf     PORTD,6  ; Horizontal centro
    ;bsf     PORTD,7  ; Indicador
    return
end