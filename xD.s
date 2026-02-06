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
	movwf	TRISB, A
	goto	start
	
temmuztable:
	db	'T','E','M','M','U','Z'
	counter EQU 0x00
	table EQU 0x01
	align	2
	
start:
	lfsr	0, table    ; load table ino FSR0 
	movlw	low highword(temmuztable)
	movwf	TBLPTRU, A
	movlw	low (termmuztable) 
	movwf	TBLPTRL, A
	movlw	high (temmuztable) 
	movwf	TBLPTRH, A 
	movlw	6		; 22 bytes to read
	movwf 	counter, A

loop:
	tblrd*+
	movff	TABLAT, PORTB
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
	
	goto	0

	end	main
