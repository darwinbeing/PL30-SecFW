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

#if defined(__dsPIC33CH__)
#define _RXDA  !U2STAHbits.URXBE
#else
#define _RXDA   U2STAbits.URXDA
#endif

// Exact match RX character sequence to trigger assignment of EZBL_COM_RX to
// this UART. Comment this line out to disable auto-bootloader wake up on this UART.

#ifndef BOOTLOADER_WAKE_KEY
//#define BOOTLOADER_WAKE_KEY     {0x434D, 0x5055, 0x4348, 0x454D} //{'M','C','U','P','H','C','M','E'}
#endif

// extern unsigned int UART2_wakeKeyIndex;

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
void __attribute__((interrupt, no_auto_psv)) _U2RXInterrupt(void)
{
    unsigned int i;
    unsigned int status;
    EZBL_COM_ACTIVITY newFlags = {.any = EZBL_COM_ACTIVITY_RX_MASK};    // Set activity.rx = 1 always

    // Clear the interrupt flag so we don't keep entering this ISR
    _U2RXIF = 0;

    // Read all available bytes. This is checked before reading anything because
    // in the event of an auto-baud 0x55 reception, we'll get this RX interrupt,
    // but won't actually have any data to put into the software RX FIFO.
    while(_RXDA)
    {
        // Get the byte
        i = U2RXREG;

        // Directly pass incoming data from PC to the PFC controller
        if(UART1_TxFifo.fifoSize > UART1_TxFifo.dataCount)
        {
            *UART1_TxFifo.headPtr++ = (char) i;

            if(UART1_TxFifo.headPtr >= UART1_TxFifo.fifoRAM + UART1_TxFifo.fifoSize)
            {
                UART1_TxFifo.headPtr = UART1_TxFifo.fifoRAM;
            }
            EZBL_ATOMIC_ADD(UART1_TxFifo.dataCount, 1);

            if(!U1STAbits.UTXBF)        //If buffer not full force interrupt for sending data to PFC controller
                _U1TXIF = 1;
        }
        else
        {
            UART1_TxFifo.activity.rxOverflow = 1;
        }

        // Collect any Parity (not used, so never should be set), Framing,
        // and Overrun errors. Parity/Framing errors persist only while the
        // applicable byte is at the top of the hardware RX FIFO, so we need to
        // collect it for every byte.
        status = U2STA;
        if(status & _U2STA_OERR_MASK)
        {
            U2STAbits.OERR = 0;    // Clear overflow flag if it it has become set. This bit prevents future reception so it must be cleared.
            newFlags.rxOverflow = 1;
        }
        if(status & _U2STA_FERR_MASK)
            newFlags.framingError = 1;
        if(status & _U2STA_PERR_MASK)
            newFlags.parityError = 1;

#if defined(BOOTLOADER_WAKE_KEY)

        // Check if Bootloader needs waking up
        short bootloaderWakeKey[] = BOOTLOADER_WAKE_KEY; // An exact-match RX string to allow EZBL Bootloader code to come alive and start Bootloader command processing when the Application is running.

        UART2_wakeKeyIndex &= 0x0007;                         // Restrict index to 0-7 so we don't have to bounds check if no crt data initialization is performed (saves perhaps 200 bytes of flash to disable this linker option)
        if(((char)i) == ((char*)bootloaderWakeKey)[UART2_wakeKeyIndex])
        {   // Might be external node trying to contact Bootloader, so decode the "MCUPHCME" first few bytes to decide if we should activate Bootloader command processing or not
            if(++UART2_wakeKeyIndex >= sizeof(bootloaderWakeKey))
           {   // All 8 bytes matched exactly, enable the EZBL command processor task
                newFlags.bootkeyRx = 1;
                EZBL_COM_RX = &UART2_RxFifo;
                EZBL_COM_TX = &UART2_TxFifo;
            }
        }
        else {
            UART2_wakeKeyIndex = 0;
            if(((char)i) == ((char*)bootloaderWakeKey)[0])
                UART2_wakeKeyIndex = 1;
        }
#endif

        // Throw this byte away if it would cause overflow
        if(UART2_RxFifo.dataCount >= UART2_RxFifo.fifoSize)
        {
            newFlags.rxOverflow = 1;
            continue;
        }

        // Copy the byte into the local FIFO
        // NOTE: The FIFO internal data structures are being accessed directly
        // here rather than calling the UART_RX_FIFO_Write*() functions because
        // any function call in an ISR will trigger a whole lot of compiler
        // context saving overhead. The compiler has no way of knowing what
        // registers any given function will clobber, so it has to save them
        // all. For efficiency, the needed write-one-byte code is duplicated
        // here.
        // *UART2_RxFifo.headPtr++ = (unsigned char)i;
        // if(UART2_RxFifo.headPtr >= UART2_RxFifo.fifoRAM + UART2_RxFifo.fifoSize)
        // {
        //     UART2_RxFifo.headPtr = UART2_RxFifo.fifoRAM;
        // }
        // EZBL_ATOMIC_ADD(UART2_RxFifo.dataCount, 1);
    }

   // Update all the activity flags we accumulated, including RxFifo.activity.rx = 1
    // UART2_RxFifo.activity.any |= newFlags.any;
}
