; File: fmClock.pbi

EnableExplicit

Procedure WCL_Form_Unload()
  Protected bNewMenuItemState
  
  ; Set the Menu Item
  If GetMenuItemState(#WMN_mnuView, #WMN_mnuViewClock) = 1
    bNewMenuItemState = #False
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewClock, bNewMenuItemState)
  EndIf
  grMisc\bClockDisplayed = #False ; Added 3Dec2022 11.9.7ar
  
  RemoveWindowTimer(#WCL, #SCS_TIMER_CLOCK)
  getFormPosition(#WCL, @grClockWindow, #True)
  scsCloseWindow(#WCL)
  
EndProcedure

Procedure WCL_Form_Load(bMakeWindowVisible)
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected sSampleTime.s, bNewMenuItemState
  
  debugMsg(sProcName, #SCS_START)
    
  If IsWindow(#WCL) = #False
    setUpWCLFont(1.0)
    createfmClock()
    If IsWindow(#WCL)
      sSampleTime = "99:99:99"  ; only used for establishing the base width
      If StartDrawing(CanvasOutput(WCL\cvsClock))
        scsDrawingFont(#SCS_FONT_WCL)
        grWCL\nTimeHeight = TextHeight("8") + 8   ; + 8 to allow for an 4 pixel margin top and bottom
        grWCL\nBaseTimeHeight = grWCL\nTimeHeight
        nCanvasWidth = TextWidth(sSampleTime) + 16  ; + 16 to allow for an 8 pixel margin left and right
        StopDrawing()
        grWCL\nBaseTimeWidth = nCanvasWidth
        nCanvasHeight = grWCL\nTimeHeight
        ResizeGadget(WCL\cvsClock, #PB_Ignore, #PB_Ignore, nCanvasWidth, nCanvasHeight)
        ResizeWindow(#WCL, #PB_Ignore, #PB_Ignore, nCanvasWidth, nCanvasHeight)
;         If StartDrawing(CanvasOutput(WCL\cvsClock))
;           Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
;           drawResizeHandle(#SCS_White)
;           StopDrawing()
;         EndIf
      EndIf
    EndIf
    
  EndIf
  
  If IsWindow(#WCL)
    setFormPosition(#WCL, @grClockWindow, -1, #True)
    WCL_Form_Resize()
    If bMakeWindowVisible
      setWindowVisible(#WCL, #True)
    EndIf
    AddWindowTimer(#WCL, #SCS_TIMER_CLOCK, 500)  
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCL_Form_Resize()
  PROCNAMEC()
  Protected nNewWidth, nNewHeight
  Protected fFactorX.f, fFactorY.f, fFontFactor.f
  Protected nNewFontSize
  
  With grWCL
    nNewWidth = WindowWidth(#WCL)
    nNewHeight = WindowHeight(#WCL)
    ResizeGadget(WCL\cvsClock, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
    fFactorX = nNewWidth / \nBaseTimeWidth
    fFactorY = nNewHeight / \nBaseTimeHeight
    If fFactorX < fFactorY
      fFontFactor = fFactorX
    Else
      fFontFactor = fFactorY
    EndIf
    setUpWCLFont(fFontFactor)
    WCL_displayClock()
  EndWith
EndProcedure

Procedure WCL_cvsClock_Event()
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nMouseX, nMouseY
  
  With grWCL
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        nMouseX = GetGadgetAttribute(WCL\cvsClock, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WCL\cvsClock, #PB_Canvas_MouseY)
        If nMouseY < 15
          \nNearEndStartLeft = WindowX(#WCL)
          \nNearEndStartTop = WindowY(#WCL)
          \nNearEndStartX = DesktopMouseX()
          \nNearEndStartY = DesktopMouseY()
          \bNearEndMoving = #True
          \bNearEndResizing = #False
        ElseIf (nMouseY >= GadgetHeight(WCL\cvsClock) - 20) And (nMouseX >= GadgetWidth(WCL\cvsClock) - 20)
          \nNearEndStartX = DesktopMouseX()
          \nNearEndStartY = DesktopMouseY()
          \nNearEndStartWidth = GadgetWidth(WCL\cvsClock)
          \nNearEndStartHeight = GadgetHeight(WCL\cvsClock)
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
          ResizeWindow(#WCL, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
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
          ResizeWindow(#WCL, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
          WCL_Form_Resize()
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bNearEndMoving = #False
        \bNearEndResizing = #False
        SAW(#WCL)
        debugMsg(sProcName, "SetActiveWindow(#WCL), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WCL_setCurrentTime()
  Protected nCurrentTime, nCurrentHour, nCurrentMinute, nCurrentSecond
  
  nCurrentTime = Date()
  
  With WCL
    nCurrentHour = Hour(nCurrentTime)
    If \b12hrMode
      ; Warning: gb12hrMode currently not implemented, ie \b12hrMode is never set #True
      If nCurrentHour < 10
        \sCurrentTime = "0" + Str(nCurrentHour) + ":"
        \stt = " AM"
      Else
        nCurrentHour = nCurrentHour - 12
        \sCurrentTime = "0" + Str(nCurrentHour) + ":"
        \stt = " PM"
      EndIf
    Else
      \sCurrentTime = Str(nCurrentHour) + ":"
    EndIf 
    
    nCurrentMinute = Minute(nCurrentTime)
    If nCurrentMinute < 10 
      \sCurrentTime = \sCurrentTime + "0" + Str(nCurrentMinute) + ":"
    Else
      \sCurrentTime = \sCurrentTime + Str(nCurrentMinute) + ":"
    EndIf
    
    nCurrentSecond = Second(nCurrentTime)
    If nCurrentSecond < 10
      \sCurrentTime = \sCurrentTime + "0" + Str(nCurrentSecond) + \stt
    Else
      \sCurrentTime = \sCurrentTime + Str(nCurrentSecond) + \stt
    EndIf
  EndWith
  
EndProcedure

Procedure WCL_displayClock()
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight, nTextWidth, nLeft
  Protected sCaption.s, sDisplayTime.s
  Protected nNewWidth
  Protected nPass, bResized
  Static nTimeTop
  Static bStaticLoaded
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure may resize gadgets
  
  If bStaticLoaded = #False
    nTimeTop = grWCL\nCaptionHeight + 4
    bStaticLoaded = #True
  EndIf
  
  WCL_setCurrentTime()
  
  ; use 2 passes if necessary because ResizeGadget(WCL\cvsClock,...) appears to destroy anything currently drawn on that canvas
  For nPass = 1 To 2
    bResized = #False
    nCanvasWidth = GadgetWidth(WCL\cvsClock)
    nCanvasHeight = GadgetHeight(WCL\cvsClock)
    If StartDrawing(CanvasOutput(WCL\cvsClock))
      scsDrawingFont(#SCS_FONT_WCL)
      nTextWidth = TextWidth(WCL\sCurrentTime)
      If nPass = 1
        If nTextWidth > (nCanvasWidth - 16)
          nNewWidth = nTextWidth + 16
          ResizeGadget(WCL\cvsClock, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
          ResizeWindow(#WCL, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
          nCanvasWidth = GadgetWidth(WCL\cvsClock)
          bResized = #True
        EndIf
      EndIf
      nLeft = (nCanvasWidth - nTextWidth) >> 1
      Box(0, 0, nCanvasWidth, nCanvasHeight, #SCS_Black)
      drawResizeHandle(#SCS_White)
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(nLeft, nTimeTop, WCL\sCurrentTime, #SCS_White, #SCS_Black)
      StopDrawing()
    EndIf
    If bResized = #False
      Break
    EndIf
  Next nPass

  ; debugMsg(sProcName, "sDisplayTime=" + sDisplayTime + ", nCanvasWidth=" + nCanvasWidth + ", nNewWidth=" + Str(nNewWidth))
  
EndProcedure

Procedure WCL_EventHandler()
  PROCNAMEC()
  Protected nDisplayTime
  
  With WCL
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WCL_Form_Unload()
        
      Case #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsClock
            WCL_cvsClock_Event()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #PB_Event_Timer
        If EventTimer() = #SCS_TIMER_CLOCK
          WCL_displayClock()
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
