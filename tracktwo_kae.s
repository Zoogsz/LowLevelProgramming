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
	.file	"tracktwo_kae.c"
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
	.global	separatorIndex
	.align	2
	.type	separatorIndex, %object
	.size	separatorIndex, 4
separatorIndex:
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
	.ascii	"Bad account number\012\000"
	.align	2
.LC3:
	.ascii	"Missing separator!\012\000"
	.align	2
.LC4:
	.ascii	"Bad extra data\012\000"
	.align	2
.LC5:
	.ascii	"Missing end sentinel\012\000"
	.align	2
.LC6:
	.ascii	"This was a good card\012\000"
	.align	2
.LC7:
	.ascii	"Account:\000"
	.align	2
.LC8:
	.ascii	"YYMMAAABBB:\000"
	.align	2
.LC9:
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
	@ args = 0, pretend = 0, frame = 80
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, fp, lr}
	add	fp, sp, #8
	sub	sp, sp, #84
	str	r0, [fp, #-88]
	str	r1, [fp, #-92]
	mov	r1, #0
	ldr	r0, .L28
	bl	swi_open
	str	r0, [fp, #-56]
	ldr	r3, [fp, #-56]
	cmp	r3, #0
	bge	.L8
	ldr	r1, .L28+4
	mov	r0, #2
	bl	swi_write
	mov	r3, #0
	b	.L7
.L27:
	bl	swi_clear
	ldr	r1, .L28+8
	ldr	r0, .L28+12
	bl	expand
	mov	r3, #0
	str	r3, [fp, #-16]
	b	.L9
.L12:
	ldr	r2, [fp, #-16]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	str	r3, [fp, #-60]
	ldr	r1, .L28+8
	ldr	r0, [fp, #-60]
	bl	byte_at
	mov	r3, r0
	cmp	r3, #59
	bne	.L10
	ldr	r2, .L28+16
	ldr	r3, [fp, #-16]
	str	r3, [r2]
	b	.L11
.L10:
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L9:
	ldr	r3, [fp, #-16]
	cmp	r3, #160
	bls	.L12
.L11:
	mov	r3, #1
	str	r3, [fp, #-20]
	ldr	r3, .L28+16
	ldr	r3, [r3]
	add	r3, r3, #1
	str	r3, [fp, #-24]
	b	.L13
.L14:
	ldr	r2, [fp, #-24]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	str	r3, [fp, #-64]
	ldr	r1, .L28+8
	ldr	r0, [fp, #-64]
	bl	byte_at
	mov	r3, r0
	sub	r3, r3, #48
	cmp	r3, #9
	movls	r3, #1
	movhi	r3, #0
	and	r3, r3, #255
	mov	r2, r3
	ldr	r3, [fp, #-20]
	and	r3, r3, r2
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-24]
	add	r3, r3, #1
	str	r3, [fp, #-24]
.L13:
	ldr	r3, .L28+16
	ldr	r3, [r3]
	add	r3, r3, #16
	ldr	r2, [fp, #-24]
	cmp	r2, r3
	ble	.L14
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bne	.L15
	ldr	r2, .L28+20
	mov	r1, #0
	mov	r0, #0
	bl	swi_lcd_string
	mov	r3, #0
	str	r3, [fp, #-28]
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L16
.L17:
	ldr	r2, [fp, #-32]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	str	r3, [fp, #-68]
	ldr	r1, .L28+8
	ldr	r0, [fp, #-68]
	bl	byte_at
	mov	r3, r0
	mov	r2, r3
	mov	r1, #1
	ldr	r0, [fp, #-28]
	bl	swi_lcd_char
	ldr	r3, [fp, #-28]
	add	r3, r3, #1
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L16:
	ldr	r3, [fp, #-32]
	cmp	r3, #160
	bls	.L17
	bl	swi_button_wait
	b	.L8
.L15:
	ldr	r3, .L28+16
	ldr	r3, [r3]
	add	r3, r3, #17
	str	r3, [fp, #-72]
	ldr	r2, [fp, #-72]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	ldr	r1, .L28+8
	mov	r0, r3
	bl	byte_at
	mov	r3, r0
	cmp	r3, #61
	beq	.L18
	ldr	r2, .L28+24
	mov	r1, #0
	mov	r0, #0
	bl	swi_lcd_string
	bl	swi_button_wait
	b	.L8
.L18:
	mov	r3, #1
	str	r3, [fp, #-36]
	ldr	r3, [fp, #-72]
	add	r3, r3, #1
	str	r3, [fp, #-40]
	b	.L19
.L20:
	ldr	r2, [fp, #-40]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	str	r3, [fp, #-76]
	ldr	r1, .L28+8
	ldr	r0, [fp, #-76]
	bl	byte_at
	mov	r3, r0
	sub	r3, r3, #48
	cmp	r3, #9
	movls	r3, #1
	movhi	r3, #0
	and	r3, r3, #255
	mov	r2, r3
	ldr	r3, [fp, #-36]
	and	r3, r3, r2
	str	r3, [fp, #-36]
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L19:
	ldr	r3, [fp, #-72]
	add	r3, r3, #10
	ldr	r2, [fp, #-40]
	cmp	r2, r3
	ble	.L20
	ldr	r3, [fp, #-36]
	cmp	r3, #0
	bne	.L21
	ldr	r2, .L28+28
	mov	r1, #0
	mov	r0, #0
	bl	swi_lcd_string
	bl	swi_button_wait
	b	.L8
.L21:
	ldr	r3, [fp, #-72]
	add	r2, r3, #11
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	ldr	r1, .L28+8
	mov	r0, r3
	bl	byte_at
	mov	r3, r0
	cmp	r3, #63
	beq	.L22
	ldr	r2, .L28+32
	mov	r1, #0
	mov	r0, #0
	bl	swi_lcd_string
	bl	swi_button_wait
	b	.L8
.L22:
	ldr	r2, .L28+36
	mov	r1, #0
	mov	r0, #0
	bl	swi_lcd_string
	ldr	r2, .L28+40
	mov	r1, #1
	mov	r0, #0
	bl	swi_lcd_string
	mov	r3, #0
	str	r3, [fp, #-44]
	ldr	r3, .L28+16
	ldr	r3, [r3]
	add	r3, r3, #1
	str	r3, [fp, #-48]
	b	.L23
.L24:
	ldr	r2, [fp, #-48]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	str	r3, [fp, #-80]
	ldr	r3, [fp, #-44]
	add	r4, r3, #8
	ldr	r1, .L28+8
	ldr	r0, [fp, #-80]
	bl	byte_at
	mov	r3, r0
	mov	r2, r3
	mov	r1, #1
	mov	r0, r4
	bl	swi_lcd_char
	ldr	r3, [fp, #-44]
	add	r3, r3, #1
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-48]
	add	r3, r3, #1
	str	r3, [fp, #-48]
.L23:
	ldr	r3, .L28+16
	ldr	r3, [r3]
	add	r3, r3, #16
	ldr	r2, [fp, #-48]
	cmp	r2, r3
	ble	.L24
	ldr	r2, .L28+44
	mov	r1, #2
	mov	r0, #0
	bl	swi_lcd_string
	mov	r3, #0
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-72]
	add	r3, r3, #1
	str	r3, [fp, #-52]
	b	.L25
.L26:
	ldr	r2, [fp, #-52]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	str	r3, [fp, #-84]
	ldr	r3, [fp, #-44]
	add	r4, r3, #11
	ldr	r1, .L28+8
	ldr	r0, [fp, #-84]
	bl	byte_at
	mov	r3, r0
	mov	r2, r3
	mov	r1, #2
	mov	r0, r4
	bl	swi_lcd_char
	ldr	r3, [fp, #-44]
	add	r3, r3, #1
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-52]
	add	r3, r3, #1
	str	r3, [fp, #-52]
.L25:
	ldr	r3, [fp, #-72]
	add	r3, r3, #10
	ldr	r2, [fp, #-52]
	cmp	r2, r3
	ble	.L26
	bl	swi_button_wait
.L8:
	mov	r2, #43
	ldr	r1, .L28+12
	ldr	r0, [fp, #-56]
	bl	swi_read
	mov	r3, r0
	cmp	r3, #39
	bgt	.L27
	ldr	r0, [fp, #-56]
	bl	swi_close
	ldr	r1, .L28+48
	mov	r0, #1
	bl	swi_write
	mov	r3, #0
.L7:
	mov	r0, r3
	sub	sp, fp, #8
	@ sp needed
	pop	{r4, fp, lr}
	bx	lr
.L29:
	.align	2
.L28:
	.word	.LC0
	.word	.LC1
	.word	expanded
	.word	data
	.word	startIndex
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.size	main, .-main
	.ident	"GCC: (GNU Tools for Arm Embedded Processors 8-2018-q4-major) 8.2.1 20181213 (release) [gcc-8-branch revision 267074]"
