; File: fmTimeProfile.pbi

EnableExplicit

Procedure WTP_Form_Unload()
  getFormPosition(#WTP, @grTimeProfileWindow)
  unsetWindowModal(#WTP)
  scsCloseWindow(#WTP)
EndProcedure

Procedure WTP_btnOK_Click()
  PROCNAMEC()
  Protected sPrevTimeProfile.s
  
  sPrevTimeProfile = gsWhichTimeProfile
  gsWhichTimeProfile = GGT(WTP\cboTimeProfile)
  debugMsg(sProcName, "gsWhichTimeProfile=" + gsWhichTimeProfile)
  If gsWhichTimeProfile <> sPrevTimeProfile
    gbChangeTimeProfile = #True
    WMN_setStatusField(LangColon("Common", "TimeProfile") + gsWhichTimeProfile)
  EndIf
  
  WTP_Form_Unload()
EndProcedure

Procedure WTP_changeTimeProfile()
  PROCNAMEC()
  Protected i
  
  debugMsg(sProcName, #SCS_START)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_CHANGE_TIME_PROFILE)
    ProcedureReturn
  EndIf
  
  gbChangeTimeProfile = #False
  
  If IsGadget(WSP\cvsSplash)
    If gsWhichTimeProfile
      debugMsg(sProcName, "calling WSP_setTimeProfile(" + #DQUOTE$ + gsWhichTimeProfile + #DQUOTE$ + ")")
      WSP_setTimeProfile(gsWhichTimeProfile)
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling WMN_setWindowTitle()")
  WMN_setWindowTitle()
  
  ; Added 4Dec2021 11.8.6cq
  For i = 1 To gnLastCue
    With aCue(i)
      If \nActivationMethod = #SCS_ACMETH_TIME
        debugMsg(sProcName, "calling resetCueStates(" + getCueLabel(i) + ", #True)")
        resetCueStates(i, #True)
        If \bTBCDone
          \bTBCDone = #False
          debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bTBCDone=" + strB(\bTBCDone))
        EndIf
        If \nActivationMethodReqd <> \nActivationMethod
          \nActivationMethodReqd = \nActivationMethod
          debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
        EndIf
      EndIf
    EndWith
  Next i
  ; End added 4Dec2021 11.8.6cq
  
;   debugMsg(sProcName, "(a) calling debugCuePtrs()")
;   debugCuePtrs()
; nb as at 11.6.1au (28Apr2017) setTimeBasedCues() checks that it is being run in the main thread, and if not then passes the call to SAM
  ; (probably no longer necessary as setTimeBasedCues(i) is called within resetCueStates(i, #True) called above, added 4Dec2021 11.8.6cq)
  debugMsg(sProcName, "calling setTimeBasedCues(-1, #True)")
  setTimeBasedCues(-1, #True)
;   debugMsg(sProcName, "(b) calling debugCuePtrs()")
;   debugCuePtrs()
  
  ; the following now added to setTimeBasedCues() due to the mod mentioned above about passing the callto SAM
;   gbCallPopulateGrid = #True
;   gbCallLoadDispPanels = #True
;   gnCallOpenNextCues = 1
;   debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTP_Form_Show(bModal, nParentWindow)
  Protected n, m
  
  If IsWindow(#WTP) = #False
    createfmTimeProfile(nParentWindow)
  EndIf
  setFormPosition(#WTP, @grTimeProfileWindow)
  setWindowModal(#WTP, bModal)
  
  m = -1
  ClearGadgetItems(WTP\cboTimeProfile)
  For n = 0 To #SCS_MAX_TIME_PROFILE
    If Len(grProd\sTimeProfile[n]) > 0
      AddGadgetItem(WTP\cboTimeProfile, -1, grProd\sTimeProfile[n])
      If grProd\sTimeProfile[n] = gsWhichTimeProfile
        m = n
      EndIf
    EndIf
  Next n
  If m >= 0
    SGS(WTP\cboTimeProfile, m)
  EndIf
  
  setWindowVisible(#WTP, #True)
  SetActiveWindow(#WTP)
EndProcedure

Procedure WTP_EventHandler()
  PROCNAMEC()
  
  With WTP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WTP_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn   ; Return
            WTP_btnOK_Click()
          Case #SCS_mnuKeyboardEscape   ; Escape
            WTP_Form_Unload()
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel ; btnCancel
            WTP_Form_Unload()
            
          Case \btnOK     ; btnOK
            WTP_btnOK_Click()
            
          Case \cboTimeProfile
            ; no action
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
