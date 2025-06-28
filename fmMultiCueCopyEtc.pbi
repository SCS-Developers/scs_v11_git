; File: fmMultiCueCopyEtc.pbi

EnableExplicit

Procedure.s WMC_decodeGrdActionL(nGrdAction)
  PROCNAMEC()
  Protected sGrdAction.s
  
  With grWMC
    Select nGrdAction
      Case #SCS_WMC_GRDACTION_NO_CHANGE
        sGrdAction = ""
      Case #SCS_WMC_GRDACTION_ADDED
        sGrdAction = \sAdded
      Case #SCS_WMC_GRDACTION_MOVED
        sGrdAction = \sMoved
      Case #SCS_WMC_GRDACTION_DELETED
        sGrdAction = \sDeleted
      Case #SCS_WMC_GRDACTION_SORTED_ASC
        sGrdAction = \sSortedAsc
      Case #SCS_WMC_GRDACTION_SORTED_DEC
        sGrdAction = \sSortedDec 
    EndSelect
  EndWith
  ProcedureReturn sGrdAction
EndProcedure

Procedure WMC_selectRowsForCueSelection()
  PROCNAMEC()
  Protected n
  
  With WMC
    SGS(\grdPreview, -1)  ; clear existing selection
    
    If \nFirstSelectedCueIndex > \nSecondSelectedCueIndex
      \nSecondSelectedCueIndex = \nFirstSelectedCueIndex
    EndIf
    
    For n = \nFirstSelectedCueIndex To \nSecondSelectedCueIndex
      SetGadgetItemState(\grdPreview, n, #PB_ListIcon_Selected)
    Next n
    SGS(\cboFirstCue, \nFirstSelectedCueIndex)
    SGS(\cboLastCue, \nSecondSelectedCueIndex)
  EndWith
  
EndProcedure
  
Procedure WMC_selectRowsFromGadgets()
  PROCNAMEC()
  Protected nFirstSelectedRow, nLastSelectedRow
  Protected n
  
  With WMC
    nFirstSelectedRow = GGS(\cboFirstCue)
    nLastSelectedRow = GGS(\cboLastCue)
    
    If (nFirstSelectedRow > nLastSelectedRow) And (nFirstSelectedRow <> -1) And (nLastSelectedRow <> -1)
      nLastSelectedRow = nFirstSelectedRow
      SGS(\cboLastCue, nLastSelectedRow)
    EndIf
    
    SGS(\grdPreview, -1)  ; clear existing selection
    For n = nFirstSelectedRow To nLastSelectedRow
      SetGadgetItemState(\grdPreview, n, #PB_ListIcon_Selected)
    Next n
  EndWith
  
EndProcedure

Procedure.i WMC_rowIsSelected()
  Protected i, nRowSelected
  
  With WMC
    For i = 1 To gnLastCue
      If GetGadgetItemState(\grdPreview, i - 1) = #PB_ListIcon_Selected
          ProcedureReturn #True
        Break
      EndIf
    Next
  EndWith
  
  ProcedureReturn #False
EndProcedure

Procedure.i WMC_rowFirstLastSelected(bFirstSelectedRow)   ; bFirstSelectedRow = #False get first selected row, #True = get last selected row
  Protected i, nRowSelected
  
  With WMC
    If bFirstSelectedRow
      For i = 1 To gnLastCue
        If GetGadgetItemState(\grdPreview, i - 1) = #PB_ListIcon_Selected
            nRowSelected = i - 1
          Break
        EndIf
      Next
    Else
      For i = 1 To gnLastCue
        If GetGadgetItemState(\grdPreview, i - 1) = #PB_ListIcon_Selected
          nRowSelected = i - 1
          While i < gnLastCue
            If GetGadgetItemState(\grdPreview, i) = #PB_ListIcon_Selected
              i + 1
              nRowSelected = i - 1
            Else
              Break
            EndIf
          Wend
        EndIf
      Next
    EndIf
  EndWith
  
  ProcedureReturn nRowSelected
EndProcedure

Procedure WMC_searchColumns()
  Protected i, nSortType, nFindStringResult
  Protected userSearchString.s
  
  ClearList(WMC\nRowSelectors())
  WMC\cntSearchResults = 0
  SGS(WMC\grdPreview, -1)  ; clear existing selection
  userSearchString = Left(GetGadgetText(WMC\txtSearchTextCC), 24)
  SGT(WMC\txtSearchTextCC, userSearchString)
  nSortType = grWMC\nSearchColumn
  WMC \nIdxSearchResultSelected = 0
  
  For i = 1 To gnLastCue
    With gaCueMoveEtcInfo(i)
      \nOldCuePtr = i
      \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
      \sCue = aCue(i)\sCue
      \sPageNo = aCue(i)\sPageNo
      \sCueType = WMC_getCueType(i)
      \sCueDescr = aCue(i)\sCueDescr
      \sCueSortKey = ""      
      
      Select nSortType
        Case 0
          nFindStringResult = FindString(\sCue, userSearchString, 1, #PB_String_NoCase)
          
          If(nFindStringResult)
            AddElement(WMC\nRowSelectors())
            WMC\nRowSelectors() = i - 1
          EndIf
          
        Case 1
          nFindStringResult = FindString(\sPageNo, userSearchString, 1, #PB_String_NoCase)
          
          If(nFindStringResult)
            AddElement(WMC\nRowSelectors())
            WMC\nRowSelectors() = i - 1
          EndIf
          
        Case 2
          nFindStringResult = FindString(\sCueType, userSearchString, 1, #PB_String_NoCase)
          
          If(nFindStringResult)
            AddElement(WMC\nRowSelectors())
            WMC\nRowSelectors() = i - 1
          EndIf
          
        Case 3  
          nFindStringResult = FindString(\sCueDescr, userSearchString, 1, #PB_String_NoCase)
          
          If(nFindStringResult)
            AddElement(WMC\nRowSelectors())
            WMC\nRowSelectors() = i - 1
          EndIf
          
      EndSelect
    EndWith
    SetGadgetItemState(WMC\grdPreview, i, 0)
    Next i
 
  With WMC
    ForEach \nRowSelectors()
      \cntSearchResults + 1
    Next
    
    If \cntSearchResults
      FirstElement(\nRowSelectors())
      SetGadgetItemState(\grdPreview, \nRowSelectors(), #PB_ListIcon_Selected)
      SAG(\grdPreview)
      SGT(WMC\lblSearchCount, LangPars("WMC", "lblSearchCount", "1", Str(\cntSearchResults)))
      DisableGadget(WMC\btnPrev, #SCS_SHOW_GADGET)
      DisableGadget(WMC\btnNext, #SCS_SHOW_GADGET)
    Else
      SGT(WMC\lblSearchCount, LangPars("WMC", "lblSearchCount", "0", "0"))
    EndIf
  EndWith
EndProcedure  


Procedure WMC_setEnabledStates(bChangedCueList)
  PROCNAMEC()
  Protected bEnableGadget
  
  With WMC
    If bChangedCueList
      bEnableGadget = #False
    Else
      bEnableGadget = #True
    EndIf
    
    setEnabled(\cboActionReqd, bEnableGadget)
    setEnabled(\cboFirstCue, bEnableGadget)
    setEnabled(\cboLastCue, bEnableGadget)
    setEnabled(\cboTargetCue, bEnableGadget)
    setEnabled(\txtCueLabel, bEnableGadget)
    setEnabled(\txtCueNumberIncrement, bEnableGadget)
    ; setEnabled(\grdPreview, bEnableGadget)  ; commented out 5Nov2016 11.5.2.4 - see comments and new \grdPreview actions under WMC_EventHandler()
    If bEnableGadget
      setEnabled(\btnViewChanges, #True)
      setEnabled(\btnReset, #False)
    Else
      setEnabled(\btnViewChanges, #False)
      setEnabled(\btnReset, #True)
    EndIf
    
  EndWith
EndProcedure

Procedure.s WMC_getCueType(pCuePtr)
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

Procedure WMC_loadGrid()
  PROCNAMEC()
  Protected i
  Protected nArrayIndex, nArrayMax
  Protected nActionReqd, nFirstCue, nLastCue, nTargetCue
  Protected sCueLabel.s
  Protected sCueNumberIncrement.s, nIncrement, fIncrement.f
  Protected nTmpCuePtr, nNewCuePtr
  Protected sText.s
  Protected nSortDirection.i
  Protected bChangedCueList
  Protected nCounter, bFound
  Protected nFirstIndex, nLastIndex
  
  debugMsg(sProcName, #SCS_START + ", WMC\cboActionReqd=" + GGT(WMC\cboActionReqd))
  nActionReqd = getCurrentItemData(WMC\cboActionReqd)
  nArrayIndex = 0
  
  If nActionReqd = #SCS_WMC_ACTION_SEARCH
    nFirstCue   = 1
    nLastCue    = gnLastCue
    nArrayMax - gnLastCue
    bChangedCueList = #True
    
    For i = nFirstCue To nLastCue
      nArrayIndex + 1
      With gaCueMoveEtcInfo(nArrayIndex)
        \nOldCuePtr = i
        \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
        \sCue = aCue(i)\sCue
        \sPageNo = aCue(i)\sPageNo
        \sCueType = WMC_getCueType(i)
        \sCueDescr = aCue(i)\sCueDescr
      EndWith
    Next i
  Else
    nFirstCue   = getCurrentItemData(WMC\cboFirstCue, -1)
    nLastCue    = getCurrentItemData(WMC\cboLastCue, -1)
  EndIf
    
  With WMC    
    nTargetCue  = getCurrentItemData(\cboTargetCue, -1)
    debugMsg(sProcName, "nFirstCue=" + getCueLabel(nFirstCue) + ", nLastCue=" + getCueLabel(nLastCue) + ", nTargetCue=" + getCueLabel(nTargetCue))
    
    If nActionReqd = #SCS_WMC_ACTION_COPY
      sCueLabel   = Trim(GGT(\txtCueLabel))
      nIncrement = 1
      sCueNumberIncrement = Trim(GGT(WMC\txtCueNumberIncrement))
      If sCueNumberIncrement
        If FindString(sCueNumberIncrement, gsDecimalMarker) > 0 And IsNumeric(sCueNumberIncrement)
          fIncrement = ValF(sCueNumberIncrement)
          If fIncrement > 0
            nIncrement = 0
          Else
            ; fIncrement is invalid, so switch to nIncrement, set to the default value of 1
            nIncrement = 1
          EndIf
        ElseIf IsInteger(sCueNumberIncrement)
          nIncrement = Val(sCueNumberIncrement)
          If nIncrement < 1
            ; nIncrement is invalid, so use 1
            nIncrement = 1
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  Select nActionReqd
    Case #SCS_WMC_ACTION_COPY ; #SCS_WMC_ACTION_COPY
      If (nFirstCue > 0) And (nLastCue > 0) And (nTargetCue >= 0)
        bChangedCueList = #True
        ; load cues up to target cue
        For i = 1 To nTargetCue
          nArrayIndex + 1
          With gaCueMoveEtcInfo(nArrayIndex)
            \nOldCuePtr = i
            \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
            \sCue = aCue(i)\sCue
            \sPageNo = aCue(i)\sPageNo
            \sCueType = WMC_getCueType(i)
            \sCueDescr = aCue(i)\sCueDescr
            debugMsg(sProcName, "(ca) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sPageNo=" + \sPageNo + ", \sCueDescr=" + \sCueDescr)
          EndWith
        Next i
        ; load designated cue copies
        For i = nFirstCue To nLastCue
          nArrayIndex + 1
          With gaCueMoveEtcInfo(nArrayIndex)
            \nOldCuePtr = i
            \nGrdAction = #SCS_WMC_GRDACTION_ADDED
            \sCue = aCue(i)\sCue + "?"  ; will be set correctly later in this Procedure
            \sPageNo = aCue(i)\sPageNo
            \sCueType = WMC_getCueType(i)
            \sCueDescr = aCue(i)\sCueDescr
            debugMsg(sProcName, "(cb) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
          EndWith
        Next i
        ; load remaining cues
        For i = nTargetCue+1 To gnLastCue
          nArrayIndex + 1
          With gaCueMoveEtcInfo(nArrayIndex)
            \nOldCuePtr = i
            \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
            \sCue = aCue(i)\sCue
            \sPageNo = aCue(i)\sPageNo
            \sCueType = WMC_getCueType(i)
            \sCueDescr = aCue(i)\sCueDescr
            debugMsg(sProcName, "(cc) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
          EndWith
        Next i
        nArrayMax = nArrayIndex
      Else  ; insufficient or no info entered for 'copy'
        For i = 1 To gnLastCue
          nArrayIndex + 1
          With gaCueMoveEtcInfo(nArrayIndex)
            \nOldCuePtr = i
            \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
            \sCue = aCue(i)\sCue
            \sPageNo = aCue(i)\sPageNo
            \sCueType = WMC_getCueType(i)
            \sCueDescr = aCue(i)\sCueDescr
            debugMsg(sProcName, "(cd) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
          EndWith
          nArrayMax = i
        Next i
      EndIf
      
    Case #SCS_WMC_ACTION_MOVE ; #SCS_WMC_ACTION_MOVE
      If nFirstCue > 0 And nLastCue > 0 And nTargetCue >= 0 And (nTargetCue < nFirstCue Or nTargetCue > nLastCue)
        bChangedCueList = #True
        ; load cues up to earlier or first cue and target cue
        If nFirstCue < nTargetCue
          nTmpCuePtr = nFirstCue - 1
        Else
          nTmpCuePtr = nTargetCue
        EndIf
        For i = 1 To nTmpCuePtr
          nArrayIndex + 1
          With gaCueMoveEtcInfo(nArrayIndex)
            \nOldCuePtr = i
            \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
            \sCue = aCue(i)\sCue
            \sPageNo = aCue(i)\sPageNo
            \sCueType = WMC_getCueType(i)
            \sCueDescr = aCue(i)\sCueDescr
            debugMsg(sProcName, "(ma) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
          EndWith
        Next i
        If nTargetCue < nFirstCue
          ; now move cues to a target location that's earlier than nFirstCue
          For i = nFirstCue To nLastCue
            nArrayIndex + 1
            With gaCueMoveEtcInfo(nArrayIndex)
              \nOldCuePtr = i
              \nGrdAction = #SCS_WMC_GRDACTION_MOVED
              \sCue = aCue(i)\sCue
              \sPageNo = aCue(i)\sPageNo
              \sCueType = WMC_getCueType(i)
              \sCueDescr = aCue(i)\sCueDescr
              debugMsg(sProcName, "(mb) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
            EndWith
          Next i
        Else
          ; skip over the cues to be moved, and load cues up to the target cue
          For i = nLastCue+1 To nTargetCue
            nArrayIndex + 1
            With gaCueMoveEtcInfo(nArrayIndex)
              \nOldCuePtr = i
              \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
              \sCue = aCue(i)\sCue
              \sPageNo = aCue(i)\sPageNo
              \sCueType = WMC_getCueType(i)
              \sCueDescr = aCue(i)\sCueDescr
              debugMsg(sProcName, "(mc) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
            EndWith
          Next i
          ; now move cues to a target location that's later than nLastCue
          For i = nFirstCue To nLastCue
            nArrayIndex + 1
            With gaCueMoveEtcInfo(nArrayIndex)
              \nOldCuePtr = i
              \nGrdAction = #SCS_WMC_GRDACTION_MOVED
              \sCue = aCue(i)\sCue
              \sPageNo = aCue(i)\sPageNo
              \sCueType = WMC_getCueType(i)
              \sCueDescr = aCue(i)\sCueDescr
              debugMsg(sProcName, "(md) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
            EndWith
          Next i
        EndIf
        ; load remaining cues
        For i = nTargetCue+1 To gnLastCue
          If i < nFirstCue Or i > nLastCue
            nArrayIndex + 1
            With gaCueMoveEtcInfo(nArrayIndex)
              \nOldCuePtr = i
              \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
              \sCue = aCue(i)\sCue
              \sPageNo = aCue(i)\sPageNo
              \sCueType = WMC_getCueType(i)
              \sCueDescr = aCue(i)\sCueDescr
              debugMsg(sProcName, "(me) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
            EndWith
          EndIf
        Next i
      Else  ; insufficient or no info entered for 'move'
        For i = 1 To gnLastCue
          nArrayIndex + 1
          With gaCueMoveEtcInfo(nArrayIndex)
            \nOldCuePtr = i
            \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
            \sCue = aCue(i)\sCue
            \sPageNo = aCue(i)\sPageNo
            \sCueType = WMC_getCueType(i)
            \sCueDescr = aCue(i)\sCueDescr
            debugMsg(sProcName, "(mf) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
          EndWith
        Next i
      EndIf
      
    Case #SCS_WMC_ACTION_DELETE ; #SCS_WMC_ACTION_DELETE
      For i = 1 To gnLastCue
        nArrayIndex + 1
        With gaCueMoveEtcInfo(nArrayIndex)
          \nOldCuePtr = i
          \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
          \sCue = aCue(i)\sCue
          \sPageNo = aCue(i)\sPageNo
          \sCueType = WMC_getCueType(i)
          \sCueDescr = aCue(i)\sCueDescr
          If (nFirstCue > 0) And (nLastCue > 0)
            If (i >= nFirstCue) And (i <= nLastCue)
              bChangedCueList = #True
              \nNewCuePtr = -1
              \nGrdAction = #SCS_WMC_GRDACTION_DELETED
            EndIf
          EndIf
          debugMsg(sProcName, "(da) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
        EndWith
      Next i
      
    Case #SCS_WMC_ACTION_SORT_ASC,  #SCS_WMC_ACTION_SORT_DEC
      For i = 1 To gnLastCue
        nArrayIndex + 1
        With gaCueMoveEtcInfo(nArrayIndex)
          \nOldCuePtr = i
          \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
          \sCue = aCue(i)\sCue
          \sPageNo = aCue(i)\sPageNo
          \sCueType = WMC_getCueType(i)
          \sCueDescr = aCue(i)\sCueDescr
          \sCueSortKey = ""
          If (nFirstCue > 0) And (nLastCue > 0)
            If (i >= nFirstCue) And (i <= nLastCue)
              bChangedCueList = #True
              \sCueSortKey = WMC_makeCueSortKey(i, 8, 24)
              \nNewCuePtr = -1
              If nActionReqd = #SCS_WMC_GRDACTION_SORTED_ASC
                \nGrdAction = #SCS_WMC_GRDACTION_SORTED_ASC
              Else
                \nGrdAction = #SCS_WMC_GRDACTION_SORTED_DEC
              EndIf
              
            EndIf
            If i = nFirstCue
              nFirstIndex = nArrayIndex
            EndIf
            If i = nLastCue
              nLastIndex = nArrayIndex
            EndIf
          EndIf
          debugMsg(sProcName, "(sa) gaCueMoveEtcInfo(" + nArrayIndex + ")\sCueSortKey=" + \sCueSortKey + ", \sPageNo=" + \sPageNo + ", \sCue=" + \sCue + ", \sCueDescr=" + \sCueDescr)
        EndWith
      Next i
      
  EndSelect
  nArrayMax = nArrayIndex
  
  If (nActionReqd = #SCS_WMC_ACTION_SORT_ASC) Or (  #SCS_WMC_ACTION_SORT_DEC)
    debugMsg(sProcName, "nActionReqd=#SCS_WMC_ACTION_SORT_ASC or _DEC, nFirstIndex=" + nFirstIndex + ", nLastIndex=" + nLastIndex)
    If nLastIndex > nFirstIndex
      If nActionReqd = #SCS_WMC_ACTION_SORT_ASC
        nSortDirection = #PB_Sort_Ascending
      Else
        nSortDirection = #PB_Sort_Descending
      EndIf
        
      ; debugMsg0(sProcName, "calling SortStructuredArray(gaCueMoveEtcInfo(), #PB_Sort_Ascending, OffsetOf(tyCueMoveEtcInfo\sCueSortKey), #PB_String, " + nFirstIndex + ", " + nLastIndex + ")")
      SortStructuredArray(gaCueMoveEtcInfo(), nSortDirection, OffsetOf(tyCueMoveEtcInfo\sCueSortKey), #PB_String, nFirstIndex, nLastIndex)
    EndIf
  EndIf
  
  nNewCuePtr = 0
  For nArrayIndex = 1 To nArrayMax
    With gaCueMoveEtcInfo(nArrayIndex)
      If \nGrdAction = #SCS_WMC_GRDACTION_DELETED
        \nNewCuePtr = -1
      Else
        nNewCuePtr + 1
        \nNewCuePtr = nNewCuePtr
      EndIf
      
      If \nGrdAction = #SCS_WMC_GRDACTION_ADDED
        \sCue = sCueLabel
        ; create the next unique label
        nCounter = 0
        bFound = #True
        While (bFound) And (nCounter < 10000) ; prevent endless loop
          nCounter + 1
          sCueLabel = generateNextCueLabel(sCueLabel, nIncrement, fIncrement)
          bFound = #False
          For i = 1 To gnLastCue
            If UCase(aCue(i)\sCue) = UCase(sCueLabel)
              bFound = #True
              Break
            EndIf
          Next i
        Wend
        If bFound
          ; couldn't generate a new cue label
          sCueLabel = ""
        EndIf
      EndIf
      
    EndWith
  Next nArrayIndex
  
  With grWMC
    \nArrayMax = nArrayMax
  EndWith
  
  ClearGadgetItems(WMC\grdPreview)
  For nArrayIndex = 1 To nArrayMax
    With gaCueMoveEtcInfo(nArrayIndex)
      If \nGrdAction <> #SCS_WMC_GRDACTION_DELETED
        sText = \sCue + Chr(10) + \sPageNo + Chr(10) + \sCueType + Chr(10) + \sCueDescr
        AddGadgetItem(WMC\grdPreview, -1, sText)
      EndIf
    EndWith
  Next nArrayIndex
  ; commented out the autoFitGridCol() as it should only be needed first time, as called in WMC_resetGrid()
  ; autoFitGridCol(WMC\grdPreview, 2) ; autofit "Description" column
  
  If bChangedCueList
    SGT(WMC\lblPreview, Lang("WMC", "lblPreview2"))
    scsSetGadgetFont(WMC\lblPreview, #SCS_FONT_GEN_BOLD)
  Else
    SGT(WMC\lblPreview, Lang("WMC", "lblPreview1"))
    scsSetGadgetFont(WMC\lblPreview, #SCS_FONT_GEN_NORMAL)
  EndIf
  
  If nActionReqd = #SCS_WMC_ACTION_SEARCH
    WMC_searchColumns()
  Else
    WMC_setEnabledStates(bChangedCueList)
  EndIf
  
  grWMC\bChangesViewed = #True
  
EndProcedure

Procedure WMC_resetGrid()
  PROCNAMEC()
  Protected i
  Protected nArrayIndex, nArrayMax
  Protected sText.s
  
  debugMsg(sProcName, #SCS_START)
  
  nArrayIndex = 0
  For i = 1 To gnLastCue
    nArrayIndex + 1
    With gaCueMoveEtcInfo(nArrayIndex)
      \nOldCuePtr = i
      \nGrdAction = #SCS_WMC_GRDACTION_NO_CHANGE
      \sCue = aCue(i)\sCue
      \sPageNo = aCue(i)\sPageNo
      \sCueType = WMC_getCueType(i)
      \sCueDescr = aCue(i)\sCueDescr
;       debugMsg(sProcName, "gaCueMoveEtcInfo(" + nArrayIndex + ")\sCue=" + \sCue)
    EndWith
  Next i
  nArrayMax = nArrayIndex
  
  With grWMC
    \nArrayMax = nArrayMax
  EndWith
  
  ClearGadgetItems(WMC\grdPreview)
  For nArrayIndex = 1 To nArrayMax
    With gaCueMoveEtcInfo(nArrayIndex)
      sText = \sCue + Chr(10) + \sPageNo + Chr(10) + \sCueType + Chr(10) + \sCueDescr
;       debugMsg(sProcName, "nArrayIndex=" + nArrayIndex + ", sText=" + sText)
      AddGadgetItem(WMC\grdPreview,-1,sText)
    EndWith
  Next nArrayIndex
  autoFitGridCol(WMC\grdPreview, 2) ; autofit "Description" column
  
  SGT(WMC\lblPreview, Lang("WMC", "lblPreview1"))
  scsSetGadgetFont(WMC\lblPreview, #SCS_FONT_GEN_NORMAL)
  
  WMC_setEnabledStates(#False)
  
  grWMC\bChangesViewed = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMC_validateAction()
  PROCNAMEC()
  Protected nActionReqd, nFirstCue, nLastCue, nTargetCue
  Protected sCueLabel.s
  Protected sErrorMsg.s
  Protected nGadgetNo
  Protected i, j, k
  Protected i2
  Protected nNewCues
  Protected sMsgStart.s
  Static sCannotDeleteCue3.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sCannotDeleteCue3 = Lang("Errors", "CannotDeleteCue3")
    bStaticLoaded = #True
  EndIf
  
  With WMC
    nActionReqd = getCurrentItemData(\cboActionReqd)
    nFirstCue   = getCurrentItemData(\cboFirstCue, -1)
    nLastCue    = getCurrentItemData(\cboLastCue, -1)
    nTargetCue  = getCurrentItemData(\cboTargetCue, -1)
    sCueLabel   = Trim(GGT(\txtCueLabel))
    
    While #True ; dummy loop so we can use 'Break' to exit after an error
      If nFirstCue = -1
        sErrorMsg = LangPars("Errors", "MustBeSelected", GGT(\lblFirstCue))
        nGadgetNo = \cboFirstCue
        Break
      EndIf
      
      If nLastCue = -1
        sErrorMsg = LangPars("Errors", "MustBeSelected", GGT(\lblLastCue))
        nGadgetNo = \cboLastCue
        Break
      EndIf
      
      If nLastCue < nFirstCue
        sErrorMsg = LangPars("Errors", "NotLessThan", GGT(\lblLastCue), GGT(\lblFirstCue))
        nGadgetNo = \cboLastCue
        Break
      EndIf
      
      If (nActionReqd = #SCS_WMC_ACTION_COPY) Or (nActionReqd = #SCS_WMC_ACTION_MOVE)
        If nTargetCue = -1
          sErrorMsg = LangPars("Errors", "MustBeSelected", GGT(\lblTargetCue))
          nGadgetNo = \cboTargetCue
          Break
        EndIf
        If (nTargetCue >= nFirstCue) And (nTargetCue < nLastCue)  ; nb nTargetCue can be the same as nLastCue, to duplicate a range of cues
          sErrorMsg = LangPars("Errors", "MustNotBeBetween", GGT(\lblTargetCue), GGT(\lblFirstCue), GGT(\lblLastCue))
          nGadgetNo = \cboTargetCue
          Break
        EndIf
      EndIf
      
      If nActionReqd = #SCS_WMC_ACTION_COPY
        If Len(sCueLabel) = 0
          sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(\lblCueLabel))
          nGadgetNo = \txtCueLabel
          Break
        EndIf
        ; check the starting cue label not already in use in cues not included in this change
        For i = 1 To gnLastCue
          If UCase(sCueLabel) = UCase(aCue(i)\sCue)
            sErrorMsg = LangPars("WMC", "AlreadyInUse", sCueLabel)
            nGadgetNo = \txtCueLabel
            Break 2
          EndIf
        Next i
        
        nNewCues = nLastCue - nFirstCue + 1
        If (gnLastCue + nNewCues) > gnMaxCueIndex And gnMaxCueIndex >= 0
          sErrorMsg = LangPars("Errors", "CannotAddCues", Str(nNewCues))
          nGadgetNo = \cboLastCue
          Break
        EndIf
        
      EndIf
      
      Select nActionReqd
        Case #SCS_WMC_ACTION_DELETE
          nGadgetNo = \cboFirstCue
          debugMsg(sProcName, "nFirstCue=" + getCueLabel(nFirstCue) + ", nLastCue=" + getCueLabel(nLastCue))
          For i = nFirstCue To nLastCue
            ; sMsgStart = LangPars("Errors", "CannotDeleteCue3", aCue(i)\sCue)
            sMsgStart = ReplaceString(sCannotDeleteCue3, "$1", getCueLabel(i))
            If checkDelCueRI(i, sMsgStart, 0, #WMC) = #False
              If IsGadget(nGadgetNo)
                SAG(nGadgetNo)
              EndIf
              ProcedureReturn #False
            EndIf
          Next i
          
        Case #SCS_WMC_ACTION_SORT_ASC, #SCS_WMC_ACTION_SORT_DEC
      ;debugMsg(sProcName, "sErrorMsg=" + sErrorMsg)
          
      EndSelect
      
      Break
    Wend
    
    If sErrorMsg
      debugMsg(sProcName, "sErrorMsg=" + sErrorMsg)
      setMouseCursorNormal()
      scsMessageRequester(GGT(\lblActionReqd), sErrorMsg, #PB_MessageRequester_Error)
      If IsGadget(nGadgetNo)
        SAG(nGadgetNo)
      EndIf
      ProcedureReturn #False
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WMC_btnViewChanges_Click()
  PROCNAMEC()
  Protected bValidationResult, tmpVar.i
  
  debugMsg(sProcName, #SCS_START)
  setMouseCursorBusy()
  
  If ((getCurrentItemData(WMC\cboActionReqd) = #SCS_WMC_ACTION_SORT_ASC) Or (getCurrentItemData(WMC\cboActionReqd) = #SCS_WMC_ACTION_SORT_DEC)) And (WMC_rowIsSelected())
    DisableGadget(WMC\cboSearchCC, #SCS_HIDE_GADGET)
    bValidationResult = #True
  ElseIf getCurrentItemData(WMC\cboActionReqd) = #SCS_WMC_ACTION_SEARCH
    bValidationResult = #True
    WMC\nFirstSelectedCueIndex = WMC\nIdxSearchResultSelected
    WMC\nSecondSelectedCueIndex = WMC\nIdxSearchResultSelected
    SGS(WMC\cboFirstCue, WMC\nFirstSelectedCueIndex)
    SGS(WMC\cboLastCue, WMC\nSecondSelectedCueIndex)
  Else
    bValidationResult = WMC_validateAction()
    debugMsg(sProcName, "WMC_validateAction() returned " + strB(bValidationResult))
  EndIf
    
  If bValidationResult = #True
    debugMsg(sProcName, "calling WMC_loadGrid()")
    WMC_loadGrid()
  EndIf
  
  setMouseCursorNormal()
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMC_btnReset_Click()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  DisableGadget(WMC\cboSearchCC, #SCS_SHOW_GADGET)

  WMC_resetGrid()
  WMC_selectRowsForCueSelection()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMC_btnHelp_Click()
  displayHelpTopic("copy_range.htm")
EndProcedure

Procedure WMC_fcActionReqd()
  PROCNAMEC()
  Protected sActionReqd.s
  Protected bTargetCueReqd
  Protected bCueLabelReqd
  
  With grWMC
    \nActionReqd = getCurrentItemData(WMC\cboActionReqd)
    Select \nActionReqd
      Case #SCS_WMC_ACTION_COPY
        sActionReqd = \sCopied
        bTargetCueReqd = #True
        bCueLabelReqd = #True
        WMC_showHideSort(\nActionReqd)
        
      Case #SCS_WMC_ACTION_MOVE
        sActionReqd = \sMoved
        bTargetCueReqd = #True
        bCueLabelReqd = #False
        WMC_showHideSort(\nActionReqd)
        
      Case #SCS_WMC_ACTION_DELETE
        sActionReqd = \sDeleted
        bTargetCueReqd = #False
        bCueLabelReqd = #False
        WMC_showHideSort(\nActionReqd)
        
      Case #SCS_WMC_ACTION_SORT_ASC
        sActionReqd = \sSortedAsc
        bTargetCueReqd = #False
        bCueLabelReqd = #False
        grWMC\nSearchColumn = GetGadgetState(WMC\cboSearchCC)
        WMC_showHideSort(\nActionReqd)
        
      Case #SCS_WMC_ACTION_SORT_DEC
        sActionReqd = \sSortedDec
        bTargetCueReqd = #False
        bCueLabelReqd = #False
        grWMC\nSearchColumn = GetGadgetState(WMC\cboSearchCC)
        WMC_showHideSort(\nActionReqd)
        
      Case #SCS_WMC_ACTION_SEARCH
        sActionReqd = \sSearch
        bTargetCueReqd = #False
        bCueLabelReqd = #False
        WMC_showHideSort(\nActionReqd)
        
    EndSelect
    
    SGT(WMC\lblFirstCue, LangPars("WMC", "lblFirstCue", LCase(sActionReqd)))
    SGT(WMC\lblLastCue, LangPars("WMC", "lblLastCue", LCase(sActionReqd)))
    
    If bTargetCueReqd
      SGT(WMC\lblTargetCue, LangPars("WMC", "lblTargetCue", LCase(sActionReqd)))
      setVisible(WMC\lblTargetCue, #True)
      setVisible(WMC\cboTargetCue, #True)
    Else
      setVisible(WMC\lblTargetCue, #False)
      setVisible(WMC\cboTargetCue, #False)
    EndIf
    
    If bCueLabelReqd
      setVisible(WMC\lblCueLabel, #True)
      setVisible(WMC\txtCueLabel, #True)
      setVisible(WMC\lblCueNumberIncrement, #True)
      setVisible(WMC\txtCueNumberIncrement, #True)
    Else
      setVisible(WMC\lblCueLabel, #False)
      setVisible(WMC\txtCueLabel, #False)
      setVisible(WMC\lblCueNumberIncrement, #False)
      setVisible(WMC\txtCueNumberIncrement, #False)
    EndIf
    
  EndWith
  
EndProcedure

Procedure WMC_Form_Load()
  PROCNAMEC()
  Protected i, nComboBoxWidth, nOldXPosistion
  
  InitKeyboard()
  
  If IsWindow(#WMC) = #False
    createfmMultiCueCopyEtc()
  EndIf
  setFormPosition(#WMC, @grMultiCueCopyEtcWindow)
  
  With grWMC
    If Len(\sAdded) = 0
      \sAdded = Lang("WMC", "Added")
      \sCopied = Lang("WMC", "Copied")
      \sDeleted = Lang("WMC", "Deleted")
      \sMoved = Lang("WMC", "Moved")
      \sSortedAsc = Lang("WMC", "SortedAsc")
      \sSortedDec = Lang("WMC", "SortedDec")
      \sSearch = Lang("WMC", "Search")
      \sTopOfShow = Lang("Common", "TopOfShow")
    EndIf
  EndWith
  
  ClearGadgetItems(WMC\cboActionReqd)
  addGadgetItemWithData(WMC\cboActionReqd, Lang("WMC", "CopyCues"), #SCS_WMC_ACTION_COPY)
  addGadgetItemWithData(WMC\cboActionReqd, Lang("WMC", "MoveCues"), #SCS_WMC_ACTION_MOVE)
  addGadgetItemWithData(WMC\cboActionReqd, Lang("WMC", "DeleteCues"), #SCS_WMC_ACTION_DELETE)
  addGadgetItemWithData(WMC\cboActionReqd, Lang("WMC", "SortCuesAsc"), #SCS_WMC_ACTION_SORT_ASC)
  addGadgetItemWithData(WMC\cboActionReqd, Lang("WMC", "SortCuesDec"), #SCS_WMC_ACTION_SORT_DEC)
  addGadgetItemWithData(WMC\cboActionReqd, Lang("WMC", "SearchCues"), #SCS_WMC_ACTION_SEARCH)
  setGadgetItemByData(WMC\cboActionReqd, grWMC\nActionReqd, 0)
  setComboBoxWidth(WMC\cboActionReqd)

  ClearGadgetItems(WMC\cboSearchCC)
  addGadgetItemWithData(WMC\cboSearchCC, Lang("WMC","CueNo"), #SCS_WMC_ACTION_COLUMN_CUE_NUMBER)
  addGadgetItemWithData(WMC\cboSearchCC, Lang("Common","Page"), #SCS_WMC_ACTION_COLUMN_PAGE)
  addGadgetItemWithData(WMC\cboSearchCC, Lang("Common","CueType"), #SCS_WMC_ACTION_COLUMN_CUE_TYPE)
  addGadgetItemWithData(WMC\cboSearchCC, Lang("Common","Description"), #SCS_WMC_ACTION_COLUMN_DESCRIPTION)
  setGadgetItemByData(WMC\cboSearchCC, grWMC\nSearchCC, 0)
  
  nOldXPosistion = 143      ; This has to be a fixed from windows.pbi number otherwise because we are aligning it to the right it will drift each time the panel is opened.
  nComboBoxWidth = setComboBoxWidth(WMC\cboSearchCC)
  
  If nComboBoxWidth < 120
    ResizeGadget(WMC\cboSearchCC, nOldXPosistion + (120 - nComboBoxWidth), 33, nComboBoxWidth, 21) ; width was 120
  EndIf
  
  SGT(WMC\lblSearchCount, LangPars("WMC", "lblSearchCount", "0", "0"))  
  HideGadget(WMC\lblSearchCount, #SCS_SHOW_GADGET)
  HideGadget(WMC\btnReset, #SCS_SHOW_GADGET)
  WMC_fcActionReqd()
  
  If gnLastCue > 0
    ; Redim gaCueMoveEtcInfo large enough to hold twice the number of cues, enabling user to copy entire cue list
    ReDim gaCueMoveEtcInfo((gnLastCue+2)<<1)
  EndIf
  
  ClearGadgetItems(WMC\cboFirstCue)
  ClearGadgetItems(WMC\cboLastCue)
  ClearGadgetItems(WMC\cboTargetCue)
  addGadgetItemWithData(WMC\cboTargetCue, grWMC\sTopOfShow, 0)
  WMC\nFirstSelectedCueIndex = -1
  WMC\nSecondSelectedCueIndex = -1
  
  For i = 1 To gnLastCue
    addGadgetItemWithData(WMC\cboFirstCue, buildCueForCBO(i, "", #True), i)
    addGadgetItemWithData(WMC\cboLastCue, buildCueForCBO(i, "", #True), i)
    addGadgetItemWithData(WMC\cboTargetCue, buildCueForCBO(i, "", #True), i)
  Next i
  SGS(WMC\cboFirstCue, -1)
  SGS(WMC\cboLastCue, -1)
  SGS(WMC\cboTargetCue, -1)
  
  ; force 'new cue number...' to upper case if required
  setUpperCase(WMC\txtCueLabel, grProd\bLabelsUCase)
  SAG(WMC\txtCueLabel)
  
  WMC_resetGrid()
  DisableGadget(WMC\btnPrev, #SCS_HIDE_GADGET)
  DisableGadget(WMC\btnNext, #SCS_HIDE_GADGET)
  
  setWindowVisible(#WMC, #True)
  
EndProcedure

Procedure WMC_cboActionReqd_Click()
  ; PROCNAMEC()
  
  WMC_fcActionReqd()
EndProcedure

Procedure WMC_applyCueChanges()
  PROCNAMEC()
  Protected nActionReqd, nFirstCue, nLastCue, nTargetCue
  Protected sCueLabel.s
  Protected nIncrement
  Protected i, j, k, n
  Protected h
  Protected i2, j2, k2
  Protected nArrayIndex
  Protected Dim aCueTmp.tyCue(0)
  Protected Dim aSubTmp.tySub(0)
  Protected Dim aAudTmp.tyAud(0)
  Protected bFirstSubForCue, bFirstAudForSub
  Protected nPrevSubIndex, nPrevAudIndex
  Protected nLastSubIndex, nLastAudIndex
  Protected sUndoDescr.s
  Protected nNodeKey
  Protected u1, u2, u3, u4
  Protected nFileDataPtr
  
  debugMsg(sProcName, #SCS_START)
  
  With grWMC
    If \nArrayMax < 1
      ProcedureReturn #True
    EndIf
    If \bChangesViewed = #False
      scsMessageRequester(GGT(WMC\lblActionReqd), Lang("WMC", "OKNotReady"), #PB_MessageRequester_Ok|#MB_ICONEXCLAMATION)
      ProcedureReturn #False  ; #False indicates window is not to be closed
    EndIf
  EndWith
  
  debugMsg(sProcName, "calling stopEverythingPart1(-1, #False, #False)")
  stopEverythingPart1(-1, #False, #False)
  
  setMouseCursorBusy()
  
  ; debugMsg(sProcName, "calling debugCuePtrs()")
  ; debugCuePtrs()
  
  ReDim aCueTmp(ArraySize(aCue()))
  ReDim aSubTmp(ArraySize(aSub()))
  ReDim aAudTmp(ArraySize(aAud()))
  
  For nArrayIndex = 1 To grWMC\nArrayMax
    With gaCueMoveEtcInfo(nArrayIndex)
      debugMsg(sProcName, "gaCueMoveEtcInfo(" + nArrayIndex + ")\nGrdAction=" + WMC_decodeGrdActionL(\nGrdAction) + ", \sCue=" + \sCue + ", \nOldCuePtr=" + \nOldCuePtr + ", \nNewCuePtr=" + \nNewCuePtr)
      Select \nGrdAction
        Case #SCS_WMC_GRDACTION_NO_CHANGE, #SCS_WMC_GRDACTION_ADDED, #SCS_WMC_GRDACTION_MOVED, #SCS_WMC_GRDACTION_SORTED_ASC, #SCS_WMC_GRDACTION_SORTED_DEC
          i = \nOldCuePtr
          If i > 0
            i2 + 1
            If i2 > ArraySize(aCueTmp())
              ReDim aCueTmp(i2+20)
            EndIf
            aCueTmp(i2) = aCue(i)
            ; aCueTmp(i2)\nCueId = i2
            gnUniqueCueId + 1
            aCueTmp(i2)\nCueId = gnUniqueCueId
            gnNodeId + 1
            aCueTmp(i2)\nNodeKey = gnNodeId
            aCueTmp(i2)\sCue = \sCue
            aCueTmp(i2)\sPageNo = \sPageNo
            j = aCue(i)\nFirstSubIndex
            bFirstSubForCue = #True
            nPrevSubIndex = -1
            While j >= 0
              j2 + 1
              If j2 > ArraySize(aSubTmp())
                ReDim aSubTmp(j2+20)
              EndIf
              aSubTmp(j2) = aSub(j)
              ; aSubTmp(j2)\nSubId = j2
              gnUniqueSubId + 1
              aSubTmp(j2)\nSubId = gnUniqueSubId
              gnNodeId + 1
              aSubTmp(j2)\nNodeKey = gnNodeId
              aSubTmp(j2)\nSubRef = grSubDef\nSubRef
              debugMsg(sProcName, "aSubTmp(" + aSubTmp(j2)\sSubLabel + ")\nSubRef=" + aSubTmp(j2)\nSubRef)
              aSubTmp(j2)\nCueIndex = i2
              aSubTmp(j2)\sCue = \sCue
              aSubTmp(j2)\nPrevSubIndex = nPrevSubIndex
              If aSub(j)\nNextSubIndex >= 0
                aSubTmp(j2)\nNextSubIndex = j2 + 1
              EndIf
              aSubTmp(j2)\sPlayOrder = grSubDef\sPlayOrder
              aSubTmp(j2)\nFirstPlayIndex = grSubDef\nFirstPlayIndex
              If bFirstSubForCue
                aCueTmp(i2)\nFirstSubIndex = j2
                bFirstSubForCue = #False
              EndIf
              aSubTmp(j2)\nLCSubRef = grSubDef\nLCSubRef
              ; debugMsg(sProcName, "aSubTmp(" + getSubLabel(j2) + ")\nLCSubRef=" + aSubTmp(j2)\nLCSubRef)
              For h = 0 To #SCS_MAX_SFR
                aSubTmp(j2)\nSFRSubRef[h] = grSubDef\nSFRSubRef[h]
              Next h
              If aSub(j)\bSubTypeHasAuds
                k = aSub(j)\nFirstAudIndex
                bFirstAudForSub = #True
                nPrevAudIndex = -1
                While k >= 0
                  k2 + 1
                  If k2 > ArraySize(aAudTmp())
                    ReDim aAudTmp(k2+20)
                  EndIf
                  aAudTmp(k2) = aAud(k)
                  ; aAudTmp(k2)\nAudId = k2
                  gnUniqueAudId + 1
                  aAudTmp(k2)\nAudId = gnUniqueAudId
                  aAudTmp(k2)\nCueIndex = i2
                  aAudTmp(k2)\sCue = \sCue
                  aAudTmp(k2)\nSubIndex = j2
                  aAudTmp(k2)\nPrevAudIndex = nPrevAudIndex
                  If aAud(k)\nNextAudIndex >= 0
                    aAudTmp(k2)\nNextAudIndex = k2 + 1
                  EndIf
                  aAudTmp(k2)\nPrevPlayIndex = grAudDef\nPrevPlayIndex
                  aAudTmp(k2)\nNextPlayIndex = grAudDef\nNextPlayIndex
                  aAudTmp(k2)\nPlayNo = grAudDef\nPlayNo
                  ; added 25Jan2017 11.5.4 (R Borsey)
                  nFileDataPtr = aAudTmp(k2)\nFileDataPtr
                  If nFileDataPtr >= 0
                    If ArraySize(gaFileData()) <= gnLastFileData
                      REDIM_ARRAY(gaFileData, gnLastFileData+20, grFileDataDef, "gaFileData()")
                      debugMsg(sProcName, "ArraySize(gaFileData())=" + ArraySize(gaFileData()))
                    EndIf
                    gnLastFileData + 1
                    gaFileData(gnLastFileData) = gaFileData(nFileDataPtr)
                    aAudTmp(k2)\nFileDataPtr = gnLastFileData
                  EndIf
                  For n = 0 To #SCS_MAX_CTRL_SEND
                    If aSubTmp(j2)\aCtrlSend[n]\nAudPtr = k
                      debugMsg(sProcName, "calling aSubTmp(" + getSubLabel(j2) + ")\aCtrlSend[" + n + "]\nAudPtr from " + getAudLabel(k) + " To " + getAudLabel(k2))
                      aSubTmp(j2)\aCtrlSend[n]\nAudPtr = k2
                    EndIf
                  Next n
                  ; end added 25Jan2017 11.5.4 (R Borsey)
                  If bFirstAudForSub
                    aSubTmp(j2)\nFirstAudIndex = k2
                    bFirstAudForSub = #False
                  EndIf
                  nPrevAudIndex = k2
                  k = aAud(k)\nNextAudIndex
                Wend
              EndIf
              nPrevSubIndex = j2
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
      EndSelect
    EndWith
  Next nArrayIndex
  
  sUndoDescr = GGT(WMC\cboActionReqd)
  u1 = preChangeProdL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_MULTI_CUE_COPY_ETC, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, grProd\nProdId)
  debugMsg(sProcName, "preChangeProdL returned " + Str(u1))
  
  For i = gnLastCue To 1 Step -1
    u2 = preChangeCueL(#True, "Delete Cue " + getCueLabel(i), i, #SCS_UNDO_ACTION_DELETE)
    debugMsg(sProcName, getCueLabel(i) + " preChangeCueL returned " + Str(u2))
    j = aCue(i)\nFirstSubIndex
    nLastSubIndex = j
    While j >= 0
      nLastSubIndex = j
      j = aSub(j)\nNextSubIndex
    Wend
    j = nLastSubIndex
    While j >= 0
      u3 = preChangeSubL(#True, "Delete Sub " + getSubLabel(j), j, #SCS_UNDO_ACTION_DELETE)
      debugMsg(sProcName, getSubLabel(j) + " preChangeSubL returned " + Str(u3))
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        nLastAudIndex = k
        While k >= 0
          nLastAudIndex = k
          k = aAud(k)\nNextAudIndex
        Wend
        k = nLastAudIndex
        While k >= 0
          u4 = preChangeAudL(#True, "Delete Aud " + getAudLabel(k), k, #SCS_UNDO_ACTION_DELETE)
          debugMsg(sProcName, getAudLabel(k) + " preChangeAudL returned " + Str(u4))
          postChangeAudL(u4, #False, -1)
          k = aAud(k)\nPrevAudIndex
        Wend
      EndIf
      postChangeSubL(u3, #False, -1)
      j = aSub(j)\nPrevSubIndex
    Wend
    postChangeCueL(u2, #False, -1)
  Next i
  
  debugMsg(sProcName, "reload arrays")
  
  gnLastCue = i2
  gnLastSub = j2
  gnLastAud = k2
  
  ReDim aCue(ArraySize(aCueTmp()))
  ReDim aSub(ArraySize(aSubTmp()))
  ReDim aAud(ArraySize(aAudTmp()))
  
  For i = 1 To gnLastCue
    aCue(i) = aCueTmp(i)
  Next i
  For j = 1 To gnLastSub
    aSub(j) = aSubTmp(j)
  Next j
  For k = 1 To gnLastAud
    aAud(k) = aAudTmp(k)
  Next k
  
  gnCueEnd = gnLastCue + 1
  aCue(gnCueEnd) = grCueDef
  
  ; debugMsg(sProcName, "calling debugCuePtrs()")
  ; debugCuePtrs()
  setCuePtrs(#False)
  
  For i = 1 To gnLastCue
    setLabels(i)
    setCueState(i)
  Next i
  
  For i = 1 To gnLastCue
    u2 = preChangeCueL(#True, "Add Cue " + getCueLabel(i), -1, #SCS_UNDO_ACTION_ADD_CUE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aCue(i)\nCueId)
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      u3 = preChangeSubL(#True, "Add Sub " + getSubLabel(j), -1, #SCS_UNDO_ACTION_ADD_SUB, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aSub(j)\nSubId)
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          u4 = preChangeAudL(#True, "Add Aud " + getAudLabel(k), -1, #SCS_UNDO_ACTION_ADD_AUD, -1, 0, aAud(k)\nAudId)
          postChangeAudL(u4, #False, k)
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      postChangeSubL(u3, #False, j)
      j = aSub(j)\nNextSubIndex
    Wend
    postChangeCueL(u2, #False, i)
  Next i
  
  debugMsg(sProcName, "calling postChangeProdL(" + Str(u1) + ", #False)")
  postChangeProdL(u1, #False)
  
  debugMsg(sProcName, "calling loadArrayCueOrSubForMTC()")
  loadArrayCueOrSubForMTC()
  
  ; debugUndoArrays()
  
  debugMsg(sProcName, "calling WMN_loadHotkeyPanel()")
  WMN_loadHotkeyPanel()
  
  nEditCuePtr = -1
  nEditSubPtr = -1
  setEditAudPtr(-1)
  
  If nEditCuePtr >= 0
    nNodeKey = aCue(nEditCuePtr)\nNodeKey
  Else
    nNodeKey = grProd\nNodeKey
  EndIf
  redoCueListTree(nNodeKey)
  
  ; WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
  WED_setEditorButtons()
  
  ; modified the following 29May2019 11.8.1.1 following bug emailed by Michel Winogradoff
  ; previously was just
  ;   gbCallPopulateGrid = #True
  ;   gbCallLoadDispPanels = #True
  ; but in Michel's run it appears the grid was not refreshed quickly enough, so Michel clicked on an item beyong the end of the new list (having deleted many cues)
  ; and this through a memory error due to the cue ptr being -1 in a procedure that wasn't expecting this
  If gnThreadNo > #SCS_THREAD_MAIN
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
  Else
    ; carry out the following immediately instead of deferring
    populateGrid()
    PNL_loadDispPanels()
  EndIf
  ; end modified the following 29May2019 11.8.1.1
  
  gnCueToGo = 0
  gnRowToGo = -1
  gnStandbyCuePtr = -1
  gnCallOpenNextCues = 0
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  
  ; resume threads stopped by stopEverything()
  debugMsg(sProcName, "resume threads")
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
  debugMsg(sProcName, "calling debugCuePtrs()")
  debugCuePtrs()
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WMC_Form_Show(bModal=#False)
  WMC_Form_Load()
  setWindowModal(#WMC, bModal)
  setWindowVisible(#WMC, #True)
  SetActiveWindow(#WMC)
EndProcedure

Procedure WMC_Form_Unload()
  getFormPosition(#WMC, @grMultiCueCopyEtcWindow)
  unsetWindowModal(#WMC)
  ; modified 23Aug2019 11.8.2af - changed 'close window' to 'hide window' because if the form is called at all then it is likely the form will be called multiple times in the run
  ; scsCloseWindow(#WMC)
  HideWindow(#WMC, #True)
EndProcedure

Procedure WMC_txtCueNumberIncrement_Validate()
  PROCNAMEC()
  ; Changed 4Jan2022 11.9ad following Forum request from 'Geoff' to allow increment of 0.1
  Protected sCueNumberIncrement.s, fMyCueNumberIncrement.f
  
  sCueNumberIncrement = Trim(GGT(WMC\txtCueNumberIncrement))
  If sCueNumberIncrement
    If IsNumeric(sCueNumberIncrement) = #False
      fMyCueNumberIncrement = -1
    Else
      fMyCueNumberIncrement = ValF(sCueNumberIncrement)
    EndIf
    If fMyCueNumberIncrement <= 0.0
      scsMessageRequester(GWT(#WMC), LangPars("Errors", "MustBeGreaterThan", GGT(WMC\lblCueNumberIncrement), "0"))
      ProcedureReturn #False
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WMC_setRangeStartByLeftButtonClick()
  PROCNAMEC()
  Protected n
  
EndProcedure

Procedure WMC_btnNextSearchResult()
  With WMC
    If \cntSearchResults
      SelectElement(\nRowSelectors(), \nIdxSearchResultSelected)
      SetGadgetItemState(\grdPreview, \nRowSelectors(), 0)
      \nIdxSearchResultSelected + 1
    
      If \nIdxSearchResultSelected >= \cntSearchResults
        \nIdxSearchResultSelected = 0
      EndIf
      SelectElement(\nRowSelectors(), \nIdxSearchResultSelected)
      SetGadgetItemState(\grdPreview, \nRowSelectors(), #PB_ListIcon_Selected)
      SGS(\grdPreview, \nRowSelectors()) ; sets the vertical scroll position
      SGT(\lblSearchCount, LangPars("WMC", "lblSearchCount", Str(\nIdxSearchResultSelected + 1), Str(\cntSearchResults)))
      \nFirstSelectedCueIndex = \nIdxSearchResultSelected
      \nSecondSelectedCueIndex = \nIdxSearchResultSelected
      SGS(\cboFirstCue, \nFirstSelectedCueIndex)
      SGS(\cboLastCue, \nSecondSelectedCueIndex)
    
      SAG(\grdPreview)
    EndIf
  EndWith
EndProcedure

Procedure WMC_btnPreviousSearchResult()
  With WMC
    If \cntSearchResults
      SelectElement(\nRowSelectors(), \nIdxSearchResultSelected)
      SetGadgetItemState(\grdPreview, \nRowSelectors(), 0)
      If \nIdxSearchResultSelected = 0
        \nIdxSearchResultSelected = (\cntSearchResults - 1)
      Else
        \nIdxSearchResultSelected - 1
      EndIf
      SelectElement(\nRowSelectors(), \nIdxSearchResultSelected)
      SetGadgetItemState(\grdPreview, \nRowSelectors(), #PB_ListIcon_Selected)
      SGS(\grdPreview, \nRowSelectors()) ; sets the vertical scroll position
      SGT(\lblSearchCount, LangPars("WMC", "lblSearchCount", Str(\nIdxSearchResultSelected + 1), Str(\cntSearchResults)))
      SetActiveGadget(\grdPreview)
    EndIf
  EndWith
EndProcedure

Procedure WMC_EventHandler()
  PROCNAMEC()
  Protected j, n
  
  With WMC
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WMC_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel
            WMC_Form_Unload()
            
          Case \btnHelp
            displayHelpTopic("copy_range.htm")
            
          Case \btnNext
            WMC_btnNextSearchResult()
            
          Case \btnPrev
            WMC_btnPreviousSearchResult()
            
          Case \btnOK
            If WMC_applyCueChanges()
              WMC_Form_Unload()
            EndIf
            
          Case \btnReset
            WMC_btnReset_Click()
            
          Case \btnViewChanges
            WMC_btnViewChanges_Click()
            
          Case \cboActionReqd
            If gnEventType = #PB_EventType_Change
              WMC_cboActionReqd_Click()
              SetActiveGadget(WMC\grdPreview)
            EndIf
            
          Case \cboFirstCue
            WMC_selectRowsFromGadgets()
            
          Case \cboLastCue
            WMC_selectRowsFromGadgets()
            
          Case \cboTargetCue
            ; no action required
            
          Case \grdPreview
            ; added 5Nov2016 11.5.2.4 as an alternmative to disabling \grdPreview, because that also disables scrolling (see forum posting "Copy, Move or Delete View Changes Not Scollable")
            If getEnabled(\cboActionReqd) = #False
              If GGS(\grdPreview) >= 0
                SGS(\grdPreview, -1)
                SAG(-1)
              EndIf
            ; end added 5Nov2016 11.6.0
            ElseIf (gnEventType = #PB_EventType_LeftClick) And (ShiftKeyDown() = #False)
              \nFirstSelectedCueIndex = WMC_rowFirstLastSelected(#True)
              \nSecondSelectedCueIndex = \nFirstSelectedCueIndex
              WMC_selectRowsForCueSelection()
            ElseIf (gnEventType = #PB_EventType_LeftClick) And (ShiftKeyDown())
              \nSecondSelectedCueIndex = WMC_rowFirstLastSelected(#False)
              WMC_selectRowsForCueSelection()
            EndIf
            
          Case \txtCueLabel
            ; no action required
            
          Case \txtCueNumberIncrement
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WMC_txtCueNumberIncrement_Validate())
            EndIf
            
          Case \cboSearchCC
            If grWMC\nSearchColumn <> GetGadgetState(WMC\cboSearchCC)
              grWMC\nSearchColumn = GetGadgetState(WMC\cboSearchCC)
              \cntSearchResults = 0       ; search is no longer valid 
              DisableGadget(WMC\btnPrev, #SCS_HIDE_GADGET)
              DisableGadget(WMC\btnNext, #SCS_HIDE_GADGET)
              SGT(WMC\lblSearchCount, LangPars("WMC", "lblSearchCount", "0", "0"))
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure.s WMC_makeSortKeyItem(sItem.s, nPartLength, nItemLength)
  PROCNAMEC()
  Protected sSortKeyItem.s, sWorkPart.s, n, sChar.s, sThisPart.s
  Static sNumeric.s, sAlpha.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sNumeric = "0123456789"
    sAlpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ; see https://en.wikipedia.org/wiki/List_of_Unicode_characters for info on Latin letters, etc
    For n = $C0 To $FF
      Select n
        Case $D7, $F7
          ; ignore multiplication sign and division sign
        Default
          ; include Latin letters
          sAlpha + Chr(n)
      EndSelect
    Next n
    debugMsg(sProcName, "sAlpha=" + #DQUOTE$ + sAlpha + #DQUOTE$)
    ; debugMsg(sProcName, "sAlpha=" + #DQUOTE$ + UCase(sAlpha) + #DQUOTE$)
    bStaticLoaded = #True
  EndIf
  
  sWorkPart = Trim(UCase(sItem))
  If sWorkPart
    n = 1
    While n <= Len(sWorkPart)
      sChar = Mid(sWorkPart, n, 1)
      
      If FindString(sNumeric, sChar) > 0
        sThisPart = ""
        While n <= Len(sWorkPart)
          sChar = Mid(sWorkPart, n, 1)
          If FindString(sNumeric, sChar) > 0
            sThisPart + sChar
          Else
            Break
          EndIf
          n + 1
        Wend
        sSortKeyItem + RSet(sThisPart, nPartLength, "0")
        
      ElseIf FindString(sAlpha, sChar) > 0
        sThisPart = ""
        While n <= Len(sWorkPart)
          sChar = Mid(sWorkPart, n, 1)
          If FindString(sAlpha, sChar) > 0
            sThisPart + sChar
          Else
            Break
          EndIf 
          n + 1
        Wend
        sSortKeyItem + Trim(sThisPart)
        
      Else
        sSortKeyItem + sChar
        n + 1
      EndIf
    Wend
  EndIf
  
  ProcedureReturn Trim(sSortKeyItem)
  
EndProcedure

Procedure.s WMC_makeCueSortKey(pCuePtr, nPartLength, nItemLength)
  PROCNAMECQ(pCuePtr)
  Protected sCueSortKey.s
  Protected nSortType
  
  nSortType = grWMC\nSearchColumn
  ; nb do not use 'space' between the items or that may get removed by a Trim()
  
  With aCue(pCuePtr)
    Select nSortType
      Case 0
        sCueSortKey = WMC_makeSortKeyItem(\sCue, nPartLength, nItemLength) + "-" + WMC_makeSortKeyItem(\sCue, nPartLength, nItemLength)
        
      Case 1
        sCueSortKey = WMC_makeSortKeyItem(\sPageNo, nPartLength, nItemLength) + "-" + WMC_makeSortKeyItem(\sCue, nPartLength, nItemLength)
        
      Case 2
        sCueSortKey = WMC_makeSortKeyItem(WMC_getCueType(pCuePtr), nPartLength, nItemLength) + "-" + WMC_makeSortKeyItem(\sCue, nPartLength, nItemLength)
        
      Case 3  
        sCueSortKey = WMC_makeSortKeyItem(aCue(pCuePtr)\sCueDescr, nPartLength, nItemLength) + "-" + WMC_makeSortKeyItem(\sCue, nPartLength, nItemLength)
        
    EndSelect
  EndWith
  
  ProcedureReturn sCueSortKey
EndProcedure

Procedure WMC_showHideSort(nShowOrHide)
  Select nShowOrHide
    Case #SCS_WMC_ACTION_COPY, #SCS_WMC_ACTION_MOVE, #SCS_WMC_ACTION_DELETE
      HideGadget(WMC\lblSearchCC, #SCS_HIDE_GADGET)
      HideGadget(WMC\cboSearchCC, #SCS_HIDE_GADGET)
      HideGadget(WMC\lblSearchTextCC, #SCS_HIDE_GADGET)
      HideGadget(WMC\txtSearchTextCC, #SCS_HIDE_GADGET)
      HideGadget(WMC\lblFirstCue, #SCS_SHOW_GADGET)
      HideGadget(WMC\cboFirstCue, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblLastCue, #SCS_SHOW_GADGET)
      HideGadget(WMC\cboLastCue, #SCS_SHOW_GADGET)
      SGT(WMC\btnViewChanges, Lang("WMC","btnViewChanges"))
      DisableGadget(WMC\btnViewChanges, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblSearchCount, #SCS_SHOW_GADGET)
      HideGadget(WMC\btnReset, #SCS_SHOW_GADGET)
      
    Case #SCS_WMC_ACTION_SORT_ASC, #SCS_WMC_ACTION_SORT_DEC
      HideGadget(WMC\lblSearchCC, #SCS_SHOW_GADGET)
      HideGadget(WMC\cboSearchCC, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblSearchTextCC, #SCS_HIDE_GADGET)
      HideGadget(WMC\txtSearchTextCC, #SCS_HIDE_GADGET)
      HideGadget(WMC\lblFirstCue, #SCS_SHOW_GADGET)
      HideGadget(WMC\cboFirstCue, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblLastCue, #SCS_SHOW_GADGET)
      HideGadget(WMC\cboLastCue, #SCS_SHOW_GADGET)
      SGT(WMC\btnViewChanges, Lang("WMC","btnViewChanges"))
      DisableGadget(WMC\btnViewChanges, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblSearchCount, #SCS_SHOW_GADGET)
      HideGadget(WMC\btnReset, #SCS_SHOW_GADGET)
      
    Case #SCS_WMC_ACTION_SEARCH
      HideGadget(WMC\lblSearchCC, #SCS_SHOW_GADGET)
      HideGadget(WMC\cboSearchCC, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblSearchTextCC, #SCS_SHOW_GADGET)
      HideGadget(WMC\txtSearchTextCC, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblFirstCue, #SCS_HIDE_GADGET)
      HideGadget(WMC\cboFirstCue, #SCS_HIDE_GADGET)
      HideGadget(WMC\lblLastCue, #SCS_HIDE_GADGET)
      HideGadget(WMC\cboLastCue, #SCS_HIDE_GADGET)
      SGT(WMC\btnViewChanges, Lang("WMC","btnViewChanges2"))
      DisableGadget(WMC\btnViewChanges, #SCS_SHOW_GADGET)
      HideGadget(WMC\lblSearchCount, #SCS_SHOW_GADGET)
      HideGadget(WMC\btnReset, #SCS_HIDE_GADGET)
      WMC_setEnabledStates(#False)
  EndSelect
EndProcedure

; EOF