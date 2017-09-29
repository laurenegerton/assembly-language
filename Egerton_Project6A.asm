;Lauren Egerton
;egertonl@oregonstate.edu
;CS271-400
;Assignment #6A
;Due 03/13/2016 

TITLE Designing low-level I/O procedures     (Egerton_Project6A.asm)

; Author: Lauren Egerton
; Course / Project ID  CS 271/Assignment #6A		Date: 03/13/16
; Description: This program takes input from a user ten times and stores it in the form of a digit string, then 
; converts each digit string to a numeric value and stores that value in an array of double words. Input is
; validated and must be betwen 0 and (2^32 - 1). The numeric values are added together and stored as
; a sum. The average of this sum is calculated and both are displayed to the user. The program converts
; the numeric values, the sum, and the average back to digit strings before displaying them to the user.
; The program also uses macros to get user input and display output.

INCLUDE Irvine32.inc

; macros defined here

getString		MACRO	output, buffer					;getString macro (use Irvine's readString)
	push edx					;save edx register
	push ecx					;save ecx register
	displayString output		;call macro to WriteString
	mov	edx, buffer			
	mov	ecx, 30				;maximum number of characters user can enter
	call	ReadString			;store input in a memory location (variable)
	pop ecx					;restore ecx register
	pop edx					;restore edx register
ENDM

displayString	MACRO	buffer						;displayString macro (use Irvine's WriteString)
	push	edx				;save edx register
	mov	edx, buffer
	call	WriteString
	pop	edx				;restore edx
ENDM

.data

;output variables
title1	BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0			;display title
title2	BYTE		"Written by: Lauren Egerton ", 0										;display author
intro1	BYTE		"Please provide 10 unsigned decimal integers.", 0							;display game explanation
intro2	BYTE		"Each number needs to be small enough to fit inside a 32 bit register.", 0		;and game rules
intro3	BYTE		"After you have finished inputting the raw numbers I will display a list", 0	;explain outcome of game
intro4	BYTE		"of the integers, their sum, and their average value.", 0					;explain outcome of game
dothis1	BYTE		"Please enter an unsigned number: ", 0									;prompt user to enter a number
error1	BYTE		"ERROR: You did not enter an unsigned number or your number was too big.", 0	;display error message
error2	BYTE		"Try again. ", 0													;prompt user to try again
display1	BYTE		"You entered the following numbers: ", 0								;display the numbers entered by the user
display2	BYTE		"The sum of these numbers is: ", 0										;display the sum of numbers entered by the user
display3	BYTE		"The average is: ", 0												;display the average of the numbers
goodbye	BYTE		"Goodbye, and thanks for playing!", 0									;display parting message
space	BYTE		", ", 0															;display spaces between output

;input variables
input	BYTE		30 DUP(0)		;store string input by user - to be converted
output	BYTE		11 DUP(0)		;store converted number as a string for output
number	DWORD	?			;store converted string as number
sum		DWORD	?			;store the sum of numbers entered by the user
average	DWORD	?			;store the average of the numbers entered by the user
arrayList	DWORD	10 DUP(?)		;array to store list of converted integers	
check	DWORD	4294967295	;bigger than this will not fit in a 32-bit register
count	DWORD	0			;keep track of loop

.code
main PROC

;introduction
	displayString OFFSET title1		;pass by address to macro
	call Crlf
	displayString OFFSET title2		;pass by address to macro
	call Crlf						;new paragraph
	call Crlf
	displayString OFFSET intro1		;pass by address to macro
	call Crlf
	displayString OFFSET intro2		;pass by address to macro
	call Crlf
	displayString OFFSET intro3		;pass by address to macro
	call Crlf
	displayString OFFSET intro4		;pass by address to macro
	call Crlf
	call Crlf
	
;get input from user and store in array
	push OFFSET arrayList			;ebp+28
	push	OFFSET number				;ebp+24
	push OFFSET input				;ebp+20
	push OFFSET dothis1				;ebp+16
	push OFFSET error1				;ebp+12
	push OFFSET error2				;ebp+8
	call readVal					;pushed 24 bits onto stack

;add the numbers in the array
	push OFFSET arrayList			;ebp+12
	push OFFSET sum				;ebp+8
	call sumArray					;pushed 8 bits onto stack

								;calculate average
	push OFFSET sum				;ebp+12
	push OFFSET average				;ebp+8
	call Calculate					;pushed 8 bits on stack

	mov esi, OFFSET arrayList		;put address of array in esi
	mov count, 0					;set counter to 0
	call Crlf
	displayString OFFSET display1		
	call Crlf

Show:							;convert numbers in array to strings and display each one
	mov eax, [esi]					;store first int in number variable
	add esi, 4					;next number in array
	mov number, eax				;put first value in array into number
	push OFFSET number				;ebp+12
	push OFFSET output				;ebp+8
	call writeVal					;pushed 8 bits on to stack
	cmp count, 9					;repeat Show 10 times
	je Quit						;leave loop
	displayString OFFSET space		;add comma and space between each string
	inc count						;increment count each time
	jmp Show						;repeat loop
Quit:
	call Crlf
		
;display sum						
	displayString OFFSET display2		
	push OFFSET sum				;ebp+12
	push OFFSET output				;ebp+8
	call writeVal					;pushed 8 bits on to stack
	call Crlf

;display average
	displayString OFFSET display3		;show average
	push OFFSET average				;ebp+12
	push OFFSET output				;ebp+8
	call writeVal					;pushed 8 bits on to stack
	call Crlf						;new paragraph
	call Crlf

;display farewell
	displayString OFFSET goodbye		;farewell
	call Crlf

	exit	; exit to operating system
main ENDP

; ***************************************************************
; Procedure to convert a digit string to numeric and validate
; user input.
; receives: address of array, address of two strings to display,
; address of input variable
; returns: user input as a numeric value in the array
; preconditions: none
; registers changed: none
; ***************************************************************
readVal PROC
	push	ebp
	mov	ebp,esp
	pushad					;save registers
	mov ecx, 10				;outer loop count
	mov edi, [ebp+28]			;store address of array in edi
L1:							
	push ecx					;save registers
Top:
	getString [ebp+16], [ebp+20]	;invoke displayString macro - dothis1 and input parameters	
	mov edx, 0				;set edx to 0
	mov ebx, 0				;reset ebx to 0 for next total
	mov ecx, eax				;string length is the inner loop counter
	mov esi, [ebp+20]			;put input address (user string) in the source register - do i need to movzx in esi?
	cld						;clear direction flag, move forward
Validate:			
	xor eax, eax				;clear eax before lodsb
	lodsb					;put first byte into esi
	cmp al, 48				;validate user input
	jb error					;can only have char 0,1,2,3,4,5,6,7,8,9
	cmp al, 57				;validate string, user input
	ja error
	sub eax, 48				;convert ASCII to number
	push eax					;save current value of eax
	push ecx					;save ecx
	mov eax, ebx				;put current total in eax
	mov ecx, 10				;put 10 into ecx
	mul ecx					;multiply eax * 10
	cmp edx, 0				;is there carry in to edx from eax?
	mov ebx, eax				;put eax * 10 back into total ebx
	pop ecx					;restore ecx
	pop eax					;restore eax
	jnz error					;if edx is not 0, display error
	add ebx, eax				;add current value in eax to ebx for updated total
	jc error
	loop Validate				;loop 10 times to get each char converted to numeric

	mov [edi], ebx				;store value in first element of array
	add edi, 4				;mov edi to next element
	
	pop ecx					;restore registers 
	loop L1

	jmp quit

error:
	displayString [ebp+12]		;error1 parameter
	call Crlf
	displayString [ebp+8]		;error2 parameter
	jmp Top

quit:
	popad					;restore registers
	pop ebp
	ret 24					;pushed 6 OFFSETS, return 6 * 4 bits
readVal ENDP

; ***************************************************************
; Procedure to convert a numeric value to a digit string
; receives: address of input and output variable
; returns: none
; preconditions: input is a numeric value and output is a null-
; terminated string
; registers changed: none
; cite : Prof. Redfield's help with clearing the array in between
; uses. 
; ***************************************************************
writeVal PROC
	push	ebp
	mov	ebp,esp
	pushad				;save registers

	mov edi, [ebp+8]		;edi points to output, a string
	mov esi, [ebp+12]		;esi points to a number (DWORD) to convert

	xor eax, eax			;clear eax	
	mov ecx, 10			;divisor always 10
	xor ebx, ebx			;clear ebx for counter
	mov eax, [esi]			;put number into eax
	cld					;move forward
Convert:					;convert each numeric digit to string
	cdq					;clear edx for division
	div ecx				;divide eax by ecx
	push dx				;will be a number between 0 and 9 in the remainder 
	inc bx				;count number of pushes
	cmp eax, 0			;is eax = 0? 
	jne Convert			;if eax is not 0, keep looping

	mov cx, bx			;loop counter is equal to bx number of pushes 
GetIt:	
	pop ax				;pop all of the dx's into ax's
	add al, 48			;convert numeric digit to ASCII  
	stosb				;store the first char in destination register
	loop GetIt
	
	mov edx, [ebp+8]	     ;display the string (converted number)
	call WriteString
	
	std
     mov al, 0
     mov cx,bx
ClearIt:
     stosb
     loop ClearIt
      
     cld

	popad				;restore registers
	pop ebp
	ret 8
writeVal ENDP

; ***************************************************************
; Procedure to display an array.
; receives: address of array
; returns: prints the array
; preconditions: none
; registers changed: eax, ecx, edi
; cite : Lecture 20 and demo5.asm
; ***************************************************************
showArray	PROC
	push	ebp
	mov	ebp,esp
	mov	ecx,10			;count in ecx
	mov	edi,[ebp+8]		;address of array in edi
	
more:
	mov eax,[edi]			;start with first element
	call WriteDec
	add	edi,4
	loop	more
	
	pop	ebp
	ret	8
showArray	ENDP

; ***************************************************************
; Procedure to sum the numbers in an array
; receives: address of array and variable sum on system stack
; returns: user input in global count
; preconditions: numbers are stored in array
; registers changed: none
; cite : textbook p. 150-151
; ***************************************************************
sumArray PROC
	push ebp		
	mov ebp, esp
	pushad				;save registers

	mov eax, 0			;accumulator
	mov ecx, 10			;loop counter
	mov edi, [ebp+12]		;put address of array in edi

L1:	add eax, [edi]			;add first value to eax
	add edi, 4			;move to next value in array
	loop L1

	mov	edx, [ebp+8]		;address of sum in edx
	mov	[edx], eax		;store sum in global variable

	popad				;restore registers
	pop ebp
	ret 8
sumArray ENDP

; ***************************************************************
; Procedure to calculate the average of a list of numbers
; receives: address of sum  and average variable on system stack
; returns: calculated average at address of variable
; preconditions: sum is calculated
; registers changed: none
; ***************************************************************
calculate PROC				;procedure to caculate average
	push ebp		
	mov ebp, esp

	pushad				;save registers

	mov edi, [ebp+12]		;address of sum in edi
	mov esi, [ebp+8]		;address of average in esi

	mov eax, [edi]			;dereference edi's address = value, dividend
	mov edx, 0			;set edx to 0
	mov ebx, 10			;divisor is 10
	div ebx				;divide eax by ebx
		
	mov [esi], eax			;store quotient in value of average

	popad				;restore registers

	pop ebp
	ret 8
calculate ENDP

END main