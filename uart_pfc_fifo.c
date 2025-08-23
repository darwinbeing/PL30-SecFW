/*
 * An easily ported interrupt based UART TX and RX buffering implementation.
 * Implements independent software FIFOs for TX and RX channels.
 */

// DOM-IGNORE-BEGIN
/*******************************************************************************
  Copyright (C) 2017 Microchip Technology Inc.

  MICROCHIP SOFTWARE NOTICE AND DISCLAIMER:  You may use this software, and any
  derivatives created by any person or entity by or on your behalf, exclusively
  with Microchip's products.  Microchip and its licensors retain all ownership
  and intellectual property rights in the accompanying software and in all
  derivatives here to.

  This software and any accompanying information is for suggestion only.  It
  does not modify Microchip's standard warranty for its products.  You agree
  that you are solely responsible for testing the software and determining its
  suitability.  Microchip has no obligation to modify, test, certify, or
  support the software.

  THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".  NO WARRANTIES, WHETHER
  EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED
  WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR
  PURPOSE APPLY TO THIS SOFTWARE, ITS INTERACTION WITH MICROCHIP'S PRODUCTS,
  COMBINATION WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION.

  IN NO EVENT, WILL MICROCHIP BE LIABLE, WHETHER IN CONTRACT, WARRANTY, TORT
  (INCLUDING NEGLIGENCE OR BREACH OF STATUTORY DUTY), STRICT LIABILITY,
  INDEMNITY, CONTRIBUTION, OR OTHERWISE, FOR ANY INDIRECT, SPECIAL, PUNITIVE,
  EXEMPLARY, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, FOR COST OR EXPENSE OF
  ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWSOEVER CAUSED, EVEN IF
  MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.
  TO THE FULLEST EXTENT ALLOWABLE BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL
  CLAIMS IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF
  FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.

  MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE
  TERMS.
*******************************************************************************/
// DOM-IGNORE-END

#include "p33Fxxxx.h"
#include "ezbl_integration/ezbl.h"
#include <stdint.h>
#include "uart_comm.h"

#if defined(__dsPIC33CH__)
#define _RXDA  !U1STAHbits.URXBE
#else
#define _RXDA   U1STAbits.URXDA
#endif

extern EZBL_FIFO UART_TxFifoPFC;
extern EZBL_FIFO UART_RxFifoPFC;

unsigned char __attribute__((section(".bss.UART1_TxFifoBuffer"))) UART1_TxFifoBuffer[96];


/*********************************************************************
 * Function:        void __attribute__((weak, vector(_UARTx_VECTOR), interrupt(IPLrxSOFT), keep)) UxRXInterrupt(void)
 *                  void _ISR _UxRXInterrupt(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          Records hardware overflow/framing/etc errors
 *                  into UART_RxFifoErrors.
 *
 * Side Effects:    None
 *
 * Overview:        Receives a physical RX byte from the UART and
 *                  places it in a local RAM FIFO for software to
 *                  read it at its leisure.
 *
 * Note:            None
 ********************************************************************/

#if 0
void __attribute__((interrupt, no_auto_psv)) _U1RXInterrupt(void)
{
    
        unsigned int data;
    if (U1STA & 0x0002) {
        U1STAbits.OERR = 0;
    } 
    data = U1RXREG;

    

        IFS0bits.U1RXIF = 0; // clear RX interrupt flag


}

/*********************************************************************
 * Function:        void __attribute__((weak, vector(_UARTx_TX_VECTOR), interrupt(IPLtxSOFT), keep)) UxTXInterrupt(void)
 *                  void _ISR _UxTXInterrupt(void)
 *
 * PreCondition:    None
 *
 * Input:           Zero or more bytes are removed from the software TX FIFO
 *
 * Output:          Bytes removed from the software TX FIFO are written to the 
 *                  hardware UART TX FIFO. On return, the data has not 
 *                  physically been transmitted onto the wire yet.
 *
 * Side Effects:    None
 *
 * Overview:        Transmits physical TX FIFOed bytes out of the UART
 *
 * Note:            None
 ********************************************************************/

void __attribute__((interrupt, no_auto_psv)) _U1TXInterrupt(void)
{
    // Clear the TX interrupt flag before transmitting again
    _U1TXIF = 0;

    // Transmit a byte, if possible, if pending
    // NOTE: The FIFO internal data structures are being accessed directly
    // here rather than calling the UART_TX_FIFO_Read*() functions because
    // any function call in an ISR will trigger a whole lot of compiler 
    // context saving overhead. The compiler has no way of knowing what 
    // registers any given function will clobber, so it has to save them 
    // all. For efficiency, the needed read-one-byte code is duplicated here.
    while(!U1STAbits.UTXBF)
    {
        // Stop loading UART TX REG if there is nothing left to transmit
        if (UART_TxFifoPFC.dataCount > 0u)
        {
            // Transmit data w/ 9th-bit set
            U1TXREG = 0x100 | (*UART_TxFifoPFC.tailPtr++); 
            EZBL_ATOMIC_SUB(UART_TxFifoPFC.dataCount, 1);    
        }
        else if(UART1_TxFifo.dataCount > 0u)
        {    
            // Get a byte from the TX buffer
            U1TXREG = (uint16_t)*UART1_TxFifo.tailPtr++;
            if(UART1_TxFifo.tailPtr >= UART1_TxFifo.fifoRAM + UART1_TxFifo.fifoSize)
                UART1_TxFifo.tailPtr = UART1_TxFifo.fifoRAM;
            EZBL_ATOMIC_SUB(UART1_TxFifo.dataCount, 1);
            UART1_TxFifo.activity.tx = 1;
        }    
        else
            return;
    }
}
#endif