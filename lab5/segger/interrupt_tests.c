#include <stdio.h>
#include <stm32l4xx.h> // consider changing depending on how things go

const double PULSES_PER_ROTATION = 408.0;
const uint32_t PRINT_RATE = 5;

volatile uint32_t pulses = 0;
volatile int direction;
volatile uint32_t mstick = 0;

void setup(void);

// For debug printf to work with SEGGER
int _write(int file, char *ptr, int len) {
    int i = 0;
    for(i=0; i<len; i++) {
        // only in debug mode, change to work with uart at some point
        ITM_SendChar((*ptr++));
    }
    return len;
}

int main(void) {
    setup();
    while(1) {
        if(((*(volatile uint32_t *)(0xE000E010UL))>>16)&0b1) {
            mstick++;
            if(mstick >= (1000 / PRINT_RATE)) {
                double speed;
                speed = (double)(pulses) / (PULSES_PER_ROTATION*4.0) * (double)(PRINT_RATE); // 4  edges per pulse
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
    while(!(RCC->BDCR>>1)&0b1); // wait for LSE lock
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
}

// set to SW3
void EXTI9_5_IRQHandler(void) {
    EXTI->PR1 = (1<<7); // clear interrupt flag on EXTI9_5 (don't want to read)
    GPIOA->BSRR |= (0b1111111111111111<<16);
    GPIOB->BSRR |= (0b1111111111111111<<16);
    pulses = 0;
}

// PB0 GPIO interrupt
void EXTI0_IRQHandler(void) {
    EXTI->PR1 |= (1<<0); // clear interrupt flag on EXTI0 (never read)
    if((GPIOB->IDR>>0)&0b01) {
        GPIOA->BSRR |= (0b0000010000000000);
        pulses++;
    } else {
        GPIOA->BSRR |= (0b0000001000000000);
        pulses++;
    }
}

// PB1 GPIO interrupt
void EXTI1_IRQHandler(void) {
    EXTI->PR1 = (1<<1); // clear interrupt flag on EXTI1 (never read)
    if((GPIOB->IDR>>1)&0b01) {
        GPIOA->BSRR |= (0b0000000001000000);
        pulses++;
    } else {
        GPIOB->BSRR |= (0b0000000000001000);
        pulses++;
    }
}