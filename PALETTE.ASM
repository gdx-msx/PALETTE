; PALETTE v0.9 by GDX
; Command to change the color palette for MSX-DOS
; 
; Assembled with zasm cross assembler
; http://sourceforge.net/projects/zasm/

;S 17	; Remove the semicolon at the beginning of this line to assemble it with GEN80

;DOS
DMA	equ	00080h		; Parameters address
BDOS	equ	00005h		; MSX-DOS function
;Main-ROM
RDSLT	equ	000ch
CALSLT	equ	001ch
BEEP	equ	00c0h		; Beep!
EXTROM	equ	015fh
NMI	equ	0066h
;Sub-ROM
GETPLT	equ	00149h		; Get palette
;System variables
EXPTBL	equ	0fcc1h
H.NMI	equ	0fdd6h
RG16SAV	equ	0FFEFh

	org	0100h

	ld	HL,002dh
	ld	a,(EXPTBL)
	call	RDSLT
	or	a
	jp	z,ForMSX2	; Jump if MSX1

	ld	c,048h		; 'H' character
	call	Param_Srch	; Search the option /h

	jp	z,HELP		; Displays the help if /h is found

	ld	hl,DMA
	ld	a,(hl)
	cp	0dh	
	jp	z,HELP		; Jump if no parameter
	or	a	
	jp	z,HELP		; Jump if no parameter

; Get specified color

Space_TC:
	inc	hl
	ld	a,(hl)
	cp	0dh	
	jp	z,Param_END	; Jump if no color parameter
	or	a	
	jp	z,Param_END	; Jump if no color parameter
	cp	2Ch		; ","	
	jp	z,Syntax_ERR
	cp	20h
	jr	nz,No_Space_TC
	jr	Space_TC
No_Space_TC:
	cp	2Fh		; "0"-1
	jp	c,Syntax_ERR	; Jump if character < "0"
	cp	40h		; "9"+1
	jp	nc,Syntax_ERR	; Jump if character > "9"
	call	GetColorValue
	cp	254
	jp	z,Overflow_ERR
	cp	255
	jp	z,Syntax_ERR
	push	af
	ld	a,c
	ld	(COLOR),a	; Store color value
	pop	af
	or	a
	jp	z,PrintPalette	; Jump if no palette parameter
	cp	0Dh
	jp	z,PrintPalette	; Jump if no palette parameter

; Get specified Red palette

Space_R:
	ld	a,1
	ld	(No_Plt),a

	call	Get_default_Plt

	inc	hl
	ld	a,(hl)
	cp	0dh		; Parameters end	
	jp	z,Param_END
	or	a		; Parameters end	
	jp	z,Param_END
	cp	2Ch		; ","	
	jp	z,Space_G
	cp	20h
	jr	nz,No_Space_R
	jr	Space_R
No_Space_R:
	cp	2Fh		; "0"-1
	jp	c,Syntax_ERR	; Jump if character < "0"
	cp	40h		; "9"+1
	jp	nc,Syntax_ERR	; Jump if character > "9"
	call	Get_Palette_Value
	cp	254
	jp	z,Overflow_ERR
	cp	255
	jp	z,Syntax_ERR
	push	af
	ld	a,c
	ld	(RED),a		; Store red palette value
	pop	af
	or	a
	jp	z,Param_END

; Get specified Green palette

Space_G:
	inc	hl
	ld	a,(hl)
	cp	0dh		; Parameters end	
	jp	z,Param_END
	or	a		; Parameters end	
	jp	z,Param_END
	cp	2Ch		; ","	
	jp	z,Space_B
	cp	20h
	jr	nz,No_Space_G
	jr	Space_G
No_Space_G:
	cp	2Fh		; "0"-1
	jp	c,Syntax_ERR	; Jump if character < "0"
	cp	40h		; "9"+1
	jp	nc,Syntax_ERR	; Jump if character > "9"
	call	Get_Palette_Value
	cp	254
	jp	z,Overflow_ERR
	cp	255
	jp	z,Syntax_ERR
	push	af
	ld	a,c
	ld	(GREEN),a	; Store green palette value
	pop	af
	or	a
	jp	z,Param_END

; Get specified Blue palette

Space_B:
	inc	hl
	ld	a,(hl)
	cp	0dh		; Parameters end	
	jp	z,Param_END
	or	a		; Parameters end	
	jp	z,Param_END
	cp	2Ch		; ","	
	jp	z,Syntax_ERR
	cp	20h
	jr	nz,No_Space_B
	jr	Space_B

