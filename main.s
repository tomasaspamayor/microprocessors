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
	movwf	0x01, A
	movwf	0x02, A ; counter for sine function (runs to 8)
	goto	sine
	
sawtooth: ; sawtooth function generator
	btg	PORTD, 0, A
	
	movlw	0x02 ; move 2 into w
	cpfsgt	0x02, A ; skip loop if counter is less than w
	bra	skiploop
	
	movlw	0x00
	movwf	0x02, A ; reset counter
	
	incf	PORTJ, A
	
skiploop:
	incf	0x02, A 
	bra	sawtooth
	
	
sine: 
    rising_sine:
		btg	PORTD, 0, A ; toggle clock
		movlw	0x08
		cpfsgt	0x01, A ; if counter less than w, end the loop
		bra	end_rising_sine 
		
		movlw	0x00
		movwf	0x01, A ; reset counter to 0
		
		incf	PORTJ, A ; on the rise
		incf	0x02, A ; increment sine counter
		
		
	end_rising_sine:
		incf	0x01, A ; increase toggle 
		
		movlw	0x07 ; move 7 into w
		cpfsgt	0x02, A ; skip loop if counter is greater than 7 
		bra	rising_sine ; loop again if less than 7

		
	movlw	0x00 ; reset sine counter
	movwf	0x02, A
	
    falling_sine:
		btg	PORTD, 0, A ; toggle clock
		movlw	0x08
		cpfsgt	0x01, A ; if counter less than w, end the loop
		bra	end_falling_sine
		
		movlw	0x00
		movwf	0x01, A ; reset counter to 0
    
		decf	PORTJ, A ; on the rise
		incf	0x02, A ; increment sine counter
		
		
	end_falling_sine:
		incf	0x01, A ; increase toggle 
		
		movlw	0x07 ; move 7 into w
		cpfsgt	0x02, A ; skip loop if counter is greater than 7 
		bra	falling_sine ; loop again if less than 7
		
		bra	sine
	
   
	