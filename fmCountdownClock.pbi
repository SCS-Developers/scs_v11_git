; File : fmCountdownClock.pbi

EnableExplicit

Procedure WCD_Form_Unload()
  
  ; Set the Menu Item
  If GetMenuItemState(#WMN_mnuView, #WMN_mnuViewCountdown)
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewCountdown, #False)
  EndIf
  
  If WCD\nCountDownTime < 0
    gnCountDownSessionTime = 0
  EndIf
  RemoveWindowTimer(#WCD, #SCS_TIMER_COUNTDOWN)
  getFormPosition(#WCD, @grCountDownWindow, #True)
  scsCloseWindow(#WCD)
  
EndProcedure

Procedure WCD_Form_Load(bMakeWindowVisible)
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected sSampleTime.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WCD) = #False
    WCD\nTime = gnCountDownSessionTime
    setUpWCDFont(1.0)
    createfmCountdownClock()
    If IsWindow(#WCD)
      sSampleTime = "99:99:99"  ; only used for establishing the base width
      If StartDrawing(CanvasOutput(WCD\cvsCountdown))
        scsDrawingFont(#SCS_FONT_WCD)
        grWCD\nTimeHeight = TextHeight("8") + 8   ; + 8 to allow for an 4 pixel margin top and bottom
        grWCD\nBaseTimeHeight = grWCD\nTimeHeight
        nCanvasWidth = TextWidth(sSampleTime) + 16  ; + 16 to allow for an 8 pixel margin left and right
        grWCD\nBaseTimeWidth = nCanvasWidth
        nCanvasHeight = grWCD\nTimeHeight
        StopDrawing()
        ResizeGadget(WCD\cvsCountdown,#PB_Ignore,#PB_Ignore,nCanvasWidth,nCanvasHeight)
        ResizeWindow(#WCD,#PB_Ignore,#PB_Ignore,nCanvasWidth,nCanvasHeight)
        If StartDrawing(CanvasOutput(WCD\cvsCountdown))
          Box(0,0,nCanvasWidth,nCanvasHeight,#SCS_Black)
          drawResizeHandle(#SCS_White)
          StopDrawing()
        EndIf
      EndIf
    EndIf
  EndIf
  
  If IsWindow(#WCD)
    setFormPosition(#WCD, @grCountDownWindow, -1, #True)
    WCD_Form_Resize()
    If bMakeWindowVisible
      setWindowVisible(#WCD, #True)
    EndIf
    If IsWindow(#WCD)
      AddWindowTimer(#WCD, #SCS_TIMER_COUNTDOWN, 500)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCD_Form_Resize()
  PROCNAMEC()
  Protected nNewWidth, nNewHeight
  Protected fFactorX.f, fFactorY.f, fFontFactor.f
  Protected nNewFontSize
  
  With grWCD
    nNewWidth = WindowWidth(#WCD)
    nNewHeight = WindowHeight(#WCD)
    ResizeGadget(WCD\cvsCountdown, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
    fFactorX = nNewWidth / \nBaseTimeWidth
    fFactorY = nNewHeight / \nBaseTimeHeight
    If fFactorX < fFactorY
      fFontFactor = fFactorX
    Else
      fFontFactor = fFactorY
    EndIf
    setUpWCDFont(fFontFactor)
;     WCD_displayCountdown(\nDisplayTime, \nDragBarCaptionCuePtr)
    WCD_displayCountdown()
  EndWith
EndProcedure

Procedure WCD_cvsCountdown_Event()
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nMouseX, nMouseY
  
  With grWCD
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        nMouseX = GetGadgetAttribute(WCD\cvsCountdown, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WCD\cvsCountdown, #PB_Canvas_MouseY)
        If nMouseY < 15
          \nNearEndStartLeft = WindowX(#WCD)
          \nNearEndStartTop = WindowY(#WCD)
          \nNearEndStartX = DesktopMouseX()
          \nNearEndStartY = DesktopMouseY()
          \bNearEndMoving = #True
          \bNearEndResizing = #False
        ElseIf (nMouseY >= GadgetHeight(WCD\cvsCountdown) - 20) And (nMouseX >= GadgetWidth(WCD\cvsCountdown) - 20)
          \nNearEndStartX = DesktopMouseX()
          \nNearEndStartY = DesktopMouseY()
          \nNearEndStartWidth = GadgetWidth(WCD\cvsCountdown)
          \nNearEndStartHeight = GadgetHeight(WCD\cvsCountdown)
          \bNearEndResizing = #True
          \bNearEndMoving = #False
          \bRedoCaption = #True
        EndIf
        
      Case #PB_EventType_MouseMove
        If \bNearEndMoving
          nDeltaX = \nNearEndStartX - DesktopMouseX()
          nDeltaY = \nNearEndStartY - DesktopMouseY()
          nNewLeft = \nNearEndStartLeft - nDeltaX
          nNewTop = \nNearEndStartTop - nDeltaY
          ResizeWindow(#WCD, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
        ElseIf \bNearEndResizing
          nDeltaX = \nNearEndStartX - DesktopMouseX()
          nDeltaY = \nNearEndStartY - DesktopMouseY()
          nNewWidth = \nNearEndStartWidth - nDeltaX
          If nNewWidth < 110
            nNewWidth = 110
          EndIf
          nNewHeight = \nNearEndStartHeight - nDeltaY
          If nNewHeight < 50
            nNewHeight = 50
          EndIf
          ResizeWindow(#WCD, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
          WCD_Form_Resize()
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bNearEndMoving = #False
        \bNearEndResizing = #False
        SAW(#WCD)
        debugMsg(sProcName, "SetActiveWindow(#WCD), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WCD_SetShowtime(nSetTime)
  WCD\nTime = nSetTime 
EndProcedure

Procedure WCD_FlashTimer(bEven)
  ; Purpose is to flash the timer here when countdown ended
  With WCD
    If bEven 
      \nFlashingBackColor = #SCS_Red
      \bFlashing = #True
    Else
      \nFlashingBackColor = #SCS_Black
      \bFlashing = #False
    EndIf
  EndWith
EndProcedure

Procedure WCD_SetShowTimer()
  Protected nCurrentTime, nCountUpTime, nPos
  
  nCurrentTime = Date()
  nCountUpTime = nCurrentTime - WCD\nTime
  
  WCD\sCompleteTime = FormatDate("%hh:%ii:%ss", nCountUpTime)
EndProcedure

Procedure.b WCD_ValidateEntry(sEntryTime.s)
  Protected nConvertedTime, bResult, nValue, nValue2
  Protected nPos, hh, ii, ss
  
  bResult = #True
  
  ; Validation Tests
  ; ------------------
  
  If bResult
    ; Count String
    If CountString(sEntryTime, ":") = 0
      MessageRequester(Lang("TIMERS", "InvalidFormat"), Lang("TIMERS", "TimeFormat"), #PB_MessageRequester_Ok)
      bResult = #False
    EndIf 
  EndIf
  
  If bResult
    ; Greater than 12 hours
    nPos = FindString(sEntryTime, ":")
    If nPos > 0
      nValue = Val(Left(sEntryTime, nPos-1))
    EndIf
    If nValue-12 > 12
      MessageRequester(Lang("TIMERS", "InvalidFormat"), Lang("TIMERS", "TooLongTime"), #PB_MessageRequester_Ok)
      bResult = #False
    EndIf
  EndIf
  
  
  If bResult
    ; Test Hour | Minutes | Seconds
    hh = nValue
    nPos = FindString(sEntryTime, ":", nPos)
    If nPos > 0
      ii = Val(StringField(sEntryTime, nPos-1, ":"))
    EndIf 
    If nPos > 0
      ss = Val(StringField(sEntryTime, nPos, ":"))  
    EndIf
    
    If hh > 23
      ; Error
      bResult = #False
    ElseIf ii > 59
      ; Error
      bResult = #False
    ElseIf  ss > 59
      ; Error
      bResult = #False
    EndIf
    
    If Not bResult 
      MessageRequester(Lang("TIMERS", "InvalidFormat"), Lang("TIMERS", "TooLongTime"), #PB_MessageRequester_Ok)
    EndIf
  EndIf
      
  ; ------------------
  
  If bResult
    nConvertedTime = stringToDateSeconds(sEntryTime)
    If nConvertedTime > 0
      WCD_SetShowtime(nConvertedTime)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
      ProcedureReturn #False
  EndIf 

  
EndProcedure

Procedure WCD_SetCountdownTime()
  PROCNAMEC()
  Protected sEnteredTime.s, sFormattedTime.s
  Protected bValidResponse, bUnloadForm
  
  With WCD
    If \nTime = 0
      \bCountDownOccurred = #False
      Repeat
        sEnteredTime = Trim(InputRequester(Lang("TIMERS","CountDownTitle"), LANG("TIMERS", "CountdownEntry"), ""))
        If sEnteredTime
          ; User entered a time, so validate the entry
          If WCD_ValidateEntry(sEnteredTime) ; nb sets \nTime if sEnteredTime is valid
            bValidResponse = #True
            gnCountDownSessionTime = \nTime
            sFormattedTime = LangPars("TIMERS", "CoundownTitle2", FormatDate("%hh:%ii:%ss", \nTime))
            debugMsg(sProcName, "sFormattedTime=" + sFormattedTime)
            SetWindowTitle(#WCD, sFormattedTime)
          Else
            bValidResponse = #False
          EndIf
        Else
          ; User didn't enter showtime so terminate the countdown timer
          bValidResponse = #True
          bUnloadForm = #True
          Break
        EndIf
      Until bValidResponse = #True
    EndIf
    
    If bUnloadForm
      ProcedureReturn #False
    EndIf
    
    \nCountDownTime = \nTime - Date()
    
    ; Check Counter still active
    If (\nCountDownTime > 0) And (\nCountDownTime <= 60)
      ; If counter has rundown completely
      If \nCountDownTime % 2 = 0
        WCD_FlashTimer(#True)
      Else
        WCD_FlashTimer(#False)
      EndIf
      \sCompleteTime = FormatDate("%hh:%ii:%ss", \nCountDownTime)
      \bCountDownOccurred = #True
      
    ElseIf \nCountDownTime < 0
      If \bCountDownOccurred
        ; Close this form automatically after a short delay
        Delay(5000) ; 5 Second display delay
        bUnloadForm = #True
      Else
        \sCompleteTime = "-" + FormatDate("%hh:%ii:%ss", (\nCountDownTime * -1))
      EndIf
      
    Else
      \sCompleteTime = FormatDate("%hh:%ii:%ss", \nCountDownTime)
      \bCountDownOccurred = #True
    EndIf
    ; debugMsg0(sProcName, "\sCompleteTime=" + \sCompleteTime + ", \bCountDownOccurred=" + strB(\bCountDownOccurred) + ", bUnloadForm=" + strB(bUnloadForm))
  EndWith
  
  If bUnloadForm
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WCD_displayCountdown()
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight, nTextWidth, nLeft
  Protected nNewWidth
  Protected nPass, bResized, nFrontColor, nBackColor
  Static nTimeTop
  Static bStaticLoaded
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure may resize gadgets
  
  If bStaticLoaded = #False
    nTimeTop = grWCD\nCaptionHeight + 4
    bStaticLoaded = #True
  EndIf
  
  If WCD_SetCountdownTime() = #False
    ProcedureReturn #False
  EndIf
  
  With WCD
    ; use 2 passes if necessary because ResizeGadget(WCD\cvsCountdown,...) appears to destroy anything currently drawn on that canvas
    For nPass = 1 To 2
      bResized = #False
      nCanvasWidth = GadgetWidth(\cvsCountdown)
      nCanvasHeight = GadgetHeight(\cvsCountdown)
      If StartDrawing(CanvasOutput(\cvsCountdown))
        scsDrawingFont(#SCS_FONT_WCD)
        nTextWidth = TextWidth(\sCompleteTime)
        If nPass = 1
          If nTextWidth > (nCanvasWidth - 16)
            nNewWidth = nTextWidth + 16
            ResizeGadget(\cvsCountdown, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
            ResizeWindow(#WCD, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
            nCanvasWidth = GadgetWidth(\cvsCountdown)
            bResized = #True
          EndIf
        EndIf
        nLeft = (nCanvasWidth - nTextWidth) >> 1
        If \bFlashing And \nCountDownTime > 0
          nBackColor = \nFlashingBackColor
          nFrontColor = #SCS_White
        ElseIf \nCountDownTime <= 0
          nBackColor = #SCS_Green
          nFrontColor = #SCS_Dark_Grey
        Else
          nBackColor = #SCS_Black
          nFrontColor = #SCS_White
        EndIf
        Box(0, 0, nCanvasWidth, nCanvasHeight, nBackColor)
        drawResizeHandle(nFrontColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        ; Draw the Current Time
        DrawText(nLeft, nTimeTop, \sCompleteTime, nFrontColor)
        StopDrawing()
      EndIf
      If bResized = #False
        Break
      EndIf
    Next nPass
  EndWith

  ; debugMsg(sProcName, "\sCompleteTime=" + \sCompleteTime)
  ProcedureReturn #True
  
EndProcedure

Procedure WCD_EventHandler()
  PROCNAMEC()
  Protected nDisplaytime
  
  With WCD
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WCD_Form_Unload()
        
      Case #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsCountdown
            WCD_cvsCountdown_Event()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #PB_Event_Timer
        If EventTimer() = #SCS_TIMER_COUNTDOWN
          If WCD_displayCountdown() = #False
            WCD_Form_Unload()
          EndIf
        EndIf 
        
    EndSelect
  EndWith
  
EndProcedure

; EOF

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 70
; FirstLine = 66
; Folding = --
; EnableThread
; EnableXP
; EnableOnError