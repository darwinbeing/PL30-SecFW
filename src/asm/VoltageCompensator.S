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
    
.data
Q15pu: .int 0x7FF9		/* For ddash[n]Q15 calculation */

/***************************************************************************
Function: ADCAN1Interrupt
Description: ISR Triggered at End Of Conversion of AN1 ADC Channel.
This ISR measures the Output Voltage and Input Voltage at every PWM (negative)
cycle. The ISR computes the values of d and d' to be used for Slope Compensation
calculations. The ISR executes the voltage compensator and also implements 
fast current protection. The ISR also implements theadaptive dead time adjustment
under low loading condition.     
 ***************************************************************************/	

 ; WREG6 - #Q11POSLIMIT
 ; WREG7 - #Q11NEGLIMIT
 ; WREG8 - #_coeff 
 ; WREG9 - #0x0000
 ; WREG10 - #_hist
 ; WREG11 - #VOMINQ15
 ; WREG12 - #VINMINQ14
 ; WREG13 - #DUTYCYCLEMAX
 ; WREG14 - #DUTYCYCLEMIN
 
 
  .pushsection    .text._ADCAN1Interrupt, code, keep
    .global __ADCAN1Interrupt

__ADCAN1Interrupt:                       ; This interrupt occurs during Negative Cycle
push RCOUNT				 ; Divide instruction

bset LATC, #4 
   
btss _SystemState, #1		; Regulation mode 
bra endconfig1  

mov #640, w1
mov _Ipeakrefcmp, w3
cpsgt w3,w1			
bra endconfig1    
    
btsc _systemFlags, #3   
bra incrementcounter

mov _ExitBurstModeCounter,w3
cpsgt w3, w9    
bra endconfig1   

incrementcounter: 
inc _ExitBurstModeCounter	    
mov #4, w1
mov _ExitBurstModeCounter,w3    
cpslt w3, w1			    
bclr _systemFlags, #3		   
  
cpslt w3, w1			    
clr _ExitBurstModeCounter    
    
    
endconfig1:      
; DeadTime and Trigger Adjustment for Low Load Conditions 
btsc _systemFlags, #4		; ACMains Flag
bra endconfig

btss _systemFlags, #3		; Burst Mode Flag
bra config2
    
config1:
btss _systemFlags, #6		 ; BurstModeConfigComplete Flag    
call _BurstModeConfig
bra endconfig

config2:
btss _systemFlags, #7		; NormalModeConfigComplete Flag 
call _NormalModeConfig

endconfig:

; VOLTAGE MEASUREMENT AND SCALING
; Measure and Clamp Input Voltage (Center Tap Voltage) 
mov ADCBUF3, w0                               ;  w0 = ADCBUF3 (Vin[n])
sl w0, #Vinscaler, w0                         ;  w0 = Vin[n]Q14 Since the Vct gain is Vogain/2

       
; LP-Filter for Input Voltage 
mov #ALPHAQ15, w2                             ; w2 = AlphaQ15
mul.ss w0, w2, w4                             ; [w5 w4] =  alpha * Vin[n]Q14  => Q29
sl w5, #1, w5                                 ; w5 = a*Vin[n] --> Q14
mov #(_measured_data+0x2), w0                 ; w0-->measured_data[1]=VinQ14[n-1]
mov #BETAQ15, w2                              ; w2 = BetaQ15
mul.ss w2, [w0], w2                           ; [w3 w2] = b * Vin[n-1]Q14 => Q29
sl w3, #1, w3                                 ; w3 = b * Vin[n-1] --> Q14
add w5, w3, [w0]                              ; update measured_data[1] = a * Vin[n] + b * Vin[n-1] = Vin[n]Q14
       
; Measure and Clamp Output Voltage
mov ADCBUF1, w4                           ;  w4 = ADCBUF1 (Vo[n])
sl w4, #Voscaler, w4                      ;  w4 = Vo[n]Q15

; Limit Check Output Voltage W11 - persistent Vomax 
cpsgt w4, w11                             ; if VoQ15>VominQ15,  skip next statement
mov w11, w4                               
    
mov w4, [--w0]                            ;  measured_data[0] = Vo[n]Q15

;SLOPE COMPENSATION PARAMS CALCULATIONS

; Limit Check Input Voltage W12 - persistent Vin 
mov [++w0], w3                               ; w0-->measured_data[1] =>VinQ14[n], w3 = VinQ14[n]
cpsgt w3, w12                                 ; if VinQ14 > VinminQ14 skip the next statement, w0 = Vin[n]Q14
mov w12, [w0]				     ; if VinQ14 < VinminQ14 Floor Vin to VinminQ14 , w0 = VinminQ14

; Duty cycle calculation: d[n]Q15 = Vo[n]Q29 /Vin[n]Q14 
mov [w0--], w4                               ; w4 = measured_data[1]=Vin[n]Q14, w0-->measured_data[0] = Vo[n]Q15
mov #PU_Q14, w2                             ; w2 = Q14_1pu = 0x3FFF
mul.ss w2, [w0], w2                          ; [w3 w2] = Vo[n]Q29
       
