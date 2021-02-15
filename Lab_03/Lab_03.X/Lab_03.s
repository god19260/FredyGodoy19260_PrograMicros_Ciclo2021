
; Autor: Fredy Josue Godoy Lucero - 19260
; Laboratorio No. 03 - Programación de Microcontraladores


    
processor 16F887
#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT
  CONFIG  WDTE = ON             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
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


ORG 100h
main:
    BANKSEL TRISA
    bcf     TRISA,0
    
    movlw   00001111B
    movwf   OPTION_REG   ; Se selecciona un preescaler de 256
    
    banksel PORTA
    clrf    PORTA
    clrf    TMR0
    
  
loop:
    bsf  PORTA,0
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    bcf  PORTA,0
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    call Timer_65ms
    goto loop

    
Timer_65ms:
    movlw   00000010B
    movwf   TMR0
    bcf     INTCON, 2
    btfss   INTCON, 2
    goto    $-1
    RETURN
   
end