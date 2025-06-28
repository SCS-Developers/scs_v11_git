; File: fmProdTimer.pbi

EnableExplicit

Procedure WPT_applyChanges()
  PROCNAMEC()
  Protected n, nCuePtr
  Protected sUndoDescr.s
  Protected u, u2
  Protected nNewProdTimerAction
  
  If getEnabled(WPT\btnApply) = #False
    ProcedureReturn #True
  EndIf
  
  setMouseCursorBusy()
  
  sUndoDescr = GWT(#WPT)
  u = preChangeProdL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_BULK_EDIT, -1, 0, grProd\nProdId)  ; nb #SCS_UNDO_ACTION_BULK_EDIT because similar in scope to bulk edit
  
  For n = 1 To WPT\nCountEnabledCues
    nCuePtr = aWPTCue(n)\nCuePtr
    With aCue(nCuePtr)
      nNewProdTimerAction = getCurrentItemData(aWPTCue(n)\cboProdTimerAction, #SCS_PTA_NO_ACTION)
      If nNewProdTimerAction <> \nProdTimerAction
        u2 = preChangeCueL(\nProdTimerAction, sUndoDescr, nCuePtr)
        \nProdTimerAction = nNewProdTimerAction
        postChangeCueL(u2, \nProdTimerAction, nCuePtr)
      EndIf
    EndWith
  Next n
  grWTI\bCheckWindowExistsAndVisible = #True
  
  With grProd
    \bSaveProdTimerHistory = GGS(WPT\chkSaveProdTimerHistory)
    \bTimeStampProdTimerHistoryFiles = GGS(WPT\chkTimeStampProdTimerHistoryFiles)
  EndWith
  
  postChangeProdL(u, #False)
  
  setMouseCursorNormal()
  
  grWPT\bProdTimerChanges = #False
  
  ProcedureReturn #True
  
EndProcedure

Procedure WPT_setButtonsEtc()
  PROCNAMEC()
  Protected n, nCuePtr
  Protected nNewProdTimerAction
  
  grWPT\bProdTimerChanges = #False
  For n = 1 To WPT\nCountEnabledCues
    nCuePtr = aWPTCue(n)\nCuePtr
    With aCue(nCuePtr)
      nNewProdTimerAction = getCurrentItemData(aWPTCue(n)\cboProdTimerAction, #SCS_PTA_NO_ACTION)
      If nNewProdTimerAction <> \nProdTimerAction
        grWPT\bProdTimerChanges = #True
        Break
      EndIf
    EndWith
  Next n
  
  With grProd
    If GGS(WPT\chkSaveProdTimerHistory) <> \bSaveProdTimerHistory
      grWPT\bProdTimerChanges = #True
    ElseIf GGS(WPT\chkTimeStampProdTimerHistoryFiles) <> \bTimeStampProdTimerHistoryFiles
      grWPT\bProdTimerChanges = #True
    EndIf
  EndWith
  
  If grWPT\bProdTimerChanges
    setEnabled(WPT\btnApply, #True)
  Else
    setEnabled(WPT\btnApply, #False)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WPT_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WPT, @grProdTimerWindow)
  
  If grWPT\bProdTimerChanges
    ensureSplashNotOnTop()
    nResponse = scsMessageRequester(GWT(#WPT), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        ProcedureReturn
        
      Case #PB_MessageRequester_Yes
        WPT_applyChanges()
        
    EndSelect
  EndIf
  
  ; note - must close window before calling unsetWindowModal() as unsetWindowModal() may call a return function
  scsCloseWindow(#WPT)
  unsetWindowModal(#WPT)
  
EndProcedure

Procedure WPT_populateCueList()
  PROCNAMEC()
  Protected i, n
  Protected nListIndex
  Static Dim sActionDesc.s(#SCS_PTA_LAST)
  Static bActionDescsLoaded
  Protected nRowNo
  
  If bActionDescsLoaded = #False
    For n = 0 To #SCS_PTA_LAST
      If n = #SCS_PTA_NO_ACTION
        sActionDesc(n) = ""
      Else
        sActionDesc(n) = decodeProdTimerActionL(n)
      EndIf
    Next n
    bActionDescsLoaded = #True
  EndIf
  
  nRowNo = 0
  For i = 1 To gnLastCue
    With aCue(i)
      If \bCueEnabled
        nRowNo + 1
        aWPTCue(nRowNo)\nCuePtr = i
        SGT(aWPTCue(nRowNo)\txtCue, \sCue)
        SGT(aWPTCue(nRowNo)\txtDescr, \sCueDescr)
        ClearGadgetItems(aWPTCue(nRowNo)\cboProdTimerAction)
        For n = 0 To #SCS_PTA_LAST
          addGadgetItemWithData(aWPTCue(nRowNo)\cboProdTimerAction, sActionDesc(n), n)
        Next n
        nListIndex = indexForComboBoxData(aWPTCue(nRowNo)\cboProdTimerAction, \nProdTimerAction, 0)
        SGS(aWPTCue(nRowNo)\cboProdTimerAction, nListIndex)
      EndIf
    EndWith
  Next i
  
  With grProd
    SGS(WPT\chkSaveProdTimerHistory, \bSaveProdTimerHistory)
    SGS(WPT\chkTimeStampProdTimerHistoryFiles, \bTimeStampProdTimerHistoryFiles)
  EndWith
  
EndProcedure

Procedure WPT_Form_Load(nParentWindow)
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WPT) = #False Or gaWindowProps(#WPT)\nParentWindow <> nParentWindow
    createfmProdTimer(nParentWindow)
  EndIf
  setFormPosition(#WPT, @grProdTimerWindow)
  
  WPT_populateCueList()
  WPT_fcSaveProdTimerHistory()
  WPT_setButtonsEtc()
  
  setWindowVisible(#WPT, #True)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WPT_Form_Show(nParentWindow, bModal=#False, nReturnFunction=0)
  PROCNAMEC()
  ; load form unconditionally
  WPT_Form_Load(nParentWindow)
  setWindowModal(#WPT, bModal, nReturnFunction)
  setWindowVisible(#WPT, #True)
  SetActiveWindow(#WPT)
EndProcedure

Procedure WPT_cboProdTimerAction_Click(Index)
  WPT_setButtonsEtc() ; enable or disable Apply button
EndProcedure

Procedure WPT_chkSaveProdTimerHistory_Click()
  WPT_fcSaveProdTimerHistory()
  WPT_setButtonsEtc() ; enable or disable Apply button
EndProcedure

Procedure WPT_chkTimeStampProdTimerHistoryFiles_Click()
  WPT_fcSaveProdTimerHistory()  ; displays filename of history file
  WPT_setButtonsEtc() ; enable or disable Apply button
EndProcedure

Procedure WPT_fcSaveProdTimerHistory()
  PROCNAMEC()
  Protected sTimerHistFileName.s
  
  With WPT
    If GGS(\chkSaveProdTimerHistory)
      setEnabled(\chkTimeStampProdTimerHistoryFiles, #True)
    Else
      setEnabled(\chkTimeStampProdTimerHistoryFiles, #False)
    EndIf
    
    sTimerHistFileName = makeProdTimerHistFileName(#True)
    If sTimerHistFileName
      If GGS(\chkTimeStampProdTimerHistoryFiles)
        SGT(\lblHistFileName, Lang("WPT","lblHistFileNameTS"))
      Else
        SGT(\lblHistFileName, Lang("WPT","lblHistFileNameNTS"))
      EndIf
      SGT(\lblHistFileName2, #DQUOTE$ + sTimerHistFileName + #DQUOTE$)
      If GadgetWidth(\lblHistFileName2,#PB_Gadget_RequiredSize) > GadgetWidth(\lblHistFileName2)
        ; full path name too long, so just display the file part
        SGT(\lblHistFileName2, #DQUOTE$ + GetFilePart(sTimerHistFileName) + #DQUOTE$)
      EndIf
    Else
      SGT(\lblHistFileName, "")
      SGT(\lblHistFileName2, "")
    EndIf
    
  EndWith
  
EndProcedure

Procedure WPT_EventHandler()
  PROCNAMEC()
  
  With WPT
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WPT_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            grWPT\bProdTimerChanges = #False   ; prevents WPT_Form_Unload asking if changes are to be saved
            WPT_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnHelp
            displayHelpTopic("prod_timer.htm")
            
          Case aWPTCue(0)\cboProdTimerAction
            CBOCHG(WPT_cboProdTimerAction_Click(gnEventGadgetArrayIndex))
            
          Case \chkSaveProdTimerHistory
            WPT_chkSaveProdTimerHistory_Click()
            
          Case \chkTimeStampProdTimerHistoryFiles
            WPT_chkTimeStampProdTimerHistoryFiles_Click()
            
          Case \btnApply
            WPT_applyChanges()
            WPT_setButtonsEtc()
            
          Case \btnCancel
            grWPT\bProdTimerChanges = #False   ; prevents WPT asking if changes are to be saved
            WPT_Form_Unload()
            
          Case \btnOK
            WPT_applyChanges()
            WPT_Form_Unload()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
