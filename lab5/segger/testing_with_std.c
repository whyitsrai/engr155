#include <stdio.h>
#include <stm32l4xx.h> // consider changing depending on how things go

//const float PULSES_PER_ROTATION = 408.0;
const float PULSES_PER_ROTATION = 120.0;
const uint32_t PRINT_RATE = 4; // 4Hz printing

volatile int32_t pulses = 0;
volatile uint32_t mstick = 0;

void setup(void);

// For printf to work with SEGGER in debug mode
int _write(int file, char *ptr, int len) {
    int i = 0;
    for(i=0; i<len; i++) {
        ITM_SendChar((*ptr++));
    }
    return len;
}

// For printf to work over USART2 without debug
int __SEGGER_RTL_X_file_write(FILE *stream, const char *ptr, unsigned len) {
    int i = 0;
    for(i=0; i<len; i++) {
        while (!(USART2->ISR & USART_ISR_TXE_Msk)); // wait until ready to send
        if((char)ptr[i] == '\n') {
            USART2->TDR = '\r';
        } else {
            USART2->TDR = (char)ptr[i]; // send character
        }
    }
    return len;
}

int main(void) {
    setup();
    while(1) {
        // every ms
        if(((*(volatile uint32_t *)(0xE000E010UL))>>16)&0b1) {
            mstick++;
            if(mstick >= (1000 / PRINT_RATE)) {
                float speed;
                speed = (float)(pulses) / (PULSES_PER_ROTATION*4.0) * (float)(PRINT_RATE); // 4  edges per pulse
                printf("speed in rps: %f\n", speed);
                mstick = 0;
                pulses = 0;
            }
            
        }
    }
    
}

void setup(void) {
    // Buses & Clocks
    RCC->APB1ENR1 |= (1<<28); // enable PWR peripheral
    RCC->APB1ENR1 |= (1<<4); // enable TIM6 peripheral
    RCC->APB1ENR1 |= (1<<5); // enable TIM7 peripheral
    RCC->AHB2ENR |= (1<<0); // enable GPIOA peripheral
    RCC->AHB2ENR |= (1<<1); // enable GPIOB peripheral
    PWR->CR1 |= (1<<8); // enable RCC_BDCR write for LSO enable
    RCC->BDCR |= (1<<0); // enable LSE (XO) peripheral
    while(!(RCC->BDCR & RCC_BDCR_LSERDY_Msk)); // wait for LSE lock
    RCC->CR |= (1<<2); // enable MSI freq compensation using LSE
    PWR->CR1 &= ~(1<<8); // disable RCC_BDCR write

    GPIOA->MODER &= ~(0b11<<14); // PA7 is input
    GPIOA->PUPDR |= (0b01<<14); // PA7 is pull-up
    GPIOA->MODER &= ~(0b11<<12);
    GPIOA->MODER |= (0b01<<12); // PA6 is output
    GPIOA->MODER &= ~(0b11<<18);
    GPIOA->MODER |= (0b01<<18); // PA9 is output
    GPIOA->MODER &= ~(0b11<<20);
    GPIOA->MODER |= (0b01<<20); // PA10 is output
    GPIOB->MODER &= ~(0b11<<6);
    GPIOB->MODER |= (0b01<<6); // PB3 is output
    GPIOB->MODER &= ~(0b11<<0); // PB0 is input
    GPIOB->MODER &= ~(0b11<<2); // PB1 is input
    GPIOA->MODER &= ~(0b11<<4);
    GPIOA->MODER |= (0b10<<4); // PA2 is alternate function
    GPIOA->MODER &= ~(0b11<<30);
    GPIOA->MODER |= (0b10<<30); // PA15 is alternate function
    GPIOA->AFR[0] |= (0b0111<<8); // PA2 is USART2_TX
    GPIOA->MODER &= ~(0b11<<30);
    GPIOA->MODER |= (0b10<<30); // PA15 is alternate function
    GPIOA->AFR[1] |= (0b0011<<28); // PA15 is USART2_RX

    // Systick TODO make registers more abstract/use vendor definitions
    *(volatile uint32_t *)(0xE000E010UL) |= (0b101<<0); //enable ARM Cortex Systick, set source to CPU Clock
    *(volatile uint32_t *)(0xE000E014UL) |= 3999; // 1ms tick

    // GPIOExt Interrupts
    RCC->APB2ENR |= (1<<0); // clock SYSCFG
    SYSCFG->EXTICR[0] |= (0b001<<0); // pin bank B for EXTI line 0
    SYSCFG->EXTICR[0] |= (0b001<<4); // pin bank B for EXTI line 1
    EXTI->IMR1 |= (1<<7); // unmask line 7
    EXTI->IMR1 |= (0b11<<0); // unmask lines 0 and 1
    EXTI->RTSR1 |= (1<<7); // rising-edge trigger for line 7
    EXTI->FTSR1 |= (1<<7); // falling-edge trigger for line 7
    EXTI->RTSR1 |= (0b11<<0); // rising-edge trigger for lines 0 and 1
    EXTI->FTSR1 |= (0b11<<0); // falling-edge trigger for lines 0 and 1
    NVIC->ISER[0] |= (1<<23); // enable interrupt on EXTI9_5
    NVIC->ISER[0] |= (0b11<<6); // enable interrupt on EXTI0 and EXTI1

    // Enable Printing over USART2 (jlink usb) 115200 8N1
    USART2->CR1 &= ~(0b1<<0); // disable USART2 for configuration
    RCC->APB1ENR1 |= (0b1<<17); // enable USART2 (default on APB1 bus clk)
    USART2->BRR |= 35; // given 4MHz clk div (35), rate of 114286 baud 0.8% error
    USART2->CR1 |= (0b1<<3); // USART2 transmit mode
    USART2->CR1 |= (0b1<<0); // enable USART2
}

// set to SW3
void EXTI9_5_IRQHandler(void) {
    EXTI->PR1 = (1<<7); // clear interrupt flag on EXTI9_5 (don't want to read)
    GPIOA->BSRR |= (0b1111111111111111<<16);
    pulses = 0;
}

// PB0 GPIO interrupt
void EXTI0_IRQHandler(void) {
    EXTI->PR1 |= (1<<0); // clear interrupt flag on EXTI0 (never read)
    if(GPIOB->IDR & GPIO_IDR_ID0_Msk) {
        if(GPIOB->IDR & GPIO_IDR_ID1_Msk) {
            pulses--;
        } else {
            pulses++;
        }
    } else {
        if(GPIOB->IDR & GPIO_IDR_ID1_Msk) {
            pulses++;
        } else {
            pulses--;
        }
    }
}

// PB1 GPIO interrupt
void EXTI1_IRQHandler(void) {
    EXTI->PR1 = (1<<1); // clear interrupt flag on EXTI1 (never read)
    if(GPIOB->IDR & GPIO_IDR_ID1_Msk) {
        if(GPIOB->IDR & GPIO_IDR_ID0_Msk) {
            pulses++;
        } else {
            pulses--;
        }
    } else {
        if(GPIOB->IDR & GPIO_IDR_ID0_Msk) {
            pulses--;
        } else {
            pulses++;
        }
    }
}

// if sig 2 leading: (let's call this positive)
// sig 1: rising other sig low, falling other sig high
// sig 2: rising other sig high, falling other sig low
//
// if sig 2 following: (let's call this negative)
// sig 1: rising other sig high, falling other sig low
// sig 2: rising other sig low, falling other sig high
