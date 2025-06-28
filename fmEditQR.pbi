; File: fmEditQR.pbi

EnableExplicit

Procedure WQR_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQRCreated = #False
    WQR_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQR\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "R", WQR)
    
    SGT(WQR\txtFileName, encodeFileName(\sRPFileName, #False, grProd\bTemplate))
    SGT(WQR\txtParams, encodeFileName(\sRPParams, #False, grProd\bTemplate))
    SGT(WQR\txtStartFolder, encodeFileName(\sRPStartFolder, #False, grProd\bTemplate))
    setOwnState(WQR\chkHideSCS, \bRPHideSCS)
    setOwnState(WQR\chkInvisible, \bRPInvisible)
    
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQR_chkHideSCS_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bRPHideSCS, getOwnText(WQR\chkHideSCS), -5, #SCS_UNDO_ACTION_CHANGE)
    \bRPHideSCS = getOwnState(WQR\chkHideSCS)
    postChangeSubL(u, \bRPHideSCS, -5)
    grEditMem\bLastRPHideSCS = \bRPHideSCS
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQR_chkInvisible_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bRPInvisible, getOwnText(WQR\chkInvisible), -5, #SCS_UNDO_ACTION_CHANGE)
    \bRPInvisible = getOwnState(WQR\chkInvisible)
    postChangeSubL(u, \bRPInvisible, -5)
    grEditMem\bLastRPInvisible = \bRPInvisible
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQR_btnBrowse_Click(Index)
  PROCNAMEC()
  Protected sMyFile.s, sPattern.s
  Protected sMyPath.s, sInitialPath.s
  Protected sTitle.s, sDisplayValue.s
  ; nb this procedure does not directly update aSub() but uses the WQR\txt... validation routines
  ; this enables the user to clear the StartFolder if required (by clearing the txtStartFolder field)
  ; and also displays and maintains 'stored' fields
  
  debugMsg(sProcName, "gsCueFolder=" + gsCueFolder)
  With aSub(nEditSubPtr)
    Select Index
      Case 0    ; filename
        sTitle = GGT(WQR\lblFileName)
        sPattern = Lang("Requesters", "AllFiles") + " (*.*)|*.*"
        sMyFile = OpenFileRequester(sTitle, "", sPattern, 0)
        If Len(sMyFile) > 0
          sDisplayValue = encodeFileName(sMyFile, #False, grProd\bTemplate)
          SGT(WQR\txtFileName, sDisplayValue)
          scsToolTip(WQR\txtFileName, sDisplayValue)
          WQR_txtFileName_Validate()
          debugMsg(sProcName, "FileName=" + sDisplayValue)
        EndIf
        
      Case 1    ; starting folder
        sTitle = GGT(WQR\lblStartFolder)
        sInitialPath = grGeneralOptions\sInitDir
        If Len(sInitialPath) = 0
          sInitialPath = "C:\"
        EndIf
        sMyPath = PathRequester(sTitle, sInitialPath)
        If Len(sMyPath) > 0
          sDisplayValue = encodeFileName(sMyPath, #False, grProd\bTemplate)
          SGT(WQR\txtStartFolder, sDisplayValue)
          scsToolTip(WQR\txtStartFolder, sDisplayValue)
          WQR_txtStartFolder_Validate()
        EndIf
        debugMsg(sProcName, "StartFolder=" + sDisplayValue)
        
    EndSelect
  EndWith
EndProcedure

Procedure WQR_txtFileName_Validate()
  PROCNAMEC()
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\sRPFileName, GGT(WQR\lblFileName))
    \sRPFileName = decodeFileName(Trim(GGT(WQR\txtFileName)))
    SGT(WQR\txtFileName, encodeFileName(\sRPFileName, #False, grProd\bTemplate))
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubs(u, \sRPFileName)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  ProcedureReturn #True
EndProcedure

Procedure WQR_txtParams_Validate()
  PROCNAMEC()
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\sRPParams, GGT(WQR\lblParams))
    \sRPParams = decodeFileName(Trim(GGT(WQR\txtParams)), #True, #False)  ; do not convert / to \ for program parameters
    SGT(WQR\txtParams, encodeFileName(\sRPParams, #False, grProd\bTemplate))
    postChangeSubs(u, \sRPParams)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  ProcedureReturn #True
EndProcedure

Procedure WQR_txtStartFolder_Validate()
  PROCNAMEC()
  Protected u
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\sRPStartFolder, GGT(WQR\lblStartFolder))
    \sRPStartFolder = decodeFileName(Trim(GGT(WQR\txtStartFolder)))
    SGT(WQR\txtStartFolder, encodeFileName(\sRPStartFolder, #False, grProd\bTemplate))
    postChangeSubs(u, \sRPStartFolder)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WQR_drawForm()
  colorEditorComponent(#WQR)
EndProcedure

Procedure WQR_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQR()
  SUB_loadOrResizeHeaderFields("R", #True)
  
  WQR_drawForm()

EndProcedure

Procedure WQR_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQR_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQR_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQR
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQR)
        
        ; detail gadgets
      Case \txtFileName
        ETVAL2(WQR_txtFileName_Validate())
        
      Case \txtParams
        ETVAL2(WQR_txtParams_Validate())
        
      Case \txtStartFolder
        ETVAL2(WQR_txtStartFolder_Validate())
        
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

Procedure WQR_EventHandler()
  PROCNAMEC()
  
  With WQR
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQR)
            
            ; detail gadgets in alphabetical order
            
          Case \btnBrowse[0]  ; btnBrowse
            BTNCLICK(WQR_btnBrowse_Click(gnEventGadgetArrayIndex))
            
          Case \chkHideSCS  ; chkHideSCS
            CHKOWNCHG(WQR_chkHideSCS_Click())
            
          Case \chkInvisible  ; chkInvisible
            CHKOWNCHG(WQR_chkInvisible_Click())
            
          Case \txtFileName ; txtFileName
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQR_txtFileName_Validate())
            EndIf
            
          Case \txtParams ; txtParams
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQR_txtParams_Validate())
            EndIf
            
          Case \txtStartFolder ; txtStartFolder
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQR_txtStartFolder_Validate())
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQR_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQR
    If IsGadget(\scaRunProg)
      ; \scaRunProg automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaRunProg) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaRunProg, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailR
      nHeight = nInnerHeight - GadgetY(\cntSubDetailR)
      ResizeGadget(\cntSubDetailR, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; ; adjust the height of \cntAudioControls
      ; nHeight = GadgetHeight(\cntSubDetailR) - GadgetY(\cntAudioControls) - GadgetHeight(\cntTest) - 5
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

; EOF
