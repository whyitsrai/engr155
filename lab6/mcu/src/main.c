/*
File: Lab_6_JHB.c
Author: Josh Brake
Email: jbrake@hmc.edu
Date: 9/14/19
*/

// Note for later: SPI Mode is set to 0  (CPOL=0,CPHA=1)


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
	// The request has been received. now process to determine whether to turn the LED on or off
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

// continuous mode
int temperature_bits = 9;
void updateTempBits(char request[]) {
	if (inString(request, "8bit") && temperature_bits != 8) {
    spiSendReceive(0b10000000); // write to configuration register
    spiSendReceive(0b11100000);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 8;
  } else if (inString(request, "9bit") && temperature_bits != 9) {
    spiSendReceive(0b10000000); // write to configuration register
    spiSendReceive(0b11100010);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 9;
  } else if (inString(request, "10bit") && temperature_bits != 10) {
    spiSendReceive(0b10000000); // write to configuration register
    spiSendReceive(0b11100100);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 10;
  } else if (inString(request, "11bit") && temperature_bits != 11) {
    spiSendReceive(0b10000000); // write to configuration register
    spiSendReceive(0b11100110);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 11;
  } else if (inString(request, "12bit") && temperature_bits != 12) {
    spiSendReceive(0b10000000); // write to configuration register
    spiSendReceive(0b11101000);
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    temperature_bits = 12;
  }
}

int32_t readTemperature() {
    int32_t temp = 0;
    spiSendReceive(0b00000001); // read LSB addr (incs to MSB next byte)
    temp += (spiSendReceive(0x00) << 0); // get LSB
    temp += (spiSendReceive(0x00) << 8); // get MSB
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
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

  // in order to use the same SPI bus to potentially drive mikrobus device
  // PB3 is SCK, PB4 is POCI, PB5 is PICO
  // both SPI1 and SPI3 are supported
  // will use software NSS because it supposedly is more univerally used
  // Will pick PB0
  // PA12 needs to be set to be pulled down to reset wifi
  pinMode(DS1722_CS_PIN, GPIO_OUTPUT);
  pinMode(POCI_PIN, GPIO_ALT);
  pinAlternateFunction(POCI_PIN, AF5);
  pinMode(PICO_PIN, GPIO_ALT);
  pinAlternateFunction(PICO_PIN, AF5);
  pinMode(SCK_PIN, GPIO_ALT);
  pinAlternateFunction(SCK_PIN, AF5);

  initSPI(0b101, 0, 1); // 2.5MHz baud, clkpol 0, cpha 1

  spiSendReceive(0b10000000); // write to configuration register
  spiSendReceive(0b11100010); // something about temperature resolution and shit
  digitalWrite(DS1722_CS_PIN, PIO_LOW);

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
    //temperature = 0b0001100110000000; // 25.5 C RIGHT
    //temperature = 0b1001100110000000; // -102.5 C RIGHT
    //temperature = 0b0000000000000000; // 0 C RIGHT
    //temperature = 0b0111100000000000; // 120 C RIGHT
    //temperature = 0b1110011011110000; // -25.0625 C RIGHT
    //temperature = 0b0001100100010000; // 25.0625 C RIGHT
    //temperature = 0b1111010111100000; // -10.125 C RIGHT
    //temperature = 0b1100100100000000; // -55 C RIGHT
    temperature = (int32_t)(temperature << 16) >> 16; // sign extend

    if (rankine == 1)
      temperature = temperature * 9 / 5 + (491<<8) + (1<<7) + (1<<5) + (1<<4); // approx int arith

    int32_t whole;
    int32_t fractional;
    if(temperature >= 0) {
      whole = temperature >> 8;
      fractional = 0;
      fractional += (temperature >> 7 & 1) * 5000;
      fractional += (temperature >> 6 & 1) * 2500;
      fractional += (temperature >> 5 & 1) * 1250;
      fractional += (temperature >> 4 & 1) * 625; // if you prepend a 0, c interprets this as 405
    } else {
      whole = (temperature >> 8) + 1;
      fractional = 10000;
      fractional -= (temperature >> 7 & 1) * 5000;
      fractional -= (temperature >> 6 & 1) * 2500;
      fractional -= (temperature >> 5 & 1) * 1250;
      fractional -= (temperature >> 4 & 1) * 625;
      // correct for whole number negative
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
