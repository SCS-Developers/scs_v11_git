; File: fmImportCSV.pbi

EnableExplicit

Procedure WIC_btnAddSelected_Click()
  PROCNAMEC()
  Protected i, j, k, d, d2, h, n
  Protected nMaxRow, nRow, nRow2, i2, i3, j2, k2
  Protected nNewCues, nStartCuePtr, nCurrCuePtr
  Protected sCue.s, nCounter, sOrigCue.s
  Protected sChar.s
  Protected nNumber, sMsg.s
  Protected bDoingPrefix, bFound, bFound2
  Protected nMyPrevSubIndex, nMyPrevAudIndex
  Protected bMissingCues, sTargetCue.s
  Protected bLockedMutex

  debugMsg(sProcName, #SCS_START)
  
  With WIC
    If grWIC\nFileType = #SCS_IMP_CSV_ETC
      If Len(Trim(grWIC\sLogicalDev)) = 0
        sMsg = LangPars("Errors", "MustBeSelected", GGT(\lblLogicalDev))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(GWT(#WIC),sMsg,#MB_ICONEXCLAMATION)
        ProcedureReturn
      EndIf
    EndIf
  EndWith
  
  For i2 = 1 To gn2ndLastCue
    a2ndCue(i2)\bCueSelected = #False
  Next i2
  
  nMaxRow = CountGadgetItems(WIC\grdAddCues) - 1
  For nRow = 0 To nMaxRow
    If GetGadgetItemState(WIC\grdAddCues,nRow) & #PB_ListIcon_Checked
      nCurrCuePtr = GetGadgetItemData(WIC\grdAddCues, nRow)
      If nCurrCuePtr <= gn2ndLastCue
        ; should be #True
        a2ndCue(nCurrCuePtr)\bCueSelected = #True
        nNewCues + 1
      EndIf
    EndIf
  Next nRow
  
  debugMsg(sProcName, "nMaxRow=" + nMaxRow + ", nNewCues=" + nNewCues)
  If nNewCues = 0
    ProcedureReturn
  EndIf
  
  LockCueListMutex(710)
  
  If grWIC\bNewCueNos = #False
    ; user requested preserve cue numbers, so check all required numbers available
    For i2 = 1 To gn2ndLastCue
      If a2ndCue(i2)\bCueSelected
        For i = 1 To gnLastCue
          If UCase(aCue(i)\sCue) = UCase(a2ndCue(i2)\sCue)
            sMsg = LangPars("WIC", "CueNumberAlreadyUsed", a2ndCue(i2)\sCue)
            debugMsg(sProcName, sMsg)
            scsMessageRequester(GWT(#WIC), sMsg, #PB_MessageRequester_Error)
            UnlockCueListMutex()
            ProcedureReturn
          EndIf
        Next i
      EndIf
    Next i2
  EndIf
  
  If checkMaxCue(gnLastCue + nNewCues) = #False
    ; cue limit exceeded - ignore this
    debugMsg(sProcName, "cue limit exceeded - ignore this")
    UnlockCueListMutex()
    ProcedureReturn ; abandon import !!!!!!!!!!!!!
  EndIf
  
  setMouseCursorBusy()
  
  nStartCuePtr = GGS(WIC\cboTargetCue) + 1
  
  For i = gnLastCue To nStartCuePtr Step -1
    i2 = i + nNewCues
    aCue(i2) = aCue(i)
    j2 = aCue(i2)\nFirstSubIndex
    While j2 >= 0
      aSub(j2)\nCueIndex = i2
      If aSub(j2)\bSubTypeHasAuds
        k2 = aSub(j2)\nFirstAudIndex
        While k2 >= 0
          aAud(k2)\nCueIndex = i2
          setMissingCueMarkerIds(k2)
          k2 = aAud(k2)\nNextAudIndex
        Wend
      EndIf
      j2 = aSub(j2)\nNextSubIndex
    Wend
  Next i
  
  For i = nStartCuePtr To (nStartCuePtr + nNewCues - 1)
    aCue(i) = grCueDef
  Next i
  
  gnLastCue + nNewCues
  gnCueEnd + nNewCues
  
  nCurrCuePtr = nStartCuePtr
  
  ReDim aCueChange(CountGadgetItems(WIC\grdAddCues))
  grWIC\nCueChangePtr = -1
  
  For i2 = 1 To gn2ndLastCue
    If a2ndCue(i2)\bCueSelected = #False
      Continue
    EndIf
    
    aCue(nCurrCuePtr) = a2ndCue(i2)
    
    sOrigCue = a2ndCue(i2)\sCue
    grWIC\nCueChangePtr + 1
    aCueChange(grWIC\nCueChangePtr)\sOrigCue = sOrigCue
    
    sCue = sOrigCue
    If grWIC\bNewCueNos
      ; generate new cue number
      aCue(nCurrCuePtr)\sCue = grCueDef\sCue
      If nCurrCuePtr = 1
        sCue = generateNextCueLabel("", grProd\nCueLabelIncrement, 0.0, grWIC\sCuePrefix)
      Else
        sCue = generateNextCueLabel(aCue(nCurrCuePtr-1)\sCue, grProd\nCueLabelIncrement, 0.0, grWIC\sCuePrefix)
      EndIf
      
      ; now check if that cue label is already in use
      bFound = #False
      For i = 1 To gnLastCue
        If UCase(aCue(i)\sCue) = UCase(sCue)
          bFound = #True
          Break
        EndIf
      Next i
      
      If bFound
        ; generated label already in use so create a unique label
        nCounter = 0
        bFound = #True
        While (bFound) And (nCounter < 10000) ; prevent endless loop
          nCounter + 1
          sCue = generateNextCueLabel(sCue, grProd\nCueLabelIncrement, 0.0, grWIC\sCuePrefix)
          bFound = #False
          For i = 1 To gnLastCue
            If UCase(aCue(i)\sCue) = UCase(sCue)
              bFound = #True
              Break
            EndIf
          Next i
        Wend
      EndIf
      
      aCue(nCurrCuePtr)\sCue = sCue
      aCue(nCurrCuePtr)\nPreEditPtr = grCueDef\nPreEditPtr
      aCue(nCurrCuePtr)\nOriginalCuePtr = grCueDef\nOriginalCuePtr
      
    EndIf ; EndIf grWIC\bNewCueNos
    
    aCueChange(grWIC\nCueChangePtr)\sNewCue = sCue
    
    aCue(nCurrCuePtr)\nFirstSubIndex = -1
    nMyPrevSubIndex = -1
    
    ; debugMsg(sProcName, "calling setDerivedCueFields(" + nCurrCuePtr + ", #False)")
    setDerivedCueFields(nCurrCuePtr, #False)
    
    j2 = a2ndCue(i2)\nFirstSubIndex
    While j2 >= 0
      gnLastSub + 1
      checkMaxSub(gnLastSub)
      aSub(gnLastSub) = a2ndSub(j2)
      aSub(gnLastSub)\sCue = sCue
      aSub(gnLastSub)\nCueIndex = nCurrCuePtr
      ; fix up indexes for cue's firstSubIndex, and for sub's prev and next pointers
      If aCue(nCurrCuePtr)\nFirstSubIndex = -1
        aCue(nCurrCuePtr)\nFirstSubIndex = gnLastSub
      EndIf
      aSub(gnLastSub)\nPrevSubIndex = nMyPrevSubIndex
      If nMyPrevSubIndex >= 0
        aSub(nMyPrevSubIndex)\nNextSubIndex = gnLastSub
      EndIf
      nMyPrevSubIndex = gnLastSub
      ; debugMsg(sProcName, "gnLastSub=" + gnLastSub + ", aCue(" + nCurrCuePtr + ")\nFirstSubIndex=" + aCue(nCurrCuePtr)\nFirstSubIndex + ", aSub(" + gnLastSub + ")\nPrevSubIndex=" + aSub(gnLastSub)\nPrevSubIndex + ", aSub(" + nMyPrevSubIndex + ")\nNextSubIndex=" + aSub(nMyPrevSubIndex)\nNextSubIndex)
      
      If (aSub(gnLastSub)\nPrevSubIndex = -1) And (aSub(gnLastSub)\nNextSubIndex = -1)
        aSub(gnLastSub)\sSubLabel = aSub(gnLastSub)\sCue
      Else
        aSub(gnLastSub)\sSubLabel = aSub(gnLastSub)\sCue + "<" + aSub(gnLastSub)\nSubNo + ">"
      EndIf
      aSub(gnLastSub)\bHotkey = aCue(nCurrCuePtr)\bHotkey ; cue activation may have been changed to manual
      aSub(gnLastSub)\bExtAct = aCue(nCurrCuePtr)\bExtAct ; cue activation may have been changed to manual
      
      aSub(gnLastSub)\nFirstAudIndex = -1
      ; debugMsg(sProcName, "aSub(" + gnLastSub + ")\nFirstAudIndex=" + aSub(gnLastSub)\nFirstAudIndex)
      nMyPrevAudIndex = -1
      k2 = a2ndSub(j2)\nFirstAudIndex
      While k2 >= 0
        gnLastAud + 1
        checkMaxAud(gnLastAud)
        aAud(gnLastAud) = a2ndAud(k2)
        aAud(gnLastAud)\sCue = sCue
        aAud(gnLastAud)\nCueIndex = nCurrCuePtr
        aAud(gnLastAud)\nSubIndex = gnLastSub
        aAud(gnLastAud)\nSubNo = aSub(gnLastSub)\nSubNo
        ; fix up indexes for sub's firstAudIndex, and for aud's prev and next pointers
        If aSub(gnLastSub)\nFirstAudIndex = -1
          aSub(gnLastSub)\nFirstAudIndex = gnLastAud
          debugMsg(sProcName, "aSub(" + gnLastSub + ")\nFirstAudIndex=" + aSub(gnLastSub)\nFirstAudIndex)
        EndIf
        aAud(gnLastAud)\nPrevAudIndex = nMyPrevAudIndex
        If nMyPrevAudIndex >= 0
          aAud(nMyPrevAudIndex)\nNextAudIndex = gnLastAud
        EndIf
        nMyPrevAudIndex = gnLastAud
        k2 = a2ndAud(k2)\nNextAudIndex
      Wend
      
      j2 = a2ndSub(j2)\nNextSubIndex
    Wend
    
    j = aCue(nCurrCuePtr)\nFirstSubIndex
    While j >= 0
      setDerivedSubFields(j, #True)
      k = aSub(j)\nFirstAudIndex
      While k >= 0
        setDerivedAudFields(k, #True)
        k = aAud(k)\nNextAudIndex
      Wend
      j = aSub(j)\nNextSubIndex
    Wend
    
    ; debugMsg(sProcName, "calling setInitCueStates(" + nCurrCuePtr + ", -1, #False)")
    setInitCueStates(nCurrCuePtr, -1, #False)
    nCurrCuePtr + 1
  Next i2
  
  gbImportedCues = #True
  
  debugMsg(sProcName, "calling validateDevMaps()")
  validateDevMaps()
  
  debugMsg(sProcName, "calling setCuePtrs")
  setCuePtrs(#False)
  loadCueBrackets()
  
  debugProd(@grProd)
  debugCuePtrs()
  
  propagateFileInfo()
  setTimeBasedCues()
  WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
  WED_setEditorButtons()
  redoCueListTree(-1)
  WMN_loadHotkeyPanel()
  populateGrid()
  clearVUDisplay()
  listAllDevMaps()
  
  WIC_loadTargetCueCombo()
  WIC_btnClearAll_Click()
  
  gnCallOpenNextCues = 1
  gbCallLoadDispPanels = #True
  
  If nNewCues = 1
    sMsg = Lang("WIM", "Imported1")
  Else
    sMsg = LangPars("WIM", "Imported>1", Str(nNewCues))
  EndIf
  ; sMsg + Chr(10) + Chr(10) + Lang("WIM", "ProdFolderNote")
  setMouseCursorNormal()
  debugMsg(sProcName, sMsg)
  scsMessageRequester(GWT(#WIC), sMsg, #PB_MessageRequester_Ok|#MB_ICONINFORMATION)
  
  setMouseCursorNormal()
  WIC_Form_Unload()
  UnlockCueListMutex()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIC_drawProgress(nCurrValue, nMaxValue)
  Protected nWidth, nHeight
  Protected nPos
  
  If StartDrawing(CanvasOutput(WIC\cvsProgress))
      nWidth = GadgetWidth(WIC\cvsProgress)
      nHeight = GadgetHeight(WIC\cvsProgress)
      ; Box(0,0,nWidth,nHeight,#SCS_Dark_Grey)
      Box(0,0,nWidth,nHeight,#SCS_Light_Grey)
      If nCurrValue > 0
        If nCurrValue >= nMaxValue
          nPos = nWidth
        Else
          nPos = Round((nCurrValue * nWidth) / nMaxValue, #PB_Round_Nearest)
        EndIf
        Box(0,0,nPos,nHeight,#SCS_Light_Green)
      EndIf
    StopDrawing()
  EndIf
EndProcedure

Procedure WIC_Form_Load()
  PROCNAMEC()
  
  If IsWindow(#WIC) = #False
    createfmImportCSV()
  EndIf
  setFormPosition(#WIC, @grImportCSVWindow)
  WIC_Form_Resized(#True)
  
  WIC_drawProgress(0,0)
  WIC_setupGrdAddCues()
  WIC_setButtons()
  WIC_loadTargetCueCombo()

  setWindowVisible(#WIC, #True)

EndProcedure

Procedure WIC_Form_Unload()
  getFormPosition(#WIC, @grImportCSVWindow, #True)
  unsetWindowModal(#WIC)
  scsCloseWindow(#WIC)
  If IsWindow(#WED)
    SetActiveWindow(#WED)
  EndIf
EndProcedure

Procedure WIC_setupDevices()
  PROCNAMEC()
  ; see WIM_setupDevices() if this procedure is to be reinstated
  gnLastImportDev = -1
EndProcedure

Procedure WIC_setupGrdAddCues()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  ClearGadgetItems(WIC\grdAddCues)

EndProcedure

Procedure WIC_btnBrowse_Click()
  PROCNAMEC()
  Protected sTitle.s, sDefaultFile.s, sPattern.s, nPattern
  Protected sThisCSVFile.s
  Protected nReadResult
  
  sTitle = Lang("Requesters", "OpenCSVFile")
  sDefaultFile = grWIC\sCSVFile
  sPattern = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
  nPattern = 0    ; use the first pattern
  
  ; Open the file for reading
  sThisCSVFile = OpenFileRequester(sTitle, sDefaultFile, sPattern, nPattern)
  If Len(sThisCSVFile) = 0
    ; no file selected
    ProcedureReturn
  EndIf
  SGT(WIC\txtCSVFile, GetFilePart(sThisCSVFile))
  scsToolTip(WIC\txtCSVFile, sThisCSVFile)
  If grWIC\sCSVFile <> sThisCSVFile
    grWIC\sCSVFile = sThisCSVFile
    WIC_clearGrid()
  EndIf
  
EndProcedure

Procedure WIC_findPageInLabel(sLabel.s)
  PROCNAMEC()
  Protected nPosAndLen
  Protected nFieldCount, nFieldNo, nFieldPos
  Protected sWorkLabel.s, sField.s
  Protected bIsPageNo
  Protected n
  
  sWorkLabel = ReplaceString(sLabel, ";", " ")
  ReplaceString(sWorkLabel, ".", " ", #PB_String_InPlace)
  ReplaceString(sWorkLabel, ",", " ", #PB_String_InPlace)
  
  ; do NOT remove multiple spaces or trim from the start, etc, as we need to determine the exact starting position with sLabel of the page number, if found
  nFieldCount = CountString(sWorkLabel, " ") + 1
  nFieldPos = 1
  For nFieldNo = 1 To nFieldCount
    sField = StringField(sWorkLabel, nFieldNo, " ")
    bIsPageNo = #False
    If Len(sField) >= 2
      If LCase(Left(sField,1)) = "p"
        For n = 2 To Len(sField)
          Select Mid(sField,n,1)
            Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
              ; this char ok
              bIsPageNo = #True
            Default
              bIsPageNo = #False
              Break
          EndSelect
        Next n
      EndIf
    EndIf
    If bIsPageNo
      nPosAndLen = (nFieldPos << 16) | Len(sField)
      ; debugMsg(sProcName, "bIsPageNo=-" + strB(bIsPageNo) + ", nFieldPos=" + Str(nFieldPos) + ", nPosAndLen=$" + Hex(nPosAndLen,#PB_Long))
      Break
    EndIf
    ; debugMsg(sProcName, "nFieldNo=" + Str(nFieldNo) + ", nFieldPos=" + Str(nFieldPos) + ", sField=<<" + sField + ">>")
    nFieldPos + Len(sField + " ")
  Next nFieldNo
  
  ProcedureReturn nPosAndLen
EndProcedure

Procedure WIC_buildCuesFromETCImport()
  PROCNAMEC()
  Protected i, j, k, n
  Protected q
  Protected sCuePrefix.s
  Protected sDescr.s, sPageNo.s, sWhenReqd.s
  Protected sDescrSplit.s, bDescrSplit
  Protected sImportLabel.s, nFieldCount
  Protected sField1.s, sField2.s
  Protected nSplitPos
  Protected bNextCueEnabled
  Protected nPosAndLen, nPos, nLen
  Protected sLeft.s, sRight.s
  
  debugMsg(sProcName, #SCS_START)
  
  With WIC
    sCuePrefix = Trim(GGT(\txtCuePrefix))
    sDescrSplit = Trim(Left(GGT(\txtDescrSplit),1))
    If Len(sDescrSplit) > 0
      bDescrSplit = #True
    EndIf
  EndWith
  
  gr2ndProd = grProdDefForAdd
  
  i = 0
  j = 0
  k = 0
  bNextCueEnabled = #True
  For q = 0 To (grETCImport\nCueCount - 1)
    sImportLabel = Trim(grETCImport\sLabel(q))
    sDescr = ""
    sPageNo = ""
    sWhenReqd = ""
    debugMsg(sProcName, "sImportLabel=" + sImportLabel)
    
    ; page
    nPosAndLen = WIC_findPageInLabel(sImportLabel)
    If nPosAndLen <> 0
      nPos = nPosAndLen >> 16
      nLen = nPosAndLen & $FFFF
      sPageNo = Mid(sImportLabel, nPos, nLen)
      If nPos > 1
        sLeft = Left(sImportLabel, (nPos - 1))
      EndIf
      sRight = Mid(sImportLabel, (nPos + nLen))
      sImportLabel = sLeft + sRight
    EndIf
    ; debugMsg(sProcName, "nPosAndLen=$" + Hex(nPosAndLen,#PB_Long))
    
    ; descr and whenreqd
    If bDescrSplit
      nFieldCount = CountString(sImportLabel, sDescrSplit) + 1
      sField1 = Trim(StringField(sImportLabel, 1, sDescrSplit))
      If nFieldCount <= 2
        sField2 = Trim(StringField(sImportLabel, 2, sDescrSplit))
      Else
        ; collect remaining 'fields' into sField2
        nSplitPos = FindString(sImportLabel, sDescrSplit)
        nSplitPos = FindString(sImportLabel, sDescrSplit, nSplitPos+1)
        sField2 = Trim(Mid(sImportLabel, nSplitPos + Len(sDescrSplit)))
      EndIf
      sDescr = sField1
      sWhenReqd = sField2
    Else
      sDescr = sImportLabel
    EndIf
    
    ; cue
    i + 1
    If i > ArraySize(a2ndCue())
      ReDim a2ndCue(i+50)
    EndIf
    a2ndCue(i) = grCueDef
    With a2ndCue(i)
      gnUniqueCueId + 1
      \nCueId = gnUniqueCueId
      gnNodeId + 1
      \nNodeKey = gnNodeId
      \bDefaultCueDescrMayBeSet = #False
      \sCue = Trim(sCuePrefix + grETCImport\sETCCue(q))
      ; description field is madatory in a cue, so if the imported description is blank then set the description to "-"
      If Len(Trim(sDescr)) = 0
        sDescr = "-"
      EndIf
      \sCueDescr = sDescr
      \sPageNo = sPageNo
      \sWhenReqd = sWhenReqd
      ; note that if the 'FOLLOW' field is set then the *following* cue is to be disabled - hence the naming of the variable bNextCueEnabled
      \bCueEnabled = bNextCueEnabled
      bNextCueEnabled = grETCImport\bNextCueEnabled(q)
    EndWith
    
    ; sub
    j + 1
    If j > ArraySize(a2ndSub())
      ReDim a2ndSub(j+50)
    EndIf
    a2ndSub(j) = grSubDefForAdd
    With a2ndSub(j)
      gnUniqueSubId + 1
      \nSubId = gnUniqueSubId
      gnNodeId + 1
      \nNodeKey = gnNodeId
      \nCueIndex = i
      \sCue = a2ndCue(i)\sCue
      \bDefaultSubDescrMayBeSet = #False
      \nSubNo = 1
      ; sub detail
      \sSubType = "M"
      \sSubDescr = sDescr
      n = 0
      \aCtrlSend[n]\nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
      \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_MSC
      \aCtrlSend[n]\sCSLogicalDev = grWIC\sLogicalDev
      \aCtrlSend[n]\nMSChannel = grWIC\nMSChannel
      \aCtrlSend[n]\nMSParam1 = 1 ; lighting
      \aCtrlSend[n]\nMSParam2 = 1 ; go
      \aCtrlSend[n]\sMSQNumber = Trim(grETCImport\sETCCue(q))
      buildDisplayInfoForCtrlSend(@a2ndSub(j), n, #False)
      ; end of sub detail
    EndWith
    
    a2ndCue(i)\nFirstSubIndex = j
    
    set2ndLabels(i)
    setDerivedSubFields(j, #False)
    setDerivedCueFields2(i, #False)
    
    ; debugMsg(sProcName, "a2ndSub(" + getSubLabel2(j) + ")\aCtrlSend[0]\sCSLogicalDev=" + a2ndSub(j)\aCtrlSend[0]\sCSLogicalDev)
    
  Next q
  
  gn2ndLastAud = k
  gn2ndLastSub = j
  gn2ndLastCue = i
  gn2ndCueEnd = gn2ndLastCue + 1
  If ArraySize(a2ndCue()) < gn2ndCueEnd
    REDIM_ARRAY(a2ndCue, gn2ndCueEnd+20, grCueDef, "a2ndCue()")
  EndIf
  a2ndCue(gn2ndCueEnd) = grCueDef
  setCuePtrs2nd(#True)
  
  ; debugMsg(sProcName, "calling debugCuePtrs2()")
  ; debugCuePtrs2()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIC_btnReadFile_Click()
  PROCNAMEC()
  Protected sMsg.s
  
  With grWIC
    If FileExists(\sCSVFile)
      Select \nFileType
        Case #SCS_IMP_CSV_STD
          WIC_importStandardCSV()
          If \nMaxImportCue < 0
            sMsg = LangPars("WIC", "NoCues", GetFilePart(\sCSVFile))
            scsMessageRequester(GWT(#WIC), sMsg, #MB_ICONEXCLAMATION)
            ProcedureReturn
          EndIf
          WIC_buildCuesFromStandardCSV()
        Case #SCS_IMP_CSV_ETC
          importETC_CueList(\sCSVFile)
          If grETCImport\nCueCount = 0
            sMsg = LangPars("WIC", "NoCues", GetFilePart(\sCSVFile))
            scsMessageRequester(GWT(#WIC), sMsg, #MB_ICONEXCLAMATION)
            ProcedureReturn
          EndIf
          WIC_buildCuesFromETCImport()
      EndSelect
      WIC_displayCueList()
    EndIf
  EndWith
EndProcedure

Procedure WIC_displayCueList()
  PROCNAMEC()
  Protected i, j, nRow, nColCount, nColNo
  Protected sItem.s
  Protected sCue.s, sType.s
  Protected bShowDisabled, sDisabledText.s
  Static nPrevDisplayedFileType

  debugMsg(sProcName, #SCS_START)
  
  With WIC
    ClearGadgetItems(\grdAddCues) ; clear any existing content
    If grWIC\nFileType <> nPrevDisplayedFileType
      nColCount = GetGadgetAttribute(\grdAddCues, #PB_ListIcon_ColumnCount)
      For nColNo = nColCount To 1 Step -1
        RemoveGadgetColumn(\grdAddCues, nColNo)
      Next nColno
      AddGadgetColumn(\grdAddCues,1,Lang("Common","Cue"),65)
      AddGadgetColumn(\grdAddCues,2,Lang("Common","Page"),45)
      AddGadgetColumn(\grdAddCues,3,Lang("Common","Description"),260)
      AddGadgetColumn(\grdAddCues,4,Lang("Common","WhenReqd"),150)
      AddGadgetColumn(\grdAddCues,5,Lang("Common","CueType"),85)
      If grWIC\nFileType = #SCS_IMP_CSV_ETC
        AddGadgetColumn(\grdAddCues,6,Lang("WIC","Disabled"),65)
      EndIf
;       autoFitGridCol(\grdAddCues, 3) ; autofit "Description" column
      nPrevDisplayedFileType = grWIC\nFileType
    EndIf
    
    If grWIC\nFileType = #SCS_IMP_CSV_ETC
      bShowDisabled = #True
      sDisabledText = Lang("WIC", "Disabled")
    EndIf
    For i = 1 To gn2ndLastCue
      nRow = i-1
      sCue = a2ndCue(i)\sCue
      j = a2ndCue(i)\nFirstSubIndex
      If j >= 0
        sType = decode2ndSubType(a2ndSub(j)\sSubType, j)
        If a2ndSub(j)\nNextSubIndex >= 0
          sCue + "+"
        EndIf
      EndIf
      sItem = ""
      sItem + Chr(10) + sCue
      sItem + Chr(10) + a2ndCue(i)\sPageNo
      sItem + Chr(10) + a2ndCue(i)\sCueDescr
      sItem + Chr(10) + a2ndCue(i)\sWhenReqd
      sItem + Chr(10) + sType
      If bShowDisabled
        If a2ndCue(i)\bCueEnabled
          sItem + Chr(10) + ""
        Else
          sItem + Chr(10) + sDisabledText
        EndIf
      EndIf
      addGadgetItemWithData(\grdAddCues, sItem, i)
      SetGadgetItemColor(WIC\grdAddCues, nRow, #PB_Gadget_BackColor, a2ndCue(i)\nBackColor, -1)
      SetGadgetItemColor(WIC\grdAddCues, nRow, #PB_Gadget_FrontColor, a2ndCue(i)\nTextColor, -1)
    Next i
    
    autoFitGridCol(\grdAddCues, 3) ; autofit "Description" column
  EndWith
  
  WIC_setButtons()

EndProcedure

Procedure WIC_setButtons()
  Protected nRow
  Protected nRowCount, nRowsChecked

  With WIC
    If (Len(grWIC\sCSVFile) = 0) Or (grWIC\nFileType = 0)
      setEnabled(\btnReadFile, #False)
    Else
      setEnabled(\btnReadFile, #True)
    EndIf
    
    nRowCount = CountGadgetItems(WIC\grdAddCues)
    For nRow = 0 To nRowCount-1
      If GetGadgetItemState(WIC\grdAddCues,nRow) & #PB_ListIcon_Checked
        nRowsChecked + 1
      EndIf
    Next nRow
    
    If nRowCount = 0 Or nRowsChecked = nRowCount
      setEnabled(WIC\btnSelectAll, #False)
    Else
      setEnabled(WIC\btnSelectAll, #True)
    EndIf
    
    If nRowsChecked = 0
      setEnabled(WIC\btnClearAll, #False)
      setEnabled(WIC\btnAddSelected, #False)
    Else
      setEnabled(WIC\btnClearAll, #True)
      setEnabled(WIC\btnAddSelected, #True)
    EndIf
  EndWith

EndProcedure

Procedure WIC_loadTargetCueCombo()
  PROCNAMEC()
  Protected i, nListIndex, nEndIndex
  Protected sTmp.s

  ClearGadgetItems(WIC\cboTargetCue)
  For i = 1 To gnLastCue
    sTmp = buildCueForCBO(i)
    addGadgetItemWithData(WIC\cboTargetCue, sTmp, i)
  Next i
  addGadgetItemWithData(WIC\cboTargetCue, grText\sTextEnd, gnCueEnd)
  nEndIndex = CountGadgetItems(WIC\cboTargetCue)-1

  If (nEditCuePtr > 0) And (nEditCuePtr <= gnLastCue)
    nListIndex = indexForComboBoxData(WIC\cboTargetCue, nEditCuePtr, nEndIndex)
  Else
    nListIndex = indexForComboBoxData(WIC\cboTargetCue, gnCueEnd, nEndIndex)
  EndIf
  SGS(WIC\cboTargetCue, nListIndex)

EndProcedure

Procedure.s WIC_getNewCue(sOrigCue.s)
  Protected n, sNewCue.s
  
  sNewCue = sOrigCue
  For n = 0 To grWIC\nCueChangePtr
    If aCueChange(n)\sOrigCue = sOrigCue
      sNewCue = aCueChange(n)\sNewCue
      Break
    EndIf
  Next n
  ProcedureReturn sNewCue
EndProcedure

Procedure WIC_cboFileType_Click()
  PROCNAMEC()
  
  With WIC
    grWIC\nFileType = getCurrentItemData(\cboFileType)
    WIC_fcFileType()
  EndWith
  
EndProcedure

Procedure WIC_cboLogicalDev_Click()
  PROCNAMEC()
  
  With WIC
    grWIC\sLogicalDev = GGT(\cboFileType)
  EndWith
  
EndProcedure

Procedure WIC_cboMSChannel_Click()
  PROCNAMEC()
  
  With WIC
    grWIC\nMSChannel = getCurrentItemData(\cboMSChannel)
  EndWith
  
EndProcedure

Procedure WIC_chkNewCueNos_Click()
  PROCNAMEC()
  
  With WIC
    grWIC\bNewCueNos = GGS(\chkNewCueNos)
  EndWith
  
EndProcedure

Procedure WIC_fcFileType()
  PROCNAMEC()
  Protected d, sLogicalDev.s
  Protected nListIndex
  Protected sMsg.s
  Protected m, sHexValue.s
  Protected sFileType.s
  Protected nControlsTop, nGridTop, nGridHeight
  
  With WIC
    
    Select grWIC\nFileType
      Case #SCS_IMP_CSV_STD
        setVisible(\cntMidi, #False)
        setVisible(\cntExtras, #False)
        
      Case #SCS_IMP_CSV_ETC
        ClearGadgetItems(\cboLogicalDev)
        For d = 0 To grProd\nMaxCtrlSendLogicalDev
          sLogicalDev = grProd\aCtrlSendLogicalDevs(d)\sLogicalDev
          If sLogicalDev
            Select grProd\aCtrlSendLogicalDevs(d)\nDevType
              Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
                addGadgetItemWithData(\cboLogicalDev,sLogicalDev,d)
            EndSelect
          EndIf
        Next d
        If CountGadgetItems(\cboLogicalDev) = 0
          sFileType = Lang("WIC", "FileTypeETC")
          sMsg = LangPars("WIC", "NoMidi", sFileType)
          debugMsg(sProcName, sMsg)
          scsMessageRequester(GWT(#WIC),sMsg,#MB_ICONEXCLAMATION)
          nListIndex = -1
        Else
          nListIndex = indexForComboBoxRow(\cboLogicalDev,grWIC\sLogicalDev,0)
          SGS(\cboLogicalDev,nListIndex)
          grWIC\sLogicalDev = GGT(\cboLogicalDev)
        EndIf
        
        ClearGadgetItems(\cboMSChannel)
        For m = 0 To 127
          sHexValue = Right("0" + Hex(m), 2)
          addGadgetItemWithData(\cboMSChannel, (sHexValue + "H  "+ m), (m + 1))
        Next m
        nListIndex = indexForComboBoxData(\cboMSChannel, grWIC\nMSChannel, 0)
        SGS(\cboMSChannel, nListIndex)
        grWIC\nMSChannel = getCurrentItemData(\cboMSChannel)
        
        setVisible(\cntMidi, #True)
        setVisible(\cntExtras, #True)
        
      Default
        setVisible(\cntMidi, #False)
        setVisible(\cntExtras, #False)
        
    EndSelect
    
    If getVisible(\cntMidi)
      nControlsTop = GadgetY(\cntExtras) + GadgetHeight(\cntExtras) + 3
    Else
      nControlsTop = GadgetY(\cntMidi)
    EndIf
    ResizeGadget(\cntControls, #PB_Ignore, nControlsTop, #PB_Ignore, #PB_Ignore)
    nGridTop = GadgetY(\cntControls) + GadgetHeight(\cntControls)
    nGridHeight = WindowHeight(#WIC) - nGridTop - GadgetHeight(\cntBelowGrid)
    ResizeGadget(\grdAddCues, #PB_Ignore, nGridTop, #PB_Ignore, nGridHeight)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIC_Form_Show(bModal=#False)
  PROCNAMEC()
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WIC) = #False
    WIC_Form_Load()
  EndIf
  
  With WIC
    If grWIC\sCSVFile
      SGT(\txtCSVFile, GetFilePart(grWIC\sCSVFile))
      scsToolTip(\txtCSVFile, grWIC\sCSVFile)
    EndIf
    
    ClearGadgetItems(\cboFileType)
    addGadgetItemWithData(\cboFileType, Lang("WIC","FileTypeSTD"), #SCS_IMP_CSV_STD)
    addGadgetItemWithData(\cboFileType, Lang("WIC","FileTypeETC"), #SCS_IMP_CSV_ETC)
    nListIndex = indexForComboBoxData(\cboFileType, grWIC\nFileType, 0)
    SGS(\cboFileType, nListIndex)
    grWIC\nFileType = getCurrentItemData(\cboFileType)
    WIC_fcFileType()
    
    If grWIC\bNewCueNos
      SGS(\chkNewCueNos, 1)
    Else
      SGS(\chkNewCueNos, 0)
    EndIf
    
    SGT(\txtCuePrefix, grWIC\sCuePrefix)
    SGT(\txtDescrSplit, grWIC\sDescrSplit)
    
    WIC_setButtons()
  EndWith
  
  gn2ndLastCue = 0
  
  setWindowModal(#WIC, bModal)
  setWindowVisible(#WIC, #True)
  
EndProcedure

Procedure WIC_EventHandler()
  PROCNAMEC()
  Protected nMaxRow, nRow
  
  With WIC
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WIC_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnAddSelected)
              WIC_btnAddSelected_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WIC_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \cboFileType
            CBOCHG(WIC_cboFileType_Click())
            
          Case \cboLogicalDev
            CBOCHG(WIC_cboLogicalDev_Click())
            
          Case \cboMSChannel
            CBOCHG(WIC_cboMSChannel_Click())
            
          Case \chkNewCueNos
            WIC_chkNewCueNos_Click()
            
          Case \btnAddSelected
            WIC_btnAddSelected_Click()
            
          Case \btnBrowse
            WIC_btnBrowse_Click()
            
          Case \btnClearAll
            WIC_btnClearAll_Click()
            
          Case \btnClose
            WIC_Form_Unload()
            
          Case \btnHelp
            displayHelpTopic("scs_import_csv_std.htm")
            
          Case \btnReadFile
            WIC_btnReadFile_Click()
            
          Case \btnSelectAll
            nMaxRow = CountGadgetItems(\grdAddCues) - 1
            For nRow = 0 To nMaxRow
              SetGadgetItemState(WIC\grdAddCues, nRow, #PB_ListIcon_Checked)
            Next nRow
            WIC_setButtons()
            
          Case \cntBelowGrid, \cntControls, \cntExtras, \cntMidi
            ; ignore events
            
          Case \cvsProgress
            ; ignore events
            
          Case \grdAddCues
            If gnEventType = #PB_EventType_LeftClick
              WIC_setButtons()
            EndIf
            
          Case \txtCuePrefix
            If gnEventType = #PB_EventType_Change
              grWIC\sCuePrefix = Trim(GGT(\txtCuePrefix))
            EndIf
            
          Case \txtDescrSplit
            If gnEventType = #PB_EventType_Change
              grWIC\sDescrSplit = Left(Trim(GGT(\txtDescrSplit)),1)
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
      Case #PB_Event_SizeWindow
        WIC_Form_Resized()
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WIC_btnClearAll_Click()
  Protected nMaxRow, nRow
  
  nMaxRow = CountGadgetItems(WIC\grdAddCues) - 1
  For nRow = 0 To nMaxRow
    SetGadgetItemState(WIC\grdAddCues, nRow, 0)
  Next nRow
  WIC_setButtons()
EndProcedure

Procedure WIC_clearGrid()
  PROCNAMEC()
  
  ClearGadgetItems(WIC\grdAddCues)
  WIC_setButtons()
EndProcedure

Procedure WIC_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Static nPrevWindowWidth, nPrevWindowHeight
  Protected nLeft, nTop, nWidth, nHeight
  
  If IsWindow(#WIC) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WIC
    nWindowWidth = WindowWidth(#WIC)
    nWindowHeight = WindowHeight(#WIC)
    If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
      nPrevWindowWidth = nWindowWidth
      nPrevWindowHeight = nWindowHeight
      
      ResizeGadget(\lnSeparator,#PB_Ignore,#PB_Ignore,nWindowWidth,#PB_Ignore)
      
      ; resize \grdAddCues
      nLeft = GadgetX(\grdAddCues)
      nWidth = nWindowWidth - (nLeft << 1)
      nTop = GadgetY(\grdAddCues)
      nHeight = nWindowHeight - nTop - GadgetHeight(\cntBelowGrid)
      ResizeGadget(\grdAddCues, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
      autoFitGridCol(\grdAddCues, 3) ; autofit "Description" column
      
      ; reposition and resize \cntBelowGrid
      nTop = nWindowHeight - GadgetHeight(\cntBelowGrid)
      ResizeGadget(\cntBelowGrid,#PB_Ignore,nTop,nWindowWidth,#PB_Ignore)
      
      ; resize \cvsProgress
      nLeft = GadgetX(\cvsProgress)
      nWidth = nWindowWidth - (nLeft << 1)
      ResizeGadget(\cvsProgress,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
      WIC_drawProgress(0,0)
      
    EndIf
  EndWith
  
EndProcedure

Procedure WIC_importStandardCSV()
  PROCNAMEC()
	Protected sFileLine.s, nFieldCount, nFieldNo, sField.s, nStringPos
	Protected rImportCue.tyWICCue, rImportCueDef.tyWICCue
	Protected nCueField, nTypeField, nCueDescrField, nPageField, nWhenReqdField, nSubDescrField, nFileNameField
	
	debugMsg(sProcName, #SCS_START)
	
  With grWIC
    \nMaxImportCue = -1
    gnNextFileNo + 1
    \nFileNo = gnNextFileNo
    If ReadFile(\nFileNo, \sCSVFile, #PB_File_SharedRead) = #False
      ProcedureReturn
    EndIf
    ; read first line, which MUST define the fields in their order in this file
    sFileLine = Trim(ReadString(\nFileNo, #PB_Ascii))
    sFileLine = RemoveString(sFileLine, " ") ; remove any embedded spaces
    debugMsg(sProcName, "sFileLine=" + sFileLine)
    If sFileLine
      nFieldCount = CountString(sFileLine, ",") + 1
      For nFieldNo = 1 To nFieldCount
        sField = StringField(sFileLine, nFieldNo, ",")
        Select UCase(sField)
          Case "CUE"
            nCueField = nFieldNo
          Case "TYPE"
            nTypeField = nFieldNo
          Case "DESCRIPTION"
            nCueDescrField = nFieldNo
          Case "PAGE"
            nPageField = nFieldNo
          Case "WHENREQUIRED" ; nb "WHENREQUIRED", not "WHEN REQUIRED" because embedded spaces have been removed (see above)
            nWhenReqdField = nFieldNo
          Case "SUB-DESCRIPTION", "SUBDESCRIPTION"
            nSubDescrField = nFieldNo
          Case "FILENAME"
            nFileNameField = nFieldNo
        EndSelect
      Next nFieldNo
      debugMsg(sProcName, "nCueField=" + nCueField + ", nTypeField=" + nTypeField)
      If nCueField
        While Eof(\nFileNo) = 0
          sFileLine = Trim(ReadString(\nFileNo, #PB_Ascii))
          ; debugMsg(sProcName, "sFileLine=" + sFileLine)
          If sFileLine
            rImportCue = rImportCueDef
            rImportCue\sCue = Trim(StringField(sFileLine, nCueField, ","))
            If nTypeField : rImportCue\sType = UCase(Trim(StringField(sFileLine, nTypeField, ","))) : EndIf ; nb forced to uppercase
            If nCueDescrField : rImportCue\sCueDescr = Trim(StringField(sFileLine, nCueDescrField, ",")) : EndIf
            If nPageField : rImportCue\sPage = Trim(StringField(sFileLine, nPageField, ",")) : EndIf
            If nWhenReqdField : rImportCue\sWhenReqd = Trim(StringField(sFileLine, nWhenReqdField, ",")) : EndIf
            If nSubDescrField : rImportCue\sSubDescr = Trim(StringField(sFileLine, nSubDescrField, ",")) : EndIf
            If nFileNameField : rImportCue\sFileName = Trim(StringField(sFileLine, nFileNameField, ",")) : EndIf
            ; debugMsg(sProcName, "rImportCue\sType=" + rImportCue\sType)
            Select rImportCue\sType
              Case "F", "K", "A", "S" ; nb ignores lines with a blank, as well as unsupported/unrecognised types
                \nMaxImportCue + 1
                If \nMaxImportCue > ArraySize(\aImportCue())
                  ReDim \aImportCue(\nMaxImportCue + 50)
                EndIf
                \aImportCue(\nMaxImportCue) = rImportCue
            EndSelect
          EndIf
        Wend
      EndIf ; EndIf nCueField
    EndIf ; EndIf sFileLine
    CloseFile(\nFileNo)
    debugMsg(sProcName, "\nMaxImportCue=" + \nMaxImportCue)
  EndWith
  
EndProcedure

Procedure WIC_buildCuesFromStandardCSV()
  PROCNAMEC()
  Protected i, j, j2, k, n
  Protected n2ndCuePtr, nMax2ndCuePtr, nLastSubIndexFor2ndCuePtr
  Protected q
  Protected rImportCue.tyWICCue
  Protected bAudCreated
  
  debugMsg(sProcName, #SCS_START)
  
  gr2ndProd = grProdDefForAdd
  gr2ndProd = grProdDefForAdd
  
  For q = 0 To grWIC\nMaxImportCue
    rImportCue = grWIC\aImportCue(q)
    n2ndCuePtr = 0
    nLastSubIndexFor2ndCuePtr = 0
    bAudCreated = #False
    If grWIC\bNewCueNos = #False
      ; check if this cue number is already in use
      For n = 1 To nMax2ndCuePtr
        If UCase(a2ndCue(n)\sCue) = UCase(rImportCue\sCue)
          ; this cue number already found, so make this rImportCue info another sub-cue of that cue
          n2ndCuePtr = n
          j2 = a2ndCue(n)\nFirstSubIndex
          While j2 >= 0
            nLastSubIndexFor2ndCuePtr = j2
            j2 = a2ndSub(j2)\nNextSubIndex
          Wend
          Break
        EndIf
      Next n
    EndIf
    ; debugMsg(sProcName, "rImportCue\sCue=" + rImportCue\sCue + ", n2ndCuePtr=" + n2ndCuePtr)
    If n2ndCuePtr = 0
      i + 1
      If i > ArraySize(a2ndCue())
        ReDim a2ndCue(i+50)
      EndIf
      a2ndCue(i) = grCueDef
      n2ndCuePtr = i
      nMax2ndCuePtr = n2ndCuePtr
      With a2ndCue(i)
        gnUniqueCueId + 1
        \nCueId = gnUniqueCueId
        gnNodeId + 1
        \nNodeKey = gnNodeId
        \sCue = rImportCue\sCue
        \sCueDescr = rImportCue\sCueDescr
        If \sCueDescr
          \bDefaultCueDescrMayBeSet = #True
        Else
          ; description field is mandatory in a cue, so if the imported description is blank then set the description to "-"
          \sCueDescr = "-"
        EndIf
        \sPageNo = rImportCue\sPage
        \sWhenReqd = rImportCue\sWhenReqd
      EndWith
    EndIf
    ; debugMsg(sProcName, "rImportCue\sCue=" + rImportCue\sCue + ", n2ndCuePtr=" + n2ndCuePtr)
    
    ; sub
    j + 1
    If j > ArraySize(a2ndSub())
      ReDim a2ndSub(j+50)
    EndIf
    a2ndSub(j) = grSubDefForAdd
    With a2ndSub(j)
      gnUniqueSubId + 1
      \nSubId = gnUniqueSubId
      gnNodeId + 1
      \nNodeKey = gnNodeId
      \nCueIndex = n2ndCuePtr
      \sCue = a2ndCue(n2ndCuePtr)\sCue
      If nLastSubIndexFor2ndCuePtr > 0
        a2ndSub(nLastSubIndexFor2ndCuePtr)\nNextSubIndex = j
        \nPrevSubIndex = nLastSubIndexFor2ndCuePtr
        \nSubNo = a2ndSub(nLastSubIndexFor2ndCuePtr)\nSubNo + 1
      Else
        a2ndCue(n2ndCuePtr)\nFirstSubIndex = j
        \nSubNo = 1
      EndIf
      \sSubType = rImportCue\sType
      If rImportCue\sSubDescr
        \sSubDescr = rImportCue\sSubDescr
      Else
        \sSubDescr = rImportCue\sCueDescr
      EndIf
      If \sSubDescr
        \bDefaultSubDescrMayBeSet = #True
      Else
        ; description field is mandatory in a sub-cue, so if the imported description is blank then set the description to "-"
        \sSubDescr = "-"
      EndIf
      If rImportCue\sType = "A" And Len(rImportCue\sFileName) = 0
        \bSubPlaceHolder = #True
      EndIf
      If rImportCue\sType = "K"
        \sLTLogicalDev = grLightingLogicalDevsDef\sLogicalDev
        \nLTDevType = #SCS_DEVTYPE_LT_DMX_OUT
        \nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
      EndIf
    EndWith
    
    If rImportCue\sType = "F" Or (rImportCue\sType = "A" And rImportCue\sFileName)
      k + 1
      If k > ArraySize(a2ndAud())
        ReDim a2ndAud(k+50)
      EndIf
      a2ndAud(k) = grAudDefForAdd
      With a2ndAud(k)
        gnUniqueAudId + 1
        \nAudId = gnUniqueAudId
        \nCueIndex = n2ndCuePtr
        \sCue = a2ndCue(n2ndCuePtr)\sCue
        \nSubIndex = j
        \nSubNo = a2ndSub(j)\nSubNo
        \nAudNo = 1
        If rImportCue\sFileName
          \sStoredFileName = rImportCue\sFileName
        Else
          \bAudPlaceHolder = #True
          \sStoredFileName = grText\sTextPlaceHolder
        EndIf
        \sFileName = decodeFileName(\sStoredFileName, #False)
        a2ndSub(j)\nFirstAudIndex = k
        a2ndSub(j)\nAudCount = 1
      EndWith
      bAudCreated = #True
    EndIf
    
    set2ndLabels(n2ndCuePtr)
    If bAudCreated
      setDerivedAudFields(k, #False)
    EndIf
    setDerivedSubFields(j, #False)
    setDerivedCueFields2(n2ndCuePtr, #False)
    
    ; debugMsg(sProcName, "a2ndSub(" + getSubLabel2(j) + ")\aCtrlSend[0]\sCSLogicalDev=" + a2ndSub(j)\aCtrlSend[0]\sCSLogicalDev)
    
  Next q
  
  gn2ndLastAud = k
  gn2ndLastSub = j
  If i > nMax2ndCuePtr
    gn2ndLastCue = i
  Else
    gn2ndLastCue = nMax2ndCuePtr
  EndIf
  debugMsg(sProcName, "i=" + i + ", nMax2ndCuePtr=" + nMax2ndCuePtr + ", gn2ndLastCue=" +gn2ndLastCue + ", gn2ndLastSub=" + gn2ndLastSub + ", gn2ndLastAud=" + gn2ndLastAud)
  gn2ndCueEnd = gn2ndLastCue + 1
  If ArraySize(a2ndCue()) < gn2ndCueEnd
    REDIM_ARRAY(a2ndCue, gn2ndCueEnd+20, grCueDef, "a2ndCue()")
  EndIf
  a2ndCue(gn2ndCueEnd) = grCueDef
  setCuePtrs2nd(#True)
  
  ; debugMsg(sProcName, "calling debugCuePtrs2()")
  ; debugCuePtrs2()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF