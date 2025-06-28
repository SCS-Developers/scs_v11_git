; File: fmEditQS.pbi

EnableExplicit

Procedure WQS_cboSFRAction_Click(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected h, bSFRTimeOverrideSensible
  Protected nPrevAction, nNewAction
  
  debugMsg(sProcName, "cboSFRAction[" + Index + "]\text=" + GetGadgetText(WQS\cboSFRAction[Index]))
  
  With aSub(nEditSubPtr)
    nPrevAction = \nSFRAction[Index]
    nNewAction = GetGadgetItemData(WQS\cboSFRAction[Index], GGS(WQS\cboSFRAction[Index]))
    
    u = preChangeSubL(nPrevAction, GGT(WQS\lblActionReqd), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \nSFRAction[Index] = nNewAction
    
    If nNewAction <> nPrevAction
      If (nPrevAction = #SCS_SFR_ACT_RELEASE) Or (nNewAction = #SCS_SFR_ACT_RELEASE) Or
         (nPrevAction = #SCS_SFR_ACT_CANCELREPEAT) Or (nNewAction = #SCS_SFR_ACT_CANCELREPEAT) Or
         (nPrevAction = #SCS_SFR_ACT_STOPMTC) Or (nNewAction = #SCS_SFR_ACT_STOPMTC) Or
         (nPrevAction = #SCS_SFR_ACT_STOPCHASE) Or (nNewAction = #SCS_SFR_ACT_STOPCHASE)
        WQS_populateOneCboSFRCueEntry(nEditSubPtr, Index)
      EndIf
    EndIf
    
    If Index = 0
      setDefaultSubDescr()
      setDefaultCueDescr()
    EndIf
    
    Select \nSFRAction[Index]
      Case #SCS_SFR_ACT_NA, #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_FADEALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
        \nSFRCueType[Index] = grSubDef\nSFRCueType[Index]
        \sSFRCue[Index] = grSubDef\sSFRCue[Index]
        \nSFRSubNo[Index] = grSubDef\nSFRSubNo[Index]
        \nSFRSubRef[Index] = grSubDef\nSFRSubRef[Index]
        \nSFRCuePtr[Index] = grSubDef\nSFRCuePtr[Index]
        \nSFRSubPtr[Index] = grSubDef\nSFRSubPtr[Index]
        SGS(WQS\cboSFRCue[Index], 0)
        
      Case #SCS_SFR_ACT_FADEOUT, #SCS_SFR_ACT_FADEOUTHIB, #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT
        bSFRTimeOverrideSensible = #True
        If \nSFRTimeOverride < 0
          \nSFRTimeOverride = grProd\nDefSFRTimeOverride
          SetGadgetText(WQS\txtTimeOverride, timeToStringT(\nSFRTimeOverride))
        EndIf
        
    EndSelect
    
    If bSFRTimeOverrideSensible = #False
      For h = 0 To #SCS_MAX_SFR
        Select \nSFRAction[h]
          Case #SCS_SFR_ACT_FADEOUT, #SCS_SFR_ACT_FADEOUTHIB, #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT
            bSFRTimeOverrideSensible = #True
            Break
        EndSelect
      Next h
      If bSFRTimeOverrideSensible = #False
        If \nSFRTimeOverride >= 0
          \nSFRTimeOverride = -2
          SetGadgetText(WQS\txtTimeOverride, "")
        EndIf
        
      EndIf
    EndIf
    
    WQS_fcSFRAction()
    
    postChangeSubL(u, \nSFRAction[Index], -5, Index)
    
  EndWith
EndProcedure

Procedure WQS_cboSFRCue_Click(Index)
  PROCNAMECS(nEditSubPtr)
  Protected i, j
  Protected u
  Protected nPrevAction, nThisAction
  Protected nCboCueData, nCboActionData, nSubId, nLoopNo
  Protected nListIndex
  Protected nNewCuePtr, nNewSubPtr, nNewLoopNo
  Protected sOld.s, sNew.s

  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nNewCuePtr = -1
  nNewSubPtr = -1
  nNewLoopNo = -1
  
  With aSub(nEditSubPtr)
    
    sOld = decodeSFRCueType(\nSFRCueType[Index]) + \sSFRCue[Index] + "." + \nSFRSubNo[Index] + "." + \nSFRLoopNo[Index]
    debugMsg(sProcName, "sOld=" + sOld)
    u = preChangeSubS(sOld, GGT(WQS\lblSFRCue), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    
    nCboActionData = getCurrentItemData(WQS\cboSFRAction[Index])
    nCboCueData = getCurrentItemData(WQS\cboSFRCue[Index])
    If nCboCueData > 0
      nSubId = nCboCueData
      nLoopNo = -1
    Else
      nSubId = Round((nCboCueData * -1) / 100, #PB_Round_Down)
      nLoopNo = (nCboCueData * -1) - (nSubId * 100)
    EndIf
    debugMsg(sProcName, "nCboCueData=" + nCboCueData + ", nSubId=" + nSubId + ", nLoopNo=" + nLoopNo)
    
    Select nCboCueData
      Case #SCS_SFR_CUE_NA, #SCS_SFR_CUE_ALL_FIRST To #SCS_SFR_CUE_ALL_LAST, #SCS_SFR_CUE_PLAY_FIRST To #SCS_SFR_CUE_PLAY_LAST, #SCS_SFR_CUE_ALLEXCEPT, #SCS_SFR_CUE_PLAYEXCEPT
        \nSFRCueType[Index] = nCboCueData
        \sSFRCue[Index] = ""
        \nSFRCuePtr[Index] = -1
        \nSFRSubNo[Index] = -1
        \nSFRSubPtr[Index] = -1
        \nSFRSubRef[Index] = -1
        \nSFRLoopNo[Index] = -1
        
      Case #SCS_SFR_CUE_PREV
        \nSFRCueType[Index] = #SCS_SFR_CUE_PREV
        If Index = 0
          setCuePtrForSFRPrevCueType(nEditSubPtr, Index)
        Else
          \sSFRCue[Index] = ""
          \nSFRCuePtr[Index] = -1
          \nSFRSubNo[Index] = -1
          \nSFRSubPtr[Index] = -1
          \nSFRSubRef[Index] = -1
          \nSFRLoopNo[Index] = -1
        EndIf
        
      Default
        For i = 1 To gnLastCue
          If aCue(i)\nCueId = nCboCueData
            nNewCuePtr = i
            Break
          EndIf
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\nSubId = nSubId
              nNewSubPtr = j
              nNewLoopNo = nLoopNo
              Break
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
          If nNewSubPtr >= 0
            Break
          EndIf
        Next i
        If nNewCuePtr >= 0
          \sSFRCue[Index] = aCue(nNewCuePtr)\sCue
          \nSFRCuePtr[Index] = nNewCuePtr
          \nSFRSubNo[Index] = -1
          \nSFRSubPtr[Index] = -1
          \nSFRSubRef[Index] = -1
          \nSFRLoopNo[Index] = -1
          \nSFRCueType[Index] = #SCS_SFR_CUE_SEL
        EndIf
        If nNewSubPtr >= 0
          \sSFRCue[Index] = aSub(nNewSubPtr)\sCue
          \nSFRCuePtr[Index] = -1
          \nSFRSubNo[Index] = aSub(nNewSubPtr)\nSubNo
          \nSFRSubPtr[Index] = nNewSubPtr
          \nSFRSubRef[Index] = aSub(nNewSubPtr)\nSubRef
          \nSFRLoopNo[Index] = nNewLoopNo
          \nSFRCueType[Index] = #SCS_SFR_CUE_SEL
        EndIf
        
    EndSelect
    
    ; debugMsg(sProcName, "\sSFRCueType[" + Index + "]=" + \sSFRCueType[Index])
    
    If nCboCueData = #SCS_SFR_CUE_NA
      Select \nSFRAction[Index]
        Case #SCS_SFR_ACT_NA, #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_FADEALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
          ; ok
        Default
          \nSFRAction[Index] = #SCS_SFR_ACT_NA
          SGS(WQS\cboSFRAction[Index], 0)
      EndSelect
    Else
      ; nb code here was removed at 11.5.0.104 because changing the 'cue to be actioned' should not have any affect on 'action required' or other fields
    EndIf
    
    If Index = 0
      setDefaultSubDescr()
      setDefaultCueDescr()
    EndIf
    
    WQS_fcSFRCueType()
    WQS_fcSFRAction()
    
    sNew = decodeSFRCueType(\nSFRCueType[Index]) + \sSFRCue[Index] + "." + \nSFRSubNo[Index] + "." + \nSFRLoopNo[Index]
    debugMsg(sProcName, "sNew=" + sNew)
    postChangeSubS(u, sNew, -5, Index)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQS_drawForm()
  PROCNAMEC()
  
  colorEditorComponent(#WQS)
  
EndProcedure

Procedure WQS_Form_Load()
  PROCNAMEC()
  Protected n, m
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQS()
  SUB_loadOrResizeHeaderFields("S", #True)

  rWQS\bInValidate = #False

  With WQS
    For n = 0 To #SCS_MAX_SFR
      ClearGadgetItems(\cboSFRAction[n])
      For m = 0 To ArraySize(gaSFRAction())
        addGadgetItemWithData(\cboSFRAction[n], gaSFRAction(m)\sActDescr, m)
      Next m
    EndWith
  Next n

  WQS_drawForm()
  
EndProcedure

Procedure WQS_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQS_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQS_txtTimeOverride_Validate()
  ; Supports txtTimeOverride being a time field (eg 1.5) or a callable cue parameter (eg OVR)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nTimeGadget, sPrompt.s, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  Protected sNewTimeOverride.s
  Protected sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nTimeGadget = WQS\txtTimeOverride
  sPrompt = removeLF(GGT(WQS\lblTimeOverride))
  macCommonTimeFieldValidationT(rWQS\bInValidate) ; nb populates sValue which will be used by macReadNumericOrStringParam() below
  
  sNewTimeOverride = Trim(GGT(nTimeGadget))
  If nTimeFieldIsParamId = -1
    sErrorMsg = LangPars("Errors", "CallableParamNotFound", sNewTimeOverride, aSub(nEditSubPtr)\sSubLabel, aCue(nEditCuePtr)\sCue)
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sSFRTimeOverride, \nSFRTimeOverride)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sSFRTimeOverride, \nSFRTimeOverride, grSubDef\nSFRTimeOverride, #True)
    ; Macro macReadNumericOrStringParam populates \sSFRTimeOverride and \nSFRTimeOverride from the value in sValue
    sNew = makeDisplayTimeValue(\sSFRTimeOverride, \nSFRTimeOverride)
    postChangeSubS(u, sNew)
  EndWith
  
  markValidationOK(WQS\txtTimeOverride)
  
  debugMsg(sProcName, #SCS_END)

  ProcedureReturn #True
EndProcedure

Procedure WQS_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQS
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQS)
        
        ; detail gadgets
      Case \txtTimeOverride
        ETVAL2(WQS_txtTimeOverride_Validate())
        
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

Procedure WQS_EventHandler()
  PROCNAMEC()
  
  With WQS
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQS)
            
            ; detail gadgets in alphabetical order
            
          Case \cboSFRAction[0] ; cboSFRAction
            CBOCHG(WQS_cboSFRAction_Click(gnEventGadgetArrayIndex))
            
          Case \cboSFRCue[0] ; cboSFRCue
            CBOCHG(WQS_cboSFRCue_Click(gnEventGadgetArrayIndex))
            
          Case \chkCompleteAssocAutoStartCues   ; chkCompleteAssocAutoStartCues
            CHKOWNCHG(WQS_chkCompleteAssocAutoStartCues_Click())
            
          Case \chkGoNext   ; chkGoNext
            CHKOWNCHG(WQS_chkGoNext_Click())
            
          Case \chkHoldAssocAutoStartCues   ; chkHoldAssocAutoStartCues
            CHKOWNCHG(WQS_chkHoldAssocAutoStartCues_Click())
            
          Case \txtGoNextDelay ; txtGoNextDelay
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQS_txtGoNextDelay_Validate())
            EndIf
            
          Case \txtTimeOverride ; txtTimeOverride
            Select gnEventType
              Case #PB_EventType_Focus
                setOrClearGadgetValidValuesFlag()
              Case #PB_EventType_LostFocus
                ETVAL(WQS_txtTimeOverride_Validate())
            EndSelect
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQS_fcSFRCueType()
  PROCNAMECS(nEditSubPtr)
  Protected h
  Protected bEnable
  
  With aSub(nEditSubPtr)
    bEnable = #True
    For h = 0 To #SCS_MAX_SFR
      If getEnabled(WQS\cboSFRCue[h]) <> bEnable
        setEnabled(WQS\cboSFRCue[h], bEnable)
        setEnabled(WQS\cboSFRAction[h], bEnable)
      EndIf
    Next h
  EndWith
  
EndProcedure

Procedure WQS_fcSFRAction()
  PROCNAMECS(nEditSubPtr)
  Protected h
  Protected bEnableAutoStart, bEnableTimeOverride, bEnableGoNext, bEnableCue
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    For h = 0 To #SCS_MAX_SFR
      bEnableCue = #False
      Select \nSFRAction[h]
        Case #SCS_SFR_ACT_FADEOUT
          bEnableAutoStart = #True
          bEnableTimeOverride = #True
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_FADEOUTHIB
          bEnableTimeOverride = #True
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_PAUSE
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_RESUME
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_PAUSEHIB
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_RESUMEHIB
          bEnableTimeOverride = #True
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_RESUMEHIBNEXT
          bEnableTimeOverride = #True
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_STOP
          bEnableAutoStart = #True
          bEnableGoNext = #True
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_RELEASE
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_CANCELREPEAT; Added 5Aug2024 11.10.3bb
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_STOPCHASE
          bEnableCue = #True
          
        Case #SCS_SFR_ACT_FADEALL
          bEnableTimeOverride = #True
          
        Case #SCS_SFR_ACT_NA, #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
          ; none enabled
          
      EndSelect
      
      If \nSFRAction[h] <> #SCS_SFR_ACT_NA
        debugMsg(sProcName, "\nSFRAction[" + h + "]=" + decodeSFRAction(\nSFRAction[h]) + ", bEnableCue=" + strB(bEnableCue))
      EndIf
      setEnabled(WQS\cboSFRCue[h], bEnableCue)
      
    Next h
    
    debugMsg(sProcName, "bEnableAutoStart=" + strB(bEnableAutoStart) + ", bEnableTimeOverride=" + strB(bEnableTimeOverride) + ", bEnableGoNext=" + strB(bEnableGoNext))
    
    setOwnEnabled(WQS\chkCompleteAssocAutoStartCues, bEnableAutoStart)
    setOwnEnabled(WQS\chkHoldAssocAutoStartCues, bEnableAutoStart)
    If bEnableAutoStart = #False
      \bSFRCompleteAssocAutoStartCues = #False
      \bSFRHoldAssocAutoStartCues = #False
      If getOwnState(WQS\chkCompleteAssocAutoStartCues) = #True
        setOwnState(WQS\chkCompleteAssocAutoStartCues, #False)
      EndIf
      If getOwnState(WQS\chkHoldAssocAutoStartCues) = #True
        setOwnState(WQS\chkHoldAssocAutoStartCues, #False)
      EndIf
    EndIf
    
    setEnabled(WQS\txtTimeOverride, bEnableTimeOverride)
    setTextBoxBackColor(WQS\txtTimeOverride)
    If bEnableTimeOverride = #False
      \nSFRTimeOverride = grSubDef\nSFRTimeOverride
      SGT(WQS\txtTimeOverride, "")
    EndIf
    
    setOwnEnabled(WQS\chkGoNext, bEnableGoNext)
    If bEnableGoNext = #False
      \bSFRGoNext = #False
      \nSFRGoNextDelay = grSubDef\nSFRGoNextDelay
      If getOwnState(WQS\chkGoNext) = #True
        setOwnState(WQS\chkGoNext, #False)
      EndIf
    EndIf
    setEnabled(WQS\txtGoNextDelay, bEnableGoNext)
    setTextBoxBackColor(WQS\txtGoNextDelay)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQS_fcGoNext()
  PROCNAMECS(nEditSubPtr)
  Protected bEnable
  
  If nEditSubPtr >= 0
    If aSub(nEditSubPtr)\bSFRGoNext
      bEnable = #True
    EndIf
  EndIf
  setEnabled(WQS\txtGoNextDelay, bEnable)
  setTextBoxBackColor(WQS\txtGoNextDelay)
  
EndProcedure

Procedure WQS_txtGoNextDelay_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeFieldT(GGT(WQS\txtGoNextDelay), GGT(WQS\lblGoNextDelay), #False, #False, 0, #True) = #False
    ProcedureReturn #False
    
  ElseIf GGT(WQS\txtGoNextDelay) <> gsTmpString
    SGT(WQS\txtGoNextDelay, gsTmpString)
    
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nSFRGoNextDelay, GGT(WQS\lblGoNextDelay))
    \nSFRGoNextDelay = stringToTime(GGT(WQS\txtGoNextDelay))
    postChangeSubL(u, \nSFRGoNextDelay)
  EndWith
  
  markValidationOK(WQS\txtGoNextDelay)
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQS_chkCompleteAssocAutoStartCues_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected bSFRCompleteAssocAutoStartCues
  
  With aSub(nEditSubPtr)
    bSFRCompleteAssocAutoStartCues = getOwnState(WQS\chkCompleteAssocAutoStartCues)
    If bSFRCompleteAssocAutoStartCues <> \bSFRCompleteAssocAutoStartCues
      u = preChangeSubL(\bSFRCompleteAssocAutoStartCues, getOwnText(WQS\chkCompleteAssocAutoStartCues))
      \bSFRCompleteAssocAutoStartCues = bSFRCompleteAssocAutoStartCues
      ; \bSFRCompleteAssocAutoStartCues and \bSFRHoldAssocAutoStartCues are mutually exclusive
      If \bSFRCompleteAssocAutoStartCues
        If \bSFRHoldAssocAutoStartCues
          \bSFRHoldAssocAutoStartCues = #False
          setOwnState(WQS\chkHoldAssocAutoStartCues, \bSFRHoldAssocAutoStartCues)
        EndIf
      EndIf
      postChangeSubL(u, \bSFRCompleteAssocAutoStartCues)
    EndIf
  EndWith
EndProcedure

Procedure WQS_chkHoldAssocAutoStartCues_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected bSFRHoldAssocAutoStartCues
  
  With aSub(nEditSubPtr)
    bSFRHoldAssocAutoStartCues = getOwnState(WQS\chkHoldAssocAutoStartCues)
    If bSFRHoldAssocAutoStartCues <> \bSFRHoldAssocAutoStartCues
      u = preChangeSubL(\bSFRHoldAssocAutoStartCues, getOwnText(WQS\chkHoldAssocAutoStartCues))
      \bSFRHoldAssocAutoStartCues = bSFRHoldAssocAutoStartCues
      ; \bSFRHoldAssocAutoStartCues and \bSFRCompleteAssocAutoStartCues are mutually exclusive
      If \bSFRHoldAssocAutoStartCues
        If \bSFRCompleteAssocAutoStartCues
          \bSFRCompleteAssocAutoStartCues = #False
          setOwnState(WQS\chkCompleteAssocAutoStartCues, \bSFRCompleteAssocAutoStartCues)
        EndIf
      EndIf
      postChangeSubL(u, \bSFRHoldAssocAutoStartCues)
    EndIf
  EndWith
EndProcedure

Procedure WQS_chkGoNext_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected bSFRGoNext
  
  With aSub(nEditSubPtr)
    bSFRGoNext = getOwnState(WQS\chkGoNext)
    If bSFRGoNext <> \bSFRGoNext
      u = preChangeSubL(\bSFRGoNext, getOwnText(WQS\chkGoNext))
      \bSFRGoNext = bSFRGoNext
      If \bSFRGoNext = #False
        \nSFRGoNextDelay = grSubDef\nSFRGoNextDelay
        If Len(Trim(GGT(WQS\txtGoNextDelay))) > 0
          SGT(WQS\txtGoNextDelay, "")
        EndIf
      EndIf
      WQS_fcGoNext()
      postChangeSubL(u, \bSFRGoNext)
    EndIf
  EndWith
EndProcedure

Procedure WQS_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQS
    If IsGadget(\scaSFRCues)
      ; \scaSFRCues automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaSFRCues) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaSFRCues, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailS
      nHeight = nInnerHeight - GadgetY(\cntSubDetailS)
      ResizeGadget(\cntSubDetailS, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
    EndIf
  EndWith
EndProcedure

Procedure WQS_populateOneCboSFRCueEntry(pSubPtr, nIndex)
  PROCNAMECS(pSubPtr)
  Protected nGadgetNo
  Protected n2
  Protected i, j, k
  Protected nThisCuePtr, nIncludedSubCount, nSubCount, bUseSubDescr
  Protected sCboText.s, sLoopText.s
  Protected bReleaseLoop, nCueMaxLoopInfo, nSubMaxLoopInfo, nLoopNo, nData, nListIndex
  Protected bIncludeCueInCbo, bSkipSub
  Protected bStopChase, bIncludeThis
  Static sLoop.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex)
  
  If bStaticLoaded = #False
    sLoop = " (" + Lang("Common", "Loop") + " #$1" + ")"
    bStaticLoaded = #True
  EndIf
  
  nGadgetNo = WQS\cboSFRCue[nIndex]
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \nSFRAction[nIndex] <> #SCS_SFR_ACT_NA
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSFRAction[" + nIndex + "]=" + decodeSFRAction(\nSFRAction[nIndex]))
      EndIf
      
      If \nSFRAction[nIndex] = #SCS_SFR_ACT_RELEASE
        bReleaseLoop = #True
      ElseIf \nSFRAction[nIndex] = #SCS_SFR_ACT_STOPCHASE
        bStopChase = #True
      EndIf
;       debugMsg0(sProcName, "\nSFRCuePtr[" + nIndex + "]=" + getCueLabel(\nSFRCuePtr[nIndex]
      
      ClearGadgetItems(nGadgetNo)
      addGadgetItemWithData(nGadgetNo, "", #SCS_SFR_CUE_NA)
      
      ; Modified the following 22Aug2024 11.10.3bk following email from Jason Mai about needing to, for example, 
      ; 'STOP immediately all playing video/image cues' and ALSO 'FADE OUT all playing audio cues'
      For n2 = #SCS_SFR_CUE_ALL_FIRST To #SCS_SFR_CUE_ALL_LAST
        bIncludeThis = #True
        If bStopChase
          Select n2
            Case #SCS_SFR_CUE_ALL_AUDIO, #SCS_SFR_CUE_ALL_VIDEO_IMAGE, #SCS_SFR_CUE_ALL_LIVE
              bIncludeThis = #False
          EndSelect
        EndIf
        ; debugMsg0(sProcName, "bIncludeThis=" + strB(bIncludeThis) + ", n2=" + decodeSFRCueType(n2))
        If bIncludeThis
          addGadgetItemWithData(nGadgetNo, gaSFRCueType(n2)\sCueType, n2)
        EndIf
      Next n2
      
      If nIndex > 0 And bReleaseLoop = #False And bStopChase = #False
        addGadgetItemWithData(nGadgetNo, gaSFRCueType(#SCS_SFR_CUE_ALLEXCEPT)\sCueType, #SCS_SFR_CUE_ALLEXCEPT)
      EndIf
      
      For n2 = #SCS_SFR_CUE_PLAY_FIRST To #SCS_SFR_CUE_PLAY_LAST
        bIncludeThis = #True
        If bStopChase
          Select n2
            Case #SCS_SFR_CUE_PLAY_AUDIO, #SCS_SFR_CUE_PLAY_VIDEO_IMAGE, #SCS_SFR_CUE_PLAY_LIVE
              bIncludeThis = #False
          EndSelect
        EndIf
        ; debugMsg0(sProcName, "bIncludeThis=" + strB(bIncludeThis) + ", n2=" + decodeSFRCueType(n2))
        If bIncludeThis
          addGadgetItemWithData(nGadgetNo, gaSFRCueType(n2)\sCueType, n2)
        EndIf
      Next n2
      
      If nIndex > 0 And bReleaseLoop = #False And bStopChase = #False
        addGadgetItemWithData(nGadgetNo, gaSFRCueType(#SCS_SFR_CUE_PLAYEXCEPT)\sCueType, #SCS_SFR_CUE_PLAYEXCEPT)
      EndIf
      
      addGadgetItemWithData(nGadgetNo, gaSFRCueType(#SCS_SFR_CUE_PREV)\sCueType, #SCS_SFR_CUE_PREV)
      
      nThisCuePtr = \nCueIndex
      For i = gnLastCue To 1 Step -1
        If (bReleaseLoop) And (aCue(i)\bSubTypeF = #False)
          ; 'release loop' only available for SubTypeF (Audio File)
          Continue
        EndIf
        If (bStopChase) And (aCue(i)\bSubTypeK = #False)
          ; 'stop chase' only available for SubTypeK (Lighting)
          Continue
        EndIf
        bIncludeCueInCbo = #True
        If (bReleaseLoop) And (aCue(i)\bSubTypeF)
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeF
              k = aSub(j)\nFirstAudIndex
              If k >= 0
                If aAud(k)\nMaxLoopInfo > 0
                  ; at least 2 loops, so do not display a cue-level entry for this cue (i) in WQS\cboSFRCue[nIndex] 
                  bIncludeCueInCbo = #False
                  Break
                EndIf
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
        
        If (bStopChase) And (aCue(i)\bSubTypeK)
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeK
              If aSub(j)\bChase = #False
                bIncludeCueInCbo = #False
                Break
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
        
        If (aCue(i)\bSubTypeA) Or (aCue(i)\bSubTypeE) Or (aCue(i)\bSubTypeF) Or (aCue(i)\bSubTypeG) Or (aCue(i)\bSubTypeI) Or (aCue(i)\bSubTypeP) Or (aCue(i)\bSubTypeM) Or (aCue(i)\bSubTypeK)
          If bIncludeCueInCbo
            sCboText = buildCueForCBO(i)
            addGadgetItemWithData(nGadgetNo, sCboText, aCue(i)\nCueId)
          EndIf
          nIncludedSubCount = 0
          nSubCount = 0
          nCueMaxLoopInfo = -1
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            nSubCount + 1
            If (i < nThisCuePtr) Or ((i = nThisCuePtr) And (aSub(j)\nSubNo < \nSubNo))
              If (aSub(j)\bSubTypeA) Or (aSub(j)\bSubTypeE) Or (aSub(j)\bSubTypeF) Or (aSub(j)\bSubTypeG) Or (aSub(j)\bSubTypeI) Or (aSub(j)\bSubTypeP) Or (aSub(j)\bSubTypeM) Or (aSub(j)\bSubTypeK)
                bSkipSub = #False
                If (bReleaseLoop) And (aSub(j)\bSubTypeF)
                  k = aSub(j)\nFirstAudIndex
                  If aAud(k)\nMaxLoopInfo < 0
                    ; 'release loop' requested, but no loop in this sub-cue so cannot release a loop, so do not include this sub in the list
                    bSkipSub = #True
                  ElseIf aAud(k)\nMaxLoopInfo > nCueMaxLoopInfo
                    nCueMaxLoopInfo = aAud(k)\nMaxLoopInfo
                  EndIf
                EndIf
                If (bStopChase) And (aSub(j)\bSubTypeK)
                  If aSub(j)\bChase = #False
                    bSkipSub = #True
                  EndIf
                EndIf
                If bSkipSub = #False
                  nIncludedSubCount + 1
                EndIf
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
          ; debugMsg(sProcName, "nSubCount=" + nSubCount + ", nIncludedSubCount=" + nIncludedSubCount + ", nCueMaxLoopInfo=" + nCueMaxLoopInfo)
          If (nIncludedSubCount > 1) Or (nSubCount > 1)
            bUseSubDescr = #True
          Else
            bUseSubDescr = #False
          EndIf
          If (nIncludedSubCount > 1) Or (nSubCount > 1) Or (nCueMaxLoopInfo > 0)
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If (i < nThisCuePtr) Or ((i = nThisCuePtr) And (aSub(j)\nSubNo < \nSubNo))
                If (aSub(j)\bSubTypeA) Or (aSub(j)\bSubTypeE) Or (aSub(j)\bSubTypeF) Or (aSub(j)\bSubTypeG) Or (aSub(j)\bSubTypeI) Or (aSub(j)\bSubTypeP) Or (aSub(j)\bSubTypeM) Or (aSub(j)\bSubTypeK)
                  bSkipSub = #False
                  If bUseSubDescr
                    sCboText = buildSubCueForCBO(j)
                  Else
                    sCboText = buildCueForCBO(i)
                  EndIf
                  nSubMaxLoopInfo = -1
                  If bReleaseLoop
                    If aSub(j)\bSubTypeF
                      k = aSub(j)\nFirstAudIndex
                      nSubMaxLoopInfo = aAud(k)\nMaxLoopInfo
                      If nSubMaxLoopInfo < 0
                        ; 'release loop' requested, but no loop in this sub-cue so cannot release a loop, so do not include this sub in the list
                        bSkipSub = #True
                      EndIf
                    EndIf
                  EndIf
                  If bStopChase
                    If aSub(j)\bSubTypeK
                      If aSub(j)\bChase = #False
                        bSkipSub = #True
                      EndIf
                    EndIf
                  EndIf
                  If bSkipSub = #False
                    If nSubMaxLoopInfo > 0
                      ; at least two loops
                      For nLoopNo = nSubMaxLoopInfo+1 To 1 Step -1
                        sLoopText = ReplaceString(sLoop, "$1", Str(nLoopNo))
                        If bUseSubDescr
                          sCboText = buildSubCueForCBO(j, sLoopText)
                        Else
                          sCboText = buildCueForCBO(i, sLoopText)
                        EndIf
                        nData = ((aSub(j)\nSubId * 100) + nLoopNo) * -1  ; -ve data indicates this contains a loop number. see the calculation for details.
                        ; debugMsg(sProcName, "nLoopNo=" + nLoopNo + ", nData=" + nData)
                       addGadgetItemWithData(nGadgetNo, sCboText, nData)
                      Next nLoopNo
                    Else
                      ; no loops, or only one loop, or not an audio file sub-cue
                      addGadgetItemWithData(nGadgetNo, sCboText, aSub(j)\nSubId)
                    EndIf
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndIf
      Next i
      
      Select \nSFRCueType[nIndex]
        Case #SCS_SFR_CUE_SEL
          i = \nSFRCuePtr[nIndex]
          j = \nSFRSubPtr[nIndex]
          ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", j=" + getSubLabel(j))
          ; check j first as this will be >= 1 if the SFR item is sub-specific
          If j >= 1
            nLoopNo = \nSFRLoopNo[nIndex]
            If nLoopNo > 0
              nData = ((aSub(j)\nSubId * 100) + nLoopNo) * -1  ; -ve data indicates this contains a loop number. see the calculation for details.
            Else
              nData = aSub(j)\nSubId
            EndIf
            nListIndex = indexForComboBoxData(nGadgetNo, nData, 0)
            ; debugMsg(sProcName, "nData=" + nData + ", nListIndex=" + nListIndex)
            If nListIndex = 0
              ; if not found, this may be because the target cue has been moved down past the SFR cue so create an extra entry in the CBO list for the target cue
              sCboText = buildSubCueForCBO(j)
              ; debugMsg(sProcName, "j=" + getSubLabel(j) + ", sCboText=" + sCboText)
              addGadgetItemWithData(nGadgetNo, sCboText, nData)
              nListIndex = indexForComboBoxData(nGadgetNo, nData, 0)
            EndIf
            
          ElseIf i >= 1
            ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueId=" + aCue(i)\nCueId)
            nListIndex = indexForComboBoxData(nGadgetNo, aCue(i)\nCueId, 0)
            ; debugMsg(sProcName, "nListIndex=" + nListIndex + ", aCue(" + getCueLabel(i) + ")\nCueId=" + aCue(i)\nCueId)
            If nListIndex = 0
              If j <= 0
                j = aCue(i)\nFirstSubIndex
              EndIf
              If j >= 0
                nLoopNo = \nSFRLoopNo[nIndex]
                If nLoopNo > 0
                  nData = ((aSub(j)\nSubId * 100) + nLoopNo) * -1  ; -ve data indicates this contains a loop number. see the calculation for details.
                  nListIndex = indexForComboBoxData(nGadgetNo, nData, 0)
                  ; debugMsg(sProcName, "nListIndex=" + nListIndex + ", nData=" + nData)
                Else
                  nData = aSub(j)\nSubId
                  nListIndex = indexForComboBoxData(nGadgetNo, nData, 0)
                  ; debugMsg(sProcName, "nListIndex=" + nListIndex + ", nData=" + nData)
                  If nListIndex = 0
                    nData = ((aSub(j)\nSubId * 100) + 1) * -1  ; -ve data indicates this contains a loop number. see the calculation for details.
                    nListIndex = indexForComboBoxData(nGadgetNo, nData, 0)
                    ; debugMsg(sProcName, "nListIndex=" + nListIndex + ", nData=" + nData)
                  EndIf
                EndIf
              EndIf
            EndIf
            If nListIndex = 0
              ; if not found, this may be because the target cue has been moved down past the SFR cue so create an extra entry in the CBO list for the target cue
              sCboText = buildCueForCBO(i)
              ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", sCboText=" + sCboText)
; debugMsg(sProcName, "calling addGadgetItemWithData(nGadgetNo, " + #DQUOTE$ + sCboText + #DQUOTE$ + ", " + aCue(i)\nCueId + ")")
              addGadgetItemWithData(nGadgetNo, sCboText, aCue(i)\nCueId)
              nListIndex = indexForComboBoxData(nGadgetNo, aCue(i)\nCueId, 0)
            EndIf
            
          Else
            nListIndex = 0
            ; debugMsg(sProcName, "nListIndex=" + nListIndex)
            
          EndIf
          
        Default
          nListIndex = indexForComboBoxData(nGadgetNo, \nSFRCueType[nIndex], 0)
          ; debugMsg(sProcName, "nListIndex=" + nListIndex)
          
      EndSelect
      
      ; debugMsg(sProcName, "nListIndex=" + nListIndex)
      SGS(nGadgetNo, nListIndex)
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQS_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected i, j, n, n2, m, nItem, nListIndex
  Protected sTmp.s
  Protected nThisCuePtr, nIncludedSubCount, nSubCount
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQSCreated = #False
    WQS_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQS\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "S", WQS)
    
    For n = 0 To #SCS_MAX_SFR
      nListIndex = indexForComboBoxData(WQS\cboSFRAction[n], \nSFRAction[n], 0)
      SGS(WQS\cboSFRAction[n], nListIndex)
      WQS_populateOneCboSFRCueEntry(pSubPtr, n)
    Next n
    
    ; SetGadgetText(WQS\txtTimeOverride, timeToStringT(\nSFRTimeOverride))
    SGT(WQS\txtTimeOverride, makeDisplayTimeValueT(\sSFRTimeOverride, \nSFRTimeOverride))
    setOwnState(WQS\chkCompleteAssocAutoStartCues, \bSFRCompleteAssocAutoStartCues)
    setOwnState(WQS\chkHoldAssocAutoStartCues, \bSFRHoldAssocAutoStartCues)
    
    setOwnState(WQS\chkGoNext, \bSFRGoNext)
    If \bSFRGoNext
      SGT(WQS\txtGoNextDelay, timeToStringBWZ(\nSFRGoNextDelay))
    Else
      SGT(WQS\txtGoNextDelay, "")
    EndIf
    WQS_fcGoNext()
    
    WQS_fcSFRCueType()
    WQS_fcSFRAction()
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF
