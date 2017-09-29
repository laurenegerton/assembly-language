;Lauren Egerton
;egertonl@oregonstate.edu
;CS271-400
;Assignment #3
;Due 02/07/2016 

TITLE Integer Accumulator     (Egerton_Project03.asm)

; Author: Lauren Egerton
; Course / Project ID : CS 271/Assignment #3               Date: 02/07/2016
; Description: This program counts and accumulates a list of negative integers and calculates the rounded average of these numbers. 
; It displays the author's name and program title. It asks for the user's name and greets the user by name. It then prompts the user 
; to input numbers between and inclusive of [-100, -1]. It counts and accumulates valid numbers input by the user until the user
; inputs a non-negative number (which is not counted in the accumulation). If the user inputs a number lower than -100, an error message 
; will be displayed and the user is prompted to re-enter a valid number. If the user first enters a non-negative number, a special message 
; is displayed and the program says goodbye to the user. After the user has input negative numbers in the correct range and then entered 
; a non-negative number, the program will then calculate and display the number of valid numbers input by the user as well as the rounded 
; average of those numbers. It will end the program with a parting message inclusive of the user's name.

INCLUDE Irvine32.inc

LOWERLIMIT = -100	;a constant to define the lower limit of negative numbers to be input by user

.data			;variables defined here

;output variables
intro1	BYTE		"Welcome to the Integer Accumulator, by Lauren Egerton", 0						;display title and author
intro2	BYTE		"What is your name? ", 0													;prompt user for name
intro3	BYTE		"Hello, ", 0															;greet user by name
dothis1	BYTE		"Please enter numbers in [-100, -1].", 0									;display first instruction to user
dothis2	BYTE		"Enter a non-negative number when you are finished to see the results.", 0			;display second instruction to user
dothis3	BYTE		"Enter a number: ", 0													;prompt user to enter the number
error1	BYTE		"ERROR! Number must be in range [-100, -1].", 0								;display error message
error2	BYTE		"Enter any non-negative number to finish.", 0								;2nd part of error message
results1	BYTE		"You entered ", 0														;display how many valid numbers were entered by user
results2	BYTE		" valid numbers.  ", 0
give_sum	BYTE		"The sum of your valid numbers is: ", 0										;display the sum of valid number entered by user
give_avg	BYTE		"The rounded average is ", 0												;display the rounded average of the numbers entered by user
goodbye1	BYTE		"Thank you for playing Integer Accumulator!", 0								;display parting message
goodbye2	BYTE		"It's been a pleasure to meet you, ", 0										;say goodbye to user
goodbye3	BYTE		".", 0																;end of sentence
special	BYTE		"Next time, please use negative numbers!", 0									;display if user does not input any negative numbers

;input variables
userName	BYTE 21 DUP (0)	;max characters user can enter for name
sum		SDWORD	?		;accumulator for non-negative numbers

;accumulator and calculations
num_terms	SDWORD	?		;count the number of integers in the correct range input by user; set to 0 at start
quotient	SDWORD	?
remainder	SDWORD	?
check	SDWORD	2

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
	call Crlf

;-----------------------------------------------------------------
; userInstructions
;  
; Prompts user to enter a number between -100 and -1. 
;----------------------------------------------------------------- 
	mov edx, OFFSET dothis1
	call WriteString
	call Crlf

	mov edx, OFFSET dothis2			
	call WriteString
	call Crlf

;------------------------------------------------------------------------
; getUserData
;
; Uses a post-test loop to check that the user has entered a number
; in the range of [-100, -1], inclusive. If the user enters a non-negative
; number, jump to checkValues : if there are no current terms, program 
; jumps to special message and goodbye. If there is at least one term, 
; jump to calculate. Otherwise, count and accumulate the valid user numbers. 
; If user enters a number less than -100, an error message is displayed and 
; Input1 loop begins again.
;------------------------------------------------------------------------- 
	mov num_terms, 0					;set the number of terms to 0
	mov sum, 0						;set the sum to 0

