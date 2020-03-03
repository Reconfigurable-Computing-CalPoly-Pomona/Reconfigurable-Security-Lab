/*
 * encrypt_core.h
 *
 *  Created on: Feb 21, 2020
 *      Author: Rafed
 */

#ifndef SRC_ENCRYPT_CORE_H_
#define SRC_ENCRYPT_CORE_H_

#include "chu_init.h"

class Encrypt_Core {

public:
	enum {
		K = 0,
		P = 4,
		S = 8,
		A = 12,
		NONCE = 16,
		START = 20,
		RESET = 21,
		DONE_FLAG = 22,
		CIPHER = 23
	};

	Encrypt_Core(uint32_t base_addr);
	~Encrypt_Core();

	void write_key(uint8_t offset, uint32_t data);
	void write_message(uint8_t offset, uint32_t data);
	void write_static(uint8_t offset, uint32_t data);
	void write_associated(uint8_t offset, uint32_t data);
	void write_nonce(uint8_t offset, uint32_t data);
	void write_input(uint8_t inputType, uint8_t offset, uint32_t data);
	void write_reset(uint8_t data);
	void write_start(uint8_t data);
	uint8_t encryptDone();
	uint32_t read_cipher(uint8_t offset);

private:
	uint32_t base_addr;
	unsigned long Key, Plaintext, StaticD, AssociatedD, NONCEData, Ciphertext;
	uint8_t Start_flag,RESET_flag,DONE_flag;
};




#endif /* SRC_ENCRYPT_CORE_H_ */
