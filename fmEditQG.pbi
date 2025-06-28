; File: fmEditQG.pbi

EnableExplicit

Procedure WQG_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected i, m, nItem, nListIndex
  Protected sTmp.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQGCreated = #False
    WQG_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQG\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "G", WQG)
    ClearGadgetItems(WQG\cboCueToGoTo)
    AddGadgetItem(WQG\cboCueToGoTo, -1, #SCS_BLANK_CBO_ENTRY)
    nListIndex = 0
    nItem = 0
    For i = 1 To gnLastCue
      If i <> nEditCuePtr
        sTmp = buildCueForCBO(i)
        AddGadgetItem(WQG\cboCueToGoTo, -1, sTmp)
        nListIndex + 1
        If aCue(i)\sCue = \sCueToGoTo
          nItem = nListIndex
        EndIf
      EndIf
    Next i
    SetGadgetState(WQG\cboCueToGoTo, nItem)
    If \bGoToCueButDoNotStartIt
      setOwnState(WQG\optStartOption[0], #False)
      setOwnState(WQG\optStartOption[1], #True)
    Else
      setOwnState(WQG\optStartOption[1], #False)
      setOwnState(WQG\optStartOption[0], #True)
    EndIf
    
    gbCallEditUpdateDisplay = #True
    
  EndWith

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQG_cboCueToGoTo_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, i, sListString.s
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\sCueToGoTo, GGT(WQG\lblCueToGoTo), -5, #SCS_UNDO_ACTION_CHANGE)
    
    \sCueToGoTo = grSubDef\sCueToGoTo
    sListString = GGT(WQG\cboCueToGoTo)
    For i = 1 To gnLastCue
      If sListString = buildCueForCBO(i)
        \sCueToGoTo = aCue(i)\sCue
        Break
      EndIf
    Next i
    debugMsg(sProcName, "\sCueToGoTo=" + \sCueToGoTo)
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubS(u, \sCueToGoTo, -5)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQG_drawForm()
  colorEditorComponent(#WQG)
EndProcedure

Procedure WQG_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQG()
  SUB_loadOrResizeHeaderFields("G", #True)
  
  WQG_drawForm()

EndProcedure

Procedure WQG_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQG_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQG_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQG
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQG)
        
        ; detail gadgets
        
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

Procedure WQG_EventHandler()
  PROCNAMEC()
  
  With WQG
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQG)
            
            ; detail gadgets in alphabetical order
            
          Case \cboCueToGoTo ; cboCueToGoTo
            CBOCHG(WQG_cboCueToGoTo_Click())
            
          Case \optStartOption[0]
            WQG_optStartOption_Click(gnEventGadgetArrayIndex)
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQG_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQG
    If IsGadget(\scaGoTo)
      ; \scaGoTo automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaGoTo) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaGoTo, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailG
      nHeight = nInnerHeight - GadgetY(\cntSubDetailG)
      ResizeGadget(\cntSubDetailG, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
    EndIf
  EndWith
EndProcedure

Procedure WQG_optStartOption_Click(nIndex)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected bNewGoToCueButDoNotStartIt
  Protected sNewDefaultDescr.s
  
  With aSub(nEditSubPtr)
    If nIndex = 1
      bNewGoToCueButDoNotStartIt = #True
    EndIf
    If bNewGoToCueButDoNotStartIt <> \bGoToCueButDoNotStartIt
      u = preChangeSubL(\bGoToCueButDoNotStartIt, getOwnText(WQG\optStartOption[nIndex]))
      \bGoToCueButDoNotStartIt = bNewGoToCueButDoNotStartIt
      setDefaultSubDescr()
      setDefaultCueDescr()
      postChangeSubL(u, \bGoToCueButDoNotStartIt)
    EndIf
  EndWith
  
EndProcedure

; EOF