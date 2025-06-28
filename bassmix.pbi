; BASSmix 2.4 C/C++ header file
; Copyright (c) 2005-2022 Un4seen Developments Ltd.
;
; See the BASSMIX.CHM file for more detailed documentation
;
; C to PB adaption by Roger "Rescator" Hågensen, 7th March 2008, http://EmSai.net/

; Additional BASS_SetConfig option
#BASS_CONFIG_MIXER_BUFFER = $10601
#BASS_CONFIG_MIXER_POSEX = $10602
#BASS_CONFIG_SPLIT_BUFFER = $10610

; BASS_Mixer_StreamCreate flags
#BASS_MIXER_RESUME = $1000    ; resume stalled immediately upon new/unpaused source
#BASS_MIXER_POSEX = $2000     ; enable BASS_Mixer_ChannelGetPositionEx support
#BASS_MIXER_NOSPEAKER = $4000 ; ignore speaker arrangement
#BASS_MIXER_QUEUE = $8000     ; queue sources
#BASS_MIXER_END = $10000      ; end the stream when there are no sources
#BASS_MIXER_NONSTOP = $20000  ; don't stall when there are no sources

; BASS_Mixer_StreamAddChannel/Ex flags
#BASS_MIXER_CHAN_ABSOLUTE = $1000	  ; start is an absolute position
#BASS_MIXER_CHAN_BUFFER = $2000     ; buffer Data for BASS_Mixer_ChannelGetData/Level
#BASS_MIXER_CHAN_LIMIT = $4000      ; limit mixer processing to the amount available from this source
#BASS_MIXER_CHAN_MATRIX = $10000    ; matrix mixing
#BASS_MIXER_CHAN_PAUSE = $20000     ; don't process the source
#BASS_MIXER_CHAN_DOWNMIX = $400000  ; downmix to stereo/mono
#BASS_MIXER_CHAN_NORAMPIN = $800000 ; don't ramp-in the start
#BASS_MIXER_BUFFER = #BASS_MIXER_CHAN_BUFFER
#BASS_MIXER_LIMIT = #BASS_MIXER_CHAN_LIMIT
#BASS_MIXER_MATRIX = #BASS_MIXER_CHAN_MATRIX
#BASS_MIXER_PAUSE = #BASS_MIXER_CHAN_PAUSE
#BASS_MIXER_DOWNMIX = #BASS_MIXER_CHAN_DOWNMIX
#BASS_MIXER_NORAMPIN = #BASS_MIXER_CHAN_NORAMPIN

; Mixer attributes
#BASS_ATTRIB_MIXER_LATENCY = $15000
#BASS_ATTRIB_MIXER_THREADS = $15001
#BASS_ATTRIB_MIXER_VOL     = $15002

; Additional BASS_Mixer_ChannelIsActive return values
#BASS_ACTIVE_WAITING = 5
#BASS_ACTIVE_QUEUED  = 6

; BASS_Split_StreamCreate flags
#BASS_SPLIT_SLAVE = $1000     ; only read buffered data
#BASS_SPLIT_POS	  = $2000

; Splitter attributes
#BASS_ATTRIB_SPLIT_ASYNCBUFFER = $15010
#BASS_ATTRIB_SPLIT_ASYNCPERIOD = $15011

; Envelope node
Structure BASS_MIXER_NODE Align #PB_Structure_AlignC
  pos.q
  value.f
EndStructure

; Envelope types
#BASS_MIXER_ENV_FREQ = 1
#BASS_MIXER_ENV_VOL = 2
#BASS_MIXER_ENV_PAN = 3
#BASS_MIXER_ENV_LOOP = $10000   ; flag: loop
#BASS_MIXER_ENV_REMOVE = $20000 ; flag: remove at end

; Additional sync type
#BASS_SYNC_MIXER_ENVELOPE = $10200
#BASS_SYNC_MIXER_ENVELOPE_NODE = $10201
#BASS_SYNC_MIXER_QUEUE = $10202

; Additional BASS_Mixer_ChannelSetPosition flag
#BASS_POS_MIXER_RESET = $10000 ; flag: clear mixer's playback buffer

; Additional BASS_Mixer_ChannelGetPosition mode
#BASS_POS_MIXER_DELAY = 5

; BASS_CHANNELINFO types
#BASS_CTYPE_STREAM_MIXER = $10800
#BASS_CTYPE_STREAM_SPLIT = $10801

;BASSmix Functions
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\bassmix.lib"
CompilerElse
  Import "libs_x86\bassmix.lib"
CompilerEndIf
 BASS_Mixer_GetVersion.l()
 
 BASS_Mixer_StreamCreate.l(freq.l, chans.l, flags.l)
 BASS_Mixer_StreamAddChannel.l(handle.l, channel.l, flags.l)
 BASS_Mixer_StreamAddChannelEx.l(handle.l, channel.l, flags.l, start.q, length.q)
 BASS_Mixer_StreamGetChannels.l(handle.l, *channels, count.l)
 
 BASS_Mixer_ChannelGetMixer.l(handle.l)
 BASS_Mixer_ChannelIsActive.l(handle.l)
 BASS_Mixer_ChannelFlags.l(handle.l, flags.l, mask.l)
 BASS_Mixer_ChannelRemove.l(handle.l)
 BASS_Mixer_ChannelSetPosition.l(handle.l, pos.q, mode.l)
 BASS_Mixer_ChannelGetPosition.q(handle.l, mode.l)
 BASS_Mixer_ChannelGetPositionEx.q(handle.l, mode.l, delay.l)
 BASS_Mixer_ChannelGetLevel.l(handle.l)
 BASS_Mixer_ChannelGetLevelEx.l(handle.l, *levels, length.f, flags.l)
 BASS_Mixer_ChannelGetData.l(handle.l, *buffer, length.l)
 BASS_Mixer_ChannelSetSync.l(handle.l, type.l, param.q, *proc, *user)
 BASS_Mixer_ChannelRemoveSync.l(channel.l, sync.l)
 BASS_Mixer_ChannelSetMatrix.l(handle.l, *matrix)
 BASS_Mixer_ChannelSetMatrixEx.l(handle.l, *matrix, time.f)
 BASS_Mixer_ChannelGetMatrix.l(handle.l, *matrix)
 BASS_Mixer_ChannelSetEnvelope.l(handle.l, type.l, *nodes, count.l)
 BASS_Mixer_ChannelSetEnvelopePos.l(handle.l, type.l, pos.q)
 BASS_Mixer_ChannelGetEnvelopePos.q(handle.l, type.l, *value)

 BASS_Split_StreamCreate.l(channel.l, flags.l, *chanmap)
 BASS_Split_StreamGetSource.l(handle.l)
 BASS_Split_StreamGetSplits.l(handle.l, *splits, count.l)
 BASS_Split_StreamReset.l(handle.l)
 BASS_Split_StreamResetEx.l(handle.l, offset.l)
 BASS_Split_StreamGetAvailable.l(handle.l)

EndImport