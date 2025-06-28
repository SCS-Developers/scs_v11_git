; File: bass.pbi

; BASS v2.4 include for PureBasic v4.20
; C to PB adaption by Roger "Rescator" Hågensen, 27th March 2008, http://EmSai.net/

; Needed by some code in this include and various other BASS sourcecodes.
Macro LOBYTE(a) : ((a)&$FF) : EndMacro
Macro LOWORD(a) : ((a)&$FFFF) : EndMacro
Macro HIWORD(a) : (((a)>>16)&$FFFF) : EndMacro
Macro MakeLong(a,B) : (((a)&$FFFF)|((B)<<16)) : EndMacro

; Ready? Here we go...

; C to PB comment:
; PureBasic has no direct match for C like typedefs, just treat these as longs instead.
; HMUSIC is a long,	MOD music handle
; HSAMPLE is a long,	sample handle
; HCHANNEL is a long,	sample playback handle
; HSTREAM is a long,	sample stream handle
; HRECORD is a long,	recording handle
; HSYNC is a long,	synchronizer handle
; HDSP is a long,	DSP handle
; HFX is a long,	effect handle
; HPLUGIN is a long,	plugin handle

; =======================================================================================
; Updated  5Mar2020 based on bass.h for version supplied by Ian 5Mar2020
; Updated 18Dec2019 based on bass.h for BASS 2.4.15
; Updated 15Oct2022 based on bass.h for BASS 2.4.17
; =======================================================================================

; BASS 2.4 C/C++ header file
; Copyright (c) 1999-2019 Un4seen Developments Ltd.
 
; See the BASS.CHM file for implementation documentation
 
#BASSVERSION = $204
#BASSVERSIONTEXT = "2.4"

#BASSTRUE = 1
#BASSFALSE = 0

; - BASS Error codes returned by BASS_GetErrorCode
#BASS_OK	             =0	 ; all is OK
#BASS_ERROR_MEM	      =1 	; memory error
#BASS_ERROR_FILEOPEN	 =2 	; can't open the file
#BASS_ERROR_DRIVER	   =3	 ; can't find a free/valid driver
#BASS_ERROR_BUFLOST	  =4	 ; the sample buffer was lost
#BASS_ERROR_HANDLE	   =5 	; invalid handle
#BASS_ERROR_FORMAT	   =6	 ; unsupported sample format
#BASS_ERROR_POSITION	 =7	 ; invalid position
#BASS_ERROR_INIT		    =8	 ; BASS_Init has not been successfully called
#BASS_ERROR_START	    =9	 ; BASS_Start has not been successfully called
#BASS_ERROR_SSL	= 10	; SSL/HTTPS support isn't available
#BASS_ERROR_REINIT = 11	; device needs To be reinitialized
#BASS_ERROR_ALREADY	  =14  ; already initialized/paused/whatever
#BASS_ERROR_NOTAUDIO = 17  ; file does not contain audio
#BASS_ERROR_NOCHAN	   =18	; can't get a free channel
#BASS_ERROR_ILLTYPE	  =19	; an illegal type was specified
#BASS_ERROR_ILLPARAM	 =20	; an illegal parameter was specified
#BASS_ERROR_NO3D		    =21	; no 3D support
#BASS_ERROR_NOEAX	    =22	; no EAX support
#BASS_ERROR_DEVICE	   =23	; illegal device number
#BASS_ERROR_NOPLAY	   =24	; not playing
#BASS_ERROR_FREQ		    =25	; illegal sample rate
#BASS_ERROR_NOTFILE	  =27	; the stream is not a file stream
#BASS_ERROR_NOHW		    =29	; no hardware voices available
#BASS_ERROR_EMPTY	    =31	; the file has no sample data
#BASS_ERROR_NONET	    =32	; no internet connection could be opened
#BASS_ERROR_CREATE	   =33	; couldn't create the file
#BASS_ERROR_NOFX		    =34	; effects are not available
#BASS_ERROR_NOTAVAIL	 =37	; requested data/action is not available
#BASS_ERROR_DECODE	   =38	; the channel is/isn't a "decoding channel"
#BASS_ERROR_DX		      =39	; a sufficient DirectX version is not installed
#BASS_ERROR_TIMEOUT	  =40	; connection timedout
#BASS_ERROR_FILEFORM	 =41	; unsupported file format
#BASS_ERROR_SPEAKER	  =42	; unavailable speaker
#BASS_ERROR_VERSION   =43	; invalid BASS version (used by add-ons)
#BASS_ERROR_CODEC     =44	; codec is not available/supported
#BASS_ERROR_ENDED     =45	; the channel/file has ended
#BASS_ERROR_BUSY      =46 ; the device is busy
#BASS_ERROR_UNSTREAMABLE = 47 ; unstreamable file
#BASS_ERROR_PROTOCOL = 48	; unsupported protocol
#BASS_ERROR_DENIED = 49 ; access denied
#BASS_ERROR_UNKNOWN	  =-1	; some other mystery error

