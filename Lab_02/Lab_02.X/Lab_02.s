
; Fredy Godoy, Carné 19260
; Programación de microcontroladores    
; Laboratorio No.2, Ciclo 1, 2021
    
    
; PIC16F887 Configuration Bit Settings
; Assembly source line config statements

processor 16F887
#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = XT ; 
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
  
  

  
;------ Configuarción---------------------------
PSECT code, delta=2, abs
ORG 100h
main:
    banksel ANSEL         
    clrf    ANSEL          ; Para asignar los pines como I/O digitales se coloca en cero ANSEL y ANSELH 
    clrf    ANSELH
    
    banksel  TRISA
    
    ;Configuaracion Puerto A
    bcf TRISA, 0           ; Del pin 0 a 3 se configura como salida
    bcf TRISA, 1
    bcf TRISA, 2  
    bcf TRISA, 3
    bsf TRISA, 4           ; Los pines 4 y 5 se configran como entrada
    bsf TRISA, 5
    
    ;Configuaracion Puerto B
    bcf TRISB, 0           ; Del pin 0 a 3 se configura como salida
    bcf TRISB, 1
    bcf TRISB, 2  
    bcf TRISB, 3
    bsf TRISB, 4           ; Los pines 4 y 5 se configran como entrada
    bsf TRISB, 5

    ;Configuaracion Puerto C
    bcf TRISC, 0           ; Del pin 0 a 4 se configura como salida
    bcf TRISC, 1
    bcf TRISC, 2  
    bcf TRISC, 3
    bcf TRISC, 4
    
    ;Configuaracion Puerto D
    bsf TRISD, 1           ; El pin 1 se configura como entrada
    
    
    ; limpiar todos los pins
    banksel PORTA
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
  

;------Bucle Principal-------
; Los botones estan en configuración pull-up    
loop: 
    clrw                   ; Se limpia el ultimo valor de w 
    btfss   PORTA, 4       ; Testear si el boton del pin 4 de PORTA esta en cero
    call    Incremento_1   ; Si esta en cero se dirige a Incremento_1
    btfss   PORTA, 5       ; Testear si el boton del pin 5 de PORTA esta en cero
    call    Decremento_1   ; Si esta en cero se dirige a Decremento_2
    btfss   PORTB, 4       ; Testear si el boton del pin 4 de PORTB esta en cero
    call    Incremento_2   ; Si esta en cero se dirige a Incremento_2
    btfss   PORTB, 5       ; Testear si el boton del pin 5 de PORTB esta en cero
    call    Decremento_2   ; Si esta en cero se dirige a Decremento_2
    btfss   PORTD, 1       ; Testear si el boton del pin 1 de PORTD esta en cero
    call    Sumador        ; Si esta en cero se dirige a Sumador
    goto    loop           ; Mantenerse en el ciclo principal (loop)
  
;------ Contador 1 -----------
; Incremento
Incremento_1:
    btfss   PORTA, 4       ; Antirebote 
    goto    $-1            ; Si el pin 4 de PORTA esta en cero regresa una linea
    incf    PORTA, 1       ; Cuando se haya soltado el boton se incrementa PORTA
    return                 ; Regresa a la interrupción en loop

; Decremento
Decremento_1:
    btfss   PORTA, 5       ; Antirebote 
    goto    $-1            ; Si el pin 5 de PORTA esta en cero regresa una linea
    decf    PORTA, 1       ; Cuando se haya soltado el boton se decrementa PORTA
    return                 ; Regresa a la interrupción en loop
    
;------ Contador 2 -----------
; Incremento
Incremento_2:
    btfss   PORTB, 4       ; Antirebote
    goto    $-1            ; Si el pin 4 de PORTB esta en cero regresa una linea
    incf    PORTB, 1       ; Cuando se haya soltado el boton se incrementa PORTB
    return                 ; Regresa a la interrupción en loop
; Decremento
Decremento_2:
    btfss   PORTB, 5       ; Antirebote
    goto    $-1            ; Si el pin 5 de PORTB esta en cero regresa una linea
    decf    PORTB, 1       ; Cuando se haya soltado el boton se decrementa PORTB
    return                 ; Regresa a la interrupción en loop
;------ Sumador -----------
Sumador:    
    btfsc   STATUS, 0      ; Testea si la bandera de carry (posición 0 de status) esta en 1
    bsf     PORTC,  4      ; Si esta en 1 se coloca en 1 el pin 4 del PORTC
    btfss   STATUS, 0      ; Testea si la bandera de carry (posición 0 de status) esta en 0
    bcf     PORTC,  4      ; Si esta en 0 se coloca en 0 el pin 4 del PORTC
    btfss   PORTD,  1      ; Antirebote - Testea si el pin 1 de PORTD esta en 0 
    goto    $-1            ; Si esta en cero, regresa una linea
    movf    PORTA,  0      ; El valor del PORTA se asigna a W
    addwf   PORTB,  0      ; El valor de W se suma a PORTB, y el resultado se mueve a W
    movwf   PORTC          ; Se asigna el valor de W a PORTC
    
    return                 ; Regresa a la interrupción en loop
end


    
  







