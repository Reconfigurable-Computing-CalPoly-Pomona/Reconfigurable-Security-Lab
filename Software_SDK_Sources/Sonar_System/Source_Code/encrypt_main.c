#include "xgpio.h"
#include "sleep.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xgpio_l.h"
#include "xuartlite.h"
#include "xuartlite_l.h"
#include "axi_encrypt_peripheral_final.h"
#include "stdio.h"
#include <string.h>
#include <math.h>

//enum {
//		K = 0,
//		P = 4,
//		S = 8,
//		A = 12,
//		NONCE = 16,
//		START = 20,
//		RESET = 21,
//		DONE_FLAG = 22,
//		CIPHER = 23
//	};
enum {S = 0, A = 4, NONCE = 8, K = 12, P = 16, TRIGGERS = 25};
enum {LED_CHANNEL = 1, SW_CHANNEL = 2};
enum {SONAR_IN = 1, SONAR_OUT = 2};

#define ENCRYPT_BASEADDR XPAR_AXI_ENCRYPT_DECRYPT_0_BASEADDR
#define PLAINTEXT_BASE AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG16_OFFSET
#define Axi_WriteReg(offset,data) AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR,offset,data);

int main()
{

	XGpio led_sw, sonar;
	int success = XGpio_Initialize(&led_sw,XPAR_AXI_GPIO_0_DEVICE_ID);
	success = XGpio_Initialize(&sonar, XPAR_AXI_GPIO_1_DEVICE_ID);

	const uint32_t ZERO_32 = 0;
	uint16_t data = 0;
	uint16_t intervals = 0; //100 microsecond intervals

	XGpio_SetDataDirection(&led_sw,LED_CHANNEL,ZERO_32);
	XGpio_SetDataDirection(&led_sw,SW_CHANNEL,~ZERO_32);
	XGpio_SetDataDirection(&sonar,SONAR_IN,~ZERO_32);
	XGpio_SetDataDirection(&sonar,SONAR_OUT,ZERO_32);
	XGpio_DiscreteWrite(&led_sw,1,0xFF00);


	//setup Uart
	XUartLite uart;
	success = XUartLite_Initialize(&uart, XPAR_UARTLITE_0_DEVICE_ID);
	XUartLite_ResetFifos(&uart);
	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,0);


	uint8_t receiveBuffer[80] = {0};

	uint32_t currentChunk = 0;
	uint8_t offset = 0;

	//read in all inputs except plaintext
	for (int j = 0; j < 4; j++)
	{
		for (int i = 0; i < 16; i++)
		{
			receiveBuffer[i+offset] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
//			receiveBuffer[(15-i)+offset] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
//			XGpio_DiscreteWrite(&led,1,0x00FF);
//			sleep(1);
		}
		offset = offset + 16;
	}

	//write upper 4 registers of plaintext in receiveBuffer to zero
	for (int i = 1; i < 16; i++)
	{
		receiveBuffer[i+offset] = 0x00;
	}

	XGpio_DiscreteWrite(&led_sw,1,1);

	uint32_t writtenChunk = 0;
	uint8_t offsetValue = 0;

	//Get distance data from sonar and trigger

	float centimeters = 0;
	//triggering:
	XGpio_DiscreteWrite(&sonar,SONAR_OUT,0x0001);
	usleep(10);
	XGpio_DiscreteWrite(&sonar,SONAR_OUT,0x0000);

