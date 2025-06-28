; File: Globals.pbi

EnableExplicit

; INFO: 'Def' variables (eg grProdDef.tyProd) are used for default values

; INFO: The names of all global variable should start with g, but this wasn't applied in the early versions of SCS, so the names of a few global variables
; INFO: do not start with g, particularly the frequently-used variables aCue(), aSub() and aAud()

Global sProcName.s

Global gbLogInfoForSam
Global gnLabelStatusCheck

Global grStopEverythingInfo.tyStopEverythingInfo

;- fonts
; default font comments:
; Arial - OK but slightly smaller than MS Sans Serif
; MS Sans Serif - OK but spidery (used in SCS 10)
; Verdana - nice but slightly too large - would need to adjust gadget widths
; Tahoma - OK - the default system font of XP/2000
; Global gsDefFontName.s = "Tahoma"
; Global gsDefFontName.s = "MS Sans Serif"
; Global gsDefFontName.s = "Segoe UI"
; SCS default font
Global gsSCSDfltFontName.s ; = "Tahoma"   ; now reset in initialisePart0()
Global gnSCSDfltFontSize ; = 8
; this session's default font, which = SCS default font unless changed by user preferences
Global gsDefFontName.s ; = "Tahoma"   ; now reset in initialisePart0()
Global gnDefFontSize ; = 8
; other fonts
Global gsDefFixedPitchFontName.s = "Courier New"
Global gsDefInfinityFontName.s = "Symbol"
Global gnCueListFontSize

;- main control variables (see WindowEventHandler.pbi)
Global gnWindowEvent
Global gnEventWindowNo
Global gnEventGadgetNo
Global gnEventGadgetNoForEvHdlr
Global gnEventGadgetPropsIndex  ; index to gaGadgetProps()
Global gnEventGadgetArrayIndex  ; if gadget has more than one instance (eg \txtDMXChannel[0] - \txtDMXChannel[8]) then this is the array index
Global gnEventGadgetType
Global gnEventType
Global gnEventMenu
Global gnEventButtonId          ; set for toolbar and sidebar button events
Global gnValidateGadgetNo       ; gadget no. of gadget last requiring validation
Global gnValidateSubPtr
Global gnValidateProdTreeGadgetState
Global gnTrackingSliderNo
Global gnSliderEvent
Global gnEventSliderNo
Global gnEventCuePanelNo
Global gnFocusSliderNo
Global gqPriorityPostEventWaiting.q
Global gnDisableEventCheckingForGadgetNo ; Added 9Apr2021 11.8.4.2ac - see appropriate comments in WEP_validateFixtureType()

Global gsFatalErrorMessage.s

;- Languages available
Global Dim gaLanguage.tyLanguage(0)
Global gnLanguageCount
Global Dim gaLanguageGroups.tyLanguageGroup(1)  ; all one based here
Global Dim gsLanguageStrings.s(1)
Global Dim gsLanguageNames.s(1)
Global Dim gsLanguageIds.s(1)
Global gnLanguageGroups, gnLanguageStrings
Global gsAppDataLanguagesPath.s
Global NewList LanguageData.LanguageEntry()  ; List to store valid data
Global NewList langConfig.LangConfig()
Global CurrentGroup.s = ""

;- SMS variables
; SoundMan-Server variables
Global Dim gaSMSSyncPoint.tySMSSyncPoint(20)
Global gnMaxSMSSyncPoint
Global grSMS.tySMS
Global *SMSReceiveBuffer
Global gnSMSReceiveBufferSize
Global Dim gsSMSResponse.s(20)
Global grSMSCheck.tySMS
Global *SMSCheckReceiveBuffer
Global gnSMSCheckReceiveBufferSize
; Global Dim gaSMSTCGenerator.tySMSTCGenerator(7)
; nb SM-S documentation states there are 'up to eight timecode generators' but in my tests I can only use two, and Loren Wilton has confirmed that two is likely to remain the actual limit
Global Dim gaSMSTCGenerator.tySMSTCGenerator(1)

Global Dim gaPlayback.tyPlayback(20)
Global gsEncFilesPath.s
Global gsAudioFilesRootFolder.s
Global Dim glEncodeFileInfo.tyEncodedFileInfo(20)
Global gnEncodedFileCount
Global grASIOGroup.tyASIOGroup
Global Dim gaSMSOutput.tySMSOutput(0)
Global gnSMSOutputCount
Global gsLogLine.s
Global gnSuspendGetCurrInfo
; Global gnSMSReceiveTimeOut = 10000 ; 10Jun2021 11.8.5ag: changed from 5 seconds to 10 seconds, following emails from Chris Bryan and Loren Wilton
Global gnSMSReceiveTimeOut = 20000 ; 19Jan2023 11.9.8ag: changed from 10 seconds to 20 seconds, following 15-second delays shown in logs from Barny Daley

Global Dim gaSMSIns.tyNetworkIn(100)
Global gnSMSInCount
Global gbSMSInLocked
Global gnSMSCurrentIndex
Global gbReadingSMSMessage

Global grLevels.tyLevels ; global audio levels
Global grPreview.tyPreview