;- BASS_SetConfig options
#BASS_CONFIG_BUFFER        =0
#BASS_CONFIG_UPDATEPERIOD  =1
#BASS_CONFIG_GVOL_SAMPLE   =4
#BASS_CONFIG_GVOL_STREAM   =5
#BASS_CONFIG_GVOL_MUSIC    =6
#BASS_CONFIG_CURVE_VOL     =7
#BASS_CONFIG_CURVE_PAN     =8
#BASS_CONFIG_FLOATDSP      =9
#BASS_CONFIG_3DALGORITHM   =10
#BASS_CONFIG_NET_TIMEOUT   =11
#BASS_CONFIG_NET_BUFFER    =12
#BASS_CONFIG_PAUSE_NOPLAY  =13
#BASS_CONFIG_NET_PREBUF    =15
#BASS_CONFIG_NET_PASSIVE   =18
#BASS_CONFIG_REC_BUFFER    =19
#BASS_CONFIG_NET_PLAYLIST  =21
#BASS_CONFIG_MUSIC_VIRTUAL =22
#BASS_CONFIG_VERIFY        =23
#BASS_CONFIG_UPDATETHREADS =24
#BASS_CONFIG_DEV_BUFFER = 27
#BASS_CONFIG_REC_LOOPBACK = 28
#BASS_CONFIG_VISTA_TRUEPOS = 30
#BASS_CONFIG_IOS_MIXAUDIO = 34
#BASS_CONFIG_IOS_SESSION = 34
#BASS_CONFIG_DEV_DEFAULT = 36
#BASS_CONFIG_NET_READTIMEOUT = 37
#BASS_CONFIG_VISTA_SPEAKERS = 38
#BASS_CONFIG_IOS_SPEAKER = 39
#BASS_CONFIG_HANDLES = 41
#BASS_CONFIG_UNICODE = 42
#BASS_CONFIG_SRC = 43
#BASS_CONFIG_SRC_SAMPLE = 44
#BASS_CONFIG_ASYNCFILE_BUFFER = 45
#BASS_CONFIG_OGG_PRESCAN = 47
#BASS_CONFIG_MF_VIDEO = 48
#BASS_CONFIG_AIRPLAY = 49
#BASS_CONFIG_DEV_NONSTOP = 50
#BASS_CONFIG_IOS_NOCATEGORY = 51
#BASS_CONFIG_VERIFY_NET = 52
#BASS_CONFIG_DEV_PERIOD = 53
#BASS_CONFIG_FLOAT = 54
#BASS_CONFIG_NET_SEEK = 56
#BASS_CONFIG_AM_DISABLE = 58
#BASS_CONFIG_NET_PLAYLIST_DEPTH = 59
#BASS_CONFIG_NET_PREBUF_WAIT = 60
#BASS_CONFIG_ANDROID_SESSIONID = 62
#BASS_CONFIG_LIBSSL = 64
#BASS_CONFIG_WASAPI_PERSIST = 65
#BASS_CONFIG_REC_WASAPI = 66
#BASS_CONFIG_ANDROID_AAUDIO = 67
#BASS_CONFIG_SAMPLE_ONEHANDLE = 69
#BASS_CONFIG_NET_META = 71
#BASS_CONFIG_NET_RESTRATE = 72
#BASS_CONFIG_REC_DEFAULT = 73
#BASS_CONFIG_NORAMP = 74

;- BASS_SetConfigPtr options
#BASS_CONFIG_NET_AGENT = 16
#BASS_CONFIG_NET_PROXY = 17
#BASS_CONFIG_IOS_NOTIFY = 46
#BASS_CONFIG_LIBSSL = 64
#BASS_CONFIG_FILENAME = 75

#BASS_CONFIG_THREAD = $40000000 ; flag: thread-specific setting

;- BASS_CONFIG_IOS_SESSION flags
#BASS_IOS_SESSION_MIX = 1
#BASS_IOS_SESSION_DUCK = 2
#BASS_IOS_SESSION_AMBIENT = 4
#BASS_IOS_SESSION_SPEAKER = 8
#BASS_IOS_SESSION_DISABLE = 16
#BASS_IOS_SESSION_DEACTIVATE = 32
#BASS_IOS_SESSION_AIRPLAY = 64
#BASS_IOS_SESSION_BTHFP = 128
#BASS_IOS_SESSION_BTA2DP = $100

;- BASS_Init flags
#BASS_DEVICE_8BITS      = 1	     ; unused
#BASS_DEVICE_MONO       = 2	     ; mono
#BASS_DEVICE_3D         = 4	     ; unused
#BASS_DEVICE_16BITS     = 8      ; limit output To 16 bit
#BASS_DEVICE_REINIT     = 128    ; reinitialize
#BASS_DEVICE_LATENCY    = $100   ; unused
#BASS_DEVICE_CPSPEAKERS = $400   ; unused
#BASS_DEVICE_SPEAKERS   = $800   ; force enabling of speaker assignment
#BASS_DEVICE_NOSPEAKER  = $1000  ; ignore speaker arrangement
#BASS_DEVICE_DMIX       = $2000  ; use ALSA "dmix" plugin
#BASS_DEVICE_FREQ       = $4000  ; set device sample rate
#BASS_DEVICE_STEREO     = $8000  ; limit output To stereo
#BASS_DEVICE_HOG        = $10000 ; hog/exclusive mode
#BASS_DEVICE_AUDIOTRACK = $20000 ; use AudioTrack output
#BASS_DEVICE_DSOUND     = $40000 ; use DirectSound output
#BASS_DEVICE_SOFTWARE   = $80000 ; disable hardware/fastpath output

;- DirectSound interfaces (For use With BASS_GetDSoundObject)
#BASS_OBJECT_DS     = 1	; IDirectSound
#BASS_OBJECT_DS3DL	= 2	; IDirectSound3DListener

;- Device info structure
Structure BASS_DEVICEINFO Align #PB_Structure_AlignC
	*name   ;description
	*driver ;driver
	flags.l
EndStructure

;- BASS_DEVICEINFO flags
#BASS_DEVICE_ENABLED  = 1
#BASS_DEVICE_DEFAULT  = 2
#BASS_DEVICE_INIT     = 4
#BASS_DEVICE_LOOPBACK = 8
#BASS_DEVICE_DEFAULTCOM = 128

#BASS_DEVICE_TYPE_MASK = $FF000000
#BASS_DEVICE_TYPE_NETWORK = $01000000
#BASS_DEVICE_TYPE_SPEAKERS = $02000000
#BASS_DEVICE_TYPE_LINE = $03000000
#BASS_DEVICE_TYPE_HEADPHONES = $04000000
#BASS_DEVICE_TYPE_MICROPHONE = $05000000
#BASS_DEVICE_TYPE_HEADSET = $06000000
#BASS_DEVICE_TYPE_HANDSET = $07000000
#BASS_DEVICE_TYPE_DIGITAL = $08000000
#BASS_DEVICE_TYPE_SPDIF = $09000000
#BASS_DEVICE_TYPE_HDMI = $0A000000
#BASS_DEVICE_TYPE_DISPLAYPORT = $40000000

;- BASS_GetDeviceInfo flags
#BASS_DEVICES_AIRPLAY = $1000000

Structure BASS_INFO
	flags.l     ; device capabilities (DSCAPS_xxx flags)
	hwsize.l    ; unused
	hwfree.l    ; unused
	freesam.l   ; unused
	free3d.l    ; unused
	minrate.l   ; unused
	maxrate.l   ; unused
	eax.l       ; unused
	minbuf.l    ; recommended minimum buffer length in ms (requires BASS_DEVICE_LATENCY)
	dsver.l     ; DirectSound version
	latency.l   ; average delay (in ms) before start of playback (requires BASS_DEVICE_LATENCY)
	initflags.l ; BASS_Init "flags" parameter
	speakers.l  ; number of speakers available
	freq.l      ; current output rate (Vista/OSX only)
EndStructure

;- BASS_INFO flags (from DSOUND.H)
#DSCAPS_EMULDRIVER      = $00000020 ; device does not have hardware DirectSound support
#DSCAPS_CERTIFIED       = $00000040 ; device driver has been certified by Microsoft