Input1:
	mov edx, OFFSET dothis3				;ask for a number from user
	call WriteString	
	call ReadInt
	jns checkValues					;if number is not signed, jump to Check Values
Input2:
	cmp eax, LOWERLIMIT					;check user input with -100
	jb Error							;if it is less than -100, jump to error message
	add sum, eax						;add current value to the sum (accumulator)
	inc num_terms						;if it is ok, increment number of valid terms input by user
	jmp Input1						;jump to top of loop 1 for next number

checkValues:
	mov ebx, num_terms
	or ebx, ebx						;check if the number of current terms is 0
	jnz Calculate						;jump to calculations if there is at least one correct value
	jz Oops							;jump to special message if current terms is 0 and say goodbye

Error:								;error message is user input is less than -100
	mov edx, OFFSET error1
	call WriteString
	call Crlf
	mov edx, OFFSET error2
	call WriteString
	call Crlf
	jmp Input1						;jump to loop 1 for next number

;-----------------------------------------------------------------
; calculate
;  
; Divides the sum of negative integers by the number of terms input
; by user. It then divides the number of terms by 2 and compares this
; to the remainder from the first division to check if the quotient
; (or average) from the first division should be rounded up, or not.
; If it is to be rounded up, the average is decremented by one, since
; it is a negative number.
;----------------------------------------------------------------- 
Calculate:							;calculate average
	mov edx, 0						;set edx to 0
	mov eax, sum						;dividend
	cdq								;extend EAX into EDX
	mov ebx, num_terms					;divisor
	idiv ebx							;divide signed integers
	mov quotient, eax					;save quoitient in variable
	mov remainder, edx					;save remainder in variable
	
	;calculate the rounded average
	mov edx, 0						;set edx to 0
	neg remainder						;negate the remainder to make it positive
	mov eax, num_terms					;dividend is num_terms
	cdq								;extend EAX into EDX
	mov ebx, check						;divisor is 2 (calculate half of divisor from first set of calculations)
	idiv ebx							;divide signed integers

	cmp eax, remainder					;compare half of divisor to remainder from calculations above
	jae DisplayAvg						;if half the divisor is greater than or equal to the remainder, jump to display
	dec quotient						;if half the divisor is less than the remainder, round "up" (dec since numbers are negative)

;-----------------------------------------------------------------
; displayResults
;  
; Displays the total number of valid numbers input by the user.
; Displays the rounded average of the sum divided by the numbers
; input by the user.
;----------------------------------------------------------------- 
DisplayAvg:
	call Crlf
	mov edx, OFFSET results1
	call WriteString
	mov eax, num_terms					;display number of valid terms input by user
	call WriteDec

;display the sum of the values input by user
	mov edx, OFFSET results2
	call WriteString
	mov edx, OFFSET give_sum				
	call WriteString
	mov eax, sum
	call WriteInt						;display sum of valid terms input by user
	call Crlf

	mov edx, OFFSET give_avg
	call WriteString
	mov eax, quotient
	call WriteInt						;display rounded average
	call Crlf
	jmp Goodbye						;skip special message

;-----------------------------------------------------------------
; goodbye
;  
; If the user first inputs a non-negative number, the program jumps
; to Oops and displays a special message. If the user inputs valid 
; numbers, Oops is skipped. The program ends by displaying a parting
; message to the user, including the user's name.
;----------------------------------------------------------------- 
Oops:								;user did not input a negative number
	call Crlf
	mov edx, OFFSET special				;display message and say goodbye
	call WriteString
	call Crlf

Goodbye:
	mov edx, OFFSET goodbye1				;display goodbye message including programmer's name
	call WriteString
	call Crlf
	mov edx, OFFSET goodbye2
	call WriteString
	mov edx, OFFSET userName				;and user's name
	call WriteString
	mov edx, OFFSET goodbye3
	call WriteString
	call Crlf 



	exit								;exit to operating system
main ENDP



END main
