;	BASSASIO 1.4 C/C++ header file
; Copyright (c) 2005-2023 Un4seen Developments Ltd.

#BASSASIOVERSION = $104   ; API version

; error codes returned by BASS_ASIO_ErrorGetCode
#BASS_OK	= 0               ; all is OK
#BASS_ERROR_FILEOPEN = 2    ; can't open the file
#BASS_ERROR_DRIVER	= 3     ; can't find a free/valid driver
#BASS_ERROR_HANDLE	= 5     ; invalid handle
#BASS_ERROR_FORMAT	= 6     ; unsupported sample format
#BASS_ERROR_INIT	= 8       ; BASS_ASIO_Init has Not been successfully called
#BASS_ERROR_START	= 9       ; BASS_ASIO_Start has/hasn't been called
#BASS_ERROR_ALREADY	= 14    ; already initialized/started
#BASS_ERROR_NOCHAN	= 18    ; no channels are enabled
#BASS_ERROR_ILLPARAM	= 20  ; an illegal parameter was specified
#BASS_ERROR_DEVICE	= 23    ; illegal device number
#BASS_ERROR_NOTAVAIL	= 37  ; not available
#BASS_ERROR_UNKNOWN = -1    ; some other mystery error

; BASS_ASIO_Init flags
#BASS_ASIO_THREAD = 1       ; host driver in dedicated thread
#BASS_ASIO_JOINORDER = 2    ; order joined channels by when they were joined

; device info Structure
Structure BASS_ASIO_DEVICEINFO
  *name     ; description
  *driver   ; driver
EndStructure

Structure BASS_ASIO_INFO
  name.a[32]    ; driver name
  version.l     ; driver version
  inputs.l      ; number of inputs
  outputs.l     ; number of outputs
  bufmin.l      ; minimum buffer length
  bufmax.l      ; maximum buffer length
  bufpref.l     ; preferred/default buffer length
  bufgran.l     ; buffer length granularity
  initflags.l   ; BASS_ASIO_Init "flags" parameter
EndStructure

Structure BASS_ASIO_CHANNELINFO
  group.l
  format.l      ;  sample format (BASS_ASIO_FORMAT_xxx)
  name.a[32]    ; channel name
EndStructure

; sample formats
#BASS_ASIO_FORMAT_16BIT	= 16  ; 16-bit integer
#BASS_ASIO_FORMAT_24BIT = 17  ; 24-bit integer
#BASS_ASIO_FORMAT_32BIT = 18  ; 32-bit integer
#BASS_ASIO_FORMAT_FLOAT = 19  ; 32-bit floating-point
#BASS_ASIO_FORMAT_32BIT16	= 24; 32-bit integer With 16-bit alignment
#BASS_ASIO_FORMAT_32BIT18	= 25; 32-bit integer With 18-bit alignment
#BASS_ASIO_FORMAT_32BIT20	= 26; 32-bit integer With 20-bit alignment
#BASS_ASIO_FORMAT_32BIT24	= 27; 32-bit integer With 24-bit alignment
#BASS_ASIO_FORMAT_DSD_LSB	= 32; DSD (LSB 1st)
#BASS_ASIO_FORMAT_DSD_MSB	= 33; DSD (MSB 1st)
#BASS_ASIO_FORMAT_DITHER	= $100 ; flag: apply dither when converting from floating-point To integer

; BASS_ASIO_ChannelReset flags
#BASS_ASIO_RESET_ENABLE	= 1   ; disable channel
#BASS_ASIO_RESET_JOIN	= 2     ; unjoin channel
#BASS_ASIO_RESET_PAUSE	= 4   ; unpause channel
#BASS_ASIO_RESET_FORMAT	= 8   ; reset sample format To native format
#BASS_ASIO_RESET_RATE	= 16    ; reset sample rate To device rate
#BASS_ASIO_RESET_VOLUME	= 32  ; reset volume To 1.0
#BASS_ASIO_RESET_JOINED	= $10000 ; apply To joined channels too

; BASS_ASIO_ChannelIsActive Return values
#BASS_ASIO_ACTIVE_DISABLED	= 0
#BASS_ASIO_ACTIVE_ENABLED	= 1
#BASS_ASIO_ACTIVE_PAUSED	= 2

; driver notifications
#BASS_ASIO_NOTIFY_RATE = 1   ;sample rate change
#BASS_ASIO_NOTIFY_RESET = 2  ;reset (reinitialization) request

; BASS_ASIO_ChannelGetLevel flags
#BASS_ASIO_LEVEL_RMS	= $1000000

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\bassasio.lib"
CompilerElse
  Import "libs_x86\bassasio.lib"
CompilerEndIf
  BASS_ASIO_GetVersion.l()
  BASS_ASIO_SetUnicode.l(unicode.l)
  BASS_ASIO_ErrorGetCode.l()
  BASS_ASIO_GetDeviceInfo.l(device.l, *info.BASS_ASIO_DEVICEINFO)
  BASS_ASIO_AddDevice.l(*clsid, *driver, *name)
  BASS_ASIO_SetDevice.l(device.l)
  BASS_ASIO_GetDevice.l()
  BASS_ASIO_Init.l(device.l, flags.l)
  BASS_ASIO_Free.l()
  BASS_ASIO_Lock.l(lock.l)
  BASS_ASIO_SetNotify.l(*proc, *user)
  BASS_ASIO_ControlPanel.l()
  BASS_ASIO_GetInfo.l(*info.BASS_ASIO_INFO)
  BASS_ASIO_CheckRate.l(rate.d)
  BASS_ASIO_SetRate.l(rate.d)
  BASS_ASIO_GetRate.d()
  BASS_ASIO_Start.l(buflen.l, threads.l)
  BASS_ASIO_Stop.l()
  BASS_ASIO_IsStarted.l()
  BASS_ASIO_GetLatency.l(input.l)
  BASS_ASIO_GetCPU.f()
  BASS_ASIO_Monitor.l(input.l, output.l, gain.l, State.l, pan.l)
  BASS_ASIO_SetDSD.l(dsd.l)
  BASS_ASIO_Future.l(selector.l, *param)
  
  BASS_ASIO_ChannelGetInfo.l(input.l, channel.l, *info.BASS_ASIO_CHANNELINFO)
  BASS_ASIO_ChannelReset.l(input.l, channel.l, flags.l)
  BASS_ASIO_ChannelEnable.l(input.l, channel.l, *proc, *user)
  BASS_ASIO_ChannelEnableMirror.l(channel.l, input2.l, channel2.l)
  BASS_ASIO_ChannelEnableBASS.l(input.l, channel.l, handle.l, join.l)
  BASS_ASIO_ChannelJoin.l(input.l, channel.l, channel2.l)
  BASS_ASIO_ChannelPause.l(input.l, channel.l)
  BASS_ASIO_ChannelIsActive.l(input.l, channel.l)
  BASS_ASIO_ChannelSetFormat.l(input.l, channel.l, format.l)
  BASS_ASIO_ChannelGetFormat.l(input.l, channel.l)
  BASS_ASIO_ChannelSetRate.l(input.l, channel.l, rate.d)
  BASS_ASIO_ChannelGetRate.d(input.l, channel.l)
  BASS_ASIO_ChannelSetVolume.l(input.l, channel.l, volume.f)
  BASS_ASIO_ChannelGetVolume.f(input.l, channel.l)
  BASS_ASIO_ChannelGetLevel.f(input.l, channel.l)
EndImport
