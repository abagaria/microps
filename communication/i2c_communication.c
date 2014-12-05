#include <plib.h>
#include <P32xxxx.h>
#define GetPeripheralClock() (5000000)
#define IN_CLOCK 5000000
#define I2C_CLOCK 100000
void main(void) {
	//TRISD = 0x0000;
	I2CConfigure(I2C3A, I2C_ENABLE_HIGH_SPEED); 

	UINT32 actualClock = I2CSetFrequency(I2C3A, GetPeripheralClock(), I2C_CLOCK);
	BYTE slaveAddr = 0x21;
	I2CSetSlaveAddress(I2C3A, slaveAddr, 0, I2C_USE_7BIT_ADDRESS);  
	I2CEnable(I2C3A, TRUE);
	BOOL isIdle = I2CBusIsIdle(I2C3A);
	
	I2C_RESULT startResult = FALSE;
	if (isIdle) {
		startResult = I2CStart(I2C3A);
	}
	if (startResult) {
		if (I2CTransmitterIsReady(I2C3A))
	    {
		    I2C_RESULT sendResult = I2CSendByte(I2C3A, (slaveAddr << 1) | I2C_WRITE );
			if (I2CByteWasAcknowledged) {
				I2C_RESULT sendData   = I2CSendByte(I2C3A, 0x00);
				I2CStop(I2C3A);
				//PORTD = 0x0000;
			}
	    }
	}
	
}