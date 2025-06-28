; File: fmExport.pbi

EnableExplicit

Procedure WEX_btnExport_Click()
  PROCNAMEC()
  Protected bCopyFiles
  Protected i
  Protected nRefCuePtr
  Protected sMsg.s
  Protected nExpAsManualCount
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  SetGadgetText(WEX\lblExportStatus, "")
  
  If Len(Trim(GGT(WEX\txtProdTitle))) = 0
    scsMessageRequester(GetWindowTitle(#WEX), Lang("WEX", "TitleReqd"))
    SAG(WEX\txtProdTitle)
    ProcedureReturn
  EndIf
  
  ; perform referential integrity check
  sMsg = Lang("WEX", "Manual1") ; "The following cues will be converted to 'Manual Start' when exported:"
  For i = 1 To gnLastCue
    With aCue(i)
      \bExportAsManualStart = #False
      If WEX_exportThisCue(i)
        If checkExportCueRI(i) = #False
          ; nb error message already displayed by checkExportCueRI(i) so now just exit this procedure
          ProcedureReturn
        EndIf
        If (\nActivationMethod = #SCS_ACMETH_AUTO) Or (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
          If \nAutoActPosn <> #SCS_ACPOSN_LOAD
            nRefCuePtr = getCuePtr(\sAutoActCue)
            If nRefCuePtr >= 0
              If WEX_exportThisCue(nRefCuePtr) = #False
                \bExportAsManualStart = #True
                sMsg + Chr(10) + \sCue + " (" + LangPars("WEX", "AutoNotIncluded", \sAutoActCue) + ")"
                nExpAsManualCount + 1
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next i
  If nExpAsManualCount > 0
    debugMsg(sProcName, sMsg)
    sMsg + Chr(10) + Chr(10) + Lang("WEX", "Proceed?")
    nResponse = scsMessageRequester(GWT(#WEX), sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
    If nResponse <> #PB_MessageRequester_Yes
      debugMsg(sProcName, "abandon export")
      ProcedureReturn
    EndIf
  EndIf
  
  bCopyFiles = GGS(WEX\chkCopyFiles)
  If writeXMLCueFile(#True, bCopyFiles, #True) = #False
    ProcedureReturn
  EndIf
  WEX_Form_Unload()
  
EndProcedure

Procedure WEX_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WEX) = #False
    createfmExport()
  EndIf
  setFormPosition(#WEX, @grExportWindow)
  
  WEX_setupgrdExport()
  WEX_setButtons()
  WEX_displayCurrProdInfo()
  
  setWindowVisible(#WEX, #True)
  
EndProcedure

Procedure WEX_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  setFormPosition(#WEX, @grExportWindow)
  unsetWindowModal(#WEX)
  scsCloseWindow(#WEX)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEX_setupgrdExport()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)

  ClearGadgetItems(WEX\grdExport)

EndProcedure

Procedure WEX_displayCurrProdInfo()
  PROCNAMEC()
  Protected i, j, nRow
  Protected sCue.s, sCueType.s

  debugMsg(sProcName, #SCS_START)
  
  SGT(WEX\txtProdTitle, grProd\sTitle)
  
  ClearGadgetItems(WEX\grdExport)

  For i = 1 To gnLastCue
    nRow = i - 1
    sCue = aCue(i)\sCue
    j = aCue(i)\nFirstSubIndex
    If j >= 0
      sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
      If aSub(j)\nNextSubIndex >= 0
        sCue + "+"
      EndIf
    EndIf
    AddGadgetItem(WEX\grdExport, -1, "" + Chr(10) + sCue + Chr(10) + aCue(i)\sCueDescr + Chr(10) + sCueType)
    SetGadgetItemColor(WEX\grdExport, nRow, #PB_Gadget_BackColor, aCue(i)\nBackColor, -1)
    SetGadgetItemColor(WEX\grdExport, nRow, #PB_Gadget_FrontColor, aCue(i)\nTextColor, -1)
  Next i

  autoFitGridCol(WEX\grdExport, 2)  ; autofit "Description" column
  
  WEX_setButtons()

EndProcedure

Procedure WEX_setButtons()
  PROCNAMEC()
  Protected nRow
  Protected nRowCount, nRowsChecked

  nRowCount = CountGadgetItems(WEX\grdExport)
  For nRow = 0 To nRowCount-1
    If GetGadgetItemState(WEX\grdExport,nRow) & #PB_ListIcon_Checked
      nRowsChecked + 1
    EndIf
  Next nRow

  If nRowCount = 0 Or nRowsChecked = nRowCount
    setEnabled(WEX\btnSelectAll, #False)
  Else
    setEnabled(WEX\btnSelectAll, #True)
  EndIf

  If nRowsChecked = 0
    setEnabled(WEX\btnClearAll, #False)
    setEnabled(WEX\btnExport, #False)
  Else
    setEnabled(WEX\btnClearAll, #True)
    setEnabled(WEX\btnExport, #True)
  EndIf

EndProcedure

Procedure WEX_exportThisCue(pCuePtr)
  Protected nRow
  
  nRow = pCuePtr-1
  If GetGadgetItemState(WEX\grdExport,nRow) & #PB_ListIcon_Checked
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure WEX_Form_Show(bModal=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WEX) = #False
    WEX_Form_Load()
  EndIf
  setWindowModal(#WEX, bModal)
  setWindowVisible(#WEX, #True)
  SetActiveWindow(#WEX)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEX_EventHandler()
  PROCNAMEC()
  Protected nRow
  
  With WEX
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WEX_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnExport)
              WEX_btnExport_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WEX_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnClearAll
            For nRow = 0 To (CountGadgetItems(WEX\grdExport)-1)
              SetGadgetItemState(WEX\grdExport, nRow, 0)
            Next nRow
            WEX_setButtons()
            
          Case \btnClose
            WEX_Form_Unload()
            
          Case \btnExport
            WEX_btnExport_Click()
            
          Case \btnHelp
            displayHelpTopic("scs_export.htm")
            
          Case \btnSelectAll
            For nRow = 0 To (CountGadgetItems(WEX\grdExport)-1)
              SetGadgetItemState(WEX\grdExport, nRow, #PB_ListIcon_Checked)
            Next nRow
            WEX_setButtons()
            
          Case \grdExport
            If gnEventType = #PB_EventType_LeftClick
              WEX_setButtons()
            EndIf
            
          Case \txtProdTitle
            ; no action required
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
