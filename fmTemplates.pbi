; File: fmTemplates.pbi

EnableExplicit

Procedure WTM_displayTemplate()
  PROCNAMEC()
  Protected i, n, nRow
  Protected sRowText.s
  Protected sFileName.s, sDevMapFileName.s
  Protected bEnable
  Protected nGrdCuesGadget, nGrdDevsGadget, nGrdDevMapsGadget
  Protected sProdId.s
  
  debugMsg(sProcName, #SCS_START)
  
  bEnable = grWTM\bEditing
  
  With WTM
    If bEnable
      nGrdCuesGadget = \grdCuesChk
      nGrdDevsGadget = \grdDevsChk
      nGrdDevMapsGadget = \grdDevMapsChk
      setVisible(\grdCuesNoChk, #False)
      setVisible(\grdDevsNoChk, #False)
      setVisible(\grdDevMapsNoChk, #False)
    Else
      nGrdCuesGadget = \grdCuesNoChk
      nGrdDevsGadget = \grdDevsNoChk
      nGrdDevMapsGadget = \grdDevMapsNoChk
      setVisible(\grdCuesChk, #False)
      setVisible(\grdDevsChk, #False)
      setVisible(\grdDevMapsChk, #False)
    EndIf
    setVisible(nGrdCuesGadget, #True)
    setVisible(nGrdDevsGadget, #True)
    setVisible(nGrdDevMapsGadget, #True)
    
    grWTM\nTemplatePtr = getCurrentItemData(\grdTemplates)
    debugMsg(sProcName, "grWTM\nTemplatePtr=" + grWTM\nTemplatePtr)
    If grWTM\nTemplatePtr >= 0
      grTmTemplate = gaTemplate(grWTM\nTemplatePtr)
    Else
      grTmTemplate = grTemplateDef
    EndIf
    SGT(\txtTmName, grTmTemplate\sName)
    SGT(\edgTmDesc, grTmTemplate\sDesc)
    setEnabled(\txtTmName, bEnable)
    setEnabled(\edgTmDesc, bEnable)
    sFileName = grTmTemplate\sOrigTemplateFileName
    If FileExists(sFileName, #False) = #False
      If grTmTemplate\sCueFileName
        sFileName = grTmTemplate\sCueFileName
      EndIf
    EndIf
    readXMLTemplateFile(sFileName)  ; may be a template file or a cue file
    sDevMapFileName = gsTemplatesFolder + ignoreExtension(GetFilePart(sFileName)) + ".scstd"
    If FileExists(sDevMapFileName, #False) = #False
      If grTmTemplate\sCueFileName
        sProdId = getProdIdFromCueFile(grTmTemplate\sCueFileName)
        sDevMapFileName = gsDevMapsPath + ignoreExtension(GetFilePart(grTmTemplate\sCueFileName))
        If sProdId
          sDevMapFileName + "_" + sProdId
        EndIf
        sDevMapFileName + ".scsd"
      EndIf
    EndIf
    readXMLTemplateDevMapFile(sDevMapFileName)
  EndWith
  
  debugMsg(sProcName, "gnLastTmCue=" + gnLastTmCue)
  ClearGadgetItems(nGrdCuesGadget)
  For i = 1 To gnLastTmCue
    With gaTmCue(i)
      If bEnable
        sRowText = "" + Chr(10) + \sCue + Chr(10) + \sCueDescr + Chr(10) + \sCueTypeL + Chr(10) + \sActivationMethodL
      Else
        sRowText = \sCue + Chr(10) + \sCueDescr + Chr(10) + \sCueTypeL + Chr(10) + \sActivationMethodL
      EndIf
      addGadgetItemWithData(nGrdCuesGadget, sRowText, i)
      nRow = i - 1
      If \nTextColor <> \nBackColor
        SetGadgetItemColor(nGrdCuesGadget, nRow, #PB_Gadget_BackColor, \nBackColor, -1)
        SetGadgetItemColor(nGrdCuesGadget, nRow, #PB_Gadget_FrontColor, \nTextColor, -1)
      EndIf
      If (bEnable) And (\bIncludeCue)
        SetGadgetItemState(nGrdCuesGadget, nRow, #PB_ListIcon_Checked)
      EndIf
    EndWith
  Next i
  ; nb do NOT disable \grdCuesNoChk, \grdDevsNoChk or \grdDevMapsNoChk as that obliterates the item colors
  
  debugMsg(sProcName, "gnLastTmDev=" + gnLastTmDev)
  ClearGadgetItems(nGrdDevsGadget)
  For n = 0 To gnLastTmDev
    With gaTmDev(n)
      If bEnable
        sRowText = "" + Chr(10) + \sDevTypeL + Chr(10) + \sLogicalDev
      Else
        sRowText = \sDevTypeL + Chr(10) + \sLogicalDev
      EndIf
      addGadgetItemWithData(nGrdDevsGadget, sRowText, n)
      nRow = n
      If \nTextColor <> \nBackColor
        SetGadgetItemColor(nGrdDevsGadget, nRow, #PB_Gadget_BackColor, \nBackColor, -1)
        SetGadgetItemColor(nGrdDevsGadget, nRow, #PB_Gadget_FrontColor, \nTextColor, -1)
      EndIf
      If (bEnable) And (\bIncludeDev)
        SetGadgetItemState(nGrdDevsGadget, nRow, #PB_ListIcon_Checked)
      EndIf
    EndWith
  Next n
  
  debugMsg(sProcName, "gnLastTmDevMap=" + gnLastTmDevMap)
  ClearGadgetItems(nGrdDevMapsGadget)
  For n = 0 To gnLastTmDevMap
    With gaTmDevMap(n)
      If bEnable
        sRowText = "" + Chr(10) + \sDevMapName + Chr(10) + \sAudioDriverL
      Else
        sRowText = \sDevMapName + Chr(10) + \sAudioDriverL
      EndIf
      addGadgetItemWithData(nGrdDevMapsGadget, sRowText, n)
      nRow = n
      If \nTextColor <> \nBackColor
        SetGadgetItemColor(nGrdDevMapsGadget, nRow, #PB_Gadget_BackColor, \nBackColor, -1)
        SetGadgetItemColor(nGrdDevMapsGadget, nRow, #PB_Gadget_FrontColor, \nTextColor, -1)
      EndIf
      If (bEnable) And (\bIncludeDevMap)
        SetGadgetItemState(nGrdDevMapsGadget, nRow, #PB_ListIcon_Checked)
      EndIf
    EndWith
  Next n
  
  WTM_setButtons()

EndProcedure

Procedure WTM_drawTemplateList(sSelectedTemplateName.s="")
  PROCNAMEC()
  Protected n, nIndex
  
  With WTM
    ClearGadgetItems(\grdTemplates)
    For n = 0 To (gnTemplateCount-1)
      If gaTemplate(n)\sName
        addGadgetItemWithData(\grdTemplates, gaTemplate(n)\sName, n)
        If sSelectedTemplateName
          If gaTemplate(n)\sName = sSelectedTemplateName
            nIndex = n
          EndIf
        EndIf
      EndIf
    Next n
    If CountGadgetItems(\grdTemplates) > 0
      SGS(\grdTemplates, nIndex)
    EndIf
    WTM_displayTemplate()
  EndWith
  
EndProcedure

Procedure WTM_Form_Load(nParentWindow)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If (IsWindow(#WTM) = #False) Or (gaWindowProps(#WTM)\nParentWindow <> nParentWindow)
    createfmTemplates(nParentWindow)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_Form_Show(nParentWindow, bModal=#False, nReturnFunction=0, sSelectedTemplateName.s="")
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nParentWindow=" + decodeWindow(nParentWindow) + ", sSelectedTemplateName=" + sSelectedTemplateName)
  
  If (IsWindow(#WTM) = #False) Or (gaWindowProps(#WTM)\nParentWindow <> nParentWindow)
    WTM_Form_Load(nParentWindow)
  EndIf
  setFormPosition(#WTM, @grTemplatesWindow)
  setWindowModal(#WTM, bModal, nReturnFunction)
  
  With grWTM
    \nParentWindow = nParentWindow
    \bEditing = #False
    \bNewTemplate = #False
  EndWith
  
  WTM_drawTemplateList(sSelectedTemplateName)
  
  setWindowVisible(#WTM, #True)
  SetActiveWindow(#WTM)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_Form_Unload(bSkipMessage=#False)
  PROCNAMEC()
  Protected nResponse, bValResult
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WTM)
    getFormPosition(#WTM, @grTemplatesWindow)
    If bSkipMessage = #False
      If (grWTM\bEditing) And (getVisible(WTM\btnSave))
        nResponse = scsMessageRequester(GWT(#WTM), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
        Select nResponse
          Case #PB_MessageRequester_Cancel
            ProcedureReturn
            
          Case #PB_MessageRequester_Yes
            bValResult = WTM_valTemplate()
            debugMsg(sProcName, "WTM_valTemplate() returned " + strB(bValResult))
            If bValResult
              WTM_applyChanges()
            Else
              ProcedureReturn
            EndIf
            
          Case #PB_MessageRequester_No
            WTM_discardChanges()
            
        EndSelect
      EndIf
    EndIf
    unsetWindowModal(#WTM)
    scsCloseWindow(#WTM)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_setButtons()
  PROCNAMEC()
  Protected nPanelSelected
  Protected bTrueIfNotEditing
  Static sSaveTT1.s, sDiscardTT1.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sSaveTT1 = Lang("WTM", "btnSaveTT1")
    sDiscardTT1 = Lang("WTM", "btnDiscardTT1")
    bStaticLoaded = #True
  EndIf
  
  With WTM
    If grWTM\bEditing
      setVisible(\btnSave, #True)
      setVisible(\btnDiscard, #True)
      If grWTM\bNewTemplate
        scsToolTip(\btnSave, sSaveTT1)
        scsToolTip(\btnDiscard, sDiscardTT1)
      EndIf
      setEnabled(\grdTemplates, #False)
    Else
      setVisible(\btnSave, #False)
      setVisible(\btnDiscard, #False)
      setEnabled(\grdTemplates, #True)
      bTrueIfNotEditing = #True
    EndIf
    
    If (CountGadgetItems(\grdTemplates) > 0) And (GGS(\grdTemplates) >= 0)
      setEnabled(\btnCreateCueFile, bTrueIfNotEditing)
      setEnabled(\btnQuickEdit, bTrueIfNotEditing)
      setEnabled(\btnFullEdit, bTrueIfNotEditing)
      setEnabled(\btnSaveAs, bTrueIfNotEditing)
      setEnabled(\btnDelete, bTrueIfNotEditing)
    Else
      setEnabled(\btnCreateCueFile, #False)
      setEnabled(\btnQuickEdit, #False)
      setEnabled(\btnFullEdit, #False)
      setEnabled(\btnSaveAs, #False)
      setEnabled(\btnDelete, #False)
    EndIf
    
    If gsCueFile
      setEnabled(\btnCreateTemplate, bTrueIfNotEditing)
    Else
      setEnabled(\btnCreateTemplate, #False)
    EndIf
    
    nPanelSelected = GGS(\pnlProps)
    If nPanelSelected = 0
      setEnabled(\btnBack, #False)
    Else
      setEnabled(\btnBack, #True)
    EndIf
    If nPanelSelected = (CountGadgetItems(\pnlProps) - 1)
      setEnabled(\btnNext, #False)
    Else
      setEnabled(\btnNext, #True)
    EndIf
    
  EndWith

EndProcedure

Procedure WTM_btnDelete_Click()
  PROCNAMEC()
  Protected sName.s
  Protected sTemplateFileName.s, sTemplateDevMapFileName.s, sTemplateDatabaseFileName.s, sTemplateBakFileName.s
  Protected sReqTitle.s, sReqMessage.s
  Protected nReply, nDelResult
  Protected bTemplateDeleted
  Protected sNextName.s
  
  debugMsg(sProcName, #SCS_START)
  
  With WTM
    If (grWTM\nTemplatePtr >= 0) And (grWTM\nTemplatePtr = getCurrentItemData(\grdTemplates))
      sTemplateFileName = gaTemplate(grWTM\nTemplatePtr)\sOrigTemplateFileName
      sName = gaTemplate(grWTM\nTemplatePtr)\sName
      If (grWTM\nTemplatePtr+1) <= (gnTemplateCount-1)
        sNextName = gaTemplate(grWTM\nTemplatePtr+1)\sName
      ElseIf (grWTM\nTemplatePtr-1) >= 0
        sNextName = gaTemplate(grWTM\nTemplatePtr-1)\sName
      EndIf
      sReqTitle = Trim(GGT(\btnDelete))
      sReqMessage = LangPars("WTM", "DelMsg", #DQUOTE$ + sName + #DQUOTE$)
      nReply = scsMessageRequester(sReqTitle, sReqMessage, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      If nReply = #PB_MessageRequester_Yes
        nDelResult = DeleteFile(sTemplateFileName, #PB_FileSystem_Force)
        debugMsg2(sProcName, "DeleteFile(" + #DQUOTE$ + sTemplateFileName + #DQUOTE$ + ", #PB_FileSystem_Force)", nDelResult)
        If nDelResult
          ; delete was successful
          bTemplateDeleted = #True
          ; now delete the associated device map file, bak file, and database file (which may or may not exist)
          sTemplateDevMapFileName = ignoreExtension(sTemplateFileName) + ".scstd"
          nDelResult = DeleteFile(sTemplateDevMapFileName, #PB_FileSystem_Force)
          debugMsg2(sProcName, "DeleteFile(" + #DQUOTE$ + sTemplateDevMapFileName + #DQUOTE$ + ", #PB_FileSystem_Force)", nDelResult)
          sTemplateDatabaseFileName = ignoreExtension(sTemplateFileName) + ".scsdb"
          nDelResult = DeleteFile(sTemplateDatabaseFileName, #PB_FileSystem_Force)
          sTemplateBakFileName = ignoreExtension(sTemplateFileName) + ".bak"
          nDelResult = DeleteFile(sTemplateBakFileName, #PB_FileSystem_Force)
        EndIf
        If bTemplateDeleted
          ; reload the templates array and redisplay the template list
          debugMsg(sProcName, "calling loadTemplatesArray()")
          loadTemplatesArray()
          debugMsg(sProcName, "calling WTM_drawTemplateList(" + #DQUOTE$ + sNextName + #DQUOTE$ + ")")
          WTM_drawTemplateList(sNextName) ; nb sNextName will be blank if deleting the only template in the list
        EndIf
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_btnBack_Click()
  Protected nIndex
  
  nIndex = GGS(WTM\pnlProps) - 1
  If nIndex >= 0
    SGS(WTM\pnlProps, nIndex)
  EndIf
  WTM_setButtons()
  
EndProcedure

Procedure WTM_btnNext_Click()
  Protected nIndex
  
  nIndex = GGS(WTM\pnlProps) + 1
  If nIndex <= (CountGadgetItems(WTM\pnlProps) - 1)
    SGS(WTM\pnlProps, nIndex)
  EndIf
  WTM_setButtons()
  
EndProcedure

Procedure WTM_btnQuickEdit_Click()
  PROCNAMEC()
  
  grWTM\bEditing = #True
  grWTM\bNewTemplate = #False
  WTM_displayTemplate()
  
  ; set the checkbox in the cues header
  grWTM\rCuesHDItem\mask = #HDI_FORMAT
  grWTM\rCuesHDItem\fmt = #HDF_CHECKBOX|#HDF_FIXEDWIDTH|#HDF_CHECKED
  SendMessage_(grWTM\nCuesHeader, #HDM_SETITEM, 0, grWTM\rCuesHDItem)
  ; set the checkbox in the devices header
  grWTM\rDevsHDItem\mask = #HDI_FORMAT
  grWTM\rDevsHDItem\fmt = #HDF_CHECKBOX|#HDF_FIXEDWIDTH|#HDF_CHECKED
  SendMessage_(grWTM\nDevsHeader, #HDM_SETITEM, 0, grWTM\rDevsHDItem)
  ; set the checkbox in the device maps header
  grWTM\rDevMapsHDItem\mask = #HDI_FORMAT
  grWTM\rDevMapsHDItem\fmt = #HDF_CHECKBOX|#HDF_FIXEDWIDTH|#HDF_CHECKED
  SendMessage_(grWTM\nDevMapsHeader, #HDM_SETITEM, 0, grWTM\rDevMapsHDItem)

  
EndProcedure

Procedure WTM_btnCreateCueFile_Click()
  PROCNAMEC()
  ; create a cue file from a template
  Protected nIndex
  Protected sFileName.s, sName.s
  Protected sReqTitle.s, sReqHeading.s, sReqItem.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    nIndex = GGS(WTM\grdTemplates)
    If nIndex >= 0
      sFileName = gaTemplate(nIndex)\sCurrTemplateFileName
      sName = gaTemplate(nIndex)\sName
      If FileExists(sFileName, #False)
        \nAction = #SCS_ACTION_NONE
        \sSelectedFileName = sFileName
        debugMsg(sProcName, "grAction\sSelectedFileName=" + #DQUOTE$ + \sSelectedFileName + #DQUOTE$)
        sReqTitle = Lang("Actions", "PrTitle")
        sReqHeading = LangPars("Actions", "PrHeading", #DQUOTE$ + sName + #DQUOTE$)
        sReqItem = Lang("WEP", "lblTitle")  ; "Name of Production"
        WIR_Form_Show(#True, #WTM, #SCS_IR_PROD_TITLE, #SCS_ACTION_CREATE_FROM_TEMPLATE, sReqTitle, sReqHeading, sReqItem)
        ProcedureReturn
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_btnCreateTemplate_Click()
  PROCNAMEC()
  ; create a template from a cue file
  Protected sFileName.s, sName.s
  Protected sReqTitle.s, sReqHeading.s, sReqItem.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    sFileName = gsCueFile
    sName = grProd\sTitle
    If FileExists(sFileName, #False)
      \nAction = #SCS_ACTION_NONE
      \sSelectedFileName = sFileName
      debugMsg(sProcName, "grAction\sSelectedFileName=" + #DQUOTE$ + \sSelectedFileName + #DQUOTE$)
      sReqTitle = Lang("Actions", "TmTitle")
      sReqHeading = LangPars("Actions", "TmHeading", #DQUOTE$ + sName + #DQUOTE$)
      sReqItem = Lang("WTM", "lblTmName")  ; "Template Name"
      WIR_Form_Show(#True, #WTM, #SCS_IR_TEMPLATE_NAME, #SCS_ACTION_CREATE_TEMPLATE_FROM_CUEFILE, sReqTitle, sReqHeading, sReqItem)
      ProcedureReturn
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_createTemplateFromCueFile(sCueFile.s, sTemplateName.s)
  PROCNAMEC()
  Protected nArraySize
  Protected i
  Protected nSubPtr
  Protected nTemplatePtr
  Protected sTemplateFileName.s, sTemplateDevMapFileName.s, sTemplateDatabaseFileName.s, sTemplateBakFileName.s
  Protected sOrigDevMapFileName.s, sOrigDatabaseFileName.s, sOrigBakFileName.s
  
  debugMsg(sProcName, #SCS_START)
  
  sTemplateFileName = gsTemplatesFolder + sTemplateName + ".scstm"
  sTemplateDevMapFileName = ignoreExtension(sTemplateFileName) + ".scstd"
  sTemplateDatabaseFileName = ignoreExtension(sTemplateFileName) + ".scsdb"
  sTemplateBakFileName = ignoreExtension(sTemplateFileName) + ".bak"
  
  sOrigDevMapFileName = gsDevMapsPath + ignoreExtension(GetFilePart(sCueFile)) + "_" + grProd\sProdId + ".scsd"
  If FileExists(sOrigDevMapFileName, #False) = #False
    sOrigDevMapFileName = gsDevMapsPath + ignoreExtension(GetFilePart(sCueFile)) + ".scsd"
    If FileExists(sOrigDevMapFileName, #False) = #False
      sOrigDevMapFileName = ""
    EndIf
  EndIf
  sOrigDatabaseFileName = ignoreExtension(sCueFile) + ".scsdb"
  If FileExists(sOrigDatabaseFileName, #False) = #False
    sOrigDatabaseFileName = ""
  EndIf
  sOrigBakFileName = ignoreExtension(sCueFile) + ".bak"
  If FileExists(sOrigBakFileName, #False) = #False
    sOrigBakFileName = ""
  EndIf
  
  nTemplatePtr = gnTemplateCount
  If nTemplatePtr > ArraySize(gaTemplate())
    ReDim gaTemplate(nTemplatePtr)
  EndIf
  gaTemplate(nTemplatePtr) = grTemplateDef
  With gaTemplate(nTemplatePtr)
    \sName = sTemplateName
    \sCurrTemplateFileName = sTemplateFileName
    \sCurrTemplateDevMapFileName = sTemplateDevMapFileName
    \sCurrTemplateDatabaseFileName = sTemplateDatabaseFileName
    \sCurrTemplateBakFileName = sTemplateBakFileName
    \sCueFileName = sCueFile
    \sDevMapFileName = sOrigDevMapFileName
    \sDatabaseFileName = sOrigDatabaseFileName
    \sBakFileName = sOrigBakFileName
  EndWith
  gnTemplateCount + 1
  
  nArraySize = ArraySize(aCue())
  ReDim gaTmCue(nArraySize)
  gnLastTmCue = gnLastCue
  For i = 1 To gnLastTmCue
    With gaTmCue(i)
      \sCue = aCue(i)\sCue
      \sCueDescr = aCue(i)\sCueDescr
      nSubPtr = aCue(i)\nFirstSubIndex
      If nSubPtr >= 0
        \sCueType = decodeSubTypeL(aSub(nSubPtr)\sSubType, nSubPtr)
      Else
        \sCueType = ""
      EndIf
      \sColorCode = aCue(i)\sColorCode
      \nBackColor = aCue(i)\nBackColor
      \nTextColor = aCue(i)\nTextColor
      \bIncludeCue = #True
    EndWith
    debugMsg(sProcName, "gaTmCue(" + i + ")\sCue=" + gaTmCue(i)\sCue)
  Next i
  
  grWTM\bEditing = #True
  grWTM\bNewTemplate = #True
  debugMsg(sProcName, "calling WTM_drawTemplateList(" + sTemplateName + ")")
  WTM_drawTemplateList(sTemplateName)
  
  SGS(WTM\pnlProps, 0)
  SAG(WTM\edgTmDesc)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_btnSaveAs_Click()
  PROCNAMEC()
  ; create a copy of this template
  Protected sFileName.s, sName.s
  Protected sReqTitle.s, sReqHeading.s, sReqItem.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    sFileName = grTmTemplate\sCurrTemplateFileName
    sName = grTmTemplate\sName
    If FileExists(sFileName, #False)
      \nAction = #SCS_ACTION_NONE
      \sSelectedFileName = sFileName
      debugMsg(sProcName, "grAction\sSelectedFileName=" + #DQUOTE$ + \sSelectedFileName + #DQUOTE$)
      sReqTitle = Lang("Actions", "SaTitle")
      sReqHeading = LangPars("Actions", "SaHeading", #DQUOTE$ + sName + #DQUOTE$)
      sReqItem = Lang("Actions", "SaItem")
      WIR_Form_Show(#True, #WTM, #SCS_IR_TEMPLATE_NAME, #SCS_ACTION_SAVE_AS_TEMPLATE, sReqTitle, sReqHeading, sReqItem)
      ProcedureReturn
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_saveAsTemplate(sOrigTemplateFileName.s, sNewTemplateName.s)
  PROCNAMEC()
  Protected sNewTemplateFileName.s
  Protected sOrigTemplateDevMapFileName.s, sNewTemplateDevMapFileName.s
  Protected sOrigTemplateDatabaseFileName.s, sNewTemplateDatabaseFileName.s
  
  debugMsg(sProcName, #SCS_START + ", sOrigTemplateFileName=" + #DQUOTE$ + sOrigTemplateFileName + #DQUOTE$ + ", sNewTemplateName=" + #DQUOTE$ + sNewTemplateName + #DQUOTE$)
  
  sOrigTemplateDevMapFileName = ignoreExtension(sOrigTemplateFileName) + ".scstd"
  sOrigTemplateDatabaseFileName = ignoreExtension(sOrigTemplateFileName) + ".scsdb"
  sNewTemplateFileName = gsTemplatesFolder + sNewTemplateName + ".scstm"
  sNewTemplateDevMapFileName = ignoreExtension(sNewTemplateFileName) + ".scstd"
  sNewTemplateDatabaseFileName = ignoreExtension(sNewTemplateFileName) + ".scsdb"
  
  ; warning: these CopyFile() commands will create the new template and associated devmap files, but will not update the <FileSaveInfo> items, but they only exist for debugging purposes
  If CopyFile(sOrigTemplateFileName, sNewTemplateFileName)
    CopyFile(sOrigTemplateDevMapFileName, sNewTemplateDevMapFileName)
    CopyFile(sOrigTemplateDatabaseFileName, sNewTemplateDatabaseFileName)
  EndIf
  
  loadTemplatesArray()
  grWTM\bEditing = #False
  grWTM\bNewTemplate = #False
  debugMsg(sProcName, "calling WTM_drawTemplateList(" + sNewTemplateName + ")")
  WTM_drawTemplateList(sNewTemplateName)
  If IsWindow(#WLP)
    WLP_setIndexWithinChoice(#SCS_CHOICE_TEMPLATE, sNewTemplateFileName)
  EndIf
  SGS(WTM\pnlProps, 0)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_btnFullEdit_Click()
  PROCNAMEC()
  Protected nIndex
  Protected sFileName.s
  Protected sTitle.s, sMessage.s, nResponse
  Protected bOkToEdit
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = GGS(WTM\grdTemplates)
  If nIndex >= 0
    sFileName = gaTemplate(nIndex)\sCurrTemplateFileName
    If FileExists(sFileName, #False)
      If gsCueFile
        sTitle = GGT(WTM\btnFullEdit)
        sMessage = Lang("WTM", "EditWarn")
        nResponse = scsMessageRequester(sTitle, sMessage, #MB_ICONEXCLAMATION|#PB_MessageRequester_YesNo)
        If nResponse = #PB_MessageRequester_Yes
          bOkToEdit = #True
        EndIf
      Else
        bOkToEdit = #True
      EndIf
    EndIf
  EndIf
  
  If bOkToEdit
    With grAction
      \sSelectedFileName = sFileName
      \nAction = #SCS_ACTION_EDIT_TEMPLATE
      \nParentWindow = #WTM
      WTM_Form_Unload(#True)
      gqMainThreadRequest | #SCS_MTH_PROCESS_ACTION
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_applyChanges()
  PROCNAMEC()
  Protected bCreateFromCueFile
  Protected sOrigTemplateFileName.s, sCurrTemplateFileName.s
  Protected sOrigTemplateDevMapFileName.s
  Protected sOrigTemplateDatabaseFileName.s
  Protected sOrigTemplateBakFile.s
  Protected nDelResult
  
  debugMsg(sProcName, #SCS_START)
  
  With grWTM
    If \nTemplatePtr >= 0
      If \bNewTemplate
        bCreateFromCueFile = #True
      Else
        sOrigTemplateFileName = gaTemplate(\nTemplatePtr)\sOrigTemplateFileName
        sCurrTemplateFileName = grTmTemplate\sCurrTemplateFileName
        sOrigTemplateDevMapFileName = gaTemplate(\nTemplatePtr)\sOrigTemplateDevMapFileName
        sOrigTemplateDatabaseFileName = gaTemplate(\nTemplatePtr)\sOrigTemplateDatabaseFileName
        sOrigTemplateBakFile = gaTemplate(\nTemplatePtr)\sOrigTemplateBakFileName
      EndIf
      gaTemplate(\nTemplatePtr) = grTmTemplate
      debugMsg(sProcName, "calling saveXMLTemplateFile(" + \nTemplatePtr + ", " + strB(bCreateFromCueFile) + ")")
      saveXMLTemplateFile(\nTemplatePtr, bCreateFromCueFile)
      debugMsg(sProcName, "calling saveXMLTemplateDevMapFile(" + \nTemplatePtr + ", " + strB(bCreateFromCueFile) + ")")
      saveXMLTemplateDevMapFile(\nTemplatePtr, bCreateFromCueFile)
      If bCreateFromCueFile = #False
        If LCase(sCurrTemplateFileName) <> LCase(sOrigTemplateFileName)
          ; template name must have been changed (other than just a case-change)
          If FileExists(sCurrTemplateFileName) ; nb delete the old template file IF the new template file was successfully created
            nDelResult = DeleteFile(sOrigTemplateFileName, #PB_FileSystem_Force)
            debugMsg2(sProcName, "DeleteFile(" + #DQUOTE$ + sOrigTemplateFileName + #DQUOTE$ + ", #PB_FileSystem_Force)", nDelResult)
            If nDelResult
              ; delete was successful, so now delete the associated device map, database and bak files
              nDelResult = DeleteFile(sOrigTemplateDevMapFileName, #PB_FileSystem_Force)
              debugMsg2(sProcName, "DeleteFile(" + #DQUOTE$ + sOrigTemplateDevMapFileName + #DQUOTE$ + ", #PB_FileSystem_Force)", nDelResult)
              nDelResult = DeleteFile(sOrigTemplateDatabaseFileName, #PB_FileSystem_Force)
              debugMsg2(sProcName, "DeleteFile(" + #DQUOTE$ + sOrigTemplateDatabaseFileName + #DQUOTE$ + ", #PB_FileSystem_Force)", nDelResult)
              nDelResult = DeleteFile(sOrigTemplateBakFile, #PB_FileSystem_Force)
              debugMsg2(sProcName, "DeleteFile(" + #DQUOTE$ + sOrigTemplateBakFile + #DQUOTE$ + ", #PB_FileSystem_Force)", nDelResult)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    \bEditing = #False
    \bNewTemplate = #False
    debugMsg(sProcName, "calling loadTemplatesArray()")
    loadTemplatesArray()
    If IsWindow(#WLP)
      WLP_setIndexWithinChoice(#SCS_CHOICE_TEMPLATE, sCurrTemplateFileName)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_btnSave_Click()
  PROCNAMEC()
  Protected bValResult
  Protected sTemplateName.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grWTM
    If \nTemplatePtr >= 0
      bValResult = WTM_valTemplate()
      debugMsg(sProcName, "WTM_valTemplate() returned " + strB(bValResult))
      If bValResult
        sTemplateName = grTmTemplate\sName  ; save for re-aligning display after re-loading and re-displaying the templates array
        WTM_applyChanges()
        debugMsg(sProcName, "calling WTM_drawTemplateList(" + #DQUOTE$ + sTemplateName + #DQUOTE$ + ")")
        WTM_drawTemplateList(sTemplateName)
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_discardChanges()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grWTM
    \bEditing = #False
    \bNewTemplate = #False
    debugMsg(sProcName, "calling loadTemplatesArray()")
    loadTemplatesArray()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_btnDiscard_Click()
  PROCNAMEC()
  Protected sTemplateName.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWTM\nTemplatePtr >= 0
    sTemplateName = gaTemplate(grWTM\nTemplatePtr)\sName  ; save for re-aligning display after re-loading and re-displaying the templates array
    EndIf
  WTM_discardChanges()
  debugMsg(sProcName, "calling WTM_drawTemplateList(" + #DQUOTE$ + sTemplateName + #DQUOTE$ + ")")
  WTM_drawTemplateList(sTemplateName)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_txtTmName_Validate()
  PROCNAMEC()
  Protected sTemplateName.s
  
  debugMsg(sProcName, #SCS_START)
  
  With WTM
    If valTemplateName(\lblTmName, \txtTmName) = #False
      ProcedureReturn #False
    EndIf
    sTemplateName = Trim(GGT(\txtTmName))
    grTmTemplate\sName = sTemplateName
    grTmTemplate\sCurrTemplateFileName = gsTemplatesFolder + sTemplateName + ".scstm"
    grTmTemplate\sCurrTemplateDevMapFileName = gsTemplatesFolder + sTemplateName + ".scstd"
    grTmTemplate\sCurrTemplateDatabaseFileName = gsTemplatesFolder + sTemplateName + ".scsdb"
    grTmTemplate\sCurrTemplateBakFileName = gsTemplatesFolder + sTemplateName + ".bak"
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WTM_edgTmDesc_Validate()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With WTM
    grTmTemplate\sDesc = Trim(GGT(\edgTmDesc))
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTM_setIncludeCueFlags()
  Protected n
  
  For n = 1 To gnLastTmCue
    If GetGadgetItemState(WTM\grdCuesChk, (n-1)) & #PB_ListIcon_Checked
      gaTmCue(n)\bIncludeCue = #True
    Else
      gaTmCue(n)\bIncludeCue = #False
    EndIf
  Next n
  
EndProcedure
  
Procedure WTM_setIncludeDevFlags()
  Protected n
  
  For n = 0 To gnLastTmDev
    If GetGadgetItemState(WTM\grdDevsChk, n) & #PB_ListIcon_Checked
      gaTmDev(n)\bIncludeDev = #True
    Else
      gaTmDev(n)\bIncludeDev = #False
    EndIf
  Next n
  
EndProcedure
  
Procedure WTM_setIncludeDevMapFlags()
  Protected n
  
  For n = 0 To gnLastTmDevMap
    If GetGadgetItemState(WTM\grdDevMapsChk, n) & #PB_ListIcon_Checked
      gaTmDevMap(n)\bIncludeDevMap = #True
    Else
      gaTmDevMap(n)\bIncludeDevMap = #False
    EndIf
  Next n
  
EndProcedure
  
Procedure WTM_headerCheckBox_Click()
  Protected nGadgetNo ;, nState
  
  nGadgetNo = EventGadget()
  ; nState = EventData()
  
  Select nGadgetNo
    Case WTM\grdCuesChk
      WTM_setIncludeCueFlags()
    Case WTM\grdDevsChk
      WTM_setIncludeDevFlags()
    Case WTM\grdDevMapsChk
      WTM_setIncludeDevMapFlags()
  EndSelect
  
EndProcedure

Procedure WTM_grdCuesChk_Click()
  WTM_setIncludeCueFlags()
EndProcedure

Procedure WTM_grdDevsChk_Click()
  WTM_setIncludeDevFlags()
EndProcedure

Procedure WTM_grdDevMapsChk_Click()
  WTM_setIncludeDevMapFlags()
EndProcedure

Procedure WTM_EventHandler()
  PROCNAMEC()
  Protected nRow
  
  With WTM
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WTM_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnBack
            WTM_btnBack_Click()
            
          Case \btnCreateCueFile
            WTM_btnCreateCueFile_Click()
            
          Case \btnCreateTemplate
            WTM_btnCreateTemplate_Click()
            
          Case \btnClose
            WTM_Form_Unload()
            
          Case \btnDelete
            WTM_btnDelete_Click()
            
          Case \btnDiscard
            WTM_btnDiscard_Click()
            
          Case \btnFullEdit
            WTM_btnFullEdit_Click()
            
          Case \btnHelp
            displayHelpTopic("templates.htm")
            
          Case \btnNext
            WTM_btnNext_Click()
            
          Case \btnQuickEdit
            WTM_btnQuickEdit_Click()
            
          Case \btnSave
            WTM_btnSave_Click()
            
          Case \btnSaveAs
            WTM_btnSaveAs_Click()
            
          Case \edgTmDesc
            If gnEventType = #PB_EventType_LostFocus
              WTM_edgTmDesc_Validate()
            EndIf
            
          Case \grdCuesChk
            If gnEventType = #PB_EventType_LeftClick
              WTM_grdCuesChk_Click()
            EndIf
            
          Case \grdCuesNoChk
            ; no action
            
          Case \grdDevsChk
            If gnEventType = #PB_EventType_LeftClick
              WTM_grdDevsChk_Click()
            EndIf
            
          Case \grdDevsNoChk
            ; no action
            
          Case \grdDevMapsChk
            If gnEventType = #PB_EventType_LeftClick
              WTM_grdDevMapsChk_Click()
            EndIf
            
          Case \grdDevMapsNoChk
            ; no action
            
          Case \grdTemplates
            If gnEventType = #PB_EventType_LeftClick
              WTM_displayTemplate()
            EndIf
            
          Case \pnlProps
            If gnEventType = #PB_EventType_Change
              WTM_setButtons()
            EndIf
            
          Case \txtTmName
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WTM_txtTmName_Validate())
            EndIf

          Default
            ; debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName( gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #SCS_Event_Header_CheckBox_Click
        WTM_headerCheckBox_Click()
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WTM_windowCallback(hwnd, uMsg, wParam, lParam)
  ; callback as part of the processing required to support a checkbox in a ListIconGadget header
  ; based on code supplied by RASHAD in reply to my PB Forum Topic "ListIconGadget checkbox in column header?" posted in Oct 2016
  PROCNAMEC()
  Protected nResult = #PB_ProcessPureBasicEvents
  Protected lvi.LV_ITEM
  Protected *pnmh.NMHEADER
  
  With grWTM
    Select uMsg
      Case #WM_NOTIFY
        *pnmh.NMHEADER = lParam
        Select *pnmh\hdr\hwndFrom
          Case \nCuesHeader
            Select *pnmh\hdr\code
              Case #HDN_ITEMSTATEICONCLICK
                SendMessage_(\nCuesHeader,#HDM_GETITEM,0,\rCuesHDItem)
                If \rCuesHDItem\fmt & #HDF_CHECKED
                  lvi\mask = #LVIF_STATE
                  lvi\stateMask = #LVIS_STATEIMAGEMASK
                  lvi\state = #LVIS_UNCHECKED
                  SendMessage_(GadgetID(WTM\grdCuesChk),#LVM_SETITEMSTATE,-1,lvi)
                  PostEvent(#SCS_Event_Header_CheckBox_Click, #WTM, WTM\grdCuesChk, 0, 0)
                Else
                  lvi\mask = #LVIF_STATE
                  lvi\stateMask = #LVIS_STATEIMAGEMASK
                  lvi\state = #LVIS_CHECKED
                  SendMessage_(GadgetID(WTM\grdCuesChk),#LVM_SETITEMSTATE,-1,lvi)
                  PostEvent(#SCS_Event_Header_CheckBox_Click, #WTM, WTM\grdCuesChk, 0, 1)
                EndIf
            EndSelect
        
          Case \nDevsHeader
            Select *pnmh\hdr\code
              Case #HDN_ITEMSTATEICONCLICK
                SendMessage_(\nDevsHeader,#HDM_GETITEM,0,\rDevsHDItem)
                If \rDevsHDItem\fmt & #HDF_CHECKED
                  lvi\mask = #LVIF_STATE
                  lvi\stateMask = #LVIS_STATEIMAGEMASK
                  lvi\state = #LVIS_UNCHECKED
                  SendMessage_(GadgetID(WTM\grdDevsChk),#LVM_SETITEMSTATE,-1,lvi)
                  PostEvent(#SCS_Event_Header_CheckBox_Click, #WTM, WTM\grdDevsChk, 0, 0)
                Else
                  lvi\mask = #LVIF_STATE
                  lvi\stateMask = #LVIS_STATEIMAGEMASK
                  lvi\state = #LVIS_CHECKED
                  SendMessage_(GadgetID(WTM\grdDevsChk),#LVM_SETITEMSTATE,-1,lvi)
                  PostEvent(#SCS_Event_Header_CheckBox_Click, #WTM, WTM\grdDevsChk, 0, 1)
                EndIf
            EndSelect
            
          Case \nDevMapsHeader
            Select *pnmh\hdr\code
              Case #HDN_ITEMSTATEICONCLICK
                SendMessage_(\nDevMapsHeader,#HDM_GETITEM,0,\rDevMapsHDItem)
                If \rDevMapsHDItem\fmt & #HDF_CHECKED
                  lvi\mask = #LVIF_STATE
                  lvi\stateMask = #LVIS_STATEIMAGEMASK
                  lvi\state = #LVIS_UNCHECKED
                  SendMessage_(GadgetID(WTM\grdDevMapsChk),#LVM_SETITEMSTATE,-1,lvi)
                  PostEvent(#SCS_Event_Header_CheckBox_Click, #WTM, WTM\grdDevMapsChk, 0, 0)
                Else
                  lvi\mask = #LVIF_STATE
                  lvi\stateMask = #LVIS_STATEIMAGEMASK
                  lvi\state = #LVIS_CHECKED
                  SendMessage_(GadgetID(WTM\grdDevMapsChk),#LVM_SETITEMSTATE,-1,lvi)
                  PostEvent(#SCS_Event_Header_CheckBox_Click, #WTM, WTM\grdDevMapsChk, 0, 1)
                EndIf
            EndSelect
            
        EndSelect
    EndSelect
  EndWith
  ProcedureReturn nResult
EndProcedure

Procedure WTM_valTemplate()
  PROCNAMEC()
  Protected i, j, k, d, h, m
  Protected bValidationOK = #True
  Protected sMsg.s, nResponse
  Protected nTemplatePtr
  Protected n1, n2
  Protected sCue1.s, sCue2.s, sCheckThisCue.s
  Protected nDevType1, sLogicalDev1.s
  Protected bCue2Included, bCue2RefersToCue1, bCue2RefersToDev1
  Protected nIncludedDevs, nExcludedDevs, nIncludedDevMaps, nExcludedDevMaps
  
  debugMsg(sProcName, #SCS_START)
  
  nTemplatePtr = grWTM\nTemplatePtr
  If nTemplatePtr >= 0
    With gaTemplate(nTemplatePtr)
      If FileExists(\sCurrTemplateFileName)
        gs2ndCueFile = \sCurrTemplateFileName
        gs2ndCueFolder = GetPathPart(gs2ndCueFile)
        debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
        open2ndSCSCueFile()
        If gb2ndCueFileOpen
          If gb2ndXMLFormat
            debugMsg(sProcName, "calling readXMLCueFile(" + Str(gn2ndCueFileNo) + ", #False, " + gn2ndCueFileStringFormat + ", " + GetFilePart(\sCurrTemplateFileName) + ", #False, #True)")
            readXMLCueFile(gn2ndCueFileNo, #False, gn2ndCueFileStringFormat, \sCurrTemplateFileName, #False, #True)
            debugMsg(sProcName, "returned from readXMLCueFile()")
          EndIf
          close2ndSCSCueFile(gn2ndCueFileNo)
        EndIf
      EndIf
    EndWith
  EndIf
  
  For n1 = 1 To gnLastTmCue
    If gaTmCue(n1)\bIncludeCue = #False
      sCue1 = gaTmCue(n1)\sCue
      debugMsg(sProcName, "sCue1=" + sCue1)
      For i = 1 To gn2ndLastCue
        If i <> n1
          With a2ndCue(i)
            sCue2 = \sCue
            ; debugMsg(sProcName, "sCue2=" + sCue2)
            bCue2RefersToCue1 = #False
            bCue2Included = #False
            For n2 = 1 To gnLastTmCue
              If gaTmCue(n2)\sCue = sCue2
                If gaTmCue(n2)\bIncludeCue
                  bCue2Included = #True
                EndIf
                Break
              EndIf
            Next n2
            If bCue2Included
              Select \nActivationMethod
                Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
                  If \nAutoActPosn <> #SCS_ACPOSN_LOAD
                    If \sAutoActCue = sCue1
                      bCue2RefersToCue1 = #True
                      Break
                    EndIf
                  EndIf
              EndSelect
              j = \nFirstSubIndex
              While j >= 0
                ; debugMsg(sProcName, "sCue2=" + sCue2 + ", a2ndSub(" + j + ")\sSubType=" + a2ndSub(j)\sSubType)
                sCheckThisCue = ""
                Select a2ndSub(j)\sSubType
                  Case "G"  ; go to cue
                    sCheckThisCue = a2ndSub(j)\sCueToGoTo
                    
                  Case "J"  ; enabe/disable cues
                    For h = 0 To #SCS_MAX_ENABLE_DISABLE
                      If a2ndSub(j)\aEnableDisable[h]\sFirstCue = sCue1 Or a2ndSub(j)\aEnableDisable[h]\sLastCue = sCue1
                        bCue2RefersToCue1 = #True
                        Break
                      EndIf
                    Next h
                    
                  Case "L"  ; level change
                    sCheckThisCue = a2ndSub(j)\sLCCue
                    
                  Case "Q" ; call cue
                    sCheckThisCue = a2ndSub(j)\sCallCue
                    
                  Case "S"  ; SFR
                    For h = 0 To #SCS_MAX_SFR
                      debugMsg(sProcName, "a2ndSub(" + j + ")\nSFRCueType[" + h + "]=" + decodeSFRCueType(a2ndSub(j)\nSFRCueType[h]) + ", a2ndSub(" + j + ")\sSFRCue[" + h + "]=" + a2ndSub(j)\sSFRCue[h])
                      Select a2ndSub(j)\nSFRCueType[h]
                        Case #SCS_SFR_CUE_SEL, #SCS_SFR_CUE_ALLEXCEPT, #SCS_SFR_CUE_PLAYEXCEPT
                          If a2ndSub(j)\sSFRCue[h] = sCue1
                            bCue2RefersToCue1 = #True
                            Break
                          EndIf
                      EndSelect
                    Next h
                    
                  Case "T"  ; set position
                    sCheckThisCue = a2ndSub(j)\sSetPosCue
                    
                EndSelect
                If (sCheckThisCue = sCue1) Or (bCue2RefersToCue1)
                  bCue2RefersToCue1 = #True
                  Break
                EndIf
                j = a2ndSub(j)\nNextSubIndex
              Wend
              If bCue2RefersToCue1
                Break
              EndIf
            EndIf
          EndWith
        EndIf
      Next i
      If bCue2RefersToCue1
        Break
      EndIf
    EndIf
  Next n1
  
  If bCue2RefersToCue1
    sMsg = LangPars("Errors", "CannotExcludeCue", sCue1, sCue2)
    bValidationOK = #False
  EndIf
  
  ; now check devices that have been marked for exclusion
  If bValidationOK
    For n1 = 0 To gnLastTmDev
      If gaTmDev(n1)\bIncludeDev = #False
        nDevType1 = gaTmDev(n1)\nDevType
        sLogicalDev1 = gaTmDev(n1)\sLogicalDev
        If sLogicalDev1
          debugMsg(sProcName, "nDevType1=" + decodeDevType(nDevType1) + ", sLogicalDev1=" + sLogicalDev1)
          For i = 1 To gn2ndLastCue
            sCue2 = a2ndCue(i)\sCue
            bCue2RefersToDev1 = #False
            bCue2Included = #False
            For n2 = 1 To gnLastTmCue
              If gaTmCue(n2)\sCue = sCue2
                If gaTmCue(n2)\bIncludeCue
                  bCue2Included = #True
                EndIf
                Break
              EndIf
            Next n2
            If bCue2Included
              j = a2ndCue(i)\nFirstSubIndex
              While j >= 0
                debugMsg(sProcName, "sCue2=" + sCue2 + ", a2ndSub(" + j + ")\sSubType=" + a2ndSub(j)\sSubType)
                sCheckThisCue = ""
                Select a2ndSub(j)\sSubType
                  Case "A"
                    If nDevType1 = #SCS_DEVTYPE_VIDEO_AUDIO
                      If a2ndSub(j)\sVidAudLogicalDev = sLogicalDev1
                        bCue2RefersToDev1 = #True
                        Break
                      EndIf
                    EndIf
                    
                  Case "F"
                    If nDevType1 = #SCS_DEVTYPE_AUDIO_OUTPUT
                      k = a2ndSub(j)\nFirstAudIndex
                      If k >= 0
                        For d = 0 To grLicInfo\nMaxAudDevPerAud
                          If a2ndAud(k)\sLogicalDev[d] = sLogicalDev1
                            bCue2RefersToDev1 = #True
                            Break
                          EndIf
                        Next d
                      EndIf
                    EndIf
                    
                  Case "K"
                    If nDevType1 = #SCS_DEVTYPE_LT_DMX_OUT
                      If a2ndSub(j)\sLTLogicalDev = sLogicalDev1
                        bCue2RefersToDev1 = #True
                        Break
                      EndIf
                    EndIf
                    
                  Case "M"
                    For m = 0 To #SCS_MAX_CTRL_SEND
                      If a2ndSub(j)\aCtrlSend[m]\nDevType = nDevType1
                        If a2ndSub(j)\aCtrlSend[m]\sCSLogicalDev = sLogicalDev1
                          bCue2RefersToDev1 = #True
                          Break
                        EndIf
                      EndIf
                    Next m
                    
                  Case "P"
                    If nDevType1 = #SCS_DEVTYPE_AUDIO_OUTPUT
                      For d = 0 To grLicInfo\nMaxAudDevPerSub
                        If a2ndSub(j)\sPLLogicalDev[d] = sLogicalDev1
                          bCue2RefersToDev1 = #True
                          Break
                        EndIf
                      Next d
                    EndIf
                    
                EndSelect
                If bCue2RefersToDev1
                  Break
                EndIf
                j = a2ndSub(j)\nNextSubIndex
              Wend
              If bCue2RefersToDev1
                Break
              EndIf
            EndIf
          Next i
          If bCue2RefersToDev1
            Break
          EndIf
        EndIf
      EndIf
    Next n1
  EndIf
    
  If bCue2RefersToDev1
    sMsg = LangPars("Errors", "CannotExcludeDev", decodeDevTypeL(nDevType1), sLogicalDev1, sCue2)
    bValidationOK = #False
  EndIf
  
  If bValidationOK = #False
    debugMsg(sProcName, sMsg)
    scsMessageRequester(GWT(#WTM), sMsg, #PB_MessageRequester_Error)
  EndIf

  If bValidationOK
    For d = 0 To gnLastTmDev
      If gaTmDev(d)\bIncludeDev
        nIncludedDevs + 1
      Else
        nExcludedDevs + 1
      EndIf
    Next d
    If (nIncludedDevs = 0) And (nExcludedDevs > 0)
      sMsg = Lang("WTM", "DelAllDevs")
      nResponse = scsMessageRequester(GWT(#WTM), sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nResponse = #PB_MessageRequester_No
        bValidationOK = #False
      EndIf
    EndIf
  EndIf
  
  If bValidationOK
    For d = 0 To gnLastTmDevMap
      If gaTmDevMap(d)\bIncludeDevMap
        nIncludedDevMaps + 1
      Else
        nExcludedDevMaps + 1
      EndIf
    Next d
    If (nIncludedDevMaps = 0) And (nExcludedDevMaps > 0)
      sMsg = Lang("WTM", "DelAllDevMaps")
      nResponse = scsMessageRequester(GWT(#WTM), sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nResponse = #PB_MessageRequester_No
        bValidationOK = #False
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + " returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

; EOF
