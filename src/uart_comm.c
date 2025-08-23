/*******************************************************************************
Microchip's products.  Microchip and its licensors retain all ownership and
intellectual property rights in the accompanying software and in all
derivatives here to.

This software and any accompanying information is for suggestion only. It
does not modify Microchip's standard warranty for its products. You agree
that you are solely responsible for testing the software and determining its
suitability. Microchip has no obligation to modify, test, certify, or
support the software.

THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".  NO WARRANTIES, WHETHER
EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR
PURPOSE APPLY TO THIS SOFTWARE, ITS INTERACTION WITH MICROCHIP?S PRODUCTS,
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

MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF
THESE TERMS.
*******************************************************************************/

#include "uart_comm.h"


// Transmit buffers for IC-IC communication
uint16_t tx_buffer[TX_BUF_LEN+1];
EZBL_FIFO UART_TxFifoPFC;
uint8_t UART_TxFifoBufferPFC[TX_MAX_BUF_PTR];

// Receive Buffers for IC-IC communications
uint16_t rx_buffer[RX_BUF_LEN+1];
EZBL_FIFO UART_RxFifoPFC;
uint8_t UART_RxFifoBufferPFC[RX_MAX_BUF_PTR*2];

// extern volatile uint8_t SystemState;
// extern int16_t Iavg;

uint16_t pfcState = 0, pfcFaults = 0, pfcBulkVoltage = 0;
uint16_t pfcInputVRMS = 0, pfcInputPRMS = 0;

static uint8_t CRCIncorrectCnt = 0, pfcFaultActiveCnt = 0, receivedDataCnt = 0;
static uint16_t isrT5Cnt;

// extern volatile ZVSFB_FAULTS __attribute__((near)) systemFaults;
// extern volatile ZVSFB_FLAGS __attribute__((near)) systemFlags;


void uartCommFunct(void)
{
    // Initialize UART for PFC communication channel and create task for calling UART TX
    //EZBL_SetSYM(UART1_TX_ISR_PRIORITY, 1);  // Optionally change the U1TX Interrupt priority. The default is IPL 1 (lowest possible priority).
    //EZBL_SetSYM(UART1_RX_ISR_PRIORITY, 2);  // Optionally change the U1RX Interrupt priority. The default is IPL 2 (low priority).
    //UART_Reset(1, FCY, BAUDRATE_PFC2DCDC, 0);

    // Need to override a few UART settings (9-bit data mode, x16 clock majority detect)
    // U1MODEbits.PDSEL = 3;
    // U1MODEbits.BRGH = 0;
    // U1BRG = ((FCY + BAUDRATE_PFC2DCDC) / (16*BAUDRATE_PFC2DCDC)) - 1;
    U1BRG = 0x1a;
    IPC2 = IPC2 & 0x8f00 | 0x3000;
    IEC0 |= 0x800;
    //U1MODEbits.UARTEN = 1; // Enable UART
    //U1STAbits.UTXEN = 1; // Enable UART Tx
    
   
    // Reset Fifo and setup pointers
    //EZBL_FIFOReset(&UART_TxFifoPFC, UART_TxFifoBufferPFC, sizeof(UART_TxFifoBufferPFC), 0, 0);
    //EZBL_FIFOReset(&UART_RxFifoPFC, UART_RxFifoBufferPFC, sizeof(UART_RxFifoBufferPFC), 0, 0);

    //T5CONbits.TON = 1;
    U1MODE |= 0x8000;
    U1STA |= 0x400;
}


void __attribute__ ((__interrupt__, no_auto_psv)) _T5Interrupt()
{
    uint16_t resultCRC;

    if(++isrT5Cnt >= 2)
    {
        isrT5Cnt = 0;
        // Load data to be sent to PFC controller
        // tx_buffer[0] = SystemState;
        // tx_buffer[1] = Iavg;
        // tx_buffer[2] = systemFaults.wordWriteFaults;
        tx_buffer[3] = 0xA5A5;

        // Perform CRC on data to be transmitted, sufficient to take 2 of 4 bytes
        resultCRC = EZBL_CRC32(CRC_START, &tx_buffer[0], 2*TX_BUF_LEN);
        tx_buffer[TX_BUF_LEN] = resultCRC;

        EZBL_RAMCopy(&UART_TxFifoBufferPFC, &tx_buffer[0], TX_MAX_BUF_PTR);

        // Reset dataCount and tailPtr if fifo was emptied from last call
        if(UART_TxFifoPFC.dataCount == 0u)
        {
            UART_TxFifoPFC.tailPtr = &UART_TxFifoBufferPFC[0];
            UART_TxFifoPFC.dataCount = TX_MAX_BUF_PTR;
            _U1TXIF = 1;
        }
    }

    // If we don't receive any UART data from PFC for extended time - fault
    if(UART_RxFifoPFC.dataCount < RX_MAX_BUF_PTR)
    {
        // if(++receivedDataCnt > 20)
        // systemFaults.communication = ENABLED;
    }
    else {
        receivedDataCnt = 0;
    }

    // If data available in RX FIFO, call CRC and if valid move data to appropriate variables
    while(UART_RxFifoPFC.dataCount >= RX_MAX_BUF_PTR)
    {
        EZBL_FIFOPeek(&rx_buffer[0], &UART_RxFifoPFC, RX_MAX_BUF_PTR);

        resultCRC = EZBL_CRC32(CRC_START, &rx_buffer[0], 2*RX_BUF_LEN);

        if(resultCRC == rx_buffer[RX_BUF_LEN])  // Check CRC result
        {
            EZBL_FIFORead(0, &UART_RxFifoPFC, RX_MAX_BUF_PTR);  // Throw away good peeked data
            CRCIncorrectCnt = 0;

            #if (IO_FUNCT == UART_CRC_GOOD)
                // DRV_IO_BTG();
            #endif

            pfcState = rx_buffer[0];            // Move data to variables
            pfcFaults = rx_buffer[1];
            pfcBulkVoltage = rx_buffer[2];
            pfcInputVRMS = rx_buffer[3];
            pfcInputPRMS = rx_buffer[4];        // other buffer is 0h

            // systemFlags.PFCVoltageReady = (pfcState&0x0004) ? ENABLED : DISABLED;       // Flag to enabled the DC-DC converter after PFC startup

            // systemFlags.faultPFCSide = (pfcFaults&0x0400) ? ENABLED : DISABLED;         // Set flag anytime PFC fault captured

            // if(DACOUTEN == ENABLED)
            // CMP4DAC = pfcInputPRMS;

            // if(systemFlags.faultPFCSide == ENABLED)
            // {
            //     if(++pfcFaultActiveCnt >= 15)                       // Give the DC-DC a chance to shutdown due to input undervoltage lock out
            //     {                                                   // if after 60ms, no DC-DC fault then execute faultState to be from PFC. Certain faults require this shutdown
            //         systemFaults.faultPFC = ENABLED;
            //     }
            // }
            // else
            //     pfcFaultActiveCnt = DISABLED;
        }
        else    // CRC check failed, try eating a byte to resynchronize and try again computing a CRC
        {
            EZBL_FIFORead(0, &UART_RxFifoPFC, 1);

            // if(SystemState == REGULATION)
            // {
            //     if(++CRCIncorrectCnt > CRCFAULTCNT)
            //         systemFaults.communication = ENABLED;
            // }
        }
    }

    _T5IF = 0;
}
