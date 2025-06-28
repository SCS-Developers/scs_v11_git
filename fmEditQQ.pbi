; File: fmEditQQ.pbi (edit 'Call Cue' sub-cue)

EnableExplicit

Procedure WQQ_displayParamsIfReqd()
  PROCNAMECS(nEditSubPtr)
  Protected n, bVisible, sParamDefault.s
  Static sDefaultValue.s
  
  debugMsg(sProcName, #SCS_START)
  
  If Len(sDefaultValue) = 0
    sDefaultValue = Lang("WQQ", "DefaultValue") + ": "
  EndIf
  
  With aSub(nEditSubPtr)
    If \nMaxCallCueParam >= 0
      setVisible(WQQ\lblParams, #True)
    Else
      setVisible(WQQ\lblParams, #False)
    EndIf
    debugMsg(sProcName, "ArraySize(WQQ\txtParamId())=" + ArraySize(WQQ\txtParamId()) + ", aSub(" + getSubLabel(nEditSubPtr) + ")\nMaxCallCueParam=" + \nMaxCallCueParam)
    For n = 0 To ArraySize(WQQ\txtParamId())
      If n <= \nMaxCallCueParam
        bVisible = #True
        SGT(WQQ\txtParamId(n), \aCallCueParam(n)\sCallParamId)
        SGT(WQQ\txtParamValue(n), \aCallCueParam(n)\sCallParamValue)
        sParamDefault = Trim(\aCallCueParam(n)\sCallParamDefault)
        If sParamDefault
          SGT(WQQ\lblParamDefault(n), sDefaultValue + sParamDefault)
        Else
          SGT(WQQ\lblParamDefault(n), "")
        EndIf
      Else
        bVisible = #False
      EndIf
      setVisible(WQQ\txtParamId(n), bVisible)
      setVisible(WQQ\txtParamValue(n), bVisible)
      setVisible(WQQ\lblParamDefault(n), bVisible)
    Next n
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQQ_fcActionReqd()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    Select \nCallCueAction
      Case #SCS_QQ_CALLCUE
        setVisible(WQQ\cntCallCue, #True)
        If IsGadget(WQQ\cntSelHKBank)
          setVisible(WQQ\cntSelHKBank, #False)
        EndIf
        WQQ_displayParamsIfReqd()
      Case #SCS_QQ_SELHKBANK
        If IsGadget(WQQ\cntSelHKBank)
          setVisible(WQQ\cntSelHKBank, #True)
        EndIf
        setVisible(WQQ\cntCallCue, #False)
    EndSelect
  EndWith
  
EndProcedure

Procedure WQQ_cboActionReqd_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nCallCueAction, GGT(WQQ\lblActionReqd))
    \nCallCueAction = getCurrentItemData(WQQ\cboActionReqd)
    grWQQ\nLastCallCueAction = \nCallCueAction
    WQQ_fcActionReqd()
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubL(u, \nCallCueAction)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQQ_cboCallCue_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, i, sListString.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\sCallCue, GGT(WQQ\lblCallCue), -5, #SCS_UNDO_ACTION_CHANGE)
    \sCallCue = grSubDef\sCallCue
    \nCallCuePtr = grSubDef\nCallCuePtr
    sListString = GGT(WQQ\cboCallCue)
    debugMsg(sProcName, "sListString=" + sListString)
    For i = 1 To gnLastCue
      debugMsg(sProcName, "buildCueForCBO(" + getCueLabel(i) + ")=" + buildCueForCBO(i))
      If sListString = buildCueForCBO(i, "", #False, #True)
        debugMsg(sProcName, "found")
        \sCallCue = aCue(i)\sCue
        \nCallCuePtr = i
        Break
      EndIf
    Next i
    debugMsg(sProcName, "\sCallCue=" + \sCallCue)
    populateCallCueParamArray(@aSub(nEditSubPtr))
    WQQ_displayParamsIfReqd()
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubS(u, \sCallCue, -5)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQQ_cboSelHKBank_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nSelHKBank, GGT(WQQ\lblSelHKBank))
    \nSelHKBank = getCurrentItemData(WQQ\cboSelHKBank)
    debugMsg(sProcName, "\nSelHKBank=" + \nSelHKBank)
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubL(u, \nSelHKBank)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQQ_txtParamValue_Validate(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected n, sCallCueParams.s, sPart.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", GGT(WQQ\txtParamValue(" + Index + "))=" + GGT(WQQ\txtParamValue(Index)) + ", gnValidateGadgetNo=" + getGadgetName(gnValidateGadgetNo) + ", gnValidateSubPtr=" + getSubLabel(gnValidateSubPtr))
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\aCallCueParam(Index)\sCallParamValue, GGT(WQQ\lblParams), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \aCallCueParam(Index)\sCallParamValue = Trim(GGT(WQQ\txtParamValue(Index)))
    sCallCueParams = ""
    For n = 0 To \nMaxCallCueParam
      sPart = \aCallCueParam(n)\sCallParamId
      If \aCallCueParam(n)\sCallParamValue
        sPart + "=" + \aCallCueParam(n)\sCallParamValue
      EndIf
      If n = 0
        sCallCueParams = sPart
      Else
        sCallCueParams + ", " + sPart
      EndIf
    Next n
    \sCallCueParams = sCallCueParams
    postChangeSubS(u, \aCallCueParam(Index)\sCallParamValue, -5, Index)
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WQQ_drawForm()
  PROCNAMEC()

  colorEditorComponent(#WQQ)

EndProcedure

Procedure WQQ_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQQ()
  SUB_loadOrResizeHeaderFields("Q", #True)
  
  WQQ_drawForm()

EndProcedure

Procedure WQQ_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQQ_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQQ_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQQ
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQQ)
        
        ; detail gadgets
      Case \txtParamValue(0) ; Added 30Sep2022 11.9.6 following email from Dave Jenkins 26Sep2022
        ETVAL2(WQQ_txtParamValue_Validate(nArrayIndex)) ; Added 30Sep2022 11.9.6
        
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

Procedure WQQ_EventHandler()
  PROCNAMECS(nEditSubPtr)
  
  With WQQ
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQQ)
            
            ; detail gadgets in alphabetical order
            
          Case \cboActionReqd ; cboActionReqd
            CBOCHG(WQQ_cboActionReqd_Click())
            
          Case \cboCallCue ; cboCallCue
            CBOCHG(WQQ_cboCallCue_Click())
            
          Case \cboSelHKBank ; cboSelHKBank
            CBOCHG(WQQ_cboSelHKBank_Click())
            
          Case \cntCallCue, \cntSelHKBank, \cntSubDetailQ
            ; ignore
            
          Case \scaCallCue
            ; ignore
            
          Case \txtParamValue(0)
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQQ_txtParamValue_Validate(gnEventGadgetArrayIndex))
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQQ_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQQ
    If IsGadget(\scaCallCue)
      ; \scaGoTo automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaCallCue) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaCallCue, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailQ
      nHeight = nInnerHeight - GadgetY(\cntSubDetailQ)
      ResizeGadget(\cntSubDetailQ, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
    EndIf
  EndWith
EndProcedure

Procedure WQQ_displaySub(pSubPtr)  ; subtype Q = 'call cue'
  PROCNAMECS(pSubPtr)
  Protected i, nItem, nListIndex, nBankIndex, nMaxCboWidth
  Protected sTmp.s, sBank.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQQCreated = #False
    WQQ_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQQ\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "Q", WQQ)
    
    setComboBoxByData(WQQ\cboActionReqd, \nCallCueAction)
    
    ClearGadgetItems(WQQ\cboCallCue)
    nListIndex = -1
    nItem = -1
    For i = 1 To gnLastCue
      If i <> nEditCuePtr
        Select aCue(i)\nActivationMethod
          Case #SCS_ACMETH_CALL_CUE, #SCS_ACMETH_HK_TRIGGER, #SCS_ACMETH_EXT_TRIGGER
            ; added #SCS_ACMETH_HK_TRIGGER, #SCS_ACMETH_EXT_TRIGGER 6Dec2019 11.8.2 following email from Doug Champion
            ; nb Toggle, Note and Step not supported by 'Call Cue'
            sTmp = buildCueForCBO(i, "", #False, #True)
            AddGadgetItem(WQQ\cboCallCue, -1, sTmp)
            nListIndex + 1
            If aCue(i)\sCue = \sCallCue
              nItem = nListIndex
            EndIf
        EndSelect
      EndIf
    Next i
    nMaxCboWidth = GadgetWidth(WQQ\cntCallCue) - GadgetX(WQQ\cboCallCue)
    setComboBoxWidth(WQQ\cboCallCue, 100, #False, nMaxCboWidth)
    SetGadgetState(WQQ\cboCallCue, nItem)
    
    If grLicInfo\nMaxHotkeyBank > 0
      ClearGadgetItems(WQQ\cboSelHKBank)
      sBank = Lang("HKeys", "Bank")
      For nBankIndex = 1 To grLicInfo\nMaxHotkeyBank ; start at 1 because 0 is the 'common' bank and is always active, so does not need to be selected
        sTmp = ReplaceString(sBank, "$1", Str(nBankIndex))
        addGadgetItemWithData(WQQ\cboSelHKBank, sTmp, nBankIndex)
      Next nBankIndex
      nMaxCboWidth = GadgetWidth(WQQ\cntSelHKBank) - GadgetX(WQQ\cboSelHKBank)
      setComboBoxWidth(WQQ\cboSelHKBank, 100, #False, nMaxCboWidth)
      SetGadgetState(WQQ\cboSelHKBank, nItem)
      setGadgetItemByData(WQQ\cboSelHKBank, \nSelHKBank)
    EndIf
    
    WQQ_fcActionReqd()
    
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF