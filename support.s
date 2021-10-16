
.global expand
.type expand, %function
.global byte_at
.type byte_at, %function

expand:
    @ loop through hexstring and store each char in r2
    @ r3 is going to be our counter
    @ r7 will be used later as our index in our binstring
	push {r4-r6, lr} @pushes registers 4,5,6
    mov r3, #0
    mov r7, #0

expand_loop_hexstring:
	ldrb r2, [r0, r3]  @ load the hexstring byte into r2
	cmp r2, #0  @ a null byte indicates the end of the hexstring
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
                

                expand_loop_hexstring_converted_bitloop_zero:
                    @ 0x30 is hex value for ascii '0'
                    mov r6, #0x30
                    strb r6, [r1, r7]
                    add r7, r7, #1
                    b expand_loop_hexstring_converted_char_added
                    
                expand_loop_hexstring_converted_bitloop_one:
                    @ 0x30 is hex value for ascii '1'
                    mov r6, #0x31
                    strb r6, [r1, r7]
                    add r7, r7, #1
                    b expand_loop_hexstring_converted_char_added
                
                expand_loop_hexstring_converted_char_added:
                lsr r5, r5, #1
                cmp r4, #4
                bge expand_loop_hexstring_converted_end
            
            expand_loop_hexstring_converted_end: @end loop
        
        @ increment r3 (our counter, remember?)
        add r3, #1
        b expand_loop_hexstring
        
    expand_end_hexstring:
        @ other code here
        
    @ basically our `return` statement
    mov pc, lr
	
	pop {r4-r6, pc }
	
byte_at:
	push { r4-r6, lr }
	
	pop { r4-r6, pc}
