	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto setup
	
	org 0x100

setup: 
	bcf CFGS
	bcf EEPGD
	goto start 
	
myTable:
	db	'T','E','M','M','U','Z',' ', 'T', 'U', 'M', 'A', 'Y'
	myArray EQU 0x20	; Address in RAM for data
	counter EQU 0x10	; Address of counter variable
	align	2		; ensure alignment of subsequent instructions 
	
Delay:
	movlw   0xFF
	movwf   0x50, A
Delay_outer:
	movlw   0x01
	movwf   0x51, A
Delay_mid:
	movlw   0x01
	movwf   0x52, A
Delay_inner:
	nop                 
	decfsz  0x52, A
	bra     Delay_inner
	decfsz  0x51, A
	bra     Delay_mid
	decfsz  0x50, A
	bra     Delay_outer
	return
	

start:	
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	12		; 22 bytes to read
	movwf 	counter, A	; our counter register
	
	call    SPI_MasterInit
	goto	loop
	

	
loop:
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movf	TABLAT, W
	call	SPI_MasterTransmit
	decfsz	counter, A
	bra	loop
	
	call	Delay
	goto	0
	

SPI_MasterInit:
	bcf	CKE2
	movlw   (SSP2CON1_SSPEN_MASK) | (SSP2CON1_CKP_MASK) | (SSP2CON1_SSPM1_MASK)
	movwf	SSP2CON1, A 

	bcf	TRISD, PORTD_SDO2_POSN, A 
	bcf	TRISD, PORTD_SCK2_POSN, A
	return 
    
   
SPI_MasterTransmit: 
	movwf	SSP2BUF, A
	
Wait_Transmit: 
	btfss	PIR2, 5, A

	bra	Wait_Transmit
	bcf	PIR2, 5, A
	return
	
	end main