repeat #17  
div.sd w2, w4                             ; w0 = d[n]Q15 = VoQ29/VinQ14 = d[n]Q15, w1 = reminder of division
    
; Limit check for duty cycle d[n]Q15 W13/W14 - persistent duty max/min
cpslt w0, w13
mov w13, w0                                ; if d[n]Q15 > DutyCycleMax, d[n]Q15 = DutyCycleMax
cpsgt w0, w14
mov w14, w0                                ; if d[n]Q15 < DutyCycleMin, d[n]Q15 = DutyCycleMin
	
; Calculate ddash[n]Q15 
mov #_slope_params, w2                        ; w2--> slope_params[0] => d[n]Q15
mov w0, [w2++]                                ; slope_params[0] = d[n]Q15, w2-->slope_params[1]=>ddash[n]Q15
sub Q15pu,  wreg                               ; w0 = Q15_1pu - d[n]Q15 = 32767-d[n]Q15 =  ddash[n]Q15
mov w0, [w2]                                  ; slope_params[1] = ddash[n]Q15, w2-->slope_params[1]=>ddash[n]Q15

btss _systemFlags, #2			      ; Compensator Enable Flag
bra  skipcomp
    
; PI VOLTAGE COMPENSATOR 
mov _measured_data, w0                               ; w0 = Vo[n]Q15
sub _VrefQ15, wreg                                   ; w0 = VrefQ15 - Vo[n]Q15 = e[n]Q15

; Limit Error to range ( -0.99 < VerrorQ15 < 0.99 )
mov #VerrorQ15pLimit, w2
cpslt w0, w2
mov w2, w0                                            ; w0 = VerrorQ15pLimit

mov #VerrorQ15nLimit, w2
cpsgt w0, w2
mov w2, w0                                            ; w0 = VerrorQ15nLimit    
          
; Load MAC registers 
; w8  --> coeff[0]   --> { KiQ13, KpQ10 }
; w10 --> hist[0]   --> { ui[n-1]Q28LSW, ui[n-1]Q28MSW, e[n-1]Q15 }
mov #ACCBL, w2                                        ; w2-->ACCBL
mov [w10++], [w2++]                                   ; ACCBL = ui[n-1]Q28LSW, w2-->ACCBH, w10 -->ui[n-1]Q28MSW
mov [w10++], [w2]                                     ; ACCBH = ui[n-1]Q28MSW, w2-->ACCBH, w10 -->e[n-1]Q15, B = ui[n-1]Q28
        
mov [w8], w4                                          ; w4 = (KiTs/2)Q13 , w8-->(KiTs/2)Q13
mov w0, w5                                            ; w5 = w0= e[n]Q15
    
; Calculate Integral Term -->ui[n] = ui[n-1] + Ki X e[n] + Ki X e[n-1] --> Coefficient in Q13 and error in Q15 format=> u[n-1] in Q4.28 format 
mac w4*w5, B, [w8]+=2, w4, [w10], w5                  ; ui[n] = ui[n-1] + Ki * e[n],  w4 = KiQ13, w5 = e[n-1], w8 --> KpQ10, w10-->e[n-1]Q15
mac w4*w5,B                                           ; u[n] = ( u[n-1] + Ki X e[n] ) + Ki X e[n-1]  B = Iref[n]Q28, w8 --> KpQ10, w10 --> e[n-1]Q15
sac.r B, #1, w5                                       ; w5 = ui[n]Q11
 
; Limit Integral Output to within +/- 14.64pu in Q11  W6/W7 - Persistent Q11 Clamps
cpslt w5, w6
mov w6, w5
cpsgt w5, w7	
mov w7, w5				 ; w5 = ui[n]Q5.11 (clamped)
        
; Update History 
mov w0, [w10--]                          ; e[n-1] = e[n], w10-->Iref[n-1]Q28MSW
mov [w2--], [w10--]                      ; ui[n-1]Q28MSW = ACCBH, w2-->ACCBL, w10-->ui[n-1]Q28LSW
mov [w2], [w10]                          ; ui[n-1]Q28LSW = ACCBL

; Calculate Proportional Term --> up[n] = Kp * e[n]  => Q7.25
mul.ss w0, [w8--], w2                          ; [w3,w2] = Kp * e[k] Q27 => w3 = up[n]Q7.9
btsc _systemFlags, #10			       ; Old controller doesnt need the shift
sl w3, #2, w3				       ; w= up[n]Q5.11
    
; Limit Proportional Output to within +/- 14.64pu in Q11  W6/W7 - Persistent Q11 Clamps 
cpslt w3, w6
mov w6, w3
cpsgt w3, w7
mov w7, w3		    ;u3= up[n] Q5.11 (clamped)

