; File: TopLevel.pbi

EnableExplicit

; INFO Issuing a New Release
; The procedure for issuing a new release is documented in "\Dropbox\SCS\Docs\SCS Release Procedure.docx"

; INFO SCS Title and Version info
#SCS_TITLE = "SCS 11"
#SCS_PROG_VERSION = "11.10.8"
#SCS_HELP_CONTENTS_ID = "contents_111008"   ; this must EXACTLY match the ID in the Properties of the "Help Contents" topic in the HelpSmith project "scs11_help".
; After setting the ID in the HelpSmith project, save and compile the CHM file so the next time SCS is generated (via Inno), the Help file ID will match the ID in the executable.

; INFO version extension (eg rc1, ab)
CompilerIf #cTutorialVideoOrScreenShots
  #SCS_PROG_VERSION_EXT = ""  ; do not show version extension on screenshots for the Help file, etc
CompilerElse
  ; #SCS_PROG_VERSION_EXT = ""
  ; #SCS_PROG_VERSION_EXT = "-b09"
  #SCS_PROG_VERSION_EXT = "bj"
CompilerEndIf

#c_huw_morgan = #False

; The 'database version' below ONLY needs to be changed if this version of SCS includes changes to the way in which data is saved in database tables.
; The constant is saved in database tables in the column 'DBVersion', and is used in SELECT statements to find rows that match the current value of this constant,
; so if you have changed this constant then those SELECT statements may return 'not found'. That is a valid result if the other values that would be returned are
; not compatible with the current version of SCS. Normally, this constant SHOULD NOT BE CHANGED.
#SCS_DATABASE_VERSION = 110700 ; Warning - please read the above before deciding to change this constant, as normally it should NOT be changed.

#c_include_tvg = #True
CompilerIf #c_include_tvg
  ; NOTE: if you change the version of the .pbi file here, then make the corresponding change to the Project File!
  ; #TVG_VERSION = "15.2.4.4" ; as at 11Oct2022 11.9.6at
  ; #TVG_VERSION = "15.2.5.4" ; as at 4Jun2023 11.10.0be
  ; #TVG_VERSION = "15.2.5.5" ; as at 21Jun2023 11.10.0b?
  ; #TVG_VERSION = "15.2.5.6" ; as at 2Jul2023 11.10.0bi
  ; #TVG_VERSION = "15.2.5.6A" ; as at 26Jul2023 11.10.0br
  ; #TVG_VERSION = "15.2.5.8" ; as at 13Dec2023 11.10.0dm
  ; #TVG_VERSION = "15.2.5.9" ; as at 19Dec2023 11.10.0dq
  ; #TVG_VERSION = "15.2.6.2" ; as at 15Mar2024 11.10.2bm
  ; #TVG_VERSION = "15.4.1.4" ; as at 25Jul2024 11.10.3au
  #TVG_VERSION = "15.4.1.8" ; as at 26Jul2024 11.10.3au
  ; #TVG_VERSION = "16.1.1.8" ; as at 15Apr2025 11.10.8az
  XIncludeFile "TVideoGrabber_" + #TVG_VERSION + ".pbi"
  Global gsTVGLicenseString.s = "759543126573379079702-26SCS"
CompilerEndIf

;- SCS File Extensions
; .scs    SCS 9/10 cue file (pre 10.8). Replaced by .scs11 in SCS 11 - see below.
; .scc    SCS 10 color scheme file. Replaced by .scsc in SCS 11 - see below.
; .tmp    SCS 10 recovery file (scsrecovery.tmp). Replaced by .scsr in SCS 11 - see below.
; .scsq   SCS 10.8/10.9 cue file. Replaced by .scs11 in SCS 11 - see below.
; .scs11  SCS 11 cue file
; .scsc   SCS 11 color scheme file (scs_colors.scsc)
; .scsd   SCS 11 device map file
; .scsdx  SCS 11 device map export file
; .scse   SCS 11 encoded files index (scs_encfileindex.scse)
; .scsr   SCS 11 recovery file (scsrecovery.scsr)
; .scst   SCS Tester (see SCSTestController.pb)
; .scstm  SCS 11 template file
; .scstd  SCS 11 template device map file
; .scsz   SCS 11 diagnostic file
; .scsdb  SCS 11 production database
; .scsl   SCS 11 language file
; .scsp   SCS 11 preferences file in user area (or in common area pre 11.6.0)
; .scscp  SCS 11 preferences file in common area (for reg info only)
; .scsrd  SCS 11 control send remote device file (scs_csrd.scsrd). The original for this file is in the source file folder (scs_v11_curr_development), and it is distributed with SCS - see files like "inno_scs11_x64.iss".

;- SCS Cue Types
; IMPORTANT: if adding a new cue type then add to populateCueTypeArray() and to #SCS_ALL_SUBTYPES
;  A  video/image/capture
;  E  memo
;  F  audio file
;  G  goto cue
;  H  multi-file cue (multiple audio files) (not yet implemented)
;  I  live input
;  J  enable/disable cues
;  K  lighting
;  L  level change
;  M  control send
;  N  note
;  P  playlist
;  Q  call cue
;  R  run external program
;  S  SFR (stop/fade-out/loop-release)
;  T  set position
;  U  MIDI time code (MTC) and Linear Time Code (LTC)

#SCS_DEMO_TIME = 60 ; 60-minute session time limit for demo version

#SCS_EMAIL_SUPPORT = "support@showcuesystems.com"

#SCS_FILE_VERSION = #SCS_PROG_VERSION ; #SCS_FILE_VERSION is stored in cue files, device map files, and in the Prefs file.

CompilerIf #cDemo
  ; INFO Demo Version
  #SCS_VERSION = #SCS_PROG_VERSION + " (Demo)"
CompilerElseIf #cWorkshop
  ; INFO Workshop Version
  #SCS_VERSION = #SCS_PROG_VERSION + " (Workshop)"
CompilerElse
    ; INFO Release Version
    #SCS_VERSION = #SCS_PROG_VERSION + #SCS_PROG_VERSION_EXT
CompilerEndIf

CompilerSelect #PB_Compiler_Processor
  CompilerCase #PB_Processor_x64
    #SCS_PROCESSOR = "x64"
  CompilerCase #PB_Processor_x86
    #SCS_PROCESSOR = "x86"
  CompilerDefault
    #SCS_PROCESSOR = Str(#PB_Compiler_Processor)
