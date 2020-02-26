#include "xgpio.h"
#include "sleep.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xgpio_l.h"
#include "xuartlite.h"
#include "xuartlite_l.h"


int main()
{
	//set up LED gpio
	XGpio led;
	int success = XGpio_Initialize(&led,XPAR_AXI_GPIO_0_DEVICE_ID);
	const uint32_t ZERO_32 = 0;
	uint16_t data = 0;
	XGpio_SetDataDirection(&led,1,ZERO_32);


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
	uint8_t K[16] = {0};
	uint8_t S[16] = {0};
	uint8_t A[16] = {0};
	uint8_t NONCE[16] = {0};
	uint8_t P[16] = {0};


	uint8_t totalReceived = 0;
	uint8_t currentReceived = 0;
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
	XUartLite_Send(&uart, receiveBuffer, 80);
	XGpio_DiscreteWrite(&led,1,2);
	while(1);

	return 0;
}
