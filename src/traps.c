////////////////////////////////////////////////////////////////////////////////
// © 2015 Microchip Technology Inc.
//
// MICROCHIP SOFTWARE NOTICE AND DISCLAIMER:  You may use this software, and any 
//derivatives, exclusively with Microchip?s products. This software and any 
//accompanying information is for suggestion only.  It does not modify Microchip?s 
//standard warranty for its products.  You agree that you are solely responsible 
//for testing the software and determining its suitability.  Microchip has no 
//obligation to modify, test, certify, or support the software.
//
// THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".  NO WARRANTIES, WHETHER EXPRESS,
//IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED WARRANTIES OF
//NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE, OR ITS 
//INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION WITH ANY OTHER PRODUCTS, OR USE 
//IN ANY APPLICATION.
 
//IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL 
//OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE 
//SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR 
//THE DAMAGES ARE FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S 
//TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED 
//THE AMOUNT OF FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.

//MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE TERMS. 

////////////////////////////////////////////////////////////////////////////////


#include <xc.h>
#include "p33Exxxx.h"

//First disable PWM1H which is the active MOSFET
//Then disable PWM1L 
//Followed by PWM2H which is already OFF
//Finally disable PWM2L 
//Then disable PWM3H and PWM3L
#define MACRO_SAFE_SHUTDOWN()   \
        IOCON1bits.OVRENH = 1;  \
        Nop();                  \
        IOCON1bits.OVRENL = 1;  \
        IOCON1bits.OVRENL = 1;  \
        Nop();                  \
        IOCON2bits.OVRENH = 1;  \
        Nop();                  \
        IOCON2bits.OVRENL = 1;  \
        IOCON2bits.OVRENL = 1;  \
        Nop();                  \
        IOCON3bits.OVRENH = 1;  \
        Nop();                  \
        IOCON3bits.OVRENL = 1;  \
        Nop();                  \
        IOCON1bits.CLDAT0 = 0;  \
        IOCON2bits.CLDAT0 = 0;  \
        LATCbits.LATC8 = 1;
                
/* ****************************************************************
* Standard Exception Vector handlers if ALTIVT (INTCON2<15>) = 0  *
*                                                                 *
* Not required for labs but good to always include                *
******************************************************************/

void __attribute__((__interrupt__, no_auto_psv)) _OscillatorFail(void)
{
    INTCON1bits.OSCFAIL = 0;
    MACRO_SAFE_SHUTDOWN();
    while(1);
}

void __attribute__((__interrupt__, no_auto_psv))  _AddressError(void)
{
    INTCON1bits.ADDRERR = 0;
    MACRO_SAFE_SHUTDOWN();
    while(1)
    {
        LATBbits.LATB5 = 1;
        __asm("repeat, #10"); Nop();
        LATBbits.LATB5 = 0;
        __asm("repeat, #10"); Nop();
        LATBbits.LATB5 = 1;
        __asm("repeat, #10"); Nop();
        LATBbits.LATB5 = 0;
        __asm("repeat, #10000"); Nop();
    }
}

void __attribute__((__interrupt__, no_auto_psv))  _StackError(void)
{
    INTCON1bits.STKERR = 0;
    MACRO_SAFE_SHUTDOWN();
    while(1);
}

void __attribute__((__interrupt__, no_auto_psv)) _MathError(void)
{
    INTCON1bits.MATHERR = 0;
    MACRO_SAFE_SHUTDOWN();
    while(1);
}

void __attribute__((interrupt, no_auto_psv)) _SoftTrapError(void)
{
    if(INTCON3bits.APLL == 1)
    {
       INTCON3bits.APLL = 0;
    }
    else
    {
        MACRO_SAFE_SHUTDOWN();
        while(1);
    }
 }



/* ****************************************************************
* Alternate Exception Vector handlers if ALTIVT (INTCON2<15>) = 1 *
*                                                                 *
******************************************************************/
//void __attribute__((__interrupt__, no_auto_psv))  _AltOscillatorFail(void)
//{
//
//        INTCON1bits.OSCFAIL = 0;
//        while(1);
//}
//
//void __attribute__((__interrupt__, no_auto_psv)) _AltAddressError(void)
//{
//
//        INTCON1bits.ADDRERR = 0;
//        while(1);
//}
//
//void __attribute__((__interrupt__, no_auto_psv)) _AltStackError(void)
//{
//
//        INTCON1bits.STKERR = 0;
//        while(1);
//}
//
//void __attribute__((__interrupt__, no_auto_psv)) _AltMathError(void)
//{
//
//        INTCON1bits.MATHERR = 0;
//        while(1);
//}