CompilerEndSelect

; INFO Tracing constants
; conditional compilation constants (sorted)
#cTraceAnalyzeWavFile               = #False
#cTraceAudFileRequester             = #False
#cTraceAuthString                   = #False
#cTraceCSRD                         = #False
#cTraceContainerGadgets             = #False ; includes container, panel and scrollarea gadgets - useful for identifying nested and parent containers
#cTraceCueMarkers                   = #False ; calls debug_AllCueMarkers() at various points
#cTraceDevMapBestMatch              = #False
#cTraceDMX                          = #False ; includes calls to FT_Write() 
#cTraceDMXChannelSet                = #False ; #True
#cTraceDMXFadeItemValues            = #False ; #True
#cTraceDMX_FTDI_ReceiveData         = #False ; #True
#cTraceDMX_FTDI_SendData            = #False
#cTraceDMXLoadChannelInfo           = #False ; traces DMX_loadDMXChannelItems() and DMX_loadDMXChannelItemsFI()
#cTraceDMXPrepareForSend            = #False
#cTraceDMXReceiveThread             = #False
#cTraceDMXSendChannels1to12         = #False ; #True      ; nb the #cTraceDMXSendChannels... constants are mutually exclusive - see Macro traceDMXChannelIfReqd()
#cTraceDMXSendChannels1to34         = #False
#cTraceDMXSendChannelsNonZero       = #False ; #True
#cTraceDMXSendThread                = #False
#cTraceDMXUpdatePackets             = #False ; #True
#cTraceFiltersEtc                   = #False
#cTraceFTCalls                      = #False
#cTraceGadgets                      = #False ; See also #cTraceContainerGadgets
#cTraceGetActiveWindow              = #False
#cTraceHTTP                         = #False
#cTraceKeyboardShortcuts            = #False
#cTraceMediaInfoInform              = #False
#cTraceMidiIn                       = #False
#cTraceMTCQuarterFramesReceived     = #False
#cTraceMTCReceive                   = #False
#cTraceMTCSend                      = #False
#cTraceNetworkMsgs                  = #False ; See also #c_hide_rai_input_tracing
#cTracePosition                     = #False
#cTraceRelFilePos                   = #False
#cTraceReqdPtrs                     = #False
#cTraceResizer                      = #False
#cTraceRunningInd                   = #False
#cTraceSetVisible                   = #False      ; see also #cTraceSetVisible_excl_WMN_WED (treat as mutually exclusive)
#cTraceSetVisible_excl_WMN_WED      = #False      ; see also #cTraceSetVisible (treat as mutually exclusive)
#cTraceSMSCurrInfo                  = #False
#cTraceSMSKey                       = #False
#cTraceSMSTrackTime                 = #False
#cTraceTVGCropping                  = #False
#cTraceX32Sends                     = #False

; drawing constants
#cTraceDrawing                      = #False
CompilerIf #cTraceDrawing = #False
  ; do not trace
  #cTraceAlphaBlend                   = #False      ; includes video fades
  #cTraceAlphaBlendFunctionCallsOnly  = #False      ; only relevant if #cTraceAlphaBlend = #True (ignores calculations leading up to the alpha blend function calls)
  #cTraceVidPicDisplay                = #False      ; used by debugMsgV()
  #cTraceVidPicDrawing                = #False      ; used by debugMsgD()
  #cTraceVidPicDrawingAlphaBlend      = #False      ; used by debugMsgDA()
CompilerElse
  ; trace
  #cTraceAlphaBlend                   = #True      ; includes video fades
  #cTraceAlphaBlendFunctionCallsOnly  = #True      ; only relevant if #cTraceAlphaBlend = #True (ignores calculations leading up to the alpha blend function calls)
  #cTraceVidPicDisplay                = #True      ; used by debugMsgV()
  #cTraceVidPicDrawing                = #True      ; used by debugMsgD()
  #cTraceVidPicDrawingAlphaBlend      = #True      ; used by debugMsgDA()
CompilerEndIf

; conditional compilation constants for tracing mutex locks (sorted)
#cTraceDMXSendMutexLocks            = #False
#cTraceHTTPSendMutexLocks           = #False
#cTraceMTCSendMutexLocks            = #False
#cTraceMutexLocks                   = #False
#cTraceSMSMutexLocks                = #False
#cTraceTempDatabaseMutexLocks       = #False

; conditional compilation constants for tracing level and pan (sorted)
#cTraceCueTotalVolNow               = #False
#cTraceGetLevels                    = #False
#cTraceGetLevelsForExcel            = #False
#cTraceGetPan                       = #False
#cTraceSetLevels                    = #False
#cTraceSetLevelsFirstDevOnly        = #False ; WARNING! Not used except for SM-S
#cTraceVULevels                     = #False

#cDisableErrorHandler = #False  ; added (#True) following email from Ian Luck (BASS) 18Feb2016 to help sort out a memory error problem occurring in BASS_ASIO_Init

; INFO Special testing constants
#c_set_tbc_time_in_cues = #False ; Set this to #True to be prompted to enter a different time for time-based-cues. This prompt (or prompts) occur on opening the cue file.
#c_next_day_in_resetTOD = #False
#c_slider_mark_section_colors = #False ; Useful for identifying the marks in the different sections of an audio level slider - see SLD_drawTickLines()
#c_simulate_ftd2xx_unavailable = #False
#c_Test_BCF2000_using_BCR2000 = #False ; Added because I (Mike) have a BCR2000 but not a BCF2000
#c_test_playlist_reset = #False ; for testing time-based playlists being correctly reset the next day, etc, to fix issues raised by Randy Hammon
#c_lockmutex_monitoring = #False
#c_hide_rai_input_tracing = #True ; minimise tracing of polling messages
; #cSMS... SoundMan-Server testing constants
#cSMS_16_16_64 = #False
#cSMS_8_8_48 = #False
#c_emulate_x32_returning_scribblestrip_names = #False

; INFO Important: the following two compiler constants were added to (temporarily?) avoid a condition that causes the Windows default beep to sound on pressing spacebar to activate the next cue.
; Initially, some tests using #c_beep_test were coded to try to track down the actual cause of the beep. Some changes worked until the user then pressed up-arrow to go back in the cue list.
; #c_keycallback_processing was finally added to effectively undo the relevant changes made in SCS 11.8.6br, as that was the version at which this problem started.
; We do, however, now need to revisit the problem 'cured' by 11.8.6br - a problem raised by Dave Jenkins on 6Nov2021 (see emails in '2021 Error Reports').
#c_beep_test = #True
#c_keycallback_processing = #False

