; File: fmEditQL.pbi

EnableExplicit

Procedure WQL_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected d, i, j, k
  Protected sTmp.s, sTmp2.s, nThisCuePtr
  Protected bWantThis, nLCTimeForProgressInfo
  Protected nActionSliderGadget, nActionSliderValue

  debugMsg(sProcName, #SCS_START)

  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure sets scrollarea inner height and resizes gadgets
  
  If grCED\bQLCreated = #False
    WQL_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQL\lblSubCueType, pSubPtr)
  
  SetGadgetText(WQL\lblLCComment, "")
  SetGadgetText(WQL\lblAudStatus, "")
  SetGadgetText(WQL\lblLCSubStatus, "")
  SetGadgetText(WQL\lblLCInfo, "")
  
  With rWQL
    \nLatestCuePtr = -1
    \nLatestSubPtr = -1
  EndWith
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "L", WQL)
    
    SetGadgetText(WQL\txtLCStartAt, timeToStringBWZ(\nLCStartAt, \nLCStartAt))
    
    ClearGadgetItems(WQL\cboLCCue)
    sTmp2 = #SCS_BLANK_CBO_ENTRY
    AddGadgetItem(WQL\cboLCCue, -1, sTmp2)
    nThisCuePtr = \nCueIndex
    For i = nThisCuePtr To 1 Step -1
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeHasAuds
          If (i < nThisCuePtr) Or ((i = nThisCuePtr) And (aSub(j)\nSubNo < \nSubNo))
            bWantThis = #True
            If aSub(j)\bSubTypeF
              k = aSub(j)\nFirstAudIndex
              If k >= 0
                If aAud(k)\nFileFormat = #SCS_FILEFORMAT_MIDI
                  bWantThis = #False ; omit MIDI file cues from Level Change cue list
                EndIf
              EndIf
            ElseIf aSub(j)\bSubTypeA
              If aSub(j)\bMuteVideoAudio
                bWantThis = #False
              EndIf
            EndIf
            If bWantThis
              sTmp = buildLCCueForCBO(j)
              AddGadgetItem(WQL\cboLCCue, -1, sTmp)
              If (aSub(j)\sCue = \sLCCue) And (aSub(j)\nSubNo = \nLCSubNo)
                sTmp2 = sTmp
              EndIf
            EndIf
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    Next i
    If (sTmp2 = #SCS_BLANK_CBO_ENTRY) And (\nLCSubPtr >= 0)
      ; if sTmp2 not set even though \nLCSubPtr is set, this may be because the target cue has been moved down past the level change cue
      ; so create an extra entry in the CBO list for the target cue
      sTmp2 = buildLCCueForCBO(\nLCSubPtr)
      AddGadgetItem(WQL\cboLCCue, -1, sTmp2)
    EndIf
    SetGadgetText(WQL\cboLCCue, sTmp2)
    
    WQL_populateCboLCAction()
    debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCAction=" + \nLCAction + " (" + decodeLCAction(\nLCAction) + ")")
    setGadgetItemByData(WQL\cboLCAction, \nLCAction, 0)
    Select \nLCAction
      Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
        WQL_fcLCSameLevel()
        rWQL\bCallSetOrigReqdDBLevels = #True
    EndSelect
    WQL_fcLCAction()
    
    Select \nLCAction
      Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
        nLCTimeForProgressInfo = \nLCTimeMax
        setOwnState(WQL\chkLCSameLevel, \bLCSameLevel)
        setOwnState(WQL\chkLCSameTime, \bLCSameTime)
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCDevPresent[d]
            If \bLCInclude[d]
              debugMsg(sProcName, "d=" + d + ", \fLCReqdBVLevel(" + d + ")=" + formatLevel(\fLCReqdBVLevel[d]))
              SLD_setMax(WQL\sldLCLevel[d], #SCS_MAXVOLUME_SLD)
              If (\bLCTargetIsF Or \bLCTargetIsI) And (\nLCAudPtr >= 0)
                SLD_setLevel(WQL\sldLCLevel[d], \fLCReqdBVLevel[d], aAud(\nLCAudPtr)\fTrimFactor[d])
              ElseIf (\bLCTargetIsP Or \bLCTargetIsA) And (\nLCSubPtr >= 0)
                SLD_setLevel(WQL\sldLCLevel[d], \fLCReqdBVLevel[d], aSub(\nLCSubPtr)\fSubTrimFactor[d])
              EndIf
              SLD_setMax(WQL\sldLCPan[d], #SCS_MAXPAN_SLD)
              SLD_setValue(WQL\sldLCPan[d], panToSliderValue(\fLCReqdPan[d]))
            EndIf
          EndIf
        Next d
        setComboBoxByData(WQL\cboLCType, \nLCType, 0)
        
      Case #SCS_LC_ACTION_FREQ, #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
        nLCTimeForProgressInfo = \nLCActionTime
        grTempoEtc\nAudTempoEtcCurrAction = \nLCAction
        grTempoEtc\nTempoEtcCurrChangeCode = getChangeCodeForAFAction(grTempoEtc\nAudTempoEtcCurrAction)
        grTempoEtc\fTempoEtcOrigValue = \fLCActionValue
        grTempoEtc\fTempoEtcCurrValue = grTempoEtc\fTempoEtcOrigValue
        
    EndSelect

    If nLCTimeForProgressInfo <= 0
      SLD_setVisible(WQL\sldLCProgress, #False)
      SLD_setMax(WQL\sldLCProgress, 1000)
    Else
      SLD_setMax(WQL\sldLCProgress, nLCTimeForProgressInfo)
      SLD_setVisible(WQL\sldLCProgress, #True)
    EndIf
    SLD_setEnabled(WQL\sldLCProgress, #False)
    gbCallEditUpdateDisplay = #True
    debugMsg(sProcName, "calling editSetDisplayButtonsL")
    editSetDisplayButtonsL()
    
    rWQL\bCallSetOrigReqdDBLevels = #True
    
  EndWith
  
  getInitBVLevelAndPan()
  WQL_displayDev()
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQL_displayDev()
  PROCNAMECS(nEditSubPtr)
  Protected d
  Protected Dim bPopulated(#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB)
  Protected rThisSub.tySub, rTargetSub.tySub, rTargetAud.tyAud
  Protected nDevIndex, nNrOfOutputChans
  Protected bInclude, bVisible, nLabel
  Protected bDisplayThisDev, sThisDev.s
  Protected bRelativeLevel
  Protected nDevMapPtr
  Protected nMaxDev, nDevInnerHeight
  Protected nFirstIncludedDev = -1
  Protected bEnableLevelFields
  Protected bPanVisible
  
  debugMsg(sProcName, #SCS_START)
  
  Select aSub(nEditSubPtr)\nLCAction
    Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
      ; continue
    Default
      ProcedureReturn
  EndSelect
  
  nLabel = 100
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  gbInDisplayDev = #True
  
  debugMsg(sProcName, "calling setLCDevPresentInds(" + getSubLabel(nEditSubPtr) + ")")
  setLCDevPresentInds(nEditSubPtr)
  
  debugMsg(sProcName, "calling populateLCAudioDevs(@aSub(" + getSubLabel(nEditSubPtr) + "))")
  populateLCAudioDevs(@aSub(nEditSubPtr))
  
  rThisSub = aSub(nEditSubPtr)
  
  If rThisSub\nLCAction = #SCS_LC_ACTION_RELATIVE
    bRelativeLevel = #True
  EndIf
  
  nLabel = 200
  debugMsg(sProcName, rThisSub\sSubLabel + ", \bLCTargetIsA=" + strB(rThisSub\bLCTargetIsA) + ", \bLCTargetIsF=" + strB(rThisSub\bLCTargetIsF) +
                      ", \bLCTargetIsI=" + strB(rThisSub\bLCTargetIsI) + ", \bLCTargetIsP=" + strB(rThisSub\bLCTargetIsP) +
                      ", \nLCAudPtr=" + getAudLabel(rThisSub\nLCAudPtr) + ", \nLCSubPtr=" + getSubLabel(rThisSub\nLCSubPtr))
  debugMsg(sProcName, "\bLCSameLevel=" + strB(rThisSub\bLCSameLevel) +  ", \bLCSameTime=" + strB(rThisSub\bLCSameTime))
  
  nMaxDev = 0   ; used for setting innerheight of scrollareagadget, so if no devices selected then set the innerheight for 1 device (equivalent to d = 0)
  
  If (rThisSub\bLCTargetIsF Or rThisSub\bLCTargetIsI) And rThisSub\nLCAudPtr >= 0
    rTargetAud = aAud(rThisSub\nLCAudPtr)
    debugMsg(sProcName, "rTargetAud=" + rTargetAud\sAudLabel + ", \nFileFormat=" + rTargetAud\nFileFormat)
    
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      If rThisSub\bLCDevPresent[d]
        bDisplayThisDev = #False
        Select rTargetAud\nFileFormat
          Case #SCS_FILEFORMAT_AUDIO, #SCS_FILEFORMAT_LIVE_INPUT
            If rTargetAud\sLogicalDev[d]
              debugMsg(sProcName, "rTargetAud\sLogicalDev[" + d + "]=" + rTargetAud\sLogicalDev[d])
              bDisplayThisDev = #True
              nMaxDev = d
              sThisDev = rTargetAud\sLogicalDev[d]
              nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, sThisDev)
              If nDevIndex >= 0
                nNrOfOutputChans = grProd\aAudioLogicalDevs(nDevIndex)\nNrOfOutputChans
              EndIf
            EndIf
          Case #SCS_FILEFORMAT_VIDEO
            If d = 0
              bDisplayThisDev = #True
              nMaxDev = d
              sThisDev = rTargetAud\sLogicalDev[d]
              nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_VIDEO_AUDIO, sThisDev)
            EndIf
        EndSelect
        
        ; debugMsg(sProcName, "d=" + d + ", bDisplayThisDev=" + strB(bDisplayThisDev))
        If bDisplayThisDev
          
          SGT(WQL\lblDevice[d], sThisDev)
          
          bInclude = rThisSub\bLCInclude[d]
          If bInclude
            If nFirstIncludedDev = -1
              nFirstIncludedDev = d
            EndIf
          EndIf
          
          setOwnState(WQL\chkLCInclude[d], bInclude)
          setOwnEnabled(WQL\chkLCInclude[d], #True)
          setVisible(WQL\chkLCInclude[d], #True)
          
          setVisible(WQL\txtLCTrim[d], #True)
          SGT(WQL\txtLCTrim[d], sDBTrimToDisplay(rThisSub\sLCDBTrim[d]))
          
          bEnableLevelFields = bInclude
          If rThisSub\bLCSameLevel
            If d > nFirstIncludedDev
              bEnableLevelFields = #False
            EndIf
          EndIf
          
          If bInclude = #False
            If bRelativeLevel
              rThisSub\fLCReqdBVLevel[d] = grLevels\fPlusZeroBV
              rThisSub\sLCReqdDBLevel[d] = grLevels\sPlusZeroDB
            Else
              rThisSub\fLCReqdBVLevel[d] = rThisSub\fLCInitBVLevel[d]
              rThisSub\sLCReqdDBLevel[d] = convertBVLevelToDBString(rThisSub\fLCReqdBVLevel[d])
            EndIf
            rThisSub\fLCReqdPan[d] = rThisSub\fLCInitPan[d]
          EndIf
          
          If bRelativeLevel
            SLD_setEnabled(WQL\sldLCLevel[d], #False)
          Else
            SLD_setLevel(WQL\sldLCLevel[d], rThisSub\fLCReqdBVLevel[d], rThisSub\fLCTrimFactor[d])
            SLD_setBaseLevel(WQL\sldLCLevel[d], rThisSub\fLCInitBVLevel[d], rThisSub\fLCTrimFactor[d])
            SLD_setEnabled(WQL\sldLCLevel[d], bEnableLevelFields)
          EndIf
          SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(rThisSub\fLCReqdBVLevel[d], bRelativeLevel, #True))
          debugMsg(sProcName, "WQL\txtLCDBLevel[" + d + "]=" + GGT(WQL\txtLCDBLevel[d]))
          setEnabled(WQL\txtLCDBLevel[d], bEnableLevelFields)
          setVisible(WQL\txtLCDBActualLevel[d], #False)
          
          If rTargetAud\bDisplayPan[d]
            bPanVisible = #True
            SLD_setValue(WQL\sldLCPan[d], panToSliderValue(rThisSub\fLCReqdPan[d]))
            SLD_setBaseValue(WQL\sldLCPan[d], panToSliderValue(rThisSub\fLCInitPan[d]))
            SGT(WQL\txtLCPan[d], panSingleToString(rThisSub\fLCReqdPan[d]))
            If nNrOfOutputChans = 2
              SLD_setEnabled(WQL\sldLCPan[d], bEnableLevelFields)
              setEnabled(WQL\txtLCPan[d], bEnableLevelFields)
            Else
              SLD_setEnabled(WQL\sldLCPan[d], #False)
              setEnabled(WQL\btnLCCenter[d], #False)
              setEnabled(WQL\txtLCPan[d], #False)
            EndIf
          Else
            bPanVisible = #False
          EndIf
          SLD_setVisible(WQL\sldLCPan[d], bPanVisible)
          setVisible(WQL\btnLCCenter[d], bPanVisible)
          setVisible(WQL\txtLCPan[d], bPanVisible)

          
          If rThisSub\sLCTime[d]
            SGT(WQL\txtLCTime[d], rThisSub\sLCTime[d])
          ElseIf rThisSub\nLCTime[d] < 0
            SGT(WQL\txtLCTime[d], "")
          Else
            SGT(WQL\txtLCTime[d], timeToStringT(rThisSub\nLCTime[d]))
          EndIf
          If rThisSub\bLCSameTime
            If d = nFirstIncludedDev
              setEnabled(WQL\txtLCTime[d], #True)
            Else
              setEnabled(WQL\txtLCTime[d], #False)
            EndIf
          Else
            setEnabled(WQL\txtLCTime[d], bInclude)
          EndIf
          setTextBoxBackColor(WQL\txtLCTime[d])
          
          If bRelativeLevel = #False
            WQL_fcSldLCLevel(d)
          EndIf
          WQL_fcSldLCPan(d)
          
          bPopulated(d) = #True
          
        EndIf ; EndIf bDisplayThisDev
      EndIf   ; EndIf rThisSub\bLCDevPresent[d]
    Next d
    
  EndIf
  
  nLabel = 300
  If (rThisSub\bLCTargetIsP) And (rThisSub\nLCSubPtr >= 0)
    rTargetSub = aSub(rThisSub\nLCSubPtr)
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      bDisplayThisDev = #False
      If rTargetSub\sPLLogicalDev[d]
        bDisplayThisDev = #True
        nMaxDev = d
        sThisDev = rTargetSub\sPLLogicalDev[d]
        nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, sThisDev)
        CheckSubInRange(nDevIndex, grProd\nMaxAudioLogicalDev, "grProd\aAudioLogicalDevs(), rThisSub\nLCSubPtr=" + getSubLabel(rThisSub\nLCSubPtr) + ", d=" + d + ", sThisDev=" + sThisDev)
        nNrOfOutputChans = grProd\aAudioLogicalDevs(nDevIndex)\nNrOfOutputChans
      EndIf
      If bDisplayThisDev
        
        SGT(WQL\lblDevice[d], sThisDev)
        
        bInclude = rThisSub\bLCInclude[d]
        
        setOwnState(WQL\chkLCInclude[d], bInclude)
        setOwnEnabled(WQL\chkLCInclude[d], #True)
        setVisible(WQL\chkLCInclude[d], #True)
        
        setVisible(WQL\txtLCTrim[d], #True)
        SGT(WQL\txtLCTrim[d], sDBTrimToDisplay(rTargetSub\sPLDBTrim[d]))
        
        If bRelativeLevel
          SLD_setEnabled(WQL\sldLCLevel[d], #False)
        Else
          SLD_setEnabled(WQL\sldLCLevel[d], bInclude)
          SLD_setMax(WQL\sldLCLevel[d], #SCS_MAXVOLUME_SLD)
          SLD_setLevel(WQL\sldLCLevel[d], rThisSub\fLCReqdBVLevel[d], rThisSub\fLCTrimFactor[d])
          SLD_setBaseLevel(WQL\sldLCLevel[d], #SCS_SLD_BASE_EQUALS_CURRENT)
        EndIf
        SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(rThisSub\fLCReqdBVLevel[d], #False, #True))
        ; debugMsg(sProcName, "WQL\txtLCDBLevel[" + d + "]=" + GGT(WQL\txtLCDBLevel[d]))
        setEnabled(WQL\txtLCDBLevel[d], bInclude)
        
        SLD_setMax(WQL\sldLCPan[d], #SCS_MAXPAN_SLD)
        SLD_setValue(WQL\sldLCPan[d], panToSliderValue(rThisSub\fLCReqdPan[d]))
        SLD_setBaseValue(WQL\sldLCPan[d], #SCS_SLD_BASE_EQUALS_CURRENT)
        SGT(WQL\txtLCPan[d], panSingleToString(rThisSub\fLCReqdPan[d]))
        If nNrOfOutputChans = 2
          SLD_setEnabled(WQL\sldLCPan[d], bInclude)
          setEnabled(WQL\txtLCPan[d], bInclude)
        Else
          SLD_setEnabled(WQL\sldLCPan[d], #False)
          setEnabled(WQL\btnLCCenter[d], #False)
          setEnabled(WQL\txtLCPan[d], #False)
        EndIf
        
        If rThisSub\nLCTime[d] < 0
          SGT(WQL\txtLCTime[d], "")
        Else
          SGT(WQL\txtLCTime[d], timeToStringT(rThisSub\nLCTime[d]))
        EndIf
        setEnabled(WQL\txtLCTime[d], bInclude)
        
        If bRelativeLevel = #False
          WQL_fcSldLCLevel(d)
        EndIf
        WQL_fcSldLCPan(d)
        
        bPopulated(d) = #True
        
      EndIf
    Next d
    
  ElseIf (rThisSub\bLCTargetIsA) And (rThisSub\nLCSubPtr >= 0)
    rTargetSub = aSub(rThisSub\nLCSubPtr)
    d = 0
    bDisplayThisDev = #False
    If rTargetSub\sVidAudLogicalDev
      bDisplayThisDev = #True
      nMaxDev = d
      sThisDev = rTargetSub\sVidAudLogicalDev
      nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_VIDEO_AUDIO, sThisDev)
    EndIf
    If bDisplayThisDev
      
      SGT(WQL\lblDevice[d], sThisDev)
      
      bInclude = rThisSub\bLCInclude[d]
      
      setOwnState(WQL\chkLCInclude[d], bInclude)
      setOwnEnabled(WQL\chkLCInclude[d], #True)
      setVisible(WQL\chkLCInclude[d], #True)
      
      setVisible(WQL\txtLCTrim[d], #True)
      SGT(WQL\txtLCTrim[d], sDBTrimToDisplay(rTargetSub\sPLDBTrim[d]))
      
      If bRelativeLevel
        SLD_setEnabled(WQL\sldLCLevel[d], #False)
      Else
        SLD_setEnabled(WQL\sldLCLevel[d], bInclude)
        SLD_setMax(WQL\sldLCLevel[d], #SCS_MAXVOLUME_SLD)
        SLD_setLevel(WQL\sldLCLevel[d], rThisSub\fLCReqdBVLevel[d], rThisSub\fLCTrimFactor[d])
        SLD_setBaseLevel(WQL\sldLCLevel[d], #SCS_SLD_BASE_EQUALS_CURRENT)
      EndIf
      SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(rThisSub\fLCReqdBVLevel[d], #False, #True))
      ; debugMsg(sProcName, "WQL\txtLCDBLevel[" + d + "]=" + GGT(WQL\txtLCDBLevel[d]))
      setEnabled(WQL\txtLCDBLevel[d], bInclude)
      
      SLD_setMax(WQL\sldLCPan[d], #SCS_MAXPAN_SLD)
      SLD_setValue(WQL\sldLCPan[d], panToSliderValue(rThisSub\fLCReqdPan[d]))
      SLD_setBaseValue(WQL\sldLCPan[d], #SCS_SLD_BASE_EQUALS_CURRENT)
      SGT(WQL\txtLCPan[d], panSingleToString(rThisSub\fLCReqdPan[d]))
      SLD_setEnabled(WQL\sldLCPan[d], bInclude)
      setEnabled(WQL\txtLCPan[d], bInclude)
      
      If rThisSub\nLCTime[d] < 0
        SGT(WQL\txtLCTime[d], "")
      Else
        SGT(WQL\txtLCTime[d], timeToStringT(rThisSub\nLCTime[d]))
      EndIf
      setEnabled(WQL\txtLCTime[d], bInclude)
      
      If bRelativeLevel = #False
        WQL_fcSldLCLevel(d)
      EndIf
      WQL_fcSldLCPan(d)
      
      bPopulated(d) = #True
      
    EndIf
  EndIf
  
  nLabel = 400
  nDevInnerHeight = (nMaxDev + 1) * 22
  SetGadgetAttribute(WQL\scaLCDevs, #PB_ScrollArea_InnerHeight, nDevInnerHeight)
  debugMsg(sProcName, "nMaxDev=" + nMaxDev + ", nDevInnerHeight=" + nDevInnerHeight)
  
  nLabel = 401
  For d = 0 To grLicInfo\nMaxAudDevPerAud
    nLabel = 402
    ; debugMsg(sProcName, "nLabel=" + nLabel + ", bPopulated(" + d + ")=" + strB(bPopulated(d)))
    SGT(WQL\lblDevNo[d], Str(d+1))
    If bPopulated(d)
      bVisible = #True
      setVisible(WQL\lblDevNo[d], #True)
    Else
      bVisible = #False
      setVisible(WQL\lblDevNo[d], #False)
      SGT(WQL\lblDevice[d], "")
      setOwnEnabled(WQL\chkLCInclude[d], #False)
      setVisible(WQL\chkLCInclude[d], #False)
      setVisible(WQL\txtLCTrim[d], #False)
      SLD_setLevel(WQL\sldLCLevel[d], #SCS_MINVOLUME_SINGLE)
      SLD_setBaseLevel(WQL\sldLCLevel[d], #SCS_SLD_NO_BASE)
      SLD_setValue(WQL\sldLCPan[d], #SCS_PANCENTRE_SLD)
      SLD_setBaseValue(WQL\sldLCPan[d], #SCS_SLD_NO_BASE)
      SGT(WQL\txtLCTime[d], "")
      SLD_setEnabled(WQL\sldLCLevel[d], #False)
      setEnabled(WQL\txtLCDBLevel[d], #False)
      setEnabled(WQL\txtLCPan[d], #False)
      SLD_setEnabled(WQL\sldLCPan[d], #False)
      setEnabled(WQL\txtLCPan[d], #False)
      setEnabled(WQL\txtLCTime[d], #False)
      ; set max properties in slider to cause slider to be formatted
      SLD_setMax(WQL\sldLCLevel[d], #SCS_MAXVOLUME_SLD)
      SLD_setMax(WQL\sldLCPan[d], #SCS_MAXPAN_SLD)
      WQL_fcSldLCLevel(d)
      WQL_fcSldLCPan(d)
    EndIf
    
    nLabel = 420
    setTextBoxBackColor(WQL\txtLCDBLevel[d])
    setTextBoxBackColor(WQL\txtLCPan[d])
    setTextBoxBackColor(WQL\txtLCTime[d])
    
    setVisible(WQL\chkLCInclude[d], bVisible)
    If bRelativeLevel
      SLD_setVisible(WQL\sldLCLevel[d], #False)
    Else
      SLD_setVisible(WQL\sldLCLevel[d], bVisible)
    EndIf
    setVisible(WQL\txtLCDBLevel[d], bVisible)
    
    bPanVisible = #True
    If rTargetAud\bAudTypeF And rTargetAud\bDisplayPan[d] = #False
      bPanVisible = #False
    EndIf
    SLD_setVisible(WQL\sldLCPan[d], bPanVisible)
    setVisible(WQL\txtLCPan[d], bPanVisible)
    setVisible(WQL\btnLCCenter[d], bPanVisible)
    
    setVisible(WQL\txtLCTime[d], bVisible) ; Corrected 7Mar2025 11.10.ac (was incorrectly set to bPanVisible in SCS 11.10.6)
    
  Next d
  
  rWQL\bCallSetOrigReqdDBLevels = #True
  
  nLabel = 500
  gbInDisplayDev = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_btnLCCenter_Click(Index)
  PROCNAMEC()
  
  WQL_changeLCPan(3, Index)
  SAG(-1)
EndProcedure

Procedure WQL_cboLCAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected d, bChanged
  Protected nIndex
  Protected nOldLCAction, nNewLCAction
  Protected fInitDBLevel.f, fReqdDBLevel.f, fDBChange.f, fNewValue.f
  Protected bRelativeLevel
  Protected u
  Protected nLCCuePtr, nLCSubPtr, nLCAudPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If gbInDisplaySub
    debugMsg(sProcName, "exiting because gbInDisplaySub=" + strB(gbInDisplaySub))
    ProcedureReturn
  EndIf
  
  nOldLCAction = aSub(nEditSubPtr)\nLCAction
  nNewLCAction = getCurrentItemData(WQL\cboLCAction)
  If nNewLCAction = nOldLCAction
    debugMsg(sProcName, "exiting because nNewLCAction = nOldLCAction (" + decodeLCAction(nNewLCAction) + ")")
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)
    nLCCuePtr = \nLCCuePtr
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
    
    u = preChangeSubL(nOldLCAction, GGT(WQL\lblLCAction))
    
    If (\bLCTargetIsF Or \bLCTargetIsI)
      If nLCAudPtr >= 0
        Select nNewLCAction
          Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If \bLCDevPresent[d]
                bChanged = #False
                nIndex = d
                If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO And nIndex = 0) Or (aAud(nLCAudPtr)\nFileFormat <> #SCS_FILEFORMAT_VIDEO And aAud(nLCAudPtr)\nBassChannel[d] <> 0)
                  If nNewLCAction = #SCS_LC_ACTION_RELATIVE
                    ; convert absolute to relative
                    bRelativeLevel = #True
                    fInitDBLevel = convertBVLevelToDBLevel(\fLCInitBVLevel[d])
                    fReqdDBLevel = convertBVLevelToDBLevel(\fLCReqdBVLevel[d])
                    fDBChange = fReqdDBLevel - fInitDBLevel
                    fNewValue = convertDBLevelToBVLevel(fDBChange)
                  ElseIf nNewLCAction = #SCS_LC_ACTION_ABSOLUTE
                    ; convert relative to absolute
                    bRelativeLevel = #False
                    fInitDBLevel = convertBVLevelToDBLevel(\fLCInitBVLevel[d])
                    fReqdDBLevel = convertBVLevelToDBLevel(\fLCReqdBVLevel[d])
                    fDBChange = fReqdDBLevel + fInitDBLevel
                    fNewValue = convertDBLevelToBVLevel(fDBChange)
                  EndIf
                  ; debugMsg0(sProcName, "fInitDBLevel=" + StrF(fInitDBLevel,1) + ", fReqdDBLevel=" + StrF(fReqdDBLevel,1) + ", fDBChange=" + StrF(fDBChange,1) + ", fNewValue=" + formatLevel(fNewValue))
                  
                  If \fLCReqdBVLevel[d] <> fNewValue
                    ; debugMsg0(sProcName, "changing \fLCReqdBVLevel[" + d + "] from " + formatLevel(\fLCReqdBVLevel[d]) + " to " + formatLevel(fNewValue))
                    \fLCReqdBVLevel[d] = fNewValue
                    \sLCReqdDBLevel[d] = convertBVLevelToDBString(\fLCReqdBVLevel[d], bRelativeLevel)
                    ; debugMsg0(sProcName, "\fLCReqdBVLevel[" + d + "]=" + formatLevel(\fLCReqdBVLevel[d]) + ", \sLCReqdDBLevel[" + d + "]=" + \sLCReqdDBLevel[d])
                    bChanged = #True
                    If nNewLCAction = #SCS_LC_ACTION_ABSOLUTE
                      If nIndex >= 0
                        SLD_setLevel(WQL\sldLCLevel[nIndex], \fLCReqdBVLevel[d], aAud(\nLCAudPtr)\fTrimFactor[d])
                        WQL_fcSldLCLevel(nIndex)
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf ; EndIf \bLCDevPresent[d]
            Next d
            
        EndSelect
      EndIf ; EndIf nLCAudPtr >= 0
      
    ElseIf \bLCTargetIsA Or \bLCTargetIsP
      If nLCSubPtr >= 0
        For d = 0 To grLicInfo\nMaxAudDevPerSub
          If \bLCDevPresent[d]
            nIndex = d
            If aSub(nLCSubPtr)\nPLBassDevice[d] >= 0
              If nOldLCAction = #SCS_LC_ACTION_ABSOLUTE And nNewLCAction = #SCS_LC_ACTION_RELATIVE
                ; convert absolute to relative
                bRelativeLevel = #True
                fInitDBLevel = convertBVLevelToDBLevel(\fLCInitBVLevel[d])
                fReqdDBLevel = convertBVLevelToDBLevel(\fLCReqdBVLevel[d])
                fDBChange = fReqdDBLevel - fInitDBLevel
                fNewValue = convertDBLevelToBVLevel(fDBChange)
              ElseIf nOldLCAction = #SCS_LC_ACTION_RELATIVE And nNewLCAction = #SCS_LC_ACTION_ABSOLUTE
                ; convert relative to absolute
                bRelativeLevel = #False
                fInitDBLevel = convertBVLevelToDBLevel(\fLCInitBVLevel[d])
                fReqdDBLevel = convertBVLevelToDBLevel(\fLCReqdBVLevel[d])
                fDBChange = fReqdDBLevel + fInitDBLevel
                fNewValue = convertDBLevelToBVLevel(fDBChange)
              EndIf
              debugMsg(sProcName, "bChanged=" + strB(bChanged) + ", fInitDBLevel=" + StrF(fInitDBLevel,1) + ", fReqdDBLevel=" + StrF(fReqdDBLevel,1) + ", fDBChange=" + StrF(fDBChange,1) + ", fNewValue=" + formatLevel(fNewValue))
              
              If \fLCReqdBVLevel[d] <> fNewValue
                debugMsg(sProcName, "changing \fLCReqdBVLevel[" + d + "] from " + formatLevel(\fLCReqdBVLevel[d]) + " to " + formatLevel(fNewValue))
                \fLCReqdBVLevel[d] = fNewValue
                \sLCReqdDBLevel[d] = convertBVLevelToDBString(\fLCReqdBVLevel[d], bRelativeLevel)
                debugMsg(sProcName, "\fLCReqdBVLevel[" + d + "]=" + formatLevel(\fLCReqdBVLevel[d]) + ", \sLCReqdDBLevel[" + d + "]=" + \sLCReqdDBLevel[d])
                bChanged = #True
                If nNewLCAction = #SCS_LC_ACTION_ABSOLUTE
                  If nIndex >= 0
                    SLD_setLevel(WQL\sldLCLevel[nIndex], \fLCReqdBVLevel[d], aSub(\nLCSubPtr)\fSubTrimFactor[d])
                    WQL_fcSldLCLevel(nIndex)
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
        Next d
      EndIf
    EndIf
    
    \nLCAction = nNewLCAction
    Select \nLCAction
      Case #SCS_LC_ACTION_FREQ, #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
        \bSubTypeHasDevs = #False
        grTempoEtc\nAudTempoEtcCurrAction = \nLCAction
        grTempoEtc\nTempoEtcCurrChangeCode = getChangeCodeForLCAction(\nLCAction)
        \fLCActionValue = getDefaultValueForChangeCode(grTempoEtc\nTempoEtcCurrChangeCode)
        If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
          If \nLCAction <> #SCS_LC_ACTION_FREQ
            checkUsingPlaybackRateChangeOnly(#True)
          EndIf
        EndIf
      Default
        \bSubTypeHasDevs = #True
    EndSelect
    WQL_fcLCAction()
    setDefaultSubDescr()
    setDefaultCueDescr()
    WQL_fcLCSameLevel()
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
    postChangeSubL(u, nNewLCAction)
    
    rWQL\bCallSetOrigReqdDBLevels = #True
    gnPrevLCAction = \nLCAction
    
  EndWith
  
  editUpdateDisplay()
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_cboLCCue_Click()
  PROCNAMECS(nEditSubPtr)
  Protected d, d2, i, j
  Protected sTargetCue.s, bExitFor
  Protected bLCCueChanged
  Protected u
  Protected nLCCuePtr = -1, nLCSubPtr = -1, nLCAudPtr = -1
  Protected rPrevSub.tySub, sPrevTargetSubType.s
  Protected sLogicalDev.s
  Protected bRetainDevInfoWherePossible = #True
  ; this procedure modifed 9Nov2017 11.7.0aw to handle the following:
  ; In versions prior to 11.7.0aw, if the user selected a different target cue from WQL\cboLCCue then SCS would refresh all the device levels and pan settings, etc, based
  ; on the derived settings for that different cue. However, C.Peters requested a change primarly to handle situations where an LCQ is copied and pasted and then the
  ; target cue is changed BUT the LCQ's device level and pan settings should be retained where possible. That is really the whole purpose of copying and pasting an LCQ
  ; rather than just creating a new LCQ.
  ; To implement this request, the old (pre-11.7.0aw) code is still executed, but before doing so this procedure takes a copy of the LCQ (in rPrevSub) and then
  ; at the end of the procedure checks to see which devices in rPrevSub exist in the new sub and reinstates the 'include', 'level', 'pan' and 'duration' for each
  ; of these devices.
  ; HOWEVER, this final process is not executed if bRetainDevInfoWherePossible has been set to #False, which will occur if the new target cue is of a different type
  ; or if the previous target cue was blank (ie this is a new LCQ, not an existing or copied LCQ)
  
  debugMsg(sProcName, #SCS_START)
  
  rPrevSub = aSub(nEditSubPtr)
  If rPrevSub\nLCSubPtr >= 0
    sPrevTargetSubType = aSub(rPrevSub\nLCSubPtr)\sSubType
  EndIf
  
  sTargetCue = GetGadgetText(WQL\cboLCCue)
  If sTargetCue <> #SCS_BLANK_CBO_ENTRY
    bExitFor = #False
    For i = 1 To nEditCuePtr
      If bExitFor
        Break
      EndIf
      With aCue(i)
        j = \nFirstSubIndex
        While (j >= 0) And (bExitFor = #False)
          If sTargetCue = buildLCCueForCBO(j)
            nLCCuePtr = i
            nLCSubPtr = j
            If aSub(j)\bSubTypeHasAuds
              nLCAudPtr = aSub(j)\nFirstPlayIndex
              If nLCAudPtr = -1
                nLCAudPtr = aSub(j)\nFirstAudIndex
              EndIf
            Else
              nLCAudPtr = -1
            EndIf
            bExitFor = #True
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndWith
    Next i
  EndIf
  debugMsg(sProcName, "sTargetCue=" + sTargetCue + ", nLCCuePtr=" + getCueLabel(nLCCuePtr) + ", nLCSubPtr=" + getSubLabel(nLCSubPtr) + ", nLCAudPtr=" + getAudLabel(nLCAudPtr))
  
  With aSub(nEditSubPtr)
    If (\nLCCuePtr <> nLCCuePtr) Or (\nLCSubPtr <> nLCSubPtr)
      u = preChangeSubL(#True, GetGadgetText(WQL\lblCueToAdjust))
      bLCCueChanged = #True
    EndIf
    
    \nLCCuePtr = nLCCuePtr
    \nLCSubPtr = nLCSubPtr
    debugMsg(sProcName, "setting aSub(" + getSubLabel(nEditSubPtr) + ")\nLCAudPtr=" + getAudLabel(nLCAudPtr) + ", was " + getAudLabel(\nLCAudPtr))
    \nLCAudPtr = nLCAudPtr
    If nLCSubPtr >= 0
      If aSub(nLCSubPtr)\sSubType <> sPrevTargetSubType
        bRetainDevInfoWherePossible = #False
      EndIf
      \sLCCue = aSub(nLCSubPtr)\sCue
      \nLCSubNo = aSub(nLCSubPtr)\nSubNo
      \nLCSubRef = aSub(nLCSubPtr)\nSubRef
      \bLCTargetIsA = aSub(nLCSubPtr)\bSubTypeA
      \bLCTargetIsF = aSub(nLCSubPtr)\bSubTypeF
      \bLCTargetIsI = aSub(nLCSubPtr)\bSubTypeI
      \bLCTargetIsP = aSub(nLCSubPtr)\bSubTypeP
      ; debugMsg(sProcName, "calling setLCDevPresentInds(" + getSubLabel(nEditSubPtr) + ")")
      setLCDevPresentInds(nEditSubPtr)
      ; debugMsg(sProcName, "calling setDerivedSubFields(" + getSubLabel(nEditSubPtr) + ", #True, #True)")
      setDerivedSubFields(nEditSubPtr, #True)
    Else
      bRetainDevInfoWherePossible = #False
      \sLCCue = grSubDef\sLCCue
      \nLCSubNo = grSubDef\nLCSubNo
      \nLCSubRef = grSubDef\nLCSubRef
      \bLCTargetIsA = grSubDef\bSubTypeA
      \bLCTargetIsF = grSubDef\bSubTypeF
      \bLCTargetIsI = grSubDef\bSubTypeI
      \bLCTargetIsP = grSubDef\bSubTypeP
      \nLCAction = grSubDef\nLCAction
      debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nLCAction=" + decodeLCAction(\nLCAction))
    EndIf
    
    If bLCCueChanged
      ; ensure \nLCAction is valid for the target
      Select \nLCAction
        Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
          ; always valid
        Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
          If \bLCTargetIsF = #False Or grLicInfo\bTempoAndPitchAvailable = #False
            ; current action (tempo, pitch or frequency) is not valid for this target, so set the default, which is 'absolute'
            \nLCAction = grSubDef\nLCAction
            debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nLCAction=" + decodeLCAction(\nLCAction))
          EndIf
      EndSelect
      
      Select \nLCAction
        Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
          If (\bLCTargetIsF Or \bLCTargetIsI) And (nLCAudPtr >= 0)
            For d = 0 To grLicInfo\nMaxAudDevPerSub
              \sLCReqdDBLevel[d] = aAud(nLCAudPtr)\sDBLevel[d]
              \fLCReqdBVLevel[d] = aAud(nLCAudPtr)\fBVLevel[d]
              ; debugMsg(sProcName, "\sLCReqdDBLevel[" + d + "]=" + \sLCReqdDBLevel[d] + ", \fLCReqdBVLevel[" + d + "]=" + StrF(\fLCReqdBVLevel[d],3))
              \fLCReqdPan[d] = aAud(nLCAudPtr)\fPan[d]
            Next d
          ElseIf (\bLCTargetIsA Or \bLCTargetIsP) And (nLCSubPtr >= 0)
            For d = 0 To grLicInfo\nMaxAudDevPerSub
              \sLCReqdDBLevel[d] = aSub(nLCSubPtr)\sPLMastDBLevel[d]
              \fLCReqdBVLevel[d] = aSub(nLCSubPtr)\fSubMastBVLevel[d]
              ; debugMsg(sProcName, "\sLCReqdDBLevel[" + d + "]=" + \sLCReqdDBLevel[d] + ", \fLCReqdBVLevel[" + d + "]=" + StrF(\fLCReqdBVLevel[d],3))
              \fLCReqdPan[d] = aSub(nLCSubPtr)\fPLPan[d]
            Next d
          EndIf
        Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
          grTempoEtc\nAudTempoEtcCurrAction = \nLCAction
          grTempoEtc\nTempoEtcCurrChangeCode = getChangeCodeForLCAction(\nLCAction)
          \fLCActionValue = getDefaultValueForChangeCode(grTempoEtc\nTempoEtcCurrChangeCode)
      EndSelect
    EndIf ; EndIf bLCCueChanged
    
  EndWith
  
  If nLCAudPtr >= 0
    With aAud(nLCAudPtr)
      If \nFileState <> #SCS_FILESTATE_OPEN
        openMediaFile(nLCAudPtr)
        setSyncPChanListForAud(nLCAudPtr)
      EndIf
    EndWith
  EndIf
  
  getInitBVLevelAndPan()
  If gbInDisplaySub = #False
    With aSub(nEditSubPtr)
      Select \nLCAction
        Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
          For d = 0 To grLicInfo\nMaxAudDevPerSub
            If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
              \fLCReqdBVLevel[d] = \fLCInitBVLevel[d]
              \sLCReqdDBLevel[d] = convertBVLevelToDBString(\fLCReqdBVLevel[d])
            Else
              \sLCReqdDBLevel[d] = grLevels\sPlusZeroDB
              \fLCReqdBVLevel[d] = grLevels\fPlusZeroBV
            EndIf
            \fLCReqdPan[d] = \fLCInitPan[d]
          Next d
      EndSelect
    EndWith
  EndIf
  
  If bRetainDevInfoWherePossible
    With aSub(nEditSubPtr)
      Select \nLCAction
        Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
          populateLCAudioDevs(@rPrevSub, #True)
          populateLCAudioDevs(@aSub(nEditSubPtr), #True)
          For d = 0 To grLicInfo\nMaxAudDevPerSub
            sLogicalDev = rPrevSub\sLCLogicalDev[d]
            For d2 = 0 To grLicInfo\nMaxAudDevPerSub
              If \sLCLogicalDev[d2] = sLogicalDev
                ; found this device [d2] in the previous version of this sub (at [d]), so copy level and pan from that version to the updated version
                \bLCInclude[d2] = rPrevSub\bLCInclude[d]
                \fLCReqdBVLevel[d2] = rPrevSub\fLCReqdBVLevel[d]
                \sLCReqdDBLevel[d2] = rPrevSub\sLCReqdDBLevel[d]
                \fLCReqdPan[d2] = rPrevSub\fLCReqdPan[d]
                \nLCTime[d2] = rPrevSub\nLCTime[d]
                Break
              EndIf
            Next d2
          Next d
      EndSelect
    EndWith
  EndIf
  
  WQL_displayDev()
  
  If gbInDisplaySub = #False
    editSetDisplayButtonsL()
  EndIf
  
  With aSub(nEditSubPtr)
    ; debugMsg(sProcName, \sSubLabel + ", (c) \fLCReqdBVLevel[0]=" + formatLevel(\fLCReqdBVLevel[0]))    ; copied from setInitCueStates
    If \nLCSubPtr < 0
      \nSubState = #SCS_CUE_NOT_LOADED
    ElseIf (aSub(\nLCSubPtr)\nSubState = #SCS_CUE_NOT_LOADED) And
           ((grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND) Or (grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND And aCue(\nCueIndex)\bNonLinearCue = #True))
      \nSubState = #SCS_CUE_NOT_LOADED
    Else
      \nSubState = #SCS_CUE_READY
    EndIf
    setCueState(\nCueIndex)
    
    setDefaultSubDescr()
    setDefaultCueDescr()
    
    WQL_populateCboLCAction()
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nLCAction=" + \nLCAction + " (" + decodeLCAction(\nLCAction) + ")")
    setGadgetItemByData(WQL\cboLCAction, \nLCAction, 0)
    Select \nLCAction
      Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
        WQL_fcLCSameLevel()
        rWQL\bCallSetOrigReqdDBLevels = #True
    EndSelect
    WQL_fcLCAction() ; causes sample rate info, etc to be refreshed if necessary
  EndWith
  
  If bLCCueChanged
    postChangeSubL(u, #False)
  EndIf
  
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_cboLCType_Click()
  PROCNAMEC()
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLCType, GGT(WQL\lblLCType))
      \nLCType = getCurrentItemData(WQL\cboLCType, #SCS_FADE_STD)
      WQL_fcLCSameLevel()
      postChangeSubL(u, \nLCType)
    EndWith
  EndIf
EndProcedure

Procedure WQL_chkLCInclude_Click(Index)
  PROCNAMECS(nEditSubPtr)
  Protected bLCInclude, d2
  Protected u
  Protected sZeroDB.s, fZeroDB.f
  Protected nLCCuePtr, nLCSubPtr, nLCAudPtr
  
  With aSub(nEditSubPtr)
    nLCCuePtr = \nLCCuePtr
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
    
    bLCInclude = getOwnState(WQL\chkLCInclude[Index])
    debugMsg(sProcName, "Index=" + Index + ", bLCInclude=" + strB(bLCInclude))
    
    If bLCInclude <> \bLCInclude[Index]
      u = preChangeSubL(\bLCInclude[Index], GGT(WQL\lblLCInclude), -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \bLCInclude[Index] = bLCInclude
      
      If \nLCAction = #SCS_LC_ACTION_ABSOLUTE  ; Absolute
        
        If bLCInclude = #False
          
          If aSub(nLCSubPtr)\bSubTypeF
            If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO And aAud(nLCAudPtr)\nBassChannel[Index] <> 0)
              If \fLCReqdBVLevel[Index] <> \fLCInitBVLevel[Index] Or \fLCReqdPan[Index] <> \fLCInitPan[Index]
                \fLCReqdBVLevel[Index] = \fLCInitBVLevel[Index]
                \sLCReqdDBLevel[Index] = convertBVLevelToDBString(\fLCReqdBVLevel[Index])
                \fLCReqdPan[Index] = \fLCInitPan[Index]
              EndIf
            EndIf
            
          ElseIf aSub(nLCSubPtr)\bSubTypeAorP
            If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO And Index = 0) Or (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO And aAud(nLCAudPtr)\nBassChannel[Index] <> 0)
              If aSub(nLCSubPtr)\nPLBassDevice >= 0
                If \fLCReqdBVLevel[Index] <> \fLCInitBVLevel[Index] Or \fLCReqdPan[Index] <> \fLCInitPan[Index]
                  \fLCReqdBVLevel[Index] = \fLCInitBVLevel[Index]
                  \sLCReqdDBLevel[Index] = convertBVLevelToDBString(\fLCReqdBVLevel[Index])
                  \fLCReqdPan[Index] = \fLCInitPan[Index]
                EndIf
              EndIf
              
            EndIf
            debugMsg(sProcName, "(abs) \fLCReqdBVLevel[" + Index + "]=" + StrF(\fLCReqdBVLevel[Index],4) + ", \sLCReqdDBLevel[" + Index + "]=" + \sLCReqdDBLevel[Index])
          EndIf
        EndIf
        
      Else  ; Relative
        
        If bLCInclude = #False
          
          If aSub(nLCSubPtr)\bSubTypeF
            If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO And aAud(nLCAudPtr)\nBassChannel[Index] <> 0)
              If \fLCReqdBVLevel[Index] <> grLevels\fPlusZeroBV Or \fLCReqdPan[Index] <> \fLCInitPan[Index]
                \sLCReqdDBLevel[Index] = grLevels\sPlusZeroDB
                \fLCReqdBVLevel[Index] = grLevels\fPlusZeroBV
                \fLCReqdPan[Index] = \fLCInitPan[Index]
              EndIf
            EndIf
            
          ElseIf aSub(nLCSubPtr)\bSubTypeAorP
            If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO And Index = 0) Or (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO And aAud(nLCAudPtr)\nBassChannel[Index] <> 0)
              If aSub(nLCSubPtr)\nPLBassDevice >= 0
                If \fLCReqdBVLevel[Index] <> grLevels\fPlusZeroBV Or \fLCReqdPan[Index] <> \fLCInitPan[Index]
                  \sLCReqdDBLevel[Index] = grLevels\sPlusZeroDB
                  \fLCReqdBVLevel[Index] = grLevels\fPlusZeroBV
                  \fLCReqdPan[Index] = \fLCInitPan[Index]
                EndIf
              EndIf
              
            EndIf
          EndIf
          debugMsg(sProcName, "(rel) \fLCReqdBVLevel[" + Index + "]=" + StrF(\fLCReqdBVLevel[Index],4) + ", \sLCReqdDBLevel[" + Index + "]=" + \sLCReqdDBLevel[Index])
        EndIf
        
      EndIf
      
      setDerivedSubFields(nEditSubPtr, #True)
      WQL_displayDev()
      
      If SLD_getMax(WQL\sldLCProgress) <> \nLCTimeMax
        SLD_setMax(WQL\sldLCProgress, \nLCTimeMax)
      EndIf
      If \nLCTimeMax <= 0
        SLD_setVisible(WQL\sldLCProgress, #False)
      Else
        SLD_setVisible(WQL\sldLCProgress, #True)
      EndIf
      SLD_setEnabled(WQL\sldLCProgress, #False)
      
      postChangeSubL(u, \bLCInclude[Index], -5, Index)
    EndIf
  EndWith
  
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  
  SAG(-1)
  
EndProcedure

Procedure WQL_chkLCSameTime_Click()
  PROCNAMECS(nEditSubPtr)
  Protected d
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bLCSameTime, getOwnText(WQL\chkLCSameTime))
    \bLCSameTime = getOwnState(WQL\chkLCSameTime)
    debugMsg(sProcName, "\bLCSameTime=" + StrB(\bLCSameTime))
    
    WQL_fcLCSameTime()
    
    postChangeSubL(u, \bLCSameTime)
  EndWith
  
  gbCallEditUpdateDisplay = #True
  editSetDisplayButtonsL()
  
  SAG(-1)
  
EndProcedure

Procedure WQL_chkLCSameLevel_Click()
  PROCNAMECS(nEditSubPtr)
  Protected d
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bLCSameLevel, getOwnText(WQL\chkLCSameLevel))
    \bLCSameLevel = getOwnState(WQL\chkLCSameLevel)
    debugMsg(sProcName, "\bLCSameLevel=" + StrB(\bLCSameLevel))
    
    WQL_fcLCSameLevel()
    
    postChangeSubL(u, \bLCSameLevel)
  EndWith
  
  gbCallEditUpdateDisplay = #True
  editSetDisplayButtonsL()
  
  SAG(-1)
  
EndProcedure

Procedure WQL_btnLCReset_Click()
  PROCNAMEC()
  Protected d, bChanged
  Protected u
  Protected nLCCuePtr, nLCSubPtr, nLCAudPtr

  With aSub(nEditSubPtr)
    nLCCuePtr = \nLCCuePtr
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
    
    u = preChangeSubL(bChanged, GetGadgetText(WQL\btnLCReset))
    
    If (\bLCTargetIsF Or \bLCTargetIsI) ; \bLCTargetIsF or \bLCTargetIsI
      If nLCAudPtr >= 0
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCDevPresent[d]
            If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO And aAud(nLCAudPtr)\nBassChannel[d] <> 0)
              If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                If \fLCReqdBVLevel[d] <> \fLCInitBVLevel[d]
                  bChanged = #True
                  \fLCReqdBVLevel[d] = \fLCInitBVLevel[d]
                  SLD_setLevel(WQL\sldLCLevel[d], \fLCReqdBVLevel[d], aAud(\nLCAudPtr)\fTrimFactor[d])
                  WQL_fcSldLCLevel(d)
                EndIf
              ElseIf \nLCAction = #SCS_LC_ACTION_RELATIVE
                If \fLCReqdBVLevel[d] <> grLevels\fPlusZeroBV
                  bChanged = #True
                  \sLCReqdDBLevel[d] = grLevels\sPlusZeroDB    ; ie no change
                  \fLCReqdBVLevel[d] = grLevels\fPlusZeroBV
                  SGT(WQL\txtLCDBLevel[d], grLevels\sPlusZeroDB)
                  debugMsg(sProcName, "WQL\txtLCDBLevel[" + d + "]=" + GGT(WQL\txtLCDBLevel[d]))
                EndIf
              EndIf
              Select \nLCAction
                Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
                  If \fLCReqdPan[d] <> \fLCInitPan[d]
                    bChanged = #True
                    \fLCReqdPan[d] = \fLCInitPan[d]
                    SLD_setValue(WQL\sldLCPan[d], panToSliderValue(\fLCReqdPan[d]))
                    WQL_fcSldLCPan(d)
                  EndIf
              EndSelect
            EndIf
          EndIf
        Next d
      EndIf
      
    ElseIf \bLCTargetIsP Or \bLCTargetIsA  ; \bLCTargetIsP or \bLCTargetIsA
      If nLCSubPtr >= 0
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCDevPresent[d]
            If (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO And d = 0) Or (aAud(nLCAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO And aAud(nLCAudPtr)\nBassChannel[d] <> 0)
              If aSub(nLCSubPtr)\nPLBassDevice[d] <> 0
                If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                  If \fLCReqdBVLevel[d] <> \fLCInitBVLevel[d]
                    bChanged = #True
                    \fLCReqdBVLevel[d] = \fLCInitBVLevel[d]
                    SLD_setLevel(WQL\sldLCLevel[d], \fLCReqdBVLevel[d], \fLCTrimFactor[d])
                    WQL_fcSldLCLevel(d)
                  EndIf
                ElseIf \nLCAction = #SCS_LC_ACTION_RELATIVE
                  If \fLCReqdBVLevel[d] <> grLevels\fPlusZeroBV
                    bChanged = #True
                    \sLCReqdDBLevel[d] = grLevels\sPlusZeroDB    ; ie no change
                    \fLCReqdBVLevel[d] = grLevels\fPlusZeroBV
                    SGT(WQL\txtLCDBLevel[d], grLevels\sPlusZeroDB)
                    debugMsg(sProcName, "WQL\txtLCDBLevel[" + d + "]=" + GGT(WQL\txtLCDBLevel[d]))
                  EndIf
                EndIf
                Select \nLCAction
                  Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
                    If \fLCReqdPan[d] <> \fLCInitPan[d]
                      bChanged = #True
                      \fLCReqdPan[d] = \fLCInitPan[d]
                      SLD_setValue(WQL\sldLCPan[d], panToSliderValue(\fLCReqdPan[d]))
                      WQL_fcSldLCPan(d)
                    EndIf
                EndSelect
              EndIf
            EndIf
          EndIf
        Next d
      EndIf
    EndIf
    
    WQL_fcLCSameLevel()
    rWQL\bCallSetOrigReqdDBLevels = #True
    postChangeSubL(u, bChanged)
    
  EndWith
  
  gbCallEditUpdateDisplay = #True
  editSetDisplayButtonsL()
  
  SAG(-1)
  
EndProcedure

Procedure WQL_btnTestLevelChange_Click()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  editPlayLevelChange()
  SAG(-1)
EndProcedure

Procedure WQL_drawForm()
  PROCNAMEC()

  colorEditorComponent(#WQL)

EndProcedure

Procedure WQL_populateCboLCAction(bForceLoad=#False)
  PROCNAMEC()
  Protected nLCAudPtr, bIncludeTempoEtc
  Static bPrevIncludeTempoEtc
  
  If grLicInfo\bTempoAndPitchAvailable
    If nEditSubPtr >= 0
      Select aSub(nEditSubPtr)\nLCAction
        Case #SCS_LC_ACTION_FREQ, #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
          bIncludeTempoEtc = #True
        Default
          nLCAudPtr = aSub(nEditSubPtr)\nLCAudPtr
          If nLCAudPtr >= 0
            If aAud(nLCAudPtr)\bAudTypeF
              bIncludeTempoEtc = #True
            EndIf
          EndIf
      EndSelect
    EndIf
  EndIf
  
  If bIncludeTempoEtc <> bPrevIncludeTempoEtc Or bForceLoad
    ClearGadgetItems(WQL\cboLCAction)
    addGadgetItemWithData(WQL\cboLCAction, Lang("WQL", "Absolute"), #SCS_LC_ACTION_ABSOLUTE)
    addGadgetItemWithData(WQL\cboLCAction, Lang("WQL", "Relative"), #SCS_LC_ACTION_RELATIVE)
    If bIncludeTempoEtc
      addGadgetItemWithData(WQL\cboLCAction, Lang("WQL", "ChgFreq"), #SCS_LC_ACTION_FREQ)
      addGadgetItemWithData(WQL\cboLCAction, Lang("WQL", "ChgTempo"), #SCS_LC_ACTION_TEMPO)
      addGadgetItemWithData(WQL\cboLCAction, Lang("WQL", "ChgPitch"), #SCS_LC_ACTION_PITCH)
    EndIf
    setComboBoxWidth(WQL\cboLCAction)
    bPrevIncludeTempoEtc = bIncludeTempoEtc
  EndIf
  
EndProcedure

Procedure WQL_Form_Load()
  PROCNAMEC()
  Protected nBracketPtr, nLeft
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQL()
  SUB_loadOrResizeHeaderFields("L", #True)
  rWQL\bInValidate = #False
  
  nBracketPtr = FindString(GGT(WQL\lblReqdNewLevel), "(", 1)
  If nBracketPtr < 2
    rWQL\slblReqdNewLevel = GGT(WQL\lblReqdNewLevel)
  Else
    rWQL\slblReqdNewLevel = Trim(Left(GGT(WQL\lblReqdNewLevel), nBracketPtr - 1))
  EndIf

  nBracketPtr = FindString(GGT(WQL\lblReqdNewPan), "(", 1)
  If nBracketPtr < 2
    rWQL\slblReqdNewPan = GGT(WQL\lblReqdNewPan)
  Else
    rWQL\slblReqdNewPan = Trim(Left(GGT(WQL\lblReqdNewPan), nBracketPtr - 1))
  EndIf
  
  WQL_populateCboLCAction(#True)
  
  WQL_drawForm()

  buildEditCBO(WQL\cboLCType, "LevelChange")
  
  ; Added 31Dec2024 11.10.6ca after removing '(recommended)' after 'Standard'
  setComboBoxWidth(WQL\cboLCType)
  nLeft = GadgetX(WQL\cboLCType) + GadgetWidth(WQL\cboLCType) + 30
  ResizeGadget(WQL\btnLCReset, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  ; End added 31Dec2024 11.10.6ca
  
EndProcedure

Procedure WQL_txtLCDBLevel_Validate(Index)
  PROCNAMEC()
  Protected bRelativeLevel
  Protected fDBLevel.f, fDBTrim.f
  Protected sReqdDBLevel.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If nEditSubPtr >= 0
    If aSub(nEditSubPtr)\nLCAction = #SCS_LC_ACTION_RELATIVE
      bRelativeLevel = #True
    EndIf
  EndIf
  
  sReqdDBLevel = Trim(GGT(WQL\txtLCDBLevel[Index]))
  
  If bRelativeLevel
    If validateDbChangeField(sReqdDBLevel, rWQL\slblReqdNewLevel) = #False
      ProcedureReturn #False
    EndIf
  Else
    If validateDbField(sReqdDBLevel, rWQL\slblReqdNewLevel) = #False
      ProcedureReturn #False
    EndIf
    If GGT(WQL\txtLCDBLevel[Index]) <> gsTmpString
      SGT(WQL\txtLCDBLevel[Index], gsTmpString)
      debugMsg(sProcName, "WQL\txtLCDBLevel[" + Index + "]=" + GGT(WQL\txtLCDBLevel[Index]))
    EndIf
  EndIf
  
  If bRelativeLevel = #False
    fDBLevel = convertDBStringToDBLevel(sReqdDBLevel)
    fDBTrim = convertDBStringToDBLevel(aSub(nEditSubPtr)\sLCDBTrim[Index])
    If (fDBLevel > fDBTrim) And (fDBTrim <> 0)
      valErrMsgTxt(WQL\txtLCDBLevel[Index], "dB (" + formatTrim(fDBLevel) + ") cannot be greater than the Trim level (" + formatTrim(fDBTrim) + ")")
      ProcedureReturn #False
    EndIf
  EndIf
  
  WQL_changeLCLevel(2, Index)
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQL_txtLCPan_Validate(Index)
  PROCNAMEC()

  If validatePanTextField(GGT(WQL\txtLCPan[Index]), rWQL\slblReqdNewPan) = #False
    ProcedureReturn #False
  EndIf
  
  ; debugMsg(sProcName, "calling WQL_changeLCPan(2, " + Index + ")")
  WQL_changeLCPan(2, Index)
  
  ProcedureReturn #True
EndProcedure

Procedure WQL_txtLCStartAt_Validate()
  PROCNAMEC()
  Protected u

  If rWQL\bInValidate
    ProcedureReturn #True
  EndIf
  rWQL\bInValidate = #True

  If validateTimeFieldT(GGT(WQL\txtLCStartAt), GGT(WQL\lblLCTestStartAt), #False, #False, 0, #True) = #False
    rWQL\bInValidate = #False
    ProcedureReturn #False
  ElseIf GGT(WQL\txtLCStartAt) <> gsTmpString
    SGT(WQL\txtLCStartAt, gsTmpString)
  EndIf

  With aSub(nEditSubPtr)
    u = preChangeSubL(\nLCStartAt, GGT(WQL\lblLCTestStartAt))
    \nLCStartAt = stringToTime(GGT(WQL\txtLCStartAt), #True)
    postChangeSubL(u, \nLCStartAt)
  EndWith
  rWQL\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQL_txtLCTime_Validate(Index)
  ; Supports txtLCTime being a time field (eg 1.5) or a callable cue parameter (eg LCT)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected d
  Protected nTimeGadget, sPrompt.s, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  Protected sNewLCTime.s
  Protected sErrorMsg.s

  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nTimeGadget = WQL\txtLCTime[Index]
  sPrompt = removeLF(GGT(WQL\lblChangeTime))
  macCommonTimeFieldValidationT(rWQL\bInValidate) ; nb populates sValue which will be used by macReadNumericOrStringParam() below
  
  sNewLCTime = Trim(GGT(nTimeGadget))
  If nTimeFieldIsParamId = -1
    sErrorMsg = LangPars("Errors", "CallableParamNotFound", sNewLCTime, aSub(nEditSubPtr)\sSubLabel, aCue(nEditCuePtr)\sCue)
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLCTime[Index], \nLCTime[Index])
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLCTime[Index], \nLCTime[Index], grSubDef\nLCTime[Index], #True)
    ; Macro macReadNumericOrStringParam populates \sLCTime[Index] and \nLCTime[Index] from the value in sValue
    sNew = makeDisplayTimeValue(\sLCTime[Index], \nLCTime[Index])
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\bLCSameTime=" + strB(\bLCSameTime) + ", \nLCMaxLogicalDev=" + \nLCMaxLogicalDev)
    If \bLCSameTime
      For d = 0 To \nLCMaxLogicalDev
        If d <> Index
          \sLCTime[d] = \sLCTime[Index]
          \nLCTime[d] = \nLCTime[Index]
          SGT(WQL\txtLCTime[d], sNewLCTime)
          ; debugMsg0(sProcName, "\sLCTime[" + d + "]=" + \sLCTime[d] + ", \nLCTime[" + d + "]=" + \nLCTime[d])
        EndIf
      Next d
    EndIf
    WQL_fcTxtLCTimes()
    postChangeSubS(u, sNew)
  EndWith

  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQL_txtLCTempoEtcValue_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u, bValResult

  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    bValResult = WQL_txtTempoEtcValue_Validate()
    If bValResult
      u = preChangeSubF(\fLCActionValue, GGT(WQL\lblLCTempoEtcValue))
      \fLCActionValue = grTempoEtc\fTempoEtcCurrValue
      debugMsg(sProcName, "\fLCActionValue=" + StrF(\fLCActionValue, grTempoEtc\nTempoEtcDecimals))
      postChangeSubF(u, \fLCActionValue)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn bValResult
  
EndProcedure

Procedure WQL_sldLCTempoEtcValue_Event(gnSliderEvent)
  ; PROCNAMECS(nEditSubPtr)
  Protected u
  
  With aSub(nEditSubPtr)
    WQL_sldLCTempoEtcValue_Common()
    u = preChangeSubF(\fLCActionValue, GGT(WQL\lblLCTempoEtcValue))
    \fLCActionValue = grTempoEtc\fTempoEtcCurrValue
    ; debugMsg(sProcName, "\fLCActionValue=" + StrF(\fLCActionValue, rWQL\nTempoEtcDecimals))
    postChangeSubF(u, \fLCActionValue)
  EndWith

EndProcedure

Procedure WQL_txtLCTempoEtcTime_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u

  debugMsg(sProcName, #SCS_START)
  
  If validateTimeFieldT(GGT(WQL\txtLCTempoEtcTime), GGT(WQL\lblLCTempoEtcTime), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WQL\txtLCTempoEtcTime) <> gsTmpString
    SGT(WQL\txtLCTempoEtcTime, gsTmpString)
  EndIf

  With aSub(nEditSubPtr)
    u = preChangeSubL(\nLCActionTime, GGT(WQL\lblLCTempoEtcTime))
    \nLCActionTime = stringToTime(GGT(WQL\txtLCTempoEtcTime))
    debugMsg(sProcName, "\nLCActionTime=" + \nLCActionTime)
    postChangeSubL(u, \nLCActionTime)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQL_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQL_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQL_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)

  With WQL
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQL)
        
        ; detail gadgets
      Case \txtLCDBLevel[0]
        ETVAL2(WQL_txtLCDBLevel_Validate(nArrayIndex))
        
      Case \txtLCPan[0]
        ETVAL2(WQL_txtLCPan_Validate(nArrayIndex))
        
      Case \txtLCStartAt
        ETVAL2(WQL_txtLCStartAt_Validate())
        
      Case \txtLCTempoEtcTime
        ETVAL2(WQL_txtLCTempoEtcTime_Validate())
        
      Case \txtLCTempoEtcValue
        ETVAL2(WQL_txtLCTempoEtcValue_Validate())
        
      Case \txtLCTime[0]
        ETVAL2(WQL_txtLCTime_Validate(nArrayIndex))
        
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

Procedure WQL_EventHandler()
  PROCNAMEC()
  Protected n, bFound
  
  With WQL
    
    ; nb MUST check menu events first so that #SCS_WMNF_IncPlayingCues and #SCS_WMNF_DecPlayingCues can be processed even if gnEventSliderNo > 0
    ; see also WED_EventHandler() in fmEditor.pbi, which is where the menu events are originally caught
    Select gnWindowEvent
      Case #PB_Event_Menu
        Select gnEventMenu
          Case #SCS_WEDF_IncLevels
            WQL_adjustAllLevels(1)
            
          Case #SCS_WEDF_DecLevels
            WQL_adjustAllLevels(-1)
            
          Case #SCS_WEDF_Rewind
            If getVisible(\btnLCRewind) And getEnabled(\btnLCRewind)
              WQL_transportBtnClick(#SCS_STANDARD_BTN_REWIND)
            EndIf
            
          Case #SCS_WEDF_PlayPause
            If getVisible(\btnLCPlay) And getEnabled(\btnLCPlay)
              WQL_transportBtnClick(#SCS_STANDARD_BTN_PLAY)
            ElseIf getVisible(\btnLCPause) And getEnabled(\btnLCPause)
              WQL_transportBtnClick(#SCS_STANDARD_BTN_PAUSE)
            EndIf
            
          Case #SCS_WEDF_Stop
            If getVisible(\btnLCStop) And getEnabled(\btnLCStop)
              WQL_transportBtnClick(#SCS_STANDARD_BTN_STOP)
            EndIf
            
        EndSelect
        
    EndSelect
    
    If gnEventSliderNo > 0
      
      ; debugMsg(sProcName, "gnSliderEvent=" + gnSliderEvent + ", gnEventSliderNo=" + gnEventSliderNo)
      
      If gnEventSliderNo = \sldLCProgress
        bFound = #True
        ; no action required on the progress slider
        
      ElseIf gnEventSliderNo = \sldLCTempoEtcValue
        bFound = #True
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            WQL_sldLCTempoEtcValue_Event(gnSliderEvent)
        EndSelect
        
      Else
        For n = 0 To grLicInfo\nMaxAudDevPerAud
          If gnEventSliderNo = \sldLCLevel[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQL_changeLCLevel(1, n)
                rWQL\bCallSetOrigReqdDBLevels = #True
            EndSelect
            Break
            
          ElseIf gnEventSliderNo = \sldLCPan[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQL_changeLCPan(1, n)
            EndSelect
            Break
          EndIf
        Next n
        
      EndIf
      
      ; debugMsg(sProcName, "end of processing gnSliderEvent=" + gnSliderEvent + ", gnEventSliderNo=" + gnEventSliderNo + ", bFound=" + strB(bFound))
      
      If bFound
        ProcedureReturn
      EndIf
      
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        If gnEventButtonId <> 0
          ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId)
          If gnEventButtonId & #SCS_TRANSPORT_BTN
            WQL_transportBtnClick(gnEventButtonId)
          EndIf
          
        ElseIf gnEventSliderNo > 0
          Select gnEventSliderNo
            Case \sldLCLevel[0]
              ; no action
            Case \sldLCPan[0]
              ; no action
            Case \sldLCProgress
              ; no action
            Case \sldLCTempoEtcValue
              ; no action
          EndSelect
          
        Else
          ; debugMsg(sProcName, "gnEventGadgetNoForEvHdlr=G" + Str(gnEventGadgetNoForEvHdlr))
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQL)
              
              ; detail gadgets in alphabetical order
              
            Case \btnLCCenter[0]
              BTNCLICK(WQL_btnLCCenter_Click(gnEventGadgetArrayIndex))
              
            Case \btnLCReset
              BTNCLICK(WQL_btnLCReset_Click())
              
            Case \btnTempoEtcReset
              WQL_btnTempoEtcReset_Click()
              
            Case \btnTestLevelChange
              BTNCLICK(WQL_btnTestLevelChange_Click())
              
            Case \cboLCAction
              CBOCHG(WQL_cboLCAction_Click())
              
            Case \cboLCCue
              CBOCHG(WQL_cboLCCue_Click())
              
            Case \cboLCType
              CBOCHG(WQL_cboLCType_Click())
              
            Case \chkLCInclude[0]
              CHKOWNCHG(WQL_chkLCInclude_Click(gnEventGadgetArrayIndex))
              
            Case \chkLCSameLevel
              CHKOWNCHG(WQL_chkLCSameLevel_Click())
              
            Case \chkLCSameTime
              CHKOWNCHG(WQL_chkLCSameTime_Click())
              
            Case \cntLCComment, \cntLCDevs, \cntLCInfoBelowDevs, \cntLCTempoEtc
              ; no action
              
            Case \cntSubDetailL, \cntTest
              ; no action
              
            Case \scaLCDevs, \scaLevelChange
              ; no action
              
            Case \txtLCDBLevel[0]
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQL_txtLCDBLevel_Validate(gnEventGadgetArrayIndex))
              EndIf
              
            Case \txtLCPan[0]
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQL_txtLCPan_Validate(gnEventGadgetArrayIndex))
              EndIf
              
            Case \txtLCStartAt
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQL_txtLCStartAt_Validate())
              EndIf
              
            Case \txtLCTempoEtcTime
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQL_txtLCTempoEtcTime_Validate())
              EndIf
              
            Case \txtLCTempoEtcValue
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQL_txtLCTempoEtcValue_Validate())
              EndIf
              
            Case \txtLCTime[0]
              If gnEventType = #PB_EventType_Focus
                setOrClearGadgetValidValuesFlag()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQL_txtLCTime_Validate(gnEventGadgetArrayIndex))
              EndIf
              
            Default
              If gnEventType <> #PB_EventType_Resize
                debugMsg0(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
              EndIf
          EndSelect
          
        EndIf
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQL_checkLCStartAt()
  PROCNAMECS(nEditSubPtr)
  Protected nLCStartAt, nCueDuration
  Protected nLCAudPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr < 0
    ; shouldn't happen
    ProcedureReturn #True
  EndIf
  
  nLCStartAt = aSub(nEditSubPtr)\nLCStartAt
  nLCAudPtr = aSub(nEditSubPtr)\nLCAudPtr
  If nLCAudPtr < 0
    ; shouldn't happen
    ProcedureReturn #True
  EndIf
  
  If aAud(nLCAudPtr)\bAudTypeI
    ; no 'start at' for live inputs
    ProcedureReturn #True
  EndIf
  
  nCueDuration = aAud(nLCAudPtr)\nCueDuration
  
  If nLCStartAt >= nCueDuration
    scsMessageRequester(grText\sTextCueTypeL, LangPars("WQL", "StartTooHigh", timeToStringT(nLCStartAt), timeToStringT(nCueDuration)), #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WQL_transportBtnClick(nButtonType)
  PROCNAMECS(nEditSubPtr)
  Protected nLCSubPtr, nLCAudPtr
  
  debugMsg(sProcName, #SCS_START + ", nButtonType=" + decodeStdBtnType(nButtonType))
  
  With aSub(nEditSubPtr)
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
  EndWith
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_REWIND  ; rewind
      gqTimeNow = ElapsedMilliseconds()
      restartAud(nLCAudPtr, #True)
      
    Case #SCS_STANDARD_BTN_PLAY  ; play
      If WQL_checkLCStartAt()
        gqTimeNow = ElapsedMilliseconds()
        If aSub(nLCSubPtr)\nSubState = #SCS_CUE_PAUSED
          resumeAud(nLCAudPtr)
        Else
          WQL_clearManualOverrides()
          editPlayLCCue()
        EndIf
        samAddRequest(#SCS_SAM_BUILD_DEV_CHANNEL_LIST)
        startVUDisplayIfReqd()
      EndIf
      
    Case #SCS_STANDARD_BTN_PAUSE  ; pause
      gqTimeNow = ElapsedMilliseconds()
      If aSub(nLCSubPtr)\nSubState = #SCS_CUE_PAUSED
        resumeAud(nLCAudPtr)
      Else
        pauseAud(nLCAudPtr)
      EndIf
      
    Case #SCS_STANDARD_BTN_STOP  ; stop
      gqTimeNow = ElapsedMilliseconds()
      editStopLCSub(nEditSubPtr)
      
  EndSelect
  
  editSetDisplayButtonsL()
  SAG(-1)
  
EndProcedure

Procedure WQL_fcSldLCLevel(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected fBVLevel.f
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", gbInDisplaySub=" + strB(gbInDisplaySub))
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)
    If \bLCInclude[Index]
      u = preChangeSubS(\sLCReqdDBLevel[Index], "Required New Level", -5, #SCS_UNDO_ACTION_CHANGE, Index)
      fBVLevel = SLD_getLevel(WQL\sldLCLevel[Index])
      \fLCReqdBVLevel[Index] = fBVLevel
      \sLCReqdDBLevel[Index] = convertBVLevelToDBString(fBVLevel)
      SetGadgetText(WQL\txtLCDBLevel[Index], \sLCReqdDBLevel[Index])
      ; debugMsg(sProcName, "WQL\txtLCDBLevel[" + Index + "]=" + GGT(WQL\txtLCDBLevel[Index]))
      If gbInDisplaySub = #False
        editSetDisplayButtonsL()
      EndIf
      postChangeSubS(u, \sLCReqdDBLevel[Index], -5, Index)
    EndIf
  EndWith
EndProcedure

Procedure WQL_fcSldLCPan(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", pDevNo=" + Str(pDevNo) + ", nEditSubPtr=" + nEditSubPtr + ", gbInDisplaySub=" + strB(gbInDisplaySub))
  
  With aSub(nEditSubPtr)
    
    If gbInDisplaySub = #False
      u = preChangeSubF(\fLCReqdPan[Index], "Required New Pan", -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \fLCReqdPan[Index] = panSliderValToSingle(SLD_getValue(WQL\sldLCPan[Index]))
      SetGadgetText(WQL\txtLCPan[Index], panSingleToString(\fLCReqdPan[Index]))
    EndIf
    
    If (\fLCReqdPan[Index] = #SCS_PANCENTRE_SINGLE) Or (\bLCInclude[Index] = #False) Or (SLD_getEnabled(WQL\sldLCPan[Index]) = #False)
      setEnabled(WQL\btnLCCenter[Index], #False)
    Else
      setEnabled(WQL\btnLCCenter[Index], #True)
    EndIf
    
    If gbInDisplaySub = #False
      editSetDisplayButtonsL()
      postChangeSubF(u, \fLCReqdPan[Index], -5, Index)
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_fcTxtLCDBLevel(Index)
  PROCNAMEC()
  Protected fBVLevel.f, fTrimFactor.f
  
  With aSub(nEditSubPtr)
    If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
      fBVLevel = \fLCReqdBVLevel[Index]
      If ((\bLCTargetIsF) Or (\bLCTargetIsI)) And (\nLCAudPtr >= 0)
        fTrimFactor = aAud(\nLCAudPtr)\fTrimFactor[Index]
      ElseIf ((\bLCTargetIsP) Or (\bLCTargetIsA)) And (\nLCSubPtr >= 0)
        fTrimFactor = aSub(\nLCSubPtr)\fSubTrimFactor[Index]
      EndIf
      If SLD_getLevel(WQL\sldLCLevel[Index]) <> fBVLevel
        SLD_setLevel(WQL\sldLCLevel[Index], fBVLevel, fTrimFactor)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WQL_fcLCAction()
  PROCNAMECS(nEditSubPtr)
  Protected nLCAction, d, nLeft, nLeft2, nLength
  Protected bReqdNewLevelVisible, bdBVisible, bReqdDBChangeVisible, bLCActionVisible, bLCDevsVisible, bLCTempoEtcVisible
  
  debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  With WQL
    nLCAction = #SCS_LC_ACTION_ABSOLUTE
    If nEditSubPtr >= 0
      nLCAction = aSub(nEditSubPtr)\nLCAction
    EndIf
    debugMsg(sProcName, "nLCAction=" + decodeLCAction(nLCAction) + " (" + nLCAction + ")")
    
    Select nLCAction
      Case #SCS_LC_ACTION_ABSOLUTE
        bReqdNewLevelVisible = #True
        bdBVisible = #True
        nLeft = SLD_gadgetX(\sldLCLevel[0]) + SLD_gadgetWidth(\sldLCLevel[0])
        bLCDevsVisible = #True
        
      Case #SCS_LC_ACTION_RELATIVE
        bReqdDBChangeVisible = #True
        nLeft = 176
        nLeft2 = nLeft + GadgetWidth(\txtLCDBLevel[0]) + 12
        bLCDevsVisible = #True
        
      Case #SCS_LC_ACTION_FREQ, #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
        bLCTempoEtcVisible = #True
        
    EndSelect
    
    ; debugMsg0(sProcName, "nLCAction=" + decodeLCAction(nLCAction) + " (" + nLCAction + ")" + ", bLCDevsVisible=" + strB(bLCDevsVisible))
    setVisible(\lblReqdNewLevel, bReqdNewLevelVisible)
    setVisible(\lbldB, bdBVisible)
    setVisible(\lblReqdDBChange, bReqdDBChangeVisible)
    setVisible(\cntLCDevs, bLCDevsVisible)
    setVisible(\cntLCInfoBelowDevs, bLCDevsVisible)
    setVisible(\cntLCTempoEtc, bLCTempoEtcVisible)
    
    If bLCDevsVisible
      If GadgetX(\txtLCDBLevel[0]) <> nLeft
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          ResizeGadget(\txtLCDBLevel[d], nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          If nLCAction = #SCS_LC_ACTION_RELATIVE
            ResizeGadget(\txtLCDBActualLevel[d], nLeft2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
        Next d
      EndIf
      WQL_displayDev()
    EndIf
    
    If bLCTempoEtcVisible
      WQL_setTempoEtcFields(nEditSubPtr)
      If aSub(nEditSubPtr)\nLCActionTime < 0
        SGT(\txtLCTempoEtcTime, "")
      Else
        SGT(\txtLCTempoEtcTime, timeToStringT(aSub(nEditSubPtr)\nLCActionTime))
      EndIf
    EndIf
    
    WQL_setTestButtonText()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_fcTxtLCTimes()
  PROCNAMECS(nEditSubPtr)
  Protected d
  
  With aSub(nEditSubPtr)
    \nLCTimeMax = 0
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      If \nLCTime[d] > \nLCTimeMax
        \nLCTimeMax = \nLCTime[d]
      EndIf
    Next d
    If SLD_getMax(WQL\sldLCProgress) <> \nLCTimeMax
      SLD_setMax(WQL\sldLCProgress, \nLCTimeMax)
    EndIf
    If \nLCTimeMax <= 0
      SLD_setVisible(WQL\sldLCProgress, #False)
    Else
      SLD_setVisible(WQL\sldLCProgress, #True)
    EndIf
    SLD_setEnabled(WQL\sldLCProgress, #False)
    setDerivedSubFields(nEditSubPtr, #True)
  EndWith
  
EndProcedure

Procedure WQL_fcLCSameLevel()
  PROCNAMECS(nEditSubPtr)
  Protected d
  Protected bLCSameLevel
  Protected sFirstLevelDB.s, fFirstPan.f
  Protected nFirstIncludedDev = -1
  Protected bRelativeLevel, bEnableLevelFields
  Protected nDevIndex, nNrOfOutputChans
  Protected nLCAudPtr, nTargetState
  
  If nEditSubPtr >= 0
    bLCSameLevel = aSub(nEditSubPtr)\bLCSameLevel
    With aSub(nEditSubPtr)
      Select \nLCAction
        Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
          ; ok to continue
        Default
          ProcedureReturn
      EndSelect
      
      ; Added 7Mar2025 11.10.7ac following bug reported by Beverley Grover
      debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nLCAudPtr=" + getAudLabel(\nLCAudPtr))
      If \nLCAudPtr < 0
        ProcedureReturn
      EndIf
      ; End added 7Mar2025 11.10.7ac
      
      If \nLCAction = #SCS_LC_ACTION_RELATIVE
        bRelativeLevel = #True
      EndIf
      
      ; Added 23Dec2024 11.10.6by
      nLCAudPtr = \nLCAudPtr
      If nLCAudPtr >= 0
        nTargetState = aAud(nLCAudPtr)\nAudState
      EndIf
      ; End added 23Dec2024 11.10.6by
      
      If bLCSameLevel
        ; if 'same Level' for all devices, then find the index and 'Level' of the first included device
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCInclude[d]
            If nFirstIncludedDev = -1
              nFirstIncludedDev = d
              sFirstLevelDB = \sLCReqdDBLevel[d]
              If aAud(nLCAudPtr)\bDisplayPan[d]
                fFirstPan = \fLCReqdPan[d]
              EndIf
              Break
            EndIf
          EndIf
        Next d
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          \sLCReqdDBLevel[d] = sFirstLevelDB
          \fLCReqdBVLevel[d] = convertDBStringToBVLevel(\sLCReqdDBLevel[d])
          If aAud(nLCAudPtr)\bDisplayPan[d]
            \fLCReqdPan[d] = fFirstPan
          EndIf
        Next d
      EndIf
      
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \bLCDevPresent[d]
          bEnableLevelFields = \bLCInclude[d]
          If bLCSameLevel
            If d <> nFirstIncludedDev
              bEnableLevelFields = #False
            EndIf
          EndIf
          If bRelativeLevel
            SLD_setEnabled(WQL\sldLCLevel[d], #False)
          Else
            SLD_setLevel(WQL\sldLCLevel[d], \fLCReqdBVLevel[d], \fLCTrimFactor[d])
            If nTargetState < #SCS_CUE_FADING_IN Or nTargetState > #SCS_CUE_FADING_OUT ; Test added 23Dec2024 11.10.6by for use in testing Level Change cue in fmEditQL.pbi
              SLD_setBaseLevel(WQL\sldLCLevel[d], \fLCInitBVLevel[d], \fLCTrimFactor[d])
            Else
              SLD_setBaseLevel(WQL\sldLCLevel[d], aAud(nLCAudPtr)\fCueTotalVolNow[d], \fLCTrimFactor[d]) ; Added 23Dec2024 11.10.6by
            EndIf
            SLD_setEnabled(WQL\sldLCLevel[d], bEnableLevelFields)
          EndIf
          SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(\fLCReqdBVLevel[d], bRelativeLevel))
          setEnabled(WQL\txtLCDBLevel[d], bEnableLevelFields)
          
          If aAud(nLCAudPtr)\bDisplayPan[d]
            SLD_setValue(WQL\sldLCPan[d], panToSliderValue(\fLCReqdPan[d]))
            If nTargetState < #SCS_CUE_FADING_IN Or nTargetState > #SCS_CUE_FADING_OUT ; Test added 23Dec2024 11.10.6by for use in testing Level Change cue in fmEditQL.pbi
              SLD_setBaseValue(WQL\sldLCPan[d], panToSliderValue(\fLCInitPan[d]))
            Else
              debugMsg(sProcName, "aAud(" + getAudLabel(\nLCAudPtr) + ")\fCuePanNow[d]=" + formatPan(aAud(\nLCAudPtr)\fCuePanNow[d]))
              SLD_setBaseValue(WQL\sldLCPan[d], panToSliderValue(aAud(\nLCAudPtr)\fCuePanNow[d])) ; Added 23Dec2024 11.10.6by
            EndIf
            SGT(WQL\txtLCPan[d], panSingleToString(\fLCReqdPan[d]))
            If \bLCTargetIsA
              nNrOfOutputChans = 2
            Else
              nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, \sLCLogicalDev[d])
              If nDevIndex >= 0
                CheckSubInRange(nDevIndex, grProd\nMaxAudioLogicalDev, "grProd\aAudioLogicalDevs(), aSub(" + getSubLabel(nEditSubPtr) + ")\sLCLogicalDev[" + d + "]=" + \sLCLogicalDev[d])
                nNrOfOutputChans = grProd\aAudioLogicalDevs(nDevIndex)\nNrOfOutputChans
              Else
                nNrOfOutputChans = 0
              EndIf
            EndIf
            If nNrOfOutputChans = 2
              SLD_setEnabled(WQL\sldLCPan[d], bEnableLevelFields)
              setEnabled(WQL\txtLCPan[d], bEnableLevelFields)
            Else
              SLD_setEnabled(WQL\sldLCPan[d], #False)
              setEnabled(WQL\btnLCCenter[d], #False)
              setEnabled(WQL\txtLCPan[d], #False)
            EndIf
          EndIf
        EndIf
      Next d
      
      rWQL\bCallSetOrigReqdDBLevels = #True
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQL_fcLCSameTime()
  PROCNAMECS(nEditSubPtr)
  Protected d
  Protected bLCSameTime
  Protected nFirstTime
  Protected nFirstIncludedDev = -1
  
  If nEditSubPtr >= 0
    bLCSameTime = aSub(nEditSubPtr)\bLCSameTime
    With aSub(nEditSubPtr)
      
      If bLCSameTime
        ; if 'same time' for all devices, then find the index and 'time' of the first included device
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCInclude[d]
            If nFirstIncludedDev = -1
              nFirstIncludedDev = d
              nFirstTime = \nLCTime[d]
              Break
            EndIf
          EndIf
        Next d
      EndIf
      
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If bLCSameTime
          If d = nFirstIncludedDev
            setEnabled(WQL\txtLCTime[d], #True)
          Else
            setEnabled(WQL\txtLCTime[d], #False)
            If \nLCTime[d] <> nFirstTime
              \nLCTime[d] = nFirstTime
              SGT(WQL\txtLCTime[d], timeToStringT(nFirstTime))
            EndIf
          EndIf
        Else
          If \bLCInclude[d]
            setEnabled(WQL\txtLCTime[d], #True)
          Else
            setEnabled(WQL\txtLCTime[d], #False)
          EndIf
        EndIf
        setTextBoxBackColor(WQL\txtLCTime[d])
      Next d
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQL_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  Protected d, nAudioDevCount, nMaxHeight
  
  With WQL
    If IsGadget(\scaLevelChange)
      ; \scaLevelChange automatically resized by splitter gadget, but need to adjust inner height
      ; debugMsg(sProcName, "GadgetHeight(\scaLevelChange)=" + GadgetHeight(\scaLevelChange))
      nInnerHeight = GadgetHeight(\scaLevelChange) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaLevelChange, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailL
      nHeight = nInnerHeight - GadgetY(\cntSubDetailL)
      ResizeGadget(\cntSubDetailL, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; adjust position of test controls container
      nTop = GadgetHeight(\cntSubDetailL) - GadgetHeight(\cntTest) - 4
      ResizeGadget(\cntTest, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      
      ; adjust position of info below devs container
      nTop = GadgetY(\cntTest) - GadgetHeight(\cntLCInfoBelowDevs)
      ResizeGadget(\cntLCInfoBelowDevs, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      
      ; adjust height of devs container
      nHeight = GadgetY(\cntLCInfoBelowDevs) - GadgetY(\cntLCDevs)
      ResizeGadget(\cntLCDevs, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; count audio devs in prod, for calculating minimum height of \scaLCDevs
      For d = 0 To grProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD ; Changed 15Dec2022 11.10.0ac
        If Trim(grProd\aAudioLogicalDevs(d)\sLogicalDev)
          nAudioDevCount + 1
        EndIf
      Next d
      ; minimum for calculating height = 4 devs
      If nAudioDevCount < 4
        nAudioDevCount = 4
      EndIf
      nMaxHeight = nAudioDevCount * 22
      ; adjust the height of \scaLCDevs
      nHeight = GadgetHeight(\cntLCDevs) - GadgetY(\scaLCDevs)
      If nHeight > nMaxHeight
        nHeight = nMaxHeight
      EndIf
      ResizeGadget(\scaLCDevs, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
    EndIf
  EndWith
EndProcedure

Procedure WQL_adjustPlayingLevelsIfReqd()
  PROCNAMEC()
  Protected nFirstDev, nLastDev
  Protected d
  Protected nLCAudPtr, nLCAudState
  Protected fTmpLevel.f, fTmpDBLevel.f
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      nLCAudPtr = \nLCAudPtr
      If nLCAudPtr >= 0
        Select \nLCAction
          Case #SCS_LC_ACTION_ABSOLUTE
            nFirstDev = aAud(nLCAudPtr)\nFirstDev
            nLastDev = aAud(nLCAudPtr)\nLastDev
            For d = nFirstDev To nLastDev
              If \bLCInclude[d]
                If nLCAudPtr >= 0
                  nLCAudState = aAud(nLCAudPtr)\nAudState
                  If nLCAudState >= #SCS_CUE_FADING_IN And nLCAudState <= #SCS_CUE_FADING_OUT
                    ; debugMsg0(sProcName, "calling setLevelsAny(" + getAudLabel(nLCAudPtr) + ", " + d + ", " + traceLevel(\fLCReqdBVLevel[d]) + ", " + tracePan(\fLCReqdPan[d]) + ")")
                    setLevelsAny(nLCAudPtr, d, \fLCReqdBVLevel[d], \fLCReqdPan[d])
                  EndIf
                EndIf
              EndIf
            Next d
            
          Case #SCS_LC_ACTION_RELATIVE
            nFirstDev = aAud(nLCAudPtr)\nFirstDev
            nLastDev = aAud(nLCAudPtr)\nLastDev
            For d = nFirstDev To nLastDev
              If \bLCInclude[d]
                If nLCAudPtr >= 0
                  nLCAudState = aAud(nLCAudPtr)\nAudState
                  If nLCAudState >= #SCS_CUE_FADING_IN And nLCAudState <= #SCS_CUE_FADING_OUT
                    fTmpDBLevel = convertBVLevelToDBLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d])
                    fTmpDBLevel + convertDBStringToDBLevel(aSub(nEditSubPtr)\sLCReqdDBLevel[d])
                    fTmpLevel = convertDBLevelToBVLevel(fTmpDBLevel)
                    If fTmpLevel > grLevels\fMaxBVLevel
                      fTmpLevel = grLevels\fMaxBVLevel
                    ElseIf fTmpLevel < #SCS_MINVOLUME_SINGLE
                      fTmpLevel = #SCS_MINVOLUME_SINGLE
                    EndIf
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(nLCAudPtr) + ")\fAudPlayBVLevel[" + d + "]=" + traceLevel(aAud(nLCAudPtr)\fAudPlayBVLevel[d]) +
                    ;                     ", aSub(" + getSubLabel(nEditSubPtr) + ")\sLCReqdDBLevel[" + d + "]=" + aSub(nEditSubPtr)\sLCReqdDBLevel[d] +
                    ;                     ", fTmpLevel=" + traceLevel(fTmpLevel))
                    setLevelsAny(nLCAudPtr, d, fTmpLevel, \fLCReqdPan[d])
                  EndIf
                EndIf
              EndIf
            Next d
            
          Case #SCS_LC_ACTION_FREQ, #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
            ; No action
            
        EndSelect
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQL_adjustAllLevels(nDirection)
  PROCNAMEC()
  ; 17/09/2014 11.3.4 added as requested by Christian Peters
  Protected fIncDecDBLevelDelta.f, fIncDecDBLevel.f, fNewDBLevel.f, fNewLevel.f
  Protected d
  Protected u
  Protected bLevelChanged
  Protected fInitDBLevel.f, fNewRelDBLevel.f
  
  debugMsg(sProcName, #SCS_START + ", nDirection=" + nDirection)
  
  If rWQL\bCallSetOrigReqdDBLevels
    WQL_setOrigReqdDBLevels()
    rWQL\bCallSetOrigReqdDBLevels = #False
  EndIf
  
  rWQL\nAdjLevelNetInc + nDirection
  fIncDecDBLevelDelta = ValF(grGeneralOptions\sDBIncrement)
  fIncDecDBLevel = fIncDecDBLevelDelta * rWQL\nAdjLevelNetInc
  debugMsg(sProcName, "rWQL\nAdjLevelNetInc=" + rWQL\nAdjLevelNetInc + ", fIncDecDBLevelDelta=" + StrF(fIncDecDBLevelDelta,2) + ", fIncDecDBLevel=" + StrF(fIncDecDBLevel,2))
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(bLevelChanged, "Required New Levels")
      If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCDevPresent[d]
            If \bLCInclude[d]
              If rWQL\fOrigReqdDBLevel[d] > grLevels\nMinDBLevel
                fNewDBLevel = rWQL\fOrigReqdDBLevel[d] + fIncDecDBLevel
                fNewLevel = convertDBLevelToBVLevel(fNewDBLevel)
                debugMsg(sProcName, "rWQL\fOrigReqdDBLevel[d]=" + StrF(rWQL\fOrigReqdDBLevel[d],2) + ", fNewDBLevel=" + StrF(fNewDBLevel,2) + ", fNewLevel=" + traceLevel(fNewLevel))
                If fNewLevel <= grLevels\fMinBVLevel
                  fNewLevel = #SCS_MINVOLUME_SINGLE
                  debugMsg(sProcName, "grLevels\fMinBVLevel=" + traceLevel(grLevels\fMinBVLevel))
                ElseIf fNewLevel > grLevels\fMaxBVLevel
                  fNewLevel = grLevels\fMaxBVLevel
                  debugMsg(sProcName, "grLevels\fMaxBVLevel=" + traceLevel(grLevels\fMaxBVLevel))
                EndIf
                If \fLCReqdBVLevel[d] <> fNewLevel
                  \fLCReqdBVLevel[d] = fNewLevel
                  \fLCTargetBVLevel[d] = fNewLevel
                  If \nSubState <= #SCS_CUE_READY Or \nSubState >= #SCS_CUE_COMPLETED
                    SLD_setLevel(WQL\sldLCLevel[d], fNewLevel, \fLCTrimFactor[d])
                  EndIf
                  \sLCReqdDBLevel[d] = convertBVLevelToDBString(fNewLevel)
                  SGT(WQL\txtLCDBLevel[d], \sLCReqdDBLevel[d])
                  WQL_setManualOverrideIfReqd(d, 0)
                  bLevelChanged = #True
                EndIf
              EndIf
            EndIf
          EndIf
        Next d
      ElseIf \nLCAction = #SCS_LC_ACTION_RELATIVE
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCDevPresent[d]
            If \bLCInclude[d]
              If rWQL\fOrigReqdDBLevel[d] > grLevels\nMinDBLevel
                fNewRelDBLevel = rWQL\fOrigReqdDBLevel[d] + fIncDecDBLevel
                \sLCReqdDBLevel[d] = convertDBLevelToDBString(fNewRelDBLevel)
                SGT(WQL\txtLCDBLevel[d], \sLCReqdDBLevel[d])
                fInitDBLevel = convertBVLevelToDBLevel(\fLCInitBVLevel[d])
                fNewDBLevel = fInitDBLevel + fNewRelDBLevel
                fNewLevel = convertDBLevelToBVLevel(fNewDBLevel)
                If fNewLevel > grLevels\fMaxBVLevel
                  fNewLevel = grLevels\fMaxBVLevel
                ElseIf fNewLevel < #SCS_MINVOLUME_SINGLE
                  fNewLevel = #SCS_MINVOLUME_SINGLE
                EndIf
                debugMsg(sProcName, "\fLCInitBVLevel[" + d + "]=" + traceLevel(\fLCInitBVLevel[d]) + ", fNewRelDBLevel=" + StrF(fNewRelDBLevel,1) +
                                    ", fInitDBLevel=" + StrF(fInitDBLevel,1) + ", fNewDBLevel=" + StrF(fNewDBLevel,1) + ", fNewLevel=" + traceLevel(fNewLevel))
                WQL_setManualOverrideIfReqd(d, 0)
                bLevelChanged = #True
              EndIf
            EndIf
          EndIf
        Next d
      EndIf
      WQL_adjustPlayingLevelsIfReqd()
      editSetDisplayButtonsL()
      postChangeSubL(u, bLevelChanged)
    EndWith
  EndIf
  
EndProcedure

Procedure WQL_setOrigReqdDBLevels()
  PROCNAMECS(nEditSubPtr)
  Protected d
  
  rWQL\nAdjLevelNetInc = 0
  debugMsg(sProcName, "rWQL\nAdjLevelNetInc=" + rWQL\nAdjLevelNetInc)
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        rWQL\fOrigReqdDBLevel[d] = convertDBStringToDBLevel(\sLCReqdDBLevel[d])
        If \bLCInclude[d]
          debugMsg(sProcName, "rWQL\fOrigReqdDBLevel[" + d + "]=" + StrF(rWQL\fOrigReqdDBLevel[d],2))
        EndIf
      Next d
    EndWith
  EndIf
  
EndProcedure

Procedure WQL_clearManualOverrides()
  PROCNAMEC()
  Protected d
  
  For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
    rWQL\bLvlManualOverride[d] = #False
    rWQL\bPanManualOverride[d] = #False
  Next d

EndProcedure

Procedure WQL_setManualOverrideIfReqd(nDevNo, nLvlOrPan)
  PROCNAMEC()
  ; nLvlOrPan: 0=Level, 1=Pan
  Protected nLCAudPtr, nLCAudState
  Protected d, nFirstDevNo, nLastDevNo
  
  If nEditSubPtr >= 0
    nLCAudPtr = aSub(nEditSubPtr)\nLCAudPtr
    If nLCAudPtr >= 0
      nLCAudState = aAud(nLCAudPtr)\nAudState
      If nLCAudState >= #SCS_CUE_FADING_IN And nLCAudState <= #SCS_CUE_FADING_OUT
        If nDevNo >= 0
          nFirstDevNo = nDevNo
          nLastDevNo = nDevNo
        Else
          nFirstDevNo = 0
          nLastDevNo = #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
        EndIf
        For d = nFirstDevNo To nLastDevNo
          If nLvlOrPan = 0
            rWQL\bLvlManualOverride[d] = #True
          Else
            rWQL\bPanManualOverride[d] = #True
          EndIf
        Next d
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure WQL_setTestButtonText()
  PROCNAMEC()
  Protected nLCAction, sAction.s, sBtnText.s
  Static sTestLevelChange.s, sLevelAndPan.s, sFreq.s, sTempo.s, sPitch.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sTestLevelChange = Lang("WQL", "btnTestLevelChange2")
    sLevelAndPan = Lang("WQL", "LevelAndPan")
    sFreq = Lang("WQL", "Freq")
    sTempo = Lang("WQL", "Tempo")
    sPitch = Lang("WQL", "Pitch")
    bStaticLoaded = #True
  EndIf
  
  With WQL
    nLCAction = aSub(nEditSubPtr)\nLCAction
    Select nLCAction
      Case #SCS_LC_ACTION_FREQ
        sAction = sFreq
      Case #SCS_LC_ACTION_TEMPO
        sAction = sTempo
      Case #SCS_LC_ACTION_PITCH
        sAction = sPitch
      Default
        sAction = sLevelAndPan
    EndSelect
    sBtnText = ReplaceString(sTestLevelChange, "$1", sAction)
    If GetGadgetText(\btnTestLevelChange) <> sBtnText
      SetGadgetText(\btnTestLevelChange, sBtnText)
    EndIf
  EndWith
  
EndProcedure

Procedure WQL_setTempoEtcFields(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nChangeCode, nLength, nMaxAvailableLength, nLCSubPtr, nAudPtr
  Protected fTempoEtcValue.f, nSliderValue, nDefaultSliderValue
  Static sTempo.s, sPitch.s, sFreq.s, sTempoInfo.s, sPitchInfo.s, sFreqInfo.s, sBtnTempoEtcReset.s, bStaticLoaded
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  debugMsg(sProcName, #SCS_START + ", nChangeCode=" + nChangeCode)
  
  If bStaticLoaded = #False
    sFreq = Lang("WQL", "Freq")
    sTempo = Lang("WQL", "Tempo")
    sPitch = Lang("WQL", "Pitch")
    sFreqInfo = Lang("WQL", "FreqInfo")
    sTempoInfo = Lang("WQL", "TempoInfo")
    sPitchInfo = Lang("WQL", "PitchInfo")
    sBtnTempoEtcReset = Lang("Btns","btnTempoEtcReset")
    bStaticLoaded = #True
    nLength = getMaxTextWidth(100, sTempoInfo, sPitchInfo, sFreqInfo)
    nMaxAvailableLength = GadgetWidth(WQL\cntLCTempoEtc) - GadgetX(WQL\lblLCTempoEtcInfo) - 4
    If nLength > nMaxAvailableLength
      nLength = nMaxAvailableLength
    EndIf
    ResizeGadget(WQL\lblLCTempoEtcInfo, #PB_Ignore, #PB_Ignore, nLength, #PB_Ignore)
  EndIf
  
  With aSub(pSubPtr)
    fTempoEtcValue = \fLCActionValue
    nAudPtr = \nLCAudPtr
    nChangeCode = getChangeCodeForLCAction(\nLCAction)
    debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCAction=" + decodeLCAction(\nLCAction) + ", nChangeCode=" + nChangeCode)
    
    setTempoEtcConstants(nChangeCode)
    
    Select nChangeCode
      Case #SCS_CHANGE_FREQ
        debugMsg(sProcName, "#SCS_CHANGE_FREQ")
        nDefaultSliderValue = 100
        SGT(WQL\lblLCTempoEtcValue, sFreq)
        SGT(WQL\lblLCTempoEtcInfo, sFreqInfo)
        SLD_setSliderType(WQL\sldLCTempoEtcValue, #SCS_ST_FREQ)
        SGT(WQL\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "100%"))
        
      Case #SCS_CHANGE_TEMPO
        debugMsg(sProcName, "#SCS_CHANGE_TEMPO")
        nDefaultSliderValue = 100
        SGT(WQL\lblLCTempoEtcValue, sTempo)
        SGT(WQL\lblLCTempoEtcInfo, sTempoInfo)
        SLD_setSliderType(WQL\sldLCTempoEtcValue, #SCS_ST_TEMPO)
        SGT(WQL\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "100%"))
        
      Case #SCS_CHANGE_PITCH
        debugMsg(sProcName, "#SCS_CHANGE_PITCH")
        nDefaultSliderValue = 0
        SGT(WQL\lblLCTempoEtcValue, sPitch)
        SGT(WQL\lblLCTempoEtcInfo, sPitchInfo)
        SLD_setSliderType(WQL\sldLCTempoEtcValue, #SCS_ST_PITCH)
        SGT(WQL\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "0"))
        
      Default
        debugMsg0(sProcName, "Other ChangeCode")

    EndSelect
  EndWith
  
  With grTempoEtc
    \nTempoEtcCurrChangeCode = nChangeCode
    \fTempoEtcDefaultValue = nDefaultSliderValue / \fTempoEtcFactor
    debugMsg(sProcName, "nDefaultSliderValue=" + nDefaultSliderValue + ", \fTempoEtcFactor=" + StrF(\fTempoEtcFactor, \nTempoEtcDecimals) + ", \fTempoEtcDefaultValue=" + StrF(\fTempoEtcDefaultValue, \nTempoEtcDecimals))
    \nTempoEtcDefaultSliderValue = nDefaultSliderValue
    \fTempoEtcOrigValue = fTempoEtcValue
    \fTempoEtcCurrValue = fTempoEtcValue
    
    SLD_setMin(WQL\sldLCTempoEtcValue, \fTempoEtcMinValue * \fTempoEtcFactor)
    SLD_setMax(WQL\sldLCTempoEtcValue, \fTempoEtcMaxValue * \fTempoEtcFactor)
    nSliderValue = \fTempoEtcCurrValue * \fTempoEtcFactor
    debugMsg(sProcName, "grTempoEtc\fTempoEtcCurrValue=" + StrF(\fTempoEtcCurrValue, \nTempoEtcDecimals) + ", \fTempoEtcFactor=" + StrF(\fTempoEtcFactor, \nTempoEtcDecimals) + ", nSliderValue=" + nSliderValue)
    debugMsg(sProcName, "SLD_getMin(WQL\sldLCTempoEtcValue)=" + SLD_getMin(WQL\sldLCTempoEtcValue) + ", SLD_getMax(WQL\sldLCTempoEtcValue)=" + SLD_getMax(WQL\sldLCTempoEtcValue))
    If nSliderValue < SLD_getMin(WQL\sldLCTempoEtcValue) Or nSliderValue > SLD_getMax(WQL\sldLCTempoEtcValue)
      nSliderValue = \nTempoEtcDefaultSliderValue
    EndIf
    ; debugMsg0(sProcName, "\fTempoEtcCurrValue=" + StrF(\fTempoEtcCurrValue) + ", \fTempoEtcFactor=" + \fTempoEtcFactor + ", nSliderValue=" + nSliderValue)
    ; nb SLD_setValue() must be called AFTER calling SLD_setSliderType() as this is used in SLD_drawTickLines()
    debugMsg(sProcName, "calling SLD_setValue(WQL\sldLCTempoEtcValue, " + nSliderValue + ")")
    SLD_setValue(WQL\sldLCTempoEtcValue, nSliderValue)
    SGT(WQL\txtLCTempoEtcValue, StrF(nSliderValue / \fTempoEtcFactor, \nTempoEtcDecimals))
    
    If \fTempoEtcCurrValue <> \fTempoEtcDefaultValue
      setEnabled(WQL\btnTempoEtcReset, #True)
    Else
      setEnabled(WQL\btnTempoEtcReset, #False)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_sldLCTempoEtcValue_Common()
  PROCNAMECS(nEditSubPtr)
  Protected nTempoEtcSliderValue
  
  With grTempoEtc
    nTempoEtcSliderValue = SLD_getValue(WQL\sldLCTempoEtcValue)
    \fTempoEtcCurrValue = nTempoEtcSliderValue / \fTempoEtcFactor
    If \fTempoEtcCurrValue <> \fTempoEtcOrigValue
      SGT(WQL\txtLCTempoEtcValue, StrF(\fTempoEtcCurrValue, \nTempoEtcDecimals))
    EndIf
    If \fTempoEtcCurrValue <> \fTempoEtcDefaultValue
      setEnabled(WQL\btnTempoEtcReset, #True)
    Else
      setEnabled(WQL\btnTempoEtcReset, #False)
    EndIf
  EndWith
  
EndProcedure

Procedure WQL_txtTempoEtcValue_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nTempoEtcSliderValue, sCurrValue.s, fCurrValue.f, sTmpValue.s
  Protected sErrorMsg.s
  
  With grTempoEtc
    sCurrValue = Trim(GGT(WQL\txtLCTempoEtcValue))
    If sCurrValue
      If validateNumberField(sCurrValue)
        fCurrValue = ValF(sCurrValue)
        If fCurrValue < \fTempoEtcMinValue Or fCurrValue > \fTempoEtcMaxValue
          sErrorMsg = LangPars("Errors", "MustBeBetween", GGT(WQL\lblLCTempoEtcValue), StrF(\fTempoEtcMinValue, \nTempoEtcDecimals), StrF(\fTempoEtcMaxValue, \nTempoEtcDecimals))
        EndIf
      Else
        sErrorMsg = LangPars("Errors", "MustBeBetween", GGT(WQL\lblLCTempoEtcValue), StrF(\fTempoEtcMinValue, \nTempoEtcDecimals), StrF(\fTempoEtcMaxValue, \nTempoEtcDecimals))
      EndIf
    Else
      sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WQL\lblLCTempoEtcValue))
    EndIf
    
    If sErrorMsg
      debugMsg(sProcName, sErrorMsg)
      scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
    
    \fTempoEtcCurrValue = fCurrValue
    nTempoEtcSliderValue = \fTempoEtcCurrValue * \fTempoEtcFactor
    SLD_setValue(WQL\sldLCTempoEtcValue, nTempoEtcSliderValue)
    ; re-display this value if required
    sTmpValue = StrF(\fTempoEtcCurrValue, \nTempoEtcDecimals)
    If sTmpValue <> sCurrValue
      SGT(WQL\txtLCTempoEtcValue, sTmpValue)
    EndIf
    If \fTempoEtcCurrValue <> \fTempoEtcDefaultValue
      setEnabled(WQL\btnTempoEtcReset, #True)
    Else
      setEnabled(WQL\btnTempoEtcReset, #False)
    EndIf
  EndWith
  ProcedureReturn #True
  
EndProcedure

Procedure WQL_btnTempoEtcReset_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubF(\fLCActionValue, GGT(WQL\lblLCTempoEtcValue))
    \fLCActionValue = grTempoEtc\fTempoEtcDefaultValue
    grTempoEtc\fTempoEtcCurrValue = \fLCActionValue
    SLD_setValue(WQL\sldLCTempoEtcValue, \fLCActionValue * grTempoEtc\fTempoEtcFactor)
    SGT(WQL\txtLCTempoEtcValue, StrF(\fLCActionValue, grTempoEtc\nTempoEtcDecimals))
    setEnabled(WQL\btnTempoEtcReset, #False)
    postChangeSubF(u, \fLCActionValue)
  EndWith
  
EndProcedure

Procedure WQL_applyTempoEtcFields()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  With grTempoEtc
    u = preChangeSubF(\fTempoEtcOrigValue, GGT(WQL\lblLCTempoEtcValue))
    aSub(nEditSubPtr)\fLCActionValue = \fTempoEtcCurrValue
    postChangeSubF(u, \fTempoEtcCurrValue)
  EndWith
  
EndProcedure

Procedure.f WQL_getDefaultLCActionValue(nLCAction)
  PROCNAMEC()
  Protected fDefaultValue.f
  
  Select nLCAction
;     Case #SCS_LC_ACTION_ABSOLUTE
;       fDefaultValue = 0.0
;     Case #SCS_LC_ACTION_RELATIVE
;       fDefaultValue = 0.0
    Case #SCS_LC_ACTION_FREQ
      fDefaultValue = 1.0
    Case #SCS_LC_ACTION_TEMPO
      fDefaultValue = 1.0
    Case #SCS_LC_ACTION_PITCH
      fDefaultValue = 0.0
  EndSelect
  
  debugMsg(sProcName, "nLCAction=" + decodeLCAction(nLCAction) + ", fDefaultValue=" + StrF(fDefaultValue))
  ProcedureReturn fDefaultValue
  
EndProcedure

Procedure WQL_changeLCLevel(pCaller, nDevIndex)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sReqdDBLevel.s, fBVLevel.f, d
  Protected nLCAudPtr, nLCAudState
  
  ; debugMsg(sProcName, #SCS_START +  ", pCaller=" + pCaller + ", nDevIndex=" + nDevIndex)
  
  Select pCaller
    Case 1 ; called from slider event
      fBVLevel = SLD_getLevel(WQL\sldLCLevel[nDevIndex])
      sReqdDBLevel = convertBVLevelToDBString(fBVLevel)
    Case 2 ; called from text box event
      sReqdDBLevel = Trim(GGT(WQL\txtLCDBLevel[nDevIndex]))
      fBVLevel = convertDBStringToBVLevel(sReqdDBLevel)
  EndSelect
  
  WQL_setManualOverrideIfReqd(nDevIndex, 0) ; NB '0' = Level
  
  With aSub(nEditSubPtr)
    nLCAudPtr = \nLCAudPtr
    If nLCAudPtr >= 0
      nLCAudState = aAud(nLCAudPtr)\nAudState
    EndIf
    
    u = preChangeSubS(\sLCReqdDBLevel[nDevIndex], rWQL\slblReqdNewLevel, -5, #SCS_UNDO_ACTION_CHANGE, nDevIndex)
    \sLCReqdDBLevel[nDevIndex] = sReqdDBLevel
    \fLCReqdBVLevel[nDevIndex] = fBVLevel
    Select pCaller
      Case 1 ; called from slider event
        SetGadgetText(WQL\txtLCDBLevel[nDevIndex], sReqdDBLevel)
      Case 2 ; called from text box event
        WQL_fcTxtLCDBLevel(nDevIndex) ; sets slider value if 'absolute'
    EndSelect
    editSetDisplayButtonsL()
    postChangeSubS(u, \sLCReqdDBLevel[nDevIndex], -5, nDevIndex)
    
    WQL_adjustPlayingLevelsIfReqd()
    WQL_fcLCSameLevel()
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQL_changeLCPan(pCaller, nDevIndex)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected fNewPan.f, d
  Protected nLCAudPtr, nLCAudState
  
  ; debugMsg(sProcName, #SCS_START +  ", pCaller=" + pCaller + ", nDevIndex=" + nDevIndex)
  
  Select pCaller
    Case 1 ; called from slider event
      fNewPan = panSliderValToSingle(SLD_getValue(WQL\sldLCPan[nDevIndex]))
    Case 2 ; called from text box event
      fNewPan = panStringToSingle(GGT(WQL\txtLCPan[nDevIndex]))
    Case 3 ; ; called from center button event
      fNewPan = #SCS_PANCENTRE_SINGLE
  EndSelect
  
  WQL_setManualOverrideIfReqd(nDevIndex, 1) ; NB '1' = Pan
  
  With aSub(nEditSubPtr)
    nLCAudPtr = \nLCAudPtr
    If nLCAudPtr >= 0
      nLCAudState = aAud(nLCAudPtr)\nAudState
    EndIf
    
    u = preChangeSubF(\fLCReqdPan[nDevIndex], "Required New Pan", -5, #SCS_UNDO_ACTION_CHANGE, nDevIndex)
    \fLCReqdPan[nDevIndex] = fNewPan
    Select pCaller
      Case 1 ; called from slider event
        SetGadgetText(WQL\txtLCPan[nDevIndex], panSingleToString(fNewPan))
      Case 2 ; called from text box event
        SLD_setValue(WQL\sldLCPan[nDevIndex], panToSliderValue(fNewPan))
      Case 3 ; called from center button event
        SLD_setValue(WQL\sldLCPan[nDevIndex], panToSliderValue(fNewPan))
        SetGadgetText(WQL\txtLCPan[nDevIndex], panSingleToString(fNewPan))
    EndSelect
    If fNewPan = #SCS_PANCENTRE_SINGLE
      setEnabled(WQL\btnLCCenter[nDevIndex], #False)
    Else
      setEnabled(WQL\btnLCCenter[nDevIndex], #True)
    EndIf
    
    If \bLCSameLevel
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \bLCInclude[d]
          ; debugMsg0(sProcName, "aAud(" + getAudLabel(nLCAudPtr) + ")\bDisplayPan[" + d + "]=" + strB(aAud(nLCAudPtr)\bDisplayPan[d]))
          If d <> nDevIndex
            If aAud(nLCAudPtr)\bDisplayPan[d]
              \fLCReqdPan[d] = fNewPan
              SLD_setValue(WQL\sldLCPan[d], panToSliderValue(fNewPan))
              SetGadgetText(WQL\txtLCPan[d], panSingleToString(fNewPan))
              If nLCAudState >= #SCS_CUE_FADING_IN And nLCAudState <= #SCS_CUE_FADING_OUT
                setLevelsAny(nLCAudPtr, d, \fLCReqdBVLevel[d], fNewPan)
              EndIf
            EndIf
          EndIf
        EndIf
      Next d
    EndIf
    
    editSetDisplayButtonsL()
    postChangeSubF(u, \fLCReqdPan[nDevIndex], -5, nDevIndex)

    ; WQL_fcLCSameLevel()
    WQL_adjustPlayingLevelsIfReqd()
    WQL_fcLCSameLevel()
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF