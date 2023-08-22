Org 0000h

;;CODE TO GET THE CURRENT FLOOR
Begin:
clr A;
Mov A,#000h; Current floor
Mov R5,A;

Start:
;;LCD MODULE
RS Equ P1.3
E Equ P1.2
; R/W* is hardwired to 0V, therefore it is always in write mode
; ---------------------------------- Main -------------------------------------
Main:
Clr RS ; RS=0 - Instruction register is selected.
;-------------------------- Instructions Code ---------------------------------

Call FuncSet ; Function set (4-bit mode)
Call DispCon ; Turn display and cusor on/off
Call EntryMode ; Entry mode set - shift cursor to the right
call ttt
;----------------------------- Scan for the keys -------------------------------
Next: Call ScanKeyPad
SetB RS ; RS=1 - Data register is selected.
Clr A
Mov A,R7
Call SendChar ;Display the key that is pressed.
Cjne R7,#'#',Next ;Check for "#", if yes, terminate.
EndHere: Jmp Select
;------------------------------ *End Of Main* ---------------------------------
;--------------- Note: Use 7 for Update Frequency in EdSim51 -----------------
;-------------------------------- Subroutines ---------------------------------
; ------------------------- Function set --------------------------------------
FuncSet: Clr P1.7
Clr P1.6
SetB P1.5 ; | bit 5=1
Clr P1.4 ; | (DB4)DL=0 - puts LCD module into 4-bit mode
Call Pulse
Call Delay ; wait for BF to clear
Call Pulse
SetB P1.7 ; P1.7=1 (N) - 2 lines
Clr P1.6
Clr P1.5
Clr P1.4
Call Pulse
Call Delay
Ret
;------------------------------------------------------------------------------
;------------------------------- Display on/off control -----------------------
; The display is turned on, the cursor is turned on
DispCon: Clr P1.7 ; |
Clr P1.6 ; |
Clr P1.5 ; |
Clr P1.4 ; | high nibble set (0H - hex)
Call Pulse
SetB P1.7 ; |

SetB P1.6 ; |Sets entire display ON
SetB P1.5 ; |Cursor ON
SetB P1.4 ; |Cursor blinking ON
Call Pulse
Call Delay ; wait for BF to clear
Ret
;----------------------------- Entry mode set (4-bit mode) ----------------------
; Set to increment the address by one and cursor shifted to the right
EntryMode: Clr P1.7 ; |P1.7=0
Clr P1.6 ; |P1.6=0
Clr P1.5 ; |P1.5=0
Clr P1.4 ; |P1.4=0
Call Pulse
Clr P1.7 ; |P1.7 = '0'
SetB P1.6 ; |P1.6 = '1'
SetB P1.5 ; |P1.5 = '1'
Clr P1.4 ; |P1.4 = '0'
Call Pulse
Call Delay ; wait for BF to clear
Ret

ttt:
clr p1.3
call delay
clr p1.7
clr p1.6
clr p1.5
clr p1.4
setb p1.2
clr p1.2
call delay
clr p1.7
clr p1.6
CLR p1.5
SETB p1.4
setb p1.2
clr p1.2
call delay
call delay
call delay
ret

;--------------------------------------------------------------------------------
;------------------------------------ Pulse --------------------------------------
Pulse: SetB E ; |*P1.2 is connected to 'E' pin of LCD module*
Clr E ; | negative edge on E
Ret
;---------------------------------------------------------------------------------
;------------------------------------- SendChar ----------------------------------
SendChar: Mov C, ACC.7 ; |
Mov P1.7, C ; |
Mov C, ACC.6 ; |
Mov P1.6, C ; |
Mov C, ACC.5 ; |
Mov P1.5, C ; |
Mov C, ACC.4 ; |
Mov P1.4, C ; | high nibble set
;Jmp $
Call Pulse
Mov C, ACC.3 ; |
Mov P1.7, C ; |
Mov C, ACC.2 ; |
Mov P1.6, C ; |
Mov C, ACC.1 ; |
Mov P1.5, C ; |
Mov C, ACC.0 ; |
Mov P1.4, C ; | low nibble set
Call Pulse
Call Delay ; wait for BF to clear
Mov R1,#55h
Ret
;--------------------------------------------------------------------------------
;------------------------------------- Delay ------------------------------------
Delay: Mov R0, #50
Djnz R0, $
Ret
;--------------------------------------------------------------------------------
;------------------------------- Scan Row ---------------------------------------
ScanKeyPad: CLR P0.3 ;Clear Row3
CALL IDCode0 ;Call scan column subroutine
SetB P0.3 ;Set Row 3
JB F0,Done1 ;If F0 is set, end scan
;Scan Row2
CLR P0.2 ;Clear Row2
CALL IDCode1 ;Call scan column subroutine
SetB P0.2 ;Set Row 2
JB F0,Done1 ;If F0 is set, end scan

;Scan Row1
CLR P0.1 ;Clear Row1
CALL IDCode2 ;Call scan column subroutine
SetB P0.1 ;Set Row 1
JB F0,Done1 ;If F0 is set, end scan
;Scan Row0
CLR P0.0 ;Clear Row0
CALL IDCode3 ;Call scan column subroutine
SetB P0.0 ;Set Row 0
JB F0,Done1 ;If F0 is set, end scan

