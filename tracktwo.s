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
	.file	"tracktwo.c"
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

swi_write:       swi   0x69	@ Write string to file
                 mov   pc, lr

swi_clear:       swi   0x206	@ Clears the LCD
                 mov   pc, lr

swi_lcd_string:  swi   0x204	@ Display at x, y, string
                 mov   pc, lr

swi_lcd_char:    swi   0x207	@ Display at x, y, character
                 mov   pc, lr

swi_button_wait: swi   0x202	@ Check button press
                 ands  r0, r0, r0
                 beq   swi_button_wait	@ Not yet!
_unpress:        swi   0x202	@ Wait for release
                 ands  r0, r0, r0
                 bne   _unpress	@ Wait for the release too                 mov   pc, lr


	.arm
	.syntax unified
	.align	2
	.global	isdigit
	.arch armv4t
	.syntax unified
	.arm
	.fpu softvfp
	.type	isdigit, %function
isdigit:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	str	r0, [fp, #-8]
	ldr	r3, [fp, #-8]
	cmp	r3, #47
	ble	.L2
	ldr	r3, [fp, #-8]
	cmp	r3, #57
	bgt	.L2
	mov	r3, #1
	b	.L4
.L2:
	mov	r3, #0
.L4:
	mov	r0, r3
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	isdigit, .-isdigit
	.comm	data,43,4
	.comm	expanded,161,4
	.global	validNum
	.bss
	.align	2
	.type	validNum, %object
	.size	validNum, 4
validNum:
	.space	4
	.global	startIndex
	.align	2
	.type	startIndex, %object
	.size	startIndex, 4
startIndex:
	.space	4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"\\Users\\Student\\Desktop\\T2DATA.TXT\000"
	.align	2
.LC1:
	.ascii	"For some reason opening the file failed...\012\000"
	.align	2
.LC2:
	.ascii	"\012hey something expanded\012\000"
	.align	2
.LC3:
	.ascii	"\012into the for loop\012\000"
	.align	2
.LC4:
	.ascii	" \012valid Check \012\000"
	.align	2
.LC5:
	.ascii	"\012 Hey it worked \012\000"
	.align	2
.LC6:
	.ascii	"\012 Missing separator \012\000"
	.align	2
.LC7:
	.ascii	"\012Bad account number\012\000"
	.align	2
.LC8:
	.ascii	"\012-end-\012\000"
	.text
	.align	2
	.global	main
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
	ldr	r0, .L17
	bl	swi_open
	str	r0, [fp, #-12]
	ldr	r3, [fp, #-12]
	cmp	r3, #0
	bge	.L8
	ldr	r1, .L17+4
	mov	r0, #2
	bl	swi_write
	mov	r3, #0
	b	.L7
.L16:
	ldr	r1, .L17+8
	ldr	r0, .L17+12
	bl	expand
	ldr	r1, .L17+16
	mov	r0, #1
	bl	swi_write
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L9
.L12:
	ldr	r1, .L17+20
	mov	r0, #1
	bl	swi_write
	ldr	r1, .L17+8
	ldr	r0, [fp, #-8]
	bl	byte_at
	mov	r3, r0
	mov	r1, r3
	mov	r0, #1
	bl	swi_write
	ldr	r1, .L17+8
	ldr	r0, [fp, #-8]
	bl	byte_at
	mov	r3, r0
	cmp	r3, #59
	bne	.L10
	ldr	r1, .L17+24
	mov	r0, #1
	bl	swi_write
	ldr	r3, .L17+28
	mov	r2, #1
	str	r2, [r3]
	ldr	r2, .L17+32
	ldr	r3, [fp, #-8]
	str	r3, [r2]
	b	.L11
.L10:
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L9:
	ldr	r3, [fp, #-8]
	cmp	r3, #160
	bls	.L12
.L11:
	ldr	r3, .L17+28
	ldr	r3, [r3]
	cmp	r3, #1
	bne	.L13
	ldr	r3, .L17+32
	ldr	r3, [r3]
	add	r3, r3, #1
	ldr	r1, .L17+8
	mov	r0, r3
	bl	byte_at
	mov	r3, r0
	cmp	r3, #61
	bne	.L14
	ldr	r1, .L17+36
	mov	r0, #1
	bl	swi_write
	b	.L8
.L14:
	ldr	r1, .L17+40
	mov	r0, #1
	bl	swi_write
	b	.L8
.L13:
	ldr	r1, .L17+44
	mov	r0, #1
	bl	swi_write
.L8:
	mov	r2, #43
	ldr	r1, .L17+12
	ldr	r0, [fp, #-12]
	bl	swi_read
	mov	r3, r0
	cmp	r3, #39
	bgt	.L16
	ldr	r0, [fp, #-12]
	bl	swi_close
	ldr	r1, .L17+48
	mov	r0, #1
	bl	swi_write
	mov	r3, #0
.L7:
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
.L18:
	.align	2
.L17:
	.word	.LC0
	.word	.LC1
	.word	expanded
	.word	data
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	validNum
	.word	startIndex
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.size	main, .-main
	.ident	"GCC: (GNU Tools for Arm Embedded Processors 8-2018-q4-major) 8.2.1 20181213 (release) [gcc-8-branch revision 267074]"
