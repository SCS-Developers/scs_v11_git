; File: Structures.pbi

EnableExplicit

XIncludeFile "bass.pbi"             ; only included because a structure requires a BASS structure

;- DMX handling structures
;- Struct_Header
Structure Struct_Header
  Delim.a       ; should be equal to SOM StartOfMessage
  byLabel.a     ; message type
  nLength.w     ; data field length (two bytes) 0..600
EndStructure

; dmx out structure
;- Struct_SEND_DMX
Structure Struct_SEND_DMX
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes
  ; Length As Byte ' data field length (two bytes) 0..600
  ascData.a[513] ; dmx data, including the startcode
  EOMChar.a         ; added by MJD
EndStructure

;- Struct_RECV_DMX
Structure Struct_RECV_DMX
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes  ; packet head
  status.a            ; 0 = OK, otherwise Bit 0 = queue overflow, Bit 1 = overrun occurred
  ascData.a[513]      ; received dmx, including the startcode
  EOMChar.a           ; added by MJD
EndStructure

; dmx input mode structure - sent to widget to set dmx receive mode
;- Struct_DMX_INPUT_MODE
Structure Struct_DMX_INPUT_MODE
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes ; packet head
  mode.a  ; 0 receive full dmx packets, 1 receive update packets
  EOMChar.a         ; added by MJD
EndStructure

; received from widget when in dmx input update only mode
;- Struct_DMX_ChangeOfState
Structure Struct_DMX_ChangeOfState
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes
  byStart.a           ; channel to start at
  Bitfield.a[5]       ; 5 bytes channels which changed
  ascData.a[40]       ; the channels data
  EOMChar.a           ; added by Dee
EndStructure

; used to request the widget's config
;- Struct_REQUEST_CFG
Structure Struct_REQUEST_CFG
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes
  UserDataLength.w ; length of user data to return
  EOMChar.a        ; added by MJD
EndStructure