; INFO POSSIBLE FUTURE FEATURES:
; NOTE Some code may already be in place for features listed below
#c_vMix_in_video_cues = #False     ; Rickee Epps (most recent - 17/09/2019)
#c_force_vMix_if_included = #False
#c_tvg_audio_streams = #False
#c_tvg_onrawaudiosample = #False
#c_allow_video_audio_routed_to_audio_device = #False
#c_blackmagic_card_support = #False
#c_new_gui = #False ; new GUI, which will be using 'gadgets' drawn on canvases. These have mostly been derived from code published on the PB Forum by 'Thorsten1867'. These are implemented as modules in the \Modules folder.
#c_new_button = #False ; 'new button' uses scsButtonGadget2() instead of scsButtonGadget(). scsButtonGadget() uses a PB button gadget, whereas scsButtonGadget2() draws the button on a canvas gadget, which provides full control of the appearance.
#c_color_scheme_classic = #False  ; The traditional SCS colour scheme - btw, prefer a different name than 'classic' as 'classic' implies ancient.
#c_black_grey_scheme = #False     ; An attempt at using basically a non-colour scheme.
#c_show_icon_in_cue_grid = #False ; Coding completed but the display is not yet acceptable as text is displayed hard against the icon.
#c_prod_timer_extra_actions = #False
#c_touch_panel = #False ; A nice feature for users with touch screens. The touch panel would be displayed at the bottom of the screen and contain large frequently-used buttons, eg GO, Stop, Next
#c_use_system_font = #False ; Possible alternative to Tahoma, etc.
#c_include_video_overlays = #False ; Not started yet, apart from a checkbox. See the topic 'Image Overlays' in the TVG help.
#c_include_tcreader = #False  ; timecode reader for SM-S
#c_osc_over_midi_sysex = #False
#c_include_mygrid_for_playlists = #False ; 'mygrid' should be a better solution for playlists in the editor, because currently every line if the playlist contains multiple gadgets

; INFO SCS 11.10.8 features:
#c_csrd_network_available = #True
#c_more_x32_osc_commands = #True
#c_lufs_support = #True
#c_include_peak = #False

; INFO SCS 11.10.7 features:
; <no compiler constant controls>

; INFO SCS 11.10.6 features:
#c_dmx_display_drop_gridline_and_backcolor_choices = #True
#c_scsltc = #False

; INFO SCS 11.10.3 features:
; <no compiler constant controls>

; INFO SCS 11.10.2 features:
#c_dmx_receive_in_main_thread = #True
; "#c_dmx_receive_in_main_thread = #True" was added following many emails back and forth with Stefano as he was getting eratic results when trying to use DMX Cue Control in SCS 11.10.
; The major change in this processing since 11.9 was that in 11.10 I (Mike) created a separate thread to handle incoming DMX. I could not reproduce the problems Stefano was having,
; but I was using ENTTEC's Pro Manager to send DMX from fader settings, whereas Stefano was using Chamsys MagicQ, which can probably send multiple DMX values far faster than using
; individual faders in Pro Manager. Despite extensive examination of the code, it appears there is probably an issue with using the new thread, even though I tried to control this
; by using a Mutex. This new constant, when set #True, calls the processing from the main thread instaed of a separate thread (which is how it was processed in 11.9), and Stefano
; has confirmed that this change has fixed the problem.
#c_cuepanel_multi_dev_select = #True
#c_remote_osc_device = #True
#c_vst_same_as = #True

