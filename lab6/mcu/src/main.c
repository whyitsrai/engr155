/*
File: main.c
Author: Rai Wandeler
Email: rwandeler@hmc.edu
Date: 2026-11-1

Code modified from: https://github.com/HMC-E155/hmc-e155/blob/main/lab/lab06/src/main.c
*/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "main.h"

//Defining the web page in two chunks: everything before the current time, and everything after the current time
char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Lab 6 Dashboard</title>\
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
    </head>\
    <body><h1>E155 Lab 6 Dashboard</h1>";
char* ledCtrlStr = "<p><form action=\"ledon\"> LED Control: <input type=\"submit\" value=\"Enable\">\
    <input type=\"submit\" value=\"Disable\" formaction=\"ledoff\"></form></p>";
char* unitSelStr = "<p><form action=\"rankine\"> Units: <input type=\"submit\" value=\"Rankine\">\
    <input type=\"submit\" value=\"Boring\" formaction=\"boring\"></form></p>";
char* sensorBitStr = "<p><form action=\"8bit\"> DS1722 Resolution: <input type=\"submit\" value=\"8 Bits\">\
    <input type=\"submit\" value=\"9 Bits\" formaction=\"9bit\">\
    <input type=\"submit\" value=\"10 Bits\" formaction=\"10bit\">\
    <input type=\"submit\" value=\"11 Bits\" formaction=\"11bit\">\
    <input type=\"submit\" value=\"12 Bits\" formaction=\"12bit\"></form></p>";
char* webpageEnd   = "</body></html>";

//determines whether a given character sequence is in a char array request, returning 1 if present, 0 if not present
int inString(char request[], char des[]) {
    if (strstr(request, des) != NULL) {return 1;}
    return 0;
}

int led_status = 0;
void updateLEDStatus(char request[]) {
    if (inString(request, "ledoff")) {
        digitalWrite(LED_PIN, PIO_LOW);
        led_status = 0;
    }
    else if (inString(request, "ledon")) {
        digitalWrite(LED_PIN, PIO_HIGH);
        led_status = 1;
    }
}

int rankine = 1;
void updateTempUnits(char request[]) {
    if (inString(request, "boring"))
        rankine = 0;
    else if (inString(request, "rankine"))
        rankine = 1;
}

int temperature_bits = 9;
// all of these set the sensor to continuous temperature conversion mode
// the temperature_bits variable ensures that reconfiguration does not take place
// when the bit configuration button is pushed a second time as this messes up the
// reading stored inside the sensor's register
void updateTempBits(char request[]) {
    if (inString(request, "8bit") && temperature_bits != 8) {
    spiSendReceive(0b10000000, DS1722_CS_PIN); // write to configuration register
    spiSendReceive(0b11100000);
    digitalWrite(DS1722_CS_PIN, PIO_LOW); // end SPI transaction
    temperature_bits = 8;
  } else if (inString(request, "9bit") && temperature_bits != 9) {
    spiSendReceive(0b10000000, DS1722_CS_PIN);
    spiSendReceive(0b11100010, DS1722_CS_PIN);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 9;
  } else if (inString(request, "10bit") && temperature_bits != 10) {
    spiSendReceive(0b10000000, DS1722_CS_PIN);
    spiSendReceive(0b11100100, DS1722_CS_PIN);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 10;
  } else if (inString(request, "11bit") && temperature_bits != 11) {
    spiSendReceive(0b10000000, DS1722_CS_PIN);
    spiSendReceive(0b11100110, DS1722_CS_PIN);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 11;
  } else if (inString(request, "12bit") && temperature_bits != 12) {
    spiSendReceive(0b10000000, DS1722_CS_PIN);
    spiSendReceive(0b11101000, DS1722_CS_PIN);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 12;
  }
}

int32_t readTemperature() {
    int32_t temp = 0;
    spiSendReceive(0b00000001, DS1722_CS_PIN); // read LSB of temperature register next transaction
    temp += (spiSendReceive(0x00, DS1722_CS_PIN) << 0); // read LSB
    temp += (spiSendReceive(0x00, DS1722_CS_PIN) << 8); // increment addr and read MSB
    digitalWrite(DS1722_CS_PIN, PIO_LOW); // end SPI transaction
    return temp;
}