//	intervals = 1;
	while (XGpio_DiscreteRead(&sonar,SONAR_IN) == 0) continue;

	while (XGpio_DiscreteRead(&sonar,SONAR_IN) == 1)
	{
		intervals++;
		usleep(100);
	}

	//calculate distance
	centimeters = ((intervals*100)/58.0);
	uint8_t hunnits =  (uint8_t) ((uint32_t) (centimeters * 100) % (100));
	receiveBuffer[PLAINTEXT_BASE] = (uint8_t) (centimeters);
	receiveBuffer[PLAINTEXT_BASE+1] = hunnits;


	//write in inputs to module
	for (int x = 0; x < 5; x++)
	{
		for (int i = 0; i < 4; i++)
		{
			for (int j = 0; j < 4; j++)
			{
				currentChunk = currentChunk | (receiveBuffer[j+(i*4)+(x*16)] << ((3-j)*8)); //sends the MS first
//				currentChunk = currentChunk | (receiveBuffer[])
			}
			offsetValue = ((x*16)+(12-(4*i)));
			AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR, offsetValue, currentChunk);
//			AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR, ((inputTypes[x]*16)+(4*i)), currentChunk);
			writtenChunk = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR, offsetValue);
			currentChunk = 0;

		}
	}


//	for (int i = 0; i < 5; i++) //read all registers we just wrote to
//	{
//		for (int j = 0; j < 4; j++)
//		{
//			writtenVals[j+(i*4)] = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,(i*16+12)-(4*j));
//		}
//
//	}
//	AXI_ENCRYPT_PERIPHERAL_mWriteReg(BaseAddress, RegOffset, Data)

//	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,0);
	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,2);
	uint32_t startAndReset = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET);
	uint32_t doneFlag = 0;
	uint8_t tagOut = 0;
	while (doneFlag != 1)
	{
		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
		tagOut = doneFlag & 0x00000002;
		tagOut = tagOut << 1; //puts the tagout from encrypt in 3rd bit to write to TAGIN
		doneFlag = doneFlag & 0x00000001;
		continue;
	}


	uint32_t cipherChunk =0;

	XUartLite_ResetFifos(&uart);

	for (int i = 0; i < 4; i++)
	{
		cipherChunk =
		AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG23_OFFSET-(4*i));
//		Axi_WriteReg(AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG19_OFFSET - (4*i),cipherChunk); //writing cipher back into plaintext
//		AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG19_OFFSET-(4*i),cipherChunk);
//		AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG19_OFFSET-(4*i));

		for (int j = 0; j < 4; j++)
		{
			receiveBuffer[j] = cipherChunk >> (3-j)*8;
//			byteToSend = cipherFirst >> (3-j)*8;
//			XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, byteToSend);

		}
		XUartLite_Send(&uart, receiveBuffer, 4); //send cipher thru uart

	}

	//---------RECEIVE READING FROM OTHER SONAR/BOARD------------------//
	//read in the ciphertext from other module

	//receive all 16 bytes of the ciphertext
	for (int i = 0; i < 16; i++)
	{
		receiveBuffer[i] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
	}

	//break into 32 bit chunks and write to plaintext register for decryption
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			currentChunk = currentChunk | (receiveBuffer[j+(i*4)] << ((3-j)*8)); //sends the MS first
		}
		offsetValue = ((4*16)+(12-(4*i)));
		AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR, offsetValue, currentChunk);
//		writtenChunk = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR, offsetValue);
		currentChunk = 0;

	}

	//reset module, assert EOC high for decryption
	uint32_t reset_decrypt = 0x00000009;
	reset_decrypt = reset_decrypt | tagOut;
	Axi_WriteReg(AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,reset_decrypt);
	//now enable the module
	sleep(1);
	reset_decrypt = reset_decrypt ^ 0x00000003; //deasserts LSB and asserts enable
	Axi_WriteReg(AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,reset_decrypt);

	doneFlag = 0;
	while (doneFlag != 1)
	{
		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
		doneFlag = doneFlag & 0x00000001;
		continue;
	}

//	XUartLite_Send(&uart, plainLabel, strlen(plainLabel));
	//read decrypted plaintext and then send
	for (int i = 0; i < 4; i++)
	{
		cipherChunk =
		AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG23_OFFSET-(4*i));

		for (int j = 0; j < 4; j++)
		{
			receiveBuffer[j] = cipherChunk >> (3-j)*8;
		}
		XUartLite_Send(&uart, receiveBuffer, 4); //send cipher thru uart

	}



	while(1);

	return 0;
}
