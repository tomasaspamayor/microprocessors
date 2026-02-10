	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100
setup:	
	movlw	0x00
	movwf	TRISJ, A
	movwf	TRISD, A
	
	goto	start

	
start:
	movlw	0x00
	movwf	PORTJ, A 
	movwf   PORTD, A 
	
loop: 
	incf	PORTJ, A
	btg	PORTD, 1, A
	nop
	nop
	bra	loop