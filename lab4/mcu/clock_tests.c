#include <stdint.h>

// page 823 mentions what ARPE does. We want it disabled so set bit to 0
// pg197 has clock settings
    // unless configured otherwise will use multifreq clock at 4MHz for SysTick (247)

int main(void) {
    // Enable Clocks
    *(volatile uint32_t *)(0x40021058) |= (1<<28); // enable PWR interface clock
    *(volatile uint32_t *)(0x40007000) |= (1<<8); // enable RCC_BDCR write for below
    *(volatile uint32_t *)(0x40021090) |= (1<<0); // enable low speed external oscillator
    while(!((*(volatile uint32_t *)(0x40021090)>>1)&0b1)) { // wait until LSE ready
    }
    *(volatile uint32_t *)(0x40021000) |= (1<<2); // compensate MSI freq with LSE PLL
    *(volatile uint32_t *)(0x4002104c) |= (1<<0); // enable GPIOA bank via AHB2 (pg218)
    *(volatile uint32_t *)(0x40021058) |= (1<<0); // enable clock for TIM2 via AHB2
    *(volatile uint32_t *)(0x40007000) &= ~(1<<8); // disable (158) RCC_BDCR write

    // PA5: First is base
    *(volatile uint32_t *)(0x48000000) &= ~(0b11<<10); // write 0b10 to 11:10, set output mode
    *(volatile uint32_t *)(0x48000000) |= (0b10<<10); // write 0b10 to 11:10, set output mode
    *(volatile uint32_t *)(0x48000020) |= (1<<20); // write 0b0001 to 23:20, set alternate function 1
    // Set PA10, PA6, PA9 to be LED indicator outputs
    *(volatile uint32_t *)(0x48000000) &= ~(0b11<<12); // reset shit
    *(volatile uint32_t *)(0x48000000) &= ~(0b11<<18);
    *(volatile uint32_t *)(0x48000000) &= ~(0b11<<20);
    *(volatile uint32_t *)(0x48000000) |= (0b01<<12); // PA6 is output
    *(volatile uint32_t *)(0x48000000) |= (0b01<<18); // PA9 is output
    *(volatile uint32_t *)(0x48000000) |= (0b01<<20); // PA10 is output

    // TIM2 Timer
    *(volatile uint32_t *)(0x40000018) &= ~(0b111<<4); // write 0b0011 to 6:4, toggle output bin when ==
    *(volatile uint32_t *)(0x40000018) |= (0b011<<4); // need to change this whenever stopping count (rest)
    *(volatile uint32_t *)(0x40000020) |= (1<<0); // write 0b01 to 1:0, capture output to pin, active HIGH
    *(volatile uint32_t *)(0x40000000) |= (1<<0); // write 0b1 to 0, enable timer

    // Systick (0xE000E010)
    *(volatile uint32_t *)(0xE000E010) |= (0b101<<0);    // enable and set source to processor clock
    *(volatile uint32_t *)(0xE000E014) |= 3999; // reset every 1ms, cannot be over 24 bit limit as bad shit happens

    const uint32_t maxtick = 1000;
    uint32_t currtick = 0;
    while(1) {
        if((*(volatile uint32_t *)(0xE000E010)>>16)&0b1) {
            currtick++; // increments every millisecond
        }

        if(currtick==0) {
            *(volatile uint32_t *)(0x40000014) |= (1<<0); // set Update interrupt flag, reset timer count
            *(volatile uint32_t *)(0x40000018) &= ~(0b111<<4);
            *(volatile uint32_t *)(0x40000018) |= (0b011<<4); // set output toggle mode
            *(volatile uint32_t *)(0x40000000) |= (1<<0); // enable timer
            *(volatile uint32_t *)(0x4000002c) = 1999; // TIM2 max count (up-counting), 1 kHz

            *(volatile uint32_t *)(0x48000018) |= (0b1111110111111111<<16); // Others LOW
            *(volatile uint32_t *)(0x48000018) |= (1<<10); // PA10 HIGH
        } else if(currtick==1000) {
            *(volatile uint32_t *)(0x40000014) |= (1<<0); // set Update interrupt flag, reset timer count
            *(volatile uint32_t *)(0x4000002c) = 3999; // TIM2 max count (up-counting), 500 Hz

            *(volatile uint32_t *)(0x48000018) |= (0b1111111011111111<<16); // Others LOW
            *(volatile uint32_t *)(0x48000018) |= (1<<9); // PA9 HIGH
        } else if(currtick==2000) {
            *(volatile uint32_t *)(0x40000000) &= ~(1<<0); // disable timer

            *(volatile uint32_t *)(0x40000018) &= ~(0b111<<4);
            *(volatile uint32_t *)(0x40000018) |= (0b100<<4); // turn off timer output pin

            *(volatile uint32_t *)(0x48000018) |= (0b1111111111011111<<16); // Others LOW
            *(volatile uint32_t *)(0x48000018) |= (1<<6); // PA6 HIGH
        } else if(currtick>=3000){
            currtick = 0;
        }
      }
}
