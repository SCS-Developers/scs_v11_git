; File: Constants.pbi

EnableExplicit

CompilerIf #cAgent = #False
  #SCS_AGENT_NAME = ""
  #SCS_URL_LINK = "https://www.showcuesystems.com"
  #SCS_URL_DISPLAY = "www.showcuesystems.com"
  #SCS_REGISTER_URL_LINK = "https://www.showcuesystems.com/cms/purchase"
  #SCS_REGISTER_URL_DISPLAY = "www.showcuesystems.com/cms/purchase"
CompilerEndIf

#SCS_HOME_PAGE_URL_DISPLAY = "www.showcuesystems.com"
#SCS_DOWNLOAD_LINK = "https://www.showcuesystems.com/mem_download.php"
#SCS_ONLINE_FORUMS = "https://www.showcuesystems.com/forum/index.php"

CompilerIf #cTutorialVideoOrScreenShots
  #SCS_PREFS_FILE = "scs11vt.scsp"
CompilerElse
  #SCS_PREFS_FILE = "scs11.scsp"
CompilerEndIf
CompilerIf #cDemo
  #SCS_PREFS_FILE_COMMON = "scs11.scscd"
CompilerElseIf #cWorkshop
  #SCS_PREFS_FILE_COMMON = "scs11.scscw"
CompilerElse
  #SCS_PREFS_FILE_COMMON = "scs11.scscp"
CompilerEndIf

;- special constants
#SCS_USE_MIN_UPDATE = #False
#SCS_ENCRYPTION_KEY = "John 3 16"
#SCS_CUE_FILE_DATE_FORMAT = "%yyyy-%mm-%dd %hh:%ii:%ss"

; max. no. of attempts per session the user may incorrectly enter their authorization string in the lock editor window
; must be greater than 3 or you will need to modify some procedures in fmLockEditor, such as WLE_btnSetPassword_Click
#SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS = 5

#SCS_DEFAULT_FILEBUFLEN = 1500

;- colors (common colors)
; Warning! do not use built-in color constants like #Black as these are not PB constants but Windows API constants, so are not cross-platform
#SCS_Black = $000000
#SCS_White = $FFFFFF
#SCS_Yellow = $00FFFF
#SCS_Light_Yellow = $44FFFF
#SCS_Dim_Yellow = $00AAAA
#SCS_Grey = $808080
#SCS_Very_Dark_Grey = $282828
#SCS_Darker_Grey = $323232
#SCS_Dark_Grey = $404040
#SCS_Mid_Grey = $989898
#SCS_Light_Grey = $C0C0C0
#SCS_Very_Light_Grey = $E8E8E8
#SCS_Blue = $FF0000
#SCS_Light_Blue = $FFDE7F
#SCS_Red = $0000FF
#SCS_Green = $00FF00
#SCS_Dark_Green = $00B000
#SCS_Light_Green = $CAFFCA
#SCS_Orange = $00A5FF
#SCS_Dark_Orange = $387CCB

#SCS_Disabled_Textbox_Back_Color = $F0F0F0
#SCS_Progress_Color = $00FF00
#SCS_Position_Color = $85EFE4
; #SCS_Pan_Color = $80C0FF
#SCS_Pan_Color = $0080FF
#SCS_Level_Color = $00FFFF
#SCS_Level_Color_Ctrl_Hold = $F6C0F1
#SCS_Line_Color = $646464 ; based on 'eye dropping' the color of a container border in Windows 11 7Aug2023
#SCS_Percent_Color = $AF73B5
#SCS_General_Color1 = $71B1E8 ; $373AC8  ; color of pointer in 'general' sliders
#SCS_General_Color2 = $80FFFF
; #SCS_General_Color2 = $676AF8
; #SCS_General_Color1 = $FF9933  ; color of pointer in 'general' sliders
; #SCS_General_Color2 = $FFDE7F
#SCS_ScrollThumb_Color1 = $FEE796
#SCS_ScrollThumb_Color2 = $FFF5D7
#SCS_Disabled_Pointer_Color = $D0D0D0
#SCS_Stopping_Color = $0000F3
#SCS_Next_Manual_Cue_BackColor = $E4010D    ; also used for grdCues marker when identifying the next manual cue
#SCS_Next_Manual_Cue_TextColor = $C0FFFF
#SCS_SplashScreen_FrontColor = $DEE0C3
#SCS_SplashScreen_BackColor = $000000
#SCS_Btn_Enabled_Color = $E1E1E1  ; = RGB(225,225,225)
#SCS_Btn_Hover_Color = $FBF1E5    ; = RGB(229,241,251)
#SCS_Tr_Btn_Enabled_Color = $000000
#SCS_Tr_Btn_Disabled_Color = $989898
#SCS_LevelPointEmphasis_Color = #SCS_Grey
#SCS_Phys_BackColor = $73C6CD ; = RGB(205,198,115)

#SCS_GUI_BackColor1 = $828282 ; Hex(RGB(130,130,130))
#SCS_GUI_BackColor2 = $969696 ; Hex(RGB(150,150,150))
#SCS_GUI_TextColor1 = $F8F8F8 ; Hex(RGB(248,248,248))
#SCS_GUI_TitleBackColor = $404040
#SCS_GUI_TitleTextColor = $FAFAFA

#SCS_Text_Minus_Infinity = "- " + Chr(165)

#SCS_SHOW_GADGET = #False
#SCS_HIDE_GADGET = #True

;- mutex numbers
Enumeration 1
  #SCS_MUTEX_CUE_LIST
  #SCS_MUTEX_IMAGE
  #SCS_MUTEX_DEBUG
  #SCS_MUTEX_MTC_SEND
  #SCS_MUTEX_DMX_SEND
  #SCS_MUTEX_DMX_RECEIVE
  #SCS_MUTEX_HTTP_SEND
  #SCS_MUTEX_SMS_NETWORK
  #SCS_MUTEX_NETWORK_SEND
  #SCS_MUTEX_TEMP_DATABASE
  #SCS_MUTEX_LANG
  #SCS_MUTEX_LOAD_SAMPLES
  #SCS_MUTEX_VMIX_SEND
  #SCS_MUTEX_DUMMY_LAST
EndEnumeration
#SCS_MUTEX_MONITOR_FIRST = #SCS_MUTEX_CUE_LIST
#SCS_MUTEX_MONITOR_LAST = #SCS_MUTEX_DUMMY_LAST - 1

;- thread numbers
Enumeration
  #SCS_THREAD_ZERO = 0          ; a value of 0 as the thread number implies the action was raised (possibly indirectly) from a callback or a MIDI In process or similar
  #SCS_THREAD_MAIN              ; main thread - NOT created by createThread()
  #SCS_THREAD_CONTROL
  #SCS_THREAD_BLENDER
  #SCS_THREAD_RS232_RECEIVE
  #SCS_THREAD_SLIDER_FILE_LOADER
  #SCS_THREAD_NETWORK
  #SCS_THREAD_MTC_CUES
  #SCS_THREAD_CTRL_SEND
  #SCS_THREAD_DMX_SEND
  #SCS_THREAD_DMX_RECEIVE
  #SCS_THREAD_HTTP_SEND
  #SCS_THREAD_COLLECT_FILES
  #SCS_THREAD_GET_FILE_STATS
  #SCS_THREAD_SYSTEM_MONITOR
  #SCS_THREAD_SCS_LTC
  #SCS_THREAD_DUMMY_LAST
EndEnumeration
#SCS_THREAD_MONITOR_FIRST = #SCS_THREAD_MAIN
#SCS_THREAD_MONITOR_LAST = #SCS_THREAD_DUMMY_LAST - 1

;- thread states
Enumeration
  #SCS_THREAD_STATE_NOT_CREATED
  #SCS_THREAD_STATE_ACTIVE
  #SCS_THREAD_STATE_SUSPENDED
  #SCS_THREAD_STATE_STOPPED
EndEnumeration

;- thread sub states
Enumeration
  #SCS_THREAD_SUB_STATE_INACTIVE
  #SCS_THREAD_SUB_STATE_STARTING
  #SCS_THREAD_SUB_STATE_ACTIVE
  #SCS_THREAD_SUB_STATE_STOPPING
EndEnumeration

;- thread mutex lock status
Enumeration 1 ; nb 0 = free/unlocked, ie no lock requested and mutex not currently locked for this thread
  #SCS_THREADMUTEX_LOCK_REQUESTED   ; LockMutex() issued for this thread, but still waiting for the lock
  #SCS_THREADMUTEX_LOCKED           ; LockMutex() successfully processed for this thread
EndEnumeration

;- control send thread item states
Enumeration
  #SCS_CSTI_NOT_SET
  #SCS_CSTI_READY
  #SCS_CSTI_RUNNING
  #SCS_CSTI_COMPLETED
EndEnumeration

;- loop actions (initially created for 'run thread' procedures)
Enumeration
  #SCS_LOOP_ACTION_PROCEED
  #SCS_LOOP_ACTION_CONTINUE
  #SCS_LOOP_ACTION_BREAK
EndEnumeration

;- Control Source for VIDEO / IMAGE / CAPTURE
Enumeration
  #SCS_CS_SOURCE_VIDIMG
  #SCS_CS_SOURCE_CAPTURE
EndEnumeration

;- SMS (SoundMan-Server) constants
; SoundMan-Server process handling constants
#SCS_SMS_RECEIVE_BUFFER_SIZE = 1000     ; size of receive buffer (in bytes)
Enumeration
  #SCS_SMS_SYNC_END
  #SCS_SMS_SYNC_POS
EndEnumeration
#SCS_ENCFILESINDEX_NAME = "scs_encfilesindex.scse"

Enumeration
  #SCS_SMS_FADE_MIDI
  #SCS_SMS_FADE_LOG
  #SCS_SMS_FADE_LIN
  #SCS_SMS_FADE_EXP
EndEnumeration

;- timers
Enumeration 1
  #SCS_TIMER_SPLASH
  #SCS_TIMER_DEMO
  #SCS_TIMER_TEST_TONE    ; on window #WED, as #WEP is not a real window
  #SCS_TIMER_CLOCK
  #SCS_TIMER_COUNTDOWN
  #SCS_TIMER_VU_METERS
EndEnumeration
#SCS_TIMER_LAST = #PB_Compiler_EnumerationValue - 1

;- time formats
EnumerationBinary 1
  #SCS_TIME_FORMAT_A
  #SCS_TIME_FORMAT_B
  #SCS_TIME_FORMAT_C
EndEnumeration
#SCS_TIME_FORMAT_A_OR_B = #SCS_TIME_FORMAT_A | #SCS_TIME_FORMAT_B
  
;- gadget base
#SCS_GADGET_BASE_NO = 4096

;- gadget numbers for event handlers (G4EH)
#SCS_G4EH_FIRST = 3500
Enumeration #SCS_G4EH_FIRST
  ; special gadget numbers for event handler in fmEditProd
  #SCS_G4EH_PR_LBLFIXTURENO
  #SCS_G4EH_PR_TXTFIXTURECODE
  #SCS_G4EH_PR_TXTFIXTUREDESC
  #SCS_G4EH_PR_CBOFIXTURETYPE
  #SCS_G4EH_PR_TXTDIMMABLECHANNELS
  #SCS_G4EH_PR_TXTDMXSTARTCHANNEL
  ; special gadget numbers for event handler in fmVSTPlugins
  #SCS_G4EH_VP_LBLLIBVSTNO
  #SCS_G4EH_VP_TXTLIBVSTPLUGINNAME
  #SCS_G4EH_VP_LBLDEVVSTORDER
  #SCS_G4EH_VP_CBODEVVSTPLUGIN
  #SCS_G4EH_VP_CHKDEVBYPASSVST
  #SCS_G4EH_VP_CHKDEVVIEWVST
  #SCS_G4EH_VP_TXTDEVVSTCOMMENT
  ; special gadget numbers for event handler in fmEditQP (playlist cues)
  #SCS_G4EH_PL_CNTFILE
  #SCS_G4EH_PL_TXTTRKNO
  #SCS_G4EH_PL_TXTFILENAME
  #SCS_G4EH_PL_CMDBROWSE
  #SCS_G4EH_PL_TXTLENGTH
  #SCS_G4EH_PL_TXTSTARTAT
  #SCS_G4EH_PL_TXTENDAT
  #SCS_G4EH_PL_TXTPLAYLENGTH
  #SCS_G4EH_PL_TXTRELLEVEL
  ; special gadget numbers for event handler in fmEditQA (video/image cues)
  #SCS_G4EH_QA_CNTFILE
  #SCS_G4EH_QA_CNTIMAGE
  #SCS_G4EH_QA_CNTPICSIZE
  #SCS_G4EH_QA_CNTTRANSITION
  #SCS_G4EH_QA_PICIMAGE
  #SCS_G4EH_QA_PICTRANSITION
  #SCS_G4EH_QA_TXTFILENAME
  ; special gadget numbers for event handler in fmEditQK (lighting cues, but just for DMX items and DMX capture)
  #SCS_G4EH_QK_CNTITEM
  #SCS_G4EH_QK_CVSITEMNO
  #SCS_G4EH_QK_TXTDMXITEMSTR
  #SCS_G4EH_QK_SLDDMXVALUE
  ; special gadget numbers for event handler in createfmCtrlSetup
  #SCS_G4EH_WCM_CNTITEM
  #SCS_G4EH_WCM_MIDICOMMAND
  #SCS_G4EH_WCM_MIDICC
  #SCS_G4EH_WCM_MIDIVV
EndEnumeration
#SCS_G4EH_LAST = #PB_Compiler_EnumerationValue - 1

;- gadget numbers for OptionRequester()
Enumeration #PB_Compiler_EnumerationValue
  #SCS_OR_BUTTON_BASE
EndEnumeration

;- gadget types
Enumeration 1
  #SCS_GTYPE_TEXT
  #SCS_GTYPE_STRING_ENTERABLE
  #SCS_GTYPE_STRING_READONLY
  #SCS_GTYPE_STRING_NO_SELECT_WHOLE_FIELD ; enterable, but do not 'select whole field' (used in Find window)
  #SCS_GTYPE_PANEL
  #SCS_GTYPE_SCROLLBAR
  #SCS_GTYPE_CHECKBOX2            ; owner-drawn checkbox gadget
  #SCS_GTYPE_OPTION2              ; owner-drawn option gadget
  #SCS_GTYPE_BUTTON2              ; owner-drawn button gadget
  #SCS_GTYPE_TOOLBAR_BTN          ; toolbar button
  #SCS_GTYPE_TOOLBAR_CAT          ; toolbar category caption
EndEnumeration

;- owner-drawn gadget flags
EnumerationBinary 1
  #SCS_OGF_BUTTON_ROUNDED
EndEnumeration

;- gadget types for module-created gadgets
Enumeration 1
  #SCS_MG_TEXT
  #SCS_MG_COMBOBOX
  #SCS_MG_BUTTON
EndEnumeration

;- windows (forms)
Enumeration 1
  ; sorted by code
  #WAB  ; fmAbout
  #WAC  ; fmAGColors (audio graph colors)
  #WBE  ; fmBulkEdit
  #WCD  ; fmCountdownClock
  #WCI  ; fmCurrInfo
  #WCL  ; fmClock
  #WCM  ; fmCtrlSetup
  #WCN  ; fmControllers
  #WCP  ; fmCopyProps
  #WCS  ; fmColorScheme
  #WDD  ; fmDMXDisplay
  #WDT  ; fmDMXTest
  #WDU  ; fmDummy (dummy hidden window for BASS_Init() calls)
  #WE1  ; fmMemo (main window)
  #WE2  ; fmMemo (preview window)
  #WED  ; fmEditor
  #WEM  ; fmEditModal
  ; #WEN  ; DO NOT USE (dummy code used with #WE1-#WE2)
  #WES  ; fmScribbleStrip
  #WEV  ; fmEditVal
  #WEX  ; fmExport
  #WFF  ; fmFavFiles
  #WFI  ; fmFind
  #WFL  ; fmFileLocator
  #WFO  ; fmFileOpener
  #WFR  ; fmFileRename
  #WFS  ; fmFavFileSelector
  #WIC  ; fmImportCSV
  #WID  ; fmImportDevs
  #WIM  ; fmImport
  #WIR  ; fmInputRequester
  #WLC  ; fmLabelChange
  #WLD  ; fmLinkDevices
  #WLE  ; fmLockEditor
  #WLP  ; fmLoadProd
  #WLV  ; fmCboListView - listview for own-drawn combobox
  #WM2  ; fmMonitor (monitor for screen 2)
  #WM3  ; fmMonitor (monitor for screen 3)
  #WM4  ; fmMonitor (monitor for screen 4)
  #WM5  ; fmMonitor (monitor for screen 5)  see also setLicLimitsEtc()
  #WM6  ; fmMonitor (monitor for screen 6)
  #WM7  ; fmMonitor (monitor for screen 7)
  #WM8  ; fmMonitor (monitor for screen 8)
  #WM9  ; fmMonitor (monitor for screen 9)  see also #WM_LAST (below) and setLicLimitsEtc()
  #WMC  ; fmMultiCueCopyEtc
  #WMI  ; fmInfo
  #WMN  ; fmMain
  #WMT  ; fmMidiTest
  #WNE  ; fmNearEndWarning
  #WOC  ; fmOSCCapture
  #WOP  ; fmOptions
  #WPF  ; fmCollectFiles
  #WPL  ; VST Plugin Editor
  #WPR  ; fmPrintCueList
  #WPT  ; fmProdTimer (see also #WTI)
  #WRG  ; fmRegister
  #WSP  ; fmSplash
  #WSS  ; fmSpecialStart
  #WST  ; slider tooltip
  #WTC  ; MTC display
  #WTI  ; Production Timer display (see also #WPT)
  #WTM  ; fmTemplates (create/maintain templates)
  #WTP  ; fmTimeProfile
  #WUP  ; fmUpdateStatus
  #WV2  ; fmVideo (screen 2)
  #WV3  ; fmVideo (screen 3)
  #WV4  ; fmVideo (screen 4)
  #WV5  ; fmVideo (screen 5)  see also setLicLimitsEtc()
  #WV6  ; fmVideo (screen 6)
  #WV7  ; fmVideo (screen 7)
  #WV8  ; fmVideo (screen 8)
  #WV9  ; fmVideo (screen 9)  see also #WV_LAST (below) and grRegInfo\nLastVideoWindow
; #WVN  ; DO NOT USE (dummy code used with #WV2-#WV9)
  #WVP  ; fmVSTPlugins
  #WYY  ; temporary window used by obtainSplitterSeparatorSizes() and obtainPanelContentOffsets()
  #WZZ  ; dummy last form
EndEnumeration
#WM_LAST = #WM9  ; last fmMonitor window
#WV_LAST = #WV9  ; last fmVideo window
; NB if the above are changed you may also need to change #cMaxScreenNo

;- editor components
Enumeration 1000
  #WEP          ; fmEditProd
  #WEC          ; fmEditCue
  #WQA          ; fmEditQA (video/image cues)
  #WQE          ; fmEditQE (memo cues)
  #WQF          ; fmEditQF (audio file cues)
  #WQG          ; fmEditQG ('go to cue' cues)
  #WQI          ; fmEditQI (live input cues)
  #WQJ          ; fmEditQJ ('enable/disable cue' cues)
  #WQK          ; fmEditQK (lighting cues)
  #WQL          ; fmEditQL (level change cues)
  #WQM          ; fmEditQM (control send cues)
  #WQP          ; fmEditQP (playlist cues)
  #WQQ          ; fmEditQQ ('call cue' cues)
  #WQR          ; fmEditQR (run external program cues)
  #WQS          ; fmEditQS (SFR cues)
  #WQT          ; fmEditQT (set position cues)
  #WQU          ; fmEditQU (MTC/LTC cues)
EndEnumeration

;- sub-cue types
#SCS_ALL_SUBTYPES = "AEFGHIJKLMNPQRSTU" ; nb "N" is not actually a sub-cue, but the cue type of a Note cue, which has no sub-cues

; drag-and-drop private types
Enumeration
  #SCS_PRIVTYPE_DRAG_CUE
EndEnumeration

;- fonts
; see also global variables gsDefFontName and gnDefFontSize
; the following fonts are loaded in setUpGENFonts and setUpWMNFonts (in StartUp.pbi)
Enumeration 1
  ; default font size (8)
  #SCS_FONT_GEN_NORMAL
  #SCS_FONT_GEN_NORMALSTRIKETHRU  ; used in editor 'sub-cue description' field
  #SCS_FONT_GEN_BOLD
  #SCS_FONT_GEN_BOLDUL
  #SCS_FONT_GEN_BOLDSTRIKETHRU    ; used in editor 'cue description' field
  #SCS_FONT_GEN_ITALIC
  #SCS_FONT_GEN_UL
  ; font size 7
  #SCS_FONT_GEN_NORMAL7
  ; font size 9
  #SCS_FONT_GEN_NORMAL9
  #SCS_FONT_GEN_BOLD9
  #SCS_FONT_GEN_BOLDSTRIKETHRU9   ; used in editor cue list tree
  ; font size 10
  #SCS_FONT_GEN_NORMAL10
  #SCS_FONT_GEN_ITALIC10
  #SCS_FONT_GEN_BOLD10
  #SCS_FONT_GEN_UL10
  ; font size 11
  #SCS_FONT_GEN_NORMAL11
  #SCS_FONT_GEN_BOLD11
  ; font size 12
  #SCS_FONT_GEN_NORMAL12            ; used in editor 'cue' and 'cue description' field
  #SCS_FONT_GEN_NORMALSTRIKETHRU12  ; used in editor 'cue' and 'cue description' field
  #SCS_FONT_GEN_BOLD12              ; used in fmMain warning message and in editor 'cue' field
  #SCS_FONT_GEN_BOLDSTRIKETHRU12    ; used in editor 'cue' field
  #SCS_FONT_GEN_UL12                ; used in fmPrintCueList
  ; font size 16
  #SCS_FONT_GEN_ITALIC16          ; italic with font size 16
  ; font size 24
  #SCS_FONT_GEN_BOLD24            ; used in fmMain 'near end' warning message
  ; special fonts
  #SCS_FONT_GEN_WINGDINGS8
  #SCS_FONT_GEN_SYMBOL8
  #SCS_FONT_GEN_SYMBOL9
  
  ; fixed-pitch font for fmOptions message assignment listboxes
  #SCS_FONT_WOP_LISTS
  ; font samples in fmOptions
  #SCS_FONT_WOP_SAMPLE_MAIN
  #SCS_FONT_WOP_SAMPLE_CUE_LIST
  #SCS_FONT_WOP_SAMPLE_OTHERS
  
  ; fonts used in fmMain (excluding cue panels) - names refer to the original settings, but the font sizes will be different when fmMain has been resized
  ; default font size (8)
  #SCS_FONT_WMN_NORMAL
  #SCS_FONT_WMN_BOLD
  #SCS_FONT_WMN_BOLDUL
  #SCS_FONT_WMN_ITALIC
  ; font size 9
  #SCS_FONT_WMN_NORMAL9
  ; font size 10
  #SCS_FONT_WMN_NORMAL10
  #SCS_FONT_WMN_BOLD10
  #SCS_FONT_WMN_ITALIC10        ; italic with font size 10
  ; font size 12
  #SCS_FONT_WMN_BOLD12          ; used in fmMain warning message
  ; font size 16
  #SCS_FONT_WMN_ITALIC16        ; italic with font size 16
  ; ; font size 24
  ; #SCS_FONT_WMN_BOLD24_VERDANA  ; timer display window
  ; ; font size 36
  ; #SCS_FONT_WMN_BOLD36_VERDANA  ; used in fmMain 'near end' warning message, in MTC display window and production timer window
  ; font size for WMN\grdCues
  #SCS_FONT_WMN_GRDCUES
  ; special fonts
  #SCS_FONT_WMN_SYMBOL9
  
  ; fonts used in cue panels on fmMain - names refer to the original settings, but the font sizes will be different when cue panels are resized
  ; default font size (8)
  #SCS_FONT_CUE_NORMAL
  #SCS_FONT_CUE_BOLD
  #SCS_FONT_CUE_UNDERLINE
  ; font size 9
  #SCS_FONT_CUE_NORMAL9
  #SCS_FONT_CUE_ITALIC9
  ; font size 10
  #SCS_FONT_CUE_NORMAL10
  #SCS_FONT_CUE_BOLD10
  #SCS_FONT_CUE_ITALIC10
  ; special fonts
  #SCS_FONT_CUE_SYMBOL9
  
  ; fonts used for main display text in windows that maybe resized by the user, requiring the fonts also to be resized
  #SCS_FONT_WTC   ; MTC display window
  #SCS_FONT_WTI   ; production timer display window
  #SCS_FONT_WNE   ; near-end warning
  #SCS_FONT_WCD   ; Countdown Clock
  #SCS_FONT_WCL   ; Time of Day Clock
  
  ; fonts used in monitor windows
  #SCS_FONT_DRAGBAR
  
  #SCS_FONT_GADGET
  
EndEnumeration

;- menu items
Enumeration 1
  ; keyboard shortcut events (see PB command AddKeyboardShortcut)
  #SCS_mnuKeyboardReturn
  #SCS_mnuKeyboardEscape
