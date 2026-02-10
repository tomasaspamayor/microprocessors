	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	movlw	0x00
	movwf	TRISC, A    ; set port B to output 
	goto	start
	
temmuztable:
	db	0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
	counter	EQU 0x00
	table	EQU 0x01
	align	2
	    
delay:	
	movlw	10
	movwf	0x22, A
	
delay_outer:
	movlw	0xFF
	movwf	0x20, A

delay_inner: 
	decfsz	0x20, A
	bra	delay_inner
	
	decfsz	0x21, A
	bra	delay_outer
	
	return
    
start:
	lfsr	0, table    ; load table address ino FSR0 
	movlw	low highword(temmuztable)
	movwf	TBLPTRU, A
	movlw	low (temmuztable) 
	movwf	TBLPTRL, A
	movlw	high (temmuztable) 
	movwf	TBLPTRH, A 
	movlw	8		; n bytes to read
	movwf 	counter, A

loop:
	    tblrd*+
	movff	TABLAT, PORTC
	
	movlw	0xFF 
	movwf	0x20, A 
	call	delay
	
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
	
	goto	0
	end	main
