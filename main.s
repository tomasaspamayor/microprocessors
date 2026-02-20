#include <xc.inc>

extrn	Keypad_Setup, Keypad_Read  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Clear, LCD_Newline, LCD_Send_Byte_D, LCD_delay_ms
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
state: ds 1
special: ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'T','e','m','m','u','z',' ','T','u','m','a','y',0x0a
					; message, plus carriage return
	myTable_l   EQU	12	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	Keypad_Setup	; setup keypad
	call	LCD_Setup	; setup UART
	call	LCD_Clear
	movlw	0x77
	movwf	state, A
	movlw	0x43
	movwf	special, A 
	goto	loop
	
	; ******* Main programme ****************************************
loop: 	
	call	Keypad_Read	    ; store key press in W
	cpfseq	special, A
	goto send
	
	call LCD_Clear
	bra loop
	
send:
	cpfseq  state, A
	call	LCD_Send_Byte_D	    ; send byte stored in W
	
	movlw	0xFE		; wait a long time
	call	LCD_delay_ms
	
	bra	loop		; goto current line in code
	; a delay subroutine if you need one, times around loop in delay_count
	
	
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return
	
	end	rst