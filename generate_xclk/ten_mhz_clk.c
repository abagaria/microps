// Include
#include <P32xxxx.h>
#include <plib.h>
// Prototypes
void main(void);
void initTimers(void);

void main(void) {
	unsigned short duration;
	duration = 1;
	TRISF = 0; // Use PORTF for output
	initTimers(); // Set up Timer1
	TMR1 = 0;
	PORTFbits.RF0 = 0;
	PORTD = 0;
	while (1) {
		if (TMR1 >= duration) {
			PORTFbits.RF0 = !PORTFbits.RF0;
			TMR1 = 0;
		}
	}
}
 
void initTimers(void) {
// Assumes peripheral clock at 20MHz
// Use Timer1 for note duration
// T1CON
// bit 15: ON=1: enable timer
// bit 14: FRZ=0: keep running in exception mode
// bit 13: SIDL = 0: keep running in idle mode
// bit 12: TWDIS=1: ignore writes until current write completes
// bit 11: TWIP=0: don't care in synchronous mode
// bit 10-8: unused
// bit 7: TGATE=0: disable gated accumulation
// bit 6: unused
// bit 5-4: TCKPS=00: 1:1 prescaler, 0.1us*1=0.1us
// bit 3: unused
// bit 2: don't care in internal clock mode
// bit 1: TCS=0: use internal peripheral clock
// bit 0: unused
T1CON = 0b1001000000000000;
}