;   #SCS_mnuKeyboardCtrlA ; used for 'select all'
;   #SCS_mnuKeyboardCtrlC ; used for 'copy'
  ; lock editor screen menus
  #WLE_mnuLock
  #WLE_mnuCancel
  ; main window's menus (sorted)
  #WMN_mnuASIOControl
  #WMN_mnuCallLinkDevs
  #WMN_mnuCloseAndReOpenDMXDevs
  #WMN_mnuCueControl
  #WMN_mnuCurrInfo
  #WMN_mnuDevMap
  #WMN_mnuDevMapEdit
  #WMN_mnuDevMapItem_0
  #WMN_mnuDevMapItem_1
  #WMN_mnuDevMapItem_2
  #WMN_mnuDevMapItem_3
  #WMN_mnuDevMapItem_4
  #WMN_mnuDevMapItem_5
  #WMN_mnuDevMapItem_6
  #WMN_mnuDevMapItem_7
  #WMN_mnuDevMapItem_8
  #WMN_mnuDevMapItem_9
  #WMN_mnuDMXMastFaderReset
  #WMN_mnuDMXMastFaderSave
  #WMN_mnuEditor
  #WMN_mnuFadeAll
  #WMN_mnuFavFiles
  #WMN_mnuFile
  #WMN_mnuFileExit
  #WMN_mnuFileLoad
  #WMN_mnuFileTemplates
  #WMN_mnuFilePrint
  #WMN_mnuGo
  #WMN_mnuHelp
  #WMN_mnuHelpAbout
  #WMN_mnuHelpCheckForUpdate
  #WMN_mnuHelpClearDTMAInds ; clear 'don't tell me this again' indicators
  #WMN_mnuHelpContents
  #WMN_mnuHelpForums
  #WMN_mnuHelpRegistration
  #WMN_mnuMastFaderReset
  #WMN_mnuMastFaderSave
  ; #WMN_mnuMtrs
  #WMN_mnuMtrsDMXDisplay
  #WMN_mnuMtrsPeakAuto
  #WMN_mnuMtrsPeakHdg
  #WMN_mnuMtrsPeakHold
  #WMN_mnuMtrsPeakOff
  #WMN_mnuMtrsPeakReset
  #WMN_mnuMtrsVUHdg
  #WMN_mnuMtrsVULevels
  #WMN_mnuMtrsVUNone
  #WMN_mnuNavBack
  #WMN_mnuNavEnd
  #WMN_mnuNavFind
  #WMN_mnuNavigate
  #WMN_mnuNavNext
  #WMN_mnuNavTop
  #WMN_mnuNavToCueMarker
  #WMN_mnuOpen
  #WMN_mnuOpenFile
  #WMN_mnuOptions
  #WMN_mnuPauseAll
  #WMN_mnuRecentFile_0
  #WMN_mnuRecentFile_1
  #WMN_mnuRecentFile_2
  #WMN_mnuRecentFile_3
  #WMN_mnuRecentFile_4
  #WMN_mnuRecentFile_5
  #WMN_mnuRecentFile_6
  #WMN_mnuRecentFile_7
  #WMN_mnuRecentFile_8
  #WMN_mnuRecentFile_9
  #WMN_mnuResetStepHKs
  #WMN_mnuSave
  #WMN_mnuSaveAs
  #WMN_mnuSaveFile
  #WMN_mnuSaveReason
  #WMN_mnuSaveSettings
  #WMN_mnuSaveSettingsAllCues
  #WMN_mnuSaveSettingsCue_00
  #WMN_mnuSaveSettingsCue_01
  #WMN_mnuSaveSettingsCue_02
  #WMN_mnuSaveSettingsCue_03
  #WMN_mnuSaveSettingsCue_04
  #WMN_mnuSaveSettingsCue_05
  #WMN_mnuSaveSettingsCue_06
  #WMN_mnuSaveSettingsCue_07
  #WMN_mnuSaveSettingsCue_08
  #WMN_mnuSaveSettingsCue_09
  #WMN_mnuSaveSettingsCue_10
  #WMN_mnuSaveSettingsCue_11
  #WMN_mnuSaveSettingsCue_12
  #WMN_mnuSaveSettingsCue_13
  #WMN_mnuSaveSettingsCue_14
  #WMN_mnuSaveSettingsCue_15
  #WMN_mnuSaveSettingsCue_16
  #WMN_mnuSaveSettingsCue_17
  #WMN_mnuSaveSettingsCue_18
  #WMN_mnuSaveSettingsCue_19     ; see also #SCS_MAX_SAVE_SETTINGS
  #WMN_mnuSaveTemplate
  #WMN_mnuStandbyGo
  #WMN_mnuStopAll
  #WMN_mnuTimeProfile
  #WMN_mnuTracing
  #WMN_mnuView
  #WMN_mnuVST
  #WMN_mnuVUMedium
  #WMN_mnuVUNarrow
  #WMN_mnuVUWide
  #WMN_mnuWindowMenu
  #WMN_mnuViewClock
  #WMN_mnuViewCountdown
  #WMN_mnuViewClearCountdownClock
  #WMN_mnuViewOperModeDesign
  #WMN_mnuViewOperModeRehearsal
  #WMN_mnuViewOperModePerformance

  ; hotkey banks
  #WMN_mnuHB_Parent
  #WMN_mnuHB_00
  #WMN_mnuHB_01
  #WMN_mnuHB_02
  #WMN_mnuHB_03
  #WMN_mnuHB_04
  #WMN_mnuHB_05
  #WMN_mnuHB_06
  #WMN_mnuHB_07
  #WMN_mnuHB_08
  #WMN_mnuHB_09
  #WMN_mnuHB_10
  #WMN_mnuHB_11
  #WMN_mnuHB_12
  
  ; options window menus
  #WOP_mnuASIODevs
  #WOP_mnuASIODev0
  #WOP_mnuASIODev1
  #WOP_mnuASIODev2
  #WOP_mnuASIODev3
  #WOP_mnuASIODev4
  #WOP_mnuASIODev5
  #WOP_mnuASIODev6
  #WOP_mnuASIODev7
  #WOP_mnuASIODev8
  #WOP_mnuASIODev9
  #WOP_mnuASIODev10
  #WOP_mnuASIODev11
  #WOP_mnuASIODev12
  #WOP_mnuASIODev13
  #WOP_mnuASIODev14
  #WOP_mnuASIODev15 ; See also #WOP_mnuASIODevLast ; changed 27/02/2025 by Dee to allow for up to 16 ASIO devices instead of 8, (I have 11 on my system).
  
  ; editor window's menus (sorted)
  #WED_mnuAddQA
  #WED_mnuAddQE
  #WED_mnuAddQF
  #WED_mnuAddQG
  #WED_mnuAddQI
  #WED_mnuAddQJ
  #WED_mnuAddQK
  #WED_mnuAddQL
  #WED_mnuAddQM
  #WED_mnuAddQN
  #WED_mnuAddQP
  #WED_mnuAddQQ
  #WED_mnuAddQR
  #WED_mnuAddQS
  #WED_mnuAddQT
  #WED_mnuAddQU
  #WED_mnuAddSA
  #WED_mnuAddSE
  #WED_mnuAddSF
  #WED_mnuAddSG
  #WED_mnuAddSI
  #WED_mnuAddSJ
  #WED_mnuAddSK
  #WED_mnuAddSL
  #WED_mnuAddSM
  #WED_mnuAddSP
  #WED_mnuAddSQ
  #WED_mnuAddSR
  #WED_mnuAddSS
  #WED_mnuAddST
  #WED_mnuAddSU
  #WED_mnuBulkEditCues
  #WED_mnuCollect
  #WED_mnuCopy
  #WED_mnuCopyProps
  #WED_mnuCueListPopupMenu
  #WED_mnuCuesMenu
  #WED_mnuCut
  #WED_mnuDelete
  #WED_mnuExportCues
  #WED_mnuFavFiles
  #WED_mnuFile
  #WED_mnuHelp
  #WED_mnuHelpContents
  #WED_mnuHelpEditor
  #WED_mnuImportCSV
  #WED_mnuImportCues
  #WED_mnuImportDevs
  #WED_mnuMultiCueCopyEtc
  #WED_mnuNew
  #WED_mnuOpen
  #WED_mnuOpenFile
  #WED_mnuOptions
  #WED_mnuOtherActions
  #WED_mnuPaste
  #WED_mnuPlaylist
  #WED_mnuPLRemove
  #WED_mnuPLRename
  #WED_mnuPrint
  #WED_mnuProdMenu
  #WED_mnuProdFolder
  #WED_mnuProdImportExport
  #WED_mnuProdProperties
  #WED_mnuProdTimer
  #WED_mnuRecentFile_0
  #WED_mnuRecentFile_1
  #WED_mnuRecentFile_2
  #WED_mnuRecentFile_3
  #WED_mnuRecentFile_4
  #WED_mnuRecentFile_5
  #WED_mnuRecentFile_6
  #WED_mnuRecentFile_7
  #WED_mnuRecentFile_8
  #WED_mnuRecentFile_9
  #WED_mnuRenumberCues
  #WED_mnuSaveAs
  #WED_mnuSubsMenu
  #WED_mnuTapDelay
  #WED_mnuUndoRedoMenu
  #WED_mnuUndoRedoInfo
  ; editor favorites
  ; must be same order as toolbar button id's #SCS_TBEB_FAV_START to #SCS_TBEB_FAV_END
  #WED_mnuFavStart    ; dummy entry - not a real menu item
  #WED_mnuFavAddQA    ; must be first AddQ entry, or need to change WED_getFavBtnForFavMnu()
  #WED_mnuFavAddQF
  #WED_mnuFavAddQG
  #WED_mnuFavAddQI
  #WED_mnuFavAddQK
  #WED_mnuFavAddQL
  #WED_mnuFavAddQM
  #WED_mnuFavAddQN
  #WED_mnuFavAddQE
  #WED_mnuFavAddQP
  #WED_mnuFavAddQR
  #WED_mnuFavAddQS
  #WED_mnuFavAddQT
  #WED_mnuFavAddQQ
  #WED_mnuFavAddQU    ; must be last AddQ entry, or need to change WED_getFavBtnForFavMnu()
  #WED_mnuFavAddSA    ; must be first AddS entry, or need to change WED_getFavBtnForFavMnu()
  #WED_mnuFavAddSF
  #WED_mnuFavAddSG
  #WED_mnuFavAddSI
  #WED_mnuFavAddSK
  #WED_mnuFavAddSL
  #WED_mnuFavAddSM
  #WED_mnuFavAddSE
  #WED_mnuFavAddSP
  #WED_mnuFavAddSR
  #WED_mnuFavAddSS
  #WED_mnuFavAddST
  #WED_mnuFavAddSQ
  #WED_mnuFavAddSU    ; must be last AddS entry, or need to change WED_getFavBtnForFavMnu()
  #WED_mnuFavEnd      ; dummy entry - not a real menu item
  #WED_mnuFavsInfo
  #WED_mnuFavsMenu
  ; production properties - fixture types - channel colors for DMX display
  #WEP_mnuGridColors ; grid colors group
  #WEP_mnuGrdColBlack
  #WEP_mnuGrdColWhite
  #WEP_mnuGrdColRed
  #WEP_mnuGrdColGreen
  #WEP_mnuGrdColBlue
  #WEP_mnuGrdColYellow
  #WEP_mnuGrdColCyan
  #WEP_mnuGrdColAmber
  #WEP_mnuGrdColUV
  #WEP_mnuGrdColPicker
  #WEP_mnuGridColorsDummyLast
  ; production properties - control send device types
  #WEP_mnuCSDevTypes
  #WEP_mnuCSDevTypeMidiOut
  #WEP_mnuCSDevTypeMidiThru
  #WEP_mnuCSDevTypeRS232Out
  #WEP_mnuCSDevTypeNetworkOut
  #WEP_mnuCSDevTypeHTTPRequest
  ; print cue list menu items (sorted)
  #WPR_mnuColAC
  #WPR_mnuColCS
  #WPR_mnuColCT
  #WPR_mnuColCU
  #WPR_mnuColDE
  #WPR_mnuColDefaults
  #WPR_mnuColDU
  #WPR_mnuColFN
  #WPR_mnuColFT
  #WPR_mnuColLV
  #WPR_mnuColMC
  #WPR_mnuColPG
  #WPR_mnuColRevert
  #WPR_mnuColSD
  #WPR_mnuColWR
  #WPR_mnuFileClose
  #WPR_mnuFilePrint
  #WPR_mnuWindowMenu
  
  ; video/image editor menu items (grouped!!!)
  #WQA_mnu_DummyFirst
  #WQA_mnuRotate            ; 'rotate' group
  #WQA_mnuFlipH
  #WQA_mnuFlipV
  #WQA_mnuRotate180
  #WQA_mnuRotateL90
  #WQA_mnuRotateR90
  #WQA_mnuRotateReset
  #WQA_mnuRotateDummyLast   ; dummy entry
  #WQA_mnuOther             ; 'other' group
  #WQA_mnuOtherCopy
  #WQA_mnuOtherDefault
  #WQA_mnuOtherPaste
  #WQA_mnuOtherDummyLast    ; dummy entry
  ; cue marker menu items
  #WQA_mnu_GraphContextMenu
  #WQA_mnu_SetPos
  #WQA_mnu_EditCueMarker
  #WQA_mnu_RemoveCueMarker
  #WQA_mnu_SetCueMarkerPos
  #WQA_mnu_ViewOnCues
  #WQA_mnu_ViewCueMarkersUsage
  #WQA_mnu_AddQuickCueMarkers
  #WQA_mnu_RemoveAllUnusedCueMarkersFromThisFile
  #WQA_mnu_RemoveAllUnusedCueMarkers
  #WQA_mnu_DummyLast
  
  ; memo toolbar menu items
  #WQE_mnu_DummyFirst
  #WQE_mnu_PageColor
  #WQE_mnu_TextBackColor
  #WQE_mnu_TextColor
  #WQE_mnu_Font
  #WQE_mnu_Search
  #WQE_mnu_Cut
  #WQE_mnu_Copy
  #WQE_mnu_Paste
  #WQE_mnu_Undo
  #WQE_mnu_Redo
  #WQE_mnu_Bold
  #WQE_mnu_Italic
  #WQE_mnu_Underline
  #WQE_mnu_Left
  #WQE_mnu_Center
  #WQE_mnu_Right
  #WQE_mnu_SelectAll
  #WQE_mnu_Indent
  #WQE_mnu_Outdent
  #WQE_mnu_List
  #WQE_mnu_Misc
  #WQE_mnu_misc_popup_menu
  #WQE_mnu_linespacing_1
  #WQE_mnu_linespacing_1_5
  #WQE_mnu_linespacing_2_0 
  #WQE_mnu_pct_10
  #WQE_mnu_pct_25
  #WQE_mnu_pct_50
  #WQE_mnu_pct_75
  #WQE_mnu_pct_100
  #WQE_mnu_pct_125
  #WQE_mnu_pct_150
  #WQE_mnu_pct_200
  #WQE_mnu_pct_400
  #WQE_mnu_DummyLast
  
  ; audio graph level right-click menu
  #WQF_mnu_DummyFirst
  #WQF_mnu_GraphContextMenu
  #WQF_mnu_AddFadeInLvlPt
  #WQF_mnu_AddFadeOutLvlPt
  #WQF_mnu_AddStdLvlPt
  #WQF_mnu_RemoveLvlPt
  #WQF_mnu_SameLvlAsPrev
  #WQF_mnu_SameLvlAsNext
  #WQF_mnu_SamePanAsPrev
  #WQF_mnu_SamePanAsNext
  #WQF_mnu_SameAsPrev
  #WQF_mnu_SameAsNext
  #WQF_mnu_ShowLvlCurvesSel
  #WQF_mnu_ShowPanCurvesSel
  #WQF_mnu_ShowLvlCurvesOther
  #WQF_mnu_ShowPanCurvesOther
  #WQF_mnu_SetStartAt
  #WQF_mnu_SetEndAt
  #WQF_mnu_SetLoopStart
  #WQF_mnu_SetLoopEnd
  #WQF_mnu_SetPos
  #WQF_mnu_EditCueMarker
  #WQF_mnu_RemoveCueMarker
  #WQF_mnu_SetCueMarkerPos
  #WQF_mnu_ViewOnCues
  #WQF_mnu_ViewCueMarkersUsage
  #WQF_mnu_AddQuickCueMarkers
  #WQF_mnu_RemoveAllUnusedCueMarkersFromThisFile
  #WQF_mnu_RemoveAllUnusedCueMarkers

  ; audio file cue 'other actions' button menu
  #WQF_mnu_Other
  #WQF_mnu_ResetAll
  #WQF_mnu_ClearAll
  ; #WQF_mnu_SetStart
  #WQF_mnu_StartTrimSilence
  #WQF_mnu_StartTrim75 ; Added 3Oct2022 11.9.6
  #WQF_mnu_StartTrim60 ; Added 3Oct2022 11.9.6
  #WQF_mnu_StartTrim45
  #WQF_mnu_StartTrim30
  ; #WQF_mnu_SetEnd
  #WQF_mnu_EndTrimSilence
  #WQF_mnu_EndTrim75 ; Added 3Oct2022 11.9.6
  #WQF_mnu_EndTrim60 ; Added 3Oct2022 11.9.6
  #WQF_mnu_EndTrim45
  #WQF_mnu_EndTrim30
  #WQF_mnu_ChangeFreqTempoPitch
  #WQF_mnu_CallLinkDevs
  #WQF_mnu_RenameFile
  #WQF_mnu_ExternalAudioEditor
  ; end of audio file menu items
  #WQF_mnu_DummyLast
  ; playlist menu items
  #WQP_mnu_DummyFirst
  ; playlist cue 'other actions' button menu
  #WQP_mnu_Other
  #WQP_mnu_TrimSilenceSel
  #WQP_mnu_Trim75Sel ; Added 3Oct2022 11.9.6
  #WQP_mnu_Trim60Sel ; Added 3Oct2022 11.9.6
  #WQP_mnu_Trim45Sel
  #WQP_mnu_Trim30Sel
  #WQP_mnu_ResetSel
  #WQP_mnu_ClearSel
  #WQP_mnu_TrimSilenceAll
  #WQP_mnu_Trim75All ; Added 3Oct2022 11.9.6
  #WQP_mnu_Trim60All ; Added 3Oct2022 11.9.6
  #WQP_mnu_Trim45All
  #WQP_mnu_Trim30All
  #WQP_mnu_ResetAll
  #WQP_mnu_ClearAll
  #WQP_mnu_LUFSNorm100All
  #WQP_mnu_LUFSNorm90All
  #WQP_mnu_LUFSNorm80All
  CompilerIf #c_include_peak
  #WQP_mnu_PeakNormAll
  CompilerEndIf
  #WQP_mnu_TruePeakNorm100All
  #WQP_mnu_TruePeakNorm90All
  #WQP_mnu_TruePeakNorm80All
  #WQP_mnu_PeakNorm100All
  #WQP_mnu_PeakNorm90All
  #WQP_mnu_PeakNorm80All
  #WQP_mnu_RemoveAllFiles
  ; end of playlist menu items
  #WQP_mnu_DummyLast
  
  ; cue panel switch popup menu
  #PNL_mnu_switch_popup
  #PNL_mnu_switch_file
  #PNL_mnu_switch_sub
  #PNL_mnu_switch_cue
  
  ; DMX display back color popup menu
  #WDD_mnu_BackColor_Popup
  #WDD_mnu_BackColor_Default
  #WDD_mnu_BackColor_Picker
  
EndEnumeration
#SCS_MAX_MENU_ITEM = #PB_Compiler_EnumerationValue - 1
#WOP_mnuASIODevLast = #WOP_mnuASIODev15         ; changed 27/02/2025 by Dee to allow for up to 16 ASIO devices instead of 8, (I have 11 on my system).

