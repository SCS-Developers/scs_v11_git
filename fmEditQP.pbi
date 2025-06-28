; File: fmEditQP.pbi

EnableExplicit

Procedure WQP_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k, d, nAudNo
  Protected nDevIndex, nListIndex
  Protected nFileDuration
  Protected nGrdRowNo
  Protected nFirstPlayIndex, nFirstPlayListIndex
  Protected nCurrPlayIndex, nCurrPlayListIndex=-1
  Protected bDevPresent
  Protected sText.s
  Protected nGrdPlaylist
  Protected nGadgetNo
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQPCreated = #False
    WQP_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQP\lblSubCueType, pSubPtr)
  
  ; propogate audio devs into logical dev combo boxes if reqd
  propogateProdDevs("P")
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "P", WQP)
    
    WQP_clearDropInfo()
    
    ; facility to reposition using sliders not yet implemented
    SLD_setEnabled(WQP\sldPLProgress[0], #False)
    SLD_setEnabled(WQP\sldPLProgress[1], #False)
    
    nFirstPlayIndex = \nFirstPlayIndex
    nCurrPlayIndex = \nCurrPlayIndex
    setEditAudPtr(\nFirstAudIndex)
    For d = 0 To grLicInfo\nMaxAudDevPerSub
      
      SGT(WQP\lblPLDevNo[d], Str(d+1))
      
      If \sPLLogicalDev[d]
        bDevPresent = #True
      Else
        bDevPresent = #False
      EndIf
      
      If bDevPresent
        nListIndex = indexForComboBoxRow(WQP\cboPLLogicalDev[d], \sPLLogicalDev[d])
        SGS(WQP\cboPLLogicalDev[d], nListIndex)
      Else
        SGS(WQP\cboPLLogicalDev[d], -1)
      EndIf
      ; debugMsg(sProcName, "calling WQP_fcLogicalDevP(" + d + ", " + d + ")")
      WQP_fcLogicalDevP(d)
      
      populateCboTracksForSub(WQP\cboPLTracks[d], pSubPtr, d)
      nListIndex = indexForComboBoxRow(WQP\cboPLTracks[d], \sPLTracks[d], -1)
      If (nListIndex = -1) And (bDevPresent)
        nListIndex = 0
      EndIf
      If GGS(WQP\cboPLTracks[d]) <> nListIndex
        SGS(WQP\cboPLTracks[d], nListIndex)
      EndIf
      
      nListIndex = indexForComboBoxRow(WQP\cboSubTrim[d], \sPLDBTrim[d], -1)
      If (nListIndex = -1) And (bDevPresent)
        nListIndex = 0
      EndIf
      If GetGadgetState(WQP\cboSubTrim[d]) <> nListIndex
        SGS(WQP\cboSubTrim[d], nListIndex)
      EndIf
      SLD_setLevel(WQP\sldSubLevel[d], \fSubMastBVLevel[d], \fSubTrimFactor[d])
      SGT(WQP\txtSubDBLevel[d], convertBVLevelToDBString(\fSubMastBVLevel[d], #False, #True))
      SLD_setMax(WQP\sldSubLevel[d], #SCS_MAXVOLUME_SLD) ; set max to format slider
      SLD_setMax(WQP\sldSubPan[d], #SCS_MAXPAN_SLD)   ; forces control to be formatted
      SLD_setValue(WQP\sldSubPan[d], panToSliderValue(\fPLPan[d]))
      WQP_fcSldLevelP(d)
      WQP_fcSldPanP(d)
    Next d
    
    debugMsg(sProcName, "fadeinfo")
    SGT(WQP\txtPLFadeInTime, timeToStringT(\nPLFadeInTime, \nPLFadeInTime))
    SGT(WQP\txtPLFadeOutTime, timeToStringT(\nPLFadeOutTime, \nPLFadeOutTime))
    
    setOwnState(WQP\chkShowFileFolders, grEditorPrefs\bShowFileFoldersInEditor)
    setOwnState(WQP\chkPLRandom, \bPLRandom)
    setOwnState(WQP\chkPLRepeat, \bPLRepeat)
    setOwnState(WQP\chkPLSavePos, \bPLSavePos)
    
    setEnabled(WQP\btnPLShuffle, \bPLRandom)  ; reshuffle button enabled if random is true
    
    CompilerIf #c_include_mygrid_for_playlists = #False
      ; about to clear WQPFile() so destroy any existing gadgets associated with WQPFile()
      ForEach WQPFile()
        If IsGadget(WQPFile()\cntFile)
          scsFreeGadget(WQPFile()\cntFile)
          debugMsg(sProcName, "FreeGadget(G" + WQPFile()\cntFile + ")")
        EndIf
      Next WQPFile()
    CompilerEndIf
    ClearList(WQPFile())
    rWQP\nVisibleFiles = 0
    rWQP\nCurrentTrkNoHandle = 0
    CompilerIf #c_include_mygrid_for_playlists
      rWQP\nCurrentTrkRowNo = 0
    CompilerEndIf
    
    CompilerIf #c_include_mygrid_for_playlists
      nGrdPlaylist = WQP\grdPlaylist
      
      k = \nFirstAudIndex
      While k >= 0
        debugMsg(sProcName, "k=" + k)
        nGrdRowNo + 1
        createWQPFile()   ; add an entry to the linked list WQPFile()
        WQPFile()\nAudPtr = k
        WQPFile()\nFileNameLen = Len(aAud(k)\sStoredFileName)
        If grEditorPrefs\bShowFileFoldersInEditor
          sText = aAud(k)\sStoredFileName
        Else
          sText = GetFilePart(aAud(k)\sStoredFileName)
        EndIf
        ; debugMsg0(sProcName, "calling MyGrid_SetText(" + getGadgetName(nGrdPlayList) + ", " + nGrdRowNo + ", 2, " + #DQUOTE$ + sText + #DQUOTE$ + ")")
        MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 2, sText)
        MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 2, rWQP\nStyleCellDisplayLeft)
        MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 3, "...")
        MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 3, rWQP\nStyleCellButton)
        ; GadgetToolTip(WQPFile()\txtFileNameP, aAud(k)\sFileName)
        If Trim(aAud(k)\sFileName)
          setDerivedAudFields(k)
          nFileDuration = aAud(k)\nFileDuration
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 1, Str(aAud(k)\nAudNo))                                    ; No.
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 1, rWQP\nStyleCellDisplayCenter)
          WQP_populateLength(k)                                                                           ; File Length
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 5, timeToStringBWZT(aAud(k)\nStartAt, nFileDuration))      ; Start At
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 5, rWQP\nStyleCellEditLeft)
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 6, timeToStringBWZT(aAud(k)\nEndAt, nFileDuration))        ; End At
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 6, rWQP\nStyleCellEditLeft)
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 7, timeToStringBWZT(aAud(k)\nCueDuration, nFileDuration))  ; Play Length
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 7, rWQP\nStyleCellDisplayLeft)
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 8, StrF(aAud(k)\fPLRelLevel,0)+"%")                        ; Relative level
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 8, rWQP\nStyleCellDisplayLeft)
        EndIf
        If k = nFirstPlayIndex
          nFirstPlayListIndex = ListIndex(WQPFile())
        EndIf
        If k = nCurrPlayIndex
          nCurrPlayListIndex = ListIndex(WQPFile())
        EndIf
        k = aAud(k)\nNextAudIndex
      Wend
      createWQPFile() ; extra row for inserts
      rWQP\nExtraRowNo = nGrdRowNo + 1
      WQP_populateExtraRow()
