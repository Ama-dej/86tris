[BITS 16]
[ORG 0x7C00]

%DEFINE TETROMINO_OFFSET 0x010E ; y : x offset of the field and other stuff.
%DEFINE SCORE_OFFSET 0x0B1D
%DEFINE PAUSED_MESSAGE_LOC 0x0B03

BOOT:
	XOR AX, AX
	MOV DS, AX
	MOV SS, AX
	MOV ES, AX
	MOV BP, 0x7C00
	MOV SP, BP ; Setup some stuff.

	MOV BYTE[DRIVE_NUMBER], DL

	MOV AH, 0x02
	MOV AL, 4
	MOV BX, 0x7E00
	XOR CH, CH
	MOV CL, 2
	XOR DH, DH ; INT 0x13 parameters.

	MOV DI, 10

READ_DISK: ; Try to read the disk 10 times.
	PUSH AX
	INT 0x13
	POP AX ; INT 0x13 modifies the AX register.
	JNC READ_SUCCESS
	DEC DI
	JNZ READ_DISK

	MOV SI, DISK_ERROR
	CALL PUTS ; Print the error message.

	MOV AH, 0x00
	INT 0x16 ; Wait for a key.

	JMP 0xFFFF:0x0000 ; Jump to the reset vector.

READ_SUCCESS:
	JMP 0x0000:0x7E00 ; Jump to our loaded address

; Prints a message on the screen.
;
; SI -> Location of the string.
PUTS:
	PUSH AX
	PUSH SI

	MOV AH, 0x0E

.LOOP:
	LODSB
	OR AL, AL
	JZ .OUT
	INT 0x10
	JMP SHORT .LOOP

.OUT:
	POP SI
	POP AX
	RET

; Writes a coloured block at a given location.
;
; BH -> Page.
; BL -> Colour.
; DH -> Row.
; DL -> Column.
WRITE_BLOCK:
	PUSH AX
	PUSH CX

	MOV AH, 0x02
	INT 0x10

	MOV AH, 0x09
	MOV AL, ' '
	MOV CX, 1
	INT 0x10

	POP CX
	POP AX
	RET

; Writes n amount of characters at a given location.
;
; AL -> Character.
; BH -> Page.
; BL -> Colour.
; DH -> Row.
; DL -> Column.
; CX -> Count.
WRITE_CHAR:
	PUSH AX

	MOV AH, 0x02
	INT 0x10

	MOV AH, 0x09
	INT 0x10

	POP AX
	RET

; Converts an integer to a buffer in memory.
; AX -> Number.
ITOA:
	PUSHA

	MOV BX, SCORE - 2
	MOV CX, 10
	MOV DI, 5

.LOOP:
	XOR DX, DX
	DIV CX

	ADD DL, 48
	MOV BYTE[BX], DL
	DEC BX

	DEC DI
	JNZ .LOOP

.OUT:
	POPA
	RET

DRIVE_NUMBER: DB 0

DISK_ERROR: DB "Read failed, press any key to reboot.", 0x00
NEXT_MSG: DB "NEXT", 0x00
GAME: DB "Game", 0x00
OVER: DB "over", 0x00
LINES: DB "Lines:", 0x00
HIGH: DB "High score:", 0x00

ASCII_NUM: DB "00000", 0x00

SCORE: DW 0
FALL_DELAY: DW 350 

NEXT_TETROMINO: DW 0
NEXT_TETROMINO_COLOUR: DB 0

TETROMINO_COORDS:
TETROMINO_X: DB 0
TETROMINO_Y: DB 0

TETROMINO_PREV_COORDS:
TETROMINO_PREV_X: DB 0
TETROMINO_PREV_Y: DB 0

TETROMINO_COLOUR: DB 0
TETROMINO_ROTATION: DW 0

TETROMINO_CUR_BUFFER: DW 0
TETROMINO_PREV_BUFFER: DW 0

