; File: fmOptions.pbi

EnableExplicit

Procedure WOP_applyChanges()
  PROCNAMEC()
  Protected n
  Protected sMsg.s
  Protected bUseBASSMixerChanged
  Protected bAsioSettingChanged
  Protected bWASAPIChanged
  Protected bVideoDriverChanged, bPlayerHwAccelChanged
  Protected bSMSControlChanged
  Protected bAudioDriverChanged
  Protected bSwapMonitorsChanged
  Protected bCallSetMidiEtcDisabledLabel
  Protected bLangCodeChanged
  Protected bDfltFontChanged
  Protected bCallSetWindows
  Protected bShowToolTipsChanged
  Protected bSplitScreenChanged
  Protected bRAIChanged
  Protected nPrevMonitorSize, bMonitorSizeChanged
  Protected bPrevAllowDisplayTimeout, bAllowDisplayTimeoutChanged
  Protected bPrevShowMidiCueInCuePanels, bShowMidiCueInCuePanelsChanged
  Protected bPrevLimitMovementOfMainWindowSplitterBar, bLimitMovementOfMainWindowSplitterBarChanged
  Protected bFMNetworkSettingsChanged, bFMOptionsChanged
  Protected bOperModeChanged
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected sResult.s

  debugMsg(sProcName, #SCS_START)
  
  grWOP\mbReloadGrid = #False

  ; general options
  If grGeneralOptions\sLangCode <> mrGeneralOptions\sLangCode
    bLangCodeChanged = #True
    COND_OPEN_PREFS("UserColumns")                      ; Reset user column text in prefs file if the language has been changed. Added by Dee 24/030/2025
    WritePreferenceString("Usercolumn1", "")
    WritePreferenceString("Usercolumn2", "")
    SetGadgetText(WOP\txtUserColumn1, "")
    SetGadgetText(WOP\txtUserColumn2, "")
    COND_CLOSE_PREFS()
  EndIf
  If #cTranslator
    If grGeneralOptions\bDisplayLangIds <> mrGeneralOptions\bDisplayLangIds
      bLangCodeChanged = #True
    EndIf
  EndIf
  If (grGeneralOptions\sDfltFontName <> mrGeneralOptions\sDfltFontName) Or (grGeneralOptions\nDfltFontSize <> mrGeneralOptions\nDfltFontSize)
    bDfltFontChanged = #True
  EndIf
  If grGeneralOptions\bSwapMonitors1and2 <> mrGeneralOptions\bSwapMonitors1and2
    bSwapMonitorsChanged = #True
  EndIf
  grGeneralOptions = mrGeneralOptions
  With grGeneralOptions
    gsAudioFileDialogInitDir = \sInitDir
    gsCdlgBrowseInitDir = \sInitDir
  EndWith
  
  ; video driver
  If grVideoDriver\nVideoPlaybackLibrary <> mrVideoDriver\nVideoPlaybackLibrary
    bVideoDriverChanged = #True
  ElseIf grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
    If grVideoDriver\nTVGVideoRenderer <> mrVideoDriver\nTVGVideoRenderer Or grVideoDriver\bTVGUse2DDrawingForImages <> mrVideoDriver\bTVGUse2DDrawingForImages
      bVideoDriverChanged = #True
    EndIf
  EndIf
  
  If grVideoDriver\nTVGPlayerHwAccel <> mrVideoDriver\nTVGPlayerHwAccel
    bPlayerHwAccelChanged = #True
  EndIf
  
  For n = 0 To grVideoDriver\nSplitScreenArrayMax
    If grVideoDriver\aSplitScreenInfo[n]\nSplitScreenCount <> mrVideoDriver\aSplitScreenInfo[n]\nSplitScreenCount
      bSplitScreenChanged = #True
      Break
    EndIf
  Next n
  
  grVideoDriver = mrVideoDriver
  CompilerIf #c_blackmagic_card_support
    grCurrScreenVideoRenderers = mrCurrScreenVideoRenderers
    debugMsg(sProcName, "mrCurrScreenVideoRenderers\nMaxCurrScreenVideoRenderer=" + mrCurrScreenVideoRenderers\nMaxCurrScreenVideoRenderer +
                        ", grCurrScreenVideoRenderers\nMaxCurrScreenVideoRenderer=" + grCurrScreenVideoRenderers\nMaxCurrScreenVideoRenderer)
  CompilerElse
    setVideoRendererFlag(grVideoDriver\nVideoPlaybackLibrary)
  CompilerEndIf
  
  For n = 0 To grVideoDriver\nSplitScreenArrayMax
    debugMsg(sProcName, "grVideoDriver\aSplitScreenInfo[" + n + "]\nSplitScreenCount=" + grVideoDriver\aSplitScreenInfo[n]\nSplitScreenCount)
  Next n
  
  grVideoDriver\bDisableVideoWarningMessage = mrVideoDriver\bDisableVideoWarningMessage
  debugMsg(sProcName, "calling populateScreenArray()")
  populateScreenArray()
  
  ; remote app interface options
  If grRAIOptions\bRAIEnabled <> mrRAIOptions\bRAIEnabled Or
     grRAIOptions\nNetworkProtocol <> mrRAIOptions\nNetworkProtocol Or
     grRAIOptions\sLocalIPAddr <> mrRAIOptions\sLocalIPAddr Or
     grRAIOptions\nLocalPort <> mrRAIOptions\nLocalPort
    bRAIChanged = #True
  EndIf
  grRAIOptions = mrRAIOptions
  If bRAIChanged
    debugMsg(sProcName, "calling RAI_Terminate()")
    RAI_Terminate()
    debugMsg(sProcName, "calling RAI_Init()")
    RAI_Init()
  EndIf
  
  ; functional mode options
  If grLicInfo\bFMAvailable
    If grFMOptions\nFunctionalMode <> mrFMOptions\nFunctionalMode Or
       grFMOptions\sFMServerName <> mrFMOptions\sFMServerName Or grFMOptions\sFMLocalIPAddr <> mrFMOptions\sFMLocalIPAddr
      bFMNetworkSettingsChanged = #True
    EndIf
    If grFMOptions\bBackupIgnoreCSMIDI <> mrFMOptions\bBackupIgnoreCSMIDI Or
       grFMOptions\bBackupIgnoreCSNetwork <> mrFMOptions\bBackupIgnoreCSNetwork Or
       grFMOptions\bBackupIgnoreLightingDMX <> mrFMOptions\bBackupIgnoreLightingDMX Or
       grFMOptions\bBackupIgnoreCCDevs <> mrFMOptions\bBackupIgnoreCCDevs
      bFMOptionsChanged = #True
    EndIf
    grFMOptions = mrFMOptions
    If bFMNetworkSettingsChanged
      FM_init(#True)
    ElseIf bFMOptionsChanged
      FM_init(#False) ; nb parameter = #False because no need to close and reopen network connection if only changing 'ignore' settings
    EndIf
  EndIf
  
  ; editing options
  grEditingOptions = mrEditingOptions
  
  ; session options
  If grSession\nDMXInEnabled <> mrSession\nDMXInEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nMidiInEnabled <> mrSession\nMidiInEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nRS232InEnabled <> mrSession\nRS232InEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nNetworkInEnabled <> mrSession\nNetworkInEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nDMXOutEnabled <> mrSession\nDMXOutEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nMidiOutEnabled <> mrSession\nMidiOutEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nRS232OutEnabled <> mrSession\nRS232OutEnabled
    bCallSetMidiEtcDisabledLabel = #True
  ElseIf grSession\nNetworkOutEnabled <> mrSession\nNetworkOutEnabled
    bCallSetMidiEtcDisabledLabel = #True
  EndIf
  grSession = mrSession
  
  gbEditorAndOptionsLocked = grWOP\bEditorAndOptionsLocked
  
  ; opermode options
  If gnOperMode <> grWOP\nCurrOperMode
    bOperModeChanged = #True
  EndIf
  
  nPrevMonitorSize = grOperModeOptions(gnOperMode)\nMonitorSize
  bPrevAllowDisplayTimeout = grOperModeOptions(gnOperMode)\bAllowDisplayTimeout
  bPrevShowMidiCueInCuePanels = grOperModeOptions(gnOperMode)\bShowMidiCueInCuePanels
  bPrevLimitMovementOfMainWindowSplitterBar = grOperModeOptions(gnOperMode)\bLimitMovementOfMainWindowSplitterBar
  grWTC\bCheckWindowExistsAndVisible = #True ; always set this in case another thread tries to use the window
  grWTI\bCheckWindowExistsAndVisible = #True ; always set this in case another thread tries to use the window
  
  gnOperMode = grWOP\nCurrOperMode
  
  For n = 0 To #SCS_OPERMODE_LAST
    grOperModeOptions(n) = mrOperModeOptions(n)
    debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(n) + ")\sSchemeName=" + grOperModeOptions(n)\sSchemeName)
    debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(n) + ")\nMainToolBarInfo=" + Str(grOperModeOptions(n)\nMainToolBarInfo))
  Next n
  updateGridInfoFromPhysicalLayout(@grOperModeOptions(gnOperMode)\rGrdCuesInfo) ; 11May2022 11.9.2
  gbCallLoadDispPanels = #True
  If nPrevMonitorSize <> grOperModeOptions(gnOperMode)\nMonitorSize
    bMonitorSizeChanged = #True
  EndIf
  If bPrevAllowDisplayTimeout <> grOperModeOptions(gnOperMode)\bAllowDisplayTimeout
    bAllowDisplayTimeoutChanged = #True
  EndIf
  If gbShowToolTips <> grOperModeOptions(gnOperMode)\bShowToolTips
    bShowToolTipsChanged = #True
  EndIf
  If bPrevShowMidiCueInCuePanels <> grOperModeOptions(gnOperMode)\bShowMidiCueInCuePanels
    bShowMidiCueInCuePanelsChanged = #True
  EndIf
  If bPrevLimitMovementOfMainWindowSplitterBar <> grOperModeOptions(gnOperMode)\bLimitMovementOfMainWindowSplitterBar
    bLimitMovementOfMainWindowSplitterBarChanged = #True
  EndIf
  If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
    WTC_Form_Load(#False)
  Else
    If IsWindow(#WTC)
      setWindowVisible(#WTC, #False)
    EndIf
  EndIf
  If grOperModeOptions(gnOperMode)\nTimerDispLocn <> #SCS_PTD_SEPARATE_WINDOW
    If IsWindow(#WTI)
      setWindowVisible(#WTI, #False)
    EndIf
  EndIf
  If grColHnd\bAudioGraphColorsChanged
    debugMsg(sProcName, "grColHnd\bAudioGraphColorsChanged=" + strB(grColHnd\bAudioGraphColorsChanged) + ", calling setGraphColors(@grMG2) and setGraphColors(@grMG3)")
    setGraphColors(@grMG2)
    setGraphColors(@grMG3)
  EndIf
  
  ; Added 23Jan2023 11.9.9aa
  If bOperModeChanged
    If IsWindow(#WMN)
      WMN_setViewOperModeMenuItems()
      WMN_applyDisplayOptions(#False, #True, #True)
    EndIf
  EndIf
  ; End added 23Jan2023 11.9.9aa
  
  ; driver settings
  If grDriverSettings\bSMSOnThisMachine <> mrDriverSettings\bSMSOnThisMachine
    bSMSControlChanged = #True
  ElseIf grDriverSettings\sSMSHost <> mrDriverSettings\sSMSHost
    bSMSControlChanged = #True
  EndIf

  If grDriverSettings\bUseBASSMixer <> mrDriverSettings\bUseBASSMixer
    bUseBASSMixerChanged = #True
  EndIf
  If grDriverSettings\nAsioBufLen <> mrDriverSettings\nAsioBufLen
    bAsioSettingChanged = #True
  EndIf
  If grDriverSettings\bNoWASAPI <> mrDriverSettings\bNoWASAPI
    bWASAPIChanged = #True
  EndIf
  
  grDriverSettings = mrDriverSettings
  ; The call to setAudioDriverGlobalFlags() deleted 15Mar2019 11.8.0.2ce following a test in which I enabled the BASS mixer during audio playback, and the program later crashed because gbUseBASSMixer had been set #True
  ; by setAudioDriverGlobalFlags() and so a BASS_Mixer function was called, but the BASS_Mixer had NOT been used in the creation of the stream.
  ; The procedure setAudioDriverGlobalFlags() should only be called during the cue file and device map loading process, or after chaning the audio driver,
  ; because setAudioDriverGlobalFlags() sets global flags that relate to the currently-selected audio driver and it's settings.
  ;   setAudioDriverGlobalFlags()
  mmSetPlaybackBufLength()
  mmSetUpdatePeriodLength()
  
  ; Shortcuts
  CopyArray(maShortcutsMain(), gaShortcutsMain())
  CopyArray(maShortcutsEditor(), gaShortcutsEditor())
  WMN_setKeyboardShortcuts()
  WED_setKeyboardShortcuts()
  savePreferencesForFavFiles()
  
  grWOP\mbReloadGrid = #True

  WMN_setStatusField(RTrim(" " + getMIDIInfo() + " " + RTrim(getRS232Info() + " " + RTrim(DMX_getDMXInfo() + " " + getNetworkInfo()))),#SCS_STATUS_INFO,0,#True)
  
  If bCallSetMidiEtcDisabledLabel
    WMN_setMidiEtcDisabledLabel()
  EndIf
  
  setGoButtonTip()
  setGoButton()

  grWOP\mbChanges = #False
  WOP_setButtons()
  grWOP\mbChangesOK = #True
  
  savePreferences()
  
  If bMonitorSizeChanged
    debugMsg(sProcName, "bMonitorSizeChanged=#True, calling positionVideoMonitorsOrWindows(#True)")
    positionVideoMonitorsOrWindows(#True)
    Select grVideoDriver\nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        debugMsg(sProcName, "calling resetTVGDisplayLocations()")
        resetTVGDisplayLocations()
    EndSelect
  EndIf
  
  If bAllowDisplayTimeoutChanged
    debugMsg(sProcName, "calling applyThreadExecutionState()")
    applyThreadExecutionState()
  EndIf
  
  If bSplitScreenChanged
    debugMsg(sProcName, "calling setVidPicTargets()")
    setVidPicTargets()
    SAW(#WOP)
  EndIf
  
  If bShowMidiCueInCuePanelsChanged Or bLimitMovementOfMainWindowSplitterBarChanged
    gbForceReloadAllDispPanels = #True
  EndIf
  
  CompilerIf #c_include_tvg
    If bPlayerHwAccelChanged
      For n = 0 To ArraySize(*gmVideoGrabber())
        If *gmVideoGrabber(n)
          TVG_SetPlayerHwAccel(*gmVideoGrabber(n), grVideoDriver\nTVGPlayerHwAccel)
          debugMsgT(sProcName, "TVG_SetPlayerHwAccel(" + decodeHandle(*gmVideoGrabber(n)) + ", " + decodeTVGPlayerHwAccel(grVideoDriver\nTVGPlayerHwAccel) + ")")
        EndIf
      Next n
    EndIf
  CompilerEndIf
  
  sMsg = ""
  If bSMSControlChanged
    sMsg = Lang("WOP", "chgSMSControl")
  ElseIf bUseBASSMixerChanged
    sMsg = Lang("WOP", "chgBASSMixer")
  ElseIf bAsioSettingChanged
    sMsg = Lang("WOP", "chgASIOSetting")
  ElseIf bVideoDriverChanged
    sMsg = Lang("WOP", "chgVideoDriver")
  ElseIf bAudioDriverChanged
    sMsg = Lang("WOP", "chgAudioDriver")
  EndIf
  If bLangCodeChanged
    If sMsg
      sMsg + Chr(10) + Chr(10)
    EndIf
    sMsg + Lang("WOP", "chgLangCode")
  EndIf
  If bDfltFontChanged
    If sMsg
      sMsg + Chr(10) + Chr(10)
    EndIf
    sMsg + Lang("WOP", "chgDfltFont")
  EndIf
  If bSwapMonitorsChanged
    If sMsg
      sMsg + Chr(10) + Chr(10)
    EndIf
    sMsg + Lang("WOP", "chgSwapMonitors")
  EndIf
  If bWASAPIChanged
    If sMsg
      sMsg + Chr(10) + Chr(10)
    EndIf
    sMsg + Lang("WOP", "chgWASAPI")
  EndIf
  
  If sMsg
    scsMessageRequester(GWT(#WOP), sMsg)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ; call the following AFTER calling "debugMsg(sProcName, #SCS_END)"
  If bOperModeChanged
    setDefaultTracing()
  EndIf

EndProcedure

Procedure WOP_processEditorAndOptionsLocked()
  PROCNAMEC()
  Protected bEnabled, bLockedMessageVisible, sCaption.s
  
  If grWOP\bEditorAndOptionsLocked
    bEnabled = #False
    bLockedMessageVisible = #True
    sCaption = LangEllipsis("WOP", "btnUnlockEditing")
  Else
    bEnabled = #True
    bLockedMessageVisible = #False
    sCaption = LangEllipsis("WOP", "btnLockEditing")
  EndIf
  
  With WOP
    setEnabled(\cntOptions, bEnabled)
    setEnabled(\cboChangeOperMode, bEnabled)
    setVisible(\lblLocked, bLockedMessageVisible)
    SGT(\btnLockEditing, sCaption)
  EndWith
  
EndProcedure

Procedure WOP_btnAsioControlPanel_Click()
  ; Changed 28Dec2022 11.9.8ab
  PROCNAMEC()
  Protected lCurrentDevice.l, n, bDeviceChanged
  Protected lBassResult.l
  Protected nMaxAsioDev = -1, nAsioDevLimit
  Protected Dim nDevPtr(0), nThisDevPtr
  
  lCurrentDevice = BASS_ASIO_GetDevice()
  debugMsg(sProcName, "BASS_ASIO_GetDevice() returned " + lCurrentDevice)
  
  nAsioDevLimit = #WOP_mnuASIODevLast - #WOP_mnuASIODev0
  
  For n = 0 To gnMaxConnectedDev
    With gaConnectedDev(n)
      If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT And \nDriver = #SCS_DRV_BASS_ASIO
        If \nOutputs > 0 Or \nSpeakers > 0
          nMaxAsioDev + 1
          If nMaxAsioDev > ArraySize(nDevPtr())
            ReDim nDevPtr(nMaxAsioDev)
          EndIf
          nDevPtr(nMaxAsioDev) = n
          If nMaxAsioDev = nAsioDevLimit
            ; reached the limit of connected ASIO devices supported by this function, Limit upped to 16 by Dee 27/02/2025
            Break
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  If nMaxAsioDev = 0
    nThisDevPtr = nDevPtr(0)
    If gaConnectedDev(nThisDevPtr)\nDevice <> lCurrentDevice
      lBassResult = BASS_ASIO_SetDevice(gaConnectedDev(nThisDevPtr)\nDevice)
      debugMsg2(sProcName, "BASS_ASIO_SetDevice(" + gaConnectedDev(nThisDevPtr)\nDevice + ")", lBassResult)
      bDeviceChanged = #True
    EndIf
    debugMsg(sProcName, "calling BASS_ASIO_ControlPanel()")
    lBassResult = BASS_ASIO_ControlPanel()
    debugMsg2(sProcName, "BASS_ASIO_ControlPanel", lBassResult)
    
  ElseIf nMaxAsioDev > 0
    bDeviceChanged = #True
    If scsCreatePopupMenu(#WOP_mnuASIODevs) ; nb menu will be re-created if it already exists
      For n = 0 To nMaxAsioDev
        nThisDevPtr = nDevPtr(n)
        scsMenuItem(#WOP_mnuASIODev0+n, gaConnectedDev(nThisDevPtr)\sPhysicalDevDesc, "", #False)
      Next n
    EndIf
    debugMsg(sProcName, "calling DisplayPopupMenu(#WQF_mnu_Other, WindowID(#WED))")
    DisplayPopupMenu(#WOP_mnuASIODevs, WindowID(#WOP))
  EndIf
  
  If bDeviceChanged And lCurrentDevice >= 0
    lBassResult = BASS_ASIO_SetDevice(lCurrentDevice)
    debugMsg2(sProcName, "BASS_ASIO_SetDevice(" + lCurrentDevice + ")", lBassResult)
  EndIf
  
EndProcedure

Procedure WOP_mnuAsioDev(nEventMenu)
  ; Added 28Dec2022 11.9.8ab
  PROCNAMEC()
  Protected lCurrentDevice.l, n, bDeviceChanged, nErrorCode.l
  Protected lBassResult.l
  Protected sAsioDev.s
  
  sAsioDev = GetMenuItemText(#WOP_mnuASIODevs, nEventMenu)
  debugMsg(sProcName, "sAsioDev=" + sAsioDev)
  
  For n = 0 To gnMaxConnectedDev
    With gaConnectedDev(n)
      If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT And \nDriver = #SCS_DRV_BASS_ASIO
        If \nOutputs > 0 Or \nSpeakers > 0
          If \sPhysicalDevDesc = sAsioDev
            lCurrentDevice = BASS_ASIO_GetDevice()
            debugMsg(sProcName, "BASS_ASIO_GetDevice() returned " + lCurrentDevice)
            If \nDevice <> lCurrentDevice
              lBassResult = BASS_ASIO_Init(\nDevice, 0)
              debugMsg2(sProcName, "BASS_ASIO_Init(" + \nDevice + ", 0)", lBassResult)
              If lBassResult = #BASSFALSE
                nErrorCode = BASS_ASIO_ErrorGetCode()
                debugMsg3(sProcName, "BASS_ASIO_ErrorGetCode=" + nErrorCode + " (" + getBassErrorDesc(nErrorCode) + ")")
              EndIf
              lBassResult = BASS_ASIO_SetDevice(\nDevice)
              debugMsg2(sProcName, "BASS_ASIO_SetDevice(" + \nDevice + ")", lBassResult)
              If lBassResult = #BASSFALSE
                nErrorCode = BASS_ASIO_ErrorGetCode()
                debugMsg3(sProcName, "BASS_ASIO_ErrorGetCode=" + nErrorCode + " (" + getBassErrorDesc(nErrorCode) + ")")
              EndIf
              bDeviceChanged = #True
            EndIf
            debugMsg(sProcName, "calling BASS_ASIO_ControlPanel()")
            lBassResult = BASS_ASIO_ControlPanel()
            debugMsg2(sProcName, "BASS_ASIO_ControlPanel()", lBassResult)
            If \nDevice <> lCurrentDevice
              lBassResult = BASS_ASIO_Free()
              debugMsg2(sProcName, "BASS_ASIO_Free()", lBassResult)
            EndIf
            Break
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  If bDeviceChanged And lCurrentDevice >= 0
    lBassResult = BASS_ASIO_SetDevice(lCurrentDevice)
    debugMsg2(sProcName, "BASS_ASIO_SetDevice(" + lCurrentDevice + ")", lBassResult)
    If lBassResult = #BASSFALSE
      nErrorCode = BASS_ASIO_ErrorGetCode()
      debugMsg3(sProcName, "BASS_ASIO_ErrorGetCode=" + nErrorCode + " (" + getBassErrorDesc(nErrorCode) + ")")
    EndIf
  EndIf
  
EndProcedure

Procedure WOP_btnLockEditing_Click()
  If (grWOP\bEditorAndOptionsLocked = #False) And (gbEditing = #True)
    scsMessageRequester(#SCS_TITLE, Lang("WOP", "CannotLock"), #MB_ICONEXCLAMATION)
  ElseIf (grLicInfo\bPlayOnly)
    scsMessageRequester(#SCS_TITLE, Lang("WOP", "CannotUnlockTemp"), #MB_ICONEXCLAMATION)
  Else
    WLE_Form_Show(#True)
  EndIf
EndProcedure

Procedure WOP_shcSelectShortcut_Event()
  PROCNAMEC()
  Protected n, nRow, nNewShortcut, sCurrentAssignment.s
  Protected sToolTip.s
  
  debugMsg(sProcName, #SCS_START + ", grWOP\nSelectedShortGroup=" + grWOP\nSelectedShortGroup)
  
  nRow = GGS(WOP\grdShortcuts)
  nNewShortcut = GGS(WOP\shcSelectShortcut)
  debugMsg(sProcName, "nRow=" + nRow + ", nNewShortcut=" + nNewShortcut + " " + decodeShortcut(nNewShortcut))
  
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsMain()))
        With maShortcutsMain(nRow)
          If nNewShortcut <> 0  ; 0 in a PB ShortCutGadget = None
            For n = 0 To ArraySize(maShortcutsMain())
              If n <> nRow
                If maShortcutsMain(n)\nShortcut = nNewShortcut
                  sCurrentAssignment = Trim(RemoveString(maShortcutsMain(n)\sFunctionDescr, "*"))
                  Break
                EndIf
              EndIf
            Next n
          EndIf
          SGT(WOP\lblCurrentInfo, " " + sCurrentAssignment) ; prefix with space because a 'bordered' text gadget looks better with the extra padding at the front
          If (\nShortcut <> nNewShortcut) ; And (Len(sCurrentAssignment) = 0)
            sToolTip = LangPars("WOP", "btnKeyAssignTT", #DQUOTE$+decodeShortcut(nNewShortcut)+#DQUOTE$, #DQUOTE$+\sFunctionDescr+#DQUOTE$)
            scsToolTip(WOP\btnKeyAssign, sToolTip)
            setEnabled(WOP\btnKeyAssign, #True)
            sToolTip = LangPars("WOP", "btnKeyResetTT", #DQUOTE$+\sFunctionDescr+#DQUOTE$, #DQUOTE$+decodeShortcut(\nShortcut)+#DQUOTE$)
            scsToolTip(WOP\btnKeyReset, sToolTip)
          Else
            setEnabled(WOP\btnKeyAssign, #False)
          EndIf
          If \nShortcut <> nNewShortcut
            setEnabled(WOP\btnKeyReset, #True)
          Else
            setEnabled(WOP\btnKeyReset, #False)
          EndIf
        EndWith
      EndIf
      
    Case #SCS_ShortGroup_Editor
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsEditor()))
        With maShortcutsEditor(nRow)
          If nNewShortcut <> 0  ; 0 in a PB ShortCutGadget = None
            For n = 0 To ArraySize(maShortcutsEditor())
              If n <> nRow
                If maShortcutsEditor(n)\nShortcut = nNewShortcut
                  sCurrentAssignment = Trim(RemoveString(maShortcutsEditor(n)\sFunctionDescr, "*"))
                  Break
                EndIf
              EndIf
            Next n
          EndIf
          SGT(WOP\lblCurrentInfo, " " + sCurrentAssignment) ; prefix with space because a 'bordered' text gadget looks better with the extra padding at the front
          If (\nShortcut <> nNewShortcut) ; And (Len(sCurrentAssignment) = 0)
            sToolTip = LangPars("WOP", "btnKeyAssignTT", #DQUOTE$+decodeShortcut(nNewShortcut)+#DQUOTE$, #DQUOTE$+\sFunctionDescr+#DQUOTE$)
            scsToolTip(WOP\btnKeyAssign, sToolTip)
            setEnabled(WOP\btnKeyAssign, #True)
            sToolTip = LangPars("WOP", "btnKeyResetTT", #DQUOTE$+\sFunctionDescr+#DQUOTE$, #DQUOTE$+decodeShortcut(\nShortcut)+#DQUOTE$)
            scsToolTip(WOP\btnKeyReset, sToolTip)
          Else
            setEnabled(WOP\btnKeyAssign, #False)
          EndIf
          If \nShortcut <> nNewShortcut
            setEnabled(WOP\btnKeyReset, #True)
          Else
            setEnabled(WOP\btnKeyReset, #False)
          EndIf
        EndWith
      EndIf
      
  EndSelect
  
  WOP_setShortcutsButtons()
  
  SAG(WOP\shcSelectShortcut)
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_btnKeyAssign_Click()
  PROCNAMEC()
  Protected n, nRow, nNewShortcut
  Protected bValidationOK, sMsg.s, nResponse
  
  debugMsg(sProcName, #SCS_START)

  bValidationOK = #True
  
  nRow = GGS(WOP\grdShortcuts)
  nNewShortcut = GGS(WOP\shcSelectShortcut)
  debugMsg(sProcName, "nRow=" + nRow + ", nNewShortcut=" + nNewShortcut + " " + decodeShortcut(nNewShortcut))
  
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsMain()))
        With maShortcutsMain(nRow)
          If nNewShortcut <> 0  ; 0 in a PB ShortCutGadget = None
            For n = 0 To ArraySize(maShortcutsMain())
              If n <> nRow
                If maShortcutsMain(n)\nShortcut = nNewShortcut
                  sMsg = LangSpace("WOP", "ShortcutAlreadyUsed") + #DQUOTE$ + maShortcutsMain(n)\sFunctionDescr + #DQUOTE$ + Chr(10) + Chr(10) +
                         LangPars("WOP", "ShortcutAlreadyUsed2", #DQUOTE$ + maShortcutsMain(n)\sShortcutStr + #DQUOTE$, #DQUOTE$ + maShortcutsMain(nRow)\sFunctionDescr + #DQUOTE$)
                  debugMsg(sProcName, sMsg)
                  nResponse = scsMessageRequester(Lang("WOP", "tabShortcuts"), sMsg, #PB_MessageRequester_YesNo)
                  If nResponse = #PB_MessageRequester_Yes
                    maShortcutsMain(n)\nShortcut = 0  ; 0 in a PB ShortCutGadget = None
                    maShortcutsMain(n)\sShortcutStr = ""
                    maShortcutsMain(n)\nShortcutVK = getShortcutVK(maShortcutsMain(n)\nShortcut, @maShortcutsMain(n)\nShortcutNumPadVK)
                    SetGadgetItemText(WOP\grdShortcuts, n, maShortcutsMain(n)\sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
                  Else
                    bValidationOK = #False
                    Break
                  EndIf
                EndIf
              EndIf
            Next n
          EndIf
          If bValidationOK
            If \nShortcut <> nNewShortcut
              \nShortcut = nNewShortcut
              \sShortcutStr = decodeShortcut(nNewShortcut)
              \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
              SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
              grWOP\mbChanges = #True
              WOP_setButtons()
            EndIf
            WOP_displayShortcuts(nRow)
          EndIf
        EndWith
      EndIf
      
    Case #SCS_ShortGroup_Editor
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsEditor()))
        With maShortcutsEditor(nRow)
          If nNewShortcut <> 0  ; 0 in a PB ShortCutGadget = None
            For n = 0 To ArraySize(maShortcutsEditor())
              If n <> nRow
                If maShortcutsEditor(n)\nShortcut = nNewShortcut
                  sMsg = LangSpace("WOP", "ShortcutAlreadyUsed") + #DQUOTE$ + maShortcutsEditor(n)\sFunctionDescr + #DQUOTE$ + Chr(10) + Chr(10) +
                         LangPars("WOP", "ShortcutAlreadyUsed2", #DQUOTE$ + maShortcutsEditor(n)\sShortcutStr + #DQUOTE$, #DQUOTE$ + maShortcutsEditor(nRow)\sFunctionDescr + #DQUOTE$)
                  debugMsg(sProcName, sMsg)
                  nResponse = scsMessageRequester(Lang("WOP", "tabShortcuts"), sMsg, #PB_MessageRequester_YesNo)
                  If nResponse = #PB_MessageRequester_Yes
                    maShortcutsEditor(n)\nShortcut = 0  ; 0 in a PB ShortCutGadget = None
                    maShortcutsEditor(n)\sShortcutStr = ""
                    maShortcutsEditor(n)\nShortcutVK = getShortcutVK(maShortcutsEditor(n)\nShortcut, @maShortcutsMain(n)\nShortcutNumPadVK)
                    SetGadgetItemText(WOP\grdShortcuts, n, maShortcutsEditor(n)\sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
                  Else
                    bValidationOK = #False
                    Break
                  EndIf
                EndIf
              EndIf
            Next n
          EndIf
          If bValidationOK
            If \nShortcut <> nNewShortcut
              \nShortcut = nNewShortcut
              \sShortcutStr = decodeShortcut(nNewShortcut)
              \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
              SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
              grWOP\mbChanges = #True
              WOP_setButtons()
            EndIf
            WOP_displayShortcuts(nRow)
          EndIf
        EndWith
      EndIf
      
  EndSelect
  
  SAG(WOP\shcSelectShortcut)

  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_btnKeyReset_Click()
  PROCNAMEC()
  Protected nRow
  
  debugMsg(sProcName, #SCS_START)
  
  nRow = GGS(WOP\grdShortcuts)
  
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsMain()))
        With maShortcutsMain(nRow)
          SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
          WOP_displayShortcuts(nRow)
        EndWith
      EndIf
      
    Case #SCS_ShortGroup_Editor
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsEditor()))
        With maShortcutsEditor(nRow)
          SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
          WOP_displayShortcuts(nRow)
        EndWith
      EndIf
      
  EndSelect
  
  SAG(WOP\shcSelectShortcut)
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_btnKeyRemove_Click()
  PROCNAMEC()
  Protected n, nRow
  
  debugMsg(sProcName, #SCS_START)
  
  nRow = GGS(WOP\grdShortcuts)
  
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsMain()))
        With maShortcutsMain(nRow)
          \nShortcut = 0  ; 0 in a PB ShortCutGadget = None
          \sShortcutStr = ""
          \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
          SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
          grWOP\mbChanges = #True
          WOP_setButtons()
          WOP_displayShortcuts(nRow)
        EndWith
      EndIf
      
    Case #SCS_ShortGroup_Editor
      If (nRow >= 0) And (nRow <= ArraySize(maShortcutsEditor()))
        With maShortcutsEditor(nRow)
          \nShortcut = 0  ; 0 in a PB ShortCutGadget = None
          \sShortcutStr = ""
          \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
          SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
          grWOP\mbChanges = #True
          WOP_setButtons()
          WOP_displayShortcuts(nRow)
        EndWith
      EndIf
      
  EndSelect
  
  
  SAG(WOP\shcSelectShortcut)
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_setShortcutsButtons()
  PROCNAMEC()
  Protected bEnableDefault
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      For n = 0 To ArraySize(maShortcutsMain())
        If n <> #SCS_ShortMain_ExclCueOverride
          With maShortcutsMain(n)
            If \sShortcutStr <> \sDefaultShortcutStr
              bEnableDefault = #True
              debugMsg(sProcName, "maShortcutsMain(" + n + ")\sShortcutStr=" + \sShortcutStr + ", \sDefaultShortcutStr=" + \sDefaultShortcutStr)
              Break
            EndIf
          EndWith
        EndIf
      Next n
      
    Case #SCS_ShortGroup_Editor
      For n = 0 To ArraySize(maShortcutsEditor())
        With maShortcutsEditor(n)
          If \sShortcutStr <> \sDefaultShortcutStr
            bEnableDefault = #True
            debugMsg(sProcName, "maShortcutsEditor(" + n + ")\sShortcutStr=" + \sShortcutStr + ", \sDefaultShortcutStr=" + \sDefaultShortcutStr)
            Break
          EndIf
        EndWith
      Next n
      
  EndSelect
  
  setEnabled(WOP\btnDefaultShortcuts, bEnableDefault)
EndProcedure

Procedure WOP_btnDefaultShortcuts_Click()
  PROCNAMEC()
  Protected nRow, nHoldKeyIndex
  Protected bChangeReqd

  nHoldKeyIndex = GGS(WOP\grdShortcuts)
  
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      For nRow = 0 To ArraySize(maShortcutsMain())
        If nRow <> #SCS_ShortMain_ExclCueOverride
          With maShortcutsMain(nRow)
            If \sShortcutStr <> \sDefaultShortcutStr
              bChangeReqd = #True
              \sShortcutStr = \sDefaultShortcutStr
              \nShortcut = encodeShortcut(\sShortcutStr)
              \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
              SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
              grWOP\mbChanges = #True
            EndIf
          EndWith
        EndIf
      Next nRow
      
    Case #SCS_ShortGroup_Editor
      For nRow = 0 To ArraySize(maShortcutsEditor())
        With maShortcutsEditor(nRow)
          If \sShortcutStr <> \sDefaultShortcutStr
            bChangeReqd = #True
            \sShortcutStr = \sDefaultShortcutStr
            \nShortcut = encodeShortcut(\sShortcutStr)
            \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
            SetGadgetItemText(WOP\grdShortcuts, nRow, \sShortcutStr, #SCS_GRDKEYS_SHORTCUT)
            grWOP\mbChanges = #True
          EndIf
        EndWith
      Next nRow
  EndSelect
  
  If bChangeReqd
    WOP_setButtons()
  EndIf
  
  WOP_displayShortcuts(nHoldKeyIndex)
  
  SAG(WOP\shcSelectShortcut)
  
EndProcedure

Procedure WOP_btnDefaultDisplayOptions_Click()
  PROCNAMEC()
  
  With mrOperModeOptions(grWOP\nNodeOperMode)
    ; see also setPrefOperModeDefaults() in modStartUp.pbi
    
    ; ordered below as per the screen layout
    
    ; Color Scheme
    \sSchemeName              = grOperModeOptionDefs(grWOP\nNodeOperMode)\sSchemeName
    
    ; Control Panel
    \nCtrlPanelPos            = grOperModeOptionDefs(grWOP\nNodeOperMode)\nCtrlPanelPos
    \nMainToolBarInfo         = grOperModeOptionDefs(grWOP\nNodeOperMode)\nMainToolBarInfo
    \nVisMode                 = grOperModeOptionDefs(grWOP\nNodeOperMode)\nVisMode
    \bShowNextManualCue       = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowNextManualCue
    \bShowMasterFader         = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowMasterFader
    \bShowMidiCueInNextManual = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowMidiCueInNextManual
    
    ; Cue List, Cue Panels and Hotkey List
    \nCueListFontSize         = grOperModeOptionDefs(grWOP\nNodeOperMode)\nCueListFontSize
    \nCuePanelVerticalSizing  = grOperModeOptionDefs(grWOP\nNodeOperMode)\nCuePanelVerticalSizing
    \bShowSubCues             = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowSubCues
    \bShowHiddenAutoStartCues = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowHiddenAutoStartCues
    \bShowHotkeyCuesInPanels  = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowHotkeyCuesInPanels
    \bShowHotkeyList          = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowHotkeyList
    \bShowTransportControls   = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowTransportControls
    \bShowFaderAndPanControls = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowFaderAndPanControls
    \bShowMidiCueInCuePanels  = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowMidiCueInCuePanels
    \bLimitMovementOfMainWindowSplitterBar = grOperModeOptionDefs(grWOP\nNodeOperMode)\bLimitMovementOfMainWindowSplitterBar
    
    ; Audio File Progress Slider extras
    \bShowLvlCurvesPrim       = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowLvlCurvesPrim
    \bShowLvlCurvesOther      = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowLvlCurvesOther
    \bShowPanCurvesPrim       = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowPanCurvesPrim
    \bShowPanCurvesOther      = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowPanCurvesOther
    \bShowAudioGraph          = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowAudioGraph
    \bShowCueMarkers          = grOperModeOptionDefs(grWop\nNodeOperMode)\bShowCueMarkers
    
    ; Other Display Options
    \nMonitorSize             = grOperModeOptionDefs(grWOP\nNodeOperMode)\nMonitorSize
    \nMTCDispLocn             = grOperModeOptionDefs(grWOP\nNodeOperMode)\nMTCDispLocn
    \nTimerDispLocn           = grOperModeOptionDefs(grWOP\nNodeOperMode)\nTimerDispLocn
    ; \nMaxMonitor              = grOperModeOptionDefs(grWOP\nNodeOperMode)\nMaxMonitor ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
    \bShowToolTips            = grOperModeOptionDefs(grWOP\nNodeOperMode)\bShowToolTips
    \bAllowDisplayTimeout     = grOperModeOptionDefs(grWOP\nNodeOperMode)\bAllowDisplayTimeout
    \bDisplayAllMidiIn        = grOperModeOptionDefs(grWOP\nNodeOperMode)\bDisplayAllMidiIn
    \nMidiInDisplayTimeout    = grOperModeOptionDefs(grWOP\nNodeOperMode)\nMidiInDisplayTimeout
    
    ; hidden display options
    \bHideCueList             = grOperModeOptionDefs(grWOP\nNodeOperMode)\bHideCueList
    \nPeakMode                = grOperModeOptionDefs(grWOP\nNodeOperMode)\nPeakMode
    \nVUBarWidth              = grOperModeOptionDefs(grWOP\nNodeOperMode)\nVUBarWidth
    \rGrdCuesInfo\sLayoutString = grOperModeOptionDefs(grWOP\nNodeOperMode)\rGrdCuesInfo\sLayoutString
    
  EndWith
  WOP_showDisplayOptions()
  WMN_setCueListFontSize()
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
  
EndProcedure

Procedure WOP_btnTestSMS_Click()
  PROCNAMEC()
  Protected bTestResult
  
  debugMsg(sProcName, #SCS_START)
  
  gnSuspendGetCurrInfo + 1  ; need to suspend getSMSCurrInfo() while testing connection
  SGT(WOP\lblTestSMSResult, "")
  setEnabled(WOP\btnTestSMS, #False)
  setMouseCursorBusy()
  allowWindowToRefresh(250)
  
  ; added 10Dec2024
  ; The code below has been adjusted so that when the SM_S test button is clicked it automatically tests for a SM-M network connection.
  ; IMPORTANT: Clicking the test button will now stop all running LTC cues, because it the test fails it will need to switch to SCS LTC, if it is running
  ; and the test succeeds we stop any running SCS LTC cues and switch to SM-S LTC. The SCS LTC thread is stopped.
  bTestResult = openSMSCheckConnection(mrDriverSettings\sSMSHost, 20000)
  stopAllTimeCodes()                                      ; added 10Dec2024 to enable auto switch over between SM-S LTC and SCS LTC 
  setMouseCursorNormal()
  setEnabled(WOP\btnTestSMS, #True)
  
  If bTestResult
    If grLicInfo\bLTCAvailable                            ; added 10Dec2024 to enable auto switch over between SM-S LTC and SCS LTC
      gn_ScsLTCAllowed = #False
      THR_suspendAThread(#SCS_THREAD_SCS_LTC)
    EndIf
  
    SetGadgetColor(WOP\lblTestSMSResult, #PB_Gadget_FrontColor, #SCS_Black)
    SGT(WOP\lblTestSMSResult, Lang("WOP", "TestSMSOK"))
  Else
    If grLicInfo\bLTCAvailable       ; added 10Dec2024 to enable auto switch over between SM-S LTC and SCS LTC
      CompilerIf #c_scsltc
        gn_ScsLTCAllowed = #True
        THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)      ; No SMS server so enable internal LTC
      CompilerElse
        gn_ScsLTCAllowed = #False
        ;THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)      ; No SMS server so enable internal LTC, Modified by Dee 29-01-2025 to disable SCSLTC
      CompilerEndIf
    EndIf
    
    SetGadgetColor(WOP\lblTestSMSResult, #PB_Gadget_FrontColor, #SCS_Red)
    SGT(WOP\lblTestSMSResult, Lang("WOP", "TestSMSFailed"))
  EndIf
  grWOP\bTestLabelPopulated = #True
  gnSuspendGetCurrInfo - 1
  
EndProcedure

Procedure WOP_cboChangeOperMode()
  PROCNAMEC()
  Protected nNewOperMode
  
  debugMsg(sProcName, #SCS_START)
  
  nNewOperMode = getCurrentItemData(WOP\cboChangeOperMode, -1)
  Select nNewOperMode
    Case #SCS_OPERMODE_DESIGN, #SCS_OPERMODE_REHEARSAL, #SCS_OPERMODE_PERFORMANCE
      If nNewOperMode <> grWOP\nCurrOperMode
        ; save the WMN splitter positions for the current oper mode before changing the opermode
        If grWMN\bNorthSouthSplitterInitialPosApplied
          If grWOP\nCurrOperMode = #SCS_OPERMODE_DESIGN
            grWMN\nNorthSouthSplitterPosD = GetGadgetState(WMN\splNorthSouth)
            grWMN\nPanelsHotkeysSplitterEndPosD = GadgetWidth(WMN\splPanelsHotkeys) - GetGadgetState(WMN\splPanelsHotkeys)
          ElseIf grWOP\nCurrOperMode = #SCS_OPERMODE_REHEARSAL
            grWMN\nNorthSouthSplitterPosR = GetGadgetState(WMN\splNorthSouth)
            grWMN\nPanelsHotkeysSplitterEndPosR = GadgetWidth(WMN\splPanelsHotkeys) - GetGadgetState(WMN\splPanelsHotkeys)
          Else
            grWMN\nNorthSouthSplitterPosP = GetGadgetState(WMN\splNorthSouth)
            grWMN\nPanelsHotkeysSplitterEndPosP = GadgetWidth(WMN\splPanelsHotkeys) - GetGadgetState(WMN\splPanelsHotkeys)
          EndIf
        EndIf
        grWOP\nCurrOperMode = nNewOperMode
        WOP_displayOperMode()
        WOP_displayFontInfo()
        CompilerIf 1=2 ; Test added 23Jan2023 11.9.9aa
          WMN_setViewOperModeMenuItems()
          WMN_applyDisplayOptions(#False, #True)  ; may change the position of the WMN splitter
        CompilerEndIf
        grWOP\mbChanges = #True
        WOP_setButtons()
      EndIf
  EndSelect
  SGS(WOP\cboChangeOperMode, 0)  ; reset combobox to "Select..."
  SAG(-1)
  
EndProcedure

Procedure WOP_cboDoubleClick_Click()
  mrGeneralOptions\nDoubleClickTime = getCurrentItemData(WOP\cboDoubleClick)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_cboFadeAllTime_Click()
  mrGeneralOptions\nFadeAllTime = getCurrentItemData(WOP\cboFadeAllTime)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_cboDBIncrement_Click()
  Protected sDBIncrement.s
  
  sDBIncrement = Trim(RemoveString(GGT(WOP\cboDBIncrement), "dB"))
  mrGeneralOptions\sDBIncrement = sDBIncrement
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_cboLanguage_Click()
  Protected nIndex
  
  With mrGeneralOptions
    nIndex = getCurrentItemData(WOP\cboLanguage)
    If nIndex >= 0
      \sLangCode = gaLanguage(nIndex)\sLangCode
    EndIf
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_chkDisplayLangIds()
  PROCNAMEC()
  
  With mrGeneralOptions
    \bDisplayLangIds = GGS(WOP\chkDisplayLangIds)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboSampleRate_Click()
  Protected sTmp.s
  With mrDriverSettings
    sTmp = GGT(WOP\cboSampleRate)
    \nDSSampleRate = Val(sTmp)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboAsioBufLen_Click()
  With mrDriverSettings
    \nAsioBufLen = getCurrentItemData(WOP\cboAsioBufLen)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboFileBufLen_Click()
  With mrDriverSettings
    \nFileBufLen = getCurrentItemData(WOP\cboFileBufLen)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboFileScanMaxLengthAudio_Click()
  With mrEditingOptions
    \nFileScanMaxLengthAudio = getCurrentItemData(WOP\cboFileScanMaxLengthAudio)
    \nFileScanMaxLengthAudioMS = \nFileScanMaxLengthAudio * 60000
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboFileScanMaxLengthVideo_Click()
  With mrEditingOptions
    \nFileScanMaxLengthVideo = getCurrentItemData(WOP\cboFileScanMaxLengthVideo)
    \nFileScanMaxLengthVideoMS = \nFileScanMaxLengthVideo * 60000
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboVideoLibrary_Click()
  With mrVideoDriver
    \nVideoPlaybackLibrary = getCurrentItemData(WOP\cboVideoLibrary)
    WOP_fcVideoLibrary()
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboVideoRenderer_Click()
  With mrVideoDriver
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        \nTVGVideoRenderer = getCurrentItemData(WOP\cboVideoRenderer)
    EndSelect
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboTVGPlayerHwAccel_Click()
  With mrVideoDriver
    \nTVGPlayerHwAccel = getCurrentItemData(WOP\cboTVGPlayerHwAccel, #tvc_hw_None)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboScreenVideoRenderer_Click(Index)
  PROCNAMEC()
  Protected nDisplayNo, nScreenVideoRenderer, n, nArrayIndex
  
  nDisplayNo = mrVideoDriver\aSplitScreenInfo[Index]\nDisplayNo
  nScreenVideoRenderer = getCurrentItemData(WOP\cboScreenVideoRenderer[Index])
  With mrCurrScreenVideoRenderers
    nArrayIndex = -1
    For n = 0 To \nMaxCurrScreenVideoRenderer
      If \aCurrScreenVideoRenderer(n)\nDisplayNo = nDisplayNo
        nArrayIndex = n
        Break
      EndIf
    Next n
    If nArrayIndex = -1
      If nScreenVideoRenderer <> #SCS_VR_AUTOSELECT
        \nMaxCurrScreenVideoRenderer + 1
        nArrayIndex = \nMaxCurrScreenVideoRenderer
        If nArrayIndex > ArraySize(\aCurrScreenVideoRenderer())
          ReDim \aCurrScreenVideoRenderer(nArrayIndex)
        EndIf
        \aCurrScreenVideoRenderer(nArrayIndex)\nDisplayNo = nDisplayNo
      EndIf
    EndIf
    If nArrayIndex >= 0
      If \aCurrScreenVideoRenderer(nArrayIndex)\nScreenVideoRenderer <> nScreenVideoRenderer
        \aCurrScreenVideoRenderer(nArrayIndex)\nScreenVideoRenderer = nScreenVideoRenderer
        debugMsg(sProcName, "mrCurrScreenVideoRenderers\aCurrScreenVideoRenderer(" + nArrayIndex + ")\nScreenVideoRenderer=" + decodeVideoRenderer(\aCurrScreenVideoRenderer(nArrayIndex)\nScreenVideoRenderer))
        grWOP\mbChanges = #True
        WOP_setButtons()
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WOP_cboSplitScreenCount_Click(Index)
  PROCNAMEC()
  Protected nArrayIndex
  Protected nSplitScreenCount
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nArrayIndex = GetGadgetData(WOP\cboSplitScreenCount[Index])
  debugMsg(sProcName, "nArrayIndex=" + nArrayIndex)
  With mrVideoDriver\aSplitScreenInfo[nArrayIndex]
    nSplitScreenCount = getCurrentItemData(WOP\cboSplitScreenCount[Index], 1)
    If nSplitScreenCount <> \nSplitScreenCount
      \nSplitScreenCount = nSplitScreenCount
      debugMsg(sProcName, "GGS(WOP\cboSplitScreenCount[" + Index + "])=" + GGS(WOP\cboSplitScreenCount[Index]) + ", mrVideoDriver\aSplitScreenInfo[" + nArrayIndex + "]\nSplitScreenCount=" + \nSplitScreenCount)
      WOP_populateSplitScreenInfo()
      WOP_populateGrdScreens()
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

;- Function Mode Routines

Procedure WOP_txtFMServerAddr_Changed()
  With mrFMOptions
    \sFMServerName = GetGadgetText(WOP\txtFMServerAddr)
  EndWith
  WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_cboFMLocalIPAddr_Click()
  Protected sValue
  With mrFMOptions
    If \nFunctionalMode = #SCS_FM_PRIMARY
      sValue= getCurrentItemData(WOP\cboFMLocalIPAddr)
      \nFMServerId=sValue
      \sFMLocalIPAddr = GetGadgetText(WOP\cboFMLocalIPAddr)
    EndIf
  EndWith
  WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_chkBackupIgnoreLighting_Click()
  With mrFMOptions
    \bBackupIgnoreLightingDMX = GGS(WOP\chkBackupIgnoreLIGHTING)
  EndWith  
  WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_chkBackupIgnoreMIDI_Click()
  With mrFMOptions
    \bBackupIgnoreCSMIDI = GGS(WOP\chkBackupIgnoreCtrlSendMIDI)
  EndWith
  WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_chkBackupIgnoreNetwork_Click()
  With mrFMOptions
     \bBackupIgnoreCSNetwork = GGS(WOP\chkBackupIgnoreCtrlSendNETWORK)
   EndWith
   WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_chkBackupIgnoreCueCtrlDevs_Click()
  With mrFMOptions
     \bBackupIgnoreCCDevs = GGS(WOP\chkBackupIgnoreCueCtrlDevs)
   EndWith
   WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_cboFMFunctionalMode_Click()  
  With mrFMOptions
    \nFunctionalMode = getCurrentItemData(WOP\cboFMFunctionalMode)
  EndWith
  WOP_FunctionModeChanged()
EndProcedure

Procedure WOP_FunctionModeChanged()
    grWOP\mbChanges = #True
    WOP_showFMOptions()
    WOP_setButtons() 
EndProcedure

Procedure WOP_cboRAIApp_Click()
  Protected nPrevRAIApp, bOSCVersionVisible, bNetworkProtocolEnabled
  
  With mrRAIOptions
    nPrevRAIApp = \nRAIApp
    \nRAIApp = getCurrentItemData(WOP\cboRAIApp)
    If \nRAIApp <> nPrevRAIApp
      bNetworkProtocolEnabled = #True
      Select \nRAIApp
        Case #SCS_RAI_APP_OSC
          \nLocalPort = #SCS_DEFAULT_RAI_LOCAL_PORT_OSCAPP
        Default
          \nLocalPort = #SCS_DEFAULT_RAI_LOCAL_PORT_SCSREMOTE
          \nNetworkProtocol = #SCS_NETWORK_PR_TCP
          bNetworkProtocolEnabled = #False
      EndSelect
      SGT(WOP\txtRAILocalPort, Str(\nLocalPort))
      setComboBoxByData(WOP\cboRAINetworkProtocol, \nNetworkProtocol)
      setEnabled(WOP\cboRAINetworkProtocol, bNetworkProtocolEnabled)
      If \nRAIApp = #SCS_RAI_APP_OSC And \nNetworkProtocol = #SCS_NETWORK_PR_TCP
        setComboBoxByData(WOP\cboRAIOSCVersion, \nRAIOSCVersion)
        bOSCVersionVisible = #True
      EndIf
      setVisible(WOP\lblRAIOSCVersion, bOSCVersionVisible)
      setVisible(WOP\cboRAIOSCVersion, bOSCVersionVisible)
    EndIf
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboRAIOSCVersion_Click()
  With mrRAIOptions
    \nRAIOSCVersion = getCurrentItemData(WOP\cboRAIOSCVersion)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboRAILocalIPAddr_Click()
  With mrRAIOptions
    \sLocalIPAddr = GGT(WOP\cboRAILocalIPAddr)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboRAINetworkProtocol_Click()
  Protected bOSCVersionVisible
  
  With mrRAIOptions
    \nNetworkProtocol = getCurrentItemData(WOP\cboRAINetworkProtocol)
    If \nRAIApp = #SCS_RAI_APP_OSC And \nNetworkProtocol = #SCS_NETWORK_PR_TCP
      bOSCVersionVisible = #True
      setComboBoxByData(WOP\cboRAIOSCVersion, \nRAIOSCVersion)
    EndIf
    setVisible(WOP\lblRAIOSCVersion, bOSCVersionVisible)
    setVisible(WOP\cboRAIOSCVersion, bOSCVersionVisible)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_chkApplyTimeoutToOtherGos_Click()
  With mrGeneralOptions
    \bApplyTimeoutToOtherGos = GGS(WOP\chkApplyTimeoutToOtherGos)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_chkDisableRightClick_Click()
  mrGeneralOptions\bDisableRightClickAsGo = GGS(WOP\chkDisableRightClick)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkCtrlOverridesExclCue_Click()
  mrGeneralOptions\bCtrlOverridesExclCue = GGS(WOP\chkCtrlOverridesExclCue)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkHotkeysOverrideExclCue_Click()
  mrGeneralOptions\bHotkeysOverrideExclCue = GGS(WOP\chkHotkeysOverrideExclCue)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkEnableAutoCheckForUpdate_Click()
  mrGeneralOptions\bEnableAutoCheckForUpdate = GGS(WOP\chkEnableAutoCheckForUpdate)
  WOP_fcEnableAutoCheckForUpdate()
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkSwap34with56_Click()
  mrDriverSettings\bSwap34with56 = GGS(WOP\chkSwap34with56)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkNoFloatingPoint_Click()
  mrDriverSettings\bNoFloatingPoint = GGS(WOP\chkNoFloatingPoint)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkNoWASAPI_Click()
  mrDriverSettings\bNoWASAPI = GGS(WOP\chkNoWASAPI)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkCheckMainLostFocusWhenEditorOpen_Click()
  mrEditingOptions\bCheckMainLostFocusWhenEditorOpen = GGS(WOP\chkCheckMainLostFocusWhenEditorOpen)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkActivateOCMAutoStarts_Click()
  mrEditingOptions\bActivateOCMAutoStarts = GGS(WOP\chkActivateOCMAutoStarts)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkDisableVideoWarningMessage_Click()
  mrVideoDriver\bDisableVideoWarningMessage = GGS(WOP\chkDisableVideoWarningMessage)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkSaveAlwaysOn_Click()
  mrEditingOptions\bSaveAlwaysOn = GGS(WOP\chkSaveAlwaysOn)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkDisplayAllMidiIn_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bDisplayAllMidiIn = GGS(WOP\chkDisplayAllMidiIn)
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboMidiInDisplayTimeout_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nMidiInDisplayTimeout = getCurrentItemData(WOP\cboMidiInDisplayTimeout)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkIgnoreTitleTags_Click()
  mrEditingOptions\bIgnoreTitleTags = GGS(WOP\chkIgnoreTitleTags)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkIncludeAllLevelPointDevices_Click()
  mrEditingOptions\bIncludeAllLevelPointDevices = GGS(WOP\chkIncludeAllLevelPointDevices)
  grWOP\mbChanges = #True
  WOP_setButtons()  
EndProcedure

Procedure WOP_chkSMSOnThisMachine_Click()
  mrDriverSettings\bSMSOnThisMachine = GGS(WOP\chkSMSOnThisMachine)
  WOP_fcSMSOnThisMachine()
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkRAIEnabled_Click()
  mrRAIOptions\bRAIEnabled = GGS(WOP\chkRAIEnabled)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_chkTVGDisplayVUMeters_Click()
  mrVideoDriver\bTVGDisplayVUMeters = GGS(WOP\chkTVGDisplayVUMeters)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_updateCopyButtonStates()
  PROCNAMEC()
  Protected nCurrentMode, nSelectedMode
  
  nCurrentMode = grWOP\nNodeOperMode
  nSelectedMode = getCurrentItemData(WOP\cboCopyModeSettings)
  debugMsg(sProcName, "nCurrentMode=" + decodeOperMode(nCurrentMode) + ", nSelectedMode=" + Str(nSelectedMode))
  
  ; Enable copy button only if a different mode is selected and the grid settings do not match
  If nSelectedMode = -1 Or WOP_gridSettingsMatch(nCurrentMode, nSelectedMode)
    DisableGadget(WOP\btnCopyModeSettings, #True)
  Else
    DisableGadget(WOP\btnCopyModeSettings, #False)
  EndIf
EndProcedure

Procedure WOP_populateGrdCueListCols()
  PROCNAMEC()
  Protected m, n, nRow, nSelectedColIndex, nNewSelectedRow
  
  debugMsg(sProcName, #SCS_START)
  
  nRow = GGS(WOP\grdCueListCols)
  If nRow >= 0
    nSelectedColIndex = GetGadgetItemData(WOP\grdCueListCols, nRow)
  Else
    nSelectedColIndex = -1
  EndIf
  
  nNewSelectedRow = -1
  ClearGadgetItems(WOP\grdCueListCols)
  ; add displayed columns first, in the order they are displayed
  debugMsg(sProcName, "mrOperModeOptions(" + decodeOperMode(grWOP\nNodeOperMode) + ")\rGrdCuesInfo\nMaxColNo=" + mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\nMaxColNo)
  With mrOperModeOptions(grWOP\nNodeOperMode)
    For m = 0 To \rGrdCuesInfo\nMaxColNo
      For n = 0 To \rGrdCuesInfo\nMaxColNo
        If \rGrdCuesInfo\aCol(n)\nCurColOrder = m
          If \rGrdCuesInfo\aCol(n)\bColVisible
            addGadgetItemWithData(WOP\grdCueListCols, \rGrdCuesInfo\aCol(n)\sTitle, n)
            debugMsg(sProcName, "(displayed) aCol[" + n + "]\sTitle=" + \rGrdCuesInfo\aCol(n)\sTitle)
            SetGadgetItemState(WOP\grdCueListCols, CountGadgetItems(WOP\grdCueListCols)-1, #PB_ListIcon_Checked)
            If n = nSelectedColIndex
              nNewSelectedRow = CountGadgetItems(WOP\grdCueListCols) - 1
            EndIf
          EndIf
        EndIf
      Next n
    Next m
    ; now add non-displayed columns
    For n = 0 To \rGrdCuesInfo\nMaxColNo
      If \rGrdCuesInfo\aCol(n)\nCurColNo = -1 Or \rGrdCuesInfo\aCol(n)\bColVisible = #False
        addGadgetItemWithData(WOP\grdCueListCols, \rGrdCuesInfo\aCol(n)\sTitle, n)
        debugMsg(sProcName, "(not displayed) aCol[" + n + "]\sTitle=" + \rGrdCuesInfo\aCol(n)\sTitle)
        If n = nSelectedColIndex
          nNewSelectedRow = CountGadgetItems(WOP\grdCueListCols) - 1
        EndIf
      EndIf
    Next n
  EndWith
  SGS(WOP\grdCueListCols, nNewSelectedRow)
  WOP_setCueListColsButtons()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_grdCueListCols_LeftClick()
  PROCNAMEC()
  Protected m, n, bIncludeCol, nColIndex, nCurColNo
  Protected bChanged
  
  nCurColNo = -1
  With mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo
    For n = 0 To (CountGadgetItems(WOP\grdCueListCols)-1)
      If GetGadgetItemState(WOP\grdCueListCols, n) & #PB_ListIcon_Checked
        bIncludeCol = #True
        nCurColNo + 1
      Else
        bIncludeCol = #False
      EndIf
      nColIndex = GetGadgetItemData(WOP\grdCueListCols, n)
      If \aCol(nColIndex)\bColVisible <> bIncludeCol
        \aCol(nColIndex)\bColVisible = bIncludeCol
        bChanged = #True
      EndIf
      If bIncludeCol
        \aCol(nColIndex)\nCurColNo = nCurColNo
      Else
        \aCol(nColIndex)\nCurColNo = -1
      EndIf
      \aCol(nColIndex)\nCurColOrder = \aCol(nColIndex)\nCurColNo
    Next n
  EndWith
  
  If bChanged
    WOP_populateGrdCueListCols()
    WOP_setOptionsChanged()
    WMN_setupGrid()
    populateGrid()
    WOP_updateCopyButtonStates()
  Else
    WOP_setCueListColsButtons()
  EndIf
  
EndProcedure

Procedure WOP_moveUpOrDown(bMoveUp)
  PROCNAMEC()
  Protected nRow
  Protected nColIndex, nOtherColIndex
  Protected nCurColOrder, nOtherColOrder
  
  debugMsg(sProcName, #SCS_START + ", grWOP\nNodeOperMode=" + decodeOperMode(grWOP\nNodeOperMode) + ", bMoveUp=" + strB(bMoveUp))

  nOtherColIndex = -1
  nRow = GGS(WOP\grdCueListCols)
  If nRow >= 0
    nColIndex = GetGadgetItemData(WOP\grdCueListCols, nRow)
    If bMoveUp
      If nRow > 0
        nOtherColIndex = GetGadgetItemData(WOP\grdCueListCols, nRow-1)
      EndIf
    Else
      If nRow < (CountGadgetItems(WOP\grdCueListCols)-1)
        nOtherColIndex = GetGadgetItemData(WOP\grdCueListCols, nRow+1)
      EndIf
    EndIf
    If nOtherColIndex >= 0
      nCurColOrder = mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(nColIndex)\nCurColOrder
      nOtherColOrder = mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(nOtherColIndex)\nCurColOrder
      
      If nCurColOrder >= 0 And nOtherColOrder >= 0
        
        mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(nColIndex)\nCurColOrder = nOtherColOrder
        mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(nOtherColIndex)\nCurColOrder = nCurColOrder
        
        WOP_populateGrdCueListCols()
        WOP_setOptionsChanged()
        WMN_setupGrid()
        populateGrid()
        
      EndIf
      
    EndIf
  EndIf
  
EndProcedure

Procedure WOP_btnColDefaults_Click()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", grWOP\nNodeOperMode=" + decodeOperMode(grWOP\nNodeOperMode))
  
  For n = 0 To mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\nMaxColNo
    With mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(n)
      \nCurWidth = \nDefWidth
      \nCurColNo = \nDefColNo
      If \nCurColNo >= 0
        \bColVisible = #True
      Else
        \bColVisible = #False
      EndIf
      \nCurColOrder = \nCurColNo
    EndWith
  Next n
  
  WOP_populateGrdCueListCols()
  WOP_setOptionsChanged()
  WMN_setupGrid()
  populateGrid()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_btnColRevert_Click()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", grWOP\nNodeOperMode=" + decodeOperMode(grWOP\nNodeOperMode))

  For n = 0 To mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\nMaxColNo
    With mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(n)
      \nCurWidth = \nIniWidth
      \nCurColNo = \nIniColNo
      If \nCurColNo >= 0
        \bColVisible = #True
      Else
        \bColVisible = #False
      EndIf
      \nCurColOrder = \nCurColNo
    EndWith
  Next n
  
  WOP_populateGrdCueListCols()
  WOP_setOptionsChanged()
  WMN_setupGrid()
  populateGrid()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_btnColFit_Click()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", grWOP\nNodeOperMode=" + decodeOperMode(grWOP\nNodeOperMode))
  
  autoFitGridCol(WMN\grdCues, -2)
  
  WOP_setOptionsChanged()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_setCueListColsButtons()
  PROCNAMEC()
  Protected bEnableMoveUp, bEnableMoveDown, bEnableDefault, bEnableRevert
  Protected nRow, nLastRow, nMaxVisibleColNo, n
  
  With mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo
    ; calculate nMaxVisibleColNo because the value in \rGrdCuesInfo may not be correct if the grid is not currently displayed for this opermode
    nMaxVisibleColNo = -1
    ; For nRow = 0 To \nMaxColNo
      ; Debug "\aCol[" + Str(nRow) + "]\bVisible=" + strB(\aCol(nRow)\bVisible)
      ; If \aCol(nRow)\bVisible
        ; nMaxVisibleColNo = nRow + 1
      ; Else
        ; Break
      ; EndIf
    ; Next nRow
    For nRow = 0 To \nMaxColNo
      ; Debug "\aCol[" + Str(nRow) + "]\bColVisible=" + strB(\aCol(nRow)\bColVisible)
      If \aCol(nRow)\bColVisible
        nMaxVisibleColNo + 1
      EndIf
    Next nRow
    nRow = GGS(WOP\grdCueListCols)
    If nRow >= 0
      If nRow < nMaxVisibleColNo
        bEnableMoveDown = #True
      EndIf
      If nRow > 0
        If GetGadgetItemState(WOP\grdCueListCols, nRow) & #PB_ListIcon_Checked
          bEnableMoveUp = #True
        EndIf
      EndIf
    EndIf
    ; Debug "nMaxVisibleColNo=" + Str(nMaxVisibleColNo) + ", GGS(WOP\grdCueListCols)=" + Str(GGS(WOP\grdCueListCols)) + ", nRow=" + Str(nRow) + ", bEnableMoveUp=" + strB(bEnableMoveUp) + ", bEnableMoveDown=" + strB(bEnableMoveDown)
  EndWith
  
  For n = 0 To mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\nMaxColNo
    With mrOperModeOptions(grWOP\nNodeOperMode)\rGrdCuesInfo\aCol(n)
      If (\nCurWidth <> \nDefWidth) Or (\nCurColNo <> \nDefColNo)
        bEnableDefault = #True
      EndIf
      If (\nCurWidth <> \nIniWidth) Or (\nCurColNo <> \nIniColNo)
        bEnableRevert = #True
      EndIf
    EndWith
  Next n
  
  setEnabled(WOP\btnMoveUp, bEnableMoveUp)
  setEnabled(WOP\btnMoveDown, bEnableMoveDown)
  setEnabled(WOP\btnColDefaults, bEnableDefault)
  setEnabled(WOP\btnColRevert, bEnableRevert)
  
EndProcedure

; Helper Procedures for Undo/Redo
Procedure WOP_getUndoDataStructure(nMode)
  With grWOP
    Select nMode
      Case #SCS_OPERMODE_DESIGN
        ProcedureReturn @\mtGrdCuesInfoDesign
      Case #SCS_OPERMODE_REHEARSAL
        ProcedureReturn @\mtGrdCuesInfoRehearsal
      Case #SCS_OPERMODE_PERFORMANCE
        ProcedureReturn @\mtGrdCuesInfoPerformance
    EndSelect
    ProcedureReturn #Null
  EndWith
EndProcedure

; Set the source mode for undo operations based on the target mode
Procedure WOP_setUndoSourceMode(nTargetMode, nSourceMode)
  With grWOP 
    Select nTargetMode
      Case #SCS_OPERMODE_DESIGN
        \nUndoSourceModeDesign = nSourceMode
        \bUndoDataAvailableDesign = #True
      Case #SCS_OPERMODE_REHEARSAL
        \nUndoSourceModeRehearsal = nSourceMode
        \bUndoDataAvailableRehearsal = #True
      Case #SCS_OPERMODE_PERFORMANCE
        \nUndoSourceModePerformance = nSourceMode
        \bUndoDataAvailablePerformance = #True
    EndSelect
  EndWith
EndProcedure

; Clear the undo data for the specified mode
Procedure WOP_clearUndoData(nMode)
  With grWOP
    Select nMode
      Case #SCS_OPERMODE_DESIGN
        \nUndoSourceModeDesign = -1
        \bUndoDataAvailableDesign = #False
      Case #SCS_OPERMODE_REHEARSAL
        \nUndoSourceModeRehearsal = -1
        \bUndoDataAvailableRehearsal = #False
      Case #SCS_OPERMODE_PERFORMANCE
        \nUndoSourceModePerformance = -1
        \bUndoDataAvailablePerformance = #False
    EndSelect
  EndWith
EndProcedure

; Get the source mode for undo operations based on the target mode
Procedure WOP_getUndoSourceMode(nMode)
  With grWOP
    Select nMode
      Case #SCS_OPERMODE_DESIGN
        ProcedureReturn \nUndoSourceModeDesign
      Case #SCS_OPERMODE_REHEARSAL
        ProcedureReturn \nUndoSourceModeRehearsal
      Case #SCS_OPERMODE_PERFORMANCE
        ProcedureReturn \nUndoSourceModePerformance
    EndSelect
    ProcedureReturn -1
  EndWith
EndProcedure

; Check if undo data is available for the specified mode
Procedure WOP_isUndoDataAvailable(nMode)
  With grWOP
  Select nMode
    Case #SCS_OPERMODE_DESIGN
      ProcedureReturn \bUndoDataAvailableDesign
    Case #SCS_OPERMODE_REHEARSAL
      ProcedureReturn \bUndoDataAvailableRehearsal
    Case #SCS_OPERMODE_PERFORMANCE
      ProcedureReturn \bUndoDataAvailablePerformance
  EndSelect
  ProcedureReturn #False
  EndWith
EndProcedure

Procedure WOP_updateUndoButtonStates()
  PROCNAMEC()
  Protected nCurrentMode.i
  
  nCurrentMode = grWOP\nNodeOperMode
  
  ; Enable undo button only if undo data is available for current mode
  If WOP_isUndoDataAvailable(nCurrentMode)
    DisableGadget(WOP\btnUndoModeSettings, #False)
  Else
    DisableGadget(WOP\btnUndoModeSettings, #True)
  EndIf
EndProcedure

Procedure WOP_gridSettingsMatch(nCurrentMode, nSelectedMode)
  PROCNAMEC()
  Protected i

  ; Check basic structure members first
  With mrOperModeOptions(nCurrentMode)\rGrdCuesInfo
    If \nMaxColNo <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\nMaxColNo
      ProcedureReturn #False
    EndIf
    If \sLayoutString <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\sLayoutString
      ProcedureReturn #False
    EndIf
    
    ; Check each column's settings
    For i = 0 To \nMaxColNo
      If \aCol(i)\nCurWidth <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\aCol(i)\nCurWidth Or
         \aCol(i)\nCurColNo <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\aCol(i)\nCurColNo Or
         \aCol(i)\bColVisible <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\aCol(i)\bColVisible Or
         \aCol(i)\nCurColOrder <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\aCol(i)\nCurColOrder Or
         \aCol(i)\sTitle <> mrOperModeOptions(nSelectedMode)\rGrdCuesInfo\aCol(i)\sTitle
        ProcedureReturn #False
      EndIf
    Next i
  EndWith

  ProcedureReturn #True
EndProcedure

Procedure WOP_copyGridInfo(*sourceGridInfo.tyGridInfo, *targetGridInfo.tyGridInfo)
  PROCNAMEC()
  Protected i
  
  If *sourceGridInfo = #Null Or *targetGridInfo = #Null
    ProcedureReturn
  EndIf
  
  ; Copy basic structure members
  *targetGridInfo\nGadgetNo = *sourceGridInfo\nGadgetNo
  *targetGridInfo\nMaxColNo = *sourceGridInfo\nMaxColNo
  *targetGridInfo\nMaxVisibleColNo = *sourceGridInfo\nMaxVisibleColNo
  *targetGridInfo\sLayoutString = *sourceGridInfo\sLayoutString
  
  ; Resize target array to match source
  ReDim *targetGridInfo\aCol(*sourceGridInfo\nMaxColNo)
  
  ; Copy each column structure
  For i = 0 To *sourceGridInfo\nMaxColNo
    *targetGridInfo\aCol(i) = *sourceGridInfo\aCol(i)
  Next i
EndProcedure

Procedure WOP_populateCopyModeSettingsCombo()
  PROCNAMEC()
  With WOP
    ; Clear existing items
    ClearGadgetItems(\cboCopyModeSettings)

    AddGadgetItemWithData(\cboCopyModeSettings, "", -1)

    ; Get the selected mode and populate the combobox fields
    If grWOP\nNodeOperMode = #SCS_OPERMODE_PERFORMANCE
      AddGadgetItemWithData(\cboCopyModeSettings, decodeOperModeL(#SCS_OPERMODE_DESIGN), #SCS_OPERMODE_DESIGN)
      AddGadgetItemWithData(\cboCopyModeSettings, decodeOperModeL(#SCS_OPERMODE_REHEARSAL), #SCS_OPERMODE_REHEARSAL)
    ElseIf grWOP\nNodeOperMode = #SCS_OPERMODE_REHEARSAL
      AddGadgetItemWithData(\cboCopyModeSettings, decodeOperModeL(#SCS_OPERMODE_DESIGN), #SCS_OPERMODE_DESIGN)
      AddGadgetItemWithData(\cboCopyModeSettings, decodeOperModeL(#SCS_OPERMODE_PERFORMANCE), #SCS_OPERMODE_PERFORMANCE)
    Else
      AddGadgetItemWithData(\cboCopyModeSettings, decodeOperModeL(#SCS_OPERMODE_REHEARSAL), #SCS_OPERMODE_REHEARSAL)
      AddGadgetItemWithData(\cboCopyModeSettings, decodeOperModeL(#SCS_OPERMODE_PERFORMANCE), #SCS_OPERMODE_PERFORMANCE)
    EndIf
  EndWith
EndProcedure

Procedure WOP_cboCopyModeSettings_Click()
  PROCNAMEC()
  Protected nCurrentMode, nSelectedMode

  nCurrentMode = grWOP\nNodeOperMode
  nSelectedMode = getCurrentItemData(WOP\cboCopyModeSettings)
  
  ; Check if the current mode's grid settings already match the selected mode's settings
  If nSelectedMode <> -1 And WOP_gridSettingsMatch(nCurrentMode, nSelectedMode)
    DisableGadget(WOP\btnCopyModeSettings, #True)
    ProcedureReturn
  EndIf
  
  ; Enable the Copy button if a mode is selected
  If nSelectedMode <> -1
    DisableGadget(WOP\btnCopyModeSettings, #False)
  Else
    DisableGadget(WOP\btnCopyModeSettings, #True)
  EndIf
EndProcedure

Procedure WOP_btnCopyModeSettings_Click()
  PROCNAMEC()
  Protected nCurrentMode, nSelectedMode, i
  Protected *undoData.tyGridInfo
  
  nCurrentMode = grWOP\nNodeOperMode
  nSelectedMode = getCurrentItemData(WOP\cboCopyModeSettings)

  ; Verify if there is undo data available for the current mode
  *undoData = WOP_getUndoDataStructure(nCurrentMode)
  If *undoData = #Null
    ProcedureReturn
  EndIf

  ; Check if the current mode's grid settings already match the selected mode's settings
  If WOP_gridSettingsMatch(nCurrentMode, nSelectedMode)
    ProcedureReturn
  EndIf

  ; Store the current mode settings for undo functionality (saves the current grid state in a buffer)
  WOP_copyGridInfo(@mrOperModeOptions(nCurrentMode)\rGrdCuesInfo, *undoData)

  ; Copy the grid column settings from the selected mode to the current mode
  WOP_copyGridInfo(@mrOperModeOptions(nSelectedMode)\rGrdCuesInfo, @mrOperModeOptions(nCurrentMode)\rGrdCuesInfo)
  
  ; Repopulate the grid and update UI
  WOP_populateGrdCueListCols()
  WOP_setOptionsChanged()
  WMN_setupGrid()
  populateGrid()

  WOP_setUndoSourceMode(nCurrentMode, nSelectedMode)
  
  ; Update button states
  DisableGadget(WOP\btnCopyModeSettings, #True)
  WOP_updateUndoButtonStates()
EndProcedure

Procedure WOP_btnUndoModeSettings_Click()
  PROCNAMEC()
  Protected i
  Protected nCurrentMode
  Protected *undoData.tyGridInfo

  nCurrentMode = grWOP\nNodeOperMode

  ; Verify undo data is available for this mode
  If WOP_isUndoDataAvailable(nCurrentMode) = #False
    debugMsg(sProcName, "No undo data available for current mode: " + Str(nCurrentMode))
    ProcedureReturn
  EndIf

  ; Get the appropriate undo data structure
  *undoData = WOP_getUndoDataStructure(nCurrentMode)
  If *undoData = #Null
    ProcedureReturn
  EndIf
  
  ; Import the undo data back into the current mode
  WOP_copyGridInfo(*undoData, @mrOperModeOptions(nCurrentMode)\rGrdCuesInfo)

  ; Clear undo data for this mode after successful undo
  WOP_clearUndoData(nCurrentMode)

  ; Repopulate the grid and update UI
  WOP_populateGrdCueListCols()
  WOP_setOptionsChanged()
  WMN_setupGrid()
  populateGrid()
  
  ; Update button states
  WOP_updateCopyButtonStates()
  WOP_updateUndoButtonStates()
EndProcedure

Procedure WOP_btnResetUserColumn1_Click()
  SGT(WOP\txtUserColumn1, gsUsercolumnOriginal1)
  WOP_setOptionsChanged()
  grWOP\mbChanges = #True
  gnUserColumnReset1 = #True
  gnuserColumnChanged1 = #True
EndProcedure

Procedure WOP_btnResetUserColumn2_Click()
  SGT(WOP\txtUserColumn2, gsUsercolumnOriginal2)
  WOP_setOptionsChanged()
  grWOP\mbChanges = #True
  gnUserColumnReset2 = #True
  gnuserColumnChanged2 = #True
EndProcedure

Procedure WOP_grdShortcuts_CurCellChange()
  PROCNAMEC()
  Protected nRow
  
  nRow = GGS(WOP\grdShortcuts)
  ; debugMsg(sProcName, "calling WOP_displayShortcuts(" + nRow + ")")
  WOP_displayShortcuts(nRow)
  SAG(WOP\shcSelectShortcut)
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_optPlaybackbuf_Click()
  With mrDriverSettings
    If GGS(WOP\optPlaybackbuf[0])
      \sPlaybackBufOption = "Default"
    Else
      \sPlaybackBufOption = "User"
    EndIf
  EndWith
  WOP_fcPlaybackBufOption()
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_optBASSMixer_Click()
  With mrDriverSettings
    If GGS(WOP\optBASSMixer[1])
      \bUseBASSMixer = #True
    Else
      \bUseBASSMixer = #False
    EndIf
    grWOP\mbChanges = #True
    WOP_setDefaultsInCaptions()
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_cboTimeFormat_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)

  Select GGS(WOP\cboTimeFormat)
    Case 0
      mrGeneralOptions\sTimeFormat = "A"
      mrGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A
    Case 1
      mrGeneralOptions\sTimeFormat = "B"
      mrGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
    Case 2
      mrGeneralOptions\sTimeFormat = "C"
      mrGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_C
  EndSelect
  debugMsg(sProcName, "mrGeneralOptions\sTimeFormat=" + mrGeneralOptions\sTimeFormat)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_optUpdatePeriod_Click()
  With mrDriverSettings
    If GGS(WOP\optUpdatePeriod[0])
      \sUpdatePeriodOption = "Default"
    Else
      \sUpdatePeriodOption = "User"
    EndIf
  EndWith
  WOP_fcUpdatePeriodOption()
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_txtMaxPreOpenAudioFiles_Change()
  PROCNAMEC()
  Protected sTmp.s, nTmp
  
  ; debugMsg(sProcName, #SCS_START)
  
  sTmp = Trim(GGT(WOP\txtMaxPreOpenAudioFiles))
  ; debugMsg(sProcName, "txtMaxPreOpenAudioFiles=" + sTmp)
  
  With mrGeneralOptions
    nTmp = Val(sTmp)
    If nTmp <> \nMaxPreOpenAudioFiles
      If nTmp < 2
        nTmp = 2
      ElseIf nTmp > gnMaxPreOpenAudioFilesForLicLevel
        nTmp = gnMaxPreOpenAudioFilesForLicLevel
      EndIf
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtMaxPreOpenVideoImageFiles_Change()
  PROCNAMEC()
  Protected sTmp.s, nTmp
  
  ; debugMsg(sProcName, #SCS_START)
  
  sTmp = Trim(GGT(WOP\txtMaxPreOpenVideoImageFiles))
  ; debugMsg(sProcName, "txtMaxPreOpenVideoImageFiles=" + sTmp)
  
  With mrGeneralOptions
    nTmp = Val(sTmp)
    If nTmp <> \nMaxPreOpenVideoImageFiles
      If nTmp < 2
        nTmp = 2
      ElseIf nTmp > gnMaxPreOpenVideoImageFilesForLicLevel
        nTmp = gnMaxPreOpenVideoImageFilesForLicLevel
      EndIf
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_btnApply_Click()
  PROCNAMEC()
  If WOP_validateAudioDriverTab() = #False
    ProcedureReturn
  EndIf
  debugMsg(sProcName, "calling applyChanges")
  WOP_applyChanges()
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_btnBrowse_Click()
  Protected sMyPath.s, sInitialPath.s
  
  With mrGeneralOptions
    sInitialPath = \sInitDir
    If Len(sInitialPath) = 0
      sInitialPath = "C:\"
    EndIf
    sMyPath = PathRequester(Lang("WOP", "btnBrowseDialog"), sInitialPath)
    If Len(sMyPath) > 0
      \sInitDir = sMyPath
      SGT(WOP\txtInitDir, \sInitDir)
    EndIf
    If \sInitDir <> grGeneralOptions\sInitDir
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_btnAudioEditorBrowse_Click()
  Protected sMyFile.s, sMyExtension.s, sMyPath.s, sInitialPath.s, sFilePathname.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  With mrEditingOptions
    sInitialPath = \sAudioEditor
    sFilePathname = OpenFileRequester("Audio Editor", "", "EXE|*.exe", 0)
    sMyFile = GetFilePart(sFilePathname)
    sMyPath = GetPathPart(sFilePathname)
    sMyExtension = GetExtensionPart(sMyFile)
    COND_OPEN_PREFS("Editing")

    If Len(sMyPath) > 0 And "exe" = sMyExtension
      SGT(WOP\txtAudioEditor, sFilePathname)
      WritePreferenceString("AudioEditor", sFilePathname)
    EndIf
    COND_CLOSE_PREFS()
    If sFilePathname <> \sAudioEditor
      \sAudioEditor = sFilePathname
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_btnImageEditorBrowse_Click()
  Protected sMyFile.s, sMyExtension.s, sMyPath.s, sInitialPath.s, sFilePathname.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  With mrEditingOptions
    sInitialPath = \sImageEditor
    sFilePathname = OpenFileRequester("Image Editor", "", "EXE|*.exe", 0)
    sMyFile = GetFilePart(sFilePathname)
    sMyPath = GetPathPart(sFilePathname)
    sMyExtension = GetExtensionPart(sMyFile)
    COND_OPEN_PREFS("Editing")

    If Len(sMyPath) > 0 And "exe" = sMyExtension
      SGT(WOP\txtImageEditor, sFilePathname)
      WritePreferenceString("ImageEditor", sFilePathname)
    EndIf
    COND_CLOSE_PREFS()
    If sFilePathname <> \sImageEditor
      \sImageEditor = sFilePathname
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_btnVideoEditorBrowse_Click()
  Protected sMyFile.s, sMyExtension.s, sMyPath.s, sInitialPath.s, sFilePathname.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  With mrEditingOptions
    sInitialPath = \sVideoEditor
    sFilePathname = OpenFileRequester("Video Editor", "", "EXE|*.exe", 0)
    sMyFile = GetFilePart(sFilePathname)
    sMyPath = GetPathPart(sFilePathname)
    sMyExtension = GetExtensionPart(sMyFile)
    COND_OPEN_PREFS("Editing")

    If Len(sMyPath) > 0 And "exe" = sMyExtension
      SGT(WOP\txtVideoEditor, sFilePathname)
      WritePreferenceString("VideoEditor", sFilePathname)
    EndIf
    COND_CLOSE_PREFS()
    If sFilePathname <> \sVideoEditor
      \sVideoEditor = sFilePathname
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_btnBrowseAudioFilesRootFolder_Click()
  Protected sMyPath.s, sInitialPath.s
  
  sInitialPath = grDriverSettings\sAudioFilesRootFolder
  If Len(sInitialPath) = 0
    sInitialPath = "C:\"
  EndIf
  sMyPath = PathRequester(Lang("WOP", "btnBrowseRootDialog"), sInitialPath)
  If Len(sMyPath) > 0
    mrDriverSettings\sAudioFilesRootFolder = sMyPath
    SGT(WOP\txtAudioFilesRootFolder, mrDriverSettings\sAudioFilesRootFolder)
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndIf
EndProcedure

Procedure WOP_btnCancel_Click()
  grWOP\mbChanges = #False   ; prevents asking if changes are to be saved
  WOP_Form_Unload()
EndProcedure

Procedure WOP_btnHelp_Click()
  displayHelpTopic("scs_options.htm")
EndProcedure

Procedure WOP_btnOK_Click()
  PROCNAMEC()
  
  If WOP_validateGeneralTab() = #False
    ProcedureReturn
  EndIf
  If WOP_validateAudioDriverTab() = #False
    ProcedureReturn
  EndIf

  debugMsg(sProcName, "mbChanges=" + strB(grWOP\mbChanges))
  If grWOP\mbChanges
    grWOP\mbChangesOK = #False
    WOP_applyChanges()
    If grWOP\mbChangesOK
      WOP_Form_Unload()
    EndIf
  Else
    WOP_Form_Unload()
  EndIf
EndProcedure

Procedure WOP_displayFontInfo()
  PROCNAMEC()
  Protected nFontSize
  Protected sSCSDfltFontInfo.s
  Protected sDfltFont.s
  Protected bEnableSCSDfltFont
  Protected sSampleFontName.s, nSampleFontSizeCueList, nSampleFontSizeMain, nSampleFontSizeOthers
  
  With mrGeneralOptions
    nFontSize = Round(gnSCSDfltFontSize * gdFontScale, #PB_Round_Down)
    sSCSDfltFontInfo = gsSCSDfltFontName + ", " + nFontSize
    
    sSampleFontName = gsSCSDfltFontName
    nSampleFontSizeMain = Round(gnSCSDfltFontSize * gfMainOrigYFactor * gdFontScale, #PB_Round_Down)
    nSampleFontSizeCueList = mrOperModeOptions(gnOperMode)\nCueListFontSize
    If nSampleFontSizeCueList <= 0
      nSampleFontSizeCueList = nSampleFontSizeMain
    EndIf
    nSampleFontSizeOthers = Round(gnSCSDfltFontSize * gdFontScale, #PB_Round_Down)
    
    If \sDfltFontName
      sDfltFont = \sDfltFontName + ", " + \nDfltFontSize
      If \sDfltFontName <> gsSCSDfltFontName Or \nDfltFontSize <> nFontSize
        bEnableSCSDfltFont = #True
        sSampleFontName = \sDfltFontName
        nSampleFontSizeMain = Round(\nDfltFontSize * gfMainOrigYFactor * gdFontScale, #PB_Round_Down)
        nSampleFontSizeCueList = mrOperModeOptions(gnOperMode)\nCueListFontSize
        If nSampleFontSizeCueList <= 0
          nSampleFontSizeCueList = nSampleFontSizeMain
        EndIf
        nSampleFontSizeOthers = Round(\nDfltFontSize * gdFontScale, #PB_Round_Down)
      EndIf
    Else
      sDfltFont = sSCSDfltFontInfo
    EndIf
    SGT(WOP\btnDfltFont, sDfltFont)
    
    SGT(WOP\btnUseSCSDfltFont, LangPars("WOP", "chkUseSCSDfltFont", sSCSDfltFontInfo))
    setEnabled(WOP\btnUseSCSDfltFont, bEnableSCSDfltFont)
    
    LoadFont(#SCS_FONT_WOP_SAMPLE_CUE_LIST, sSampleFontName, nSampleFontSizeCueList)
    scsSetGadgetFont(WOP\lblFontSampleCueList, #SCS_FONT_WOP_SAMPLE_CUE_LIST)
    LoadFont(#SCS_FONT_WOP_SAMPLE_MAIN, sSampleFontName, nSampleFontSizeMain)
    scsSetGadgetFont(WOP\lblFontSampleMain, #SCS_FONT_WOP_SAMPLE_MAIN)
    LoadFont(#SCS_FONT_WOP_SAMPLE_OTHERS, sSampleFontName, nSampleFontSizeOthers)
    scsSetGadgetFont(WOP\lblFontSampleOthers, #SCS_FONT_WOP_SAMPLE_OTHERS)
    
  EndWith
  
EndProcedure

Procedure WOP_btnDfltFont_Click()
  PROCNAMEC()
  Protected nResult
  Protected sDfltFontName.s, nDfltFontSize
  
  With mrGeneralOptions
    If Len(\sDfltFontName) > 0
      sDfltFontName = \sDfltFontName
      nDfltFontSize = \nDfltFontSize
    Else
      ; \sDfltFontName = gsSCSDfltFontName
      ; \nDfltFontSize = Round(gnSCSDfltFontSize * gdFontScale, #PB_Round_Down)
      sDfltFontName = gsSCSDfltFontName
      nDfltFontSize = gnSCSDfltFontSize
    EndIf
    nResult = FontRequester(sDfltFontName, nDfltFontSize, 0)
    If nResult
      \sDfltFontName = SelectedFontName()
      \nDfltFontSize = SelectedFontSize()
      debugMsg(sProcName, "selected font " + \sDfltFontName + ", size " + Str(\nDfltFontSize))
      WOP_displayFontInfo()
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_btnUseSCSDfltFont_Click()
  PROCNAMEC()
  
  With mrGeneralOptions
    \sDfltFontName = gsSCSDfltFontName
    \nDfltFontSize = Round(gnSCSDfltFontSize * gdFontScale, #PB_Round_Down)
    debugMsg(sProcName, "selected font " + \sDfltFontName + ", size " + Str(\nDfltFontSize))
    WOP_displayFontInfo()
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndWith
EndProcedure

Procedure WOP_displayOperMode()
  PROCNAMEC()
  
  SGT(WOP\lblCurrOperMode[1], decodeOperModeL(grWOP\nCurrOperMode))
  If grWOP\nCurrOperMode = #SCS_OPERMODE_PERFORMANCE
    SetGadgetColor(WOP\lblCurrOperMode[1], #PB_Gadget_BackColor, #SCS_Blue)
    SetGadgetColor(WOP\lblCurrOperMode[1], #PB_Gadget_FrontColor, #SCS_White)
  ElseIf grWOP\nCurrOperMode = #SCS_OPERMODE_REHEARSAL
    SetGadgetColor(WOP\lblCurrOperMode[1], #PB_Gadget_BackColor, #SCS_Orange)
    SetGadgetColor(WOP\lblCurrOperMode[1], #PB_Gadget_FrontColor, #SCS_Dark_Grey)
  Else
    SetGadgetColor(WOP\lblCurrOperMode[1], #PB_Gadget_BackColor, #SCS_Green)
    SetGadgetColor(WOP\lblCurrOperMode[1], #PB_Gadget_FrontColor, #SCS_Dark_Grey)
  EndIf
  SGS(WOP\cboChangeOperMode, 0) ; set this to the "Select..." item
  
EndProcedure

Procedure WOP_Form_Show(bModal, nParentWindow, nFirstNode=0)
  PROCNAMEC()
  Protected sName.s, sHexValue.s, sTmp.s
  Protected nListIndex, nTimeFormatIndex
  Protected m, n, nColNo
  Protected nLeft, nHeight
  Protected sFontSizes.s, sOneFontSize.s, nOneFontSize, nFontSizeCount
  Protected sPanelHeights.s, sOnePanelHeight.s, nPanelHeightCount
  Protected nNodeIndex
  Protected sSamples.s, sMilliseconds.s, sScreen.s
  Protected sMinutes.s, sSeconds.s
  Protected nIPAddr, nCount, bResult
  Protected sNormal.s, sBold.s, sDefault.s
  Protected nMaxWidth
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WOP) = #False
    createfmOptions(nParentWindow)
  EndIf
  setWindowModal(#WOP, bModal)
  setFormPosition(#WOP, @grOptionsWindow)
  
  ;=============================================
  ; set module variables at their default values
  grWOP\mbChanges = #False
  grWOP\mbChangesOK = #False
  grWOP\mbReloadGrid = #False
  grWOP\bLoadingOptionsForm = #False
  grWOP\bGrdShortcutsSetup = #False
  ;=============================================

  grWOP\bLoadingOptionsForm = #True
  grWOP\bInFrmOptionsLoad = #True

  grWOP\mbReloadGrid = #False
  
  ; call updateGridInfoFromPhysicalLayout() for main grid now because even if user cancels, WMN_setupGrid() will rebuild the main grid on exiting
  updateGridInfoFromPhysicalLayout(@grOperModeOptions(gnOperMode)\rGrdCuesInfo)
  
  gbInOptionsWindow = #True
  
  grWOP\bEditorAndOptionsLocked = gbEditorAndOptionsLocked
  grWOP\nCurrOperMode = gnOperMode
  For n = 0 To #SCS_OPERMODE_LAST
    mrOperModeOptions(n) = grOperModeOptions(n)
  Next n
  
  mrDriverSettings = grDriverSettings
  mrGeneralOptions = grGeneralOptions
  mrEditingOptions = grEditingOptions
  mrSession = grSession
  mrVideoDriver = grVideoDriver
  mrRAIOptions = grRAIOptions
  mrFMOptions = grFMOptions
  CompilerIf #c_blackmagic_card_support
    mrCurrScreenVideoRenderers = grCurrScreenVideoRenderers
  CompilerEndIf
  
  ; editor cue font constants
  sNormal = " " + Lang("Common", "Normal")
  sBold = " " + Lang("Common", "Bold")
  sDefault = " (" + Lang("Common", "Default") + ")"
  
  With WOP
    
    ; Operational Mode
    ClearGadgetItems(\cboChangeOperMode)
    addGadgetItemWithData(\cboChangeOperMode, LangEllipsis("WOP", "SelectOperMode"), -1)
    addGadgetItemWithData(\cboChangeOperMode, Lang("OperMode", "Design"), #SCS_OPERMODE_DESIGN)
    addGadgetItemWithData(\cboChangeOperMode, Lang("OperMode", "Rehearsal"), #SCS_OPERMODE_REHEARSAL)
    addGadgetItemWithData(\cboChangeOperMode, Lang("OperMode", "Performance"), #SCS_OPERMODE_PERFORMANCE)
    
    ; INFO: General Options
    ClearGadgetItems(\cboDoubleClick)
    ; data value is time in milliseconds
    addGadgetItemWithData(\cboDoubleClick, "0.0 seconds (" + Lang("WOP", "DoubleClick") + ")", 0)
    addGadgetItemWithData(\cboDoubleClick, "0.1 second", 100)
    addGadgetItemWithData(\cboDoubleClick, "0.2 second", 200)
    addGadgetItemWithData(\cboDoubleClick, "0.3 second", 300)
    addGadgetItemWithData(\cboDoubleClick, "0.4 second (" + Lang("WOP", "DfltSetting") + ")", 400)
    addGadgetItemWithData(\cboDoubleClick, "0.5 second", 500)
    addGadgetItemWithData(\cboDoubleClick, "0.6 second", 600)
    addGadgetItemWithData(\cboDoubleClick, "0.7 second", 700)
    addGadgetItemWithData(\cboDoubleClick, "0.8 second", 800)
    addGadgetItemWithData(\cboDoubleClick, "0.9 second", 900)
    addGadgetItemWithData(\cboDoubleClick, "1.0 second", 1000)
    setComboBoxWidth(\cboDoubleClick)
    
    ClearGadgetItems(\cboFadeAllTime)
    ; data value is time in milliseconds
    addGadgetItemWithData(\cboFadeAllTime, "0.25 second", 250)
    addGadgetItemWithData(\cboFadeAllTime, "0.50 second", 500)
    addGadgetItemWithData(\cboFadeAllTime, "0.75 second", 750)
    addGadgetItemWithData(\cboFadeAllTime, "1.00 second (" + Lang("WOP", "DfltSetting") + ")", 1000)
    addGadgetItemWithData(\cboFadeAllTime, "1.25 seconds", 1250)
    addGadgetItemWithData(\cboFadeAllTime, "1.50 seconds", 1500)
    addGadgetItemWithData(\cboFadeAllTime, "1.75 seconds", 1750)
    addGadgetItemWithData(\cboFadeAllTime, "2.0 seconds", 2000)
    ; Added 8May2022 11.9.2
    addGadgetItemWithData(\cboFadeAllTime, "2.5 seconds", 2500)
    addGadgetItemWithData(\cboFadeAllTime, "3.0 seconds", 3000)
    addGadgetItemWithData(\cboFadeAllTime, "3.5 seconds", 3500)
    addGadgetItemWithData(\cboFadeAllTime, "4.0 seconds", 4000)
    addGadgetItemWithData(\cboFadeAllTime, "4.5 seconds", 4500)
    addGadgetItemWithData(\cboFadeAllTime, "5.0 seconds", 5000)
    setComboBoxWidth(\cboFadeAllTime)
    ; End added 8May2022 11.9.2
    
    ClearGadgetItems(\cboTimeFormat)
    ; NB using 'optTimeFormat[]' Lang items in the following as option buttons were originally used.
    ; These were changed to a combobox in SCS 11.10.0 to save space on the General options screen.
    addGadgetItemWithData(\cboTimeFormat, Lang("WOP", "optTimeFormat[0]"), 0) ; "MMM:SS:NNN  Minutes:Seconds.Thousandths. Suppress minutes If time < 1 minute"
    addGadgetItemWithData(\cboTimeFormat, Lang("WOP", "optTimeFormat[1]"), 1) ; "MMM:SS:NNN  Minutes:Seconds.Thousandths. Always display minutes"
    addGadgetItemWithData(\cboTimeFormat, Lang("WOP", "optTimeFormat[2]"), 2) ; "SSS.NNN  Seconds.Thousandths"
    nMaxWidth = GadgetWidth(\frTimeFormat) - GadgetX(\cboTimeFormat) - 6
    setComboBoxWidth(\cboTimeFormat, 80, #False, nMaxWidth)
    
    ClearGadgetItems(\cboLanguage)
    For n = 0 To (gnLanguageCount-1)
      addGadgetItemWithData(\cboLanguage, gaLanguage(n)\sLangName, n)
    Next n
    
    WOP_displayFontInfo()
    
    ; INFO: Display Options
    ; color scheme
    ClearGadgetItems(\cboColorScheme)
    For n = 0 To ArraySize(gaColorScheme())
      ; Debug sProcName + ": gaColorScheme(" + n + ")\sSchemeName=" + gaColorScheme(n)\sSchemeName
      If Len(gaColorScheme(n)\sSchemeName) > 0
        addGadgetItemWithData(\cboColorScheme, gaColorScheme(n)\sSchemeName, n)
      EndIf
    Next n
    
    ; cue list font size
    sFontSizes = #SCS_CUELIST_FONT_SIZES
    nFontSizeCount = CountString(sFontSizes, ",") + 1
    ClearGadgetItems(\cboCueListFontSize)
    addGadgetItemWithData(\cboCueListFontSize, Lang("Common", "Default"), -1)
    For n = 1 To nFontSizeCount
      sOneFontSize = StringField(sFontSizes, n, ",")
      nOneFontSize = Val(sOneFontSize)
      addGadgetItemWithData(\cboCueListFontSize, sOneFontSize, nOneFontSize)
    Next n
    
    ; cue panel height
    sPanelHeights = #SCS_CUEPANEL_HEIGHT
    nPanelHeightCount = CountString(sPanelHeights, ",") + 1
    ClearGadgetItems(\cboCuePanelHeight)
    For n = 1 To nPanelHeightCount
      sOnePanelHeight = StringField(sPanelHeights, n, ",")
      addGadgetItemWithData(\cboCuePanelHeight, sOnePanelHeight + "%", Val(sOnePanelHeight))
    Next n
    
    setComboBoxesWidth(-1, \cboCueListFontSize, \cboCuePanelHeight)
    nLeft = GadgetX(\cboCueListFontSize) + GadgetWidth(\cboCueListFontSize) + 12
    ResizeGadget(\lblCuePanelHeight, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    nLeft = GadgetX(\lblCuePanelHeight) + GadgetWidth(\lblCuePanelHeight) + gnGap
    ResizeGadget(\cboCuePanelHeight, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    
    ClearGadgetItems(\cboCtrlPanelPos)
    addGadgetItemWithData(\cboCtrlPanelPos, Lang("WOP", "ctrlPanelTop"),#SCS_CTRLPANEL_TOP)
    addGadgetItemWithData(\cboCtrlPanelPos, Lang("WOP", "ctrlPanelBottom"),#SCS_CTRLPANEL_BOTTOM)
    addGadgetItemWithData(\cboCtrlPanelPos, Lang("WOP", "ctrlPanelNone"),#SCS_CTRLPANEL_NONE)
    
    ClearGadgetItems(\cboToolbarInfo)
    addGadgetItemWithData(\cboToolbarInfo, Lang("WOP", "ToolbarAll"), #SCS_TOOL_DISPLAY_ALL)
    addGadgetItemWithData(\cboToolbarInfo, Lang("WOP", "ToolbarMin2"), #SCS_TOOL_DISPLAY_MIN)
    addGadgetItemWithData(\cboToolbarInfo, Lang("WOP", "ToolbarNone"), #SCS_TOOL_DISPLAY_NONE)
    
    ClearGadgetItems(\cboVUDisplay)
    addGadgetItemWithData(\cboVUDisplay, Lang("WOP", "VisModeLevels"), #SCS_VU_LEVELS)
    addGadgetItemWithData(\cboVUDisplay, Lang("WOP", "VisModeNone"), #SCS_VU_NONE)
    setComboBoxesWidth(-1, \cboCtrlPanelPos, \cboToolbarInfo, \cboVUDisplay)
    
    ClearGadgetItems(\cboMonitorSize)
    addGadgetItemWithData(\cboMonitorSize, decodeMonitorSizeL(#SCS_MON_NONE), #SCS_MON_NONE)
    addGadgetItemWithData(\cboMonitorSize, decodeMonitorSizeL(#SCS_MON_SMALL), #SCS_MON_SMALL)
    addGadgetItemWithData(\cboMonitorSize, decodeMonitorSizeL(#SCS_MON_STD), #SCS_MON_STD)
    addGadgetItemWithData(\cboMonitorSize, decodeMonitorSizeL(#SCS_MON_LARGE), #SCS_MON_LARGE)
    setComboBoxWidth(\cboMonitorSize)
    nLeft = GadgetX(\cboMonitorSize) + GadgetWidth(\cboMonitorSize) + 20
    If nLeft > GadgetX(\chkShowToolTips)
      ResizeGadget(\chkShowToolTips, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\chkAllowDisplayTimeout, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\chkDisplayAllMidiIn, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\lblMidiInDisplayTimeout, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Added 8Jul2024 11.10.3as
      ResizeGadget(\cboMidiInDisplayTimeout, (nLeft + GadgetWidth(\lblMidiInDisplayTimeout) + gnGap), #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Added 8Jul2024 11.10.3as
    EndIf
    
    ClearGadgetItems(\cboMTCDispLocn)
    addGadgetItemWithData(\cboMTCDispLocn, decodeMTCDispLocnL(#SCS_MTC_DISP_VU_METERS), #SCS_MTC_DISP_VU_METERS)
    addGadgetItemWithData(\cboMTCDispLocn, decodeMTCDispLocnL(#SCS_MTC_DISP_SEPARATE_WINDOW), #SCS_MTC_DISP_SEPARATE_WINDOW)
    
    ClearGadgetItems(\cboTimerDispLocn)
    addGadgetItemWithData(\cboTimerDispLocn, decodeTimerDispLocnL(#SCS_PTD_STATUS_LINE), #SCS_PTD_STATUS_LINE)
    addGadgetItemWithData(\cboTimerDispLocn, decodeTimerDispLocnL(#SCS_PTD_SEPARATE_WINDOW), #SCS_PTD_SEPARATE_WINDOW)
    setComboBoxesWidth(50, \cboMTCDispLocn, \cboTimerDispLocn)
    
    ; Deleted the following 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;     ClearGadgetItems(\cboMaxMonitor)
;     addGadgetItemWithData(\cboMaxMonitor, Lang("WOP","cboMaxMonitorMax"), -1) ; "Maximum available"
;     sScreen = Lang("WOP","cboMaxMonitorScr")                                  ; Screen $1
;     For n = 1 To ExamineDesktops()
;       addGadgetItemWithData(\cboMaxMonitor, ReplaceString(sScreen, "$1", Str(n)), n)
;     Next n
;     setComboBoxWidth(\cboMaxMonitor)
    
    sSeconds = Lang("Common", "Seconds")
    ClearGadgetItems(\cboMidiInDisplayTimeout)
    addGadgetItemWithData(\cboMidiInDisplayTimeout, "3 " + sSeconds, 3000)
    addGadgetItemWithData(\cboMidiInDisplayTimeout, "5 " + sSeconds, 5000)
    addGadgetItemWithData(\cboMidiInDisplayTimeout, "10 " + sSeconds, 10000)
    addGadgetItemWithData(\cboMidiInDisplayTimeout, Lang("Common", "Continuous"), -1)
    setComboBoxWidth(\cboMidiInDisplayTimeout)
    
    ; INFO: Cue List Columns
    WOP_populateGrdCueListCols()
    autoFitGridCol(\grdCueListCols, 0)
    
    ; Initialise the Undo Mode Settings variables
    grWOP\nUndoSourceModeDesign = -1
    grWOP\nUndoSourceModeRehearsal = -1
    grWOP\nUndoSourceModePerformance = -1
    grWOP\bUndoDataAvailableDesign = #False
    grWOP\bUndoDataAvailableRehearsal = #False
    grWOP\bUndoDataAvailablePerformance = #False
    
    setEnabled(WOP\btnCopyModeSettings, #False)
    setEnabled(WOP\btnUndoModeSettings, #False)
    
    ; INFO: Audio Driver Settings (DirectSound)
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      CompilerIf #cEnableASIOBufLen
        ClearGadgetItems(\cboAsioBufLen)
        addGadgetItemWithData(\cboAsioBufLen, Lang("WOP", "cboAsioBufLenPref"), #SCS_ASIOBUFLEN_PREF)
        addGadgetItemWithData(\cboAsioBufLen, Lang("WOP", "cboAsioBufLenMax"), #SCS_ASIOBUFLEN_MAX)
        sSamples = Lang("WOP", "cboAsioBufLenSamples")
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "128"), 128)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "256"), 256)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "384"), 384)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "512"), 512)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "768"), 768)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "1024"), 1024)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "2048"), 2048)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "3072"), 3072)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "4096"), 4096)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "5120"), 5120)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "6144"), 6144)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "7168"), 7168)
        addGadgetItemWithData(\cboAsioBufLen, ReplaceString(sSamples, "$1", "8192"), 8192)
      CompilerEndIf
      
      CompilerIf #cEnableFileBufLen
        ClearGadgetItems(\cboFileBufLen)
        addGadgetItemWithData(\cboFileBufLen, LangPars("WOP", "cboFileBufLenDflt", Str(#SCS_DEFAULT_FILEBUFLEN)), 0) ; nb 'data' for default = 0
        sMilliseconds = Lang("WOP", "cboFileBufLenMS")
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "500"), 500)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "1000"), 1000)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "1500"), 1500)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "2000"), 2000)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "2500"), 2500)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "3000"), 3000)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "4000"), 4000)
        addGadgetItemWithData(\cboFileBufLen, ReplaceString(sMilliseconds, "$1", "5000"), 5000)
      CompilerEndIf
      
    EndIf
    
    ; INFO: Video Driver Settings
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      ClearGadgetItems(\cboVideoLibrary)
      CompilerIf #c_include_tvg
        addGadgetItemWithData(\cboVideoLibrary, decodeVideoPlaybackLibraryL(#SCS_VPL_TVG), #SCS_VPL_TVG)
      CompilerEndIf
      CompilerIf #c_vMix_in_video_cues
        addGadgetItemWithData(\cboVideoLibrary, decodeVideoPlaybackLibraryL(#SCS_VPL_VMIX), #SCS_VPL_VMIX)
      CompilerEndIf
      If CountGadgetItems(\cboVideoLibrary) = 1
        setEnabled(\cboVideoLibrary, #False)
      EndIf
      CompilerIf #c_include_tvg
        ClearGadgetItems(\cboTVGPlayerHwAccel)
        addGadgetItemWithData(\cboTVGPlayerHwAccel, decodeTVGPlayerHwAccelL(#tvc_hw_None), #tvc_hw_None)
        addGadgetItemWithData(\cboTVGPlayerHwAccel, decodeTVGPlayerHwAccelL(#tvc_hw_Cuda), #tvc_hw_Cuda)
        addGadgetItemWithData(\cboTVGPlayerHwAccel, decodeTVGPlayerHwAccelL(#tvc_hw_QuickSync), #tvc_hw_QuickSync)
        addGadgetItemWithData(\cboTVGPlayerHwAccel, decodeTVGPlayerHwAccelL(#tvc_hw_Dxva2), #tvc_hw_Dxva2)
        addGadgetItemWithData(\cboTVGPlayerHwAccel, decodeTVGPlayerHwAccelL(#tvc_hw_d3d11), #tvc_hw_d3d11)
        setComboBoxWidth(\cboTVGPlayerHwAccel)
      CompilerEndIf
      
    EndIf
    
    ; INFO: Remote App Interface
    debugMsg(sProcName, "RAI")
    ClearGadgetItems(\cboRAIApp)
    addGadgetItemWithData(\cboRAIApp, "SCSremote", #SCS_RAI_APP_SCSREMOTE)
    addGadgetItemWithData(\cboRAIApp, "OSC App", #SCS_RAI_APP_OSC)
    setComboBoxWidth(\cboRAIApp)
    For n = 0 To #SCS_MAX_OSC_VER
      AddGadgetItemWithData(\cboRAIOSCVersion, decodeOSCVersionL(n), n)
    Next n
    setComboBoxWidth(\cboRAIOSCVersion)
    ClearGadgetItems(\cboRAINetworkProtocol)
    addGadgetItemWithData(\cboRAINetworkProtocol, "TCP", #SCS_NETWORK_PR_TCP)
    addGadgetItemWithData(\cboRAINetworkProtocol, "UDP", #SCS_NETWORK_PR_UDP)
    setComboBoxWidth(\cboRAINetworkProtocol)
    ClearGadgetItems(\cboRAILocalIPAddr)
    ; addGadgetItemWithData(\cboRAILocalIPAddr, Lang("Network", "AnyAvailable"), #False)
    ExamineIPAddresses() 
    Repeat
      nIPAddr = NextIPAddress()
      If nIPAddr = 0
        Break
      EndIf
      addGadgetItemWithData(\cboRAILocalIPAddr, IPString(nIPAddr), #True)
    ForEver
    setComboBoxWidth(\cboRAILocalIPAddr)
    nLeft = GadgetX(\cboRAILocalIPAddr) + GadgetWidth(\cboRAILocalIPAddr) + gnGap
    ResizeGadget(\btnRAIIPInfo, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    
    ; INFO: Functional Mode
    If (grLicInfo\nLicLevel >= #SCS_LIC_PLUS)
      debugMsg(sProcName, "FuncMode")
      ClearGadgetItems(\cboFMFunctionalMode)
      addGadgetItemWithData(\cboFMFunctionalMode, Lang("Common", "Stand-Alone"), #SCS_FM_STAND_ALONE)
      addGadgetItemWithData(\cboFMFunctionalMode, Lang("Common", "Primary"), #SCS_FM_PRIMARY)
      addGadgetItemWithData(\cboFMFunctionalMode, Lang("Common", "Backup"), #SCS_FM_BACKUP)
      setComboBoxWidth(\cboFMFunctionalMode)
      ClearGadgetItems(\cboFMLocalIPAddr)
      bResult = ExamineIPAddresses()
      debugMsg(sProcName, "ExamineIPAddresses() returned " + strB(bResult))
      If bResult
        nCount = -1
        Repeat
          nIPAddr = NextIPAddress()
          If nIPAddr = 0
            Break
          EndIf
          nCount + 1
          debugMsg(sProcName, "calling addGadgetItemWithData(\cboFMLocalIPAddr, " + #DQUOTE$ + IPString(nIPAddr) + #DQUOTE$ + ", " + nCount + ")")
          addGadgetItemWithData(\cboFMLocalIPAddr, IPString(nIPAddr), nCount)
        ForEver
      EndIf
      nLeft = GadgetX(\cboFMLocalIPAddr) + GadgetWidth(\cboFMLocalIPAddr) + gnGap
      ResizeGadget(\btnFMIPInfo, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
    
    ; INFO: Shortcuts
    debugMsg(sProcName, "shortcuts")
    CopyArray(gaShortcutsMain(), maShortcutsMain())
    CopyArray(gaShortcutsEditor(), maShortcutsEditor())
    
    ClearGadgetItems(\cboSampleRate)
    AddGadgetItem(\cboSampleRate, -1, "44100")
    AddGadgetItem(\cboSampleRate, -1, "48000")
    AddGadgetItem(\cboSampleRate, -1, "88200")
    AddGadgetItem(\cboSampleRate, -1, "96000")
    AddGadgetItem(\cboSampleRate, -1, "192000")
    
    ; INFO: Editing Options
    ClearGadgetItems(\cboFileScanMaxLengthAudio)
    ClearGadgetItems(\cboFileScanMaxLengthVideo)
    addGadgetItemWithData(\cboFileScanMaxLengthAudio, Lang("WOP", "NoDisplay"), 0)
    addGadgetItemWithData(\cboFileScanMaxLengthVideo, Lang("WOP", "NoDisplay"), 0)
    sMinutes = Lang("WOP", "minutes")
    For n = 5 To 30 Step 5
      addGadgetItemWithData(\cboFileScanMaxLengthAudio, ReplaceString(sMinutes,"$1",Str(n)), n)
      addGadgetItemWithData(\cboFileScanMaxLengthVideo, ReplaceString(sMinutes,"$1",Str(n)), n)
    Next n
    For n = 40 To 90 Step 10
      addGadgetItemWithData(\cboFileScanMaxLengthAudio, ReplaceString(sMinutes,"$1",Str(n)), n)
      addGadgetItemWithData(\cboFileScanMaxLengthVideo, ReplaceString(sMinutes,"$1",Str(n)), n)
    Next n
    addGadgetItemWithData(\cboFileScanMaxLengthAudio, Lang("WOP", "NoMaximum"), -1)
    addGadgetItemWithData(\cboFileScanMaxLengthVideo, Lang("WOP", "NoMaximum"), -1)
    setComboBoxesWidth(20, \cboFileScanMaxLengthAudio, \cboFileScanMaxLengthVideo)
    
    ClearGadgetItems(\cboEditorCueListFontSize)
    ; See also savePreferences() and WED_setEditorCueListFontSize()
    For n = 9 To 12
      sOneFontSize = Str(n) + sNormal
      nOneFontSize = 100 + n
      If nOneFontSize = 109 ; font size '9 Normal'
        sOneFontSize + sDefault
      EndIf
      addGadgetItemWithData(\cboEditorCueListFontSize, sOneFontSize, nOneFontSize)
      sOneFontSize = Str(n) + sBold
      nOneFontSize = n
      addGadgetItemWithData(\cboEditorCueListFontSize, sOneFontSize, nOneFontSize)
    Next n
    setComboBoxWidth(\cboEditorCueListFontSize)
    
  EndWith
  
  ; ================================== all controls populated
  
  WOP_displayOperMode()
  WOP_processEditorAndOptionsLocked()
  
  grWOP\mbChanges = #False
  WOP_setButtons()
  grWOP\bLoadingOptionsForm = #False

  If nFirstNode > 0
    nNodeIndex = grWOP\nNodeIndex[nFirstNode]
  Else
    nNodeIndex = 0
  EndIf
  SGS(WOP\tvwPrefTree, nNodeIndex)
  WOP_tvwPrefTree_NodeClick()
  
  grWOP\bInFrmOptionsLoad = #False
  
  setWindowVisible(#WOP, #True)
  SAW(#WOP)
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  Protected bValidationOK = #True
  
  debugMsg(sProcName, #SCS_START)
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WOP_valGadget(gnValidateGadgetNo)
    If bValidationOK = #False
      ProcedureReturn
    EndIf
  EndIf

  If grWOP\mbChanges
    nResponse = scsMessageRequester(GWT(#WOP), Lang("WOP", "SaveChanges?"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    If nResponse = #PB_MessageRequester_Cancel
      debugMsg(sProcName, "nResponse = Cancel")
      ProcedureReturn #False
      
    ElseIf nResponse = #PB_MessageRequester_Yes
      debugMsg(sProcName, "nResponse = Yes")
      
      If WOP_validateGeneralTab() = #False
        ProcedureReturn #False
      EndIf
      If WOP_validateAudioDriverTab() = #False
        ProcedureReturn #False
      EndIf
      WOP_applyChanges()
      
    EndIf
  EndIf
  
  getFormPosition(#WOP, @grOptionsWindow)
  unsetWindowModal(#WOP)
  scsCloseWindow(#WOP)
  
  gbInOptionsWindow = #False
  ; the following must be performed AFTER setting gbInOptionsWindow=#False so that settings are taken from grGeneralOptions,
  ; which will have been updated from mrGeneralOptions if changes were applied, or will be the pre-changed values if changes are discarded
  WMN_applyDisplayOptions()
  WMN_setupGrid()
  populateGrid()
  WED_setEditorCueListFontSize()
  
  ; gbCallLoadDispPanels = #True

  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_fcSMSOnThisMachine()
  PROCNAMEC()
  Protected bEnabled, sSMSHost.s, sSMSPort.s
  
  With mrDriverSettings
    If \bSMSOnThisMachine
      sSMSHost = "127.0.0.1"
      sSMSPort = "20000"
    Else
      sSMSHost = \sSMSHost
      sSMSPort = "20000"
      bEnabled = #True
    EndIf
    
    SGS(WOP\ipSMSHost, makeIPAddressFromString(sSMSHost))
    SGT(WOP\txtSMSPort, sSMSPort)
    
    setEnabled(WOP\ipSMSHost, bEnabled)
    setEnabled(WOP\txtSMSPort, #False)
    
  EndWith
  
EndProcedure

Procedure WOP_fcPlaybackBufOption()
  PROCNAMEC()
  With mrDriverSettings
    If \sPlaybackBufOption = "User"
      setEnabled(WOP\txtPlaybackBufLength, #True)
    Else
      setEnabled(WOP\txtPlaybackBufLength, #False)
    EndIf
    setTextBoxBackColor(WOP\txtPlaybackBufLength)
  EndWith
EndProcedure

Procedure WOP_fcUpdatePeriodOption()
  PROCNAMEC()
  With mrDriverSettings
    If \sUpdatePeriodOption = "User"
      setEnabled(WOP\txtUpdatePeriodLength, #True)
    Else
      setEnabled(WOP\txtUpdatePeriodLength, #False)
    EndIf
    setTextBoxBackColor(WOP\txtUpdatePeriodLength)
  EndWith
EndProcedure

Procedure WOP_populateCboVideoRenderer()
  PROCNAMEC()
  Protected nListIndex
  
  With WOP
    Select mrVideoDriver\nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          ClearGadgetItems(\cboVideoRenderer)
          addGadgetItemWithData(\cboVideoRenderer, decodeVideoRendererWithDefault(#SCS_VR_AUTOSELECT, #SCS_VPL_TVG), #SCS_VR_AUTOSELECT)
          addGadgetItemWithData(\cboVideoRenderer, decodeVideoRendererWithDefault(#SCS_VR_EVR, #SCS_VPL_TVG), #SCS_VR_EVR)
          addGadgetItemWithData(\cboVideoRenderer, decodeVideoRendererWithDefault(#SCS_VR_VMR9, #SCS_VPL_TVG), #SCS_VR_VMR9)
          addGadgetItemWithData(\cboVideoRenderer, decodeVideoRendererWithDefault(#SCS_VR_VMR7, #SCS_VPL_TVG), #SCS_VR_VMR7)
          addGadgetItemWithData(\cboVideoRenderer, decodeVideoRendererWithDefault(#SCS_VR_STANDARD, #SCS_VPL_TVG), #SCS_VR_STANDARD)
          addGadgetItemWithData(\cboVideoRenderer, decodeVideoRendererWithDefault(#SCS_VR_OVERLAY, #SCS_VPL_TVG), #SCS_VR_OVERLAY)
          setComboBoxWidth(\cboVideoRenderer) ; Added 16Dec2020 11.8.3.4aa
          nListIndex = indexForComboBoxData(\cboVideoRenderer, mrVideoDriver\nTVGVideoRenderer, 0)
          SGS(\cboVideoRenderer, nListIndex)
        CompilerEndIf
        
    EndSelect
    
  EndWith
EndProcedure

Procedure WOP_populateCboScreenVideoRenderer(nIndex)
  PROCNAMEC()
  Protected nDisplayNo, nScreenVideoRenderer, n, nArrayIndex
  Protected nGadgetNo, nListIndex
  
  nScreenVideoRenderer = #SCS_VR_AUTOSELECT
  nDisplayNo = mrVideoDriver\aSplitScreenInfo[nIndex]\nDisplayNo
  With mrCurrScreenVideoRenderers
    For n = 0 To \nMaxCurrScreenVideoRenderer
      If \aCurrScreenVideoRenderer(n)\nDisplayNo = nDisplayNo
        nScreenVideoRenderer = \aCurrScreenVideoRenderer(n)\nScreenVideoRenderer
        Break
      EndIf
    Next n
  EndWith
  
  Select mrVideoDriver\nVideoPlaybackLibrary
    Case #SCS_VPL_TVG
      nGadgetNo = WOP\cboScreenVideoRenderer[nIndex]
      If IsGadget(nGadgetNo)
        ClearGadgetItems(nGadgetNo)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_AUTOSELECT), #SCS_VR_AUTOSELECT)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_EVR), #SCS_VR_EVR)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_VMR9), #SCS_VR_VMR9)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_VMR7), #SCS_VR_VMR7)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_STANDARD), #SCS_VR_STANDARD)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_OVERLAY), #SCS_VR_OVERLAY)
        addGadgetItemWithData(nGadgetNo, decodeVideoRendererL(#SCS_VR_BLACKMAGIC_DECKLINK), #SCS_VR_BLACKMAGIC_DECKLINK)
        nListIndex = indexForComboBoxData(nGadgetNo, nScreenVideoRenderer, 0)
        SGS(nGadgetNo, nListIndex)
      EndIf
  EndSelect
  
EndProcedure

Procedure WOP_fcVideoLibrary()
  PROCNAMEC()
  Protected bVideoRendererVisible, bHwAccelVisible
  
  debugMsg(sProcName, #SCS_START)
  
  With mrVideoDriver
    debugMsg(sProcName, "grVideoDriver\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(grVideoDriver\nVideoPlaybackLibrary))
    debugMsg(sProcName, "mrVideoDriver\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary))
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        ; none visible
        
      Case #SCS_VPL_TVG
        CompilerIf #c_blackmagic_card_support = #False
          WOP_populateCboVideoRenderer()
        CompilerEndIf
        bVideoRendererVisible = #True
        If \nVideoPlaybackLibrary = #SCS_VPL_TVG
          bHwAccelVisible = #True
        EndIf
        
    EndSelect
  EndWith
  
  With WOP
    setVisible(\lblVideoRenderer, bVideoRendererVisible)
    setVisible(\cboVideoRenderer, bVideoRendererVisible)
    setVisible(\lblTVGPlayerHwAccel, bHwAccelVisible)
    setVisible(\cboTVGPlayerHwAccel, bHwAccelVisible)
    If bHwAccelVisible
      setGadgetItemByData(\cboTVGPlayerHwAccel, mrVideoDriver\nTVGPlayerHwAccel, 0)
    EndIf
  EndWith
EndProcedure

Procedure WOP_setButtons()
  If grWOP\mbChanges
    setEnabled(WOP\btnApply, #True)
  Else
    setEnabled(WOP\btnApply, #False)
  EndIf
EndProcedure

Procedure WOP_setOptionsChanged()
  grWOP\mbChanges = #True
  setEnabled(WOP\btnApply, #True)
EndProcedure

Procedure WOP_txtInitDir_Validate()
  PROCNAMEC()
  Protected sMsg.s, sFolder.s
  
  sFolder = Trim(GGT(WOP\txtInitDir))
  If sFolder
    If FolderExists(sFolder) = #False
      sMsg = LangPars("Errors", "FolderNotFound", sFolder)
      debugMsg(sProcName, sMsg)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
  EndIf
  mrGeneralOptions\sInitDir = sFolder
  If mrGeneralOptions\sInitDir <> grGeneralOptions\sInitDir
    grWOP\mbChanges = #True
    WOP_setButtons()
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WOP_validateGeneralTab()
  PROCNAMEC()
  Protected nGadgetIndex
  
  If grWOP\bLoadingOptionsForm
    ProcedureReturn #True
  EndIf
  
  nGadgetIndex = getGadgetPropsIndex(WOP\txtInitDir)
  If gaGadgetProps(nGadgetIndex)\bValidationReqd
    If WOP_txtInitDir_Validate() = #False
      ProcedureReturn #False
    EndIf
  EndIf
  
  nGadgetIndex = getGadgetPropsIndex(WOP\txtMaxPreOpenAudioFiles)
  If gaGadgetProps(nGadgetIndex)\bValidationReqd
    If WOP_txtMaxPreOpenAudioFiles_Validate() = #False
      ProcedureReturn #False
    EndIf
  EndIf
  
  nGadgetIndex = getGadgetPropsIndex(WOP\txtMaxPreOpenVideoImageFiles)
  If gaGadgetProps(nGadgetIndex)\bValidationReqd
    If WOP_txtMaxPreOpenVideoImageFiles_Validate() = #False
      ProcedureReturn #False
    EndIf
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WOP_validateAudioDriverTab()
  PROCNAMEC()
  Protected actualDriverSettings.tyDriverSettings
  Protected sMsg.s

  actualDriverSettings = mrDriverSettings
  
  With actualDriverSettings
    
    If \sUpdatePeriodOption = "Default"
      If \bUseBASSMixer
        \nUpdatePeriodLength = #SCS_DEFAULT_UPDATE_PERIOD_USING_MIXER
      Else
        \nUpdatePeriodLength = #SCS_DEFAULT_UPDATE_PERIOD_NO_MIXER
      EndIf
    EndIf
    
    If (\nUpdatePeriodLength < 5) Or (\nUpdatePeriodLength > 100)
      ; Update period ($1) must be between 5 and 100 milliseconds
      sMsg = LangPars("Errors", "UpdatePeriod", Str(\nUpdatePeriodLength))
      debugMsg(sProcName, "sMsg=" + sMsg)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
    
    If \sPlaybackBufOption = "Default"
      If \bUseBASSMixer
        \nPlaybackBufLength = #SCS_DEFAULT_BUFFER_USING_MIXER
      Else
        \nPlaybackBufLength = #SCS_DEFAULT_BUFFER_NO_MIXER
      EndIf
    EndIf
    
    If (\nPlaybackBufLength < (\nUpdatePeriodLength + 1)) Or (\nPlaybackBufLength > 5000)
      ; Playback buffer length ($1) must be between $2 and 5000 milliseconds
      sMsg = LangPars("Errors", "PlaybackBuffer", Str(\nPlaybackBufLength), Str(\nUpdatePeriodLength + 1))
      debugMsg(sProcName, "sMsg=" + sMsg)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
    
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtMaxPreOpenAudioFiles_Validate()
  PROCNAMEC()
  Protected sTmp.s, nTmp
  Protected sMsg.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  sTmp = Trim(GGT(WOP\txtMaxPreOpenAudioFiles))
  ; debugMsg(sProcName, "txtMaxPreOpenAudioFiles=" + sTmp)
  
  If IsInteger(sTmp) = #False
    nTmp = -99999
  Else
    nTmp = Val(sTmp)
  EndIf
  
  With mrGeneralOptions
    ; Max. No. of Audio Files to Pre-Open
    ; minimum is 5, because if we allow it much lower (eg 2) then user is more likely to run into
    ; problems by having all open files currently playing and no file 'ready' to play.
    If (nTmp < 5) Or (nTmp > gnMaxPreOpenAudioFilesForLicLevel)
      sMsg = LangPars("Errors", "MustBeBetween", GGT(WOP\lblMaxPreOpenAudioFiles), "5", Str(gnMaxPreOpenAudioFilesForLicLevel))
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
    \nMaxPreOpenAudioFiles = nTmp
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtMaxPreOpenVideoImageFiles_Validate()
  PROCNAMEC()
  Protected sTmp.s, nTmp
  Protected sMsg.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  sTmp = Trim(GGT(WOP\txtMaxPreOpenVideoImageFiles))
  ; debugMsg(sProcName, "txtMaxPreOpenVideoImageFiles=" + sTmp)
  
  If IsInteger(sTmp) = #False
    nTmp = -99999
  Else
    nTmp = Val(sTmp)
  EndIf
  
  With mrGeneralOptions
    ; Max. No. of Video/Image Files to Pre-Open
    If (nTmp < 2) Or (nTmp > gnMaxPreOpenVideoImageFilesForLicLevel)
      sMsg = LangPars("Errors", "MustBeBetween", GGT(WOP\lblMaxPreOpenVideoImageFiles), "2", Str(gnMaxPreOpenVideoImageFilesForLicLevel))
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
    \nMaxPreOpenVideoImageFiles = nTmp
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtLinkSyncPoint_Change()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtLinkSyncPoint)))
    If nTmp <> \nLinkSyncPoint
      \nLinkSyncPoint = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtLinkSyncPoint_Validate()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtLinkSyncPoint)))
    If nTmp <> \nLinkSyncPoint
      \nLinkSyncPoint = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
    gdResetPosForLinked = \nLinkSyncPoint / 1000
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtPlaybackBufLength_Change()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtPlaybackBufLength)))
    If nTmp <> \nPlaybackBufLength
      \nPlaybackBufLength = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtPlaybackBufLength_Validate()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtPlaybackBufLength)))
    If nTmp <> \nPlaybackBufLength
      \nPlaybackBufLength = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtUpdatePeriodLength_Change()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtUpdatePeriodLength)))
    If nTmp <> \nUpdatePeriodLength
      \nUpdatePeriodLength = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtUpdatePeriodLength_Validate()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtUpdatePeriodLength)))
    If nTmp <> \nUpdatePeriodLength
      \nUpdatePeriodLength = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
  ProcedureReturn #True
EndProcedure

; Added by Dee to allow for user defined "Play" and When reqd" columns 25/03/2025
Procedure WOP_txtUserColumnChanged1()
  WOP_setOptionsChanged()
  grWOP\mbChanges = #True
  gnUserColumnReset1 = #False
  gnuserColumnChanged1 = #True
  SetGadgetColor(WOP\txtUserColumn1, #PB_Gadget_BackColor, $c0c0ff)
  setEnabled(WOP\btnResetUserColumn1, #True)
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtUserColumnChanged2()
  WOP_setOptionsChanged()
  grWOP\mbChanges = #True
  gnUserColumnReset2 = #False
  gnuserColumnChanged1 = #True
  SetGadgetColor(WOP\txtUserColumn2, #PB_Gadget_BackColor, $c0c0ff)
  setEnabled(WOP\btnResetUserColumn2, #True)
  ProcedureReturn #True
EndProcedure

Procedure WOP_txtRAILocalPort_Change()
  Protected nTmp
  
  With mrRAIOptions
    nTmp = Val(Trim(GGT(WOP\txtRAILocalPort)))
    If nTmp <> \nLocalPort
      \nLocalPort = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtRAILocalPort_Validate()
  Protected nTmp
  
  With mrRAIOptions
    nTmp = Val(Trim(GGT(WOP\txtRAILocalPort)))
    If nTmp <> \nLocalPort
      \nLocalPort = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WOP_cboShortGroup_Click()
  PROCNAMEC()
  
  With WOP
    grWOP\nSelectedShortGroup = getCurrentItemData(\cboShortGroup)
    WOP_setupGrdShortcuts()
    SGS(\grdShortcuts, 0)
    WOP_displayShortcuts(0)
  EndWith
  
EndProcedure

Procedure WOP_setupGrdShortcuts()
  PROCNAMEC()
  Protected n, sText.s
  Protected sFunctionDescr.s

  debugMsg(sProcName, #SCS_START)

  ClearGadgetItems(WOP\grdShortcuts)
  Select grWOP\nSelectedShortGroup
    Case #SCS_ShortGroup_Main
      For n = 0 To ArraySize(maShortcutsMain())
        sFunctionDescr = maShortcutsMain(n)\sFunctionDescr
        If Len(sFunctionDescr) > 0
          Select n
            Case #SCS_ShortMain_DecPlayingCues, #SCS_ShortMain_IncPlayingCues, #SCS_ShortMain_DecLastPlayingCue, #SCS_ShortMain_IncLastPlayingCue
              sFunctionDescr + " **"
          EndSelect
          sText = sFunctionDescr + Chr(10) + maShortcutsMain(n)\sShortcutStr
          AddGadgetItem(WOP\grdShortcuts, -1, sText)
        EndIf
      Next n
      setVisible(WOP\lblShortcutInfo, #True)
      
    Case #SCS_ShortGroup_Editor
      For n = 0 To ArraySize(maShortcutsEditor())
        sFunctionDescr = maShortcutsEditor(n)\sFunctionDescr
        If sFunctionDescr
          Select n
            Case #SCS_ShortEditor_DecLevels, #SCS_ShortEditor_IncLevels
              sFunctionDescr + " **"
          EndSelect
          sText = sFunctionDescr + Chr(10) + maShortcutsEditor(n)\sShortcutStr
          AddGadgetItem(WOP\grdShortcuts, -1, sText)
        EndIf
      Next n
      setVisible(WOP\lblShortcutInfo, #False)
      
  EndSelect
  
  autoFitGridCol(WOP\grdShortcuts, 0)  ; autofit 'Function' column
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_displayShortcuts(nRow)
  PROCNAMEC()
  Protected n
  Protected sDBIncrement.s
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", nRow=" + nRow)

  If nRow >= 0
    Select grWOP\nSelectedShortGroup
      Case #SCS_ShortGroup_Main
        With maShortcutsMain(nRow)
          SGT(WOP\lblSelectedInfo, " " + \sFunctionDescr) ; prefix with space because a 'bordered' text gadget looks better with the extra padding at the front
          ; debugMsg(sProcName, "maShortcutsMain(" + nRow + ")\nShortcut=" + maShortcutsMain(nRow)\nShortcut)
          SGS(WOP\shcSelectShortcut, maShortcutsMain(nRow)\nShortcut)
          If Len(\sShortcutStr) = 0
            setEnabled(WOP\btnKeyRemove, #False)
          Else
            setEnabled(WOP\btnKeyRemove, #True)
          EndIf
        EndWith
        
      Case #SCS_ShortGroup_Editor
        With maShortcutsEditor(nRow)
          ; Debug "maShortcutsEditor(" + nRow + ")\sFunctionDescr=" + \sFunctionDescr
          SGT(WOP\lblSelectedInfo, " " + \sFunctionDescr) ; prefix with space because a 'bordered' text gadget looks better with the extra padding at the front
          SGS(WOP\shcSelectShortcut, maShortcutsEditor(nRow)\nShortcut)
          If Len(\sShortcutStr) = 0
            setEnabled(WOP\btnKeyRemove, #False)
          Else
            setEnabled(WOP\btnKeyRemove, #True)
          EndIf
        EndWith
    EndSelect
    setEnabled(WOP\shcSelectShortcut, #True)
    
  Else
    ; Debug "blank"
    SGT(WOP\lblSelectedInfo, "")
    SGS(WOP\shcSelectShortcut, 0)
    setEnabled(WOP\btnKeyRemove, #False)
    setEnabled(WOP\shcSelectShortcut, #False)
  EndIf
  
  SGT(WOP\lblCurrentInfo, "")
  setEnabled(WOP\btnKeyAssign, #False)
  setEnabled(WOP\btnKeyReset, #False)
  
  ClearGadgetItems(WOP\cboDBIncrement)
  For n = 1 To 10
    If n < 10
      sDBIncrement = "0." + n + "dB"
    Else
      sDBIncrement = "1." + Str(n-10) + "dB"
    EndIf
    addGadgetItemWithData(WOP\cboDBIncrement, sDBIncrement, n)
  Next n
  nListIndex = indexForComboBoxRow(WOP\cboDBIncrement,mrGeneralOptions\sDBIncrement + "dB")
  If nListIndex >= 0
    SGS(WOP\cboDBIncrement, nListIndex)
  EndIf
  
  WOP_setShortcutsButtons()
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WOP_populateSplitScreenInfo()
  PROCNAMEC()
  Protected nItemIndex
  Protected sDoNotSplit.s
  Protected nRealScreenWidth, nRealScreenHeight
  Protected nWidth
  Protected sSplitCount.s
  Protected nListIndex
  Protected sRealScreenSizeLabel.s
  Protected nDisplayNo, nOutputNo, nScreenNo
  Protected sScreens.s
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling listSplitScreenArray()")
  listSplitScreenArray()
  
  debugMsg(sProcName, "mrVideoDriver\nSplitScreenArrayMax=" + mrVideoDriver\nSplitScreenArrayMax + ", grVideoDriver\nSplitScreenArrayMax=" + grVideoDriver\nSplitScreenArrayMax)
  
  If mrVideoDriver\nRealScreensConnected > 0
    
    sDoNotSplit = Lang("WOP", "DoNotSplit")
    sRealScreenSizeLabel = Trim(GGT(WOP\lblRealScreenSize))
    
    nScreenNo = 0
    For nItemIndex = 0 To mrVideoDriver\nSplitScreenArrayMax
      With mrVideoDriver\aSplitScreenInfo[nItemIndex]
        debugMsg(sProcName, "mrVideoDriver\aSplitScreenInfo[" + nItemIndex + "]\sRealScreenSize=" + \sRealScreenSize + ", \nRealScreenWidth=" + \nRealScreenWidth + ", \nRealScreenHeight=" + \nRealScreenHeight + ", \nSplitScreenCount=" + \nSplitScreenCount)
        If IsGadget(WOP\txtRealScreenSize[nItemIndex])
          SGT(WOP\txtRealScreenSize[nItemIndex], Str(\nDisplayNo) + ": " + \sRealScreenSize)
          CompilerIf #c_blackmagic_card_support
            WOP_populateCboScreenVideoRenderer(nItemIndex)
          CompilerEndIf
          ClearGadgetItems(WOP\cboSplitScreenCount[nItemIndex])
          addGadgetItemWithData(WOP\cboSplitScreenCount[nItemIndex],sDoNotSplit,1)
          nRealScreenWidth = \nRealScreenWidth
          nRealScreenHeight = \nRealScreenHeight
          ; add entry for 2 screens
          nWidth = nRealScreenWidth / 2
          If nWidth >= 800
            If (nWidth * 2) = nRealScreenWidth ; checks that real screen width is exactly divisible by 2
              sSplitCount = "2 x [" + nWidth + "x" + nRealScreenHeight + "]"
              addGadgetItemWithData(WOP\cboSplitScreenCount[nItemIndex],sSplitCount,2)
            EndIf
          EndIf
          ; add entry for 3 screens
          nWidth = nRealScreenWidth / 3
          If nWidth >= 800
            If (nWidth * 3) = nRealScreenWidth ; checks that real screen width is exactly divisible by 3
              sSplitCount = "3 x [" + nWidth + "x" + nRealScreenHeight + "]"
              addGadgetItemWithData(WOP\cboSplitScreenCount[nItemIndex],sSplitCount,3)
            EndIf
          EndIf
          nListIndex = indexForComboBoxData(WOP\cboSplitScreenCount[nItemIndex],\nSplitScreenCount,0)
          SGS(WOP\cboSplitScreenCount[nItemIndex],nListIndex)
          scsToolTip(WOP\cboSplitScreenCount[nItemIndex],LangPars("WOP", "cboSplitScreenCountTT", sRealScreenSizeLabel + " " + \sRealScreenSize))
          
          sScreens = ""
          debugMsg(sProcName, "mrVideoDriver\aSplitScreenInfo[" + nItemIndex + "]\nSplitScreenCount=" + Str(\nSplitScreenCount))
          For nOutputNo = 1 To \nSplitScreenCount
            nScreenNo + 1
            Select nScreenNo
              Case #SCS_VID_PIC_TARGET_F2 To grLicInfo\nLastVidPicTarget
                If Len(sScreens) = 0
                  sScreens = Str(nScreenNo)
                Else
                  sScreens + ", " + Str(nScreenNo)
                EndIf
            EndSelect
          Next nOutputNo
          
          If CountGadgetItems(WOP\cboSplitScreenCount[nItemIndex]) > 1
            setEnabled(WOP\cboSplitScreenCount[nItemIndex], #True)
          Else
            setEnabled(WOP\cboSplitScreenCount[nItemIndex], #False)
          EndIf
          
          SGT(WOP\txtScreens[nItemIndex], sScreens)
        EndIf
      EndWith
    Next nItemIndex
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_setDefaultsInCaptions()
  PROCNAMEC()
  Protected nMyDefaultBuffer, nMyDefaultUpdatePeriod

  If mrDriverSettings\bUseBASSMixer
    nMyDefaultBuffer = #SCS_DEFAULT_BUFFER_USING_MIXER
    nMyDefaultUpdatePeriod = #SCS_DEFAULT_UPDATE_PERIOD_USING_MIXER
  Else
    nMyDefaultBuffer = #SCS_DEFAULT_BUFFER_NO_MIXER
    nMyDefaultUpdatePeriod = #SCS_DEFAULT_UPDATE_PERIOD_NO_MIXER
  EndIf
  
  ; SGT(WOP\optPlaybackbuf[0], "SCS default playback buffer length (" + Str(nMyDefaultBuffer) + "ms)")
  ; GadgetToolTip(WOP\optPlaybackbuf[0], "Use the SCS default playback buffering length, which is " + Str(nMyDefaultBuffer) + "ms")
  ; SGT(WOP\optUpdatePeriod[0], "SCS default update period (" + Str(nMyDefaultUpdatePeriod) + "ms)")
  ; GadgetToolTip(WOP\optUpdatePeriod[0], "Use the SCS default update period for the playback buffer, which is " + Str(nMyDefaultUpdatePeriod) + "ms")
  
  SGT(WOP\optPlaybackbuf[0], LangPars("WOP", "optPlaybackbuf[0]", Str(nMyDefaultBuffer)))
  scsToolTip(WOP\optPlaybackbuf[0], LangPars("WOP", "optPlaybackbufTT[0]", Str(nMyDefaultBuffer)))
  SGT(WOP\optUpdatePeriod[0], LangPars("WOP", "optUpdatePeriod[0]", Str(nMyDefaultUpdatePeriod)))
  scsToolTip(WOP\optUpdatePeriod[0], LangPars("WOP", "optUpdatePeriodTT[0]", Str(nMyDefaultUpdatePeriod)))
  
  ProcedureReturn
EndProcedure

Procedure WOP_tvwPrefTree_NodeClick()
  PROCNAMEC()
  Protected nNodeIndex, nNodeKey
  Protected nSelectedContainer
  Static bInNodeClick
  
  debugMsg(sProcName, #SCS_START)
  
  If bInNodeClick
    debugMsg(sProcName, "returning because bInNodeClick=" + strB(bInNodeClick))
    ProcedureReturn
  EndIf
  bInNodeClick = #True
  
  nNodeIndex = GetGadgetState(WOP\tvwPrefTree)
  If nNodeIndex >= 0
    
    nNodeKey = grWOP\nNodeKey[nNodeIndex]
    debugMsg(sProcName, "nNodeIndex=" + nNodeIndex + ", nNodeKey=" + nNodeKey)
    
    Select nNodeKey
      Case #SCS_OPTNODE_ROOT, #SCS_OPTNODE_GENERAL
        nSelectedContainer = #SCS_OPTCNT_GENERAL
        WOP_displayFontInfo()
        
      Case #SCS_OPTNODE_DISPLAY, #SCS_OPTNODE_DISPLAY_DESIGN, #SCS_OPTNODE_DISPLAY_REHEARSAL, #SCS_OPTNODE_DISPLAY_PERFORMANCE
        If nNodeKey = #SCS_OPTNODE_DISPLAY
          ; if user clicks the parent 'display options' node then re-position on the first child node
          SGS(WOP\tvwPrefTree, grWOP\nNodeIndex[#SCS_OPTNODE_DISPLAY_DESIGN])
        EndIf
        nSelectedContainer = #SCS_OPTCNT_DISPLAY
        
      Case #SCS_OPTNODE_COLS, #SCS_OPTNODE_COLS_DESIGN, #SCS_OPTNODE_COLS_REHEARSAL, #SCS_OPTNODE_COLS_PERFORMANCE
        If nNodeKey = #SCS_OPTNODE_COLS
          ; if user clicks the parent 'cue list columns' node then re-position on the first child node
          SGS(WOP\tvwPrefTree, grWOP\nNodeIndex[#SCS_OPTNODE_COLS_DESIGN])
        EndIf
        nSelectedContainer = #SCS_OPTCNT_COLS
        
      Case #SCS_OPTNODE_AUDIO_DRIVER
        ; nSelectedContainer = #SCS_OPTCNT_AUDIO_DRIVER
        ; if user clicks the parent 'Audio Driver' node then re-position on the first child node
        SGS(WOP\tvwPrefTree, grWOP\nNodeIndex[#SCS_OPTNODE_BASS_DS])
        nSelectedContainer = #SCS_OPTCNT_BASS_DS ; 'DS' originally just for DirectSound, but now also includes WASAPI
        
      Case #SCS_OPTNODE_BASS_DS
        nSelectedContainer = #SCS_OPTCNT_BASS_DS ; 'DS' originally just for DirectSound, but now also includes WASAPI
        
      Case #SCS_OPTNODE_BASS_ASIO
        nSelectedContainer = #SCS_OPTCNT_BASS_ASIO
        
      Case #SCS_OPTNODE_SMS_ASIO
        nSelectedContainer = #SCS_OPTCNT_SMS_ASIO
        
      Case #SCS_OPTNODE_VIDEO_DRIVER
        nSelectedContainer = #SCS_OPTCNT_VIDEO_DRIVER
        
      Case #SCS_OPTNODE_RAI
        nSelectedContainer = #SCS_OPTCNT_RAI
        
      Case #SCS_OPTNODE_FUNCTIONAL_MODE
        nSelectedContainer = #SCS_OPTCNT_FUNCTIONAL_MODE
        
      Case #SCS_OPTNODE_EDITING
        nSelectedContainer = #SCS_OPTCNT_EDITING
        
      Case #SCS_OPTNODE_SHORTCUTS
        nSelectedContainer = #SCS_OPTCNT_SHORTCUTS
        
      Case #SCS_OPTNODE_SESSION
        nSelectedContainer = #SCS_OPTCNT_SESSION
        
    EndSelect
    
    ; Debug sProcName + ": grWOP\nDisplayedContainer=" + grWOP\nDisplayedContainer + ", nSelectedContainer=" + nSelectedContainer
    If grWOP\nDisplayedContainer <> nSelectedContainer
      
      ; hide currently-displayed container (validate first, if necessary)
      Select grWOP\nDisplayedContainer
        Case #SCS_OPTCNT_GENERAL
          If WOP_validateGeneralTab() = #False
            SGS(WOP\tvwPrefTree, grWOP\nNodeIndex[#SCS_OPTNODE_GENERAL])
            bInNodeClick = #False
            ProcedureReturn
          EndIf
          setVisible(WOP\cntGeneral, #False)
          
        Case #SCS_OPTCNT_DISPLAY
          setVisible(WOP\cntDisplayOptions, #False)
          
        Case #SCS_OPTCNT_COLS
          setVisible(WOP\cntCueListCols, #False)
          
        Case #SCS_OPTCNT_AUDIO_DRIVER
          ; If WOP_validateAudioDriverTab() = #False
            ; SGS(WOP\tvwPrefTree, grWOP\nNodeIndex[#SCS_OPTNODE_AUDIO_DRIVER])
            ; bInNodeClick = #False
            ; ProcedureReturn
          ; EndIf
          ; setVisible(WOP\cntAudioDriver, #False)
          
        Case #SCS_OPTCNT_BASS_DS
          setVisible(WOP\cntBASSDS, #False)
          
        Case #SCS_OPTCNT_BASS_ASIO
          setVisible(WOP\cntBASSASIO, #False)
          
        Case #SCS_OPTCNT_SMS_ASIO
          setVisible(WOP\cntSMS, #False)
          
        Case #SCS_OPTCNT_VIDEO_DRIVER
          setVisible(WOP\cntVideoDriver, #False)
          
        Case #SCS_OPTCNT_RAI
          setVisible(WOP\cntRAI, #False)
          
        Case #SCS_OPTCNT_FUNCTIONAL_MODE
          setVisible(WOP\cntFM, #False)
          
        Case #SCS_OPTCNT_EDITING
          setVisible(WOP\cntEditing, #False)
          
        Case #SCS_OPTCNT_SHORTCUTS
          setVisible(WOP\cntShortcuts, #False)
          
        Case #SCS_OPTCNT_SESSION
          setVisible(WOP\cntSession, #False)
          
      EndSelect
      
    EndIf
    
    WOP_populateContainerForNode(nNodeKey)
    
    grWOP\nDisplayedContainer = nSelectedContainer
    
  EndIf
  
  bInNodeClick = #False
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WOP_EventHandler()
  PROCNAMEC()
  Protected nActiveGadgetNo
  
  With WOP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WOP_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #WOP_mnuASIODev0 To #WOP_mnuASIODevLast
            WOP_mnuAsioDev(gnEventMenu)
        EndSelect
        
      Case #PB_Event_Gadget
        ; debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        
        ; the following is in lieu of the VB6 'lost focus' event on the 'Test SMS Connection' button
        If grWOP\bTestLabelPopulated
          SGT(WOP\lblTestSMSResult, "")
          grWOP\bTestLabelPopulated = #False
        EndIf
        
        Select gnEventGadgetNoForEvHdlr
            
          ; INFO: Form-Level gadgets
          Case \btnApply
            BTNCLICK(WOP_btnApply_Click())
          Case \btnCancel
            BTNCLICK(WOP_btnCancel_Click())
          Case \btnHelp
            BTNCLICK(WOP_btnHelp_Click())
          Case \btnOK
            BTNCLICK(WOP_btnOK_Click())
            
          Case \tvwPrefTree
            If gnEventType = #PB_EventType_LeftClick
              debugMsg(sProcName, "calling WOP_tvwPrefTree_NodeClick()")
              WOP_tvwPrefTree_NodeClick()
              debugMsg(sProcName, "returned from WOP_tvwPrefTree_NodeClick()")
            EndIf
            
          ; INFO: Operational Mode gadgets
          Case \btnLockEditing
            BTNCLICK(WOP_btnLockEditing_Click())
          Case \cboChangeOperMode
            CBOCHG(WOP_cboChangeOperMode())
            
          ; INFO: General Options gadgets
          Case \cboDoubleClick
            CBOCHG(WOP_cboDoubleClick_Click())
          Case \cboLanguage
            CBOCHG(WOP_cboLanguage_Click())
          Case \cboFadeAllTime
            CBOCHG(WOP_cboFadeAllTime_Click())
          Case \cboSwapMonitor
            CBOCHG(WOP_cboSwapMonitor_Click())
          Case \chkApplyTimeoutToOtherGos
            CHKCHG(WOP_chkApplyTimeoutToOtherGos_Click())
          Case \chkDisplayLangIds
            CHKCHG(WOP_chkDisplayLangIds())
          Case \chkEnableAutoCheckForUpdate
            CHKCHG(WOP_chkEnableAutoCheckForUpdate_Click())
          Case \chkSwapMonitors1and2
            CHKCHG(WOP_chkSwapMonitors1and2_Click())
          Case \btnBrowse
            BTNCLICK(WOP_btnBrowse_Click())
          Case \btnAudioEditorBrowse
            BTNCLICK(WOP_btnAudioEditorBrowse_Click())
          Case \btnImageEditorBrowse
            BTNCLICK(WOP_btnImageEditorBrowse_Click())
          Case \btnVideoEditorBrowse
            BTNCLICK(WOP_btnVideoEditorBrowse_Click())
          Case \btnDfltFont
            BTNCLICK(WOP_btnDfltFont_Click())
          Case \btnUseSCSDfltFont
            BTNCLICK(WOP_btnUseSCSDfltFont_Click())
          Case \cboTimeFormat
            WOP_cboTimeFormat_Click()
          Case \txtDaysBetweenChecks
            If gnEventType = #PB_EventType_Change
              WOP_txtDaysBetweenChecks_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtDaysBetweenChecks_Validate())
            EndIf
          Case \txtInitDir
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtInitDir_Validate())
            EndIf
          Case \txtMaxPreOpenAudioFiles
            If gnEventType = #PB_EventType_Change
              WOP_txtMaxPreOpenAudioFiles_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtMaxPreOpenAudioFiles_Validate())
            EndIf
          Case \txtMaxPreOpenVideoImageFiles
            If gnEventType = #PB_EventType_Change
              WOP_txtMaxPreOpenVideoImageFiles_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtMaxPreOpenVideoImageFiles_Validate())
            EndIf
            
          ; INFO: Display Options gadgets
          Case \btnColorSchemeDesigner
            BTNCLICK(WCS_Form_Show(#True, #WOP))
          Case \btnDefaultDisplayOptions
            BTNCLICK(WOP_btnDefaultDisplayOptions_Click())
          Case \cboColorScheme
            CBOCHG(WOP_cboColorScheme_Click())
          Case \cboCtrlPanelPos
            CBOCHG(WOP_cboCtrlPanelPos_Click())
          Case \cboCueListFontSize
            CBOCHG(WOP_cboCueListFontSize_Click())
          Case \cboCuePanelHeight
            CBOCHG(WOP_cboCuePanelHeight_Click())
;           Case \cboMaxMonitor ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;             CBOCHG(WOP_cboMaxMonitor_Click())
          Case \cboMonitorSize
            CBOCHG(WOP_cboMonitorSize_Click())
          Case \cboMidiInDisplayTimeout
            CBOCHG(WOP_cboMidiInDisplayTimeout_Click())
          Case \cboMTCDispLocn
            CBOCHG(WOP_cboMTCDispLocn_Click())
          Case \cboTimerDispLocn
            CBOCHG(WOP_cboTimerDispLocn_Click())
          Case \cboToolbarInfo
            CBOCHG(WOP_cboToolbarInfo_Click())
          Case \cboVUDisplay
            CBOCHG(WOP_cboVUDisplay_Click())
          Case \chkAllowDisplayTimeout
            CHKCHG(WOP_chkAllowDisplayTimeout_Click())
          Case \chkDisplayAllMidiIn
            CHKCHG(WOP_chkDisplayAllMidiIn_Click())
          Case \chkLimitMovementOfMainWindowSplitterBar
            CHKCHG(WOP_chkLimitMovementOfMainWindowSplitterBar_Click())
          Case \chkRequestConfirmCueClick
            CHKCHG(WOP_chkRequestConfirmCueClick_Click())
          Case \chkShowAudioGraph
            CHKCHG(WOP_chkShowAudioGraph_Click())
          Case \chkShowCueMarkers
            CHKCHG(WOP_chkShowCueMarkers_Click())
          Case \chkShowFaderAndPanControls
            CHKCHG(WOP_chkShowFaderAndPanControls_Click())
          Case \chkShowHidden
            CHKCHG(WOP_chkShowHidden_Click())
          Case \chkShowHKeysInPanels
            CHKCHG(WOP_chkShowHKeysInPanels_Click())
          Case \chkShowHKeyList
            CHKCHG(WOP_chkShowHKeyList_Click())
          Case \chkShowLvlCurvesOther
            CHKCHG(WOP_chkShowLvlCurvesOther_Click())
          Case \chkShowLvlCurvesPrim
            CHKCHG(WOP_chkShowLvlCurvesPrim_Click())
          Case \chkShowMasterFader
            CHKCHG(WOP_chkShowMasterFader_Click())
          Case \chkShowMidiCueInCuePanels
            CHKCHG(WOP_chkShowMidiCueInCuePanels_Click())
          Case \chkShowMidiCueInNextManual
            CHKCHG(WOP_chkShowMidiCueInNextManual_Click())
          Case \chkShowNextManual
            CHKCHG(WOP_chkShowNextManual_Click())
          Case \chkShowPanCurvesOther
            CHKCHG(WOP_chkShowPanCurvesOther_Click())
          Case \chkShowPanCurvesPrim
            CHKCHG(WOP_chkShowPanCurvesPrim_Click())
          Case \chkShowSubCues
            CHKCHG(WOP_chkShowSubCues_Click())
          Case \chkShowToolTips
            CHKCHG(WOP_chkShowToolTips_Click())
          Case \chkShowTransportControls
            CHKCHG(WOP_chkShowTransportControls_Click())
            
          ; INFO: Cue List Columns tab gadgets
          Case \btnColDefaults
            BTNCLICK(WOP_btnColDefaults_Click())
          Case \btnColFit
            BTNCLICK(WOP_btnColFit_Click())
          Case \btnColRevert
            BTNCLICK(WOP_btnColRevert_Click())
          Case \btnMoveDown
            BTNCLICK(WOP_moveUpOrDown(#False))
          Case \btnMoveUp
            BTNCLICK(WOP_moveUpOrDown(#True))
          Case \grdCueListCols
            If gnEventType = #PB_EventType_LeftClick
              WOP_grdCueListCols_LeftClick()
            EndIf
            
          Case \cboCopyModeSettings
            CBOCHG(WOP_cboCopyModeSettings_Click())
          Case \btnCopyModeSettings
            BTNCLICK(WOP_btnCopyModeSettings_Click())
          Case \btnUndoModeSettings
            BTNCLICK(WOP_btnUndoModeSettings_Click())
            
          ; Added by Dee to allow for user defined "Play" and When reqd" columns 25/03/2025
          Case WOP\txtUserColumn1
            If gnEventType = #PB_EventType_Change
              WOP_txtUserColumnChanged1()
            EndIf
            
          Case WOP\txtUserColumn2
            If gnEventType = #PB_EventType_Change
              WOP_txtUserColumnChanged2()
            EndIf
                        
          Case \btnResetUserColumn1
            BTNCLICK(WOP_btnResetUserColumn1_Click())
            
          Case \btnResetUserColumn2
            BTNCLICK(WOP_btnResetUserColumn2_Click())
            
          ; INFO: Audio Driver tab gadgets
          ; SM-S
          Case \chkSMSOnThisMachine
            CHKCHG(WOP_chkSMSOnThisMachine_Click())
          Case \btnBrowseAudioFilesRootFolder
            BTNCLICK(WOP_btnBrowseAudioFilesRootFolder_Click())
          Case \btnTestSMS
            BTNCLICK(WOP_btnTestSMS_Click())
          Case \txtMinPChansNonHK
            If gnEventType = #PB_EventType_Change
              WOP_txtMinPChansNonHK_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtMinPChansNonHK_Validate())
            EndIf
            
          ; BASS
          Case \chkNoFloatingPoint
            CHKCHG(WOP_chkNoFloatingPoint_Click())
          Case \chkSwap34with56
            CHKCHG(WOP_chkSwap34with56_Click())
          Case \chkNoWASAPI
            CHKCHG(WOP_chkNoWASAPI_Click())
            
          ; SCS Internal Mixer frame
          Case \optBASSMixer[0], \optBASSMixer[1]
            WOP_optBASSMixer_Click()
            
          ; Playback Buffering frame
          Case \optPlaybackbuf[0] ;, \optPlaybackbuf[1]
            WOP_optPlaybackbuf_Click()
          Case \txtPlaybackBufLength
            If gnEventType = #PB_EventType_Change
              WOP_txtPlaybackBufLength_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtPlaybackBufLength_Validate())
            EndIf
            
          ; Update Period frame
          Case \optUpdatePeriod[0]  ;, \optUpdatePeriod[1]
            WOP_optUpdatePeriod_Click()
          Case \txtUpdatePeriodLength
            If gnEventType = #PB_EventType_Change
              WOP_txtUpdatePeriodLength_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtUpdatePeriodLength_Validate())
            EndIf
            
          ; Other fields
          Case \cboAsioBufLen
            CBOCHG(WOP_cboAsioBufLen_Click())
          Case \cboFileBufLen
            CBOCHG(WOP_cboFileBufLen_Click())
          Case \cboSampleRate
            CBOCHG(WOP_cboSampleRate_Click())
          Case \txtLinkSyncPoint
            If gnEventType = #PB_EventType_Change
              WOP_txtLinkSyncPoint_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtLinkSyncPoint_Validate())
            EndIf
          Case \btnAsioControlPanel, \btnAsioControlPanelSMS
            BTNCLICK(WOP_btnAsioControlPanel_Click())
            
          ; INFO: Video Driver tab gadgets
          Case \cboSplitScreenCount[0]
            WOP_cboSplitScreenCount_Click(gnEventGadgetArrayIndex)
          Case \cboScreenVideoRenderer[0]
            WOP_cboScreenVideoRenderer_Click(gnEventGadgetArrayIndex)
          Case \cboTVGPlayerHwAccel
            CBOCHG(WOP_cboTVGPlayerHwAccel_Click())
          Case \cboVideoLibrary
            CBOCHG(WOP_cboVideoLibrary_Click())
          Case \cboVideoRenderer
            CBOCHG(WOP_cboVideoRenderer_Click())
          Case \chkTVGDisplayVUMeters
            WOP_chkTVGDisplayVUMeters_Click()
          Case \cntSplitScreenInfo
            ; ignore

          ; INFO: Remote App Interface tab gadgets
          Case \btnRAIIPInfo
            BTNCLICK(WOP_btnRAIIPInfo_Click())
          Case \cboRAIApp
            WOP_cboRAIApp_Click()
          Case \cboRAIOSCVersion
            WOP_cboRAIOSCVersion_Click()
          Case \cboRAILocalIPAddr
            WOP_cboRAILocalIPAddr_Click()
          Case \cboRAINetworkProtocol
            WOP_cboRAINetworkProtocol_Click()
          Case \chkRAIEnabled
            CHKCHG(WOP_chkRAIEnabled_Click())
          Case \txtRAILocalPort
            If gnEventType = #PB_EventType_Change
              WOP_txtRAILocalPort_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WOP_txtRAILocalPort_Validate())
            EndIf
            
          ; INFO: Primary/Backup Functional Modes gadgets
          Case \btnFMIPInfo
            BTNCLICK(WOP_btnFMALLInfo_Click())
          Case \cboFMFunctionalMode
            WOP_cboFMFunctionalMode_Click()  
          Case \cboFMLocalIPAddr
            WOP_cboFMLocalIPAddr_Click()
          Case \chkBackupIgnoreLIGHTING
            WOP_chkBackupIgnoreLighting_Click()
          Case \chkBackupIgnoreCtrlSendMIDI
            WOP_chkBackupIgnoreMIDI_Click()  
          Case \chkBackupIgnoreCtrlSendNETWORK
            WOP_chkBackupIgnoreNetwork_Click()
          Case \chkBackupIgnoreCueCtrlDevs
            WOP_chkBackupIgnoreCueCtrlDevs_Click()
          Case \txtFMServerAddr
            If gnEventType = #PB_EventType_LostFocus
              WOP_txtFMServerAddr_Changed()
            EndIf             
            
          ; INFO: Shortcuts tab gadgets
          Case \cboShortGroup
            CBOCHG(WOP_cboShortGroup_Click())
          Case \grdShortcuts
            If gnEventType = #PB_EventType_Change Or gnEventType = #PB_EventType_LeftClick
              WOP_grdShortcuts_CurCellChange()
            EndIf
          Case \btnDefaultShortcuts
            BTNCLICK(WOP_btnDefaultShortcuts_Click())
          Case \btnKeyAssign
            BTNCLICK(WOP_btnKeyAssign_Click())
          Case \btnKeyRemove
            BTNCLICK(WOP_btnKeyRemove_Click())
          Case \btnKeyReset
            BTNCLICK(WOP_btnKeyReset_Click())
          Case \cboDBIncrement
            CHKCHG(WOP_cboDBIncrement_Click())
          Case \chkCtrlOverridesExclCue
            CHKCHG(WOP_chkCtrlOverridesExclCue_Click())
          Case \chkDisableRightClick
            CHKCHG(WOP_chkDisableRightClick_Click())
          Case \chkHotkeysOverrideExclCue
            CHKCHG(WOP_chkHotkeysOverrideExclCue_Click())
          Case \shcSelectShortcut
            WOP_shcSelectShortcut_Event()
            
          ; INFO: Editing Options tab gadgets
          Case \cboAudioFileSelector
            CHKCHG(WOP_cboAudioFileSelector_Click())
          Case \cboEditorCueListFontSize
            CBOCHG(WOP_cboEditorCueListFontSize_Click())
          Case \cboFileScanMaxLengthAudio
            CHKCHG(WOP_cboFileScanMaxLengthAudio_Click())
          Case \cboFileScanMaxLengthVideo
            CHKCHG(WOP_cboFileScanMaxLengthVideo_Click())
          Case \chkActivateOCMAutoStarts
            CHKCHG(WOP_chkActivateOCMAutoStarts_Click())
          Case \chkDisableVideoWarningMessage
            CHKCHG(WOP_chkDisableVideoWarningMessage_Click())
          Case \chkCheckMainLostFocusWhenEditorOpen
            CHKCHG(WOP_chkCheckMainLostFocusWhenEditorOpen_Click())
          Case \chkIgnoreTitleTags
            CHKCHG(WOP_chkIgnoreTitleTags_Click())
          Case \chkIncludeAllLevelPointDevices
            CHKCHG(WOP_chkIncludeAllLevelPointDevices_Click())
          Case \chkSaveAlwaysOn
            CHKCHG(WOP_chkSaveAlwaysOn_Click())
            
          ; INFO: Session tab gadgets
          Case \optDMXInEnabled[0], \optMidiInEnabled[0], \optRS232InEnabled[0], \optNetworkInEnabled[0], \optDMXOutEnabled[0], \optMidiOutEnabled[0], \optRS232OutEnabled[0], \optNetworkOutEnabled[0]
            WOP_deviceEnabled_Click()
            
          Default
            ; unknown gadget
            If gnEventType <> #PB_EventType_Resize
              debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
            EndIf
            
        EndSelect
        
      Case #WM_LBUTTONUP
        ; debugMsg(sProcName, "#WM_LBUTTONUP")
        If gnValidateGadgetNo <> 0
          ; debugMsg(sProcName, "#WM_LBUTTONUP, gnValidateGadgetNo=G" + Str(gnValidateGadgetNo) + " (" + getGadgetName(gnValidateGadgetNo) + ")")
          commonValidation()
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WOP_colorSchemeDesignerModReturn()
  PROCNAMEC()
  Protected n, nListIndex
  ; returned from Color Scheme Designer (fmColorScheme)
  
  debugMsg(sProcName, "grColorScheme\sSchemeName=" + grColorScheme\sSchemeName)
  
  ; if user clicked OK in Color Scheme Designer then grColorScheme may have been changed, so this is now the required color scheme
  gsColorScheme = grColorScheme\sSchemeName
  
  ; need to repopulate cboColorScheme as user could have added or deleted color schemes
  ClearGadgetItems(WOP\cboColorScheme)
  nListIndex = -1
  For n = 0 To ArraySize(gaColorScheme())
    If gaColorScheme(n)\sSchemeName
      AddGadgetItem(WOP\cboColorScheme, -1, gaColorScheme(n)\sSchemeName)
      If gsColorScheme = gaColorScheme(n)\sSchemeName
        nListIndex = n
      EndIf
    EndIf
  Next n
  SGS(WOP\cboColorScheme, nListIndex)
  
  mrOperModeOptions(grWOP\nNodeOperMode)\sSchemeName = GetGadgetItemText(WOP\cboColorScheme, GGS(WOP\cboColorScheme))
  debugMsg(sProcName, "mrOperModeOptions(" + decodeOperMode(grWOP\nNodeOperMode) + ")\sSchemeName=" + mrOperModeOptions(grWOP\nNodeOperMode)\sSchemeName)
  WMN_applyDisplayOptions(#False, #True)  ; 2nd parameter forces redo of colors in main window
  If (mrOperModeOptions(grWOP\nNodeOperMode)\sSchemeName <> grOperModeOptions(grWOP\nNodeOperMode)\sSchemeName) Or (grColHnd\bAudioGraphColorsChanged)
    WOP_setOptionsChanged()
  EndIf
  
EndProcedure

Procedure WOP_txtMinPChansNonHK_Change()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtMinPChansNonHK)))
    If nTmp <> \nMinPChansNonHK
      \nMinPChansNonHK = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtMinPChansNonHK_Validate()
  Protected nTmp
  
  With mrDriverSettings
    nTmp = Val(Trim(GGT(WOP\txtMinPChansNonHK)))
    If nTmp <> \nMinPChansNonHK
      \nMinPChansNonHK = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
  ProcedureReturn #True
  
EndProcedure

Procedure WOP_showGeneral()
  PROCNAMEC()
  Protected nTimeFormatIndex
  Protected nListIndex
  Protected n, nMaxSwapMonitor, nLeft
  
  ; debugMsg(sProcName, #SCS_START)
  
  With mrGeneralOptions
    SGT(WOP\txtInitDir, \sInitDir)
    
    ; Moved to WOP_showShortcuts() 28May2020 11.8.3rc5 because these checkboxes are displayed on the Shortcuts tab even though the values are stored under mrGeneralOptions
    ; SGS(WOP\chkDisableRightClick, \bDisableRightClickAsGo)
    ; debugMsg0(sProcName, "mrGeneralOptions\bCtrlOverridesExclCue=" + strB(\bCtrlOverridesExclCue) + ", \bHotkeysOverrideExclCue=" + strB(\bHotkeysOverrideExclCue))
    ; SGS(WOP\chkCtrlOverridesExclCue, \bCtrlOverridesExclCue)
    ; SGS(WOP\chkHotkeysOverrideExclCue, \bHotkeysOverrideExclCue)
    ; End moved to WOP_showShortcuts() 28May2020 11.8.3rc5
    
    SGT(WOP\txtMaxPreOpenAudioFiles, Str(\nMaxPreOpenAudioFiles))
    SGT(WOP\txtMaxPreOpenVideoImageFiles, Str(\nMaxPreOpenVideoImageFiles))
    
    setComboBoxByData(WOP\cboDoubleClick, \nDoubleClickTime)
    SGS(WOP\chkApplyTimeoutToOtherGos, \bApplyTimeoutToOtherGos)
    nListIndex = indexForComboBoxData(WOP\cboFadeAllTime, \nFadeAllTime)
    If nListIndex = -1
      nListIndex = indexForComboBoxData(WOP\cboFadeAllTime, 1000) ; 1000ms is default fade-all time
    EndIf
    SGS(WOP\cboFadeAllTime, nListIndex)
    
    debugMsg(sProcName, "mrGeneralOptions\sTimeFormat=" + \sTimeFormat)
    nTimeFormatIndex = FindString("ABC", \sTimeFormat, 1) - 1
    debugMsg(sProcName, "nTimeFormatIndex=" + nTimeFormatIndex)
    SGS(WOP\cboTimeFormat, nTimeFormatIndex)
    
    CompilerIf #cDemo = #False And #cWorkshop = #False
      SGS(WOP\chkEnableAutoCheckForUpdate, \bEnableAutoCheckForUpdate)
      SGT(WOP\txtDaysBetweenChecks, Str(\nDaysBetweenChecks))
      WOP_fcEnableAutoCheckForUpdate()
    CompilerEndIf
    
    nListIndex = -1
    For n = 0 To (gnLanguageCount-1)
      If gaLanguage(n)\sLangCode = \sLangCode
        nListIndex = n
        Break
      EndIf
    Next n
    SGS(WOP\cboLanguage, nListIndex)
    If #cTranslator
      If IsGadget(WOP\chkDisplayLangIds)
        debugMsg(sProcName, "\bDisplayLangIds=" + \bDisplayLangIds)
        SGS(WOP\chkDisplayLangIds, \bDisplayLangIds)
      EndIf
    EndIf
    
    SGS(WOP\chkSwapMonitors1and2, \bSwapMonitors1and2)
    nMaxSwapMonitor = gnMonitors
    If \nSwapMonitor > nMaxSwapMonitor
      ; must have been set higher earlier when \nSwapMonitor was available, so keep this value as the maximum for the combobox
      nMaxSwapMonitor = \nSwapMonitor
    EndIf
    ClearGadgetItems(WOP\cboSwapMonitor)
    addGadgetItemWithData(WOP\cboSwapMonitor, "2", 2) ; always include '2', even if there is only a single monitor present
    For n = 3 To nMaxSwapMonitor
      addGadgetItemWithData(WOP\cboSwapMonitor, Str(n), n)
    Next n
    setComboBoxWidth(WOP\cboSwapMonitor)
    setComboBoxByData(WOP\cboSwapMonitor, \nSwapMonitor, 0)
    If IsGadget(WOP\lblSwapMonitors1and2Part2)
      nLeft = GadgetX(WOP\cboSwapMonitor) + GadgetWidth(WOP\cboSwapMonitor); + gnGap
      ResizeGadget(WOP\lblSwapMonitors1and2Part2, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
    
    WOP_fcSwapMonitors1And2()
  EndWith
  
  setVisible(WOP\cntGeneral, #True)
  
EndProcedure

Procedure WOP_showDisplayOptions()
  PROCNAMEC()
  Protected nListIndex
  
  If grWOP\nNodeOperMode = #SCS_OPERMODE_PERFORMANCE
    SGT(WOP\frDisplayOptions, Lang("WOP","tabDisplayOptions") + " - " + Lang("WOP","tabPerformance"))
    SetGadgetColor(WOP\lnDispOperMode, #PB_Gadget_BackColor, #SCS_Blue)
  ElseIf grWOP\nNodeOperMode = #SCS_OPERMODE_REHEARSAL
    SGT(WOP\frDisplayOptions, Lang("WOP","tabDisplayOptions") + " - " + Lang("WOP","tabRehearsal"))
    SetGadgetColor(WOP\lnDispOperMode, #PB_Gadget_BackColor, #SCS_Orange)
  Else
    SGT(WOP\frDisplayOptions, Lang("WOP","tabDisplayOptions") + " - " + Lang("WOP","tabDesign"))
    SetGadgetColor(WOP\lnDispOperMode, #PB_Gadget_BackColor, #SCS_Green)
  EndIf
  
  With mrOperModeOptions(grWOP\nNodeOperMode)
    nListIndex = indexForComboBoxRow(WOP\cboColorScheme, \sSchemeName, 0)
    ; debugMsg(sProcName, "mrOperModeOptions(" + decodeOperMode(grWOP\nNodeOperMode) + ")\sSchemeName=" + \sSchemeName + ", nListIndex=" + nListIndex + ", CountGadgetItems(WOP\cboColorScheme)=" + Str(CountGadgetItems(WOP\cboColorScheme)))
    SGS(WOP\cboColorScheme, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboCueListFontSize, \nCueListFontSize, 0)
    SGS(WOP\cboCueListFontSize, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboCuePanelHeight, \nCuePanelVerticalSizing)
    SGS(WOP\cboCuePanelHeight, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboCtrlPanelPos, \nCtrlPanelPos, 0)
    SGS(WOP\cboCtrlPanelPos, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboToolbarInfo, \nMainToolBarInfo)
    SGS(WOP\cboToolbarInfo, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboVUDisplay, \nVisMode, 0)
    SGS(WOP\cboVUDisplay, nListIndex)
    SGS(WOP\chkShowSubCues, \bShowSubCues)
    SGS(WOP\chkShowHidden, \bShowHiddenAutoStartCues)
    SGS(WOP\chkShowHKeysInPanels, \bShowHotkeyCuesInPanels)
    SGS(WOP\chkShowHKeyList, \bShowHotkeyList)
    SGS(WOP\chkShowNextManual, \bShowNextManualCue)
    SGS(WOP\chkShowMasterFader, \bShowMasterFader)
    SGS(WOP\chkShowTransportControls, \bShowTransportControls)
    SGS(WOP\chkShowFaderAndPanControls, \bShowFaderAndPanControls)
    SGS(WOP\chkRequestConfirmCueClick, \bRequestConfirmCueClick)
    SGS(WOP\chkShowMidiCueInNextManual, \bShowMidiCueInNextManual)
    SGS(WOP\chkShowMidiCueInCuePanels, \bShowMidiCueInCuePanels)
    SGS(WOP\chkLimitMovementOfMainWindowSplitterBar, \bLimitMovementOfMainWindowSplitterBar)
    nListIndex = indexForComboBoxData(WOP\cboMonitorSize, \nMonitorSize, 0)
    SGS(WOP\cboMonitorSize, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboMTCDispLocn, \nMTCDispLocn, 0)
    SGS(WOP\cboMTCDispLocn, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboTimerDispLocn, \nTimerDispLocn, 0)
    SGS(WOP\cboTimerDispLocn, nListIndex)
    ; Deleted the following 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;     nListIndex = indexForComboBoxData(WOP\cboMaxMonitor, \nMaxMonitor, 0)
;     SGS(WOP\cboMaxMonitor, nListIndex)
    SGS(WOP\chkShowToolTips, \bShowToolTips)
    SGS(WOP\chkAllowDisplayTimeout, \bAllowDisplayTimeout)
    SGS(WOP\chkShowLvlCurvesPrim, \bShowLvlCurvesPrim)
    SGS(WOP\chkShowLvlCurvesOther, \bShowLvlCurvesOther)
    SGS(WOP\chkShowPanCurvesPrim, \bShowPanCurvesPrim)
    SGS(WOP\chkShowPanCurvesOther, \bShowPanCurvesOther)
    SGS(WOP\chkShowAudioGraph, \bShowAudioGraph)
    SGS(WOP\chkShowCueMarkers, \bShowCueMarkers)
    SGS(WOP\chkDisplayAllMidiIn, \bDisplayAllMidiIn)
    nListIndex = indexForComboBoxData(WOP\cboMidiInDisplayTimeout, \nMidiInDisplayTimeout, 0)
    SGS(WOP\cboMidiInDisplayTimeout, nListIndex)
  EndWith
  
  setVisible(WOP\cntDisplayOptions, #True)

EndProcedure

Procedure WOP_showCueListCols()
  PROCNAMEC()
  Protected nCurrentMode, nSelectedMode
  Protected nListIndex

  debugMsg(sProcName, #SCS_START + ", grWOP\nNodeOperMode=" + decodeOperMode(grWOP\nNodeOperMode) + ", gnOperMode=" + decodeOperMode(gnOperMode))
  
  nCurrentMode = grWOP\nNodeOperMode
  nSelectedMode = getCurrentItemData(WOP\cboCopyModeSettings)
  
  If grWOP\nNodeOperMode = #SCS_OPERMODE_PERFORMANCE
    SGT(WOP\frCueListCols, Lang("WOP","tabCueListCols") + " - " + Lang("WOP","tabPerformance"))
    SetGadgetColor(WOP\lnColsOperMode, #PB_Gadget_BackColor, #SCS_Blue)
  ElseIf grWOP\nNodeOperMode = #SCS_OPERMODE_REHEARSAL
    SGT(WOP\frCueListCols, Lang("WOP","tabCueListCols") + " - " + Lang("WOP","tabRehearsal"))
    SetGadgetColor(WOP\lnColsOperMode, #PB_Gadget_BackColor, #SCS_Orange)
  Else
    SGT(WOP\frCueListCols, Lang("WOP","tabCueListCols") + " - " + Lang("WOP","tabDesign"))
    SetGadgetColor(WOP\lnColsOperMode, #PB_Gadget_BackColor, #SCS_Green)
  EndIf
  
  If gnUserColumnReset1 = 0
    SGT(WOP\txtUserColumn1, Lang("common","Page"))
  EndIf
  
  If gnUserColumnReset2 = 0
    SGT(WOP\txtUserColumn2, Lang("common","WhenReqd"))
  EndIf
  
  ; If grWOP\nNodeOperMode = gnOperMode
    ; debugMsg(sProcName, "calling updateGridInfoFromPhysicalLayout(@mrOperModeOptions(gnOperMode)\rGrdCuesInfo)")
    ; updateGridInfoFromPhysicalLayout(@mrOperModeOptions(gnOperMode)\rGrdCuesInfo)
  ; EndIf
  debugMsg(sProcName, "calling WOP_populateGrdCueListCols()")
  WOP_populateGrdCueListCols()

  ; Populate the combobox with the available options
  WOP_populateCopyModeSettingsCombo()
  SGS(WOP\cboCopyModeSettings, 0)

  setVisible(WOP\cntCueListCols, #True)

  ; Check if the current mode's grid settings already match the selected mode's settings
  WOP_updateCopyButtonStates()
  WOP_updateUndoButtonStates()
  
  If grWOP\nNodeOperMode = #SCS_OPERMODE_DESIGN         ; Added by Dee 28/03/2025 to allow for user editable columns Page and When required.
    setVisible(WOP\lblUserColumn1, #True)
    setVisible(WOP\txtUserColumn1, #True)
    setVisible(WOP\lblUserColumn2, #True)
    setVisible(WOP\txtUserColumn2, #True)
    setVisible(WOP\lblUserColumnWarning, #True)
    setVisible(WOP\btnResetUserColumn1, #True)
    setVisible(WOP\btnResetUserColumn2, #True)
  Else
    setVisible(WOP\lblUserColumn1, #False)
    setVisible(WOP\txtUserColumn1, #False)
    setVisible(WOP\lblUserColumn2, #False)
    setVisible(WOP\txtUserColumn2, #False)
    setVisible(WOP\lblUserColumnWarning, #False)
    setVisible(WOP\btnResetUserColumn1, #False)
    setVisible(WOP\btnResetUserColumn2, #False)
  EndIf

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_showAudioDriver(nOptNode)
  PROCNAMEC()
  Protected nListIndex
  
  ; debugMsg(sProcName, #SCS_START + ", nOptNode=" + Str(nOptNode))
  
  Select nOptNode
    Case #SCS_OPTNODE_AUDIO_DRIVER, #SCS_OPTNODE_BASS_DS ; Audio Driver Group, SCS_OPTNODE_BASS_DS ; 'DS' originally just for DirectSound, but now also includes WASAPI
      ; debugMsg(sProcName, "DirectSound")
      With mrDriverSettings
        setCheckboxStateFromBoolean(WOP\chkNoFloatingPoint, \bNoFloatingPoint)
        setCheckboxStateFromBoolean(WOP\chkSwap34with56, \bSwap34with56)
        setCheckboxStateFromBoolean(WOP\chkNoWASAPI, \bNoWASAPI)
        
        If \bUseBASSMixer
          SetGadgetState(WOP\optBASSMixer[1], #True)
        Else
          SetGadgetState(WOP\optBASSMixer[0], #True)
        EndIf
        
        Select \sPlaybackBufOption
          Case "User"
            SGS(WOP\optPlaybackbuf[1], #True)
          Default
            SGS(WOP\optPlaybackbuf[0], #True)
        EndSelect
        
        If \nPlaybackBufLength <> 0
          SGT(WOP\txtPlaybackBufLength, Str(\nPlaybackBufLength))
        Else
          SGT(WOP\txtPlaybackBufLength, "")
        EndIf
        
        Select \sUpdatePeriodOption
          Case "User"
            SGS(WOP\optUpdatePeriod[1], #True)
          Default
            SGS(WOP\optUpdatePeriod[0], #True)
        EndSelect
        
        If \nUpdatePeriodLength <> 0
          SGT(WOP\txtUpdatePeriodLength, Str(\nUpdatePeriodLength))
        Else
          SGT(WOP\txtUpdatePeriodLength, "")
        EndIf
        
        nListIndex = indexForComboBoxRow(WOP\cboSampleRate, Str(\nDSSampleRate))
        If nListIndex >= 0
          SGS(WOP\cboSampleRate, nListIndex)
        EndIf
        
        If \nLinkSyncPoint <> 0
          SGT(WOP\txtLinkSyncPoint, Str(\nLinkSyncPoint))
        Else
          SGT(WOP\txtLinkSyncPoint, "")
        EndIf
        
      EndWith
      WOP_fcPlaybackBufOption()
      WOP_fcUpdatePeriodOption()
      WOP_setDefaultsInCaptions()
      setVisible(WOP\cntBASSDS, #True)
      
    Case #SCS_OPTNODE_BASS_ASIO  ; #SCS_OPTNODE_BASS_ASIO
      ; debugMsg(sProcName, "ASIO")
      With mrDriverSettings
        CompilerIf #cEnableASIOBufLen
          nListIndex = indexForComboBoxData(WOP\cboAsioBufLen, \nAsioBufLen, 0)
          SGS(WOP\cboAsioBufLen, nListIndex)
        CompilerEndIf
        CompilerIf #cEnableFileBufLen
          nListIndex = indexForComboBoxData(WOP\cboFileBufLen, \nFileBufLen, 0)
          SGS(WOP\cboFileBufLen, nListIndex)
        CompilerEndIf
        setEnabled(WOP\btnAsioControlPanel, gbAsioInitDone)
      EndWith
      setVisible(WOP\cntBASSASIO, #True)
      
    Case #SCS_OPTNODE_SMS_ASIO ; #SCS_OPTNODE_SMS_ASIO
      ; debugMsg(sProcName, "SM-S")
      With mrDriverSettings
        CompilerIf #cSMSOnThisMachineOnly = #False
          SGS(WOP\chkSMSOnThisMachine, \bSMSOnThisMachine)
        CompilerEndIf
        WOP_fcSMSOnThisMachine()
        CompilerIf #cSMSOnThisMachineOnly = #False
          SGT(WOP\txtAudioFilesRootFolder, \sAudioFilesRootFolder)
        CompilerEndIf
        SGT(WOP\txtMinPChansNonHK, Str(\nMinPChansNonHK))
      EndWith
      WOP_fcSMSOnThisMachine()
      setVisible(WOP\cntSMS, #True)
      
  EndSelect
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_showShortcuts()
  PROCNAMEC()
  Protected nListIndex
  
  With WOP
    If grWOP\bGrdShortcutsSetup = #False
      ClearGadgetItems(\cboShortGroup)
      addGadgetItemWithData(\cboShortGroup, Lang("WOP", "cboShortGroupMain"), #SCS_ShortGroup_Main)
      addGadgetItemWithData(\cboShortGroup, Lang("WOP", "cboShortGroupEditor"), #SCS_ShortGroup_Editor)
      setComboBoxWidth(\cboShortGroup)
      nListIndex = indexForComboBoxData(\cboShortGroup, #SCS_ShortGroup_Main)
      SGS(\cboShortGroup, nListIndex)
      grWOP\nSelectedShortGroup = getCurrentItemData(\cboShortGroup) ; Added 15Jun2020 11.8.3.2ac because displayed list may not match \cboShortGroup after closing a re-opening Options
      WOP_setupGrdShortcuts()
      SGS(\grdShortcuts, 0)
      WOP_displayShortcuts(0)
      
      ; Moved here from WOP_showGeneral() 28May2020 11.8.3rc5 because the checkboxes are on the Shortcuts tab even though the values are stored in mrGeneralOptions
      SGS(\chkDisableRightClick, mrGeneralOptions\bDisableRightClickAsGo)
      ; debugMsg(sProcName, "mrGeneralOptions\bCtrlOverridesExclCue=" + strB(mrGeneralOptions\bCtrlOverridesExclCue) + ", \bHotkeysOverrideExclCue=" + strB(mrGeneralOptions\bHotkeysOverrideExclCue))
      SGS(\chkCtrlOverridesExclCue, mrGeneralOptions\bCtrlOverridesExclCue)
      SGS(\chkHotkeysOverrideExclCue, mrGeneralOptions\bHotkeysOverrideExclCue)
      ; End moved here 28May2020 11.8.3rc5
      
      grWOP\bGrdShortcutsSetup = #True
    EndIf
    setVisible(\cntShortcuts, #True)
  EndWith
  
EndProcedure

Procedure WOP_showEditingOptions()
  PROCNAMEC()
  Protected nListIndex
  
  With mrEditingOptions
    If grLicInfo\bExternalEditorsIncluded
      SGT(WOP\txtAudioEditor, \sAudioEditor)
      SGT(WOP\txtImageEditor, \sImageEditor)
      SGT(WOP\txtVideoEditor, \sVideoEditor)
    EndIf
    
    nListIndex = indexForComboBoxData(WOP\cboFileScanMaxLengthAudio, \nFileScanMaxLengthAudio)
    SGS(WOP\cboFileScanMaxLengthAudio, nListIndex)
    nListIndex = indexForComboBoxData(WOP\cboFileScanMaxLengthVideo, \nFileScanMaxLengthVideo)
    SGS(WOP\cboFileScanMaxLengthVideo, nListIndex)
    
    SGS(WOP\chkSaveAlwaysOn, \bSaveAlwaysOn)
    SGS(WOP\chkIgnoreTitleTags, \bIgnoreTitleTags)
    setComboBoxByData(WOP\cboAudioFileSelector, \nAudioFileSelector, 0)
    SGS(WOP\chkIncludeAllLevelPointDevices, \bIncludeAllLevelPointDevices)
    SGS(WOP\chkCheckMainLostFocusWhenEditorOpen, \bCheckMainLostFocusWhenEditorOpen)
    SGS(WOP\chkActivateOCMAutoStarts, \bActivateOCMAutoStarts)
    setComboBoxByData(WOP\cboEditorCueListFontSize, \nEditorCueListFontSize, 0)
  EndWith
  
  setVisible(WOP\cntEditing, #True)

EndProcedure

Procedure WOP_showVideoDriver()
  PROCNAMEC()
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  With mrVideoDriver
    nListIndex = indexForComboBoxData(WOP\cboVideoLibrary, \nVideoPlaybackLibrary, 0)
    SGS(WOP\cboVideoLibrary, nListIndex)
    WOP_fcVideoLibrary()
    If \nVideoPlaybackLibrary = #SCS_VPL_TVG
      setComboBoxByData(WOP\cboTVGPlayerHwAccel, \nTVGPlayerHwAccel, 0)
    EndIf
    SGS(WOP\chkTVGDisplayVUMeters, \bTVGDisplayVUMeters)
    SGS(WOP\chkDisableVideoWarningMessage, \bDisableVideoWarningMessage)
    WOP_populateSplitScreenInfo()
    WOP_populateGrdScreens()
  EndWith
  
  setVisible(WOP\cntVideoDriver, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_btnRAIIPInfo_Click()
  PROCNAMEC()
  
  showMoreInfoForCompIPAddresses()
  
EndProcedure

Procedure WOP_btnFMAllInfo_Click()
  PROCNAMEC()
  
  showMoreInfoForCompIPAddresses()
  
EndProcedure

Procedure WOP_showRAIOptions()
  PROCNAMEC()
  Protected nListIndex, bOSCVersionVisible, bNetworkProtocolEnabled
  
  debugMsg(sProcName, #SCS_START)
  
  With mrRAIOptions
    SGS(WOP\chkRAIEnabled, \bRAIEnabled)
    
    nListIndex = indexForComboBoxData(WOP\cboRAIApp, \nRAIApp, 0)
    SGS(WOP\cboRAIApp, nListIndex)
    
    If \nRAIApp = #SCS_RAI_APP_OSC
      bNetworkProtocolEnabled = #True
    EndIf
    setComboBoxByData(WOP\cboRAINetworkProtocol, \nNetworkProtocol)
    setEnabled(WOP\cboRAINetworkProtocol, bNetworkProtocolEnabled)
    
    If \nRAIApp = #SCS_RAI_APP_OSC And \nNetworkProtocol = #SCS_NETWORK_PR_TCP
      bOSCVersionVisible = #True
      setComboBoxByData(WOP\cboRAIOSCVersion, \nRAIOSCVersion)
    EndIf
    setVisible(WOP\lblRAIOSCVersion, bOSCVersionVisible)
    setVisible(WOP\cboRAIOSCVersion, bOSCVersionVisible)
    
    If CountGadgetItems(WOP\cboRAILocalIPAddr) > 0
      nListIndex = indexForComboBoxRow(WOP\cboRAILocalIPAddr, \sLocalIPAddr, 0) ; nb if \sLocalIPAddr not found in list (eg because cable unplugged), default to the first entry in the list
      SGS(WOP\cboRAILocalIPAddr, nListIndex)
    EndIf
    SGT(WOP\txtRAILocalPort, Str(\nLocalPort))
  EndWith
  
  setVisible(WOP\cntRAI, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_showFMOptions()
  ; Function Mode - (ie SCS Primary, SCS Backup, or Stand-Alone)
  PROCNAMEC()
  Protected nListIndex, nListIndexIP
  Protected nTestIPLoc
  
  debugMsg(sProcName, #SCS_START)
  
  nTestIPLoc = GGS(WOP\cboFMLocalIPAddr)
  
  With mrFMOptions
    ; Functional Mode Index
    nListIndex = indexForComboBoxData(WOP\cboFMFunctionalMode, \nFunctionalMode, 0)
    SGS(WOP\cboFMFunctionalMode, nListIndex)
    ; IP Address Index
    If nTestIPLoc = -1
      SGT(WOP\cboFMLocalIPAddr, \sFMLocalIPAddr)
      If Len(Trim(GGT(WOP\cboFMLocalIPAddr))) < 1
        SGS(WOP\cboFMLocalIPAddr, 0)
      EndIf
    Else  
      nListIndexIP = indexForComboBoxData(WOP\cboFMLocalIPAddr, nTestIPLoc, 0)
      SGS(WOP\cboFMLocalIPAddr, nListIndexIP)
    EndIf
    ; Server Name
    SGT(WOP\txtFMServerAddr, \sFMServerName)
    ; Set the Check Boxes for Backup Machine
    SGS(WOP\chkBackupIgnoreLIGHTING, \bBackupIgnoreLightingDMX)
    SGS(WOP\chkBackupIgnoreCtrlSendMIDI, \bBackupIgnoreCSMIDI)
    SGS(WOP\chkBackupIgnoreCtrlSendNETWORK, \bBackupIgnoreCSNetwork)
    SGS(WOP\chkBackupIgnoreCueCtrlDevs, \bBackupIgnoreCCDevs)
   
    ; Description Information
    setVisible(WOP\lblFMDescription, #True)  
    Select mrFMOptions\nFunctionalMode
      Case #SCS_FM_STAND_ALONE
        SGT(WOP\lblFMDescription,  Lang("Common","StandAlone"))
      Case #SCS_FM_PRIMARY
        SGT(WOP\lblFMDescription,  Lang("Common","PrimaryMode"))
      Case #SCS_FM_BACKUP
        SGT(WOP\lblFMDescription,  Lang("Common","BackupMode"))
    EndSelect
    setGadgetWidth(WOP\lblFMDescription, -1)
    
    If nListIndex = 0 ; Stand-Alone Mode
      ; Mode Visibility
      setVisible(WOP\lblFMFunctionalMode, #True)
      setVisible(WOP\cboFMFunctionalMode, #True)
      ; Local Server IP
      setVisible(WOP\lblFMLocalIPAddr, #False)
      setVisible(WOP\cboFMLocalIPAddr, #False)
      ; Backup Ignore Settings
      setVisible(WOP\chkBackupIgnoreLIGHTING, #False)
      setVisible(WOP\chkBackupIgnoreCtrlSendMIDI, #False)
      setVisible(WOP\chkBackupIgnoreCtrlSendNETWORK, #False)
      setVisible(WOP\chkBackupIgnoreCueCtrlDevs, #False)
      ; Server Address
      setVisible(WOP\txtFMServerAddr, #False)
      setVisible(WOP\lblFMServerAddr, #False)
      ; IP Info 
      setVisible(WOP\btnFMIPInfo, #False)
      ; Ip Connection
      setVisible(WOP\lblFMFuncMode, #False)
      
    ElseIf nListIndex = 1 ; Primary Mode
      ; Mode Visibility
      setVisible(WOP\lblFMFunctionalMode, #True)
      setVisible(WOP\cboFMFunctionalMode, #True)
      ; Local Server IP
      setVisible(WOP\lblFMLocalIPAddr, #True)
      setVisible(WOP\cboFMLocalIPAddr, #True)  
      ; Backup Ignore Settings
      setVisible(WOP\chkBackupIgnoreLIGHTING, #False)
      setVisible(WOP\chkBackupIgnoreCtrlSendMIDI, #False)
      setVisible(WOP\chkBackupIgnoreCtrlSendNETWORK, #False)
      setVisible(WOP\chkBackupIgnoreCueCtrlDevs, #False)
      ; Server Address
      setVisible(WOP\txtFMServerAddr, #False)
      setVisible(WOP\lblFMServerAddr, #False)
      ; IP Info 
      setVisible(WOP\btnFMIPInfo, #True)
      ; Ip Connection
      setVisible(WOP\lblFMFuncMode, #True)
      
    ElseIf nListIndex = 2 ; Backup Mode
      ; Mode Visibility
      setVisible(WOP\lblFMFunctionalMode, #True)
      setVisible(WOP\cboFMFunctionalMode, #True)
      ; Local Server IP
      setVisible(WOP\lblFMLocalIPAddr, #False)
      setVisible(WOP\cboFMLocalIPAddr, #False)  
      ; Backup Ignore Settings 
      setVisible(WOP\chkBackupIgnoreLIGHTING, #True)
      setVisible(WOP\chkBackupIgnoreCtrlSendMIDI, #True)
      setVisible(WOP\chkBackupIgnoreCtrlSendNETWORK, #True)
      setVisible(WOP\chkBackupIgnoreCueCtrlDevs, #True)
      ; Server Address
      setVisible(WOP\txtFMServerAddr, #True)
      setVisible(WOP\lblFMServerAddr, #True)      
      ; IP Info 
      setVisible(WOP\btnFMIPInfo, #False)
      ; IP Connection
      setVisible(WOP\lblFMFuncMode, #False)
      
    EndIf
    
  EndWith
  
  setVisible(WOP\cntFM, #True) 
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_showSessionOptions()
  PROCNAMEC()
  Protected bEnableControls, nSetIndex
  
  ; debugMsg(sProcName, "mrSession\nMidiEnabled=" + Str(mrSession\nMidiEnabled) + ", grSession\nMidiEnabled=" + Str(grSession\nMidiEnabled))
  
  setMidiEnabled()
  setRS232Enabled()
  setDMXEnabled()
  setNetworkEnabled()
  
  ; debugMsg(sProcName, "mrSession\nMidiEnabled=" + Str(mrSession\nMidiEnabled))
  With WOP
    ; CONTROL SEND DEVICE TYPES
    ; MIDI Out
    Select mrSession\nMidiOutEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optMidiOutEnabled[0], bEnableControls)
    setEnabled(\optMidiOutEnabled[1], bEnableControls)
    setEnabled(\optMidiOutEnabled[2], #False)  ; always false
    SGS(\optMidiOutEnabled[nSetIndex], #True)
    
    ; RS232 Out
    Select mrSession\nRS232OutEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optRS232OutEnabled[0], bEnableControls)
    setEnabled(\optRS232OutEnabled[1], bEnableControls)
    setEnabled(\optRS232OutEnabled[2], #False)  ; always false
    SGS(\optRS232OutEnabled[nSetIndex], #True)
    
    ; DMX Out
    Select mrSession\nDMXOutEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optDMXOutEnabled[0], bEnableControls)
    setEnabled(\optDMXOutEnabled[1], bEnableControls)
    setEnabled(\optDMXOutEnabled[2], #False)  ; always false
    SGS(\optDMXOutEnabled[nSetIndex], #True)
    
    ; Network Out
    Select mrSession\nNetworkOutEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optNetworkOutEnabled[0], bEnableControls)
    setEnabled(\optNetworkOutEnabled[1], bEnableControls)
    setEnabled(\optNetworkOutEnabled[2], #False)  ; always false
    SGS(\optNetworkOutEnabled[nSetIndex], #True)
    
    ; CUE CONTROL DEVICE TYPES
    ; MIDI In
    Select mrSession\nMidiInEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optMidiInEnabled[0], bEnableControls)
    setEnabled(\optMidiInEnabled[1], bEnableControls)
    setEnabled(\optMidiInEnabled[2], #False)  ; always false
    SGS(\optMidiInEnabled[nSetIndex], #True)
    
    ; RS232 In
    Select mrSession\nRS232InEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optRS232InEnabled[0], bEnableControls)
    setEnabled(\optRS232InEnabled[1], bEnableControls)
    setEnabled(\optRS232InEnabled[2], #False)  ; always false
    SGS(\optRS232InEnabled[nSetIndex], #True)
    
    ; DMX In
    Select mrSession\nDMXInEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optDMXInEnabled[0], bEnableControls)
    setEnabled(\optDMXInEnabled[1], bEnableControls)
    setEnabled(\optDMXInEnabled[2], #False)  ; always false
    SGS(\optDMXInEnabled[nSetIndex], #True)
    
    ; Network In
    Select mrSession\nNetworkInEnabled
      Case #SCS_DEVTYPE_ENABLED
        bEnableControls = #True
        nSetIndex = 0
      Case #SCS_DEVTYPE_DISABLED
        bEnableControls = #True
        nSetIndex = 1
      Default ; #SCS_DEVTYPE_NOT_REQD
        bEnableControls = #False
        nSetIndex = 2
    EndSelect
    setEnabled(\optNetworkInEnabled[0], bEnableControls)
    setEnabled(\optNetworkInEnabled[1], bEnableControls)
    setEnabled(\optNetworkInEnabled[2], #False)  ; always false
    SGS(\optNetworkInEnabled[nSetIndex], #True)
    
  EndWith
  
  setVisible(WOP\cntSession, #True)
  
EndProcedure

Procedure WOP_populateContainerForNode(nOptNode)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nOptNode=" + nOptNode)
  
  Select nOptNode
    Case #SCS_OPTNODE_ROOT, #SCS_OPTNODE_GENERAL  ; general
      WOP_showGeneral()
      
    Case #SCS_OPTNODE_DISPLAY, #SCS_OPTNODE_DISPLAY_DESIGN, #SCS_OPTNODE_DISPLAY_REHEARSAL, #SCS_OPTNODE_DISPLAY_PERFORMANCE  ; display options
      If nOptNode = #SCS_OPTNODE_DISPLAY_PERFORMANCE
        grWOP\nNodeOperMode = #SCS_OPERMODE_PERFORMANCE
      ElseIf nOptNode = #SCS_OPTNODE_DISPLAY_REHEARSAL
        grWOP\nNodeOperMode = #SCS_OPERMODE_REHEARSAL
      Else
        grWOP\nNodeOperMode = #SCS_OPERMODE_DESIGN
      EndIf
      WOP_showDisplayOptions()
      
    Case #SCS_OPTNODE_COLS, #SCS_OPTNODE_COLS_DESIGN, #SCS_OPTNODE_COLS_REHEARSAL, #SCS_OPTNODE_COLS_PERFORMANCE ; cue list columns
      If nOptNode = #SCS_OPTNODE_COLS_PERFORMANCE
        grWOP\nNodeOperMode = #SCS_OPERMODE_PERFORMANCE
      ElseIf nOptNode = #SCS_OPTNODE_COLS_REHEARSAL
        grWOP\nNodeOperMode = #SCS_OPERMODE_REHEARSAL
      Else
        grWOP\nNodeOperMode = #SCS_OPERMODE_DESIGN
      EndIf
      WOP_showCueListCols()
      
    Case #SCS_OPTNODE_AUDIO_DRIVER, #SCS_OPTNODE_BASS_DS, #SCS_OPTNODE_BASS_ASIO, #SCS_OPTNODE_SMS_ASIO  ; audio driver
      ; 'DS' originally just for DirectSound, but now also includes WASAPI
      WOP_showAudioDriver(nOptNode)
      
    Case #SCS_OPTNODE_VIDEO_DRIVER   ; video driver
      WOP_showVideoDriver()
      
    Case #SCS_OPTNODE_RAI     ; remote app interface
      WOP_showRAIOptions()
      
    Case #SCS_OPTNODE_FUNCTIONAL_MODE ; Functional Mode for Primary/Backup System
      WOP_showFMOptions()
    
    Case #SCS_OPTNODE_EDITING   ; editing options
      WOP_showEditingOptions()
      
    Case #SCS_OPTNODE_SHORTCUTS   ; shortcuts
      WOP_showShortcuts()
      
    Case #SCS_OPTNODE_SESSION   ; session options
      WOP_showSessionOptions()
      
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOP_fcSwapMonitors1And2()
  PROCNAMEC()
  If mrGeneralOptions\bSwapMonitors1and2
    setEnabled(WOP\cboSwapMonitor, #True)
  Else
    setEnabled(WOP\cboSwapMonitor, #False)
  EndIf
  
EndProcedure

Procedure WOP_chkSwapMonitors1and2_Click()
  PROCNAMEC()
  
  With mrGeneralOptions
    If GGS(WOP\chkSwapMonitors1and2)
      \bSwapMonitors1and2 = #True
    Else
      \bSwapMonitors1and2 = #False
    EndIf
    debugMsg(sProcName, "\bSwapMonitors1and2=" + strB(\bSwapMonitors1and2))
  EndWith
  WOP_fcSwapMonitors1And2()
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_cboSwapMonitor_Click()
  mrGeneralOptions\nSwapMonitor = getCurrentItemData(WOP\cboSwapMonitor)
  grWOP\mbChanges = #True
  WOP_setButtons()
EndProcedure

Procedure WOP_deviceEnabled_Click()
  PROCNAMEC()
  Protected sTitle.s, sMsg.s, bChanges = #True
  
  With mrSession
    Select gnEventGadgetNoForEvHdlr
        
        ; CONTROL SEND DEVICE TYPES
      Case WOP\optMidiOutEnabled[0]
        If GGS(WOP\optMidiOutEnabled[0])
          \nMidiOutEnabled = #SCS_DEVTYPE_ENABLED
          If \nMidiInEnabled = #SCS_DEVTYPE_DISABLED
            ; See also "Case WOP\optMidiOutEnabled[0]" below, and setMidiEnabled() in aamain.pbi
            sTitle = Lang("WOP", "tabSession")
            sMsg = Lang("WOP", "EnableMIDIIn")
            scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_Warning)
            \nMidiInEnabled = #SCS_DEVTYPE_ENABLED
            SGS(WOP\optMidiInEnabled[0], #True)
          EndIf
        ElseIf GGS(WOP\optMidiOutEnabled[1])
          \nMidiOutEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nMidiOutEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Case WOP\optRS232OutEnabled[0]
        If GGS(WOP\optRS232OutEnabled[0])
          \nRS232OutEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optRS232OutEnabled[1])
          \nRS232OutEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nRS232OutEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Case WOP\optNetworkOutEnabled[0]
        If GGS(WOP\optNetworkOutEnabled[0])
          \nNetworkOutEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optNetworkOutEnabled[1])
          \nNetworkOutEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nNetworkOutEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Case WOP\optDMXOutEnabled[0]
        If GGS(WOP\optDMXOutEnabled[0])
          \nDMXOutEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optDMXOutEnabled[1])
          \nDMXOutEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nDMXOutEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
        ; CUE CONTROL DEVICE TYPES
      Case WOP\optMidiInEnabled[0]
        If GGS(WOP\optMidiInEnabled[0])
          \nMidiInEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optMidiInEnabled[1])
          If (\nMidiInEnabled = #SCS_DEVTYPE_ENABLED) And (\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
            ; See also "Case WOP\optMidiOutEnabled[0]" above, and setMidiEnabled() in aamain.pbi
            sTitle = Lang("WOP", "tabSession")
            sMsg = Lang("WOP", "EnableMIDIIn")
            scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_Warning)
            SGS(WOP\optMidiInEnabled[0], #True)
            bChanges = #False
          Else
            \nMidiInEnabled = #SCS_DEVTYPE_DISABLED
          EndIf
        Else
          \nMidiInEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Case WOP\optRS232InEnabled[0]
        If GGS(WOP\optRS232InEnabled[0])
          \nRS232InEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optRS232InEnabled[1])
          \nRS232InEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nRS232InEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Case WOP\optNetworkInEnabled[0]
        If GGS(WOP\optNetworkInEnabled[0])
          \nNetworkInEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optNetworkInEnabled[1])
          \nNetworkInEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nNetworkInEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Case WOP\optDMXInEnabled[0]
        If GGS(WOP\optDMXInEnabled[0])
          \nDMXInEnabled = #SCS_DEVTYPE_ENABLED
        ElseIf GGS(WOP\optDMXInEnabled[1])
          \nDMXInEnabled = #SCS_DEVTYPE_DISABLED
        Else
          \nDMXInEnabled = #SCS_DEVTYPE_NOT_REQD
        EndIf
        
      Default
        debugMsg(sProcName, "Unknown")
        
    EndSelect
  EndWith
  
  If bChanges
    grWOP\mbChanges = #True
  EndIf
  WOP_setButtons()
  
EndProcedure

Procedure WOP_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WOP
    Select nEventGadgetNoForEvHdlr
        
      Case \txtDaysBetweenChecks
        ETVAL2(WOP_txtDaysBetweenChecks_Validate())
        
      Case \txtInitDir
        ETVAL2(WOP_txtInitDir_Validate())
        
      Case \txtLinkSyncPoint
        ETVAL2(WOP_txtLinkSyncPoint_Validate())
        
      Case \txtMaxPreOpenAudioFiles
        ETVAL2(WOP_txtMaxPreOpenAudioFiles_Validate())
        
      Case \txtMaxPreOpenVideoImageFiles
        ETVAL2(WOP_txtMaxPreOpenVideoImageFiles_Validate())
        
      Case \txtMinPChansNonHK
        ETVAL2(WOP_txtMinPChansNonHK_Validate())
        
      Case \txtPlaybackBufLength
        ETVAL2(WOP_txtPlaybackBufLength_Validate())
        
      Case \txtRAILocalPort
        ETVAL2(WOP_txtRAILocalPort_Validate())
        
      Case \txtUpdatePeriodLength
        ETVAL2(WOP_txtUpdatePeriodLength_Validate())
        
      Default
        bFound = #False
        
    EndSelect
  EndWith
  
  If bFound
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WOP_cboAudioFileSelector_Click()
  Protected nAudioFileSelector
  
  nAudioFileSelector = getCurrentItemData(WOP\cboAudioFileSelector)
  If nAudioFileSelector <> mrEditingOptions\nAudioFileSelector
    mrEditingOptions\nAudioFileSelector = nAudioFileSelector
    WOP_setOptionsChanged()
  EndIf
EndProcedure

Procedure WOP_cboColorScheme_Click()
  PROCNAMEC()
  Protected sSelectedSchemeName.s
  
  sSelectedSchemeName = GetGadgetItemText(WOP\cboColorScheme, GGS(WOP\cboColorScheme))
  If sSelectedSchemeName <> mrOperModeOptions(grWOP\nNodeOperMode)\sSchemeName
    mrOperModeOptions(grWOP\nNodeOperMode)\sSchemeName = GetGadgetItemText(WOP\cboColorScheme, GGS(WOP\cboColorScheme))
    grColHnd\bAudioGraphColorsChanged = #True
    WMN_applyDisplayOptions()
    WOP_setOptionsChanged()
  EndIf
EndProcedure

Procedure WOP_cboCtrlPanelPos_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nCtrlPanelPos = getCurrentItemData(WOP\cboCtrlPanelPos)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboCueListFontSize_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nCueListFontSize = getCurrentItemData(WOP\cboCueListFontSize)
  WMN_setCueListFontSize()
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboEditorCueListFontSize_Click()
  mrEditingOptions\nEditorCueListFontSize = getCurrentItemData(WOP\cboEditorCueListFontSize)
  WED_setEditorCueListFontSize()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboCuePanelHeight_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nCuePanelVerticalSizing = Val(StringField(GGT(WOP\cboCuePanelHeight),1,"%"))
  WMN_applyDisplayOptions(#True)
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboMonitorSize_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nMonitorSize = getCurrentItemData(WOP\cboMonitorSize)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

; Procedure WOP_cboMaxMonitor_Click() ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;   mrOperModeOptions(grWOP\nNodeOperMode)\nMaxMonitor = getCurrentItemData(WOP\cboMaxMonitor, -1)
;   WMN_applyDisplayOptions()
;   WOP_setOptionsChanged()
; EndProcedure

Procedure WOP_cboMTCDispLocn_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nMTCDispLocn = getCurrentItemData(WOP\cboMTCDispLocn)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboTimerDispLocn_Click()
  PROCNAMEC()
  mrOperModeOptions(grWOP\nNodeOperMode)\nTimerDispLocn = getCurrentItemData(WOP\cboTimerDispLocn)
  debugMsg(sProcName, "mrOperModeOptions(" + decodeOperMode(grWOP\nNodeOperMode) + ")\nTimerDispLocn=" + decodeTimerDispLocn(mrOperModeOptions(grWOP\nNodeOperMode)\nTimerDispLocn))
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboToolbarInfo_Click()
  PROCNAMEC()
  mrOperModeOptions(grWOP\nNodeOperMode)\nMainToolBarInfo = getCurrentItemData(WOP\cboToolbarInfo)
  debugMsg(sProcName, "GGS(WOP\cboToolbarInfo)=" + Str(GGS(WOP\cboToolbarInfo)) + "getCurrentItemData(WOP\cboToolbarInfo)=" + decodeMainToolBarInfo(getCurrentItemData(WOP\cboToolbarInfo)))
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_cboVUDisplay_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\nVisMode = getCurrentItemData(WOP\cboVUDisplay)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowFaderAndPanControls_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowFaderAndPanControls = GGS(WOP\chkShowFaderAndPanControls)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkRequestConfirmCueClick_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bRequestConfirmCueClick = GGS(WOP\chkRequestConfirmCueClick)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowHidden_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowHiddenAutoStartCues = GGS(WOP\chkShowHidden)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowHKeysInPanels_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowHotkeyCuesInPanels = GGS(WOP\chkShowHKeysInPanels)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowHKeyList_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowHotkeyList = GGS(WOP\chkShowHKeyList)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowMasterFader_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowMasterFader = GGS(WOP\chkShowMasterFader)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowNextManual_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowNextManualCue = GGS(WOP\chkShowNextManual)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowSubCues_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowSubCues = GGS(WOP\chkShowSubCues)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowLvlCurvesPrim_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowLvlCurvesPrim = GGS(WOP\chkShowLvlCurvesPrim)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowLvlCurvesOther_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowLvlCurvesOther = GGS(WOP\chkShowLvlCurvesOther)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowPanCurvesPrim_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowPanCurvesPrim = GGS(WOP\chkShowPanCurvesPrim)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowPanCurvesOther_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowPanCurvesOther = GGS(WOP\chkShowPanCurvesOther)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowTransportControls_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowTransportControls = GGS(WOP\chkShowTransportControls)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowAudioGraph_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowAudioGraph = GGS(WOP\chkShowAudioGraph)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowCueMarkers_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowCueMarkers = GGS(WOP\chkShowCueMarkers)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged() 
EndProcedure

Procedure WOP_chkAllowDisplayTimeout_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bAllowDisplayTimeout = GGS(WOP\chkAllowDisplayTimeout)
  ; WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowToolTips_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowToolTips = GGS(WOP\chkShowToolTips)
  ; WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowMidiCueInCuePanels_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowMidiCueInCuePanels = GGS(WOP\chkShowMidiCueInCuePanels)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkShowMidiCueInNextManual_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bShowMidiCueInNextManual = GGS(WOP\chkShowMidiCueInNextManual)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_chkLimitMovementOfMainWindowSplitterBar_Click()
  mrOperModeOptions(grWOP\nNodeOperMode)\bLimitMovementOfMainWindowSplitterBar = GGS(WOP\chkLimitMovementOfMainWindowSplitterBar)
  WMN_applyDisplayOptions()
  WOP_setOptionsChanged()
EndProcedure

Procedure WOP_populateGrdScreens()
  PROCNAMEC()
  Protected nScreenNo
  Protected nMonitorNo
  Protected nSplitScreenIndex, nMonitorIndex
  Protected n
  Protected sOutputScreenInfo.s
  Protected nRowHeight, nHeight
  
  ClearGadgetItems(WOP\grdScreens)
  
  nScreenNo = 0
  For nMonitorNo = 1 To gnMonitors
    For nSplitScreenIndex = 0 To mrVideoDriver\nSplitScreenArrayMax
      With mrVideoDriver\aSplitScreenInfo[nSplitScreenIndex]
        If \nCurrentMonitorIndex >= 0
          If \nDisplayNo = nMonitorNo
            nMonitorIndex = \nCurrentMonitorIndex
            For n = 0 To (\nSplitScreenCount - 1)
              nScreenNo + 1
              If nScreenNo = 1
                sOutputScreenInfo = "(" + nScreenNo + ")" + Chr(10)
              Else
                sOutputScreenInfo = Str(nScreenNo) + Chr(10)
              EndIf
              sOutputScreenInfo + "X=" + Str(gaMonitors(nMonitorIndex)\nDesktopLeft + (n * gaMonitors(nMonitorIndex)\nDesktopWidth / \nSplitScreenCount))
              sOutputScreenInfo + ", Y=" + Str(gaMonitors(nMonitorIndex)\nDesktopTop)
              sOutputScreenInfo + ", W=" + Str(gaMonitors(nMonitorIndex)\nDesktopWidth / \nSplitScreenCount)
              sOutputScreenInfo + ", H=" + Str(gaMonitors(nMonitorIndex)\nDesktopHeight)
              AddGadgetItem(WOP\grdScreens,-1,sOutputScreenInfo)
            Next n
          EndIf
        EndIf
      EndWith
    Next nSplitScreenIndex
  Next nMonitorNo
  nRowHeight = getGridRowHeight(WOP\grdScreens)
  nHeight = getGridHeaderHeight(WOP\grdScreens) + (nRowHeight * nScreenNo) + gl3DBorderAllowanceY
  ResizeGadget(WOP\grdScreens, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
  autoFitGridCol(WOP\grdScreens,-2)
  JustifyListIconColumn(WOP\grdScreens,0,2)
  
EndProcedure

Procedure WOP_txtDaysBetweenChecks_Change()
  Protected nTmp
  
  With mrGeneralOptions
    nTmp = Val(Trim(GGT(WOP\txtDaysBetweenChecks)))
    If nTmp <> \nDaysBetweenChecks
      \nDaysBetweenChecks = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
EndProcedure

Procedure WOP_txtDaysBetweenChecks_Validate()
  Protected nTmp
  
  With mrGeneralOptions
    nTmp = Val(Trim(GGT(WOP\txtDaysBetweenChecks)))
    If nTmp <> \nDaysBetweenChecks
      \nDaysBetweenChecks = nTmp
      grWOP\mbChanges = #True
      WOP_setButtons()
    EndIf
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WOP_fcEnableAutoCheckForUpdate()
  PROCNAMEC()
  With mrGeneralOptions
    If \bEnableAutoCheckForUpdate
      setEnabled(WOP\txtDaysBetweenChecks, #True)
    Else
      setEnabled(WOP\txtDaysBetweenChecks, #False)
    EndIf
    setTextBoxBackColor(WOP\txtDaysBetweenChecks)
  EndWith
EndProcedure

; EOF

;test