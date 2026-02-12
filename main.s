	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto start
	
	org 0x100
	
start: 
    
	call    SPI_MasterInit
	goto	loop
	
table:
	db	"T","E","M","M","U","Z"
	array	EQU 0x20
	counter	EQU 0x10
	align	2
	
loop:
	movlw	0xAA
	call SPI_MasterTransmit
	bra loop
	

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
	btfss	PIR2, 5

	bra	Wait_Transmit
	bcf	PIR2, 5, A
	return
	
	end main