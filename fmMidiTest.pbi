; File: fmMidiTest.pbi
; also used for RS232 and Network testing

EnableExplicit

Procedure WMT_PopulateForDevice()
  PROCNAMEC()
  Protected sWindowTitle.s, sInfo.s
  Protected bShowMTC
  
  Select grWMT\nWMTDeviceType
    Case #SCS_WMT_MIDI
      sWindowTitle = Lang("WMT", "MIDITest")
      sInfo = Lang("WMT", "MonitorMidi")
      bShowMTC = #True
      
    Case #SCS_WMT_RS232
      sWindowTitle = Lang("WMT", "RS232Test")
      sInfo = Lang("WMT", "MonitorRS232")
      
    Case #SCS_WMT_NETWORK
      sWindowTitle = Lang("WMT", "NetworkTest")
      sInfo = Lang("WMT", "MonitorNetwork")
      
  EndSelect
  
  SetWindowTitle(#WMT, sWindowTitle)
  SGT(WMT\lblMidiTestInfo, sInfo)
  setVisible(WMT\lblMTC, bShowMTC)
  setVisible(WMT\lblMTCValue, bShowMTC)
  
EndProcedure

Procedure WMT_btnClear_Click()
  ClearGadgetItems(WMT\lstTestMidiInfo)
  SGT(WMT\lblMTCValue, "00:00:00:00")
EndProcedure

Procedure WMT_Form_Show(nWMTDeviceType, nDevType, bModal=#False, nParentWindow=#WED)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nWMTDeviceType=" + nWMTDeviceType)
  
  If IsWindow(#WMT) = #False
    createfmMidiTest(nParentWindow)
  EndIf
  
  grWMT\nWMTDeviceType = nWMTDeviceType
  grWMT\nDevType = nDevType
  gbMidiTestWindow = #True    ; nb 'gbMidiTestWindow' applies to all device types that use #WMT
  debugMsg(sProcName, "gbMidiTestWindow=" + strB(gbMidiTestWindow))
  
  WMT_PopulateForDevice()
  setFormPosition(#WMT, @grMidiTestWindow)
  setWindowModal(#WMT, bModal)
  setWindowVisible(#WMT, #True)
  SetActiveWindow(#WMT)
  
EndProcedure

Procedure WMT_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WMT, @grMidiTestWindow)
  ; closeMidiPorts()
  gbMidiTestWindow = #False
  debugMsg(sProcName, "gbMidiTestWindow=" + strB(gbMidiTestWindow))
  unsetWindowModal(#WMT)
  scsCloseWindow(#WMT)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WMT_EventHandler()
  PROCNAMEC()
  
  With WMT
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WMT_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            WMT_Form_Unload()
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WMT_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
          Case \btnClear
            WMT_btnClear_Click()
          Case \btnOK
            WMT_Form_Unload()
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WMT_DisplayTimeCode(nTimeCode.l)
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, decodeMTCTime(nTimeCode))
  SGT(WMT\lblMTCValue, decodeMTCTime(nTimeCode))
  
EndProcedure

Procedure WMT_addListItem(sMidiInName.s, sTxt1.s, sTxt2.s="")
  PROCNAMEC()
  
  With WMT
    If Len(sTxt2) = 0
      AddGadgetItem(\lstTestMidiInfo, -1, sMidiInName + ": " + sTxt1)
      debugMsg(sProcName, "sMidiInName=" + sMidiInName + ", sTxt1=" + sTxt1)
    Else
      AddGadgetItem(\lstTestMidiInfo, -1, sMidiInName + ": " + sTxt1)
      AddGadgetItem(\lstTestMidiInfo, -1, sMidiInName + ":   " + sTxt2)
      debugMsg(sProcName, "sMidiInName=" + sMidiInName + ", sTxt1=" + sTxt1 + ", sTxt2=" + sTxt2)
    EndIf
    ; scroll to last entry, so entry just added is visible
    SetGadgetState(\lstTestMidiInfo, CountGadgetItems(\lstTestMidiInfo)-1)
    SetGadgetState(\lstTestMidiInfo, -1)
  EndWith
EndProcedure

Procedure WMT_addMiscListItem(sTxt1.s)
  PROCNAMEC()
  
  With WMT
    AddGadgetItem(\lstTestMidiInfo, -1, sTxt1)
    debugMsg(sProcName, sTxt1)
    ; scroll to last entry, so entry just added is visible
    SetGadgetState(\lstTestMidiInfo, CountGadgetItems(\lstTestMidiInfo)-1)
    SetGadgetState(\lstTestMidiInfo, -1)
  EndWith
EndProcedure

; EOF