#DSCAPS_HARDWARE        = $80000000 ; hardware mixed

;- Recording device info Structure
Structure BASS_RECORDINFO
	flags.l    ;device capabilities (DSCCAPS_xxx flags)
	formats.l  ;supported standard formats (WAVE_FORMAT_xxx flags)
	inputs.l   ;number of inputs
	singlein.l ;TRUE = only 1 input can be set at a time
	freq.l     ;current input rate (Vista/OSX only)
EndStructure

;- BASS_RECORDINFO flags (from DSOUND.H)
#DSCCAPS_EMULDRIVER = #DSCAPS_EMULDRIVER	;device does not have hardware DirectSound recording support
#DSCCAPS_CERTIFIED  = #DSCAPS_CERTIFIED	 ;device driver has been certified by Microsoft

;- defines for formats field of BASS_RECORDINFO (from MMSYSTEM.H)
#WAVE_FORMAT_1M08 =$00000001 ;11.025 kHz, Mono,   8-bit
#WAVE_FORMAT_1S08 =$00000002 ;11.025 kHz, Stereo, 8-bit
#WAVE_FORMAT_1M16 =$00000004 ;11.025 kHz, Mono,   16-bit
#WAVE_FORMAT_1S16 =$00000008 ;11.025 kHz, Stereo, 16-bit
#WAVE_FORMAT_2M08 =$00000010 ;22.05  kHz, Mono,   8-bit
#WAVE_FORMAT_2S08 =$00000020 ;22.05  kHz, Stereo, 8-bit
#WAVE_FORMAT_2M16 =$00000040 ;22.05  kHz, Mono,   16-bit
#WAVE_FORMAT_2S16 =$00000080 ;22.05  kHz, Stereo, 16-bit
#WAVE_FORMAT_4M08 =$00000100 ;44.1   kHz, Mono,   8-bit
#WAVE_FORMAT_4S08 =$00000200 ;44.1   kHz, Stereo, 8-bit
#WAVE_FORMAT_4M16 =$00000400 ;44.1   kHz, Mono,   16-bit
#WAVE_FORMAT_4S16 =$00000800 ;44.1   kHz, Stereo, 16-bit

;- Sample info structure
Structure BASS_SAMPLE
	freq.l     ; default playback rate
	volume.f   ; default volume (0-1)
	pan.f      ; default pan (-1=left, 0=middle, 1=right)
	flags.l    ; BASS_SAMPLE_xxx flags
	length.l   ; length (in bytes)
	max.l      ; maximum simultaneous playbacks
	origres.l  ; original resolution
	chans.l    ; number of channels
	mingap.l   ; minimum gap (ms) between creating channels
	mode3d.l   ; BASS_3DMODE_xxx mode
	mindist.f  ; minimum distance
	maxdist.f  ; maximum distance
	iangle.l   ; angle of inside projection cone
	oangle.l   ; angle of outside projection cone
	outvol.f   ; delta-volume outside the projection cone
	vam.l      ; unused
	priority.l ; unused
EndStructure

;- SAMPLE flags
#BASS_SAMPLE_8BITS     = 1      ; 8 bit
#BASS_SAMPLE_FLOAT     = 256    ; 32-bit floating-point
#BASS_SAMPLE_MONO      = 2      ; mono
#BASS_SAMPLE_LOOP      = 4      ; looped
#BASS_SAMPLE_3D        = 8      ; 3D functionality
#BASS_SAMPLE_SOFTWARE  = 16     ; unused
#BASS_SAMPLE_MUTEMAX   = 32     ; mute at max distance (3D only)
#BASS_SAMPLE_VAM       = 64     ; unused
#BASS_SAMPLE_FX        = 128    ; unused
#BASS_SAMPLE_OVER_VOL  = $10000 ; override lowest volume
#BASS_SAMPLE_OVER_POS  = $20000 ; override longest playing
#BASS_SAMPLE_OVER_DIST = $30000 ; override furthest from listener (3D only)

;- STREAM flags
#BASS_STREAM_PRESCAN  = $20000  ; scan file for accurate seeking and length
#BASS_STREAM_AUTOFREE = $40000  ; automatically free the stream when it stops/ends
#BASS_STREAM_RESTRATE = $80000  ; restrict the download rate of internet file stream
#BASS_STREAM_BLOCK    = $100000 ; download/play internet file stream in small blocks
#BASS_STREAM_DECODE   = $200000 ; don't play the stream, only decode (BASS_ChannelGetData)
#BASS_STREAM_STATUS   = $800000 ; give server status info (HTTP/ICY tags) in DOWNLOADPROC

#BASS_MP3_IGNOREDELAY = $200    ; ignore LAME/Xing/VBRI/iTunes delay & padding info
#BASS_MP3_SETPOS      = #BASS_STREAM_PRESCAN

;- MUSIC flags
#BASS_MUSIC_FLOAT      = #BASS_SAMPLE_FLOAT
#BASS_MUSIC_MONO       = #BASS_SAMPLE_MONO
#BASS_MUSIC_LOOP       = #BASS_SAMPLE_LOOP
#BASS_MUSIC_3D         = #BASS_SAMPLE_3D
#BASS_MUSIC_FX         = #BASS_SAMPLE_FX
#BASS_MUSIC_AUTOFREE   = #BASS_STREAM_AUTOFREE
#BASS_MUSIC_DECODE     = #BASS_STREAM_DECODE
#BASS_MUSIC_PRESCAN    = #BASS_STREAM_PRESCAN ;calculate playback length
#BASS_MUSIC_CALCLEN    = #BASS_MUSIC_PRESCAN
#BASS_MUSIC_RAMP       = $200 ;normal ramping
#BASS_MUSIC_RAMPS      = $400 ;sensitive ramping
#BASS_MUSIC_SURROUND   = $800 ;surround sound
#BASS_MUSIC_SURROUND2  = $1000 ;surround sound (mode 2)
#BASS_MUSIC_FT2PAN     = $2000 ;apply FastTracker 2 panning To XM files
#BASS_MUSIC_FT2MOD     = $2000 ;play .MOD as FastTracker 2 does
#BASS_MUSIC_PT1MOD     = $4000 ;play .MOD as ProTracker 1 does
#BASS_MUSIC_NONINTER   = $10000 ;non-interpolated sample mixing
#BASS_MUSIC_SINCINTER  = $800000 ;sinc interpolated sample mixing
#BASS_MUSIC_POSRESET   = $8000 ;stop all notes when moving position
#BASS_MUSIC_POSRESETEX = $400000 ;stop all notes and reset bmp/etc when moving position
#BASS_MUSIC_STOPBACK   = $80000 ;stop the music on a backwards jump effect
#BASS_MUSIC_NOSAMPLE   = $100000 ;don't load the samples

