// File: STM32L432KC_SPI.c
// Author: Rai Wandeler
// Email: rwandeler@hmc.edu
// Date: 2026-11-01
// 
// Functionality to send/receive a character (byte) over SPI and initialize the SPI peripheral as a
// controller with software control of the CS Pin, an MSB-first 8-bit frame, and a configurable baud
// rate, CPOL, and CPHA

#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include "../src/main.h"

/* Enables the SPI peripheral and initializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
void initSPI(int br, int cpol, int cpha) {
    pinMode(DS1722_CS_PIN, GPIO_OUTPUT);
    pinMode(POCI_PIN, GPIO_ALT);
    pinAlternateFunction(POCI_PIN, AF5);
    pinMode(PICO_PIN, GPIO_ALT);
    pinAlternateFunction(PICO_PIN, AF5);
    pinMode(SCK_PIN, GPIO_ALT);
    pinAlternateFunction(SCK_PIN, AF5);

    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN; // enable SPI1
    SPI1->CR1 |= (br<<SPI_CR1_BR_Pos);
    SPI1->CR1 |= (cpol<<SPI_CR1_CPOL_Pos);
    SPI1->CR1 |= (cpha<<SPI_CR1_CPHA_Pos);
    // MSB First by default
    SPI1->CR1 |= (1<<SPI_CR1_SSM_Pos); // CS controlled by Software GPIO
    SPI1->CR1 |= (1<<SPI_CR1_SSI_Pos); // Prevent Mode Fault
    SPI1->CR1 |= (1<<SPI_CR1_MSTR_Pos); // set as controller

    SPI1->CR2 |= (0b0111<<SPI_CR2_DS_Pos); // 8-bit frame
    // SSOE not needed 
    SPI1->CR2 |= (1<<SPI_CR2_FRXTH_Pos);

    SPI1->CR1 |= (1<<SPI_CR1_SPE_Pos); // enable SPI
}

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- cs_pin: pin number to drive HIGH to enable the SPI device
 *    -- return: the character received over SPI 
 *
 *    NOTE: this function does not set CS low after returning in order to allow multi-byte transactions
*/
char spiSendReceive(char send, int cs_pin) {
    while(!(SPI1->SR & SPI_SR_TXE)); // wait until space
    digitalWrite(cs_pin, PIO_HIGH); // set chip-select HIGH

    *(volatile char *)(&SPI1->DR) = send;
    while(!(SPI1->SR & SPI_SR_RXNE)); // wait until there is data in RX buffer
    char receive = SPI1->DR;

    return receive; // return character
}
