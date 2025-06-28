; File: fmColorScheme.pbi

EnableExplicit

Procedure WCS_displaySample()
  PROCNAMEC()
  Protected nItemCode
  Protected nBackColor, nTextColor, bUseDflt
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grColHnd\nSelectedRow=" + Str(grColHnd\nSelectedRow))
  
  nItemCode = grColHnd\nSelectedRow
  If (nItemCode >= 0) And (nItemCode <= #SCS_COL_ITEM_LAST)
    With grWorkScheme\aItem[nItemCode]
      nBackColor = \nBackColor
      nTextColor = \nTextColor
      bUseDflt = \bUseDflt
    EndWith
    
;     If bUseDflt
;       nBackColor = grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nBackColor
;       nTextColor = grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nTextColor
;     EndIf
    
    SetGadgetColor(WCS\cntSampleGrid, #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(WCS\lblSampleGrid, #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(WCS\lblSampleGrid, #PB_Gadget_FrontColor, nTextColor)
    SGT(WCS\lblSampleGrid, grColHnd\sItemTitle[grColHnd\nSelectedRow])
    setVisible(WCS\cntSampleGrid, #True)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_displayNXSample()
  PROCNAMEC()
  Protected nItemCode
  Protected nBackColor, nTextColor, bUseDflt
  Protected nNXBackColor.l, nNXTextColor.l  ; must be Longs as setNXColorsForItemColors() uses PokeL() to populate these fields
  
  debugMsg(sProcName, #SCS_START)
  
  nItemCode = grColHnd\nSelectedRow
  Select nItemCode
    Case #SCS_COL_ITEM_QF To #SCS_COL_ITEM_QN, #SCS_COL_ITEM_DF
      ; nb may need to change the above if the #SCS_COL_ITEM_... Enumeration is changed
      With grWorkScheme\aItem[nItemCode]
        nBackColor = \nBackColor
        nTextColor = \nTextColor
        bUseDflt = \bUseDflt
      EndWith
      setNXColorsForItemColors(nItemCode, nBackColor, nTextColor, @nNXBackColor, @nNXTextColor)
      SetGadgetColor(WCS\cntSampleNX, #PB_Gadget_BackColor, nNXBackColor)
      SetGadgetColor(WCS\lblSampleNX, #PB_Gadget_BackColor, nNXBackColor)
      SetGadgetColor(WCS\lblSampleNX, #PB_Gadget_FrontColor, nNXTextColor)
      SGT(WCS\lblSampleNX, grColHnd\sItemTitle[grColHnd\nSelectedRow])
      setVisible(WCS\cntSampleNX, #True)
      
    Default
      setVisible(WCS\cntSampleNX, #False)
      
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_checkItemAltered(nIndex)
  PROCNAMEC()
  Protected bItemAltered
  
  If grWorkScheme\aItem[nIndex]\nBackColor <> grSchemeForReset\aItem[nIndex]\nBackColor
    bItemAltered = #True
  ElseIf grWorkScheme\aItem[nIndex]\nTextColor <> grSchemeForReset\aItem[nIndex]\nTextColor
    bItemAltered = #True
  ElseIf (nIndex <> #SCS_COL_ITEM_DF) And (grWorkScheme\aItem[nIndex]\bUseDflt <> grSchemeForReset\aItem[nIndex]\bUseDflt)
    bItemAltered = #True
  EndIf
  
  ProcedureReturn bItemAltered
  
EndProcedure

Procedure WCS_getSelectedItemColor(sSelectedColumn.s)
  PROCNAMEC()
  Protected nColor
  
  With grColHnd
    
    Select sSelectedColumn
      Case "BACK"
        nColor = grWorkScheme\aItem[\nSelectedRow]\nBackColor
        
      Case "TEXT"
        nColor = grWorkScheme\aItem[\nSelectedRow]\nTextColor
        
    EndSelect
  EndWith
  
  ProcedureReturn nColor
  
EndProcedure

Procedure WCS_setButtons()
  PROCNAMEC()
  Protected bResetEnabled, bSaveEnabled
  Protected bItemAltered, bMySchemeAltered
  Protected bCopy, bPaste
  Protected sItemTitle.s
  Protected n
  Protected nHalfWidth
  
  With grColHnd
    
    bMySchemeAltered = #False
    For n = 0 To #SCS_COL_ITEM_LAST
      bItemAltered = WCS_checkItemAltered(n)
      If n = \nSelectedRow
        If bItemAltered
          sItemTitle = \sItemTitle[\nSelectedRow] + " *"
          bResetEnabled = #True
        Else
          sItemTitle = \sItemTitle[\nSelectedRow]
        EndIf
        SGT(WCS\lblItemDtl[\nSelectedRow], sItemTitle)
      EndIf
      If bItemAltered
        bMySchemeAltered = #True
        bSaveEnabled = #True
      EndIf
    Next n
    If grWorkScheme\nColNXAction <> grSchemeForReset\nColNXAction
      bMySchemeAltered = #True
      bSaveEnabled = #True
    EndIf
    
    \bSchemeAltered = bMySchemeAltered
    
    If \nSelectedRow >= 0
      bCopy = #True
      If StartDrawing(CanvasOutput(WCS\cvsCopy))
        nHalfWidth = OutputWidth() >> 1
        Box(0,0,nHalfWidth,OutputHeight(),WCS_getSelectedItemColor("BACK"))
        Box(nHalfWidth,0,nHalfWidth,OutputHeight(),WCS_getSelectedItemColor("TEXT"))
        LineXY(nHalfWidth,0,nHalfWidth,OutputHeight(),#SCS_Black)
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
        StopDrawing()
      EndIf
      
      If \bCopyPopulated
        bPaste = #True
        If StartDrawing(CanvasOutput(WCS\cvsPaste))
          nHalfWidth = OutputWidth() >> 1
          Box(0,0,nHalfWidth,OutputHeight(),\rCopyColorItem\nBackColor)
          Box(nHalfWidth,0,nHalfWidth,OutputHeight(),\rCopyColorItem\nTextColor)
          LineXY(nHalfWidth,0,nHalfWidth,OutputHeight(),#SCS_Black)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
          StopDrawing()
        EndIf
      EndIf
    EndIf
    
    setEnabled(WCS\btnCopy, bCopy)
    setVisible(WCS\cvsCopy, bCopy)
    setEnabled(WCS\btnPaste, bPaste)
    setVisible(WCS\cvsPaste, bPaste)
    
  EndWith
  
  setEnabled(WCS\btnResetItem, bResetEnabled)
  
  setEnabled(WCS\btnSave, bSaveEnabled)
  If grWorkScheme\bInternalScheme
    setEnabled(WCS\btnDelete, #False)
    setEnabled(WCS\btnExport, #False)
  Else
    setEnabled(WCS\btnDelete, #True)
    setEnabled(WCS\btnExport, #True)
  EndIf
  
EndProcedure

Procedure WCS_displayColorItem(nItemCode)
  PROCNAMEC()
  Protected nDisplayBackColor, nDisplayTextColor
  
;   debugMsg(sProcName, #SCS_START + ", nItemCode=" + decodeColorItemIndex(nItemCode))
  
  With grWorkScheme\aItem[nItemCode]
    debugMsg(sProcName, "grWorkScheme\aItem[" + decodeColorItemIndex(nItemCode) + "]\nBackColor=$" + Hex(\nBackColor, #PB_Long))
    If nItemCode <> #SCS_COL_ITEM_DF
      SGS(WCS\chkUseDflt[nItemCode], \bUseDflt)
    EndIf
    
    ; back color
    If StartDrawing(ImageOutput(WCS\imgBackColor[nItemCode]))
      Box(0,0,54,18,\nBackColor)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0,0,54,18,#SCS_Black)
      StopDrawing()
      SGS(WCS\picBackColor[nItemCode],ImageID(WCS\imgBackColor[nItemCode]))
    EndIf
    
    ; text color
    If StartDrawing(ImageOutput(WCS\imgTextColor[nItemCode]))
      Box(0,0,54,18,\nTextColor)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0,0,54,18,#SCS_Black)
      StopDrawing()
      SGS(WCS\picTextColor[nItemCode],ImageID(WCS\imgTextColor[nItemCode]))
    EndIf
  EndWith
  
EndProcedure

Procedure WCS_selectItemColor(nIndex)
  PROCNAMEC()
  Protected n
  Protected nBackColor, nLabelFont
  
  debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex)
  
  For n = 0 To #SCS_COL_ITEM_LAST
    If n = nIndex
      nBackColor = $BBBBBB
      nLabelFont = #SCS_FONT_GEN_BOLD
    Else
      nBackColor = $FAFAFA
      nLabelFont = #SCS_FONT_GEN_NORMAL
    EndIf
    SetGadgetColor(WCS\cntColorItem[n], #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(WCS\lblItemDtl[n], #PB_Gadget_BackColor, nBackColor)
    scsSetGadgetFont(WCS\lblItemDtl[n], nLabelFont)
    SetGadgetColor(WCS\cntBackColor[n], #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(WCS\cntTextColor[n], #PB_Gadget_BackColor, nBackColor)
  Next n
  
  grColHnd\nSelectedRow = nIndex
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_setItemColor(nItemCode, sSelectedColumn.s, nColor)
  PROCNAMEC()
  
;   debugMsg(sProcName, #SCS_START + ", nItemCode=" + Str(nItemCode) + ", sSelectedColumn=" + sSelectedColumn + ", nColor=$" + Hex(nColor,#PB_Long))
  
  With grWorkScheme\aItem[nItemCode]
    Select sSelectedColumn
      Case "BACK"
        \nBackColor = nColor
;         debugMsg(sProcName, "grWorkScheme\aItem[" + decodeColorItemIndex(nItemCode) + "]\nBackColor=$" + Hex(\nBackColor,#PB_Long))
        If StartDrawing(ImageOutput(WCS\imgBackColor[nItemCode]))
          Box(0,0,54,18,nColor)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0,0,54,18,#SCS_Black)
          StopDrawing()
          SGS(WCS\picBackColor[nItemCode],ImageID(WCS\imgBackColor[nItemCode]))
        EndIf
        
      Case "TEXT"
        \nTextColor = nColor
        If StartDrawing(ImageOutput(WCS\imgTextColor[nItemCode]))
          Box(0,0,54,18,nColor)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0,0,54,18,#SCS_Black)
          StopDrawing()
          SGS(WCS\picTextColor[nItemCode],ImageID(WCS\imgTextColor[nItemCode]))
        EndIf
        
    EndSelect
    
    If grColHnd\nSelectedRow = nItemCode
      debugMsg(sProcName, "calling displaySample")
      WCS_displaySample()
      WCS_displayNXSample()
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_loadScheme(sSchemeName.s)
  PROCNAMEC()
  Protected n
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", sSchemeName=" + sSchemeName)
  
  For n = 0 To #SCS_COL_ITEM_LAST
    SGT(WCS\lblItemDtl[n], grColHnd\sItemTitle[n])
  Next n
  
  debugMsg(sProcName, "ArraySize(gaColorScheme())=" + ArraySize(gaColorScheme()))
  For n = 0 To ArraySize(gaColorScheme())
    If gaColorScheme(n)\sSchemeName = sSchemeName
      debugMsg(sProcName, "gaColorScheme(" + n + ")\sSchemeName=" + gaColorScheme(n)\sSchemeName)
      grWorkScheme = gaColorScheme(n)
      grSchemeForReset = grWorkScheme
      grColHnd\nDesignSchemeIndex = n
      For n = 0 To #SCS_COL_ITEM_LAST
        WCS_displayColorItem(n)
      Next n
      WCS_selectItemColor(0)
      WCS_displaySample()
      nListIndex = indexForComboBoxData(WCS\cboColNXAction, grWorkScheme\nColNXAction, 0)
      SGS(WCS\cboColNXAction, nListIndex)
      WCS_displayNXSample()
      Break
    EndIf
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  Protected n
  
  If grColHnd\bSchemeAltered
    nResponse = scsMessageRequester(GWT(#WCS), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel | #MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        ProcedureReturn
        
      Case #PB_MessageRequester_Yes
        WCS_btnSave_Click()
        If grColHnd\bSchemeAltered
          ; Save/SaveAs cancelled by user (or failed)
          ProcedureReturn
        EndIf
        ; set selected scheme
        For n = 0 To ArraySize(gaColorScheme())
          If gaColorScheme(n)\sSchemeName = GetGadgetText(WCS\cboScheme)
            grColorScheme = gaColorScheme(n)
            Break
          EndIf
        Next n
        
    EndSelect
  EndIf
  
  getFormPosition(#WCS, @grColorSchemeWindow)
  unsetWindowModal(#WCS)
  scsCloseWindow(#WCS)
  debugMsg(sProcName, "grColHnd\bChangesSaved=" + strB(grColHnd\bChangesSaved))
  If (grColHnd\bChangesSaved) Or (grColorScheme\sSchemeName <> grColHnd\sOrigSchemeName)
    WOP_colorSchemeDesignerModReturn()
  EndIf
  
EndProcedure

Procedure WCS_btnOK_Click()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", grColHnd\bSchemeAltered=" + strB(grColHnd\bSchemeAltered))
  
  If grColHnd\bSchemeAltered
    WCS_btnSave_Click()
    If grColHnd\bSchemeAltered
      ; Save/SaveAs cancelled by user (or failed)
      ProcedureReturn
    EndIf
  EndIf
  
  ; set selected scheme
  For n = 0 To ArraySize(gaColorScheme())
    If gaColorScheme(n)\sSchemeName = GetGadgetText(WCS\cboScheme)
      grColorScheme = gaColorScheme(n)
      Break
    EndIf
  Next n

  WCS_Form_Unload()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_btnCancel_Click()
  PROCNAMEC()
  
  grColHnd\bSchemeAltered = #False
  WMN_setFormColors()
  WCS_Form_Unload()
  
EndProcedure

Procedure WCS_btnDelete_Click()
  PROCNAMEC()
  Protected nResponse, n, nMaxScheme

  If grWorkScheme\bInternalScheme
    ProcedureReturn
  EndIf

  nResponse = scsMessageRequester(GWT(#WCS), LangPars("WCS", "DelScheme", grWorkScheme\sSchemeName), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
  If nResponse <> #PB_MessageRequester_Yes
    ProcedureReturn
  EndIf

  nMaxScheme = 0
  For n = 1 To ArraySize(gaColorScheme())
    If gaColorScheme(n)\sSchemeName <> grWorkScheme\sSchemeName
      nMaxScheme + 1
      If nMaxScheme <> n
        gaColorScheme(nMaxScheme) = gaColorScheme(n)
      EndIf
    EndIf
  Next n
  ReDim gaColorScheme(nMaxScheme)

  saveXMLColorFile(gsColorFolder)
  
  ClearGadgetItems(WCS\cboScheme)
  For n = 0 To ArraySize(gaColorScheme())
    AddGadgetItem(WCS\cboScheme, -1, gaColorScheme(n)\sSchemeName)
  Next n
  SGS(WCS\cboScheme, 0)    ; reset screen to default scheme
  WCS_loadScheme(GetGadgetText(WCS\cboScheme))
  WCS_setButtons()
  
EndProcedure

Procedure WCS_btnSaveAs_Click()
  Protected sNewName.s, n, bAsking, bFound
  Protected nReplace, nCurrentScheme, nResponse
  
  bAsking = #True
  nReplace = -1
  While bAsking
    sNewName = Trim(InputRequester(GetWindowTitle(#WCS), Lang("WCS", "SaveAsPrompt"), ""))
    If Len(sNewName) = 0
      bAsking = #False
    ElseIf UCase(sNewName) = UCase(#SCS_COL_DEF_SCHEME_NAME) Or UCase(sNewName) = UCase(#SCS_COL_LIGHT_SCHEME_NAME) Or UCase(sNewName) = UCase(#SCS_COL_DARK_SCHEME_NAME)
      scsMessageRequester(GWT(#WCS), LangPars("WCS", "Reserved", sNewName), #PB_MessageRequester_Ok)
    Else
      bFound = #False
      For n = 0 To ArraySize(gaColorScheme())
        If gaColorScheme(n)\sSchemeName = sNewName
          bFound = #True
          nResponse = scsMessageRequester(GWT(#WCS), LangPars("WCS", "AlreadyUsed", sNewName) + #CRLF$ + Lang("WCS", "Replace"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
          If nResponse = #PB_MessageRequester_Yes
            nReplace = n
            bAsking = #False
            Break
          EndIf
        EndIf
      Next n
      If bFound = #False
        bAsking = #False
      EndIf
    EndIf
  Wend
  
  If Len(sNewName) > 0
    grWorkScheme\sSchemeName = sNewName
    grWorkScheme\bInternalScheme = #False
    If nReplace >= 0
      n = nReplace
    Else
      n = ArraySize(gaColorScheme()) + 1
      ReDim gaColorScheme(n)
    EndIf
    gaColorScheme(n) = grWorkScheme
    grSchemeForReset = grWorkScheme
    saveXMLColorFile(gsColorFolder)
    grColHnd\bChangesSaved = #True
    
    ClearGadgetItems(WCS\cboScheme)
    For n = 0 To ArraySize(gaColorScheme())
      AddGadgetItem(WCS\cboScheme, -1, gaColorScheme(n)\sSchemeName)
      If gaColorScheme(n)\sSchemeName = grWorkScheme\sSchemeName
        grColHnd\nDesignSchemeIndex = n
      EndIf
    Next n
    
    SGS(WCS\cboScheme, grColHnd\nDesignSchemeIndex)
    
  EndIf
  
  WCS_setButtons()
  
EndProcedure

Procedure WCS_btnSave_Click()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  If grWorkScheme\bInternalScheme
    WCS_btnSaveAs_Click()
  Else
    For n = 0 To ArraySize(gaColorScheme())
      If gaColorScheme(n)\sSchemeName = grWorkScheme\sSchemeName
        gaColorScheme(n) = grWorkScheme
        grSchemeForReset = grWorkScheme
        saveXMLColorFile(gsColorFolder)
        grColHnd\bChangesSaved = #True
        Break
      EndIf
    Next n
  EndIf
  WCS_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_btnAGColors_Click()
  PROCNAMEC()
  
  WAC_Form_Show() ; nb modal form
  
EndProcedure

Procedure WCS_btnExport_Click()
  PROCNAMEC()
  
  exportColorScheme(@grWorkScheme)
  
EndProcedure

Procedure WCS_btnImport_Click()
  PROCNAMEC()
  Protected nResponse
  Protected sTitle.s, sDefaultFile.s, sPattern.s
  Protected sFileName.s
  Protected nImportedSchemePtr
  Protected n
  
  If grColHnd\bSchemeAltered
    nResponse = scsMessageRequester(GWT(#WCS), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel | #MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        ProcedureReturn
      Case #PB_MessageRequester_Yes
        WCS_btnSave_Click()
    EndSelect
  EndIf
  
  sTitle = Lang("WCS", "btnImport")
  If Len(Trim(gsCueFolder)) > 0
    sDefaultFile = Trim(gsCueFolder)
  ElseIf Len(Trim(grGeneralOptions\sInitDir)) > 0
    sDefaultFile = Trim(grGeneralOptions\sInitDir)
  EndIf
  
  ; open the file for reading
  sPattern = Lang("Requesters", "ColorScheme") + " (*.scscs)|*.scscs"
  sFileName = OpenFileRequester(sTitle, sDefaultFile, sPattern, 0)
  If Len(sFileName) = 0
    ProcedureReturn
  EndIf
  
  nImportedSchemePtr = importColorScheme(sFileName)
  If nImportedSchemePtr >= 0
    grColorScheme = gaColorScheme(nImportedSchemePtr)
    grColHnd\bSchemeAltered = #True
    ClearGadgetItems(WCS\cboScheme)
    For n = 0 To ArraySize(gaColorScheme())
      AddGadgetItem(WCS\cboScheme, -1, gaColorScheme(n)\sSchemeName)
      If gaColorScheme(n)\sSchemeName = grColorScheme\sSchemeName
        grColHnd\nDesignSchemeIndex = n
      EndIf
    Next n
    SGS(WCS\cboScheme, grColHnd\nDesignSchemeIndex)
    
    WCS_loadScheme(GGT(WCS\cboScheme))
    
    WCS_setButtons()
  EndIf
  
EndProcedure

Procedure WCS_cboScheme_Click()
  Protected nResponse
  
  If grColHnd\bSchemeAltered
    nResponse = scsMessageRequester(GWT(#WCS), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    If nResponse = #PB_MessageRequester_Yes
      WCS_btnSave_Click()
    EndIf
  EndIf
  
  WCS_loadScheme(GetGadgetText(WCS\cboScheme))
  grColHnd\bAudioGraphColorsChanged = #True
  
  WCS_setButtons()
  
EndProcedure

Procedure WCS_cboColNXAction_Click()
  PROCNAMEC()
  ; nb NX = 'next manual cue'
  
  With grWorkScheme
    \nColNXAction = getCurrentItemData(WCS\cboColNXAction, 0)
    WCS_displayNXSample()
    grColHnd\bSchemeAltered = #True
  EndWith
  
EndProcedure

Procedure WCS_updateDefaultColors()
  PROCNAMEC()
  Protected nItemCode
  
  debugMsg(sProcName, #SCS_START)
  
  For nItemCode = 0 To #SCS_COL_ITEM_LAST
    If nItemCode <> #SCS_COL_ITEM_DF
      With grWorkScheme\aItem[nItemCode]
;         debugMsg(sProcName, "grWorkScheme\aItem[" + decodeColorItemIndex(nItemCode) + "]\bUseDflt=" + strB(\bUseDflt))
        If \bUseDflt
          \nBackColor = grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nBackColor
          \nTextColor = grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nTextColor
          WCS_displayColorItem(nItemCode)
        EndIf
      EndWith
    EndIf
  Next nItemCode
  
EndProcedure

Procedure WCS_clearUseDfltIfReqd(nItemCode)
  PROCNAMEC()
  
  If nItemCode <> #SCS_COL_ITEM_DF
    With grWorkScheme\aItem[nItemCode]
      If \bUseDflt
        If (\nBackColor <> grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nBackColor) Or
           (\nTextColor <> grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nTextColor)
          \bUseDflt = #False
          SGS(WCS\chkUseDflt[grColHnd\nSelectedRow], \bUseDflt)
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WCS_btnSwap_Click()
  PROCNAMEC()
  Protected nItemCode
  Protected nSwapColor
  
  debugMsg(sProcName, #SCS_START + ", grColHnd\nSelectedRow=" + Str(grColHnd\nSelectedRow))
  
  nItemCode = grColHnd\nSelectedRow
  If (nItemCode >= 0) And (nItemCode <= #SCS_COL_ITEM_LAST)
    With grWorkScheme\aItem[nItemCode]
      nSwapColor = \nBackColor
      \nBackColor = \nTextColor
      \nTextColor = nSwapColor
      WCS_clearUseDfltIfReqd(nItemCode)
      WCS_displayColorItem(nItemCode)
      If nItemCode = #SCS_COL_ITEM_DF
        WCS_updateDefaultColors()
      EndIf
    EndWith
  EndIf
  
  WCS_selectItemColor(nItemCode)
  WCS_displaySample()
  WCS_displayNXSample()
  WCS_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_btnResetItem_Click()
  PROCNAMEC()
  Protected nItemCode
  
  debugMsg(sProcName, #SCS_START + ", grColHnd\nSelectedRow=" + Str(grColHnd\nSelectedRow))
  
  nItemCode = grColHnd\nSelectedRow
  If (nItemCode >= 0) And (nItemCode <= #SCS_COL_ITEM_LAST)
    grWorkScheme\aItem[nItemCode] = grSchemeForReset\aItem[nItemCode]
    WCS_clearUseDfltIfReqd(nItemCode)
    WCS_displayColorItem(nItemCode)
    If nItemCode = #SCS_COL_ITEM_DF
      WCS_updateDefaultColors()
    EndIf
  EndIf
  
  WCS_selectItemColor(nItemCode)
  WCS_displaySample()
  WCS_displayNXSample()
  WCS_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_btnCopy_Click()
  PROCNAMEC()
  Protected nItemCode
  
  With grColHnd
    nItemCode = \nSelectedRow
    If (nItemCode >= 0) And (nItemCode <= #SCS_COL_ITEM_LAST)
      \rCopyColorItem = grWorkScheme\aItem[nItemCode]
      \bCopyPopulated = #True
      WCS_setButtons()
    EndIf
  EndWith
  
EndProcedure

Procedure WCS_btnPaste_Click()
  PROCNAMEC()
  Protected nItemCode
  
  debugMsg(sProcName, #SCS_START + ", grColHnd\nSelectedRow=" + Str(grColHnd\nSelectedRow))
  
  With grColHnd
    nItemCode = \nSelectedRow
    If (nItemCode >= 0) And (nItemCode <= #SCS_COL_ITEM_LAST) And (\bCopyPopulated)
      grWorkScheme\aItem[nItemCode] = \rCopyColorItem
      WCS_clearUseDfltIfReqd(nItemCode)
    EndIf
    WCS_displayColorItem(nItemCode)
    If nItemCode = #SCS_COL_ITEM_DF
      WCS_updateDefaultColors()
    EndIf
  EndWith
  
  WCS_selectItemColor(nItemCode)
  WCS_displaySample()
  WCS_displayNXSample()
  WCS_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCS_Form_Show(bModal, nParentWindow)
  PROCNAMEC()
  Protected n, sNr.s, sItemCode.s
  Protected sColorFolder.s, sInfo.s
  Protected nLeft, nWidth
  
  debugMsg(sProcName, #SCS_START)
  
  With grColHnd
    
    ; store initial item titles so that the "*" altered marker may be added if required
    For n = 0 To #SCS_COL_ITEM_LAST
      sItemCode = decodeColorItemIndex(n)
      \sItemTitle[n] = Lang("WCS", "ColCode" + sItemCode)
    Next n
    
    If IsWindow(#WCS) = #False
      createfmColorScheme(nParentWindow)
    EndIf
    setFormPosition(#WCS, @grColorSchemeWindow)
    
    If gbDfltColorFile
      setVisible(WCS\lblInfo, #False)
      setVisible(WCS\lnHdgSep, #True)
    Else
      If Left(gsColorFolder, Len(gsMyDocsPath)) = gsMyDocsPath
        sColorFolder = gsMyDocsLeafName + Mid(gsColorFolder, Len(gsMyDocsPath)+1)
      Else
        sColorFolder = gsColorFolder
      EndIf
      ; debugMsg(sProcName, "gsColorFile=" + gsColorFile)
      ; debugMsg(sProcName, "gsColorFolder=" + gsColorFolder)
      ; debugMsg(sProcName, "sColorFolder=" + sColorFolder)
      sInfo = LangPars("WCS", "UsingProd", sColorFolder)
      debugMsg(sProcName, "sInfo=" + sInfo)
      SGT(WCS\lblInfo, sInfo)
      setVisible(WCS\lnHdgSep, #False)
      setVisible(WCS\lblInfo, #True)
    EndIf
    
    debugMsg(sProcName, "Loading cboScheme")
    \bChangesSaved = #False
    \bSchemeAltered = #False
    \bAudioGraphColorsChanged = #False
    \sOrigSchemeName = grColorScheme\sSchemeName
    ClearGadgetItems(WCS\cboScheme)
    For n = 0 To ArraySize(gaColorScheme())
      debugMsg(sProcName, "Adding " + gaColorScheme(n)\sSchemeName)
      AddGadgetItem(WCS\cboScheme, -1, gaColorScheme(n)\sSchemeName)
      If gaColorScheme(n)\sSchemeName = grColorScheme\sSchemeName
        \nDesignSchemeIndex = n
      EndIf
    Next n
    SGS(WCS\cboScheme, \nDesignSchemeIndex)
    
    nWidth = GadgetX(WCS\btnOK) - GadgetX(WCS\cntColNXAction) - 4
    ResizeGadget(WCS\cntColNXAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    ClearGadgetItems(WCS\cboColNXAction)
    For n = 0 To #SCS_COL_NX_LAST
      addGadgetItemWithData(WCS\cboColNXAction, decodeColNXActionL(n), n)
    Next n
    setComboBoxWidth(WCS\cboColNXAction)
    nLeft = GadgetX(WCS\cboColNXAction) + GadgetWidth(WCS\cboColNXAction) + gnGap
    ; nWidth = GadgetWidth(WCS\scaColorItemList) - nLeft
    nWidth = GadgetX(WCS\btnOK) - nLeft - 8
    If nWidth > 0
      If nWidth > 220
        nWidth = 220
      EndIf
      ResizeGadget(WCS\cntSampleNX, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
      nWidth - 4
      If nWidth > 0
        ResizeGadget(WCS\lblSampleNX, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
      EndIf
    EndIf
    
    WCS_loadScheme(GGT(WCS\cboScheme))
    WCS_setAGColorsButtonText()
    
    WCS_setButtons()
    setWindowModal(#WCS, bModal)
    setWindowVisible(#WCS, #True)
    SetActiveWindow(#WCS)
   
  EndWith
  
EndProcedure

Procedure WCS_rowGadget_Click(Index)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  WCS_selectItemColor(Index)
  WCS_displaySample()
  WCS_displayNXSample()
  WCS_setButtons()
  SAG(-1)
  
EndProcedure

Procedure WCS_picColor_Click(sSelectedColumn.s)
  PROCNAMEC()
  Protected nCurrItemColor, nSelectedColor
  
  debugMsg(sProcName, #SCS_START + ", sSelectedColumn=" + sSelectedColumn)
  
  nCurrItemColor = WCS_getSelectedItemColor(sSelectedColumn)
  nSelectedColor = ColorRequester(nCurrItemColor)
  If nSelectedColor = -1
    debugMsg(sProcName, "user cancelled ColorRequester")
  Else
    debugMsg(sProcName, "nCurrItemColor=$" + Hex(nCurrItemColor) + ", nSelectedColor=$" + Hex(nSelectedColor))
    If nSelectedColor <> nCurrItemColor
      WCS_setItemColor(grColHnd\nSelectedRow, sSelectedColumn, nSelectedColor)
      If grColHnd\nSelectedRow = #SCS_COL_ITEM_DF
        WCS_updateDefaultColors()
      EndIf
      WCS_clearUseDfltIfReqd(grColHnd\nSelectedRow)
    EndIf
  EndIf
  WCS_setButtons()
  SAG(-1)
  
EndProcedure

Procedure WCS_chkUseDflt_Click(Index)
  PROCNAMEC()
  Protected bNewUseDflt
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  bNewUseDflt = GetGadgetState(WCS\chkUseDflt[Index])
  If Index <> #SCS_COL_ITEM_DF
    With grWorkScheme\aItem[Index]
      If (bNewUseDflt) And (\bUseDflt = #False)
        \nBackColorPreSetUseDflt = \nBackColor
        \nTextColorPreSetUseDflt = \nTextColor
        \bColorsPreSetUseDfltSet = #True
        \nBackColor = grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nBackColor
        \nTextColor = grWorkScheme\aItem[#SCS_COL_ITEM_DF]\nTextColor
        
      ElseIf (bNewUseDflt = #False) And (\bUseDflt) And (\bColorsPreSetUseDfltSet)
        \nBackColor = \nBackColorPreSetUseDflt
        \nTextColor = \nTextColorPreSetUseDflt
        
      EndIf
      \bUseDflt = bNewUseDflt
      WCS_displayColorItem(Index)
    EndWith
  EndIf
  
  WCS_rowGadget_Click(Index)
  
EndProcedure

Procedure WCS_EventHandler()
  PROCNAMEC()
  
  With WCS
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        ; WCS_Form_Unload()
        WCS_btnOK_Click()   ; nb asks user if changes are to be saved
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOK)
              WCS_btnOK_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WCS_btnCancel_Click()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnAGColors
            WCS_btnAGColors_Click()
            
          Case \btnCancel
            WCS_btnCancel_Click()
            
          Case \btnCopy
            WCS_btnCopy_Click()
            
          Case \btnDelete
            WCS_btnDelete_Click()
            
          Case \btnExport
            WCS_btnExport_Click()
            
          Case \btnHelp
            displayHelpTopic("scs_colors.htm")
            
          Case \btnImport
            WCS_btnImport_Click()
            
          Case \btnOK
            WCS_btnOK_Click()
            
          Case \btnPaste
            WCS_btnPaste_Click()
            
          Case \btnResetItem
            WCS_btnResetItem_Click()
            
          Case \btnSave
            WCS_btnSave_Click()
            
          Case \btnSaveAs
            WCS_btnSaveAs_Click()
            
          Case \btnSwap
            WCS_btnSwap_Click()
            
          Case \cboColNXAction
            WCS_cboColNXAction_Click()
            
          Case \cboScheme
            CBOCHG(WCS_cboScheme_Click())
            
          Case \chkUseDflt[0]
            WCS_chkUseDflt_Click(gnEventGadgetArrayIndex)
            
          Case \lblItemDtl[0]
            WCS_rowGadget_Click(gnEventGadgetArrayIndex)
            
          Case \picBackColor[0]
            If gnEventType = #PB_EventType_LeftClick
              WCS_rowGadget_Click(gnEventGadgetArrayIndex)
              WCS_picColor_Click("BACK")
            EndIf
            
          Case \picTextColor[0]
            If gnEventType = #PB_EventType_LeftClick
              WCS_rowGadget_Click(gnEventGadgetArrayIndex)
              WCS_picColor_Click("TEXT")
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WCS_setAGColorsButtonText()
  If grColHnd\bAudioGraphColorsChanged
    SGT(WCS\btnAGColors, Lang("WCS", "btnAGColors") + "* ...")
  Else
    SGT(WCS\btnAGColors, Lang("WCS", "btnAGColors") + "...")
  EndIf
EndProcedure

; EOF

; IDE Options = PureBasic 5.45 LTS (Windows - x64)
; CursorPosition = 927
; FirstLine = 923
; Folding = ------
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; CPU = 1