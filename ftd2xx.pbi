; Copyright © 2001-2011 Future Technology Devices International Limited
;
; THIS SOFTWARE IS PROVIDED BY FUTURE TECHNOLOGY DEVICES INTERNATIONAL LIMITED "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
; FUTURE TECHNOLOGY DEVICES INTERNATIONAL LIMITED BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
; OF SUBSTITUTE GOODS OR SERVICES LOSS OF USE, DATA, OR PROFITS OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
; TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
; EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; FTDI DRIVERS MAY BE USED ONLY IN CONJUNCTION WITH PRODUCTS BASED ON FTDI PARTS.
;
; FTDI DRIVERS MAY BE DISTRIBUTED IN ANY FORM AS LONG AS LICENSE INFORMATION IS NOT MODIFIED.
;
; IF A CUSTOM VENDOR ID AND/OR PRODUCT ID OR DESCRIPTION STRING ARE USED, IT IS THE
; RESPONSIBILITY OF THE PRODUCT MANUFACTURER TO MAINTAIN ANY CHANGES AND SUBSEQUENT WHQL
; RE-CERTIFICATION AS A RESULT OF MAKING THESE CHANGES.
;
;
; Module Name:
;
; ftd2xx.h
;
; Abstract:
;
; Native USB device driver for FTDI FT232x, FT245x, FT2232x and FT4232x devices
; FTD2XX library definitions
;
; Environment:
;
; kernel & user mode
;
;
;
; PureBasic Notes
; ===============
; ftd2xx.pbi is derived from ftd2xx.h
; do NOT use:
;   Import "ftd2xx.lib"
; etc because that causes the SCS11 executable to require ftd2xx.dll to exist on the target machine.
; so instead of Import... we use Prototypes - more work to code but the use of OpenLibrary(#PB_Any, "ftd2xx")
; means that the code runs successfully in an environment in which ftd2xx.dll does not exist (or is not registered).
; end of PureBasic Notes

; NOTE: can't work out how to convert typedef's to PB, so retained the following for reference purposes:
; typedef PVOID   FT_HANDLE;
; typedef ULONG   FT_STATUS;

;
; Device status
;
Enumeration
  #FT_OK
  #FT_INVALID_HANDLE
  #FT_DEVICE_NOT_FOUND
  #FT_DEVICE_NOT_OPENED
  #FT_IO_ERROR
  #FT_INSUFFICIENT_RESOURCES
  #FT_INVALID_PARAMETER
  #FT_INVALID_BAUD_RATE
  
  #FT_DEVICE_NOT_OPENED_FOR_ERASE
  #FT_DEVICE_NOT_OPENED_FOR_WRITE
  #FT_FAILED_TO_WRITE_DEVICE
  #FT_EEPROM_READ_FAILED
  #FT_EEPROM_WRITE_FAILED
  #FT_EEPROM_ERASE_FAILED
  #FT_EEPROM_NOT_PRESENT
  #FT_EEPROM_NOT_PROGRAMMED
  #FT_INVALID_ARGS
  #FT_NOT_SUPPORTED
  #FT_OTHER_ERROR
  #FT_DEVICE_LIST_NOT_READY
EndEnumeration

;
; FT_OpenEx Flags
;
#FT_OPEN_BY_SERIAL_NUMBER = 1
#FT_OPEN_BY_DESCRIPTION  = 2
#FT_OPEN_BY_LOCATION   = 4

;
; FT_ListDevices Flags (used in conjunction with FT_OpenEx Flags
;
#FT_LIST_NUMBER_ONLY =  $80000000
#FT_LIST_BY_INDEX =  $40000000
#FT_LIST_ALL =    $20000000

#FT_LIST_MASK = #FT_LIST_NUMBER_ONLY|#FT_LIST_BY_INDEX|#FT_LIST_ALL

;
; Baud Rates
;
#FT_BAUD_300  = 300
#FT_BAUD_600  = 600
#FT_BAUD_1200 = 1200
#FT_BAUD_2400 = 2400
#FT_BAUD_4800 = 4800
#FT_BAUD_9600 = 9600
#FT_BAUD_14400 = 14400
#FT_BAUD_19200 = 19200
#FT_BAUD_38400 = 38400
#FT_BAUD_57600 = 57600
#FT_BAUD_115200 = 115200
#FT_BAUD_230400 = 230400
#FT_BAUD_460800 = 460800
#FT_BAUD_921600 = 921600

;
; Word Lengths
;
#FT_BITS_8 = 8
#FT_BITS_7 = 7

;
; Stop Bits
;
#FT_STOP_BITS_1  = 0
#FT_STOP_BITS_2  = 2

;
; Parity
;
#FT_PARITY_NONE  = 0
#FT_PARITY_ODD  = 1
#FT_PARITY_EVEN  = 2
#FT_PARITY_MARK  = 3
#FT_PARITY_SPACE  = 4

;
; Flow Control
;
#FT_FLOW_NONE = $0000
#FT_FLOW_RTS_CTS = $0100
#FT_FLOW_DTR_DSR = $0200
#FT_FLOW_XON_XOFF = $0400

;
; Purge rx and tx buffers
;
#FT_PURGE_RX =  1
#FT_PURGE_TX =  2

;
; Events
;
#FT_EVENT_RXCHAR =  1
#FT_EVENT_MODEM_STATUS = 2
#FT_EVENT_LINE_STATUS = 4

;
; Timeouts
;
#FT_DEFAULT_RX_TIMEOUT = 300
#FT_DEFAULT_TX_TIMEOUT = 300

;
; Device types
;
Enumeration
  #FT_DEVICE_BM
  #FT_DEVICE_AM
  #FT_DEVICE_100AX
  #FT_DEVICE_UNKNOWN
  #FT_DEVICE_2232C
  #FT_DEVICE_232R
  #FT_DEVICE_2232H
  #FT_DEVICE_4232H
  #FT_DEVICE_232H
EndEnumeration

;
; Bit Modes
;
#FT_BITMODE_RESET =   $00
#FT_BITMODE_ASYNC_BITBANG = $01
#FT_BITMODE_MPSSE =   $02
#FT_BITMODE_SYNC_BITBANG =  $04
#FT_BITMODE_MCU_HOST =   $08
#FT_BITMODE_FAST_SERIAL =  $10
#FT_BITMODE_CBUS_BITBANG =  $20
#FT_BITMODE_SYNC_FIFO =  $40

;
; FT232R CBUS Options EEPROM values
;
#FT_232R_CBUS_TXDEN =   $00 ; Tx Data Enable
#FT_232R_CBUS_PWRON =   $01 ; Power On
#FT_232R_CBUS_RXLED =   $02 ; Rx LED
#FT_232R_CBUS_TXLED =   $03 ; Tx LED
#FT_232R_CBUS_TXRXLED =  $04; Tx and Rx LED
#FT_232R_CBUS_SLEEP =   $05 ; Sleep
#FT_232R_CBUS_CLK48 =   $06 ; 48MHz clock
#FT_232R_CBUS_CLK24 =   $07 ; 24MHz clock
#FT_232R_CBUS_CLK12 =   $08 ; 12MHz clock
#FT_232R_CBUS_CLK6 =   $09  ; 6MHz clock
#FT_232R_CBUS_IOMODE =   $0A; IO Mode for CBUS bit-bang
#FT_232R_CBUS_BITBANG_WR =  $0B ; Bit-bang write strobe
#FT_232R_CBUS_BITBANG_RD =  $0C ; Bit-bang read strobe

;
; FT232H CBUS Options EEPROM values
;
#FT_232H_CBUS_TRISTATE =  $00 ; Tristate
#FT_232H_CBUS_RXLED =   $01   ; Rx LED
#FT_232H_CBUS_TXLED =   $02   ; Tx LED
#FT_232H_CBUS_TXRXLED =  $03  ; Tx and Rx LED
#FT_232H_CBUS_PWREN =   $04   ; Power Enable
#FT_232H_CBUS_SLEEP =   $05   ; Sleep
#FT_232H_CBUS_DRIVE_0 =  $06  ; Drive pin to logic 0
#FT_232H_CBUS_DRIVE_1 =  $07  ; Drive pin to logic 1
#FT_232H_CBUS_IOMODE =   $08  ; IO Mode for CBUS bit-bang
#FT_232H_CBUS_TXDEN =   $09   ; Tx Data Enable
#FT_232H_CBUS_CLK30 =   $0A   ; 30MHz clock
#FT_232H_CBUS_CLK15 =   $0B   ; 15MHz clock
#FT_232H_CBUS_CLK7_5 =   $0C  ; 7.5MHz clock

; WARNING!!!! DO NOT USE "IMPORT"
; "IMPORT" of the ftd2xx.lib file will cause scs11.exe to need to find ftd2xx.dll at run time, and the user probably will not have it!
Prototype.i PR_FT_Open(intDeviceNumber.l, *pHandle)
Prototype.i PR_FT_OpenEx(*pArg1, flags.l, *pHandle)
Prototype.i PR_FT_ListDevices(*pArg1, *pArg2, dwFlags.l)
Prototype.i PR_FT_Close(ftHandle.i)
Prototype.i PR_FT_Read(ftHandle.i, *lpBuffer, dwBytesToRead.l, *lpBytesReturned)
Prototype.i PR_FT_Write(ftHandle.i, *lpBuffer, dwBytesToWrite.l, *lpBytesWritten)
Prototype.i PR_FT_IoCtl(ftHandle.i, dwIoControlCode.l, *lpInBuf, nInBufSize.l, *lpOutBuf, nOutBufSize.l, *lpBytesReturned, *lpOverlapped)
Prototype.i PR_FT_SetBaudRate(ftHandle.i, dwBaudRate.l)
Prototype.i PR_FT_SetDivisor(ftHandle.i, wDivisor.w)
Prototype.i PR_FT_SetDataCharacteristics(ftHandle.i, byWordLength.b, byStopBits.b, byParity.b)
Prototype.i PR_FT_SetFlowControl(ftHandle.i, wFlowControl.w, byXonChar.b, byXoffChar.b)
Prototype.i PR_FT_ResetDevice(ftHandle.i)
Prototype.i PR_FT_SetDtr(ftHandle.i)
Prototype.i PR_FT_ClrDtr(ftHandle.i)
Prototype.i PR_FT_SetRts(ftHandle.i)
Prototype.i PR_FT_ClrRts(ftHandle.i)
Prototype.i PR_FT_GetModemStatus(ftHandle.i, *pModemStatus)
Prototype.i PR_FT_SetChars(ftHandle.i, byEventChar.b, byEventCharEnabled.b, byErrorChar.b, byErrorCharEnabled.b)
Prototype.i PR_FT_Purge(ftHandle.i, lngMask.l)
Prototype.i PR_FT_SetTimeouts(ftHandle.i, lngReadTimeout.l, lngWriteTimeout.l)
Prototype.i PR_FT_GetQueueStatus(ftHandle.i, *dwRxBytes)
Prototype.i PR_FT_SetEventNotification(ftHandle.i, dwMask.l, *pParam)
Prototype.i PR_FT_GetStatus(ftHandle.i, *dwRxBytes, *dwTxBytes, *dwEventDWord)
Prototype.i PR_FT_SetBreakOn(ftHandle.i)
Prototype.i PR_FT_SetBreakOff(ftHandle.i)
Prototype.i PR_FT_SetWaitMask(ftHandle.i, dwMask.l)
Prototype.i PR_FT_WaitOnMask(ftHandle.i, *dwMask)
Prototype.i PR_FT_GetEventStatus(ftHandle.i, *dwEventDWord)
Prototype.i PR_FT_ReadEE(ftHandle.i, dwWordOffset.l, *lpwValue)
Prototype.i PR_FT_WriteEE(ftHandle.i, dwWordOffset.l, wValue.w)
Prototype.i PR_FT_EraseEE(ftHandle.i)

;
; structure to hold program data for FT_Program function
;
Structure FT_PROGRAM_DATA
  
  signature1.l   ; Header - must be $00000000 
  signature2.l   ; Header - must be $ffffffff
  version.l      ; Header - FT_PROGRAM_DATA version
                 ;   0 = original
                 ;   1 = FT2232C extensions
                 ;   2 = FT232R extensions
                 ;   3 = FT2232H extensions
                 ;   4 = FT4232H extensions
                 ;   5 = FT232H extensions
  
  VendorId.w    ; $0403
  ProductId.w   ; $6001
                ; *Manufacturer.l   ; "FTDI"
                ; *ManufacturerId.l  ; "FT"
                ; *Description.l   ; "USB HS Serial Converter"
                ; *SerialNumber.l   ; "FT000001" if fixed, or NULL
                ; native types removed from pointers for PB 5.20 (01/10/2013)
  *Manufacturer ; "FTDI"
  *ManufacturerId  ; "FT"
  *Description     ; "USB HS Serial Converter"
  *SerialNumber    ; "FT000001" if fixed, or NULL
  MaxPower.w       ; 0 < MaxPower <= 500
  PnP.w            ; 0 = disabled, 1 = enabled
  SelfPowered.w    ; 0 = bus powered, 1 = self powered
  RemoteWakeup.w   ; 0 = not capable, 1 = capable
                   ;
                   ; Rev4 (FT232B) extensions
                   ;
  Rev4.b           ; non-zero if Rev4 chip, zero otherwise
  IsoIn.b          ; non-zero if in endpoint is isochronous
  IsoOut.b         ; non-zero if out endpoint is isochronous
  PullDownEnable.b ; non-zero if pull down enabled
  SerNumEnable.b   ; non-zero if serial number to be used
  USBVersionEnable.b  ; non-zero if chip uses USBVersion
  USBVersion.w        ; BCD ($0200 => USB2)
                      ;
                      ; Rev 5 (FT2232) extensions
                      ;
  Rev5.b              ; non-zero if Rev5 chip, zero otherwise
  IsoInA.b            ; non-zero if in endpoint is isochronous
  IsoInB.b            ; non-zero if in endpoint is isochronous
  IsoOutA.b           ; non-zero if out endpoint is isochronous
  IsoOutB.b           ; non-zero if out endpoint is isochronous
  PullDownEnable5.b   ; non-zero if pull down enabled
  SerNumEnable5.b     ; non-zero if serial number to be used
  USBVersionEnable5.b ; non-zero if chip uses USBVersion
  USBVersion5.w       ; BCD ($0200 => USB2)
  AIsHighCurrent.b    ; non-zero if interface is high current
  BIsHighCurrent.b    ; non-zero if interface is high current
  IFAIsFifo.b         ; non-zero if interface is 245 FIFO
  IFAIsFifoTar.b      ; non-zero if interface is 245 FIFO CPU target
  IFAIsFastSer.b      ; non-zero if interface is Fast serial
  AIsVCP.b            ; non-zero if interface is to use VCP drivers
  IFBIsFifo.b         ; non-zero if interface is 245 FIFO
  IFBIsFifoTar.b      ; non-zero if interface is 245 FIFO CPU target
  IFBIsFastSer.b      ; non-zero if interface is Fast serial
  BIsVCP.b            ; non-zero if interface is to use VCP drivers
                      ;
                      ; Rev 6 (FT232R) extensions
                      ;
  UseExtOSC.b         ; Use External Oscillator
  HighDriveIOs.b      ; High Drive I/Os
  EndPointSize.b      ; Endpoint size
  PullDownEnableR.b   ; non-zero if pull down enabled
  SerNumEnableR.b     ; non-zero if serial number to be used
  InvertTXD.b         ; non-zero if invert TXD
  InvertRXD.b         ; non-zero if invert RXD
  InvertRTS.b         ; non-zero if invert RTS
  InvertCTS.b         ; non-zero if invert CTS
  InvertDTR.b         ; non-zero if invert DTR
  InvertDSR.b         ; non-zero if invert DSR
  InvertDCD.b         ; non-zero if invert DCD
  InvertRI.b          ; non-zero if invert RI
  Cbus0.b             ; Cbus Mux control
  Cbus1.b             ; Cbus Mux control
  Cbus2.b             ; Cbus Mux control
  Cbus3.b             ; Cbus Mux control
  Cbus4.b             ; Cbus Mux control
  RIsD2XX.b           ; non-zero if using D2XX driver
                      ;
                      ; Rev 7 (FT2232H) Extensions
                      ;
  PullDownEnable7.b   ; non-zero if pull down enabled
  SerNumEnable7.b     ; non-zero if serial number to be used
  ALSlowSlew.b        ; non-zero if AL pins have slow slew
  ALSchmittInput.b    ; non-zero if AL pins are Schmitt input
  ALDriveCurrent.b    ; valid values are 4mA, 8mA, 12mA, 16mA
  AHSlowSlew.b        ; non-zero if AH pins have slow slew
  AHSchmittInput.b    ; non-zero if AH pins are Schmitt input
  AHDriveCurrent.b    ; valid values are 4mA, 8mA, 12mA, 16mA
  BLSlowSlew.b        ; non-zero if BL pins have slow slew
  BLSchmittInput.b    ; non-zero if BL pins are Schmitt input
  BLDriveCurrent.b    ; valid values are 4mA, 8mA, 12mA, 16mA
  BHSlowSlew.b        ; non-zero if BH pins have slow slew
  BHSchmittInput.b    ; non-zero if BH pins are Schmitt input
  BHDriveCurrent.b    ; valid values are 4mA, 8mA, 12mA, 16mA
  IFAIsFifo7.b        ; non-zero if interface is 245 FIFO
  IFAIsFifoTar7.b     ; non-zero if interface is 245 FIFO CPU target
  IFAIsFastSer7.b     ; non-zero if interface is Fast serial
  AIsVCP7.b           ; non-zero if interface is to use VCP drivers
  IFBIsFifo7.b        ; non-zero if interface is 245 FIFO
  IFBIsFifoTar7.b     ; non-zero if interface is 245 FIFO CPU target
  IFBIsFastSer7.b     ; non-zero if interface is Fast serial
  BIsVCP7.b           ; non-zero if interface is to use VCP drivers
  PowerSaveEnable.b   ; non-zero if using BCBUS7 to save power for self-powered designs
                      ;
                      ; Rev 8 (FT4232H) Extensions
                      ;
  PullDownEnable8.b   ; non-zero if pull down enabled
  SerNumEnable8.b     ; non-zero if serial number to be used
  ASlowSlew.b         ; non-zero if AL pins have slow slew
  ASchmittInput.b     ; non-zero if AL pins are Schmitt input
  ADriveCurrent.b     ; valid values are 4mA, 8mA, 12mA, 16mA
  BSlowSlew.b         ; non-zero if AH pins have slow slew
  BSchmittInput.b     ; non-zero if AH pins are Schmitt input
  BDriveCurrent.b     ; valid values are 4mA, 8mA, 12mA, 16mA
  CSlowSlew.b         ; non-zero if BL pins have slow slew
  CSchmittInput.b     ; non-zero if BL pins are Schmitt input
  CDriveCurrent.b     ; valid values are 4mA, 8mA, 12mA, 16mA
  DSlowSlew.b         ; non-zero if BH pins have slow slew
  DSchmittInput.b     ; non-zero if BH pins are Schmitt input
  DDriveCurrent.b     ; valid values are 4mA, 8mA, 12mA, 16mA
  ARIIsTXDEN.b        ; non-zero if port A uses RI as RS485 TXDEN
  BRIIsTXDEN.b        ; non-zero if port B uses RI as RS485 TXDEN
  CRIIsTXDEN.b        ; non-zero if port C uses RI as RS485 TXDEN
  DRIIsTXDEN.b        ; non-zero if port D uses RI as RS485 TXDEN
  AIsVCP8.b           ; non-zero if interface is to use VCP drivers
  BIsVCP8.b           ; non-zero if interface is to use VCP drivers
  CIsVCP8.b           ; non-zero if interface is to use VCP drivers
  DIsVCP8.b           ; non-zero if interface is to use VCP drivers
                      ;
                      ; Rev 9 (FT232H) Extensions
                      ;
  PullDownEnableH.b   ; non-zero if pull down enabled
  SerNumEnableH.b     ; non-zero if serial number to be used
  ACSlowSlewH.b       ; non-zero if AC pins have slow slew
  ACSchmittInputH.b   ; non-zero if AC pins are Schmitt input
  ACDriveCurrentH.b   ; valid values are 4mA, 8mA, 12mA, 16mA
  ADSlowSlewH.b       ; non-zero if AD pins have slow slew
  ADSchmittInputH.b   ; non-zero if AD pins are Schmitt input
  ADDriveCurrentH.b   ; valid values are 4mA, 8mA, 12mA, 16mA
  Cbus0H.b            ; Cbus Mux control
  Cbus1H.b            ; Cbus Mux control
  Cbus2H.b            ; Cbus Mux control
  Cbus3H.b            ; Cbus Mux control
  Cbus4H.b            ; Cbus Mux control
  Cbus5H.b            ; Cbus Mux control
  Cbus6H.b            ; Cbus Mux control
  Cbus7H.b            ; Cbus Mux control
  Cbus8H.b            ; Cbus Mux control
  Cbus9H.b            ; Cbus Mux control
  IsFifoH.b           ; non-zero if interface is 245 FIFO
  IsFifoTarH.b        ; non-zero if interface is 245 FIFO CPU target
  IsFastSerH.b        ; non-zero if interface is Fast serial
  IsFT1248H.b         ; non-zero if interface is FT1248
  FT1248CpolH.b       ; FT1248 clock polarity - clock idle high (1) or clock idle low (0)
  FT1248LsbH.b        ; FT1248 data is LSB (1) or MSB (0)
  FT1248FlowControlH.b; FT1248 flow control enable
  IsVCPH.b            ; non-zero if interface is to use VCP drivers
  PowerSaveEnableH.b  ; non-zero if using ACBUS7 to save power for self-powered designs
  
EndStructure

Prototype.i PR_FT_EE_Program(ftHandle.i, *pData.FT_PROGRAM_DATA)
Prototype.i PR_FT_EE_ProgramEx(ftHandle.i, *pData.FT_PROGRAM_DATA, *Manufacturer, *ManufacturerId, *Description, *SerialNumber)
Prototype.i PR_FT_EE_Read(ftHandle.i, *pData.FT_PROGRAM_DATA)
Prototype.i PR_FT_EE_ReadEx(ftHandle.i, *pData.FT_PROGRAM_DATA, *Manufacturer, *ManufacturerId, *Description, *SerialNumber)
; Prototype.i PR_FT_EE_UASize(ftHandle.i, *lpdwSize.l)
Prototype.i PR_FT_EE_UASize(ftHandle.i, *lpdwSize)
Prototype.i PR_FT_EE_UAWrite(ftHandle.i, *pucData, dwDataLen.l)
; Prototype.i PR_FT_EE_UARead(ftHandle.i, *pucData, dwDataLen.l, *lpdwBytesRead.l)
Prototype.i PR_FT_EE_UARead(ftHandle.i, *pucData, dwDataLen.l, *lpdwBytesRead)
Prototype.i PR_FT_SetLatencyTimer(ftHandle.i, ucLatency.b)
Prototype.i PR_FT_GetLatencyTimer(ftHandle.i, *pucLatency)
Prototype.i PR_FT_SetBitMode(ftHandle.i, ucMask.b, ucEnable.b)
; Prototype.i PR_FT_GetBitMode(ftHandle.i, *pucMode.l)
Prototype.i PR_FT_GetBitMode(ftHandle.i, *pucMode)
Prototype.i PR_FT_SetUSBParameters(ftHandle.i, ulInTransferSize.l, ulOutTransferSize.l)
Prototype.i PR_FT_SetDeadmanTimeout(ftHandle.i, ulDeadmanTimeout.l)
Prototype.i PR_FT_GetDeviceInfo(ftHandle.i, *lpftDevice, *lpdwID, *SerialNumber, *Description, *Dummy)
Prototype.i PR_FT_StopInTask(ftHandle.i)
Prototype.i PR_FT_RestartInTask(ftHandle.i)
Prototype.i PR_FT_SetResetPipeRetryCount(ftHandle.i, dwCount.l)
Prototype.i PR_FT_ResetPort(ftHandle.i)
Prototype.i PR_FT_CyclePort(ftHandle.i)

;
; Win32-type functions
;
Structure LPSECURITY_ATTRIBUTES
  nLength.l
  lpSecurityDescriptor.l
  bInheritHandle.i
EndStructure

Structure lpOverlapped
  Internal.l
  InternalHigh.l
  offset.l
  OffsetHigh.l
  hEvent.l
EndStructure

; Prototype.i PR_FT_W32_CreateFile(*lpszName, dwAccess.l, dwShareMode.l, *lpSecurityAttributes.LPSECURITY_ATTRIBUTES, dwCreate.l, dwAttrsAndFlags.l, hTemplate.l)
; Prototype.i PR_FT_W32_CloseHandle(ftHandle.i)
; Prototype.i PR_FT_W32_ReadFile(ftHandle.i, *lpBuffer, nBufferSize.l, *lpBytesReturned.l, *lpOverlapped.lpOverlapped)
; Prototype.i PR_FT_W32_WriteFile(ftHandle.i, *lpBuffer, nBufferSize.l, *lpBytesWritten.l, *lpOverlapped.lpOverlapped)
; Prototype.i PR_FT_W32_GetLastError(ftHandle.i)
; Prototype.i PR_FT_W32_GetOverlappedResult(ftHandle.i, *lpOverlapped, *lpdwBytesTransferred.l, bWait.l)
; Prototype.i PR_FT_W32_CancelIo(ftHandle.i)
Prototype.i PR_FT_W32_CreateFile(*lpszName, dwAccess.l, dwShareMode.l, *lpSecurityAttributes.LPSECURITY_ATTRIBUTES, dwCreate.l, dwAttrsAndFlags.l, hTemplate.l)
Prototype.i PR_FT_W32_CloseHandle(ftHandle.i)
Prototype.i PR_FT_W32_ReadFile(ftHandle.i, *lpBuffer, nBufferSize.l, *lpBytesReturned, *lpOverlapped.lpOverlapped)
Prototype.i PR_FT_W32_WriteFile(ftHandle.i, *lpBuffer, nBufferSize.l, *lpBytesWritten, *lpOverlapped.lpOverlapped)
Prototype.i PR_FT_W32_GetLastError(ftHandle.i)
Prototype.i PR_FT_W32_GetOverlappedResult(ftHandle.i, *lpOverlapped, *lpdwBytesTransferred, bWait.l)
Prototype.i PR_FT_W32_CancelIo(ftHandle.i)

;
; Win32 COMM API type functions
;
; FTCOMSTAT abd FTDCB commented out because they contain bit fields (eg : 1)
; Structure FTCOMSTAT
; fCtsHold.l : 1
; fDsrHold.l : 1
; fRlsdHold.l : 1
; fXoffHold.l : 1
; fXoffSent.l : 1
; fEof.l : 1
; fTxim.l : 1
; fReserved.l : 25
; cbInQue.l
; cbOutQue.l
; EndStructure
; 
; Structure FTDCB
; DCBlength.l   ; sizeof(FTDCB)     
; BaudRate.l    ; Baudrate at which running  
; fBinary.l : 1   ; Binary Mode (skip EOF check)  
; fParity.l : 1   ; Enable parity checking   
; fOutxCtsFlow.l : 1  ; CTS handshaking on output  
; fOutxDsrFlow.l : 1  ; DSR handshaking on output  
; fDtrControl.l : 2  ; DTR Flow control     
; fDsrSensitivity.l : 1; ; DSR Sensitivity     
; fTXContinueOnXoff.l : 1; ; Continue TX when Xoff sent  
; fOutX.l : 1    ; Enable output X-ON/X-OFF   
; fInX.l : 1    ; Enable input X-ON/X-OFF   
; fErrorChar.l : 1  ; Enable Err Replacement   
; fNull.l : 1    ; Enable Null stripping   
; fRtsControl.l : 2  ; Rts Flow control     
; fAbortOnError.l : 1  ; Abort all reads and writes on Error
; fDummy2.l : 17   ; Reserved       
; wReserved.w    ; Not currently used    
; XonLim.w    ; Transmit X-ON threshold   
; XoffLim.w    ; Transmit X-OFF threshold   
; ByteSize.b    ; Number of bits/byte, 4-8   
; Parity.b    ; 0-4:None,Odd,Even,Mark,Space  
; StopBits.b    ; 0,1,2 : 1, 1.5, 2    
; XonChar.b    ; Tx and Rx X-ON character   
; XoffChar.b    ; Tx and Rx X-OFF character  
; ErrorChar.b    ; Error replacement   
; EofChar.b    ; End of Input character   
; EvtChar.b    ; Received Event character   
; wReserved1.w   ; Fill for now.     
; EndStructure

Structure FTTIMEOUTS
  ReadIntervalTimeout.l   ; Maximum time between read chars.
  ReadTotalTimeoutMultiplier.l ; Multiplier of characters. 
  ReadTotalTimeoutConstant.l   ; Constant in milliseconds. 
  WriteTotalTimeoutMultiplier.l; Multiplier of characters. 
  WriteTotalTimeoutConstant.l  ; Constant in milliseconds. 
EndStructure

Prototype.i PR_FT_W32_ClearCommBreak(ftHandle.i)
; Prototype.i PR_FT_W32_ClearCommError(ftHandle.i, *lpdwErrors, *LPFTCOMSTAT.LPFTCOMSTAT)
Prototype.i PR_FT_W32_EscapeCommFunction(ftHandle.i, dwFunc.l)
Prototype.i PR_FT_W32_GetCommModemStatus(ftHandle.i, *lpdwModemStatus)
; Prototype.i PR_FT_W32_GetCommState(ftHandle.i, *lpftDCB.FTDCB)
Prototype.i PR_FT_W32_GetCommTimeouts(ftHandle.i, *pTimeouts.FTTIMEOUTS)
Prototype.i PR_FT_W32_PurgeComm(ftHandle.i, dwMask.l)
Prototype.i PR_FT_W32_SetCommBreak(ftHandle.i)
Prototype.i PR_FT_W32_SetCommMask(ftHandle.i, ulEventMask.l)
Prototype.i PR_FT_W32_GetCommMask(ftHandle.i, *lpdwEventMask)
; Prototype.i PR_FT_W32_SetCommState(ftHandle.i, *lpftDCB.FTDCB)
Prototype.i PR_FT_W32_SetCommTimeouts(ftHandle.i, *pTimeouts.FTTIMEOUTS)
Prototype.i PR_FT_W32_SetupComm(ftHandle.i, dwReadBufferSize.l, dwWriteBufferSize.l)
; Prototype.i PR_FT_W32_WaitCommEvent(ftHandle.i, *pulEvent.l, *lpOverlapped.lpOverlapped)
Prototype.i PR_FT_W32_WaitCommEvent(ftHandle.i, *pulEvent, *lpOverlapped.lpOverlapped)

;
; Device information
;

Structure FT_DEVICE_LIST_INFO_NODE
  flags.l
  type.l
  ID.l
  LocId.l
  SerialNumber.s{16}
  Description.s{64}
  ftHandle.i
EndStructure

; Device information flags
Enumeration
  #FT_FLAGS_OPENED = 1
  #FT_FLAGS_HISPEED = 2
EndEnumeration

Prototype.i PR_FT_CreateDeviceInfoList(*lpdwNumDevs)
Prototype.i PR_FT_GetDeviceInfoList(*pDest.FT_DEVICE_LIST_INFO_NODE, *lpdwNumDevs)
Prototype.i PR_FT_GetDeviceInfoDetail(dwIndex.l, *lpdwFlags, *lpdwType, *lpdwID, *lpdwLocId, *lpSerialNumber, *lpDescription, *pftHandle)

;
; Version information
;
Prototype.i PR_FT_GetDriverVersion(ftHandle.i, *lpdwVersion)
Prototype.i PR_FT_GetLibraryVersion(*lpdwVersion)
Prototype.i PR_FT_Rescan()
Prototype.i PR_FT_Reload(wVid.w, wPid.w)
Prototype.i PR_FT_GetComPortNumber(ftHandle.i, *lpdwComPortNumber)

;
; FT232H additional EEPROM functions
;
; Prototype.i PR_FT_EE_ReadConfig(ftHandle.i, ucAddress.b, *pucValue.b)
Prototype.i PR_FT_EE_ReadConfig(ftHandle.i, ucAddress.b, *pucValue)
Prototype.i PR_FT_EE_WriteConfig(ftHandle.i, ucAddress.b, ucValue.b)
Prototype.i PR_FT_EE_ReadECC(ftHandle.i, ucOption.b, *lpwValue)
Prototype.i PR_FT_GetQueueStatusEx(ftHandle.i, *dwRxBytes)

;- Globals
Global FT_Open.PR_FT_Open
Global FT_OpenEx.PR_FT_OpenEx
Global FT_ListDevices.PR_FT_ListDevices
Global FT_Close.PR_FT_Close
Global FT_Read.PR_FT_Read
Global FT_Write.PR_FT_Write
Global FT_IoCtl.PR_FT_IoCtl
Global FT_SetBaudRate.PR_FT_SetBaudRate
Global FT_SetDivisor.PR_FT_SetDivisor
Global FT_SetDataCharacteristics.PR_FT_SetDataCharacteristics
Global FT_SetFlowControl.PR_FT_SetFlowControl
Global FT_ResetDevice.PR_FT_ResetDevice
Global FT_SetDtr.PR_FT_SetDtr
Global FT_ClrDtr.PR_FT_ClrDtr
Global FT_SetRts.PR_FT_SetRts
Global FT_ClrRts.PR_FT_ClrRts
Global FT_GetModemStatus.PR_FT_GetModemStatus
Global FT_SetChars.PR_FT_SetChars
Global FT_Purge.PR_FT_Purge
Global FT_SetTimeouts.PR_FT_SetTimeouts
Global FT_GetQueueStatus.PR_FT_GetQueueStatus
Global FT_SetEventNotification.PR_FT_SetEventNotification
Global FT_GetStatus.PR_FT_GetStatus
Global FT_SetBreakOn.PR_FT_SetBreakOn
Global FT_SetBreakOff.PR_FT_SetBreakOff
Global FT_SetWaitMask.PR_FT_SetWaitMask
Global FT_WaitOnMask.PR_FT_WaitOnMask
Global FT_GetEventStatus.PR_FT_GetEventStatus
Global FT_ReadEE.PR_FT_ReadEE
Global FT_WriteEE.PR_FT_WriteEE
Global FT_EraseEE.PR_FT_EraseEE
Global FT_EE_Program.PR_FT_EE_Program
Global FT_EE_ProgramEx.PR_FT_EE_ProgramEx
Global FT_EE_Read.PR_FT_EE_Read
Global FT_EE_ReadEx.PR_FT_EE_ReadEx
Global FT_EE_UASize.PR_FT_EE_UASize
Global FT_EE_UAWrite.PR_FT_EE_UAWrite
Global FT_EE_UARead.PR_FT_EE_UARead
Global FT_SetLatencyTimer.PR_FT_SetLatencyTimer
Global FT_GetLatencyTimer.PR_FT_GetLatencyTimer
Global FT_SetBitMode.PR_FT_SetBitMode
Global FT_GetBitMode.PR_FT_GetBitMode
Global FT_SetUSBParameters.PR_FT_SetUSBParameters
Global FT_SetDeadmanTimeout.PR_FT_SetDeadmanTimeout
Global FT_GetDeviceInfo.PR_FT_GetDeviceInfo
Global FT_StopInTask.PR_FT_StopInTask
Global FT_RestartInTask.PR_FT_RestartInTask
Global FT_SetResetPipeRetryCount.PR_FT_SetResetPipeRetryCount
Global FT_ResetPort.PR_FT_ResetPort
Global FT_CyclePort.PR_FT_CyclePort
Global FT_W32_CreateFile.PR_FT_W32_CreateFile
Global FT_W32_CloseHandle.PR_FT_W32_CloseHandle
Global FT_W32_ReadFile.PR_FT_W32_ReadFile
Global FT_W32_WriteFile.PR_FT_W32_WriteFile
Global FT_W32_GetLastError.PR_FT_W32_GetLastError
Global FT_W32_GetOverlappedResult.PR_FT_W32_GetOverlappedResult
Global FT_W32_CancelIo.PR_FT_W32_CancelIo
Global FT_W32_ClearCommBreak.PR_FT_W32_ClearCommBreak
; Global FT_W32_ClearCommError.PR_FT_W32_ClearCommError
Global FT_W32_EscapeCommFunction.PR_FT_W32_EscapeCommFunction
Global FT_W32_GetCommModemStatus.PR_FT_W32_GetCommModemStatus
; Global FT_W32_GetCommState.PR_FT_W32_GetCommState
Global FT_W32_GetCommTimeouts.PR_FT_W32_GetCommTimeouts
Global FT_W32_PurgeComm.PR_FT_W32_PurgeComm
Global FT_W32_SetCommBreak.PR_FT_W32_SetCommBreak
Global FT_W32_SetCommMask.PR_FT_W32_SetCommMask
Global FT_W32_GetCommMask.PR_FT_W32_GetCommMask
; Global FT_W32_SetCommState.PR_FT_W32_SetCommState
Global FT_W32_SetCommTimeouts.PR_FT_W32_SetCommTimeouts
Global FT_W32_SetupComm.PR_FT_W32_SetupComm
Global FT_W32_WaitCommEvent.PR_FT_W32_WaitCommEvent
Global FT_CreateDeviceInfoList.PR_FT_CreateDeviceInfoList
Global FT_GetDeviceInfoList.PR_FT_GetDeviceInfoList
Global FT_GetDeviceInfoDetail.PR_FT_GetDeviceInfoDetail
Global FT_GetDriverVersion.PR_FT_GetDriverVersion
Global FT_GetLibraryVersion.PR_FT_GetLibraryVersion
Global FT_Rescan.PR_FT_Rescan
Global FT_Reload.PR_FT_Reload
Global FT_GetComPortNumber.PR_FT_GetComPortNumber
Global FT_EE_ReadConfig.PR_FT_EE_ReadConfig
Global FT_EE_WriteConfig.PR_FT_EE_WriteConfig
Global FT_EE_ReadECC.PR_FT_EE_ReadECC
Global FT_GetQueueStatusEx.PR_FT_GetQueueStatusEx

Procedure checkFTD2XXAvailable()
  Protected sLibName.s
  Protected bResult, nLibrary.i
  
  CompilerIf #c_simulate_ftd2xx_unavailable
    ProcedureReturn #False
  CompilerEndIf
  
  If gnFTD2XXLibraryNo
    ProcedureReturn gbFTD2XXAvailable
  EndIf
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    sLibName.s = "ftd2xxX64.dll"
  CompilerElse
    sLibName.s = "ftd2xx.dll"
  CompilerEndIf
  
  nLibrary = OpenLibrary(#PB_Any, sLibName)
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    If nLibrary = 0
      sLibName.s = "ftd2xx.dll"
      nLibrary = OpenLibrary(#PB_Any, sLibName)
    EndIf
  CompilerEndIf
  
  If nLibrary
    ; nb library must stay open until end of run or functions will fail
    gnFTD2XXLibraryNo = nLibrary
    bResult = #True
    
    FT_Open.PR_FT_Open = GetFunction(nLibrary, "FT_Open")
    FT_OpenEx.PR_FT_OpenEx = GetFunction(nLibrary, "FT_OpenEx")
    FT_ListDevices.PR_FT_ListDevices = GetFunction(nLibrary, "FT_ListDevices")
    Debug "FT_ListDevices=" + Str(FT_ListDevices)
    FT_Close.PR_FT_Close = GetFunction(nLibrary, "FT_Close")
    FT_Read.PR_FT_Read = GetFunction(nLibrary, "FT_Read")
    FT_Write.PR_FT_Write = GetFunction(nLibrary, "FT_Write")
    FT_IoCtl.PR_FT_IoCtl = GetFunction(nLibrary, "FT_IoCtl")
    FT_SetBaudRate.PR_FT_SetBaudRate = GetFunction(nLibrary, "FT_SetBaudRate")
    FT_SetDivisor.PR_FT_SetDivisor = GetFunction(nLibrary, "FT_SetDivisor")
    FT_SetDataCharacteristics.PR_FT_SetDataCharacteristics = GetFunction(nLibrary, "FT_SetDataCharacteristics")
    FT_SetFlowControl.PR_FT_SetFlowControl = GetFunction(nLibrary, "FT_SetFlowControl")
    FT_ResetDevice.PR_FT_ResetDevice = GetFunction(nLibrary, "FT_ResetDevice")
    FT_SetDtr.PR_FT_SetDtr = GetFunction(nLibrary, "FT_SetDtr")
    FT_ClrDtr.PR_FT_ClrDtr = GetFunction(nLibrary, "FT_ClrDtr")
    FT_SetRts.PR_FT_SetRts = GetFunction(nLibrary, "FT_SetRts")
    FT_ClrRts.PR_FT_ClrRts = GetFunction(nLibrary, "FT_ClrRts")
    FT_GetModemStatus.PR_FT_GetModemStatus = GetFunction(nLibrary, "FT_GetModemStatus")
    FT_SetChars.PR_FT_SetChars = GetFunction(nLibrary, "FT_SetChars")
    FT_Purge.PR_FT_Purge = GetFunction(nLibrary, "FT_Purge")
    FT_SetTimeouts.PR_FT_SetTimeouts = GetFunction(nLibrary, "FT_SetTimeouts")
    FT_GetQueueStatus.PR_FT_GetQueueStatus = GetFunction(nLibrary, "FT_GetQueueStatus")
    FT_SetEventNotification.PR_FT_SetEventNotification = GetFunction(nLibrary, "FT_SetEventNotification")
    FT_GetStatus.PR_FT_GetStatus = GetFunction(nLibrary, "FT_GetStatus")
    FT_SetBreakOn.PR_FT_SetBreakOn = GetFunction(nLibrary, "FT_SetBreakOn")
    FT_SetBreakOff.PR_FT_SetBreakOff = GetFunction(nLibrary, "FT_SetBreakOff")
    FT_SetWaitMask.PR_FT_SetWaitMask = GetFunction(nLibrary, "FT_SetWaitMask")
    FT_WaitOnMask.PR_FT_WaitOnMask = GetFunction(nLibrary, "FT_WaitOnMask")
    FT_GetEventStatus.PR_FT_GetEventStatus = GetFunction(nLibrary, "FT_GetEventStatus")
    FT_ReadEE.PR_FT_ReadEE = GetFunction(nLibrary, "FT_ReadEE")
    FT_WriteEE.PR_FT_WriteEE = GetFunction(nLibrary, "FT_WriteEE")
    FT_EraseEE.PR_FT_EraseEE = GetFunction(nLibrary, "FT_EraseEE")
    FT_EE_Program.PR_FT_EE_Program = GetFunction(nLibrary, "FT_EE_Program")
    FT_EE_ProgramEx.PR_FT_EE_ProgramEx = GetFunction(nLibrary, "FT_EE_ProgramEx")
    FT_EE_Read.PR_FT_EE_Read = GetFunction(nLibrary, "FT_EE_Read")
    FT_EE_ReadEx.PR_FT_EE_ReadEx = GetFunction(nLibrary, "FT_EE_ReadEx")
    FT_EE_UASize.PR_FT_EE_UASize = GetFunction(nLibrary, "FT_EE_UASize")
    FT_EE_UAWrite.PR_FT_EE_UAWrite = GetFunction(nLibrary, "FT_EE_UAWrite")
    FT_EE_UARead.PR_FT_EE_UARead = GetFunction(nLibrary, "FT_EE_UARead")
    FT_SetLatencyTimer.PR_FT_SetLatencyTimer = GetFunction(nLibrary, "FT_SetLatencyTimer")
    FT_GetLatencyTimer.PR_FT_GetLatencyTimer = GetFunction(nLibrary, "FT_GetLatencyTimer")
    FT_SetBitMode.PR_FT_SetBitMode = GetFunction(nLibrary, "FT_SetBitMode")
    FT_GetBitMode.PR_FT_GetBitMode = GetFunction(nLibrary, "FT_GetBitMode")
    FT_SetUSBParameters.PR_FT_SetUSBParameters = GetFunction(nLibrary, "FT_SetUSBParameters")
    FT_SetDeadmanTimeout.PR_FT_SetDeadmanTimeout = GetFunction(nLibrary, "FT_SetDeadmanTimeout")
    FT_GetDeviceInfo.PR_FT_GetDeviceInfo = GetFunction(nLibrary, "FT_GetDeviceInfo")
    FT_StopInTask.PR_FT_StopInTask = GetFunction(nLibrary, "FT_StopInTask")
    FT_RestartInTask.PR_FT_RestartInTask = GetFunction(nLibrary, "FT_RestartInTask")
    FT_SetResetPipeRetryCount.PR_FT_SetResetPipeRetryCount = GetFunction(nLibrary, "FT_SetResetPipeRetryCount")
    FT_ResetPort.PR_FT_ResetPort = GetFunction(nLibrary, "FT_ResetPort")
    FT_CyclePort.PR_FT_CyclePort = GetFunction(nLibrary, "FT_CyclePort")
    FT_W32_CreateFile.PR_FT_W32_CreateFile = GetFunction(nLibrary, "FT_W32_CreateFile")
    FT_W32_CloseHandle.PR_FT_W32_CloseHandle = GetFunction(nLibrary, "FT_W32_CloseHandle")
    FT_W32_ReadFile.PR_FT_W32_ReadFile = GetFunction(nLibrary, "FT_W32_ReadFile")
    FT_W32_WriteFile.PR_FT_W32_WriteFile = GetFunction(nLibrary, "FT_W32_WriteFile")
    FT_W32_GetLastError.PR_FT_W32_GetLastError = GetFunction(nLibrary, "FT_W32_GetLastError")
    FT_W32_GetOverlappedResult.PR_FT_W32_GetOverlappedResult = GetFunction(nLibrary, "FT_W32_GetOverlappedResult")
    FT_W32_CancelIo.PR_FT_W32_CancelIo = GetFunction(nLibrary, "FT_W32_CancelIo")
    FT_W32_ClearCommBreak.PR_FT_W32_ClearCommBreak = GetFunction(nLibrary, "FT_W32_ClearCommBreak")
    ; FT_W32_ClearCommError.PR_FT_W32_ClearCommError = GetFunction(nLibrary, "FT_W32_ClearCommError")
    FT_W32_EscapeCommFunction.PR_FT_W32_EscapeCommFunction = GetFunction(nLibrary, "FT_W32_EscapeCommFunction")
    FT_W32_GetCommModemStatus.PR_FT_W32_GetCommModemStatus = GetFunction(nLibrary, "FT_W32_GetCommModemStatus")
    ; FT_W32_GetCommState.PR_FT_W32_GetCommState = GetFunction(nLibrary, "FT_W32_GetCommState")
    FT_W32_GetCommTimeouts.PR_FT_W32_GetCommTimeouts = GetFunction(nLibrary, "FT_W32_GetCommTimeouts")
    FT_W32_PurgeComm.PR_FT_W32_PurgeComm = GetFunction(nLibrary, "FT_W32_PurgeComm")
    FT_W32_SetCommBreak.PR_FT_W32_SetCommBreak = GetFunction(nLibrary, "FT_W32_SetCommBreak")
    FT_W32_SetCommMask.PR_FT_W32_SetCommMask = GetFunction(nLibrary, "FT_W32_SetCommMask")
    FT_W32_GetCommMask.PR_FT_W32_GetCommMask = GetFunction(nLibrary, "FT_W32_GetCommMask")
    ; FT_W32_SetCommState.PR_FT_W32_SetCommState = GetFunction(nLibrary, "FT_W32_SetCommState")
    FT_W32_SetCommTimeouts.PR_FT_W32_SetCommTimeouts = GetFunction(nLibrary, "FT_W32_SetCommTimeouts")
    FT_W32_SetupComm.PR_FT_W32_SetupComm = GetFunction(nLibrary, "FT_W32_SetupComm")
    FT_W32_WaitCommEvent.PR_FT_W32_WaitCommEvent = GetFunction(nLibrary, "FT_W32_WaitCommEvent")
    FT_CreateDeviceInfoList.PR_FT_CreateDeviceInfoList = GetFunction(nLibrary, "FT_CreateDeviceInfoList")
    FT_GetDeviceInfoList.PR_FT_GetDeviceInfoList = GetFunction(nLibrary, "FT_GetDeviceInfoList")
    FT_GetDeviceInfoDetail.PR_FT_GetDeviceInfoDetail = GetFunction(nLibrary, "FT_GetDeviceInfoDetail")
    FT_GetDriverVersion.PR_FT_GetDriverVersion = GetFunction(nLibrary, "FT_GetDriverVersion")
    FT_GetLibraryVersion.PR_FT_GetLibraryVersion = GetFunction(nLibrary, "FT_GetLibraryVersion")
    FT_Rescan.PR_FT_Rescan = GetFunction(nLibrary, "FT_Rescan")
    FT_Reload.PR_FT_Reload = GetFunction(nLibrary, "FT_Reload")
    FT_GetComPortNumber.PR_FT_GetComPortNumber = GetFunction(nLibrary, "FT_GetComPortNumber")
    FT_EE_ReadConfig.PR_FT_EE_ReadConfig = GetFunction(nLibrary, "FT_EE_ReadConfig")
    FT_EE_WriteConfig.PR_FT_EE_WriteConfig = GetFunction(nLibrary, "FT_EE_WriteConfig")
    FT_EE_ReadECC.PR_FT_EE_ReadECC = GetFunction(nLibrary, "FT_EE_ReadECC")
    FT_GetQueueStatusEx.PR_FT_GetQueueStatusEx = GetFunction(nLibrary, "FT_GetQueueStatusEx")
    
  EndIf
  
  ; Debug "(b) " + Str(scsMilliseconds()) + ", bResult=" + StrB(bResult)
  ProcedureReturn bResult
  
EndProcedure

; unconditional procedure call - executed during program load
Debug "calling checkFTD2XXAvailable()"
gbFTD2XXAvailable = checkFTD2XXAvailable()
Debug "gbFTD2XXAvailable=" + strB(gbFTD2XXAvailable)

; EOF