/*
 * encrypt_core.cpp
 *
 *  Created on: Feb 21, 2020
 *      Author: Rafed
 */

//io_write(base_addr, offset, data)

#include "encrypt_core.h"

Encrypt_Core::Encrypt_Core(uint32_t base_address)
{
	base_addr = base_address;
}

Encrypt_Core::~Encrypt_Core(){}

void Encrypt_Core::write_message(uint8_t offset, uint32_t data)
{
	io_write(base_addr,P+offset,data);
}

void Encrypt_Core::write_associated(uint8_t offset, uint32_t data)
{
	io_write(base_addr,A+offset,data);
}

void Encrypt_Core::write_key(uint8_t offset, uint32_t data)
{
	io_write(base_addr, K+offset, data);
}

void Encrypt_Core::write_static(uint8_t offset, uint32_t data)
{
	io_write(base_addr, S+offset, data);
}

void Encrypt_Core::write_nonce(uint8_t offset, uint32_t data)
{
	io_write(base_addr, NONCE+offset, data);
}

void Encrypt_Core::write_reset(uint8_t data)
{
	io_write(base_addr, RESET, data);
}

void Encrypt_Core::write_start(uint8_t data)
{
	io_write(base_addr, START, data);
}

uint8_t Encrypt_Core::encryptDone()
{
	return io_read(base_addr, DONE_FLAG) & 0x00000001;
}

uint32_t Encrypt_Core::read_cipher(uint8_t offset)
{
	return io_read(base_addr, CIPHER+offset);
}

void Encrypt_Core::write_input(uint8_t inputType, uint8_t offset, uint32_t data)
{
	io_write(base_addr,inputType+offset, data);
}

