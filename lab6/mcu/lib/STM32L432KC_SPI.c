// STM32L432KC_SPI.c
// TODO: <YOUR NAME>
// TODO: <YOUR EMAIL>
// TODO: <DATE>
// TODO: <SHORT DESCRIPTION OF WHAT THIS FILE DOES>

#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include "../src/main.h"

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
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
    SPI1->CR1 |= (br<<SPI_CR1_BR_Pos); // 1.25 MHz
    //SPI1->CR1 |= (0b111<<SPI_CR1_BR_Pos); // fucking slow
    SPI1->CR1 |= (cpol<<SPI_CR1_CPOL_Pos);
    SPI1->CR1 |= (cpha<<SPI_CR1_CPHA_Pos);
    // MSB First by default
    SPI1->CR1 |= (1<<SPI_CR1_SSM_Pos); // CS controlled by Software GPIO
    SPI1->CR1 |= (1<<SPI_CR1_SSI_Pos); // Prevent Mode Fault
    SPI1->CR1 |= (1<<SPI_CR1_MSTR_Pos); // set as peripheral

    SPI1->CR2 |= (0b0111<<SPI_CR2_DS_Pos); // 8-bit
    // SSOE not needed 
    SPI1->CR2 |= (1<<SPI_CR2_FRXTH_Pos);

    SPI1->CR1 |= (1<<SPI_CR1_SPE_Pos); // enable SPI
}

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- return: the character received over SPI */
char spiSendReceive(char send) {
    while(!(SPI1->SR & SPI_SR_TXE)); // wait until space
    digitalWrite(DS1722_CS_PIN, PIO_HIGH);
    // see if there is a way to make this just a tad less ugly??
    *(volatile char *)(&SPI1->DR) = send;
    while(!(SPI1->SR & SPI_SR_RXNE)); // wait until there is data in RX buffer
    char receive = SPI1->DR;
    //digitalWrite(DS1722_CS_PIN, PIO_LOW);

    return receive; // return character
}