;Lauren Egerton
;egertonl@oregonstate.edu
;CS271-400
;Assignment #2
;Due 01/24/2016 

TITLE Fibonacci Numbers     (Egerton_Project02.asm)

; Author: Lauren Egerton
; Course / Project ID : CS 271/Assignment #2         Date: 01/24/2016
; Description: This program calculates Fibonacci numbers. It displays the author's name and the program's title. It will prompt the user to
; input a number between 1 and 46, which will be the number of Fibonacci terms to be calculated. It will validate user input and tell the user
; if the number chosen is out of range, using a post-test loop. It will then calculate the Fibonacci terms using a MASM loop instruction, 
; displaying the results 5 terms per line with at least 5 spaces between terms. It displays a parting message that includes the user's name. 

INCLUDE Irvine32.inc


UPPERLIMIT = 46	;a constant to define the upper limit of terms to be displayed

.data			;variables defined here

intro1	BYTE		"Fibonacci Numbers: A Program by Lauren Egerton",0		;display the title and author
intro2	BYTE		"What's your name? ", 0								;prompt user for name
intro3	BYTE		"Hello, ", 0										;greet user by name
intro4	BYTE		"Enter the number of Fibonacci terms to be displayed.", 0	;ask for number of terms
intro5	BYTE		"Give the number as an integer in the range [1 .. 46] ", 0	;between 1-46
num_terms	DWORD	?												;save number of terms input by user
error1	BYTE		"Out of range. Enter a number in the range [1 .. 46] ", 0	;display error message
how_many	BYTE		"How many Fibonacci terms do you want? ", 0				;ask for number of terms again if input was wrong
goodbye_1	BYTE		"Results certified by Lauren Egerton.", 0				;goodbye message
goodbye_2	BYTE		"Goodbye, ", 0										;goodbye to user by name
userName	BYTE 21 DUP (0)											;max characters user can enter for name
sum		DWORD	?												;accumulator for Fibonacci sequence
last_num	DWORD	?												;stores previous number in sequence
spaces	BYTE		"     ", 0										;displays 5 spaces between each number 
count	DWORD	0												;save number of loops to skip a line every 5 terms

.code
main PROC

;-----------------------------------------------------------------
; introduction
;
; Displays programmer's name and program title. Asks for user's name
; and greets user by name.
;------------------------------------------------------------------ 
	mov edx, OFFSET intro1					
	call WriteString
	call CrLf
	call CrLf

	mov edx, OFFSET intro2			;ask for user's name
	call WriteString

	mov edx, OFFSET userName			;input user's name
	mov ecx, SIZEOF userName
	call ReadString

	mov edx, OFFSET intro3			;greet user by name
	call WriteString
	mov edx, OFFSET userName
	call WriteString
	call Crlf 

;-----------------------------------------------------------------
; userInstructions
;
; Prompts the user to input the number of Fibonacci terms to be 
; displayed.
;----------------------------------------------------------------- 
	mov edx, OFFSET intro4
	call WriteString
	call Crlf

	mov edx, OFFSET intro5			;prompt user to enter an integer between between 1-46
	call WriteString
	call Crlf
	call Crlf

;-----------------------------------------------------------------
; getUserData
;
; Uses a post-test loop to check that the user has entered a number
; in the range of 1 - 46. Asks the user to re-enter the number if
; it is out of range. If input is ok, saves the number in a variable.
;------------------------------------------------------------------ 
CheckInput:
	mov edx, OFFSET how_many			;prompt user for number of terms to be displayed
	call WriteString
	call ReadInt
	cmp eax, UPPERLIMIT				;compare user input to UPPERLIMIT
	jbe InputOk					;if input is less than or equal to UPPERLIMIT, jump to InputOk
	mov edx, OFFSET error1			;if input is out of range, display error message
	call WriteString
	call Crlf
	call Crlf
	jmp CheckInput					;go to top of loop and ask user for number of terms again
					
InputOk:							;input is in range,	
	mov num_terms, eax				;so store number in a variable
	call Crlf

CheckForZero:
	cmp num_terms, 0				;avoid an infinite loop
	je Farewell					;jump to end if user chooses 0
;-----------------------------------------------------------------
; displayFibs
;
; Calculate Fibonacci numbers up to nth term chosen by the user.
; Uses MASM loop instruction to calculate and display each number.
;------------------------------------------------------------------ 
	mov last_num, 1				;Fibonacci sequence starts at 1
	mov sum, 0					;initial sum is 0
	mov eax, last_num				;store last number in eax
	
	mov ecx, num_terms				;set loop counter

Fibonacci:
	cmp count, 6			
	jb continueLoop				;jump over next line if count, or current number of loops, is below 6
	mov count, 1					;if above 6, start count over at 1
continueLoop:
	mov eax, sum					;store next sum in eax
	add eax, last_num				;add current sum and last number in sequence
	mov edx, sum					;hold previous value of sum
	mov last_num, edx				;and store it in last_num for next loop
	mov sum, eax					;store current sum in eax for next loop
	inc count						;increment count each time loop completes
	cmp count, 6					;if count is not at 6
	jne EndThen					;skip next line
	call Crlf						;if count is equal to 6, skip a line (leaving 5 terms on each line)
EndThen:
	call WriteDec					;display next term
	mov edx, OFFSET spaces			;with five spaces in between
	call WriteString
	loop Fibonacci					;loop again until counter reaches 0

;-----------------------------------------------------------------
; farewell
;
; Display parting message that includes user's name.
;------------------------------------------------------------------ 
Farewell:
	call Crlf
	call Crlf
	mov edx, OFFSET goodbye_1		;display goodbye message including programmer's name
	call WriteString
	call Crlf
	mov edx, OFFSET goodbye_2
	call WriteString
	mov edx, OFFSET userName			;and user's name
	call WriteString
	call Crlf 

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