;- SPEAKER assignment flags
#BASS_SPEAKER_FRONT      = $1000000 ; front speakers
#BASS_SPEAKER_REAR       = $2000000 ; rear speakers
#BASS_SPEAKER_CENLFE     = $3000000 ; center & LFE speakers (5.1)
#BASS_SPEAKER_SIDE       = $4000000	; side speakers (7.1)
Macro BASS_SPEAKER_N(n) : (n<<24) : EndMacro ; n'th pair of speakers (max 15)
#BASS_SPEAKER_LEFT       = $10000000 ; modifier: left
#BASS_SPEAKER_RIGHT      = $20000000 ;modifier: right
#BASS_SPEAKER_FRONTLEFT  = #BASS_SPEAKER_FRONT|#BASS_SPEAKER_LEFT
#BASS_SPEAKER_FRONTRIGHT = #BASS_SPEAKER_FRONT|#BASS_SPEAKER_RIGHT
#BASS_SPEAKER_REARLEFT   = #BASS_SPEAKER_REAR|#BASS_SPEAKER_LEFT
#BASS_SPEAKER_REARRIGHT  = #BASS_SPEAKER_REAR|#BASS_SPEAKER_RIGHT
#BASS_SPEAKER_CENTER     = #BASS_SPEAKER_CENLFE|#BASS_SPEAKER_LEFT
#BASS_SPEAKER_LFE        = #BASS_SPEAKER_CENLFE|#BASS_SPEAKER_RIGHT
#BASS_SPEAKER_SIDELEFT   = #BASS_SPEAKER_SIDE|#BASS_SPEAKER_LEFT
#BASS_SPEAKER_SIDERIGHT  = #BASS_SPEAKER_SIDE|#BASS_SPEAKER_RIGHT
#BASS_SPEAKER_REAR2      = #BASS_SPEAKER_SIDE
#BASS_SPEAKER_REAR2LEFT  = #BASS_SPEAKER_SIDELEFT
#BASS_SPEAKER_REAR2RIGHT = #BASS_SPEAKER_SIDERIGHT

#BASS_ASYNCFILE = $40000000 ; read file asynchronously
#BASS_UNICODE   = $80000000 ; UTF-16

#BASS_RECORD_ECHOCANCEL = $2000
#BASS_RECORD_AGC        = $4000
#BASS_RECORD_PAUSE      = $8000 ; start recording paused

;- DX7 voice allocation & management flags
#BASS_VAM_HARDWARE  = 1
#BASS_VAM_SOFTWARE  = 2
#BASS_VAM_TERM_TIME = 4
#BASS_VAM_TERM_DIST = 8
#BASS_VAM_TERM_PRIO	= 16

;- BASS Structures
Structure BASS_CHANNELINFO Align #PB_Structure_AlignC
	freq.l 	    ; default playback rate
	chans.l     ; channels
	flags.l
	ctype.l     ; type of channel
	origres.l   ; original resolution
	plugin.l
	sample.l
 *filename
EndStructure

#BASS_ORIGRES_FLOAT = $10000

;- BASS_CHANNELINFO types
#BASS_CTYPE_SAMPLE		       = 1
#BASS_CTYPE_RECORD		       = 2
#BASS_CTYPE_STREAM		       = $10000
#BASS_CTYPE_STREAM_VORBIS    = $10002
#BASS_CTYPE_STREAM_OGG	     = $10002
#BASS_CTYPE_STREAM_MP1	     = $10003
#BASS_CTYPE_STREAM_MP2	     = $10004
#BASS_CTYPE_STREAM_MP3	     = $10005
#BASS_CTYPE_STREAM_AIFF	     = $10006
#BASS_CTYPE_STREAM_CA        = $10007
#BASS_CTYPE_STREAM_MF        = $10008
#BASS_CTYPE_STREAM_AM        = $10009
#BASS_CTYPE_STREAM_SAMPLE    = $1000A
#BASS_CTYPE_STREAM_DUMMY     = $18000
#BASS_CTYPE_STREAM_DEVICE    = $18001
#BASS_CTYPE_STREAM_WAV	     = $40000 ; WAVE flag (LOWORD=codec)
#BASS_CTYPE_STREAM_WAV_PCM	 = $50001
#BASS_CTYPE_STREAM_WAV_FLOAT = $50003
#BASS_CTYPE_MUSIC_MOD	       = $20000
#BASS_CTYPE_MUSIC_MTM	       = $20001
#BASS_CTYPE_MUSIC_S3M	       = $20002
#BASS_CTYPE_MUSIC_XM		     = $20003
#BASS_CTYPE_MUSIC_IT		     = $20004
#BASS_CTYPE_MUSIC_MO3	       = $00100 ; MO3 flag

; BASS_PluginLoad flags
#BASS_PLUGIN_PROC = 1

Structure BASS_PLUGINFORM Align #PB_Structure_AlignC
	ctype.l ; channel type
	*name   ; format description
	*exts   ; file extension filter (*.ext1;*.ext2;etc...)
EndStructure

Structure BASS_PLUGININFO Align #PB_Structure_AlignC
	version.l ; version (same form as BASS_GetVersion)
	formatc.l ; number of formats
	*formats.BASS_PLUGINFORM ; the array of formats
EndStructure

;- 3D vector (For 3D positions/velocities/orientations)
Structure BASS_3DVECTOR
	X.f ; +=right, -=left
	Y.f ; +=up, -=down
	z.f ; +=front, -=behind
EndStructure

;- 3D channel modes
#BASS_3DMODE_NORMAL   = 0 ;normal 3D processing
#BASS_3DMODE_RELATIVE = 1 ;position is relative to the listener
#BASS_3DMODE_OFF      = 2 ;no 3D processing

;- software 3D mixing algorithms (used With BASS_CONFIG_3DALGORITHM)
#BASS_3DALG_DEFAULT = 0
#BASS_3DALG_OFF     = 1
#BASS_3DALG_FULL    = 2
#BASS_3DALG_LIGHT   = 3

;- BASS_SampleGetChannel flags
#BASS_SAMCHAN_NEW     = 1 ; get a new playback channel
#BASS_SAMCHAN_STREAM  = 2 ; create a stream

