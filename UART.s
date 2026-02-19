#include <xc.inc>
    
global  Keypad_Setup, Keypad_Read

psect	udata_acs   ; reserve data space in access ram
;variables
Row_State:  ds 1
Col_State:  ds 1
State:	    ds 1
delay_count:ds 1
	
psect	uart_code,class=CODE

Keypad_Setup:
	movlb	0x0F	; we set REPU (default) state to 1
	bsf	REPU
	
	return

Keypad_R_Rows:	; step 1 
	clrf    LATE, A	    ; write all 0s to LATE register
	movlw	0x0F ; first 4 bits are cols (0 - output), last four are rows (1 - input)
	movwf	TRISE, A	; set the first 4 as output, last 4 as input
	
	movf	PORTE, W, A 
	andlw	0x0F   ; mask input (first 4 pins) from rows 
	movwf	Row_State, A 
	return 
	
Keypad_R_Cols: 
	clrf    LATE, A	    ; write all 0s to LATE register
	movlw	0xF0 ; first 4 bits are cols (1 - input), last four are rows (0 - output)
	movwf	TRISE, A	; set the last 4 as output, first 4 as input
	
	movf	PORTE, W, A
	andlw	0xF0   ; mask input (last 4 pins) from columns 
	movwf	Col_State, A
	return
	
Keypad_Read: 
	call	Keypad_R_Rows
	
	movlw	0xFF
	movwf	delay_count, A
	call	delay
	
	call	Keypad_R_Cols
	
	movlw	0xFF
	movwf	delay_count, A
	call	delay
	
	movf	Row_State, W, A 
	iorwf	Col_State, A	    ; combine both states to make a byte
	
	movwf	State, A ; move byte into variable State
	
	movlw   0xFF
	cpfseq  State, A      ; skip next if State == 0xFF
	goto    NoKey             ; W != State ? continue checking
	movlw   0x00              ; no key pressed, return 0
	return
	
	NoKey:

	    ; ----------------------------
	    ; Key 1 ? 0x77
	    ; ----------------------------
	    movlw   0x77
	    cpfseq  State, A
	    goto    Check2
	    movlw   0x01              ; key 1
	    goto    Done

	Check2:
	    ; Key 2 ? 0x7B
	    movlw   0x7B
	    cpfseq  State, A
	    goto    Check3
	    movlw   0x02              ; key 2
	    goto    Done

	Check3:
	    ; Key 3 ? 0x7D
	    movlw   0x7D
	    cpfseq  State, A
	    goto    CheckF
	    movlw   0x03              ; key 3
	    goto    Done

	CheckF:
	    ; Key F ? 0x7E
	    movlw   0x7E
	    cpfseq  State, A
	    goto    Check4
	    movlw   0x0F              ; key F
	    goto    Done

	Check4:
	    ; Key 4 ? 0xB7
	    movlw   0xB7
	    cpfseq  State, A
	    goto    Check5
	    movlw   0x04
	    goto    Done

	Check5:
	    movlw   0xBB
	    cpfseq  State, A
	    goto    Check6
	    movlw   0x05
	    goto    Done

	Check6:
	    movlw   0xBD
	    cpfseq  State, A
	    goto    CheckE
	    movlw   0x06
	    goto    Done

	CheckE:
	    movlw   0xBE
	    cpfseq  State, A
	    goto    Check7
	    movlw   0x0E
	    goto    Done

	Check7:
	    movlw   0xD7
	    cpfseq  State, A
	    goto    Check8
	    movlw   0x07
	    goto    Done

	Check8:
	    movlw   0xDB
	    cpfseq  State, A
	    goto    Check9
	    movlw   0x08
	    goto    Done

	Check9:
	    movlw   0xDD
	    cpfseq  State, A
	    goto    CheckD
	    movlw   0x09
	    goto    Done

	CheckD:
	    movlw   0xDE
	    cpfseq  State, A
	    goto    CheckA
	    movlw   0x0D
	    goto    Done

	CheckA:
	    movlw   0xE7
	    cpfseq  State, A
	    goto    Check0
	    movlw   0x0A
	    goto    Done

	Check0:
	    movlw   0xEB
	    cpfseq  State, A
	    goto    CheckB
	    movlw   0x00
	    goto    Done

	CheckB:
	    movlw   0xED
	    cpfseq  State, A
	    goto    CheckC
	    movlw   0x0B
	    goto    Done

	CheckC:
	    movlw   0xEE
	    cpfseq  State, A
	    goto    Done        ; none matched, fall through
	    movlw   0x0C

	Done:
	    return

	
	
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return
	
	