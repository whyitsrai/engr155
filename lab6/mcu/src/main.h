/**
    Main Header: Contains general defines and selected portions of CMSIS files
    @file main.h
    @author Josh Brake
    @version 1.0 10/7/2020
*/

#ifndef MAIN_H
#define MAIN_H

#include "../lib/STM32L432KC.h"

#define LED_PIN PA6 // LED pin for blinking on Port B pin 3
#define PICO_PIN PB5
#define POCI_PIN PB4
#define SCK_PIN PB3
#define DS1722_CS_PIN PB0
#define DS1722_RST_PIN PA12
#define BUFF_LEN 32

#endif // MAIN_H