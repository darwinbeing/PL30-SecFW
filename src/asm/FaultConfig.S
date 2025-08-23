/*//////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////*/

#include "../../h/Defines.h"
.include "p33Exxxx.inc"
    
/***************************************************************************
Function: PWM3Interrupt
Description: ISR Triggered at instant configured in the TRIG3 register.
This ISR disables fault for PWM2 and enables fault for PWM1 at the beginning 
of Positive Cycle. This ISR also maximises the DAC reference during normal 
loading conditions. At low loads the DAC reference is not maximised to avoid 
increase in peak current reference.This ISR also limits the peak current
during Converter StartUp     
 ***************************************************************************/	
 
 .pushsection    .text._PWM3Interrupt, code, keep
    .global __PWM3Interrupt
    .type   __PWM3Interrupt, @function
 
__PWM3Interrupt:
push.s   
bset LATC,#4
/* Re-configure Fault Settings for Peak Current Control of PWM1 */
mov #0x0503,w0
mov w0,FCLCON2                              ; Disable Fault for PWM2 during the positive cycle
mov #0x3D03,w0    
mov w0,FCLCON1                              ; Enable Fault1 for PWM1 for peak current control during the positive cycle

/*Load CMPDAC with Max DAC Value at start of positive cycle*/
mov #Ipeakcmpdacmax,w0

btsc _systemFlags, #0			    ; If SoftStartActiveFlag==1, then w0=_Ipeakrefcmp else w0=Ipeakcmpdacmax
mov _Ipeakrefcmp,w0

mov _measured_data, w1	    
mov #0x44E8,w2				    ; W2 = 8V
cpslt w1,w2				    ; if Vo>8V then w0=Ipeakcmpdacmax else w0=Ipeakrefcmp
mov #Ipeakcmpdacmax,w0

/*Limit Inrush Current at Startup */
mov _SystemState,w1			    ; To avoid peak currents during full overlap of the legs at startup
clr w2
cpsne w1,w2
mov #CMPDACMAXINIT,w0                       ;If SystemState = STARTUP, then load Peak Current Reset value as CMPDACMAXINIT */
mov w0,CMP3DAC

mov #0x1, w0
mov w0, _criticalISRDone		    ; Set bit 0 and clear bit position #1

bclr IFS6,#0                                ; Clear PWM3IF
bclr LATC,#4
   
pop.s
retfie

    
/***************************************************************************
Function: PWMSpEventMatchInterrupt
Description: ISR Triggered at instant configured in the SEVTCMP register.
This ISR disables fault for PWM1 and enables fault for PWM2 at the beginning 
of Negative Cycle. This ISR also maximises the DAC reference during normal 
loading conditions. At low loads the DAC reference is not maximised to avoid 
increase in peak current reference.This ISR also limits the peak current
during Converter StartUp     
 ***************************************************************************/	

.pushsection    .text._PWMSpEventMatchInterrupt, code, keep
    .global __PWMSpEventMatchInterrupt
    .type   __PWMSpEventMatchInterrupt, @function
    
__PWMSpEventMatchInterrupt:
push.s
bset LATC,#4
/* Re-configure Fault Settings for Peak Current Control of PWM2 */
mov #0x0503,w0
mov w0,FCLCON1                           ; Disable Fault for PWM1 during the negative cycle
mov #0x3D03,w0  
mov w0,FCLCON2                           ; Enable Fault1 for PWM2 for peak current control during the negative cycle

/*Load CMPDAC with Max DAC Value at start of negetive cycle*/
mov #Ipeakcmpdacmax,w0			;in Regulation mode Ipeakcmpdacmax is uploaded to DACREF
					;and if burstmode or softstart are active,then Ipeakrefcmp which was calculated in previous ADCAN0 interrupt will be uploaded to DACREF

btsc _systemFlags, #0			; If SoftStartActiveFlag==1, then w0=_Ipeakrefcmp else w0=Ipeakcmpdacmax
mov _Ipeakrefcmp,w0

mov _measured_data,w1
mov #0x44E8,w2				; w2 = 8V
cpslt w1,w2
mov #Ipeakcmpdacmax,w0			; if Vo>8V then w0=Ipeakcmpdacmax else w0=Ipeakrefcmp

/*Limit Inrush Current */
mov _SystemState,w1			   ; To avoid peak currents during full overlap of the legs at startup
clr w2
cpsne w1,w2
mov #CMPDACMAXINIT,w0                      ;If SystemState = STARTUP, then load Peak Current Reset value as CMPDACMAXINIT */
mov w0,CMP3DAC
bclr IFS3,#9                             ; Clear PSEMIF
bclr LATC,#4
				
pop.s
					
retfie

					