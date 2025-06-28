; File: fmFind.pbi

EnableExplicit

Procedure WFI_saveFindItem()
  PROCNAMEC()
  
  gnMaxFindIndex + 1
  If gnMaxFindIndex > ArraySize(gaFind())
    ReDim gaFind(gnMaxFindIndex+20)
  EndIf
  gaFind(gnMaxFindIndex) = grWFI\rFindItem
  
EndProcedure

Procedure WFI_loadFindArray()
  PROCNAMEC()
  Protected i, j, k
  Protected bAudVidOnly
  Protected bFullPathNames
  Protected bItemSaved
  
  If ArraySize(gaFind()) < gnLastCue
    ReDim gaFind(gnLastCue) ; nb just an initial size - may grow larger
  EndIf
  gnMaxFindIndex = -1
  
  If GGS(WFI\optAudVidOnly)
    bAudVidOnly = #True
  EndIf
  
  If GGS(WFI\chkFullPathNames) = #PB_Checkbox_Checked
    bFullPathNames = #True
  Else
    bFullPathNames = #False
  EndIf
  
  With grWFI\rFindItem
    For i = 1 To gnLastCue
      If (bAudVidOnly = #False) Or ((bAudVidOnly) And ((aCue(i)\bSubTypeAorF) Or (aCue(i)\bSubTypeP)))
        \nCuePtr = i
        \sCue = aCue(i)\sCue
        \sPageNo = aCue(i)\sPageNo
        \sMidiCue = aCue(i)\sMidiCue
        \sDescr = aCue(i)\sCueDescr
        \sWhenReqd =aCue(i)\sWhenReqd
        If aCue(i)\bHotkey
          \sHotkeyLabel = aCue(i)\sHotkeyLabel
        Else
          \sHotkeyLabel = ""
        EndIf
        \sFileName = ""
        bItemSaved = #False
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If (bAudVidOnly = #False) Or ((bAudVidOnly) And (aSub(j)\bSubTypeHasAuds))
            If aSub(j)\sSubDescr <> \sDescr
              If bItemSaved = #False
                WFI_saveFindItem()
              EndIf
              \sDescr = aSub(j)\sSubDescr
            EndIf
            If aSub(j)\bSubTypeHasAuds
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                If bFullPathNames
                  \sFileName = aAud(k)\sFileName
                Else
                  \sFileName = GetFilePart(aAud(k)\sFileName)
                EndIf
                WFI_saveFindItem()
                bItemSaved = #True
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If bItemSaved = #False
          WFI_saveFindItem()
        EndIf
      EndIf
    Next i
  EndWith
EndProcedure

Procedure WFI_loadGrid()
  PROCNAMEC()
  Protected sFind.s
  Protected n
  Protected nFirstIndex
  Protected nColNo
  Protected sItemText.s, sColText.s
  
  ClearGadgetItems(WFI\grdFindResults)
  
  sFind = LCase(Trim(GGT(WFI\txtFind)))
  nFirstIndex = -1
  If sFind
    For n = 0 To gnMaxFindIndex
      With gaFind(n)
        If (FindString(LCase(\sCue), sFind)) Or (FindString(LCase(\sDescr), sFind)) Or (FindString(LCase(\sFileName), sFind)) Or (FindString(LCase(\sMidiCue), sFind)) Or (FindString(LCase(\sPageNo), sFind)) Or (FindString(LCase(\sHotkeyLabel), sFind)) Or
           (FindString(LCase(\sWhenReqd), sFind))
          sItemText = ""
          For nColNo = 0 To grWFI\nMaxColNo
            Select nColNo
              Case grWFI\nColCue
                sColText = \sCue
              Case grWFI\nColPage
                sColText = \sPageNo
              Case grWFI\nColMidiCue
                sColText = \sMidiCue
              Case grWFI\nColDescr
                sColText = \sDescr
              Case grWFI\nColWhenReqd
                sColText = \sWhenReqd
              Case grWFI\nColFile
                sColText = \sFileName
            EndSelect
            sItemText + sColText
            If nColNo < grWFI\nMaxColNo
              sItemText + Chr(10)
            EndIf
          Next nColNo
          addGadgetItemWithData(WFI\grdFindResults, sItemText, n)
          If nFirstIndex = -1
            nFirstIndex = n
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
  
  If CountGadgetItems(WFI\grdFindResults) > 0
    If GGS(WFI\grdFindResults) < 0
      SGS(WFI\grdFindResults, 0)
    EndIf
  EndIf
  
EndProcedure

Procedure WFI_setButtons()
  PROCNAMEC()
  Protected nIndex
  
  With WFI
    nIndex = getCurrentItemData(\grdFindResults, -1)
    If nIndex >= 0
      grWFI\nSelectedCuePtr = gaFind(nIndex)\nCuePtr
    Else
      grWFI\nSelectedCuePtr = -1
    EndIf
    If grWFI\nSelectedCuePtr >= 0
      SGT(\btnSelect, LangPars("WFI", "btnSelect", getCueLabel(grWFI\nSelectedCuePtr)))
      setEnabled(\btnSelect, #True)
    Else
      SGT(\btnSelect, Trim(LangPars("WFI", "btnSelect", "")))
      setEnabled(\btnSelect, #False)
    EndIf
  EndWith
EndProcedure

Procedure WFI_txtFind_Change()
  PROCNAMEC()
  
  WFI_loadGrid()
  WFI_setButtons()
  
EndProcedure

Procedure WFI_txtFind_Validate()
  ; Added 30Sep2022 11.9.6
  ; no processing required
  ProcedureReturn #True
EndProcedure

Procedure WFI_btnSelect_Click()
  PROCNAMEC()
  Protected bCalcCueStartValues
  
  With grWFI
    If \nSelectedCuePtr >= 0
      Select \nParentWindow
        Case #WMN
          If grProd\bDoNotCalcCueStartValues = #False
            bCalcCueStartValues = #True
          EndIf
          samAddRequest(#SCS_SAM_GOTO_CUE, grWFI\nSelectedCuePtr, 0, bCalcCueStartValues)
        Case #WED
          gnClickThisNode = aCue(\nSelectedCuePtr)\nNodeKey
          ; debugMsg(sProcName, "gnClickThisNode=" + gnClickThisNode)
      EndSelect
      WFI_Form_Unload()
    EndIf
  EndWith
  
EndProcedure

Procedure WFI_Form_Show(bModal, nParentWindow)
  PROCNAMEC()
  Protected i
  Protected bPageFound, bMidiCueFound, bWhenReqdFound
  Static bFirstTime, bPrevPageFound, bPrevMidiCueFound, bPrevWhenReqdFound
  Protected bRecreateGrid
  Protected nColNo
  
  If (IsWindow(#WFI) = #False) Or (gaWindowProps(#WFI)\nParentWindow <> nParentWindow)
    createfmFind(nParentWindow)
    bFirstTime = #True
  EndIf
  setFormPosition(#WFI, @grFindWindow)
  setWindowModal(#WFI, bModal)
  
  For i = 1 To gnLastCue
    With aCue(i)
      If Trim(\sPageNo)
        bPageFound = #True
      EndIf
      If Trim(\sMidiCue)
        bMidiCueFound = #True
      EndIf
      If Trim(\sWhenReqd)
        bWhenReqdFound = #True
      EndIf
    EndWith
  Next i
  If bFirstTime
    bRecreateGrid = #True ; need to 'recreate' the grid first time as the columns created in createfmFind() may be wrong
    bFirstTime = #False
  Else
    If (bPageFound <> bPrevPageFound) Or (bMidiCueFound <> bPrevMidiCueFound) Or (bWhenReqdFound <> bPrevWhenReqdFound)
      bRecreateGrid = #True
    EndIf
  EndIf
  bPrevPageFound = bPageFound
  bPrevMidiCueFound = bMidiCueFound
  bPrevWhenReqdFound = bWhenReqdFound
  
  If bRecreateGrid
    With WFI
      ; clear find results
      ClearGadgetItems(\grdFindResults)
      
      ; remove existing columns
      removeAllGadgetColumns(\grdFindResults)
      
      ; add required columns
      nColNo = 0
      AddGadgetColumn(\grdFindResults,nColNo,grText\sTextCue,50)
      grWFI\nColCue = nColNo
      nColNo + 1
      If bPageFound
        AddGadgetColumn(\grdFindResults,nColNo,Lang("Common","Page"),50)
        grWFI\nColPage = nColNo
        nColNo + 1
      Else
        grWFI\nColPage = -1
      EndIf
      If bMidiCueFound
        AddGadgetColumn(\grdFindResults,nColNo,Lang("Common","MidiCue"),70)
        grWFI\nColMidiCue = nColNo
        nColNo + 1
      Else
        grWFI\nColMidiCue = -1
      EndIf
      AddGadgetColumn(\grdFindResults,nColNo,Lang("WFI","Description"),220)
      grWFI\nColDescr = nColNo
      nColNo + 1
      If bWhenReqdFound
        AddGadgetColumn(\grdFindResults,nColNo,Lang("Common","WhenReqd"),160)
        grWFI\nColWhenReqd = nColNo
        nColNo + 1
      Else
        grWFI\nColWhenReqd = -1
      EndIf
      AddGadgetColumn(\grdFindResults,nColNo,Lang("WFI","FileName"),240)
      grWFI\nColFile = nColNo
      autoFitGridCol(\grdFindResults,grWFI\nColFile) ; autofit "FileName" column
      grWFI\nMaxColNo = nColNo
    EndWith
  EndIf
  
  With grWFI
    \nParentWindow = nParentWindow
    \nSelectedCuePtr = -1
    If \bFindOptionSet = #False
      ; changed default 12Oct2017 11.6.2.1ak and 11.7.0 following email from Declan Brennan
      ; \bAudVidOnly = #True
      \bAudVidOnly = #False
      \bFindOptionSet = #True
    EndIf
    If \bAudVidOnly
      SGS(WFI\optAudVidOnly, #True)
    Else
      SGS(WFI\optAllCues, #True)
    EndIf
    If \bFullPathNames
      SGS(WFI\chkFullPathNames, #PB_Checkbox_Checked)
    Else
      SGS(WFI\chkFullPathNames, #PB_Checkbox_Unchecked)
    EndIf
  EndWith
  
  SGT(WFI\txtFind, "")
  WFI_loadFindArray()
  WFI_loadGrid()
  WFI_setButtons()
  
  SAG(WFI\txtFind)
  
  setWindowVisible(#WFI, #True)
EndProcedure

Procedure WFI_Form_Unload()
  PROCNAMEC()
  
  getFormPosition(#WFI, @grFindWindow)
  unsetWindowModal(#WFI)
  scsCloseWindow(#WFI)
EndProcedure

Procedure WFI_formValidation()
  ; Added 1Oct2022 11.9.6
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WFI_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WFI_valGadget(nGadgetNo)
  ; Added 1Oct2022 11.9.6
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr ;, nArrayIndex
  Protected bFound = #True
  
  ; debugMsg0(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
;  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WFI
    Select nEventGadgetNoForEvHdlr
      Case \txtFind
        ETVAL2(WFI_txtFind_Validate())
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

Procedure WFI_EventHandler()
  PROCNAMEC()
  
  With WFI
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        If WFI_formValidation()
          WFI_Form_Unload()
        EndIf
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnSelect)
              WFI_btnSelect_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            If WFI_formValidation()
              WFI_Form_Unload()
            EndIf
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel
            If WFI_formValidation()
              WFI_Form_Unload()
            EndIf
            
          Case \btnHelp
            displayHelpTopic("find_cue.htm")
            
          Case \btnSelect
            WFI_btnSelect_Click()
            
          Case \chkFullPathNames
            If GGS(\chkFullPathNames) = #PB_Checkbox_Checked
              grWFI\bFullPathNames = #True
            Else
              grWFI\bFullPathNames = #False
            EndIf
            WFI_loadFindArray()
            WFI_loadGrid()
            SAG(WFI\txtFind)
            
          Case \grdFindResults
            Select gnEventType
              Case #PB_EventType_Change
                WFI_setButtons()
              Case #PB_EventType_LeftDoubleClick
                WFI_setButtons()
                WFI_btnSelect_Click()
            EndSelect
            
          Case \optAllCues
            grWFI\bAudVidOnly = #False
            WFI_loadFindArray()
            WFI_loadGrid()
            WFI_setButtons()
            SAG(WFI\txtFind)
            
          Case \optAudVidOnly
            grWFI\bAudVidOnly = #True
            WFI_loadFindArray()
            WFI_loadGrid()
            WFI_setButtons()
            SAG(WFI\txtFind)
            
          Case \txtFind
            Select gnEventType
              Case #PB_EventType_Change
                WFI_txtFind_Change()
              Case #PB_EventType_LostFocus
                ; Added 30Sep2022 11.9.6 after finding 'Find' in the editor didn't work due to the change in "20Jun2022 11.9.3aa" near the start of WED_publicNodeClick()
                ; debugMsg(sProcName, "WFI\txtFind LostFocus")
                ETVAL(WFI_txtFind_Validate())
            EndSelect
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF