;BASSenc 2.4 C/C++ header file
;Copyright (c) 2003-2022 Un4seen Developments Ltd.
;
;See the BASSENC.CHM file for more detailed documentation
;
;BASSenc v2.4 include for PureBasic v4.20
;C to PB adaption by Roger "Rescator" Hågensen, 5th March 2008, http://EmSai.net/

;Additional error codes returned by BASS_ErrorGetCode
#BASS_ERROR_ACM_CANCEL = 2000   ; ACM codec selection cancelled
#BASS_ERROR_CAST_DENIED = 2100  ; access denied (invalid password)
#BASS_ERROR_SERVER_CERT = 2101  ; missing/invalid certificate

;Additional BASS_SetConfig options
#BASS_CONFIG_ENCODE_PRIORITY = $10300 ;encoder DSP priority
#BASS_CONFIG_ENCODE_QUEUE = $10301
#BASS_CONFIG_ENCODE_CAST_TIMEOUT = $10310 ;cast timeout

; Additional BASS_SetConfigPtr options
#BASS_CONFIG_ENCODE_ACM_LOAD = $10302
#BASS_CONFIG_ENCODE_CAST_PROXY = $10311
#BASS_CONFIG_ENCODE_CAST_BIND = $10312
#BASS_CONFIG_ENCODE_SERVER_CERT = $10320
#BASS_CONFIG_ENCODE_SERVER_KEY = $10321

;BASS_Encode_Start flags
#BASS_ENCODE_NOHEAD = 1      ;do not send a WAV header to the encoder
#BASS_ENCODE_FP_8BIT = 2     ;convert floating-point sample Data To 8-bit integer
#BASS_ENCODE_FP_16BIT = 4       ;convert floating-point sample Data To 16-bit integer
#BASS_ENCODE_FP_24BIT =6       ;convert floating-point sample Data To 24-bit integer
#BASS_ENCODE_FP_32BIT =8       ;convert floating-point sample Data To 32-bit integer
#BASS_ENCODE_FP_AUTO = 14      ;convert floating-point sample Data back To channel's format
#BASS_ENCODE_BIGEND = 16     ;big-endian sample data
#BASS_ENCODE_PAUSE = 32    ;start encording paused
#BASS_ENCODE_PCM =64   ;write PCM sample Data (no encoder)
#BASS_ENCODE_RF64 = 128        ; send an RF64 header
#BASS_ENCODE_MONO = $100       ; convert to mono (if not already)
#BASS_ENCODE_QUEUE = $200      ; queue data to feed encoder asynchronously
#BASS_ENCODE_WFEXT = $400      ; WAVEFORMATEXTENSIBLE "fmt" chunk
#BASS_ENCODE_CAST_NOLIMIT = $1000 ; don't limit casting data rate
#BASS_ENCODE_LIMIT = $2000        ; limit data rate to real-time
#BASS_ENCODE_AIFF = $4000       ; send an AIFF header rather than WAV
#BASS_ENCODE_DITHER = $8000       ; apply dither when converting floating-point sample data To integer
#BASS_ENCODE_AUTOFREE = $40000     ;free the encoder when the channel is freed

;BASS_Encode_GetACMFormat flags
#BASS_ACM_DEFAULT = 1 ; use the format as default selection
#BASS_ACM_RATE = 2    ; only list formats with same sample rate as the source channel
#BASS_ACM_CHANS = 4   ; only list formats with same number of channels (eg. mono/stereo)
#BASS_ACM_SUGGEST = 8 ; suggest a format (HIWORD=format tag)

;BASS_Encode_GetCount counts
#BASS_ENCODE_COUNT_IN = 0  ;sent to encoder
#BASS_ENCODE_COUNT_OUT = 1 ;received from encoder
#BASS_ENCODE_COUNT_CAST = 2  ;sent to cast server
#BASS_ENCODE_COUNT_QUEUE = 3 ; queued
#BASS_ENCODE_COUNT_QUEUE_LIMIT = 4 ;  queue limit
#BASS_ENCODE_COUNT_QUEUE_FAIL = 5 ; failed to queue
#BASS_ENCODE_COUNT_IN_FP = 6      ; sent to encoder before floating-point conversion

;BASS_Encode_CastInit content MIME types
#BASS_ENCODE_TYPE_MP3 ="audio/mpeg"
#BASS_ENCODE_TYPE_OGG ="application/ogg"
#BASS_ENCODE_TYPE_AAC ="audio/aacp"

