// Map of register offsets is starting page 68 in reference manual

#define PWR_reg_CR1 (volatile uint32_t *)(0x40007000UL)

#define TIM2_reg_CR1 (volatile uint32_t *)(0x40000000UL) // Enable/disable timer
#define TIM2_reg_EGR (volatile uint32_t *)(0x40000014UL) // reset timer (force update)
#define TIM2_reg_CCMR1 (volatile uint32_t *)(0x40000018UL) // output compare mode
#define TIM2_reg_CCER (volatile uint32_t *)(0x40000020UL) // output capture pin config
#define TIM2_reg_ARR (volatile uint32_t *)(0x4000002cUL) // max count value (auto reload)

#define RCC_reg_CR (volatile uint32_t *)(0x40021000UL) // compensate MSI drift
#define RCC_reg_AHB2ENR (volatile uint32_t *)(0x4002104cUL) // Below bus enable registers
#define RCC_reg_APB1ENR1 (volatile uint32_t *)(0x40021058UL)
#define RCC_reg_BDCR (volatile uint32_t *)(0x40021090UL)

#define GPIOA_reg_MODER (volatile uint32_t *)(0x48000000UL) // set pinMode
#define GPIOA_reg_PUPDR (volatile uint32_t *)(0x4800000cUL) // GPIO pull-up/pull-down
#define GPIOA_reg_IDR (volatile uint32_t *)(0x48000010UL) // input data register
#define GPIOA_reg_BSRR (volatile uint32_t *)(0x48000018UL) // set/reset output HIGH/LOW
#define GPIOA_reg_AFRL (volatile uint32_t *)(0x48000020UL) // alternate functions selection

#define STCSR_reg (volatile uint32_t *)(0xE000E010UL) // SysTick Control and Status
#define STRVR_reg (volatile uint32_t *)(0xE000E014UL) // SysTick Reload Value


// OLD SHIT UNTIL I REALIZED I WAS WASTING MY TIME

//typedef struct {
//    volatile uint32_t CR1; // Used to allow RCC_BDCR write
//    volatile uint32_t CR2;
//    volatile uint32_t CR3;
//    volatile uint32_t CR4;
//    volatile uint32_t SR1;
//    volatile uint32_t SR2;
//    volatile uint32_t SCR;
//    volatile uint32_t PUCRA;
//    volatile uint32_t PDCRA;
//    volatile uint32_t PUCRB;
//    volatile uint32_t PDCRB;
//    volatile uint32_t PUCRC;
//    volatile uint32_t PDCRC;
//    volatile uint32_t PUCRD;
//    volatile uint32_t PDCRD;
//    volatile uint32_t PUCRE;
//    volatile uint32_t PDCRE;
//    volatile uint32_t PUCRH;
//    volatile uint32_t PDCRH;
//} PWR_reg_t;
//#define PWR_reg ((PWR_reg_t *) 0x40007000UL)
//
//typedef struct {
//    volatile uint32_t CR1;
//    volatile uint32_t CR2; 
//    volatile uint32_t SMCR; 
//    volatile uint32_t DIER; 
//    volatile uint32_t SR;
//    volatile uint32_t EGR;
//    volatile uint32_t CCMR1; // i/o compare mode
//    volatile uint32_t CCMR2; // i/o compare mode
//    volatile uint32_t CCER;
//    volatile uint32_t CNT;
//    volatile uint32_t PSC;
//    volatile uint32_t ARR; // max count value
//    volatile uint32_t CCR1;
//    volatile uint32_t CCR2;
//    volatile uint32_t CCR3;
//    volatile uint32_t CCR4;
//    volatile uint32_t DCR;
//    volatile uint32_t DMAR;
//    volatile uint32_t OR1;
//    volatile uint32_t OR2;
//} TIMx_reg_t;
//#define TIM2_reg ((TIMx_reg_t *) 0x40000000UL)
