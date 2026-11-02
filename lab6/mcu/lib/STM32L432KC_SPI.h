// File: STM32L432KC_SPI.h
// Author: Rai Wandeler
// Email: rwandeler@hmc.edu
// Date: 2026-11-01
// 
// Functionality to send/receive a character (byte) over SPI and initialize the SPI peripheral as a
// controller with software control of the CS Pin, an MSB-first 8-bit frame, and a configurable baud
// rate, CPOL, and CPHA

#ifndef STM32L4_SPI_H
#define STM32L4_SPI_H

#include <stdint.h>
#include "STM32L4xx/Device/include/stm32l432xx.h"  // CMSIS device library include

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
void initSPI(int br, int cpol, int cpha);

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- cs_pin: pin number to drive HIGH to enable the SPI device
 *    -- return: the character received over SPI 
 *
 *    NOTE: this function does not set CS low after returning in order to allow multi-byte transactions
*/
char spiSendReceive(char send, int cs_pin);

#endif
