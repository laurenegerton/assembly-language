;Lauren Egerton
;egertonl@oregonstate.edu
;CS271-400
;Assignment #4
;Due 02/14/2016 

TITLE Composite Numbers     (Egerton_Project04.asm)

; Author: Lauren Egerton
; Course / Project ID    CS 271/Assignment #4             Date: 02/14/16
; Description: This program calculates composite numbers. It displays the author's name and program title. 
; It then prompots the user to enter the number of composites to be displayed, and is prompted to enter an
; integer in the range [1...400]. The user then enters a number, n, and the program verifies that it is 
; between 1 and 400 (inclusive of both numbers). If n is out of range, an error message is displayed and the
; user is re-prompted until s/he enters a value in the specified range. The program then calculates and displays
; all of the composite numbers up to and including the nth composite. The results are displayed 10 composites per
; line with at least three spaces between each number.


INCLUDE Irvine32.inc

UPPERLIMIT = 400	;a constant to define the upper limit of numbers to be input by user

.data			;variables defined here

;output variables
intro1	BYTE		"Composite Numbers	Programmed by Lauren Egerton", 0					;display title and author
intro2	BYTE		"Enter the number of composite numbers you would like to see.", 0		;tell user what she will be doings
intro3	BYTE		"I'll accept orders for up to 400 composites.", 0						;notify user of the upper limit she can choose
how_many	BYTE		"Enter the number of composite numbers to display [1...400] : ", 0		;prompt user to now enter the amount of composite numbers to be displayed
error1	BYTE		"Out of range. Try again.", 0										;error message if user enters a number of out of range
spaces	BYTE		"   ", 0														;spaces between each number
goodbye	BYTE		"Results certified by Lauren Egerton. Goodbye!", 0					;parting message

;input variables
amount	DWORD	?	;number of composite numbers user wants to display
count	DWORD	0	;counter for skipping lines
number	DWORD	3	;store number that is being checked; start at 3 + 1, since 1, 2, and 3 are not composite 
check	DWORD	2	;divisor used to check for composite numbers
printed	DWORD	?	;variable to keep track of how many values have been printed

.code
main PROC

call introduction		;call procedures 	
call getUserData
call showComposites
call farewell

	exit	; exit to operating system
main ENDP

;additional procedures

;-----------------------------------------------------
introduction PROC
;
; Displays programmer's name and program title. 
;-----------------------------------------------------
	mov edx, OFFSET intro1					
	call WriteString
	call CrLf
	call Crlf				;skip line for readability

	mov edx, OFFSET intro2			
	call WriteString
	call Crlf

	mov edx, OFFSET intro3			
	call WriteString
	call Crlf
	call Crlf				;skip line for readability

	ret 					
introduction ENDP

;-----------------------------------------------------
getUserData PROC
;
; Prompts user to enter a number between 1 and 400, 
; inclusive.
;-----------------------------------------------------
	mov edx, OFFSET how_many			;prompt user for number of terms to be displayed
	call WriteString
	call ReadInt
	call Validate					;call Validate procedure to check input
	call Crlf	
	ret 					
getUserData ENDP

;-----------------------------------------------------
validate PROC
;
; Checks user input by first checking if it is equal to
; or below the upper limit (400). Next, it saves the
; number in a variable and then checks if number is below
; the lower limit (1). If the number is above 400 or below
; 1, the procedure displays an error message and asks for
; the user to input the number again. The procedure returns
; when the user has input a number between 1 and 400,
; inclusive.
;-----------------------------------------------------
	cmp eax, UPPERLIMIT				;compare user input to UPPERLIMIT
	jbe InputOK					;if input is less than or equal to UPPERLIMIT, jump to InputOK
	ja Oops
CheckInput:
	mov edx, OFFSET how_many			;prompt user for number of terms to be displayed
	call WriteString
	call ReadInt	
	cmp eax, UPPERLIMIT				;compare user input to UPPERLIMIT
	jbe InputOK					;if input is less than or equal to UPPERLIMIT, jump to InputOK
Oops:
	mov edx, OFFSET error1			;if input is out of range, display error message
	call WriteString
	call Crlf
	call Crlf
	call CheckInput				;go to top of loop and ask user for number of terms again
InputOk:							;input is in range,	
	mov amount, eax				;so store number in a variable
CheckForZero:
	cmp amount, 1					;avoid an infinite loop as this will be used for counter
	jb Oops						;if input is below 1, display error message
	ret 					
validate ENDP

;-----------------------------------------------------
showComposites PROC
;
; Uses a MASM loop instruction to display the number of 
; composite numbers (between 1 and 400) chosen by the user.
; This number is stored as the counter variable for the 
; loop. The procedure calls isComposite within the loop to get
; the next number to display. It starts checking at number
; 4, since 1, 2, and 3 are not composite numbers.
;-----------------------------------------------------
	mov ecx, amount	;loop counter set to number of values to be displayed

L1:
	cmp count, 11			
	jb continueLoop				;jump over next line if count, or current number of loops, is below 6
	mov count, 1					;if above 6, start count over at 1
continueLoop:
	call isComposite
	mov eax, number
	inc count						;increment count each time loop completes
	cmp count, 11					;if count is not at 6
	jne EndThen					;skip next line
	call Crlf						;if count is equal to 6, skip a line (leaving 5 terms on each line)
EndThen:
	call WriteDec					;display next term
	mov edx, OFFSET spaces			;with five spaces in between
	call WriteString
	loop L1
	ret 					
showComposites ENDP

;-----------------------------------------------------
isComposite PROC
;
; Checks each number starting at 4. It divides each 
; number first by 2 and checks to see if the remainder
; is 0 - meaning the number is composite. If the remainder
; is not 0, it increments check - the dividend - divides
; again and checks the remainder. This continues until 
; either the reaminder equals 0, in which case it exits the
; procedure to write the composite number in showComposite,
; or it reaches dividend = number - 1, which means it stops
; dividing, increments number and begins the process again
; with the following number.
;-----------------------------------------------------

L2:	
	mov check, 2		;always start with dividend as 2
	inc number
L3:	mov eax, number	;set eax to be dividend - start with 4
	cdq				;clear edx
	div check			;divide 4 / 2
	cmp edx, 0		;if there is no remainder, then this is a composite, leave PROC to display composite
	je EndComp		;the loop is a composite, so exit PROC
	inc check			;try again with next bigger number as divisor
	mov eax, number	;move original number back in to eax
	cmp eax, check		;is the dividend = to the divisor?
	je L2			;if so, we need to exit and try the next number (that one was a prime)
	jmp L3			;start division loop over again, if dividend and divisor are not yet equal

EndComp:
	ret 					
isComposite ENDP

;-----------------------------------------------------
farewell PROC
;
; Displays a goodbye message to the user.
;-----------------------------------------------------
	call Crlf
	call Crlf
	mov edx, OFFSET goodbye
	call WriteString
	call Crlf
	ret 					
farewell ENDP

END main
