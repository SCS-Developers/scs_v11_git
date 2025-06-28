; File: fmEditQU.pbi

EnableExplicit

Procedure WQU_setWindowTextForMTCType(nMTCType)
  PROCNAMEC()
  Static nLastMTCType = #SCS_MTC_TYPE_MTC
  Static sLastMTCType.s = "MTC"
  Protected sMTCType.s, sOldSubDescr.s, sNewSubDescr.s
  Protected n
  
  With WQU
    If nMTCType <> nLastMTCType
      ; nb although decodeMTCType() could be used for the following, do not do so because decodeMTCType() is intended for internal use (codes saved in the cue file)
      ; whereas we want to 'decode' values to text used in screen prompts and tooltips
      If nMTCType = #SCS_MTC_TYPE_LTC
        sMTCType = "LTC"
      Else
        sMTCType = "MTC"
      EndIf
      SGT(\lblMTCDuration, ReplaceString(Lang("WQU","lblMTCDuration"), "MTC", sMTCType))
      SGT(\lblMTCFrameRate, ReplaceString(Lang("WQU","lblMTCFrameRate"), "MTC", sMTCType))
      SGT(\lblMTCPreRoll, ReplaceString(Lang("WQU","lblMTCPreRoll"), "MTC", sMTCType))
      SGT(\lblMTCStartTime, ReplaceString(Lang("WQU","lblMTCStartTime"), "MTC", sMTCType))
      scsToolTip(\txtMTCDuration, ReplaceString(Lang("WQU","txtMTCDurationTT"), "MTC", sMTCType))
      scsToolTip(\txtMTCPreRoll, ReplaceString(Lang("WQU","txtMTCPreRollTT"), "MTC", sMTCType))
      For n = 0 To 3
        scsToolTip(\txtMTCStartPart[n], ReplaceString(Lang("WQU","txtMTCStartTimeTT"), "MTC", sMTCType))
      Next n
      ; note that the default sub-cue description contains MTC, but the user may have changed the default description so check the current content of this field
      sOldSubDescr = aSub(nEditSubPtr)\sSubDescr
      If FindString(sOldSubDescr, sLastMTCType)
        sNewSubDescr = ReplaceString(sOldSubDescr, sLastMTCType, sMTCType)
        SGT(\txtSubDescr, sNewSubDescr)
        SUB_setSubDescr(sNewSubDescr, \txtSubDescr, #False)
      EndIf
      
      nLastMTCType = nMTCType
      sLastMTCType = sMTCType
      
    EndIf
  EndWith
EndProcedure

Procedure WQU_fcMTCType()
  PROCNAMECS(nEditSubPtr)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      WQU_setWindowTextForMTCType(\nMTCType)
    EndWith
  EndIf
  
EndProcedure

Procedure WQU_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nListIndex
  Protected sMTCStartTime.s
  Protected n, nMTCDevNo, nLTCDevNo
  Static sLTCType.s, sMTCType.s, bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQUCreated = #False
    WQU_Form_Load()
  EndIf
  
  If bStaticLoaded = #False
    sMTCType = Lang("Common", "MTC")
    sLTCType = Lang("Common", "LTC")
    bStaticLoaded = #True
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQU\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "U", WQU)
    
    If IsGadget(WQU\cboMTCType)
      ClearGadgetItems(WQU\cboMTCType)
      nMTCDevNo = getMTCDevNo(@grProd)
      nLTCDevNo = getLTCDevNo(@grProd)
      If (nMTCDevNo >= 0) Or (nLTCDevNo < 0)
        ; include MTC if (a) there is an MTC device, or (b) there is neither an MTC or an LTC device
        addGadgetItemWithData(WQU\cboMTCType, sMTCType, #SCS_MTC_TYPE_MTC)
      EndIf
      If nLTCDevNo >= 0
        ; include LTC only if there is an LTC device
        addGadgetItemWithData(WQU\cboMTCType, sLTCType, #SCS_MTC_TYPE_LTC)
      EndIf
      setComboBoxWidth(WQU\cboMTCType)
      setComboBoxByData(WQU\cboMTCType, \nMTCType, 0)
      WQU_fcMTCType()
    EndIf
    sMTCStartTime = decodeMTCTime(\nMTCStartTime)
    For n = 0 To 3
      SGT(WQU\txtMTCStartPart[n], StringField(sMTCStartTime,n+1,":"))
    Next n
    nListIndex = indexForComboBoxData(WQU\cboMTCFrameRate, \nMTCFrameRate, 0)
    SGS(WQU\cboMTCFrameRate, nListIndex)
    SGT(WQU\txtMTCPreRoll, timeToStringT(\nMTCPreRoll))
    SGT(WQU\txtMTCDuration, timeToStringT(\nMTCDuration))
    
    \bSubCheckProgSlider = #False
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQU_cboMTCType_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nNewMTCType
  Protected sMsg.s
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    nNewMTCType = getCurrentItemData(WQU\cboMTCType)
    u = preChangeSubL(\nMTCType, GGT(WQU\lblMTCType), -5, #SCS_UNDO_ACTION_CHANGE)
    \nMTCType = nNewMTCType
    gnLastMTCType = \nMTCType
    WQU_fcMTCType()
    postChangeSubL(u, \nMTCType, -5)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQU_cboMTCFrameRate_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nNewMTCFrameRate
  Protected sMsg.s
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  ; See also valSub() for validation for of the MTC Start Time 'frame' (ff) against the selected frame rate
  
  With aSub(nEditSubPtr)
    nNewMTCFrameRate = getCurrentItemData(WQU\cboMTCFrameRate)
    If nNewMTCFrameRate = #SCS_MTC_FR_NOT_SET
      sMsg = LangPars("Errors", "MustBeEntered", GetGadgetText(WQU\lblMTCFrameRate))
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      ; reinstate previous setting
      If \nMTCFrameRate <> #SCS_MTC_FR_NOT_SET
        nListIndex = indexForComboBoxData(WQU\cboMTCFrameRate, \nMTCFrameRate, 0)
        SGS(WQU\cboMTCFrameRate, nListIndex)
      EndIf
      ProcedureReturn
    EndIf
    
    u = preChangeSubL(\nMTCFrameRate, GGT(WQU\lblMTCFrameRate), -5, #SCS_UNDO_ACTION_CHANGE)
    \nMTCFrameRate = nNewMTCFrameRate
    gnLastMTCFrameRate = \nMTCFrameRate
    postChangeSubL(u, \nMTCFrameRate, -5)
    
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQU_txtMTCStartPart_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sMTCStartTime.s
  Protected nMTCStartTime
  Protected n
  
  ; See also valSub() for validation for 'frame' (ff) against the selected frame rate
  
  With aSub(nEditSubPtr)
    sMTCStartTime = Trim(GGT(WQU\txtMTCStartPart[0])) + ":"
    sMTCStartTime + Trim(GGT(WQU\txtMTCStartPart[1])) + ":"
    sMTCStartTime + Trim(GGT(WQU\txtMTCStartPart[2])) + ":"
    sMTCStartTime + Trim(GGT(WQU\txtMTCStartPart[3]))
    debugMsg(sProcName, "sMTCStartTime=" + sMTCStartTime)
    If validateMTCField(sMTCStartTime, GGT(WQU\lblMTCStartTime)) = #False
      ProcedureReturn #False
    ElseIf sMTCStartTime <> gsTmpString
      For n = 0 To 3
        If GGT(WQU\txtMTCStartPart[n]) <> StringField(gsTmpString,n+1,":")
          SGT(WQU\txtMTCStartPart[n], StringField(gsTmpString,n+1,":"))
        EndIf
      Next n
    EndIf
    u = preChangeSubL(\nMTCStartTime, GGT(WQU\lblMTCStartTime))
    \nMTCStartTime = encodeMTCTime(sMTCStartTime)
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubL(u, \nMTCStartTime)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  ProcedureReturn #True
EndProcedure

Procedure WQU_txtMTCPreRoll_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeFieldT(GGT(WQU\txtMTCPreRoll), GGT(WQU\lblMTCPreRoll), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WQU\txtMTCPreRoll) <> gsTmpString
    SGT(WQU\txtMTCPreRoll, gsTmpString)
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nMTCPreRoll, GGT(WQU\lblMTCPreRoll), -5, #SCS_UNDO_ACTION_CHANGE)
    \nMTCPreRoll = stringToTime(GGT(WQU\txtMTCPreRoll))
    gnLastMTCPreRoll = \nMTCPreRoll
    postChangeSubL(u, \nMTCPreRoll, -5)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQU_txtMTCDuration_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeFieldT(GGT(WQU\txtMTCDuration), GGT(WQU\lblMTCDuration), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WQU\txtMTCDuration) <> gsTmpString
    SGT(WQU\txtMTCDuration, gsTmpString)
  EndIf
  
  With aSub(nEditSubPtr)
    debugMsg(sProcName, "(preChange) \nMTCDuration=" + \nMTCDuration)
    u = preChangeSubL(\nMTCDuration, GGT(WQU\lblMTCDuration), -5, #SCS_UNDO_ACTION_CHANGE)
    \nMTCDuration = stringToTime(GGT(WQU\txtMTCDuration))
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    debugMsg(sProcName, "(postChange) \nMTCDuration=" + \nMTCDuration)
    postChangeSubL(u, \nMTCDuration, -5)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQU_drawForm()
  PROCNAMEC()

  colorEditorComponent(#WQU)

EndProcedure

Procedure WQU_Form_Load()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQU()
  SUB_loadOrResizeHeaderFields("U", #True)

  With WQU
    ClearGadgetItems(\cboMTCFrameRate)
    For n = 0 To #SCS_MTC_LAST
      addGadgetItemWithData(\cboMTCFrameRate, decodeMTCFrameRateL(n), n)
    Next n
  EndWith
  
  WQU_drawForm()

EndProcedure

Procedure WQU_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQU_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQU_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQU
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQU)
        
        ; detail gadgets
      Case \txtMTCDuration
        ETVAL2(WQU_txtMTCDuration_Validate())
        
      Case \txtMTCPreRoll
        ETVAL2(WQU_txtMTCPreRoll_Validate())
        
      Case \txtMTCStartPart[0]
        ETVAL2(WQU_txtMTCStartPart_Validate())
        
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

Procedure WQU_EventHandler()
  PROCNAMEC()
  
  With WQU
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQU)
            
            ; detail gadgets in alphabetical order
            
          Case \cboMTCFrameRate ; cboMTCFrameRate
            CBOCHG(WQU_cboMTCFrameRate_Click())
            
          Case \cboMTCType ; cboMTCType
            CBOCHG(WQU_cboMTCType_Click())
            
          Case \cntMTCStartTime
            ; No action
            
          Case \cntSubDetailU
            ; No action
            
          Case \scaMTCCue
            ; No action
            
          Case \txtMTCDuration   ; txtMTCDuration
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQU_txtMTCDuration_Validate())
            EndIf
            
          Case \txtMTCPreRoll   ; txtMTCPreRoll
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQU_txtMTCPreRoll_Validate())
            EndIf
            
          Case \txtMTCStartPart[0]  ; txtMTCStartPart
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
              ETVAL(WQU_txtMTCStartPart_Validate())
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQU_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQU
    If IsGadget(\scaMTCCue)
      ; \scaMTCCue automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaMTCCue) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaMTCCue, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailU
      nHeight = nInnerHeight - GadgetY(\cntSubDetailU)
      ResizeGadget(\cntSubDetailU, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
      ; ; adjust the height of \cntAudioControls
      ; nHeight = GadgetHeight(\cntSubDetailU) - GadgetY(\cntAudioControls) - GadgetHeight(\cntTest) - 5
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
