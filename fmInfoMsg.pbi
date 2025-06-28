; File: fmInfoMsg.pbi

EnableExplicit

Procedure WMI_Form_Unload()
  PROCNAMEC()
  Protected qTimeNow.q, nTimeToGo
  
  With grWMI
    \bFormActive = #False
    If \nMinDisplayTime > 0
      qTimeNow = ElapsedMilliseconds()
      If (qTimeNow - \qTimeDisplayed) < \nMinDisplayTime
        nTimeToGo = \nMinDisplayTime - (qTimeNow - \qTimeDisplayed)
        If nTimeToGo > 0
          debugMsg(sProcName, "Delay(" + nTimeToGo + ")")
          Delay(nTimeToGo)
        EndIf
      EndIf
      \nMinDisplayTime = 0
    EndIf
  EndWith
  
  ; Changed the following 28Jun2021 11.8.5ao
  ; debugMsg(sProcName, "calling scsCloseWindow(#WMI)")
  ; scsCloseWindow(#WMI)
  ; debugMsg(sProcName, "calling setWindowVisible(#WMI, #False)")
  setWindowVisible(#WMI, #False)
  
EndProcedure

Procedure WMI_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WMI) = #False
    createfmInfoMsg()
  EndIf
  setWindowVisible(#WMI, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMI_displayInfoMsg1(sInfoMsg1.s, nProgressMax=0, sWindowTitle.s="", nMinDisplayTime=1000)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", sInfoMsg1=" + #DQUOTE$ + sInfoMsg1 + #DQUOTE$ + ", nProgressMax=" + nProgressMax + ", sWindowTitle=" + #DQUOTE$ + sWindowTitle + #DQUOTE$ + ", nMinDisplayTime=" + nMinDisplayTime)
  
  If IsWindow(#WMI) = #False
    WMI_Form_Load()
  EndIf
  SetWindowTitle(#WMI, sWindowTitle)
  setWindowVisible(#WMI, #True)
  StickyWindow(#WMI, #True)
  ; debugMsg0(sProcName, "IsWindow(#WMI)=" + IsWindow(#WMI))
  
  With WMI
    If Len(sWindowTitle) = 0
      SetWindowTitle(#WMI, grProd\sTitle)
    EndIf
    SGT(\lblInfoMsg1, sInfoMsg1)
    SGT(\lblInfoMsg2, "")
    If nProgressMax <= 1
      setVisible(\prbInfoProgress, #False)
    Else
      SetGadgetAttribute(\prbInfoProgress, #PB_ProgressBar_Maximum, nProgressMax)
      setVisible(\prbInfoProgress, #True)
    EndIf
    RedrawWindow_(GadgetID(\cntInfoMsg), 0, 0, #RDW_INVALIDATE)
  EndWith
  
  grWMI\nMinDisplayTime = nMinDisplayTime
  grWMI\qTimeDisplayed = ElapsedMilliseconds()
  grWMI\bFormActive = #True
  
;   debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMI_updateInfoMsg1(sInfoMsg1.s)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", sInfoMsg1=" + #DQUOTE$ + sInfoMsg1 + #DQUOTE$)
  
  With WMI
    If IsGadget(\lblInfoMsg1)
      SGT(\lblInfoMsg1, sInfoMsg1)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMI_displayInfoMsg2(sInfoMsg2.s)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", sInfoMsg2=" + sInfoMsg2)
  
  With WMI
    If IsGadget(\lblInfoMsg2)
      ; debugMsg(sProcName, "sInfoMsg2=" + #DQUOTE$ + sInfoMsg2 + #DQUOTE$)
      SGT(\lblInfoMsg2, sInfoMsg2)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMI_setProgress(nProgressValue)
  PROCNAMEC()
  Protected nMaxValue, nReqdValue
  
  ; debugMsg(sProcName, #SCS_START + ", nProgressValue=" + nProgressValue)
  
  With WMI
    nReqdValue = nProgressValue
    nMaxValue = GetGadgetAttribute(\prbInfoProgress, #PB_ProgressBar_Maximum)
    If nReqdValue > nMaxValue
      nReqdValue = nMaxValue
    EndIf
    ; debugMsg(sProcName, "nProgressValue=" + nProgressValue + ", nMaxValue=" + nMaxValue + ", nReqdValue=" + nReqdValue + ", \lblInfoMsg1=" + GGT(\lblInfoMsg1) + ", \lblInfoMsg2=" + GGT(\lblInfoMsg2))
    SGS(\prbInfoProgress, nReqdValue)
    RedrawWindow_(GadgetID(\prbInfoProgress), 0, 0, #RDW_INVALIDATE)
  EndWith
  
EndProcedure

Procedure WMI_clearInfoMsgs()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  setWindowVisible(#WMI, #False)
  With WMI
    SGT(\lblInfoMsg1, "")
    SGT(\lblInfoMsg2, "")
    SGS(\prbInfoProgress, 0)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure
  
Procedure WMI_EventHandler()
  PROCNAMEC()
  
  With WMI
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WMI_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
;         Select gnEventGadgetNoForEvHdlr
;             
;           Default
;             debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
;         EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF