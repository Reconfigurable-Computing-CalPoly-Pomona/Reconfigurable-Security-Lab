/*****************************************************************//**
 * @file main_vanilla_test.cpp
 *
 * @brief Basic test of 4 basic i/o cores
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

//#define _DEBUG
#include "chu_init.h"
#include "gpio_cores.h"
#include "encrypt_core.h"


/**
 * blink once per second for 5 times.
 * provide a sanity check for timer (based on SYS_CLK_FREQ)
 * @param led_p pointer to led instance
 */
void timer_check(GpoCore *led_p) {
   int i;

   for (i = 0; i < 5; i++) {
      led_p->write(0xffff);
      sleep_ms(500);
      led_p->write(0x0000);
      sleep_ms(500);
      debug("timer check - (loop #)/now: ", i, now_ms());
   }
}

/**
 * check individual led
 * @param led_p pointer to led instance
 * @param n number of led
 */
void led_check(GpoCore *led_p, int n) {
   int i;

   for (i = 0; i < n; i++) {
      led_p->write(1, i);
      sleep_ms(200);
      led_p->write(0, i);
      sleep_ms(200);
   }
}

/**
 * leds flash according to switch positions.
 * @param led_p pointer to led instance
 * @param sw_p pointer to switch instance
 */
void sw_check(GpoCore *led_p, GpiCore *sw_p) {
   int i, s;

   s = sw_p->read();
   for (i = 0; i < 30; i++) {
      led_p->write(s);
      sleep_ms(50);
      led_p->write(0);
      sleep_ms(50);
   }
}

/**
 * uart transmits test line.
 * @note uart instance is declared as global variable in chu_io_basic.h
 */
void uart_check() {
   static int loop = 0;

   uart.disp("uart test #");
   uart.disp(loop);
   uart.disp("\n\r");
   loop++;
}

// instantiate switch, led
GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));
Encrypt_Core Encrypt(get_slot_addr(BRIDGE_BASE,S4_ENCRYPT));

int main() {

	uart.set_baud_rate(19200);
//	unsigned long Key, Plaintext, StaticD, AssociatedD, NONCEData;
	unsigned long long Ciphertext = 0; //should be 128 bits
	int8_t receivedData = 0;
	uint8_t counter = 0;
	uint32_t currentChunk = 0;
	int32_t tempData = 0;
	led_check(&led,10);

//	while(1)
//	{
//		uart.tx_byte(6);
//	}

   while (1) {

//	   uart_check();
	   led.write(0x01);
//	   Encrypt.write_reset(1);
	   Encrypt.write_start(0);
	   sleep_ms(10);

	   //Plaintext Receive
	   for (int i = 0; i < 4; i++)
	   {
		   led.write(0xFF00);
		   uart.disp("awaiting plaintext\n");
		   while(1)
		   {
//			   uart.disp("awaiting plaintext\n");
//			   sleep_ms(100);

			   tempData = uart.rx_byte();
			   if (tempData != -1)
			   {
				   currentChunk = currentChunk | (tempData << (counter*8));
				   counter++;	//increment here to keep indexing proper
				   if (counter >= 4)
				   {
					   Encrypt.write_input(Encrypt.P,i, currentChunk);
					   break;
				   }
			   }
			   else continue;
		   }

		   counter = 0;
	   }

	   //Key Receive
	   for (int i = 0; i < 4; i++)
	   {
		   led.write(0x00FF);
		   uart.disp("awaiting key\n");
		   while(1)
		   {
//			   sleep_ms(100);
//			   uart.disp("awaiting key\n");
			   tempData = uart.rx_byte();
			   if (tempData != -1)
			   {
				   currentChunk = currentChunk | (tempData << (counter*8));
				   counter++;	//increment here to keep indexing proper
				   if (counter >= 4)
				   {
					   Encrypt.write_input(Encrypt.K,i, currentChunk);
					   break;
				   }
			   }
			   else continue;
		   }

		   counter = 0;
	   }

	   //StaticData Receive
	   for (int i = 0; i < 4; i++)
	   {
		   uart.disp("awaiting static data\n");
		   while(1)
		   {
//			   sleep_ms(100);
//			   uart.disp("awaiting static data\n");
			   tempData = uart.rx_byte();
			   if (tempData != -1)
			   {
				   currentChunk = currentChunk | (tempData << (counter*8));
				   counter++;	//increment here to keep indexing proper
				   if (counter >= 4)
				   {
					   Encrypt.write_input(Encrypt.S,i, currentChunk);
					   break;
				   }
			   }
			   else continue;
		   }

		   counter = 0;
	   }

	   counter = 0;

	   //NONCE Receive
	   for (int i = 0; i < 4; i++)
	   {
		   uart.disp("awaiting NONCE\n");
		   while(1)
		   {
//			   sleep_ms(100);
//			   uart.disp("awaiting NONCE\n");
			   tempData = uart.rx_byte();
			   if (tempData != -1)
			   {
				   currentChunk = currentChunk | (tempData << (counter*8));
				   counter++;	//increment here to keep indexing proper
				   if (counter >= 4)
				   {
					   Encrypt.write_input(Encrypt.NONCE,i, currentChunk);
					   break;
				   }
			   }
			   else continue;
		   }

		   counter = 0;
	   }

	   //ASSOCIATED Receive
	   for (int i = 0; i < 4; i++)
	   {
		   uart.disp("awaiting associated\n");
		   while(1)
		   {
//			   sleep_ms(100);
//			   uart.disp("awaiting associated\n");
			   tempData = uart.rx_byte();
			   if (tempData != -1)
			   {
				   currentChunk = currentChunk | (tempData << (counter*8));
				   counter++;	//increment here to keep indexing proper
				   if (counter >= 4)
				   {
					   Encrypt.write_input(Encrypt.A,i, currentChunk);
					   break;
				   }
			   }
			   else continue;
		   }

		   counter = 0;
	   }

	   Encrypt.write_reset(1);
	   Encrypt.write_start(0);
	   sleep_ms(5000);
	   Encrypt.write_start(1);
	   uart.disp("encrypt started\n");

//       while (Encrypt.encryptDone() != 1) continue;
//	   uart.disp("encrypt done\n");
	   sleep_ms(15000);
	   led.write(0x02);



	   unsigned long long temp = 0;
	   //Encrypt is now done, so read cipher
	   for (int i = 0; i < 4; i++)
	   {
		   temp = Encrypt.read_cipher(i);
		   temp = temp << (i*32);
		   Ciphertext = Ciphertext | temp;
	   }
	   uart.disp("got cipher\n");

	   uint8_t currentByte = 0;
//	   char * cipherString = '0';
	   //sent 16 bytes of cipher
	   for (int i = 0; i < 16; i++)
	   {
		   currentByte = (uint8_t) (Ciphertext >> ((15-i)*8));
		   uart.tx_byte(currentByte);
	   }

	   while(1) continue;


   } //while
} //main

