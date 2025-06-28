; File: fmLabelChange.pbi

EnableExplicit

Procedure WLC_isLabelChanged(sCue.s)
  Protected i, bChanged
  
  For i = 1 To gnLastCue
    If gaCueLabelInfo(i)\sOldCue = sCue
      If gaCueLabelInfo(i)\sNewCue <> gaCueLabelInfo(i)\sOldCue
        bChanged = #True
      EndIf
      Break
    EndIf
  Next i
  ProcedureReturn bChanged
EndProcedure

Procedure WLC_selectRowsForCueSelection()
  PROCNAMEC()
  Protected nFirstSelectedRow, nLastSelectedRow
  Protected n
  
  With WLC
    nFirstSelectedRow = GGS(\cboStartCue)
    nLastSelectedRow = GGS(\cboEndCue)
    SGS(\grdPreview, -1)  ; clear existing selection
    For n = nFirstSelectedRow To nLastSelectedRow
      SetGadgetItemState(\grdPreview, n, #PB_ListIcon_Selected)
    Next n
  EndWith
  
EndProcedure

Procedure WLC_btnReset_Click()
  PROCNAMEC()
  Protected i

  For i = 1 To gnLastCue
    gaCueLabelInfo(i)\sNewCue = gaCueLabelInfo(i)\sOldCue
    SetGadgetItemText(WLC\grdPreview, i-1, gaCueLabelInfo(i)\sNewCue, 1)
    SetGadgetItemText(WLC\grdPreview, i-1, aCue(i)\sCueDescr, 4)
  Next i

EndProcedure

Procedure WLC_btnSelectAll_Click()
  PROCNAMEC()
  
  SGS(WLC\cboStartCue, 0)
  SGS(WLC\cboEndCue, gnLastCue-1)
  WLC_selectRowsForCueSelection()
  
EndProcedure

Procedure.s WLC_getCueType(pCuePtr)
  Protected sCueType.s
  Protected j
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    If j >= 0
      sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
      If aSub(j)\nNextSubIndex >= 0
        sCueType + " +"
      EndIf
    EndIf
  EndIf
  ProcedureReturn sCueType
EndProcedure

Procedure WLC_Form_Load()
  PROCNAMEC()
  Protected i
  Protected sText.s
  
  If IsWindow(#WLC) = #False
    createfmLabelChange()
  EndIf
  setFormPosition(#WLC, @grLabelChangeWindow)
  
  If gnLastCue > 0
    ReDim gaCueLabelInfo(gnLastCue)
  EndIf
  If gnLastSub > 0
    ReDim gaSubCueLabelInfo(gnLastSub)
  EndIf
  
  For i = 1 To gnLastCue
    With gaCueLabelInfo(i)
      \sOldCue = aCue(i)\sCue
      \sNewCue = aCue(i)\sCue
      \sCueType = WLC_getCueType(i)
      \sCueDescr = aCue(i)\sCueDescr
      \sPageNo = aCue(i)\sPageNo
      \sOldMidiCue = aCue(i)\sMidiCue
      If aCue(i)\sMidiCue = getMidiCueFromSCSCue(aCue(i)\sCue, "GLOBAL")
        \bOldMidiIsDefault = #True
      Else
        \bOldMidiIsDefault = #False
      EndIf
    EndWith
  Next i

  ClearGadgetItems(WLC\grdPreview)

  For i = 1 To gnLastCue
    With gaCueLabelInfo(i)
      sText = \sOldCue + Chr(10) + \sNewCue + Chr(10) + \sPageNo + Chr(10) + \sCueType + Chr(10) + \sCueDescr
      AddGadgetItem(WLC\grdPreview,-1,sText)
    EndWith
  Next i
  autoFitGridCol(WLC\grdPreview, 4) ; autofit "Description" column
  
  ClearGadgetItems(WLC\cboStartCue)
  ClearGadgetItems(WLC\cboEndCue)
  For i = 1 To gnLastCue
    AddGadgetItem(WLC\cboStartCue, -1, buildCueForCBO(i))
    AddGadgetItem(WLC\cboEndCue, -1, buildCueForCBO(i))
  Next i
  SGS(WLC\cboStartCue, 0)
  SGS(WLC\cboEndCue, gnLastCue-1)
  ; nb don't initially select the whole list
  WLC_selectRowsForCueSelection()
  
  SGT(WLC\txtCueLabel, grWLC\sNewFirstCueLabel)
  SGT(WLC\txtRenumberIncrement, grWLC\sRenumberIncrement)
  
  ; force 'new cue number...' to upper case if required
  setUpperCase(WLC\txtCueLabel, grProd\bLabelsUCase)
  SAG(WLC\txtCueLabel)
  
  setWindowVisible(#WLC, #True)
  
EndProcedure

Procedure WLC_applyLabelChanges()
  PROCNAMEC()
  Protected i, j, nMaxLength, sTmpPrefix.s
  Protected nHoldEditCuePtr
  Protected sOldCue.s, sTmpCue.s, sNewCue.s, sUndoDescr.s
  Protected u, u2
  Protected bChangeReqd, bWantThis, n
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If gaCueLabelInfo(i)\sNewCue <> gaCueLabelInfo(i)\sOldCue
      bChangeReqd = #True
      Break
    EndIf
  Next i
  If bChangeReqd = #False
    ProcedureReturn
  EndIf
  
  gbInApplyLabelChanges = #True
  setMouseCursorBusy()

  sUndoDescr = GetWindowTitle(#WLC)  ; "Renumber Cues"
  u = preChangeProdL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_RENUMBER_CUES, -1, #SCS_UNDO_FLAG_REDO_TREE, grProd\nProdId)
  
  For i = 1 To gnLastCue
    
    gaCueLabelInfo(i)\bChanged = WLC_isLabelChanged(aCue(i)\sCue)
    If gaCueLabelInfo(i)\bChanged
      gaCueLabelInfo(i)\u2 = preChangeCueS(aCue(i)\sCue, "Cue", i)
      ; debugMsg(sProcName, "preChangeCue(" + aCue(i)\sCue + ", " + #DQUOTE$ + "Cue" + #DQUOTE$ + ", " + i + ") returned " + Str(gaCueLabelInfo(i)\u2))
      aCue(i)\bCallLoadGridRow = #True
    EndIf
    
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      bWantThis = #False
      With aSub(j)
        If \bSubTypeQ       ; bSubTypeQ
          bWantThis = WLC_isLabelChanged(\sCallCue)
        EndIf
        
        If \bSubTypeG       ; bSubTypeG
          bWantThis = WLC_isLabelChanged(\sCueToGoTo)
          
        ElseIf \bSubTypeJ   ; bSubTypeJ
          For n = 0 To #SCS_MAX_ENABLE_DISABLE
            If Trim(\aEnableDisable[n]\sFirstCue)
              bWantThis = WLC_isLabelChanged(\aEnableDisable[n]\sFirstCue)
              If bWantThis
                Break
              EndIf
            EndIf
            If Trim(\aEnableDisable[n]\sLastCue)
              bWantThis = WLC_isLabelChanged(\aEnableDisable[n]\sLastCue)
              If bWantThis
                Break
              EndIf
            EndIf
          Next n
          
        ElseIf \bSubTypeL   ; bSubTypeL
          bWantThis = WLC_isLabelChanged(\sLCCue)
          
        ElseIf \bSubTypeS   ; bSubTypeS
          For n = 0 To #SCS_MAX_SFR
            If \nSFRCueType[n] = #SCS_SFR_CUE_SEL
              If Trim(\sSFRCue[n])
                bWantThis = WLC_isLabelChanged(\sSFRCue[n])
                If bWantThis
                  Break
                EndIf
              EndIf
            EndIf
          Next n
          
        ElseIf \bSubTypeT   ; bSubTypeT
          bWantThis = WLC_isLabelChanged(\sSetPosCue)
          
        EndIf
      EndWith
      
      ; debugMsg(sProcName, "bWantThis=" + strB(bWantThis))
      gaSubCueLabelInfo(j)\bChanged = bWantThis
      If bWantThis
        gaSubCueLabelInfo(j)\u3 = preChangeSubL(#True, "Cue", j)
        ; debugMsg(sProcName, "preChangeSub(True, " + #DQUOTE$ + "Cue" + #DQUOTE$ + ", " + j + ") returned " + Str(gaSubCueLabelInfo(j)\u3))
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    
  Next i
  
  nMaxLength = 1
  For i = 1 To gnLastCue
    With gaCueLabelInfo(i)
      If Len(\sOldCue) > nMaxLength
        nMaxLength = Len(\sOldCue)
      EndIf
      If Len(\sNewCue) > nMaxLength
        nMaxLength = Len(\sNewCue)
      EndIf
    EndWith
  Next i

  sTmpPrefix = LSet("Z", nMaxLength, "Z")

  For i = 1 To gnLastCue
    gaCueLabelInfo(i)\sTmpCue = sTmpPrefix + i
  Next i

  nHoldEditCuePtr = nEditCuePtr

  ; for cues to be changed, first change label to tmp label
  For i = 1 To gnLastCue
    If gaCueLabelInfo(i)\sNewCue <> gaCueLabelInfo(i)\sOldCue
      sOldCue = gaCueLabelInfo(i)\sOldCue
      sTmpCue = gaCueLabelInfo(i)\sTmpCue
      nEditCuePtr = i
      ; debugMsg(sProcName, "calling changeCueLabel(" + sOldCue + ", " + sTmpCue + ", #True)")
      changeCueLabel(sOldCue, sTmpCue, #True)
    EndIf
  Next i

  ; for cues to be changed, now change tmp label to new label
  For i = 1 To gnLastCue
    If gaCueLabelInfo(i)\sNewCue <> gaCueLabelInfo(i)\sOldCue
      sOldCue = gaCueLabelInfo(i)\sOldCue
      sTmpCue = gaCueLabelInfo(i)\sTmpCue
      sNewCue = gaCueLabelInfo(i)\sNewCue
      nEditCuePtr = i
      With aCue(nEditCuePtr)
        If \sCue <> sNewCue
          \sCue = sNewCue
          ; debugMsg(sProcName, "calling changeCueLabel(" + sTmpCue + ", " + sNewCue + ", #True, " + sOldCue + ", " + #DQUOTE$ + sUndoDescr + ")")
          changeCueLabel(sTmpCue, sNewCue, #True, sOldCue, sUndoDescr)
          If \sCue <> \sValidatedCue
            \sValidatedCue = \sCue
            WED_setCueNodeText(nEditCuePtr)
            ; Added 12Jul2021 11.8.5at because sub-cues that reference an earlier sub-cue in this same cue (eg Level Change) left the description with leading Z's in the cue label
            ; Reported by David Gilbrook 4Jul2021
            j = \nFirstSubIndex
            While j >= 0
              ; debugMsg0(sProcName, "1: aSub(" + getSubLabel(j) + ")\sSubDescr=" + aSub(j)\sSubDescr)
              setDefaultSubDescr(j)
              ; debugMsg0(sProcName, "2: aSub(" + getSubLabel(j) + ")\sSubDescr=" + aSub(j)\sSubDescr)
              j = aSub(j)\nNextSubIndex
            Wend
            ; End added 12Jul2021 11.8.5at
          EndIf
        EndIf
      EndWith
    EndIf
  Next i
  
  For i = 1 To gnLastCue
    If gaCueLabelInfo(i)\bChanged
      ; debugMsg(sProcName, "calling postChangeCue(" + gaCueLabelInfo(i)\u2 + ", " + aCue(i)\sCue + ", " + i + ")")
      postChangeCueS(gaCueLabelInfo(i)\u2, aCue(i)\sCue, i)
    EndIf
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If gaSubCueLabelInfo(j)\bChanged
        ; debugMsg(sProcName, "calling postChangeSub(" + gaSubCueLabelInfo(j)\u3 + ", #False, " + j + ")")
        postChangeSubL(gaSubCueLabelInfo(j)\u3, #False, j)
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  postChangeProdL(u, #False)
  
  nEditCuePtr = nHoldEditCuePtr

  If nEditCuePtr >= 0
    gnClickThisNode = aCue(nEditCuePtr)\nNodeKey
  Else
    gnClickThisNode = grProd\nNodeKey
  EndIf
  
  debugMsg(sProcName, "calling loadCueMarkerArrays()")
  loadCueMarkerArrays()
  
  gbCallLoadDispPanels = #True
  gbCallLoadGridRowsWhereRequested = #True
  gbForceNodeDisplay = #True
  
  WED_tvwProdTree_NodeClick(#True)
  
  setLastPlayingCue(grWMN\nLastPlayingCuePtr)
  setGoButton()
  
  setMouseCursorNormal()
  gbInApplyLabelChanges = #False
  
  debugMsg(sProcName, #SCS_End)
  
EndProcedure

Procedure WLC_tryChange()
  PROCNAMEC()
  Protected i, i2, j
  Protected bOK
  Protected nStartPtr, nEndPtr, sCueLabel.s, sDescr.s
  Protected bFound, iRow, nCounter
  Protected nIncrement
  Protected sHoldCueLabel.s
  Protected sMayBeChanged.s
  Protected sTargetCue.s, nTargetCuePtr, bTooComplex
  
  ; debugMsg(sProcName, #SCS_START)
  
  bOK = #True
  nStartPtr = GGS(WLC\cboStartCue) + 1
  nEndPtr = GGS(WLC\cboEndCue) + 1

  If nEndPtr < nStartPtr
    scsMessageRequester(GWT(#WLC), Lang("WLC", "EndBeforeStart"), #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf

  sCueLabel = GGT(WLC\txtCueLabel)
  If Len(sCueLabel) = 0
    scsMessageRequester(GWT(#WLC), LangPars("Errors", "MustBeEntered", GGT(WLC\lblCueLabel)), #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf

  ; check the starting cue label not already in use in cues not included in this change
  For i = 1 To gnLastCue
    If i < nStartPtr Or i > nEndPtr
      If UCase(sCueLabel) = UCase(gaCueLabelInfo(i)\sNewCue)
        scsMessageRequester(GWT(#WLC), LangPars("WLC", "AlreadyInUse", sCueLabel), #PB_MessageRequester_Error)
        ProcedureReturn
      EndIf
    EndIf
  Next i
  
  nIncrement = 1
  If Trim(GGT(WLC\txtRenumberIncrement))
    If IsInteger(GGT(WLC\txtRenumberIncrement))
      nIncrement = Val(Trim(GGT(WLC\txtRenumberIncrement)))
      If nIncrement < 1
        nIncrement = 1
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "nStartPtr=" + nStartPtr + ", nEndPtr=" + nEndPtr)
  For i = nStartPtr To nEndPtr
    ; debugMsg(sProcName, "i=" + i)
    bFound = #False
    
    If i > nStartPtr
      sHoldCueLabel = sCueLabel
      sCueLabel = generateNextCueLabel(sHoldCueLabel, nIncrement, 0.0, "", #True)
      ; debugMsg(sProcName, "generateNextCueLabel(" + sHoldCueLabel + ", " + nIncrement + ", 0.0, " + #DQUOTE$ + #DQUOTE$ + ", #True) returned " + sCueLabel)
      ; check if cue label is already in use
      For i2 = 1 To gnLastCue
        If (i2 < nStartPtr) Or (i2 > nEndPtr)
          If UCase(gaCueLabelInfo(i2)\sNewCue) = UCase(sCueLabel)
            bFound = #True
            Break
          EndIf
        EndIf
      Next i2
    EndIf
    
    If bFound
      ; generated label already in use so create a unique label
      nCounter = 0
      bFound = #True
      While bFound And nCounter < 10000 ; prevent endless loop
        nCounter + 1
        sHoldCueLabel = sCueLabel
        sCueLabel = generateNextCueLabel(sHoldCueLabel, nIncrement, 0.0, "", #True)
        ; debugMsg(sProcName, "generateNextCueLabel(" + sHoldCueLabel + ", " + nIncrement + ", 0.0, " + #DQUOTE$ + #DQUOTE$ + ", #True) returned " + sCueLabel)
        bFound = #False
        For i2 = 1 To gnLastCue
          If UCase(gaCueLabelInfo(i2)\sNewCue) = UCase(sCueLabel)
            bFound = #True
            Break
          EndIf
        Next i2
      Wend
      If bFound
        ; couldn't generate a new cue label
        bOK = #False
      EndIf
    EndIf
    
    ; debugMsg(sProcName, "bOK=" + strB(bOK))
    If bOK
      gaCueLabelInfo(i)\sNewCue = sCueLabel
      ; debugMsg(sProcName, "gaCueLabelInfo(" + i + ")\sNewCue=" + gaCueLabelInfo(i)\sNewCue)
    EndIf
    
  Next i
  
  sMayBeChanged = "(" + Lang("WLC", "MayBeChanged") + ")"
  For i = 1 To gnLastCue
    SetGadgetItemText(WLC\grdPreview, i-1, gaCueLabelInfo(i)\sNewCue, 1)
    If aCue(i)\bDefaultCueDescrMayBeSet
      j = aCue(i)\nFirstSubIndex
      If j >= 0
        With aSub(j)
          ; nb see setDefaultSubDescr() for more info on determining the target cue, etc
          sTargetCue = "" ; blank means 'no change'
          bTooComplex = #False
          If \bSubTypeG ; go to cue
            sTargetCue = \sCueToGoTo
            nTargetCuePtr = getCuePtr(sTargetCue)
            If nTargetCuePtr >= 0
              If gaCueLabelInfo(nTargetCuePtr)\sNewCue <> gaCueLabelInfo(nTargetCuePtr)\sOldCue
                bTooComplex = #True ; too complex for this procedure (nb target cue description may contain another cue number)
                sTargetCue = ""
              EndIf
            EndIf
          ElseIf \bSubTypeJ ; enable/disable cue
            bTooComplex = #True ; too complex for this procedure
          ElseIf \bSubTypeL     ; level change
            sTargetCue = \sLCCue
          ElseIf \bSubTypeQ ; call cue
            sTargetCue = \sCallCue
          ElseIf \bSubTypeS ; SFR cue
            If \nSFRCueType = #SCS_SFR_CUE_SEL
              sTargetCue = getSubLabel(\nSFRSubPtr[0])
            EndIf
          ElseIf \bSubTypeT ; set position of cue
            sTargetCue = \sSetPosCue
          EndIf
          If bTooComplex
            SetGadgetItemText(WLC\grdPreview, i-1, sMayBeChanged, 3)
          ElseIf sTargetCue
            nTargetCuePtr = getCuePtr(sTargetCue)
            If nTargetCuePtr >= 0
              sDescr = ReplaceString(aCue(i)\sCueDescr, gaCueLabelInfo(nTargetCuePtr)\sOldCue, gaCueLabelInfo(nTargetCuePtr)\sNewCue, #PB_String_CaseSensitive, 1, 1)
              SetGadgetItemText(WLC\grdPreview, i-1, sDescr, 3)
            EndIf
          EndIf
        EndIf
      EndWith
    EndIf
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLC_Form_Show(bModal=#False)
  PROCNAMEC()
  
  WLC_Form_Load()
  setWindowModal(#WLC, bModal)
  setWindowVisible(#WLC, #True)
  SAW(#WLC)
  SAG(WLC\txtCueLabel)
EndProcedure

Procedure WLC_Form_Unload()
  
  grWLC\sNewFirstCueLabel = Trim(GGT(WLC\txtCueLabel))
  grWLC\sRenumberIncrement = Trim(GGT(WLC\txtRenumberIncrement))
  
  getFormPosition(#WLC, @grLabelChangeWindow)
  unsetWindowModal(#WLC)
  scsCloseWindow(#WLC)
EndProcedure

Procedure WLC_txtRenumberIncrement_Validate()
  PROCNAMEC()
  Protected nMyRenumberIncrement
  
  If Len(Trim(GGT(WLC\txtRenumberIncrement))) = 0
    nMyRenumberIncrement = 1
  Else
    If IsInteger(GGT(WLC\txtRenumberIncrement)) = #False
      nMyRenumberIncrement = -99999    ; force error
    Else
      nMyRenumberIncrement = Val(GGT(WLC\txtRenumberIncrement))
    EndIf
    If nMyRenumberIncrement < 1
      scsMessageRequester(GWT(#WLC), LangPars("Errors", "MustBeGreaterThan", GGT(WLC\lblRenumberIncrement), "0"))
      ProcedureReturn #False
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WLC_setRangeFromGridSelection()
  PROCNAMEC()
  Protected n
  Protected nFirstSelectedRow, nLastSelectedRow
  
  debugMsg(sProcName, #SCS_START)
  
  With WLC
    nFirstSelectedRow = -1
    nLastSelectedRow = -1
    For n = 0 To (CountGadgetItems(\grdPreview)-1)
      If GetGadgetItemState(\grdPreview, n) = #PB_ListIcon_Selected
        If nFirstSelectedRow = -1
          nFirstSelectedRow = n
        EndIf
        nLastSelectedRow = n
      EndIf
    Next n
    SGS(\cboStartCue, nFirstSelectedRow)
    SGS(\cboEndCue, nLastSelectedRow)
  EndWith
  
EndProcedure

Procedure WLC_EventHandler()
  PROCNAMEC()
  
  With WLC
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WLC_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel
            WLC_Form_Unload()
            
          Case \btnHelp
            displayHelpTopic("cue_renumbering.htm")
            
          Case \btnOK
            WLC_applyLabelChanges()
            WLC_Form_Unload()
            
          Case \btnReset
            WLC_btnReset_Click()
            
          Case \btnSelectAll
            WLC_btnSelectAll_Click()
            
          Case \btnViewChanges
            WLC_tryChange()
            
          Case \cboEndCue
            WLC_selectRowsForCueSelection()
            
          Case \cboStartCue
            WLC_selectRowsForCueSelection()
            
          Case \grdPreview
            If gnEventType = #PB_EventType_Change
              WLC_setRangeFromGridSelection()
              ; now call WLC_selectRowsForCueSelection() to avoid the confusion of using Ctrl in a multi-select,
              ; because WLC_selectRowsForCueSelection() will select all rows betweeb the first and last selected rows
              WLC_selectRowsForCueSelection()
            EndIf
            
          Case \txtCueLabel
            ; no action
            
          Case \txtRenumberIncrement
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WLC_txtRenumberIncrement_Validate())
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
