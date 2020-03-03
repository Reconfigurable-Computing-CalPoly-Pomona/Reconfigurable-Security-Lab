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

int main()
{
	uint32_t baseAddress = 0x44A00000;
//	XStatus status = AXI_ENCRYPT_PERIPHERAL_FINAL_Reg_SelfTest(&baseAddress);
	uint8_t inputTypes[5] = {0, 4, 8, 12, 16};
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


//	while(1)
//	{
//		XGpio_DiscreteWrite(&led,1,data);
//		usleep(500000);
//		if (data == 65535) data = 0;
//		data = data + 1;
//		XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, data);
//	}

	uint8_t receiveBuffer[80] = {0};


	uint32_t currentChunk = 0;
	uint8_t offset = 0;

	//attempt to receive all inputs from uart
//	while (totalReceived != 20)
//	{
//		currentReceived = XUartLite_Recv(&uart, receiveBuffer, 20-totalReceived);
//		totalReceived = totalReceived + currentReceived;
//	}
	for (int j = 0; j < 5; j++)
	{
		for (int i = 0; i < 16; i++)
		{
			receiveBuffer[i+offset] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
		}
		offset = offset + 16;
	}
	XGpio_DiscreteWrite(&led,1,1);

	//send data back to let receiver know.
	XUartLite_Send(&uart, receiveBuffer, 16);
	XGpio_DiscreteWrite(&led,1,2);

	uint32_t writtenChunk = 0;
	//write in inputs to module
	for (int x = 0; x < 5; x++)
	{
		for (int i = 0; i < 4; i++)
		{
			for (int j = 0; j < 4; j++)
			{
				currentChunk = currentChunk | (receiveBuffer[j+(i*4)] << ((3-j)*8));
			}

			AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR, ((inputTypes[x]*16)+(4*i)), currentChunk);
			writtenChunk = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,((inputTypes[x]*16)+(4*i)));
			currentChunk = 0;

		}
	}
//	AXI_ENCRYPT_PERIPHERAL_mWriteReg(BaseAddress, RegOffset, Data)

//	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,0);
	AXI_ENCRYPT_PERIPHERAL_FINAL_mWriteReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET,2);
	uint32_t startAndReset = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG25_OFFSET);
//	uint32_t doneFlag = 0;
//	while (doneFlag != 1)
//	{
//		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
//		doneFlag = doneFlag & 0x00000001;
//		continue;
//	}
//
	sleep(5);
	uint32_t doneFlag = 0;
	for (int i = 0; i < 5; i++)
	{
		doneFlag = AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG24_OFFSET);
		doneFlag = doneFlag & 0x00000001;
	}

	uint32_t cipherFirst =0;

	for (int i = 0; i < 4; i++)
	{
		cipherFirst =
				AXI_ENCRYPT_PERIPHERAL_FINAL_mReadReg(XPAR_AXI_ENCRYPT_PERIPHER_0_BASEADDR,AXI_ENCRYPT_PERIPHERAL_FINAL_DATA_IN_SLV_REG20_OFFSET+(4*i));
		for (int j = 0; j < 4; j++)
		{
			receiveBuffer[j] = cipherFirst >> (3-j)*8;
		}
		XUartLite_Send(&uart, receiveBuffer, 4);

	}//



	while(1);

	return 0;
}
