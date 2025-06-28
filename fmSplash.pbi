; File: fmSplash.pbi

EnableExplicit

Procedure WSP_setLicInfo()
  PROCNAMEC()
  Protected nExpiryDate
  Protected sLicLabel.s, sLicUser.s, sLicType.s
  Protected nLeft
  Protected sText.s, nTextWidth
  Protected nGroupLeft, nGroupWidth
  
  With grWSP
    
    CompilerIf #cDemo
      sLicUser = Lang("WSP", "DemoVersion")
    CompilerElseIf #cWorkshop
      sLicUser = "WORKSHOP VERSION"
    CompilerElse
      If grLicInfo\sLicType = "D"
        sLicUser = Lang("WSP", "DemoVersion")
      ElseIf grLicInfo\sLicType = "T"
        nExpiryDate = dateToNumber(grLicInfo\nExpireDate)
        sLicType = "Temporary License expiring " + formatDateAsDDMMMYYYY(nExpiryDate)
      ElseIf grLicInfo\nLicLevel > 0
        sLicLabel = Lang("Common", "LicensedTo")
        sLicUser = grLicInfo\sLicUser
        sLicType = decodeLicType(grLicInfo\sLicType, grLicInfo\dLicExpDate)
      Else
        sLicUser = "Not Registered"
      EndIf
    CompilerEndIf
    
    If StartDrawing(CanvasOutput(WSP\cvsSplash))
      FrontColor(#SCS_SplashScreen_FrontColor)
      BackColor(#SCS_SplashScreen_BackColor)
      
      ; license info
      nGroupLeft = 433
      nGroupWidth = 195
      If sLicLabel
        scsDrawingFont(#SCS_FONT_GEN_BOLD10)
        nTextWidth = TextWidth(sLicLabel)
        If nTextWidth < nGroupWidth
          nLeft = ((nGroupWidth - nTextWidth) >> 1) + nGroupLeft
        Else
          nLeft = nGroupLeft
        EndIf
        DrawText(nLeft,179,sLicLabel)
      EndIf
      If sLicUser
        scsDrawingFont(#SCS_FONT_GEN_BOLD10)
        nTextWidth = TextWidth(sLicUser)
        If nTextWidth < nGroupWidth
          nLeft = ((nGroupWidth - nTextWidth) >> 1) + nGroupLeft
        Else
          nLeft = nGroupLeft
        EndIf
        DrawText(nLeft,197,sLicUser)
      EndIf
      If sLicType
        scsDrawingFont(#SCS_FONT_GEN_BOLD10)
        nTextWidth = TextWidth(sLicType)
        If nTextWidth < nGroupWidth
          nLeft = ((nGroupWidth - nTextWidth) >> 1) + nGroupLeft
          DrawText(nLeft,237,sLicType)
        Else
          WrapTextLeft(nGroupLeft,237,sLicType,nGroupWidth,#SCS_SplashScreen_FrontColor,#SCS_SplashScreen_BackColor)
        EndIf
      EndIf
      
      StopDrawing()
    EndIf
    
  EndWith
  
EndProcedure

Procedure WSP_drawSplash()
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected nLeft
  Protected sText.s, nTextWidth
  
  debugMsg(sProcName, #SCS_START)
  
  If IsGadget(WSP\cvsSplash)
    If StartDrawing(CanvasOutput(WSP\cvsSplash))
      FrontColor(#SCS_SplashScreen_FrontColor)
      BackColor(#SCS_SplashScreen_BackColor)
      nCanvasWidth = GadgetWidth(WSP\cvsSplash)
      nCanvasHeight = GadgetHeight(WSP\cvsSplash)
      Box(0,0,nCanvasWidth,nCanvasHeight,#SCS_SplashScreen_BackColor)
      
      ; logo
      DrawImage(ImageID(hSplashScreenLogo),0,0)
      
      ; copyright and version
      LineXY(0,291,nCanvasWidth,291)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
      DrawText(4,296,grProgVersion\sCopyRight)
      debugMsg(sProcName, "grProgVersion\sCopyRight=" + grProgVersion\sCopyRight)
      sText = " SCS " + #SCS_VERSION + " (" + #SCS_PROCESSOR + ") "
      nTextWidth = TextWidth(sText)
      nLeft = nCanvasWidth - gl3DBorderAllowanceX - nTextWidth
      DrawText(nLeft,296,sText)
      
      StopDrawing()
    EndIf
  EndIf
  
EndProcedure

Procedure WSP_drawText(X,Y,nWidth,nHeight,sText.s,nFont,bReverseColors=#False,nAlign=0)
  PROCNAMEC()
  ; self-contained DrawText procedure, ie including StartDrawing() etc
  Protected nFrontColor, nBackColor
  Protected nLeft, nTextWidth
  
  If bReverseColors
    nFrontColor = #SCS_SplashScreen_BackColor
    nBackColor = #SCS_SplashScreen_FrontColor
  Else
    nFrontColor = #SCS_SplashScreen_FrontColor
    nBackColor = #SCS_SplashScreen_BackColor
  EndIf
  
  If StartDrawing(CanvasOutput(WSP\cvsSplash))
    FrontColor(nFrontColor)
    BackColor(nBackColor)
    scsDrawingFont(nFont)
    Box(X,Y,nWidth,nHeight,nBackColor)  ; clear any previous longer text
    nLeft = X
    If nAlign = #PB_Text_Center
      nTextWidth = TextWidth(sText)
      If nTextWidth < nWidth
        nLeft = X + ((nWidth - nTextWidth) >> 1)
      EndIf
    EndIf
    DrawText(nLeft,Y,sText)
    StopDrawing()
  EndIf
  
EndProcedure

Procedure WSP_wrapTextLeft(X,Y,nWidth,nHeight,sText.s,nFont,bReverseColors=#False)
  PROCNAMEC()
  Protected nFrontColor, nBackColor
  
  If bReverseColors
    nFrontColor = #SCS_SplashScreen_BackColor
    nBackColor = #SCS_SplashScreen_FrontColor
  Else
    nFrontColor = #SCS_SplashScreen_FrontColor
    nBackColor = #SCS_SplashScreen_BackColor
  EndIf
  
  If StartDrawing(CanvasOutput(WSP\cvsSplash))
    FrontColor(nFrontColor)
    BackColor(nBackColor)
    scsDrawingFont(nFont)
    Box(X,Y,nWidth,nHeight,nBackColor)  ; clear any previous longer text
    WrapTextLeft(X,Y,sText,nWidth,nFrontColor,nBackColor)
    StopDrawing()
  EndIf
  
EndProcedure

Procedure WSP_setProdTitle(sTitle.s)
  WSP_wrapTextLeft(6,197,400,57,sTitle + " ",#SCS_FONT_GEN_ITALIC16)
EndProcedure

Procedure WSP_setStatus(sStatus.s)
  WSP_drawText(7,178,300,22,sStatus,#SCS_FONT_GEN_NORMAL10)
  grWSP\sStatus = sStatus
  grWSP\bStatusVisible = #True
EndProcedure

Procedure.s WSP_getStatus()
  ProcedureReturn grWSP\sStatus
EndProcedure

Procedure WSP_setStatusVisible(bVisible)
  If bVisible
    WSP_drawText(7,178,300,22,grWSP\sStatus,#SCS_FONT_GEN_NORMAL10)
    grWSP\bStatusVisible = #True
  Else
    WSP_drawText(7,178,300,22,"",#SCS_FONT_GEN_NORMAL10)
    grWSP\bStatusVisible = #False
  EndIf
EndProcedure

Procedure WSP_getStatusVisible()
  ProcedureReturn grWSP\bStatusVisible
EndProcedure

Procedure WSP_setTimeProfile(sTimeProfile.s)
  If StartDrawing(CanvasOutput(WSP\cvsSplash))
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(411,23,199,36,#SCS_SplashScreen_FrontColor)
    StopDrawing()
  EndIf
  WSP_drawText(412,24,197,17,Lang("WSP","lblTimeProfile"),#SCS_FONT_GEN_BOLD10,#False,#PB_Text_Center)
  WSP_drawText(412,41,197,17,sTimeProfile,#SCS_FONT_GEN_BOLD10,#False,#PB_Text_Center)
EndProcedure

Procedure WSP_setDevMap(sDevMap.s)
  PROCNAMEC()
  
  debugMsg(sProcName, "sDevMap=" + sDevMap)
  If StartDrawing(CanvasOutput(WSP\cvsSplash))
    Box(21,254,197,34,#SCS_SplashScreen_BackColor)
    StopDrawing()
  EndIf
  WSP_drawText(21,254,197,17,Lang("WSP","lblDevMap"),#SCS_FONT_GEN_BOLD10,#True,#PB_Text_Center)
  WSP_drawText(21,271,197,17,sDevMap,#SCS_FONT_GEN_BOLD10,#True,#PB_Text_Center)
EndProcedure

Procedure WSP_primeSplash()
  PROCNAMEC()
  Protected nLeft
  
  ; debugMsg(sProcName, #SCS_START)
  
  grWSP\bDisplaySplashWhenReady = #False
  WSP_setLicInfo()
  ; debugMsg(sProcName, "gbModalDisplayed=" + strB(gbModalDisplayed))
  
  WSP_setProdTitle(grProd\sTitle)
  WSP_setStatus(LangEllipsis("WSP","Loading"))
  
  If gsWhichTimeProfile
    debugMsg(sProcName, "gsWhichTimeProfile=" + gsWhichTimeProfile)
    WSP_setTimeProfile(gsWhichTimeProfile)
  EndIf
  
  If gbModalDisplayed = #False
    setWindowVisible(#WSP, #True)
    gbSplashOnTop = #True
    
    If gbDoDebug = #False
      setWindowSticky(#WSP, #True)
    EndIf
  Else
    grWSP\bDisplaySplashWhenReady = #True
  EndIf
  
  ; gbKillSplashTimerNow = #False
  ; gbKillSplashTimerEarly = #False
  gqSplashStartedTime = ElapsedMilliseconds()
  AddWindowTimer(#WSP, #SCS_TIMER_SPLASH, 100)  ; 100 milliseconds between timer calls
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WSP_continueLoadingA()
  PROCNAMEC()
  Protected nQuotePtr
  Protected d, n, nChan.l
  Protected nBassVersion.l, nBassMixerVersion.l, nTagsVersion.l
  Protected lngAdditionalFilesAvailable
  Protected nCounter.l
  Protected nPlugin.i
  Protected *nPluginInfoPtr.BASS_PLUGININFO
  Protected *nPluginForm.BASS_PLUGINFORM
  Protected sName.s, sExtensions.s, sReqdExtensions.s
  Protected sOneExtension.s
  Protected nExtensionCount
  Protected hDirectoryId
  Protected sFileName.s
  Protected bResult
  
  Debug sProcName + ": start"
  debugMsg(sProcName, #SCS_START)
  
  gbSplashWindow = #True
  gbMidiTestWindow = #False
  grDMX\bDMXTestWindowActive = #False
  gbSplashOnTop = #False
  gbModalDisplayed = #False
  
  debugMsg(sProcName, "gsAppPath=" + gsAppPath)
  ; change and set the current path so program shouldn't ever tell you, that "bass.dll" isn't found
  SetCurrentDirectory(gsAppPath)
  
  ; check bass loaded ok and correct version
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; check the correct version of BASS was loaded
    nBassVersion = BASS_GetVersion()
    debugMsg(sProcName, "BASS_GetVersion() returned $" + Hex(nBassVersion,#PB_Long))
    If HIWORD(nBassVersion) <> #BASSVERSION
      debugMsg(sProcName, "BASSVERSION=$" + Hex(#BASSVERSION,#PB_Long) + ", HiWord(BASS_GetVersion())=$" + Hex(HIWORD(nBassVersion),#PB_Long))
      ensureSplashNotOnTop()
      scsMessageRequester(#SCS_TITLE, "An incorrect version of bass.dll was loaded", #PB_MessageRequester_Error)
      ; terminate program immediately
      End
    EndIf
    
    ; check the correct version of BASSMIX was loaded
    nBassMixerVersion = BASS_Mixer_GetVersion()
    debugMsg(sProcName, "BASS_Mixer_GetVersion() returned $" + Hex(nBassMixerVersion,#PB_Long))
    If HIWORD(BASS_Mixer_GetVersion()) <> #BASSVERSION
      debugMsg(sProcName, "BASSVERSION=" + Hex(#BASSVERSION) + ", HiWord(BASS_Mixer_GetVersion())=" + Hex(HIWORD(BASS_Mixer_GetVersion())))
      ensureSplashNotOnTop()
      scsMessageRequester(#SCS_TITLE, "An incorrect version of bassmix.dll was loaded", #PB_MessageRequester_Error)
      ; terminate program immediately
      End
    EndIf
  CompilerEndIf
  
  setMouseCursorBusy()
  
  ; force load of tags.dll
  nTagsVersion = TAGS_GetVersion()
  debugMsg(sProcName, "TAGS_GetVersion() returned $" + Hex(nTagsVersion,#PB_Long))
  
  ; load all available BASS plugins
  gsPluginAllAudioFilesPattern = ""
  gsPluginAudioFilePattern = ""
  hDirectoryId = ExamineDirectory(#PB_Any, gsAppPath, "bass*.dll")
  
  If hDirectoryId <> 0
    While NextDirectoryEntry(hDirectoryId)
      If DirectoryEntryType(hDirectoryId) = #PB_DirectoryEntry_File
        sFileName = DirectoryEntryName(hDirectoryId)
        Select LCase(sFileName)
          Case "bass.dll", "bassmix.dll", "bassasio.dll", "bassenc.dll", "basswasapi.dll", "bass_fx.dll", "bass_vst.dll"
            ; not a 'plugin', so ignore
          Case "bass_dshow.dll"
            ; also ignore bass_dshow
          Default
            debugMsg(sProcName, "loading plugin " + sFileName)
            gsFile = sFileName
            nPlugin = BASS_PluginLoad(gsFile, #SCS_BASS_UNICODE)
            ; debugMsg(sProcName, "nPlugin=" + Str(nPlugin))
            If nPlugin
              *nPluginInfoPtr = BASS_PluginGetInfo(nPlugin)
              ; debugMsg(sProcName, "*nPluginInfoPtr=" + *nPluginInfoPtr)
              If *nPluginInfoPtr
                *nPluginForm = *nPluginInfoPtr\formats
                ; debugMsg(sProcName, "*nPluginForm=" + *nPluginForm)
                If *nPluginForm
                  ; debugMsg(sProcName, "*nPluginInfoPtr\formatc=" + Str(*nPluginInfoPtr\formatc))
                  For nCounter = 0 To (*nPluginInfoPtr\formatc-1)
                    sName = PeekS(*nPluginForm\name, -1, #PB_Ascii)
                    sExtensions = PeekS(*nPluginForm\exts, -1, #PB_Ascii)
                    nExtensionCount = CountString(sExtensions,";") + 1
                    sReqdExtensions = ""
                    For n = 1 To nExtensionCount
                      sOneExtension = StringField(sExtensions,n,";")
                      Select sOneExtension
                        Case "*.wav", "*.mp3", "*.wma", "*.ogg", "*.aif", "*.aiff"
                          ; omit as already included in the standard list
                        Case "*.mp4"
                          ; omit as this is a video format but is included by bass_aac.dll
                        Case "*.aac", "*.m4a"
                          ; if gnOSVersion >= #PB_OS_Windows_7 then ignore as these extensions are included in the standard list
                          If gnOSVersion < #PB_OS_Windows_7
                            If FindString(gsPluginAllAudioFilesPattern, sOneExtension) = 0
                              sReqdExtensions + ";" + sOneExtension
                            EndIf
                          EndIf
                        Default
                          If FindString(gsPluginAllAudioFilesPattern, sOneExtension) = 0
                            sReqdExtensions + ";" + sOneExtension
                          EndIf
                      EndSelect
                    Next
                    debugMsg(sProcName, "sName=" + sName + ", sExtensions=" + sExtensions + ", sReqdExtensions=" + sReqdExtensions)
                    If Len(sReqdExtensions) > 1
                      gsPluginAudioFilePattern + "|" + sName + " (" + Mid(sReqdExtensions,2) + ")|" + Mid(sReqdExtensions,2)
                      gsPluginAllAudioFilesPattern + sReqdExtensions
                    EndIf
                    *nPluginForm + SizeOf(BASS_PLUGINFORM)
                  Next nCounter
                EndIf
              EndIf
            EndIf
        EndSelect
      EndIf
    Wend
  EndIf
  FinishDirectory(hDirectoryId)
  debugMsg(sProcName, "gsPluginAudioFilePattern=" + gsPluginAudioFilePattern)
  debugMsg(sProcName, "gsPluginAllAudioFilesPattern=" + gsPluginAllAudioFilesPattern)
  
  gsCommand = ""
  If CountProgramParameters() > 0
    gsCommand = Trim(ProgramParameter())
    If Len(gsCommand) > 2
      If Left(gsCommand, 1) = Chr(34)
        gsCommand = Mid(gsCommand, 2)
        nQuotePtr = FindString(gsCommand, Chr(34), 1)
        If nQuotePtr > 1
          gsCommand = Left(gsCommand, nQuotePtr - 1)
        Else
          gsCommand = ""
        EndIf
      EndIf
    EndIf
  EndIf
  
  gsRecoveryFile = gsTempFolderPath + "scsrecovery.scsr"
  
  debugMsg(sProcName, "calling initialisePart2()")
  bResult = initialisePart2()
  If bResult = #False
    Debug sProcName + ": end(1)"
    ProcedureReturn #False
  EndIf
  
  debugMsg(sProcName, "calling WSP_continueLoadingB()")
  WSP_continueLoadingB()
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  Debug sProcName + ": end(2)"
  ProcedureReturn #True
EndProcedure

Procedure WSP_continueLoadingB()
  PROCNAMEC()
  Protected bShowLoadProdAtStart
  Protected nTimeSinceStart
  
  Debug sProcName + ": start"
  debugMsg(sProcName, #SCS_START)
  
  gbRecovering = #False
  If FileExists(gsRecoveryFile)
    debugMsg(sProcName, "FileExists(" + gsRecoveryFile + ") returned #True")
    If getRecoveryFileInfo()
      gbRecovering = #True
    EndIf
  EndIf
  debugMsg(sProcName, "gbRecovering=" + strB(gbRecovering))
  
  debugMsg(sProcName, "calling loadPrefsPart2()")
  loadPrefsPart2()
  
  loadGlobalColorScheme(gsColorScheme)
  debugMsg(sProcName, "grColorScheme\sSchemeName=" + grColorScheme\sSchemeName)
  
  WSP_primeSplash()
  
  gbNoWait = #True
  gnValMsgCount = 0
  ReDim gaValMsg(gnValMsgCount)
  
  If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
    ; if 'SCS Backup' mode then do not display the 'load production' window, and do not automatically open the most recent cue file.
    ; this is because the 'SCS Primary' will send an 'open file' command on accepting the client connection
    WSP_loadNoFile()
  Else
    If (gbRecovering = #False) And (Len(gsCommand) = 0)
      bShowLoadProdAtStart = grLoadProdPrefs\bShowAtStart
      If bShowLoadProdAtStart
        ; ensure splash screen stays visible for at least 1.5 seconds
        nTimeSinceStart = ElapsedMilliseconds() - gqStartTime
        debugMsg(sProcName, "nTimeSinceStart=" + nTimeSinceStart)
        If nTimeSinceStart < 1500
          Delay(1500 - nTimeSinceStart)
        EndIf
        debugMsg(sProcName, "calling WLP_Form_Show(#WSP, #True)")
        WLP_Form_Show(#WSP, #True)
        Debug sProcName + ": end(1)"
        ProcedureReturn
      EndIf
    EndIf
    If bShowLoadProdAtStart = #False
      WSP_loadMostRecentFile()  ; nb openMostRecentFile() called by WSP_loadMostRecentFile() handles gbOpenRecentFile = #True or #False
    EndIf
  EndIf
  
  Debug sProcName + ": end(2)"
  
EndProcedure

Procedure WSP_loadMostRecentFile()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbReadyToLoadMainForm = #True
  openMostRecentFile()  ; nb openMostRecentFile() handles gbOpenRecentFile = #True or #False
  debugMsg(sProcName, "calling WMN_Form_Load")
  WMN_Form_Load()
  
  debugMsg(sProcName, "calling setGoButtonTip")
  setGoButtonTip()
  
  gnCallOpenNextCues = 1
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  gbForceReloadAllDispPanels = #True
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  gbCallSetNavigateButtons = #True
  
  gbNoWait = #False
  
  debugMsg(sProcName, "gsAppPath=" + gsAppPath)
  debugMsg(sProcName, "gsMyDocsPath=" + gsMyDocsPath)
  
  If (gbRecovering) And (grRecoveryFileInfo\fMasterBVLevel >= 0)
;     SLD_setValue(WMN\sldMasterFader, SLD_levelToValue(grRecoveryFileInfo\fMasterBVLevel))
    SLD_setLevel(WMN\sldMasterFader, grRecoveryFileInfo\fMasterBVLevel)
    setMasterFader(grRecoveryFileInfo\fMasterBVLevel)
    debugMsg(sProcName, "calling setAllInputGains()")
    setAllInputGains()
    debugMsg(sProcName, "calling setAllLiveEQ()")
    setAllLiveEQ()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WSP_loadSelectedFile(sCueFile.s, bCreateFromTemplate=#False, bTemplate=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", sCueFile=" + #DQUOTE$ + sCueFile + #DQUOTE$ + ", bCreateFromTemplate=" + strB(bCreateFromTemplate) + ", bTemplate=" + strB(bTemplate))
  
  gbReadyToLoadMainForm = #True
  openSelectedFile(sCueFile, bCreateFromTemplate, bTemplate)
  
  debugMsg(sProcName, "calling WMN_Form_Load")
  WMN_Form_Load()
  
  debugMsg(sProcName, "calling setGoButtonTip")
  setGoButtonTip()
  
  gnCallOpenNextCues = 1
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  gbForceReloadAllDispPanels = #True
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  gbCallSetNavigateButtons = #True
  
  gbNoWait = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WSP_loadNoFile()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbReadyToLoadMainForm = #True
  clearCueFile()
  
  debugMsg(sProcName, "calling WMN_Form_Load")
  WMN_Form_Load()
  
  debugMsg(sProcName, "calling setGoButtonTip")
  setGoButtonTip()
  
  gnCallOpenNextCues = 1
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  gbForceReloadAllDispPanels = #True
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  gbCallSetNavigateButtons = #True
  
  gbNoWait = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WSP_Form_Load()
  PROCNAMEC()
  Protected nLeft
  Protected bPrevRunInitializing
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected nPrevRunDeadlockState, sDiagFile.s
  Protected sMsg.s
  Protected sLastRunState.s
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WSP) = #False
    debugMsg(sProcName, "calling createfmSplash()")
    createfmSplash()
  EndIf
  gbSplashFormLoaded = #True
  debugMsg(sProcName, "gbSplashFormLoaded=" + strB(gbSplashFormLoaded))
  
  WSP_drawSplash()
  
  With WSP
    
    If gbInitialising ; initialising
      
      WSP_setStatus(Lang("WSP", "Initializing"))
      
      gbRecovering = #True
      If grLoadProdPrefs\bShowAtStart
        gbOpenRecentFile = #False ; may be reset #True on exiting #WLP
      Else
        If grSpecialStartInfo\bDoNotOpenMRF
          gbOpenRecentFile = #False
        Else
          gbOpenRecentFile = #True
        EndIf
      EndIf
      
      COND_OPEN_PREFS("Init")
      sLastRunState = ReadPreferenceString("RunState", "C") ; 'C' = closed
      debugMsg(sProcName, "sLastRunState=" + sLastRunState)
      Select sLastRunState
        Case "I"  ; last run state saved in preferences was 'initializing', so run failed or was aborted while loading 'most recent cue file'
          gbOpenRecentFile = #False
        Case "R"  ; last run state saved in preferences was 'running', so run probably crashed, which may have been due to a deadlock or lock timeout
      EndSelect
      setRunState("I")  ; indicates SCS now initializing
      COND_CLOSE_PREFS()
      
      loadPrefsRegistration()
      debugMsg(sProcName, "\sLicUser=" + grLicInfo\sLicUser + ", \sLicType=" + grLicInfo\sLicType + ", \nLicLevel=" + grLicInfo\nLicLevel)
      ; loadPrefsPart1()  ; 2Apr2018 11.7.0.1: moved call to loadPrefsPart1() to initialisePart1() after call to loadPrefsPart0()
      
      If gnCurrAudioDriver = 0
        setCurrAudioDriver(gnDefaultAudioDriver)
      EndIf
      
      setFileTypeList()
      
      CompilerIf #cDemo Or #cWorkshop
        setWindowVisible(#WSP, #True)
        WSP_continueLoadingA()
      CompilerElse
        debugMsg(sProcName, "grLicInfo\nLicLevel=" + grLicInfo\nLicLevel)
        If (grLicInfo\nLicLevel <> #SCS_LIC_DEMO) And (grLicInfo\nLicLevel <> 0)
          WSP_setLicInfo()
          setWindowVisible(#WSP, #True)
          WSP_continueLoadingA()
        Else
          WRG_Form_Show(#True, #WSP)
          ProcedureReturn
        EndIf
      CompilerEndIf
      
      ; call WMN_setupGridDefaults() now so that column info is set up for the Options screen if that is called directly from the 'Load Production' window (#WLP)
      ; before the 'Main' window (#WMN) has been loaded. WMN_setupGridDefaults() will be called again when #WMN is loaded and resized so that the correct default
      ; column widths can be calculated for the resized form, ie the resized font #SCS_FONT_WMN_GRDCUES.
      debugMsg(sProcName, "calling WMN_setupGridDefaults()")
      WMN_setupGridDefaults()
      
    Else
      ; not initialising
      WSP_setLicInfo()
      setWindowVisible(#WSP, #True)
      
    EndIf
    
  EndWith
  
  If gbKillSplashTimerEarly
    gbKillSplashTimerNow = gbKillSplashTimerEarly
  EndIf
  debugMsg(sProcName, "gbKillSplashTimerNow=" + strB(gbKillSplashTimerNow))
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WSP_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  gbSplashWindow = #False
  gbKillSplashTimerNow = #False
  gbKillSplashTimerEarly = #False
  If gbInitialising
    gbClosingDown = #True  ; forces WaitWindowEvent() loop to terminate
  ElseIf IsWindow(#WSP)
    ; nb 'animate' works OK but currently the splash window seems to get hidden when the main screen is painted.
    ; reinstate 'animate' when we get the splash screen always on top.
    ; for more #AW... constants, see animate_window.pb in "PB Test Files".
    ; debugMsg(sProcName, "animate close")
    ; AnimateWindow_(WindowID(#WSP),750,#AW_HIDE|#AW_CENTER|#AW_SLIDE)
    scsCloseWindow(#WSP)
  EndIf
  gbSplashFormLoaded = #False
EndProcedure

Procedure WSP_tmrSplash_Timer()
  PROCNAMEC()
  Static bWelcomeDisplayed
  Protected qTimeNow.q, nResponse
  Static qTimeSetStatusLastCalled.q
  
  ; debugMsg(sProcName, "gbInitialising=" + strB(gbInitialising))

  If gbInMapProdLogicalDevs Or gbModalDisplayed Or grWLP\bWindowActive
    ; debugMsg(sProcName, "return")
    ProcedureReturn
  EndIf

  qTimeNow = ElapsedMilliseconds()
  
  If gbKillSplashTimerNow = #False
    ; 12Feb2016 11.5.0 removed gbCallSetGoButton from the following test as this seems to lock up the process sometimes
    If (gbWaitForDispPanels) Or
       (gbInitialising) Or
       (gbInOpenNextCues) Or
       ((qTimeNow - gqSplashStartedTime) < gnSplashDuration) Or
       (grMain\nSamRequestsWaiting > 0) Or
       (gbCallLoadDispPanels) Or
       (gnCallOpenNextCues > 0)
      If (qTimeNow - qTimeSetStatusLastCalled) >= 1000
        WSP_setStatus(grWSP\sStatus + ".")
        qTimeSetStatusLastCalled = qTimeNow
      EndIf
      ; debugMsg(sProcName, "return")
      ProcedureReturn
    EndIf
  Else
    debugMsg(sProcName, "gbKillSplashTimerNow=" + strB(gbKillSplashTimerNow))
  EndIf

  ; kill splash timer
  ; debugMsg(sProcName, "removing splash timer")
  RemoveWindowTimer(#WSP, #SCS_TIMER_SPLASH)
  
  If getWindowSticky(#WSP)
    setWindowSticky(#WSP, #False)
  EndIf
  gbSplashOnTop = #False
  If IsWindow(#WMN) = #False
    debugMsg(sProcName, "load main")
    Debug sProcName + ": calling WMN_Form_Load()"
    WMN_Form_Load()
  EndIf
  
  setMouseCursorNormal()

  If gbDemoMode
    If bWelcomeDisplayed = #False
      If Right(LCase(Trim(gsCueFile)), 8) = "demo.scs"
        gbModalDisplayed = #True
        ensureSplashNotOnTop()
        nResponse = scsMessageRequester(Lang("WSP", "Welcome"), Lang("WSP", "WelcomeMessage"), #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
        bWelcomeDisplayed = #True
        If nResponse = #PB_MessageRequester_Yes
          displayHelpTopic("scs_running_demo.htm")
        EndIf
        gbModalDisplayed = #False
        If grWSP\bDisplaySplashWhenReady
          WSP_primeSplash()
        EndIf
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, "gbRecovering=" + strB(gbRecovering) + ", grRecoveryFileInfo\nEditCuePtr=" + Str(grRecoveryFileInfo\nEditCuePtr) + ", gnLastCue=" + gnLastCue)
  If (gbRecovering) And (grRecoveryFileInfo\nEditCuePtr > 0) And (grRecoveryFileInfo\nEditCuePtr < gnLastCue)
    gnCallEditorCuePtr = grRecoveryFileInfo\nEditCuePtr
    gbCallEditor = #True
  EndIf
  gbRecovering = #False     ; completed recovery processing
  
  If gbEditing = #False
    gbCheckForLostFocus = #True
  EndIf
  
  WSP_Form_Unload()
  
  If gbGoToProdPropDevices = #False
    If IsWindow(#WED) = #False  ; if user activated editor before the splash screen timer expired, do NOT set focus to the main window (#WMN)
      ; added 23/01/2014 so that key presses following display of the splash screen are immediately detectable under #WMN (otherwise they get reported as being under #WSP)
      If IsWindow(#WMN)
        SAW(#WMN)
        SAG(-1)
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WSP_EventHandler()
  PROCNAMEC()
  
  With WSP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WSP_Form_Unload()
        
      Case #PB_Event_Gadget
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsSplash
            ; no action
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " " + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType(gnEventGadgetNo))
            
        EndSelect
        
      Case #PB_Event_Timer
        If EventTimer() = #SCS_TIMER_SPLASH
          WSP_tmrSplash_Timer()
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

; EOF