int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  gpioEnable(GPIO_PORT_C);

  pinMode(LED_PIN, GPIO_OUTPUT);
  
  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  initTIM(TIM15);

  USART_TypeDef * USART = initUSART(USART1_ID, 125000);

  pinMode(DS1722_CS_PIN, GPIO_OUTPUT);
  pinMode(POCI_PIN, GPIO_ALT);
  pinAlternateFunction(POCI_PIN, AF5);
  pinMode(PICO_PIN, GPIO_ALT);
  pinAlternateFunction(PICO_PIN, AF5);
  pinMode(SCK_PIN, GPIO_ALT);
  pinAlternateFunction(SCK_PIN, AF5);

  initSPI(0b101, 0, 1); // 1.25MHz baud, clkpol=0, cpha=1

  spiSendReceive(0b10000000, DS1722_CS_PIN); // write to configuration register
  spiSendReceive(0b11100010, DS1722_CS_PIN); // 9 bits resolution, cont. temp. conv. mode
  digitalWrite(DS1722_CS_PIN, PIO_LOW); // end SPI transaction

  while(1) {
    /* Wait for ESP8266 to send a request.
    Requests take the form of '/REQ:<tag>\n', with TAG begin <= 10 characters.
    Therefore the request[] array must be able to contain 18 characters.
    */

    // Receive web request from the ESP
    char request[BUFF_LEN] = "                  "; // initialize to known value
    int charIndex = 0;
  
    // Keep going until you get end of line character
    while(!inString(request, "\n")) {
      // Wait for a complete request to be transmitted before processing
      while(!(USART->ISR & USART_ISR_RXNE));
      request[charIndex++] = readChar(USART);
    }

    updateLEDStatus(request);
    char ledStatusStr[20];
    if (led_status == 1)
      sprintf(ledStatusStr,"LED is on!");
    else if (led_status == 0)
      sprintf(ledStatusStr,"LED is off!");

    updateTempUnits(request);
    updateTempBits(request);
    int32_t temperature = readTemperature();

    char tempStatusStr[24];
    temperature = (int32_t)(temperature << 16) >> 16; // sign extend

    // approximate integer conversion using fixed-point arithmetic Q24.8
    if (rankine == 1)
      temperature = temperature * 9 / 5 + (491<<8) + (1<<7) + (1<<5) + (1<<4);

    // This Section uses approximate integer mathematics to separately decode the Q24.8 fixed-point
    // temperature readout into a whole number and decimal portion. This is done in order to avoid
    // including the heavy float library and to be able to use sprintf using %i while still printing
    // a decimal point. As the sensor only read Q8.4 values (and pads with 0s), the 4 LSB are thrown out
    int32_t whole;
    int32_t fractional;
    if(temperature >= 0) {
      whole = temperature >> 8;
      fractional = 0;
      fractional += (temperature >> 7 & 1) * 5000;
      fractional += (temperature >> 6 & 1) * 2500;
      fractional += (temperature >> 5 & 1) * 1250;
      fractional += (temperature >> 4 & 1) * 625;
    } else {
      whole = (temperature >> 8) + 1;
      fractional = 10000;
      fractional -= (temperature >> 7 & 1) * 5000;
      fractional -= (temperature >> 6 & 1) * 2500;
      fractional -= (temperature >> 5 & 1) * 1250;
      fractional -= (temperature >> 4 & 1) * 625;
      // necessary correction for negative whole integers (without decimals)
      if(fractional == 10000) {
        fractional = 0;
        whole--;
      }
    }
    if (rankine == 1) {
      sprintf(tempStatusStr,"%i.%04i Rankine", whole, fractional);
    } else {
      sprintf(tempStatusStr,"%i.%04i Boring Units", whole, fractional);
    }

    // finally, transmit the webpage over UART
    sendString(USART, webpageStart); // webpage header code
    sendString(USART, unitSelStr); // select temperature units
    sendString(USART, sensorBitStr); // button for selecting DS1722 temperature bits
    sendString(USART, ledCtrlStr); // button for controlling LED

    sendString(USART, "<h2>LED Status</h2>");
    sendString(USART, "<p>");
    sendString(USART, ledStatusStr);
    sendString(USART, "</p>");

    sendString(USART, "<h2>DS17222 Temperature Status</h2>");
    sendString(USART, "<p>");
    sendString(USART, tempStatusStr);
    sendString(USART, "</p>");

    sendString(USART, webpageEnd);
  }
}