;typedef DWORD (CALLBACK STREAMPROC)(HSTREAM handle, void *buffer, DWORD length, void *user);
; User stream callback function.
;handle : The stream that needs writing
;buffer : Buffer to write the samples in
;length : Number of bytes to write
;user   : The 'user' parameter value given when calling BASS_StreamCreate
;RETURN : Number of bytes written. Set the BASS_STREAMPROC_END flag to end the stream.

#BASS_STREAMPROC_END	=$80000000	;end of user stream flag

;- Special STREAMPROCs
#STREAMPROC_DUMMY     =  0  ; "dummy" stream
#STREAMPROC_PUSH      = -1  ; push stream
#STREAMPROC_DEVICE    = -2  ; device mix stream
#STREAMPROC_DEVICE_3D = -3  ; device 3D mix stream

;- BASS_StreamCreateFileUser file systems
#STREAMFILE_NOBUFFER		= 0
#STREAMFILE_BUFFER		  = 1
#STREAMFILE_BUFFERPUSH	= 2

;- User file stream callback functions
;typedef void (CALLBACK FILECLOSEPROC)(void *user);
;typedef QWORD (CALLBACK FILELENPROC)(void *user);
;typedef DWORD (CALLBACK FILEREADPROC)(void *buffer, DWORD length, void *user);
;typedef BOOL (CALLBACK FILESEEKPROC)(QWORD offset, void *user);

Structure BASS_FILEPROCS
	*close
	*length
	*read
	*seek
EndStructure

;- BASS_StreamPutFileData options
#BASS_FILEDATA_END = 0	; end & close the file

;- BASS_StreamGetFilePosition modes
#BASS_FILEPOS_CURRENT     = 0
#BASS_FILEPOS_DECODE      = #BASS_FILEPOS_CURRENT
#BASS_FILEPOS_DOWNLOAD    = 1
#BASS_FILEPOS_END         = 2
#BASS_FILEPOS_START       = 3
#BASS_FILEPOS_CONNECTED   = 4
#BASS_FILEPOS_BUFFER      = 5
#BASS_FILEPOS_SOCKET      = 6
#BASS_FILEPOS_ASYNCBUF    = 7
#BASS_FILEPOS_SIZE        = 8
#BASS_FILEPOS_BUFFERING   = 9
#BASS_FILEPOS_AVAILABLE   = 10

;typedef void (CALLBACK DOWNLOADPROC)(const void *buffer, DWORD length, void *user);
;/* Internet stream download callback function.
;buffer : Buffer containing the downloaded data... NULL=end of download
;length : Number of bytes in the buffer
;user   : The 'user' parameter value given when calling BASS_StreamCreateURL */

;- BASS_ChannelSetSync types
#BASS_SYNC_POS        = 0
#BASS_SYNC_END        = 2
#BASS_SYNC_META       = 4
#BASS_SYNC_SLIDE      = 5
#BASS_SYNC_STALL      = 6
#BASS_SYNC_DOWNLOAD   = 7
#BASS_SYNC_FREE       = 8
#BASS_SYNC_SETPOS     = 11
#BASS_SYNC_MUSICPOS   = 10
#BASS_SYNC_MUSICINST  = 1
#BASS_SYNC_MUSICFX    = 3
#BASS_SYNC_OGG_CHANGE = 12
#BASS_SYNC_DEV_FAIL   = 14
#BASS_SYNC_DEV_FORMAT = 15
#BASS_SYNC_THREAD     = $20000000	; flag: call sync in other thread
#BASS_SYNC_MIXTIME    = $40000000	; flag: sync at mixtime, else at playtime
#BASS_SYNC_ONETIME    = $80000000	; flag: sync only once, else continuously

;typedef void (CALLBACK SYNCPROC)(HSYNC handle, DWORD channel, DWORD data, void *user);
;Sync callback function.
;handle : The sync that has occured
;channel: Channel that the sync occured in
;data   : Additional data associated with the sync's occurance
;user   : The 'user' parameter given when calling BASS_ChannelSetSync

;typedef void (CALLBACK DSPPROC)(HDSP handle, DWORD channel, void *buffer, DWORD length, void *user);
;DSP callback function.
;handle : The DSP handle
;channel: Channel that the DSP is being applied to
;buffer : Buffer to apply the DSP to
;length : Number of bytes in the buffer
;user   : The 'user' parameter given when calling BASS_ChannelSetDSP

;typedef BOOL (CALLBACK RECORDPROC)(HRECORD handle, const void *buffer, DWORD length, void *user);
;Recording callback function.
;handle : The recording handle
;buffer : Buffer containing the recorded sample data
;length : Number of bytes
;user   : The 'user' parameter value given when calling BASS_RecordStart
;RETURN : TRUE = continue recording, FALSE = stop

;- BASS_ChannelIsActive Return values
#BASS_ACTIVE_STOPPED        = 0
#BASS_ACTIVE_PLAYING        = 1
#BASS_ACTIVE_STALLED        = 2
#BASS_ACTIVE_PAUSED         = 3
#BASS_ACTIVE_PAUSED_DEVICE  = 4
 
;- Channel attributes
#BASS_ATTRIB_FREQ             = 1
#BASS_ATTRIB_VOL              = 2
#BASS_ATTRIB_PAN              = 3
#BASS_ATTRIB_EAXMIX           = 4
#BASS_ATTRIB_NOBUFFER         = 5
#BASS_ATTRIB_VBR              = 6
#BASS_ATTRIB_CPU              = 7
#BASS_ATTRIB_SRC              = 8
#BASS_ATTRIB_NET_RESUME       = 9
#BASS_ATTRIB_SCANINFO         = 10
#BASS_ATTRIB_NORAMP           = 11
#BASS_ATTRIB_BITRATE          = 12
#BASS_ATTRIB_BUFFER           = 13
#BASS_ATTRIB_GRANULE          = 14
#BASS_ATTRIB_USER             = 15
#BASS_ATTRIB_TAIL             = 16
#BASS_ATTRIB_PUSH_LIMIT       = 17
#BASS_ATTRIB_DOWNLOADPROC     = 18
#BASS_ATTRIB_VOLDSP           = 19
#BASS_ATTRIB_VOLDSP_PRIORITY  = 20
#BASS_ATTRIB_MUSIC_AMPLIFY    = $100
#BASS_ATTRIB_MUSIC_PANSEP     = $101
#BASS_ATTRIB_MUSIC_PSCALER    = $102
#BASS_ATTRIB_MUSIC_BPM        = $103
#BASS_ATTRIB_MUSIC_SPEED      = $104
#BASS_ATTRIB_MUSIC_VOL_GLOBAL = $105
#BASS_ATTRIB_MUSIC_ACTIVE     = $106
#BASS_ATTRIB_MUSIC_VOL_CHAN   = $200 ;+ channel #
#BASS_ATTRIB_MUSIC_VOL_INST   = $300 ;+ instrument #

