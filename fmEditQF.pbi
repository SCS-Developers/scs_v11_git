; File: fmEditQF.pbi (Audio File cue)

EnableExplicit

Procedure WQF_addDeviceIfReqd(nDevNo)
  PROCNAMECA(nEditAudPtr)
  Protected bDevPresent, nListIndex
  
  With aAud(nEditAudPtr)
    If nDevNo <= grLicInfo\nMaxAudDevPerAud
      SetGadgetText(WQF\lblDevNo[nDevNo], Str(nDevNo + 1))
      
      If nDevNo <= \nLastDev
        If \sLogicalDev[nDevNo]
          bDevPresent = #True
        EndIf
      EndIf
      
      If bDevPresent
        debugMsg(sProcName, "\sLogicalDev[" + nDevNo + "]=" + \sLogicalDev[nDevNo])
      EndIf
      nListIndex = indexForComboBoxRow(WQF\cboLogicalDevF[nDevNo], \sLogicalDev[nDevNo], 0)
      SGS(WQF\cboLogicalDevF[nDevNo], nListIndex)
      WQF_fcLogicalDev(nDevNo)
      
      SetFirstAndLastDev(nEditAudPtr)
      
      populateCboTracksForAud(WQF\cboTracks[nDevNo], nEditAudPtr, nDevNo)
      nListIndex = indexForComboBoxRow(WQF\cboTracks[nDevNo], \sTracks[nDevNo], -1)
      If (nListIndex = -1) And (bDevPresent)
        nListIndex = 0
      EndIf
      SGS(WQF\cboTracks[nDevNo], nListIndex)
      
      nListIndex = indexForComboBoxRow(WQF\cboTrim[nDevNo], \sDBTrim[nDevNo], -1)
      If (nListIndex = -1) And (bDevPresent)
        nListIndex = 0
      EndIf
      SetGadgetState(WQF\cboTrim[nDevNo], nListIndex)
      
      ; Added 2May2024 11.10.2ck
      If bDevPresent = #False
        \fDeviceTotalVolWork[nDevNo] = \fCueTotalVolNow[nDevNo]
        ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fDeviceTotalVolWork[" + nDevNo + "]=" + traceLevel(\fDeviceTotalVolWork[nDevNo]))
      EndIf
      ; End added 2May2024 11.10.2ck
      
      ; debugMsg(sProcName, "calling WQF_displayLevelAndPanForDev(" + d + ", " + strB(bDevPresent) + ")")
      WQF_displayLevelAndPanForDev(nDevNo, bDevPresent)
    EndIf
  EndWith
    
EndProcedure

Procedure WQF_setScaDevsInnerHeight()
  ; PROCNAMECA(nEditAudPtr)
  Protected nDisplayedDevs, nReqdInnerHeight
  
  nDisplayedDevs = aAud(nEditAudPtr)\nLastDev + 2 ; plus 2 because (1) \nLastDev is zero-based, and (2) an extra line is required to enable the user to select another device
  If nDisplayedDevs <= 0
    nDisplayedDevs = 1
  EndIf
  nReqdInnerHeight = nDisplayedDevs * 22 ; 22 = row height as used in createfmEditQF()
  ; debugMsg0(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nLastDev=" + aAud(nEditAudPtr)\nLastDev + ", nDisplayedDevs=" + nDisplayedDevs + ", nReqdInnerHeight=" + nReqdInnerHeight)
  SetGadgetAttribute(WQF\scaDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
  
EndProcedure

Procedure WQF_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected d, bResult
  Protected nListIndex, bAvailable
  Protected bFileInfoDisplayed
  Protected bDevPresent
  Protected nFirstExistingDevNo
  Protected nSameAsSubPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQFCreated = #False
    WQF_Form_Load()
  EndIf
  
  If aCue(nEditCuePtr)\nActivationMethod = #SCS_ACMETH_CALL_CUE And Trim(aCue(nEditCuePtr)\sCallableCueParams)
    WEC_applyCallableCueParams(nEditCuePtr, aCue(nEditCuePtr)\sCallableCueParams)
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQF\lblSubCueType, pSubPtr)
  
  clearCtrlHoldLP()
  
  bFileInfoDisplayed = #False
  rWQF\bChangingCurrPos = #False
  rWQF\nCurrDevNo = -1
  If aAud(nEditAudPtr)\nMaxLoopInfo >= 0
    rWQF\nDisplayedLoopInfoIndex = 0
  Else
    rWQF\nDisplayedLoopInfoIndex = -1
  EndIf
  ; debugMsg(sProcName, "rWQF\nDisplayedLoopInfoIndex=" + rWQF\nDisplayedLoopInfoIndex)
  
  ; propogate audio devs into logical dev combo boxes if reqd
  propogateProdDevs("F")
  
  If (grLicInfo\bVSTPluginsAvailable) And (gnCurrAudioDriver <> #SCS_DRV_SMS_ASIO)
    debugMsg(sProcName, "calling WQF_populateCboVSTPlugin()")
    WQF_populateCboVSTPlugin()
  EndIf

  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "F", WQF)
    setEditAudPtr(\nFirstAudIndex)
  EndWith
  
  WQF_initUnusedRelLevelEtcControls()
  
  With aAud(nEditAudPtr)
    debugMsg(sProcName, "nEditAudPtr=" + getAudLabel(nEditAudPtr) + ", \sFileTitle=" + \sFileTitle)
    
    SetGadgetText(WQF\txtFileName, \sStoredFileName)
    scsToolTip(WQF\txtFileName, \sFileName)
    debugMsg(sProcName, "\sFileType=" + \sFileType)
    WQF_populateFileTypeExt(nEditAudPtr)
    WQF_fcPlaceHolder()
    
    WQF_fcFileExt(#True)
    
    WQF_populateCboDevSel()
    SGS(WQF\cboDevSel, 0)
    
    setOwnState(WQF\chkAutoScroll, grEditorPrefs\bAutoScroll)
    
    nListIndex = indexForComboBoxData(WQF\cboGraphDisplayMode, grEditorPrefs\nGraphDisplayMode, 0)
    SGS(WQF\cboGraphDisplayMode, nListIndex)
    
    ; 17/09/2014 11.3.4: added nFirstExistingDevNo at request of Christian Peters to handle scenario of first device entry being blank
    nFirstExistingDevNo = 0
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      If \sLogicalDev[d]
        nFirstExistingDevNo = d
        Break
      EndIf
    Next d
    
    ;     debugMsg(sProcName, "calling WQF_setCurrentDevInfo(0, #False, #True, #True)")
    ;     WQF_setCurrentDevInfo(0, #False, #True, #True)
    debugMsg(sProcName, "calling WQF_setCurrentDevInfo(" + nFirstExistingDevNo + ", #False, #True, #True)")
    WQF_setCurrentDevInfo(nFirstExistingDevNo, #False, #True, #True)
    
    debugMsg(sProcName, "WQF\txtFileName=" + GetGadgetText(WQF\txtFileName))
    If Trim(GetGadgetText(WQF\txtFileName))
      If \nFileState = #SCS_FILESTATE_CLOSED
        debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
        setIgnoreDevInds(nEditAudPtr, #True)
        openMediaFile(nEditAudPtr)
        setSyncPChanListForAud(nEditAudPtr)
      EndIf
      debugMsg(sProcName, "\nFileState=" + decodeFileState(\nFileState))
      debugMsg(sProcName, "calling WQF_initGraphInfo()")
      WQF_initGraphInfo()
      If \nFileState = #SCS_FILESTATE_OPEN
        WQF_displayFileInfo()
        bFileInfoDisplayed = #True
      Else
        debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
      EndIf
    Else
      debugMsg(sProcName, "calling WQF_initGraphInfo()")
      WQF_initGraphInfo()
      debugMsg(sProcName, "calling drawWholeGraphArea()")
      drawWholeGraphArea()
    EndIf
    
    If bFileInfoDisplayed = #False
      debugMsg(sProcName, "calling WQF_displayFileInfo")
      WQF_displayFileInfo()
      bFileInfoDisplayed = #True
    EndIf
    
    rWQF\bDisplayingLevelPoint = #False
    ; debugMsg0(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint))
    
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      WQF_addDeviceIfReqd(d)
    Next d
    WQF_setScaDevsInnerHeight()
    
    debugMsg(sProcName, "calling WQF_setClearState()")
    WQF_setClearState()
    
    WQF_processDevSel()
    
    CompilerIf #c_minimal_vst
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_AUD, " + getAudLabel(nEditAudPtr) + ", " + decodeHandle(aAud(nEditAudPtr)\nVSTHandle) + ", #True)")
      WPL_showVSTEditor(#SCS_VST_HOST_AUD, nEditAudPtr, aAud(nEditAudPtr)\nVSTHandle, #True)
    CompilerElse
      If grWPL\bPluginShowing
        debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(grWPL\nVSTHandleForPluginShowing) + ", #False)")
        WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, grWPL\nVSTHandleForPluginShowing, #False) ; remove any existing display of the plugin
      EndIf
      nSameAsSubPtr = VST_setReqdPluginInfo(nEditAudPtr) ; returns subptr if 'same as cue/subno' requested and found, else returns -1
      debugMsg(sProcName, "calling VST_loadAudVSTPlugin(" + getAudLabel(nEditAudPtr) + ")")
      If VST_loadAudVSTPlugin(nEditAudPtr) Or \sVSTReqdPluginName
        If nSameAsSubPtr = -1
          SGT(WQF\cboVSTPlugin, \sVSTPluginName)
        Else
          setComboBoxByData(WQF\cboVSTPlugin, nSameAsSubPtr)
        EndIf
        WQF_showVST(#True)
        setOwnState(WQF\chkBypassVST,aAud(nEditAudPtr)\bVSTBypass)
      Else
        SGT(WQF\cboVSTPlugin, \sVSTReqdPluginName) 
        WQF_showVST(#False)
      EndIf
    CompilerEndIf
    
    \bCheckProgSlider = #False
    debugMsg(sProcName, "calling editSetDisplayButtonsF()")
    editSetDisplayButtonsF()
    
    WQF_refreshTempoEtcInfo()
    rWQF\bCallSetOrigDBLevels = #True
    
    gbCallEditUpdateDisplay = #True
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_UsedAllCueMarkers(nMaxValue)
  
  If (gnMaxCueMarkerInfo + 1) >= nMaxValue
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure

Procedure WQF_checkSelectedAudioFileInList()
  Protected n, bResult
  
  For n = 0 To gnMaxCueMarkerFile
    With gaCueMarkerFile(n)
      If (\nAudPtr = nEditAudPtr) And (\sFileName = aAud(nEditAudPtr)\sFileName)
        bResult = #True
        Break
      EndIf
    EndWith
  Next n
  ProcedureReturn bResult
EndProcedure

Procedure WQF_chkAudioFileHasMarkers(pAudPtr)
  PROCNAMEC()
  Protected bResult
  
  If aAud(pAudPtr)\nMaxCueMarker >= 0
    bResult = #True
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure WQF_displayFileInfo(bInitZoomAndPos=#True, bTimesEtcOnly=#False)
  PROCNAMECA(nEditAudPtr)
  ; see also WQF_refreshFileInfo()
  Protected nFileDuration, nLeft
  
  ;   debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    nFileDuration = \nFileDuration
    
    If bTimesEtcOnly = #False
      WQF_populateFileTypeExt(nEditAudPtr)
    EndIf
    
    SGT(WQF\txtCueDuration, timeToStringBWZT(\nCueDuration, nFileDuration))
    ; debugMsg(sProcName, "\nFileDuration=" + \nFileDuration + ", \nCueDuration=" + \nCueDuration + ", GGT(WQF\txtCueDuration)=" + GGT(WQF\txtCueDuration))
    
    If \dStartAtCPTime >= 0.0
      SGT(WQF\txtStartAt, timeDblToStringHT(\dStartAtCPTime, nFileDuration))
    Else
      SGT(WQF\txtStartAt, timeToStringBWZT(\nStartAt, nFileDuration))
    EndIf
    
    If \dEndAtCPTime >= 0.0
      SGT(WQF\txtEndAt, timeDblToStringHT(\dEndAtCPTime, nFileDuration))
    Else
      SGT(WQF\txtEndAt, timeToStringBWZT(\nEndAt, nFileDuration))
    EndIf
    
    SGT(WQF\txtCurrPos, timeToStringT((\nRelFilePos + \nAbsMin), nFileDuration))
    
    If grProd\nVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
      setVisible(WQF\lblCuePosTimeOffset, #True)
      setVisible(WQF\txtCuePosTimeOffset, #True)
      SGT(WQF\txtCuePosTimeOffset, timeToStringT(\nCuePosTimeOffset, nFileDuration))
      nLeft = GadgetX(WQF\txtCuePosTimeOffset) + GadgetWidth(WQF\txtCuePosTimeOffset) + gnGap2
    Else
      setVisible(WQF\lblCuePosTimeOffset, #False)
      setVisible(WQF\txtCuePosTimeOffset, #False)
      nLeft = GadgetX(WQF\lblStartAt)
    EndIf
    ResizeGadget(WQF\lblTempoEtcInfo, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    
    grMG2\nLastTimeMark = (\nRelFilePos + \nAbsMin)
    ; debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
    WQF_fcLevelPointInfo()
    
    ; SGT(WQF\txtFadeInTime, timeToStringBWZT(\nFadeInTime))
    ; SGT(WQF\txtFadeOutTime, timeToStringBWZT(\nFadeOutTime))
    SGT(WQF\txtFadeInTime, makeDisplayTimeValueBWZT(\sFadeInTime, \nFadeInTime))
    SGT(WQF\txtFadeOutTime, makeDisplayTimeValueBWZT(\sFadeOutTime, \nFadeOutTime))
    
    setOwnState(WQF\chkLoopLinked, \bLoopLinked)  ; added 2Nov2015 11.4.1.2g
    
    ; debugMsg(sProcName, "calling WQF_setTimeFieldEnabledStates()")
    WQF_setTimeFieldEnabledStates()
    
    ; debugMsg(sProcName, "calling WQF_setClearState")
    WQF_setClearState()
    
    SLD_setMax(WQF\sldProgress, (\nCueDuration-1))
    SLD_setValue(WQF\sldProgress, 0)
    
    If bInitZoomAndPos
      ; debugMsg(sProcName, "calling SGS(WQF\trbZoom, 1)")
      SGS(WQF\trbZoom, 1)
      debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom) + ", calling WQF_processZoom(#True)")
      WQF_processZoom(#True)
      SLD_setValue(WQF\sldPosition, 0)
    EndIf
    
    WQF_displayLoopAndCueMarkerInfo()
    
  EndWith
  ;   debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQF_refreshFileInfo()
  ; PROCNAMEC()
  ; see also WQF_displayFileInfo()
  Protected nFirstDevChannel.l
  Protected nAbsFilePos.l
  
  ;   debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    SGT(WQF\txtCueDuration, timeToStringBWZT(\nCueDuration, \nFileDuration))
    SLD_setMax(WQF\sldProgress, (\nCueDuration-1))
    
    WQF_displayLoopAndCueMarkerInfo()
  
    If gbUseBASS
      nFirstDevChannel = \nBassChannel[\nFirstDev]
      If nFirstDevChannel <> 0
        nAbsFilePos = Int(BASS_ChannelBytes2Seconds(nFirstDevChannel, \qChannelBytePosition) * 1000)
        \nRelFilePos = nAbsFilePos - \nAbsMin
        If \nRelFilePos < 0
          \nRelFilePos = 0
        EndIf
        ; debugMsg(sProcName, "nAbsFilePos=" + nAbsFilePos + ", \nAbsMin=" + \nAbsMin + ", \nRelFilePos=" + \nRelFilePos)
      EndIf
    EndIf
    
    ; debugMsg(sProcName, "calling editUpdateDisplay(#True)")
    editUpdateDisplay(#True)
    
  EndWith
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQF_refreshCueMarkersDisplayEtc()
  PROCNAMEC()
  
  ; debugMsg(sProcName, "calling loadCueMarkerArrays()")
  loadCueMarkerArrays()
  WQF_refreshFileInfo()
  redrawGraphAfterMouseChange(@grMG2)
  WQF_setClearState()
  WQF_setViewControls()
  
  ; debugMsg(sProcName, "calling redisplayCueMarkerInfoWhereReqd(" + getAudLabel(nEditAudPtr) + ")")
  redisplayCueMarkerInfoWhereReqd(nEditAudPtr)
  
EndProcedure

Procedure WQF_displayLoopAndCueMarkerInfo()
  PROCNAMECA(nEditAudPtr)
  Protected nFileDuration
  Protected sTmp.s
  Protected l2, nLineCount, nLevelPointIndex
  Protected bEnableAdd, bEnableDel
  Protected bEnableLeft, bEnableRight
  Protected bEnableLoopFields
  Protected bStdMarker, bCueMarker, nCueMarkerIndex, nMarkerPos
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    nFileDuration = \nFileDuration
    If rWQF\nDisplayedLoopInfoIndex > \nMaxLoopInfo
      rWQF\nDisplayedLoopInfoIndex = \nMaxLoopInfo
    EndIf
    l2 = rWQF\nDisplayedLoopInfoIndex
    If l2 >= 0
      bEnableLoopFields = #True
      SGT(WQF\txtLoopNr, Str(l2+1))
      If l2 > 0
        bEnableLeft = #True
      EndIf
      If l2 < \nMaxLoopInfo
        bEnableRight = #True
      EndIf
      If \aLoopInfo(l2)\dLoopStartCPTime >= 0.0
        SGT(WQF\txtLoopStart, timeDblToStringHT(\aLoopInfo(l2)\dLoopStartCPTime, nFileDuration))
      Else
        SGT(WQF\txtLoopStart, timeToStringT(\aLoopInfo(l2)\nLoopStart, nFileDuration))
      EndIf
      
      If \aLoopInfo(l2)\dLoopEndCPTime >= 0.0
        SGT(WQF\txtLoopEnd, timeDblToStringHT(\aLoopInfo(l2)\dLoopEndCPTime, nFileDuration))
      Else
        SGT(WQF\txtLoopEnd, timeToStringT(\aLoopInfo(l2)\nLoopEnd, nFileDuration))
      EndIf
      
      SGT(WQF\txtLoopXFadeTime, timeToStringBWZT(\aLoopInfo(l2)\nLoopXFadeTime))
      sTmp = ""
      If \aLoopInfo(l2)\nNumLoops > 0
        sTmp = Str(\aLoopInfo(l2)\nNumLoops)
      EndIf
      SGT(WQF\txtNumLoops, sTmp)
      
    Else
      SGT(WQF\txtLoopNr, "")
      SGT(WQF\txtLoopStart, "")
      SGT(WQF\txtLoopEnd, "")
      SGT(WQF\txtLoopXFadeTime, "")
      SGT(WQF\txtNumLoops, "")
      
    EndIf
    
    If grLicInfo\bAudFileLoopsAvailable
      If \nMaxLoopInfo < #SCS_MAX_LOOP
        bEnableAdd = #True
      EndIf
      If rWQF\nDisplayedLoopInfoIndex >= 0
        bEnableDel = #True
      EndIf
      
      If (bEnableAdd) And (l2 >= 0)
        If l2 = \nMaxLoopInfo
          If \aLoopInfo(l2)\nAbsLoopEnd >= \nAbsEndAt
            bEnableAdd = #False ; cannot start a loop after the 'end at' time because the cue has already ended
            debugMsg(sProcName, "l2=" + l2 + ", \aLoopInfo(" + l2 + ")\nAbsLoopEnd=" + \aLoopInfo(l2)\nAbsLoopEnd + ", \nAbsEndAt=" + \nAbsEndAt + ", bEnableAdd=#False")
          EndIf
        ElseIf l2 < \nMaxLoopInfo
          If (\aLoopInfo(l2)\nAbsLoopEnd + 100) >= \aLoopInfo(l2+1)\nAbsLoopStart
            bEnableAdd = #False ; insufficient time between this loop and the next to create a new loop (using a 100ms 'minimum loop time')
            debugMsg(sProcName, "l2=" + l2 + ", \aLoopInfo(" + l2 + ")\nAbsLoopEnd=" + \aLoopInfo(l2)\nAbsLoopEnd + ", \aLoopInfo(" + Str(l2+1) + ")\nAbsLoopStart=" + \aLoopInfo(l2+1)\nAbsLoopStart + ", bEnableAdd=#False")
          EndIf
        EndIf
      EndIf
      
      If bEnableAdd
        ; Std Level Point
        For nLevelPointIndex = 0 To \nMaxLevelPoint
          If \aPoint(nLevelPointIndex)\nPointType = #SCS_PT_STD
            ; loops not permitted if a standard level point exists
            bStdMarker = #True
            Break
          EndIf
        Next nLevelPointIndex
        
        If \nMaxCueMarker >= 0
          bCueMarker = #True
        EndIf
        
      EndIf
      
      ; Set Enable Loops
      If bStdMarker
        bEnableAdd = #False
        bEnableDel = #False
      EndIf
      
;       debugMsg(sProcName, "\nMaxLoopInfo=" + \nMaxLoopInfo + ", \nMaxLevelPoint=" + \nMaxLevelPoint +
;                           ", bStdMarker=" + strB(bStdMarker) + ", bCueMarker=" + strB(bCueMarker) + ", bEnableAdd=" + strB(bEnableAdd) + ", bEnableDel=" + strB(bEnableDel))
      
    EndIf ; EndIf grLicInfo\nLicLevel >= #SCS_LIC_STD
    
    ; debugMsg(sProcName, "calling setEnabled(WQF\btnLoopAdd, " + strB(bEnableAdd) + ")")
    setEnabled(WQF\btnLoopAdd, bEnableAdd)
    setEnabled(WQF\btnLoopDel, bEnableDel)
    setEnabled(WQF\btnLoopNrLeft, bEnableLeft)
    setEnabled(WQF\btnLoopNrRight, bEnableRight)
    setEnabled(WQF\txtLoopNr, bEnableLoopFields)
    setEnabled(WQF\txtLoopStart, bEnableLoopFields)
    setEnabled(WQF\txtLoopEnd, bEnableLoopFields)
    setEnabled(WQF\txtLoopXFadeTime, bEnableLoopFields)
    setEnabled(WQF\txtNumLoops, bEnableLoopFields)
    
    nLineCount = 0
    For l2 = 0 To \nMaxLoopInfo
      SLD_setLinePos(WQF\sldProgress, nLineCount, \aLoopInfo(l2)\nAbsLoopStart - \nAbsMin, #SCS_SLD_LT_LOOP_START)
      SLD_setLinePos(WQF\sldProgress, nLineCount+1, \aLoopInfo(l2)\nAbsLoopEnd - \nAbsMin, #SCS_SLD_LT_LOOP_END)
      nLineCount + 2
    Next l2
    For nCueMarkerIndex = 0 To \nMaxCueMarker
      nMarkerPos = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
      If (nMarkerPos >= \nAbsMin) And (nMarkerPos <= \nAbsMax)
        SLD_setLinePos(WQF\sldProgress, nLineCount, nMarkerPos - \nAbsMin, #SCS_SLD_LT_CUE_MARKER)
        nLineCount + 1
      EndIf
    Next nCueMarkerIndex   
    SLD_setLineCount(WQF\sldProgress, nLineCount)
    
    WQF_setLoopTimeFieldEnabledStates()
    WQF_setClearState()
    
    samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_drawForm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  colorEditorComponent(#WQF)
  
  With WQF
    SetGadgetColor(\txtFileTypeExt, #PB_Gadget_FrontColor, getSubTextColor())
    SetGadgetColor(\txtFileTypeExt, #PB_Gadget_BackColor, getSubBackColor())
    SetGadgetColor(\lnTimes, #PB_Gadget_BackColor, getSubTextColor())
    
    setEnabled(\txtStartAt, grLicInfo\bStartEndAvailable)
    setTextBoxBackColor(\txtStartAt)
    setEnabled(\txtEndAt, grLicInfo\bStartEndAvailable)
    setTextBoxBackColor(\txtEndAt)
    SLD_setEnabled(\sldProgress, #True)
    setEnabled(\btnOther, grLicInfo\bStartEndAvailable)
    
  EndWith
  
EndProcedure

Procedure WQF_setCboLogicalDevsEnabled()
  PROCNAMEC()
  Protected bAvailable, d
  
  debugMsg(sProcName, #SCS_START)
  
  If rWQF\bDisplayingLevelPoint = #False
    bAvailable = #True
  EndIf
  For d = 0 To grLicInfo\nMaxAudDevPerAud
    setEnabled(WQF\cboLogicalDevF[d], bAvailable)
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setCboTracksEnabled(nIndex=-1)
  PROCNAMECA(nEditAudPtr)
  Protected bAvailable, d
  Protected nStart, nEnd
  
  If nIndex = -1
    nStart = 0
    nEnd = grLicInfo\nMaxAudDevPerAud
  Else
    nStart = nIndex
    nEnd = nIndex
  EndIf
  
  For d = nStart To nEnd
    bAvailable = #False
    If nEditAudPtr >= 0
      If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_OPEN
        If gbUseSMS
          If getEnabled(WQF\cboLogicalDevF[d]) And Len(Trim(GGT(WQF\cboLogicalDevF[d]))) > 0
            If nEditAudPtr >= 0
              If Len(aAud(nEditAudPtr)\sFileName) > 0 And aAud(nEditAudPtr)\nFileChannels > 0
                bAvailable = #True
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    setEnabled(WQF\cboTracks[d], bAvailable)
  Next d
  
EndProcedure

Procedure WQF_btnCenter_Click(Index)
  PROCNAMEC()
  
  SLD_setValue(WQF\sldPan[Index], #SCS_PANCENTRE_SLD)
  debugMsg(sProcName, "SLD_getValue(WQF\sldPan[" + Index + "])=" + WQF\sldPan[Index])
  WQF_fcSldPan(Index)
  
  If Index <> rWQF\nCurrDevNo
    WQF_setCurrentDevInfo(Index, #True, #True)
  EndIf
  
EndProcedure

Procedure WQF_btnEditFadeOut_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, aAud(nEditAudPtr)\sAudLabel)
  fadeOutOneAud(nEditAudPtr)
  setResyncLinksReqd(nEditAudPtr)
  editSetDisplayButtonsF()
  gbCallEditUpdateDisplay = #True
  
  If IsGadget(WQF\cvsGraph)
    SAG(WQF\cvsGraph)
  Else
    SAG(-1)
  EndIf
  
  WQF_makeVSTWindowActiveIfReqd() ; Added 21Feb2025
  
EndProcedure

Procedure WQF_btnEditPause_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, aAud(nEditAudPtr)\sAudLabel)
  If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
    resumeAud(nEditAudPtr)
  Else
    debugMsg(sProcName, "calling pauseAud(" + nEditAudPtr + ")")
    pauseAud(nEditAudPtr)
  EndIf
  debugMsg(sProcName, "calling setResyncLinksReqd(" + nEditAudPtr + ")")
  setResyncLinksReqd(nEditAudPtr)
  debugMsg(sProcName, "calling editSetDisplayButtonsF()")
  editSetDisplayButtonsF()
  gbCallEditUpdateDisplay = #True
  debugMsg(sProcName, #SCS_END)
  
  If IsGadget(WQF\cvsGraph)
    SAG(WQF\cvsGraph)
  Else
    SAG(-1)
  EndIf
  
  WQF_makeVSTWindowActiveIfReqd() ; Added 21Feb2025
  
EndProcedure

Procedure WQF_btnEditPlay_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    gqTimeNow = ElapsedMilliseconds()
    debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState))
    If \nAudState = #SCS_CUE_PAUSED
      debugMsg(sProcName, "calling resumeAud(" + getAudLabel(nEditAudPtr) + ")")
      resumeAud(nEditAudPtr)
    ElseIf (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
      debugMsg(sProcName, "calling editPlaySub()")
      editPlaySub()
    Else
      debugMsg(sProcName, "calling restartAud(" + getAudLabel(nEditAudPtr) + ")")
      restartAud(nEditAudPtr)
    EndIf
    setResyncLinksReqd(nEditAudPtr)
    editSetDisplayButtonsF()
    
    If getOwnState(WQF\chkViewVST) = #PB_Checkbox_Checked
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_AUD, " + getAudLabel(nEditAudPtr) + ", " + decodeHandle(\nVSTHandle) + ", #True)")
      WPL_showVSTEditor(#SCS_VST_HOST_AUD, nEditAudPtr, \nVSTHandle, #True)
    EndIf
    
    gbCallEditUpdateDisplay = #True
    gbEditUpdateGraphMarkers = #True
    
    If IsGadget(WQF\cvsGraph)
      SAG(WQF\cvsGraph)
    Else
      SAG(-1)
    EndIf
    
    WQF_makeVSTWindowActiveIfReqd() ; Added 21Feb2025
    
  EndWith
  
EndProcedure

Procedure WQF_btnEditRelease_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  releaseAudLoop(nEditAudPtr)
  setResyncLinksReqd(nEditAudPtr)
  editSetDisplayButtonsF()
  gbCallEditUpdateDisplay = #True
  gbEditUpdateGraphMarkers = #True
  
  If IsGadget(WQF\cvsGraph)
    SAG(WQF\cvsGraph)
  Else
    SAG(-1)
  EndIf
  
EndProcedure

Procedure WQF_btnEditRewind_Click()
  PROCNAMECA(nEditAudPtr)
  Protected nState
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  
  nState = aAud(nEditAudPtr)\nAudState
  If (nState >= #SCS_CUE_FADING_IN) And (nState <= #SCS_CUE_FADING_OUT) And (nState <> #SCS_CUE_PAUSED)
    If gbUseBASS
      pauseAud(nEditAudPtr)
    EndIf
    With aAud(nEditAudPtr)
      \nCuePosAtLoopStart = 0    ; must be cleared before calling reposAuds
      debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ")")
      reposAuds(nEditAudPtr, \nAbsStartAt)
      \qTimeAudStarted = gqTimeNow
      ; \qTimeAudEnded = 0
      \bTimeAudEndedSet = #False
      \qTimeAudRestarted = gqTimeNow
      \nTotalTimeOnPause = 0
      \nPriorTimeOnPause = 0
      \nPreFadeInTimeOnPause = 0
      \nPreFadeOutTimeOnPause = 0
      \nCuePosAtLoopStart = 0
    EndWith
    If gbUseBASS
      resumeAud(nEditAudPtr)
    EndIf
  Else
    With aAud(nEditAudPtr)
      \nCuePosAtLoopStart = 0    ; must be cleared before calling reposAuds
      debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ")")
      reposAuds(nEditAudPtr, \nAbsStartAt)
      If \nAudState = #SCS_CUE_PAUSED
        \nAudState = #SCS_CUE_READY
        setCueState(nEditCuePtr)
      EndIf
    EndWith
  EndIf
  setResyncLinksReqd(nEditAudPtr)
  editSetDisplayButtonsF()
  gbCallEditUpdateDisplay = #True
  gbEditUpdateGraphMarkers = #True
  
  If IsGadget(WQF\cvsGraph)
    SAG(WQF\cvsGraph)
  Else
    SAG(-1)
  EndIf
  
  WQF_makeVSTWindowActiveIfReqd() ; Added 21Feb2025
  
EndProcedure

Procedure WQF_btnEditStop_Click()
  PROCNAMECA(nEditAudPtr)
  Protected j
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  stopAud(nEditAudPtr, #True)
  ; added 25May2017 11.6.2ai following email from C.Peters about starting (in the main window) a cue with a linked MTC sub-cue, and then
  ; stopping the cue in the editor - the MTC kept running
  If aSub(nEditSubPtr)\nSubState = #SCS_CUE_READY
    editStopMTCSubIfLinked(nEditSubPtr)
  EndIf
  ; end added 25May2017 11.6.2ai
  SAG(-1)
  
  ; now pause until stop slide has completed
  If gnStopFadeTime > 0
    Delay(gnStopFadeTime)
  EndIf
  
  With aAud(nEditAudPtr)
    If \nPlayFromPos <= 0
      \nCuePosAtLoopStart = 0
      debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ")")
      reposAuds(nEditAudPtr, \nAbsStartAt)
    EndIf
  EndWith
  setResyncLinksReqd(nEditAudPtr)
  WQF_resetSliders()  ; enables level and pan sliders for ignored devices (provided they have a logical device)
  editSetDisplayButtonsF()
  gbCallEditUpdateDisplay = #True
  gbEditUpdateGraphMarkers = #True
  
  If IsGadget(WQF\cvsGraph)
    SAG(WQF\cvsGraph)
  Else
    SAG(-1)
  EndIf
  
  WQF_makeVSTWindowActiveIfReqd() ; Added 21Feb2025

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setPropertyLogicalDev(Index, sNewLogicalDev.s)
  PROCNAMECA(nEditAudPtr)
  Protected d, nNewBassDevice
  Protected bFound, nListIndex
  Protected sOldLogicalDev.s
  Protected nNrOfOutputChans
  Protected u, sAfterValue.s
  Protected nDefaultDevPtr
  Protected sMyTracks.s
  Protected bResetPanBase
  Protected bDevPresent, bAddingDevice, bDeletingDevice
  Protected bPanVisible
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    If \bDisplayPan[Index]
      bPanVisible = #True
    EndIf
    
    bFound = #False
    sOldLogicalDev = \sLogicalDev[Index]
    nNewBassDevice = -1
    For d = 0 To grProd\nMaxAudioLogicalDev
      If Len(grProd\aAudioLogicalDevs(d)\sLogicalDev) > 0
        If grProd\aAudioLogicalDevs(d)\sLogicalDev = sNewLogicalDev
          bFound = #True
          nNewBassDevice = grProd\aAudioLogicalDevs(d)\nBassDevice
          nNrOfOutputChans = grProd\aAudioLogicalDevs(d)\nNrOfOutputChans
          Break
        EndIf
      EndIf
    Next d
    
    If (Len(sOldLogicalDev) = 0) And (Len(sNewLogicalDev) > 0)
      bAddingDevice = #True
    ElseIf (Len(sOldLogicalDev) > 0) And (Len(sNewLogicalDev) = 0)
      bDeletingDevice = #True
    EndIf
    
    setGraphChannelsForLogicalDev(2, sNewLogicalDev)
    
    debugMsg(sProcName, "sNewLogicalDev=" + sNewLogicalDev + ", \sLogicalDev[" + Index + "]=" + \sLogicalDev[Index] + ", bFound=" + strB(bFound) + ", \bUsingSplitStream=" + strB(\bUsingSplitStream))
    If Len(sNewLogicalDev) > 0
      bDevPresent = #True
    EndIf
    If (sNewLogicalDev <> \sLogicalDev[Index]) Or (gbAdding)
      setGaplessMajorChangeForAud(nEditAudPtr)
      u = preChangeAudL(#True, Lang("Common", "AudioDevice"), -5, #SCS_UNDO_ACTION_CHANGE, Index, #SCS_UNDO_FLAG_OPEN_FILE)
      ; close current channel if open
      debugMsg(sProcName, "calling freeOneAudStream for nEditAudPtr=" + nEditAudPtr)
      debugMsg3(sProcName, "calling freeOneAudStream(" + nEditAudPtr + ", " + Index + ")")
      freeOneAudStream(nEditAudPtr, Index)
      
      \sLogicalDev[Index] = sNewLogicalDev
      sAfterValue = \sLogicalDev[Index]
      \nBassDevice[Index] = nNewBassDevice
      
      If bFound
        debugMsg(sProcName, "sOldLogicalDev=" + sOldLogicalDev + ", \fBVLevel[" + Index + "]=" + StrF(\fBVLevel[Index],4) + ", #SCS_MINVOLUME_SINGLE=" + StrF(#SCS_MINVOLUME_SINGLE,4) + ", gbAdding=" + strB(gbAdding))
        If (Len(sOldLogicalDev) = 0 And \fBVLevel[Index] = #SCS_MINVOLUME_SINGLE) Or (gbAdding)
          nDefaultDevPtr = getProdLogicalDevPtrForLogicalDev(sNewLogicalDev)
          If gbPasting = #False
            debugMsg(sProcName, "Index=" + Index + ", nDefaultDevPtr=" + nDefaultDevPtr)
            If nDefaultDevPtr >= 0
              \sDBTrim[Index] = grProd\aAudioLogicalDevs(nDefaultDevPtr)\sDfltDBTrim
              \sDBLevel[Index] = grProd\aAudioLogicalDevs(nDefaultDevPtr)\sDfltDBLevel
              debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index])
              \fPan[Index] = grProd\aAudioLogicalDevs(nDefaultDevPtr)\fDfltPan
            ElseIf Index = 0
              \sDBTrim[Index] = #SCS_DEFAULT_DBTRIM
              \sDBLevel[Index] = grLevels\sDefaultDBLevel
              debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index])
              \fPan[Index] = #SCS_PANCENTRE_SINGLE
            Else
              If Len(\sLogicalDev[Index-1]) > 0
                \sDBTrim[Index] = \sDBTrim[Index-1]
                \sDBLevel[Index] = \sDBLevel[Index-1]
                debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index])
                \fBVLevel[Index] = \fBVLevel[Index-1]
                \fTrimFactor[Index] = \fTrimFactor[Index-1]
              Else
                \sDBTrim[Index] = #SCS_DEFAULT_DBTRIM
                \sDBLevel[Index] = grLevels\sDefaultDBLevel
                debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index])
                \fPan[Index] = #SCS_PANCENTRE_SINGLE
              EndIf
            EndIf
          EndIf
          debugMsg(sProcName, "\sDBTrim[" + Index + "]=" + \sDBTrim[Index])
          \fTrimFactor[Index] = dbTrimStringToFactor(\sDBTrim[Index])
          nListIndex = indexForComboBoxRow(WQF\cboTrim[Index], \sDBTrim[Index], -1)
          If (nListIndex = -1) And (bDevPresent)
            nListIndex = 0
          EndIf
          If GGS(WQF\cboTrim[Index]) <> nListIndex
            SGS(WQF\cboTrim[Index], nListIndex)
          EndIf
          \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
          debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index] + ", \fBVLevel[" + Index + "]=" + formatLevel(\fBVLevel[Index]))
          \fSavedBVLevel[Index] = \fBVLevel[Index]
          \fSavedPan[Index] = \fPan[Index]
        Else
          \fSavedBVLevel[Index] = \fBVLevel[Index]
          \fSavedPan[Index] = \fPan[Index]
          nListIndex = indexForComboBoxRow(WQF\cboTrim[Index], \sDBTrim[Index], -1)
          If (nListIndex = -1) And (bDevPresent)
            nListIndex = 0
          EndIf
          If GGS(WQF\cboTrim[Index]) <> nListIndex
            SGS(WQF\cboTrim[Index], nListIndex)
          EndIf
        EndIf
        ; debugMsg(sProcName, "bb")
        If bDevPresent
          If CountGadgetItems(WQF\cboTracks[Index]) = 0
            populateCboTracksForAud(WQF\cboTracks[Index], nEditAudPtr, Index)
          EndIf
          \sTracks[Index] = ""
          nListIndex = indexForComboBoxRow(WQF\cboTracks[Index], \sTracks[Index], -1)
          If (nListIndex = -1) And (bDevPresent)
            nListIndex = 0
          EndIf
          If GGS(WQF\cboTracks[Index]) <> nListIndex
            SGS(WQF\cboTracks[Index], nListIndex)
          EndIf
        EndIf
        ; re-open sound file to use new device
        debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
        setIgnoreDevInds(nEditAudPtr, #True)
        debugMsg(sProcName, "calling setResyncLinksReqd(" + getAudLabel(nEditAudPtr) + ")")
        setResyncLinksReqd(nEditAudPtr)
        debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ")")
        openMediaFile(nEditAudPtr)
        
      Else ; new device is blank
        \sTracks[Index] = ""
        nListIndex = indexForComboBoxRow(WQF\cboTracks[Index], \sTracks[Index], -1)
        If GGS(WQF\cboTracks[Index]) <> nListIndex
          SGS(WQF\cboTracks[Index], nListIndex)
        EndIf
        \sDBTrim[Index] = #SCS_DEFAULT_DBTRIM
        \sDBLevel[Index] = #SCS_INF_DBLEVEL
        \fPan[Index] = #SCS_PANCENTRE_SINGLE
        \fTrimFactor[Index] = dbTrimStringToFactor(\sDBTrim[Index])
        nListIndex = -1
        If GGS(WQF\cboTrim[Index]) <> nListIndex
          SGS(WQF\cboTrim[Index], nListIndex)
        EndIf
        \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
        \fSavedBVLevel[Index] = \fBVLevel[Index]
        \fSavedPan[Index] = \fPan[Index]
      EndIf
      
      debugMsg(sProcName, "nNrOfOutputChans=" + Str(nNrOfOutputChans))
      If nNrOfOutputChans <> 2
        If \fPan[Index] <> #SCS_PANCENTRE_SINGLE
          \fPan[Index] = #SCS_PANCENTRE_SINGLE
          \fSavedPan[Index] = \fPan[Index]
          bResetPanBase = #True
        EndIf
      EndIf
      
      If SLD_getLevel(WQF\sldLevel[Index]) <> \fBVLevel[Index]
        SLD_setLevel(WQF\sldLevel[Index], \fBVLevel[Index], \fTrimFactor[Index])
        SLD_setBaseLevel(WQF\sldLevel[Index], #SCS_SLD_BASE_EQUALS_CURRENT)
        WQF_fcSldLevel(Index)
      EndIf
      SGT(WQF\txtDBLevel[Index], \sDBLevel[Index])
      
      If bPanVisible
        If SLD_getValue(WQF\sldPan[Index]) <> panToSliderValue(\fPan[Index])
          SLD_setValue(WQF\sldPan[Index], panToSliderValue(\fPan[Index]))
          SLD_setBaseValue(WQF\sldPan[Index], #SCS_SLD_BASE_EQUALS_CURRENT)
          WQF_fcSldPan(Index)
        EndIf
        SGT(WQF\txtPan[Index], panSingleToString(\fPan[Index]))
        If bResetPanBase
          SLD_setBaseValue(WQF\sldPan[Index], panToSliderValue(\fPan[Index]))
        EndIf
        If nNrOfOutputChans = 2
          SLD_setEnabled(WQF\sldPan[Index], #True)
        Else
          SLD_setEnabled(WQF\sldPan[Index], #False)
        EndIf
      EndIf
      SLD_setVisible(WQF\sldPan[Index], bPanVisible)
      setVisible(WQF\btnCenter[Index], bPanVisible)
      setVisible(WQF\txtPan[Index], bPanVisible)
      
    EndIf
    
    setFirstAndLastDev(nEditAudPtr)
    
    If bAddingDevice
      addLevelPointItemsForNewDevice(nEditAudPtr, Index)
      setDerivedLevelPointInfo2(nEditAudPtr)
    EndIf
    
    debugMsg(sProcName, "calling WQF_fcLogicalDevF(" + Index + ")")
    WQF_fcLogicalDev(Index)
    
    debugMsg(sProcName, "calling displayFileInfo()")
    WQF_displayFileInfo()
    
    debugMsg(sProcName, "calling WQF_processDevSel()")
    WQF_processDevSel()
    
    debugMsg(sProcName, "calling editSetDisplayButtonsF()")
    editSetDisplayButtonsF()
    
    WQF_setCurrentDevInfo(Index, #True, #True)
    nCurrPos = -1
    WQF_initGraphInfo()
    
    gbCallEditUpdateDisplay = #True
    
    postChangeAudL(u, #False, -5, Index)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_cboLogicalDevF_Click(Index)
  PROCNAMECA(nEditAudPtr)
  Protected sNewLogicalDev.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", gnEventType=" + decodeEventType())
  
  ; debugMsg0(sProcName, "(a) aAud(" + getAudLabel(nEditAudPtr) + ")\nLastDev=" + aAud(nEditAudPtr)\nLastDev)
  rWQF\bInLogicalDevClick = #True
  
  sNewLogicalDev = GGT(WQF\cboLogicalDevF[Index])
  WQF_setPropertyLogicalDev(Index, sNewLogicalDev)
  
  ; Added 5Jul2022 11.9.3.1ab  
  If closeAndReopenSub(nEditSubPtr) = #False
    rWQF\bInLogicalDevClick = #False
    ProcedureReturn
  EndIf
  ; End added 5Jul2022 11.9.3.1ab  

  rWQF\bInLogicalDevClick = #False
  ; must set rWQF\bInLogicalDevClick = #False BEFORE displaying graph
  ; debugMsg(sProcName, "calling prepareAndDisplayGraph(@grMG2)")
  prepareAndDisplayGraph(@grMG2)
  
  If sNewLogicalDev
    ; debugMsg0(sProcName, "(z) aAud(" + getAudLabel(nEditAudPtr) + ")\nLastDev=" + aAud(nEditAudPtr)\nLastDev)
    WQF_addDeviceIfReqd(aAud(nEditAudPtr)\nLastDev + 1)
    WQF_setScaDevsInnerHeight()
  EndIf
  
  gbCallLoadDispPanels = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_cboTracks_Click(Index)
  PROCNAMEC()
  Protected u
  
  If rWQF\bInLogicalDevClick
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    If \sTracks[Index] <> GGT(WQF\cboTracks[Index])
      u = preChangeAudS(\sTracks[Index], GGT(WQF\lblTracks), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \sTracks[Index] = GGT(WQF\cboTracks[Index])
      postChangeAudS(u, \sTracks[Index], -5, Index)
    EndIf
  EndWith
  
  WQF_setCurrentDevInfo(Index, #True)
  
EndProcedure

Procedure WQF_cboTrim_Click(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected fOldTrim.f, fNewTrim.f
  Protected fOldDBLevelSingle.f, fNewDBLevelSingle.f
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If rWQF\bInLogicalDevClick
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    If \sDBTrim[Index] <> GGT(WQF\cboTrim[Index])
      u = preChangeAudS(\sDBTrim[Index], GGT(WQF\lblTrim), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      fOldTrim = dbTrimStringToSingle(\sDBTrim[Index])
      fNewTrim = getCurrentItemData(WQF\cboTrim[Index])
      fOldDBLevelSingle = convertDBStringToDBLevel(\sDBLevel[Index])
      fNewDBLevelSingle = fOldDBLevelSingle + (fNewTrim - fOldTrim)
;       If fNewDBLevelSingle > 0.0
;         fNewDBLevelSingle = 0.0
;       ElseIf fNewDBLevelSingle < -75.0
;         fNewDBLevelSingle = -75.0
;       EndIf
      If fNewDBLevelSingle > grProd\nMaxDBLevel
        fNewDBLevelSingle = grProd\nMaxDBLevel
      ElseIf fNewDBLevelSingle < grProd\nMinDBLevel
        fNewDBLevelSingle = grProd\nMinDBLevel
      EndIf
      ; debugMsg(sProcName, "fOldTrim=" + StrF(fOldTrim,2) + ", fNewTrim=" + StrF(fNewTrim,2) + ", fOldDBLevelSingle=" + StrF(fOldDBLevelSingle,2) + ", fNewDBLevelSingle=" + StrF(fNewDBLevelSingle,2))
      \sDBTrim[Index] = GGT(WQF\cboTrim[Index])
      \sDBLevel[Index] = StrF(fNewDBLevelSingle,1)
      \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
      ; debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index] + ", \fBVLevel[" + Index + "]=" + traceLevel(\fBVLevel[Index]))
      \fTrimFactor[Index] = dbTrimStringToFactor(\sDBTrim[Index])
      ; Deleted 18Feb2022 11.9.1aa
      ; If (SLD_getLevel(WQF\sldLevel[Index]) <> \fBVLevel[Index]) Or (SLD_getTrimFactor(WQF\sldLevel[Index]) <> \fTrimFactor[Index])
      ;   SLD_setLevel(WQF\sldLevel[Index], SLD_BVLevelToSliderValue(\fBVLevel[Index], \fTrimFactor[Index]), \fTrimFactor[Index]) ; 17Feb2022 11.9.1aa added "\fTrimFactor[Index]" to Sld_setLevel call
      ; EndIf
      ; End deleted 18Feb2022 11.9.1aa
      ; Added 18Feb2022 11.9.1aa (replacing the above deleted code, following an email from Jason Mai on 16Feb2022 regarding Trim not working)
      SLD_setLevel(WQF\sldLevel[Index], \fBVLevel[Index], \fTrimFactor[Index])
      ; End added 18Feb2022 11.9.1aa
      ; debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index] + ", \fBVLevel[" + Index + "]=" + traceLevel(\fBVLevel[Index]))
      WQF_fcSldLevel(Index)
      ; debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index] + ", \fBVLevel[" + Index + "]=" + traceLevel(\fBVLevel[Index]))
      SGT(WQF\txtDBLevel[Index], \sDBLevel[Index])
      postChangeAudSN(u, \sDBTrim[Index], -5, Index, "")
    EndIf
  EndWith
  
  WQF_setCurrentDevInfo(Index, #True, #True)
  
EndProcedure

Procedure WQF_chkDevInclude_Click(Index)
  PROCNAMECA(nEditAudPtr)
  Protected nLevelPointIndex, nItemIndex
  Protected sLogicalDev.s, sTracks.s
  Protected bItemInclude, bItemIncludeForAddItem
  Protected fItemRelDBLevel.f
  Protected fItemPan
  Protected n
  Protected u
  Protected nLvlPtLvlSel
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  WQF_setCurrentDevInfo(Index, #True, #True)
  
  bItemInclude = getOwnState(WQF\chkDevInclude[Index])
  debugMsg(sProcName, "bItemInclude=" + strB(bItemInclude))
  
  nLevelPointIndex = getLevelPointIndexForTime(nEditAudPtr, rWQF\nCurrLevelPointTime)
  If nLevelPointIndex >= 0
    sLogicalDev = aAud(nEditAudPtr)\sLogicalDev[Index]
    sTracks = aAud(nEditAudPtr)\sTracks[Index]
    nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
    If nItemIndex = -1
      ; item currently missing, so add the item
      fItemRelDBLevel = 0.0
      fItemPan = 0
      ; add the item with \bItemInclude reversed so that pre/post change will detect a change when the required \bItemInclude value has been set
      If bItemInclude = #False
        bItemIncludeForAddItem = #True
      EndIf
      nItemIndex = addOneDBLevelPointItem(nEditAudPtr, nLevelPointIndex, sLogicalDev, sTracks, bItemIncludeForAddItem, fItemRelDBLevel, fItemPan)
    EndIf
    debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex + ", nItemIndex=" + Str(nItemIndex))
    If nItemIndex >= 0
      With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)
        If bItemInclude
          ; if 'sync levels' then get the required relative level from a currently-included item
          nLvlPtLvlSel = aAud(nEditAudPtr)\nLvlPtLvlSel
          If nLvlPtLvlSel = #SCS_LVLSEL_SYNC
            fItemRelDBLevel = 0.0
            For n = 0 To \nPointMaxItem
              If \aItem(n)\bItemInclude
                fItemRelDBLevel = \aItem(n)\fItemRelDBLevel
                Break
              EndIf
            Next n
          EndIf
        EndIf
        
        u = preChangeAudL(\aItem(nItemIndex)\bItemInclude, rWQF\sUndoDescKeyPart + Lang("WQF","lblInclude"), -5, #SCS_UNDO_ACTION_CHANGE, Index)
        \aItem(nItemIndex)\bItemInclude = bItemInclude
        
        If bItemInclude
          If nLvlPtLvlSel = #SCS_LVLSEL_SYNC
            \aItem(nItemIndex)\fItemRelDBLevel = fItemRelDBLevel
            ; debugMsg0(sProcName, "\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemRelDBLevel=" + convertDBLevelToDBString(\aItem(nItemIndex)\fItemRelDBLevel))
          EndIf
        EndIf
        WQF_displayRelLevelAndPanForDev(nLevelPointIndex, nItemIndex)
        debugMsg(sProcName, "calling WQF_setLevelAndPanEnabledStates(" + Index + ")")
        WQF_setLevelAndPanEnabledStates(Index)
        debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
        
        postChangeAudLN(u, \aItem(nItemIndex)\bItemInclude, -5, Index)
      EndWith
    EndIf ; EndIf nItemIndex >= 0
  EndIf ; EndIf nLevelPointIndex >= 0
  
EndProcedure

Procedure WQF_fcPlaceHolder()
  PROCNAMEC()
  Protected bEnable
  
  ; debugMsg(sProcName, #SCS_START)
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \bAudPlaceHolder = #False
        bEnable = #True
      Else
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bAudPlaceHolder=" + strB(\bAudPlaceHolder))
      EndIf
      ; setEnabled(WQF\btnRename, bEnable)
    EndWith
  EndIf
  setEnabled(WQF\btnOther, bEnable)
EndProcedure

Procedure WQF_setPropertyFileName(sFileName.s, nCallingWindow=#WED)
  PROCNAMECA(nEditAudPtr)
  Protected u, u2
  
  debugMsg(sProcName, #SCS_START + ", sFileName=" + #DQUOTE$ + sFileName + #DQUOTE$ + ", nCallingWindow=" + decodeWindow(nCallingWindow))
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      debugMsg(sProcName, "calling preChangeAud")
      u = preChangeAudS(\sFileName, GGT(WQF\lblFileName), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_OPEN_FILE|#SCS_UNDO_FLAG_SET_CUE_NODE_TEXT|#SCS_UNDO_FLAG_REDO_TREE)
      \sFileName = sFileName
      \nFileDataPtr = grAudDef\nFileDataPtr
      \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
      \bAudPlaceHolder = #False
      \nFileStatsPtr = grAudDef\nFileStatsPtr
      WQF_fcPlaceHolder()
      
      debugMsg(sProcName, "calling WQF_fcFileExt()")
      WQF_fcFileExt(#False)  ; nb sets \nFileFormat
      debugMsg(sProcName, "returned from WQF_fcFileExt()")
      
      SGT(WQF\txtFileName, \sStoredFileName)
      scsToolTip(WQF\txtFileName, \sFileName)
      
      debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
      setIgnoreDevInds(nEditAudPtr, #True)
      debugMsg(sProcName, "calling openMediaFile()")
      openMediaFile(nEditAudPtr, #True, #SCS_VID_PIC_TARGET_NONE, #False, #False, #True)
      debugMsg(sProcName, "returned from openMediaFile()")
      
      \sFileTitle = grFileInfo\sFileTitle
      
      If \bAudTypeF
        u2 = preChangeSubS(aSub(\nSubIndex)\sSubDescr, GGT(WQF\lblFileName), \nSubIndex)
        If grEditingOptions\bIgnoreTitleTags
          aSub(\nSubIndex)\sSubDescr = ignoreExtension(GetFilePart(\sFileName))
        Else
          aSub(\nSubIndex)\sSubDescr = \sFileTitle
        EndIf
        If WQF_populateFileTypeExt(nEditAudPtr) ; returns #True if file type or file title changed
          debugMsg(sProcName, "calling setSubNodeText(" + Str(\nSubIndex) + ")")
          WED_setSubNodeText(\nSubIndex)
        EndIf
        debugMsg(sProcName, "calling setAudDescrsForAorP(" + getSubLabel(\nSubIndex) + ")")
        setAudDescrsForAorP(\nSubIndex)
        debugMsg(sProcName, "calling setDefaultSubDescr()")
        setDefaultSubDescr()
        SGT(WQF\txtSubDescr, aSub(\nSubIndex)\sSubDescr)
        setSubDescrToolTip(WQF\txtSubDescr)
        postChangeSubS(u2, aSub(\nSubIndex)\sSubDescr, \nSubIndex)
      EndIf
      
      debugMsg(sProcName, "calling displayFileInfo()")
      WQF_displayFileInfo()
      
      If (aCue(nEditCuePtr)\bDefaultCueDescrMayBeSet) And (\nPrevAudIndex = -1) And (aSub(\nSubIndex)\nPrevSubIndex = -1)
        u2 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, GGT(WQF\lblFileName))
        If grEditingOptions\bIgnoreTitleTags
          aCue(nEditCuePtr)\sCueDescr = ignoreExtension(GetFilePart(\sFileName))
        Else
          aCue(nEditCuePtr)\sCueDescr = \sFileTitle
        EndIf
        If GGT(WEC\txtDescr) <> aCue(nEditCuePtr)\sCueDescr
          SGT(WEC\txtDescr, aCue(nEditCuePtr)\sCueDescr)
          WED_setCueNodeText(nEditCuePtr)
          aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
        EndIf
        postChangeCueS(u2, aCue(nEditCuePtr)\sCueDescr)
      EndIf
      
      loadGridRow(nEditCuePtr)
      
      If \bAudTypeF
        If (aSub(\nSubIndex)\nPrevSubIndex >= 0) Or (aSub(\nSubIndex)\nNextSubIndex >= 0)
          ; multiple sub-cues
          WED_setCueNodeText(nEditCuePtr)
        EndIf
        editSetDisplayButtonsF()
      EndIf
      
      nCurrPos = -1
      DoEvents()
      
      WQF_initGraphInfo()
      debugMsg(sProcName, "calling prepareAndDisplayGraph(@grMG2)")
      prepareAndDisplayGraph(@grMG2)
      
      setFileSave()
      
      debugMsg(sProcName, "calling postChangeAudS(" + u + ", " + \sFileName + ")")
      postChangeAudS(u, \sFileName)
      
      If \bAudPlaceHolder = #False
        THR_createOrResumeAThread(#SCS_THREAD_GET_FILE_STATS)
      EndIf
      
    EndWith
    rWQF\bCallSetOrigDBLevels = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnBrowse_Click()
  PROCNAMEC()
  Protected sOldFileName.s, sNewFileName.s, nFileCount
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    sOldFileName = aAud(nEditAudPtr)\sFileName
  EndIf
  
  Select grEditingOptions\nAudioFileSelector
    Case #SCS_FO_SCS_AFS
      ; SCS 'Audio File Selector' - slower and less efficient than the Windows File Selector BUT includes audio preview capability
      WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AudioFile", #False)
      
    Case #SCS_FO_WINDOWS_FS
      ; Standard Windows File Selector
      nFileCount = audioFileRequester(Lang("Requesters", "AudioFile"), #False, #WED, sOldFileName)
      If nFileCount = 0
        ProcedureReturn
      EndIf
      sNewFileName = gsSelectedDirectory + gsSelectedFile(0)
      debugMsg(sProcName, "sNewFileName=" + sNewFileName)
      WQF_setPropertyFileName(sNewFileName)
      SAG(-1)
      ; debugMsg(sProcName, "file=" + GetFilePart(sNewFileName))
      SAW(#WED)
      
  EndSelect
  
  ; Added 5Dec2023 11.10.0de
  gnRefreshCuePtr = nEditCuePtr
  gnRefreshSubPtr = nEditSubPtr
  gnRefreshAudPtr = nEditAudPtr
  gbCallReloadDispPanel = #True ; cause this sub-cue's cue panel to be reloaded to show the new file
  ; End added 5Dec2023 11.10.0de
  
  If nEditAudPtr >= 0
    aAud(nEditAudPtr)\bAudNormSet = #False
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnOther_Click()
  PROCNAMECA(nEditAudPtr)
  Protected bLinkDevsEnabled
  
  CompilerIf #c_cuepanel_multi_dev_select
    If grLicInfo\bDevLinkAvailable
      If grProd\nMaxAudioLogicalDev > 0
        ; at least two audio devices defined in production properties
        bLinkDevsEnabled = #True
      EndIf
      scsEnableMenuItem(#WQF_mnu_Other, #WQF_mnu_CallLinkDevs, bLinkDevsEnabled)
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, "calling DisplayPopupMenu(#WQF_mnu_Other, WindowID(#WED))")
  DisplayPopupMenu(#WQF_mnu_Other, WindowID(#WED))
EndProcedure

Procedure WQF_mnuClearAll()
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  u = preChangeAudL(#True, "Clear")
  
  With aAud(nEditAudPtr)
    \nStartAt = grAudDef\nStartAt
    \nEndAt = grAudDef\nEndAt
    \nMaxLoopInfo = grAudDef\nMaxLoopInfo
    \rCurrLoopInfo = grAudDef\rCurrLoopInfo
    \nFadeInTime = grAudDef\nFadeInTime
    \nFadeOutTime = grAudDef\nFadeOutTime
    \nFadeInType = grAudDef\nFadeInType
    \nFadeOutType = grAudDef\nFadeOutType
    \nCurrFadeInTime = \nFadeInTime
    \nCurrFadeOutTime = \nFadeOutTime
    \bLoopLinked = grAudDef\bLoopLinked
    
    \sStartAtCPName = grAudDef\sStartAtCPName
    \qStartAtSamplePos = grAudDef\qStartAtSamplePos
    \dStartAtCPTime = grAudDef\dStartAtCPTime
    \sEndAtCPName = grAudDef\sEndAtCPName
    \qEndAtSamplePos = grAudDef\qEndAtSamplePos
    \dEndAtCPTime = grAudDef\dEndAtCPTime
    
    \bAudNormSet = #False
  
    clearLevelPoints(nEditAudPtr)
    WQF_populateCboDevSel()
    
    setDerivedAudFields(nEditAudPtr)
    debugMsg(sProcName, "calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
    setBassLoopStart(nEditAudPtr)
    debugMsg(sProcName, "calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
    setBassLoopEnd(nEditAudPtr)
    debugMsg(sProcName, "calling rewindAud(" + getAudLabel(nEditAudPtr) + ")")
    rewindAud(nEditAudPtr)
    
    debugMsg(sProcName, "calling WQF_displayFileInfo(True, True)")
    WQF_displayFileInfo(#True, #True)
    
    debugMsg(sProcName, "calling WQF_processDevSel()")
    WQF_processDevSel()
    
    If grGraph2\bGraphVisible
      grMG2\nLastTimeMark = -1
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
      debugMsg(sProcName, "calling drawWholeGraphArea()")
      drawWholeGraphArea()
      WQF_btnViewAll_Click()
    EndIf
    
    \bCheckProgSlider = #False
    
  EndWith
  
  rWQF\bCallSetOrigDBLevels = #True
  
  postChangeAudLN(u, #False)
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_mnuResetAll()
  PROCNAMECA(nEditAudPtr)
  Protected k, l2
  Protected u
  Protected nLevelPointIndex
  
  debugMsg(sProcName, #SCS_START)
  
  u = preChangeAudL(#True, "Reset")
  
  With aAud(nEditAudPtr)
    If \nPreEditPtr <= 0
      WQF_mnuClearAll()
    Else
      k = \nPreEditPtr
      \nStartAt = gaHoldAud(k)\nStartAt
      \nEndAt = gaHoldAud(k)\nEndAt
      \nAbsStartAt = gaHoldAud(k)\nAbsStartAt
      \nAbsEndAt = gaHoldAud(k)\nAbsEndAt
      \nMaxLoopInfo = gaHoldAud(k)\nMaxLoopInfo
      For l2 = 0 To \nMaxLoopInfo
        \aLoopInfo(l2) = gaHoldAud(k)\aLoopInfo(l2)
      Next l2
      \rCurrLoopInfo = gaHoldAud(k)\rCurrLoopInfo
      \nFadeInTime = gaHoldAud(k)\nFadeInTime
      \nFadeOutTime = gaHoldAud(k)\nFadeOutTime
      \nFadeInType = gaHoldAud(k)\nFadeInType
      \nFadeOutType = gaHoldAud(k)\nFadeOutType
      
      \sStartAtCPName = gaHoldAud(k)\sStartAtCPName
      \qStartAtSamplePos = gaHoldAud(k)\qStartAtSamplePos
      \dStartAtCPTime = gaHoldAud(k)\dStartAtCPTime
      \sEndAtCPName = gaHoldAud(k)\sEndAtCPName
      \qEndAtSamplePos = gaHoldAud(k)\qEndAtSamplePos
      \dEndAtCPTime = gaHoldAud(k)\dEndAtCPTime
      
      \bAudNormSet = #False
      
      \nCurrFadeInTime = \nFadeInTime
      \nCurrFadeOutTime = \nFadeOutTime
      
      debugMsg(sProcName, "\nMaxLevelPoint=" + \nMaxLevelPoint + ", gaHoldAud(k)\nMaxLevelPoint=" + gaHoldAud(k)\nMaxLevelPoint)
      \nMaxLevelPoint = gaHoldAud(k)\nMaxLevelPoint
      For nLevelPointIndex = 0 To \nMaxLevelPoint
        \aPoint(nLevelPointIndex) = gaHoldAud(k)\aPoint(nLevelPointIndex)
      Next nLevelPointIndex
      WQF_populateCboDevSel()
      
      setDerivedAudFields(nEditAudPtr)
      debugMsg(sProcName, "calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
      setBassLoopStart(nEditAudPtr)
      debugMsg(sProcName, "calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
      setBassLoopEnd(nEditAudPtr)
      debugMsg(sProcName, "calling rewindAud(" + getAudLabel(nEditAudPtr) + ")")
      rewindAud(nEditAudPtr)
      
      debugMsg(sProcName, "calling WQF_displayFileInfo(True, True)")
      WQF_displayFileInfo(#True, #True)
      
      debugMsg(sProcName, "calling WQF_processDevSel()")
      WQF_processDevSel()
      
      debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
      setBassMarkerPositions(nEditAudPtr)
      
      If grGraph2\bGraphVisible
        grMG2\nLastTimeMark = -1
        debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
        debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
        WQF_btnViewAll_Click()
      EndIf
      
    EndIf
  EndWith
  
  rWQF\bCallSetOrigDBLevels = #True
  
  postChangeAudLN(u, #False)
  
  SAG(-1)
  
  debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(nEditAudPtr) + ")")
  listLevelPoints(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnViewAll_Click()
  PROCNAMEC()
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      grMG2\dSamplePositionsPerPixel = 0.0 ; forces \dSamplePositionsPerPixel to be recalculated
      debugMsg(sProcName, "calling resetGraphView(@grMG2, 0, " + Str(\nFileDuration-1) + ", #True)")
      resetGraphView(@grMG2, 0, (\nFileDuration-1), #True)
      WQF_setZoomTrackBar()
      WQF_setPosSlider()
      WQF_setViewControls()
    EndWith
    SAG(-1)
  EndIf
EndProcedure

Procedure WQF_btnViewPlayable_Click()
  PROCNAMECA(nEditAudPtr)
  Protected nPlayableStart, nPlayableEnd, nMaxTime, nValue
  Protected bForceSave, bForceDoNotSave
  
  debugMsg(sProcName, #SCS_START)
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      debugMsg(sProcName, "\nAbsStartAt=" + \nAbsStartAt + ", \nAbsEndAt=" + \nAbsEndAt + ", \nMaxLoopInfo=" + \nMaxLoopInfo)
      nPlayableStart = \nAbsStartAt
      nPlayableEnd = \nAbsEndAt
      nMaxTime = \nFileDuration - 1
      If \nMaxLoopInfo >= 0
        If \aLoopInfo(0)\nAbsLoopStart < nPlayableStart
          nPlayableStart = \aLoopInfo(0)\nAbsLoopStart
        EndIf
        If \aLoopInfo(\nMaxLoopInfo)\nAbsLoopEnd > nPlayableEnd
          nPlayableEnd = \aLoopInfo(\nMaxLoopInfo)\nAbsLoopEnd
        EndIf
      EndIf
      If (nPlayableStart = 0) And (nPlayableEnd = nMaxTime)
        bForceSave = #True
      EndIf
      grMG2\dSamplePositionsPerPixel = 0.0 ; forces \dSamplePositionsPerPixel to be recalculated
      ; debugMsg(sProcName, "calling resetGraphView(@grMG2, " + nPlayableStart + ", " + nPlayableEnd + ", " + strB(bForceSave) + ", " + strB(bForceDoNotSave) + ")")
      resetGraphView(@grMG2, nPlayableStart, nPlayableEnd, bForceSave, bForceDoNotSave)
      ; debugMsg(sProcName, "calling WQF_setZoomTrackBar")
      WQF_setZoomTrackBar()
      ; debugMsg(sProcName, "calling WQF_setPosSlider()")
      WQF_setPosSlider()
      ; debugMsg(sProcName, "calling WQF_setViewControls()")
      WQF_setViewControls()
      ; debugMsg(sProcName, "SLD_getValue(WQF\sldPosition)=" + SLD_getValue(WQF\sldPosition))
      
      ; NOTE: The call to SLD_adjustButton() below results in an inaccurate 'View Playable' display.
      ; NOTE: From testing on 4May2023 11.10.2cl it does NOT seem to be necessary to call SLD_adjustButton(), so is now omitted.
;       ; Added 1Feb2022 11.9.0rc7 - seems we need to call SLD_adjustButton() followed by WQF_processPositionChange() for this horizontal scrollbar
;       ; May need to examine this further. Note that WQF\sldPosition is the ONLY slider in SCS with slider type #SCS_ST_HSCROLLBAR.
;       ; debugMsg(sProcName, "calling SLD_adjustButton(WQF\sldPosition, 0, 0, #True)")
;       SLD_adjustButton(WQF\sldPosition, 0, 0, #True)
;       ; debugMsg(sProcName, "SLD_getValue(WQF\sldPosition)=" + SLD_getValue(WQF\sldPosition))
      ; NOTE: End of chage reomitting calling to SLD_adjustButton()
      
      nValue = SLD_getValue(WQF\sldPosition)
      ; debugMsg(sProcName, "calling WQF_processPositionChange(" + nValue + ")")
      WQF_processPositionChange(nValue)
      ; End added 1Feb2022 11.9.0rc7
    EndWith
    SAG(-1)
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_Form_Load()
  PROCNAMEC()
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQF()
  SUB_loadOrResizeHeaderFields("F", #True)
  
  rWQF\bInValidate = #False
  rWQF\bChangingCurrPos = #False
  
  For d = 0 To grLicInfo\nMaxAudDevPerAud
    populateCboTrim(WQF\cboTrim[d])
  Next d
  
  WQF_populateCboLevelSel()
  WQF_populateCboPanSel()
  
  With WQF
    ClearGadgetItems(\cboGraphDisplayMode)
    addGadgetItemWithData(\cboGraphDisplayMode, Lang("WQF", "GraphFile"), #SCS_GRAPH_FILE)
    addGadgetItemWithData(\cboGraphDisplayMode, Lang("WQF", "GraphFileN"), #SCS_GRAPH_FILEN)
    addGadgetItemWithData(\cboGraphDisplayMode, Lang("WQF", "GraphAdj"), #SCS_GRAPH_ADJ)
    addGadgetItemWithData(\cboGraphDisplayMode, Lang("WQF", "GraphAdjN"), #SCS_GRAPH_ADJN)
    setComboBoxWidth(\cboGraphDisplayMode)
  EndWith
  
  ; debugMsg(sProcName, "calling graphInit(@grMG2)")
  graphInit(@grMG2)
  
  ; debugMsg(sProcName, "calling WQF_drawForm()")
  WQF_drawForm()
  
  With WQF
    ; Call "SLD_ToolTip(\sldProgress, #SCS_SLD_TTA_BUILD, ...)" now because if we wait until the tooltip is required then the first time the tooltip
    ; is displayed it will be displayed blank. I don't know why - tried adding some timing delays but they didn't help. But by 'building' the tooltip
    ; early (eg on creating the form), the tooltip displays correctly every time.
    ; Similarly for WQA and WQP.
    gaSlider(\sldProgress)\nSliderToolTipType = #SCS_SLD_TTT_GENERAL
    SLD_ToolTip(\sldProgress, #SCS_SLD_TTA_BUILD, buildSkipBackForwardTooltip())
  EndWith
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQF_sldProgress_Common(nSliderEventType)
  PROCNAMECA(nEditAudPtr)
  Protected nAbsReposAt, l2, bReposition
  
  With aAud(nEditAudPtr)
    
    Select nSliderEventType
      Case #SCS_SLD_EVENT_MOUSE_UP
        bReposition = #True
      Case #SCS_SLD_EVENT_SCROLL
        If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
          If gnCurrAudioDriver <> #SCS_DRV_SMS_ASIO
            bReposition = #True
          EndIf
        EndIf
    EndSelect
    
    debugMsg(sProcName, "nSliderEventType=" + nSliderEventType + ", bReposition=" + strB(bReposition))
    If bReposition
      debugMsg(sProcName, "nSliderEventType=" + SLD_decodeEvent(nSliderEventType) + ", \nAudState=" + decodeCueState(\nAudState))
      gqTimeNow = ElapsedMilliseconds()
      nAbsReposAt = SLD_getValue(WQF\sldProgress) + \nAbsMin
      debugMsg(sProcName, "sldProgress.value=" + SLD_getValue(WQF\sldProgress) + ", nAbsReposAt=" + nAbsReposAt)
      reposAuds(nEditAudPtr, nAbsReposAt)
      editSetDisplayButtonsF()
      redrawGraphAfterMouseChange(@grMG2)
      l2 = \nCurrLoopInfoIndex
      ; debugMsg(sProcName, "l2=" + l2)
      If l2 >= 0
        If nAbsReposAt < \rCurrLoopInfo\nAbsLoopEnd 
          \aLoopInfo(l2)\bLoopReleased = #False
          \rCurrLoopInfo\bLoopReleased = #False
        Else
          \aLoopInfo(l2)\bLoopReleased = #True
          \rCurrLoopInfo\bLoopReleased = #True
        EndIf
      EndIf
      rWQF\bEditProgMouseDown = #False
    EndIf
  EndWith
  
EndProcedure

Procedure WQF_skipBackOrForward(nSkipTime)
  PROCNAMECA(nEditAudPtr)
  ; code based on WQF_sldProgress_Common()
  Protected nValue, nAbsReposAt, l2
  
  debugMsg(sProcName, #SCS_START + ", nSkipTime=" + nSkipTime)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nValue = SLD_getValue(WQF\sldProgress) + nSkipTime
      If nValue < SLD_getMin(WQF\sldProgress)
        nValue = SLD_getMin(WQF\sldProgress)
      ElseIf nValue > SLD_getMax(WQF\sldProgress)
        nValue = SLD_getMax(WQF\sldProgress)
      EndIf
      SLD_setValue(WQF\sldProgress, nValue, #True)
      
      gqTimeNow = ElapsedMilliseconds()
      nAbsReposAt = nValue + \nAbsMin
      debugMsg(sProcName, "sldProgress\value=" + SLD_getValue(WQF\sldProgress) + ", nAbsReposAt=" + nAbsReposAt)
      reposAuds(nEditAudPtr, nAbsReposAt)
      editSetDisplayButtonsF()
      redrawGraphAfterMouseChange(@grMG2)
      l2 = \nCurrLoopInfoIndex
      ; debugMsg(sProcName, "l2=" + l2)
      If l2 >= 0
        If nAbsReposAt < \rCurrLoopInfo\nAbsLoopEnd 
          \aLoopInfo(l2)\bLoopReleased = #False
          \rCurrLoopInfo\bLoopReleased = #False
        Else
          \aLoopInfo(l2)\bLoopReleased = #True
          \rCurrLoopInfo\bLoopReleased = #True
        EndIf
      EndIf
      
    EndWith
  EndIf

EndProcedure

Procedure WQF_processPositionChange(nValue)
  PROCNAMECA(nEditAudPtr)
  Protected nViewStart, nViewEnd, nViewRange
  Protected qNewViewStart.q   ; needs to be quad to handle large files (eg > 5mins)
  Protected nLeft
  Protected nPositionSliderMin, nPositionSliderMax,  nPositionSliderRange
  Protected bDrawGraph
  
  ; debugMsg(sProcName, #SCS_START + ", nValue=" + nValue)
  
  If nEditAudPtr >= 0
    If aAud(nEditAudPtr)\nFileDataPtr < 0
      ProcedureReturn
    EndIf
  EndIf
  
  nPositionSliderMin = SLD_getMin(WQF\sldPosition)
  nPositionSliderMax = SLD_getMax(WQF\sldPosition)
  nPositionSliderRange = nPositionSliderMax - nPositionSliderMin + 1
  
  ; debugMsg(sProcName, "nPositionSliderMin=" + nPositionSliderMin + ", nPositionSliderMax=" + nPositionSliderMax + ", nPositionSliderRange=" + nPositionSliderRange + ", nValue=" + nValue)
  
  With grMG2
    nViewStart = \nGraphLeft * -1 * \fMillisecondsPerPixel
    nViewEnd = ((\nGraphLeft * -1) + \nVisibleWidth) * \fMillisecondsPerPixel
    If nViewStart < 0
      nViewStart = 0
    EndIf
    If nViewEnd > \nFileDuration
      nViewEnd = \nFileDuration - 1
    EndIf
    nViewRange = nViewEnd - nViewStart + 1
    ; debugMsg(sProcName, "nViewStart=" + nViewStart + ", nViewEnd=" + nViewEnd + ", nViewRange=" + nViewRange + ", \nFileDuration=" + \nFileDuration)
    
    If nViewRange < \nFileDuration
      ; debugMsg(sProcName, "nValue=" + nValue + ", nPositionSliderMax=" + nPositionSliderMax)
      If nValue < nPositionSliderMax
        qNewViewStart = (nValue - nPositionSliderMin) * (\nFileDuration - nViewRange) / nPositionSliderRange
        ; debugMsg(sProcName, "nValue=" + nValue + ", qNewViewStart=" + qNewViewStart + ", \nFileDuration=" + \nFileDuration +
        ;                     ", nViewRange=" + nViewRange + ", nPositionSliderRange=" + nPositionSliderRange)
        nLeft = qNewViewStart / \fMillisecondsPerPixel * -1
        ; debugMsg(sProcName, "qNewViewStart=" + qNewViewStart + ", grMG2\fMillisecondsPerPixel=" + \fMillisecondsPerPixel + ", nLeft=" + nLeft)
      Else
        nLeft = \nVisibleWidth - \nGraphWidth
        ; debugMsg(sProcName, "grMG2\nVisibleWidth=" + \nVisibleWidth + "\nGraphWidth=" + \nGraphWidth + ", nLeft=" + nLeft)
      EndIf
    Else
      nLeft = 0
    EndIf
    If \nFileDataPtrForSlicePeakAndMinArrays >= 0
      bDrawGraph = #True
      If \nAudPtr = nEditAudPtr
        If (\bCurrSldPositionValueSet) And (\nCurrSldPositionValue = nValue)
          If nLeft = \nGraphLeft
            bDrawGraph = #False
          EndIf
        EndIf
      EndIf
    EndIf
    If bDrawGraph
      \nGraphLeft = nLeft
      ; debugMsg(sProcName, "grMG2\nGraphLeft=" + \nGraphLeft)
      ; debugMsg(sProcName, "calling drawWholeGraphArea()")
      drawWholeGraphArea()
      \nCurrSldPositionValue = nValue
      \bCurrSldPositionValueSet = #True
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQF_sldPosition_Change()
  PROCNAMECA(nEditAudPtr)
  Protected nValue
  
  nValue = SLD_getValue(WQF\sldPosition)
  WQF_processPositionChange(nValue)
  
EndProcedure

Procedure WQF_sldPosition_Event(nSliderEventType)
  PROCNAMECA(nEditAudPtr)
  Protected nValue
  
  debugMsg(sProcName, #SCS_START + ", nSliderEventType=" + nSliderEventType)
  Select nSliderEventType
    Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_MOUSE_UP, #SCS_SLD_EVENT_SCROLL
      nValue = SLD_getValue(WQF\sldPosition)
      debugMsg(sProcName, "calling WQF_processPositionChange(" + nValue + ")")
      WQF_processPositionChange(nValue)
  EndSelect
  
EndProcedure

Procedure WQF_processZoom(bForceProcessing=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nThisTrbZoomValue
  Protected bZoomChanged  ; added 13Nov2015 11.4.1.2k
  
  debugMsg(sProcName, #SCS_START + ", bForceProcessing=" + strB(bForceProcessing))
  
  nThisTrbZoomValue = GGS(WQF\trbZoom)
  debugMsg(sProcName, "nThisTrbZoomValue=" + nThisTrbZoomValue + ", rWQF\nLastTrbZoomValue=" + rWQF\nLastTrbZoomValue)
  
  If nEditAudPtr >= 0
    If (nThisTrbZoomValue <> rWQF\nLastTrbZoomValue) Or (bForceProcessing)
      bZoomChanged = #True
      rWQF\nLastTrbZoomValue = nThisTrbZoomValue
      calcViewStartAndEnd(@grMG2, nEditAudPtr)
      With grMG2
        \nFileDuration = aAud(nEditAudPtr)\nFileDuration    ; added 27Oct2015 11.4.1.2b
        \dSamplePositionsPerPixel = 0.0                     ; forces \dSamplePositionsPerPixel to be recalculated
        debugMsg(sProcName, "calling resetGraphView(@grMG2, " + \nViewStart + ", " + \nViewEnd + ")")
        resetGraphView(@grMG2, \nViewStart, \nViewEnd)
        WQF_setViewControls()
      EndWith
      
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bZoomChanged))
  ProcedureReturn bZoomChanged
  
EndProcedure

Procedure WQF_trbZoom_Change()
  PROCNAMECA(nEditAudPtr)
  Protected bZoomChanged
  
  ; debugMsg(sProcName, #SCS_START)
  
  bZoomChanged = WQF_processZoom()
  If bZoomChanged
    ; debugMsg(sProcName, "calling WQF_setPosSlider()")
    WQF_setPosSlider()
    ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysAndDrawGraph(@grMG2)")
    loadSlicePeakAndMinArraysAndDrawGraph(@grMG2)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtEndAt_KeyDown(nEventMenu)
  PROCNAMEC()
  Protected nMin, nMax
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  If bumpKey(nEventMenu)
    If validateTimeFieldT(GGT(WQF\txtEndAt), GGT(WQF\lblEndAt), #True, #False, aAud(nEditAudPtr)\nFileDuration)
      nMin = aAud(nEditAudPtr)\nAbsStartAt
      nMax = aAud(nEditAudPtr)\nFileDuration - 1
      If bumpTimeField(WQF\txtEndAt, nMin, nMax, nMax, nEventMenu)
        WQF_txtEndAt_Validate()
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure WQF_txtLoopEnd_KeyDown(nEventMenu)
  PROCNAMEC()
  Protected nMin, nMax, l2
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  With aAud(nEditAudPtr)
    If bumpKey(nEventMenu)
      If validateTimeFieldT(GGT(WQF\txtLoopEnd), GGT(WQF\lblLoopEnd), #True, #False, \nFileDuration) = #True
        l2 = rWQF\nDisplayedLoopInfoIndex
        nMin = \aLoopInfo(l2)\nAbsLoopStart
        nMax = \nFileDuration - 1
        If bumpTimeField(WQF\txtLoopEnd, nMin, nMax, nMax, nEventMenu)
          WQF_txtLoopEnd_Validate()
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WQF_txtLoopStart_KeyDown(nEventMenu)
  PROCNAMEC()
  Protected nMin, nMax, l2
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  With aAud(nEditAudPtr)
    If bumpKey(nEventMenu)
      If validateTimeFieldT(GGT(WQF\txtLoopStart), GGT(WQF\lblLoopStart), #True, #False, \nFileDuration)
        l2 = rWQF\nDisplayedLoopInfoIndex
        nMin = 0
        nMax = \aLoopInfo(l2)\nAbsLoopEnd
        If nMax = 0
          nMax = \nFileDuration - 1
        EndIf
        If bumpTimeField(WQF\txtLoopStart, nMin, nMax, nMin, nEventMenu)
          WQF_txtLoopStart_Validate()
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WQF_txtFadeInTime_KeyDown(nEventMenu)
  PROCNAMEC()
  Protected nMin, nMax
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  If bumpKey(nEventMenu)
    If validateTimeFieldT(GGT(WQF\txtFadeInTime), GGT(WQF\lblFadeInTime), #False, #False, aAud(nEditAudPtr)\nFileDuration)
      nMin = 0
      nMax = getMaxFadeInTime(nEditAudPtr)
      If bumpTimeField(WQF\txtFadeInTime, nMin, nMax, nMin, nEventMenu)
        WQF_txtFadeInTime_Validate()
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure WQF_txtFadeOutTime_KeyDown(nEventMenu)
  PROCNAMEC()
  Protected nMin, nMax
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  If bumpKey(nEventMenu)
    If validateTimeFieldT(GGT(WQF\txtFadeOutTime), GGT(WQF\lblFadeOutTime), #False, #False, aAud(nEditAudPtr)\nFileDuration)
      nMin = 0
      nMax = getMaxFadeOutTime(nEditAudPtr)
      If bumpTimeField(WQF\txtFadeOutTime, nMin, nMax, nMin, nEventMenu)
        WQF_txtFadeOutTime_Validate()
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure WQF_txtLoopXFadeTime_KeyDown(nEventMenu)
  PROCNAMEC()
  Protected nMin, nMax
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  If bumpKey(nEventMenu)
    If validateTimeFieldT(GGT(WQF\txtLoopXFadeTime), GGT(WQF\lblLoopXFadeTime), #False, #False, aAud(nEditAudPtr)\nFileDuration)
      nMin = 0
      nMax = getMaxLoopXFadeTime(nEditAudPtr)
      If bumpTimeField(WQF\txtLoopXFadeTime, nMin, nMax, nMin, nEventMenu)
        WQF_txtLoopXFadeTime_Validate()
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure WQF_txtLoopStart_Validate(pCallingModule=#WQF, bUsingCuePoint=#False, bReturnBeforeUpdate=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nOldLoopStart
  Protected nTime, dTimeDbl.d
  Protected nTextGadget, nLabelGadget
  Protected sMsg.s
  Protected l2
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + Str(pCallingModule) + ", bUsingCuePoint=" + strB(bUsingCuePoint))
  
  If pCallingModule = #WEM
    nTextGadget = WEM\txtValue
    nLabelGadget = WEM\lblField
  Else
    nTextGadget = WQF\txtLoopStart
    nLabelGadget = WQF\lblLoopStart
  EndIf
  
  debugMsg(sProcName, "txtLoopStart=" + GGT(nTextGadget))
  
  l2 = rWQF\nDisplayedLoopInfoIndex
  
  If bUsingCuePoint = #False
    If validateTimeFieldT(GGT(nTextGadget), GGT(nLabelGadget), #True, #False, aAud(nEditAudPtr)\nFileDuration) = #False
      rWQF\bInValidate = #False
      ProcedureReturn #False
    EndIf
    If GGT(nTextGadget) <> gsTmpString
      SGT(nTextGadget, gsTmpString)
    EndIf
  EndIf
  
  With aAud(nEditAudPtr)\aLoopInfo(l2)
    If bUsingCuePoint
      dTimeDbl = stringToTimeDbl(GGT(nTextGadget))
      If dTimeDbl >= 0.0
        nTime = Int(dTimeDbl * 1000)
      Else
        nTime = Int(dTimeDbl)
      EndIf
    Else
      nTime = stringToTime(GGT(nTextGadget))
    EndIf
    
    If nTime >= 0
      If (\nLoopEnd >= 0) And (nTime > \nAbsLoopEnd)
        ; do not throw error if loop start = \nAbsLoopEnd as this prevents user altering field via graph
        sMsg = LangPars("Errors", "MustBeLessThan", GLT(WQF\lblLoopStart) + " (" + ttszt(nTime) + ")", GLT(WQF\lblLoopEnd) + " (" + ttszt(\nAbsLoopEnd) + ")")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        rWQF\bInValidate = #False
        ProcedureReturn #False
      EndIf
    EndIf
    
    If bReturnBeforeUpdate
      ProcedureReturn #True
    EndIf
    
    WQF_setPropertyLoopStart(l2, nTime, bUsingCuePoint, pCallingModule)
    setLoopAddBtnEnabledState()
    
  EndWith
  rWQF\bInValidate = #False
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WQF_setPropertyFadeInTime(sNewFadeInTime.s, nNewFadeInTime, sUndoDescr.s, nCallingModule=#WQF, nTimeFieldIsParamId=0)
  PROCNAMECA(nEditAudPtr)
  ; The value in nTimeFieldIsParamId will have been set by the macro macCommonTimeFieldValidationT in Macros.pbi, and possible values are:
  ;   0 - sNewFadeInTime is not a call cue parameter, ie it doesn't start with A-Z or a-z
  ;   1 - sNewFadeInTime is a call cue parameter that was found in the parent cue's parameter list
  Protected u
  Protected nOldFadeInTime, nMyNewFadeInTime
  Protected sParamDefault.s, nParamDefault
  Protected nTmpPos
  Protected sOld.s, sNew.s, sValue.s
  Protected nLevelPointIndex
  
  debugMsg(sProcName, #SCS_START + ", sNewFadeInTime=" + sNewFadeInTime + ", nNewFadeInTime=" + nNewFadeInTime + ", nCallingModule=" + nCallingModule + ", nTimeFieldIsParamId=" + nTimeFieldIsParamId)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      sOld = makeDisplayTimeValue(\sFadeInTime, \nFadeInTime)
      u = preChangeAudS(sOld, sUndoDescr)
      nOldFadeInTime = \nFadeInTime
      
      Select nCallingModule
        Case #WQF
          sValue = Trim(GGT(WQF\txtFadeInTime))
        Case #WCP ; copy properties
          sValue = makeDisplayTimeValue(sNewFadeInTime, nNewFadeInTime)
      EndSelect
      macReadNumericOrStringParam(sValue, \sFadeInTime, \nFadeInTime, grAudDef\nFadeInTime, #True)
      ; Macro macReadNumericOrStringParam populates \nFadeInTime from the value in sValue
      If nTimeFieldIsParamId = 1
        ; sNewFadeInTime is a call cue parameter that was found in the parent cue's parameter list
        sParamDefault = getCallableCueParamDefault(@aCue(nEditCuePtr), sNewFadeInTime)
        debugMsg(sProcName, "sParamDefault=" + sParamDefault)
        If sParamDefault
          \nFadeInTime = stringToTime(sParamDefault)
        Else
          ; no parameter default
          \nFadeInTime = 1 ; 'dummy' value (1 millisecond) so that a Fade In Level Point will be created
        EndIf
      Else
        \nFadeInTime = nNewFadeInTime
      EndIf
      \nCurrFadeInTime = \nFadeInTime
      WQF_setClearState()
      
      If \nFadeInTime > 0
        nTmpPos = \nAbsStartAt + \nFadeInTime
        If nTmpPos <= \nAbsEndAt
          grMG2\nLastTimeMark = nTmpPos
          debugMsg(sProcName, "grMG2\nLastTimeMark=" + grMG2\nLastTimeMark)
        EndIf
      EndIf
      
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\sFadeInTime=" + \sFadeInTime + ", \nFadeInTime=" + \nFadeInTime)
      If \sFadeInTime And 1=2
        ; If fade-in time is a callable cue parameter then the fade-in level point will be set at runtime
        nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, #SCS_PT_FADE_IN)
        If nLevelPointIndex >= 0
          removeOneLevelPoint(nEditAudPtr, nLevelPointIndex)
        EndIf
      Else
        debugMsg(sProcName, "calling maintainFadeInLevelPoint(" + getAudLabel(nEditAudPtr) + ", " + nOldFadeInTime + ", " + \nFadeInTime + ")")
        maintainFadeInLevelPoint(nEditAudPtr, nOldFadeInTime, \nFadeInTime)
      EndIf
      
      WQF_populateCboDevSel()
      ; debugMsg(sProcName, "\sFadeInTime=" + \sFadeInTime + ", \nFadeInTime=" + \nFadeInTime)
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
      sNew = makeDisplayTimeValue(\sFadeInTime, \nFadeInTime)
      postChangeAudS(u, sNew)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setPropertyFadeOutTime(sNewFadeOutTime.s, nNewFadeOutTime, sUndoDescr.s, nCallingModule=#WQF, nTimeFieldIsParamId=0)
  PROCNAMECA(nEditAudPtr)
  ; The value in nTimeFieldIsParamId will have been set by the macro macCommonTimeFieldValidationT in Macros.pbi, and possible values are:
  ;   0 - sNewFadeInTime is not a call cue parameter, ie it doesn't start with A-Z or a-z
  ;   1 - sNewFadeInTime is a call cue parameter that was found in the parent cue's parameter list
  Protected u
  Protected sOldFadeOutTime.s, nOldFadeOutTime, nMyNewFadeOutTime
  Protected sParamDefault.s, nParamDefault
  Protected nTmpPos
  Protected sOld.s, sNew.s, sValue.s
  Protected nLevelPointIndex
  
  debugMsg(sProcName, #SCS_START + ", sNewFadeOutTime=" + sNewFadeOutTime + ", nNewFadeOutTime=" + nNewFadeOutTime + ", nCallingModule=" + nCallingModule)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      sOld = makeDisplayTimeValue(\sFadeOutTime, \nFadeOutTime)
      u = preChangeAudS(sOld, sUndoDescr)
      sOldFadeOutTime = \sFadeOutTime
      nOldFadeOutTime = \nFadeOutTime
      
      Select nCallingModule
        Case #WQF
          sValue = Trim(GGT(WQF\txtFadeOutTime))
        Case #WCP ; copy properties
          sValue = makeDisplayTimeValue(sNewFadeOutTime, nNewFadeOutTime)
      EndSelect
      macReadNumericOrStringParam(sValue, \sFadeOutTime, \nFadeOutTime, grAudDef\nFadeOutTime, #True)
      ; Macro macReadNumericOrStringParam populates \sFadeOutTime and \nFadeOutTime from the value in sValue
      If nTimeFieldIsParamId = 1
        ; sNewFadeOutTime is a call cue parameter that was found in the parent cue's parameter list
        sParamDefault = getCallableCueParamDefault(@aCue(nEditCuePtr), sNewFadeOutTime)
        debugMsg(sProcName, "sParamDefault=" + sParamDefault)
        If sParamDefault
          \nFadeOutTime = stringToTime(sParamDefault)
        Else
          ; no parameter default
          \nFadeOutTime = 1 ; 'dummy' value (1 millisecond) so that a Fade In Level Point will be created
        EndIf
      Else
        \nFadeOutTime = nNewFadeOutTime
      EndIf
      \nCurrFadeOutTime = \nFadeOutTime
      WQF_setClearState()
      
      If \nFadeOutTime > 0
        nTmpPos = \nAbsEndAt - \nFadeOutTime
        If nTmpPos >= \nAbsStartAt
          grMG2\nLastTimeMark = nTmpPos
          debugMsg(sProcName, "grMG2\nLastTimeMark=" + grMG2\nLastTimeMark)
        EndIf
      EndIf
      
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\sFadeOutTime=" + \sFadeOutTime + ", \nFadeOutTime=" + \nFadeOutTime)
      If \sFadeOutTime And 1=2
        ; If fade-out time is a callable cue parameter then the fade-out level point will be set at runtime
        nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, #SCS_PT_FADE_OUT)
        If nLevelPointIndex >= 0
          removeOneLevelPoint(nEditAudPtr, nLevelPointIndex)
        EndIf
      Else
        debugMsg(sProcName, "calling maintainFadeOutLevelPoint(" + getAudLabel(nEditAudPtr) + ", " + nOldFadeOutTime + ", " + \nFadeOutTime + ")")
        maintainFadeOutLevelPoint(nEditAudPtr, nOldFadeOutTime, \nFadeOutTime)
      EndIf
      
      WQF_populateCboDevSel()
      ; debugMsg(sProcName, "\sFadeOutTime=" + \sFadeOutTime + ", \nFadeOutTime=" + \nFadeOutTime)
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
      sNew = makeDisplayTimeValue(\sFadeOutTime, \nFadeOutTime)
      postChangeAudS(u, sNew)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtFadeInTime_Validate(pCallingModule=#WQF, bReturnBeforeUpdate=#False)
  ; NOTE: Supports txtFadeInTime being a time field (eg 1.5) or a callable cue parameter (eg FI)
  PROCNAMEC()
  Protected sPrompt.s, sValue.s, nTimeFieldIsParamId
  Protected nTimeGadget, nLabelGadget
  Protected sNewFadeInTime.s, nNewFadeInTime, nMaxFadeInTime
  Protected sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + decodeEditorComponent(pCallingModule) + ", bReturnBeforeUpdate=" + strB(bReturnBeforeUpdate))
  
  If pCallingModule = #WEM
    nTimeGadget = WEM\txtFadeValue
    nLabelGadget = WEM\lblFadeField
  Else
    nTimeGadget = WQF\txtFadeInTime
    nLabelGadget = WQF\lblFadeInTime
  EndIf
  
  sPrompt = removeLF(GGT(nLabelGadget))
  macCommonTimeFieldValidationT(rWQF\bInValidate)
  
  sNewFadeInTime = Trim(GGT(nTimeGadget))
  debugMsg(sProcName, "sNewFadeInTime=" + sNewFadeInTime + ", nTimeFieldIsParamId=" + nTimeFieldIsParamId)
  
  ; The following changed 16Jul2024 11.10.3at following bug reported in emails by John Shea.
  ; The bug was due to this procedure using an IsNumeric() test to check if the value entered is a time, which was OK if no minute component was included,
  ; but a minute component is followed by a colon which causes IsNumeric() to return #False.
  ; In John Shea's run, he had the Time Format Option set to alwyas display minutes.
  ; The use of IsNumeric() is unnecessary, and the procedure has been tidied up to do full checks of nTimeFieldIsParamId values.
  
  If nTimeFieldIsParamId = 0 ; sNewFadeInTime is not a call cue parameter, ie it doesn't start with A-Z or a-z
    nNewFadeInTime = stringToTime(sNewFadeInTime)
    ; debugMsg(sProcName, "nNewFadeInTime=" + nNewFadeInTime)
    nMaxFadeInTime = getMaxFadeInTime(nEditAudPtr)
    If nNewFadeInTime > nMaxFadeInTime
      sErrorMsg = LangPars("Errors", "MustBeLessThan", sPrompt + " (" + ttszt(nNewFadeInTime) + ")", ttszt(nMaxFadeInTime + 1))
    EndIf
    
  ElseIf nTimeFieldIsParamId = 1 ; sNewFadeInTime is a call cue parameter that was found in the parent cue's parameter list
    nNewFadeInTime = 0
    
  ElseIf nTimeFieldIsParamId = -1 ; sNewFadeInTime looks like a call cue parameter but it does not exist in the parent cue's parameter list
    sErrorMsg = LangPars("Errors", "CallableParamNotFound", sNewFadeInTime, aSub(nEditSubPtr)\sSubLabel, aCue(nEditCuePtr)\sCue)
  EndIf
  
  If sErrorMsg
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
  If bReturnBeforeUpdate
    ProcedureReturn #True
  EndIf
  
  WQF_setPropertyFadeInTime(sNewFadeInTime, nNewFadeInTime, sPrompt, pCallingModule, nTimeFieldIsParamId)
  
  clearCtrlHoldLP() ; Added 30Dec2023 11.10.0dt to prevent the possible UNINTENTIONAL scenario of having multiple level points selected in the graph
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQF_txtFadeOutTime_Validate(pCallingModule=#WQF, bReturnBeforeUpdate=#False)
  ; NOTE: Supports txtFadeOutTime being a time field (eg 1.5) or a callable cue parameter (eg FO)
  PROCNAMEC()
  Protected sPrompt.s, sValue.s, nTimeFieldIsParamId
  Protected nTimeGadget, nLabelGadget
  Protected sNewFadeOutTime.s, nNewFadeOutTime, nMaxFadeOutTime
  Protected sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + decodeEditorComponent(pCallingModule) + ", bReturnBeforeUpdate=" + strB(bReturnBeforeUpdate))
  
  If pCallingModule = #WEM
    nTimeGadget = WEM\txtFadeValue
    nLabelGadget = WEM\lblFadeField
  Else
    nTimeGadget = WQF\txtFadeOutTime
    nLabelGadget = WQF\lblFadeOutTime
  EndIf
  
  sPrompt = removeLF(GGT(nLabelGadget))
  macCommonTimeFieldValidationT(rWQF\bInValidate)
  
  sNewFadeOutTime = Trim(GGT(nTimeGadget))
  debugMsg(sProcName, "sNewFadeOutTime=" + sNewFadeOutTime + ", nTimeFieldIsParamId=" + nTimeFieldIsParamId)
  
  ; The following changed 16Jul2024 11.10.3at following bug reported in emails by John Shea.
  ; The bug was due to this procedure using an IsNumeric() test to check if the value entered is a time, which was OK if no minute component was included,
  ; but a minute component is followed by a colon which causes IsNumeric() to return #False.
  ; In John Shea's run, he had the Time Format Option set to alwyas display minutes.
  ; The use of IsNumeric() is unnecessary, and the procedure has been tidied up to do full checks of nTimeFieldIsParamId values.
  
  If nTimeFieldIsParamId = 0 ; sNewFadeOutTime is not a call cue parameter, ie it doesn't start with A-Z or a-z
    nNewFadeOutTime = stringToTime(sNewFadeOutTime)
    ; debugMsg(sProcName, "nNewFadeOutTime=" + nNewFadeOutTime)
    nMaxFadeOutTime = getMaxFadeOutTime(nEditAudPtr)
    If nNewFadeOutTime > nMaxFadeOutTime
      sErrorMsg = LangPars("Errors", "MustBeLessThan", sPrompt + " (" + ttszt(nNewFadeOutTime) + ")", ttszt(nMaxFadeOutTime + 1))
    EndIf
    
  ElseIf nTimeFieldIsParamId = 1 ; sNewFadeOutTime is a call cue parameter that was found in the parent cue's parameter list
    nNewFadeOutTime = 0
    
  ElseIf nTimeFieldIsParamId = -1 ; sNewFadeOutTime looks like a call cue parameter but it does not exist in the parent cue's parameter list
    sErrorMsg = LangPars("Errors", "CallableParamNotFound", sNewFadeOutTime, aSub(nEditSubPtr)\sSubLabel, aCue(nEditCuePtr)\sCue)
    
  EndIf
  
  If sErrorMsg
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
  If bReturnBeforeUpdate
    ProcedureReturn #True
  EndIf
  
  WQF_setPropertyFadeOutTime(sNewFadeOutTime, nNewFadeOutTime, sPrompt, pCallingModule, nTimeFieldIsParamId)
  
  clearCtrlHoldLP() ; Added 30Dec2023 11.10.0dt to prevent the possible UNINTENTIONAL scenario of having multiple level points selected in the graph
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQF_txtCuePosTimeOffset_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  If validateTimeFieldT(GGT(WQF\txtCuePosTimeOffset), GGT(WQF\lblCuePosTimeOffset), #False, #False, 0, #True) = #False
    rWQF\bInValidate = #False
    ProcedureReturn #False
  ElseIf GGT(WQF\txtCuePosTimeOffset) <> gsTmpString
    SGT(WQF\txtCuePosTimeOffset, gsTmpString)
  EndIf
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudL(\nCuePosTimeOffset, GGT(WQF\lblCuePosTimeOffset))
      \nCuePosTimeOffset = stringToTime(GGT(WQF\txtCuePosTimeOffset))
      postChangeAudLN(u, \nCuePosTimeOffset)
    EndWith
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_populateFileTypeExt(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  Protected sFileTypeExt.s
  Protected bChanged
  Static bStaticLoaded, sLength.s
  
  If bStaticLoaded = #False
    sLength = LangColon("Common", "Length")
    bStaticLoaded = #True
  EndIf
  
  With aAud(pAudPtr)
    If (\nAudState = #SCS_CUE_ERROR) And (Len(\sErrorMsg) > 0)
      sFileTypeExt = \sErrorMsg
      scsSetGadgetFont(WQF\txtFileTypeExt, #SCS_FONT_GEN_BOLD)
      SetGadgetColor(WQF\txtFileTypeExt, #PB_Gadget_FrontColor, #SCS_Red)
    ElseIf ((\nAudState >= #SCS_CUE_READY) And (\nAudState <= #SCS_CUE_COMPLETED)) Or (\nFileState = #SCS_FILESTATE_OPEN)
      If \nFileDuration > 0
        sFileTypeExt = sLength + timeToStringT(\nFileDuration)
      EndIf
      If Len(\sFileType) > 0
        If Len(sFileTypeExt) > 0
          sFileTypeExt + ", "
        EndIf
        sFileTypeExt + \sFileType
      EndIf
      If Len(\sFileTitle) > 0
        If ignoreExtension(GetFilePart(\sFileName)) <> \sFileTitle
          If Len(sFileTypeExt) > 0
            sFileTypeExt + ", "
          EndIf
          sFileTypeExt + \sFileTitle
        EndIf
      EndIf
      scsSetGadgetFont(WQF\txtFileTypeExt, #SCS_FONT_GEN_NORMAL)
      SetGadgetColor(WQF\txtFileTypeExt, #PB_Gadget_FrontColor, glSysColGrayText)
    EndIf
    If GGT(WQF\txtFileTypeExt) <> sFileTypeExt
      bChanged = #True
      SetGadgetText(WQF\txtFileTypeExt, sFileTypeExt)
      scsToolTip(WQF\txtFileTypeExt, sFileTypeExt)
    EndIf
  EndWith
  ProcedureReturn bChanged
  
EndProcedure

Procedure WQF_txtFileName_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected sFileExt.s, sFileName.s, sStoredFileName.s
  Protected f.l, v.l
  Protected u, u2, u3
  
  debugMsg(sProcName, #SCS_START)
  If rWQF\bInValidate
    ProcedureReturn #True
  EndIf
  rWQF\bInValidate = #True
  
  rWQF\bValidatingFileName = #True
  sStoredFileName = Trim(GGT(WQF\txtFileName))
  If Len(sStoredFileName) > 0
    
    sFileName = decodeFileName(sStoredFileName, #True)
    
    If FileExists(sFileName) = #False
      debugMsg(sProcName, "sStoredFileName=" + sStoredFileName)
      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "FileNotFound", sFileName), #PB_MessageRequester_Error)
      rWQF\bValidatingFileName = #False
      rWQF\bInValidate = #False
      ProcedureReturn #False
    EndIf
    
    sFileExt = LCase(GetExtensionPart(GGT(WQF\txtFileName)))
    If InStr(gsAudioFileTypes, sFileExt) = 0
      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "FileFormatNotSupported", GGT(WQF\txtFileName)), #PB_MessageRequester_Error)
      rWQF\bValidatingFileName = #False
      rWQF\bInValidate = #False
      ProcedureReturn #False
    EndIf
    
    With aAud(nEditAudPtr)
      
      If sFileName <> \sFileName
        u = preChangeAudS(\sFileName, GGT(WQF\lblFileName), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_OPEN_FILE)
        \sFileName = sFileName
        \sStoredFileName = sStoredFileName
        \nFileDataPtr = grAudDef\nFileDataPtr
        
        WQF_fcFileExt(#False)  ; nb sets \nFileFormat
        
        debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
        setIgnoreDevInds(nEditAudPtr, #True)
        openMediaFile(nEditAudPtr, #True, #SCS_VID_PIC_TARGET_NONE, #False, #False, #True)
        \sFileTitle = grFileInfo\sFileTitle
        
        u2 = preChangeSubS(aSub(\nSubIndex)\sSubDescr, GGT(WQF\lblFileName), \nSubIndex)
        If grEditingOptions\bIgnoreTitleTags
          aSub(\nSubIndex)\sSubDescr = ignoreExtension(GetFilePart(\sFileName))
        Else
          aSub(\nSubIndex)\sSubDescr = \sFileTitle
        EndIf
        
        If WQF_populateFileTypeExt(nEditAudPtr) ; returns #True if file type or file title changed
          debugMsg(sProcName, "calling setSubNodeText(" + getSubLabel(\nSubIndex) + ")")
          WED_setSubNodeText(\nSubIndex)
        EndIf
        debugMsg(sProcName, "calling setAudDescrsForAorP(" + getSubLabel(\nSubIndex) + ")")
        setAudDescrsForAorP(\nSubIndex)
        debugMsg(sProcName, "calling setDefaultSubDescr()")
        setDefaultSubDescr()
        SGT(WQF\txtSubDescr, aSub(\nSubIndex)\sSubDescr)
        setSubDescrToolTip(WQF\txtSubDescr)
        
        WQF_displayFileInfo()
        
        debugMsg(sProcName, "aCue(" + getCueLabel(nEditCuePtr) + ")\bDefaultCueDescrMayBeSet=" + strB(aCue(nEditCuePtr)\bDefaultCueDescrMayBeSet))
        If aCue(nEditCuePtr)\bDefaultCueDescrMayBeSet
          u3 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, GGT(WQF\lblFileName))
          If grEditingOptions\bIgnoreTitleTags
            aCue(nEditCuePtr)\sCueDescr = ignoreExtension(GetFilePart(\sFileName))
          Else
            aCue(nEditCuePtr)\sCueDescr = grFileInfo\sFileTitle
          EndIf
          debugMsg(sProcName, "aCue(" + nEditCuePtr + ")\sCueDescr=" + aCue(nEditCuePtr)\sCueDescr)
          If GGT(WEC\txtDescr) <> aCue(nEditCuePtr)\sCueDescr
            SGT(WEC\txtDescr, aCue(nEditCuePtr)\sCueDescr)
            WED_setCueNodeText(nEditCuePtr)
            aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
          EndIf
          postChangeCueS(u3, aCue(nEditCuePtr)\sCueDescr)
        EndIf
        
        postChangeSubS(u2, aSub(\nSubIndex)\sSubDescr, \nSubIndex)
        
      EndIf
      
      If aSub(\nSubIndex)\nPrevSubIndex >= 0 Or aSub(\nSubIndex)\nNextSubIndex >= 0
        ; multiple sub-cues
        WED_setCueNodeText(nEditCuePtr)
      EndIf
      
      nCurrPos = -1
      
      WQF_initGraphInfo()
      debugMsg(sProcName, "calling prepareAndDisplayGraph(@grMG2)")
      prepareAndDisplayGraph(@grMG2)
      
      setFileSave()
      
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr)
      
      postChangeAudS(u, \sFileName)
      
    EndWith
    
  EndIf
  
  rWQF\bValidatingFileName = #False
  rWQF\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQF_txtFileName_DropFiles()
  PROCNAMEC()
  Protected sFileList.s
  Protected sFileName.s, sStoredFileName.s
  Protected nFileFormat
  
  debugMsg(sProcName, #SCS_START)
  
  sFileList = EventDropFiles()
  sFileName = StringField(sFileList,1,Chr(10))  ; only use first dropped file
  nFileFormat = getFileFormat(sFileName)
  If nFileFormat <> #SCS_FILEFORMAT_AUDIO
    scsMessageRequester(Lang("CED","ValErr"), LangPars("Errors", "FileFormatNotSupported", GetFilePart(sFileName)), #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf
  
  sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
  SGT(WQF\txtFileName, sStoredFileName)
  scsToolTip(WQF\txtFileName, sFileName)
  ; process new filename
  debugMsg(sProcName, "calling WQF_txtFileName_Validate()")
  WQF_txtFileName_Validate()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtLoopEnd_Validate(pCallingModule=#WQF, bUsingCuePoint=#False, bReturnBeforeUpdate=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nOldLoopEnd
  Protected nTime, dTimeDbl.d
  Protected nTextGadget, nLabelGadget
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + Str(pCallingModule) + ", bUsingCuePoint=" + strB(bUsingCuePoint))
  
  If pCallingModule = #WEM
    nTextGadget = WEM\txtValue
    nLabelGadget = WEM\lblField
  Else
    nTextGadget = WQF\txtLoopEnd
    nLabelGadget = WQF\lblLoopEnd
  EndIf
  
  debugMsg(sProcName, "txtLoopEnd=" + GGT(nTextGadget))
  
  If bUsingCuePoint = #False
    If validateTimeFieldT(GGT(nTextGadget), GGT(nLabelGadget), #False, #True, aAud(nEditAudPtr)\nFileDuration) = #False
      rWQF\bInValidate = #False
      ProcedureReturn #False
    EndIf
    debugMsg(sProcName, "gsTmpString=" + gsTmpString)
    If GGT(nTextGadget) <> gsTmpString
      SGT(nTextGadget, gsTmpString)
    EndIf
  EndIf
  
  With aAud(nEditAudPtr)\aLoopInfo(rWQF\nDisplayedLoopInfoIndex)
    If bUsingCuePoint
      dTimeDbl = stringToTimeDbl(GGT(nTextGadget))
      If dTimeDbl >= 0.0
        nTime = Int(dTimeDbl * 1000)
      Else
        nTime = Int(dTimeDbl)
      EndIf
    Else
      nTime = stringToTime(GGT(nTextGadget))
    EndIf
    
    If (\nLoopStart >= 0) And (nTime >= 0)
      If nTime < \nAbsLoopStart
        ; do not throw error if nTime = \nAbsLoopStart as this prevents user altering field via graph
        sMsg = LangPars("Errors", "MustBeGreaterThan", GLT(WQF\lblLoopEnd) + " (" + ttszt(nTime) + ")", GLT(WQF\lblLoopStart) + " (" + ttszt(\nAbsLoopStart) + ")")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        rWQF\bInValidate = #False
        ProcedureReturn #False
      EndIf
    EndIf
    
    If bReturnBeforeUpdate
      ProcedureReturn #True
    EndIf
    
    WQF_setPropertyLoopEnd(rWQF\nDisplayedLoopInfoIndex, nTime, bUsingCuePoint, pCallingModule)
    setLoopAddBtnEnabledState()
    
  EndWith
  rWQF\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQF_setPropertyEndAt(nTime, sUndoDescr.s, bUsingCuePoint=#False, pCallingModule=#WQF)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected bSetFilePosAtStartAt
  
  debugMsg(sProcName, #SCS_START + ", nTime=" + nTime + ", pCallingModule=" + pCallingModule)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudS(Str(\nEndAt)+\sEndAtCPName, sUndoDescr)
      
      If (pCallingModule = #WEM) And (bUsingCuePoint)
        \sEndAtCPName = grWEM\sReqdCPName
        \qEndAtSamplePos = grWEM\qReqdSamplePos
        \dEndAtCPTime = grWEM\dReqdCPTimePos
      Else
        \sEndAtCPName = grAudDef\sEndAtCPName
        \qEndAtSamplePos = grAudDef\qEndAtSamplePos
        \dEndAtCPTime = grAudDef\dEndAtCPTime
      EndIf
      debugMsg(sProcName, "\sEndAtCPName=" + \sEndAtCPName + ", \dEndAtCPTime=" + StrD(\dEndAtCPTime,5))
      \nEndAt = nTime
      If (\nEndAt = -2) And (\nFileDuration > 0)
        \nAbsEndAt = \nFileDuration - 1
      Else
        \nAbsEndAt = \nEndAt
      EndIf
      
      \bAudNormSet = #False
  
      If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
        debugMsg(sProcName, "calling reopenAudFileIfReqd(" + getAudLabel(nEditAudPtr) + ")")
        reopenAudFileIfReqd(nEditAudPtr)
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nFileState=" + decodeFileState(aAud(nEditAudPtr)\nFileState))
        WQF_populateFileTypeExt(nEditAudPtr)
      EndIf
      
      debugMsg(sProcName, "calling setDerivedAudFields")
      setDerivedAudFields(nEditAudPtr)
      WQF_populateCboDevSel()
      
      SGT(WQF\txtCueDuration, timeToStringBWZT(\nCueDuration, \nFileDuration))
      SLD_setMax(WQF\sldProgress, \nCueDuration)
      
      debugMsg(sProcName, "calling setBassPlayEnd(" + getAudLabel(nEditAudPtr) + ")")
      setBassPlayEnd(nEditAudPtr)
      debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
      setBassMarkerPositions(nEditAudPtr)
      
      WQF_setClearState()
      grMG2\nLastTimeMark = \nAbsEndAt
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
      
      ; WQF_displayLevelPointInfo(#SCS_PT_END)
      
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
      postChangeAudSN(u, Str(\nEndAt) + \sEndAtCPName)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtEndAt_Validate(pCallingModule=#WQF, bUsingCuePoint=#False, bReturnBeforeUpdate=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nTime, dTimeDbl.d
  Protected u
  Protected nTextGadget, nLabelGadget
  Protected sMsg.s
  Protected nMinTime
  Protected nAudState, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + Str(pCallingModule) + ", bUsingCuePoint=" + strB(bUsingCuePoint))
  
  If pCallingModule = #WEM
    nTextGadget = WEM\txtValue
    nLabelGadget = WEM\lblField
  Else
    nTextGadget = WQF\txtEndAt
    nLabelGadget = WQF\lblEndAt
  EndIf
  
  debugMsg(sProcName, "txtEndAt=" + GGT(nTextGadget))
  
  If bUsingCuePoint = #False
    If validateTimeFieldT(GGT(nTextGadget), GGT(nLabelGadget), #False, #True, aAud(nEditAudPtr)\nFileDuration) = #False
      ProcedureReturn #False
    EndIf
    If GGT(nTextGadget) <> gsTmpString
      SGT(nTextGadget, gsTmpString)
    EndIf
  EndIf
  
  With aAud(nEditAudPtr)
    
    If bUsingCuePoint
      dTimeDbl = stringToTimeDbl(GGT(nTextGadget))
      If dTimeDbl >= 0.0
        nTime = Int(dTimeDbl * 1000)
      Else
        nTime = Int(dTimeDbl)
      EndIf
    Else
      nTime = stringToTime(GGT(nTextGadget))
    EndIf
    
    If nTime >= 0
      ; Standard Level Point Condition
      nMinTime = getMinTimeForPoint(nEditAudPtr, \nAbsEndAt)
      If (nMinTime >= 0) And (nTime < nMinTime)
        sMsg = LangPars("Errors", "MustBeGreaterThan", Trim(GGT(WQF\lblEndAt)) + " (" + ttszt(nTime) + ")", ttszt(nMinTime - 1))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      ; Cue Markers Condition
      nMinTime = getMinTimeforCueMarkers(nEditAudPtr)
      If (nMinTime >= 0) And (nTime < nMinTime)
        sMsg = LangPars("Errors", "MustBeGreaterThan", Trim(GGT(WQF\lblEndAt)) + " (" + ttszt(nTime) + ")", ttszt(nMinTime - 1))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
    EndIf
    
    If bReturnBeforeUpdate
      ProcedureReturn #True
    EndIf
    
    WQF_setPropertyEndAt(nTime, GGT(WQF\lblEndAt), bUsingCuePoint, pCallingModule)
    
    clearCtrlHoldLP() ; Added 30Dec2023 11.10.0dt to prevent the possible UNINTENTIONAL scenario of having multiple level points selected in the graph
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQF_setPropertyDBLevel(Index, sNewDBLevel.s)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", sNewDBLevel=" + sNewDBLevel)
  
  With aAud(nEditAudPtr)
    debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index])
    If sNewDBLevel <> \sDBLevel[Index]
      u = preChangeAudS(\sDBLevel[Index], rWQF\sUndoDescKeyPart + GGT(WQF\lblDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \sDBLevel[Index] = sNewDBLevel
      \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
      debugMsg(sProcName, "\fBVLevel[" + Index + "]=" + traceLevel(\fBVLevel[Index]))
      WQF_fcTxtDBLevel(Index, sNewDBLevel)
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      postChangeAudSN(u, \sDBLevel[Index], -5, Index)
    EndIf
  EndWith
EndProcedure

Procedure WQF_txtDBLevel_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  Protected sNewDBLevel.s, fBVLevel.f
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If validateDbField(GGT(WQF\txtDBLevel[Index]), GGT(WQF\lblLevel)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WQF\txtDBLevel[Index]) <> gsTmpString
    debugMsg(sProcName, "setting WQF\txtDBLevel[" + Index + "]=" + gsTmpString)
    SGT(WQF\txtDBLevel[Index], gsTmpString)
  EndIf
  
  sNewDBLevel = Trim(GGT(WQF\txtDBLevel[Index]))
  WQF_setPropertyDBLevel(Index, sNewDBLevel)
  
  ; Added 27Apr2024 11.10.2cg
  If grLicInfo\bDevLinkAvailable
    With aAud(nEditAudPtr)
      If \bDeviceSelected[Index]
        fBVLevel = \fBVLevel[Index]
        ; debugMsg(sProcName, "calling WQF_adjustSelectedDevicesLevels(" + n + ", " + convertBVLevelToDBString(fBVLevel) + ")")
        WQF_adjustSelectedDevicesLevels(Index, fBVLevel)
      EndIf
    EndWith
  EndIf
  ; End added 27Apr2024 11.10.2cg
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_setPropertyLoopXFadeTime(nLoopInfoIndex, nTime)
  Protected nOldLoopXFadeTime
  Protected u
  
  With aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
    nOldLoopXFadeTime = \nLoopXFadeTime
    u = preChangeAudL(\nLoopXFadeTime, GGT(WQF\lblLoopXFadeTime), -5, #SCS_UNDO_ACTION_CHANGE, nLoopInfoIndex)
    \nLoopXFadeTime = nTime
    If (\nLoopStart <> nOldLoopXFadeTime) And (\nAbsLoopStart >= 0)
      setBassLoopStart(nEditAudPtr)
    EndIf
    WQF_setClearState()
    If nLoopInfoIndex = aAud(nEditAudPtr)\nCurrLoopInfoIndex
      aAud(nEditAudPtr)\rCurrLoopInfo = aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
    EndIf
    postChangeAudLN(u, \nLoopXFadeTime, -5, nLoopInfoIndex)
  EndWith
  
EndProcedure

Procedure WQF_txtLoopXFadeTime_Validate()
  Protected nTime
  
  If validateTimeFieldT(GGT(WQF\txtLoopXFadeTime), GGT(WQF\lblLoopStart), #False, #False) = #False
    rWQF\bInValidate = #False
    ProcedureReturn #False
  EndIf
  
  If GGT(WQF\txtLoopXFadeTime) <> gsTmpString
    SGT(WQF\txtLoopXFadeTime, gsTmpString)
  EndIf
  
  nTime = stringToTime(GGT(WQF\txtLoopXFadeTime), #False)
  WQF_setPropertyLoopXFadeTime(rWQF\nDisplayedLoopInfoIndex, nTime)
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_setPropertyNumLoops(nLoopInfoIndex, nNewNumLoops)
  PROCNAMECA(nEditAudPtr)
  Protected u, nArraySize
  
  debugMsg(sProcName, #SCS_START + ", nLoopInfoIndex=" + nLoopInfoIndex + ", nNewNumLoops=" + nNewNumLoops)
  
  If nEditAudPtr >= 0
    nArraySize = ArraySize(aAud(nEditAudPtr)\aLoopInfo())
    debugMsg(sProcName, "nArraySize=" + nArraySize)
    If nLoopInfoIndex <= nArraySize
      With aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
        If nNewNumLoops <> \nNumLoops
          u = preChangeAudL(\nNumLoops, GGT(WQF\lblNumLoops), -5, #SCS_UNDO_ACTION_CHANGE, nLoopInfoIndex)
          \nNumLoops = nNewNumLoops
          If nLoopInfoIndex = aAud(nEditAudPtr)\nCurrLoopInfoIndex
            aAud(nEditAudPtr)\rCurrLoopInfo = aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
          EndIf
          postChangeAudLN(u, \nNumLoops, -5, nLoopInfoIndex)
        EndIf
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtNumLoops_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected nMyNumLoops
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    If Len(Trim(GGT(WQF\txtNumLoops))) = 0
      nMyNumLoops = -2
    Else
      If IsInteger(GGT(WQF\txtNumLoops)) = #False
        nMyNumLoops = -99999  ; force error
      Else
        nMyNumLoops = Val(GGT(WQF\txtNumLoops))
      EndIf
      If nMyNumLoops < 2
        scsMessageRequester(grText\sTextValErr, Lang("Errors", "NumLoopsInvalid"), #PB_MessageRequester_Error)
        rWQF\bInValidate = #False
        ProcedureReturn #False
      EndIf
    EndIf
    WQF_setPropertyNumLoops(rWQF\nDisplayedLoopInfoIndex, nMyNumLoops)
  EndWith
  rWQF\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_txtPanForLevelPoint_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nLevelPointIndex, nItemIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If gbInDisplaySub = #False
    WQF_setCurrentDevInfo(Index, #True)
    
    With aAud(nEditAudPtr)
      nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
      nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, \sLogicalDev[Index], \sTracks[Index])
    EndWith
    
    If (nLevelPointIndex >= 0) And (nItemIndex >= 0)
      With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)
        u = preChangeAudF(\fItemPan, rWQF\sUndoDescKeyPart + GetGadgetText(WQF\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
        \fItemPan = panStringToSingle(GGT(WQF\txtPan[Index]))
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" + formatPan(\fItemPan))
        samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
        postChangeAudFN(u, \fItemPan, -5, Index)
      EndWith
    EndIf
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_setPropertyPan(Index, fNewPan.f)
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  ; audio device pan
  With aAud(nEditAudPtr)
    If fNewPan <> \fPan[Index]
      u = preChangeAudL(\fPan[Index], rWQF\sUndoDescKeyPart + GGT(WQF\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \fPan[Index] = fNewPan
      WQF_fcTxtPan(Index, fNewPan)
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      postChangeAudLN(u, \fPan[Index], -5, Index)
    EndIf
  EndWith
EndProcedure

Procedure WQF_txtPan_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  ;   Protected u
  Protected bValidationResult
  Protected fNewPan.f
  
  debugMsg(sProcName, #SCS_START)
  
  If validatePanTextField(GGT(WQF\txtPan[Index]), "Pan") = #False
    ProcedureReturn #False
  EndIf
  
  If rWQF\bDisplayingLevelPoint
    ; level point pan
    bValidationResult = WQF_txtPanForLevelPoint_Validate(Index)
    ProcedureReturn bValidationResult
  EndIf
  
  ; audio device pan
  fNewPan = panStringToSingle(GGT(WQF\txtPan[Index]))
  WQF_setPropertyPan(Index, fNewPan)
  
  ;   With aAud(nEditAudPtr)
  ;     u = preChangeAudL(\fPan[Index], rWQF\sUndoDescKeyPart + GGT(WQF\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
  ;     \fPan[Index] = panStringToSingle(GGT(WQF\txtPan[Index]))
  ;     WQF_fcTxtPan(Index)
  ;     samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
  ;     postChangeAudLN(u, \fPan[Index], -5, Index)
  ;   EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_txtStartAt_KeyDown(nEventMenu)
  PROCNAMECA(nEditAudPtr)
  Protected nMin, nMax
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  If bumpKey(nEventMenu)
    If validateTimeFieldT(GGT(WQF\txtStartAt), GGT(WQF\lblStartAt), #True, #False, aAud(nEditAudPtr)\nFileDuration)
      nMin = 0
      nMax = aAud(nEditAudPtr)\nAbsEndAt
      If nMax = 0
        nMax = aAud(nEditAudPtr)\nFileDuration - 1
      EndIf
      If bumpTimeField(WQF\txtStartAt, nMin, nMax, nMin, nEventMenu)
        WQF_txtStartAt_Validate()
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure WQF_setPropertyLoopStart(nLoopInfoIndex, nTime, bUsingCuePoint=#False, pCallingModule=#WQF)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nOldLoopStart
  
  debugMsg(sProcName, #SCS_START + ", nLoopInfoIndex=" + nLoopInfoIndex + ", nTime=" + nTime + ", bUsingCuePoint=" + strB(bUsingCuePoint) + ", pCallingModule=" + pCallingModule)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
      nOldLoopStart = \nLoopStart
      u = preChangeAudS(Str(\nLoopStart) + \sLoopStartCPName, GLT(WQF\lblLoopStart), -5, #SCS_UNDO_ACTION_CHANGE, nLoopInfoIndex)
      If pCallingModule = #WEM And bUsingCuePoint
        \sLoopStartCPName = grWEM\sReqdCPName
        \qLoopStartSamplePos = grWEM\qReqdSamplePos
        \dLoopStartCPTime = grWEM\dReqdCPTimePos
      Else
        \sLoopStartCPName = grLoopInfoDef\sLoopStartCPName
        \qLoopStartSamplePos = grLoopInfoDef\qLoopStartSamplePos
        \dLoopStartCPTime = grLoopInfoDef\dLoopStartCPTime
      EndIf
      debugMsg(sProcName, "\sLoopStartCPName=" + \sLoopStartCPName + ", \dLoopStartCPTime=" + StrD(\dLoopStartCPTime,5))
      \nLoopStart = nTime
      aAud(nEditAudPtr)\bAudNormSet = #False
      debugMsg(sProcName, "calling setDerivedAudFields")
      setDerivedAudFields(nEditAudPtr)
      
      SGT(WQF\txtCueDuration, timeToStringBWZT(aAud(nEditAudPtr)\nCueDuration, aAud(nEditAudPtr)\nFileDuration))
      
      ;       If (\nLoopStart <> nOldLoopStart) And (\nAbsLoopStart >= 0)
      ;         setBassLoopStart(nEditAudPtr)
      ;       EndIf
      debugMsg(sProcName, "(LS) calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
      setBassLoopStart(nEditAudPtr)
      debugMsg(sProcName, "(LS) calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
      setBassLoopEnd(nEditAudPtr)
      
      debugMsg(sProcName, "calling WQF_refreshFileInfo()")
      WQF_refreshFileInfo()
      
      WQF_setClearState()
      grMG2\nLastTimeMark = \nAbsLoopStart
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + grMG2\nLastTimeMark)
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
      If nLoopInfoIndex = aAud(nEditAudPtr)\nCurrLoopInfoIndex
        aAud(nEditAudPtr)\rCurrLoopInfo = aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
      EndIf
      
      debugMsg(sProcName, "calling postChangeAudL(" + u + ", " + \nLoopStart + ")")
      postChangeAudSN(u, Str(\nLoopStart) + \sLoopStartCPName, -5, nLoopInfoIndex)
      
      If aAud(nEditAudPtr)\nMaxCueMarker >= 0
        WQF_refreshCueMarkersDisplayEtc()
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setPropertyLoopEnd(nLoopInfoIndex, nTime, bUsingCuePoint=#False, pCallingModule=#WQF)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nOldLoopEnd
  
  debugMsg(sProcName, #SCS_START + ", nLoopInfoIndex=" + ", nTime=" + nTime + ", bUsingCuePoint=" + strB(bUsingCuePoint) + ", pCallingModule=" + pCallingModule)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
      nOldLoopEnd = \nLoopEnd
      u = preChangeAudS(Str(\nLoopEnd)+\sLoopEndCPName, GLT(WQF\lblLoopEnd), -5, #SCS_UNDO_ACTION_CHANGE, nLoopInfoIndex)
      If (pCallingModule = #WEM) And (bUsingCuePoint)
        \sLoopEndCPName = grWEM\sReqdCPName
        \qLoopEndSamplePos = grWEM\qReqdSamplePos
        \dLoopEndCPTime = grWEM\dReqdCPTimePos
      Else
        \sLoopEndCPName = grLoopInfoDef\sLoopEndCPName
        \qLoopEndSamplePos = grLoopInfoDef\qLoopEndSamplePos
        \dLoopEndCPTime = grLoopInfoDef\dLoopEndCPTime
      EndIf
      debugMsg(sProcName, "\sLoopEndCPName=" + \sLoopEndCPName + ", \dLoopEndCPTime=" + StrD(\dLoopEndCPTime,5))
      \nLoopEnd = nTime
      aAud(nEditAudPtr)\bAudNormSet = #False
      debugMsg(sProcName, "calling setDerivedAudFields")
      setDerivedAudFields(nEditAudPtr)
      
      SGT(WQF\txtCueDuration, timeToStringBWZT(aAud(nEditAudPtr)\nCueDuration, aAud(nEditAudPtr)\nFileDuration))
      SLD_setMax(WQF\sldProgress, (aAud(nEditAudPtr)\nCueDuration-1))
      If (\nLoopEnd <> nOldLoopEnd) And (\nAbsLoopEnd > \nAbsLoopStart)
        debugMsg(sProcName, "calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
        setBassLoopStart(nEditAudPtr)
        debugMsg(sProcName, "calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
        setBassLoopEnd(nEditAudPtr)
      EndIf
      
      debugMsg(sProcName, "calling WQF_refreshFileInfo()")
      WQF_refreshFileInfo()
      
      WQF_setClearState()
      grMG2\nLastTimeMark = \nAbsLoopEnd
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
      If nLoopInfoIndex = aAud(nEditAudPtr)\nCurrLoopInfoIndex
        aAud(nEditAudPtr)\rCurrLoopInfo = aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
      EndIf
      
      postChangeAudSN(u, Str(\nLoopEnd)+\sLoopEndCPName, -5, nLoopInfoIndex)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setPropertyStartAt(nTime, sUndoDescr.s, bUsingCuePoint=#False, pCallingModule=#WQF)
  PROCNAMECA(nEditAudPtr)
  Protected u, l2
  Protected bSetFilePosAtStartAt
  
  debugMsg(sProcName, #SCS_START + ", nTime=" + nTime + ", pCallingModule=" + pCallingModule)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudS(Str(\nStartAt)+\sStartAtCPName, sUndoDescr)
      debugMsg(sProcName, "\nStartAt=" + \nStartAt + ", nTime=" + nTime)
      
      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
        If (\nRelFilePos + \nAbsMin) = \nAbsStartAt
          bSetFilePosAtStartAt = #True
          debugMsg(sProcName, "bSetFilePosAtStartAt=" + strB(bSetFilePosAtStartAt))
        EndIf
      EndIf
      
      If (pCallingModule = #WEM) And (bUsingCuePoint)
        \sStartAtCPName = grWEM\sReqdCPName
        \qStartAtSamplePos = grWEM\qReqdSamplePos
        \dStartAtCPTime = grWEM\dReqdCPTimePos
      Else
        \sStartAtCPName = grAudDef\sStartAtCPName
        \qStartAtSamplePos = grAudDef\qStartAtSamplePos
        \dStartAtCPTime = grAudDef\dStartAtCPTime
      EndIf
      debugMsg(sProcName, "\sStartAtCPName=" + \sStartAtCPName + ", \dStartAtCPTime=" + StrD(\dStartAtCPTime,5))
      \nStartAt = nTime
      If \nStartAt = -2
        \nAbsStartAt = 0
      Else
        \nAbsStartAt = \nStartAt
      EndIf
      \bAudNormSet = #False
      For l2 = 0 To \nMaxLoopInfo
        \aLoopInfo(l2)\nRelLoopStart = getRelTime(\aLoopInfo(l2)\nAbsLoopStart, \nAbsStartAt)
        \aLoopInfo(l2)\nRelLoopEnd = getRelTime(\aLoopInfo(l2)\nAbsLoopEnd, \nAbsStartAt)
      Next l2
      If (\nMaxLoopInfo >= 0) And (\nCurrLoopInfoIndex >= 0)
        \rCurrLoopInfo = \aLoopInfo(\nCurrLoopInfoIndex)
      EndIf
      debugMsg(sProcName, "calling setDerivedAudFields")
      setDerivedAudFields(nEditAudPtr)
      WQF_populateCboDevSel()
      
      If bSetFilePosAtStartAt
        \nRelFilePos = \nAbsStartAt - \nAbsMin
        debugMsg(sProcName, "\nAbsStartAt=" + \nAbsStartAt + ", \nAbsMin=" + \nAbsMin + ", \nRelFilePos=" + \nRelFilePos)
        reposAuds(nEditAudPtr, \nAbsStartAt, #True)
      EndIf
      
      SGT(WQF\txtCueDuration, timeToStringBWZT(\nCueDuration, \nFileDuration))
      SLD_setMax(WQF\sldProgress, (\nCueDuration-1))
      ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldProgress, 0)")
      SLD_setValue(WQF\sldProgress, 0)
      
      WQF_setClearState()
      grMG2\nLastTimeMark = \nAbsStartAt
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
      
      ; WQF_displayLevelPointInfo(#SCS_PT_START)
      
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
      postChangeAudSN(u, Str(\nStartAt)+\sStartAtCPName)
      
      If aAud(nEditAudPtr)\nMaxCueMarker >= 0
        WQF_refreshCueMarkersDisplayEtc()
      EndIf
      
      debugMsg(sProcName, "\sStartAtCPName=" + \sStartAtCPName + ", \dStartAtCPTime=" + StrD(\dStartAtCPTime,5))
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtStartAt_Validate(pCallingModule=#WQF, bUsingCuePoint=#False, bReturnBeforeUpdate=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nTime, dTimeDbl.d
  Protected nTextGadget, nLabelGadget
  Protected sMsg.s
  Protected nMaxTime
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + Str(pCallingModule) + ", bUsingCuePoint=" + strB(bUsingCuePoint))
  
  If pCallingModule = #WEM
    nTextGadget = WEM\txtValue
    nLabelGadget = WEM\lblField
  Else
    nTextGadget = WQF\txtStartAt
    nLabelGadget = WQF\lblStartAt
  EndIf
  
  debugMsg(sProcName, "txtStartAt=" + GGT(nTextGadget))
  
  If bUsingCuePoint = #False
    If validateTimeFieldT(GGT(nTextGadget), GGT(nLabelGadget), #False, #False, aAud(nEditAudPtr)\nFileDuration) = #False
      rWQF\bInValidate = #False
      ProcedureReturn #False
    EndIf
    ; debugMsg(sProcName, "gsTmpString=" + gsTmpString)
    If GGT(nTextGadget) <> gsTmpString
      SGT(nTextGadget, gsTmpString)
    EndIf
  EndIf
  
  With aAud(nEditAudPtr)
    If bUsingCuePoint
      dTimeDbl = stringToTimeDbl(GGT(nTextGadget))
      If dTimeDbl >= 0.0
        nTime = Int(dTimeDbl * 1000)
      Else
        nTime = Int(dTimeDbl)
      EndIf
    Else
      nTime = stringToTime(GGT(nTextGadget))
    EndIf
    
    If nTime >= 0
      ; Standard Level Point Condition
      nMaxTime = getMaxTimeForPoint(nEditAudPtr, \nAbsStartAt)
      If (nMaxTime >= 0) And (nTime > nMaxTime)
        sMsg = LangPars("Errors", "MustBeLessThan", Trim(GGT(WQF\lblStartAt)) + " (" + ttszt(nTime) + ")", ttszt(nMaxTime + 1))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      ; Cue Markers Condition
      nMaxTime = getMaxTimeforCueMarkers(nEditAudPtr)
      If (nMaxTime >= 0) And (nTime > nMaxTime)
        sMsg = LangPars("Errors", "MustBeLessThan", Trim(GGT(WQF\lblStartAt)) + " (" + ttszt(nTime) + ")", ttszt(nMaxTime + 1))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False  
      EndIf
    EndIf
    
    If bReturnBeforeUpdate
      ProcedureReturn #True
    EndIf
    
    WQF_setPropertyStartAt(nTime, GGT(nLabelGadget), bUsingCuePoint, pCallingModule)
    
    clearCtrlHoldLP() ; Added 30Dec2023 11.10.0dt to prevent the possible UNINTENTIONAL scenario of having multiple level points selected in the graph
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQF_mnuStartTrim(nEventMenu)
  PROCNAMECA(nEditAudPtr)
  Protected fStartThresholdDB.f, fEndThresholdDB.f = 999, nStartMilliseconds.l, nEndMilliseconds.l
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \bAudPlaceHolder = #False
        If FileExists(\sFileName, #False)
          Select nEventMenu
            Case #WQF_mnu_StartTrimSilence
              fStartThresholdDB = -160 ; Treated as -INF by GetSilenceLength() ; Changed 3Oct2022 11.9.6
            Case #WQF_mnu_StartTrim75 ; Added 3Oct2022 11.9.6
              fStartThresholdDB = -75
            Case #WQF_mnu_StartTrim60 ; Added 3Oct2022 11.9.6
              fStartThresholdDB = -60
            Case #WQF_mnu_StartTrim45
              fStartThresholdDB = -45
            Case #WQF_mnu_StartTrim30
              fStartThresholdDB = -30
          EndSelect
          GetSilenceLength(\sFileName, fStartThresholdDB, fEndThresholdDB, @nStartMilliseconds, @nEndMilliseconds)
          debugMsg(sProcName, "nStartMilliseconds=" + nStartMilliseconds)
          If nStartMilliseconds <> \nAbsStartAt
            SGT(WQF\txtStartAt, timeToStringBWZT(nStartMilliseconds, \nFileDuration))
            WQF_txtStartAt_Validate()
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_mnuEndTrim(nEventMenu)
  PROCNAMECA(nEditAudPtr)
  Protected fStartThresholdDB.f = 999, fEndThresholdDB.f, nStartMilliseconds.l, nEndMilliseconds.l
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \bAudPlaceHolder = #False
        If FileExists(\sFileName, #False)
          Select nEventMenu
            Case #WQF_mnu_EndTrimSilence
              fEndThresholdDB = -160  ; Treated as -INF by GetSilenceLength() ; Changed 3Oct2022 11.9.6
            Case #WQF_mnu_EndTrim75
              fEndThresholdDB = -75 ; Added 3Oct2022 11.9.6
            Case #WQF_mnu_EndTrim60
              fEndThresholdDB = -60 ; Added 3Oct2022 11.9.6
            Case #WQF_mnu_EndTrim45
              fEndThresholdDB = -45
            Case #WQF_mnu_EndTrim30
              fEndThresholdDB = -30
          EndSelect
          GetSilenceLength(\sFileName, fStartThresholdDB, fEndThresholdDB, @nStartMilliseconds, @nEndMilliseconds)
          debugMsg(sProcName, "nEndMilliseconds=" + nEndMilliseconds)
          If nEndMilliseconds >= (\nFileDuration - 1)
            SGT(WQF\txtEndAt, "")
            WQF_txtEndAt_Validate()
          Else
            If nEndMilliseconds <> \nAbsEndAt
              SGT(WQF\txtEndAt, timeToStringBWZT(nEndMilliseconds, \nFileDuration))
              WQF_txtEndAt_Validate()
            EndIf
          EndIf
        EndIf
        loadGridRow(nEditCuePtr)
        PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtCurrPos_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected nTime, sMsg.s
  
  debugMsg(sProcName, #SCS_START + ", txtCurrPos=" + GGT(WQF\txtCurrPos))
  
  If validateTimeFieldT(GGT(WQF\txtCurrPos), GGT(WQF\lblCurrPos), #False, #False, aAud(nEditAudPtr)\nFileDuration, #True) = #False
    ProcedureReturn #False
  EndIf
  
  ; debugMsg(sProcName, "gsTmpString=" + gsTmpString)
  If GGT(WQF\txtCurrPos) <> gsTmpString
    SGT(WQF\txtCurrPos, gsTmpString)
  EndIf
  
  With aAud(nEditAudPtr)
    nTime = stringToTime(GGT(WQF\txtCurrPos))
    
    If nTime >= 0
      If (nTime > \nAbsMax) Or (nTime < \nAbsMin)
        sMsg = LangPars("Errors", "RangeError", getLabelAndValue(WQF\lblCurrPos, WQF\txtCurrPos), timeToStringT(\nAbsMin), timeToStringT(\nAbsMax))
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      
      reposAuds(nEditAudPtr, nTime, #True)
      ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldProgress, " + nTime + ")")
      SLD_setValue(WQF\sldProgress, nTime)
      
      grMG2\nLastTimeMark = nTime
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + Str(grMG2\nLastTimeMark))
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 2)  ; request SAM to call drawGraph
      
    EndIf
    
    debugMsg(sProcName, #SCS_END)
    
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WQF_setClearState()
  PROCNAMEC()
  Protected bCurrClearAllState, bReqdClearAllState
  Protected bCurrResetAllState, bReqdResetAllState
  Protected k, l2
  
  bCurrClearAllState = gbMenuItemEnabled(#WQF_mnu_ClearAll)
  bCurrResetAllState = gbMenuItemEnabled(#WQF_mnu_ResetAll)
  
  If nEditAudPtr >= 0
    With grAudDef
      If (\nStartAt <> aAud(nEditAudPtr)\nStartAt) Or
         (\nEndAt <> aAud(nEditAudPtr)\nEndAt) Or
         (\nFadeInTime <> aAud(nEditAudPtr)\nFadeInTime) Or
         (\nFadeOutTime <> aAud(nEditAudPtr)\nFadeOutTime) Or
         (\nMaxLoopInfo <> aAud(nEditAudPtr)\nMaxLoopInfo) Or
         (\bLoopLinked <> aAud(nEditAudPtr)\bLoopLinked)
        bReqdClearAllState = #True
      Else
        For l2 = 0 To \nMaxLoopInfo
          If (\aLoopInfo(l2)\nLoopStart <> aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart) Or
             (\aLoopInfo(l2)\nLoopEnd <> aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd) Or
             (\aLoopInfo(l2)\nLoopXFadeTime <> aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopXFadeTime) Or
             (\aLoopInfo(l2)\nNumLoops <> aAud(nEditAudPtr)\aLoopInfo(l2)\nNumLoops)
            bReqdClearAllState = #True
            Break
          EndIf
        Next l2
      EndIf
    EndWith
    
    k = aAud(nEditAudPtr)\nPreEditPtr
    If k > 0
      With gaHoldAud(k)
        If (\nStartAt <> aAud(nEditAudPtr)\nStartAt) Or
           (\nEndAt <> aAud(nEditAudPtr)\nEndAt) Or
           (\nFadeInTime <> aAud(nEditAudPtr)\nFadeInTime) Or
           (\nFadeOutTime <> aAud(nEditAudPtr)\nFadeOutTime) Or
           (\nMaxLoopInfo <> aAud(nEditAudPtr)\nMaxLoopInfo) Or
           (\bLoopLinked <> aAud(nEditAudPtr)\bLoopLinked)
          bReqdResetAllState = #True
        Else
          For l2 = 0 To \nMaxLoopInfo
            If (\aLoopInfo(l2)\nLoopStart <> aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart) Or
               (\aLoopInfo(l2)\nLoopEnd <> aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd) Or
               (\aLoopInfo(l2)\nLoopXFadeTime <> aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopXFadeTime) Or
               (\aLoopInfo(l2)\nNumLoops <> aAud(nEditAudPtr)\aLoopInfo(l2)\nNumLoops)
              bReqdResetAllState = #True
              Break
            EndIf
          Next l2
        EndIf
      EndWith
    EndIf ; EndIf k > 0
    
  EndIf ; EndIf nEditAudPtr >= 0
  
  If bReqdClearAllState <> bCurrClearAllState
    scsEnableMenuItem(#WQF_mnu_Other, #WQF_mnu_ClearAll, bReqdClearAllState)
  EndIf
  If bReqdResetAllState <> bCurrResetAllState
    scsEnableMenuItem(#WQF_mnu_Other, #WQF_mnu_ResetAll, bReqdResetAllState)
  EndIf
  
EndProcedure

Procedure WQF_fieldValidation()
  SetActiveGadget(-1)
EndProcedure

Procedure WQF_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQF_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WQF_setZoomTrackBar()
  PROCNAMECA(nEditAudPtr)
  Protected nZoomValue, bZoomEnabled
  Static nZoomTrackBarMin, nZoomTrackBarMax, nZoomTrackBarRange
  Static bStaticLoaded
  Protected fMillisecondsPerPixelMaxInnerWidth.f
  Protected fMillisecondsPerPixelViewRange.f
  Protected fViewProportion.f
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    ; load static variables
    nZoomTrackBarMin = GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Minimum)
    nZoomTrackBarMax = GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Maximum)
    nZoomTrackBarRange = nZoomTrackBarMax - nZoomTrackBarMin + 1
    bStaticLoaded = #True
  EndIf
  
  ; set default values
  nZoomValue = nZoomTrackBarMin
  
  With aAud(nEditAudPtr)
    If (\nFileDuration > 0) And (grMG2\nFileDataPtrForSlicePeakAndMinArrays = \nFileDataPtr)
      bZoomEnabled = #True
      fMillisecondsPerPixelMaxInnerWidth = grMG2\nMaxInnerWidth / grMG2\nVisibleWidth
      fMillisecondsPerPixelViewRange = grMG2\nViewRange / grMG2\nVisibleWidth
      fViewProportion = fMillisecondsPerPixelViewRange / fMillisecondsPerPixelMaxInnerWidth
      nZoomValue = Round(nZoomTrackBarRange * (1.0 - fViewProportion), #PB_Round_Nearest)
      ;       debugMsg(sProcName, "fMillisecondsPerPixelMaxInnerWidth=" + StrF(fMillisecondsPerPixelMaxInnerWidth,2) +
      ;                           ", fMillisecondsPerPixelViewRange=" + StrF(fMillisecondsPerPixelViewRange,2) +
      ;                           ", fViewProportion=" + StrF(fViewProportion,2) +
      ;                           ", nZoomValue=" + nZoomValue)
      If nZoomValue < nZoomTrackBarMin
        nZoomValue = nZoomTrackBarMin
      ElseIf nZoomValue > nZoomTrackBarMax
        nZoomValue = nZoomTrackBarMax
      EndIf
      grMG2\nZoomValue = nZoomValue
    EndIf
    
    debugMsg(sProcName, "calling SGS(WQF\trbZoom, " + nZoomValue + ")")
    SGS(WQF\trbZoom, nZoomValue)
    debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom))
    setEnabled(WQF\trbZoom, bZoomEnabled)
    rWQF\nLastTrbZoomValue = nZoomValue
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setPosSlider()
  PROCNAMECA(nEditAudPtr)
  Protected nPositionValue, bPositionEnabled
  Protected nPositionSliderMin, nPositionSliderMax, nPositionSliderRange
  Protected nMaxStartPosForRange
  Protected fPosFactor.f
  Protected nAreaOutsideRange
  
  ; debugMsg(sProcName, #SCS_START)
  
  nPositionSliderMin = SLD_getMin(WQF\sldPosition)
  nPositionSliderMax = SLD_getMax(WQF\sldPosition)
  nPositionSliderRange = nPositionSliderMax - nPositionSliderMin + 1
  
  With grMG2
    nPositionValue = nPositionSliderMin
    ; debugMsg(sProcName, "grMG2\nFileDuration=" + \nFileDuration + ", \nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange)
    If (\nFileDuration > 0) And (\nViewRange > 0)
      If \nViewRange < \nFileDuration
        bPositionEnabled = #True
        nMaxStartPosForRange = \nFileDuration - \nViewRange
        ; debugMsg(sProcName, "nMaxStartPosForRange=" + nMaxStartPosForRange)
        If \nViewStart > nMaxStartPosForRange
          nPositionValue = nPositionSliderMax
        Else
          nAreaOutsideRange = \nFileDuration - \nViewRange
          fPosFactor = \nViewStart / nAreaOutsideRange
          nPositionValue = nPositionSliderMin + ((nPositionSliderRange - 1) * fPosFactor)
          ; debugMsg(sProcName, "grMG2\nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange + ", nAreaOutsideRange=" + nAreaOutsideRange +
          ;                      ", \nFileDuration=" + \nFileDuration +
          ;                      ", fPosFactor=" + StrF(fPosFactor,4) + ", nPositionValue=" + nPositionValue)
        EndIf
      EndIf
    EndIf
    
    If nPositionValue < nPositionSliderMin
      nPositionValue = nPositionSliderMin
    ElseIf nPositionValue > nPositionSliderMax
      nPositionValue = nPositionSliderMax
    EndIf
    \nPositionValue = nPositionValue
    ; debugMsg(sProcName, "nPositionValue=" + nPositionValue + ", nPositionSliderMin=" + nPositionSliderMin + ", nPositionSliderMax=" + nPositionSliderMax)
    
    ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldPosition, " + nPositionValue + ")")
    SLD_setValue(WQF\sldPosition, nPositionValue)
    SLD_setEnabled(WQF\sldPosition, bPositionEnabled)
    WQF_sldPosition_Change() ; Added 31Jan2022 11.9.0rc7
    ; debugMsg(sProcName, "SLD_getValue(WQF\sldPosition)=" + SLD_getValue(WQF\sldPosition))
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setViewControls()
  PROCNAMECA(nEditAudPtr)
  Protected nPlayableStart, nPlayableEnd
  Protected nFileDataPtr
  Protected bEnableZoom, bEnablePos
  
  ; debugMsg(sProcName, #SCS_START + ", grGraph2\bGraphVisible=" + strB(grGraph2\bGraphVisible) + ", getEnabled(WQF\trbZoom)=" + strB(getEnabled(WQF\trbZoom)) + ", SLD_getEnabled(WQF\sldPosition)=" + strB(SLD_getEnabled(WQF\sldPosition)))
  
  If (grGraph2\bGraphVisible = #False) Or (nEditAudPtr < 0)
    ; debugMsg(sProcName, "calling SGS(WQF\trbZoom, 1)")
    SGS(WQF\trbZoom, 1)
    ; debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom))
    SetEnabled(WQF\trbZoom, #False)
    SLD_setEnabled(WQF\sldPosition, #False)
    setEnabled(WQF\btnViewPlayable, #False)
    setEnabled(WQF\btnViewAll, #False)
    ; debugMsg(sProcName, "ProcedureReturn")
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    nFileDataPtr = \nFileDataPtr
    
    ; debugMsg(sProcName, "\nFileDuration=" + \nFileDuration + ", \nFileDataPtr=" + \nFileDataPtr + ", grMG2\nFileDataPtrForSlicePeakAndMinArrays=" + grMG2\nFileDataPtrForSlicePeakAndMinArrays)
    If (\nFileDuration <= 0) Or (grMG2\nFileDataPtrForSlicePeakAndMinArrays <> \nFileDataPtr)
      setEnabled(WQF\btnViewAll, #False)
      setEnabled(WQF\btnViewPlayable, #False)
      ; debugMsg(sProcName, "calling SGS(WQF\trbZoom, 1)")
      SGS(WQF\trbZoom, 1)
      ; debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom))
      SetEnabled(WQF\trbZoom, #False)
      SLD_setEnabled(WQF\sldPosition, #False)
      
    Else
      
      If (grMG2\nViewStart > 0) Or (grMG2\nViewEnd < (\nFileDuration-1))
        setEnabled(WQF\btnViewAll, #True)
      Else
        setEnabled(WQF\btnViewAll, #False)
      EndIf
      
      ; set enabled property of 'View Playable' and 'View All' buttons
      nPlayableStart = \nAbsStartAt
      nPlayableEnd = \nAbsEndAt
      If \nMaxLoopInfo >= 0
        If (\aLoopInfo(0)\nAbsLoopStart > 0) And (\aLoopInfo(0)\nAbsLoopStart < nPlayableStart)
          nPlayableStart = \aLoopInfo(0)\nAbsLoopStart
        EndIf
        If \aLoopInfo(\nMaxLoopInfo)\nAbsLoopEnd > nPlayableEnd
          nPlayableEnd = \aLoopInfo(\nMaxLoopInfo)\nAbsLoopEnd
        EndIf
      EndIf
      
      If (nPlayableStart > 0) Or (nPlayableEnd < (\nFileDuration - 1))
        setEnabled(WQF\btnViewPlayable, #True)
      Else
        setEnabled(WQF\btnViewPlayable, #False)
      EndIf
      
    EndIf
    
    bEnableZoom = #False
    If nFileDataPtr >= 0
      ; always enable zoom, provided file duration > 0
      If \nFileDuration > 0
        bEnableZoom = #True
      EndIf
    EndIf
    setEnabled(WQF\trbZoom, bEnableZoom)
    
    bEnablePos = #False
    If bEnableZoom
      If GGS(WQF\trbZoom) > 1
        bEnablePos = #True
      EndIf
    EndIf
    SLD_setEnabled(WQF\sldPosition, bEnablePos)
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_populateCboLogicalDevs()
  PROCNAMEC()
  Protected d, n
  
  debugMsg(sProcName, #SCS_START)
  
  ; populate logical device cbo for sub type F
  For d = 0 To grLicInfo\nMaxAudDevPerAud
    ; debugMsg(sProcName, "WQF\cboLogicalDevF[" + Str(d) + "]=G" + Str(WQF\cboLogicalDevF[d]) + ", IsGadget(WQF\cboLogicalDevF[" + Str(d) + "])=" + Str(IsGadget(WQF\cboLogicalDevF[d])))
    ClearGadgetItems(WQF\cboLogicalDevF[d])
    AddGadgetItem(WQF\cboLogicalDevF[d], -1, #SCS_BLANK_CBO_ENTRY)
    For n = 0 To grProd\nMaxAudioLogicalDev
      If Len(Trim(grProd\aAudioLogicalDevs(n)\sLogicalDev)) > 0
        AddGadgetItem(WQF\cboLogicalDevF[d], -1, grProd\aAudioLogicalDevs(n)\sLogicalDev)
      EndIf
    Next n
  Next d
  WQF_setCboLogicalDevsEnabled()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_populateCboDevSel()
  PROCNAMEC()
  ; note: this procedure is called from WQF_displaySub() but is ALSO called from WQF_cvsGraph_Event() when dragging a Level Point marker,
  ; so may be called many times while the Level Point marker is dragged.
  Protected nLevelPointIndex, nListIndex, n
  Protected sCurrItemText.s
  Protected bWantThis, bRetainCurrItem
  Static sAudioDevices.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sAudioDevices = Lang("WQF","lblSoundDevice")
    bStaticLoaded = #True
  EndIf
  
  sCurrItemText = GGT(WQF\cboDevSel)
  
  ClearGadgetItems(WQF\cboDevSel)
  addGadgetItemWithData(WQF\cboDevSel, sAudioDevices, -1)
  
  If nEditAudPtr >= 0
    For nLevelPointIndex = 0 To aAud(nEditAudPtr)\nMaxLevelPoint
      bWantThis = #False
      With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)
        Select \nPointType
          Case #SCS_PT_START, #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT, #SCS_PT_END
            bWantThis = #True
        EndSelect
        If bWantThis
          addGadgetItemWithData(WQF\cboDevSel, \sPointDesc, nLevelPointIndex)
        EndIf
      EndWith
    Next nLevelPointIndex
  EndIf
  
  nListIndex = 0
  If rWQF\bDisplayingLevelPoint
    Select rWQF\nCurrLevelPointType
      Case #SCS_PT_START, #SCS_PT_END, #SCS_PT_FADE_IN, #SCS_PT_FADE_OUT
        nListIndex = indexForComboBoxRow(WQF\cboDevSel, sCurrItemText, 0)
      Default
        nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
        nListIndex = indexForComboBoxData(WQF\cboDevSel, nLevelPointIndex, 0)
    EndSelect
  EndIf
  ; debugMsg(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", nListIndex=" + nListIndex)
  SGS(WQF\cboDevSel, nListIndex)
  
  ; For n = 0 To CountGadgetItems(WQF\cboDevSel) - 1
  ;   debugMsg(sProcName, "WQF\cboDevSel item " + n + " = " + GetGadgetItemText(WQF\cboDevSel, n))
  ; Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_populateCboLevelSel()
  PROCNAMEC()
  Static sIndividual.s, sSynced.s, sLinked.s
  Static bStaticLoaded
  Protected nLevelSelWidth
  Protected nLevelFieldsLeft, nLevelFieldsWidth
  Protected nReqdLeft
  
  If bStaticLoaded = #False
    sIndividual = decodeLvlPtLvlSelL(#SCS_LVLSEL_INDIV)
    sSynced = decodeLvlPtLvlSelL(#SCS_LVLSEL_SYNC)
    sLinked = decodeLvlPtLvlSelL(#SCS_LVLSEL_LINK)
    bStaticLoaded = #True
  EndIf
  
  With WQF
    ClearGadgetItems(\cboLevelSel)
    addGadgetItemWithData(\cboLevelSel, sIndividual, #SCS_LVLSEL_INDIV)
    addGadgetItemWithData(\cboLevelSel, sSynced, #SCS_LVLSEL_SYNC)
    addGadgetItemWithData(\cboLevelSel, sLinked, #SCS_LVLSEL_LINK)
    setComboBoxWidth(\cboLevelSel)
    
    ; centre \cboLevelSel over level fields
    nLevelFieldsLeft = GadgetX(\scaDevs) + GadgetX(\cntDevRelLevel[0]) + GadgetX(\txtDevDBLevel[0])
    nLevelFieldsWidth = GadgetX(\txtPlayDBLevel[0]) + GadgetWidth(\txtPlayDBLevel[0]) - GadgetX(\txtDevDBLevel[0])
    nLevelSelWidth = GadgetWidth(\cboLevelSel)
    nReqdLeft = nLevelFieldsLeft + ((nLevelFieldsWidth - nLevelSelWidth) / 2) - GadgetX(\cntRelLevelLabels)
    If nReqdLeft <> GadgetX(\cboLevelSel)
      ResizeGadget(\cboLevelSel, nReqdLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
    
  EndWith
EndProcedure

Procedure WQF_populateCboPanSel()
  PROCNAMEC()
  Static sUseAudDev.s, sIndividual.s, sSynced.s
  Static bStaticLoaded
  Protected nLeft, nWidth
  Protected nPanFieldsLeft, nPanFieldsWidth
  
  If bStaticLoaded = #False
    sUseAudDev = decodeLvlPtPanSelL(#SCS_PANSEL_USEAUDDEV)
    sIndividual = decodeLvlPtPanSelL(#SCS_PANSEL_INDIV)
    sSynced = decodeLvlPtPanSelL(#SCS_PANSEL_SYNC)
    bStaticLoaded = #True
  EndIf
  
  With WQF
    ClearGadgetItems(\cboPanSel)
    addGadgetItemWithData(\cboPanSel, sUseAudDev, #SCS_PANSEL_USEAUDDEV)
    addGadgetItemWithData(\cboPanSel, sIndividual, #SCS_PANSEL_INDIV)
    addGadgetItemWithData(\cboPanSel, sSynced, #SCS_PANSEL_SYNC)
    setComboBoxWidth(\cboPanSel)
    ; centre \cboPanSel over pan fields
    nPanFieldsLeft = GadgetX(\scaDevs) + SLD_gadgetX(\sldPan[0]) - GadgetX(\cntRelLevelLabels)
    nPanFieldsWidth = GadgetX(\txtPan[0]) + GadgetWidth(\txtPan[0]) - SLD_gadgetX(\sldPan[0])
    nWidth = GadgetWidth(\cboPanSel)
    If nWidth < nPanFieldsWidth
      nLeft = nPanFieldsLeft + ((nPanFieldsWidth - nWidth) >> 1)
    Else
      nLeft = nPanFieldsLeft
    EndIf
    ResizeGadget(\cboPanSel, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndWith
EndProcedure

Macro WQF_Macro_ChangeLevel()
  bChanged = #False
  nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, grMG2\nMouseDownLevelPointId)
  If (nLevelPointIndex >= 0) And (grMG2\nMouseDownItemIndex >= 0)
    fFieldRelDBLevel = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel
    ; debugMsg0(sProcName, "(a1) nLevelPointIndex=" + nLevelPointIndex + ", fNewRelDBLevel=" + StrF(fNewRelDBLevel,4) + " (" + convertDBLevelToDBString(fNewRelDBLevel) +
    ;                      "), aAud(nEditAudPtr)\aPoint(" + nLevelPointIndex + ")\aItem(" + grMG2\nMouseDownItemIndex + ")\fItemRelDBLevel=" +
    ;                      StrF(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel,4) + " (" +
     ;                     convertDBLevelToDBString(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel) + ")")
    ; Added 16Oct2024 11.10.6ap
    If IsInfinity(fFieldRelDBLevel)
      ; debugMsg(sProcName, "(a2) setting fFieldRelDBLevel=" + grLevels\nMinDBLevel + ", was " + StrF(fFieldRelDBLevel,4))
      fFieldRelDBLevel = grLevels\nMinDBLevel
    EndIf
    ; End added 16Oct2024 11.10.6ap
    If fNewRelDBLevel <> fFieldRelDBLevel
      fRelDBLevelChangeExt = fNewRelDBLevel - fFieldRelDBLevel
      ; debugMsg0(sProcName, "(b) fNewRelDBLevel=" + StrF(fNewRelDBLevel,4) + " (" + convertDBLevelToDBString(fNewRelDBLevel) + ")" +
      ;                      ", fFieldRelDBLevel=" + StrF(fFieldRelDBLevel,4) + " (" + convertDBLevelToDBString(fFieldRelDBLevel) + ")" +
      ;                      ", fRelDBLevelChangeExt=" + StrF(fRelDBLevelChangeExt,4) + " (" + convertDBLevelToDBString(fRelDBLevelChangeExt) + ")" + ", ListSize(CtrlHoldLevelPoints())=" + ListSize(CtrlHoldLevelPoints()))
      If ListSize(CtrlHoldLevelPoints()) = 1 ; Changed 16Oct2024 11.10.6ap (was = 0)
        ; if we get here then the user is adjusting the level of a single level point and has NOT used the Ctrl key to select any level points
        bChanged = #True
        fFieldRelDBLevel = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel
        ; Added 16Oct2024 11.10.6ap
        If IsInfinity(fFieldRelDBLevel)
          ; debugMsg(sProcName, "(c1) setting fFieldRelDBLevel=" + grLevels\nMinDBLevel + ", was " + StrF(fFieldRelDBLevel,4))
          fFieldRelDBLevel = grLevels\nMinDBLevel
        EndIf
        ; End added 16Oct2024 11.10.6ap
        fNewRelDBLevel = fFieldRelDBLevel + fRelDBLevelChangeExt
        ; debugMsg0(sProcName, "(c2) nLevelPointIndex=" + nLevelPointIndex + ", fNewRelDBLevel=" + StrF(fNewRelDBLevel,4) + " (" + convertDBLevelToDBString(fNewRelDBLevel) + "), fFieldRelDBLevel=" + StrF(fFieldRelDBLevel,4) + " (" + convertDBLevelToDBString(fFieldRelDBLevel) + ")")
        u = preChangeAudF(fFieldRelDBLevel, rWQF\sUndoDescKeyPart + sRelLevel, -5, #SCS_UNDO_ACTION_CHANGE, grMG2\nMouseDownItemIndex)
        nLvlPtLvlSel = aAud(nEditAudPtr)\nLvlPtLvlSel
        Select nLvlPtLvlSel
          Case #SCS_LVLSEL_INDIV
            aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel = fNewRelDBLevel
            ; debugMsg0(sProcName, "(d) \aPoint(" + nLevelPointIndex + ")\aItem(" + grMG2\nMouseDownItemIndex + ")\fItemRelDBLevel=" + convertDBLevelToDBString(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel))
          Case #SCS_LVLSEL_SYNC
            setRelLevelsForSync(nEditAudPtr, nLevelPointIndex, fNewRelDBLevel)
          Case #SCS_LVLSEL_LINK
            fRelDBLevelChangeExt = fNewRelDBLevel - fFieldRelDBLevel
            adjustRelLevelsForLink(nEditAudPtr, nLevelPointIndex, fRelDBLevelChangeExt)
        EndSelect
        WQF_displayRelLevelAndPanForDev(nLevelPointIndex)
        postChangeAudFN(u, fNewRelDBLevel, -5, grMG2\nMouseDownItemIndex)
      Else
        ; if we get here then the user has used the Ctrl key to select one or more level points
        ResetList(CtrlHoldLevelPoints())
        While NextElement(CtrlHoldLevelPoints())
          If CtrlHoldLevelPoints()\bLPSelected
            nLevelPointId = CtrlHoldLevelPoints()\nLPPointId
            nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, nLevelPointId)
            If nLevelPointIndex >= 0
              bChanged = #True
              fFieldRelDBLevel = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel
              ; Added 16Oct2024 11.10.6ap
              If IsInfinity(fFieldRelDBLevel)
                ; debugMsg(sProcName, "(e1) setting fFieldRelDBLevel=" + grLevels\nMinDBLevel + ", was " + StrF(fFieldRelDBLevel,4))
                fFieldRelDBLevel = grLevels\nMinDBLevel
              EndIf
              ; End added 16Oct2024 11.10.6ap
              fNewRelDBLevel = fFieldRelDBLevel + fRelDBLevelChangeExt
              ; debugMsg0(sProcName, "(e2 nLevelPointIndex=" + nLevelPointIndex + ", fNewRelDBLevel=" + StrF(fNewRelDBLevel,4) + " (" + convertDBLevelToDBString(fNewRelDBLevel) + "), fFieldRelDBLevel=" + StrF(fFieldRelDBLevel,4) + " (" + convertDBLevelToDBString(fFieldRelDBLevel) + ")")
              u = preChangeAudF(fFieldRelDBLevel, rWQF\sUndoDescKeyPart + sRelLevel, -5, #SCS_UNDO_ACTION_CHANGE, grMG2\nMouseDownItemIndex)
              nLvlPtLvlSel = aAud(nEditAudPtr)\nLvlPtLvlSel
              Select nLvlPtLvlSel
                Case #SCS_LVLSEL_INDIV
                  aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel = fNewRelDBLevel
                  ; debugMsg0(sProcName, "(f) \aPoint(" + nLevelPointIndex + ")\aItem(" + grMG2\nMouseDownItemIndex + ")\fItemRelDBLevel=" + convertDBLevelToDBString(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemRelDBLevel))
                Case #SCS_LVLSEL_SYNC
                  setRelLevelsForSync(nEditAudPtr, nLevelPointIndex, fNewRelDBLevel)
                Case #SCS_LVLSEL_LINK
                  fRelDBLevelChangeExt = fNewRelDBLevel - fFieldRelDBLevel
                  adjustRelLevelsForLink(nEditAudPtr, nLevelPointIndex, fRelDBLevelChangeExt)
              EndSelect
              WQF_displayRelLevelAndPanForDev(nLevelPointIndex)
              postChangeAudFN(u, fNewRelDBLevel, -5, grMG2\nMouseDownItemIndex)
            EndIf ; EndIf nLevelPointIndex >= 0
          EndIf ; EndIf CtrlHoldLevelPoints()\bLPSelected
        Wend
      EndIf ; EndIf ListSize(CtrlHoldLevelPoints()) > 0
    EndIf ; EndIf fNewRelDBLevel <> fFieldRelDBLevel
  EndIf ; EndIf (nLevelPointIndex >= 0) And (grMG2\nMouseDownItemIndex >= 0)
  If bChanged
    redrawGraphAfterMouseChange(@grMG2)
    If (aAud(nEditAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(nEditAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
      ; debugMsg(sProcName, "calling loadLvlPtRun(" + getAudLabel(nEditAudPtr) + ", " + aAud(nEditAudPtr)\nCuePos + ", #False)")
      loadLvlPtRun(nEditAudPtr, aAud(nEditAudPtr)\nCuePos, #False)
    EndIf
  EndIf
EndMacro

Macro WQF_Macro_ChangePan()
  nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, grMG2\nMouseDownLevelPointId)
  If (nLevelPointIndex >= 0) And (grMG2\nMouseDownItemIndex >= 0)
    fFieldPan = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemPan
    If fNewPan <> fFieldPan
      u = preChangeAudF(fFieldPan, rWQF\sUndoDescKeyPart + sPan, -5, #SCS_UNDO_ACTION_CHANGE, grMG2\nMouseDownItemIndex)
      aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemPan = fNewPan
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + grMG2\nMouseDownItemIndex + ")\fItemPan=" +
                          formatPan(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(grMG2\nMouseDownItemIndex)\fItemPan))
      nLvlPtPanSel = aAud(nEditAudPtr)\nLvlPtPanSel
      If nLvlPtPanSel = #SCS_PANSEL_SYNC
        For nItemIndex = 0 To aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem
          If nItemIndex <> grMG2\nMouseDownItemIndex
            aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan = fNewPan
            debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" +
                                formatPan(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan))
          EndIf
        Next nItemIndex
      EndIf
      ; debugMsg(sProcName, "calling WQF_displayRelLevelAndPanForDev(" + nLevelPointIndex + "), fFieldPan=" + StrF(fFieldPan,2) + ", fNewPan=" + StrF(fNewPan,2))
      WQF_displayRelLevelAndPanForDev(nLevelPointIndex)
      redrawGraphAfterMouseChange(@grMG2)
      postChangeAudFN(u, fNewPan, -5, grMG2\nMouseDownItemIndex)
      
      If (aAud(nEditAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(nEditAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
        ; debugMsg(sProcName, "calling loadLvlPtRun(" + getAudLabel(nEditAudPtr) + ", " + aAud(nEditAudPtr)\nCuePos + ", #False)")
        loadLvlPtRun(nEditAudPtr, aAud(nEditAudPtr)\nCuePos, #False)
      EndIf
      
    EndIf
  EndIf
EndMacro

Procedure WQF_setMarkerDragActionAndCursor()
  PROCNAMEC()
  Protected nCanvasCursor = -1
  Protected sPointDesc.s, sUndoDesc.s
  Protected sErrorMsg.s, sButtons.s
  Protected bCannotChangeLevel
  Protected nReply
  Protected nNewPanSel = -1
  Protected u
  Protected nLevelPointIndex, nItemIndex
  
  With grMG2
    nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
    nItemIndex = \nMouseDownItemIndex
    ; debugMsg0(sProcName, "grMG2\nMouseDownLevelPointId=" + \nMouseDownLevelPointId + ", nLevelPointIndex=" + nLevelPointIndex + ", nItemIndex=" + nItemIndex + ", \nMouseDownLevelOrPan=" + \nMouseDownLevelOrPan)
    If nLevelPointIndex >= 0
      sPointDesc = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\sPointDesc
      sUndoDesc = sPointDesc
      If nItemIndex >= 0
        sUndoDesc + " (" + nItemIndex + ")"
      EndIf
      If (isAltKeyDown() = #False) And (isCtrlKeyDown() = #False)
        ; request to change position (can occur on level or pan markers, or on 'start' or 'end' markers)
        \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION
        nCanvasCursor = #PB_Cursor_LeftRight
        
      ElseIf (isAltKeyDown()) And (nItemIndex >= 0)
        If \nMouseDownLevelOrPan = #SCS_GRAPH_MARKER_LEVEL
          ; request to change level
          ; Debug sProcName + ": aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointType=" + decodeLevelPointType(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType) + ", \nFadeInTime=" + aAud(nEditAudPtr)\nFadeInTime
          If (aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType = #SCS_PT_START) And (aAud(nEditAudPtr)\nFadeInTime > 0)
            sErrorMsg = Lang("Graph", "CannotChgSTLvl")
            bCannotChangeLevel = #True
          ElseIf (aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType = #SCS_PT_END) And (aAud(nEditAudPtr)\nFadeOutTime > 0)
            sErrorMsg = Lang("Graph", "CannotChgENLvl")
            bCannotChangeLevel = #True
          EndIf
          If bCannotChangeLevel
            removeSelectedCtrlHoldLP(\nMouseDownLevelPointId) ; may have been added earlier in procedure that called WQF_setMarkerDragActionAndCursor() - doesn't matter if the level point id hasn't been added to the array
            SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
            scsMessageRequester(sPointDesc, sErrorMsg)
          Else
            \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL
            nCanvasCursor = #PB_Cursor_UpDown
          EndIf
          
        ElseIf \nMouseDownLevelOrPan = #SCS_GRAPH_MARKER_PAN
          ; request to change pan
          ; If aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointPanSel = #SCS_PANSEL_USEAUDDEV
          If aAud(nEditAudPtr)\nLvlPtPanSel = #SCS_PANSEL_USEAUDDEV
            ; sErrorMsg = ReplaceString(LangPars("Graph", "CannotAdjPan", sPointDesc, decodeLvlPtPanSelL(aAud(nEditAudPtr)\nLvlPtPanSel)), Chr(10), "|")
            sErrorMsg = ReplaceString(LangPars("Graph", "CannotAdjPan", decodeLvlPtPanSelL(aAud(nEditAudPtr)\nLvlPtPanSel)), Chr(10), "|")
            sButtons = Lang("Common", "No") + "|" +
                       Lang("WQF", "PanIndiv") + "|" +
                       Lang("WQF", "PanSync")
            SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
            nReply = OptionRequester(0, 0, sPointDesc + "|" + sErrorMsg, sButtons, 250)
            Select nReply
              Case 1  ; No
                ; no action
              Case 2
                nNewPanSel = #SCS_PANSEL_INDIV
              Case 3
                nNewPanSel = #SCS_PANSEL_SYNC
            EndSelect
            If nNewPanSel <> -1
              u = preChangeAudL(#True, Lang("WQF","PanSel"), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
              aAud(nEditAudPtr)\nLvlPtPanSel = nNewPanSel
              propagateLvlPtLevelAndPanSelection(nEditAudPtr, nLevelPointIndex, #False, #True)
              postChangeAudLN(u, #False)
              ; WQF_displayRelLevels(rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
              WQF_displayLevelPointInfo(rWQF\nCurrLevelPointType)
              drawGraph(@grMG2)
            EndIf
          EndIf
          If aAud(nEditAudPtr)\nLvlPtPanSel <> #SCS_PANSEL_USEAUDDEV
            \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
            nCanvasCursor = #PB_Cursor_UpDown
          EndIf
        EndIf
        
      EndIf
    EndIf
  EndWith
  ProcedureReturn nCanvasCursor
EndProcedure

Procedure WQF_cvsSideLabels_Event()
  PROCNAMEC()
  Protected nMouseX, nMouseY, bDisplayHelp, bCheckDisplay
  Static bHelpDisplayed
  Static sGraphHelp.s,sHelpMessage0.s, sHelpMessage1.s, sHelpMessage2.s, sHelpMessage3.s, sHelpMessage4.s, sHelpMessage5.s, sHelpMessage6.s, nMaxWidth, sFullMessage.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sGraphHelp = Lang("Graph", "GraphHelp")
    sHelpMessage0 = Lang("Graph", "HelpMsg0") ; "Press F7 while file is playing to create a QUICK CUE MARKER at the current playback position."
    sHelpMessage1 = Lang("Graph", "HelpMsg1") ; "To change the POSITION of a marker, CLICK and DRAG the marker."
    sHelpMessage2 = Lang("Graph", "HelpMsg2") ; "To change the LEVEL or PAN of a marker, ALT-CLICK and DRAG the marker."
    sHelpMessage3 = Lang("Graph", "HelpMsg3") ; "To select multiple markers for a LEVEL change, CTRL-CLICK each required marker and then ALT-CLICK and DRAG one of the selected markers."
    If grLicInfo\bStdLvlPtsAvailable
      sHelpMessage4 = Lang("Graph", "HelpMsg4") ; "Double-left-click to add a standard level point at the mouse click position."
      ; sHelpMessage5 = Lang("Graph", "HelpMsg5") ; "(The term 'marker' in the following items refres to both cue markers and level points.)"
    EndIf
    sHelpMessage6 = buildSkipBackForwardTooltip()
    nMaxWidth = GetTextWidth(sHelpMessage2 + Space(20)) ; seems to give a good result
    sFullMessage = sHelpMessage0
    If sHelpMessage4
      sFullMessage + #CRLF$ + #CRLF$ + sHelpMessage4 ; + #CRLF$ + #CRLF$ + sHelpMessage5
    EndIf
    sFullMessage + #CRLF$ + #CRLF$ + sHelpMessage1 + #CRLF$ + #CRLF$ + sHelpMessage2 + #CRLF$ + #CRLF$ + sHelpMessage3
    sFullMessage + #CRLF$ + #CRLF$ + sHelpMessage6
    bStaticLoaded = #True
  EndIf
  
  With grMG2
    
    If \bDeviceAssigned = #False
      ProcedureReturn
    EndIf
    
    ; debugMsg(sProcName, "gnEventType=" + decodeEventType(WQF\cvsGraph))
    
    Select gnEventType
      Case #PB_EventType_MouseEnter, #PB_EventType_MouseMove
        nMouseX = GetGadgetAttribute(WQF\cvsSideLabels, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WQF\cvsSideLabels, #PB_Canvas_MouseY)
        If (nMouseX >= \nGraphHelpLeft) And (nMouseX <= \nGraphHelpRight) And (nMouseY >= \nGraphHelpTop) And (nMouseY <= \nGraphHelpBottom)
          bDisplayHelp = #True
        Else
          bDisplayHelp = #False
        EndIf
        bCheckDisplay = #True
        
      Case #PB_EventType_MouseLeave
        bDisplayHelp = #False
        bCheckDisplay = #True
        
    EndSelect
    
    If bCheckDisplay
      If bDisplayHelp <> bHelpDisplayed
        If bDisplayHelp
          GadToolTip(WQF\cvsSideLabels, sFullMessage, nMaxWidth)
          SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_NO_ICON, @sGraphHelp)
        EndIf
        bHelpDisplayed = bDisplayHelp
      EndIf
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQF_cvsGraph_Event()
  PROCNAMECA(nEditAudPtr)
  Protected nSliceType
  Protected nMouseX, nChangeInX, fChangeInTime.f
  Protected nMouseY, nChangeInY
  Protected nMouseTime, nFieldTime, nAfterValue
  Protected nLeft
  Protected u, n
  Protected sUndoDesc.s
  Protected nNewRelFilePos
  Protected fFieldRelDBLevel.f
  Protected fNewRelDBLevel.f
  Protected fRelDBLevelChangeExt.f
  Protected fFieldPan.f
  Protected fNewPan.f
  Protected nMouseDownSliceType, nMouseDownStartX, nMouseDownStartY, nMouseDownTime
  Protected nMinTime, nMaxTime
  Protected nItemIndex, nMarkerIdx
  Protected nCanvasCursor = -1
  Protected nLvlPtLvlSel, nLvlPtPanSel
  Protected nLevelPointIndex
  Protected nCurrLevelPointIndex, nCurrPointType, nCurrLoopInfoIndex
  Protected nCueMarkerId, nCueMarkerPosition, nCueMarkerType, nMGCueMarkerIndex, nOldMarkerPosition, nNewMarkerPosition, nCueMarkerIndex
  Protected nOldFadeInTime, nNewFadeInTime
  Protected nOldFadeOutTime, nNewFadeOutTime
  Protected nKeyDown
  Protected nDevSel, nMaxDevSel
  Protected nDevNo, nMaxDevNo
  Protected nWheelDelta, nSizeIncrement
  Protected nZoomValue, nMaxZoomValue
  Protected l2
  Protected bFound
  Protected nLevelPointId, bChanged
  Protected bRefreshCuePanel
  Protected nPointTime
  Static sLevelPointTime.s, sRelLevel.s, sPan.s
  Static bStaticLoaded
  Protected nTmpValue
  
  If bStaticLoaded = #False
    sLevelPointTime = Lang("WQF", "LevelPointTime")
    sRelLevel = Lang("WQF", "RelLevel")
    sPan = Lang("WQF", "Pan")
    bStaticLoaded = #True
  EndIf
  
  With grMG2
    
    If \bDeviceAssigned = #False
      ProcedureReturn
    EndIf
    
    ; debugMsg(sProcName, "gnEventType=" + decodeEventType(WQF\cvsGraph))
    
    Select gnEventType
      Case #PB_EventType_MouseEnter ; INFO: cvsGraph #PB_EventType_MouseEnter
        ;{
        ; debugMsg(sProcName, "#PB_EventType_MouseEnter start")
        \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
        ; debugMsg(sProcName, "#PB_EventType_MouseEnter end")
        ;}
      Case #PB_EventType_RightButtonDown ; INFO: cvsGraph #PB_EventType_RightButtonDown
        ;{
        debugMsg(sProcName, "#PB_EventType_RightButtonDown start")
        nMouseDownSliceType = checkMousePosInGraphQF(#True)  ; nb also sets grMG2\nMouseDownLevelPointId if appropriate
        nMouseDownStartX = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseX)
        nMouseDownStartY = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseY)
        nMouseDownTime = (nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
        ; the following commented out because level points and loops are mutually exclusive, so level points may only be added between 'start at' and 'end at'
        ; nMinTime = aAud(nEditAudPtr)\nAbsStartAt
        ; nMaxTime = aAud(nEditAudPtr)\nAbsEndAt
        ; If aAud(nEditAudPtr)\bContainsLoop
        ;   If aAud(nEditAudPtr)\nAbsLoopStart < nMinTime
        ;     nMinTime = aAud(nEditAudPtr)\nAbsLoopStart
        ;   EndIf
        ;   If aAud(nEditAudPtr)\nAbsLoopEnd > nMaxTime
        ;     nMaxTime = aAud(nEditAudPtr)\nAbsLoopEnd
        ;   EndIf
        ; EndIf
        \nMouseDownSliceType = nMouseDownSliceType
        \nMouseDownStartX = nMouseDownStartX
        \nMouseDownStartY = nMouseDownStartY
        \nMouseDownTime = nMouseDownTime
        WQF_graphContextMenuEnabledStates()
        SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
        DisplayPopupMenu(#WQF_mnu_GraphContextMenu, WindowID(#WED))
        ;}
      Case #PB_EventType_LeftButtonDown ; INFO: cvsGraph #PB_EventType_LeftButtonDown
        ;{
        ; debugMsg(sProcName, "#PB_EventType_LeftButtonDown start")
        ; listGraphMarkers()
        \nMouseDownSliceType = checkMousePosInGraphQF(#True)
        ; nb checkMousePosInGraphQF() also sets grMG2\nMouseDownLevelPointId and grMG2\nMouseDownItemId if appropriate, and grMG2\nMouseMinTime and grMG2\nMouseMaxTime
        ; also sets grMG2\nMouseDownLoopInfoIndex is appropriate
        ; debugMsg(sProcName, "grMG2\nMouseDownSliceType=" + decodeSliceType(\nMouseDownSliceType) + ", \nMouseDownLevelPointId=" + \nMouseDownLevelPointId)
        \nMouseDownStartX = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseX)
        \nMouseDownStartY = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseY)
        \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_NO_ACTION ; may be changed later in this procedure
        ; debugMsg(sProcName, "\nGraphTop=" + Str(\nGraphTop) + ", \nGraphTopL=" + Str(\nGraphTopL) + ", \nGraphTopR=" + Str(\nGraphTopR) + ", \nGraphBottom=" + Str(\nGraphBottom) +
        ;                     ", \nGraphBottomL=" + Str(\nGraphBottomL) + ", \nGraphBottomR=" + Str(\nGraphBottomR))
        nCurrLevelPointIndex = getCurrentItemData(WQF\cboDevSel)
        If nCurrLevelPointIndex >= 0
          nCurrPointType = aAud(nEditAudPtr)\aPoint(nCurrLevelPointIndex)\nPointType
        Else
          nCurrPointType = -1
        EndIf
        ; debugMsg0(sProcName, "nCurrLevelPointIndex=" + nCurrLevelPointIndex + ", nCurrPointType=" + decodeLevelPointType(nCurrPointType))
        
        If isCtrlKeyDown()
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_LP, #SCS_SLICE_TYPE_FI, #SCS_SLICE_TYPE_FO, #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
              addSelectedCtrlHoldLP(\nMouseDownLevelPointId) ; nb this procedure will de-select the level point if it is currently selected
          EndSelect
        ElseIf isAltKeyDown() = #False
          ; if neither a Ctrl key nor an Alt key is down, then initially clear the Ctrl Hold List for Level Points
          clearCtrlHoldLP()
          ; now add this entry to the Ctrl Hold List if required
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_LP, #SCS_SLICE_TYPE_FI, #SCS_SLICE_TYPE_FO, #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
              addSelectedCtrlHoldLP(\nMouseDownLevelPointId) ; nb this procedure will de-select the level point if it is currently selected
          EndSelect
        ElseIf isAltKeyDown()
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_LP, #SCS_SLICE_TYPE_FI, #SCS_SLICE_TYPE_FO, #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
              If checkSelectedCtrlHoldLP(\nMouseDownLevelPointId) = #False
                addSelectedCtrlHoldLP(\nMouseDownLevelPointId)
              EndIf
          EndSelect
        EndIf
        
        Select \nMouseDownSliceType
          Case #SCS_SLICE_TYPE_ST ; LeftButtonDown: #SCS_SLICE_TYPE_ST
            \nMouseDownTime = aAud(nEditAudPtr)\nAbsStartAt
            \nLastTimeMark = \nMouseDownTime
            \bSetFilePosAtStartAt = #False
            If (aAud(nEditAudPtr)\nAudState < #SCS_CUE_FADING_IN) Or (aAud(nEditAudPtr)\nAudState > #SCS_CUE_FADING_OUT)
              If (aAud(nEditAudPtr)\nRelFilePos + aAud(nEditAudPtr)\nAbsMin) = aAud(nEditAudPtr)\nAbsStartAt
                \bSetFilePosAtStartAt = #True
                ; debugMsg(sProcName, "\bSetFilePosAtStartAt=" + strB(\bSetFilePosAtStartAt))
              EndIf
            EndIf
            Select \nMouseDownGraphMarkerType
              Case #SCS_GRAPH_MARKER_ST, #SCS_GRAPH_MARKER_LP
                nCanvasCursor = WQF_setMarkerDragActionAndCursor()
                WQF_displayLevelPointInfo(#SCS_PT_START)
            EndSelect
            
          Case #SCS_SLICE_TYPE_EN ; LeftButtonDown: #SCS_SLICE_TYPE_EN
            \nMouseDownTime = aAud(nEditAudPtr)\nAbsEndAt
            If \nMouseDownTime >= aAud(nEditAudPtr)\nFileDuration
              \nMouseDownTime = aAud(nEditAudPtr)\nFileDuration - 1
            EndIf
            \nLastTimeMark = \nMouseDownTime
            Select \nMouseDownGraphMarkerType
              Case #SCS_GRAPH_MARKER_EN, #SCS_GRAPH_MARKER_LP
                nCanvasCursor = WQF_setMarkerDragActionAndCursor()
            EndSelect
            WQF_displayLevelPointInfo(#SCS_PT_END)
            
          Case #SCS_SLICE_TYPE_LS ; LeftButtonDown: #SCS_SLICE_TYPE_LS
            l2 = grMG2\nMouseDownLoopInfoIndex
            \nMouseDownTime = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
            \nLastTimeMark = \nMouseDownTime
            \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION
            nCanvasCursor = #PB_Cursor_LeftRight
            
          Case #SCS_SLICE_TYPE_LE ; LeftButtonDown: #SCS_SLICE_TYPE_LE
            l2 = grMG2\nMouseDownLoopInfoIndex
            \nMouseDownTime = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd
            \nLastTimeMark = \nMouseDownTime
            \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION
            nCanvasCursor = #PB_Cursor_LeftRight
            
          Case #SCS_SLICE_TYPE_FI ; LeftButtonDown: #SCS_SLICE_TYPE_FI
            If aAud(nEditAudPtr)\nFadeInTime > 0
              \nMouseDownTime = aAud(nEditAudPtr)\nAbsStartAt + aAud(nEditAudPtr)\nFadeInTime
            Else
              \nMouseDownTime = aAud(nEditAudPtr)\nAbsStartAt
            EndIf
            \nLastTimeMark = \nMouseDownTime
            nCanvasCursor = WQF_setMarkerDragActionAndCursor()
            ; commented out the following 9May2019 11.8.1rc2 following email from C Peters
            ; If nCurrPointType <> #SCS_PT_FADE_IN
            ;   WQF_displayLevelPointInfo(#SCS_PT_FADE_IN)
            ; EndIf
            WQF_displayLevelPointInfo(#SCS_PT_FADE_IN) ; reinstated 11Feb2022 11.9.0 following latest report from CPeters
            
          Case #SCS_SLICE_TYPE_FO ; LeftButtonDown: #SCS_SLICE_TYPE_FO
            If aAud(nEditAudPtr)\nFadeOutTime > 0
              \nMouseDownTime = aAud(nEditAudPtr)\nAbsEndAt - aAud(nEditAudPtr)\nFadeOutTime
            Else
              \nMouseDownTime = aAud(nEditAudPtr)\nAbsEndAt
            EndIf
            \nLastTimeMark = \nMouseDownTime
            nCanvasCursor = WQF_setMarkerDragActionAndCursor()
            ; commented out the following 9May2019 11.8.1rc2 following email from C Peters
            ; If nCurrPointType <> #SCS_PT_FADE_OUT
            ;   WQF_displayLevelPointInfo(#SCS_PT_FADE_OUT)
            ; EndIf
            WQF_displayLevelPointInfo(#SCS_PT_FADE_OUT) ; reinstated 11Feb2022 11.9.0 following latest report from CPeters
            
          Case #SCS_SLICE_TYPE_LP ; LeftButtonDown: #SCS_SLICE_TYPE_LP
            ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(nEditAudPtr) + ")")
            ; listLevelPoints(nEditAudPtr)
            nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
            ; debugMsg(sProcName, "#SCS_SLICE_TYPE_LP: nLevelPointIndex=" + nLevelPointIndex + ", nCurrPointType=" + nCurrPointType)
            If nLevelPointIndex >= 0
              \nMouseDownTime = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime
              \nLastTimeMark = \nMouseDownTime
              nCanvasCursor = WQF_setMarkerDragActionAndCursor()
              ; commented out the following 9May2019 11.8.1rc2 following email from C Peters
              ; WQF_displayLevelPointInfo(#SCS_PT_STD, \nMouseDownTime)
              WQF_displayLevelPointInfo(#SCS_PT_STD, \nMouseDownTime) ; reinstated 11Feb2022 11.9.0 following latest report from CPeters
            EndIf
            ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(nEditAudPtr) + ")")
            ; listLevelPoints(nEditAudPtr)
            
          Case #SCS_SLICE_TYPE_CURR ; LeftButtonDown: #SCS_SLICE_TYPE_CURR
            \nMouseDownTime = (\nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
            ; debugMsg(sProcName, "LeftButtonDown: \nMouseDownStartX=" + \nMouseDownStartX + ", \nGraphLeft=" + \nGraphLeft + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,2) + ", \nMouseDownTime=" + \nMouseDownTime)
            \nLastTimeMark = \nMouseDownTime
            
          Case #SCS_SLICE_TYPE_NORMAL ; LeftButtonDown: #SCS_SLICE_TYPE_NORMAL
            \nMouseDownTime = (\nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
            \nMouseDownCanvasLeft = \nGraphLeft
            ; debugMsg(sProcName, "LeftButtonDown: \nMouseDownStartX=" + \nMouseDownStartX + ", \nGraphLeft=" + \nGraphLeft + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,2) + ", \nMouseDownTime=" + \nMouseDownTime)
            \nMouseDownGrabStartX = WindowMouseX(#WED)
            SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_CustomCursor, hCursorGrabbing)
            If (aAud(nEditAudPtr)\nAudState < #SCS_CUE_FADING_IN) Or (aAud(nEditAudPtr)\nAudState > #SCS_CUE_FADING_OUT)
              aAud(nEditAudPtr)\bResetFilePosToStartAtInMain = #True
              ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bResetFilePosToStartAtInMain=" + strB(aAud(nEditAudPtr)\bResetFilePosToStartAtInMain))
            EndIf
            
          Case #SCS_SLICE_TYPE_CM ;  ; LeftButtonDown: #SCS_SLICE_TYPE_CM
            nMGCueMarkerIndex = \nMouseDownGraphMarkerIndex
            nCueMarkerId = \nMouseDownCueMarkerId
            nCueMarkerIndex = -1
            nCueMarkerPosition = -1
            If nEditAudPtr >= 0
              bFound = #False
              For n = 0 To aAud(nEditAudPtr)\nMaxCueMarker
                If aAud(nEditAudPtr)\aCueMarker(n)\nCueMarkerId = nCueMarkerId
                  nCueMarkerIndex = n
                  Break
                EndIf
              Next n
              If nCueMarkerIndex >= 0
                nCueMarkerPosition = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
                If nCueMarkerPosition >= 0
                  ; debugMsg(sProcName, "#SCS_SLICE_TYPE_CM: nCueMarkerPosition=" + nCueMarkerPosition + ", nCueMarkerType=" + nCueMarkerType + ", sCueMarkerName=" + aAud(nEditAudPtr)\aCueMarker(n)\sCueMarkerName)
                  \nMouseDownTime = nCueMarkerPosition 
                  \nLastTimeMark = \nMouseDownTime
                  nCanvasCursor = WQF_setMarkerDragActionAndCursor() ; I believe this actually does nothing as it does not test for Cue Markers as yet
                EndIf
              EndIf
              WQF_refreshCueMarkersDisplayEtc() ; Added 29Oct2024 11.10.6ay so that "CM" is displayed immediately on left button down, instead of waiting for the mouse move event
            EndIf
            
        EndSelect
        redrawGraphAfterMouseChange(@grMG2)
        ; nb do not rely on an earlier setting of nLevelPointIndex as the level point entry may have been moved by setDerivedLevelPointInfo()
        
        If \nMouseDownSliceType = #SCS_SLICE_TYPE_CM
          nCueMarkerIndex = \nMouseDownGraphMarkerIndex
          If nCueMarkerIndex >= 0
            drawTip(@grMG2, \nMouseDownSliceType, -1, -1, nCueMarkerIndex)
          EndIf
        Else
          nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
          drawTip(@grMG2, \nMouseDownSliceType, nLevelPointIndex, \nMouseDownLoopInfoIndex)
        EndIf
        ; Moved into the If EndIf statement above
        ;nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
        ;drawTip(\nMouseDownSliceType, nLevelPointIndex, \nMouseDownLoopInfoIndex)
        
        CompilerIf 1=2
          ; blocked out 2Feb2022 11.9.0rc7
          debugMsg(sProcName, "calling setCurrLoopReleasedState(" + getAudLabel(nEditAudPtr) + ")")
          setCurrLoopReleasedState(nEditAudPtr)
          debugMsg(sProcName, "returned from setCurrLoopReleasedState(" + getAudLabel(nEditAudPtr) + ")")
        CompilerEndIf
        If nCanvasCursor >= 0
          SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Cursor, nCanvasCursor)
        EndIf
        ; debugMsg(sProcName, "Mouse Down \nMouseDownSliceType=" + \nMouseDownSliceType + ", \nMouseDownTime=" + \nMouseDownTime)
        ; debugMsg0(sProcName, "#PB_EventType_LeftButtonDown end")
        ; listGraphMarkers()
        ;}
      Case #PB_EventType_LeftButtonUp ; INFO: cvsGraph #PB_EventType_LeftButtonUp
        ;{
        ; debugMsg(sProcName, "#PB_EventType_LeftButtonUp start, \nMouseDownSliceType=" + decodeSliceType(\nMouseDownSliceType))
        Select \nMouseDownSliceType
          Case #SCS_SLICE_TYPE_ST
            If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
              debugMsg(sProcName, "calling reopenAudFileIfReqd(" + getAudLabel(nEditAudPtr) + ")")
              reopenAudFileIfReqd(nEditAudPtr)
              WQF_populateFileTypeExt(nEditAudPtr)
            EndIf
            If \bSetFilePosAtStartAt
              aAud(nEditAudPtr)\nRelFilePos = aAud(nEditAudPtr)\nAbsStartAt - aAud(nEditAudPtr)\nAbsMin
              ; debugMsg(sProcName, "\nAbsStartAt=" + aAud(nEditAudPtr)\nAbsStartAt + ", \nAbsMin=" + aAud(nEditAudPtr)\nAbsMin + ", \nRelFilePos=" + aAud(nEditAudPtr)\nRelFilePos)
              reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt, #True)
              editSetDisplayButtonsF()
              setDerivedLevelPointInfo2(nEditAudPtr)
              redrawGraphAfterMouseChange(@grMG2)
            EndIf
            ; debugMsg(sProcName, "calling setBassPlayEnd(" + getAudLabel(nEditAudPtr) + ")")
            setBassPlayEnd(nEditAudPtr)
            ; debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
            setBassMarkerPositions(nEditAudPtr)
            bRefreshCuePanel = #True
            
          Case #SCS_SLICE_TYPE_EN, #SCS_SLICE_TYPE_FI, #SCS_SLICE_TYPE_FO
            If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
              debugMsg(sProcName, "calling reopenAudFileIfReqd(" + getAudLabel(nEditAudPtr) + ")")
              reopenAudFileIfReqd(nEditAudPtr)
              WQF_populateFileTypeExt(nEditAudPtr)
            EndIf
            ; debugMsg(sProcName, "calling setBassPlayEnd(" + getAudLabel(nEditAudPtr) + ")")
            setBassPlayEnd(nEditAudPtr)
            ; debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
            setBassMarkerPositions(nEditAudPtr)
            bRefreshCuePanel = #True
            
          Case #SCS_SLICE_TYPE_NORMAL
            If WindowMouseX(#WED) = \nMouseDownGrabStartX
              ; user just left-clicked on graph - didn't drag mouse - so reposition
              \nMouseDownTime = (\nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
              nMouseTime = \nMouseDownTime
              If nMouseTime < aAud(nEditAudPtr)\nAbsMin
                nMouseTime = aAud(nEditAudPtr)\nAbsMin
              ElseIf nMouseTime > aAud(nEditAudPtr)\nAbsMax
                nMouseTime = aAud(nEditAudPtr)\nAbsMax
              EndIf
              \nLastTimeMark = nMouseTime
              nFieldTime = aAud(nEditAudPtr)\nRelFilePos + aAud(nEditAudPtr)\nAbsMin
              \nReposMouseTime = nMouseTime
              If nMouseTime <> nFieldTime
                aAud(nEditAudPtr)\nRelFilePos = nMouseTime - aAud(nEditAudPtr)\nAbsMin
                ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos=" + aAud(nEditAudPtr)\nRelFilePos)
                reposAuds(nEditAudPtr, nMouseTime, #True)
                editSetDisplayButtonsF()
                redrawGraphAfterMouseChange(@grMG2)
              EndIf
            EndIf
            SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Cursor, #PB_Cursor_Default)
            
          Case #SCS_SLICE_TYPE_CM ; #SCS_SLICE_TYPE_CM
            ; added 26Feb2019 11.8.0.2av
            nCueMarkerId = \nMouseDownCueMarkerId
            ; debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
            setBassMarkerPositions(nEditAudPtr)
            ; debugMsg(sProcName, "calling propogateCueMarkerPositionChange(" + getAudLabel(nEditAudPtr) + ", " + nCueMarkerId + ")")
            propogateCueMarkerPositionChange(nEditAudPtr, nCueMarkerId)
            gbForceReloadAllDispPanels = #True
            gbCallLoadDispPanels = #True
            ; end added 26Feb2019 11.8.0.2av
            redrawGraphAfterMouseChange(@grMG2)
            SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Cursor, #PB_Cursor_Default)
            ; bRefreshCuePanel = #True
            
          Case #SCS_SLICE_TYPE_LP
            ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(nEditAudPtr) + ")")
            ; listLevelPoints(nEditAudPtr)

        EndSelect
        nCurrLoopInfoIndex = getCurrLoopInfoIndexAndSetLoopReleasedIndsIfReqd(nEditAudPtr, aAud(nEditAudPtr)\nRelFilePos, #True, #False)
        \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
        \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_NO_ACTION
        If aAud(nEditAudPtr)\nMaxCueMarker >= 0
          WQF_refreshCueMarkersDisplayEtc()
        EndIf
        debugMsg(sProcName, "#PB_EventType_LeftButtonUp end")
        ;}
      Case #PB_EventType_MouseMove  ; INFO: cvsGraph #PB_EventType_MouseMove
        ;{
        ; debugMsg(sProcName, "#PB_EventType_MouseMove start, \nMouseDownSliceType=" + decodeSliceType(\nMouseDownSliceType))
        If \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
          nSliceType = checkMousePosInGraphQF()   ; sets cursor if over a hot spot, else resets default cursor
          nTmpValue = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseX)  
          If nSliceType = #SCS_SLICE_TYPE_CM Or nSliceType = #SCS_SLICE_TYPE_CP
            nCueMarkerIndex = \nMouseMoveMarkerIndex
            If nCueMarkerIndex >= 0
              drawTip(@grMG2, nSliceType, -1, -1, nCueMarkerIndex)
            EndIf
          Else
            nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseMoveLevelPointId)
            ; debugMsg0(sProcName, "\nMouseMoveLevelPointId=" + \nMouseMoveLevelPointId + ", nLevelPointIndex=" + nLevelPointIndex)
            drawTip(@grMG2, nSliceType, nLevelPointIndex, \nMouseDownLoopInfoIndex)
          EndIf
          
        Else
          nMouseX = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseX)
          nChangeInX = nMouseX - \nMouseDownStartX
          fChangeInTime = nChangeInX * \fMillisecondsPerPixel
          nMouseTime = \nMouseDownTime + fChangeInTime
          If nMouseTime < 0
            nMouseTime = 0
          ElseIf nMouseTime >= aAud(nEditAudPtr)\nFileDuration
            nMouseTime = aAud(nEditAudPtr)\nFileDuration - 1
          EndIf
          ; debugMsg0(sProcName, "MM \nMouseDownGraphMarkerType=" + decodeGraphMarkerType(\nMouseDownGraphMarkerType) + ", rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", grMG2\nMarkerDragAction=" + \nMarkerDragAction)
          Select \nMarkerDragAction
            Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL
              nMouseY = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseY)
              nChangeInY = nMouseY - \nMouseDownStartY
              fNewRelDBLevel = graphYToRelDBLevel(nMouseY)
              ; debugMsg0(sProcName, "nMouseY=" + nMouseY + ", fNewRelDBLevel=" + convertDBLevelToDBString(fNewRelDBLevel))
              
            Case #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
              nMouseY = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseY)
              nChangeInY = nMouseY - \nMouseDownStartY
              fNewPan = graphYToPan(nMouseY)
              
          EndSelect
          ; debugMsg(sProcName, "MouseMove \nMouseDownSliceType=" + \nMouseDownSliceType + ", nChangeInX=" + Str(nChangeInX) + ", fChangeInTime=" + StrF(fChangeInTime,4) + ", nMouseTime=" + Str(nMouseTime))
          
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_CURR ; MouseMove: #SCS_SLICE_TYPE_CURR
              If nMouseTime > \nMouseMaxTime
                nMouseTime = \nMouseMaxTime
              ElseIf nMouseTime < \nMouseMinTime
                nMouseTime = \nMouseMinTime
              EndIf
              \nLastTimeMark = nMouseTime
              nFieldTime = aAud(nEditAudPtr)\nRelFilePos + aAud(nEditAudPtr)\nAbsMin
              \nReposMouseTime = nMouseTime
              If nMouseTime <> nFieldTime
                aAud(nEditAudPtr)\nRelFilePos = nMouseTime - aAud(nEditAudPtr)\nAbsMin
                ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos=" + aAud(nEditAudPtr)\nRelFilePos)
                reposAuds(nEditAudPtr, nMouseTime, #True)
                editSetDisplayButtonsF()
                redrawGraphAfterMouseChange(@grMG2)
              EndIf
              
            Case #SCS_SLICE_TYPE_ST ; MouseMove: #SCS_SLICE_TYPE_ST   START
              Select \nMarkerDragAction
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                  ; Debug "ST: nMouseTime=" + timeToStringT(nMouseTime) + ", \nMouseMaxTime=" + timeToStringT(\nMouseMaxTime)
                  If nMouseTime > \nMouseMaxTime
                    ; Debug "ST: nMouseTime=" + timeToStringT(nMouseTime) + ", \nMouseMaxTime=" + timeToStringT(\nMouseMaxTime)
                    nMouseTime = \nMouseMaxTime
                  EndIf
                  \nLastTimeMark = nMouseTime
                  nFieldTime = aAud(nEditAudPtr)\nAbsStartAt
                  If nMouseTime <> nFieldTime
                    u = preChangeAudL(aAud(nEditAudPtr)\nStartAt, GGT(WQF\lblStartAt), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                    aAud(nEditAudPtr)\nAbsStartAt = nMouseTime
                    If aAud(nEditAudPtr)\nAbsStartAt <= 0
                      aAud(nEditAudPtr)\nStartAt = -2
                    Else
                      aAud(nEditAudPtr)\nStartAt = aAud(nEditAudPtr)\nAbsStartAt
                    EndIf
                    aAud(nEditAudPtr)\bAudNormSet = #False
                    nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
                    If nLevelPointIndex >= 0
                      ; debugMsg(sProcName, "changing aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointTime (" + timeToStringT(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime) + ") to " + timeToStringT(nMouseTime))
                      aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime = nMouseTime
                      rWQF\nCurrLevelPointTime = nMouseTime
                      rWQF\nCurrLevelPointType = #SCS_PT_START
                    EndIf
                    ; debugMsg(sProcName, "calling setDerivedAudFields")
                    setDerivedAudFields(nEditAudPtr)
                    SGT(WQF\txtStartAt, timeToStringT(aAud(nEditAudPtr)\nStartAt, aAud(nEditAudPtr)\nFileDuration))
                    nAfterValue = aAud(nEditAudPtr)\nStartAt
                    ; debugMsg(sProcName, "nFieldTime=" + Str(nFieldTime) + ", nAfterValue=" + Str(nAfterValue))
                    CompilerIf 1=2
                      ; 11/04/2015 (11.3.9ktr) blocked out resetting \nRelFilePos following bug reported by Carl Underwood, that only affects SM-S users.
                      ; resetting \nRelFilePos can cause 'subscript out of range' when drawing the graph, and this was due to drawPosSlice() using \nRelFilePos
                      ; for SM-S users. it is correct that drawPosSlice() does use \nRelFilePos, but \nRelFilePos mustn't be set here.
                      ; blocking out this code does not affect DirectSound users.
                      ; see email "SCS crash when editing loop start and end" from Carl Underwood for more info.
                      nNewRelFilePos = aAud(nEditAudPtr)\nRelFilePos + (nFieldTime - nAfterValue)
                      ; debugMsg(sProcName, "changing aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos from " + Str(aAud(nEditAudPtr)\nRelFilePos) + " to " + Str(nNewRelFilePos))
                      aAud(nEditAudPtr)\nRelFilePos = nNewRelFilePos
                    CompilerEndIf
                    WQF_refreshFileInfo()
                    redrawGraphAfterMouseChange(@grMG2)
                    WQF_setClearState()
                    postChangeAudLN(u, nAfterValue)
                    WQF_setViewControls()
                  EndIf
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL ; change relative level
                  WQF_Macro_ChangeLevel()
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
                  WQF_Macro_ChangePan()
              EndSelect
              
            Case #SCS_SLICE_TYPE_FI ; MouseMove: #SCS_SLICE_TYPE_FI     FADE IN
              Select \nMarkerDragAction
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                  If nMouseTime > \nMouseMaxTime
                    nMouseTime = \nMouseMaxTime
                  ElseIf nMouseTime < \nMouseMinTime
                    nMouseTime = \nMouseMinTime
                  EndIf
                  \nLastTimeMark = nMouseTime
                  If aAud(nEditAudPtr)\nFadeInTime > 0
                    nFieldTime = aAud(nEditAudPtr)\nAbsStartAt + aAud(nEditAudPtr)\nFadeInTime
                  Else
                    nFieldTime = aAud(nEditAudPtr)\nAbsStartAt
                  EndIf
                  If nMouseTime <> nFieldTime
                    ; debugMsg(sProcName, "#SCS_SLICE_TYPE_FI: calling preChangeAudL(" + aAud(nEditAudPtr)\nFadeInTime + ",...)")
                    u = preChangeAudL(aAud(nEditAudPtr)\nFadeInTime, GGT(WQF\lblFadeInTime), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                    nOldFadeInTime = aAud(nEditAudPtr)\nFadeInTime
                    aAud(nEditAudPtr)\nFadeInTime = nMouseTime - aAud(nEditAudPtr)\nAbsStartAt
                    If aAud(nEditAudPtr)\nFadeInTime <= 0
                      aAud(nEditAudPtr)\nFadeInTime = -2
                    EndIf
                    nNewFadeInTime = aAud(nEditAudPtr)\nFadeInTime
                    maintainFadeInLevelPoint(nEditAudPtr, nOldFadeInTime, nNewFadeInTime)
                    rWQF\nCurrLevelPointTime = nMouseTime
                    rWQF\nCurrLevelPointType = #SCS_PT_FADE_IN
                    SGT(WQF\txtFadeInTime, timeToStringT(aAud(nEditAudPtr)\nFadeInTime))
                    nAfterValue = aAud(nEditAudPtr)\nFadeInTime
                    WQF_refreshFileInfo()
                    redrawGraphAfterMouseChange(@grMG2)
                    WQF_setClearState()
                    ; debugMsg(sProcName, "#SCS_SLICE_TYPE_FI: calling postChangeAudLN(u, " + nAfterValue + ")")
                    postChangeAudLN(u, nAfterValue)
                    WQF_setViewControls()
                  EndIf
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL ; change relative level
                  WQF_Macro_ChangeLevel()
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
                  WQF_Macro_ChangePan()
              EndSelect
              
            Case #SCS_SLICE_TYPE_FO ; MouseMove: #SCS_SLICE_TYPE_FO    FADE OUT
              Select \nMarkerDragAction
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                  If nMouseTime > \nMouseMaxTime
                    nMouseTime = \nMouseMaxTime
                  ElseIf nMouseTime < \nMouseMinTime
                    nMouseTime = \nMouseMinTime
                  EndIf
                  \nLastTimeMark = nMouseTime
                  If aAud(nEditAudPtr)\nFadeOutTime > 0
                    nFieldTime = aAud(nEditAudPtr)\nAbsEndAt - aAud(nEditAudPtr)\nFadeOutTime
                  Else
                    nFieldTime = aAud(nEditAudPtr)\nAbsEndAt
                  EndIf
                  If nMouseTime <> nFieldTime
                    u = preChangeAudL(aAud(nEditAudPtr)\nFadeOutTime, GGT(WQF\lblFadeOutTime), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                    nOldFadeOutTime = aAud(nEditAudPtr)\nFadeOutTime
                    aAud(nEditAudPtr)\nFadeOutTime = aAud(nEditAudPtr)\nAbsEndAt - nMouseTime
                    If aAud(nEditAudPtr)\nFadeOutTime <= 0
                      aAud(nEditAudPtr)\nFadeOutTime = -2
                    EndIf
                    nNewFadeOutTime = aAud(nEditAudPtr)\nFadeOutTime
                    maintainFadeOutLevelPoint(nEditAudPtr, nOldFadeOutTime, nNewFadeOutTime)
                    rWQF\nCurrLevelPointTime = nMouseTime
                    rWQF\nCurrLevelPointType = #SCS_PT_FADE_OUT
                    SGT(WQF\txtFadeOutTime, timeToStringT(aAud(nEditAudPtr)\nFadeOutTime))
                    nAfterValue = aAud(nEditAudPtr)\nFadeOutTime
                    WQF_refreshFileInfo()
                    redrawGraphAfterMouseChange(@grMG2)
                    WQF_setClearState()
                    postChangeAudLN(u, nAfterValue)
                    WQF_setViewControls()
                  EndIf
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL ; change relative level
                  WQF_Macro_ChangeLevel()
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
                  WQF_Macro_ChangePan()
              EndSelect
              
            Case #SCS_SLICE_TYPE_LP ; MouseMove: #SCS_SLICE_TYPE_LP     LEVEL POINT
              nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
              ; debugMsg0(sProcName, "nLevelPointIndex=" + nLevelPointIndex + ", \nMarkerDragAction=" + \nMarkerDragAction)
              If nLevelPointIndex >= 0
                Select \nMarkerDragAction
                  Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                    If nMouseTime > \nMouseMaxTime
                      nMouseTime = \nMouseMaxTime
                    ElseIf nMouseTime < \nMouseMinTime
                      nMouseTime = \nMouseMinTime
                    EndIf
                    \nLastTimeMark = nMouseTime
                    nFieldTime = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime
                    If nMouseTime <> nFieldTime
                      u = preChangeAudL(#True, sLevelPointTime, -5, #SCS_UNDO_ACTION_CHANGE, nLevelPointIndex, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                      aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime = nMouseTime
                      rWQF\nCurrLevelPointTime = nMouseTime
                      setDerivedLevelPointInfo2(nEditAudPtr)
                      redrawGraphAfterMouseChange(@grMG2)
                      postChangeAudLN(u, #False)
                      WQF_populateCboDevSel() ; update combobox to show new level point time
                    EndIf
                  Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL ; change relative level
                    WQF_Macro_ChangeLevel()
                  Case #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
                    WQF_Macro_ChangePan()
                EndSelect
              EndIf
              
            Case #SCS_SLICE_TYPE_EN ; MouseMove: #SCS_SLICE_TYPE_EN
              Select \nMarkerDragAction
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                  nFieldTime = aAud(nEditAudPtr)\nAbsEndAt
                  ; debugMsg(sProcName, "EN: nMouseTime=" + nMouseTime + ", \nMouseMinTime=" + \nMouseMinTime + ", nFieldTime=" + nFieldTime + 
                  ;                     ", aAud(" + getAudLabel(nEditAudPtr) + ")\nAbsStartAt=" + aAud(nEditAudPtr)\nAbsStartAt + ", \nAbsEndAt=" + aAud(nEditAudPtr)\nAbsEndAt)
                  If nMouseTime < \nMouseMinTime
                    nMouseTime = \nMouseMinTime
                  EndIf
                  \nLastTimeMark = nMouseTime
                  If nMouseTime <> nFieldTime
                    u = preChangeAudL(aAud(nEditAudPtr)\nEndAt, GGT(WQF\lblEndAt), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                    aAud(nEditAudPtr)\nAbsEndAt = nMouseTime
                    If aAud(nEditAudPtr)\nAbsEndAt >= aAud(nEditAudPtr)\nFileDuration
                      aAud(nEditAudPtr)\nEndAt = -2
                    Else
                      aAud(nEditAudPtr)\nEndAt = aAud(nEditAudPtr)\nAbsEndAt
                    EndIf
                    aAud(nEditAudPtr)\bAudNormSet = #False
                    ; debugMsg(sProcName, "EN: aAud(" + getAudLabel(nEditAudPtr) + ")\nAbsStartAt=" + aAud(nEditAudPtr)\nAbsStartAt + ", \nAbsEndAt=" + aAud(nEditAudPtr)\nAbsEndAt)
                    nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
                    If nLevelPointIndex >= 0
                      aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime = nMouseTime
                      rWQF\nCurrLevelPointTime = nMouseTime
                      rWQF\nCurrLevelPointType = #SCS_PT_END
                    EndIf
                    ; debugMsg(sProcName, "calling setDerivedAudFields")
                    setDerivedAudFields(nEditAudPtr)
                    SGT(WQF\txtEndAt, timeToStringT(aAud(nEditAudPtr)\nEndAt, aAud(nEditAudPtr)\nFileDuration))
                    nAfterValue = aAud(nEditAudPtr)\nEndAt
                    WQF_refreshFileInfo()
                    redrawGraphAfterMouseChange(@grMG2)
                    WQF_setClearState()
                    postChangeAudLN(u, nAfterValue)
                    WQF_setViewControls()
                  EndIf
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL ; change relative level
                  WQF_Macro_ChangeLevel()
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_PAN
                  WQF_Macro_ChangePan()
              EndSelect
              
            Case #SCS_SLICE_TYPE_LS ; MouseMove: #SCS_SLICE_TYPE_LS    LOOP START
              l2 = grMG2\nMouseDownLoopInfoIndex
              If aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd > 0
                If nMouseTime > aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd
                  nMouseTime = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd
                EndIf
              EndIf
              \nLastTimeMark = nMouseTime
              nFieldTime = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
              If nMouseTime <> nFieldTime
                u = preChangeAudL(aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart, GGT(WQF\lblLoopStart), -5, #SCS_UNDO_ACTION_CHANGE, l2, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart = nMouseTime
                aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
                ; if loop end not yet set then assume cue end
                If aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd = -2
                  aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd = -1
                EndIf
                aAud(nEditAudPtr)\bAudNormSet = #False
                ; debugMsg(sProcName, "calling setDerivedAudFields")
                setDerivedAudFields(nEditAudPtr)
                If l2 = rWQF\nDisplayedLoopInfoIndex
                  SGT(WQF\txtLoopStart, timeToStringT(aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart, aAud(nEditAudPtr)\nFileDuration))
                  SGT(WQF\txtLoopEnd, timeToStringT(aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd, aAud(nEditAudPtr)\nFileDuration))
                EndIf
                nAfterValue = aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart
                WQF_refreshFileInfo()
                redrawGraphAfterMouseChange(@grMG2)
                ; debugMsg(sProcName, "(LS) calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
                setBassLoopStart(nEditAudPtr)
                ; debugMsg(sProcName, "(LS) calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
                setBassLoopEnd(nEditAudPtr)
                WQF_setClearState()
                postChangeAudLN(u, nAfterValue, -5, l2)
                WQF_setViewControls()
                setLoopAddBtnEnabledState()
              EndIf
              
            Case #SCS_SLICE_TYPE_LE ; MouseMove: #SCS_SLICE_TYPE_LE   LOOP END
              l2 = grMG2\nMouseDownLoopInfoIndex
              If nMouseTime < aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
                nMouseTime = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
              EndIf
              \nLastTimeMark = nMouseTime
              nFieldTime = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd
              If nMouseTime <> nFieldTime
                u = preChangeAudL(aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd, GGT(WQF\lblLoopEnd), -5, #SCS_UNDO_ACTION_CHANGE, l2, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd = nMouseTime
                aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd
                ; if loop start not yet set then assume cue start
                If aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart = -2
                  aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart = aAud(nEditAudPtr)\nAbsStartAt
                  aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
                EndIf
                aAud(nEditAudPtr)\bAudNormSet = #False
                ; debugMsg(sProcName, "calling setDerivedAudFields")
                setDerivedAudFields(nEditAudPtr)
                If l2 = rWQF\nDisplayedLoopInfoIndex
                  SGT(WQF\txtLoopEnd, timeToStringT(aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd, aAud(nEditAudPtr)\nFileDuration))
                  SGT(WQF\txtLoopStart, timeToStringT(aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopStart, aAud(nEditAudPtr)\nFileDuration))
                EndIf
                nAfterValue = aAud(nEditAudPtr)\aLoopInfo(l2)\nLoopEnd
                WQF_refreshFileInfo()
                redrawGraphAfterMouseChange(@grMG2)
                ; debugMsg(sProcName, "(LE) calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
                setBassLoopStart(nEditAudPtr)
                ; debugMsg(sProcName, "(LE) calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
                setBassLoopEnd(nEditAudPtr)
                WQF_setClearState()
                postChangeAudLN(u, nAfterValue, -5, l2)
                WQF_setViewControls()
                setLoopAddBtnEnabledState()
              EndIf
              
            Case #SCS_SLICE_TYPE_NORMAL ; MouseMove: #SCS_SLICE_TYPE_NORMAL
              nMouseX = WindowMouseX(#WED)
              nChangeInX = nMouseX - \nMouseDownGrabStartX
              If nChangeInX <> 0
                ; user is dragging the display
                nLeft = \nMouseDownCanvasLeft + nChangeInX
                If nLeft > 0
                  nLeft = 0
                ElseIf nLeft < (\nVisibleWidth - \nInnerWidth)
                  nLeft = (\nVisibleWidth - \nInnerWidth)
                EndIf
                ; debugMsg(sProcName, "nMouseX=" + Str(nMouseX) + ", nLeft=" + nLeft)
                If nLeft <> \nGraphLeft
                  \nGraphLeft = nLeft
                  ; debugMsg(sProcName, "grMG2\nGraphLeft=" + \nGraphLeft)
                  ; debugMsg(sProcName, "calling drawWholeGraphArea()")
                  drawWholeGraphArea()
                  ; debugMsg(sProcName, "calling setViewStartAndEndFromVisibleGraph()")
                  setViewStartAndEndFromVisibleGraph()
                  ; WQF_setZoomAndPosSliders(#True)
                  ; debugMsg(sProcName, "calling WQF_setPosSlider()")
                  WQF_setPosSlider()
                EndIf
              EndIf
              
            Case #SCS_SLICE_TYPE_CM ; MouseMove: #SCS_SLICE_TYPE_CM  CUE MARKER
              ; Handle no sliding if audio file is currently playing
              If aAud(nEditAudPtr)\nAudState <> #SCS_CUE_PLAYING
                
                ; Handle any Slide Movement here
                ; \nMouseDownSliceType = #SCS_SLICE_TYPE_CM
                ; nMGCueMarkerIndex = grMG2\aGraphMarker(\nMouseDownGraphMarkerIndex)\nMGCueMarkerIndex
                nMGCueMarkerIndex = \nMouseDownGraphMarkerIndex
                If nMouseTime > \nMouseMaxTime
                  nMouseTime = \nMouseMaxTime
                ElseIf nMouseTime < \nMouseMinTime
                  nMouseTime = \nMouseMinTime
                EndIf
                \nLastTimeMark = nMouseTime
                
                nFieldTime = aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition
                If nMouseTime <> nFieldTime
                  ; debugMsg(sProcName, "#SCS_SLICE_TYPE_CM: calling preChangeAudL(" + aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition + ",...)")
                  u = preChangeAudL(aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition , "Move Cue Marker", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                  nOldMarkerPosition = aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition
                  
                  If nMouseTime < aAud(nEditAudPtr)\nAbsStartAt
                    aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition = aAud(nEditAudPtr)\nAbsStartAt
                  ElseIf  nMouseTime > aAud(nEditAudPtr)\nAbsEndAt
                    aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition = aAud(nEditAudPtr)\nAbsEndAt
                  Else
                    aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition = nMouseTime
                  EndIf
                  nAfterValue = aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition
                  ; debugMsg(sProcName, "#SCS_SLICE_TYPE_CM: calling postChangeAudLN(u, " + nAfterValue + ")")
                  postChangeAudLN(u, nAfterValue)
                  ; WQF_refreshCueMarkersDisplayEtc() ; Repositioned 29Oct2024 11.10/6ay - see comment below
                EndIf
                WQF_refreshCueMarkersDisplayEtc() ; Repositioned 29Oct2024 11.10.6ay so that "CM" remains displayed even if nMouseTime = nFieldTime
              EndIf
              
            Case #SCS_SLICE_TYPE_CP
              ; no action - not an SCS control
              
          EndSelect
          
          If \nMouseDownSliceType = #SCS_SLICE_TYPE_CM Or \nMouseDownSliceType = #SCS_SLICE_TYPE_CP
            ; nMouseTime already populated earlier
            nCueMarkerIndex = \nMouseMoveMarkerIndex
            If nCueMarkerIndex >= 0
              ; Draw the Tip for a Cue Marker with Mouse Moving
              drawTip(@grMG2, \nMouseDownSliceType, -1, -1, nCueMarkerIndex)
            EndIf
          Else
            nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, \nMouseDownLevelPointId)
            drawTip(@grMG2, \nMouseDownSliceType, nLevelPointIndex, \nMouseDownLoopInfoIndex)
          EndIf
          
          ; debugMsg(sProcName, "calling setCurrLoopReleasedState(" + getAudLabel(nEditAudPtr) + ")")
          setCurrLoopReleasedState(nEditAudPtr)
          
        EndIf
        ;}
      Case #PB_EventType_KeyDown ; INFO: cvsGraph #PB_EventType_KeyDown
        ;{
        nKeyDown = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Key)
        Select nKeyDown
          Case #PB_Shortcut_Left
            debugMsg(sProcName, "nKeyDown=#PB_Shortcut_Left")
            nDevSel = GGS(WQF\cboDevSel) - 1
            If nDevSel >= 0
              debugMsg(sProcName, "setting WQF\cboDevSel=" + nDevSel)
              SGS(WQF\cboDevSel, nDevSel)
              WQF_cboDevSel_Click()
            EndIf
            
          Case #PB_Shortcut_Right
            debugMsg(sProcName, "nKeyDown=#PB_Shortcut_Right")
            nDevSel = GGS(WQF\cboDevSel) + 1
            nMaxDevSel = CountGadgetItems(WQF\cboDevSel) - 1
            If nDevSel <= nMaxDevSel
              debugMsg(sProcName, "setting WQF\cboDevSel=" + nDevSel)
              SGS(WQF\cboDevSel, nDevSel)
              WQF_cboDevSel_Click()
            EndIf
            
          Case #PB_Shortcut_Up
            debugMsg(sProcName, "nKeyDown=#PB_Shortcut_Up")
            nDevNo = rWQF\nCurrDevNo - 1
            If nDevNo >= 0
              If aAud(nEditAudPtr)\sLogicalDev[nDevNo]
                debugMsg(sProcName, "calling WQF_setCurrentDevInfo(" + nDevNo + ", #True, #True)")
                WQF_setCurrentDevInfo(nDevNo, #True, #True)
              EndIf
            EndIf
            
          Case #PB_Shortcut_Down
            debugMsg(sProcName, "nKeyDown=#PB_Shortcut_Down")
            nDevNo = rWQF\nCurrDevNo + 1
            If nDevNo <= #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
              If aAud(nEditAudPtr)\sLogicalDev[nDevNo]
                debugMsg(sProcName, "calling WQF_setCurrentDevInfo(" + nDevNo + ", #True, #True)")
                WQF_setCurrentDevInfo(nDevNo, #True, #True)
              EndIf
            EndIf
            
        EndSelect
        ;}
      Case #PB_EventType_MouseWheel ; INFO: cvsGraph #PB_EventType_MouseWheel
        ;{
        nWheelDelta = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_WheelDelta)
        ; debugMsg(sProcName, "#PB_EventType_MouseWheel: nWheelDelta=" + nWheelDelta)
        If ShiftKeyDown()
          nSizeIncrement = 1
        Else
          nSizeIncrement = 10
        EndIf
        If nSizeIncrement = 0
          nSizeIncrement = 1
        EndIf
        nWheelDelta * nSizeIncrement
        If nWheelDelta <> 0
          nZoomValue = GGS(WQF\trbZoom) + nWheelDelta
          If nZoomValue < GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Minimum)
            nZoomValue = GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Minimum)
          ElseIf nZoomValue > GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Maximum)
            nZoomValue = GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Maximum)
          EndIf
          If nZoomValue <> GGS(WQF\trbZoom)
            SGS(WQF\trbZoom, nZoomValue)
            debugMsg(sProcName, "nWheelDelta=" + nWheelDelta + ", nZoomValue=" + nZoomValue + ", GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom) + ", calling WQF_processZoom()")
            WQF_processZoom()
          EndIf
        EndIf
        ;}
      Case #PB_EventType_LeftDoubleClick ; INFO: cvsGraph #PB_EventType_LeftDoubleClick
        ; Added 7Feb2022 11.9.0 following request from CPeters 4Feb2022
        debugMsg(sProcName, "#PB_EventType_LeftDoubleClick start")
        If ShiftKeyDown()
          If grLicInfo\bStdLvlPtsAvailable
            nPointTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
            If WQF_setStdEnabled(nPointTime)
              WQF_mnuAddLevelPoint(#SCS_PT_STD)
            EndIf
          EndIf
        EndIf
        ; End added 7Feb2022 11.9.0
    EndSelect
    
    If bRefreshCuePanel
      debugMsg(sProcName, "bRefreshCuePanel=" + strB(bRefreshCuePanel))
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQF_EventHandler()
  PROCNAMEC()
  Protected n, bFound, fBVLevel.f
  
  With WQF
    
    ; nb MUST check menu events first so that #SCS_WMNF_IncPlayingCues and #SCS_WMNF_DecPlayingCues can be processed even if gnEventSliderNo > 0
    ; see also WED_EventHandler() in fmEditor.pbi, which is where the menu events are originally caught
    Select gnWindowEvent
      Case #PB_Event_Menu ; #PB_Event_Menu
        ; debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
          Case #WQF_mnu_AddFadeInLvlPt
            WQF_mnuAddLevelPoint(#SCS_PT_FADE_IN)
            
          Case #WQF_mnu_AddFadeOutLvlPt
            WQF_mnuAddLevelPoint(#SCS_PT_FADE_OUT)
            
          Case #WQF_mnu_AddStdLvlPt
            WQF_mnuAddLevelPoint(#SCS_PT_STD)
            
          Case #WQF_mnu_ChangeFreqTempoPitch
            ; the following tests before calling WQF_mnuChangeFreqTempoPitch() are necessary because this menu event can be called by a keyboard shortcut, regardless of the currently-displayed subtype
            If grLicInfo\bTempoAndPitchAvailable
              If aSub(nEditSubPtr)\bSubTypeF And aSub(nEditSubPtr)\bSubPlaceHolder = #False And aSub(nEditSubPtr)\nFirstAudIndex >= 0
                WQF_mnuChangeFreqTempoPitch()
              EndIf
            EndIf
            
          Case #WQF_mnu_ClearAll
            WQF_mnuClearAll()
            
          Case #WQF_mnu_EndTrimSilence, #WQF_mnu_EndTrim75, #WQF_mnu_EndTrim60, #WQF_mnu_EndTrim45, #WQF_mnu_EndTrim30 ; Changed 3Oct2022 11.9.6
            WQF_mnuEndTrim(gnEventMenu)
            
          Case #WQF_mnu_ExternalAudioEditor
            WEC_editFileExternal_Click()
            
          Case #WQF_mnu_CallLinkDevs, #SCS_WEDF_CallLinkDevs
            WQF_mnuLinkDevices()
            
          Case #WQF_mnu_RenameFile
            WQF_mnuRenameFile()
            
          Case #WQF_mnu_RemoveLvlPt
            WQF_mnuRemoveLevelPoint()
            
          Case #WQF_mnu_ResetAll
            WQF_mnuResetAll()
            
          Case #WQF_mnu_SameAsNext
            WQF_mnuSameAs(#True, -1)
            
          Case #WQF_mnu_SameAsPrev
            WQF_mnuSameAs(#False, -1)
            
          Case #WQF_mnu_SameLvlAsNext
            WQF_mnuSameAs(#True, #SCS_GRAPH_MARKER_LEVEL)
            
          Case #WQF_mnu_SameLvlAsPrev
            WQF_mnuSameAs(#False, #SCS_GRAPH_MARKER_LEVEL)
            
          Case #WQF_mnu_SamePanAsNext
            WQF_mnuSameAs(#True, #SCS_GRAPH_MARKER_PAN)
            
          Case #WQF_mnu_SamePanAsPrev
            WQF_mnuSameAs(#False, #SCS_GRAPH_MARKER_PAN)
            
          Case #WQF_mnu_SetEndAt
            WQF_mnuSetEndAt()
            
          Case #WQF_mnu_SetLoopEnd
            WQF_mnuSetLoopEnd()
            
          Case #WQF_mnu_SetLoopStart
            WQF_mnuSetLoopStart()
            
          Case #WQF_mnu_SetPos
            WQF_mnuSetPos()
            
          Case #WQF_mnu_SetStartAt
            WQF_mnuSetStartAt()
            
          Case #WQF_mnu_ShowLvlCurvesOther
            WQF_mnuShowLvlCurvesOther()
            
          Case #WQF_mnu_ShowLvlCurvesSel
            WQF_mnuShowLvlCurvesSel()
            
          Case #WQF_mnu_ShowPanCurvesOther
            WQF_mnuShowPanCurvesOther()
            
          Case #WQF_mnu_ShowPanCurvesSel
            WQF_mnuShowPanCurvesSel()
            
          Case #WQF_mnu_StartTrimSilence, #WQF_mnu_StartTrim75, #WQF_mnu_StartTrim60, #WQF_mnu_StartTrim45, #WQF_mnu_StartTrim30 ; Changed 3Oct2022 11.9.6
            WQF_mnuStartTrim(gnEventMenu)
            
          Case #SCS_WEDF_IncLevels
            ; 18/09/2014 11.3.4 added, using same shortcue as 'increment levels of all playing cues', for incrementing all levels for this level change sub-cue
            WQF_adjustAllLevels(1)
            
          Case #SCS_WEDF_DecLevels
            ; 18/09/2014 11.3.4 added, using same shortcue as 'decrement levels of all playing cues', for decrementing all levels for this level change sub-cue
            WQF_adjustAllLevels(-1)
            
          Case #SCS_WEDF_SkipBack
            WQF_skipBackOrForward(-2000) ; skip back 2 seconds
            
          Case #SCS_WEDF_SkipForward
            WQF_skipBackOrForward(2000) ; skip forward 2 seconds
            
          Case #SCS_WEDF_Rewind
            If getVisible(\btnEditRewind) And getEnabled(\btnEditRewind)
              WQF_btnEditRewind_Click()
            EndIf
            
          Case #SCS_WEDF_PlayPause
            If getVisible(\btnEditPlay) And getEnabled(\btnEditPlay)
              WQF_btnEditPlay_Click()
            ElseIf getVisible(\btnEditPause) And getEnabled(\btnEditPause)
              WQF_btnEditPause_Click()
            EndIf
            
          Case #SCS_WEDF_Stop
            If getVisible(\btnEditStop) And getEnabled(\btnEditStop)
              WQF_btnEditStop_Click()
            EndIf
            
          Case #WQF_mnu_EditCueMarker
            editCueMarker(@grMG2)
          Case #WQF_mnu_RemoveCueMarker
            removeCueMarker(@grMG2)
          Case #WQF_mnu_SetCueMarkerPos
            WQF_mnuSetCueMarkerPosition()
          Case #WQF_mnu_ViewOnCues
            WQF_mnuViewOnCues()
          Case #WQF_mnu_ViewCueMarkersUsage
            WQF_mnuViewCueMarkersUsage()
          Case #WQF_mnu_AddQuickCueMarkers
            WQF_mnuAddQuickCueMarkers()
          Case #WQF_mnu_RemoveAllUnusedCueMarkersFromThisFile
            removeAllUnusedCueMarkersFromThisFile(nEditAudPtr)
          Case #WQF_mnu_RemoveAllUnusedCueMarkers
            removeAllUnusedCueMarkers()
          Case #SCS_WEDF_AddCueMarker
            addCueMarker()
          Case #SCS_WEDF_CueMarkerNext, #SCS_WEDF_CueMarkerPrev
            skipCueMarker(gnEventMenu)
            
        EndSelect
        
    EndSelect
    
    If gnEventSliderNo > 0
      If nEditAudPtr < 0
        debugMsg(sProcName, "gnEventSliderNo=" + gnEventSliderNo + ", exiting because nEditAudPtr=" + nEditAudPtr)
        ProcedureReturn
      ElseIf aAud(nEditAudPtr)\bAudTypeF = #False
        debugMsg(sProcName, "gnEventSliderNo=" + gnEventSliderNo + ", exiting because aAud(" + getAudLabel(nEditAudPtr) + ")\bAudTypeF=" + strB(aAud(nEditAudPtr)\bAudTypeF))
        ProcedureReturn
      EndIf
      
      If gnEventSliderNo = \sldProgress
        bFound = #True
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            WQF_sldProgress_Common(gnSliderEvent)
        EndSelect
        
      ElseIf gnEventSliderNo = \sldPosition
        bFound = #True
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            WQF_sldPosition_Event(gnSliderEvent)
        EndSelect
        
      Else
        For n = 0 To grLicInfo\nMaxAudDevPerAud
          If gnEventSliderNo = \sldLevel[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN
                WQF_setCurrentDevInfo(n, #True)
              Case #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                fBVLevel = SLD_getLevel(gnEventSliderNo)
                If grLicInfo\bDevLinkAvailable And fBVLevel <> aAud(nEditAudPtr)\fBVLevel[n] And aAud(nEditAudPtr)\bDeviceSelected[n] = #False
                  WQF_fcSldLevel(n)
                  aAud(nEditAudPtr)\fDeviceTotalVolWork[n] = aAud(nEditAudPtr)\fCueTotalVolNow[n]
; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fDeviceTotalVolWork[" + n + "]=" + traceLevel(aAud(nEditAudPtr)\fDeviceTotalVolWork[n]))
                ElseIf grLicInfo\bDevLinkAvailable And aAud(nEditAudPtr)\bDeviceSelected[n]
                  fBVLevel = SLD_getLevel(gnEventSliderNo)
                  ; debugMsg(sProcName, "calling WQF_adjustSelectedDevicesLevels(" + n + ", " + convertBVLevelToDBString(fBVLevel) + ")")
                  WQF_adjustSelectedDevicesLevels(n, fBVLevel)
                Else
                  WQF_fcSldLevel(n)
                EndIf
            EndSelect
            Break
            
          ElseIf gnEventSliderNo = \sldPan[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN
                WQF_setCurrentDevInfo(n, #True)
              Case #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQF_fcSldPan(n)
            EndSelect
            Break
          EndIf
        Next n
        
      EndIf
      
      If bFound
        ProcedureReturn
      EndIf
      
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget ; #PB_Event_Gadget
        
        If nEditAudPtr < 0
          debugMsg(sProcName, "exiting because nEditAudPtr=" + nEditAudPtr)
          debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + ", gnEventGadgetNoForEvHdlr=G" + gnEventGadgetNoForEvHdlr + "), gnEventType=" + decodeEventType())
          ProcedureReturn
        ElseIf aAud(nEditAudPtr)\bAudTypeF = #False
          debugMsg(sProcName, "exiting because aAud(" + getAudLabel(nEditAudPtr) + ")\bAudTypeF=" + strB(aAud(nEditAudPtr)\bAudTypeF))
          ProcedureReturn
        EndIf
        
        If gnEventButtonId <> 0
          
          Select gnEventButtonId
              
            Case #SCS_STANDARD_BTN_FADEOUT
              WQF_btnEditFadeOut_Click()
              
            Case #SCS_STANDARD_BTN_PAUSE
              WQF_btnEditPause_Click()
              
            Case #SCS_STANDARD_BTN_PLAY
              WQF_btnEditPlay_Click()
              
            Case #SCS_STANDARD_BTN_STOP
              WQF_btnEditStop_Click()
              
            Case #SCS_STANDARD_BTN_RELEASE
              WQF_btnEditRelease_Click()
              
            Case #SCS_STANDARD_BTN_REWIND
              WQF_btnEditRewind_Click()
              
            Case #SCS_STANDARD_BTN_MOVE_DOWN
              WQF_btnMoveDev_Click(#False)
              
            Case #SCS_STANDARD_BTN_MOVE_UP
              WQF_btnMoveDev_Click(#True)
              
            Case #SCS_STANDARD_BTN_PLUS
              If gnEventGadgetNo = WQF\btnLoopAdd
                WQF_btnLoopAdd_Click()
              ElseIf gnEventGadgetNo = WQF\btnInsertDev
                BTNCLICK(WQF_btnInsertDev_Click())
              EndIf
              
            Case #SCS_STANDARD_BTN_MINUS
              If gnEventGadgetNo = WQF\btnLoopDel
                WQF_btnLoopDel_Click()
              ElseIf gnEventGadgetNo = WQF\btnRemoveDev
                BTNCLICK(WQF_btnRemoveDev_Click())
              EndIf
              
            Default
              debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId)
              
          EndSelect
          
        Else
          
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQF)
              
              ; detail gadgets in alphabetical order
              
            Case \btnBrowse       ; btnBrowse
              BTNCLICK(WQF_btnBrowse_Click())
              
            Case \btnCenter[0]    ; btnCenter
              BTNCLICK(WQF_btnCenter_Click(gnEventGadgetArrayIndex))
              
            Case \btnEndAt, \btnFadeInTime, \btnFadeOutTime, \btnLoopEnd, \btnLoopStart, \btnStartAt
              BTNCLICK(WQF_WEM_Button_Click(gnEventGadgetNoForEvHdlr))
              
            Case \btnLoopNrLeft
              BTNCLICK(WQF_btnLoopNrLeft_Click())
              
            Case \btnLoopNrRight
              BTNCLICK(WQF_btnLoopNrRight_Click())
              
            Case \btnMoveDevDown, \btnMoveDevUp
              BTNCLICK(WQF_btnMoveDev_Click(gnEventGadgetNoForEvHdlr))
              
            Case \btnOther       ; btnOther
              BTNCLICK(WQF_btnOther_Click())
              
;             Case \btnRename     ; btnRename
;               If nEditAudPtr >= 0
;                 If valCue(#False)
;                   BTNCLICK(WFR_renameAudFile(aAud(nEditAudPtr)\sFileName, "F"))
;                   ; no further action allowed here as WFR_renameAudFile() opens a modal window
;                 EndIf
;               EndIf
              
            Case \btnViewAll       ; btnViewAll
              BTNCLICK(WQF_btnViewAll_Click())
              
            Case \btnViewPlayable       ; btnViewPlayable
              BTNCLICK(WQF_btnViewPlayable_Click())
              
            Case \cboDevSel   ; cboDevSel
              CBOCHG(WQF_cboDevSel_Click())
              
            Case \cboGraphDisplayMode   ; cboGraphDisplayMode
              CBOCHG(WQF_cboGraphDisplayMode_Click())
              
            Case \cboLevelSel   ; cboLevelSel
              CBOCHG(WQF_cboLevelSel_Click())
              
            Case \cboLogicalDevF[0]  ; cboLogicalDevF
              CBOCHG(WQF_cboLogicalDevF_Click(gnEventGadgetArrayIndex))
              
            Case \cboPanSel   ; cboPanSel
              CBOCHG(WQF_cboPanSel_Click())
              
            Case \cboTracks[0]  ; cboTracks
              CBOCHG(WQF_cboTracks_Click(gnEventGadgetArrayIndex))
              
            Case \cboTrim[0]  ; cboTrim
              CBOCHG(WQF_cboTrim_Click(gnEventGadgetArrayIndex))
              
            Case \cboVSTPlugin ; cboVSTPlugin
              CBOCHG(WQF_cboVSTPlugin_Click())
              
            Case \chkAutoScroll   ; chkAutoScroll
              CHKOWNCHG(WQF_chkAutoScroll_Click())
              
            Case \chkBypassVST
              CHKOWNCHG(WQF_chkBypassVST_Click())
              
            Case \chkDevInclude[0]  ; chkDevInclude
              CHKOWNCHG(WQF_chkDevInclude_Click(gnEventGadgetArrayIndex))
              
            Case \chkLoop   ; chkLoop
              CHKOWNCHG(WQF_chkLoop_Click())
              
            Case \chkLoopLinked   ; chkLoopLinked    ; added 2Nov2015 11.4.1.2g
              CHKOWNCHG(WQF_chkLoopLinked_Click())
              
            Case \chkViewVST
              CHKOWNCHG(WQF_chkViewVST_Click()) 
              
            Case \cntAudioControls
              ; ignore events
              
            Case \cntSubDetailF
              ; ignore events
              
            Case \cvsGraph
              WQF_cvsGraph_Event()
              
            Case \cvsSideLabels
              WQF_cvsSideLabels_Event()
              
            Case \lblDevNo[0]
              If gnEventType = #PB_EventType_Focus
                WQF_lblDevNo_Click(gnEventGadgetArrayIndex)
              EndIf
              
            Case \scaDevs
              ; ignore events
              
            Case \scaSoundFile
              ; ignore events
              
            Case \trbZoom
              debugMsg(sProcName, "\trbZoom: calling WQF_trbZoom_Change()")
              WQF_trbZoom_Change()
              
            Case \txtCuePosTimeOffset
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtCuePosTimeOffset_Validate())
              EndSelect
              
            Case \txtCurrPos
              Select gnEventType
                Case #PB_EventType_Change
                  rWQF\bChangingCurrPos = #True
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtCurrPos_Validate())
                  rWQF\bChangingCurrPos = #False
              EndSelect
              
            Case \txtDBLevel[0]
              Select gnEventType
                Case #PB_EventType_Focus
                  WQF_setCurrentDevInfo(gnEventGadgetArrayIndex, #True, #True)
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtDBLevel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtDevDBLevel[0]
              ; ignore - display-only
              
            Case \txtEndAt
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtEndAt_Validate())
              EndSelect
              bumpKeyHandler()
              
            Case \txtFadeInTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtFadeInTime_Validate())
              EndSelect
              bumpKeyHandler()
              
            Case \txtFadeOutTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtFadeOutTime_Validate())
              EndSelect
              bumpKeyHandler()
              
            Case \txtLoopEnd  ; txtLoopEnd
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtLoopEnd_Validate())
              EndSelect
              bumpKeyHandler()
              
            Case \txtLoopStart  ; txtLoopStart
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtLoopStart_Validate())
              EndSelect
              bumpKeyHandler()
              
            Case \txtLoopXFadeTime  ; txtLoopXFadeTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtLoopXFadeTime_Validate())
              EndSelect
              bumpKeyHandler()
              
            Case \txtNumLoops  ; txtNumLoops
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtNumLoops_Validate())
              EndSelect
              
            Case \txtPan[0]  ; txtPan
              Select gnEventType
                Case #PB_EventType_Focus
                  WQF_setCurrentDevInfo(gnEventGadgetArrayIndex, #True, #True)
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtPan_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtPlayDBLevel[0]
              ; ignore - display-only
              
            Case \txtRelDBLevel[0]  ; txtRelDBLevel
              Select gnEventType
                Case #PB_EventType_Focus
                  WQF_setCurrentDevInfo(gnEventGadgetArrayIndex, #True, #True)
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtRelDBLevel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtStartAt  ; txtStartAt
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQF_txtStartAt_Validate())
              EndSelect
              bumpKeyHandler()
              
            Default
              If gnEventType <> #PB_EventType_Resize
                debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
              EndIf
          EndSelect
          
        EndIf
        
      Case #PB_Event_GadgetDrop ; #PB_Event_GadgetDrop
        Select gnEventGadgetNoForEvHdlr
            
          Case WQF\txtFileName
            WQF_txtFileName_DropFiles()
            
          Default
            debugMsg(sProcName, "#PB_Event_GadgetDrop gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
            
        EndSelect
        
      Default
        debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQF_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  ; debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQF
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQF)
        
        ; detail gadgets
      Case \txtDBLevel[0]
        ETVAL2(WQF_txtDBLevel_Validate(nArrayIndex))
        
      Case \txtCuePosTimeOffset
        ETVAL2(WQF_txtCuePosTimeOffset_Validate())
        
      Case \txtCurrPos
        ETVAL2(WQF_txtCurrPos_Validate())
        
      Case \txtEndAt
        ETVAL2(WQF_txtEndAt_Validate())
        
      Case \txtFadeInTime
        ETVAL2(WQF_txtFadeInTime_Validate())
        
      Case \txtFadeOutTime
        ETVAL2(WQF_txtFadeOutTime_Validate())
        
      Case \txtFileName
        ETVAL2(WQF_txtFileName_Validate())
        
      Case \txtLoopEnd
        ETVAL2(WQF_txtLoopEnd_Validate())
        
      Case \txtLoopStart
        ETVAL2(WQF_txtLoopStart_Validate())
        
      Case \txtLoopXFadeTime
        ETVAL2(WQF_txtLoopXFadeTime_Validate())
        
      Case \txtNumLoops
        ETVAL2(WQF_txtNumLoops_Validate())
        
      Case \txtPan[0]
        ETVAL2(WQF_txtPan_Validate(nArrayIndex))
        
      Case \txtStartAt
        ETVAL2(WQF_txtStartAt_Validate())
        
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

Procedure WQF_initGraphInfo()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  newGraph(@grMG2, nEditAudPtr)
  
  If GGS(WQF\trbZoom) <> 1
    rWQF\nLastTrbZoomValue = 1  ; prevent WQF_trbZoom_Change() re-drawing the graph
    debugMsg(sProcName, "calling SGS(WQF\trbZoom, 1)")
    SGS(WQF\trbZoom, 1)
    debugMsg(sProcName, "calling WQF_trbZoom_Change()")
    WQF_trbZoom_Change()
  EndIf
  
  ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldPosition, 0)")
  SLD_setValue(WQF\sldPosition, 0)
  WQF_sldPosition_Change()
  
  resizeInnerAreaOfGraph(@grMG2)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_fcSldPanForLevelPoint(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u, n
  Protected nLevelPointIndex, nItemIndex
  Protected fItemPan.f
  Protected nLvlPtPanSel
  Static sPan.s
  Static bStaticLoaded
  
  If (gbInDisplaySub = #False) And (rWQF\bInLogicalDevClick = #False)
    
    If bStaticLoaded = #False
      sPan = Lang("WQF", "Pan")
      bStaticLoaded = #True
    EndIf
    
    WQF_setCurrentDevInfo(Index, #True, #True)
    
    With aAud(nEditAudPtr)
      nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
      nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, \sLogicalDev[Index], \sTracks[Index])
    EndWith
    
    If (nLevelPointIndex >= 0) And (nItemIndex >= 0)
      With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)
        u = preChangeAudF(\aItem(nItemIndex)\fItemPan, sPan, -5, #SCS_UNDO_ACTION_CHANGE, Index)
        fItemPan = panSliderValToSingle(SLD_getValue(WQF\sldPan[Index]))
        \aItem(nItemIndex)\fItemPan = fItemPan
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" + formatPan(fItemPan))
        SLD_setValue(WQF\sldPan[Index], panToSliderValue(fItemPan))
        debugMsg(sProcName, "SLD_getValue(WQF\sldPan[" + Index + "])=" + WQF\sldPan[Index])
        SetGadgetText(WQF\txtPan[Index], panSingleToString(fItemPan))
        debugMsg(sProcName, "WQF\txtPan[" + Index + "]=" + GGT(WQF\txtPan[Index]))
        debugMsg(sProcName, "calling WQF_setLevelAndPanEnabledStates(" + Index + ")")
        WQF_setLevelAndPanEnabledStates(Index)
        nLvlPtPanSel = aAud(nEditAudPtr)\nLvlPtPanSel
        Select nLvlPtPanSel
          Case #SCS_PANSEL_SYNC
            For n = 0 To \nPointMaxItem
              If n <> nItemIndex
                If \aItem(n)\fItemPan <> fItemPan
                  If getPanAvailableForLogicalDev(\aItem(n)\sItemLogicalDev)
                    \aItem(n)\fItemPan = fItemPan
                    debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + n + ")\fItemPan=" + formatPan(fItemPan))
                    SLD_setValue(WQF\sldPan[n], panToSliderValue(fItemPan))
                    debugMsg(sProcName, "SLD_getValue(WQF\sldPan[" + n + "])=" + WQF\sldPan[n])
                    SetGadgetText(WQF\txtPan[n], panSingleToString(fItemPan))
                    debugMsg(sProcName, "WQF\txtPan[" + n + "]=" + GGT(WQF\txtPan[n]))
                    debugMsg(sProcName, "calling WQF_setLevelAndPanEnabledStates(" + n + ")")
                    WQF_setLevelAndPanEnabledStates(n)
                  EndIf
                EndIf
              EndIf
            Next n
        EndSelect
        debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
        postChangeAudFN(u, \aItem(nItemIndex)\fItemPan, -5, Index)
      EndWith
    EndIf
    
  EndIf
  
EndProcedure

Procedure WQF_fcSldLevel(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u, nSliderValue
  
  ; audio device Level
  With aAud(nEditAudPtr)
    
    u = preChangeAudS(\sDBLevel[Index], rWQF\sUndoDescKeyPart + GetGadgetText(WQF\lblDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    
    If (gbInDisplaySub = #False) And (rWQF\bInLogicalDevClick = #False)
      \fBVLevel[Index] = SLD_getLevel(WQF\sldLevel[Index])
      ; Changed 3May2024 11.10.2ck
      If \fBVLevel[Index] <= grLevels\fMinBVLevel
        \fBVLevel[Index] = grLevels\fMinBVLevel
        \sDBLevel[Index] = grLevels\sMinDBLevel
      Else
        \sDBLevel[Index] = convertBVLevelToDBString(\fBVLevel[Index])
      EndIf
      ; debugMsg0(sProcName, "\fBVLevel[" + Index + "]=" + traceLevel(\fBVLevel[Index]))
      ; End changed 3May2024 11.10.2ck
      \fSavedBVLevel[Index] = \fBVLevel[Index]
      \fAudPlayBVLevel[Index] = \fBVLevel[Index]
      \fCueVolNow[Index] = \fBVLevel[Index]
      \fCueAltVolNow[Index] = #SCS_MINVOLUME_SINGLE
      \fCueTotalVolNow[Index] = \fBVLevel[Index]
      CompilerIf #cTraceCueTotalVolNow
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fCueTotalVolNow[" + Index + "]=" + traceLevel(aAud(nEditAudPtr)\fCueTotalVolNow[Index]))
      CompilerEndIf
      
      If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
        If \bIgnoreDev[Index]
          debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
          setIgnoreDevInds(nEditAudPtr, #True)
          If \bIgnoreDev[Index] = #False
            ; this device was ignored but now is not, so close and reopen Aud
            debugMsg(sProcName, "calling closeAud(" + getAudLabel(nEditAudPtr) + ")")
            closeAud(nEditAudPtr)
            debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
            setIgnoreDevInds(nEditAudPtr, #True)
            debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ")")
            openMediaFile(nEditAudPtr)
          EndIf
        EndIf
      EndIf
      
      ; debugMsg(sProcName, "calling recalcLvlPtLevels(" + getAudLabel(nEditAudPtr) + ")")
      recalcLvlPtLevels(nEditAudPtr)
      \bLvlPtRunForceSettings = #True
      ; debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(nEditAudPtr) + ", " + \nCuePos + ")")
      doLvlPtRun(nEditAudPtr, \nCuePos)
      rWQF\bCallSetOrigDBLevels = #True
      
    EndIf
    
    SGT(WQF\txtDBLevel[Index], convertBVLevelToDBStringWithMinusInf(\fBVLevel[Index])) ; Changed 3May2024 11.10.2ck
    
    ; debugMsg(sProcName, "calling drawWholeGraphArea()")
    drawWholeGraphArea()
    
    postChangeAudSN(u, \sDBLevel[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQF_fcSldPan(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Static sPan.s
  Static bStaticLoaded
  
  If rWQF\bDisplayingLevelPoint
    ; level point pan
    WQF_fcSldPanForLevelPoint(Index)
    ProcedureReturn
  EndIf
  
  ; audio device pan
  With aAud(nEditAudPtr)
    
    If bStaticLoaded = #False
      sPan = Lang("WQF", "Pan")
      bStaticLoaded = #True
    EndIf
    
    u = preChangeAudF(\fPan[Index], rWQF\sUndoDescKeyPart + sPan, -5, #SCS_UNDO_ACTION_CHANGE, Index)
    
    If (gbInDisplaySub = #False) And (rWQF\bInLogicalDevClick = #False)
      \fPan[Index] = panSliderValToSingle(SLD_getValue(WQF\sldPan[Index]))
      \fSavedPan[Index] = \fPan[Index]
      \fCuePanNow[Index] = \fPan[Index]
      
      If \nFileState = #SCS_FILESTATE_OPEN
        If gbUseBASS
          setLevelsAny(nEditAudPtr, Index, #SCS_NOVOLCHANGE_SINGLE, \fPan[Index])
        Else ; SM-S
          samAddRequest(#SCS_SAM_SET_AUD_DEV_PAN, nEditAudPtr, \fPan[Index], Index)
        EndIf
      EndIf
    EndIf
    
    If \fPan[Index] = #SCS_PANCENTRE_SINGLE
      setEnabled(WQF\btnCenter[Index], #False)
    Else
      setEnabled(WQF\btnCenter[Index], #True)
    EndIf
    SetGadgetText(WQF\txtPan[Index], panSingleToString(\fPan[Index]))
    ; debugMsg(sProcName, "WQF\txtPan[" + Index + "]=" + GGT(WQF\txtPan[Index]))
    
    If (gbInDisplaySub = #False) And (rWQF\bInLogicalDevClick = #False)
      ; debugMsg(sProcName, "calling setDerivedLevelPointInfo2(" + getAudLabel(nEditAudPtr) + ")")
      setDerivedLevelPointInfo2(nEditAudPtr) ; will set Level Point pans to changed Audio Dev pan where reqd
      ; debugMsg(sProcName, "calling recalcLvlPtPans(" + getAudLabel(nEditAudPtr) + ")")
      recalcLvlPtPans(nEditAudPtr)
      ; debugMsg(sProcName, "calling drawWholeGraphArea()")
      drawWholeGraphArea()
    EndIf
    
    postChangeAudFN(u, \fPan[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQF_fcFileExt(bForce)
  PROCNAMECA(nEditAudPtr)
  Protected d, n
  Protected bAvailable, nListIndex
  Protected nSldLevel
  
  ; debugMsg0(sProcName, #SCS_START)
  
  If nEditAudPtr <= 0
    ProcedureReturn
  EndIf
  
  ;   debugMsg(sProcName, "bForce=" + strB(bForce) + ", \sFileExt=" + aAud(nEditAudPtr)\sFileExt + ", \sFileName=" + aAud(nEditAudPtr)\sFileName)
  
  If bForce = #False
    If LCase(GetExtensionPart(aAud(nEditAudPtr)\sFileName)) = LCase(aAud(nEditAudPtr)\sFileExt)
      ; no change to file ext so exit now
      ProcedureReturn
    EndIf
  EndIf
  
  With aAud(nEditAudPtr)
    \sFileExt = GetExtensionPart(\sFileName)
    \nFileFormat = getFileFormat(\sFileName)
    bAvailable = #True
    
    If gbInPaste = #False
      SLD_setEnabled(WQF\sldProgress, #True)
      WQF_populateCboLogicalDevs()
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        ; debugMsg(sProcName, "\sLogicalDev[" + Str(d) + "]=" + \sLogicalDev[d])
        If \sLogicalDev[d]
          SetGadgetState(WQF\cboLogicalDevF[d], indexForComboBoxRow(WQF\cboLogicalDevF[d], \sLogicalDev[d]))
        Else
          SetGadgetState(WQF\cboLogicalDevF[d], -1)
        EndIf
        If bForce
          ; SLD_setBaseVal(WQF\sldLevel[d], -1)
          ; SLD_setBaseVal(WQF\sldPan[d], -1)
          SLD_setBaseLevel(WQF\sldLevel[d], #SCS_SLD_NO_BASE, 1)
          SLD_setBaseValue(WQF\sldPan[d], #SCS_SLD_NO_BASE)
          If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
            SLD_setLevel(WQF\sldLevel[d], \fBVLevel[d], \fTrimFactor[d])
            SLD_setValue(WQF\sldPan[d], panToSliderValue(\fPan[d]))
          ElseIf aSub(\nSubIndex)\bStartedInEditor
            SLD_setLevel(WQF\sldLevel[d], \fCueVolNow[d], \fTrimFactor[d])
            SLD_setValue(WQF\sldPan[d], panToSliderValue(\fCuePanNow[d]))
          EndIf
        EndIf
        If aSub(\nSubIndex)\bStartedInEditor
          WQF_fcLogicalDev(d)
          WQF_fcSldLevel(d)
          WQF_fcSldPan(d)
        EndIf
      Next d
    EndIf
    
    If gbInPaste = #False
      WQF_setTimeFieldEnabledStates()
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQF_setLevelAndPanEnabledStates(Index)
  PROCNAMECA(nEditAudPtr)
  Protected sLogicalDev.s, sTracks.s
  Protected nNrOfOutputChans
  Protected nLevelPointIndex, nItemIndex
  Protected bEnableLevel, bEnablePan, bEnableCenter
  Protected bDevExists
  Protected n
  Protected bPanVisible
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \bDisplayPan[Index]
        bPanVisible = #True
      EndIf
      sLogicalDev = \sLogicalDev[Index]
      sTracks = \sTracks[Index]
      nNrOfOutputChans = getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, sLogicalDev)
      
      If rWQF\bDisplayingLevelPoint
        ; displaying level point relative levels and pans
        nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
        If (sLogicalDev) And (nLevelPointIndex >= 0)
          bDevExists = #True
          If (\bIgnoreDev[Index]) And (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            ; bEnableLevel = #False
            ; bEnablePan = #False
          Else
            nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
            If nItemIndex >= 0
              If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                bEnableLevel = #True
                If (\aPoint(nLevelPointIndex)\nPointType = #SCS_PT_START) And (\nFadeInTime > 0)
                  bEnableLevel = #False
                ElseIf (\aPoint(nLevelPointIndex)\nPointType = #SCS_PT_END) And (\nFadeOutTime > 0)
                  bEnableLevel = #False
                EndIf
                If (nNrOfOutputChans = 2) And (\nLvlPtPanSel <> #SCS_PANSEL_USEAUDDEV)
                  bEnablePan = #True
                  If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan <> #SCS_PANCENTRE_SINGLE
                    bEnableCenter = #True
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        If bDevExists = #False
          setOwnEnabled(WQF\chkDevInclude[Index], #False)
        EndIf
        setEnabled(WQF\txtRelDBLevel[Index], bEnableLevel)
        If bPanVisible
          SLD_setEnabled(WQF\sldPan[Index], bEnablePan)
          setEnabled(WQF\btnCenter[Index], bEnableCenter)
          setEnabled(WQF\txtPan[Index], bEnablePan)
          setTextBoxBackColor(WQF\txtPan[Index])
        EndIf
        SLD_setVisible(WQF\sldPan[Index], bPanVisible)
        setVisible(WQF\btnCenter[Index], bPanVisible)
        setVisible(WQF\txtPan[Index], bPanVisible)
        
      Else
        ; displaying audio device levels and pans
        If sLogicalDev
          If (\bIgnoreDev[Index]) And (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            ; bEnableLevel = #False
            ; bEnablePan = #False
          Else
            bEnableLevel = #True
            If nNrOfOutputChans = 2
              bEnablePan = #True
            EndIf
          EndIf
        EndIf
        If bEnablePan
          If \fPan[Index] <> #SCS_PANCENTRE_SINGLE
            bEnableCenter = #True
          EndIf
        EndIf
        setEnabled(WQF\cboTrim[Index], bEnableLevel)
        SLD_setEnabled(WQF\sldLevel[Index], bEnableLevel)
        setEnabled(WQF\txtDBLevel[Index], bEnableLevel)
        setTextBoxBackColor(WQF\txtDBLevel[Index])
        setEnabled(WQF\txtRelDBLevel[Index], bEnableLevel)
        If bPanVisible
          SLD_setEnabled(WQF\sldPan[Index], bEnablePan)
          setEnabled(WQF\btnCenter[Index], bEnableCenter)
          setEnabled(WQF\txtPan[Index], bEnablePan)
          setTextBoxBackColor(WQF\txtPan[Index])
        EndIf
        SLD_setVisible(WQF\sldPan[Index], bPanVisible)
        setVisible(WQF\btnCenter[Index], bPanVisible)
        setVisible(WQF\txtPan[Index], bPanVisible)
        
      EndIf
      
    EndWith
  EndIf
  
  ; ebugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_fcLogicalDev(Index)
  PROCNAMECA(nEditAudPtr)
  
  ; debugMsg(sProcName, "calling WQF_setLevelAndPanEnabledStates(" + Index + ")")
  WQF_setLevelAndPanEnabledStates(Index)
  
EndProcedure

Procedure WQF_fcTxtDBLevel(Index, sThisDBLevel.s)
  PROCNAMEC()
  Protected u
  
  With aAud(nEditAudPtr)
    
    u = preChangeAudS(\sDBLevel[Index], rWQF\sUndoDescKeyPart + GetGadgetText(WQF\lblDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \sDBLevel[Index] = sThisDBLevel
    \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
    debugMsg(sProcName, "\fBVLevel[" + Index + "]=" + traceLevel(\fBVLevel[Index]))
    \fSavedBVLevel[Index] = \fBVLevel[Index]
    \fAudPlayBVLevel[Index] = \fBVLevel[Index]
    
    \fCueVolNow[Index] = \fBVLevel[Index]
    \fCueAltVolNow[Index] = #SCS_MINVOLUME_SINGLE
    \fCueTotalVolNow[Index] = \fBVLevel[Index]
    CompilerIf #cTraceCueTotalVolNow
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fCueTotalVolNow[" + Index + "]=" + traceLevel(aAud(nEditAudPtr)\fCueTotalVolNow[Index]))
    CompilerEndIf
    
    SLD_setLevel(WQF\sldLevel[Index], \fBVLevel[Index], \fTrimFactor[Index])
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
        setLevelsAny(nEditAudPtr, Index, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE)
        \fCueVolNow[Index] = #SCS_MINVOLUME_SINGLE
        \fCueTotalVolNow[Index] = #SCS_MINVOLUME_SINGLE
        CompilerIf #cTraceCueTotalVolNow
          debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fCueTotalVolNow[" + Index + "]=" + traceLevel(aAud(nEditAudPtr)\fCueTotalVolNow[Index]))
        CompilerEndIf
      EndIf
    EndIf
    
    recalcLvlPtLevels(nEditAudPtr)
    \bLvlPtRunForceSettings = #True
    debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(nEditAudPtr) + ", " + \nCuePos + ")")
    doLvlPtRun(nEditAudPtr, \nCuePos)
    rWQF\bCallSetOrigDBLevels = #True
    
    postChangeAudSN(u, \sDBLevel[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQF_fcTxtPan(Index, fNewPan.f)
  PROCNAMEC()
  Protected u
  
  With aAud(nEditAudPtr)
    
    u = preChangeAudF(\fPan[Index], rWQF\sUndoDescKeyPart + GetGadgetText(WQF\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fPan[Index] = fNewPan
    \fSavedPan[Index] = \fPan[Index]
    
    \fCuePanNow[Index] = \fPan[Index]
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
        setLevelsAny(nEditAudPtr, Index, #SCS_NOVOLCHANGE_SINGLE, \fPan[Index])
        \fCuePanNow[Index] = \fPan[Index]
      EndIf
    EndIf
    
    debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fPan[" + Index + "]=" + formatPan(\fPan[Index]))
    SLD_setValue(WQF\sldPan[Index], panToSliderValue(\fPan[Index]))
    debugMsg(sProcName, "SLD_getValue(WQF\sldPan[" + Index + "])=" + WQF\sldPan[Index])
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
        setLevelsAny(nEditAudPtr, Index, #SCS_NOVOLCHANGE_SINGLE, \fPan[Index])
        \fCuePanNow[Index] = \fPan[Index]
      EndIf
    EndIf
    
    If \fPan[Index] = #SCS_PANCENTRE_SINGLE
      setEnabled(WQF\btnCenter[Index], #False)
    Else
      setEnabled(WQF\btnCenter[Index], #True)
    EndIf
    setDerivedLevelPointInfo2(nEditAudPtr)
    
    rWQF\bCallSetOrigDBLevels = #True
    
    postChangeAudFN(u, \fPan[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQF_setPropertyContainsLoop(nLoopInfoIndex, bNewContainsLoop)
  PROCNAMEC()
  Protected u
  Protected sChangeKey.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex)
    sChangeKey = Str(nLoopInfoIndex) + "|" + Str(\bContainsLoop) + "|" + Str(\nLoopStart) + "|" + Str(\nLoopEnd) + "|" + \nNumLoops + "|" + \sLoopStartCPName + "|" + \sLoopEndCPName
    ;     u = preChangeAudS(sChangeKey, getOwnText(WQF\chkLoop))
    ; changed getOwnText(WQF\chkLoop) to Lang("WQF", "chkLoop") as WQF_setPropertyContainsLoop() may be called from WCP_copyPropsForF(), in which case gadget WQF\chkLoop may not yet have been created
    u = preChangeAudS(sChangeKey, Lang("WQF", "chkLoop"))
    \bContainsLoop = bNewContainsLoop
    
    If \bContainsLoop = #False
      aAud(nEditAudPtr)\aLoopInfo(nLoopInfoIndex) = grLoopInfoDef
      setDerivedAudFields(nEditAudPtr)
      
      If nLoopInfoIndex = rWQF\nDisplayedLoopInfoIndex
        SGT(WQF\txtLoopStart, "")
        SGT(WQF\txtLoopEnd, "")
        SGT(WQF\txtLoopXFadeTime, "")
        SGT(WQF\txtNumLoops, "")
        setOwnState(WQF\chkLoopLinked, #False)  ; added 2Nov2015 11.4.1.2g
      EndIf
      
    Else
      \nLoopXFadeTime = grLoopInfoDef\nLoopXFadeTime
      If nLoopInfoIndex = rWQF\nDisplayedLoopInfoIndex
        SGT(WQF\txtLoopXFadeTime, timeToStringBWZT(\nLoopXFadeTime))
      EndIf
      setDerivedAudFields(nEditAudPtr)
      
    EndIf
    
    debugMsg(sProcName, "calling WQF_refreshFileInfo()")
    WQF_refreshFileInfo()
    
    debugMsg(sProcName, "calling WQF_setTimeFieldEnabledStates()")
    WQF_setTimeFieldEnabledStates()
    
    debugMsg(sProcName, "calling setBassLoopStart(" + getAudLabel(nEditAudPtr) + ")")
    setBassLoopStart(nEditAudPtr)
    debugMsg(sProcName, "calling setBassLoopEnd(" + getAudLabel(nEditAudPtr) + ")")
    setBassLoopEnd(nEditAudPtr)
    
    WQF_setClearState()
    sChangeKey = Str(nLoopInfoIndex) + "|" + \bContainsLoop + "|" + \nLoopStart + "|" + \nLoopEnd + "|" + \nNumLoops + "|" + \sLoopStartCPName + "|" + \sLoopEndCPName
    postChangeAudSN(u, sChangeKey)
    ; debugMsg(sProcName, "calling drawWholeGraphArea()")
    drawWholeGraphArea()
    
    If aAud(nEditAudPtr)\nMaxLoopInfo >= 0
      ; if turning on 'Loop' then force 'View All' to make sure loop start and end points are visible
      WQF_btnViewAll_Click()
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_chkLoop_Click()
  PROCNAMEC()
  Protected bNewContainsLoop
  
  debugMsg(sProcName, #SCS_START)
  
  bNewContainsLoop = getOwnState(WQF\chkLoop)
  WQF_setPropertyContainsLoop(rWQF\nDisplayedLoopInfoIndex, bNewContainsLoop)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnLoopNrLeft_Click()
  If rWQF\nDisplayedLoopInfoIndex > 0
    rWQF\nDisplayedLoopInfoIndex - 1
    WQF_displayLoopAndCueMarkerInfo()
  EndIf
EndProcedure

Procedure WQF_btnLoopNrRight_Click()
  If rWQF\nDisplayedLoopInfoIndex < aAud(nEditAudPtr)\nMaxLoopInfo
    rWQF\nDisplayedLoopInfoIndex + 1
    WQF_displayLoopAndCueMarkerInfo()
  EndIf
EndProcedure

Procedure WQF_btnLoopAdd_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected l2, l3
  Protected nReqdArraySize
  Protected nLoopStart, nLoopEnd
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    If \nMaxLoopInfo < #SCS_MAX_LOOP
      u = preChangeAudL(#False, Lang("WQF", "btnLoopAddTT"))
      ; create a new slot in the \aLoopInfo() array for this new entry
      nReqdArraySize = \nMaxLoopInfo + 1
      If ArraySize(\aLoopInfo()) < nReqdArraySize
        ReDim \aLoopInfo(nReqdArraySize)
      EndIf
      For l2 = \nMaxLoopInfo To (rWQF\nDisplayedLoopInfoIndex + 1) Step -1
        \aLoopInfo(l2+1) = \aLoopInfo(l2)
      Next l2
      rWQF\nDisplayedLoopInfoIndex + 1
      l2 = rWQF\nDisplayedLoopInfoIndex
      \aLoopInfo(l2) = grLoopInfoDef
      \nMaxLoopInfo = nReqdArraySize
      nLoopStart = \nAbsStartAt
      nLoopEnd = \nAbsEndAt
      If l2 > 0
        nLoopStart = \aLoopInfo(l2-1)\nLoopEnd + 1
      EndIf
      If l2 < \nMaxLoopInfo
        nLoopEnd = \aLoopInfo(\nMaxLoopInfo)\nLoopStart - 1
      EndIf
      If nLoopStart < 0
        nLoopStart = 0
      EndIf
      If nLoopEnd >= \nAbsEndAt
        nLoopEnd = \nAbsEndAt
      EndIf
      If nLoopStart > nLoopEnd
        ; could occur if the current loop runs to the current 'end at' time
        If nLoopEnd <= (\nFileDuration - 1)
          nLoopEnd = \nFileDuration - 1
        EndIf
      EndIf
      \aLoopInfo(l2)\nLoopStart = nLoopStart
      \aLoopInfo(l2)\nLoopEnd = nLoopEnd
      setDerivedLoopInfo(nEditAudPtr, l2)
      \bAudNormSet = #False
      debugMsg(sProcName, "\nAbsStartAt=" + \nAbsStartAt + ", \nAbsEndAt=" + \nAbsEndAt + ", \aLoopInfo(" + l2 + ")\nLoopStart=" + \aLoopInfo(l2)\nLoopStart + ", \aLoopInfo(" + l2 + ")\nLoopEnd=" + \aLoopInfo(l2)\nLoopEnd)
      postChangeAudL(u, #True)
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nMaxLoopInfo=" + aAud(nEditAudPtr)\nMaxLoopInfo)
    EndIf
    
    loadCurrLoopInfo(nEditAudPtr, \nCuePos) ; Added 20Nov2024 11.10.6bm
    
    ; Reload if a Loop added to file for Alt Channel
    If \nSourceAltChannel <> 0
      debugMsg(sProcName, "calling VST_loadAudVSTPlugin(" + getAudLabel(nEditAudPtr) + ")")
      VST_loadAudVSTPlugin(nEditAudPtr)
    EndIf
    
  EndWith
  
  debugMsg(sProcName, "calling WQF_displayLoopAndCueMarkerInfo()")
  WQF_displayLoopAndCueMarkerInfo()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnLoopDel_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected l2
  Protected nReqdArraySize
  Protected nNewMaxLoopIndex, nNewMaxLoopNo
  Protected i, j, h
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  If aAud(nEditAudPtr)\nMaxLoopInfo >= 0
    ; first of all, check that it's OK to delete this loop, ie that there is no SFR cue set to release a loop number that would be greater than the number of loops remaining after this deletion
    ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nMaxLoopInfo=" + aAud(nEditAudPtr)\nMaxLoopInfo)
    nNewMaxLoopIndex = aAud(nEditAudPtr)\nMaxLoopInfo - 1
    nNewMaxLoopNo = nNewMaxLoopIndex + 1
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeS
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          With aSub(j)
            If \bSubTypeS
              For h = 0 To #SCS_MAX_SFR
                If \nSFRAction[h] = #SCS_SFR_ACT_RELEASE
                  If (\nSFRCueType[h] = #SCS_SFR_CUE_SEL) And (\nSFRCuePtr[h] = nEditCuePtr)
                    ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSFRLoopNo[" + h + "]=" + \nSFRLoopNo[h])
                    If \nSFRLoopNo[h] > nNewMaxLoopNo
                      sMsg = LangPars("WQF", "CannotDelLoop", getAudLabel(nEditAudPtr), Str(nNewMaxLoopNo), getSubLabel(j), Str(\nSFRLoopNo[h]))
                      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
                      ProcedureReturn #False
                    EndIf
                  EndIf
                EndIf
              Next h
            EndIf
            j = \nNextSubIndex
          EndWith
        Wend
      EndIf
    Next i
    With aAud(nEditAudPtr)
      If rWQF\nDisplayedLoopInfoIndex >= 0
        u = preChangeAudL(#False, Lang("WQF", "btnLoopDelTT"))
        For l2 = (rWQF\nDisplayedLoopInfoIndex + 1) To \nMaxLoopInfo
          \aLoopInfo(l2-1) = \aLoopInfo(l2)
        Next l2
        \nMaxLoopInfo - 1
        If rWQF\nDisplayedLoopInfoIndex > \nMaxLoopInfo
          rWQF\nDisplayedLoopInfoIndex = \nMaxLoopInfo
        EndIf
        postChangeAudL(u, #True)
      EndIf
    EndWith
  EndIf
  
  loadCurrLoopInfo(nEditAudPtr, aAud(nEditAudPtr)\nCuePos) ; Added 20Nov2024 11.10.6bm
    
  debugMsg(sProcName, "calling WQF_displayLoopAndCueMarkerInfo()")
  WQF_displayLoopAndCueMarkerInfo()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setPropertyLoopLinked(bNewLoopLinked)
  Protected u
  
  With aAud(nEditAudPtr)
    If bNewLoopLinked <> \bLoopLinked
      u = preChangeAudL(\bLoopLinked, getOwnText(WQF\chkLoopLinked))
      \bLoopLinked = bNewLoopLinked
      postChangeAudLN(u, \bLoopLinked)
    EndIf
  EndWith
  
EndProcedure

Procedure WQF_chkLoopLinked_Click()
  PROCNAMEC()
  ; procedure added 2Nov2015 11.4.1.2g
  Protected sMsg.s
  Static bWarningDisplayed
  Protected bNewLoopLinked
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    bNewLoopLinked = getOwnState(WQF\chkLoopLinked)
    WQF_setPropertyLoopLinked(bNewLoopLinked)
    ; added 1Feb2016 11.4.2.1
    If \bLoopLinked
      If gnCurrAudioDriver = #SCS_DRV_BASS_DS Or gnCurrAudioDriver = #SCS_DRV_BASS_WASAPI
        If gbUseBASSMixer = #False
          If bWarningDisplayed = #False
            sMsg = Lang("WQF", "MixerWarning")
            scsMessageRequester(GGT(WQF\chkLoopLinked), sMsg, #MB_ICONEXCLAMATION)
            bWarningDisplayed = #True
          EndIf
        EndIf
      EndIf
    EndIf
    ; end added 1Feb2016 11.4.2.1
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_WEM_Button_Click(nGadgetNo)
  PROCNAMEC()
  Protected nField
  
  debugMsg(sProcName, #SCS_START + ", nGadgetNo=" + GadgetNoAndName(nGadgetNo))
  
  With WQF
    Select nGadgetNo
      Case \btnStartAt
        nField = #SCS_WEM_F_STARTAT
      Case \btnEndAt
        nField = #SCS_WEM_F_ENDAT
      Case \btnLoopStart
        nField = #SCS_WEM_F_LOOPSTART
      Case \btnLoopEnd
        nField = #SCS_WEM_F_LOOPEND
      Case \btnFadeInTime
        nField = #SCS_WEM_F_FADEINTIME
      Case \btnFadeOutTime
        nField = #SCS_WEM_F_FADEOUTTIME
    EndSelect
    
    debugMsg(sProcName, "calling WEM_Form_Show()")
    WEM_Form_Show(#True, #WED, #WQF, nField)
    ; must return now - unlike VB, PB doesn't block processing while the modal form is displayed
    ProcedureReturn
    
  EndWith
  
EndProcedure

Procedure WQF_setLoopTimeFieldEnabledStates()
  PROCNAMEC()
  Protected bEnableLoopTxt, bEnableLoopChevronBtn
  Protected bEnableLoopLinked
  Protected bEnableCurrPos
  Protected nIndex, bCuePointsAvailable, l2
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      l2 = rWQF\nDisplayedLoopInfoIndex
      If (\sFileName) And (\bAudPlaceHolder = #False)
        If grLicInfo\nLicLevel >= #SCS_LIC_STD
          nIndex = getAnalyzedFileIndex(\sFileName)
          If nIndex >= 0
            If gaAnalyzedFile(nIndex)\nFirstCPIndex >= 0
              bCuePointsAvailable = #True
            EndIf
          EndIf
          If \nMaxLoopInfo >= 0
            bEnableLoopTxt = #True
            bEnableLoopChevronBtn = bCuePointsAvailable
            bEnableLoopLinked = #True
          EndIf
        Else
          If \nMaxLoopInfo >= 0
            bEnableLoopTxt = #True
            bEnableLoopLinked = #True
          EndIf
        EndIf
      EndIf
      
      If (\nMaxLoopInfo >= 0) And (l2 >= 0)
        If (bCuePointsAvailable) And (\aLoopInfo(l2)\dLoopStartCPTime >= 0.0)
          setEnabled(WQF\txtLoopStart, #False)
        Else
          setEnabled(WQF\txtLoopStart, bEnableLoopTxt)
        EndIf
      Else
        setEnabled(WQF\txtLoopStart, #False)
      EndIf
      setTextBoxBackColor(WQF\txtLoopStart)
      setEnabled(WQF\btnLoopStart, bEnableLoopChevronBtn)
      
      If (\nMaxLoopInfo >= 0) And (l2 >= 0)
        If (bCuePointsAvailable) And (\aLoopInfo(l2)\dLoopEndCPTime >= 0.0)
          setEnabled(WQF\txtLoopEnd, #False)
        Else
          setEnabled(WQF\txtLoopEnd, bEnableLoopTxt)
        EndIf
      Else
        setEnabled(WQF\txtLoopEnd, #False)
      EndIf
      setTextBoxBackColor(WQF\txtLoopEnd)
      setEnabled(WQF\btnLoopEnd, bEnableLoopChevronBtn)
      
      setEnabled(WQF\txtLoopXFadeTime, bEnableLoopTxt)
      setTextBoxBackColor(WQF\txtLoopXFadeTime)
      
      setEnabled(WQF\txtNumLoops, bEnableLoopTxt)
      setTextBoxBackColor(WQF\txtNumLoops)
      
      setOwnEnabled(WQF\chkLoopLinked, bEnableLoopLinked)
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_setTimeFieldEnabledStates()
  PROCNAMEC()
  Protected bEnableStartEndTxt, bEnableStartEndChevronBtn
  Protected bEnableLoopTxt, bEnableLoopChevronBtn
  Protected bEnableLoopLinked
  Protected bEnableFades
  Protected bEnableCurrPos
  Protected nIndex, bCuePointsAvailable, l2
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      l2 = rWQF\nDisplayedLoopInfoIndex
      If (\sFileName) And (\bAudPlaceHolder = #False)
        If \nCueDuration > 0
          bEnableCurrPos = #True
        EndIf
        If grLicInfo\nLicLevel >= #SCS_LIC_STD
          nIndex = getAnalyzedFileIndex(\sFileName)
          If nIndex >= 0
            If gaAnalyzedFile(nIndex)\nFirstCPIndex >= 0
              bCuePointsAvailable = #True
            EndIf
          EndIf
          bEnableStartEndTxt = #True
          bEnableStartEndChevronBtn = bCuePointsAvailable
          If \nMaxLoopInfo >= 0
            bEnableLoopTxt = #True
            bEnableLoopChevronBtn = bCuePointsAvailable
            bEnableLoopLinked = #True
          EndIf
          bEnableFades = #True
        Else
          If \nMaxLoopInfo >= 0
            bEnableLoopTxt = #True
            bEnableLoopLinked = #True
          EndIf
          bEnableFades = #True
        EndIf
      EndIf
      
      If (bCuePointsAvailable) And (\dStartAtCPTime >= 0.0)
        setEnabled(WQF\txtStartAt, #False)
      Else
        setEnabled(WQF\txtStartAt, bEnableStartEndTxt)
      EndIf
      setTextBoxBackColor(WQF\txtStartAt)
      setEnabled(WQF\btnStartAt, bEnableStartEndChevronBtn)
      
      If (bCuePointsAvailable) And (\dEndAtCPTime >= 0.0)
        setEnabled(WQF\txtEndAt, #False)
      Else
        setEnabled(WQF\txtEndAt, bEnableStartEndTxt)
      EndIf
      setTextBoxBackColor(WQF\txtEndAt)
      setEnabled(WQF\btnEndAt, bEnableStartEndChevronBtn)
      
      If (\nMaxLoopInfo >= 0) And (l2 >= 0)
        If (bCuePointsAvailable) And (\aLoopInfo(l2)\dLoopStartCPTime >= 0.0)
          setEnabled(WQF\txtLoopStart, #False)
        Else
          setEnabled(WQF\txtLoopStart, bEnableLoopTxt)
        EndIf
      Else
        setEnabled(WQF\txtLoopStart, #False)
      EndIf
      setTextBoxBackColor(WQF\txtLoopStart)
      setEnabled(WQF\btnLoopStart, bEnableLoopChevronBtn)
      
      If (\nMaxLoopInfo >= 0) And (l2 >= 0)
        If (bCuePointsAvailable) And (\aLoopInfo(l2)\dLoopEndCPTime >= 0.0)
          setEnabled(WQF\txtLoopEnd, #False)
        Else
          setEnabled(WQF\txtLoopEnd, bEnableLoopTxt)
        EndIf
      Else
        setEnabled(WQF\txtLoopEnd, #False)
      EndIf
      setTextBoxBackColor(WQF\txtLoopEnd)
      setEnabled(WQF\btnLoopEnd, bEnableLoopChevronBtn)
      
      setEnabled(WQF\txtFadeInTime, bEnableFades)
      setTextBoxBackColor(WQF\txtFadeInTime)
      setEnabled(WQF\btnFadeInTime, bEnableFades)
      
      setEnabled(WQF\txtFadeOutTime, bEnableFades)
      setTextBoxBackColor(WQF\txtFadeOutTime)
      setEnabled(WQF\btnFadeOutTime, bEnableFades)
      
      setEnabled(WQF\txtLoopXFadeTime, bEnableLoopTxt)
      setTextBoxBackColor(WQF\txtLoopXFadeTime)
      
      setEnabled(WQF\txtNumLoops, bEnableLoopTxt)
      setTextBoxBackColor(WQF\txtNumLoops)
      
      setOwnEnabled(WQF\chkLoopLinked, bEnableLoopLinked)
      
      setEnabled(WQF\txtCurrPos, bEnableCurrPos)
      setTextBoxBackColor(WQF\txtCurrPos)
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_resetSliders()
  PROCNAMECA(nEditAudPtr)
  Protected d
  Protected bIgnoreDevToBeCleared
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      For d = \nFirstDev To \nLastDev
        If \sLogicalDev[d]
          If \bIgnoreDev
            bIgnoreDevToBeCleared = #True
            Break
          EndIf
        EndIf
      Next d
      If bIgnoreDevToBeCleared
        setIgnoreDevInds(nEditAudPtr, #True)  ; also calls setFirstAndLastDev()
      EndIf
      For d = \nFirstDev To \nLastDev
        WQF_fcLogicalDev(d)
      Next d
    EndWith
  EndIf
EndProcedure

Procedure WQF_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nWidth, nHeight, nInnerHeight, nMinInnerHeight
  
  ; debugMsg(sProcName, #SCS_START + ", IsWindow(#WED)=" + IsWindow(#WED) + ", WindowWidth(#WED)=" + WindowWidth(#WED))
  
  With WQF
    If (IsWindow(#WED)) And (IsGadget(\scaSoundFile))
      ; \scaSoundFile automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaSoundFile) - gl3DBorderHeight
      nMinInnerHeight = 273
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaSoundFile, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailF
      nHeight = nInnerHeight - GadgetY(\cntSubDetailF)
      ResizeGadget(\cntSubDetailF, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; adjust the height of \cntAudioControls
      nHeight = GadgetHeight(\cntSubDetailF) - GadgetY(\cntAudioControls) - GadgetHeight(\cntTest) - 8
      ResizeGadget(\cntAudioControls, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; adjust the height of \scaDevs
      nHeight = GadgetHeight(\cntAudioControls) - GadgetY(\scaDevs)
      ResizeGadget(\scaDevs, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; adjust the top position of the controls below \cntAudioControls
      nTop = GadgetY(\cntAudioControls) + GadgetHeight(\cntAudioControls) + 5
      ResizeGadget(\cntTest, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      
      ; adjust the width of the graph area
      ; nb width calculations below should be the same as used in scsOpenGadgetList(WED\cntSpecialQF) under createfmEditQF()
      nWidth = WindowWidth(#WED)
;       debugMsg(sProcName,"WindowWidth(#WED)=" + WindowWidth(#WED) + ", GadgetWidth(WED\cntSpecialQF)=" + GadgetWidth(WED\cntSpecialQF) +
;                          ", IsWindow(#WED)=" + IsWindow(#WED) + ", #WED=" + #WED)
      If (GadgetWidth(WED\cntSpecialQF) <> nWidth) And (nWidth > 0)
        ; the above test is to avoid executing the following code if the user has changed the height but not the width of the editor window
        ; debugMsg(sProcName, "GadgetWidth(WED\cntSpecialQF)=" + GadgetWidth(WED\cntSpecialQF) + ", nWidth=" + nWidth)
        ResizeGadget(WED\cntSpecialQF,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
        ; debugMsg(sProcName, "ResizeGadget(WED\cntSpecialQF,#PB_Ignore,#PB_Ignore," + nWidth + ",#PB_Ignore)")
        nWidth = GadgetWidth(WED\cntSpecialQF) - gl3DBorderAllowanceX
        ResizeGadget(WQF\cntGraphDisplay,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
        ; debugMsg(sProcName, "ResizeGadget(WQF\cntGraphDisplay,#PB_Ignore,#PB_Ignore," + nWidth + ",#PB_Ignore), GadgetX(WQF\cntGraphDisplay)=" + Str(GadgetX(WQF\cntGraphDisplay)))
        nWidth = GadgetWidth(\cntGraphDisplay) - GadgetWidth(\cvsSideLabels) - GadgetX(\cvsSideLabels) - 2 ; 2 pixels to allow for 'flat' border of \cntGraphDisplay
        ResizeGadget(\cntGraph, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
        ; debugMsg(sProcName, "ResizeGadget(\cntGraph, #PB_Ignore, #PB_Ignore, " + nWidth + ", #PB_Ignore), GadgetX(WQF\cntGraph)=" + Str(GadgetX(WQF\cntGraph)))
        ; debugMsg(sProcName, "calling resizeGraph(@grMG2)")
        resizeGraph(@grMG2)
        If getEnabled(WQF\btnViewAll)
          ; debugMsg(sProcName, "calling WQF_btnViewAll_Click() to reset the graph view")
          WQF_btnViewAll_Click()
        EndIf
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_setStdEnabled(nPointTime)
  PROCNAMECA(nEditAudPtr)
  Protected bStdEnabled, nMinTimeForStd, nMaxTimeForStd
  
  With aAud(nEditAudPtr)
    If \nFadeInTime <= 0
      nMinTimeForStd = \nAbsStartAt + 1
    Else
      nMinTimeForStd = \nAbsStartAt + \nFadeInTime + 1
    EndIf
    If \nFadeOutTime <= 0
      nMaxTimeForStd = \nAbsEndAt - 1
    Else
      nMaxTimeForStd = \nAbsEndAt - \nFadeOutTime - 1
    EndIf
    If (nPointTime >= nMinTimeForStd) And (nPointTime <= nMaxTimeForStd) And (\nMaxLoopInfo < 0)
      bStdEnabled = #True
    EndIf
  EndWith
  debugMsg(sProcName, "nPointTime=" + nPointTime + ", nMinTimeForStd=" + nMinTimeForStd + ", nMaxTimeForStd=" + nMaxTimeForStd + ", bStdEnabled=" + strB(bStdEnabled))
  ProcedureReturn bStdEnabled
EndProcedure

Procedure WQF_graphContextMenuEnabledStates()
  PROCNAMECA(nEditAudPtr)
  Protected nPointTime, nPointType
  Protected bStdEnabled, bFadeInEnabled, bFadeOutEnabled
  Protected bRemoveEnabled
  Protected bSameAsPrevEnabled, bSameAsNextEnabled
  Protected bSameLvlAsPrevEnabled, bSameLvlAsNextEnabled
  Protected bSamePanAsPrevEnabled, bSamePanAsNextEnabled
  Protected bShowLvlCurvesSelEnabled, bShowPanCurvesSelEnabled, bShowLvlCurvesOtherEnabled, bShowPanCurvesOtherEnabled
  Protected bSetPosEnabled
  Protected bSetStartAtEnabled, bSetEndAtEnabled
  Protected bSetLoopStartEnabled, bSetLoopEndEnabled
  Protected nLevelPointIndex
  Protected nFirstPointTime
  Protected nNextLevelPointIndex, nNextPointTime
  Protected nPrevLevelPointIndex, nPrevPointTime
  Protected n, nGraphMarkerIndex
  Protected bMarkersVisible
  Protected bEditCueMarker, bRemoveCueMarker, bSetCueMarkerPosition, bShowOnCues, bCueMarkersEnabled, nCueMarkerIndex, bShowOnAllGraphs, bRemoveAllCueMarkersFromFile
  
  With grMG2
    If grEditorPrefs\bEditShowLvlCurvesSel
      bMarkersVisible = #True
    ElseIf (grEditorPrefs\bEditShowPanCurvesSel) And (\nGraphChannels = 2)
      bMarkersVisible = #True
    EndIf
  EndWith
  
  If (nEditAudPtr >= 0) And (rWQF\nCurrDevNo >= 0)
    With aAud(nEditAudPtr)
      nGraphMarkerIndex = checkMouseOnGraphMarker(@grMG2, grMG2\nMouseDownStartX, grMG2\nMouseDownStartY)
      debugMsg(sProcName, "nGraphMarkerIndex=" + nGraphMarkerIndex)
      If nGraphMarkerIndex >= 0
        Select grMG2\aGraphMarker(nGraphMarkerIndex)\nGraphMarkerType
          Case #SCS_GRAPH_MARKER_CM, #SCS_GRAPH_MARKER_CP
            nCueMarkerIndex = grMG2\aGraphMarker(nGraphMarkerIndex)\nMGCueMarkerIndex
            nPointTime = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
            debugMsg(sProcName, "Cue Marker nPointTime=" + nPointTime)
          Case #SCS_GRAPH_MARKER_LP
            nPointTime = grMG2\aGraphMarker(nGraphMarkerIndex)\nGraphMarkerTime
            nLevelPointIndex = getLevelPointIndexForTime(nEditAudPtr, nPointTime)
            debugMsg(sProcName, "nPointTime=" + nPointTime + ", nLevelPointIndex=" + nLevelPointIndex)
        EndSelect
      Else
        nPointTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        nLevelPointIndex = -1
      EndIf
      nNextLevelPointIndex = getNextLevelPointIndex(nEditAudPtr, nPointTime)
      If nNextLevelPointIndex >= 0
        nNextPointTime = \aPoint(nNextLevelPointIndex)\nPointTime
      Else
        nNextPointTime = \nFileDuration + 1000
      EndIf
      nPrevLevelPointIndex = getPrevLevelPointIndex(nEditAudPtr, nPointTime)
      If nPrevLevelPointIndex >= 0
        nPrevPointTime = \aPoint(nPrevLevelPointIndex)\nPointTime
      Else
        nPrevPointTime = -1000
      EndIf
      ; Added 10Feb2022 11.9.0
      If \nMaxLevelPoint >= 0
        nFirstPointTime = getTimeOfFirstNonStartLevelPoint(nEditAudPtr)
      Else
        nFirstPointTime = \nFileDuration + 1000
      EndIf
      ; End added 10Feb2022 11.9.0
      
      If nGraphMarkerIndex = -1
        If \nFadeInTime <= 0
          If (nPointTime < nFirstPointTime) And (nPointTime > \nAbsStartAt) And (nPointTime < \nAbsEndAt) ; Changed 10Feb2022 11.9.0 (nFirstPointTime was nNextPointTime)
            bFadeInEnabled = #True
            If \nFadeOutTime > 0
              If nPointTime >= (\nAbsEndAt - \nFadeOutTime)
                bFadeInEnabled = #False
              EndIf
            EndIf
          EndIf
        EndIf
        
        If \nFadeOutTime <= 0
          If (nNextPointTime = \nAbsEndAt) And (nPointTime > \nAbsStartAt)
            bFadeOutEnabled = #True
            If \nFadeInTime > 0
              If nPointTime <= (\nAbsStartAt + \nFadeInTime)
                bFadeOutEnabled = #False
              EndIf
            EndIf
          EndIf
        EndIf
        
        bStdEnabled = WQF_setStdEnabled(nPointTime)
        
      EndIf
      
      If (nPointTime >= \nAbsMin) And (nPointTime <= \nAbsMax)
        bCueMarkersEnabled = #True
      EndIf
      
      If nLevelPointIndex >= 0
        nPointType = \aPoint(nLevelPointIndex)\nPointType
        debugMsg(sProcName, "\aPoint(" + nLevelPointIndex + ")\nPointType=" + decodeLevelPointType(nPointType))
        Select nPointType
          Case #SCS_PT_STD, #SCS_PT_FADE_OUT, #SCS_PT_END
            If nPointTime > \nAbsStartAt
              bSameLvlAsPrevEnabled = #True
              If grMG2\nGraphChannels = 2
                bSamePanAsPrevEnabled = #True
                bSameAsPrevEnabled = #True
              EndIf
            EndIf
        EndSelect
        Select nPointType
          Case #SCS_PT_START, #SCS_PT_FADE_IN, #SCS_PT_STD
            If nPointTime < \nAbsEndAt
              bSameLvlAsNextEnabled = #True
              If grMG2\nGraphChannels = 2
                bSamePanAsNextEnabled = #True
                bSameAsNextEnabled = #True
              EndIf
            EndIf
        EndSelect
        Select nPointType
          Case #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT
            bSetPosEnabled = #True
            bRemoveEnabled = #True
        EndSelect
        If ((nPointType = #SCS_PT_START) And (\nFadeInTime > 0)) Or ((nPointType = #SCS_PT_END) And (\nFadeOutTime > 0))
          bSameLvlAsNextEnabled = #False
          bSameAsNextEnabled = #False
          bSameLvlAsPrevEnabled = #False
          bSameAsPrevEnabled = #False
        EndIf
      EndIf
      
      bShowLvlCurvesSelEnabled = #True
      bShowLvlCurvesOtherEnabled = #True
      bShowPanCurvesOtherEnabled = #True ; enable pan for all devs even if the current device is mono
      If grMG2\nGraphChannels = 2
        bShowPanCurvesSelEnabled = #True
      EndIf
    EndWith 
  EndIf
  
  If bMarkersVisible = #False
    bFadeInEnabled = #False
    bFadeOutEnabled = #False
    bStdEnabled = #False
    bCueMarkersEnabled = #False
    ; other menu items for level points will be disabled anyway because the mouse cursor will not be found on a marker if no markers are visible
  EndIf
  
  bSetStartAtEnabled = getEnabled(WQF\txtStartAt)
  bSetEndAtEnabled = getEnabled(WQF\txtEndAt)
  bSetLoopStartEnabled = getEnabled(WQF\txtLoopStart)
  bSetLoopEndEnabled = getEnabled(WQF\txtLoopEnd)
  
  If grLicInfo\bCueMarkersAvailable
    bShowOnAllGraphs = #True
    If aAud(nEditAudPtr)\nMaxCueMarker >= 0
      bRemoveAllCueMarkersFromFile = #True
    EndIf
    If bCueMarkersEnabled
      bEditCueMarker = #True
      bShowOnCues = #True
      If grMG2\nGraphMarkerIndex >= 0
        bRemoveCueMarker = #True
        bSetCueMarkerPosition = #True
      EndIf
    EndIf
  EndIf
  
  If IsMenu(#WQF_mnu_GraphContextMenu)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_AddFadeInLvlPt, bFadeInEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_AddFadeOutLvlPt, bFadeOutEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_AddStdLvlPt, bStdEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_RemoveLvlPt, bRemoveEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SameLvlAsPrev, bSameLvlAsPrevEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SameLvlAsNext, bSameLvlAsNextEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SamePanAsPrev, bSamePanAsPrevEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SamePanAsNext, bSamePanAsNextEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SameAsPrev, bSameAsPrevEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SameAsNext, bSameAsNextEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SetPos, bSetPosEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SetCueMarkerPos, bSetCueMarkerPosition)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SetStartAt, bSetStartAtEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SetEndAt, bSetEndAtEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SetLoopStart, bSetLoopStartEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_SetLoopEnd, bSetLoopEndEnabled)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_AddQuickCueMarkers, bShowOnCues)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_EditCueMarker, bEditCueMarker)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_RemoveCueMarker, bRemoveCueMarker)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_RemoveAllUnusedCueMarkersFromThisFile, bRemoveAllCueMarkersFromFile)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_ViewOnCues, bShowOnAllGraphs)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_ViewCueMarkersUsage, bShowOnAllGraphs)
    scsEnableMenuItem(#WQF_mnu_GraphContextMenu, #WQF_mnu_RemoveAllUnusedCueMarkers, bShowOnAllGraphs)
  EndIf
  
EndProcedure

Procedure WQF_mnuAddLevelPoint(nPointType)
  PROCNAMECA(nEditAudPtr)
  Protected d, n, u
  Protected sLogicalDev.s, sTracks.s
  Protected nPointTime
  Protected nLevelPointIndex, nPrevLevelPointIndex, nNextLevelPointIndex
  Protected nItemIndex, nPrevItemIndex, nNextItemIndex
  Protected bReqdItemInclude
  Protected fReqdItemRelDBLevel.f
  Protected fReqdItemPan.f
  Protected sMsg.s
  Protected bLevelPointAdded
  Protected sAddLevelPoint.s
  Protected nOldFadeInTime, nOldFadeOutTime
  Static sAddStdLvlPt.s, sAddFadeInLvlPt.s, sAddFadeOutLvlPt.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sAddStdLvlPt = Lang("Menu", "mnuWQFAddStdLvlPt")
    sAddFadeInLvlPt = Lang("Menu", "mnuWQFAddFadeInLvlPt")
    sAddFadeOutLvlPt = Lang("Menu", "mnuWQFAddFadeOutLvlPt")
    bStaticLoaded = #True
  EndIf
  
  Select nPointType
    Case #SCS_PT_FADE_IN
      sAddLevelPoint = sAddFadeInLvlPt
    Case #SCS_PT_FADE_OUT
      sAddLevelPoint = sAddFadeOutLvlPt
    Default
      sAddLevelPoint = sAddStdLvlPt
  EndSelect
  
  bReqdItemInclude = grLevelPointItemDef\bItemInclude
  fReqdItemPan = grLevelPointItemDef\fItemPan
  
  While #True   ; dummy loop so we can 'Break' to quit
    
    If nEditAudPtr >= 0
      With aAud(nEditAudPtr)
        
        nPointTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        debugMsg(sProcName, "grMG2\nMouseDownStartX=" + grMG2\nMouseDownStartX + ", nPointTime=" + nPointTime + " (" + timeToStringT(nPointTime) + ")")
        
        ; check that we can add a Level Point at the selected position
        ; make sure there's no existing level point at this exact position
        nLevelPointIndex = getLevelPointIndexForTime(nEditAudPtr, nPointTime)
        If nLevelPointIndex >= 0
          sMsg = LangPars("Errors", "LvlPtAlready", timeToStringT(nPointTime))
          debugMsg(sProcName, sMsg)
          SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
          scsMessageRequester(sAddLevelPoint, sMsg, #MB_ICONEXCLAMATION)
          Break
        EndIf
        
        u = preChangeAudL(\nMaxLevelPoint, sAddLevelPoint, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
        
        nLevelPointIndex = addOneLevelPoint(nEditAudPtr, nPointTime, nPointType)
        If nLevelPointIndex >= 0
          bLevelPointAdded = #True
          
          Select nPointType
            Case #SCS_PT_FADE_IN
              nOldFadeInTime = \nFadeInTime
              \nFadeInTime = nPointTime - \nAbsStartAt
              \nCurrFadeInTime = \nFadeInTime
              debugMsg(sProcName, "\nFadeInTime=" + \nFadeInTime)
              SGT(WQF\txtFadeInTime, timeToStringBWZT(\nFadeInTime))
              WQF_setClearState()
              debugMsg(sProcName, "calling maintainFadeInLevelPoint(" + getAudLabel(nEditAudPtr) + ", " + nOldFadeInTime + ", " + \nFadeInTime + ")")
              maintainFadeInLevelPoint(nEditAudPtr, nOldFadeInTime, \nFadeInTime)
              
            Case #SCS_PT_FADE_OUT
              nOldFadeOutTime = \nFadeOutTime
              \nFadeOutTime = \nAbsEndAt - nPointTime
              \nCurrFadeOutTime = \nFadeOutTime
              debugMsg(sProcName, "\nFadeOutTime=" + \nFadeOutTime)
              SGT(WQF\txtFadeOutTime, timeToStringBWZT(\nFadeOutTime))
              WQF_setClearState()
              debugMsg(sProcName, "calling maintainFadeOutLevelPoint(" + getAudLabel(nEditAudPtr) + ", " + nOldFadeOutTime + ", " + \nFadeOutTime + ")")
              maintainFadeOutLevelPoint(nEditAudPtr, nOldFadeOutTime, \nFadeOutTime)
              
          EndSelect
          
          Select nPointType
            ; Case #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT
            Case #SCS_PT_STD
              ; get prev level point, as the initial level and pan info will be taken from that level point
              nPrevLevelPointIndex = getPrevLevelPointIndex(nEditAudPtr, nPointTime)
              If nPrevLevelPointIndex >= 0
                For d = \nFirstDev To \nLastDev
                  sLogicalDev = \sLogicalDev[d]
                  sTracks = \sTracks[d]
                  If sLogicalDev
                    nPrevItemIndex = getLevelPointItemIndex(nEditAudPtr, nPrevLevelPointIndex, sLogicalDev, sTracks)
                    If nPrevItemIndex >= 0
                      fReqdItemRelDBLevel = \aPoint(nPrevLevelPointIndex)\aItem(nPrevItemIndex)\fItemRelDBLevel
                      fReqdItemPan = \aPoint(nPrevLevelPointIndex)\aItem(nPrevItemIndex)\fItemPan
                      ; added 30Mar2017 11.6.0
                      ; for new standard level points, only the currently-selected audio device is to be marked for 'include' (Feature Request from Mark Seyler 2Mar2017)
                      ; 27Dec2018 11.8.0cm added "Or (grEditingOptions\bIncludeAllLevelPointDevices)"
                      If (d = rWQF\nCurrDevNo) Or (grEditingOptions\bIncludeAllLevelPointDevices)
                        bReqdItemInclude = #True
                      Else
                        bReqdItemInclude = #False
                      EndIf
                      ; end added 30Mar2017 11.6.0
                      nItemIndex = addOneDBLevelPointItem(nEditAudPtr, nLevelPointIndex, sLogicalDev, sTracks, bReqdItemInclude, fReqdItemRelDBLevel, fReqdItemPan)
                    EndIf
                  EndIf
                Next d
              EndIf
          EndSelect
          
          debugMsg(sProcName, "calling sortLevelPointsArray(" + getAudLabel(nEditAudPtr) + ")")
          sortLevelPointsArray(nEditAudPtr)
          
          debugMsg(sProcName, "calling setDerivedLevelPointInfo2(" + getAudLabel(nEditAudPtr) + ")")
          setDerivedLevelPointInfo2(nEditAudPtr)
          
        EndIf
        
        postChangeAudLN(u, \nMaxLevelPoint)
        
      EndWith
      
    EndIf
    
    If bLevelPointAdded
      rWQF\bDisplayingLevelPoint = #True
      rWQF\nCurrLevelPointType = nPointType
      rWQF\nCurrLevelPointTime = nPointTime
      debugMsg(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", \nCurrLevelPointType=" + decodeLevelPointType(rWQF\nCurrLevelPointType) + ", \nCurrLevelPointTime=" + rWQF\nCurrLevelPointTime)
      grMG2\nLastTimeMark = nPointTime
      debugMsg(sProcName, "grMG2\nLastTimeMark=" + grMG2\nLastTimeMark)
      WQF_populateCboDevSel()
      debugMsg(sProcName, "calling WQF_processDevSel()")
      WQF_processDevSel()
      WQF_fcLevelPointInfo()
    EndIf
    
    drawGraph(@grMG2)
    
    Break
  Wend
  
  ; clear the 'clip mouse' attribute or PB thinks the mouse is still down and won't let the mouse pointer leave the canvas
  SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_cboGraphDisplayMode_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  grEditorPrefs\nGraphDisplayMode = getCurrentItemData(WQF\cboGraphDisplayMode)
  
  debugMsg(sProcName, "calling loadSlicePeakAndMinArraysAndDrawGraph(@grMG2)")
  loadSlicePeakAndMinArraysAndDrawGraph(@grMG2)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_chkAutoScroll_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  grEditorPrefs\bAutoScroll = getOwnState(WQF\chkAutoScroll)
  
  debugMsg(sProcName, #SCS_END + ", grEditorPrefs\bAutoScroll=" + grEditorPrefs\bAutoScroll)
  
EndProcedure

Procedure WQF_setCurrentDevInfo(Index, bRedrawGraphIfReqd, bForceSet=#False, bSkipGraphDrawing=#False)
  PROCNAMEC()
  Protected nDisplayedDevNo, nReqdDevNo, d
  Protected sLogicalDev.s
  Protected nWidth
  Protected bPrevDevAssigned
  Protected nFileDataPtr
  Protected bSaveToTempDatabase
  Protected bLoadResult
  Protected bEnableMoveUp, bEnableMoveDown, bEnableInsert, bEnableRemove
  Static bStaticLoaded
  Static nDevBackColor, nDevFrontColor
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", bRedrawGraphIfReqd=" + strB(bRedrawGraphIfReqd) + ", bForceSet=" + strB(bForceSet) + ", bSkipGraphDrawing=" + strB(bSkipGraphDrawing))
  
  If bStaticLoaded = #False
    If IsGadget(WQF\lblGraphDev)
      nDevBackColor = GetGadgetColor(WQF\lblGraphDev, #PB_Gadget_BackColor)
      nDevFrontColor = GetGadgetColor(WQF\lblGraphDev, #PB_Gadget_FrontColor)
      bStaticLoaded = #True
    EndIf
  EndIf
  
  nDisplayedDevNo = rWQF\nCurrDevNo
  nReqdDevNo = Index
  
  If bForceSet
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      If d <> nReqdDevNo
        SetGadgetColor(WQF\lblDevNo[d], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
        SetGadgetColor(WQF\lblDevNo[d], #PB_Gadget_FrontColor, #SCS_Black)
      EndIf
    Next d
  EndIf
  
  debugMsg(sProcName, "nReqdDevNo=" + nReqdDevNo + ", nDisplayedDevNo=" + nDisplayedDevNo + ", bForceSet=" + strB(bForceSet))
  If (nReqdDevNo <> nDisplayedDevNo) Or (bForceSet)
    If nDisplayedDevNo >= 0
      SetGadgetColor(WQF\lblDevNo[nDisplayedDevNo], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      SetGadgetColor(WQF\lblDevNo[nDisplayedDevNo], #PB_Gadget_FrontColor, #SCS_Black)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WQF\lblDevNo[nReqdDevNo], #PB_Gadget_BackColor, nDevBackColor)
      SetGadgetColor(WQF\lblDevNo[nReqdDevNo], #PB_Gadget_FrontColor, nDevFrontColor)
    EndIf
    rWQF\nCurrDevNo = nReqdDevNo
    debugMsg(sProcName, "rWQF\nCurrDevNo=" + rWQF\nCurrDevNo)
    bPrevDevAssigned = grMG2\bDeviceAssigned
    If (nReqdDevNo >= 0) And (nEditAudPtr >= 0)
      sLogicalDev = aAud(nEditAudPtr)\sLogicalDev[nReqdDevNo]
      If sLogicalDev
        grMG2\bDeviceAssigned = #True
        debugMsg(sProcName, "grMG2\bDeviceAssigned=#True")
      Else
        grMG2\bDeviceAssigned = #False
        debugMsg(sProcName, "grMG2\bDeviceAssigned=#False")
      EndIf
    Else
      grMG2\bDeviceAssigned = #False
      debugMsg(sProcName, "grMG2\bDeviceAssigned=#False")
    EndIf
    
    SGT(WQF\lblGraphDev, " " + LangPars("WQF","lblGraphDev",sLogicalDev) + " ")
    nWidth = GadgetWidth(WQF\lblGraphDev, #PB_Gadget_RequiredSize)
    If nWidth > WQF\nMaxGraphDevWidth
      nWidth = WQF\nMaxGraphDevWidth
    EndIf
    ResizeGadget(WQF\lblGraphDev,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
    
    setGraphChannelsForLogicalDev(2, sLogicalDev)
    If bSkipGraphDrawing = #False
      If (bRedrawGraphIfReqd) Or (grMG2\bDeviceAssigned <> bPrevDevAssigned) Or (grMG2\sGraphLogicalDev <> sLogicalDev)
        If nEditAudPtr >= 0
          If aAud(nEditAudPtr)\nFileDuration <= grEditingOptions\nFileScanMaxLengthAudioMS Or grEditingOptions\nFileScanMaxLengthAudio < 0
            nFileDataPtr = aAud(nEditAudPtr)\nFileDataPtr
            If nFileDataPtr >= 0
              If getZoomValue() <= 1
                bSaveToTempDatabase = #True
              EndIf
              debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromDatabase(@grMG2, " + nFileDataPtr + ", -1, " + getAudLabel(nEditAudPtr) + ")")
              bLoadResult = loadSlicePeakAndMinArraysFromDatabase(@grMG2, nFileDataPtr, -1, nEditAudPtr)
              If bLoadResult = #False
                debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(@grMG2, " + nFileDataPtr + ", -1, " + getAudLabel(nEditAudPtr) + ", " + strB(bSaveToTempDatabase) + ") for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
                loadSlicePeakAndMinArraysFromSamplesArray(@grMG2, nFileDataPtr, -1, nEditAudPtr, bSaveToTempDatabase)
              EndIf
            EndIf
          EndIf
        EndIf
        If rWQF\bInLogicalDevClick = #False
          debugMsg(sProcName, "calling drawWholeGraphArea()")
          drawWholeGraphArea()
        EndIf
      EndIf
    EndIf
    
    With WQF
      If IsGadget(\btnMoveDevUp)
        ; debugMsg0(sProcName, "rWQF\nCurrDevNo=" + rWQF\nCurrDevNo)
        If rWQF\nCurrDevNo > 0
          bEnableMoveUp = #True
        EndIf
        If rWQF\nCurrDevNo <= aAud(nEditAudPtr)\nLastDev ; < grLicInfo\nMaxAudDevPerAud
          bEnableMoveDown = #True
        EndIf
        If rWQF\nCurrDevNo < grLicInfo\nMaxAudDevPerAud
          bEnableInsert = #True
        EndIf
        If rWQF\nCurrDevNo <= aAud(nEditAudPtr)\nLastDev
          bEnableRemove = #True
        EndIf
        setEnabled(\btnMoveDevUp, bEnableMoveUp)
        setEnabled(\btnMoveDevDown, bEnableMoveDown)
        setEnabled(\btnInsertDev, bEnableInsert)
        setEnabled(\btnRemoveDev, bEnableRemove)
      EndIf
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_lblDevNo_Click(Index)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  WQF_setCurrentDevInfo(Index, #True, #True)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_displayLevels()
  PROCNAMEC()
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  rWQF\bDisplayingLevelPoint = #False
  ; debugMsg(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint))
  
  With WQF
    If getVisible(\cntLevelLabels) = #False
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        setEnabled(\cboLogicalDevF[d], #True)
        setVisible(\cntDevRelLevel[d], #False)
        setVisible(\cntDevLevel[d], #True)
        If nEditAudPtr >= 0
          If aAud(nEditAudPtr)\sLogicalDev[d]
            WQF_setLevelAndPanEnabledStates(d)
          EndIf
        EndIf
      Next d
      setVisible(\cntRelLevelLabels, #False)
      setVisible(\cntLevelLabels, #True)
      WQF_setCboTracksEnabled()
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_displayRelLevels(nLevelPointType, nLevelPointTime)
  PROCNAMECA(nEditAudPtr)
  Protected d, n
  Protected sLogicalDev.s, sTracks.s
  Protected bDevPresent
  Protected bLevelSelSet, bPanSelSet
  Protected nLevelPointIndex, nItemIndex
  Protected nListIndex
  Protected nLvlPtLvlSel, nLvlPtPanSel
  
  debugMsg(sProcName, #SCS_START + ", nLevelPointType=" + decodeLevelPointType(nLevelPointType) + ", nLevelPointTime=" + nLevelPointTime + " (" + timeToStringT(nLevelPointTime) + ")")
  
  rWQF\bDisplayingLevelPoint = #True
  rWQF\nCurrLevelPointType = nLevelPointType
  rWQF\nCurrLevelPointTime = nLevelPointTime
  ; debugMsg(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", \nCurrLevelPointType=" + decodeLevelPointType(rWQF\nCurrLevelPointType) + ", \nCurrLevelPointTime=" + rWQF\nCurrLevelPointTime)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
      If nLevelPointIndex >= 0
        nLvlPtLvlSel = \nLvlPtLvlSel
        nLvlPtPanSel = \nLvlPtPanSel
        nListIndex = indexForComboBoxData(WQF\cboLevelSel, nLvlPtLvlSel, -1)
        If nListIndex >= 0
          SGS(WQF\cboLevelSel, nListIndex)
          bLevelSelSet = #True
        EndIf
        nListIndex = indexForComboBoxData(WQF\cboPanSel, nLvlPtPanSel, -1)
        If nListIndex >= 0
          SGS(WQF\cboPanSel, nListIndex)
          bPanSelSet = #True
        EndIf
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          sLogicalDev = \sLogicalDev[d]
          sTracks = \sTracks[d]
          If sLogicalDev
            bDevPresent = #True
            nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
          Else
            bDevPresent = #False
            nItemIndex = -1
          EndIf
          If bDevPresent ; added bDevPresent test 20Mar2017 11.6.0 as the following procedure was previously being called unnecessarily(?) for devices that did not exist
            debugMsg(sProcName, "calling WQF_displayRelLevelAndPanForDev(" + nLevelPointIndex + ", " + nItemIndex + ")")
            WQF_displayRelLevelAndPanForDev(nLevelPointIndex, nItemIndex)
          EndIf
        Next d
      EndIf
    EndWith
  EndIf
  
  With WQF
    If getVisible(\cntRelLevelLabels) = #False
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        setVisible(\cntDevLevel[d], #False)
        setVisible(\cntDevRelLevel[d], #True)
        setEnabled(\cboLogicalDevF[d], #False)
        setEnabled(\cboTracks[d], #False)
      Next d
      setVisible(\cntLevelLabels, #False)
      setVisible(\cntRelLevelLabels, #True)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_displayLevelAndPanForDev(d, bDevPresent)
  PROCNAMEC()
  Protected fEditFadeInLevel.f
  Protected fBVLevel.f
  Protected nSldBackColor, nSldLevelPtr, nSldPanPtr
  
;   If bDevPresent
;     debugMsg(sProcName, #SCS_START + ", d=" + d + ", bDevPresent=" + strB(bDevPresent))
;   EndIf
  
  nSldLevelPtr = WQF\sldLevel[d]
  nSldPanPtr = WQF\sldPan[d]
  SLD_setAudPtr(nSldLevelPtr, nEditAudPtr) ; Added 23Apr2024 11.10.2cc
  SLD_setAudPtr(nSldPanPtr, nEditAudPtr)   ; Added 23Apr2024 11.10.2cc
  
  With aAud(nEditAudPtr)
    SLD_setMax(nSldLevelPtr, #SCS_MAXVOLUME_SLD)
    fBVLevel = \fBVLevel[d]
    SLD_setLevel(nSldLevelPtr, fBVLevel, \fTrimFactor[d])
    SLD_setBaseLevel(nSldLevelPtr, \fBVLevel[d], \fTrimFactor[d])
    SLD_setMax(nSldPanPtr, #SCS_MAXPAN_SLD)   ; forces control to be formatted
    SLD_setValue(nSldPanPtr, panToSliderValue(\fPan[d]))
    SLD_setBaseValue(nSldPanPtr, panToSliderValue(\fPan[d]))
    nSldBackColor = SLD_getBackColor(nSldLevelPtr)
    If nSldBackColor <> #SCS_SLD_BACKCOLOR
      SLD_setBackColor(nSldLevelPtr, #SCS_SLD_BACKCOLOR)
    EndIf
    nSldBackColor = SLD_getBackColor(nSldPanPtr)
    If nSldBackColor <> #SCS_SLD_BACKCOLOR
      SLD_setBackColor(nSldPanPtr, #SCS_SLD_BACKCOLOR)
    EndIf
    ; Added 5Apr2024 11.10.2bu
    If \bDeviceSelected[d]
      ; debugMsg0(sProcName, "calling SLD_setBtnColor1(WQF\sldLevel[" + d + "], #Cyan)")
      SLD_setBtnColor1(nSldLevelPtr, #Cyan)
    Else
      SLD_setBtnColor1(nSldLevelPtr, -1)
    EndIf
    SLD_drawButton(nSldLevelPtr)
    ; End added 5Apr2024 11.10.2bu
    SGT(WQF\txtDBLevel[d], convertBVLevelToDBStringWithMinusInf(fBVLevel))
    SGT(WQF\txtPan[d], panSingleToString(\fPan[d]))
    
    If bDevPresent
      If \nAudState < #SCS_CUE_FADING_IN
        If \nFadeInTime <= 0
          fEditFadeInLevel = fBVLevel
        Else
          fEditFadeInLevel = #SCS_MINVOLUME_SINGLE
        EndIf
      Else
        fEditFadeInLevel = fBVLevel
      EndIf
      
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
        If \nFileState = #SCS_FILESTATE_OPEN
          ; debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nEditAudPtr) + ", " + d + ", " + traceLevel(fEditFadeInLevel) + ", " + formatPan(\fPan[d]) + ")")
          setLevelsAny(nEditAudPtr, d, fEditFadeInLevel, \fPan[d])
        EndIf
        ; debugMsg(sProcName, "calling WQF_fcSldLevel(" + d + ")")
        WQF_fcSldLevel(d)
        ; debugMsg(sProcName, "calling WQF_fcSldPan(" + d + ")")
        WQF_fcSldPan(d)
      EndIf
      
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_initUnusedRelLevelEtcControls()
  PROCNAMEC()
  Protected d
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If (d < \nFirstDev) Or (d > \nLastDev)
          setOwnState(WQF\chkDevInclude[d], #False)
          setOwnEnabled(WQF\chkDevInclude[d], #False)
          SGT(WQF\txtDevDBLevel[d], "")
          SGT(WQF\txtRelDBLevel[d], "")
          SGT(WQF\txtPlayDBLevel[d], "")
          SLD_setValue(WQF\sldPan[d], #SCS_PANCENTRE_SLD)
          SLD_setBaseValue(WQF\sldPan[d], #SCS_SLD_NO_BASE)
          SGT(WQF\txtPan[d], panSingleToString(#SCS_PANCENTRE_SINGLE))
          WQF_setLevelAndPanEnabledStates(d)
        EndIf
      Next d
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_displayRelLevelAndPanForDev(nLevelPointIndex, nItemIndex=-1)
  PROCNAMEC()
  Protected fItemPan.f
  Protected bEnableInclude, bItemInclude
  Protected d, n2
  Protected nFirstItem, nLastItem
  Protected fDevDBLevel.f, fPlayDBLevel.f
  
  ;   debugMsg(sProcName, #SCS_START + ", nLevelPointIndex=" + nLevelPointIndex + ", nItemIndex=" + Str(nItemIndex))
  
  If nLevelPointIndex >= 0
    With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)
      If nItemIndex = -1
        nFirstItem = 0
        nLastItem = \nPointMaxItem
      Else
        nFirstItem = nItemIndex
        nLastItem = nItemIndex
      EndIf
      
      For n2 = nFirstItem To nLastItem
        bItemInclude = grLevelPointItemDef\bItemInclude
        fItemPan = grLevelPointItemDef\fItemPan
        
        Select \nPointType
          Case #SCS_PT_STD
            bItemInclude = \aItem(n2)\bItemInclude
            bEnableInclude = #True
          Default
            ; fade-in and fade-out level points etc must have all devices included
            bItemInclude = #True
            bEnableInclude = #False
        EndSelect
        
        fItemPan = \aItem(n2)\fItemPan
        
        d = getAudDevNoForLogicalDev(nEditAudPtr, \aItem(n2)\sItemLogicalDev, \aItem(n2)\sItemTracks)
        If d >= 0
          setOwnState(WQF\chkDevInclude[d], bItemInclude)
          setOwnEnabled(WQF\chkDevInclude[d], bEnableInclude)
          If bItemInclude
            fDevDBLevel = getTrimmedDBLevel(nEditAudPtr, d)
            SGT(WQF\txtDevDBLevel[d], convertDBLevelToDBString(fDevDBLevel))
            ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + n2 + ")\fItemRelDBLevel=" + StrF(\aItem(n2)\fItemRelDBLevel,2) +
            ;                     ", \aItem(" + n2 + ")\fItemPan=" + tracePan(\aItem(n2)\fItemPan))
            SGT(WQF\txtRelDBLevel[d], convertDBLevelToDBString(\aItem(n2)\fItemRelDBLevel))
            fPlayDBLevel = fDevDBLevel + \aItem(n2)\fItemRelDBLevel
            If fPlayDBLevel > grLevels\nMaxDBLevel
              SGT(WQF\txtPlayDBLevel[d], "=[" + convertDBLevelToDBString(grLevels\nMaxDBLevel) + "]")
              ; nb tried to use SetGadgetColor() but colors ignored on a disabled String Gadget
            ElseIf fPlayDBLevel < grLevels\nMinDBLevel
              SGT(WQF\txtPlayDBLevel[d], "=[" + #SCS_INF_DBLEVEL + "]") ; -INF
            Else
              SGT(WQF\txtPlayDBLevel[d], "= " + convertDBLevelToDBString(fPlayDBLevel))
            EndIf
          Else
            SGT(WQF\txtDevDBLevel[d], "")
            SGT(WQF\txtRelDBLevel[d], "")
            SGT(WQF\txtPlayDBLevel[d], "")
            fItemPan = #SCS_PANCENTRE_SINGLE
          EndIf
          SLD_setBaseValue(WQF\sldPan[d], #SCS_SLD_NO_BASE)
          SLD_setValue(WQF\sldPan[d], panToSliderValue(fItemPan))
          SGT(WQF\txtPan[d], panSingleToString(fItemPan))
          WQF_setLevelAndPanEnabledStates(d)
        EndIf
        
      Next n2
      
    EndWith
  EndIf
  
  ;   debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_processDevSel()
  PROCNAMECA(nEditAudPtr)
  Protected nLevelPointIndex, nLevelPointType, nLevelPointTime
  Protected nDevNo
  Protected bDevPresent
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      rWQF\sUndoDescKeyPart = Trim(GGT(WQF\cboDevSel)) + " "
      nLevelPointIndex = getCurrentItemData(WQF\cboDevSel, -1)
      If nLevelPointIndex = -1
        debugMsg(sProcName, "calling WQF_displayLevels()")
        WQF_displayLevels()
      Else
        nLevelPointType = \aPoint(nLevelPointIndex)\nPointType
        nLevelPointTime = \aPoint(nLevelPointIndex)\nPointTime
        grMG2\nLastTimeMark = nLevelPointTime
        debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(nLevelPointType) + ", " + nLevelPointTime + ")")
        WQF_displayRelLevels(nLevelPointType, nLevelPointTime)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_cboDevSel_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling WQF_processDevSel()")
  WQF_processDevSel()
  
  clearCtrlHoldLP() ; Added 11Feb2022 11.9.0
  
  debugMsg(sProcName, "calling drawGraph(@grMG2)")
  drawGraph(@grMG2)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_displayLevelPointInfo(nPointType, nPointTime=0)
  PROCNAMEC()
  Protected bChangeDisplay
  Protected nLevelPointIndex
  Protected nReqdLevelPointTime
  Protected nListIndex
  
  ; debugMsg(sProcName, #SCS_START + ", nPointType=" + decodeLevelPointType(nPointType) + ", nPointTime=" + nPointTime)
  
  With rWQF
    If nEditAudPtr >= 0
      nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, nPointType, nPointTime)
      ; debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex)
      If nLevelPointIndex >= 0
        nReqdLevelPointTime = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime
      Else
        ; added 30Oct2018 11.8.0aj
        ; got here in a test when called from WQF_mnuSameAs(), and needed to refresh the graph to show the change made by this menu item
        ; (previously the comment was 'shouldn't get here')
        redrawGraphAfterMouseChange(@grMG2)
        ; end added 30Oct2018 11.8.0aj
        ProcedureReturn
      EndIf
      ; debugMsg(sProcName, "\bDisplayingLevelPoint=" + strB(\bDisplayingLevelPoint) + ", \nCurrLevelPointTime=" + \nCurrLevelPointTime + ", nReqdLevelPointTime=" + nReqdLevelPointTime)
      If GGS(WQF\cboDevSel) > 0
        ; Only change the selected display if it is NOT currently set to 'Audio Devices'
        ; This test added 30Dec2023 11.10.0dt as I (Mike) found it annoying that on dragging a start or other marker on the audio graph, the 'device' combobox would change to the type of marker (eg Start) being moved.
        If \bDisplayingLevelPoint = #False
          bChangeDisplay = #True
        Else
          If \nCurrLevelPointTime <> nReqdLevelPointTime
            bChangeDisplay = #True
          EndIf
        EndIf
      EndIf
    EndIf
    
    If bChangeDisplay
      nLevelPointIndex = getLevelPointIndexForTime(nEditAudPtr, nReqdLevelPointTime)
      nListIndex = indexForComboBoxData(WQF\cboDevSel, nLevelPointIndex, 0)
      If nListIndex >= 0
        SGS(WQF\cboDevSel, nListIndex)
        ; debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(nPointType) + ", " + timeToStringT(nReqdLevelPointTime) + ")")
        WQF_displayRelLevels(nPointType, nReqdLevelPointTime)
        drawGraph(@grMG2)
      EndIf
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_displayDevInfo()
  PROCNAMECA(nEditAudPtr)
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If getCurrentItemData(WQF\cboDevSel) <> -1
    nListIndex = indexForComboBoxData(WQF\cboDevSel, -1, 0)
    SGS(WQF\cboDevSel, nListIndex)
    WQF_processDevSel()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_mnuViewOnCues()
  PROCNAMEC()
    Protected nResult, Event, i, j , k, sCueMarkers.s, nFlags
    Protected sLinkCue.s, sActivationCue.s, sCueMarkerName.s, sPosition.s, sAssigned.s, sAllCues.s
    Protected sCueMarkerFiles.s, sOK.s
    Protected nTotalOnCueMarkers, nTotalAssigned, nTotalCueFiles
    Protected n, n2, nCueMarkerId, nCueMarkerIndex, nOCMCuePtr
    Protected nListGadget, nListGadgetAll, nListGadgetCueFiles
    Protected nTextGadget, nTextGadgetAll, nTextGadgetCueFiles
    
    nFlags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered
    
    ; Set the Language Specification
    sLinkCue = Lang("Common", "Cue")
    sActivationCue = Lang("Common", "Activation")+" "+Lang("Common", "Cue")
    sCueMarkerName = Lang("WEM", "Name")
    sPosition = Lang("WEM", "Position")
    sAssigned = Lang("ViewMarkerCues", "cmAssigned")
    sAllCues = Lang("ViewMarkerCues", "cmAllCues")
    sCueMarkerFiles = Lang("ViewMarkerCues", "cmCueFiles")
    sOK = Lang("Btns", "OK")
    
    ; Get the Current Totals
    nTotalAssigned = gnMaxOCMMatrixItem + 1
    nTotalOnCueMarkers = gnMaxCueMarkerInfo + 1
    nTotalCueFiles = gnMaxCueMarkerFile + 1
    ; Build Heading Strings
    sAssigned + " - Total Assigned: " + nTotalAssigned
    sAllCues + " - Total On Cue Markers: " + nTotalOnCueMarkers
    sCueMarkerFiles + " - Total Cue Files Used: " + nTotalCueFiles
    
    nResult = OpenWindow(#PB_Any, 0, 0, 620, 600, Lang("Menu", "mnuWQFViewOnCues"), nFlags, WindowID(#WED))
    If nResult   
      nTextGadget = TextGadget (#PB_Any,  12,  10, 330, 20, sAssigned)
      nListGadget = ListIconGadget(#PB_Any, 10, 25, 600, 175, sActivationCue, 100,  #PB_ListIcon_GridLines)
      AddGadgetColumn(nListGadget, 1, sCueMarkerName, 200)
      AddGadgetColumn(nListGadget, 2, sPosition, 90)
      AddGadgetColumn(nListGadget, 3, sLinkCue, 100)
      For n = 0 To gnMaxOCMMatrixItem
        nCueMarkerId = gaOCMMatrix(n)\nCueMarkerId
        nOCMCuePtr = gaOCMMatrix(n)\nOCMCuePtr
        nCueMarkerIndex = -1
        For n2 = 0 To gnMaxCueMarkerInfo
          With gaCueMarkerInfo(n2)
            If \nCueMarkerId = nCueMarkerId
              nCueMarkerIndex = n2
              AddGadgetItem(nListGadget, -1, getAudLabel(\nHostAudPtr) + Chr(10) + \sCueMarkerName + Chr(10) + timeToString(\nCueMarkerPosition) + Chr(10) + aCue(nOCMCuePtr)\sCue)
            EndIf
          EndWith
        Next n2
      Next n
      
      nTextGadgetAll = TextGadget (#PB_Any, 12, 205, 580, 15, sAllCues)
      nListGadgetAll = ListIconGadget(#PB_Any, 10, 220, 600, 175, sActivationCue, 100,  #PB_ListIcon_GridLines)
      AddGadgetColumn(nListGadgetAll, 1, sCueMarkerName, 200)
      AddGadgetColumn(nListGadgetAll, 2, sPosition, 90)
      
      ; Step Through Cues / Sub / Aud
      For i = 1 To gnLastCue
        With aCue(i)
          j = aCue(i)\nFirstSubIndex 
          While j >= 0
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              For n = 0 To aAud(k)\nMaxCueMarker
                sCueMarkers = getAudLabel(k) + Chr(10) +
                              aAud(k)\aCueMarker(n)\sCueMarkerName + Chr(10) +
                              timeToString(aAud(k)\aCueMarker(n)\nCueMarkerPosition)
                AddGadgetItem(nListGadgetAll, -1, sCueMarkers)
              Next n
              k = aAud(k)\nNextAudIndex
            Wend
            j = aSub(j)\nNextSubIndex
          Wend
        EndWith
      Next i
      
      ; Add a Listing for all the Cue Markers Files
      nTextGadgetCueFiles = TextGadget(#PB_Any, 12, 400, 580, 20, sCueMarkerFiles)
      nListGadgetCueFiles = ListIconGadget(#PB_Any, 10, 415, 600, 145, sActivationCue, 100, #PB_ListIcon_GridLines)
      AddGadgetColumn(nListGadgetCueFiles, 1, Lang("ViewMarkerCues", "cmFileMarker"), 490)
      ; Add File Names to the Gadget List
      For n = 0 To gnMaxCueMarkerFile
        AddGadgetItem(nListGadgetCueFiles, -1, getAudLabel(gaCueMarkerFile(n)\nAudPtr) + Chr(10) + gaCueMarkerFile(n)\sFileName)
      Next n
      
      ; Add an OK button to close down this Window
      WQF\btnVCMOK = scsButtonGadget(250, 570, 100, gnBtnHeight, sOK, #PB_Button_Default,"btnVCMOK")
      
      ; Handle the Window Event
      Repeat 
        Event = WaitWindowEvent()
        Select Event
          Case #PB_Event_CloseWindow
            CloseWindow(nResult)
            Break
          Case #PB_Event_Gadget
            ; Debug sProcName+" EventGadget()=G"+EventGadget()
            Select EventGadget()
              Case  WQF\btnVCMOK
                CloseWindow(nResult)
                Break
            EndSelect
        EndSelect
      ForEver
    EndIf
  ;debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_mnuSetCueMarkerPosition()
  setCueMarkerPosition(@grMG2)
EndProcedure

Procedure WQF_mnuSetPos()
  PROCNAMECA(nEditAudPtr)
  Protected nPointType, sPointDesc.s
  Protected nLevelPointIndex
  Protected nPointTime, nMinTime, nMaxTime
  Protected sNewTime.s, nNewTime
  Protected sRequestMsg.s, sMsg.s
  Protected sLevelPointTime.s
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, grMG2\nMouseDownLevelPointId)
      debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex)
      If nLevelPointIndex >= 0
        
        nPointTime = \aPoint(nLevelPointIndex)\nPointTime
        nPointType = \aPoint(nLevelPointIndex)\nPointType
        sPointDesc = \aPoint(nLevelPointIndex)\sPointDesc
        sRequestMsg = LangPars("WQF", "NewPos", sPointDesc)
        
        sNewTime = ttszt(nPointTime)
        While #True
          sNewTime = Trim(InputRequester(Lang("Menu", "mnuWQFSetPos"), sRequestMsg, sNewTime))
          If Len(sNewTime) > 0
            ; nb if sNewTime is blank the user 'cancelled' input request
            
            sLevelPointTime = Lang("WQF", "LevelPointTime")
            
            If validateTimeFieldT(sNewTime, sLevelPointTime, #False, #False) = #False
              Continue  ; try again
            EndIf
            
            nNewTime = stringToTime(sNewTime)
            nMinTime = getMinTimeForPoint(nEditAudPtr, nPointTime)
            nMaxTime = getMaxTimeForPoint(nEditAudPtr, nPointTime)
            
            If (nNewTime < nMinTime) Or (nNewTime > nMaxTime)
              sMsg = LangPars("Errors", "MustBeBetween", sLevelPointTime + " (" + ttszt(nNewTime) + ")", ttszt(nMinTime), ttszt(nMaxTime))
              debugMsg(sProcName, sMsg)
              scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
              Continue  ; try again
            EndIf
            
            If nNewTime <> nPointTime
              u = preChangeAudL(nPointTime, sLevelPointTime + " (" + nLevelPointIndex + ")", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
              \aPoint(nLevelPointIndex)\nPointTime = nNewTime
              Select nPointType
                Case #SCS_PT_FADE_IN
                  \nFadeInTime = nNewTime - \nAbsStartAt
                  SGT(WQF\txtFadeInTime, timeToStringT(\nFadeInTime))
                Case #SCS_PT_FADE_OUT
                  \nFadeOutTime = \nAbsEndAt - nNewTime
                  SGT(WQF\txtFadeOutTime, timeToStringT(\nFadeOutTime))
              EndSelect
              setDerivedLevelPointInfo2(nEditAudPtr)
              postChangeAudLN(u, nNewTime)
              
              rWQF\nCurrLevelPointTime = nNewTime
              WQF_populateCboDevSel()
              If rWQF\bDisplayingLevelPoint
                debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(nPointType) + ", " + timeToStringT(rWQF\nCurrLevelPointTime) + ")")
                WQF_displayRelLevels(nPointType, rWQF\nCurrLevelPointTime)
              EndIf
              
              WQF_fcLevelPointInfo()
              drawGraph(@grMG2)
              
            EndIf ; EndIf nNewTime <> nPointTime
            
          EndIf ; EndIf Len(sNewTime) > 0
          Break
        Wend
        
      EndIf ; EndIf nLevelPointIndex >= 0
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_mnuRemoveLevelPoint()
  PROCNAMECA(nEditAudPtr)
  Protected nPointType, sPointDesc.s
  Protected nLevelPointIndex
  Protected nOtherIndex, nOtherItem
  Protected n, n2
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, grMG2\nMouseDownLevelPointId)
      debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex)
      If nLevelPointIndex >= 0
        sPointDesc = \aPoint(nLevelPointIndex)\sPointDesc
        u = preChangeAudL(\nMaxLevelPoint, LangPars("WQF", "Remove", sPointDesc), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
        nPointType = \aPoint(nLevelPointIndex)\nPointType
        For n = (nLevelPointIndex+1) To \nMaxLevelPoint
          \aPoint(n-1) = \aPoint(n)
        Next n
        \nMaxLevelPoint - 1
        Select nPointType
          Case #SCS_PT_FADE_IN
            SGT(WQF\txtFadeInTime,"")
            \nFadeInTime = 0
            \nCurrFadeInTime = \nFadeInTime
            WQF_setClearState()
            nOtherIndex = getLevelPointIndexForType(nEditAudPtr, #SCS_PT_START)
            If nOtherIndex >= 0
              For nOtherItem = 0 To \aPoint(nOtherIndex)\nPointMaxItem
                \aPoint(nOtherIndex)\aItem(nOtherItem)\fItemRelDBLevel = 0.0
              Next nOtherItem
            EndIf
            
          Case #SCS_PT_FADE_OUT
            SGT(WQF\txtFadeOutTime,"")
            \nFadeOutTime = 0
            \nCurrFadeOutTime = \nFadeOutTime
            WQF_setClearState()
            nOtherIndex = getLevelPointIndexForType(nEditAudPtr, #SCS_PT_END)
            If nOtherIndex >= 0
              For nOtherItem = 0 To \aPoint(nOtherIndex)\nPointMaxItem
                \aPoint(nOtherIndex)\aItem(nOtherItem)\fItemRelDBLevel = 0.0
              Next nOtherItem
            EndIf
            
        EndSelect
        postChangeAudLN(u, \nMaxLevelPoint)
        
        ; check if next level point is 'usable', and if so then reposition to that level point, else go to 'audio device'
        nPointType = \aPoint(nLevelPointIndex)\nPointType
        Select nPointType
          Case #SCS_PT_START, #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT, #SCS_PT_END
            rWQF\bDisplayingLevelPoint = #True
            rWQF\nCurrLevelPointTime = \aPoint(nLevelPointIndex)\nPointTime
            rWQF\nCurrLevelPointType = \aPoint(nLevelPointIndex)\nPointType
            ; debugMsg0(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", \nCurrLevelPointType=" + decodeLevelPointType(rWQF\nCurrLevelPointType) + ", \nCurrLevelPointTime=" + rWQF\nCurrLevelPointTime)
            WQF_populateCboDevSel()
            debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(nPointType) + ", " + timeToStringT(rWQF\nCurrLevelPointTime) + ")")
            WQF_displayRelLevels(nPointType, rWQF\nCurrLevelPointTime)
            
          Default
            rWQF\bDisplayingLevelPoint = #False
            ; debugMsg0(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint))
            WQF_populateCboDevSel()
            WQF_displayLevelAndPanForDev(rWQF\nCurrDevNo, #True)
            
        EndSelect
        
        WQF_fcLevelPointInfo()
        
        debugMsg(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", nLevelPointIndex=" + nLevelPointIndex +
                            ", nPointType=" + decodeLevelPointType(nPointType) + ", rWQF\nCurrLevelPointTime=" + timeToStringT(rWQF\nCurrLevelPointTime))
        drawGraph(@grMG2)
        
        loadGridRow(nEditCuePtr)
        PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
        
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_mnuSameAs(bNextLevelPoint, nLevelOrPan)
  PROCNAMECA(nEditAudPtr)
  Protected nPointTime, nPointType
  Protected nLevelPointIndex, nItemIndex
  Protected nOtherIndex
  Protected u
  Protected sSameAs.s, sMsg.s
  Protected nResponse
  Protected nDevNo, sLogicalDev.s, sTracks.s
  
  debugMsg(sProcName, #SCS_START + ", bNextLevelPoint=" + strB(bNextLevelPoint) + ", nLevelOrPan=" + nLevelOrPan)
  
  If (nEditAudPtr >= 0) And (rWQF\nCurrDevNo >= 0)
    With aAud(nEditAudPtr)
      nLevelPointIndex = getLevelPointIndexForId(nEditAudPtr, grMG2\nMouseDownLevelPointId)
      debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex)
      If nLevelPointIndex >= 0
        nPointTime = \aPoint(nLevelPointIndex)\nPointTime
        nPointType = \aPoint(nLevelPointIndex)\nPointType
        If bNextLevelPoint
          nOtherIndex = getNextLevelPointIndex(nEditAudPtr, nPointTime)
          Select nLevelOrPan
            Case #SCS_GRAPH_MARKER_LEVEL
              sSameAs = Lang("Menu", "mnuWQFSameLvlAsNext")
            Case #SCS_GRAPH_MARKER_PAN
              sSameAs = Lang("Menu", "mnuWQFSamePanAsNext")
            Default
              sSameAs = Lang("Menu", "mnuWQFSameAsNext")
          EndSelect
        Else
          nOtherIndex = getPrevLevelPointIndex(nEditAudPtr, nPointTime)
          Select nLevelOrPan
            Case #SCS_GRAPH_MARKER_LEVEL
              sSameAs = Lang("Menu", "mnuWQFSameLvlAsPrev")
            Case #SCS_GRAPH_MARKER_PAN
              sSameAs = Lang("Menu", "mnuWQFSamePanAsPrev")
            Default
              sSameAs = Lang("Menu", "mnuWQFSameAsPrev")
          EndSelect
        EndIf
        debugMsg(sProcName, "nOtherIndex=" + Str(nOtherIndex))
        If nOtherIndex >= 0
          If \aPoint(nLevelPointIndex)\nPointMaxItem <> \aPoint(nOtherIndex)\nPointMaxItem
            ; no language translation for the following as it should not happen!
            sMsg = "Level Points have different numbers of items so cannot apply this request." + Chr(10) + Chr(10)
            sMsg + "Please contact SCS Support"
            scsMessageRequester(sSameAs, sMsg, #PB_MessageRequester_Error)
          Else
            ; apply this request
            u = preChangeAudL(#False, sSameAs + "(" + nLevelPointIndex + ")", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
            ; For nItemIndex = 0 To \aPoint(nLevelPointIndex)\nPointMaxItem
            nDevNo = rWQF\nCurrDevNo
            sLogicalDev = aAud(nEditAudPtr)\sLogicalDev[nDevNo]
            sTracks = aAud(nEditAudPtr)\sTracks[nDevNo]
            nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
            If nItemIndex >= 0
              Select nLevelOrPan
                Case #SCS_GRAPH_MARKER_LEVEL
                  \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel = \aPoint(nOtherIndex)\aItem(nItemIndex)\fItemRelDBLevel
                  ; debugMsg0(sProcName, "\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemRelDBLevel=" + convertDBLevelToDBString(\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel))
                  \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude = \aPoint(nOtherIndex)\aItem(nItemIndex)\bItemInclude
                Case #SCS_GRAPH_MARKER_PAN
                  \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan = \aPoint(nOtherIndex)\aItem(nItemIndex)\fItemPan
                  \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude = \aPoint(nOtherIndex)\aItem(nItemIndex)\bItemInclude
                Default ; both level and pan
                  \aPoint(nLevelPointIndex)\aItem(nItemIndex) = \aPoint(nOtherIndex)\aItem(nItemIndex)
              EndSelect
              Select nPointType
                Case #SCS_PT_FADE_IN, #SCS_PT_FADE_OUT
                  ; force \bItemInclude = #True for point types that require all devices to be included
                  \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude = #True
              EndSelect
            EndIf
            ; Next nItemIndex
            postChangeAudLN(u, #True)
            redrawGraphAfterMouseChange(@grMG2) ; Added 4Apr2025 11.10.8ax
            
            WQF_displayLevelPointInfo(nPointType)
            
          EndIf
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_mnuShowLvlCurvesSel()
  PROCNAMEC()
  
  With grEditorPrefs
    If \bEditShowLvlCurvesSel
      \bEditShowLvlCurvesSel = #False
    Else
      \bEditShowLvlCurvesSel = #True
    EndIf
    drawGraph(@grMG2)
  EndWith
EndProcedure

Procedure WQF_mnuShowPanCurvesSel()
  PROCNAMEC()
  
  With grEditorPrefs
    If \bEditShowPanCurvesSel
      \bEditShowPanCurvesSel = #False
    Else
      \bEditShowPanCurvesSel = #True
    EndIf
    drawGraph(@grMG2)
  EndWith
EndProcedure

Procedure WQF_mnuShowLvlCurvesOther()
  PROCNAMEC()
  
  With grEditorPrefs
    If \bEditShowLvlCurvesOther
      \bEditShowLvlCurvesOther = #False
    Else
      \bEditShowLvlCurvesOther = #True
    EndIf
    drawGraph(@grMG2)
  EndWith
EndProcedure

Procedure WQF_mnuShowPanCurvesOther()
  PROCNAMEC()
  
  With grEditorPrefs
    If \bEditShowPanCurvesOther
      \bEditShowPanCurvesOther = #False
    Else
      \bEditShowPanCurvesOther = #True
    EndIf
    drawGraph(@grMG2)
  EndWith
EndProcedure

Procedure WQF_mnuSetStartAt()
  PROCNAMECA(nEditAudPtr)
  Protected nStartTime, sHoldStartAt.s
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If getEnabled(WQF\txtStartAt)
        sHoldStartAt = GGT(WQF\txtStartAt)
        nStartTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        debugMsg(sProcName, "grMG2\nMouseDownStartX=" + grMG2\nMouseDownStartX + ", nStartTime=" + nStartTime + " (" + timeToStringT(nStartTime) + ")")
        SGT(WQF\txtStartAt, timeToString(nStartTime))
        If WQF_txtStartAt_Validate() = #False
          SGT(WQF\txtStartAt, sHoldStartAt)
          loadGridRow(nEditCuePtr)
          PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_mnuSetEndAt()
  PROCNAMECA(nEditAudPtr)
  Protected nEndTime, sHoldEndAt.s
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If getEnabled(WQF\txtEndAt)
        sHoldEndAt = GGT(WQF\txtEndAt)
        nEndTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        debugMsg(sProcName, "grMG2\nMouseDownStartX=" + grMG2\nMouseDownStartX + ", nEndTime=" + nEndTime + " (" + timeToStringT(nEndTime) + ")")
        SGT(WQF\txtEndAt, timeToString(nEndTime))
        If WQF_txtEndAt_Validate() = #False
          SGT(WQF\txtEndAt, sHoldEndAt)
          loadGridRow(nEditCuePtr)
          PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_mnuSetLoopStart()
  PROCNAMECA(nEditAudPtr)
  Protected nLoopStartTime, sHoldLoopStart.s
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If getEnabled(WQF\txtLoopStart)
        sHoldLoopStart = GGT(WQF\txtLoopStart)
        nLoopStartTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        debugMsg(sProcName, "grMG2\nMouseDownStartX=" + grMG2\nMouseDownStartX + ", nLoopStartTime=" + nLoopStartTime + " (" + timeToStringT(nLoopStartTime) + ")")
        SGT(WQF\txtLoopStart, timeToString(nLoopStartTime))
        If WQF_txtLoopStart_Validate() = #False
          SGT(WQF\txtLoopStart, sHoldLoopStart)
          loadGridRow(nEditCuePtr)
          PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_mnuSetLoopEnd()
  PROCNAMECA(nEditAudPtr)
  Protected nLoopEndTime, sHoldLoopEnd.s
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If getEnabled(WQF\txtLoopEnd)
        sHoldLoopEnd = GGT(WQF\txtLoopEnd)
        nLoopEndTime = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        debugMsg(sProcName, "grMG2\nMouseDownStartX=" + grMG2\nMouseDownStartX + ", nLoopEndTime=" + nLoopEndTime + " (" + timeToStringT(nLoopEndTime) + ")")
        SGT(WQF\txtLoopEnd, timeToString(nLoopEndTime))
        If WQF_txtLoopEnd_Validate() = #False
          SGT(WQF\txtLoopEnd, sHoldLoopEnd)
          loadGridRow(nEditCuePtr)
          PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_cboLevelSel_Click()
  PROCNAMEC()
  Protected u
  Protected nOldLvlSel, nNewLvlSel
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nOldLvlSel = \nLvlPtLvlSel
      nNewLvlSel = getCurrentItemData(WQF\cboLevelSel)
      If nNewLvlSel <> nOldLvlSel
        ; nb use #True/#False in pre/postChange, not nOld/nNewLvlSel so that 'undo' is not cancelled on reinstating LevelSel
        ; this is necessary because relative level fields may have been changed and we need 'undo' to be available
        u = preChangeAudL(#True, Lang("WQF","RelLevelSel"), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
        \nLvlPtLvlSel = nNewLvlSel
        Select nNewLvlSel
          Case #SCS_LVLSEL_SYNC
            propagateLvlPtLevelAndPanSelection(nEditAudPtr, -1, #True, #False)
          Case #SCS_LVLSEL_LINK
            setLinkRelLevels(nEditAudPtr, -1)
        EndSelect
        postChangeAudLN(u,#False)
        debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(rWQF\nCurrLevelPointType) + ", " + timeToStringT(rWQF\nCurrLevelPointTime) + ")")
        WQF_displayRelLevels(rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
        drawGraph(@grMG2)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_cboPanSel_Click()
  PROCNAMEC()
  Protected u
  Protected nOldPanSel, nNewPanSel
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nOldPanSel = \nLvlPtPanSel
      nNewPanSel = getCurrentItemData(WQF\cboPanSel)
      If nNewPanSel <> nOldPanSel
        ; nb use #True/#False in pre/postChange, not nOld/nNewPanSel so that 'undo' is not cancelled on reinstating PanSel
        ; this is necessary because pan settings may have been changed and we need 'undo' to be available
        u = preChangeAudL(#True, Lang("WQF","PanSel"), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
        \nLvlPtPanSel = nNewPanSel
        Select nNewPanSel
          Case #SCS_PANSEL_USEAUDDEV
            debugMsg(sProcName, "calling setLvlPtPansAtAudDevPan(" + getAudLabel(nEditAudPtr) + ")")
            setLvlPtPansAtAudDevPan(nEditAudPtr)
          Case #SCS_PANSEL_SYNC
            debugMsg(sProcName, "calling propagateLvlPtLevelAndPanSelection(" + getAudLabel(nEditAudPtr) + ", -1, #False, #True)")
            propagateLvlPtLevelAndPanSelection(nEditAudPtr, -1, #False, #True)
        EndSelect
        postChangeAudLN(u,#False)
        debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(rWQF\nCurrLevelPointType) + ", " + timeToStringT(rWQF\nCurrLevelPointTime) + ")")
        WQF_displayRelLevels(rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
        drawGraph(@grMG2)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_fcLevelPointInfo()
  PROCNAMECA(nEditAudPtr)
  Protected bEnableLoopAdd, bEnableLoopDel, nLevelPointIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\bAudFileLoopsAvailable
    bEnableLoopAdd = #True
    
    If nEditAudPtr >= 0
      With aAud(nEditAudPtr)
        For nLevelPointIndex = 0 To \nMaxLevelPoint
          If \aPoint(nLevelPointIndex)\nPointType = #SCS_PT_STD
            bEnableLoopAdd = #False
            Break
          EndIf
        Next nLevelPointIndex
        
        ; added 2Feb2020 11.8.2.2af (also split bEnableLoops into bEnableLoopAdd and bEnableLoopDel)
        If \nMaxLoopInfo >= 0
          bEnableLoopDel = #True
        EndIf
        ; end added 2Feb2020 11.8.2.2af
        
      EndWith
    EndIf
  EndIf
  
  setEnabled(WQF\btnLoopAdd, bEnableLoopAdd)
  setEnabled(WQF\btnLoopDel, bEnableLoopDel)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_txtRelDBLevel_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nLevelPointIndex, nItemIndex
  Protected sReqdDBLevel.s
  Protected fReqdRelDBLevel.f
  Protected fCurrRelDBLevel.f
  Protected fRelDBLevelChangeExt.f
  Protected nLvlPtLvlSel
  Static sRelLevel.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If bStaticLoaded = #False
    sRelLevel = Lang("WQF", "RelLevel")
    bStaticLoaded = #True
  EndIf
  
  sReqdDBLevel = Trim(GGT(WQF\txtRelDBLevel[Index]))
  If validateDbChangeField(sReqdDBLevel, sRelLevel) = #False
    ProcedureReturn #False
  EndIf
  
  fReqdRelDBLevel = convertDBStringToDBLevel(sReqdDBLevel)
  sReqdDBLevel = convertDBLevelToDBString(fReqdRelDBLevel) ; reformat if necessary
  
  If GGT(WQF\txtRelDBLevel[Index]) <> sReqdDBLevel
    SGT(WQF\txtRelDBLevel[Index], sReqdDBLevel)
    ; debugMsg(sProcName, "WQF\txtRelDBLevel[" + Index + "]=" + GGT(WQF\txtRelDBLevel[Index]))
  EndIf
  
  With aAud(nEditAudPtr)
    nLevelPointIndex = getLevelPointIndexForType(nEditAudPtr, rWQF\nCurrLevelPointType, rWQF\nCurrLevelPointTime)
    nItemIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, \sLogicalDev[Index], \sTracks[Index])
    nLvlPtLvlSel = \nLvlPtLvlSel
  EndWith
  
  If (nLevelPointIndex >= 0) And (nItemIndex >= 0)
    With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)
      fCurrRelDBLevel = \aItem(nItemIndex)\fItemRelDBLevel
      debugMsg(sProcName, "fCurrRelDBLevel=" + StrF(fCurrRelDBLevel,2) + ", fReqdRelDBLevel=" + StrF(fReqdRelDBLevel,2) + ", \nPointLvlSel=" + decodeLvlPtLvlSel(nLvlPtLvlSel))
      If fReqdRelDBLevel <> fCurrRelDBLevel
        u = preChangeAudF(fCurrRelDBLevel, rWQF\sUndoDescKeyPart + sRelLevel, -5, #SCS_UNDO_ACTION_CHANGE, Index)
        Select nLvlPtLvlSel
          Case #SCS_LVLSEL_INDIV
            debugMsg(sProcName, "#SCS_LVLSEL_INDIV: nItemIndex=" + nItemIndex)
            \aItem(nItemIndex)\fItemRelDBLevel = fReqdRelDBLevel
            ; debugMsg0(sProcName, "\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemRelDBLevel=" + convertDBLevelToDBString(\aItem(nItemIndex)\fItemRelDBLevel))
            debugMsg(sProcName, "\aItem(" + nItemIndex + ")\fItemRelDBLevel=" + formatLevel(\aItem(nItemIndex)\fItemRelDBLevel))
            WQF_displayRelLevelAndPanForDev(nLevelPointIndex, nItemIndex)
            debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(nEditAudPtr) + ")")
            listLevelPoints(nEditAudPtr)
            
          Case #SCS_LVLSEL_SYNC
            setRelLevelsForSync(nEditAudPtr, nLevelPointIndex, fReqdRelDBLevel)
            WQF_displayRelLevelAndPanForDev(nLevelPointIndex)
            
          Case #SCS_LVLSEL_LINK
            fRelDBLevelChangeExt = fReqdRelDBLevel - fCurrRelDBLevel
            adjustRelLevelsForLink(nEditAudPtr, nLevelPointIndex, fRelDBLevelChangeExt)
            WQF_displayRelLevelAndPanForDev(nLevelPointIndex)
            
        EndSelect
        postChangeAudFN(u, fReqdRelDBLevel, -5, Index)
      EndIf
      If Index = rWQF\nCurrDevNo
        debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WQF_saveOrSetDisplayInfo(nSaveOrSetDisplayInfo)
  PROCNAMECA(nEditAudPtr)
  Protected rSaveOrSetDef.tySaveOrSet
  Static rSaveOrSet.tySaveOrSet
  Protected nReqdDevNo
  Protected nLevelPointIndex
  Protected nPositionSliderMin, nPositionSliderMax
  
  With rSaveOrSet
    Select nSaveOrSetDisplayInfo
      Case #SCS_SAVEORSET_SAVE  ; SAVE
        sProcName + "[Save]"
        rSaveOrSet = rSaveOrSetDef
        \nAudPtr = nEditAudPtr
        If nEditAudPtr >= 0
          If rWQF\nCurrDevNo >= 0
            \sLogicalDev = aAud(nEditAudPtr)\sLogicalDev[rWQF\nCurrDevNo]
            \sTracks = aAud(nEditAudPtr)\sTracks[rWQF\nCurrDevNo]
          EndIf
          \bDisplayingLevelPoint = rWQF\bDisplayingLevelPoint
          \nLevelPointType = rWQF\nCurrLevelPointType
          \nLevelPointTime = rWQF\nCurrLevelPointTime
        EndIf
        \nZoomValue = GGS(WQF\trbZoom)
        \nPosition = SLD_getValue(WQF\sldPosition)
        
      Case #SCS_SAVEORSET_SET   ; SET
        sProcName + "[Set]"
        While #True ; dummy loop
          If \nAudPtr <> nEditAudPtr
            Break
          EndIf
          
          ; all tests passed - now set display info
          nReqdDevNo = getAudDevNoForLogicalDev(nEditAudPtr, \sLogicalDev, \sTracks)
          If nReqdDevNo < 0
            nReqdDevNo = 0
          EndIf
          debugMsg(sProcName, "calling WQF_setCurrentDevInfo(" + nReqdDevNo + ", #True, #True)")
          WQF_setCurrentDevInfo(nReqdDevNo, #True, #True)
          If \bDisplayingLevelPoint
            nLevelPointIndex = getLevelPointIndexForType(\nAudPtr, \nLevelPointType, \nLevelPointTime)
            If nLevelPointIndex >= 0
              ; level point info is still valid after undo/redo
              debugMsg(sProcName, "calling WQF_displayRelLevels(" + decodeLevelPointType(\nLevelPointType) + ", " + timeToStringT(\nLevelPointTime) + ")")
              WQF_displayRelLevels(\nLevelPointType, \nLevelPointTime)
            EndIf
          EndIf
          If IsGadget(WQF\trbZoom)
            debugMsg(sProcName, "calling SGS(WQF\trbZoom, " + \nZoomValue + ")")
            SGS(WQF\trbZoom, \nZoomValue)
            debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom))
            debugMsg(sProcName, "calling WQF_processZoom(#True)")
            WQF_processZoom(#True)
          EndIf
          nPositionSliderMin = SLD_getMin(WQF\sldPosition)
          nPositionSliderMax = SLD_getMax(WQF\sldPosition)
          If (\nPosition >= nPositionSliderMin) And (\nPosition < nPositionSliderMax)
            debugMsg(sProcName, "calling SLD_setValue(WQF\sldPosition, " + \nPosition + ", #True)")
            SLD_setValue(WQF\sldPosition, \nPosition, #True)
            WQF_processPositionChange(\nPosition)
          EndIf
          
          Break
        Wend
    EndSelect
  EndWith
EndProcedure

Procedure WQF_adjustAllLevels(nDirection)
  PROCNAMECA(nEditAudPtr)
  Protected fIncDecDBLevelDelta.f, fIncDecDBLevel.f, fNewDBLevel.f, fNewLevel.f
  Protected d
  Protected u
  Protected nLevelPointIndex
  Protected bLevelChanged
  
  debugMsg(sProcName, #SCS_START + ", nDirection=" + nDirection)
  
  If rWQF\bCallSetOrigDBLevels
    WQF_setOrigDBLevels()
    rWQF\bCallSetOrigDBLevels = #False
  EndIf
  
  rWQF\nAdjLevelNetInc + nDirection
  fIncDecDBLevelDelta = ValF(grGeneralOptions\sDBIncrement)
  fIncDecDBLevel = fIncDecDBLevelDelta * rWQF\nAdjLevelNetInc
  debugMsg(sProcName, "rWQF\nAdjLevelNetInc=" + rWQF\nAdjLevelNetInc + ", fIncDecDBLevelDelta=" + StrF(fIncDecDBLevelDelta,2) + ", fIncDecDBLevel=" + StrF(fIncDecDBLevel,2))
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudL(bLevelChanged, "Levels")
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \sLogicalDev[d]
          ; debugMsg(sProcName, "\sLogicalDev[" + d + "]=" + \sLogicalDev[d] + ", rWQF\fOrigDBLevel[" + d + "]=" + StrF(rWQF\fOrigDBLevel[d],2))
          If rWQF\fOrigDBLevel[d] > grLevels\nMinDBLevel
            fNewDBLevel = rWQF\fOrigDBLevel[d] + fIncDecDBLevel
            fNewLevel = convertDBLevelToBVLevel(fNewDBLevel)
            debugMsg(sProcName, "rWQF\fOrigDBLevel[d]=" + StrF(rWQF\fOrigDBLevel[d],2) + ", fNewDBLevel=" + StrF(fNewDBLevel,2) + ", fNewLevel=" + traceLevel(fNewLevel))
            If fNewLevel <= grLevels\fMinBVLevel
              fNewLevel = #SCS_MINVOLUME_SINGLE
              debugMsg(sProcName, "grLevels\fMinBVLevel=" + traceLevel(grLevels\fMinBVLevel))
            ElseIf fNewLevel > grLevels\fMaxBVLevel
              fNewLevel = grLevels\fMaxBVLevel
              debugMsg(sProcName, "grLevels\fMaxBVLevel=" + traceLevel(grLevels\fMaxBVLevel))
            EndIf
            If \fBVLevel[d] <> fNewLevel
              \fBVLevel[d] = fNewLevel
              SLD_setLevel(WQF\sldLevel[d], fNewLevel, \fTrimFactor[d])
              WQF_fcSldLevel(d)
              nLevelPointIndex = getCurrentItemData(WQF\cboDevSel, -1)
              If nLevelPointIndex >= 0
                WQF_displayRelLevelAndPanForDev(nLevelPointIndex)
              EndIf
              bLevelChanged = #True
            EndIf
          EndIf
        EndIf
      Next d
      recalcLvlPtLevels(nEditAudPtr)
      \bLvlPtRunForceSettings = #True
      editSetDisplayButtonsF()
      postChangeAudLN(u, bLevelChanged)
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_setOrigDBLevels()
  PROCNAMECA(nEditAudPtr)
  Protected d
  Protected nItemIndex
  
  rWQF\nAdjLevelNetInc = 0
  debugMsg(sProcName, "rWQF\nAdjLevelNetInc=" + rWQF\nAdjLevelNetInc)
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        rWQF\fOrigDBLevel[d] = convertDBStringToDBLevel(\sDBLevel[d])
        If \sLogicalDev[d]
          debugMsg(sProcName, "\sDBLevel[" + d + "]=" + \sDBLevel[d] + ", rWQF\fOrigDBLevel[" + d + "]=" + StrF(rWQF\fOrigDBLevel[d],2))
        EndIf
      Next d
    EndWith
  EndIf
  
EndProcedure

Procedure WQF_setReleaseBtnState(bRepositioning=#False)
  PROCNAMECA(nEditAudPtr)
  Protected bEnableRelease
  Protected nCurrLoopInfoIndex
  
  debugMsg(sProcName, #SCS_START + ", bRepositioning=" + strB(bRepositioning))
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \nLinkedToAudPtr = -1
        If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
          ; nCurrLoopInfoIndex = getCurrLoopInfoIndexAndSetLoopReleasedIndsIfReqd(nEditAudPtr, \nRelFilePos, bRepositioning, #True)
          nCurrLoopInfoIndex = \nCurrLoopInfoIndex ; Changed 8Jan2024 11.10.0
          ; debugMsg(sProcName, "nCurrLoopInfoIndex=" + nCurrLoopInfoIndex)
          If nCurrLoopInfoIndex >= 0 And nCurrLoopInfoIndex <> 100
            If \aLoopInfo(nCurrLoopInfoIndex)\bLoopReleased = #False
              bEnableRelease = #True
            EndIf
          EndIf
        EndIf
      EndIf
;       debugMsg(sProcName, "calling listLoopInfoArray(" + getAudLabel(nEditAudPtr) + ")")
;       listLoopInfoArray(nEditAudPtr)
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", nCurrLoopInfoIndex=" + nCurrLoopInfoIndex + ", bEnableRelease=" + strB(bEnableRelease))
      setEnabled(WQF\btnEditRelease, bEnableRelease)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnMoveDev_Click(bMoveUp)
  PROCNAMECA(nEditAudPtr)
  Protected nThisDevNo, nSwapDevNo, sLogicalDev.s
  Protected rMixerMatrix.tyMatrix
  Protected rLvlPtRun.tyLevelPointRunTime
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", bMoveUp=" + strB(bMoveUp))
  
  With aAud(nEditAudPtr)
    u = preChangeAudL(#True, "Move Device")
    nThisDevNo = rWQF\nCurrDevNo
    sLogicalDev = \sLogicalDev[nThisDevNo]
    If bMoveUp
      nSwapDevNo = nThisDevNo - 1
    Else
      nSwapDevNo = nThisDevNo + 1
    EndIf
    debugMsg(sProcName, "nThisDevNo=" + nThisDevNo + ", nSwapDevNo=" + nSwapDevNo)
    
    Swap \sLogicalDev[nThisDevNo],                      \sLogicalDev[nSwapDevNo]
    Swap \bIgnoreDev[nThisDevNo],                       \bIgnoreDev[nSwapDevNo]
    Swap \sTracks[nThisDevNo],                          \sTracks[nSwapDevNo]
    Swap \sDBTrim[nThisDevNo],                          \sDBTrim[nSwapDevNo]
    Swap \sDBLevel[nThisDevNo],                         \sDBLevel[nSwapDevNo]
    Swap \fPan[nThisDevNo],                             \fPan[nSwapDevNo]
    Swap \fBVLevelAtLoopEnd[nThisDevNo],                  \fBVLevelAtLoopEnd[nSwapDevNo]
    Swap \sDevPXChanListLeft[nThisDevNo],               \sDevPXChanListLeft[nSwapDevNo]
    Swap \sDevPXChanListRight[nThisDevNo],              \sDevPXChanListRight[nSwapDevNo]
    Swap \sDevXChanListLeft[nThisDevNo],                \sDevXChanListLeft[nSwapDevNo]
    Swap \sDevXChanListRight[nThisDevNo],               \sDevXChanListRight[nSwapDevNo]
    Swap \sAltDevPXChanListLeft[nThisDevNo],            \sAltDevPXChanListLeft[nSwapDevNo]
    Swap \sAltDevPXChanListRight[nThisDevNo],           \sAltDevPXChanListRight[nSwapDevNo]
    Swap \bStopping[nThisDevNo],                        \bStopping[nSwapDevNo]
    Swap \bAltStopping[nThisDevNo],                     \bAltStopping[nSwapDevNo]
    Swap \bFading[nThisDevNo],                          \bFading[nSwapDevNo]
    Swap \bAltFading[nThisDevNo],                       \bAltFading[nSwapDevNo]
    Swap \nFadeFactor[nThisDevNo],                      \nFadeFactor[nSwapDevNo]
    Swap \nAltFadeFactor[nThisDevNo],                   \nAltFadeFactor[nSwapDevNo]
    Swap \nFadeInc[nThisDevNo],                         \nFadeInc[nSwapDevNo]
    Swap \nAltFadeInc[nThisDevNo],                      \nAltFadeInc[nSwapDevNo]
    Swap \hFadeDSP[nThisDevNo],                         \hFadeDSP[nSwapDevNo]
    Swap \hPanDSP[nThisDevNo],                          \hPanDSP[nSwapDevNo]
    Swap \nMixerStreamPtr[nThisDevNo],                  \nMixerStreamPtr[nSwapDevNo]
    Swap \bUseMatrix[nThisDevNo],                       \bUseMatrix[nSwapDevNo]
    ;Swap \aMixerMatrix[nThisDevNo],                     \aMixerMatrix[nSwapDevNo]
    rMixerMatrix = \aMixerMatrix[nThisDevNo] : \aMixerMatrix[nThisDevNo] = \aMixerMatrix[nSwapDevNo] : \aMixerMatrix[nSwapDevNo] = rMixerMatrix
    Swap \nSelectedDeviceOutputs[nThisDevNo],           \nSelectedDeviceOutputs[nSwapDevNo]
    Swap \nMatrixOutputs[nThisDevNo],                   \nMatrixOutputs[nSwapDevNo]
    Swap \nMatrixOutputOffSet[nThisDevNo],              \nMatrixOutputOffSet[nSwapDevNo]
    Swap \nMatrixFactor[nThisDevNo],                    \nMatrixFactor[nSwapDevNo]
    Swap \bDisplayPan[nThisDevNo],                      \bDisplayPan[nSwapDevNo]
    Swap \nDSPInd[nThisDevNo],                          \nDSPInd[nSwapDevNo]
    Swap \nOutputDevMapDevPtr[nThisDevNo],              \nOutputDevMapDevPtr[nSwapDevNo]
    Swap \bASIO[nThisDevNo],                            \bASIO[nSwapDevNo]
    Swap \nBassASIODevice[nThisDevNo],                  \nBassASIODevice[nSwapDevNo]
    Swap \nBassDevice[nThisDevNo],                      \nBassDevice[nSwapDevNo]
    Swap \nBassChannel[nThisDevNo],                     \nBassChannel[nSwapDevNo]
    Swap \nBassAltChannel[nThisDevNo],                  \nBassAltChannel[nSwapDevNo]
    Swap \nBassStreamCreateFlags[nThisDevNo],           \nBassStreamCreateFlags[nSwapDevNo]
    Swap \nBassDecodeStreamCreateFlags[nThisDevNo],     \nBassDecodeStreamCreateFlags[nSwapDevNo]
    Swap \fBVLevel[nThisDevNo],                           \fBVLevel[nSwapDevNo]
    Swap \fTrimFactor[nThisDevNo],                      \fTrimFactor[nSwapDevNo]
    Swap \fCueVolNow[nThisDevNo],                       \fCueVolNow[nSwapDevNo]
    Swap \fCueAltVolNow[nThisDevNo],                    \fCueAltVolNow[nSwapDevNo]
    Swap \fCueTotalVolNow[nThisDevNo],                  \fCueTotalVolNow[nSwapDevNo]
    Swap \fCuePanNow[nThisDevNo],                       \fCuePanNow[nSwapDevNo]
    Swap \bCueVolManual[nThisDevNo],                    \bCueVolManual[nSwapDevNo]
    Swap \bCuePanManual[nThisDevNo],                    \bCuePanManual[nSwapDevNo]
    Swap \fSavedBVLevel[nThisDevNo],                      \fSavedBVLevel[nSwapDevNo]
    Swap \fSavedPan[nThisDevNo],                        \fSavedPan[nSwapDevNo]
    Swap \bCueLevelLC[nThisDevNo],                      \bCueLevelLC[nSwapDevNo]
    Swap \bCuePanLC[nThisDevNo],                        \bCuePanLC[nSwapDevNo]
    Swap \fLCBVLevel[nThisDevNo],                         \fLCBVLevel[nSwapDevNo]
    Swap \fLCPan[nThisDevNo],                           \fLCPan[nSwapDevNo]
    Swap \fBVLevelWhenFadeOutStarted[nThisDevNo],         \fBVLevelWhenFadeOutStarted[nSwapDevNo]
    Swap \fAudPlayBVLevel[nThisDevNo],                    \fAudPlayBVLevel[nSwapDevNo]
    Swap \fAudPlayPan[nThisDevNo],                      \fAudPlayPan[nSwapDevNo]
    Swap \fIncDecLevelBase[nThisDevNo],                 \fIncDecLevelBase[nSwapDevNo]
    Swap \fPreFadeBVLevel[nThisDevNo],                    \fPreFadeBVLevel[nSwapDevNo]
    Swap \fPreFadePan[nThisDevNo],                      \fPreFadePan[nSwapDevNo]
    Swap \fTargetBVLevel[nThisDevNo],                     \fTargetBVLevel[nSwapDevNo]
    Swap \fTargetPan[nThisDevNo],                       \fTargetPan[nSwapDevNo]
    Swap \nReqdFadeTime[nThisDevNo],                    \nReqdFadeTime[nSwapDevNo]
    Swap \bFadeCompleted[nThisDevNo],                   \bFadeCompleted[nSwapDevNo]
    ; Swap \aLvlPtRun[nThisDevNo],                        \aLvlPtRun[nSwapDevNo]
    rLvlPtRun = \aLvlPtRun[nThisDevNo] : \aLvlPtRun[nThisDevNo] = \aLvlPtRun[nSwapDevNo] : \aLvlPtRun[nSwapDevNo] = rLvlPtRun
    ; Added 25-28Mar2023 11.10.2bm
    Swap \bDeviceSelected[nThisDevNo],                  \bDeviceSelected[nSwapDevNo]
    Swap \nDeviceMinX[nThisDevNo],                      \nDeviceMinX[nSwapDevNo]
    Swap \nDeviceMaxX[nThisDevNo],                      \nDeviceMaxX[nSwapDevNo]
    Swap \fDeviceTotalVolWork[nThisDevNo],              \fDeviceTotalVolWork[nSwapDevNo]
    ; End added 25-28Mar2023 11.10.2bm
  EndWith
  
  SetFirstAndLastDev(nEditAudPtr)
  
  postChangeAudL(u, #False)
  
  WQF_displaySub(nEditSubPtr)
  
  With aAud(nEditAudPtr)
    If \sLogicalDev[nSwapDevNo] = sLogicalDev
      WQF_setCurrentDevInfo(nSwapDevNo, #True, #True)
      SAG(-1)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnRemoveDev_Click()
  ; Procedure added 21Mar2022 11.9.1aq
  PROCNAMECA(nEditAudPtr)
  Protected nThisDevNo, nNextDevNo, nHoldCurrDevNo, sLogicalDev.s
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    debugMsg(sProcName, "rWQF\nCurrDevNo=" + rWQF\nCurrDevNo)
    nHoldCurrDevNo = rWQF\nCurrDevNo
    sLogicalDev = \sLogicalDev[nHoldCurrDevNo]
    If Len(sLogicalDev) = 0
      sLogicalDev = Str(nHoldCurrDevNo + 1)
    EndIf
    u = preChangeAudL(#True, "Remove Device: " + sLogicalDev)
    ; move all following entries up one
    For nThisDevNo = rWQF\nCurrDevNo To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB - 1
      nNextDevNo = nThisDevNo + 1
      \sLogicalDev[nThisDevNo] =                      \sLogicalDev[nNextDevNo]
      \bIgnoreDev[nThisDevNo] =                       \bIgnoreDev[nNextDevNo]
      \sTracks[nThisDevNo] =                          \sTracks[nNextDevNo]
      \sDBTrim[nThisDevNo] =                          \sDBTrim[nNextDevNo]
      \sDBLevel[nThisDevNo] =                         \sDBLevel[nNextDevNo]
      \fPan[nThisDevNo] =                             \fPan[nNextDevNo]
      \fBVLevelAtLoopEnd[nThisDevNo] =                \fBVLevelAtLoopEnd[nNextDevNo]
      \sDevPXChanListLeft[nThisDevNo] =               \sDevPXChanListLeft[nNextDevNo]
      \sDevPXChanListRight[nThisDevNo] =              \sDevPXChanListRight[nNextDevNo]
      \sDevXChanListLeft[nThisDevNo] =                \sDevXChanListLeft[nNextDevNo]
      \sDevXChanListRight[nThisDevNo] =               \sDevXChanListRight[nNextDevNo]
      \sAltDevPXChanListLeft[nThisDevNo] =            \sAltDevPXChanListLeft[nNextDevNo]
      \sAltDevPXChanListRight[nThisDevNo] =           \sAltDevPXChanListRight[nNextDevNo]
      \bStopping[nThisDevNo] =                        \bStopping[nNextDevNo]
      \bAltStopping[nThisDevNo] =                     \bAltStopping[nNextDevNo]
      \bFading[nThisDevNo] =                          \bFading[nNextDevNo]
      \bAltFading[nThisDevNo] =                       \bAltFading[nNextDevNo]
      \nFadeFactor[nThisDevNo] =                      \nFadeFactor[nNextDevNo]
      \nAltFadeFactor[nThisDevNo] =                   \nAltFadeFactor[nNextDevNo]
      \nFadeInc[nThisDevNo] =                         \nFadeInc[nNextDevNo]
      \nAltFadeInc[nThisDevNo] =                      \nAltFadeInc[nNextDevNo]
      \hFadeDSP[nThisDevNo] =                         \hFadeDSP[nNextDevNo]
      \hPanDSP[nThisDevNo] =                          \hPanDSP[nNextDevNo]
      \nMixerStreamPtr[nThisDevNo] =                  \nMixerStreamPtr[nNextDevNo]
      \bUseMatrix[nThisDevNo] =                       \bUseMatrix[nNextDevNo]
      \aMixerMatrix[nThisDevNo] =                     \aMixerMatrix[nNextDevNo]
      \nSelectedDeviceOutputs[nThisDevNo] =           \nSelectedDeviceOutputs[nNextDevNo]
      \nMatrixOutputs[nThisDevNo] =                   \nMatrixOutputs[nNextDevNo]
      \nMatrixOutputOffSet[nThisDevNo] =              \nMatrixOutputOffSet[nNextDevNo]
      \nMatrixFactor[nThisDevNo] =                    \nMatrixFactor[nNextDevNo]
      \bDisplayPan[nThisDevNo] =                      \bDisplayPan[nNextDevNo]
      \nDSPInd[nThisDevNo] =                          \nDSPInd[nNextDevNo]
      \nOutputDevMapDevPtr[nThisDevNo] =              \nOutputDevMapDevPtr[nNextDevNo]
      \bASIO[nThisDevNo] =                            \bASIO[nNextDevNo]
      \nBassASIODevice[nThisDevNo] =                  \nBassASIODevice[nNextDevNo]
      \nBassDevice[nThisDevNo] =                      \nBassDevice[nNextDevNo]
      \nBassChannel[nThisDevNo] =                     \nBassChannel[nNextDevNo]
      \nBassAltChannel[nThisDevNo] =                  \nBassAltChannel[nNextDevNo]
      \nBassStreamCreateFlags[nThisDevNo] =           \nBassStreamCreateFlags[nNextDevNo]
      \nBassDecodeStreamCreateFlags[nThisDevNo] =     \nBassDecodeStreamCreateFlags[nNextDevNo]
      \fBVLevel[nThisDevNo] =                         \fBVLevel[nNextDevNo]
      \fTrimFactor[nThisDevNo] =                      \fTrimFactor[nNextDevNo]
      \fCueVolNow[nThisDevNo] =                       \fCueVolNow[nNextDevNo]
      \fCueAltVolNow[nThisDevNo] =                    \fCueAltVolNow[nNextDevNo]
      \fCueTotalVolNow[nThisDevNo] =                  \fCueTotalVolNow[nNextDevNo]
      \fCuePanNow[nThisDevNo] =                       \fCuePanNow[nNextDevNo]
      \bCueVolManual[nThisDevNo] =                    \bCueVolManual[nNextDevNo]
      \bCuePanManual[nThisDevNo] =                    \bCuePanManual[nNextDevNo]
      \fSavedBVLevel[nThisDevNo] =                    \fSavedBVLevel[nNextDevNo]
      \fSavedPan[nThisDevNo] =                        \fSavedPan[nNextDevNo]
      \bCueLevelLC[nThisDevNo] =                      \bCueLevelLC[nNextDevNo]
      \bCuePanLC[nThisDevNo] =                        \bCuePanLC[nNextDevNo]
      \fLCBVLevel[nThisDevNo] =                       \fLCBVLevel[nNextDevNo]
      \fLCPan[nThisDevNo] =                           \fLCPan[nNextDevNo]
      \fBVLevelWhenFadeOutStarted[nThisDevNo] =       \fBVLevelWhenFadeOutStarted[nNextDevNo]
      \fAudPlayBVLevel[nThisDevNo] =                  \fAudPlayBVLevel[nNextDevNo]
      \fAudPlayPan[nThisDevNo] =                      \fAudPlayPan[nNextDevNo]
      \fIncDecLevelBase[nThisDevNo] =                 \fIncDecLevelBase[nNextDevNo]
      \fPreFadeBVLevel[nThisDevNo] =                  \fPreFadeBVLevel[nNextDevNo]
      \fPreFadePan[nThisDevNo] =                      \fPreFadePan[nNextDevNo]
      \fTargetBVLevel[nThisDevNo] =                   \fTargetBVLevel[nNextDevNo]
      \fTargetPan[nThisDevNo] =                       \fTargetPan[nNextDevNo]
      \nReqdFadeTime[nThisDevNo] =                    \nReqdFadeTime[nNextDevNo]
      \bFadeCompleted[nThisDevNo] =                   \bFadeCompleted[nNextDevNo]
      \aLvlPtRun[nThisDevNo] =                        \aLvlPtRun[nNextDevNo]
      ; Added 25-28Mar2023 11.10.2bm
      \bDeviceSelected[nThisDevNo] =                  \bDeviceSelected[nNextDevNo]
      \nDeviceMinX[nThisDevNo] =                      \nDeviceMinX[nNextDevNo]
      \nDeviceMaxX[nThisDevNo] =                      \nDeviceMaxX[nNextDevNo]
      \fDeviceTotalVolWork[nThisDevNo] =              \fDeviceTotalVolWork[nNextDevNo]
      ; End added 25-28Mar2023 11.10.2bm
    Next nThisDevNo
    
    ; now clear the final entry
    nThisDevNo = #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
    \sLogicalDev[nThisDevNo] =                      grAudDef\sLogicalDev[nThisDevNo]
    \bIgnoreDev[nThisDevNo] =                       grAudDef\bIgnoreDev[nThisDevNo]
    \sTracks[nThisDevNo] =                          grAudDef\sTracks[nThisDevNo]
    \sDBTrim[nThisDevNo] =                          grAudDef\sDBTrim[nThisDevNo]
    \sDBLevel[nThisDevNo] =                         grAudDef\sDBLevel[nThisDevNo]
    \fPan[nThisDevNo] =                             grAudDef\fPan[nThisDevNo]
    \fBVLevelAtLoopEnd[nThisDevNo] =                grAudDef\fBVLevelAtLoopEnd[nThisDevNo]
    \sDevPXChanListLeft[nThisDevNo] =               grAudDef\sDevPXChanListLeft[nThisDevNo]
    \sDevPXChanListRight[nThisDevNo] =              grAudDef\sDevPXChanListRight[nThisDevNo]
    \sDevXChanListLeft[nThisDevNo] =                grAudDef\sDevXChanListLeft[nThisDevNo]
    \sDevXChanListRight[nThisDevNo] =               grAudDef\sDevXChanListRight[nThisDevNo]
    \sAltDevPXChanListLeft[nThisDevNo] =            grAudDef\sAltDevPXChanListLeft[nThisDevNo]
    \sAltDevPXChanListRight[nThisDevNo] =           grAudDef\sAltDevPXChanListRight[nThisDevNo]
    \bStopping[nThisDevNo] =                        grAudDef\bStopping[nThisDevNo]
    \bAltStopping[nThisDevNo] =                     grAudDef\bAltStopping[nThisDevNo]
    \bFading[nThisDevNo] =                          grAudDef\bFading[nThisDevNo]
    \bAltFading[nThisDevNo] =                       grAudDef\bAltFading[nThisDevNo]
    \nFadeFactor[nThisDevNo] =                      grAudDef\nFadeFactor[nThisDevNo]
    \nAltFadeFactor[nThisDevNo] =                   grAudDef\nAltFadeFactor[nThisDevNo]
    \nFadeInc[nThisDevNo] =                         grAudDef\nFadeInc[nThisDevNo]
    \nAltFadeInc[nThisDevNo] =                      grAudDef\nAltFadeInc[nThisDevNo]
    \hFadeDSP[nThisDevNo] =                         grAudDef\hFadeDSP[nThisDevNo]
    \hPanDSP[nThisDevNo] =                          grAudDef\hPanDSP[nThisDevNo]
    \nMixerStreamPtr[nThisDevNo] =                  grAudDef\nMixerStreamPtr[nThisDevNo]
    \bUseMatrix[nThisDevNo] =                       grAudDef\bUseMatrix[nThisDevNo]
    \aMixerMatrix[nThisDevNo] =                     grAudDef\aMixerMatrix[nThisDevNo]
    \nSelectedDeviceOutputs[nThisDevNo] =           grAudDef\nSelectedDeviceOutputs[nThisDevNo]
    \nMatrixOutputs[nThisDevNo] =                   grAudDef\nMatrixOutputs[nThisDevNo]
    \nMatrixOutputOffSet[nThisDevNo] =              grAudDef\nMatrixOutputOffSet[nThisDevNo]
    \nMatrixFactor[nThisDevNo] =                    grAudDef\nMatrixFactor[nThisDevNo]
    \bDisplayPan[nThisDevNo] =                      grAudDef\bDisplayPan[nThisDevNo]
    \nDSPInd[nThisDevNo] =                          grAudDef\nDSPInd[nThisDevNo]
    \nOutputDevMapDevPtr[nThisDevNo] =              grAudDef\nOutputDevMapDevPtr[nThisDevNo]
    \bASIO[nThisDevNo] =                            grAudDef\bASIO[nThisDevNo]
    \nBassASIODevice[nThisDevNo] =                  grAudDef\nBassASIODevice[nThisDevNo]
    \nBassDevice[nThisDevNo] =                      grAudDef\nBassDevice[nThisDevNo]
    \nBassChannel[nThisDevNo] =                     grAudDef\nBassChannel[nThisDevNo]
    \nBassAltChannel[nThisDevNo] =                  grAudDef\nBassAltChannel[nThisDevNo]
    \nBassStreamCreateFlags[nThisDevNo] =           grAudDef\nBassStreamCreateFlags[nThisDevNo]
    \nBassDecodeStreamCreateFlags[nThisDevNo] =     grAudDef\nBassDecodeStreamCreateFlags[nThisDevNo]
    \fBVLevel[nThisDevNo] =                         grAudDef\fBVLevel[nThisDevNo]
    \fTrimFactor[nThisDevNo] =                      grAudDef\fTrimFactor[nThisDevNo]
    \fCueVolNow[nThisDevNo] =                       grAudDef\fCueVolNow[nThisDevNo]
    \fCueAltVolNow[nThisDevNo] =                    grAudDef\fCueAltVolNow[nThisDevNo]
    \fCueTotalVolNow[nThisDevNo] =                  grAudDef\fCueTotalVolNow[nThisDevNo]
    \fCuePanNow[nThisDevNo] =                       grAudDef\fCuePanNow[nThisDevNo]
    \bCueVolManual[nThisDevNo] =                    grAudDef\bCueVolManual[nThisDevNo]
    \bCuePanManual[nThisDevNo] =                    grAudDef\bCuePanManual[nThisDevNo]
    \fSavedBVLevel[nThisDevNo] =                    grAudDef\fSavedBVLevel[nThisDevNo]
    \fSavedPan[nThisDevNo] =                        grAudDef\fSavedPan[nThisDevNo]
    \bCueLevelLC[nThisDevNo] =                      grAudDef\bCueLevelLC[nThisDevNo]
    \bCuePanLC[nThisDevNo] =                        grAudDef\bCuePanLC[nThisDevNo]
    \fLCBVLevel[nThisDevNo] =                       grAudDef\fLCBVLevel[nThisDevNo]
    \fLCPan[nThisDevNo] =                           grAudDef\fLCPan[nThisDevNo]
    \fBVLevelWhenFadeOutStarted[nThisDevNo] =       grAudDef\fBVLevelWhenFadeOutStarted[nThisDevNo]
    \fAudPlayBVLevel[nThisDevNo] =                  grAudDef\fAudPlayBVLevel[nThisDevNo]
    \fAudPlayPan[nThisDevNo] =                      grAudDef\fAudPlayPan[nThisDevNo]
    \fIncDecLevelBase[nThisDevNo] =                 grAudDef\fIncDecLevelBase[nThisDevNo]
    \fPreFadeBVLevel[nThisDevNo] =                  grAudDef\fPreFadeBVLevel[nThisDevNo]
    \fPreFadePan[nThisDevNo] =                      grAudDef\fPreFadePan[nThisDevNo]
    \fTargetBVLevel[nThisDevNo] =                   grAudDef\fTargetBVLevel[nThisDevNo]
    \fTargetPan[nThisDevNo] =                       grAudDef\fTargetPan[nThisDevNo]
    \nReqdFadeTime[nThisDevNo] =                    grAudDef\nReqdFadeTime[nThisDevNo]
    \bFadeCompleted[nThisDevNo] =                   grAudDef\bFadeCompleted[nThisDevNo]
    \aLvlPtRun[nThisDevNo] =                        grAudDef\aLvlPtRun[nThisDevNo]
    \bDeviceSelected[nThisDevNo] =                  grAudDef\bDeviceSelected[nThisDevNo] ; Added 25Mar2023 11.10.2bm (no need to reset related variables, eg min and max positions)
    
  EndWith
  
  SetFirstAndLastDev(nEditAudPtr)
  
  postChangeAudL(u, #False)
  
  WQF_displaySub(nEditSubPtr)
  
  WQF_setCurrentDevInfo(nHoldCurrDevNo, #True, #True)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_btnInsertDev_Click()
  ; Procedure added 21Mar2022 11.9.1aq
  PROCNAMECA(nEditAudPtr)
  Protected nThisDevNo, nPrevDevNo, nHoldCurrDevNo
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    u = preChangeAudL(#True, "Insert Device")
    debugMsg(sProcName, "rWQF\nCurrDevNo=" + rWQF\nCurrDevNo)
    nHoldCurrDevNo = rWQF\nCurrDevNo
    ; move all following entries up one
    For nThisDevNo = #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB To (nHoldCurrDevNo + 1) Step -1
      nPrevDevNo = nThisDevNo - 1
      \sLogicalDev[nThisDevNo] =                      \sLogicalDev[nPrevDevNo]
      \bIgnoreDev[nThisDevNo] =                       \bIgnoreDev[nPrevDevNo]
      \sTracks[nThisDevNo] =                          \sTracks[nPrevDevNo]
      \sDBTrim[nThisDevNo] =                          \sDBTrim[nPrevDevNo]
      \sDBLevel[nThisDevNo] =                         \sDBLevel[nPrevDevNo]
      \fPan[nThisDevNo] =                             \fPan[nPrevDevNo]
      \fBVLevelAtLoopEnd[nThisDevNo] =                \fBVLevelAtLoopEnd[nPrevDevNo]
      \sDevPXChanListLeft[nThisDevNo] =               \sDevPXChanListLeft[nPrevDevNo]
      \sDevPXChanListRight[nThisDevNo] =              \sDevPXChanListRight[nPrevDevNo]
      \sDevXChanListLeft[nThisDevNo] =                \sDevXChanListLeft[nPrevDevNo]
      \sDevXChanListRight[nThisDevNo] =               \sDevXChanListRight[nPrevDevNo]
      \sAltDevPXChanListLeft[nThisDevNo] =            \sAltDevPXChanListLeft[nPrevDevNo]
      \sAltDevPXChanListRight[nThisDevNo] =           \sAltDevPXChanListRight[nPrevDevNo]
      \bStopping[nThisDevNo] =                        \bStopping[nPrevDevNo]
      \bAltStopping[nThisDevNo] =                     \bAltStopping[nPrevDevNo]
      \bFading[nThisDevNo] =                          \bFading[nPrevDevNo]
      \bAltFading[nThisDevNo] =                       \bAltFading[nPrevDevNo]
      \nFadeFactor[nThisDevNo] =                      \nFadeFactor[nPrevDevNo]
      \nAltFadeFactor[nThisDevNo] =                   \nAltFadeFactor[nPrevDevNo]
      \nFadeInc[nThisDevNo] =                         \nFadeInc[nPrevDevNo]
      \nAltFadeInc[nThisDevNo] =                      \nAltFadeInc[nPrevDevNo]
      \hFadeDSP[nThisDevNo] =                         \hFadeDSP[nPrevDevNo]
      \hPanDSP[nThisDevNo] =                          \hPanDSP[nPrevDevNo]
      \nMixerStreamPtr[nThisDevNo] =                  \nMixerStreamPtr[nPrevDevNo]
      \bUseMatrix[nThisDevNo] =                       \bUseMatrix[nPrevDevNo]
      \aMixerMatrix[nThisDevNo] =                     \aMixerMatrix[nPrevDevNo]
      \nSelectedDeviceOutputs[nThisDevNo] =           \nSelectedDeviceOutputs[nPrevDevNo]
      \nMatrixOutputs[nThisDevNo] =                   \nMatrixOutputs[nPrevDevNo]
      \nMatrixOutputOffSet[nThisDevNo] =              \nMatrixOutputOffSet[nPrevDevNo]
      \nMatrixFactor[nThisDevNo] =                    \nMatrixFactor[nPrevDevNo]
      \bDisplayPan[nThisDevNo] =                      \bDisplayPan[nPrevDevNo]
      \nDSPInd[nThisDevNo] =                          \nDSPInd[nPrevDevNo]
      \nOutputDevMapDevPtr[nThisDevNo] =              \nOutputDevMapDevPtr[nPrevDevNo]
      \bASIO[nThisDevNo] =                            \bASIO[nPrevDevNo]
      \nBassASIODevice[nThisDevNo] =                  \nBassASIODevice[nPrevDevNo]
      \nBassDevice[nThisDevNo] =                      \nBassDevice[nPrevDevNo]
      \nBassChannel[nThisDevNo] =                     \nBassChannel[nPrevDevNo]
      \nBassAltChannel[nThisDevNo] =                  \nBassAltChannel[nPrevDevNo]
      \nBassStreamCreateFlags[nThisDevNo] =           \nBassStreamCreateFlags[nPrevDevNo]
      \nBassDecodeStreamCreateFlags[nThisDevNo] =     \nBassDecodeStreamCreateFlags[nPrevDevNo]
      \fBVLevel[nThisDevNo] =                         \fBVLevel[nPrevDevNo]
      \fTrimFactor[nThisDevNo] =                      \fTrimFactor[nPrevDevNo]
      \fCueVolNow[nThisDevNo] =                       \fCueVolNow[nPrevDevNo]
      \fCueAltVolNow[nThisDevNo] =                    \fCueAltVolNow[nPrevDevNo]
      \fCueTotalVolNow[nThisDevNo] =                  \fCueTotalVolNow[nPrevDevNo]
      \fCuePanNow[nThisDevNo] =                       \fCuePanNow[nPrevDevNo]
      \bCueVolManual[nThisDevNo] =                    \bCueVolManual[nPrevDevNo]
      \bCuePanManual[nThisDevNo] =                    \bCuePanManual[nPrevDevNo]
      \fSavedBVLevel[nThisDevNo] =                    \fSavedBVLevel[nPrevDevNo]
      \fSavedPan[nThisDevNo] =                        \fSavedPan[nPrevDevNo]
      \bCueLevelLC[nThisDevNo] =                      \bCueLevelLC[nPrevDevNo]
      \bCuePanLC[nThisDevNo] =                        \bCuePanLC[nPrevDevNo]
      \fLCBVLevel[nThisDevNo] =                       \fLCBVLevel[nPrevDevNo]
      \fLCPan[nThisDevNo] =                           \fLCPan[nPrevDevNo]
      \fBVLevelWhenFadeOutStarted[nThisDevNo] =       \fBVLevelWhenFadeOutStarted[nPrevDevNo]
      \fAudPlayBVLevel[nThisDevNo] =                  \fAudPlayBVLevel[nPrevDevNo]
      \fAudPlayPan[nThisDevNo] =                      \fAudPlayPan[nPrevDevNo]
      \fIncDecLevelBase[nThisDevNo] =                 \fIncDecLevelBase[nPrevDevNo]
      \fPreFadeBVLevel[nThisDevNo] =                  \fPreFadeBVLevel[nPrevDevNo]
      \fPreFadePan[nThisDevNo] =                      \fPreFadePan[nPrevDevNo]
      \fTargetBVLevel[nThisDevNo] =                   \fTargetBVLevel[nPrevDevNo]
      \fTargetPan[nThisDevNo] =                       \fTargetPan[nPrevDevNo]
      \nReqdFadeTime[nThisDevNo] =                    \nReqdFadeTime[nPrevDevNo]
      \bFadeCompleted[nThisDevNo] =                   \bFadeCompleted[nPrevDevNo]
      \aLvlPtRun[nThisDevNo] =                        \aLvlPtRun[nPrevDevNo]
      ; Added 25-28Mar2023 11.10.2bm
      \bDeviceSelected[nThisDevNo] =                  \bDeviceSelected[nPrevDevNo]
      \nDeviceMinX[nThisDevNo] =                      \nDeviceMinX[nPrevDevNo]
      \nDeviceMaxX[nThisDevNo] =                      \nDeviceMaxX[nPrevDevNo]
      \fDeviceTotalVolWork[nThisDevNo] =              \fDeviceTotalVolWork[nPrevDevNo]
debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fDeviceTotalVolWork[" + nThisDevNo + "]=" + traceLevel(\fDeviceTotalVolWork[nThisDevNo]))
      ; End added 25-28Mar2023 11.10.2bm
    Next nThisDevNo
    
    ; now clear the insert entry
    nThisDevNo = nHoldCurrDevNo
    \sLogicalDev[nThisDevNo] =                      grAudDef\sLogicalDev[nThisDevNo]
    \bIgnoreDev[nThisDevNo] =                       grAudDef\bIgnoreDev[nThisDevNo]
    \sTracks[nThisDevNo] =                          grAudDef\sTracks[nThisDevNo]
    \sDBTrim[nThisDevNo] =                          grAudDef\sDBTrim[nThisDevNo]
    \sDBLevel[nThisDevNo] =                         grAudDef\sDBLevel[nThisDevNo]
    \fPan[nThisDevNo] =                             grAudDef\fPan[nThisDevNo]
    \fBVLevelAtLoopEnd[nThisDevNo] =                grAudDef\fBVLevelAtLoopEnd[nThisDevNo]
    \sDevPXChanListLeft[nThisDevNo] =               grAudDef\sDevPXChanListLeft[nThisDevNo]
    \sDevPXChanListRight[nThisDevNo] =              grAudDef\sDevPXChanListRight[nThisDevNo]
    \sDevXChanListLeft[nThisDevNo] =                grAudDef\sDevXChanListLeft[nThisDevNo]
    \sDevXChanListRight[nThisDevNo] =               grAudDef\sDevXChanListRight[nThisDevNo]
    \sAltDevPXChanListLeft[nThisDevNo] =            grAudDef\sAltDevPXChanListLeft[nThisDevNo]
    \sAltDevPXChanListRight[nThisDevNo] =           grAudDef\sAltDevPXChanListRight[nThisDevNo]
    \bStopping[nThisDevNo] =                        grAudDef\bStopping[nThisDevNo]
    \bAltStopping[nThisDevNo] =                     grAudDef\bAltStopping[nThisDevNo]
    \bFading[nThisDevNo] =                          grAudDef\bFading[nThisDevNo]
    \bAltFading[nThisDevNo] =                       grAudDef\bAltFading[nThisDevNo]
    \nFadeFactor[nThisDevNo] =                      grAudDef\nFadeFactor[nThisDevNo]
    \nAltFadeFactor[nThisDevNo] =                   grAudDef\nAltFadeFactor[nThisDevNo]
    \nFadeInc[nThisDevNo] =                         grAudDef\nFadeInc[nThisDevNo]
    \nAltFadeInc[nThisDevNo] =                      grAudDef\nAltFadeInc[nThisDevNo]
    \hFadeDSP[nThisDevNo] =                         grAudDef\hFadeDSP[nThisDevNo]
    \hPanDSP[nThisDevNo] =                          grAudDef\hPanDSP[nThisDevNo]
    \nMixerStreamPtr[nThisDevNo] =                  grAudDef\nMixerStreamPtr[nThisDevNo]
    \bUseMatrix[nThisDevNo] =                       grAudDef\bUseMatrix[nThisDevNo]
    \aMixerMatrix[nThisDevNo] =                     grAudDef\aMixerMatrix[nThisDevNo]
    \nSelectedDeviceOutputs[nThisDevNo] =           grAudDef\nSelectedDeviceOutputs[nThisDevNo]
    \nMatrixOutputs[nThisDevNo] =                   grAudDef\nMatrixOutputs[nThisDevNo]
    \nMatrixOutputOffSet[nThisDevNo] =              grAudDef\nMatrixOutputOffSet[nThisDevNo]
    \nMatrixFactor[nThisDevNo] =                    grAudDef\nMatrixFactor[nThisDevNo]
    \bDisplayPan[nThisDevNo] =                      grAudDef\bDisplayPan[nThisDevNo]
    \nDSPInd[nThisDevNo] =                          grAudDef\nDSPInd[nThisDevNo]
    \nOutputDevMapDevPtr[nThisDevNo] =              grAudDef\nOutputDevMapDevPtr[nThisDevNo]
    \bASIO[nThisDevNo] =                            grAudDef\bASIO[nThisDevNo]
    \nBassASIODevice[nThisDevNo] =                  grAudDef\nBassASIODevice[nThisDevNo]
    \nBassDevice[nThisDevNo] =                      grAudDef\nBassDevice[nThisDevNo]
    \nBassChannel[nThisDevNo] =                     grAudDef\nBassChannel[nThisDevNo]
    \nBassAltChannel[nThisDevNo] =                  grAudDef\nBassAltChannel[nThisDevNo]
    \nBassStreamCreateFlags[nThisDevNo] =           grAudDef\nBassStreamCreateFlags[nThisDevNo]
    \nBassDecodeStreamCreateFlags[nThisDevNo] =     grAudDef\nBassDecodeStreamCreateFlags[nThisDevNo]
    \fBVLevel[nThisDevNo] =                         grAudDef\fBVLevel[nThisDevNo]
    \fTrimFactor[nThisDevNo] =                      grAudDef\fTrimFactor[nThisDevNo]
    \fCueVolNow[nThisDevNo] =                       grAudDef\fCueVolNow[nThisDevNo]
    \fCueAltVolNow[nThisDevNo] =                    grAudDef\fCueAltVolNow[nThisDevNo]
    \fCueTotalVolNow[nThisDevNo] =                  grAudDef\fCueTotalVolNow[nThisDevNo]
    \fCuePanNow[nThisDevNo] =                       grAudDef\fCuePanNow[nThisDevNo]
    \bCueVolManual[nThisDevNo] =                    grAudDef\bCueVolManual[nThisDevNo]
    \bCuePanManual[nThisDevNo] =                    grAudDef\bCuePanManual[nThisDevNo]
    \fSavedBVLevel[nThisDevNo] =                    grAudDef\fSavedBVLevel[nThisDevNo]
    \fSavedPan[nThisDevNo] =                        grAudDef\fSavedPan[nThisDevNo]
    \bCueLevelLC[nThisDevNo] =                      grAudDef\bCueLevelLC[nThisDevNo]
    \bCuePanLC[nThisDevNo] =                        grAudDef\bCuePanLC[nThisDevNo]
    \fLCBVLevel[nThisDevNo] =                       grAudDef\fLCBVLevel[nThisDevNo]
    \fLCPan[nThisDevNo] =                           grAudDef\fLCPan[nThisDevNo]
    \fBVLevelWhenFadeOutStarted[nThisDevNo] =       grAudDef\fBVLevelWhenFadeOutStarted[nThisDevNo]
    \fAudPlayBVLevel[nThisDevNo] =                  grAudDef\fAudPlayBVLevel[nThisDevNo]
    \fAudPlayPan[nThisDevNo] =                      grAudDef\fAudPlayPan[nThisDevNo]
    \fIncDecLevelBase[nThisDevNo] =                 grAudDef\fIncDecLevelBase[nThisDevNo]
    \fPreFadeBVLevel[nThisDevNo] =                  grAudDef\fPreFadeBVLevel[nThisDevNo]
    \fPreFadePan[nThisDevNo] =                      grAudDef\fPreFadePan[nThisDevNo]
    \fTargetBVLevel[nThisDevNo] =                   grAudDef\fTargetBVLevel[nThisDevNo]
    \fTargetPan[nThisDevNo] =                       grAudDef\fTargetPan[nThisDevNo]
    \nReqdFadeTime[nThisDevNo] =                    grAudDef\nReqdFadeTime[nThisDevNo]
    \bFadeCompleted[nThisDevNo] =                   grAudDef\bFadeCompleted[nThisDevNo]
    \aLvlPtRun[nThisDevNo] =                        grAudDef\aLvlPtRun[nThisDevNo]
    \bDeviceSelected[nThisDevNo] =                  grAudDef\bDeviceSelected[nThisDevNo] ; Added 25Mar2023 11.10.2bm (no need to reset related varaibles, eg min and max positions)
    
  EndWith
  
  SetFirstAndLastDev(nEditAudPtr)
  
  postChangeAudL(u, #False)
  
  WQF_displaySub(nEditSubPtr)
  
  WQF_setCurrentDevInfo(nHoldCurrDevNo, #True, #True)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure  WQF_mnuAddQuickCueMarkers()
  ; Purpose is to add a Quick Cue Marker to the Current Audio File at the mouse click position
  addQuickCueMarker(@grMG2)
EndProcedure

; VST GUI Actions
; ---------------
Procedure WQF_makeVSTWindowActiveIfReqd()
  ; Added 21Feb2025
  PROCNAMECA(nEditAudPtr)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \sVSTPluginName
        If IsWindow(#WPL)
          If getOwnState(WQF\chkViewVST) = #PB_Checkbox_Checked
            debugMsg(sProcName, "calling SAW(#WPL)")
            SAW(#WPL)
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  ; End added 21Feb2025

EndProcedure

Procedure WQF_showVST(bShowVST)
  PROCNAMECA(nEditAudPtr)
  Protected bPluginsFound, n, nWidth, bShowCheckboxes, bEnableCheckboxes
  
  debugMsg(sProcName, #SCS_START + ", bShowVST=" + strB(bShowVST))
  
  With WQF
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      For n = 0 To grVST\nMaxLibVSTPlugin
        If grVST\aLibVSTPlugin(n)\sLibVSTPluginFile64
          bPluginsFound = #True
          Break
        EndIf
      Next n
    CompilerElse
      For n = 0 To grVST\nMaxLibVSTPlugin
        If grVST\aLibVSTPlugin(n)\sLibVSTPluginFile32
          bPluginsFound = #True
          Break
        EndIf
      Next n
    CompilerEndIf
    
    If bPluginsFound Or aAud(nEditAudPtr)\sVSTPluginName ; Added aAud(nEditAudPtr)\sVSTPluginName test 23Dec2023 11.10.0dt
      setVisibleAndEnabled(\lblVSTPlugin, #True)
      setVisibleAndEnabled(\cboVSTPlugin, #True)
      nWidth = GadgetX(\lblVSTPlugin) - GadgetX(\txtFileTypeExt) - gnGap2
      If aAud(nEditAudPtr)\sVSTPluginName
        bShowCheckboxes = bShowVST
        bEnableCheckboxes = bShowVST
      EndIf
    Else
      setVisibleAndEnabled(\lblVSTPlugin, #False)
      setVisibleAndEnabled(\cboVSTPlugin, #False)
      nWidth = GadgetWidth(\cntSubDetailF) - (GadgetX(\txtFileTypeExt) * 2)
    EndIf
    If GadgetWidth(\txtFileTypeExt) <> nWidth
      ResizeGadget(WQF\txtFileTypeExt, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    EndIf
    
    setVisible(\chkViewVST, bShowCheckboxes)
    setVisible(\chkBypassVST, bShowCheckboxes)
    setEnabled(\chkViewVST, bEnableCheckboxes)
    setEnabled(\chkBypassVST, bEnableCheckboxes)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure  

Procedure WQF_chkBypassVST_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  u = preChangeAudL(aAud(nEditAudPtr)\bVSTBypass, GGT(WQF\chkBypassVST))
  If getOwnState(WQF\chkBypassVST) = #PB_Checkbox_Checked
    aAud(nEditAudPtr)\bVSTBypass = #True
  Else
    aAud(nEditAudPtr)\bVSTBypass = #False
  EndIf
  debugMsg(sProcName, "\bVSTBypass=" + strB(aAud(nEditAudPtr)\bVSTBypass))
  VST_setPluginBypass(aAud(nEditAudPtr)\nVSTHandle, nEditAudPtr) 
  If aAud(nEditAudPtr)\nSourceAltChannel <> 0
    VST_setPluginBypass(aAud(nEditAudPtr)\nVSTAltHandle, nEditAudPtr)
  EndIf
  VST_applyVSTInfoToSameAsSubCues(nEditAudPtr)
  postChangeAudL(u, aAud(nEditAudPtr)\bVSTBypass)
  
  WQF_makeVSTWindowActiveIfReqd() ; Added 21Feb2025
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_chkViewVST_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    If getOwnState(WQF\chkViewVST) = #PB_Checkbox_Checked
      If \nVSTHandle = 0
        VST_showWarning(#SCS_VST_PLUGIN_ERROR_FILE_LOCATION, \sVSTPluginName)
        setOwnState(WQF\chkViewVST, #PB_Checkbox_Unchecked)
      Else
        debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_AUD, " + getAudLabel(nEditAudPtr) + ", " + decodeHandle(\nVSTHandle) + ", #True)")
        WPL_showVSTEditor(#SCS_VST_HOST_AUD, nEditAudPtr, \nVSTHandle, #True)
      EndIf
    Else
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(\nVSTHandle) + ", #False)")
      WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, \nVSTHandle, #False)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_cboVSTPlugin_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u, sOldPluginName.s, sNewPluginName.s, bPluginLoaded
  Protected sOldSameAsCue.s, nOldSameAsSubNo, nNewData, sNewSameAsCue.s, nNewSameAsSubNo
  Protected nOldSameAsSubRef, nNewSameAsSubRef
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \sVSTPluginName
        sOldPluginName = \sVSTPluginName
      ElseIf \sVSTPluginSameAsCue
        sOldSameAsCue = \sVSTPluginSameAsCue
        nOldSameAsSubNo = \nVSTPluginSameAsSubNo
        nOldSameAsSubRef = \nVSTPluginSameAsSubRef
      EndIf
      nNewData = GetGadgetItemData(WQF\cboVSTPlugin, GGS(WQF\cboVSTPlugin))
      If nNewData = -1
        sNewPluginName = Trim(GGT(WQF\cboVSTPlugin))
      ElseIf nNewData >= 0
        ; 'Same as...' where nNewData = sub ptr
        sNewSameAsCue = aSub(nNewData)\sCue
        nNewSameAsSubNo = aSub(nNewData)\nSubNo
        nNewSameAsSubRef = aSub(nNewData)\nSubRef
      EndIf
      ; debugMsg(sProcName, "sOldPluginName=" + #DQUOTE$ + sOldPluginName + #DQUOTE$ + ", sNewPluginName=" + #DQUOTE$ + sNewPluginName + #DQUOTE$)
      If sNewPluginName = sOldPluginName And sNewSameAsCue = sOldSameAsCue And nNewSameAsSubNo = nOldSameAsSubNo And nNewSameAsSubRef = nOldSameAsSubRef
        ; no change so exit immediately
        ProcedureReturn
      EndIf
      
      ; Do not change the selected plugin for the current aud if the aud is playing
      If (\nAudState = #SCS_CUE_PLAYING) And (sOldPluginName Or sOldSameAsCue)
        MessageRequester(Lang("VST", "vstViewer"), sOldPluginName + Lang("VST", "audPlaying"))
        SGT(WQF\cboVSTPlugin, sOldPluginName)
        ProcedureReturn
      EndIf
      
    EndWith
    
    If grWPL\bPluginShowing
      ; if the viewer of the current plugin is showing then close the viewer
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(grWPL\nVSTHandleForPluginShowing) + ", #False)")
      WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, grWPL\nVSTHandleForPluginShowing, #False)
    EndIf
    
    With WQF
      u = preChangeAudL(#True, Trim(GGT(WQF\lblVSTPlugin))) ; nb use True/False, not plugin name, because it's more than just the name but also all the parameter settings etc
      VST_clearAudPlugin(nEditAudPtr) ; clear any existing plugin
      
      aAud(nEditAudPtr)\sVSTPluginName = sNewPluginName
      aAud(nEditAudPtr)\sVSTPluginSameAsCue = sNewSameAsCue
      aAud(nEditAudPtr)\nVSTPluginSameAsSubNo = nNewSameAsSubNo
      aAud(nEditAudPtr)\nVSTPluginSameAsSubRef = nNewSameAsSubRef
      
      If sNewPluginName
        WQF_showVST(#True)
      Else
        WQF_showVST(#False)
      EndIf      
      
      ; Change the Plugin (nb this code is NOT executed for 'Same as...')
      If sNewPluginName
        VST_setReqdPluginInfo(nEditAudPtr)
        debugMsg(sProcName, "calling VST_loadAudVSTPlugin(" + getAudLabel(nEditAudPtr) + ")")
        bPluginLoaded = VST_loadAudVSTPlugin(nEditAudPtr)
      EndIf
      If bPluginLoaded
        setVisibleAndEnabled(WQF\chkBypassVST, #True)
        setVisibleAndEnabled(WQF\chkViewVST, #True)
        setOwnState(WQF\chkViewVST, #PB_Checkbox_Checked)
        If aAud(nEditAudPtr)\bVSTBypass
          setOwnState(WQF\chkBypassVST, #PB_Checkbox_Checked)
        Else
          setOwnState(WQF\chkBypassVST, #PB_Checkbox_Unchecked)
        EndIf
        debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_AUD, " + getAudLabel(nEditAudPtr) + ", " + decodeHandle(aAud(nEditAudPtr)\nVSTHandle) + ", #True)")
        WPL_showVSTEditor(#SCS_VST_HOST_AUD, nEditAudPtr, aAud(nEditAudPtr)\nVSTHandle, #True)
      Else
        setOwnState(WQF\chkBypassVST, #PB_Checkbox_Unchecked)
        setVisibleAndEnabled(WQF\chkBypassVST, #False)
        setOwnState(WQF\chkViewVST, #PB_Checkbox_Unchecked)
        setVisibleAndEnabled(WQF\chkViewVST, #False)
      EndIf
      
      postChangeAudL(u, #False)
      
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQF_populateCboVSTPlugin()
  PROCNAMECA(nEditAudPtr)
  Protected sVSTPluginName.s, n, bNoPlugins, bShowVST, nWidth
  Protected sCurrentSelectedPluginName.s, nListIndex
  Protected i, j, k, sSameAs.s
  
  debugMsg(sProcName, #SCS_START)
  
  If IsGadget(WQF\cboVSTPlugin) = #False
    debugMsg(sProcName, "exiting - WQF\cboVSTPlugin not yet created")
    ProcedureReturn
  EndIf
  
  ; Added 5Mar2024 11.10.2ba following an attempt to add a VST plugin in fmVSTPlugins after fmEditQF had previously been displayed but the editor now closed.
  ; nEditAudPtr was -1 which caused this procedure to crash. Decided we also need to make sure that nEditAudPtr (if set) pointed to an Audio File sub-cue.
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  If aAud(nEditAudPtr)\bAudTypeF = #False
    ProcedureReturn
  EndIf
  ; End added 5Mar2024 11.10.2ba
  
  If aAud(nEditAudPtr)\sVSTPluginName Or aAud(nEditAudPtr)\sVSTPluginSameAsCue
    bShowVST = #True
  Else
    For n = 0 To grVST\nMaxLibVSTPlugin
      If Trim(grVST\aLibVSTPlugin(n)\sLibVSTPluginName)
        bShowVST = #True
        Break
      EndIf
    Next n
  EndIf
  
  With WQF
    If CountGadgetItems(\cboVSTPlugin) > 0
      sCurrentSelectedPluginName = GGT(\cboVSTPlugin)
    EndIf
    ClearGadgetItems(\cboVSTPlugin)
    addGadgetItemWithData(\cboVSTPlugin, "", -2) ; nData = -2 for none selected
    If bShowVST
      For n = 0 To grVST\nMaxLibVSTPlugin
        sVSTPluginName = Trim(grVST\aLibVSTPlugin(n)\sLibVSTPluginName)
        If sVSTPluginName
          addGadgetItemWithData(\cboVSTPlugin, sVSTPluginName, -1) ; nData = -1 for VST Plugin
        EndIf
      Next n
      CompilerIf #c_vst_same_as
        For i = 1 To gnLastCue
          If aCue(i)\bSubTypeF
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubTypeF And j <> nEditSubPtr
                k = aSub(j)\nFirstAudIndex
                If k >= 0
                  sVSTPluginName = aAud(k)\sVSTPluginName
                  If sVSTPluginName <> "None" And sVSTPluginName <> ""
                    sSameAs = LangPars("VST", "SameAs", getSubLabel(j)) ; eg 'Same plugin data as Q4<2>'
                    addGadgetItemWithData(\cboVSTPlugin, sSameAs, j) ; nData = j (sub ptr) for 'same as'
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf ; EndIf aCue(i)\bSubTypeF
        Next i
      CompilerEndIf
      If nEditAudPtr >= 0
        nListIndex = indexForComboBoxRow(\cboVSTPlugin, sCurrentSelectedPluginName, 0)
        SGS(\cboVSTPlugin, nListIndex)
        WQF_showVST(#True)
      Else
        SGS(\cboVSTPlugin, 0) 
        setVisibleAndEnabled(\chkViewVST, #False)
        setVisibleAndEnabled(\chkBypassVST, #False)
      EndIf
    Else
      ; Hide the Control for VST Bypass & View
      SGS(WQF\cboVSTPlugin, 0) 
      bNoPlugins = #True
      For n = 0 To grVST\nMaxLibVSTPlugin
        If Trim(grVST\aLibVSTPlugin(n)\sLibVSTPluginName)
          bNoPlugins = #False
          Break
        EndIf
      Next n
      If bNoPlugins And Len(Trim(aAud(nEditAudPtr)\sVSTPluginName)) = 0
        setVisibleAndEnabled(\lblVSTPlugin, #False)
        setVisibleAndEnabled(\cboVSTPlugin, #False)
        nWidth = GadgetWidth(\cntSubDetailF) - (GadgetX(\txtFileTypeExt) * 2)
        setVisibleAndEnabled(WQF\chkViewVST, #False)
        setVisibleAndEnabled(WQF\chkBypassVST, #False)
      Else
        nWidth = GadgetX(\lblVSTPlugin) - GadgetX(\txtFileTypeExt) - gnGap2
      EndIf
      If GadgetWidth(\txtFileTypeExt) <> nWidth
        ResizeGadget(WQF\txtFileTypeExt, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WQF_mnuViewCueMarkersUsage(nSourceForm=#WQF)
  ; nb after supportiog cue markers in video cues, this procedure may be called from #WQA, so nSourceForm added
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, "calling WEM_Form_Show(#True, #WED, " + decodeWindow(nSourceForm) + ", #SCS_WEM_F_CUEMARKERSUSAGE)")
  WEM_Form_Show(#True, #WED, nSourceForm, #SCS_WEM_F_CUEMARKERSUSAGE)
  ; must return now - unlike VB, PB doesn't block processing while the modal form is displayed
  ProcedureReturn
  
EndProcedure

Procedure WQF_mnuChangeFreqTempoPitch()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, "calling WEM_Form_Show(#True, #WED, #WQF, #SCS_WEM_F_FREQ_TEMPO_PITCH)")
  WEM_Form_Show(#True, #WED, #WQF, #SCS_WEM_F_FREQ_TEMPO_PITCH)
  ; must return now - unlike VB, PB doesn't block processing while the modal form is displayed
  ProcedureReturn
  
EndProcedure

Procedure WQF_refreshTempoEtcInfo()
  PROCNAMECA(nEditAudPtr)
  Protected sTempoEtcInfo.s
  
  sTempoEtcInfo = buildTempoEtcInfo(nEditSubPtr)
  SGT(WQF\lblTempoEtcInfo, sTempoEtcInfo)
  
EndProcedure

Procedure WQF_mnuRenameFile()
  PROCNAMECA(nEditAudPtr)
  
  If nEditAudPtr >= 0
    If valCue(#False)
      BTNCLICK(WFR_renameAudFile(aAud(nEditAudPtr)\sFileName, "F"))
      ; no further action allowed here as WFR_renameAudFile() opens a modal window
    EndIf
  EndIf
EndProcedure

Procedure WQF_mnuLinkDevices()
  PROCNAMECS(nEditSubPtr)
  
  If nEditSubPtr >= 0 And nEditAudPtr >= 0
    CompilerIf #c_cuepanel_multi_dev_select
      If grProd\nMaxAudioLogicalDev > 0
        ; at least two audio devices defined in production properties
        WLD_Form_Show(nEditSubPtr, 1, #WED)
      EndIf
    CompilerEndIf
  EndIf
  
EndProcedure

Procedure WQF_adjustSelectedDevicesLevels(nDevNo, fBVLevel.f)
  PROCNAMECA(nEditAudPtr)
  
  ; NOTE: See also PNL_adjustSelectedDevicesLevels()
  ; NOTE: ------------------------------------------
  
  Protected fCurrBVLevel.f, fCurrDBLevel.f, fDBLevel.f, fDBChange.f, d, d2
  Protected fDevBVLevel.f, fDevDBLevel.f, fTrimFactor.f
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", nDevNo=" + nDevNo + ", fBVLevel=" + traceLevel(fBVLevel))
  With aAud(nEditAudPtr)
    fCurrBVLevel = \fDeviceTotalVolWork[nDevNo]
    fCurrDBLevel = convertBVLevelToDBLevel(fCurrBVLevel)
    If fBVLevel > grLevels\fMinBVLevel
      fDBLevel = convertBVLevelToDBLevel(fBVLevel)
    Else
      fDBLevel = grLevels\nMinDBLevel
    EndIf
    fDBChange = fDBLevel - fCurrDBLevel
debugMsgC(sProcName, ">>>> gnSliderEvent=" + gnSliderEvent + ", nDevNo=" + nDevNo + ", fDBLevel=" + StrF(fDBLevel,2) + ", fCurrDBLevel=" + StrF(fCurrDBLevel,2) + ", fDBChange=" + StrF(fDBChange,2))
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      If \bDeviceSelected[d]
        If \sLogicalDev[d] 
          ; should be #True
          ; NOTE: The purpose of fDeviceTotalVolWork[d] is to enable level increases to be capped at the maximum (eg 0.0dB) whilst increases continue for other devices
          ; NOTE: that are currently set at lower levels, but then to retain the original gap when the level of the devices is lowered.
          fCurrBVLevel = \fDeviceTotalVolWork[d]
          fCurrDBLevel = convertBVLevelToDBLevel(fCurrBVLevel)
          fDevDBLevel = fCurrDBLevel + fDBChange
          fDevBVLevel = convertDBLevelToBVLevel(fDevDBLevel)
          \fDeviceTotalVolWork[d] = fDevBVLevel
debugMsgC(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\fDeviceTotalVolWork[" + d + "]=" + traceLevel(\fDeviceTotalVolWork[d]))
          If fDevBVLevel > grLevels\fMaxBVLevel
            fDevBVLevel = grLevels\fMaxBVLevel
          ElseIf fDevDBLevel <= grLevels\nMinDBLevel
            fDevBVLevel = grLevels\fSilentBVLevel ; BASS Volume 'silent'
          EndIf
debugMsgC(sProcName, "d=" + d + ", fDevDBLevel=" + StrF(fDevDBLevel,2) + ", fCurrDBLevel=" + StrF(fCurrDBLevel,2))
          If d = nDevNo
            ; debugMsg(sProcName, "calling WQF_fcSldLevel(" + d + ")")
            WQF_fcSldLevel(d)
          Else
debugMsgC(sProcName, "calling SLD_setLevel(WQF\sldLevel[" + d + "]), " + convertBVLevelToDBString(fDevBVLevel) + ", " + StrF(fTrimFactor,1) + ")")
            SLD_setLevel(WQF\sldLevel[d], fDevBVLevel, fTrimFactor)
            ; SLD_setBaseLevel(WQF\sldLevel[d], fBaseLevel, fTrimFactor)
            SLD_drawSlider(WQF\sldLevel[d])
            ; debugMsg(sProcName, "calling WQF_fcSldLevel(" + d + ")")
            WQF_fcSldLevel(d)
          EndIf
        EndIf
      EndIf
    Next d
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF