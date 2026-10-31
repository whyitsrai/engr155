// STM32F401RE_RCC.h
// Header for RCC functions

#ifndef STM32L4_RCC_H
#define STM32L4_RCC_H

#include <stdint.h>
#include "STM32L4xx/Device/include/stm32l432xx.h"  // CMSIS device library include

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void configurePLL();
void configureClock();

#endif