;- BASS_ChannelSlideAttribute flags
#BASS_SLIDE_LOG = $1000000

;- BASS_ChannelGetData flags
#BASS_DATA_AVAILABL       = 0         ; query how much data is buffered
#BASS_DATA_NOREMOVE       = $10000000 ; flag: don't remove data from recording buffer
#BASS_DATA_FIXED          = $20000000 ; unused
#BASS_DATA_FLOAT          = $40000000 ; flag: return floating-point sample data
#BASS_DATA_FFT256         = $80000000 ; 256 sample FFT
#BASS_DATA_FFT512         = $80000001 ; 512 FFT
#BASS_DATA_FFT1024        = $80000002 ; 1024 FFT
#BASS_DATA_FFT2048        = $80000003 ; 2048 FFT
#BASS_DATA_FFT4096        = $80000004 ; 4096 FFT
#BASS_DATA_FFT8192        = $80000005 ; 8192 FFT
#BASS_DATA_FFT16384       = $80000006 ; 16384 FFT
#BASS_DATA_FFT32768       = $80000007 ; 32768 FFT
#BASS_DATA_FFT_INDIVIDUAL = $10       ; FFT flag: FFT for each channel, else all combined
#BASS_DATA_FFT_NOWINDOW   = $20       ; FFT flag: no Hanning window
#BASS_DATA_FFT_REMOVEDC   = $40       ; FFT flag: pre-remove DC bias
#BASS_DATA_FFT_COMPLEX    = $80       ; FFT flag: return complex data
#BASS_DATA_FFT_NYQUIST    = $100      ; FFT flag: return extra Nyquist value

;- BASS_ChannelGetLevelEx flags
#BASS_LEVEL_MONO    = 1 ; get mono level
#BASS_LEVEL_STEREO  = 2 ; get stereo level
#BASS_LEVEL_RMS     = 4 ; get RMS levels
#BASS_LEVEL_VOLPAN  = 8 ; apply VOL/PAN attributes to the levels
#BASS_LEVEL_NOREMOVE = 16 ; don't remove data from recording buffer

;- BASS_ChannelGetTags types : what's returned
#BASS_TAG_ID3 = 0                 ; ID3v1 tags : TAG_ID3 structure
#BASS_TAG_ID3V2 = 1               ; ID3v2 tags : variable length block
#BASS_TAG_OGG = 2                 ; OGG comments : series of null-terminated UTF-8 strings
#BASS_TAG_HTTP = 3                ; HTTP headers : series of null-terminated ASCII strings
#BASS_TAG_ICY = 4                 ; ICY headers : series of null-terminated ANSI strings
#BASS_TAG_META = 5                ; ICY metadata : ANSI string
#BASS_TAG_APE = 6                 ; APEv2 tags : series of null-terminated UTF-8 strings
#BASS_TAG_MP4 = 7                 ; MP4/iTunes metadata : series of null-terminated UTF-8 strings
#BASS_TAG_WMA = 8                 ; WMA tags : series of null-terminated UTF-8 strings
#BASS_TAG_VENDOR = 9              ; OGG encoder : UTF-8 string
#BASS_TAG_LYRICS3 = 10            ; Lyric3v2 tag : ASCII string
#BASS_TAG_CA_CODEC = 11           ; CoreAudio codec info : TAG_CA_CODEC structure
#BASS_TAG_MF = 13                 ; Media Foundation tags : series of null-terminated UTF-8 strings
#BASS_TAG_WAVEFORMAT = 14         ; WAVE format : WAVEFORMATEEX structure
#BASS_TAG_AM_NAME = 16            ; Android Media codec name : ASCII string
#BASS_TAG_ID3V2_2 = 17            ; ID3v2 tags (2nd block) : variable length block
#BASS_TAG_AM_MIME = 18	          ; Android Media MIME type : ASCII string
#BASS_TAG_LOCATION = 19	          ; redirected URL : ASCII string
#BASS_TAG_RIFF_INFO = $100        ; RIFF "INFO" tags : series of null-terminated ANSI strings
#BASS_TAG_RIFF_BEXT = $101        ; RIFF/BWF "bext" tags : TAG_BEXT structure
#BASS_TAG_RIFF_CART = $102        ; RIFF/BWF "cart" tags : TAG_CART structure
#BASS_TAG_RIFF_DISP = $103        ; RIFF "DISP" text tag : ANSI string
#BASS_TAG_RIFF_CUE  = $104        ; RIFF "cue " chunk : TAG_CUE Structure
#BASS_TAG_RIFF_SMPL = $105        ; RIFF "smpl" chunk : TAG_SMPL Structure
#BASS_TAG_APE_BINARY = $1000      ; + index #, binary APEv2 tag : TAG_APE_BINARY structure
#BASS_TAG_MUSIC_NAME = $10000     ; MOD music name : ANSI string
#BASS_TAG_MUSIC_MESSAGE = $10001  ; MOD message : ANSI string
#BASS_TAG_MUSIC_ORDERS = $10002   ; MOD order list : BYTE array of pattern numbers
#BASS_TAG_MUSIC_AUTH  = $10003    ; MOD author : UTF-8 string
#BASS_TAG_MUSIC_INST = $10100     ; + instrument #, MOD instrument name : ANSI string
#BASS_TAG_MUSIC_CHAN = $10200     ; + channel #, MOD channel name : ANSI string
#BASS_TAG_MUSIC_SAMPLE = $10300 ; + sample #, MOD sample name : ANSI string

;- BASS_ChannelGetLength/GetPosition/SetPosition modes
#BASS_POS_BYTE        = 0         ; byte position
#BASS_POS_MUSIC_ORDER = 1         ; order.row position, MAKELONG(order,row)
#BASS_POS_OGG         = 3         ; OGG bitstream number
#BASS_POS_END         = $10       ; trimmed end position
#BASS_POS_LOOP        = $11       ; loop start positiom
#BASS_POS_FLUSH       = $1000000  ; flag: flush decoder/FX buffers
#BASS_POS_RESET       = $2000000  ; flag: reset user file buffers
#BASS_POS_RELATIVE    = $4000000  ; flag: seek relative To the current position
#BASS_POS_INEXACT     = $8000000  ; flag: allow seeking to inexact position
#BASS_POS_DECODE      = $10000000 ; flag: get the decoding (not playing) position
#BASS_POS_DECODEETC   = $20000000 ; flag: decode to the position instead of seeking
#BASS_POS_SCAN        = $40000000 ; flag: scan to the position

