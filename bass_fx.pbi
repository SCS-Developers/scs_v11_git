; "BASS_FX"
;=============================================================================
; BASS_FX 2.4 - Copyright (c) 2002-2018 (: JOBnik! :) [Arthur Aminov, ISRAEL]
;                                                     [http://www.jobnik.org]
;
;         bugs/suggestions/questions:
;           forum  : http://www.un4seen.com/forum/?board=1
;                    http://www.jobnik.org/smforum
;           e-mail : bass_fx@jobnik.org
;        --------------------------------------------------
;
; NOTE: This module will work only with BASS_FX version 2.4.10
;       Check www.un4seen.com or www.jobnik.org for any later versions.
;
; * Requires BASS 2.4 (available at http://www.un4seen.com)
;=============================================================================

; BASS_CHANNELINFO types
#BASS_CTYPE_STREAM_TEMPO   = $1f200
#BASS_CTYPE_STREAM_REVERSE = $1f201

; Tempo / Reverse / BPM / Beat flag
#BASS_FX_FREESOURCE = $10000     ; Free the source handle as well?

; BASS_FX Version
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\bass_fx.lib"
CompilerElse
  Import "libs_x86\bass_fx.lib"
CompilerEndIf
  BASS_FX_GetVersion.l()
  BASS_FX_TempoCreate.l(chan.l, flags.l)
  BASS_FX_TempoGetSource.l(chan.l)
  BASS_FX_TempoGetRateRatio.f(chan.l)
  BASS_FX_ReverseCreate.l(chan.l, dec_block.f, flags.l)
  BASS_FX_ReverseGetSource.l(chan.l)
  BASS_FX_BPM_DecodeGet.f(chan.l, startSec.d, endSec.d, minMaxBPM.l, flags.l, proc.l, user.l)
  BASS_FX_BPM_CallbackSet.l(Handle.l, proc.l, period.d, minMaxBPM.l, flags.l, user.l)
  BASS_FX_BPM_CallbackReset.l(Handle.l)
  BASS_FX_BPM_Translate.f(Handle.l, val2tran.f, trans.l) ; deprecated
  BASS_FX_BPM_Free(Handle.l)
  BASS_FX_BPM_BeatCallbackSet.l(Handle.l, proc.l, user.l)
  BASS_FX_BPM_BeatCallbackReset.l(Handle.l)
  BASS_FX_BPM_BeatDecodeGet.l(Handle.l, startSec.d, endSec.d, flags.l, proc.l, user.l)
  BASS_FX_BPM_BeatSetParameters.l(Handle.l, bandwidth.f, centerfreq.f, beat_rtime.f)
  ; BASS_FX_BPM_BeatGetParameters.l(Handle.l, *bandwidth.f, *centerfreq.f, *beat_rtime.f)
  BASS_FX_BPM_BeatGetParameters.l(Handle.l, *bandwidth.Float, *centerfreq.Float, *beat_rtime.Float)
  BASS_FX_BPM_BeatFree(Handle.l)
EndImport
  
;=============================================================================
;	DSP (Digital Signal Processing)
;=============================================================================

;	Multi-channel order of each channel is as follows:
;	 3 channels       left-front, right-front, center.
;	 4 channels       left-front, right-front, left-rear/side, right-rear/side.
;	 5 channels       left-front, right-front, center, left-rear/side, right-rear/side.
;	 6 channels (5.1) left-front, right-front, center, LFE, left-rear/side, right-rear/side.
;	 8 channels (7.1) left-front, right-front, center, LFE, left-rear/side, right-rear/side, left-rear center, right-rear center.

; DSP channels flags
#BASS_BFX_CHANALL = -1            ; all channels at once (as by default)
#BASS_BFX_CHANNONE = 0            ; disable an effect for all channels
#BASS_BFX_CHAN1 = 1               ; left-front channel
#BASS_BFX_CHAN2 = 2               ; right-front channel
#BASS_BFX_CHAN3 = 4               ; see above info
#BASS_BFX_CHAN4 = 8               ; see above info
#BASS_BFX_CHAN5 = 16              ; see above info
#BASS_BFX_CHAN6 = 32              ; see above info
#BASS_BFX_CHAN7 = 64              ; see above info
#BASS_BFX_CHAN8 = 128             ; see above info

; if you have more than 8 channels (7.1), use BASS_BFX_CHANNEL_N(n) function below

; DSP effects
Enumeration ; BFX
  #BASS_FX_BFX_ROTATE = $10000              ; A channels volume ping-pong  / multi-channel
  #BASS_FX_BFX_ECHO                          ; Echo                         / 2 channels max   (deprecated)
  #BASS_FX_BFX_FLANGER                       ; Flanger                      / multi channel    (deprecated)
  #BASS_FX_BFX_VOLUME                        ; Volume                       / multi channel
  #BASS_FX_BFX_PEAKEQ                        ; Peaking Equalizer            / multi channel
  #BASS_FX_BFX_REVERB                        ; Reverb                       / 2 channels max   (deprecated)
  #BASS_FX_BFX_LPF                           ; Low Pass Filter 24dB         / multi channel    (deprecated)
  #BASS_FX_BFX_MIX                           ; Swap, remap and mix channels / multi channel
  #BASS_FX_BFX_DAMP                          ; Dynamic Amplification        / multi channel
  #BASS_FX_BFX_AUTOWAH                       ; Auto Wah                     / multi channel
  #BASS_FX_BFX_ECHO2                         ; Echo 2                       / multi channel    (deprecated)
  #BASS_FX_BFX_PHASER                        ; Phaser                       / multi channel
  #BASS_FX_BFX_ECHO3                         ; Echo 3                       / multi channel    (deprecated)
  #BASS_FX_BFX_CHORUS                        ; Chorus/Flanger               / multi channel
  #BASS_FX_BFX_APF                           ; All Pass Filter              / multi channel    (deprecated)
  #BASS_FX_BFX_COMPRESSOR                    ; Compressor                   / multi channel    (deprecated)
  #BASS_FX_BFX_DISTORTION                    ; Distortion                   / multi channel
  #BASS_FX_BFX_COMPRESSOR2                   ; Compressor 2                 / multi channel
  #BASS_FX_BFX_VOLUME_ENV                    ; Volume envelope              / multi channel
  #BASS_FX_BFX_BQF                           ; BiQuad filters               / multi channel
  #BASS_FX_BFX_ECHO4                         ; Echo 4                       / multi channel
	#BASS_FX_BFX_PITCHSHIFT                    ; Pitch shift using FFT        / multi channel    (Not available on mobile)
	#BASS_FX_BFX_FREEVERB                      ; Reverb using "Freeverb" algo / multi channel
EndEnumeration

; Deprecated effects in 2.4.10 version:
; ------------------------------------
; #BASS_FX_BFX_ECHO        -> use #BASS_FX_BFX_ECHO4
; #BASS_FX_BFX_ECHO2       -> use #BASS_FX_BFX_ECHO4
; #BASS_FX_BFX_ECHO3       -> use #BASS_FX_BFX_ECHO4
; #BASS_FX_BFX_REVERB      -> use BASS_FX_BFX_FREEVERB
; #BASS_FX_BFX_FLANGER     -> use #BASS_FX_BFX_CHORUS
; #BASS_FX_BFX_COMPRESSOR  -> use #BASS_FX_BFX_COMPRESSOR2
; #BASS_FX_BFX_APF         -> use #BASS_FX_BFX_BQF with BASS_BFX_BQF_ALLPASS filter
; #BASS_FX_BFX_LPF         -> use 2x #BASS_FX_BFX_BQF with BASS_BFX_BQF_LOWPASS filter and appropriate fQ values

; Rotate
Structure BASS_BFX_ROTATE
  fRate.f                           ; rotation rate/speed in Hz (A negative rate can be used for reverse direction)
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s (supported only even number of channels)
EndStructure

; Echo (deprecated)
Structure BASS_BFX_ECHO
  fLevel.f                          ; [0....1....n] linear
  lDelay.l                            ; [1200..30000]
EndStructure

; Flanger (deprecated)
Structure BASS_BFX_FLANGER
  fWetDry.f                         ; [0....1....n] linear
  fSpeed.f                          ; [0......0.09]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Volume
Structure BASS_BFX_VOLUME
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s or 0 for global volume control
  fVolume.f                         ; [0....1....n] linear
EndStructure

; Peaking Equalizer
Structure BASS_BFX_PEAKEQ
  lBand.l                             ; [0...............n] more bands means more memory & cpu usage
  fBandWidth.f                      ; [0.1...........<10] in octaves - fQ is not in use (Bandwidth has a priority over fQ)
  fQ.f                              ; [0...............1] the EE kinda definition (linear) (if Bandwidth is not in use)
  fCenter.f                         ; [1Hz..<info.freq/2] in Hz
  fGain.f                           ; [-15dB...0...+15dB] in dB (can be above/below these limits)
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Reverb (deprecated)
Structure BASS_BFX_REVERB
  fLevel.f                          ; [0....1....n] linear
  lDelay.l                            ; [1200..10000]
EndStructure

; Low Pass Filter (deprecated)
Structure BASS_BFX_LPF
  fResonance.f                      ; [0.01............10]
  fCutOffFreq.f                     ; [1Hz....info.freq/2] cutoff frequency
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Swap, remap and mix
Structure BASS_BFX_MIX
  lChannel.l                          ; a pointer to an array of channels to mix using BASS_BFX_CHANxxx flag/s (lChannel[0] is left channel...)
EndStructure

; Dynamic Amplification
Structure BASS_BFX_DAMP
  fTarget.f                         ; target volume level                      [0<......1] linear
  fQuiet.f                          ; quiet  volume level                      [0.......1] linear
  fRate.f                           ; amp adjustment rate                      [0.......1] linear
  fGain.f                           ; amplification level                      [0...1...n] linear
  fDelay.f                          ; delay in seconds before increasing level [0.......n] linear
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Auto Wah
Structure BASS_BFX_AUTOWAH
  fDryMix.f                         ; dry (unaffected) signal mix              [-2......2]
  fWetMix.f                         ; wet (affected) signal mix                [-2......2]
  fFeedback.f                       ; output signal to feed back into input	 [-1......1]
  fRate.f                           ; rate of sweep in cycles per second       [0<....<10]
  fRange.f                          ; sweep range in octaves                   [0<....<10]
  fFreq.f                           ; base frequency of sweep Hz               [0<...1000]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Echo 2 (deprecated)
Structure BASS_BFX_ECHO2
  fDryMix.f                         ; dry (unaffected) signal mix              [-2......2]
  fWetMix.f                         ; wet (affected) signal mix                [-2......2]
  fFeedback.f                       ; output signal to feed back into input	 [-1......1]
  fDelay.f                          ; delay sec                                [0<......n]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Phaser
Structure BASS_BFX_PHASER
  fDryMix.f                         ; dry (unaffected) signal mix              [-2......2]
  fWetMix.f                         ; wet (affected) signal mix                [-2......2]
  fFeedback.f                       ; output signal to feed back into input	 [-1......1]
  fRate.f                           ; rate of sweep in cycles per second       [0<....<10]
  fRange.f                          ; sweep range in octaves                   [0<....<10]
  fFreq.f                           ; base frequency of sweep                  [0<...1000]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Echo 3 (deprecated)
Structure BASS_BFX_ECHO3
  fDryMix.f                         ; dry (unaffected) signal mix              [-2......2]
  fWetMix.f                         ; wet (affected) signal mix                [-2......2]
  fDelay.f                          ; delay sec                                [0<......n]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Chorus/Flanger
Structure BASS_BFX_CHORUS
  fDryMix.f                         ; dry (unaffected) signal mix              [-2......2]
  fWetMix.f                         ; wet (affected) signal mix                [-2......2]
  fFeedback.f                       ; output signal to feed back into input	 [-1......1]
  fMinSweep.f                       ; minimal delay ms                         [0<..<6000]
  fMaxSweep.f                       ; maximum delay ms                         [0<..<6000]
  fRate.f                           ; rate ms/s                                [0<...1000]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; All Pass Filter (deprecated)
Structure BASS_BFX_APF
  fGain.f                           ; reverberation time                       [-1=<..<=1]
  fDelay.f                          ; delay sec                                [0<....<=n]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Compressor (deprecated)
Structure BASS_BFX_COMPRESSOR
  fThreshold.f                      ; compressor threshold                     [0<=...<=1]
  fAttacktime.f                     ; attack time ms                           [0<.<=1000]
  fReleasetime.f                    ; release time ms                          [0<.<=5000]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Distortion
Structure BASS_BFX_DISTORTION
  fDrive.f                          ; distortion drive                         [0<=...<=5]
  fDryMix.f                         ; dry (unaffected) signal mix              [-5<=..<=5]
  fWetMix.f                         ; wet (affected) signal mix                [-5<=..<=5]
  fFeedback.f                       ; output signal to feed back into input	 [-1<=..<=1]
  fVolume.f                         ; distortion volume                        [0=<...<=2]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Compressor 2
Structure BASS_BFX_COMPRESSOR2
  fGain.f                           ; output gain of signal after compression  [-60....60] in dB
  fThreshold.f                      ; point at which compression begins        [-60.....0] in dB
  fRatio.f                          ; compression ratio                        [1.......n]
  fAttack.f                         ; attack time in ms                        [0.01.1000]
  fRelease.f                        ; release time in ms                       [0.01.5000]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Volume envelope
Structure BASS_BFX_ENV_NODE
  pos.d                             ; node position in seconds (1st envelope node must be at position 0)
  val_.f                            ; node value
EndStructure

Structure BASS_BFX_VOLUME_ENV
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
  lNodeCount.l                        ; number of nodes
  pNodes.l                            ; the nodes. Pointer to nodes of BASS_BFX_ENV_NODE
  bFollow.l                           ; follow source position
EndStructure

; BiQuad Filters
Enumeration ; BQF
  #BASS_BFX_BQF_LOWPASS
  #BASS_BFX_BQF_HIGHPASS
  #BASS_BFX_BQF_BANDPASS                     ; constant 0 dB peak gain
  #BASS_BFX_BQF_BANDPASS_Q                   ; constant skirt gain, peak gain = Q
  #BASS_BFX_BQF_NOTCH
  #BASS_BFX_BQF_ALLPASS
  #BASS_BFX_BQF_PEAKINGEQ
  #BASS_BFX_BQF_LOWSHELF
  #BASS_BFX_BQF_HIGHSHELF
EndEnumeration

Structure BASS_BFX_BQF
  lFilter.l                        ; #BASS_BFX_BQF_xxx filter types
  fCenter.f                        ; [1Hz..<info.freq/2] Cutoff (central) frequency in Hz
  fGain.f                          ; [-15dB...0...+15dB] Used only for PEAKINGEQ and Shelving filters in dB (can be above/below these limits)
  fBandWidth.f                     ; [0.1...........<10] Bandwidth in octaves (fQ is not in use (fBandwidth has a priority over fQ))
                                   ;                     (between -3 dB frequencies for BANDPASS and NOTCH or between midpoint
                                   ;                     (fGgain/2) gain frequencies for PEAKINGEQ)
  fQ.f                             ; [0.1.............1] The EE kinda definition (linear) (if fBandwidth is not in use)
  fS.f                             ; [0.1.............1] A "shelf slope" parameter (linear) (used only with Shelving filters)
                                   ;                     when fS = 1, the shelf slope is as steep as you can get it and remain monotonically
                                   ;                     increasing or decreasing gain with frequency.
  lChannel.l                       ; BASS_BFX_CHANxxx flag/s
EndStructure

; Echo 4
Structure BASS_BFX_ECHO4
  fDryMix.f                         ; dry (unaffected) signal mix              [-2.......2]
  fWetMix.f                         ; wet (affected) signal mix                [-2.......2]
  fFeedback.f                       ; output signal to feed back into input    [-1.......1]
  fDelay.f                          ; delay sec                                [0<.......n]
  bStereo.l                           ; echo adjoining channels to each other    [TRUE/FALSE]
  lChannel.l                          ; BASS_BFX_CHANxxx flag/s
EndStructure

; Pitch shift (not available on mobile)
Structure BASS_BFX_PITCHSHIFT
  fPitchShift.f                     ; A factor value which is between 0.5 (one octave down) and 2 (one octave up) (1 won't change the pitch) [1 default]
                                    ; (fSemitones is not in use, fPitchShift has a priority over fSemitones)
  fSemitones.f                      ; Semitones (0 won't change the pitch) [0 default]
  lFFTsize.l                        ;	Defines the FFT frame size used for the processing. Typical values are 1024, 2048 and 4096 [2048 default]
                                    ; It may be any value <= 8192 but it MUST be a power of 2
  lOsamp.l                          ; Is the STFT oversampling factor which also determines the overlap between adjacent STFT frames [8 default]
                                    ; It should at least be 4 for moderate scaling ratios. A value of 32 is recommended for best quality (better quality = higher CPU usage)
  lChannel.l                        ; BASS_BFX_CHANxxx flag/s
EndStructure

; Freeverb
#BASS_BFX_FREEVERB_MODE_FREEZE = 1

Structure BASS_BFX_FREEVERB
	fDryMix.f                         ; dry (unaffected) signal mix				[0........1], def. 0
	fWetMix.f                         ; wet (affected) signal mix				[0........3], def. 1.0f
	fRoomSize.f                       ; room size								[0........1], def. 0.5f
	fDamp.f                           ; damping									[0........1], def. 0.5f
	fWidth.f                          ; stereo width								[0........1], def. 1
	lMode.l                           ; 0 or BASS_BFX_FREEVERB_MODE_FREEZE, def. 0 (no freeze)
  lChannel.l                        ; BASS_BFX_CHANxxx flag/s
EndStructure

;=============================================================================
;   set dsp fx          - BASS_ChannelSetFX
;   remove dsp fx       - BASS_ChannelRemoveFX
;   set parameters      - BASS_FXSetParameters
;   retrieve parameters - BASS_FXGetParameters
;   reset the state     - BASS_FXReset
;=============================================================================

;=============================================================================
;   Tempo, Pitch scaling and Sample rate changers
;=============================================================================

; NOTE: Enable Tempo supported flags in BASS_FX_TempoCreate and the others to source handle.

; tempo attributes (BASS_ChannelSet/GetAttribute)
Enumeration ; TempoAttribs
  #BASS_ATTRIB_TEMPO = $10000
  #BASS_ATTRIB_TEMPO_PITCH
  #BASS_ATTRIB_TEMPO_FREQ
EndEnumeration

; tempo attributes options
Enumeration ; TempoAttribsOptions
  #BASS_ATTRIB_TEMPO_OPTION_USE_AA_FILTER = $10010    ; TRUE (default) / FALSE (default for multi-channel on mobile devices for lower CPU usage)
  #BASS_ATTRIB_TEMPO_OPTION_AA_FILTER_LENGTH           ; 32 default (8 .. 128 taps)
  #BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO              ; TRUE (default on mobile devices for loswer CPU usage) / FALSE (default)
  #BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS                ; 82 default, 0 = automatic
  #BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS              ; 28 default, 0 = automatic
  #BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS                 ; 8  default
  #BASS_ATTRIB_TEMPO_OPTION_PREVENT_CLICK              ; TRUE / FALSE (default)
EndEnumeration

;=============================================================================
;   Reverse playback
;=============================================================================

; NOTE: 1. MODs won't load without BASS_MUSIC_PRESCAN flag.
;       2. Enable Reverse supported flags in BASS_FX_ReverseCreate and the others to source handle.

; reverse attribute (BASS_ChannelSet/GetAttribute)
#BASS_ATTRIB_REVERSE_DIR = $11000

; playback directions
#BASS_FX_RVS_REVERSE = -1
#BASS_FX_RVS_FORWARD = 1

;=============================================================================
;   BPM (Beats Per Minute)
;=============================================================================

; bpm flags
#BASS_FX_BPM_BKGRND = 1   ; if in use, then you can do other processing while detection's in progress. Available only in Windows platforms (BPM/Beat)
#BASS_FX_BPM_MULT2 = 2    ; if in use, then will auto multiply bpm by 2 (if BPM < minBPM*2)

; translation options (deprecated)
Enumeration ; bpmTranslation
  #BASS_FX_BPM_TRAN_X2         ; multiply the original BPM value by 2 (may be called only once & will change the original BPM as well!)
  #BASS_FX_BPM_TRAN_2FREQ      ; BPM value to Frequency
  #BASS_FX_BPM_TRAN_FREQ2      ; Frequency to BPM value
  #BASS_FX_BPM_TRAN_2PERCENT   ; BPM value to Percents
  #BASS_FX_BPM_TRAN_PERCENT2   ; Percents to BPM value
EndEnumeration

;=============================================================================
;   Beat position trigger
;=============================================================================

;=============================================================================
;   Callback functions
;=============================================================================

;typedef void (CALLBACK BPMPROC)(DWORD chan, float bpm, void *user);
;typedef void (CALLBACK BPMPROGRESSPROC)(DWORD chan, float percent, void *user);
;typedef BPMPROGRESSPROC BPMPROCESSPROC;	// back-compatibility

;=============================================================================
;   Macros
;=============================================================================

; If you have more than 8 channels (7.1), use this function
Procedure.l BASS_BFX_CHANNEL_N(n.l)
  ProcedureReturn Pow(2, (n - 1))
EndProcedure

; translate linear level to logarithmic dB
Procedure.d BASS_BFX_Linear2dB(level.d)
  ProcedureReturn 20 * (Log(level) / 2.30258509299405)   ; base 10 logarithm
EndProcedure

; translate logarithmic dB level to linear
Procedure.d BASS_BFX_dB2Linear(dB.d)
  ProcedureReturn Pow(10, (dB / 20))
EndProcedure