;       nGrdRowNo + 1
;       MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 3, "...")
;       MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 3, rWQP\nStyleCellButton)
;       rWQP\nExtraRowNo = nGrdRowNo
;       debugMsg(sProcName, "rWQP\nExtraRowNo=" + rWQP\nExtraRowNo)
;       debugMsg(sProcName, "calling MyGrid_ReDefineRows(" + getGadgetName(nGrdPlaylist) + ", " + nGrdRowNo + ")")
;       MyGrid_ReDefineRows(nGrdPlaylist, nGrdRowNo)
      ForEach WQPFile()
        debugMsg(sProcName, "ListIndex(WQPFile())=" + ListIndex(WQPFile()) + ", WQPFile()\nAudPtr=" + getAudLabel(WQPFile()\nAudPtr))
      Next WQPFile()

    CompilerElse
      k = \nFirstAudIndex
      While k >= 0
        ; debugMsg(sProcName, "k=" + k)
        createWQPFile()   ; add an entry to the linked list WQPFile() and create the associated gadgets
        WQPFile()\nAudPtr = k
        WQPFile()\nFileNameLen = Len(aAud(k)\sStoredFileName)
        nGadgetNo = WQPFile()\txtFileNameP
        If grEditorPrefs\bShowFileFoldersInEditor
          SGT(nGadgetNo, aAud(k)\sStoredFileName)
        Else
          SGT(nGadgetNo, GetFilePart(aAud(k)\sStoredFileName))
        EndIf
        scsToolTip(WQPFile()\txtFileNameP, aAud(k)\sFileName)
        If Trim(aAud(k)\sFileName)
          setDerivedAudFields(k)
          nFileDuration = aAud(k)\nFileDuration
          SGT(WQPFile()\txtTrkNo, Str(aAud(k)\nAudNo))                                         ; No.
          WQP_populateLength(k)                                                                ; File Length
          SGT(WQPFile()\txtStartAt, timeToStringBWZT(aAud(k)\nStartAt, nFileDuration))         ; Start At
          SGT(WQPFile()\txtEndAt, timeToStringBWZT(aAud(k)\nEndAt, nFileDuration))             ; End At
          SGT(WQPFile()\txtPlayLength, timeToStringBWZT(aAud(k)\nCueDuration, nFileDuration))  ; Play Length
          SGT(WQPFile()\txtRelLevel, StrF(aAud(k)\fPLRelLevel,0)+"%")
        EndIf
        If k = nFirstPlayIndex
          nFirstPlayListIndex = ListIndex(WQPFile())
        EndIf
        If k = nCurrPlayIndex
          nCurrPlayListIndex = ListIndex(WQPFile())
        EndIf
        k = aAud(k)\nNextAudIndex
        nGrdRowNo + 1
      Wend
      createWQPFile() ; extra row for inserts
    CompilerEndIf
    
    If nCurrPlayListIndex >= 0
      debugMsg(sProcName, "calling WQP_setCurrentRow(" + nCurrPlayListIndex + ")")
      WQP_setCurrentRow(nCurrPlayListIndex)
    Else
      debugMsg(sProcName, "calling WQP_setCurrentRow(" + nFirstPlayListIndex + ")")
      WQP_setCurrentRow(nFirstPlayListIndex)
    EndIf
    
    debugMsg(sProcName, "nEditAudPtr=" + nEditAudPtr)
    
    debugMsg(sProcName, "calling calcPLTotalTime(" + getSubLabel(pSubPtr) + ")")
    calcPLTotalTime(pSubPtr)
    If \nSubState = #SCS_CUE_ERROR
      SGT(WQP\txtPLTotalTime, "")
    Else
      SGT(WQP\txtPLTotalTime, timeToStringBWZ(\nPLTotalTime))
    EndIf
    SGS(WQP\cboPLTestMode, gnPLTestMode)
    SLD_setMax(WQP\sldPLProgress[1], \nPLTestTime)
    WQP_buildPlayOrderLBL()
    
  EndWith
  
  k = aSub(pSubPtr)\nCurrPlayIndex
  If k >= 0
    If (aAud(k)\sFileName) And (aAud(k)\nFileState = #SCS_FILESTATE_CLOSED)
      openMediaFile(k)
    EndIf
  EndIf
  
  rWQP\bCallSetOrigDBLevels = #True
  
  gbCallEditUpdateDisplay = #True
  editSetDisplayButtonsP()
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQP_displayDev()
  PROCNAMEC()
  Protected d
  Protected nListIndex
  Protected sMyTracks.s

  gbInDisplayDev = #True
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        
        SGT(WQP\lblPLDevNo[d], Str(d + 1))
        If Len(\sPLLogicalDev[d]) > 0
          nListIndex = indexForComboBoxRow(WQP\cboPLLogicalDev[d], \sPLLogicalDev[d])
          SGS(WQP\cboPLLogicalDev[d], nListIndex)
        Else
          SGS(WQP\cboPLLogicalDev[d], 0)
        EndIf
        WQP_fcLogicalDevP(d)
        
        populateCboTracksForSub(WQP\cboPLTracks[d], nEditSubPtr, d)
        sMyTracks = \sPLTracks[d]
        If Len(sMyTracks) = 0
          sMyTracks = #SCS_TRACKS_DFLT
        EndIf
        nListIndex = indexForComboBoxRow(WQP\cboPLTracks[d], sMyTracks, -1)
        If GGS(WQP\cboPLTracks[d]) <> nListIndex
          SGS(WQP\cboPLTracks[d], nListIndex)
        EndIf
        
        SLD_setMax(WQP\sldSubLevel[d], #SCS_MAXVOLUME_SLD)
        SLD_setLevel(WQP\sldSubLevel[d], \fSubMastBVLevel[d], \fSubTrimFactor[d])
        SLD_setBaseLevel(WQP\sldSubLevel[d], #SCS_SLD_BASE_EQUALS_CURRENT)
        SLD_setMax(WQP\sldSubPan[d], #SCS_MAXPAN_SLD)   ; forces control to be formatted
        SLD_setValue(WQP\sldSubPan[d], panToSliderValue(\fPLPan[d]))
        SLD_setBaseValue(WQP\sldSubPan[d], #SCS_SLD_BASE_EQUALS_CURRENT)
        If Len(Trim(\sPLDBTrim[d])) = 0
          nListIndex = 0
        Else
          nListIndex = indexForComboBoxRow(WQP\cboSubTrim[d], \sPLDBTrim[d])
        EndIf
        If GetGadgetState(WQP\cboSubTrim[d]) <> nListIndex
          SGS(WQP\cboSubTrim[d], nListIndex)
        EndIf
        
        SGT(WQP\txtSubDBLevel[d], convertBVLevelToDBString(\fSubMastBVLevel[d], #False, #True))
        SGT(WQP\txtSubPan[d], panSingleToString(\fPLPan[d]))
      Next d
    EndWith
  EndIf
  
  gbInDisplayDev = #False
  
EndProcedure

Procedure WQP_buildPlayOrderLBL()
  PROCNAMEC()
  Protected sText.s
  
  If aSub(nEditSubPtr)\nSubState >= #SCS_CUE_FADING_IN And aSub(nEditSubPtr)\nSubState <= #SCS_CUE_FADING_OUT
    ProcedureReturn
  EndIf

  sText = Lang("WQP", "lblPlayOrder") + ": "    ; = "Play order: "
  If gnPLTestMode = #SCS_PLTESTMODE_HIGHLIGHTED_FILE
    ; test play one file only
    If nEditAudPtr >= 0
      sText + Str(aAud(nEditAudPtr)\nAudNo)
    EndIf
  Else
    ; test play all files
    sText + aSub(nEditSubPtr)\sPlayOrder
    If ListSize(WQPFile()) > 0
      If ListIndex(WQPFile()) >= 0
        sText + " " + Lang("WQP", "StartingAtTrack") + " " + Str(ListIndex(WQPFile())+1)
      EndIf
    EndIf
  EndIf
  SGT(WQP\lblPlayOrder, sText)
EndProcedure

Procedure WQP_setcboPLLogicalDevsEnabled()
  PROCNAMECS(nEditSubPtr)
  Protected bAvailable, d
  
  debugMsg(sProcName, #SCS_START)
  
  ; 1st dev available in all levels
  ; debugMsg(sProcName, "WQP\cboPLLogicalDev[0]=" + Str(WQP\cboPLLogicalDev[0]))
  setEnabled(WQP\cboPLLogicalDev[0], #True)
  
  If grLicInfo\nMaxAudDevPerSub > 0
    
    ; 2nd dev available in SCS-Std and above
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      bAvailable = #True
    EndIf
    
    ; debugMsg(sProcName, "WQP\cboPLLogicalDev[1]=" + Str(WQP\cboPLLogicalDev[1]))
    setEnabled(WQP\cboPLLogicalDev[1], bAvailable)
    
    ; 3rd and higher devs available in SCS-Pro and above
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      bAvailable = #True
    Else
      bAvailable = #False
    EndIf
    
    For d = 2 To grLicInfo\nMaxAudDevPerSub
      ; debugMsg(sProcName, "WQP\cboPLLogicalDev[" + Str(d) + "]=" + Str(WQP\cboPLLogicalDev[d]))
      setEnabled(WQP\cboPLLogicalDev[d], bAvailable)
    Next d
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_setCboPLTracksEnabled(nIndex=-1)
  PROCNAMECS(nEditSubPtr)
  Protected bAvailable, d
  Protected nStart, nEnd
  Protected k, nMaxFileChannels
  
  debugMsg(sProcName, #SCS_START)
  
  If nIndex = -1
    nStart = 0
    nEnd = grLicInfo\nMaxAudDevPerSub
  Else
    nStart = nIndex
    nEnd = nIndex
  EndIf
  
  If nEditSubPtr >= 0
    k = aSub(nEditSubPtr)\nFirstAudIndex
    While k >= 0
      If aAud(k)\nFileChannels > nMaxFileChannels
        nMaxFileChannels = aAud(k)\nFileChannels
      EndIf
      k = aAud(k)\nNextAudIndex
    Wend
  EndIf
  
  For d = nStart To nEnd
    bAvailable = #False
    If gbUseSMS
      If getEnabled(WQP\cboPLLogicalDev[d]) And Len(Trim(GGT(WQP\cboPLLogicalDev[d]))) > 0
        If nMaxFileChannels > 0
          bAvailable = #True
        EndIf
      EndIf
    EndIf
    setEnabled(WQP\cboPLTracks[d], bAvailable)
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_btnPLCenter_Click(Index)
  SLD_setValue(WQP\sldSubPan[Index], #SCS_PANCENTRE_SLD)
  WQP_fcSldPanP(Index)
EndProcedure

Procedure WQP_transportBtnClick(nButtonType)
  PROCNAMEC()
  Protected k, bValidateOK
  Protected nState
  
  gqTimeNow = ElapsedMilliseconds()
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_REWIND  ; rewind
      debugMsg(sProcName, "rewind")
      debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + aAud(nEditAudPtr)\nAbsStartAt + ")")
      reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt)
      If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
        audSetState(nEditAudPtr, #SCS_CUE_READY, 10)
        setCueState(nEditCuePtr)
      EndIf
      editSetDisplayButtonsP()
      gbCallEditUpdateDisplay = #True
      
    Case #SCS_STANDARD_BTN_PLAY  ; play
      debugMsg(sProcName, "play")
      
      With aSub(nEditSubPtr)
        k = \nFirstAudIndex
        bValidateOK = #True
        While k >= 0 And bValidateOK
          bValidateOK = valAud(k)
          k = aAud(k)\nNextAudIndex
        Wend
        
        If bValidateOK = #False
          ProcedureReturn
        EndIf
        
        ; call setDerivedSubFields() so that the \nPLPlayLevel[] fields get set, or else the test will be silent!
        setDerivedSubFields(nEditSubPtr)
        setCueState(nEditCuePtr) ; Added 3Dec2021 11.8.6cp to ensure aSub(neditsubPtr)\nSubState is correctly set
        
        \bPLTerminating = #False
        \bPLFadingIn = #False
        \bPLFadingOut = #False
        \bStartedInEditor = #True
        debugMsg(sProcName, "\nSubState=" + decodeCueState(\nSubState))
        
        WQP_fcPLTestMode()
        Select gnPLTestMode
          Case #SCS_PLTESTMODE_COMPLETE_PLAYLIST, #SCS_PLTESTMODE_10_SECS, #SCS_PLTESTMODE_5_SECS
            nState = \nSubState
          Case #SCS_PLTESTMODE_HIGHLIGHTED_FILE
            nState = aAud(nEditAudPtr)\nAudState
        EndSelect
        
        If nState = #SCS_CUE_PAUSED
          resumeAud(nEditAudPtr)
          
        ElseIf (nState < #SCS_CUE_FADING_IN) Or (nState = #SCS_CUE_PL_READY)
          If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
            openMediaFile(nEditAudPtr)
          EndIf
          If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
            If ListIndex(WQPFile()) >= 0
              rWQP\nStartTrkNo = ListIndex(WQPFile()) + 1
            Else
              rWQP\nStartTrkNo = aAud(\nFirstPlayIndex)\nAudNo
              SelectElement(WQPFile(), rWQP\nStartTrkNo - 1)
            EndIf
            debugMsg(sProcName, "rWQP\nStartTrkNo=" + rWQP\nStartTrkNo)
            \nCurrPlayIndex = nEditAudPtr
            debugMsg(sProcName, "gnPLTestMode=" + Str(gnPLTestMode) + ", \nCurrPlayIndex=" + Str(\nCurrPlayIndex))
            WQP_highlightPlayListRow()
            debugMsg(sProcName, "calling editPlaySub(-1, " + Str(rWQP\nStartTrkNo) + ")")
            editPlaySub(-1, rWQP\nStartTrkNo)
          Else
            debugMsg(sProcName, "calling rewindAud(" + getAudLabel(nEditAudPtr) + ")")
            rewindAud(nEditAudPtr)
            debugMsg(sProcName, "calling playAud(" + getAudLabel(nEditAudPtr) + ")")
            playAud(nEditAudPtr)
            debugMsg(sProcName, "calling calcPLUnplayedFilesTime(" + getSubLabel(nEditSubPtr) + ")")
            calcPLUnplayedFilesTime(nEditSubPtr)
          EndIf
          
        Else
          If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
            If ListIndex(WQPFile()) >= 0
              rWQP\nStartTrkNo = ListIndex(WQPFile()) + 1
            Else
              rWQP\nStartTrkNo = aAud(\nFirstPlayIndex)\nAudNo
              SelectElement(WQPFile(), rWQP\nStartTrkNo - 1)
            EndIf
            debugMsg(sProcName, "rWQP\nStartTrkNo=" + rWQP\nStartTrkNo)
            \nCurrPlayIndex = nEditAudPtr
            debugMsg(sProcName, "gnPLTestMode=" + gnPLTestMode + ", \nCurrPlayIndex=" + \nCurrPlayIndex)
            WQP_highlightPlayListRow()
            editPLRestart()
          Else
            rWQP\nStartTrkNo = aAud(nEditAudPtr)\nAudNo
            debugMsg(sProcName, "rWQP\nStartTrkNo=" + rWQP\nStartTrkNo)
            SelectElement(WQPFile(), rWQP\nStartTrkNo - 1)
            WQP_highlightPlayListRow()
            editPLRestart()
          EndIf
          
        EndIf
      EndWith
      ; fmEditor\tmrEditPlay\Enabled = #True
      debugMsg(sProcName, "calling editSetDisplayButtonsP()")
      editSetDisplayButtonsP()
      
    Case #SCS_STANDARD_BTN_PAUSE  ; pause
      debugMsg(sProcName, "pause")
      pauseAud(nEditAudPtr)
      editSetDisplayButtonsP()
      
    Case #SCS_STANDARD_BTN_FADEOUT  ; fadeout
      debugMsg(sProcName, "fadeout")
      fadeOutSub(nEditSubPtr, #False)
      editSetDisplayButtonsP()
      
    Case #SCS_STANDARD_BTN_STOP  ; stop
      debugMsg(sProcName, "stop")
      editPLStop(nEditSubPtr)
      editSetDisplayButtonsP()
      
    Case #SCS_STANDARD_BTN_SHUFFLE  ; shuffle
      debugMsg(sProcName, "shuffle")
      debugMsg(sProcName, "calling generatePlayOrder(" + nEditSubPtr + ")")
      generatePlayOrder(nEditSubPtr, #True)
      WQP_buildPlayOrderLBL()
      debugMsg(sProcName, "calling WQP_doPLTotals()")
      WQP_doPLTotals()
      
  EndSelect
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_cboPLLogicalDev_Click(Index)
  PROCNAMEC()
  Protected d, k
  Protected sNewLogicalDev.s, nNewBassDevice
  Protected sOldLogicalDev.s
  Protected bFound
  Protected u, u2
  Protected sMyTracks.s, nListIndex
  Protected nNrOfOutputChans
  Protected nCurrPlayListIndex
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  rWQP\bInLogicalDevClick = #True
  
  With aSub(nEditSubPtr)
    bFound = #False
    sOldLogicalDev = \sPLLogicalDev[Index]
    sNewLogicalDev = ""
    nNewBassDevice = 0
    For d = 0 To grProd\nMaxAudioLogicalDev
      If Len(grProd\aAudioLogicalDevs(d)\sLogicalDev) > 0
        If grProd\aAudioLogicalDevs(d)\sLogicalDev = Trim(GGT(WQP\cboPLLogicalDev[Index]))
          bFound = #True
          sNewLogicalDev = grProd\aAudioLogicalDevs(d)\sLogicalDev
          nNewBassDevice = grProd\aAudioLogicalDevs(d)\nBassDevice
          nNrOfOutputChans = grProd\aAudioLogicalDevs(d)\nNrOfOutputChans
          Break
        EndIf
      EndIf
    Next d
    
    If sNewLogicalDev <> \sPLLogicalDev[Index]
      u = preChangeSubS(\sPLLogicalDev[Index], GGT(WQP\lblPLSoundDevices), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      If bFound
        \sPLLogicalDev[Index] = sNewLogicalDev
        debugMsg(sProcName, "sOldLogicalDev=" + sOldLogicalDev + ", \fSubMastBVLevel[" + Index + "]=" + traceLevel(\fSubMastBVLevel[Index]) + ", #SCS_MINVOLUME_SINGLE=" + traceLevel(#SCS_MINVOLUME_SINGLE))
        If (Len(sOldLogicalDev) = 0) And (\fSubMastBVLevel[Index] = #SCS_MINVOLUME_SINGLE)
          debugMsg(sProcName, "new device")
          ; for a new device set the level at normal, but if this is not the first device then set the level the same as the previous device (if set)
          If CountGadgetItems(WQP\cboPLTracks[Index]) = 0
            populateCboTracksForSub(WQP\cboPLTracks[Index], nEditSubPtr, Index)
          EndIf
          \sPLTracks[Index] = ""
          sMyTracks = #SCS_TRACKS_DFLT
          nListIndex = indexForComboBoxRow(WQP\cboPLTracks[Index], sMyTracks, -1)
          debugMsg(sProcName, "sMyTracks=" + sMyTracks + ", nListIndex=" + nListIndex)
          If GGS(WQP\cboPLTracks[Index]) <> nListIndex And nListIndex >= 0
            SGS(WQP\cboPLTracks[Index], nListIndex)
          EndIf
          
          \fSubTrimFactor[Index] = 1
          \fSubMastBVLevel[Index] = #SCS_NORMALVOLUME_SINGLE
          \fPLPan[Index] = #SCS_PANCENTRE_SINGLE
          If Index > 0
            If Len(\sPLLogicalDev[Index-1]) > 0
              \fSubTrimFactor[Index] = \fSubTrimFactor[Index-1]
              \fSubMastBVLevel[Index] = \fSubMastBVLevel[Index-1]
              \fPLPan[Index] = \fPLPan[Index-1]
            EndIf
          EndIf
          \fSubBVLevelNow[Index] = \fSubMastBVLevel[Index]
          \fSubPanNow[Index] = \fPLPan[Index]
        EndIf
      Else
        debugMsg(sProcName, "blank device")
        ; new device is blank
        \sPLLogicalDev[Index] = ""
        \fSubTrimFactor[Index] = 1
        \fSubMastBVLevel[Index] = #SCS_MINVOLUME_SINGLE
        \fPLPan[Index] = #SCS_PANCENTRE_SINGLE
        \fSubBVLevelNow[Index] = \fSubMastBVLevel[Index]
        \fSubPanNow[Index] = \fPLPan[Index]
      EndIf
      
      debugMsg(sProcName, "nNrOfOutputChans=" + Str(nNrOfOutputChans))
      If nNrOfOutputChans <> 2
        \fPLPan[Index] = #SCS_PANCENTRE_SINGLE
        \fSubPanNow[Index] = \fPLPan[Index]
      EndIf
      
      k = \nFirstAudIndex
      While k >= 0
        u2 = preChangeAudS(aAud(k)\sLogicalDev[Index], GGT(WQP\lblPLSoundDevices), k, #SCS_UNDO_ACTION_CHANGE, Index, #SCS_UNDO_FLAG_OPEN_FILE)
        ; close current channel if open
        freeOneAudStream(k, Index)
        aAud(k)\sLogicalDev[Index] = sNewLogicalDev
        aAud(k)\nBassDevice[Index] = nNewBassDevice
        ; re-open sound file to use new device
        setFirstAndLastDev(k)
        openMediaFile(k)
        postChangeAudS(u2, aAud(k)\sLogicalDev[Index], k, Index)
        k = aAud(k)\nNextAudIndex
      Wend
      
      If (SLD_getLevel(WQP\sldSubLevel[Index]) <> \fSubMastBVLevel[Index]) Or (SLD_getTrimFactor(WQP\sldSubLevel[Index]) <> \fSubTrimFactor[Index])
        SLD_setLevel(WQP\sldSubLevel[Index], \fSubMastBVLevel[Index], \fSubTrimFactor[Index])
        WQP_fcSldLevelP(Index)
        If bFound
          SGT(WQP\txtSubDBLevel[Index], convertBVLevelToDBString(\fSubMastBVLevel[Index]))
        Else
          SGT(WQP\txtSubDBLevel[Index], "")
        EndIf
      EndIf
      
      If SLD_getValue(WQP\sldSubPan[Index]) <> panToSliderValue(\fPLPan[Index])
        SLD_setValue(WQP\sldSubPan[Index], panToSliderValue(\fPLPan[Index]))
        WQP_fcSldPanP(Index)
      EndIf
      
    EndIf
    
    debugMsg(sProcName, "calling WQP_fcLogicalDevP(" + Index + ")")
    WQP_fcLogicalDevP(Index)
    
    nCurrPlayListIndex = rWQP\nCurrPlayListIndex
    debugMsg(sProcName, "nCurrPlayListIndex=" + Str(nCurrPlayListIndex))
    
    debugMsg(sProcName, "calling WQP_displayPlayList(#False)")
    WQP_displayPlayList(#False)
    
    debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
    WQP_updateAudsFromWQPFile(nEditSubPtr)
    
    debugMsg(sProcName, "calling WQP_setCurrentRow(" + Str(nCurrPlayListIndex) + ")")
    WQP_setCurrentRow(nCurrPlayListIndex)
    
    editSetDisplayButtonsP()
    gbCallEditUpdateDisplay = #True
    
    postChangeSubS(u, \sPLLogicalDev[Index], -5, Index)
    
  EndWith
  
  rWQP\bInLogicalDevClick = #False

EndProcedure

Procedure WQP_cboPLTestMode_Click()
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START)
  WQP_fcPLTestMode()
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQP_cboPLTracks_Click(Index)
  PROCNAMEC()
  Protected sOldLogicalDev.s
  Protected bFound
  Protected u, u2
  Protected k
  
  If rWQP\bInLogicalDevClick
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With aSub(nEditSubPtr)
    If \sPLTracks[Index] <> GGT(WQP\cboPLTracks[Index])
      u = preChangeSubS(\sPLTracks[Index], GGT(WQP\lblPLTracks), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \sPLTracks[Index] = GGT(WQP\cboPLTracks[Index])
      
      k = \nFirstAudIndex
      While k >= 0
        If aAud(k)\nFileState = #SCS_FILESTATE_OPEN
          u2 = preChangeAudL(#False, GGT(WQP\lblPLTracks), k, #SCS_UNDO_ACTION_CHANGE, Index, #SCS_UNDO_FLAG_OPEN_FILE)
          ; close current channel if open
          freeOneAudStream(k, Index)
          ; re-open sound file to re-assign crosspoints
          openMediaFile(k)
          postChangeAudL(u2, #True, k, Index)
        EndIf
        k = aAud(k)\nNextAudIndex
      Wend
      
      postChangeSubS(u, \sPLTracks[Index], -5, Index)
      
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_cboTransType_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u

  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudL(\nPLTransType, GGT(WQP\lblTransType))
      \nPLTransType = getCurrentItemData(WQP\cboTransType, #SCS_TRANS_NONE)
      \nPLRunTimeTransType = \nPLTransType
      WQP_fcTransType()
      debugMsg(sProcName, "calling WQP_doPLTotals()")
      WQP_doPLTotals()
      WQP_setApplyToAllButton()
      postChangeAudLN(u, \nPLTransType)
    EndWith
  EndIf
EndProcedure

Procedure WQP_cboSubTrim_Click(Index)
  PROCNAMEC()
  Protected u
  Protected fOldTrim.f, fNewTrim.f
  Protected fOldDBLevelSingle.f, fNewDBLevelSingle.f
  Protected fOldLevel.f, fNewLevel.f
  
  If rWQP\bInLogicalDevClick
    ProcedureReturn
  EndIf

  With aSub(nEditSubPtr)
    If \sPLDBTrim[Index] <> GGT(WQP\cboSubTrim[Index])
      u = preChangeSubS(\sPLDBTrim[Index], GGT(WQP\lblSubTrim), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      fOldTrim = dbTrimStringToSingle(\sPLDBTrim[Index])
      fNewTrim = getCurrentItemData(WQP\cboSubTrim[Index])
      fOldDBLevelSingle = convertDBStringToDBLevel(\sPLMastDBLevel[Index])
      fNewDBLevelSingle = fOldDBLevelSingle + (fNewTrim - fOldTrim)
      If fNewDBLevelSingle > grProd\nMaxDBLevel
        fNewDBLevelSingle = grProd\nMaxDBLevel
      ElseIf fNewDBLevelSingle < grProd\nMinDBLevel
        fNewDBLevelSingle = grProd\nMinDBLevel
      EndIf
      \sPLDBTrim[Index] = GGT(WQP\cboSubTrim[Index])
      \sPLMastDBLevel[Index] = StrF(fNewDBLevelSingle,1)
      \fSubMastBVLevel[Index] = convertDBStringToBVLevel(\sPLMastDBLevel[Index])
      \fSubTrimFactor[Index] = dbTrimStringToFactor(\sPLDBTrim[Index])
      SLD_setLevel(WQP\sldSubLevel[Index], \fSubMastBVLevel[Index], \fSubTrimFactor[Index])
      WQP_fcSldLevelP(Index)
      SGT(WQP\txtSubDBLevel[Index], \sPLMastDBLevel[Index])
      postChangeSubSN(u, \sPLDBTrim[Index], -5, Index)
    EndIf
  EndWith

EndProcedure

Procedure WQP_chkPLRepeat_Click()
  PROCNAMEC()
  Protected u
  Protected bPLRepeat

  With aSub(nEditSubPtr)
    bPLRepeat = getOwnState(WQP\chkPLRepeat)
    If bPLRepeat <> \bPLRepeat
      u = preChangeSubL(\bPLRepeat, getOwnText(WQP\chkPLRepeat))
      \bPLRepeat = bPLRepeat
      \bPLRepeatCancelled = #False
      generatePlayOrder(nEditSubPtr, #True)
      WQP_buildPlayOrderLBL()
      WQP_doPLTotals()
      postChangeSubL(u, \bPLRepeat)
    EndIf
  EndWith
EndProcedure

Procedure WQP_chkPLRandom_Click()
  PROCNAMEC()
  Protected u
  Protected bPLRandom

  debugMsg(sProcName, #SCS_START)
  With aSub(nEditSubPtr)
    bPLRandom = getOwnState(WQP\chkPLRandom)
    debugMsg(sProcName, "bPLRandom=" + strB(bPLRandom))
    If bPLRandom <> \bPLRandom
      u = preChangeSubL(\bPLRandom, getOwnText(WQP\chkPLRandom))
      \bPLRandom = bPLRandom
      debugMsg(sProcName, "calling generatePlayOrder(" + nEditSubPtr + ")")
      generatePlayOrder(nEditSubPtr, #True)
      WQP_buildPlayOrderLBL()
      debugMsg(sProcName, "calling WQP_doPLTotals()")
      WQP_doPLTotals()
      postChangeSubL(u, \bPLRandom)
    EndIf
    setEnabled(WQP\btnPLShuffle, \bPLRandom)
  EndWith
EndProcedure

Procedure WQP_chkPLSavePos_Click()
  PROCNAMEC()
  Protected u
  Protected bPLSavePos

  debugMsg(sProcName, #SCS_START)
  With aSub(nEditSubPtr)
    bPLSavePos = getOwnState(WQP\chkPLSavePos)
    debugMsg(sProcName, "bPLSavePos=" + strB(bPLSavePos))
    If bPLSavePos <> \bPLSavePos
      u = preChangeSubL(\bPLSavePos, getOwnText(WQP\chkPLSavePos))
      \bPLSavePos = bPLSavePos
      debugMsg(sProcName, "calling generatePlayOrder(" + nEditSubPtr + ")")
      generatePlayOrder(nEditSubPtr, #True)
      WQP_buildPlayOrderLBL()
      debugMsg(sProcName, "calling WQP_doPLTotals()")
      WQP_doPLTotals()
      postChangeSubL(u, \bPLSavePos)
    EndIf
  EndWith
EndProcedure

Procedure WQP_btnApplyToAll_Click()
  PROCNAMEC()
  Protected k, nPLTransType, nPLTransTime
  Protected u, u2
  
  If nEditSubPtr < 0 Or nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  u = preChangeSubL(#True, GetGadgetText(WQP\btnApplyToAll))
  
  With aAud(nEditAudPtr)
    nPLTransType = \nPLTransType
    nPLTransTime = \nPLTransTime
  EndWith

  k = aSub(nEditSubPtr)\nFirstAudIndex
  While k >= 0
    With aAud(k)
      u2 = preChangeAuds(decodeTransType(\nPLTransType) + \nPLTransTime, GGT(WQP\lblTransType), k)
      \nPLTransType = nPLTransType
      \nPLTransTime = nPLTransTime
      \nPLRunTimeTransType = \nPLTransType
      \nPLRunTimeTransTime = \nPLTransTime
      postChangeAudS(u2, decodeTransType(\nPLTransType) + \nPLTransTime, k)
      k = \nNextAudIndex
    EndWith
  Wend
  
  setPLFades(nEditSubPtr)
  WQP_doPLTotals()
  WQP_setApplyToAllButton()
  
  postChangeSubL(u, #False)

EndProcedure

Procedure WQP_drawForm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  colorEditorComponent(#WQP)
  
  With WQP
    ; ; color the read-only string fields for file title
    ; SetGadgetColor(\txtPLTitle, #PB_Gadget_FrontColor, rColorScheme\nTextColorP)
    ; SetGadgetColor(\txtPLTitle, #PB_Gadget_BackColor, rColorScheme\nBackColorP1)
    SetGadgetColor(\txtPLTitle, #PB_Gadget_BackColor, #SCS_Disabled_Textbox_Back_Color)
  EndWith
  ; setEnabled(WQP\txtPLTitle, #False)

EndProcedure

Procedure WQP_Form_Load()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQP()
  SUB_loadOrResizeHeaderFields("P", #True)
  CompilerIf #c_include_mygrid_for_playlists
    WQP_setupGrdPlaylist()
  CompilerEndIf
  
  CompilerIf #c_include_mygrid_for_playlists = #False
    EnableGadgetDrop(WQP\scaFiles, #PB_Drop_Files, #PB_Drag_Copy) ; nb 'drop' processed by WED_DropCallback()
  CompilerEndIf

  rWQP\bInValidate = #False
  
  With rWQP
    \nCurrPlayListIndex = -1
  EndWith

  With WQP
    
    For n = 0 To grLicInfo\nMaxAudDevPerSub
      populateCboTrim(\cboSubTrim[n])
    Next n
    
    ; populate \cboTransType
    ClearGadgetItems(\cboTransType)
    addGadgetItemWithData(\cboTransType, Lang("WQP", "cboTransTypeNone"), #SCS_TRANS_NONE)
    addGadgetItemWithData(\cboTransType, Lang("WQP", "cboTransTypeCrossFade"), #SCS_TRANS_XFADE)
    addGadgetItemWithData(\cboTransType, Lang("WQP", "cboTransTypeMix"), #SCS_TRANS_MIX)
    addGadgetItemWithData(\cboTransType, Lang("WQP", "cboTransTypeWait"), #SCS_TRANS_WAIT)
    
    ; populate \cboPLTestMode
    ClearGadgetItems(\cboPLTestMode)
    AddGadgetItem(\cboPLTestMode, -1, Lang("WQP", "PLTestMode0"))    ; complete playlist
    AddGadgetItem(\cboPLTestMode, -1, Lang("WQP", "PLTestMode1"))    ; first and last 10 secs of each
    AddGadgetItem(\cboPLTestMode, -1, Lang("WQP", "PLTestMode2"))    ; first and last 5 secs of each
    AddGadgetItem(\cboPLTestMode, -1, Lang("WQP", "PLTestMode3"))    ; highlighted file only
    
    WQP_drawForm()
    
    ; Call "SLD_ToolTip(\sldPLProgress[0], #SCS_SLD_TTA_BUILD, ...)" now because if we wait until the tooltip is required then the first time the tooltip
    ; is displayed it will be displayed blank. I don't know why - tried adding some timing delays but they didn't help. But by 'building' the tooltip
    ; early (eg on creating the form), the tooltip displays correctly every time.
    ; Similarly for WQA and WQF.
    gaSlider(\sldPLProgress[0])\nSliderToolTipType = #SCS_SLD_TTT_GENERAL
    SLD_ToolTip(\sldPLProgress[0], #SCS_SLD_TTA_BUILD, buildSkipBackForwardTooltip())
  
  EndWith
  
  ; debugCuePtrs()
  
EndProcedure

Procedure WQP_Form_Unload(Cancel)
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START)
EndProcedure

Procedure WQP_txtPLFadeInTime_Validate()
  PROCNAMEC()
  Protected u

  If rWQP\bInValidate : ProcedureReturn #True : EndIf
  rWQP\bInValidate = #True

  With aSub(nEditSubPtr)
    If validateTimeFieldT(GGT(WQP\txtPLFadeInTime), GGT(WQP\lblPLFadeInTime), #False, #False, \nPLFadeInTime) = #False
      rWQP\bInValidate = #False
      ProcedureReturn #False
    ElseIf GGT(WQP\txtPLFadeInTime) <> gsTmpString
      SGT(WQP\txtPLFadeInTime, gsTmpString)
    EndIf
    
    u = preChangeSubL(\nPLFadeInTime, GGT(WQP\lblPLFadeInTime))
    \nPLFadeInTime = stringToTime(GGT(WQP\txtPLFadeInTime))
    \nPLCurrFadeInTime = \nPLFadeInTime
    postChangeSubLN(u, \nPLFadeInTime)
  EndWith
  rWQP\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQP_txtPLFadeOutTime_Validate()
  PROCNAMEC()
  Protected u

  If rWQP\bInValidate : ProcedureReturn #True : EndIf
  rWQP\bInValidate = #True

  With aSub(nEditSubPtr)
    If validateTimeFieldT(GGT(WQP\txtPLFadeOutTime), GGT(WQP\lblPLFadeOutTime), #False, #False, \nPLFadeOutTime) = #False
      rWQP\bInValidate = #False
      ProcedureReturn #False
    ElseIf GGT(WQP\txtPLFadeOutTime) <> gsTmpString
      SGT(WQP\txtPLFadeOutTime, gsTmpString)
    EndIf
    
    u = preChangeSubL(\nPLFadeOutTime, GGT(WQP\lblPLFadeOutTime))
    \nPLFadeOutTime = stringToTime(GGT(WQP\txtPLFadeOutTime))
    \nPLCurrFadeOutTime = \nPLFadeOutTime
    postChangeSubLN(u, \nPLFadeOutTime)
  EndWith
  rWQP\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQP_txtSubDBLevel_Validate(Index)
  PROCNAMEC()
  Protected u

  If validateDbField(GGT(WQP\txtSubDBLevel[Index]), GGT(WQP\lblMastDb)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WQP\txtSubDBLevel[Index]) <> gsTmpString
    SGT(WQP\txtSubDBLevel[Index], gsTmpString)
  EndIf
  
  WQP_fcTxtDBLevelP(Index)
  ProcedureReturn #True

EndProcedure

Procedure WQP_txtSubPan_Validate(Index)
  PROCNAMEC()
  Protected u

  If validatePanTextField(GGT(WQP\txtSubPan[Index]), "Pan") = #False
    ProcedureReturn #False
  EndIf

  With aSub(nEditSubPtr)
    u = preChangeSubF(\fPLPan[Index], GGT(WQP\lblSubPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fPLPan[Index] = panStringToSingle(GGT(WQP\txtSubPan[Index]))
    WQP_fcTxtPanP(Index)
    postChangeSubFN(u, \fPLPan[Index], -5, Index)
  EndWith
EndProcedure

Procedure WQP_txtTransTime_Change()
  PROCNAMEC()
  If gbInDisplaySub = #False
    WQP_setApplyToAllButton(#True)
  EndIf
EndProcedure

Procedure WQP_txtTransTime_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sTransTime.s

  If rWQP\bInValidate
    ProcedureReturn #True
  EndIf
  rWQP\bInValidate = #True
  
  With aAud(nEditAudPtr)
    If validateTimeFieldT(GGT(WQP\txtTransTime), GGT(WQP\lblTransTime), #False, #False, \nFileDuration) = #False
      rWQP\bInValidate = #False
      ProcedureReturn #False
;     ElseIf GGT(WQP\txtTransTime) <> gsTmpString
;       SGT(WQP\txtTransTime, gsTmpString)
    EndIf
    
    u = preChangeAudL(\nPLTransTime, GGT(WQP\lblTransTime))
    \nPLTransTime = stringToTime(GGT(WQP\txtTransTime))
    \nPLRunTimeTransTime = \nPLTransTime
    ; Added 24Feb2024 11.10.2aw to replace commented out code above which displayed a full time field, eg 0:02.000 instead of 2.000
    sTransTime = timeToStringBWZT(\nPLTransTime)
    If GGT(WQP\txtTransTime) <> sTransTime
      SGT(WQP\txtTransTime, sTransTime)
    EndIf
    ; End added 24Feb2024 11.10.2aw
    WQP_doPLTotals()
    WQP_setApplyToAllButton()
    
    postChangeAudLN(u, \nPLTransTime)
    
  EndWith

  rWQP\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQP_updateAudsFromWQPFile(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nPrevAudIndex, nAudPtr
  Protected nAudNo
  Protected *oldElement
  
  debugMsg(sProcName, #SCS_START)
  ; debugCuePtrs()
  
  nPrevAudIndex = -1
  nAudNo = 0
  With aSub(pSubPtr)
    *oldElement = @WQPFile()
    ForEach WQPFile()
      nAudPtr = WQPFile()\nAudPtr
      ; debugMsg(sProcName, "ListIndex(WQPFile())=" + ListIndex(WQPFile()) + ", nAudPtr=" + getAudLabel(nAudPtr))
      If nAudPtr > 0
        nAudNo + 1
        aAud(nAudPtr)\nAudNo = nAudNo
        ; debugMsg(sProcName, "\nAudNo=" + aAud(nAudPtr)\nAudNo)
        nAudPtr = WQPFile()\nAudPtr
        CompilerIf #c_include_mygrid_for_playlists
          ; MyGrid_SetText(WQP\grdPlaylist, 
        CompilerElse
          SGT(WQPFile()\txtTrkNo, Str(nAudNo))
        CompilerEndIf
        If nPrevAudIndex = -1
          aSub(pSubPtr)\nFirstAudIndex = nAudPtr
        Else
          aAud(nPrevAudIndex)\nNextAudIndex = nAudPtr
        EndIf
        aAud(nAudPtr)\nPrevAudIndex = nPrevAudIndex
        nPrevAudIndex = nAudPtr
      EndIf
    Next WQPFile()
    ChangeCurrentElement(WQPFile(), *oldElement)
    
    If nPrevAudIndex = -1
      aSub(pSubPtr)\nFirstAudIndex = -1
    Else
      aAud(nPrevAudIndex)\nNextAudIndex = -1
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, "(b)")
  ; debugCuePtrs()
  
  ; debugMsg(sProcName, "calling setDerivedSubFields(" + getSubLabel(pSubPtr) + ")")
  setDerivedSubFields(pSubPtr)
  debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(pSubPtr) + ", #True, #True)")
  generatePlayOrder(pSubPtr, #True, #True)
  ; debugMsg(sProcName, "calling WQP_buildPlayOrderLBL()")
  WQP_buildPlayOrderLBL()
  debugMsg(sProcName, "calling WQP_doPLTotals()")
  WQP_doPLTotals()
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WQP_btnBrowse_Click(nRow, bAddingRow=#False)
  PROCNAMECS(nEditSubPtr)
  Protected bEmptyRowFound
  Protected nFileCount, n
  Protected sFileName.s
  Protected u
  Protected Dim u4(0)
  Protected Dim sNewFileName.s(0)
  Protected Dim nNewAudPtr(0)
  Protected Dim bAudAdded(0)
  Protected nGrdPlayList, sText.s, nSelectedElement, nListIndex, nGrdRowNo
  
  debugMsg(sProcName, #SCS_START + ", nRow=" + nRow + ", bAddingRow=" + strB(bAddingRow))
  
  CompilerIf #c_include_mygrid_for_playlists
    nGrdPlayList = WQP\grdPlaylist
    nGrdRowNo = nRow
  CompilerEndIf
  
  WQP_setCurrentRow(nRow)
  setEditAudPtr(WQPFile()\nAudPtr)
  debugMsg(sProcName, "nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  Select grEditingOptions\nAudioFileSelector
    Case #SCS_FO_SCS_AFS
      ; save nRow and bAddingRow in rWQP for later use in WQP_btnBrowse_ModReturn() after file opener return
      rWQP\nBrowseRow = nRow
      rWQP\bBrowseAddingRow = bAddingRow
      WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AudioFileMulti", #True)
      
    Case #SCS_FO_WINDOWS_FS
      nFileCount = audioFileRequester(Lang("Requesters", "AudioFileMulti"), #True)
      If nFileCount = 0
        ProcedureReturn
      ElseIf nFileCount > 50
        If checkManyFilesOK(nFileCount) = #False
          ProcedureReturn
        EndIf
      EndIf
      
      u = preChangeSubL(#True, "Playlist Files", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS | #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
      
      ReDim u4(nFileCount)
      ReDim sNewFileName(nFileCount)
      ReDim nNewAudPtr(nFileCount)
      ReDim bAudAdded(nFileCount)
      
      For n = 1 To nFileCount
        
        debugMsg(sProcName, "gsSelectedDirectory=" + gsSelectedDirectory + ", gsSelectedFile(" + Str(n-1) + ")=" + gsSelectedFile(n-1))
        sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
        
        If (n = 1) And (nEditAudPtr >= 0) And (bAddingRow = #False)
          u4(n) = preChangeAudS(aAud(nEditAudPtr)\sFileName, "File Name", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_OPEN_FILE)
          bAudAdded(n) = #False
        Else
          u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
          If nEditAudPtr < 0
            ; addAudToSub() failed
            ProcedureReturn
          EndIf
          bAudAdded(n) = #True
          If WQPFile()\nFileNameLen > 0
            ; not positioned on a blank row, so insert a new row
            insertWQPFile()
          EndIf
        EndIf
        
        debugMsg(sProcName, "n=" + n + ", nEditAudPtr=" + nEditAudPtr + ", sFileName=" + GetFilePart(sFileName) + ", ListIndex(WQPFile())=" + Str(ListIndex(WQPFile())))
        With aAud(nEditAudPtr)
          
          nNewAudPtr(n) = nEditAudPtr
          
          \sFileName = sFileName
          \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
          If \nAudNo = -1
            aSub(nEditSubPtr)\nAudCount + 1
            debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nAudCount=" + Str(aSub(nEditSubPtr)\nAudCount))
            \nAudNo = aSub(nEditSubPtr)\nAudCount
          EndIf
          setLabels(nEditCuePtr)
          setFirstAndLastDev(nEditAudPtr)
          openMediaFile(nEditAudPtr, #True, #SCS_VID_PIC_TARGET_NONE, #False, #False, #True)
          debugMsg(sProcName, \sAudLabel + ", \nAudState=" + decodeCueState(\nAudState))
          WQP_populatePLTitle(nEditAudPtr)
          
          If \nStartAt >= \nFileDuration
            \nStartAt = grAudDef\nStartAt
          EndIf
          If \nEndAt >= \nFileDuration
            \nEndAt = grAudDef\nEndAt
          EndIf
          setDerivedAudFields(nEditAudPtr)
          \bAudNormSet = #False
          
          CompilerIf #c_include_mygrid_for_playlists
            nListIndex = nGrdRowNo - 1
            ; First of all, update the list WQPFile() with this file's details
            debugMsg(sProcName, "nListIndex=" + nListIndex + ", ListSize(WQPFile())=" + ListSize(WQPFile()))
            nSelectedElement = SelectElement(WQPFile(), nListIndex)
            If nSelectedElement <> 0
              WQPFile()\nAudPtr = nEditAudPtr
              WQPFile()\nFileNameLen = Len(\sStoredFileName)
            EndIf
            ; Col 1: No.
            MyGrid_SetText(nGrdPlayList, nGrdRowNo, 1, Str(\nAudNo))
            MyGrid_AssignStyle(nGrdPlayList, nGrdRowNo, 1, rWQP\nStyleCellDisplayCenter)
            ; Col 2: Audio File
            If grEditorPrefs\bShowFileFoldersInEditor
              sText = \sStoredFileName
            Else
              sText = GetFilePart(\sStoredFileName)
            EndIf
debugMsg0(sProcName, "calling MyGrid_SetText(" + getGadgetName(nGrdPlayList) + ", " + nGrdRowNo + ", 2, " + #DQUOTE$ + sText + #DQUOTE$ + ")")
            MyGrid_SetText(nGrdPlayList, nGrdRowNo, 2, sText)
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 2, rWQP\nStyleCellDisplayLeft)
            ; scsToolTip(WQPFile()\txtFileNameP, \sFileName)
            ; Col 3: ... (browse button)
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 3, "...")
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 3, rWQP\nStyleCellButton)
            ; Col 4: File Length
            WQP_populateLength(nEditAudPtr)
            ; Start At
            MyGrid_SetText(nGrdPlayList, nGrdRowNo, 5, timeToStringBWZT(\nStartAt, \nFileDuration))
            MyGrid_AssignStyle(nGrdPlayList, nGrdRowNo, 5, rWQP\nStyleCellEditLeft)
            ; End At
            MyGrid_SetText(nGrdPlayList, nGrdRowNo, 6, timeToStringBWZT(\nEndAt, \nFileDuration))
            MyGrid_AssignStyle(nGrdPlayList, nGrdRowNo, 6, rWQP\nStyleCellEditLeft)
            ; Play Length
            MyGrid_SetText(nGrdPlayList, nGrdRowNo, 7, timeToStringBWZT(\nCueDuration, \nFileDuration))
            MyGrid_AssignStyle(nGrdPlayList, nGrdRowNo, 7, rWQP\nStyleCellDisplayLeft)
            ; Relative level
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 8, StrF(\fPLRelLevel,0)+"%")
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 8, rWQP\nStyleCellDisplayLeft)
          CompilerElse
            SGT(WQPFile()\txtTrkNo, Str(\nAudNo))
            If grEditorPrefs\bShowFileFoldersInEditor
              SGT(WQPFile()\txtFileNameP, \sStoredFileName)
            Else
              SGT(WQPFile()\txtFileNameP, GetFilePart(\sStoredFileName))
            EndIf
            scsToolTip(WQPFile()\txtFileNameP, \sFileName)
            WQP_populateLength(nEditAudPtr)
            SGT(WQPFile()\txtStartAt, timeToStringBWZT(\nStartAt, \nFileDuration))
            SGT(WQPFile()\txtEndAt, timeToStringBWZT(\nEndAt, \nFileDuration))
            SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, \nFileDuration))
            SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%") ; Added 11Mar2024 11.10.2be
          CompilerEndIf
          WQPFile()\nAudPtr = nEditAudPtr
          WQPFile()\nFileNameLen = Len(\sStoredFileName)
          
          sNewFileName(n) = \sFileName
          
        EndWith
        
        If n < nFileCount
          If ListIndex(WQPFile()) < (ListSize(WQPFile())-1)
            NextElement(WQPFile())
          Else
            createWQPFile()
          EndIf
        EndIf
        CompilerIf #c_include_mygrid_for_playlists
          nGrdRowNo + 1
        CompilerEndIf
        
      Next n
      
      CompilerIf #c_include_mygrid_for_playlists
        rWQP\nExtraRowNo = nGrdRowNo
        WQP_populateExtraRow()
;         MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 3, "...")
;         MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 3, rWQP\nStyleCellButton)
;         rWQP\nExtraRowNo = nGrdRowNo
;         debugMsg(sProcName, "rWQP\nExtraRowNo=" + rWQP\nExtraRowNo)
;         debugMsg(sProcName, "calling MyGrid_ReDefineRows(" + getGadgetName(nGrdPlaylist) + ", " + nGrdRowNo + ")")
;         MyGrid_ReDefineRows(nGrdPlaylist, nGrdRowNo)
      CompilerEndIf
      
      ; debugMsg(sProcName, "calling WQP_listWQPFile()")
      ; WQP_listWQPFile()
      
      debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
      WQP_updateAudsFromWQPFile(nEditSubPtr)
      
      setLabels(nEditCuePtr)
      
      setLinksForCue(nEditCuePtr)
      setLinksForAudsWithinSubsForCue(nEditCuePtr)
      buildAudSetArray()
      
      generatePlayOrder(nEditSubPtr)
      setCueState(nEditCuePtr)
      
      For n = 1 To nFileCount
        If bAudAdded(n)
          postChangeAudL(u4(n), #False, nNewAudPtr(n))
        Else
          postChangeAudS(u4(n), sNewFileName(n), nNewAudPtr(n))
        EndIf
      Next n
      
      WQP_resetSubDescrIfReqd()
      
      postChangeSubL(u, #False)
      
      ; create an empty row if required
      bEmptyRowFound = #False
      ForEach WQPFile()
        If WQPFile()\nFileNameLen = 0
          bEmptyRowFound = #True
          Break
        EndIf
      Next WQPFile()
      If bEmptyRowFound = #False
        createWQPFile()
      EndIf
      
      nListIndex = nRow - 1
      debugMsg(sProcName, "calling WQP_setCurrentRow(" + nListIndex + ")")
      WQP_setCurrentRow(nListIndex)
      
      CompilerIf #c_include_mygrid_for_playlists
        MyGrid_Redraw(nGrdPlaylist)
      CompilerEndIf
      setFileSave()
      
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_btnBrowse_ModReturn(nFileCount)
  PROCNAMECA(nEditAudPtr)
  Protected nRow, bAddingRow
  Protected bEmptyRowFound
  Protected n
  Protected sFileName.s
  Protected u
  Protected Dim u4(0)
  Protected Dim sNewFileName.s(0)
  Protected Dim nNewAudPtr(0)
  Protected Dim bAudAdded(0)
  
  debugMsg(sProcName, #SCS_START + ", nFileCount=" + nFileCount)
  
  ; retrieve nRow and bAddingRow from rWQP as saved by WQP_btnBrowse_Click()
  nRow = rWQP\nBrowseRow
  bAddingRow = rWQP\bBrowseAddingRow
  
  debugMsg(sProcName, "nRow=" + nRow + ", bAddingRow=" + strB(bAddingRow))
  
  If nFileCount = 0
    ProcedureReturn
  ElseIf nFileCount > 50
    If checkManyFilesOK(nFileCount) = #False
      ProcedureReturn
    EndIf
  EndIf
  
  u = preChangeSubL(#True, "Playlist Files", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS | #SCS_UNDO_FLAG_GENERATE_PLAYORDER)

  ReDim u4(nFileCount)
  ReDim sNewFileName(nFileCount)
  ReDim nNewAudPtr(nFileCount)
  ReDim bAudAdded(nFileCount)
  
  For n = 1 To nFileCount
    
    debugMsg(sProcName, "gsSelectedDirectory=" + gsSelectedDirectory + ", gsSelectedFile(" + Str(n-1) + ")=" + gsSelectedFile(n-1))
    sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
    
    If (n = 1) And (nEditAudPtr >= 0) And (bAddingRow = #False)
      u4(n) = preChangeAudS(aAud(nEditAudPtr)\sFileName, "File Name", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_OPEN_FILE)
      bAudAdded(n) = #False
    Else
      u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
      If nEditAudPtr < 0
        ; addAudToSub() failed
        ProcedureReturn
      EndIf
      bAudAdded(n) = #True
      If WQPFile()\nFileNameLen > 0
        ; not positioned on a blank row, so insert a new row
        insertWQPFile()
      EndIf
    EndIf
    
    debugMsg(sProcName, "n=" + n + ", nEditAudPtr=" + nEditAudPtr + ", sFileName=" + GetFilePart(sFileName) + ", ListIndex(WQPFile())=" + Str(ListIndex(WQPFile())))
    With aAud(nEditAudPtr)
      
      nNewAudPtr(n) = nEditAudPtr
      
      \sFileName = sFileName
      \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
      \nFileStatsPtr = grAudDef\nFileStatsPtr
      If \nAudNo = -1
        aSub(nEditSubPtr)\nAudCount + 1
        debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nAudCount=" + Str(aSub(nEditSubPtr)\nAudCount))
        \nAudNo = aSub(nEditSubPtr)\nAudCount
      EndIf
      setLabels(nEditCuePtr)
      setFirstAndLastDev(nEditAudPtr)
      openMediaFile(nEditAudPtr, #True, #SCS_VID_PIC_TARGET_NONE, #False, #False, #True)
      debugMsg(sProcName, \sAudLabel + ", \nAudState=" + decodeCueState(\nAudState))
      WQP_populatePLTitle(nEditAudPtr)
      
      If \nStartAt >= \nFileDuration
        \nStartAt = grAudDef\nStartAt
      EndIf
      If \nEndAt >= \nFileDuration
        \nEndAt = grAudDef\nEndAt
      EndIf
      setDerivedAudFields(nEditAudPtr)
      \bAudNormSet = #False
      
      CompilerIf #c_include_mygrid_for_playlists = #False
        SGT(WQPFile()\txtTrkNo, Str(\nAudNo))
        If grEditorPrefs\bShowFileFoldersInEditor
          SGT(WQPFile()\txtFileNameP, \sStoredFileName)
        Else
          SGT(WQPFile()\txtFileNameP, GetFilePart(\sStoredFileName))
        EndIf
        scsToolTip(WQPFile()\txtFileNameP, \sFileName)
      CompilerEndIf
      WQP_populateLength(nEditAudPtr)
      CompilerIf #c_include_mygrid_for_playlists = #False
        SGT(WQPFile()\txtStartAt, timeToStringBWZT(\nStartAt, \nFileDuration))
        SGT(WQPFile()\txtEndAt, timeToStringBWZT(\nEndAt, \nFileDuration))
        SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, \nFileDuration))
        SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
      CompilerEndIf
      WQPFile()\nAudPtr = nEditAudPtr
      WQPFile()\nFileNameLen = Len(\sStoredFileName)
      
      sNewFileName(n) = \sFileName
      
    EndWith
    
    If n < nFileCount
      If ListIndex(WQPFile()) < (ListSize(WQPFile())-1)
        NextElement(WQPFile())
      Else
        createWQPFile()
      EndIf
    EndIf
    
  Next n
  
  ; debugMsg(sProcName, "calling WQP_listWQPFile()")
  ; WQP_listWQPFile()
  
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)
  
  setLabels(nEditCuePtr)
  
  setLinksForCue(nEditCuePtr)
  setLinksForAudsWithinSubsForCue(nEditCuePtr)
  buildAudSetArray()

  debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nEditSubPtr) + ")")
  generatePlayOrder(nEditSubPtr)
  setCueState(nEditCuePtr)
  
  For n = 1 To nFileCount
    If bAudAdded(n)
      postChangeAudL(u4(n), #False, nNewAudPtr(n))
    Else
      postChangeAudS(u4(n), sNewFileName(n), nNewAudPtr(n))
    EndIf
  Next n
  
  WQP_resetSubDescrIfReqd()
  
  postChangeSubL(u, #False)
  
  ; create an empty row if required
  bEmptyRowFound = #False
  ForEach WQPFile()
    If WQPFile()\nFileNameLen = 0
      bEmptyRowFound = #True
      Break
    EndIf
  Next WQPFile()
  If bEmptyRowFound = #False
    createWQPFile()
  EndIf
  
  debugMsg(sProcName, "calling WQP_setCurrentRow(" + nRow + ")")
  WQP_setCurrentRow(nRow)
  
  setFileSave()
  
  If nFileCount > 0
    THR_createOrResumeAThread(#SCS_THREAD_GET_FILE_STATS)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_populateLength(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nGrdPlaylist
  Protected nRowNo, sText.s
  
  CompilerIf #c_include_mygrid_for_playlists
    If pAudPtr >= 0
      nGrdPlaylist = WQP\grdPlaylist
      nRowNo = ListIndex(WQPFile()) + 1
      With aAud(pAudPtr)
        If \nAudState = #SCS_CUE_ERROR
          ; scsSetGadgetFont(WQPFile()\txtLength, #SCS_FONT_GEN_BOLD)
          ; SetGadgetColor(WQPFile()\txtLength, #PB_Gadget_FrontColor, #SCS_Red)
          sText = grText\sTextError
          MyGrid_SetText(nGrdPlaylist, nRowNo, 4, sText)
          ; GadgetToolTip(WQPFile()\txtLength, \sErrorMsg)
        Else
          ; scsSetGadgetFont(WQPFile()\txtLength, #SCS_FONT_GEN_NORMAL)
          ; SetGadgetColor(WQPFile()\txtLength, #PB_Gadget_FrontColor, glSysColGrayText)
          sText = timeToStringBWZT(\nFileDuration)
          MyGrid_SetText(nGrdPlaylist, nRowNo, 4, sText)
          MyGrid_AssignStyle(nGrdPlaylist, nRowNo, 4, rWQP\nStyleCellDisplayLeft)
          ; GadgetToolTip(WQPFile()\txtLength, "")
        EndIf
      EndWith
    EndIf
  CompilerElse
    If pAudPtr >= 0
      With aAud(pAudPtr)
        If \nAudState = #SCS_CUE_ERROR
          scsSetGadgetFont(WQPFile()\txtLength, #SCS_FONT_GEN_BOLD)
          SetGadgetColor(WQPFile()\txtLength, #PB_Gadget_FrontColor, #SCS_Red)
          ; need to reset the back color due to a PB bug with setting the front color of ReadOnly string gadgets - see my Windows bug report raised 3 Feb 2012
          SetGadgetColor(WQPFile()\txtLength, #PB_Gadget_BackColor, glSysColBtnFace)
          SGT(WQPFile()\txtLength, grText\sTextError)
          scsToolTip(WQPFile()\txtLength, \sErrorMsg)
        Else
          scsSetGadgetFont(WQPFile()\txtLength, #SCS_FONT_GEN_NORMAL)
          SetGadgetColor(WQPFile()\txtLength, #PB_Gadget_FrontColor, glSysColGrayText)
          ; need to reset the back color due to a PB bug with setting the front color of ReadOnly string gadgets - see my Windows bug report raised 3 Feb 2012
          SetGadgetColor(WQPFile()\txtLength, #PB_Gadget_BackColor, glSysColBtnFace)
          SGT(WQPFile()\txtLength, timeToStringBWZT(\nFileDuration))
          scsToolTip(WQPFile()\txtLength, "")
        EndIf
      EndWith
    EndIf
  CompilerEndIf
  
EndProcedure

Procedure WQP_populatePLTitle(pAudPtr)
  PROCNAMECA(pAudPtr)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nAudState = #SCS_CUE_ERROR
        SGT(WQP\txtPLTitle, \sErrorMsg)
        scsSetGadgetFont(WQP\txtPLTitle, #SCS_FONT_GEN_BOLD)
        SetGadgetColor(WQP\txtPLTitle, #PB_Gadget_FrontColor, #SCS_Red)
        scsToolTip(WQP\txtPLTitle, \sErrorMsg)
      Else
        SGT(WQP\txtPLTitle, \sFileTitle)
        scsToolTip(WQP\txtPLTitle, \sFileTitle)
        scsSetGadgetFont(WQP\txtPLTitle, #SCS_FONT_GEN_NORMAL)
        SetGadgetColor(WQP\txtPLTitle, #PB_Gadget_FrontColor, glSysColGrayText)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQP_highlightPlayListRow()
  PROCNAMECS(nEditSubPtr)
  Protected d
  Protected nTrkNoHandle, nOldTrkNoHandle
  Protected nTrkRowNo, nOldTrkRowNo
  Protected nListIndex, nGrdRow
  
  ; ASSERT_THREAD(#SCS_THREAD_MAIN)
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_HIGHLIGHT_PLAYLIST_ROW)
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START + ", grCED\sDisplayedSubType=" + grCED\sDisplayedSubType)
  If grCED\sDisplayedSubType <> "P"
    ProcedureReturn
  EndIf

  rWQP\nCurrPlayListIndex = ListIndex(WQPFile())
  ; debugMsg(sProcName, "rWQP\nCurrPlayListIndex=" + rWQP\nCurrPlayListIndex)
  If rWQP\nCurrPlayListIndex = -1
    ; no current row
    editSetDisplayButtonsP()
    ProcedureReturn
  EndIf
  
  setEditAudPtr(WQPFile()\nAudPtr)
  
  debugMsg(sProcName, "rWQP\nCurrPlayListIndex=" + rWQP\nCurrPlayListIndex + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  CompilerIf #c_include_mygrid_for_playlists
    nGrdRow = rWQP\nCurrPlayListIndex + 1
    nOldTrkRowNo = rWQP\nCurrentTrkRowNo
    nTrkRowNo = Val(MyGrid_GetText(WQP\grdPlaylist, nGrdRow, 1))
    ; debugMsg(sProcName, "nOldTrkRowNo=" + nOldTrkRowNo + ", nTrkRowNo=" + nTrkRowNo + ", nGrdRow=" + nGrdRow + ", rWQP\nExtraRowNo=" + rWQP\nExtraRowNo)
    If nTrkRowNo <> nOldTrkRowNo
      If IsGadget(WQP\grdPlaylist)
        If nOldTrkRowNo > 0
          If nOldTrkRowNo = rWQP\nExtraRowNo
            ; debugMsg(sProcName, "calling MyGrid_AssignStyle(WQP\grdPlaylist, " + nTrkRowNo + ", 1, rWQP\nStyleCellUnavailable)")
            ; MyGrid_AssignStyle(WQP\grdPlaylist, nTrkRowNo, 1, rWQP\nStyleCellUnavailable)
            MyGrid_AssignStyle(WQP\grdPlaylist, nTrkRowNo, 1, rWQP\nStyleCellDisplayLeft)
          Else
            ; debugMsg(sProcName, "calling MyGrid_AssignStyle(WQP\grdPlaylist, " + nOldTrkRowNo + ", 1, rWQP\nStyleCellDisplayCenter)")
            MyGrid_AssignStyle(WQP\grdPlaylist, nOldTrkRowNo, 1, rWQP\nStyleCellDisplayCenter)
          EndIf
        EndIf
        If nTrkRowNo > 0
          ; debugMsg(sProcName, "calling MyGrid_AssignStyle(WQP\grdPlaylist, " + nTrkRowNo + ", 1, rWQP\nStyleCellHighlightCenter)")
          MyGrid_AssignStyle(WQP\grdPlaylist, nTrkRowNo, 1, rWQP\nStyleCellHighlightCenter)
          MyGrid_ShowCell(WQP\GrdPlaylist, nTrkRowNo, 1, #True) ; show 'focus' rectangle
        EndIf
      EndIf
      MyGrid_Redraw(WQP\grdPlaylist)
      rWQP\nCurrentTrkRowNo = nTrkRowNo
    EndIf
  CompilerElse
    nOldTrkNoHandle = rWQP\nCurrentTrkNoHandle
    nTrkNoHandle = WQPFile()\txtTrkNo
    ; debugMsg(sProcName, "nOldTrkNoHandle=" + nOldTrkNoHandle + ", nTrkNoHandle=" + nTrkNoHandle)
    If nTrkNoHandle <> nOldTrkNoHandle
      If IsGadget(nOldTrkNoHandle)
        scsSetGadgetFont(nOldTrkNoHandle, #SCS_FONT_GEN_NORMAL)
        SetGadgetColor(nOldTrkNoHandle, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      EndIf
      scsSetGadgetFont(nTrkNoHandle, #SCS_FONT_GEN_BOLD)
      SetGadgetColor(nTrkNoHandle, #PB_Gadget_BackColor, #SCS_Light_Yellow)
      rWQP\nCurrentTrkNoHandle = nTrkNoHandle
    EndIf
  CompilerEndIf
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", \nCuePos=" + \nCuePos + ", \sErrorMsg=" + \sErrorMsg)
      If \nAudState = #SCS_CUE_NOT_LOADED
        debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ", #True)")
        openMediaFile(nEditAudPtr, #True)
      EndIf
      WQP_populatePLTitle(nEditAudPtr)
      debugMsg(sProcName, "txtPLTitle=" + GGT(WQP\txtPLTitle))
      
      nListIndex = indexForComboBoxData(WQP\cboTransType, \nPLTransType, #SCS_TRANS_NONE)
      SGS(WQP\cboTransType, nListIndex)
      setEnabled(WQP\cboTransType, #True)
      SGT(WQP\txtTransTime, timeToStringBWZT(\nPLTransTime))
      setEnabled(WQP\txtTransTime, #True)
      
      SLD_setValue(WQP\sldRelLevel, \fPLRelLevel)
      SLD_setEnabled(WQP\sldRelLevel, #True)
      ; debugMsg(sProcName, "SLD_setEnabled(WQP\sldRelLevel, #True)")
      SLD_setEnabled(WQP\sldPLProgress[0], #True) ; changed from #False to #True 16Oct2019 11.8.2bb following email from Eric Snodgrass
      SLD_setMax(WQP\sldPLProgress[0], (\nCueDuration-1))
      SLD_setValue(WQP\sldPLProgress[0], \nCuePos)
      SGT(WQP\lblPLTestFile, grText\sTextFile +" " + \nAudNo + ":")
      
      debugMsg(sProcName, "calling calcPLPosition(" + nEditSubPtr + ")")
      calcPLPosition(nEditSubPtr)
      
      If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
        If SLD_getMax(WQP\sldPLProgress[1]) <> (aSub(\nSubIndex)\nPLTestTime-1)
          SLD_setMax(WQP\sldPLProgress[1], (aSub(\nSubIndex)\nPLTestTime-1))
        EndIf
        SLD_setValue(WQP\sldPLProgress[1], \nCuePos)
        ; debugMsg(sProcName, "SLD_setValue(WQP\sldPLProgress[1], " + Str(\nCuePos) + ")")
        SGT(WQP\lblPLInfo, gaCueState(aSub(\nSubIndex)\nSubState))
      Else
        If SLD_getMax(WQP\sldPLProgress[1]) <> (\nCueDuration-1)
          SLD_setMax(WQP\sldPLProgress[1], (\nCueDuration-1))
        EndIf
        SLD_setValue(WQP\sldPLProgress[1], aSub(\nSubIndex)\nPLCuePosition)
        ; debugMsg(sProcName, "SLD_setValue(WQP\sldPLProgress[1], " + Str(aSub(\nSubIndex)\nPLCuePosition) + ")")
        SGT(WQP\lblPLInfo, gaCueState(\nAudState))
      EndIf
    EndWith
    
  Else ; current row is blank entry at end
    SGT(WQP\txtPLTitle, "")
    scsToolTip(WQP\txtPLTitle, "")
    SGS(WQP\cboTransType, 0)
    setEnabled(WQP\cboTransType, #False)
    SGT(WQP\txtTransTime, "")
    setEnabled(WQP\txtTransTime, #False)
    SLD_setValue(WQP\sldRelLevel, grAudDef\fPLRelLevel)
    SLD_setEnabled(WQP\sldRelLevel, #False)
    SLD_setEnabled(WQP\sldPLProgress[0], #False)
    SLD_setMax(WQP\sldPLProgress[1], (aSub(nEditSubPtr)\nPLTestTime-1))
    SLD_setValue(WQP\sldPLProgress[1], 0)
    SLD_setMax(WQP\sldPLProgress[0], 0)
    SLD_setValue(WQP\sldPLProgress[0], 0)
    SGT(WQP\lblPLTestFile, "File " + Str(rWQP\nCurrPlayListIndex+1) + ":")
    If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
      SGT(WQP\lblPLInfo, gaCueState(aSub(nEditSubPtr)\nSubState))
    Else
      SGT(WQP\lblPLInfo, "")
    EndIf
  EndIf
  WQP_buildPlayOrderLBL()
  
  WQP_setApplyToAllButton()
  WQP_setTBSButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_validatePLItem(nGadgetNo, nRow, sColKey.s)
  PROCNAMECS(nEditSubPtr)
  Protected nAudPtr, nGrdRowNo
  Protected sNewText.s
  Protected u
  Protected bRedrawGrdPlaylist

  nAudPtr = WQPFile()\nAudPtr
  nGrdRowNo = nRow + 1
  CompilerIf #c_include_mygrid_for_playlists
    Select sColKey
      Case "ST"
        sNewText = MyGrid_GetText(WQP\grdPlaylist, nGrdRowNo, 5)
      Case "EN"
        sNewText = MyGrid_GetText(WQP\grdPlaylist, nGrdRowNo, 6)
    EndSelect
  CompilerElse
    sNewText = GGT(nGadgetNo)
  CompilerEndIf
  debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", sColKey=" + sColKey + ", sNewText=" + sNewText)
  
  If nAudPtr = -1
    ProcedureReturn #True
  EndIf
  
  With aAud(nAudPtr)
    
    Select sColKey
      Case "FN"   ; file name
        ; u = preChangeAudS(aAud(nAudPtr)\sFileName, "File Name", nAudPtr, #SCS_UNDO_ACTION_CHANGE, nRow, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS | #SCS_UNDO_FLAG_OPEN_FILE)
        ; debugMsg(sProcName, "calling addOrReplacePLFile(" + Str(nRow) + ", " + sNewText + ")")
        ; addOrReplacePLFile(nRow, sNewText)  ; nb updates \sFileName
        ; postChangeAudS(u, aAud(nAudPtr)\sFileName)
        
      Case "ST"   ; start at
        u = preChangeAudL(aAud(nAudPtr)\nStartAt, "Start At", nAudPtr, #SCS_UNDO_ACTION_CHANGE, nRow, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS | #SCS_UNDO_FLAG_OPEN_FILE)
        If validateTimeFieldT(sNewText, "Start At", #False, #False, \nFileDuration) = #False
          debugMsg(sProcName, "validateTimeField failed")
          ProcedureReturn #False
        ElseIf sNewText <> gsTmpString
          debugMsg(sProcName, "validateTimeField ok ")
          sNewText = gsTmpString
        EndIf
        \nStartAt = stringToTime(sNewText)
        CompilerIf #c_include_mygrid_for_playlists
          debugMsg(sProcName, "calling MyGrid_SetText(WQP\grdPlaylist, " + nGrdRowNo + ", 5, " + timeToStringBWZT(\nStartAt, \nFileDuration) + ")")
          MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 5, timeToStringBWZT(\nStartAt, \nFileDuration))
          bRedrawGrdPlaylist = #True
        CompilerElse
          SGT(nGadgetNo, timeToStringBWZT(\nStartAt, \nFileDuration))
        CompilerEndIf
        postChangeAudLN(u, aAud(nAudPtr)\nStartAt, nAudPtr)
        
      Case "EN"   ; end at
        u = preChangeAudL(aAud(nAudPtr)\nEndAt, "End At", nAudPtr, #SCS_UNDO_ACTION_CHANGE, nRow, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS | #SCS_UNDO_FLAG_OPEN_FILE)
        If validateTimeFieldT(sNewText, "End At", #False, #False, \nFileDuration) = #False
          ProcedureReturn #False
        ElseIf sNewText <> gsTmpString
          sNewText = gsTmpString
        EndIf
        \nEndAt = stringToTime(sNewText)
        CompilerIf #c_include_mygrid_for_playlists
          MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 6, timeToStringBWZT(\nEndAt, \nFileDuration))
          bRedrawGrdPlaylist = #True
        CompilerElse
          SGT(nGadgetNo, timeToStringBWZT(\nEndAt, \nFileDuration))
        CompilerEndIf
        postChangeAudLN(u, aAud(nAudPtr)\nEndAt, nAudPtr)
        
    EndSelect
    
    setDerivedAudFields(nAudPtr)
    CompilerIf #c_include_mygrid_for_playlists
      MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 7, timeToStringBWZT(\nCueDuration, \nFileDuration))
      bRedrawGrdPlaylist = #True
    CompilerElse
      SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, \nFileDuration))
      SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
    CompilerEndIf
    
    SLD_setValue(WQP\sldPLProgress[0], 0)
    SLD_setMax(WQP\sldPLProgress[0], (\nCueDuration-1))
    debugMsg(sProcName, "calling WQP_doPLTotals()")
    WQP_doPLTotals()
    
  EndWith
  
  CompilerIf #c_include_mygrid_for_playlists
    If bRedrawGrdPlaylist
      MyGrid_Redraw(WQP\grdPlaylist)
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)
  setFileSave()
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQP_setApplyToAllButton(bForce=#False)
  PROCNAMEC()
  Protected k, bEnabled
  Protected nPLTransType, nPLTransTime
  
  If bForce And 1=2
    setEnabled(WQP\btnApplyToAll, #True)
  Else
    If (nEditSubPtr >= 0) And (nEditAudPtr >= 0)
      k = aSub(nEditSubPtr)\nFirstAudIndex
      If (k >= 0) And (Len(aAud(k)\sStoredFileName) > 0)
        nPLTransType = aAud(k)\nPLTransType
        nPLTransTime = aAud(k)\nPLTransTime
        k = aAud(k)\nNextAudIndex
        While k >= 0
          With aAud(k)
            If Len(\sStoredFileName) > 0
              If (\nPLTransType <> nPLTransType) Or (\nPLTransTime <> nPLTransTime)
                bEnabled = #True
                Break
              EndIf
            EndIf
            k = \nNextAudIndex
          EndWith
        Wend
      EndIf
    EndIf
    setEnabled(WQP\btnApplyToAll, bEnabled)
  EndIf
  
EndProcedure

Procedure WQP_formValidation()
  PROCNAMECS(nEditSubPtr)
  Protected bValidationOK = #True
  
  ; debugMsg(sProcName, "gnValidateGadgetNo=G" + gnValidateGadgetNo)
  If gnValidateGadgetNo <> 0
    bValidationOK = WQP_valGadget(gnValidateGadgetNo)
  EndIf
  
  If bValidationOK = #False
    debugMsg(sProcName, "returning " + strB(bValidationOK))
  EndIf
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WQP_clearDropInfo()
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START)
  rWQP\m_lDropRow = 0
  rWQP\m_lDropCol = 0
EndProcedure

Procedure WQP_populateCboPLLogicalDevs()
  PROCNAMECS(nEditSubPtr)
  Protected d, n

  debugMsg(sProcName, #SCS_START)
  
  ; populate logical device cbo for sub type P
  For d = 0 To grLicInfo\nMaxAudDevPerSub
    ; debugMsg(sProcName, "d=" + Str(d))
    ClearGadgetItems(WQP\cboPLLogicalDev[d])
    AddGadgetItem(WQP\cboPLLogicalDev[d], -1, #SCS_BLANK_CBO_ENTRY)
    For n = 0 To grProd\nMaxAudioLogicalDev
      If Len(Trim(grProd\aAudioLogicalDevs(n)\sLogicalDev)) > 0
        AddGadgetItem(WQP\cboPLLogicalDev[d], -1, grProd\aAudioLogicalDevs(n)\sLogicalDev)
      EndIf
    Next n
  Next d

EndProcedure

Procedure WQP_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  ; debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  ; debugMsg(sProcName, "nGadgetNo=G" + nGadgetNo + ", nGadgetPropsIndex=" + Str(nGadgetPropsIndex) + ", nEventGadgetNoForEvHdlr=G" + Str(nEventGadgetNoForEvHdlr))
  
  With WQP
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQP)
        
        ; detail gadgets
      Case #SCS_G4EH_PL_TXTENDAT  ; txtEndAt
        ETVAL2(WQP_validatePLItem(nGadgetNo, WQP_calcGadgetRow(), "EN"))
        
      Case #SCS_G4EH_PL_TXTFILENAME   ; txtFileName
        ETVAL2(WQP_validatePLItem(nGadgetNo, WQP_calcGadgetRow(), "FN"))
        
      Case \txtPLFadeInTime   ; txtPLFadeInTime
        ETVAL2(WQP_txtPLFadeInTime_Validate())
        
      Case \txtPLFadeOutTime   ; txtPLFadeOutTime
        ETVAL2(WQP_txtPLFadeOutTime_Validate())
        
      ; Case \txtPLTitle   ; txtPLTitle
        ; ETVAL2(WQP_txtPLTitle_Validate())
        
      Case #SCS_G4EH_PL_TXTSTARTAT    ; txtStartAt
        ETVAL2(WQP_validatePLItem(nGadgetNo, WQP_calcGadgetRow(), "ST"))
        
      Case \txtSubDBLevel[0]   ; txtSubDBLevel
        ETVAL2(WQP_txtSubDBLevel_Validate(nArrayIndex))
        
      Case \txtSubPan[0]   ; txtSubPan
        ETVAL2(WQP_txtSubPan_Validate(nArrayIndex))
        
      Case \txtTransTime   ; txtTransTime
        ETVAL2(WQP_txtTransTime_Validate())
        
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

Procedure WQP_fcSldRelLevel()
  PROCNAMECS(nEditSubPtr)
  Protected d, k
  Protected u
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  If ListIndex(WQPFile()) >= 0
    k = WQPFile()\nAudPtr
    If k > 0
      debugMsg(sProcName, "gnSliderEvent=" + SLD_decodeEvent(gnSliderEvent) + ", k=" + getAudLabel(k))
      With aAud(k)
        u = preChangeAudF(\fPLRelLevel, GetGadgetText(WQP\lblRelLevel), k)
        \fPLRelLevel = SLD_getValue(WQP\sldRelLevel)
        debugMsg(sProcName, "SLD_getValue() returned " + StrF(\fPLRelLevel,4))
        CompilerIf #c_include_mygrid_for_playlists
          ; ????????????????????
        CompilerElse
          SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
        CompilerEndIf
        For d = 0 To grLicInfo\nMaxAudDevPerSub
          If \sLogicalDev[d]
            \fAudPlayBVLevel[d] = aSub(\nSubIndex)\fSubMastBVLevel[d] * \fPLRelLevel / 100.0
            \fBVLevel[d] = \fAudPlayBVLevel[d]
            \fCueVolNow[d] = \fBVLevel[d]
            \fCueTotalVolNow[d] = \fCueVolNow[d]
            If \nFileState = #SCS_FILESTATE_OPEN
              If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
                If gbUseBASS
                  setLevelsAny(k, d, \fBVLevel[d], #SCS_NOPANCHANGE_SINGLE)
                Else ; SM-S
                  samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, k, \fBVLevel[d], d)
                EndIf
                \fCueVolNow[d] = \fBVLevel[d]
                \fCueTotalVolNow[d] = \fCueVolNow[d]
              EndIf
            EndIf
          EndIf
        Next d
        postChangeAudFN(u, \fPLRelLevel, k)
      EndWith
    EndIf ; EndIf k > 0
  EndIf ; EndIf ListIndex(WQPFile()) >= 0
  
EndProcedure

Procedure WQP_fcTxtDBLevelP(Index)
  PROCNAMECS(nEditSubPtr)
  Protected k, d
  Protected u, u2
  
  u = preChangeSubS(aSub(nEditSubPtr)\sPLMastDBLevel[Index], GGT(WQP\lblMastDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
  
  If gbInDisplaySub = #False
    With aSub(nEditSubPtr)
      \sPLMastDBLevel[Index] = GGT(WQP\txtSubDBLevel[Index])
      \fSubMastBVLevel[Index] = convertDBStringToBVLevel(\sPLMastDBLevel[Index])
      SLD_setLevel(WQP\sldSubLevel[Index], \fSubMastBVLevel[Index], \fSubTrimFactor[Index])
      \fSubBVLevelNow[Index] = \fSubMastBVLevel[Index]
    EndWith
    
    k = aSub(nEditSubPtr)\nFirstAudIndex
    While k >= 0
      With aAud(k)
        If \sLogicalDev[Index]
          u2 = preChangeAudF(\fBVLevel[Index], "Level", k, #SCS_UNDO_ACTION_CHANGE, Index)
          \fAudPlayBVLevel[Index] = aSub(\nSubIndex)\fSubMastBVLevel[Index] * \fPLRelLevel / 100.0
          \fBVLevel[Index] = \fAudPlayBVLevel[Index]
          \fCueVolNow[Index] = \fBVLevel[Index]
          \fCueTotalVolNow[Index] = \fCueVolNow[Index]
          If \nFileState = #SCS_FILESTATE_OPEN
            If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
              If gbUseBASS
                setLevelsAny(k, Index, \fBVLevel[Index], #SCS_NOPANCHANGE_SINGLE)
              Else
                samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, k, \fBVLevel[Index], Index)
              EndIf
              \fCueVolNow[Index] = \fBVLevel[Index]
              \fCueTotalVolNow[Index] = \fCueVolNow[Index]
            EndIf
          EndIf
          postChangeAudFN(u2, \fBVLevel[Index], k, Index)
        EndIf
        k = \nNextAudIndex
      EndWith
    Wend
    
  EndIf
  
  postChangeSubSN(u, aSub(nEditSubPtr)\sPLMastDBLevel[Index], -5, Index)
  
EndProcedure

Procedure WQP_fcSldLevelP(Index)
  PROCNAMECS(nEditSubPtr)
  Protected k, d
  Protected u, u2
  
  u = preChangeSubL(aSub(nEditSubPtr)\fSubMastBVLevel[Index], GetGadgetText(WQP\lblMastDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
  
  If gbInDisplaySub = #False
    With aSub(nEditSubPtr)
      \fSubMastBVLevel[Index] = SLD_getLevel(WQP\sldSubLevel[Index])
      \fSubBVLevelNow[Index] = aSub(nEditSubPtr)\fSubMastBVLevel[Index]
      \sPLMastDBLevel[Index] = convertBVLevelToDBString(\fSubMastBVLevel[Index])
    EndWith
    
    k = aSub(nEditSubPtr)\nFirstAudIndex
    While k >= 0
      With aAud(k)
        If Len(\sLogicalDev[Index]) > 0
          u2 = preChangeAudF(\fBVLevel[Index], "Level", k, #SCS_UNDO_ACTION_CHANGE, Index)
          \fAudPlayBVLevel[Index] = aSub(\nSubIndex)\fSubMastBVLevel[Index] * \fPLRelLevel / 100.0
          \fBVLevel[Index] = \fAudPlayBVLevel[Index]
          If \nFileState = #SCS_FILESTATE_OPEN
            If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
              If gbUseBASS
                setLevelsAny(k, Index, \fBVLevel[Index], #SCS_NOPANCHANGE_SINGLE)
              Else
                samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, k, \fBVLevel[Index], Index)
              EndIf
              \fCueVolNow[Index] = \fBVLevel[Index]
              \fCueTotalVolNow[Index] = \fCueVolNow[Index]
            EndIf
          EndIf
          postChangeAudFN(u2, \fBVLevel[Index], k, Index)
        EndIf
        k = \nNextAudIndex
      EndWith
    Wend
    
  EndIf
  
  If GetGadgetText(WQP\txtSubDBLevel[Index]) <> aSub(nEditSubPtr)\sPLMastDBLevel[Index]
    SetGadgetText(WQP\txtSubDBLevel[Index], aSub(nEditSubPtr)\sPLMastDBLevel[Index])
  EndIf
  
  postChangeSubLN(u, aSub(nEditSubPtr)\fSubMastBVLevel[Index], -5, Index)
  
EndProcedure

Procedure WQP_fcSldPanP(Index)
  PROCNAMECS(nEditSubPtr)
  Protected k
  Protected u, u2
  
  With aSub(nEditSubPtr)
    
    u = preChangeSubF(\fPLPan[Index], GetGadgetText(WQP\lblSubPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    
    If gbInDisplaySub = #False
      \fPLPan[Index] = panSliderValToSingle(SLD_getValue(WQP\sldSubPan[Index]))
      \fSubPanNow[Index] = \fPLPan[Index]
      k = \nFirstPlayIndex
      While k >= 0
        If aAud(k)\nFileState = #SCS_FILESTATE_OPEN
          u2 = preChangeAudL(#True, "Pan", k, #SCS_UNDO_ACTION_CHANGE, Index)
          If gbUseBASS
            setLevelsAny(k, Index, #SCS_NOVOLCHANGE_SINGLE, \fPLPan[Index])
          Else ; SM-S
            samAddRequest(#SCS_SAM_SET_AUD_DEV_PAN, k, \fPLPan[Index], Index)
          EndIf
          postChangeAudLN(u2, #False, k, Index)
        EndIf
        k = aAud(k)\nNextPlayIndex
      Wend
    EndIf
    
    If \fPLPan[Index] = #SCS_PANCENTRE_SINGLE
      setEnabled(WQP\btnPLCenter[Index], #False)
    Else
      setEnabled(WQP\btnPLCenter[Index], #True)
    EndIf
    SetGadgetText(WQP\txtSubPan[Index], panSingleToString(\fPLPan[Index]))
    
    postChangeSubFN(u, \fPLPan[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQP_setGrdFocusRectangle()
  PROCNAMEC()
  Protected nRow, nCol
  Protected nFocusBorderColor, nReqdFocusBorderColor
  
  CompilerIf #c_include_mygrid_for_playlists
    With WQP
      WQP_setCurrentRow(WQP_calcGadgetRow())
      If 1=2
        nRow = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_Row)
        nCol = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_Col)
        debugMsg(sProcName, "#MyGrid_Event_Focus, nRow=" + nRow + ", nCol=" + nCol)
        nReqdFocusBorderColor = -1
        If nRow > 0
          Select nCol
            Case 5, 6
              nReqdFocusBorderColor = RGB(0,0,198)
          EndSelect
        EndIf
        nFocusBorderColor = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Color_FocusBorder)
        If nReqdFocusBorderColor <> nFocusBorderColor
          debugMsg(sProcName, "nRow=" + nRow + ", nCol=" + nCol + ", calling MyGrid_SetColorAttribute(\grdPlaylist, #MyGrid_Color_FocusBorder, " + nReqdFocusBorderColor + ")")
          MyGrid_SetColorAttribute(\grdPlaylist, #MyGrid_Color_FocusBorder, nReqdFocusBorderColor)
          MyGrid_Redraw(\grdPlaylist)
        EndIf
      EndIf
    EndWith
  CompilerEndIf
EndProcedure

Procedure WQP_EventHandler()
  PROCNAMEC()
  Protected n, bFound, k
  Protected nRow, nCol, nCurrentRow
  Protected nLostFocusRow, nLostFocusCol
  Protected nCanvasKey
  CompilerIf #c_include_mygrid_for_playlists
    Protected EvGd, rr, cc, wrd.s
  CompilerEndIf
  
  ; Debug sProcName
  
  With WQP
    
    If gnEventSliderNo > 0
      
      ; debugMsg(sProcName, "gnSliderEvent=" + Str(gnSliderEvent) + ", gnEventSliderNo=" + Str(gnEventSliderNo))
      ; debugMsg(sProcName, "gnTrackingSliderNo=" + Str(gnTrackingSliderNo))
      
      If gnEventSliderNo = \sldRelLevel
        bFound = #True
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            WQP_fcSldRelLevel()
        EndSelect
        
      ElseIf gnEventSliderNo = \sldPLProgress[0]
        bFound = #True
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            WQP_sldPLProgress_Common(gnSliderEvent)
        EndSelect
        
      ElseIf gnEventSliderNo = \sldPLProgress[1]
        bFound = #True
        ; do nothing
        
      Else
        For n = 0 To grLicInfo\nMaxAudDevPerSub
          If gnEventSliderNo = \sldSubLevel[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQP_fcSldLevelP(n)
            EndSelect
            Break
            
          ElseIf gnEventSliderNo = \sldSubPan[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQP_fcSldPanP(n)
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
        
      Case #PB_Event_Menu ; see also WED_EventHandler() in fmEditor.pbi, which is where these menu events are originally caught
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
          Case #SCS_WEDF_Rewind
            If getVisible(\btnPLRewind) And getEnabled(\btnPLRewind)
              WQP_transportBtnClick(#SCS_STANDARD_BTN_REWIND)
            EndIf
            
          Case #SCS_WEDF_PlayPause
            If getVisible(\btnPLPlay) And getEnabled(\btnPLPlay)
              WQP_transportBtnClick(#SCS_STANDARD_BTN_PLAY)
            ElseIf getVisible(\btnPLPause) And getEnabled(\btnPLPause)
              WQP_transportBtnClick(#SCS_STANDARD_BTN_PAUSE)
            EndIf
            
          Case #SCS_WEDF_Stop
            If getVisible(\btnPLStop) And getEnabled(\btnPLStop)
              WQP_transportBtnClick(#SCS_STANDARD_BTN_STOP)
            EndIf
            
          Case #SCS_WEDF_SkipBack
            WQP_skipBackOrForward(-2000) ; skip back 2 seconds
            
          Case #SCS_WEDF_SkipForward
            WQP_skipBackOrForward(2000) ; skip forward 2 seconds
            
          Case #WQP_mnu_ClearAll, #WQP_mnu_ClearSel, #WQP_mnu_ResetAll, #WQP_mnu_ResetSel
            WQP_mnuClearOrReset(gnEventMenu)
            
            CompilerIf #c_include_peak
            Case #WQP_mnu_LUFSNormAll, #WQP_mnu_PeakNormAll, #WQP_mnu_TruePeakNormAll
              WQP_applyNormalization(gnEventMenu)
            CompilerElse
            Case #WQP_mnu_LUFSNorm100All, #WQP_mnu_LUFSNorm90All, #WQP_mnu_LUFSNorm80All, #WQP_mnu_TruePeakNorm100All, #WQP_mnu_TruePeakNorm90All, #WQP_mnu_TruePeakNorm80All
              WQP_applyNormalization(gnEventMenu)
            CompilerEndIf  
            
          Case #WQP_mnu_TrimSilenceAll, #WQP_mnu_Trim75All, #WQP_mnu_Trim60All, #WQP_mnu_Trim45All, #WQP_mnu_Trim30All, ; Changed 3Oct2022 11.9.6
               #WQP_mnu_TrimSilenceSel, #WQP_mnu_Trim75Sel, #WQP_mnu_Trim60Sel, #WQP_mnu_Trim45Sel, #WQP_mnu_Trim30Sel, ; Changed 3Oct2022 11.9.6
               #WQP_mnu_PeakNorm100All, #WQP_mnu_PeakNorm90All, #WQP_mnu_PeakNorm80All
            WQP_mnuTrimOrPeakNorm(gnEventMenu)
            
          Case #WQP_mnu_RemoveAllFiles
            WQP_mnuRemoveAllFiles()
            
        EndSelect
        
      Case #PB_Event_Gadget
        
        If gnEventButtonId <> 0
          
          If gnEventButtonId & #SCS_TRANSPORT_BTN
            WQP_transportBtnClick(gnEventButtonId)
            
          Else
            Select gnEventButtonId
              Case #SCS_STANDARD_BTN_MOVE_UP, #SCS_STANDARD_BTN_MOVE_DOWN, #SCS_STANDARD_BTN_PLUS, #SCS_STANDARD_BTN_MINUS
                WQP_imgButtonTBS_Click(gnEventButtonId)
            EndSelect
          EndIf
          
        Else
          
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQP)
              
              ; detail gadgets in alphabetical order
              
            Case \btnApplyToAll   ; btnApplyToAll
              BTNCLICK(WQP_btnApplyToAll_Click())
              
            Case #SCS_G4EH_PL_CMDBROWSE   ; btnBrowse
              BTNCLICK(WQP_btnBrowse_Click(WQP_calcGadgetRow()))
              
            Case \btnPLCenter   ; btnPLCenter
              BTNCLICK(WQP_btnPLCenter_Click(gnEventGadgetArrayIndex))
              
            Case \btnPLOther    ; btnPLOther
              BTNCLICK(WQP_btnPLOther_Click())
              
            Case \btnRename   ; btnRename
              BTNCLICK(WQP_renamePlaylistFile())
              
            Case \cboPLLogicalDev[0]  ; cboPLLogicalDev
              CBOCHG(WQP_cboPLLogicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboPLTestMode  ; cboPLTestMode
              CBOCHG(WQP_cboPLTestMode_Click())
              
            Case \cboTransType  ; cboTransType
              CBOCHG(WQP_cboTransType_Click())
              
            Case \cboSubTrim[0]  ; cboSubTrim
              CBOCHG(WQP_cboSubTrim_Click(gnEventGadgetArrayIndex))
              
            Case \chkPLRandom   ; chkPLRandom
              CHKOWNCHG(WQP_chkPLRandom_Click())
              
            Case \chkPLSavePos   ; chkPLSavePos
              CHKOWNCHG(WQP_chkPLSavePos_Click())
              
            Case \chkPLRepeat   ; chkPLRepeat
              CHKOWNCHG(WQP_chkPLRepeat_Click())
              
            Case \cboPLTracks[0]  ; cboPLTracks
              CHKOWNCHG(CBOCHG(WQP_cboPLTracks_Click(gnEventGadgetArrayIndex)))
              
            Case \chkShowFileFolders  ; chkShowFileFolders
              CHKOWNCHG(WQP_chkShowFileFolders())
              
            Case \cntInfoBelowFiles, \cntPlaylistSideBar, \cntSubDetailP, \cntSubHeader, \cntTest
              ; ignore events
              
            Case \grdPlaylist
              CompilerIf #c_include_mygrid_for_playlists
                ; debugMsg(sProcName, "calling MyGrid_ManageEvent(" + getGadgetName( gnEventGadgetNo) + ", " + decodeEventType(gnEventGadgetNo)) ; gnEventType)")
                MyGrid_ManageEvent(gnEventGadgetNo, gnEventType)
              CompilerEndIf
              
            Case \scaDevs, \scaFiles, \scaPlaylist
              ; do nothing
              
            Case #SCS_G4EH_PL_TXTENDAT    ; txtEndAt
              Select gnEventType
                Case #PB_EventType_Focus
                  WQP_setCurrentRow(WQP_calcGadgetRow())
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_validatePLItem(gnEventGadgetNo, WQP_calcGadgetRow(), "EN"))
              EndSelect
              
            Case #SCS_G4EH_PL_TXTFILENAME   ; txtFileName
              If gnEventType = #PB_EventType_Focus
                WQP_setCurrentRow(WQP_calcGadgetRow())
              EndIf
              
            Case #SCS_G4EH_PL_TXTTRKNO   ; txtTrkNo
              If gnEventType = #PB_EventType_Focus
                debugMsg(sProcName, "txtTrkNo focus calling WQP_calcGadgetRow()")
                nCurrentRow = WQP_calcGadgetRow()
                debugMsg(sProcName, "txtTrkNo focus calling WQP_setCurrentRow(" + nCurrentRow + ")")
                WQP_setCurrentRow(nCurrentRow)
              EndIf
              
            Case #SCS_G4EH_PL_TXTLENGTH   ; txtLength
              If gnEventType = #PB_EventType_Focus
                WQP_setCurrentRow(WQP_calcGadgetRow())
              EndIf
              
            Case #SCS_G4EH_PL_TXTPLAYLENGTH   ; txtPlayLength
              If gnEventType = #PB_EventType_Focus
                WQP_setCurrentRow(WQP_calcGadgetRow())
              EndIf
              
            Case #SCS_G4EH_PL_TXTRELLEVEL   ; txtRelLevel
              If gnEventType = #PB_EventType_Focus
                WQP_setCurrentRow(WQP_calcGadgetRow())
              EndIf
              
            Case \txtPLFadeInTime   ; txtPLFadeInTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_txtPLFadeInTime_Validate())
              EndSelect
              
            Case \txtPLFadeOutTime   ; txtPLFadeOutTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_txtPLFadeOutTime_Validate())
              EndSelect
              
            Case \txtSubDBLevel[0]   ; txtSubDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_txtSubDBLevel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtSubPan[0]   ; txtSubPan
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_txtSubPan_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtTransTime   ; txtTransTime
              Select gnEventType
                Case #PB_EventType_Change
                  WQP_txtTransTime_Change()
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_txtTransTime_Validate())
              EndSelect
              
            Case #SCS_G4EH_PL_TXTSTARTAT    ; txtStartAt
              Select gnEventType
                Case #PB_EventType_Focus
                  WQP_setCurrentRow(WQP_calcGadgetRow())
                Case #PB_EventType_LostFocus
                  ETVAL(WQP_validatePLItem(gnEventGadgetNo, WQP_calcGadgetRow(), "ST"))
              EndSelect
              
            Default
              debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + "), gnEventGadgetNoForEvHdlr=G" + gnEventGadgetNoForEvHdlr + ", gnEventType=" + decodeEventType())
          EndSelect
          
        EndIf
        
      Case #PB_Event_GadgetDrop
        Select gnEventGadgetNoForEvHdlr
          Case \scaFiles
            debugMsg(sProcName, "gadget drop on scaFiles")
            WQP_processDroppedFiles()
          Default
            debugMsg(sProcName, "#PB_Event_GadgetDrop gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      CompilerIf #c_include_mygrid_for_playlists
      Case #MyGrid_Event_Change ; fired when cell content has changed from outside / #MyGrid_Att_ChangedRow and #MyGrid_Att_ChangedCol can be used to see what cell has changed
        ; debugMsg0(sProcName, "#MyGrid_Event_Change, gnEventGadgetNoForEvHdlr=" + gnEventGadgetNoForEvHdlr + ", WQP\grdPlaylist=" + WQP\grdPlaylist)
        nRow = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_ChangedRow)
        nCol = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_ChangedCol)
        ; debugMsg0(sProcName, "#MyGrid_Event_Change, nRow=" + nRow + ", nCol=" + nCol)
        EvGd = EventGadget()
        If EvGd = WQP\grdPlaylist ; #Grid_Nbr
          rr = MyGrid_GetAttribute(EvGd, #MyGrid_Att_ChangedRow)
          cc = MyGrid_GetAttribute(EvGd, #MyGrid_Att_ChangedCol)
          wrd = MyGrid_LastChangedCellText(EvGd)
          ; debugMsg0(sProcName, " ... Change occured in Cell (" + rr +","+ cc + ") .. old text:" + wrd)
        EndIf
        
      Case #MyGrid_Event_Click ; fired when a button-cell received a full click / #MyGrid_Att_ClickedRow and #MyGrid_Att_ClickedCol can be used to see what cell has been clicked
        ; debugMsg0(sProcName, "#MyGrid_Event_Click, gnEventGadgetNoForEvHdlr=" + gnEventGadgetNoForEvHdlr + ", WQP\grdPlaylist=" + WQP\grdPlaylist)
        EvGd = EventGadget()
        If EvGd = WQP\grdPlaylist ; #Grid_Nbr
          rr = MyGrid_GetAttribute(EvGd, #MyGrid_Att_ClickedRow)
          cc = MyGrid_GetAttribute(EvGd, #MyGrid_Att_ClickedCol)
          debugMsg0(sProcName, " ... Button clicked in Cell (" + rr +","+ cc + ")")
          If cc = 3 ; Browse
            ; debugMsg0(sProcName, "calling WQP_btnBrowse_Click(" + rr + ")")
            WQP_btnBrowse_Click(rr)
          EndIf
        EndIf
        
      Case #MyGrid_Event_LostFocus
        nLostFocusRow = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_LostFocusRow)
        nLostFocusCol = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_LostFocusCol)
        ; debugMsg0(sProcName, "#MyGrid_Event_LostFocus, nLostFocusRow=" + nLostFocusRow + ", nLostFocusCol=" + nLostFocusCol)
        If nLostFocusRow > 0
          Select nLostFocusCol
            Case 5  ; start at
              debugMsg0(sProcName, "Start At")
              WQP_validatePLItem(gnEventGadgetNo, WQP_calcGadgetRow(), "ST")
            Case 6  ; end at
              debugMsg0(sProcName, "End At")
              WQP_validatePLItem(gnEventGadgetNo, WQP_calcGadgetRow(), "EN")
          EndSelect
        EndIf
        
      Case #MyGrid_Event_Focus
        ; Debug "#MyGrid_Event_Focus, gnEventGadgetNoForEvHdlr=" + gnEventGadgetNoForEvHdlr + ", WQP\grdPlaylist=" + WQP\grdPlaylist
        nRow = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_Row)
        nCol = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_Col)
        ; debugMsg0(sProcName, "#MyGrid_Event_Focus, nRow=" + nRow + ", nCol=" + nCol)
        WQP_setCurrentRow(WQP_calcGadgetRow())
;         WQP_setGrdFocusRectangle()
;         nRow = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_Row)
;         nCol = MyGrid_GetAttribute(\grdPlaylist, #MyGrid_Att_Col)
;         debugMsg(sProcName, "#MyGrid_Event_Focus, nRow=" + nRow + ", nCol=" + nCol)
;         WQP_setCurrentRow(WQP_calcGadgetRow())
;         nFocusBorderColor = -1
;         If nRow > 0
;           Select nCol
;             Case 5, 6
;               nFocusBorderColor = RGB(0,0,198)
;           EndSelect
;         EndIf
;         MyGrid_SetColorAttribute(\grdPlaylist, #MyGrid_Color_FocusBorder, nFocusBorderColor)
;         MyGrid_Redraw(\grdPlaylist)
        
      Case #MyGrid_Event_KeyDown
        ; debugMsg0(sProcName, "#MyGrid_Event_KeyDown, gnEventGadgetNoForEvHdlr=" + gnEventGadgetNoForEvHdlr + ", WQP\grdPlaylist=" + WQP\grdPlaylist)
        nCanvasKey = GetGadgetAttribute(\grdPlaylist, #PB_Canvas_Key)
        ; debugMsg0(sProcName, "nCanvasKey=" + nCanvasKey)
;         Select nCanvasKey
;           Case #PB_Shortcut_Tab
;             Debug "Tab"
;             WQP_setGrdFocusRectangle()
;         EndSelect
      CompilerEndIf
        
      Default
        debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQP_setCurrentRow(nPlayListIndex)
  PROCNAMECS(nEditSubPtr)
  
  ; debugMsg(sProcName, #SCS_START + ", nPlayListIndex=" + nPlayListIndex + ", ListSize(WQPFile())=" + ListSize(WQPFile()))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  If (nPlayListIndex >= 0) And (nPlayListIndex < ListSize(WQPFile()))
    SelectElement(WQPFile(), nPlayListIndex)
    WQP_highlightPlayListRow()
  Else
    editSetDisplayButtonsP()
    WQP_setTBSButtons()
  EndIf
  editSetDisplayButtonsP()
  
  With rWQP
    \nCurrPlayListIndex = nPlayListIndex
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_calcGadgetRow()
  PROCNAMECS(nEditSubPtr)
  ; procedure to calculate the row number of a gadget in the scaFiles scrollable area.
  ;  the procedure determines the row number from the position of the container of this gadget.
  ;  we cannot use the usual nGadgetArrayIndex because the user may have moved or deleted some rows, so the nGadgetArrayIndex then becomes
  ;  out-of-sync with the currently-displayed position.
  Protected nRow, nContainerGadgetNo
  
  CompilerIf #c_include_mygrid_for_playlists
    nRow = MyGrid_GetAttribute(WQP\grdPlaylist, #MyGrid_Att_Row) - 1
  CompilerElse
    nContainerGadgetNo = gaGadgetProps(gnEventGadgetPropsIndex)\nContainerGadgetNo
    nRow = Round(GadgetY(nContainerGadgetNo) / GadgetHeight(nContainerGadgetNo), #PB_Round_Down)
  CompilerEndIf
  
  debugMsg(sProcName, "nRow=" + nRow)
  ProcedureReturn nRow
EndProcedure

Procedure WQP_fcLogicalDevP(Index)
  PROCNAMECS(nEditSubPtr)
  Protected bEnabled, nDevIndex, nNrOfOutputChans
  Protected bDevPresent, nListIndex
  Protected sMyTracks.s
  
  With WQP
    If GetGadgetState(\cboPLLogicalDev[Index]) <= 0
      bEnabled = #False
      bDevPresent = #False
    Else
      bEnabled = #True
      bDevPresent = #True
      nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, aSub(nEditSubPtr)\sPLLogicalDev[Index])
      If Index >= 0
        nNrOfOutputChans = grProd\aAudioLogicalDevs(nDevIndex)\nNrOfOutputChans
      EndIf
    EndIf
    
    If CountGadgetItems(WQP\cboPLTracks[Index]) = 0
      populateCboTracksForSub(WQP\cboPLTracks[Index], nEditSubPtr, Index)
    EndIf
    ; \sPLTracks[Index] = ""
    sMyTracks = #SCS_TRACKS_DFLT
    nListIndex = indexForComboBoxRow(\cboPLTracks[Index], sMyTracks, -1)
    ; debugMsg(sProcName, "sMyTracks=" + sMyTracks + ", nListIndex=" + nListIndex)
    If GGS(\cboPLTracks[Index]) <> nListIndex And nListIndex >= 0
      SGS(\cboPLTracks[Index], nListIndex)
    EndIf
    
    setEnabled(\cboSubTrim[Index], bEnabled)
    nListIndex = indexForComboBoxRow(\cboSubTrim[Index], aSub(nEditSubPtr)\sPLDBTrim[Index], -1)
    If nListIndex = -1 And bDevPresent
      nListIndex = 0
    EndIf
    If GetGadgetState(\cboSubTrim[Index]) <> nListIndex
      SGS(\cboSubTrim[Index], nListIndex)
    EndIf
    
    SLD_setEnabled(\sldSubLevel[Index], bEnabled)
    setEnabled(\txtSubDBLevel[Index], bEnabled)
    setTextBoxBackColor(\txtSubDBLevel[Index])
    If bEnabled = #False
      SetGadgetText(\txtSubDBLevel[Index], "")
    EndIf
    
    If nNrOfOutputChans = 2
      SLD_setEnabled(\sldSubPan[Index], bEnabled)
      If aSub(nEditSubPtr)\fPLPan[Index] = #SCS_PANCENTRE_SINGLE
        setEnabled(\btnPLCenter[Index], #False)
      Else
        setEnabled(\btnPLCenter[Index], bEnabled)
      EndIf
      setEnabled(\txtSubPan[Index], bEnabled)
    Else
      SLD_setEnabled(\sldSubPan[Index], #False)
      setEnabled(\btnPLCenter[Index], #False)
      setEnabled(\txtSubPan[Index], #False)
    EndIf
    setTextBoxBackColor(\txtSubPan[Index])
  EndWith
EndProcedure

Procedure WQP_fcPLTestMode()
  PROCNAMECS(nEditSubPtr)
  debugMsg(sProcName, #SCS_START)
  
  With WQP
    gnPLTestMode = GetGadgetState(\cboPLTestMode)
    Select gnPLTestMode
      Case #SCS_PLTESTMODE_10_SECS      ; first and last 10 seconds
        gnPLFirstAndLastTime = 10000
      Case #SCS_PLTESTMODE_5_SECS       ; first and last 5 seconds
        gnPLFirstAndLastTime = 5000
      Default
        gnPLFirstAndLastTime = -1
    EndSelect
    debugMsg(sProcName, "gnPLTestMode=" + Str(gnPLTestMode) + ", gnPLFirstAndLastTime=" + Str(gnPLFirstAndLastTime))
    WQP_buildPlayOrderLBL()
    WQP_doPLTotals()     ; recalcs test time and resets test progress slider
    If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
      SGT(\lblPLInfo, gaCueState(aSub(nEditSubPtr)\nSubState))
    Else
      If nEditAudPtr >= 0
        SGT(\lblPLInfo, gaCueState(aAud(nEditAudPtr)\nAudState))
      Else
        SGT(\lblPLInfo, "")
      EndIf
    EndIf
    editSetDisplayButtonsP()
  EndWith
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQP_fcTransType()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \nPLTransType > #SCS_TRANS_NONE
        setEnabled(WQP\txtTransTime, #True)
      Else
        setEnabled(WQP\txtTransTime, #False)
        If Len(Trim(GetGadgetText(WQP\txtTransTime))) > 0
          SetGadgetText(WQP\txtTransTime, "")
          u = preChangeAudL(\nPLTransTime, GetGadgetText(WQP\lblTransTime))
          \nPLTransTime = grAudDef\nPLTransTime
          debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nPLTransTime=" + \nPLTransTime)
          postChangeAudLN(u, \nPLTransTime)
        EndIf
      EndIf
      setTextBoxBackColor(WQP\txtTransTime)
    EndWith
  EndIf
  
EndProcedure

Procedure WQP_fcTxtPanP(Index)
  PROCNAMEC()
  Protected k
  Protected u, u2
  
  With aSub(nEditSubPtr)
    u = preChangeSubF(\fPLPan[Index], GetGadgetText(WQP\lblSubPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fPLPan[Index] = panStringToSingle(GetGadgetText(WQP\txtSubPan[Index]))
    \fSubPanNow[Index] = \fPLPan[Index]
  EndWith
  
  k = aSub(nEditSubPtr)\nFirstPlayIndex
  While k >= 0
    With aAud(k)
      u2 = preChangeAudF(\fPan[Index], "Pan", k, #SCS_UNDO_ACTION_CHANGE, Index)
      \fAudPlayPan[Index] = aSub(nEditSubPtr)\fPLPan[Index]
      \fPan[Index] = \fAudPlayPan[Index]
      If \nFileState = #SCS_FILESTATE_OPEN
        setLevelsAny(k, Index, #SCS_NOVOLCHANGE_SINGLE, \fPan[Index])
      EndIf
      postChangeAudFN(u2, \fPan[Index], k, Index)
      k = \nNextPlayIndex
    EndWith
  Wend
  
  With aSub(nEditSubPtr)
    SLD_setValue(WQP\sldSubPan[Index], panToSliderValue(\fPLPan[Index]))
    
    If \fPLPan[Index] = #SCS_PANCENTRE_SINGLE
      setEnabled(WQP\btnPLCenter[Index], #False)
    Else
      setEnabled(WQP\btnPLCenter[Index], #True)
    EndIf
    
    postChangeSubFN(u, \fPLPan[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQP_setTBSButtons()
  PROCNAMEC()
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableInsFile, sToolTipInsFile.s
  Protected bEnableDelFile, sToolTipDelFile.s
  Protected bEnableRename, sToolTipRename.s
  Protected sFileName.s, bFileNamePresent
  Protected sToolTipFile.s
  Protected nLastFile
  Protected *oldElement
  Protected n, nAudPtr
  Protected nListIndex
  Protected nFileCount
  
  debugMsg(sProcName, #SCS_START)
  
  nListIndex = -1
  nLastFile = -1
  
  If ListSize(WQPFile()) > 0
    nListIndex = ListIndex(WQPFile())
    If nListIndex >= 0
      CompilerIf #c_include_mygrid_for_playlists
        sToolTipFile = Str(nListIndex + 1) ; shows row number
      CompilerElse
        sToolTipFile = GGT(WQPFile()\txtTrkNo)
      CompilerEndIf
    EndIf
    
    *oldElement = @WQPFile()
    ForEach WQPFile()
      If WQPFile()\nAudPtr > 0
        nFileCount + 1
        nLastFile = ListIndex(WQPFile())
      EndIf
    Next WQPFile()
    ChangeCurrentElement(WQPFile(), *oldElement)
    
    nAudPtr = -1
    If nListIndex >= 0
      nAudPtr = WQPFile()\nAudPtr
    EndIf
    If nAudPtr >= 0
      sFileName = GetFilePart(aAud(nAudPtr)\sFileName)
      If sFileName
        bFileNamePresent = #True
        sToolTipFile + " (" + sFileName + ")"
      EndIf
    EndIf
    
  EndIf
  
  If (nListIndex > 0) And (nListIndex <= nLastFile)
    bEnableMoveUp = #True
    sToolTipMoveUp = LangPars("WQP", "tbsMoveFileUpTT", sToolTipFile)
  EndIf
  If nListIndex < nLastFile
    bEnableMoveDown = #True
    sToolTipMoveDown = LangPars("WQP", "tbsMoveFileDownTT", sToolTipFile)
  EndIf
  If bFileNamePresent
    bEnableInsFile = #True
    sToolTipInsFile = LangPars("WQP", "tbsInsFileTT", sToolTipFile)
    bEnableRename = #True
    sToolTipRename = LangPars("WQP", "tbsRenameTT", sToolTipFile)
    bEnableDelFile = #True
    sToolTipDelFile = LangPars("WQP", "tbsDelFileTT", sToolTipFile)
  EndIf
  ; If (nLastFile > 0) And (nListIndex <= nLastFile)
    ; bEnableDelFile = #True
    ; sToolTipDelFile = LangPars("WQP", "tbsDelFileTT", sToolTipFile)
  ; EndIf
  
  setEnabled(WQP\imgButtonTBS[0], bEnableMoveUp)
  scsToolTip(WQP\imgButtonTBS[0], sToolTipMoveUp)
  
  setEnabled(WQP\imgButtonTBS[1], bEnableMoveDown)
  scsToolTip(WQP\imgButtonTBS[1], sToolTipMoveDown)
  
  setEnabled(WQP\imgButtonTBS[2], bEnableInsFile)
  scsToolTip(WQP\imgButtonTBS[2], sToolTipInsFile)
  
  setEnabled(WQP\imgButtonTBS[3], bEnableDelFile)
  scsToolTip(WQP\imgButtonTBS[3], sToolTipDelFile)
  
  setEnabled(WQP\btnRename, bEnableRename)
  scsToolTip(WQP\btnRename, sToolTipRename)
  
EndProcedure

Procedure WQP_mnuRemoveAllFiles()
  ; Procedure added Feb2020 11.8.2.2al
  PROCNAMECS(nEditSubPtr)
  Protected nAudPtr
  Protected u, u2
  Protected bLockedMutex
  Protected sAction.s, sMsg.s, nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    
    With aSub(nEditSubPtr)
      
      If \nAudCount > 0
        sAction = Lang("Menu", "mnuWQPRemoveAllFiles")
        sMsg = LangPars("Common", "AreYouSure", sAction)
        nResponse = scsMessageRequester(sAction, sMsg, #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
        If nResponse = #PB_MessageRequester_Yes
          
          LockCueListMutex(456)
          
          u = preChangeSubL(#True, "Remove Playlist Files", nEditSubPtr, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
          nAudPtr = aSub(nEditSubPtr)\nFirstAudIndex ; Corrected 8Dec2021 11.8.6cv (was aSub(nEditAudPtr)...)
          While nAudPtr >= 0
            u2 = preChangeAudL(#True, "Remove Playlist File", nAudPtr, #SCS_UNDO_ACTION_DELETE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
            closeAud(nAudPtr)
            aAud(nAudPtr)\bExists = #False
            postChangeAudL(u2, #False, -1)
            nAudPtr = aAud(nAudPtr)\nNextAudIndex
          Wend
          
          \nAudCount = grSubDef\nAudCount
          \nFirstAudIndex = grSubDef\nFirstAudIndex
          \nFirstPlayIndex = grSubDef\nFirstPlayIndex
          \nFirstPlayIndexThisRun = grSubDef\nFirstPlayIndexThisRun
          \nLastPlayIndex = grSubDef\nLastPlayIndex
          \nCurrPlayIndex = grSubDef\nCurrPlayIndex
          \bSubPlaceHolder = #True
          
          ; WQP_resetSubDescrIfReqd()
          ; Do NOT call WQP_resetSubDescrIfReqd() as that would reset the Sub Description to "[Placeholder]", but it is preferable to leave the Sub Descxription unchanged
          ; as it will typically be something like "Pre-Show Music" and that would still be relevant when the playlist is re-populated.
          
          postChangeSubL(u, #False)
          
          UnlockCueListMutex()
          
          debugMsg(sProcName, "calling displaySub(" + getSubLabel(nEditSubPtr) + ")")
          displaySub(nEditSubPtr)
          
        EndIf ; EndIf nResponse = #PB_MessageRequester_Yes
        
      EndIf ; EndIf \nAudCount > 0
      
    EndWith
    
  EndIf ; EndIf nEditSubPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_imgButtonTBS_Click(nButtonId)
  PROCNAMECS(nEditSubPtr)
  Protected nIndex, nNewIndex, nAudPtr, nListIndex
  Protected *firstElement, *secondElement
  Protected u, u2
  
  debugMsg(sProcName, #SCS_START)
  
  *firstElement = @WQPFile()
  nIndex = ListIndex(WQPFile())
  nNewIndex = -1
  
  debugMsg(sProcName, "ListSize(WQPFile())=" + ListSize(WQPFile()))
  Select nButtonId
    Case #SCS_STANDARD_BTN_MOVE_UP  ; move up
      debugMsg(sProcName, "move up")
      u = preChangeSubL(#True, "Move Playlist File Up", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
      nNewIndex = nIndex - 1
      SelectElement(WQPFile(), nNewIndex)
      *secondElement = @WQPFile()
      SwapElements(WQPFile(), *firstElement, *secondElement)
      
    Case #SCS_STANDARD_BTN_MOVE_DOWN  ; move down
      debugMsg(sProcName, "move down")
      u = preChangeSubL(#True, "Move Playlist File Down", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
      nNewIndex = nIndex + 1
      SelectElement(WQPFile(), nNewIndex)
      *secondElement = @WQPFile()
      SwapElements(WQPFile(), *firstElement, *secondElement)
      
    Case #SCS_STANDARD_BTN_PLUS ; insert file
      debugMsg(sProcName, "insert file")
      u = preChangeSubL(#True, "Add Playlist File", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
      WQP_btnBrowse_Click(nIndex, #True)
      nNewIndex = nIndex
      debugMsg(sProcName, "nNewIndex=" + nNewIndex)
      
    Case #SCS_STANDARD_BTN_MINUS  ; remove file
      debugMsg(sProcName, "remove file")
      u = preChangeSubL(#True, "Remove Playlist File", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
      nAudPtr = WQPFile()\nAudPtr
      If nAudPtr >= 0
        u2 = preChangeAudL(#True, "Remove Playlist File", nAudPtr, #SCS_UNDO_ACTION_DELETE, -1, #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
        closeAud(nAudPtr)
        aAud(nAudPtr)\bExists = #False
        postChangeAudL(u2, #False, -1)
      EndIf
      nNewIndex = removeWQPFile()
      
  EndSelect
  debugMsg(sProcName, "ListSize(WQPFile())=" + ListSize(WQPFile()) + ", nNewIndex=" + nNewIndex)
  
  If nNewIndex < (ListSize(WQPFile()) - 1)
    SelectElement(WQPFile(), nNewIndex)
  EndIf
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)
  WQP_updatePlayListElements(nIndex, nNewIndex)
  WQP_resetSubDescrIfReqd()
  WQP_highlightPlayListRow()
  editSetDisplayButtonsP() ; Added 7Dec2020 11.8.3.3as
  postChangeSubL(u, #False)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_displayPlayList(bTrkNoOnly=#True)
  PROCNAMECS(nEditSubPtr)
  Protected k, nFileDuration, *oldElement, nGrdPlaylist, sText.s, nGrdRowNo, nGrdColNo
  Protected nRowCount, nColCount
  
  debugMsg(sProcName, #SCS_START)
  
  *oldElement = @WQPFile()
  
  CompilerIf #c_include_mygrid_for_playlists
    nGrdPlaylist = WQP\grdPlaylist
    nRowCount = MyGrid_GetAttribute(nGrdPlaylist, #MyGrid_Att_RowCount)
    nColCount = MyGrid_GetAttribute(nGrdPlaylist, #MyGrid_Att_ColCount)
    debugMsg(sProcName, "nRowCount=" + nRowCount + ", nColCount=" + nColCount)
    For nGrdRowNo = 1 To nRowCount
      For nGrdColNo = 1 To nColCount
        MyGrid_SetText(nGrdPlaylist, nGrdRowNo, nGrdColNo, "")
        ; MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, nGrdColNo, rWQP\nStyleCellUnavailable)
        MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, nGrdColNo, rWQP\nStyleCellDisplayLeft)
      Next nGrdColNo
    Next nGrdRowNo
  CompilerEndIf
  
  nGrdRowNo = 0
  ForEach WQPFile()
    k = WQPFile()\nAudPtr
    debugMsg(sProcName, "ListIndex(WQPFile())=" + ListIndex(WQPFile()) + ", nAudPtr=" + getAudLabel(k))
    CompilerIf #c_include_mygrid_for_playlists
      If k >= 0
        With aAud(k)
          nGrdRowNo + 1
          If grEditorPrefs\bShowFileFoldersInEditor
            sText = \sStoredFileName
          Else
            sText = GetFilePart(\sStoredFileName)
          EndIf
          debugMsg(sProcName, "calling MyGrid_SetText(" + getGadgetName(nGrdPlayList) + ", " + nGrdRowNo + ", 2, " + #DQUOTE$ + sText + #DQUOTE$ + ")")
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 2, sText)
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 2, rWQP\nStyleCellDisplayLeft)
          MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 3, "...")
          MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 3, rWQP\nStyleCellButton)
          ; GadgetToolTip(WQPFile()\txtFileNameP, \sFileName)
          If Trim(\sFileName)
            setDerivedAudFields(k)
            nFileDuration = \nFileDuration
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 1, Str(\nAudNo))                                    ; No.
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 1, rWQP\nStyleCellDisplayCenter)
            WQP_populateLength(k)                                                                    ; File Length
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 5, timeToStringBWZT(\nStartAt, nFileDuration))      ; Start At
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 5, rWQP\nStyleCellEditLeft)
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 6, timeToStringBWZT(\nEndAt, nFileDuration))        ; End At
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 6, rWQP\nStyleCellEditLeft)
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 7, timeToStringBWZT(\nCueDuration, nFileDuration))  ; Play Length
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 7, rWQP\nStyleCellDisplayLeft)
            MyGrid_SetText(nGrdPlaylist, nGrdRowNo, 8, StrF(\fPLRelLevel,0)+"%")                        ; Relative level
            MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, 8, rWQP\nStyleCellDisplayLeft)
          EndIf
        EndWith
      EndIf
    CompilerElse
      If k >= 0
        With aAud(k)
          SGT(WQPFile()\txtTrkNo, Str(\nAudNo))                                       ; No.
          If bTrkNoOnly = #False
            nFileDuration = \nFileDuration
            If grEditorPrefs\bShowFileFoldersInEditor
              SGT(WQPFile()\txtFileNameP, \sStoredFileName)                              ; Audio File Name
            Else
              SGT(WQPFile()\txtFileNameP, GetFilePart(\sStoredFileName))
            EndIf
            WQP_populateLength(k)                                                        ; File Length
            SGT(WQPFile()\txtStartAt, timeToStringBWZT(\nStartAt, nFileDuration))        ; Start At
            SGT(WQPFile()\txtEndAt, timeToStringBWZT(\nEndAt, nFileDuration))            ; End At
            SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, nFileDuration)) ; Play Length
            SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
          EndIf
        EndWith
      Else
        SGT(WQPFile()\txtTrkNo, "")                                                     ; No.
        If bTrkNoOnly = #False
          SGT(WQPFile()\txtFileNameP, "")                                               ; Audio File
          SGT(WQPFile()\txtLength, "")                                                  ; File Length
          scsToolTip(WQPFile()\txtLength, "")
          SGT(WQPFile()\txtStartAt, "")                                                 ; Start At
          SGT(WQPFile()\txtEndAt, "")                                                   ; End At
          SGT(WQPFile()\txtPlayLength, "")                                              ; Play Length
          SGT(WQPFile()\txtRelLevel, "")
        EndIf
      EndIf
      WQP_setFileCurrRowPos()
    CompilerEndIf
  Next WQPFile()
  CompilerIf #c_include_mygrid_for_playlists
    rWQP\nExtraRowNo = nGrdRowNo + 1
    WQP_populateExtraRow()
  CompilerEndIf
  ChangeCurrentElement(WQPFile(), *oldElement)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_updatePlayListElements(nFirstIndex, nSecondIndex)
  PROCNAMEC()
  Protected nAudPtr, *oldElement, n, nThisIndex
  
  debugMsg(sProcName, #SCS_START + ", nFirstIndex=" + nFirstIndex + ", nSecondIndex=" + nSecondIndex)
  
  *oldElement = @WQPFile()
  
  For n = 1 To 2
    If n = 1
      nThisIndex = nFirstIndex
    Else
      nThisIndex = nSecondIndex
    EndIf
    If nThisIndex >= 0
      SelectElement(WQPFile(), nThisIndex)
      nAudPtr = WQPFile()\nAudPtr
      CompilerIf #c_include_mygrid_for_playlists
        ; ????????????????????????
      CompilerElse
        If nAudPtr >= 0
          SGT(WQPFile()\txtTrkNo, Str(aAud(nAudPtr)\nAudNo))
        Else
          SGT(WQPFile()\txtTrkNo, "")
        EndIf
      CompilerEndIf
      WQP_setFileCurrRowPos()
    EndIf
  Next n
  
  ChangeCurrentElement(WQPFile(), *oldElement)
  
  CompilerIf #c_include_mygrid_for_playlists
    WQP_displayPlayList(#False)
    MyGrid_Redraw(WQP\grdPlaylist)
  CompilerEndIf

EndProcedure

Procedure WQP_doPLTotals()
  PROCNAMECS(nEditSubPtr)
  Protected nTestTime
  
  setPLFades(nEditSubPtr)
  ; debugMsg(sProcName, "calling calcPLTotalTime(" + getSubLabel(nEditSubPtr) + ")")
  calcPLTotalTime(nEditSubPtr)
  If grCED\bQPCreated
    ; SGT(WQP\txtPLTotalTime, timeToStringBWZT(aSub(nEditSubPtr)\nPLTotalTime))
    ; 27Nov2017 11.7.0bb changed timeToStringBWZT() to timeToStringBWZ() in line with displaySubP() as the total time is calculated to the nearest 1/100 second, not to 1/1000 second
    SGT(WQP\txtPLTotalTime, timeToStringBWZ(aSub(nEditSubPtr)\nPLTotalTime))
    nTestTime = aSub(nEditSubPtr)\nPLTestTime
    If SLD_getMax(WQP\sldPLProgress[1]) <> nTestTime
      SLD_setValue(WQP\sldPLProgress[1], 0)
      ; debugMsg(sProcName, "SLD_setValue(WQP\sldPLProgress[1], 0")
      SLD_setMax(WQP\sldPLProgress[1], (nTestTime-1))
    EndIf
  EndIf
EndProcedure

Procedure WQP_getRowForAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected *oldElement, nRow
  
  *oldElement = @WQPFile()
  ForEach WQPFile()
    If WQPFile()\nAudPtr = pAudPtr
      nRow = ListIndex(WQPFile())
      Break
    EndIf
  Next WQPFile()
  ChangeCurrentElement(WQPFile(), *oldElement)
  ProcedureReturn nRow
EndProcedure

Procedure WQP_resetSubDescrIfReqd(bForceReset=#False)
  PROCNAMECS(nEditSubPtr)
  Protected sOldSubDescr.s
  Protected bCueChanged, bSubChanged
  Protected u2
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; debugMsg(sProcName, "\bDefaultSubDescrMayBeSet=" + strB(\bDefaultSubDescrMayBeSet))
      If \bDefaultSubDescrMayBeSet
        sOldSubDescr = \sSubDescr
        If \nAudCount = 0
          \sSubDescr = grText\sTextPlaceHolder
          \bSubPlaceHolder = #True
        Else
          \sSubDescr = LangPars("WQP", "dfltDescr", Str(\nAudCount))
          \bSubPlaceHolder = #False
        EndIf
        If GGT(WQP\txtSubDescr) <> \sSubDescr Or bForceReset
          SGT(WQP\txtSubDescr, \sSubDescr)
          setSubDescrToolTip(WQP\txtSubDescr)
          WED_setSubNodeText(nEditSubPtr)
          bSubChanged = #True
          If \nPrevSubIndex = -1
            If aCue(\nCueIndex)\sCueDescr = sOldSubDescr
              CompilerIf #c_include_mygrid_for_playlists
                u2 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, "TEMP") ; 6Jan2022 11.10.0ab
              CompilerElse
                u2 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, GGT(WQP\lblFile))
              CompilerEndIf
              aCue(nEditCuePtr)\sCueDescr = \sSubDescr
              bCueChanged = #True
              If GGT(WEC\txtDescr) <> aCue(nEditCuePtr)\sCueDescr
                SGT(WEC\txtDescr, aCue(nEditCuePtr)\sCueDescr)
                WED_setCueNodeText(nEditCuePtr)
                aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
              EndIf
              postChangeCueS(u2, aCue(nEditCuePtr)\sCueDescr)
            EndIf
          EndIf
        EndIf
      EndIf
      
      If bCueChanged
        loadGridRow(nEditCuePtr)
      EndIf
      
      If bSubChanged
        If \nPrevSubIndex >= 0 Or \nNextSubIndex >= 0
          ; multiple sub-cues
          WED_setCueNodeText(nEditCuePtr)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQP_listWQPFile()
  PROCNAMEC()
  Protected *oldElement
  
  *oldElement = @WQPFile()
  debugMsg(sProcName, "ListSize(WQPFile())=" + Str(ListSize(WQPFile())))
  ForEach WQPFile()
    debugMsg(sProcName, "ListIndex(WQPFile())=" + Str(ListIndex(WQPFile())) + ", \nAudPtr=" + getAudLabel(WQPFile()\nAudPtr))
  Next WQPFile()
  ChangeCurrentElement(WQPFile(), *oldElement)
  
EndProcedure

Procedure WQP_renamePlaylistFile()
  PROCNAMEC()
  Protected nRow, nAudPtr
  
  nRow = ListIndex(WQPFile())
  If nRow >= 0
    nAudPtr = WQPFile()\nAudPtr
    If nAudPtr >= 0 And WQPFile()\nFileNameLen > 0
      WFR_renameAudFile(aAud(nAudPtr)\sFileName, "P")
      ; no further action allowed here as WFR_renameAudFile() opens a modal window
    EndIf
  EndIf
EndProcedure

Procedure WQP_chkShowFileFolders()
  PROCNAMEC()
  Protected k
  Protected *oldElement
  
  grEditorPrefs\bShowFileFoldersInEditor = getOwnState(WQP\chkShowFileFolders)
  
  *oldElement = @WQPFile()
  ForEach WQPFile()
    k = WQPFile()\nAudPtr
    If k >= 0
      CompilerIf #c_include_mygrid_for_playlists
        ; ??????????????????????
      CompilerElse
        If grEditorPrefs\bShowFileFoldersInEditor
          SGT(WQPFile()\txtFileNameP, aAud(k)\sStoredFileName)
        Else
          SGT(WQPFile()\txtFileNameP, GetFilePart(aAud(k)\sStoredFileName))
        EndIf
      CompilerEndIf
    EndIf
  Next WQPFile()
  ChangeCurrentElement(WQPFile(), *oldElement)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_processDroppedFiles()
  PROCNAMECS(nEditSubPtr)
  Protected sDroppedFiles.s
  Protected nFileCount
  Protected Dim sFileName.s(0)
  Protected nScrollAreaY, nFirstVisibleRowNo, nVisibleRowNo, nActualRowNo
  Protected sFileName.s, sFileExt.s, sStoredFileName.s
  Protected n, nNewIndex, bEmptyRowFound
  Protected u
  Protected Dim u4(0)
  Protected Dim sNewFileName.s(0)
  Protected Dim nNewAudPtr(0)
  
  sDroppedFiles = EventDropFiles()
  nFileCount = CountString(sDroppedFiles, Chr(10)) + 1
  debugMsg(sProcName, "nFileCount=" + Str(nFileCount))
  debugMsg(sProcName, "sDroppedFiles=" + sDroppedFiles)
  
  If nFileCount = 0
    ProcedureReturn
  EndIf
  
  nScrollAreaY = GetGadgetAttribute(WQP\scaFiles, #PB_ScrollArea_Y)
  nFirstVisibleRowNo = Round(nScrollAreaY / 21, #PB_Round_Nearest)
  nVisibleRowNo = Round(EventDropY() / 21, #PB_Round_Nearest)
  nActualRowNo = nFirstVisibleRowNo + nVisibleRowNo
  If nActualRowNo > aSub(nEditSubPtr)\nAudCount
    nActualRowNo = aSub(nEditSubPtr)\nAudCount
    If nActualRowNo < 0
      nActualRowNo = 0
    EndIf
  EndIf
  
  debugMsg(sProcName, "nActualRowNo=" + Str(nActualRowNo))
  
  ; Check the data
  For n = 1 To nFileCount
    sFileName = StringField(sDroppedFiles, n, Chr(10))
    sFileExt = LCase(GetExtensionPart(sFileName))
    If FindString(gsAudioFileTypes, sFileExt) = 0
      scsMessageRequester(Lang("WQP", "Drag&Drop"), LangPars("Errors", "FileFormatNotSupported", GetFilePart(sFileName)), #PB_MessageRequester_Error)
      ProcedureReturn
    EndIf
  Next n
  
  If nActualRowNo >= 0 And nActualRowNo < ListSize(WQPFile())
    SelectElement(WQPFile(), nActualRowNo)
  EndIf
  
  ; Get the data
  ReDim u4(nFileCount)
  ReDim sNewFileName(nFileCount)
  ReDim nNewAudPtr(nFileCount)

  u = preChangeSubL(#True, "Playlist Drag-and-Drop")
  For n = 1 To nFileCount
    sFileName = StringField(sDroppedFiles, n, Chr(10))
    nNewIndex = insertWQPFile()
    setEditAudPtr(-1)
    u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
    If nEditAudPtr < 0
      ProcedureReturn
    EndIf
    debugMsg(sProcName, "n=" + n + ", nEditAudPtr=" + nEditAudPtr)
    With aAud(nEditAudPtr)
      nNewAudPtr(n) = nEditAudPtr
      \sFileName = sFileName
      \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
      debugMsg(sProcName, "\sFileName=" + \sFileName)
      If getInfoAboutFile(\sFileName)
        \nFileDuration = grInfoAboutFile\nFileDuration
        \nFileChannels = grInfoAboutFile\nFileChannels
        \sFileTitle = grInfoAboutFile\sFileTitle
      Else
        debugMsg(sProcName, "getInfoAboutFile returned false for " + \sFileName)
      EndIf
      setDerivedAudFields(nEditAudPtr)
      CompilerIf #c_include_mygrid_for_playlists
        ; ??????????????????????????
      CompilerElse
        If grEditorPrefs\bShowFileFoldersInEditor
          SGT(WQPFile()\txtFileNameP, \sStoredFileName)
        Else
          SGT(WQPFile()\txtFileNameP, GetFilePart(\sStoredFileName))
        EndIf
        WQP_populateLength(nEditAudPtr)
        SGT(WQPFile()\txtStartAt, timeToStringBWZT(\nStartAt, \nFileDuration))
        SGT(WQPFile()\txtEndAt, timeToStringBWZT(\nEndAt, \nFileDuration))
        SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, \nFileDuration))
        SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
      CompilerEndIf
      WQPFile()\nAudPtr = nEditAudPtr
      WQPFile()\nFileNameLen = Len(\sFileName)
      sNewFileName(n) = \sFileName
    EndWith
    If n < nFileCount
      NextElement(WQPFile())
    EndIf
  Next n
  
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)  ; nb sets nAudNo's in aAud's
  setLabels(nEditCuePtr)
  generatePlayOrder(nEditSubPtr)
  setCueState(nEditCuePtr)
  
  ; refresh track numbers
  ForEach WQPFile()
    If WQPFile()\nAudPtr >= 0
      With aAud(WQPFile()\nAudPtr)
        CompilerIf #c_include_mygrid_for_playlists
          ; ????????????
        CompilerElse
          SGT(WQPFile()\txtTrkNo, Str(\nAudNo))
        CompilerEndIf
      EndWith
    EndIf
  Next WQPFile()
  
  For n = 1 To nFileCount
    postChangeAudL(u4(n), #False, nNewAudPtr(n))
  Next n
  
  WQP_resetSubDescrIfReqd()
  
  postChangeSubL(u, #False)
  
  ; create an empty row if required
  bEmptyRowFound = #False
  ForEach WQPFile()
    If WQPFile()\nFileNameLen = 0
      bEmptyRowFound = #True
      Break
    EndIf
  Next WQPFile()
  If bEmptyRowFound = #False
    createWQPFile()
  EndIf
  
  debugMsg(sProcName, "calling WQP_setCurrentRow(" + Str(nActualRowNo) + ")")
  WQP_setCurrentRow(nActualRowNo)   ; select first added row
  
  setFileSave()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQP
    If IsGadget(\scaPlaylist)
      ; \scaPlaylist automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaPlaylist) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaPlaylist, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailP
      nHeight = nInnerHeight - GadgetY(\cntSubDetailP)
      ResizeGadget(\cntSubDetailP, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      CompilerIf #c_include_mygrid_for_playlists
        ; adjust the height of \scaFiles
        nHeight = GadgetHeight(\cntSubDetailP) - GadgetY(\grdPlaylist) - GadgetHeight(\cntInfoBelowFiles) - 6
        debugMsg(sProcName, "calling MyGrid_Resize()")
        MyGrid_Resize(\grdPlaylist, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ; adjust the top position of the controls below \scaFiles
        nTop = GadgetY(\grdPlaylist) + GadgetHeight(\grdPlaylist) + 3
        ResizeGadget(\cntInfoBelowFiles, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      CompilerElse
        ; adjust the height of \scaFiles
        nHeight = GadgetHeight(\cntSubDetailP) - GadgetY(\scaFiles) - GadgetHeight(\cntInfoBelowFiles) - 6
        ResizeGadget(\scaFiles, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ; adjust the top position of the controls below \scaFiles
        nTop = GadgetY(\scaFiles) + GadgetHeight(\scaFiles) + 3
        ResizeGadget(\cntInfoBelowFiles, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      CompilerEndIf
      
    EndIf
  EndWith
EndProcedure

Procedure WQP_setupGrdPlaylist()
  PROCNAMEC()
  CompilerIf #c_include_mygrid_for_playlists
  Protected nGrdPlaylist
  Protected nTotalWidth, nColNo, nColWidth
  Protected *mg._MyGrid_Type = GetGadgetData(WQP\grdPlaylist)
  
  debugMsg(sProcName, #SCS_START)
  
  nGrdPlaylist = WQP\grdPlaylist
  
  ; debugMsg(sProcName, "calling MyGrid_SetColorAttribute(" + nGrdPlaylist + ", #MyGrid_Color_FocusBorder, -1)")
  ; MyGrid_SetColorAttribute(nGrdPlaylist, #MyGrid_Color_FocusBorder, -1) ; hides focus rectangle
  
  With rWQP
    If \nStyleHeaderLeft = 0
      \nStyleHeaderLeft = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_Font(nGrdPlaylist, #SCS_FONT_GEN_NORMAL)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, $F5F5F5)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Left)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #False)
    EndIf
    If \nStyleHeaderCenter = 0
      \nStyleHeaderCenter = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_Font(nGrdPlaylist, #SCS_FONT_GEN_NORMAL)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, $F5F5F5)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Center)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #False)
    EndIf
    If \nStyleCellButton = 0
      \nStyleCellButton = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, RGB(207, 207, 207))
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Button)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Center)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #True)
    EndIf
    If \nStyleCellDisplayLeft = 0
      \nStyleCellDisplayLeft = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, #SCS_Very_Light_Grey)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Left)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #False)
    EndIf
    If \nStyleCellDisplayCenter = 0
      \nStyleCellDisplayCenter = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, #SCS_Very_Light_Grey)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Center)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #False)
    EndIf
    If \nStyleCellEditLeft = 0
      \nStyleCellEditLeft = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Left)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #True)
    EndIf
    If \nStyleCellHighlightCenter = 0
      \nStyleCellHighlightCenter = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, #SCS_Light_Yellow)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Center)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #False)
    EndIf
    If \nStyleCellUnavailable = 0
      \nStyleCellUnavailable = MyGrid_AddNewStyle(nGrdPlaylist)
      MyGrid_LastStyle_BackColor(nGrdPlaylist, #SCS_White)
      MyGrid_LastStyle_CellType(nGrdPlaylist, #MyGrid_CellType_Normal)
      MyGrid_LastStyle_Align(nGrdPlaylist, #MyGrid_Align_Left)
      MyGrid_LastStyle_Editable(nGrdPlaylist, #False)
    EndIf

    MyGrid_NoRedraw(nGrdPlaylist)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 1, \nStyleHeaderCenter)
    MyGrid_SetText(nGrdPlaylist,0,1,Lang("Common", "No."))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,1,30)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 2, \nStyleHeaderLeft)
    MyGrid_SetText(nGrdPlaylist,0,2,Lang("Common", "AudioFile"))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,2,234) ;272)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 3, \nStyleHeaderCenter)
    MyGrid_SetText(nGrdPlaylist,0,3,"")
    MyGrid_Col_ChangeWidth(nGrdPlaylist,3,20)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 4, \nStyleHeaderLeft)
    MyGrid_SetText(nGrdPlaylist,0,4,Lang("Common","FileLength"))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,4,68)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 5, \nStyleHeaderLeft)
    MyGrid_SetText(nGrdPlaylist,0,5,Lang("Common","StartAt"))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,5,54)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 6, \nStyleHeaderLeft)
    MyGrid_SetText(nGrdPlaylist,0,6,Lang("Common","EndAt"))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,6,54)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 7, \nStyleHeaderLeft)
    MyGrid_SetText(nGrdPlaylist,0,7,Lang("Common","PlayLength"))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,7,68)
    
    MyGrid_AssignStyle(nGrdPlaylist, 0, 8, \nStyleHeaderLeft)
    MyGrid_SetText(nGrdPlaylist,0,8,Lang("WQP","lblRelLevel2"))
    MyGrid_Col_ChangeWidth(nGrdPlaylist,8,54)
    
    MyGrid_Col_Hide(nGrdPlaylist, 0, #True)
    
    For nColNo = 1 To 8
      nColWidth = MyGrid_GetAttribute(nGrdPlaylist, #MyGrid_Att_ColWdith, nColNo)
      debugMsg(sProcName, "Col " + nColNo + " width = " + nColWidth)
      nTotalWidth + nColWidth + 1
    Next nColNo
    debugMsg(sProcName, "nTotalWidth=" + nTotalWidth)
    debugMsg(sProcName, "calling MyGrid_Resize(" + nGrdPlaylist + ", #PB_Ignore, #PB_Ignore, " + nTotalWidth + ", #PB_Ignore)")
    MyGrid_Resize(nGrdPlaylist, #PB_Ignore, #PB_Ignore, nTotalWidth, #PB_Ignore)
    
    MyGrid_Redraw(nGrdPlaylist)
    MyGrid_FocusCell(nGrdPlaylist, 0, 0)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  CompilerEndIf
EndProcedure

Procedure WQP_setFileCurrRowPos()
  PROCNAMEC()
  ; this procedure places the current WQPFile() entry correctly on the screen (within WQP\scaFiles)
  ; this is necessary when elements within WQPFile() have been moved, deleted or inserted
  Protected nListIndex, nTop
  
  nListIndex = ListIndex(WQPFile())
  If nListIndex >= 0
    nTop = nListIndex * #SCS_QPROW_HEIGHT
    CompilerIf #c_include_mygrid_for_playlists
      ; ??????????????
    CompilerElse
      ResizeGadget(WQPFile()\cntFile, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    CompilerEndIf
  EndIf
  
EndProcedure

Procedure WQP_btnPLOther_Click()
  PROCNAMECS(nEditSubPtr)
  DisplayPopupMenu(#WQP_mnu_Other, WindowID(#WED))
EndProcedure

Procedure WQP_mnuClearOrReset(nEventMenu)
  PROCNAMECS(nEditSubPtr)
  Protected nPreEditAudPtr, nThisAudPtr, nCurrAudPtr, bWantThis
  Protected u, u2, sUndoDescr.s, *oldElement
  Protected bRedrawGrdPlaylist
  Protected rReqdAud.tyAud
  CompilerIf #c_include_mygrid_for_playlists
    Protected nGrdRowNo
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  setMouseCursorBusy()
  
  nCurrAudPtr = WQPFile()\nAudPtr
  *oldElement = @WQPFile()
  
  Select nEventMenu
    Case #WQP_mnu_ClearAll
      sUndoDescr = "Clear Start and End Times for ALL files in Playlist Sub-Cue " + getSubLabel(nEditSubPtr)
    Case #WQP_mnu_ClearSel
      sUndoDescr = "Reset Start and End Times for Playlist File " + getAudLabel(nCurrAudPtr)
    Case #WQP_mnu_ResetAll
      sUndoDescr = "Reset Start and End Times for ALL files in Playlist Sub-Cue " + getSubLabel(nEditSubPtr)
    Case #WQP_mnu_ResetSel
      sUndoDescr = "Reset Start and End Times for Playlist File " + getAudLabel(nCurrAudPtr)
  EndSelect
  
  ForEach WQPFile()
    nThisAudPtr = WQPFile()\nAudPtr
    bWantThis = #False
    If nThisAudPtr >= 0
      If nEventMenu = #WQP_mnu_ClearAll Or nEventMenu = #WQP_mnu_ResetAll
        bWantThis = #True
      ElseIf nThisAudPtr = nCurrAudPtr
        bWantThis = #True
      EndIf
    EndIf
    ; debugMsg(sProcName, "nCurrAudPtr=" + getAudLabel(nCurrAudPtr) + ", nThisAudPtr=" + getAudLabel(nThisAudPtr) + ", bWantThis=" + strB(bWantThis))
    If bWantThis
      With aAud(nThisAudPtr)
        Select nEventMenu
          Case #WQP_mnu_ClearAll, #WQP_mnu_ClearSel
            rReqdAud = grAudDef
          Default
            nPreEditAudPtr = \nPreEditPtr
            If nPreEditAudPtr <= 0
              rReqdAud = grAudDef
            Else
              rReqdAud = gaHoldAud(nPreEditAudPtr)
            EndIf
        EndSelect
        If (\nStartAt <> rReqdAud\nStartAt) Or (\nEndAt <> rReqdAud\nEndAt)
          If u = 0
            u = preChangeSubL(#True, sUndoDescr)
          EndIf
          u2 = preChangeAudL(#True, sUndoDescr, nThisAudPtr)
          \nStartAt = rReqdAud\nStartAt
          \nEndAt = rReqdAud\nEndAt
          setDerivedAudFields(nThisAudPtr)
          WQP_populateLength(nThisAudPtr)
          CompilerIf #c_include_mygrid_for_playlists
            nGrdRowNo + 1
            MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 5, timeToStringBWZT(\nStartAt, \nFileDuration))
            MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 6, timeToStringBWZT(\nEndAt, \nFileDuration))
            MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 7, timeToStringBWZT(\nCueDuration, \nFileDuration))
            MyGrid_SetText(WQP\GrdPlaylist, nGrdRowNo, 8, StrF(\fPLRelLevel,0) + "%")
            bRedrawGrdPlaylist = #True
          CompilerElse
            SGT(WQPFile()\txtStartAt, timeToStringBWZT(\nStartAt, \nFileDuration))
            SGT(WQPFile()\txtEndAt, timeToStringBWZT(\nEndAt, \nFileDuration))
            SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, \nFileDuration))
            SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%") ; Added 11Mar2024 11.10.2be
          CompilerEndIf
          postChangeAudL(u2, #False, nThisAudPtr)
        EndIf
        If nEventMenu = #WQP_mnu_ClearSel
          ; only clear settings for the selected file, so break out the loop now
          Break
        EndIf
      EndWith
    EndIf
  Next WQPFile()
  ChangeCurrentElement(WQPFile(), *oldElement)

  If u <> 0
    postChangeSubL(u, #False)
  EndIf
  
  If nCurrAudPtr >= 0
    With aAud(nCurrAudPtr)
      SLD_setValue(WQP\sldPLProgress[0], 0)
      SLD_setMax(WQP\sldPLProgress[0], (\nCueDuration-1))
    EndWith
  EndIf
  debugMsg(sProcName, "calling WQP_doPLTotals()")
  WQP_doPLTotals()
  
  CompilerIf #c_include_mygrid_for_playlists
    If bRedrawGrdPlaylist
      MyGrid_Redraw(WQP\grdPlaylist)
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)
  setFileSave()
  
  setMouseCursorNormal()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_applyNormalization(nEventMenu)
  PROCNAMECS(nEditSubPtr)
  Protected nNormalizationType, nAllNormalizationTypes
  Protected nAudPtr, nCurrAudPtr, bWantThis, nFileStatsPtr
  Protected u, u2, sUndoDescr.s, *oldElement
  Protected nSelectedCount, nCalcReqdCount
  Protected bDisplayProgress, nProgress, sProgress.s
  Protected fMaxNewValue.f
  ; Protected nGetDataLength.l
  Protected sMsg.s
  Protected fTarget.f, fIntegrated.f, fPeak.f, fTruePeak.f
  Protected fCalcLevel.f, fPLRelLevel.f
  Protected nIntegratedCount
  Protected qStartTime.q, qFinishTime.q
  Protected nRowIndex, nMaxRowIndex
  Protected nNormMaxValue
  Protected Dim bIntegrated(0), Dim fNewValue.f(0)
  Protected nDevIndex, sReqdLogicalDev.s, fDevDefaultDBLevel.f
  
  debugMsg(sProcName, #SCS_START)
  
  qStartTime = ElapsedMilliseconds()
  
  CompilerIf #c_include_peak
    Select nEventMenu
      Case #WQP_mnu_LUFSNormAll
        nNormalizationType = #SCS_NORMALIZE_LUFS
      Case #WQP_mnu_PeakNormAll
        nNormalizationType = #SCS_NORMALIZE_PEAK
      Case #WQP_mnu_TruePeakNormAll
        nNormalizationType = #SCS_NORMALIZE_TRUE_PEAK
    EndSelect
  CompilerElse
    Select nEventMenu
      Case #WQP_mnu_LUFSNorm100All
        nNormalizationType = #SCS_NORMALIZE_LUFS
        nNormMaxValue = 100
      Case #WQP_mnu_LUFSNorm90All
        nNormalizationType = #SCS_NORMALIZE_LUFS
        nNormMaxValue = 90
      Case #WQP_mnu_LUFSNorm80All
        nNormalizationType = #SCS_NORMALIZE_LUFS
        nNormMaxValue = 80
      Case #WQP_mnu_TruePeakNorm100All
        nNormalizationType = #SCS_NORMALIZE_TRUE_PEAK
        nNormMaxValue = 100
      Case #WQP_mnu_TruePeakNorm90All
        nNormalizationType = #SCS_NORMALIZE_TRUE_PEAK
        nNormMaxValue = 90
      Case #WQP_mnu_TruePeakNorm80All
        nNormalizationType = #SCS_NORMALIZE_TRUE_PEAK
        nNormMaxValue = 80
    EndSelect
  CompilerEndIf
  debugMsg(sProcName, "nNormalizationType=" + decodeNormalize(nNormalizationType))

  sReqdLogicalDev = aSub(nEditSubPtr)\sPLLogicalDev[0]
  For nDevIndex = 0 To grProd\nMaxAudioLogicalDev
    If grProd\aAudioLogicalDevs(nDevIndex)\sLogicalDev = sReqdLogicalDev
      fDevDefaultDBLevel = convertBVLevelToDBLevel(grProd\aAudioLogicalDevs(nDevIndex)\fDfltBVLevel)
      Break
    EndIf
  Next nDevIndex
  
  nCurrAudPtr = WQPFile()\nAudPtr
  ; debugMsg(sProcName, "nCurrAudPtr=" + getAudLabel(nCurrAudPtr))
  *oldElement = @WQPFile()
  
  sUndoDescr = GetMenuItemText(#WQP_mnu_Other, nEventMenu)
  
  CompilerIf #c_include_peak
    nAllNormalizationTypes = #SCS_NORMALIZE_LUFS | #SCS_NORMALIZE_PEAK | #SCS_NORMALIZE_TRUE_PEAK
  CompilerElse
    nAllNormalizationTypes = #SCS_NORMALIZE_LUFS | #SCS_NORMALIZE_TRUE_PEAK
  CompilerEndIf
  fTarget = -23.0 ; INFO: LUFS hard-coded
  ;;;;;;;;; nNormMaxValue = 100 ; used for percentaghe caculation
  fMaxNewValue = -9999999
  
  nRowIndex = -1
  ForEach WQPFile()
    nRowIndex + 1
    nAudPtr = WQPFile()\nAudPtr
    If nAudPtr >= 0
      nMaxRowIndex = nRowIndex ; see comment below regarding nMaxRowIndex
      If aAud(nAudPtr)\bAudPlaceHolder = #False
        nSelectedCount + 1
      EndIf
      If aAud(nAudPtr)\bAudNormSet = #False
        nCalcReqdCount + 1
      EndIf
    EndIf
  Next WQPFile()
  ; nMaxRowIndex calculated in the way above just in case there are any blank rows in the playlist (although there shouldn't be)
  
  If nSelectedCount = 0
    ProcedureReturn
  EndIf
  
  If nCalcReqdCount > 0
    setMouseCursorBusy()
  EndIf
  
  ReDim bIntegrated(nMaxRowIndex)
  ReDim fNewValue(nMaxRowIndex)
  
  If nCalcReqdCount > 1
    WMI_displayInfoMsg1(Lang("WBE", "LUFSCalcTitle"), nCalcReqdCount)
    bDisplayProgress = #True
  EndIf

  nRowIndex = -1
  ForEach WQPFile()
    nRowIndex + 1
    nAudPtr = WQPFile()\nAudPtr
    If nAudPtr >= 0
      With aAud(nAudPtr)
        If \bAudPlaceHolder
          Continue
        EndIf
        If bDisplayProgress And aAud(nAudPtr)\bAudNormSet = #False
          sProgress = getAudLabel(nAudPtr) + " " + GetFilePart(aAud(nAudPtr)\sFileName)
          WMI_displayInfoMsg2(sProgress)
          nProgress + 1
          WMI_setProgress(nProgress)
        EndIf
        If \bAudNormSet = #False
          calcAudLoudness(nAudPtr, nAllNormalizationTypes)
          ; debugMsg0(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\fAudNormIntegrated=" + StrF(\fAudNormIntegrated,3) + ", \fAudNormPeak=" + StrF(\fAudNormPeak,3) + ", \fAudNormTruePeak=" + StrF(\fAudNormTruePeak,3))
        EndIf
        Select nNormalizationType
          Case #SCS_NORMALIZE_LUFS
            fIntegrated = aAud(nAudPtr)\fAudNormIntegrated
            If fIntegrated = -Infinity() ; no loudness level available (too short Or silent)
              bIntegrated(nRowIndex) = #False
            Else
              bIntegrated(nRowIndex) = #True
              nIntegratedCount + 1
              fCalcLevel = convertDBLevelToBVLevel(fTarget - fIntegrated)
            EndIf
            
          CompilerIf #c_include_peak
            Case #SCS_NORMALIZE_PEAK
              fPeak = convertBVLevelToDBLevel(aAud(nAudPtr)\fAudNormPeak)
              fCalcLevel = convertDBLevelToBVLevel(fDevDefaultDBLevel - fPeak)
              ; debugMsg0(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\fAudNormPeak=" + StrF(\fAudNormPeak,3) + ", fPeak=" + StrF(fPeak,3) + ", fCalcLevel=" + StrF(fCalcLevel,3))
          CompilerEndIf
            
          Case #SCS_NORMALIZE_TRUE_PEAK
            fTruePeak = convertBVLevelToDBLevel(aAud(nAudPtr)\fAudNormTruePeak)
            fCalcLevel = convertDBLevelToBVLevel(fDevDefaultDBLevel - fTruePeak)
            
        EndSelect
        fNewValue(nRowIndex) = fCalcLevel
        ; debugMsg0(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", fNewValue(" + nRowIndex + ")=" + StrF(fNewValue(nRowIndex),3))
        If fCalcLevel > fMaxNewValue
          fMaxNewValue = fCalcLevel
        EndIf
      EndWith
    EndIf
  Next WQPFile()
  
  If getWindowVisible(#WMI)
    WMI_Form_Unload()
  EndIf
  
  nRowIndex = -1
  ForEach WQPFile()
    nRowIndex + 1
    nAudPtr = WQPFile()\nAudPtr
    If nAudPtr >= 0
      If aAud(nAudPtr)\bAudPlaceHolder = #False
        With aAud(nAudPtr)
          fPLRelLevel = fNewValue(nRowIndex) * nNormMaxValue / fMaxNewValue
          If \fPLRelLevel <> fPLRelLevel
            If u = 0
              u = preChangeSubL(#True, sUndoDescr)
            EndIf
            u2 = preChangeAudF(\fPLRelLevel, sUndoDescr, nAudPtr)
            \fPLRelLevel = fPLRelLevel
            SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
            postChangeAudF(u2, \fPLRelLevel, nAudPtr)
          EndIf
        EndWith
      EndIf ; EndIf aAud(nAudPtr)\bAudPlaceHolder = #False
    EndIf ; EndIf nAudPtr >= 0
  Next WQPFile()
  
  If u <> 0
    postChangeSubL(u, #False)
  EndIf
  
  If nCurrAudPtr >= 0
    With aAud(nCurrAudPtr)
      SLD_setValue(WQP\sldPLProgress[0], 0)
      SLD_setMax(WQP\sldPLProgress[0], (\nCueDuration-1))
    EndWith
  EndIf
  debugMsg(sProcName, "calling WQP_doPLTotals()")
  WQP_doPLTotals()
  
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)
  setFileSave()
  
  ChangeCurrentElement(WQPFile(), *oldElement)
  WQP_highlightPlayListRow()  ; re-displays info for current row
    
  ;   setMouseCursorNormal()
  If nCalcReqdCount > 0
    setMouseCursorNormal()
  EndIf

  
  qFinishTime = ElapsedMilliseconds()
  debugMsg(sProcName, "fMaxNewValue=" + convertBVLevelToDBString(fMaxNewValue) + ", nSelectedCount=" + nSelectedCount + ", nIntegratedCount=" + nIntegratedCount +
                      ", processing time = " + Str(qFinishTime - qStartTime) + " milliseconds")
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WQP_mnuTrimOrPeakNorm(nEventMenu)
  PROCNAMECS(nEditSubPtr)
  Protected nThisAudPtr, nCurrAudPtr, bWantThis, nFileStatsPtr
  Protected u, u2, sUndoDescr.s, *oldElement
  Protected bRedrawGrdPlaylist
  Protected nReqdStartAt, nReqdEndAt
  Protected nGetFileStatsCount, bDisplayProgressInfo, bDisplayProgress, qStartTime.q, nProgressPtr=-1
  Protected bTrim, bPeakNorm, nPeakNormMax
  Protected nSubMinMaxAbsSample ; the minimum 'maximum absolute sample' of files in this sub
  Protected nAudPtrOfMinMaxAbsSample
  Protected nAudMaxAbsSample, fPLRelLevel.f
  Protected nInitThreadState
  CompilerIf #c_include_mygrid_for_playlists
    Protected nGrdRowNo
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu))
  
  nInitThreadState = THR_getThreadState(#SCS_THREAD_GET_FILE_STATS)
  If nInitThreadState = #SCS_THREAD_STATE_ACTIVE
    THR_suspendAThreadAndWait(#SCS_THREAD_GET_FILE_STATS)
  EndIf
  
  setMouseCursorBusy()
  
  Select nEventMenu
    Case #WQP_mnu_PeakNorm100All
      bPeakNorm = #True
      nPeakNormMax = 100
    Case #WQP_mnu_PeakNorm90All
      bPeakNorm = #True
      nPeakNormMax = 90
    Case #WQP_mnu_PeakNorm80All
      bPeakNorm = #True
      nPeakNormMax = 80
    Default
      bTrim = #True
  EndSelect

  nCurrAudPtr = WQPFile()\nAudPtr
  *oldElement = @WQPFile()
  
  sUndoDescr = GetMenuItemText(#WQP_mnu_Other, nEventMenu)
  
  Select nEventMenu
    Case #WQP_mnu_Trim30All, #WQP_mnu_Trim45All, #WQP_mnu_Trim60All, #WQP_mnu_Trim75All, #WQP_mnu_TrimSilenceAll,  ; Changed 3Oct2022 11.9.6
         #WQP_mnu_PeakNorm100All, #WQP_mnu_PeakNorm90All, #WQP_mnu_PeakNorm80All
      ForEach WQPFile()
        nThisAudPtr = WQPFile()\nAudPtr
        If nThisAudPtr >= 0
          With aAud(nThisAudPtr)
            If (\bAudPlaceHolder = #False) And (\nFileStatsPtr = grAudDef\nFileStatsPtr)
              nGetFileStatsCount + 1
            EndIf
          EndWith
        EndIf
      Next WQPFile()
  EndSelect
  debugMsg(sProcName, "nGetFileStatsCount=" + nGetFileStatsCount)
  If nGetFileStatsCount > 2
    ; if more than 2 files require calls to getFileStats() then display progress info
    bDisplayProgressInfo = #True
    qStartTime = ElapsedMilliseconds()
  EndIf
  
  nSubMinMaxAbsSample = 10000
  ForEach WQPFile()
    bWantThis = #False
    nThisAudPtr = WQPFile()\nAudPtr
    If nThisAudPtr >= 0
      With aAud(nThisAudPtr)
        debugMsg0(sProcName, "aAud(" + getAudLabel(nThisAudPtr) + ")\qStartAtBytePos=" + \qStartAtBytePos + ", \qEndAtBytePos=" + \qEndAtBytePos + ", \nStartAt=" + \nStartAt + ", \nEndAt=" + \nEndAt)
      EndWith
      If bPeakNorm
        ; for peak normalization ALL files in this sub-cue must be processed
        bWantThis = #True
      Else
        If nThisAudPtr >= 0
          Select nEventMenu
            Case #WQP_mnu_Trim30All, #WQP_mnu_Trim45All, #WQP_mnu_Trim60All, #WQP_mnu_Trim75All, #WQP_mnu_TrimSilenceAll ; Changed 3Oct2022 11.9.6
              bWantThis = #True
            Default
              If nThisAudPtr = nCurrAudPtr
                bWantThis = #True
              EndIf
          EndSelect
        EndIf
      EndIf
    EndIf
    ; debugMsg(sProcName, "nCurrAudPtr=" + getAudLabel(nCurrAudPtr) + ", nThisAudPtr=" + getAudLabel(nThisAudPtr) + ", bWantThis=" + strB(bWantThis))
    If bWantThis
      With aAud(nThisAudPtr)
        If \bAudPlaceHolder = #False
          If FileExists(\sFileName, #False)
            If \nFileStatsPtr = grAudDef\nFileStatsPtr
              If bDisplayProgressInfo
                nProgressPtr + 1
                If nProgressPtr = 1
                  WMI_displayInfoMsg1(Lang("Common","Scanning"), nGetFileStatsCount)
                  bDisplayProgress = #True
                EndIf
                If bDisplayProgress
                  WMI_setProgress(nProgressPtr)
                  WMI_displayInfoMsg2(GetFilePart(\sFileName))
                EndIf
              EndIf
              debugMsg(sProcName, "calling getFileStats(" + getAudLabel(nThisAudPtr) + ")")
              getFileStats(nThisAudPtr)
              debugMsg(sProcName, "returned from getFileStats(" + getAudLabel(nThisAudPtr) + "), \nFileStatsPtr=" + \nFileStatsPtr)
            EndIf
            nFileStatsPtr = \nFileStatsPtr
            ; debugMsg(sProcName, "nFileStatsPtr=" + nFileStatsPtr)
            ; debugMsg(sProcName, "gaFileStats(" + nFileStatsPtr + ")\nFileDuration=" + gaFileStats(nFileStatsPtr)\nFileDuration +
            ;                     ", \qFileSize=" + gaFileStats(nFileStatsPtr)\qFileSize +
            ;                     ", \nMaxAbsSample=" + gaFileStats(nFileStatsPtr)\nMaxAbsSample)
            If nFileStatsPtr = grAudDef\nFileStatsPtr Or nFileStatsPtr = -2
              ; nb if \nFileStatsPtr is still the default value after calling getFileStats() this implies getFileStats() couldn't scan the file,
              ; possibly because the length exceeds the max scanning length (see editing options)
            Else
              If bTrim
                Select nEventMenu
                  Case #WQP_mnu_TrimSilenceAll, #WQP_mnu_TrimSilenceSel
                    nReqdStartAt = gaFileStats(nFileStatsPtr)\nSilenceStartAt
                    nReqdEndAt = gaFileStats(nFileStatsPtr)\nSilenceEndAt
                  Case #WQP_mnu_Trim75All, #WQP_mnu_Trim75Sel ; Added 3Oct2022 11.9.6
                    nReqdStartAt = gaFileStats(nFileStatsPtr)\nM75dBStartAt
                    nReqdEndAt = gaFileStats(nFileStatsPtr)\nM75dBEndAt
                  Case #WQP_mnu_Trim60All, #WQP_mnu_Trim60Sel ; Added 3Oct2022 11.9.6
                    nReqdStartAt = gaFileStats(nFileStatsPtr)\nM60dBStartAt
                    nReqdEndAt = gaFileStats(nFileStatsPtr)\nM60dBEndAt
                  Case #WQP_mnu_Trim45All, #WQP_mnu_Trim45Sel
                    nReqdStartAt = gaFileStats(nFileStatsPtr)\nM45dBStartAt
                    nReqdEndAt = gaFileStats(nFileStatsPtr)\nM45dBEndAt
                  Case #WQP_mnu_Trim30All, #WQP_mnu_Trim30Sel
                    nReqdStartAt = gaFileStats(nFileStatsPtr)\nM30dBStartAt
                    nReqdEndAt = gaFileStats(nFileStatsPtr)\nM30dBEndAt
                EndSelect
                ; debugMsg(sProcName, "nReqdStartAt=" + nReqdStartAt + ", aAud(" + getAudLabel(nThisAudPtr) + ")\nStartAt=" + \nStartAt + ", nReqdEndAt=" + nReqdEndAt + ", \nEndAt=" + \nEndAt)
                If (nReqdStartAt <> \nStartAt) Or (nReqdEndAt <> \nEndAt)
                  If u = 0
                    u = preChangeSubL(#True, sUndoDescr)
                  EndIf
                  u2 = preChangeAudL(#True, sUndoDescr, nThisAudPtr)
                  \nStartAt = nReqdStartAt
                  \nEndAt = nReqdEndAt
                  setDerivedAudFields(nThisAudPtr)
                  WQP_populateLength(nThisAudPtr)
                  CompilerIf #c_include_mygrid_for_playlists
                    nGrdRowNo + 1
                    MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 5, timeToStringBWZT(\nStartAt, \nFileDuration))
                    MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 6, timeToStringBWZT(\nEndAt, \nFileDuration))
                    MyGrid_SetText(WQP\grdPlaylist, nGrdRowNo, 7, timeToStringBWZT(\nCueDuration, \nFileDuration))
                    MyGrid_SetText(WQP\GrdPlaylist, nGrdRowNo, 8, StrF(\fPLRelLevel,0) + "%")
                    bRedrawGrdPlaylist = #True
                  CompilerElse
                    SGT(WQPFile()\txtStartAt, timeToStringBWZT(\nStartAt, \nFileDuration))
                    SGT(WQPFile()\txtEndAt, timeToStringBWZT(\nEndAt, \nFileDuration))
                    SGT(WQPFile()\txtPlayLength, timeToStringBWZT(\nCueDuration, \nFileDuration))
                    SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%") ; Added 11Mar2024 11.10.2be
                  CompilerEndIf
                  postChangeAudL(u2, #False, nThisAudPtr)
                EndIf ; EndIf (nReqdStartAt <> \nStartAt) Or (nReqdEndAt <> \nEndAt)
                Select nEventMenu
                  Case #WQP_mnu_Trim30Sel, #WQP_mnu_Trim45Sel, #WQP_mnu_Trim60Sel, #WQP_mnu_Trim75Sel, #WQP_mnu_TrimSilenceSel ; Changed 3Oct2022 11.9.6
                    ; only trim the selected file, so break out of the loop now
                    Break
                EndSelect
              Else
                ; peak normalization - just determine the max abs peak in this first pass of WQPFile()
                If gaFileStats(nFileStatsPtr)\nMaxAbsSample < nSubMinMaxAbsSample
                  nSubMinMaxAbsSample = gaFileStats(nFileStatsPtr)\nMaxAbsSample
                  nAudPtrOfMinMaxAbsSample = nThisAudPtr
                EndIf
              EndIf ; EndIf bTrim / Else
            EndIf ; EndIf nFileStatsPtr >= 0
          EndIf ; EndIf FileExists(\sFileName, #False)
        EndIf ; EndIf \bAudPlaceHolder = #False
      EndWith
    EndIf ; EndIf bWantThis
  Next WQPFile()
  
  If bDisplayProgress
    WMI_clearInfoMsgs()
  EndIf
  
  If bPeakNorm
    debugMsg(sProcName, "nSubMinMaxAbsSample=" + nSubMinMaxAbsSample + ", nAudPtrOfMinMaxAbsSample=" + getAudLabel(nAudPtrOfMinMaxAbsSample))
    ForEach WQPFile()
      nThisAudPtr = WQPFile()\nAudPtr
      If nThisAudPtr >= 0
        If aAud(nThisAudPtr)\bAudPlaceHolder = #False
          With aAud(nThisAudPtr)
            nFileStatsPtr = \nFileStatsPtr
            If nFileStatsPtr >= 0
              nAudMaxAbsSample = gaFileStats(nFileStatsPtr)\nMaxAbsSample
              ; debugMsg(sProcName, "aAud(" + nThisAudPtr + ")\nFileStatsPtr=" + \nFileStatsPtr + ", gaFileStats(" + nFileStatsPtr + ")\nMaxAbsSample returned " + nAudMaxAbsSample)
              fPLRelLevel = nSubMinMaxAbsSample * nPeakNormMax / nAudMaxAbsSample
              If \fPLRelLevel <> fPLRelLevel
                If u = 0
                  u = preChangeSubL(#True, sUndoDescr)
                EndIf
                u2 = preChangeAudF(\fPLRelLevel, sUndoDescr, nThisAudPtr)
                \fPLRelLevel = fPLRelLevel
                CompilerIf #c_include_mygrid_for_playlists
                  ; ??????????????????????
                CompilerElse
                  SGT(WQPFile()\txtRelLevel, StrF(\fPLRelLevel,0)+"%")
                CompilerEndIf
                postChangeAudF(u2, \fPLRelLevel, nThisAudPtr)
              EndIf
              ; debugMsg(sProcName, "aAud(" + getAudLabel(nThisAudPtr) + ")\nFileStatsPtr=" + \nFileStatsPtr +
              ;                     ", gaFileStats(" + nFileStatsPtr + ")\nMaxAbsSample=" + gaFileStats(nFileStatsPtr)\nMaxAbsSample +
              ;                     ", nPeakNormMax=" + nPeakNormMax +
              ;                     ", aAud(" + getAudLabel(nThisAudPtr) + ")\fPLRelLevel=" + StrF(\fPLRelLevel,2))
            EndIf ; EndIf nFileStatsPtr >= 0
          EndWith
        EndIf ; EndIf aAud(nThisAudPtr)\bAudPlaceHolder = #False
      EndIf ; EndIf nThisAudPtr >= 0
    Next WQPFile()
  EndIf ; EndIf bPeakNorm
  
  If u <> 0
    postChangeSubL(u, #False)
  EndIf
  
  If nCurrAudPtr >= 0
    With aAud(nCurrAudPtr)
      SLD_setValue(WQP\sldPLProgress[0], 0)
      SLD_setMax(WQP\sldPLProgress[0], (\nCueDuration-1))
    EndWith
  EndIf
  debugMsg(sProcName, "calling WQP_doPLTotals()")
  WQP_doPLTotals()
  
  CompilerIf #c_include_mygrid_for_playlists
    If bRedrawGrdPlaylist
      MyGrid_Redraw(WQP\grdPlaylist)
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, "calling WQP_updateAudsFromWQPFile(" + getSubLabel(nEditSubPtr) + ")")
  WQP_updateAudsFromWQPFile(nEditSubPtr)
  setFileSave()
  
  ChangeCurrentElement(WQPFile(), *oldElement)
  WQP_highlightPlayListRow()  ; re-displays info for current row
  
  setMouseCursorNormal()
  
  If nInitThreadState = #SCS_THREAD_STATE_ACTIVE
    THR_resumeAThread(#SCS_THREAD_GET_FILE_STATS)
  EndIf

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQP_sldPLProgress_Common(nSliderEventType)
  PROCNAMECA(nEditAudPtr)
  Protected nAbsReposAt
  Protected bReposition
  
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
      nAbsReposAt = SLD_getValue(WQP\sldPLProgress[0]) + \nAbsMin
      debugMsg(sProcName, "sldPLProgress[0].value=" + SLD_getValue(WQP\sldPLProgress[0]) + ", nAbsReposAt=" + nAbsReposAt)
      reposAuds(nEditAudPtr, nAbsReposAt)
      editSetDisplayButtonsP()
      ; redrawGraphAfterMouseChange()
      ; rWQP\bEditProgMouseDown = #False
    EndIf
  EndWith
  
EndProcedure

Procedure WQP_skipBackOrForward(nSkipTime)
  PROCNAMECA(nEditAudPtr)
  ; code based on WQP_sldProgress_Common()
  Protected nValue, nAbsReposAt
  
  debugMsg(sProcName, #SCS_START + ", nSkipTime=" + nSkipTime)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nValue = SLD_getValue(WQP\sldPLProgress[0]) + nSkipTime
      If nValue < SLD_getMin(WQP\sldPLProgress[0])
        nValue = SLD_getMin(WQP\sldPLProgress[0])
      ElseIf nValue > SLD_getMax(WQP\sldPLProgress[0])
        nValue = SLD_getMax(WQP\sldPLProgress[0])
      EndIf
      SLD_setValue(WQP\sldPLProgress[0], nValue, #True)
      
      gqTimeNow = ElapsedMilliseconds()
      nAbsReposAt = SLD_getValue(WQP\sldPLProgress[0]) + \nAbsMin
      debugMsg(sProcName, "sldPLProgress[0].value=" + SLD_getValue(WQP\sldPLProgress[0]) + ", nAbsReposAt=" + nAbsReposAt)
      reposAuds(nEditAudPtr, nAbsReposAt)
      editSetDisplayButtonsP()
      
    EndWith
  EndIf

EndProcedure

Procedure WQP_populateExtraRow()
  PROCNAMEC()
  CompilerIf #c_include_mygrid_for_playlists
    Protected nGrdPlaylist, nGrdRowNo, nGrdColNo
    
    nGrdPlaylist = WQP\grdPlaylist
    nGrdRowNo = rWQP\nExtraRowNo
    
    For nGrdColNo = 1 To 8
      If nGrdColNo = 3
        MyGrid_SetText(nGrdPlaylist, nGrdRowNo, nGrdColNo, "...")
        MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, nGrdColNo, rWQP\nStyleCellButton)
      ElseIf 2=3
        MyGrid_SetText(nGrdPlaylist, nGrdRowNo, nGrdColNo, "")
        MyGrid_AssignStyle(nGrdPlaylist, nGrdRowNo, nGrdColNo, rWQP\nStyleCellDisplayLeft)
      EndIf
    Next nGrdColNo
    
    debugMsg(sProcName, "calling MyGrid_ReDefineRows(" + getGadgetName(nGrdPlaylist) + ", " + nGrdRowNo + ")")
    MyGrid_ReDefineRows(nGrdPlaylist, nGrdRowNo)
  CompilerEndIf
  
EndProcedure

; EOF