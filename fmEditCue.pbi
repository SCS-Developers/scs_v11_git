; File: fmEditCue.pbi

EnableExplicit

Procedure WEC_cboActivationMethod_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected d, i, j, n, bCueHotkey, bCueExtAct, bCallableCue, bExtFaderDevSet
  Protected bChanged
  Protected u, u2
  Protected nListIndex
  Protected nOldActivationMethod, nNewActivationMethod, nAutoActPosn
  Protected bOldActivationMethodMayBeCalledByCallCue, bNewActivationMethodMayBeCalledByCallCue ; Added 11Oct2022 11.9.6
  Protected bChangedOCM
  Protected sCueMarkerNamefromCBO.s
  Protected sErrorMsg.s
  Static nChangeFlag

  If gbInDisplayCue
    ProcedureReturn
  EndIf

  debugMsg(sProcName, #SCS_START)
  
  bChanged = #False
  CheckSubInRange(nEditCuePtr, ArraySize(aCue()), "aCue()") ; Added 17Sep2022 11.9.5.1af following email from Scott Seigwald where procedure crashed with a memory error on trying to access aCue(nEditCuePtr)\nActivationMethod
                                                            ; (I couldn't reproduce the error)
  With aCue(nEditCuePtr)
    
    nOldActivationMethod = \nActivationMethod
    nNewActivationMethod = getCurrentItemData(WEC\cboActivationMethod)
    If nNewActivationMethod = nOldActivationMethod
      ProcedureReturn
    EndIf
    
    If nOldActivationMethod & #SCS_ACMETH_HK_BIT Or nOldActivationMethod & #SCS_ACMETH_HK_BIT Or nOldActivationMethod = #SCS_ACMETH_CALL_CUE
      bOldActivationMethodMayBeCalledByCallCue = #True
    EndIf
    If nNewActivationMethod & #SCS_ACMETH_HK_BIT Or nNewActivationMethod & #SCS_ACMETH_HK_BIT Or nNewActivationMethod = #SCS_ACMETH_CALL_CUE
      bNewActivationMethodMayBeCalledByCallCue = #True
    EndIf
    
    debugMsg(sProcName, "nOldActivationMethod=" + decodeActivationMethod(nOldActivationMethod) + ", nNewActivationMethod=" + decodeActivationMethod(nNewActivationMethod))
    If nOldActivationMethod = #SCS_ACMETH_MTC
      j = \nFirstSubIndex
      While j >= 0
        If aSub(j)\nSubStart = #SCS_SUBSTART_REL_MTC
          sErrorMsg = LangPars("Errors", "CannotChangeAcMethMTC", decodeActivationMethodL(nOldActivationMethod), getSubLabel(j), decodeSubStartL(aSub(j)\nSubStart))
          Break
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
    
    If Len(sErrorMsg) = 0
      If bOldActivationMethodMayBeCalledByCallCue And (bNewActivationMethodMayBeCalledByCallCue = #False) ; Changed 11Oct2022 11.9.6
        For i = 1 To gnLastCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\sSubType = "Q"
              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nCallCuePtr=" + getCueLabel(aSub(j)\nCallCuePtr))
              If aSub(j)\nCallCuePtr = nEditCuePtr ; Test added 28Jun2022 11.9.3ae
                sErrorMsg = LangPars("Errors", "CannotChangeAcMethCallable", decodeActivationMethodL(nOldActivationMethod), getSubLabel(j), \sCue)
                Break 2 ; Break j, i
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        Next i
      EndIf
    EndIf
    
    If Len(sErrorMsg) = 0
      If nNewActivationMethod = #SCS_ACMETH_EXT_FADER
        For d = 0 To grProd\nMaxCueCtrlLogicalDev
          If grProd\aCueCtrlLogicalDevs(d)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
            If grProd\aCueCtrlLogicalDevs(d)\aMidiCommand[#SCS_MIDI_EXT_FADER]\nCmd > 0
              bExtFaderDevSet = #True
              Break
            EndIf
          EndIf
        Next d
        If bExtFaderDevSet = #False
          sErrorMsg = Lang("Errors", "CannotSetExtFader1")
        Else
          j = \nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeK
              If aSub(j)\nLTEntryType <> #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                sErrorMsg = LangPars("Errors", "CannotSetExtFader2", getSubLabel(j), decodeLTEntryTypeL(aSub(j)\nLTEntryType), decodeLTEntryTypeL(#SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS))
                Break
              ElseIf aSub(j)\bChase
                sErrorMsg = LangPars("Errors", "CannotSetExtFader3", getSubLabel(j))
                Break
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      EndIf
    EndIf
    
    If Len(sErrorMsg) = 0
      If nNewActivationMethod = #SCS_ACMETH_LTC
        If grProd\nMaxLiveInputLogicalDev < 0
          sErrorMsg = LangPars("Errors", "NoLTCInputDev", getCueLabel(nEditCuePtr),
                               decodeActivationMethodL(nNewActivationMethod),
                               Trim(GGT(WEC\lblLTCInputDev)))
        EndIf
      EndIf
    EndIf

    If sErrorMsg
      valErrMsg(WEC\cboActivationMethod, sErrorMsg)
      setComboBoxByData(WEC\cboActivationMethod, nOldActivationMethod)
      ProcedureReturn #False
    EndIf
    bChanged = #True
    ; NB use Static nChangeFlag instead of \nActivationMethod to force the change to be recorded in the undo list even if the user changes back to the original value,
    ; eg changed from autostart to manual and then back to autostart. The reason for this is that changing back to autostart does not reinstate autostart time, etc,
    ; so the undo list MUST be retained.
    u = preChangeCueL(nChangeFlag, GGT(WEC\lblActivationHdg), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_MAIN)
    \nActivationMethod = nNewActivationMethod
    \nActivationMethodReqd = \nActivationMethod
    ; -- TBC Project -- CSS
    setVisibleAndEnabled(WEC\cntStandby, #True)
    setVisibleAndEnabled(WEC\lblStandby, #True)
    setVisibleAndEnabled(WEC\cboStandby, #True)
    
    If nNewActivationMethod = #SCS_ACMETH_AUTO Or nNewActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
      If bChanged
        \nAutoActTime = 0
        SGT(WEC\txtAutoActivateTime, timeToString(\nAutoActTime))
        
        ; \nAutoActPosn = #SCS_ACPOSN_AE   ; 'end'
        debugMsg(sProcName, "grEditMem\nLastAutoActPosn=" + decodeAutoActPosn(grEditMem\nLastAutoActPosn))
        \nAutoActPosn = grEditMem\nLastAutoActPosn
        nListIndex = indexForComboBoxData(WEC\cboAutoActivatePosn, \nAutoActPosn, 0)
        SGS(WEC\cboAutoActivatePosn, nListIndex)
        WEC_fcActivatePosn()  ; nb populates WEC\cboAutoActivateCue
        
        \nAutoActCueSelType = grCueDef\nAutoActCueSelType
        \sAutoActCue = grCueDef\sAutoActCue
        \nAutoActCuePtr = grCueDef\nAutoActCuePtr
        nListIndex = 0
        If \nAutoActPosn <> #SCS_ACPOSN_OCM
          If CountGadgetItems(WEC\cboAutoActivateCue) > 1
            nListIndex = 1
          EndIf
        EndIf
        SGS(WEC\cboAutoActivateCue, nListIndex)
        WEC_cboAutoActivateCue_Click()
        
      EndIf
    Else
      \nAutoActTime = grCueDef\nAutoActTime
      ; \nAutoActPosn = grCueDef\nAutoActPosn
      \nAutoActPosn = grEditMem\nLastAutoActPosn
      \nAutoActCueSelType = grCueDef\nAutoActCueSelType
      \sAutoActCue = grCueDef\sAutoActCue
      \nAutoActCuePtr = grCueDef\nAutoActCuePtr
    EndIf
    
    If nNewActivationMethod <> #SCS_ACMETH_HK_STEP
      ; \sHotkey = grCueDef\sHotkey ; Deleted 20Apr2024 11.10.2cb as this was clearing the selected hotkey even if changing from, say, trigger to toggle
      \nCueHotkeyStepNo = grCueDef\nCueHotkeyStepNo
    EndIf
    
    If nNewActivationMethod & #SCS_ACMETH_HK_BIT
      \bHotkey = #True
      loadHotkeyArray()
      WEC_loadHotkeyCBO(\sHotkey) ; Added 28Feb2022 11.9.1ac
    Else
      If \bHotkey
        ; was hotkey but not now
        \bHotkey = #False
        \sHotkey = ""
        \sHotkeyLabel = ""
        loadHotkeyArray()
        WEC_loadHotkeyCBO(\sHotkey)
        If GetGadgetText(WEC\txtHotkeyLabel)
          SGT(WEC\txtHotkeyLabel, "")
        EndIf
      EndIf
    EndIf
    
    If nNewActivationMethod & #SCS_ACMETH_EXT_BIT
      \bExtAct = #True
    Else
      \bExtAct = #False
    EndIf
    
    If nNewActivationMethod = #SCS_ACMETH_CALL_CUE
      \bCallableCue = #True
    Else
      \bCallableCue = #False
    EndIf
    
    If nNewActivationMethod = #SCS_ACMETH_EXT_FADER
      setGadgetItemByData(WEC\cboExtFaderCC, \nExtFaderCC)
    EndIf
    
    ; propogate \bHotkey, \bExtAct and \bCallableCue down to subs
    bCueHotkey = \bHotkey
    bCueExtAct = \bExtAct
    bCallableCue = \bCallableCue
    j = \nFirstSubIndex
    While j >= 0
      If (aSub(j)\bHotkey <> bCueHotkey) Or (aSub(j)\bExtAct <> bCueExtAct) Or (aSub(j)\bCallableCue <> bCallableCue)
        u2 = preChangeSubL(#True, Trim(GetGadgetText(WEC\lblActivationHdg)), j)
        aSub(j)\bHotkey = bCueHotkey
        aSub(j)\bExtAct = bCueExtAct
        aSub(j)\bCallableCue = bCallableCue
        If aSub(j)\bSubTypeK
          calcPLTotalTime(j)
          aSub(j)\nSubDuration = getSubLength(j, #True) ; may be cleared if changing to 'external fader'
          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubDuration=" + aSub(j)\nSubDuration)
        EndIf
        postChangeSubL(u2, #False, j)
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    
    If nNewActivationMethod = #SCS_ACMETH_TIME
      ; -- TBC Project -- CSS
      setVisibleAndEnabled(WEC\cntStandby, #False)
      setVisibleAndEnabled(WEC\lblStandby, #False)
      setVisibleAndEnabled(WEC\cboStandby, #False)
      ; Added 2Nov2024 11.10.6bc
      If nOldActivationMethod <> nNewActivationMethod
        For n = 0 To #SCS_MAX_TIME_PROFILE
          \sTimeProfile[n] = grProd\sTimeProfile[n]
        Next n
      EndIf
      ; End added 2Nov2024 11.10.6bc
      setTimeBasedCues(nEditCuePtr)
    EndIf
    
    If nOldActivationMethod = #SCS_ACMETH_MTC Or nNewActivationMethod = #SCS_ACMETH_MTC
      loadArrayCueOrSubForMTC()
    EndIf
    
    setDerivedCueFields(nEditCuePtr, #True) ; set cue colors
    WED_setCueNodeText(nEditCuePtr) ; colors node
    
    WEC_fcActivationMethod()
    
    If bChanged
      loadCueMarkerArrays()
      setDelayHideInds()
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
      WMN_displayOrHideHotkeys()
      loadCueBrackets()
      nChangeFlag + 1
      postChangeCueL(u, nChangeFlag)
      
      If nOldActivationMethod = #SCS_ACMETH_EXT_FADER Or nNewActivationMethod = #SCS_ACMETH_EXT_FADER
        If nEditSubPtr >= 0
          If aSub(nEditSubPtr)\bSubTypeK
            ; re-display the sub-cue if the cue's activation method has changed to or from external fader
            WQK_displaySub(nEditSubPtr)
          EndIf
        EndIf
      EndIf
    EndIf ; EndIf bChanged
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_cboAutoActivatePosn_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected u

  If gbInDisplayCue
    ProcedureReturn
  EndIf

  debugMsg(sProcName, #SCS_START)

  With aCue(nEditCuePtr)
    If \nAutoActPosn = #SCS_ACPOSN_OCM
      u = preChangeCueL(\nAutoActPosn, Lang("WEC", "cboAutoActivatePosn") + " OCM")
    Else
      u = preChangeCueL(\nAutoActPosn, Lang("WEC", "cboAutoActivatePosn"))
    EndIf
    \nAutoActPosn = getCurrentItemData(WEC\cboAutoActivatePosn)
    
    WEC_fcActivatePosn()  ; nb populates WEC\cboAutoActivateCue
    
    setDelayHideInds()
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
    postChangeCueL(u, \nAutoActPosn)
    
    grEditMem\nLastAutoActPosn = \nAutoActPosn
    
  EndWith

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_cboAutoActivateCue_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected i, n, sTmp.s, nCuePtr, nThisAutoActCueSelType
  Protected u

  If gbInDisplayCue
    ProcedureReturn
  EndIf

  debugMsg(sProcName, #SCS_START)
  
  With aCue(nEditCuePtr)
    nThisAutoActCueSelType = getCurrentItemData(WEC\cboAutoActivateCue) ; nb the 'data' property in WEC\cboAutoActivateCue will have been set to #SCS_ACCUESEL_DEFAULT, #SCS_ACCUESEL_PREV or #SCS_ACCUESEL_CM by addGadgetItemWithData()
    If nThisAutoActCueSelType = #SCS_ACCUESEL_CM
      u = preChangeCueS(decodeAutoActCueSelType(\nAutoActCueSelType) + \sAutoActCue + \sAutoActCueMarkerName, "Auto-Activate Controlling Cue Marker")
    Else
      u = preChangeCueS(decodeAutoActCueSelType(\nAutoActCueSelType) + \sAutoActCue, "Auto-Activate Controlling Cue")
    EndIf
    \nAutoActCueSelType = nThisAutoActCueSelType
    sTmp = GetGadgetText(WEC\cboAutoActivateCue)
    nCuePtr = -1
    Select \nAutoActCueSelType
      Case #SCS_ACCUESEL_DEFAULT
        For i = 1 To gnLastCue
          If sTmp = buildCueForCBO(i)
            nCuePtr = i
            Break
          EndIf
        Next i
        If nCuePtr >= 0
          \sAutoActCue = aCue(nCuePtr)\sCue
          \nAutoActCuePtr = nCuePtr
        EndIf
        
      Case #SCS_ACCUESEL_PREV
        setCuePtrForAutoStartPrevCueType(nEditCuePtr)
        
      Case #SCS_ACCUESEL_CM
        ; not used for cue files SAVED by SCS 11.8.2 or later as cue activation method #SCS_ACMETH_OCM supercedes this
        For n = 0 To gnMaxCueMarkerInfo
          If gaCueMarkerInfo(n)\bOCMAvailable
            If gaCueMarkerInfo(n)\sCueMarkerDisplayInfo = sTmp
              \sAutoActCue = gaCueMarkerInfo(n)\sHostCue
              \nAutoActCuePtr = gaCueMarkerInfo(n)\nHostCuePtr
              \nAutoActSubNo = gaCueMarkerInfo(n)\nHostSubNo
              \nAutoActSubId = gaCueMarkerInfo(n)\nHostSubId
              \sAutoActCueMarkerName = gaCueMarkerInfo(n)\sCueMarkerName
              Break
            EndIf
          EndIf
        Next n
        loadCueMarkerArrays()
;         debugMsg(sProcName, "calling loadOCMMatrix(#True)")
;         loadOCMMatrix(#True)
;         debugMsg(sProcName, "calling loadCueMarkerFileArray()")
;         loadCueMarkerFileArray()
        
    EndSelect
    
    setDelayHideInds()
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
    If nThisAutoActCueSelType = #SCS_ACCUESEL_CM
      postChangeCueS(u, decodeAutoActCueSelType(\nAutoActCueSelType) + \sAutoActCue + \sAutoActCueMarkerName)
    Else
      postChangeCueS(u, decodeAutoActCueSelType(\nAutoActCueSelType) + \sAutoActCue)
    EndIf
    
    If \nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT
      If \sAutoActCue = \sCue
        ensureSplashNotOnTop()
        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotSelectItself", \sCue, Lang("WEC", "AutoActivateCue")), #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEC_cboAutoActivateMarker_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected nCueMarkerId, n
  Protected u

  If gbInDisplayCue
    ProcedureReturn
  EndIf

  ; debugMsg(sProcName, #SCS_START)
  
  With aCue(nEditCuePtr)
    nCueMarkerId = getCurrentItemData(WEC\cboAutoActivateMarker)
    debugMsg(sProcName, "aCue(" + getCueLabel(nEditCuePtr) + ")\nAutoActCueMarkerId=" + \nAutoActCueMarkerId + ", getCurrentItemData(WEC\cboAutoActivateMarker)=" + getCurrentItemData(WEC\cboAutoActivateMarker))
    If nCueMarkerId <> \nAutoActCueMarkerId
      u = preChangeCueL(\nAutoActCueMarkerId, "Auto-Activate Controlling Cue Marker")
      \nAutoActCueMarkerId = nCueMarkerId
      For n = 0 To gnMaxCueMarkerInfo
        If gaCueMarkerInfo(n)\nCueMarkerId = nCueMarkerId
          \sAutoActCue = gaCueMarkerInfo(n)\sHostCue
          \nAutoActCuePtr = gaCueMarkerInfo(n)\nHostCuePtr
          \nAutoActSubNo = gaCueMarkerInfo(n)\nHostSubNo
          \nAutoActSubId = gaCueMarkerInfo(n)\nHostSubId
          \nAutoActAudNo = gaCueMarkerInfo(n)\nHostAudNo
          \nAutoActAudId = gaCueMarkerInfo(n)\nHostAudId
          \sAutoActCueMarkerName = gaCueMarkerInfo(n)\sCueMarkerName
          Break
        EndIf
      Next n
      loadCueMarkerArrays()
      setDelayHideInds()
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
      postChangeCueL(u, \nAutoActCueMarkerId)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEC_cboHotkey_Click()
  PROCNAMECQ(nEditCuePtr)
;   Protected sHoldHotkey.s, n, nListIndex, sHotkey.s
  Protected nDataValue
  
  debugMsg(sProcName, #SCS_START)
  
  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aCue(nEditCuePtr)
    If WEC_valHotkey() ; includes calls to preChangeCue and postChangeCue
      WEC_fcHotkey()
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
      If GGS(WEC\cboHotkey) > 0
        SAG(WEC\txtHotkeyLabel)
      EndIf
    Else
      ; validation failed, so reinstate
      nDataValue = WEC_calcDataValueForCueHotkey(nEditCuePtr)
      setComboBoxByData(WEC\cboHotkey, nDataValue)
;       sHoldHotkey = \sHotkey
;       nListIndex = -1
;       If sHoldHotkey
;         For n = 0 To CountGadgetItems(WEC\cboHotkey) - 1
;           sHotkey = Trim(StringField(GetGadgetItemText(WEC\cboHotkey, n), 1, " "))
;           If sHotkey = sHoldHotkey
;             nListIndex = n
;             \sHotkey = sHoldHotkey
;             Break
;           EndIf
;         Next n
;       EndIf
;       SGS(WEC\cboHotkey, nListIndex)
    EndIf
  EndWith
EndProcedure

Procedure WEC_cboHotkeyBank_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected nNewBank, sHoldHotkey.s, n, nListIndex, sHotkey.s
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aCue(nEditCuePtr)
    nNewBank = getCurrentItemData(WEC\cboHotkeyBank, 0)
    If nNewBank <> \nHotkeyBank
      sHoldHotkey = \sHotkey
      u = preChangeCueL(\nHotkeyBank, GetGadgetText(WEC\lblHotkeyBank))
      \nHotkeyBank = nNewBank
      \sHotkey = ""
      WEC_loadHotkeyCBO(\sHotkey)
      nListIndex = -1
      If sHoldHotkey
        For n = 0 To CountGadgetItems(WEC\cboHotkey) - 1
          sHotkey = Trim(StringField(GetGadgetItemText(WEC\cboHotkey, n), 1, " "))
          If sHotkey = sHoldHotkey
            nListIndex = n
            \sHotkey = sHoldHotkey
            Break
          EndIf
        Next n
      EndIf
      SGS(WEC\cboHotkey, nListIndex)
      postChangeCueL(u, \nHotkeyBank)
    EndIf
  EndWith
  
EndProcedure

Procedure WEC_cboStandby_Click()
  Protected u

  With aCue(nEditCuePtr)
    u = preChangeCueL(\nStandby, GetGadgetText(WEC\lblStandby))
    \nStandby = getCurrentItemData(WEC\cboStandby)
    WMN_updateToolBar()
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    postChangeCueL(u, \nStandby)
  EndWith
EndProcedure

Procedure WEC_cboExtFaderCC_Click()
  Protected u

  With aCue(nEditCuePtr)
    u = preChangeCueL(\nExtFaderCC, GetGadgetText(WEC\lblExtFaderCC))
    \nExtFaderCC = getCurrentItemData(WEC\cboExtFaderCC)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    postChangeCueL(u, \nExtFaderCC)
  EndWith
EndProcedure

Procedure WEC_chkCueEnabled_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  Protected bMyCueEnabled
  Protected sMsgStart.s
  
  bMyCueEnabled = getOwnState(WEC\chkCueEnabled)
  If bMyCueEnabled = #False
    sMsgStart = LangPars("Errors", "CannotDisableCue3", aCue(nEditCuePtr)\sCue)
    If checkDelCueRI(nEditCuePtr, sMsgStart, 1) = #False
      setOwnState(WEC\chkCueEnabled, aCue(nEditCuePtr)\bCueEnabled)
      ProcedureReturn
    EndIf
  Else
    sMsgStart = LangPars("Errors", "CannotEnableCue3", aCue(nEditCuePtr)\sCue)
    If checkDelCueRI(nEditCuePtr, sMsgStart, 2) = #False
      setOwnState(WEC\chkCueEnabled, aCue(nEditCuePtr)\bCueEnabled)
      ProcedureReturn
    EndIf
  EndIf
  
  With aCue(nEditCuePtr)
    debugMsg(sProcName, "aCue(nEditCuePtr)\bCueEnabled=" + strB(\bCueEnabled))
    u = preChangeCueL(\bCueEnabled, getOwnText(WEC\chkCueEnabled))
    \bCueEnabled = getOwnState(WEC\chkCueEnabled)
    \bCueCurrentlyEnabled = \bCueEnabled
    WEC_fcEnabled()
    ; WED_setCueNodeText(nEditCuePtr)
    redoCueListTree(\nNodeKey)
    setCuePtrs(#False)
    loadHotkeyArray()
    loadCueMarkerArrays()
    debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)")
    samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    debugMsg(sProcName, "calling setCueToGo()")
    setCueToGo()
    debugMsg(sProcName, "aCue(nEditCuePtr)\bCueEnabled=" + strB(\bCueEnabled))
    postChangeCueL(u, \bCueEnabled)
    If \nActivationMethod = #SCS_ACMETH_MTC
      setMTCStartTimesForCueSubs(nEditCuePtr)
      loadArrayCueOrSubForMTC()
    EndIf
    WMN_updateToolBar()
    loadGridRow(nEditCuePtr)
  EndWith
EndProcedure

Procedure WEC_drawForm()
  PROCNAMECQ(nEditCuePtr)

  debugMsg(sProcName, #SCS_START)
  colorEditorComponent(#WEC)
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_cboHideCueOpt_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  
  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aCue(nEditCuePtr)
    u = preChangeCueL(\nHideCueOpt, Lang("WEC", "lblHideCueOpt"))
    \nHideCueOpt = getCurrentItemData(WEC\cboHideCueOpt)
    WEC_fcHideCueOpt()
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    postChangeCueL(u, \nHideCueOpt)
  EndWith
EndProcedure

Procedure WEC_chkExclusive_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected u

  If gbInDisplayCue
    ProcedureReturn
  EndIf

  With aCue(nEditCuePtr)
    u = preChangeCueL(\bExclusiveCue, getOwnText(WEC\chkExclusive))
    \bExclusiveCue = getOwnState(WEC\chkExclusive)
    WEC_fcExclusive()
    setCuePtrs(#False)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    debugMsg(sProcName, "calling setCueToGo()")
    setCueToGo()
    postChangeCueL(u, \bExclusiveCue)
  EndWith
EndProcedure

Procedure WEC_chkWarningBeforeEnd_Click()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  
  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aCue(nEditCuePtr)
    u = preChangeCueL(\bWarningBeforeEnd, getOwnText(WEC\chkWarningBeforeEnd))
    \bWarningBeforeEnd = getOwnState(WEC\chkWarningBeforeEnd)
    postChangeCueL(u, \bWarningBeforeEnd)
  EndWith
EndProcedure

Procedure WEC_editFileExternal_Click()
  ; NOTE: This procedure is actually called from fmEditQA.pbi (for image and video editing) and from fmEditQF.pbi (for audio file editing).
  ; NOTE: It is NOT called from this source file (fmEditCue.pbi).
  PROCNAMECA(nEditAudPtr)
  Protected nWindowStateMain.i, nWindowStateEditor.i
  Protected sFilePathname.s, result.i
  Protected sCueFilename.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  sCueFilename = aAud(nEditAudPtr)\sFileName
  
  Select aAud(nEditAudPtr)\nFileFormat
    Case #SCS_FILEFORMAT_AUDIO
      COND_OPEN_PREFS("Editing")
      sFilePathname = ReadPreferenceString("AudioEditor", "")
      COND_CLOSE_PREFS()
    Case #SCS_FILEFORMAT_VIDEO
      COND_OPEN_PREFS("Editing")
      sFilePathname = ReadPreferenceString("VideoEditor", "")
      COND_CLOSE_PREFS()
    Case #SCS_FILEFORMAT_PICTURE
      COND_OPEN_PREFS("Editing")
      sFilePathname = ReadPreferenceString("ImageEditor", "")
      COND_CLOSE_PREFS()
    Default
      ; do nothing
  EndSelect
  
  If Trim(sFilePathname) = ""
    scsMessageRequester(Lang("Common", "Information"), Lang("WEC", "SetExtEditor"), #PB_MessageRequester_Info)
  Else
    nWindowStateEditor = GetWindowState(#WED)
    SetWindowState(#WED, #PB_Window_Minimize)
    nWindowStateMain = GetWindowState(#WMN)
    SetWindowState(#WMN, #PB_Window_Minimize)
    
    Select aAud(nEditAudPtr)\nFileFormat
      Case #SCS_FILEFORMAT_AUDIO
        closeAud(nEditAudPtr)
      Case #SCS_FILEFORMAT_VIDEO, #SCS_FILEFORMAT_PICTURE
        closeVideo(nEditAudPtr)
      Default
        ; do nothing
    EndSelect
    
    result = RunProgram(Chr(34) + sFilePathname + Chr(34), Chr(34) + sCueFilename + Chr(34), "", #PB_Program_Wait)
    openMediaFile(nEditAudPtr)
    gbSetEditorWindowActive = #True
    
    Select aAud(nEditAudPtr)\nFileFormat
      Case #SCS_FILEFORMAT_AUDIO
        WQF_setPropertyFileName(aAud(nEditAudPtr)\sFileName)
        ;SAG(-1)
      Default
        WQA_reloadImages()
    EndSelect
    
    SetWindowState(#WED, nWindowStateEditor)
    SetWindowState(#WMN, nWindowStateMain)
    SAW(#WED)
    ; We need to set this to 0 to prevent any following cues from being Auto triggered when we exit
    aCue(nEditCuePtr)\bCloseCueWhenLeavingEditor = 0
  EndIf
    
EndProcedure

Procedure WEC_loadActivationMethodCBO()
  PROCNAMECQ(nEditCuePtr)
  
  With WEC
    ClearGadgetItems(\cboActivationMethod)
    addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmMan"), #SCS_ACMETH_MAN)
    If (grLicInfo\nLicLevel >= #SCS_LIC_STD) Or (gbDemoCueFile)
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmAuto"), #SCS_ACMETH_AUTO)
    EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmCallQ"), #SCS_ACMETH_CALL_CUE)
    EndIf
    addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmHot"), #SCS_ACMETH_HK_TRIGGER)
    addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmHKTG"), #SCS_ACMETH_HK_TOGGLE)
    addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmHKNT"), #SCS_ACMETH_HK_NOTE)
    If grLicInfo\bStepHotkeysAvailable
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmHKST"), #SCS_ACMETH_HK_STEP)
    EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmTime"), #SCS_ACMETH_TIME)
    EndIf
    ; see also SUB_populateCboSubStart() regarding the order of MTC and OCM
    If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmMTC"), #SCS_ACMETH_MTC)
    EndIf
    CompilerIf #c_lock_audio_to_ltc
      If grLicInfo\bLockAudioToLTCAvailable
        addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmLTC"), #SCS_ACMETH_LTC)
      EndIf
    CompilerEndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmOCM"), #SCS_ACMETH_OCM)
    EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmM+C"), #SCS_ACMETH_MAN_PLUS_CONF)
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmA+C"), #SCS_ACMETH_AUTO_PLUS_CONF)
    EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmExt"), #SCS_ACMETH_EXT_TRIGGER)
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmEXTG"), #SCS_ACMETH_EXT_TOGGLE)
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmEXNT"), #SCS_ACMETH_EXT_NOTE)
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmEXCOMP"), #SCS_ACMETH_EXT_COMPLETE)
    EndIf
    If grLicInfo\bExtFaderCueControlAvailable
      addGadgetItemWithData(\cboActivationMethod, Lang("WEC", "acmExtFdr"), #SCS_ACMETH_EXT_FADER)
    EndIf
  EndWith
  
EndProcedure

Procedure WEC_Form_Load()
  PROCNAMEC()
  Protected nReqdWidth, nActualWidth
  Protected nLeft
  Protected nBankIndex, nCC
  Protected nChkEnabledWidth, nLblDisabledWidth

  debugMsg(sProcName, #SCS_START)
  
  createfmEditCue()
  
  With WEC
    
    grWEC\bLoadingHotkeyCBO = #False
    grWEC\bTBCGridSetup = #False
    grWEC\bTBC_OK = #False
    grWEC\bInValidate = #False
    
    WEC_drawForm()
    
    WEC_loadActivationMethodCBO()
    
    ClearGadgetItems(\cboAutoActivatePosn)
    addGadgetItemWithData(\cboAutoActivatePosn, "", #SCS_ACPOSN_DEFAULT)
    addGadgetItemWithData(\cboAutoActivatePosn, Lang("WEC", "acpStart"), #SCS_ACPOSN_AS)
    addGadgetItemWithData(\cboAutoActivatePosn, Lang("WEC", "acpEnd"), #SCS_ACPOSN_AE)
    addGadgetItemWithData(\cboAutoActivatePosn, Lang("WEC", "acpB4end"), #SCS_ACPOSN_BE)
    addGadgetItemWithData(\cboAutoActivatePosn, Lang("WEC", "acpLoad"), #SCS_ACPOSN_LOAD)
    
    ClearGadgetItems(\cboStandby)
    addGadgetItemWithData(\cboStandby, "", #SCS_STANDBY_NONE)
    addGadgetItemWithData(\cboStandby, decodeStandbyL(#SCS_STANDBY_SET), #SCS_STANDBY_SET)
    addGadgetItemWithData(\cboStandby, decodeStandbyL(#SCS_STANDBY_CANCEL), #SCS_STANDBY_CANCEL)
    
    ClearGadgetItems(\cboHideCueOpt)
    nReqdWidth = GadgetWidth(\cboHideCueOpt, #PB_Gadget_RequiredSize)
    buildEditCBO(\cboHideCueOpt, "HideCueOpt")
    nReqdWidth + getComboBoxMaxTextWidth(\cboHideCueOpt) + gl3DBorderAllowanceX
    nActualWidth = GadgetWidth(\cboHideCueOpt)
    nLeft = GadgetX(\cboHideCueOpt) + nActualWidth - nReqdWidth
    ResizeGadget(\cboHideCueOpt, nLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
    nLeft - GadgetWidth(\lblHideCueOpt) - 5
    ResizeGadget(\lblHideCueOpt, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    
    ClearGadgetItems(\cboHotkeyBank)
    For nBankIndex = 0 To grLicInfo\nMaxHotkeyBank
      If nBankIndex = 0
        addGadgetItemWithData(\cboHotkeyBank, "*", nBankIndex)
      Else
        addGadgetItemWithData(\cboHotkeyBank, Str(nBankIndex), nBankIndex)
      EndIf
    Next nBankIndex
    
    If grLicInfo\bExtFaderCueControlAvailable
      ClearGadgetItems(\cboExtFaderCC)
      For nCC = 0 To 127
        addGadgetItemWithData(\cboExtFaderCC, Str(nCC), nCC)
      Next ncc
    EndIf
    
  EndWith

EndProcedure

Procedure WEC_fcTimeOfDay()
  PROCNAMECQ(nEditCuePtr)
  ; Procedure modified 18Oct2024 11.10.6ar to fix a bug reported by Kenneth Zinkl
  Protected sTimeBasedStart.s, sTimeBasedLatestStart.s, bEnableLatest, sTimeProfile.s
  Protected n, nIndexInCue, nIndexOnScreen
  
  debugMsg(sProcName, #SCS_START)
  
  With aCue(nEditCuePtr)
    For nIndexOnScreen = 0 To #SCS_MAX_TIME_PROFILE
      sTimeProfile = Trim(GGT(WEC\txtTimeProfile[nIndexOnScreen]))
      ; debugMsg0(sProcName, "sTimeProfile=" + sTimeProfile)
      nIndexInCue = -1
      For n = 0 To #SCS_MAX_TIME_PROFILE
        ; debugMsg0(sProcName, "\sTimeProfile[" + n + "]=" + \sTimeProfile[n])
        If \sTimeProfile[n] = sTimeProfile
          nIndexInCue = n
          Break
        EndIf
      Next n
      ; debugMsg0(sProcName, "nIndexInCue=" + nIndexInCue)
      If nIndexInCue = -1
        sTimeBasedStart = ""
        sTimeBasedLatestStart = ""
      Else
        ; debugMsg0(sProcName, "\sTimeBasedStart[" + nIndexInCue + "]=" + \sTimeBasedStart[nIndexInCue])
        sTimeBasedStart = Trim(\sTimeBasedStart[nIndexInCue])
        sTimeBasedLatestStart = Trim(\sTimeBasedLatestStart[nIndexInCue])
      EndIf
      If (sTimeBasedStart) And UCase(Left(sTimeBasedStart, 1)) <> "M"
        bEnableLatest = #True
      Else
        bEnableLatest = #False
        sTimeBasedLatestStart = ""
      EndIf
      setEnabled(WEC\txtLatestTimeOfDay[nIndexOnScreen], bEnableLatest)
      SGT(WEC\txtLatestTimeOfDay[nIndexOnScreen], sTimeBasedLatestStart)
    Next nIndexOnScreen
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_txtTimeOfDay_Validate(Index)
  PROCNAMECQ(nEditCuePtr)
  ; Procedure modified 18Oct2024 11.10.6ar to fix a bug reported by Kenneth Zinkl
  Protected u
  Protected sTimeOfDay.s, sTimeProfile.s
  Protected bCancel
  Protected n, nIndexInCue, nMaxIndexInCue

  sTimeOfDay = Trim(GGT(WEC\txtTimeOfDay[Index]))
  sTimeProfile = Trim(GGT(WEC\txtTimeProfile[Index]))
  
  debugMsg(sProcName, "Index=" + Index + ", sTimeProfile=" + sTimeProfile + ", sTimeOfDay=" + sTimeOfDay)
  With aCue(nEditCuePtr)
    bCancel = #False
    If (LCase(sTimeOfDay) = Left("manual", Len(sTimeOfDay))) And (Len(Trim(sTimeOfDay)) > 0)
      sTimeOfDay = "Manual"
    ElseIf (LCase(sTimeOfDay) = Left(LCase(grText\sTextManual), Len(sTimeOfDay))) And (Len(Trim(sTimeOfDay)) > 0)
      sTimeOfDay = "Manual"
    ElseIf validateTODField(sTimeOfDay, GGT(WEC\lblTimeOfDay)) = #False
      bCancel = #True
      grWEC\bTBC_OK = #False
    EndIf
    If bCancel
      debugMsg(sProcName, "Validation failed")
      ProcedureReturn #False
    Else
      nIndexInCue = -1
      nMaxIndexInCue = -1
      For n = 0 To #SCS_MAX_TIME_PROFILE
        ; debugMsg0(sProcName, "\sTimeProfile[" + n + "]=" + \sTimeProfile[n])
        If \sTimeProfile[n] = sTimeProfile
          nIndexInCue = n
          Break
        EndIf
      Next n
      ; debugMsg(sProcName, "nIndexInCue=" + nIndexInCue)
      If nIndexInCue = -1
        For n = 0 To #SCS_MAX_TIME_PROFILE
          If Len(Trim(\sTimeProfile[n])) = 0
            ; blank entry found (probably at the end) so create a new entry for this time profile
            debugMsg(sProcName, "New entry: setting \sTimeProfile[" + n + "]=" + sTimeProfile)
            nIndexInCue = n
            \sTimeProfile[n] = sTimeProfile
            \sTimeBasedStart[n] = ""
            \sTimeBasedLatestStart[n] =""
            Break
          EndIf
        Next n
      EndIf
      If nIndexInCue >= 0
        ; Should be #True
        u = preChangeCueS(\sTimeBasedStart[nIndexInCue], GGT(WEC\lblTimeOfDay))
        If sTimeOfDay <> \sTimeBasedStart[nIndexInCue]
          \bTBCDone = #False
        EndIf
        \sTimeProfile[nIndexInCue] = sTimeProfile
        \sTimeBasedStart[nIndexInCue] = sTimeOfDay
        WEC_fcTimeOfDay()
        setTimeBasedCues(nEditCuePtr)
        debugMsg(sProcName, "aCue(" + getCueLabel(nEditCuePtr) + ")\sTimeBasedStart[" + nIndexInCue + "]=" + aCue(nEditCuePtr)\sTimeBasedStart[nIndexInCue])
        postChangeCueS(u, \sTimeBasedStart[nIndexInCue])
      EndIf
    EndIf
  EndWith
  markValidationOK(WEC\txtTimeOfDay[Index])
  If getEnabled(WEC\txtLatestTimeOfDay[Index])
    SAG(WEC\txtLatestTimeOfDay[Index])
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtLatestTimeOfDay_Validate(Index)
  PROCNAMECQ(nEditCuePtr)
  ; Procedure modified 18Oct2024 11.10.6ar to fix a bug reported by Kenneth Zinkl
  Protected u
  Protected sTimeProfile.s, sLatestTimeOfDay.s
  Protected bCancel
  Protected n, nIndexInCue
  
  ; TBC Project Changes
  sTimeProfile = Trim(GGT(WEC\txtTimeProfile[Index]))
  sLatestTimeOfDay = Trim(GGT(WEC\txtLatestTimeOfDay[Index]))
  
  debugMsg(sProcName, "Index=" + Index + ", sTimeProfile=" + sTimeProfile + ", sLatestTimeOfDay=" + sLatestTimeOfDay)
  With aCue(nEditCuePtr)
    bCancel = #False
    If validateTODField(sLatestTimeOfDay, GGT(WEC\lblLatestTimeOfDay)) = #False
      bCancel = #True
      grWEC\bTBC_OK = #False
    EndIf
    If bCancel
      debugMsg(sProcName, "Validation failed")
      ProcedureReturn #False
    Else
      nIndexInCue = -1
      For n = 0 To #SCS_MAX_TIME_PROFILE
        If \sTimeProfile[n] = sTimeProfile
          nIndexInCue = n
          Break
        EndIf
      Next n
      If nIndexInCue >= 0
        ; Should be #True
        u = preChangeCueS(\sTimeBasedLatestStart[nIndexInCue], GGT(WEC\lblLatestTimeOfDay))
        If sLatestTimeOfDay <> \sTimeBasedLatestStart[Index]
          \bTBCDone = #False
        EndIf
        \sTimeProfile[nIndexInCue] = sTimeProfile
        \sTimeBasedLatestStart[nIndexInCue] = sLatestTimeOfDay
        setTimeBasedCues(nEditCuePtr)
        debugMsg(sProcName, "aCue(" + getCueLabel(nEditCuePtr) + ")\sTimeBasedLatestStart[" + nIndexInCue + "]=" + aCue(nEditCuePtr)\sTimeBasedLatestStart[nIndexInCue])
        postChangeCueS(u, \sTimeBasedLatestStart[nIndexInCue])
      EndIf
    EndIf
  EndWith
  markValidationOK(WEC\txtLatestTimeOfDay[Index])
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtAutoActivateTime_Validate()
  PROCNAMECQ(nEditCuePtr)
  Protected nTime
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  If grWEC\bInValidate
    ProcedureReturn #True
  EndIf

  grWEC\bInValidate = #True

  If validateTimeField(GGT(WEC\txtAutoActivateTime), "Auto-Activate Time", #False, #False, 60000, #True) = #False
    grWEC\bInValidate = #False
    ProcedureReturn #False
  ElseIf GGT(WEC\txtAutoActivateTime) <> gsTmpString
    SGT(WEC\txtAutoActivateTime, gsTmpString)
  EndIf

  With aCue(nEditCuePtr)
    u = preChangeCueL(\nAutoActTime, "Auto-Activate Time")
    nTime = stringToTime(GGT(WEC\txtAutoActivateTime))
    If nTime <> \nAutoActTime
      \nAutoActTime = nTime
      debugMsg(sProcName, "\nAutoActTime=" + \nAutoActTime)
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    EndIf
    postChangeCueL(u, \nAutoActTime)
  EndWith
  grWEC\bInValidate = #False
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtCue_Change()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", txtCue=" + GGT(grCED\nCurrentCueLabelGadgetNo))
  With aCue(nEditCuePtr)
    u = preChangeCueS(\sCue, GGT(WEC\lblCue), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
    If grProd\bLabelsUCase
      \sCue = UCase(GGT(grCED\nCurrentCueLabelGadgetNo))
      If GGT(grCED\nCurrentCueLabelGadgetNo) <> \sCue
        SGT(grCED\nCurrentCueLabelGadgetNo, \sCue)
      EndIf
    Else
      \sCue = GGT(grCED\nCurrentCueLabelGadgetNo)
    EndIf
    WED_setCueNodeText(nEditCuePtr)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
    postChangeCueS(u, \sCue)
  EndWith
  debugMsg(sProcName, #SCS_END + ", txtCue=" + GGT(grCED\nCurrentCueLabelGadgetNo))
EndProcedure

Procedure WEC_txtCue_Validate()
  PROCNAMECQ(nEditCuePtr)
  Protected sOldCue.s, sNewCue.s
  Protected i
  Protected u
  Protected sMsg.s

  grWEC\bInValidate = #True

  debugMsg(sProcName, #SCS_START + ", txtCue=" + GGT(grCED\nCurrentCueLabelGadgetNo))

  sOldCue = aCue(nEditCuePtr)\sCuePreChange
  sNewCue = Trim(GGT(grCED\nCurrentCueLabelGadgetNo))
  
  If sNewCue
    If UCase(sNewCue) <> UCase(sOldCue)
      For i = 1 To gnLastCue
        With aCue(i)
          If UCase(Trim(\sCue)) = UCase(sNewCue)
            If i <> nEditCuePtr
              ensureSplashNotOnTop()
              valErrMsg(grCED\nCurrentCueLabelGadgetNo, LangPars("Errors", "CueAlreadyExists", sNewCue))
              grWEC\bInValidate = #False
              ; Added 20Oct2023 11.10.0cm following email from Dave Jenkins about not being able to escape from this error message
              SGT(grCED\nCurrentCueLabelGadgetNo, sOldCue)
              WEC_txtCue_Change()
              ; End added 20Oct2023 11.10.0cm
              ProcedureReturn #False
            EndIf
          EndIf
        EndWith
      Next i
    EndIf
    
    If sNewCue <> sOldCue
      With aCue(nEditCuePtr)
        If \sCuePreChange <> sNewCue
          u = preChangeCueS(\sCuePreChange, GGT(WEC\lblCue), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
          \sCue = sNewCue
          \sCuePreChange = sNewCue
          debugMsg(sProcName, "calling changeCueLabel(" + sOldCue + ", " + sNewCue + ", #True, " + sOldCue + ", " + #DQUOTE$ + GGT(WEC\lblCue) + #DQUOTE$ + ")")
          changeCueLabel(sOldCue, sNewCue, #True, sOldCue, GGT(WEC\lblCue))
          SGT(WEC\txtMidiCue, \sMidiCue)
          If \sCue <> \sValidatedCue
            \sValidatedCue = \sCue
            WED_setCueNodeText(nEditCuePtr)
            debugMsg(sProcName, "calling loadCueMarkerArrays()")
            loadCueMarkerArrays()
            \bCallLoadGridRow = #True
            grDMX\bLoadPreCueDMXValuesIfReqd = #True
            PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
          EndIf
          postChangeCueS(u, \sCuePreChange)
        EndIf
      EndWith
      WED_setTBSButtons() ; added 20Nov2019 11.8.2rc5 so that changing a cue label makes corresponding changes to the side bar button tooltips and to menus like 'cut cue xx'
    EndIf
    
  EndIf
  
  markValidationOK(grCED\nCurrentCueLabelGadgetNo)
  grWEC\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEC_txtDescr_Change()
  ; PROCNAMECQ(nEditCuePtr)
  Protected u
  Protected nSubPtr, sNewDescr.s
  
  ; debugMsg(sProcName, #SCS_START + ", txtDescr=" + GGT(WEC\txtDescr))

  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  If nEditCuePtr > 0
    With aCue(nEditCuePtr)
      nSubPtr = \nFirstSubIndex
      u = preChangeCueS(\sCueDescr, GGT(WEC\lblDescr), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
      sNewDescr = Trim(GGT(WEC\txtDescr))
      \sCueDescr = sNewDescr
      setDefaultCueDescrMayBeSet(nEditCuePtr, #True)
      \sValidatedDescr = \sCueDescr
      WED_setCueNodeText(nEditCuePtr)
      loadGridRow(nEditCuePtr)
      If nSubPtr >= 0
        If aSub(nSubPtr)\bSubTypeN
          PNL_refreshDispPanel(nEditCuePtr, nSubPtr, -1, #True)
        EndIf
      EndIf
      postChangeCueS(u, \sCueDescr)
    EndWith
  EndIf
  ; debugMsg(sProcName, #SCS_END + ", txtDescr=" + GGT(WEC\txtDescr))
EndProcedure

Procedure WEC_txtDescr_Validate()
  ; PROCNAMEC()
  
  markValidationOK(WEC\txtDescr)
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtHotkeyLabel_Validate()
  PROCNAMECQ(nEditCuePtr)
  Protected u

  If grWEC\bInValidate
    ProcedureReturn #True
  EndIf
  grWEC\bInValidate = #True

  debugMsg(sProcName, #SCS_START)

  With aCue(nEditCuePtr)
    u = preChangeCueS(\sHotkeyLabel, GGT(WEC\lblHotkeyLabel), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_MAIN)
    \sHotkeyLabel = Trim(GGT(WEC\txtHotkeyLabel))
    loadHotkeyArray()
    samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
    samAddRequest(#SCS_SAM_LOAD_GRID_ROW, nEditCuePtr)
    WEC_loadHotkeyCBO(\sHotkey)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    postChangeCueS(u, \sHotkeyLabel)
  EndWith
  
  markValidationOK(WEC\txtHotkeyLabel)
  grWEC\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtMidiCue_Change()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  
  ; debugMsg(sProcName, #SCS_START)

  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, "WEC\txtMidiCue=" + GGT(WEC\txtMidiCue))
  With aCue(nEditCuePtr)
    u = preChangeCueS(\sMidiCue, GGT(WEC\lblMidiCue))
    \sMidiCue = Trim(GGT(WEC\txtMidiCue))
    WED_setCueNodeText(nEditCuePtr)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    postChangeCueS(u, \sMidiCue)
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_txtMidiCue_Validate()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  Protected sNewMidiCue.s
  Protected i
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEC\bInValidate Or nEditCuePtr < 0 ; Changed 14Jun2022 following weird error reported by Michel Winogradoff, where it appears that nEditCuePtr had not been set
    ProcedureReturn #True
  EndIf
  grWEC\bInValidate = #True
  
  sNewMidiCue = Trim(GGT(WEC\txtMidiCue))
  If Len(sNewMidiCue) > 0
    For i = 1 To gnLastCue
      With aCue(i)
        If UCase(Trim(\sMidiCue)) = UCase(sNewMidiCue)
          If i <> nEditCuePtr
            ; ensureSplashNotOnTop()
            valErrMsg(WEC\txtMidiCue, LangPars("Errors", "MIDICueAlreadyAssigned", GLT(WEC\lblMidiCue), sNewMidiCue, getCueLabel(i)))
            grWEC\bInValidate = #False
            debugMsg(sProcName, "exiting #False")
            ProcedureReturn #False
          EndIf
        EndIf
      EndWith
    Next i
  EndIf
  
  With aCue(nEditCuePtr)
    If sNewMidiCue <> \sMidiCue
      u = preChangeCueS(\sMidiCue, GGT(WEC\lblMidiCue))
      \sMidiCue = sNewMidiCue
      If \sMidiCue
        grProd\bUsingMidiCueNumbers = #True
        ; NB do NOT recalc above flag if this \sMidiCue has been cleared - user may have cleared the last remaining \sMidiCue but wants to re-enter them
      EndIf
      WED_setCueNodeText(nEditCuePtr)
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
      postChangeCueS(u, \sMidiCue)
    EndIf
  EndWith
  
  debugMsg(sProcName, "calling DMX_loadDMXChannelMonitoredArray(@grProd)")
  DMX_loadDMXChannelMonitoredArray(@grProd)
  
  markValidationOK(WEC\txtMidiCue)
  grWEC\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEC_txtPageNo_Change()
  Protected u
  
  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aCue(nEditCuePtr)
    u = preChangeCueS(\sPageNo, GGT(WEC\lblPageNo), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
    \sPageNo = Trim(GGT(WEC\txtPageNo))
    WED_setCueNodeText(nEditCuePtr)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex, -1, #True)
    postChangeCueS(u, \sPageNo)
  EndWith
EndProcedure

Procedure WEC_txtPageNo_Validate()
  markValidationOK(WEC\txtPageNo)
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtWhenReqd_Change()
  PROCNAMECQ(nEditCuePtr)
  Protected u

  debugMsg(sProcName, #SCS_START + ", txtWhenReqd=" + GGT(WEC\txtWhenReqd))
  With aCue(nEditCuePtr)
    u = preChangeCueS(\sWhenReqd, GGT(WEC\lblWhenReqd))
    \sWhenReqd = Trim(GGT(WEC\txtWhenReqd))
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, \nFirstSubIndex)
    postChangeCueS(u, \sWhenReqd)
  EndWith
  debugMsg(sProcName, #SCS_END + ", txtWhenReqd=" + GGT(WEC\txtWhenReqd))
EndProcedure

Procedure WEC_txtWhenReqd_Validate()
  PROCNAMEC()
  Protected u

  If grWEC\bInValidate
    ProcedureReturn #True
  EndIf
  grWEC\bInValidate = #True

  debugMsg(sProcName, #SCS_START + ", txtWhenReqd=" + GetGadgetText(WEC\txtWhenReqd))
  With aCue(nEditCuePtr)
    u = preChangeCueS(\sWhenReqd, GetGadgetText(WEC\lblWhenReqd))
    \sWhenReqd = Trim(GGT(WEC\txtWhenReqd))
    postChangeCueS(u, \sWhenReqd)
  EndWith
  debugMsg(sProcName, #SCS_END + ", txtWhenReqd=" + GetGadgetText(WEC\txtWhenReqd))
  
  markValidationOK(WEC\txtWhenReqd)
  grWEC\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WEC_txtMTCStartPart_Validate()
  PROCNAMECQ(nEditCuePtr)
  Protected u
  Protected sMTCStartTime.s
  Protected nMTCStartTime
  Protected n
  Protected sFieldPrompt.s
  Protected nTimeCodeType
  
  debugMsg(sProcName, #SCS_START)
  
  With aCue(nEditCuePtr)
    If \nActivationMethod = #SCS_ACMETH_LTC
      nTimeCodeType = #SCS_TIMECODE_LTC
    Else
      nTimeCodeType = #SCS_TIMECODE_MTC
    EndIf
    sMTCStartTime = Trim(GGT(WEC\txtMTCStartPart[0])) + ":"
    sMTCStartTime + Trim(GGT(WEC\txtMTCStartPart[1])) + ":"
    sMTCStartTime + Trim(GGT(WEC\txtMTCStartPart[2])) + ":"
    sMTCStartTime + Trim(GGT(WEC\txtMTCStartPart[3]))
   ;  debugMsg(sProcName, "sMTCStartTime=" + sMTCStartTime)
    sFieldPrompt = GGT(WEC\cboActivationMethod)
    If validateMTCField(sMTCStartTime, sFieldPrompt, nTimeCodeType) = #False
      ProcedureReturn #False
    ElseIf sMTCStartTime <> gsTmpString
      For n = 0 To 3
        If GGT(WEC\txtMTCStartPart[n]) <> StringField(gsTmpString,n+1,":")
          SGT(WEC\txtMTCStartPart[n], StringField(gsTmpString,n+1,":"))
        EndIf
      Next n
    EndIf
    u = preChangeCueL(\nMTCStartTimeForCue, sFieldPrompt)
    \nMTCStartTimeForCue = encodeMTCTime(sMTCStartTime)
    setDefaultCueDescr()
    postChangeCueL(u, \nMTCStartTimeForCue)
    setMTCStartTimesForCueSubs(nEditCuePtr)
  EndWith
  loadArrayCueOrSubForMTC()
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  ProcedureReturn #True
EndProcedure

Procedure WEC_setFieldFocus(sField.s)
  With WEC
    Select sField
      Case "txtDescr": SetActiveGadget(\txtDescr)
    EndSelect
  EndWith
EndProcedure

Procedure WEC_addAudioFileMarkers(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected sReqdCueMarkerDetails.s, n
  
  debugMsg(sProcName, #SCS_START)
  
  With aCue(pCuePtr)
    debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nAutoActCueMarkerId=" + \nAutoActCueMarkerId + ", \sAutoActCue=" + \sAutoActCue + ", \sAutoActCueMarkerName=" + \sAutoActCueMarkerName)
  EndWith
  
  For n = 0 To gnMaxCueMarkerInfo
    With gaCueMarkerInfo(n)
      If \bOCMAvailable
        addGadgetItemWithData(WEC\cboAutoActivateMarker, \sCueMarkerDisplayInfo, \nCueMarkerId)
        debugMsg(sProcName, "addGadgetItemWithData(WEC\cboAutoActivateMarker, " + \sCueMarkerDisplayInfo + ", " + \nCueMarkerId + ")")
        If aCue(pCuePtr)\nAutoActCueMarkerId = \nCueMarkerId
          sReqdCueMarkerDetails = \sCueMarkerDisplayInfo
        EndIf
      EndIf
    EndWith
  Next n
  debugMsg(sProcName, "sReqdCueMarkerDetails=" + sReqdCueMarkerDetails)
  
  If sReqdCueMarkerDetails
    SGT(WEC\cboAutoActivateMarker, sReqdCueMarkerDetails)
  Else
    SGS(WEC\cboAutoActivateMarker, -1)
  EndIf
  debugMsg(sProcName, "GGS(WEC\cboAutoActivateMarker)=" + GGS(WEC\cboAutoActivateMarker))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_displayOrHideParamsQMark(bDisplay)
  Static sHelp.s, nHelpWidth, nHelpHeight, nLeft, nTop, nRadius, nFrontColor, nBackColor, nTextLeft, nTextTop
  Static bStaticLoaded
  
  If IsGadget(WEC\cvsParamsQMark)
    If bDisplay
      If StartDrawing(CanvasOutput(WEC\cvsParamsQMark))
        scsDrawingFont(#SCS_FONT_GEN_BOLD9)
        If bStaticLoaded = #False
          sHelp = "?"
          nHelpWidth = TextWidth(sHelp)
          nHelpHeight = TextHeight(sHelp)
          nBackColor = getBackColorFromColorScheme(#SCS_COL_ITEM_CP) ; #SCS_COL_ITEM_CP = color item for Cue Properties in editor
          nFrontColor = getTextColorFromColorScheme(#SCS_COL_ITEM_CP)
          nLeft = (OutputWidth() >> 1) ; - 1
          nTop = (OutputHeight() >> 1) ; - 1
          If nHelpHeight > nHelpWidth
            nRadius = (nHelpHeight >> 1) + 2
          Else
            nRadius = (nHelpWidth >> 1) + 2
          EndIf
          nTextLeft = nLeft - (nHelpWidth >> 1)
          nTextTop = nTop - (nHelpHeight >> 1)
          bStaticLoaded = #True
        EndIf
        ; draw callable parameters help question mark in circle
        Box(0, 0, OutputWidth(), OutputHeight(), nBackColor)
        DrawingMode(#PB_2DDrawing_Outlined)
        Circle(nLeft, nTop, nRadius, nFrontColor)
        DrawText(nTextLeft, nTextTop, sHelp, nFrontColor, nBackColor)
        StopDrawing()
      EndIf
    EndIf
    setVisible(WEC\cvsParamsQMark, bDisplay)
  EndIf
  
EndProcedure

Procedure WEC_cvsParamsQMark_Event()
  PROCNAMEC()
  Protected nMouseX, nMouseY, bDisplayHelp, bCheckDisplay
  Static bHelpDisplayed
  Static sHelpHdr.s, sParamsHelpF.s, sParamsHelpK.s, sParamsHelpL.s, sParamsHelpM.s, sParamsHelpS.s
  Static nMaxWidth, sFullMessage.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sHelpHdr = Lang("WEC", "ParamsHelpHdr")
    sParamsHelpF = Lang("WEC", "ParamsHelpF") ; "Audio File sub-cues: Fade-In and Fade-Out Times"
    sParamsHelpK = Lang("WEC", "ParamsHelpK") ; "Lighting sub-cues: 'Use this' times for Fade Up, Fade Down and Fade Out"
    sParamsHelpL = Lang("WEC", "ParamsHelpL") ; "Level Change sub-cues: duration(s) of change""
    sParamsHelpM = Lang("WEC", "ParamsHelpM") ; "MIDI Control Send sub-cues: properties below 'Channel', eg Note #, Velocity, NRPN items"
    sParamsHelpS = Lang("WEC", "ParamsHelpS") ; "SFR sub-cues: Time Override for Fades"
    nMaxWidth = GetTextWidth(sParamsHelpM + Space(20)) ; seems to give a good result
    sFullMessage = #CRLF$ + sParamsHelpF + #CRLF$ + #CRLF$ +
                   sParamsHelpK + #CRLF$ + #CRLF$ +
                   sParamsHelpL + #CRLF$ + #CRLF$ +
                   sParamsHelpM + #CRLF$ + #CRLF$ +
                   sParamsHelpS
    bStaticLoaded = #True
  EndIf
  
  Select gnEventType
    Case #PB_EventType_MouseEnter, #PB_EventType_MouseMove
      bDisplayHelp = #True
      bCheckDisplay = #True
    Case #PB_EventType_MouseLeave
      bDisplayHelp = #False
      bCheckDisplay = #True
  EndSelect
  
  If bCheckDisplay
    If bDisplayHelp <> bHelpDisplayed
      If bDisplayHelp
        GadToolTip(WEC\cvsParamsQMark, sFullMessage, nMaxWidth)
        SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_NO_ICON, @sHelpHdr)
      EndIf
      bHelpDisplayed = bDisplayHelp
    EndIf
  EndIf
  
EndProcedure

Procedure WEC_populateLTCInputDev()
  ; PROCNAMECQ(nEditCuePtr)
  Protected sLogicalDev.s, nWidth
  
  With WEC
    If IsGadget(\txtLTCInputDev)
      sLogicalDev = getLogicalDevForInputForLTCDev(@grProd) ; may return blank
      SetGadgetText(\txtLTCInputDev, sLogicalDev)
      setGadgetWidth(\txtLTCInputDev, 20, #True)
      ; debugMsg0(sProcName, "WEC\txtLTCInputDev=" + #DQUOTE$ + GetGadgetText(\txtLTCInputDev) + #DQUOTE$ + ", " + GadgetWidth(\txtLTCInputDev))
      ; check if the container needs to be widened
      nWidth = GadgetX(\txtLTCInputDev) + GadgetWidth(\txtLTCInputDev) + gnGap
      If nWidth > GadgetWidth(\cntLTCInputDev)
        ResizeGadget(\cntLTCInputDev, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WEC_displayCueDetail(pCuePtr, pSubPtr)
  PROCNAMECQ(pCuePtr)
  Protected k, sThisHotkey.s, sThisHotkeyEntry.s, sThisHotkeyLabel.s
  Protected nThisHotkeyBank
  Protected nListIndex, n
  Protected nLeft, nTop, nWidth, nHeight
  Protected nReqdCueGadgetNo
  
  ; debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr))
  
  If grCED\bCueCreated = #False
    WEC_Form_Load()
  EndIf
  
  If pCuePtr >= 0
    With grProd
      If \bLabelsUCase And \bLabelsFrozen
        nReqdCueGadgetNo = WEC\txtCueUCFR
      ElseIf \bLabelsUCase
        nReqdCueGadgetNo = WEC\txtCueUC
      ElseIf \bLabelsFrozen
        nReqdCueGadgetNo = WEC\txtCueFR
      Else
        nReqdCueGadgetNo = WEC\txtCueNormal
      EndIf
    EndWith
    
    With grCED
      If \nCurrentCueLabelGadgetNo <> nReqdCueGadgetNo
        HideGadget(\nCurrentCueLabelGadgetNo, #True)
        \nCurrentCueLabelGadgetNo = nReqdCueGadgetNo
        HideGadget(\nCurrentCueLabelGadgetNo, #False)
      EndIf
    EndWith
    
    With aCue(pCuePtr)
      ; debugMsg(sProcName, "grProd\bLabelsUCase=" + strB(grProd\bLabelsUCase) + ", \bLabelsFrozen=" + strB(grProd\bLabelsFrozen) +
      ;                     ", \bEnableMidiCue=" + strB(grProd\bEnableMidiCue) + ", \bUsingMidiCueNumbers=" + strB(grProd\bUsingMidiCueNumbers))
      
      SGT(grCED\nCurrentCueLabelGadgetNo, \sCue)
      
      SGT(WEC\txtMidiCue, \sMidiCue)
      If (grProd\bEnableMidiCue) Or (grProd\bUsingMidiCueNumbers)
        setVisible(WEC\txtMidiCue, #True)
        setVisible(WEC\lblMidiCue, #True)
        nLeft = GadgetX(WEC\txtMidiCue) + GadgetWidth(WEC\txtMidiCue) + 8
        ;ResizeGadget(WEC\lblWhenReqd, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        nLeft = GadgetX(WEC\lblWhenReqd) + GadgetWidth(WEC\lblWhenReqd) + 5
        nWidth = GadgetX(WEC\txtDescr) + GadgetWidth(WEC\txtDescr) - nLeft
        ;ResizeGadget(WEC\txtWhenReqd, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
      Else
        setVisible(WEC\txtMidiCue, #False)
        setVisible(WEC\lblMidiCue, #False)
        nLeft = GadgetX(WEC\txtDescr) - GadgetWidth(WEC\lblWhenReqd) - 5
        ;ResizeGadget(WEC\lblWhenReqd, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        nLeft = GadgetX(WEC\txtDescr)
        nWidth = GadgetWidth(WEC\txtDescr)
        ;ResizeGadget(WEC\txtWhenReqd, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
      EndIf
      
      SGT(WEC\txtPageNo, \sPageNo)
      SGT(WEC\txtDescr, \sCueDescr)
      SGT(WEC\txtWhenReqd, \sWhenReqd)
      
      setOwnState(WEC\chkCueEnabled, \bCueEnabled)
      WEC_fcEnabled()
      
      setOwnState(WEC\chkExclusive, \bExclusiveCue)
      WEC_fcExclusive()
      
      setOwnState(WEC\chkWarningBeforeEnd, \bWarningBeforeEnd)
      If grProd\nVisualWarningTime > 0 Or grProd\nVisualWarningTime = #SCS_VWT_COUNT_DOWN_WHOLE_CUE
        setVisible(WEC\chkWarningBeforeEnd, #True)
      Else
        setVisible(WEC\chkWarningBeforeEnd, #False)
      EndIf
      
      nListIndex = indexForComboBoxData(WEC\cboHideCueOpt, \nHideCueOpt, 0)
      SGS(WEC\cboHideCueOpt, nListIndex)
      WEC_fcHideCueOpt()
      
      ; debugMsg(sProcName, "\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \sAutoActCue=" + \sAutoActCue)
      
      ; activation method
      WEC_loadActivationMethodCBO()
      nListIndex = indexForComboBoxData(WEC\cboActivationMethod, \nActivationMethod, 0)
      SetGadgetState(WEC\cboActivationMethod, nListIndex)
      WEC_fcActivationMethod()
      
      ; hotkey processing
      If (\nActivationMethod & #SCS_ACMETH_HK_BIT) <> 0
        nThisHotkeyBank = \nHotkeyBank
        sThisHotkey = \sHotkey
        sThisHotkeyLabel = \sHotkeyLabel
      Else
        nThisHotkeyBank = 0 ; (common)
        sThisHotkey = ""
        sThisHotkeyLabel = ""
      EndIf
      nListIndex = indexForComboBoxData(WEC\cboHotkeyBank, nThisHotkeyBank, 0)
      SGS(WEC\cboHotkeyBank, nListIndex)
      WEC_loadHotkeyCBO(sThisHotkey)
      If GGT(WEC\txtHotkeyLabel) <> sThisHotkeyLabel
        SGT(WEC\txtHotkeyLabel, sThisHotkeyLabel)
      EndIf
      
      ; autostart processing
      If (\nActivationMethod = #SCS_ACMETH_AUTO) Or (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
        nListIndex = indexForComboBoxData(WEC\cboAutoActivatePosn, \nAutoActPosn, 0)
        SGS(WEC\cboAutoActivatePosn, nListIndex)
        SGT(WEC\txtAutoActivateTime, timeToString(\nAutoActTime, \nAutoActTime))
        WEC_fcActivatePosn()  ; nb populates WEC\cboAutoActivateCue
        setEnabled(WEC\cboAutoActivatePosn, #True)
        setEnabled(WEC\txtAutoActivateTime, #True)
        setEnabled(WEC\cboAutoActivateCue, #True)
      EndIf
      
      ; standby processing
      If grLicInfo\nLicLevel >= #SCS_LIC_PRO
        setEnabled(WEC\cboStandby, #True)
        nListIndex = indexForComboBoxData(WEC\cboStandby, \nStandby)
        SGS(WEC\cboStandby, nListIndex)
      Else
        setEnabled(WEC\cboStandby, #False)
      EndIf
      
      ; external fader processing
      If grLicInfo\bExtFaderCueControlAvailable
        If \nActivationMethod = #SCS_ACMETH_EXT_FADER
          setGadgetItemByData(WEC\cboExtFaderCC, \nExtFaderCC)
        EndIf
      EndIf
      
      ; callable cue parameters
      If \nActivationMethod = #SCS_ACMETH_CALL_CUE
        SGT(WEC\txtCallableCueParams, \sCallableCueParams)
      EndIf
      
      If \nActivationMethod = #SCS_ACMETH_LTC
        WEC_populateLTCInputDev()
      EndIf
      
      \sCuePreChange = \sCue
      
    EndWith
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_fcActivationMethod()
  PROCNAMECQ(nEditCuePtr)
  Protected sMTCStartTimeForCue.s
  Protected n, nListIndex
  Protected bHotkeyBankVisible, bHotkeyVisible, bTBCVisible, bMTCStartTimeVisible, bAutoActivateMarkerVisible, bExtFaderCCVisible
  Protected bAutoActivateTimeAndStartPositionVisible, bAutoActivatePosnAndCueVisible, bCallablCueParamsVisible
  Protected bLTCInputDevVisible
  Protected sTimeCodeType.s
  
  setVisible(WEC\cntStandby, #True)
  setVisible(WEC\lblStandby, #True)
  setVisible(WEC\cboStandby, #True)

  With WEC
    Select aCue(nEditCuePtr)\nActivationMethod
        
      Case #SCS_ACMETH_MAN, #SCS_ACMETH_MAN_PLUS_CONF, #SCS_ACMETH_EXT_TRIGGER, #SCS_ACMETH_EXT_TOGGLE, #SCS_ACMETH_EXT_NOTE, #SCS_ACMETH_EXT_STEP, #SCS_ACMETH_EXT_COMPLETE
        ; no other activation fields visible
        
      Case #SCS_ACMETH_HK_TRIGGER, #SCS_ACMETH_HK_TOGGLE, #SCS_ACMETH_HK_NOTE, #SCS_ACMETH_HK_STEP
        bHotkeyBankVisible = #True
        bHotkeyVisible = #True
        
      Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
        ; For the condition when the AutoStart is first selected and the Posn is already for OCM - otherwise components are reset to visible 
        If aCue(nEditCuePtr)\nAutoActPosn <> #SCS_ACPOSN_OCM
          bAutoActivateTimeAndStartPositionVisible = #True
        EndIf
        bAutoActivatePosnAndCueVisible = #True
        If aCue(nEditCuePtr)\nAutoActCuePtr < 0
          If CountGadgetItems(\cboAutoActivateCue) > 1
            SGS(\cboAutoActivateCue, 1)
          EndIf
        EndIf
        
      Case #SCS_ACMETH_TIME
        WEC_populateTBCList()
        bTBCVisible = #True
        setVisible(\cntStandby, #False)
        setVisible(\lblStandby, #False)
        setVisible(\cboStandby, #False)
        
      Case #SCS_ACMETH_MTC, #SCS_ACMETH_LTC
        ; Used for both MTC and LTC start times
        sMTCStartTimeForCue = decodeMTCTime(aCue(nEditCuePtr)\nMTCStartTimeForCue)
        For n = 0 To 3
          SGT(\txtMTCStartPart[n], StringField(sMTCStartTimeForCue,n+1,":"))
        Next n
        CompilerIf #c_lock_audio_to_ltc
          If aCue(nEditCuePtr)\nActivationMethod = #SCS_ACMETH_LTC
            sTimeCodeType = "LTC"
            If IsGadget(\txtLTCInputDev)
              bLTCInputDevVisible = #True
              WEC_populateLTCInputDev()
            EndIf
          Else
            sTimeCodeType = "MTC"
          EndIf
        CompilerElse
          sTimeCodeType = "MTC"
        CompilerEndIf
        For n = 0 To 3
          scsToolTip(\txtMTCStartPart[n], ReplaceString(Lang("WQU","txtMTCStartTimeTT"), "MTC", sTimeCodeType))
        Next n
        bMTCStartTimeVisible = #True
        
      Case #SCS_ACMETH_CALL_CUE
        SGT(\txtCallableCueParams, aCue(nEditCuePtr)\sCallableCueParams) ; Added 29May2023 11.10.0be
        bCallablCueParamsVisible = #True
        
      Case #SCS_ACMETH_OCM
        WEC_loadAutoActivateCueMarker(nEditCuePtr)
        bAutoActivateMarkerVisible = #True
        
      Case #SCS_ACMETH_EXT_FADER
        bExtFaderCCVisible = #True
        
    EndSelect
    
    ; NOTE: setVisible() includes a check that the gadget exists so we do not need to wrap conditional code around the following setVisible() calls
    setVisible(\txtAutoActivateTime, bAutoActivateTimeAndStartPositionVisible)
    setVisible(\lblAutoStartPosition, bAutoActivateTimeAndStartPositionVisible)
    setVisible(\cboAutoActivatePosn, bAutoActivatePosnAndCueVisible)
    setVisible(\cboAutoActivateCue, bAutoActivatePosnAndCueVisible)
    setVisible(\lblHotkeyBank, bHotkeyBankVisible)
    setVisible(\cboHotkeyBank, bHotkeyBankVisible)
    setVisible(\lblHotkey, bHotkeyVisible)
    setVisible(\cboHotkey, bHotkeyVisible)
    setVisible(\lblHotkeyLabel, bHotkeyVisible)
    setVisible(\txtHotkeyLabel, bHotkeyVisible)
    setVisible(\cntTBC, bTBCVisible)
    setVisible(\cntMTCStartTime, bMTCStartTimeVisible); Used for both MTC and LTC start imes
    CompilerIf #c_lock_audio_to_ltc
      setVisible(\cntLTCInputDev, bLTCInputDevVisible)
    CompilerEndIf
    setVisible(\cboAutoActivateMarker, bAutoActivateMarkerVisible)
    If grLicInfo\bExtFaderCueControlAvailable
      setVisible(\lblExtFaderCC, bExtFaderCCVisible)
      setVisible(\cboExtFaderCC, bExtFaderCCVisible)
    EndIf
    setVisible(\lblCallableCueParams, bCallablCueParamsVisible)
    setVisible(\txtCallableCueParams, bCallablCueParamsVisible)
    WEC_displayOrHideParamsQMark(bCallablCueParamsVisible)

    setTextBoxBackColor(\txtAutoActivateTime)
    
    WMN_updateToolBar()
    
  EndWith
  
EndProcedure

Procedure WEC_fcActivatePosn()
  PROCNAMECQ(nEditCuePtr)
  Protected bEnableAutoActivateCue, bVisibleAutoActivateTime
  
  ; debugMsg(sProcName, #SCS_START)
  
  WEC_loadAutoActivateCueCBO(nEditCuePtr)
  
  With aCue(nEditCuePtr)
    Select \nActivationMethod
      Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
        Select \nAutoActPosn
          Case #SCS_ACPOSN_AE, #SCS_ACPOSN_AS, #SCS_ACPOSN_BE
            bVisibleAutoActivateTime = #True
            bEnableAutoActivateCue = #True
          Case #SCS_ACPOSN_OCM
            bVisibleAutoActivateTime = #False
            bEnableAutoActivateCue = #True
          Case #SCS_ACPOSN_DEFAULT, #SCS_ACPOSN_LOAD
            bVisibleAutoActivateTime = #True
            bEnableAutoActivateCue = #False
            \sAutoActCue = grCueDef\sAutoActCue
            \nAutoActCuePtr = grCueDef\nAutoActCuePtr
        EndSelect
        
      Case #SCS_ACMETH_OCM
        bVisibleAutoActivateTime = #False
        bEnableAutoActivateCue = #False
        
      Default ; other activation methods, eg Manual, Hotkey, etc
        bVisibleAutoActivateTime = #False
        bEnableAutoActivateCue = #False
        \sAutoActCue = grCueDef\sAutoActCue
        \nAutoActCuePtr = grCueDef\nAutoActCuePtr
        
    EndSelect
    
    setVisible(WEC\txtAutoActivateTime, bVisibleAutoActivateTime)
    setVisible(WEC\lblAutoStartPosition, bVisibleAutoActivateTime)
    
    If bEnableAutoActivateCue
      setEnabled(WEC\cboAutoActivateCue, #True)
    Else
      setEnabled(WEC\cboAutoActivateCue, #False)
      If GGS(WEC\cboAutoActivateCue) > 0
        SGS(WEC\cboAutoActivateCue, -1)
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEC_fcEnabled()
  PROCNAMECQ(nEditCuePtr)
  
  With WEC
    If getOwnState(\chkCueEnabled)
      setVisible(\lblCueDisabled, #False)
      Select grCED\nCurrentCueLabelGadgetNo
        Case \txtCueFR, \txtCueUCFR
          scsSetGadgetFont(grCED\nCurrentCueLabelGadgetNo, #SCS_FONT_GEN_NORMAL12)
          scsSetGadgetFont(\txtDescr, #SCS_FONT_GEN_NORMAL)
        Default
          scsSetGadgetFont(grCED\nCurrentCueLabelGadgetNo, #SCS_FONT_GEN_BOLD12)
          scsSetGadgetFont(\txtDescr, #SCS_FONT_GEN_BOLD)
      EndSelect
    Else
      setVisible(\lblCueDisabled, #True)
      Select grCED\nCurrentCueLabelGadgetNo
        Case \txtCueFR, \txtCueUCFR
          scsSetGadgetFont(grCED\nCurrentCueLabelGadgetNo, #SCS_FONT_GEN_NORMALSTRIKETHRU12)
          scsSetGadgetFont(\txtDescr, #SCS_FONT_GEN_NORMALSTRIKETHRU)
        Default
          scsSetGadgetFont(grCED\nCurrentCueLabelGadgetNo, #SCS_FONT_GEN_BOLDSTRIKETHRU12)
          scsSetGadgetFont(\txtDescr, #SCS_FONT_GEN_BOLDSTRIKETHRU)
      EndSelect
    EndIf
  EndWith
  setLinksForCue(nEditCuePtr) ; Added 13Aug2022 11.9.4
EndProcedure

Procedure WEC_fcExclusive()
  ; PROCNAMEC()
  With WEC
    If getOwnState(\chkExclusive)
      setOwnFont(\chkExclusive, #SCS_FONT_GEN_BOLD)
    Else
      setOwnFont(\chkExclusive, #SCS_FONT_GEN_NORMAL)
    EndIf
  EndWith
EndProcedure

Procedure WEC_fcHideCueOpt()
  ; PROCNAMEC()
  With WEC
    Select aCue(nEditCuePtr)\nHideCueOpt
      Case #SCS_HIDE_ENTIRE_CUE
        ; debugMsg(sProcName, "Hide Cue")
        SGT(\lblHidden, Lang("WEC", "lblHidden"))
        setVisible(\lblHidden, #True)
        
      Case #SCS_HIDE_CUE_PANEL
        ; debugMsg(sProcName, "Hide Cue Panel")
        SGT(\lblHidden, Lang("WEC", "lblHidden2"))
        setVisible(\lblHidden, #True)
        
      Case #SCS_HIDE_NO
        ; debugMsg(sProcName, "Display Cue")
        setVisible(\lblHidden, #False)
        
    EndSelect
  EndWith
EndProcedure

Procedure WEC_fcHotkey()
  PROCNAMEC()
  With WEC
    If GGT(\cboHotkey) = #SCS_BLANK_CBO_ENTRY
      setEnabled(\txtHotkeyLabel, #False)
      debugMsg(sProcName, "clearing txtHotkeyLabel")
      SGT(\txtHotkeyLabel, "")
    Else
      setEnabled(\txtHotkeyLabel, #True)
    EndIf
    setTextBoxBackColor(\txtHotkeyLabel)
  EndWith
EndProcedure

Procedure WEC_loadHotkeyCBO(sHotkey.s)
  PROCNAMECQ(nEditCuePtr)
  Protected nSelectedBank, nKeyNumber, n, sMyHotkey.s, nDataValue, nReqdDataValue
  Protected sBank.s
  Protected bLoaded
  Protected nListIndex
  Protected sText.s
  Protected bStepHotkey, nStepNo, nMaxStepNo, bNewStep
  Static sNewStep.s, bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", sHotkey=" + sHotkey)
  
  If grWEC\bLoadingHotkeyCBO
    ProcedureReturn
  EndIf
  grWEC\bLoadingHotkeyCBO = #True
  
  If bStaticLoaded = #False
    sNewStep = " (" + LCase(Lang("HKeys", "NewStep")) + ")"
    bStaticLoaded = #True
  EndIf
  
  nSelectedBank = aCue(nEditCuePtr)\nHotkeyBank
  If aCue(nEditCuePtr)\nActivationMethod = #SCS_ACMETH_HK_STEP
    bStepHotkey = #True
  EndIf
  ; debugMsg(sProcName, "bStepHotkey=" + strB(bStepHotkey))
  
  ClearGadgetItems(WEC\cboHotkey)
  addGadgetItemWithData(WEC\cboHotkey, #SCS_BLANK_CBO_ENTRY, -1)
  
  ; debugMsg(sProcName, "ArraySize(gaHotkeys(),1)=" + ArraySize(gaHotkeys(),1) + ", ArraySize(gaHotkeys(),2)=" + ArraySize(gaHotkeys(),2) + ", grLicInfo\nMaxHotkeyBank=" + grLicInfo\nMaxHotkeyBank)
  
  For nKeyNumber = 1 To CountString(gsValidHotkeys, ",") + 1
    sMyHotkey = StringField(gsValidHotkeys, nKeyNumber, ",")
    ; debugMsg(sProcName, "nKeyNumber=" + nKeyNumber + ", sMyHotkey=" + #DQUOTE$ + sMyHotkey + #DQUOTE$)
    nStepNo = 0
    nMaxStepNo = 0
    bLoaded = #False
    bNewStep = #False
    For n = 0 To gnMaxHotkey
      With gaHotkeys(n)
        If \nHotkeyBank = nSelectedBank And \sHotkey = sMyHotkey And \nCuePtr >= 0
          sText = sMyHotkey
          If \sHotkeyLabel
            sText +  " - " + \sHotkeyLabel
          ElseIf bStepHotkey
            sText + sNewStep ; sNewStep = " (new step)"
            bNewStep = #True
            ; nb bNewStep is set to #True for a 'step' hotkey that has not yet had the label assigned, so still has "(new step)" displayed
          EndIf
          bLoaded = #True
          If \nActivationMethod = #SCS_ACMETH_HK_STEP
            nStepNo = \nHotkeyStepNo
            If nStepNo > nMaxStepNo
              nMaxStepNo = nStepNo
            EndIf
          EndIf
          nDataValue = (nKeyNumber << 16) | nStepNo
          addGadgetItemWithData(WEC\cboHotkey, sText, nDataValue)
          ; debugMsg(sProcName, "addGadgetItemWithData(WEC\cboHotkey, " + #DQUOTE$ + sText+ #DQUOTE$ + ", " + nDataValue + ")")
          If \nCuePtr = nEditCuePtr
            nReqdDataValue = nDataValue
          EndIf
        EndIf
      EndWith
    Next n
    If bStepHotkey
      If nMaxStepNo > 0 And bNewStep = #False
        ; add an extra hotkey item if steps are used, to allow the user to assign another cue to this 'step' hotkey
        sText = sMyHotkey + sNewStep ; sNewStep = " (new step)"
        nStepNo = 0
        nDataValue = (nKeyNumber << 16) | nStepNo
        addGadgetItemWithData(WEC\cboHotkey, sText, nDataValue)
        ; debugMsg(sProcName, "addGadgetItemWithData(WEC\cboHotkey, " + #DQUOTE$ + sText+ #DQUOTE$ + ", " + nDataValue + ")")
      EndIf
    EndIf
    If bLoaded = #False
      sText = sMyHotkey
      If nSelectedBank = 0
        sBank = ""
        For n = 0 To gnMaxHotkey
          With gaHotkeys(n)
            If \sHotkey = sMyHotkey And \sHotkeyLabel
              If Len(sBank) = 0
                sBank = " (" + \nHotkeyBank
              Else
                sBank + "," + \nHotkeyBank
              EndIf
            EndIf
          EndWith
        Next n
        If sBank
          sBank + ")"
        EndIf
      Else ; nSelectedBank > 0
        For n = 0 To gnMaxHotkey
          With gaHotkeys(n)
            If \sHotkey = sMyHotkey And \sHotkeyLabel And \nHotkeyBank = 0
              sBank = " (*) " + gaHotkeys(n)\sHotkeyLabel
              Break
            EndIf
          EndWith
        Next n
      EndIf
      sText + sBank
      nDataValue = (nKeyNumber << 16) | nStepNo
      addGadgetItemWithData(WEC\cboHotkey, sText, nDataValue)
      ; debugMsg(sProcName, "addGadgetItemWithData(WEC\cboHotkey, " + #DQUOTE$ + sText+ #DQUOTE$ + ", " + nDataValue + ")")
    EndIf
  Next nKeyNumber
  
  setComboBoxByData(WEC\cboHotkey, nReqdDataValue, 0)
  
  grWEC\bLoadingHotkeyCBO = #False
  
EndProcedure

Procedure WEC_valHotkey()
  PROCNAMECQ(nEditCuePtr)
  ; handles validation and updating of cboHotkey (sHotkey) and cboHotkeyBank (nHotkeyBank)
  Protected sHotkeyRequested.s, i, bStepHotkey
  Protected u
  Protected nBankIndex, nDataValue, nKeynumber, nStepNo, nCurrHotkeyPtr
  
  nBankIndex = getCurrentItemData(WEC\cboHotkeyBank)
  nDataValue = getCurrentItemData(WEC\cboHotkey) ; data value is "(nKeyNumber << 16) | nStepNo" - see WEC_loadHotkeyCBO()
  nKeynumber = nDataValue >> 16
  nStepNo = nDataValue & $FFFF
  debugMsg(sProcName, "GGT(WEC\cboHotkey)=" + #DQUOTE$ + GGT(WEC\cboHotkey) + #DQUOTE$ + ", nDataValue=" + nDataValue + ", nKeynumber=" + nKeynumber + ", nStepNo=" + nStepNo)
  
  sHotkeyRequested = getHotkeyFromHotkeyNr(nKeynumber)
  debugMsg(sProcName, "sHotkeyRequested=" + sHotkeyRequested)
  
  If aCue(nEditCuePtr)\nActivationMethod = #SCS_ACMETH_HK_STEP
    bStepHotkey = #True
    debugMsg(sProcName, "bStepHotkey=" + strB(bStepHotkey))
  EndIf
  
  If sHotkeyRequested
    For i = 1 To gnLastCue
      If i <> nEditCuePtr
        With aCue(i)
          If \sHotkey = sHotkeyRequested
            If (\nHotkeyBank = nBankIndex) Or (\nHotkeyBank = 0) Or (nBankIndex = 0)
              If bStepHotkey And \nActivationMethod = #SCS_ACMETH_HK_STEP
                ; OK to have more than one cue with the same hotkey if they are all 'step' hotkeys
              Else
                scsMessageRequester(grText\sTextValErr,LangSpace("Common","Hotkey") + sHotkeyRequested + " " + LangSpace("WEC", "AlreadyUsed") + aCue(i)\sCue, #PB_MessageRequester_Error)
                SAW(#WED)
                ProcedureReturn #False
              EndIf
            EndIf
          EndIf
        EndWith
      EndIf
    Next i
  Else
    If Trim(GGT(WEC\txtHotkeyLabel))
      debugMsg(sProcName, "clearing txtHotkeyLabel")
      SGT(WEC\txtHotkeyLabel, "")
    EndIf
  EndIf

  With aCue(nEditCuePtr)
    If \sHotkey <> Trim(sHotkeyRequested)
      u = preChangeCueS(\sHotkey, GGT(WEC\lblHotkey), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_MAIN)
      \sHotkey = Trim(sHotkeyRequested)
      loadHotkeyArray()
      debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)")
      samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
      samAddRequest(#SCS_SAM_LOAD_GRID_ROW, nEditCuePtr)
      WEC_loadHotkeyCBO(\sHotkey)
      postChangeCueS(u, \sHotkey)
    EndIf
  EndWith
  
  ProcedureReturn #True

EndProcedure

Procedure WEC_populateTBCList()
  PROCNAMECQ(nEditCuePtr)
  Protected n, m, sTimeProfile.s, sTimeOfDay.s
  Protected nTimeProfileCount, sMsg.s
  Protected nMaxTimeProfile, nInnerHeight ; Added 23Jan2024 11.10.1

  debugMsg(sProcName, #SCS_START)
  
  With WEC
    For n = 0 To #SCS_MAX_TIME_PROFILE
      sTimeProfile = grProd\sTimeProfile[n]
      sTimeOfDay = ""
      If sTimeProfile
        nMaxTimeProfile = n ; Added 23Jan2024 11.10.1
        nTimeProfileCount + 1
        For m = 0 To #SCS_MAX_TIME_PROFILE
          If UCase(aCue(nEditCuePtr)\sTimeProfile[m]) = UCase(sTimeProfile)
            sTimeOfDay = aCue(nEditCuePtr)\sTimeBasedStart[m]
            Break
          EndIf
        Next m
      EndIf
      ; debugMsg0(sProcName, "n=" + n + ", sTimeProfile=" + #DQUOTE$ + sTimeProfile + #DQUOTE$ + ", sTimeOfDay=" + #DQUOTE$ + sTimeOfDay + #DQUOTE$)
      SGT(\txtTimeProfile[n], sTimeProfile)
      SGT(\txtTimeOfDay[n], sTimeOfDay)
      If sTimeProfile
        setEnabled(\txtTimeOfDay[n], #True)
      Else
        setEnabled(\txtTimeOfDay[n], #False)
      EndIf
    Next n
    ; Added 23Jan2024 11.10.1 because previously when entering a time against the last supplied time profile the scroll arae would scroll up
    nInnerHeight = (nMaxTimeProfile + 1) * 21
    SetGadgetAttribute(\scaTBC, #PB_ScrollArea_InnerHeight, nInnerHeight)
    ; End added 23Jan2024 11.10.1
    
    WEC_fcTimeOfDay() ; nb enables and populates \txtLatestTimeOfDay[] as required
    
    If nTimeProfileCount = 0
      sMsg = Lang("Errors", "NoTimeProfiles")
      debugMsg(sProcName, sMsg)
      scsMessageRequester(grText\sTextEditor, sMsg, #PB_MessageRequester_Ok | #MB_ICONEXCLAMATION)
    EndIf
    
  EndWith
  
EndProcedure

Procedure WEC_fieldValidation()
  SetActiveGadget(-1)
EndProcedure

Procedure WEC_formValidation()
  ; PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WEC_valGadget(gnValidateGadgetNo)
  EndIf
  
  ; debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure 

Procedure WEC_EventHandler()
  PROCNAMEC()
  
  With WEC
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        Select gnEventGadgetNoForEvHdlr
            
          Case \cboActivationMethod
            CBOCHG(WEC_cboActivationMethod_Click())
            
          Case \cboAutoActivateCue
            CBOCHG(WEC_cboAutoActivateCue_Click())
            
          Case \cboAutoActivateMarker
            CBOCHG(WEC_cboAutoActivateMarker_Click())
            
          Case \cboAutoActivatePosn
            CBOCHG(WEC_cboAutoActivatePosn_Click())
            
          Case \cboExtFaderCC
            CBOCHG(WEC_cboExtFaderCC_Click())
            
          Case \cboHideCueOpt
            CBOCHG(WEC_cboHideCueOpt_Click())
            
          Case \cboHotkey
            CBOCHG(WEC_cboHotkey_Click())
            
          Case \cboHotkeyBank
            CBOCHG(WEC_cboHotkeyBank_Click())
            
          Case \cboStandby
            CBOCHG(WEC_cboStandby_Click())
            
          Case \chkCueEnabled
            CHKOWNCHG(WEC_chkCueEnabled_Click())
            
          Case \chkExclusive
            CHKOWNCHG(WEC_chkExclusive_Click())
            
          Case \chkWarningBeforeEnd
            CHKOWNCHG(WEC_chkWarningBeforeEnd_Click())
            
          Case \cntSubPlaceHolder
            ; ignore events
            
          Case \cvsParamsQMark
            WEC_cvsParamsQMark_Event()
            
          Case \scaCueProperties
            ; ignore events
            
          Case \scaTBC
            ; ignore events
            
          Case \splEditH
            WEC_splEditH_Event()
            
          Case \txtAutoActivateTime
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtAutoActivateTime_Validate())
            EndIf
            
          Case \txtCallableCueParams
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtCallableCueParams_Validate())
            EndIf
            
          Case grCED\nCurrentCueLabelGadgetNo ; eg \txtCueNormal
            If gnEventType = #PB_EventType_Change
              WEC_txtCue_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtCue_Validate())
            EndIf
            
          Case \txtDescr
            If gnEventType = #PB_EventType_Change
              WEC_txtDescr_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtDescr_Validate())
            EndIf
            
          Case \txtHotkeyLabel
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtHotkeyLabel_Validate())
            EndIf
            
          Case \txtLatestTimeOfDay[0]
            If gnEventType = #PB_EventType_Focus
              ensureScrollAreaItemVisible(\scaTBC, 21, gnEventGadgetArrayIndex)
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtLatestTimeOfDay_Validate(gnEventGadgetArrayIndex))
            EndIf

          Case \txtMidiCue
            If gnEventType = #PB_EventType_Change
              WEC_txtMidiCue_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              debugMsg(sProcName, "\txtMidiCue LostFocus")
              ETVAL(WEC_txtMidiCue_Validate())
            EndIf
            
          Case \txtMTCStartPart[0]
            If gnEventType = #PB_EventType_Change
              Select gnEventGadgetNo
                Case \txtMTCStartPart[0]
                  macTimecodeEntry(\txtMTCStartPart[0], \txtMTCStartPart[1])
                Case \txtMTCStartPart[1]
                  macTimecodeEntry(\txtMTCStartPart[1], \txtMTCStartPart[2])
                Case \txtMTCStartPart[2]
                  macTimecodeEntry(\txtMTCStartPart[2], \txtMTCStartPart[3])
                Case \txtMTCStartPart[3]
                  ; do NOT call macTimecodeEntry() as this is the last part of the timecode
              EndSelect
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtMTCStartPart_Validate())
            EndIf
            
          Case \txtPageNo
            If gnEventType = #PB_EventType_Change
              WEC_txtPageNo_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtPageNo_Validate())
            EndIf
            
          Case \txtTimeOfDay[0]
            If gnEventType = #PB_EventType_Focus
              ensureScrollAreaItemVisible(\scaTBC, 21, gnEventGadgetArrayIndex)
            ElseIf gnEventType = #PB_EventType_LostFocus
              ; debugMsg0(sProcName, "calling ETVAL(WEC_txtTimeOfDay_Validate(" + gnEventGadgetArrayIndex + "))")
              ETVAL(WEC_txtTimeOfDay_Validate(gnEventGadgetArrayIndex))
            EndIf
            
          Case \txtWhenReqd
            If gnEventType = #PB_EventType_Change
              WEC_txtWhenReqd_Change()
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WEC_txtWhenReqd_Validate())
            EndIf
            
          Default
            If gnEventType <> #PB_EventType_Resize
              debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
            EndIf
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WEC_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  ; debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ; debugMsg(sProcName, "nGadgetPropsIndex=" + nGadgetPropsIndex)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  ; debugMsg(sProcName, "nEventGadgetNoForEvHdlr=G" + nEventGadgetNoForEvHdlr)
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  ; debugMsg(sProcName, "nArrayIndex=" + nArrayIndex)
  
  With WEC
    Select nEventGadgetNoForEvHdlr
        
      Case \txtAutoActivateTime
        ETVAL2(WEC_txtAutoActivateTime_Validate())
        
      Case \txtCallableCueParams
        ETVAL2(WEC_txtCallableCueParams_Validate())
        
      Case grCED\nCurrentCueLabelGadgetNo ; eg \txtCueNormal
        ETVAL2(WEC_txtCue_Validate())
        
      Case \txtDescr
        ETVAL2(WEC_txtDescr_Validate())
        
      Case \txtHotkeyLabel
        ETVAL2(WEC_txtHotkeyLabel_Validate())
        
      Case \txtLatestTimeOfDay[0]
        ETVAL2(WEC_txtLatestTimeOfDay_Validate(nArrayIndex))

      Case \txtMidiCue
        ETVAL2(WEC_txtMidiCue_Validate())
        
      Case \txtPageNo
        ETVAL2(WEC_txtPageNo_Validate())
        
      Case \txtTimeOfDay[0]
        ; debugMsg0(sProcName, "calling ETVAL2(WEC_txtTimeOfDay_Validate(" + nArrayIndex + "))")
        ETVAL2(WEC_txtTimeOfDay_Validate(nArrayIndex))
        
      Case \txtWhenReqd
        ETVAL2(WEC_txtWhenReqd_Validate())
        
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

Procedure WEC_splEditH_Event()
  PROCNAMEC()
  
  If grEditorPrefs\nSplitterPosEditH <> GGS(WEC\splEditH)
    grEditorPrefs\nSplitterPosEditH = GGS(WEC\splEditH)
    ; debugMsg(sProcName, "WEC\splEditH: grEditorPrefs\nSplitterPosEditH=" + Str(grEditorPrefs\nSplitterPosEditH))
    If IsGadget(WQE\scaMemo)
      WQE_adjustForSplitterSize()
    EndIf
    If IsGadget(WQF\scaSoundFile)
      WQF_adjustForSplitterSize()
    EndIf
    If IsGadget(WQL\scaLevelChange)
      WQL_adjustForSplitterSize()
    EndIf
  EndIf
  
EndProcedure

Procedure WEC_setSplitterHMinSizes()
  ; PROCNAMEC()
  Protected nMinSize
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure sets splitter sizes
  
  ; NOTE: WEC\splEditH frequently has minimum sizes set to 0 by calls to WED_Form_Resized with bForceProcessing set #True,
  ; NOTE: so significant benefit in checking first if the minimum sizes are already set as required.
  
  ; set the minimum height of the cue properties gadget so that the cue label and description is visible
  nMinSize = GadgetY(grCED\nCurrentCueLabelGadgetNo) + GadgetHeight(grCED\nCurrentCueLabelGadgetNo) + 4
  SetGadgetAttribute(WEC\splEditH, #PB_Splitter_FirstMinimumSize, nMinSize)
  
  ; we want to set the maximum height of the cue properties gadget to the cue properties scrollarea inner height,
  ; but as PB has no gadget attribute for 'maximum size' we have to simulate this by setting the minimum height of the sub-cue properties gadget
  nMinSize = GadgetHeight(WEC\splEditH) - GetGadgetAttribute(WEC\scaCueProperties, #PB_ScrollArea_InnerHeight) - gnHSplitterSeparatorHeight - 4
  SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondMinimumSize, nMinSize)
  
EndProcedure

Procedure WEC_loadAutoActivateCueCBO(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected sTmp.s, sTmp2.s
  Protected nCueAutoStartRange
  Protected i
  
  With aCue(pCuePtr)
    Select \nAutoActPosn
      Case #SCS_ACPOSN_AE, #SCS_ACPOSN_AS, #SCS_ACPOSN_BE 
        ClearGadgetItems(WEC\cboAutoActivateCue)
        sTmp2 = #SCS_BLANK_CBO_ENTRY
        addGadgetItemWithData(WEC\cboAutoActivateCue, sTmp2, #SCS_ACCUESEL_DEFAULT)
        If (pCuePtr > 1) Or (\nAutoActCueSelType = #SCS_ACCUESEL_PREV)
          addGadgetItemWithData(WEC\cboAutoActivateCue, Lang("WEC", "PreviousCue"), #SCS_ACCUESEL_PREV)
        EndIf
        If grProd\nRunMode = #SCS_RUN_MODE_LINEAR
          nCueAutoStartRange = #SCS_CUE_AUTO_START_RANGE_EARLIER
        Else
          nCueAutoStartRange = #SCS_CUE_AUTO_START_RANGE_ALL
        EndIf
        If nCueAutoStartRange = #SCS_CUE_AUTO_START_RANGE_EARLIER
          If \nActivationMethod = #SCS_ACMETH_AUTO Or \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
            If \nAutoActCuePtr > pCuePtr
              ; this can occur if the user previously had non-linear mode and selected a later cue, but then change to linear mode
              nCueAutoStartRange = #SCS_CUE_AUTO_START_RANGE_ALL
            EndIf
          EndIf
        EndIf
        Select nCueAutoStartRange
          Case #SCS_CUE_AUTO_START_RANGE_ALL
            For i = 1 To gnLastCue
              sTmp = buildCueForCBO(i)
              If Len(Trim(sTmp)) > 0
                addGadgetItemWithData(WEC\cboAutoActivateCue, sTmp, #SCS_ACCUESEL_DEFAULT)
                If \nActivationMethod = #SCS_ACMETH_AUTO Or \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
                  If aCue(i)\sCue = \sAutoActCue
                    sTmp2 = sTmp
                  EndIf
                EndIf
              EndIf
            Next i
            
          Default ; (including #SCS_CUE_AUTO_START_RANGE_EARLIER)
            For i = (pCuePtr - 1) To 1 Step -1
              sTmp = buildCueForCBO(i)
              If Len(Trim(sTmp)) > 0
                addGadgetItemWithData(WEC\cboAutoActivateCue, sTmp, #SCS_ACCUESEL_DEFAULT)
                If \nActivationMethod = #SCS_ACMETH_AUTO Or \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
                  If aCue(i)\sCue = \sAutoActCue
                    sTmp2 = sTmp
                  EndIf
                EndIf
              EndIf
            Next i
        EndSelect
        
        If (sTmp2 = #SCS_BLANK_CBO_ENTRY) And (\nAutoActCuePtr > 0)
          ; if sTmp2 not set even though \nAutoActCuePtr is set, this may be because the cue has been moved up past the controlling cue
          ; so create an extra entry in the CBO list for the controlling cue
          sTmp2 = buildCueForCBO(\nAutoActCuePtr)
          If Len(Trim(sTmp2)) > 0
            addGadgetItemWithData(WEC\cboAutoActivateCue, sTmp2, #SCS_ACCUESEL_DEFAULT)
          Else
            sTmp2 = #SCS_BLANK_CBO_ENTRY
          EndIf
        EndIf
        
        If \nAutoActCueSelType = #SCS_ACCUESEL_PREV
          SGS(WEC\cboAutoActivateCue, 1)
        Else
          SGT(WEC\cboAutoActivateCue, sTmp2)
        EndIf
        
      Case #SCS_ACPOSN_OCM
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WEC_loadAutoActivateCueMarker(pCuePtr)
  PROCNAMECQ(pCuePtr)
  
  ClearGadgetItems(WEC\cboAutoActivateMarker)
  WEC_addAudioFileMarkers(pCuePtr)
  setComboBoxWidth(WEC\cboAutoActivateMarker, 120)
  
EndProcedure

Procedure WEC_applyCallableCueParams(nCuePtr, sCallableCueParams.s)
  ; Called from WEC_txtCallableCueParams_Validate() when the user edits the callable cue
  ; parameters of a cue with an activation method of 'Callable Cue'.
  ; Not be confused with the procedure applyCallCueParameters() in CueCommon.pbi which is called
  ; from playSubTypeQ(), ie when playing a 'Call Cue' sub-cue.
  PROCNAMECQ(nCuePtr)
  Structure tyReqdParam
    sNewParamId.s
    sNewParamDefault.s
    sOldParamId.s
    sParamValue.s
  EndStructure
  Protected Dim aReqdParam.tyReqdParam(#SCS_MAX_CALLABLE_CUE_PARAM)
  Protected nMaxReqdParam
  Protected nNewIndex, nOldIndex, nNewIndex2, bParamAssigned
  Protected sWorkParams.s, nPartCount, nPartNo, sPart.s, sParamId.s, sParamDefault.s
  Protected sWorkParamId.s
  Protected u, u2
  Protected i, j, k
  Protected sOldCallCueParams.s, sNewCallCueParams.s
  Protected bChangeSub, sThisOldParamId.s, sThisNewParamId.s, sThisNewParamDefault.s, bRedisplaySub
  Protected nCtrlSendIndex, nLvlChgIndex
  Protected nOldFadeInTime, nOldFadeOutTime
  
  sWorkParams = Trim(sCallableCueParams)
  ; nb may be blank
  nMaxReqdParam = -1
  If sWorkParams
    nPartCount = CountString(sWorkParams, ",") + 1
    For nPartNo = 1 To nPartCount
      sPart = Trim(StringField(sWorkParams, nPartNo, ","))
      If sPart
        sParamId = Trim(StringField(sPart, 1, "="))
        sParamDefault = Trim(StringField(sPart, 2, "="))
        ; debugMsg(sProcName, "nPartNo=" + nPartNo + ", sParamId=" + sParamId + ", sParamDefault=" + sParamDefault)
        nMaxReqdParam + 1
        aReqdParam(nMaxReqdParam)\sNewParamId = sParamId
        aReqdParam(nMaxReqdParam)\sNewParamDefault = sParamDefault
      EndIf
    Next nPartNo
  EndIf
  
  With aCue(nCuePtr)
    For nOldIndex = 0 To \nMaxCallableCueParam
      For nNewIndex = 0 To nMaxReqdParam
        If UCase(aReqdParam(nNewIndex)\sNewParamId) = UCase(\aCallableCueParam(nOldIndex)\sCallableParamId)
          ; paramid match found, regardless of case and position
          aReqdParam(nNewIndex)\sOldParamId = \aCallableCueParam(nOldIndex)\sCallableParamId
        EndIf
      Next nNewIndex
    Next nOldIndex
    ; Now look for any old paramid's that were not matched, and where the corresponding position is also unmatched, which we assume means the paramid has been changed
    For nNewIndex = 0 To nMaxReqdParam
      If Len(aReqdParam(nNewIndex)\sOldParamId) = 0
        ; no old paramid found for this position
        ; check if this new paramid is assigned elsewhere
        If nNewIndex <= \nMaxCallableCueParam
          sWorkParamId = \aCallableCueParam(nNewIndex)\sCallableParamId ; aReqdParam(nNewIndex)\sNewParamId
          bParamAssigned = #False
          For nNewIndex2 = 0 To nMaxReqdParam
            If UCase(aReqdParam(nNewIndex2)\sNewParamId) = UCase(sWorkParamId)
              bParamAssigned = #True
              Break
            EndIf
          Next nNewIndex2
          If bParamAssigned = #False
            ; assume id for this position has been changed
            aReqdParam(nNewIndex)\sOldParamId = \aCallableCueParam(nNewIndex)\sCallableParamId
          EndIf
        EndIf
      EndIf
    Next nNewIndex
    
  EndWith
  
  For nNewIndex = 0 To nMaxReqdParam
    With aReqdParam(nNewIndex)
      debugMsg(sProcName, "aReqdParam(" + nNewIndex+ ")\sNewParamId=" + \sNewParamId + ", \sOldParamId=" + \sOldParamId + ", \sNewParamDefault=" + \sNewParamDefault)
    EndWith
  Next nNewIndex
  
  u = preChangeCueS(aCue(nCuePtr)\sCallableCueParams, GGT(WEC\lblCallableCueParams), nCuePtr)
  
  ; In the following scan of cues and sub-cues, do NOT consider the 'enabled' state as any changes must be applied whether or not a subcue is enabled
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeQ
      ; Cue contains at least one 'call cue'
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubTypeQ
            ; This is a 'call cue' sub-cue
            If \nCallCuePtr = nCuePtr
              ; This 'Call Cue' calls the cue pointed to be the procedure parameter nCuePtr
              ; Initially clear all parameter values
              For nNewIndex = 0 To nMaxReqdParam
                aReqdParam(nNewIndex)\sParamValue = ""
              Next nNewIndex
              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nMaxCallCueParam=" + \nMaxCallCueParam + ", nMaxReqdParam=" + nMaxReqdParam)
              For nOldIndex = 0 To \nMaxCallCueParam
                ; debugMsg(sProcName, "nOldIndex=" + nOldIndex)
                For nNewIndex = 0 To nMaxReqdParam
                  ; debugMsg(sProcName, "aReqdParam(" + nNewIndex + ")\sOldParamId=" + aReqdParam(nNewIndex)\sOldParamId + ", aSub(" + getSubLabel(j) + ")\aCallCueParam(" + nOldIndex + ")\sCallParamId=" + \aCallCueParam(nOldIndex)\sCallParamId)
                  If aReqdParam(nNewIndex)\sOldParamId = \aCallCueParam(nOldIndex)\sCallParamId
                    ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\aCallCueParam(" + nOldIndex + ")\sCallParamValue=" + \aCallCueParam(nOldIndex)\sCallParamValue)
                    aReqdParam(nNewIndex)\sParamValue = \aCallCueParam(nOldIndex)\sCallParamValue
                    Break ; Break nNewIndex because this existing (old) paramid has been found in the new array, and the existing paramvalue has been saved in the new array
                  EndIf
                Next nNewIndex
              Next nOldIndex
              ; Now apply the changes, if required, to this 'Call Cue' sub-cue, ie to aSub(j)
              sOldCallCueParams = \sCallCueParams
              sNewCallCueParams = ""
              For nNewIndex = 0 To nMaxReqdParam
                sPart = aReqdParam(nNewIndex)\sNewParamId
                If aReqdParam(nNewIndex)\sParamValue
                  sPart + "=" + aReqdParam(nNewIndex)\sParamValue
                EndIf
                If nNewIndex = 0
                  sNewCallCueParams = sPart
                Else
                  sNewCallCueParams + ", " + sPart
                EndIf
              Next nNewIndex
              debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sCallCueParams=" + #DQUOTE$ + aSub(j)\sCallCueParams + #DQUOTE$ + ", sNewCallCueParams=" + #DQUOTE$ + sNewCallCueParams + #DQUOTE$)
              If sNewCallCueParams <> sOldCallCueParams
                ; at least one change found
                u2 = preChangeSubS(sOldCallCueParams, Lang("Common","Parameters"), j, #SCS_UNDO_ACTION_CHANGE)
                \sCallCueParams = sNewCallCueParams
                \nMaxCallCueParam = nMaxReqdParam
                If nMaxReqdParam > ArraySize(\aCallCueParam())
                  ReDim \aCallCueParam(nMaxReqdParam)
                EndIf
                For nNewIndex = 0 To nMaxReqdParam
                  \aCallCueParam(nNewIndex)\sCallParamId = aReqdParam(nNewIndex)\sNewParamId
                  \aCallCueParam(nNewIndex)\sCallParamValue = aReqdParam(nNewIndex)\sParamValue
                  \aCallCueParam(nNewIndex)\sCallParamDefault = aReqdParam(nNewIndex)\sNewParamDefault
                Next nNewIndex
                postChangeSubS(u2, sNewCallCueParams, j)
              EndIf ; EndIf sNewCallCueParams <> sOldCallCueParams
            EndIf ; EndIf \nCallCuePtr = nCuePtr
          EndIf ; EndIf \bSubTypeQ
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
    ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", j=" + getSubLabel(j) + ", nCuePtr=" + getCueLabel(nCuePtr))
    If i = nCuePtr
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          ; sub-cue is a child of the callable cue we are changing
          ; debugMsg(sProcName, "\sSubType=" + \sSubType + ", aCue(" + getCueLabel(i) + ")\nMaxCallableCueParam=" + aCue(i)\nMaxCallableCueParam)
          bChangeSub = #False
          If \bSubTypeF ; NOTE: SubType F (Audio File)
            k = \nFirstAudIndex
            For nOldIndex = 0 To aCue(i)\nMaxCallableCueParam
              sThisOldParamId = aCue(i)\aCallableCueParam(nOldIndex)\sCallableParamId
              If aAud(k)\sFadeInTime = sThisOldParamId : bChangeSub = #True : Break : EndIf
              If aAud(k)\sFadeOutTime = sThisOldParamId : bChangeSub = #True : Break : EndIf
            Next nOldIndex
          ElseIf \bSubTypeK ; NOTE SubType K (Lighting)
            For nOldIndex = 0 To aCue(i)\nMaxCallableCueParam
              sThisOldParamId = aCue(i)\aCallableCueParam(nOldIndex)\sCallableParamId
              If \nLTEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
                If \sLTBLFadeUserTime = sThisOldParamId : bChangeSub = #True : Break : EndIf
              ElseIf \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                If \sLTDCFadeUpUserTime = sThisOldParamId Or \sLTDCFadeDownUserTime = sThisOldParamId : bChangeSub = #True : Break : EndIf
              ElseIf \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_ITEMS
                If \sLTDIFadeUpUserTime = sThisOldParamId Or \sLTDIFadeDownUserTime = sThisOldParamId Or \sLTDIFadeOutOthersUserTime = sThisOldParamId : bChangeSub = #True : Break : EndIf
              ElseIf \nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                If \sLTFIFadeUpUserTime = sThisOldParamId Or \sLTFIFadeDownUserTime = sThisOldParamId Or \sLTFIFadeOutOthersUserTime = sThisOldParamId : bChangeSub = #True : Break:  EndIf
              EndIf
            Next nOldIndex
          ElseIf \bSubTypeL ; NOTE: SubType L (Level Change)
            For nOldIndex = 0 To aCue(i)\nMaxCallableCueParam
              sThisOldParamId = aCue(i)\aCallableCueParam(nOldIndex)\sCallableParamId
              For nLvlChgIndex = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                If \sLCTime[nLvlChgIndex] = sThisOldParamId : bChangeSub = #True : Break : EndIf
              Next nLvlChgIndex
            Next nOldIndex
          ElseIf \bSubTypeM ; NOTE: SubType M (Control Send)
            For nOldIndex = 0 To aCue(i)\nMaxCallableCueParam
              sThisOldParamId = aCue(i)\aCallableCueParam(nOldIndex)\sCallableParamId
              For nCtrlSendIndex = 0 To #SCS_MAX_CTRL_SEND
                Select \aCtrlSend[nCtrlSendIndex]\nMSMsgType
                  Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam1 = sThisOldParamId : bChangeSub = #True : Break 2 : EndIf
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam2 = sThisOldParamId : bChangeSub = #True : Break 2 : EndIf
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam3 = sThisOldParamId : bChangeSub = #True : Break 2 : EndIf
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam4 = sThisOldParamId : bChangeSub = #True : Break 2 : EndIf
                EndSelect
              Next nCtrlSendIndex
            Next nOldIndex
          ElseIf \bSubTypeS ; NOTE: SubType S (SFR)
            For nOldIndex = 0 To aCue(i)\nMaxCallableCueParam
              sThisOldParamId = aCue(i)\aCallableCueParam(nOldIndex)\sCallableParamId
              If \sSFRTimeOverride = sThisOldParamId : bChangeSub = #True : Break : EndIf
            Next nOldIndex
          EndIf
          
          If bChangeSub ; NOTE: Change detected
            u2 = preChangeSubL(#True, GGT(WEC\lblCallableCueParams), j)
            For nOldIndex = 0 To aCue(i)\nMaxCallableCueParam
              sThisOldParamId = aCue(i)\aCallableCueParam(nOldIndex)\sCallableParamId
              sThisNewParamId = ""
              sThisNewParamDefault = ""
              For nNewIndex = 0 To nMaxReqdParam
                If aReqdParam(nNewIndex)\sOldParamId = sThisOldParamId
                  sThisNewParamId = aReqdParam(nNewIndex)\sNewParamId
                  sThisNewParamDefault = aReqdParam(nNewIndex)\sNewParamDefault
                  Break
                EndIf
              Next nNewIndex
              If \bSubTypeF ; NOTE: SubType F (Audio File)
                k = \nFirstAudIndex
                If aAud(k)\sFadeInTime = sThisOldParamId
                  nOldFadeInTime = aAud(k)\nFadeInTime
                  aAud(k)\sFadeInTime = sThisNewParamId
                  If sThisNewParamId = ""
                    aAud(k)\nFadeInTime = grAudDef\nFadeInTime
                  ElseIf IsNumeric(sThisNewParamId)
                    aAud(k)\nFadeInTime = stringToTime(sThisNewParamId)
                  Else
                    If sThisNewParamDefault
                      aAud(k)\nFadeInTime = stringToTime(sThisNewParamDefault)
                    Else
                      ; no parameter default
                      aAud(k)\nFadeInTime = 1 ; 'dummy' value (1 millisecond) so that a Fade In Level Point will be created
                    EndIf
                  EndIf
                  aAud(k)\nCurrFadeInTime = aAud(k)\nFadeInTime
                  debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFadeInTime=" + aAud(k)\sFadeInTime + ", \nFadeInTime=" + aAud(k)\nFadeInTime)
                  debugMsg(sProcName, "calling maintainFadeInLevelPoint(" + getAudLabel(k) + ", " + nOldFadeInTime + ", " + aAud(k)\nFadeInTime + ")")
                  maintainFadeInLevelPoint(k, nOldFadeInTime, aAud(k)\nFadeInTime)
                EndIf
                If aAud(k)\sFadeOutTime = sThisOldParamId
                  nOldFadeOutTime = aAud(k)\nFadeOutTime
                  aAud(k)\sFadeOutTime = sThisNewParamId
                  If sThisNewParamId = ""
                    aAud(k)\nFadeOutTime = grAudDef\nFadeOutTime
                  ElseIf IsNumeric(sThisNewParamId)
                    aAud(k)\nFadeOutTime = stringToTime(sThisNewParamId)
                  Else
                    If sThisNewParamDefault
                      aAud(k)\nFadeOutTime = stringToTime(sThisNewParamDefault)
                    Else
                      ; no parameter default
                      aAud(k)\nFadeOutTime = 1 ; 'dummy' value (1 millisecond) so that a Fade In Level Point will be created
                    EndIf
                  EndIf
                  aAud(k)\nCurrFadeOutTime = aAud(k)\nFadeOutTime
                  debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFadeOutTime=" + aAud(k)\sFadeOutTime + ", \nFadeOutTime=" + aAud(k)\nFadeOutTime)
                  debugMsg(sProcName, "calling maintainFadeOutLevelPoint(" + getAudLabel(k) + ", " + nOldFadeOutTime + ", " + aAud(k)\nFadeOutTime + ")")
                  maintainFadeOutLevelPoint(k, nOldFadeOutTime, aAud(k)\nFadeOutTime)
                EndIf
              ElseIf \bSubTypeK ; NOTE SubType K (Lighting)
                If \nLTEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
                  If \sLTBLFadeUserTime = sThisOldParamId : \sLTBLFadeUserTime = sThisNewParamId : EndIf
                ElseIf \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                  If \sLTDCFadeUpUserTime = sThisOldParamId : \sLTDCFadeUpUserTime = sThisNewParamId : EndIf
                  If \sLTDCFadeDownUserTime = sThisOldParamId : \sLTDCFadeDownUserTime = sThisNewParamId : EndIf
                ElseIf \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_ITEMS
                  If \sLTDIFadeUpUserTime = sThisOldParamId : \sLTDIFadeUpUserTime = sThisNewParamId : EndIf
                  If \sLTDIFadeDownUserTime = sThisOldParamId : \sLTDIFadeDownUserTime = sThisNewParamId : EndIf
                  If \sLTDIFadeOutOthersUserTime = sThisOldParamId : \sLTDIFadeOutOthersUserTime = sThisNewParamId : EndIf
                ElseIf \nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                  If \sLTFIFadeUpUserTime = sThisOldParamId : \sLTFIFadeUpUserTime = sThisNewParamId : EndIf
                  If \sLTFIFadeDownUserTime = sThisOldParamId : \sLTFIFadeDownUserTime = sThisNewParamId : EndIf
                  If \sLTFIFadeOutOthersUserTime = sThisOldParamId : \sLTFIFadeOutOthersUserTime = sThisNewParamId : EndIf
                EndIf
              ElseIf \bSubTypeL ; NOTE: SubType L (Level Change)
                For nLvlChgIndex = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                  If \sLCTime[nLvlChgIndex] = sThisOldParamId : \sLCTime[nLvlChgIndex] = sThisNewParamId : EndIf
                Next nLvlChgIndex
              ElseIf \bSubTypeM ; NOTE: SubType M (Control Send)
                For nCtrlSendIndex = 0 To #SCS_MAX_CTRL_SEND
                  Select \aCtrlSend[nCtrlSendIndex]\nMSMsgType
                    Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF
                      If \aCtrlSend[nCtrlSendIndex]\sMSParam1 = sThisOldParamId : \aCtrlSend[nCtrlSendIndex]\sMSParam1 = sThisNewParamId : EndIf
                      If \aCtrlSend[nCtrlSendIndex]\sMSParam2 = sThisOldParamId : \aCtrlSend[nCtrlSendIndex]\sMSParam2 = sThisNewParamId : EndIf
                      If \aCtrlSend[nCtrlSendIndex]\sMSParam3 = sThisOldParamId : \aCtrlSend[nCtrlSendIndex]\sMSParam3 = sThisNewParamId : EndIf
                      If \aCtrlSend[nCtrlSendIndex]\sMSParam4 = sThisOldParamId : \aCtrlSend[nCtrlSendIndex]\sMSParam4 = sThisNewParamId : EndIf
                  EndSelect
                Next nCtrlSendIndex
              ElseIf \bSubTypeS ; NOTE: SubType S (SFR)
                If \sSFRTimeOverride = sThisOldParamId : \sSFRTimeOverride = sThisNewParamId : EndIf
              EndIf
            Next nOldIndex
            
            postChangeSubL(u2, #False, j)
            ; debugMsg0(sProcName, "nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", gnDisplayedSubPtr=" + getSubLabel(gnDisplayedSubPtr))
            If j = gnDisplayedSubPtr
              bRedisplaySub = #True
            EndIf
          EndIf ; EndIf bChangeSub
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf ; EndIf i = nCuePtr
  Next i
  
  aCue(nCuePtr)\sCallableCueParams = sWorkParams
  populateCallableCueParamArray(@aCue(nCuePtr))
  postChangeCueS(u, sWorkParams, nCuePtr)
  
  markValidationOK(WEC\txtCallableCueParams)
  grWEC\bInValidate = #False
  
  If bRedisplaySub And gbInDisplaySub = #False
    debugMsg(sProcName, "calling displaySub(" + getSubLabel(gnDisplayedSubPtr) + ")")
    displaySub(gnDisplayedSubPtr)
  EndIf

EndProcedure

Procedure WEC_txtCallableCueParams_Validate()
  PROCNAMECQ(nEditCuePtr)
  Protected sMsg.s
  Protected sWorkParams.s, nPartCount, nPartNo, sPart.s, sParamId.s, sParamDefault.s, nChar, sChar.s
  Protected sDeletedParamId.s, sOldParamId.s, sNewParamId.s, sOldParamDefault.s, sNewParamDefault.s, sOldCombined.s, sNewCombined.s
  Protected sValidFirstChar.s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  Protected sValidOtherChar.s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
  Protected bParamIdValid
  Structure tyOldCallableParam
    sOldParamId.s
    sOldParamDefault.s
    sNewParamId.s
    sNewParamDefault.s
  EndStructure
  Structure tyNewCallableParam
    sNewParamId.s
    sNewParamDefault.s
    nSeqNoInOld.i
  EndStructure
  Protected Dim aOldParam.tyOldCallableParam(#SCS_MAX_CALLABLE_CUE_PARAM)
  Protected Dim aNewParam.tyNewCallableParam(#SCS_MAX_CALLABLE_CUE_PARAM)
  Protected nMaxNewParam
  Protected i, j, n1, n2, sThisCue.s, bChangeSub, bRedisplaySub
  Protected bTrace = #False
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEC\bInValidate
    ProcedureReturn #True
  EndIf
  grWEC\bInValidate = #True
  
  ; NOTE: Populate the array aCue(nEditCuePtr)\aCallableCueParam() from aCue(nEditCuePtr)\sCallableCueParams 
  populateCallableCueParamArray(@aCue(nEditCuePtr))
  ; NOTE: Now copy those details to the local array aOldParam()
  With aCue(nEditCuePtr)
    For n2 = 0 To #SCS_MAX_CALLABLE_CUE_PARAM
      If n2 <= \nMaxCallableCueParam
        aOldParam(n2)\sOldParamId = \aCallableCueParam(n2)\sCallableParamId ; ParamId = the parameter name, eg "UP"
        aOldParam(n2)\sOldParamDefault = \aCallableCueParam(n2)\sCallableParamDefault ; The default value for this parameter, eg "1.5"
      EndIf
      aNewParam(n2)\nSeqNoInOld = -1 ; initially set all nSeqNoInOld to -1 in array aNewParam()
    Next n2
  EndWith
  
  sWorkParams = Trim(GGT(WEC\txtCallableCueParams))
  ; nb may be blank
  nMaxNewParam = -1
  If sWorkParams
    ; NOTE: Validate the new parameters, and if all validation is successful then load the parameters details in to the local array aNewParam()
    nPartCount = CountString(sWorkParams, ",") + 1
    If nPartCount > (#SCS_MAX_CALLABLE_CUE_PARAM + 1)
      sMsg = LangPars("Errors", "TooManyParams", Str(#SCS_MAX_CALLABLE_CUE_PARAM + 1))
      debugMsg(sProcName, sMsg)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      grWEC\bInValidate = #False
      ProcedureReturn #False
    EndIf
    For nPartNo = 1 To nPartCount
      sPart = Trim(StringField(sWorkParams, nPartNo, ","))
      If sPart
        sParamId = Trim(StringField(sPart, 1, "="))
        sParamDefault = Trim(StringField(sPart, 2, "="))
        debugMsgC0(sProcName, "nPartNo=" + nPartNo + ", sParamId=" + sParamId + ", sParamDefault=" + sParamDefault)
        ; make sure sParamId is valid
        If Len(sParamId) = 0
          sMsg = LangPars("Errors", "ParamIdReqd", Str(nPartNo))
          debugMsg(sProcName, sMsg)
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          grWEC\bInValidate = #False
          ProcedureReturn #False
        EndIf
        bParamIdValid = #True
        For nChar = 1 To Len(sParamId)
          sChar = Mid(sParamId, nChar, 1)
          If nChar = 1
            If FindString(sValidFirstChar, sChar, 1, #PB_String_NoCase) = 0
              ; unacceptable first character of a fixture code
              bParamIdValid = #False
              Break
            EndIf
          Else
            If FindString(sValidOtherChar, sChar, 1, #PB_String_NoCase) = 0
              ; unacceptable character in a fixture code
              bParamIdValid = #False
              Break
            EndIf
          EndIf
        Next nChar
        If bParamIdValid = #False
          sMsg =  LangPars("Errors", "ParamIdInvalid", Str(nPartNo), sParamId)
          debugMsg(sProcName, sMsg)
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          grWEC\bInValidate = #False
          ProcedureReturn #False
        EndIf
      EndIf
      For n2 = 0 To nMaxNewParam
        If UCase(sParamId) = UCase(aNewParam(n2)\sNewParamId)
          sMsg = LangPars("Errors", "ParamIdDuplicated", sParamId)
          debugMsg(sProcName, sMsg)
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          grWEC\bInValidate = #False
          ProcedureReturn #False
        EndIf
      Next n2
      nMaxNewParam + 1
      aNewParam(nMaxNewParam)\sNewParamId = sParamId
      aNewParam(nMaxNewParam)\sNewParamDefault = sParamDefault
      aNewParam(nMaxNewParam)\nSeqNoInOld = -1 ; will be assigned, if found, later
    Next nPartNo
  EndIf ; EndIf sWorkParams
  ; initial validation successful
  
  ; NOTE: Try to combine arrays
  For n1 = 0 To nMaxNewParam
    sParamId = aNewParam(n1)\sNewParamId
    sParamDefault = aNewParam(n1)\sNewParamDefault
    For n2 = 0 To #SCS_MAX_CALLABLE_CUE_PARAM
      If UCase(aOldParam(n2)\sOldParamId) = UCase(sParamId)
        ; new paramid found in the existing (old) params
        aOldParam(n2)\sNewParamId = sParamId
        aOldParam(n2)\sNewParamDefault = sParamDefault
        aNewParam(n1)\nSeqNoInOld = n2
        Break
      EndIf
    Next n2
  Next n1
  For n1 = 0 To #SCS_MAX_CALLABLE_CUE_PARAM
    If aOldParam(n1)\sOldParamId
      If Len(aOldParam(n1)\sNewParamId) = 0
        ; old paramid not found in the new params
        If n1 <= nMaxNewParam
          If aNewParam(n1)\nSeqNoInOld = -1
            ; corresponding entry (by order) has not yet been assigned, so assume this is a name change
            aOldParam(n1)\sNewParamId = aNewParam(n1)\sNewParamId
            aOldParam(n1)\sNewParamDefault = aNewParam(n1)\sNewParamDefault
            aNewParam(n1)\nSeqNoInOld = n1
          EndIf
        EndIf
      EndIf
    EndIf
  Next n1
  ; State now:-
  ; - any sOldParamId in array aOldParam() that has a blank sNewParamId has been deleted by the user
  ; - any sOldParamId in array aOldParam() that has a different sNewParamId is deemed to be a name change
  ; - any sNewParamId in array sNewParam() that has nSeqNoInOld = -1 is a new parameter
  
  If bTrace
    For n1 = 0 To #SCS_MAX_CALLABLE_CUE_PARAM
      With aOldParam(n1)
        debugMsg0(sProcName, "aOldParam(" + n1 + ")\sOldParamId=" + \sOldParamId + ", \sNewParamId=" + \sNewParamId + ", \sOldParamDefault=" + \sOldParamDefault + ", \sNewParamDefault=" + \sNewParamDefault)
      EndWith
    Next n1
  EndIf
  
  ; Now check that no deleted parameters are currently being used in cues that call this cue
  sThisCue = aCue(nEditCuePtr)\sCue
  For n1 = 0 To #SCS_MAX_CALLABLE_CUE_PARAM
    If aOldParam(n1)\sOldParamId
      If Len(aOldParam(n1)\sNewParamId) = 0
        sDeletedParamId = aOldParam(n1)\sOldParamId
        For i = 1 To gnLastCue
          If aCue(i)\bSubTypeQ
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              With aSub(j)
                If \bSubTypeQ And \sCallCue = sThisCue
                  For n2 = 0 To \nMaxCallCueParam
                    If UCase(\aCallCueParam(n2)\sCallParamId) = UCase(sDeletedParamId) And Trim(\aCallCueParam(n2)\sCallParamValue)
                      sMsg = LangPars("Errors", "ParamIdDeleted", sDeletedParamId, \sSubLabel)
                      debugMsg(sProcName, sMsg)
                      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
                      grWEC\bInValidate = #False
                      ProcedureReturn #False
                    EndIf
                  Next n2
                EndIf ; EndIf \bSubTypeQ And \sCallCue = sThisCue
                j = \nNextSubIndex
              EndWith
            Wend
          EndIf ; EndIf aCue(i)\bSubTypeQ
        Next i
      EndIf ; EndIf Len(aOldParam(n1)\sNewParamId) = 0
    EndIf ; EndIf aOldParam(n1)\sOldParamId
  Next n1
  ; validation completed successfully
  
  ; debugMsg(sProcName, "sWorkParams=" + sWorkParams + ", aCue(" + getCueLabel(nEditCuePtr) + ")\sCallableCueParams=" + aCue(nEditCuePtr)\sCallableCueParams)
  If sWorkParams <> aCue(nEditCuePtr)\sCallableCueParams
    WEC_applyCallableCueParams(nEditCuePtr, sWorkParams)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WEC_calcDataValueForCueHotkey(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected n, nKeyNumber, sMyHotkey.s, nDataValue
  Protected nCueHotkeyBank, sCueHotkey.s, nCueHotkeyStepNo
  
  nCueHotkeyBank = aCue(pCuePtr)\nHotkeyBank
  sCueHotkey = aCue(pCuePtr)\sHotkey
  If aCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_HK_STEP
    nCueHotkeyStepNo = aCue(pCuePtr)\nCueHotkeyStepNo
  EndIf
  
  For nKeyNumber = 1 To CountString(gsValidHotkeys, ",") + 1
    sMyHotkey = StringField(gsValidHotkeys, nKeyNumber, ",")
    ; debugMsg(sProcName, "nKeyNumber=" + nKeyNumber + ", sMyHotkey=" + #DQUOTE$ + sMyHotkey + #DQUOTE$)
    For n = 0 To gnMaxHotkey
      With gaHotkeys(n)
        If \sHotkey = sMyHotkey
          If \nHotkeyBank = nCueHotkeyBank And \sHotkey = sCueHotkey And \nHotkeyStepNo = nCueHotkeyStepNo
            nDataValue = (nKeyNumber << 16) | nCueHotkeyStepNo
            Break
          EndIf
        EndIf
      EndWith
    Next n
  Next nKeyNumber
  debugMsg0(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nActivationMethod=" + decodeActivationMethod(aCue(pCuePtr)\nActivationMethod) + ", nCueHotkeyBank=" + nCueHotkeyBank + ", sCueHotkey=" + sCueHotkey + ", nCueHotkeyStepNo=" + nCueHotkeyStepNo + ", returning nDataValue=" + nDataValue)
  ProcedureReturn nDataValue
  
EndProcedure

; EOF