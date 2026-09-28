#include <stdint.h>
#include "notes.h"
#include "definitions.h"

void setup(void);

void play_tune(const int tune[][2], const uint32_t size);

int main(void) {
    setup();
    uint32_t tune_selection = 0;
    uint32_t sw2status = 0;
    uint32_t sw2buf = 0;
    uint32_t sw3status = 0;
    uint32_t sw3buf = 0;
    while(1) {
        switch (tune_selection) {
            case 0:
                GPIOA_reg->BSRR |= (0b1111101111111111<<16); // Others LOW
                GPIOA_reg->BSRR |= (0b0000010000000000); // PA10 HIGH
                if(sw2status == 1) {
                    sw2status = 2; // switch press registered
                    tune_selection = 1; // next tune selection
                }
                if(sw3status == 1) {
                    sw3status = 2; // switch press registered
                    play_tune(fuer_elise_notes, sizeof(fuer_elise_notes)/sizeof(fuer_elise_notes[0]));
                }
                break;
            case 1:
                GPIOA_reg->BSRR |= (0b1111110111111111<<16); // Others LOW
                GPIOA_reg->BSRR |= (0b0000001000000000); // PA9 HIGH
                if(sw2status == 1) {
                    sw2status = 2;
                    tune_selection = 2;
                }
                if(sw3status == 1) {
                    sw3status = 2;
                    play_tune(dragonforce_notes, sizeof(dragonforce_notes)/sizeof(dragonforce_notes[0]));
                }
                break;
            default:
                GPIOA_reg->BSRR |= (0b1111111110111111<<16); // Others LOW
                GPIOA_reg->BSRR |= (0b0000000001000000); // PA6 HIGH
                if(sw2status == 1) {
                    sw2status = 2;
                    tune_selection = 0;
                }
                if(sw3status == 1) {
                    sw3status = 2;
                    play_tune(testing_notes, sizeof(testing_notes)/sizeof(testing_notes[0]));
                }
                break;
        }

        // read switch presses with debounce shift register, when pressed becomes state 1
        // after being registered (state 2), switch cannot be pressed again until it is reset (state 0)
        if((*STCSR_reg>>16)&0b1) {
            sw2buf = sw2buf << 1;
            sw2buf |= ((GPIOA_reg->IDR>>4)&0b1);
            sw3buf = sw3buf << 1;
            sw3buf |= ((GPIOA_reg->IDR>>7)&0b1);
            if (sw2status == 0) {
                sw2status = (sw2buf == 0x00000000);
            }
            else if (sw2status == 2 && sw2buf == 0xffffffff) {
                sw2status = 0;
            }
            if (sw3status == 0) {
                sw3status = (sw3buf == 0x00000000);
            }
            else if (sw3status == 2 && sw3buf == 0xffffffff) {
                sw3status = 0;
            }
        }
    }
}

void play_tune(const int tune[][2], const uint32_t size) {
    uint32_t i = 0;
    uint32_t currtick = 0;
    GPIOA_reg->BSRR |= (0b1111111111111111<<16); // All LOW

    while(1) {
        // start of a note
        if(currtick==0) {
            if(i>=size) { // end of array! panic
                break;
            }
            else if(tune[i][0] == 0 && tune[i][1] == 0) { // reached end of tune
                break;
            }
            else if(tune[i][0] == 0) { // reached a rest
                GPIOA_reg->BSRR |= (0b1111111111111111<<16); // All LOW
                TIM2_reg->CR1 &= ~(1<<0); // disable timer
                TIM2_reg->CCMR1 &= ~(0b111<<4);
                TIM2_reg->CCMR1 |= (0b100<<4); // turn off timer output pin
            }
            else { // reached a note
                GPIOA_reg->BSRR |= (0b0000011001000000); // PA10,PA9,PA6 HIGH
                TIM2_reg->EGR |= (1<<0); // set Update interrupt flag, reset timer count
                TIM2_reg->CCMR1 &= ~(0b111<<4);
                TIM2_reg->CCMR1 |= (0b011<<4); // set output toggle mode
                TIM2_reg->CR1 |= (1<<0); // enable timer
                TIM2_reg->ARR = (2000000/tune[i][0]) - 1; // max count per toggle (4MHz clk)
            }
        }
        // end of a note
        else if(currtick>=tune[i][1]) {
            i++;
            currtick = 0;
            continue; // to ensure currtick remains 0
        }

        // 1ms counter
        if((*STCSR_reg>>16)&0b1) {
            currtick++;
        }
    }
    TIM2_reg->CCMR1 &= ~(0b111<<4);
    TIM2_reg->CCMR1 |= (0b100<<4); // turn off timer output pin
    return;
}

void setup(void) {
    // Buses & Clocks
    *RCC_reg_APB1ENR1 |= (1<<28); // enable PWR peripheral clock
    *RCC_reg_APB1ENR1 |= (1<<0); // enable TIM2 peripheral clock
    *RCC_reg_AHB2ENR |= (1<<0); // enable GPIOA peripheral clock
    *PWR_reg_CR1 |= (1<<8); // enable RCC_BDCR write for LSO
    *RCC_reg_BDCR |= (1<<0); // enable LSE (XO)
    while(!((*RCC_reg_BDCR>>1)&0b1)); // wait until LSE ready
    *RCC_reg_CR |= (1<<2); // compensate MSI freq with LSE PLL
    *PWR_reg_CR1 &= ~(1<<8); // disable (158) RCC_BDCR write

    // pinModes
    GPIOA_reg->MODER &= ~(0b11<<10); // PA5 is alternate function
    GPIOA_reg->MODER |= (0b10<<10);
    GPIOA_reg->AFRL |= (1<<20); // PA5 AF1
    GPIOA_reg->MODER &= ~(0b11<<12); // PA6 is output
    GPIOA_reg->MODER |= (0b01<<12);
    GPIOA_reg->MODER &= ~(0b11<<18); // PA9 is output
    GPIOA_reg->MODER |= (0b01<<18);
    GPIOA_reg->MODER &= ~(0b11<<20); // PA10 is output
    GPIOA_reg->MODER |= (0b01<<20);
    GPIOA_reg->MODER &= ~(0b11<<8); // PA4 is input
    GPIOA_reg->PUPDR |= (0b01<<8); // PA4 is pull-up
    GPIOA_reg->MODER &= ~(0b11<<14); // PA7 is input
    GPIOA_reg->PUPDR |= (0b01<<14); // PA7 is pull-up

    // Timers: TIM2, Systick
    TIM2_reg->CCER |= (1<<0); // output TIM2 compare to pin
    *STCSR_reg |= (0b101<<0); // enable and set source to CPU clock (4MHz)
    *STRVR_reg |= 3999; // reset every 1ms
}
