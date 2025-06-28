; File: fmEditQT.pbi (Set Position cue)

EnableExplicit

Procedure WQT_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected i, j, nItem, nListIndex, nData
  Protected sTmp.s
  Protected nCountAudioCues, nCountVideoCues, nMaxWidthForCbo ; Added 7Jun2022 11.9.2
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQTCreated = #False
    WQT_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQT\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "T", WQT)
    
    ClearGadgetItems(WQT\cboSetPosCue)
    addGadgetItemWithData(WQT\cboSetPosCue, #SCS_BLANK_CBO_ENTRY, -1) ; Changed 7Jun2022 11.9.2
;     nListIndex = 0
;     nItem = 0
    nData = -1
    For i = 1 To gnLastCue
      If i <> nEditCuePtr
        ; only cues containing a SubTypeF, or a SubTypeA with only one video/image, are available for 'set position'
        If aCue(i)\bSubTypeF
          sTmp = buildCueForCBO(i)
          addGadgetItemWithData(WQT\cboSetPosCue, sTmp, aCue(i)\nCueId) ; Changed 7Jun2022 11.9.2
          If \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA And aCue(i)\sCue = \sSetPosCue
            nData = aCue(i)\nCueId
          EndIf
;           nListIndex + 1
;           If aCue(i)\sCue = \sSetPosCue
;             nItem = nListIndex
;           EndIf
          nCountAudioCues + 1 ; Added 7Jun2022 11.9.2
          
        ElseIf aCue(i)\bSubTypeA
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeA
              If aSub(j)\nAudCount = 1
                sTmp = buildCueForCBO(i)
                addGadgetItemWithData(WQT\cboSetPosCue, sTmp, aCue(i)\nCueId) ; Changed 7Jun2022 11.9.2
                If \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA And aCue(i)\sCue = \sSetPosCue
                  nData = aCue(i)\nCueId
                EndIf
;                 nListIndex + 1
;                 If aCue(i)\sCue = \sSetPosCue
;                   nItem = nListIndex
;                 EndIf
                nCountVideoCues + 1 ; Added 7Jun2022 11.9.2
                Break
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      EndIf
    Next i
    ; Added 7Jun2022 11.9.2
    ; NB using "WQS" text as these descriptions already exist for SFR cues
    If nCountAudioCues > 0
      addGadgetItemWithData(WQT\cboSetPosCue, Lang("WQS", "cuePlayAud"), #SCS_SETPOS_CUETYPE_PLAY_AUDIO)
      If \nSetPosCueType = #SCS_SETPOS_CUETYPE_PLAY_AUDIO
        nData = #SCS_SETPOS_CUETYPE_PLAY_AUDIO
      EndIf
    EndIf
    If nCountVideoCues > 0
      addGadgetItemWithData(WQT\cboSetPosCue, Lang("WQS", "cuePlayVid"), #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE)
      If \nSetPosCueType = #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE
        nData = #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE
      EndIf
    EndIf
    nMaxWidthForCbo = GadgetWidth(WQT\cntSubDetailT) - GadgetX(WQT\cboSetPosCue) - 30
    setComboBoxWidth(WQT\cboSetPosCue, -1, #False, nMaxWidthForCbo)
    ; End added 7Jun2022 11.9.2
    
    ; SetGadgetState(WQT\cboSetPosCue, nItem)
    setGadgetItemByData(WQT\cboSetPosCue, nData, 0) ; Changed 7Jun2022 11.9.2
    
    setGadgetItemByData(WQT\cboPosType, \nSetPosAbsRel, 0)
    
    WQT_fcAbsRel()
    
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQT_cboSetPosCue_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, i, nData
  Protected sSetPosCueOrig.s, nSetPosCueTypeOrig, sOrig.s
  Protected sSetPosCueNew.s, nSetPosCueTypeNew, sNew.s
  
  With aSub(nEditSubPtr)
    ; keep the original values to detect a change
    If \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA
      sSetPosCueOrig = \sSetPosCue
    Else
      nSetPosCueTypeOrig = \nSetPosCueType
    EndIf
    sOrig = decodeSetPosSetPosCueType(nSetPosCueTypeOrig) + "." + sSetPosCueOrig
    
    u = preChangeSubS(sOrig, GGT(WQT\lblSetPosCue), -5, #SCS_UNDO_ACTION_CHANGE)
    nData = getCurrentItemData(WQT\cboSetPosCue)
    Select nData
      Case #SCS_SETPOS_CUETYPE_PLAY_AUDIO, #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE
        \nSetPosCueType = nData
        \sSetPosCue = ""
      Default
        \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA
        For i = 1 To gnLastCue
          If aCue(i)\nCueId = nData
            \sSetPosCue = aCue(i)\sCue
            Break
          EndIf
        Next i
    EndSelect
    ; debugMsg(sProcName, "\sSetPosCue=" + \sSetPosCue)
    setDefaultSubDescr()
    setDefaultCueDescr()
    If \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA
      sSetPosCueNew = \sSetPosCue
    Else
      nSetPosCueTypeNew = \nSetPosCueType
    EndIf
    sNew = decodeSetPosSetPosCueType(nSetPosCueTypeNew) + "." + sSetPosCueNew
    postChangeSubS(u, sNew, -5)
    
    If sNew <> sOrig
      ; User has changed the cue. Clear Cue Markers and re-populate
      WQT_fcAbsRel()
    EndIf  
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQT_cboSetPosCueMarker_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, i, sListString.s, n
  
  With aSub(nEditSubPtr)
    u = preChangeSubS(\sSetPosCueMarker, GGT(WQT\lblSetPosCueMarker), -5, #SCS_UNDO_ACTION_CHANGE)
    n = getCurrentItemData(WQT\cboSetPosCueMarker)
    \sSetPosCue = gaCueMarkerInfo(n)\sHostCue
    \nSetPosCueMarkerSubNo = gaCueMarkerInfo(n)\nHostSubNo
    \sSetPosCueMarker = gaCueMarkerInfo(n)\sCueMarkerName
    debugMsg(sProcName, "\sSetPosCueMarker=" + \sSetPosCueMarker)
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubS(u, \sSetPosCueMarker, -5)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQT_cboPosType_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nSetPosAbsRel, GGT(WQT\lblPosType))
    \nSetPosAbsRel = getCurrentItemData(WQT\cboPosType, #SCS_SETPOS_ABSOLUTE)
    WQT_fcAbsRel()
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubL(u, \nSetPosAbsRel)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
EndProcedure

Procedure WQT_txtSetPosTime_Validate()
  PROCNAMEC()
  Protected u
  Protected nSetPosTime, bRelative
  
  With aSub(nEditSubPtr)
    If \nSetPosAbsRel = #SCS_SETPOS_RELATIVE
      bRelative = #True
    EndIf
    ; If validateTimeFieldT(GGT(WQT\txtSetPosTime), GGT(WQT\lblSetPosTime), #False, #False, \nSetPosTime, #False, bRelative) = #False
    ; 2Nov2018 11.8.0an changed bZeroOK parameter from #False to #True to enable absolute position 0
    If validateTimeFieldT(GGT(WQT\txtSetPosTime), GGT(WQT\lblSetPosTime), #False, #False, \nSetPosTime, #True, bRelative) = #False
      ProcedureReturn #False
    ElseIf GGT(WQT\txtSetPosTime) <> gsTmpString
      SGT(WQT\txtSetPosTime, gsTmpString)
    EndIf
    u = preChangeSubL(\nSetPosTime, GGT(WQT\lblSetPosTime))
    If bRelative
      \nSetPosTime = stringToRelativeTime(GGT(WQT\txtSetPosTime))
    Else
      \nSetPosTime = stringToTime(GGT(WQT\txtSetPosTime))
    EndIf
    setDefaultSubDescr()
    setDefaultCueDescr()
    postChangeSubL(u, \nSetPosTime)
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  ProcedureReturn #True
EndProcedure

Procedure WQT_drawForm()

  colorEditorComponent(#WQT)

EndProcedure

Procedure WQT_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQT()
  SUB_loadOrResizeHeaderFields("T", #True)
  
  ClearGadgetItems(WQT\cboPosType)
  addGadgetItemWithData(WQT\cboPosType, Lang("Common", "Absolute"), #SCS_SETPOS_ABSOLUTE)
  addGadgetItemWithData(WQT\cboPosType, Lang("Common", "Relative"), #SCS_SETPOS_RELATIVE)
  addGadgetItemWithData(WQT\cboPosType, Lang("Common", "BeforeEnd"), #SCS_SETPOS_BEFORE_END) ; Added 7Jun2022 11.9.2
  addGadgetItemWithData(WQT\cboPosType, Lang("Common", "CueMarker"), #SCS_SETPOS_CUE_MARKER)
  setComboBoxWidth(WQT\cboPosType)
  
  WQT_drawForm()

EndProcedure

Procedure WQT_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQT_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQT_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQT
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQT)
        
        ; detail gadgets
      Case \txtSetPosTime
        ETVAL2(WQT_txtSetPosTime_Validate())
        
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

Procedure WQT_EventHandler()
  PROCNAMEC()
  
  With WQT
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQT)
            
            ; detail gadgets in alphabetical order
            
          Case \cboPosType ; cboPosType
            CBOCHG(WQT_cboPosType_Click())
            
          Case \cboSetPosCue ; cboSetPosCue
            CBOCHG(WQT_cboSetPosCue_Click())
            
          Case \cboSetPosCueMarker ; cboSetPosCueMarker
            CBOCHG(WQT_cboSetPosCueMarker_Click())
            
          Case \txtSetPosTime ; txtSetPosTime
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WQT_txtSetPosTime_Validate())
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQT_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQT
    If IsGadget(\scaSetPos)
      ; \scaSetPos automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaSetPos) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaSetPos, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailT
      nHeight = nInnerHeight - GadgetY(\cntSubDetailT)
      ResizeGadget(\cntSubDetailT, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
    EndIf
  EndWith
EndProcedure

Procedure WQT_fcAbsRel()
  PROCNAMECS(nEditSubPtr)
  Protected bCueMarkerVisible, bTimeVisible
  Protected nSetPosCuePtr, n, nListData
  
  With aSub(nEditSubPtr)
    Select \nSetPosAbsRel
      Case #SCS_SETPOS_CUE_MARKER
        bCueMarkerVisible = #True
        nListData = -1
        ClearGadgetItems(WQT\cboSetPosCueMarker)
        If \sSetPosCue
          nSetPosCuePtr = getCuePtr(\sSetPosCue)
          If nSetPosCuePtr >= 0
            For n = 0 To gnMaxCueMarkerInfo
              If gaCueMarkerInfo(n)\nHostCuePtr = nSetPosCuePtr
                addGadgetItemWithData(WQT\cboSetPosCueMarker, gaCueMarkerInfo(n)\sCueMarkerDisplayInfo, n)
                If \sSetPosCueMarker = gaCueMarkerInfo(n)\sCueMarkerName 
                  If \nSetPosCueMarkerSubNo = gaCueMarkerInfo(n)\nHostSubNo Or \nSetPosCueMarkerSubNo = 0 
                    debugMsg(sProcName, "Found CueMarker at " + n)
                    nListData = n
                  EndIf
                EndIf
              EndIf
            Next n
            setComboBoxWidth(WQT\cboSetPosCueMarker, 40) ; Changed nMinWidth 7Jun2022 11.9.2
          EndIf
        EndIf
        If nListData = -1
          \sSetPosCueMarker = grSubDef\sSetPosCueMarker
          \nSetPosCueMarkerSubNo = grSubDef\nSetPosCueMarkerSubNo
        EndIf
        setComboBoxByData(WQT\cboSetPosCueMarker, nListData)
      Default
        \sSetPosCueMarker = grSubDef\sSetPosCueMarker
        \nSetPosCueMarkerSubNo = grSubDef\nSetPosCueMarkerSubNo
        bTimeVisible = #True
        SGT(WQT\txtSetPosTime, timeToStringT(\nSetPosTime))
    EndSelect
    setVisible(WQT\lblSetPosTime, bTimeVisible)
    setVisible(WQT\txtSetPosTime, bTimeVisible)
    setVisible(WQT\lblSetPosCueMarker, bCueMarkerVisible)
    setVisible(WQT\cboSetPosCueMarker, bCueMarkerVisible)
  EndWith
  
EndProcedure

; EOF