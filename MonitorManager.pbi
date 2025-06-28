; File: MonitorManager.pbi

; manage video monitor windows

EnableExplicit

Procedure setMaxAndMinOutputScreen()
  PROCNAMEC()
  Protected nThisOutputScreen, nThisMonitorWindow
  Protected bFirstTimeScreen = #True, bFirstTimeMonitor = #True
  Protected i, j
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  With grVideoMonitors
    For n = 0 To ArraySize(\bScreenReqd())
      \bScreenReqd(n) = #False
    Next n
    
    \nMaxOutputScreen = -1
    \nMinOutputScreen = -1
    \nMaxMonitorWindow = -1
    \nMinMonitorWindow = -1
    \nMaxOutputScreenIncludingDefaultScreen = grProd\nDefOutputScreen
    
    For i = 1 To gnLastCue
      If aCue(i)\bCueEnabled
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          ; output screens
          If aSub(j)\bSubEnabled
            If aSub(j)\bSubTypeA Or aSub(j)\bSubTypeE
              ; loadArrayOutputScreenReqd(j)  ; nb shouldn't be necessary to call this here
              For nThisOutputScreen = 2 To ArraySize(aSub(j)\bOutputScreenReqd())
                ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bOutputScreenReqd(" + nThisOutputScreen + ")=" + strB(aSub(j)\bOutputScreenReqd(nThisOutputScreen)))
                If aSub(j)\bOutputScreenReqd(nThisOutputScreen)
                  \bScreenReqd(nThisOutputScreen) = #True
                  If bFirstTimeScreen
                    \nMaxOutputScreen = nThisOutputScreen
                    \nMaxOutputSubCuePtr = j
                    \nMinOutputScreen = nThisOutputScreen
                    bFirstTimeScreen = #False
                  Else
                    If nThisOutputScreen > \nMaxOutputScreen
                      \nMaxOutputScreen = nThisOutputScreen
                      \nMaxOutputSubCuePtr = j
                    EndIf
                    If nThisOutputScreen < \nMinOutputScreen
                      \nMinOutputScreen = nThisOutputScreen
                    EndIf
                  EndIf
                EndIf
              Next nThisOutputScreen
            EndIf
          EndIf
          ; monitor windows
          nThisMonitorWindow = -1
          If aSub(j)\bSubTypeA
            nThisMonitorWindow = aSub(j)\nOutputScreen  ; \nOutputScreen is the 'primary' output screen
          ElseIf aSub(j)\bSubTypeE
            nThisMonitorWindow = aSub(j)\nMemoScreen
          EndIf
          If nThisMonitorWindow >= 2
            \bMonitorReqd(nThisMonitorWindow) = #True
            If bFirstTimeMonitor
              \nMaxMonitorWindow = nThisMonitorWindow
              \nMaxMonitorSubCuePtr = j
              \nMinMonitorWindow = nThisMonitorWindow
              bFirstTimeMonitor = #False
            Else
              If nThisMonitorWindow > \nMaxMonitorWindow
                \nMaxMonitorWindow = nThisMonitorWindow
                \nMaxMonitorSubCuePtr = j
              EndIf
              If nThisMonitorWindow < \nMinMonitorWindow
                \nMinMonitorWindow = nThisMonitorWindow
              EndIf
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf ; EndIf aCue(i)\bCueEnabled
    Next i
    
    \nMaxOutputScreenIncludingDefaultScreen = \nMaxOutputScreen
    If grProd\nDefOutputScreen > \nMaxOutputScreen
      \nMaxOutputScreenIncludingDefaultScreen = grProd\nDefOutputScreen
    EndIf
    
    \nOutputScreenCount = 0
    For n = 0 To ArraySize(\bScreenReqd())
      If \bScreenReqd(n)
        \nOutputScreenCount + 1
      EndIf
    Next n
    
    \nMonitorWindowCount = 0
    For n = 0 To ArraySize(\bMonitorReqd())
      If \bMonitorReqd(n)
        \nMonitorWindowCount + 1
      EndIf
    Next n
    
    debugMsg(sProcName, "grVideoMonitors\nMaxOutputScreen=" + \nMaxOutputScreen + ", \nMinOutputScreen=" + \nMinOutputScreen + ", \nOutputScreenCount=" + \nOutputScreenCount +
                        ", \nMaxOutputSubCuePtr=" + getSubLabel(\nMaxOutputSubCuePtr))
    debugMsg(sProcName, "grVideoMonitors\nMaxMonitorWindow=" + \nMaxMonitorWindow + ", \nMinMonitorWindow=" + \nMinMonitorWindow + ", \nMonitorWindowCount=" + \nMonitorWindowCount +
                        ", \nMaxMonitorSubCuePtr=" + getSubLabel(\nMaxMonitorSubCuePtr))
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setMonitorPin()
  PROCNAMEC()
  Protected nMonitorWindowNo
  Protected bMonitorWindowFound
  Protected sMonitorPin.s
  Protected nMonitorRight, nMonitorTop, nMonitorHeight
  Protected sPrefKey.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected nFirstMonitorWindowNo, nLastMonitorWindowNo, nMemoWidth
  
  debugMsg(sProcName, #SCS_START)
  
  If gbVideosOnMainWindow
    nFirstMonitorWindowNo = #WV2
    nLastMonitorWindowNo = grLicInfo\nLastVideoWindowNo
  Else
    If (grVideoMonitors\bDisplayMonitorWindows = #False) Or (grVideoMonitors\bMonitorsPositioned = #False)
      ProcedureReturn
    EndIf
    nFirstMonitorWindowNo = #WM2
    nLastMonitorWindowNo = grLicInfo\nLastMonitorWindowNo
  EndIf
  
  For nMonitorWindowNo = nLastMonitorWindowNo To nFirstMonitorWindowNo Step -1
    If IsWindow(nMonitorWindowNo)
      bMonitorWindowFound = #True
      nMonitorRight = WindowX(nMonitorWindowNo) + WindowWidth(nMonitorWindowNo)
      nMemoWidth = WMN_getMemoWidth()
      If nMemoWidth > 0
        nMonitorRight + nMemoWidth
      EndIf
      nMonitorTop = WindowY(nMonitorWindowNo)
      nMonitorHeight = WindowHeight(nMonitorWindowNo)
      debugMsg(sProcName, "nMonitorWindowNo=" + decodeWindow(nMonitorWindowNo) + ", bMonitorWindowFound=" + strB(bMonitorWindowFound) + ", nMemoWidth=" + nMemoWidth +
                          ", nMonitorRight=" + nMonitorRight + ", nMonitorTop=" + nMonitorTop + ", nMonitorHeight=" + nMonitorHeight)
      Break
    EndIf
  Next nMonitorWindowNo
  
  If bMonitorWindowFound
    If (nMonitorRight > 0) And (nMonitorRight <= WindowWidth(#WMN))
      If (nMonitorTop >= 0) And (nMonitorTop < (WindowHeight(#WMN) - nMonitorHeight))
        sMonitorPin = "TR;" + nMonitorRight + ";" + nMonitorTop
      EndIf
    EndIf
    If sMonitorPin <> grVideoMonitors\sMonitorPin
      ; COND_OPEN_PREFS("Windows")
      COND_OPEN_PREFS("Windows_" + gsMonitorKey)
      sPrefKey = "MonitorPin"
      If sMonitorPin
        debugMsg(sProcName, "calling WritePreferenceString(" + sPrefKey + ", " + sMonitorPin + ")")
        WritePreferenceString(sPrefKey, sMonitorPin)
      Else
        debugMsg(sProcName, "calling RemovePreferenceKey(" + sPrefKey + ")")
        RemovePreferenceKey(sPrefKey)
      EndIf
      COND_CLOSE_PREFS()
      grVideoMonitors\sMonitorPin = sMonitorPin
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure positionVideoMonitorsOrWindows(bMonitors)
  PROCNAMEC()
  Protected n, n2
  Protected nVideoWindowNo, nMonitorWindowNo, nWindowCount
  Protected nMonitorLeft, nMonitorRight, nMonitorTop
  Protected nMonitorHeight, nMonitorWidth
  Protected nWindowHeight
  Protected Dim nMonitorWidthArray(0)
  Protected nTotalWidthOfMonitors
  Protected nTextWidth, sCaption.s
  Protected nDragBarWidth, nDragBarHeight
  Protected nLeft
  Protected nLastMonitorWidth, nLastMonitorHeight
  Protected nLastMonitorRight, nLastMonitorTop
  Protected nVidPicTarget
  Protected nContainerGadget, nCanvasGadget, nDragBarGadget, nContainerWidth
  Protected sField1.s, sField2.s, sField3.s
  Protected nMemoWidth
  Protected nCurrMonitorCount, nMaxRight, nMinTop, nThisRight, nThisTop
  Protected nVideoCanvas
  Protected nBlanketDesktopIndex
  Protected nRealX, nRealY
  
  debugMsg(sProcName, #SCS_START + ", bMonitors=" + strB(bMonitors))
  
  If bMonitors
    If grVideoMonitors\bDisplayMonitorWindows = #False
      debugMsg(sProcName, "exiting because grVideoMonitors\bDisplayMonitorWindows=" + strB(grVideoMonitors\bDisplayMonitorWindows))
      ProcedureReturn
    EndIf
  Else
    If gbVideosOnMainWindow = #False
      debugMsg(sProcName, "exiting because gbVideosOnMainWindow=" + strB(gbVideosOnMainWindow))
      ProcedureReturn
    EndIf
  EndIf
  
  debugMsg(sProcName, "grVideoMonitors\sMonitorPin=" + grVideoMonitors\sMonitorPin)
  sField1 = StringField(grVideoMonitors\sMonitorPin, 1, ";")
  sField2 = StringField(grVideoMonitors\sMonitorPin, 2, ";")
  sField3 = StringField(grVideoMonitors\sMonitorPin, 3, ";")
  
  If (sField1 = "TR") And (IsInteger(sField2)) And (IsInteger(sField3))
    nLastMonitorRight = Val(sField2)
    nLastMonitorTop = Val(sField3)
  Else
    ; \sMonitorPin not set or invalid - use default settings
    nLastMonitorRight = WindowX(#WMN, #PB_Window_InnerCoordinate) + WindowWidth(#WMN, #PB_Window_InnerCoordinate) - (gl3DBorderWidth * 2)
    nLastMonitorTop = GadgetY(WMN\splNorthSouth, #PB_Gadget_ScreenCoordinate) + gl3DBorderWidth
  EndIf
  
  nMemoWidth = WMN_getMemoWidth()
  If nMemoWidth > 0
    nLastMonitorRight - nMemoWidth
  EndIf
  
  debugMsg(sProcName, "nMemoWidth=" + nMemoWidth + ", nLastMonitorRight=" + nLastMonitorRight + ", nLastMonitorTop=" + nLastMonitorTop)
  
  nCurrMonitorCount = ExamineDesktops()
  
  ; added 16Dec2019 11.8.2.1ag
  nBlanketDesktopIndex = getBlanketDesktopIndex()
  If (nBlanketDesktopIndex > 0) And (nBlanketDesktopIndex = nCurrMonitorCount - 1)
    ; the last desktop entry is a 'blanket' (dummy) entry covering other desktop settings - can be caused when using a VNC connection (emails from Rob Widdicombe Oct2019), so ignore the last entry
    debugMsg(sProcName, "ignoring last 'desktop'")
    nCurrMonitorCount - 1
  EndIf
  ; end added 16Dec2019 11.8.2.1ag
  
  ; Deleted the following 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;   With grOperModeOptions(gnOperMode)
;     If (\nMaxMonitor > 0) And (\nMaxMonitor < nCurrMonitorCount)
;       nCurrMonitorCount = \nMaxMonitor
;     EndIf
;   EndWith
  debugMsg(sProcName, "nCurrMonitorCount=" + nCurrMonitorCount)
  For n = 0 To (nCurrMonitorCount - 1)
    debugMsg(sProcName, "n=" + n + ", DesktopX(n)=" + DesktopX(n) + ", DesktopY(n)=" + DesktopY(n) + ", DesktopWidth(n)=" + DesktopWidth(n) + ", DesktopHeight(n)=" + DesktopHeight(n))
    If n = 0
      nMaxRight = DesktopX(n) + DesktopWidth(n) - 1
      nMinTop = DesktopY(n)
    Else
      nThisRight = DesktopX(n) + DesktopWidth(n) - 1
      If nThisRight > nMaxRight
        nMaxRight = nThisRight
      EndIf
      nThisTop = DesktopY(n)
      If nThisTop < nMinTop
        nMinTop = nThisTop
      EndIf
    EndIf
  Next n
  If nLastMonitorRight > nMaxRight
    nLastMonitorRight = nMaxRight
  EndIf
  If nLastMonitorTop < nMinTop
    nLastMonitorTop = nMinTop
  EndIf
  debugMsg(sProcName, "nLastMonitorRight=" + nLastMonitorRight + ", nLastMonitorTop=" + nLastMonitorTop)
  
  If bMonitors
    nWindowCount = (grVideoMonitors\nMaxMonitorWindow - 1)
    debugMsg(sProcName, "grVideoMonitors\nMaxMonitorWindow=" + grVideoMonitors\nMaxMonitorWindow + ", nWindowCount=" + nWindowCount)
  Else
    nWindowCount = (grVideoMonitors\nMaxOutputScreen - 1)
    debugMsg(sProcName, "grVideoMonitors\nMaxOutputScreen=" + grVideoMonitors\nMaxOutputScreen + ", nWindowCount=" + nWindowCount)
  EndIf
  If nWindowCount < 1
    nWindowCount = 1
  EndIf
  ReDim nMonitorWidthArray(nWindowCount-1)
  
  Select grOperModeOptions(gnOperMode)\nMonitorSize
    Case #SCS_MON_SMALL
      nMonitorHeight = 80
    Case #SCS_MON_STD
      nMonitorHeight = 160
    Case #SCS_MON_LARGE
      nMonitorHeight = 240
    Default
      nMonitorHeight = 160
  EndSelect
  
  If bMonitors
    For n = 0 To (nWindowCount - 1)
      If IsGadget(WMO(n)\cvsMonitorDragBar)
        nDragBarHeight = GadgetHeight(WMO(n)\cvsMonitorDragBar)
        Break
      EndIf
    Next n
  Else
    For n = 0 To (nWindowCount - 1)
      If IsGadget(WVN(n)\cvsDragBar)
        nDragBarHeight = GadgetHeight(WVN(n)\cvsDragBar)
        Break
      EndIf
    Next n
  EndIf
  nWindowHeight = nMonitorHeight + nDragBarHeight
  debugMsg(sProcName, "nMonitorHeight=" + nMonitorHeight + ", nDragBarHeight=" + nDragBarHeight + ", nWindowHeight=" + nWindowHeight)
  
  ; calculate widths of individual monitor windows to correspond with the aspect ratio of the corresponding video window (#WV2 etc)
  For n = 0 To (nWindowCount - 1)
    nVideoWindowNo = #WV2 + n
    If IsWindow(nVideoWindowNo)
      If bMonitors
        nLastMonitorWidth = WindowWidth(nVideoWindowNo)
        nLastMonitorHeight = WindowHeight(nVideoWindowNo) - nDragBarHeight
        debugMsg(sProcName, "WindowWidth(" + decodeWindow(nVideoWindowNo) + ")=" + WindowWidth(nVideoWindowNo) + ", WindowHeight(" + decodeWindow(nVideoWindowNo) + ")=" + WindowHeight(nVideoWindowNo))
      Else
        nLastMonitorWidth = gaScreen(1)\nScreenWidth
        nLastMonitorHeight = gaScreen(1)\nScreenHeight
      EndIf
      If nLastMonitorHeight > 0
        nMonitorWidthArray(n) = nMonitorHeight * nLastMonitorWidth / nLastMonitorHeight
        debugMsg(sProcName, "nMonitorWidthArray(" + n + ")=" + nMonitorWidthArray(n) + ", nMonitorHeight=" + nMonitorHeight + ", nLastMonitorWidth=" + nLastMonitorWidth + ", nLastMonitorHeight=" + nLastMonitorHeight)
        If (bMonitors = #False) And (gnScreens = 1)
          ResizeImage(WVN(n)\imgMainBlack, nMonitorWidthArray(n), nMonitorHeight)
          ResizeImage(WVN(n)\imgMainBlended, nMonitorWidthArray(n), nMonitorHeight)
          ResizeImage(WVN(n)\imgMainPicture, nMonitorWidthArray(n), nMonitorHeight)
        EndIf
        nTotalWidthOfMonitors + nMonitorWidthArray(n)
      EndIf
    EndIf
  Next n
  debugMsg(sProcName, "nTotalWidthOfMonitors=" + nTotalWidthOfMonitors)
  
  nMonitorLeft = nLastMonitorRight - nTotalWidthOfMonitors - (nWindowCount - 1) ; "- (nWindowCount - 1)" added 15Jan2022 11.9.0am to provide an extra single-pixel gap between monitors
  nMonitorTop = nLastMonitorTop
  
  For n = 0 To (nWindowCount - 1)
    If bMonitors
      nMonitorWindowNo = #WM2 + n
    Else
      nMonitorWindowNo = #WV2 + n
    EndIf
    
    debugMsg(sProcName, "n=" + n + ", nMonitorWindowNo=" + decodeWindow(nMonitorWindowNo))
    If IsWindow(nMonitorWindowNo)
      nMonitorWidth = nMonitorWidthArray(n)
      If n < (nWindowCount - 1)
        nContainerWidth = nMonitorWidth + 1
      Else
        nContainerWidth = nMonitorWidth
      EndIf
      ResizeWindow(nMonitorWindowNo, nMonitorLeft, nMonitorTop, nContainerWidth, nWindowHeight)
      debugMsg(sProcName, "ResizeWindow(" + decodeWindow(nMonitorWindowNo) + ", " + nMonitorLeft + ", " + nMonitorTop + ", " + nContainerWidth + ", " + nWindowHeight + ")")
      
      If bMonitors
        nContainerGadget = WMO(n)\cntMonitor
        nCanvasGadget = WMO(n)\aMonitor(0)\cvsMonitorCanvas
        nDragBarGadget = WMO(n)\cvsMonitorDragBar
      Else
        nContainerGadget = WVN(n)\cntMainPicture
        nCanvasGadget = WVN(n)\aVideo(0)\cvsCanvas
        nDragBarGadget = WVN(n)\cvsDragBar
      EndIf
      
      If (GadgetWidth(nContainerGadget) <> nContainerWidth) Or (GadgetHeight(nContainerGadget) <> nMonitorHeight)
        ResizeGadget(nContainerGadget,#PB_Ignore,#PB_Ignore,nContainerWidth,nMonitorHeight)
        debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nContainerGadget) + ",#PB_Ignore,#PB_Ignore," + nContainerWidth + "," + nMonitorHeight + ")")
        SetGadgetColor(nContainerGadget, #PB_Gadget_BackColor, #SCS_Black)
      EndIf
      
      If (GadgetWidth(nCanvasGadget) <> nMonitorWidth) Or (GadgetHeight(nCanvasGadget) <> nMonitorHeight)
        ResizeGadget(nCanvasGadget,#PB_Ignore,#PB_Ignore,nMonitorWidth,nMonitorHeight)
        debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nCanvasGadget) + ",#PB_Ignore,#PB_Ignore," + nMonitorWidth + "," + nMonitorHeight + ")")
        If StartDrawing(CanvasOutput(nCanvasGadget))
          debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasGadget) + "))")
          Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
          debugMsgD(sProcName, "Box(0,0," + OutputWidth() + "," + OutputHeight() + ",#SCS_Black)")
          StopDrawing()
          debugMsgD(sProcName, "StopDrawing()")
        EndIf
      EndIf
      
      If IsGadget(nDragBarGadget)
        ResizeGadget(nDragBarGadget,#PB_Ignore,#PB_Ignore,nMonitorWidth,#PB_Ignore)
        debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nDragBarGadget) + ",#PB_Ignore,#PB_Ignore," + nMonitorWidth + ",#PB_Ignore)")
        If StartDrawing(CanvasOutput(nDragBarGadget))
          debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nDragBarGadget) + "))")
          ; scsDrawingFont(#SCS_FONT_WMN_NORMAL)
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          sCaption = Str(n+2)
          nTextWidth = TextWidth(sCaption)
          nDragBarWidth = GadgetWidth(nDragBarGadget)
          If nTextWidth < nDragBarWidth
            nLeft = (nDragBarWidth - nTextWidth) >> 1
          Else
            nLeft = 0
          EndIf
          Box(0,0,nDragBarWidth,nDragBarHeight,$303030)
          debugMsgD(sProcName, "Box(0,0," + nDragBarWidth + "," + nDragBarHeight + ",$303030)")
          debugMsgD(sProcName, "TextHeight(" + #DQUOTE$ + sCaption + #DQUOTE$ + ")=" + TextHeight(sCaption))
          DrawText(nLeft,0,sCaption,#SCS_Yellow,$303030)
          debugMsgD(sProcName, "DrawText(" + nLeft + ",0," + #DQUOTE$ + sCaption + #DQUOTE$ + ",#SCS_Yellow,$303030)")
          StopDrawing()
          debugMsgD(sProcName, "StopDrawing()")
        EndIf
      EndIf
      
      nVidPicTarget = #SCS_VID_PIC_TARGET_F2 + n
      Select nVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          With grVidPicTarget(nVidPicTarget)
            If grVideoMonitors\bDisplayMonitorWindows
              \nMonitorWindowNo = nMonitorWindowNo
              \nMonitorCanvasNo = nCanvasGadget ; added 7Feb2020 11.8.2.2ai
              \nMonitorWidth = nMonitorWidth
              \nMonitorHeight = nMonitorHeight
            Else
              \nMonitorWindowNo = 0
              \nMonitorCanvasNo = 0 ; added 7Feb2020 11.8.2.2ai
              \nMonitorWidth = 0
              \nMonitorHeight = 0
            EndIf
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nVideoCanvasNo=" + getGadgetName(\nVideoCanvasNo))
            If IsGadget(\nVideoCanvasNo)
              \nTargetWidth = GadgetWidth(\nVideoCanvasNo)
              \nTargetHeight = GadgetHeight(\nVideoCanvasNo)
            EndIf
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nMonitorWindowNo=" + decodeWindow(\nMonitorWindowNo) +
                                ", \nTargetWidth=" + \nTargetWidth + ", \nTargetHeight=" + \nTargetHeight)
          EndWith
      EndSelect
      
      If gbVideosOnMainWindow
        If IsWindow(nMonitorWindowNo)
          setWindowVisible(nMonitorWindowNo, #False)
        EndIf
      EndIf

      nMonitorLeft + nMonitorWidth + 1 ; "+ 1" added 15Jan2022 11.9.0am to provide an extra single-pixel gap between monitors
    EndIf
  Next n
  
  ; Added 29Jun2022 11.9.3ag
  If gnScreens = 1
    If nMonitorWidth > 0 And nMonitorHeight > 0
      For nVidPicTarget = 2 To grVideoMonitors\nMaxOutputScreen
        n2 = nVidPicTarget - 2
        With grVidPicTarget(nVidPicTarget)
          \nMainWindowWidth = nMonitorWidth
          \nMainWindowHeight = nMonitorHeight
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nMainWindowWidth=" + \nMainWindowWidth + ", \nMainWindowHeight=" + \nMainWindowHeight)
          ResizeImage(WVN(n2)\imgMainPicture, \nMainWindowWidth, \nMainWindowHeight)
          debugMsg(sProcName, "ResizeImage(" + decodeHandle(WVN(n2)\imgMainPicture) + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight + ")")
          ResizeImage(WVN(n2)\imgMainBlack, \nMainWindowWidth, \nMainWindowHeight)
          debugMsg(sProcName, "ResizeImage(" + decodeHandle(WVN(n2)\imgMainBlack) + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight + ")")
          WVN(n2)\rchMemoObject\Resize(0,0,\nMainWindowWidth,\nMainWindowHeight)
          If IsImage(WVN(n2)\imgMainBlended)
            ResizeImage(WVN(n2)\imgMainBlended, \nMainWindowWidth, \nMainWindowHeight)
            debugMsg(sProcName, "ResizeImage(" + decodeHandle(WVN(n2)\imgMainBlended) + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight + ")")
          Else
            debugMsg(sProcName, "IsImage(" + WVN(n2)\imgMainBlended + ") returned #False")
          EndIf
        EndWith
      Next nVidPicTarget
    EndIf
  EndIf
  ; End added 29Jun2022 11.9.3ag

  If nTotalWidthOfMonitors > 0
    grVideoMonitors\bMonitorsPositioned = #True ; enables setMonitorPin()
    setMonitorPin()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDisplayMonitorWindows()
  PROCNAMEC()
  
  With grVideoMonitors
    \bDisplayMonitorWindows = #False
    If gbVideosOnMainWindow = #False
      If grOperModeOptions(gnOperMode)\nMonitorSize <> #SCS_MON_NONE
        Select grVideoDriver\nVideoPlaybackLibrary
          Case #SCS_VPL_TVG ; NB deliberately omit #SCS_VPL_VMIX as vMix cannot display to the monitor window
            \bDisplayMonitorWindows = #True
        EndSelect
      EndIf
    EndIf
    debugMsg(sProcName, "grVideoMonitors\bDisplayMonitorWindows=" + strB(\bDisplayMonitorWindows))
  EndWith
EndProcedure

Procedure setupForAvailableMonitors()
  PROCNAMEC()
  Protected i, bOpenNextCues
  ; modifications made in this procedure 14May2018 11.7.1ak as part of the fix for the bug reported by Sue Hickson whereby if the secondary screen is disconnected (and then possibly reconnected)
  ; the window may be moved by Windows to a different display and may be of a different size

  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling populateMonitorInfo()")
  populateMonitorInfo()
  ; added in 11.7.1ak
  debugMsg(sProcName, "calling updateMonitorInfoForTVG()")
  updateMonitorInfoForTVG()
  ; end of added in 11.7.1ak
  ; split screen and screen adjustment settings
  debugMsg(sProcName, "loadPrefsScreenSettings()")
  loadPrefsScreenSettings()
  debugMsg(sProcName, "calling updateSplitScreenArray()")
  updateSplitScreenArray()
  debugMsg(sProcName, "calling populateScreenArray()")
  populateScreenArray()
  debugMsg(sProcName, "calling setVidPicTargets(#True)")
  setVidPicTargets(#True)
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \bSubTypeA
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState))
        If \nCueState < #SCS_CUE_COMPLETED
          closeCue(i)
          ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState))
          bOpenNextCues = #True
        EndIf
      EndIf
    EndWith
  Next i
  If bOpenNextCues
    debugMsg(sProcName, "calling ONC_openNextCues()")
    ONC_openNextCues()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkMonitorInfo()
  PROCNAMEC()
  ; procedure for checking if we have lost or gained a monitor (ie screen)
  Protected nMonitorsNow
  Static nMonitorsPrev
  
  ; debugMsg0(sProcName, #SCS_START)
  
  If grVideoMonitors\nMaxOutputScreen > 1
    nMonitorsNow = ExamineDesktops()
    If (#cMaxScreenNo > 0) And (#cMaxScreenNo < nMonitorsNow)
      nMonitorsNow = #cMaxScreenNo
    EndIf
    If nMonitorsPrev > 0
      If nMonitorsNow <> nMonitorsPrev
        debugMsg(sProcName, "nMonitorsPrev=" + nMonitorsPrev + ", nMonitorsNow=" + nMonitorsNow)
        If (nMonitorsNow = 1) And (nMonitorsPrev > 1)
          If IsWindow(#WV2)
            setWindowVisible(#WV2, #False)
          EndIf
        EndIf
        WMN_displayWarningMsg(LangPars("Errors", "MonitorsChanged2", Str(nMonitorsPrev), Str(nMonitorsNow)))
      EndIf
    EndIf
    nMonitorsPrev = nMonitorsNow
  EndIf
  
EndProcedure

Procedure drawMonitorDragBars(pVidPicTarget=#SCS_VID_PIC_TARGET_F2_TO_LAST)
  PROCNAMEC()
  Protected nVidPicTarget, nFromVidPicTarget, nUpToVidPicTarget, nMonitorIndex
  Protected sCaption.s
  Protected nTextWidth, nDragBarGadget, nDragBarWidth, nLeft
  
  If pVidPicTarget = #SCS_VID_PIC_TARGET_F2_TO_LAST
    nFromVidPicTarget = #SCS_VID_PIC_TARGET_F2
    nUpToVidPicTarget = #SCS_VID_PIC_TARGET_LAST
  Else
    nFromVidPicTarget = pVidPicTarget
    nUpToVidPicTarget = pVidPicTarget
  EndIf
  
  For nVidPicTarget = nFromVidPicTarget To nUpToVidPicTarget
    With grVidPicTarget(nVidPicTarget)
      If IsWindow(\nMonitorWindowNo)
        nMonitorIndex = nVidPicTarget - #SCS_VID_PIC_TARGET_F2
        If gbVideosOnMainWindow
          If nMonitorIndex <= ArraySize(WVN())
            nDragBarGadget = WVN(nMonitorIndex)\cvsDragBar
          EndIf
        Else
          If nMonitorIndex <= ArraySize(WMO())
            nDragBarGadget = WMO(nMonitorIndex)\cvsMonitorDragBar
          EndIf
        EndIf
        If IsGadget(nDragBarGadget)
          sCaption = Str(nVidPicTarget)
          If StartDrawing(CanvasOutput(nDragBarGadget))
            debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nDragBarGadget) + "))")
            scsDrawingFont(#SCS_FONT_GEN_NORMAL)
            nTextWidth = TextWidth(sCaption)
            nDragBarWidth = OutputWidth()
            If nTextWidth < nDragBarWidth
              nLeft = (nDragBarWidth - nTextWidth) >> 1
            Else
              nLeft = 0
            EndIf
            Box(0, 0, OutputWidth(), OutputHeight(), $303030)
            debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", $303030)")
            debugMsgD(sProcName, "TextHeight(" + #DQUOTE$ + sCaption + #DQUOTE$ + ")=" + TextHeight(sCaption))
            DrawText(nLeft, 0, sCaption, #SCS_Yellow, $303030)
            debugMsgD(sProcName, "DrawText(" + nLeft + ", 0, " + #DQUOTE$ + sCaption + #DQUOTE$ + ", #SCS_Yellow, $303030)")
            StopDrawing()
            debugMsgD(sProcName, "StopDrawing()")
          EndIf
        EndIf
      EndIf
    EndWith
  Next nVidPicTarget
  
EndProcedure

Procedure getScaledCoordinates(nRealX, nRealY, *nScaledX, *nScaledY)
  PROCNAMEC()
  Protected n, bMonitorFound
  Protected nThisScaledX.l, nThisScaledY.l
  
  For n = 1 To gnMonitors
    With gaMonitors(n)
      If (nRealX >= \nDesktopLeft) And (nRealX < (\nDesktopLeft + \nDesktopWidth))
        If (nRealY >= \nDesktopTop) And (nRealY < (\nDesktopTop + \nDesktopHeight))
          nThisScaledX = \nTVGDisplayLeft + Round((nRealX - \nDesktopLeft) * 100 /\nDisplayScalingPercentage, #PB_Round_Up)
          nThisScaledY = \nTVGDisplayTop + Round((nRealY - \nDesktopTop) * 100 / \nDisplayScalingPercentage, #PB_Round_Up)
          debugMsg(sProcName, "n=" + n + ", nRealX=" + nRealX + ", \nDesktopLeft=" + \nDesktopLeft + ", \nTVGDisplayLeft=" + \nTVGDisplayLeft + ", \nDisplayScalingPercentage=" + \nDisplayScalingPercentage + ", nThisScaledX=" + nThisScaledX)
          PokeL(*nScaledX, nThisScaledX)
          PokeL(*nScaledY, nThisScaledY)
          bMonitorFound = #True
          Break
        EndIf
      EndIf
    EndWith
  Next n
  ProcedureReturn bMonitorFound
EndProcedure

Procedure getScaledArea(nRealX, nRealY, nRealWidth, nRealHeight, *nScaledX, *nScaledY, *nScaledWidth, *nScaledHeight)
  PROCNAMEC()
  Protected nAreaScaledLeft.l, nAreaScaledTop.l, nAreaScaledRight.l, nAreaScaledBottom.l, nAreaScaledWidth.l, nAreaScaledHeight.l
  Protected nRealRight, nRealBottom
  Protected bScaled
  
  debugMsg(sProcName, #SCS_START + " nRealX=" + nRealX + ", nRealY=" + nRealY + ", nRealWidth=" + nRealWidth + ", nRealHeight=" + nRealHeight)
  nRealRight = nRealX + nRealWidth - 1
  nRealBottom = nRealY + nRealHeight - 1
  If getScaledCoordinates(nRealX, nRealY, @nAreaScaledLeft, @nAreaScaledTop)
    If getScaledCoordinates(nRealRight, nRealBottom, @nAreaScaledRight, @nAreaScaledBottom)
      nAreaScaledWidth = nAreaScaledRight - nAreaScaledLeft ; + 1
      nAreaScaledHeight = nAreaScaledBottom - nAreaScaledTop ; + 1
      debugMsg(sProcName, "nAreaScaledLeft=" + nAreaScaledLeft + ", nAreaScaledTop=" + nAreaScaledTop + ", nAreaScaledRight=" + nAreaScaledRight + ", nAreaScaledWidth=" + nAreaScaledWidth + ", nAreaScaledHeight=" + nAreaScaledHeight)
      bScaled = #True
      PokeL(*nScaledX, nAreaScaledLeft)
      PokeL(*nScaledY, nAreaScaledTop)
      PokeL(*nScaledWidth, nAreaScaledWidth)
      PokeL(*nScaledHeight, nAreaScaledHeight)
    EndIf
  EndIf
  ProcedureReturn bScaled
EndProcedure

Procedure.s buildMonitorKey()
  PROCNAMEC()
  Protected nMonitorNo, sMonitorKey.s, nSwapMonitor
  
  sMonitorKey = Str(gnMonitors)
  If gbSwapMonitors1and2
    sMonitorKey + "s" + gnSwapMonitor
  EndIf
  sMonitorKey + ":"
  For nMonitorNo = 1 To gnMonitors
    If nMonitorNo > 1
      sMonitorKey + ";"
    EndIf
    sMonitorKey + nMonitorNo + "@"
    With gaMonitors(nMonitorNo)
      sMonitorKey + \nMonitorBoundsLeft + "," + \nMonitorBoundsTop + "," + \nMonitorBoundsWidth + "x" + \nMonitorBoundsHeight
    EndWith
  Next nMonitorNo
  ProcedureReturn sMonitorKey
  
EndProcedure

Procedure getBlanketDesktopIndex()
  PROCNAMEC()
  ; Procedure added 16Dec2019 11.8.2.1ag following bug report from Rob Widdicombe ('Trogwold') in Oct 2019 who had 'desktop' settings of:
  ;   DesktopX(0)=0, DesktopY(0)=0, DesktopWidth(0)=1440, DesktopHeight(0)=900      0,0,1440,900
  ;   DesktopX(1)=1440, DesktopY(1)=0, DesktopWidth(1)=1920, DesktopHeight(1)=1080  1440,0,1920,1080
  ;   DesktopX(2)=5280, DesktopY(2)=0, DesktopWidth(2)=1920, DesktopHeight(2)=1080  5280,0,1920,1080
  ;   DesktopX(3)=3360, DesktopY(3)=0, DesktopWidth(3)=1920, DesktopHeight(3)=1080  3360,0,1920,1080
  ;   DesktopX(4)=0,    DesktopY(4)=0, DesktopWidth(4)=7200, DesktopHeight(4)=1080  0,0,7200,1080
  ; but TVG MonitorBounds of:
  ;   nMonitorIndex=0, nLeftBound=0,    nTopBound=0, nRightBound=1440, nBottomBound=900  0,0,1440,900  scaling 100%
  ;   nMonitorIndex=1, nLeftBound=1440, nTopBound=0, nRightBound=2720, nBottomBound=720  1440,0,1280,720  scaling 150%
  ;   nMonitorIndex=2, nLeftBound=3360, nTopBound=0, nRightBound=4640, nBottomBound=720  3360,0,1280,720  scaling 150%
  ;   nMonitorIndex=3, nLeftBound=5280, nTopBound=0, nRightBound=6560, nBottomBound=720  5280,0,1280,720  scaling 150%
  ; note that Desktop 4 is not included in TVG MonitorBounds which is reasonable because it is a blanket desktop definition that covers all 4 monitors
  ; Rob advised that this condition occurs when using VNC (see email 8Oct2019)
  ; NOTE: A 'fix' was originally applied in updateMonitorInfoForTVG() but this was deleted 16Dec2019 11.8.2.1ag following analysis of log files from Vincent Rijntjes
  ; that showed some legitimate secondary screens being 'deleted', possibly due to scaling. This procedure (getBlanketDesktopIndex()) and calls to this procedure
  ; will hopefully provide a safer solution as this checks if the last desktop definition appears to be a blanket definition and if so then returns the index so
  ; calling procedures can ignore that last desktop definition.
  Protected nDesktops, nBlanketDesktopIndex
  Protected nLastDesktopIndex, nLastLeft, nLastTop, nLastRight, nLastBottom
  Protected nThisDesktopIndex, nThisLeft, nThisTop, nThisRight, nThisBottom
  
  nBlanketDesktopIndex = -1
  nDesktops = ExamineDesktops()
  If nDesktops > 1
    nLastDesktopIndex = nDesktops - 1
    nLastLeft = DesktopX(nLastDesktopIndex)
    nLastTop = DesktopY(nLastDesktopIndex)
    nLastRight = nLastLeft + DesktopWidth(nLastDesktopIndex) - 1
    nLastBottom = nLastTop + DesktopHeight(nLastDesktopIndex) - 1
    For nThisDesktopIndex = 0 To nLastDesktopIndex - 1
      nThisLeft = DesktopX(nThisDesktopIndex)
      nThisTop = DesktopY(nThisDesktopIndex)
      nThisRight = nThisLeft + DesktopWidth(nThisDesktopIndex) - 1
      nThisBottom = nThisTop + DesktopHeight(nThisDesktopIndex) - 1
      If (nThisLeft >= nLastLeft) And (nThisRight <= nLastRight) And (nThisTop >= nLastTop) And (nThisBottom <= nLastBottom)
        ; desktop nThisDesktopIndex is fully contained within the last desktop so assume the last desktop is a blanket definition
        nBlanketDesktopIndex = nLastDesktopIndex
        Break
      EndIf
    Next nThisDesktopIndex
  EndIf
  
  If nBlanketDesktopIndex >= 0
    debugMsg(sProcName, "DesktopX(" + nBlanketDesktopIndex + ")=" + DesktopX(nBlanketDesktopIndex) + ", DesktopY(" + nBlanketDesktopIndex + ")=" + DesktopY(nBlanketDesktopIndex) +
                        ", DesktopWidth(" + nBlanketDesktopIndex + ")=" + DesktopWidth(nBlanketDesktopIndex) + ", DesktopHeight(" + nBlanketDesktopIndex + ")=" + DesktopHeight(nBlanketDesktopIndex))
  EndIf
  debugMsg(sProcName, #SCS_END + ", returning nBlanketDesktopIndex=" + nBlanketDesktopIndex)
  ProcedureReturn nBlanketDesktopIndex
  
EndProcedure

; EOF