// ============================================================
//
// numbers.c
//
// This is the starter program for the number classification problem.
// This version is specifically for ARMSIM. Take this and run with it.
//
//
//
// ============================================================
#include <stdbool.h>
#include <stdio.h>

// ============================================================ Tie in
// functions for the simulator. These will copy through to the output
// from the C compiler and into the assembly file.
// ============================================================

int  swi_open( const char *name, unsigned int mode );
void swi_close( int fd );
int  swi_read( int fd, char *dest, unsigned int n );
int  swi_write( int fd, char *str );
void swi_clear( void );
void swi_lcd_string( int col, int row, char *string );
void swi_lcd_char( int col, int row, char ch );
void swi_button_wait( void );
int  swi_read_int( int fd );
int  swi_lcd_int( int x, int y, int n );

// If using the -std=c1x standard use __asm__ instead.

__asm( "\n\n\n"
       "@ ============================\n"
       "@ Bill's glue logic for ARMsim\n"
       "@ ============================\n"
       "                 .text\n"
       "                 .align 4\n"
       "swi_open:        swi   0x66\n"
       "                 mov   pc, lr\n\n"
       "swi_close:       swi   0x68\n"
       "                 mov   pc, lr\n\n"
       "swi_read:        swi   0x6a\n"
       "                 mov   pc, lr\n\n"
       "swi_write:       swi   0x69\t@ Write string to file\n"
       "                 mov   pc, lr\n\n"
       "swi_clear:       swi   0x206\t@ Clears the LCD\n"
       "                 mov   pc, lr\n\n"
       "swi_lcd_string:  swi   0x204\t@ Display at x, y, string\n"
       "                 mov   pc, lr\n\n"
       "swi_lcd_char:    swi   0x207\t@ Display at x, y, character\n"
       "                 mov   pc, lr\n\n"
       "swi_button_wait: swi   0x202\t@ Check button press\n"
       "                 ands  r0, r0, r0\n"
       "                 beq   swi_button_wait\t@ Not yet!\n"
       "_unpress:        swi   0x202\t@ Wait for release\n"
       "                 ands  r0, r0, r0\n"
       "                 bne   _unpress\t@ Wait for the release too\n"
       "                 mov   pc, lr\n"
       "swi_read_int:    swi   0x6c\t@ Read integer from file\n"
       "                 mov   pc, lr\n"
       "swi_lcd_int:     swi   0x205\t@ Display an int on the LCD at x,y\n"
       "                 mov   pc, lr\n"
     );

// You will, obviously, want to add comments here so you do not lose points.
int isPrime (int num)
{
	for (int i = 2; i < num; ++i )
	{
		if(( num % i ) == 0)
		{ return 0; } 
	}

	return 1;
}
int isTriangular (int num)
{
	for( int i = 0; i < 65000; ++i) //anything over 65k is a larger susm then signed 32bit integers can hold
	{
		sum += i;
		if(sum < num) //if less then add next val
		{ continue; }
	
		if (sum > num) //if over not a triangular num
		{ return 0; }
	return 1; // if match return true
		
int isSquare(int num)
{
	for ( int i = 0; i  <= num; i++ ) // adding <= to solve edge case of 1
	{
		if ( num == i * i )
		{ return 1; }
	}
	return 0;
}

int isHexagonal(int num)
{
	for( int i = 0; i < 65000; ++i) //anything over 65k is a larger susm then signed 32bit integers can hold
	{
		sum += i
		
		if (( i  % 2) == 0) // if an even number is being added to the sum we can disqualify it as a hex 
		{ continue; }
		
		if(sum < num) //if less then add next val
		{ continue; }
		
		if (sum > num) //if over not a triangular num
		{ return 0; }
		
		return 1;
		 // if match return true	
}	

int isPerfect(int num)
{
	int PERFECT[] = { 6 , 28, 496, 8128, 33550336 }
	for( int i = 0; i < (sizeof(PERFECT) / sizeof(int); ++i) //dynamically allocate for loop because clout
	{
		if (num == PERFECT[i])
		{ return 1; }
	}
	return 0;
	
}
int main()
{
    int fd, n;

    fd = swi_open( "c:\\users\\student\\desktop\\numbers.txt", 0 ); // 0 == "read"
    if ( fd < 0 )
    {
        swi_write( 1, "The file could not be opened! Bailing out!\n" );
        return( 1 );
    }

    // For testing we'll just read the next number and put it on the
    // LCD display, then wait for a button to be pressed.
    while ( ( n = swi_read_int( fd ) ) >= 0 )
    {
		swi_write(1, "About the number " + n + "\n"
		if(isPrime(n) == 1)
		{swi_write("That number is prime")}
	
		else
		{ swi_write("That number is not prime")}
	
		if(isTriangular(n) == 1)
		{swi_write("That number is triangular")}
	
		else
		{ swi_write("That number is not triangular")}
	
		if(isSquare(n) == 1)
		{swi_write("That number is a square")}
	
		else
		{ swi_write("That number is not a square")}
	
		if(isHexagonal(n) == 1)
		{swi_write("That number is hexagonal")}
	
		else
		{ swi_write("That number is not hexagonal")}
	
		if(isPerfect(n) == 1)
		{swi_write("That number is perfect")}
	
		else
		{ swi_write("That number is not perfect")}
        swi_lcd_int( 0, 0, n );
        swi_button_wait();
        swi_clear();
    }
    
    swi_close( fd );
    return( 0 );
}