; configuration info returned by widget
;- Struct_GET_CFG
Structure Struct_GET_CFG
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes
  Firmware_VersionL.a
  Firmware_VersionH.a
  BreakTime.a               ; 9..127 in 10.67us units
  MarkAfterBreak.a          ; 1..127 in 10.67us units
  FrameRate.a               ; frames sent per second, 1..40
  UserData.a[#ENTTEC_USER_DATA_SIZE]
  ; user data area...
  EOMChar.a         ; added by MJD
EndStructure

; set widget configuration
;- Struct_SET_CFG
Structure Struct_SET_CFG
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes       ; packet head
  DataLength.w             ; set length of data area, two bytes, LSB first 0..508
  BreakTime.a              ; 9..127 in 10.67us units
  MarkAfterBreak.a         ; 1..127 in 10.67us units
  FrameRate.a              ; frames sent per second, 1..40
  EOMChar.a         ; added by MJD
EndStructure

;- Struct_SET_RECV_ON_CHG
Structure Struct_SET_RECV_ON_CHG
  Head.Struct_Header  ; 1 + 1 + 2 = 4 bytes      ; packet head
  mode.a                  ; 0 send always, 1 send on data change only
  EOMChar.a
EndStructure

;firmware page structure
;- Struct_SEND_Firmware_Page
Structure Struct_SEND_Firmware_Page
  Delim.a          ; should be equal to SOM StartOfMessage
  byLabel.a        ; message type
  length.w         ; Byte ' data field length (two bytes) 0..600
  ascData.a[64]     ; firmware page data
  EOMChar.a
EndStructure

;firmware page structure
;- Struct_Firmware_Page_Success
Structure Struct_Firmware_Page_Success
  Delim.a          ; should be equal to SOM StartOfMessage
  byLabel.a        ; message type
  length.w         ; data field length (two bytes) 0..600
  ascData.a[4]      ; TRUE or FALSE
  EOMChar.a
EndStructure

;- tyLanguage
Structure tyLanguage
  sLangCode.s
  sLangName.s
  sCreator.s
  sFilename.s
EndStructure

Structure LangConfig
  sLangCode.s
  sLangName.s
  sCreator.s
  sFilename.s
EndStructure

Structure tyLanguageGroup
  sName.s
  iGroupStart.i
  iGroupEnd.i
  aIndexTable.i[256]    ; 256 = number of characters in the ASCII character set. For unicode characters with Asc() > 255, use the last element
EndStructure

Structure LanguageEntry
  Key.s
  ShortText.s
  LongText.s
EndStructure

;- tyLevels GLOBAL AUDIO LEVELS
Structure tyLevels
  ; maximum level
  sMaxDBLevel.s ; maximum dB level as a string, eg "0" or "12"
  nMaxDBLevel.i ; the integer equivalent, eg 0 or 12
  fMaxBVLevel.f ; the 'BASS Volume' (BASS_ATTRIB_VOL) equivalent - see convertDBLevelToBVLevel()
  
  ; minimum level (ie the level below which SCS treats the level as -INF, ie silent)
  sMinDBLevel.s ; minimum dB level as a string, eg "-75", "-120" or "-160"
  nMinDBLevel.i ; the integer equivalent, eg -75, -120 or -160
  fMinBVLevel.f ; the 'BASS Volume' (BASS_ATTRIB_VOL) equivalent - see convertDBLevelToBVLevel()
  nMinRelDBLevel.i
  
  ; default level for new Audio File Cues, etc
  sDefaultDBLevel.s
  
  ; 12dB
  f12BVLevel.f
  ; 0dB
  sZeroDBLevel.s ; = "0.0dB" or "0,0dB"
  fZeroBVLevel.f
  ; +0dB
  sPlusZeroDB.s ; = "+0.0dB" or "+0,0dB"
  fPlusZeroBV.f
  ; silent
  fSilentBVLevel.f
  
  bSMSUseGainMidi.i ; indicates if SMS can use 'gain'
  
EndStructure

;- tySMS
Structure tySMS
  nSMSClientConnection.i
  nConnectionTimeOut.i
  nLogFile.i
  sLogFile.s
  sServerName.s
  nPortNo.i
  nResponseLineCount.i
  sFirstWordLC.s            ; first word of response in lower case (eg "ok", not "OK")
  sFirstLine.s
  qSendTime.q
  qReceiveTime.q
  rSendTime.SYSTEMTIME
  rReceiveTime.SYSTEMTIME
  sPStatusCommandString.s
  sPTimeCommandString.s
  sPXGainCommandString.s
  sOVUCommandString.s
  bVUCommandStringChanged.i
  sPStatusResponse.s
  sPTimeResponse.s
  sPXGainResponse.s
  sOVUResponse.s
  sTcGenResponse.s
  bInterfaceOpen.i
  bEncFilesIndexLoaded.i
  qPStatusResponseReceived.q
  qPTimeResponseReceived.q
  nSMSGroup.i ; used for 'set group ...' commands. Group numbers are in the range 0-127, although use 1-127 as 0 throws an error in SM-S 1.0.144
  nSMSTimeCodeChan.i
  ; the following set by setTrackTimesCommandStrings():
  nMainCount.i
  sTrackTimesCommandString.s
  sAltTrackTimesCommandString.s
  sTrackRepeatOffCommandString.s
  bLTCRunning.i
  sGetTimeCodeCommandString.s
EndStructure

;- tySMSTCGenerator
Structure tySMSTCGenerator
  ; SM-S Timecode Generator
  sTCChannel.s    ; SM-S channel number for a timecode generator, range: P1000 - P1007
  nSubPtr.i       ; ptr to SubTypeU that this generator is currently assigned to (-1 if not assigned)
  sTCGainCommand.s
  sTCMuteCommand.s
EndStructure

;- tyProgVersion
Structure tyProgVersion
  sBuildDateTime.s
  sCopyRight.s
  nBuildDate.i  ; 'build date' can be used for sub-version-specific change control
EndStructure

;- tyThread
Structure tyThread
  hThread.i
  nThreadSubState.i       ; Thread sub status, e.g. starting, running, stopping. See #SCS_THREAD_SUB_STATE_xxxx
  nThreadMutex.i
  nThreadState.i
  nThreadPriority.i
  bThreadCreated.i
  bStopASAP.i
  bStopRequested.i
  bSuspendRequested.i
EndStructure

;- tyThreadMutexInfo
Structure tyThreadMutexInfo
  nLockStatus.i
  ; qStatusTime.q           ; if nLockStatus non-zero then nStatusTime is the time of the last change to nLockStatus
  nLockNoForRequest.i     ; lock number of last lock request
  nLockNoForLock.i        ; lock number of last successful lock
  qRequestTime.q
  qLockTime.q
  qUnlockTime.q
  bSuspendTimeoutCheck.i  ; set by THR_suspendMutexLockTimeoutChecks() which is called by scsMessageRequester() to prevent a mutex timeout occuring dues to the mutex being locked while waiting for the user.
                          ; cleared on the next lock or unlock request, or on the next successful trylock request.
EndStructure

;-POINTAPI
Structure POINTAPI
  X.i
  Y.i
EndStructure

;- tyXY
Structure tyXY
  X.i
  Y.i
EndStructure

;- tyVariant
; structure to simplify conversion of VB6 variants, especially for undo/redo
Structure tyVariant
  nVarType.i
  ; StructureUnion
  sVar.s
  lVar.i
  fVar.f
  dVar.d ; Added 19Jul2022
  ; EndStructureUnion
EndStructure

;- tyWindow
Structure tyWindow
  sPrefKey.s
  bPositionSet.i
  bSizeSet.i
  bMaximized.i
  nLeft.i
  nTop.i
  nWidth.i
  nHeight.i
  nCenteredLeft.i
  nCenteredTop.i
EndStructure

;- tyModalWindowInfo
Structure tyModalWindowInfo
  bWindowCreated.i
  bEnabled.i
EndStructure

;- tyDesktop
Structure tyDesktop
  nDesktopIndex.i
  nDesktopLeft.l
  nDesktopTop.l
  nDesktopWidth.l
  nDesktopHeight.l
  qSortKey.q
  qSortKey2.q     ; Added 10May2021 11.8.4.2ba
  nDeskTopOrder.i ; Added 10May2021 11.8.4.2ba
EndStructure

;- tyMonitor
Structure tyMonitor
  nDisplayNo.i
  nDesktopIndex.i
  nDesktopLeft.l
  nDesktopTop.l
  nDesktopWidth.l
  nDesktopHeight.l
  nDeskTopOrder.i ; Added 10May2021 11.8.4.2ba
  nMonitorBoundsLeft.l
  nMonitorBoundsTop.l
  nMonitorBoundsRight.l
  nMonitorBoundsBottom.l
  nMonitorBoundsWidth.l
  nMonitorBoundsHeight.l
  nDisplayScalingPercentage.l
  fCumulativeDisplayScalingFactor.f
  nTVGDisplayMonitor.l
  nTVGDisplayLeft.l
  nTVGDisplayTop.l
  nTVGDisplayWidth.l
  nTVGDisplayHeight.l
EndStructure

;- tySplitScreenInfo
Structure tySplitScreenInfo
  ; nb the 'primary key' is nDisplayNo + sRealScreenSize
  ; the display no. is included because a user could have multiple 'real' screens with the same resolution (possibly including the primary screen)
  ; and we need to uniquely identify each of these screens
  nDisplayNo.i
  sRealScreenSize.s
  nRealScreenWidth.i
  nRealScreenHeight.i
  nSplitScreenCount.i     ; nb value 1 (default value) = 'do not split'
  nCurrentMonitorIndex.i  ; -1 if not in gaMonitors(), ie if not a currently-connected screen
  ; nScreenVideoRenderer.i
EndStructure

;- tyCurrScreenVideoRenderer
Structure tyCurrScreenVideoRenderer
  nDisplayNo.i
  nScreenVideoRenderer.i
EndStructure

; tyCurrScreenVideoRenderers
Structure tyCurrScreenVideoRenderers
  Array aCurrScreenVideoRenderer.tyCurrScreenVideoRenderer(0)
  nMaxCurrScreenVideoRenderer.i
EndStructure

;- tyScreen
Structure tyScreen
  ; used for SCS screens available for video/image cues
  nDisplayNo.i  ; windows display number (also referred to as the monitor number)
  nOutputNo.i   ; output number within display number (following Matrox terminology)
  ; scaled position and size
  nScreenLeft.i       ; X position of a 'full screen' window for this SCS Screen
  nScreenTop.i        ; Y position of a 'full screen' window for this SCS Screen
  nScreenWidth.i      ; width of a 'full screen' window for this SCS Screen
  nScreenHeight.i     ; height of a 'full screen' window for this SCS Screen
  ; unscaled position and size
  nDesktopLeft.i
  nDesktopTop.i
  nDesktopWidth.i
  nDesktopHeight.i
EndStructure

;- tySaveOrSet
Structure tySaveOrSet
  nAudPtr.i
  sLogicalDev.s
  sTracks.s
  bDisplayingLevelPoint.i
  nLevelPointType.i
  nLevelPointTime.i
  nZoomValue.i
  nPosition.i
EndStructure

;- tyWindowProps
Structure tyWindowProps
  sName.s
  bVisible.i
  bSticky.i
  bEnabled.i
  nOrigLeft.i
  nOrigTop.i
  nOrigWidth.i
  nOrigHeight.i
  nToolBarHeight.i
  nParentWindow.i     ; 0 if no parent window
  bModal.i
  nReturnFunction.i
  nReturnFunctionParam.i
EndStructure

;- tyGadgetProps non-PB gadget properties
Structure tyGadgetProps
  sName.s
  nGType.i                      ; gadget type, 0 if not specifically set, or -1 if this entry has been freed by scsFreeGadget()
  nModGadgetType.i              ; see enumeration #SCS_MG_... (0 if not a module-created gadget, ie not created by TextEx::Gadget(), etc)
  nGWindowNo.i                  ; gadget window
  sGWindow.s
  nContainerLevel.i
  nContainerGadgetNo.i
  nCuePanelNo.i
  nSliderNo.i
  nEditorComponent.i
  nArrayIndex.i                 ; index of gadget if in a repeating group - derived from [n] in sName, eg if sName = "txtDMXChannel[3]" then nIndex will be 3
  sNameGroup.s                  ; sName excluding the repeating group index, eg if sName = "txtDMXChannel[3]" then sNameGroup will be "txtDMXChannel"
  nGadgetNoForEvHdlr.i          ; gadget no. of first gadget in group - used for EventHandlers to save having to check the gadget no. of every instance in the group
  sLogName.s
  bAllowEditorColors.i
  bReverseEditorColors.i
  bIgnoreDisabledColor.l
  bVisible.i
  bEnabled.i
  bSlider.i
  nResizeFlags.i
  nOrigLeft.i
  nOrigTop.i
  nOrigWidth.i
  nOrigHeight.i
  nFontNo.i
  sValidChars.s
  bValidCharsPresent.i
  bUpperCase.i
  nToolBarBtnId.i                 ; = 0 if not a toolbar button
  nToolBarCatId.i                 ; = 0 if not a toolbar category
  ; 'standard button' properties
  nButtonType.i                   ; = 0 if not a standard button
  hImageEn.i                      ; the 'enabled' image for the button image gadget
  hImageDi.i                      ; the 'disabled' image for the button image gadget
  hImageMo.i                      ; the 'mouse over' image for the button image gadget
  bStandardCanvasButton.i
  bMouseOver.i
  ; validation info
  bValidationReqd.i
  bErrorMessageDisplayed.i
  nReqdWidth.i
  ; fields for owner-drawn gadgets, to be accessed using setOwn...() and getOwn...(), eg setOwnValue(#Gadget, nNewValue)
  nFlags.i
  nOGFlags.i ; non-PB flags for owner-drawn gadgets
  nValue.i
  nState.i
  sText.s
  nFrontColor.l
  nBackColor.l
EndStructure

;- tyGadgetCallbackInfo
Structure tyGadgetCallbackInfo
  cbGadgetId.i
  cbPrevWndFunc.i
EndStructure

;- tyText
;- __ common text from translated text
; populated in loadCommonText(), which is in Lang.pbi
Structure tyText
  sTextActivation.s
  sTextAnimated.s
  sTextAudioLevel.s
  sTextAudioLevelManual.s
  sTextBtnApply.s
  sTextBtnCancel.s
  sTextBtnHelp.s
  sTextBtnOK.s
  sTextCopy.s
  sTextCue.s
  sTextCueState.s[#SCS_LAST_CUE_STATE+1]
  sTextCueTypeA.s
  sTextCueTypeE.s
  sTextCueTypeF.s
  sTextCueTypeG.s
  sTextCueTypeH.s
  sTextCueTypeI.s
  sTextCueTypeJ.s
  sTextCueTypeK.s
  sTextCueTypeL.s
  sTextCueTypeM.s
  sTextCueTypeN.s
  sTextCueTypeP.s
  sTextCueTypeQ.s
  sTextCueTypeR.s
  sTextCueTypeS.s
  sTextCueTypeT.s
  sTextCueTypeU.s
  sTextCut.s
  sTextDefault.s
  sTextDelete.s
  sTextDescription.s
  sTextDevGrp.s[#SCS_DEVGRP_VERY_LAST+1]
  sTextDevice.s
  sTextEditor.s
  sTextEnd.s
  sTextError.s
  sTextFile.s
  sTextFileLength.s
  sTextFixture.s
  sTextGo.s
  sTextLevel.s
  sTextLevelManual.s
  sTextLive.s
  sTextManual.s
  sTextMute.s
  sTextMuteAudio.s
  sTextNextManual.s
  sTextNextManualCue.s
  sTextOff.s
  sTextOn.s
  sTextOptional.s
  sTextPan.s
  sTextPanManual.s
  sTextPaste.s
  sTextPlaceHolder.s
  sTextPreRoll.s
  sTextRepeat.s
  sTextRepositioning.s
  sTextRightClick.s
  sTextSave.s
  sTextSaveAs.s
  sTextSaveReason.s
  sTextSelect.s
  sTextSolo.s
  sTextStoppingEverything.s
  sTextFadingEverything.s
  sTextSub.s
  sTextTemplate.s
  sTextTrue.s
  sTextUnmute.s
  sTextValErr.s
EndStructure

;- tyWMN from fmMain
Structure tyWMN
  bHotkeysCurrentlyDisplayed.i
  bNearEndWarningVisible.i
  sFirstItemLabel.s
  nMaxRowsVisible.i
  nCurrWindowWidth.i  ; width of #WMN
  nCurrWindowHeight.i ; height of #WMN
  nCurrMemoWidth.i    ; width of \cntMemo
  nCurrMemoHeight.i   ; height of \cntMemo
  bMemoScreen1InUse.i
  ; splitter positions - design mode
  nCuelistMemoSplitterPosD.i
  nMainMemoSplitterPosD.i
  nNorthSouthSplitterPosD.i
  nPanelsHotkeysSplitterEndPosD.i
  ; splitter positions - reherasl mode
  nCuelistMemoSplitterPosR.i
  nMainMemoSplitterPosR.i
  nNorthSouthSplitterPosR.i
  nPanelsHotkeysSplitterEndPosR.i
  ; splitter positions - performance mode
  nCuelistMemoSplitterPosP.i
  nMainMemoSplitterPosP.i
  nNorthSouthSplitterPosP.i
  nPanelsHotkeysSplitterEndPosP.i
  ;
  bNorthSouthSplitterInitialPosApplied.i
  bPanelsHotkeysSplitterInitialPosApplied.i
  bToolBarDisplayed.i
  nMainToolBarInfo.i
  bStandbyButtonDisplayed.i
  bTimeProfileButtonDisplayed.i
  bGrdCuesRedrawState.i
  fYFactorForCuePanelFonts.f
  nStatusBackColor.l
  nStatusFrontColor.l
  nStatusTextTop.i
  nProdTimerLength.i
  nProdTimerX.i
  bTemplateInfoSet.i
  nLastPlayingCuePtr.i
  nLastPlayingSubPtr.i
  nLastPlayingState.i
  qLastPlayingTimeDisplayed.q
  qLastPlayingTimeEnded.q
  nLastPlayingTimeOut.i
  Array nAnimatedTimerAudPtr.i(0)
EndStructure

;- tyWQE for fmEditQE
Structure tyWQE
  bTextLoaded.i
  sTextLine.s
  sTextCol.s
  sTextFont.s
  sTextCount.s
  sTextZoom.s
  nStatusItemLine.i
  nStatusItemCol.i
  nStatusItemFont.i
  nStatusItemCount.i
  nStatusItemZoom.i
  nPreviewBtnState.i   ; 0 = 'Preview', 1 = 'Cancel Preview'
  nPreviewMemoScreen.i
EndStructure

;- tyWEN for fmMemo
Structure tyWEN
  nMainSubPtr.i
  nPreviewSubPtr.i
  bDragBarMoving.i
  nDragBarStartX.i
  nDragBarStartY.i
  nWindowStartLeft.i
  nWindowStartTop.i
  bResizerMoving.i
  nResizerStartX.i
  nResizerStartY.i
  nWindowStartWidth.i
  nWindowStartHeight.i
  bInFormResize.i
  bFormResizedInEditor.i
  ; last memo info
  nLastMemoAspectRatio.i
  bLastMemoContinuous.i
  nLastMemoPageColor.l
  nLastMemoTextBackColor.l
  nLastMemoTextColor.l
  nLastMemoDisplayHeight.i
  nLastMemoDisplayTime.i
  nLastMemoDisplayWidth.i
  nLastMemoScreen.i
  bLastMemoResizeFont.i
EndStructure

;- tyWDD for fmDMXDisplay
Structure tyWDD
  bDMXDisplayActive.i
  bDMXDisplayFirstCall.i
  bForceRedisplay.i
  sLTLogicalDev.s
  nDMXDisplayControlPtr.i
  nDMXSendDataBaseIndex.i
  nCanvasWidth.i
  nCanvasHeight.i
  nRowHeight.i
  nColWidth.i
  nTitleWidth.i
  nCanvasBackColor1.l ; back color for display items if only a single DMX start channel is defined, or back color for odd-numbered items where multiple DMX start channels are defined
  nCanvasBackColor2.l ; back color for even-numbered items where multiple DMX start channels are defined
  nTextHeight.i
  nTopMargin.i
  bDragBarMoving.i
  nDragBarStartX.i
  nDragBarStartY.i
  nWindowStartLeft.i
  nWindowStartTop.i
  nWindowStartWidth.i
  nWindowStartHeight.i
  nSCABottomMargin.i ; Used when resizing the window to correctly resize the scroll area gadget - note that only window height can be changed, due to a WindowsBound() function call
  Array aPrevDMXSendData.a(512)
EndStructure

;- tyWDT for fmDMXTest
Structure tyWDT
  nCanvasWidth.i
  nCanvasHeight.i
  nRowHeight.i
  nColWidth.i
  nTitleWidth.i
  nCanvasBackColor.l
  nDMXInPref.i
  nTextHeight.i
  nTopMargin.i
EndStructure

;- tyWCM for fmCtrlSetup
Structure tyWCM
  nItemId.i
EndStructure

;- tyLoadProdPrefs
Structure tyLoadProdPrefs
  bShowAtStart.i    ; indicates if #WLP is to be shown at start-up (else SCS tries to open the most recent file)
  nBlankCount.i     ; used in generating a default production title for 'blank' choices, eg "SCS Production 123"
  nAudioDriver.i    ; the audio driver last selected for 'blank' choices
  sAudPrimaryDev.s
  sDevMapName.s
EndStructure

;- tyWLP for fmLoadProd
Structure tyWLP
  bPlayOnly.i
  bWindowActive.i
  bStructurePrimed.i
  nSelectedChoice.i
  nSelectedExisting.i
  nSelectedFavorite.i
  nSelectedTemplate.i
  nExistingY.i
  nFavoriteY.i
  nTemplateY.i
  nFileCountExisting.i
  nFileCountFavorite.i
  nFileCountTemplate.i
  nDfltBackColor.l
  nDfltItemBackColor.l
  nDfltTextColor1.l
  nDfltTextColor2.l
  nHighBackColor.l
  ; nHighBackHoverColor.l
  nHighTextColor1.l
  nHighTextColor2.l
  nPlayOnlyBackColor.l
  nPlayOnlyTextColor1.l
  nTextLeft1.i
  nTextLeft2.i
  nTextTop1.i
  nTextTop2.i
  nScaTop.i
  nScaWidth.i
  nScaHeight.i
  nFileHeight.i
  nFavoriteHeight.i
  nTemplateHeight.i
  nDelItemWidth.i
  nDelItemHeight.i
  nDelItemLeft.i
  nDelItemRight.i
  nDelItemTop.i
  nDelItemBottom.i
  nDelItemHotWidth.i
  nDelItemHotHeight.i
  nDelItemHotLeft.i
  nDelItemHotRight.i
  nDelItemHotTop.i
  nDelItemHotBottom.i
  bMouseOverDelItemHot.i
  Array aMouseOverChoice.i(3)
  Array aMouseOverItem.i(10)
  Array aItemFileName.s(10)
  Array aItemName.s(10)
  Array aItemTitleOrDesc.s(10)
EndStructure

Structure tyXMLArrayItem
  nSubLevel.i
  sNodeName.s
  sNodeText.s
  sAttributeName.s
  sAttributeValue.s
  sCue.s
  sSubType.s
  nDevType.i
  sLogicalDev.s
  bInclude.i
EndStructure

;- tyWTM for fmTemplates
Structure tyWTM
  nParentWindow.i
  nTemplatePtr.i
  bEditing.i
  bNewTemplate.i
  nCuesHeader.i
  rCuesHDItem.HD_ITEM
  nDevsHeader.i
  rDevsHDItem.HD_ITEM
  nDevMapsHeader.i
  rDevMapsHDItem.HD_ITEM
  Array aValCueFileArray.tyXMLArrayItem(0)
  nMaxItemCueFileArray.i
  Array aValDevMapFileArray.tyXMLArrayItem(0)
  nMaxItemDevMapFileArray.i
EndStructure

;- tyAction
Structure tyAction
  nParentWindow.i
  nAction.i
  bProcessingAction.i
  sSelectedFileName.s
  sTitle.s
  nAudioDriver.i
  sAudPrimaryDev.s
  sDevMapName.s
EndStructure

;- tyWMT for fmMidiTest
; (also used for RS232 and Network)
Structure tyWMT
  nWMTDeviceType.i  ; eg #SCS_WMT_MIDI
  nDevType.i        ; eg #SCS_DEVTYPE_CC_MIDI_IN
EndStructure

;- tyRS232Control
Structure tyRS232Control
  sRS232PortAddress.s
  bDummy.i       ; #True if dummy port - useful during design if no real serial ports are available
  bInitialized.i
  nRS232PortNo.i  ; port number used in PB functions like OpenSerialPort(), WriteSerialPortString(), IsSerialPort(), etc. (0 for dummy port)
  bRS232In.i
  bRS232Out.i
  nRS232BaudRate.i
  nRS232Parity.i
  nRS232DataBits.i
  fRS232StopBits.f
  nRS232Handshaking.i
  nInBufferSize.i
  nOutBufferSize.i
  nRS232RTSEnable.i
  nRS232DTREnable.i
  nRS232ErrNo.i
  sRS232ErrDesc.s
  bHideWarning.i
  sComRcv.s         ; temp buffer for partially-received RS232 messages
  qTimeReceived.q   ; time partially-received message was received (used for timing out corrupt messages)
  ; current values, ie parameters used when this port was last opened
  sCurrRS232PortAddress.s
  nCurrBaudRate.i
  nCurrParity.i
  nCurrDataBits.i
  fCurrStopBits.f
  nCurrHandshaking.i
  nCurrInBufferSize.i
  nCurrOutBufferSize.i
  nCurrRTSEnable.i
  nCurrDTREnable.i
EndStructure

;- tyTimeLineEntry
Structure tyTimeLineEntry
  nEntryId.i              ; unique id for this timeline entry (unique across all TimeLine arrays)
  nEntryStatus.i          ; see Enumeration #SCS_TLS_...
  nEntryType.i            ; see Enumeration #SCS_TLT_...
  qTime.q                 ; absolute time in milliseconds (based on ElapsedMilliseconds()) when this entry is to be executed
  nDependentOnEntryId.i   ; id of a timeline entry that this entry is dependent on, or 0 if none
  nCuePtr.i               ; cue pointer if required by nEntryType
  nSubPtr.i               ; sub pointer if required by nEntryType
  nAudPtr.i               ; aud pointer if required by nEntryType
  nItemIndex.i            ; eg file index for playlist or video/image cue, or message index for control-send cue
EndStructure

;- tySam
Structure tySam
  nSamRequest.i
  nSamPriority.i
  qNotBefore.q
  bActioned.i
  p1Long.i
  p2Single.f
  p3Long.i
  p4String.s
  p5Long.i
  p6Quad.q
  p7Long.i
  p8String.s
  nCuePtrForRequestTime.i
  qTimeRequestAdded.q
  bUnderStoppingEverything.i
EndStructure

;- tyCasItem
Structure tyCasItem
  nCasCueAction.i
  bCasActioned.i
  nCasGroupId.i
  bCasWaitForGroupReady.i
  nCasMixerStream.l
  nCasChannel.l
  nCasTime.i
  sCasMciString.s
  nCasVidPicTarget.i
  nCasAudPtr.i
  sCasOriginProcName.s
EndStructure

;- tyCasGroup
Structure tyCasGroup
  nCasGroupId.i
  bCasGroupReady.i
  qCasTimeCreated.q
EndStructure

;- tyLicInfo
Structure tyLicInfo
  ; sorted
  bASIOAvailable.i
  bAllUsers.i
  bAudFileLoopsAvailable.i
  bCCDMXAvailable.i
  bCSRDAvailable.i ; control send remote device feature available - (CSRD = 'Control Send Remote Device')
  bCommonPrefsLoaded.i
  bCueMarkersAvailable.i  ; includes cue points
  bCueStartConfirmationAvailable.i
  bCueTypeKAvailable.i ; lighting cues
  bDevLinkAvailable.i
  bDMXCaptureAvailable.i
  bDMXSendAvailable.i
  bDriverOptionsLoaded.i
  bExternalEditorsIncluded.i
  bExtFaderCueControlAvailable.i
  bFMAvailable.i    ; functional mode available (primary or backup - default of stand-alone is always available)
  bHKClickAvailable.i ; enables "Activate a hotkey by clicking on the hotkey in the displayed list, if it is currently selected"
  bImportCSVAvailable.i
  bImportDevsAvailable.i
  bLockAudioToLTCAvailable.i ; lock audio file playback to incoming LTC
  bLTCAvailable.i   ; linear time code available
  bM2TAvailable.i
  bPlayOnly.i
  bProductionTimerAvailable.i
  bSMSAvailable.i
  bStartEndAvailable.i
  bStdLvlPtsAvailable.i
  bStepHotkeysAvailable.i
  bTempoAndPitchAvailable.i
  bTimeProfilesAvailable.i
  bVSTPluginsAvailable.i
  dLicExpDate.i
  nExpFactor.l  ; must be long as it is used as a byref parameter in a call to decodeExpString()
  nExpireDate.i
  nLastMonitorWindowNo.i
  nLastVidPicTarget.i
  nLastVideoWindowNo.i
  nLicLevel.i
  nMaxAudDevPerAud.i
  nMaxAudDevPerProd.i
  nMaxAudDevPerSub.i
  nMaxAudioOutputs.i
  nMaxChaseSteps.i
  nMaxCtrlSendDevPerProd.i
  nMaxCtrlSendDevPerSub.i
  nMaxCtrlSendDevs.i
  nMaxCueCtrlDev.i
  nMaxDMXChannel.i
  nMaxDMXItemPerLightingSub.i
  nMaxDMXPort.i
  nMaxFixTypePerProd.i
  nMaxFixTypes.i
  nMaxFixtureItemPerLightingSub.i
  nMaxHotkeyBank.i
  nMaxInGrpItemPerInGrp.i
  nMaxInGrpPerProd.i
  nMaxInGrps.i
  nMaxLightingDevPerProd.i
  nMaxLightingDevPerSub.i
  nMaxLiveDevPerAud.i
  nMaxLiveDevPerProd.i
  nMaxLiveDevPerSub.i
  nMaxLiveInputs.i
  nMaxVSTDevPlugin.i
  nMaxVidAudDevPerProd.i
  nMaxVidCapDevPerProd.i
  nMaxVideoAudioOutputs.i
  nMaxVideoCaptureDevs.i
  nStartsLeft.i
  qRegDate.q
  sAuthString.s
  sExpString.s
  sLicType.s
  sLicUser.s
  sRegErrorMsg.s
  sRegString.s
  sRegisteredLicType.s
EndStructure

;- tyAudioDev
Structure tyAudioDev
  nAudioDriver.i
  sDesc.s
  bInitialized.i
  nInputs.i
  nOutputs.i
  bASIO.i
  nRealPhysDevPtr.i
  bNoDevice.i
  bDummy.i                    ; ??? may take over from bNoDevice ???
  bDefaultDev.i
  bNoSoundDevice.i
  nInterfaceNo.i              ; SMS interface number (-1 if not available)
  bAssignedToASIOGroup.i      ; #True if this interface is assigned to the SMS ASIO Group
  nFirst0BasedOutputChanAG.i  ; first SMS output channel in the SMS ASIO Group
  nDefaultSampleRate.i
  nDevBassASIODevice.l
  nBassDevice.l     ; long
  nBassInitErrorCode.l
  nSpeakers.i           ; non-ASIO speakers
  nSampleRate.i
  nBassInitFlags.l      ; (long)
  nOutputArrayIndex.i[#SCS_MAX_OUTPUT_ARRAY_INDEX+1]
  rBassInfo.BASS_INFO
  nAsioBufLen.i
  dAsioSampleRate.d
  ; SM-S info
  bSMS.i
EndStructure

;- tyAudioDevShort
Structure tyAudioDevShort
  sSortKey.s
  nAudioDriver.i
  sDesc.s
  bNoDevice.i
  bNoSoundDevice.i
  bDefaultDev.i
  nPhysDevPtr.i
  nOutputs.i
  nInputs.i
EndStructure

;- tyVideoAudioDev
Structure tyVideoAudioDev
  bDefaultDev.i
  bNoSoundDev.i
  nVidAudDevId.i
  sVidAudName.s
  bVidAudInitialized.i
  nVidAudOutputs.i
  sSortKey.s
EndStructure

;- tyVideoCaptureDev
Structure tyVideoCaptureDev
  nVidCapDevId.i
  sVidCapName.s
  nFormatsCount.l
  sFormats.s
  bVidCapInitialized.i
EndStructure

;- tyLiveInputDev
Structure tyLiveInputDev
  nLiveInputDevId.i
  sLiveInputName.s
  bLiveInputInitialized.i
EndStructure

;- tyMixerStream
Structure tyMixerStream
  nMixerStreamHandle.l
  nPushStreamHandle.l     ; push stream used for ASIO
  nBufBytes.l             ; the amount of data wanted in the push stream's buffer
  nPhysicalDevPtr.i
  bASIO.i
  bNoDevice.i
  bNoSoundDevice.i
  bIgnoreDevThisRun.i
  bDecodeStream.i
  nBassASIODevice.l
  nBassInitFlags.l
  nBassDevice.l
  nSampleRate.l
  nMixerChans.l
  nFlags.l
  sSpeaker.s
  nSpeakerCount.i   ; 1 if mono, else 2
  nFirstOutputChannel.l
  nOutputs.i
  nSpeakerFlag.l
  bUseMatrix.i
  nMatrixOutputs.i
  fMatrixLeftValue.f
  fMatrixRightValue.f
  bRecreateMixerStream.i
  nTestToneChan.l
  bGaplessStream.i
EndStructure

;- tyMatrix
Structure tyMatrix
  aMatrix.f[#SCS_MAX_MATRIX+1]
EndStructure

;- tyGaplessSeq
Structure tyGaplessSeq
  nGaplessStream.l     ; eg gapless#1 or timeline#1
  nStreamType.i
  nFirstGaplessAudPtr.i
  nLastGaplessAudPtr.i
  nCurrGaplessAudPtr.i
  ; audio info
  nMaxFileChannels.i
  nFlags.l
  nSampleRate.l
  nSyncHandle.l
  ; target outputs
  nSplitterChannel.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]   ; eg splitter#1 etc - only used if multiple outputs required
  nMixerStream.l       ; eg mixer#1 - only used if output directly to mixer (not via splitter)
  ; video info
  nTimeLineChannel.l
  ; ONC_openNextCues() flag
  bAtLeastOneAudOpenForGaplessSeq.i
  ; editing info
  bMajorChangeInEditor.i
EndStructure

;- tyVSTParams
Structure tyVSTParams
  nVSTParamIndex.i
  fVSTParamValue.f 
  fVSTParamDefaultValue.f
EndStructure

;- tyVSTChunk
Structure tyVSTChunk
  sChunkMagic.s
  nByteSize.l
  sChunkData.s
EndStructure

;- VST: library
;- tyLibVSTPlugin
Structure tyLibVSTPlugin
  sLibVSTPluginName.s
  sLibVSTPluginFile32.s
  sLibVSTPluginFile64.s
  bLibWarningShown.i
EndStructure

;- VST: device
;- tyDevVSTPlugin
Structure tyDevVSTPlugin
  sDevVSTLogicalDev.s
  nDevVSTOrder.i
  sDevVSTPluginName.s
  nDevVSTProgram.i
  nDevVSTMaxParam.i ; Def = -1 and set in Startup.pbi in setIndependentDefaults()
  Array aDevVSTParam.tyVSTParams(0) ; dynamically re-dim'ed as required
  rDevVSTChunk.tyVSTChunk
  bDevVSTBypass.i
  nDevVSTHandle.l
  sDevVSTComment.s
EndStructure

;- VST: audio file sub-cue
;- tyAudVSTPlugin
Structure tyAudVSTPlugin
  sAudVSTPluginName.s
  nAudVSTProgram.i
  nAudVSTMaxParam.i ; Def = -1 and set in Startup.pbi in setIndependentDefaults()
  Array aAudVSTParam.tyVSTParams(0) ; dynamically re-dim'ed as required
  rAudVSTChunk.tyVSTChunk
  bAudVSTBypass.i
  nAudVSTHandle.l
  nAudVSTAltHandle.l
  sAudVSTComment.s
EndStructure

;- ************ tyVST
;- tyVST
Structure tyVST
  nMaxLibVSTPlugin.i
  Array aLibVSTPlugin.tyLibVSTPlugin(0)
  nMaxDevVSTPlugin.i
  Array aDevVSTPlugin.tyDevVSTPlugin(0)
EndStructure

;- tyAudioLogicalDevs
; data kept under production properties
Structure tyAudioLogicalDevs
  sLogicalDev.s               ; Device Name used in cues
  nDevType.i
  nDevId.i                    ; unique id for this logical device
  nNrOfOutputChans.i
  nPhysicalDevPtr.i           ; ptr to device in gaAudioDev array
  nMultiDevStatus.i
  bNoDevice.i
  nBassASIODevice.l
  nBassDevice.l
  nOutputs.i
  sSpeaker.s                  ; = SCS code for Speakers
  nSpeakersFlag.l             ; long
  nChannelCount.i
  sOrigLogicalDev.s           ; may be used when applying device changes
  bDevChanged.i
  ; cue defaults
  bAutoInclude.i
  sDfltDBTrim.s
  sDfltDBLevel.s
  fDfltPan.f
  fDfltBVLevel.f
  fDfltTrimFactor.f
  nDfltBassDevice.i
  bDfltASIO.i
  nDfltBassASIODevice.i
  ; other
  bForLTC.i
EndStructure

;- tyVidAudLogicalDevs
Structure tyVidAudLogicalDevs
  sVidAudLogicalDev.s
  nDevType.i
  nDevId.i                    ; unique id for this logical device
  nNrOfOutputChans.i
  nPhysicalDevPtr.i           ; ptr to device in gaVideoAudioDevs array
  nOutputs.i
  sOrigLogicalDev.s
  bDevChanged.i
  sRouteToAudioLogicalDev.s
  ; cue defaults
  bAutoInclude.i
  sDfltDBTrim.s
  sDfltDBLevel.s
  fDfltPan.f
  fDfltBVLevel.f
  fDfltTrimFactor.f
EndStructure

;- tyVidCapLogicalDevs
Structure tyVidCapLogicalDevs
  sLogicalDev.s
  nDevType.i
  nDevId.i                    ; unique id for this logical device
  nPhysicalDevPtr.i           ; ptr to device in gaVideoCaptureDevs array
  sOrigLogicalDev.s
  bDevChanged.i
  ; cue defaults
  bAutoInclude.i
EndStructure

;- tyLiveInputLogicalDevs
Structure tyLiveInputLogicalDevs
  sLogicalDev.s
  nDevType.i
  nDevId.i                    ; unique id for this logical device
  nNrOfInputChans.i
  nPhysicalDevPtr.i           ; ptr to device in gaAudioDev array
  bNoDevice.i
  bDummyDev.i
  nInputs.i
  sLiveInputDevDesc.s
  sOrigLogicalDev.s
  bDevChanged.i
  sDfltInputDBLevel.s
  fDfltInputLevel.f
  bLiveOn.i
  bInputForLTC.i
EndStructure

;- tyInGrpItem
Structure tyInGrpItem
  nInGrpItemDevType.i
  sInGrpItemLiveInput.s
EndStructure

;- tyInGrp
Structure tyInGrp
  sInGrpName.s
  nInGrpId.i
  sOrigInGrpName.s
  bInGrpChanged.i
  Array aInGrpItem.tyInGrpItem(0) ; [#SCS_MAX_LIVE_INPUT_DEV_PER_PROD+1]
  nMaxInGrpItem.i
  nMaxInGrpItemDisplay.i
EndStructure

;- tyMidiCommand
Structure tyMidiCommand
  nCmd.i          ; 08H = Note Off, 09H = Note On, etc
  nCC.i           ; CC or KK, etc
  nVV.i           ; 0-127, or #SCS_MIDI_ANY_VALUE (-99)
  bModifiable.i   ; True if user may modify this command setting
EndStructure

;- tyMidiControl
Structure tyMidiControl
  sMidiInName.s
  sMidiConnectName.s
  nCtrlMethod.i       ; MSC / MMC / Note / PC127 / PC128 / ETC AB / ETC CD / Palladium / Custom
  nMidiChannel.i
  nMscMmcMidiDevId.i  ; used with MSC and MMC (ONLY!)
  nMscCommandFormat.i
  bMMCApplyFadeForStop.i
  nBase.i ; 0: value 0 = cue 1     1: value 1 = cue 1
  nGoMacro.i
  nExtFaderThresholdVV.i
  aMidiCommand.tyMidiCommand[#SCS_MAX_MIDI_COMMAND+1]
  ; fields used by doMidiIn_Proc() and subordinate procedures
  sStatusField.s
  nStatusType.i
EndStructure

;- tyMidiIn
Structure tyMidiIn
  nPhysicalDevPtr.i
  wMsg.l
  dwInstance.l
  dw1.l
  dw2.l
  msgType.l
  midiChannel.l
  kk.i
  vv.i
  bPlayCue.i
  bDone.i
  bNRPN_Gen.i ; format is standard NRPN (NRPN MSB, NRPN LSB, Data MSB, Data LSB)
  bNRPN_Yam.i ; format is Yamaha NRPN (NRPN LSB, NRPN MSB, Data MSB, Data LSB)
  dw1_NRPN_MSB.l
  dw1_NRPN_LSB.l
  dw1_Data_MSB.l
  dw1_Data_LSB.l
  vv_NRPN_MSB.b
  vv_NRPN_LSB.b
  vv_Data_MSB.b
  vv_Data_LSB.b
  nNRPNPartsReceived.i ; for NRPN messages, this will be 3 or 4 (Data_LSB is optional in the NRPN spec)
EndStructure

;- tyNetworkMsgResponse
Structure tyNetworkMsgResponse
  sReceiveMsg.s
  sComparisonMsg.s        ; derived from sReceiveMsg but used when comparing against incoming messages
  nMsgAction.i
  sReplyMsg.s
EndStructure

;- tyX32Command
Structure tyX32Command
  nX32Button.i
EndStructure

;- tyDMXDevice
Structure tyDMXDevice
  ; this structure is used to hold info for a physical DMX interface device, eg an ENTTEC DMX PRO MK2
  sName.s
  bDummy.i          ; #True if dummy port - useful during design if no real DMX ports are available
  nDMXDevType.i     ; eg #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO
  bInitialized.i
  ; info on serial numbers, supplied by ENTTEC support:
  ; ===================================================
  ; There are indeed two different serial numbers.
  ;
  ; The numeric one is stored inside the PRO Mk2 firmware, and is only available on GET_WIDGET_SN
  ; This is the number you should be using to display
  ;
  ; The alphanumeric number is used to identify it as a unique FTDI device (that's what the FTDI driver requires)
  ; This number should be used internally to handle the device uniquely
  ; This one is a random unique identifier provided by FTDI with a prefix "EN" - for ENTTEC
  nSerial.l
  sSerial.s
  nDMXPorts.i
  sDMXIpAddress.s
  nFTDeviceNo.l   ; iDevice as required for functions such as FT_Open (see D2XX Programmers' Guide)
  nFTHandle.i     ; handle returned by FT_Open (see D2XX Programmers' Guide)
  bMidiEnabled.i
EndStructure

;- tyDMXCommand
Structure tyDMXCommand
  nChannel.l            ; DMX Channel
EndStructure

;- tyDMXControl
Structure tyDMXControl
  bExists.i
  nDevMapId.i
  nDevType.i
  nDevNo.i
  sLogicalDev.s
  nDevMapDevPtr.i
  nDevChgsDevMapDevPtr.i
  nDMXPort.i
  sDMXIpAddress.s     ; Artnet - sACn ip address
  nDMXDevPtr.i
  nDMXDevType.i       ; eg #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO
  sDMXName.s
  nDMXSerial.l        ; see comments about serial numbers under tyDMXDevices
  sDMXSerial.s
  bDMXDummyPort.i
  nFTHandle.i
  nDMXSendDataBaseIndex.i
  ; cue control (DMX receive) data
  bDMXCueControl.i
  nDMXInPref.i            ; preferred value notation: 0 = 0-255, 1 = %
  nDMXTrgCtrl.i
  nDMXTrgValue.i
  aDMXCommand.tyDMXCommand[#SCS_MAX_DMX_COMMAND+1]
  ; added to ignore first type 5 message (if necessary)
  bDMXFirstReceive.i
  ; lighting (DMX send) data
  bDMXProcessRefresh.i  ; only required for Enttec OPEN DMX USB or equivalent
  nDMXRefreshRate.i     ; eg 40 = 40fps, 0 = no refresh
  qTimeLastSent.q
EndStructure

;- tyDMXRefreshControl
Structure tyDMXRefreshControl
  bRefreshSet.i
  qTimeLastSent.q
  nRefreshInterval.i
EndStructure

;- lighting fixtures
;- tyFixTypeChan
Structure tyFixTypeChan
  nChanNo.i
  sChannelDesc.s
  bDimmerChan.i   ; #True if this channel can be dimmed, or is to be used as the dimmer (or intensity) channel
  sDefault.s      ; the default value for this fixture channel (saved as strings as may be a percentage, eg 50, or a DMX value, eg d255 or dmx255)
  nDMXDefault.i   ; DMX equivalent of sDefault (ie DMX value in the range 0-255)  
  nDMXTextColor.l ; Foreground Color for DMX Display Grid
EndStructure

;- tyFixType
Structure tyFixType
  sFixTypeName.s    ; a unique code to identify this fixture type
  sFixTypeDesc.s    ; description
  nFixTypeId.i
  sOrigFixTypeName.s
  bFixTypeChanged.i
  nTotalChans.i
  Array aFixTypeChan.tyFixTypeChan(0)
EndStructure

;- tyFixtureLogical
Structure tyFixtureLogical
  sFixtureCode.s
  nFixtureId.i
  sFixTypeName.s
  sOrigFixtureCode.s ; may be used when applying device changes
  bFixtureChanged.i
  sFixtureDesc.s
  sDimmableChannels.s ; single or multiple dmx channels (eg "1", or "1-7", or "1,3,4"). Note: sDimmableChannels is only used for "Lighting Devices - Pre SCS 11.8"
  nDefaultDMXStartChannel.i ; useful if copying cue file to another computer, because the tyFixtureRunTime\nDMXStartChannel is held in the device map
EndStructure

;- tyDevFixture
Structure tyDevFixture ; nb previously named tyFixturePhysical
  sDevFixtureCode.s
  nDevDMXStartChannel.w
  sDevDMXStartChannels.s
  nMaxDevStartChannelIndex.w
  Array aDevStartChannel.w(0) ; For an explanation of the reason for supporting multiple start channels, see the Help for 'DMX Start Channel' under 'Production Properties - Lighting - DMX Devices and Fixtures'
EndStructure

;- tyFixtureRunTime
Structure tyFixtureRunTime
  sFixtureSortKey.s
  nDevNo.i
  sFixtureCode.s
  nFixtureId.i
  nFixTypeIndex.i
  sDimmableChannels.s ; single or multiple dmx channels (eg "1", or "1-7", or "1,3,4"). Note: sDimmableChannels is only used for "Lighting Devices - Pre SCS 11.8"
;   nDMXStartChannel.i
;   sDMXStartChannels.s
  nTotalChans.i
  bFixtureRequired.i
  nMaxDevStartChannelIndex.w
  Array aDevStartChannel.w(0)
EndStructure

;- tyFixturesRunTime
Structure tyFixturesRunTime
  bLoaded.i
  Array aFixtureRunTime.tyFixtureRunTime(0)
  nMaxFixture.i
EndStructure

;- tyLightingLogicalDevs
Structure tyLightingLogicalDevs
  sLogicalDev.s
  nDevType.i
  nDevId.i                    ; unique id for this logical device
  sLightingDevDesc.s          ; physical dev desc
  sOrigLogicalDev.s
  bDevChanged.i
  Array aFixture.tyFixtureLogical(0)
  nMaxFixture.i
EndStructure

;- tyCtrlSendLogicalDevs
Structure tyCtrlSendLogicalDevs
  sLogicalDev.s
  nDevType.i
  nDevId.i                    ; unique id for this logical device
  sCtrlSendDevDesc.s          ; physical dev desc, eg Com1, Com2, etc
  sOrigLogicalDev.s
  bDevChanged.i
  bM2TSkipEarlierCtrlMsgs.i
  bConnectWhenReqd.i ; 19Sep2022 11.9.6 (initially added for network client connections following request from Jason Mai 14Sep2022)

  ; MIDI Out
  nCtrlMidiRemoteDev.i
  sCtrlMidiRemoteDevCode.s
  nCtrlMidiRemDevId.i ; (derived) the 'CSRD' id of this remote device, to optimise scans of the array gaCSRD_MsgData()
  nCtrlMidiChannel.i
  bCtrlMidiForMTC.i
  
  ; RS232 Out
  nRS232DataBits.i
  fRS232StopBits.f
  nRS232Parity.i
  nRS232BaudRate.i
  nRS232Handshaking.i
  nRS232RTSEnable.i
  nRS232DTREnable.i
  
  ; DMX Out
  
  ; Network Out
  CompilerIf #c_csrd_network_available
  sCtrlNetworkRemoteDevCode.s
  nCtrlNetworkRemoteDev.i ; eg #SCS_CS_NETWORK_REM_OSC_X32 if sCtrlNetworkRemoteDevCode = "OSC-X32". NetworkRemoteDev = 4 at the time of writing this comment.
  nCtrlNetworkRemDevId.i  ; (derived) the 'CSRD' id of this remote device, to optimise scans of the array gaCSRD_MsgData()
  CompilerElse
  nCtrlNetworkRemoteDev.i
  CompilerEndIf
  nOSCVersion.i
  nNetworkProtocol.i
  nNetworkRole.i
  bGetRemDevScribbleStripNames.i ; Added 6May2024 11.10.2cn
  nDelayBeforeReloadNames.i
  sCtrlNetworkRemoteDevPassword.s
  aMsgResponse.tyNetworkMsgResponse[#SCS_MAX_NETWORK_MSG_RESPONSE+1]
  nMaxMsgResponse.i
  bReplyMsgAddCR.i
  bReplyMsgAddLF.i
  
  ; HTTP Out
  sHTTPStart.s
EndStructure

;- tyCueCtrlLogicalDevs
Structure tyCueCtrlLogicalDevs
  sCueCtrlLogicalDev.s
  nDevType.i
  nDevId.i ; unique id for this logical device
  sCueCtrlDevDesc.s ; C1, C2, etc
  sOrigLogicalDev.s
  bDevChanged.i
  ; MIDI In
  nMidiChannel.i
  nCtrlMethod.i
  nMscMmcMidiDevId.i  ; used with MSC and MMC (ONLY!)
  nMscCommandFormat.i
  nGoMacro.i
  aMidiCommand.tyMidiCommand[#SCS_MAX_MIDI_COMMAND+1]
  bMMCApplyFadeForStop.i ; if #True then MMC 'Stop' command will be processed as 'Fade All' instead of 'Stop All'
  ; RS232 In
  nRS232DataBits.i
  fRS232StopBits.f
  nRS232Parity.i
  nRS232BaudRate.i
  nRS232Handshaking.i
  nRS232RTSEnable.i
  nRS232DTREnable.i
  ; DMX In
  nDMXInPref.i ; preferred value notation: 0 = 0-255, 1 = %
  nDMXTrgCtrl.i
  nDMXTrgValue.i
  aDMXCommand.tyDMXCommand[#SCS_MAX_DMX_COMMAND+1]
  ; Network In
  nCueNetworkRemoteDev.i
  nNetworkProtocol.i
  nNetworkRole.i
  nNetworkMsgFormat.i ; nb only used for display purposes in cue control device properties
  nOSCVersion.i
  aX32Command.tyX32Command[#SCS_MAX_X32_COMMAND+1]
EndStructure

;- tyTemplate
Structure tyTemplate
  sName.s
  sDesc.s
  ; current values
  sCurrTemplateFileName.s
  sCurrTemplateDevMapFileName.s
  sCurrTemplateDatabaseFileName.s
  sCurrTemplateBakFileName.s
  ; original values (if applicable)
  sOrigTemplateFileName.s
  sOrigTemplateDevMapFileName.s
  sOrigTemplateDatabaseFileName.s
  sOrigTemplateBakFileName.s
  ; the following only used when creating a template from a cue file
  sCueFileName.s
  sDevMapFileName.s
  sDatabaseFileName.s
  sBakFileName.s
EndStructure

;- tyTmCue
Structure tyTmCue
  sCue.s
  sCueDescr.s
  sCueType.s
  nActivationMethod.i
  nAutoActCueSelType.i
  sAutoActCue.s
  nAutoActPosn.i
  nAutoActTime.i
  sHotkey.s
  nMTCStartTimeForCue.i
  bIncludeCue.i
  sCueTypeL.s           ; language translation of \sCueType
  sActivationMethodL.s  ; language translation of \nActivationMethod
  sColorCode.s
  nBackColor.l
  nTextColor.l
EndStructure

;- tyTmDev
Structure tyTmDev
  sNodeName.s
  nDevType.i
  nDevGrp.i
  sLogicalDev.s
  sRemoteDev.s
  bIncludeDev.i
  sDevTypeL.s           ; language translation of \nDevType
  nBackColor.l
  nTextColor.l
  nProdDevSeq.i         ; 'absolute' sequence number of this device within production properties as read from the cue file - use for identifying and deleting xml nodes of devices
EndStructure

;- tyTmDevMap
Structure tyTmDevMap
  sDevMapName.s
  nAudioDriver.i
  bIncludeDevMap.i
  ; bDevMapC.i
  sAudioDriverL.s       ; language translation of \nAudioDriver
  nBackColor.l
  nTextColor.l
EndStructure

;- ******** tyProd
;- tyProd ********
Structure tyProd
  nProdId.i
  sTitle.s
  sProdId.s
  sFileVersion.s
  nFileBuild.i
  Array aAudioLogicalDevs.tyAudioLogicalDevs(0)
  Array aVidAudLogicalDevs.tyVidAudLogicalDevs(0)
  Array aVidCapLogicalDevs.tyVidCapLogicalDevs(0)
  Array aFixTypes.tyFixType(0)  ; fixture types (designed for lighting fixture types, but could also be used for types of smoke machine, etc)
  Array aLightingLogicalDevs.tyLightingLogicalDevs(0)
  Array aCtrlSendLogicalDevs.tyCtrlSendLogicalDevs(0)
  Array aCueCtrlLogicalDevs.tyCueCtrlLogicalDevs(0)
  Array aLiveInputLogicalDevs.tyLiveInputLogicalDevs(0)
  Array aInGrps.tyInGrp(0)
  ; The maximum index currently used for each of the above device types, or -1 for any device type not currently used
  nMaxAudioLogicalDev.i
  nMaxVidAudLogicalDev.i
  nMaxVidCapLogicalDev.i
  nMaxFixType.i
  nMaxLightingLogicalDev.i
  nMaxCtrlSendLogicalDev.i
  nMaxCueCtrlLogicalDev.i
  nMaxLiveInputLogicalDev.i
  nMaxInGrp.i
  ; The maximum index used ONLY in fmEditProd (WEP) for each of the above device types.
  ; This will always be one greater than the maximum used for the arrays, UP TO the maximum for the license type.
  ; For example, grLicInfo\nMaxAudioOutputs will be 16 for an SCS Professional license, so \nMaxAudioLogicalDevDisplay will be capped at 15 (0-based).
  ; This is to simplify the displaying of Logical Devices entries in fmEditProd.
  ; Examples (for an SCS Professional user):
  ;   If the user has selected 3 audio devices then nMaxAudioLogicalDev=2 (0,1,2) and nMaxAudioLogicalDevDisplay=3 (0,1,2, and 3 for a new entry)
  ;   If the user has selected 5 audio devices then nMaxAudioLogicalDev=4 (0-4) and nMaxAudioLogicalDevDisplay=5 (0-4, and 5 for a new entry)
  ;   If the user has selected 16 audio devices then nMaxAudioLogicalDev=15 (0-15) and nMaxAudioLogicalDevDisplay(capped)=15 (0-15, no new entry possible)
  nMaxAudioLogicalDevDisplay.i
  nMaxVidAudLogicalDevDisplay.i
  nMaxVidCapLogicalDevDisplay.i
  nMaxFixTypeDisplay.i
  nMaxLightingLogicalDevDisplay.i
  nMaxCtrlSendLogicalDevDisplay.i
  nMaxCueCtrlLogicalDevDisplay.i
  nMaxLiveInputLogicalDevDisplay.i
  nMaxInGrpDisplay.i

  sTimeProfile.s[#SCS_MAX_TIME_PROFILE+1]
  nTimeProfileCount.i
  sOutputDevForTestLiveInput.s
  bLabelsFrozen.i
  bLabelsUCase.i
  bPreLoadNextManualOnly.i
  bNoPreLoadVideoHotkeys.i
  bAllowHKeyClick.i
  bDoNotCalcCueStartValues.i
  bEnableMidiCue.i
  nDefChaseSpeed.i
  nDefDMXFadeTime.i
  nDefFadeInTime.i
  nDefFadeInTimeI.i
  nDefFadeOutTime.i
  nDefFadeOutTimeI.i
  nDefLoopXFadeTime.i
  nDefSFRAction.i
  nDefSFRTimeOverride.i
  sDefaultTimeProfile.s
  sDefaultTimeProfileForDay.s[7]
  ; Added 5Feb2025 11.10.7aa for Video/Image sub-cues
  nDefFadeInTimeA.i
  nDefFadeOutTimeA.i
  nDefDisplayTimeA.i
  bDefRepeatA.i
  bDefPauseAtEndA.i
  ; End added 5Feb2025 11.10.7aa for Video/Image sub-cues
  nDefOutputScreen.i
  nCueAutoStartRange.i
  nVisualWarningTime.i
  nVisualWarningFormat.i    ; 0 = seconds only (eg 9); 1 = seconds and hundredths (eg 8.75)
  nRunMode.i                ; 0 = linear (default);  1 = non-linear (load on demand); 2 = non-linear (pre-load all cues)
  
  ; Various audio level variables
  ; Note that 'DB' in a variable name indicates this contains a decibel (dB) value, eg -3 for -3dB. DB variables will normally be floats or strings, but integers are also permissible if the dB value is always a whole number.
  ;           'BV' in a variable name indicates this contains a 'BASS Volume' (BASS_ATTRIB_VOL) value, which will be a float normally in the range 0.0 (silent) to 1.0 (0dB), but higher for values above 0dB.
  nMaxDBLevel.i ; 0 (0dB) or 12 (+12dB)
  nMinDBLevel.i ; -75 (-75dB) or -160 (-160dB)
  sTestToneDBLevel.s ; The dB level currently selected for playing audio device test tones under Production Properties / Devices / Audio Output
  fTestToneBVLevel.f ; The 'BASS Volume' (BASS_ATTRIB_VOL) equivalent of sTestToneDBLevel
  fMasterBVLevel.f
  fTestTonePan.f  ; 4May2022am
  nTestSound.i    ; 3May2022pm 11.9.1
  fPreviewBVLevel.f
  sMasterDBVol.s
  ;
  nDMXMasterFaderValue.i
  sDBLevelChangeIncrement.s
  ; nMVIncrements.i
  sPreviewDevice.s
  nCueLabelIncrement.i
  nResetTOD.i       ; reset time-of-day; -1 (default) if reset not required
  nVideoTargetAspectRatio.i
  nFocusPoint.i
  nGridClickAction.i
  bSaveProdTimerHistory.i
  bTimeStampProdTimerHistoryFiles.i
  bStopAllInclHib.i
  bTapAllowed.i           ; global tap allowed for setting lighting chase bpm
  sTapShortcutStr.s       ; keyboard shortcut
  bTemplate.i
  sTmName.s   ; template name (saved for templates only)
  sTmDesc.s   ; template description (saved for templates only)
  nMemoDispOptForPrim.i
  nLostFocusAction.i
  ; --------------------------------- derived production fields
  bProdIdFoundInCueFile.i ; this flag is used to indicate if the associated device map file is expected to have the ProdId in the filename
  nFileVersion.i
  bPreOpenNonLinearCues.i
  bExistingDevMapFileFound.i
  sDevMapFile.s
  sSelectedDevMapName.s
  nSelectedDevMapPtr.i
  nNodeKey.i
  sErrorMsg.s
  bUsingMidiCueNumbers.i
  bLightingPre118.i ; cue file contains lighting features created pre SCS 11.8
  qTimeProdLoaded.q
  bTimeProdLoadedSet.i
  nDatabaseNo.i
  sDatabaseFile.s
  nCurrHotkeyBank.i
  sCueListTitle.s
  nTapShortcut.i          ; PB shortcut, eg #PB_Shortcut_P, or #PB_Shortcut_Control | #PB_Shortcut_P. Note that SCS will treat #PB_Shortcut_Pad1 as #PB_Shortcut_1, etc, and vice-versa
  nTapShortcutVK.l        ; corresponding Windows 'virtual key', eg #VK_F1 - ignoring control/shift/alt/command
                          ; nb although vKeys values are 16-bit, the Windows function GetAsyncKeyState() declares the vKey parameter as int (32-bit)
  nTapShortcutNumPadVK.l  ; numeric pad alternative vKey if applicable, otherwise 0
  nMidiFreeConvertedToNrpn.i
  nMidiCCsConvertedToNRPN.i
  nDevChgsId.i
  bVideoFilePresent.i ; Added 30Apr2024 11.10.2ck for use in determining whether or not VU meters should be displayed for Video Audio devices - will be #True if at least one enabled Video/Image cue conatains a video file (that's not muted)
  bNewCueFile.i ; Added 7Feb2025 11.10.7aa to address issue encountered in displayLabelsBASSandTVG() in VUDisplay.pbi
EndStructure

;- tyProdTimer
Structure tyProdTimer
  nPTState.i
  qPTStartTime.q
  qPTTimePaused.q
  nPTTotalTimeOnPause.i
  bPTForceRedisplay.i
EndStructure

;- tyProdTimerHistory
Structure tyProdTimerHistory
  nDateTime.i
  nHistAction.i
  nTimeInSecs.i
  sCue.s
  sCueDescr.s
  nProdTimerAction.i
EndStructure

;- tyCallableCueParam
Structure tyCallableCueParam
  sCallableParamId.s
  sCallableParamDefault.s
EndStructure

;- tyCallCueParam
Structure tyCallCueParam
  sCallParamId.s
  sCallParamValue.s
  sCallParamDefault.s ; derived at run-time from the callable cue's sCallableParamDefault
EndStructure

;- ********* tyCue
;- tyCue ********
Structure tyCue
  nCueId.i
  sCue.s                  ; cue number entered by the user, or auto-generated, which must be unique (primary key)
  sCueDescr.s             ; cue description
  sPageNo.s               ; page number in the script
  nActivationMethod.i     ; activation method, eg manual, auto-start, etc - see 'cue activation method' constants #SCS_ACMETH_MAN, etc
  nActivationMethodReqd.i ; this will normally be the same as nActivationMethod but may be dynamically changed to 'manual', eg if the user clicks on a cue that would otherwise have been an auto-start cue
  nAutoActCueSelType.i    ; for auto-start this indicates if a specific cue is the auto-start triggering cue (#SCS_ACCUESEL_DEFAULT) or if the 'previous' cue is the triggering cue (#SCS_ACCUESEL_PREV)
  sAutoActCue.s           ; for auto-start with selection type #SCS_ACCUESEL_DEFAULT, or 'on cue marker' activation method (#SCS_ACMETH_OCM), this specifies the cue number of the triggering cue
  nAutoActSubNo.i         ; for 'on cue marker' activation method (#SCS_ACMETH_OCM) this specifies the sub-cue of the triggering cue that contains the triggering cue marker
  nAutoActSubId.i         ; (not saved in cue file) the nSubId of nAutoActSubNo - useful for resetting nAutoActSubNo after sub-cues have been added or removed
  nAutoActAudNo.i         ; for 'on cue marker' activation method (#SCS_ACMETH_OCM) this specifies the aAud of the triggering cue that contains the triggering cue marker
  nAutoActAudId.i         ; (not saved in cue file) the nAudId of nAutoActAudNo - useful for resetting nAutoActAudNo after videos or images have been added to or removed from a TypeA sub-cue
  nAutoActPosn.i
  nAutoActTime.i
  sAutoActCueMarkerName.s
  nHotkeyBank.i
  sHotkey.s
  sHotkeyLabel.s
  sWhenReqd.s
  nStandby.i
  nProdTimerAction.i
  sMidiCue.s
  nExtFaderCC.i
  bCueEnabled.i             ; bCueEnabled is cue's "enabled" property, as saved in the "Enabled" item in the XML cue file
  bCueCurrentlyEnabled.i    ; bCueCurrentlyEnabled is initially set to the value in bCueEnabled but may be adjusted by playing SubTypeJ (enable/disable cues),
                            ; so bCueCurrentlyEnabled is the field that should be checked when SCS needs to know if a cue is currently enabled
  bCueSubsAllDisabled.i     ; set if all subs for this cue are disabled (only relevant if the cue itself is enabled)
  bExclusiveCue.i
  bWarningBeforeEnd.i
  bCueGaplessIfPossible.i
  nHideCueOpt.i
  sTimeProfile.s[#SCS_MAX_TIME_PROFILE+1]     ; if non-blank then an entry contains a time profile for the following 'time based start'
  sTimeBasedStart.s[#SCS_MAX_TIME_PROFILE+1]  ; the time-of-day that will cause this cue to be started, if the currently-selected time profile matches the corresponding sTimeProfile entry - or sTimeBasedStart may be 'Manual'
  sTimeBasedStartReqd.s                       ; the actual time-of-day (or 'Manual') to be used this run, ie for the currently-selected time profile
  nSecondToStart.i                            ; ditto but in seconds, ie seconds within the day - see setTimeBasedCues() for more info
  ; TBC Project Changes
  sTimeBasedLatestStart.s[#SCS_MAX_TIME_PROFILE+1]
  sTimeBasedLatestStartReqd.s
  nLatestSecondToStart.i
  sCallableCueParams.s
  Array aCallableCueParam.tyCallableCueParam(0) ; derived from sCallableCueParams
  nMaxCallableCueParam.i                        ; derived
  ; ----
  nMTCStartTimeForCue.i ; hh:mm:ss:ff
  nFirstSubIndex.i ; pointer to the first sub-cue for this cue
  bSubTypeA.i
  bSubTypeE.i
  bSubTypeF.i
  bSubTypeG.i
  bSubTypeI.i
  bSubTypeJ.i
  bSubTypeK.i
  bSubTypeL.i
  bSubTypeM.i
  bSubTypeN.i
  bSubTypeP.i
  bSubTypeQ.i
  bSubTypeR.i
  bSubTypeS.i
  bSubTypeT.i
  bSubTypeU.i
  bSubTypeAorF.i
  bSubTypeAorP.i
  bSubTypeForP.i
  bLiveInput.i
  nCueState.i
  nM2TItemIndex.i
  nCueLength.i
  nGrdCuesRowNo.i     ; row number in WMN\grdCues, or -1 if not displayed (eg because cue is disabled)
  bDefaultCueDescrMayBeSet.i
  bDisplayingWarningBeforeEnd.i
  nStopEverythingCueState.i   ; nCueState when stopEverything() last activated
  bRedoCueState.i
  qTimeCueLastEdited.q
  nRAICueState.i
  bRAICueSubStartedInEditor.i
  bCueCountDownPaused.i
  qTimeCueCountDownPaused.q
  bUpdateGrid.i
  nCuePanelUpdateFlags.i
  qTimeCueStarted.q
  bTimeCueStartedSet.i
  qTimeCueLastStarted.q
  nCueStartedCount.i    ; cue start sequence for this session - used for determining first playing cue etc, as cannot rely on qTimeCueStarted due to time overflows
  bCueStartedByLTC.i
  qTimeCueStopped.q
  bTimeCueStoppedSet.i
  bCueStoppedByStopEverything.i
  bCueStoppedByGoToCue.i
  bTBCDone.i
  bPlayCueEventPosted.i
  bNonLinearCue.i
  nAutoActCuePtr.i
  nAutoActCueMarkerId.i
  bAutoStartLocked.i
  ; bAutoStartLocked.i: an auto-start cue will be locked by playCue() and unlocked when the controlling cue is (re)opened
  ; this is to prevent statusCheck() immediately restarting a non-linear cue after it has been reopened
  bHoldAutoStart.i
  bResetInitialStateWhenCompleted.i
  nCurrentCuePtrForResetInitialState.i
  bHotkey.i
  nCueHotkeyStepNo.i
  bDoNotResetToggleStateAtCueEnd.i
  bExtAct.i ; external activation (eg #SCS_ACMETH_EXT_TRIGGER)
  nExtActToggleState.i ; 1 = odd press (1st, 3rd, 5th, etc), 0 = even press (2nd, 4th, 6th, etc)
  bCallableCue.i
  bKeepOpen.i
  bNoPreLoad.i
  bUseCasForThisCue.i
  qTimeToStartCue.q
  bTimeToStartCueSet.i
  nCueCountDownTimeLeftDisplayed.i
  nCueCountDownTimeLeft.i
  bCueCountDownFinished.i
  qCueCountDownFinishedTime.q
  sColorCode.s
  nBackColor.l
  nTextColor.l
  bInPlayCue.i
  bCallSetWindowVisible.i
  nFirstEnabledAudPtr.i
  ; the following define cue-level links
  nLinkedToCuePtr.i
  nCueLinkCount.i
  nFirstCueLink.i
  bCallClearLinksForCue.i
  ; the following used by the production editor
  nPreEditPtr.i
  nOriginalCuePtr.i
  nNodeKey.i
  bNodeExpanded.i
  nNodeImageHandle.i
  sValidatedCue.s
  sValidatedDescr.s
  sErrorMsg.s
  bUnloadWhenEnded.i
  bCueCompletedBeforeOpenedInEditor.i
  bCloseCueWhenLeavingEditor.i
  sCuePreChange.s
  sCueSetGainCommandString.s
  sCuePlayCommandString.s
  bSetLevelsWhenPlayCue.i
  sFastCuePlayCommandString.s
  qMainThreadRequestTime.q
  bUsingCuePoints.i
  nNrOfInputChans.i
  nSMSGroup.i ; used for SM-S 'set group ...' commands
  bSMSTimeCodeLocked.i
  bExportAsManualStart.i
  bStopOpenNextCuesHere.i
  bCueContainsGapless.i
  bLockMixerStreamsOnPlayCue.i
  bGoOkIfExclPlaying.i
  bCueEnded.i
  nCalledBySubPtr.i
  nCurrHotkeyBank.i
  nCueTotalTimeOnPause.i
  qCueTimePauseStarted.q
  bM2TCue.i
  bCallLoadGridRow.i
  bCueSelected.i ; used exclusively for procedures that import cues, indicating cues that are selected for import
  bLogInONCCloseFilesNotReqd.i ; TEMP (?) Added 16Jun2020 11.8.2.3ad to try to track cause of error reported by CPeters 5Jun2020 under subject 'Heavy bug...'.
                               ; Once set #True, this should NEVER be set #False in this run. This is to ensure logging in this procedure continues for this cue even if the gapless info is broken or lost.
EndStructure

;- tyDMXValueInfo
; used for validating and converting DMX display values
Structure tyDMXValueInfo
  sDMXDisplayValue.s
  nDMXDisplayValue.i  ; 0-255 if dmx value; 0-100 if percentage
  nDMXAbsValue.w      ; 0-255
  bDMXAbsValue.w      ; #True if dmx value; #False if percentage
  nErrorCode.i        ; 0 = no error, 1 = invalid format, 2 = value out of range
EndStructure

;- tyLTFixtureItemChannel
Structure tyLTFixtureItemChannel
  nRelChanNo.w
  bRelChanIncluded.b
  bApplyFadeTime.b    ; nb even though this variable is included in tyLTFixtureItemChannel and therefore will be present for every chase step, it is not used in chase cues so will only be relevnt in the first occurrence 
  sDMXDisplayValue.s
  nDMXDisplayValue.i  ; 0-255 if dmx value; 0-100 if percentage
  nDMXAbsValue.w      ; 0-255
  bDMXAbsValue.w      ; #True if dmx value; #False if percentage
EndStructure

;- tyLTFixtureItem
Structure tyLTFixtureItem
  sFixtureCode.s
  Array aFixChan.tyLTFixtureItemChannel(0) ; contains 1 occurrence per channel in the fixture sFixtureCode
EndStructure

;- tyDMXSendItem
Structure tyDMXSendItem
  ; saved in cue file:
  sDMXItemStr.s     ; eg "1,2,24-30@90fade4.5"
  ; temp field used in converting old-format DMX control send cues:
  bDMXFade.i
  ; derived fields:
  sDMXChannels.s      ; single or multiple dmx channels, eg "1", or "1-512", or "24,36,90-100", possibly preceded by the fixtures
  nDMXValue.i         ; 0-255 ; Changed 19Jul2022
  nDMXDisplayValue.i  ; 0-255 if dmx value; 0-100 if percentage ; Changed 19Jul2022
  bDMXAbsValue.w      ; #True if dmx value; #False if percentage
  nDMXFlags.w
  nDMXFadeTime.i      ; -2 if blank and therefore to use the default fade time; 0 if no fade required; >0 if specific fade time required
  nDMXDelayTime.i     ; delay time before processing this item, or 0 if no delay required. derived from the value in [time] eg [8.3] at the start of sDMXItemStr
  bDBO.i
  sComment.s
  nFixtureInd.i ; as enumeration #SCS_FIX_IND_...
  sDMXFixturesOnly.s
  sDMXRelChannelsOnly.s
  nFixtureCount.i
  nRelChannelCount.i
  Array sDMXFixtureCode.s(0)
  Array nDMXRelChannel.w(0)
EndStructure

;- tyDMXChannelItem
Structure tyDMXChannelItem
  bDMXFixtureChannel.b
  bDMXChannelSet.b
  bDMXChannelDimmable.b
  bDMXApplyFadeTime.b
  nDMXChannelValue.i
  nDMXChannelFadeTime.i
  qDMXTimeOfWarmUp.q
EndStructure

;- tyDMXChannelItems
Structure tyDMXChannelItems
  Array aDMXChannelItem.tyDMXChannelItem(512)
EndStructure

;- tyDMXFadeItem
Structure tyDMXFadeItem
  nDMXDelayTime.i
  nDMXDevPtr.i
  nDMXPort.i
  nDMXChannel.i
  nStartValue.a
  nTargetValue.a
  qStartTime.q
  nFadeTime.i
  bFadeCompleted.i
  nSubPtr.i   ; aSub() instance that initiated this fade
EndStructure

;- tyDMXFadeItems
Structure tyDMXFadeItems
  Array aFadeItem.tyDMXFadeItem(512) ; nb array size will be increased if necessary to accommodate multiple delay times
  nMaxFadeItem.i
  nUniqueDelayTimeCount.i
EndStructure

;- tyLTChaseStep
Structure tyLTChaseStep
  nDMXSendItemCount.i
  Array aDMXSendItem.tyDMXSendItem(0)
  Array aFixtureItem.tyLTFixtureItem(0) ; contains 1 instance per fixture included in tySub array \sFixtureCode()
EndStructure

;- tyDMXChaseItem
Structure tyDMXChaseItem
  nStep.i
  nDMXChannel.i
  nDMXValue.i
EndStructure

;- tyDMXChaseItems
Structure tyDMXChaseItems
  nChaseCueCount.i
  bChaseRunning.i
  bMonitorTapDelay.i
  nChaseMode.i
  bBouncingBack.i
  bStopChase.i
  qLastItemTime.q
  qChaseStartTime.q
  qNextTtemTime.q
  nItemsProcessed.i
  nChaseSteps.i
  nLastStepProcessed.i
  nChaseControl.i ; uses enumeration #SCS_DMX_CHASE_CTL_... to indicate if the current chase running is controlled by the cue's BPM or the tap delay BPM
  nCueTimeBetweenSteps.i  ; time between steps derived from the sub-cue's BPM
  nTapTimeBetweenSteps.i  ; time between steps derived from the last use of tap delay, even if that's prior to running a cue that's not set to monitor tap delay
  nDefTimeBetweenSteps.i  ; time between steps derived from grProd\nDefChaseSpeed
  sCueChaseBPM.s
  sTapChaseBPM.s
  sDefChaseBPM.s
  nMaxChaseItem.i
  nChaseSubPtr.i      ; aSub() instance that initiated this chase
  nDMXDevPtr.i
  nDMXPort.i
  nDMXControlPtr.i
  bNextLTStopsChase.i ; next lighting cue stops chase
  bDisplayChaseIndicator.i
  qTimeDisplayChaseIndicatorSet.q
  nChaseIndHotLeft.i
  nChaseIndHotTop.i
  nChaseIndHotRight.i
  nChaseIndHotBottom.i
  Array aDMXChaseItem.tyDMXChaseItem(0)
EndStructure

;- tyDMXPreHotkeyItem
; Added 16Dec2020 11.8.3.4ab
Structure tyDMXPreHotkeyItem
  nDMXSendDataItemIndex.i
  nDMXValue.i
EndStructure

;- tyDMXPreHotkeyData
; Added 16Dec2020 11.8.3.4ab
Structure tyDMXPreHotkeyData
  nSubPtr.i
  Array aPreHotkeyItem.tyDMXPreHotkeyItem(0)
  nMaxPreHotkeyItem.i
EndStructure

;- tyDMXCurrChanValue
; Used for 'apply current DMX values as minimums', which was added to SCS for Lighting Cues activated by External Faders (11Jul2021 11.8.5as)
Structure tyDMXCurrChanValue
  nDMXChannel.i
  nDMXValue.i
EndStructure

;- tyLTSubFixture
Structure tyLTSubFixture
  sLTFixtureCode.s ; populated from cue file entries "LTFixtures" and "LTFixtureCode"
  nFixtureLinkGroup.b
  nLTMaxDMXStartChannelIndex.w
  Array aLTDMXStartChannel.w(0)
EndStructure

;- tyWQK for fmEditQK (Lighting Cues)
Structure tyWQK
  bInValidate.i
  nSelectedItem.i
  nSelectedFixture.i
  sSelectedLogicalDev.s
  nSelectedDevType.i
  ; nFixtureDisplay.i ; see Enumeration for #SCS_LT_DISP_...
  ; bLiveDMXTest is used for controlling live DMX testing, and set to the latest setting of WQK\chkLiveDMXTest. NOT reset per cue, sub-cue, etc, so latest setting is retained for this session.
  ; however, it is cleared on closing the editor
  bLiveDMXTest.i
  bProcessingReset.i ; Added 31Jul2020 11.8.3.2ap - see comments regarding \bProcessingReset in DMX_displayDMXSendData()
  bRunningLiveDMXTest.i
  nLiveDMXTestSubPtr.i
  bSingleStep.i
  bTestingChase.i
  nCurrItemIndex.i
  nCurrStepIndex.i
  bDoNotBlackoutOthers.i
  nFixtureComboboxesPopulatedForDevNo.i
  Array nChanIndex1.i(0)
  ; last lighting info
  sLastLTLogicalDev.s
  nLastBLFadeAction.i
  nLastBLFadeUserTime.i
  nLastDIFadeUpAction.i
  nLastDIFadeUpUserTime.i
  nLastDIFadeDownAction.i
  nLastDIFadeDownUserTime.i
  nLastDIFadeOutOthersAction.i
  nLastDIFadeOutOthersUserTime.i
  nLastFIFadeUpAction.i
  nLastFIFadeUpUserTime.i
  nLastFIFadeDownAction.i
  nLastFIFadeDownUserTime.i
  nLastFIFadeOutOthersAction.i
  nLastFIFadeOutOthersUserTime.i
  nLastDCFadeUpAction.i
  nLastDCFadeUpUserTime.i
  nLastDCFadeDownAction.i
  nLastDCFadeDownUserTime.i
  nLastDCFadeOutOthersAction.i
  nLastDCFadeOutOthersUserTime.i
  ; save initial dmx items for 'reset dmx items'
  nInitSubPtr.i
  nInitLTEntryType.i
  bInitChase.i
  nInitChaseSteps.i
  nInitChaseSpeed.i
  nInitChaseMode.i
  bInitNextLTStopsChase.i
  nInitMaxChaseStepIndex.i
  Array aInitChaseStep.tyLTChaseStep(0)
  nInitCurrItemIndex.i
  nInitCurrStepIndex.i
  nInitMaxFixture.i
  Array aInitLTFixture.tyLTSubFixture(0)
  bCapturingDMXSequence.i
  nDMXControlPtr.i
  nDMXCaptureNo.i
  qDMXCaptureTime.q
  nDMXCapturePort.i
  nItemId.i
  qTimeOfLastDisplayChange.q
  nCapturingDisplaySeq.i
  bStartingCapture.i ; Added 15Jun2023 11.10.0bg
EndStructure

;- tyWEM for fmEditModal
Structure tyWEM
  nPrevActiveWindow.i
  nSourceForm.i
  nSourceField.i
  sLabel.s
  sTitle.s ; Added 25Jan2023 11.9.9ac
  nDefaultWindowWidth.i
  nDefaultWindowHeight.i
  nHeightBelowMainContainer.i
  nCurrWindowWidth.i
  nCurrWindowHeight.i
  bAllowWindowResizeByUser.i
  nLoopInfoIndex.i
  bCntCuePoints.i
  bCntDMXStarts.i
  bCntFadeTime.i
  bCntScreens.i
  bCntCueMarkersUsage.i
  bCntTempoEtc.i
  bTxtChanged.i
  nDefFadeTime.i ; used in Live Input cues
  nDefFadeType.i ; used in Live Input cues
  nFirstCPIndex.i
  nLastCPIndex.i
  nSelectedRow.i
  nOrigSelectedRow.i
  sReqdCPName.s
  qReqdSamplePos.q
  qReqdCPBytePos.q
  dReqdCPTimePos.d
  nReqdTime.i
  nReqdFadeType.i
  sReqdDevMapName.s
  sOrigCPName.s
  qOrigSamplePos.q
  qOrigCPBytePos.q
  dOrigCPTimePos.d
  nOrigTime.i
  nOrigFadeType.i
  bMaxCuePointCuesReached.i
  Array aCheckedFile.s(0)
  Array aCheckedScreen.i(0)
  nCheckedScreenArraySize.i
  nNrCheckedFiles.i
  ; items saved (in the preferences file) between sessions
  sCntCueMarkersUsageDim.s
EndStructure

;- tyScribbleStripItem
Structure tyScribbleStripItem
  nSSSortKey.i
  sSSValType.s    ; to match a "ValType" in the CSRD "ValidValues", eg "Chan"
  nSSDataValue.i  ; a single component equivalent similar to digits used in tyCtrlSend\sRemDevValue, eg 1 for CH01
  sSSItemName.s   ; the scribble strip name, eg "Fred"
EndStructure

;- tyCtrlSend
Structure tyCtrlSend
  nCtrlSendIndex.i
  sCSLogicalDev.s
  nCSPhysicalDevPtr.i
  nDevType.i
  bMIDISend.i
  bRS232Send.i
  bNetworkSend.i
  bHTTPSend.i
  nMSMsgType.i    ; built-in msg type #SCS_MSGTYPE_..., or #SCS_MSGTYPE_NONE if sRemDevMsgType used (nMSMsgType and sRemDevMsgType/nRemDevMsgType are mutually exclusive)
  sRemDevMsgType.s  ; remote device msg type from CSRD
  nRemDevMsgType.i  ; (derived)
  nMSChannel.l
  nMSParam1.i
  nMSParam2.i
  nMSParam3.i
  nMSParam4.i
  sMSParam1.s ; sMSParam... used with callable cue parameter substitution
  sMSParam2.s
  sMSParam3.s
  sMSParam4.s
  sMSQNumber.s
  sMSQList.s
  sMSQPath.s
  nMSMacro.i
  nRemDevId.i ; derived
  nEntryMode.i            ; 0 = ASCII; 1 = HEX; 2 = ASCII+CTL (see #SCS_ENTRYMODE... enumeration)
  bAddCR.i                ; add CR to end of message?
  bAddLF.i                ; add LF to end of message?
  sEnteredString.s        ; string as entered by user
  sSendString.s           ; message to send
  Buffer.i                ; buffer in allocated memory containing data to be sent
  nBufLen.i               ; length of data in *Buffer
  sDisplayInfo.s          ; abbreviated info about this ctrl send message displayed in cue list, etc
  nAudPtr.i
  bIsOSC.i
  sOSCCmdType.s
  nOSCCmdType.i
  nOSCItemNr.i
  sOSCItemString.s
  bOSCItemPlaceHolder.i
  nOSCMuteAction.i
  bOSCReloadNamesGoScene.i    ; reload names after X32 'Go Scene'
  bOSCReloadNamesGoSnippet.i  ; reload names after X32 'Go Snippet'
  bOSCReloadNamesGoCue.i      ; reload names after X32 'Go Cue'
  nStartValue.i
  nTargetValue.i
  nFadeTime.i
  sCSItemDesc.s
  sMSParam1Info.s ; added for NRPN
  sMSParam2Info.s
  sMSParam3Info.s
  sMSParam4Info.s
  nRemDevMuteAction.i
  sRemDevValue.s ; eg "1-16,34,35"
  sRemDevValue2.s
  sRemDevLevel.s
  fRemDevBVLevel.f
  Array aScribbleStripItem.tyScribbleStripItem(0)
  nMaxScribbleStripItem.i
EndStructure

Structure tyScribbleStrip
  Array aScribbleStripItem.tyScribbleStripItem(0)
  nMaxScribbleStripItem.i
EndStructure

;- tyCtrlSendThreadItem
Structure tyCtrlSendThreadItem
  nSubPtr.i
  nCtrlSendIndex.i
  qNotBefore.q
  nState.i
  qTimeStarted.q
  nStartValue.i
  nTargetValue.i
EndStructure

;- tyCtrlSendSubData
Structure tyCtrlSendSubData
  nSubPtr.i
  nCtrlSendCount.i
  sCtrlSendPorts.s
  nCtrlSendPortCount.i
  nMidiCount.i
  nRS232Count.i
  nNetworkCount.i
  nDMXCount.i
  nHTTPCount.i
  nMidiSent.i
  nRS232Sent.i
  nNetworkSent.i
  nDMXSent.i
  nHTTPSent.i
  sCtrlSendSeqFails.s
  bCtrlSendError.i
  sCtrlSendPortName.s
  sCtrlSendInfo.s
  bOSCItemPlaceHolder.i
EndStructure

;- tyEnableDisable
Structure tyEnableDisable
  sFirstCue.s
  sLastCue.s
  nAction.i
EndStructure

;- ********** tySub
;- tySub ********
Structure tySub
  nSubId.i
  nSubRef.i
  ; Warning! nSubRef seems to serve the same function as nSubId, ie to provide every sub with a unique id during this session, so I don't know why nSubRef was created.
  ; However, I don't want to combine the two just yet, partly because pasteFromClipboard() contains code to 'reinstate generated sub id' but also generating a completely new and unique nSubRef.
  sCue.s                ; primary key col 1
  nSubNo.i              ; primary key col 2
  sSubDescr.s
  bDefaultSubDescrMayBeSet.i
  bSubPlaceHolder.i ; #True if this is a placeholder, which occurs if the user cancels the selection of an audio file when creating a new audio file sub-cue, and then accepts the request to create a placeholder.
  sSubType.s ; F = Audio File sub-cue; S = SFR sub-cue, etc. See 'SCS Cue Types' in TopLevel.pbi.
  bSubEnabled.i   ; nb not necessary to have a bSubCurrentlyEnabled field as Sub Type J operates exclusively on cues, not sub-cues,
                  ; so bSubEnabled will always be the 'current' enabled state as well as the saved enabled state
  nSubStart.i
  nRelStartTime.i
  nRelStartMode.i
  sRelStartSyncWithSub.s
  sSubCueMarkerName.s
  nSubCueMarkerAudNo.i
  nSubCueMarkerAudId.i ; (derived)
  nSubCueMarkerId.i ; (derived)
  nRelMTCStartTimeForSub.i  ; hh:mm:ss:ff
  nCalcMTCStartTimeForSub.i ; (derived) hh:mm:ss:ff
  
  ;- - Sub: audio file fields (type F)
  nAFLinkedToMTCSubPtr.i

  ;- - Sub: SFR fields (type S)
  nSFRAction.i[#SCS_MAX_SFR+1]
  nSFRCueType.i[#SCS_MAX_SFR+1]
  sSFRCue.s[#SCS_MAX_SFR+1]
  nSFRSubNo.i[#SCS_MAX_SFR+1]
  nSFRLoopNo.i[#SCS_MAX_SFR+1]
  nSFRReleasedLoopInfoIndex.i[#SCS_MAX_SFR+1]
  nSFRTimeOverride.i
  sSFRTimeOverride.s ; time override if set to a callable cue parameter
  bSFRCompleteAssocAutoStartCues.i
  bSFRHoldAssocAutoStartCues.i
  bSFRGoNext.i
  nSFRGoNextDelay.i
  
  ;- - Sub: playlist fields (type P)
  ; the following for each required logical device for playlists and slideshows
  sPLLogicalDev.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]   ; playlists only
  sPLTracks.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sPLDBTrim.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sPLMastDBLevel.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fPLPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nPLFadeInTime.i
  nPLFadeOutTime.i
  bPLRandom.i
  bPLRepeat.i          ; #True if playlist or videolist continuous
  bPLRepeatCancelled.i ; set #True by an SFR cue with the action 'Cancel Repeat'
  bPLSavePos.i         ; for playlist sub-cues, save playback position for next SCS session
  ; playlist fields from database, as at time of loading cue file
  sPLListOrder.s
  nPLAudNoLastPlayed.i ; used in conjunction with 'save playback position' (see Playlist Cues in Help file), where the playback position is saved in the production database
  bPLDatabaseInfoLoaded.i
  bPLPlayOrderSyncedWithPrimary.i
  
  ;- - Sub: video/image fields (including video capture) (type A)
  sScreens.s  ; all selected output screens, including primary (added 11.7.0), eg 3,5,6
  nOutputScreen.i   ; primary output screen (only output screen pre 11.7.0), eg 3
  Array bOutputScreenReqd.i(#SCS_VID_PIC_TARGET_LAST)
  nSubMaxOutputScreen.i ; maximum selected screen eg is sScreens = "3,5,6" then nMaxOutputScreen will be set to 6
  sVidAudLogicalDev.s
  nVideoAudioDevPtr.i
  bMuteVideoAudio.i
  bPauseAtEnd.i   ; #True if user has requested 'pause at end' for this sub in the cue file
  bMayUseGaplessStream.i  ; this video/image field not yet implemented
  bUseNew2DDrawing.i
  
  ;- - Sub: level change fields (type L)
  nLCCueType.i
  sLCCue.s
  nLCSubNo.i
  bLCSameTime.i
  bLCSameLevel.i
  sLCReqdDBLevel.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCReqdPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nLCTime.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sLCTime.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1] ; level-change time if set to a callable cue parameter
  bLCInclude.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bLCDevPresent.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  ; nLCAbsRel.i    ; Deleted 20Aug2021 11.8.6, superceded by nLCAction
  nLCAction.i      ; Added 20Aug2021 11.8.6, supercedes nLCAbsRel
  fLCActionValue.f ; Added 20Aug2021 11.8.6
  nLCActionTime.i
  nLCType.i
  nLCStartAt.i
  
  ;- - Sub: control-send fields (type M)
  aCtrlSend.tyCtrlSend[#SCS_MAX_CTRL_SEND+1]
  
  ;- - Sub: lighting fields (type K)
  sLTLogicalDev.s
  nLTDevType.i
  nLTEntryType.i
  sLTDisplayInfo.s  ; abbreviated info displayed in cue list, etc
  bDMXSend.i
  ; fade actions and times for entry type 'Fixture'
  nLTFIFadeUpAction.i
  nLTFIFadeUpUserTime.i
  nLTFIFadeDownAction.i
  nLTFIFadeDownUserTime.i
  nLTFIFadeOutOthersAction.i
  nLTFIFadeOutOthersUserTime.i
  ; the following added for use with callable cue parameters, eg where the user may set F1 for the fixture fade up time, F2 for the fixture fade down time, etc
  sLTFIFadeUpUserTime.s
  sLTFIFadeDownUserTime.s
  sLTFIFadeOutOthersUserTime.s
  ; fade action and time for entry type 'Blackout'
  nLTBLFadeAction.i
  nLTBLFadeUserTime.i
  ; the following added for use with callable cue parameters, eg where the user may set B1 for the blackout fade time
  sLTBLFadeUserTime.s
  ; fade actions and times for entry type 'DMX Items'
  nLTDIFadeUpAction.i
  nLTDIFadeUpUserTime.i
  nLTDIFadeDownAction.i
  nLTDIFadeDownUserTime.i
  nLTDIFadeOutOthersAction.i
  nLTDIFadeOutOthersUserTime.i
  ; the following added for use with callable cue parameters, eg where the user may set D1 for the DMX item fade up time, D2 for the DMX item fade down time, etc
  sLTDIFadeUpUserTime.s
  sLTDIFadeDownUserTime.s
  sLTDIFadeOutOthersUserTime.s
  ; fade actions and times for entry type 'DMX Capture Snapshot'
  nLTDCFadeUpAction.i
  nLTDCFadeUpUserTime.i
  nLTDCFadeDownAction.i
  nLTDCFadeDownUserTime.i
  nLTDCFadeOutOthersAction.i
  nLTDCFadeOutOthersUserTime.i
  ; the following added for use with callable cue parameters, eg where the user may set DC1 for the DMX capture fade up time, DC2 for the DMX capture fade down time, etc
  sLTDCFadeUpUserTime.s
  sLTDCFadeDownUserTime.s
  sLTDCFadeOutOthersUserTime.s
  ;
  nDMXControlPtr.i
  sDMXSendString.s
  bChase.i
  nChaseMode.i
  nChaseSteps.i
  nChaseSpeed.i   ; speed in beats per minute (bpm)
  bMonitorTapDelay.i
  nMaxChaseStepIndex.i
  bNextLTStopsChase.i ; next lighting cue stops chase
  Array aChaseStep.tyLTChaseStep(0)
  ; Added 16Aug2018 11.7.2
  nMaxFixture.i
  Array aLTFixture.tyLTSubFixture(0)
  ; Added 28Jul2020 11.8.3.2
  nLTCaptureMode.i
  nLTCaptureTime.i
  sLTCaptureData.s
  nDMXPreHotkeyDataIndex.i ; Added 16Dec2020 11.8.3.4ab
  ; Added 11Jul2021 11.8.5as
  bLTApplyCurrValuesAsMins.i
  nLTMaxCurrChanValue.i
  Array aLTCurrChanValue.tyDMXCurrChanValue(0)
  ; End added 11Jul2021 11.8.5as

  ;- - Sub: 'go to cue' fields (type G)
  sCueToGoTo.s
  bGoToCueButDoNotStartIt.i ; Added 28Jan2021 11.8.3.5
  
  ;- - Sub: 'set position' fields (type T)
  nSetPosCueType.i  ; Added 7Jun2022 11.9.2
  sSetPosCue.s
  nSetPosTime.i
  nSetPosAbsRel.i
  nSetPosCueMarkerSubNo.i
  sSetPosCueMarker.s
  
  ;- - Sub: MTC/LTC fields (type U)
  nMTCType.i                ; MTC or LTC as specified in the enumeration #SCS_MTC_TYPE_...
  nMTCStartTime.i           ; hh:mm:ss:ff
  nMTCFrameRate.i           ; value in the enumeration #SCS_MTC_FR_...
  nMTCPreRoll.i
  nMTCDuration.i
  nMTCMSAtLinkedAudStart.i  ; 'current' MTC millisecond time when a linked aud starts - used for determining MTC reposition point
  nTCGenIndex.i
  nMTCStartOrRestartTimeCodeSync.l
  
  ;- - Sub: memo fields (type E)
  sMemoRTFText.s
  bMemoContinuous.i
  nMemoDisplayTime.i
  nMemoDisplayWidth.i
  nMemoDisplayHeight.i
  nMemoDesignWidth.i
  ; nMemoDesignHeight.i ; design height not currently required as SCS calculates design height as (design width * 9 / 16)
  nMemoPageColor.l
  nMemoTextBackColor.l
  nMemoTextColor.l
  nMemoScreen.i
  bMemoResizeFont.i
  nMemoAspectRatio.i
  sMemoSyncCue.s
  nMemoSyncSubNo.i
  
  ;- - Sub: 'run program' fields (type R)
  sRPFileName.s
  sRPParams.s
  sRPStartFolder.s
  bRPHideSCS.i
  bRPInvisible.i
  
  ;- - Sub: 'call cue' fields (type Q)
  nCallCueAction.i
  sCallCue.s
  nCallCuePtr.i
  nSelHKBank.i
  sCallCueParams.s
  Array aCallCueParam.tyCallCueParam(0) ; derived from sCallCueParams
  nMaxCallCueParam.i ; derived
  
  ;- - Sub: enable/disable fields (type J)
  aEnableDisable.tyEnableDisable[#SCS_MAX_ENABLE_DISABLE+1]
  
  ; --------------------------------- derived sub fields
  bExists.i
  nCueIndex.i           ; pointer to parent cue
  nNextSubIndex.i       ; pointer to next sub cue for this cue (-1 if last)
  nPrevSubIndex.i       ; pointer to previous sub cue for this cue (-1 if first)
  nFirstAudIndex.i      ; pointer to first audio file component (-1 if none)
  nFirstPlayIndex.i     ; pointer to first audio file component to be played (-1 if none)
  nFirstPlayIndexThisRun.i ; as nFirstPlayIndex unless a playlist with a 'saved' position
  nLastPlayIndex.i
  nCurrPlayIndex.i
  bSubTypeA.i
  bSubTypeE.i
  bSubTypeF.i
  bSubTypeG.i
  bSubTypeI.i
  bSubTypeJ.i
  bSubTypeK.i
  bSubTypeL.i
  bSubTypeM.i
  bSubTypeN.i
  bSubTypeP.i
  bSubTypeQ.i
  bSubTypeR.i
  bSubTypeS.i
  bSubTypeT.i
  bSubTypeU.i
  bSubTypeHasAuds.i
  bSubTypeHasDevs.i
  bSubTypeAorF.i
  bSubTypeAorP.i
  bSubTypeForP.i
  bLiveInput.i
  nSubState.i
  nM2TItemIndex.i
  nAudCount.i
  nImageCount.i
  nVideoCount.i
  bHotkey.i
  bExtAct.i ; external activation (eg #SCS_ACMETH_EXT_TRIGGER)
  bCallableCue.i
  qTimeToStartSub.q
  qTimeSubStarted.q
  bTimeSubStartedSet.i
  qTimeSubRestarted.q
  nSubCountDownTimeLeft.i
  bPlaySubInMainThread.i
  bSubCountDownPaused.i
  qTimeSubCountDownPaused.q
  bStopSubEventPosted.i
  sSubLabel.s
  nBackColor.l
  nTextColor.l
  qTimeSubLastEdited.q
  nTotalTimeOnGlobalPause.i
  nTransportSwitchIndex.i
  nTransportSwitchCode.i
  bHibernating.i
  bFadingPreHibernating.i
  bStartedInEditor.i
  bSubCompletedBeforeOpenedInEditor.i
  nSubStateBeforeOpenedInEditor.i
  bMajorChangeInEditor.i
  bSetLevelsWhenPlaySub.i
  bIgnoreInStatusCheck.i
  bIgnoreInStatusCheckLogged.i
  bSubUseGaplessStream.i
  nSubGaplessSeqPtr.i
  bSubContainsGapless.i
  bLockMixerStreamsOnPlaySub.i
  bSubGloballyPaused.i
  
  nMTCLinkedToAFSubPtr.i  ; used for MTC sub-cues
  nSubDuration.i
  nSubPosition.i
  qAdjTimeSubStarted.q        ; similar to nTimeSubStarted but may be adjusted on repositioning the sub
  nSubTotalTimeOnPause.i
  qSubTimePauseStarted.q
  nSubPriorTimeOnPause.i
  nSubPrepauseSubState.i
  bSubCheckProgSlider.i
  
  nPLBassDevice.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bPLASIO.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nPLBassASIODevice.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSubTrimFactor.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSubMastBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSubBVLevelNow.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSubPanNow.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bSubDisplayPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nOutputDevMapDevPtr.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  qPLTimeFadeInStarted.q
  qPLTimeFadeOutStarted.q
  bPLFadingIn.i
  bPLFadingOut.i
  bPLTerminating.i
  nPLCuePosition.i
  sPlayOrder.s
  nPlayOrderAudNo.i
  nPLFirstPlayNoThisPass.i
  nPLCurrFadeInTime.i
  nPLCurrFadeOutTime.i
  nPLTotalTime.i
  nPLTestTime.i
  nPLUnplayedFilesTime.i
  nPLAudPlayCount.i
  
  nSFRCuePtr.i[#SCS_MAX_SFR+1]
  nSFRSubPtr.i[#SCS_MAX_SFR+1]
  nSFRSubRef.i[#SCS_MAX_SFR+1]
  bSFRFadeInOnResume.i
  
  nLCCuePtr.i
  nLCSubPtr.i
  nLCSubRef.i
  nLCAudPtr.i
  sLCLogicalDev.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nLCMaxLogicalDev.i
  fLCReqdBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCTargetBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sLCDBTrim.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCTrimFactor.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCInitBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCInitPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCBVLevelWhenStarted.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCPanWhenStarted.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nLCPosition.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bLCActive.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nLCPositionMax.i
  bLCCalcSameTimeInd.i
  bLCCalcSameLevelInd.i
  nLCTimeMax.i
  bLCTargetIsA.i
  bLCTargetIsF.i
  bLCTargetIsI.i
  bLCTargetIsP.i
  nLCCtrlSubPtr.i   ; on target sub
  
  bSetStandby.i
  bTestingLevelChange.i
  bCalculatingDMXStartValuesOnly.i ; Added 30Sep2024 11.10.6ad
  
  sSubSetGainCommandString.s
  sSubPlayCommandString.s
  sSubFinalSetGainCommandString.s   ; used at the end of a level-change to accurately set the required level, instead of the approximate level achieved via 'gainmidi'
  
  nNrOfInputChans.i
  
  ; the following used by the production editor
  nPreEditPtr.i
  sValidatedSubDescr.s
  nNodeKey.i
  sErrorMsg.s
  
EndStructure

;- tyLevelPointItem
Structure tyLevelPointItem
  sItemLogicalDev.s
  sItemTracks.s
  nItemDevNo.i
  nItemGraphChannels.i
  bItemInclude.i
  fItemRelDBLevel.f
  fItemPan.f
  fItemSyncRelDBLevel.f
EndStructure

;- tyLevelPoint
Structure tyLevelPoint
  nPointTime.i              ; primary key (within an aAud() entry)
  nPointType.i
  nPointId.i                ; unique id
  sPointDesc.s
  sPanPointDesc.s
  nPointMaxItem.i
  Array aItem.tyLevelPointItem(0) ; dev/track level point detail
EndStructure

;- tyLevelPointItemHold
Structure tyLevelPointItemHold
  aLevelPointIndex.i
  aLevelPointOriginalPointTime.i
  aItem.tyLevelPointItem
EndStructure

;- tyCurrentLevelPointHold
Structure tyCurrentLevelPointHold
  nPointTime.i
  nPointIndex.i
  fOriginalRelDBLevel.f
EndStructure

;- tyLevelPointRunTime
Structure tyLevelPointRunTime
  nFromTime.i
  nFromType.i
  fFromLevel.f
  fFromPan.f
  nToTime.i
  nToType.i
  fToLevel.f
  fToPan.f
  bNoChange.i         ; #True if fToLevel = fFromLevel and fToPan = fFromPan
  bSuspendItemProc.i  ; suspend processing of this level point item (may be set when an associated SFR or Level Change cue is activated)
  fFromRelDBLevel.f   ; set by loadLvlPtRun(); required by recalcLvlPtLevels()
  fToRelDBLevel.f     ; ditto
EndStructure

;- tyLevelNode
Structure tyLevelNode
  nNodeType.i
  nNodeTime.i
  nFadeType.i
EndStructure

;- tyCtrlHoldLevelPoint
Structure tyCtrlHoldLevelPoint
  nLPPointId.i
  bLPSelected.i  
EndStructure

;- audio and video file properties
; --------------
; notes on times
; --------------
; nStartAt, nEndAt, nLoopStart and nLoopEnd are times as entered by the user.
; They are absolute times but with special negative values (-1, -2 and -3).

; nAbsStart, nAbsEndAt, nAbsLoopStart and nAbsLoopEnd are actual absolute times
; after processing of the special negative values.

; nAbsMin is derived from the lower of nAbsStartAt and nAbsLoopStart.
; If no looping is required the nAbsMin = nAbsStartAt.

; nAbsMax is derived from the higher of nAbsEndAt and nAbsLoopEnd.
; If no looping is required the nAbsMax = nAbsEndAt.

; nCueDuration = nAbsMax - nAbsMin as this represents the part of the file that
; will be played.  This is therefore used in setting the range of the progress slider.

; nRelStartAt, nRelEndAt, nRelLoopStart and nRelLoopEnd are the respective times
; relative to nAbsMin, so define the respective positions within the progress slider.

;- tyLoopInfo
Structure tyLoopInfo
  bContainsLoop.i
  sLoopId.s
  nLoopStart.i        ; loop start as recorded in the cue file, ie as the absolute time value (time within file), or -2 if blank
  nLoopEnd.i          ; similar to above
  sLoopStartCPName.s
  sLoopEndCPName.s
  qLoopStartSamplePos.q
  qLoopEndSamplePos.q
  nLoopXFadeTime.i
  nNumLoops.i
;   bLoopLinked.i     ; added 2Nov2015 11.4.1.2g
  ; derived fields
  dLoopStartCPTime.d
  dLoopEndCPTime.d
  qLoopStartByte.q
  qLoopStartBytePos.q
  qLoopEndBytePos.q
  qLoopEndByteXFade.q
  qLoopEndByteLE.q
  bLoopReleased.i
  nAbsLoopStart.i
  nAbsLoopEnd.i
  nRelLoopStart.i
  nRelLoopEnd.i
  qBassLoopStartByte.q
  bDisplayedLoop.i  ; only used in valAud()
  nBassLoopSyncStart.l
  nBassAltLoopSyncStart.l
  nBassLoopSyncHearXFade.l
  nBassLoopSyncHearLE.l
  nBassLoopSyncHearBoth.l
  nBassLoopSyncMixTime.l
  nBassAltLoopSyncHearXFade.l
  nBassAltLoopSyncHearLE.l
  nBassAltLoopSyncHearBoth.l
  nBassAltLoopSyncMixTime.l   ; used if this loop does not have cross-fade but at least one other loop does have a cross-fade (hence there will be an 'alt' channel)
  nLoopSyncIndex.i            ; pointer to array gaLoopSync(), which is used for both BASS and SMS
  nSMSLoopSyncPointIndex1.i   ; pointer (or 'handle') to gaSMSSyncPoint(), which is used for SMS to support similar functionality to BASS sync points such as nBassAltLoopSyncMixTime
  nSMSLoopSyncPointIndex2.i   ; ditto
EndStructure

;- tyLoopSync
Structure tyLoopSync
  bActive.i               ; #True if this entry is in use
  nAudPtr.i
  nLoopInfoIndex.i
  nDevNo.i                ; devNo of first sounding dev (which is what loop sync hear's are based on)
  nChannel.l              ; for nDevNo
  nAltChannel.l           ; for nDevNo
  nSourceChannel.l
  nSourceAltChannel.l
  nLoopXFadeTime.i
  nLoopSyncPassNo.i
  nLoopSyncPassesReqd.i
  bInXfade.i
  bChannelSwapAtXFade.i   ; #True if channel swap to occur at XFade; false if channel swap to occur at LE (default)
  bSwapped.i              ; #True if nChannel and nAltChannel have been swapped
  bSwitchAtXFade.i
  bSwitchAtLE.i
EndStructure

;- tyPlayAud
Structure tyPlayAud
  nAudPtr.i
  nPlayNo.i
EndStructure

;- tyFile
Structure tyFile
  nFileNo.i
  nThisSeq.i
EndStructure

; CS Added 24/01/2018 - Cue Markers
;- tyCueMarker
Structure tyCueMarker
  ; NOTE: fields populated from and saved in the cue file
  sCueMarkerName.s      ; eg "Mk1"
  nCueMarkerPosition.i  ; time of this cue marker in milliseconds from the start of the file, regardless of the cue's 'start at' position.
  ; NOTE: derived fields
  nCueMarkerType.i      ; see enumeration #SCS_CMT_... Distinguishes between a cue marker (#SCS_CMT_CM) and a cue point in an audio file (#SCS_CMT_CP).
  nCueMarkerId.i        ; a unique id generated this run and retained with this cue marker for the duration of the run - NOT saved to the cue file but re-generated each run.
  ; NOTE: fields used by BASS for cue markers/cue points in an audio file (SubType F)
  ; BASS provides very precise cue marker processing as we can record the byte position of the cue marker/cue point.
  nBassMarkerSync.l
  nBassMarkerAltSync.l
  nBassMarkerSyncChannel.l
  nBassMarkerAltSyncChannel.l
  qBassMarkerByte.q
  ; NOTE: fields used by TVG for cue markers in a video file (SubType A)
  ; Cue marker processing using TVG uses the Frame Position callback - TVG_SetOnFrameProgress2() - so video file cue markers will be frame-precise.
  ; However, tests indicate we cannot predict the actual frame number, even by using the frame rate, so we set a time range (min and max) in which we will detect the first frame that meets the cue marker position.
  ; The min and max fields are stored as quads as TVG's *frameinfo\frametime is a quad.
  ; These fields are set in setTVGMarkerPositions().
  qMinFrameTimeForCueMarker.q ; This will be set to nCueMarkerPosition minus half the time of a frame (based on the frame rate).
  qMaxFrameTimeForCueMarker.q ; This will be set to nCueMarkerPosition plus the time of a couple(?) of frames to ensure the value returned by TVG in *frameinfo\frametime is definitely within the min and max times here.
  bCueMarkerProcessed.i       ; Set #True when we have processed the cue marker, to ensure we do not process it a second time by the next reported *frameinfo\frametime. Cleared on opening the file, etc.
EndStructure

;- tyCueMarkerInfo
Structure tyCueMarkerInfo
  nCueMarkerType.i      ; see enumeration #SCS_CMT_... Distinguishes between a cue marker (#SCS_CMT_CM) and a cue point in an audio file (#SCS_CMT_CP)
  nCueMarkerId.i        ; a unique id generated this run and retained with this cue marker for the duration of the run - NOT saved to the cue file but re-generated each run
  sHostCue.s            ; the host aCue() entry of this cue marker
  nHostCuePtr.i         ; the host aCue() entry of this cue marker
  nHostSubNo.i          ; the host aSub()\nSubNo of this cue marker
  nHostSubId.i          ; the host aSub()\nSubId of this cue marker
  nHostAudNo.i          ; the host aAud()\nAudNo of this cue marker
  nHostAudId.i          ; the host aAud()\nAudId of this cue marker
  nHostAudPtr.i         ; the host aAud() entry of this cue marker
  sCueMarkerName.s      ; eg "M1"
  nCueMarkerPosition.i  ; time of this cue marker in milliseconds from the start of the file, regardless of the cue's 'start at' position
  sCueMarkerDisplayInfo.s ; as displayed in main window's 'Activation' column, cue display panels, and editor's auto-activation cue combobox for OCM. EG "Q1 M1 (12.5 as Q1)"
  sCueMarkerDisplayInfoShort.s ; as sCueMarkerDisplayInfo but without the leading aAud() info
  bOCMAvailable.i       ; intended for use with cue points: #True if OCM available, ie if the cue point is between the absolute 'start at' and 'end at' of the associated aAud
EndStructure

;- tyOCMMatrixItem
Structure tyOCMMatrixItem
  nCueMarkerId.i
  nOCMCuePtr.i
  nOCMSubPtr.i
  nOCMAudPtr.i
EndStructure

;- tyCueMarkerFile
Structure tyCueMarkerFile
  nAudPtr.i
  sFileName.s
EndStructure

;- tyAudScreenInfo
Structure tyAudScreenInfo
  nAudOutputScreen.i
  nAudVidPicTarget.i
  nAudTargetImageNo.i
EndStructure

;- *********** tyAud
;- tyAud ********
Structure tyAud
  nAudId.i
  sCue.s                ; primary key col 1
  nSubNo.i              ; primary key col 2
  nAudNo.i              ; primary key col 3 (eg PL track no.)
  sStoredFileName.s
  bAudPlaceHolder.i
  sAudDescr.s
  nStartAt.i
  nEndAt.i
  sStartAtCPName.s
  sEndAtCPName.s
  qStartAtSamplePos.q
  qEndAtSamplePos.q
  nFadeInEntryType.i
  nFadeOutEntryType.i
  nFadeInTime.i     ; user-specified for type F; derived from nPLTransTime for type P
  nFadeOutTime.i    ; ditto
  nFadeInMSPos.i    ; fade-in millisecond position
  nFadeOutMSPos.i   ; fade-out millisecond position
  sFadeInTime.s     ; fade-in time if set to a callable cue parameter
  sFadeOutTime.s    ; fade-out time if set to a callable cue parameter
  sFadeInCPName.s
  sFadeOutCPName.s
  qFadeInSamplePos.q
  qFadeOutSamplePos.q
  nFadeInType.i
  nFadeOutType.i
  nCuePosTimeOffset.i
  ; the following for each required logical device
  sLogicalDev.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bIgnoreDev.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sTracks.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sDBTrim.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sDBLevel.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nTransportSwitchIndex.i
  nTransportSwitchCode.i
  nGraphChan.l    ; long
  fPLRelLevel.f
  nPLTransType.i
  nPLTransTime.i
  nPLRunTimeTransType.i ; Added 4Jul2023 11.10.0bn
  nPLRunTimeTransTime.i ; Added 4Jul2023 11.10.0bn
  bFullScreen.i
  nRotate.i       ; 0 = no rotate; 90/180/270 = rotate 90/180/270 degrees
  nFlip.i         ; 0 no flip; 1 = flip horizontal; 2 = flip vertical; 3 = flip horizontal and vertical
  bContinuous.i   ; see also bDoContinuous later in this structure
  bLogo.i
  bOverlay.i
  sInputLogicalDev.s[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  sInputDBLevel.s[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  bInputOff.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  bInputCurrentlyOff.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]  ; run-time 'off' state
  bSyncLevels.i
  nLvlPtLvlSel.i            ; level selection
  nLvlPtPanSel.i            ; pan selection
  nMaxLevelPoint.i
  Array aPoint.tyLevelPoint(0)
  nVideoSource.i ; as per Enumeration #SCS_VID_SRC_...
  nVideoASIOStream.l
  nAudCalcRelStartTime.i ; Added 16Jan2021 for 'Move to Time' on video/image cues
  
  ; loop info
  nMaxLoopInfo.i
  Array aLoopInfo.tyLoopInfo(0)
  rCurrLoopInfo.tyLoopInfo  ; current loop info
  nCurrLoopInfoIndex.i      ; loop info index of rCurrLoopInfo
  bLoopLinked.i     ; added 2Nov2015 11.4.1.2g
  ; the following apply to the current loop
  nCuePosAtLoopStart.i
  fBVLevelAtLoopEnd.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nLoopPassNo.i
  nRelPassStart.i   ; relative position of start of the current pass
  nRelPassEnd.i
  qTimePassStarted.q
  bUsingBassLoop.i
  
  ; tempo and pitch info
  nAudTempoEtcAction.i
  fAudTempoEtcValue.f
  
  ; normalization info
  bAudNormSet.i ; This will be set #True if the normalization info for this aAud() file has been set.
                ; bAudNormSet is set #False by any event that could invalidate the saved results such as changing the selected file, changing the start at position, etc.
                ; The following three fields are saved (if bAudNormSet = #True) in the cue file in a single entry: "AudNormInfo".
  fAudNormIntegrated.f
  fAudNormPeak.f
  fAudNormTruePeak.f
  
  ; --------------------------------- derived aud fields
  bExists.i
  nCueIndex.i           ; pointer to grand parent cue
  nSubIndex.i           ; pointer to parent sub cue
  nPrevAudIndex.i       ; pointer to previous track for this playlist (-1 if first)
  nNextAudIndex.i       ; pointer to next track for this playlist (-1 if last)
  nPrevPlayIndex.i      ; pointer to previous track for this playlist (-1 if first)
  nNextPlayIndex.i      ; pointer to next track for this playlist (-1 if last)
  nPlayNo.i
  bAudTypeA.i
  bAudTypeF.i
  bAudTypeI.i
  bAudTypeM.i
  bAudTypeP.i
  bAudTypeAorF.i
  bAudTypeAorP.i
  bAudTypeForP.i
  bLiveInput.i
  nAudState.i
  nM2TItemIndex.i
  nFirstDev.i
  nLastDev.i
  nFirstSoundingDev.i   ; first dev that is not marked as 'bIgnoreDev'
  nLastSoundingDev.i    ; last dev that is not marked as 'bIgnoreDev'
  nSoundingDevCount.i
  nFirstInputDev.i
  nLastInputDev.i
  nPrepauseAudState.i
  nFileState.i
  nAltFileState.i
  sFileName.s
  sFileExt.s
  sFileTitle.s
  nFileDataPtr.i        ; index to array gaFileData(), or -1 if not set
  nFileStatsPtr.i       ; index to array gaFileStats(), or -1 if not set, -2 if to be excluded (eg because duration too long for scanning)
  sDriver.s
  bFileOpenFailNotified.i
  sFileType.s
  nFileDuration.i
  nFileChannels.i
  qFileBytes.q
  qFileBytesForTenSecs.q
  sAudLabel.s
  nFileFormat.i
  nBytesPerSamplePos.i
  nSampleRate.i
  nBytesPerSec.i
  qStartAtBytePos.q
  qEndAtBytePos.q
  dStartAtCPTime.d
  dEndAtCPTime.d
  bMidiFile.i
  sMidiAlias.s
  sMidiMode.s
  nSourceWidth.l
  nSourceHeight.l
  ; nVidPicSrcWidth.i     ; width of source image/video, ie before resizing
  ; nVidPicSrcHeight.i    ; height of source image/video, ie before resizing
  bMediaStarted.i         ; used with video files to make sure bMediaEnded isn't set immediately, as PB MovieStatus() returns 0 for 'stopped' but also if it hasn't yet started
  bMediaEnded.i
  bPlayNextAudRequested.i
  nAudVidPicTarget.i
  nVideoPlayState.i
  nVideoPosition.i
  bDelayHide.i
  bInfoObtained.i
  nAlphaBlend.i
  bBlending.i
  sPlayableFileName.s
  qTimePlayOrReposIssued.q
  bInsufficientSMSPlaybacks.i
  bTVG_OpenPlayerFailed.i
  bWaitForLinkSyncPos.i
  bAudChannelsStopped.i
  bOKForSMS.i
  bOKForAnalyzeFile.i
  qInitialGetPosition.q
  nManualOffset.i
  nVideoPlaybackLibrary.i
  bPrimeVideoReqd.i
  nPrimeVideoVidPicTarget.i
  bResetFilePosToStartAtInMain.i
  nVideoRotation.i              ; rotation value obtained from mmediainfo.dll
  bTVGCropping.i
  nTVGCroppingX.l
  nTVGCroppingY.l
  nTVGCroppingWidth.l
  nTVGCroppingHeight.l
  dTVGCroppingZoom.d
  bCallSetWindowVisible.i
  
  bOpenWithPrevAud.i            ; #True if image aud to be opened when previous play aud in 'slide show' is opened - intended for short-duration prev aud
  
  bUsingShellThumbnail.i
  
  ; image info
  bReloadImage.i
  bReRotateImage.i
  bReRotatePosImage.i
  bReloadMainImage.i
  nLoadImageNo.i                ; if picture then image no. returned by PB command LoadImage(); if video then image no. returned by PB command CopyImage() when creating the video frame
  nImageFrameCount.i
  nImageAfterRotateAndFlip.i    ; image after applying any required rotation and flipping, but BEFORE resizing or rescaling, or resizing for target
  nPosLoadImageNo.i             ; image no. for current position if user dragged position slider in editor
  nPosImageAfterRotateAndFlip.i ; image no. for current position if user dragged position slider in editor, after applying any required rotation and flipping, but before resizing etc
  nPosImagePos.i                ; position of nPosImageNo
  nThumbnailImageNo.i
  nMainVideoNo.i
  nPreviewVideoNo.i
  nPlayVideoNo.i                ; VideoNo (nMainVideoNo or nPreviewVideoNo) as used in the most recent PlayVideo() call
  nMainTVGIndex.i
  nPreviewTVGIndex.i
  nPlayTVGIndex.i               ; TVGIndex (nMainTVGIndex or nPreviewTVGIndex) as used in the most recent PlayVideo() call
  nAudMonitorCanvasNo.i
  bDoContinuous.i               ; #True if last image file and is to be played continuously, either because bContinuous = #True, or aSub()\bPLRepeat = #True and this is the only Aud in the Sub
  bIgnoreInStatusCheck.i
  bIgnoreInStatusCheckLogged.i
  nFadeOutExtraTime.i
  bInForcedFadeOut.i
  nMemoryImageNo.i              ; Image (full-size) adjusted by \nXPos, \nYPos and \nSize, if \nXPos or \nYPos are non-zero. Added for playing via TVG.
  bUsingMemoryImage.i
  nSelectedFrameIndex.i
  nAnimatedImageTimer.i
  bCancelAudAnimation.i
  Array nVidPicTargetImageNo.i(#SCS_VID_PIC_TARGET_LAST) ; (adjusted) image resized for each required target in the range #SCS_VID_PIC_TARGET_F2 to #SCS_VID_PIC_TARGET_LAST
  Array nDisplayLeft.i(#SCS_VID_PIC_TARGET_LAST)
  Array nDisplayTop.i(#SCS_VID_PIC_TARGET_LAST)
  Array nDisplayWidth.i(#SCS_VID_PIC_TARGET_LAST)
  Array nDisplayHeight.i(#SCS_VID_PIC_TARGET_LAST)
  Array nAudVideoCanvasNo.i(#SCS_VID_PIC_TARGET_LAST)
  
  Array aScreenInfo.tyAudScreenInfo(0)
  nMaxScreenInfo.i
  
  bBetweenMixAndHearSyncPoints.i
  bStopCompleted.i
  bPlayEndSyncOccurred.i
  bSetLevelsWhenPlayAud.i
  
  nPrimaryChan.i          ; primary SM-S playback channel (ptr to gaPlaybacks() array)
  sPPrimaryChan.s
  sAudPChanList.s         ; playback channels for this audio file (one channel per track), eg "p3 p4" for a stereo file
  sAudPXChanList.s        ; playback crosspoint channels for this audio file (one channel per track per device), eg "px3.0 px4.1" for a stereo file to a stero output
  sSyncPChanList.s        ; playback channels for this audio file PLUS playback channels for audio files LINKED to this audio file
  sSyncPXChanList.s       ; playback crosspoint channels for this audio file PLUS playback crosspoint channels for audio files LINKED to this audio file
  sSyncSetGainList.s      ; set gain settings for this audio file PLUS playback channels for audio files LINKED to this audio file
  bSyncPChanListPlaying.i ; #True only if a 'play' command is active using sSyncPChanList for _this_ aAud()
  sDevPXChanListLeft.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sDevPXChanListRight.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sDevPXDownMix.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1] ; "DM" if stereo-to-mono downmix (info required for SoundMan-Server set gaindb commands)
  sDevXChanListLeft.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]  ; input/output crosspoints per output - used for adjusting output levels, not for adjusting input levels
  sDevXChanListRight.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1] ; ditto
  ; sLiveXChanList.s[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]       ; input/output crosspoints per input - used for adjusting input levels
  sAudPrevSetGainCommandString.s
  sAudSetGainCommandString.s
  sAudFinalSetGainCommandString.s   ; used at the end of a fade-in to accurately set the required level, instead of the approximate level achieved via 'gainmidi'
  
  nAltPrimaryChan.i
  sAltPPrimaryChan.s
  sAltAudPChanList.s
  sAltAudPXChanList.s
  sAltSyncPChanList.s
  sAltSyncPXChanList.s
  sAltDevPXChanListLeft.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sAltDevPXChanListRight.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sAltDevPXDownMix.s[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sAltAudSetGainCommandString.s
  
  sAudChanList.s          ; input channels for this item (one channel per input), eg "i3 i4 i12" for 3 inputs
  sAudXChanList.s         ; input crosspoint channels for this item (one channel per input per device), eg "x3.0 x3.1 x4.0 x4.1 x12.0 x12.1" for 3 inputs to a stero output
  sSyncChanList.s
  sSyncXChanList.s
  
  bStopping.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]            ; #True if sliding to -2
  bAltStopping.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]         ; #True if sliding to -2
  bFading.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bAltFading.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nFadeFactor.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nAltFadeFactor.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nFadeInc.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nAltFadeInc.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  hFadeDSP.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  hPanDSP.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nMixerStreamPtr.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bUseMatrix.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  aMixerMatrix.tyMatrix[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nSelectedDeviceOutputs.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nMatrixOutputs.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nMatrixOutputOffSet.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nMatrixFactor.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bDisplayPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nDSPInd.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]               ; 0=no DSP; 1=Stereo2MonoLeftDSP; 2=Stsreo2MonoRightDSP
  nInputDevMapDevPtr.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  nOutputDevMapDevPtr.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  
  nAbsStartAt.i
  nAbsEndAt.i
  nAbsMin.i
  nAbsMax.i
  nCueDuration.i
  
  nRelStartAt.i
  nRelEndAt.i
  nRelCheckForEnd.i
  
  qEndAtTime.q ; needed for fade outs activated on aud's with loops
  
  nSMSPChansReqd.i
  nSMSPChanCount.i
  
  qBassPlayEndByte.q
  nBassPlayEndSync.l
  nBassAltPlayEndSync.l
  nBassLinkPosSync.l
  nBassChannelEndSync.l
  nBassAltChannelEndSync.l
  nSMSManualStartPos.i
  nBassDevFailSync.l
  
  nBassFreq.i           ; from BASS_ChannelGetInfo
  nBassChans.i          ; from BASS_ChannelGetInfo
  bBassFloat.i       ; true if floating-point channel
  
  bTempoChannelReqd.i
  bTempoChannelCreated.i
  nChannelTempoChannelReplaced.l
  
  nMidiPhysicalDevPtr.i
  
  nInputOnCount.i
  nInputOffCount.i
  
  nCuePos.i
  nCuePosWhenLastChecked.i
  nRelFilePos.i ; relative position as calculated by SCS. (When repositioning, this will be calculated before calling BASS_ChannelSetPosition() etc, so may not be always in sync with nCurrRelFilePos.)
  nPlayingPos.i ; current relative position as returned by BASS_ChannelGetPosition() etc
  nPrevPlayingPos.i
  nCuePosAtFadeStart.i ; added 27Mar2021 11.8.4.1ah to simplify fade in processing, particularly for fading in a hibernated cue (bug report from Malcolm Gordon)
  qVideoFrameCount.q ; Added 17Feb2025
  
  nLinkedToAudPtr.i
  nFirstAudLink.i
  nAudLinkCount.i
  nMaxAudSetPtr2.i ; Used exclusively with the global two-dimensional array gaAudSet(). See description in buildAudSetArray() for more more info.
  bCallSetLinksOneAud.i
  bASIO.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nBassASIODevice.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nBassDevice.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nSourceChannel.l      ; eg source#1
  nSourceAltChannel.l   ; ditto
  bAudUseGaplessStream.i
  nAudGaplessSeqPtr.i
  nAudGaplessStream.l      ; eg gapless#1
  bUsingSplitStream.i
  bReOpenFile.i
  bReOpenVidFile.i
  nBassChannel.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]       ; eg source#1 etc or splitter#1 etc (NOT gapless#1 etc or mixer#1 etc). level changes applied to nBassChannel[]
  nBassAltChannel.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]    ; ditto
  nNrOfInputChans.i
  nBassStreamCreateFlags.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nBassDecodeStreamCreateFlags.l[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fTrimFactor.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fInputLevel.f[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  fCueVolNow.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fCueInputVolNow.f[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  fCueAltVolNow.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fCueTotalVolNow.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]   ; fCueVolNow + fCueAltVolNow
  fCueInputTotalVolNow.f[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  fCuePanNow.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bCueVolManual.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bCuePanManual.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSavedBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSavedPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bCueLevelLC.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bCuePanLC.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fLCPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fBVLevelWhenFadeOutStarted.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fAudPlayBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]  ; normal device play levels for a playlist aud file, initially = fBVLevel[] but may be adjusted by Level Change cues
  fAudPlayPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fIncDecLevelBase.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bIncDecLevelSet.i
  fIncDecLevelDelta.f
  bAffectedByLevelChange.i
  bIgnoreLevelEnvelope.i
  nLevelChangeSubPtr.i
  nTotalTimeOnPause.i
  qTimePauseStarted.q
  bTimePauseStartedSet.i
  nPriorTimeOnPause.i
  nPreFadeInTimeOnPause.i
  nPreFadeOutTimeOnPause.i
  qTimeFadeInStarted.q
  qTimeFadeOutStarted.q
  bTimeFadeInStartedSet.i
  bTimeFadeOutStartedSet.i
  bCheckProgSlider.i
  qTimeAudStarted.q
  qTimeAudRestarted.q
  bFinalSlide.i
  bFinalFadeOut.i
  nFinalFadeOutTime.i
  nMainFadeOutTime.i
  qTimeForNextFadeCheck.q
  bTimeForNextFadeCheckSet.i
  bGloballyPaused.i
  nPlaybackBufSize.i ; used in loop sync proc
  bInLoopXFade.i
  nImagePtr.i
  nCurrFadeInTime.i
  nCurrFadeOutTime.i
  bFadingInFromHibernate.i
  bCodecWarningDisplayed.i
  
  bFadeRequested.i
  bFadeInOneAudIssuedSlideChannelAttributes.i ; Added 4Feb2025 11.10.6
  nRequestedBySubPtr.i   ; sub that initiated the fade (could be an LCC or an SFR)
  qTimeFadeStarted.q
  bFadeInProgress.i
  nFadeType.i
  fPreFadeBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fPreFadePan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fTargetBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fTargetPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nReqdFadeTime.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bFadeCompleted.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  
  ; Added 25Mar2024 11.10.2bm for CPeters request for selecting multiple devices for manual level adjustments
  bDeviceSelected.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nDeviceMinX.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nDeviceMaxX.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fDeviceTotalVolWork.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bDeviceInitialTotalVolWorksSet.i
  ; End added 25Mar2024 11.10.2bm

  nPLCountDownTimeLeft.i
  qPLTimeTransStarted.q
  nPLDelayStartTime.q ; derived from nPLTransTime of previous audio file
  bPLSkipDone.i
  
  nXPos.i
  nYPos.i
  nSize.i
  nAspect.i   ; deprecated - replaced by nAspectRatioType and nAspectRatioVal
  nAspectRatioType.i
  nAspectRatioHVal.i
  nOrigLeft.i
  nOrigTop.i
  nOrigWidth.i
  nOrigHeight.i
  nAspectRatioWindow.i
  
  nAutoFollowAudPtr.i
  bAutoFollowStarted.i
  bWaitForGaplessEndSync.i
  qTimeAudEnded.q
  bTimeAudEndedSet.i
  
  ; level envelope (level points)
  aLvlPtRun.tyLevelPointRunTime[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  nLvlPtRunToTime.i
  bLvlPtRunForceSettings.i
  
  ; remote app
  bRAISendProgressPosMsgs.i
  bRAISendSetPos.i
  nRAIRelFilePos.i
  
  CompilerIf #c_vMix_in_video_cues
    ; vMix
    svMixInputKey.s ; a unique key generated by vMix which remains constant while the video/image file (clip) is open in vMix
    nvMixInputNr.i  ; this may change over time as other inputs are removed
    Array bvMixOutputReqd.i(4) ; only 1-4 used (0 not used)
  CompilerEndIf
  
  ; the following used by the editor
  nPreEditPtr.i
  qTimeAudLastEdited.q
  qChannelBytePosition.q  ; quad
  sErrorMsg.s
  bResyncLinksReqd.i
  bUpdateDisplay.i
  nPlayFromPos.i
  
  ;- aAud Cue Markers
  Array aCueMarker.tyCueMarker(0)
  nMaxCueMarker.i
  rNextCueMarker.tyCueMarker
  
  ;- aAud Video Capture
  sVideoCaptureLogicalDevice.s
  nVideoCaptureDeviceType.i
  
  ;- aAud VST Plugins
  sVSTPluginName.s
  sVSTPluginSameAsCue.s
  nVSTPluginSameAsSubNo.i
  nVSTPluginSameAsSubRef.i ; calculated at runtime
  sVSTReqdPluginName.s ; populated dynamically from either this aAud's sVSTPluginName or from the sVSTPluginName of the 'same as' aAud
  nVSTProgram.i
  nVSTMaxParam.i ; Def = -1 and set in Startup.pbi in setIndependentDefaults()
  Array aVSTParam.tyVSTParams(0) ; dynamically re-dim'ed as required
  rVSTChunk.tyVSTChunk
  bVSTBypass.i
  nVSTHandle.l
  nVSTAltHandle.l
  sVSTComment.s
EndStructure

;- tyPosSizeAndAspect
Structure tyPosSizeAndAspect
  bPopulated.i
  sCopyInfo.s
  nXPos.i
  nYPos.i
  nSize.i
  nAspectRatioType.i
  nAspectRatioHVal.i
EndStructure

;- tyInfoAboutFile
Structure tyInfoAboutFile
  sFileName.s
  nFileFormat.i
  nFileDuration.i
  nFileChannels.i
  qFileBytesForTenSecs.q
  qFileBytes.q
  nBytesPerSamplePos.i
  bOKForSMS.i
  bOKForAnalyzeFile.i
  sFileInfo.s
  sFileTitle.s
  wFormatTag.w          ; wFormatTag from WAV file fmt chunk (populated from BASS_ChannelInfo)
  sErrorMsg.s
EndStructure

;- tyFileInfo
Structure tyFileInfo
  sFileName.s
  sFileExt.s
  sFileTitle.s
  sTrack.s
  nSize.i
  nCompressionType.w
  nChannels.w
  sChannelSpread.s
  nSamplingFreq.i
  nLenData.i
  nDuration.i
EndStructure

;- tyFileData
Structure tyFileData
  sStoredFileName.s
  sFileModified.s         ; date/time file modified
  qFileSize.q
  sFileProps.s
  sFileType.s
  sFileTitle.s
  nFileDuration.i
  qFileBytesForTenSecs.q
  qFileBytes.q
  nSourceWidth.l
  nSourceHeight.l
  nxFileChannels.i ; NB Changed from nFileChannels to nxFileChannels to assist in debugging, as there are other structures that also contain nFileChannels. It helps debugging if names are unique.
  nSampleRate.i
  qSamplePositionCount.q  ; count of the number of 'sample positions' - a mono file will have one sample per 'sample position';
                          ; a stereo file will have two samples per 'sample posiiton', and so on,
                          ; so SamplePositionCount = (number of samples) / (number of channels)
  nInitGraphImage.i
  
  ; --------------------------------- derived fileinfo fields
  sFileName.s
  bOKForSMS.i
  bOKForAnalyzeFile.i
  bLoadRequest2.i   ; load request from caller 2 (editor audio file graph)
  bLoadRequest3.i   ; load request from caller 3 (progress slider audio graph)
  bSaveThisFile.i   ; set and used in unloadGrid()
  bUnsavedFile.i
  bDrawGraphAfterLoad.i
  bDrawSliderAfterLoad.i
  fNormalizeFactor.f
  nSamplesArrayStatus.i
  bKillScanRequested.i
  bForceReadFileBlob.i
  nMaxInnerWidth.i                ; max inner width of graph in WQF
  nArrayMax.i                     ; max array index used in following arrays
EndStructure

;- tyFileStats
Structure tyFileStats
  sFileName.s
  sFileModified.s       ; date/time file modified
  qFileSize.q
  nFileDuration.i
  ; silence and low audio level times - used for trim functions, such as those available under the 'other actions' button in playlist cues
  nSilenceStartAt.i     ; the 'start at' position required to skip silence at the start of the file
  nSilenceEndAt.i       ; the 'end at' position required to ignore silence at the end of the file
  ; Added 3Oct2022 11.9.6
  nM75dBStartAt.i       ; the 'start at' position required to skip audio less than -75dB at the start of the file
  nM75dBEndAt.i         ; the 'end at' position required to ignore audio less than -75dB at the end of the file
  nM60dBStartAt.i       ; the 'start at' position required to skip audio less than -60dB at the start of the file
  nM60dBEndAt.i         ; the 'end at' position required to ignore audio less than -60dB at the end of the file
  ; End added 3Oct2022 11.9.6
  nM45dBStartAt.i       ; the 'start at' position required to skip audio less than -45dB at the start of the file
  nM45dBEndAt.i         ; the 'end at' position required to ignore audio less than -45dB at the end of the file
  nM30dBStartAt.i       ; the 'start at' position required to skip audio less than -30dB at the start of the file
  nM30dBEndAt.i         ; the 'end at' position required to ignore audio less than -30dB at the end of the file
  ; max absolute samples will be used for 'peak normalization' (nMaxAbsSample = (abs max sample float) * 10000)
  nMaxAbsSample.i
EndStructure

;- tyGraphLoadRequest
Structure tyGraphLoadRequest
  bLoadRequest2.i   ; load request from caller 2 (editor audio file graph)
  bLoadRequest3.i   ; load request from caller 3 (progress slider audio graph)
  nAudPtr.i
  nGraphWidth.i
EndStructure

;- tyFileBlobInfo
Structure tyFileBlobInfo
  sFileName.s
  sFileModified.s         ; date/time file modified
  qFileSize.q
  nGraphWidth.i
  nGraphChannels.i
  nMaxPeak.i ; should be #SCS_GRAPH_MAX_PEAK - see #SCS_GRAPH_MAX_PEAK in scsconstants.pbi for more info
EndStructure

;- tySldrBlobInfo
Structure tySldrBlobInfo
  nAudPtr.i
  sFileName.s
  sFileModified.s         ; date/time file modified
  qFileSize.q
  nGraphWidth.i
  nGraphChannels.i
  nAbsMin.i
  nAbsMax.i
  nMaxPeak.i ; should be #SCS_GRAPH_MAX_PEAK - see #SCS_GRAPH_MAX_PEAK in scsconstants.pbi for more info
  fNormalizeFactor.f
EndStructure

;- tyImageBlobInfo
Structure tyImageBlobInfo
  sFileName.s
  sFileModified.s         ; date/time file modified
  qFileSize.q
  nWidth.i
  nHeight.i
  sSizeEtc.s
  nFilePos.i
  nImageNo.i
  bShellThumbnail.i
EndStructure

;- tyHotkeys
Structure tyHotkeys
  ; fields set by initHotkeyArray():
  sHotkey.s             ; A-Z, 0-9, F1-F12 - see gsValidHotkeys
  nHotkeyNr.i           ; A=1, B=2, etc
  nHotkeyStepNo.i       ; step number starting from 1 for 'Step' hot keys, otherwise 0 (zero)
  nHKShortcut.i         ; #PB_Shortcut_A, etc
  nHKShortcutVK.l       ; nb although vKeys values are 16-bit, the Windows function GetAsyncKeyState() declares the vKey parameter as int (32-bit)
  nHKShortcutNumPadVK.l ; numeric pad alternative vKey if applicable, otherwise 0
  nHKShortcutVKUsed.l   ; actual vKey last pressed (either nHKShortcutVK or nHKShortcutNumPadVK) - used for checking key released
  bExternallyTriggered.i  ; eg triggered from remote app, so do not check keyboard key down for the end of a 'note' hotkey
  ; fields set by loadHotkeyArray():
  sHotkeyLabel.s
  sCue.s
  nCuePtr.i
  nActivationMethod.i
  nToggleState.i ; 1 = odd press (1st, 3rd, 5th, etc), 0 = even press (2nd, 4th, 6th, etc)
  nHotkeyPanelRowNo.i
  nHotkeyBank.i
  nHKSortKey.i
EndStructure

;- tyGridCol
Structure tyGridCol
  sColType.s          ; 2-character column type as held externally, eg in layout definition in the registry. populated by registerGrid()
  sTitle.s            ; column title, or PB column type for ExplorerListGadget (note that these constants are strings which are recognized by AddGadgetColumn())
  ; note: PB column numbers are assigned when the columns are added to the grid, and stay with those columns even if the columns are
  ; subsequently re-ordered, eg by the user dragging a column to a new position.
  nDefColNo.i         ; default PB column number of this column (-1 if not visible)
  nIniColNo.i         ; initial PB column number of this column (when WMN_setupGrid(), or equivalent for other grids, was first executed this session)
  nCurColNo.i         ; current PB column number of this column (when WMN_setupGrid(), or equivalent for other grids, was last executed)
  nDefWidth.i         ; default width of this column
  nIniWidth.i         ; initial width of this column (this session)
  nCurWidth.i         ; current width of this column
  nCurColOrder.i      ; current physical position of this column - set the same as nCurcolNo by WMN_setupGrd() or equivalent, but reset by updateGridInfoFromPhysicalLayout()
  bColVisible.i       ; indicates if column is currently visible
EndStructure

;- tyGridInfo GRID info
Structure tyGridInfo
  nGadgetNo.i         ; gadget no. of the grid, populated by registerGrid()
  nMaxColNo.i         ; max possible colno for this table, populated by registerGrid()
  nMaxVisibleColNo.i  ; max colno currently visible
  sLayoutString.s     ; sColType:nCurWidth:nCurColNo;...  populated by loadPrefs...(), unpacked by unpackGridLayoutString() and built by updateGridInfoFromPhysicalLayout()
  Array aCol.tyGridCol(0) ; ReDim'd in registerGrid()
EndStructure

;- tyGridRowInfo
Structure tyGridRowInfo
  ; details populated by getGridRowInfo()
  nFirstRowVisible.i
  nLastRowVisible.i
  nSelectedRow.i
  nMaxRowsVisible.i
EndStructure

;- tyDPS (display position and size)
Structure tyDPS
  nDisplayLeft.i
  nDisplayTop.i
  nDisplayWidth.i
  nDisplayHeight.i
  nDisplay2Left.i
  nDisplay2Top.i
  nDisplay2Width.i
  nDisplay2Height.i
  nTVGZoomCoeff.i
  dAspectRatioToUse.d
EndStructure

;- tyController
; see strWCNController in Windows.pbi

;- tyWBE
Structure tyWBE
  nDefaultGridWidth.i
  nDefaultWindowWidth.i
  nBEField.i
  sBEField.s
  nBERowTypes.i
  nBERowCount.i
  bAllAudioDevs.i
  sAudioDevice.s
  nNoChangeColor.l
  nChangeColor.l
  nCappedColor.l
  nIgnoredColor.l
  nColNoCueType.i
  nColNoDevice.i
  nColNoOld.i
  nColNoNew.i
  bInValidate.i
  bInFieldChange.i
  nMaxColNo.i
  nChangeType.i
  fTarget.f
  nOldCallBack.i
EndStructure

;- tyBulkEditItem
Structure tyBulkEditItem
  nPtr.i
  nCuePtr.i
  sItemType.s
  sSubType.s
  sLabel.s
  sCueType.s
  sDescr.s
  nDevNo.i
  sDevice.s
  nFileStatsPtr.i
  bSelected.i
  sOldValue.s
  sNewValue.s
  nOldValue.i
  nNewValue.i
  fOldValue.f
  fNewValue.f
  bOldValue.i
  bNewValue.i
  sOldDispValue.s
  sNewDispValue.s
  bCapped.i
  bIgnored.i
  bIncluded.i
  nDeviceIndex.i
  bIntegrated.i
  fIntegratedValue.f
  fPeakValue.f
  fTruePeakValue.f
  sIntegratedValue.s
  sPeakValue.s
  sTruePeakValue.s
EndStructure

;- tyColorItem
Structure tyColorItem
  bUseDflt.i
  nBackColor.l
  nTextColor.l
  bColorsPreSetUseDfltSet.i
  nBackColorPreSetUseDflt.i
  nTextColorPreSetUseDflt.i
EndStructure

;- tyColorAudioGraph
Structure tyColorAudioGraph
  nLeftColor.l        ; left color in slider audio graph when the cue is not playing (by default this is light blue)
  nRightColor.l       ; right ditto
  bRightSameAsLeft.i
  nLeftColorPlay.i    ; left color in slider audio graph when the cue is playing (by default this is light green)
  nRightColorPlay.i   ; right ditto
  nCursorColor.l
  nShadowColor.l
  nDarkenFactor.i
  nCuePanelCursorStyle.i
  nCursorTransparencyFactor.i
  ; derived colors
  nCuePanelCursorColor.l
  nCuePanelShadowColor.l
EndStructure

;- tyColorScheme
Structure tyColorScheme
  sSchemeName.s       ; internal name (as saved in the prefs file)
  sSchemeDescr.s      ; external name
  bInternalScheme.i   ; #True if SCS internal scheme (cannot be modified or deleted)
  nColNXAction.i      ; defines how to color 'next manual cue' - see enumeration values #SCS_COL_NX_...
  aItem.tyColorItem[#SCS_COL_ITEM_LAST+1]
  rColorAudioGraph.tyColorAudioGraph
EndStructure

;- tyWCS
; no Structure tyWCS - see tyColHnd below

;- tyColHnd
Structure tyColHnd
  rDefaultScheme.tyColorScheme
  rClassicScheme.tyColorScheme
  rLightScheme.tyColorScheme
  rDarkScheme.tyColorScheme
  rWinDefScheme.tyColorScheme
  nSelectedRow.i
  bSchemeAltered.i
  bChangesSaved.i
  sOrigSchemeName.s
  nItemIndex.i[#SCS_COL_ITEM_LAST+1]
  sItemTitle.s[#SCS_COL_ITEM_LAST+1]
  bItemAltered.i[#SCS_COL_ITEM_LAST+1]
  nCurrentSchemeIndex.i
  nDesignSchemeIndex.i
  bCopyPopulated.i
  rCopyColorItem.tyColorItem
  bAudioGraphColorsChanged.i
EndStructure

;- tyUIColors
; added 26Dec2019 for new GUI
Structure tyUIColors
  nTitleBackColor.l
  nMainBackColor.l
  nButtonBackColor.l
  nButtonBorderColor.l
  nButtonFrontColor.l
  nLineColor.l
EndStructure

;- tyMain from aamain
Structure tyMain
  ; sam (special action manager)
  nSamSize.i
  nSamWritePtr.i
  nSamReadPtr.i
  nSamRequestsWaiting.i
  bControlThreadWaiting.i
  qControlThreadWaitingTimeTrue.q
  qControlThreadWaitingTimeFalse.q
  nCasWritePtr.i
  nCasReadPtr.i
  nCasRequestsWaiting.i
  bCasProcessing.i
  bUsingCas.i
  nCasGroupId.i
  nDemoTime.i
  nDisplayPanel.i
  qDeviceCheckTime.q
  qCheckFocusTime.q
  qCheckPauseAllTime.q
  nStayAwakeLines.i
  sStayAwakeFile.s
  qLastPlayResTime.q
  bDisplayPopupMenu.i
  nGrdCuesOldProc.i
  qGrdCuesClickTime.q
  nGrdCuesClickRow.i
  lpPrevWndFuncCues.i
  lpPrevWndFuncHotkeys.i
  bRightButtonDownTimeSet.i
  qRightButtonDownTime.q
  bDoSaveGridLayout.i
  ; fields for calling WMN_setStatusField() from main thread
  sStatusField.s
  nStatusType.i
  nExtraDisplayTime.i
  bMayOverrideStatus.i
  ; end of fields for calling WMN_setStatusField() from main thread
  nSwitchMenuHostPanel.i
  nRunningIndDesignWidth.i
  ; main memo fields
  nMainMemoSubPtr.i
  nMainMemoCloseButtonLeft.i
  bMainMemoCloseButtonVisible.i
EndStructure

; Added 3Dec2022 11.9.7ar
Structure tyMisc
  bClockDisplayed.i
EndStructure
; End added 3Dec2022 11.9.7ar

Structure tyStopEverythingInfo
  nCuePtr.i
  bResetAfterStop.i
  bResumeThreadsAfterStop.i
  bCallStopEverythingPart2.i
  nDelayTimeBeforePart2.i
EndStructure

;- tyDispControl
Structure tyDispControl
  nCuePtr.i
  nSubNo.i
  nSubPtr.i
  nPlayNo.i
  nAudPtr.i
  bUseNext.i
EndStructure

;-- Options / Audio Driver
;- tyDriverSettings  audio driver settings
Structure tyDriverSettings
  ; Audio Driver: BASS_DS / WASAPI
  bSWMixer.i
  bNoFloatingPoint.i
  bNoWASAPI.i
  bSwap34with56.i
  bUseBASSMixer.i
  sPlaybackBufOption.s
  nPlaybackBufLength.l        ; long
  sUpdatePeriodOption.s
  nUpdatePeriodLength.l       ; long
  nDSSampleRate.l             ; long: DirectSound sample rate
  nLinkSyncPoint.i
  ; Audio Driver: BASS_ASIO
  nAsioBufLen.i
  nFileBufLen.i
  ; Audio Driver: SMS_ASIO
  bSMSOnThisMachine.i
  sSMSHost.s
  sAudioFilesRootFolder.s
  sEncFilesFolder.s
  nMinPChansNonHK.i
  nFadeProfile.i
EndStructure

;- tyDriverInfo
Structure tyDriverInfo
  bPhysicalDevsPopulated.i
  nDeviceCount.i
  bBassInitialised.i
EndStructure

;- tyCueLogicalDevs
Structure tyCueLogicalDevs
  sCueDev.s
  sActualDev.s
  bASIO.i
  nBassASIODevice.l         ; long
  nBassDevice.l             ; long
  nSpeaker.l                ; long
  bSurround.i
  bMidiDev.i
  nMidiPhysicalDevPtr.i
  bVideoDev.i
EndStructure

;- tyCuePoint
Structure tyCuePoint
  sCuePointKey.s
  sFileName.s
  nIdentifier.l     ; (long) derived from WAV file CuePoint structure field dwIdentifier
  qSamplePos.q      ; (quad) sample position of this cue point / marker
  dTimePos.d        ; (double) derived time position of this cue point in seconds
  sName.s           ; optional name of this cue point as obtained from the associated data list (if present)
  ; fields for use in fmEditModule (WEM)
  nRowNo.i          ; row number in WEM\grdCuePoints
EndStructure

;- tyAudCuePoint
Structure tyAudCuePoint
  nAudPtr.i
  sCuePointKey.s
  dTimePos.d        ; (double) derived time position of this cue point in seconds
EndStructure

;- tyCueType
Structure tyCueType
  sCueType.s
  nMinLicLevel.i
  bCueTypeAvailable.i
EndStructure

;- tyMidiDevice
Structure tyMidiDevice
  nMidiDeviceID.l
  sName.s
  bDummy.i
  bIgnoreDev.i
  bInitialized.i
  hMidiIn.i           ; handle for midi in port
  hMidiOut.i          ; handle for midi out port
  hMidiConnect.i      ; handle for midi in port to be connected to midi out port to implement midi thru
  bMidiCapture.i      ; port (midi in port) required open for midi capture
  bNRPNCapture.i      ; port (midi in port) required open for NRPN capture
  bCueControl.i       ; port (midi in port) required for cue control
  bCtrlSend.i         ; port (midi out port) required for control send cues
  bMidiFilePlayback.i ; port (midi out port) required for midi file playback in control send cues
  bConnectPort.i      ; port (midi in port) required for connecting to a midi out port for 'midi thru'
  bThruPort.i         ; port (midi out port) required for 'midi thru'
  nCueControlOutPhysicalDevPtr.i ; pointer to midi out port that matches this midi in port, for cue control messages that need to be sent, eg for turning off a CtrlChg button
  nMidiThruInPhysicalDevPtr.i ; pointer to midi in port (the 'connect' port) for this midi out port's 'midi thru' connection
  bMidiDevForMTC.i
  bMTCCuesPort.i
  bControllerPort.i   ; port used for external controller (eg Behringer BCR2000)
  bWindowsMidiCompatible.i  ; #True if device may be handled by Windows MIDI functions, such as midiInOpen(), midiOutOpen() etc.
                            ; #False for other devices, such as the Enttec DMX USB PRO MK2
  bEnttecMidi.i ; #True if to use the Enttec DMX USB PRO MK2 API
  ; the following only applicable if bEnttecMidi = #True
  nDMXDevPtr.i
  sDMXName.s
  nDMXSerial.i
  sDMXSerial.s
  nFTHandle.i
  ;bDMXFirstReceive.i
  ;nDevice.i
EndStructure

;- tyGraphMarker
Structure tyGraphMarker
  qGraphMarkerSortKey.q
  nGraphMarkerType.i
  nLevelPointIndex.i
  nLevelPointId.i
  nLoopInfoIndex.i
  nLevelOrPan.i
  nItemIndex.i
  nMGCueMarkerIndex.i
  nCueMarkerId.i
  nX.i
  nY.i
  nWidth.i
  nHeight.i
  fMidPointX.f
  fMidPointY.f
  nGraphMarkerTime.i
  ; the 'hot area' defines the area within which SCS regards the mouse pointer as being on this marker
  nHotAreaX.i
  nHotAreaY.i
  nHotAreaWidth.i
  nHotAreaHeight.i
EndStructure

;- tyMG
Structure tyMG
  nMGNumber.i
  sMGNumber.s
  Array aFileSampleL.b(0)
  Array aFileSampleR.b(0)
  Array aSliceMinL.b(0)
  Array aSliceMinR.b(0)
  Array aSlicePeakL.b(0)
  Array aSlicePeakR.b(0)
  Array aGraphMarker.tyGraphMarker(8)
  nMGMaxLoop.i
  Array nLE.i(0)
  Array nLS.i(0)
  ; sorted
  bAudPlaceHolder.i
  bContainsLoop.i
  bCurrSldPositionValueSet.i
  bDeviceAssigned.i
  bDrawingStarted.i
  bInAutoScroll.i
  bInDrawGraph.i
  bInGetData.i
  bInitDataLoaded.i
  bInitGraphDrawn.i
  bInLoadSlicePeakAndMin.i
  bSetFilePosAtStartAt.i
  bTipDrawn.i
  dSamplePositionsPerPixel.d  ; see also nSamplePositionsPerPixel.i
  fBVLevel.f        ; level before being adjusted for pan, so use this for audio graph for mono files
  fBVLevelLeft.f
  fBVLevelRight.f
  fMillisecondsPerPixel.f           ; milliseconds per pixel
  fMouseDownRelDBLevel.f
  fNormalizeFactor.f
  fYFactor.f
  nAudPtr.i
  nBuffPtr.i
  nCanvasGadget.i
  nCanvasHeight.i
  nCanvasWidth.i
  nCMColor.l  ; SCS Cue Marker color
  nCPColor.l  ; File Cue Point color
  nCurrEN.i
  nCurrLE.i
  nCurrLS.i
  nCurrPos.i
  nCurrSldPositionValue.i
  nCurrST.i
  nCursorColor.l
  nCursorShadowColor.l
  nDfltGraphChannels.i
  nEN.i
  nENColor.l
  nEXBGColor.l
  nEXFGColorL.i
  nEXFGColorR.i
  nFadeMarkerBottom.i
  nFadeMarkerTop.i
  nFI.i
  nFIColor.l
  nFO.i
  nFOColor.l
  nMGFileChannels.i ; NB Changed 12Jan2024 11.10.0 from nFileChannels to nMGFileChannels to assist in debugging, as there are other structures that also contain nFileChannels. It helps debugging if names are unique.
  nFileDataPtrForGraph.i
  nFileDataPtrForSamplesArray.i
  nFileDataPtrForSlicePeakAndMinArrays.i
  nFileDuration.i
  nFirstIndex.i               ; used while drawing graph and will change frequently if graph is zoomed or repositioned
  nFromPtr.i
  nFullBufSize.i
  nGetDataCount.i
  nGetDataLimit.i
  nGraphBottom.i
  nGraphBottomL.i
  nGraphBottomR.i
  nGraphChannels.i
  nGraphedFileAudPtr.i
  nGraphHalfHeightL.i
  nGraphHalfHeightR.i
  nGraphHeight.i              ; height (odd number for centre line)
  nGraphHalfHeight.i
  nGraphHeightL.i
  nGraphHeightR.i
  nGraphHelpBottom.i          ; graph help question mark info for hotspot
  nGraphHelpLeft.i
  nGraphHelpRight.i
  nGraphHelpTop.i
  nGraphImage.i
  nGraphLeft.i                ; always 0
  nGraphLeftBaseY.i
  nGraphMarkerIndex.i
  nGraphMaxX.i
  nGraphPartHeight.i
  nGraphRight.i
  nGraphRightBaseY.i
  nGraphTop.i
  nGraphTopL.i
  nGraphTopR.i
  nGraphWidth.i               ; width after zooming, so if zooming then \nGraphWidth will be greater than \nVisibleWidth
  nGraphYMidPoint.i
  nGraphYMidPointL.i
  nGraphYMidPointR.i
  nINBGColor.l
  nINFGColorL.i
  nINFGColorLPlay.i
  nINFGColorR.i
  nINFGColorRPlay.i
  nInnerWidth.i               ; dragable width (= \nGraphWidth)
  nLastIndex.i                ; used while drawing graph and will change frequently if graph is zoomed or repositioned
  nLastTimeMark.i
  nLEColorD.i     ; loop end color (currently displayed loop)
  nLEColorN.i     ; loop end color (not currently displayed)
  nLoopBarBottom.i
  nLoopBarHeight.i
  nLoopBarLeft.i
  nLoopBarTop.i
  nLoopBarWidth.i
  nLPColor.l
  nLPColor2.i
  nLPColor_Ctrl.i ; Color for CTRL HOLD Level Points
  nLSColorD.i     ; loop start color (currently displayed loop)
  nLSColorN.i     ; loop start color (not currently displayed)
  nLVColor.l      ; 'level' color - used for indicating audio device level
  nMarkerDragAction.i
  nMaxGraphMarker.i
  nMaxInnerWidth.i
  nMGMaxCueMarker.i
  nMouseDownCanvasLeft.i
  nMouseDownCueMarkerId.i
  nMouseDownGrabStartX.i
  nMouseDownGraphMarkerIndex.i
  nMouseDownGraphMarkerType.i
  nMouseDownItemIndex.i
  nMouseDownLevelOrPan.i
  nMouseDownLevelPointId.i
  nMouseDownLoopInfoIndex.i
  nMouseDownSliceType.i
  nMouseDownStartX.i
  nMouseDownStartY.i
  nMouseDownTime.i        ; original time value (eg nAbsStartAt) when mouse down occurred
  nMouseMaxTime.i
  nMouseMinTime.i
  nMouseMoveLevelPointId.i
  nMouseMoveMarkerIndex.i
  nPanColor.l
  nPanColor2.i
  nPos.i
  nPositionValue.i
  nPrevTimeMarkX.i
  nReposMouseTime.i
  nSamplePositionsPerPixel.i  ; = dSamplePositionsPerPixel rounded to nearest integer for 'For' loops
  nSEBarBottom.i
  nSEBarHeight.i
  nSEBarLeft.i
  nSEBarTop.i
  nSEBarWidth.i
  nSideLabelsGadget.i
  nSldPtr.i           ; used with MG3 (audio graph in progress slider)
  nSlicePeakAndMinCount.i
  bCallSaveSlicePeakAndMinArraysToTempDatabase.i
  nST.i
  nSTColor.l
  nTimeBarBottom.i
  nTimeBarHeight.i
  nTimeBarLeft.i
  nTimeBarTop.i
  nTimeBarWidth.i
  nTipSliceType.i
  nUpToPtr.i
  nViewEnd.i
  nViewRange.i
  nViewStart.i
  nAbsMin.i     ; used in audio graph sliders (grMG3)
  nAbsMax.i     ; ditto
  nVirtualCanvasWidth.i
  nVirtualCanvasX.i
  nVisibleWidth.i             ; visible width (ie the width of the container \cntGraph)
  nZoomValue.i
  qMaxSamplePtr.q
  sBuff.s
  sFileName.s
  sGraphLogicalDev.s
  sSampleArrayFileName.s
EndStructure

;- tyCtrlItem
; used for custom-specified control surfaces
Structure tyCtrlItem
  nCtrlItemType.i
  nCmd.i          ; 08H = Note Off, 09H = Note On, etc
  nCC.i           ; CC or KK, etc
  nVV.i           ; 0-127, or #SCS_MIDI_ANY_VALUE (-99)
EndStructure

;- tyCtrlSetup
; used for control surfaces, such as BCF2000/BCR2000 and Korg nanoKONTROL2
Structure tyCtrlSetup
  bIncludeGoEtc.i
  bShowMidi.i
  nController.i
  nCtrlConfig.i
  sCtrlMidiInPort.s
  sCtrlMidiOutPort.s
  ;
  bDataChanged.i
  bUseExternalController.i ; #True if using an external controller, eg BCR2000, for control of Master Fader, etc. #False if just using MIDI Cue Control or no external control at all
  nCtrlMidiInPhysicalDevPtr.i
  nCtrlMidiOutPhysicalDevPtr.i
  bRecreateWCN.i
  ;
  Array nCtrlBtnCC.i(#SCS_CTRLBTN_LAST)
EndStructure

;- tyKeyboardMap
Structure tyKeyboardMap
  key.b[256]
EndStructure

;-- Options / Shortcuts
;- tyShortcuts
Structure tyShortcuts
  sFunctionPrefKey.s
  sFunctionDescr.s
  nShortcut.i         ; PB shortcut, eg #PB_Shortcut_P, or #PB_Shortcut_Control | #PB_Shortcut_P. Note that SCS will treat #PB_Shortcut_Pad1 as #PB_Shortcut_1, etc, and vice-versa
  nShortcutVK.l       ; corresponding Windows 'virtual key', eg #VK_F1 - ignoring control/shift/alt/command
                      ; nb although vKeys values are 16-bit, the Windows function GetAsyncKeyState() declares the vKey parameter as int (32-bit)
  nShortcutNumPadVK.l ; numeric pad alternative vKey if applicable, otherwise 0
  sShortcutStr.s
  sDefaultShortcutStr.s
  nShortcutFunction.i
  nCurrShortcut.i     ; value of nShortcut last supplied to AddKeyboardShortcut() - used for removing 'all' shortcuts
EndStructure

;- tyKeyEvent
Structure tyKeyEvent
  rDateTime.SYSTEMTIME
  sKeyEvent.s
EndStructure

;- tyFavoriteFile
Structure tyFavoriteFile
  sFileName.s
  nShortcut.i
EndStructure

;- tyFind
Structure tyFind
  nCuePtr.i
  sCue.s
  sPageNo.s
  sWhenReqd.s
  sMidiCue.s
  sDescr.s
  sFileName.s
  sHotkeyLabel.s
EndStructure

;- tySFRAction
Structure tySFRAction
  sActDescr.s
  sActDescr2.s
EndStructure

;- tySFRCueType
Structure tySFRCueType
  sCueType.s
  sCueType2.s
EndStructure

;-- Options / Display and Cue List Columns
;- tyOperModeOptions
Structure tyOperModeOptions
  ; sorted
  bAllowDisplayTimeout.i
  bDisplayAllMidiIn.i
  bHideCueList.i
  bLimitMovementOfMainWindowSplitterBar.i
  bRequestConfirmCueClick.i
  bShowAudioGraph.i
  bShowCueMarkers.i
  bShowHiddenAutoStartCues.i
  bShowHotkeyCuesInPanels.i
  bShowHotkeyList.i
  bShowLvlCurvesOther.i
  bShowLvlCurvesPrim.i
  bShowMasterFader.i
  bShowMidiCueInCuePanels.i
  bShowMidiCueInNextManual.i
  bShowNextManualCue.i
  bShowPanCurvesOther.i
  bShowPanCurvesPrim.i
  bShowSubCues.i
  bShowToolTips.i
  bShowTransportControls.i
  bShowFaderAndPanControls.i
  nCtrlPanelPos.i
  nCueListFontSize.i
  nCuePanelVerticalSizing.i
  nMidiInDisplayTimeout.i ; negative means continuous
  nMainToolBarInfo.i
  ; nMaxMonitor.i ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
  nMonitorSize.i  ; see enumeration #SCS_MON_... (eg #SCS_MON_STD for standard size monitor window)
  nMTCDispLocn.i
  nPeakMode.i
  nTimerDispLocn.i
  nTouchPanelHeight.i
  nTouchPanelLocn.i
  nVUBarWidth.i
  nVisMode.i
  rGrdCuesInfo.tyGridInfo ; cue list columns
  sSchemeName.s ; color scheme
EndStructure

;-- Options / Functional Mode
;- tyFMOptions
Structure tyFMOptions
  nFunctionalMode.i               ; stand-alone, primary, or backup (see #SCS_FM_... enumeration)
  bBackupIgnoreCSMIDI.i           ; SCS Backup to ignore control-send MIDI
  bBackupIgnoreCSNetwork.i        ; SCS Backup to ignore control-send Network messages
  bBackupIgnoreLightingDMX.i      ; SCS Backup to ignore lighting DMX
  bBackupIgnoreCCDevs.i           ; SCS Backup to ignore cue control devices (except for commands from primary) - Added 30Oct2021 11.8.6bn
  sFMServerName.s                 ; Server name or IP address last selected by this SCS Backup
  nFMServerId.i
  sFMLocalIPAddr.s
  nFMClientId.i
  nFMClientNetworkControlPtr.i
  nFMNetworkMode.i
  sFMNetworkMode.s
  qTimeBCRSent.q      ; time /fmh/bcr message sent to the primary
  qTimeBCAReceived.q  ; time /fmh/bca message received by the backup
  qTimePollSent.q
  sPrimaryVersion.s
EndStructure

;-- Options / General
;- tyGeneralOptions
Structure tyGeneralOptions
  ; sorted
  bApplyTimeoutToOtherGos.i
  bCreateLogFile.i
  bCtrlOverridesExclCue.i
  bDisableRightClickAsGo.i
  bDisplayLangIds.i   ; only for translation assistance
  bEnableAutoCheckForUpdate.i
  bHotkeysOverrideExclCue.i ; Added 26May2020 11.8.3rc5c
  bSwapMonitors1and2.i ; see also nSwapMonitor
  nDaysBetweenChecks.i ; days between auto check for updates
  nDfltFontSize.i
  nDoubleClickTime.i
  nFadeAllTime.i
  nFaderAssignments.i       ; \nFaderAssignments is used for BCF2000 to indicate what the motorized faders are assigned to
  nMaxPreOpenAudioFiles.i
  nMaxPreOpenVideoImageFiles.i
  nPurgeLogDays.i
  nSwapMonitor.i ; see also bSwapMonitors1and2
  nTimeFormat.i
  sDBIncrement.s
  sDfltFontName.s
  sInitDir.s
  sLangCode.s
  sTimeFormat.s
EndStructure

;- tyDontTellMeAgain
Structure tyDontTellMeAgain
  bVideoCodecs.i
EndStructure

;-- Options / Video Driver
;- tyVideoDriver
Structure tyVideoDriver
  nVideoPlaybackLibrary.i
  ; TVG
  nTVGVideoRenderer.i
  nTVGDefaultVideoRenderer.i
  nTVGVideoRendererTVGValue.i
  bTVGControlForSecondaryScreenCreated.i
  bTVGUse2DDrawingForImages.i
  nTVGPlayerHwAccel.i ; hardware acceleration setting
  bTVGDisplayVUMeters.i
  ; split screen info
  aSplitScreenInfo.tySplitScreenInfo[#SCS_MAX_SPLIT_SCREENS+1]
  nSplitScreenArrayMax.i
  nRealScreensConnected.i
  bDisableVideoWarningMessage.i
EndStructure

;- tyVideoControl
Structure tyVideoControl
  nAudPtr.i
  bPlayWhenStopped.i
EndStructure

;-- Options / Remote App Interface
;- tyRAIOptions
Structure tyRAIOptions
  bRAIEnabled.i
  nRAIApp.i
  nRAIOSCVersion.i
  nNetworkProtocol.i
  sLocalIPAddr.s
  nLocalPort.i
EndStructure

;- tyBlackImage
Structure tyBlackImage
  nBlackImage.i
  hBlackBitmap.i
  nImageWidth.i
  nImageHeight.i
EndStructure

;- tyMemoryPrefs
Structure tyMemoryPrefs
  nDMXDisplayPref.i
  nDMXGridType.i
  nDMXBackColor.l
  bDMXShowGridLines.i
  nDMXFixtureDisplayData.i ; see Enumeration for #SCS_LT_DISP_...
  sDontAskCloseSCSDate.s
  sLastCheckForUpdate.s
  sDontTellDMXChannelLimitDate.s
EndStructure

;-- Options / Session
;- tySession
Structure tySession
  ; in the following session device flags: 0=not required (#SCS_DEVTYPE_NOT_REQD), 1=enabled (#SCS_DEVTYPE_ENABLED), 2=disabled (#SCS_DEVTYPE_DISABLED)
  nMidiInEnabled.i
  nMidiOutEnabled.i
  nRS232InEnabled.i
  nRS232OutEnabled.i
  nNetworkInEnabled.i
  nNetworkOutEnabled.i
  nDMXInEnabled.i
  nDMXOutEnabled.i
EndStructure

;-- Options / Editing
;- tyEditingOptions
Structure tyEditingOptions
  sAudioEditor.s
  sImageEditor.s
  sVideoEditor.s
  nFileScanMaxLengthAudio.i   ; maximum file scan length in seconds as displayed in editing options
  nFileScanMaxLengthAudioMS.i ; calculated maximum file scan length in milliseconds (added 2May2022 11.9.1)
  nFileScanMaxLengthVideo.i   ; maximum file scan length in seconds as displayed in editing options
  nFileScanMaxLengthVideoMS.i ; calculated maximum file scan length in milliseconds
  bSaveAlwaysOn.i
  bIgnoreTitleTags.i
  nAudioFileSelector.i
  bIncludeAllLevelPointDevices.i
  bCheckMainLostFocusWhenEditorOpen.i ; added 14Mar2019 11.8.0.2cc following request from Scott Siegwald, 6Mar2019
  bActivateOCMAutoStarts.i            ; added 31Jul2019 11.8.1.3af following request from Joe Eaton on 16Jun2019
  nEditorCueListFontSize.i            ; added 20Dec2021 11.8.6cx following request from Christian Peters on 21Nov2021
EndStructure

;- tyEditorPrefs
Structure tyEditorPrefs
  bAutoScroll.i
  bEditShowLvlCurvesSel.i
  bEditShowPanCurvesSel.i
  bEditShowLvlCurvesOther.i
  bEditShowPanCurvesOther.i
  bShowFileFoldersInEditor.i
  nGraphDisplayMode.i
  nSplitterPosEditV.i
  nSplitterPosEditH.i
  sFavItems.s
EndStructure

;- for CueFileHandler
;- tyCFH
Structure tyCFH
  sFileVersion.s
  sVersionParts.s[4]
  nFileVersion.i
  s2ndLine.s
  s2ndChar.s
  b2ndEOF.i
  nDevMapPtr.i
  nCurrDevGrp.i
  nDevIndex.i
  ; nCueFileDateModified.i         ; Deleted 5Jul2022 11.9.3.1a
  sMostRecentCueFile.s             ; Added 5Jul2022 11.9.3.1ab ; nb could be the recovery file
  nMostRecentCueFileDateModified.i ; Added 5Jul2022 11.9.3.1ab
  bDriveFreeSpaceResult.i
  qDriveFreeSpaceBytes.q
  sDriveFreeSpaceMsg.s
  nCueFileXML.i
  bCueFileXMLStatusOK.i
  bReadingSecondaryCueFile.i
EndStructure

;- tyTempDB
Structure tyTempDB
  bTempDatabaseOpen.i
  sTempDatabaseFile.s
  nTempDatabaseNo.i
  bTempDatabaseLoaded.i
  bTempDatabaseChanged.i
EndStructure

;- tyRecoveryFileInfo
Structure tyRecoveryFileInfo
  bRecFileFound.i
  sCueFile.s
  sSaveDateTime.s
  sProdTitle.s
  fMasterBVLevel.f
  nEditCuePtr.i
EndStructure

;- tyCED
Structure tyCED
  bProdCreated.i
  bProdChanged.i
  bProdDefDMXFadeTimeChanged.i
  bProdForLTCChanged.i
  bProdForMTCChanged.i
  bCueCreated.i
  bQACreated.i
  bQECreated.i
  bQFCreated.i
  bQGCreated.i
  bQICreated.i
  bQJCreated.i
  bQKCreated.i
  bQLCreated.i
  bQMCreated.i
  bQPCreated.i
  bQQCreated.i
  bQRCreated.i
  bQSCreated.i
  bQTCreated.i
  bQUCreated.i
  bProdDisplayed.i
  bCueDisplayed.i
  bQADisplayed.i
  bQEDisplayed.i
  bQFDisplayed.i
  bQGDisplayed.i
  bQIDisplayed.i
  bQJDisplayed.i
  bQKDisplayed.i
  bQLDisplayed.i
  bQMDisplayed.i
  bQPDisplayed.i
  bQQDisplayed.i
  bQRDisplayed.i
  bQSDisplayed.i
  bQTDisplayed.i
  bQUDisplayed.i
  sDisplayedSubType.s
  nCurrentCueLabelGadgetNo.i ; the gadget number of the cue label varies depending on production property settings for 'upper case' and 'cannot be changed'
  bKillCharacterEdit.i
  nPLLastPos.i
  sHoldWhichTimeProfile.s
  nSelectedItemForDragAndDrop.i
  nTreeEventCount.i   ; used for deciding when to clear the tvwProdTree tooltip, which is a 'hint' that may frustrate the user if it's continually displayed
  bChangeDevMap.i
  sNewDevMapName.s
  bDisplayApplyMsg.i
  bClosingEditor.i
  bDragCue.i
  nDragCueSourceItem.i
  nDragCueTargetItem.i
  sDragSourceCue.s
EndStructure

;- tyEditMemMsg
Structure tyEditMemMsg
  sLastMSItemDesc.s
  nLastMSChannel.i
  nLastMSParam1.i
  nLastMSParam2.i
  nLastMSParam3.i
  nLastMSParam4.i
  sLastMSParam1Info.s
  sLastMSParam2Info.s
  sLastMSParam3Info.s
  sLastMSParam4Info.s
EndStructure

;- tyEditMem
Structure tyEditMem   ; editing 'memory'
  nLastCtrlSendDevType.i
  sLastCtrlSendLogicalDev.s
  sLastRSItemDesc.s
  sLastNWItemDesc.s
  sLastHTItemDesc.s
  nLastEntryMode.i
  bLastAddCR.i
  bLastAddLF.i
  nLastMsgType.i
  nLastRemDevMsgType.i
  Array aLastMsg.tyEditMemMsg(#SCS_MSGTYPE_DUMMY_LAST)
  sLastMSQNumber.s
  nLastOSCCmdType.i
  bLastOSCReloadNamesGoScene.i
  bLastOSCReloadNamesGoSnippet.i
  bLastOSCReloadNamesGoCue.i
  nLastAutoActPosn.i
  nLastRemDevMuteAction.i
  ; for sub type R (run external program)
  bLastRPHideSCS.i
  bLastRPInvisible.i
  nLastNormToApply.i
EndStructure

;- tyLastPicInfo
Structure tyLastPicInfo
  nLastPicEndAt.i
  nLastPicTransTime.i
  nLastPicTransType.i
  bLastPicContinuous.i
EndStructure

;- tyVideoInfo
Structure tyVideoInfo
  sFileName.s
  nSourceWidth.l
  nSourceHeight.l
  nLength.i         ; length in milliseconds
  sInfo.s
  sTitle.s
  nRotation.i
EndStructure

;- tyVideoChannelInfo
Structure tyVideoChannelInfo
  nVideoChannel.l
  bChannelAssigned.i
EndStructure

;- tyVideoMonitors
Structure tyVideoMonitors
  sMonitorPin.s
  ; output screens
  nMaxOutputScreen.i    ; max output screen from aSub(j)\sScreens or aSub(j)\nMemoScreen from current cue file
  nMinOutputScreen.i    ; min output screen from aSub(j)\sScreens or aSub(j)\nMemoScreen from current cue file
  nOutputScreenCount.i  ; count of distinct output screens from aSub(j)\sScreens or aSub(j)\nMemoScreen from current cue file
  nMaxOutputSubCuePtr.i
  nMaxOutputScreenIncludingDefaultScreen.i
  Array bScreenReqd.i(#SCS_VID_PIC_TARGET_LAST)
  ; monitor windows (matching 'primary' output screens only)
  nMaxMonitorWindow.i   ; max aSub(j)\nOutputScreen or aSub(j)\nMemoScreen from current cue file
  nMinMonitorWindow.i   ; min aSub(j)\nOutputScreen or aSub(j)\nMemoScreen from current cue file
  nMonitorWindowCount.i ; count of distinct aSub(j)\nOutputScreen or aSub(j)\nMemoScreen from current cue file
  nMaxMonitorSubCuePtr.i
  Array bMonitorReqd.i(#SCS_VID_PIC_TARGET_LAST)
  ;
  bMonitorsPositioned.i
  bDisplayMonitorWindows.i
EndStructure

; tyChannelUpdate
Structure tyChannelUpdate
  nBassChannel.l
  nUpdateLength.l
EndStructure

;- tyFreeStream
Structure tyFreeStream
  bLocked.i
  nBassChannel.l
  nBassDevice.l
  bASIO.i
  nBassASIODevice.l
  nMixerStreamPtr.i
  qTimeRequested.q
  nAudPtr.i
  nDevNo.i
  bDecodeStream.i
  bUsingSplitStream.i
  bDone.i
EndStructure

;- tyMMedia
Structure tyMMedia
  sDefAudDevDesc.s
  ; SoundMan-Server info:
  sSMSVersion.s     ; SM-S version
  bDongleDetected.i
  bMMFinalSlide.i     ; set in calcBVLevel()
  nSMSMaxInputs.i      ; maximum number of inputs allowed for user's SM-S license
  nSMSMaxOutputs.i     ; ditto for outputs
  nSMSMaxPlaybacks.i   ; ditto for playbacks
  nSMSMaxSMPTEGenerators.i  ; SMPTE generators are only used in SCS for 'fake playback channels' - see SM-S documentation
  nSMSOutputsUsed.i
  nSampleRate.i
  nInterfaceCount.i ; number of interfaces
  sGainTableString.s
  sTestToneChan.s
  sTestToneFadeTime.s
  sTestLiveInputChan.s
  
  ; other info:
  bMastFaderMuted.i
  fMastFaderSliderLevelBeforeMute.f
  nTestToneMixerStreamPtr.i
  qTimeOfLastMemoryCheck.q
  nNextIndexForVideoF.i
  nNextIndexForVideoM.i
  nNextIndexForPictureF.i
  nNextIndexForPictureM.i
  bPause.i
  bInPlayCue.i
  nMaxBassDevice.i
  nStreamCreateError.l
  anSFRCuePtr.i[5]
  nSFRCueMax.i
  nAudPtrForGetMidiMode.i
  bEncodedFileInfoListChanged.i
  nFirst0BasedChan.i    ; set by get0BasedFrom1BasedChanString()
  nLast0BasedChan.i     ; set by get0BasedFrom1BasedChanString()
  nFirst1BasedChan.i    ; set by get0BasedFrom1BasedChanString()
  nLast1BasedChan.i     ; set by get0BasedFrom1BasedChanString()
  nBassSpeaker.l        ; set by getBassDeviceForLogicalDev()
  nSpeakerCount.i       ; set by getBassDeviceForLogicalDev()
  bCatchPreviewFrame.i
  bCatchPosFrame.i
  nCatchFrameTime.i
  nVideoWidth.i         ; used in loadFrame() and eventOnFrameH()
  nVideoHeight.i        ; ditto
  bInBlendPictures.i
  bAnimationWaiting.i
  
  nVideoImageCurrFadeOutTime.i
  nVideoImageCurrFadeOutSubPtr.i
  
  ; used to pass info from freeStreamRequest() to freeOneStreamNow()
  rFreeStream.tyFreeStream
  
  ; array for delaying BASS_ChannelUpdate() calls
  Array aChannelUpdate.tyChannelUpdate(0)
  nMaxChannelUpdateIndex.i
  
  fCalcLevel.f          ; set by calcLevelAndPanForPos()
  fCalcPan.f            ; set by calcLevelAndPanForPos()
  
  ; cross-fade (gapless) stream info
  nCurrGaplessSeqPtr.i
  
  ; ASIO info
  nAsioBufSize.i    ; size of aAsioBuffer in bytes
  nAsioBufLen.i     ; length of data last written to aAsioBuffer by AsioProc_ (in bytes)
  
EndStructure

;- tyEQBandSettings
Structure tyEQBandSettings
  bEQBandSelected.i
  sEQGainDB.s
  nEQFreq.i
  fEQQ.f
EndStructure

;- tyDevMapDev
Structure tyDevMapDev     ; ************** setProdDevChgs() in CueEditor.pbi may need to be modified if any changes are made to this structure **************
  nDevGrp.i               ; internal representation of dev group
  nDevType.i              ; internal representation of dev type
  bExists.i
  nDevMapId.i             ; id of parent device map
  nNextDevIndex.i         ; pointer to next device for this device map (-1 if last)
  nPrevDevIndex.i         ; pointer to previous device for this device map (-1 if first)
  sLogicalDev.s
  sPhysicalDev.s
  sOrigPhysicalDev.s      ; used for checking in WEP_btnApplyDevChgs_Click() if we want to ask the user if they want to 'SaveAs' instead of 'Apply'
  nDevId.i                ; device id for corresponding logical device in grProd, eg see tyAudioLogicalDevs
  nPhysicalDevPtr.i
  nDevState.i
  bDevFound.i
  bReopenDevice.i
  bDeleteThisDev.i        ; only used in removeDeadDevMaps()
  bNewDevice.i            ; device newly created this run (added 3Nov2015 11.4.1.2g)
  bDefaultDev.i
  bDummy.i
  bIgnoreDevThisRun.i     ; added 18Nov2015 11.4.1.2m - may be set for a missing device, causing the device to be treated as a dummy device for this run (ie not to affect saved device map assignments)
  bNotFoundMsgDisplayed.i ; added 10Feb2020 11.8.2.2ak following email from Steve Martin
  bConnectWhenReqd.i ; 19Sep2022 11.9.6 (initially added for network client connections following request from Jason Mai 14Sep2022)
  
  ;
  ; audio dev info
  ;
  bNoDevice.i
  bNoSoundDevice.i
  bReroutedToDefault.i    ; 16Apr2018 11.7.0.1au - an 'ignored' audio device re-routed to the Windows default sound device
  nFirst1BasedOutputChan.i
  nNrOfDevOutputChans.i          ; number of output channels (1 for mono, 2 for stereo, 6 for 5.1, etc)
  s1BasedOutputRange.s        ; 1-based output channel string for commands that operate on entire SCS device, eg "1-2"
  nFirst0BasedOutputChan.i    ; first output channel on the hardware device, not in the SM-S ASIO group (if used)
  nFirst0BasedOutputChanAG.i  ; first output channel in the SM-S ASIO group (if used)
  s0BasedOutputRangeAG.s      ; SM-S ASIO group output channel string for commands that operate on entire SCS device, eg "0-1"
  nDelayTime.i
  sDevOutputGainDB.s
  fDevOutputGain.f
  bUseFaderOutputGain.i
  sDevFaderOutputGainDB.s
  fDevFaderOutputGain.f
  bOutputMuteOn.i
  bOutputMuteTmpOn.i    ; temporarily muted because at least one other output is solo and this output is not being soloed
  bBassASIO.i
  nBassDevice.l
  nBassASIODevice.l
  nBassSpeakerFlags.i
  bUnavailableMessageDisplayed.i
  nSilenceChan.i
  nTestToneChan.i
  ; BASS fields
  nFirstASIOChannel.l
  nLastASIOChannel.l
  nMixerStreamPtr.i
  nReassignDevMapDevPtr.i
  sReassignPhysicalDev.s
  sReassignSpeaker.s
  sSpeaker.s
  nDevChannelCount.i
  nDevChannel.l[#SCS_MAX_DEV_CHANNEL+1]
  nDSPInd.i[#SCS_MAX_DEV_CHANNEL+1]
  ;
  ; video audio dev info
  ;
  nVideoPlayingCount.i
  dAudioPeakLeftPercent.d
  dAudioPeakRightPercent.d
  nVideoLevel.l ; level last sent to TVG_SetAudioVolume(), and used when calculating VU meter bar heights in updateSpectrumTVG()
  nVideoPan.l   ; balance last sent to TVG_SetAudioBalance(), and used when calculating VU meter bar heights in updateSpectrumTVG()
  ;
  ; Video Capture device info
  ;
  sVidCapFormat.s
  dVidCapFrameRate.d

  ;
  ; live input dev info
  ;
  nFirst1BasedInputChan.i
  nNrOfInputChans.i         ; number of input channels (1 for mono, 2 for stereo)
  s1BasedInputRange.s       ; 1-based input channel string for commands that operate on entire SCS device, eg "1-2"
  nFirst0BasedInputChan.i   ; first input channel on the hardware device, not in the SM-S ASIO group
  nFirst0BasedInputChanAG.i ; first input channel in the SM-S ASIO group
  s0BasedInputRangeAG.s     ; SM-S ASIO group input channel string for commands that operate on entire SCS device, eg "0-1"
  nInputDelayTime.i
  sInputGainDB.s
  fInputGain.f
  bUseFaderInputGain.i
  sFaderInputGainDB.s
  fFaderInputGain.f
  bInputMuteOn.i
  bInputMuteTmpOn.i     ; temporarily muted because at least on other input is solo and this input is not being soloed
  sInputDBTrim.s
  fInputTrimFactor.f
  fInputVolNow.f
  bInputEQOn.i            ; set #True if at least one EQ group is selected
  bInputLowCutSelected.i
  nInputLowCutFreq.i
  aInputEQBand.tyEQBandSettings[#SCS_MAX_EQ_BAND+1]
  nInputPlayCount.i        ; count of currently-playing Aud's using this live input device
  ;
  ; MIDI port info
  ;
  nMidiInPhysicalDevPtr.i
  nMidiOutPhysicalDevPtr.i
  ; MIDI Thru 'in port' info
  sMidiThruInPhysicalDev.s
  nMidiThruInPhysicalDevPtr.i
  bMidiThruInDummy.i
  ; pre 20150401 fields
  nMidiChannelx.i
  nCtrlMethodx.i
  nMidiDevIdx.i
  nMscCommandFormatx.i
  nGoMacrox.i
  aMidiCommandx.tyMidiCommand[#SCS_MAX_MIDI_COMMAND+1]
  ;
  ; RS232 port info
  ;
  ; pre 20150401 fields
  nRS232DataBitsx.i
  fRS232StopBitsx.f
  nRS232Parityx.i
  nRS232BaudRatex.i
  nRS232Handshakingx.i
  nRS232RTSEnablex.i
  nRS232DTREnablex.i
  ;
  ; DMX port info
  ;
  nDMXSerial.l  ; see comments about serial numbers under tyDMXDevices
  sDMXSerial.s
  nDMXPorts.i
  nDMXPort.i    ; 1 or 2 for ENTTEC DMX USB PRO MK2, else 0
  nDMXRefreshRate.i   ; only required for Enttec OPEN DMX USB or equivalent. eg 40 = 40fps, 0 = no refresh
  sDMXIpAddress.s     ; IP address string for Artnet or sACN
  Array aDevFixture.tyDevFixture(0)
  nMaxDevFixture.i
  ; pre 20150401 fields
  nDMXPrefx.i            ; preferred value notation: 0 = 0-255, 1 = %
  nDMXTrgCtrlx.i
  nDMXTrgValuex.i
  aDMXCommandx.tyDMXCommand[#SCS_MAX_DMX_COMMAND+1]
  ;
  ; Network info
  ;
  sRemoteHost.s
  nRemotePort.i
  nLocalPort.i
  nCtrlSendDelay.i    ; control send inter-message delay time (default 100ms for TCP/Telnet, or 0ms for UDP, but could be set to any value)
  ; pre 20150401 fields
  nNetworkRolex.i
  aMsgResponsex.tyNetworkMsgResponse[#SCS_MAX_NETWORK_MSG_RESPONSE+1]
  nMaxMsgResponsex.i
  bReplyMsgAddCRx.i
  bReplyMsgAddLFx.i
  ;
  ; HTTP info
  ;
  ; pre 20150401 fields
  sHTTPStartx.s
EndStructure

;- tyDevMap
Structure tyDevMap
  sDevMapName.s
  nDevMapId.i
  ; bDevMapC.i              ; 'common' devmap - added post build 20150401 for devices OTHER THAN audio output (#True)
  nAudioDriver.i
  nOrigAudioDriver.i      ; used for checking in WEP_btnApplyDevChgs_Click() if we want to ask the user if they want to 'SaveAs' instead of 'Apply'
  nFirstDevIndex.i
  nFirstLiveGrpIndex.i
  bNewDevMap.i
  bDeleteThisDevMap.i     ; only used in removeDeadDevMaps()
  nMenuItemNo.i           ; set for DeviceMap popup menu
  sDevMapFileName.s   ; Host devmap filename (file part only)
  sDevMapFileSaved.s  ; "_Saved_" data from host devmap file, eg "2022/11/08 22:54:48"
  bDevMapFileSelectedDevMap.i
  sDevMapSortKey.s
  bIgnoreThisDevMap.i
EndStructure

;- tyDevMapCheckItem
Structure tyDevMapCheckItem
  nDevGrp.i
  nDevType.i
  nDevId.i
  sLogicalDev.s
  sPhysicalDevInfo.s
  sCheckMsg.s
  nCheckResult.i  ; added 6Mar2020 11.8.2.2bc following bug reported by Stas Ushomirsky
EndStructure

;- tyDevMapCheck
Structure tyDevMapCheck
  bDevGrpIssue.i[#SCS_DEVGRP_LAST+1]
  Array aCheckItem.tyDevMapCheckItem(0)
  nCheckItemCount.i
EndStructure

;- tyImportDev
Structure tyImportDev
  nDevGrp.i
  nDevType.i
  s2ndLogicalDev.s
  b2ndUsedInCues.i
  s2ndCues.s
  s1stLogicalDev.s
EndStructure

;- tyLiveGrp
Structure tyLiveGrp   ; live input group or sub-group
  nLiveGrpId.i
  sLiveGrpName.s
  bExists.i
  nDevGrp.i               ; #SCS_DEVGRP_LIVE_INPUT (included in structure for possible later expansion to other device types)
  nDevType.i              ; #SCS_DEVTYPE_LIVE_INPUT (included in structure for possible later expansion to other device types)
  nDevMapId.i             ; id of parent device map
  nNextLiveGrpIndex.i     ; pointer to next live input group for this device map (-1 if last)
  nPrevLiveGrpIndex.i     ; pointer to previous live input group for this device map (-1 if first)
  nCompCount.i            ; number of component live input devices AND/OR live input groups
  sCompName.s[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]      ; array of component live input devices AND/OR live input groups
  nDevMapDevPtr.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]  ; denormalized array of pointers to live input devices
EndStructure

;-- Device Maps
;- tyMaps (Device Maps)
Structure tyMaps
  Array aMap.tyDevMap(0)
  Array aDev.tyDevMapDev(0)
  Array aLiveGrp.tyLiveGrp(0)
  nMaxMapIndex.i
  nMaxDevIndex.i
  nMaxLiveGrpIndex.i
  sSelectedDevMapName.s
  nVersion.i
  nDevMapFileBuildDate.i
EndStructure

;- tyTestTone
Structure tyTestTone
  bPlayingTestTone.i
  bContinuousTestTone.i
  qTimeTestToneStarted.q
  qTimeToRemoveTimer.q
  dTestToneIndex.d
  nDevMapDevPtr.i
  nTestToneDataLength.i
  dTestToneFreq.d
  dTestTonePos.d
  dTestToneSampleRate.d
  nTestToneChan.l
  nTestToneDevNo.i
  nMixerStreamPtr.i
  bSetLevelInStreamProcTestTone.i
EndStructure

;- tyTestLiveInput
Structure tyTestLiveInput
  bRunningTestLiveInput.i
  nInputDevMapDevPtr.i
  nOutputDevMapDevPtr.i
  nTestLiveInputChan.i
  sSMSStopCommand.s
EndStructure

;- tyOutputRequested
Structure tyOutputRequested
  nPhysicalDevPtr.i
  nOutputChan.i
EndStructure

;- tyPlayback
Structure tyPlayback
  nAssignedTo.i       ; see enumeration #SCS_PLB...
  sFileName.s
  nFileTrackNo.i
  nFileTrackCount.i
  nPrimaryChan.i      ; playback channel assigned to track 1
  sPChanListPrimary.s ; playback channel list (held for primary channel only)
  nAudPtr.i
  sTrackCommandString.s
  qTimeAssigned.q
EndStructure

;- tyFileNotFound
Structure tyFileNotFound
  sFileName.s
  nAudPtr.i
  sNewFileName.s
  bFound.i
EndStructure

;- tyASIOGroup
Structure tyASIOGroup
  sNameWithQuotes.s
  bGroupCreated.i
  bGroupInitialized.i
  nGroupInputs.i
  nGroupOutputs.i
  nInterfaceCount.i
  nSampleRate.i
  sCreateGroupSMSCommand.s    ; used for determining if group needs to be re-created
  sErrorMsg.s
  Array sAsioDev.s(2)
  Array nFirstInputChanAG.i(2)  ; first input channel in this ASIO group for this device
  Array nFirstOutputChanAG.i(2) ; first output channel in this ASIO group for this device
  nMaxAsioDevIndex.i
EndStructure

;- tySMSOutput
Structure tySMSOutput
  n0BasedOutputChanAG.i
  nFirstDevPtr.i
  nLastDevPtr.i     ; will only be different to nFirstDevPtr if more than one SCS device uses this SM-S output
EndStructure

;- tyPreview
Structure tyPreview
  nPreviewChannel.l   ; long
  nPreviewMixerStreamPtr.i
  bPreviewChannelOpen.i
  nPreviewBassDevice.l ; long
  qPreviewLengthInBytes.q  ; (quad .q in PB) (set by BASS_ChannelGetLength) ?????????????????
  nPreviewTrackLengthInMS.i
  sPPrimaryChan.s
  sPChanList.s
  sPXChanList.s
EndStructure

;- tyEncodedFileInfo
Structure tyEncodedFileInfo
  sFilePart.s
  sSourceFile.s
  sSourceModified.s         ; date/time file modified
  qSourceSize.q
  sEncodedFile.s
  bKeep.i
EndStructure

;- tySyncInfo
Structure tySyncInfo
  nSyncHandle.l
  nChannel.l
  nSyncType.l
  bGaplessStream.i
  bMixerSync.i
  bActive.i
EndStructure

;- tySMSSyncPoint
Structure tySMSSyncPoint
  nAudPtr.i         ; nb -1 = entry not in use; -2 = preview channel
  nSyncType.i
  nSyncPos.i
  sSyncProcedure.s
  nLoopSyncIndex.i
  nLoopInfoIndex.i
  bLoopReleased.i
EndStructure

;- tyOSCCtrlSendItem May2025
Structure tyOSCCtrlSendItem
  sMsgType.s
  sMsgDesc.s
  sMsgShortDesc.s
  sValType.s
  sValDesc.s
  nValBase.i
  Array sValDataValue.s(0)
  nMaxValDataValue.i
  sFdrDesc.s
EndStructure

;- tyOSCCtrlSendItemsForDev
Structure tyOSCCtrlSendItemsForDev
  sLoadedForDevCode.s ; eg "BR_X32", or blank if not yet loaded
  rGoCue.tyOSCCtrlSendItem
  rGoScene.tyOSCCtrlSendItem
  rGoSnippet.tyOSCCtrlSendItem
  rMuteChannel.tyOSCCtrlSendItem
  rMuteDCA.tyOSCCtrlSendItem
  rMuteAuxIn.tyOSCCtrlSendItem
  rMuteFXRtn.tyOSCCtrlSendItem
  rMuteBus.tyOSCCtrlSendItem
  rMuteMatrix.tyOSCCtrlSendItem
  rMuteMG.tyOSCCtrlSendItem
  rMuteMain.tyOSCCtrlSendItem
  rSetChannelLevels.tyOSCCtrlSendItem
  rSetDCALevels.tyOSCCtrlSendItem
  rSetAuxInLevel.tyOSCCtrlSendItem
  rSetFXRtnLevel.tyOSCCtrlSendItem
  rSetBusLevel.tyOSCCtrlSendItem
  rSetMatrixLevel.tyOSCCtrlSendItem
  rSetMGLevel.tyOSCCtrlSendItem
  rSetMainFader.tyOSCCtrlSendItem
EndStructure

;- tyX32NWData (Behringer X32) Network Data
Structure tyX32NWData
  sInfo.s
  Array sChannel.s(0)
  Array sDCAGroup.s(0)
  Array sAuxIn.s(0)
  Array sFXReturn.s(0)
  Array sBus.s(0)
  Array sMatrix.s(0)
  Array sMain.s(0) ; handles LR and MC (mono/center)
  Array sMuteGroup.s(0)
  Array sCue.s(0)
  Array sScene.s(0)
  Array sSnippet.s(0)
  nMaxChannel.i
  nMaxDCAGroup.i
  nMaxAuxIn.i
  nMaxUSBIn.i
  nMaxFXReturn.i
  nMaxBus.i
  nMaxMatrix.i
  nMaxMain.i
  nMaxMuteGroup.i
  nMaxCue.i
  nMaxScene.i
  nMaxSnippet.i
  ; counts of 'name' messages received, eg number of "/ch/../config/name" messages received
  nChannelNameCount.i
  nAuxInNameCount.i
  nFXReturnNameCount.i
  nBusNameCount.i
  nMatrixNameCount.i
  nDCAGroupNameCount.i
  nMainNameCount.i
  nCueNameCount.i
  nSceneNameCount.i
  nSnippetNameCount.i
  ; used by fmOSCCapture for data 'captured' for setting up Control Send cues
  Array nX32ItemOn.i(0) ; 1 = On; 0 = Off (Muted)
EndStructure

;- tySendWhenReady
; for network control send messages waiting for the network device to be ready, eg after receiving OK in response to sending a password
Structure tySendWhenReady
  nSWRSubPtr.i
  nSWRCtrlSendIndex.i
  sSWRSendWhenReady.s
  nSWRStringFormat.i
EndStructure

;- tyNetworkControl
Structure tyNetworkControl
  bControlExists.i
  nDevMapId.i
  nDevType.i
  nDevNo.i
  sLogicalDev.s
  nDevMapDevPtr.i
  nNetworkProtocol.i
  nNetworkRole.i
  nCtrlSendDelay.i  ; control send inter-message delay time
  bNWDummy.i        ; #True if dummy connection - useful during design if no real Network connections are available
  bNWIgnoreDevThisRun.i ; added 16Mar2020 11.8.2.3aa following issues reported by Stas Ushomirsky where the device's '\bIgnoreDevThisRun=#True' was cleared in a second call to startNetwork()
  bRAIDev.i         ; #True if connection for remote access interface device (in which case there will be no device map entry)
  bSCSBackupDev.i   ; #True if connection for SCS Backup (in which case there will be no device map entry)
  bNetworkDevInitialized.i
  bConnectWhenReqd.i ; 22Sep2022 11.9.6 (initially added for network client connections following request from Jason Mai 14Sep2022)
  sRemoteHost.s
  nRemotePort.i
  nLocalPort.i
  nCtrlNetworkRemoteDev.i
  sCtrlNetworkRemoteDevPassword.s
  nCueNetworkRemoteDev.i
  nClientConnection.i
  nServerConnection.i
  nOpenConnectionTimeout.i
  sClientIP.s
  nClientPort.i
  bNetworkControl.i
  nNetworkErrNo.i
  sNetworkErrDesc.s
  bHideWarning.i
  sNetworkDevDesc.s
  bClientConnectionLive.i
  bClientConnectionNeedsReady.i
  bClientConnectionReady.i
  bUDPServerResponding.i
  bOSCServer.i
  bOSCClient.i
  nOSCVersion.i
  nUseNetworkControlPtr.i       ; >= 0 if this is the same device as an existing device, eg for an X32 which is connected for both Control Send and Cue Control
  Array aSendWhenReady.tySendWhenReady(0)
  nCountSendWhenReady.i
  qSendTime.q
  sMsgSent.s
  qReceiveTime.q
  rSendTime.SYSTEMTIME
  rReceiveTime.SYSTEMTIME
  sOSCPathOriginal.s    ; OSC path as unpacked by unpackOSCMsg(), eg "/_ctrl/go"
  sOSCPath.s            ; derived from sOSCPathOriginal but modified to standardize later processing, eg changes paths like "/_ctrl/go" to "/ctrl/go"
  sOSCTagTypes.s
  nOSCStringCount.i
  nOSCLongCount.i
  nOSCFloatCount.i
  sOSCDisplayMsg.s
  Array sOSCString.s(0)
  Array nOSCLong.l(0)
  Array fOSCFloat.f(0)
  bOSCTextMsg.i
  sOSCTextParam1.s
  sOSCTextParam2.s
  sOSCTextParam3.s
  bAddLF.i
  rX32NWData.tyX32NWData
  ; current values, ie parameters used when this port was last opened
  nCurrNetworkProtocol.i
  nCurrNetworkRole.i
  sCurrRemoteHost.s
  nCurrRemotePort.i
  nCurrLocalPort.i
  nCurrDevType.i
EndStructure

;- tyOSCTagData
Structure tyOSCTagData
  nInteger.i
  fFloat.f
  sString.s
EndStructure

;- tyOSCMsgData
Structure tyOSCMsgData
  bOSCTextMsg.i
  sOSCItemString.s
  sOSCAddress.s
  sTagString.s
  nTagCount.i
  Array aTagData.tyOSCTagData(4)  ; minimum array size = 4 to save having to constantly check for a redim in FMP_sendCueFileName() and FMP_sendCommandIfReqd()
  sOSCTextParam.s
  bAddLF.i
EndStructure

;- tyX32CueControl
Structure tyX32CueControl
  nX32ClientConnection.i
  bCueControlActive.i
  qLastXRemoteTime.q    ; time the last /xremote command was sent (needs to be sent at least every 10 seconds)
  aX32Command.tyX32Command[#SCS_MAX_X32_COMMAND+1]
EndStructure

;- tyNetworkIn
Structure tyNetworkIn
  sMessage.s
  bReady.i
  bDone.i
  qTimeIn.q
  bRAI.i
  bVMix.i
EndStructure

;- tyHTTPSendMsg
Structure tyHTTPSendMsg
  sHTTPSendMsg.s
  bHTTPSendMsgSent.i
  nCueNumber.i
  *pHTTPResponseBuffer
  nHTTPSendIsATest.i
  nHTTPGetStatusCode.i
EndStructure

;- tyHTTPControl
Structure tyHTTPControl
  bExists.i
  nDevMapId.i
  nDevType.i
  sHTTPDevDesc.s
  nMaxHTTPSendMsg.i
  Array aHTTPSendMessage.tyHTTPSendMsg(0)
EndStructure

;- tyVidPicTarget
Structure tyVidPicTarget
  bTargetExists.i
  nVidPicTarget.i
  nCurrVideoPlaybackLibrary.i
  nTargetCanvasNo.i ; dynamically set, eg in editor may either point to the embedded display, or to the canvas on the output screen
  nVideoCanvasNo.i
  nTVGDisplayMonitor.i
  nTargetImageNo.i
  nTargetWidth.i                          ; width of this target, regardless of image size
  nTargetHeight.i                         ; height of this target, regardless of image size
  nBlackImageNo.i                         ; a black image that fills this target - used for fade-to-black or fade-from-black
  nBlankImageNo.i                         ; a blank image that fills this target - used in editor for new items (no picture yet assigned)
  nLogoImageNo.i
  nLogoAudId.i
  nLogoFadeInTime.i
  nLogoFadeStartTime.i
  bLogoCurrentlyDisplayed.i
  nPrimaryImageNo.i
  nPrevPrimaryAudPtr.i      ; nPrimaryAudPtr rolled into nPrevPrimaryAudPtr before being changed
  nPrimaryAudPtr.i          ; populated when this target assigned to an aAud() entry
  nPrimaryFileFormat.i      ; ditto
  sPrimaryFileName.s        ; ditto
  nPrevPlayingSubPtr.i
  nPlayingSubPtr.i          ; mainly added for memo sub-cues
  nCurrentSubPtr.i          ; current sub-cue displayed on this target, even if it's a secondary screen, eg if "\sScreens=2,3" then nCurrentSubPtr would be set in both targets 2 and 3 ; added 13Feb2020 11.8.2.2al
  nPrevBlendFactor.i
  nBlendTime.i
  qBlendStartTime.q
  nBlendedImageNo.i
  nSavedBlendedImageNo.i
  bBlendingLogo.i
  nMovieNo.i
  sMovieFileName.s
  nMovieAudPtr.i
  nCurrMoviePos.i
  bVideoRunning.i
  nVolume.i
  nBalance.i
  ; monitor info
  nMonitorWindowNo.i
  nMonitorCanvasNo.i
  nCurrMonitorCanvasNo.i
  nMonitorWidth.i
  nMonitorHeight.i
  bImageOnMonitor.i
  ; window details below used for P (editor preview), F2, F3, etc, but not for T (timeline)
  nMainWindowNo.i ; will be set to #WV2 for #SCS_VID_PIC_TARGET_F2, #WV3 for #SCS_VID_PIC_TARGET_F3, etc, or #WED for #SCS_VID_PIC_TARGET_P
  nFullWindowX.i  ; the main window X position BEFORE any screen adjustments made
  nFullWindowY.i
  nFullWindowWidth.i
  nFullWindowHeight.i
  nMainWindowX.i  ; the main window X position AFTER any screen adjustments made
  nMainWindowY.i
  nMainWindowWidth.i
  nMainWindowHeight.i
  nMainWindowXWithinDisplayMonitor.i
  nMainWindowYWithinDisplayMonitor.i
  nDesktopWidth.i
  nDesktopHeight.i
  nDisplayScalingPercentage.i
  nMonitorArrayIndex.i ; pointer to entry in gaMonitors() ; Added 25Oct2022 11.9.6
  sVideoDevice.s
  nMoviePlaying.i
  bFirstPreview.i
  bShowingPreviewImage.i
  bShareScreen.i    ; #True if this VidPicTarget may be sharing a screen with other VidPicTargets (ie on the final screen, eg if there are two screens available but the cues refer to screens greater than 2)
  
  nCurrAudPtr.i
  
  nImage1.i         ; image currently fully displayed or fading in (NOT the blend of two images) - may be an actual image or be the black image (eg black if nImage2 is fading out to black)
  nImage2.i         ; image being faded out, or 0 if no fading occurring - may be an actual image or be the black image (eg black if Image1 is fading in from black)
  nBlendedImage.i   ; current result of blending nImage1 and nImage2, or 0 if blending not currently being processed
  nAudPtr1.i        ; aAud() pointer for nImage1, or -1 if no nImage1
  nAudPtr2.i        ; aAud() pointer for nImage2, or -1 if no nImage2
  
  ; blend control
  bInBlendThreadProcess.i
  bInFadeStartProcess.i
EndStructure

;- tyVUBar
Structure tyVUBar ; A 'bar' is a VU component displaying all or part of an audio device. Either 1 or 2 channels may be included in each 'bar', corresponding to 1 or 2 audio channels
  sVUBarLogicalDev.s
  sVUBarLabel.s
  bIgnoreDevThisRun.i
  nBarX.i
  bNoDevice.i
  nVUBarDevType.i
  fVUOutputGain.f
  nMeterCount.i ; 1 or 2
EndStructure

;- tyVUMeter
Structure tyVUMeter ; A 'meter' is a component within a 'bar' (see tyVUBar above). There may be 1 or 2 meters within a bar
  nParentBarIndex.i
  nMeterX.i
  nMeterY.i
  nDevMapDevPtr.i
  nBassASIODevice.l
  nDevChannel.l
  nMixerStreamPtr.i
  nMixerChanNr.i
  fVULevel.f
  nSMSVUAve.i
  nSMSVUPeak.i
  nOutputGainY.i
  nPeakValue.i
  qPeakTime.q
  nDevType.i
EndStructure

;- tyImageData
Structure tyImageData
  sFileName.s
  nRotate.i       ; 0 = no rotate; 90/180/270 = rotate 90/180/270 degrees
  nFlip.i         ; 0 no flip; 1 = flip horizontal; 2 = flip vertical; 3 = flip horizontal and vertical
  nXpos.i
  nYPos.i
  nSize.i
  nAspectRatioType.i
  nAspectRatioHVal.i
  nImageNo.i
  nTargetWidth.i
  nTargetHeight.i
  nImageOpenCount.i
EndStructure

;- tyCuePanels
Structure tyCuePanels
  nMaxDevLineNo.i
  nMaxDevLines.i
  nTwiceDevLines.i
  bCreatePanelsReqd.i
  nCuePanelHeightSml.i    ; small cue panel (one line only)
  nCuePanelHeightStd.i    ; standard cue panel
  nCuePanelGap.i
  nCuePanelHeightSmlPlusGap.i
  nCuePanelHeightStdPlusGap.i
EndStructure

;- tyDispPanel
Structure tyDispPanel
  ; see also tyPnlVars
  nCuePanelIndex.i
  nDPCuePtr.i
  nDPSubPtr.i
  nDPAudPtr.i
  qDPTimeCueLastEdited.q
  qDPTimeSubLastEdited.q
  qDPTimeAudLastEdited.q
  sDPSubType.s
  nDPSubState.i
  nDPPrevSubState.i   ; added 2May2022pm 11.9.1
  nDPAudLinkCount.i   ; added 2May2022 11.9.1
  nDPLinkedToAudPtr.i ; added 2May2022 11.9.1
  bPicture.i
  bAwaitingLoad.i
  bDeviceAssigned.i[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  bNoDevice.i[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  bIgnoreDev.i[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  bEnableVolAndPan.i[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  fDispCueVolNow.f[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  fDispCuePanNow.f[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  bDisplayPan.i[#SCS_MAX_AUDIO_DEV_PER_DISP_PANEL+1]
  bAtLeastOnePanDisplayed.i
  nDispCountDownTimeLeft.i
  sLinked.s
  bEnableRelease.i
  bEnableFadeOut.i
  bGradientDrawn.i
  nMaxDev.i
  sDevices.s[#SCS_MAX_CUE_PANEL_DEV_LINE + 1]
  nVisualWarningState.i ; 0 = not required, 1 = on (normal), 2 = off (dim)
  qVisualWarningLastChangeTime.q
  nVisualWarningTimeRemaining.i
  nTransportSwitchIndex.i
  nTransportSwitchCode.i
  bM2T_Active.i ; 'Move to Time' active
  sPrevDevNames2.s ; Added for gang devices changes
EndStructure

;- tyDispPanelKeyInfo
Structure tyDispPanelKeyInfo
  nDPK_CuePtr.i
  nDPK_SubPtr.i
  nDPK_AudPtr.i
  qDPK_TimeCueLastEdited.q
  qDPK_TimeSubLastEdited.q
  qDPK_TimeAudLastEdited.q
  nDPK_SubState.i
  nDPK_AudLinkCount.i   ; added 2May2022 11.9.1
  nDPK_LinkedToAudPtr.i ; added 2May2022 11.9.1
EndStructure

;- tyDisplayable
Structure tyDisplayable
  bDisplayThisPanel.i
  bCompleted.i
  bHibernating.i
  nDispPanelPtr.i       ; pointer to corresponding entry in aDispPanel(), which is dynamically re-ordered according to what's playing
  nScrollBarValue.i
  nGadgetY.i
  bHotkey.i
  bExtAct.i
  bCallableCue.i
  nDACuePtr.i
  nDASubPtr.i
  nDAAudPtr.i
  nSubNo.i
  nPlayNo.i
  nSubState.i
  bSubTypeP.i
  nAudState.i
  qDATimeStarted.q
  qDATimeCueStarted.q
  sLabel.s
EndStructure

;- tyPnlVars
; see also tyDispPanel
Structure tyPnlVars
  bInUse.i                        ; #True if this cue panel has been created by PNL_New
  sName.s                         ; name of cue panel (mainly for debug messages)
  bInLoadingDisplay.i
  bSlidersInitialised.i
  ; gadget numbers
  btnMoveToTimeApply.i
  btnMoveToTimeCancel.i
  cntCuePanel.i
  cntFaderAndPanCtls.i
  cntMoveToTimePrimary.i
  cntTransportCtls.i
  CompilerIf #c_cuepanel_multi_dev_select
  cvsDevice.i[#SCS_MAX_CUE_PANEL_DEV_LINE + 1]
  CompilerEndIf
  cvsFadeOut.i
  cvsFirst.i
  cvsLinked.i
  cvsPause.i
  cvsPlay.i
  cvsPnlOtherInfo.i
  cvsRelease.i
  cvsRewind.i
  cvsShuffle.i
  cvsStop.i
  cvsSwitch.i
  imgType.i
  lblDescriptionA.i   ; used for cue types other than Note
  lblDescriptionB.i   ; used for Note cue type
  CompilerIf #c_cuepanel_multi_dev_select = #False
  lblDevice.i[#SCS_MAX_CUE_PANEL_DEV_LINE + 1]
  CompilerEndIf
  lblMoveToTimePrimary.i
  lblMoveToTimeSecondary.i
  lblRunningInd.i
  lblSoundCue.i
  lnBottomBorder.i
  lnTopBorder.i
  sOtherInfoText.s
  sldCuePan.i[#SCS_MAX_CUE_PANEL_DEV_LINE + 1]
  sldCueVol.i[#SCS_MAX_CUE_PANEL_DEV_LINE + 1]
  sldMoveToTimePosition.i
  sldPnlProgress.i
  txtLinked.i
  txtMoveToTime.i
  nFirstGadgetId.i ; id of first gadget created for this cue panel (will be set to \cntCuePanel in createCuePanelGadgets())
  nLastGadgetId.i  ; id of last gadget created for this cue panel (will be set to \lnBottomBorder in createCuePanelGadgets())
  
  ; fonts (sizes based on original sizes before resizing)
  font8Regular.i
  font8Bold.i
  font10Bold.i
  
  ;Property Variables:
  m_nDispPanel.i
  m_nCuePtr.i
  m_nSubPtr.i
  m_nAudPtr.i ; Added 23Mar2024 11.10.2bm
  
  ; size and position
  nContainerWidth.i       ; width of container gadget
  nContainerHeight.i      ; height of container gadget
  nContainerX.i           ; window X position of container gadget left
  nContainerY.i           ; window Y position of container gadget top
  nPosTop.i[#SCS_MAX_CUE_PANEL_DEV_LINE + 1]
  nSldVolLeftA.i
  nSldVolLeftB.i
  nSldVolWidthA.i
  nSldVolWidthB.i
  nSldPanLeftA.i
  nSldPanLeftB.i
  nSldPanWidthA.i
  nSldPanWidthB.i
  nSldCuePanOffset.i
  nSldCueVolOffset.i
  nBackColor.l
  nTextColor.l
  bNextManualCue.i
  bActiveOrComplete.i
  bPlaying.i
  nImageHandle.i
  
  nSldCueVolOrigLeft.i
  nSldCueVolOrigWidth.i
  nSldCuePanOrigLeft.i
  nSldCuePanOrigWidth.i
  nLblDeviceOrigLeft.i
  nLblDescriptionOrigWidth.i
  nLblOtherInfoOrigWidth.i
  nSliderOrigVerticalSpace.i
  
  nCntFaderAndPanCtlsStdHeight.i
  
  nDisplayMode.i  ; see #SCS_CUEPNL_DISP... constants
  
  bShowTransportControls.i
  bShowFaderAndPanControls.i
  
  nLastMoveToTime.i ; time shown in the M2T time field when last applied via the Apply button, this session, for the cue displayed in this cue panel
  nLastM2TPrimaryCuePtr.i

EndStructure

;- tyToolBar
Structure tyToolBar
  nBarId.i
  nHostId.i   ; host container gadget id or window id - must be populated from GadgetID(#Gadget) or WindowID(#Window), so nHostId can be used in UseGadgetList(\nHostId)
  nCatCount.i
  nBarLeft.i
  nBarTop.i
  nBarWidth.i
  nBarMinWidth.i
  nBarHeight.i
  nFontNormal.i
  nFontBold.i
  nCatLeft.i  ; left position of first displayed category in toolbar
  nCatTop.i
  nCatHeight.i
  ; gadget id's
  cntToolBar.i
EndStructure

;- tyToolBarCat
Structure tyToolBarCat
  nCatId.i
  nBarId.i
  nCatLeft.i
  nCatWidth.i
  nCatMinWidth.i
  nCatDisplayOrder.i
  nBtnCount.i
  sCaption.s
  bCatVisible.i
  nBtnLeft.i  ; left position of first displayed button in category
  nBtnTop.i
  nBtnHeight.i
  bCatMore.i
  bCatEnabled.i
  bCatMouseOver.i
  ; gadget id's
  cntToolCat.i
  cvsCatCaption.i
EndStructure

;- tyToolBarBtn
Structure tyToolBarBtn
  nBtnId.i
  nCatId.i
  nBtnLeft.i
  nBtnWidth.i
  nImgWidth.i
  nImgHeight.i
  nBtnDisplayOrder.i
  hBtnPicture1En.i
  hBtnPicture1Di.i
  hBtnPicture2En.i
  hBtnPicture2Di.i
  sBtnCaption1.s
  sBtnCaption2.s
  sBtnTooltip1.s
  sBtnTooltip2.s
  bBtnMore.i
  bBtnEnabled.i
  bFontBold.i
  bBtnVisible.i
  bBtnMouseOver.i
  bPicture2Displayed.i
  ; gadget id's
  cvsToolBtn.i
EndStructure

;- tyToolBarColors
Structure tyToolBarColors
  bColorsLoaded.i
  nCntColor.l           ; container color
  nBtnColor.l           ; button color
  nBtnColorMouseOver.i  ; button color when mouse over (if button enabled)
  nBtnTextColor.l
  nBtnMoreEnRGBA.i
  nBtnMoreEnRGB.i
  nBtnMoreDiRGBA.i
  nBtnMoreDiRGB.i
  nCatColor.l           ; category color
  nCatColorMouseOver.i  ; category color when mouse over (if category enabled)
  nCatTextColor.l
  nCatMoreEnRGBA.i
  nCatMoreEnRGB.i
EndStructure

;- tyTRECT
Structure TRECT
  left.l
  top.l
  right.l
  bottom.l
EndStructure

;- tyPosAndSize
Structure tyPosAndSize
  nLeft.i
  nTop.i
  nWidth.i
  nHeight.i
EndStructure

;- tyImageLog
Structure tyImageLog
  nImageNo.i
  nImageId.i
  qCreated.q  ; time created
  qFreed.q    ; time freed
  nCallPointForCreate.i
  nCallPointForFree.i
  nAudPtr.i
  nVidPicTarget.i
  sComment.s
EndStructure

;- tyHandle
Structure tyHandle
  nHandle.i
  nHandleType.i
  sMnemonic.s
EndStructure

;- tyDMXIn
Structure tyDMXIn
  rDMX_In.Struct_RECV_DMX
  bDone.l
EndStructure

;- tyDMXCapture
Structure tyDMXCapture
  nCaptureNo.l
  qCaptureTime.q
  nCaptureLabel.a
  wCaptureBufferLength.w
  aCaptureBuffer.a[514]
EndStructure

;- tyDMXCaptureItem
Structure tyDMXCaptureItem
  qSortKey.q
  nItemSequence.i ; a session-unique number that identifies the sequence in which capture items were saved to the gaDMXCaptureItem() array
  qCaptureTime.q ; time of this DMX capture, as returned by the PB function ElapsedMilliseconds() when processing a 'Received Change Of State Packet (Label=9)' - see the document 'dmx_usb_pro_api_spec.pdf'
  nCaptureChannel.i ; DMX channel (1-512)
  nCaptureValue.i   ; DMX channel value (0-255)
  nCaptureElapsedTime.i ; elapsed time in milliseconds since the time of the first item captured for this sub-cue
  nCaptureElapsedTimeAdj.i ; elapsed time adjusted to the nearest 0.1 second
  nCaptureChannelTimeDelta.i ; difference in elpased times between this capture item and the previous capture item for this channel
  nCaptureChannelTimeDeltaAdj.i ; time difference adjusted to the nearest 0.1 second
  nCaptureTimeSlot.i
  sItemValue.s
  sItemFadeTime.s
  sItemData.s
  bUseThisItem.i
  bDeleteThisItem.i
EndStructure

;- tyDMX
Structure tyDMX
  ; sorted
  bBlackOutOnCloseDown.i
  bBlackOutWhenOpenDone.i
  bCallDisplayDMXSendData.i ; Added 24Jun2021 11.8.5an to process these calls from the main thread instead of from the DMX Send Thread (which was causing mutex locking issues)
  bDMXFirstTime.i ; Reinstated 16Feb2024 11.10.2ap
  bDMXInLocked.i
  bDMXReadyToSend.i
  bDMXTestWindowActive.i
  bDMXTestWindowFirstRead.i
  bLoadPreCueDMXValuesIfReqd.i
  bReceiveDMX.i
  bTooManyDMXMessages.i
  nDMXCueControlPtr.i
  nDMXInCount.i
  nMaxDMXControl.i
  nNumDMXDevs.i
  qTimeLastDMXReceiveRequested.q
  rPrevDMX.Struct_RECV_DMX
  sChannelErrorMsg.s
  ; DMX Capture info (used for DMX Capture if required when editing Lighting Cues)
  bCaptureComplete.i
  bCaptureDMX.i
  bDMXCaptureLimitWarningDisplayed.i
  bDMXCaptureSingleShot.i
  bDMXSaveCapture.i
  bRequestNextImmediately.i
  nDMXCaptureControlPtr.i
  nDMXCaptureLimit.i
  nDMXCaptureNo.i
  nMaxDMXCapture.i
  nMaxDMXCaptureItem.i
  qDMXCaptureStartTime.q
  qDMXCaptureStopTime.q
  ; qTimeLastPacket5Saved.q
  qTimeFirstPacket9Received.q
  qTimeLastDMXPacketForCaptureSaved.q
  ; Also for DMX Capture:
  Array nSubDMXDelayTime.i(0)
  nMaxSubDMXDelayTimeIndex.i
EndStructure

;- tyUSBPRO
Structure tyUSBPRO
  bInitialized.i
  FTDIDevCount.l    ; number of ftdi devices available
  myindex.l
  mymode.l          ; my mode DMX_OUTPUT (output) or RDM_OUTPUT (input)
  try_count.l
  ; other info
  rxbytes.l
  retbytes.l
  readbuf.s{768}
  timedout.a
  fatalerror.a
  totalbytesread.l
  bytesread.l
  txbytes.l
  EventDWord.l
EndStructure

;- WAVEHEADER_RIFF
Structure WAVEHEADER_RIFF
  RIFF.l                    ; "RIFF" = &H46464952
  riffBlockSize.l
  riffBlockType.l           ; "WAVE" = &H45564157
EndStructure

;-WAVEHEADER_DATA
Structure WAVEHEADER_DATA
  dataBlockType.l            ; "data" = &H61746164
  dataBlockSize.l
EndStructure

;- WAVE_FORMAT
; WAVE_FORMAT defined here because the PB native WAVEFORMATEX doesn't include wfBlockType and wfBlockSize
Structure WAVE_FORMAT
  wfBlockType.l             ; "fmt " = &H20746D66
  wfBlockSize.l
  wFormatTag.u
  nChannels.w
  nSampleRate.l
  nAvgBytesPerSec.l
  nBlockAlign.w
  wBitsPerSample.w
EndStructure

;- WAVE_CUEPOINT
Structure WAVE_CUEPOINT   ; used by analyzeWavFile()
  dwIdentifier.l
  dwPosition.l
  fccChunk.l
  dwChunkStart.l
  dwBlockStart.l
  dwSampleOffset.l
EndStructure

;- WAVE_LABEL
Structure WAVE_LABEL      ; used by analyzeWavFile()
  dwIdentifier.l
  dwText.s
EndStructure

;- WAVE_SAMPLER
Structure WAVE_SAMPLER   ; used by analyzeWavFile()
  dwManufacturer.l
  dwProduct.l
  dwSamplePeriod.l
  dwMIDIUnityNote.l
  dwMIDIPitchFraction.l
  dwSMPTEFormat.l
  dwSMPTEOffset.l
  dwNumSampleLoops.l
  dwSamplerDataBytes.l
EndStructure

;- WAVE_SAMPLER_DATA
Structure WAVE_SAMPLER_DATA ; used by analyzeWavFile()
  dwCuePointId.l
  dwType.l
  dwStart.l
  dwEnd.l
  dwFraction.l
  dwPlayCount.l
EndStructure

;- tyCueOrSubForMTC
Structure tyCueOrSubForMTC
  nMTCCuePtr.i
  nMTCSubPtr.i
  nMTCStartTimeForCueOrSub.l
  nMTCMaxStartTimeForCueOrSub.l
  ; nMTCMaxStartTimeForCueOrSub will be set to 1 second later than nMTCStartTimeForCue establishing a 1-second window of MTC time for triggering the cue.
  ; This is because an exact time code may not be received, especially as timecodes typically come at 2-frame intervals.
  qTimeCueOrSubLastStarted.q
  ; qTimeCueOrSubLastStarted is used to ensure we do not activate the cue more than once within the 1-second window described above.
EndStructure

;- tyMTCControl
Structure tyMTCControl
  nMidiPhysicalDevPtr.i
  sMidiInName.s
  sTxt.s
  bMTCControlActive.i
  nTimeCode.l
  nPrevTimeCodeProcessed.l
  Array aCueOrSubForMTC.tyCueOrSubForMTC(0)
  nMaxCueOrSubForMTC.i
  bTimeCodeStopped.i
  bStoppedDuringTest.i
  bClearPrevTimeCodeProcessed.i   ; added 29Oct2015 11.4.1.2e for testing resetting MTC (testing for Richard Borsey's request for looping stems)
EndStructure

;- tyMTCSendControl
Structure tyMTCSendControl
  bMTCSuspendThreadUntilFullFrameSent.i ; Added 3Jan2023 11.10.0ab following email from Ian Harding 12Dec2022 that showed some quarter-frame messages sent before the relevant full-frame message on starting a second MTC cue
  bMTCSendControlActive.i
  bMTCSendRefreshDisplay.i
  nMTCSubPtr.i
  nMTCType.i ; #SCS_MTC_TYPE_MTC or #SCS_MTC_TYPE_LTC
  nMTCLinkedToAudPtr.i
  nMTCLinkedAudChannel.l
  ; nMTCAudSyncPosToStartMTC.l
  bMTCSyncNextQtrFrameWithAud.i
  nMTCThreadRequest.i
  nMTCCuesPhysicalDevPtr.i
  bMTCCuesPortOpen.i
  hMTCMidiOut.i
  nMTCPreRoll.i ; delay after sending a full-frame, before sending quarter-frames
  nMTCStartTime.i
  qMTCStartTimeAsMicroseconds.q
  nMTCFrameRate.i   ; value in the enumeration #SCS_MTC_FR_...
  nMTCChannelNo.i
  dMTCMillisecondsPerFrame.d
  nMTCMillisecondsPerFrame.i    ; only used for 25fps (or potentially any other frame rate that gives an integer milliseconds per frame)
  nMTCFrameRateX100.i    ; frame rate x 100, eg frame rate 29.97 = 2997
  nMTCPieceDelayTime.i   ; delay required between sending successive quarter-frame messages, less 1ms (per piece) to ensure entire 8 pieces are sent WITHIN the time of two frames
  nMTCSendState.i
  qQPCTimeReady.q   ; time from QueryPerformanceCounter the full-frame message was sent
  qQPCTimeStarted.q ; time from QueryPerformanceCounter first quarter frame message sent
  qMinNextElapsedFrame.q
  nSMPTEType.l     ; SMPTE type (yy) shifted to 'OR' (|) into the 8th quarter-frame message
  nHours.i
  nMinutes.i
  nSeconds.i
  nFrames.i
  nMTCPanelIndex.i
  nRunningIndGadgetNo.i
  qLogQtrFramesStartTime.q
  bMTCEnttecMidi.i ; #True if to use the Enttec DMX USB PRO MK2 API
  ; the following only applicable if bEnttecMidi = #True
  nMTCFTHandle.i
EndStructure

;- tyQPCInfo (QueryPerformanceCounter info)
Structure tyQPCInfo
  bQPCInitDone.i
  bQPCAvailable.i
  sQPCInfo.s  ; saved for diagnostic file
  dQPCPeriodNanoSecs.d
  dQPCPeriodMilliseconds.d
  qQPCCallDelay.q
  qQPCFrequency.q
EndStructure

;- tyCueLabelInfo from fmLabelChange
Structure tyCueLabelInfo
  sOldCue.s
  sNewCue.s
  sCueType.s
  sCueDescr.s
  sPageNo.s
  sTmpCue.s
  sOldMidiCue.s
  bOldMidiIsDefault.i
  sNewMidiCue.s
  bChanged.i
  u2.i
EndStructure

;- tySubCueLabelInfo
Structure tySubCueLabelInfo
  bChanged.i
  u3.i
EndStructure

;- tyWMC for fmMultiCueCopyEtc
Structure tyWMC
  nActionReqd.i
  nArrayMax.i
  nSearchCC .i
  nSearchColumn.i
  bChangesViewed.i
  sAdded.s
  sCopied.s
  sMoved.s
  sDeleted.s
  sSortedAsc.s
  sSortedDec.s
  sSearch.s
  sTopOfShow.s
EndStructure

;- tyWPFUniqueFile
Structure tyWPFUniqueFile
  sOldFile.s
  sNewFile.s
EndStructure

;- tyWPF for fmCollectFiles
Structure tyWPF
  sHoldCueFolder.s
  sHoldCueFile.s
  sProdFolder.s
  sCueFile.s
  sColorFile.s
  sDevMapFile.s
  Array sFileName.s(1)
  Array bSameButDifferent.i(1)  ; will be set #True if GetFilePart() indicates the same file part as an entry already in the list and appears to be the same file
  Array bFilePartClash.i(1)     ; will be set #True if GetFilePart() indicates the same file part as an entry already in the list but is actually a different file
  nFileCount.i
  nFilesToBeCopied.i
  nFilesSameButDifferent.i
  nFilesToBeExcluded.i
  bCopyThreadRunning.i
  bCopyCancelRequested.i
  nExcludedLeft.i
  nExcludedTop.i
  nExcludedRight.i
  nExcludedBottom.i
  Array aUniqueFile.tyWPFUniqueFile(0)
  nMaxUniqueFile.i
  qDriveSpaceRequired.q
EndStructure

;- tyCueMoveEtcInfo
Structure tyCueMoveEtcInfo
  sCueSortKey.s
  nGrdAction.i
  nOldCuePtr.i
  nNewCuePtr.i
  sCue.s
  sPageNo.s
  sCueType.s
  sCueDescr.s
EndStructure

;- tySpecialStartInfo
Structure tySpecialStartInfo
  bDoNotOpenMRF.i   ; do not open most recent file
  bFactoryReset.i   ; factory reset
  bIgnoreWindows.i  ; ignore saved window positions
  bNoWASAPI.i       ; do not use WASAPI (Windows Audio Session API)
EndStructure

;- tyKnob
Structure tyKnob
  bKnobCreated.i
  nCanv.i
  nSize.i
  nMinValue.i
  nMaxValue.i
  nMidValue.i
  nValueRange.i
  nValue.i
  nXCenter.i
  nYCenter.i
  nRGB1.i
  nRGB2.i
  nLightRGB.i
  nBkRGB.i
  fAngle.f
  nInfo.i
  bMouseDown.i
  nKnobType.i
  nEQBand.i
  fMinDeadAngle.f
  fMaxDeadAngle.f
  fAngleRange.f
  fAnglePerUnit.f
  nNrOfMarks.i
  fAnglePerMark.f
EndStructure
;- Pointf
Structure Pointf
  X.f : Y.f
EndStructure

;- tyMasterLevel
Structure tyMasterLevel
  ; BV means 'BASS Volume' as used in BASS call values for #BASS_ATTRIB_VOL
  fProdMasterBVLevel.f                ; the master level as saved in Production Properties, or as adjusted from the Master Level slider in the main window
  fControllerFaderMasterBVLevel.f     ; the master level as set in the 'Show Faders' window (#WCN)
  bUseControllerFaderMasterBVLevel.i  ; if #True then calcReqdGain() will use \fControllerFaderMasterBVLevel, else it will use \fProdMasterBVLevel
  fVideoVolumeFactor.f
EndStructure

;- tyDMXMasterFader
Structure tyDMXMasterFader
  nDMXMasterFaderValue.i        ; nb DMX master fader values held as a percentage (0%-100%)
  nDMXMasterFaderResetValue.i
EndStructure

;- tyETCImport
Structure tyETCImport
  nControlFile.i
  Array sETCCue.s(0)          ; ETC cue number
  Array sLabel.s(0)           ; ETC cue description
  Array bNextCueEnabled.i(0)  ; will be set #True if 'follow' column is blank, else will be set #False
  nCueCount.i
EndStructure

;- tyvMixControl
Structure tyvMixControl
  bvMixInitDone.i
  ; vMix connection info
  sIPAddress.s
  nPortNo.i
  sAPIAddress.s
  nConnection.i
EndStructure

;- tyvMixInputInfo
Structure tyvMixInputInfo
  ; info obtained from vMix about a vMix 'Input'
  sName.s
  sKey.s
  nNumber.i
  sType.s
  sTitle.s
  sState.s
  nPosition.i
  nDuration.i
  sMuted.s
  nVolume.i
  nBalance.i
EndStructure

;- tyvMixInfo
Structure tyvMixInfo
  ; general info about the current vMix state and the 'Input' clips
  sLastCommandSent.s ; cleared after being processed
  qTimeLastCommandSent.q
  sVersion.s ; version of vMix, eg 23.0.0.41
  sEdition.s ; vMix edition, ie license level, eg Basic
  bBasicEdition.i ; #True if Basic or Basic HD edition
  bvMixEditionNotSupported.i
  nMaxInputNoForEdition.i ; eg 4 for Basic and Basic HD, otherwise 1000 (not sure about demo)
  nMaxOutputNoForEdition.i ; 1 for Basic, Basic HD, SD and HD, otherwise 4 (not sure about demo)
  Array aInputInfo.tyvMixInputInfo(0)
  nMaxInputInfo.i
  Array sInputKeyToRemoveWhenvMixIdle.s(0)
  nMaxInputKeyToRemoveWhenvMixIdle.i
  Array sIncomingMsg.s(0)
  nActiveInputNo.i
  nMaxIncomingMsg.i
  nNextClipNo.i
  nTransition1Duration.i
  sTransition1Effect.s
  sBlackColourKey.s
  bStartSettingsLoaded.i
  bStartSettingFullScreenOn.i
  bInputLimitReached.i ; will be set #True if a vMix AddInput command fails with a message containing the words "Input Limit"
EndStructure

;- tyAnalyzedFile
Structure tyAnalyzedFile
  sFileName.s
  nFirstCPIndex.i
  nLastCPIndex.i
EndStructure

;- tyLinkedAuds
Structure tyLinkedAuds
  nAudPtr.i
EndStructure

;- tyTVGAudioDev
Structure tyTVGAudioDev
  sVidAudLogicalDev.s
  nVideoAudioDevPtr.i
  nFirstMeterIndex.i
EndStructure

;- tyTVGControl
Structure tyTVGControl
  nMaxTVGIndex.i
  nTVGWorkControlIndex.i
  nNextTVGNo.i
  nCountTVGsPlaying.i   ; set by eventTVGOnPlayerStateChanged() and may include TVG's paused
  bTVGsPlaying.i        ; set by isTVGPlaying() and is #True ONLY if at least one control has the 'playing' state, so a 'paused' control is regarded as not playing
  bCloseTVGsWaiting.i
  qTimeOfLastIsPlayingCheck.q
  Array nFadeAudPtr.i(0)
  nFadeAudCount.i
  nDirectShowFiltersCount.l
  sDirectShowFilters.s
  nDisplayMonitor.l       ; added 10Jan2017 11.5.3
  bFFDSHOWInstalled.i     ; added 11Jan2017 11.5.3
  bLAVFiltersInstalled.i  ; added 11Jan2017 11.5.3
  qLastPollTime.q
  Array aAudioDev.tyTVGAudioDev(0)
  nMaxAudioDev.i
  bDisplayVUMeters.i ; session-level setting
EndStructure

;- tyTVG
Structure tyTVG
  bAssigned.i
  nTVGAudPtr.i
  nTVGSubPtr.i
  nTVGVidPicTarget.i
  nTVGVideoSource.i
  bProdTestVidCap.i
  bDualDisplayActive.i
  bSetMainDisplayLocationDone.i
  bSetMonitorDisplayLocationDone.i
  bSetPreviewDisplayLocationDone.i
  nMainWindowNo.i
  nMonitorWindowNo.i
  nOutputScreen.i
  nOutputWindowNo.i
  bStillImage.i
  nZOrder.i
  bTopMostWindowForTarget.i
  nChannel.i
  nLastOnPlayerStateChange.i
  bClosePlayerRequested.i
  nMainRelLeft.i
  nMainRelTop.i
  nMainRelWidth.i
  nMainRelHeight.i
  bCloseWhenTVGNotPlaying.i
  Array bDisplayIndexUsed.i(8)
  Array nWindowForDisplayIndex.i(8)
  nWorkMonitorleft.l
  nWorkMonitorTop.l
EndStructure

;- tySldLvlPt
Structure tySldLvlPt
  nLevelPointIndex.i
  nItemIndex.i
  nLvlPtX.i
  nLvlPtY.i
  nPanPtX.i
  nPanPtY.i
EndStructure

;- tySldCustom
Structure tySldCustom
  nCustomLinePos.i
  nCustomLineType.i ; see enumeration #SCS_SLD_CLT_...
  nCustomDBLevel.i  ; integer only (eg +10, -15, or -999 for -INF)
  fCustomBVLevel.f  ; BASS Volume equivalent
EndStructure

;- tyFaderInfo
Structure tyFaderInfo
  fFdrDBHeadroom.f            ; headroom in dB
  ; section A
  fFdrSecADBBase.f            ; lowest dB level for section A
  fFdrSecADBInterval.f        ; dB interval between major marks in section A
  fFdrSecADBRange.f           ; dB range of section A
  fFdrSecACellSize.f          ; relative distance between major marks in section A, based on gfFdrOverallSize
  fFdrSecABaseValue.f         ; slider value for lowest level in section A
  fFdrSecA1DBValue.f          ; value of 1dB in section A, relative to sliders; max value, which is 1000
  fFdrSecADBLevel.f
  ; section B
  fFdrSecBDBBase.f            ; lowest dB level for section B
  fFdrSecBDBInterval.f        ; dB interval between major marks in section B
  fFdrSecBDBRange.f           ; dB range of section B
  fFdrSecBCellSize.f          ; relative distance between major marks in section B, based on gfFdrOverallSize
  fFdrSecBBaseValue.f         ; slider value for lowest level in section B
  fFdrSecB1DBValue.f          ; value of 1dB in section B
  fFdrSecBDBFactor.f
  fFdrSecBDBLevel.f
  ; section C
  fFdrSecCDBBase.f            ; lowest dB level for section C
  fFdrSecCDBInterval.f        ; dB interval between major marks in section C
  fFdrSecCDBRange.f           ; dB range of section C
  fFdrSecCCellSize.f          ; relative distance between major marks in section C, based on gfFdrOverallSize
  fFdrSecCBaseValue.f         ; slider value for lowest level in section C
  fFdrSecC1DBValue.f          ; value of 1dB in section C
  fFdrSecCDBFactor.f
  fFdrSecCDBLevel.f
EndStructure

;- tySlider
Structure tySlider
  bInUse.i                        ; #True if this slider has been created by SLD_New
  sName.s                         ; name of slider (mainly for debug messages)
  bInitialized.i
  ; Gadget ID's
  cvsSlider.i
  ; fonts
  fontLabels.i
  fontInfinity.i
  ; type of slider
  nSliderType.i
  nSliderToolTipType.i
  bLevelSlider.i  ; set #True for slider types #SCS_ST_HLEVELRUN, #SCS_ST_HLEVELNODB, #SCS_ST_VFADER_LIVE_INPUT, #SCS_ST_VFADER_OUTPUT, #SCS_ST_VFADER_MASTER
  bFader.i        ; set #True for slider types #SCS_ST_VFADER_LIVE_INPUT, #SCS_ST_VFADER_OUTPUT, #SCS_ST_VFADER_MASTER
  bAudioGraph.i
  nRemDevMsgType.i ; CSRD remote device message type (internal code) if slider type = #SCS_ST_REMDEV_FADER_LEVEL, otherwise 0 (zero)
  ; size and position
  nCanvasWidth.i       ; width of container gadget
  nCanvasHeight.i      ; height of container gadger
  nCanvasHalfWidth.i   ; half width of container gadget
  nCanvasHalfHeight.i  ; half height of container gadget
  nCanvasX.i           ; window X position of container gadget left
  nCanvasY.i           ; window Y position of container gadget top
  nLblHeight.i
  nLblLeftWidth.i
  nLblRightWidth.i
  nLblLeftX.i
  nLblRightX.i
  nLblLeftY.i
  nLblRightY.i
  nLblTopWidth.i
  nLblBottomWidth.i
  nLblTopHeight.i
  nLblBottomHeight.i
  nLblTopY.i
  nLblBottomY.i
  bUseMainScaling.i
  bUseCuePanelScaling.i
  bContinuous.i
  bHorizontal.i
  nButtonStyle.i
  nKnobIndex.i
  ; other
  btnColor1.i
  btnColor2.i
  btnHght.i
  btnWdth.i
  sldNumDiv.i
  sLeftText.s
  sRightText.s
  sTopText.s
  sBottomText.s
  sCaptionText.s
  fCurrPos.f
  bCurrMove.i
  nBasePointerX1.i
  nBasePointerX2.i
  nCurrPointerX1.i
  nCurrPointerX2.i
  nBasePointerY1.i
  nBasePointerY2.i
  nCurrPointerY1.i
  nCurrPointerY2.i
  bBasePointerSelected.i
  nCurrPointerClickOffset.i   ; when the current pointer is clicked this will be set to the number of pixels offset from the centre of the pointer
  nLblFontId.i
  bUseInfinityFont.i
  ; fader fields
  nTrackX1.i
  nTrackY1.i
  nTrackY2.i
  nTrackHeight.i
  nTrackExtra.i
  nImageNo.i
  nImageLeft.i
  nImageWidth.i
  nImageHeight.i
  nImageCentreOffset.i
  nMarkerX1.i
  nMarkerX2.i
  ; extra fields
  sldUseBase.i
  fBasePos.f
  btnBaseColor.l
  nEventWindowNo.i
  ; level point fields
  nMaxArrayIndex.i
  nFromDev.i
  nUpToDev.i
  Array aSldLvlPt.tySldLvlPt(0)
  ; derived fields (derived in SLD_drawSlider)
  fMarkWidth.f         ; used for progress sliders, pan sliders, etc, but not level sliders
  btnHalfHght.i
  btnHalfWdth.i
  nFaderMarkSize.i[#SCS_SLD_MAX_MARKS]
  nFaderMarks.i[#SCS_SLD_MAX_MARKS]
  CompilerIf #c_slider_mark_section_colors
    nMarkColors.i[#SCS_SLD_MAX_MARKS]
  CompilerEndIf
  nGtrDistanceLeft.i
  nGtrDistanceRight.i
  nGtrLength.i
  nGtrDistanceTop.i
  nGtrDistanceBottom.i
  nGtrX1.i
  nGtrX2.i
  nGtrY1.i
  nGtrY2.i
  nPointerMinX.i  ; range of mouse X values recognised
  nPointerMaxX.i  ; as operating on the slider pointer (for horizontal sliders)
  nPointerMinY.i  ; range of mouse Y values recognised
  nPointerMaxY.i  ; as operating on the slider pointer (for vertical sliders)
  fUnitSize.f     ; width (horizontal sliders) or height (vertical sliders) of 1 unit of the slider, ie nPhysicalRange / (sldMaxVal - m_Min)
  Array aSldCustom.tySldCustom(0)
  nMaxSldCustom.i
  nSldCustomLinePos.i
  ; Other variables
  nPhysicalRange.i
  nLogicalRange.i
  bMouseDown.i
  bDrawingStarted.i
  nMouseXOffset.i
  nMouseYOffset.i
  nMinPos.i
  nMaxPos.i
  nPrevMouseX.i
  nPrevMouseY.i
  nCuePanelNo.i
  nDevNo.i
  nControlKeyAction.i
  ; audio graph fields
  bLoadFileRequest.i
  nLoadFileRequestCount.i
  nSldFileDataPtr.i
  nAudioGraphImageNo.i
  nAudioGraphImageNoPlay.i    ; optional version of audio graph for a playing file
  nAudioGraphWidth.i
  nAudioGraphHeight.i
  nAudioGraphAudPtr.i         ; nAudPtr used when creating this audio graph image
  nAudioGraphFileDuration.i   ; aAud()\nFileDuration used when creating this audio graph image
  nAudioGraphFileChannels.i   ; aAud()\nFileChannels used when creating this audio graph image
  nAudioGraphAbsMin.i         ; aAud()\nAbsMin used when creating this audio graph image
  nAudioGraphAbsMax.i         ; aAud()\nAbsMax used when creating this audio graph image
  bAudioGraphImageReady.i
  bRedrawSldAfterLoad.i
  bRedrawThisSld.i
  bReloadThisSld.i
  nTickColor.l
  ; Cue Marker Flag
  bCueMarkers.b
  ; Property Variables:
  m_Value.i
  m_BaseValue.i
  m_BVLevel.f         ; only used for sliders with \bLevelSlider = #True
  m_BaseBVLevel.f     ; ditto
  m_BackColor.l
  m_GtrAreaBackColor.l
  m_Enabled.i
  m_Min.i
  m_Max.i
  m_LineCount.i
  Array m_LinePos.i(#SCS_SLD_MAX_LINES)   ; array size may be increased in SLD_setLinePos()
  Array m_LineType.i(#SCS_SLD_MAX_LINES)  ; array size may be increased in SLD_setLinePos()
  m_TrimFactor.f
  m_BaseTrimFactor.f
  m_XFactor.f
  m_YFactor.f
  m_KeyFactorS.f  ; factor for small increments
  m_KeyFactorL.f  ; factor for large increments
  m_AudPtr.i
  ; scrollbar fields
  m_PageLength.i
EndStructure

;- tyRAI
Structure tyRAI
  bRAIClientActive.i
  bRAIAvailable.i
  bRAIInitialized.i
  nServerPort.i
  nServerConnection1.i  ; main connection from the remote app, that the remote app will use to send commands to SCS (by default this server connection uses port 58000)
  nServerConnection2.i  ; connection that will be used to send SCS-initiated messages to the remote app, eg GETSTATE (by default this server connection uses port 58001)
  nServerConnection3.i  ; connection that will be used to send SCS-initiated progress messages to the remote app (by default this server connection uses port 58002)
  nClientConnection1.i
  nClientConnection2.i
  nClientConnection3.i
  sClientIP.s
  nClientPort.i
  nNetworkControlPtr1.i
  nNetworkControlPtr2.i
  nNetworkControlPtr3.i
  nStatus.i
  bNewCueFile.i   ; this item may not be necessary but is included for 'safety' to prevent SCS sending unsolicited messages to the app before loading the cue file is complete
  nSendSetPosCount.i
EndStructure

;- tyFMBackup
Structure tyFMBackup
  nNetworkControlPtr.i
  nBackupId.i
EndStructure

;- DMX PRO Structures
; derived from "ENTTEC\pro_example_v2\EXAMPLE\pro_driver.h"
Structure DMXUSBPROParamsType
  FirmwareLSB.a
  FirmwareMSB.a
  BreakTime.a
  MaBTime.a
  RefreshRate.a
EndStructure

Structure DMXUSBPROSetParamsType
  UserSizeLSB.a
  UserSizeMSB.a
  BreakTime.a
  MaBTime.a
  RefreshRate.a
EndStructure

Structure ReceivedDmxCosStruct
  start_changed_byte_number.a
  changed_byte_array.a[5]
  changed_byte_data.a[40]
EndStructure

;- tyCueCtrlData
Structure tyCueCtrlData
  sMessage.s
  sNetworkCue.s
  sAction.s
  sCommand.s
  sExpString.s
  sExpectedCue.s
  txt.s
  txt2.s
EndStructure

;- tyCueBracket
; A 'cue bracket' starts with a cue that is manually started, including external activation,
; and includes any subsequent cues that are auto-started from this cue or from an earlier cue in this bracket,
; ending with the last such cue before then next manual start cue.
; This structure and the associated global array was created to assist in preventing cues being opened when any cue in a bracket is
; currently playing, except for other cues within the same bracket.
; Feature added 23May2018 11.7.1aq to address performance issue raised by Kevin Washburn.
; Note that cue brackets are currently only used in conjunction with 'preload only the next manual cue' 
Structure tyCueBracket
  nBracketFirstCue.i
  nBracketLastCue.i
EndStructure

;- tyConnectedDev
Structure tyConnectedDev
  nDevType.i
  nDriver.i
  sPhysicalDevDesc.s
  nDevice.l ; id or no. for this device for this driver, eg equivalent of what was previously nBassDevice, nBassASIODevice, nFTDeviceNo, etc ('long' because long required by the respective libraries)
  bInitialized.i
  bDummy.i
  bIgnoreDev.i
  sSortKey.s
  
  ; audio output and live input device info (live input requires SM-S)
  nBassInitFlags.l      ; used by BASS DS and BASS ASIO
  nBassInitErrorCode.l
  nInterfaceNo.i        ; SM-S only
  bDefaultDev.i
  bNoDevice.i
  bNoSoundDevice.i
  nSpeakers.i           ; BASS DS only
  nInputs.i             ; SM-S only
  nOutputs.i            ; all audio drivers
  nAsioBufLen.i         ; BASS ASIO only
  dAsioSampleRate.d     ; BASS ASIO only
  nDefaultSampleRate.i  ; SM-S only
  bAssignedToASIOGroup.i
  nFirst0BasedOutputChanAG.i
  nFirst0BasedInputChanAG.i
  
  ; video audio device info
  bMuteVideoAudio.i
  
  ; video capture device info
  nSubtypesCount.l
  nSizesCount.l
  nFormatsCount.l
  sSubtypes.s
  sSizes.s
  sFormats.s
  sFormatsSorted.s
  
  ; midi in/out device info
  nMidiDeviceID.l ; long as required by functions such as midiOutOpen_()
  bWindowsMidiCompatible.i  ; #True if device may be handled by Windows MIDI functions, such as midiInOpen(), midiOutOpen() etc.
                            ; #False for other devices, such as the Enttec DMX USB PRO MK2
  bEnttecMidi.i             ; #True if to use the Enttec DMX USB PRO MK2 API
  
  ; dmx device info
  ; nFTDeviceNo.l   ; nFTDeviceNo as required for functions such as FT_Open (see D2XX Programmers' Guide)
  nDMXDevType.i
  nDMXPorts.i
  ; info on serial numbers, supplied by ENTTEC support:
  ; ===================================================
  ; There are indeed two different serial numbers.
  ;
  ; The numeric one is stored inside the PRO Mk2 firmware, and is only available on GET_WIDGET_SN
  ; This is the number you should be using to display
  ;
  ; The alphanumeric number is used to identify it as a unique FTDI device (that's what the FTDI driver requires)
  ; This number should be used internally to handle the device uniquely
  ; This one is a random unique identifier provided by FTDI with a prefix "EN" - for ENTTEC
  sSerial.s
  nSerial.l
  
  ; rs232 port info
EndStructure

;- tyOutput
Structure tyOutput
  sDesc.s
  sSpeaker.s
  nSpeakersFlag.l
  nChans.i
  bIgnoreSpkrArrangement.i
  nFirstASIOChannel.l                   ; used for ASIO channel enable and for SM-S
EndStructure

Structure tyAggregateItems
  nCuesWithAudioFileSubCues.i
  nCuesWithAudioFileAndOrVideoImageSubCues.i
  nCuesWithAudioFileAndOrVideoImageAndOrPlaylistSubCues.i
EndStructure

Structure tyAggregateTimes
  rProdAggregate.tyAggregateItems
  rNonCompleteAggregate.tyAggregateItems
EndStructure

Structure tyRegKeyFile
  qCFDate.q
  sRegKeyFolder.s
  sRegKeyFile.s
  sRegKey.s
EndStructure

Structure tyLightingCueClipboard
  rChaseStep.tyLTChaseStep
  nMaxFixture.i
  Array aLTSubFixture.tyLTSubFixture(0)
EndStructure

;- tyWMI
Structure tyWMI
  bFormActive.i
  nMinDisplayTime.i
  qTimeDisplayed.q
EndStructure

;- tyM2TItem (Move to Time item)
Structure tyM2TItem
  nDispPanel.i
  nControllingCuePtr.i
  ; this cue
  nThisCuePtr.i
  nThisCueStartTime.i
  nThisCueLength.i
  nOrigCueState.i
  nReqdCueState.i
  nReqdCuePos.i
  ; this sub
  bFirstSubForCue.i
  nThisSubPtr.i
  nThisSubStartTime.i
  nThisSubLength.i
  sThisSubType.s
  nOrigSubState.i
  nReqdSubState.i
  nReqdSubPos.i
  ; this aud
  nThisAudPtr.i
  nThisAudStartTime.i
  nThisAudLength.i
  nOrigAudState.i
  nReqdAudState.i
  nReqdAudPos.i
  nReqdRelFilePos.i
EndStructure

;- tyM2T (Move to Time)
Structure tyM2T
  nM2TPrimaryCuePtr.i
  nM2TPrimarySubPtr.i ; will be first sub in cue
  nM2TPrimaryAudPtr.i ; will be first aud in sub
  nM2TPrimaryCueLength.i
  nM2TTotalLength.i
  Array aM2TItem.tyM2TItem(0)
  nM2TMaxItem.i
  nMoveToTime.i
  bProcessingApplyMoveToTime.i
  bM2TCueListColoringReqd.i
  bM2TCueListColoringApplied.i
  sM2TErrorMsg.s
EndStructure

;- tyMixer
Structure tyMixer
  nCtrlMidiRemoteDev.i
  nCtrlMidiChannel.i
  nMaxChannel.i
  nMaxDCA.i
  nMaxMuteGrp.i
  nMaxScene.i
  Array bChannelSelected.i(0)
  Array bDCASelected.i(0)
  Array bMuteGrpSelected.i(0)
EndStructure

;- tyCSRD_LangItem (CSRD = Ctrl Send Remote Device)
Structure tyCSRD_LangItem
  sCSRD_LangGrp.s
  sCSRD_LangItem.s
  sCSRD_LangText.s
  sCSRD_LangShort.s
  bCSRD_ValSS.i ; #True if this LangGrp 'Val' item may be used in scribble strips
EndStructure

;- tyCSRD_RemDev
Structure tyCSRD_RemDev
  nCSRD_RemDevId.i
  nCSRD_DevType.i
  sCSRD_DevCode.s
  sCSRD_DevLang.s
  sCSRD_DevName.s ; (derived from LangItem array from DevCode)
  nCSRD_DfltMIDIChan.i ; 0 if not set
  bCSRD_RemDevUsedInProd.i ; #True if this remote device (type), eg AH_Qu, is used in this production
EndStructure

;- tyCSRD_ValidValue
Structure tyCSRD_ValidValue
  nCSRD_RemDevId.i
  sCSRD_ValType.s
  sCSRD_ValLang.s
  sCSRD_ValData.s
  sCSRD_ValDataNum.s ; (derived) as ValData but converted to numeric-only, eg ValData "(1-32),ST1,ST2,ST3" is stored in ValDataNum as "1-32,33,34,35"
  nCSRD_ValWidth.i   ; 0 if not set
  nCSRD_ValBase.i    ; default base = 1
  Array sValDataValue.s(0)
  nCSRD_MaxValDataValue.i ; ie max array index
  sCSRD_ValDataCodes.s    ; Added 2Sep2022 11.9.5.1ab
EndStructure

;- tyCSRD_FaderValue
Structure tyCSRD_FaderValue
  fCSRD_FdrLevel_dB.f ; dB level (-999 = -INF)
  nCSRD_FdrLevel_Byte1.a
  nCSRD_FdrLevel_Byte2.a
EndStructure

;- tyCSRD_FaderData
Structure tyCSRD_FaderData
  nCSRD_RemDevId.i
  sCSRD_FdrType.s
  sCSRD_FdrLang.s
  nCSRD_FdrBytes.i
  sCSRD_FdrValFormat.s ; "D1" for single-value decimal (eg 1023), "D2" for two-value decimal (eg 127.112). If blank then assume single or two-value hexadecimal (eg 7H or 7F.40)
  sCSRD_FdrData.s
  Array aFdrValue.tyCSRD_FaderValue(0)
  nCSRD_MaxFaderValue.i ; ie max array index
EndStructure

;- tyCSRD_RemDevMsgData (message data for a remote device)
Structure tyCSRD_RemDevMsgData
  nCSRD_RemDevId.i
  sCSRD_RemDevMsgType.s
  nCSRD_RemDevMsgType.i ; will be greater than #SCS_MSGTYPE_DUMMY_LAST
  sCSRD_MsgLang.s
  sCSRD_MsgDesc.s ; (derived from LangItem array from MsgLang)
  sCSRD_MsgShortDesc.s
  sCSRD_ValType.s
  sCSRD_ValDesc.s ; value description (derived from LangItem array from ValType's ValLang)
  bCSRD_ValSS.i   ; #True if this ValDesc may be used in scribble strips (derived from LangItem array from ValType's ValLang)
  sCSRD_ValData.s ; (derived)
  sCSRD_ValDataNum.s ; (derived) as ValData but converted to numeric-only, eg ValData "(1-32),ST1,ST2,ST3" is stored in ValDataNum as "1-32,33,34,35"
  nCSRD_ValWidth.i   ; (derived) 0 if not set
  nCSRD_ValBase.i    ; (derived) default base = 1
  Array sValDataValue.s(0) ; (derived)
  nCSRD_MaxValDataValue.i ; (derived) max array index
  sCSRD_ValDataCodes.s ; Added 3Sep2022
  sCSRD_FdrType.s
  sCSRD_FdrDesc.s ; fader description (derived from LangItem array from FdrType's FdrLang)
  sCSRD_FdrData.s ; (derived)
  nCSRD_FdrBytes.i ; (derived)
  Array aFdrValue.tyCSRD_FaderValue(0) ; (derived)
  nCSRD_MaxFaderValue.i ; (derived) max array index
  nCSRD_SelectionType.i ; see constants #SCS_SELTYPE_... (CSRD Message Value Selection Types)
  sCSRD_MsgData.s
  sCSRD_ValType2.s
  sCSRD_ValDesc2.s ; value description (derived from LangItem array from ValType2's ValLang)
  bCSRD_ValSS2.i   ; #True if this ValDesc may be used in scribble strips (derived from LangItem array from ValType's ValLang)
  sCSRD_ValData2.s
  sCSRD_ValDataNum2.s ; (derived) as ValData2 but converted to numeric-only, eg ValData2 "(FX1-FX4)" is stored in ValDataNum2 as "1-4"
  nCSRD_ValWidth2.i   ; 0 if not set
  nCSRD_ValBase2.i    ; default base = 1
  Array sValDataValue2.s(0)
  nCSRD_MaxValDataValue2.i ; ie max array index
  sCSRD_ValDataCodes2.s    ; Added 3Sep2022
  sCSRD_SkipParamValues.s
  sCSRD_OSCCmdType.s
  nCSRD_OSCCmdType.i ; derived using encodeOSCCmdType(sCSRD_OSCCmdType), 0 if not set
EndStructure

;- tyCSRD (Ctrl Send Remote Device)
Structure tyCSRD
  nCSRDLastUpdated.i
  Array aLangItem.tyCSRD_LangItem(0)
  Array aRemDev.tyCSRD_RemDev(0)
  Array aValidValue.tyCSRD_ValidValue(0)
  Array aFaderData.tyCSRD_FaderData(0)
  Array aRemDevMsgData.tyCSRD_RemDevMsgData(0)
  nMaxLangItem.i
  nMaxRemDev.i
  nMaxValidValue.i
  nMaxFaderData.i
  nMaxRemDevMsgData.i
  bLogCSRDArray.i
  ; temporary (working) info:
  Array bDataValueSelected.i(0)
  nMaxDataValueIndex.i
  Array bDataValueSelected2.i(0)
  nMaxDataValueIndex2.i
  bRemDisplayInfoUsingItemName.i
EndStructure

;- tyTempoEtc
Structure tyTempoEtc
  nAudTempoEtcCurrAction.i
  nTempoEtcCurrChangeCode.i
  fTempoEtcOrigValue.f
  fTempoEtcCurrValue.f
  fTempoEtcMinValue.f
  fTempoEtcMaxValue.f
  fTempoEtcDefaultValue.f
  nTempoEtcDecimals.i
  fTempoEtcFactor.f
  nTempoEtcCurrSliderValue.i
  nTempoEtcDefaultSliderValue.i
  bDontTellMeAgainAboutPlaybackRateChangeOnly.i
EndStructure

;- tyAnimImageCanvas (animated image canvas)
Structure tyAnimImageCanvas
  nCanvasNo.i
  nLeft.i
  nTop.i
  nWidth.i
  nHeight.i
EndStructure

;- tyAnimImageTargetImage (animated image target image)
Structure tyAnimTargetImage
  nTargetImageNo.i
  nLeft.i
  nTop.i
  nWidth.i
  nHeight.i
EndStructure

;- tyAnimImage (animated image)
Structure tyAnimImage
  nImageAudPtr.i
  nWindowTimer.i
  nImageNo.i
  fImageAspectRatio.f
  nImageFrameCount.i
  nImageCurrentFrame.i
  nVidPicTarget.i
  nMaxImageCanvas.i
  Array aImageCanvas.tyAnimImageCanvas(0)
  nMaxTargetImage.i
  Array aTargetImage.tyAnimTargetImage(0)
EndStructure

;- tyCueFileItemCounts
Structure tyCueFileItemCounts
  bProcessingHead.i
  nCountAudioLogicalDevs.i
  nCountVidAudLogicalDevs.i
  nCountVidCapLogicalDevs.i
  nCountFixTypes.i
  nCountLightingLogicalDevs.i
  nCountCtrlSendLogicalDevs.i
  nCountCueCtrlLogicalDevs.i
  nCountLiveInputLogicalDevs.i
  nCountInGrps.i
  nCountCues.i
  nCountSubs.i
  nCountAuds.i
EndStructure

Structure tySaveSetting
  nSSSubPtr.i
  nSSMaxDev.i
  nSSDevIndex.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSSBVLevel.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  fSSPan.f[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
EndStructure

; Artnet structures
Structure artnetTimers_t
  qThisTime.q
  qLastTime.q
  qInterval.q
  qStoredInterval.q
  *pFunction
  nCount.i
  nActive.i
  sTimerName.s
  hClient.i
EndStructure

Structure artnetDmxData_t
  aDmxData.a[#ARTNET_DMX_OUT_SIZE]                           ; 18 bytes header + 512 data
  nReady.i
  cUniverseIndex.c
EndStructure

Structure artnetPollreplies_t
  sArtnetClientId.s
  sArtnetId.s
  cArtnetOpcode.c
  cArtnetProtVer.c
  qArrived.q
EndStructure

Structure artnetRxBuffers_t
  qTimestamp.q
  aDmxDataArray.a[#ARTNET_BUFFER_SIZE]
EndStructure

; SCS_LTC structures

Structure scsLTCUserData
  sGeneratorname.s      ; Name to search for
EndStructure

Structure scsLTCCommandData_t
  sScsLTCCommands.s      ; Commands sent from Timecode.pbi
EndStructure

Structure scsLTCTDevice_t
  ;buf_AudioBuffer.b[#LTC_AUDIO_BUFFER_SIZE]  ; array of signed bytes for the audio buffer.
  *pLTCXxcoder.LTCEncoder                     ; Handle to the encode / decoder instance, in reality a dynamic memory pointer
  *pAudioBuffer         ; pointer to the audio buffer
  nAudioBufferSize.i    ; size of audio buffer in case we need to re-Dim it
  sLTCName.s            ; p1000, px1001
  sTimecodeStart.s      ; 01:02:03:04 Note: last digit is frames not miliseconds
  sType.s               ; timecode type, Default: #LTC_TV_525_60 ; 30fps
  nType.i               ; values of timecode type to match enumeration
  dFramerate.d          ; real world framerate.d
  nAudioLevel.f         ; Default for LTC is 0dB
  nStatus.i             ; Default: #SCS_LTC_COMMAND_STOP
  sCue.s                ; Cue name, mostly for debugging
  hBassStream.l         ; the BASS stream handle
  hBassMixer.l          ; the BASS mixer handle
  hBassSource.l         ; the BASS source handle
  nBassAudioDevice.l    ; grProd\aAudioLogicalDevs(nLoop)\nPhysicalDevPtr
  nBassASIODevice.l     ; gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\nDevice
  nloop.i
  nBassAudioDevType.i   ; grProd\aAudioLogicalDevs(nLoop)\nDevId, directsound, asio, sms flag
  nBassChannelPan.i     ; 0 = none (mute) , 1 = L, 2 = R, 3 = L+R
  sBassChannelName.s    ; The name of the BASS audio device
  nLTCbufferIndex.i     ; pointer to current position in the *audiopuffer
  qTimeSaved.q          ; Time used to update the display whilst playing.
EndStructure

Structure SMPTETimecode 
	timezone.a[6]         ; the timezone 6bytes: "+HHMM" textual representation
	years.a               ; LTC-date uses 2-digit year 00.99
	months.a              ; valid months are 1..12
	days.a                ; day of month 1..31
	hours.a               ; hour 0..23
	mins.a                ; minute 0..60
	secs.a                ; second 0..60
	dfbit.a               ; dfbit either . or :
	frame.a               ; sub-second frame 0..(FPS - 1)
	reverse.a             ; either "R" : "F"
	dummy.a
	off_start.q           ; offset start frame
	off_end.q             ; offset end frame
EndStructure            ; 6 + 10 + 8 + 8 = 32

Structure LTCFrameExternal
	LTCFrame.a[5]         ; the actual LTC frame. LTCFrame 80 bits or 5 bytes
	off_start.q           ; anchor off_start the approximate sample in the stream corresponding to the start of the LTC frame.
	off_end.q             ; anchor off_end the sample in the stream corresponding to the end of the LTC frame.
	reverse.i             ; if non-zero, a reverse played LTC frame was detected. Since the frame was reversed, it started at off_end and finishes as off_start (off_end > off_start). (Note: in reverse playback the (reversed) sync-word of the next/previous frame is detected, this offset is corrected).
	biphase_tics.f[80]    ; detailed timing info: phase of the LTC signal; the time between each bit in the LTC-frame in audio-frames. Summing all 80 values in the array will yield audio-frames/LTC-frame = (\ref off_end - \ref off_start + 1).
	sample_min.a          ; the minimum input sample signal for this frame (0..255)
	sample_max.a          ; the maximum input sample signal for this frame (0..255)
	volume.d              ; the volume of the input signal in dbFS
EndStructure            ; 5 + 8 + 8 + 8 + (80 * 8) + 1 + 1 + 8 = 679

Structure audioBuffer
  audioByte.a[#LTC_AUDIO_BUFFER_SIZE]
EndStructure

Structure LTCFrame
  bitfield.a[10]                    ; no equivelent to bit fields in PB so just dim a block the correct size (80 bits) as we do not manipulate
EndStructure

Structure LTCDecoder
	*queue.LTCFrameExternal           ;
	queue_len.i                       ;
	queue_read_off.i                  ;
	queue_write_off.i                 ;

	biphase_state.a                   ;
	biphase_prev.a                    ;
	snd_to_biphase_state.a            ;
	snd_to_biphase_cnt.i              ; counts the samples in the current period
	snd_to_biphase_lmt.i              ; specifies when a state-change is considered biphase-clock or 2*biphase-clock
	snd_to_biphase_period.d           ; track length of a period - used to set snd_to_biphase_lmt

	snd_to_biphase_min.a              ;
	snd_to_biphase_max.a              ;

	decoder_sync_word.u               ;
	ltc_frame.LTCFrame                ;
	bit_cnt.i                         ;

	frame_start_off.q                 ;
	frame_start_prev.q                ;
  
	biphase_tics.f[#LTC_FRAME_BIT_COUNT]      ;
	biphase_tic.i                             ;
EndStructure                        ; 679 + 8 + 8 + 8 + 3 + 16 + 8 + 2 + 2 + 10 + 8 + 8 + 8 + 8 + 8 + 360 = 1144

Structure LTCEncoder
  fps.d
  sample_rate.d
  filter_const.d
  flags.i
  standard.i ; Assuming LTC_TV_STANDARD is an integer enum
  enc_lo.l
  enc_hi.l
  offset.q
  bufsize.q
  buf.l ; Pointer to ltcsnd_sample_t (assuming it's a long)
  state.b
  samples_per_clock.d
  samples_per_clock_2.d
  sample_remainder.d
  f.LTCFrame 
EndStructure                        ; 8 + 8 + 8 + 8 + 8 + 4 + 4 + 8 + 8 + 4 + 1 + 8 + 8 + 10 = 95

; EOF