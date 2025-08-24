
#include <p33Fxxxx.h>
#include "xc.h"



void __attribute__((interrupt, no_auto_psv)) _ADCP0Interrupt(void)
{
    ADSTATbits.P0RDY = 0;          //Clear ready bit
    IFS6bits.ADCP0IF = 0;          //Clear ADC1 Interrupt Flag
}

void __attribute__((interrupt, no_auto_psv)) _ADCP1Interrupt(void)
{
    ADSTATbits.P1RDY = 0;          //Clear ready bit
    IFS6bits.ADCP1IF = 0;          //Clear ADC1 Interrupt Flag
}