;- BASS_ChannelSetDevice/GetDevice option
#BASS_NODEVICE  = $20000

;- BASS_RecordSetInput flags
#BASS_INPUT_OFF = $10000
#BASS_INPUT_ON  = $20000

#BASS_INPUT_TYPE_MASK     = $FF000000
#BASS_INPUT_TYPE_UNDEF    = $00000000
#BASS_INPUT_TYPE_DIGITAL  = $01000000
#BASS_INPUT_TYPE_LINE     = $02000000
#BASS_INPUT_TYPE_MIC      = $03000000
#BASS_INPUT_TYPE_SYNTH    = $04000000
#BASS_INPUT_TYPE_CD       = $05000000
#BASS_INPUT_TYPE_PHONE    = $06000000
#BASS_INPUT_TYPE_SPEAKER  = $07000000
#BASS_INPUT_TYPE_WAVE     = $08000000
#BASS_INPUT_TYPE_AUX      = $09000000
#BASS_INPUT_TYPE_ANALOG   = $0A000000

;- BASS_ChannelSetFX effect types
#BASS_FX_DX8_CHORUS       = 0
#BASS_FX_DX8_COMPRESSOR   = 1
#BASS_FX_DX8_DISTORTION   = 2
#BASS_FX_DX8_ECHO         = 3
#BASS_FX_DX8_FLANGER      = 4
#BASS_FX_DX8_GARGLE       = 5
#BASS_FX_DX8_I3DL2REVERB  = 6
#BASS_FX_DX8_PARAMEQ      = 7
#BASS_FX_DX8_REVERB       = 8
#BASS_FX_VOLUME           = 9

Structure BASS_DX8_CHORUS
 fWetDryMix.f
 fDepth.f
 fFeedback.f
 fFrequency.f
 lWaveform.l  ;0=triangle, 1=sine
 fDelay.f
 lPhase.l     ;BASS_DX8_PHASE_xxx
EndStructure

Structure BASS_DX8_COMPRESSOR
 fGain.f
 fAttack.f
 fRelease.f
 fThreshold.f
 fRatio.f
 fPredelay.f
EndStructure

Structure BASS_DX8_DISTORTION
 fGain.f
 fEdge.f
 fPostEQCenterFrequency.f
 fPostEQBandwidth.f
 fPreLowpassCutoff.f
EndStructure

Structure BASS_DX8_ECHO
 fWetDryMix.f
 fFeedback.f
 fLeftDelay.f
 fRightDelay.f
 lPanDelay.l
EndStructure

Structure BASS_DX8_FLANGER
 fWetDryMix.f
 fDepth.f
 fFeedback.f
 fFrequency.f
 lWaveform.l	;0=triangle, 1=sine
 fDelay.f
 lPhase.l		  ;BASS_DX8_PHASE_xxx
EndStructure

Structure BASS_DX8_GARGLE
 dwRateHz.l    ;Rate of modulation in hz
 dwWaveShape.l ;0=triangle, 1=square
EndStructure

Structure BASS_DX8_I3DL2REVERB
 lRoom.l               ; [-10000, 0]      default: -1000 mB
 lRoomHF.l             ; [-10000, 0]      default: 0 mB
 flRoomRolloffFactor.f ;[0.0, 10.0]      default: 0.0
 flDecayTime.f         ;[0.1, 20.0]      default: 1.49s
 flDecayHFRatio.f      ;[0.1, 2.0]       default: 0.83
 lReflections.l        ; [-10000, 1000]   default: -2602 mB
 flReflectionsDelay.f  ;[0.0, 0.3]       default: 0.007 s
 lReverb.l             ; [-10000, 2000]   default: 200 mB
 flReverbDelay.f       ;[0.0, 0.1]       default: 0.011 s
 flDiffusion.f         ;[0.0, 100.0]     default: 100.0 %
 flDensity.f           ;[0.0, 100.0]     default: 100.0 %
 flHFReference.f       ;[20.0, 20000.0]  default: 5000.0 Hz
EndStructure

Structure BASS_DX8_PARAMEQ
 fCenter.f
 fBandwidth.f
 fGain.f
EndStructure

Structure BASS_DX8_REVERB
 fInGain.f          ; [-96.0,0.0]            default: 0.0 dB
 fReverbMix.f       ; [-96.0,0.0]            default: 0.0 db
 fReverbTime.f      ;[0.001,3000.0]         default: 1000.0 ms
 fHighFreqRTRatio.f ;[0.001,0.999]          default: 0.001
EndStructure

#BASS_DX8_PHASE_NEG_180 =0
#BASS_DX8_PHASE_NEG_90  =1
#BASS_DX8_PHASE_ZERO    =2
#BASS_DX8_PHASE_90      =3
#BASS_DX8_PHASE_180     =4

; typedef void (CALLBACK IOSNOTIFYPROC)(DWORD status);
; /* iOS notification callback function.
; status : The notification (BASS_IOSNOTIFY_xxx) */

#BASS_IOSNOTIFY_INTERRUPT = 1     ; interruption started
#BASS_IOSNOTIFY_INTERRUPT_END = 2 ; interruption ended

;- BASS Functions

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\bass.lib"
CompilerElse
  Import "libs_x86\bass.lib"
