; File: fmEditSub.pbi

; procedures common to several sub-cue processes

EnableExplicit

Procedure SUB_populateCboSubStart(nGadgetNo)
  PROCNAMEC()
  Static sRelStart.s, sRelMTC.s, sOCM.s, bStaticLoaded
  Protected nOriginalLeft, nOriginalWidth, nNewWidth, nNewLeft
  
  If bStaticLoaded = #False
    sRelStart = Lang("Common", "RelativeStart")
    sRelMTC = Lang("Common", "RelativeMTC")
    sOCM = Lang("Common", "OCM")
    bStaticLoaded = #True
  EndIf
  
  nOriginalLeft = GadgetX(nGadgetNo)
  nOriginalWidth = GadgetWidth(nGadgetNo)
  
  ClearGadgetItems(nGadgetNo)
  addGadgetItemWithData(nGadgetNo, sRelStart, #SCS_SUBSTART_REL_TIME)
  ; MTC listed before OCM to match the order in the cue's action method - see WEC_loadActivationMethodCBO()
  If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
    addGadgetItemWithData(nGadgetNo, sRelMTC, #SCS_SUBSTART_REL_MTC)
  EndIf
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    addGadgetItemWithData(nGadgetNo, sOCM, #SCS_SUBSTART_OCM)
  EndIf
  setComboBoxWidth(nGadgetNo)
  nNewWidth = GadgetWidth(nGadgetNo)
  If nNewWidth <> nOriginalLeft
    nNewLeft = nOriginalLeft + (nOriginalWidth - nNewWidth)
    ResizeGadget(nGadgetNo, nNewLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
  
EndProcedure

Procedure SUB_setCboSubStart(nGadgetNo, nSubStart)
  setComboBoxByData(nGadgetNo, nSubStart)
EndProcedure

Procedure SUB_cboSubStart_Click(nGadgetNo)
  PROCNAMECS(nEditSubPtr)
  Protected nPrevSubStart, nNewSubStart, nCuePtr
  Protected bCueMarkerArraysPopulated, n, bCueMarkersPresent
  Protected sErrorMsg.s
  Protected u
  
  debugMsg(sProcName, #SCS_START)

  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)
    nPrevSubStart = \nSubStart
    nNewSubStart = getCurrentItemData(nGadgetNo)
    If nNewSubStart <> nPrevSubStart
      nCuePtr = \nCueIndex
      Select nNewSubStart
        Case #SCS_SUBSTART_REL_MTC
          If aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_MTC
            sErrorMsg = LangPars("CED", "RelMTCNotAvail", GGT(nGadgetNo), getCueLabel(nCuePtr), decodeActivationMethodL(#SCS_ACMETH_MTC))
          EndIf
        Case #SCS_SUBSTART_OCM
          debugMsg(sProcName, "calling loadCueMarkerArrays()")
          loadCueMarkerArrays()
          bCueMarkerArraysPopulated = #True
          For n = 0 To gnMaxCueMarkerInfo
            If gaCueMarkerInfo(n)\bOCMAvailable
              If gaCueMarkerInfo(n)\nHostCuePtr = nCuePtr
                bCueMarkersPresent = #True
                Break
              EndIf
            EndIf
          Next n
          If bCueMarkersPresent = #False
            sErrorMsg = LangPars("CED", "SubOCMNotAvail", GGT(nGadgetNo), getCueLabel(nCuePtr))
          EndIf
      EndSelect
      If sErrorMsg
        ensureSplashNotOnTop()
        scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
        setComboBoxByData(nGadgetNo, nPrevSubStart, 0)
        ProcedureReturn #False
      EndIf
      u = preChangeSubL(\nSubStart, Lang("CED", "cboSubStartTT")) ; nb use tooltip as this field has no directly-associated label
      \nSubStart = nNewSubStart
      SUB_fcSubStart(\sSubType)
      postChangeSubL(u, \nSubStart)
    EndIf
    If nNewSubStart = #SCS_SUBSTART_OCM Or nPrevSubStart = #SCS_SUBSTART_OCM
      If bCueMarkerArraysPopulated = #False
        debugMsg(sProcName, "calling loadCueMarkerArrays()")
        loadCueMarkerArrays()
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure SUB_cboRelStartMode_Click(nGadgetNo)
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  Protected u
  
  debugMsg(sProcName, #SCS_START)

  If gbInDisplayCue
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nRelStartMode, Lang("CED", "cboRelStartModeTT")) ; nb use tooltip as this field has no directly-associated label
    nListIndex = GGS(nGadgetNo)
    \nRelStartMode = GetGadgetItemData(nGadgetNo, nListIndex)
    ; SUB_fcRelStartMode()
    ; added 27Dec2018 11.8.0cm to force re-display of 'other info' in cue panel
    gnRefreshCuePtr = nEditCuePtr
    gnRefreshSubPtr = nEditSubPtr
    gnRefreshAudPtr = nEditAudPtr
    gbCallReloadDispPanel = #True
    ; end added 27Dec2018 11.8.0cm
    postChangeSubL(u, \nRelStartMode)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure SUB_populateCboRelStartMode(nGadgetNo)
  PROCNAMEC()
  Static sAsCue.s, sAsPrevSub.s, sAePrevSub.s, sBePrevSub.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sAsCue = Lang("Common", "RelStartASCue")
    sAsPrevSub = Lang("Common", "RelStartASPrevSub")
    sAePrevSub = Lang("Common", "RelStartAEPrevSub")
    sBePrevSub = Lang("Common", "RelStartBEPrevSub")
    bStaticLoaded = #True
  EndIf
  
  ClearGadgetItems(nGadgetNo)
  addGadgetItemWithData(nGadgetNo, "", #SCS_RELSTART_DEFAULT)
  addGadgetItemWithData(nGadgetNo, sAsCue, #SCS_RELSTART_AS_CUE)
  addGadgetItemWithData(nGadgetNo, sAsPrevSub, #SCS_RELSTART_AS_PREV_SUB)
  addGadgetItemWithData(nGadgetNo, sAePrevSub, #SCS_RELSTART_AE_PREV_SUB)
  addGadgetItemWithData(nGadgetNo, sBePrevSub, #SCS_RELSTART_BE_PREV_SUB)
  setComboBoxWidth(nGadgetNo)
  
EndProcedure

Procedure SUB_setCboRelStartMode(nGadgetNo, nRelStartMode)
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", nRelStartMode=" + nRelStartMode)
  nListIndex = indexForComboBoxData(nGadgetNo, nRelStartMode)
  debugMsg(sProcName, "nListIndex=" + nListIndex)
  SGS(nGadgetNo, nListIndex)
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SUB_populateCboRelStartSubCue(nGadgetNo)
  PROCNAMEC()
  Protected i, j
  Protected Dim aSubCueInfo.s(100)
  Protected Dim aSubCuePtr(100)
  Protected n, nMaxItem
  
  n = -1
  For i = 1 To nEditCuePtr
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If j <> nEditSubPtr
        If aSub(j)\bSubTypeF
          n + 1
          If n > ArraySize(aSubCueInfo())
            ReDim aSubCueInfo(n+100)
            ReDim aSubCuePtr(n+100)
          EndIf
          aSubCueInfo(n) = aSub(j)\sSubLabel + " " + aSub(j)\sSubDescr
          aSubCuePtr(n) = j
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  nMaxItem = n
  
  ClearGadgetItems(nGadgetNo)
  ; add subcue labels in reverse order (most recent subcue first)
  For n = nMaxItem To 0 Step -1
    addGadgetItemWithData(nGadgetNo, aSubCueInfo(n), aSubCuePtr(n))
  Next n
  
EndProcedure

Procedure SUB_txtRelStartTime_Validate(hTxtRelStartTime, hLblRelStart)
  PROCNAMECS(nEditSubPtr)
  Protected nTime
  Protected u
  Protected sRelStartTime.s, sLabel.s
  
  If nEditSubPtr < 0
    ProcedureReturn #False
  EndIf
  
  sRelStartTime = GetGadgetText(hTxtRelStartTime)
  sLabel = GetGadgetText(hLblRelStart)
  
  debugMsg(sProcName, "txtRelStartTime=" + sRelStartTime)
  debugMsg(sProcName, "calling validateTimeField")
  If validateTimeField(sRelStartTime, sLabel, #False, #False, 0, #True) = #False
    debugMsg(sProcName, "validateTimeField returned False")
    ProcedureReturn #False
  ElseIf sRelStartTime <> gsTmpString
    sRelStartTime = gsTmpString
    SGT(hTxtRelStartTime, sRelStartTime)
  EndIf
  
  With aSub(nEditSubPtr)
    debugMsg(sProcName, "setting nTime to " + sRelStartTime)
    nTime = stringToTime(sRelStartTime)
    
    u = preChangeSubL(\nRelStartTime, sLabel)
    \nRelStartTime = nTime
    
    ; call setCuePtrs as changing the RelStartTime could affect linked audio files
    setCuePtrs(#False)
    gbCallPopulateGrid = #True
    ;gbCallLoadDispPanels = True
    gnRefreshCuePtr = nEditCuePtr
    gnRefreshSubPtr = nEditSubPtr
    gnRefreshAudPtr = nEditAudPtr
    ; changed 27Dec2018 11.8.0cm from gbCallPNL_refreshDispPanel to gbCallReloadDispPanel to force reload of 'other info' in cue panel
    ; gbCallPNL_refreshDispPanel = #True
    gbCallReloadDispPanel = #True
    
    postChangeSubL(u, \nRelStartTime)
    
  EndWith
  
  markValidationOK(hTxtRelStartTime)
  ProcedureReturn #True
  
EndProcedure

Procedure SUB_txtSubDescr_Change(hTxtSubDescr, hLblSubDescr)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sOldSubDescr.s
  
  ; Note: #PB_EventType_Change is only raised if the USER changes the gadget, eg types into a string, NOT if the gadget is 'changed' by program
  ; So if we get here then the user must have entered or changed something in the 'Description' field
  
  ; see SUB_setSubDescr() for the handling of sub-cue descriptions changed by program
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; aSub(nEditSubPtr)\bDefaultSubDescrMayBeSet = #False ; Deleted 7Dec2020 11.8.3.3as
  
  With aSub(nEditSubPtr)
    If GGT(hTxtSubDescr) <> \sSubDescr
      sOldSubDescr = \sSubDescr
      u = preChangeSubS(\sSubDescr, GGT(hLblSubDescr), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT)
      \sSubDescr = GGT(hTxtSubDescr)
      ; Added 7Dec2020 11.8.3.3as
      If \sSubDescr = buildDefaultSubDescr(nEditSubPtr)
        \bDefaultSubDescrMayBeSet = #True
      Else
        \bDefaultSubDescrMayBeSet = #False
      EndIf
      ; End added 7Dec2020 11.8.3.3as
      ; debugMsg(sProcName, "calling setSubDescrToolTip()")
      setSubDescrToolTip(hTxtSubDescr)
      ; debugMsg(sProcName, "calling WED_setSubNodeText()")
      WED_setSubNodeText(nEditSubPtr)
      ; debugMsg(sProcName, "calling promoteSubDescrIfReqd()")
      promoteSubDescrIfReqd(sOldSubDescr, GGT(hLblSubDescr))
      ; debugMsg(sProcName, "calling loadGridRow()")
      loadGridRow(nEditCuePtr)
      ; debugMsg(sProcName, "calling PNL_refreshDispPanel()")
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, -1, #True)
      ; debugMsg(sProcName, "calling postChangeSubS()")
      postChangeSubS(u, \sSubDescr)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SUB_setSubDescr(sSubDescr.s, hTxtSubDescr, bClearDefaultSubDescrMayBeSet=#True)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sOldSubDescr.s
  
  debugMsg(sProcName, #SCS_START + ", sSubDescr=" + sSubDescr)
  
  ; Deleted 7Dec2020 11.8.3.3as
;   If bClearDefaultSubDescrMayBeSet
;     aSub(nEditSubPtr)\bDefaultSubDescrMayBeSet = #False
;   EndIf
  ; End Deleted 7Dec2020 11.8.3.3as
  
  With aSub(nEditSubPtr)
    If sSubDescr <> \sSubDescr
      sOldSubDescr = \sSubDescr
      u = preChangeSubS(\sSubDescr, grText\sTextDescription, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT)
      \sSubDescr = sSubDescr
      ; Added 7Dec2020 11.8.3.3as
      If \sSubDescr = buildDefaultSubDescr(nEditSubPtr)
        \bDefaultSubDescrMayBeSet = #True
      Else
        \bDefaultSubDescrMayBeSet = #False
      EndIf
      If nEditSubPtr = aCue(nEditCuePtr)\nFirstSubIndex
        setDefaultCueDescrMayBeSet(nEditCuePtr, #True)
      EndIf
      ; End added 7Dec2020 11.8.3.3as
      debugMsg(sProcName, "calling setSubDescrToolTip()")
      setSubDescrToolTip(hTxtSubDescr)
      debugMsg(sProcName, "calling WED_setSubNodeText()")
      WED_setSubNodeText(nEditSubPtr)
      debugMsg(sProcName, "calling promoteSubDescrIfReqd()")
      promoteSubDescrIfReqd(sOldSubDescr, grText\sTextDescription)
      debugMsg(sProcName, "calling loadGridRow()")
      loadGridRow(nEditCuePtr)
      debugMsg(sProcName, "calling PNL_refreshDispPanel()")
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, -1, #True)
      debugMsg(sProcName, "calling postChangeSubS()")
      postChangeSubS(u, \sSubDescr)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SUB_txtSubDescr_Validate(hTxtSubDescr)
  PROCNAMECS(nEditSubPtr)
  
  ; debugMsg(sProcName, #SCS_START)
  
  markValidationOK(hTxtSubDescr)
  setSubDescrToolTip(hTxtSubDescr)
  
  ProcedureReturn #True
EndProcedure

Procedure SUB_chkSubEnabled_Click(hChkSubEnabled, hLblSubDisabled, hTxtSubDescr)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected bMySubEnabled
  Protected sMsgStart.s
  
  debugMsg(sProcName, #SCS_START)
  
  bMySubEnabled = getOwnState(hChkSubEnabled)
  If bMySubEnabled = #False
    sMsgStart = LangPars("Errors", "CannotDisableSub3", getSubLabel(nEditSubPtr))
    If checkDelSubRI(nEditSubPtr, sMsgStart, 1) = #False
      setOwnState(hChkSubEnabled, aSub(nEditSubPtr)\bSubEnabled)
      ProcedureReturn
    EndIf
  Else
    sMsgStart = LangPars("Errors", "CannotEnableSub3", getSubLabel(nEditSubPtr))
    If checkDelSubRI(nEditSubPtr, sMsgStart, 2) = #False
      setOwnState(hChkSubEnabled, aSub(nEditSubPtr)\bSubEnabled)
      ProcedureReturn
    EndIf
  EndIf

  With aSub(nEditSubPtr)
    u = preChangeSubL(\bSubEnabled, getOwnText(hChkSubEnabled))
    \bSubEnabled = getOwnState(hChkSubEnabled)
    SUB_fcSubEnabled(hLblSubDisabled, hTxtSubDescr)
    redoCueListTree(\nNodeKey)
    setCuePtrs(#False)
    loadHotkeyArray()
    loadCueMarkerArrays()
    ; debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)")
    samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    debugMsg(sProcName, "calling setCueToGo()")
    setCueToGo()
    postChangeSubL(u, \bSubEnabled)
    WMN_updateToolBar()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SUB_fcSubEnabled(hLblSubDisabled, hTxtSubDescr)
  PROCNAMECS(nEditSubPtr)
  
  If aSub(nEditSubPtr)\bSubEnabled
    setVisible(hLblSubDisabled, #False)
    scsSetGadgetFont(hTxtSubDescr, #SCS_FONT_GEN_NORMAL)
  Else
    setVisible(hLblSubDisabled, #True)
    scsSetGadgetFont(hTxtSubDescr, #SCS_FONT_GEN_NORMALSTRIKETHRU)
  EndIf
  setCueSubsAllDisabledFlag(nEditCuePtr)
  setLinksForCue(nEditCuePtr) ; Added 13Aug2022 11.9.4

EndProcedure

Macro SUB_setGadgetNos(pRecord)
  cntSubHeader = pRecord\cntSubHeader
  txtSubDescr = pRecord\txtSubDescr
  cboSubStart = pRecord\cboSubStart
  cntSubRelMTCStartTime = pRecord\cntSubRelMTCStartTime
  cboSubCueMarker = pRecord\cboSubCueMarker
  txtSubRelMTCStartPart(0) = pRecord\txtSubRelMTCStartPart(0)
  txtSubRelMTCStartPart(1) = pRecord\txtSubRelMTCStartPart(1)
  txtSubRelMTCStartPart(2) = pRecord\txtSubRelMTCStartPart(2)
  txtSubRelMTCStartPart(3) = pRecord\txtSubRelMTCStartPart(3)
  txtRelStartTime = pRecord\txtRelStartTime
  cboRelStartMode = pRecord\cboRelStartMode
EndMacro

Macro SUB_setGadgetNosForSubType(pSubType)
  Select pSubType
    Case "A"
      SUB_setGadgetNos(WQA)
    Case "E"
      SUB_setGadgetNos(WQE)
    Case "F"
      SUB_setGadgetNos(WQF)
    Case "G"
      SUB_setGadgetNos(WQG)
    Case "I"
      SUB_setGadgetNos(WQI)
    Case "J"
      SUB_setGadgetNos(WQJ)
    Case "K"
      SUB_setGadgetNos(WQK)
    Case "L"
      SUB_setGadgetNos(WQL)
    Case "M"
      SUB_setGadgetNos(WQM)
    Case "P"
      SUB_setGadgetNos(WQP)
    Case "Q"
      SUB_setGadgetNos(WQQ)
    Case "R"
      SUB_setGadgetNos(WQR)
    Case "S"
      SUB_setGadgetNos(WQS)
    Case "T"
      SUB_setGadgetNos(WQT)
    Case "U"
      SUB_setGadgetNos(WQU)
  EndSelect
EndMacro

Procedure SUB_loadOrResizeHeaderFields(pSubType.s, pLoadComboBoxes)
  PROCNAMEC()
  Protected cntSubHeader, txtSubDescr, cboSubStart, lblRelStart, txtRelStartTime, cboRelStartMode, cntSubRelMTCStartTime, cboSubCueMarker
  Protected Dim txtSubRelMTCStartPart.i(3)
  Protected nCntWidth, nLeft, nWidth
  
  ; debugMsg0(sProcName, "pSubType=" + pSubType + ", pLoadComboBoxes=" + strB(pLoadComboBoxes))
  
  SUB_setGadgetNosForSubType(pSubType)
  
  If pLoadComboBoxes
    SUB_populateCboSubStart(cboSubStart)
    SUB_populateCboRelStartMode(cboRelStartMode)
  EndIf
  
  nCntWidth = GadgetWidth(cntSubHeader)
  nLeft = nCntWidth - GadgetWidth(cboRelStartMode) - glBorderAllowanceX
  ; debugMsg0(sProcName, "GadgetWidth(cntSubHeader)=" + GadgetWidth(cntSubHeader) + ", GadgetWidth(cboRelStartMode)=" + GadgetWidth(cboRelStartMode) + ", nLeft=" + nLeft)
  If GadgetX(cboRelStartMode) <> nLeft
    ResizeGadget(cboRelStartMode, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
  nLeft - GadgetWidth(txtRelStartTime)
  ; debugMsg0(sProcName, "GadgetX(txtRelStartTime)=" + GadgetX(txtRelStartTime) + ", nLeft=" + nLeft)
  If GadgetX(txtRelStartTime) <> nLeft
    ResizeGadget(txtRelStartTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
  ; debugMsg0(sProcName, "GadgetX(txtRelStartTime)=" + GadgetX(txtRelStartTime))
  If GadgetX(cntSubRelMTCStartTime) <> nLeft
    ResizeGadget(cntSubRelMTCStartTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
  If GadgetX(cboSubCueMarker) <> nLeft
    ResizeGadget(cboSubCueMarker, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
  nLeft - GadgetWidth(cboSubStart)
  If GadgetX(cboSubStart) <> nLeft
    ResizeGadget(cboSubStart, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
  nWidth = nLeft - GadgetX(txtSubDescr) - gnGap
  If nWidth > 0
    ; should be #True
    ResizeGadget(txtSubDescr, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
  EndIf
  
EndProcedure

Procedure SUB_setRelMTCStartTimeForSubToolTip(pSubType.s)
  PROCNAMECS(nEditSubPtr)
  Protected cntSubHeader, txtSubDescr, cboSubStart, lblRelStart, txtRelStartTime, cboRelStartMode, cntSubRelMTCStartTime, cboSubCueMarker, Dim txtSubRelMTCStartPart(3)
  Protected sToolTip.s, n
  
  SUB_setGadgetNosForSubType(pSubType)
  
  With aSub(nEditSubPtr)
    If \nCalcMTCStartTimeForSub = grSubDef\nCalcMTCStartTimeForSub
      sToolTip = Lang("CED","txtSubRelMTCStartTimeTT")
    Else
      sToolTip = LangPars("CED", "CalcSubMTCStartTime", decodeMTCTime(\nCalcMTCStartTimeForSub))
    EndIf
    For n = 0 To 3
      scsToolTip(txtSubRelMTCStartPart(n), sToolTip)
    Next n
  EndWith
  
EndProcedure

Procedure SUB_fcSubStart(pSubType.s)
  PROCNAMECS(nEditSubPtr)
  Protected cntSubHeader, txtSubDescr, cboSubStart, lblRelStart, txtRelStartTime, cboRelStartMode, cntSubRelMTCStartTime, cboSubCueMarker, Dim txtSubRelMTCStartPart(3)
  Protected bRelStartVisible, bRelMTCVisible, bOCMVisible, sRelMTCStartTimeForSub.s, n
  
  SUB_setGadgetNosForSubType(pSubType)
  
  With aSub(nEditSubPtr)
    Select \nSubStart
      Case #SCS_SUBSTART_REL_TIME
        bRelStartVisible = #True
      Case #SCS_SUBSTART_REL_MTC
        bRelMTCVisible = #True
        sRelMTCStartTimeForSub = decodeMTCTime(\nRelMTCStartTimeForSub)
        ; debugMsg0(sProcName, "sRelMTCStartTimeForSub=" + sRelMTCStartTimeForSub)
        For n = 0 To 3
          SGT(txtSubRelMTCStartPart(n), StringField(sRelMTCStartTimeForSub, n+1, ":"))
        Next n
        SUB_setRelMTCStartTimeForSubToolTip(pSubType)
      Case #SCS_SUBSTART_OCM
        bOCMVisible = #True
        SUB_populateCboSubCueMarker(nEditSubPtr)
    EndSelect
    setVisible(txtRelStartTime, bRelStartVisible)
    setVisible(cboRelStartMode, bRelStartVisible)
    setVisible(cntSubRelMTCStartTime, bRelMTCVisible)
    setVisible(cboSubCueMarker, bOCMVisible)
  EndWith
  
EndProcedure

Procedure SUB_populateCboSubCueMarker(pSubPtr)
  ; populates the 'on cue marker' combobox for a sub-cue
  PROCNAMECS(pSubPtr)
  Protected cntSubHeader, txtSubDescr, cboSubStart, lblRelStart, txtRelStartTime, cboRelStartMode, cntSubRelMTCStartTime, cboSubCueMarker, Dim txtSubRelMTCStartPart(3)
  Protected sReqdCueMarkerDetails.s, n
  Protected nCuePtr, sGadgetName.s
  Protected sFileTitle.s, nMaxComboBoxWidth
  
  SUB_setGadgetNosForSubType(aSub(pSubPtr)\sSubType)
  
  nCuePtr = aSub(pSubPtr)\nCueIndex
  sGadgetName = getGadgetName(cboSubCueMarker)
  ClearGadgetItems(cboSubCueMarker)
  For n = 0 To gnMaxCueMarkerInfo
    With gaCueMarkerInfo(n)
      If \bOCMAvailable
        If \nHostCuePtr = nCuePtr
          If \nHostAudPtr >= 0
            sFileTitle = aAud(\nHostAudPtr)\sFileTitle
          Else
            sFileTitle = ""
          EndIf
          addGadgetItemWithData(cboSubCueMarker, Trim(\sCueMarkerDisplayInfoShort + " " + sFileTitle), \nCueMarkerId)
          debugMsg(sProcName, "addGadgetItemWithData(" + sGadgetName + ", " + \sCueMarkerDisplayInfoShort + ", " + \nCueMarkerId + ")")
          If aSub(pSubPtr)\nSubCueMarkerId = \nCueMarkerId
            sReqdCueMarkerDetails = Trim(\sCueMarkerDisplayInfoShort + " " + sFileTitle)
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  debugMsg(sProcName, "sReqdCueMarkerDetails=" + sReqdCueMarkerDetails)
  
  If sReqdCueMarkerDetails
    SGT(cboSubCueMarker, sReqdCueMarkerDetails)
  Else
    SGS(cboSubCueMarker, -1)
  EndIf
  debugMsg(sProcName, "GGS(" + sGadgetName + ")=" + GGS(cboSubCueMarker))
  nMaxComboBoxWidth = GadgetWidth(cntSubHeader) - GadgetX(cboSubCueMarker) - glBorderAllowanceX
  setComboBoxWidth(cboSubCueMarker, 120, #False, nMaxComboBoxWidth)
  
EndProcedure

Procedure SUB_cboSubCueMarker_Click(nGadgetNo)
  PROCNAMECS(nEditSubPtr)
  Protected cntSubHeader, txtSubDescr, cboSubStart, lblRelStart, txtRelStartTime, cboRelStartMode, cntSubRelMTCStartTime, cboSubCueMarker, Dim txtSubRelMTCStartPart(3)
  Protected nCueMarkerId, n, nHostAudPtr
  Protected u

  debugMsg(sProcName, #SCS_START)
  
  SUB_setGadgetNosForSubType(aSub(nEditSubPtr)\sSubType)
  
  With aSub(nEditSubPtr)
    nCueMarkerId = getCurrentItemData(nGadgetNo)
    If nCueMarkerId <> \nSubCueMarkerId
      nHostAudPtr = -1
      u = preChangeCueL(\nSubCueMarkerId, "Sub Cue Marker")
      \nSubCueMarkerId = nCueMarkerId
      For n = 0 To gnMaxCueMarkerInfo
        If gaCueMarkerInfo(n)\nCueMarkerId = nCueMarkerId
          \sSubCueMarkerName = gaCueMarkerInfo(n)\sCueMarkerName
          nHostAudPtr = gaCueMarkerInfo(n)\nHostAudPtr
          \nSubCueMarkerAudNo = aAud(nHostAudPtr)\nAudNo
          debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\sSubCueMarkerName=" + \sSubCueMarkerName + ", \nSubCueMarkerAudNo=" + \nSubCueMarkerAudNo)
          Break
        EndIf
      Next n
      debugMsg(sProcName, "calling loadCueMarkerArrays()")
      loadCueMarkerArrays()
      setDelayHideInds()
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, -1, #True)
      postChangeCueL(u, \nSubCueMarkerId)
      If nHostAudPtr >= 0
        debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nHostAudPtr) + ")")
        setBassMarkerPositions(nHostAudPtr)
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure SUB_txtRelMTCStartPart_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected cntSubHeader, txtSubDescr, cboSubStart, lblRelStart, txtRelStartTime, cboRelStartMode, cntSubRelMTCStartTime, cboSubCueMarker, Dim txtSubRelMTCStartPart.i(3)
  Protected u
  Protected sMTCStartTime.s
  Protected nMTCStartTime
  Protected n, bAllBlank
  Protected sFieldPrompt.s, sToolTip.s
  
  debugMsg(sProcName, #SCS_START)
  
  SUB_setGadgetNosForSubType(aSub(nEditSubPtr)\sSubType)
  
  With aSub(nEditSubPtr)
    sMTCStartTime = Trim(GGT(txtSubRelMTCStartPart(0))) + ":"
    sMTCStartTime + Trim(GGT(txtSubRelMTCStartPart(1))) + ":"
    sMTCStartTime + Trim(GGT(txtSubRelMTCStartPart(2))) + ":"
    sMTCStartTime + Trim(GGT(txtSubRelMTCStartPart(3)))
    debugMsg(sProcName, "sMTCStartTime=" + sMTCStartTime)
    sFieldPrompt = GGT(cboSubStart)
    If validateMTCField(sMTCStartTime, sFieldPrompt) = #False
      ProcedureReturn #False
    ElseIf sMTCStartTime <> gsTmpString
      For n = 0 To 3
        If GGT(txtSubRelMTCStartPart(n)) <> StringField(gsTmpString,n+1,":")
          SGT(txtSubRelMTCStartPart(n), StringField(gsTmpString,n+1,":"))
        EndIf
      Next n
    EndIf
    u = preChangeSubL(\nRelMTCStartTimeForSub, sFieldPrompt)
    \nRelMTCStartTimeForSub = encodeMTCTime(sMTCStartTime)
    \nCalcMTCStartTimeForSub = calcMTCStartTimeForSub(nEditSubPtr)
    SUB_setRelMTCStartTimeForSubToolTip(\sSubType)
    setDefaultSubDescr()
    postChangeSubL(u, \nRelMTCStartTimeForSub)
  EndWith
  loadArrayCueOrSubForMTC()
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  ProcedureReturn #True
EndProcedure

; EOF
