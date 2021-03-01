

; Autor: Fredy Josue Godoy Lucero - 19260
; Laboratorio No. 05 - Programación de Microcontraladores

    
processor 16F887
#include <xc.inc>
 
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = OFF             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
    
;---------------------------------------------------------
;--------------- Macros ----------------------------------

  
;---------------------------------------------------------
;------------ Variables a usar----------------------------
    ;------- Nombrar Pines ---------  
;B_Inc   EQU  0
;B_Dec   EQU  1  
   
#define  B_Inc 0 
#define  B_Dec 1 
   
    ;------- Espacio especifico en memoria para memoria 
PSECT udata_bank0

;PSECT udata_shr  ; common memory
    W_TEMP:         DS 1
    STATUS_TEMP:    DS 1
    Cont_Displays:  DS 1
  
    
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
    btfsc  RBIF
    call   contador
   
    btfsc  T0IF
    call   temporizador

    bcf    T0IF
    BCF    RBIF
pop: 
    swapf  STATUS_TEMP,W
    movwf  STATUS
    swapf  W_TEMP, F
    swapf  W_TEMP, W
    RETFIE

contador:
    btfss  PORTB, B_Inc
    incf   PORTC
   
    btfss  PORTB, B_Dec
    decf   PORTC
    
    bcf    RBIF
    return

    
temporizador:
    bcf      T0IF
    movlw    11111111B     ; 255
    movwf    TMR0
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
       
    movlw    11100000B     ; PORTA 0 al 4 como salidas y 5 al 7 como entradas
    movwf    TRISA
    movlw    00000000B     ; PORTC todos los pines como salidas 
    movwf    TRISC
    movlw    10000000B     ; PORTD 0 al 6 como salidas y el 7 como entrada
    movwf    TRISD
    
    banksel  OPTION_REG
    bcf      OPTION_REG, 7
    bsf      WPUB, B_Inc   ; Activar los pullups de los pines B_Inc y B_Dec 
    bsf      WPUB, B_Dec 
    
    bcf      OPTION_REG, 5
    bcf      OPTION_REG, 3
    bsf      OPTION_REG, 0     ; Se selecciona un preescaler de 256
    bsf      OPTION_REG, 1
    bsf      OPTION_REG, 2
    
    
    banksel  IOCB
    bsf      IOCB, B_Inc   ; Habilitar Interrupt on change en B_Inc y B_Dec
    bsf      IOCB, B_Dec  
    
    banksel  PORTA
    movf     PORTB, W
    
    
    banksel  INTCON
    movlw    10101000B
    movwf    INTCON
    ;bsf      GIE
    ;bsf      RBIE
    ;bcf      RBIF
    
    banksel  PORTA
    clrf     PORTA
    clrf     PORTB
    clrf     PORTC
    clrf     PORTD
    clrf     Cont_Displays
    clrf     TMR0
    movlw    11111111B     ; 255
    movwf    TMR0
    btfss    PORTB, 0
    nop 
;---------------------------------------------------------
;----------- Loop Forever --------------------------------    
loop:  
    ;call     Contador_Displays
    
    swapf    PORTC,0
    call     Display
    movwf    PORTD
    bsf      PORTA,1
   
    movlw    11111111B
    sublw    Cont_Displays
    

    goto  loop

Contador_Displays:
    
    
    return 

end 
