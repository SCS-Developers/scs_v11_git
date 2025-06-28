; File: fmEditQJ.pbi

EnableExplicit

Procedure WQJ_displaySub(pSubPtr)  ; subtype J = 'enable/disable cues'
  PROCNAMECS(pSubPtr)
  Protected i, n, nListIndex
  Protected nCuePtr
  Protected sTmp.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQJCreated = #False
    WQJ_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQJ\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "J", WQJ)
    
    For n = 0 To #SCS_MAX_ENABLE_DISABLE
      ClearGadgetItems(WQJ\cboFirstCue[n])
      addGadgetItemWithData(WQJ\cboFirstCue[n], "", -1)
      ClearGadgetItems(WQJ\cboLastCue[n])
      addGadgetItemWithData(WQJ\cboLastCue[n], "", -1)
    Next n
    
    For i = 1 To gnLastCue
      If i <> \nCueIndex
;         If (aCue(i)\bSubTypeJ) ; Commented out 22Jan2024 11.10.1. Not sure why this test was in place.
;           ; ignore
;         Else
          sTmp = buildCueForCBO(i)
          debugMsg(sProcName, "sTmp=" + sTmp + ", aCue(" + getCueLabel(i) + ")\nCueId=" + aCue(i)\nCueId)
          For n = 0 To #SCS_MAX_ENABLE_DISABLE
            addGadgetItemWithData(WQJ\cboFirstCue[n], sTmp, aCue(i)\nCueId)
            addGadgetItemWithData(WQJ\cboLastCue[n], sTmp, aCue(i)\nCueId)
          Next n