; Offsets for each tetromino.
I_TETROMINO:
DW 0x0100, 0x0101, 0x0102, 0x0103
DW 0x0002, 0x0102, 0x0202, 0x0302
DW 0x0200, 0x0201, 0x0202, 0x0203
DW 0x0001, 0x0101, 0x0201, 0x0301
J_TETROMINO:
DW 0x0000, 0x0100, 0x0101, 0x0102
DW 0x0001, 0x0002, 0x0101, 0x0201
DW 0x0100, 0x0101, 0x0102, 0x0202
DW 0x0001, 0x0101, 0x0200, 0x0201
L_TETROMINO:
DW 0x0002, 0x0100, 0x0101, 0x0102
DW 0x0001, 0x0101, 0x0201, 0x0202
DW 0x0100, 0x0101, 0x0102, 0x0200
DW 0x0000, 0x0001, 0x0101, 0x0201
O_TETROMINO:
DW 0x0001, 0x0002, 0x0101, 0x0102
DW 0x0001, 0x0002, 0x0101, 0x0102
DW 0x0001, 0x0002, 0x0101, 0x0102
DW 0x0001, 0x0002, 0x0101, 0x0102
S_TETROMINO:
DW 0x0001, 0x0002, 0x0100, 0x0101
DW 0x0001, 0x0101, 0x0102, 0x0202
DW 0x0101, 0x0102, 0x0200, 0x0201
DW 0x0000, 0x0100, 0x0101, 0x0201
T_TETROMINO:
DW 0x0001, 0x0100, 0x0101, 0x0102
DW 0x0001, 0x0101, 0x0102, 0x0201
DW 0x0100, 0x0101, 0x0102, 0x0201
DW 0x0001, 0x0100, 0x0101, 0x0201
Z_TETROMINO:
DW 0x0000, 0x0001, 0x0101, 0x0102
DW 0x0002, 0x0101, 0x0102, 0x0201
DW 0x0100, 0x0101, 0x0201, 0x0202
DW 0x0001, 0x0100, 0x0101, 0x0200

; Give them some nice colours.
TETROMINO_COLOURS:
DB 0xB7
DB 0x17
DB 0x67
DB 0xE7
DB 0xA7
DB 0xD7
DB 0x47

FIELD_DATA:
TIMES 23 DW 0
DW 0xFFFF

TIMES 510 - ($ - $$) DB 0
DW 0xAA55

SETUP:
	MOV AH, 0x00
	MOV AL, 0x01
	INT 0x10 ; Change to 40x25.

	MOV AH, 0x01
	MOV CX, 0x2607
	INT 0x10 ; Make the cursor invisible.

	MOV AX, 0x1003
	MOV BL, 0x00
	INT 0x10 ; Turn off blinking attribute. 

	MOV BX, 0x0007

	MOV AL, 0xC9
	MOV DL, (TETROMINO_OFFSET & 0xFF) - 1
	MOV DH, 0
	MOV CX, 1
	CALL WRITE_CHAR ; Corner character of the border.

	MOV AL, 0xCD
	MOV DL, TETROMINO_OFFSET & 0xFF 
	MOV CX, 17
	CALL WRITE_CHAR ; Top side of the border.

	MOV AH, 0x02
	XOR BX, BX
	MOV DH, (TETROMINO_OFFSET >> 8) - 1
	MOV DL, (TETROMINO_OFFSET & 0xFF) + 12
	INT 0x10 ; "NEXT" string position.

	MOV SI, NEXT_MSG
	CALL PUTS

	MOV BX, 0x0007

	MOV AL, 0xCB
	MOV DL, (TETROMINO_OFFSET & 0xFF) + 10
	MOV CX, 1
	CALL WRITE_CHAR ; More border characters...

	MOV AL, 0xCD
	MOV DH, 5
	MOV DL, (TETROMINO_OFFSET & 0xFF) + 11
	MOV CX, 6
	CALL WRITE_CHAR

	MOV AL, 0xBA
	MOV DH, 1
	MOV DL, (TETROMINO_OFFSET & 0xFF) + 17
	MOV CX, 1
	MOV DI, 4