; INFO SCS 11.10.0 features:
#c_httpsend_in_own_thread = #True
#c_suspend_slider_file_loader_thread_when_auds_playing = #False
; #c_suspend_slider_file_loader_thread_when_auds_playing was effectively #True in all earlier versions of SCS, but
; try allowing thread to continue following email from Ian Harding 6Dec2022 which highlighted the (known) fact
; that progress sliders may not show the audio graph if:
; (a) the graph had not previously been loaded and saved in the .scsdb file, and
; (b) at least one audio file is curremtly playing
#c_lock_audio_to_ltc = #True
; #c_lock_audio_to_ltc: see email "SCS realtime sync to LTC" from Jonathan Digby 20Jun2023, with follow-up info from Loren Wilton
#c_NK2PresetC = #True ; support control of audio in the first currently-playing cue using a Korg nanoKONTROL2
#c_cue_markers_for_video_files = #True
#c_drop_unused_graph_fields = #True
#c_VU_meters_use_BASS_ASIO = #True ; Added 21Nov2023 following emails from Huw Morgan about VU meters not displaying when using BASS ASIO. Appears to be device-specific,
                                    ; but this constant (set to #False) forces SCS to display the meter values from the mixer stream outputs rather than the ASIO outputs.
                                    ; Seems reliable.
#c_enable_bass_asio_lock = #True

; INFO SCS 11.9.0 features:
#c_no_blackout_on_start_or_closedown = #True

; INFO SCS 11.8.3 features:
#c_ignore_Decklink_Video_Capture = #True ; Janice Finke (20Mar2020)

; INFO SCS 11.8.2 features:
#c_omit_bass_asio_setrate = #True

; INFO SCS 11.8.0 features:
#c_tvg_preferred_aspect_ratio = #True ; seems necessary for videos like Bangkok.wmv which is 720x576 but has a 'preferred aspect ratio' size of 720x404, which is required to display correctly when 'keep original' is the sub-cue's aspect ratio
                                      ; NB 9May2020 11.8.3rc3 - 'preferred aspect ratio' is no longer required so use of this has been commented out

#c_minimal_vst = #False ; set #True when desparately trying to find out why Valhalla Echo initially displays Sync as 1/16 when it should be 1/8, and (of lesser importance) why mode is initially displayed as Stereo not stereo
                        ; doesn't happen with VSTPluginTest3.pb, so can't understand why it happens with SCS
                        ; only seems to be a GUI issue(?) as BASS_VST_GetParam() returns the correct value for Sync=1/8, and making any slight adjustment to any control on the GUI 'corrects' the sync and mode displays
                        ; nb some tests of #c_minimal_vst were removed in SCS 11.8.2

; see Ian's reply to my BASS Forum posting "BASS_ChannelLock hangs"
; ; #c_use_BassChannelSetSync_not_BassMixerChannelSetSync = #True
; #c_use_BassChannelSetSync_not_BassMixerChannelSetSync = #False
; ; found that setting the above to #True can cause audio cues played to multiple outputs (via split stream) to stop early when not using the bass mixer
; ; re-reading Ian's reply hints at an alternative solution to BASS_ChannelLock hanging, and that is to use single-threading in BASS, which is the default anyway, so:
; #c_single_thread_bass = #True
; reset "#c_use_BassChannelSetSync_not_BassMixerChannelSetSync = #True" following deadlocks reported by Lars Stokdijk
; (see bug report and emails July/August 2017)
#c_use_BassChannelSetSync_not_BassMixerChannelSetSync = #True
#c_single_thread_bass = #True ; Warning! do NOT change this to #False because that can cause BASS_ChannelLock lockups,
                              ; and also a test of Lars Stokdijk's file (modified) "Project VSC - Cue T-OP1.scs11" caused some Bass Sync Ends to start while a Bass Sync Loop Mixtime was
                              ; being processed and that caused 2 out of the 6 sub-cues to fail to loop. (This test performed on 11.7.0 in Sep 2017.)

; use sam instead of 'postevent' commands because all network commands must be processed by sam, or all must be processed by postevent.
; if the following is set #False then some commands will be processed by sam and others by postevent, and this can lead to commands being processed out of sync
; (eg postevent may be handled before sam, or vice versa)
#c_use_sam_for_network_cue_control = #True

#c_show_infomsg_cancel = #False ; #False because I can't get the cancel button to display!

#cSMSOnThisMachineOnly = #True

#cUseBassMixerEnvelopeForXFades = #False  ; nb cannot get bass mixer envelope to work

; #cAlwaysUseMixerForBass = #True ; added 28Dec2015 for 'Loop Linked' property, because when using DirectSound without the mixer the linked files do not loop in sync
;                                 ; with the primary file - don't know why - tried several scenarios but could only get loops in sync when using the mixer, and
;                                 ; that also requires a small playback buffer etc.
#cAlwaysUseMixerForBass = #False  ; reinstated mixer option 01Feb2016 following email from Mark Skyrme 29Jan2016 of a delay in starting cues - which was due to the buffering when using the mixer
#cUseTryLockMutex = #True
#cDisplaySMSWindow = #False ; Setting this to #True (ie displaying the SM-S window) enables SM-S VU meters to be visible, but #False can reduce the processing overhead
#cEnableASIOBufLen = #False
#cEnableFileBufLen = #True

;- Camtasia and Screen Shot settings
; NB the compiler constant #cTutorialVideoOrScreenShots is set in the parent pb file, eg in scs_PB_x64.pb
CompilerIf #cTutorialVideoOrScreenShots
  #c1600x900 = #True  ; for ScreenPal recordings
  ; #c1280x720 = #True   ; for Camtasia screen capture and for Help file screen shots
  #c1280x720 = #False
  #cMaxScreenNo = 1    ; set to 1 to test single monitor, or up to 9
  #cSuppressLostFocusMsg = #True ; set this to #True for Camtasia/ScreenPal screen capture
CompilerElse
  #c1600x900 = #False
  #c1280x720 = #False
  #cMaxScreenNo = 9     ; set to 1 to test single monitor, or up to 9
  ; #cMaxScreenNo = 1     ; set to 1 to test single monitor, or up to 9
  #cSuppressLostFocusMsg = #False
  ; #cSuppressLostFocusMsg = #True
CompilerEndIf

#c_audio_editor_included = #False
#c_include_sync_levels = #False

CompilerIf Defined(SetThreadExecutionState_, #PB_OSFunction) = #False
  Import "Kernel32.lib"
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      SetThreadExecutionState_(esFlags.l) As "_SetThreadExecutionState@4"
    CompilerElse
      SetThreadExecutionState_(esFlags.l) As "SetThreadExecutionState"
    CompilerEndIf
  EndImport
CompilerEndIf

;- SCS Macros file
XIncludeFile "Macros.pbi"

;- BASS Include files
XIncludeFile "bass.pbi"
XIncludeFile "bassmix.pbi"
XIncludeFile "bassenc.pbi"
XIncludeFile "bassasio.pbi"
XIncludeFile "basswasapi.pbi"
XIncludeFile "tags.pbi"
XIncludeFile "bass_fx.pbi"
XIncludeFile "bass_vst.pbi"
CompilerIf #c_lufs_support
  XIncludeFile "bassloud.pbi"
CompilerEndIf

;- other include files
CompilerIf #c_use_system_font
  XIncludeFile "SystemFonts.pbi"
CompilerEndIf
XIncludeFile "WordWrap.pbi"

;- Modules (ModuleEx, ComboBoxEx, etc)
CompilerIf #c_new_gui Or 1=1
  XIncludeFile "Modules\ModuleEx\ModuleEx.pbi"
  XIncludeFile "Modules\ButtonEx\ButtonExModule.pbi"
  XIncludeFile "Modules\ComboBoxEx\ComboBoxExModule.pbi"
  XIncludeFile "Modules\TextEx\TextExModule.pbi"
CompilerEndIf

;- SCS constants, globals and structures
XIncludeFile "declare\RichEdit_2_4_MJD.pbd" ; must be included before fmEditQE.pbd
XIncludeFile "Constants.pbi"
XIncludeFile "Structures.pbi"
XIncludeFile "Globals.pbi"

XIncludeFile "declare\PreWindows.pbd"
XIncludeFile "declare\Threads.pbd"
XIncludeFile "declare\Tracing.pbd"
XIncludeFile "declare\StartUp.pbd"

XIncludeFile "RichEdit_2_4_MJD.pbi"   ; must be included before fmEditQE.pbi

; ; This replaces #c_audio_editor_included = #True, it's intention is to be set if it needs to be controlled by licence levels
; bExternalEditorsIncluded = #True
; bExternalEditorsIncluded now moved to grLicInfo and set #True for licence levels >= SCS Pro

Procedure displayFatalError()
  ; This Procedure created 24Feb2020 11.8.2.2as following info from Steve Slator, where a run crashed with a memory error in the control thread,
  ; and SCS locked up on displaying the error message. So this procedure was written so that this message could be always be displayed from the
  ; main thread of the program. The global variable gsFatalErrorMessage.s is used for controlling the call to this Procedure.
  
  If IsWindow(#WSP)
    HideWindow(#WSP, #True)   ; don't use setWindowVisible in the error handler
  EndIf
  MessageRequester(#SCS_TITLE, gsFatalErrorMessage)
  
  Delay(100)
  
  callTimeEndPeriodIfReqd()
  If gnDebugFile
    closeLogFile()
  EndIf
  
  gsFatalErrorMessage = ""
  
EndProcedure

Procedure generalErrorHandler()
  PROCNAMEC()
  Protected sErrorMessage.s
  Protected nErrorCode, nErrorLine, sErrorFile.s
  
  nErrorCode = ErrorCode()
  nErrorLine = ErrorLine()
  sErrorFile = GetFilePart(ErrorFile())
  
  OnErrorDefault()  ; cancel the error handler in case debugMsg fails
  
  gbForceTracing = #True
  debugMsg(sProcName, #SCS_START + ", nErrorCode=" + nErrorCode + ", $" + Hex(nErrorCode,#PB_Long))
  
  sErrorMessage = "A program error was detected:" + Chr(13) 
  sErrorMessage + Chr(13)
  sErrorMessage + "Error Message:   "
  Select nErrorCode
    Case #SCS_ERROR_GADGET_NO_NOT_SET
      sErrorMessage + "#SCS_ERROR_GADGET_NO_NOT_SET"
    Case #SCS_ERROR_GADGET_NO_INVALID
      sErrorMessage + "#SCS_ERROR_GADGET_NO_INVALID"
    Case #SCS_ERROR_GADGET_NO_OUT_OF_RANGE
      sErrorMessage + "#SCS_ERROR_GADGET_NO_OUT_OF_RANGE"
    Case #SCS_ERROR_SUBSCRIPT_OUT_OF_RANGE
      sErrorMessage + gsError
    Case #SCS_ERROR_ARRAY_SIZE_INVALID
      sErrorMessage + gsError
    Case #SCS_ERROR_POINTER_OUT_OF_RANGE
      sErrorMessage + gsError
    Case #SCS_ERROR_MISC
      sErrorMessage + gsError
    Default
      sErrorMessage + ErrorMessage()
  EndSelect
  sErrorMessage + Chr(13)
  sErrorMessage + "Error Code:      " + nErrorCode + ", $" + Hex(nErrorCode,#PB_Long) + Chr(13)  
  sErrorMessage + "Code Address:    " + ErrorAddress() + Chr(13)
  
  If nErrorCode = #PB_OnError_InvalidMemory   
    sErrorMessage + "Target Address:  " + ErrorTargetAddress() + Chr(13)
  EndIf
  
  If ErrorLine() = -1
    sErrorMessage + "Source code line: Enable OnError lines support to get code line information." + Chr(13)
  Else
    sErrorMessage + "Source code file: " + sErrorFile + Chr(13)
    sErrorMessage + "Source code line: " + nErrorLine + Chr(13)
  EndIf
  
  Select gnErrorHandlerCode
    Case #SCS_EHC_GRAPH_PROGRESS_BAR
      With grMG2
        sErrorMessage + "Command: Box(" + \nSEBarLeft + ", " + \nSEBarTop + ", " + \nGraphWidth + ", nHeight, #SCS_Black)" + Chr(13)
      EndWith
  EndSelect
  
  sErrorMessage + "Cue file: " + #DQUOTE$ + gsCueFile + #DQUOTE$ + Chr(13)
  
  sErrorMessage + "Thread: #" + gnThreadNo + Chr(13)
  sErrorMessage + "Time: " + Str(ElapsedMilliseconds() - gqStartTime) + Chr(13)
  sErrorMessage + "StartDateTime: " + gsStartDateTime + Chr(13)
  
  sErrorMessage + "Log file: " + GetFilePart(gsDebugFile) + Chr(13)
  sErrorMessage + "Log lines: " + gnTraceLine + Chr(13)
  ; sErrorMessage + "gnErrLabel: " + gnErrLabel + Chr(13)
  sErrorMessage + "SCS version: " + #SCS_VERSION + " (" + #SCS_PROCESSOR + ")" + Chr(13)
  
  sErrorMessage + "gnLabel=" + gnLabel + ", gnLabelStatusCheck=" + gnLabelStatusCheck + ", gnLabelSAM=" + gnLabelSAM + ", gnLabelSpecial=" + gnLabelSpecial + ", gnLabelPre=" + gnLabelPre + Chr(13)
  sErrorMessage + "gnCueListMutexLockThread=" + gnCueListMutexLockThread + ", gnCueListMutexLockNo=" + gnCueListMutexLockNo + ", gqCueListMutexLockTime=" + Str(gqCueListMutexLockTime - gqStartTime) + Chr(13)
  
  CompilerIf 1=2    ; ignore the following as register values don't mean anything to me!
    sErrorMessage + Chr(13)
    sErrorMessage + "Register content:" + Chr(13)
    
    CompilerSelect #PB_Compiler_Processor 
      CompilerCase #PB_Processor_x86
        sErrorMessage + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + Chr(13)
        sErrorMessage + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + Chr(13)
        sErrorMessage + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + Chr(13)
        sErrorMessage + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + Chr(13)
        sErrorMessage + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + Chr(13)
        sErrorMessage + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + Chr(13)
        sErrorMessage + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + Chr(13)
        sErrorMessage + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + Chr(13)
        
      CompilerCase #PB_Processor_x64
        sErrorMessage + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + Chr(13)
        sErrorMessage + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + Chr(13)
        sErrorMessage + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + Chr(13)
        sErrorMessage + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + Chr(13)
        sErrorMessage + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + Chr(13)
        sErrorMessage + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + Chr(13)
        sErrorMessage + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + Chr(13)
        sErrorMessage + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + Chr(13)
        sErrorMessage + "Display of registers R8-R15 skipped."         + Chr(13)
        
      CompilerCase #PB_Processor_PowerPC
        sErrorMessage + "r0 = " + Str(ErrorRegister(#PB_OnError_r0)) + Chr(13)
        sErrorMessage + "r1 = " + Str(ErrorRegister(#PB_OnError_r1)) + Chr(13)
        sErrorMessage + "r2 = " + Str(ErrorRegister(#PB_OnError_r2)) + Chr(13)
        sErrorMessage + "r3 = " + Str(ErrorRegister(#PB_OnError_r3)) + Chr(13)
        sErrorMessage + "r4 = " + Str(ErrorRegister(#PB_OnError_r4)) + Chr(13)
        sErrorMessage + "r5 = " + Str(ErrorRegister(#PB_OnError_r5)) + Chr(13)
        sErrorMessage + "r6 = " + Str(ErrorRegister(#PB_OnError_r6)) + Chr(13)
        sErrorMessage + "r7 = " + Str(ErrorRegister(#PB_OnError_r7)) + Chr(13)
        sErrorMessage + "Display of registers r8-R31 skipped."       + Chr(13)
        
    CompilerEndSelect
  CompilerEndIf
  
  Debug sErrorMessage
  
  debugMsg(sProcName, "-----------------------------")
  debugMsg(sProcName, ReplaceString(sErrorMessage, Chr(13), #CRLF$))
  debugMsg(sProcName, "-----------------------------")
  
  gsFatalErrorMessage = sErrorMessage
  gbClosingDown = #True ; force handleWindowEvents() to exit main loop
  
  THR_stopAThread(#SCS_THREAD_CONTROL)
  
  Delay(250)
  displayFatalError()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; trap errors
CompilerIf #cDisableErrorHandler = #False
  OnErrorCall(@generalErrorHandler())
CompilerEndIf

; INFO language .pbi files
; language files must be submitted in the order they are to appear in the cboLanguage drop-down list in General Options
; if you add or remove a language file you also need to add or remove a 'Restore' command in LoadLanguage()
; fully implemented translations:

;XIncludeFile "scsLangENUS.pbi"      ; English (US)
;XIncludeFile "scsLangENGB.pbi"      ; English (GB)
;XIncludeFile "scsLangFR.pbi"        ; French
;XIncludeFile "scsLangIT.pbi"        ; Italian
;XIncludeFile "scsLangES.pbi"        ; Spanish
;XIncludeFile "scsLangCA.pbi"        ; Catalan
;XIncludeFile "scsLangDE.pbi"        ; German    Note: Uwe Hinkel wrote "I did not translate the BASS error messages and a few technical terms that we Germans are used to."
;XIncludeFile "scsLangPL.pbi"        ; Polish
;XIncludeFile "scsLangJP.pbi"        ; Japanese
;XIncludeFile "scsLangZH.pbi"        ; Chinese

;- SCS Declare files
Debug("declare files")
XIncludeFile "declare\aamain.pbd"
XIncludeFile "declare\AudFileRequester.pbd"
XIncludeFile "declare\common.pbd"
XIncludeFile "declare\centerMsgRqstr.pbd"
XIncludeFile "declare\CSRD.pbd"
XIncludeFile "declare\CueCommon.pbd"
XIncludeFile "declare\CueEditor.pbd"
XIncludeFile "declare\CueFileHandler.pbd"
XIncludeFile "declare\CueFileHandler.pbd"
XIncludeFile "declare\CuePanelControl.pbd"
XIncludeFile "declare\DevMapHandler.pbd"
XIncludeFile "declare\sACN.pbd"
XIncludeFile "declare\DMX.pbd"
XIncludeFile "declare\Artnet.pbd"
XIncludeFile "declare\EditDevs.pbd"
XIncludeFile "declare\ETCImport.pbd"
XIncludeFile "declare\fmAGColors.pbd"
XIncludeFile "declare\fmBulkEdit.pbd"
XIncludeFile "declare\fmColorScheme.pbd"
XIncludeFile "declare\fmControllers.pbd"
XIncludeFile "declare\fmCopyProps.pbd"
XIncludeFile "declare\fmCtrlSetup.pbd"
XIncludeFile "declare\fmCurrInfo.pbd"
XIncludeFile "declare\fmDMXDisplay.pbd"
XIncludeFile "declare\fmDMXTest.pbd"
XIncludeFile "declare\fmEditCue.pbd"
XIncludeFile "declare\fmEditModal.pbd"
XIncludeFile "declare\fmEditProd.pbd"
XIncludeFile "declare\fmEditQA.pbd"
XIncludeFile "declare\fmEditQE.pbd"
XIncludeFile "declare\fmEditQF.pbd"
XIncludeFile "declare\fmEditQG.pbd"
XIncludeFile "declare\fmEditQI.pbd"
XIncludeFile "declare\fmEditQJ.pbd"
XIncludeFile "declare\fmEditQK.pbd"
XIncludeFile "declare\fmEditQL.pbd"
XIncludeFile "declare\fmEditQM.pbd"
XIncludeFile "declare\fmEditQP.pbd"
XIncludeFile "declare\fmEditQQ.pbd"
XIncludeFile "declare\fmEditQR.pbd"
XIncludeFile "declare\fmEditQS.pbd"
XIncludeFile "declare\fmEditQT.pbd"
XIncludeFile "declare\fmEditQU.pbd"
XIncludeFile "declare\fmEditSub.pbd"
XIncludeFile "declare\fmEditor.pbd"
XIncludeFile "declare\fmExport.pbd"
XIncludeFile "declare\fmFileOpener.pbd"
XIncludeFile "declare\fmFind.pbd"
XIncludeFile "declare\fmImport.pbd"
XIncludeFile "declare\fmImportCSV.pbd"
XIncludeFile "declare\fmImportDevs.pbd"
XIncludeFile "declare\fmInfoMsg.pbd"
XIncludeFile "declare\fmInputRequester.pbd"
CompilerIf#c_cuepanel_multi_dev_select
XIncludeFile "declare\fmLinkDevs.pbd"
CompilerEndIf
XIncludeFile "declare\fmLockEditor.pbd"
XIncludeFile "declare\fmMain.pbd"
XIncludeFile "declare\fmMemo.pbd"
XIncludeFile "declare\fmMTCDisplay.pbd"
XIncludeFile "declare\fmMultiCueCopyEtc.pbd"
XIncludeFile "declare\fmNearEndWarning.pbd"
XIncludeFile "declare\fmOptions.pbd"
XIncludeFile "declare\fmOSCCapture.pbd"
XIncludeFile "declare\fmPrintCueList.pbd"
XIncludeFile "declare\fmProdTimer.pbd"
XIncludeFile "declare\fmRegister.pbd"
XIncludeFile "declare\fmScribbleStrip.pbd"
XIncludeFile "declare\fmSplash.pbd"
XIncludeFile "declare\fmTemplates.pbd"
XIncludeFile "declare\fmTimerDisplay.pbd"
XIncludeFile "declare\fmVSTPlugins.pbd"
XIncludeFile "declare\gapless.pbd"
XIncludeFile "declare\Graph2.pbd"
XIncludeFile "declare\HTTPControl.pbd"
XIncludeFile "declare\Knob.pbd"
XIncludeFile "declare\LvlEnv.pbd"
XIncludeFile "declare\MIDI.pbd"
XIncludeFile "declare\mmedia.pbd"
XIncludeFile "declare\mmedia2.pbd"
XIncludeFile "declare\MonitorManager.pbd"
XIncludeFile "declare\M2T.pbd"
XIncludeFile "declare\Network.pbd"
XIncludeFile "declare\OpenNextCues.pbd"
XIncludeFile "declare\RS232.pbd"
XIncludeFile "declare\sam.pbd"
XIncludeFile "declare\SliderControl.pbd"
XIncludeFile "declare\SMSControl.pbd"
CompilerIf #c_scsltc
  XIncludeFile "declare\LTC.pbd"
CompilerEndIf
XIncludeFile "declare\Timecode.pbd"
XIncludeFile "declare\UndoRedo.pbd"
XIncludeFile "declare\VUDisplay.pbd"
XIncludeFile "declare\WindowEventHandler.pbd"
XIncludeFile "declare\condev.pbd"
XIncludeFile "declare\fmLoadProd.pbd"
CompilerIf #c_vMix_in_video_cues
  XIncludeFile "declare\VMixControl.pbd"
CompilerEndIf
CompilerIf #c_include_tvg
  XIncludeFile "declare\TVG.pbd"
CompilerEndIf
XIncludeFile "declare\scsCueMarkers.pbd"
XIncludeFile "declare\fmClock.pbd"
XIncludeFile "declare\fmCountdownClock.pbd"
XIncludeFile "declare\VSTRuntime.pbd"

;- SCS Include files without declare files
Debug("include files without declare files")
; XIncludeFile "http.pbi"
XIncludeFile "MediaInfo.pbi"
XIncludeFile "DLLType.pbi"

XIncludeFile "MyGrid_PB520.pbi"
XIncludeFile "MultiLineTooltip.pbi"
XIncludeFile "USBPowerStates.pbi"

; the include files that do not have (do not need) their own declare files
XIncludeFile "BassExtras.pbi"  ; keep BassExtras at top of list of SCS files
XIncludeFile "SelfContained.pbi"
XIncludeFile "Lang.pbi"
XIncludeFile "Images.pbi"
XIncludeFile "Sounds.pbi"
XIncludeFile "ShortcutGadgetEx.pbi" ; must be before PreWindows.pbi
XIncludeFile "ToolBar.pbi"
XIncludeFile "Shortcuts.pbi"   ; must be before Windows.pbi
XIncludeFile "Windows.pbi"
XIncludeFile "Resizer.pbi"
XIncludeFile "Mouse.pbi"
XIncludeFile "BassChanInfo.pbi"
XIncludeFile "ColorHandler.pbi"
XIncludeFile "ftd2xx.pbi"  ; must be before StartUp.pbi
CompilerIf #c_include_tvg
  XIncludeFile "TVG.pbi"
CompilerEndIf
XIncludeFile "StartUp.pbi"
XIncludeFile "CueListHandler.pbi"
XIncludeFile "Tracing.pbi"

XIncludeFile "fmAbout.pbi"
XIncludeFile "fmCheckForUpdates.pbi"
XIncludeFile "fmCollectFiles.pbi"
XIncludeFile "fmControllers.pbi"
XIncludeFile "fmFavFiles.pbi"
XIncludeFile "fmFavFileSelector.pbi"
XIncludeFile "fmFileLocator.pbi"
XIncludeFile "fmFileOpener.pbi"
XIncludeFile "fmFileRename.pbi"
XIncludeFile "fmLabelChange.pbi"
XIncludeFile "fmMidiTest.pbi"
XIncludeFile "fmProdTimer.pbi"
XIncludeFile "fmTimeProfile.pbi"
XIncludeFile "fmVideo.pbi"
XIncludeFile "fmMonitor.pbi"
XIncludeFile "fmSpecialStart.pbi"

XIncludeFile "StatusCheck.pbi"

;- SCS Include files
Debug("pbi files")
XIncludeFile "aamain.pbi"
XIncludeFile "AudFileRequester.pbi"
XIncludeFile "centerMsgRqstr.pbi"
XIncludeFile "common.pbi"
XIncludeFile "CSRD.pbi"
XIncludeFile "CueCommon.pbi"
XIncludeFile "CueEditor.pbi"
XIncludeFile "CueFileHandler.pbi"
XIncludeFile "CuePanelControl.pbi"
XIncludeFile "DevMapHandler.pbi"
XIncludeFile "sACN.pbi"
XIncludeFile "DMX.pbi"
XIncludeFile "Artnet.pbi"
XIncludeFile "EditDevs.pbi"
XIncludeFile "ETCImport.pbi"
XIncludeFile "fmAGColors.pbi"
XIncludeFile "fmBulkEdit.pbi"
XIncludeFile "fmColorScheme.pbi"
XIncludeFile "fmCopyProps.pbi"
XIncludeFile "fmCtrlSetup.pbi"
XIncludeFile "fmCurrInfo.pbi"
XIncludeFile "fmDMXDisplay.pbi"
XIncludeFile "fmDMXTest.pbi"
XIncludeFile "fmEditCue.pbi"
XIncludeFile "fmEditModal.pbi"
XIncludeFile "fmEditProd.pbi"
XIncludeFile "fmEditQA.pbi"
XIncludeFile "fmEditQE.pbi"
XIncludeFile "fmEditQF.pbi"
XIncludeFile "fmEditQG.pbi"
XIncludeFile "fmEditQI.pbi"
XIncludeFile "fmEditQJ.pbi"
XIncludeFile "fmEditQK.pbi"
XIncludeFile "fmEditQL.pbi"
XIncludeFile "fmEditQM.pbi"
XIncludeFile "fmEditQP.pbi"
XIncludeFile "fmEditQQ.pbi"
XIncludeFile "fmEditQR.pbi"
XIncludeFile "fmEditQS.pbi"
XIncludeFile "fmEditQT.pbi"
XIncludeFile "fmEditQU.pbi"
XIncludeFile "fmEditSub.pbi"
XIncludeFile "fmEditor.pbi"
XIncludeFile "fmExport.pbi"
XIncludeFile "fmFind.pbi"
XIncludeFile "fmImport.pbi"
XIncludeFile "fmImportCSV.pbi"
XIncludeFile "fmImportDevs.pbi"
XIncludeFile "fmInfoMsg.pbi"
XIncludeFile "fmInputRequester.pbi"
CompilerIf #c_cuepanel_multi_dev_select
XIncludeFile "fmLinkDevs.pbi"
CompilerEndIf
XIncludeFile "fmLockEditor.pbi"
XIncludeFile "fmMain.pbi"
XIncludeFile "fmMemo.pbi"
XIncludeFile "fmMTCDisplay.pbi"
XIncludeFile "fmMultiCueCopyEtc.pbi"
XIncludeFile "fmNearEndWarning.pbi"
XIncludeFile "fmOptions.pbi"
XIncludeFile "fmOSCCapture.pbi"
XIncludeFile "fmPrintCueList.pbi"
XIncludeFile "fmRegister.pbi"
XIncludeFile "fmScribbleStrip.pbi"
XIncludeFile "fmSplash.pbi"
XIncludeFile "fmTemplates.pbi"
XIncludeFile "fmTimerDisplay.pbi"
XIncludeFile "fmVSTPlugins.pbi"
XIncludeFile "gapless.pbi"
XIncludeFile "Graph2.pbi"
XIncludeFile "HTTPControl.pbi"
XIncludeFile "Knob.pbi"
XIncludeFile "LvlEnv.pbi"
XIncludeFile "MIDI.pbi"
XIncludeFile "mmedia.pbi"
XIncludeFile "mmedia2.pbi"
XIncludeFile "MonitorManager.pbi"
XIncludeFile "M2T.pbi"
XIncludeFile "Network.pbi"
XIncludeFile "OpenNextCues.pbi"
XIncludeFile "PreWindows.pbi"
XIncludeFile "RS232.pbi"
XIncludeFile "sam.pbi"
XIncludeFile "SliderControl.pbi"
XIncludeFile "SMSControl.pbi"
XIncludeFile "Threads.pbi"
XIncludeFile "TimeCode.pbi"
CompilerIf #c_scsltc
  XIncludeFile "LTC.pbi"
CompilerEndIf
XIncludeFile "UndoRedo.pbi"
XIncludeFile "VUDisplay.pbi"
XIncludeFile "WindowEventHandler.pbi"
XIncludeFile "condev.pbi"
XIncludeFile "fmLoadProd.pbi"
CompilerIf #c_vMix_in_video_cues
  XIncludeFile "VMixControl.pbi"
CompilerEndIf
XIncludeFile "scsCueMarkers.pbi"
XIncludeFile "fmClock.pbi"
XIncludeFile "fmCountdownClock.pbi"
XIncludeFile "VSTRuntime.pbi"

;- SCS resource files
Import "images\cursors.res"
EndImport
; notes on images\cursors.res
;  This resource file contains the grab and grabbing cursors used for dragging the audio file graph (cvsGraph).
;  All the necessary files for maintaining cursors.res are in the images folder, including cursors.rc and cursors.res.
;  Use the "Pelles C for Windows" IDE to edit cursors.rc, and then save your changes.
;  Then save the file as cursors.res, which is then ready for the above PB Import command.
;  Note that the cursor files grab.cur and grabbing.cur are defined in cursors.rc, not in cursors.res,
;  so you need to go back to cursors.rc if you need to make any changes to this resource file.

;- START PROGRAM
setThreadNo(#SCS_THREAD_MAIN)

CompilerIf #cTraceMutexLocks
  gnTraceMutexLocking = 1
  gnTraceTempDatabaseMutexLocking = 1
  gnTraceSMSMutexLocking = 1
  gnTraceMTCSendMutexLocking = 1
  gnTraceDMXSendMutexLocking = 1
  gnTraceHTTPSendMutexLocking = 1
CompilerEndIf
CompilerIf #cTraceSMSMutexLocks
  gnTraceSMSMutexLocking = 1
CompilerEndIf
CompilerIf #cTraceTempDatabaseMutexLocks
  gnTraceTempDatabaseMutexLocking = 1
CompilerEndIf
CompilerIf #cTraceMTCSendMutexLocks
  gnTraceMTCSendMutexLocking = 1
CompilerEndIf
CompilerIf #cTraceDMXSendMutexLocks
  gnTraceDMXSendMutexLocking = 1
CompilerEndIf
CompilerIf #cTraceHTTPSendMutexLocks
  gnTraceHTTPSendMutexLocking = 1
CompilerEndIf

; gbUseBASS and gbUseSMS are mutually exclusive
gbUseBASS = #True
If gbUseBASS
  gbUseSMS = #False
Else
  gbUseSMS = #True
EndIf

callTimeBeginPeriodIfReqd()
; useAesEncryption = #True    ; IF #False then then language files will be read as plaintext, if #true then read encrypted
useAesEncryption = #False    ; IF #False then then language files will be read as plaintext, if #true then read encrypted

Debug("call initialisePart0()")
initialisePart0()
loadPrefsFavFiles() ; favorite file preferences loaded now as this must not be destroyed by 'factory reset'
If GetAsyncKeyState_(#VK_SHIFT) & (1 << 15)
  ; display 'special start' screen
  If WSS_Main() = #False
    ; if WSS_Main() returned #False then user clicked the 'Close SCS' button
    callTimeEndPeriodIfReqd()
    End
  EndIf
EndIf

Debug("call initialisePart1()")
initialisePart1()

WSP_Form_Load()
  
handleWindowEvents()

debugMsg("TopLevel", "Closing down")

If gsFatalErrorMessage
  debugMsg("TopLevel", "calling displayFatalError()")
  displayFatalError()
EndIf

callTimeEndPeriodIfReqd()

gqTimeNow = ElapsedMilliseconds()
gsTmpString = Str(Round(((gqTimeNow - gqStartTime) / 1000), #PB_Round_Nearest))
debugMsg("TopLevel", "END OF RUN, Elapsed time: " + gsTmpString + " seconds")

If gnDebugFile
  closeLogFile()
EndIf

Debug "END OF RUN"

End

; EOF