;- shortcut functions
Enumeration #SCS_MAX_MENU_ITEM + 1   ; PB keyboard shortcuts raise menu events so event numbers must not clash with actual menu event numbers
  #SCS_ALLF_DummyFirst
  ; main window (#WMN) functions
  #SCS_WMNF_Go
  #SCS_WMNF_GoConfirm
  #SCS_WMNF_PauseResumeAll
  #SCS_WMNF_StopAll
  #SCS_WMNF_FadeAll
  #SCS_WMNF_MastFdrUp
  #SCS_WMNF_MastFdrDown
  #SCS_WMNF_MastFdrReset
  #SCS_WMNF_MastFdrMute
  #SCS_WMNF_DecPlayingCues
  #SCS_WMNF_IncPlayingCues
  #SCS_WMNF_DecLastPlayingCue
  #SCS_WMNF_IncLastPlayingCue
  #SCS_WMNF_SaveCueSettings
  #SCS_WMNF_CueListUpOneRow
  #SCS_WMNF_CueListDownOneRow
  #SCS_WMNF_CueListUpOnePage
  #SCS_WMNF_CueListDownOnePage
  #SCS_WMNF_CueListTop
  #SCS_WMNF_CueListEnd
  #SCS_WMNF_FindCue
  #SCS_WMNF_ExclCueOverride
  #SCS_WMNF_TapDelay
  #SCS_WMNF_DMXMastFdrUp
  #SCS_WMNF_DMXMastFdrDown
  #SCS_WMNF_DMXMastFdrReset
  #SCS_WMNF_CueMarkerPrev
  #SCS_WMNF_CueMarkerNext
  #SCS_WMNF_MoveToTime
  #SCS_WMNF_CallLinkDevs
  #SCS_WMNF_FavFile1
  #SCS_WMNF_FavFile2
  #SCS_WMNF_FavFile3
  #SCS_WMNF_FavFile4
  #SCS_WMNF_FavFile5
  #SCS_WMNF_FavFile6
  #SCS_WMNF_FavFile7
  #SCS_WMNF_FavFile8
  #SCS_WMNF_FavFile9
  #SCS_WMNF_FavFile10
  #SCS_WMNF_FavFile11
  #SCS_WMNF_FavFile12
  #SCS_WMNF_FavFile13
  #SCS_WMNF_FavFile14
  #SCS_WMNF_FavFile15
  #SCS_WMNF_FavFile16
  #SCS_WMNF_FavFile17
  #SCS_WMNF_FavFile18
  #SCS_WMNF_FavFile19
  #SCS_WMNF_FavFile20
  ; hotkeys - these MUST be in the same order as listed in gsValidHotkeys (see Globals.pbi)
  #SCS_WMNF_HK_A  ; nb must be FIRST of the hotkeys for "Case #SCS_WMNF_HK_A To #SCS_WMNF_HK_PGDN"
  #SCS_WMNF_HK_B
  #SCS_WMNF_HK_C
  #SCS_WMNF_HK_D
  #SCS_WMNF_HK_E
  #SCS_WMNF_HK_F
  #SCS_WMNF_HK_G
  #SCS_WMNF_HK_H
  #SCS_WMNF_HK_I
  #SCS_WMNF_HK_J
  #SCS_WMNF_HK_K
  #SCS_WMNF_HK_L
  #SCS_WMNF_HK_M
  #SCS_WMNF_HK_N
  #SCS_WMNF_HK_O
  #SCS_WMNF_HK_P
  #SCS_WMNF_HK_Q
  #SCS_WMNF_HK_R
  #SCS_WMNF_HK_S
  #SCS_WMNF_HK_T
  #SCS_WMNF_HK_U
  #SCS_WMNF_HK_V
  #SCS_WMNF_HK_W
  #SCS_WMNF_HK_X
  #SCS_WMNF_HK_Y
  #SCS_WMNF_HK_Z
  #SCS_WMNF_HK_1
  #SCS_WMNF_HK_2
  #SCS_WMNF_HK_3
  #SCS_WMNF_HK_4
  #SCS_WMNF_HK_5
  #SCS_WMNF_HK_6
  #SCS_WMNF_HK_7
  #SCS_WMNF_HK_8
  #SCS_WMNF_HK_9
  #SCS_WMNF_HK_0
  #SCS_WMNF_HK_F1
  #SCS_WMNF_HK_F2
  #SCS_WMNF_HK_F3
  #SCS_WMNF_HK_F4
  #SCS_WMNF_HK_F5
  #SCS_WMNF_HK_F6
  #SCS_WMNF_HK_F7
  #SCS_WMNF_HK_F8
  #SCS_WMNF_HK_F9
  #SCS_WMNF_HK_F10
  #SCS_WMNF_HK_F11
  #SCS_WMNF_HK_F12
; Added 25Jul2020 but commented out when I realised that some of these 'shortcut keys' are already used as Master Fader shortcut keys
;   #SCS_WMNF_HK_ADD
;   #SCS_WMNF_HK_SUBTRACT
;   #SCS_WMNF_HK_DIVIDE
;   #SCS_WMNF_HK_MULTIPLY
;   #SCS_WMNF_HK_DECIMAL  ; nb must be LAST of the hotkeys for "Case #SCS_WMNF_HK_A To #SCS_WMNF_HK_DECIMAL"
  ; Added 17Apr2022 11.9.1bb
  #SCS_WMNF_HK_PGUP
  #SCS_WMNF_HK_PGDN ; nb must be LAST of the hotkeys for "Case #SCS_WMNF_HK_A To #SCS_WMNF_HK_PGDN"
  ; End added 17Apr2022 11.9.1bb
  ; hotkey banks
  #SCS_WMNF_HB_00
  #SCS_WMNF_HB_01
  #SCS_WMNF_HB_02
  #SCS_WMNF_HB_03
  #SCS_WMNF_HB_04
  #SCS_WMNF_HB_05
  #SCS_WMNF_HB_06
  #SCS_WMNF_HB_07
  #SCS_WMNF_HB_08
  #SCS_WMNF_HB_09
  #SCS_WMNF_HB_10
  #SCS_WMNF_HB_11
  #SCS_WMNF_HB_12
  ; editor window
  #SCS_WEDF_Save
  #SCS_WEDF_Undo
  #SCS_WEDF_Redo
  #SCS_WEDF_FindCue
  #SCS_WEDF_Rewind
  #SCS_WEDF_PlayPause
  #SCS_WEDF_Stop
  #SCS_WEDF_DecLevels
  #SCS_WEDF_IncLevels
  #SCS_WEDF_SelectAll
  #SCS_WEDF_AddCueMarker
  #SCS_WEDF_CueMarkerPrev
  #SCS_WEDF_CueMarkerNext
  #SCS_WEDF_SkipBack
  #SCS_WEDF_SkipForward
  #SCS_WEDF_CallLinkDevs
  #SCS_WEDK_TapDelay
  ; functions common to many windows
  #SCS_ALLF_BumpLeft
  #SCS_ALLF_BumpRight
  ;
  #SCS_ALLF_DummyLast
EndEnumeration
; undo/redo menu items - theoretically unlimited in number so starting point must be beyond all other menu numbers
#WED_mnuUndoRedo_01 = #SCS_ALLF_DummyLast + 1
; do not enter any menu numbers greater than #WED_mnuUndoRedo_01 as these are reserved for the equivalents of #WED_mnuUndoRedo_02, #WED_mnuUndoRedo_03, ...

;- variant types for tyVariant
Enumeration
  #SCS_VAR_S
  #SCS_VAR_L
  #SCS_VAR_F
  #SCS_VAR_D ; Added 19Jul2022
EndEnumeration

;- operational modes
Enumeration
  #SCS_OPERMODE_DESIGN
  #SCS_OPERMODE_REHEARSAL
  #SCS_OPERMODE_PERFORMANCE
EndEnumeration
#SCS_OPERMODE_LAST = #PB_Compiler_EnumerationValue - 1
#SCS_USER_COLUMN_LENGTH = 20
#SCS_USER_COLUMN_DUMMY_TEXT = "WWWWWWWWWWWWWWWWWWWWW"

;- image flip
; flags that may be combined, so 3 = flip horizontal AND vertical; 0 = no flip
#SCS_FLIPH = 1
#SCS_FLIPV = 2

;- import types
Enumeration
  ; nb values do NOT have to match order of buttons
  #SCS_IMPORT_CANCEL
  #SCS_IMPORT_AUDIO_CUES
  #SCS_IMPORT_PLAYLIST
EndEnumeration

;- import csv file types
Enumeration 1
  #SCS_IMP_CSV_STD
  #SCS_IMP_CSV_ETC
EndEnumeration

;- import device row types
Enumeration 1
  #SCS_IMD_HEADER
  #SCS_IMD_DEVMAP
  #SCS_IMD_DEVICE
EndEnumeration

;- item types
Enumeration 1
  #SCS_ITEM_PROD
  #SCS_ITEM_CUE
  #SCS_ITEM_SUB
  #SCS_ITEM_AUD
  #SCS_ITEM_FILE
EndEnumeration

;- option nodes
Enumeration 0
  ; nb do NOT have to be in order - they are just unique identifiers
  #SCS_OPTNODE_ROOT
  #SCS_OPTNODE_GENERAL
  #SCS_OPTNODE_DISPLAY
  #SCS_OPTNODE_DISPLAY_DESIGN
  #SCS_OPTNODE_DISPLAY_REHEARSAL
  #SCS_OPTNODE_DISPLAY_PERFORMANCE
  #SCS_OPTNODE_COLS
  #SCS_OPTNODE_COLS_DESIGN
  #SCS_OPTNODE_COLS_REHEARSAL
  #SCS_OPTNODE_COLS_PERFORMANCE
  #SCS_OPTNODE_AUDIO_DRIVER
  #SCS_OPTNODE_BASS_DS ; 'DS' originally just for DirectSound, but now also includes WASAPI
  #SCS_OPTNODE_BASS_ASIO
  #SCS_OPTNODE_SMS_ASIO
  #SCS_OPTNODE_VIDEO_DRIVER
  #SCS_OPTNODE_RAI
  #SCS_OPTNODE_FUNCTIONAL_MODE
  #SCS_OPTNODE_SHORTCUTS
  #SCS_OPTNODE_EDITING
  #SCS_OPTNODE_SESSION
EndEnumeration
#SCS_OPTNODE_LAST = #PB_Compiler_EnumerationValue - 1

;- option containers
Enumeration
  ; nb do NOT have to be in order - they are just unique identifiers
  #SCS_OPTCNT_GENERAL
  #SCS_OPTCNT_DISPLAY
  #SCS_OPTCNT_COLS
  #SCS_OPTCNT_AUDIO_DRIVER
  #SCS_OPTCNT_BASS_DS
  #SCS_OPTCNT_BASS_ASIO
  #SCS_OPTCNT_SMS_ASIO
  #SCS_OPTCNT_VIDEO_DRIVER
  #SCS_OPTCNT_RAI
  #SCS_OPTCNT_SHORTCUTS
  #SCS_OPTCNT_EDITING
  #SCS_OPTCNT_SESSION
  #SCS_OPTCNT_FUNCTIONAL_MODE
EndEnumeration

;- functional modes 
Enumeration 
  #SCS_FM_STAND_ALONE
  #SCS_FM_PRIMARY
  #SCS_FM_BACKUP
EndEnumeration

;- menu button gadget flags
#SCS_MBG_ALIGN_CENTER = 0   ; default alignment
#SCS_MBG_ALIGN_LEFT = 1
#SCS_MBG_ALIGN_RIGHT = 2
#SCS_MBG_BORDER = 4
#SCS_MBG_AUTOSIZE = 8

;- control panel position
Enumeration 0
  #SCS_CTRLPANEL_TOP        ; default
  #SCS_CTRLPANEL_BOTTOM
  #SCS_CTRLPANEL_NONE
EndEnumeration

;- grid types
Enumeration 1
  #SCS_GT_GRDCOMMPORTS
  #SCS_GT_GRDCTRLSENDS
  #SCS_GT_GRDCUEPRINT
  #SCS_GT_GRDCUES
  #SCS_GT_GRDEXPORT
  #SCS_GT_GRDSHORTCUTS
  #SCS_GT_GRDTBC
  #SCS_GT_EXPWFO
EndEnumeration

;- column indexes for grdCommPorts(WOP\grdCommPorts)
Enumeration 0
  #SCS_GRDCOMMPORTS_PORT
  #SCS_GRDCOMMPORTS_IN
  #SCS_GRDCOMMPORTS_OUT
EndEnumeration

;- column indexes for grdCtrlSends (WQM\grdCtrlSends)
Enumeration 0
  #SCS_GRDCTRLSENDS_SEQ   ; Sequence
  #SCS_GRDCTRLSENDS_INFO  ; Info
EndEnumeration
#SCS_GRDCTRLSENDS_LAST = #PB_Compiler_EnumerationValue - 1

;- column indexes for grdCuePrint (WPR\grdCuePrint)
; see also call to registerGrid() in createfmPrintCueList(), and getIndexForColType()
Enumeration 0
  #SCS_GRDCUEPRINT_CU   ; Cue
  #SCS_GRDCUEPRINT_DE   ; Description
  #SCS_GRDCUEPRINT_CT   ; Cue Type
  #SCS_GRDCUEPRINT_AC   ; Activation
  #SCS_GRDCUEPRINT_FN   ; File / Info
  #SCS_GRDCUEPRINT_DU   ; Length (Duration)
  #SCS_GRDCUEPRINT_SD   ; Device
  #SCS_GRDCUEPRINT_WR   ; When Required
  #SCS_GRDCUEPRINT_MC   ; MIDI Cue #
  #SCS_GRDCUEPRINT_FT   ; File Type
  #SCS_GRDCUEPRINT_PG   ; Page
  #SCS_GRDCUEPRINT_LV   ; Level (dB)
EndEnumeration
#SCS_GRDCUEPRINT_LAST = #PB_Compiler_EnumerationValue - 1

;- column indexes for grdCues (WMN\grdCues)
; see also call to registerGrid() in createfmMain(), and getIndexForColType()
Enumeration 0
  #SCS_GRDCUES_CU   ; Cue
  #SCS_GRDCUES_DE   ; Description
  #SCS_GRDCUES_CT   ; Cue Type
  #SCS_GRDCUES_CS   ; Cue State
  #SCS_GRDCUES_AC   ; Activation
  #SCS_GRDCUES_FN   ; File / Info
  #SCS_GRDCUES_DU   ; Length (Duration)
  #SCS_GRDCUES_SD   ; Device
  #SCS_GRDCUES_WR   ; When Required
  #SCS_GRDCUES_MC   ; MIDI Cue #
  #SCS_GRDCUES_FT   ; File Type
  #SCS_GRDCUES_PG   ; Page
  #SCS_GRDCUES_LV   ; Level (dB)
EndEnumeration
#SCS_GRDCUES_LAST = #PB_Compiler_EnumerationValue - 1

;- column indexes for grdShortCuts (WOP\grdShortcuts)
Enumeration 0
  #SCS_GRDKEYS_FUNCTION
  #SCS_GRDKEYS_SHORTCUT
EndEnumeration
#SCS_GRDKEYS_LAST = #PB_Compiler_EnumerationValue - 1

;- column indexes for grdTBC (WEC\grdTBC)
Enumeration 0
  #SCS_GRDTBC_PR        ; Time Profile
  #SCS_GRDTBC_TM        ; Time of Day
EndEnumeration
#SCS_GRDTBC_LAST = #PB_Compiler_EnumerationValue - 1

;- column indexes for WFO\expList (ExplorerListGadget)
Enumeration 0
  #SCS_WFOLIST_NM       ; Name (#PB_Explorer_Name)
  #SCS_WFOLIST_SZ       ; Size (#PB_Explorer_Size)
  #SCS_WFOLIST_TY       ; Type (#PB_Explorer_Type)
  #SCS_WFOLIST_DM       ; Date Modified (#PB_Explorer_Modified)
  #SCS_WFOLIST_LN       ; Length
  #SCS_WFOLIST_TI       ; Title
EndEnumeration
#SCS_WFOLIST_LAST = #PB_Compiler_EnumerationValue - 1

;- grid click actions
Enumeration
  #SCS_GRDCLICK_GOTO_CUE
  #SCS_GRDCLICK_SET_GO_BUTTON_ONLY
  #SCS_GRDCLICK_IGNORE
EndEnumeration

;- tab id's for Production Properties
Enumeration 0
  #SCS_PROD_TAB_GENERAL
  #SCS_PROD_TAB_DEVS
  #SCS_PROD_TAB_AUD_DEVS        ; audio output devices (device group #SCS_DEVGRP_AUDIO_OUTPUT)
  #SCS_PROD_TAB_VIDEO_AUD_DEVS  ; video audio devices (device group #SCS_DEVGRP_VIDEO_AUDIO)
  #SCS_PROD_TAB_VIDEO_CAP_DEVS  ; video capture devices (device group #SCS_DEVGRP_VIDEO_CAPTURE)
  #SCS_PROD_TAB_LIVE_DEVS       ; live input devices (device group #SCS_DEVGRP_LIVE_INPUT)
  #SCS_PROD_TAB_IN_GRPS         ; input groups
  #SCS_PROD_TAB_SUB_GRPS        ; sub groups
  #SCS_PROD_TAB_FIX_TYPES       ; fixture types
  #SCS_PROD_TAB_LIGHTING_DEVS   ; lighting devices (device group #SCS_DEVGRP_LIGHT)
  #SCS_PROD_TAB_CTRL_DEVS       ; ctrl send devices (device group #SCS_DEVGRP_CTRL_SEND)
  #SCS_PROD_TAB_CUE_DEVS        ; cue control devices (device group #SCS_DEVGRP_CUE_CTRL)
  #SCS_PROD_TAB_TIME_PROFILES
  #SCS_PROD_TAB_RUN_TIME_SETTINGS
  ; #SCS_PROD_TAB_VST_PLUGINS     ; vst plugins tab
EndEnumeration
#SCS_PROD_TAB_LAST = #PB_Compiler_EnumerationValue - 1

;- tab indexes for Production Properties Devices tabs (only)
Enumeration 0
  #SCS_PROD_TAB_INDEX_AUD_DEVS        ; audio output devices (device group #SCS_DEVGRP_AUDIO_OUTPUT)
  #SCS_PROD_TAB_INDEX_VIDEO_AUD_DEVS  ; video audio devices (device group #SCS_DEVGRP_VIDEO_AUDIO)
  #SCS_PROD_TAB_INDEX_VIDEO_CAP_DEVS  ; video capture devices (device group #SCS_DEVGRP_VIDEO_CAPTURE)
  #SCS_PROD_TAB_INDEX_LIVE_DEVS       ; live input devices (device group #SCS_DEVGRP_LIVE_INPUT)
  #SCS_PROD_TAB_INDEX_LIGHTING_DEVS   ; lighting devices (device group #SCS_DEVGRP_LIGHT)
  #SCS_PROD_TAB_INDEX_CTRL_DEVS       ; ctrl send devices (device group #SCS_DEVGRP_CTRL_SEND)
  #SCS_PROD_TAB_INDEX_CUE_DEVS        ; cue control devices (device group #SCS_DEVGRP_CUE_CTRL)
  #SCS_PROD_TAB_INDEX_VST_PLUGINS     ; vst plugins devices (device group #SCS_DEVGRP_VST_PLUGINS)
EndEnumeration
#SCS_PROD_TAB_INDEX_LAST = #PB_Compiler_EnumerationValue - 1

;- templates
;- tab id's for templates
Enumeration
  #SCS_WTM_TAB_TEMPLATE
  #SCS_WTM_TAB_CUES
  #SCS_WTM_TAB_DEVS
EndEnumeration

; tab id's for VST Plugins
Enumeration
  #SCS_WVP_TAB_LIBRARY
  #SCS_WVP_TAB_DEV_PLUGINS
  #SCS_WVP_TAB_CUE_PLUGINS
EndEnumeration

;-  max values for structure arrays
#SCS_MAX_MATRIX = 15
#SCS_MAX_CUE_PANEL_DEV_LINE = 15
; Added 25Jul2020 but commented out when I realised that some of these 'shortcut keys' are already used as Master Fader shortcut keys
; CompilerIf #c_extra_hotkeys
;   #SCS_MAX_HOTKEY = 52            ; A-Z, 0-9, F1-F12, +-/*.
; CompilerElse
#SCS_MAX_HOTKEY = 47            ; A-Z, 0-9, F1-F12
; CompilerEndIf
#SCS_MAX_HOTKEY_BANK = 12
#SCS_MAX_TIME_PROFILE = 9 ; mod 28Jan2021 11.8.4 (was 3)
#SCS_MAX_DEV_CHANNEL = 20
#SCS_MAX_OUTPUT_ARRAY_INDEX = 30
#SCS_MAX_COLOR_SCHEME = 9
#SCS_MAX_CTRL_SEND = 31 ; 15 ; increased 25Mar2019 11.8.0.2ck to accommodate the full 32 channels of an X32
#SCS_MAX_DEV_MAP = 19
#SCS_MAX_SPLIT_SCREENS = 10
#SCS_MAX_EQ_BAND = 1
#SCS_MAX_NETWORK_MSG_RESPONSE = 4
#SCS_MAX_ITEM_IN_COPY_PROPERTIES = 7
#SCS_MAX_LOOP = 7
#SCS_MAX_CALLABLE_CUE_PARAM = 3

#SCS_MAX_AUDIO_DEV_PER_DEVMAP = 511
#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB = 15 ; See also #WQF_mnu_LinkDev..
#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL = 15
#SCS_MAX_LIVE_INPUT_DEV_PER_AUD = 15
#SCS_MAX_VST_LIB_PLUGIN = 7
#SCS_MAX_VST_DEV_PLUGIN = 2

; The following constants MUST be kept in sync, but note that #SCS_MAX_FIX_TYPE_CHANNEL is the actual 1-based maximum
; whereas #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB is a 0-based maximum so should be 1 less than #SCS_MAX_FIX_TYPE_CHANNEL
; #SCS_MAX_FIX_TYPE_CHANNEL = 48 ; 32 ; increased from 32 to 48 14Feb2020 11.8.2.2am following Forum Feature Request from SilverTech (Peter Holmes)
; #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB = 47 ; 31 increase from 31 to 47 15Feb2020 11.8.2.2am to match #SCS_MAX_FIX_TYPE_CHANNEL
#SCS_MAX_FIX_TYPE_CHANNEL = 100 ; increased from 48 to 100 10Feb2024 11.10.2ak following email from Mike Ellis in which he has 65 lighting fixtures, and was trying to use more than 48 in a single lighting cue
#SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB = #SCS_MAX_FIX_TYPE_CHANNEL - 1
#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB = #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB

; #SCS_MAX_MNUFONTVALUE = #WMN_mnuFontValue_13 - #WMN_mnuFontValue_0      ; see also scswindows.pbi #WMN_mnuFontValue...
#SCS_MAX_GRDCOL = #SCS_GRDCUES_LAST   ; sets size of grid info col arrays
#SCS_MAX_SFR = 4
#SCS_MAX_ENABLE_DISABLE = 9 ; increased from 4 6Apr2022 11.9.1az following request from Mike Pope
#SCS_MAX_SAVE_SETTINGS = 20
#SCS_MAX_FAV_FILE = 19
#SCS_MAX_ED_FAV = 7 ; increased from 5 26Dec2023 11.10.0 ; max favorite button in toolbar (max number = #SCS_MAX_ED_FAV + 1, ie up to 8 favorites if #SCS_MAX_ED_FAV = 7)

;- shortcut array indexes (main window shortcuts) IN DISPLAY ORDER in fmOptions/Shortcuts
Enumeration
  ; file category
;   #SCS_ShortMain_Load
;   #SCS_ShortMain_Templates
;   #SCS_ShortMain_FavFile1
  #SCS_ShortMain_Save
  #SCS_ShortMain_SaveAs
  #SCS_ShortMain_Print
  #SCS_ShortMain_Options
  ; cue control category
  #SCS_ShortMain_GoButton
  #SCS_ShortMain_GoConfirm
  #SCS_ShortMain_PauseResumeAll
  #SCS_ShortMain_StopAll
  #SCS_ShortMain_FadeAll
  #SCS_ShortMain_CueListUpOneRow
  #SCS_ShortMain_CueListDownOneRow
  #SCS_ShortMain_CueListUpOnePage
  #SCS_ShortMain_CueListDownOnePage
  #SCS_ShortMain_CueListTop
  #SCS_ShortMain_CueListEnd
  #SCS_ShortMain_FindCue
  #SCS_ShortMain_HotkeyBank1
  ; editing category
  #SCS_ShortMain_Editor
  #SCS_ShortMain_SaveCueSettings
  ; help category
  ; meters category
  ; others
  #SCS_ShortMain_MastFdrDown
  #SCS_ShortMain_MastFdrUp
  #SCS_ShortMain_MastFdrReset
  #SCS_ShortMain_MastFdrMute
  #SCS_ShortMain_DecPlayingCues
  #SCS_ShortMain_IncPlayingCues
  #SCS_ShortMain_DecLastPlayingCue
  #SCS_ShortMain_IncLastPlayingCue
  #SCS_ShortMain_TapDelay
  #SCS_ShortMain_DMXMastFdrDown
  #SCS_ShortMain_DMXMastFdrUp
  #SCS_ShortMain_DMXMastFdrReset
  #SCS_ShortMain_CueMarkerPrev
  #SCS_ShortMain_CueMarkerNext
  #SCS_ShortMain_MoveToTime
  #SCS_ShortMain_CallLinkDevs
  #SCS_ShortMain_ExclCueOverride  ; must be last in this list
EndEnumeration
#SCS_ShortMain_Last = #PB_Compiler_EnumerationValue - 1

;- shortcut array indexes (editor shortcuts) IN DISPLAY ORDER in fmOptions/Shortcuts
Enumeration
  ; transport, etc
  #SCS_ShortEditor_Rewind
  #SCS_ShortEditor_PlayPause
  #SCS_ShortEditor_Stop
  #SCS_ShortEditor_AddCueMarker
  #SCS_ShortEditor_CueMarkerPrev
  #SCS_ShortEditor_CueMarkerNext
  #SCS_ShortEditor_SkipBack
  #SCS_ShortEditor_SkipForward
  #SCS_ShortEditor_DecLevels
  #SCS_ShortEditor_IncLevels
  ; file category
  #SCS_ShortEditor_Save
  #SCS_ShortEditor_SaveAs
  #SCS_ShortEditor_Print
  #SCS_ShortEditor_Options
  ; editing category
  #SCS_ShortEditor_Cut
  #SCS_ShortEditor_Copy
  #SCS_ShortEditor_Paste
  #SCS_ShortEditor_SelectAll
  #SCS_ShortEditor_FindCue
  #SCS_ShortEditor_Undo
  #SCS_ShortEditor_Redo
  #SCS_ShortEditor_ProdProps
  #SCS_ShortEditor_ImportDevs
  #SCS_ShortEditor_Collect
  #SCS_ShortEditor_Timer
  #SCS_ShortEditor_AddQF
  #SCS_ShortEditor_AddSF
  #SCS_ShortEditor_AddQA
  #SCS_ShortEditor_AddSA
  #SCS_ShortEditor_AddQI
  #SCS_ShortEditor_AddSI
  #SCS_ShortEditor_AddQK
  #SCS_ShortEditor_AddSK
  #SCS_ShortEditor_AddQS
  #SCS_ShortEditor_AddSS
  #SCS_ShortEditor_AddQL
  #SCS_ShortEditor_AddSL
  #SCS_ShortEditor_AddQM
  #SCS_ShortEditor_AddSM
  #SCS_ShortEditor_AddQN
  #SCS_ShortEditor_AddQE
  #SCS_ShortEditor_AddSE
  #SCS_ShortEditor_AddQP
  #SCS_ShortEditor_AddSP
  #SCS_ShortEditor_AddQG
  #SCS_ShortEditor_AddSG
  #SCS_ShortEditor_AddQT
  #SCS_ShortEditor_AddST
  #SCS_ShortEditor_AddQU
  #SCS_ShortEditor_AddSU
  #SCS_ShortEditor_AddQR
  #SCS_ShortEditor_AddSR
  #SCS_ShortEditor_AddQQ
  #SCS_ShortEditor_AddSQ
  #SCS_ShortEditor_AddQJ
  #SCS_ShortEditor_AddSJ
  #SCS_ShortEditor_Renumber
  #SCS_ShortEditor_BulkEdit
  #SCS_ShortEditor_CopyMoveEtc
  #SCS_ShortEditor_ImportCues
  #SCS_ShortEditor_ExportCues
  #SCS_ShortEditor_ChangeFreqTempoPitch
  #SCS_ShortEditor_CallLinkDevs
  ; others
  #SCS_ShortEditor_TapDelay
EndEnumeration
#SCS_ShortEditor_Last = #PB_Compiler_EnumerationValue - 1

Enumeration
  #SCS_ShortGroup_Main
  #SCS_ShortGroup_Editor
EndEnumeration

;- keyboard constants
#SCS_KEYBOARD_SHIFT = 1
#SCS_KEYBOARD_CTRL = 2
#SCS_KEYBOARD_ALT = 4

;- handle types
Enumeration
  #SCS_HANDLE_NONE
  #SCS_HANDLE_SOURCE
  #SCS_HANDLE_SPLITTER
  #SCS_HANDLE_MIXER
  #SCS_HANDLE_GAPLESS
  #SCS_HANDLE_BUFFER
  #SCS_HANDLE_ENCODER
  #SCS_HANDLE_VIDEO
  #SCS_HANDLE_IMAGE
  #SCS_HANDLE_SYNC
  #SCS_HANDLE_TIMELINE
  #SCS_HANDLE_TEMPO
  #SCS_HANDLE_TVG
  #SCS_HANDLE_NETWORK_SERVER
  #SCS_HANDLE_NETWORK_CLIENT
  #SCS_HANDLE_VST
  #SCS_HANDLE_DMX
  #SCS_HANDLE_TMP
  #SCS_HANDLE_LTC
EndEnumeration

;- device groups
Enumeration
  #SCS_DEVGRP_NONE
  #SCS_DEVGRP_AUDIO_OUTPUT ; see also #SCS_DEVGRP_FIRST below
  #SCS_DEVGRP_VIDEO_AUDIO
  #SCS_DEVGRP_VIDEO_CAPTURE
  #SCS_DEVGRP_LIGHTING
  #SCS_DEVGRP_CTRL_SEND
  #SCS_DEVGRP_LIVE_INPUT
  #SCS_DEVGRP_CUE_CTRL ; see also #SCS_DEVGRP_LAST below
  #SCS_DEVGRP_IN_GRP   ; pseudo 'device group' - used in Production Properties
  #SCS_DEVGRP_IN_GRP_LIVE_INPUT ; pseudo 'device group' - used in Production Properties ('input group live inputs' are the live inputs assigned to this input group)
  #SCS_DEVGRP_FIX_TYPE      ; pseudo 'device group' - used in Production Properties
  #SCS_DEVGRP_EXT_CONTROLLER ; Added 18Jun2022 11.9.4
EndEnumeration
#SCS_DEVGRP_VERY_LAST = #PB_Compiler_EnumerationValue - 1
#SCS_DEVGRP_FIRST = #SCS_DEVGRP_AUDIO_OUTPUT
#SCS_DEVGRP_LAST = #SCS_DEVGRP_CUE_CTRL

;- device types
Enumeration
  #SCS_DEVTYPE_NONE = -1
  ; audio devices
  #SCS_DEVTYPE_AUDIO_OUTPUT = 0
  #SCS_DEVTYPE_MIDI_PLAYBACK
  ; video devices
  #SCS_DEVTYPE_VIDEO_AUDIO
  #SCS_DEVTYPE_VIDEO_CAPTURE
  ; lighting devices
  #SCS_DEVTYPE_LT_DMX_OUT
  ; control-send devices
  #SCS_DEVTYPE_CS_MIDI_OUT ; See also SCS_DEVTYPE_EXTCTRL_MIDI_OUT below
  #SCS_DEVTYPE_CS_MIDI_THRU
  #SCS_DEVTYPE_CS_RS232_OUT
  #SCS_DEVTYPE_CS_NETWORK_OUT
  #SCS_DEVTYPE_CS_HTTP_REQUEST
  ; cue-control devices
  #SCS_DEVTYPE_CC_MIDI_IN ; See also SCS_DEVTYPE_EXTCTRL_MIDI_IN below
  #SCS_DEVTYPE_CC_RS232_IN
  #SCS_DEVTYPE_CC_NETWORK_IN
  #SCS_DEVTYPE_CC_DMX_IN
  ; live input devices
  #SCS_DEVTYPE_LIVE_INPUT
EndEnumeration
#SCS_DEVTYPE_LAST = #PB_Compiler_EnumerationValue - 1

#SCS_DEVTYPE_EXTCTRL_MIDI_IN = #SCS_DEVTYPE_CC_MIDI_IN   ; Added 25Jun2022 11.9.4
#SCS_DEVTYPE_EXTCTRL_MIDI_OUT = #SCS_DEVTYPE_CS_MIDI_OUT ; Added 25Jun2022 11.9.4

;- device type enabled
Enumeration
  #SCS_DEVTYPE_NOT_REQD
  #SCS_DEVTYPE_ENABLED
  #SCS_DEVTYPE_DISABLED
EndEnumeration

;- drivers (all device types)
Enumeration 1
  ;- audio drivers
  #SCS_DRV_BASS_DS
  #SCS_DRV_BASS_WASAPI
  #SCS_DRV_BASS_ASIO
  #SCS_DRV_SMS_ASIO
  ;- video drivers
  #SCS_DRV_TVG
EndEnumeration
#SCS_DRV_LAST = #PB_Compiler_EnumerationValue - 1

;- ASIO buffer lengths
#SCS_ASIOBUFLEN_PREF = 0
#SCS_ASIOBUFLEN_MAX = -1
; other values are real values, eg 128 (samples), 256, etc

;- WMT devices
Enumeration
  #SCS_WMT_MIDI
  #SCS_WMT_RS232
  #SCS_WMT_NETWORK
  #SCS_WMT_UDP
EndEnumeration

;- ungrouped constants
#SCS_UNTITLED = ""
#SCS_MAXRFL_SAVED = 20
#SCS_MAXRFL_DISPLAYED = 20

#SCS_HEX_VALID_CHARS = "0123456789ABCDEF"

#SCS_NOVOLCHANGE_SINGLE = -1
#SCS_NOPANCHANGE_SINGLE = -101
#SCS_LEVELNOTSET_SINGLE = -2

#SCS_MINVOLUME_SINGLE = 0
; #SCS_LOWVOLUME_SINGLE = 0.000179  ; ~ -74.9dB
#SCS_MINVOLUME_SLD = 0
#SCS_MAXVOLUME_SLD = 10000
#SCS_NORMALVOLUME_SINGLE = 0.88
#SCS_NORMALVOLUME_SLD = 8800
#SCS_DEFAULT_DBTRIM = "0"
#SCS_ZERO_DBTRIM = "0dB"
#SCS_INF_DBLEVEL = "-INF"
#SCS_MINPAN_SINGLE = -1
#SCS_MINPAN_SLD = 0
#SCS_MAXPAN_SINGLE = 1
#SCS_MAXPAN_SLD = 1000
#SCS_PANCENTRE_SINGLE = 0
#SCS_PANCENTRE_SLD = 500
#SCS_NO_SLICE = -99999999
#SCS_PARAM_NOT_SET = -99
#SCS_HOTKEYBANK_NOT_SET = 99

; ; #SCS_CONTINUOUS = $7FFFFFFF   ; dummy value for continuous time (used when image 'display length' set to blank)
; #SCS_CONTINUOUS = $7FFFFFF0   ; dummy value for continuous time (used when image 'display length' set to blank)
; ; changed #SCS_CONTINUOUS from $7FFFFFFF to $7FFFFFF0 on 20May2016 11.5.0.102 because getAbsTime() may add 1 to this when calculating cue duration, and adding 1 to $7FFFFFFF goes negative
#SCS_CONTINUOUS_LENGTH = $7FFFFFF0   ; dummy value for continuous time (used when image 'display length' set to blank)
#SCS_CONTINUOUS_END_AT = #SCS_CONTINUOUS_LENGTH - 1

#SCS_Key_LeftArrow = 1
#SCS_Key_RightArrow = 2

#SCS_GAPLESS_MARKER = "//"
#SCS_START = "start"
#SCS_END = "end"
#SCS_BLANK = "blank"
#SCS_BLANK_CBO_ENTRY = ""
#SCS_CBO_ENTRY_INVALID = -99999
#SCS_NO_DEVICE = "<no device>"
#SCS_DEFAULT_AUDIO_SPEAKER = "STEREO"
#SCS_DEFAULT_MIDI_LOGICALDEV = "MIDI"
#SCS_DEFAULT_RS232_LOGICALDEV = "RS232"
#SCS_DEFAULT_NETWORK_LOGICALDEV = "Network"
#SCS_DEFAULT_NETWORK_LOCAL_PORT = 59648
#SCS_DEFAULT_HTTP_LOGICALDEV = "HTTP"
#SCS_DEFAULT_UDP_LOGICALDEV = "UDP"
#SCS_DEFAULT_UDP_LOCAL_PORT = 59649
#SCS_DEFAULT_DMX_LOGICALDEV = "DMX"
#SCS_DEFAULT_RAI_LOCAL_PORT_SCSREMOTE = 58000
#SCS_DEFAULT_RAI_LOCAL_PORT_OSCAPP = 58100
#SCS_PRIMARY_SERVER_PORT = 59650

#SCS_DEFAULT_BUFFER_USING_MIXER = 300
#SCS_DEFAULT_BUFFER_NO_MIXER = 5000
#SCS_DEFAULT_UPDATE_PERIOD_USING_MIXER = 80
#SCS_DEFAULT_UPDATE_PERIOD_NO_MIXER = 100

#SCS_RS232_PORT_NOT_OPEN = "<Port not open>"
#SCS_NETWORK_CONNECTION_NOT_OPEN = "<Connection not open>"

; QA preview image is 304 x 171, which equates to an aspect ratio of 16:9
#SCS_QAPREVIEW_WIDTH = 304
#SCS_QAPREVIEW_HEIGHT = 171
; QA timeline images are 64 x 36, which equates to an aspect ratio of 16:9
#SCS_QATIMELINE_IMAGE_WIDTH = 64
#SCS_QATIMELINE_IMAGE_HEIGHT = 36
#SCS_QAITEM_WIDTH = #SCS_QATIMELINE_IMAGE_WIDTH + 12    ; allow enough room between items to display and use a 'drop marker' (vertical bar)
#SCS_QAITEM_HEIGHT = #SCS_QATIMELINE_IMAGE_HEIGHT + 32  ; allow for image height plus two lines of text

#SCS_QKROW_HEIGHT = 19
#SCS_QPROW_HEIGHT = 21

#SCS_REVIEW_DEVMAP = -101
#SCS_ASK_TO_REVIEW_DEVMAP = -102 ; Added 25Jun2021 11.8.5ao
#SCS_CLOSE_CUE_FILE = -103
#SCS_CANCEL_EDIT = -104
#SCS_VMIX_EDITION_NOT_SUPPORTED = -105

#SCS_DATABASE_MIN_SIZE_FOR_INFOMSG = 5000000

;- licence levels
#SCS_LIC_LITE = 10
#SCS_LIC_STD = 20
#SCS_LIC_PRO = 30
#SCS_LIC_PLUS = 40
#SCS_LIC_DEMO = 45    ; demo has functionality of plus but has limits on certain items, eg number of cues and number of outputs
#SCS_LIC_PLAT = 50

;- run modes
Enumeration
  #SCS_RUN_MODE_LINEAR
  #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND
  #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
  #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND
  #SCS_RUN_MODE_BOTH_PREOPEN_ALL
EndEnumeration

;- status message values
Enumeration
  #SCS_STATUS_CLEAR
  #SCS_STATUS_LICENSE_INFO
  #SCS_STATUS_INFO
  #SCS_STATUS_INCOMING_COMMAND
  #SCS_STATUS_WARN
  #SCS_STATUS_MAJOR_WARN
  #SCS_STATUS_MAJOR_WARN_REVERSE_COLORS ; added 5Mar2019 11.8.0.2ax
  #SCS_STATUS_MAJOR_WARN_NORMAL_COLORS  ; added 5Mar2019 11.8.0.2ax
  #SCS_STATUS_ERROR
  #SCS_STATUS_CLOSEDOWN
EndEnumeration
#SCS_STATUS_DISPLAY_TIME = 4000

;- stream types
Enumeration
  #SCS_STREAM_AUDIO
  #SCS_STREAM_VIDEO
EndEnumeration

;- cue status values
Enumeration
  #SCS_CUE_NOT_LOADED
  #SCS_CUE_READY
  #SCS_CUE_COUNTDOWN_TO_START
  #SCS_CUE_SUB_COUNTDOWN_TO_START
  #SCS_CUE_PL_COUNTDOWN_TO_START
  #SCS_CUE_WAITING_FOR_CONFIRM
  
  #SCS_CUE_FADING_IN
  #SCS_CUE_TRANS_FADING_IN
  #SCS_CUE_PLAYING
  #SCS_CUE_CHANGING_LEVEL
  #SCS_CUE_RELEASING
  #SCS_CUE_STOPPING
  #SCS_CUE_PAUSED
  #SCS_CUE_HIBERNATING
  #SCS_CUE_TRANS_MIXING_OUT
  #SCS_CUE_TRANS_FADING_OUT
  #SCS_CUE_FADING_OUT
  
  #SCS_CUE_PL_READY
  #SCS_CUE_STANDBY
  #SCS_CUE_COMPLETED
  #SCS_CUE_ERROR
  #SCS_CUE_IGNORED
  
  #SCS_CUE_STATE_NOT_SET
EndEnumeration
#SCS_LAST_CUE_STATE = #PB_Compiler_EnumerationValue - 1

;- file states
Enumeration
  #SCS_FILESTATE_CLOSED
  #SCS_FILESTATE_OPEN
EndEnumeration

;- file formats
Enumeration
  #SCS_FILEFORMAT_UNKNOWN
  #SCS_FILEFORMAT_AUDIO
  #SCS_FILEFORMAT_CAPTURE
  #SCS_FILEFORMAT_MIDI
  #SCS_FILEFORMAT_VIDEO
  #SCS_FILEFORMAT_PICTURE
  #SCS_FILEFORMAT_LIVE_INPUT
EndEnumeration

;- audio file selector
Enumeration
  #SCS_FO_SCS_AFS       ; SCS audio file selector
  #SCS_FO_WINDOWS_FS    ; Windows file selector
EndEnumeration

;- file save format
Enumeration
  ; used in decodeSaveAsFormat() and writeXMLCueFile()
  #SCS_SAVEAS_SCS11       ; extension .scs11
EndEnumeration

;- DSP Ind
Enumeration
  #SCS_DSP_NONE
  #SCS_DSP_LEFT
  #SCS_DSP_RIGHT
EndEnumeration

;- cue marker types
Enumeration
  #SCS_CMT_CM ; an SCS Cue Marker
  #SCS_CMT_CP ; a cue point from an audio file, eg embedded in a WAV file, OR a marker from a MRK file, eg "When I'm SixtyFour.mrk"
EndEnumeration

;- cue activation method
  #SCS_ACMETH_MAN             = $0        ;  manual start
  #SCS_ACMETH_AUTO            = $1        ;  auto start
  #SCS_ACMETH_CALL_CUE        = $4        ;  call cue
  #SCS_ACMETH_CHASE           = $8        ;  chase
  
  #SCS_ACMETH_CONF_BIT        = $1000     ; 'confirmation' bit setting - not an activation method
  #SCS_ACMETH_MAN_PLUS_CONF   = $1000     ;  manual + confirmation
  #SCS_ACMETH_AUTO_PLUS_CONF  = $1001     ;  auto + confirmation
  
  #SCS_ACMETH_HK_BIT          = $2000     ; 'hotkey' bit setting - not an activation method
  #SCS_ACMETH_HK_TRIGGER      = $2002     ;  'trigger' hotkey
  #SCS_ACMETH_HK_TOGGLE       = $2003     ;  'toggle' hotkey
  #SCS_ACMETH_HK_NOTE         = $2004     ;  'note' hotkey
  #SCS_ACMETH_HK_STEP         = $2005     ;  'step' hotkey - same as 'trigger' except that multiple cues may have the same keyboard key, and SCS activates them in sequence on successive presses of that key
  
  #SCS_ACMETH_TIME            = $4005     ; time-based start (eg start at 7:15pm)
  
  ; #SCS_ACMETH_LINKED          = $8006     ; linked cue - not an activation method per se, ie not entered by the user
  
  #SCS_ACMETH_EXT_BIT         = $10000    ; 'external' bit setting - not an activation method
                                          ; NOTE and WARNING: 'external' activation cues are not displayed in the cue panels
  #SCS_ACMETH_EXT_TRIGGER     = $10002    ; 'trigger' from external device (eg MIDI)
  #SCS_ACMETH_EXT_TOGGLE      = $10003    ; 'toggle' from external device (eg MIDI)
  #SCS_ACMETH_EXT_NOTE        = $10004    ; 'note' from external device (eg MIDI)
  #SCS_ACMETH_EXT_STEP        = $10005    ; 'step' from external device (eg MIDI)
  #SCS_ACMETH_EXT_COMPLETE    = $10006    ; as 'trigger' from external device (eg MIDI), except that the cue must complete before being restarted, ie if the cue is currently playing then the request will be ignored.
  #SCS_ACMETH_MTC             = $10010    ; 'MTC' (MIDI time code) - either external or internal, but generally treated as 'external'
  #SCS_ACMETH_LTC             = $10020    ; 'LTC' (Linear time code) - only external supported
  #SCS_ACMETH_EXT_FADER       = $10030    ; external fader control of a lighting cue
  
  #SCS_ACMETH_OCM             = $20020    ; 'ocm' (On Cue Marker/Point)

;- cue activation position
Enumeration
  #SCS_ACPOSN_DEFAULT
  #SCS_ACPOSN_AS              ; after start of nominated cue ('start')
  #SCS_ACPOSN_AE              ; after end of nominated cue ('end')
  #SCS_ACPOSN_BE              ; before end of nominated cue ('b4end')
  #SCS_ACPOSN_LOAD            ; after cue file loaded
  #SCS_ACPOSN_OCM             ; on cue marker ; replaced 3Aug2019 11.8.1.3af by cue activation method #SCS_ACMETH_OCM
EndEnumeration

;- cue activation cue selection type
Enumeration
  #SCS_ACCUESEL_DEFAULT
  #SCS_ACCUESEL_PREV
  #SCS_ACCUESEL_CM ; cue marker - nb this selection type is not used for cue files saved by SCS 11.8.2 or later as the cue activation method now supports 'on cue marker' (#SCS_ACMETH_OCM)
EndEnumeration

;- cue auto-start range
Enumeration
  #SCS_CUE_AUTO_START_RANGE_EARLIER
  #SCS_CUE_AUTO_START_RANGE_ALL
EndEnumeration

;- standby
Enumeration
  #SCS_STANDBY_NONE
  #SCS_STANDBY_SET
  #SCS_STANDBY_CANCEL
EndEnumeration

;- hide cue
Enumeration
  #SCS_HIDE_NO
  #SCS_HIDE_CUE_PANEL
  #SCS_HIDE_ENTIRE_CUE
EndEnumeration

;- CueToGo states
Enumeration
  #SCS_Q2GO_NOT_SET
  #SCS_Q2GO_ENABLED
  #SCS_Q2GO_DISABLED
  #SCS_Q2GO_END
EndEnumeration

;- call cue (QQ) actions
Enumeration
  #SCS_QQ_CALLCUE
  #SCS_QQ_SELHKBANK
EndEnumeration

;- cue panel update flags
#SCS_CUEPNL_PROGRESS    = 1
#SCS_CUEPNL_TRANSPORT   = 2
#SCS_CUEPNL_OTHER       = 4

;- cue panel display modes
; the following modes are negative values so that positive values can be used to indicate modes equivalent to 'default' but with 5 or more device lines
; eg for a cue panel with default display mode but with provision for 12 device lines the mode would be +12
#SCS_CUEPNL_DISP_3_LINE = -3  ; default (cue line + progress slider line + transport controls; max 4 device lines)
#SCS_CUEPNL_DISP_2_LINE = -2  ; cue line + progress slider line; max 2 device lines
#SCS_CUEPNL_DISP_1_LINE = -1  ; cue line; max 1 device line

;- sub-cue start
Enumeration
  #SCS_SUBSTART_REL_TIME
  #SCS_SUBSTART_REL_MTC
  #SCS_SUBSTART_OCM
EndEnumeration

;- sub-cue relative start mode
Enumeration
  ; the first two values (#SCS_RELSTART_DEFAULT and #SCS_RELSTART_AS_CUE) mean the same and must be first so code can test \nRelStartMode <= #SCS_RELSTART_AS_CUE
  #SCS_RELSTART_DEFAULT
  #SCS_RELSTART_AS_CUE        ; after start of cue ('as_cue')
  #SCS_RELSTART_AS_PREV_SUB   ; after start of previous sub-cue ('as_prev_sub')
  #SCS_RELSTART_AE_PREV_SUB   ; after end of previous sub-cue ('ae_prev_sub')
  #SCS_RELSTART_BE_PREV_SUB   ; before end of previous sub-cue ('be_prev_sub')
EndEnumeration

;- MTH - Main Thread Requests
EnumerationBinary
  #SCS_MTH_CALL_SETFILESAVE
  #SCS_MTH_CLEAR_STATUS_FIELD
  #SCS_MTH_CLOSE_DOWN
  #SCS_MTH_COUNTDOWN_CLOCK
  #SCS_MTH_DISP_VIS_WARN_IF_REQD
  #SCS_MTH_DISPLAY_OR_HIDE_HOTKEYS
  #SCS_MTH_DRAW_WQF_GRAPH
  #SCS_MTH_EDIT_UPDATE_DISPLAY
  #SCS_MTH_FADE_ALL
  #SCS_MTH_GET_MIDI_MODE
  #SCS_MTH_HIDE_WARNING_MSG
  #SCS_MTH_HIGHLIGHT_LINE
  #SCS_MTH_LOAD_DISP_PANELS
  #SCS_MTH_PAUSE_ALL
  #SCS_MTH_PAUSE_RESUME_ALL
  #SCS_MTH_PLAY_SUB
  #SCS_MTH_PROCESS_ACTION
  #SCS_MTH_REFRESH_DISP_PANEL
  #SCS_MTH_REFRESH_GRDCUES
  #SCS_MTH_RELOAD_DISP_PANEL
  #SCS_MTH_RESUME_ALL
  #SCS_MTH_SET_CUE_TO_GO
  #SCS_MTH_SET_GRID_WINDOW
  #SCS_MTH_SET_NAVIGATE_BUTTONS
  #SCS_MTH_SET_STATUS_FIELD
  #SCS_MTH_SET_WED_NODE
  #SCS_MTH_STOP_ALL
  #SCS_MTH_STOP_MTC
  #SCS_MTH_TIME_OF_DAY_CLOCK
  #SCS_MTH_UPDATE_ALL_GRID
  #SCS_MTH_UPDATE_DISP_PANELS
  #SCS_MTH_VU_CLEAR
  #SCS_MTH_VU_INIT
  ; Important: maximum of 64 entries allowed as the value(s) will be stored in a quad variable
EndEnumeration

;- TimeLine Entry Types
Enumeration
  #SCS_TLT_NONE
  #SCS_TLT_PLAY_CUE
  #SCS_TLT_PLAY_SUB
  #SCS_TLT_PLAY_AUD
  #SCS_TLT_SEND_CTRL_MSG
EndEnumeration

;- TimeLine Entry Status
Enumeration
  #SCS_TLS_NOT_SET
  #SCS_TLS_WAITING
  #SCS_TLS_PROCESSED
EndEnumeration

;- SAM - special action manager
Enumeration 1
  ; SAM request types that do NOT have parameters (p1Long, etc) are numbered < 1000
  ; sorted
  #SCS_SAM_CHANGE_TIME_PROFILE
  #SCS_SAM_CHECK_USING_PLAYBACK_RATE_CHANGE_ONLY
  #SCS_SAM_CLEAR_POSITIONING_MIDI
  #SCS_SAM_CLOSE_EDITOR
  #SCS_SAM_DISPLAY_CLOCK_IF_REQD ; Added 3Dec2022 11.9.7ar
  #SCS_SAM_DISPLAY_DMX_DISPLAY
  #SCS_SAM_DISPLAY_FADERS
  #SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS
  #SCS_SAM_GO
  #SCS_SAM_HIDE_MTC_WINDOW_IF_INACTIVE
  #SCS_SAM_HIDE_WARNING_MSG
  #SCS_SAM_HIGHLIGHT_PLAYLIST_ROW
  #SCS_SAM_INIT_RAI
  ; #SCS_SAM_LOAD_CUE_PANELS ; 18Mar2022 11.9.1ap - moved to numbered > 2000 so that only the latest unprocessed request is kept
  #SCS_SAM_NEW_CUE_FILE
  #SCS_SAM_OPEN_DMX_DEVS
  #SCS_SAM_OPEN_RS232_PORTS
  #SCS_SAM_PAUSE_RESUME_ALL
  #SCS_SAM_POPULATE_GRID
  #SCS_SAM_REFRESH_GRDCUES
  #SCS_SAM_SET_CUE_PANELS
  #SCS_SAM_SET_FOCUS_TO_SCS
  #SCS_SAM_SET_GO_BUTTON
  #SCS_SAM_SET_NAVIGATE_BUTTONS
  #SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW
  #SCS_SAM_SETUP_AVAILABLE_MONITORS
  
  ; SAM request types that have parameters (p1Long, etc) are numbered > 1000
  ; sorted
  #SCS_SAM_BUILD_DEV_CHANNEL_LIST = 1001
  #SCS_SAM_CALL_MODRETURN_FUNCTION
  #SCS_SAM_CHANNEL_SLIDE
  #SCS_SAM_CHECK_MAIN_HAS_FOCUS
  #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE
  #SCS_SAM_CLEAR_VIDEO_CANVAS_IF_NOT_IN_USE
  #SCS_SAM_COMPLETE_AUD
  #SCS_SAM_CREATE_TVG_CONTROL
  #SCS_SAM_DISPLAY_PICTURE
  #SCS_SAM_DISPLAY_THUMBNAILS
  #SCS_SAM_DRAW_GRAPH
  #SCS_SAM_EDITOR_NODE_CLICK
  #SCS_SAM_GOTO_CUE
  #SCS_SAM_GOTO_CUELIST_FOR_SHORTCUT
  #SCS_SAM_GO_REMOTE  ; 'GO' issued by network or other remote device
  #SCS_SAM_GO_WHEN_OK
  #SCS_SAM_GO_WITH_EXPECTED_CUE
  #SCS_SAM_HIDE_PICTURE
  #SCS_SAM_HIDE_VIDEO_WINDOW_IF_NOT_IN_USE
  #SCS_SAM_HOTKEY
  #SCS_SAM_INIT_FM
  #SCS_SAM_LOAD_GRID_ROW
  #SCS_SAM_LOAD_NEXT_CUE_PANELS
  #SCS_SAM_LOAD_OCM_CUES
  #SCS_SAM_LOAD_SCS_CUE_FILE
  #SCS_SAM_MAKE_VID_PIC_VISIBLE
  #SCS_SAM_OPEN_FILES_FOR_CUE
  #SCS_SAM_OPEN_MIDI_PORTS
  #SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD
  #SCS_SAM_OPEN_NEXT_CUES
  #SCS_SAM_OPEN_NEXT_CUES_ONE_CUE_ONLY
  #SCS_SAM_PAUSE_RESUME_CUE
  #SCS_SAM_PAUSE_VIDEO
  #SCS_SAM_PLAY_AUD_FOR_STATUS_CHECK
  #SCS_SAM_PLAY_CTRL_SEND_ITEM_DELAYED
  #SCS_SAM_PLAY_CUE
  #SCS_SAM_PLAY_MIDI_OR_DMX_CUE
  #SCS_SAM_PLAY_NEXT_AUD
  #SCS_SAM_PLAY_SUB
  #SCS_SAM_PLAY_VIDEO
  #SCS_SAM_PROCESS_WQA_SELECTED_ITEM
  #SCS_SAM_RAI_REQUEST
  #SCS_SAM_RELEASE_LOOP
  #SCS_SAM_RESET_INITIAL_STATE_OF_CUE
  #SCS_SAM_REWIND_AUD
  #SCS_SAM_SET_CURR_PL_ROW
  #SCS_SAM_SET_CURR_QA_ITEM
  #SCS_SAM_SET_HOTKEY_BANK
  #SCS_SAM_SET_MOUSE_CURSOR
  #SCS_SAM_SET_TIME_BASED_CUES
  #SCS_SAM_SET_WINDOW_VISIBLE
  #SCS_SAM_SHOW_VIDEO_FRAME
  #SCS_SAM_START_NETWORK
  #SCS_SAM_START_THREAD
  #SCS_SAM_START_VU_DISPLAY
  #SCS_SAM_STOP_AUD
  #SCS_SAM_STOP_CUE
  #SCS_SAM_STOP_DMX_FADES_FOR_SUB
  #SCS_SAM_STOP_LC_SUB
  #SCS_SAM_STOP_QA
  #SCS_SAM_STOP_SUB
  #SCS_SAM_STOP_SUB_FOR_STATUS_CHECK
  #SCS_SAM_UPDATE_GRID
  #SCS_SAM_UPDATE_SCREEN_FOR_CUE
  
  ; SAM request types that have parameters (p1Long, etc) AND where only the LATEST unprocessed request is to be kept, are numbered > 2000
  ; sorted
  #SCS_SAM_CLOSE_NETWORK_CONNECTION = 2001
  #SCS_SAM_DISPLAY_TIMER
  #SCS_SAM_DMX_CAPTURE_COMPLETE
  #SCS_SAM_EDITOR_BTN_CLICK
  #SCS_SAM_FMB_FILE_OPEN
  #SCS_SAM_FREE_TVG_CONTROL
  #SCS_SAM_GOTO_SPECIAL   ; p1 = value from enumeration #SCS_GOTO_...
  #SCS_SAM_HIDE_MEMO_ON_SECONDARY_SCREEN
  #SCS_SAM_LOAD_CUE_PANELS ; 18Mar2022 11.9.1ap - moved from numbered < 1000
  #SCS_SAM_LOAD_ONE_CUE ; Added 3Jun2024 11.10.3ag
  #SCS_SAM_LOAD_SLIDER_AUDIO_FILE
  #SCS_SAM_REPOS_AUDS
  #SCS_SAM_REPOS_CUE
  #SCS_SAM_REPOS_SPLITTER
  #SCS_SAM_SET_CUE_POSITION
  #SCS_SAM_SET_CUE_TO_GO
  #SCS_SAM_SET_DEVICE_FADER
  #SCS_SAM_SET_EDIT_WINDOW_ACTIVE
  ; #SCS_SAM_SET_MASTER_FADER
  #SCS_SAM_SET_GRID_ROW
  #SCS_SAM_SET_SLD_BUTTON_POSITION
  #SCS_SAM_SET_TEST_TONE_LEVEL
  #SCS_SAM_SPECIFIC_SMS_COMMAND   ; see also 'unique constants for p1Long...' following this Enumeration
  #SCS_SAM_UNASSIGN_SMS_PLAYBACK_CHANNEL
  #SCS_SAM_WMN_RESIZED            ; need to keep only the latest request, but doesn't actually have any parameters
  
  ; SAM request types like the > 2000 range but where p3Long is also checked in the duplication test
  ; sorted
  #SCS_SAM_SET_AUD_DEV_LEVEL = 3001   ; p1 = audPtr, p3 = devno
  #SCS_SAM_SET_AUD_DEV_PAN            ; p1 = audPtr, p3 = devno
  #SCS_SAM_SET_AUD_INPUT_DEV_LEVEL    ; p1 = audPtr, p3 = inputdevno
  
  ; SAM request types that are to be added even if a duplicate already exists, are numbered > 4000
  ; sorted
  #SCS_SAM_LOAD_MISSING_OSC_INFO = 4001 ; needs to be in this range because processing the request can itself re-issue the request, which therefore happens BEFORE the original request is deleted, so a 'duplicate' condition will occur which is OK
  #SCS_SAM_SET_PLAYORDER
  
  ; SAM request types where only the LATEST unprocessed request is to be kept, regardless of parameter values, are numbered > 5000
  #SCS_SAM_GOTO_CUE_LATEST_ONLY = 5001
  #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS
  #SCS_SAM_SET_MASTER_FADER ; Moved here 15Nov2022 11.9.7ag

EndEnumeration

; unique constants for p1Long in SCS_SAM_SPECIFIC_SMS_COMMAND requests
#SCS_SAM_SMS_PREVIEW_LEVEL = 1

Enumeration
  #SCS_SAMPRIORITY_HIGH
  #SCS_SAMPRIORITY_NORMAL
  #SCS_SAMPRIORITY_LOW
EndEnumeration

Enumeration 1 ; enumeration for #SCS_SAM_GOTO_SPEICAL
  #SCS_GOTO_TOP
  #SCS_GOTO_PREV
  #SCS_GOTO_NEXT
  #SCS_GOTO_END
EndEnumeration

Enumeration 1 ; enumeration for #SCS_SAM_PAUSE_RESUME_CUE
  #SCS_MM_PAUSE
  #SCS_MM_RESUME
  #SCS_MM_PAUSE_OR_RESUME
EndEnumeration

;- CAS - cue action stack
Enumeration 1
  #SCS_CAS_MIXER_UNPAUSE
  #SCS_CAS_MIXER_PAUSE
  #SCS_CAS_FADE_OUT
  #SCS_CAS_MCI_STRING
  #SCS_CAS_PLAY_VIDEO
  #SCS_CAS_PLAY_AUD
EndEnumeration

;- EditModal fields
Enumeration 1
  ; #SCS_WEM_A_... for SubTypeA fields (video/image)
  #SCS_WEM_A_SCREENS
  ; #SCS_WEM_F_... for SubTypeF fields (audio file)
  #SCS_WEM_F_STARTAT
  #SCS_WEM_F_ENDAT
  #SCS_WEM_F_LOOPSTART
  #SCS_WEM_F_LOOPEND
  #SCS_WEM_F_FADEINTIME
  #SCS_WEM_F_FADEOUTTIME
  #SCS_WEM_F_CUEMARKERSUSAGE
  #SCS_WEM_F_FREQ_TEMPO_PITCH
  ; #SCS_WEM_I_... for SubTypeI fields (live input)
  #SCS_WEM_I_FADEINTIME
  #SCS_WEM_I_FADEOUTTIME
  ; #SCS_WEM_LT_... for Production Properties - Lighting Devices
  #SCS_WEM_LT_COPYFROM
EndEnumeration

;- Fade types
Enumeration 1
  #SCS_FADE_STD       ; default and recommended
  #SCS_FADE_LIN
  #SCS_FADE_LOG
  #SCS_FADE_LIN_SE    ; available for fade outs only
  #SCS_FADE_LOG_SE    ; available for fade outs only
  #SCS_FADE_EXP       ; possible later use by SM-S
EndEnumeration

;- Fade entry types
Enumeration
  #SCS_FADE_ENTRY_TIME
  #SCS_FADE_ENTRY_POS
EndEnumeration

;- Fade field types
Enumeration
  #SCS_FADE_IN_FIELD
  #SCS_FADE_OUT_FIELD
EndEnumeration

;- Modal Window return functions
Enumeration 1
  #SCS_MODRETURN_IMPORT
  #SCS_MODRETURN_IMPORT_DEVS
  #SCS_MODRETURN_PASTE_FROM_OLE
  #SCS_MODRETURN_RS232_CHECK
  #SCS_MODRETURN_F_OR_P
  #SCS_MODRETURN_CREATE_PROD_FOLDER
  #SCS_MODRETURN_RESYNC_PROD_FOLDER
  #SCS_MODRETURN_FILE_RENAME
  #SCS_MODRETURN_LOADPROD
  #SCS_MODRETURN_FILE_OPENER
EndEnumeration

;- view codes for graphs
Enumeration
  #SCS_VIEW_CODE_NONE
  ; nb view code A made obsolete at 11.2.0 as it was not accurate enough. replaced by view code B to force re-generation of graph info.
  ; #SCS_VIEW_CODE_A     ; display entire file in the graph's scroll area with an inner width of 600 pixels and height of 106 pixels (default view, no zoom)
  #SCS_VIEW_CODE_B     ; display entire file in the graph's scroll area with an inner width of 600 pixels and height of 106 pixels (default view, no zoom)
  #SCS_VIEW_CODE_C     ; display entire file in the graph's scroll area with an inner width in pixels specified by \nViewWidth (implemented in 11.2.4 for DPI-aware processing)
EndEnumeration

;- VU display mode
Enumeration
  #SCS_VU_NONE
  #SCS_VU_LEVELS
EndEnumeration

;- VU Peak Hold
Enumeration
  #SCS_PEAK_NONE
  #SCS_PEAK_AUTO
  #SCS_PEAK_HOLD
EndEnumeration

;- VU Meter Bar Width
Enumeration
  #SCS_VUBARWIDTH_NARROW
  #SCS_VUBARWIDTH_MEDIUM
  #SCS_VUBARWIDTH_WIDE
EndEnumeration

;- MIDI constants
#MSC_DEFAULT_COMMAND_FORMAT = $10
#IN_BUFFER_LEN = 256 ; maximum length supported by 

;- MIDI NRPN Format
Enumeration
  #SCS_MIDI_NRPN_STD
  #SCS_MIDI_NRPN_YAMAHA
EndEnumeration

;- MIDI Control
Enumeration
  ; cue control method
  #SCS_CTRLMETHOD_NONE
  #SCS_CTRLMETHOD_MTC
  #SCS_CTRLMETHOD_MSC
  #SCS_CTRLMETHOD_MMC
  #SCS_CTRLMETHOD_NOTE
  #SCS_CTRLMETHOD_PC127
  #SCS_CTRLMETHOD_PC128
  #SCS_CTRLMETHOD_ETC_AB
  #SCS_CTRLMETHOD_ETC_CD
  #SCS_CTRLMETHOD_PALLADIUM
  #SCS_CTRLMETHOD_CUSTOM
EndEnumeration

Enumeration 0
  ; constants for MIDI cue control commands (cue-related commands)
  #SCS_MIDI_PLAY_CUE
  #SCS_MIDI_PAUSE_RESUME_CUE
  #SCS_MIDI_RELEASE_CUE
  #SCS_MIDI_FADE_OUT_CUE
  #SCS_MIDI_STOP_CUE
  #SCS_MIDI_GO_TO_CUE
  #SCS_MIDI_LOAD_CUE
  #SCS_MIDI_UNLOAD_CUE
EndEnumeration
#SCS_MIDI_LAST_SCS_CUE_RELATED = #PB_Compiler_EnumerationValue - 1
Enumeration #PB_Compiler_EnumerationValue
  ; constants for MIDI cue control commands (non cue-related commands)
  #SCS_MIDI_GO_BUTTON
  #SCS_MIDI_STOP_ALL
  #SCS_MIDI_FADE_ALL ; 7May2022 11.9.1
  #SCS_MIDI_PAUSE_RESUME_ALL
  #SCS_MIDI_GO_TO_TOP
  #SCS_MIDI_GO_BACK
  #SCS_MIDI_GO_TO_NEXT
  #SCS_MIDI_PAGE_UP
  #SCS_MIDI_PAGE_DOWN
  #SCS_MIDI_GO_CONFIRM
  #SCS_MIDI_OPEN_FAV_FILE
  #SCS_MIDI_SET_HOTKEY_BANK
  #SCS_MIDI_TAP_DELAY
  #SCS_MIDI_MASTER_FADER
  #SCS_MIDI_DEVICE_1_FADER
  #SCS_MIDI_DEVICE_2_FADER
  #SCS_MIDI_DEVICE_3_FADER
  #SCS_MIDI_DEVICE_4_FADER
  #SCS_MIDI_DEVICE_5_FADER
  #SCS_MIDI_DEVICE_6_FADER
  #SCS_MIDI_DEVICE_7_FADER
  #SCS_MIDI_DEVICE_8_FADER ; see also #SCS_MIDI_DEVICE_LAST_FADER
  #SCS_MIDI_DIMMER_1_FADER
  #SCS_MIDI_DIMMER_2_FADER
  #SCS_MIDI_DIMMER_3_FADER
  #SCS_MIDI_DIMMER_4_FADER
  #SCS_MIDI_DIMMER_5_FADER
  #SCS_MIDI_DIMMER_6_FADER
  #SCS_MIDI_DIMMER_7_FADER
  #SCS_MIDI_DIMMER_8_FADER ; see also #SCS_MIDI_DIMMER_LAST_FADER
  #SCS_MIDI_DMX_MASTER
  #SCS_MIDI_EXT_FADER
  #SCS_MIDI_CUE_MARKER_PREV ; Added 3May2022 11.9.1
  #SCS_MIDI_CUE_MARKER_NEXT ; Added 3May2022 11.9.1
EndEnumeration
#SCS_MAX_MIDI_COMMAND = #PB_Compiler_EnumerationValue - 1
#SCS_MIDI_DEVICE_LAST_FADER = #SCS_MIDI_DEVICE_8_FADER
#SCS_MIDI_DIMMER_LAST_FADER = #SCS_MIDI_DIMMER_8_FADER

#SCS_MIDI_ANY_VALUE = -99

Enumeration
  ; constants for X32 cue control commands (non cue-related commands)
  #SCS_X32_GO_BUTTON
  #SCS_X32_STOP_ALL
  #SCS_X32_FADE_ALL ; Added 3Jun2021 11.8.5
  #SCS_X32_PAUSE_RESUME_ALL
  #SCS_X32_GO_TO_TOP
  #SCS_X32_GO_BACK
  #SCS_X32_GO_TO_NEXT
  #SCS_X32_TAP_DELAY
;   #SCS_X32_PAGE_UP            ; this and the following commands not implemented yet
;   #SCS_X32_PAGE_DOWN
;   #SCS_X32_MASTER_FADER
;   #SCS_X32_GO_CONFIRM
EndEnumeration
#SCS_MAX_X32_COMMAND = #PB_Compiler_EnumerationValue - 1

;- remote app interface and 'SCS Primary' commands
Enumeration
  ; constants for cue control commands from remote devices (not necessarily 'remote app') or from the SCS Primary instance
  ; constant naming based on SCS OSC commands (apart from DMX constants) but constants may be used for any remote interface
  
  ; INFO RECEIVE-ONLY (< 1000)
  #SCS_OSCINP_CTRL_GO = 1
  #SCS_OSCINP_CTRL_GO_CONFIRM
  #SCS_OSCINP_CTRL_STOP_ALL
  #SCS_OSCINP_CTRL_FADE_ALL
  #SCS_OSCINP_CTRL_PAUSE_RESUME_ALL
  #SCS_OSCINP_CTRL_STOP_MTC
  #SCS_OSCINP_CTRL_OPEN_NEXT_CUES
  #SCS_OSCINP_CTRL_GO_TO_TOP
  #SCS_OSCINP_CTRL_GO_BACK
  #SCS_OSCINP_CTRL_GO_TO_NEXT
  #SCS_OSCINP_CTRL_GO_TO_END
  #SCS_OSCINP_CTRL_GO_TO_CUE
  #SCS_OSCINP_CUE_PLAY
  #SCS_OSCINP_CUE_STOP
  #SCS_OSCINP_CUE_PAUSE_RESUME
  #SCS_OSCINP_HKEY_GO
  #SCS_OSCINP_HKEY_ON
  #SCS_OSCINP_HKEY_OFF
  #SCS_OSCINP_CUE_SET_POS
  #SCS_OSCINP_FADER_SET_MASTER
  #SCS_OSCINP_FADER_SET_MASTER_PERCENT
  #SCS_OSCINP_FADER_SET_MASTER_RELATIVE
  #SCS_OSCINP_FADER_SET_DEVICE
  #SCS_OSCINP_FADER_SET_DEVICE_PERCENT
  #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
  #SCS_OSCINP_FMH_BCA ; functional mode handler - backup connection accepted
  #SCS_OSCINP_PNL_BTN_CLICK
  #SCS_OSCINP_X32_CONFIG_NAME
  #SCS_OSCINP_SET_PLAYORDER
  #SCS_OSCINP_POLL
  #SCS_OSCINP_IGNORE
  
  ; INFO RECEIVE AND SEND REPLY (> 1000)
  #SCS_OSCINP_STATUS = 1001 ; X32
  #SCS_OSCINP_INFO          ; X32
  #SCS_OSCINP_XINFO         ; X32
  #SCS_OSCINP_BEAT ; Added for X32TC heart-beat
  #SCS_OSCINP_FILE_OPEN
  #SCS_OSCINP_INFO_SCS_VERSION
  #SCS_OSCINP_INFO_FINAL_CUE
  #SCS_OSCINP_INFO_CURR_CUE
  #SCS_OSCINP_INFO_NEXT_CUE
  #SCS_OSCINP_INFO_GET_CUE
  #SCS_OSCINP_INFO_HKEY_COUNT
  #SCS_OSCINP_INFO_GET_HKEY
  #SCS_OSCINP_INFO_GET_COLORS
  #SCS_OSCINP_INFO_PRODUCT ; Added for X32TC
  #SCS_OSCINP_INFO_CUE_FILE ; Added for X32TC
  #SCS_OSCINP_INFO_TITLE ; Same as #SCS_OSCINP_PROD_GET_TITLE but added for X32TC
  #SCS_OSCINP_CUE_GET_ITEMS_X
  #SCS_OSCINP_CUE_GET_ITEMS_N
  #SCS_OSCINP_CUE_GET_NAME
  #SCS_OSCINP_CUE_GET_PAGE
  #SCS_OSCINP_CUE_GET_WHEN_REQD
  #SCS_OSCINP_CUE_GET_TYPE
  #SCS_OSCINP_CUE_GET_LENGTH
  #SCS_OSCINP_CUE_GET_POS
  #SCS_OSCINP_CUE_GET_STATE
  #SCS_OSCINP_CUE_GET_COLORS
  #SCS_OSCINP_PROD_GET_TITLE
  #SCS_OSCINP_FADER_GET_MASTER
  #SCS_OSCINP_FADER_GET_MASTER_PERCENT
  #SCS_OSCINP_FADER_GET_DEVICE
  #SCS_OSCINP_FADER_GET_DEVICE_PERCENT
  
EndEnumeration

;- remote app interface status
; nb although this could be set up using EnumerationBinary, the individual values have been specifically assigned
; as a reminder that these values are 'locked' as they may be used externally, ie by a remote app
#SCS_RAI_STATUS_FILE = 1        ; cue file has been closed or a new cue file has been opened since the last /status request
#SCS_RAI_STATUS_PROD = 2        ; the production title has been changed since the last /status request
#SCS_RAI_STATUS_CUE = 4         ; at least one cue has been added, changed or deleted since the last /status request
; NB see "If (grRAI\nStatus & 7) <> 0" in handleWindowEvents() if any changes made to the above or similar reasons for sending status to the remote app unsolicited
#SCS_RAI_STATUS_MASTER = 8      ; the master fader dB setting has been changed since the last /status request
#SCS_RAI_STATUS_PLAYING = 16    ; at least one cue is currently playing

;- remote app values for 'cue state'
; nb although this could be set up using an Enumeration, the individual values have been specifically assigned
; as a reminder that these values are 'locked' as they may be used externally, ie by a remote app
#SCS_RAI_CUE_STATE_WAITING = 0    ; eg 'not loaded' or 'ready'
#SCS_RAI_CUE_STATE_PLAYING = 1
#SCS_RAI_CUE_STATE_PAUSED = 2
#SCS_RAI_CUE_STATE_ENDED = 3

;- remote app
Enumeration
  #SCS_RAI_APP_SCSREMOTE ; default
  #SCS_RAI_APP_OSC
EndEnumeration

;- Control Send Message Types (MIDI)
; See #SCS_CS_OSC_... for Network Control Send commands
Enumeration
  #SCS_MSGTYPE_NONE
  #SCS_MSGTYPE_PC127
  #SCS_MSGTYPE_PC128
  #SCS_MSGTYPE_CC
  #SCS_MSGTYPE_ON
  #SCS_MSGTYPE_OFF
  #SCS_MSGTYPE_MSC
  #SCS_MSGTYPE_MMC   ; MMC seems to be partially coded in SCS 10 for Control Sends
  #SCS_MSGTYPE_NRPN_GEN ; 'Standard' NRPN (NRPN MSB, NRPN LSB, Data MSB, Data LSB)
  #SCS_MSGTYPE_NRPN_YAM ; Yamaha NRPN     (NRPN LSB, NRPN MSB, Data MSB, Data LSB)
  #SCS_MSGTYPE_FREE
  #SCS_MSGTYPE_OSC_OVER_MIDI ; not yet implemented - see "#c_include_osc_over_midi_sysex"
  #SCS_MSGTYPE_FILE  
  #SCS_MSGTYPE_RS232
  #SCS_MSGTYPE_NETWORK
  #SCS_MSGTYPE_SCRIBBLE_STRIP
  #SCS_MSGTYPE_DUMMY_LAST
EndEnumeration

#SCS_MIDI_IN_BUFFER_LEN = 255
#SCS_MIDI_OUT_BUFFER_LEN = 255

;- entry mode (RS232 and NETWORK)
Enumeration
  #SCS_ENTRYMODE_ASCII
  #SCS_ENTRYMODE_HEX
  #SCS_ENTRYMODE_ASCII_PLUS_CTL
  #SCS_ENTRYMODE_UTF8 ; Added 14Apr2020 11.8.2.3ar
EndEnumeration

;- DMX Control

Enumeration 1
  #SCS_DMX_MODE_OUTPUT
  #SCS_DMX_MODE_INPUT
EndEnumeration

; constants for DMX cue control commands (non cue-related commands)
Enumeration
  #SCS_DMX_GO_BUTTON
  #SCS_DMX_STOP_ALL
  #SCS_DMX_PAUSE_RESUME_ALL
  #SCS_DMX_GO_TO_TOP
  #SCS_DMX_GO_BACK
  #SCS_DMX_GO_TO_NEXT
  #SCS_DMX_MASTER_FADER
  #SCS_DMX_PLAY_DMX_CUE_0
  #SCS_DMX_PLAY_DMX_CUE_MAX
EndEnumeration
#SCS_MAX_DMX_COMMAND = #PB_Compiler_EnumerationValue - 1

Enumeration
  #SCS_DMX_NOTATION_0_255
  #SCS_DMX_NOTATION_PERCENT
EndEnumeration

Enumeration
  #SCS_DMX_GRIDTYPE_UNIVERSE
  #SCS_DMX_GRIDTYPE_ALL_FIXTURES
EndEnumeration

EnumerationBinary   ; used in \nDMXFlags
  #SCS_DMX_CS_DMX     ; sDMXItemStr contains DMX absolute value preceded by "dmx", eg 1-2@dmx475 for DMX value 475
  #SCS_DMX_CS_D       ; sDMXItemStr contains DMX absolute value preceded by "d", eg 1-2@d475 for DMX value 475
  #SCS_DMX_CS_FADE    ; sDMXItemStr contains fade time preceded by "fade", eg 1-2@0fade3 to fade out over 3 seconds
  #SCS_DMX_CS_F       ; sDMXItemStr contains fade time preceded by "f", eg 1-2@0f3 to fade out over 3 seconds
EndEnumeration

Enumeration
  #SCS_DMX_TRG_CHG_UP_TO_VALUE
  #SCS_DMX_TRG_CHG_FROM_ZERO
  #SCS_DMX_TRG_ANY_CHG
EndEnumeration

;- DMX fade fields
Enumeration
  #SCS_DMX_FADE_FIELD_FI_FADEUP
  #SCS_DMX_FADE_FIELD_FI_FADEDOWN
  #SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS
  #SCS_DMX_FADE_FIELD_BL_FADE
  #SCS_DMX_FADE_FIELD_DI_FADEUP
  #SCS_DMX_FADE_FIELD_DI_FADEDOWN
  #SCS_DMX_FADE_FIELD_DI_FADEOUTOTHERS
  #SCS_DMX_FADE_FIELD_DC_FADEUP
  #SCS_DMX_FADE_FIELD_DC_FADEDOWN
  #SCS_DMX_FADE_FIELD_DC_FADEOUTOTHERS
EndEnumeration

;- DMX fade actions
Enumeration ; DMX fade time actions for entry type 'Fixture'
  #SCS_DMX_FI_FADE_ACTION_NONE
  #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
  #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
  #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
  #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
  #SCS_DMX_FI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
  #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
EndEnumeration

Enumeration ; DMX fade time actions for entry type 'Blackout'
  #SCS_DMX_BL_FADE_ACTION_NONE
  #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
  #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
EndEnumeration

Enumeration ; DMX fade time actions for entry type 'DMX Items'
  #SCS_DMX_DI_FADE_ACTION_NONE
  #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
  #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
  #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME
  #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
  #SCS_DMX_DI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
  #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
EndEnumeration

Enumeration ; DMX fade time actions for entry type 'DMX Capture'
  #SCS_DMX_DC_FADE_ACTION_NONE
  #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
  #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
  #SCS_DMX_DC_FADE_ACTION_USE_FADEUP_TIME
  #SCS_DMX_DC_FADE_ACTION_USE_FADEDOWN_TIME
  #SCS_DMX_DC_FADE_ACTION_USE_FADEOUTOTHERS_TIME
  #SCS_DMX_DC_FADE_ACTION_DO_NOT_FADEOUTOTHERS
EndEnumeration

Enumeration ; chase mode
  #SCS_DMX_CHASE_MODE_FORWARD
  #SCS_DMX_CHASE_MODE_REVERSE
  #SCS_DMX_CHASE_MODE_BOUNCE
  #SCS_DMX_CHASE_MODE_RANDOM
EndEnumeration

Enumeration ; chase control
  #SCS_DMX_CHASE_CTL_NONE ; chase speed not set
  #SCS_DMX_CHASE_CTL_CUE  ; chase speed determined by the sub-cue's chase BPM
  #SCS_DMX_CHASE_CTL_TAP  ; chase speed determined by the tap delay BPM
EndEnumeration

Enumeration ; dmx send origin
  #SCS_DMX_ORIGIN_CUE           ; (default) DMX value set by a Lighting Cue
  #SCS_DMX_ORIGIN_CHANNEL_FADER ; DMX value set by the user moving a DMX channel fader in the Control Panel, or on a device such as the KORG nanoKONTROL2
  #SCS_DMX_ORIGIN_MASTER_FADER  ; DMX value set by the user moving the DMX master fader in the Control Panel, or on a device such as the KORG nanoKONTROL2
EndEnumeration

;- network incoming message actions
Enumeration
  #SCS_NETWORK_ACT_NOT_SET
  #SCS_NETWORK_ACT_NONE
  #SCS_NETWORK_ACT_REPLY
  #SCS_NETWORK_ACT_READY
  #SCS_NETWORK_ACT_AUTHENTICATE
EndEnumeration

;- control send remote devices (midi)
Enumeration
  #SCS_CS_MIDI_REM_ANY
  #SCS_CS_MIDI_REM_AH_QU
  #SCS_CS_MIDI_REM_AH_SQ
EndEnumeration
#SCS_MAX_CS_MIDI_REM_DEV = #PB_Compiler_EnumerationValue - 1

;- control send remote devices (network)
Enumeration
  #SCS_CS_NETWORK_REM_ANY
  #SCS_CS_NETWORK_REM_SCS
  #SCS_CS_NETWORK_REM_PJLINK
  #SCS_CS_NETWORK_REM_PJNET
  #SCS_CS_NETWORK_REM_OSC_X32
  #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
  #SCS_CS_NETWORK_REM_OSC_X32TC ; Added 7Jun2021 11.8.5af
  #SCS_CS_NETWORK_REM_OSC_OTHER
  #SCS_CS_NETWORK_REM_LF
  #SCS_CS_NETWORK_REM_VMIX ; Added 21Sep2020
EndEnumeration
#SCS_MAX_CS_NETWORK_REM_DEV = #PB_Compiler_EnumerationValue - 1

;- cue control remote devices (network)
Enumeration
  #SCS_CC_NETWORK_REM_ANY
  #SCS_CC_NETWORK_REM_SCS
  #SCS_CC_NETWORK_REM_OSC_X32
  #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
  #SCS_CC_NETWORK_REM_OSC_X32TC
  #SCS_CC_NETWORK_REM_LF
EndEnumeration
#SCS_MAX_CC_NETWORK_REM_DEV = #PB_Compiler_EnumerationValue - 1

;- cue control commands
Enumeration 1
  #SCS_CCC_GO
  #SCS_CCC_GO_CONFIRM
  #SCS_CCC_STOP_ALL
  #SCS_CCC_FADE_ALL
  #SCS_CCC_PAUSE_RESUME_ALL
  #SCS_CCC_GO_TO_TOP
  #SCS_CCC_GO_BACK
  #SCS_CCC_GO_TO_NEXT
  #SCS_CCC_GO_TO_END
  #SCS_CCC_GO_TO_CUE_X
  #SCS_CCC_PLAY_CUE_X
  #SCS_CCC_STOP_CUE_X
  #SCS_CCC_PAUSE_RESUME_CUE_X
  #SCS_CCC_PLAY_HOTKEY_X
  #SCS_CCC_START_NOTE_HOTKEY_X
  #SCS_CCC_STOP_NOTE_HOTKEY_X
  #SCS_CCC_SET_MASTER_FADER_DB
  #SCS_CCC_SET_DEVICE_FADER_DB
EndEnumeration

;- network protocol
Enumeration
  ; #SCS_NETWORK_PR_TELNET
  #SCS_NETWORK_PR_TCP
  #SCS_NETWORK_PR_UDP
EndEnumeration

;- network inter-message delay
#SCS_NETWORK_DELAY_TCP = 100  ; default inter-message delay for network messages sent via TCP
#SCS_NETWORK_DELAY_UDP = 0    ; default inter-message delay for network messages sent via UDP

;- OSC command types
; See #SCS_MSGTYPE_... for MIDI Control Send equivalents and more
CompilerIf #c_more_x32_osc_commands
Enumeration
  #SCS_CS_OSC_NOT_SET
  ; command types for X32 and X32 Compact
  #SCS_CS_OSC_DUMMY_FIRST
  #SCS_CS_OSC_GOCUE
  #SCS_CS_OSC_GOSCENE
  #SCS_CS_OSC_GOSNIPPET
  #SCS_CS_OSC_MUTECHANNEL ; NOTE: See also #SCS_CS_OSC_MUTE_FIRST
  #SCS_CS_OSC_MUTEDCAGROUP
  #SCS_CS_OSC_MUTEAUXIN
  #SCS_CS_OSC_MUTEFXRTN
  #SCS_CS_OSC_MUTEBUS
  #SCS_CS_OSC_MUTEMATRIX
  ; #SCS_CS_OSC_MUTEMAIN ; handles LR and MC (mono/center)
  #SCS_CS_OSC_MUTEMAINLR
  #SCS_CS_OSC_MUTEMAINMC
  #SCS_CS_OSC_MUTEMG ; NOTE: See also #SCS_CS_OSC_MUTE_LAST
  #SCS_CS_OSC_CHANNELLEVEL ; NOTE: See also #SCS_CS_OSC_LEVEL_FIRST
  #SCS_CS_OSC_DCALEVEL
  #SCS_CS_OSC_AUXINLEVEL
  #SCS_CS_OSC_FXRTNLEVEL
  #SCS_CS_OSC_BUSLEVEL
  #SCS_CS_OSC_MATRIXLEVEL
  #SCS_CS_OSC_MAINLRFADER
  #SCS_CS_OSC_MAINMCFADER ; NOTE: See also #SCS_CS_OSC_LEVEL_LAST
  #SCS_CS_OSC_DUMMY_LAST
  ; command types for X32 Theatre Control
  #SCS_CS_OSC_TC_DUMMY_FIRST
  #SCS_CS_OSC_TC_GO
  #SCS_CS_OSC_TC_BACK
  #SCS_CS_OSC_TC_JUMP
  #SCS_CS_OSC_TC_DUMMY_LAST
  ; free format
  #SCS_CS_OSC_FREEFORMAT
EndEnumeration
#SCS_CS_OSC_MUTE_FIRST = #SCS_CS_OSC_MUTECHANNEL
#SCS_CS_OSC_MUTE_LAST = #SCS_CS_OSC_MUTEMG
#SCS_CS_OSC_LEVEL_FIRST = #SCS_CS_OSC_CHANNELLEVEL
#SCS_CS_OSC_LEVEL_LAST = #SCS_CS_OSC_MAINMCFADER
CompilerElse
Enumeration
  #SCS_CS_OSC_NOT_SET
  ; command types for X32 and X32 Compact
  #SCS_CS_OSC_DUMMY_FIRST
  #SCS_CS_OSC_GOCUE
  #SCS_CS_OSC_GOSCENE
  #SCS_CS_OSC_GOSNIPPET
  #SCS_CS_OSC_MUTECHANNEL ; NOTE: See also #SCS_CS_OSC_MUTE_FIRST
  #SCS_CS_OSC_MUTEDCAGROUP
  #SCS_CS_OSC_MUTEAUXIN
  #SCS_CS_OSC_MUTEFXRTN
  #SCS_CS_OSC_MUTEBUS
  #SCS_CS_OSC_MUTEMATRIX
  #SCS_CS_OSC_MUTEMG
  #SCS_CS_OSC_MUTEMAINLR
  #SCS_CS_OSC_MUTEMAINMC ; NOTE: See also #SCS_CS_OSC_MUTE_LAST
  #SCS_CS_OSC_DUMMY_LAST
  ; command types for X32 Theatre Control
  #SCS_CS_OSC_TC_DUMMY_FIRST
  #SCS_CS_OSC_TC_GO
  #SCS_CS_OSC_TC_BACK
  #SCS_CS_OSC_TC_JUMP
  #SCS_CS_OSC_TC_DUMMY_LAST
  ; free format
  #SCS_CS_OSC_FREEFORMAT
EndEnumeration
#SCS_CS_OSC_MUTE_FIRST = #SCS_CS_OSC_MUTECHANNEL
#SCS_CS_OSC_MUTE_LAST = #SCS_CS_OSC_MUTEMAINMC
CompilerEndIf

;- OSC Versions
; NB -1 assigned elsewhere for 'not OSC'
Enumeration
  #SCS_OSC_VER_1_0 ; OSC 1.0
  #SCS_OSC_VER_1_1 ; OSC 1.1
EndEnumeration
#SCS_MAX_OSC_VER = #PB_Compiler_EnumerationValue - 1

;- mute action
Enumeration
  #SCS_MUTE_ON
  #SCS_MUTE_OFF
EndEnumeration

;- network role
Enumeration
  #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
  #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
  #SCS_ROLE_DUMMY
EndEnumeration

;- network message format
Enumeration
  #SCS_NETWORK_MSG_ASCII
  #SCS_NETWORK_MSG_OSC
EndEnumeration

;- memory allocation fixed sizes
#SCS_MEM_SIZE_NETWORK_BUFFERS = 2048

;- video playback libraries
Enumeration
  #SCS_VPL_NOT_SET
  #SCS_VPL_IMAGE          ; only used for images
  #SCS_VPL_TVG
  #SCS_VPL_VMIX
EndEnumeration

;- video renderer
Enumeration
  #SCS_VR_AUTOSELECT
  #SCS_VR_EVR
  #SCS_VR_VMR9
  #SCS_VR_VMR7
  #SCS_VR_STANDARD
  #SCS_VR_OVERLAY
  #SCS_VR_BLACKMAGIC_DECKLINK
EndEnumeration

;- monitor size
Enumeration
  #SCS_MON_NONE
  #SCS_MON_SMALL
  #SCS_MON_STD
  #SCS_MON_LARGE
EndEnumeration

;- aspect ratio types
Enumeration
  #SCS_ART_ORIGINAL
  #SCS_ART_FULL
  #SCS_ART_16_9
  #SCS_ART_4_3
  #SCS_ART_185_1
  #SCS_ART_235_1
  #SCS_ART_CUSTOM
EndEnumeration

;- aspect ratio values
Enumeration 1
  #SCS_AR_16_9
  #SCS_AR_4_3
  #SCS_AR_185_1
  #SCS_AR_235_1
EndEnumeration

;- video and picture targets
; values nominated below are critical
; The range from #SCS_VID_PIC_TARGET_T onwards map to occurrrences of grVidPicTarget() so #SCS_VID_PIC_TARGET_T must be 0.
; #SCS_VID_PIC_TARGET_P must immediately precede #SCS_VID_PIC_TARGET_F2 so that blending loops etc can use "#SCS_VID_PIC_TARGET_P To #SCS_VID_PIC_TARGET_LAST" or similar.
; #SCS_VID_PIC_TARGET_F2 must = 2 as it is to match screen number 2. Same for F3 onwards.
Enumeration
  #SCS_VID_PIC_TARGET_TEST = -5 ; used in Production Properties / Devices / Video Capture for 'Test Video Capture'
  #SCS_VID_PIC_TARGET_F2_TO_LAST = -4
  #SCS_VID_PIC_TARGET_FRAME_CAPTURE = -3  ; added for TVG
  #SCS_VID_PIC_TARGET_UNKNOWN = -2  ; used in calls to setLevelsVideo() to instruct setLevelsVideo() to derive the target from aAud() and aSub()
  #SCS_VID_PIC_TARGET_NONE = -1
  #SCS_VID_PIC_TARGET_T = 0     ; timeline in editor (in fmEditQA)
  #SCS_VID_PIC_TARGET_P = 1     ; preview in editor (in fmEditQA)
  #SCS_VID_PIC_TARGET_F2 = 2    ; display on 'output screen 2'
  #SCS_VID_PIC_TARGET_F3        ; display on 'output screen 3'
  #SCS_VID_PIC_TARGET_F4        ; display on 'output screen 4'
  #SCS_VID_PIC_TARGET_F5        ; display on 'output screen 5'
  #SCS_VID_PIC_TARGET_F6        ; display on 'output screen 6'
  #SCS_VID_PIC_TARGET_F7        ; display on 'output screen 7'
  #SCS_VID_PIC_TARGET_F8        ; display on 'output screen 8'
  #SCS_VID_PIC_TARGET_F9        ; display on 'output screen 9'
EndEnumeration
#SCS_VID_PIC_TARGET_LAST = #PB_Compiler_EnumerationValue - 1  ; see also grRegInfo\nLastVidPicTarget

;- video sources
Enumeration
  #SCS_VID_SRC_FILE
  #SCS_VID_SRC_CAPTURE
EndEnumeration

;- vMix constants
#SCS_VMIX_XML = 99 ; arbitrary constant for the #XML handle for ParseXML() etc

;- playlist test modes
Enumeration
  ; enumeration must match order in which WQP\cboPLTestMode is populated - see WQP_FormLoad()
  #SCS_PLTESTMODE_COMPLETE_PLAYLIST
  #SCS_PLTESTMODE_10_SECS
  #SCS_PLTESTMODE_5_SECS
  #SCS_PLTESTMODE_HIGHLIGHTED_FILE
EndEnumeration

;- production timer actions
Enumeration
  ; to be in required order of items in cboProdTimerAction fields in WPT
  #SCS_PTA_NO_ACTION
  #SCS_PTA_START_S    ; Start timer (at 0:00) when cue starts
  #SCS_PTA_START_E    ; Start timer (at 0:00) when cue ends
  #SCS_PTA_PAUSE_S    ; Pause timer when cue starts
  #SCS_PTA_PAUSE_E    ; Pause timer when cue ends
  #SCS_PTA_RESUME_S   ; Resume timer when cue starts
  #SCS_PTA_RESUME_E   ; Resume timer when cue ends
  CompilerIf #c_prod_timer_extra_actions
    #SCS_PTA_SHOW_TIMER ; Show production timer
    #SCS_PTA_HIDE_TIMER ; Hide production timer
    #SCS_PTA_SHOW_CLOCK ; Show time-of-day clock
    #SCS_PTA_HIDE_CLOCK ; Hide time-of-day clock
  CompilerEndIf
EndEnumeration
#SCS_PTA_LAST = #PB_Compiler_EnumerationValue - 1

;- production timer actions for history
Enumeration 1
  #SCS_PTHA_STARTED
  #SCS_PTHA_PAUSED
  #SCS_PTHA_RESUMED
EndEnumeration

;- production timer 'when'
Enumeration
  #SCS_PTW_WHEN_CUE_STARTS
  #SCS_PTW_WHEN_CUE_ENDS
EndEnumeration

;- production timer states
Enumeration
  #SCS_PTS_NOT_STARTED
  #SCS_PTS_RUNNING
  #SCS_PTS_PAUSED
EndEnumeration

;- production timer display location
Enumeration
  #SCS_PTD_STATUS_LINE
  #SCS_PTD_SEPARATE_WINDOW
EndEnumeration

;- graph constants (audio file graph)
Enumeration
  #SCS_SLICE_TYPE_NONE
  #SCS_SLICE_TYPE_NORMAL
  #SCS_SLICE_TYPE_CURR  ; current position
  #SCS_SLICE_TYPE_ST    ; start at
  #SCS_SLICE_TYPE_EN    ; end at
  #SCS_SLICE_TYPE_LS    ; loop start
  #SCS_SLICE_TYPE_LE    ; loop end
  #SCS_SLICE_TYPE_FI    ; fade-in (end point)
  #SCS_SLICE_TYPE_FO    ; fade-out (start point)
  #SCS_SLICE_TYPE_LP    ; level point
  #SCS_SLICE_TYPE_CM    ; SCS cue marker
  #SCS_SLICE_TYPE_CP    ; file cue point
EndEnumeration

;- graph marker constants
#SCS_FADE_GRAPH_MARKER_RADIUS = 4
#SCS_FADE_GRAPH_MARKER_DIAMETER = #SCS_FADE_GRAPH_MARKER_RADIUS + #SCS_FADE_GRAPH_MARKER_RADIUS + 1   ; nb +1 because 'Radius' in Circle() does not include the center pixel

Enumeration
  #SCS_GRAPH_MARKER_NONE
  #SCS_GRAPH_MARKER_ST    ; start at
  #SCS_GRAPH_MARKER_EN    ; end at
  #SCS_GRAPH_MARKER_LS    ; loop start
  #SCS_GRAPH_MARKER_LE    ; loop end
  #SCS_GRAPH_MARKER_FI    ; fade-in (end point)
  #SCS_GRAPH_MARKER_FO    ; fade-out (start point)
  #SCS_GRAPH_MARKER_LP    ; level point
  #SCS_GRAPH_MARKER_CM    ; SCS cue marker
  #SCS_GRAPH_MARKER_CP    ; File cue point
EndEnumeration

Enumeration
  #SCS_GRAPH_MARKER_LEVEL
  #SCS_GRAPH_MARKER_PAN
EndEnumeration

Enumeration
  #SCS_GRAPH_MARKER_DRAG_NO_ACTION
  #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION
  #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL
  #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
EndEnumeration

;- samples array populate status
Enumeration
  #SCS_SAP_NONE
  #SCS_SAP_REQUESTED
  #SCS_SAP_IN_PROGRESS
  #SCS_SAP_DONE
  #SCS_SAP_NOT_REQD
EndEnumeration

;- display mode
Enumeration
  #SCS_GRAPH_ADJ
  #SCS_GRAPH_ADJN
  #SCS_GRAPH_FILE
  #SCS_GRAPH_FILEN
EndEnumeration

;- graph max inner width
#SCS_GRAPH_MAX_INNER_WIDTH = 2000 * 20    ; allows for up to 2000 pixels wide by zoom factor of 20
#SCS_GRAPH_MAX_PEAK = 127                 ; used in determining stored peak and min data - currently limited to capacity of one byte (-128 to +127)

;- level point constants
Enumeration 1 ; level point types (must be logically in order for 'sanityCheckLevelPoints()')
  #SCS_PT_UNUSED_BOF
  #SCS_PT_UNUSED_MIN
  #SCS_PT_START
  #SCS_PT_FADE_IN
  #SCS_PT_STD
  #SCS_PT_FADE_OUT
  #SCS_PT_END
  #SCS_PT_UNUSED_MAX
  #SCS_PT_UNUSED_EOF
EndEnumeration

Enumeration ; level selection
  #SCS_LVLSEL_INDIV
  #SCS_LVLSEL_SYNC
  #SCS_LVLSEL_LINK
EndEnumeration

Enumeration ; pan selection
  #SCS_PANSEL_USEAUDDEV
  #SCS_PANSEL_INDIV
  #SCS_PANSEL_SYNC
EndEnumeration

Enumeration 1 ; level node types
  #SCS_LNT_END
  #SCS_LNT_FADE_IN_END
  #SCS_LNT_FADE_OUT_START
  #SCS_LNT_XFADE_START
  #SCS_LNT_XFADE_END
  #SCS_LNT_STD_LEVEL_POINT
  #SCS_LNT_REQD_FADE_END
EndEnumeration

;- slider constants
Enumeration ; slider types
  #SCS_ST_PROGRESS
  #SCS_ST_POSITION
  #SCS_ST_PAN
  #SCS_ST_PANNOLR
  #SCS_ST_HLEVEL
  #SCS_ST_HLEVELRUN
  #SCS_ST_HLEVELNODB
  #SCS_ST_ROTARYGAIN
  #SCS_ST_HPERCENT
  #SCS_ST_HLEVELCHANGERUN
  #SCS_ST_HLEVELCHANGERUNPL
  #SCS_ST_HGENERAL
  #SCS_ST_VGENERAL
  ; The order of the following VFADER constants must be retained as it determines the order of the faders in the 'Faders' window.
  ; If the order is to be changed, or the list extended, then other program changes will also need to be done, in Windows.pbi, fmControllers.pbi and SliderControl.pbi.
  #SCS_ST_VFADER_LIVE_INPUT
  #SCS_ST_VFADER_OUTPUT
  #SCS_ST_VFADER_PLAYING ; nb 'playing' and 'output' are mutually exclusive, ie if 'playing' is displayed (for NK2 Preset C) then 'output' will not be displayed
  #SCS_ST_VFADER_MASTER
  #SCS_ST_VFADER_DMX_MASTER
  #SCS_ST_VFADER_DIMMER_CHAN
  ; End of VFADER constants
  #SCS_ST_HSCROLLBAR
  #SCS_ST_HLIGHTING_GENERAL
  #SCS_ST_HLIGHTING_PERCENT
  #SCS_ST_REMDEV_FADER_LEVEL
  #SCS_ST_FREQ
  #SCS_ST_TEMPO
  #SCS_ST_PITCH
EndEnumeration

Enumeration ; slider button styles
  #SCS_BUTTON_POINTER
  #SCS_BUTTON_ROUNDED_BOX
  #SCS_BUTTON_KNOB
  #SCS_BUTTON_FADER_LIVE_INPUT
  #SCS_BUTTON_FADER_OUTPUT
  #SCS_BUTTON_FADER_MASTER
  #SCS_BUTTON_FADER_DIMMER_CHAN ; Added 11Jul2022 11.9.4
  #SCS_BUTTON_FADER_DMX_MASTER
  #SCS_BUTTON_SCROLLBAR_THUMB
  #SCS_BUTTON_LIGHTING
  #SCS_BUTTON_HBOX
  #SCS_BUTTON_VBOX
EndEnumeration

#SCS_SLD_NO_BASE = -9999999
#SCS_SLD_BASE_EQUALS_CURRENT = -8888888
#SCS_SLD_MAX_MARKS = 40   ; nb needs 31 if max level = 0dB; 32 if max level = 12dB

; #SCS_SLD_MAX_LINES is only used for setting the initial size of slider arrays \m_LinePos and \m_LineType, but these array sizes may be increased in SLD_setLinePos()
#SCS_SLD_MAX_LINES = 3 + ((#SCS_MAX_LOOP + 1) * 2)  + 32

; Cue Markers -------------
#SCS_SLD_MAX_LINES_STD = 16 
#SCS_SLD_MAX_LINES_PRO = 32
#SCS_SLD_MAX_LINES_ULM = 9999999
; Cue Markers -------------

#SCS_SLD_BACKCOLOR = $444450           ; = RGB(80, 68, 68)
#SCS_SLD_FOCUS_BACKCOLOR = $FF9933     ; = RGB(51, 153, 255), = windows highlight background color for default color scheme
#SCS_SLD_FADER_BACKCOLOR = $606060
#SCS_MIXER_SLIDER_MAX = 10000

#SCS_POINTER_BORDERCOLOR1 = $010101       ; close to black but not black so that FillArea function has a definite border to work to
#SCS_POINTER_BORDERCOLOR2 = $010102       ; close to black but not black so that FillArea function has a definite border to work to

Enumeration ; events raised by the slider control - host action may be required
  #SCS_SLD_EVENT_NONE
  #SCS_SLD_EVENT_MOUSE_DOWN
  #SCS_SLD_EVENT_MOUSE_UP
  #SCS_SLD_EVENT_MOUSE_MOVE
  #SCS_SLD_EVENT_SCROLL
  #SCS_SLD_EVENT_GOT_FOCUS
  #SCS_SLD_EVENT_LOST_FOCUS
EndEnumeration

Enumeration ; constants for check control key
  #SCS_SLD_CCK_NONE   ; do not check control key down
  #SCS_SLD_CCK_BASE   ; position to 'base' value if set
  #SCS_SLD_CCK_ZERO   ; position to zero value (eg mid point for video size/ypos/xpos
  #SCS_SLD_CCK_0DB    ; position to '0 dB'
EndEnumeration

Enumeration ; slider tooltip types
  #SCS_SLD_TTT_NONE
  #SCS_SLD_TTT_GENERAL
  #SCS_SLD_TTT_SIZE
EndEnumeration

Enumeration ; slider tooltip actions
  #SCS_SLD_TTA_BUILD
  #SCS_SLD_TTA_SHOW
  #SCS_SLD_TTA_HIDE
EndEnumeration

Enumeration ; slider line types
  #SCS_SLD_LT_LOOP_START
  #SCS_SLD_LT_LOOP_END
  #SCS_SLD_LT_CUE_MARKER
EndEnumeration

Enumeration ; slider custom line types
  #SCS_SLD_CLT_MAJOR
  #SCS_SLD_CLT_MINOR
  #SCS_SLD_CLT_0DB
EndEnumeration

;- resize flags
; binary flags, allowing multiple flags to be or'd
#SCS_RESIZE_NORMAL = 0
#SCS_RESIZE_FIX_LEFT = 1
#SCS_RESIZE_FIX_TOP = 2
#SCS_RESIZE_FIX_WIDTH = 4
#SCS_RESIZE_FIX_HEIGHT = 8
#SCS_RESIZE_FIX_ALL = 15
#SCS_RESIZE_IGNORE = 16     ; control to be ignored by the procedure 'resizeControl'

;- Memo Display Options for primary window
Enumeration
  #SCS_MEMO_DISP_PRIM_POPUP
  #SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST
  #SCS_MEMO_DISP_PRIM_SHARE_MAIN
EndEnumeration

;- error codes
Enumeration 1000
  #SCS_ERROR_GADGET_NO_NOT_SET
  #SCS_ERROR_GADGET_NO_OUT_OF_RANGE
  #SCS_ERROR_GADGET_NO_INVALID
  #SCS_ERROR_FONT_NOT_SET
  #SCS_ERROR_FONT_INVALID
  #SCS_ERROR_SUBSCRIPT_OUT_OF_RANGE
  #SCS_ERROR_ARRAY_SIZE_INVALID
  #SCS_ERROR_POINTER_OUT_OF_RANGE
  #SCS_ERROR_MISC
EndEnumeration

;- error handler codes
Enumeration 0
  #SCS_EHC_NONE
  #SCS_EHC_GRAPH_PROGRESS_BAR
EndEnumeration

;- color scheme constants
; language translation not required as these names are saved in the preferences file
#SCS_COL_DEF_SCHEME_NAME = "SCS Default"    ; must be "SCS Default" as this is the name used in SCS 10 for the default color scheme
#SCS_COL_LIGHT_SCHEME_NAME = "SCS Light"
#SCS_COL_DARK_SCHEME_NAME = "SCS Dark"
CompilerIf #c_color_scheme_classic
  #SCS_COL_CLASSIC = "SCS Classic"            ; this scheme was "SCS Default" prior to SCS 11.8.3.2 when the default scheme was revised
  #SCS_MAX_INTERNAL_COL_SCHEME = 3            ; number of internal color schemes - 1
CompilerElse
  #SCS_COL_WIN_DEF = "SCS WinDef"             ; pseudo color scheme - use Windows defaults (eg glSysCol3DFace and glSysColWindowText)
  #SCS_MAX_INTERNAL_COL_SCHEME = 3            ; number of internal color schemes - 1
CompilerEndIf

Enumeration   ; enumeration order sets the order of the items in the Color Scheme Designer window
  #SCS_COL_ITEM_DF  ; Default Colors
  #SCS_COL_ITEM_QF  ; Audio File cue ; INFO: See also #SCS_COL_ITEM_Q_FIRST below
  #SCS_COL_ITEM_QP  ; Playlist cue
  #SCS_COL_ITEM_QA  ; Video/Image cue
  #SCS_COL_ITEM_QI  ; Live Input cue
  #SCS_COL_ITEM_QK  ; Lighting cue
  #SCS_COL_ITEM_QS  ; SFR cue
  #SCS_COL_ITEM_QL  ; Level Change cue
  #SCS_COL_ITEM_QM  ; Control Send cue
  #SCS_COL_ITEM_QG  ; Go To cue
  #SCS_COL_ITEM_QT  ; Set Position cue
  #SCS_COL_ITEM_QU  ; MTC cue
  #SCS_COL_ITEM_QR  ; Run External Program cue
  #SCS_COL_ITEM_QQ  ; 'Call Cue' cue
  #SCS_COL_ITEM_QJ  ; Enable/Disable cue
  #SCS_COL_ITEM_QE  ; Memo cue
  #SCS_COL_ITEM_QN  ; Note cue ; INFO: See also #SCS_COL_ITEM_Q_LAST below
  #SCS_COL_ITEM_EN  ; End
  #SCS_COL_ITEM_DP  ; Display Panel (Inactive)
  #SCS_COL_ITEM_DA  ; Display Panel (Active)
  #SCS_COL_ITEM_HK  ; Hotkeys
  #SCS_COL_ITEM_CC  ; Callable Cues
  #SCS_COL_ITEM_RU  ; Running...
  #SCS_COL_ITEM_CT  ; Counting Down
  #SCS_COL_ITEM_CM  ; Completed
  #SCS_COL_ITEM_NX  ; Next Cue
  #SCS_COL_ITEM_PR  ; Production Properties in editor
  #SCS_COL_ITEM_CP  ; Cue Properties in editor
  #SCS_COL_ITEM_MW  ; Main Window
EndEnumeration
#SCS_COL_ITEM_LAST = #PB_Compiler_EnumerationValue - 1
#SCS_COL_ITEM_Q_FIRST = #SCS_COL_ITEM_QF
#SCS_COL_ITEM_Q_LAST = #SCS_COL_ITEM_QN

Enumeration ; order must be order in which actions are to be shown in WCS\cboColNXAction
  #SCS_COL_NX_USE_NX_COLORS
  #SCS_COL_NX_USE_CUE_COLORS
  #SCS_COL_NX_SWAP_CUE_COLORS
  #SCS_COL_NX_LIGHTEN_OTHERS
  #SCS_COL_NX_DARKEN_OTHERS
EndEnumeration
#SCS_COL_NX_LAST = #PB_Compiler_EnumerationValue - 1

Enumeration
  #SCS_COL_AUDGR_LEFT
  #SCS_COL_AUDGR_RIGHT
  #SCS_COL_AUDGR_CURSOR
EndEnumeration

;- Display options
#SCS_CUELIST_FONT_SIZES = "6,8,10,12,14,16,18,20,22,24,26,28,36,48,72"
#SCS_CUEPANEL_HEIGHT = "120,110,100,95,90,85,80,75,70,65,60,55,50"

;- Touch Panel position
Enumeration
  #SCS_TOUCH_PANEL_POS_NONE
  #SCS_TOUCH_PANEL_POS_BOTTOM
  #SCS_TOUCH_PANEL_POS_TOP
EndEnumeration

;- ToolBar id's
Enumeration 1
  #SCS_TBM_MAIN         ; main ToolBar
  #SCS_TBE_EDITOR       ; editor ToolBar
  #SCS_TBZ_DUMMY_LAST   ; dummy last
EndEnumeration

;- ToolBar category id's
Enumeration 1
  ; main ToolBar categories
  #SCS_TBMC_CUE_CONTROL
  #SCS_TBMC_FILE
  #SCS_TBMC_EDITING
  #SCS_TBMC_VIEW
  #SCS_TBMC_HELP
  #SCS_TBMC_MTRS
  
  ; editor ToolBar categories
  #SCS_TBEC_FILE
  #SCS_TBEC_EDIT
  #SCS_TBEC_FAV
  #SCS_TBEC_HELP
  
  ; dummy last
  #SCS_TBZC_DUMMY_LAST
EndEnumeration

;- ToolBar button id's
Enumeration 1
  ; main ToolBar buttons
  #SCS_TBMB_GO
  #SCS_TBMB_PAUSE_RESUME
  #SCS_TBMB_STOP_ALL
  #SCS_TBMB_FADE_ALL ; added 21Mar2020 11.8.2.3ad
  #SCS_TBMB_NAVIGATE
  #SCS_TBMB_HB_PARENT
  #SCS_TBMB_STANDBY_GO
  #SCS_TBMB_LOAD
  #SCS_TBMB_TEMPLATES
  #SCS_TBMB_SAVE
  #SCS_TBMB_PRINT
  #SCS_TBMB_TIME
  #SCS_TBMB_OPTIONS
  #SCS_TBMB_EDITOR
  #SCS_TBMB_VST
  #SCS_TBMB_DEVMAP
  #SCS_TBMB_SAVE_SETTINGS
  #SCS_TBMB_VIEW
  #SCS_TBMB_HELP
  
  ; editor ToolBar buttons
  #SCS_TBEB_OTHER_ACTIONS
  #SCS_TBEB_SAVE
  #SCS_TBEB_UNDO
  #SCS_TBEB_REDO
  #SCS_TBEB_PROD
  #SCS_TBEB_CUES
  #SCS_TBEB_SUBS
  
  ; candidates for favorites group
  ; must be in same order as sBtnList.s in WED_loadFavArray() and WED_unloadFavArray(), and as menu items #WED_mnuFavStart to #WED_mnuFavEnd
  #SCS_TBEB_FAV_START   ; dummy entry - not a button
  ; cue-related
  #SCS_TBEB_ADD_QA
  #SCS_TBEB_ADD_QF
  #SCS_TBEB_ADD_QG
  #SCS_TBEB_ADD_QI
  #SCS_TBEB_ADD_QK
  #SCS_TBEB_ADD_QL
  #SCS_TBEB_ADD_QM
  #SCS_TBEB_ADD_QN
  #SCS_TBEB_ADD_QE
  #SCS_TBEB_ADD_QP
  #SCS_TBEB_ADD_QR
  #SCS_TBEB_ADD_QS
  #SCS_TBEB_ADD_QT
  #SCS_TBEB_ADD_QQ
;   #SCS_TBEB_ADD_QJ  ; nb QJ omitted because (a) the title ('add enable/disable cue') is too long a wraps to 3 lines, and (b) this cue type is not considered necessary for 'favorites'
  #SCS_TBEB_ADD_QU
  ; sub-cue-related
  #SCS_TBEB_ADD_SA
  #SCS_TBEB_ADD_SF
  #SCS_TBEB_ADD_SG
  #SCS_TBEB_ADD_SI
  #SCS_TBEB_ADD_SK
  #SCS_TBEB_ADD_SL
  #SCS_TBEB_ADD_SM
  #SCS_TBEB_ADD_SE
  #SCS_TBEB_ADD_SP
  #SCS_TBEB_ADD_SR
  #SCS_TBEB_ADD_SS
  #SCS_TBEB_ADD_ST
  #SCS_TBEB_ADD_SQ
;   #SCS_TBEB_ADD_SJ  ; nb SJ omitted because (a) the title ('add enable/disable sub-cue') is too long and wraps to 3 lines, and (b) this sub-cue type is not considered necessary for 'favorites'
  #SCS_TBEB_ADD_SU
  ; end of candidates for favorites group
  #SCS_TBEB_FAV_END   ; dummy entry - not a button
  #SCS_TBEB_FAV_NONE  ; blank dummy button used as a place holder if no favorites have been selected
  
  #SCS_TBEB_HELP
  
  ; dummy last
  #SCS_TBZB_DUMMY_LAST
EndEnumeration

;- ToolBar other constants
#SCS_TBN_CAT_CAPTION_HEIGHT = 15 ; 15 is the 'standard' height for text labels in SCS

;- ToolBar Display options
Enumeration
  #SCS_TOOL_DISPLAY_NONE
  #SCS_TOOL_DISPLAY_MIN
  #SCS_TOOL_DISPLAY_ALL
EndEnumeration

;- GoConfirm methods
Enumeration
  #SCS_GOCONFIRM_MIDI
  #SCS_GOCONFIRM_KEYBOARD
EndEnumeration

;- enable/disable action
Enumeration
  #SCS_ENADIS_ENABLE
  #SCS_ENADIS_DISABLE
EndEnumeration

;- standard button identifiers and constants
#SCS_TRANSPORT_BTN = $4000    ; enables standard buttons to be checked in the range of transport buttons - see Enumeration below
#SCS_TRANSPORT_SWITCH_CUE = 100
#SCS_TRANSPORT_SWITCH_SUB = 200
#SCS_TRANSPORT_SWITCH_FILE = 300
Enumeration 1
  ; editor and device map side bar buttons
  #SCS_STANDARD_BTN_EXPAND_ALL
  #SCS_STANDARD_BTN_COLLAPSE_ALL
  #SCS_STANDARD_BTN_MOVE_UP
  #SCS_STANDARD_BTN_MOVE_DOWN
  #SCS_STANDARD_BTN_MOVE_LEFT
  #SCS_STANDARD_BTN_MOVE_RIGHT
  #SCS_STANDARD_BTN_MOVE_RIGHT_UP
  #SCS_STANDARD_BTN_CUT
  #SCS_STANDARD_BTN_COPY
  #SCS_STANDARD_BTN_PASTE
  #SCS_STANDARD_BTN_DELETE
  #SCS_STANDARD_BTN_PLUS
  #SCS_STANDARD_BTN_MINUS
  #SCS_STANDARD_BTN_FIND
  #SCS_STANDARD_BTN_COPY_PROPS
  ; miscellaneous buttons
  #SCS_STANDARD_BTN_TICK
  #SCS_STANDARD_BTN_CROSS
  ; transport control buttons
  #SCS_STANDARD_BTN_REWIND = #SCS_TRANSPORT_BTN + 1
  #SCS_STANDARD_BTN_PLAY
  #SCS_STANDARD_BTN_PAUSE
  #SCS_STANDARD_BTN_RELEASE
  #SCS_STANDARD_BTN_FADEOUT
  #SCS_STANDARD_BTN_STOP
  #SCS_STANDARD_BTN_SHUFFLE
  #SCS_STANDARD_BTN_FIRST
  #SCS_STANDARD_BTN_LAST
  #SCS_STANDARD_BTN_PREV
  #SCS_STANDARD_BTN_NEXT
EndEnumeration

;- editor sidebar button indexes
Enumeration 0
  #SCS_SIDEBAR_BTN_EXPAND_ALL
  #SCS_SIDEBAR_BTN_COLLAPSE_ALL
  #SCS_SIDEBAR_BTN_MOVE_UP
  #SCS_SIDEBAR_BTN_MOVE_DOWN
  #SCS_SIDEBAR_BTN_MOVE_RIGHT_UP
  #SCS_SIDEBAR_BTN_MOVE_LEFT
  #SCS_SIDEBAR_BTN_CUT
  #SCS_SIDEBAR_BTN_COPY
  #SCS_SIDEBAR_BTN_PASTE
  #SCS_SIDEBAR_BTN_DELETE
  #SCS_SIDEBAR_BTN_FIND
  #SCS_SIDEBAR_BTN_COPY_PROPS
EndEnumeration

;- editor prod devices sidebar button indexes
Enumeration 0
  #SCS_DEV_SIDEBAR_BTN_MOVE_UP
  #SCS_DEV_SIDEBAR_BTN_MOVE_DOWN
  #SCS_DEV_SIDEBAR_BTN_INS_ROW
  #SCS_DEV_SIDEBAR_BTN_DEL_ROW
EndEnumeration

;- undo constants
; types to be bit-unique so multiple types can be or'd together
#SCS_UNDO_TYPE_PROD = 2
#SCS_UNDO_TYPE_CUE = 4
#SCS_UNDO_TYPE_SUB = 8
#SCS_UNDO_TYPE_AUD = 16
#SCS_UNDO_TYPE_EDITDEVS = 32

Enumeration 201
  #SCS_UNDO_ACTION_CHANGE
  #SCS_UNDO_ACTION_ADD
  #SCS_UNDO_ACTION_DELETE
  #SCS_UNDO_ACTION_MOVE_CUE
  #SCS_UNDO_ACTION_MOVE_SUB
  #SCS_UNDO_ACTION_RENUMBER_CUES
  #SCS_UNDO_ACTION_MULTI_CUE_COPY_ETC
  #SCS_UNDO_ACTION_MAKE_SCS_CUE_FROM_SUBS
  #SCS_UNDO_ACTION_ADD_CUE
  #SCS_UNDO_ACTION_ADD_SUB
  #SCS_UNDO_ACTION_ADD_AUD
  #SCS_UNDO_ACTION_DRAG
  #SCS_UNDO_ACTION_DRAG_CUE
  #SCS_UNDO_ACTION_MOVE_DEVICE
  #SCS_UNDO_ACTION_ADD_DEVICE
  #SCS_UNDO_ACTION_DEL_DEVICE
  #SCS_UNDO_ACTION_BULK_EDIT
  #SCS_UNDO_ACTION_IMPORT_FILES
EndEnumeration

; binary enumeration so multiple flags can be or'd together
EnumerationBinary ; nb first item for EnumerationBinary is 1
  #SCS_UNDO_FLAG_PROD_LOGICAL_DEVS
  #SCS_UNDO_FLAG_REDO_PHYSICAL_DEVS
  #SCS_UNDO_FLAG_SET_CUE_PTRS
  #SCS_UNDO_FLAG_REDO_TREE
  #SCS_UNDO_FLAG_SET_PROD_NODE_TEXT
  #SCS_UNDO_FLAG_SET_CUE_NODE_TEXT
  #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT
  #SCS_UNDO_FLAG_OPEN_FILE
  #SCS_UNDO_FLAG_REDO_GRAPH
  #SCS_UNDO_FLAG_DISPLAYSUB
  #SCS_UNDO_FLAG_GENERATE_PLAYORDER
  #SCS_UNDO_FLAG_CHANGE_LOGICAL_DEV_NAME
  #SCS_UNDO_FLAG_SET_MASTER_VOL
  #SCS_UNDO_FLAG_SET_DMX_MASTER_FADER
  #SCS_UNDO_FLAG_REDO_MAIN
  #SCS_UNDO_FLAG_REDO_CUE
  #SCS_UNDO_FLAG_REPOS_VIDEO
  #SCS_UNDO_FLAG_SET_MAX_LEVEL
  #SCS_UNDO_FLAG_SET_LOW_LEVEL
EndEnumeration

;- SaveOrSet
Enumeration
  #SCS_SAVEORSET_SAVE
  #SCS_SAVEORSET_SET
EndEnumeration

;- transition types
Enumeration
  #SCS_TRANS_NONE
  #SCS_TRANS_XFADE
  #SCS_TRANS_MIX
  #SCS_TRANS_WAIT
EndEnumeration

;- tracks
#SCS_TRACKS_DFLT = "Dflt"
#SCS_TRACKS_ALL = "All"

;- treeview node types
Enumeration 1
  #SCS_NODE_TYPE_PROD
  #SCS_NODE_TYPE_MULTI
  #SCS_NODE_TYPE_CUE
  #SCS_NODE_TYPE_SUB
EndEnumeration

;- file previewer constants
#SCS_TB_LEVEL_MIN = 0
#SCS_TB_LEVEL_MAX = 1000
#SCS_TB_PROGRESS_MIN = 0
#SCS_TB_PROGRESS_MAX = 1000

;- bulk edit constants
Enumeration 1
  #SCS_BE_CUES
  #SCS_BE_SUBS
  #SCS_BE_AUDS
EndEnumeration

Enumeration 1
  #SCS_BE_AUDIO_LEVELS
  #SCS_BE_CUE_ENABLED
  #SCS_BE_EXCL_CUE
  #SCS_BE_PAGE_NO
  #SCS_BE_HIDE_CUE_OPT
  #SCS_BE_REL_START_TIME
  #SCS_BE_FADE_IN_TIME
  #SCS_BE_FADE_IN_TYPE
  #SCS_BE_FADE_OUT_TIME
  #SCS_BE_FADE_OUT_TYPE
  #SCS_BE_LVL_CHG_TYPE
  #SCS_BE_SFR_TIME_OVERRIDE
  #SCS_BE_SFR_COMPLETE_ASSOC
  #SCS_BE_SFR_HOLD_ASSOC
  #SCS_BE_SFR_GO_NEXT
  #SCS_BE_QA_REPEAT
  #SCS_BE_QA_PAUSE_AT_END
  #SCS_BE_QA_DISPLAY_TIME
  #SCS_BE_WARN_B4_END   ; #SCS_BE_WARN_B4_END must be last as it is optional (not included if grProd\nVisualWarningTime = -2)
EndEnumeration

;- bulk edit change types (only used for #SCS_BE_AUDIO_LEVELS)
Enumeration
  #SCS_BECT_NORMALIZE
  #SCS_BECT_CHANGE_IN_LEVEL
  #SCS_BECT_NEW_LEVEL
EndEnumeration

;- audio normalization types
CompilerIf #c_include_peak
EnumerationBinary
  #SCS_NORMALIZE_LUFS
  #SCS_NORMALIZE_PEAK
  #SCS_NORMALIZE_TRUE_PEAK
EndEnumeration
CompilerElse
EnumerationBinary
  #SCS_NORMALIZE_LUFS
  #SCS_NORMALIZE_TRUE_PEAK
EndEnumeration
CompilerEndIf

;- multi cue move, etc
Enumeration
  #SCS_WMC_ACTION_COPY
  #SCS_WMC_ACTION_MOVE
  #SCS_WMC_ACTION_DELETE
  #SCS_WMC_ACTION_SORT
  #SCS_WMC_ACTION_SORT_ASC
  #SCS_WMC_ACTION_SORT_DEC
  #SCS_WMC_ACTION_SEARCH
EndEnumeration

;- search columns in cue move copy
Enumeration
  #SCS_WMC_ACTION_COLUMN_CUE_NUMBER
  #SCS_WMC_ACTION_COLUMN_PAGE
  #SCS_WMC_ACTION_COLUMN_CUE_TYPE
  #SCS_WMC_ACTION_COLUMN_DESCRIPTION
EndEnumeration

Enumeration
  #SCS_WMC_GRDACTION_NO_CHANGE
  #SCS_WMC_GRDACTION_ADDED
  #SCS_WMC_GRDACTION_MOVED
  #SCS_WMC_GRDACTION_DELETED
  #SCS_WMC_GRDACTION_SORTED_ASC
  #SCS_WMC_GRDACTION_SORTED_DEC
EndEnumeration

;- display gradient directions
; clockwise, starting from right (3 o'clock)
Enumeration
  #SCS_GRADIENT_RIGHT
  #SCS_GRADIENT_DOWN_RIGHT
  #SCS_GRADIENT_DOWN
  #SCS_GRADIENT_DOWN_LEFT
  #SCS_GRADIENT_LEFT
  #SCS_GRADIENT_UP_LEFT
  #SCS_GRADIENT_UP
  #SCS_GRADIENT_UP_RIGHT
EndEnumeration

;- device status (in devmap)
Enumeration
  #SCS_DEVSTATE_NA
  #SCS_DEVSTATE_ACTIVE
  #SCS_DEVSTATE_INACTIVE
EndEnumeration

;- channel selection
Enumeration
  #SCS_CHAN_MAIN
  #SCS_CHAN_ALT
EndEnumeration

;- SFR Cue Types
Enumeration
  #SCS_SFR_CUE_NA
  ; see also #SCS_SFR_CUE_ALL_FIRST and #SCS_SFR_CUE_ALL_LAST (below this enumeration)
  #SCS_SFR_CUE_ALL_ANY
  #SCS_SFR_CUE_ALL_AUDIO
  #SCS_SFR_CUE_ALL_VIDEO_IMAGE
  #SCS_SFR_CUE_ALL_LIVE
  ; see also #SCS_SFR_CUE_PLAY_FIRST and #SCS_SFR_CUE_PLAY_LAST (below this enumeration)
  #SCS_SFR_CUE_PLAY_ANY
  #SCS_SFR_CUE_PLAY_AUDIO
  #SCS_SFR_CUE_PLAY_VIDEO_IMAGE
  #SCS_SFR_CUE_PLAY_LIVE
  ;
  #SCS_SFR_CUE_ALLEXCEPT
  #SCS_SFR_CUE_PLAYEXCEPT
  #SCS_SFR_CUE_PREV
  #SCS_SFR_CUE_SEL
EndEnumeration
#SCS_SFR_CUE_LAST = #PB_Compiler_EnumerationValue - 1
#SCS_SFR_CUE_ALL_FIRST = #SCS_SFR_CUE_ALL_ANY
#SCS_SFR_CUE_ALL_LAST = #SCS_SFR_CUE_ALL_LIVE
#SCS_SFR_CUE_PLAY_FIRST = #SCS_SFR_CUE_PLAY_ANY
#SCS_SFR_CUE_PLAY_LAST = #SCS_SFR_CUE_PLAY_LIVE

;- SFR Actions
Enumeration
  #SCS_SFR_ACT_NA
  #SCS_SFR_ACT_STOP
  #SCS_SFR_ACT_FADEOUT
  #SCS_SFR_ACT_RELEASE
  #SCS_SFR_ACT_CANCELREPEAT
  #SCS_SFR_ACT_TRACK
  #SCS_SFR_ACT_PAUSE
  #SCS_SFR_ACT_RESUME
  #SCS_SFR_ACT_PAUSEHIB
  #SCS_SFR_ACT_FADEOUTHIB
  #SCS_SFR_ACT_RESUMEHIB
  #SCS_SFR_ACT_RESUMEHIBNEXT
  #SCS_SFR_ACT_STOPALL
  #SCS_SFR_ACT_FADEALL
  #SCS_SFR_ACT_PAUSEALL ; nb equivalent of Pause/Resume All
  #SCS_SFR_ACT_STOPMTC
  #SCS_SFR_ACT_STOPCHASE
EndEnumeration
#SCS_SFR_ACT_LAST = #PB_Compiler_EnumerationValue - 1

;- LC Absolute/Relative Level Change
; NB superceded by LC Action, 20Aug2021 11.8.6
Enumeration
  #SCS_LC_ABSOLUTE
  #SCS_LC_RELATIVE
EndEnumeration

;- LC Action, eg Absolute/Relative Level Change
; Added 20Aug2021 11.8.6 - supercedes LC Absolute/Relative Level Change
Enumeration 1
  #SCS_LC_ACTION_ABSOLUTE
  #SCS_LC_ACTION_RELATIVE
  #SCS_LC_ACTION_FREQ
  #SCS_LC_ACTION_TEMPO
  #SCS_LC_ACTION_PITCH
EndEnumeration

;- Audio File tempo etc action
Enumeration
  #SCS_AF_ACTION_NONE
  #SCS_AF_ACTION_FREQ
  #SCS_AF_ACTION_TEMPO
  #SCS_AF_ACTION_PITCH
EndEnumeration

;- tempo etc change codes
Enumeration
  #SCS_CHANGE_NONE
  #SCS_CHANGE_FREQ
  #SCS_CHANGE_TEMPO
  #SCS_CHANGE_PITCH
EndEnumeration

;- LC Cue Types
Enumeration
  #SCS_LC_CUE_NA          ; not applicable (not set)
  #SCS_LC_CUE_PLAY_AUDIO  ; any playing audio cue
  #SCS_LC_CUE_SEL         ; selected cue
EndEnumeration

;- set position Absolute/Relative times
Enumeration
  #SCS_SETPOS_ABSOLUTE
  #SCS_SETPOS_RELATIVE
  #SCS_SETPOS_CUE_MARKER
  #SCS_SETPOS_BEFORE_END ; Added 7Jun2022 11.9.2
EndEnumeration

;- set position cue types
Enumeration ; Added 7Jun2022 11.9.2
  #SCS_SETPOS_CUETYPE_NA
  #SCS_SETPOS_CUETYPE_PLAY_AUDIO
  #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE
EndEnumeration

;- playback assignments
Enumeration
  #SCS_PLB_UNASSIGNED
  #SCS_PLB_PREVIEW
  #SCS_PLB_NORMAL
EndEnumeration

;- PB 'extras'
; undocumented(?) PB Shortcuts
#SCS_Shortcut_SemiColon     = 186
#SCS_Shortcut_Equals        = 187
#SCS_Shortcut_Comma         = 188
#SCS_Shortcut_Minus         = 189
#SCS_Shortcut_Period        = 190
#SCS_Shortcut_Slash         = 191
#SCS_Shortcut_Grave         = 192
#SCS_Shortcut_LeftBracket   = 219
#SCS_Shortcut_Backslash     = 220
#SCS_Shortcut_RightBracket  = 221
#SCS_Shortcut_Apostrophe    = 222

#WM_SYSTIMER = $118

;- DMX handling constants
;- ENTTEC constants
; misc constants
; #DEFAULT_LATENCY = 1 ; FTDI latency timer in milliseconds
#ENTTEC_DEFAULT_LATENCY = 5 ; FTDI latency timer in milliseconds ; changed from 1ms at 11.3.8
#ENTTEC_RX_TIMEOUT = 40 ; FTDI receive timeout in milliseconds

; Widget message types
; ====================

; configuration packets
#ENTTEC_GET_WIDGET_CFG = 3 ; request the widgets config data
#ENTTEC_GET_WIDGET_CFG_REPLY = 3 ; returned config
#ENTTEC_SET_WIDGET_CFG = 4 ; send new config

; packet alignment
#ENTTEC_SOM = $7E ; Start Of Message Marker
#ENTTEC_EOM = $E7 ; End Of Message Marker

; User data area
#ENTTEC_USER_DATA_SIZE = 508 ; in bytes

; firmware flashing
#FLASH_FIRMWARE = 1   ; enter flash mode
#FLASH_PAGE_WRITE = 2 ; flash a page
#FLASH_PAGE_REPLY = 2 ; flash page success status
#FLASH_PAGE_SUCCESS = "TRUE" ; received if last flash page write was OK
#FLASH_PAGE_FAIL = "FALS" ; received if last flash page write failed
#FLASH_PAGES = 96
#FLASH_PAGE_SIZE = 64

;- MTC/LTC constants
Enumeration
  #SCS_TIMECODE_MTC  
  #SCS_TIMECODE_LTC  
EndEnumeration

Enumeration
  #SCS_MTC_FR_NOT_SET
  #SCS_MTC_FR_24
  #SCS_MTC_FR_25
  #SCS_MTC_FR_29_97
  #SCS_MTC_FR_30
EndEnumeration
#SCS_MTC_LAST = #PB_Compiler_EnumerationValue - 1

; MTC Thread Requests
#SCS_MTC_THR_OPEN_MIDI = 1
#SCS_MTC_THR_READY_MTC = 2
#SCS_MTC_THR_PAUSE_MTC = 4
#SCS_MTC_THR_RESUME_MTC = 8     ; resume without pre-roll wait
#SCS_MTC_THR_RESTART_MTC = 16   ; resume with pre-roll wait
#SCS_MTC_THR_STOP_MTC = 32
#SCS_MTC_THR_CLOSE_MIDI = 64

Enumeration
  #SCS_MTC_STATE_IDLE
  #SCS_MTC_STATE_PRE_ROLL ; full-frame sent but sending quarter-frames not yet started
  #SCS_MTC_STATE_RUNNING  ; sending quarter-frames
  #SCS_MTC_STATE_PAUSED   ; quarter-frames paused by SCS cue or operator
  #SCS_MTC_STATE_STOPPED  ; quarter-frames stopped by SCS cue or operator
EndEnumeration

Enumeration
  #SCS_MTC_DISP_VU_METERS
  #SCS_MTC_DISP_SEPARATE_WINDOW
EndEnumeration

Enumeration 1
  ; start enumeration at 1 so that 0 means 'not set'
  ; note: LTC was added much later than MTC, so all code primarily refers to MTC
  #SCS_MTC_TYPE_MTC   ; MIDI Time Code
  #SCS_MTC_TYPE_LTC   ; Linear Time Code
EndEnumeration

;- button state colors
#SCS_BS_ENABLED_BACKCOLOR = $E8E8E8   ; = RGB(232,232,232)
#SCS_BS_ENABLED_TEXTCOLOR = $000000   ; = RGB(0,0,0)
#SCS_BS_DISABLED_BACKCOLOR = $ECECEC  ; = RGB(236,236,236)
#SCS_BS_DISABLED_TEXTCOLOR = $B9AAAA  ; = RGB(185,170,170)

;- focus point
Enumeration
  #SCS_FOCUS_NEXT_MANUAL
  #SCS_FOCUS_LAST_PLAYING
EndEnumeration

;- custom events
;- SCS events
Enumeration #PB_Event_FirstCustomValue + 100 ; nb ModuleEx::#Event... constants start from #PB_Event_FirstCustomValue
  #SCS_Event_DummyFirst  ; dummy first and dummy last to encapsulate the SCS events
  #SCS_Event_CollectThreadEnd
  #SCS_Event_GoButton
  #SCS_Event_GoConfirm
  #SCS_Event_GoTo_End_Cue
  #SCS_Event_GoTo_Next_Cue
  #SCS_Event_GoTo_Prev_Cue
  #SCS_Event_GoTo_Top_Cue
  #SCS_Event_PlayCue
  #SCS_Event_PlayMidiCue
  #SCS_Event_PlaySub
  #SCS_Event_SetFaderAssignments
  #SCS_Event_SetStandbyToolbarBtn
  #SCS_Event_StartOrRestartTimeCodeForSub
  #SCS_Event_StopAndEndSub
  #SCS_Event_StopEverything
  #SCS_Event_WakeUp   ; dummy event just to wake up the main thread's WaitWindowEvent()
  #SCS_Event_Deadlock
  #SCS_Event_LockTimeOut
  #SCS_Event_DrawMTC
  #SCS_Event_DrawLTC
  #SCS_Event_Header_CheckBox_Click
  #SCS_Event_TVG_RunPlayer
  #SCS_Event_Send_xremote_to_X32
  #SCS_Event_VSTGetData
  #SCS_Event_M2T_Apply
  #SCS_Event_M2T_Cancel
  #SCS_Event_DummyLast
  ; the following appended from MyGrid_PB520.pbi
  #MyGrid_Event_DummyFirst  ; dummy first and dummy last to encapsulate the #MyGrid events
  #MyGrid_Event_Change      ; fired when cell content has changed from outside / #MyGrid_Att_ChangedRow and #MyGrid_Att_ChangedCol can be used to see what cell has changed
  #MyGrid_Event_Click       ; fired when a button-cell received a full click   / #MyGrid_Att_ClickedRow and #MyGrid_Att_ClickedCol can be used to see what cell has been clicked
  #MyGrid_Event_Focus
  #MyGrid_Event_LostFocus
  #MyGrid_Event_KeyDown
  #MyGrid_Event_DummyLast
EndEnumeration

;- controller types
Enumeration 1
  #SCS_CTRLTYPE_LIVE_INPUT
  #SCS_CTRLTYPE_OUTPUT
  #SCS_CTRLTYPE_MASTER
  #SCS_CTRLTYPE_DMX_MASTER
  #SCS_CTRLTYPE_EQ_SELECT
  #SCS_CTRLTYPE_EQ_KNOB
  #SCS_CTRLTYPE_EQ_BTN
  #SCS_CTRLTYPE_MUTE
  #SCS_CTRLTYPE_SOLO ; Added 24Jun2022 11.9.4
  #SCS_CTRLTYPE_DIMMER_CHANNEL ; Added 11Jul2022 11.9.4
  #SCS_CTRLTYPE_PLAYING ; Added 28Aug2023 11.10.0by
EndEnumeration

;- controller sub-types
Enumeration 1
  #SCS_CTRLSUBTYPE_FADER
  #SCS_CTRLSUBTYPE_EQ_CHAN_SELECT
EndEnumeration

;- controllers
Enumeration
  #SCS_CTRL_NONE ; 20Jun2022 11.9.4
  #SCS_CTRL_MIDI_CUE_CONTROL
  #SCS_CTRL_BCF2000 ; Behringer BCF2000
  #SCS_CTRL_BCR2000 ; Behringer BCR2000
  #SCS_CTRL_NK2     ; Korg nanoKontrol2 ; 13Jun2022 11.9.4
EndEnumeration

;- controller item types (used for custom controller only)
Enumeration 1
  #SCS_CTRLITEMTYPE_OUTPUT_GAIN_FADER
  #SCS_CTRLITEMTYPE_MUTE
  #SCS_CTRLITEMTYPE_SOLO
  #SCS_CTRLITEMTYPE_MASTER_FADER
  #SCS_CTRLITEMTYPE_DMX_MASTER_FADER
EndEnumeration

;- controller configurations
Enumeration 1
  #SCS_CTRLCONF_BCF2000_PRESET_A
  #SCS_CTRLCONF_BCF2000_PRESET_C
  #SCS_CTRLCONF_BCR2000_PRESET_A
  #SCS_CTRLCONF_BCR2000_PRESET_B
  #SCS_CTRLCONF_BCR2000_PRESET_C
  #SCS_CTRLCONF_NK2_PRESET_A
  #SCS_CTRLCONF_NK2_PRESET_B
  #SCS_CTRLCONF_NK2_PRESET_C
EndEnumeration

;- fader assignments
Enumeration
  #SCS_FADER_OUTPUTS_1_7_M  ; default because many scenarios will not have live inputs
  #SCS_FADER_INPUTS_1_8
  #SCS_FADER_PLAYING_1_7_M
EndEnumeration

;- EQ groups
Enumeration 1
  #SCS_EQGRP_LOW_CUT
  #SCS_EQGRP_BAND_1
  #SCS_EQGRP_BAND_2
EndEnumeration

;- EQ types
Enumeration 1
  #SCS_EQTYPE_LOWCUT_FREQ
  #SCS_EQTYPE_GAIN
  #SCS_EQTYPE_FREQ
  #SCS_EQTYPE_Q
EndEnumeration

;- controller buttons
Enumeration
  #SCS_CTRLBTN_PREV
  #SCS_CTRLBTN_NEXT
  #SCS_CTRLBTN_STOP
  #SCS_CTRLBTN_GO
  #SCS_CTRLBTN_INPUTS
  #SCS_CTRLBTN_OUTPUTS
EndEnumeration
#SCS_CTRLBTN_LAST = #PB_Compiler_EnumerationValue - 1

;- capture for test controller - actions
Enumeration 1
  #SCS_CAP_START
  #SCS_CAP_GO_BUTTON
  #SCS_CAP_LOG
  #SCS_CAP_CLOSE
EndEnumeration

;- controller logging constants for MIDI Test Window (#WMT) and for processMidiControllerMsg()
Enumeration 1
  #SCS_CTRLLOG_GO
  #SCS_CTRLLOG_STOP
  #SCS_CTRLLOG_PREV
  #SCS_CTRLLOG_NEXT
  #SCS_CTRLLOG_FADER
  #SCS_CTRLLOG_LIVE_INPUT
  #SCS_CTRLLOG_OUTPUT
  #SCS_CTRLLOG_MASTER
  #SCS_CTRLLOG_DMX
  #SCS_CTRLLOG_DIMMER ; Added 18Jul2022 11.9.4
  #SCS_CTRLLOG_MUTE
  #SCS_CTRLLOG_SOLO ; Added 24Jun2022 11.9.4
  #SCS_CTRLLOG_EQ
  #SCS_CTRLLOG_PLAYING ; Added 28Aug2023 11.10.0by
EndEnumeration

; INFO DMX Enttec Pro and Pro Mk2 constants

;******************** PRO MK2 LABELS: ASSIGN As PER YOUR API (request the pdf If you don't have one) *********************/
; THE API Key is LSB First: so If it says 11223344 .. Define it As ... 44,33,22,11

; unsigned char APIKey[]					= {0x00, 0x00,0x00, 0x00};
#ENTTEC_SEND_MIDI_PORT = 0
#ENTTEC_RECEIVE_MIDI_PORT = 0

;***********************************************************************************/

; ----------------------------------------------------------
;- ENTTEC definitions as defined in document PRO2_API_03.pdf (requires API key value for API2 to be $E403A4C9, as per message label 13 - Set API Key Request)
; Get Port Widget Parameters Request/Reply
#ENTTEC_GET_WIDGET_PARAMS_PORT1 = 3
#ENTTEC_GET_WIDGET_PARAMS_PORT2 = 196
; Set Port Widget Parameters Request
#ENTTEC_SET_WIDGET_PARAMS_PORT1 = 4
#ENTTEC_SET_WIDGET_PARAMS_PORT2 = 156
; Received DMX Packet
#ENTTEC_RECEIVED_DMX_PORT1 = 5
#ENTTEC_RECEIVED_DMX_PORT2 = 210
; Output Only Send DMX Packet Request
#ENTTEC_SEND_DMX_PORT1 = 6
#ENTTEC_SEND_DMX_PORT2 = 132
; Send RDM Packet Request
#ENTTEC_SEND_DMX_RDM_TX_PORT1 = 7
#ENTTEC_SEND_DMX_RDM_TX_PORT2 = 226
; Receive DMX ON Change
#ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT1 = 8
#ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT2 = 128
; Received DMX Change Of State Packet
#ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1 = 9
#ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2 = 212
; Get Widget Serial Number Request/Reply
#ENTTEC_GET_WIDGET_SN = 10
; Set API Key Request
#ENTTEC_SET_API_KEY = 13
; Query Hardware Version Request/Reply
#ENTTEC_HARDWARE_VERSION = 14
; Get Port Assignment Request/Reply
#ENTTEC_GET_PORT_ASSIGNMENT = 220
; Set Port Assignment Request
#ENTTEC_SET_PORT_ASSIGNMENT = 201
; Received MIDI
#ENTTEC_RECEIVED_MIDI = 225
; Send MIDI Request
#ENTTEC_SEND_MIDI = 191
; remaining request and reply codes not used in SCS
; ----------------------------------------------------------

; To integrate sACN and Art-net into the DMX recieve routine we need 2 fake reply codes that are different to the Enttec ones
#ENTTEC_ARTNET_RX = $100
#ENTTEC_SACN_RX = $101

#ENTTEC_DMX_START_CODE = $7E
#ENTTEC_DMX_END_CODE = $E7
#ENTTEC_OFFSET = $FF
#ENTTEC_DMX_HEADER_LENGTH = 4
#ENTTEC_BYTE_LENGTH = 8
#ENTTEC_HEADER_RDM_LABEL = 5
#ENTTEC_NO_RESPONSE = 0
#ENTTEC_DMX_PACKET_SIZE = 512

#ENTTEC_MAX_PROS = 20
#ENTTEC_SEND_NOW = 0
#ENTTEC_HEAD = 0
#ENTTEC_IO_ERROR = 9

;- DMX device types
Enumeration
  #SCS_DMX_DEV_NONE ; not a recognisable device
  #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB
  #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO
  #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
  #SCS_DMX_DEV_FTDI_USB_RS485
  #SCS_DMX_DEV_ARTNET
  #SCS_DMX_DEV_SACN
EndEnumeration

;- Lighting constants
#SCS_LT_DEF_CHASE_STEPS = 4

Enumeration 1
  #SCS_LT_ENTRY_TYPE_DMX_ITEMS
  #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
  #SCS_LT_ENTRY_TYPE_BLACKOUT
  ; #SCS_LT_ENTRY_TYPE_DMX_CAPTURE
  #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
  #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
EndEnumeration

Enumeration
  #SCS_LT_CAPTURE_BTN_SNAP
  #SCS_LT_CAPTURE_BTN_SEQ_START
  #SCS_LT_CAPTURE_BTN_SEQ_STOP
EndEnumeration

Enumeration
  #SCS_LT_DISP_ALL
  #SCS_LT_DISP_1ST
EndEnumeration

;- Fixture indicator values
Enumeration
  #SCS_FIXIND_NO_FIXTURE_CODES
  #SCS_FIXIND_FIXTURE_CODES_PRESENT
  #SCS_FIXIND_SAME_FIXTURE_CODES_AS_PREV_ITEM
EndEnumeration

;- Load Production choices
Enumeration
  #SCS_CHOICE_NEW
  #SCS_CHOICE_TEMPLATE
  #SCS_CHOICE_FAVORITE
  #SCS_CHOICE_EXISTING
EndEnumeration

;- Actions
Enumeration
  #SCS_ACTION_NONE
  #SCS_ACTION_CLOSE_SCS
  #SCS_ACTION_CANCEL
  #SCS_ACTION_OPEN_FILE
  #SCS_ACTION_CREATE
  #SCS_ACTION_CREATE_FROM_TEMPLATE
  #SCS_ACTION_CREATE_TEMPLATE_FROM_CUEFILE
  #SCS_ACTION_SAVE_AS_TEMPLATE
  #SCS_ACTION_EDIT_TEMPLATE
EndEnumeration

;- input requester types
Enumeration 1
  #SCS_IR_PROD_TITLE
  #SCS_IR_TEMPLATE_NAME
EndEnumeration

;- video thread request types
Enumeration 1
  #SCS_VTREQ_INIT_TVG
  #SCS_VTREQ_CREATE_PREVIEW_TVG_CONTROLS
  #SCS_VTREQ_CREATE_TVG_CONTROL
  #SCS_VTREQ_OPEN_FILE
EndEnumeration

;- Windows header control styles
#HDS_CHECKBOXES    = $0400
#HDF_CHECKBOX      = $00000040
#HDF_CHECKED       = $00000080
#HDF_FIXEDWIDTH    = $00000100
#HDF_SPLITBUTTON   = $01000000
#HDN_ITEMSTATEICONCLICK = #HDN_FIRST - 16

;- Windows listview item states
#LVIS_CHECKED = $2000
#LVIS_UNCHECKED = $1000

;- Drag Multi Level Point Movements
#SCS_DRAG_MULTI_ALLOWED           = 0
#SCS_DRAG_MULTI_UPPER_DISALLOWED  = 1
#SCS_DRAG_MULTI_LOWER_DISALLOWED  = 2
#SCS_DRAG_MULTI_DISALLOWED        = 3

;- VST Plugin Host
Enumeration
  #SCS_VST_HOST_ANY   ; used in WPL_hideWindowIfDisplayed() to indicate the window is to be hidden regardless of the current 'host' setting
  #SCS_VST_HOST_NONE  ; means hide the VST plugin editor window
  #SCS_VST_HOST_DEV   ; VST plugin editor window activated from 'devices' tab in fmVSTPlugins
  #SCS_VST_HOST_AUD   ; VST plugin editor window activated from fmEditQF
EndEnumeration

;- DLL Type (32/64-bit)
#SCS_DLL_32_BIT = 32

;- VST Plugin Error
Enumeration
  #SCS_VST_PLUGIN_ERROR_OK
  #SCS_VST_PLUGIN_ERROR_FILE_LOCATION
  #SCS_VST_PLUGIN_ERROR_PLUGIN_NOT_LOADED
  #SCS_VST_PLUGIN_ERROR_INCORRECT_PROCESSOR_VERSION
  #SCS_VST_PLUGIN_ERROR_ALREADY_EXISTS
  #SCS_VST_PLUGIN_ERROR_INSTRUMENT
EndEnumeration

;- Lost Focus Action
Enumeration
  #SCS_LOSTFOCUS_WARN
  #SCS_LOSTFOCUS_IGNORE
EndEnumeration

;- Video/Image position and size adjustments
EnumerationBinary
  #SCS_PS_XPOS
  #SCS_PS_YPOS
  #SCS_PS_SIZE
EndEnumeration
#SCS_PS_ALL = $FF

;- "Don't Ask Me Again Today" preference keys
#SCS_DontAskCloseSCSDate = "DontAskCloseSCSDate"

;- "Don't Tell Me Again Today" preference keys
#SCS_DontTellDMXChannelLimitDate = "DontTellDMXChannelLimitDate"

;- Visual Warning Time
; These special constants MUST BE NEGATIVE as other values will be positive, eg +5000 for 'count down last 5 seconds', and some code will check for >= 0
; WARNING! Do NOT change these constants as the values may be held in cue files (new constants may be added if required)
#SCS_VWT_NOT_SET = -2 ; standard SCS value for blank integer fields
#SCS_VWT_COUNT_DOWN_WHOLE_CUE = -3
#SCS_VWT_CUEPOS = -4
#SCS_VWT_FILEPOS = -5
#SCS_VWT_CUEPOS_PLUS_TIME_OFFSET = -6

;- Visual Warning Format
; WARNING! Do NOT change these constants as the values may be held in cue files (new constants may be added if required)
#SCS_VWF_SECS = 0
#SCS_VWF_TIME = 1
#SCS_VWF_HHMMSS = 2

;- CSRD Message Value Selection Types
Enumeration
  #SCS_SELTYPE_GRID               ; Multiple values may be selected from a grid (WQM\grdRemDevItem). This is the default selection type.
  #SCS_SELTYPE_CBO                ; Only one value may be chosen from a combobox (WQM\cboRemDevCboItem)
  #SCS_SELTYPE_FADER              ; Fader
  #SCS_SELTYPE_FADER_AND_GRID     ; Fader and grid
  #SCS_SELTYPE_CBO_FADER_AND_GRID ; Combobox, fader and grid (eg combobox for FX send, such as FX1-FX4, fader for FX send level, and grid for channel)
  #SCS_SELTYPE_CBO_AND_GRID       ; Combobox and grid
  #SCS_SELTYPE_NONE               ; No value may be chosen as the message type provides a fixed 'value' (eg MuteLR can only mute LR)
EndEnumeration

;- Editor constants
#SCS_EDITOR_MIN_SCROLLAREA_INNERHEIGHT = 350 ; originally hard-coded 448 into each fmEditQx file

;- Miscellaneous constants
#SCS_MISC_WQM_COMBO_PARAM_BASE = 10000
#SCS_MISC_DFLT_DAYS_BETWEEN_CHECKS = 14 ; days between auto check for updates

; Added 3May2022pm
;- Test Tone Types
Enumeration
  #SCS_TEST_TONE_SINE
  #SCS_TEST_TONE_PINK
EndEnumeration
; End added 3May2022pm

; Added 01Jul2022 11.9.4 (initially added for vertical alignment of text to be drawn by WCM_drawItem())
Enumeration
  #SCS_ALIGN_TOP
  #SCS_ALIGN_MIDDLE
  #SCS_ALIGN_BOTTOM
EndEnumeration
; End added 01Jul2022 11.9.4

; Added by Dee to show or hide gadgets, HideGadget(#Gadget, State)  where 0 = show , 1 = hide
; we can define #showgadget and #hide gadget to make more logical sense
#SCS_SHOW_GADGET = #False
#SCS_HIDE_GADGET = #True

; Artnet
#ARTNET_PORT = 6454
#ARTNET_BUFFER_SIZE = 1024
#ARTNET_DMX_OUT_SIZE = 530
;#ARTNET_IP_TO_BIND = "192.168.8.24"     ; this will need to be selected from the system, dropdown?
;#ARTNET_IP_DMX_SEND_BROADCAST = "192.168.8.255"   ; broadcast address 
#ARTNET_OPCODE_OFFSET = 8
#ARTNET_PROTOCOL_VERSION_OFFSET = 10
#ARTNET_SEQUENCE_NUMBER_OFFSET = 12
#ARTNET_PHYSICAL_OFFSET = 13
#ARTNET_UNIVERSE_OFFSET = 14
#ARTNET_LENGTH_OFFSET = 15
#ARTPOLL_TALK_TO_ME_OFFSET = 12
#ARTPOLL_DPALL_OFFSET = 13
#ARTNET_DATA_OFFSET = 18
#ARTNET_SHORT_NAME = "SCS"                                    ; max 17 char for a string + 0
#ARTNET_LONG_NAME = "ShowCueSystems It's a kind of magic."    ; max 63 char for a string + 0
#ARTNET_PROTOCOL_NAME = "Art-Net"
#ARTNET_POLL_REQUEST = $2000
#ARTNET_POLL_REPLY = $2100
#ARTNET_DATA_PACKET = $5000
#ARTNET_VERSION_INFO = 14
#ARTNET_POLLREPLY_SIZE = 256
#ARTNET_POLLREQUEST_SIZE = 256
#ARTNET_DMX_BUFFER_SIZE = 512
#ARTNET_MAX_RX_QUE_DEPTH = 4
#ARTNET_MAX_TX_QUE_DEPTH = 4
#ARTNET_POLL_TIMEOUT = 3000                                   ; poll timeout, stop tx if no polls
#ARTNET_MAX_UNIVERSES = 2                                     ; max universes, 4 recomended max
#DMX_RATE = 25                                                ; Controls the DMX transmission rate 25mS, 40 frame/sec
#ARTNET_POLL_REPLY_TIME = 2500

; DMX port conflict values
Enumeration
  #SCS_WEP_DMX_CONFLICT_NOMESSAGE
  #SCS_WEP_DMX_CONFLICT_STATUSBAR
  #SCS_WEP_DMX_CONFLICT_MESSAGEREQUESTER
EndEnumeration

#ARTNET_RX_ENABLE = #True

; sACN
#SACN_DMX_BUFFER_SIZE = 1024
#SACN_DMX_DATA_OFFSET = 0

Enumeration
#SACN_OK                      ; 0
#SACN_ERROR_SOCKET_CREATION   ; 1
#SACN_ERROR_SOCKET_OPTIONS    ; 2
#SACN_ERROR_SEND_PACKET       ; 3
#SACN_INCORRECT_UNIVERSE      ; 4
#SACN_MEMORY_ALLOCATION_FAIL  ; 5
#SACN_MAP_ELEMENT_IN_USE      ; 6
#SACN_ERROR_BIND_FAIL         ; 7
EndEnumeration

; sACN initialisation error messages for debug only
DataSection
  sACNErrorMessages:
  Data.s "sACN Initialised OK."
  Data.s "sACN Error socket creation."
  Data.s "sACN Error socket options."
  Data.s "sACN Error sending packet."
  Data.s "sACN Error incorrect universe."
  Data.s "sACN Error memory allocation fail."
  Data.s "sACN Error map element already in use."
  Data.s "sACN Error bind error."
EndDataSection

; cpu usage 
#CPU_GPU_METERING_DELAY = 60000 ; 1000

; SCS LTC

#SCS_LTC_DISPLAYUPDATE_TIMER = 30    ; 30 milliseconds
#LTC_FRAME_SIZE = 679
#SMPTE_FRAME_SIZE = 32
#LTC_AUDIO_BUFFER_SIZE = 4096
#LTC_FRAME_BIT_COUNT = 80
#LTC_USE_DATE = 1
#LTC_DECODER_SIZE = 1144
#LTC_ENCODER_SIZE = 95
#LTC_CONSTANT_APV = 1920
#WAV_HEADER_SIZE = 44
;#LTC_NETWORK_BUFFER_SIZE = 1024
#LTC_SAMPLE_RATE = 48000
#LTC_AUDIO_CHANS = 1

Enumeration         ; LTC_TV_STANDARD
  #LTC_TV_525_60    ; 30fps
  #LTC_TV_625_50    ; 25fps
  #LTC_TV_1125_60   ; 30fps  (probably 29.97 fps in practice)
  #LTC_TV_FILM_24   ; 24fps
EndEnumeration

DataSection
  SmpteDataS:
  Data.s "smpte30", "smpte25", "smpte30drop", "smpte24"
  
  SmpteDataN:
  Data.d 30, 25, 29.97, 24
EndDataSection

Enumeration
  #SCS_LTC_COMMAND_SET
  #SCS_LTC_COMMAND_STOP
  #SCS_LTC_COMMAND_PLAY
  #SCS_LTC_COMMAND_PAUSE
  #SCS_LTC_COMMAND_RESUME
  #SCS_LTC_COMMAND_READY
EndEnumeration

; Secret AES encryption key
#SECRET_AES_KEY = "eX4dkcN9Wgbw61PS"  ; At least 16 chars recommended


; EOF
