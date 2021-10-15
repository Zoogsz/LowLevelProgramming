.global expand
.type expand, %function

expand:
    @ loop through hexstring and store each char in r2
    @ r3 is going to be our counter
    mov r3, #0
    
expand_loop_hexstring:
    @ load the hexstring byte into r2
	ldrb r2, [r0, r3]
	@ a null byte indicates the end of the hexstring
    cmp r2, #0
	beq expand_end_hexstring
        
        
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
		@ this is where the fun part begins
            
        
        @ increment r3 (our counter, remember?)
        add r3, #1
        b expand_loop_hexstring
        
    expand_end_hexstring:
        @ other code here
        
    @ basically our `return` statement
    mov pc, lr