.NEXT_DRAW_LOOP: ; This draws the border around the next tetromino.
	CALL WRITE_CHAR
	INC DH

	DEC DI
	JNZ .NEXT_DRAW_LOOP

	MOV CX, 1
	MOV DI, 23
	MOV DH, 1 
	MOV AL, 0xBA

BORDER_LOOP:
	MOV DL, (TETROMINO_OFFSET & 0xFF) - 1 
	CALL WRITE_CHAR

	MOV DL, (TETROMINO_OFFSET & 0xFF) + 10 
	CALL WRITE_CHAR

	INC DH
	DEC DI
	JNZ BORDER_LOOP

	MOV AL, 0xCC
	MOV DH, 5
	MOV DL, (TETROMINO_OFFSET & 0xFF) + 10
	MOV CX, 1 
	CALL WRITE_CHAR

	MOV AL, 0xBC
	ADD DL, 7
	CALL WRITE_CHAR

	MOV AL, 0xBB
	SUB DH, 5
	CALL WRITE_CHAR
	
	MOV AL, 0xC8
	MOV DL, (TETROMINO_OFFSET & 0xFF) - 1
	MOV DH, 24 
	MOV CX, 1
	CALL WRITE_CHAR

	MOV AL, 0xCD
	MOV DL, TETROMINO_OFFSET & 0xFF 
	MOV CX, 10
	CALL WRITE_CHAR

	MOV AL, 0xBC
	MOV DL, (TETROMINO_OFFSET & 0xFF) + 10
	MOV CX, 1
	CALL WRITE_CHAR

	MOV AH, 0x02
	XOR BX, BX
	MOV DX, SCORE_OFFSET - 0x0100 
	INT 0x10 

	MOV SI, LINES
	CALL PUTS

	MOV DX, ((SCORE_OFFSET & 0xFF00) + 0x0300) | ((SCORE_OFFSET & 0x00FF) - 2)
	INT 0x10

	MOV SI, HIGH
	CALL PUTS

	JMP GEN_FIRST_PIECE

NEW_PIECE:
	MOV AH, 0x00
	INT 0x1A ; Get clock ticks since midnight.

	PUSH DX

	MOV AH, 0x02
	INT 0x1A ; Get current time.

	POP AX
	ADD AX, DX ; Add the clock ticks and time together.
	XOR DX, DX

	MOV BX, 7
	DIV BX ; Divide by 7 to get the index of the tetromino.

	MOV BL, BYTE[NEXT_TETROMINO_COLOUR]
	MOV BYTE[TETROMINO_COLOUR], BL ; Update the colour.

	MOV BX, TETROMINO_COLOURS
	ADD BX, DX
	MOV AL, BYTE[BX]
	MOV BYTE[NEXT_TETROMINO_COLOUR], AL ; Get the new colour for the next tetromino.

	SHL DX, 5 ; Multiply by 32 (because each tetromino is 32 bytes large).
	ADD DX, I_TETROMINO

	MOV AX, WORD[NEXT_TETROMINO]
	MOV WORD[TETROMINO_CUR_BUFFER], AX ; The current tetromino becomes the next one.
	MOV WORD[TETROMINO_PREV_BUFFER], AX 

	MOV WORD[NEXT_TETROMINO], DX ; Update the next tetromino.

	MOV WORD[TETROMINO_COORDS], 0x0004 ; Reset the coords to the top of the field.
	MOV WORD[TETROMINO_PREV_COORDS], 0x0004

	MOV WORD[TETROMINO_ROTATION], 0

	XOR BX, BX
	MOV DX, ((TETROMINO_OFFSET + 0x100) & 0xFF00) | ((TETROMINO_OFFSET + 12) & 0x00FF)

	MOV DI, 4
	MOV CX, 2

