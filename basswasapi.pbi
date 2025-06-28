; BASSWASAPI 2.4 C/C++ header file
; Copyright (c) 2009-2020 Un4seen Developments Ltd.

; See the BASSWASAPI.CHM file for more detailed documentation

; Additional error codes returned by BASS_ErrorGetCode
#BASS_ERROR_WASAPI          = 5000 ; no WASAPI
#BASS_ERROR_WASAPI_BUFFER   = 5001 ; buffer size is invalid
#BASS_ERROR_WASAPI_CATEGORY = 5002 ; can't set category
#BASS_ERROR_WASAPI_DENIED   = 5003 ; access denied

; Device info structure
Structure BASS_WASAPI_DEVICEINFO Align #PB_Structure_AlignC
  *name
  *id
  type.l
  flags.l
  minperiod.f
  defperiod.f
  mixfreq.l
  mixchans.l
EndStructure

Structure BASS_WASAPI_INFO
  initflags.l
  freq.l
  chans.l
  format.l
  buflen.l
  volmax.f
  volmin.f
  volstep.f
EndStructure

; BASS_WASAPI_DEVICEINFO "type"
#BASS_WASAPI_TYPE_NETWORKDEVICE = 0
#BASS_WASAPI_TYPE_SPEAKERS      = 1
#BASS_WASAPI_TYPE_LINELEVEL     = 2
#BASS_WASAPI_TYPE_HEADPHONES    = 3
#BASS_WASAPI_TYPE_MICROPHONE    = 4
#BASS_WASAPI_TYPE_HEADSET       = 5
#BASS_WASAPI_TYPE_HANDSET       = 6
#BASS_WASAPI_TYPE_DIGITAL       = 7
#BASS_WASAPI_TYPE_SPDIF         = 8
#BASS_WASAPI_TYPE_HDMI          = 9
#BASS_WASAPI_TYPE_UNKNOWN       = 10

; BASS_WASAPI_DEVICEINFO flags
#BASS_DEVICE_ENABLED    = 1
#BASS_DEVICE_DEFAULT    = 2
#BASS_DEVICE_INIT       = 4
#BASS_DEVICE_LOOPBACK   = 8
#BASS_DEVICE_INPUT      = 16
#BASS_DEVICE_UNPLUGGED  = 32
#BASS_DEVICE_DISABLED   = 64

; BASS_WASAPI_Init flags
#BASS_WASAPI_EXCLUSIVE  = 1
#BASS_WASAPI_AUTOFORMAT = 2
#BASS_WASAPI_BUFFER     = 4
#BASS_WASAPI_EVENT      = 16
#BASS_WASAPI_SAMPLES    = 32
#BASS_WASAPI_DITHER     = 64
#BASS_WASAPI_RAW        = 128
#BASS_WASAPI_ASYNC      = $100

#BASS_WASAPI_CATEGORY_MASK = $f000
#BASS_WASAPI_CATEGORY_OTHER = $0000
#BASS_WASAPI_CATEGORY_FOREGROUNDONLYMEDIA = $1000
#BASS_WASAPI_CATEGORY_BACKGROUNDCAPABLEMEDIA = $2000
#BASS_WASAPI_CATEGORY_COMMUNICATIONS = $3000
#BASS_WASAPI_CATEGORY_ALERTS = $4000
#BASS_WASAPI_CATEGORY_SOUNDEFFECTS = $5000
#BASS_WASAPI_CATEGORY_GAMEEFFECTS = $6000
#BASS_WASAPI_CATEGORY_GAMEMEDIA = $7000
#BASS_WASAPI_CATEGORY_GAMECHAT = $8000
#BASS_WASAPI_CATEGORY_SPEECH = $9000
#BASS_WASAPI_CATEGORY_MOVIE = $A000
#BASS_WASAPI_CATEGORY_MEDIA = $B000

; BASS_WASAPI_INFO "format"
#BASS_WASAPI_FORMAT_FLOAT = 0
#BASS_WASAPI_FORMAT_8BIT = 1
#BASS_WASAPI_FORMAT_16BIT = 2
#BASS_WASAPI_FORMAT_24BIT = 3
#BASS_WASAPI_FORMAT_32BIT = 4

; BASS_WASAPI_Set/GetVolume modes
#BASS_WASAPI_CURVE_DB = 0
#BASS_WASAPI_CURVE_LINEAR = 1
#BASS_WASAPI_CURVE_WINDOWS = 2
#BASS_WASAPI_VOL_SESSION = 8

; typedef DWORD (CALLBACK WASAPIPROC)(void *buffer, DWORD length, void *user);
; /* WASAPI callback function.
; buffer : Buffer containing the sample data
; length : Number of bytes
; user   : The 'user' parameter given when calling BASS_WASAPI_Init
; RETURN : The number of bytes written (output devices), 0/1 = stop/continue (input devices) */

; Special WASAPIPROCs
; #WASAPIPROC_PUSH (WASAPIPROC*) = 0  ; push output
; #WASAPIPROC_BASS (WASAPIPROC*) = -1 ; BASS channel

; typedef void (CALLBACK WASAPINOTIFYPROC)(DWORD notify, DWORD device, void *user);
; /* WASAPI device notification callback function.
; notify : The notification (BASS_WASAPI_NOTIFY_xxx)
; device : Device that the notification applies to
; user   : The 'user' parameter given when calling BASS_WASAPI_SetNotify */

; Device notifications
#BASS_WASAPI_NOTIFY_ENABLED = 0
#BASS_WASAPI_NOTIFY_DISABLED = 1
#BASS_WASAPI_NOTIFY_DEFOUTPUT = 2
#BASS_WASAPI_NOTIFY_DEFINPUT = 3
#BASS_WASAPI_NOTIFY_FAIL = $100

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\basswasapi.lib"
CompilerElse
  Import "libs_x86\basswasapi.lib"
CompilerEndIf
  BASS_WASAPI_GetVersion.l();
  BASS_WASAPI_SetNotify.l(*procWASAPINOTIFYPROC, *user)
  BASS_WASAPI_GetDeviceInfo.l(device.l, *info.BASS_WASAPI_DEVICEINFO)
  BASS_WASAPI_GetDeviceLevel.f(device.l, chan.l)
  BASS_WASAPI_SetDevice.l(device.l)
  BASS_WASAPI_GetDevice.l()
  BASS_WASAPI_CheckFormat.l(device.l, freq.l, chans.l, flags.l)
  BASS_WASAPI_Init.l(device.l, freq.l, chans.l, flags.l, buffer.f, period.f, *proc, *user)
  BASS_WASAPI_Free.l()
  BASS_WASAPI_GetInfo.l(*info.BASS_WASAPI_INFO)
  BASS_WASAPI_GetCPU.f()
  BASS_WASAPI_Lock.l(lock.l)
  BASS_WASAPI_Start.l()
  BASS_WASAPI_Stop.l(reset.l)
  BASS_WASAPI_IsStarted.l()
  BASS_WASAPI_SetVolume.l(mode.l, volume.f)
  BASS_WASAPI_GetVolume.f(mode.l)
  BASS_WASAPI_SetMute.l(mode.l, mute.l)
  BASS_WASAPI_GetMute.l(mode.l)
  BASS_WASAPI_PutData.l(*buffer, length.l)
  BASS_WASAPI_GetData.l(*buffer, length.l)
  BASS_WASAPI_GetLevel.l();
  BASS_WASAPI_GetLevelEx.l(*levels, length.f, flags.l)
EndImport
