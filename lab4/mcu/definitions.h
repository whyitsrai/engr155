#include <stdint.h>

// Map of register offsets is starting page 68 in reference manual

#define PWR_reg_CR1 (volatile uint32_t *)(0x40007000UL)

#define RCC_reg_CR (volatile uint32_t *)(0x40021000UL) // compensate MSI drift
#define RCC_reg_AHB2ENR (volatile uint32_t *)(0x4002104cUL) // Below bus enable registers
#define RCC_reg_APB1ENR1 (volatile uint32_t *)(0x40021058UL)
#define RCC_reg_BDCR (volatile uint32_t *)(0x40021090UL)

#define STCSR_reg (volatile uint32_t *)(0xE000E010UL) // SysTick Control and Status
#define STRVR_reg (volatile uint32_t *)(0xE000E014UL) // SysTick Reload Value

typedef struct {
    volatile uint32_t CR1; // using to enable/disable timer
    volatile uint32_t CR2; 
    volatile uint32_t SMCR; 
    volatile uint32_t DIER; 
    volatile uint32_t SR;
    volatile uint32_t EGR; // using to reset timer (force update)
    volatile uint32_t CCMR1; // using for i/o capture/compare mode
    volatile uint32_t CCMR2;
    volatile uint32_t CCER; // using for output capture pin config
    volatile uint32_t CNT;
    volatile uint32_t PSC;
    volatile uint32_t ARR; // max count value (auto reload)
    uint32_t reserved0[1];
    volatile uint32_t CCR1;
    volatile uint32_t CCR2;
    volatile uint32_t CCR3;
    volatile uint32_t CCR4;
    uint32_t reserved1[1];
    volatile uint32_t DCR;
    volatile uint32_t DMAR;
    volatile uint32_t OR1;
    uint32_t reserved2[3];
    volatile uint32_t OR2;
} TIMx_reg_t;
#define TIM2_reg ((TIMx_reg_t *) 0x40000000UL)

typedef struct {
    volatile uint32_t MODER; // set pinMode
    volatile uint32_t OTYPER; 
    volatile uint32_t OSPEEDR; 
    volatile uint32_t PUPDR; 
    volatile uint32_t IDR; // input data register
    volatile uint32_t ODR;
    volatile uint32_t BSRR; // set/reset output HIGH/LOW
    volatile uint32_t LCKR;
    volatile uint32_t AFRL; // alternate functions selection
    volatile uint32_t AFRH; // alternate functions selection
    volatile uint32_t BRR;
} GPIOx_reg_t;
#define GPIOA_reg ((GPIOx_reg_t *) 0x48000000UL)
