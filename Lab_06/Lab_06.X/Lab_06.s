
; Autor: Fredy Josue Godoy Lucero - 19260
; Laboratorio No. 06 - Programación de Microcontraladores

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
;------------ Variables a usar----------------------------
PSECT udata_shr  ; common memory  

    #define B_Inc 0  ; pines puerto B, Incremento y Decremento
    #define B_Dec 1
    W_TEMP:         DS 1
    STATUS_TEMP:    DS 1
    Cont_Displays:  DS 1
    #define  Dis_1     0
    #define  Dis_2     1
    #define  Bandera   2
    
    Display1:       DS 1
    Display2:       DS 1
    Bandera_Dis:    DS 1
    #define Off        0
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
    ;Interrupcion timer0
    btfsc  T0IF
    goto   Timer0
    
    ;Interrupcion timer1
    btfsc   TMR1IF	 ; Interrupción timer1
    goto    Timer1   	
    
    ;Interrupcion timer2
    btfsc   TMR2IF	; Testear si esta encendida la bandera para...
    call    Timer2	; Ir a la subrutina del TMR1 */
    
    
    bcf    T0IF
    bcf    TMR1IF
    bcf	   TMR2IF
pop: 
    swapf  STATUS_TEMP,W
    movwf  STATUS
    swapf  W_TEMP, F
    swapf  W_TEMP, W
    RETFIE
    
 ; rutinas de interrupción
Timer0:
    bsf      Cont_Displays,Bandera
    clrf     PORTD
    movlw    246
    movwf    TMR0
    bcf      T0IF
    goto     isr 
    
Timer1:
    incf    PORTC,1
   
    Banksel PORTA   ; Acceder al Bank 0
    movlw   0x0B   ; Cargar valor de registro W, valor inicial del tmr0
    movwf   TMR1H    ; Mover el valor de W a TMR0 por interrupción
    movlw   0xDC	    ; Cargar valor de registro W, valor inicial del tmr0
    movwf   TMR1L    ; Mover el valor de W a TMR0 por interrupción
    
    bcf	    TMR1IF    ; Limpiar bit de interrupción por overflow (Bit de INTCON)
    goto    isr
 
 Timer2:
    clrf    TMR2
    banksel PORTA
    incf    PORTA,1
    bcf	    TMR2IF
    
    btfss   Bandera_Dis,Off
    goto    Encender 
    
    btfsc   Bandera_Dis,Off
    goto    Apagar
    
    Apagar:
    bcf     Bandera_Dis,Off
    goto    Fin_Timer2
    
    Encender:
    bsf     Bandera_Dis,Off
    
    
    Fin_Timer2:
    goto    isr
    
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
    ;------- Oscilador -------------
    BANKSEL  OSCCON
    bcf      IRCF0       ; Donfiguración del reloj interno 
    bcf      IRCF1
    bsf      IRCF2       ; 500khz
    
    ;------- Timer0 ---------------
    bcf      OPTION_REG, 5
    bcf      OPTION_REG, 3
    bsf      OPTION_REG, 0     ; Se selecciona un preescaler de 64
    bcf      OPTION_REG, 1
    bsf      OPTION_REG, 2     
    
    banksel  INTCON           ; Habilitar Interrupciones
    movlw    10101000B
    movwf    INTCON
    
    clrf     TMR0
    movlw    246              ; n de timer0
    movwf    TMR0
    ;------- Timer1 --------------    
    Banksel  PORTA  
    bsf	     TMR1ON
    bcf	     TMR1CS   ; Seleccion del reloj interno
    bcf	     T1CKPS0
    bsf	     T1CKPS1  ; Prescaler a 1:2
    
    movlw    0x0B
    movwf    TMR1H
    movlw    0xDC
    movwf    TMR1L
    
    Banksel PORTA
    bsf	GIE	; Se habilitan las interrupciones globales
    bsf	PEIE	
    Banksel TRISA
    bsf	TMR1IE	; Se habilitan la interrupción del TMR1 Registro PIE1
    bcf	TMR1IF  ; Se limpia la bandera Registro PIR1
    ;------- Timer2 ---------------
    banksel PORTA
    bsf	    TMR2ON
    bsf	    T2CKPS1
    bsf	    T2CKPS0 ; Prescaler a 1:16
    bsf	    TOUTPS3
    bsf	    TOUTPS2
    bsf	    TOUTPS1
    bsf	    TOUTPS0 ;Postscaler 1:16
    bcf	    TMR2IF    ; Limpiar bit de interrupción por overflow (Bit de INTCON)
    Banksel TRISA   ; Acceder al Bank 1
    movlw   230   ; Cargar valor de registro W, valor inicial del tmr2
    movwf   PR2	
    
    ;------- Puertos ---------------
    banksel ANSEL ;Banco 11
    clrf    ANSEL ;Pines digitales
    clrf    ANSELH
    
    banksel TRISA ;Banco 01
    bcf     TRISA,0
    clrf    TRISC    ;Display multiplexados 7seg 
    clrf    TRISD    ;Alternancia de displays
    clrf    TRISE
    
    banksel PORTA ;Banco 00
    clrf    PORTA ;Comenzar contador binario en 0
    clrf    PORTC ;Comenzar displays en 0
    clrf    PORTD ;Comenzar la alternancia de displays en 0
    clrf    PORTE
    clrf    Bandera_Dis

;---------------------------------------------------------
;----------- Loop Forever --------------------------------    
loop:  
    
    btfss   Bandera_Dis,Off
    goto    fin_loop
    
    ;bcf     Bandera_Dis,Off
    
    
    btfsc   Cont_Displays,Bandera
    goto    Display7seg
    
    
    fin_loop:
    goto     loop
    
    
Display_1Y2:
    movf    PORTC,0
    andlw   0x0f
    call    Display
    movwf   Display1
    
    swapf   PORTC,0
    andlw   0x0f
    call    Display
    movwf   Display2
    
    return
Display7seg:
    call    Display_1Y2
    bcf     Cont_Displays, Bandera
    
    btfsc   Cont_Displays, Dis_1     ; Debe encender el display 2
    goto    Encender_Dis2
    
    btfsc   Cont_Displays, Dis_2     ; Debe encender el display 3
    goto    Encender_Dis1
Encender_Dis1:
    movf    Display1,0
    movwf   PORTD
    
    movlw   00000001B ; Anodo:00000001B  Catodo:11111110B
    movwf   PORTE
    ;bsf     PORTC,0
    bcf     Cont_Displays, Dis_2
    bsf     Cont_Displays, Dis_1
    
    goto    loop
Encender_Dis2:
    movf    Display2,0
    movwf   PORTD 
    movlw   00000010B ; Anodo:00000010B  Catodo:11111101B
    movwf   PORTE
    ;bsf     PORTC,1
    bcf     Cont_Displays, Dis_1
    bsf     Cont_Displays, Dis_2
    
    goto    loop