.CLEAR_LOOP: ; Clear the previous next tetromino to make place for the new one.
	CALL WRITE_BLOCK

	INC DL
	DEC DI
	JNZ .CLEAR_LOOP

	MOV DI, 4
	INC DH
	SUB DL, 4

	DEC CX
	JNZ .CLEAR_LOOP

	MOV BX, WORD[NEXT_TETROMINO]
	MOV DI, 4

.WRITE_LOOP: ; Then write the next tetromino.
	MOV DX, WORD[BX]
	ADD DL, 12 
	ADD DH, 1
	ADD DX, TETROMINO_OFFSET

	PUSH BX
	XOR BH, BH
	MOV BL, BYTE[NEXT_TETROMINO_COLOUR]
	CALL WRITE_BLOCK
	POP BX

	ADD BX, 2

	DEC DI
	JNZ .WRITE_LOOP

	JMP MOVE

START:
	MOV AH, 0x01
	INT 0x16 ; Check if a key is pressed.

	JZ DELAY ; If not do nothing.

	MOV AH, 0x00
	INT 0x16 ; Get the key.

	OR AL, 0b00100000 ; Convert to lowercase (so it works even if caps lock is on).

SKIP_INPUT:
	CMP AL, 'w'
	JE W_PRESSED

	CMP AL, 's'
	JE S_PRESSED

	CMP AL, 'a'
	JE A_PRESSED

	CMP AL, 'd'
	JE D_PRESSED

	CMP AL, ' '
	JE SPACE_PRESSED

	CMP AL, 'p'
	JE P_PRESSED

	JMP DELAY

P_PRESSED: ; Pause the game.
	CMP WORD[PAUSED_DELAY], 0 ; So you can't spam the pause key.
	JNZ DELAY

	MOV AX, WORD[FALL_DELAY]
	SHL AX, 1
	ADD AX, WORD[FALL_DELAY]
	MOV WORD[PAUSED_DELAY], AX ; Reset the delay.

	MOV AH, 0x02
	XOR BX, BX
	MOV DX, PAUSED_MESSAGE_LOC 
	INT 0x10 ; Change cursor location to the left side of the screen.

	MOV SI, PAUSED_MSG
	CALL PUTS

