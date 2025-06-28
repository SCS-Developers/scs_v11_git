; File: fmInputRequester.pbi

EnableExplicit

Procedure WIR_Form_Unload()
  
  unsetWindowModal(#WIR)
  scsCloseWindow(#WIR)
  
EndProcedure

Procedure WIR_Form_Show(bModal, nParentWindow, nRequesterType, nAction, sTitle.s, sHeading.s, sItem.s)
  PROCNAMEC()
  Protected nMinReqdWindowWidth, nMinRightPadding
  
  If (IsWindow(#WIR) = #False) Or (gaWindowProps(#WIR)\nParentWindow <> nParentWindow)
    createfmInputRequester(nParentWindow)
  EndIf
  setWindowModal(#WIR, bModal)
  
  With grWIR
    \nParentWindow = nParentWindow
    \nRequesterType = nRequesterType
    \nAction = nAction
  EndWith
  
  SetWindowTitle(#WIR, sTitle)
  With WIR
    SGT(\lblHeading, sHeading)
    setGadgetWidth(\lblHeading)
    SGT(\lblItem, sItem)
    setGadgetWidth(\lblItem)
    SGT(\txtItem,"")
    nMinReqdWindowWidth = 500
    nMinRightPadding = GadgetX(\lblHeading)
    If (GadgetX(\lblHeading) + GadgetWidth(\lblHeading) + nMinRightPadding) > nMinReqdWindowWidth
      nMinReqdWindowWidth = GadgetX(\lblHeading) + GadgetWidth(\lblHeading) + nMinRightPadding
      ResizeWindow(#WIR, #PB_Ignore, #PB_Ignore, nMinReqdWindowWidth, #PB_Ignore)
    EndIf
    SAG(\txtItem)
  EndWith
  
  setWindowVisible(#WIR, #True)
  
EndProcedure

Procedure WIR_btnOK_Click()
  PROCNAMEC()
  Protected sItem.s, sError.s
  Protected n
  
  sItem = Trim(GGT(WIR\txtItem))
  If Len(sItem) = 0
    sError = LangPars("Errors", "MustBeEntered", GGT(WIR\lblItem))
    scsMessageRequester(GWT(#WIR), sError, #MB_ICONEXCLAMATION)
    SAG(WIR\txtItem)
    ProcedureReturn
  EndIf
  
  Select grWIR\nRequesterType
    Case #SCS_IR_PROD_TITLE
      
    Case #SCS_IR_TEMPLATE_NAME
      If CheckFilename(sItem) = #False
        sError = Lang("Errors", "TemplateNameInvalid")
        scsMessageRequester(GWT(#WIR), sError, #MB_ICONEXCLAMATION)
        SAG(WIR\txtItem)
        ProcedureReturn
      EndIf
      For n = 0 To ArraySize(gaTemplate())
        If UCase(gaTemplate(n)\sName) = UCase(sItem)
          sError = LangPars("Errors", "TemplateNameAlreadyUsed", #DQUOTE$ + sItem + #DQUOTE$)
          scsMessageRequester(GWT(#WIR), sError, #MB_ICONEXCLAMATION)
          SAG(WIR\txtItem)
          ProcedureReturn
        EndIf
      Next n          
      
  EndSelect
  
  With grAction
    \nParentWindow = grWIR\nParentWindow
    \nAction = grWIR\nAction
    \sTitle = sItem
    If \nAction <> #SCS_ACTION_NONE
      gqMainThreadRequest | #SCS_MTH_PROCESS_ACTION
    EndIf
  EndWith
  
  WIR_Form_Unload()
  
EndProcedure

Procedure WIR_EventHandler()
  PROCNAMEC()
  
  With WIR
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WIR_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOK)
              WIR_btnOK_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WIR_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel
            WIR_Form_Unload()
            
          Case \btnOK
            WIR_btnOK_Click()
            
          Case \txtItem
            ; Added 15Jul2022 11.9.3.1ad following a test of creating a new cue file from a template, where because gnValidateGadgetNo was still pointing to \txtItem,
            ; the editor would not display any cue or production details but would keep trying to issue a SAM 'node click' request
            markValidationOK(gnEventGadgetNo)
            gnValidateGadgetNo = 0
            ; End added 15Jul2022 11.9.3.1ad
            
          Default
            ; debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