;BASS_Encode_CastInit flags
#BASS_ENCODE_CAST_PUBLIC = 1 ; add To public directory
#BASS_ENCODE_CAST_PUT    = 2 ; use PUT method
#BASS_ENCODE_CAST_SSL    = 4 ; use SSL/TLS encryption

;BASS_Encode_CastGetStats types
#BASS_ENCODE_STATS_SHOUT = 0 ;Shoutcast stats
#BASS_ENCODE_STATS_ICE = 1 ;Icecast mount-point stats
#BASS_ENCODE_STATS_ICESERV = 2  ;Icecast server stats

; typedef void (CALLBACK ENCODEPROC)(HENCODE handle, DWORD channel, const void *buffer, DWORD length, void *user);
; /* Encoding callback function.
; handle : The encoder
; channel: The channel handle
; buffer : Buffer containing the encoded Data
; length : Number of bytes
; user   : The 'user' parameter value given when calling BASS_Encode_Start */
 
; typedef void (CALLBACK ENCODENOTIFYPROC)(HENCODE handle, DWORD status, void *user);
; /* Encoder death notification callback function.
; handle : The encoder
; status : Notification (BASS_ENCODE_NOTIFY_xxx)
; user   : The 'user' parameter value given when calling BASS_Encode_SetNotify */

;Encoder notifications
#BASS_ENCODE_NOTIFY_ENCODER = 1 ;encoder died
#BASS_ENCODE_NOTIFY_CAST = 2 ;cast server connection died
#BASS_ENCODE_NOTIFY_SERVER = 3        ; server died
#BASS_ENCODE_NOTIFY_CAST_TIMEOUT = $10000 ;cast timeout
#BASS_ENCODE_NOTIFY_QUEUE_FULL = $10001  ; queue is out of space
#BASS_ENCODE_NOTIFY_FREE = $10002    ; encoder has been freed

; BASS_Encode_ServerInit flags
#BASS_ENCODE_SERVER_NOHTTP = 1 ; no HTTP headers
#BASS_ENCODE_SERVER_META = 2 ; Shoutcast metadata
#BASS_ENCODE_SERVER_SSL = 4

;BASSenc Functions
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\bassenc.lib"
CompilerElse
  Import "libs_x86\bassenc.lib"
CompilerEndIf
  BASS_Encode_GetVersion.l()
  BASS_Encode_Start.l(Handle.l,*cmdline,flags.l,*proc,*user)
  BASS_Encode_StartLimit.l(Handle.l, *cmdline, flags.l, *proc, *user, limit.l)
  BASS_Encode_AddChunk.l(Handle.l, *id, *buffer, length.l)
  BASS_Encode_Write.l(Handle.l,*buffer,length.l)
  BASS_Encode_Stop.l(Handle.l)
  BASS_Encode_StopEx.l(Handle.l, queue.l)
  BASS_Encode_SetPaused.l(Handle.l,paused.l)
  BASS_Encode_IsActive.l(Handle.l)
  BASS_Encode_SetNotify.l(Handle.l,*proc,*user)
  BASS_Encode_GetCount.q(Handle.l,count.l)
  BASS_Encode_SetChannel.l(Handle.l,channel.l)
  BASS_Encode_GetChannel.l(Handle.l)
  CompilerIf #PB_Compiler_OS=#PB_OS_Windows
    BASS_Encode_GetACMFormat.l(Handle.l,*form,formlen.l,*title,flags.l)
    BASS_Encode_StartACM.l(Handle.l,*form,flags.l,*proc,*user)
    BASS_Encode_StartACMFile.l(Handle.l,*form,flags.l,*file)
  CompilerEndIf
  BASS_Encode_CastInit.l(Handle.l,*server,*pass,*content,*name,*url,*genre,*desc,*headers,bitrate.l,pub.l)
  BASS_Encode_CastSetTitle.l(Handle.l,*title,*url)
  BASS_Encode_CastSendMeta.l(Handle.l, type.l, *metadata, length.l)
  BASS_Encode_CastGetStats.l(Handle.l,type.l,*pass)
  
  BASS_Encode_ServerInit.l(Handle.l, *port, Buffer.l, burst.l, flags.l, *proc, *user)
  BASS_Encode_ServerKick.l(Handle.l, *client)
  
EndImport
