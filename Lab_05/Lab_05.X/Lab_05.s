

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

Division macro Dividendo, Divisor, Resultado_Division,var_in1
    ;clrf   PORTC
    clrf   Resultado_Division

    ;movf   Dividendo,0
    ;addwf  Divisor,0
    ;btfsc  STATUS,2
    ;goto   no_valido
    
    movf   Dividendo,0
    movwf  var_in1
    
 Valido:        ; Divisor y Dividendo deben ser diferentes a cero
    movlw  Divisor
    subwf  var_in1,1
    
    btfsc  STATUS,2
    goto   cero
    
    btfss  STATUS,0
    goto   carry
    
    incf   Resultado_Division,1
    goto   Valido
 carry:
    goto   fin
 cero:
    incf   Resultado_Division,1
    goto   fin
 no_valido:
    movlw  0B
    movwf  Resultado_Division
    
  fin:   
 endm            ; End del macro Division 
 
  
;Division 00010100B, 0B, Resultado_Div,Resultado_Resta
 
;---------------------------------------------------------
;------------ Variables a usar----------------------------
    ;------- Nombrar Pines ---------  
;B_Inc   EQU  0
;B_Dec   EQU  1  
   
#define  B_Inc 6 
#define  B_Dec 7 
    
    ;------- Espacio especifico en memoria para memoria 
;PSECT udata_bank0

PSECT udata_shr  ; common memory
    W_TEMP:         DS 1
    STATUS_TEMP:    DS 1
    Cont_Displays:  DS 1
    #define    Dis_1   0
    #define    Dis_2   1
    #define    Dis_3   2
    #define    Dis_4   3
    #define    Dis_5   4
    #define    Bandera 5
    Display1:       DS 1
    Display2:       DS 1
    Display3:       DS 1
    Display4:       DS 1
    Display5:       DS 1
    Centenas:       DS 1
    Decenas:        DS 1
    Unidades:       DS 1
    Cont_8bits:     DS 1
    Resultado_Resta:DS 1  ; Variable macro 
    Divisor:        DS 1
    Dividendo_Ingreso:      DS 1
    Contador:       DS 1
    
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
    goto   contador
   
    btfsc  T0IF
    goto   temporizador

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
    goto   isr

    
temporizador:
    bsf      Cont_Displays,Bandera
    clrf     PORTD
    movlw    246
    movwf    TMR0
    bcf      T0IF
    goto     isr
    

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
    bsf      IRCF2       ; 500khz
    
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
    bcf      OPTION_REG, 0     ; Se selecciona un preescaler de 128
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
    clrf     Centenas
    clrf     Decenas
    clrf     Unidades
    ;clrf     Resultado_Div
    clrf     Resultado_Resta
    clrf     Dividendo_Ingreso
    clrf     Contador
    clrf     Divisor
    clrf     Cont_8bits
    clrf     TMR0
    movlw    246       ; n de timer0
    movwf    TMR0
    btfss    PORTB, 0
    nop 
    bsf      Cont_Displays, Dis_1
;---------------------------------------------------------
;----------- Loop Forever --------------------------------    
loop:  
    ;Division 11B, 10B, Resultado_Div
    
    
    btfsc   Cont_Displays,Bandera
    goto    Display7seg
    
    goto  loop
    
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

Display_3_4_5:
    movf    PORTC,0
    movwf   Cont_8bits   
    clrf    Centenas
    clrf    Decenas
    clrf    Unidades
    Centena:
    movlw   01100100B
    subwf   Cont_8bits,1
    incf    Centenas,1
    btfsc   STATUS,0
    goto    Centena
    movlw   01100100B
    addwf   Cont_8bits,1
    decf    Centenas,1
    movf    Centenas,0
    andlw   0x0f
    call    Display
    movwf   Display5
    Decena:
    movlw   10
    subwf   Cont_8bits,1
    incf    Decenas,1
    btfsc   STATUS,0
    goto    Decena
    movlw   10
    addwf   Cont_8bits,1
    decf    Decenas,1
    movf    Decenas,0
    andlw   0x0f
    call    Display
    movwf   Display4
    Unidad:
    movlw   1
    subwf   Cont_8bits,1
    incf    Unidades,1
    btfsc   STATUS,0
    goto    Unidad
    movlw   1
    addwf   Cont_8bits,1
    decf    Unidades,1
    movf    Unidades,0
    andlw   0x0f
    call    Display
    movwf   Display3
return


    
Display7seg:
    
    call    Display_1Y2
    call    Display_3_4_5
    bcf     Cont_Displays, Bandera
    
    btfsc   Cont_Displays, Dis_1     ; Debe encender el display 2
    goto    Encender_Dis2
    
    btfsc   Cont_Displays, Dis_2     ; Debe encender el display 3
    goto    Encender_Dis3
    
    btfsc   Cont_Displays, Dis_3     ; Debe encender el display 4
    goto    Encender_Dis4
    
    btfsc   Cont_Displays, Dis_4     ; Debe encender el display 5
    goto    Encender_Dis5 
    
    btfsc   Cont_Displays, Dis_5     ; Debe encender el display 1
    goto    Encender_Dis1
    
    ;goto    loop
    
Encender_Dis1:
    movf    Display1,0
    movwf   PORTD
    
    movlw   00000001B ; Anodo:00000001B  Catodo:11111110B
    movwf   PORTA
    ;bsf     PORTC,0
    bcf     Cont_Displays, Dis_5
    bsf     Cont_Displays, Dis_1
    
    goto    loop
Encender_Dis2:
    movf    Display2,0
    movwf   PORTD 
    movlw   00000010B ; Anodo:00000010B  Catodo:11111101B
    movwf   PORTA
    ;bsf     PORTC,1
    bcf     Cont_Displays, Dis_1
    bsf     Cont_Displays, Dis_2
    
    goto    loop
Encender_Dis3:
    movf    Display3,0
    movwf   PORTD 
    movlw   00000100B ; Anado:00000100B  Catodo:11111011B
    movwf   PORTA
    ;bsf     PORTC,2
    bcf     Cont_Displays, Dis_2
    bsf     Cont_Displays, Dis_3
    
    goto    loop
Encender_Dis4:
    movf    Display4,0
    movwf   PORTD 
    movlw   00001000B ; Anodo:00001000B  Catodo:11110111B
    movwf   PORTA
    ;bsf     PORTC,3
    bcf     Cont_Displays, Dis_3
    bsf     Cont_Displays, Dis_4
    
    goto    loop

Encender_Dis5:
    movf    Display5,0
    movwf   PORTD 
    movlw   00010000B ; Anodo:00010000B  Catodo:11101111B
    movwf   PORTA
    ;bsf     PORTC,4
    bcf     Cont_Displays, Dis_4
    bsf     Cont_Displays, Dis_5
    
    goto    loop 


end 
