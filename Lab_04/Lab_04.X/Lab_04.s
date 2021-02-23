
; Autor: Fredy Josue Godoy Lucero - 19260
; Laboratorio No. 04 - Programación de Microcontraladores

    
processor 16F887
#include <xc.inc>
 
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
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
;--------------- Macros ----------------------------------
  
Incrementar macro Boton, puerto   ; Incrimenta con configuración pullup 
  btfsc  Boton
  incf   puerto,1
  endm
  
Decrementar macro Boton, puerto   ; Decrementa con configuración pullup 
  btfsc  Boton
  decf   puerto,1
  endm
  
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
    Cont:        DS 1
    
    
;---------------------------------------------------------
;------------ Reset Vector -------------------------------
PSECT resVect, class=code, abs, delta=2  
ORG 00h
resVect:
    PAGESEL main
    goto    main 
    
;---------------------------------------------------------
;------------ Interrupción ---------------------------
PSECT resVect, class=code, abs, delta=2  
ORG 04h
push:
    movwf  W_TEMP
    swapf  STATUS,W
    movwf  STATUS_TEMP
isr:
    btfsc  T0IF
    incf   PORTD
    
    btfss  PORTB, B_Inc
    call   Incremento
    btfss  PORTB, B_Dec
    call   Decremento
    bcf    RBIF
    movf  PORTA,0
    call  Display
    movwf PORTC 
    ;bcf    T0IF
    
pop: 
    swapf  STATUS_TEMP,W
    movwf  STATUS
    swapf  W_TEMP, F
    swapf  W_TEMP, W
    RETFIE
    
Incremento:
    btfss    PORTB, B_Inc
    goto     $-1
    incf     PORTA
    return
Decremento:
    btfss    PORTB, B_Dec
    goto     $-1
    decf     PORTA
    return
;---------------------------------------------------------
;------------ Definición del Inicio ----------------------
PSECT code, delta=2, abs
ORG 100h
;---------------------------------------------------------
;------------ Tablas -------------------------------------
Display:
    clrf  PCLATH
    bsf   PCLATH,0
    andlw 0x0F
    addwf PCL
    retlw 00111111B ; Cero
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
    
    ; ---------- Activar pines como salidas o entradas
    banksel  TRISA         
    bsf      TRISB, B_Inc  ; Colocar los pines B_Inc y B_Dec como entradas
    bsf      TRISB, B_Dec
    movlw    11110000B     ; PORTA 0 al 3 como salidas y 4 al 7 como entradas
    movwf    TRISA
    movlw    10000000B     ; PORTC 0 al 6 como salidas y el 7 como entrada
    movwf    TRISC
    movlw    10000000B     ; PORTD 0 al 6 como salidas y el 7 como entrada
    movwf    TRISD
    
    banksel  OPTION_REG
    bcf      OPTION_REG, 7
    bsf      WPUB, B_Inc   ; Activar los pullups de los pines B_Inc y B_Dec 
    bsf      WPUB, B_Dec 
    
    
    bsf      OPTION_REG, 0     ; Se selecciona un preescaler de 256
    bsf      OPTION_REG, 1
    bsf      OPTION_REG, 2
    
    
    banksel  IOCB
    bsf      IOCB, B_Inc   ; Habilitar Interrupt on change en B_Inc y B_Dec
    bsf      IOCB, B_Dec  
    
    ;banksel  PORTA
   ; movf     PORTB, W
 
    
    banksel  INTCON
    movlw    11101000B
    movwf    INTCON,1
    ;bsf      GIE
    ;bsf      RBIE
    ;bcf      RBIF
    
    banksel  PORTA
    clrf     PORTA
    clrf     PORTB
    clrf     PORTC
    clrf     PORTD
    clrf     TMR0
;---------------------------------------------------------
;----------- Loop Forever --------------------------------    
loop:   
  
    goto  loop
 
    ;   11101101B     ; 237

end 