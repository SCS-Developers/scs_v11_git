; File: fmOSCCapture.pbi

EnableExplicit

Procedure WOC_populateComboBoxes()
  PROCNAMECS(nEditSubPtr)
  Protected d, n, sItemText.s
  
  debugMsg(sProcName, #SCS_START)
  
  ClearGadgetItems(WOC\cboLogicalDev)
  ClearGadgetItems(WOC\cboCtrlNetworkRemoteDev)
  ClearGadgetItems(WOC\cboOSCCmdType)
  
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    With grProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        If \nDevType <> #SCS_DEVTYPE_LT_DMX_OUT
          debugMsg(sProcName, "grProd\aCtrlSendLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev)
          addGadgetItemWithData(WOC\cboLogicalDev,\sLogicalDev,d)
        EndIf
      EndIf
    EndWith
  Next d
  
  For n = 0 To #SCS_MAX_CS_NETWORK_REM_DEV
    addGadgetItemWithData(WOC\cboCtrlNetworkRemoteDev, decodeCtrlNetworkRemoteDevLShort(n), n)
    debugMsg(sProcName, "WOC\cboCtrlNetworkRemoteDev," + n + "=" + GetGadgetItemText(WOC\cboCtrlNetworkRemoteDev, n))
  Next n
  
  For n = (#SCS_CS_OSC_DUMMY_FIRST + 1) To (#SCS_CS_OSC_DUMMY_LAST - 1)
    Select n
      Case #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG
        addGadgetItemWithData(WOC\cboOSCCmdType, decodeOSCCmdTypeL(n), n)
        ; debugMsg(sProcName, "WOC\cboOSCCmdType," + n + "=" + GetGadgetItemText(WOC\cboOSCCmdType, n))
    EndSelect
  Next n
  
;   setComboBoxWidth(WOC\cboCtrlNetworkRemoteDev, 80)
;   setComboBoxWidth(WOC\cboOSCCmdType, 80)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_populateForm()
  PROCNAMECS(nEditSubPtr)
  Protected nRowNo, nListIndex
  Protected bOSCServer, nCtrlNetworkRemoteDev
  
  debugMsg(sProcName, #SCS_START)
  
  WOC_populateComboBoxes()
  
  If nEditSubPtr >= 0
    nRowNo = GGS(WQM\grdCtrlSends)
    If nRowNo < 0
      nRowNo = 0
    EndIf
    With aSub(nEditSubPtr)\aCtrlSend[nRowNo]
      SGT(WOC\lblSubCueInfo, Trim(getSubLabel(nEditSubPtr) + "  " + aSub(nEditSubPtr)\sSubDescr))
      nListIndex = indexForComboBoxRow(WOC\cboLogicalDev, \sCSLogicalDev, -1)
      SGS(WOC\cboLogicalDev, nListIndex)
      If \nCSPhysicalDevPtr >= 0
        bOSCServer = gaNetworkControl(\nCSPhysicalDevPtr)\bOSCServer
        nCtrlNetworkRemoteDev = gaNetworkControl(\nCSPhysicalDevPtr)\nCtrlNetworkRemoteDev
      Else
        bOSCServer = #False
        nCtrlNetworkRemoteDev = -1
      EndIf
      debugMsg(sProcName, "\nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr + ", nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev) + ", bOSCServer=" + strB(bOSCServer))
      setComboBoxByData(WOC\cboCtrlNetworkRemoteDev, nCtrlNetworkRemoteDev)
debugMsg(sProcName, "calling setComboBoxByData(WOC\cboOSCCmdType, " + decodeOSCCmdType(\nOSCCmdType) + ", -1)")
      setComboBoxByData(WOC\cboOSCCmdType, \nOSCCmdType, -1)
      ; WOC_setEnabledStates()
      WOC_cboOSCCmdType_Click()
    EndWith
  EndIf
  
EndProcedure

Procedure WOC_Form_Show(bModal)
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WOC) = #False
    createfmOSCCapture()
  EndIf
  setFormPosition(#WOC, @grOSCCaptureWindow)
  
  WOC_populateForm()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_Form_Unload()
  PROCNAMECS(nEditSubPtr)
  
  getFormPosition(#WOC, @grOSCCaptureWindow)
  unsetWindowModal(#WOC)
  scsCloseWindow(#WOC)
;   debugMsg(sProcName, "grColHnd\bChangesSaved=" + strB(grColHnd\bChangesSaved))
;   If (grColHnd\bChangesSaved) Or (grColorScheme\sSchemeName <> grColHnd\sOrigSchemeName)
;     WOP_colorSchemeDesignerModReturn()
;   EndIf
  
EndProcedure

Procedure WOC_btnCancel_Click()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  WOC_Form_Unload()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_countNamed()
  PROCNAMECS(nEditSubPtr)
  Protected nRow, sItemInfo.s, nNamedCount
  
  If grWOC\nOSCCmdType <> #SCS_CS_OSC_MUTEMG
    For nRow = 0 To (grWOC\nItemCount - 1)
      With gaOSCCaptureItem(nRow)
        sItemInfo = Trim(makeX32ItemId(grWOC\nOSCCmdType, \nItemNo))
        If (sItemInfo) And (sItemInfo <> Trim(\sItemDesc))
          nNamedCount + 1
        EndIf
      EndWith
    Next nRow
  EndIf
  
  ProcedureReturn nNamedCount
  
EndProcedure

Procedure WOC_btnIncludeNamed_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nRow, sItemInfo.s, bNamed
  
  For nRow = 0 To (grWOC\nItemCount - 1)
    With gaOSCCaptureItem(nRow)
      bNamed = #False
      If grWOC\nOSCCmdType <> #SCS_CS_OSC_MUTEMG
        sItemInfo = Trim(makeX32ItemId(grWOC\nOSCCmdType, \nItemNo))
        If (sItemInfo) And (sItemInfo <> Trim(\sItemDesc))
          bNamed = #True
        EndIf
      EndIf
      If bNamed
        SetGadgetItemState(WOC\grdOSCCapture, nRow, #PB_ListIcon_Checked)
        gaOSCCaptureItem(nRow)\bIncluded = #True
      Else
        SetGadgetItemState(WOC\grdOSCCapture, nRow, #PB_Checkbox_Unchecked)
        gaOSCCaptureItem(nRow)\bIncluded = #False
      EndIf
    EndWith
  Next nRow
  
  WOC_colorRows()
  
  SAG(-1)
EndProcedure

Procedure WOC_btnIncludeAll_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nRow
  
  For nRow = 0 To (grWOC\nItemCount - 1)
    SetGadgetItemState(WOC\grdOSCCapture, nRow, #PB_ListIcon_Checked)
    gaOSCCaptureItem(nRow)\bIncluded = #True
  Next nRow
  
  WOC_colorRows()
  
  SAG(-1)
EndProcedure

Procedure WOC_btnClearAll_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nRow
  
  For nRow = 0 To (CountGadgetItems(WOC\grdOSCCapture)-1)
    SetGadgetItemState(WOC\grdOSCCapture, nRow, 0)
    gaOSCCaptureItem(nRow)\bIncluded = #False
  Next nRow
  
  WOC_colorRows()
  
  SAG(-1)
EndProcedure

Procedure WOC_colorRows()
  PROCNAMECS(nEditSubPtr)
  Protected n, nBackColor, nTextColor
  
  debugMsg(sProcName, #SCS_START)
  
  nTextColor = #SCS_Black
  
  debugMsg(sProcName, "grWOC\nItemCount=" + grWOC\nItemCount)
  For n = 0 To (grWOC\nItemCount - 1)
    With gaOSCCaptureItem(n)
      If \bIncluded
        If \bMute
          nBackColor = #SCS_Red
        Else
          nBackColor = #SCS_Green
        EndIf
      Else
        nBackColor = #SCS_Very_Light_Grey
      EndIf
      SetGadgetItemColor(WOC\grdOSCCapture, n, #PB_Gadget_BackColor, nBackColor, -1)
      SetGadgetItemColor(WOC\grdOSCCapture, n, #PB_Gadget_FrontColor, nTextColor, -1)
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_grdOSCCapture_LeftClick()
  PROCNAMECS(nEditSubPtr)
  Protected nRow, bIncluded
  
  debugMsg(sProcName, #SCS_START)
  
  For nRow = 0 To (CountGadgetItems(WOC\grdOSCCapture)-1)
    With gaOSCCaptureItem(nRow)
      If GetGadgetItemState(WOC\grdOSCCapture, nRow) & #PB_ListIcon_Checked   ; nb use & not = as value contains a combination of flags
        bIncluded = #True
      Else
        bIncluded = #False
      EndIf
      If bIncluded <> \bIncluded
        \bIncluded = bIncluded
        debugMsg(sProcName, "gaOSCCaptureItem(" + nRow + ")\bIncluded=" + strB(\bIncluded) + ", \nItemNo=" + \nItemNo + ", \sItemDesc=" + \sItemDesc)
      EndIf
    EndWith
  Next nRow
  
  WOC_colorRows()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_btnOK_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nCtrlSendIndex
  Protected rCtrlSendDef.tyCtrlSend
  Protected rCtrlSend.tyCtrlSend
  Protected rFirstCtrlSend.tyCtrlSend
  
  debugMsg(sProcName, #SCS_START)
  
  nCtrlSendIndex = -1
  rFirstCtrlSend =  aSub(nEditSubPtr)\aCtrlSend[0]
  
  Select grWOC\nOSCCmdType
    Case #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG
      u = preChangeSubL(#True, decodeOSCCmdTypeL(grWOC\nOSCCmdType))
      debugMsg(sProcName, "grWOC\nItemCount=" + grWOC\nItemCount)
      For n = 0 To (grWOC\nItemCount - 1)
        ; debugMsg(sProcName, "gaOSCCaptureItem(" + n + ")\bIncluded=" + strB(gaOSCCaptureItem(n)\bIncluded))
        If gaOSCCaptureItem(n)\bIncluded
          nCtrlSendIndex + 1
          rCtrlSend = rCtrlSendDef
          With rCtrlSend
            \nDevType = rFirstCtrlSend\nDevType
            \sCSLogicalDev = rFirstCtrlSend\sCSLogicalDev
            \nCSPhysicalDevPtr = rFirstCtrlSend\nCSPhysicalDevPtr
            \bNetworkSend = rFirstCtrlSend\bNetworkSend
            \bIsOSC = #True
            \nOSCCmdType = grWOC\nOSCCmdType
            \sOSCItemString = gaOSCCaptureItem(n)\sItemDesc
            \nOSCItemNr = gaOSCCaptureItem(n)\nItemNo
            Select \nOSCCmdType
              Case #SCS_CS_OSC_MUTEMG
                ; MUTE GROUP
                Select gaNetworkControl(\nCSPhysicalDevPtr)\rX32NWData\nX32ItemOn(n)
                  Case 0
                    \nOSCMuteAction = #SCS_MUTE_OFF ; 0 means mute group button off = group not muted
                  Default
                    \nOSCMuteAction = #SCS_MUTE_ON  ; 1 means mute group button on = group muted
                EndSelect
              Default
                ; OTHER ITEM TYPES, EG CHANNELS, DCA GROUPS, ETC
                Select gaNetworkControl(\nCSPhysicalDevPtr)\rX32NWData\nX32ItemOn(n)
                  Case 0
                    \nOSCMuteAction = #SCS_MUTE_ON  ; 0 means item off = item muted
                  Default
                    \nOSCMuteAction = #SCS_MUTE_OFF ; 1 means item on = item not muted
                EndSelect
            EndSelect
          EndWith
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex] = rCtrlSend
          buildNetworkSendString(nEditSubPtr, nCtrlSendIndex)
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sDisplayInfo = Trim(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev + " " + buildOSCDisplayInfo(@aSub(nEditSubPtr), nCtrlSendIndex))
          debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\nCSPhysicalDevPtr=" + aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nCSPhysicalDevPtr)
        EndIf
      Next n
      
      debugMsg(sProcName, "nCtrlSendIndex=" + nCtrlSendIndex)
      If nCtrlSendIndex >= 0
        ; if at least one item is selected then clear all remaining Ctrl Send items in this Sub
        For n = nCtrlSendIndex + 1 To #SCS_MAX_CTRL_SEND
          aSub(nEditSubPtr)\aCtrlSend[n] = rCtrlSendDef
        Next n
        ; now refresh the editing screen (also only if at least one item selected, otherwise there's no change
        WQM_resetSubDescrIfReqd()
        displaySub(nEditSubPtr)
      EndIf
      
      postChangeSubL(u, #False)
      
  EndSelect
  
  WOC_Form_Unload()
  
  ; debugMsg(sProcName, "calling debugCuePtrs(" + getCueLabel(nEditCuePtr) + ")")
  ; debugCuePtrs(nEditCuePtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_setupGrdOSCCapture()
  PROCNAMECS(nEditSubPtr)
  Protected n
  Protected sMuteColHdr.s
  Protected sPad.s = Space(6)
  
  debugMsg(sProcName, #SCS_START)
  
  With WOC
    ; remove all columns except the "Select" column (column 0)
    For n = grWOC\nMaxColNo To 1 Step -1
      RemoveGadgetColumn(\grdOSCCapture, n)
    Next n
    
    If StartDrawing(WindowOutput(#WOC))
      DrawingFont(GetGadgetFont(WOC\grdOSCCapture))
      Select grWOC\nOSCCmdType
        Case #SCS_CS_OSC_MUTECHANNEL
          sMuteColHdr = Lang("OSC","mutechannel")
        Case #SCS_CS_OSC_MUTEDCAGROUP
          sMuteColHdr = Lang("OSC","mutedcagroup")
        Case #SCS_CS_OSC_MUTEAUXIN
          sMuteColHdr = Lang("OSC","muteauxin")
        Case #SCS_CS_OSC_MUTEBUS
          sMuteColHdr = Lang("OSC","mutebus")
        Case #SCS_CS_OSC_MUTEFXRTN
          sMuteColHdr = Lang("OSC","mutefxrtn")
        Case #SCS_CS_OSC_MUTEMATRIX
          sMuteColHdr = Lang("OSC","mutematrix")
        Case #SCS_CS_OSC_MUTEMG
          sMuteColHdr = Lang("OSC","mutemg")
      EndSelect
      grWOC\nMaxColNo = 2
      AddGadgetColumn(\grdOSCCapture, 1, grText\sTextDescription, TextWidth("CH32 channel description"))
      AddGadgetColumn(\grdOSCCapture, 2, sMuteColHdr, TextWidth(sMuteColHdr+sPad))
      autoFitGridCol(\grdOSCCapture, 2) ; autofit Mute column
      StopDrawing()
    EndIf
    
  EndWith
  
EndProcedure

Procedure WOC_populateGrdOSCCapture()
  PROCNAMECS(nEditSubPtr)
  Protected n, n2, sText.s, nMatchCount, nUnmatchCount
  
  debugMsg(sProcName, #SCS_START)
  
  If grWOC\nOSCCmdType >= 0
    For n = 0 To #SCS_MAX_CTRL_SEND
      With aSub(nEditSubPtr)\aCtrlSend[n]
        If (\nOSCCmdType <> grCtrlSendDef\nOSCCmdType) And (\nOSCItemNr <> grCtrlSendDef\nOSCItemNr)
          ; not a blank entry (blank entries are not considered unmatching)
          If \nOSCCmdType = grWOC\nOSCCmdType
            nMatchCount + 1
          Else
            nUnmatchCount + 1
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
  
  debugMsg(sProcName, "grWOC\nOSCCmdType=" + decodeOSCCmdType(grWOC\nOSCCmdType) + ", nMatchCount=" + nMatchCount + ", nUnmatchCount=" + nUnmatchCount)
  
  ; in the following, pre-select the 'Include' checkbox for items that are already included in the control send sub-cue being edited,
  ; PROVIDED ALL existing entries are for this OSC Command Type.
  
  With WOC
    ClearGadgetItems(\grdOSCCapture)
    For n = 0 To (grWOC\nItemCount - 1)
      sText = ""   ; 'Include' column
      If grWOC\nOSCCmdType = #SCS_CS_OSC_MUTEMG
        sText + Chr(10) + gaOSCCaptureItem(n)\nItemNo ; X32 mute groups have no 'name', just a number
      Else
        sText + Chr(10) + gaOSCCaptureItem(n)\nItemNo + ": " + gaOSCCaptureItem(n)\sItemDesc
      EndIf
      sText + Chr(10) + gaOSCCaptureItem(n)\sCaptureValue
      AddGadgetItem(\grdOSCCapture, -1, sText)
      ; set the Include checkbox if required
      If (nMatchCount > 0) ; And (nUnmatchCount = 0)
        For n2 = 0 To #SCS_MAX_CTRL_SEND
          If aSub(nEditSubPtr)\aCtrlSend[n2]\nOSCCmdType = grWOC\nOSCCmdType
            If aSub(nEditSubPtr)\aCtrlSend[n2]\nOSCItemNr = gaOSCCaptureItem(n)\nItemNo
              gaOSCCaptureItem(n)\bIncluded = #True
              SetGadgetItemState(\grdOSCCapture, n, #PB_ListIcon_Checked) ; sets 'Include' checkbox
              Break ; Break n2
            EndIf
          EndIf
        Next n2
      EndIf
    Next n
    ; autoFitGridCol(\grdOSCCapture, 1) ; autofit Description column
    WOC_colorRows()
  EndWith
  
EndProcedure

Procedure WOC_cboOSCCmdType_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nPhysicalDevPtr
  Protected n, sItemText.s
  Protected rOSCCaptureItem.tyOSCCaptureItem
  Protected nMaxX32ItemIndex
  Static sMute.s, sUnmute.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sMute = Lang("Common", "Mute")
    sUnmute = Lang("Common", "Unmute")
    bStaticLoaded = #True
  EndIf
  
  grWOC\nOSCCmdType = getCurrentItemData(WOC\cboOSCCmdType, -1)
  If grWOC\nOSCCmdType >= 0
    nPhysicalDevPtr = aSub(nEditSubPtr)\aCtrlSend[0]\nCSPhysicalDevPtr
    If nPhysicalDevPtr >= 0
      With gaNetworkControl(nPhysicalDevPtr)\rX32NWData
        nMaxX32ItemIndex = getMaxX32ItemIndex(nPhysicalDevPtr, grWOC\nOSCCmdType)
        If nMaxX32ItemIndex >= 0
          grWOC\nItemCount = 0
          For n = 0 To nMaxX32ItemIndex
            If nMaxX32ItemIndex > ArraySize(gaOSCCaptureItem())
              ReDim gaOSCCaptureItem(nMaxX32ItemIndex)
            EndIf
            rOSCCaptureItem = grOSCCaptureItemDef
            rOSCCaptureItem\nItemNo = n + 1
            Select grWOC\nOSCCmdType
              Case #SCS_CS_OSC_MUTECHANNEL
                rOSCCaptureItem\sItemDesc = Trim(\sChannel(n))
              Case #SCS_CS_OSC_MUTEDCAGROUP
                rOSCCaptureItem\sItemDesc = Trim(\sDCAGroup(n))
              Case #SCS_CS_OSC_MUTEAUXIN
                rOSCCaptureItem\sItemDesc = Trim(\sAuxIn(n))
              Case #SCS_CS_OSC_MUTEFXRTN
                rOSCCaptureItem\sItemDesc = Trim(\sFXReturn(n))
              Case #SCS_CS_OSC_MUTEBUS
                rOSCCaptureItem\sItemDesc = Trim(\sBus(n))
              Case #SCS_CS_OSC_MUTEMATRIX
                rOSCCaptureItem\sItemDesc = Trim(\sMatrix(n))
              Case #SCS_CS_OSC_MUTEMAINLR
                rOSCCaptureItem\sItemDesc = Trim(\sMain(0))
              Case #SCS_CS_OSC_MUTEMAINMC
                rOSCCaptureItem\sItemDesc = Trim(\sMain(1))
              Case #SCS_CS_OSC_MUTEMG
                rOSCCaptureItem\sItemDesc = Trim(\sMuteGroup(n))
            EndSelect
            gaOSCCaptureItem(grWOC\nItemCount) = rOSCCaptureItem
            grWOC\nItemCount + 1
          Next n
          getX32ItemOnStates(nPhysicalDevPtr, grWOC\nOSCCmdType, #True)
          Select grWOC\nOSCCmdType
            Case #SCS_CS_OSC_MUTEMG
              ; MUTE GROUP
              For n = 0 To nMaxX32ItemIndex
                If gaNetworkControl(nPhysicalDevPtr)\rX32NWData\nX32ItemOn(n) = 0
                  gaOSCCaptureItem(n)\sCaptureValue = sUnmute
                Else
                  gaOSCCaptureItem(n)\sCaptureValue = sMute
                  gaOSCCaptureItem(n)\bMute = #True
                EndIf
              Next n
            Default
              ; OTHER ITEM TYPES, EG CHANNELS, DCA GROUPS, ETC
              For n = 0 To nMaxX32ItemIndex
                If gaNetworkControl(nPhysicalDevPtr)\rX32NWData\nX32ItemOn(n) = 0
                  gaOSCCaptureItem(n)\sCaptureValue = sMute
                  gaOSCCaptureItem(n)\bMute = #True
                Else
                  gaOSCCaptureItem(n)\sCaptureValue = sUnmute
                EndIf
              Next n
          EndSelect
          WOC_setupGrdOSCCapture()
          WOC_populateGrdOSCCapture()
        EndIf
      EndWith
    EndIf ; EndIf nPhysicalDevPtr >= 0
  EndIf ; EndIf grWOC\nOSCCmdType >= 0
  
  WOC_setEnabledStates()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WOC_EventHandler()
  PROCNAMECS(nEditSubPtr)
  
  With WOC
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WOC_btnCancel_Click()
        
      Case #PB_Event_Gadget
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            WOC_btnCancel_Click()
            
          Case \btnClearAll
            WOC_btnClearAll_Click()
            
          Case \btnIncludeAll
            WOC_btnIncludeAll_Click()
            
          Case \btnIncludeNamed
            WOC_btnIncludeNamed_Click()
            
          Case \btnHelp
            displayHelpTopic("capture_x32_info.htm")
            
          Case \btnOK
            WOC_btnOK_Click()
            
          Case \cboOSCCmdType
            WOC_cboOSCCmdType_Click()
            
          Case \grdOSCCapture
            If gnEventType = #PB_EventType_LeftClick
              WOC_grdOSCCapture_LeftClick()
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WOC_setEnabledStates()
  PROCNAMECS(nEditSubPtr)
  Protected bEnable, bEnableNamed
  
  With WOC
    If CountGadgetItems(\grdOSCCapture) > 0
      bEnable = #True
    EndIf
    If WOC_countNamed() > 0
      bEnableNamed = #True
    EndIf
    setEnabled(\btnIncludeNamed, bEnableNamed)
    setEnabled(\btnIncludeAll, bEnable)
    setEnabled(\btnClearAll, bEnable)
    
  EndWith
  
EndProcedure

; EOF