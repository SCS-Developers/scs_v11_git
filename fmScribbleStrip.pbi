; File: fmScribbleStrip.pbi

EnableExplicit

Procedure WES_Form_Show(pSubPtr, pCtrlSendIndex, pOldMsgType=-1)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WES) = #False
    createfmScribbleStrip()
  EndIf
  setFormPosition(#WES, @grScribbleStripWindow)
  WES_Form_Resized(#True)
  
  With grWES
    \bScribbleStripChanged = #False
    \nSubPtr = pSubPtr
    \nCtrlSendIndex = pCtrlSendIndex
    \nOldMsgType = pOldMsgType
    debugMsg(sProcName, "calling loadCurrScribbleStrip(" + getCueLabel(aSub(pSubPtr)\nCueIndex) + ", " + aSub(pSubPtr)\nSubNo + ", " + pCtrlSendIndex + ")")
    loadCurrScribbleStrip(aSub(pSubPtr)\nCueIndex, aSub(pSubPtr)\nSubNo, pCtrlSendIndex)
    \rScribbleStrip\nMaxScribbleStripItem = grCurrScribbleStrip\nMaxScribbleStripItem
    CopyArray(grCurrScribbleStrip\aScribbleStripItem(), \rScribbleStrip\aScribbleStripItem())
    SGT(WES\txtDevName, aSub(\nSubPtr)\aCtrlSend[\nCtrlSendIndex]\sCSLogicalDev)
    WES_loadPnlCategories()
  EndWith
  setWindowModal(#WES, #True)
  setWindowVisible(#WES, #True)
  SetActiveWindow(#WES)
EndProcedure

Procedure WES_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  
  getFormPosition(#WES, @grScribbleStripWindow, #True)
  If grWES\bScribbleStripChanged
    ensureSplashNotOnTop()
    nResponse = scsMessageRequester(GWT(#WES), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        ProcedureReturn
      Case #PB_MessageRequester_Yes
        WES_applyChanges()
    EndSelect
  EndIf
  unsetWindowModal(#WES)
  scsCloseWindow(#WES)
  If IsWindow(#WED)
    SetActiveWindow(#WED)
    ; now re-display the control send item as some scribble strip item names may have been changed
    WQM_displayCtrlSendItem(grWES\nSubPtr)
  EndIf
EndProcedure

Procedure WES_applyChanges()
  PROCNAMEC()
  Protected u, bChangeFound
  Protected nSubPtr, nCtrlSendIndex, n, nRemDevId, nItemCount, nItemIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nSubPtr = grWES\nSubPtr
  nCtrlSendIndex = grWES\nCtrlSendIndex
  
  With grWES
    ; sort the scribble strip items before saving (this is not essential but makes the cue file easier to follow if there have been many changes to the scribble strip items)
    nRemDevId = aSub(nSubPtr)\aCtrlSend[nCtrlSendIndex]\nRemDevId
    sortScribbleStripItems(nRemDevId, @\rScribbleStrip)
    ; count non-blank items as we only need to save the non-blank items
    nItemCount = 0
    For n = 0 To \rScribbleStrip\nMaxScribbleStripItem
      If Trim(\rScribbleStrip\aScribbleStripItem(n)\sSSItemName)
        nItemCount + 1
      EndIf
    Next n
  EndWith
  
  u = preChangeSubL(bChangeFound, Lang("Ctrl","Scrib"), grWES\nSubPtr, #SCS_UNDO_ACTION_CHANGE, grWES\nCtrlSendIndex, 0, 0, 0, #True)

  With aSub(grWES\nSubPtr)\aCtrlSend[grWES\nCtrlSendIndex]
    If \nMaxScribbleStripItem <> (nItemCount - 1)
      bChangeFound = #True
      \nMaxScribbleStripItem = (nItemCount - 1)
    EndIf
    If \nMaxScribbleStripItem > ArraySize(\aScribbleStripItem())
      ReDim \aScribbleStripItem(\nMaxScribbleStripItem)
    EndIf
    nItemIndex = -1
    For n = 0 To grWES\rScribbleStrip\nMaxScribbleStripItem
      If Trim(grWES\rScribbleStrip\aScribbleStripItem(n)\sSSItemName)
        ; only items with non-blank item names are saved
        nItemIndex + 1
        If bChangeFound = #False
          If \aScribbleStripItem(nItemIndex)\sSSValType <> grWES\rScribbleStrip\aScribbleStripItem(n)\sSSValType Or
             \aScribbleStripItem(nItemIndex)\nSSDataValue <> grWES\rScribbleStrip\aScribbleStripItem(n)\nSSDataValue Or
             \aScribbleStripItem(nItemIndex)\sSSItemName <> grWES\rScribbleStrip\aScribbleStripItem(n)\sSSItemName
            bChangeFound = #True
          EndIf
        EndIf
        \aScribbleStripItem(nItemIndex)\sSSValType = grWES\rScribbleStrip\aScribbleStripItem(n)\sSSValType
        \aScribbleStripItem(nItemIndex)\nSSDataValue = grWES\rScribbleStrip\aScribbleStripItem(n)\nSSDataValue
        \aScribbleStripItem(nItemIndex)\sSSItemName = Trim(grWES\rScribbleStrip\aScribbleStripItem(n)\sSSItemName)
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(grWES\nSubPtr) + ")\aCtrlSend[" + grWES\nCtrlSendIndex + "]\aScribbleStripItem(" + nItemIndex + ")\sSSItemName=" + \aScribbleStripItem(nItemIndex)\sSSItemName)
      EndIf
    Next n
    \nMaxScribbleStripItem = nItemIndex
    debugMsg(sProcName, "calling loadCurrScribbleStrip(" + getCueLabel(aSub(grWES\nSubPtr)\nCueIndex) + ", " + aSub(grWES\nSubPtr)\nSubNo + ", " + grWES\nCtrlSendIndex + ")")
    loadCurrScribbleStrip(aSub(grWES\nSubPtr)\nCueIndex, aSub(grWES\nSubPtr)\nSubNo, grWES\nCtrlSendIndex)
    buildCtrlSendMessage(grWES\nCtrlSendIndex)
    buildDisplayInfoForCtrlSend(@aSub(grWES\nSubPtr), grWES\nCtrlSendIndex)
    updateCtrlSendGrid(grWES\nCtrlSendIndex, #True)
  EndWith
  
  postChangeSubL(u, bChangeFound, grWES\nSubPtr, grWES\nCtrlSendIndex)
  
  updateCtrlSendMsgsForScribbleStripItemNames()
  
  grWES\bScribbleStripChanged = #False
  grWES\nOldMsgType = -1
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WES_undoMsgTypeChange()
  PROCNAMEC()
  
  With grWES
    If \nOldMsgType >= 0
      setGadgetItemByData(WQM\cboMsgType, \nOldMsgType)
      debugMsg(sProcName, "calling WQM_cboMsgType_Click()")
      WQM_cboMsgType_Click()
    EndIf
  EndWith
  
EndProcedure

Procedure WES_pnlCategories_Click()
  PROCNAMEC()
  Protected nRemDevMsgType, sValType.s, sValDesc.s
  
  debugMsg0(sProcName, GetGadgetText(WES\pnlCategories) + ", " + getCurrentItemData(WES\pnlCategories))
  SAG(WES\pnlCategories)
  nRemDevMsgType = getCurrentItemData(WES\pnlCategories)
  sValType = CSRD_GetValTypeForRemDevMsgType(nRemDevMsgType, 1)
  sValDesc = CSRD_GetValDescForRemDevMsgType(nRemDevMsgType, 1)
  WES_loadScribbleStripItems(@aSub(grWES\nSubPtr)\aCtrlSend[grWES\nCtrlSendIndex], sValType, sValDesc)
  
EndProcedure

Procedure WES_txtCategoryItemName_Change(nItemIndex)
  PROCNAMEC()
  Protected nRemDevMsgType, sValType.s, nValBase, nDataValueIndex, sItemName.s, sItemNameTrimmed.s
  
  nRemDevMsgType = getCurrentItemData(WES\pnlCategories)
  sValType = CSRD_GetValTypeForRemDevMsgType(nRemDevMsgType, 1)
  nValBase = CSRD_GetValBaseForRemDevMsgType(nRemDevMsgType, 1)
  nDataValueIndex = nItemIndex + nValBase
  sItemName = GGT(WES\txtCategoryItemName(nItemIndex))
  ; debugMsg0(sProcName, "sValType=" + sValType + ", nItemIndex=" + nItemIndex + ", nValBase=" + nValBase + ", sItemName=" + sItemName)
  sItemNameTrimmed = Trim(sItemName)
  setScribbleStripItemName(@grWES\rScribbleStrip, sValType, nDataValueIndex, sItemNameTrimmed)
  grWES\bScribbleStripChanged = #True
  
EndProcedure

Procedure WES_txtCategoryItemName_Validate(nItemIndex)
  PROCNAMEC()
  Protected nRemDevMsgType, sValType.s, nValBase, nDataValueIndex, sItemName.s, sItemNameTrimmed.s
  
  nRemDevMsgType = getCurrentItemData(WES\pnlCategories)
  sValType = CSRD_GetValTypeForRemDevMsgType(nRemDevMsgType, 1)
  nValBase = CSRD_GetValBaseForRemDevMsgType(nRemDevMsgType, 1)
  nDataValueIndex = nItemIndex + nValBase
  sItemName = GGT(WES\txtCategoryItemName(nItemIndex))
  ; debugMsg0(sProcName, "sValType=" + sValType + ", nItemIndex=" + nItemIndex + ", nValBase=" + nValBase + ", sItemName=" + sItemName)
  sItemNameTrimmed = Trim(sItemName)
  If sItemNameTrimmed <> sItemName
    SGT(WES\txtCategoryItemName(nItemIndex), sItemNameTrimmed)
  EndIf
  setScribbleStripItemName(@grWES\rScribbleStrip, sValType, nDataValueIndex, sItemNameTrimmed)
  grWES\bScribbleStripChanged = #True
  
  ProcedureReturn #True
  
EndProcedure

Procedure WES_EventHandler()
  PROCNAMEC()
  
  With WES
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WES_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        ; debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOK)
              WES_applyChanges()
              WES_Form_Unload()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            grWES\bScribbleStripChanged = #False
            If grWES\nOldMsgType >= 0
              WES_undoMsgTypeChange()
            EndIf
            WES_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            grWES\bScribbleStripChanged = #False
            If grWES\nOldMsgType >= 0
              WES_undoMsgTypeChange()
            EndIf
            WES_Form_Unload()
            
          Case \btnOK
            WES_applyChanges()
            WES_Form_Unload()
            
          Case \cntBelowGrid
            ; no action
            
          Case \pnlCategories
            If gnEventType = #PB_EventType_Change
              WES_pnlCategories_Click()
            EndIf
            
          Case \scaCategoryItems
            ; no action
            
          Case \txtCategoryItemCode(0)
            If gnEventType = #PB_EventType_Focus
              SAG(\txtCategoryItemName(gnEventGadgetArrayIndex))
            EndIf
            
          Case \txtCategoryItemName(0)
            If gnEventType = #PB_EventType_Change
              WES_txtCategoryItemName_Change(gnEventGadgetArrayIndex)
            ElseIf gnEventType = #PB_EventType_LostFocus
              ETVAL(WES_txtCategoryItemName_Validate(gnEventGadgetArrayIndex))
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
        EndSelect
        
      Case #PB_Event_SizeWindow
        WES_Form_Resized()
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WES_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Static nPrevWindowWidth, nPrevWindowHeight
  Protected nLeft, nTop, nWidth, nHeight, nGap
  
  If IsWindow(#WES) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WES
    nWindowWidth = WindowWidth(#WES)
    nWindowHeight = WindowHeight(#WES)
    If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
      nPrevWindowWidth = nWindowWidth
      nPrevWindowHeight = nWindowHeight
      
      ; resize \pnlCategories
      nLeft = GadgetX(\pnlCategories)
      nWidth = nWindowWidth - (nLeft << 1)
      ResizeGadget(\pnlCategories, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
      
      ; resize \scaCategoryItems
      nLeft = GadgetX(\scaCategoryItems)
      nWidth = nWindowWidth - (nLeft << 1)
      nTop = GadgetY(\scaCategoryItems)
      nHeight = nWindowHeight - nTop - GadgetHeight(\cntBelowGrid)
      ResizeGadget(\scaCategoryItems, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
      
      ; reposition and resize \cntBelowGrid
      nTop = nWindowHeight - GadgetHeight(\cntBelowGrid)
      ResizeGadget(\cntBelowGrid,#PB_Ignore,nTop,nWindowWidth,#PB_Ignore)
      nWidth = GadgetX(\btnCancel) + GadgetWidth(\btnCancel) - GadgetX(\btnOK)
      nGap = GadgetX(\btnCancel) - (GadgetX(\btnOK) + GadgetWidth(\btnOK))
      nLeft = (nWindowWidth - nWidth) >> 1
      ResizeGadget(\btnOK, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft + GadgetWidth(\btnOK) + nGap
      ResizeGadget(\btnCancel, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
  EndWith
  
EndProcedure

Procedure WES_loadPnlCategories()
  ; INFO: Modified 6Jan2025 11.10.6cg so that the 'Channel' tab, if present, will be the initially displayed tab.
  ; INFO: Modified after frequent use with the Qu-16 where the first tab is 'Scene' and the second tab is 'Channel', but 'Channel' is the most likely initial requirement.
  PROCNAMEC()
  Protected nRemDevId, nRemDevMsgIndex, sValDesc.s
  Protected Dim sCategory.s(10), Dim nRemDevMsgType(10), nMaxCategoryIndex, n, bFound, nPnlItemCount
  Protected sFirstValType.s, sFirstValDesc.s
  Protected nChannelIndex = -1, nChannelCategory = -1
  
  nMaxCategoryIndex = -1
  nRemDevId = aSub(grWES\nSubPtr)\aCtrlSend[grWES\nCtrlSendIndex]\nRemDevId
  If nRemDevId > 0
    For nRemDevMsgIndex = 0 To grCSRD\nMaxRemDevMsgData
      With grCSRD\aRemDevMsgData(nRemDevMsgIndex)
        If \nCSRD_RemDevId = nRemDevId
          If \bCSRD_ValSS
            If Len(sFirstValType) = 0
              sFirstValType = \sCSRD_ValType
              sFirstValDesc = \sCSRD_ValDesc
            ElseIf LCase(\sCSRD_ValDesc) = "channel" ; Added 6Jan2025 11.01.6cg
              sFirstValType = \sCSRD_ValType
              sFirstValDesc = \sCSRD_ValDesc
            EndIf
            sValDesc = \sCSRD_ValDesc
            If sValDesc
              bFound = #False
              For n = 0 To nMaxCategoryIndex
                If sCategory(n) = sValDesc
                  bFound = #True
                  Break
                EndIf
              Next n
              If bFound = #False
                nMaxCategoryIndex + 1
                If nMaxCategoryIndex > ArraySize(sCategory())
                  ReDim sCategory(nMaxCategoryIndex+5)
                  ReDim nRemDevMsgType(nMaxCategoryIndex+5)
                EndIf
                sCategory(nMaxCategoryIndex) = sValDesc
                nRemDevMsgType(nMaxCategoryIndex) = \nCSRD_RemDevMsgType
              EndIf ; EndIf bFound = #False
            EndIf ; EndIf sValDesc
          EndIf ; EndIf \bCSRD_ValSS
        EndIf ; EndIf \nCSRD_RemDevId = nRemDevId
      EndWith
    Next nRemDevMsgIndex
    With WES
      If IsGadget(\pnlCategories)
        scsOpenGadgetList(\pnlCategories)
          ClearGadgetItems(\pnlCategories)
          For n = 0 To nMaxCategoryIndex
            ; debugMsg0(sProcName, "n=" + n + ", calling addGadgetItemWithData(\pnlCategories, " + sCategory(n) + ", " + nRemDevMsgType(n) + ")")
            addGadgetItemWithData(\pnlCategories, sCategory(n), nRemDevMsgType(n))
            ; Added 6Jan2025 11.01.6cg
            If LCase(sCategory(n)) = "channel"
              nChannelIndex  = n
            EndIf
            ; End added 6Jan2025 11.01.6cg
          Next n
        scsCloseGadgetList()
        ; Added 6Jan2025 11.01.6cg
        If nChannelIndex > 0
          SetGadgetState(\pnlCategories, nChannelIndex)
        EndIf
        ; End added 6Jan2025 11.01.6cg
      EndIf
    EndWith
    If sFirstValType
      WES_loadScribbleStripItems(@aSub(grWES\nSubPtr)\aCtrlSend[grWES\nCtrlSendIndex], sFirstValType, sFirstValDesc)
    EndIf
  EndIf
  
EndProcedure

Procedure WES_loadScribbleStripItems(*rCtrlSend.tyCtrlSend, sValType.s, sValDesc.s)
  PROCNAMEC()
  Protected nRemDevId, nValidValIndex, nItemIndex, nValBase, nDataValueIndex, nLeft, nTop, nItemCount, nItemHeight, nInnerHeight, sItemName.s
  
  ; debugMsg0(sProcName, #SCS_START + ", sValType=" + sValType + ", sValDesc=" + sValDesc)
  
  grWES\nMaxItem = -1
  nRemDevId = *rCtrlSend\nRemDevId
  If nRemDevId >= 0
    SGT(WES\lblItemType, sValDesc)
    nItemHeight = 21
    For nValidValIndex = 0 To grCSRD\nMaxValidValue
      With grCSRD\aValidValue(nValidValIndex)
        If \nCSRD_RemDevId = nRemDevId And \sCSRD_ValType = sValType
          nValBase = \nCSRD_ValBase
          grWES\nMaxItem = \nCSRD_MaxValDataValue - nValBase
          ; debugMsg(sProcName, "grWES\nMaxItem=" + grWES\nMaxItem)
          If grWES\nMaxItem >= 0
            scsOpenGadgetList(WES\scaCategoryItems)
              If grWES\nMaxItem > ArraySize(WES\txtCategoryItemCode())
                ReDim WES\txtCategoryItemCode(grWES\nMaxItem)
                ReDim WES\txtCategoryItemName(grWES\nMaxItem)
              EndIf
              nLeft = 0
              ; display required items
              For nItemIndex = 0 To grWES\nMaxItem
                ; if the gadgets do not yet exist then create them
                If IsGadget(WES\txtCategoryItemCode(nItemIndex)) = #False
                  nTop = nItemIndex * nItemHeight
                  WES\txtCategoryItemCode(nItemIndex)=scsStringGadget(nLeft,nTop,80,nItemHeight,"",#PB_String_ReadOnly,"txtCategoryItemCode[" + nItemIndex + "]")
                  WES\txtCategoryItemName(nItemIndex)=scsStringGadget(gnNextX+4,nTop,80,nItemHeight,"",0,"txtCategoryItemName[" + nItemIndex + "]")
                EndIf
                ; display the item
                nDataValueIndex = nItemIndex + nValBase
                SGT(WES\txtCategoryItemCode(nItemIndex), \sValDataValue(nDataValueIndex))
                sItemName = getScribbleStripItemName(@grWES\rScribbleStrip, sValType, nDataValueIndex)
                SGT(WES\txtCategoryItemName(nItemIndex), sItemName)
                setVisible(WES\txtCategoryItemCode(nItemIndex), #True)
                setVisible(WES\txtCategoryItemName(nItemIndex), #True)
              Next nItemIndex
              ; clear any remaining items
              For nItemIndex = grWES\nMaxItem + 1 To ArraySize(WES\txtCategoryItemCode())
                If IsGadget(WES\txtCategoryItemCode(nItemIndex))
                  SGT(WES\txtCategoryItemCode(nItemIndex), "")
                  SGT(WES\txtCategoryItemName(nItemIndex), "")
                  setVisible(WES\txtCategoryItemCode(nItemIndex), #False)
                  setVisible(WES\txtCategoryItemName(nItemIndex), #False)
                EndIf
              Next nItemIndex
            scsCloseGadgetList()
          EndIf ; EndIf grWES\nMaxItem >= 0
          Break ; Break nValidValIndex
        EndIf ; EndIf \nCSRD_RemDevId = nRemDevId And \sCSRD_ValType = sValType
      EndWith
    Next nValidValIndex
  EndIf ; EndIf nRemDevId >= 0
  nItemCount = grWES\nMaxItem + 1
  nInnerHeight = nItemCount * nItemHeight
  SetGadgetAttribute(WES\scaCategoryItems, #PB_ScrollArea_InnerHeight, nInnerHeight)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WES_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WES
    Select nEventGadgetNoForEvHdlr
      Case \txtCategoryItemName(0)
        ETVAL2(WES\txtCategoryItemName(0))
      Default
        bFound = #False
    EndSelect
  EndWith
  
  If bFound
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      debugMsg(sProcName, "returning #False")
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      debugMsg(sProcName, "returning #True (a)")
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    debugMsg(sProcName, "returning #True (b)")
    ProcedureReturn #True
  EndIf
  
EndProcedure

; EOF