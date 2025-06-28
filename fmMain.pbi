; File: fmMain.pbi

EnableExplicit

Procedure WMN_mnuHelpAbout_Click()
  PROCNAMEC()
  
  WAB_Form_Show(#True)
  
  ; INFO START TEMP !!!!!!!!!!!!!!!!!!!!!!!!!!!
  CompilerIf #c_test_playlist_reset
    Protected rDateTime.SYSTEMTIME
    Protected qTimeNow, sTime.s
    
    GetLocalTime_(@rDateTime)
    With rDateTime
      \wMinute + 2
      If \wMinute > 59
        \wHour + 1
        \wMinute - 60
      EndIf
      If \wHour = 12
        sTime = RSet(Str(\wHour),2,"0") + ":" + RSet(Str(\wMinute),2,"0") + "PM"
      ElseIf \wHour > 12
        sTime = RSet(Str(\wHour-12),2,"0") + ":" + RSet(Str(\wMinute),2,"0") + "PM"
      Else
        sTime = RSet(Str(\wHour),2,"0") + ":" + RSet(Str(\wMinute),2,"0") + "AM"
      EndIf
      debugMsg(sProcName, "sTime=" + sTime)
      aCue(1)\sTimeBasedStart[0] = sTime
      
      \wMinute + 2
      If \wMinute > 59
        \wHour + 1
        \wMinute - 60
      EndIf
      If \wHour = 12
        sTime = RSet(Str(\wHour),2,"0") + ":" + RSet(Str(\wMinute),2,"0") + "PM"
      ElseIf \wHour > 12
        sTime = RSet(Str(\wHour-12),2,"0") + ":" + RSet(Str(\wMinute),2,"0") + "PM"
      Else
        sTime = RSet(Str(\wHour),2,"0") + ":" + RSet(Str(\wMinute),2,"0") + "AM"
      EndIf
      debugMsg(sProcName, "sTime=" + sTime)
      aCue(2)\sTimeBasedStart[0] = sTime
    EndWith
    
    gnLastResetDay - 1
  CompilerEndIf
  ; INFO END TEMP !!!!!!!!!!!!!!!!!!!!!!!!!!!
EndProcedure

Procedure WMN_mnuHelpCheckForUpdate_Click()
  WUP_Form_Show(#True)
EndProcedure

Procedure WMN_mnuCurrInfo_Click()
  PROCNAMEC()
  Protected sMsg.s, sSeparator.s
  Protected nIPAddr
  
  sSeparator = ": " + Chr(9)
  sMsg + Chr(10) + Lang("Info", "CueFile") + sSeparator + gsCueFile
  sMsg + Chr(10) + Lang("Info", "ProdTitle") + sSeparator + grProd\sTitle
  sMsg + Chr(10) + Lang("Info", "DevMap") + sSeparator + grProd\sSelectedDevMapName
  sMsg + Chr(10) + Lang("Info", "AudioDriver") + sSeparator + decodeDriverL(gnCurrAudioDriver)
  sMsg + Chr(10) + Lang("Info", "VideoLibrary") + sSeparator + decodeVideoPlaybackLibraryL(grVideoDriver\nVideoPlaybackLibrary)
  sMsg + Chr(10) + Lang("Info", "OperMode") + sSeparator + Lang("OperMode", decodeOperMode(gnOperMode))
  
  ExamineIPAddresses() 
  Repeat
    nIPAddr = NextIPAddress()
    If nIPAddr = 0
      Break
    EndIf
    sMsg + Chr(10) + Lang("Network", "IPAddr") + sSeparator + IPString(nIPAddr)
  ForEver
  
  ensureSplashNotOnTop()
  scsMessageRequester(Lang("Info", "Hdg"), sMsg)
  
EndProcedure

Procedure WMN_doSaveSettings(Index)
  PROCNAMEC()
  Protected k, d, k2
  Protected nSubPtr
  Protected nLoopStart, nLoopEnd
  Protected bSettingsSaved
  Protected fNewSubMastBVLevel.f
  Protected fNewRelLevel.f
  Protected sSubList.s, sMessage.s
  Protected nSSIndex, nSSDevIndex

  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", gnSaveSettingsCount=" + gnSaveSettingsCount)
  
  If Index < 0
    nLoopStart = 0
    nLoopEnd = gnSaveSettingsCount - 1
  Else
    nLoopStart = Index
    nLoopEnd = Index
  EndIf

  For nSSIndex = nLoopStart To nLoopEnd
    If nSSIndex < gnSaveSettingsCount
      nSubPtr = gaSaveSettings(nSSIndex)\nSSSubPtr
      debugMsg(sProcName, "--- gaSaveSettings(" + nSSIndex + ")\nSSSubPtr=" + getSubLabel(nSubPtr) + ", aSub(" + getSubLabel(nSubPtr) + ")\sSubType=" + aSub(nSubPtr)\sSubType)
      If nSubPtr >= 0
        sSubList + ", " + getSubLabel(nSubPtr)
        If aSub(nSubPtr)\bSubTypeAorF ; doesn't currently support \bSubTypeP
          k = aSub(nSubPtr)\nFirstAudIndex
          While k >= 0
            With aAud(k)
              Select \nFileFormat
                Case #SCS_FILEFORMAT_AUDIO
                  For d = 0 To grLicInfo\nMaxAudDevPerAud
                    If \sLogicalDev[d]
                      nSSDevIndex = getSaveSettingsDevIndexForLogicalDevIndex(nSSIndex, d)
                      If nSSDevIndex >= 0
                        ; should be #True
                        If \bCueVolManual[d]
                          \fBVLevel[d] = gaSaveSettings(nSSIndex)\fSSBVLevel[nSSDevIndex]
                          \fSavedBVLevel[d] = \fBVLevel[d]
                          \fAudPlayBVLevel[d] = \fBVLevel[d]
                          \sDBLevel[d] = convertBVLevelToDBString(\fBVLevel[d])
                          debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sDBLevel[" + d + "]=" + \sDBLevel[d] + ", \fBVLevel[" + d + "]=" + formatLevel(\fBVLevel[d]))
                          \bCueVolManual[d] = #False
                          \bCueLevelLC[d] = #False
                        EndIf
                        If \bCuePanManual[d]
                          \fPan[d] = gaSaveSettings(nSSIndex)\fSSPan[nSSDevIndex]
                          \fSavedPan[d] = \fPan[d]
                          \bCuePanManual[d] = #False
                          \bCuePanLC[d] = #False
                        EndIf
                      EndIf
                    EndIf
                  Next d
                  
                Case #SCS_FILEFORMAT_VIDEO, #SCS_FILEFORMAT_PICTURE
                  d = 0
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bCueVolManual[" + d + "]=" + strB(\bCueVolManual[d]))
                  If \bCueVolManual[d]
                    If (\nPrevAudIndex = -1) And (\nNextAudIndex = -1)
                      ; only one Aud in this Sub - adjust aSub()\fSubMastBVLevel[] and aSub()\sPLMastDBLevel[]
                      If \fPLRelLevel = 100.0
                        fNewSubMastBVLevel = gaSaveSettings(nSSIndex)\fSSBVLevel[nSSDevIndex]
                      Else
                        fNewSubMastBVLevel = gaSaveSettings(nSSIndex)\fSSBVLevel[nSSDevIndex] / (\fPLRelLevel / 100.0)
                      EndIf
                      If fNewSubMastBVLevel <= grLevels\fMaxBVLevel
                        aSub(nSubPtr)\fSubMastBVLevel[d] = fNewSubMastBVLevel
                        aSub(nSubPtr)\sPLMastDBLevel[d] = convertBVLevelToDBString(fNewSubMastBVLevel)
                        debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\sPLMastDBLevel[" + d + "]=" + aSub(nSubPtr)\sPLMastDBLevel[d] + ", \fSubMastBVLevel[" + d + "]=" + formatLevel(aSub(nSubPtr)\fSubMastBVLevel[d]))
                      EndIf
                    Else
                      ; more than one Aud in this Sub
                      fNewRelLevel = \fBVLevel[d] / aSub(nSubPtr)\fSubMastBVLevel[d] * 100.0
                      If (fNewRelLevel >= 0.0) And (fNewRelLevel <= 100.0)
                        \fPLRelLevel = fNewRelLevel
                        debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fPLRelLevel=" + StrF(\fPLRelLevel,1))
                      EndIf
                    EndIf
                    \fSavedBVLevel[d] = \fBVLevel[d]
                    ; although the following is mainly for audio file cues, the \fAudPlayBVLevel[] setting is necessary to reset the white marker in the display panels
                    \fAudPlayBVLevel[d] = \fBVLevel[d]  ; see comment above
                    \sDBLevel[d] = convertBVLevelToDBString(\fBVLevel[d])
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sDBLevel[" + d + "]=" + \sDBLevel[d] + ", \fBVLevel[" + d + "]=" + formatLevel(\fBVLevel[d]))
                    \bCueVolManual[d] = #False
                    \bCueLevelLC[d] = #False
                  EndIf
                  If \bCuePanManual[d]
                    \fSavedPan[d] = gaSaveSettings(nSSIndex)\fSSPan[nSSDevIndex]
                    \bCuePanManual[d] = #False
                    \bCuePanLC[d] = #False
                  EndIf
                  
              EndSelect
              k = \nNextAudIndex
            EndWith
          Wend
          
        ElseIf aSub(nSubPtr)\bSubTypeL  ; \bSubTypeL
          debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nLCAction=" + decodeLCAction(aSub(nSubPtr)\nLCAction))
          With aSub(nSubPtr)
            Select \nLCAction
              Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  nSSDevIndex = getSaveSettingsDevIndexForLogicalDevIndex(nSSIndex, d)
                  If nSSDevIndex >= 0
                    debugMsg(sProcName, "getSaveSettingsDevIndexForLogicalDevIndex(" + nSSIndex + ", " + d + ") returned " + nSSDevIndex)
                    If nSSDevIndex >= 0
                      ; should be #True
                      \fLCReqdBVLevel[d] = gaSaveSettings(nSSIndex)\fSSBVLevel[nSSDevIndex]
                      \sLCReqdDBLevel[d] = convertBVLevelToDBString(\fLCReqdBVLevel[d])
                      \fLCReqdPan[d] = gaSaveSettings(nSSIndex)\fSSPan[nSSDevIndex]
                    EndIf
                  EndIf
                Next d
            EndSelect
          EndWith
        EndIf
      EndIf
      gbDataChanged = #True
      bSettingsSaved = #True
    EndIf
  Next nSSIndex

  If Index = -1
    ; saved settings for all listed cues - clear save settings array
    gnSaveSettingsCount = 0
  Else
    ; saved settings for one cue only - remove that cue from the array
    nSubPtr = gaSaveSettings(Index)\nSSSubPtr
    debugMsg(sProcName, "calling removeFromSaveSettings(" + getSubLabel(nSubPtr) + ")")
    removeFromSaveSettings(nSubPtr)
  EndIf
  debugMsg(sProcName, "gnSaveSettingsCount=" + gnSaveSettingsCount) 

  setSaveSettings()
  If bSettingsSaved
    debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #False, " + strB(grProd\bTemplate) + ")")
    writeXMLCueFile(#False, #False, #False, #False, grProd\bTemplate)
    PNL_loadDispPanels()
  EndIf
  
  If sSubList
    WMN_setStatusField(LangPars("Main", "SettingsSaved", Mid(sSubList, 3)))
  EndIf

  SAG(-1)

EndProcedure

Procedure WMN_mnuMtrsPeakReset_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  resetPeaks(#False)
  If gbVUDisplayRunning = #False
    ; only need to call drawVUDisplay() if gbVUDisplayRunning = False because procedure will be called anyway if gbVUDisplayRunning = True
    drawVUDisplay()
  EndIf

  SAG(-1)
EndProcedure

Procedure WMN_mnuHelpClearDTMAInds_Click()
  ; clear 'don't tell me again' (DTMA) indicators
  PROCNAMEC()
  Protected i, j, k
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected sTitle.s, sMessage.s
  
  With grDontTellMeAgain
    \bVideoCodecs = #False
  EndWith
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeA
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            aAud(k)\bCodecWarningDisplayed = #False
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  ; see also 'load preference group Memory' under loadPrefsPart0() in StartUp.pbi
  grMemoryPrefs\sDontAskCloseSCSDate = ""
  grMemoryPrefs\sDontTellDMXChannelLimitDate = ""
  COND_OPEN_PREFS("Memory")
  RemovePreferenceKey(#SCS_DontAskCloseSCSDate)
  RemovePreferenceKey(#SCS_DontTellDMXChannelLimitDate)
  COND_CLOSE_PREFS()

  sTitle = Lang("menu", "mnuHelpClearDTMAInds")
  sMessage = Lang("WMN", "IndClear")
  scsMessageRequester(sTitle, sMessage)
  
EndProcedure

Procedure WMN_processFileLoad()
  PROCNAMEC()
  Protected bCancel
  
  debugMsg(sProcName, #SCS_START)
  
  WEN_closeMemoWindowsIfOpen()
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not start new file
    ProcedureReturn
  EndIf
  
  ; Added 27Feb2025 11.10.7-b07 following email from Stuart Barry where a playing video continued playing even after opening a new cue file.
  If gnLastCue > 0
    debugMsg(sProcName, "calling processStopAll()")
    processStopAll()
  EndIf
  ; End added 27Feb2025 11.10.7-b07
  
  setMonitorPin()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  WLP_Form_Show(#WMN, #True)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_processFileTemplates()
  PROCNAMEC()
  Protected bCancel
  
  debugMsg(sProcName, #SCS_START)
  
  WEN_closeMemoWindowsIfOpen()
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not start new file
    ProcedureReturn
  EndIf
  setMonitorPin()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  WTM_Form_Show(#WMN, #True)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_FileOpen_Click()
  PROCNAMEC()
  Protected bCancel
  Protected sTitle.s, sDefaultFile.s
  Protected sTmp.s
  
  debugMsg(sProcName, #SCS_START)
  
  ; added 12Nov2015 11.4.1.2k
  debugMsg(sProcName, "THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
  THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
  ; end added 12Nov2015 11.4.1.2k
  
  debugMsg(sProcName, "calling WEN_closeMemoWindowsIfOpen()")
  WEN_closeMemoWindowsIfOpen()
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not open new file
    ; added 12Nov2015 11.4.1.2k
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
    ; end added 12Nov2015 11.4.1.2k
    ProcedureReturn
  EndIf
  setMonitorPin()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  sTitle = Lang("Common", "OpenSCSCueFile")
  If Len(Trim(gsCueFolder)) > 0
    sDefaultFile = Trim(gsCueFolder)
  ElseIf Len(Trim(grGeneralOptions\sInitDir)) > 0
    sDefaultFile = Trim(grGeneralOptions\sInitDir)
  EndIf
  
  ; Open the file for reading
  sTmp = OpenFileRequester(sTitle, sDefaultFile, gsPatternAllCueFiles, 0)
  If Len(sTmp) = 0
    ; added 12Nov2015 11.4.1.2k
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
    ; end added 12Nov2015 11.4.1.2k
    ProcedureReturn
  EndIf
  gsCueFile = sTmp
  gsCueFolder = GetPathPart(gsCueFile)
  debugMsg(sProcName, "gsCueFolder=" + gsCueFolder)
  
  ; samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, -1)  ; p1: 1 = primary file.  p3: -1 = call editor after loading, with -1 as the cueptr
  samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1)  ; p1: 1 = primary file.  p3: -1 = call editor after loading, with -1 as the cueptr
  
  CompilerIf 1=2
    ; !!!! blocked out 6Feb2016 11.4.3 as this can cause deadlock on opening the editor (cuelistmutex locks 234 vs 815)
    ; added 12Nov2015 11.4.1.2k
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
    ; end added 12Nov2015 11.4.1.2k
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_resizePanelSliders()
  PROCNAMEC()
  Protected nGadgetPropsIndex
  Protected fSliderScalingXFactor.f
  Protected n
  
  nGadgetPropsIndex = getGadgetPropsIndex(WMN\scaCuePanels)
  fSliderScalingXFactor = GadgetWidth(WMN\scaCuePanels) / gaGadgetProps(nGadgetPropsIndex)\nOrigWidth
  debugMsg(sProcName, "GadgetWidth(WMN\scaCuePanels)=" + GadgetWidth(WMN\scaCuePanels) + ", \nOrigWidth=" + gaGadgetProps(nGadgetPropsIndex)\nOrigWidth +
                      ", fSliderScalingXFactor=" + StrF(fSliderScalingXFactor,4) + ", gfMainXFactor=" + StrF(gfMainXFactor,4))
  For n = 1 To ArraySize(gaDispPanel())
    PNL_setSliderScalingFactors(n, gfMainYFactor, fSliderScalingXFactor)
  Next n

EndProcedure

Procedure WMN_Form_Resize()
  PROCNAMEC()
  Protected n, nSliderVerticalSpace
  Protected nLeft, nTop, nWidth, nHeight, nWidth2
  Protected nTmp
  Protected nGadgetPropsIndex
  Static bInFormResize
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)
  
  If bInFormResize
    debugMsg(sProcName, "returning because bInFormResize=" + strB(bInFormResize))
    ProcedureReturn
  EndIf
  bInFormResize = #True
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If GetWindowState(#WMN) = #PB_Window_Minimize
    debugMsg(sProcName, "window minimized")
    bInFormResize = #False
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, "calling checkMonitorInfo()")
  checkMonitorInfo()
  
  gfMainXFactor = WindowWidth(#WMN) / gaWindowProps(#WMN)\nOrigWidth
  gfMainYFactor = WindowHeight(#WMN) / gaWindowProps(#WMN)\nOrigHeight * _ScaleDPI_Y_
  If IsGadget(WMN\scaCuePanels)
    nGadgetPropsIndex = getGadgetPropsIndex(WMN\scaCuePanels)
    gfMainPnlXFactor = GadgetWidth(WMN\scaCuePanels) / gaGadgetProps(nGadgetPropsIndex)\nOrigWidth
  Else
    gfMainPnlXFactor = gfMainXFactor
  EndIf
  debugMsg(sProcName, "gfMainXFactor=" + StrF(gfMainXFactor,4) + ", gfMainYFactor=" + StrF(gfMainYFactor,4) + ", gfMainPnlXFactor=" + StrF(gfMainPnlXFactor,4))
  
  With grWMN
    \nCurrWindowWidth = WindowWidth(#WMN)
    \nCurrWindowHeight = WindowHeight(#WMN)
    
    resizeForm(#WMN)
    debugMsg(sProcName, "calling WMN_displayOrHideMemoPanel()")
    WMN_displayOrHideMemoPanel()
    WMN_resizeGoAndMaster()
    
    WMN_doCtrlPanelPosition()
    
    nTop = WindowHeight(#WMN) - GadgetHeight(WMN\cvsStatusBar)
    ResizeGadget(WMN\cvsStatusBar, 0, nTop, \nCurrWindowWidth, #PB_Ignore)
    
    nTop = WindowHeight(#WMN) - GadgetHeight(WMN\cvsStatusBar) - GadgetHeight(WMN\cntTemplate)
    ResizeGadget(WMN\cntTemplate, 0, nTop, \nCurrWindowWidth, #PB_Ignore)
    \bTemplateInfoSet = #False
    
    If StartDrawing(WindowOutput(#WMN))
      DrawingFont(GetGadgetFont(WMN\lblNextManualCue))
      nWidth = TextWidth(" " + GetGadgetText(WMN\lblNextManualCue) + " ")
      nWidth2 = TextWidth(" " + GetGadgetText(WMN\lblLastPlayingCue) + " ")
      If nWidth2 > nWidth
        nWidth = nWidth2
      EndIf
      StopDrawing()
    EndIf
    ResizeGadget(WMN\lblNextManualCue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
    ResizeGadget(WMN\lblLastPlayingCue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
    
    nLeft = GadgetX(WMN\lblNextManualCue) + GadgetWidth(WMN\lblNextManualCue) + Round(GadgetWidth(WMN\imgType) / 2, #PB_Round_Down)
    ResizeGadget(WMN\imgType,nLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore)
    ResizeGadget(WMN\imgLastPlayingType,nLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore)
    
    nLeft = GadgetX(WMN\imgType) + GadgetWidth(WMN\imgType) + Round(GadgetWidth(WMN\imgType) / 2, #PB_Round_Down)
    nWidth = GadgetWidth(WMN\cntGoInfo) - nLeft - 2
    ResizeGadget(WMN\lblGoInfo, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(WMN\lblLastPlayingInfo, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
    
    WMN_setCueListFontSize()
    
    For n = 1 To ArraySize(gaDispPanel())
      PNL_setSliderScalingFactors(n, gfMainYFactor, gfMainXFactor)
    Next n
    
    SLD_Resize(WMN\sldMasterFader)
    
    If GGA(WMN\splCueListMemo, #PB_Splitter_FirstGadget) <> WMN\grdCues
      nWidth = GadgetWidth(WMN\cntNorth)
      nHeight = GadgetHeight(WMN\cntNorth)
      ResizeGadget(WMN\grdCues, 0, 0, nWidth, nHeight)
      ; debugMsg(sProcName, "ResizeGadget(WMN\grdCues, 0, 0, " + nWidth + ", " + nHeight + ")")
    EndIf
    
    WMN_setupVUDisplay()
    clearVUDisplay()
    
    debugMsg(sProcName, "calling refreshGrdCues")
    WMN_refreshGrdCues() ; force refresh of grid so column headers are repainted
    
    ; sizes and positions reinstated based on original sizes and positions so reinstate "bHotkeysCurrentlyDisplayed = #True" so that displayOrHideHotkeys adjusts according to reinstated positions
    \bHotkeysCurrentlyDisplayed = #True
    WMN_displayOrHideHotkeys()
    
    If gbInitialising = #False
      WMN_applyDisplayOptions(#False, #False, #True) ; Changed 24Jan2023 11.9.9ab
      WMN_setupGrid()
      populateGrid()
      samAddRequest(#SCS_SAM_SET_CUE_PANELS)
    EndIf
    samAddRequest(#SCS_SAM_REPOS_SPLITTER, WMN\splNorthSouth, 0, #True) ; horizontal splitter between cue list and cue panels
    samAddRequest(#SCS_SAM_REPOS_SPLITTER, WMN\splPanelsHotkeys, 0, #True) ; vertical splitter between cue panels and hotkey list
    If grWMN\bMemoScreen1InUse
      Select grProd\nMemoDispOptForPrim
        Case #SCS_MEMO_DISP_PRIM_POPUP
          ; no splitter required
        Case #SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST
          samAddRequest(#SCS_SAM_REPOS_SPLITTER, WMN\splCueListMemo, 0, #True) ; vertical splitter between cue list and memo
        Case #SCS_MEMO_DISP_PRIM_SHARE_MAIN
          samAddRequest(#SCS_SAM_REPOS_SPLITTER, WMN\splMainMemo, 0, #True) ; vertical splitter between (cue list and cue panels) and memo
      EndSelect
    EndIf
    
    \nProdTimerLength = 0   ; force X position of production timer to be recalculated
    
    If IsGadget(WMN\btnShowFaders)
      nTop = GadgetHeight(WMN\cntMasterFaders) >> 1
      ResizeGadget(WMN\btnShowFaders, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    EndIf
  EndWith
  
  With WMN
    debugMsg(sProcName, "GadgetX(\splNorthSouth)=" + GadgetX(\splNorthSouth) + ", GadgetY()=" + GadgetY(\splNorthSouth) + ", GadgetWidth()=" + GadgetWidth(\splNorthSouth) + ", GadgetHeight()=" + GadgetHeight(\splNorthSouth))
    debugMsg(sProcName, "GadgetX(\cvsStatusBar)=" + GadgetX(\cvsStatusBar) + ", GadgetY()=" + GadgetY(\cvsStatusBar) + ", GadgetWidth()=" + GadgetWidth(\cvsStatusBar) + ", GadgetHeight()=" + GadgetHeight(\cvsStatusBar))
  EndWith
  
  bInFormResize = #False
  debugMsg(sProcName, #SCS_END +
                      ", WindowX(#WMN)=" + WindowX(#WMN) + ", WindowY(#WMN)=" + WindowY(#WMN) +
                      ", WindowWidth(#WMN)=" + WindowWidth(#WMN) + ", WindowHeight(#WMN)=" + WindowHeight(#WMN))
  
EndProcedure

Procedure WMN_grdCues_Click()
  PROCNAMEC()
  Protected nRow, nCuePtr
  Protected qTimeNow
  Protected nExclusiveCuePtr
  Protected bCallEditor
  
  debugMsg(sProcName, #SCS_START)
  
  If (gbSystemLocked) Or (gbLoadingCueFile) Or (gbClosingDown)
    ; ignore click
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "(start) GGS(WMN\grdCues)=" + GGS(WMN\grdCues) + ", " + getCueLabel(GGS(WMN\grdCues)))
  
  nRow = GGS(WMN\grdCues)
  nCuePtr = WMN_getCuePtrForRowNo(nRow)
  debugMsg(sProcName, "nRow=" + nRow + ", nCuePtr=" + getCueLabel(nCuePtr))
  
  If grOperModeOptions(gnOperMode)\bRequestConfirmCueClick
    If WMN_CheckOkToGoToCue(nCuePtr) = #False
      ProcedureReturn
    EndIf
  EndIf
  
  If (nCuePtr > 0) And (nCuePtr <= gnLastCue)
    If (aCue(nCuePtr)\nCueState = #SCS_CUE_READY) And (aCue(nCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO)
      aCue(nCuePtr)\nActivationMethodReqd = #SCS_ACMETH_MAN
      debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(nCuePtr)\nActivationMethodReqd))
    EndIf
  EndIf
  
  Select grProd\nGridClickAction
    Case #SCS_GRDCLICK_GOTO_CUE ; go to cue (default action)
      ; no action required in this 'Select' statement - fall through to the remainder of the procedure
      
    Case #SCS_GRDCLICK_SET_GO_BUTTON_ONLY ; set go button only (added initially for Patrick Wambold)
      If nCuePtr >= 0
        gnCueToGoOverride = nCuePtr
        debugMsg(sProcName, "calling setCueToGo(#True, " + getCueLabel(nCuePtr) + ")")
        setCueToGo(#True, nCuePtr)
        gbForceFocusPointToNextManual = #True
        ProcedureReturn
      EndIf
      
    Case #SCS_GRDCLICK_IGNORE ; ignore cue list click - could be useful for unattended productions
      SGS(WMN\grdCues, -1)
      debugMsg(sProcName, "calling highlightLine(" + getCueLabel(gnPrevHighlightedCue) + ") to re-highlight the required next cue")
      highlightLine(gnPrevHighlightedCue)
      ProcedureReturn
      
  EndSelect
  
  nExclusiveCuePtr = checkExclusiveCuePlaying()
  If nExclusiveCuePtr >= 0
    WMN_setStatusField(ReplaceString(Lang("WMN", "ExclCueRun"), "$1", aCue(nExclusiveCuePtr)\sCue), #SCS_STATUS_ERROR)
    debugMsg(sProcName, "calling highlightLine(" + getCueLabel(gnPrevHighlightedCue) + ") to re-highlight the required next cue")
    highlightLine(gnPrevHighlightedCue)
    ProcedureReturn
  EndIf
  
  gbForceFocusPointToNextManual = #True
  
  With grMain
    If nRow >= 0
      qTimeNow = ElapsedMilliseconds()
      If gbEditorAndOptionsLocked = #False
        If nRow = \nGrdCuesClickRow
          If (qTimeNow - \qGrdCuesClickTime) <= grGeneralOptions\nDoubleClickTime
            ; user double-clicked, so call editor
            bCallEditor = #True
          EndIf
        EndIf
      EndIf
      \nGrdCuesClickRow = nRow
      \qGrdCuesClickTime = qTimeNow
      
      If bCallEditor
        logKeyEvent("calling callEditor(" + getCueLabel(nCuePtr) + ")")
        callEditor(nCuePtr)
      Else
        logKeyEvent("calling GoToCue(" + getCueLabel(nCuePtr) + ", #True, #True)")
        GoToCue(nCuePtr, #True, #True)
        debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
        calcCueStartValues(nCuePtr)
      EndIf
    EndIf
  EndWith
  
  SGS(WMN\grdCues, -1)
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WMN_grdCues_DblClick()
  PROCNAMEC()
  Protected nRow, nCuePtr
  Protected nExclusiveCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  If (gbSystemLocked) Or (gbLoadingCueFile) Or (gbClosingDown)
    ; ignore double-click
    ProcedureReturn
  EndIf
  
  If gnOperMode >= #SCS_OPERMODE_REHEARSAL ; Test added 24Sep2024 11.10.5 following forum posting by 'BeigheyMW' 23Sep2024
    ; ignore double-click
    ProcedureReturn
  EndIf
  
  nExclusiveCuePtr = checkExclusiveCuePlaying()
  If nExclusiveCuePtr >= 0
    WMN_setStatusField(ReplaceString(Lang("WMN", "ExclCueRun"), "$1", aCue(nExclusiveCuePtr)\sCue), #SCS_STATUS_ERROR)
    debugMsg(sProcName, "calling highlightLine(" + getCueLabel(gnPrevHighlightedCue) + ") to re-highlight the required next cue")
    highlightLine(gnPrevHighlightedCue)
    ProcedureReturn
  EndIf
  
  If gbEditorAndOptionsLocked = #False
    nRow = GGS(WMN\grdCues)
    If nRow >= 0
      callEditor()
    Else
      nRow = grMain\nGrdCuesClickRow
      If nRow >= 0
        nCuePtr = WMN_getCuePtrForRowNo(nRow)
        debugMsg(sProcName, "nRow=" + nRow + ", nCuePtr=" + getCueLabel(nCuePtr))
        debugMsg(sProcName, "calling callEditor(" + getCueLabel(nCuePtr) + ")")
        callEditor(nCuePtr)
      EndIf
    EndIf
  EndIf
  
  SGS(WMN\grdCues, -1)
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WMN_mnuHelpTopics_Click()
  displayHelpContents()
EndProcedure

Procedure WMN_mnuASIOControl_Click()
  PROCNAMEC()
  Protected lBassResult.l
  
  lBassResult = BASS_ASIO_ControlPanel()
  debugMsg2(sProcName, "BASS_ASIO_ControlPanel", lBassResult)
EndProcedure

Procedure WMN_mnuFavFiles_Click()
  WFF_Form_Show(#WMN, #True)
EndProcedure

Procedure WMN_mnuFileExit_Click()
  If doUnloadMain()
    gbMainFormLoaded = #False
    gbClosingDown = #True
  EndIf
EndProcedure

Procedure WMN_mnuSaveSettingsAllCues_Click()
  PROCNAMEC()
  WMN_doSaveSettings(-1)
EndProcedure

Procedure WMN_mnuMastVolSave_Click()
  PROCNAMEC()
  
  With grProd
    \fMasterBVLevel = SLD_getLevel(WMN\sldMasterFader)
    grMasterLevel\fProdMasterBVLevel = \fMasterBVLevel
    debugMsg(sProcName, "grMasterLevel\fProdMasterBVLevel=" + traceLevel(grMasterLevel\fProdMasterBVLevel))
    \sMasterDBVol = convertBVLevelToDBString(\fMasterBVLevel)
    SLD_setBaseLevel(WMN\sldMasterFader, SLD_getLevel(WMN\sldMasterFader))
    If gbEditProdFormLoaded
      SLD_setLevel(WMN\sldMasterFader, \fMasterBVLevel)
    EndIf
    setSaveSettings()
    debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #False, " + strB(grProd\bTemplate) + ")")
    writeXMLCueFile(#False, #False, #False, #False, grProd\bTemplate)
  EndWith

EndProcedure

Procedure WMN_mnuDMXMastFaderSave_Click()
  PROCNAMEC()
  
  With grProd
    \nDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderValue
    grDMXMasterFader\nDMXMasterFaderResetValue = \nDMXMasterFaderValue
    If SLD_isSlider(WCN\sldDMXMasterFader)
      SLD_setValue(WCN\sldDMXMasterFader, \nDMXMasterFaderValue)
    EndIf
    setSaveSettings()
    debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #False, " + strB(grProd\bTemplate) + ")")
    writeXMLCueFile(#False, #False, #False, #False, grProd\bTemplate)
  EndWith
  
EndProcedure

Procedure WMN_mnuNavBack_Click()
  gbForceFocusPointToNextManual = #True
  WMN_prevCue()
EndProcedure

Procedure WMN_mnuNavEnd_Click()
  gbForceFocusPointToNextManual = #True
  WMN_endCue()
EndProcedure

Procedure WMN_mnuNavNext_Click()
  gbForceFocusPointToNextManual = #True
  WMN_nextCue()
EndProcedure

Procedure WMN_mnuNavTop_Click()
  gbForceFocusPointToNextManual = #True
  WMN_TopCue()
EndProcedure

Procedure WMN_mnuHBSelect_Click(nBankIndex)
  PROCNAMEC()
  Protected nSelectedBankIndex
  
  debugMsg(sProcName, #SCS_START + ", nBankIndex=" + nBankIndex)
  
  If (nBankIndex > 0) And (nBankIndex <= grLicInfo\nMaxHotkeyBank)
    ; nBankIndex in the range 1 to max
    If GetMenuItemState(#WMN_mnuNavigate, #WMN_mnuHB_00 + nBankIndex)
      ; this > 0 bank currently selected, so de-select it selecting bank 0
      nSelectedBankIndex = 0
    Else
      nSelectedBankIndex = nBankIndex
    EndIf
  Else
    nSelectedBankIndex = 0
  EndIf
  
  setHotkeyBank(nSelectedBankIndex)
 
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_mnuOptions_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  setMouseCursorBusy()
  gbCheckForLostFocus = #False     ; if options displayed then do not check for lost focus
  WOP_Form_Show(#True, #WMN)
  
EndProcedure

Procedure WMN_mnuRecentFile_Click(nMenuItemId)
  Protected nFileNr
  nFileNr = nMenuItemId + 1
  openRecentFile(nFileNr)
EndProcedure

Procedure WMN_mnuHelpRegistration_Click()
  WRG_Form_Show(#True, #WMN)
EndProcedure

Procedure WMN_mnuSave_Click()
  PROCNAMEC()
  Protected bSaveFile
  
  debugMsg(sProcName, #SCS_START)
  
  gbSaveAs = #False
  If valProd()
    If gbEditorFormLoaded
      If valCue(#False)
        bSaveFile = #True
      EndIf
    Else
      bSaveFile = #True
    EndIf
    If bSaveFile
      debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #False, " + strB(grProd\bTemplate) + ")")
      writeXMLCueFile(#False, #False, #False, #False, grProd\bTemplate)
      If grProd\bTemplate
        setCurrTemplateFileNames()
        renameTemplateFilesIfReqd()
      EndIf
      If IsWindow(#WED)
        WED_setWindowTitle()
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_mnuSaveAs_Click()
  PROCNAMEC()
  Protected bSaveFile
  
  debugMsg(sProcName, #SCS_START)
  
  If grProd\bTemplate
    debugMsg(sProcName, "'Save As...' ignored because grProd\bTemplate=#True")
  Else
    gbSaveAs = #True
    If valProd()
      If gbEditorFormLoaded
        If valCue(#False)
          bSaveFile = #True
        EndIf
      Else
        bSaveFile = #True
      EndIf
      If bSaveFile
        debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #True)")
        writeXMLCueFile(#False, #False, #True)
        If IsWindow(#WED)
          WED_setWindowTitle()
        EndIf
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_mnuSaveReason_Click()
  displayReasonsForSave()
EndProcedure

Procedure WMN_mnuSaveSettingsCue_Click(Index)
  WMN_doSaveSettings(Index)
EndProcedure

Procedure WMN_mnuVUWidth(nEventMenu)
  PROCNAMEC()
  
  With grOperModeOptions(gnOperMode)
    Select nEventMenu
      Case #WMN_mnuVUNarrow
        \nVUBarWidth = #SCS_VUBARWIDTH_NARROW
      Case #WMN_mnuVUMedium
        \nVUBarWidth = #SCS_VUBARWIDTH_MEDIUM
      Case #WMN_mnuVUWide
        \nVUBarWidth = #SCS_VUBARWIDTH_WIDE
    EndSelect
    WMN_setupVUDisplay()
    clearVUDisplay()
    startVUDisplayIfReqd()
    WMN_setVUMenuItemStates()
    
    debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\nVUBarWidth=" + decodeVUBarWidth(\nVUBarWidth))
    
  EndWith
  
  SAG(-1)
  
EndProcedure

Procedure WMN_mnuMtrsDMXDisplay_Click()
  PROCNAMEC()
  Protected d, bDMXDeviceAvailable
  Protected bNewMenuItemState
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If \nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        If \sLogicalDev
          bDMXDeviceAvailable = #True
          Break
        EndIf
      EndIf
    EndWith
  Next d
  
  If bDMXDeviceAvailable
    If GetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsDMXDisplay) = 0
      bNewMenuItemState = #True
    EndIf
  EndIf
  
  SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsDMXDisplay, bNewMenuItemState)
  If bNewMenuItemState
    WDD_Form_Show()
  Else
    If IsWindow(#WDD)
      WDD_Form_Unload()
    EndIf
  EndIf
  
  debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(#WMN)")
  SAW(#WMN)
  SAG(-1)
  
EndProcedure

Procedure WMN_btnShowFaders_Click()
  PROCNAMEC()
  Protected nDevMapPtr, nAudioDriver
  
  If (IsWindow(#WCN)) And (getWindowVisible(#WCN)) And (IsGadget(WMN\btnShowFaders))
    WCN_Form_Unload()
    gbFadersDisplayed = #False
    SGT(WMN\btnShowFaders, Lang("WMN", "ShowFaders"))
  Else
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      CompilerIf #cAlwaysUseMixerForBass
        WCN_Form_Show()
        SGT(WMN\btnShowFaders, Lang("WMN", "HideFaders"))
      CompilerElse
        nAudioDriver = grMaps\aMap(nDevMapPtr)\nAudioDriver
        If (nAudioDriver = #SCS_DRV_BASS_DS Or nAudioDriver = #SCS_DRV_BASS_WASAPI) And (grDriverSettings\bUseBASSMixer = #False)
          ; Note: fader control is only available when using the BASS Mixer because otherwise we would have to apply fader controls to individual audio output devices per sub-cue.
          ; The BASS mixer outputs, however, combine audio outputs from all playing audio/playlist cues.
          scsMessageRequester(Lang("WCN", "Window"), Lang("WCN", "NotAvailable"), #MB_ICONEXCLAMATION)
        Else
          WCN_Form_Show()
          SGT(WMN\btnShowFaders, Lang("WMN", "HideFaders"))
        EndIf
      CompilerEndIf
    EndIf
  EndIf
  
  SAW(#WMN)
  SAG(-1)
  
EndProcedure

Procedure WMN_mnuTracing_Click()
  PROCNAMEC()
  
  If gbDoDebug
    debugMsg(sProcName, "============== Tracing suspended ==============")
    gbDoDebug = #False
    gbDoSMSLogging = #False
  Else
    gbDoDebug = #True
    gbDoSMSLogging = #True
    If gnDebugFile = 0
      openLogFile()
    EndIf
    If gnDebugFile
      debugMsg(sProcName, "============== Tracing resumed ==============")
    EndIf
  EndIf
  
  If IsMenu(#WMN_mnuWindowMenu)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuTracing, gbDoDebug)
  EndIf
  If IsMenu(#WMN_mnuHelp)
    SetMenuItemState(#WMN_mnuHelp, #WMN_mnuTracing, gbDoDebug)
  EndIf
  WMN_setWindowTitle()
  
EndProcedure

Procedure WMN_setToolbarButtons()
  PROCNAMEC()
  Protected nThisCue
  Protected bGrdVisible
  Protected bTrueIfNotTemplate
  
  ; debugMsg(sProcName, #SCS_START)
  
  If grProd\bTemplate = #False
    bTrueIfNotTemplate = #True
  EndIf
  
  If grLicInfo\bPlayOnly
    setToolBarBtnEnabled(#SCS_TBMB_EDITOR, #False)
    setToolBarBtnEnabled(#SCS_TBMB_DEVMAP, #False)
    setToolBarBtnEnabled(#SCS_TBMB_SAVE_SETTINGS, #False)
    setToolBarBtnEnabled(#SCS_TBMB_VST, #False)
  ElseIf gbEditorAndOptionsLocked
    setToolBarBtnEnabled(#SCS_TBMB_EDITOR, #False)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuEditor, #False)
    setToolBarBtnEnabled(#SCS_TBMB_DEVMAP, #False)
    setToolBarBtnEnabled(#SCS_TBMB_VST, #False)
  Else
    nThisCue = GetGadgetState(WMN\grdCues)
    nThisCue = gnHighlightedCue
    setToolBarBtnEnabled(#SCS_TBMB_EDITOR, #True)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuEditor, #True)
    setToolBarBtnEnabled(#SCS_TBMB_DEVMAP, #True)
    If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
      setToolBarBtnEnabled(#SCS_TBMB_VST, #False)
    Else
      setToolBarBtnEnabled(#SCS_TBMB_VST, #True)
    EndIf
  EndIf
  
  setToolBarBtnEnabled(#SCS_TBMB_LOAD, bTrueIfNotTemplate)
  setToolBarBtnToolTip(#SCS_TBMB_LOAD, Lang("WMN", "LoadTip"))
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuFileLoad, bTrueIfNotTemplate)
  
  If (gbEditorAndOptionsLocked) Or (grLicInfo\bPlayOnly)
    setToolBarBtnEnabled(#SCS_TBMB_TEMPLATES, #False)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuFileTemplates, #False)
    
    setToolBarBtnEnabled(#SCS_TBMB_SAVE, #False)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuSaveFile, #False)
    
    setToolBarBtnEnabled(#SCS_TBMB_OPTIONS, #True)
    setToolBarBtnToolTip(#SCS_TBMB_OPTIONS, "")
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuOptions, #True)
    
  Else
    setToolBarBtnEnabled(#SCS_TBMB_TEMPLATES, bTrueIfNotTemplate)
    setToolBarBtnToolTip(#SCS_TBMB_TEMPLATES, Lang("WMN", "TemplatesTip"))
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuFileTemplates, bTrueIfNotTemplate)
    
    setToolBarBtnEnabled(#SCS_TBMB_SAVE, #True)
    ; setToolBarBtnToolTip(#SCS_TBMB_SAVE, Lang("WMN", "SaveTip")) ; " Save the cue file, Or 'Save As...' a new cue file "
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuSaveFile, #True)
    
    setToolBarBtnEnabled(#SCS_TBMB_OPTIONS, #True)
    setToolBarBtnToolTip(#SCS_TBMB_OPTIONS, "")
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuOptions, #True)
    
  EndIf
  
  If bGrdVisible
    setVisible(WMN\grdCues, #True)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WMN_setToolbarStandbyBtn(bEnable)
  ; Added 12Mar2024 11.10.2bg following email from Mike Ellis where the procedures below were previously called directly from stopOneSub() but that wa in the control thread (#2) not the main thread.
  ; Now changed to enable this to be called via PostEvent
  If bEnable
    setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #True)
    setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, "Standby" + Chr(10) + aCue(gnStandbyCuePtr)\sCue + " - Go!")
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, #True)
    scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, "Standby " + aCue(gnStandbyCuePtr)\sCue + " - Go!")
  Else
    setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #False)
    setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, "Standby Go")
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, #False)
    scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, "Standby Go")
  EndIf
EndProcedure

Procedure WMN_Form_Load()
  PROCNAMEC()
  Protected bEnabled
  Protected n
  Protected nParentMenu
  
  debugMsg(sProcName, #SCS_START)
  
  gbMainFormLoaded = #True
  
  If gbClosingDown
    debugMsg(sProcName, "unloading because gbClosingDown=" + strB(gbClosingDown))
    gbUnloadImmediate = #True
    ProcedureReturn
  EndIf
  
  If IsWindow(#WMN) = #False
    createfmMain()
  EndIf
  
  With grWMN
    gbDontChangeFocus = #False
    \bHotkeysCurrentlyDisplayed = #True
    \bToolBarDisplayed = #False
    \bStandbyButtonDisplayed = #False
    \bTimeProfileButtonDisplayed = #False
    \bGrdCuesRedrawState = #True
    \nCurrWindowWidth = WindowWidth(#WMN)
    \nCurrWindowHeight = WindowHeight(#WMN)
  EndWith

  ; debugMsg(sProcName, "calling setFormColors")
  WMN_setFormColors()

  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuGo, #False)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuPauseAll, #False)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStopAll, #False)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuFadeAll, #False)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, #False)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuSaveSettings, #False)
  
  If grWMN\bToolBarDisplayed
    nParentMenu = #WMN_mnuNavigate
  Else
    nParentMenu = #WMN_mnuWindowMenu
  EndIf
  ; debugMsg(sProcName, "grWMN\bToolBarDisplayed=" + strB(grWMN\bToolBarDisplayed) + ", nParentMenu=" + decodeMenuItem(nParentMenu))
  scsEnableMenuItem(nParentMenu, #WMN_mnuNavTop, #False)
  scsEnableMenuItem(nParentMenu, #WMN_mnuNavBack, #False)
  scsEnableMenuItem(nParentMenu, #WMN_mnuNavNext, #False)
  scsEnableMenuItem(nParentMenu, #WMN_mnuNavEnd, #False)
  If grLicInfo\bStepHotkeysAvailable
    scsEnableMenuItem(nParentMenu, #WMN_mnuResetStepHKs, #False)
  EndIf

  bEnabled = #False
  For n = 0 To #SCS_MAX_TIME_PROFILE
    If grProd\sTimeProfile[n]
      bEnabled = #True
      Break
    EndIf
  Next n
  setToolBarBtnEnabled(#SCS_TBMB_TIME, bEnabled)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuTimeProfile, bEnabled)

  setVisible(WMN\lblDemo, #False)

  WMN_setupVUDisplay()

  ; debugMsg(sProcName, "calling setFormPosition(#WMN, @grMainWindow)")
  setFormPosition(#WMN, @grMainWindow)
  ; reset saved current window dimensions to prevent the next #PB_Event_SizeWindow doing anything as we need to call WMN_Form_Resize() NOW.
  grWMN\nCurrWindowWidth = WindowWidth(#WMN)
  grWMN\nCurrWindowHeight = WindowHeight(#WMN)
  ; debugMsg(sProcName, "calling WMN_Form_Resize")
  WMN_Form_Resize()
  
  grCuePanels\nCuePanelHeightStd = PNL_GadgetHeight(0)
  grCuePanels\nCuePanelHeightStdPlusGap = grCuePanels\nCuePanelHeightStd + grCuePanels\nCuePanelGap
  ; debugMsg(sProcName, "grCuePanels\nCuePanelHeightStd=" + Str(grCuePanels\nCuePanelHeightStd))
  
  ; debugMsg(sProcName, "calling graphInit(@grMG3)")
  graphInit(@grMG3)
  ; debugMsg(sProcName, "calling graphInit(@grMG4)")
  graphInit(@grMG4)
  
  ; debugMsg(sProcName, "calling WMN_applyDisplayOptions(#True)")
  WMN_applyDisplayOptions(#True)
  
  ; grid to be setup (including default widths determined) AFTER form has been resized but BEFORE calling initialisePart3()
  WMN_setupGridDefaults()
  WMN_setupGrid()
  
  setWindowVisible(#WMN, #True)
  
  samAddRequest(#SCS_SAM_SET_CUE_PANELS)
  
  SLD_setMax(WMN\sldMasterFader, #SCS_MAXVOLUME_SLD)
  SLD_setBaseLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
  SLD_setLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
  SLD_setEnabled(WMN\sldMasterFader, #True)
  SLD_drawSlider(WMN\sldMasterFader)
  
  grMasterLevel\fProdMasterBVLevel = grProd\fMasterBVLevel
  ; debugMsg0(sProcName, "grMasterLevel\fProdMasterBVLevel=" + traceLevel(grMasterLevel\fProdMasterBVLevel))
  
  ; debugMsg(sProcName, "calling initialisePart3 - gbCueFileOpen=" + StrB(gbCueFileOpen))
  initialisePart3()
  ; debugMsg(sProcName, "returned from initialisePart3 - gbCueFileOpen=" + StrB(gbCueFileOpen))
  debugMsg(sProcName, "\sLicType=" + grLicInfo\sLicType + ", \nLicLevel=" + grLicInfo\nLicLevel)
  ; debugMsg(sProcName, "end of initialisation")
  
  If grProd\bTimeProdLoadedSet
    ; reset 'time loaded' so that if there is a long delay in starting (eg due to SM-S) then 'auto start after load' cues won't be timed out by the 5-second test
    grProd\qTimeProdLoaded = ElapsedMilliseconds()
    debugMsg(sProcName, "grProd\nTimeProdLoaded=" + traceTime(grProd\qTimeProdLoaded))
  EndIf
  
  ; debugMsg(sProcName, "calling initialiseEnd()")
  initialiseEnd()
  
  WMN_setToolbarButtons()

  ; debugMsg(sProcName, "calling highlightLine(" + getCueLabel(gnHighlightedCue) + ")")
  highlightLine(gnHighlightedCue)

  WMN_refreshGrdCues()
  
  If IsMenu(#WMN_mnuWindowMenu)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuTracing, gbDoDebug)
  EndIf
  If IsMenu(#WMN_mnuHelp)
    SetMenuItemState(#WMN_mnuHelp, #WMN_mnuTracing, gbDoDebug)
  EndIf
  
  If gbDemoMode
    gnDemoTimeCount = grMain\nDemoTime
    debugMsg(sProcName, "gnDemoTimeCount=" + gnDemoTimeCount)
    AddWindowTimer(#WMN, #SCS_TIMER_DEMO, 60000)  ; 60000 milliseconds = 60 seconds as timer interval
    displayDemoCount()
  EndIf
  
  ; debugMsg(sProcName, "set keyboard shortcuts")
  WMN_setKeyboardShortcuts(#WMN, #cTraceKeyboardShortcuts)
  
  WMN_setWindowTitle()
  
  With grWMN
    \nStatusBackColor = grColorScheme\aItem[#SCS_COL_ITEM_MW]\nBackColor
    \nStatusFrontColor = grColorScheme\aItem[#SCS_COL_ITEM_MW]\nTextColor
    \nStatusTextTop = 0
    ; debugMsg(sProcName, "\nStatusTextTop=" + Str(\nStatusTextTop))
  EndWith
  
  samAddRequest(#SCS_SAM_DISPLAY_CLOCK_IF_REQD) ; Added 3Dec2022 11.9.7ar
  
  ; debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
  If (gbShowFileLocatorAfterInitialisation) And (gnFileNotFoundCount > 0)
    ensureSplashNotOnTop()
    WFL_populateFileList(#True)
    setMouseCursorNormal()
    ; debugMsg(sProcName, "calling WFL_Form_Show(#True)")
    WFL_Form_Show(#True)
  Else
    If gbGoToProdPropDevices
      ; debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices) + ", calling callEditor()")
      callEditor()
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If doUnloadMain()
    gbMainFormLoaded = #False
    gbClosingDown = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_setVUMenuItemStates()
  PROCNAMEC()
  ; Changed 24Jan2023 11.9.9ab
  Protected bVULevels, bVUNone
  Protected bVUBarWidthNarrow, bVUBarWidthMedium, bVUBarWidthWide

  ; debugMsg(sProcName, #SCS_START + ", gnOperMode=" + decodeOperMode(gnOperMode))
  
  Select gnVisMode
    Case #SCS_VU_NONE
      bVUNone = #True
    Case #SCS_VU_LEVELS
      bVULevels = #True
  EndSelect
  
  Select grOperModeOptions(gnOperMode)\nVUBarWidth
    Case #SCS_VUBARWIDTH_NARROW
      bVUBarWidthNarrow = #True
    Case #SCS_VUBARWIDTH_MEDIUM
      bVUBarWidthMedium = #True
    Case #SCS_VUBARWIDTH_WIDE
      bVUBarWidthWide = #True
  EndSelect
  
  If IsMenu(#WMN_mnuView)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsVULevels, bVULevels)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsVUNone, bVUNone)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuVUNarrow, bVUBarWidthNarrow)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuVUMedium, bVUBarWidthMedium)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuVUWide, bVUBarWidthWide)
  EndIf
  
  If IsMenu(#WMN_mnuWindowMenu)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuMtrsVULevels, bVULevels)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuMtrsVUNone, bVUNone)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuVUNarrow, bVUBarWidthNarrow)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuVUMedium, bVUBarWidthMedium)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuVUWide, bVUBarWidthWide)
  EndIf
  
EndProcedure

Procedure WMN_mnuMtrsVUVarious_Click(nEventMenu)
  PROCNAMEC()
  Protected bDisplayVisible
  
  bDisplayVisible = #True
  With grOperModeOptions(gnOperMode)
    Select nEventMenu
      Case #WMN_mnuMtrsVUNone
        \nVisMode = #SCS_VU_NONE
        bDisplayVisible = #False
      Case #WMN_mnuMtrsVULevels
        \nVisMode = #SCS_VU_LEVELS
    EndSelect
    WMN_setupVUDisplay()
    clearVUDisplay()
    startVUDisplayIfReqd()
    WMN_setVUMenuItemStates()
    WMN_setStatusField(LangPars("WMN", "GraphInfo", decodeVisModeL(gnVisMode)))
    
    debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\nVisMode=" + decodeVisMode(\nVisMode) + ", gnVisMode=" + decodeVisMode(gnVisMode))
    
  EndWith
  
  SAG(-1)
  
EndProcedure

Procedure WMN_setPeakMenuItemStates()
  PROCNAMEC()
  Protected bPeakNone, bPeakAuto, bPeakHold
  Protected bPeakResetEnabled
  
  Select gnPeakMode
    Case #SCS_PEAK_NONE
      bPeakNone = #True
      
    Case #SCS_PEAK_AUTO
      bPeakAuto = #True
      
    Case #SCS_PEAK_HOLD
      bPeakHold = #True
      bPeakResetEnabled = #True
      
  EndSelect
  
  If IsMenu(#WMN_mnuView)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsPeakOff, bPeakNone)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsPeakAuto, bPeakAuto)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsPeakHold, bPeakHold)
    scsEnableMenuItem(#WMN_mnuView, #WMN_mnuMtrsPeakReset, bPeakResetEnabled)
  EndIf
  
  ; Added 24Jan2023 11.9.9ab
  If IsMenu(#WMN_mnuWindowMenu)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuMtrsPeakOff, bPeakNone)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuMtrsPeakAuto, bPeakAuto)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuMtrsPeakHold, bPeakHold)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuMtrsPeakReset, bPeakResetEnabled)
  EndIf
  ; End added 24Jan2023 11.9.9ab
  
EndProcedure

Procedure WMN_mnuMtrsPeakVarious_Click(nEventMenu)
  PROCNAMEC()
  
  With grOperModeOptions(gnOperMode)
    Select nEventMenu
      Case #WMN_mnuMtrsPeakOff
        \nPeakMode = #SCS_PEAK_NONE
      Case #WMN_mnuMtrsPeakAuto
        \nPeakMode = #SCS_PEAK_AUTO
      Case #WMN_mnuMtrsPeakHold
        \nPeakMode = #SCS_PEAK_HOLD
    EndSelect
    gnPeakMode = \nPeakMode
    WMN_setPeakMenuItemStates()
  EndWith
  
  resetPeaks(#True)
  If gbVUDisplayRunning = #False
    ; only need to call drawVUDisplay() if gbVUDisplayRunning = False because procedure will be called anyway if gbVUDisplayRunning = True
    drawVUDisplay()
  EndIf
  
  SAG(-1)
  
EndProcedure

Procedure WMN_cvsVUDisplay_MouseMove()
  Protected X, Y
  
  X = GGA(WMN\cvsVUDisplay, #PB_Canvas_MouseX)
  Y = GGA(WMN\cvsVUDisplay, #PB_Canvas_MouseY)
  chaseSpeedHot(X, Y)
EndProcedure

Procedure WMN_callEditor(bCalledFromDevMapMenu=#False)
  PROCNAMEC()
  Protected nRow, nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  If gbEditorAndOptionsLocked = #False
    If bCalledFromDevMapMenu
      callEditor(-1, bCalledFromDevMapMenu)
    Else
      nRow = GGS(WMN\grdCues)
      If nRow >= 0
        callEditor()
      Else
        debugMsg(sProcName, "gnHighlightedRow=" + gnHighlightedRow + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue))
        ; nRow = grMain\nGrdCuesClickRow ; 11.2.4
        nRow = gnHighlightedRow         ; 11.2.5
        If nRow >= 0
          nCuePtr = WMN_getCuePtrForRowNo(nRow)
          debugMsg(sProcName, "nRow=" + nRow + ", nCuePtr=" + getCueLabel(nCuePtr))
          debugMsg(sProcName, "calling callEditor(" + getCueLabel(nCuePtr) + ")")
          callEditor(nCuePtr)
        Else
          ; added 2Feb2016 11.4.2.1 following bug reported by Lluis Vilarrasa about clicking 'Edit' doing nothing when the only cue is marked as hidden
          callEditor()
        EndIf
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_tbMain_ButtonClick(nButtonId)
  PROCNAME(#PB_Compiler_Procedure + "[" + nButtonId + "]")
  Protected nRow, nCuePtr

  debugMsg(sProcName, #SCS_START)
  
  SAG(-1) ; ensure focus taken away from sliders
  
  If getToolBarBtnEnabled(nButtonId) = #False
    ; ignore button click if the button is not enabled - unless this is GO button and disabled because an exclusive cue is playing but 'ctrl overrides exclusive cue' applicable
    If (nButtonId = #SCS_TBMB_GO) And (grGeneralOptions\bCtrlOverridesExclCue) And (GetAsyncKeyState_(#VK_CONTROL) & 32768)
      debugMsg(sProcName, "allowing GO due to 'Ctrl overrides exclusive cue")
      WMN_setStatusField("", #SCS_STATUS_CLEAR)
      ; continue processing
    Else
      ProcedureReturn
    EndIf
  EndIf
  
  Select nButtonId
    Case #SCS_TBMB_GO   ; Go button
      logKeyEvent("SCS_TBMB_GO")
      goClicked(#True)
      
    Case #SCS_TBMB_PAUSE_RESUME
      logKeyEvent("SCS_TBMB_PAUSE_RESUME")
      processPauseResumeAll()
      
    Case #SCS_TBMB_STOP_ALL   ; Stop All, or Fade All if shift is down
      If (GetAsyncKeyState_(#VK_SHIFT) & 32768)
        logKeyEvent("SCS_TBMB_FADE_ALL")
        processFadeAll()
      Else
        logKeyEvent("SCS_TBMB_STOP_ALL")
        processStopAll()
      EndIf
      
    Case #SCS_TBMB_FADE_ALL   ; Fade All ; added 21Mar2020 11.8.2.3ad
      logKeyEvent("SCS_TBMB_FADE_ALL")
      processFadeAll()
      
    Case #SCS_TBMB_NAVIGATE   ; Navigate
      logKeyEvent("SCS_TBMB_NAVIGATE")
      DisplayPopupMenu(#WMN_mnuNavigate, WindowID(#WMN))
      
    Case #SCS_TBMB_STANDBY_GO   ; Standby Go
      logKeyEvent("SCS_TBMB_STANDBY_GO")
      standbyGoClicked()
      
    Case #SCS_TBMB_TIME   ; Select Time Profile
      logKeyEvent("SCS_TBMB_TIME")
      WTP_Form_Show(#True, #WMN)
      
    Case #SCS_TBMB_LOAD   ; Load
      logKeyEvent("SCS_TBMB_LOAD")
      WMN_processFileLoad()
      
    Case #SCS_TBMB_TEMPLATES   ; Templates
      logKeyEvent("SCS_TBMB_TEMPLATES")
      WMN_processFileTemplates()
      
    Case #SCS_TBMB_SAVE   ; Save
      logKeyEvent("SCS_TBMB_SAVE")
      DisplayPopupMenu(#WMN_mnuSaveFile, WindowID(#WMN))
      
    Case #SCS_TBMB_PRINT   ; Print
      logKeyEvent("SCS_TBMB_PRINT")
      WPR_Form_Show(#WMN, #True)
      
    Case #SCS_TBMB_OPTIONS   ; Options
      logKeyEvent("SCS_TBMB_OPTIONS")
      WMN_mnuOptions_Click()
      
    Case #SCS_TBMB_EDITOR   ; Editor
      logKeyEvent("SCS_TBMB_EDITOR")
      WMN_callEditor()
      
    Case #SCS_TBMB_VST ; VST Plugins
      logKeyEvent("SCS_TBMB_VST")
      If grWVP\bWindowActive
        SAW(#WVP)
      Else
        WVP_Form_Show()
      EndIf
      
    Case #SCS_TBMB_DEVMAP   ; Device Map
      logKeyEvent("SCS_TBMB_DEVMAP")
      DisplayPopupMenu(#WMN_mnuDevMap, WindowID(#WMN))
      
    Case #SCS_TBMB_SAVE_SETTINGS   ; Save Settings
      logKeyEvent("SCS_TBMB_SAVE_SETTINGS")
      DisplayPopupMenu(#WMN_mnuSaveSettings, WindowID(#WMN))
      
    Case #SCS_TBMB_HELP   ; Help
      logKeyEvent("SCS_TBMB_HELP")
      DisplayPopupMenu(#WMN_mnuHelp, WindowID(#WMN))
      
    Case #SCS_TBMB_VIEW   ; View
      logKeyEvent("SCS_TBMB_VIEW")
      DisplayPopupMenu(#WMN_mnuView, WindowID(#WMN))
      
    Case #SCS_TBMB_HB_PARENT   ; Select Hotkey Bank
      logKeyEvent("SCS_TBMB_HB_PARENT")
      DisplayPopupMenu(#WMN_mnuHB_Parent, WindowID(#WMN))
      
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_sldMasterFader_Common()
  ; PROCNAMEC()
  
  grMasterLevel\fProdMasterBVLevel = SLD_getLevel(WMN\sldMasterFader)
  If gbUseBASS
    ; debugMsg0(sProcName, "calling setMasterFader(" + traceLevel(grMasterLevel\fProdMasterBVLevel) + ")")
    setMasterFader(grMasterLevel\fProdMasterBVLevel)
  Else ; SM-S
    samAddRequest(#SCS_SAM_SET_MASTER_FADER, 0, grMasterLevel\fProdMasterBVLevel)
  EndIf
EndProcedure

Procedure WMN_tmrDemo_Timer()
  PROCNAMEC()
  
  debugMsg(sProcName, "gnDemoTimeCount=" + gnDemoTimeCount)
  If gnDemoTimeCount > 0
    gnDemoTimeCount - 1
    displayDemoCount()
    If gnDemoTimeCount < 1
      processFadeAll()
    EndIf
  EndIf
EndProcedure

Procedure WMN_loadHotkeyPanel()
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START)

  loadHotkeyArray()
  WMN_displayOrHideHotkeys()

EndProcedure

Procedure WMN_EndCue()
  PROCNAMEC()
  Protected nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  nCuePtr = gnLastCue + 1
  GoToCue(nCuePtr, #True, #True)
  debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
  calcCueStartValues(nCuePtr)
  
  If gbInExternalControl = #False
    SAG(-1)  ; will fail if current window is not fmMain
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_NextCue()
  PROCNAMEC()
  Protected i, nNewCuePtr, bRunningCueFound
  
  debugMsg(sProcName, #SCS_START)

  bRunningCueFound = #False
  nNewCuePtr = gnLastCue + 1
  
  For i = gnHighlightedCue To gnLastCue
    With aCue(i)
      If \bCueCurrentlyEnabled
        If i < gnCueToGo
          If (\nCueState > #SCS_CUE_READY) And (\nCueState < #SCS_CUE_STANDBY)
            bRunningCueFound = #True
          EndIf
        Else
          If ((\nActivationMethod = #SCS_ACMETH_MAN) Or (\nActivationMethod = #SCS_ACMETH_MAN_PLUS_CONF)) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
            If (\bSubTypeF) Or (\bSubTypeK) Or (\bSubTypeM) Or (\bSubTypeP) Or (\bSubTypeA) Or (\bSubTypeU)
              If bRunningCueFound
                nNewCuePtr = i
                Break
              ElseIf i > gnCueToGo
                nNewCuePtr = i
                Break
              EndIf
            ElseIf i > gnCueToGo
              nNewCuePtr = i
              Break
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next i
  
  debugMsg(sProcName, "calling GoToCue(" + getCueLabel(nNewCuePtr) + ")")
  GoToCue(nNewCuePtr)
  debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nNewCuePtr) + ")")
  calcCueStartValues(nNewCuePtr)

  If gbInExternalControl = #False
    SAG(-1)  ; will fail if current window is not fmMain
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_PrevCue()
  PROCNAMEC()
  Protected i, nNewCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  nNewCuePtr = 1
  
  For i = 1 To (gnHighlightedCue - 1)
    With aCue(i)
      If \bCueCurrentlyEnabled
        If (\nActivationMethod = #SCS_ACMETH_MAN Or \nActivationMethod = #SCS_ACMETH_MAN_PLUS_CONF) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
          ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState))
          ; If \nCueState >= #SCS_CUE_COUNTDOWN_TO_START
          ; modified 4May2018 11.7.1af following email from Lluís Vilarrasa
          If \nCueState <= #SCS_CUE_READY Or \nCueState >= #SCS_CUE_STANDBY
            ; debugMsg(sProcName, "setting nNewCuePtr=" + getCueLabel(i))
            nNewCuePtr = i
          EndIf
        EndIf
      EndIf
    EndWith
  Next i

  debugMsg(sProcName, "calling GoToCue(" + getCueLabel(nNewCuePtr) + ")")
  GoToCue(nNewCuePtr)
  debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nNewCuePtr) + ")")
  calcCueStartValues(nNewCuePtr)
  
  If gbInExternalControl = #False
    SAG(-1)  ; will fail if current window is not fmMain
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_TopCue()
  PROCNAMEC()
  Protected nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  nCuePtr = getFirstEnabledCue()
  GoToCue(nCuePtr, #True, #True)
  debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
  calcCueStartValues(nCuePtr)
  
  If gbInExternalControl = #False
    SAG(-1)  ; will fail if current window is not fmMain
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_disableGoButtons()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  setToolBarBtnEnabled(#SCS_TBMB_GO, #False)
  setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #False)
  setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, Lang("Menu", "mnuStandbyGo"))

  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuGo, #False)
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, #False)
  scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, Lang("Menu", "mnuStandbyGo"))

EndProcedure

Procedure WMN_refreshGrdCues()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  If gbInitialising = #False And gbClosingDown = #False
    ; force refresh of grid so column headers are repainted
    setVisible(WMN\grdCues, #False)
    setVisible(WMN\grdCues, #True)
  EndIf
EndProcedure

Procedure WMN_setCueListFontSize()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)

  setUpWMNFonts(#True)

  scsSetGadgetFont(WMN\grdCues, #SCS_FONT_WMN_GRDCUES)
  scsSetGadgetFont(WMN\treHotkeys, #SCS_FONT_WMN_GRDCUES)
  
  gqMainThreadRequest | #SCS_MTH_SET_GRID_WINDOW
  
EndProcedure

Procedure WMN_displayOrHideHotkeys(bInSplitterEvent=#False)
  PROCNAMEC()
  Protected nKeyIndex
  Protected nCuePanel
  Protected bDisplayHotkeys, bHotkeysInUse, bChangeFound
  Protected nScrollAreaGadgetWidth, nScrollAreaInnerWidth, nShift, nHotkeysLeft, nHotKeysWidth, nHotkeysHeight
  Protected sHotkeyEntry.s
  Protected bHKTrig, bHKTogl, bHKNote, bHKStep
  Protected bRepopulateOnly
  Protected nHdrBackColor, nHdrTextColor
  Protected nTreeItemCount
  Protected sToggleState.s
  Protected bInitialSplitterPosMainPanelsHotkeysApplied
  Protected nPanelsHotkeysSplitterEndPos = -1
  Protected nGadgetPropsIndex, n
  Protected nInitialCuePanelsWidth, bInitialHotkeysSplitterVisible
  Protected nNewPos

  debugMsg(sProcName, #SCS_START + ", bInSplitterEvent=" + strB(bInSplitterEvent) + ", GGS(WMN\splPanelsHotkeys)=" + GGS(WMN\splPanelsHotkeys))
  
  ; debugMsg(sProcName, "GadgetWidth(WMN\scaCuePanels)=" + GadgetWidth(WMN\scaCuePanels))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure sets scrollarea inner height and resizes gadgets
  
  nInitialCuePanelsWidth = GadgetWidth(WMN\scaCuePanels)
  bInitialHotkeysSplitterVisible = getVisible(WMN\splPanelsHotkeys)
  
  loadCurrHotkeys()
  
  For nKeyIndex = 0 To gnMaxCurrHotkey
    ; debugMsg(sProcName, "gaCurrHotkeys(" + nKeyIndex + ")\sCue=" + gaCurrHotkeys(nKeyIndex)\sCue)
    If gaCurrHotkeys(nKeyIndex)\sCue
      bHotkeysInUse = #True
      Break
    EndIf
  Next nKeyIndex
  
  If bHotkeysInUse
    If gbInOptionsWindow
      bDisplayHotkeys = mrOperModeOptions(gnOperMode)\bShowHotkeyList
    Else
      bDisplayHotkeys = grOperModeOptions(gnOperMode)\bShowHotkeyList
    EndIf
  EndIf
  debugMsg(sProcName, "bHotkeysInUse=" + strB(bHotkeysInUse) + ", bDisplayHotkeys=" + strB(bDisplayHotkeys) + ", bInSplitterEvent=" + strB(bInSplitterEvent))
  
  If bDisplayHotkeys
    With WMN
      If GGA(\splPanelsHotkeys, #PB_Splitter_FirstGadget) <> \scaCuePanels
        SGA(\splPanelsHotkeys, #PB_Splitter_FirstGadget, \scaCuePanels)
      EndIf
      If bInSplitterEvent = #False
        If GadgetWidth(\splPanelsHotkeys) <> GadgetWidth(\cntSouth) Or GadgetHeight(\splPanelsHotkeys) <> GadgetHeight(\cntSouth)
          ResizeGadget(\splPanelsHotkeys, #PB_Ignore, #PB_Ignore, GadgetWidth(\cntSouth), GadgetHeight(\cntSouth))
        EndIf
        If gbInOptionsWindow
          If grWOP\nCurrOperMode = #SCS_OPERMODE_DESIGN
            nPanelsHotkeysSplitterEndPos = grWMN\nPanelsHotkeysSplitterEndPosD
          ElseIf grWOP\nCurrOperMode = #SCS_OPERMODE_REHEARSAL
            nPanelsHotkeysSplitterEndPos = grWMN\nPanelsHotkeysSplitterEndPosR
          Else
            nPanelsHotkeysSplitterEndPos = grWMN\nPanelsHotkeysSplitterEndPosP
          EndIf
        Else
          If gnOperMode = #SCS_OPERMODE_DESIGN
            nPanelsHotkeysSplitterEndPos = grWMN\nPanelsHotkeysSplitterEndPosD
          ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
            nPanelsHotkeysSplitterEndPos = grWMN\nPanelsHotkeysSplitterEndPosR
          Else
            nPanelsHotkeysSplitterEndPos = grWMN\nPanelsHotkeysSplitterEndPosP
          EndIf
        EndIf
        ; debugMsg(sProcName, "nPanelsHotkeysSplitterEndPos=" + nPanelsHotkeysSplitterEndPos + ", GadgetWidth(\splPanelsHotkeys)=" + GadgetWidth(\splPanelsHotkeys))
        If (nPanelsHotkeysSplitterEndPos < 0) Or (nPanelsHotkeysSplitterEndPos > (GadgetWidth(\splPanelsHotkeys) * 0.25))
          ; debugMsg(sProcName, "bInitialSplitterPosMainPanelsHotkeysApplied=" + strB(bInitialSplitterPosMainPanelsHotkeysApplied) + ", GadgetWidth(\treHotkeys)=" + GadgetWidth(\treHotkeys) + ", gfMainXFactor=" + StrF(gfMainXFactor,4))
          If bInitialSplitterPosMainPanelsHotkeysApplied = #False
            nHotKeysWidth = Round(81 * gfMainXFactor, #PB_Round_Up)
          ElseIf GadgetWidth(\treHotkeys) > 10
            nHotKeysWidth = GadgetWidth(\treHotkeys)
          Else
            nHotKeysWidth = Round(81 * gfMainXFactor, #PB_Round_Up)
          EndIf
          ; nPanelsHotkeysSplitterEndPos = GadgetWidth(\splPanelsHotkeys) - nHotKeysWidth - gnVSplitterSeparatorWidth
          nPanelsHotkeysSplitterEndPos = nHotKeysWidth + gnVSplitterSeparatorWidth
          ; debugMsg(sProcName, "GadgetWidth(\splPanelsHotkeys)=" + GadgetWidth(\splPanelsHotkeys) + ", nHotKeysWidth=" + nHotKeysWidth + ", gnVSplitterSeparatorWidth=" + gnVSplitterSeparatorWidth + ", nPanelsHotkeysSplitterEndPos=" + nPanelsHotkeysSplitterEndPos)
        EndIf
        If (nPanelsHotkeysSplitterEndPos >= 0) And (nPanelsHotkeysSplitterEndPos < GadgetWidth(\splPanelsHotkeys))
          nNewPos = GadgetWidth(\splPanelsHotkeys) - nPanelsHotkeysSplitterEndPos
          If nNewPos >= 0
            If GGS(\splPanelsHotkeys) <> nNewPos
              SGS(\splPanelsHotkeys, nNewPos)
              ; debugMsg(sProcName, "SGS(\splPanelsHotkeys, " + nNewPos + ")")
            EndIf
          EndIf
        EndIf
      EndIf ; EndIf bInSplitterEvent = #False
      
      If gbInOptionsWindow = #False
        If gnOperMode = #SCS_OPERMODE_DESIGN
          grWMN\nPanelsHotkeysSplitterEndPosD = GadgetWidth(\splPanelsHotkeys) - GGS(\splPanelsHotkeys)
        ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
          grWMN\nPanelsHotkeysSplitterEndPosR = GadgetWidth(\splPanelsHotkeys) - GGS(\splPanelsHotkeys)
        Else
          grWMN\nPanelsHotkeysSplitterEndPosP = GadgetWidth(\splPanelsHotkeys) - GGS(\splPanelsHotkeys)
        EndIf
        grWMN\bPanelsHotkeysSplitterInitialPosApplied = #True
      EndIf
      
      nScrollAreaGadgetWidth = GadgetWidth(\scaCuePanels)
      nScrollAreaInnerWidth = nScrollAreaGadgetWidth - glScrollBarWidth - gl3DBorderAllowanceX
      nHotkeysLeft = nScrollAreaGadgetWidth
      nHotkeysHeight = GadgetHeight(\cntSouth)
      If (grWMN\bHotkeysCurrentlyDisplayed) And (GadgetX(\treHotkeys) = nHotkeysLeft) And (GadgetHeight(\treHotkeys) = nHotkeysHeight)
        bRepopulateOnly = #True
      Else
        If GGA(\scaCuePanels, #PB_ScrollArea_InnerWidth) <> nScrollAreaInnerWidth
          SGA(\scaCuePanels, #PB_ScrollArea_InnerWidth, nScrollAreaInnerWidth)
        EndIf
        setVisible(\treHotkeys, #True)
      EndIf
      SetGadgetColors(\treHotkeys, grColorScheme\aItem[#SCS_COL_ITEM_HK]\nTextColor, grColorScheme\aItem[#SCS_COL_ITEM_HK]\nBackColor)
    EndWith
    
    ; check hotkey types used
    For nKeyIndex = 0 To gnMaxCurrHotkey
      If gaCurrHotkeys(nKeyIndex)\sCue
        Select gaCurrHotkeys(nKeyIndex)\nActivationMethod
          Case #SCS_ACMETH_HK_TRIGGER
            bHKTrig = #True
          Case #SCS_ACMETH_HK_TOGGLE
            bHKTogl = #True
          Case #SCS_ACMETH_HK_NOTE
            bHKNote = #True
          Case #SCS_ACMETH_HK_STEP
            bHKStep = #True
        EndSelect
      EndIf
    Next nKeyIndex
    
    ClearGadgetItems(WMN\treHotkeys)
    WMN_processHotkeyClick(-1, "", #True) ; reset only
    
    If grProd\nCurrHotkeyBank > 0
      AddGadgetItem(WMN\treHotkeys, -1, "Bank " + grProd\nCurrHotkeyBank)
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_FrontColor, RGB(0, 240, 0))
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_BackColor, #SCS_Black)
      nTreeItemCount + 1
    EndIf
    
    nHdrBackColor = RGB($90,$90,$90)
    nHdrTextColor = RGB($E1,$E1,$E1)
    
    If bHKTrig
      AddGadgetItem(WMN\treHotkeys, -1, "HKeys(Trigger)")
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_FrontColor, nHdrTextColor)
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_BackColor, nHdrBackColor)
      nTreeItemCount + 1
      For nKeyIndex = 0 To gnMaxCurrHotkey
        With gaCurrHotkeys(nKeyIndex)
          If \sCue
            If \nActivationMethod = #SCS_ACMETH_HK_TRIGGER
              AddGadgetItem(WMN\treHotkeys, -1, \sHotkey + ": " + \sHotkeyLabel)
              \nHotkeyPanelRowNo = nTreeItemCount
              nTreeItemCount + 1
            EndIf
          EndIf
        EndWith
      Next nKeyIndex
    EndIf
    
    If bHKTogl
      AddGadgetItem(WMN\treHotkeys, -1, "HKeys(Toggle)")
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_FrontColor, nHdrTextColor)
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_BackColor, nHdrBackColor)
      nTreeItemCount + 1
      For nKeyIndex = 0 To gnMaxCurrHotkey
        With gaCurrHotkeys(nKeyIndex)
          If \sCue
            If \nActivationMethod = #SCS_ACMETH_HK_TOGGLE
              ; debugMsg(sProcName, "gaCurrHotkeys(" + nKeyIndex + ")\nToggleState=" + \nToggleState)
              If \nToggleState = 0
                sToggleState = "(1)"
              Else
                sToggleState = "(0)"
              EndIf
              AddGadgetItem(WMN\treHotkeys, -1, \sHotkey + sToggleState + ": " + \sHotkeyLabel)
              \nHotkeyPanelRowNo = nTreeItemCount
              nTreeItemCount + 1
            EndIf
          EndIf
        EndWith
      Next nKeyIndex
    EndIf
    
    If bHKNote
      AddGadgetItem(WMN\treHotkeys, -1, "HKeys(Note)")
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_FrontColor, nHdrTextColor)
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_BackColor, nHdrBackColor)
      nTreeItemCount + 1
      For nKeyIndex = 0 To gnMaxCurrHotkey
        With gaCurrHotkeys(nKeyIndex)
          If \sCue
            If \nActivationMethod = #SCS_ACMETH_HK_NOTE
              AddGadgetItem(WMN\treHotkeys, -1, \sHotkey + ": " + \sHotkeyLabel)
              \nHotkeyPanelRowNo = nTreeItemCount
              nTreeItemCount + 1
            EndIf
          EndIf
        EndWith
      Next nKeyIndex
    EndIf
    
    If bHKStep
      AddGadgetItem(WMN\treHotkeys, -1, "HKeys(Step)")
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_FrontColor, nHdrTextColor)
      SetGadgetItemColor(WMN\treHotkeys, nTreeItemCount, #PB_Gadget_BackColor, nHdrBackColor)
      nTreeItemCount + 1
      For nKeyIndex = 0 To gnMaxCurrHotkey
        With gaCurrHotkeys(nKeyIndex)
          If \sCue
            If \nActivationMethod = #SCS_ACMETH_HK_STEP
              AddGadgetItem(WMN\treHotkeys, -1, \sHotkey + "#" + \nHotkeyStepNo + ": " + \sHotkeyLabel)
              \nHotkeyPanelRowNo = nTreeItemCount
              nTreeItemCount + 1
            EndIf
          EndIf
        EndWith
      Next nKeyIndex
    EndIf
    
    setVisible(WMN\splPanelsHotkeys, #True)
    
  Else  ; bDisplayHotkeys = #False
    With WMN
      SGA(\splPanelsHotkeys, #PB_Splitter_FirstGadget, \cntDummyFirstForPanelsHotkeysSplitter)
      setVisible(\splPanelsHotkeys, #False)
      nScrollAreaGadgetWidth = GadgetWidth(WMN\cntSouth)
      nScrollAreaInnerWidth = nScrollAreaGadgetWidth - glScrollBarWidth - gl3DBorderAllowanceX
      ResizeGadget(WMN\scaCuePanels, #PB_Ignore, #PB_Ignore, nScrollAreaGadgetWidth, #PB_Ignore)
      SGA(\scaCuePanels, #PB_ScrollArea_InnerWidth, nScrollAreaInnerWidth)
    EndWith
  EndIf
  
  ; added 11Apr2019 11.8.0.2cn / 11.8.1ac to ensure cue panels resized if necessary
  If (GadgetWidth(WMN\scaCuePanels) <> nInitialCuePanelsWidth) Or (getVisible(WMN\splPanelsHotkeys) <> bInitialHotkeysSplitterVisible)
    ; debugMsg(sProcName, "GadgetWidth(WMN\scaCuePanels)=" + GadgetWidth(WMN\scaCuePanels) + ", nInitialCuePanelsWidth=" + nInitialCuePanelsWidth +
    ;                     ", getVisible(WMN\splPanelsHotkeys)=" + strB(getVisible(WMN\splPanelsHotkeys)) + ", bInitialHotkeysSplitterVisible=" + strB(bInitialHotkeysSplitterVisible))
    bChangeFound = #True
    nGadgetPropsIndex = getGadgetPropsIndex(WMN\scaCuePanels)
    gfMainPnlXFactor = GadgetWidth(WMN\scaCuePanels) / gaGadgetProps(nGadgetPropsIndex)\nOrigWidth
    ; debugMsg(sProcName, "gfMainXFactor=" + StrF(gfMainXFactor,4) + ", gfMainYFactor=" + StrF(gfMainYFactor,4) + ", gfMainPnlXFactor=" + StrF(gfMainPnlXFactor,4))
    ; debugMsg(sProcName, "resize cue panels")
    For n = 0 To gnMaxCuePanelCreated
      If PNL_InUse(n)
        WMN_resizeOneCuePanel(n)
      EndIf
    Next n
  EndIf
  ; end added 11Apr2019 11.8.0.2cn / 11.8.1ac
  
  If (bRepopulateOnly = #False) And (bChangeFound)
    ; debugMsg(sProcName, "gnMaxCuePanelCreated=" + gnMaxCuePanelCreated)
    For nCuePanel = 0 To gnMaxCuePanelCreated
      PNL_ResizeGadget(sProcName, nCuePanel, #PB_Ignore, #PB_Ignore, nScrollAreaInnerWidth, #PB_Ignore)
      gaDispPanel(nCuePanel)\bGradientDrawn = #False
      PNL_setSliderSizes(nCuePanel)
    Next nCuePanel
    
    ; debugMsg(sProcName, "gbWaitForDispPanels=" + strB(gbWaitForDispPanels))
    If gbWaitForDispPanels = #False
      samAddRequest(#SCS_SAM_LOAD_CUE_PANELS)
    EndIf
    
  EndIf
  
  If grLicInfo\bStepHotkeysAvailable
    WMN_enableOrDisableResetStepHKs()
  EndIf
  
  scsSetGadgetFont(WMN\treHotkeys, #SCS_FONT_WMN_GRDCUES)
  
  grWMN\bHotkeysCurrentlyDisplayed = bDisplayHotkeys
  
  ; debugMsg(sProcName, "GGS(WMN\splPanelsHotkeys)=" + GGS(WMN\splPanelsHotkeys))
  ; debugMsg(sProcName, #SCS_END + ", grWMN\bHotkeysCurrentlyDisplayed=" + strB(grWMN\bHotkeysCurrentlyDisplayed))

EndProcedure

Procedure WMN_setMidiEtcDisabledLabel()
  PROCNAMEC()
  Protected sText.s

  With grSession
    If \nMidiInEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "MIDIControl")
    EndIf
    If \nMidiOutEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "MIDISend")
    EndIf
    If \nRS232InEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "RS232Control")
    EndIf
    If \nRS232OutEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "RS232Send")
    EndIf
    If \nDMXInEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "DMXControl")
    EndIf
    If \nDMXOutEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "DMXSend")
    EndIf
    If \nNetworkInEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "NetworkControl")
    EndIf
    If \nNetworkOutEnabled = #SCS_DEVTYPE_DISABLED
      sText + ", " + Lang("WMN", "NetworkSend")
    EndIf
  EndWith
  
  If Len(sText) > 2
    sText = Trim(Mid(sText,3) + " " + Lang("WMN", "Disabled"))
    WMN_setStatusField(sText, #SCS_STATUS_INFO)
  EndIf
  
EndProcedure

Procedure WMN_ucPicInfo_GoToCue(Index, pCuePtr)
  PROCNAMEC()

  debugMsg(sProcName, "Index=" + Index + ", calling GoToCue(" + pCuePtr + ")")
  GoToCue(pCuePtr)
EndProcedure

Procedure WMN_displayWarningMsg(sText.s)
  PROCNAMEC()
  ; nb NOT 'near end warning'
  debugMsg(sProcName, #SCS_START + ", sText=" + #DQUOTE$ + sText + #DQUOTE$)
  gqTimeWarningMessageDisplayed = ElapsedMilliseconds()
  gbWarningMessageDisplayed = #True
  debugMsg(sProcName, "gqTimeWarningMessageDisplayed=" + traceTime(gqTimeWarningMessageDisplayed))
  WMN_setStatusField(sText, #SCS_STATUS_MAJOR_WARN)
  ; samAddRequest(#SCS_SAM_HIDE_WARNING_MSG, 0, 0, 0, "", gqTimeWarningMessageDisplayed + 10000) ; clear message after 10 seconds
  ; Commented out the above samAddRequest() 9Aug2024 11.10.3bc. It didn't exist in 11.10.2 and I can't remember why I (Mike) added it.
  
EndProcedure

Procedure WMN_hideWarningMsg()
  PROCNAMEC()
  ; nb NOT 'near end warning'
  Protected nTimeDiff
  
  debugMsg(sProcName, #SCS_START)
  
  ; ASSERT_THREAD(#SCS_THREAD_MAIN)
  If gnThreadNo > #SCS_THREAD_MAIN
    gqMainThreadRequest | #SCS_MTH_HIDE_WARNING_MSG
    ProcedureReturn
  EndIf
  If gbWarningMessageDisplayed
    nTimeDiff = ElapsedMilliseconds() - gqTimeWarningMessageDisplayed
    ; debugMsg(sProcName, "gqTimeWarningMessageDisplayed=" + traceTime(gqTimeWarningMessageDisplayed) + ", nTimeDiff=" + Str(nTimeDiff))
    If (nTimeDiff > 0) And (nTimeDiff < 500)
      ; ensure warning message displayed for at least 0.5 second
      Delay(500 - nTimeDiff)
    EndIf
  EndIf
  ; gqTimeWarningMessageDisplayed = 0
  gbWarningMessageDisplayed = #False
  gbMajorWarnDisplayed = #False
  debugMsg(sProcName, "clearing status field")
  WMN_setStatusField("", #SCS_STATUS_CLEAR)
  
EndProcedure

Procedure WMN_setFormColors()
  PROCNAMEC()
  Protected i
  Protected nTextColorMain, nBackColorMain
  Protected nTextColorDispPanelInactive, nBackColorDispPanelInactive

  debugMsg(sProcName, #SCS_START)
  
  With grColorScheme
    debugMsg(sProcName, "\sSchemeName=" + \sSchemeName)
    nTextColorMain = \aItem[#SCS_COL_ITEM_MW]\nTextColor
    nBackColorMain = \aItem[#SCS_COL_ITEM_MW]\nBackColor
    nTextColorDispPanelInactive = \aItem[#SCS_COL_ITEM_DP]\nTextColor
    nBackColorDispPanelInactive = \aItem[#SCS_COL_ITEM_DP]\nBackColor
    SetWindowColor(#WMN, nBackColorMain)
    SetGadgetColor(WMN\cntToolbarAndVU, #PB_Gadget_BackColor, nBackColorMain)
    SetGadgetColor(WMN\cntGoInfo, #PB_Gadget_BackColor, nBackColorMain)
    SetGadgetColor(WMN\cntGoAndMaster, #PB_Gadget_BackColor, nBackColorMain)
    SetGadgetColors(WMN\grdCues, nTextColorMain, nBackColorMain)
    SetGadgetColor(WMN\cntNorth, #PB_Gadget_BackColor, nBackColorMain)
    SetGadgetColor(WMN\cntSouth, #PB_Gadget_BackColor, nBackColorMain)
    SetGadgetColor(WMN\scaCuePanels, #PB_Gadget_BackColor, nBackColorMain)
    SetGadgetColors(WMN\lblMasterFader, nTextColorDispPanelInactive, RGB(213, 60, 0))
    SetGadgetColor(WMN\cntMasterFader, #PB_Gadget_BackColor, RGB(213, 60, 0))
  EndWith

  debugMsg(sProcName, "gnCueEnd=" + Str(gnCueEnd))
  For i = 1 To gnCueEnd
    setDerivedCueFields(i, #True)
    ; debugMsg(sProcName, "calling colorLine(" + getCueLabel(i) + ")")
    colorLine(i)
  Next i
  
  If gbInitialising = #False
    ; not necessary to call this during initialisation as WMN_loadHotkeyPanel() is called at the end of WMN_Form_Load()
    debugMsg(sProcName, "calling WMN_loadHotkeyPanel")
    WMN_loadHotkeyPanel()
  EndIf
  
  gbRedrawPanelGradients = #True
  
  If (gbInitialising = #False) And (gbLoadingCueFile = #False)
    debugMsg(sProcName, "calling setGoButton")
    setGoButton()     ; re-colors go info
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_resizeOneCuePanel(nDispPanel)
  PROCNAMEC()
  Protected fYFactor.f, fXFactor.f
  
  If gbInOptionsWindow
    fYFactor = gfMainOrigYFactor * mrOperModeOptions(gnOperMode)\nCuePanelVerticalSizing / 100
  Else
    fYFactor = gfMainOrigYFactor * grOperModeOptions(gnOperMode)\nCuePanelVerticalSizing / 100
  EndIf
  fXFactor = gfMainPnlXFactor
  
  PNL_setSliderScalingFactors(nDispPanel, fYFactor, fXFactor)
  ; debugMsg(sProcName, "calling PNL_Resize(" + Str(nDispPanel) + ", " + StrF(fYFactor,4) + ", " + StrF(fXFactor,4) + ")")
  PNL_Resize(nDispPanel, fYFactor, fXFactor)
  ; debugMsg(sProcName, "calling PNL_setSliderSizes")
  PNL_setSliderSizes(nDispPanel)
  ; debugMsg(sProcName, "calling PNL_adjustSliderSizes")
  PNL_adjustSliderSizes(nDispPanel)
  ; debugMsg(sProcName, "calling PNL_setPosTops")
  PNL_setPosTops(nDispPanel, fYFactor)
  ; debugMsg(sProcName, "calling PNL_drawPanelGradient")
  PNL_drawPanelGradient(nDispPanel)
  ; debugMsg(sProcName, "calling PNL_arrangeSliders")
  PNL_arrangeSliders(nDispPanel)
  
  If nDispPanel = 0
    With gaPnlVars(nDispPanel)
      If IsGadget(\lblRunningInd)
        grMain\nRunningIndDesignWidth = GadgetWidth(\lblRunningInd)
        ; debugMsg(sProcName, "grMain\nRunningIndDesignWidth=" + grMain\nRunningIndDesignWidth)
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_resizeGoAndMaster()
  PROCNAMEC()
  Protected fYFactor.f, fXFactor.f
  Protected nGoAndMasterHeight, nGoInfoTop, nGoInfoHeight, nLastPlayingInfoHeight
  Protected nStatusBarHeight
  Protected nShowFadersTop, nShowFadersHeight, nBorderLineTop
  Protected nInnerWidth, nInnerHeight, nStep
  Protected nLabelLeft, nLabelTop, nLabelWidth, nLabelHeight
  Protected nSliderLeft, nSliderTop, nSliderWidth, nSliderHeight
  Protected nTmp
  
  debugMsg(sProcName, #SCS_START)
  
  If gbInOptionsWindow
    fYFactor = gfMainYFactor * mrOperModeOptions(gnOperMode)\nCuePanelVerticalSizing / 100
  Else
    fYFactor = gfMainYFactor * grOperModeOptions(gnOperMode)\nCuePanelVerticalSizing / 100
  EndIf
  fXFactor = gfMainXFactor
  
  With WMN
    debugMsg(sProcName, "fYFactor=" + StrF(fYFactor,2))
    nGoAndMasterHeight = 42 * fYFactor
    nLastPlayingInfoHeight = 20 * fYFactor
    nGoInfoTop = GadgetY(\cntLastPlayingInfo) + nLastPlayingInfoHeight
    nGoInfoHeight = 20 * fYFactor
    nStatusBarHeight = 17 * fYFactor
    nLabelHeight = nGoInfoHeight - 2
    nSliderHeight = nGoInfoHeight - 3
    ; debugMsg(sProcName, "nGoAndMasterHeight=" + nGoAndMasterHeight + ", nGoInfoHeight=" + nGoInfoHeight + ", nLastPlayingInfoHeight=" + nLastPlayingInfoHeight +
    ;                     ", nLabelHeight=" + nLabelHeight + ", nSliderHeight=" + nSliderHeight +
    ;                     ", GadgetHeight(WMN\cntMasterFaders)=" + GadgetHeight(WMN\cntMasterFaders))
    
    ResizeGadget(\cntGoAndMaster, #PB_Ignore, #PB_Ignore, #PB_Ignore, nGoAndMasterHeight)
    ResizeGadget(\cntMasterFaders, #PB_Ignore, #PB_Ignore, #PB_Ignore, nGoAndMasterHeight)
    ResizeGadget(\cntLastPlayingInfo, #PB_Ignore, #PB_Ignore, #PB_Ignore, nLastPlayingInfoHeight)
    ResizeGadget(\cntMasterFader, #PB_Ignore, #PB_Ignore, #PB_Ignore, nLastPlayingInfoHeight)
    ResizeGadget(\cntGoInfo, #PB_Ignore, nGoInfoTop, #PB_Ignore, nGoInfoHeight)
    nInnerWidth = GadgetWidth(\cntMasterFaders)
    scsSetGadgetFont(\lblLastPlayingCue, #SCS_FONT_CUE_ITALIC10)
    scsSetGadgetFont(\lblLastPlayingInfo, #SCS_FONT_CUE_ITALIC10)
    scsSetGadgetFont(\lblNextManualCue, #SCS_FONT_CUE_ITALIC10)
    scsSetGadgetFont(\lblGoInfo, #SCS_FONT_CUE_ITALIC10)
    scsSetGadgetFont(\lblMasterFader, #SCS_FONT_CUE_NORMAL)
    nShowFadersHeight = (GadgetHeight(\cntGoAndMaster) >> 1) - 1
    nShowFadersTop = GadgetY(\cntMasterFader) + GadgetHeight(\cntMasterFader)
    If IsGadget(\btnShowFaders)
      ResizeGadget(\btnShowFaders, #PB_Ignore, nShowFadersTop, #PB_Ignore, nShowFadersHeight)
      scsSetGadgetFont(\btnShowFaders, #SCS_FONT_CUE_NORMAL)
    EndIf
    nBorderLineTop = GadgetHeight(\cntMasterFaders) - 1
    ResizeGadget(\lnGoAndMasterBorder, #PB_Ignore, nBorderLineTop, #PB_Ignore, #PB_Ignore)
    
    nLabelLeft = 0
    nLabelTop = 2 * fYFactor
    nLabelWidth = GadgetWidth(\lblMasterFader, #PB_Gadget_RequiredSize)
    nSliderTop = 1 * fYFactor
    nSliderLeft = nLabelLeft + nLabelWidth ; + gnGap
    nSliderWidth = nInnerWidth - nSliderLeft
    
    ; debugMsg(sProcName, "GadgetY(\lblMasterFader)=" + GadgetY(\lblMasterFader) + ", GadgetHeight(\lblMasterFader)=" + GadgetHeight(\lblMasterFader))
    ; debugMsg(sProcName, "calling ResizeGadget(\lblMasterFader, " + nLabelLeft + ", " + nLabelTop + ", " + nLabelWidth + ", " + nLabelHeight + ")")
    ResizeGadget(\lblMasterFader, nLabelLeft, nLabelTop, nLabelWidth, nLabelHeight)
    ; debugMsg(sProcName, "GadgetY(\lblMasterFader)=" + GadgetY(\lblMasterFader) + ", GadgetHeight(\lblMasterFader)=" + GadgetHeight(\lblMasterFader))
    SLD_ResizeGadget(sProcName, \sldMasterFader, nSliderLeft, #PB_Ignore, nSliderWidth, nSliderHeight)
    SLD_Resize(\sldMasterFader, #False)
    ResizeGadget(\cvsStatusBar, #PB_Ignore, #PB_Ignore, #PB_Ignore, nStatusBarHeight)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_updateToolBar()
  PROCNAMEC()
  Protected i
  Protected bStandbyButtonReqd
  Protected bTimeProfileButtonReqd
  Protected bChangeStandby
  Protected bChangeTimeProfile
  Protected bChangeSomething
  
  debugMsg(sProcName, #SCS_START)

  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      If aCue(i)\nStandby <> #SCS_STANDBY_NONE
        bStandbyButtonReqd = #True
      EndIf
      If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
        bTimeProfileButtonReqd = #True
      EndIf
    EndIf
  Next i

  debugMsg(sProcName, "bStandbyButtonReqd=" + strB(bStandbyButtonReqd) + ", bTimeProfileButtonReqd=" + strB(bTimeProfileButtonReqd))

  If (bStandbyButtonReqd <> grWMN\bStandbyButtonDisplayed)
    bChangeStandby = #True
    bChangeSomething = #True
  EndIf

  If (bTimeProfileButtonReqd <> grWMN\bTimeProfileButtonDisplayed)
    bChangeTimeProfile = #True
    bChangeSomething = #True
  EndIf

  If bChangeStandby
    setToolBarBtnVisible(#SCS_TBMB_STANDBY_GO, bStandbyButtonReqd, #True)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, bStandbyButtonReqd)
    grWMN\bStandbyButtonDisplayed = bStandbyButtonReqd
  EndIf

  If bChangeTimeProfile
    debugMsg(sProcName,"bChangeTimeProfile=" + strB(bChangeTimeProfile))
    setToolBarBtnVisible(#SCS_TBMB_TIME, bTimeProfileButtonReqd, #True)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuTimeProfile, bTimeProfileButtonReqd)
    grWMN\bTimeProfileButtonDisplayed = bTimeProfileButtonReqd
  EndIf

  If bChangeSomething
    ; debugMsg(sProcName, "calling drawToolBar(#SCS_TBM_MAIN)")
    drawToolBar(#SCS_TBM_MAIN)
    ; debugMsg(sProcName, "calling setSaveSettings()")
    setSaveSettings()
    ; debugMsg(sProcName, "calling setupVUDisplay")
    WMN_setupVUDisplay()
  EndIf
  
  ; debugMsg(sProcName, "calling WMN_buildPopupMenu_DevMap()")
  WMN_buildPopupMenu_DevMap()
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_setupVUDisplay()
  PROCNAMEC()
  Protected nLeft, nWidth
  Protected bVisible

  ; debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If gbInOptionsWindow
    gnVisMode = mrOperModeOptions(grWOP\nNodeOperMode)\nVisMode
    gnPeakMode = mrOperModeOptions(grWOP\nNodeOperMode)\nPeakMode
    gnCtrlPanelPos = mrOperModeOptions(grWOP\nNodeOperMode)\nCtrlPanelPos
  Else
    gnVisMode = grOperModeOptions(gnOperMode)\nVisMode
    gnPeakMode = grOperModeOptions(gnOperMode)\nPeakMode
    gnCtrlPanelPos = grOperModeOptions(gnOperMode)\nCtrlPanelPos
  EndIf
  
  WMN_setVUMenuItemStates()
  WMN_setPeakMenuItemStates()
  
  With WMN
    ; size and position cvsVULabels and cvsVUDisplay
    If IsGadget(\tbMain)
      nLeft = GadgetX(\tbMain) + GadgetWidth(\tbMain)
    Else
      nLeft = 0
    EndIf
    nWidth = WindowWidth(#WMN) - nLeft
    If nWidth > 40
      ResizeGadget(\cvsVULabels, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
      ResizeGadget(\cvsVUDisplay, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
      If (gnVisMode = #SCS_VU_NONE) Or (gnCtrlPanelPos = #SCS_CTRLPANEL_NONE)
        bVisible = #False
      Else
        bVisible = #True
      EndIf
    EndIf
    
    ; debugMsg(sProcName, "bVisible=" + strB(bVisible))
    setVisible(\cvsVULabels, bVisible)
    setVisible(\cvsVUDisplay, bVisible)
    
    initVU()     ; setup VU display info
    startVUDisplayIfReqd(#True)
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_setGridWindow()
  PROCNAMEC()
  Protected i
  Protected nFirstRowVisible, nLastRowVisible, nSelectedRow, nMaxRowsVisible
  Protected nLowestRow, nHighestRow
  Protected nAdj
  Protected bRedraw
  Protected nRowCount
  Protected nCueState
  Protected nFirstPlayingRow, nLastPlayingRow
  Protected nFirstPlayingRowStartCount, nLastPlayingRowStartCount
  Protected nRowBase = 0    ; row number of first row
  Protected nRowToGoOrFirstReadyTBC
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  If gnCueToGo < 1
    ; probably too early to start setting grid window
    debugMsg(sProcName, "exiting because gnCueToGo=" + getCueLabel(gnCueToGo))
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  
  nRowCount = CountGadgetItems(WMN\grdCues)
  ; debugMsg(sProcName, "nRowCount=" + nRowCount)
  If nRowCount < 1
    ProcedureReturn
  EndIf
  
  getGridRowInfo(WMN\grdCues)
  With grGridRowInfo
    nFirstRowVisible = \nFirstRowVisible
    nLastRowVisible = \nLastRowVisible
    nSelectedRow = \nSelectedRow
    nMaxRowsVisible = \nMaxRowsVisible
    ; debugMsg(sProcName, "nFirstRowVisible=" + nFirstRowVisible + ", nLastRowVisible=" + nLastRowVisible + ", nSelectedRow=" + nSelectedRow + ", nMaxRowsVisible=" + nMaxRowsVisible)
  EndWith
  
  grWMN\nMaxRowsVisible = nMaxRowsVisible
  
  nFirstPlayingRow = -1
  nLastPlayingRow = -1
  For i = 1 To gnLastCue
    If aCue(i)\nGrdCuesRowNo >= 0
      nCueState = aCue(i)\nCueState
      If (nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (nCueState <= #SCS_CUE_FADING_OUT) And (nCueState <> #SCS_CUE_HIBERNATING)
        If (aCue(i)\bHotkey = #False) And (aCue(i)\bExtAct = #False) And (aCue(i)\bCallableCue = #False)
          ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nGrdCuesRowNo=" + aCue(i)\nGrdCuesRowNo + ", \nTimeStarted=" + traceTime(aCue(i)\nTimeStarted))
          
          If nFirstPlayingRow = -1
            nFirstPlayingRow = aCue(i)\nGrdCuesRowNo
            nFirstPlayingRowStartCount = aCue(i)\nCueStartedCount
          Else
            If aCue(i)\nCueStartedCount < nFirstPlayingRowStartCount
              nFirstPlayingRow = aCue(i)\nGrdCuesRowNo
              nFirstPlayingRowStartCount = aCue(i)\nCueStartedCount
            EndIf
          EndIf
          
          If nLastPlayingRow = -1
            nLastPlayingRow = aCue(i)\nGrdCuesRowNo
            nLastPlayingRowStartCount = aCue(i)\nCueStartedCount
          Else
            If aCue(i)\nCueStartedCount >= nLastPlayingRowStartCount
              nLastPlayingRow = aCue(i)\nGrdCuesRowNo
              nLastPlayingRowStartCount = aCue(i)\nCueStartedCount
            EndIf
          EndIf
          
        EndIf
      EndIf
    EndIf
  Next i
  
  nLowestRow = -1
  nHighestRow = -1
  If grWMN\nMaxRowsVisible >= CountGadgetItems(WMN\grdCues)
    nLowestRow = nRowBase
    nHighestRow = CountGadgetItems(WMN\grdCues) - nRowBase
    
  Else
    ; default action is to leave unchanged
    nLowestRow = nFirstRowVisible
    nHighestRow = nLowestRow + nMaxRowsVisible - 1
    
    If (grProd\nFocusPoint = #SCS_FOCUS_LAST_PLAYING) And (nLastPlayingRow >= 0) And (gbForceFocusPointToNextManual = #False)
      If nLastPlayingRow = nFirstPlayingRow
        If (nFirstPlayingRow < nFirstRowVisible) Or (nFirstPlayingRow > (nFirstRowVisible + (nMaxRowsVisible >> 1)))
          ; only reposition if first playing row is not currently visible or is below the half-way point
          nLowestRow = nFirstPlayingRow - (nMaxRowsVisible >> 1)
          If nLowestRow < nRowBase
            nLowestRow = nRowBase
          EndIf
          nHighestRow = nLowestRow + nMaxRowsVisible - 1
        EndIf
      Else  ; nLastPlayingRow > nFirstPlayingRow
        If nLastPlayingRow > nLastRowVisible
          nHighestRow = nLastRowVisible
          nLowestRow = nHighestRow - nMaxRowsVisible + 1
          If nLowestRow < nFirstPlayingRow
            nLowestRow = nFirstPlayingRow
            nHighestRow = nLowestRow + nMaxRowsVisible -1
          EndIf
        ElseIf nFirstPlayingRow > nFirstRowVisible
          If nLastPlayingRow > (nFirstRowVisible + (nMaxRowsVisible >> 1))
            ; last playing row is below the half-way point
            nLowestRow = nFirstRowVisible + 1 ; move down one row
            nHighestRow = nLowestRow + nMaxRowsVisible - 1
          EndIf
        EndIf
      EndIf
    Else
      ; Added 4Aug2023 11.10.0bw following testing of cue file from Scott Britt that had ONLY TBC's and hotkey cues - no manual start
      ; cues so 'gnRowToGo' always pointed to 'End', which controlled which part of the grid was displayed (the part containing the 'End').
      ; If this condition occurs, nRowToGoOrFirstReadyTBC will be set to the first time-based-cue that is either ready or currently playing.
      nRowToGoOrFirstReadyTBC = gnRowToGo
      For i = 1 To gnLastCue
        If aCue(i)\bCueEnabled
          If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
            If aCue(i)\nCueState >= #SCS_CUE_READY And aCue(i)\nCueState < #SCS_CUE_COMPLETED And aCue(i)\nCueState <> #SCS_CUE_HIBERNATING
              If aCue(i)\nGrdCuesRowNo >= 0
                If aCue(i)\nGrdCuesRowNo < nRowToGoOrFirstReadyTBC
                  nRowToGoOrFirstReadyTBC = aCue(i)\nGrdCuesRowNo
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      Next i
      ; End added 4Aug2023 11.10.0bw
      
      ; Added 13Mar2025 11.10.8ah following email from Dave Cornish 24Feb2025 where the first 'ready' TBC was controlling the grid display
      ; even though there were many completed cues and then ready cues after that non-executed TBC
      If nRowToGoOrFirstReadyTBC <> gnRowToGo
        ; Implies the loop above found a TBC
        For i = nRowToGoOrFirstReadyTBC + 1 To gnLastCue
          If aCue(i)\bCueEnabled
            If aCue(i)\nActivationMethod <> #SCS_ACMETH_TIME
              If aCue(i)\nCueState >= #SCS_CUE_READY And aCue(i)\nCueState < #SCS_CUE_COMPLETED And aCue(i)\nCueState <> #SCS_CUE_HIBERNATING
                If aCue(i)\nGrdCuesRowNo >= 0
                  ; Reset nRowToGoOrFirstReadyTBC to gnRowToGo and exit loop
                  nRowToGoOrFirstReadyTBC = gnRowToGo
                  Break
                EndIf
              EndIf
            EndIf
          EndIf
        Next i
      EndIf
      ; End added 13Mar2025
      
      If nRowToGoOrFirstReadyTBC >= nRowBase ; Prior to 11.10.0bw, nRowToGoOrFirstReadyTBC here and in the following lines was gnRowToGo
        nLowestRow = nRowToGoOrFirstReadyTBC - (grWMN\nMaxRowsVisible >> 1)
        nHighestRow = nRowToGoOrFirstReadyTBC + (grWMN\nMaxRowsVisible >> 1) - 1
        If nLowestRow < nRowBase
          nAdj = nRowBase - nLowestRow
          nLowestRow = nRowBase
          nHighestRow = nHighestRow + nAdj
        EndIf
        If nHighestRow > gnRowEnd
          nAdj = nHighestRow - gnRowEnd
          nHighestRow = gnRowEnd
          nLowestRow = nLowestRow - nAdj
        EndIf
      EndIf
    EndIf
    
  EndIf
  
  If grOperModeOptions(gnOperMode)\bHideCueList = #False
    If nLowestRow < nRowBase
      nLowestRow = nRowBase
    EndIf
    If (nHighestRow > gnRowEnd) Or (nHighestRow = -1)
      nHighestRow = gnRowEnd
    EndIf
    
    bRedraw = getGrdCuesRedrawState()
    setGrdCuesRedrawState(#False)
    
    ; nHighestRow is highest row number, which physically is lowest on screen!
    If nHighestRow >= nRowBase
      SendMessage_(GadgetID(WMN\grdCues), #LVM_ENSUREVISIBLE, nHighestRow, 0)
    EndIf
    ; nLowestRow is lowest row number, which physically is highest on screen!
    If nLowestRow >= nRowBase
      SendMessage_(GadgetID(WMN\grdCues), #LVM_ENSUREVISIBLE, nLowestRow, 0)
    EndIf
    
    gbForceGridReposition = #False
    
    setGrdCuesRedrawState(bRedraw)
    
  EndIf
  
  ; call highlightLine as it may be necessary to 'select' the row if the row was not visible when the original call was made to highlightLine
  highlightLine(gnHighlightedCue)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_setupGrid()
  PROCNAMEC()
  Protected bGrdVisible
  Protected m, n, nMaxVisibleColNo
  Protected rOperModeOptions.tyOperModeOptions

  ; this procedure clears any existing rows and columns in the grid, and then adds the 'current' visible columns
  ; the procedure does NOT populate the rows
  
  ; debugMsg(sProcName, #SCS_START + ", gbInOptionsWindow=" + strB(gbInOptionsWindow) + ", gnOperMode=" + decodeOperMode(gnOperMode))
  
  If gbInOptionsWindow
    rOperModeOptions = mrOperModeOptions(gnOperMode)
  Else
    rOperModeOptions = grOperModeOptions(gnOperMode)
  EndIf
  
  With WMN
    bGrdVisible = getVisible(\grdCues)
    setVisible(\grdCues, #False)
    
    ; clear cue list
    ClearGadgetItems(\grdCues)
    ; debugMsg(sProcName, "ClearGadgetItems(WMN\grdCues)")
    
    ; remove existing columns
    removeAllGadgetColumns(\grdCues)
    
    nMaxVisibleColNo = -1
    
    For m = 0 To rOperModeOptions\rGrdCuesInfo\nMaxColNo
      rOperModeOptions\rGrdCuesInfo\aCol(m)\nCurColNo = rOperModeOptions\rGrdCuesInfo\aCol(m)\nCurColOrder
    Next m
    
    ; add the visible columns that have an 'nCurColNo'
    For m = 0 To rOperModeOptions\rGrdCuesInfo\nMaxColNo
      For n = 0 To rOperModeOptions\rGrdCuesInfo\nMaxColNo
        If rOperModeOptions\rGrdCuesInfo\aCol(n)\nCurColNo = m
          ; add a column, setting the column title and the column width
          ; debugMsg(sProcName, "add column: " + rOperModeOptions\rGrdCuesInfo\aCol(n)\sTitle + ", width=" + Str(rOperModeOptions\rGrdCuesInfo\aCol(n)\nCurWidth))
          AddGadgetColumn(\grdCues, m, rOperModeOptions\rGrdCuesInfo\aCol(n)\sTitle, rOperModeOptions\rGrdCuesInfo\aCol(n)\nCurWidth)
          nMaxVisibleColNo = m
          Break ; break n loop
        EndIf
      Next n
    Next m
    
    rOperModeOptions\rGrdCuesInfo\nMaxVisibleColNo = nMaxVisibleColNo
    ; debugMsg(sProcName, "\nMaxColNo=" + Str(rOperModeOptions\rGrdCuesInfo\nMaxColNo) + ", \nMaxVisibleColNo=" + Str(rOperModeOptions\rGrdCuesInfo\nMaxVisibleColNo))
    
    setVisible(\grdCues, bGrdVisible)
  EndWith
  
  If gbInOptionsWindow
    mrOperModeOptions(gnOperMode) = rOperModeOptions
  Else
    grOperModeOptions(gnOperMode) = rOperModeOptions
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_gotoCueListForShortcut(nShortcutFunction)
  PROCNAMEC()
  Protected nRow, nOriginalRow
  Protected bChecking, nDirection
  Protected nExclusiveCuePtr
  Protected nRowCount
  Protected nCuePtr
  Protected bDisplayWarning
  Protected bUseSAMForGoToCue

  debugMsg(sProcName, #SCS_START + ", nShortcutFunction=" + nShortcutFunction + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow + ", GGS(WMN\grdCues)=" + GGS(WMN\grdCues))

  nExclusiveCuePtr = checkExclusiveCuePlaying()
  If nExclusiveCuePtr >= 0
    WMN_setStatusField(ReplaceString(Lang("WMN", "ExclCueRun"), "$1", aCue(nExclusiveCuePtr)\sCue), #SCS_STATUS_ERROR)
    ProcedureReturn
  EndIf
  
  If gnHighlightedRow >= 0
    nOriginalRow = gnHighlightedRow
  Else
    nOriginalRow = WMN_getPrevRowForHiddenCue(gnHighlightedCue)
  EndIf
  nRow = nOriginalRow
  nRowCount = CountGadgetItems(WMN\grdCues)

  Select nShortcutFunction
    Case #SCS_WMNF_CueListUpOneRow
      debugMsg(sProcName, "#SCS_WMNF_CueListUpOneRow")
      nRow = nOriginalRow - 1
      ; Added 6Sep2024 11.10.3bv following emails from Damon Leibert, so now skips any currently playing cues
      While nRow > 0
        nCuePtr = WMN_getCuePtrForRowNo(nRow)
        If aCue(nCuePtr)\nCueState < #SCS_CUE_FADING_IN Or aCue(nCuePtr)\nCueState > #SCS_CUE_FADING_OUT
          ; cue not currently playing
          Break
        EndIf
        nRow - 1
      Wend
      ; End added 6Sep2024 11.10.3bv
      nDirection = -1
      bUseSAMForGoToCue = #True
      
    Case #SCS_WMNF_CueListDownOneRow
      debugMsg(sProcName, "#SCS_WMNF_CueListDownOneRow")
      nRow = nOriginalRow + 1
      nDirection = 1
      bUseSAMForGoToCue = #True
      
    Case #SCS_WMNF_CueListTop
      debugMsg(sProcName, "#SCS_WMNF_CueListTop")
      nRow = 0
      nDirection = -1
      bDisplayWarning = #True
      
    Case #SCS_WMNF_CueListEnd
      debugMsg(sProcName, "#SCS_WMNF_CueListEnd")
      nRow = nRowCount - 1
      nDirection = 1
      bDisplayWarning = #True
      
    Case #SCS_WMNF_CueListUpOnePage
      debugMsg(sProcName, "#SCS_WMNF_CueListUpOnePage")
      nRow = nOriginalRow - grWMN\nMaxRowsVisible
      nDirection = -1
      bDisplayWarning = #True
      
    Case #SCS_WMNF_CueListDownOnePage
      debugMsg(sProcName, "#SCS_WMNF_CueListDownOnePage")
      nRow = nOriginalRow + grWMN\nMaxRowsVisible
      nDirection = 1
      bDisplayWarning = #True
      
    Default
      debugMsg(sProcName, "Default, " + nShortcutFunction)
      
  EndSelect

  If nRow < 0
    nRow = 0              ; set nRow to the first row
  EndIf
  If nRow >= nRowCount
    nRow = nRowCount - 1  ; set nRow to the last row
  EndIf

  If nRow < 0
    ProcedureReturn
  EndIf

  debugMsg(sProcName, "nOriginalRow=" + nOriginalRow + ", nDirection=" + nDirection + ", nRow=" + nRow + ", nRowCount=" + nRowCount + ", gnCueEnd=" + gnCueEnd + ", gnLastCue=" + gnLastCue)

  ; skip over hotkeys, external activations, and callable cues
  bChecking = #True
  While (bChecking)
    nCuePtr = WMN_getCuePtrForRowNo(nRow)
    If nRow <= 0
      bChecking = #False
    ElseIf nRow >= gnRowEnd
      bChecking = #False
    ElseIf (aCue(nCuePtr)\bHotkey = #False) And (aCue(nCuePtr)\bExtAct = #False) And (aCue(nCuePtr)\bCallableCue = #False)
      bChecking = #False
    Else
      ; cue is a hotkey or external activation
      nRow + nDirection ; nDirection will be +1 if moving down the cue list, or -1 if moving up the cue list
    EndIf
  Wend

  If nRow <> nOriginalRow
    nCuePtr = WMN_getCuePtrForRowNo(nRow)
    debugMsg(sProcName, "WMN_getCuePtrForRowNo(" + nRow + ") returned " + getCueLabel(nCuePtr))
    ; added 4Feb2019 11.8.0.2af following email from Roei Luster about 'down arrow' in cue list auto-starting an auto-start cue that should now have had 'activation method required' set to manual
    If (nCuePtr > 0) And (nCuePtr <= gnLastCue)
      If aCue(nCuePtr)\nCueState = #SCS_CUE_READY
        Select aCue(nCuePtr)\nActivationMethod
          Case #SCS_ACMETH_AUTO, #SCS_ACMETH_OCM ; added #SCS_ACMETH_OCM 18Mar2020 11.8.2.3ab
            aCue(nCuePtr)\nActivationMethodReqd = #SCS_ACMETH_MAN
            debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(nCuePtr)\nActivationMethodReqd))
        EndSelect
      EndIf
    EndIf
    ; end added 4Feb2019 11.8.0.2af
    If bUseSAMForGoToCue And 1=2
      samAddRequest(#SCS_SAM_GOTO_CUE_LATEST_ONLY, nCuePtr, 0, #True, "", ElapsedMilliseconds()+500, bDisplayWarning, -1, #True, #False, 0, #True)
    Else
      debugMsg(sProcName, "calling GoToCue(" + getCueLabel(nCuePtr) + ", #True, " + strB(bDisplayWarning) + ", #True)")
      GoToCue(nCuePtr, #True, bDisplayWarning, #True) ; added bApplyDefaultGridClickAction parameter 17Mar2020 11.8.2.3aa
      debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
      calcCueStartValues(nCuePtr)
    EndIf
  EndIf

  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WMN_reposCueList(nShortcutFunction)
  PROCNAMEC()
  Protected bLockReqd, bLockedMutex
  
  debugMsg(sProcName, #SCS_START + ", nShortcutFunction=" + nShortcutFunction)
  
  TryLockCueListMutex(10)
  If (bLockReqd = #False) Or (bLockedMutex)
    WMN_gotoCueListForShortcut(nShortcutFunction)
    UnlockCueListMutex()
  Else
    samAddRequest(#SCS_SAM_GOTO_CUELIST_FOR_SHORTCUT, nShortcutFunction)
  EndIf
  
EndProcedure

Procedure WMN_showOrHideMasterFader()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If grOperModeOptions(gnOperMode)\bShowMasterFader
    setVisible(WMN\cntMasterFaders, #True)
  Else
    setVisible(WMN\cntMasterFaders, #False)
  EndIf
  grMain\bDisplayPopupMenu = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_showOrHideNextManualCue()
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START + ", bShowNextManualCue=" + strB(grOperModeOptions(gnOperMode)\bShowNextManualCue))

  If (grOperModeOptions(gnOperMode)\bShowNextManualCue)
    setVisible(WMN\cntGoInfo, #True)
  Else
    setVisible(WMN\cntGoInfo, #False)
  EndIf
  grMain\bDisplayPopupMenu = #True
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WMN_processSplitterRepositioned(nSplitterGadgetNo, bEndOfMove=#False)
  PROCNAMECG(nSplitterGadgetNo)
  
;   debugMsg(sProcName, #SCS_START + ", bEndOfMove=" + strB(bEndOfMove))
  
  With WMN
    Select nSplitterGadgetNo
      Case \splNorthSouth
        ; debugMsg(sProcName, "GadgetY(\splNorthSouth)=" + GadgetY(\splNorthSouth) + ", GadgetY(\cntNorth)=" + GadgetY(\cntNorth) + ", GadgetY(\cvsStatusBar)=" + GadgetY(\cvsStatusBar))
        If bEndOfMove
          If GadgetHeight(\cntNorth) < 4
            grOperModeOptions(gnOperMode)\bHideCueList = #True
          Else
            grOperModeOptions(gnOperMode)\bHideCueList = #False
          EndIf
          WMN_resizeGadgetsForSplitters(#True)
          If grWMN\bNorthSouthSplitterInitialPosApplied
            ; the '\bNorthSouthSplitterInitialPosApplied' flag is required so that \nNorthSouthSplitterPosD/P is not set during initialisation of the window when the splitter is first displayed
            If gnOperMode = #SCS_OPERMODE_DESIGN
              grWMN\nNorthSouthSplitterPosD = GGS(\splNorthSouth)
            ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
              grWMN\nNorthSouthSplitterPosR = GGS(\splNorthSouth)
            Else
              grWMN\nNorthSouthSplitterPosP = GGS(\splNorthSouth)
            EndIf
          EndIf
        EndIf
        
      Case \splCueListMemo
        If bEndOfMove
          WMN_resizeGadgetsForSplitters(#True)
        EndIf
        
      Case \splPanelsHotkeys
        If bEndOfMove
          WMN_resizeGadgetsForSplitters(#True)
        EndIf
        
      Case \splMainMemo
        If bEndOfMove
          SGA(\splPanelsHotkeys, #PB_Splitter_FirstMinimumSize, 0)
          ResizeGadget(\cvsMemoTitleBar, #PB_Ignore, #PB_Ignore, GadgetWidth(\cntMemo), #PB_Ignore)
          ; debugMsg(sProcName, "ResizeGadget(\cvsMemoTitleBar, #PB_Ignore, #PB_Ignore, " + GadgetWidth(\cntMemo) + ", #PB_Ignore)")
          \rchMainMemoObject\Resize(#PB_Ignore, #PB_Ignore, GadgetWidth(\cntMemo), #PB_Ignore)
          WEN_drawTitleBarForMainMemoPanel(grMain\nMainMemoSubPtr)
          If GGS(\splMainMemo) > GGA(\splMainMemo, #PB_Splitter_FirstMinimumSize)
            ; the above test added 19Nov2019 11.8.2rc5 because under some circumstances (not yet determined) the splitter position is set to the minimum,
            ; and if that is then saved it causes the memo to be displayed very wide next time SCS is opened
            If gnOperMode = #SCS_OPERMODE_DESIGN
              grWMN\nMainMemoSplitterPosD = GGS(\splMainMemo)
            ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
              grWMN\nMainMemoSplitterPosR = GGS(\splMainMemo)
            Else
              grWMN\nMainMemoSplitterPosP = GGS(\splMainMemo)
            EndIf
          Else
            debugMsg(sProcName, "GGS(\splMainMemo)=" + GGS(\splMainMemo) + ", GGA(\splMainMemo, #PB_Splitter_FirstMinimumSize)=" + GGA(\splMainMemo, #PB_Splitter_FirstMinimumSize) +
                                ", WindowWidth(#WMN)=" + WindowWidth(#WMN) + ", GetWindowState(#WMN)=" + GetWindowState(#WMN))
          EndIf
          WMN_resizeGadgetsForSplitters(#True)
        EndIf
        
    EndSelect
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_displayProdTimer()
  PROCNAMEC()
  Protected sProdTimer.s
  Static nPrevState = #SCS_PTS_NOT_STARTED
  Static nPrevTimeInSecs = -1
  Static nBracketWidth
  Static nPausedWidth
  Protected bDrawTimer
  
  With grProdTimer
    Select \nPTState
      Case #SCS_PTS_NOT_STARTED
        If nPrevState <> #SCS_PTS_NOT_STARTED
          debugMsg(sProcName, "calling WMN_clearProdTimer(#True)")
          WMN_clearProdTimer(#True)
          nPrevTimeInSecs = -1
        EndIf
        
      Case #SCS_PTS_RUNNING
        gnProdTimerTimeInSecs = ((ElapsedMilliseconds() - \qPTStartTime) - \nPTTotalTimeOnPause) / 1000
        If (gnProdTimerTimeInSecs <> nPrevTimeInSecs) Or (\bPTForceRedisplay)
          Select grOperModeOptions(gnOperMode)\nTimerDispLocn
            Case #SCS_PTD_STATUS_LINE ; status line
              If IsGadget(WMN\cvsStatusBar)
                If StartDrawing(CanvasOutput(WMN\cvsStatusBar))
                  scsDrawingFont(#SCS_FONT_WMN_NORMAL)
                  sProdTimer = TimeInSecsToString(gnProdTimerTimeInSecs)
                  If Len(sProdTimer) <> grWMN\nProdTimerLength
                    ; debugMsg(sProcName, "sProdTimer=" + sProdTimer + ", Len(sProdTimer)=" + Str(Len(sProdTimer)) + ", grWMN\nProdTimerLength=" + Str(grWMN\nProdTimerLength))
                    grWMN\nProdTimerLength = Len(sProdTimer)
                    grWMN\nProdTimerX = GadgetWidth(WMN\cvsStatusBar) - TextWidth(sProdTimer) - 12
                  EndIf
                  If nPausedWidth > 0
                    Box(grWMN\nProdTimerX - nBracketWidth, grWMN\nStatusTextTop, nPausedWidth, TextHeight("[]"), grWMN\nStatusBackColor)
                    ; debugMsg(sProcName, "Box(" + Str(grWMN\nProdTimerX - nBracketWidth) + ", " + Str(grWMN\nStatusTextTop) + ", " + Str(nPausedWidth) + ", " + Str(TextHeight("[]")) + ", grWMN\nStatusBackColor)")
                    nPausedWidth = 0
                  EndIf
                  DrawText(grWMN\nProdTimerX, grWMN\nStatusTextTop, sProdTimer, grWMN\nStatusFrontColor, grWMN\nStatusBackColor)
                  StopDrawing()
                EndIf
              EndIf
              
            Case #SCS_PTD_SEPARATE_WINDOW ; separate window
              sProdTimer = TimeInSecsToString(gnProdTimerTimeInSecs)
              WTI_displayTimer(sProdTimer)
              
          EndSelect
          nPrevTimeInSecs = gnProdTimerTimeInSecs
        EndIf
        
      Case #SCS_PTS_PAUSED
        If (nPrevState <> #SCS_PTS_PAUSED And nPrevTimeInSecs >= 0) Or (\bPTForceRedisplay)
          Select grOperModeOptions(gnOperMode)\nTimerDispLocn
            Case #SCS_PTD_STATUS_LINE ; status line
              If IsGadget(WMN\cvsStatusBar)
                If StartDrawing(CanvasOutput(WMN\cvsStatusBar))
                  scsDrawingFont(#SCS_FONT_WMN_NORMAL)
                  If nBracketWidth = 0
                    nBracketWidth = TextWidth("[")
                  EndIf
                  sProdTimer = TimeInSecsToString(nPrevTimeInSecs)
                  DrawText(grWMN\nProdTimerX - nBracketWidth, grWMN\nStatusTextTop, "[" + sProdTimer + "]", grWMN\nStatusFrontColor, grWMN\nStatusBackColor)
                  nPausedWidth = TextWidth("[" + sProdTimer + "]")
                  ; debugMsg(sProcName, "nBracketWidth=" + Str(nBracketWidth) + ", nPausedWidth=" + Str(nPausedWidth))
                  StopDrawing()
                EndIf
              EndIf
              
            Case #SCS_PTD_SEPARATE_WINDOW ; separate window
              sProdTimer = "[" + TimeInSecsToString(nPrevTimeInSecs) + "]"
              WTI_displayTimer(sProdTimer)
              
          EndSelect
        EndIf
        
    EndSelect
    nPrevState = \nPTState
    \bPTForceRedisplay = #False
    
  EndWith
  
EndProcedure

Procedure WMN_clearProdTimer(bHideTimerWindow)
  PROCNAMEC()
  Protected nWidth, nHeight
  
  With grWMN
    Select grOperModeOptions(gnOperMode)\nTimerDispLocn
      Case #SCS_PTD_STATUS_LINE ; status line
        If \nProdTimerX > 0
          If IsGadget(WMN\cvsStatusBar)
            If StartDrawing(CanvasOutput(WMN\cvsStatusBar))
              nWidth = GadgetWidth(WMN\cvsStatusBar) - \nProdTimerX
              nHeight = GadgetHeight(WMN\cvsStatusBar) - \nStatusTextTop
              Box(\nProdTimerX, \nStatusTextTop, nWidth, nHeight, \nStatusBackColor)
              StopDrawing()
            EndIf
          EndIf
        EndIf
        
      Case #SCS_PTD_SEPARATE_WINDOW ; separate window
        WTI_displayTimer("0.00") ; safe to set time at "0:00" rather than "" as whole canvas is refreshed
        If bHideTimerWindow
          If IsWindow(#WTI)
            setWindowVisible(#WTI, #False)
          EndIf
        EndIf
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WMN_setStatusField(sStatusField.s, nStatusType=#SCS_STATUS_INFO, nExtraDisplayTime=0, bMayOverrideStatus=#False)
  PROCNAMEC()
  Protected sStatusText.s, nFrontColor, nBackColor
  Protected nLeft, nTop, nWidth, nTextWidth, nHeight, nTextHeight
  Static sWarning.s
  Static nWarningLength
  Static nFlashState
  Protected qTimeNow.q
  
  ; debugMsg(sProcName, #SCS_START + ", sStatusField=" + sStatusField)
  
  ; set default colors (may be overriden later in this procedure)
  nFrontColor = grColorScheme\aItem[#SCS_COL_ITEM_MW]\nTextColor
  nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_MW]\nBackColor
  
  If gnThreadNo > #SCS_THREAD_MAIN
    ; if not called from the main thread then save the parameters and set flag so that main thread will re-call this procedure
    With grMain
      \sStatusField = sStatusField
      \nStatusType = nStatusType
      \nExtraDisplayTime = nExtraDisplayTime
      \bMayOverrideStatus = bMayOverrideStatus
    EndWith
    gqMainThreadRequest | #SCS_MTH_SET_STATUS_FIELD
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, #SCS_START + ", sStatusField=" + Trim(sStatusField))
  
  If gbStoppingEverything
    If nStatusType < #SCS_STATUS_MAJOR_WARN
      ; ignore
      ProcedureReturn
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "gnCurrentStatusType=" + Str(gnCurrentStatusType) + ", gbMayOverrideStatus=" + strB(gbMayOverrideStatus))
  If (nStatusType < gnCurrentStatusType) And (nStatusType <> #SCS_STATUS_CLEAR)
    ; prevents info messages overriding warnings, or similar overrides
    If gbMayOverrideStatus = #False   ; gbMayOverrideStatus is the bMayOverrideStatus parameter from the previous successful call of WMN_setStatusField()
      ; debugMsg(sProcName, "exit a")
      ProcedureReturn
    EndIf
  EndIf
  gbMayOverrideStatus = bMayOverrideStatus
  
  If nStatusType = #SCS_STATUS_MAJOR_WARN
    gbMajorWarnDisplayed = #True
  EndIf
  
  sStatusText = Trim(sStatusField)
  If FindString(sStatusText, #CRLF$) > 0
    sStatusText = ReplaceString(Trim(sStatusText), "." + #CRLF$, ". ")
    sStatusText = ReplaceString(Trim(sStatusText), #CRLF$, ". ")
  EndIf

  If Len(Trim(sStatusText)) = 0
    debugMsg(sProcName, "clearing")
    gbDisplayStatus = #False
    gnCurrentStatusType = #SCS_STATUS_CLEAR
    gbWarningMessageDisplayed = #False
    
  Else
    qTimeNow = ElapsedMilliseconds()
    Select nStatusType
      Case #SCS_STATUS_CLEAR
        debugMsg(sProcName, "clear")
        gbDisplayStatus = #False
        gbWarningMessageDisplayed = #False
        
      Case #SCS_STATUS_WARN
        debugMsg(sProcName, "warn: " + sStatusText)
        gqStatusDisplayed = qTimeNow + nExtraDisplayTime
        gqTimeWarningMessageDisplayed = qTimeNow
        gbWarningMessageDisplayed = #True
        gbDisplayStatus = #True
        nFrontColor = #SCS_Black
        nBackColor = $E83F8
        
      Case #SCS_STATUS_MAJOR_WARN
        debugMsg(sProcName, "major: " + sStatusText)
        gqStatusDisplayed = qTimeNow + 36000000     ; adds 10 hours to make display 'permanent' for major warnings
        gqTimeWarningMessageDisplayed = qTimeNow
        gbWarningMessageDisplayed = #True
        gbDisplayStatus = #True
        nFrontColor = #SCS_Black
        nBackColor = #SCS_Yellow
        
      Case #SCS_STATUS_MAJOR_WARN_NORMAL_COLORS
        ; debugMsg(sProcName, "major (normal): " + sStatusText)
        nFrontColor = #SCS_Black
        nBackColor = #SCS_Yellow
        
      Case #SCS_STATUS_MAJOR_WARN_REVERSE_COLORS
        ; debugMsg(sProcName, "major (reverse): " + sStatusText)
        nFrontColor = #SCS_Yellow
        nBackColor = #SCS_Black
        
      Case #SCS_STATUS_ERROR
        debugMsg(sProcName, "error: " + sStatusText)
        gqStatusDisplayed = qTimeNow + nExtraDisplayTime ; + 5000 ; add 5 seconds to display time for errors (removed 5 seconds extra time 24Aug2024 11.10.3bm)
        gqTimeWarningMessageDisplayed = qTimeNow
        gbWarningMessageDisplayed = #True
        gbDisplayStatus = #True
        nFrontColor = #SCS_White
        nBackColor = #SCS_Red
        
      Case #SCS_STATUS_CLOSEDOWN
        debugMsg(sProcName, "closedown")
        gqStatusDisplayed = qTimeNow + 36000000 ; adds 10 hours to make display 'permanent'
        gbDisplayStatus = #True
        nFrontColor = #SCS_Yellow
        nBackColor = #SCS_Black
        
      Case #SCS_STATUS_INCOMING_COMMAND
        ; debugMsg(sProcName, "incoming: " + sStatusText)
        If grOperModeOptions(gnOperMode)\nMidiInDisplayTimeout < 0
          gqStatusDisplayed = qTimeNow + 36000000     ; adds 10 hours to make display 'permanent'
        Else
          gqStatusDisplayed = qTimeNow + grOperModeOptions(gnOperMode)\nMidiInDisplayTimeout - #SCS_STATUS_DISPLAY_TIME
        EndIf
        ; debugMsg(sProcName, "qTimeNow=" + traceTime(qTimeNow) +", grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\nMidiInDisplayTimeout=" + grOperModeOptions(gnOperMode)\nMidiInDisplayTimeout + ", gqStatusDisplayed=" + traceTime(gqStatusDisplayed))
        gbDisplayStatus = #True
        nFrontColor = #SCS_Black
        nBackColor = #SCS_Light_Green
        
      Case #SCS_STATUS_INFO
        debugMsg(sProcName, "info: " + sStatusText)
        gqStatusDisplayed = qTimeNow + nExtraDisplayTime
        gbDisplayStatus = #True
        
      Default
        debugMsg(sProcName, "other: " + Str(nStatusType) + ": " + sStatusText)
        gqStatusDisplayed = qTimeNow + nExtraDisplayTime
        gbDisplayStatus = #True
        
    EndSelect
    
    gnCurrentStatusType = nStatusType
    
  EndIf
  
  Select gnCurrentStatusType
    Case #SCS_STATUS_MAJOR_WARN, #SCS_STATUS_MAJOR_WARN_NORMAL_COLORS, #SCS_STATUS_MAJOR_WARN_REVERSE_COLORS
      gbMajorWarnDisplayed = #True
    Default
      gbMajorWarnDisplayed = #False
  EndSelect
  
  nWidth = GadgetWidth(WMN\cvsStatusBar)
  nHeight = GadgetHeight(WMN\cvsStatusBar)
  nTop = -1
  If StartDrawing(CanvasOutput(WMN\cvsStatusBar))
    Box(0,0,nWidth,nHeight,nBackColor)
    If gnCurrentStatusType <> #SCS_STATUS_CLEAR
      If gnCurrentStatusType = #SCS_STATUS_INFO
        LineXY(0,0,nWidth,0,#SCS_Dark_Grey)
      EndIf
      ; scsDrawingFont(#SCS_FONT_WMN_BOLD)
      scsDrawingFont(#SCS_FONT_CUE_BOLD)
      DrawingMode(#PB_2DDrawing_Transparent)
      nTextWidth = TextWidth(sStatusText)
      If nTextWidth > nWidth
        ; text is too wide, so if the text status with "Warning! " then remove that and try again
        ; load static variables if necessary
        If nWarningLength = 0
          sWarning = Lang("Common", "Warning") + "! "
          nWarningLength = Len(sWarning)
        EndIf
        If LCase(Left(sStatusText, nWarningLength)) = LCase(sWarning)
          sStatusText = Mid(sStatusText, nWarningLength+1)
        EndIf
        nTextWidth = TextWidth(sStatusText)
      EndIf
      If nTextWidth >= nWidth
        nLeft = 0
      Else
        nLeft = (nWidth - nTextWidth) >> 1
      EndIf
      nTextHeight = TextHeight(sStatusText)
      If nTextHeight >= nHeight
        nTop = 0
      Else
        nTop = (nHeight - nTextHeight) >> 1
      EndIf
      DrawText(nLeft,nTop,sStatusText,nFrontColor)
    EndIf
    StopDrawing()
  EndIf
  
  With grWMN
    \nStatusBackColor = nBackColor
    \nStatusFrontColor = nFrontColor
    If nTop >= 0  ; will be -1 for 'clear', so leave current '\nStatusTextTop' unchanged
      \nStatusTextTop = nTop
      ; debugMsg(sProcName, "\nStatusTextTop=" + \nStatusTextTop)
    EndIf
  EndWith
  
  With grProdTimer
    If \nPTState <> #SCS_PTS_NOT_STARTED
      \bPTForceRedisplay = #True
    EndIf
  EndWith
  
  If gbDisplayStatus = #False
    gbLostFocusDisplayed = #False
    ; debugMsg0(sProcName, "gbLostFocusDisplayed=#False")
    gbPauseAllDisplayed = #False
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_setupGridDefaults()
  PROCNAMEC()
  Protected n, nColNo, nOperMode
  Protected nTextImage, nTextWidth
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; create a temporary image for calculating default text widths.
  ; prior to SCS 11.6 StartDrawing used WindowOutput(#WMN) but WMN_setupGridDefaults() needs to be called prior to #WMN being
  ; created in case the user clicks the 'Options' button in the 'Load Production' window (#WLP) before #WMN has been opened.
  nTextImage = scsCreateImage(16,16)
  If StartDrawing(ImageOutput(nTextImage))
    
    DrawingFont(#SCS_FONT_WMN_GRDCUES)
    
    For nOperMode = 0 To #SCS_OPERMODE_LAST
      
      nColNo = -1
      
      If ArraySize(grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol()) < #SCS_GRDCUES_LAST
        ReDim grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_LAST)
      EndIf
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_CU) ; Cue
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("S/C 999S-")   ; note: no language translation required as these text strings are not displayed
        \sTitle = Lang("Common", "Cue")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_PG) ; Page
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("p1234xx")
        \sTitle = Lang("Common", "Page")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_DE) ; Description
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("This is a description of a show cue")
        \sTitle = Lang("Common", "Description")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_CT) ; Cue Type
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("Snd,LvlChg&Stp--")
        \sTitle = Lang("Common", "CueType")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_CS) ; Cue State
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("Count Down--")
        nTextWidth = TextWidth(Lang("Common","NextManual") + "----")
        ; debugMsg(sProcName, "\nDefWidth=" + \nDefWidth + ", nTextWidth=" + nTextWidth)
        If nTextWidth > \nDefWidth
          \nDefWidth = nTextWidth
        EndIf
        \sTitle = Lang("Common", "State")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_AC) ; Activation
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("HKey (Trig) F3----")
        \sTitle = Lang("Common", "Activation")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_FN) ; File / Info
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("wwwwwwwwwwwwwwwwww.wav")
        \sTitle = Lang("Common", "FileInfo")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_DU) ; Length (Duration)
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("88:88.888--")
        \sTitle = Lang("Common", "Length")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_SD) ; Device
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("V:1 A:Rear Stg--")
        \sTitle = grText\sTextDevice
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_WR) ; When Required
        \nDefColNo = -1                                                    ; not visible
        \nDefWidth = TextWidth("This is a when required desc")
        \sTitle = Lang("Common", "WhenReqd")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_MC) ; MIDI Cue #
        \nDefColNo = -1                                                    ; not visible
        \nDefWidth = TextWidth("MIDI/DMX Cue")
        \sTitle = Lang("Common", "MIDICue")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_FT) ; File Type
        \nDefColNo = -1                                                    ; not visible
        \nDefWidth = TextWidth("WAV (44100Hz, 16 Bit, Stereo)---")
        \sTitle = Lang("Common", "FileType")
      EndWith
      
      With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_LV) ; Level (dB)
        \nDefColNo = -1                                                    ; not visible
        \nDefWidth = TextWidth("+12.3dB---")
        \sTitle = Lang("Common", "Level")
      EndWith
      
      For n = 0 To grOperModeOptions(nOperMode)\rGrdCuesInfo\nMaxColNo
        With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(n)
          \nCurWidth = \nDefWidth
          \nCurColNo = \nDefColNo
        EndWith
      Next n
      
      ; debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(nOperMode) + ")\rGrdCuesInfo\sLayoutString=" + grOperModeOptions(nOperMode)\rGrdCuesInfo\sLayoutString)
      If grOperModeOptions(nOperMode)\rGrdCuesInfo\sLayoutString
        unpackGridLayoutString(@grOperModeOptions(nOperMode)\rGrdCuesInfo, #SCS_GT_GRDCUES)
      EndIf
      
      For n = 0 To grOperModeOptions(nOperMode)\rGrdCuesInfo\nMaxColNo
        With grOperModeOptions(nOperMode)\rGrdCuesInfo\aCol(n)
          ; debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(nOperMode) + ")\rGrdCuesInfo\aCol(" + n + ")\sColType=" + \sColType + ", \nCurColNo=" + \nCurColNo +
          ;                     ", \nCurWidth=" + \nCurWidth + ", \nDefWidth=" + \nDefWidth)
          If \nCurColNo >= 0
            \bColVisible = #True
          Else
            \bColVisible = #False
          EndIf
          If (\bColVisible) And (\nCurWidth < 10)
            \nCurWidth = \nDefWidth
          EndIf
          \nIniWidth = \nCurWidth
          \nIniColNo = \nCurColNo
          \nCurColOrder = \nCurColNo
        EndWith
      Next n
      
    Next nOperMode
    
    StopDrawing()
  EndIf
  
  FreeImage(nTextImage)
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_setGrdCuesCellValue(nRowNo, nColIndex, sValue.s)
  PROCNAMEC()
  Protected nColNo
  
  If gbInOptionsWindow
    nColNo = mrOperModeOptions(gnOperMode)\rGrdCuesInfo\aCol(nColIndex)\nCurColNo
  Else
    nColNo = grOperModeOptions(gnOperMode)\rGrdCuesInfo\aCol(nColIndex)\nCurColNo
  EndIf

  If (nRowNo >= 0) And (nColNo >= 0)
    If GetGadgetItemText(WMN\grdCues, nRowNo, nColNo) <> sValue
      SetGadgetItemText(WMN\grdCues, nRowNo, sValue, nColNo)
      ; debugMsg(sProcName, "nRowNo=" + nRowNo + ", nColNo=" + nColNo + ", sValue=" + sValue)
    EndIf
  EndIf
  
EndProcedure

Procedure WMN_processRightClick()
  PROCNAMEC()
  Protected bRightClickProcessed
  
  debugMsg(sProcName, #SCS_START)
  
  If (grMain\bRightButtonDownTimeSet = #False) Or ((ElapsedMilliseconds() - grMain\qRightButtonDownTime) > grGeneralOptions\nDoubleClickTime)
    grMain\qRightButtonDownTime = ElapsedMilliseconds()
    grMain\bRightButtonDownTimeSet = #True
    MouseDown(2)
    checkMainHasFocus(2)
    bRightClickProcessed = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning bRightClickProcessed=" + strB(bRightClickProcessed))
  ProcedureReturn bRightClickProcessed
  
EndProcedure

Procedure WMN_processRightClickIfMouseButtonUp()
  PROCNAMEC()
  
  If (GetAsyncKeyState_(#VK_RBUTTON) & 32768) = 0
    ; mouse button is up
    WMN_processRightClick()
  EndIf
  
EndProcedure

Procedure WMN_EventHandler()
  PROCNAMEC()
  Protected nWindowTimer
  
;   If gnEventType > 0
;     debugMsg0(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventGadgetNo=G" + GadgetNoAndName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
;   EndIf

  With WMN
    
    Select gnWindowEvent
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        logKeyEvent("gnEventMenu=" + gnEventMenu + " (" + decodeMenuItem(gnEventMenu) + ")")
        Select gnEventMenu
            
            ; keyboard shortcut functions
          Case #SCS_ALLF_DummyFirst To #SCS_ALLF_DummyLast
            Select gnEventMenu
              Case #SCS_WMNF_CueListDownOneRow, #SCS_WMNF_CueListUpOneRow, #SCS_WMNF_CueListTop, #SCS_WMNF_CueListEnd, #SCS_WMNF_CueListDownOnePage, #SCS_WMNF_CueListUpOnePage,
                   #SCS_WMNF_CueMarkerNext, #SCS_WMNF_CueMarkerPrev, #SCS_WMNF_TapDelay
                WMN_processShortcut(gnEventMenu, #True)
              Default
                WMN_processShortcut(gnEventMenu)
            EndSelect
            
            ; 'Cue Control' menu items
          Case #WMN_mnuGo
            goClicked(#True)
          Case #WMN_mnuPauseAll
            processPauseResumeAll()
          Case #WMN_mnuStopAll
            processStopAll()
          Case #WMN_mnuFadeAll
            processFadeAll()
          Case #WMN_mnuStandbyGo
            standbyGoClicked()
          Case #WMN_mnuTimeProfile
            WTP_Form_Show(#True, #WMN)
            
            ; 'Navigation' popup menu items
          Case #WMN_mnuNavTop
            WMN_mnuNavTop_Click()
          Case #WMN_mnuNavBack
            WMN_mnuNavBack_Click()
          Case #WMN_mnuNavNext
            WMN_mnuNavNext_Click()
          Case #WMN_mnuNavEnd
            WMN_mnuNavEnd_Click()
          Case #WMN_mnuNavFind
            WFI_Form_Show(#True, #WMN)
          Case #WMN_mnuResetStepHKs
            WMN_mnuResetStepHKs_Click()
          Case #WMN_mnuCloseAndReOpenDMXDevs
            WMN_CloseAndReOpenDMXDevs_Click()
            
            ; 'File' menu items
          Case #WMN_mnuFileLoad
            WMN_processFileLoad()
          Case #WMN_mnuFileTemplates
            WMN_processFileTemplates()
          Case #WMN_mnuFavFiles
            WMN_mnuFavFiles_Click()
          Case #WMN_mnuFilePrint
            WPR_Form_Show(#WMN, #True)
          Case #WMN_mnuOptions
            WMN_mnuOptions_Click()
          Case #WMN_mnuFileExit
            WMN_mnuFileExit_Click()
            
            ; 'Recent File' popup menu items
          Case #WMN_mnuRecentFile_0 To #WMN_mnuRecentFile_9
            WMN_mnuRecentFile_Click(gnEventMenu - #WMN_mnuRecentFile_0) ; argument is index in the range 0-9
            
            ; 'Save' popup menu items
          Case #WMN_mnuSave
            WMN_mnuSave_Click()
          Case #WMN_mnuSaveAs
            WMN_mnuSaveAs_Click()
          Case #WMN_mnuSaveReason
            WMN_mnuSaveReason_Click()
            
            ; 'Editing' menu items
          Case #WMN_mnuEditor
            WMN_callEditor()
            WED_refreshTBSButtons()   ; see comment at start of WED_refreshTBSButton(nButtonType)
            WED_refreshMiscButtons()  ; see comment at start of WED_refreshTBSButton(nButtonType)
            
          Case #WMN_mnuVST
            If grWVP\bWindowActive
              SAW(#WVP)
            Else
              WVP_Form_Show()
            EndIf
            
            ; 'Device Map' popup menu items
          Case #WMN_mnuDevMapItem_0 To #WMN_mnuDevMapItem_9
            WMN_mnuDevMapItem_Click()
          Case #WMN_mnuDevMapEdit
            WMN_callEditor()
            WED_refreshTBSButtons()   ; see comment at start of WED_refreshTBSButton(nButtonType)
            WED_refreshMiscButtons()  ; see comment at start of WED_refreshTBSButton(nButtonType)
            
            ; 'Save Settings' popup menu items
          Case #WMN_mnuMastFaderReset
            resetMasterFader()
          Case #WMN_mnuMastFaderSave
            WMN_mnuMastVolSave_Click()
          Case #WMN_mnuSaveSettingsCue_00 To #WMN_mnuSaveSettingsCue_19
            WMN_mnuSaveSettingsCue_Click(gnEventMenu - #WMN_mnuSaveSettingsCue_00)  ; argument is index in the range 0-19
          Case #WMN_mnuSaveSettingsAllCues
            WMN_mnuSaveSettingsAllCues_Click()
          Case #WMN_mnuDMXMastFaderReset
            DMX_resetDMXMasterFader()
          Case #WMN_mnuDMXMastFaderSave
            WMN_mnuDMXMastFaderSave_Click()
            
            ; 'View' menu items
          Case #WMN_mnuViewOperModeDesign, #WMN_mnuViewOperModeRehearsal, #WMN_mnuViewOperModePerformance
            WMN_mnuViewOperMode_Click(gnEventMenu)
          Case #WMN_mnuViewClock
            startTimeOfDayClock()
          Case #WMN_mnuViewCountdown
            startCountdownClock()
          Case #WMN_mnuViewClearCountdownClock
            clearCountdownClock()
          ; 'View / Meters' menu items
          Case #WMN_mnuMtrsPeakAuto, #WMN_mnuMtrsPeakHold, #WMN_mnuMtrsPeakOff
            WMN_mnuMtrsPeakVarious_Click(gnEventMenu)
          Case #WMN_mnuMtrsPeakReset
            WMN_mnuMtrsPeakReset_Click()
          Case #WMN_mnuMtrsVULevels, #WMN_mnuMtrsVUNone
            WMN_mnuMtrsVUVarious_Click(gnEventMenu)
          Case #WMN_mnuVUNarrow, #WMN_mnuVUMedium, #WMN_mnuVUWide
            WMN_mnuVUWidth(gnEventMenu)
          Case #WMN_mnuMtrsDMXDisplay
            WMN_mnuMtrsDMXDisplay_Click()
            
            ; 'Help' menu items
          Case #WMN_mnuHelpContents
            WMN_mnuHelpTopics_Click()
          Case #WMN_mnuHelpClearDTMAInds
            WMN_mnuHelpClearDTMAInds_Click()
          Case #WMN_mnuHelpRegistration
            WMN_mnuHelpRegistration_Click()
          Case #WMN_mnuHelpAbout
            WMN_mnuHelpAbout_Click()
          Case #WMN_mnuHelpCheckForUpdate
            WMN_mnuHelpCheckForUpdate_Click()
          Case #WMN_mnuHelpForums
            OpenURL(#SCS_ONLINE_FORUMS)
          Case #WMN_mnuCurrInfo
            WCI_DisplayCurrInfo()
          Case #WMN_mnuTracing
            WMN_mnuTracing_Click()
            
          Case #WMN_mnuHB_00 To #WMN_mnuHB_12
            WMN_mnuHBSelect_Click(gnEventMenu - #WMN_mnuHB_00)
            
            ; timefield shortcuts
          Case #SCS_ALLF_BumpLeft
            debugMsg(sProcName, "Bump Left")
          Case #SCS_ALLF_BumpRight
            debugMsg(sProcName, "Bump Right")
            
          Case #PNL_mnu_switch_cue, #PNL_mnu_switch_file, #PNL_mnu_switch_sub
            PNL_EventHandler(grMain\nSwitchMenuHostPanel)
            ProcedureReturn

            ; unhandled menu items
          Default
            debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
            
        EndSelect
        
      Case #WM_RBUTTONDOWN, #WM_NCRBUTTONDOWN
        ; see note at start of WMN_windowCallback()
        debugMsg(sProcName, decodeEvent(gnWindowEvent) + ", GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
        If WMN_processRightClick()
          ProcedureReturn
        EndIf
        
      Case #PB_Event_Gadget
        If gnEventSliderNo > 0
          If gnEventSliderNo = \sldMasterFader
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WMN_sldMasterFader_Common()
                ProcedureReturn
              Default
                ; ignore other slider events
                ProcedureReturn
            EndSelect
            
          ElseIf gnEventCuePanelNo >= 0
            PNL_SliderEventHandler(gnEventCuePanelNo)
            ProcedureReturn
            
          EndIf
        EndIf
        
        ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventGadgetNo=G" + GadgetNoAndName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", gnEventCuePanelNo=" + Str(gnEventCuePanelNo))
        If gnEventCuePanelNo >= 0
          ; debugMsg(sProcName, "gnEventCuePanelNo=" + gnEventCuePanelNo + ", gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
          PNL_EventHandler(gnEventCuePanelNo)
          
        ElseIf gnEventButtonId <> 0
          ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventType=" + decodeEventType(gnEventType))
          Select gnEventType
            Case #PB_EventType_LeftClick
              WMN_tbMain_ButtonClick(gnEventButtonId)
            Case #PB_EventType_MouseEnter, #PB_EventType_MouseLeave
              ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventGadgetNo=G" + GadgetNoAndName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
              setToolBarBtnMouseOver(gnEventButtonId, gnEventType)   ; draw or remove focus rectangle
          EndSelect
          
        Else
          Select gnEventGadgetNoForEvHdlr
              
            Case \btnCloseTemplate
              WMN_btnCloseTemplate_Click()
              
            Case \btnShowFaders
              WMN_btnShowFaders_Click()
              
            Case \cntCtrlPanel, \cntGoAndMaster, \cntGoInfo, \cntMasterFaders, \cntNorth, \cntSouth, \cntToolbarAndVU, \cntTemplate
              ; ignore events
              
            Case \cvsMemoTitleBar
              Select gnEventType
                Case #PB_EventType_LeftClick
                  WMN_cvsMemoTitleBar_LeftClick()
                Case #PB_EventType_MouseMove
                  WMN_cvsMemoTitleBar_MouseMove()
                Case #PB_EventType_MouseLeave
                  WMN_cvsMemoTitleBar_MouseLeave()
              EndSelect
              
            Case \cvsStatusBar
              ; debugMsg0(sProcName, "status bar gnEventType=" + decodeEventType(\cvsStatusBar))
              Select gnEventType
                Case #PB_EventType_MouseEnter
                  ; debugMsg0(sProcName, "status bar gnEventType=" + decodeEventType(\cvsStatusBar) + ", GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
                Case #PB_EventType_LeftClick
                  debugMsg(sProcName, "status bar left-click")
                  checkMainHasFocus(3)
                  ProcedureReturn
              EndSelect
              
            Case \cvsVUDisplay
              Select gnEventType
                Case #PB_EventType_MouseMove
                  WMN_cvsVUDisplay_MouseMove()
              EndSelect
              
            Case \cvsVULabels
              ; no action
              
            Case \grdCues
              Select gnEventType
                Case #PB_EventType_LeftClick
                  WMN_grdCues_Click()
                  checkMainHasFocus(4)
                Case #PB_EventType_LeftDoubleClick
                  WMN_grdCues_DblClick()
                Case #PB_EventType_RightClick   ; need to check right-click here or else user often has to right-click twice (reported by Dee)
                  ; obsolete(?) as at 20/03/2014 following changes explained in WMN_windowCallback()
                  CompilerIf 1=2
                    Debug "Right-Click on grdCues"
                    debugMsg(sProcName, "Right-Click on grdCues")
                    MouseDown(2)
                    checkMainHasFocus(5)
                    ProcedureReturn
                  CompilerEndIf
              EndSelect
              
            Case \splCueListMemo
              If getVisible(\splCueListMemo)
                gnSplitterMoving = \splCueListMemo
              EndIf
                
            Case \splMainMemo
              If getVisible(\splMainMemo)
                gnSplitterMoving = \splMainMemo
              EndIf
              
            Case \splNorthSouth
              gnSplitterMoving = \splNorthSouth
              
            Case \splPanelsHotkeys
              If grWMN\bHotkeysCurrentlyDisplayed
                gnSplitterMoving = \splPanelsHotkeys
              Else
                ; no action necessary as WMN_displayOrHideHotkeys() will have set #PB_Splitter_FirstMinimumSize to GadgetWidth(WMN\scaCuePanels);
                ; to prevent the user dragging \splPanelsHotkeys splitter bar (desirable since there are no hotkeys displayed)
              EndIf
              
            Case \treHotkeys
              Select gnEventType
                Case #PB_EventType_RightClick
                  ; obsolete(?) as at 20/03/2014 following changes explained in WMN_windowCallback(), and the addition of WMN_callback_hotkeys()
                  CompilerIf 1=2
                    debugMsg(sProcName, "Right-Click on treHotkeys")
                    MouseDown(2)
                    checkMainHasFocus(6)
                    ProcedureReturn
                  CompilerEndIf
                Case #PB_EventType_LeftClick
                  ; debugMsg0(sProcName, "Hotkey LEFT CLICK " + GetGadgetState(\treHotkeys) + ", " + GetGadgetText(\treHotkeys))
                  If grProd\bAllowHKeyClick
                    WMN_processHotkeyClick(GetGadgetState(\treHotkeys), GetGadgetText(\treHotkeys))
                  Else
                    SGS(\treHotkeys, -1) ; clears the standard color for a selected item as selection is irrelevant if grProd\bAllowHKeyClick = #False
                  EndIf
              EndSelect
              
            Default
              If gnEventGadgetType = #SCS_GTYPE_TOOLBAR_CAT
                ; do nothing
              Else
                ; debugMsg0(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventSliderNo=" + gnEventSliderNo)
                If gnEventType = #PB_EventType_LeftClick
                  checkMainHasFocus(7)
                EndIf
              EndIf
              
          EndSelect
        EndIf
        
      Case #PB_Event_Timer
        nWindowTimer = EventTimer()
        Select nWindowTimer
          Case #SCS_TIMER_DEMO
            WMN_tmrDemo_Timer()
          Default
            If nWindowTimer > #SCS_TIMER_LAST And nWindowTimer < gnNextAnimatedTimer
              WMN_processAnimatedImageTimer(nWindowTimer)
            EndIf
        EndSelect
        
      Case #PB_Event_SizeWindow
        If (WindowWidth(#WMN) <> grWMN\nCurrWindowWidth) Or (WindowHeight(#WMN) <> grWMN\nCurrWindowHeight)
          ; defer processing for 0.5 second, discarding any earlier requests in the queue, so that gadget resizing etc is only done on completion of a border drag
          samAddRequest(#SCS_SAM_WMN_RESIZED, 0, 0, 0, "", ElapsedMilliseconds()+500)
        EndIf
        
      Case #PB_Event_MaximizeWindow
        ; debugMsg(sProcName, "#PB_Event_MaximizeWindow")
        ; debugMsg(sProcName, "calling checkMonitorInfo()")
        checkMonitorInfo()
  
      Case #PB_Event_CloseWindow
        debugMsg(sProcName, "#PB_Event_CloseWindow")
        debugMsg(sProcName, "calling WMN_Form_Unload()")
        WMN_Form_Unload()
        ; debugMsg(sProcName, "returned from WMN_Form_Unload()")
        ProcedureReturn
        
      Case #PB_Event_ActivateWindow
        ; debugMsg(sProcName, "#PB_Event_ActivateWindow")
        ; debugMsg(sProcName, "GadgetY(WMN\splNorthSouth)=" + GadgetY(WMN\splNorthSouth) + ", GadgetY(WMN\cntNorth)=" + GadgetY(WMN\cntNorth) + ", GadgetY(WMN\grdCues)=" + GadgetY(WMN\grdCues))
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WMN_getCuePtrForRowNo(nRowNo)
  Protected i, nCuePtr
  
  If nRowNo = gnRowEnd
    nCuePtr = gnCueEnd
  Else
    nCuePtr = -1
    For i = 1 To gnLastCue
      If aCue(i)\nGrdCuesRowNo = nRowNo
        nCuePtr = i
        Break
      EndIf
    Next i
  EndIf
  ProcedureReturn nCuePtr
EndProcedure

Procedure WMN_processShortcut(nShortcutFunction, bIgnoreAutoRepeatTest=#False)
  PROCNAMEC()
  Protected nIndex
  Protected nShortcutVK.l, sShortcutStr.s
  Protected nCurrHotkeyPtr, nHotkeyNr
  Protected nFavFilePtr
  Protected bAutoRepeating
  Protected bExclCueOverride
  ; Protected nCuePtr, nCueState
  Protected qTimeNow.q, qTimeEnd.q
  Protected nShortCut
  Protected nShortcutNumPadVK.l
  Protected nKeyboardAutoRepeatTimeout
  Protected nReqdAutoRepeatTimeout, nTimeDiff, bResetMainVKTimeActioned
  Protected j, k
  
  If gbSystemLocked
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START + ", nShortcutFunction=" + nShortcutFunction + ", " + decodeMenuItem(nShortcutFunction) + ", bIgnoreAutoRepeatTest=" + strB(bIgnoreAutoRepeatTest))
  
  qTimeNow = ElapsedMilliseconds()
  nIndex = getIndexForMainShortcutFunction(nShortcutFunction)
  If nIndex >= 0
    nShortcutVK = gaShortcutsMain(nIndex)\nShortcutVK
    sShortcutStr = gaShortcutsMain(nIndex)\sShortcutStr
    debugMsg(sProcName, "nShortcutVK=$" + Hex(nShortcutVK) + ", sShortcutStr=" + sShortcutStr)
  Else
    nShortCut = getPBShortcutForMainShortcutFunction(nShortcutFunction)
    If nShortCut >= 0
      nShortcutVK = getShortcutVK(nShortcut, @nShortcutNumPadVK)
    Else
      Select nShortcutFunction
        Case #SCS_WMNF_HB_01 To #SCS_WMNF_HB_12 ; check for hotkey bank shortcut
          nShortcutVK = gaShortcutsMain(#SCS_ShortMain_HotkeyBank1)\nShortcutVK + (nShortcutFunction - #SCS_WMNF_HB_01)
      EndSelect
    EndIf
    ; debugMsg(sProcName, "nShortCut=" + nShortCut + ", nShortcutVK=$" + Hex(nShortcutVK))
  EndIf
  
  If gqMainVKTimeDown(nShortcutVK) <> 0
    nKeyboardAutoRepeatTimeout = 750 ; 1000
    If (qTimeNow - gqMainVKTimeDown(nShortcutVK)) > nKeyboardAutoRepeatTimeout
      ; last 'keydown' event for this key was more than <nKeyboardAutoRepeatTimeout> milliseconds ago so presumably we didn't get the 'keyup' event
      If gqMainVKTimeDown(nShortcutVK) <> 0
        debugMsg(sProcName, "setting gqMainVKTimeDown(" + nShortcutVK + ")=0, was " + gqMainVKTimeDown(nShortcutVK))
        gqMainVKTimeDown(nShortcutVK) = 0
      EndIf
      debugMsg(sProcName, "calling getCurrHotkeyPtrForVK(" + nShortcutVK + ")")
      nCurrHotkeyPtr = getCurrHotkeyPtrForVK(nShortcutVK)
      If nCurrHotkeyPtr >= 0
        With gaCurrHotkeys(nCurrHotkeyPtr)
          If \nHKShortcutVK <> nShortcutVK
            If gqMainVKTimeDown(\nHKShortcutVK) <> 0
              debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutVK))
              gqMainVKTimeDown(\nHKShortcutVK) = 0
            EndIf
          EndIf
          If (\nHKShortcutNumPadVK <> nShortcutVK) And (\nHKShortcutNumPadVK <> 0)
            If gqMainVKTimeDown(\nHKShortcutNumPadVK) <> 0
              debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutNumPadVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutNumPadVK))
              gqMainVKTimeDown(\nHKShortcutNumPadVK) = 0
            EndIf
          EndIf
        EndWith
      EndIf
    ElseIf bIgnoreAutoRepeatTest = #False
      bAutoRepeating = #True  ; note: auto-repeating OK for fader up and down, and for 'note' hotkeys, but not for other key mappings
      ; debugMsg(sProcName, "bAutoRepeating="+ strB(bAutoRepeating))
    EndIf
  EndIf
  
  If (gqMainVKTimeDown(nShortcutVK) <> 0) And (bIgnoreAutoRepeatTest = #False)
    bAutoRepeating = #True  ; note: auto-repeating OK for fader up and down, and for 'note' hotkeys, but not for other key mappings
    ; debugMsg(sProcName, "bAutoRepeating="+ strB(bAutoRepeating))
  EndIf
  ; debugMsg(sProcName, "nShortcutFunction=" + nShortcutFunction + ", nShortcutVK=$" + Hex(nShortcutVK) +
  ;                     ", gqMainVKTimeDown(" + nShortcutVK + ")=" + gqMainVKTimeDown(nShortcutVK) + ", qTimeNow=" + qTimeNow +
  ;                     ", diff=" + Str(qTimeNow - gqMainVKTimeDown(nShortcutVK)) +
  ;                     ", bAutoRepeating=" + strB(bAutoRepeating))
  gqMainVKTimeDown(nShortcutVK) = qTimeNow

  ; Added 17Apr2022 11.9.1bb
  If nShortcutFunction = #SCS_WMNF_CueListUpOnePage Or nShortcutFunction = #SCS_WMNF_CueListDownOnePage
    nCurrHotkeyPtr = getCurrHotkeyPtrForVK(nShortcutVK)
    ; debugMsg0(sProcName, "nCurrHotkeyPtr=" + nCurrHotkeyPtr)
    If nCurrHotkeyPtr >= 0
      ; debugMsg0(sProcName, "gaCurrHotkeys(" + nCurrHotkeyPtr + ")\nCuePtr=" + getCueLabel(gaCurrHotkeys(nCurrHotkeyPtr)\nCuePtr))
      If gaCurrHotkeys(nCurrHotkeyPtr)\nCuePtr >= 0
        If nShortcutFunction = #SCS_WMNF_CueListUpOnePage
          nShortcutFunction = #SCS_WMNF_HK_PGUP
        Else
          nShortcutFunction = #SCS_WMNF_HK_PGDN
        EndIf
      EndIf
    EndIf
    ; debugMsg0(sProcName, "nShortcutFunction=" + nShortcutFunction)
  EndIf
  ; End added 17Apr2022 11.9.1bb
  
  Select nShortcutFunction
    Case #SCS_WMNF_StopAll, #SCS_WMNF_FadeAll
      If bAutoRepeating = #False
        If nShortcutFunction = #SCS_WMNF_FadeAll
          processFadeAll()
        Else
          processStopAll()
        EndIf
      Else
        debugMsg(sProcName, "bAutoRepeating=" + strB(bAutoRepeating))
      EndIf
      
    Case #SCS_WMNF_PauseResumeAll
      If bAutoRepeating = #False
        processPauseResumeAll()
      Else
        debugMsg(sProcName, "bAutoRepeating=" + strB(bAutoRepeating))
      EndIf
      
    Case #SCS_WMNF_Go, #SCS_WMNF_ExclCueOverride
      If bAutoRepeating = #False
        If nShortcutFunction = #SCS_WMNF_ExclCueOverride
          bExclCueOverride = #True
        EndIf
        ; debugMsg(sProcName, "calling WMN_processGo(#True, " + strB(bExclCueOverride) + ")")
        WMN_processGo(#True, bExclCueOverride)
      Else
        debugMsg(sProcName, "bAutoRepeating=" + strB(bAutoRepeating))
      EndIf
      
    Case #SCS_WMNF_GoConfirm
      If bAutoRepeating = #False
        confirmGo(#SCS_GOCONFIRM_KEYBOARD)
      EndIf
      
    Case #SCS_WMNF_HK_A To #SCS_WMNF_HK_PGDN
      If bAutoRepeating = #False
        nHotkeyNr = nShortcutFunction - #SCS_WMNF_HK_A + 1
        ; debugMsg(sProcName, "calling WMN_processHotkey(" + nHotkeyNr + ")")
        WMN_processHotkey(nHotkeyNr)
      Else
        debugMsg(sProcName, "bAutoRepeating=" + strB(bAutoRepeating))
      EndIf
      
    Case #SCS_WMNF_HB_00 To #SCS_WMNF_HB_12
      If bAutoRepeating = #False
        samAddRequest(#SCS_SAM_SET_HOTKEY_BANK, (nShortcutFunction - #SCS_WMNF_HB_00))
      Else
        debugMsg(sProcName, "bAutoRepeating=" + strB(bAutoRepeating))
      EndIf
      
    Case #SCS_WMNF_CueListUpOneRow, #SCS_WMNF_CueListDownOneRow, #SCS_WMNF_CueListUpOnePage, #SCS_WMNF_CueListDownOnePage, #SCS_WMNF_CueListTop, #SCS_WMNF_CueListEnd
      ; cue list navigation
      If bAutoRepeating = #False
        WMN_reposCueList(nShortcutFunction)
      Else
        debugMsg(sProcName, "bAutoRepeating=" + strB(bAutoRepeating))
      EndIf
      
    Case #SCS_WMNF_FindCue
      debugMsg(sProcName, "calling WFI_Form_Show(#True, #WMN)")
      WFI_Form_Show(#True, #WMN)
      
    Case #SCS_WMNF_MastFdrUp
      ; debugMsg(sProcName, "#SCS_WMNF_MastFdrUp, grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\bShowMasterFader=" + strB(grOperModeOptions(gnOperMode)\bShowMasterFader))
      ; Master Fader notes:
      ; 1. Master Fader key presses ignored if Master Fader is not displayed
      ; 2. Master Fader adjustments do not access the cue list so we do not need to try to lock the gnCueListMutex
      ; 3. Autorepeating OK for Master Fader Up and Master Fader Down
      If grOperModeOptions(gnOperMode)\bShowMasterFader
        adjustMasterFader(1)
        gqLastChangeTime = gqTimeNow
      EndIf
      
    Case #SCS_WMNF_MastFdrDown
      ; debugMsg(sProcName, "#SCS_WMNF_MastFdrDown, grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\bShowMasterFader=" + strB(grOperModeOptions(gnOperMode)\bShowMasterFader))
      If grOperModeOptions(gnOperMode)\bShowMasterFader
        adjustMasterFader(-1)
        gqLastChangeTime = gqTimeNow
      EndIf
      
    Case #SCS_WMNF_MastFdrReset
      If grOperModeOptions(gnOperMode)\bShowMasterFader
        If bAutoRepeating = #False
          ; debugMsg(sProcName, "SCS_WMNF_MastFdrReset")
          resetMasterFader()
          gqLastChangeTime = gqTimeNow
        EndIf
      EndIf
      
    Case #SCS_WMNF_MastFdrMute
      If grOperModeOptions(gnOperMode)\bShowMasterFader
        If bAutoRepeating = #False
          ; debugMsg(sProcName, "SCS_WMNF_MastFdrMute")
          muteMasterFader()
          gqLastChangeTime = gqTimeNow
        EndIf
      EndIf
      
    Case #SCS_WMNF_IncPlayingCues
      debugMsg(sProcName, "calling adjustLevelOfPlayingCues(1)")
      adjustLevelOfPlayingCues(1)
      
    Case #SCS_WMNF_DecPlayingCues
      debugMsg(sProcName, "calling adjustLevelOfPlayingCues(-1)")
      adjustLevelOfPlayingCues(-1)
      
    Case #SCS_WMNF_IncLastPlayingCue
      debugMsg(sProcName, "calling adjustLevelOfPlayingCues(1, #True)")
      adjustLevelOfPlayingCues(1, #True)
      
    Case #SCS_WMNF_DecLastPlayingCue
      debugMsg(sProcName, "calling adjustLevelOfPlayingCues(-1, #True)")
      adjustLevelOfPlayingCues(-1, #True)
      
    Case #SCS_WMNF_SaveCueSettings
      debugMsg(sProcName, "calling WMN_doSaveSettings(-1)")
      WMN_doSaveSettings(-1)
      
    Case #SCS_WMNF_TapDelay
      DMX_processTapDelayShortcutOrCommand()
      
    Case #SCS_WMNF_DMXMastFdrUp
      If grLicInfo\bDMXSendAvailable
        With grDMXMasterFader
          If \nDMXMasterFaderValue < 100
            \nDMXMasterFaderValue + 1
            DMX_setDMXMasterFader(\nDMXMasterFaderValue)
            If SLD_isSlider(WCN\sldDMXMasterFader)
              WCN_setFader(#SCS_CTRLTYPE_DMX_MASTER, 0, \nDMXMasterFaderValue, #True)
            EndIf
            gqLastChangeTime = gqTimeNow
          EndIf
        EndWith
      EndIf
      
    Case #SCS_WMNF_DMXMastFdrDown
      If grLicInfo\bDMXSendAvailable
        With grDMXMasterFader
          If \nDMXMasterFaderValue > 0
            \nDMXMasterFaderValue - 1
            DMX_setDMXMasterFader(\nDMXMasterFaderValue)
            If SLD_isSlider(WCN\sldDMXMasterFader)
              WCN_setFader(#SCS_CTRLTYPE_DMX_MASTER, 0, \nDMXMasterFaderValue, #True)
            EndIf
            gqLastChangeTime = gqTimeNow
          EndIf
        EndWith
      EndIf
      
    Case #SCS_WMNF_DMXMastFdrReset
      If grLicInfo\bDMXSendAvailable
        If bAutoRepeating = #False
          DMX_resetDMXMasterFader()
          If SLD_isSlider(WCN\sldDMXMasterFader)
            WCN_setFader(#SCS_CTRLTYPE_DMX_MASTER, 0, grDMXMasterFader\nDMXMasterFaderValue, #True)
          EndIf
          gqLastChangeTime = gqTimeNow
        EndIf
      EndIf
      
    Case #SCS_WMNF_FavFile1 To #SCS_WMNF_FavFile20
      If bAutoRepeating = #False
        nFavFilePtr = nShortcutFunction - #SCS_WMNF_FavFile1
        If gaFavoriteFiles(nFavFilePtr)\sFileName
          If FileExists(gaFavoriteFiles(nFavFilePtr)\sFileName)
            gsCueFile = gaFavoriteFiles(nFavFilePtr)\sFileName
            gsCueFolder = GetPathPart(gsCueFile)
            samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, 0)  ; p1: 1 = primary file.  p3: 0 = do NOT call editor after loading
          EndIf
        EndIf
      EndIf
      
    Case #SCS_WMNF_CueMarkerPrev, #SCS_WMNF_CueMarkerNext
      skipCueMarker(nShortcutFunction)
      
    Case #SCS_WMNF_MoveToTime
      If grLicInfo\bM2TAvailable
        M2T_processMoveToTimeShortcut()
      EndIf
      
    Case #SCS_WMNF_CallLinkDevs
      CompilerIf #c_cuepanel_multi_dev_select
        If grProd\nMaxAudioLogicalDev > 0
          ; at least two audio devices defined in production properties
          If gnCueToGo >= 0
            j = aCue(gnCueToGo)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeF And aSub(j)\bSubPlaceHolder = #False
                  WLD_Form_Show(j, 2, #WMN)
                  Break
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndIf
      CompilerEndIf

  EndSelect
  
  If bResetMainVKTimeActioned
    gqMainVKTimeActioned(nShortcutVK) = ElapsedMilliseconds()
  EndIf

  qTimeEnd = ElapsedMilliseconds()
  debugMsg(sProcName, #SCS_END + ", time in " + sProcName + ": " + Str(qTimeEnd - qTimeNow) + "ms")
  
EndProcedure

Procedure WMN_removeKeyboardShortcuts(nWindowNo=#WMN, bDoNotRemoveCtrlShortCuts=#False, bTrace=#False)
  PROCNAMEC()
  Protected n, n2, nPadShortcut
  Protected nMaxShortcut, sHotkey.s, nHKShortcut
  
  ; NOTE: Do NOT use RemoveKeyboardShortcut(nWindowNo, #PB_ShortCut_All) because that seems to disable using Tab to go to the next field
  
  debugMsgC(sProcName, "gnMaxCurrHotkey=" + gnMaxCurrHotkey + ", ArraySize(gaShortcutsMain())=" + ArraySize(gaShortcutsMain()) + ", ArraySize(gaCurrHotkeys())=" + ArraySize(gaCurrHotkeys()))
  For n = 0 To ArraySize(gaShortcutsMain()) ; Changed 15Nov2022 11.9.7af
    With gaShortcutsMain(n)
      If \nCurrShortcut
        If bDoNotRemoveCtrlShortCuts And (\nCurrShortcut & #PB_Shortcut_Control)
          Continue
        Else
          RemoveKeyboardShortcut(nWindowNo, \nCurrShortcut)
          debugMsgC(sProcName, "RemoveKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nCurrShortcut) + ")")
          If n = #SCS_ShortMain_HotkeyBank1
            If grLicInfo\nMaxHotkeyBank > 0
              For n2 = 1 To grLicInfo\nMaxHotkeyBank
                RemoveKeyboardShortcut(nWindowNo, \nShortcut+n2)
                debugMsgC(sProcName, "RemoveKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut+n2) + ")")
              Next n2
            EndIf
          EndIf
          \nCurrShortcut = 0
        EndIf
      EndIf
    EndWith
  Next n
  
  ; Added 29Feb2024 11.10.2az following test of M2T where it was not possible to enter a time because the numerics (eg 6) were still assigned as hotkeys
  nMaxShortcut = CountString(gsValidHotkeys, ",")
  For n = 0 To nMaxShortcut
    sHotkey = StringField(gsValidHotkeys, n+1, ",")
    nHKShortcut = getShortcutForKey(sHotkey)
    RemoveKeyboardShortcut(nWindowNo, nHKShortcut)
    debugMsgC(sProcName, "RemoveKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(nHKShortcut))
    ; for numeric shortcuts (0-9) add the numeric pad equivalent, mapped to the same SCS shortcut constants
    nPadShortcut = -1
    Select nHKShortcut
      Case #PB_Shortcut_0
        nPadShortcut = #PB_Shortcut_Pad0
      Case #PB_Shortcut_1
        nPadShortcut = #PB_Shortcut_Pad1
      Case #PB_Shortcut_2
        nPadShortcut = #PB_Shortcut_Pad2
      Case #PB_Shortcut_3
        nPadShortcut = #PB_Shortcut_Pad3
      Case #PB_Shortcut_4
        nPadShortcut = #PB_Shortcut_Pad4
      Case #PB_Shortcut_5
        nPadShortcut = #PB_Shortcut_Pad5
      Case #PB_Shortcut_6
        nPadShortcut = #PB_Shortcut_Pad6
      Case #PB_Shortcut_7
        nPadShortcut = #PB_Shortcut_Pad7
      Case #PB_Shortcut_8
        nPadShortcut = #PB_Shortcut_Pad8
      Case #PB_Shortcut_9
        nPadShortcut = #PB_Shortcut_Pad9
    EndSelect
    If nPadShortcut >= 0
      RemoveKeyboardShortcut(nWindowNo, nPadShortcut)
      debugMsgC(sProcName, "RemoveKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(nPadShortcut) + ")")
    EndIf
  Next n
  ; End added 29Feb2024 11.10.2az
  
  For n = 0 To gnMaxCurrHotkey
    With gaCurrHotkeys(n)
      RemoveKeyboardShortcut(nWindowNo, \nHKShortcut)
      debugMsgC(sProcName, "RemoveKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nHKShortcut) + ")")
      ; added 4Oct2019 11.8.2ar to allow keys such as shift/A to be treated the same as A
      If n < 26 ; ie keys A-Z
        RemoveKeyboardShortcut(nWindowNo, \nHKShortcut | #PB_Shortcut_Shift)
      EndIf
      ; end added 4Oct2019 11.8.2ar
    EndWith
  Next n

EndProcedure

Procedure WMN_setKeyboardShortcuts(nWindowNo=#WMN, bTrace=#False)
  PROCNAMEC()
  Protected n, n2, nPadShortcut, nMaxShortcut, sHotkey.s, nHKShortcut
  Protected sParam.s
  
  debugMsgC(sProcName, #SCS_START)
  
  ; start by removing all shortcuts
  WMN_removeKeyboardShortcuts(nWindowNo, #False, bTrace)

  ; debugMsgC(sProcName, "calling populateExclCueOverrideShortcut()")
  populateExclCueOverrideShortcut()
  
  nMaxShortcut = CountString(gsValidHotkeys, ",")
  For n = 0 To nMaxShortcut
    sHotkey = StringField(gsValidHotkeys, n+1, ",")
    nHKShortcut = getShortcutForKey(sHotkey)
    AddKeyboardShortcut(nWindowNo, nHKShortcut, #SCS_WMNF_HK_A + n)
    debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(nHKShortcut) + ", " + decodeMenuItem(#SCS_WMNF_HK_A + n) + ")")
    ; added 4Oct2019 11.8.2ar to allow keys such as shift/A to be treated the same as A
    If n < 26 ; ie keys A-Z
      AddKeyboardShortcut(nWindowNo, nHKShortcut | #PB_Shortcut_Shift, #SCS_WMNF_HK_A + n)
      debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(nHKShortcut | #PB_Shortcut_Shift) + ", " + decodeMenuItem(#SCS_WMNF_HK_A + n) + ")")
    EndIf
    ; end added 4Oct2019 11.8.2ar
    ; for numeric shortcuts (0-9) add the numeric pad equivalent, mapped to the same SCS shortcut constants
    nPadShortcut = -1
    Select nHKShortcut
      Case #PB_Shortcut_0
        nPadShortcut = #PB_Shortcut_Pad0
      Case #PB_Shortcut_1
        nPadShortcut = #PB_Shortcut_Pad1
      Case #PB_Shortcut_2
        nPadShortcut = #PB_Shortcut_Pad2
      Case #PB_Shortcut_3
        nPadShortcut = #PB_Shortcut_Pad3
      Case #PB_Shortcut_4
        nPadShortcut = #PB_Shortcut_Pad4
      Case #PB_Shortcut_5
        nPadShortcut = #PB_Shortcut_Pad5
      Case #PB_Shortcut_6
        nPadShortcut = #PB_Shortcut_Pad6
      Case #PB_Shortcut_7
        nPadShortcut = #PB_Shortcut_Pad7
      Case #PB_Shortcut_8
        nPadShortcut = #PB_Shortcut_Pad8
      Case #PB_Shortcut_9
        nPadShortcut = #PB_Shortcut_Pad9
    EndSelect
    If nPadShortcut >= 0
      AddKeyboardShortcut(nWindowNo, nPadShortcut, #SCS_WMNF_HK_A + n)
      debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(nPadShortcut) + ", " + decodeMenuItem(#SCS_WMNF_HK_A + n) + ")")
    EndIf
  Next n
  
  ; comment: must process the above BEFORE the following, so any re-assignment of a standard hotkey (eg Num Pad 0) will take the (later) assignment below
  
  For n = 0 To ArraySize(gaShortcutsMain())
    With gaShortcutsMain(n)
      CompilerIf #c_keycallback_processing
        If nWindowNo = #WMN And \nShortcutFunction = #SCS_WMNF_Go ; #c_beep_test = #False ; Test added 8Nov2021 11.8.6br
          gnGoShortcut = \nShortcut
          debugMsg(sProcName, "gnGoShortcut=" + gnGoShortcut + " (" + decodeShortcut(gnGoShortcut) + ")")
        ElseIf \nShortcut
          AddKeyboardShortcut(nWindowNo, \nShortcut, \nShortcutFunction)
          debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut) + ", " + decodeMenuItem(\nShortcutFunction) + ")")
          \nCurrShortcut = \nShortcut
          If n = #SCS_ShortMain_HotkeyBank1
            If grLicInfo\nMaxHotkeyBank > 0
              For n2 = 1 To grLicInfo\nMaxHotkeyBank
                AddKeyboardShortcut(nWindowNo, \nShortcut+n2, \nShortcutFunction+n2)
                debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut+n2) + ", " + decodeMenuItem(\nShortcutFunction+n2) + ")")
              Next n2
            EndIf
          EndIf
        EndIf
      CompilerElse
        If \nShortcut
          AddKeyboardShortcut(nWindowNo, \nShortcut, \nShortcutFunction)
          debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut) + ", " + decodeMenuItem(\nShortcutFunction) + ")")
          \nCurrShortcut = \nShortcut
          If n = #SCS_ShortMain_HotkeyBank1
            If grLicInfo\nMaxHotkeyBank > 0
              For n2 = 1 To grLicInfo\nMaxHotkeyBank
                AddKeyboardShortcut(nWindowNo, \nShortcut+n2, \nShortcutFunction+n2)
                debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut+n2) + ", " + decodeMenuItem(\nShortcutFunction+n2) + ")")
              Next n2
            EndIf
          EndIf
        EndIf
      CompilerEndIf
    EndWith
  Next n
  
  For n = 0 To ArraySize(gaFavoriteFiles())
    With gaFavoriteFiles(n)
      If \sFileName
        AddKeyboardShortcut(nWindowNo, \nShortcut, #SCS_WMNF_FavFile1 + n)
        debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut) + ", " + decodeMenuItem(#SCS_WMNF_FavFile1 + n) + ")")
      EndIf
    EndWith
  Next n
  
  If nWindowNo = #WMN
    ; refresh 'stop all' button caption
    sParam = decodeMainShortcutFunction(#SCS_WMNF_StopAll)
    setToolBarBtnCaption(#SCS_TBMB_STOP_ALL, LangPars("Menu", "mnuStopAll", sParam))
    
    ; added 21Mar2020 11.8.2.3ad
    ; refresh 'fade all' button caption
    sParam = decodeMainShortcutFunction(#SCS_WMNF_FadeAll)
    setToolBarBtnCaption(#SCS_TBMB_FADE_ALL, LangPars("Menu", "mnuFadeAll", sParam))
    ; end added 21Mar2020 11.8.2.3ad
    
    setSliderShortcuts(#WMN)
  EndIf
  
  ; debugMsgC(sProcName, "calling loadSFRActionDescrs()")
  loadSFRActionDescrs()
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_processGo(bMouseClick=#False, bExclCueOverride=#False)
  PROCNAMEC()
  Protected bGoEnabled
  Protected nExclusiveCuePtr
  Protected sMsg.s
  
  ; bGoEnabled = getToolBarBtnEnabled(#SCS_TBMB_GO)
  bGoEnabled = WMN_isGoEnabled()
  debugMsg(sProcName, "bGoEnabled=" + strB(bGoEnabled))
  If bGoEnabled
    debugMsg(sProcName, "calling goClicked(" + strB(bMouseClick) + ")")
    goClicked(bMouseClick)
    
  Else
    nExclusiveCuePtr = checkExclusiveCuePlaying()
    If nExclusiveCuePtr >= 0
      If (bExclCueOverride) And (gnCueToGo >= 0)
        goClicked(bMouseClick)
      Else
        If grGeneralOptions\bCtrlOverridesExclCue
          sMsg = LangPars("WMN", "ExclCueRun3", aCue(nExclusiveCuePtr)\sCue)   ; "'Go' button disabled because exclusive cue $1 is currently playing, but..."
        Else
          sMsg = LangPars("WMN", "ExclCueRun2", aCue(nExclusiveCuePtr)\sCue)   ; "'Go' button disabled because exclusive cue $1 is currently playing"
        EndIf
        WMN_setStatusField(sMsg, #SCS_STATUS_ERROR)
      EndIf
    EndIf
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_processGoWithExpectedCue(nExpectedCuePtr)
  PROCNAMEC()
  Protected sErrorMsg.s
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START + ", nExpectedCuePtr=" + getCueLabel(nExpectedCuePtr))
  
  If nExpectedCuePtr <> gnCueToGo
    sErrorMsg = "Processing Network 'GO(" + #DQUOTE$ + "0" + #DQUOTE$ + ")'" + Chr(10) +
    "Expecting to fire " + getCueLabel(nExpectedCuePtr) + " but 'cue to go' is currently " + getCueLabel(gnCueToGo) + Chr(10) +
    "OK to continue?"
    debugMsg(sProcName, sErrorMsg)
    nResponse = scsMessageRequester(#SCS_TITLE, sErrorMsg, #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
    If nResponse = #PB_MessageRequester_No
      debugMsg(sProcName, "response=no")
      gqMainThreadRequest = #SCS_MTH_CLOSE_DOWN ; use =, not |, so any existing main thread requests are wiped
      ProcedureReturn
    Else
      debugMsg(sProcName, "reponse=yes")
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling goIfOK()")
  goIfOK()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_processHotkey(nHotkeyNr, bExternallyTriggered=#False)
  PROCNAMEC()
  Protected nCurrHotkeyPtr, nHotkeyCuePtr, nCueState, n, bStepHotkey, sMsg.s
  Protected bCallPlayCue
  Protected nRowNo, sToggleState.s
  Protected nExclusiveCuePtr
  Protected bEnableInSoloMode
  Protected j, nKeyIndex
  Protected i2, j2
  
  debugMsg(sProcName, #SCS_START + ", nHotkeyNr=" + nHotkeyNr + ", bExternallyTriggered=" + strB(bExternallyTriggered))
  
  nCurrHotkeyPtr = -1
  ; debugMsg(sProcName, "gnMaxCurrHotkey=" + gnMaxCurrHotkey)
  For n = 0 To gnMaxCurrHotkey
    ; debugMsg(sProcName, "gaCurrHotkeys(" + n + ")\nHotkeyNr=" + gaCurrHotkeys(n)\nHotkeyNr + ", \sHotkey=" + gaCurrHotkeys(n)\sHotkey)
    If gaCurrHotkeys(n)\nHotkeyNr = nHotkeyNr
      If gaCurrHotkeys(n)\nActivationMethod = #SCS_ACMETH_HK_STEP
        bStepHotkey = #True
        If gaHotkeys(n)\nHotkeyStepNo = gnLastHotkeyStepProcessed(nHotkeyNr) + 1
          nCurrHotkeyPtr = n
          Break
        EndIf
      Else
        nCurrHotkeyPtr = n
        Break
      EndIf
    EndIf
  Next n
  ; debugMsg(sProcName, "nCurrHotkeyPtr=" + nCurrHotkeyPtr)
  
  If nCurrHotkeyPtr < 0
    If bStepHotkey
      sMsg = "Hotkey " + StringField(gsValidHotkeys, nHotkeyNr, ",") + " ignored as the last step number (" + gnLastHotkeyStepProcessed(nHotkeyNr) + ") has already been processed"
      WMN_setStatusField(sMsg, #SCS_STATUS_WARN)
      ; debugMsg(sProcName, "a 'step' hotkey but all steps already processed, so exiting now (gnLastHotkeyStepProcessed(" + nHotkeyNr + ")=" + gnLastHotkeyStepProcessed(nHotkeyNr) + ")")
    Else
      debugMsg(sProcName, "not a hotkey, so exiting now")
    EndIf
    ProcedureReturn
  EndIf
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_HOTKEY, nHotkeyNr, 0, bExternallyTriggered)
    ProcedureReturn
  EndIf
  
  gaCurrHotkeys(nCurrHotkeyPtr)\bExternallyTriggered = bExternallyTriggered
  nHotkeyCuePtr = gaCurrHotkeys(nCurrHotkeyPtr)\nCuePtr
  debugMsg(sProcName, "nHotkeyCuePtr=" + getCueLabel(nHotkeyCuePtr))
  
  If nHotkeyCuePtr > 0
    If grGeneralOptions\bHotkeysOverrideExclCue
      ; hotkeys allowed even if an exclusive cue is playing, so no need to check
    Else
      nExclusiveCuePtr = checkExclusiveCuePlaying()
      If nExclusiveCuePtr > 0
        debugMsg(sProcName, "nExclusiveCuePtr=" + getCueLabel(nExclusiveCuePtr))
        bEnableInSoloMode = #True
        If nExclusiveCuePtr <> nHotkeyCuePtr
          j = aCue(nHotkeyCuePtr)\nFirstSubIndex
          While (j >= 0) And (bEnableInSoloMode)
            If (aSub(j)\bSubTypeForP) Or (aSub(j)\bSubTypeA)
              bEnableInSoloMode = #False
            ElseIf aSub(j)\bSubTypeQ ; Added 10Oct2022 11.9.6
              i2 = aSub(j)\nCallCuePtr
              If i2 >= 0
                j2 = aCue(i2)\nFirstSubIndex
                While (j2 >= 0) And (bEnableInSoloMode)
                  If aSub(j2)\bSubTypeForP Or aSub(j2)\bSubTypeA
                    bEnableInSoloMode = #False
                  EndIf
                  j2 = aSub(j2)\nNextSubIndex
                Wend
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
        If bEnableInSoloMode = #False
          WMN_setStatusField(LangPars("Errors", "HKCannotPlay", gaCurrHotkeys(nCurrHotkeyPtr)\sHotkey + " (" + gaCurrHotkeys(nCurrHotkeyPtr)\sHotkeyLabel + ")", getCueLabel(nExclusiveCuePtr)), #SCS_STATUS_ERROR)
          ProcedureReturn
        EndIf
      EndIf
    EndIf
    
    nCueState = aCue(nHotkeyCuePtr)\nCueState
    debugMsg(sProcName, "nHotkeyCuePtr=" + nHotkeyCuePtr + "(" + getCueLabel(nHotkeyCuePtr) + "), sHotkey=" + gaCurrHotkeys(nCurrHotkeyPtr)\sHotkey)
    Select aCue(nHotkeyCuePtr)\nActivationMethodReqd
        
      Case #SCS_ACMETH_HK_TRIGGER
        playCue(nHotkeyCuePtr)
        ; Added 30Jun2023
        If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
          FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_GO, 0, 0, 0, aCue(nHotkeyCuePtr)\sHotkey)
        EndIf
        ; End added 30Jun2023
        
      Case #SCS_ACMETH_HK_TOGGLE
        ; hotkey (toggle) activation method, so fade out / stop cue IF cue is currently playing
        gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState ! 1   ; flip toggle state for this hotkey
        debugMsg(sProcName, "gaCurrHotkeys(" + nCurrHotkeyPtr + ")\nToggleState=" + gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState)
        bCallPlayCue = #True
        If gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState = 0
          ; even press (eg 2nd, 4th, 6th, etc)
          With aCue(nHotkeyCuePtr)
            If (\bSubTypeAorP) Or (\bSubTypeF) Or (\bSubTypeI) ; Commented out "Or (\bSubTypeK)" 13Jun2024 11.10.3al
              fadeOutCue(nHotkeyCuePtr, #False)
              bCallPlayCue = #False
            EndIf
          EndWith
          ; Added 30Jun2023
          If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
            ; nb the follow sends command #SCS_OSCINP_HKEY_ON, not #SCS_OSCINP_HKEY_OFF, because #SCS_OSCINP_HKEY_ON indicates the hotkey has been pressed again
            FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_ON, 0, 0, 0, aCue(nHotkeyCuePtr)\sHotkey)
          EndIf
          ; End added 30Jun2023
        EndIf
        If bCallPlayCue
          playCue(nHotkeyCuePtr, #False, gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState)
          ; Added 30Jun2023
          If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
            If gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState = 0 ; Added test 13Jun2024 11.10.3al
              FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_ON, 0, 0, 0, aCue(nHotkeyCuePtr)\sHotkey)
            Else
              FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_OFF, 0, 0, 0, aCue(nHotkeyCuePtr)\sHotkey) ; Added 13Jun2024 11.10.3al
            EndIf
          EndIf
          ; End added 30Jun2023
        EndIf
        nRowNo = gaCurrHotkeys(nCurrHotkeyPtr)\nHotkeyPanelRowNo
        If nRowNo >= 0
          If gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState = 0
            sToggleState = "(1)"
          Else
            sToggleState = "(0)"
          EndIf
          SetGadgetItemText(WMN\treHotkeys, nRowNo, gaCurrHotkeys(nCurrHotkeyPtr)\sHotkey + sToggleState + ": " + gaCurrHotkeys(nCurrHotkeyPtr)\sHotkeyLabel)
        EndIf
        
      Case #SCS_ACMETH_HK_NOTE
        If (nCueState < #SCS_CUE_FADING_IN) Or (nCueState > #SCS_CUE_FADING_OUT)
          playCue(nHotkeyCuePtr)
          ; Added 30Jun2023
          If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
            FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_ON, 0, 0, 0, aCue(nHotkeyCuePtr)\sHotkey)
          EndIf
          ; End added 30Jun2023
        Else
          ; Added 30Jun2023
          If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
            debugMsg(sProcName, "calling FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_OFF, 0, 0, 0, " + aCue(nHotkeyCuePtr)\sHotkey + ")")
            FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_OFF, 0, 0, 0, aCue(nHotkeyCuePtr)\sHotkey)
          EndIf
          ; End added 30Jun2023
        EndIf
        gnNoteHotkeyCuesPlaying = countNoteHotkeysPlaying()
        
      Case #SCS_ACMETH_HK_STEP
        playCue(nHotkeyCuePtr)
        gnLastHotkeyStepProcessed(nHotkeyNr) = aCue(nHotkeyCuePtr)\nCueHotkeyStepNo
        debugMsg(sProcName, "gnLastHotkeyStepProcessed(" + nHotkeyNr + ")=" + gnLastHotkeyStepProcessed(nHotkeyNr))
        
    EndSelect
    
    If grOperModeOptions(gnOperMode)\bShowHotkeyCuesInPanels
      If (aCue(nHotkeyCuePtr)\nHideCueOpt = #SCS_HIDE_NO) ; test added 19Jul2018 11.7.1.1ac (bug report from 'Cheetah' "Redraw of cue window stalling hotkey cues")
        debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
        gbCallLoadDispPanels = #True
        ; debugMsg(sProcName, "gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
        aCue(nHotkeyCuePtr)\nCuePanelUpdateFlags | #SCS_CUEPNL_TRANSPORT | #SCS_CUEPNL_PROGRESS
        ; debugMsg(sProcName, "aCue(" + getCueLabel(nHotkeyCuePtr) + ")\nCuePanelUpdateFlags=" + aCue(nHotkeyCuePtr)\nCuePanelUpdateFlags)
      EndIf
    EndIf
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_processHotkeyClick(nItem, sHotkeyText.s, bResetOnly=#False)
  PROCNAMEC()
  Protected sHotkey.s, n, nHotkeyNr
  Static sSelectedHotkey.s, nSelectedItem = -1
  Protected nBackColor.l = GetSysColor_(#COLOR_HIGHLIGHT)
  Protected nTextColor.l = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
  
  ; debugMsg(sProcName, #SCS_START + ", nItem=" + nItem + ", sHotkeyText=" + #DQUOTE$ + sHotkeyText + #DQUOTE$ + ", bResetOnly=" + strB(bResetOnly))
  
  If bResetOnly
    sSelectedHotkey = ""
    nSelectedItem = -1
    ProcedureReturn
  EndIf
  
  With WMN
    sHotkey = Trim(StringField(sHotkeyText, 1, ":"))
    sHotkey = StringField(sHotkey, 1, "(") ; for toggle hot keys - ignores the (0) or (1)
    ; debugMsg(sProcName, "sHotkey=" + sHotkey + ", gnMaxCurrHotkey=" + gnMaxCurrHotkey)
    nHotkeyNr = -1
    For n = 0 To gnMaxCurrHotkey
      ; debugMsg(sProcName, "gaCurrHotkeys(" + n + ")\sHotkey=" + gaCurrHotkeys(n)\sHotkey + ", \nActivationMethod=" + decodeActivationMethod(gaCurrHotkeys(n)\nActivationMethod))
      If gaCurrHotkeys(n)\sHotkey = sHotkey
        Select gaCurrHotkeys(n)\nActivationMethod
          Case #SCS_ACMETH_HK_TRIGGER, #SCS_ACMETH_HK_TOGGLE
            nHotkeyNr = gaCurrHotkeys(n)\nHotkeyNr
            Break
        EndSelect
      EndIf
    Next n
    debugMsg(sProcName, "sHotkey=" + sHotkey + ", nHotkeyNr=" + nHotkeyNr)
    SGS(\treHotkeys, -1) ; clears the standard color for a selected item as we are controlling the color in the code below
    If nHotkeyNr >= 0
      If nSelectedItem >= 0
        SetGadgetItemColor(\treHotkeys, nSelectedItem, #PB_Gadget_BackColor, #PB_Default, #PB_All)
        SetGadgetItemColor(\treHotkeys, nSelectedItem, #PB_Gadget_FrontColor, #PB_Default, #PB_All)
      EndIf        
      If sHotkey <> sSelectedHotkey And nItem <> nSelectedItem
        SetGadgetItemColor(\treHotkeys, nItem, #PB_Gadget_BackColor, nBackColor, #PB_All)
        SetGadgetItemColor(\treHotkeys, nItem, #PB_Gadget_FrontColor, nTextColor, #PB_All)
        sSelectedHotkey = sHotkey
        nSelectedItem = nItem
      Else
        ; second click on the hotkey, so play the hotkey
        debugMsg(sProcName, "calling WMN_processHotkey(" + nHotkeyNr + ")")
        WMN_processHotkey(nHotkeyNr)
        ; now reset the static variables to indicate nothing is currently selected
        sSelectedHotkey = ""
        nSelectedItem = -1
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_setWindowTitle()
  PROCNAMEC()
  Static sTimeProfile.s
  Static bStaticLoaded
  Protected sFileName.s, sCaption.s
  
  If bStaticLoaded = #False
    sTimeProfile = Lang("Common", "TimeProfile") + ": "
    bStaticLoaded = #True
  EndIf
  
  sCaption = "SCS " + #SCS_VERSION + " (" + #SCS_PROCESSOR + ") - "
  If grProd\bTemplate
    sCaption + #DQUOTE$ + Trim(grProd\sTmName) + #DQUOTE$
    sFileName = gsTemplateFile
  Else
    sCaption + #DQUOTE$ + Trim(grProd\sTitle) + #DQUOTE$
    sFileName = gsCueFile
    If Len(gsCueFile) > Len(gsMyDocsPath)
      If LCase(Left(gsCueFile, Len(gsMyDocsPath))) = LCase(gsMyDocsPath)
        sFileName = gsMyDocsLeafName + Mid(gsCueFile, Len(gsMyDocsPath) + 1)
      EndIf
    EndIf
  EndIf
  
  If sFileName
    sCaption + " - [" + sFileName + "]"
  EndIf
  If gsWhichTimeProfile
    sCaption + " (" + sTimeProfile + gsWhichTimeProfile + ")"
  EndIf
  
  If gbDataChanged Or gbUnsavedChanges
    sCaption + " *"
  EndIf
  
  Select grFMOptions\nFunctionalMode
    Case #SCS_FM_PRIMARY
      sCaption + "    [SCS PRIMARY]"
    Case #SCS_FM_BACKUP
      sCaption + "    [SCS BACKUP]"
  EndSelect
  
  If GetWindowTitle(#WMN) <> sCaption
    debugMsg(sProcName, "sCaption=" + sCaption)
    SetWindowTitle(#WMN, sCaption)
  EndIf
  
  If IsGadget(WSP\cvsSplash)
    WSP_setProdTitle(grProd\sTitle)
  EndIf
  
EndProcedure

Procedure WMN_applyDisplayOptions(bRescaleCuePanels=#False, bRedoColors=#False, bRedoToolbar=#False)
  PROCNAMEC()
  Protected nAvailableHeight
  Protected bCtrlPanelVisible, nCtrlPanelTop, nCtrlPanelHeight
  Protected bGoAndMasterVisible, nGoAndMasterTop, nGoAndMasterHeight
  Protected bToolbarAndVUVisible, nToolbarAndVUTop
  Protected nSplitterTop, nSplitterHeight, nNorthSouthSplitterPos
  Protected bMenuReqd
  Protected rOperModeOptions.tyOperModeOptions
  Protected bDisplayMenu
  Protected nMenuHeight
  Protected fYFactor.f, fXFactor.f, fYFactorCues.f
  Protected n, bColorSchemeChanged
  Protected nPanelHeight
  Protected nToolBarHeight
  Protected nOldGadgetList
  Protected bEnabled
  Protected nTop
  Protected nNorthHeight, nSouthHeight
  Protected bTrace
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  debugMsg(sProcName, #SCS_START + ", bRescaleCuePanels=" + strB(bRescaleCuePanels) + ", bRedoColors=" + strB(bRedoColors))
;   debugMsg(sProcName, "GadgetY(WMN\splNorthSouth)=" + GadgetY(WMN\splNorthSouth) + 
;                       ", GadgetY(WMN\cntNorth)=" + GadgetY(WMN\cntNorth) + ", GadgetHeight(WMN\cntNorth)=" + GadgetHeight(WMN\cntNorth) +
;                       ", GadgetY(WMN\grdCues)=" + GadgetY(WMN\grdCues) + ", GadgetHeight(WMN\grdCues)=" + GadgetHeight(WMN\grdCues) +
;                       ", GadgetY(WMN\cntSouth)=" + GadgetY(WMN\cntSouth) + ", GadgetHeight(WMN\cntSouth)=" + GadgetHeight(WMN\cntSouth) +
;                       ", GadgetY(WMN\scaCuePanels)=" + GadgetY(WMN\scaCuePanels) + ", GadgetHeight(WMN\scaCuePanels)=" + GadgetHeight(WMN\scaCuePanels))
;   debugMsg(sProcName, "GGS(WMN\splPanelsHotkeys)=" + GGS(WMN\splPanelsHotkeys))
  
  nToolBarHeight = 80
  
  If gbInOptionsWindow
    rOperModeOptions = mrOperModeOptions(grWOP\nCurrOperMode)
    debugMsgC(sProcName, "mrOperModeOptions(" + decodeOperMode(grWOP\nCurrOperMode) + ")\bShowTransportControls=" + strB(mrOperModeOptions(grWOP\nCurrOperMode)\bShowTransportControls))
  Else
    rOperModeOptions = grOperModeOptions(gnOperMode)
    debugMsgC(sProcName, "grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\bShowTransportControls=" + strB(grOperModeOptions(gnOperMode)\bShowTransportControls))
  EndIf
  
  If bRescaleCuePanels
    fYFactor = gfMainYFactor * rOperModeOptions\nCuePanelVerticalSizing / 100
    fXFactor = gfMainXFactor
    fYFactorCues = gfMainOrigYFactor * rOperModeOptions\nCuePanelVerticalSizing / 100
    debugMsgC(sProcName, "nCuePanelVerticalSizing=" + rOperModeOptions\nCuePanelVerticalSizing + ", gfMainYFactor=" + StrF(gfMainYFactor,4) + ", fYFactor=" + StrF(fYFactor,4) + ", fXFactor=" + StrF(fXFactor,4))
    If fYFactorCues <> grWMN\fYFactorForCuePanelFonts
      setUpCUEFonts(fYFactorCues)
    EndIf
  EndIf
  
  debugMsgC(sProcName, "calling WMN_resizeGoAndMaster()")
  WMN_resizeGoAndMaster()
  
  With rOperModeOptions
    
    ; change color scheme if necessary or requested
    If (\sSchemeName <> gsColorScheme) Or (bRedoColors)
      loadGlobalColorScheme(\sSchemeName)
      WMN_setFormColors()
      bColorSchemeChanged = #True
    EndIf
    
    If \nCtrlPanelPos <> #SCS_CTRLPANEL_NONE
      bCtrlPanelVisible = #True
      
      If \nMainToolBarInfo <> #SCS_TOOL_DISPLAY_NONE Or \nVisMode <> #SCS_VU_NONE
        bToolbarAndVUVisible = #True
        nCtrlPanelHeight + nToolBarHeight
      EndIf
      
      If \bShowNextManualCue Or \bShowMasterFader
        bGoAndMasterVisible = #True
        nGoAndMasterHeight = GadgetHeight(WMN\cntGoAndMaster)
        nCtrlPanelHeight + nGoAndMasterHeight
      EndIf
      
    EndIf
    
    debugMsgC(sProcName, "\nMainToolBarInfo=" + decodeMainToolBarInfo(\nMainToolBarInfo) + ", \nVisMode=" + decodeVisMode(\nVisMode))
    debugMsgC(sProcName, "bToolbarAndVUVisible=" + strB(bToolbarAndVUVisible) + ", bGoAndMasterVisible=" + strB(bGoAndMasterVisible))
    
    If nCtrlPanelHeight = 0
      bCtrlPanelVisible = #False
      bDisplayMenu = #True
    ElseIf \nMainToolBarInfo <> #SCS_TOOL_DISPLAY_ALL
      bDisplayMenu = #True
    EndIf
    
    If bCtrlPanelVisible
      If \nCtrlPanelPos = #SCS_CTRLPANEL_TOP
        nToolbarAndVUTop = 0
        If bGoAndMasterVisible And bToolbarAndVUVisible
          nGoAndMasterTop = nToolBarHeight
        EndIf
      Else  ; \nCtrlPanelPos = #SCS_CTRLPANEL_BOTTOM
        ; nGoAndMasterTop = 0
        nGoAndMasterTop = 1
        If bGoAndMasterVisible And bToolbarAndVUVisible
          nToolbarAndVUTop = nGoAndMasterHeight
        EndIf
      EndIf
    EndIf
    
    debugMsgC(sProcName, "nCtrlPanelHeight=" + nCtrlPanelHeight + ", bDisplayMenu=" + strB(bDisplayMenu))
    If bDisplayMenu
      ; show top-level menus
      debugMsgC(sProcName, "calling WMN_buildWindowMenu()")
      WMN_buildWindowMenu()
      nMenuHeight = glMenuHeight
    Else
      ; hide top-level menus
      If IsMenu(#WMN_mnuWindowMenu)
        FreeMenu(#WMN_mnuWindowMenu)
      EndIf
    EndIf
    
    ; Deleted 20Apr2022 11.9.1bc as UseGadgetList() crashing after (a) try to open a cue file but close when message about device not available, followed by (b) open another cue file.
    ; Also, it doesn't appear to be necessary to call WMN_createToolBar().
;     If IsGadget(WMN\cntToolbarAndVU)
;       ; nOldGadgetList = UseGadgetList(GadgetID(WMN\cntToolbarAndVU))
;       nOldGadgetList = UseGadgetList(WindowID(#WMN)) ; Changed 20Apr2022 11.9.1bc following crash on UseGadgetList() below
;       debugMsg0(sProcName, "nOldGadgetList=" + nOldGadgetList)
;       WMN_createToolBar(0, 0, 602, nToolBarHeight, GadgetID(WMN\cntToolbarAndVU))
;       UseGadgetList(nOldGadgetList)
;     EndIf
    
    ; Added 23Jan2023 11.9.9aa
    If bRedoToolbar
      nOldGadgetList = UseGadgetList(GadgetID(WMN\cntToolbarAndVU))
      debugMsgC(sProcName, "nOldGadgetList=" + nOldGadgetList + ", IsGadget(nOldGadgetList)=" + IsGadget(nOldGadgetList))
      WMN_createToolBar(0, 0, 602, nToolBarHeight, GadgetID(WMN\cntToolbarAndVU))
      ; UseGadgetList(nOldGadgetList) ; Deleted 2Aug2023 11.10.0bv as UseGadgetList(nOldGadgetList) was crashing in test of opening a new cue file
    EndIf
    ; End added 23Jan2023 11.9.9aa
    
    nAvailableHeight = WindowHeight(#WMN) - GadgetHeight(WMN\cvsStatusBar) - nMenuHeight
    ResizeGadget(WMN\cvsStatusBar, #PB_Ignore, nAvailableHeight, #PB_Ignore, #PB_Ignore)
    debugMsgC(sProcName, "WindowHeight(#WMN)=" + WindowHeight(#WMN) +
                        ", GadgetX(WMN\cvsStatusBar)=" + GadgetX(WMN\cvsStatusBar) + ", GadgetY()=" + GadgetY(WMN\cvsStatusBar) +
                        ", GadgetWidth()=" + GadgetWidth(WMN\cvsStatusBar) + ", GadgetHeight()=" + GadgetHeight(WMN\cvsStatusBar))
    
    If bCtrlPanelVisible
      ; debugMsg(sProcName, "bToolbarAndVUVisible=" + strB(bToolbarAndVUVisible))
      If bToolbarAndVUVisible
        If IsGadget(WMN\tbMain)
          If \nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
            setVisible(WMN\tbMain, #False)
          Else
            setVisible(WMN\tbMain, #True)
          EndIf
        EndIf
        If \nVisMode = #SCS_VU_NONE
          setVisible(WMN\cvsVULabels, #False)
          setVisible(WMN\cvsVUDisplay, #False)
        Else
          setVisible(WMN\cvsVULabels, #True)
          setVisible(WMN\cvsVUDisplay, #True)
        EndIf
        ResizeGadget(WMN\cntToolbarAndVU,#PB_Ignore,nToolbarAndVUTop,#PB_Ignore,#PB_Ignore)
      EndIf
      setVisible(WMN\cntToolbarAndVU, bToolbarAndVUVisible)
      
      If bGoAndMasterVisible
        setVisible(WMN\cntGoInfo, \bShowNextManualCue)
        debugMsgC(sProcName, "calling setVisible(WMN\cntMasterFaders, " + strB(\bShowMasterFader) + ")")
        setVisible(WMN\cntMasterFaders, \bShowMasterFader)
        ResizeGadget(WMN\cntGoAndMaster, #PB_Ignore, nGoAndMasterTop, #PB_Ignore, nGoAndMasterHeight)
      EndIf
      setVisible(WMN\cntGoAndMaster, bGoAndMasterVisible)
    EndIf
    
    setVisible(WMN\cntCtrlPanel, #False)
    setVisible(WMN\splNorthSouth, #False)
    
    WMN_doCtrlPanelPosition()
    
    If gnOperMode = #SCS_OPERMODE_DESIGN
      nNorthSouthSplitterPos = grWMN\nNorthSouthSplitterPosD
    ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
      nNorthSouthSplitterPos = grWMN\nNorthSouthSplitterPosR
    Else
      nNorthSouthSplitterPos = grWMN\nNorthSouthSplitterPosP
    EndIf
    debugMsgC(sProcName, "gnOperMode=" + decodeOperMode(gnOperMode) + ", nNorthSouthSplitterPos=" + nNorthSouthSplitterPos + ", GadgetHeight(WMN\splNorthSouth)=" + GadgetHeight(WMN\splNorthSouth))
    If nNorthSouthSplitterPos >= 0
      If nNorthSouthSplitterPos < GadgetHeight(WMN\splNorthSouth)
        SetGadgetState(WMN\splNorthSouth, nNorthSouthSplitterPos)
        debugMsgC(sProcName, "SetGadgetState(WMN\splNorthSouth, " + nNorthSouthSplitterPos + ")")
        If gbInOptionsWindow = #False
          ; only set bNorthSouthSplitterInitialPosApplied IF SetGadgetState() was called
          grWMN\bNorthSouthSplitterInitialPosApplied = #True
        EndIf
      EndIf
    Else
      If gbInOptionsWindow = #False
        grWMN\bNorthSouthSplitterInitialPosApplied = #True
      EndIf
    EndIf
    
    WMN_resizeGadgetsForSplitters()

    If gbCallLoadDispPanels
      PNL_setDispPanelsTransportControlsVisible(\bShowTransportControls, #True) ; suppress gadget change = #True because disp panels are going to be reloaded anyway
      PNL_setDispPanelsFaderAndPanControlsVisible(\bShowFaderAndPanControls, #True) ; suppress gadget change = #True because disp panels are going to be reloaded anyway
    Else
      PNL_setDispPanelsTransportControlsVisible(\bShowTransportControls, #False)
      PNL_setDispPanelsFaderAndPanControlsVisible(\bShowFaderAndPanControls, #False)
    EndIf
    
    ; scale cue panels if required
    If bRescaleCuePanels
      For n = 1 To ArraySize(gaDispPanel())
        PNL_setSliderScalingFactors(n, fYFactor, fXFactor)
      Next n
      For n = 0 To gnMaxCuePanelCreated
        If PNL_InUse(n)
          WMN_resizeOneCuePanel(n)
        EndIf
      Next n
      grCuePanels\nCuePanelHeightStd = PNL_GadgetHeight(0)
      grCuePanels\nCuePanelHeightStdPlusGap = grCuePanels\nCuePanelHeightStd + grCuePanels\nCuePanelGap
      debugMsgC(sProcName, "grCuePanels\nCuePanelHeightStd=" + Str(grCuePanels\nCuePanelHeightStd))
    EndIf
    
    WMN_displayOrHideHotkeys()
    setVisible(WMN\cntCtrlPanel, bCtrlPanelVisible)
    setVisible(WMN\splNorthSouth, #True)
    
    WMN_setupVUDisplay()
    startVUDisplayIfReqd()
    
    ; debugMsg(sProcName, "calling setNavigateButtons()")
    setNavigateButtons()
    
    ; debugMsg(sProcName, "GadgetWidth(WMN\scaCuePanels)=" + Str(GadgetWidth(WMN\scaCuePanels)))
    
    If (bRescaleCuePanels) Or (bColorSchemeChanged)
      debugMsgC(sProcName, "setting gbCallLoadDispPanels=#True")
      gbCallLoadDispPanels = #True
    EndIf
    
    bEnabled = #False
    For n = 0 To #SCS_MAX_TIME_PROFILE
      If grProd\sTimeProfile[n]
        bEnabled = #True
        Break
      EndIf
    Next n
    setToolBarBtnEnabled(#SCS_TBMB_TIME, bEnabled)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuTimeProfile, bEnabled)
    
    setGoButton()
    
  EndWith
  
;   debugMsgC(sProcName, "GadgetY(WMN\splNorthSouth)=" + GadgetY(WMN\splNorthSouth) + 
;                       ", GadgetY(WMN\cntNorth)=" + GadgetY(WMN\cntNorth) + ", GadgetHeight(WMN\cntNorth)=" + GadgetHeight(WMN\cntNorth) +
;                       ", GadgetY(WMN\grdCues)=" + GadgetY(WMN\grdCues) + ", GadgetHeight(WMN\grdCues)=" + GadgetHeight(WMN\grdCues) +
;                       ", GadgetY(WMN\cntSouth)=" + GadgetY(WMN\cntSouth) + ", GadgetHeight(WMN\cntSouth)=" + GadgetHeight(WMN\cntSouth) +
;                       ", GadgetY(WMN\scaCuePanels)=" + GadgetY(WMN\scaCuePanels) + ", GadgetHeight(WMN\scaCuePanels)=" + GadgetHeight(WMN\scaCuePanels))
;   debugMsgC(sProcName, "GGS(WMN\splPanelsHotkeys)=" + GGS(WMN\splPanelsHotkeys))
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_processKeyCallback(uMsg, wParam, lParam)
  PROCNAMEC()
  Protected nCurrHotkeyPtr, nDownDiff, nUpDiff, bSkipClearingTimeDown
  Static nGoKeyUpCount, bForceNextGo
  
  Select uMsg
    Case #WM_KEYDOWN, #WM_SYSKEYDOWN
      CompilerIf #c_keycallback_processing
        Select uMsg
          Case #WM_KEYDOWN
            debugMsg0(sProcName, "#WM_KEYDOWN, wParam=" + wParam)
          Case #WM_SYSKEYDOWN
            debugMsg0(sProcName, "#WM_SYSKEYDOWN, wParam=" + wParam)
        EndSelect
        ; debugMsg0(sProcName, "#WM_KEYDOWN or #WM_SYSKEYDOWN, wParam=" + wParam)
        ; no action
        CompilerIf #c_beep_test = #False
          If wParam = gnGoShortcut
            setGlobalTimeNow()
            nDownDiff = gqTimeNow - gqGoKeyDownTime
            nUpDiff = gqTimeNow - gqGoKeyUpTime
            debugMsg(sProcName, "KeyDown gqTimeNow=" + gqTimeNow + ", gqGoKeyDownTime=" + gqGoKeyDownTime + ", nDownDiff=" + nDownDiff + ", gqGoKeyUpTime=" + gqGoKeyUpTime + ", nUpDiff=" + nUpDiff + ", bForceNextGo=" + strB(bForceNextGo))
            If nDownDiff > grGeneralOptions\nDoubleClickTime
              If gqGoKeyUpTime > gqGoKeyDownTime Or gqGoKeyDownTime = 0
                If nUpDiff > grGeneralOptions\nDoubleClickTime Or bForceNextGo ; nUpDiff = 0
                  If 1=2                                                       ; 21Jan2022
                    debugMsg(sProcName, "calling goClicked(#True)")
                    goClicked(#True)
                    ; debugMsg0(sProcName, "returned from goClicked(#True)")
                  Else
                    gbGoIfOk = #True
                    ; PostEvent(#SCS_Event_GoButton, #WMN, 0)
                    ; playCueViaCas(gnCueToGo)
                    ; samAddRequest(#SCS_SAM_GO)
                  EndIf
                  bForceNextGo = #False
                EndIf
              EndIf
            EndIf
            gqGoKeyDownTime = gqTimeNow
          EndIf
        CompilerEndIf
      CompilerEndIf
      
    Case #WM_KEYUP, #WM_SYSKEYUP
      CompilerIf #c_keycallback_processing
        Select uMsg
          Case #WM_KEYUP
            debugMsg0(sProcName, "#WM_KEYUP, wParam=" + wParam)
          Case #WM_SYSKEYUP
            debugMsg0(sProcName, "#WM_SYSKEYUP, wParam=" + wParam)
        EndSelect
        ; debugMsg0(sProcName, "#WM_KEYUP or #WM_SYSKEYUP")
        CompilerIf #c_beep_test = #False
          If wParam = gnGoShortcut
            setGlobalTimeNow()
            debugMsg(sProcName, "KeyUp gqTimeNow=" + gqTimeNow + ", gqGoKeyDownTime=" + gqGoKeyDownTime)
            gqGoKeyUpTime = gqTimeNow
            nGoKeyUpCount + 1
            If nGoKeyUpCount = 1
              If (gqGoKeyUpTime - gqGoKeyDownTime) > grGeneralOptions\nDoubleClickTime
                bForceNextGo = #True
              EndIf
            EndIf
          EndIf
        CompilerEndIf
      CompilerEndIf
      nCurrHotkeyPtr = getCurrHotkeyPtrForVK(wParam)
      If nCurrHotkeyPtr >= 0
        Select gaCurrHotkeys(nCurrHotkeyPtr)\nActivationMethod
          Case #SCS_ACMETH_HK_TOGGLE, #SCS_ACMETH_EXT_TOGGLE
            ; Added bSkipClearingTimeDown 9Aug2024 11.10.3bc following test that showed an accidental double-press of a toggle hotkey would cause the cue to immediately stop (or fadeout) on the second press.
            bSkipClearingTimeDown = #True
        EndSelect
      EndIf
      If bSkipClearingTimeDown = #False
        If gqMainVKTimeDown(wParam) <> 0
          debugMsg(sProcName, "setting gqMainVKTimeDown(" + wParam + ")=0, was " + gqMainVKTimeDown(wParam))
          gqMainVKTimeDown(wParam) = 0
        EndIf
        If wParam <> gnGoShortcut Or #c_beep_test
          If nCurrHotkeyPtr >= 0
            With gaCurrHotkeys(nCurrHotkeyPtr)
              If \nHKShortcutVK <> wParam
                If gqMainVKTimeDown(\nHKShortcutVK) <> 0
                  debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutVK))
                  gqMainVKTimeDown(\nHKShortcutVK) = 0
                EndIf
              EndIf
              If (\nHKShortcutNumPadVK <> wParam) And (\nHKShortcutNumPadVK <> 0)
                If gqMainVKTimeDown(\nHKShortcutNumPadVK) <> 0
                  debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutNumPadVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutNumPadVK))
                  gqMainVKTimeDown(\nHKShortcutNumPadVK) = 0
                EndIf
              EndIf
            EndWith
          EndIf
        EndIf
      EndIf ; EndIf wParam <> gnGoShortcut
      
  EndSelect
      
EndProcedure

Procedure WMN_windowCallback(hWnd, uMsg, wParam, lParam)
  PROCNAMEC()
  ; SEE ALSO WCN_windowCallback() in fmControllers.pbi which duplicates this code
  ; After much testing (see RightClickTest.pb) it was found that to reliably detect right-mouse-down from anywhere on the screen that
  ; #WM_RBUTTONDOWN and #WM_NCRBUTTONDOWN should be caught in this window callback AND in the cue list callback, and that these events
  ; should return 0 to discard further processing.
  ; The corresponding event (#WM_RBUTTONDOWN or #WM_NCRBUTTONDOWN) will then be detected in WMN_EventHandler()
  
  Select uMsg
    Case #WM_RBUTTONDOWN
      ; Debug "window right button down"
      debugMsg(sProcName, "window right button down")
      ProcedureReturn 0
      
    Case #WM_NCRBUTTONDOWN
      ; Debug "window nonclient right button down"
      debugMsg(sProcName, "window nonclient right button down")
      ProcedureReturn 0
      
      ; 8May2017 11.6.1bd: commented out processing #WM_KEYDOWN, #WM_KEYUP and #WM_SYSKEYDOWN as these are now handled by keyboard shortcuts
      ; (changed because if they're not handled by keyboard shortcuts and active gadget is -1 then Windows sounds 'default beep', as reported by Malcolm Gordon)
    Case #WM_KEYDOWN
      ; debugMsg0(sProcName, "#WM_KEYDOWN uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
       
    Case #WM_KEYUP
      ; debugMsg0(sProcName, "#WM_KEYUP uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
       
    Case #WM_SYSKEYDOWN
      ; debugMsg0(sProcName, "#WM_SYSKEYDOWN uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so return 0 to cancel Windows default processing
      ProcedureReturn 0
       
    Case #WM_SYSKEYUP
      ; debugMsg0(sProcName, "#WM_SYSKEYUP uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so Return 0 To cancel Windows Default processing
      ProcedureReturn 0
      
    Case #WM_DISPLAYCHANGE
      debugMsg(sProcName, "#WM_DISPLAYCHANGE uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      checkMonitorInfo() ; 26Jul2024 11.10.3au
      
    Default
      ; debugMsg0(sProcName, "uMsg=" + uMsg + ", $" + Hex(uMsg,#PB_Long))
      
  EndSelect
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure WMN_callback_cues(hWnd, uMsg, wParam, lParam)
  PROCNAMEC()
  ; window procedure for sub-classed 'window' (gadget)
  ; see note at start of WMN_windowCallback()
  
  ; debugMsg(sProcName, "uMsg=" + uMsg + ", $" + Hex(uMsg,#PB_Long))
  Select uMsg
    Case #WM_RBUTTONDOWN
      ; Debug "cue list right button down"
      debugMsg(sProcName, "cue list right button down")
      ProcedureReturn 0
      
    Case #WM_NCRBUTTONDOWN
      ; Debug "cue list nonclient right button down"
      debugMsg(sProcName, "cue list nonclient right button down")
      ProcedureReturn 0
      
    Case #WM_KEYDOWN
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_KEYDOWN), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      
    Case #WM_SYSKEYDOWN
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_SYSKEYDOWN), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so return 0 to cancel Windows default processing
      ProcedureReturn 0
      
    Case #WM_KEYUP
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_KEYUP), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      
    Case #WM_SYSKEYUP
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_SYSKEYUP), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so return 0 to cancel Windows default processing
      ProcedureReturn 0
      
    Case #WM_NOTIFY
      ; added 6Jun2019 11.8.1.1an to update grid layout memory after dragging a column to a new position, or resizing a column - see also handleWindowEvents()
      ; debugMsg(sProcName, "#WM_NOTIFY uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      If isLeftMouseButtonDown()
        grMain\bDoSaveGridLayout = #True
      EndIf
      ProcedureReturn CallWindowProc_(grMain\lpPrevWndFuncCues, hWnd, uMsg, wParam, lParam)
      ; end added 6Jun2019 11.8.1.1an
      
    Default
      ; debugMsg0(sProcName, "uMsg=" + uMsg + ", $" + Hex(uMsg,#PB_Long)
      ; debugMsg(sProcName, "uMsg=" + uMsg + ", $" + Hex(uMsg,#PB_Long))
      ; any other messages to be passed to the previous window procedure
      ProcedureReturn CallWindowProc_(grMain\lpPrevWndFuncCues, hWnd, uMsg, wParam, lParam)
  EndSelect
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure WMN_callback_hotkeys(hWnd, uMsg, wParam, lParam)
  PROCNAMEC()
  ; window procedure for sub-classed 'window' (gadget)
  ; see note at start of WMN_windowCallback()
  
  ; debugMsg0(sProcName, "uMsg=" + uMsg + ", $" + Hex(uMsg,#PB_Long))
  Select uMsg
    Case #WM_RBUTTONDOWN
      ; Debug "hotkeys right button down"
      debugMsg(sProcName, "hotkeys right button down")
      ProcedureReturn 0
      
    Case #WM_NCRBUTTONDOWN
      ; Debug "hotkeys nonclient right button down"
      debugMsg(sProcName, "hotkeys nonclient right button down")
      ProcedureReturn 0
      
    Case #WM_KEYDOWN
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_KEYDOWN), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      
    Case #WM_SYSKEYDOWN
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_SYSKEYDOWN), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so return 0 to cancel Windows defaut processing
      ProcedureReturn 0
      
    Case #WM_KEYUP
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_KEYUP), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      
    Case #WM_SYSKEYUP
      ; debugMsg0(sProcName, "uMsg=" + uMsg + " (#WM_SYSKEYUP), wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so return 0 to cancel Windows defaut processing
      ProcedureReturn 0
      
    Default
      ; debugMsg(sProcName, "uMsg=" + uMsg + ", $" + Hex(uMsg,#PB_Long))
      ; any other messages to be passed to the previous window procedure
      ProcedureReturn CallWindowProc_(grMain\lpPrevWndFuncHotkeys, hWnd, uMsg, wParam, lParam)
  EndSelect
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure.l WMN_KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
  PROCNAMEC()
  ; Procedure added 24Apr2019 11.8.1ah to enable vol up/down/mute keys to be trapped without also being processed by Windows.
  ; Based on code provided by RSBasic in reply to my forum posting "How do I take control of keyboard vol up, down and mute?".
  Static bMuteKeyDown
  Protected nVkCode, nCurrHotkeyPtr, qTimeNow.q, bSkipClearingTimeDown
  
  ; Note: The hex codes in the following Select Case statements are as supplied by Michael Swenson 20Apr2019 regarding the LiveShowControl remote device, namely:
  ;   VolUp – 0xE9
  ;   VolDown – 0xEA
  ;   Mute – 0xE3
  ; The #VK_VOLUME... values are as detected on my development laptop, and these values are different to those provided by Michael Swenson.
  
  If wParam = #WM_KEYDOWN Or wParam = #WM_SYSKEYDOWN
    ; debugMsg0(sProcName, "KEY DOWN vvvvvvvvv, *p\vkCode=" + *p\vkCode)
    Select *p\vkCode
      Case #VK_VOLUME_UP, $E9
        WMN_processShortcut(#SCS_WMNF_MastFdrUp, #True)
        ProcedureReturn 1
        
      Case #VK_VOLUME_DOWN, $EA
        WMN_processShortcut(#SCS_WMNF_MastFdrDown, #True)
        ProcedureReturn 1
        
      Case #VK_VOLUME_MUTE, $E3
        If bMuteKeyDown = #False
          WMN_processShortcut(#SCS_WMNF_MastFdrMute, #True)
          bMuteKeyDown = #True
        EndIf
        ProcedureReturn 1
        
      Case #VK_RETURN
        If grM2T\nM2TMaxItem >= 0
          If gbInMessageRequester = #False ; Could be in MessageRequester if an invalid time has been entered in txtMoveToTime
            If IsGadget(gaPnlVars(0)\cntMoveToTimePrimary)
              If getVisible(gaPnlVars(0)\cntMoveToTimePrimary)
                debugMsg(sProcName, "#VK_RETURN, calling PostEvent(#SCS_Event_M2T_Apply, #WMN, 0, 0, 0)")
                PostEvent(#SCS_Event_M2T_Apply, #WMN, 0, 0, 0) ; 'Data' parameter is display panel index
                ProcedureReturn 1
              EndIf
            EndIf
          EndIf ; EndIf gbInMessageRequester = #False
        EndIf ; EndIf grM2T\nM2TMaxItem >= 0
        
      Case #VK_ESCAPE
        If grM2T\nM2TMaxItem >= 0
          If gbInMessageRequester = #False ; Could be in MessageRequester if an invalid time has been entered in txtMoveToTime
            If IsGadget(gaPnlVars(0)\cntMoveToTimePrimary)
              If getVisible(gaPnlVars(0)\cntMoveToTimePrimary)
                debugMsg(sProcName, "#VK_ESCAPE, calling PostEvent(#SCS_Event_M2T_Cancel, #WMN, 0, 0, 0)")
                PostEvent(#SCS_Event_M2T_Cancel, #WMN, 0, 0, 0) ; 'Data' parameter is display panel index
                ProcedureReturn 1
              EndIf
            EndIf
          EndIf ; EndIf gbInMessageRequester = #False
        EndIf ; EndIf grM2T\nM2TMaxItem >= 0
        
      Default
        ; debugMsg0(sProcName, "*p\vkCode=" + *p\vkCode)
        
    EndSelect
    
  ElseIf wParam = #WM_KEYUP Or wParam = #WM_SYSKEYUP
    ; debugMsg0(sProcName, "KEY UP ^^^^^^^^^^^, *p\vkCode=" + *p\vkCode)
    nVkCode = *p\vkCode
    Select nVkCode
      Case #VK_VOLUME_MUTE, $E3
        bMuteKeyDown = #False
        ProcedureReturn 1
      Default
        nCurrHotkeyPtr = getCurrHotkeyPtrForVK(nVkCode)
        ; debugMsg(sProcName, "nCurrHotkeyPtr=" + nCurrHotkeyPtr)
        ; Added 12May2020 11.8.3rc3 following email from Christian Peters about Ctrl/U (Pause/Resume all) not working sometimes
        If gqMainVKTimeDown(nVkCode) <> 0
          If nCurrHotkeyPtr >= 0
            ; debugMsg(sProcName, "gaHotkeys(" + nCurrHotkeyPtr + ")\nActivationMethod=" + decodeActivationMethod(gaHotkeys(nCurrHotkeyPtr)\nActivationMethod))
            Select gaCurrHotkeys(nCurrHotkeyPtr)\nActivationMethod
              Case #SCS_ACMETH_HK_TOGGLE, #SCS_ACMETH_EXT_TOGGLE
                ; Added bSkipClearingTimeDown 9Aug2024 11.10.3bc following test that showed an accidental double-press of a toggle hotkey would cause the cue to immediately stop (or fadeout) on the second press.
                bSkipClearingTimeDown = #True
            EndSelect
          EndIf
          If bSkipClearingTimeDown = #False
            debugMsg(sProcName, "setting gqMainVKTimeDown(" + nVkCode + ")=0, was " + gqMainVKTimeDown(nVkCode))
            gqMainVKTimeDown(nVkCode) = 0
          EndIf
        EndIf
        If nCurrHotkeyPtr >= 0 And bSkipClearingTimeDown = #False
          With gaCurrHotkeys(nCurrHotkeyPtr)
            If \nHKShortcutVK <> nVkCode
              If gqMainVKTimeDown(\nHKShortcutVK) <> 0
                debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutVK))
                gqMainVKTimeDown(\nHKShortcutVK) = 0
              EndIf
            EndIf
            If (\nHKShortcutNumPadVK <> nVkCode) And (\nHKShortcutNumPadVK <> 0)
              If gqMainVKTimeDown(\nHKShortcutNumPadVK) <> 0
                debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutNumPadVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutNumPadVK))
                gqMainVKTimeDown(\nHKShortcutNumPadVK) = 0
              EndIf
            EndIf
          EndWith
        EndIf
        ; End added 12May2020 11.8.3rc3

    EndSelect
  EndIf
  ProcedureReturn CallNextHookEx_(0, nCode, wParam, *p)
EndProcedure

Procedure WMN_displayTemplateInfoIfReqd(bForce=#False)
  PROCNAMEC()
  Protected nReqdWidth, nLeft
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WMN
    ; debugMsg(sProcName, "grProd\bTemplate=" + strB(grProd\bTemplate) + ", grProd\sTmName=" + grProd\sTmName)
    If grProd\bTemplate
      If (grWMN\bTemplateInfoSet = #False) Or (getVisible(\cntTemplate) = #False) Or (bForce)
        ResizeGadget(\cntTemplate, GadgetX(\cntMasterFaders), GadgetY(\cntMasterFaders), GadgetWidth(\cntMasterFaders), GadgetHeight(\cntMasterFaders))
        SGT(\lblTemplateInfo, LangPars("WMN", "lblTemplateInfo", #DQUOTE$ + grProd\sTmName + #DQUOTE$))
        nReqdWidth = GadgetWidth(\lblTemplateInfo, #PB_Gadget_RequiredSize)
        nLeft = (GadgetWidth(\cntTemplate) - nReqdWidth - gl3DBorderAllowanceX) / 2
        ResizeGadget(\lblTemplateInfo, nLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        nLeft = (GadgetWidth(\cntTemplate) - GadgetWidth(\btnCloseTemplate) - gl3DBorderAllowanceX) / 2
        ResizeGadget(\btnCloseTemplate, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        setVisible(\cntTemplate, #True)
        grWMN\bTemplateInfoSet = #True
      EndIf
      setVisible(\cntMasterFaders, #False)
      setVisible(\cntTemplate, #True)
    Else
      setVisible(\cntTemplate, #False)
      setVisible(\cntMasterFaders, grOperModeOptions(gnOperMode)\bShowMasterFader)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_btnCloseTemplate_Click()
  PROCNAMEC()
  Protected bCancel
  
  debugMsg(sProcName, #SCS_START)
  
  WEN_closeMemoWindowsIfOpen()
  debugMsg(sProcName, "calling checkDataChanged(#False)")
  bCancel = checkDataChanged(#False)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not start new file
    ProcedureReturn
  EndIf
  setMonitorPin()
  
  debugMsg(sProcName, "calling closeCueFile()")
  closeCueFile()
  debugMsg(sProcName, "calling setCueDetailsInMain()")
  setCueDetailsInMain()
  
  WLP_setIndexWithinChoice(#SCS_CHOICE_TEMPLATE, gsTemplateFile)
  WLP_Form_Show(#WMN, #True, 0, #False)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WMN_buildMenuGroup_SaveFile(nMenu)
  ; PROCNAMEC()
  Protected nSaveTest, bEnableSave, bEnableSaveAs, bSaveReasonVisible
  
  ; debugMsg(sProcName, #SCS_START)
  
  scsMenuItemFast(#WMN_mnuSave, grText\sTextSave)
  scsMenuItemFast(#WMN_mnuSaveAs, grText\sTextSaveAs)
  
  nSaveTest = checkSaveToBeEnabled()
  If nSaveTest > 0
    bEnableSave = #True
    If nSaveTest <= 29
      bSaveReasonVisible = #True
    EndIf
  EndIf
  If grProd\bTemplate = #False
    bEnableSaveAs = #True
  EndIf
  scsEnableMenuItem(nMenu, #WMN_mnuSave, bEnableSave)
  scsEnableMenuItem(nMenu, #WMN_mnuSaveAs, bEnableSaveAs)
  
  gbMainSaveEnabled = bEnableSave
  If gbMainSaveEnabled = #False
    killRecoveryFile()
  EndIf
  If bSaveReasonVisible
    MenuBar()
    scsMenuItemFast(#WMN_mnuSaveReason, grText\sTextSaveReason)
  EndIf
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WMN_buildMenuGroup_Navigate()
  PROCNAMEC()
  Protected nBankIndex, sBank.s, sText.s
  Protected nAudPtr, nCueMarkerIndex, nCueMarkerId, n
  
  debugMsg(sProcName, #SCS_START)
  
  scsMenuItem(#WMN_mnuNavTop, "mnuNavTop")
  scsMenuItem(#WMN_mnuNavBack, "mnuNavBack")
  scsMenuItem(#WMN_mnuNavNext, "mnuNavNext")
  scsMenuItem(#WMN_mnuNavEnd, "mnuNavEnd")
  MenuBar()
  scsMenuItem(#WMN_mnuNavFind, "mnuNavFind")
  If grLicInfo\nMaxHotkeyBank > 0
    MenuBar()
    OpenSubMenu(Lang("Menu", "mnuHB_Parent"))
      sBank = Lang("HKeys", "Bank")
      For nBankIndex = 0 To grLicInfo\nMaxHotkeyBank
        If nBankIndex = 0
          sText = ReplaceString(sBank, "$1", "0 (" + Lang("HKeys", "Common") + ")")
        Else
          sText = ReplaceString(sBank, "$1", Str(nBankIndex))
        EndIf
        scsMenuItem(#WMN_mnuHB_00 + nBankIndex, sText, "", #False)
      Next nBankIndex
    CloseSubMenu()
    SetMenuItemState(#WMN_mnuNavigate, #WMN_mnuHB_00, #True)
  EndIf
  If grLicInfo\bStepHotkeysAvailable
    MenuBar()
    scsMenuItem(#WMN_mnuResetStepHKs, "mnuResetStepHKs")
  EndIf
  MenuBar()
  scsMenuItem(#WMN_mnuCloseAndReOpenDMXDevs, "Close and Re-Open DMX Devices", "", #False)
  
EndProcedure

Procedure WMN_buildMenuGroup_Help()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  scsMenuItem(#WMN_mnuHelpContents, "mnuHelpContents")
  
  MenuBar()
  scsMenuItem(#WMN_mnuHelpClearDTMAInds, "mnuHelpClearDTMAInds")
  scsMenuItem(#WMN_mnuTracing, "mnuTracing")
  
  MenuBar()
  CompilerIf #cWorkshop = #False
    scsMenuItem(#WMN_mnuHelpCheckForUpdate, "mnuHelpCheckForUpdate")
    scsMenuItem(#WMN_mnuHelpForums, "mnuHelpForums")
    MenuBar()
    scsMenuItem(#WMN_mnuHelpRegistration, "mnuHelpRegistration")
  CompilerEndIf
  
  scsMenuItem(#WMN_mnuHelpAbout, "mnuHelpAbout")
  
EndProcedure

Procedure WMN_buildMenuGroup_Mtrs()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  OpenSubMenu(Lang("Menu", "mnuMtrsVUHdg"))
    scsMenuItem(#WMN_mnuMtrsVULevels, "mnuMtrsVULevels")
    scsMenuItem(#WMN_mnuMtrsVUNone, "mnuMtrsVUNone")
  CloseSubMenu()
  
  OpenSubMenu(Lang("Menu", "mnuVUBarWidth"))
    scsMenuItem(#WMN_mnuVUNarrow, "mnuVUNarrow")
    scsMenuItem(#WMN_mnuVUMedium, "mnuVUMedium")
    scsMenuItem(#WMN_mnuVUWide, "mnuVUWide")
  CloseSubMenu()
  
  OpenSubMenu(Lang("Menu", "mnuMtrsPeakHdg"))
    scsMenuItem(#WMN_mnuMtrsPeakOff, "mnuMtrsPeakOff")
    scsMenuItem(#WMN_mnuMtrsPeakAuto, "mnuMtrsPeakAuto")
    scsMenuItem(#WMN_mnuMtrsPeakHold, "mnuMtrsPeakHold")
  CloseSubMenu()
  
  MenuBar()
  ; 'reset' outside of above group to provide easier access to 'reset'
  scsMenuItem(#WMN_mnuMtrsPeakReset, "mnuMtrsPeakReset")
  
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    MenuBar()
    scsMenuItem(#WMN_mnuMtrsDMXDisplay, "mnuMtrsDMXDisplay")
  EndIf
  
EndProcedure

Procedure WMN_setViewOperModeMenuItems()
  Protected bDesign, bRehearsal, bPerformance
  
  Select gnOperMode
    Case #SCS_OPERMODE_DESIGN
      bDesign = #True
    Case #SCS_OPERMODE_REHEARSAL
      bRehearsal = #True
    Case #SCS_OPERMODE_PERFORMANCE
      bPerformance = #True
  EndSelect
  
  ; Changed 24Jan2023 11.9.9ab
  If IsMenu(#WMN_mnuView)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewOperModeDesign, bDesign)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewOperModeRehearsal, bRehearsal)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewOperModePerformance, bPerformance)
  EndIf
  If IsMenu(#WMN_mnuWindowMenu)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuViewOperModeDesign, bDesign)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuViewOperModeRehearsal, bRehearsal)
    SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuViewOperModePerformance, bPerformance)
  EndIf
  ; End changed 24Jan2023 11.9.9ab
  
EndProcedure

Procedure WMN_buildMenuGroup_View()
  PROCNAMEC()
  Static sDesign.s, sRehearsal.s, sPerformance.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sDesign = Lang("OperMode", "Design")
    sRehearsal = Lang("OperMode", "Rehearsal")
    sPerformance = Lang("OperMode", "Performance")
    bStaticLoaded = #True
  EndIf
  
  OpenSubMenu(Lang("Info", "OperMode"))
    scsMenuItem(#WMN_mnuViewOperModeDesign, sDesign, "", #False)
    scsMenuItem(#WMN_mnuViewOperModeRehearsal, sRehearsal, "", #False)
    scsMenuItem(#WMN_mnuViewOperModePerformance, sPerformance, "", #False)
  CloseSubMenu()
  WMN_setViewOperModeMenuItems()
  MenuBar()
  
  OpenSubMenu(Lang("Menu", "mnuMtrs"))
    
    OpenSubMenu(Lang("Menu", "mnuMtrsVUHdg"))
      scsMenuItem(#WMN_mnuMtrsVULevels, "mnuMtrsVULevels")
      scsMenuItem(#WMN_mnuMtrsVUNone, "mnuMtrsVUNone")
    CloseSubMenu()
    
    OpenSubMenu(Lang("Menu", "mnuVUBarWidth"))
      scsMenuItem(#WMN_mnuVUNarrow, "mnuVUNarrow")
      scsMenuItem(#WMN_mnuVUMedium, "mnuVUMedium")
      scsMenuItem(#WMN_mnuVUWide, "mnuVUWide")
    CloseSubMenu()
    
    OpenSubMenu(Lang("Menu", "mnuMtrsPeakHdg"))
      scsMenuItem(#WMN_mnuMtrsPeakOff, "mnuMtrsPeakOff")
      scsMenuItem(#WMN_mnuMtrsPeakAuto, "mnuMtrsPeakAuto")
      scsMenuItem(#WMN_mnuMtrsPeakHold, "mnuMtrsPeakHold")
    CloseSubMenu()
    
    MenuBar()
    ; 'reset' outside of above group to provide easier access to 'reset'
    scsMenuItem(#WMN_mnuMtrsPeakReset, "mnuMtrsPeakReset")
    
    WMN_setVUMenuItemStates() ; Added 24Jan2023 11.9.9ab
    WMN_setPeakMenuItemStates() ; Added 24Jan2023 11.9.9ab
    
  CloseSubMenu()
  
  MenuBar()
  scsMenuItem(#WMN_mnuCurrInfo, "mnuCurrInfo")
  
  MenuBar()
  scsMenuItem(#WMN_mnuViewClock, "mnuViewClock")
  MenuBar()
  scsMenuItem(#WMN_mnuViewCountdown, "mnuViewCountdown")
  scsMenuItem(#WMN_mnuViewClearCountdownClock, "mnuViewClearCountdownClock")
  
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    MenuBar()
    scsMenuItem(#WMN_mnuMtrsDMXDisplay, "mnuMtrsDMXDisplay")
  EndIf
  
EndProcedure

Procedure WMN_buildPopupMenu_SaveFile()
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  If IsMenu(#WMN_mnuSaveFile)
    FreeMenu(#WMN_mnuSaveFile)
  EndIf
  
  If scsCreatePopupMenu(#WMN_mnuSaveFile)
    WMN_buildMenuGroup_SaveFile(#WMN_mnuSaveFile)
  EndIf
EndProcedure

Procedure WMN_buildWindowMenu()
  PROCNAMEC()
  Protected nIndex, sParam.s, sMenuText.s
  
  debugMsg(sProcName, #SCS_START)
  
  If IsMenu(#WMN_mnuWindowMenu)
    FreeMenu(#WMN_mnuWindowMenu)
  EndIf
  
  If scsCreateMenu(#WMN_mnuWindowMenu, #WMN)
  
    ; Cue Control
    MenuTitle(Lang("Menu", "mnuCueControl"))
    scsMenuItem(#WMN_mnuGo, "mnuGo")
    scsMenuItem(#WMN_mnuPauseAll, "mnuPauseAll")
    
    sParam = decodeMainShortcutFunction(#SCS_WMNF_StopAll)
    sMenuText = LangPars("Menu", "mnuStopAll", sParam)
    scsMenuItemFast(#WMN_mnuStopAll, sMenuText)
    
    sParam = decodeMainShortcutFunction(#SCS_WMNF_FadeAll)
    sMenuText = LangPars("Menu", "mnuFadeAll", sParam)
    scsMenuItemFast(#WMN_mnuFadeAll, sMenuText)
    
    OpenSubMenu(Lang("Menu","mnuNavigate"))
      WMN_buildMenuGroup_Navigate()
    CloseSubMenu()
    scsMenuItem(#WMN_mnuStandbyGo, "mnuStandbyGo")
    scsMenuItem(#WMN_mnuTimeProfile, "mnuTimeProfile")
    
    ; File
    MenuTitle(Lang("Menu", "mnuFile"))
    scsMenuItem(#WMN_mnuFileLoad, "mnuFileLoad")
    scsMenuItem(#WMN_mnuFileTemplates, "mnuFileTemplates")
    MenuBar()
    OpenSubMenu(Lang("Menu","mnuSaveFile"))  ; Save submenu
      WMN_buildMenuGroup_SaveFile(#WMN_mnuWindowMenu)
    CloseSubMenu()
    MenuBar()
    scsMenuItem(#WMN_mnuFilePrint, "mnuFilePrint")
    MenuBar()
    scsMenuItem(#WMN_mnuOptions, "mnuOptions")
    MenuBar()
    scsMenuItem(#WMN_mnuFileExit, "mnuFileExit")
    
    ; Editing
    MenuTitle(Lang("Menu", "mnuEditing"))
    scsMenuItem(#WMN_mnuEditor, "mnuEditor")
    If grLicInfo\bVSTPluginsAvailable
      scsMenuItem(#WMN_mnuVST, "mnuVST")
    EndIf
    OpenSubMenu(Lang("Menu","mnuSaveSettings"))
      WMN_buildMenuGroup_SaveSettings(#WMN_mnuWindowMenu)
    CloseSubMenu()
    
    ; View
    MenuTitle(Lang("Menu", "mnuView"))
    WMN_buildMenuGroup_View()
    
    ; Help
    MenuTitle(Lang("Menu", "mnuHelp"))
    WMN_buildMenuGroup_Help()
    
  EndIf
EndProcedure

Procedure WMN_buildPopupMenu_SaveSettings()
  PROCNAMEC()
  ; debugMsg(sProcName, #SCS_START)
  
  If scsCreatePopupMenu(#WMN_mnuSaveSettings)
    WMN_buildMenuGroup_SaveSettings(#WMN_mnuSaveSettings)
  EndIf
  
  If IsMenu(#WMN_mnuWindowMenu)
    FreeMenu(#WMN_mnuWindowMenu)
    ; re-build the menu to re-populate the 'Save Settings' sub-menu
    debugMsg(sProcName, "(d) calling WMN_buildWindowMenu()")
    WMN_buildWindowMenu()
  EndIf
  
EndProcedure

Procedure WMN_refreshMenu_SaveSettings()
  ; PROCNAMEC()
  Protected nMenu = #WMN_mnuWindowMenu, nMenu2 = #WMN_mnuSaveSettings
  Protected bEnable
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; AUDIO MASTER FADER
  If grProd\fMasterBVLevel = SLD_getLevel(WMN\sldMasterFader)
    bEnable = #False
  Else
    bEnable = #True
  EndIf
  scsEnableMenuItem2(nMenu, #WMN_mnuMastFaderReset, bEnable, nMenu2)
  scsEnableMenuItem2(nMenu, #WMN_mnuMastFaderSave, bEnable, nMenu2)
  If gnSaveSettingsCount > 0
    scsEnableMenuItem2(nMenu, #WMN_mnuSaveSettingsAllCues, bEnable, nMenu2)
  EndIf
  ; DMX MASTER FADER
  If grLicInfo\bDMXSendAvailable
    If grDMXMasterFader\nDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderResetValue
      bEnable = #False
    Else
      bEnable = #True
    EndIf
    scsEnableMenuItem2(nMenu, #WMN_mnuDMXMastFaderReset, bEnable, nMenu2)
    scsEnableMenuItem2(nMenu, #WMN_mnuDMXMastFaderSave, bEnable, nMenu2)
  EndIf
  
EndProcedure

Procedure WMN_buildPopupMenu_DevMap()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "IsMenu(#WMN_mnuDevMap)=" + IsMenu(#WMN_mnuDevMap))
  If IsMenu(#WMN_mnuDevMap)
    FreeMenu(#WMN_mnuDevMap)
  EndIf
  
  If scsCreatePopupMenu(#WMN_mnuDevMap)
    debugMsg(sProcName, "scsCreatePopupMenu(#WMN_mnuDevMap) returned #True")
    WMN_buildMenuGroup_DevMap()
    setToolBarBtnEnabled(#SCS_TBMB_DEVMAP, #True)
  EndIf
  
EndProcedure

Procedure WMN_createCuePanel(nPanelIndex, bPanelVisible)
  PROCNAMEC()
  Protected sPanelName.s
  Protected nTop
  
  ; debugMsg(sProcName, #SCS_START + ", nPanelIndex=" + nPanelIndex + ", bPanelVisible=" + strB(bPanelVisible))
  
  setCurrWindowGlobals(#WMN)
  
  sPanelName = "Panel_" + nPanelIndex
  nTop = (nPanelIndex * (grCuePanels\nCuePanelHeightStdPlusGap))
  If nPanelIndex > gnMaxCuePanelCreated
    gnMaxCuePanelCreated = nPanelIndex
  EndIf
  ; 23Mar2017 11.6.0: changed PNL_New to use grCuePanelsInitValues instead of grCuePanels following email from C.Peters about audio graphs on cue panels > 25 being too large
  ; PNL_New(nPanelIndex, sPanelName, WMN\scaCuePanels, 1, nTop, 692, grCuePanels\nCuePanelHeightStd)
  PNL_New(nPanelIndex, sPanelName, WMN\scaCuePanels, 1, nTop, 692, grCuePanelsInitValues\nCuePanelHeightStd)
  PNL_SetVisible(nPanelIndex, bPanelVisible)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_createToolBar(nLeft, nTop, nWidth, nHeight, nHostId)
  PROCNAMEC()
  Protected i
  Protected bStandbyButtonReqd
  Protected bTimeProfileButtonReqd
  Protected nMainToolBarInfo
  Protected nIndex, sParam.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gbInOptionsWindow
    nMainToolBarInfo = mrOperModeOptions(gnOperMode)\nMainToolBarInfo
  Else
    nMainToolBarInfo = grOperModeOptions(gnOperMode)\nMainToolBarInfo
  EndIf
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      If aCue(i)\nStandby <> #SCS_STANDBY_NONE
        bStandbyButtonReqd = #True
      EndIf
      If (aCue(i)\nActivationMethod = #SCS_ACMETH_TIME) And (nMainToolBarInfo = #SCS_TOOL_DISPLAY_ALL)
        bTimeProfileButtonReqd = #True
      EndIf
    EndIf
  Next i
  
  debugMsg(sProcName, "bStandbyButtonReqd=" + StrB(bStandbyButtonReqd) + ", bTimeProfileButtonReqd=" + StrB(bTimeProfileButtonReqd))
  If (nMainToolBarInfo = grWMN\nMainToolBarInfo) And (bStandbyButtonReqd = grWMN\bStandbyButtonDisplayed) And (bTimeProfileButtonReqd = grWMN\bTimeProfileButtonDisplayed)
    ; no change to toolbar
    ProcedureReturn
  EndIf
  
  deleteToolBar(#SCS_TBM_MAIN)  ; frees toolbar gadgets if the toolbar exists
  
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
    grWMN\bToolBarDisplayed = #False
    grWMN\nMainToolBarInfo = nMainToolBarInfo
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "nMainToolBarInfo=" + decodeMainToolBarInfo(nMainToolBarInfo))
  
  ; ------------------------ toolbar setup
  WMN\tbMain = addToolBar(#SCS_TBM_MAIN, nLeft, nTop, nWidth, nHeight, nHostId)
  
  ; Cue Control category
  addToolBarCat(#SCS_TBMC_CUE_CONTROL, #SCS_TBM_MAIN, Lang("Menu", "mnuCueControl"),140)
  addToolBarBtn(#SCS_TBMB_GO, #SCS_TBMC_CUE_CONTROL, hToolGoEn, hToolGoDi, Lang("Menu", "mnuGo"), "", 102, 24, 24, #False, #True, #False) ; Go
  addToolBarBtn(#SCS_TBMB_PAUSE_RESUME, #SCS_TBMC_CUE_CONTROL, hToolPauseAllEn, hToolPauseAllDi, Lang("Menu", "mnuPauseAll"), Lang("Menu", "mnuPauseAllTT"), 54, 24, 24, #False, #True, #False) ; Pause/Resume All
  addToolBarBtn2(#SCS_TBMB_PAUSE_RESUME, hToolResumeAllEn, hToolResumeAllDi, Lang("Menu", "mnuResumeAll"), Lang("Menu", "mnuResumeAllTT"))
  sParam = decodeMainShortcutFunction(#SCS_WMNF_StopAll)
  addToolBarBtn(#SCS_TBMB_STOP_ALL, #SCS_TBMC_CUE_CONTROL, hToolStopAllEn, hToolStopAllDi, LangPars("Menu", "mnuStopAll", sParam), "", -4, 24, 24, #False, #True, #False) ; Stop All
  setToolBarBtnToolTip(#SCS_TBMB_STOP_ALL, Lang("WMN", "StopTip"))
  ; added 21Mar2020 11.8.2.3ad
  sParam = decodeMainShortcutFunction(#SCS_WMNF_FadeAll)
  addToolBarBtn(#SCS_TBMB_FADE_ALL, #SCS_TBMC_CUE_CONTROL, hToolFadeAllEn, hToolFadeAllDi, LangPars("Menu", "mnuFadeAll", sParam), "", -4, 24, 24, #False, #True, #False) ; Fade All
  setToolBarBtnToolTip(#SCS_TBMB_FADE_ALL, Lang("WMN", "FadeTip"))
  ; end added 21Mar2020 11.8.2.3ad
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_ALL
    addToolBarBtn(#SCS_TBMB_NAVIGATE, #SCS_TBMC_CUE_CONTROL, hToolNavigateEn, hToolNavigateDi, Lang("Menu", "mnuNavigate"), "", -3, 24, 24, #True, #False) ; Navigate
  EndIf
  addToolBarBtn(#SCS_TBMB_STANDBY_GO, #SCS_TBMC_CUE_CONTROL, hToolStandbyGoEn, hToolStandbyGoDi, Lang("Menu", "mnuStandbyGo"), "", -3, 24, 24, #False, #False, #True, bStandbyButtonReqd) ; Standby Go
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_ALL
    addToolBarBtn(#SCS_TBMB_TIME, #SCS_TBMC_CUE_CONTROL, hToolTimeEn, hToolTimeDi, Lang("Menu", "mnuTimeProfile"), "", -3, 24, 24, #False, #False, #True, bTimeProfileButtonReqd) ; Select Time Profile
  EndIf
  
  ; File category
  addToolBarCat(#SCS_TBMC_FILE, #SCS_TBM_MAIN, Lang("Menu", "mnuFile"))
  addToolBarBtn(#SCS_TBMB_LOAD, #SCS_TBMC_FILE, hToolLoadEn, hToolLoadDi, Lang("Menu", "mnuLoad"), "", -2) ; Load
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_ALL
    addToolBarBtn(#SCS_TBMB_TEMPLATES, #SCS_TBMC_FILE, hToolTemplatesEn, hToolTemplatesDi, Lang("Menu", "mnuTemplates"), "", -2) ; Templates
    addToolBarBtn(#SCS_TBMB_SAVE, #SCS_TBMC_FILE, hToolSaveEn, hToolSaveDi, Lang("Menu", "mnuSave"), "", -1, 24, 24, #True)      ; Save
    addToolBarBtn(#SCS_TBMB_PRINT, #SCS_TBMC_FILE, hToolPrintEn, hToolPrintEn, Lang("Menu", "mnuPrint"), "", -2)                 ; Print
  EndIf
  addToolBarBtn(#SCS_TBMB_OPTIONS, #SCS_TBMC_FILE, hToolOptEn, hToolOptDi, Lang("Menu", "mnuOptions"), "", -2) ; Options
  
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_ALL
    ; Editing category
    addToolBarCat(#SCS_TBMC_EDITING, #SCS_TBM_MAIN, Lang("Menu", "mnuEditing"))
    addToolBarBtn(#SCS_TBMB_EDITOR, #SCS_TBMC_EDITING, hToolEditorEn, hToolEditorDi, Lang("Menu", "mnuEditor"), Lang("Menu", "mnuEditorTT"), -1) ; Editor
    If grLicInfo\bVSTPluginsAvailable
      addToolBarBtn(#SCS_TBMB_VST, #SCS_TBMC_EDITING, hToolVSTEn, hToolVSTDi, Lang("Menu", "mnuVST"), Lang("Menu", "mnuVSTTT"), -3, 24, 24) ; VST Plugin
    EndIf
    addToolBarBtn(#SCS_TBMB_DEVMAP, #SCS_TBMC_EDITING, hToolDevMapEn, hToolDevMapDi, Lang("Menu", "mnuDevMap"), Lang("Menu", "mnuDevMapTT"), -3, 24, 24, #True) ; DevMap Selection
    addToolBarBtn(#SCS_TBMB_SAVE_SETTINGS, #SCS_TBMC_EDITING, hToolSvSettingsEn, hToolSvSettingsDi, Lang("Menu", "mnuSaveSettings"), Lang("Menu", "mnuSaveSettingsTT"), -3, 24, 24, #True) ; Save Settings
  EndIf

  ; View category
  addToolBarCat(#SCS_TBMC_VIEW, #SCS_TBM_MAIN, Lang("Menu", "mnuView"))
  addToolBarBtn(#SCS_TBMB_VIEW, #SCS_TBMC_VIEW, hToolViewEn, hToolViewEn, Lang("Menu", "mnuView"), "", -2, 24, 24, #True) ; View
  
  ; Help category
  addToolBarCat(#SCS_TBMC_HELP, #SCS_TBM_MAIN, Lang("Menu", "mnuHelp"))
  addToolBarBtn(#SCS_TBMB_HELP, #SCS_TBMC_HELP, hToolHelpEn, hToolHelpEn, Lang("Menu", "mnuHelp"), "", -2, 24, 24, #True) ; Help
  
  drawToolBar(#SCS_TBM_MAIN)
  
  ; debugMsg(sProcName, "bStandbyButtonReqd=" + strB(bStandbyButtonReqd) + ", bTimeProfileButtonReqd=" + strB(bTimeProfileButtonReqd))
  grWMN\bStandbyButtonDisplayed = bStandbyButtonReqd
  grWMN\bTimeProfileButtonDisplayed = bTimeProfileButtonReqd
  grWMN\bToolBarDisplayed = #True
  grWMN\nMainToolBarInfo = nMainToolBarInfo
  
  ; ------------------------ end of toolbar setup
  
  gaWindowProps(#WMN)\nToolBarHeight = nHeight
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_buildMenuGroup_SaveSettings(nMenu)
  ; PROCNAMEC()
  Protected n, bSaveEnabled
  Protected sShortCut.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  scsMenuItem(#WMN_mnuMastFaderReset, "mnuMastFaderReset")
  scsMenuItem(#WMN_mnuMastFaderSave, "mnuMastFaderSave")
  
  If grProd\fMasterBVLevel = SLD_getLevel(WMN\sldMasterFader)
    scsEnableMenuItem(nMenu, #WMN_mnuMastFaderReset, #False)
    scsEnableMenuItem(nMenu, #WMN_mnuMastFaderSave, #False)
    bSaveEnabled = #False
  Else
    scsEnableMenuItem(nMenu, #WMN_mnuMastFaderReset, #True)
    scsEnableMenuItem(nMenu, #WMN_mnuMastFaderSave, #True)
    bSaveEnabled = #True
  EndIf
  
  ; debugMsg(sProcName, "gnSaveSettingsCount=" + gnSaveSettingsCount)
  If gnSaveSettingsCount > 0
    MenuBar()
    For n = 0 To #SCS_MAX_SAVE_SETTINGS ; ArraySize(#WMN_mnuSaveSettingsCue)
      If n < gnSaveSettingsCount
        scsMenuItem(#WMN_mnuSaveSettingsCue_00+n, Lang("Menu","mnuSaveSettings") + " " + aSub(gaSaveSettings(n)\nSSSubPtr)\sSubLabel, "", #False)
      EndIf
    Next n
    MenuBar()
    sShortCut = Trim(gaShortcutsMain(#SCS_ShortMain_SaveCueSettings)\sShortcutStr)
    If bSaveEnabled
      scsMenuItem(#WMN_mnuSaveSettingsAllCues, "mnuSaveSettingsAllCuesNMF", sShortCut)  ; "Save Level/pan For all above Cues (but not Master Fader)"
    Else
      scsMenuItem(#WMN_mnuSaveSettingsAllCues, "mnuSaveSettingsAllCues", sShortCut)     ; "Save Level/pan For all above Cues"
    EndIf
  EndIf
  
  If grLicInfo\bDMXSendAvailable
    MenuBar()
    scsMenuItem(#WMN_mnuDMXMastFaderReset, "mnuDMXMastFaderReset")
    scsMenuItem(#WMN_mnuDMXMastFaderSave, "mnuDMXMastFaderSave")
    If grDMXMasterFader\nDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderResetValue
      scsEnableMenuItem(nMenu, #WMN_mnuDMXMastFaderReset, #False)
      scsEnableMenuItem(nMenu, #WMN_mnuDMXMastFaderSave, #False)
    Else
      scsEnableMenuItem(nMenu, #WMN_mnuDMXMastFaderReset, #True)
      scsEnableMenuItem(nMenu, #WMN_mnuDMXMastFaderSave, #True)
    EndIf
  EndIf
  
EndProcedure

Procedure WMN_buildMenuGroup_DevMap()
  PROCNAMEC()
  Protected n
  Protected nMenuItemNo = #WMN_mnuDevMapItem_0
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMaps\nMaxMapIndex
    grMaps\aMap(n)\nMenuItemNo = 0 ; initially clear all menu item numbers
  Next n
  
  For n = 0 To grMaps\nMaxMapIndex
    With grMaps\aMap(n)
      If nMenuItemNo <= #WMN_mnuDevMapItem_9
        scsMenuItem(nMenuItemNo, \sDevMapName, "", #False)
        If \sDevMapName = grProd\sSelectedDevMapName
          SetMenuItemState(#WMN_mnuDevMap, nMenuItemNo, #True)
        EndIf
        \nMenuItemNo = nMenuItemNo
        nMenuItemNo + 1
      EndIf
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_buildPopupMenu_Help()
  PROCNAMEC()
  ; debugMsg(sProcName, #SCS_START)
  If scsCreatePopupMenu(#WMN_mnuHelp)
    WMN_buildMenuGroup_Help()
  EndIf
EndProcedure

Procedure WMN_buildPopupMenu_View()
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START)
  If scsCreatePopupMenu(#WMN_mnuView)
    WMN_buildMenuGroup_View()
  EndIf
EndProcedure

Procedure WMN_buildPopupMenu_Navigate()
  PROCNAMEC()
  ; debugMsg(sProcName, #SCS_START)
  If scsCreatePopupMenu(#WMN_mnuNavigate)
    WMN_buildMenuGroup_Navigate()
  EndIf
EndProcedure

Procedure WMN_mnuDevMapItem_Click()
  PROCNAMEC()
  Protected n, sDevMapName.s
  Protected sTitle.s, sMsg.s, nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  With grMaps
    For n = 0 To \nMaxMapIndex
      If \aMap(n)\nMenuItemNo = gnEventMenu
        sDevMapName = \aMap(n)\sDevMapName
        Break
      EndIf
    Next n
  EndWith
  debugMsg(sProcName, "sDevMapName=" + sDevMapName)
  
  With grCED
    If (sDevMapName) And (sDevMapName <> grProd\sSelectedDevMapName)
      sTitle = Lang("Menu", "mnuDevMap")
      sMsg = LangPars("DevMap", "ChangeDevMap", grProd\sSelectedDevMapName, sDevMapName)
      nResponse = scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nResponse = #PB_MessageRequester_Yes
        debugMsg(sProcName, "nResponse=Yes")
        \sNewDevMapName = sDevMapName
        \bChangeDevMap = #True
        \bDisplayApplyMsg = #False  ; may be set #True later
        WMN_callEditor(#True)
        debugMsg(sProcName, "returned from WMN_callEditor(), \bDisplayApplyMsg=" + strB(\bDisplayApplyMsg))
        WED_refreshTBSButtons()   ; see comment at start of WED_refreshTBSButton(nButtonType)
        WED_refreshMiscButtons()  ; see comment at start of WED_refreshTBSButton(nButtonType)
        WMN_buildPopupMenu_DevMap() ; rebuild devmap popup menu to reset the selected devmap
        If \bDisplayApplyMsg
          setToolBarBtnEnabled(#SCS_TBMB_DEVMAP, #False)
          sMsg = LangPars("DevMap", "ApplyDevMapChg", GGT(WEP\btnApplyDevChgs), GGT(WEP\btnUndoDevChgs))
          scsMessageRequester(sTitle, sMsg, #MB_ICONEXCLAMATION)
          If IsWindow(#WED)
            SAW(#WED)
            WED_publicNodeClick(grProd\nNodeKey)
            SGS(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
            setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_AUD_DEVS)
            WEP_pnlDevs_Click()
          EndIf
        EndIf
        grMVUD\bDevMapDisplayed = #False
        grMVUD\bDevMapCurrentlyDisplayed = #False
      Else
        debugMsg(sProcName, "nResponse=No")
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_displayOrHideMemoPanel()
  PROCNAMEC()
  Protected bDisplayMemoPanel, bDisplayPopup
  Protected nCuelistMemoSplitterPos, bEnableCuelistMemoSplitter
  Protected nMainMemoSplitterPos, bEnableMainMemoSplitter
  
  debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  Select grProd\nMemoDispOptForPrim
    Case #SCS_MEMO_DISP_PRIM_POPUP
      bDisplayPopup = #True
    Case #SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST, #SCS_MEMO_DISP_PRIM_SHARE_MAIN
      setMemoScreen1InUseInd()
      If grWMN\bMemoScreen1InUse
        bDisplayMemoPanel = #True
      EndIf
  EndSelect
  
  With WMN
    Select grProd\nMemoDispOptForPrim
      Case #SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST
        If bDisplayMemoPanel
          bEnableCuelistMemoSplitter = #True
          If gnOperMode = #SCS_OPERMODE_DESIGN
            nCuelistMemoSplitterPos = grWMN\nCuelistMemoSplitterPosD
          Else
            nCuelistMemoSplitterPos = grWMN\nCuelistMemoSplitterPosP
          EndIf
          If (nCuelistMemoSplitterPos = GadgetWidth(\cntNorth)) And (gnPrefsReadBuild < 20190510)
            nCuelistMemoSplitterPos = -1
          EndIf
          If nCuelistMemoSplitterPos < 0
            nCuelistMemoSplitterPos = Round(GadgetWidth(\cntNorth) * 0.8, #PB_Round_Nearest)
            If (nCuelistMemoSplitterPos < 600) And (GadgetWidth(\cntNorth) > 700)
              nCuelistMemoSplitterPos = 600
            EndIf
          EndIf
          If GGS(\splCueListMemo) <> nCuelistMemoSplitterPos
            SGS(\splCueListMemo, nCuelistMemoSplitterPos)
            If gnOperMode = #SCS_OPERMODE_DESIGN
              grWMN\nCuelistMemoSplitterPosD = nCuelistMemoSplitterPos
            ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
              grWMN\nCuelistMemoSplitterPosR = nCuelistMemoSplitterPos
            Else
              grWMN\nCuelistMemoSplitterPosP = nCuelistMemoSplitterPos
            EndIf
          EndIf
        EndIf
        
      Case #SCS_MEMO_DISP_PRIM_SHARE_MAIN
        If bDisplayMemoPanel
          bEnableMainMemoSplitter = #True
          If gnOperMode = #SCS_OPERMODE_DESIGN
            nMainMemoSplitterPos = grWMN\nMainMemoSplitterPosD
          ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
            nMainMemoSplitterPos = grWMN\nMainMemoSplitterPosR
          Else
            nMainMemoSplitterPos = grWMN\nMainMemoSplitterPosP
          EndIf
          ; added 10May2019 11.8.1rc2 to fix a bug in 11.8.1rc1
          If (nMainMemoSplitterPos = WindowWidth(#WMN)) And (gnPrefsReadBuild < 20190510)
            nMainMemoSplitterPos = -1
          EndIf
          ; end added 10May2019 11.8.1rc2
          If nMainMemoSplitterPos < (WindowWidth(#WMN) >> 1) ; test modified 19Nov2019 11.8.2rc5 to overcome some issue that I haven't resolved that seems to cause the memo width to be the larger width
            nMainMemoSplitterPos = Round(WindowWidth(#WMN) * 0.8, #PB_Round_Nearest)
            If (nMainMemoSplitterPos < 600) And (WindowWidth(#WMN) > 700)
              nMainMemoSplitterPos = 600
            EndIf
          EndIf
          If GGS(\splMainMemo) <> nMainMemoSplitterPos
            SGS(\splMainMemo, nMainMemoSplitterPos)
            If gnOperMode = #SCS_OPERMODE_DESIGN
              grWMN\nMainMemoSplitterPosD = nMainMemoSplitterPos
            ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
              grWMN\nMainMemoSplitterPosR = nMainMemoSplitterPos
            Else
              grWMN\nMainMemoSplitterPosP = nMainMemoSplitterPos
            EndIf
          EndIf
        EndIf
        
    EndSelect
    
    ; the following is performed outside of the above tests of grProd\nMemoDispOptForPrim to handle setting up the screen for a new cue file
    ; after the previously-opened cue file had memo cues, but the new cue file does not.
    ; this means we may need to hide the relevant splitters that were displayed for the previous cue file.
    
    ; initially assign the dummy containers so we don't get a clash, eg that \cntMemo is simultaneously assigned to both \splCueListMemo and \splMainMemo
    SGA(\splCueListMemo, #PB_Splitter_FirstGadget, \cntDummyFirstForCueListMemoSplitter)
    SGA(\splCueListMemo, #PB_Splitter_SecondGadget, \cntDummySecondForCueListMemoSplitter)
    setVisible(\splCueListMemo, #False)
    setEnabled(\splCueListMemo, #False)
    
    SGA(\splMainMemo, #PB_Splitter_FirstGadget, \cntDummyFirstForMainMemoSplitter)
    SGA(\splMainMemo, #PB_Splitter_SecondGadget, \cntDummySecondForMainMemoSplitter)
    setVisible(\splMainMemo, #False)
    setEnabled(\splMainMemo, #False)
    
    debugMsg(sProcName, "bEnableCuelistMemoSplitter=" + strB(bEnableCuelistMemoSplitter) + ", bEnableMainMemoSplitter=" + strB(bEnableMainMemoSplitter))
    ; now assign the required gadgets to the splitters where necessary
    If bEnableCuelistMemoSplitter
      SGA(\splCueListMemo, #PB_Splitter_FirstGadget, \grdCues)
      SGA(\splCueListMemo, #PB_Splitter_SecondGadget, \cntMemo)
      WEN_drawTitleBarForMainMemoPanel(grMain\nMainMemoSubPtr)
      setVisible(\splCueListMemo, #True)
      setEnabled(\splCueListMemo, #True)
    EndIf
    
    If bEnableMainMemoSplitter
      SGA(\splMainMemo, #PB_Splitter_FirstGadget, \splNorthSouth)
      SGA(\splMainMemo, #PB_Splitter_SecondGadget, \cntMemo)
      WEN_drawTitleBarForMainMemoPanel(grMain\nMainMemoSubPtr)
      setVisible(\splMainMemo, #True)
      setEnabled(\splMainMemo, #True)
      ResizeGadget(\splNorthSouth, #PB_Ignore, 0, #PB_Ignore, #PB_Ignore) ; \splNorthSouth is now inside \splMainMemo
    Else
      ResizeGadget(\splNorthSouth, #PB_Ignore, GadgetY(\splMainMemo), #PB_Ignore, #PB_Ignore) ; \splNorthSouth NOT inside \splMainMemo
    EndIf
    
    If bEnableCuelistMemoSplitter Or bEnableMainMemoSplitter
      setVisible(\cntMemo, #True)
    Else
      setVisible(\cntMemo, #False)
    EndIf
    
    If bDisplayPopup
      If grMain\nMainMemoSubPtr >= 0
        debugMsg(sProcName, "calling WEN_Form_Show(#WE1, " + getSubLabel(grMain\nMainMemoSubPtr) + ")")
        WEN_Form_Show(#WE1, grMain\nMainMemoSubPtr)
      EndIf
    Else
      If grWEN\nMainSubPtr >= 0
        WEN_closeMemoWindowsIfOpen(#True)
      EndIf
    EndIf
    
    debugMsg(sProcName, "calling setVidPicTargets(#True, #True)")
    setVidPicTargets(#True, #True)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning bDisplayMemoPanel=" + strB(bDisplayMemoPanel))
  ProcedureReturn bDisplayMemoPanel

EndProcedure

Procedure WMN_cvsMemoTitleBar_MouseMove()
  ; PROCNAMEC()
  Protected X, bHot
  
  With grMain
    If \bMainMemoCloseButtonVisible And \nMainMemoSubPtr >= 0
      X = GGA(WMN\cvsMemoTitleBar, #PB_Canvas_MouseX)
      If X >= \nMainMemoCloseButtonLeft
        bHot = #True
      EndIf
      ; debugMsg(sProcName, "calling WEN_drawTitleBarForMainMemoPanel(" + getSubLabel(\nMainMemoSubPtr) + ", " + strB(bHot) + ")")
      WEN_drawTitleBarForMainMemoPanel(\nMainMemoSubPtr, bHot)
    EndIf
  EndWith
  
EndProcedure

Procedure WMN_cvsMemoTitleBar_MouseLeave()
  ; PROCNAMEC()
  
  With grMain
    If \bMainMemoCloseButtonVisible And \nMainMemoSubPtr >= 0
      ; debugMsg(sProcName, "calling WEN_drawTitleBarForMainMemoPanel(" + getSubLabel(\nMainMemoSubPtr) + ", #False)")
      WEN_drawTitleBarForMainMemoPanel(\nMainMemoSubPtr, #False)
    EndIf
  EndWith
  
EndProcedure

Procedure WMN_cvsMemoTitleBar_LeftClick()
  ; PROCNAMEC()
  Protected X, bClose
  
  With grMain
    If \bMainMemoCloseButtonVisible And \nMainMemoSubPtr >= 0
      X = GGA(WMN\cvsMemoTitleBar, #PB_Canvas_MouseX)
      If X >= \nMainMemoCloseButtonLeft
        bClose = #True
      EndIf
      If bClose
        ; cloned from code in WEN_EventHandler() for \cvsCloseIcon
        If (aSub(\nMainMemoSubPtr)\bSubTypeE) And (aSub(\nMainMemoSubPtr)\nSubState < #SCS_CUE_COMPLETED)
          stopSub(\nMainMemoSubPtr, "E", #True, #False)
        EndIf
        ; end of cloned code
      EndIf
      WMN_clearMainMemoIfReqd(\nMainMemoSubPtr)
    EndIf
  EndWith
EndProcedure

Procedure WMN_clearMainMemoIfReqd(pSubPtr)
  ; PROCNAMECS(pSubPtr)
  
  With grMain
    If \nMainMemoSubPtr = pSubPtr
      WMN\rchMainMemoObject\Clear()
      WMN\rchMainMemoObject\SetCtrlBackColor(#SCS_Black)
      ; debugMsg(sProcName, "calling WEN_drawTitleBarForMainMemoPanel(-1)")
      WEN_drawTitleBarForMainMemoPanel(-1)
      UpdateWindow_(WindowID(#WMN))
      \nMainMemoSubPtr = -1
    EndIf
  EndWith
  
EndProcedure

Procedure WMN_resizeGadgetsForSplitters(bInSplitterEvent=#False)
  PROCNAMEC()
  Protected nTop, nWidth, nHeight, bReloadCuePanels, bCueListMemoVisible, bMainMemoVisible
  Protected nScrollAreaGadgetWidth, nScrollAreaInnerWidth, nGadgetPropsIndex, n
  Protected bTrace = #cTraceGadgets
  
  debugMsgC(sProcName, #SCS_START + ", bInSplitterEvent=" + strB(bInSplitterEvent))
  
  With WMN
;     debugMsg(sProcName, "getVisible(\splNorthSouth)=" + strB(getVisible(\splNorthSouth)) + ", GGA(\splNorthSouth, #PB_Splitter_FirstGadget)=" + getGadgetName(GGA(\splNorthSouth, #PB_Splitter_FirstGadget)) +
;                         ", GGA(\splNorthSouth, #PB_Splitter_SecondGadget)=" + getGadgetName(GGA(\splNorthSouth, #PB_Splitter_SecondGadget)))
;     
;     debugMsg(sProcName, "GGS(\splCueListMemo)=" + GGS(WMN\splCueListMemo))
;     debugMsg(sProcName, "GadgetWidth(\splCueListMemo)=" + GadgetWidth(\splCueListMemo) + ", GadgetHeight(\splCueListMemo)=" + GadgetHeight(\splCueListMemo) + ", GGS(\splCueListMemo)=" + GGS(\splCueListMemo))
;     debugMsg(sProcName, "GadgetX(\grdCues)=" + GadgetX(\grdCues) + ", GadgetY(\grdCues)=" + GadgetY(\grdCues) + ", GadgetWidth(\grdCues)=" + GadgetWidth(\grdCues) + ", GadgetHeight(\grdCues)=" + GadgetHeight(\grdCues))
;     debugMsg(sProcName, "GadgetX(\cntMemo)=" + GadgetX(\cntMemo) + ", GadgetY(\cntMemo)=" + GadgetY(\cntMemo) + ", GadgetWidth(\cntMemo)=" + GadgetWidth(\cntMemo) + ", GadgetHeight(\cntMemo)=" + GadgetHeight(\cntMemo))
;     
;     debugMsg(sProcName, "getVisible(\splCueListMemo)=" + strB(getVisible(\splCueListMemo)) + ", GGA(\splCueListMemo, #PB_Splitter_FirstGadget)=" + getGadgetName(GGA(\splCueListMemo, #PB_Splitter_FirstGadget)) +
;                         ", GGA(\splCueListMemo, #PB_Splitter_SecondGadget)=" + getGadgetName(GGA(\splCueListMemo, #PB_Splitter_SecondGadget)))
;     debugMsg(sProcName, "getVisible(\splMainMemo)=" + strB(getVisible(\splMainMemo)) + ", GGA(\splMainMemo, #PB_Splitter_FirstGadget)=" + getGadgetName(GGA(\splMainMemo, #PB_Splitter_FirstGadget)) +
;                         ", GGA(\splMainMemo, #PB_Splitter_SecondGadget)=" + getGadgetName(GGA(\splMainMemo, #PB_Splitter_SecondGadget)))
    
    ; \splNorthSouth
    If GGA(\splMainMemo, #PB_Splitter_FirstGadget) = \splNorthSouth
      ; \splNorthSouth auto-sized
      bMainMemoVisible = #True
    Else
      nWidth = WindowWidth(#WMN)
      If GadgetWidth(\splNorthSouth) <> nWidth
        ResizeGadget(\splNorthSouth, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
        debugMsgC(sProcName, "ResizeGadget(\splNorthSouth, #PB_Ignore, #PB_Ignore, " + nWidth + ", #PB_Ignore)")
      EndIf
    EndIf
    
    ; \splCueListMemo
    If GGA(\splCueListMemo, #PB_Splitter_FirstGadget) = \grdCues
      ; \splCueListMemo in use so resize to fit \cntNorth
      nWidth = GadgetWidth(\cntNorth)
      nHeight = GadgetHeight(\cntNorth)
      If GadgetWidth(\splCueListMemo) <> nWidth Or GadgetHeight(\splCueListMemo) <> nHeight
        ResizeGadget(\splCueListMemo, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
        debugMsgC(sProcName, "ResizeGadget(\splCueListMemo, #PB_Ignore, #PB_Ignore, " + nWidth + ", " + nHeight + ")")
      EndIf
    EndIf
    
    ; \grdCues
    If GGA(\splCueListMemo, #PB_Splitter_FirstGadget) = \grdCues
      ; \grdCues auto-sized
      bCueListMemoVisible = #True
    Else
      nWidth = GadgetWidth(\cntNorth)
      nHeight = GadgetHeight(\cntNorth)
      If GadgetWidth(\grdCues) <> nWidth Or GadgetHeight(\grdCues) <> nHeight
        ResizeGadget(\grdCues, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
        debugMsgC(sProcName, "ResizeGadget(\grdCues, #PB_Ignore, #PB_Ignore, " + nWidth + ", " + nHeight + ")")
      EndIf
    EndIf
    
    ; \splPanelsHotkeys
    If GGA(\splMainMemo, #PB_Splitter_FirstGadget) = \splPanelsHotkeys
      ; \splPanelsHotkeys auto-sized
    Else
      nWidth = GadgetWidth(\cntSouth)
      nHeight = GadgetHeight(\cntSouth)
      If GadgetWidth(\splPanelsHotkeys) <> nWidth Or GadgetHeight(\splPanelsHotkeys) <> nHeight
        ResizeGadget(\splPanelsHotkeys, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
        debugMsgC(sProcName, "ResizeGadget(\splPanelsHotkeys, #PB_Ignore, #PB_Ignore, " + nWidth + ", " + nHeight + ")")
      EndIf
    EndIf
    
    ; \scaCuePanels
    If GGA(\splPanelsHotkeys, #PB_Splitter_FirstGadget) = \scaCuePanels
      ; \scaCuePanels auto-sized
      bReloadCuePanels = #True
    Else
      nWidth = GadgetWidth(\cntSouth)
      nHeight = GadgetHeight(\cntSouth)
      If GadgetWidth(\scaCuePanels) <> nWidth Or GadgetHeight(\scaCuePanels) <> nHeight
        ResizeGadget(\scaCuePanels, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
        debugMsgC(sProcName, "ResizeGadget(\scaCuePanels, #PB_Ignore, #PB_Ignore, " + nWidth + ", " + nHeight + ")")
        bReloadCuePanels = #True
      EndIf
    EndIf
    
    ; \cntMemo
    ; debugMsg(sProcName, "bMainMemoVisible=" + strB(bMainMemoVisible) + ", bCueListMemoVisible=" + strB(bCueListMemoVisible))
    If bMainMemoVisible Or bCueListMemoVisible
      ; nb \cntMemo will have been auto-sized as it is the 'second gadget' of \splMainMemo or \splCueListMemo
      nWidth = GadgetWidth(\cntMemo)
      nHeight = GadgetHeight(\cntMemo) - GadgetHeight(\cvsMemoTitleBar)
      If \rchMainMemoObject\GetWidth() <> nWidth Or \rchMainMemoObject\GetHeight() <> nHeight
        \rchMainMemoObject\Resize(#PB_Ignore, #PB_Ignore, nWidth, nHeight)
        debugMsgC(sProcName, "\rchMainMemoObject\Resize(#PB_Ignore, #PB_Ignore, " + nWidth + ", " + nHeight + ")")
        WEN_drawTitleBarForMainMemoPanel(grMain\nMainMemoSubPtr)
      EndIf
    EndIf
    
    If bReloadCuePanels
      nScrollAreaGadgetWidth = GadgetWidth(\scaCuePanels)
      nScrollAreaInnerWidth = nScrollAreaGadgetWidth - glScrollBarWidth - gl3DBorderAllowanceX
      If (GGA(\scaCuePanels, #PB_ScrollArea_InnerWidth) <> nScrollAreaInnerWidth) Or (GadgetHeight(\scaCuePanels) <> GadgetHeight(\cntSouth))
        SGA(\scaCuePanels, #PB_ScrollArea_InnerWidth, nScrollAreaInnerWidth)
        nGadgetPropsIndex = getGadgetPropsIndex(\scaCuePanels)
        gfMainPnlXFactor = GadgetWidth(\scaCuePanels) / gaGadgetProps(nGadgetPropsIndex)\nOrigWidth
        ; debugMsg(sProcName, "gfMainXFactor=" + StrF(gfMainXFactor,4) + ", gfMainYFactor=" + StrF(gfMainYFactor,4) + ", gfMainPnlXFactor=" + StrF(gfMainPnlXFactor,4))
        For n = 0 To gnMaxCuePanelCreated
          If PNL_InUse(n)
            WMN_resizeOneCuePanel(n)
          EndIf
        Next n
        ; sizes and positions reinstated based on original sizes and positions so reinstate "bHotkeysCurrentlyDisplayed = #True" so that displayOrHideHotkeys adjusted according to reinstated positions
        grWMN\bHotkeysCurrentlyDisplayed = #True
        WMN_displayOrHideHotkeys(bInSplitterEvent)
      EndIf
    EndIf
    
;     debugMsg(sProcName, "GadgetWidth(\splNorthSouth)=" + GadgetWidth(\splNorthSouth) + ", GadgetHeight(\splNorthSouth)=" + GadgetHeight(\splNorthSouth) + ", GGS(\splCueListMemo)=" + GGS(\splNorthSouth))
;     debugMsg(sProcName, "GadgetX(\cntNorth)=" + GadgetX(\cntNorth) + ", GadgetY(\cntNorth)=" + GadgetY(\cntNorth) + ", GadgetWidth(\cntNorth)=" + GadgetWidth(\cntNorth) + ", GadgetHeight(\cntNorth)=" + GadgetHeight(\cntNorth))
;     debugMsg(sProcName, "GadgetWidth(\splCueListMemo)=" + GadgetWidth(\splCueListMemo) + ", GadgetHeight(\splCueListMemo)=" + GadgetHeight(\splCueListMemo) + ", GGS(\splCueListMemo)=" + GGS(\splCueListMemo))
;     debugMsg(sProcName, "GadgetX(\grdCues)=" + GadgetX(\grdCues) + ", GadgetY(\grdCues)=" + GadgetY(\grdCues) + ", GadgetWidth(\grdCues)=" + GadgetWidth(\grdCues) + ", GadgetHeight(\grdCues)=" + GadgetHeight(\grdCues))
;     debugMsg(sProcName, "GadgetX(\cntMemo)=" + GadgetX(\cntMemo) + ", GadgetY(\cntMemo)=" + GadgetY(\cntMemo) + ", GadgetWidth(\cntMemo)=" + GadgetWidth(\cntMemo) + ", GadgetHeight(\cntMemo)=" + GadgetHeight(\cntMemo))
;     debugMsg(sProcName, "GadgetX(\cntSouth)=" + GadgetX(\cntSouth) + ", GadgetY(\cntSouth)=" + GadgetY(\cntSouth) + ", GadgetWidth(\cntSouth)=" + GadgetWidth(\cntSouth) + ", GadgetHeight(\cntSouth)=" + GadgetHeight(\cntSouth))
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WMN_getMemoWidth()
  PROCNAMEC()
  Protected nMemoWidth = -1
  
  With WMN
    If (GGA(\splCueListMemo, #PB_Splitter_SecondGadget) = \cntMemo) And (getVisible(\splCueListMemo))
      If gnOperMode = #SCS_OPERMODE_DESIGN
        nMemoWidth = GadgetWidth(\splCueListMemo) - grWMN\nCuelistMemoSplitterPosD
      ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
        nMemoWidth = GadgetWidth(\splCueListMemo) - grWMN\nCuelistMemoSplitterPosR
      Else
        nMemoWidth = GadgetWidth(\splCueListMemo) - grWMN\nCuelistMemoSplitterPosP
      EndIf
    ElseIf (GGA(\splMainMemo, #PB_Splitter_SecondGadget) = \cntMemo) And (getVisible(\splMainMemo))
      If gnOperMode = #SCS_OPERMODE_DESIGN
        nMemoWidth = GadgetWidth(\splMainMemo) - grWMN\nMainMemoSplitterPosD
      ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
        nMemoWidth = GadgetWidth(\splMainMemo) - grWMN\nMainMemoSplitterPosR
      Else
        nMemoWidth = GadgetWidth(\splMainMemo) - grWMN\nMainMemoSplitterPosP
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning " + nMemoWidth)
  ProcedureReturn nMemoWidth
EndProcedure

Procedure WMN_getPrevRowForHiddenCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nRowNo, i
  
  For i = pCuePtr To 1 Step -1
    With aCue(i)
      If \bCueEnabled
        Select \nHideCueOpt
          Case  #SCS_HIDE_NO, #SCS_HIDE_CUE_PANEL
            If \nGrdCuesRowNo >= 0
              debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nGrdCuesRowNo=" + \nGrdCuesRowNo)
              nRowNo = \nGrdCuesRowNo
              Break
            EndIf
        EndSelect
      EndIf
    EndWith
  Next i
  ; nb returns 0 if no previous displayed cue found
  ProcedureReturn nRowNo
EndProcedure

Procedure WMN_isGoEnabled()
  PROCNAMEC()
  Protected bGoEnabled
  
  If grOperModeOptions(gnOperMode)\nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
    bGoEnabled = gbMenuItemEnabled(#WMN_mnuGo)
  Else
    bGoEnabled = getToolBarBtnEnabled(#SCS_TBMB_GO)
  EndIf
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bGoEnabled))
  ProcedureReturn bGoEnabled
  
EndProcedure

Procedure WMN_doCtrlPanelPosition()
  ; PROCNAMEC()
  Protected bCtrlPanelVisible, nCtrlPanelTop, nCtrlPanelHeight, nNorthSouthTop, nNorthSouthHeight
  
  ; debugMsg(sProcName, "WindowHeight(#WMN)=" + WindowHeight(#WMN))
  
  With WMN
    Select grOperModeOptions(gnOperMode)\nCtrlPanelPos
      Case #SCS_CTRLPANEL_BOTTOM
        bCtrlPanelVisible = #True
        nCtrlPanelHeight = GadgetHeight(\cntToolbarAndVU) + GadgetHeight(\cntGoAndMaster)
        nCtrlPanelTop = WindowHeight(#WMN) - GadgetHeight(\cvsStatusBar) - nCtrlPanelHeight
        nNorthSouthTop = 2 ; provides a 2-pixel border at the top
        nNorthSouthHeight = nCtrlPanelTop - nNorthSouthTop - 2 ; and at the bottom
        
      Case #SCS_CTRLPANEL_NONE
        bCtrlPanelVisible = #False
        nNorthSouthTop = 0
        nNorthSouthHeight = WindowHeight(#WMN) - GadgetHeight(\cvsStatusBar) - nNorthSouthTop
        
      Default ; #SCS_CTRLPANEL_TOP
        bCtrlPanelVisible = #True
        nCtrlPanelTop = 0
        nCtrlPanelHeight = GadgetHeight(\cntToolbarAndVU) + GadgetHeight(\cntGoAndMaster)
        nNorthSouthTop = nCtrlPanelTop + nCtrlPanelHeight
        nNorthSouthHeight = WindowHeight(#WMN) - GadgetHeight(\cvsStatusBar) - nNorthSouthTop
        
    EndSelect
    
    ; SetWindowColor(#WMN, #SCS_Black)
    
    If bCtrlPanelVisible
      If GadgetY(\cntCtrlPanel) <> nCtrlPanelTop Or GadgetHeight(\cntCtrlPanel) <> nCtrlPanelHeight
        ResizeGadget(\cntCtrlPanel, #PB_Ignore, nCtrlPanelTop, #PB_Ignore, nCtrlPanelHeight)
        ; debugMsg(sProcName, "ResizeGadget(\cntCtrlPanel, #PB_Ignore, " + nCtrlPanelTop + ", #PB_Ignore, " + nCtrlPanelHeight + ")")
      EndIf
    EndIf
    setVisible(\cntCtrlPanel, bCtrlPanelVisible)
    If GadgetY(\splNorthSouth) <> nNorthSouthTop Or GadgetHeight(\splNorthSouth) <> nNorthSouthHeight
      ResizeGadget(\splNorthSouth, #PB_Ignore, nNorthSouthTop, #PB_Ignore, nNorthSouthHeight)
      ; debugMsg(sProcName, "ResizeGadget(\splNorthSouth, #PB_Ignore, " + nNorthSouthTop + ", #PB_Ignore, " + nNorthSouthHeight + ")")
    EndIf
    If GadgetY(\splMainMemo) <> nNorthSouthTop Or GadgetHeight(\splMainMemo) <> nNorthSouthHeight
      ResizeGadget(\splMainMemo, #PB_Ignore, nNorthSouthTop, #PB_Ignore, nNorthSouthHeight)
      ; debugMsg(sProcName, "ResizeGadget(\splMainMemo, #PB_Ignore, " + nNorthSouthTop + ", #PB_Ignore, " + nNorthSouthHeight + ")")
    EndIf
    
  EndWith

EndProcedure

Procedure WMN_CheckOkToGoToCue(pCuePtr)
  PROCNAMEC()
  Protected sMsg.s, sButtons.s, sCue.s
  Protected nOption, bOKToGoToCue
  Static sGoToMsg1.s, sGoToMsg2.s, bStaticLoaded
  Static bYesAndDontAskMeAgain
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sGoToMsg1 = Lang("WMN", "GoToMsg1") ; "Do you want to go to cue $1 in the cue List?"
    sGoToMsg2 = Lang("WMN", "GoToMsg2") ; "Yes, go to cue $1|Yes, and don't ask me about this again this session|No - stay on cue $2"
    bStaticLoaded = #True
  EndIf
  
  If bYesAndDontAskMeAgain
    bOKToGoToCue = #True
  Else
    sCue = getCueLabel(pCuePtr)
    sMsg = grProd\sTitle + "|" + ReplaceString(sGoToMsg1, "$1", sCue)
    sButtons = ReplaceString(ReplaceString(sGoToMsg2, "$1", sCue), "$2", getCueLabel(gnCueToGo))
    nOption = OptionRequester(0, 0, sMsg, sButtons, 160, 0, #WMN, "", 0, 0, RGB(251,67,6), RGB(255,253,208), 16, 16) ; approx amber color background; cream text
    debugMsg(sProcName, sMsg + ", nOption=" + nOption)
    Select (nOption & $FFFF)
      Case 1 ; Yes
        bOKToGoToCue = #True
      Case 2 ; Yes, but do not ask again
        bOKToGoToCue = #True
        bYesAndDontAskMeAgain = #True
      Default ; 3 = No, 0 = Esc (treat as No)
        bOKToGoToCue = #False
        ; debugMsg(sProcName, "calling highlightLine(" + getCueLabel(gnCueToGo) + ")")
        highlightLine(gnCueToGo)
    EndSelect
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bOKToGoToCue))
  ProcedureReturn bOKToGoToCue
  
EndProcedure

Procedure WMN_mnuResetStepHKs_Click()
  PROCNAMEC()
  
  resetStepHotkeys(Lang("Menu", "mnuResetStepHKs"))
  SAG(-1)
  
EndProcedure

Procedure WMN_enableOrDisableResetStepHKs()
  PROCNAMEC()
  Protected i, bEnable, nParentMenu
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \nActivationMethod = #SCS_ACMETH_HK_STEP
        If \bCueEnabled And \nCueState <> #SCS_CUE_IGNORED
          bEnable = #True
          Break
        EndIf
      EndIf
    EndWith
  Next i
  If grOperModeOptions(gnOperMode)\nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
    nParentMenu = #WMN_mnuWindowMenu
  Else
    nParentMenu = #WMN_mnuNavigate
  EndIf
  ; debugMsg(sProcName, "calling scsEnableMenuItem(" + decodeMenuItem(nParentMenu) + ", #WMN_mnuResetStepHKs, " + strB(bEnable) + ")")
  scsEnableMenuItem(nParentMenu, #WMN_mnuResetStepHKs, bEnable)
  
EndProcedure

Procedure WMN_CloseAndReOpenDMXDevs_Click()
  PROCNAMEC()
  
  debugMsg0(sProcName, "calling DMX_closeDMXDevs()")
  DMX_closeDMXDevs()
  debugMsg0(sProcName, "calling DMX_openDMXDevs()")
  DMX_openDMXDevs()
  
  WMN_setStatusField("DMX Devices closed and re-opened")
  
EndProcedure

Procedure WMN_processAnimatedImageTimer(nWindowTimer)
  PROCNAMEC()
  Protected nAudPtr, nSubPtr
  Protected bLockedMutex
  Protected nVidPicTarget, nVideoCanvasNo
  Protected nMinVidPicTarget, nMaxVidPicTarget, bCheckScreenReqd, bDisplayOnThisVidPicTarget
  Protected nReqdLeft, nReqdTop, nReqdWidth, nReqdHeight
  Protected nLoadImageNo, nMainImage
;   Protected *mBuffer
;   Static nCounter
  
; debugMsg(sProcName, #SCS_START + ", nWindowTimer=" + nWindowTimer)
  
  RemoveWindowTimer(#WMN, nWindowTimer)
  
  nAudPtr = grWMN\nAnimatedTimerAudPtr(nWindowTimer)
; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr))
  
  If aAud(nAudPtr)\nAudState >= #SCS_CUE_FADING_IN And aAud(nAudPtr)\nAudState <= #SCS_CUE_FADING_OUT
    ; The variables grMMedia\bInBlendPictures and grMMedia\bAnimationWaiting were added to try to better share processing between the blender thread and this window timer.
    ; In a test of an animated GIF that was being played to two screens and which was being fade in and faded out, then the painting of frame images for the two screens
    ; could take longer than the frame delay time. That caused WMN_processAnimatedImageTimer() to be re-activated immediately on completion, and that typically occurred
    ; before the blender thread was able to lock the image mutex. Just relying on the mutex didn't seem to provide a satisfactory result.
    While grMMedia\bInBlendPictures
      grMMedia\bAnimationWaiting = #True ; This is checked by the blender thread, and tells the blender thread that WMN_processAnimatedImageTimer() is waiting to proceed.
      Delay(2)
    Wend
    LockImageMutex(282)
; debugMsg(sProcName, "ImageMutex Locked")
    grMMedia\bAnimationWaiting = #False
    
    With aAud(nAudPtr)
      If \bCancelAudAnimation
        ; nb must test \bCancelAudAnimation AFTER returning from LockImageMutex() because \bCancelAudAnimation may have been set in THR_runBlenderThread() while ImageMutex was locked,
        ; and therefore while this procedure (WMN_processAnimatedImageTimer()) was waiting for the lock to be released.
        debugMsg(sProcName, "exiting because aAud(" + getAudLabel(nAudPtr) + ")\bCancelAudAnimation=" + strB(\bCancelAudAnimation))
        UnlockImageMutex()
        ProcedureReturn
      EndIf
      nLoadImageNo = \nLoadImageNo
      \nSelectedFrameIndex + 1
      If \nSelectedFrameIndex >= \nImageFrameCount
        \nSelectedFrameIndex = 0
      EndIf
; debugMsg(sProcName, "calling SetImageFrame(" + decodeHandle(nLoadImageNo) + ", " + \nSelectedFrameIndex + ")" + ", ImageFrameCount(" + decodeHandle(nLoadImageNo) + ")=" + ImageFrameCount(nLoadImageNo))
      SetImageFrame(nLoadImageNo, \nSelectedFrameIndex)
; debugMsg(sProcName, "calling AddWindowTimer(#WMN, " + nWindowTimer + ", " + GetImageFrameDelay(nLoadImageNo) + ")")
      AddWindowTimer(#WMN, nWindowTimer, GetImageFrameDelay(nLoadImageNo))
      nSubPtr = \nSubIndex
    EndWith
    
    With aSub(nSubPtr)
      If \bStartedInEditor
        If gbPreviewOnOutputScreen
          nMinVidPicTarget = gnPreviewOnOutputScreenNo
          nMaxVidPicTarget = gnPreviewOnOutputScreenNo
        Else
          nMinVidPicTarget = #SCS_VID_PIC_TARGET_P
          nMaxVidPicTarget = #SCS_VID_PIC_TARGET_P
        EndIf
      Else
        nMinVidPicTarget = \nOutputScreen
        nMaxVidPicTarget = \nSubMaxOutputScreen
        bCheckScreenReqd = #True
      EndIf
    EndWith
    
    For nVidPicTarget = nMinVidPicTarget To nMaxVidPicTarget
      bDisplayOnThisVidPicTarget = #False
      If bCheckScreenReqd
        If aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
          bDisplayOnThisVidPicTarget = #True
        EndIf
      Else
        bDisplayOnThisVidPicTarget = #True
      EndIf
      If bDisplayOnThisVidPicTarget
        nMainImage = aAud(nAudPtr)\nVidPicTargetImageNo(nVidPicTarget)
        nReqdLeft = aAud(nAudPtr)\nDisplayLeft(nVidPicTarget)
        nReqdTop = aAud(nAudPtr)\nDisplayTop(nVidPicTarget)
        nReqdWidth = aAud(nAudPtr)\nDisplayWidth(nVidPicTarget)
        nReqdHeight = aAud(nAudPtr)\nDisplayHeight(nVidPicTarget)
        With grVidPicTarget(nVidPicTarget)
          If IsImage(nMainImage)
            If StartDrawing(ImageOutput(nMainImage))
              debugMsgD(sProcName, "StartDrawing(ImageOutput(" + decodeHandle(nMainImage) + "))")
              DrawImage(ImageID(nLoadImageNo), nReqdLeft, nReqdTop, nReqdWidth, nReqdHeight)
              debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nLoadImageNo) + "), " + nReqdLeft + ", " + nReqdTop + ", " + nReqdWidth + ", " + nReqdHeight + ")")
              ; DrawText(20, 20, FormatDate("%hh:%ii:%ss", Date()) + " FrameCount(" + decodeHandle(nLoadImageNo) + ")=" + ImageFrameCount(nLoadImageNo) + ", GetImageFrame(" + decodeHandle(nLoadImageNo) + ")=" + GetImageFrame(nLoadImageNo))
              StopDrawing()
              debugMsgD(sProcName, "StopDrawing()")
              ; debugMsg(sProcName, "ImageWidth(" + decodeHandle(nMainImage) + ")=" + ImageWidth(nMainImage) + ", ImageHeight(" + decodeHandle(nMainImage) + ")=" + ImageHeight(nMainImage))
              ; Added to check how much memory would be required if we were to save frame data in memory.
              ; The file "animated_twitter_.gif" would require about 11MB per frame for a 2560x1440 screen, and about 7MB per frame for a 1920x1200 screen.
;               If nCounter < 20
;                 *mBuffer = EncodeImage(nMainImage)
;                 If *mBuffer
;                   debugMsg(sProcName, "nMainImage=" + decodeHandle(nMainImage) + ", ImageWidth()=" + ImageWidth(nMainImage) + ", ImageHeight()=" + ImageHeight(nMainImage) + ", MemorySize(*mBuffer)=" + MemorySize(*mBuffer))
;                 EndIf
;                 nCounter + 1
;               EndIf
            EndIf
            If \nImage2 = 0 ; Or \nAudPtr2 < 0
              nVideoCanvasNo = \nTargetCanvasNo
              debugMsgV(sProcName, "calling StartDrawing(CanvasOutput(" + getGadgetName(nVideoCanvasNo) + "))")
              If StartDrawing(CanvasOutput(nVideoCanvasNo))
                debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nVideoCanvasNo) + "))")
                DrawImage(ImageID(nMainImage), 0, 0)
                debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nMainImage) + "), 0, 0)")
                StopDrawing()
                debugMsgD(sProcName, "StopDrawing()")
                If getVisible(nVideoCanvasNo) = #False
                  setVisible(nVideoCanvasNo, #True)
                EndIf
              Else
                debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + nVideoCanvasNo + ")) returned #False")
              EndIf
            EndIf
          Else
            debugMsg(sProcName, "IsImage(" + decodeHandle(nMainImage) + ") returned " + strB(IsImage(nMainImage)))
          EndIf
        EndWith
      EndIf
    Next nVidPicTarget
    
    UnlockImageMutex()
    
  EndIf
  
; debugMsg(sProcName, #SCS_END + ", ImageMutex Unlocked")
  
EndProcedure

Procedure WMN_mnuViewOperMode_Click(nEventMenu)
  PROCNAMEC()
  Protected nReqdOperMode, sTitle.s, sMessage.s, nResponse
  
  Select nEventMenu
    Case #WMN_mnuViewOperModeDesign
      nReqdOperMode = #SCS_OPERMODE_DESIGN
    Case #WMN_mnuViewOperModeRehearsal
      nReqdOperMode = #SCS_OPERMODE_REHEARSAL
    Case #WMN_mnuViewOperModePerformance
      nReqdOperMode = #SCS_OPERMODE_PERFORMANCE
  EndSelect
  If nReqdOperMode <> gnOperMode
    sTitle = Lang("Info", "OperMode")
    sMessage = LangPars("OperMode", "ChangeOperMode", decodeOperModeL(gnOperMode), decodeOperModeL(nReqdOperMode))
    nResponse = scsMessageRequester(sTitle, sMessage, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    If nResponse = #PB_MessageRequester_Yes
      gnOperMode = nReqdOperMode
      WMN_Form_Resize() ; call WMN_Form_Resize() as this implements any display changes required for the change of operational mode, eg changing the toolbar buttons displayed
      WMN_setViewOperModeMenuItems()
    EndIf
  EndIf
  
EndProcedure

; EOF