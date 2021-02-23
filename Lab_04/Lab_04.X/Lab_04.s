
; Autor: Fredy Josue Godoy Lucero - 19260
; Laboratorio No. 04 - Programación de Microcontraladores

    
processor 16F887
#include <xc.inc>
 
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = ON             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = ON             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
    
;---------------------------------------------------------
;------------ Variables a usar----------------------------
    ;------- Nombrar Pines ---------  
B_Inc   EQU  0
B_Dec   EQU  1  
    ;------- Espacio especifico en memoria para memoria 
PSECT udata_bank0

;PSECT udata_shr  ; common memory
    W_TEMP:      DS 1
    STATUS_TEMP: DS 1
    
    
;---------------------------------------------------------
;------------ Reset Vector -------------------------------
PSECT resVect, class=code, abs, delta=2  
ORG 00h
resVect:
    PAGESEL main
    goto    main 
    
;---------------------------------------------------------
;------------ Interrupt Vector ---------------------------
PSECT resVect, class=code, abs, delta=2  
ORG 04h
push:
    movwf  W_TEMP
    swapf  STATUS,W
    movwf  STATUS_TEMP
isr:
    btfsc  RBIF
    call   Interrupcion
pop: 
    swapf  STATUS_TEMP,W
    movwf  STATUS
    swapf  W_TEMP, F
    swapf  W_TEMP, W
    retfie
    
Interrupcion:
    btfss    PORTB, B_Inc
    incf     PORTA, 1
    btfss    PORTB, B_Dec
    decf     PORTA, 1
    bcf      RBIF
    return
;---------------------------------------------------------
;------------ Definición del Inicio ----------------------
PSECT code, delta=2, abs
ORG 100h

;---------------------------------------------------------
;------------ Main ---------------------------------------
main: 
    ;------- Configuraciones -------
    BANKSEL  OSCCON
    bcf      IRCF0       ; Donfiguración del reloj interno 
    bcf      IRCF1
    bsf      IRCF2       ; 1Mhz
    
    BANKSEL  ANSEL       ; Disponer los pines como I/O Inputs
    clrf     ANSEL
    clrf     ANSELH
    
    banksel  TRISA         
    bsf      TRISB, B_Inc  ; Colocar los pines B_Inc y B_Dec como entradas
    bsf      TRISB, B_Dec
    
    banksel  OPTION_REG
    bcf      OPTION_REG, 7
    bsf      WPUB, B_Inc  ; Activar los pullups de los pines B_Inc y B_Dec 
    bsf      WPUB, B_Dec
    
    banksel  IOCB
    bsf      IOCB, B_Inc   ; Habilitar Interrupt on change en B_Inc y B_Dec
    bsf      IOCB, B_Dec  
    
    banksel  PORTA
    movf     PORTB, W
 
    
    banksel  INTCON
    movlw    10001000B
    movwf    INTCON,1
    ;bsf      GIE
    ;bsf      RBIE
    ;bcf      RBIF
    
    
    clrf     PORTB
;---------------------------------------------------------
;----------- Loop Forever --------------------------------    
loop:    
    
    goto loop

end 