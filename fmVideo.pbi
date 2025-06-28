; File: fmVideo.pbi

EnableExplicit

Procedure WVN_Form_Load(nWindowNo, nUseLeft=0, nUseTop=0, nUseWidth=0, nUseHeight=0, nWinLeft=0, nWinTop=0, nWinWidth=0, nWinHeight=0)
  PROCNAMECW(nWindowNo)
  Protected nWinMidPointX, nWinMidPointY, nVideoWindow, bOverlaps
  
  debugMsg(sProcName, #SCS_START + ", nWindowNo=" + decodeWindow(nWindowNo))
  
  If IsWindow(nWindowNo) = #False
    ; see also createVideoWindows() where the follwoing code is reproduced to prevent windows being maximised when they shouldn't
    ; which would occur if there are insufficient physical screens available for the required number of 'screens' requested in cues in the cue file
    If nWindowNo > #WV2
      nWinMidPointX = nWinLeft + (nWinWidth >> 1)
      nWinMidPointY = nWinTop + (nWinHeight >> 1)
      For nVideoWindow = #WV2 To (nWindowNo - 1)
        If nWinMidPointX > WindowX(nVideoWindow) And nWinMidPointX < (WindowX(nVideoWindow) + WindowWidth(nVideoWindow))
          If nWinMidPointY > WindowY(nVideoWindow) And nWinMidPointY < (WindowY(nVideoWindow) + WindowHeight(nVideoWindow))
            bOverlaps = #True
            Break
          EndIf
        EndIf
      Next nVideoWindow
    EndIf
    If bOverlaps
      debugMsg(sProcName, "calling createfmVideo(" + decodeWindow(nWindowNo) + ", " + nUseLeft + ", " + nUseTop + ", " + nUseWidth + ", " + nUseHeight + ")")
      createfmVideo(nWindowNo, nUseLeft, nUseTop, nUseWidth, nUseHeight)
    Else
      debugMsg(sProcName, "calling createfmVideo(" + decodeWindow(nWindowNo) + ", " + nUseLeft + ", " + nUseTop + ", " + nUseWidth + ", " + nUseHeight +
                          ", " + nWinLeft + ", " + nWinTop + ", " + nWinWidth + ", " + nWinHeight + ")")
      createfmVideo(nWindowNo, nUseLeft, nUseTop, nUseWidth, nUseHeight, nWinLeft, nWinTop, nWinWidth, nWinHeight)
    EndIf
  EndIf
  
EndProcedure

Procedure WVN_Form_Resize(nWindowNo, nUseLeft, nUseTop, nUseWidth, nUseHeight, nWinLeft, nWinTop, nWinWidth, nWinHeight)
  PROCNAMECW(nWindowNo)
  ; procedure added 14May2018 11.7.1ak as part of the fix for the bug reported by Sue Hickson whereby if the secondary screen is disconnected (and then possibly reconnected)
  ; the window may be moved by Windows to a different display and may be of a different size
  Protected bFormResized
  Protected nIndex, n, nCntLeft, nCntTop
  
  debugMsg(sProcName, #SCS_START + ", nWindowNo=" + decodeWindow(nWindowNo) + ", nUseLeft=" + nUseLeft + ", nUseTop=" + nUseTop + ", nUseWidth=" + nUseWidth + ", nUseHeight=" + nUseHeight +
                      ", nWinLeft=" + nWinLeft + ", nWinTop=" + nWinTop + ", nWinWidth=" + nWinWidth + ", nWinHeight=" + nWinHeight)
  
  If gbVideosOnMainWindow = #False ; Test added 15Sep2020 11.8.3.2ay
    If IsWindow(nWindowNo)
      nIndex = getIndexForVideoWindowNo(nWindowNo)
      With WVN(nIndex)
        If (WindowX(nWindowNo) <> nWinLeft) Or
           (WindowY(nWindowNo) <> nWinTop) Or
           (WindowWidth(nWindowNo) <> nWinWidth) Or
           (WindowHeight(nWindowNo) <> nWinHeight) Or
           (GadgetWidth(\cntMainPicture) <> nUseWidth) Or
           (GadgetHeight(\cntMainPicture) <> nUseHeight)
          ResizeWindow(nWindowNo, nWinLeft, nWinTop, nWinWidth, nWinHeight)
          debugMsg(sProcName, "ResizeWindow(" + decodeWindow(nWindowNo) + ", " + nWinLeft + ", " + nWinTop + ", " + nWinWidth + ", " + nWinHeight + ")")
          bFormResized = #True
          nCntLeft = nUseLeft - nWinLeft
          nCntTop = nUseTop - nWinTop
          ; Added 17May2020 11.8.3rc5a
          If gbVideosOnMainWindow
            nCntTop + GadgetHeight(\cvsDragBar)
          EndIf
          ; End added 17May2020 11.8.3rc5a
          ResizeGadget(\cntMainPicture, nCntLeft, nCntTop, nUseWidth, nUseHeight)
          ResizeImage(\imgMainPicture, nUseWidth, nUseHeight)
          ResizeImage(\imgMainBlack, nUseWidth, nUseHeight)
          ResizeImage(\imgMainBlended, nUseWidth, nUseHeight)
          For n = 0 To ArraySize(\aVideo())
            ResizeGadget(\aVideo(n)\cvsCanvas, 0, 0, nUseWidth, nUseHeight)
          Next n
          If IsGadget(\rchMemo)
            ResizeGadget(\rchMemo, 0, 0, nUseWidth, nUseHeight)
          EndIf
          debugMsg(sProcName, "WindowX(" + decodeWindow(nWindowNo) + ")=" + WindowX(nWindowNo) + ", WindowY()=" + WindowY(nWindowNo) + ", WindowWidth()=" + WindowWidth(nWindowNo) + ", WindowHeight()=" + WindowHeight(nWindowNo))
        EndIf
      EndWith
    EndIf ; EndIf IsWindow(nWindowNo)
  EndIf ; EndIf gbVideosOnMainWindow = #False
  
  ProcedureReturn bFormResized
EndProcedure

Procedure WVN_Form_Unload(nIndex)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex)
  
  debugMsg(sProcName, "WindowX(" + decodeWindow(gnEventWindowNo) + ")=" + WindowX(gnEventWindowNo) + ", WindowY()=" + WindowY(gnEventWindowNo) + ", WindowWidth()=" + WindowWidth(gnEventWindowNo) + ", WindowHeight()=" + WindowHeight(gnEventWindowNo))
  debugMsg(sProcName, "calling CloseWindow(" + decodeWindow(gnEventWindowNo) + ")")
  CloseWindow(gnEventWindowNo)
