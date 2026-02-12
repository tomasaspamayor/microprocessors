	#include <xc.inc>
	
psect	code, abs

SPI_MasterInit:
	bcf	CKE2
	movlw   (SSPCON1_SSPEN_MSK) | (SSP2CON1_CKP_MASK) | (SSP2CON1_SSPM1_MASK)
	movwf	SSP2CON1, A 

	bcf	TRISD, PORTD_SDO2_POSN, A 
	bcf	TRISD, PORTD_SCK2_POSN, A
	return 
    
   
SPI_MasterTransmit: 
	movwf	SSP2BUF, A 
Wait_Transmit: 
	btfss	PIR2, 5

	bra	Wait_Transmit
	bcf	PIR2, 5
	return