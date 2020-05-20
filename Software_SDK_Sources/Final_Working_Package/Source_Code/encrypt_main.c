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
#define ENCRYPT_BASEADDR XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR
#define Axi_WriteReg(offset,data) AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR,offset,data);

int main()
{
//	uint32_t baseAddress = 0x44A00000;
//	XStatus status = AXI_ENCRYPT_PERIPHERAL_FINAL_Reg_SelfTest(&baseAddress);
//	uint8_t inputTypes[5] = {0, 4, 8, 12, 16};
	//set up LED gpio
	XGpio led;
	int success = XGpio_Initialize(&led,XPAR_AXI_GPIO_0_DEVICE_ID);
	const uint32_t ZERO_32 = 0;
	uint16_t data = 0;
	XGpio_SetDataDirection(&led,1,ZERO_32);
	XGpio_DiscreteWrite(&led,1,0xFF00);


	//setup Uart
	XUartLite uart;
	success = XUartLite_Initialize(&uart, XPAR_AXI_UARTLITE_0_DEVICE_ID);
	XUartLite_ResetFifos(&uart);
	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(ENCRYPT_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,0);
//	while(1)
//	{
//		XGpio_DiscreteWrite(&led,1,data);
//		usleep(500000);
//		if (data == 65535) data = 0;
//		data = data + 1;
//		XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, data);
//	}

	uint8_t receiveBuffer[80] = {0};

	const char cipherLabel[] = "Cipher: ";
	const char plainLabel[] = "Plaintext: ";

	uint32_t currentChunk = 0;
	uint8_t offset = 0;

	//attempt to receive all inputs from uart
//	while (totalReceived != 20)
//	{
//		currentReceived = XUartLite_Recv(&uart, receiveBuffer, 20-totalReceived);
//		totalReceived = totalReceived + currentReceived;
//	}

	//write out Cipher label

	for (int j = 0; j < 5; j++)
	{
		for (int i = 0; i < 16; i++)
		{
			XGpio_DiscreteWrite(&led,1,0xFF00);
			receiveBuffer[i+offset] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
//			receiveBuffer[(15-i)+offset] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
//			XGpio_DiscreteWrite(&led,1,0x00FF);
//			sleep(1);
		}
		offset = offset + 16;
	}
	XGpio_DiscreteWrite(&led,1,1);

	//send data back to let receiver know.
	//	XUartLite_Send(&uart, receiveBuffer, 16);
	XGpio_DiscreteWrite(&led,1,2);

	uint32_t writtenChunk = 0;
	uint8_t offsetValue = 0;


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
			AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR, offsetValue, currentChunk);
//			AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR, ((inputTypes[x]*16)+(4*i)), currentChunk);
			writtenChunk = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR, offsetValue);
			currentChunk = 0;

		}
	}
	uint32_t writtenVals[20] = {0};

	for (int i = 0; i < 5; i++) //read all registers we just wrote to
	{
		for (int j = 0; j < 4; j++)
		{
			writtenVals[j+(i*4)] = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,(i*16+12)-(4*j));
		}

	}
//	AXI_ENCRYPT_PERIPHERAL_mWriteReg(BaseAddress, RegOffset, Data)

//	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,0);
	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,2);
	uint32_t startAndReset = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET);
	uint32_t doneFlag = 0;
	uint8_t tagOut = 0;
	while (doneFlag != 1)
	{
		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
		tagOut = doneFlag & 0x00000002;
		tagOut = tagOut << 1; //puts the tagout from encrypt in 3rd bit to write to TAGIN
		doneFlag = doneFlag & 0x00000001;
		continue;
	}
//
//	sleep(5);
//	uint32_t doneFlag = 0;
//	for (int i = 0; i < 5; i++)
//	{
//		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
//		doneFlag = doneFlag & 0x00000001;
//	}

	uint32_t cipherChunk =0;
//	uint8_t byteToSend = 0;

	XUartLite_ResetFifos(&uart);
//	XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, 5);

	XUartLite_Send(&uart, cipherLabel, strlen(cipherLabel));
	for (int i = 0; i < 4; i++)
	{
		cipherChunk =
		AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG23_OFFSET-(4*i));
//		Axi_WriteReg(AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG19_OFFSET - (4*i),cipherChunk); //writing cipher back into plaintext
		AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG19_OFFSET-(4*i),cipherChunk);
		AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG19_OFFSET-(4*i));

		for (int j = 0; j < 4; j++)
		{
			receiveBuffer[j] = cipherChunk >> (3-j)*8;
//			byteToSend = cipherFirst >> (3-j)*8;
//			XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, byteToSend);

		}
		XUartLite_Send(&uart, receiveBuffer, 4); //send cipher thru uart

	}

	XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, '\n');

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
		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
		doneFlag = doneFlag & 0x00000001;
		continue;
	}

	XUartLite_Send(&uart, plainLabel, strlen(plainLabel));
	//read decrypted plaintext and then send
	for (int i = 0; i < 4; i++)
	{
		cipherChunk =
		AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG23_OFFSET-(4*i));

		for (int j = 0; j < 4; j++)
		{
			receiveBuffer[j] = cipherChunk >> (3-j)*8;
		}
		XUartLite_Send(&uart, receiveBuffer, 4); //send cipher thru uart

	}



	while(1);

	return 0;
}
