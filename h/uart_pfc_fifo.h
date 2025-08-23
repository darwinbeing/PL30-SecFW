/* 
 * File:   uart_pfc_fifo.h
 */

// DOM-IGNORE-BEGIN
/*******************************************************************************
  Copyright (C) 2016 Microchip Technology Inc.

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

#ifndef UART_PFC_FIFO_H
#define	UART_PFC_FIFO_H

// NOTE: This file depends on ezbl.h and ezbl_lib16.a/ezbl_lib16ep.a.
#ifndef EZBL_H
#include "ezbl.h"
#endif


// Static macros for concatenating tokens together without making them strings
// first. This is useful for prefixing letters or words onto functions,
// variables, and other symbol names.
// Ex: you can write 1 to the T2CONbits.ON register bit using:
// #define TIMER_SELECT  2
//     CAT3(T,TIMER_SELECT,CONbits.ON) = 1;
// The preprocessor will resolve this into:
//     T2CONbits.ON = 1;
#if !defined(CAT2)
#define CAT2_IN(a0,a1)              a0##a1                      // Not recommended to use this macro directly; macro expansion won't occur unless another macro wraps it.
#define CAT3_IN(a0,a1,a2)           a0##a1##a2                  // Not recommended to use this macro directly; macro expansion won't occur unless another macro wraps it.
#define CAT4_IN(a0,a1,a2,a3)        a0##a1##a2##a3              // Not recommended to use this macro directly; macro expansion won't occur unless another macro wraps it.
#define CAT5_IN(a0,a1,a2,a3,a4)     a0##a1##a2##a3##a4          // Not recommended to use this macro directly; macro expansion won't occur unless another macro wraps it.
#define CAT6_IN(a0,a1,a2,a3,a4,a5)  a0##a1##a2##a3##a4##a5      // Not recommended to use this macro directly; macro expansion won't occur unless another macro wraps it.
#define CAT2(a0,a1)                 CAT2_IN(a0,a1)              // Use this; allows macro expansion
#define CAT3(a0,a1,a2)              CAT3_IN(a0,a1,a2)           // Use this; allows macro expansion
#define CAT4(a0,a1,a2,a3)           CAT4_IN(a0,a1,a2,a3)        // Use this; allows macro expansion
#define CAT5(a0,a1,a2,a3,a4)        CAT5_IN(a0,a1,a2,a3,a4)     // Use this; allows macro expansion
#define CAT6(a0,a1,a2,a3,a4,a5)     CAT6_IN(a0,a1,a2,a3,a4,a5)  // Use this; allows macro expansion
#endif


// Macros for converting a macro value into a string representation of the
// macro value. This is needed for concatenating macro contents to other strings.
// Using STRINGIFY_INNER() directly does not allow macro expansion.
// Using STRINGIFY() does perform macro expansion of value before passing
// to the inner version.
// As an example, consider this code:
//  #define APP_VERSION_MAJOR    3
//  #define APP_VERSION_MINOR    14
//      UARTPrintROMString("Firmware version: " STRINGIFY(APP_VERSION_MAJOR) "." STRINGIFY(APP_VERSION_MINOR) "\r\n");
// Here, the version macros are integer compile-time constants. With
// stringification, the UARTPrintROMString() function doesn't need any logic to
// do binary to ASCII number conversion like the heavyweight printf() function.
#if !defined(STRINGIFY)
#define STRINGIFY_INNER(x)              #x
#define STRINGIFY(value)                STRINGIFY_INNER(value)
#endif



extern EZBL_FIFO UART_pfcTxFifo;
extern EZBL_FIFO UART_pfcRxFifo;
extern unsigned char UART_pfcTxFifoBuffer[];    // Memory array storing the actual FIFO data contents; Must be in the same named section that UART_TX_FIFO_GetSize() inline code uses.
extern unsigned char UART_pfcRxFifoBuffer[];    // Memory array storing the actual FIFO data contents; Must be in the same named section that UART_RX_FIFO_GetSize() inline code uses.
extern volatile unsigned int UART_pfcRxFifoErrors;



// Prototypes for functions declared in uart_fifo.c
void UART_PFC_Reset(unsigned long peripheralClockSpeed, unsigned long baudRate); // Resets the hardware UART module, clears all pending data in the RX and TX FIFOs, and then initializes the UART for automatic ISR based TX/RX operation.
void UART_PFC_TX_FIFO_WaitUntilFlushed(void);                                    // Blocks until TX FIFO is empty (in both software and hardware)
void UART_PFC_FIFO_EnableInterrupts(void);                                       // Sets this module's UART TX and RX interrupt enable flags
void UART_PFC_FIFO_DisableInterrupts(void);                                      // Clears this module's UART TX and RX interrupt enable flags
unsigned int UART_PFC_TX_FIFO_OnWrite(unsigned int bytesPushed, void *writeSrc, unsigned int reqWriteLen, EZBL_FIFO *writeFIFO);// EZBL_FIFOWrite() OnWrite callback function
unsigned int UART_PFC_RX_FIFO_OnRead(unsigned int bytesPulled, void *readDest, unsigned int reqReadLen, EZBL_FIFO *readFIFO);   // EZBL_FIFORead() OnRead callback function

///**
// * Efficiently retrieves the allocated RAM for the software UART RX FIFO.
// * 
// * NOTE: This inline function must be used instead of 
// * sizeof(UART_pfcRxFifo.fifoRAM) because the definition for the array size 
// * lies at the top of uart_pfc_fifo.c and not in the header's extern declaration for
// * UART_RxFifo. The C sizeof operator requires the array size to be known 
// * at compile time instead of link time.
// * 
// * @return Number of bytes allocated for the FIFO, which excludes head/tail 
// *         pointers and other FIFO state tracking variable size.
// */
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_GetSize(void)
//{
//    return __builtin_section_size(".bss.UART_RxFifoBuffer");
//}
//static inline void __attribute__((always_inline, optimize(1)))                  UART_RX_FIFO_Reset(void)
//{
//    EZBL_FIFOReset(&UART_RxFifo, UART_RxFifoBuffer, UART_RX_FIFO_GetSize(), 0, UART_RX_FIFO_OnRead);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_WritableLength(void)
//{
//    return UART_RX_FIFO_GetSize() - UART_RxFifo.dataCount;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_ReadableLength(void)
//{
//    return UART_RxFifo.dataCount;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write(void *writeData, unsigned int dataLen)
//{
//    return EZBL_FIFOWrite(&UART_RxFifo, writeData, dataLen);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write8(unsigned char writeData)
//{
//    return UART_RX_FIFO_Write(&writeData, 1);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write16(unsigned int writeData)
//{
//    return UART_RX_FIFO_Write(&writeData, 2);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write24(unsigned long writeData)
//{
//    return UART_RX_FIFO_Write(&writeData, 3);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write32(unsigned long writeData)
//{
//    return UART_RX_FIFO_Write(&writeData, 4);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write48(unsigned long long writeData)
//{
//    return UART_RX_FIFO_Write(&writeData, 6);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Write64(unsigned long long writeData)
//{
//    return UART_RX_FIFO_Write(&writeData, 8);
//}
///**
// * Copies a null-terminated string to the software RX FIFO. The null-character 
// * is not transmitted.
// * 
// * When a string literal is passed in, the string length is evaluated at compile 
// * time. When the string's length cannot be proven at compile time, or when a 
// * variable is passed in, run-time string length evaluation will occur via a 
// * call to the strlen() C standard library function.
// * 
// * Unlike printf(), '\n' characters are not expanded into "\r\n" sequences. The 
// * string contents are transmitted as binary/non-translated data.
// * 
// * @param *str Pointer to a null-terminated character string to write. The 
// *             null-terminator is not written to the FIFO.
// * 
// *             The string can be located in PSV Flash memory or any data space 
// *             location. 
// * 
// *             This parameter cannot be null.
// * 
// * @return Number of bytes copied into the FIFO. This can be less than the 
// *         string's length if the RX FIFO is full and the FIFO's OnWrite() 
// *         callback does not block or otherwise arrange for the data to be 
// *         consumed.
// * 
// *         The default behavior will block until all bytes are successfully 
// *         placed in the FIFO or an excessive blocking timeout occurs. See the 
// *         RX FIFO's OnWrite() callback implementation for the specific timeout 
// *         period.
// */
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_WriteStr(char *str)
//{
//    return UART_RX_FIFO_Write(str, __builtin_strlen(str) - 1u); // __builtin_strlen() evaluates at compile time for string literals and automatically falls back to a strlen() call when run-time evaluation is required.
//}
//#define  UART_RX_FIFO_printf(format, ...) EZBL_FIFOprintf(&UART_RxFifo, format, __VA_ARGS__)
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Read(void *readData, unsigned int dataLen)
//{
//    return EZBL_FIFORead(readData, &UART_RxFifo, dataLen);
//}
//static inline unsigned char __attribute__((always_inline, optimize(1)))         UART_RX_FIFO_Read8(void)
//{
//    unsigned char readData;
//    UART_RX_FIFO_Read(&readData, 1);
//    return readData;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Read16(void)
//{
//    unsigned int readData;
//    UART_RX_FIFO_Read(&readData, 2);
//    return readData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_RX_FIFO_Read24(void)
//{
//    unsigned long readData;
//    UART_RX_FIFO_Read(&readData, 3);
//    ((unsigned char *)&readData)[3] = 0x00;
//    return readData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_RX_FIFO_Read32(void)
//{
//    unsigned long readData;
//    UART_RX_FIFO_Read(&readData, 4);
//    return readData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_RX_FIFO_Read48(void)
//{
//    unsigned long long readData;
//    UART_RX_FIFO_Read(&readData, 6);
//    ((unsigned char *)&readData)[6] = 0x00;
//    ((unsigned char *)&readData)[7] = 0x00;
//    return readData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_RX_FIFO_Read64(void)
//{
//    unsigned long long readData;
//    UART_RX_FIFO_Read(&readData, 8);
//    return readData;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Peek(void *peekData, unsigned int dataLen)
//{
//    return EZBL_FIFOPeek(peekData, &UART_RxFifo, dataLen);
//}
//static inline unsigned char __attribute__((always_inline, optimize(1)))         UART_RX_FIFO_Peek8(void)
//{
//    unsigned char readData;
//    UART_RX_FIFO_Peek(&readData, 1);
//    return readData;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_RX_FIFO_Peek16(void)
//{
//    unsigned int readData;
//    UART_RX_FIFO_Peek(&readData, 2);
//    return readData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_RX_FIFO_Peek24(void)
//{
//    unsigned long readData;
//    UART_RX_FIFO_Peek(&readData, 3);
//    ((unsigned char *)&readData)[3] = 0x00;
//    return readData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_RX_FIFO_Peek32(void)
//{
//    unsigned long readData;
//    UART_RX_FIFO_Peek(&readData, 4);
//    return readData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_RX_FIFO_Peek48(void)
//{
//    unsigned long long readData;
//    UART_RX_FIFO_Peek(&readData, 6);
//    ((unsigned char *)&readData)[6] = 0x00;
//    ((unsigned char *)&readData)[7] = 0x00;
//    return readData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_RX_FIFO_Peek64(void)
//{
//    unsigned long long readData;
//    UART_RX_FIFO_Peek(&readData, 8);
//    return readData;
//}
//
//
///**
// * Efficiently retrieves the allocated RAM for the software UART TX FIFO.
// * 
// * NOTE: This inline function must be used instead of 
// * sizeof(UART_TxFifo.fifoRAM) because the definition for the array size 
// * lies at the top of uart_fifo.c and not in the header's extern declaration for
// * UART_TxFifo. The C sizeof operator requires the array size to be known 
// * at compile time instead of link time.
// * 
// * @return Number of bytes allocated for the FIFO, which excludes head/tail 
// *         pointers and other FIFO state tracking variable size.
// */
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_GetSize(void)
//{
//    return __builtin_section_size(".bss.UART_TxFifoBuffer");
//}
//static inline void __attribute__((always_inline, optimize(1)))                  UART_TX_FIFO_Reset(void)
//{
//    EZBL_FIFOReset(&UART_TxFifo, UART_TxFifoBuffer, UART_TX_FIFO_GetSize(), UART_TX_FIFO_OnWrite, 0);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_WritableLength(void)
//{
//    return UART_TX_FIFO_GetSize() - UART_TxFifo.dataCount;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_ReadableLength(void)
//{
//    return UART_TxFifo.dataCount;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write(void *writeData, unsigned int dataLen)
//{
//    return EZBL_FIFOWrite(&UART_TxFifo, writeData, dataLen);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write8(unsigned char writeData)
//{
//    return UART_TX_FIFO_Write(&writeData, 1);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write16(unsigned int writeData)
//{
//    return UART_TX_FIFO_Write(&writeData, 2);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write24(unsigned long writeData)
//{
//    return UART_TX_FIFO_Write(&writeData, 3);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write32(unsigned long writeData)
//{
//    return UART_TX_FIFO_Write(&writeData, 4);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write48(unsigned long long writeData)
//{
//    return UART_TX_FIFO_Write(&writeData, 6);
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Write64(unsigned long long writeData)
//{
//    return UART_TX_FIFO_Write(&writeData, 8);
//}
//
///**
// * Copies a null-terminated string to the software TX FIFO for hardware 
// * transmission in the TX ISR. The null-character is not transmitted.
// * 
// * When a string literal is passed in, the string length is evaluated at compile 
// * time. When the string's length cannot be proven at compile time, or when a 
// * variable is passed in, run-time string length evaluation will occur via a 
// * call to the strlen() C standard library function.
// * 
// * Unlike printf(), '\n' characters are not expanded into "\r\n" sequences. The 
// * string contents are transmitted as binary/non-translated data.
// * 
// * @param *str Pointer to a null-terminated character string to transmit. The 
// *             null-terminator is not transmitted.
// * 
// *             The string can be located in PSV Flash memory or any data space 
// *             location. 
// * 
// *             This parameter cannot be null.
// * 
// * @return Number of bytes copied into the FIFO. This can be less than the 
// *         string's length if the TX FIFO is full and the FIFO's OnWrite() 
// *         callback does not block or otherwise arrange for the data to be 
// *         transmitted.
// * 
// *         The default behavior will block until all bytes are successfully 
// *         placed in the FIFO or an excessive blocking timeout occurs (such as 
// *         when the UART or TX ISR is not enabled). See the TX FIFO's OnWrite()
// *         callback implementation for the specific timeout period.
// */
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_WriteStr(char *str)
//{
//    return UART_TX_FIFO_Write(str, __builtin_strlen(str) - 1u); // __builtin_strlen() evaluates at compile time for string literals and automatically falls back to a strlen() call when run-time evaluation is required.
//}
//
///**
// * Prints formatted text to the software TX FIFO using a variable length 
// * argument list.
// * 
// * This function internally calls vsprintf(), so will match your compiler's 
// * normal printf() formatting characteristics. See the compiler libraries 
// * printf() documentation for full formatting options.
// * 
// * NOTE: Because sprintf() generates the full output string before returning, 
// * this function is likely to offer greater throughput at the expense of higher 
// * latency to first character being transmitted than calling printf() that 
// * routes stdout to the UART_TX_FIFO_Write() function.
// * 
// * Additionally, because sprintf() has no buffer overflow prevention limits, 
// * care should be taken when passing in formatting strings and parameters so as 
// * to not actually cause overflow. Internally, this function will reserve the 
// * total size of the TX FIFO onto the stack as a temporary storage location 
// * before moving the formatted output into the TX FIFO. This implies that the TX 
// * FIFO's overall size needs to be >= the longest string that sprintf() 
// * generates, and when using very large FIFOs, care must be taken to ensure some 
// * stack space remains for ISRs to execute without triggering stack overflow.
// * 
//  * @param *format Constant formatting string for printf(). See compiler library 
// *                documentation on printf() for full details.
// * @param ...     Zero or more additional variables to be printed when 
// *                encountered in the format string.
// * 
// * @return Number of bytes successfully generated and written to the FIFO. This 
// *         will be less than the number of bytes the printf() call should have
// *         generated if the FIFO becomes full and the FIFO's OnWrite() callback 
// *         function does not block or otherwise arrange for extra data to be 
// *         pushed into the FIFO.
// */
//#define  UART_TX_FIFO_printf(format, ...) EZBL_FIFOprintf(&UART_TxFifo, format, __VA_ARGS__)
//
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Read(void *readData, unsigned int dataLen)
//{
//    return EZBL_FIFORead(readData, &UART_TxFifo, dataLen);
//}
//static inline unsigned char __attribute__((always_inline, optimize(1)))         UART_TX_FIFO_Read8(void)
//{
//    unsigned char readData;
//    UART_TX_FIFO_Read(&readData, 1);
//    return readData;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Read16(void)
//{
//    unsigned int readData;
//    UART_TX_FIFO_Read(&readData, 2);
//    return readData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_TX_FIFO_Read24(void)
//{
//    unsigned long readData;
//    UART_TX_FIFO_Read(&readData, 3);
//    ((unsigned char *)&readData)[3] = 0x00;
//    return readData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_TX_FIFO_Read32(void)
//{
//    unsigned long readData;
//    UART_TX_FIFO_Read(&readData, 4);
//    return readData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_TX_FIFO_Read48(void)
//{
//    unsigned long long readData;
//    UART_TX_FIFO_Read(&readData, 6);
//    ((unsigned char *)&readData)[6] = 0x00;
//    ((unsigned char *)&readData)[7] = 0x00;
//    return readData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_TX_FIFO_Read64(void)
//{
//    unsigned long long readData;
//    UART_TX_FIFO_Read(&readData, 8);
//    return readData;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Peek(void *peekData, unsigned int dataLen)
//{
//    return EZBL_FIFOPeek(peekData, &UART_TxFifo, dataLen);
//}
//static inline unsigned char __attribute__((always_inline, optimize(1)))         UART_TX_FIFO_Peek8(void)
//{
//    unsigned char peekData;
//    UART_TX_FIFO_Peek(&peekData, 1);
//    return peekData;
//}
//static inline unsigned int __attribute__((always_inline, optimize(1)))          UART_TX_FIFO_Peek16(void)
//{
//    unsigned int peekData;
//    UART_TX_FIFO_Peek(&peekData, 2);
//    return peekData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_TX_FIFO_Peek24(void)
//{
//    unsigned long peekData;
//    UART_TX_FIFO_Peek(&peekData, 3);
//    ((unsigned char *)&peekData)[3] = 0x00;
//    return peekData;
//}
//static inline unsigned long __attribute__((always_inline, optimize(1)))         UART_TX_FIFO_Peek32(void)
//{
//    unsigned long peekData;
//    UART_TX_FIFO_Peek(&peekData, 4);
//    return peekData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_TX_FIFO_Peek48(void)
//{
//    unsigned long long peekData;
//    UART_TX_FIFO_Peek(&peekData, 6);
//    ((unsigned char *)&peekData)[6] = 0x00;
//    ((unsigned char *)&peekData)[7] = 0x00;
//    return peekData;
//}
//static inline unsigned long long __attribute__((always_inline, optimize(1)))    UART_TX_FIFO_Peek64(void)
//{
//    unsigned long long peekData;
//    UART_TX_FIFO_Peek(&peekData, 8);
//    return peekData;
//}



#endif	/* UART_FIFO_H */

