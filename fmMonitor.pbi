; File: fmMonitor.pbi

EnableExplicit

Procedure WMO_Form_Load(nWindowNo)
  PROCNAMECW(nWindowNo)
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(nWindowNo) = #False
    createfmMonitor(nWindowNo)
  EndIf

EndProcedure

Procedure WMO_Form_Unload(nIndex)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex)
  
  debugMsg(sProcName, "calling CloseWindow(" + decodeWindow(gnEventWindowNo) + ")")
  CloseWindow(gnEventWindowNo)
EndProcedure

Procedure WMO_cvsMonitorDragBar_Event(nIndex)
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop
  Protected n, nMonitorWindowNo
  
  With grWMO
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        For n = 0 To ArraySize(WMO())
          nMonitorWindowNo = #WM2 + n
          If IsWindow(nMonitorWindowNo)
            \nWindowStartLeft[n] = WindowX(nMonitorWindowNo)
            \nWindowStartTop[n] = WindowY(nMonitorWindowNo)
          EndIf
        Next n
        \nDragBarStartX = DesktopMouseX()
        \nDragBarStartY = DesktopMouseY()
        \bDragBarMoving = #True
        
      Case #PB_EventType_MouseMove
        If \bDragBarMoving
          nDeltaX = \nDragBarStartX - DesktopMouseX()
          nDeltaY = \nDragBarStartY - DesktopMouseY()
          For n = 0 To ArraySize(WMO())
            nMonitorWindowNo = #WM2 + n
            If IsWindow(nMonitorWindowNo)
              nNewLeft = \nWindowStartLeft[n] - nDeltaX
              nNewTop = \nWindowStartTop[n] - nDeltaY
              ResizeWindow(nMonitorWindowNo, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
              CompilerIf #c_include_tvg
                If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
                  repositionMonitorDisplays(nMonitorWindowNo)
                EndIf
              CompilerEndIf
            EndIf
          Next n
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bDragBarMoving = #False
        debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(#WMN)")
        SAW(#WMN)
        debugMsg(sProcName, "nIndex=" + nIndex + ", SAW(#WMN), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WMO_EventHandler()
  PROCNAMEC()
  Protected nIndex
  
  nIndex = getIndexForMonitorWindowNo(gnEventWindowNo)
  ; debugMsg(sProcName, "nIndex=" + nIndex)
  
  With WMO(nIndex)
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WMO_Form_Unload(nIndex)
        
      Case #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \cntMonitor
            ; no action
            
          Case \aMonitor(0)\cvsMonitorCanvas
            ; no action
            
          Case \cvsMonitorDragBar
            WMO_cvsMonitorDragBar_Event(nIndex)
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