;- system variables
;- color variables
Global glSysColWindow.l = GetSysColor_(#COLOR_WINDOW)           ; Window background
Global glSysColWindowText.l = GetSysColor_(#COLOR_WINDOWTEXT)   ; Text in windows
Global glSysColGrayText.l = GetSysColor_(#COLOR_GRAYTEXT)       ; Grayed (disabled) text
Global glSysCol3DFace.l = GetSysColor_(#COLOR_3DFACE)           ; Face color for three-dimensional display elements and for dialog box backgrounds
Global glSysColBtnFace.l = $F0F0F0 ; was GetSysColor_(#COLOR_BTNFACE) which is apparently not supported in Windows 10 or greater, but returned this value under Windows 11!
Global glSysColInactiveCaption.l = $DBCDBF ; was GetSysColor_(#COLOR_INACTIVECAPTION) ditto
Global glSysColInactiveCaptionText.l = 0 ; was GetSysColor_(#COLOR_INACTIVECAPTIONTEXT) ditto
Global glScrollBarWidth.l = GetSystemMetrics_(#SM_CXVSCROLL)
Global glScrollBarHeight.l = GetSystemMetrics_(#SM_CXHSCROLL)
Global gl3DBorderWidth.l = GetSystemMetrics_(#SM_CXEDGE)
Global gl3DBorderHeight.l = GetSystemMetrics_(#SM_CYEDGE)
Global gl3DBorderAllowanceX.l = GetSystemMetrics_(#SM_CXEDGE) + GetSystemMetrics_(#SM_CXEDGE)
Global gl3DBorderAllowanceY.l = GetSystemMetrics_(#SM_CYEDGE) + GetSystemMetrics_(#SM_CYEDGE)
Global glBorderWidth.l = GetSystemMetrics_(#SM_CXBORDER)
Global glBorderHeight.l = GetSystemMetrics_(#SM_CYBORDER)
Global glBorderAllowanceX.l = GetSystemMetrics_(#SM_CXBORDER) + GetSystemMetrics_(#SM_CXBORDER)
Global glBorderAllowanceY.l = GetSystemMetrics_(#SM_CYBORDER) + GetSystemMetrics_(#SM_CYBORDER)
Global glMenuHeight.l = GetSystemMetrics_(#SM_CYMENU)
Global glThumbWidth = GetSystemMetrics_(#SM_CXHTHUMB) ; also relates to width of combobox arrow

Global grProgVersion.tyProgVersion

Global Dim gaThread.tyThread(#SCS_THREAD_DUMMY_LAST-1)

;- thread number
Threaded gnThreadNo             ; can be used to identify the number of the thread being executed
Threaded gsThreadNo.s = " #0 "  ; set to "#" + gnThreadNo + " " for debugging and key events (preset value for callback 'thread')

;- mutex handles and other mutex variables
Global gnCueListMutex
Global gnCueListMutexIndex = #SCS_MUTEX_CUE_LIST
Global gnCueListMutexLockThread           ; thread number that last locked gnCueListMutex
Global gnCueListMutexLockNo
Global gqCueListMutexLockTime.q
Global gqCueListLockDuration.q

Structure tyTryLockInfo
  qTryLockStartTime.q
  qTryLockTimeNow.q
  qTryLockLogInfoTime.q
  qTryLockSuccessfulTime.q
  nTryLockSuccessfulLockNo.i
  bTryLockDetailLogged.i
  sTryLockExtraInfo1.s
  sTryLockExtraInfo2.s
EndStructure
Threaded Dim gaTryLockInfo.tyTryLockInfo(#SCS_MUTEX_DUMMY_LAST)

Structure tySuccessfulLockInfo
  nMutexLockThread.i
  nMutexLockNo.i
  qMutexLockTime.q
  qMutexUnlockTime.q
EndStructure
Global Dim gaSuccessfulLockInfo.tySuccessfulLockInfo(#SCS_MUTEX_DUMMY_LAST) ; nb this array is NOT threaded so is common to all threads

Global gnImageMutex
Global gnImageMutexIndex = #SCS_MUTEX_IMAGE
Global gnImageMutexLockThread             ; thread number that last locked gnImageMutex
Global gnImageMutexLockNo
Global gqImageMutexLockTime.q

Global gnTempDatabaseMutex
Global gnTempDatabaseMutexIndex = #SCS_MUTEX_TEMP_DATABASE
Global gnTempDatabaseMutexLockThread               ; thread number that last locked gnTempDatabaseMutex
Global gnTempDatabaseMutexLockNo
Global gqTempDatabaseMutexLockTime.q

Global gnLoadSamplesMutex
Global gnLoadSamplesMutexIndex = #SCS_MUTEX_TEMP_DATABASE
Global gnLoadSamplesMutexLockThread               ; thread number that last locked gnLoadSamplesMutex
Global gnLoadSamplesMutexLockNo
Global gqLoadSamplesMutexLockTime.q

Global gnDebugMutex
Global gnDebugMutexIndex = #SCS_MUTEX_DEBUG

Global gnMTCSendMutex
Global gnMTCSendMutexIndex = #SCS_MUTEX_MTC_SEND
Global gnMTCSendMutexLockThread              ; thread number that last locked gnMTCSendMutex
Global gnMTCSendMutexLockNo
Global gqMTCSendMutexLockTime.q

Global gnDMXSendMutex
Global gnDMXSendMutexIndex = #SCS_MUTEX_DMX_SEND
Global gnDMXSendMutexLockThread              ; thread number that last locked gnDMXSendMutex
Global gnDMXSendMutexLockNo
Global gqDMXSendMutexLockTime.q

Global gnDMXReceiveMutex
Global gnDMXReceiveMutexIndex = #SCS_MUTEX_DMX_RECEIVE
Global gnDMXReceiveMutexLockThread           ; thread number that last locked gnDMXReceiveMutex
Global gnDMXReceiveMutexLockNo
Global gqDMXReceiveMutexLockTime.q

Global gnHTTPSendMutex
Global gnHTTPSendMutexIndex = #SCS_MUTEX_HTTP_SEND
Global gnHTTPSendMutexLockThread             ; thread number that last locked gnHTTPSendMutex
Global gnHTTPSendMutexLockNo
Global gqHTTPSendMutexLockTime.q

Global gnNetworkSendMutex
Global gnNetworkSendMutexIndex = #SCS_MUTEX_NETWORK_SEND
Global gnNetworkSendMutexLockThread          ; thread number that last locked gnNetworkSendMutex
Global gnNetworkSendMutexLockNo
Global gqNetworkSendMutexLockTime.q

Global gnSMSNetworkMutex
Global gnSMSNetworkMutexIndex = #SCS_MUTEX_SMS_NETWORK
Global gnSMSNetworkMutexLockThread           ; thread number that last locked gnSMSNetworkMutex
Global gnSMSNetworkMutexLockNo
Global gqSMSNetworkMutexLockTime.q

Global gnvMixSendMutex

Global gnLangMutex
Global gnLangMutexIndex = #SCS_MUTEX_LANG

Global Dim gaThreadMutexArray.tyThreadMutexInfo(#SCS_THREAD_DUMMY_LAST-1, #SCS_MUTEX_DUMMY_LAST-1)

Global gnLabel
Global gnLabelSAM
Global gnLabelUpdDispPanel
Global gnLabelUpdDispPanels
Global gnLabelReposAuds
Global gnLabelSlider
Global gnLabelOther, gnLabelThread, gnLabelSpecial, gnLabelPre

Global Dim gaWindowProps.tyWindowProps(#WZZ)
Global Dim gaGadgetProps.tyGadgetProps(1000)
Global gnNextGadgetNo = #SCS_GADGET_BASE_NO
Global gnFreeGadgetCount
Global gnMaxGadgetNo
Global gnNextImageNo
Global gnNextMiscGadgetNo = 50
Global gnNextMovieNo = 1000
Global gnNextFileNo = 100
Global gnNextDatabaseNo
Global gnNextSerialPortNo = 1
Global gnPreviewCurrVideoPlaybackLibrary
Global gnPreviewGaplessSeqPtr
Global gnCurrentWindowNo
Global gsCurrentWindow.s
Global gnCurrentCuePanelNo
Global gnCurrentSliderNo
Global gnDefaultFontNo
Global gdFontScale.d
Global gbCreatingSliderGadgets
Global gnCurrentEditorComponent
Global gnCurrentToolBarContainer
Global Dim gaOrderedShortcut(35)
Global Dim gaContainerLevelGadgetNo(100)

Global grText.tyText

Global grWCM.tyWCM
Global grWDD.tyWDD
Global grWDT.tyWDT
Global grWEM.tyWEM
Global grWEN.tyWEN
Global grWMI.tyWMI
Global grWMN.tyWMN
Global grWMT.tyWMT
Global grWQE.tyWQE
Global grWQK.tyWQK

Global gbDontChangeFocus
Global gbUnloadImmediate

;- cue types
Global Dim gaCueType.tyCueType(26)

;- level nodes
Global Dim gaLevelNode.tyLevelNode(20)
Global gnMaxLevelNode = -1

Global gnReqdMeterWidth = 37 ; 18 ;12
Global grTestLiveInputVUMeter.tyVUMeter

;- handles
Global Dim gaHandle.tyHandle(100)
Global gnMaxHandleIndex = -1

Global Dim gaVideoChannelInfo.tyVideoChannelInfo(0)
Global gnMaxVideoChannel = -1

;- display position and size
Global grDPS.tyDPS

;- PosSizeAndAspect clipboard
Global grPosSizeAndAspectClipboard.tyPosSizeAndAspect

;- special start info
Global grSpecialStartInfo.tySpecialStartInfo

;- production timer history
Global Dim gaProdTimerHistory.tyProdTimerHistory(0)
Global gnProdTimerHistoryPtr = -1

;- cue brackets
; see comments with Structure tyCueBracket for info about this array
Global Dim gaCueBracket.tyCueBracket(0)
Global gnLastCueBracket = -1

;- Move to Time info
Global grM2T.tyM2T

Global grCueFileItemCounts.tyCueFileItemCounts

; INFO ungrouped with specified initial values
; sorted
Global gbInitialising = #True
Global gbSystemLocked = #True
Global gbWaitForDispPanels = #True
Global gbShowToolTips = #True
Global gdResetPosForLinked.d = 0.05
Global gdTimerInterval.d = 50.0
Global gfMainXFactor.f = 1.0
Global gfMainPnlXFactor.f = 1.0
Global gfMainYFactor.f = 1.0
Global gfMainOrigXFactor.f
Global gfMainOrigYFactor.f
Global gnControlThreadDelay = 20
Global gnCtrlPanelPos = #SCS_CTRLPANEL_TOP
Global gnDependencyCue = -1
Global gnHighlightedCue = -1
Global gnInitialThreadExecutionState.l = -1
Global gnLastImageData = -1
Global gnLastPlayingAudioCue = -1
Global gnLogoAudPtr = -1 ; Added 15Mar2025 11.10.8al
Global gnMainWindowDesignHeight = 560 ; use by createfmMain() AND setMainXandYfactors()
Global gnMainWindowDesignWidth = 792  ; use by createfmMain() AND setMainXandYfactors()
Global gnMaxCuePanelAvailable = 9 ; 49    ; limits the number of cue panels that may be created, to prevent excessively high number of gadgets being created and the program crashing
Global gnMaxMixerLevel = 10000
Global gnNextAnimatedTimer = #SCS_TIMER_LAST + 1 ; used for assigning window timers for animated images
Global gnNextDevId = 1
Global gnNextFileId = 101
Global gnNextInGrpId = 1
Global gnNextFixTypeId = 1
Global gnNonLinearCue = -1
Global gnPeakMode = #SCS_PEAK_AUTO
Global gnTimerInterval = 50
Global gnUniqueAudId = 400000
Global gnUniqueCueId = 200000
Global gnUniqueCueMarkerId = 1000
Global gnUniqueDevMapId = 100
Global gnUniquePointId = 500
Global gnUniqueProdId = 100000
Global gnUniqueSubId = 300000
Global gnVisMode = #SCS_VU_LEVELS
Global gnWaitWindowEventTimeout = 20
Global gnWriteStringFormat = #PB_UTF8
Global gs100Chars.s = "1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik,9ol.0p;/-[¥'=]\!QAZ@WSX#EDC$RFV%TGB^YHN&UJM*IK<(OL>)P:?_{«+}|`~ €ƒÅ£"
; gs100Chars is used when encrypting the registration info stored in "C:\ProgramData\ShowCueSystem\scs11_24E6784.scscp"
; see encryptRegKey(), decryptRegKey(), loadRegKeyFileArray() and saveRegKey()
Global gsDecimalMarker.s = "." ; may be changed in initialisePart1() when checking internationalization

; The following list of hotkeys MUST be in the same order as #SCS_WMNF_HK_A to #SCS_WMNF_HK_PGDN
Global gsValidHotkeys.s = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,1,2,3,4,5,6,7,8,9,0,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,PGUP,PGDN" ; mod 17Apr2022 11.9.1bb

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Global gsProcBits.s = "64"
CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x86
  Global gsProcBits.s = "32"
CompilerElse
  ; if neither of the above then do not define gsProcBits.s to force a compilation error for any usage of gsProcBits
CompilerEndIf

; INFO ungrouped with default initial values
; sorted
Global gbAdding
Global gbApplyDisplayScaling
Global gbAudioFileOrPathChanged
Global gbBassNoSoundDevInitialised
Global gbCallCheckUsingPlaybackRateChangeOnly
Global gbCallEditor
Global gbCallEditUpdateDisplay
Global gbCallGoClicked
Global gbCallLoadDispPanels
Global gbCallLoadGridRowsWhereRequested
Global gbCallPopulateGrid
Global gbCallPrimeSplash
Global gbCallRefreshDispPanel
Global gbCallReloadDispPanel
Global gbCallSetCueToGo
Global gbCallSetGoButton
Global gbCallSetNavigateButtons
Global gbCallSetVidPicTargets
Global gbChangeTimeProfile
Global gbCheckForLostFocus
Global gbCheckForPrimeVideoReqd
Global gbCheckForResetTOD
Global gbCloseCueFile
Global gbCloseSCS
Global gbClosingDevices
Global gbClosingDown
Global gbCrashClose
Global gbCueFileLoaded ; added 25Nov2019 11.8.2rc5 - used to delay processing #SCS_SAM_SET_PLAYORDER until cue file has been loaded - this SAM request results from receiving /ctrl/setplayorder message from the primary
Global gbCueFileOpen
Global gbCuePanelLoadingMessageDisplayed
Global gbDataChanged
Global gbDemoCueFile
Global gbDemoMode
Global gbDfltColorFile
Global gbDisplayStatus
Global gbDispPanelsLoaded
Global gbDMXAvailable ; #True if the license level allows DMX (cue control and/or lighting) AND if the library ftd2xx.dll is successfully opened. See also gbFTD2XXAvailable.
Global gbDMXDisplayDisplayed
Global gbEditHasFocus
Global gbEditing
Global gbEditingTemplate
Global gbEditorAndOptionsLocked
Global gbEditPasswordReqd
Global gbEditPasswordSupplied
Global gbEditProdFormLoaded
Global gbEditorFormLoaded
Global gbEditUpdateGraphMarkers
Global gbFadersDisplayed
Global gbFileLocatorActive
Global gbFileStatsChanged
Global gbForceFocusPointToNextManual
Global gbForceGridReposition
Global gbForceReloadAllDispPanels
Global gbForceStartEditor
Global gbForceTracing
Global gbFTD2XXAvailable ; #True if the library ftd2xx.dll is successfully open. This library is supplied by ENTTEC and is used for accessing the ENTTEC DMX interfaces. See also gbDMXAvailable.
Global gbGlobalPause
Global gbGoIfOk ; 21Jan2022 11.9.0rc3
Global gbGoToProdPropDevices
Global gbGridLoaded
Global gbHotkeysInUse
Global gbIgnoreLostFocus
Global gbIgnoreSetCueState
Global gbImportedCues
Global gbInApplyLabelChanges
Global gbInApplyDevChanges
Global gbInBuildDevChannelList
Global gbInCalcCueStartValues
Global gbInCueStatusChecks
Global gbInDragDrop
Global gbInEditorDoPublicNodeClick
Global gbInExternalControl
Global gbInFadeImage
Global gbInGetSMSCurrInfo
Global gbInGoToCue
Global gbInImportAudioFiles
Global gbInImportFromCueFile
Global gbInLoadArrayAudioDevs
Global gbInLoadCueFile
Global gbInLoadDispPanels
Global gbInMessageRequester
Global gbInMidiInClose
Global gbInMidiInReset
Global gbInOpenNextCues
Global gbInOptionRequester
Global gbInOptionsWindow
Global gbInPauseAll
Global gbInPlayAud
Global gbInRedoPhysicalDevs
Global gbInReleaseAudLoop
Global gbInReposAuds
Global gbInSamProcess
Global gbInSetAlphaBlend
Global gbInSetCueToGo
Global gbInStopAud ; Added 17Jan2023 11.9.8ad
Global gbKillSplashTimerEarly
Global gbKillSplashTimerNow
Global gbLogProcessorEvents
Global gbLostFocusDisplayed
Global gbMainFormLoaded
Global gbMajorWarnDisplayed
Global gbMaxCueWarningDisplayed
Global gbMayOverrideStatus
Global gbMidiExtras
Global gbMidiTestWindow
Global gbModalDisplayed
Global gbNewCueFile
Global gbNewDevMapFileCreated
Global gbNoWait
Global gbOpeningCueFile
Global gbOpenRecentFile
Global gbPasting
Global gbPauseAllDisplayed
Global gbPictureBlending
Global gbPreferencesOpen
Global gbPreviewOnOutputScreen
Global gbProcessingSubTypeG
Global gbProcessSliderLoadFileRequestIssued
Global gbProcessSliderLoadFileRequests
Global gbReadyToLoadMainForm
Global gbRecovering
Global gbRedoPhysicalDevs
Global gbRedrawPanelGradients
Global gbReloadAndDisplayDevsForProd
Global gbResetTOD ; Reset time-of-day for time-based cues. Set in the Control Thread on detecting a change of day.
Global gbResettingTODPart1 ; inside the procedure resetTOD() - used by procedures that may be called directly or indirectly by resetTOD()
Global gbResettingTODPart2 ; inside the procedure stopEverythingPart2() where parameter bResettingTOD=#True - used by procedures that may be called directly or indirectly by stopEverythingPart2()
Global gbReviewDevMap ; may be set by primeAndInitSMS()
Global gbSamRequestUnderStoppingEverything
Global gbSaveAs
Global gbScreenNotPresentWarningDisplayed
Global gbSCSVersionChanged
Global gbSetEditorWindowActive
Global gbShowFileLocatorAfterInitialisation
Global gbSplashFormLoaded
Global gbSplashOnTop
Global gbSplashWindow
Global gbStartingEditor
Global gbStopEverything
Global gbStoppingEverything
Global gbFadingEverything
Global gnFadeEverythingTime
Global gbSwapMonitors1and2  ; as set at session start, and applicable to the whole session (see also gnSwapMonitor as the swap may not be for monitor 2)
Global gbTracingStopped
Global gbUnsavedChanges
Global gbUnsavedRecovery
Global gbUseBASS
Global gbUseBASSMixer
Global gbUseSMS
Global gbVideoFormClearReqd
Global gbVideoFormLoaded
Global gbVideosOnMainWindow
Global gbWaitForSetCueToGo
Global gbWarningMessageDisplayed
Global gbWorkshopMode
Global gbXMLFormat

Global _ScaleDPI_X_.f=1.0, _ScaleDPI_Y_.f=1.0

Global gn2ndCueFileStringFormat
Global gnActiveAudPtr
Global gnBtnGap
Global gnBtnHeight
Global gnBufferingThreadEvent.l
Global gnCallEditorCuePtr
Global gnCallOpenNextCues
Global gnContainerLevel
Global gnCueEnd
Global gnCueFileNo
Global gnCueFileStringFormat
Global gnCueStartedCount  ; cue start sequence for this session - used for determining first playing cue etc, as cannot rely on nTimeCueStarted due to time overflows
Global gnCueToGo  ; cue to activate when 'Go' button clicked
Global gnCueToGoOverride  ; as gnCueToGo but as set by user clicking on grid when grProd\nGridClickAction = #SCS_GRDCLICK_SET_GO_BUTTON_ONLY
Global gnCueToGoState
Global gnCueToHighlight ; used ONLY for the main thread request #SCS_MTH_HIGHLIGHT_LINE
Global gnCurrentStatusType
Global gnCurrMouseCursor
Global gnDemoTimeCount
Global gnEditorCntRightFixedWidth
Global gnEditorScaPropertiesInnerWidth
Global gnEditorScaSubCueInnerHeight
Global gnErrorHandlerCode  ; used in generalErrorHandler() - see also Enumeration for "error handler codes"
Global gnFavFileCount
Global gnFirstCueStopped
Global gnFTD2XXLibraryNo
Global gnGap  ; standard gap between a right-justified prompt and a field
Global gnGap2
Global gnGoShortcut
Global gnHibernatedCueResumed
Global gnHighlightedRow
Global gnHSplitterSeparatorHeight   ; populated by obtainSplitterSeparatorSizes()
Global gnKernel32Library
Global gnLastAud
Global gnLastCue
Global gnLastFileData
Global gnLastFileStats
Global gnLastMTCPreRoll
Global gnLastMTCFrameRate
Global gnLastMTCType
Global gnLastResetDay
Global gnLastSub
Global gnLblVOffsetC ; vertical offset for labels of combobox gadgets
Global gnLblVOffsetS ; vertical offset for labels of strings gadgets
Global gnMainThreadContinueLine
Global gnMainThreadLabel
Global gnMaxBVLevelSubPtr     ; return value from getMaxBVLevelInUse() identifying the sub-cue that contains the maximum level, or -ve for production properties
Global gnMaxCueIndex
Global gnMaxCuePanelCreated   ; max cue panel based on max height of connected screens, with min cue panel height % (75%), and no toolbar and no cue list displayed
Global gnMaxDisplayablePanel  ; calculated by PNL_loadDispPanels
Global gnMaxDispPanel         ; max cue panel as calculated by setDisplayOrder (based on actuals cues), capped at gnMaxCuePanelAvailable
Global gnMidiAliasCount
Global gnMinBVLevelSubPtr     ; return value from getMinBVLevelInUse() identifying the sub-cue that contains the minimum level greater than -inf, or -ve for production properties
Global gnNextX
Global gnNodeId
Global gnNoteHotkeyCuesPlaying
Global gnNumWaveOutDevs
Global gnOperMode       ; operational mode (design or performance)
Global gnOSVersion
Global gnPanelContentXOffset        ; populated by obtainPanelContentOffsets()
Global gnPanelContentYOffset        ; populated by obtainPanelContentOffsets()
Global gnPhysicalAudDevs ; number of physical audio output devices
Global gnPositioningMidi
Global gnPrefsReadBuild
Global gnPrefsReadVersion
Global gnPrevHighlightedCue
Global gnPrevHighlightedRow
Global gnPreviewOnOutputScreenNo
Global gnPrevLCAction
Global gnProdTimerTimeInSecs
Global gnRandomSeed
Global gnRecentFileCount
Global gnRedimIndex
Global gnRefreshAudPtr
Global gnRefreshCuePtr
Global gnRefreshSubPtr
Global gnRegisterRetries
Global gnRowEnd  ; row in WMN\grdCues corresponding to gnCueEnd
Global gnRowToGo ; row in WMN\grdCues corresponding to gnCueToGo
Global gnSamLastRequestProcessed
Global gnSamRequestsProcessed
Global gnSaveAsFormat
Global gnSaveSettingsCount
Global gnSCSColor
Global gnSessionId
Global gnShortGap
Global gnSortedAudioDevs
Global gnSortedInitializedDevs
Global gnSplashDuration
Global gnSplitterMoving
Global gnStandbyCuePtr
Global gnSwapMonitor ; as set at session start, and applicable to the whole session (see also gbSwapMonitors1and2)
Global gnTemplateCount
Global gnThisCueLength
Global gnThisCurrentValue
Global gnTimePeriod   ; value used in timeBeginPeriod(), or 0 if timeBeginPeriod() not called
Global gnTraceLine
Global gnTraceDMXSendMutexLocking
Global gnTraceHTTPSendMutexLocking
Global gnTraceMTCSendMutexLocking
Global gnTraceMutexLocking
Global gnTraceSMSMutexLocking
Global gnTraceTempDatabaseMutexLocking
Global gnTraceLoadSamplesMutexLocking
Global gnUniqueRef
Global gnUniqueTreeItemId
Global gnValMsgCount
Global gnVideoFadeInTransitionId.l    ; long
Global gnVideoFadeOutTransitionId.l   ; long
Global gnVisualWarningCuePtr
Global gnVisualWarningState ; 0 = not required, 1 = on (normal), 2 = off (dim)
Global gnVisualWarningTimeRemaining
Global gnVSplitterSeparatorWidth    ; populated by obtainSplitterSeparatorSizes()
Global gnWEDDefaultWindowWidth
Global gnWEDDefaultWindowHeight
Global gnWrapTextLineCount
Global gnWrapTextTotalHeight

Global gqGlobalPauseTimeStarted.q
Global gqGoKeyDownTime.q
Global gqGoKeyUpTime.q
Global gqIgnoreCalcPosUntilTime.q
Global gqMainThreadRequest
Global Dim gqMainVKTimeDown.q(255)  ; time a key in window #WMN was pressed (used for checking double-presses)
Global Dim gqMainVKTimeActioned.q(255) ; Added 29Aug2022 11.9.5ae
Global gqSamTimeLastRequestEnded.q
Global gqSamTimeLastRequestStarted.q
Global gqSamProcessLastEnded.q
Global gqSamProcessLastStarted.q
Global gqSplashStartedTime.q
Global gqStartTime.q
Global gqStatusDisplayed.q
Global gqStopEverythingTime.q
Global gqThreadMainLoopEnded.q
Global gqThreadMainEventStarted.q
Global gqThreadMainLoopStarted.q
Global gqTimeDiskActive.q
Global gqTimeLostFocusDisplayed.q
Global gqTimeMainShortcutPressed.q    ; time the keyboard shortcut was pressed
Global gqTimeMouseClicked.q
Global gqTimeNow.q
Global gqTimeWarningMessageDisplayed.q

Global grStartTime.SYSTEMTIME

Global gs2ndCueFile.s
Global gs2ndCueFolder.s
Global gsAppDataPath.s
Global gsAppPath.s
Global gsAudioFileDialogInitDir.s
Global gsCdlgBrowseInitDir.s
Global gsColorFile.s
Global gsColorFolder.s
Global gsColorScheme.s
Global gsCommand.s
Global gsCommonAppDataPath.s
Global gsCueFile.s
Global gsCueFolder.s
Global gsDevMapsPath.s
Global gsError.s
Global gsFile.s
Global gsFile2.s
Global gsHelpFile.s
Global gsInitialCurrentDirectory.s
Global gsLCPrevCueType.s
Global gsLicUser.s
Global gsMonitorKey.s
Global gsMyDocsLeafName.s
Global gsMyDocsPath.s
Global gsOSVersion.s
Global gsPatternAllCueFiles.s
Global gsPrefenceGroup.s
Global gsProcessNetworkCommandError.s
Global gsRegAuthString.s
Global gsRenamedFileName.s
Global gsSelectedFileErrorMsg.s
Global gsStatusLine.s
Global gsTempFolderPath.s
Global gsTemplateFile.s
Global gsTemplatesFolder.s
Global gsTipControl.s
Global gsTmpString.s
Global gsToolTipText.s
Global gsUnwrappedText.s
Global gsVideoFileDialogInitDir.s
Global gsVSTError.s
Global gsWhichTimeProfile.s

; Global Dim gaSaveSettingsSubPtr(0)
Global Dim gaSaveSettings.tySaveSetting(0)
Global Dim gaValMsg.s(0)
Global Dim gsRecentFile.s(#SCS_MAXRFL_SAVED)
Global Dim gsTemplate.s(10)

Global grLicInfo.tyLicInfo
Global Dim gaRegKeyFile.tyRegKeyFile(0)
Global gnMaxRegKeyFile = -1

; Countdown Timer Value : Session Only
Global gnCountDownSessionTime

;- audio devices
Global grAudioDevDef.tyAudioDev
Global Dim gaAudioDev.tyAudioDev(20)
Global Dim gaAudioDevSorted.tyAudioDevShort(20)
Global Dim gaAudioInitializedDevSorted.tyAudioDevShort(20)
Global Dim gaMixerStreams.tyMixerStream(0)
Global Dim gaGaplessSeqs.tyGaplessSeq(0)
Global Dim glEncodedFileInfo.tyEncodedFileInfo(0)
Global gnNumAudioDSandWASPIDevs
Global gnNumAudioASIODevs

;- video audio devices
Global Dim gaVideoAudioDev.tyVideoAudioDev(0)
Global gnNumVideoAudioDevs
Global gbVideoAudioDevsLoaded

;- video capture devices
Global Dim gaVideoCaptureDev.tyVideoCaptureDev(0)
Global gnNumVideoCaptureDevs
Global gbVideoCaptureDevsLoaded

;- live input devices
Global Dim gaLiveInputDev.tyLiveInputDev(0)
Global gnNumLiveInputDevs
Global gbLiveInputDevsLoaded

;- templates
Global Dim gaTemplate.tyTemplate(0)
Global grTemplateDef.tyTemplate
Global grTmTemplate.tyTemplate
Global grTmCueDef.tyTmCue
Global grTmDevDef.tyTmDev
Global grTmDevMapDef.tyTmDevMap
Global Dim gaTmCue.tyTmCue(0)
Global Dim gaTmDev.tyTmDev(0)
Global Dim gaTmDevMap.tyTmDevMap(0)
Global gnLastTmCue
Global gnLastTmDev
Global gnLastTmDevMap

Global grProd.tyProd
Global grProdForDevChgs.tyProd
Global grProdForChecker.tyProd
Global grHoldProd.tyProd
Global gbProdDevChgs ; set #True or #False in WEP_setDevChgsBtns() - #True if changes found
Global gbProdDevOutputGainChgs
Global gbProdDevInputGainChgs

Global grVST.tyVST, grVSTDef.tyVST, grVSTHold.tyVST
Global grDevVSTPluginDef.tyDevVSTPlugin

Global grCtrlSetupDef.tyCtrlSetup
Global grCtrlSetup.tyCtrlSetup  ; for control surface equipment, eg Behringer BCR2000
Global mrCtrlSetup.tyCtrlSetup  ; 'module' info for above, so changes can be cancelled if required (in fmCtrlSetup.pbi)

Global grFixtureLogicalDef.tyFixtureLogical
Global grDevFixtureDef.tyDevFixture

; see also a2ndCue.tyCue(0) etc, further down this file
Global Dim aCue.tyCue(0)
Global Dim aSub.tySub(0)
Global Dim aAud.tyAud(0)
Global Dim gaFileData.tyFileData(0)
Global Dim gaFileStats.tyFileStats(0)
Global Dim gaImageData.tyImageData(0)

Global grMixerStreamDef.tyMixerStream
Global grGaplessSeqDef.tyGaplessSeq
Global grLevelPointItemDef.tyLevelPointItem
Global grLevelPointDef.tyLevelPoint
Global grLevelPointItem.tyLevelPointItem    ; 'temporary' area to hold item found by getPrevIncludedLevelPointItem()

Global grProdDef.tyProd, grProdDefForAdd.tyProd
Global grAudioLogicalDevsDef.tyAudioLogicalDevs
Global grVidAudLogicalDevsDef.tyVidAudLogicalDevs
Global grVidCapLogicalDevsDef.tyVidCapLogicalDevs
Global grFixTypesDef.tyFixType
Global grLightingLogicalDevsDef.tyLightingLogicalDevs
Global grCtrlSendLogicalDevsDef.tyCtrlSendLogicalDevs
Global grCueCtrlLogicalDevsDef.tyCueCtrlLogicalDevs
Global grLiveInputLogicalDevsDef.tyLiveInputLogicalDevs
Global grInGrpsDef.tyInGrp

Global grCueDef.tyCue
Global grSubDef.tySub, grSubDefForAdd.tySub
Global grAudDef.tyAud, grAudDefForAdd.tyAud
Global grLoopInfoDef.tyLoopInfo
Global grFileDataDef.tyFileData
Global grFileStatsDef.tyFileStats
Global grEnableDisableDef.tyEnableDisable

Global grLibVSTPluginDef.tyLibVSTPlugin
Global grDevVSTPluginDef.tyDevVSTPlugin
Global grAudVSTPluginDef.tyAudVSTPlugin

Global Dim gaHotkeys.tyHotkeys(0)
Global Dim gaCurrHotkeys.tyHotkeys(0)
Global gnMaxHotkey
Global gnMaxCurrHotkey
Global grHotkeyDef.tyHotkeys
Global Dim gnLastHotkeyStepProcessed(#SCS_MAX_HOTKEY) ; one entry per hotkey number

; only required for grids in which the user may select or move columns
Global grGrdCuePrintInfo.tyGridInfo

Global grGridRowInfo.tyGridRowInfo  ; return variables from getGridRowInfo()

Global grCasItem.tyCasItem
Global Dim gaCasArray.tyCasItem(0)
Global Dim gaCasGroupArray.tyCasGroup(0)
Global Dim gaSamArray.tySam(100)

Global grMain.tyMain
Global grMisc.tyMisc ; Added 3Dec2022 11.9.7ar

Global grDispControl.tyDispControl

Global Dim gaCueState.s(#SCS_LAST_CUE_STATE + 1)
Global Dim gaCueStateForGrid.s(#SCS_LAST_CUE_STATE + 1)

;- options
Global grGeneralOptions.tyGeneralOptions
Global mrGeneralOptions.tyGeneralOptions ; module level for fmOptions
Global grEditingOptions.tyEditingOptions
Global mrEditingOptions.tyEditingOptions ; module level for fmOptions
Global grEditorPrefs.tyEditorPrefs
Global grVideoDriver.tyVideoDriver
Global mrVideoDriver.tyVideoDriver  ; module level for fmOptions
Global grVideoDriverSession.tyVideoDriver ; use for video driver settings that MUST use the start-of-session settings (eg video renderer)
Global grRAIOptions.tyRAIOptions
Global mrRAIOptions.tyRAIOptions ; module level for fmOptions
Global grCurrScreenVideoRenderers.tyCurrScreenVideoRenderers
Global mrCurrScreenVideoRenderers.tyCurrScreenVideoRenderers ; module level for fmOptions

Global Dim grOperModeOptions.tyOperModeOptions(#SCS_OPERMODE_LAST)
Global Dim mrOperModeOptions.tyOperModeOptions(#SCS_OPERMODE_LAST)          ; module level for fmOptions
Global Dim grOperModeOptionDefs.tyOperModeOptions(#SCS_OPERMODE_LAST)       ; defaults
Global Dim grOperModeOptionsAtStart.tyOperModeOptions(#SCS_OPERMODE_LAST)   ; settings at session start

Global gnAsioDeviceCount
Global gnDSDeviceCount
Global gnWASAPIDeviceCount
Global gnDefaultAudioDriver
Global gnCurrAudioDriver
Global gnPrevAudioDriver
Global grDriverSettings.tyDriverSettings
Global mrDriverSettings.tyDriverSettings      ; module level for fmOptions
Global Dim gaDriverInfo.tyDriverInfo(#SCS_DRV_LAST)

Global grSession.tySession
Global mrSession.tySession                  ; module level for fmOptions

Global grDontTellMeAgain.tyDontTellMeAgain
Global grLoadProdPrefs.tyLoadProdPrefs

;- shortcuts
Global Dim gaShortcutsMain.tyShortCuts(#SCS_ShortMain_Last)
Global Dim gaShortcutsEditor.tyShortCuts(#SCS_ShortEditor_Last)
Global Dim maShortcutsMain.tyShortcuts(0)   ; module level for fmOptions
Global Dim maShortcutsEditor.tyShortCuts(0)

Global Dim gaFavoriteFiles.tyFavoriteFile(#SCS_MAX_FAV_FILE)

Global Dim gaCueLogicalDevs.tyCueLogicalDevs(100)
Global gsSelectedDevice.s

;- TimeLine
Global Dim gaActTimeLine.tyTimeLineEntry(200)       ; active timeline
Global Dim gaPenTimeLine.tyTimeLineEntry(100)       ; pending timeline (eg cues that are 'ready')
Global Dim gaHibTimeLine.tyTimeLineEntry(0)         ; hibernating timeline (cues currently hibernating)
Global gnMaxActTimeLine = -1
Global gnMaxPenTimeLine = -1
Global gnMaxHibTimeLine = -1
Global gnLastTimeLineEntryId

;- window positions
; INFO update closeAllForms() if making changes to this list
Global grAGColorsWindow.tyWindow
Global grBulkEditWindow.tyWindow
Global grClockWindow.tyWindow
Global grColorSchemeWindow.tyWindow
Global grCopyPropsWindow.tyWindow
Global grControllersWindow.tyWindow
Global grCountDownWindow.tyWindow
Global grCtrlSetupWindow.tyWindow
Global grCueMarkerUsageWindow.tyWindow
Global grDMXChannelsWindow.tyWindow
Global grDMXDisplayWindow.tyWindow
Global grDMXTestWindow.tyWindow
Global grEditModalWindow.tyWindow
Global grEditWindow.tyWindow
Global grExportWindow.tyWindow
Global grFavFilesWindow.tyWindow
Global grFavFileSelectorWindow.tyWindow
Global grFileOpenerWindow.tyWindow
Global grFileRenameWindow.tyWindow
Global grFindWindow.tyWindow
Global grImportWindow.tyWindow
Global grImportCSVWindow.tyWindow
Global grImportDevsWindow.tyWindow
Global grLabelChangeWindow.tyWindow
Global grLinkDevsWindow.tyWindow
Global grLockWindow.tyWindow
Global grMainWindow.tyWindow
Global grMemoWindowMain.tyWindow
Global grMemoWindowPreview.tyWindow
Global grMidiTestWindow.tyWindow
Global grMTCDisplayWindow.tyWindow
Global grMultiCueCopyEtcWindow.tyWindow
Global grMultiDevWindow.tyWindow
Global grNearEndWarningWindow.tyWindow
Global grOptionsWindow.tyWindow
Global grOSCCaptureWindow.tyWindow
Global grPrintCueListWindow.tyWindow
Global grProdFolderWindow.tyWindow
Global grProdTimerWindow.tyWindow
Global grScribbleStripWindow.tyWindow
Global grTemplatesWindow.tyWindow
Global grTimeProfileWindow.tyWindow
Global grTimerDisplayWindow.tyWindow
Global grVideoWindow.tyWindow
Global grVSTWindow.tyWindow
Global grVSTPluginsWindow.tyWindow

Global grVideoMonitors.tyVideoMonitors

Global Dim gaModalWindowStack.tyModalWindowInfo(20, #WZZ)
Global gnModalWindowStackPtr = -1

Global Dim gaGadgetCallbackInfo.tyGadgetCallbackInfo(10)
Global gnMaxGadgetCallBackInfo = -1

;- slider globals
Global gnSliderWithFocus
Global Dim gaFaderInfo.tyFaderInfo(1)
Global gfFdrOverallSize.f           ; used for working out proportions of fader to sections A, B and C

;- find
Global Dim gaFind.tyFind(0)
Global gnMaxFindIndex

Global Dim gaSFRAction.tySFRAction(#SCS_SFR_ACT_LAST)
Global Dim gaSFRCueType.tySFRCueType(#SCS_SFR_CUE_LAST)

Global grCFH.tyCFH

Global gbLoadingCueFile
Global gbInWriteXMLCueFile
Global gnTagLevel
Global gsLine.s, gsChar.s, gbEOF
Global gsTag.s, gsData.s, gsTagAttributeName1.s, gsTagAttributeValue1.s, gsTagAttributeName2.s, gsTagAttributeValue2.s
Global Dim gasTagStack.s(20)
Global gqLastRecoveryTime
Global gbMainSaveEnabled
Global gbMainSaveReasonVisible
Global gsRecoveryFile.s

Global grRecoveryFileInfo.tyRecoveryFileInfo

Global Dim gaFileNotFound.tyFileNotFound(0)
Global gnFileNotFoundCount.i

; the '2nd' arrays and variables below are used when importing cues from another cue file, or when reading a template cue file
Global gr2ndProd.tyProd
Global gr2ndVST.tyVST
Global Dim a2ndCue.tyCue(0)
Global Dim a2ndSub.tySub(0)
Global Dim a2ndAud.tyAud(0)
Global Dim a2ndFileData.tyFileData(0)
Global gn2ndCueEnd
Global gn2ndLastCue
Global gn2ndLastSub
Global gn2ndLastAud
Global gn2ndLastFileData
Global gb2ndCueFileOpen
Global gn2ndCueFileNo
Global gb2ndXMLFormat

Global Dim gaImportDev.tyImportDev(0)
Global Dim gaImportMidiDev.tyImportDev(0)
Global gnLastImportDev = -1
Global gnLastImportMidiDev = -1

;- for MMedia
Global gbAsioInitDone
Global gbWasapiAvailable
Global gnStopFadeTime.l     ; long
Global Dim gaAudSet(0,0)
Global grMMedia.tyMMedia
Global grVideoInfo.tyVideoInfo
Global gbPlayingVideo
Global gbBassVideoInitialised
Global gnPreviewEndSync.l
Global gbAsioStarted
Global gnMaxPreOpenAudioFilesForLicLevel
Global gnMaxPreOpenVideoImageFilesForLicLevel
Global gnStreamLockLevel
; Global gbAsioLocked
Global gnCurrAsioLockCount

Global grTestTone.tyTestTone
Global Dim gaTestToneData.w(0) ; array of 2-byte fields
Global grTestLiveInput.tyTestLiveInput
Global grMasterLevel.tyMasterLevel
Global Dim gaOutputArray.tyOutput(0)
Global gnMaxOutputArrayIndex
Global Dim gaLoopSync.tyLoopSync(50)
Global gnLastLoopSync

Global Dim grVidPicTarget.tyVidPicTarget(#SCS_VID_PIC_TARGET_LAST)
Global grVidPicTargetDef.tyVidPicTarget
Global gnMaxVidPicTargetSetup = #SCS_VID_PIC_TARGET_NONE
Global gbMoviePlaying

Global Dim gaMonitors.tyMonitor(1)
Global gnMonitors
Global gnRealMonitors
Global Dim gaScreen.tyScreen(1)  ; SCS screens available for video/image cues
Global gnScreens

Global gnPlayWhenReadyAudPtr
Global gnMixerStreamCount
Global gnGaplessSeqCount
Global gsPluginAudioFilePattern.s
Global gsPluginAllAudioFilesPattern.s

Global gsAudioFileTypes.s         ; populated by setFileTypeList
Global gsAudioFilePattern.s
Global gnAudioFilePatternPosition.l   ; long

Global gsVideoImageFileTypes.s    ; populated by setFileTypeList
Global gsVideoImageFilePattern.s  ; ditto
Global gnVideoImageFilePatternPosition.l
Global gsVideoDefaultFile.s       ; shared by VideoImage and Video files

Global gsMidiFileTypes.s          ; populated by setFileTypeList
Global gsMidiFilePattern.s        ; ditto
Global gsMidiDefaultFile.s

Global gnDefaultBuffer.l        ; long
Global gnDefaultUpdatePeriod.l  ; long
Global gbInMapProdLogicalDevs

Global grProdTimer.tyProdTimer

Global Dim aLinkedAuds.tyLinkedAuds(0)
Global Dim gaFreeStreams.tyFreeStream(0)
Global grFreeStreamDef.tyFreeStream
Global gnFreeStreamCount
Global grFileInfo.tyFileInfo
Global grInfoAboutFile.tyInfoAboutFile
Global Dim gaCuePoint.tyCuePoint(0)
Global gnMaxCuePoint
Global Dim gaAnalyzedFile.tyAnalyzedFile(0)
Global gnMaxAnalyzedFile
Global Dim gaAudCuePoint.tyAudCuePoint(0)
Global gnMaxAudCuePoint

;- for CueEditor
Global grCED.tyCED
Global grEditMem.tyEditMem  ; editing 'memory'

;- last pic info
Global grLastPicInfo.tyLastPicInfo

Global gbInNodeClick
Global gbKillNodeClick
Global gnClickThisNode = -1
Global gbForceNodeDisplay
Global gbSkipValidation
Global gnFocusGadgetNo
Global gbLastVALResult = #True
Global gbInDisplayProd
Global gbInDisplayCue
Global gbInDisplaySub
Global gbInDisplayDev
Global gbInDisplayCtrlSendItem
Global gbInEditUpdateDisplay
Global gbInEditPlaySub
Global gbInPaste
Global gnUnsavedEditorGraphs
Global gsUnsavedEditorGraphs.s
Global gnUnsavedSliderGraphs
Global gbUnsavedVideoImageData
Global gbUnsavedPlaylistOrderInfo
Global gbDevMapsDeleted

Global Dim gaHoldAud.tyAud(0)
Global Dim gaClipCue.tyCue(0)
Global Dim gaClipSub.tySub(0)
Global Dim gaClipAud.tyAud(0)
Global gnClipCueCount, gnClipSubCount, gnClipAudCount
Global gbClipPopulated
Global gnClipCuePtr
Global grClipChaseStep.tyLTChaseStep
Global gbClipChaseStepPopulated
Global gbClipChaseStepPopulatedFI
Global gsClipChaseStepDescr.s
Global grLightingCueClipboard.tyLightingCueClipboard
Global gnClipMaxFixture
Global Dim gsClipFixtureCode.s(0)
Global Dim gnFixtureLinkGroup.b(0)

Global nEditCuePtr = -99
Global nEditSubPtr = -99
Global nEditAudPtr = -99
Global gnDisplayedCuePtr
Global gnDisplayedSubPtr
Global gnDisplayedAudPtr

Global gnEditPrevCueState
Global gnEditPrevLCState

Global gbEditMidiInfoDisplayedSet
Global gqEditMidiInfoDisplayed.q
Global gnPLTestMode
Global gnPLFirstAndLastTime
Global gbDoProdDevsForA
Global gbDoProdDevsForF
Global gbDoProdDevsForI
Global gbDoProdDevsForK
Global gbDoProdDevsForP

Global Dim gaCtrlSendItemB4Change.tyCtrlSend(#SCS_MAX_CTRL_SEND)
Global Dim gbNewCtrlSendItem(#SCS_MAX_CTRL_SEND)
Global Dim gbMenuItemAvailable(#SCS_MAX_MENU_ITEM)
Global Dim gbMenuItemEnabled(#SCS_MAX_MENU_ITEM)

;- tracing
Global gsDebugFileDateTime.s, gsStartDateTime.s
Global gsDebugFile.s, gsDebugFolder.s
Global gsOriginalDebugFile.s, gnCurrLogDay
Global gnDebugFile
Global gsListLogFile.s, gnListLogFile, gbDoListLogging
Global gsIndent.s
Global gbDoDebug, gbDoSMSLogging, gbSMSLogUsed
Global gsDebugFolderShortName.s
Global gnMaxTraceLines = 1000000
Global gnPlayingAudTypeForPPtr = -1
Global gnPeakVU ; only used for debug messages - tracks the peak (highest) level since the previous call to monitorVU()

;- slider globals
Global Dim gaSlider.tySlider(1)
Global gnMaxSld
Global gnSldCurrID = 0  ; first slider id (h) will be 1 (see SLD_New()), so if we get 0 in a slider id it means it hasn't been set
Global gbInitFaderConstantsDone
Global gnRedrawSldCount
Global gnReloadSldCount

;- for fmSplash
;- tyWSP for fmSplash
Structure tyWSP
  bDisplayingRegDetails.i
  bDisplaySplashWhenReady.i
  sStatus.s
  bStatusVisible.i
EndStructure
Global grWSP.tyWSP

;- for fmOptions
;- tyWOP for fmOptions
Structure tyWOP
  bEditorAndOptionsLocked.i
  bGrdShortcutsSetup.i
  bInFrmOptionsLoad.i
  bLoadingOptionsForm.i
  bTestLabelPopulated.i
  mbChanges.i
  mbChangesOK.i
  mbReloadGrid.i
  nDefaultBackColor.l
  nDisplayedContainer.i
  nNodeIndex.i[#SCS_OPTNODE_LAST+1]
  nNodeKey.i[#SCS_OPTNODE_LAST+1]
  nOldStringProc.i
  nNodeOperMode.i     ; operational mode of the selected node, if applicable, eg = #SCS_OPER_MODE_DESIGN when on the display options 'design performance mode' node
  nCurrOperMode.i     ; operational mode initially set = gnOperMode and possibly changed by cboChangeOperMode - saved back to gnOperMode on applying changes
  rDisplayedShortcuts.tyShortcuts
  nSelectedShortGroup.i
  
  ; Added by Josh 29/05/2025 Three copy/undo buffers for the three different operational modes
  ; Tracks the last used undo source mode for each of the three modes
  nUndoSourceModeDesign.i
  nUndoSourceModeRehearsal.i
  nUndoSourceModePerformance.i
  
  ; Tracks whether undo data is available for each mode
  bUndoDataAvailableDesign.i
  bUndoDataAvailableRehearsal.i
  bUndoDataAvailablePerformance.i
  
  ; Three separate undo data storage structures
  mtGrdCuesInfoDesign.tyGridInfo
  mtGrdCuesInfoRehearsal.tyGridInfo
  mtGrdCuesInfoPerformance.tyGridInfo
  ; End added by Josh 29/05/2025
EndStructure
Global grWOP.tyWOP

;- tyMidiCmdInfo
Structure tyMidiCmdInfo
  nCmd.i
  nCC.i
  nVV.i
  nCCVVFrom.i
  nCCVVUpto.i
  bCueRelated.i
EndStructure

;- tyMidiDupInfo
Structure tyMidiDupInfo
  sOriginal.s
  sDuplicate.s
  sMidiCueOrig.s
  sMidiCueDupl.s
EndStructure

;- MIDI variables
Global gnNumMidiOutDevs
Global gnNumMidiInDevs
Global gbMidiWarningDisplayed
Global gbTooManyMessages
Global gsMidiSendError.s
Global grMidiCommandDef.tyMidiCommand
Global gnMaxMidiCommand

Global *gMidiInData
Global Dim gaMidiInHdr.MIDIHDR(0)
Global Dim gaMidiOutHdr.MIDIHDR(0)

; ------------------------------------------------------------------------
;                               MIDI devices and control
; ------------------------------------------------------------------------
Global Dim gaMidiInDevice.tyMidiDevice(0)
Global Dim gaMidiOutDevice.tyMidiDevice(0)
Global grMidiDeviceDef.tyMidiDevice
Global Dim gaMidiControl.tyMidiControl(0)
Global grMidiControlDef.tyMidiControl
Global gnMidiCapturePhysicalDevPtr = -1
Global gbCapturingFreeFormatMidi
Global gnNRPNCapturePhysicalDevPtr = -1
Global gbCapturingNRPN
Global grMidiIn.tyMidiIn
Global grMidiInDef.tyMidiIn
Global Dim gaMidiIns.tyMidiIn(200)
Global gnMidiInCount
Global gbMidiInLocked
Global gsNoteMsg.s
; the following two globals are set by "setActionAndCue" (in MIDI.pbi)
Global gnMidiAction
Global gsMidiCue.s

Global Dim gaMSCSoundCommand.s($1E + 1)
Global Dim gaMMCCommand.s($47)

;- MTC Control
Global grMTCControl.tyMTCControl
Global grMTCSendControl.tyMTCSendControl
Global grMTCSendControlDef.tyMTCSendControl
Global grQPCInfo.tyQPCInfo

;- tyCtrObj
Structure tyCtrObj
  h.i
  sName.s
  nTop.i
  nLeft.i
  nHeight.i
  nWidth.i
  nFontId.i
  nFontSize.i
  nToolBarHeight.i
  sTag.s
  nResizeFlags.i
EndStructure
Global Dim gaResizeFormInfo.tyCtrObj(#WZZ)
Global Dim gaResizeControlInfo.tyCtrObj(0)

;- tyResizer
Structure tyResizer
  bRunning.i
EndStructure
Global grResizer.tyResizer

;- tyWFL for fmFileNotFound
Structure tyWFL
  sMyFileName.s
  sMyFolder.s
  bPrimaryFile.i
EndStructure
Global grWFL.tyWFL

;- tyBCI from BassChanInfo
Structure tyBCI
  nSilenceDataLength.i
  nTestToneDataLength.i
  chanInfo.BASS_CHANNELINFO
  bOKForSMS.i
  bOKForAnalyzeFile.i
  qChannelBytePosition.q
EndStructure
Global grBCI.tyBCI

Global grColHnd.tyColHnd

Global Dim gaColorScheme.tyColorScheme(#SCS_MAX_COLOR_SCHEME)
Global grColorScheme.tyColorScheme
Global grColorSchemeDef.tyColorScheme
Global grWorkScheme.tyColorScheme
Global grSchemeForReset.tyColorScheme

Global grUIColors.tyUIColors  ; added 26Dec2019 for new GUI

;- tyWAC for fmAGColors
Structure tyWAC
  rColorAudioGraph.tyColorAudioGraph
  rClassicColors.tyColorAudioGraph
  Array aSliceMinL.b(0)
  Array aSliceMinR.b(0)
  Array aSlicePeakL.b(0)
  Array aSlicePeakR.b(0)
  bArraysLoaded.i
  ; 'static' info regarding how the samples are displayed
  nFirstIncludedSlice.i
  nLastIncludedSlice.i
  nCursorPos.i
  nCursorPosPlay.i
  nCursorPosEdit.i
EndStructure
Global grWAC.tyWAC

;- tymodCueListHandler for modCueListHandler
Structure tymodCueListHandler
  mbMulti.i
EndStructure
Global grCLH.tymodCueListHandler

;- tyWLE for fmLockEditor
Structure tyWLE
  sCurrentFrame.s
  nLockAttempts.i
EndStructure
Global grWLE.tyWLE

;- tySongTags from BassChanInfo
Structure tySongTags
  strArtist.s     ; %ARTI
  strAlbum.s      ; %ALBM
  strTitle.s      ; %TITL
  strYear.s       ; %YEAR
  strTrack.s      ; %TRCK
  strGenre.s      ; %GNRE
  strComment.s    ; %CMNT
  strFormat.s     ; Format.. i.e. mp3, ogg, etc
  strFrequency.s  ; I.E. 44100, 48000, etc
  strBitrate.s    ; I.E. 128k, 192k, etc
EndStructure
Global grSongTags.tySongTags

Global grRS232ControlDefault.tyRS232Control
Global Dim gaRS232Control.tyRS232Control(0)
Global gnMaxRS232Control

;- tyRS232In
Structure tyRS232In
  sMessage.s
  bReady.i
  bDone.i
  qTimeIn.q
EndStructure
Global gbRS232Started
Global Dim gaRS232Ins.tyRS232In(100)
Global gnRS232InCount
Global gbRS232InLocked
Global gnRS232CurrentIndex
Global gbReadingRS232Message

;- for fmEditor
;- tyWED for fmEditor
Structure tyWED
  bActivated.i
  mbFormLoaded.i
  nNodeClickKey.i     ; used for checking if user has clicked on a node while we are still processing the previous node click
  mbUndoEnabled.i
  msUndoToolTip.s
  mbRedoEnabled.i
  msRedoToolTip.s
  mbSaveEnabled.i
  nFavBtnId.i[#SCS_MAX_ED_FAV+1]
  bSkipNextSplitterRepositioned.i
  nFileCount.i
  nFormMinWidth.i
  nCntLeftMinWidth.i
  nTreeMinWidth.i
  nFormMinHeight.i
  nSpecialAreaHeight.i
  ; nFormMaxHeight.i
  nTreeGadgetItem.i   ; set by WED_windowCallback() which is activated via SetWindowCallback. nTreeGadgetItem is the item clicked on if the user clicks the + or - symbol. PB doesn't auto-select.
  nTreeGadgetItemExpanded.i   ; 0 = not neither expanded nor collapsed; 1 = item collapsed; 2 = item expanded
  bReturnToEditorAfterFavFiles.i     ; used for telling FavFiles to return to the Editor
  bForceProcessNextTreeChangeEvent.i
  nSelectedNodeKey.i
  bTemplateInfoSet.i
  bFlickerTemplateInfo.i
  nFlickerCount.i
EndStructure
Global grWED.tyWED

Global gnSelectedNodeCuePtr
Global gnSelectedNodeSubPtr
Global gnSelectedNodeType
Global gsSelectedNodeInfo.s
Global gsSelectedCueInfo.s
Global gnSelectedCueNodeKey
Global gnSelectedNodeKey
Global gbIgnoreNodeClick
Global gbProcessOleStartDrag

;- for fmEditProd
;- tyWEP for fmEditProd
Structure tyWEP
  bTabDevLiveInputsCreated.i
  ; sorted
  bCtrlMidiOutComboBoxesPopulated.i
  bCtrlMidiThruComboBoxesPopulated.i
  bCtrlNetworkComboBoxesPopulated.i
  bCtrlRS232ComboBoxesPopulated.i
  bCtrlUDPComboBoxesPopulated.i
  bCueDMXComboBoxesPopulated.i
  bCueMidiInComboBoxesPopulated.i
  bCueMidiInDevsChanged.i
  bCueNetworkComboBoxesPopulated.i
  bCueRS232ComboBoxesPopulated.i
  bCueUDPComboBoxesPopulated.i
  bDeletingDevice.i
  bDeletingFixture.i
  bDisplayAudioTab.i
  bDisplayCtrlSendTab.i
  bDisplayCueCtrlTab.i ; 14Jun2022 11.9.4
  bDisplayLightingTab.i
  bEnableTestLiveInput.i
  bEnableTestTone.i
  bEnableTestVidCap.i
  bFixtureTypeTabPopulated.i
  bInDisplayDevMap.i
  bInDisplayDevProd.i
  bInValidate.i
  bLightingComboBoxesPopulated.i
  bReloadFixtureTypesComboBox.i
  bReloadInGrpLiveInputs.i
  nCntMidiAssignsOriginalHeight.i
  nCtrlDevClicked.i
  nCurrentAudDevMapDevPtr.i
  nCurrentAudDevNo.i
  nCurrentAudDevType.i
  nCurrentCtrlDevMapDevPtr.i
  nCurrentCtrlDevNo.i
  nCurrentCtrlDevType.i
  nCurrentCueDevMapDevPtr.i
  nCurrentCueDevNo.i
  nCurrentCueDevType.i
  nCurrentDevGrp.i
  nCurrentFixTypeChanNo.i
  nCurrentFixTypeNo.i
  nCurrentInGrpNo.i
  nCurrentLightingDevMapDevPtr.i
  nCurrentLightingDevNo.i
  nCurrentLightingDevType.i
  nCurrentLiveDevMapDevPtr.i
  nCurrentLiveDevNo.i
  nCurrentLiveDevType.i
  nCurrentVidAudDevMapDevPtr.i
  nCurrentVidAudDevNo.i
  nCurrentVidAudDevType.i
  nCurrentVidCapDevMapDevPtr.i
  nCurrentVidCapDevNo.i
  nCurrentVidCapDevType.i
  nDisplayedDevTab.i
  nDisplayedTab.i
  nEdgMidiAssignsOriginalHeight.i
  nFixtureId.i
  nHeightChangeIfHideSpecial.i
  nLoadProgress.i
  nMaxLoadProgress.i
  nReqdFixtureFocusGadget.i
  nTestToneTabNo.i
  rOrigInfo.tyMidiCmdInfo
  rThisInfo.tyMidiCmdInfo
  sCurrentAudDevName.s
  sCurrentCtrlDevName.s
  sCurrentCueDevName.s  ; pseudo dev name
  sCurrentFixTypeName.s ; pseudo dev name
  sCurrentInGrpName.s
  sCurrentLightingDevName.s
  sCurrentLiveInputDevName.s
  sCurrentVidAudDevName.s
  sCurrentVidCapDevName.s
  sDevDetailFrameTitle.s
  sErrorMsg.s
EndStructure
Global grWEP.tyWEP

;- for fmVSTPlugins
;- tyWVP for fmVSTPlugins
Structure tyWVP
  nDisplayedTab.i
  sDevCurrentLogicalDev.s
  nDevCurrentLineIndex.i
  nLibCurrentLineIndex.i
  bLibTabPopulated.i
  bDevTabPopulated.i
  bWindowActive.i
  bChanged.i
  bReadyToSaveToCueFile.i
EndStructure
Global grWVP.tyWVP

;- tyWPL for VST Plugin Editor (VST plugin's GUI)
Structure tyWPL
  nVSTHost.i          ; VST plugin host (DEV or AUD)
  nHostPluginIndex.i  ; grVST\aDevVSTPlugin() index if host DEV
  nHostAudPtr.i       ; aAud() ptr if host AUD
  bPluginShowing.i
  nVSTHandleForPluginShowing.l
EndStructure
Global grWPL.tyWPL

;- for fmEditCue
;- tyWEC for fmEditCue
Structure tyWEC
  bLoadingHotkeyCBO.i
  bTBC_OK.i
  bInValidate.i
  ; sActivationCode.s[11]   ; must be string as will hold the character representations of sActivationCode as held in the cue file
  bTBCGridSetup.i
EndStructure
Global grWEC.tyWEC

;- for fmEditQA
;- tyWQA for fmEditQA
Structure tyWQA
  nFileId.i     ; used for creating a unique id for entries in the array WQAFile()
  nCurrentCntImageHandle.i
  bEditProgMouseDown.i
  nFirstSelectedItem.i
  nSelectedItemCount.i
  bPlayLengthMayBeDisplayed.i
  nItemIndex.i  ; used after File Rename to reposition the display at the item renamed
  nScrollPos.i  ; used after File Rename to reposition the timeline at the position before the File Rename
  nStartFileNo.i
  bStartAtChanged.i
  bEndAtChanged.i
  nFullScreenState.i  ; checkbox state of 'Full Screen' when displayed (3-state checkbox)
  nContinuousState.i  ; checkbox state of 'Continuous' when displayed (3-state checkbox)
  rPreviewOrigPosAndSize.tyPosAndSize
  ; fields used in grabbing and dragging/resizing the preview image
  nMouseDownAudXPos.i   ; aAud()\nXPos when MouseDown event occurs
  nMouseDownAudYPos.i   ; aAud()\nYPos when MouseDown event occurs
  nMouseDownStartX.i    ; X position of cursor when MouseDown event occurs
  nMouseDownStartY.i    ; Y position of cursor when MouseDown event occurs
  bMouseDownOnCanvas.i
  bMouseDownOnCanvasProcessed.i
  fMouseDownXFactor.f
  fMouseDownYFactor.f
  fXPosIncrementS.f   ; small change (1 pixel)
  fYPosIncrementS.f
  fSizeIncrementS.f
  fXPosIncrementL.f   ; large change
  fYPosIncrementL.f
  fSizeIncrementL.f
  nXPosRange.i
  nYPosRange.i
  nSizeRange.i
EndStructure
Global rWQA.tyWQA

;- for fmEditQF
;- tyWQF for fmEditQF
Structure tyWQF
  bGraphMouseDown.i
  nGraphMouseX.i
  bInLogicalDevClick.i
  bValidatingFileName.i
  bInValidate.i
  nCurrST.i
  nCurrLS.i
  nCurrLE.i
  nCurrEN.i
  nCurrPos.i
  nCurrDevNo.i
  sCurrMouseFields.s
  sMouseFields.s
  bEditProgMouseDown.i
  nLastTrbZoomValue.i
  bChangingCurrPos.i
  bDisplayingLevelPoint.i
  nCurrLevelPointType.i
  nCurrLevelPointTime.i
  sUndoDescKeyPart.s
  nAdjLevelNetInc.i
  bCallSetOrigDBLevels.i
  fOrigDBLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1] ; used by WQF_adjustAllLevels()
  nDisplayedLoopInfoIndex.i
  lpDevSelFunc.i
  lpLogicalDevFunc.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1] ; must be integer even though these are 'long pointers'
EndStructure
Global rWQF.tyWQF

;- for fmEditQI
;- tyWQI for fmEditQI
Structure tyWQI
  bInLogicalDevClick.i
  bInValidate.i
EndStructure
Global rWQI.tyWQI

;- for fmEditQL
;- tyWQL for fmEditQL
Structure tyWQL
  slblReqdNewLevel.s
  slblReqdNewPan.s
  bInValidate.i
  nLatestCuePtr.i
  nLatestSubPtr.i
  nAdjLevelNetInc.i
  bCallSetOrigReqdDBLevels.i
  fOrigReqdDBLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bLvlManualOverride.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bPanManualOverride.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
EndStructure
Global rWQL.tyWQL

;- TempoEtc (for freq, tempo, pitch)
Global grTempoEtc.tyTempoEtc

;- for fmEditQM
;- tyWQM for fmEditQM
Structure tyWQM
  bInValidate.i
  bInMsgTypeChange.i
  nSelectedCtrlSendRow.i
  nCurrentMsgType.i
  sSelectedLogicalDev.s
  nSelectedDevType.i
  rNRPNCapture.tyMidiIn
  Array sRemDevMsgTypeValue.s(0)
  nMaxRemDevMsgTypeValue.i
  nCntMidiOriginalHeight.i
  nCntRemDevOriginalHeight.i
  nGrdRemDevOriginalHeight.i
  bCboCtrlMidiRemoteDevPopulated.i
  bUseMidiContainerForNetwork.i ; Set #True for CSRD Network so that all the 'MIDI' fields will be available to CSRD Network Control Send devices
EndStructure
Structure tyWQMDevPopulated
  bCboCtrlMidiRemote.i
  bCboCtrlNetworkRemoteDev.i
EndStructure
Global grWQM.tyWQM
Global grWQMDevPopulated.tyWQMDevPopulated
Global grWQMDevPopulatedDef.tyWQMDevPopulated

;- for fmEditQP
;- tyWQP for fmEditQP
Structure tyWQP
  m_lBtnRow.i
  m_lBtnCol.i
  m_lBtnLeft.i
  m_lBtnTop.i
  m_lBtnRight.i
  m_lBtnBottom.i
  m_lDragRow.i
  m_lDragCol.i
  m_lDropRow.i
  m_lDropCol.i
  m_bDragCancel.i
  bInLogicalDevClick.i
  bInValidate.i
  nStartTrkNo.i
  nFileId.i     ; used for creating a unique id for entries in linked list WQPFile()
  nVisibleFiles.i
  nCurrentTrkNoHandle.i
  CompilerIf #c_include_mygrid_for_playlists
    nCurrentTrkRowNo.i
    nExtraRowNo.i ; row number of the extra row for a possible new entry (or entries) to be added - the row that initially just contains the "..." browse button
  CompilerElse
    nCurrentTrkNo.i
  CompilerEndIf
  nCurrPlayListIndex.i
  nAdjLevelNetInc.i
  bCallSetOrigDBLevels.i
  fOrigDBLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nStyleHeaderLeft.i
  nStyleHeaderCenter.i
  nStyleCellDisplayLeft.i
  nStyleCellDisplayCenter.i
  nStyleCellButton.i
  nStyleCellEditLeft.i
  nStyleCellHighlightCenter.i
  nStyleCellUnavailable.i
  nBrowseRow.i        ; used for passing parameter from WQP_btnBrowse_Click() to WQP_btnBrowse_ModReturn() after FileOpener has completed
  bBrowseAddingRow.i  ; ditto
EndStructure
Global rWQP.tyWQP

;- for fmEditQQ
;- tyWQQ for fmEditQQ
Structure tyWQQ
  nLastCallCueAction.i
EndStructure
Global grWQQ.tyWQQ

;- for fmEditQR
;- tyWQR for fmEditQR
Structure tyWQR
  nOpenOrRun.i
EndStructure
Global rWQR.tyWQR

;- for fmEditQS
;- tyWQS for fmEditQS
Structure tyWQS
  bInValidate.i
EndStructure
Global rWQS.tyWQS

;- for fmPrintCueList
;- tyWPR for fmPrintCueList
Structure tyWPR
  bCallResizeForm.i
  bFormLoading.i
  sPrintGridDefaultLayoutCol.s
EndStructure
Global rWPR.tyWPR

;- for fmScribbleStrip
;- tyWES for fmScribbleStrip
Structure tyWES
  nSubPtr.i
  nCtrlSendIndex.i
  nOldMsgType.i
  sCategory.s
  nMaxItem.i
  bScribbleStripChanged.i
  rScribbleStrip.tyScribbleStrip
EndStructure
Global grWES.tyWES

;- tyPrintOptions
Structure tyPrintOptions
  bChkA.i
  bChkE.i
  bChkF.i
  bChkG.i
  bChkI.i
  bChkJ.i
  bChkK.i
  bChkL.i
  bChkM.i
  bChkN.i
  bChkP.i
  bChkQ.i
  bChkR.i
  bChkS.i
  bChkT.i
  bChkU.i
  bIncludeHotkeys.i
  bIncludeSubCues.i
  bManualCuesOnly.i
EndStructure
Global grPrintOptions.tyPrintOptions

;- renumber cues (label change)
Global Dim gaCueLabelInfo.tyCueLabelInfo(0)
Global Dim gaSubCueLabelInfo.tySubCueLabelInfo(0)

;- MultiCueCopyEtc
Global grWMC.tyWMC
Global Dim gaCueMoveEtcInfo.tyCueMoveEtcInfo(0)

Global grMG2.tyMG   ; used by fmEditQF and associated routines
Global grMG3.tyMG   ; used for creating an image for an 'audio graph' progress slider
Global grMG4.tyMG   ; used by the slider graph loader thread
Global grMG5.tyMG   ; used by fmEditQA and associated routines (added 4Sep2023 11.10.0 for cue markers in video files)

;- tyGraph2
Structure tyGraph2
  nSliceST.i
  nSliceEN.i
  Array nSliceLS.i(#SCS_MAX_LOOP)
  Array nSliceLE.i(#SCS_MAX_LOOP)
  nSliceMaxLoop.i
  nSliceFI.i
  nSliceFO.i
  nSlicePos.i
  bInGraphScanFile.i
  bGraphVisible.i
EndStructure
Global grGraph2.tyGraph2

;- for fmVideo
;- tyWVN for fmVideo
Structure tyWVN
  bDragBarMoving.i
  nDragBarStartX.i
  nDragBarStartY.i
  nWindowStartLeft.i[#WV_LAST - #WV2 + 1]
  nWindowStartTop.i[#WV_LAST - #WV2 + 1]
EndStructure
Global grWVN.tyWVN

;- for fmMonitor
;- tyWMO for fmMonitor
Structure tyWMO
  bDragBarMoving.i
  nDragBarStartX.i
  nDragBarStartY.i
  nWindowStartLeft.i[#WM_LAST - #WM2 + 1]
  nWindowStartTop.i[#WM_LAST - #WM2 + 1]
EndStructure
Global grWMO.tyWMO

;- for fmNearEndWarning
;- tyWNE for fmNearEndWarning
Structure tyWNE
  nCaptionHeight.i
  nTimeHeight.i
  nBaseTimeHeight.i
  nBaseTimeWidth.i
  bRedoCaption.i
  bNearEndMoving.i
  bNearEndResizing.i
  nNearEndStartX.i
  nNearEndStartY.i
  nNearEndStartLeft.i
  nNearEndStartTop.i
  nNearEndStartWidth.i
  nNearEndStartHeight.i
  nDragBarCaptionCuePtr.i
  nDragBarCaptionSubPtr.i
  nDragBarCaptionTimeSetting.i ; eg #SCS_VWT_CUEPOS
  sDisplayTime.s
  nDisplayTime.i
  nCuePosTimeOffset.i
  bCheckWindowExistsAndVisible.i
  bFileVisualWarningTimeAvailable.i ; Added 30Sep2022 11.9.6
EndStructure
Global grWNE.tyWNE
Global grWCD.tyWNE
Global grWCL.tyWNE

;- for fmMTCDisplay
;- tyWTC for fmMTCDisplay
Structure tyWTC
  nCaptionHeight.i
  nTimeHeight.i
  nBaseTimeHeight.i
  nBaseTimeWidth.i
  bRedoCaption.i
  bMTCMoving.i
  bMTCResizing.i
  nMTCStartX.i
  nMTCStartY.i
  nMTCStartLeft.i
  nMTCStartTop.i
  nMTCStartWidth.i
  nMTCStartHeight.i
  nDragBarCaptionSubPtr.i
  sPreRollText.s
  sDisplayMTC.s
  bCheckWindowExistsAndVisible.i
  n16PixelsX.i
  n4PixelsY.i
  nCanvasWidth.i
  nCanvasHeight.i
  bFastDrawAvailable.i
  nTextLeft.i
  nTextTop.i
EndStructure
Global grWTC.tyWTC

;- for fmTimerDisplay
;- tyWTI for fmTimerDisplay
Structure tyWTI
  nCaptionHeight.i
  nTimeHeight.i
  nBaseTimeHeight.i
  nBaseTimeWidth.i
  bRedoCaption.i
  bTimerMoving.i
  bTimerResizing.i
  nTimerStartX.i
  nTimerStartY.i
  nTimerStartLeft.i
  nTimerStartTop.i
  nTimerStartWidth.i
  nTimerStartHeight.i
  nDragBarCaptionCuePtr.i
  sDisplayTime.s
  bCheckWindowExistsAndVisible.i
EndStructure
Global grWTI.tyWTI

;- for fmCollectFiles
Global grWPF.tyWPF

;- for fmLabelChange
;- tyWLC
Structure tyWLC
  sNewFirstCueLabel.s
  sRenumberIncrement.s
EndStructure
Global grWLC.tyWLC

;- for fmLoadProd
Global grWLP.tyWLP

;- for fmTemplates
Global grWTM.tyWTM

Global grAction.tyAction

Structure tyCollectOptions
  bCopyColorFile.i
  bExcludePlaylists.i
  bSwitchToCollected.i
  bIncludeDevMaps.i
EndStructure
Global grCollectOptions.tyCollectOptions

;- tyFileNotCopied
Structure tyFileNotCopied
  sCue.s
  sFileName.s
EndStructure
Global Dim gaFileNotCopied.tyFileNotCopied(0)

;- for fmCopyProps
;- tyCopyProps
Structure tyCopyProps
  nCFSubPtr.i
  sCFSubType.s
  nPropCount.i
  ; property code strings
  sPropsF.s  ; audio file sub-cue properties
  sPropsK.s  ; lighting properties
  sSelectedF.s
  sSelectedK.s
  sCopyTitle.s
  sCopyMsg.s
  nErrorCount.i
  nSuccessCount.i
EndStructure
Global grCopyProps.tyCopyProps

;- for fmImport
;- tyCueChange
Structure tyCueChange
  sOrigCue.s
  sNewCue.s
EndStructure
Global Dim aCueChange.tyCueChange(0)

;- tyWIM for fmImport
Structure tyWIM
  nCueChangePtr.i
  bImportingCues.i
EndStructure
Global grWIM.tyWIM

;- for fmImportCSV
Structure tyWICCue
  sCue.s
  sType.s ; as aSub()\sSubType, eg "F" for Audio File, "A" for Video/Image
  sCueDescr.s
  sPage.s
  sWhenReqd.s
  sSubDescr.s
  sFileName.s
  n2ndCuePtr.i
  n2ndSubPtr.i
EndStructure

;- tyWIC for fmImportCSV
Structure tyWIC
  sCSVFile.s
  nFileType.i
  sLogicalDev.s
  bNewCueNos.i
  nMSChannel.i
  nCueChangePtr.i
  sCuePrefix.s
  sDescrSplit.s
  nCueCount.i
  nFileNo.i
  Array aImportCue.tyWICCue(0)
  nMaxImportCue.i
EndStructure
Global grWIC.tyWIC

;- for fmImportDevs
;- tyWIDRowInfo
Structure tyWIDRowInfo
  nRow.i
  nRowType.i
  nDevGrp.i
  nDevNo.i
  sLogicalDev.s
  sDevMapName.s
  nDevMapForImportPtr.i
  bImported.i
  bUpdated.i
EndStructure

;- tyWID for fmImportDevs
Structure tyWID
  nMaxRowNo.i
  Array aRowInfo.tyWIDRowInfo(0)
EndStructure
Global grWID.tyWID

Global nCurrST, nCurrLS, nCurrLE, nCurrEN, nCurrPos

;- for fmFavFiles
;- tyWFF for fmFavFiles
Structure tyWFF
  nParentWindow.i
  bFavForPrimary.i
  bFavFileChanges.i
  maFavoriteFiles.tyFavoriteFile[#SCS_MAX_FAV_FILE+1]
EndStructure
Global grWFF.tyWFF

;- for fmFavFileSelector
;- tyWFF for fmFavFileSelector
Structure tyWFS
  bFavForPrimary.i
  maFavoriteFiles.tyFavoriteFile[#SCS_MAX_FAV_FILE+1]
EndStructure
Global grWFS.tyWFS

;- for fmProdTimer
;- tyWPT for fmProdTimer
Structure tyWPT
  bProdTimerForPrimary.i
  bProdTimerChanges.i
EndStructure
Global grWPT.tyWPT

;- for fmFileOpener
;- tyWFO for fmFileOpener
Structure tyWFO
  sType.s
  nExpListGadgetNo.i
  sFolder.s
  sFile.s
  sFullPathName.s
  bPlayEnabled.i
  bStopEnabled.i
  bDeviceEnabled.i
  bLevelEnabled.i
  bProgressEnabled.i
  bProgressManual.i
  bChangingLevel.i
  bLastFilePlayable.i
  nPosSliderMax.i
  ; the following are used in WFO_populateOwnCols() but are also cleared in WFO_Form_Show() to force WFO_populateOwnCols() to repopulate the list
  sOwnLastFolder.s
  nOwnLastExpListGadget.i
  ; the following are populated from and saved in preferences group "FileOpener"
  nSplitterPos.i
  rExpListInfo.tyGridInfo
  ; the following are for WFO_AddItem() and associated code, as suggested by RASHAD for including the Music library in the ExplorerTreeGadget
  tvi.TVITEM
  sBuffer.s
  sMyMusicPath.s
EndStructure
Global grWFO.tyWFO

;- for fmFileRename
;- tyWFR for fmFileRename
Structure tyWFR
  sCurrFileName.s
  bSelectWholeField.i
  sSubType.s
EndStructure
Global grWFR.tyWFR

;- for fmFind
;- tyWFI for fmFind
Structure tyWFI
  nParentWindow.i
  rFindItem.tyFind
  bFindOptionSet.i
  bAudVidOnly.i
  bFullPathNames.i
  nSelectedCuePtr.i
  ; grid column numbers (-1 = not displayed)
  nColCue.i
  nColPage.i
  nColMidiCue.i
  nColDescr.i
  nColFile.i
  nColWhenReqd.i
  nMaxColNo.i
EndStructure
Global grWFI.tyWFI

;- for fmInputRequester
;- tyWIR for fmInputRequester
Structure tyWIR
  nParentWindow.i
  nRequesterType.i
  nAction.i
EndStructure
Global grWIR.tyWIR

;- for VUDisdplay
Global Dim specbuf.b(0)
Global gbVUDisplayRunning
Global gbRefreshVUDisplay
Global gnVUBank
Global gnVUFirstChan
Global gnVULastChan
Global gnVUMeters
Global gnVUMaxMeters
Global gnVUInputMeters
Global gbClearVUB4Update

;- tyPeak
Structure tyPeak
  nPeakValue.i
  qPeakTime.q
EndStructure
Global grLiveInputTestLvlPeak.tyPeak

Global gnSelectedFileCount
Global gsSelectedDirectory.s
Global Dim gsSelectedFile.s(0)
Global gbPreviewPlaying
Global gbPreviewEnded

;- tyUndoGroup
Structure tyUndoGroup
  nUndoGroupId.i
  nPrimaryType.i            ; see UNDO_TYPE... constants (prod, sub, cue or aud)
  nPrimaryItemId.i          ; id of primary item (nProdId, nCueId, nSubId or nAudId)
  nPrimaryAction.i          ; see UNDO_ACTION... constants
  nPrimaryOldPtr.i          ; old ptr, eg CuePtr, if item has been moved (eg dragged) to a new position. -1 if there is no old item, eg this is an added cue.
  nPrimaryNewPtr.i          ; new or current ptr, eg cuePtr. -1 if there is no new item, eg this is a deleted cue, or if the value has not yet been set.
  nPrimarySubRef.i
  sPrimaryDescr.s           ; description for the undo/redo tooltip text
  nPrimaryExtraParam.i      ; extra parameter - initially included for 'drag cue'
  nSelectedNodeKey.i
  ; state of pointers on creation of the undo group. saved so that on cancelling the group we can recover the space used in the arrays.
  nStartUndoItemPtr.i
  nStartB4ProdPtr.i
  nStartB4CuePtr.i
  nStartB4SubPtr.i
  nStartB4AudPtr.i
  nStartAftProdPtr.i
  nStartAftCuePtr.i
  nStartAftSubPtr.i
  nStartAftAudPtr.i
EndStructure
Global Dim gaUndoGroup.tyUndoGroup(0)

;- tyUndoItem
Structure tyUndoItem
  nUndoItemId.i
  nUndoGroupId.i            ; parent undo group
  bCancelled.i              ; set True if vNew=Vold
  nItemType.i               ; see UNDO_TYPE... constants (prod, sub, cue or aud)
  nItemId.i                 ; id of item (nProdId, nCueId, nSubId or nAudId)
  nAction.i                 ; see UNDO_ACTION... constants
  nFlags.i                  ; see UNDO_FLAG... constants
  nOldPtr.i                 ; old ptr, eg CuePtr, if item has been moved (eg dragged) to a new position. -1 if there is no old item, eg this is an added cue.
  nNewPtr.i                 ; new or current ptr, eg cuePtr. -1 if there is no new item, eg this is a deleted cue, or if the value has not yet been set.
  bSecondaryChange.i        ; True if not the primary item of change. Secondary changes do not appear in the undo/redo lists.
  nSubRef.i
  nB4Ptr.i                  ; pointer to before image (or -1 if none)
  nAftPtr.i                 ; pointer to after image (or -1 if none)
  sDescr.s                  ; description for the undo/redo tooltip text
  nExtraParam.i             ; extra parameter - initially included for 'drag cue'
  ; vOld.VARIANT As Variant
  ; vNew.VARIANT As Variant
  vOld.tyVariant
  vNew.tyVariant
EndStructure
Global Dim gaUndoItem.tyUndoItem(0)
Global gvWork.tyVariant     ; work area for passing vOld/vNew through procedures
Global gbItemKnown

;- tyLastGroupInfo
Structure tyLastGroupInfo
  nCuePtr1.i
  nCuePtr2.i
  nSubPtr.i
  nAudPtr.i
  nUndoTypes.i
  nUndoFlags.i
EndStructure

;- tyB4Prod
Structure tyB4Prod
  nUndoItemId.i
  nUndoGroupId.i
  rProd.tyProd
EndStructure

;- tyB4DevChgs
Structure tyB4DevChgs
  nUndoItemId.i
  nUndoGroupId.i
  rProdForDevChgs.tyProd
EndStructure

;- tyB4Cue
Structure tyB4Cue
  nUndoItemId.i
  nUndoGroupId.i
  rCue.tyCue
EndStructure

;- tyB4Sub
Structure tyB4Sub
  nUndoItemId.i
  nUndoGroupId.i
  rSub.tySub
EndStructure

;- tyB4Aud
Structure tyB4Aud
  nUndoItemId.i
  nUndoGroupId.i
  rAud.tyAud
EndStructure

Global Dim gaB4ImageProd.tyB4Prod(0)
Global Dim gaB4ImageDevChgs.tyB4DevChgs(0)
Global Dim gaB4ImageCue.tyB4Cue(0)
Global Dim gaB4ImageSub.tyB4Sub(0)
Global Dim gaB4ImageAud.tyB4Aud(0)

Global Dim gaAftImageProd.tyB4Prod(0)
Global Dim gaAftImageDevChgs.tyB4DevChgs(0)
Global Dim gaAftImageCue.tyB4Cue(0)
Global Dim gaAftImageSub.tyB4Sub(0)
Global Dim gaAftImageAud.tyB4Aud(0)

;- for modUndoRedo
;- tyMUR
Structure tyMUR
  nUndoGroupPtr.i
  nMaxRedoGroupPtr.i
  nMaxRedoItemPtr.i
  nUndoItemPtr.i
  nUniqueUndoId.i
  nUniqueUndoGroupId.i
  nLatestUndoGroupIdAtSave.i     ; latest undo group id when file was last saved (this session)
  nCurrUndoGroupId.i
  nCurrUndoItemId.i
  nPrimaryUndoGroupId.i
  nSelectedItems.i
  nB4ProdPtr.i
  nB4DevChgsPtr.i
  nB4CuePtr.i
  nB4SubPtr.i
  nB4AudPtr.i
  nAftProdPtr.i
  nAftDevChgsPtr.i
  nAftCuePtr.i
  nAftSubPtr.i
  nAftAudPtr.i
  rPreserveCue.tyCue
  rPreserveSub.tySub
  rPreserveAud.tyAud
  sUndoRedo.s
EndStructure
Global grMUR.tyMUR

Global gbInUndoOrRedo.i
Global gqLastChangeTime.q

;- for fmBulkEdit
Global grWBE.tyWBE
Global Dim gaBulkEditItem.tyBulkEditItem(0)
Global grBulkEditItemDef.tyBulkEditItem

;- for fmOSCCapture
;- tyWOC for fmOSCCapture
Structure tyWOC
  nMaxColNo.i
  nOSCCmdType.i
  nItemCount.i
EndStructure
Global grWOC.tyWOC
;- tyOSCCaptureItem
Structure tyOSCCaptureItem
  nItemNo.i
  sItemDesc.s
  bIncluded.i
  nCaptureValue.i
  sCaptureValue.s
  bMute.i
EndStructure
Global Dim gaOSCCaptureItem.tyOSCCaptureItem(0)
Global grOSCCaptureItemDef.tyOSCCaptureItem

;- tyMVUD for VUDisplay.pbi
Structure tyMVUD
  nSpecWidth.i
  nSpecHeight.i
  fVolumeFactor.f     ; used in VU display
  nMaxBarWidth.i
  nMinBarWidth.i
  nMeterWidth.i
  nMaxVUDevLabelIndex.i
  nLabelCount.i
  nMeterGapWithinBar.i
  sMeterGapWithinBar.s
  bDisplayTriangles.i
  nTriangleHeight.i
  nTriangleWidth.i
  nTriangleXPosL.i
  nTriangleYPosL.i
  nTriangleXPosR.i
  nTriangleYPosR.i
  nTriangleColorL.i
  nTriangleColorR.i
  nBarWidth.i
  nXOffSet.i
  bInBuildDevChannelList.i
  bNoDeviceExists.i
  bTrianglesForVUBank.i
  bDrawOutputGainMarkers.i
  nMTCWidth.i
  bDevMapDisplayed.i
  bDevMapCurrentlyDisplayed.i
  qTimeDevMapDisplayed.q
  ; for SM-S
  nSMSFirstOutputIndex.i
  nSMSLastOutputIndex.i
  nSMSVUMeters.i
  nSMSVUInputMeters.i
  ; VU meters
  Array aBar.tyVUBar(0)
  Array aMeter.tyVUMeter(0)
  nBarCount.i
  nMeterCount.i
  nMaxBar.i
  nMaxMeter.i
EndStructure
Global grMVUD.tyMVUD

;- network variables
Global gnServerEvent
Global gnEventServer
Global gnEventClient
Global gnClientEvent
Global Dim gaNetworkControl.tyNetworkControl(0)
Global gnMaxNetworkControl
Global grNetworkControlDef.tyNetworkControl
Global gbNetworkStarted
Global Dim gaNetworkIns.tyNetworkIn(100)
Global gnNetworkInCount
Global gbNetworkInLocked
Global gnNetworkCurrentIndex
Global gbReadingNetworkMessage
Global gnNetworkCueControlPtr
Global gnNetworkServersActive
Global gnNetworkClientsActive
Global gnNetworkResponseCount
Global grX32CommandDef.tyX32Command
Global grX32CueControl.tyX32CueControl
Global grOSCMsgData.tyOSCMsgData
Global grOSCMsgDataDef.tyOSCMsgData
Global *gmNetworkSendBuffer
Global *gmNetworkInputBuffer
Global gnNetworkInputLength
Global *gmNetworkReceiveBuffer
Global gnNetworkBytesReceived
Global gnNetworkBytesProcessed
Global grSendWhenReadyDef.tySendWhenReady
Global *gmSLIPDatagram
Global gnSLIPDatagramLength

;- UDP variables
Global gnUDPReceiveTimeOut = 1500

;- remote app interface variables
Global grRAI.tyRAI

;- functional mode backup instance variables
Global Dim gaFMBackup.tyFMBackup(0)
Global gnLastFMBackup = -1
Global gnFMUniqueMsgId

;- HTTP variables
Global grHTTPControl.tyHTTPControl

;- devmap globals
Global grMaps.tyMaps ; device maps for grProd
Global grMapsForDevChgs.tyMaps
Global grMapsForImport.tyMaps
Global grMapsForChecker.tyMaps ; nb checker will actually only use on device map as this global will be used for checking that the selected device map is valid
Global grDevMapDef.tyDevMap
Global grDevMapDevDef.tyDevMapDev
Global grLiveGrpDef.tyLiveGrp

Global grMsgResponse.tyNetworkMsgResponse
Global gnPluginMapFileBuildDate

Global Dim gsDevMapLine.s(0)
Global gnDevMapLineCount
Global grDevMapCheck.tyDevMapCheck
Global grDevMapCheckDef.tyDevMapCheck
Global grDevMapCheckForSetIgnoreDevInds.tyDevMapCheck
Global gsCheckDevMapMsg.s

; Added 11Nov2022 11.9.7ae
Global Dim gaDevMapForBestMatch.tyDevMap(20)
Global Dim gaDevForBestMatch.tyDevMapDev(0)
Global Dim gaLiveGrpForBestMatch.tyLiveGrp(0)
Global gnLastLiveGrpForBestMatch = -1
Global gnLastDevForBestMatch = -1
Global gnDevMapForBestMatchCount
Global gnMaxDevMapForBestMatchPtr
Global gsDevMapFileSelectedDevMap.s
Global gsDevMapFileSaved.s
Global gbSCSDefaultDevsOnly.i
; End added 11Nov2022 11.9.7ae

Global gbDelayTimeAvailable

;- control send thread items
Global Dim gaCtrlSendThreadItem.tyCtrlSendThreadItem(0)
Global gnMaxCtrlSendThreadItem = -1
Global grCtrlSendSubData.tyCtrlSendSubData
Global grCtrlSendSubDataDef.tyCtrlSendSubData
Global grCtrlSendDef.tyCtrlSend

Global Dim gsXMLNodeName.s(20)

;- cue panels
Global grCuePanels.tyCuePanels
Global grCuePanelsInitValues.tyCuePanels
; gaDispPanel(h)\nDPCuePtr etc are populated for ALL gaDispPanel() entries in PNL_loadDispPanels() to identify the cue etc to be displayed in each cue panel.
; However, the gaPnlVars(h) entry is not reloaded until loadOneDispPanel(h) is called, which may have been deferred for performance reasons.
Global Dim gaDispPanel.tyDispPanel(0)
Global Dim gaPnlVars.tyPnlVars(0)
Global grPnlVarsDef.tyPnlVars
Global grDispPanelDef.tyDispPanel
; The array gaDisplayable() is populated in PNL_loadDispPanels(), every time the procedure is called, and is populated with every sub-cue that is still to be displayed, ie
; non-completed sub-cues. Playlist and video file sub-cues may have two entries as they may have two panels displayed (if there are two or more aud's still to be played).
Global Dim gaDisplayable.tyDisplayable(0)

;- toolbar arrays
Global Dim gaToolBar.tyToolBar(#SCS_TBZ_DUMMY_LAST)
Global Dim gaToolBarCat.tyToolBarCat(#SCS_TBZC_DUMMY_LAST)
Global Dim gaToolBarBtn.tyToolBarBtn(#SCS_TBZB_DUMMY_LAST)

; toolbar colors
Global grToolBarColors.tyToolBarColors

;- key events
Global Dim gaKeyEvent.tyKeyEvent(500)
Global gnMaxKeyEvent = -1

;- image log
Global Dim gaImageLog.tyImageLog(100)
Global gnMaxImageNo = 0

;- DMX handling globals
Global grDMX.tyDMX
Global grUSBPRO.tyUSBPRO
Global Dim gaDMXDevice.tyDMXDevice(0)
Global Dim gaDMXControl.tyDMXControl(0)
Global grDMXControlDef.tyDMXControl
Global grDMXCommandDef.tyDMXCommand
Global grDMXChannelItemsDef.tyDMXChannelItems ; deleted 28May2021 11.8.5 following bug report from Dave Jenkins
Global grDMXRefreshControl.tyDMXRefreshControl
Global grDMXMasterFader.tyDMXMasterFader
Global *gmDMXReceiveBuffer
Global *gmDMXPacket ; DMX packet (label=5) saved during DMX capture - see Procedure DMX_SaveDMXPacket()
Global Dim gbDMXChannelMonitored.a(512) ; 0 not used, 1-512 = DMX channel to be monitored
; the following DMX arrays may be redimensioned in DMX_redimDMXArraysIfRequired() if more than one DMX universe is required
Global Dim gaDMXSendData.a(512) ; index 0 = start code, 1-512 = values for channels 1-512
Global Dim gbDMXDimmableChannel.a(512)
Global Dim gaDMXSendOrigin.a(512)
; ditto for arrays in the following structures
Global grDMXChannelItems.tyDMXChannelItems
Global grDMXFadeItems.tyDMXFadeItems
Global Dim gaDMXPreHotkeyData.tyDMXPreHotkeyData(0)
Global grDMXPreHotkeyDataDef.tyDMXPreHotkeyData
Global Dim gnDMXTextColorsZero.l(512)     ; Array for the text colors in the DMX Grid for the 'Universe (all 512 channels)' option, where the DMX value is zero
Global Dim gnDMXTextColorsNonZero.l(512)  ; Array for the text colors in the DMX Grid for the 'Universe (all 512 channels)' option, where the DMX value is non-zero

Global gnMaxChaseStep
Global grDMXChaseItems.tyDMXChaseItems

Global grMemoryPrefs.tyMemoryPrefs

Global DMX_OUT.Struct_SEND_DMX  ; contains dmx to send
Global DMX_IN.Struct_RECV_DMX ; contains dmx received
Global PRO_INFO.Struct_GET_CFG  ; received config info
Global PRO_CONFIG.Struct_SET_CFG  ; used to set widget config
Global DMXIN_MODE.Struct_DMX_INPUT_MODE ; used to set the widget into receive updates only mode
Global DMXIN_Changes.Struct_DMX_ChangeOfState ; used to store a change of state message to decode (input update mode)
Global Header.Struct_Header ; a temp header structure
Global FIRMWARE_PAGE.Struct_SEND_Firmware_Page  ; for firmware re-programming
Global FIRMWARE_PAGE_REPLY.Struct_Firmware_Page_Success

Global Dim gaDMXIns.tyDMXIn(200)
Global grChaseStepDef.tyLTChaseStep
Global grLTSubFixtureDef.tyLTSubFixture
Global grDMXSendItemDef.tyDMXSendItem
Global grLTFixChanDef.tyLTFixtureItemChannel
Global grDMXValueInfo.tyDMXValueInfo ; used for validating and converting DMX display values

Global grDMXReceiveDataCapture.tyDMXCapture ; populated by DMX_FTDI_ReceiveData() to pass info not otherwise returned in 
Global Dim gaDMXCapture.tyDMXCapture(0) ; array of DMX 'Change of State' packets as received during the DMX Capture process when editing a Lighting Cue
Global Dim gaDMXCaptureItem.tyDMXCaptureItem(0)

;- for Knob.pbi
Global Dim _Knob.tyKnob(7)
Global _BkRGB = $55

;- ETC Import
Global grETCImport.tyETCImport

;- temp database
Global grTempDB.tyTempDB
Global grFileBlobInfo.tyFileBlobInfo
Global *gmFileBlob
Global grSldrBlobInfo.tySldrBlobInfo
Global *gmSldrBlob
Global grImageBlobInfo.tyImageBlobInfo
Global *gmInitGraphImage

;- vMix
CompilerIf #c_vMix_in_video_cues
Global grvMixControl.tyvMixControl
Global grvMixInputInfo.tyvMixInputInfo
Global grvMixInfo.tyvMixInfo
CompilerEndIf

;- TVG
Global Dim *gmVideoGrabber(0)
Global Dim gaTVG.tyTVG(0)
Global grTVGDef.tyTVG
Global grTVGControl.tyTVGControl

;- connected devices
Global Dim gaConnectedDev.tyConnectedDev(10) ; will be resized if required
Global grConnectedDevDef.tyConnectedDev
Global gnMaxConnectedDev = -1

;- aggregate times
Global grAggregateTimes.tyAggregateTimes

; Cue Markers
Global Dim gaCueMarkerInfo.tyCueMarkerInfo(0)
Global gnMaxCueMarkerInfo
Global Dim gaOCMMatrix.tyOCMMatrixItem(0)
Global gnMaxOCMMatrixItem
Global Dim gaCueMarkerFile.tyCueMarkerFile(0)
Global gnMaxCueMarkerFile

Global grFMOptions.tyFMOptions
Global mrFMOptions.tyFMOptions ; module level

Global NewList CtrlHoldLevelPoints.tyCtrlHoldLevelPoint()  

Global grMixer.tyMixer

;- CSRD (Ctrl Send Remote Device)
Global grCSRD.tyCSRD
Global grCurrScribbleStrip.tyScribbleStrip
; Defaults
Global gaCSRDLangItem_Def.tyCSRD_LangItem
Global gaCSRDRemDev_Def.tyCSRD_RemDev
Global gaCSRDValidValue_Def.tyCSRD_ValidValue
Global gaCSRDFaderData_Def.tyCSRD_FaderData
Global gaCSRDRemDevMsgData_Def.tyCSRD_RemDevMsgData

;- Animated Images (eg animated GIFs)
; only populated when an animated image is displayed
Global Dim gaAnimImage.tyAnimImage(0)
Global gnMaxAnimImage
Global grAnimImageDef.tyAnimImage

; fixtures
Global grFixTypeChanDef.tyFixTypeChan
Global grFixturesRunTime.tyFixturesRunTime

; Artnet
Global gnArtnetPort.i = #ARTNET_PORT
Global *gpArtnetRxBuffer
Global *gpArtnetTxBuffer
Global *gpArtnetMyDmx
Global gsArtnetId.s
Global gnArtnetOpcode.c
Global gnArtnetProtVer.c
Global gnArtnetServerEvent.i
Global ghArtnetClientId.i
Global gnArtnetQuitThread.i = 0
Global gnArtnetsequence.a
Global gnArtnetphysical.a
Global gnArtnetlength.c
Global Dim gnMyipf(4)                                              ; 0-3 + a null
Global Dim gnArtnetsequenceOut.a(#ARTNET_MAX_UNIVERSES)            ; each universe needs it's own sequence number
Global Dim gnArtnetUniversesLookup.c(#ARTNET_MAX_UNIVERSES)        ; array for storing the actual universes numbers
Global gnArtnetUniverse.c
Global ghArtnetMutex.i = CreateMutex()
Global ghArtnetThreadId.i
Global gsArtnetIpToBindTo.s
Global gsArtnetBroadcastIp.s
Global NewMap artnetTimers_m.ArtnetTimers_t()                     ; store the timers in a map
Global NewList artnetDmxSend_l.artnetDmxData_t()
Global NewList artnetPollReplies_l.artnetPollReplies_t()
Global gn_ArtnetActive.a
Global gnArtnetHandle.i
Global smArtnetRxSemaphore = CreateSemaphore()
Global ghArtnetRxMutex = CreateMutex()
Global NewList ghArtnetRxList.artnetRxBuffers_t()

; sACN
Global gh_sACNLib.i
Global sACNStart                                                  ; global define for the dll functions
Global sACNSendDmxData                                            ; global define for the dll functions
Global sACNEnd                                                    ; global define for the dll functions
Global sACNDmxTxBuffer                                            ; global define for the dll functions
Global sACNDmxRxBuffer                                            ; global define for the dll functions
Global sACNDmxRxSize                                              ; global define for the dll functions

Global NewMap gm_sACnActive.a()
Global gnDmxValue.a
Global gn_sACNIp
Global *gp_sACNBuffer
Global gs_sACNIpToBindTo.s

; These names are the function names from the sACN.dll, they must come after the global defines. sACN.dll is written in C
PrototypeC.i sACNInit(sMyn_sACNIp.l, cUniverse.c)                  ; Initialise sACN, we pass in the n_sACNIp of the interface we are using to send sACN
PrototypeC.i sACNTxDmx(cUniverse.c)                                ; Does what it says on the tin
PrototypeC.i sACNClose(cUniverse.c)                                ; Close and finish sACN
PrototypeC.i sACNGetDmxTxBuffer(cUniverse.c)                       ; Get a pointer to the DMX TX buffer, we fill the buffer and then call sACNProcessDMX()
PrototypeC.i sACNGetDmxRxBuffer(cUniverse.c)                       ; Get a pointer to the DMX RX buffer
PrototypeC.i sACNgetDmxRxSize(universe.c)                          ; Gets the Rx byte size, -1 = an error 

;**************************** SETUP CPU %LOAD USAGE  *************************

Global CPUTimeMutex = CreateMutex()
Global qIdletime1.FILETIME, qkerneltime1.FILETIME, qusertime1.FILETIME
Global qIdletime2.FILETIME, qkerneltime2.FILETIME, qusertime2.FILETIME
Global qIdle1.q, qKernel1.q, qUser1.q, qIdle2.q, qKernel2.q, qUser2.q
Global kernel32Lib
Prototype GetSystemTimes(*lpIdleTime, *lpKernelTime, *lpUserTime )        ; Uses stdcalling, most internal windows API calls use stdcalling not C calling
Global GetSystemTimes.GetSystemTimes 
Global fCpuUsage.f

;************************* READ THE WINDOWS gpu COUNTERS  ********************

Global glib_GetGPUUsage
Global gfn_GetGPUUsageActivate
Global gfn_GetGPUUsageDeactivate
Global gfn_GetGPUUsagePercentage
Global gfn_GetTotalMemoryUsage
Global gpuRarr_DisplayParamsResults.d
Global gpuResult.i
Global Event
Global th_ReadGPUPercent
Global nStopGPUThread

PrototypeC.i activateGPUpercentage()
PrototypeC deactivateGPUpercentage()
PrototypeC.d getGPUpercentage()
PrototypeC.d getTotalMemoryUsage()


; SCS_LTC

; Prototypes for LTC based on the provided C functions

PrototypeC.i pt_ltc_frame_to_time(*stime, *decoder, flags.i, *frame)
PrototypeC.i pt_ltc_time_to_frame(*frame, *stime, standard.i, flags.i)
PrototypeC.i pt_ltc_frame_reset(*frame)
PrototypeC.i pt_ltc_frame_increment(*frame, fps.i, standard.i, flags.i)
PrototypeC.i pt_ltc_frame_decrement(*frame, fps.i, standard.i, flags.i)
PrototypeC.i pt_ltc_decoder_create(apv.i, queue_size.i)
PrototypeC.i pt_ltc_decoder_free(*d)
PrototypeC.i pt_ltc_decoder_write(*d, *buf, size.i, posinfo.q)
PrototypeC.i pt_ltc_decoder_write_double(*d, *buf, size.i, posinfo.q)
PrototypeC.i pt_ltc_decoder_write_float(*d, *buf, size.i, posinfo.q)
PrototypeC.i pt_ltc_decoder_write_s16(*d, *buf, size.i, posinfo.q)
PrototypeC.i pt_ltc_decoder_write_u16(*d, *buf, size.i, posinfo.q)
PrototypeC.i pt_ltc_decoder_read(*d, *frame)
PrototypeC.i pt_ltc_decoder_queue_flush(*d)
PrototypeC.i pt_ltc_decoder_queue_length(*d)
PrototypeC.i pt_ltc_encoder_create(sample_rate.d, fps.d, standard.i, flags.i)
PrototypeC.i pt_ltc_encoder_free(*e)
PrototypeC.i pt_ltc_encoder_set_timecode(*e, *t)
PrototypeC.i pt_ltc_encoder_get_timecode(*e, *t)
PrototypeC.i pt_ltc_encoder_set_user_bits(*e, eData.l)
PrototypeC.i pt_ltc_frame_get_user_bits(*f)
PrototypeC.i pt_ltc_encoder_inc_timecode(*e)
PrototypeC.i pt_ltc_encoder_dec_timecode(*e)
PrototypeC.i pt_ltc_encoder_set_frame(*e, *f)
PrototypeC.i pt_ltc_encoder_get_frame(*e, *f)
PrototypeC.i pt_ltc_encoder_get_buffer(*e, *buf)
PrototypeC.i pt_ltc_encoder_copy_buffer(*e, *buf)
PrototypeC.i pt_ltc_encoder_get_bufptr(*e, *size, flush.i)
PrototypeC.i pt_ltc_encoder_get_bufferptr(*e, *buf, flush.i)
PrototypeC.i pt_ltc_encoder_buffer_flush(*e)
PrototypeC.i pt_ltc_encoder_get_buffersize(*e)
PrototypeC.i pt_ltc_encoder_reinit(*e, sample_rate.d, fps.d, standard.i, flags.i)
PrototypeC.i pt_ltc_encoder_reset(*e)
PrototypeC.i pt_ltc_encoder_set_bufsize(*e, sample_rate.d, fps.d)
PrototypeC.i pt_ltc_encoder_set_buffersize(*e, sample_rate.d, fps.d)
PrototypeC.i pt_ltc_encoder_get_volume(*e)
PrototypeC.i pt_ltc_encoder_set_volume(*e, dBFS.d)
PrototypeC.i pt_ltc_encoder_get_filter(*e)
PrototypeC.i pt_ltc_encoder_set_filter(*e, rise_time.d)
PrototypeC.i pt_ltc_encoder_encode_byte(*e, byte.i, speed.d)
PrototypeC.i pt_ltc_encoder_encode_frame(*e)
PrototypeC.i pt_ltc_encoder_encode_reversed_frame(*e)
PrototypeC.i pt_ltc_encoder16_copy_buffer(*e, *buf)
PrototypeC.i pt_ltc_encoder32_copy_buffer(*e, *buf)

; Globals

Global LTC_Years.s    
Global LTC_Months.s    
Global LTC_Days.s    
Global LTC_Timezone.s
Global LTC_Hours.s    
Global LTC_Mins.s    
Global LTC_Secs.s    
Global LTC_Dfbit.s    
Global LTC_Frame.s    
Global LTC_OffStart.s    
Global LTC_OffEnd.s    
Global LTC_Reverse.s    
Global LTCDecode.i
Global LTCEncode.i

; LTC DLL calls

Global ltc_decoder_create.pt_ltc_decoder_create
Global ltc_decoder_write.pt_ltc_decoder_write
Global ltc_frame_to_time.pt_ltc_frame_to_time
Global ltc_decoder_free.pt_ltc_decoder_free
Global ltc_encoder_create.pt_ltc_encoder_create
Global ltc_encoder_set_buffersize.pt_ltc_encoder_set_buffersize
Global ltc_encoder_reinit.pt_ltc_encoder_reinit
Global ltc_encoder_set_filter.pt_ltc_encoder_set_filter
Global ltc_encoder_set_volume.pt_ltc_encoder_set_volume
Global ltc_encoder_set_timecode.pt_ltc_encoder_set_timecode
Global ltc_encoder_get_timecode.pt_ltc_encoder_get_timecode
Global ltc_encoder_get_bufferptr.pt_ltc_encoder_get_bufferptr
Global ltc_encoder_copy_buffer.pt_ltc_encoder_copy_buffer
Global ltc_encoder_encode_frame.pt_ltc_encoder_encode_frame
Global ltc_encoder_inc_timecode.pt_ltc_encoder_inc_timecode
Global ltc_encoder_free.pt_ltc_encoder_free
Global ltc_encoder16_copy_buffer.pt_ltc_encoder16_copy_buffer
Global ltc_encoder32_copy_buffer.pt_ltc_encoder32_copy_buffer

; SCSLTC globals

Global *LTCFrame.LTCFrameExternal
Global *ltcStimeDecoder.SMPTETimecode
Global *ltcStimeEncoder.SMPTETimecode
Global *ltcDecoder.LTCDecoder
Global *ltcEncoder.LTCEncoder
Global NewMap map_ScsLTCGenerators.scsLTCTDevice_t()
Global gLTCSmpteEncoder.SMPTETimecode
Global gnAScsLTCQuitThread.i
Global gn_ScsLTCAllowed                               ; This gets set when  grLicInfo\bLTCAvailable = 1 and grSMS\nSMSClientConnection = 0 (non zero if the SMSnetwork has connected)
Global mtx_ScsLTCMutex = CreateMutex()
Global mtx_ScsLTCMutexCmdList = CreateMutex()
Global NewList list_ScsLTCQueue.scsLTCCommandData_t()

; Added by Dee 03/04/2025 When the Usercolumnx has been reset if you return to Options it will reload the altered Lang text, these flags prevent that from happening.
Global gnUserColumnReset1.i
Global gnUserColumnReset2.i
Global gnuserColumnChanged1.i
Global gnuserColumnChanged2.i
Global gsUsercolumnOriginal1.s
Global gsUsercolumnOriginal2.s

Global useAesEncryption

; Added by Mike 15May2025 primarily for enhacned network OSC control send support for X32
Global grOSCCtrlSendItemsForDev.tyOSCCtrlSendItemsForDev
Global grOSCCtrlSendItemsForDevDef.tyOSCCtrlSendItemsForDev

; EOF
