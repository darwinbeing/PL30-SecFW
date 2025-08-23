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
Function: ADCAN0Interrupt
Description: ISR Triggered at End Of Conversion of AN0 ADC Channel.
This ISR measures the Valley Current at every inductor current cycle and 
implements the digital slope compensation algorithm. The ISR also calculates
ans stores the average inductor current. The ISR also monitors for High Current
Condition (ShortCkt) and raises flag. The ISR also triggers AN3 for sampling
and converting Input voltage (at center tap).A provision is given for storing 
variables for viewing using DMCI. For using DMCI uncomment the DMCI symbol 
in Defines.inc file.    
 ***************************************************************************/	
; W0-W1 - Misc. use 
; W2  - #ADCBUF0
; W3  - #Ivalley
; W4-W5 - MAC and Misc use
; W6  - #IpeakcmpmaxQ15
; W7  - #IpeakcmpminQ15    
; W8  - #_slope_params
; W9  - #0x0000
; W10 - #_slope_currents
; W11 - #VO5V 
; W12 - #_Iavg
; W13 - #_Ipeakrefcmp
; w14 - #DMCIMAXCOUNT   
 
    
 .pushsection    .text._ADCAN0Interrupt, code, keep
    .global __ADCAN0Interrupt
    .type   __ADCAN0Interrupt, @function
 
 __ADCAN0Interrupt:  
 bset LATC,#4

; Valley Current Measurement and Normalization
mov [w2], [w3]				; Ivalley = ADCBUF0 (12bit)
sl [w2], w0				; w0<<1 = ivalley[n]Q3.13
mov w0,(_measured_data+0x4)             ; measured_data[2]= ivalleyQ13     
mov w0,[w10]                            ; slope_currents[0] = ivalley[n]Q13

; icmp = d[n] * ivalley[n] + ddash[n] * ipeakref[n]
clr A, [w8]+=2,w4,[w10]+=2,w5           ; A =0, w4 = slope_params[0]=>d[n]Q15, w8-->slope_params[1], w5=slope_currents[0]=>ivalley[n]Q15, w10-->slope_currents[1]=>ipeakref[n]
mac w4*w5,A,[w8]-=2,w4,[w10]-=2,w5      ; A = A + d[n]Q15 * IvalleyQ13, w4 = slope_params[1]=>ddash[n]Q15,w8-->slope_params[0], w5 = slope_currents[1]=>ipeakref[n]Q13, w10-->slope_currents[0]
mac w4*w5,A                             ; A = A + ddash[n]Q15 * ipeakrefQ13 => A = IcmprefQ28
sac.r A,#-3,w0                          ; w0 =  A<<3 = IcmprefQ15

; Check Peak Current Limit before loading to CMPDAC
cpslt w0, w6                             ; if IcmprefQ15 > IpeakcmpmaxQ15(w0>w6), go to next step, otherwise skip next step
mov w6, w0				 ; IcmprefQ15 = IpeakcmpmaxQ15

cpsgt w0, w7                             ; if IcmprefQ15 < IpeakcmpminQ15(w0<w7), go to next step, else skip next step
mov w7, w0				 ; IcmprefQ15 = IpeakcmpminQ15

asr w0,#DACscaler, w0                    ; w0 = Ipeakrefcmp-12bit

; Limit Inrush Current + Load CMPDAC
mov _SystemState, w1
cpsne w1, w9
mov #CMPDACINIT, w0                      ; If SystemState = STARTUP, then load Peak Current value as CMPDACINIT else load Ipeakrefcmpdac
mov w0, CMP3DAC				 ; Load SlopeCompensated Peak Current Reference in CMP3DAC
bset ADCON3L, #6		         ; Trigger Center Tap Voltage(AN) using Common SW Trigger. Cleared by HW

 ; Average Inductor Current (Iavg) calculations 
add w0,[w3],w1				; w1= Ipeakrefcmp+Ivalley (Q12.0+Q12.0)
asr w1,[w12]				; [w12] = w1/2 = Iavg
mov w0,[w13]				; Store Ipeakrefcmp[n] = [w12] 

 ; Fast Current Protection 
mov _VrefQ15, w1
mov #SHORTCKTLIMIT, w0
cpsgt w1, w11			;if Vref < 5V, then load w0=SHORTCKTLIMITSS, else load w0 = SHORTCKTLIMIT
mov #SHORTCKTLIMITSS, w0   
		
mov [w3], w4			; w4 = IvalleyQ12.0

inc.b _ShortCktCounter		; increment counter, cleared if not overcurrent
cpsgt w4, w0			; if Ivalley<SHORTCKTLIMIT/SS then clear counter
clr _ShortCktCounter		; reset counter


.ifdef DMCI 
mov #_DMCIcount, w5                     ; w5 &count
mov [w5],w4                              ; w4 = count
cpslt w4, w14                            ; if count < maxcount then skip next step
mov w9, [w5]				 ; if count >= maxcount then reset counter count = 0

mov #_DMCI1 , w0                         ; w0--> DMCI1
mov ADCBUF4, w1				 ; w1 = ui[n]
mov w1, [w0 + w4]                        ; DMCI1[count] = ADCBUFx

mov #_DMCI2, w0                          ; w0 --> DMCI2
mov ADCBUF0, w1				 ; w1 = Ivalley
mov w1,[w0+w4]                           ; DMCI2[count] = ADCBUFx

inc2 w4,[w5]                             ; count = count + 2
.endif


bset _criticalISRDone, #1		  ; Set bit 1 of this variable 
bclr IFS6, #ADCAN0IF                      ; Clear ADCAN0IF
bclr LATC, #4
retfie   
    

   