EndProcedure

Procedure WVN_cvsDragBar_Event(nIndex)
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop
  Protected n, nWindowNo
  
  With grWVN
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        For n = 0 To ArraySize(WVN())
          nWindowNo = #WV2 + n
          If IsWindow(nWindowNo)
            \nWindowStartLeft[n] = WindowX(nWindowNo)
            \nWindowStartTop[n] = WindowY(nWindowNo)
          EndIf
        Next n
        \nDragBarStartX = DesktopMouseX()
        \nDragBarStartY = DesktopMouseY()
        \bDragBarMoving = #True
        
      Case #PB_EventType_MouseMove
        If \bDragBarMoving
          nDeltaX = \nDragBarStartX - DesktopMouseX()
          nDeltaY = \nDragBarStartY - DesktopMouseY()
          For n = 0 To ArraySize(WVN())
            nWindowNo = #WV2 + n
            If IsWindow(nWindowNo)
              nNewLeft = \nWindowStartLeft[n] - nDeltaX
              nNewTop = \nWindowStartTop[n] - nDeltaY
              ; debugMsg(sProcName, "calling ResizeWindow(" + decodeWindow(nWindowNo) + ", " + nNewLeft + ", " + nNewTop + ", #PB_Ignore, #PB_Ignore)")
              ResizeWindow(nWindowNo, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
              debugMsg(sProcName, "ResizeWindow(" + decodeWindow(nWindowNo) + ", " + nNewLeft + ", " + nNewTop + ", #PB_Ignore, #PB_Ignore)")
              CompilerIf #c_include_tvg
                If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
                  repositionMainDisplays(nWindowNo)
                EndIf
              CompilerEndIf
            EndIf
          Next n
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bDragBarMoving = #False
        debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(#WMN)")
        SAW(#WMN)
        debugMsg(sProcName, "SetActiveWindow(#WMN), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WVN_MoveWindow(nVideoWindowNo)
  ; Procedure added 30Jun2020 11.8.3.2ah for Brian Hacker because #WV2 appears to be being moved over the top of #WMN (possibly by Windows 10?)
  PROCNAMECW(nVideoWindowNo)
  Protected nVidPicTarget
  
  debugMsg(sProcName, #SCS_START)
  
  Select nVideoWindowNo
    Case #WV2 To #WV_LAST
      nVidPicTarget = getVidPicTargetForVideoWindowNo(nVideoWindowNo)
      debugMsg(sProcName, "nVidPicTarget=" + decodeVidPicTarget(nVidPicTarget))
      With grVidPicTarget(nVidPicTarget)
        debugMsg(sProcName, "calling WVN_Form_Resize(" + decodeWindow(nVideoWindowNo) +
                            ", main: " + \nMainWindowX + ", " + \nMainWindowY + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight +
                            ", full: " + \nFullWindowX + ", " + \nFullWindowY + ", " + \nFullWindowWidth + ", " + \nFullWindowHeight + ")")
        WVN_Form_Resize(nVideoWindowNo, \nMainWindowX, \nMainWindowY, \nMainWindowWidth, \nMainWindowHeight, \nFullWindowX, \nFullWindowY, \nFullWindowWidth, \nFullWindowHeight)
      EndWith
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVN_EventHandler()
  PROCNAMEC()
  Protected nIndex
  Protected nWindowNo
  Protected sMsg.s
  Static nMoveWindowCount
  
  nIndex = getIndexForVideoWindowNo(gnEventWindowNo)
  ; debugMsg(sProcName, "nIndex=" + nIndex)
  
  With WVN(nIndex)
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WVN_Form_Unload(nIndex)
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsDragBar
            WVN_cvsDragBar_Event(nIndex)
            
          Case \aVideo(0)\cvsCanvas
            ; ignore events
            
          Default
            ; debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName( gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
      Case #PB_Event_SizeWindow
        nWindowNo = #WV2 + nIndex
        sMsg = decodeWindow(nWindowNo) + " #PB_Event_SizeWindow WindowX=" + WindowX(nWindowNo) + ", WindowY=" + WindowY(nWindowNo) +
               ", WindowWidth=" + WindowWidth(nWindowNo) + ", WindowHeight=" + WindowHeight(nWindowNo)
        debugMsg(sProcName, sMsg)
        debugMsg(sProcName, "calling checkMonitorInfo()")
        checkMonitorInfo()
        
      Case #PB_Event_MoveWindow
        If gbVideosOnMainWindow = #False ; test added 14Sep2020 11.8.3.2ay to prevent main window being blacked out by a full-screen #WV2
          ; Added 30Jun2020 11.8.3.2ah for Brian Hacker because #WV2 appears to be being moved over the top of #WMN (possibly by Windows 10?)
          nWindowNo = #WV2 + nIndex
          sMsg = decodeWindow(nWindowNo) + " #PB_Event_MoveWindow WindowX=" + WindowX(nWindowNo) + ", WindowY=" + WindowY(nWindowNo) +
                 ", WindowWidth=" + WindowWidth(nWindowNo) + ", WindowHeight=" + WindowHeight(nWindowNo)
          debugMsg(sProcName, sMsg)
          debugMsg(sProcName, "calling checkMonitorInfo()")
          checkMonitorInfo()
          debugMsg(sProcName, "WindowX(" + decodeWindow(nWindowNo) + ")=" + WindowX(nWindowNo) + ", WindowY()=" + WindowY(nWindowNo) +
                              ", WindowWidth()=" + WindowWidth(nWindowNo) + ", WindowHeight()=" + WindowHeight(nWindowNo))
          debugMsg(sProcName, "WindowX(#WMN)=" + WindowX(#WMN) + ", WindowY()=" + WindowY(#WMN) +
                              ", WindowWidth()=" + WindowWidth(#WMN) + ", WindowHeight()=" + WindowHeight(#WMN))
          If WindowX(nWindowNo) >= WindowX(#WMN) And WindowX(nWindowNo) <= (WindowX(#WMN) + WindowWidth(#WMN)) And
             WindowY(nWindowNo) >= WindowY(#WMN) And WindowY(nWindowNo) <= (WindowY(#WMN) + WindowHeight(#WMN))
            nMoveWindowCount + 1
            If nMoveWindowCount < 10
              ; This test (using the static variable nMoveWindowCount) is in case the auto-moving of the window starts looping after WVN_MoveWindow() has moved the window back to the original position.
              debugMsg(sProcName, "calling WVN_MoveWindow(nWindowNo)")
              WVN_MoveWindow(nWindowNo)
            EndIf
          EndIf
          ; End added 30Jun2020 11.8.3.2ah
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