No_Space_B:
	cp	2Fh		; "0"-1
	jp	c,Syntax_ERR	; Jump if character < "0"
	cp	40h		; "9"+1
	jp	nc,Syntax_ERR	; Jump if character > "9"
	call	Get_Palette_Value
	cp	254
	jp	z,Overflow_ERR
	cp	255
	jp	z,Syntax_ERR
	push	af
	ld	a,c
	ld	(BLUE),a	; Store blue palette value
	pop	af
	or	a
	jp	z,Param_END

Param_END:
	ld	a,l
	cp	81h
	ret	z		; Back to MSX-DOS

	ld	a,(No_Plt)
	or	a
	jp	z,PrintPalette

	ld	HL,0007h
	ld	a,(EXPTBL)
	call	RDSLT
	ld	c,a
	inc	c		; C= Writing port 1 of VDP

	ld	a,(COLOR)	; Color number...
	di
	out	(c),a
	ld	(RG16SAV),a
	ld	a,80h+16	; ...into register 16 (+80h)
	out	(c),a
	ei

	inc	c		; C= Writing port 2 of VDP
	ld	a,(RED)
	rlca
	rlca
	rlca
	rlca
	ld	b,a
	ld	a,(BLUE)
	or	b
	out	(c),a		; Send red & blue to port 3
	ld	a,(GREEN)
	out	(c),a		; Send green to le port 3

	ret			; Back to MSX-DOS

; Routine to read the default palette

Get_default_Plt:
	push	hl
	ld	ix,GETPLT
	ld	a,(COLOR)
	call	CALSUB
	ld	a,b
	and	0F0h
	rrca
	rrca
	rrca
	rrca
	ld	(RED),a
	ld	a,b
	and	0Fh
	ld	(BLUE),a
	ld	a,c
	ld	(GREEN),a
	pop	hl
	ret

PrintPalette:

	call	Get_default_Plt

	ld	de,ColorTXT
	call	PRINT		; Print

	ld	a,(COLOR)
	cp	10
	jr	nc,TwoDigits	; Jump if COLOR>9
	add	a,30h
	ld	e,a
	ld	c,2
	call	BDOS		; Print a character
	jr	PalIs
TwoDigits:
	ld	e,31h
	ld	c,2
	call	BDOS
	ld	a,(COLOR)
	sub	10		
	add	a,30h
	ld	e,a
	ld	c,2
	call	BDOS
PalIs:
	ld	de,PalisTXT
	call	PRINT		; Print
PrintR:
	ld	a,(RED)
	add	a,30h
	ld	e,a
	ld	c,2
	call	BDOS
	ld	e,02ch		; ","
	ld	c,2
	call	BDOS
PrintG:
	ld	a,(GREEN)
	add	a,30h
	ld	e,a
	ld	c,2
	call	BDOS
	ld	e,02ch		; ","
	ld	c,2
	call	BDOS
PrintB:
	ld	a,(BLUE)
	add	a,30h
	ld	e,a
	ld	c,2
	call	BDOS
	ret

; Entry: The content of the address pointed to by HL must be one digit only.
; Output: A = code for condition, C = value converted, HL = next character
; Modify: AF, BC, HL

Get_Palette_Value:
	sub	30h		; Digit to value
	ld	c,a		; C = color or first digit value
	cp	8
	ld	a,254
	ret	nc		; Back if value >= 8

	inc	hl
	ld	a,(hl)
	or	a		; Parameters end
	ret	z		; Back if character = 0
	cp	0Dh	
	ld	a,0
	ret	z		; back if character = 0Dh
	ld	a,(hl)
	cp	2Ch		; ","	
	ret	z		; back if character = 2Ch

	ld	a,255
	ret

; Entry: The content of the address pointed to by HL must be one or two
;        digit.
; Output: A = code for condition, C = value converted, HL = next character
; Modify: AF, BC, HL

GetColorValue:
	sub	30h		; Digit to value
	ld	c,a		; C = color or first digit value

	inc	hl
	ld	a,(hl)
	or	a		; Parameters end
	ret	z		; Back if character = 0
	cp	0Dh	
	ld	a,0
	ret	z		; back if character = 0Dh
	ld	a,(hl)
	cp	2Ch		; ","	
	ret	z		; back if character = 2Ch

	cp	2Fh		; "0"-1
	ld	a,255
	ret	c		; Back if character < "0"
	ld	a,(hl)
	cp	40h		; "9"+1
	ld	a,255
	ret	nc		; Back if character > "9"
	ld	a,(hl)
	cp	36h		; "6"
	ld	a,254
	ret	nc		; Back if character > "5"

	ld	a,(hl)
	sub	30h		; Digit to value
	ld	b,a		; B = second digit value
	ld	a,c
	cp	1	
	jr	z,Ten_TC	; Jump if character = "1"
	or	a
	jr	z,Zero_TC	; Jump if character = "0"
	ld	a,254
	ret	
