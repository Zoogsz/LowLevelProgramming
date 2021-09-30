@ ============================================================
@
@ Palindrome problem for ARM - starter code.
@
@ Author: Bill Mahoney
@ For:    CYBR 2250
@
@ ============================================================

        @ These are the SWI instructions for the "Embest" plugin.
	
        .equ SWI_WriteC,        0x00    @ Write to stdout
        .equ SWI_Exit,          0x11    @ Exit gracefully
        .equ SWI_Open,          0x66    @ Open file
        .equ SWI_Close,         0x68    @ Close file
        .equ SWI_ReadS,         0x6a    @ Read string from file
        .equ SWI_WriteS,        0x69    @ Write string to stdout
        .equ SWI_RdInt,         0x6c    @ Read an integer from a file
        .equ SWI_PrInt,         0x6b    @ Write an integer to a file
        .equ SWI_Disp,          0x204   @ Display a string on the LCD screen
        .equ SWI_Check_button,  0x202   @ Check if button is pressed

        .equ LINE_SIZE,         100     @ Each line of input < 100 bytes
        
        .text                       
        .global _start             
_start:                           
        ldr     r0, =in_file_name       @ Open up the file
        mov     r1, #0                  @ Read only
        swi     SWI_Open		@ Open the file
        bcs     file_not_found		@ Branch on carry set (it didn't work)
        ldr     r1, =file_handle        @ Save the file handle for later
        str     r0, [r1]

get:	ldr     r0, =file_handle        @ Read the next line of input
        ldr     r0, [r0]
        ldr     r1, =line
        mov     r2, #LINE_SIZE
        swi     SWI_ReadS               @ I SWI_ReadS gives the number of
        bcs     end_of_file             @ bytes read, it is in R0.
        subs    r0, r0, #1              @ A word like "radar" will have R0=6
        beq     end_of_file             @ because of the null character.
        
        @ ========================================
        @ Here is where you put YOUR part of the assignment.
        @
        @ If the string passes the test, branch to "good", and if it
        @ does not, branch to "bad".
        @
        @ ========================================
	
	ldr r1, =line
	ldr r4, =charArray
	mov r2, #0
	mov r5, #0


update_char_array:
	ldrb r3, [r1, r2]		@ read the char at line [r2] into r3
	
	cmp r3 , #0x20			@ check if loaded char is space
	beq loop_continue 		@ if its a space continue

	cmp r3, #0x61 			@ compare case
	blt convert_case
	b case_converted

convert_case:
	add r3, r3, #0x20

case_converted:
	strb r3, [r4 , r5]
	add  r5, r5, #1 		@ loop body end


loop_continue:				@ increment counter and continue
	add r2, r2, #1  		@ essentially i++
	cmp r2, r0			@ compare r2 to r0 for length
	blt update_char_array		@ continue loop if comparison is false
	
	cmp r5,  #1			@ one char string passes by default	
	beq good

					@cleaning up registers
	ldr r0, = charArray		@ reference to base address of CHAR_ARRAY
	mov r1, r5, lsr #1		@ mid index for CHAR_ARRAY
	mov r2, #0			@ index
	mov r3, #0			@ char val
	sub r4, r5, #1			@ reverse index
	mov r5, #0			@ reverse char val

check_palindrome:
	ldrb r3, [r0, r2]		@ load char from either side of arr
	ldrb r5, [r0, r4]

	cmp r3, r5 			@ if no match return false
	bne bad

	add r2, r2, #1			@ i++
	sub r4, r4, #1
	cmp r4, r1
	ble good
	b check_palindrome
good:   mov     r0, #1                  @ Print that it is
        ldr     r1, =it_is
        swi     SWI_WriteS
        b       get




bad:    mov     r0, #1                  @ Print that it is
        ldr     r1, =it_is_not
        swi     SWI_WriteS
        b       get

end_of_file:
        ldr     r0, =file_handle
        ldr     r0, [r0]
        swi     SWI_Close
        swi     SWI_Exit

file_not_found:                     
        mov     r0, #1                  @ Stdout
        ldr     r1, =in_file_error                                  
        swi     SWI_WriteS
        swi     SWI_Exit

@ ============================================================
@ 
@ Data
@ 
@ ============================================================

                .data
file_handle:    .word   0x00
in_file_name:   .asciz  "pal.txt"
in_file_error:  .asciz  "Can't open the file. Shoot...\n"
it_is_not:      .asciz  "This was not a palindrome.\n"
it_is:          .asciz  "YES! This one IS a palindrome!\n"
newline:        .asciz  "\n"

line:           .skip   100     @ The line will be read into here
charArray:	.skip	100 	@ The array we will store char's in
