;Lauren Egerton
;egertonl@oregonstate.edu
;CS271-400
;Assignment #5
;Due 02/28/2016 

TITLE Sorting Random Integers     (Egerton_Project05.asm)

; Author: Lauren Egerton
; Course / Project ID   CS 271/Assignment #5               Date: 02/28/16
; Description: This program displays a list of random integers (both sorted and unsorted) and calculates and 
; displays the median of the sorted list. It displays the author's name and program title. It prompts the user to
; enter n number of integers between 10 and 200 (inclusive) to be displayed. The program validates user input and
; re-prompts the user if the input is not in the correct range. It then generates n random integers between 100 and 999,
; inclusive, and saves them in an array. The program displays the list of n integers, sorts the array, and 
; calculates the median of the sorted list of integers. If there is an even number of integers, it calculates the 
; average of the two middle numbers, rounding up if the remainder is .5. The program then displays the median and then
; the sorted list of n integers. The program is constructed using the following procedures, in addition to main : 
; introduction, getData, fillArray, showArray, sortList, and showMedian. The program uses four global constant variables 
; and passes arguments to the procedures both by value and by reference.

;Implementation Note : Parameters are passed on the system stack.

INCLUDE Irvine32.inc

; (constant variables)
MIN = 10		;minimum user request 
MAX = 200		;maximum user request
LO = 100		;minimum integer range
HI = 999		;maximum integer range
	
.data

;output variables
intro1	BYTE	"Sorting Random Integers		      Programmed by Lauren Egerton", 0			;title
intro2	BYTE	"This program generates random numbers in the range [100 .. 999],", 0			;introduction
intro3	BYTE	"displays the original list, sorts the list, and calculates the", 0			;introduction
intro4	BYTE "median value. Finally, it displays the list sorted in descending order.", 0	;introduction
dothis	BYTE	 "How many numbers should be generated? [10 .. 200]: ", 0					;get user input
error	BYTE	 "Invalid input", 0													;error message
title1	BYTE	 "The unsorted random numbers: ", 0									;title for unsorted list				
title2	BYTE	 "The sorted list: ", 0												;title for sorted list				
title3	BYTE	 "The median is ", 0												;title for median					

;input variables
request		DWORD	?			;store user input for number of integers to generate
arrayList		DWORD	MAX DUP(?)	;array to store list of integers

.code
main PROC
; (insert executable instructions here)
call Randomize						;re-seed random number generator

push OFFSET intro1					;push address of intro on to stack
push OFFSET intro2					;push address of intro on to stack
push OFFSET intro3					;push address of intro on to stack
push OFFSET intro4					;push address of intro on to stack
call introduction

push OFFSET dothis					;push address of instructions on to stack
push OFFSET error					;push address of error message on to stack
push OFFSET request					;push address of input variable on to stack
call getData

push OFFSET arrayList				;push address of array on to stack
push request						;push value of input variable on to stack
call fillArray

push OFFSET arrayList				;push address of array on to stack
push request						;push value of input variable on to stack
push OFFSET title1					;push address of unsorted list title on to stack
call showArray

push OFFSET arrayList				;push address of array on to stack
push request						;push value of input variable on to stack
call sortList

push OFFSET arrayList
push request						;push value of input variable on to stack
push OFFSET title3					;push address of sorted list title on to stack
call showMedian

push OFFSET arrayList				;push address of array on to stack
push request						;push value of input variable on to stack
push OFFSET title2					;push address of median title on to stack
call showArray

	exit	; exit to operating system
main ENDP

; additional procedures

; ***************************************************************
; Procedure to introduce the program to the user.
; receives: address of four sentences on system stack
; returns: none
; preconditions: none
; registers changed: edx
; ***************************************************************
introduction	PROC
	push	ebp
	mov	ebp,esp
	mov	edx, [ebp + 20]
	call	WriteString		;display program title
	call Crlf
	mov edx, [ebp + 16]
	call WriteString
	call Crlf
	mov edx, [ebp + 12]
	call WriteString
	call Crlf
	mov edx, [ebp + 8]
	call WriteString
	call Crlf
	call Crlf
	pop	ebp
	ret	16
introduction	ENDP

; ***************************************************************
; Procedure to get and validate user input
; receives: address of request and two sentences on system stack
; returns: user input in global request
; preconditions: constant global variables to check range of input
; registers changed: edx, ebx, eax
; ***************************************************************
getData	PROC
	push	ebp
	mov	ebp,esp
Prompt:
	mov	edx, [ebp+16]
	call	WriteString		;prompt user to input a number
	call	ReadInt			;get user's number, stored in eax
	;call Crlf
	cmp eax, MAX			;compare user input to MAX
	jbe checkMin			;if input is less than or equal to MAX, jump to checkMin
	ja Oops				;if input is above MAX, jump to error
checkMin:
	cmp eax, MIN			;compare user input to MIN
	jb Oops				;if input is less than MIN, jump to eror
	jmp Finish
Oops:
	mov edx, [ebp+12]		;if input is out of range, display error message
	call WriteString
	call Crlf
	jmp Prompt			;go to top of loop and ask user for number of terms again
