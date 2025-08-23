;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (C) 2016 Microchip Technology Inc.
;
; MICROCHIP SOFTWARE NOTICE AND DISCLAIMER:  You may use this software, and any
; derivatives created by any person or entity by or on your behalf, exclusively
; with Microchip's products.  Microchip and its licensors retain all ownership
; and intellectual property rights in the accompanying software and in all
; derivatives here to.
;
; This software and any accompanying information is for suggestion only.  It
; does not modify Microchip's standard warranty for its products.  You agree
; that you are solely responsible for testing the software and determining its
; suitability.  Microchip has no obligation to modify, test, certify, or
; support the software.
;
; THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".  NO WARRANTIES, WHETHER
; EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED
; WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR
; PURPOSE APPLY TO THIS SOFTWARE, ITS INTERACTION WITH MICROCHIP�S PRODUCTS,
; COMBINATION WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION.
;
; IN NO EVENT, WILL MICROCHIP BE LIABLE, WHETHER IN CONTRACT, WARRANTY, TORT
; (INCLUDING NEGLIGENCE OR BREACH OF STATUTORY DUTY), STRICT LIABILITY,
; INDEMNITY, CONTRIBUTION, OR OTHERWISE, FOR ANY INDIRECT, SPECIAL, PUNITIVE,
; EXEMPLARY, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, FOR COST OR EXPENSE OF
; ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWSOEVER CAUSED, EVEN IF
; MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.
; TO THE FULLEST EXTENT ALLOWABLE BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL
; CLAIMS IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF
; FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
;
; MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE
; TERMS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include "../../h/Defines.h"
    
/**
 * void init_ALTWREG(void);
 * Initializes Alternate W-register sets 
 *
 */    
    .pushsection .text.init_ALTWREG, code
    .global _init_ALTWREG
    .type   _init_ALTWREG, @function
_init_ALTWREG:
    ctxtswp #0x1   ;Swap to Alternate W-Reg context #1

    ; Initialize Alternate Working Registers context #1
    mov  #ADCBUF0,           w2 
    mov  #_Ivalley,           w3 
    mov  #IPK_CMPMAXQ15,     w6 
    mov  #IPK_CMPMINQ15,     w7 
    mov  #_slope_params,     w8 
    mov  #0x0000,            w9 
    mov  #_slope_currents,   w10 
    mov  #11000,              w11 
    mov  #_Iavg,             w12 
    mov  #_Ipeakrefcmp,      w13 
    mov  #DMCIMAXCOUNT,      w14 

    ctxtswp #0x2   ; Swap to Alternate W-Reg #2
   
    ; Initialize Alternate Working Registers context #2
    mov     #Q11POSLIMIT,     w6
    mov     #Q11NEGLIMIT,     w7
    mov     #_coeff,          w8
    mov     #0x0000,          w9
    mov     #_hist,           w10
    mov     #VOMINQ15,        w11
    mov     #VINMINQ14,       w12
    mov     #DUTYCYCLEMAX,    w13
    mov     #DUTYCYCLEMIN,    w14
    
    ctxtswp #0x0  ; Swap back to main register set
    return        ; Exit funtion
    
    .size   _init_ALTWREG, . - _init_ALTWREG
    .popsection
    
.end