.WAIT_FOR_P_PRESS:
	MOV AH, 0x00 
	INT 0x16

	OR AL, 0b00100000

	CMP AL, 'p'
	JNE .WAIT_FOR_P_PRESS

	MOV AH, 0x02
	XOR BX, BX
	MOV DX, PAUSED_MESSAGE_LOC 
	INT 0x10 ; Change cursor back to clear the string.

	MOV SI, CLEAR_PAUSED_MSG
	CALL PUTS

	MOV SI, 1 ; After unpausing force the piece to fall down (so the player can't cheat by spamming the pause button).
	
	JMP DELAY

W_PRESSED:
	ADD WORD[TETROMINO_ROTATION], 8 ; "Rotate" right (each tetromino image is 8 bytes large).
	AND WORD[TETROMINO_ROTATION], 0x001F ; So it doesn't overflow.

	JMP CHECK_MOVE 

S_PRESSED:
	SUB WORD[TETROMINO_ROTATION], 8 ; Same thing but "rotate" left.
	AND WORD[TETROMINO_ROTATION], 0x001F

	JMP CHECK_MOVE 

A_PRESSED:
	DEC BYTE[TETROMINO_X] ; If we want to go left decrement the X coordinate.

	JMP CHECK_MOVE 

D_PRESSED:
	INC BYTE[TETROMINO_X] ; Same thing as going left but instead increment.

	JMP CHECK_MOVE 

SPACE_PRESSED:
	INC BYTE[TETROMINO_Y] ; Go down.

	MOV BX, WORD[TETROMINO_CUR_BUFFER]
	ADD BX, WORD[TETROMINO_ROTATION]
	MOV DI, 4

	PUSH BX

.CHECK_OVERLAP: ; Checks if the piece overlaps. 
	MOV DX, WORD[BX]

	PUSH BX

	MOV BX, FIELD_DATA
	ADD DH, BYTE[TETROMINO_Y]
	MOVZX CX, DH
	SHL CX, 1
	ADD BX, CX ; Get the corresponding field data.

	MOV AX, WORD[BX]
	ADD DL, BYTE[TETROMINO_X]
	MOV CL, 9
	SUB CL, DL
	SHR AX, CL ; This is done by shifting the bit in the y coordinate of the block by x times to the right.
	AND AX, 0x0001

	POP BX
	JNZ WRITE_TO_FIELD ; If there is a one it means our piece overlaps. 
	ADD BX, 2

	DEC DI
	JNZ .CHECK_OVERLAP

	POP BX
	JMP MOVE 

WRITE_TO_FIELD:
	DEC BYTE[TETROMINO_Y]
	POP BX
	PUSH BX
	MOV DI, 4

.WRITE_LOOP:
	MOV DX, WORD[BX]

	PUSH BX

	MOV BX, FIELD_DATA
	ADD DH, BYTE[TETROMINO_Y]
	MOVZX CX, DH
	SHL CX, 1
	ADD BX, CX ; Get the corresponding field data.

	ADD DL, BYTE[TETROMINO_X]
	MOV CL, 9 
	SUB CL, DL
	MOV DX, 1
	SHL DX, CL ; Write to the field with the same logic as before.
	OR WORD[BX], DX

	POP BX
	ADD BX, 2

	DEC DI
	JNZ .WRITE_LOOP

	POP BX

	MOV DX, WORD[BX]

	MOV BX, FIELD_DATA
	ADD DH, BYTE[TETROMINO_Y]
	MOVZX CX, DH
	SHL CX, 1
	ADD BX, CX

	MOV DI, 4

.CLEAR_ROW:
	PUSH BX

	MOV AX, WORD[BX]
	CMP AX, 0x03FF ; Check if the row is full.
	JNE .UPDATE_OUT

	INC WORD[SCORE] ; Increment the score by one.

.UPDATE_LOOP:
	MOV AX, WORD[BX - 2]
	MOV WORD[BX], AX ; Move the field one down.

	PUSH AX
	PUSH BX

	SUB BX, FIELD_DATA
	SHR BX, 1
	MOV DH, BL
	MOV DL, TETROMINO_OFFSET & 0xFF
	XOR BX, BX
	MOV CL, 10

	ADD DH, (TETROMINO_OFFSET >> 8) & 0xFF
	DEC DH

.UPDATE_GRAPHICS: ; Now we also have to update the graphics.
	MOV AH, 0x02
	INT 0x10

	MOV AH, 0x08
	INT 0x10

	INC DH

	MOVZX BX, AH
	CALL WRITE_BLOCK

	DEC DH
	INC DL
	DEC CL
	JNZ .UPDATE_GRAPHICS

	POP BX
	POP AX

	OR AX, AX
	JZ .UPDATE_OUT ; Do this until we find an empty field space.

	SUB BX, 2
	JMP SHORT .UPDATE_LOOP

.UPDATE_OUT:
	POP BX
	ADD BX, 2

	DEC DI
	JNZ .CLEAR_ROW

	MOV AH, 0x02
	XOR BX, BX
	MOV DX, SCORE_OFFSET 
	INT 0x10 

	MOV AX, WORD[SCORE]
	CALL ITOA ; Update the score.

	PUSH SI
	MOV SI, ASCII_NUM
	CALL PUTS
	POP SI

	AND AX, 0x000F
	JNZ .NO_DECREASE ; Every 16 lines cleared increase the falling speed.

	CMP WORD[FALL_DELAY], 150 ; If the falling speed is already to high then don't.
	JLE .NO_DECREASE

	SUB WORD[FALL_DELAY], 5 

.NO_DECREASE:
	OR WORD[FIELD_DATA + 2], 0
	JNZ GAME_OVER ; if the second row of the field from the top has something in it, it's game over.

	JMP NEW_PIECE
	
CHECK_MOVE: ; Basically check if any of the pieces are out of bounds.
	MOV BX, WORD[TETROMINO_CUR_BUFFER]
	ADD BX, WORD[TETROMINO_ROTATION]
	MOV DI, 4

.CHECK_LOOP:
	MOV DX, WORD[BX]
	ADD DX, WORD[TETROMINO_COORDS]

	CMP DL, 0
	JL REVERT

	CMP DL, 10 ; Checks if the y coordinate of each block is inside the field.
	JGE REVERT ; If it's not we have to revert the piece to it's previous position.

	ADD BX, 2

	DEC DI
	JNZ .CHECK_LOOP

	MOV BX, WORD[TETROMINO_CUR_BUFFER]
	ADD BX, WORD[TETROMINO_ROTATION]
	MOV DI, 4

.CHECK_OVERLAP: ; We also have to prevent rotating the tetromino into pieces.
	MOV DX, WORD[BX]

	PUSH BX

	MOV BX, FIELD_DATA
	ADD DH, BYTE[TETROMINO_Y]
	MOVZX CX, DH
	SHL CX, 1
	ADD BX, CX

	MOV AX, WORD[BX]
	ADD DL, BYTE[TETROMINO_X]
	MOV CL, 9
	SUB CL, DL
	SHR AX, CL ; This is done with the same logic as when the piece moves down.
	AND AX, 0x0001

	POP BX
	JNZ REVERT 
	ADD BX, 2

	DEC DI
	JNZ .CHECK_OVERLAP

	JMP MOVE

REVERT:
	MOV AX, WORD[TETROMINO_PREV_BUFFER]
	SUB AX, WORD[TETROMINO_CUR_BUFFER]
	MOV WORD[TETROMINO_ROTATION], AX ; Reset the rotation.

	MOV AX, WORD[TETROMINO_PREV_COORDS]
	MOV WORD[TETROMINO_COORDS], AX ; Set to the previous position.

	JMP DELAY

MOVE: ; Give the illusion of movement.
	MOV BX, WORD[TETROMINO_PREV_BUFFER]
	MOV DI, 4

.CLEAR_LOOP: ; First clear the previous location.
	MOV DX, WORD[BX]
	ADD DL, BYTE[TETROMINO_PREV_X] 
	ADD DH, BYTE[TETROMINO_PREV_Y]
	ADD DX, TETROMINO_OFFSET

	PUSH BX
	MOV BX, 0x0007
	CALL WRITE_BLOCK
	POP BX

	ADD BX, 2

	DEC DI
	JNZ .CLEAR_LOOP

	MOV BX, WORD[TETROMINO_CUR_BUFFER]
	ADD BX, WORD[TETROMINO_ROTATION]
	MOV DI, 4

.WRITE_LOOP: ; Then write the new location.
	MOV DX, WORD[BX]
	ADD DL, BYTE[TETROMINO_X]
	ADD DH, BYTE[TETROMINO_Y]
	ADD DX, TETROMINO_OFFSET

	PUSH BX
	XOR BH, BH
	MOV BL, BYTE[TETROMINO_COLOUR]
	CALL WRITE_BLOCK
	POP BX

	ADD BX, 2

	DEC DI
	JNZ .WRITE_LOOP

	SUB BX, 8
	MOV WORD[TETROMINO_PREV_BUFFER], BX
	MOV AX, WORD[TETROMINO_COORDS]
	MOV WORD[TETROMINO_PREV_COORDS], AX

DELAY:
	MOV AH, 0x86
	XOR CX, CX
	MOV DX, 0x03E8
	INT 0x15 ; Wait for 1ms.

	OR WORD[PAUSED_DELAY], 0
	JZ .SKIP
	DEC WORD[PAUSED_DELAY]

.SKIP:
	DEC SI
	JNZ START ; Wait N times for 1ms so it looks like a N ms delay.

	MOV SI, WORD[FALL_DELAY] ; Reset the counter.
	MOV AL, ' ' ; It's stupid but it works.
	JMP SKIP_INPUT 

GAME_OVER:
	MOV AH, 0x02
	XOR BX, BX
	MOV DX, 0x0A11
	INT 0x10 ; Change cursor location to around the middle of the screen.

	MOV SI, GAME
	CALL PUTS ; Print "Game".

	MOV AH, 0x02
	MOV DX, 0x0D11
	INT 0x10 ; Move down a bit.

	MOV SI, OVER
	CALL PUTS ; Print "over".

	MOV AX, WORD[SCORE]
	CMP AX, WORD[HIGH_SCORE] ; Check if the score is higher than the high score.

	JLE NOT_BEATEN	

	MOV WORD[HIGH_SCORE], AX ; If it is update it.

	MOV AH, 0x03
	MOV AL, 1
	XOR CH, CH
	MOV CL, 5 
	XOR DH, DH
	MOV DL, BYTE[DRIVE_NUMBER]
	MOV BX, HIGH_SCORE

	MOV DI, 10

.TRY_10_TIMES:
	PUSH AX
	INT 0x13 ; Then write the new high score to the disk.
	POP AX
	JNC NOT_BEATEN

	DEC DI
	JNZ .TRY_10_TIMES ; Try this 10 times before giving up.

NOT_BEATEN:
	XOR AX, AX
	MOV WORD[SCORE], AX
	CALL ITOA

	MOV BX, FIELD_DATA
	MOV DI, 23

.CLEAR_FIELD_DATA: ; We have to set the field to zeros.
	MOV WORD[BX], 0
	ADD BX, 2

	DEC DI
	JNZ .CLEAR_FIELD_DATA

	MOV AH, 0x86
	MOV CX, 0x0007 
	MOV DX, 0xA120 
	INT 0x15 ; Wait for 500ms.

	MOV AH, 0x00
	INT 0x16

	MOV DX, TETROMINO_OFFSET
	XOR BX, BX

	MOV CX, 10
	MOV DI, 23

.CLEAR_FIELD_GRAPHICS: ; Then visually clear the field.
	CALL WRITE_BLOCK

	INC DL
	DEC CX 
	JNZ .CLEAR_FIELD_GRAPHICS

	MOV DL, TETROMINO_OFFSET & 0xFF
	INC DH
	MOV CX, 10 

	DEC DI
	JNZ .CLEAR_FIELD_GRAPHICS

GEN_FIRST_PIECE: ; When we start a new game there are some things we have to do first.
	MOV AH, 0x02
	XOR BX, BX
	MOV DX, SCORE_OFFSET
	INT 0x10

	MOV SI, ASCII_NUM
	CALL PUTS ; Print the scores for the first time.

	MOV DX, SCORE_OFFSET + 0x0400
	INT 0x10

	MOV AX, WORD[HIGH_SCORE]
	CALL ITOA ; Don't forget about the high score.

	MOV SI, ASCII_NUM
	CALL PUTS

	MOV SI, WORD[FALL_DELAY] 

	MOV AH, 0x02
	INT 0x1A ; Generate the first piece.

	MOV AX, DX
	XOR DX, DX

	MOV BX, 7
	DIV BX 

	MOV BX, TETROMINO_COLOURS
	ADD BX, DX
	MOV AL, BYTE[BX]
	MOV BYTE[NEXT_TETROMINO_COLOUR], AL ; Same logic as the code under the NEW_PIECE label.

	SHL DX, 5
	ADD DX, I_TETROMINO
	MOV WORD[NEXT_TETROMINO], DX

	JMP NEW_PIECE 

HALT:
	HLT
	JMP SHORT HALT

PAUSED_MSG: DB "Paused", 0x00 ; This message is here because the boot sector ran out of space.
CLEAR_PAUSED_MSG: DB "      ", 0x00
PAUSED_DELAY: DW 1050

TIMES 2048 - ($ - $$) DB 0
HIGH_SCORE: DW 0