Finish:
	mov	ebx,[ebp+8]		;address of request in ebx
	mov	[ebx],eax			;store user input in global variable
	pop	ebp
	ret	12
getData	ENDP

; ***************************************************************
; Procedure to fill an array with random integers
; receives: value of request and address of array on system stack
; returns: array containing random integers between [100...999], size
; of array is equal to value of request
; preconditions: loop counter is set to request value 10 <= ecx <= 200  
; registers changed: ecx, edi, eax
; cite : Lecture 20 and demo5.asm
; ***************************************************************
fillArray	PROC
	push	ebp
	mov	ebp,esp
	mov	ecx,[ebp+8]		;request in ecx, how many times to loop
	mov	edi,[ebp+12]		;address of array in edi
	
again:
	mov eax, HI			;999	
	sub eax, LO			;999 - 100 = 899
	inc eax				;900
	call RandomRange		;eax in [0..899]
	add eax, LO			;eax in [100...999]
	mov	[edi],eax
	add	edi,4
	loop	again
	
	pop	ebp
	ret	8
fillArray	ENDP

; ***************************************************************
; Procedure to display an array.
; receives: address of array and value of request on system stack
; returns: the sorted array 
; preconditions: count is initialized to value of request, 10 <= ecx <= 200
; registers changed: eax, edx, ecx, edi
; cite : Lecture 20 and demo5.asm
; ***************************************************************
showArray	PROC
	push	ebp
	mov	ebp,esp
	mov edx, [ebp+8]
	call Crlf
	call WriteString
	call Crlf
	mov	ecx,[ebp+12]		;request in ecx for counter
	mov	edi,[ebp+16]		;address of array in edi
	mov	edx, 0			;use this to count for skipping lines

more:
	cmp edx, 11
	jb continueLoop
	mov edx, 1
continueLoop:
	mov eax,[edi]			;start with first element
	inc edx				;add 1 to edx
	cmp edx, 11
	jne andThen			;if not at 10, skip next line
	call Crlf
andThen:
	call	WriteDec
	mov	al,32
	call	WriteChar
	call WriteChar
	add edi, 4			;go to next element in array
	loop more
	
	call Crlf
	call Crlf
	pop	ebp
	ret	12
showArray	ENDP

; ***************************************************************
; Procedure to sort array.
; receives: address of array and value of request on system stack
; returns: the sorted array in descending order at starting address 
; passed in
; preconditions: count is initialized, 10 <= ecx <= 200 
; registers changed: ecx, eax, edi
; cite: p. 375 in textbook (Bubble Sort example)
; ***************************************************************
sortList	PROC
	push	ebp
	mov	ebp,esp
	mov ecx, [ebp+8]	;request in ecx, how many times to loop
	dec ecx			;decrement count by 1

L1:	push ecx			;save outer loop content
	mov edi, [ebp+12]	;move address of first value into edi

L2:	mov eax, [edi]		;get array value
	cmp [edi+4], eax	;compare a pair of values
	jbe L3			;if [EDI] >= [EDI+4], no exchange
	xchg eax, [edi+4]	;exchange the pair
	mov [edi], eax		

L3:	add edi, 4		;move to next element in array
	loop L2			;inner loop

	pop ecx			;retrieve outer loop count
	loop L1

L4:	pop ebp
	ret 8
sortList	ENDP

; ***************************************************************
; Procedure to calculate and display the median.
; receives: address of array and value of request on system stack
; returns: the sorted array at starting address passed in
; preconditions: count is initialized, 10 <= ecx <= 200
; registers changed: ecx, eax, edi
; ***************************************************************
showMedian	PROC
	push ebp
	mov ebp, esp

	mov edx, [ebp+8]
	call WriteString

	cdq					;clear edx 
	mov eax, [ebp+12]		;dividend is request
	mov ebx, 2			;divisor is 2
	div ebx				;divide eax by edx
	mov ebx, eax			;store the quotient in ebx; this is the middle element of array
	mov edi,[ebp+16]		;address of array in edi
	cmp edx, 0			;is there an even number of integers in the list?
	jne moveElement		;if there is an odd number, jump to display them
						;if not, calculate average of two middle numbers
	mov eax, [edi+ebx*4]	;add address of array + 1st middle element location*4 and dereference to get the number
	dec ebx				;move back one element in the array
	add eax, [edi+ebx*4]	;add the previous element in array, 2nd middle number, to eax
	cdq					;clear edx
	mov ebx, 2			;divisor is 2
	div ebx				;divide eax by ebx to get new median
	cmp edx, 0			;compare remainder to 0 (is there a remainder)
	je finish				;display quotient, does not need to be rounded up
	inc eax				;round quotient (median) up if remainder is .5	
	jmp finish	

moveElement:				;display the middle number 
	mov eax, [edi+ebx*4]	;store middle element in eax (median), access with array + (k*size of element)
finish:
	call WriteDec			;display number
	call Crlf
	call Crlf
	pop ebp				
	ret 12
showMedian ENDP

END main
