;	BASSloud 2.4 C/C++ header file
;	Copyright (c) 2023 Un4seen Developments Ltd.

;	See the BASSLOUD.CHM file for more detailed documentation

; BASS_Loudness_Start flags / BASS_Loudness_GetLevel modes
#BASS_LOUDNESS_CURRENT    = 0
#BASS_LOUDNESS_INTEGRATED = 1
#BASS_LOUDNESS_RANGE      = 2
#BASS_LOUDNESS_PEAK       = 4
#BASS_LOUDNESS_TRUEPEAK   = 8
#BASS_LOUDNESS_AUTOFREE   = $8000

; BASSLOUD Functions
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\bassloud.lib"
CompilerElse
  Import "libs_x86\bassloud.lib"
CompilerEndIf

 BASS_Loudness_GetVersion.l()

 BASS_Loudness_Start.l(handle.l, flags.l, priority.l)
 BASS_Loudness_Stop.l(handle.l)
 BASS_Loudness_SetChannel.l(handle.l, channel.l, priority.l)
 BASS_Loudness_GetChannel.l(handle.l)
 BASS_Loudness_GetLevel.l(handle.l, mode.l, *level)
 BASS_Loudness_GetLevelMulti.l(*handles, count.l, mode.l, *level)

EndImport