JMP ScanKeyPad ;Go back to scan Row3
Done1: Clr F0 ;Clear F0 flag before exit
Ret
;--------------------------------------------------------------------------------
;---------------------------- Scan column subroutine ----------------------------
IDCode0: JNB P0.4, KeyCode03 ;If Col0 Row3 is cleared - key found
JNB P0.5, KeyCode13 ;If Col1 Row3 is cleared - key found
JNB P0.6, KeyCode23 ;If Col2 Row3 is cleared - key found
RET
KeyCode03: SETB F0 ;Key found - set F0
Mov R7,#'3' ;Code for '3'
Mov R6 ,#003H
RET
KeyCode13: SETB F0 ;Key found - set F0
Mov R7,#'2' ;Code for '2'
Mov R6 ,#002H
RET
KeyCode23: SETB F0 ;Key found - set F0
Mov R7,#'1' ;Code for '1'
Mov R6 ,#001H
RET
IDCode1: JNB P0.4, KeyCode02 ;If Col0 Row2 is cleared - key found
JNB P0.5, KeyCode12 ;If Col1 Row2 is cleared - key found
JNB P0.6, KeyCode22 ;If Col2 Row2 is cleared - key found
RET
KeyCode02: SETB F0 ;Key found - set F0
Mov R7,#'6' ;Code for '6'
Mov R6 ,#006H
RET

KeyCode12: SETB F0 ;Key found - set F0
Mov R7,#'5' ;Code for '5'
Mov R6 ,#005H
RET
KeyCode22: SETB F0 ;Key found - set F0
Mov R7,#'4' ;Code for '4'
Mov R6 ,#004H
RET
IDCode2: JNB P0.4, KeyCode01 ;If Col0 Row1 is cleared - key found
JNB P0.5, KeyCode11 ;If Col1 Row1 is cleared - key found
JNB P0.6, KeyCode21 ;If Col2 Row1 is cleared - key found
RET
KeyCode01: SETB F0 ;Key found - set F0
Mov R7,#'9' ;Code for '9'
Mov R6 ,#009H
RET
KeyCode11: SETB F0 ;Key found - set F0
Mov R7,#'8' ;Code for '8'
Mov R6 ,#008H
RET
KeyCode21: SETB F0 ;Key found - set F0
Mov R7,#'7' ;Code for '7'
Mov R6 ,#007H
RET
IDCode3: JNB P0.4, KeyCode00 ;If Col0 Row0 is cleared - key found
JNB P0.5, KeyCode10 ;If Col1 Row0 is cleared - key found
JNB P0.6, KeyCode20 ;If Col2 Row0 is cleared - key found
RET
KeyCode00: SETB F0 ;Key found - set F0
Mov R7,#'#' ;Code for '#'
RET
KeyCode10: SETB F0 ;Key found - set F0
Mov R7,#'0' ;Code for '0'
Mov R6 ,#000H
RET
KeyCode20: SETB F0 ;Key found - set F0
Mov R7,#'*' ;Code for '*'
RET
;--------------------------------- End of subroutines ---------------------------
Stop: Jmp newpos; Jump to current floor

;;SEVEN SEGMENT DISPLAY

newpos:
clr A;
MOV A,R5; Move the data of R5(Current floor to the Accummulator)
CJNE A,6,NEQU
call StopMotor
jmp Start

NEQU: JC LOC1
call Aclockmotor
dec R5; Increment current
; call StopMotor
jmp select

LOC1: call clockmotor
inc R5 ; Decrementing R5
; call StopMotor
jmp select

Select: SetB P0.7 ;Chip select
SetB P3.3 ;Select Disp
SetB P3.4 ;Select Disp Mov P3,A
Mov A,R5;
CJNE A,#000,num9;
Mov A,#0C0h ;Display data
Mov P1,A
jmp newpos

num9: CJNE A,#009,num8
Mov A,#090h ;Display data
Mov P1,A
jmp newpos
num8: CJNE A,#008,num7
Mov A,#080h ;Display data
Mov P1,A
jmp newpos
num7: CJNE A,#007,num6
Mov A,#0F8h ;Display data

Mov P1,A
jmp newpos
num6: CJNE A,#006,num5
Mov A,#082h ;Display data
Mov P1,A
jmp newpos
num5: CJNE A,#005,num4
Mov A,#092h ;Display data
Mov P1,A
jmp newpos
num4: CJNE A,#004,num3
Mov A,#099h ;Display data
Mov P1,A
jmp newpos
num3: CJNE A,#003,num2
Mov A,#0B0h ;Display data
Mov P1,A
jmp newpos
num2: CJNE A,#002,num1
Mov A,#0A4h ;Display data
Mov P1,A
jmp newpos
num1: Mov A,#0F9h ;Display data
Mov P1,A
jmp newpos

;;MOTOR CONTROL
clockmotor:
MOV R1,#2H
SETB P3.0
CLR P3.1
call Delay1
RET;
Aclockmotor:
SETB P3.1
CLR P3.0
call Delay1
RET
StopMotor:
SETB P3.0

SETB P3.1
call Delay1
RET
Delay1: Mov R1, #50
Djnz R1,$
Ret