Ten_TC:
	ld	a,b
	add	10
	ld	c,a		; C = Value
	jr	Third_digit_TC
Zero_TC:
	ld	c,b		; C = Value

Third_digit_TC:
	inc	hl
	ld	a,(hl)
	cp	2Fh		; "0"-1
	ret	c		; Back if character < "0"
	ld	a,(hl)
	cp	40h		; "9"+1
	ld	a,254
	ret	c		; Back if character < "9"+1
	ld	a,(hl)
	ret

Syntax_ERR:
	ld	de,Syntax_ERR_TXT
	call	PRINT		; Print
	jp	BEEPSND

Overflow_ERR:
	ld	de,Overflow_ERR_TXT
	call	PRINT		; Print
	jp	BEEPSND

; Print a text
; DE = text pointer

PRINT:
	ld	c,9
	jp	BDOS		; Print

; -- Parameter search routine
; Entry: C = Character used as option (A~Z or a~z)
; Output: F = NZ if Parameter not found
; Modify: AF, BC, HL

Param_Srch:
	ld	a,c
	or	020h		; Upper case
	ld	c,a
	ld	hl,DMA
	ld	b,(hl)
	inc	b
ParamBCL:
	inc	hl
	ld	a,(hl)
	cp	02Fh		; Seek '/' character
	jr	nz,SLSH_NTFND	; Jump if '/' is not found
	inc	hl
	ld	a,(hl)
	or	020h		; Upper case
	cp	c		; Compare found character with the input character
	ret	z		; Back if character is found
SLSH_NTFND:
	djnz	ParamBCL
	ret

; Entrée : IX = Adresse à appeler dans la Sub-ROM
;          AF, HL, DE, BC = Paramètres de la routine
;
; Sortie : AF, HL, DE, BC = Dépendent de la routine

CALSUB:
	exx			; Préserve les paramètres
	ex	af,af'		; des registers

	ld	hl,EXTROM	; Place la routine suivante
	push	hl		; dans la pile (longueur = 10)
	ld	hl,0c300h	;
	push	hl		; +0   inc sp
	push	ix		; +1   inc sp
	ld	hl,021ddh	; +2   ld ix,<adresse à appeler>
	push	hl		; +6   nop
	ld	hl,03333h	; +7   jp EXTROM
	push	hl
	ld	hl,0
	add	hl,sp
	ld	a,0c3h
	ld	(H.NMI),a
	ld	(H.NMI+1),hl
	ex	af,af'	; Restore les paramètres
	exx		; des registers

	ld	ix,NMI
	ld	iy,(EXPTBL-1)
	call	CALSLT
	ei

	ld	hl,10 ; Jeter la routine qui sert d'interface
	add	hl,sp
	ld	sp,hl
	ret
HELP:
	ld	de,HelpTXT
	call	PRINT		; Print
	ret			; Back to DOS	
ForMSX2:
	ld	de,ForMSX2_TXT
	call	PRINT		; Print
BEEPSND:
	ld	ix,BEEP
	ld	iy,(EXPTBL-1)
	call	CALSLT
	ret			; Back to DOS
COLOR:
	db	0
RED:
	db	0
GREEN:
	db	0
BLUE:
	db	0
No_Plt:
	db	0
HelpTXT:
	db	"PALETTE v0.9 by GDX",10,13
	db	"Use:",10,13
	db	"palette <color>,<R>,<G>,<B>",10,13
	db	10,13
	db	"color = 0-15",10,13
	db	"R = 0-7",10,13
	db	"G = 0-7",10,13
	db	"B = 0-7",10,13,24h
ColorTXT:
	db	"Color ",24h
PalisTXT:
	db	" palette is ",24h
Syntax_ERR_TXT:
	db	"Syntax error!!!",10,13,24h

Overflow_ERR_TXT:
	db	"Overflow!!!",10,13,24h
ForMSX2_TXT:
	db	"Not for MSX1!!",10,13,24h
