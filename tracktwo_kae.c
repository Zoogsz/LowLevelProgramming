// ============================================================
//
// tracktwo.c
//
// This is the starter program for the track two C assignment.
//
// This version is specifically for ARMSIM.
// Compile using the Gnu ARM compiler on Windows via arm-none-eabi-gcc
//
// Then run the resulting assembly on ARMSIM.
//
// There's some changes in here, of course. For one thing the arrays
// are declared globally so that it is easier to see them in the
// ARMsim memory dump. All the I/O is for the simulator.
//
// ============================================================

void expand( const char hex[], char binstring[] );
char byte_at( int position, const char binstring[] );
#include <stdio.h>
#define IN_SIZE     40          // 40 characters per data line
#define EXPAND_SIZE (IN_SIZE*4) // Expanded to ASCII string
#define START       ';'
#define SEP         '='
#define END         '?'
#define TRUE        1
#define FALSE       0
#define ACCOUNT_NUM_LEN 16
#define EXP_DATE_LEN 10

// ============================================================
//
// Tie in functions for the simulator.
//
// ============================================================

int  swi_open( char *name, int mode );
int  swi_close( int fd );
int  swi_read( int fd, char *dest, unsigned int n );
int  swi_write( int fd, char *str );
void swi_clear( void );
void swi_lcd_string( int col, int row, char *string );
void swi_lcd_char( int col, int row, char ch );
void swi_button_wait( void );

__asm( "\n\n\n"
     "@ ============================\n"
     "@ Bill's glue logic for ARMsim\n"
     "@ ============================\n"
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
     "                 bne   _unpress\t@ Wait for the release too"
     "                 mov   pc, lr\n\n"
     );

// ============================================================
//
// Other glue logic.
//
// ============================================================

int isdigit( int a ) { return( a >= '0' && a <= '9' ); }

// ============================================================
//
// Start here... Variables are global to make it easier on folks.
//
// ============================================================

char     data[ IN_SIZE + 3 ]; // 1 for '\r', 1 for '\n', 1 for the null
char     expanded[ EXPAND_SIZE + 1 ];
int      validNum = 0; //using essentially as a boolean
int      startIndex = 0;
int      separatorIndex = 0;

int main( int ac, char *av[] )
{
    int fd = swi_open( "\\Users\\Student\\Desktop\\T2DATA.TXT", 0 ); // Read-only

    if ( fd < 0 )
    {
        // Notify them somehow so they're not stuck. fd 2 = stderr
        swi_write( 2, "For some reason opening the file failed...\n" );
        return( 0 ); // Will halt
    }

    // FYI: ARMsim interrupt 0x6a removes the newline.
    while ( swi_read( fd, data, IN_SIZE + 3 ) >= 40 )
    {
        // display needs to be clean for each card that we read
        swi_clear();

        // Here, "data" is a string with 40 hex characters
        //	2. Use the “expand” function to create the string of 160 characters.
        expand( data, expanded );

        //	3. Use a for loop and the “byte_at” function to locate the start sentinel in the data.
	    	for ( int i = 0; i < sizeof(expanded); i++ ) // i -> counter; index*5
		    {
            int index = (i * 5);

            if ( byte_at(index, expanded) == START) //check if start sentinal is valid
            {
                startIndex = i; //save index that start sentinal was found on
                break;
            }
        }

        // 4. Once the start sentinel is located, use the “byte_at” function to examine the account
        // number. This must be digits. If not the output should be “Bad account number”.
        int isAccountNumValid = TRUE;
        for ( int i = (startIndex+1); i < (startIndex+1+ACCOUNT_NUM_LEN); ++i )
        {
            int index = (i * 5);
            isAccountNumValid &= isdigit( byte_at(index, expanded) );
        }

        if ( isAccountNumValid == FALSE )
        {
            swi_lcd_string( 0, 0, "Bad account number\n");

            int colIndex = 0;
            for ( int i = 0; i < sizeof(expanded); ++i )
            {
                int index = (i * 5);
                swi_lcd_char( colIndex, 1, byte_at(index, expanded) );

                ++colIndex;
            }

            swi_button_wait();
            continue;
        }

        // 5. After the account number the next character must be the separator ‘=’, or the output should
        // be “Missing separator”

        int separatorIndex = startIndex + ACCOUNT_NUM_LEN + 1;

        if ( byte_at(separatorIndex * 5, expanded) != SEP )
        {
            swi_lcd_string( 0, 0, "Missing separator!\n");
            swi_button_wait();
            continue;
        }

        //	6. After the separator, the next 10 characters need to all be digits. (These are the expiration date
		//	and the two three-digit fields.) If these are not digits, the output should be “Bad extra data”.
        int isExpDateValid = TRUE;

        for ( int i = (separatorIndex+1); i < (separatorIndex+1+EXP_DATE_LEN); ++i )
        {
            int index = (i * 5);

            isExpDateValid &= isdigit( byte_at(index, expanded) );
        }

        if ( isExpDateValid == FALSE )
        {
            swi_lcd_string( 0, 0, "Bad extra data\n" );
            swi_button_wait();
            continue;
        }

        //	7. Finally, the last character should be the end sentinel, ‘?’. If not the output should be “Missing
		//	end sentinel”.
        if ( byte_at( ((separatorIndex +  EXP_DATE_LEN+1)*5) , expanded) != END )
        {
            swi_lcd_string( 0, 0, "Missing end sentinel\n" );
            swi_button_wait();
            continue;
        }

        //	8. If all of the tests pass, we are displaying, on the LCD screen, something like the following:
		    swi_lcd_string( 0, 0, "This was a good card\n" );
        swi_lcd_string( 0,1, "Account:" );

        int colIndex = 0;
        for ( int i = (startIndex+1); i < (startIndex+1+ACCOUNT_NUM_LEN); ++i )
        {
            int index = (i * 5);
            swi_lcd_char( colIndex+8, 1, byte_at(index, expanded) );

            ++colIndex;
        }

        swi_lcd_string( 0, 2, "YYMMAAABBB:");

        colIndex = 0;
        for ( int i = (separatorIndex+1); i < (separatorIndex+1+EXP_DATE_LEN); ++i )
        {
            int index = (i * 5);
            swi_lcd_char( colIndex+11, 2, byte_at(index, expanded) );

            ++colIndex;
        }

        swi_button_wait();
		//	9. If there was an error, the top line might say “Bad account number” for example.
		//	10. Wait for the user to “press” one of the black buttons on the simulator. At that point go back
		//	to step 1 and read and process the next line.
			//You will be provided with a test file to use. However the file does not have all possible errors

    }
    swi_close( fd );
    swi_write( 1, "\n-end-\n" );
    return( 0 );
}
