	.cpu arm7tdmi
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"calling.c"
	.text
	.syntax divided
	


@ ============================
@ Bill's glue logic for ARMsim
@ ============================
swi_open:        swi   0x66
                 mov   pc, lr

swi_close:       swi   0x68
                 mov   pc, lr

swi_read:        swi   0x6a
                 mov   pc, lr

swi_write:       swi   0x69	@ Write string to stdout
                 mov   pc, lr

@ converts an ascii hexstring into its ascii binstring equivalent.
@ parameters:
@   r0 = hexstring (input)
@   r1 = binstring (output)
@
@ overwritten registers:
@   r2, r3, r4, r5, r6, r7
expand:
    @ loop through hexstring and store each char in r2
    @ r3 is going to be our counter
    @ r7 will be used later as our index in our binstring
    mov r3, #0
    mov r7, #0
    
    expand_loop_hexstring:
        @ load the hexstring byte into r2
        ldrb r2, [r0, r3]
        
        @ a null byte indicates the end of the hexstring
        cmp r2, #0
        beq expand_end_hexstring
        
        @ so, when it comes to decoding hex strings into its numerical equivalent,
        @ we consider the following:
        @   - for any digit, ascii value minus 0x30 gives numerical value
        @   - for CAPS, ascii value minus 0x37 gives us numerical
        @ so let's start by seeing if we have a digit or a capital ASCII letter by seeing
        @ if we're in digit range (0x30-0x39) or alpha range (0x41-0x46) by comparing
        @ against 0x3a. is this a lazy check? yes. is this defensive programming? no.
        @ in fact, you could argue its offensive programming, because it hurts me
        @ to write. unfortunately, school assignments assume constriants are followed
        @ a lot of the time, and the logic to make this defensive would complicate
        @ things, so let's get the assignment done FIRST, and then talk about all that
        cmp r2, #0x3a
        blt expand_loop_hexstring_digit
        b expand_loop_hexstring_letter
        
        expand_loop_hexstring_digit:
            sub r2, #0x30
            b expand_loop_hexstring_converted
        
        expand_loop_hexstring_letter:
            sub r2, #0x37
            b expand_loop_hexstring_converted
        
        @ sooo now r2 contains the numerical value of our ascii hex char. 
        expand_loop_hexstring_converted:
            @ so here's how we're gonna do this. bitmasks. 
            @ each hex char is four bin digits. so we loop through each relevant bit
            @ (so 4 times) and apply a bitmask/shift each time, from msb to lsb, and
            @ then conditionally add to the bitstring based on what we find
            @
            @ r4 will be our counter
            @ r5 will be our mask (starting at 0x8 because itll be shifted 3 times)
            @   ^ yes i know this could be more efficient but i dont care
            @ r6 is for intermediary/temp value
            mov r4, #0
            mov r5, #0x8
            mov r6, #0
            
            expand_loop_hexstring_converted_bitloop:
                and r6, r2, r5
                
                cmp r6, #0
                beq expand_loop_hexstring_converted_bitloop_zero
                b expand_loop_hexstring_converted_bitloop_one
                
                @ yes, there's a better way to do this than two separate
                @ branches with one tiny difference that are otherwise identical,
                @ but i feel this is cleaner for you to read and understand
                expand_loop_hexstring_converted_bitloop_zero:
                    @ 0x30 is hex value for ascii '0'
                    mov r6, #0x30
                    strb r6, [r1, r7]
                    add r7, r7, #1
                    b expand_loop_converted_char_added
                    
                expand_loop_hexstring_converted_bitloop_one:
                    @ 0x30 is hex value for ascii '1'
                    mov r6, #0x31
                    strb r6, [r1, r7]
                    add r7, r7, #1
                    b expand_loop_converted_char_added
                
                expand_loop_hexstring_converted_char_added:
                lsr r5, r5, #1
                cmp r4, #4
                bge expand_loop_hexstring_converted_end
            
            expand_loop_hexstring_converted_end:
            @ aand we're done!
        
        @ increment r3 (our counter, remember?)
        add r3, #1
        b expand_loop_hexstring
        
    expand_end_hexstring:
        @ other code here
        
    @ basically our `return` statement
    mov pc, lr

	.arm
	.syntax unified
	.comm	data,43,4
	.comm	expanded,161,4
	.comm	outstring,42,4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"\\Users\\Student\\Desktop\\T2DATA.TXT\000"
	.text
	.align	2
	.global	main
	.arch armv4t
	.syntax unified
	.arm
	.fpu softvfp
	.type	main, %function
main:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r1, #0
	ldr	r0, .L7
	bl	swi_open
	str	r0, [fp, #-12]
	b	.L2
.L5:
	ldr	r1, .L7+4
	ldr	r0, .L7+8
	bl	expand
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L3
.L4:
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #2
	ldr	r1, .L7+4
	mov	r0, r3
	bl	byte_at
	mov	r3, r0
	mov	r1, r3
	ldr	r2, .L7+12
	ldr	r3, [fp, #-8]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L3:
	ldr	r3, [fp, #-8]
	cmp	r3, #38
	ble	.L4
	ldr	r3, [fp, #-8]
	add	r2, r3, #1
	str	r2, [fp, #-8]
	ldr	r2, .L7+12
	mov	r1, #10
	strb	r1, [r2, r3]
	ldr	r3, [fp, #-8]
	add	r2, r3, #1
	str	r2, [fp, #-8]
	ldr	r2, .L7+12
	mov	r1, #0
	strb	r1, [r2, r3]
	ldr	r1, .L7+12
	mov	r0, #1
	bl	swi_write
.L2:
	mov	r2, #43
	ldr	r1, .L7+8
	ldr	r0, [fp, #-12]
	bl	swi_read
	mov	r3, r0
	cmp	r3, #39
	bgt	.L5
	ldr	r0, [fp, #-12]
	bl	swi_close
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
.L8:
	.align	2
.L7:
	.word	.LC0
	.word	expanded
	.word	data
	.word	outstring
	.size	main, .-main
	.ident	"GCC: (GNU Tools for Arm Embedded Processors 8-2018-q4-major) 8.2.1 20181213 (release) [gcc-8-branch revision 267074]"