CompilerEndIf
 BASS_SetConfig.l(option.l,value.l)
 BASS_GetConfig.l(option.l)
 BASS_SetConfigPtr.l(option.l,value$)
 BASS_GetConfigPtr.l(option.l)
 BASS_GetVersion.l()
 BASS_ErrorGetCode.l()
 BASS_GetDeviceInfo.l(device.l,*info.BASS_DEVICEINFO)
 BASS_Init.l(device.l,freq.l,flags.l,win.l,*dsguid)
 BASS_Free.l()
 BASS_SetDevice.l(device.l)
 BASS_GetDevice.l()
 BASS_GetInfo.l(*info)
 BASS_Start.l()
 BASS_Stop.l()
 BASS_Pause.l()
 BASS_IsStarted.l()
 BASS_Update.l(length.l)
 BASS_GetCPU.f()
 BASS_SetVolume.l(volume.f)
 BASS_GetVolume.f()
 BASS_GetDSoundObject.l(Object.l)
 BASS_Set3DFactors.l(distf.f,rollf.f,doppf.f)
 BASS_Get3DFactors.l(*distf,*rollf,*doppf)
 BASS_Set3DPosition.l(*pos.BASS_3DVECTOR,*vel.BASS_3DVECTOR,*front.BASS_3DVECTOR,*top.BASS_3DVECTOR)
 BASS_Get3DPosition.l(*pos.BASS_3DVECTOR,*vel.BASS_3DVECTOR,*front.BASS_3DVECTOR,*top.BASS_3DVECTOR)
 BASS_Apply3D.l()
 BASS_PluginLoad.i(File$,flags.l)
 BASS_PluginFree.i(Handle.l)
 BASS_PluginEnable.i(Handle.l,enable.l)
 BASS_PluginGetInfo.i(Handle.l)
 BASS_SampleLoad.l(mem.l,*file,offset.q,length.l,max.l,flags.l)
 BASS_SampleCreate.l(length.l,freq.l,chans.l,max.l,flags.l)
 BASS_SampleFree.l(Handle.l)
 BASS_SampleSetData.l(Handle.l,*buffer)
 BASS_SampleGetData.l(Handle.l,*buffer)
 BASS_SampleGetInfo.l(Handle.l,*info.BASS_SAMPLE)
 BASS_SampleSetInfo.l(Handle.l,*info.BASS_SAMPLE)
 BASS_SampleGetChannel.l(Handle.l,flags.l)
 BASS_SampleGetChannels.l(Handle.l,*channels)
 BASS_SampleStop.l(Handle.l)
 BASS_StreamCreate.l(freq.l,chans.l,flags.l,*proc,*user)
 BASS_StreamCreateFile.l(mem.l,*file,offset.q,length.q,flags.l)
 BASS_StreamCreateURL.l(url.p-ascii,offset.l,flags.l,*proc,*user)
 BASS_StreamCreateFileUser.l(system.l,flags.l,*proc,*user)
 BASS_StreamFree.l(Handle.l)
 BASS_StreamGetFilePosition.q(Handle.l,mode.l)
 BASS_StreamPutData.l(Handle.l,*buffer,length.l)
 BASS_StreamPutFileData.l(Handle.l,*buffer,length.l)
 BASS_MusicLoad.l(mem.l,*file,offset.q,length.l,flags.l,freq.l)
 BASS_MusicFree.l(Handle.l)
 BASS_RecordGetDeviceInfo.l(device.l,*info.BASS_DEVICEINFO)
 BASS_RecordInit.l(device.l)
 BASS_RecordFree.l()
 BASS_RecordSetDevice.l(device.l)
 BASS_RecordGetDevice.l()
 BASS_RecordGetInfo.l(*info.BASS_RECORDINFO)
 BASS_RecordGetInputName.l(input.l)
 BASS_RecordSetInput.l(input.l,flags.l,volume.f)
 BASS_RecordGetInput.l(input.l,*volume)
 BASS_RecordStart.l(freq.l,chans.l,flags.l,*proc,*user)
 BASS_ChannelBytes2Seconds.d(Handle.l,pos.q)
 BASS_ChannelSeconds2Bytes.q(Handle.l,pos.d)
 BASS_ChannelGetDevice.l(Handle.l)
 BASS_ChannelSetDevice.l(Handle.l,device.l)
 BASS_ChannelIsActive.l(Handle.l)
 BASS_ChannelGetInfo.l(Handle.l,*info.BASS_CHANNELINFO)
 BASS_ChannelGetTags.l(Handle.l,tags.l)
 BASS_ChannelFlags.l(Handle.l,flags.l,Mask.l)
 BASS_ChannelLock.l(Handle.l,lock.l)
 BASS_ChannelFree.l(Handle.l)
 BASS_ChannelPlay.l(Handle.l,restart.l)
 BASS_ChannelStart.l(Handle.l)
 BASS_ChannelStop.l(Handle.l)
 BASS_ChannelPause.l(Handle.l)
 BASS_ChannelUpdate.l(Handle.l,length.l)
 BASS_ChannelSetAttribute.l(Handle.l,attrib.l,value.f)
 BASS_ChannelGetAttribute.l(Handle.l,attrib.l,*value)
 BASS_ChannelSlideAttribute.l(Handle.l,attrib.l,value.f,time.l)
 BASS_ChannelIsSliding.l(Handle.l,attrib.l)
 BASS_ChannelSetAttributeEx.l(Handle.l,attrib.l,*value,size.l)
 BASS_ChannelGetAttributeEx.l(Handle.l,attrib.l,*value,size.l)
 BASS_ChannelSet3DAttributes.l(Handle.l,mode.l,min.f,max.f,iangle.l,oangle.l,outvol.f)
 BASS_ChannelGet3DAttributes.l(Handle.l,*mode,*min,*max,*iangle,*oangle,*outvol)
 BASS_ChannelSet3DPosition.l(Handle.l,*pos.BASS_3DVECTOR,*orient.BASS_3DVECTOR,*vel.BASS_3DVECTOR)
 BASS_ChannelGet3DPosition.l(Handle.l,*pos.BASS_3DVECTOR,*orient.BASS_3DVECTOR,*vel.BASS_3DVECTOR)
 BASS_ChannelGetLength.q(Handle.l,mode.l)
 BASS_ChannelSetPosition.l(Handle.l,pos.q,mode.l)
 BASS_ChannelGetPosition.q(Handle.l,mode.l)
 BASS_ChannelGetLevel.l(Handle.l)
 BASS_ChannelGetLevelEx.l(Handle.l,*levels,length.f,flags.l)
 BASS_ChannelGetData.l(Handle.l,*buffer,length.l)
 BASS_ChannelSetSync.l(Handle.l,Type.l,param.q,*proc,*user)
 BASS_ChannelRemoveSync.l(Handle.l,sync.l)
 BASS_ChannelSetLink.l(Handle.l,chan.l)
 BASS_ChannelRemoveLink.l(Handle.l,chan.l)
 BASS_ChannelSetDSP.l(Handle.l,*proc,*user,priority.l)
 BASS_ChannelRemoveDSP.l(Handle.l,dsp.l)
 BASS_ChannelSetFX.l(Handle.l,type.l,priority.l)
 BASS_ChannelRemoveFX.l(Handle.l,fx.l)
 BASS_FXSetParameters.l(Handle.l,*params)
 BASS_FXGetParameters.l(Handle.l,*params)
 BASS_FXSetPriority.l(handle.l,priority.l)
 BASS_FXReset.l(Handle.l)
EndImport

; EOF