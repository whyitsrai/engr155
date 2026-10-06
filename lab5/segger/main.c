#include <stm32l4xx.h>

#define PRINT_RATE 4 // 4Hz printing

volatile int32_t edges = 0;
volatile uint32_t mstick = 0;

char printbuf[32];

void setup(void);
void setup_usbuart(void);
void setup_speedmonitoring(void);
void setup_systick(void);

int send_string(char string[]);
int get_motor_rotation_string(char string[], int32_t);

int main(void) {
    setup();
    int32_t pulses_per_rotation = 0;
    while(1) {
        // set motor type
        if(GPIOB->IDR & GPIO_IDR_ID4_Msk) {
            pulses_per_rotation = 408;
        } else {
            pulses_per_rotation = 120;
        }

        // every ms
        if((SysTick->CTRL >> SysTick_CTRL_COUNTFLAG_Pos) & 0b1) {
            mstick++;
            if(mstick >= (1000 / PRINT_RATE)) {
                GPIOB->BSRR |= GPIO_BSRR_BS3_Msk;
                int32_t ispeed = (10000 * edges * PRINT_RATE) / (4*pulses_per_rotation);
                get_motor_rotation_string(printbuf, ispeed);
                send_string(printbuf);
                mstick = 0;
                edges = 0;
                GPIOB->BSRR |= GPIO_BSRR_BR3_Msk;
            }
        }
    }
}

int get_motor_rotation_string(char deststr[], int32_t FXP_speed) {
    int isnegative = 0;
    deststr[0] = 's';
    deststr[1] = 'p';
    deststr[2] = 'e';
    deststr[3] = 'e';
    deststr[4] = 'd';
    deststr[5] = ':';
    deststr[6] = ' ';
    if (FXP_speed < 0) {
        isnegative = 1;
        FXP_speed = -1 * FXP_speed;
    }
    for(int i = 15; i >= 12; i--) {
        deststr[i] = '0' + (FXP_speed % 10);
        FXP_speed /= 10;
    }
    deststr[11] = '.';
    for(int i = 10; i >= 7; i--) {
        deststr[i] = '0' + (FXP_speed % 10);
        FXP_speed /= 10;
    }
    deststr[16] = ' ';
    deststr[17] = 'r';
    deststr[18] = 'p';
    deststr[19] = 's';
    deststr[20] = ' ';
    if (isnegative) {
        deststr[21] = 'C';
        deststr[22] = 'C';
        deststr[23] = 'W';
        deststr[24] = '\r';
        deststr[25] = '\n';
        deststr[26] = '\0';
    }
    else {
        deststr[21] = 'C';
        deststr[22] = 'W';
        deststr[23] = '\r';
        deststr[24] = '\n';
        deststr[25] = '\0';
    }
    return 0;
    // NNNN.dddd so get dddddddd
}

int send_string(char string[]) {
    for(int i = 0; string[i] != '\0'; i++) {
        while (!(USART2->ISR & USART_ISR_TXE_Msk)); // wait until ready to send
        USART2->TDR = string[i]; // send character
    }
    return 0;
}

// structs from stm32l432xx.h and core_cm4.h
void setup(void) {
    // Buses & Clocks
    RCC->APB1ENR1 |= (1<<28); // enable PWR peripheral
    RCC->AHB2ENR |= (1<<0); // enable GPIOA peripheral
    RCC->AHB2ENR |= (1<<1); // enable GPIOB peripheral
    PWR->CR1 |= (1<<8); // enable RCC_BDCR write for LSO enable
    RCC->BDCR |= (1<<0); // enable LSE (XO) peripheral
    while(!(RCC->BDCR & RCC_BDCR_LSERDY_Msk)); // wait for LSE lock
    RCC->CR |= (1<<2); // enable MSI freq compensation using LSE
    PWR->CR1 &= ~(1<<8); // disable RCC_BDCR write

    setup_systick();
    setup_speedmonitoring();
    setup_usbuart();
}

void setup_systick(void) {
    SysTick->CTRL &= ~(0b111<<0);
    SysTick->CTRL |= (0b101<<0); //enable ARM Cortex Systick, no interupt, source is CPU Clock
    SysTick->LOAD |= 3999; // 1ms tick
}

void setup_usbuart(void) {
    GPIOA->MODER &= ~(0b11<<30);
    GPIOA->MODER |= (0b10<<30); // PA15 is alternate function
    GPIOA->MODER &= ~(0b11<<4);
    GPIOA->MODER |= (0b10<<4); // PA2 is alternate function
    GPIOA->AFR[0] |= (0b0111<<8); // PA2 is USART2_TX
    GPIOA->AFR[1] |= (0b0011<<28); // PA15 is USART2_RX

    // USART2 (jlink usb) 115200 8N1
    USART2->CR1 &= ~(0b1<<0); // disable USART2 for configuration
    RCC->APB1ENR1 |= (0b1<<17); // enable USART2 (default on APB1 bus clk)
    USART2->BRR |= 35; // given 4MHz clk div (35), rate of 114286 baud 0.8% error
    USART2->CR1 |= (0b1<<3); // USART2 transmit mode
    USART2->CR1 |= (0b1<<0); // enable USART2

    // Monitor transmit with onboard LED
    GPIOB->MODER &= ~(0b11<<6);
    GPIOB->MODER |= (0b01<<6); // PB3 is output
}

void setup_speedmonitoring(void) {
    GPIOB->MODER &= ~(0b11<<0); // PB0 is input
    GPIOB->MODER &= ~(0b11<<2); // PB1 is input

    // Motor selection switch
    GPIOB->MODER &= ~(0b11<<8); // PB4 is input
    GPIOB->PUPDR &= ~(0b11<<8);
    GPIOB->PUPDR |= (0b01<<8); // PB4 is input pullup

    // Configure EXTI
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

// PB0 GPIO interrupt
void EXTI0_IRQHandler(void) {
    EXTI->PR1 |= (1<<0); // clear interrupt flag on EXTI0 (never read)
    if(GPIOB->IDR & GPIO_IDR_ID0_Msk) {
        if(GPIOB->IDR & GPIO_IDR_ID1_Msk) {
            edges--;
        } else {
            edges++;
        }
    } else {
        if(GPIOB->IDR & GPIO_IDR_ID1_Msk) {
            edges++;
        } else {
            edges--;
        }
    }
}

// PB1 GPIO interrupt
void EXTI1_IRQHandler(void) {
    EXTI->PR1 = (1<<1); // clear interrupt flag on EXTI1 (never read)
    if(GPIOB->IDR & GPIO_IDR_ID1_Msk) {
        if(GPIOB->IDR & GPIO_IDR_ID0_Msk) {
            edges++;
        } else {
            edges--;
        }
    } else {
        if(GPIOB->IDR & GPIO_IDR_ID0_Msk) {
            edges--;
        } else {
            edges++;
        }
    }
}