; Calculate PI Compensator Output u[n] = ui[n] + up[n] 
add w3, w5, w5                                ; w5= u[n]Q11 = ui[n]Q11 + up[n]Q11
btsc w5, #15                                  ; If output is negative then clamp to zero
clr w5

;Clamp and convert IpeakrefQ11 to IpeakrefQ13
mov #IpeakrefmaxQ11, w4                   ; Clamp Q11 value to 0<w5<4pu
cpslt w5, w4
mov w4, w5
cpsgt w5, w9				  ; W9 - Persistent (0x0)
mov w9, w5

sl w5, #2, w5                             ; w5= IpeakrefQ13
    
; Limit Ipeakref[n]Q13 to range (IpeakrefminQ13 < Ipeakref[n]Q13 < IpeakrefmaxQ13)
mov #IpeakrefmaxQ13, w4
cpslt w5, w4
mov w4, w5
cpsgt w5,w9			   	  ; W9 - Persistent (0x0)
mov w9,w5

mov w5,(_slope_currents+0x2)                    ; Store slope_currents[2] = IpeakrefQ13
    
skipcomp: 

; Fast Current Protection 
mov _VrefQ15, w1			; w1 = VrefQ15
mov #VO5V, w3		        ; w3 = 5V

    
bclr LATC,#4

mov #SHORTCKTCNTLIMIT, w2        
cpsgt w1, w3				;if VrefQ15<5V, then load w1=SHORTCKTCNTLIMITSS, 
mov #SHORTCKTCNTLIMITSS, w2

mov _ShortCktCounter, w0
cpslt w0, w2
bra shutdown
    
btsc _SystemState, #2 
bra shutdown
    
bclr IFS6, #ADCAN1IF                         ; Clear ADCP1IF
pop RCOUNT   
retfie

shutdown:
bset IOCON1, #OVRENH            ; First disable PWM1H which is the active MOSFET
nop
bset IOCON1, #OVRENL            ; Then disable PWM1L 
bset IOCON1, #OVRENL            
nop
bset IOCON2, #OVRENH            ; Followed by PWM2H which is already OFF
nop
bset IOCON2, #OVRENL            ; Finally disable PWM2L 
bset IOCON2, #OVRENL            
nop
bset IOCON3, #OVRENH            ; Then disable PWM3H and PWM3L
nop
bset IOCON3, #OVRENL
nop
    
bclr IOCON1, #2                 ; To pull down PWMxL after override 
bclr IOCON2, #2

mov _faultState, w0		; If faultState is 0 but we entered shutdown must be from over current above
cpseq w0, w9 
bra BypassOVRCurrFault      

bset _faultState, #1    
bset _systemFaults, #0
 
BypassOVRCurrFault:
mov #SHUTDOWNCOMPLETE,w0
mov w0,_SystemState             ; SystemState = ShutdownComplete
    
bclr IFS6, #ADCAN1IF                         ; Clear ADCP1IF
pop RCOUNT    
retfie
    
        
  .pushsection    .text._BurstModeConfig, code, keep
    .global _BurstModeConfig

_BurstModeConfig:
mov #DEADTIMEBM, w0
mov w0, _DTR1
mov w0, _ALTDTR1
mov w0, _DTR2
mov w0, _ALTDTR2
    
mov #CURRENTLOOPTRIG1BM, w0
mov w0, _TRIG1

mov #CURRENTLOOPTRIG2BM, w0
mov w0, _STRIG1

mov #POSCYCLEFLTCONFIGBM, w0
mov w0, _TRIG3

mov #NEGCYCLEFLTCONFIGBM, w0
mov w0, _SEVTCMP 

mov #DUTYSYNCBM, w0
mov w0, _PDC3
mov w0, _SDC3

mov #PHASESYNCBM, w0
mov w0, _PHASE3

mov #SPHASESYNCBM, w0
mov w0, _SPHASE3

bclr LATC,#5			; Disable Parallel Mosfets during Light Loads
bclr LATC,#6

bset _systemFlags, #6
bclr _systemFlags, #7    
return
    
    
.pushsection    .text._NormalModeConfig, code, keep
    .global _NormalModeConfig
_NormalModeConfig:
mov #DEADTIME,w0
mov w0,_DTR1
mov w0,_ALTDTR1
mov w0,_DTR2
mov w0,_ALTDTR2

mov #CURRENTLOOPTRIG1,w0
mov w0,_TRIG1

mov #CURRENTLOOPTRIG2,w0
mov w0,_STRIG1

mov #POSCYCLEFLTCONFIG,w0
mov w0,_TRIG3

mov #NEGCYCLEFLTCONFIG,w0
mov w0,_SEVTCMP

mov #DUTYSYNC, w0
mov w0,_PDC3
mov w0,_SDC3

mov #PHASESYNC, w0
mov w0,_PHASE3
    
mov #SPHASESYNC, w0
mov w0, _SPHASE3

bset LATC,#5		; Enable Secy Parallel Mosfets
bset LATC,#6
    
bset _systemFlags, #7
bclr _systemFlags, #6

return
    
     