;         EndIf
      EndIf
    Next i
    
    For n = 0 To #SCS_MAX_ENABLE_DISABLE
      debugMsg(sProcName, "\aEnableDisable[" + n + "]\sFirstCue=" + \aEnableDisable[n]\sFirstCue)
      If \aEnableDisable[n]\sFirstCue
        nCuePtr = getCuePtr(\aEnableDisable[n]\sFirstCue)
        debugMsg(sProcName, "nCuePtr=" + nCuePtr)
        If nCuePtr >= 0
          nListIndex = indexForComboBoxData(WQJ\cboFirstCue[n], aCue(nCuePtr)\nCueId)
          SGS(WQJ\cboFirstCue[n], nListIndex)
          If \aEnableDisable[n]\sLastCue
            nCuePtr = getCuePtr(\aEnableDisable[n]\sLastCue)
            If nCuePtr >= 0
              nListIndex = indexForComboBoxData(WQJ\cboLastCue[n], aCue(nCuePtr)\nCueId)
              SGS(WQJ\cboLastCue[n], nListIndex)
            EndIf
          EndIf
        EndIf
      EndIf
      Select \aEnableDisable[n]\nAction
        Case #SCS_ENADIS_DISABLE
          setOwnState(WQJ\optDisable[n], #True)
          setOwnState(WQJ\optEnable[n], #False)
        Default
          setOwnState(WQJ\optEnable[n], #True)
          setOwnState(WQJ\optDisable[n], #False)
      EndSelect
    Next n
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQJ_cboFirstCue_Click(Index)
  PROCNAMECS(nEditSubPtr)
  ; Modified 22Jan2024 11.10.1 as follows:
  ; When selecting the 'first cue in range' for a new entry (ie where this field is currently blank), and if this is not the very first entry in the list,
  ; then set the 'enable' / 'disable' option buttons the same as those of the previous entry.
  ; This can obviously be changed by the user.
  Protected u, i, sListString.s
  Protected nDefaultAction, bDefaultActionSet
  Static sUndoDescr.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sUndoDescr = Lang("WQJ","lblFirstCue")
    ; sUndoDescr is set in a smiliar manner to WQJ_cboLastCue_Click() even though the 'first' cue label doesn't contain '(optional)'
    bStaticLoaded = #True
  EndIf
  
  If Index <= #SCS_MAX_ENABLE_DISABLE
    With aSub(nEditSubPtr)\aEnableDisable[Index]
      If index > 0 And Len(Trim(\sFirstCue)) = 0
        nDefaultAction = aSub(nEditSubPtr)\aEnableDisable[Index-1]\nAction ; use the 'action' of the previous entry as the default 'action' for this new entry
        bDefaultActionSet = #True
      EndIf
      u = preChangeSubS(\sFirstCue, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \sFirstCue = grEnableDisableDef\sFirstCue
      sListString = GGT(WQJ\cboFirstCue[Index])
      For i = 1 To gnLastCue
        If sListString = buildCueForCBO(i)
          \sFirstCue = aCue(i)\sCue
          Break
        EndIf
      Next i
      ; debugMsg(sProcName, "\sFirstCue=" + \sFirstCue + ", bDefaultActionSet=" + strB(bDefaultActionSet))
      If bDefaultActionSet
        \nAction = nDefaultAction
        Select \nAction
          Case #SCS_ENADIS_DISABLE
            setOwnState(WQJ\optDisable[Index], #True)
            setOwnState(WQJ\optEnable[Index], #False)
          Default
            setOwnState(WQJ\optEnable[Index], #True)
            setOwnState(WQJ\optDisable[Index], #False)
        EndSelect
      EndIf
      setDefaultSubDescr()
      setDefaultCueDescr()
      postChangeSubS(u, \sFirstCue, -5, Index)
    EndWith
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  EndIf
EndProcedure

Procedure WQJ_cboLastCue_Click(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u, i, sListString.s
  Static sUndoDescr.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sUndoDescr = Lang("WQJ","lblLastCue")
    ; sUndoDescr is set to the base part of the label, not the displayed label as that contains '(optional)' which we don't want in the undo description
    bStaticLoaded = #True
  EndIf
  
  If Index <= #SCS_MAX_ENABLE_DISABLE
    With aSub(nEditSubPtr)\aEnableDisable[Index]
      u = preChangeSubS(\sLastCue, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \sLastCue = grEnableDisableDef\sLastCue
      sListString = GGT(WQJ\cboLastCue[Index])
      For i = 1 To gnLastCue
        If sListString = buildCueForCBO(i)
          \sLastCue = aCue(i)\sCue
          Break
        EndIf
      Next i
      debugMsg(sProcName, "\sLastCue=" + \sLastCue)
      setDefaultSubDescr()
      setDefaultCueDescr()
      postChangeSubS(u, \sLastCue, -5, Index)
    EndWith
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  EndIf
EndProcedure

Procedure WQJ_optEnableDisable_Click(Index, bEnable)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nReqdAction
  Protected sUndoDescr.s
  
  If bEnable
    nReqdAction = #SCS_ENADIS_ENABLE
    sUndoDescr = getOwnText(WQJ\optEnable[Index])
  Else
    nReqdAction = #SCS_ENADIS_DISABLE
    sUndoDescr = getOwnText(WQJ\optDisable[Index])
  EndIf
  
  With aSub(nEditSubPtr)\aEnableDisable[Index]
    If \nAction <> nReqdAction
      u = preChangeSubL(\nAction, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, Index)
      \nAction = nReqdAction
      setDefaultSubDescr()
      setDefaultCueDescr()
      postChangeSubL(u, \nAction, -5, Index)
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
    EndIf
  EndWith
  
EndProcedure

Procedure WQJ_drawForm()
  PROCNAMEC()

  colorEditorComponent(#WQJ)

EndProcedure

Procedure WQJ_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQJ()
  SUB_loadOrResizeHeaderFields("J", #True)
  
  WQJ_drawForm()

EndProcedure

Procedure WQJ_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQJ_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQJ_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQJ
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQJ)
        
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

Procedure WQJ_EventHandler()
  PROCNAMEC()
  
  With WQJ
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQJ)
            
            ; detail gadgets in alphabetical order
            
          Case \cboFirstCue[0] ; cboFirstCue
            CBOCHG(WQJ_cboFirstCue_Click(gnEventGadgetArrayIndex))
            
          Case \cboLastCue[0] ; cboLastCue
            CBOCHG(WQJ_cboLastCue_Click(gnEventGadgetArrayIndex))
            
          Case \optDisable[0]  ; optDisable
            WQJ_optEnableDisable_Click(gnEventGadgetArrayIndex, #False)
            
          Case \optEnable[0]  ; optEnable
            WQJ_optEnableDisable_Click(gnEventGadgetArrayIndex, #True)
            
          Default
            ; debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQJ_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQJ
    If IsGadget(\scaEnableDisable)
      ; \scaGoTo automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaEnableDisable) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaEnableDisable, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailG
      nHeight = nInnerHeight - GadgetY(\cntSubDetailJ)
      ResizeGadget(\cntSubDetailJ, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; ; adjust the height of \cntAudioControls
      ; nHeight = GadgetHeight(\cntSubDetailG) - GadgetY(\cntAudioControls) - GadgetHeight(\cntTest) - 5
      ; ResizeGadget(\cntAudioControls,#PB_Ignore,#PB_Ignore,#PB_Ignore,nHeight)
      ; 
      ; ; adjust the height of \scaDevs
      ; nHeight = GadgetHeight(\cntAudioControls) - GadgetY(\scaDevs)
      ; ResizeGadget(\scaDevs,#PB_Ignore,#PB_Ignore,#PB_Ignore,nHeight)
      ; 
      ; ; adjust the top position of the controls below \cntAudioControls
      ; nTop = GadgetY(\cntAudioControls) + GadgetHeight(\cntAudioControls) + 5
      ; ResizeGadget(\cntTest,#PB_Ignore,nTop,#PB_Ignore,#PB_Ignore)
      
    EndIf
  EndWith
EndProcedure

Procedure.s WQJ_buildEnableDisableDesc(pSubPtr)
  PROCNAMECS(pSubPtr)
  ; nb also used for info field
  Protected sDescr.s
  Protected sRange.s
  Protected n
  Protected i
  Protected nPrevAction = -1
  Static sDescrEnable.s, sDescrDisable.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sDescrEnable = Lang("Common", "Enable") + " "
    sDescrDisable = Lang("Common", "Disable") + " "
    bStaticLoaded = #True
  EndIf
  
  For n = 0 To #SCS_MAX_ENABLE_DISABLE
    With aSub(pSubPtr)\aEnableDisable[n]
      If \sFirstCue
        i = getCuePtr(\sFirstCue)
        If i >= 0
          sRange = aCue(i)\sCue
          If \sLastCue
            i = getCuePtr(\sLastCue)
            If i >= 0
              sRange + " - " + aCue(i)\sCue
            EndIf
          EndIf
          If sDescr
            sDescr + ", "
          EndIf
          If \nAction <> nPrevAction
            Select \nAction
              Case #SCS_ENADIS_ENABLE
                sDescr + sDescrEnable
              Case #SCS_ENADIS_DISABLE
                sDescr + sDescrDisable
            EndSelect
            nPrevAction = \nAction
          EndIf
          sDescr + sRange
        EndIf
      EndIf
    EndWith
  Next n
  ProcedureReturn sDescr
    
EndProcedure

; EOF
