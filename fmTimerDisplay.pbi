; File: fmTimerDisplay.pbi

EnableExplicit

Procedure WTI_Form_Unload()
  getFormPosition(#WTI, @grTimerDisplayWindow, #True)
  scsCloseWindow(#WTI)
EndProcedure

Procedure WTI_Form_Load(bMakeWindowVisible)
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected sSampleTime.s
  Protected sCaption.s
  Protected nTextWidth, nLeft
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WTI) = #False
    setUpWTIFont(1.0)
    createfmTimerDisplay()
    If IsWindow(#WTI)
      sSampleTime = "2:59:59"
      If StartDrawing(CanvasOutput(WTI\cvsTimer))
        scsDrawingFont(#SCS_FONT_WMN_NORMAL)
        grWTI\nCaptionHeight = TextHeight("8g") + 4
        scsDrawingFont(#SCS_FONT_WTI)
        grWTI\nTimeHeight = TextHeight("8") + 8   ; + 8 to allow for an 4 pixel margin top and bottom
        grWTI\nBaseTimeHeight = grWTI\nTimeHeight
        nCanvasWidth = TextWidth(sSampleTime) + 16  ; + 16 to allow for an 8 pixel margin left and right
        grWTI\nBaseTimeWidth = nCanvasWidth
        ; note: WTI_displayTimer() will increase the width of the canvas and window if necessary
        nCanvasHeight = grWTI\nCaptionHeight + grWTI\nTimeHeight
        StopDrawing()
        ResizeGadget(WTI\cvsTimer, #PB_Ignore, #PB_Ignore, nCanvasWidth, nCanvasHeight)
        ResizeWindow(#WTI, #PB_Ignore, #PB_Ignore, nCanvasWidth, nCanvasHeight)
        If StartDrawing(CanvasOutput(WTI\cvsTimer))
          Box(0,0,nCanvasWidth,grWTI\nCaptionHeight,$303030)
          scsDrawingFont(#SCS_FONT_WMN_NORMAL)
          sCaption = Lang("WTI","Window")
          nTextWidth = TextWidth(sCaption)
          If nTextWidth < nCanvasWidth
            nLeft = (nCanvasWidth - nTextWidth) >> 1
          EndIf
          DrawText(nLeft, 0, sCaption, #SCS_Dim_Yellow, $303030)
          Box(0, grWTI\nCaptionHeight, nCanvasWidth, grWTI\nTimeHeight, #SCS_Black)
          drawResizeHandle(#SCS_Yellow)
          StopDrawing()
        EndIf
      EndIf
    EndIf
  EndIf
  
  If IsWindow(#WTI)
    setFormPosition(#WTI, @grTimerDisplayWindow, -1, #True)
    WTI_Form_Resize()
    If bMakeWindowVisible
      setWindowVisible(#WTI, #True)
      setWindowSticky(#WTI, #True) ; Added 1Oct2021 11.8.6as
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTI_Form_Resize()
  PROCNAMEC()
  Protected nNewWidth, nNewHeight
  Protected fFactorX.f, fFactorY.f, fFontFactor.f
  Protected nNewFontSize
  
  debugMsg(sProcName, #SCS_START)
  
  With grWTI
    nNewWidth = WindowWidth(#WTI)
    nNewHeight = WindowHeight(#WTI)
    \nTimeHeight = nNewHeight - \nCaptionHeight
    ResizeGadget(WTI\cvsTimer, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
    fFactorX = nNewWidth / \nBaseTimeWidth
    fFactorY = \nTimeHeight / \nBaseTimeHeight
    If fFactorX < fFactorY
      fFontFactor = fFactorX
    Else
      fFontFactor = fFactorY
    EndIf
    setUpWTIFont(fFontFactor)
    \bRedoCaption = #True
    debugMsg(sProcName, "calling WTI_displayTimer(" + #DQUOTE$ + \sDisplayTime + #DQUOTE$ + ", #True)")
    WTI_displayTimer(\sDisplayTime, #True)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTI_cvsTimer_Event()
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nMouseX, nMouseY
  
  With grWTI
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        nMouseX = GetGadgetAttribute(WTI\cvsTimer, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WTI\cvsTimer, #PB_Canvas_MouseY)
        If nMouseY < 15
          \nTimerStartLeft = WindowX(#WTI)
          \nTimerStartTop = WindowY(#WTI)
          \nTimerStartX = DesktopMouseX()
          \nTimerStartY = DesktopMouseY()
          \bTimerMoving = #True
          \bTimerResizing = #False
        ElseIf (nMouseY >= GadgetHeight(WTI\cvsTimer) - 20) And (nMouseX >= GadgetWidth(WTI\cvsTimer) - 20)
          \nTimerStartX = DesktopMouseX()
          \nTimerStartY = DesktopMouseY()
          \nTimerStartWidth = GadgetWidth(WTI\cvsTimer)
          \nTimerStartHeight = GadgetHeight(WTI\cvsTimer)
          \bTimerResizing = #True
          \bTimerMoving = #False
          \bRedoCaption = #True
        EndIf
        
      Case #PB_EventType_MouseMove
        If \bTimerMoving
          nDeltaX = \nTimerStartX - DesktopMouseX()
          nDeltaY = \nTimerStartY - DesktopMouseY()
          nNewLeft = \nTimerStartLeft - nDeltaX
          nNewTop = \nTimerStartTop - nDeltaY
          ResizeWindow(#WTI, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
        ElseIf \bTimerResizing
          nDeltaX = \nTimerStartX - DesktopMouseX()
          nDeltaY = \nTimerStartY - DesktopMouseY()
          nNewWidth = \nTimerStartWidth - nDeltaX
          If nNewWidth < 110
            nNewWidth = 110
          EndIf
          nNewHeight = \nTimerStartHeight - nDeltaY
          If nNewHeight < 50
            nNewHeight = 50
          EndIf
          ResizeWindow(#WTI, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
          WTI_Form_Resize()
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bTimerMoving = #False
        \bTimerResizing = #False
        SetActiveWindow(#WMN)
        debugMsg(sProcName, "SetActiveWindow(#WMN), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WTI_displayTimer(sProdTimer.s, bForceDisplay=#False)
  PROCNAMEC()
  Protected nCanvasWidth
  Protected nTextWidth, nLeft
  Protected sDisplayTime.s
  Protected nNewWidth
  Protected bCheckActiveWindow, nActiveWindow
  Static sCaption.s, nCaptionWidth
  Static bStaticLoaded
  Static nSamCallNo
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ; ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure may resize gadgets
  If gnThreadNo > #SCS_THREAD_MAIN
    nSamCallNo + 1  ; nSamCallNo unique to prevent 'duplicate' request being rejected, important if setting "0:00" after setting ""
    samAddRequest(#SCS_SAM_DISPLAY_TIMER, nSamCallNo, 0, bForceDisplay, sProdTimer)
    ProcedureReturn
  EndIf
  
  With grWTI
    
    sDisplayTime = sProdTimer
    If (sDisplayTime <> \sDisplayTime) Or (bForceDisplay)
      \sDisplayTime = sDisplayTime
      
      If \bCheckWindowExistsAndVisible
        debugMsg(sProcName, "\bCheckWindowExistsAndVisible=" + strB(\bCheckWindowExistsAndVisible))
        If IsWindow(#WTI) = #False
          debugMsg(sProcName, "calling WTI_Form_Load(#True)")
          WTI_Form_Load(#True)
        ElseIf getWindowVisible(#WTI) = #False
          debugMsg(sProcName, "calling setWindowVisible(#WTI, #True)")
          setWindowVisible(#WTI, #True)
        EndIf
        \bCheckWindowExistsAndVisible = #False
        debugMsg(sProcName, "\bCheckWindowExistsAndVisible=" + strB(\bCheckWindowExistsAndVisible))
      EndIf
      
      nTextWidth = GetTextWidth(sDisplayTime, #SCS_FONT_WTI)
      nCanvasWidth = GadgetWidth(WTI\cvsTimer)
      If nTextWidth > (nCanvasWidth - 16)
        nNewWidth = nTextWidth + 16
      Else
        nNewWidth = nCanvasWidth
      EndIf
      
      If nNewWidth > nCanvasWidth
        nActiveWindow = GetActiveWindow()
        bCheckActiveWindow = #True
        debugMsg(sProcName, "calling ResizeGadget(WTI\cvsTimer, #PB_Ignore, #PB_Ignore, " + nNewWidth + ", #PB_Ignore)")
        ResizeGadget(WTI\cvsTimer, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
        debugMsg(sProcName, "calling ResizeWindow(#WTI, #PB_Ignore, #PB_Ignore, " + nNewWidth + ", #PB_Ignore)")
        ResizeWindow(#WTI, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
        nCanvasWidth = GadgetWidth(WTI\cvsTimer)
      EndIf
      
      If StartDrawing(CanvasOutput(WTI\cvsTimer))
        ; display time
        scsDrawingFont(#SCS_FONT_WTI)
        nLeft = (nCanvasWidth - nTextWidth) >> 1
        Box(0, grWTI\nCaptionHeight, nCanvasWidth, grWTI\nTimeHeight, #SCS_Black)
        drawResizeHandle(#SCS_Yellow)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(nLeft, grWTI\nCaptionHeight+4, sDisplayTime, #SCS_Yellow, #SCS_Black)
        ; caption (if necessary)
        If \bRedoCaption
          Box(0, 0, nCanvasWidth, grWTI\nCaptionHeight, $303030)
          scsDrawingFont(#SCS_FONT_WMN_NORMAL)
          If bStaticLoaded = #False
            sCaption = Lang("WTI","Window")
            nCaptionWidth = TextWidth(sCaption)
            bStaticLoaded = #True
          EndIf
          If nCaptionWidth < nCanvasWidth
            nLeft = (nCanvasWidth - nCaptionWidth) >> 1
          Else
            nLeft = 0
          EndIf
          DrawText(nLeft, 0, sCaption, #SCS_Dim_Yellow, $303030)
        EndIf
        StopDrawing()
        
        If bCheckActiveWindow
          If GetActiveWindow() <> nActiveWindow
            If IsWindow(nActiveWindow)
              debugMsg(sProcName, "calling SetActiveWindow()=" + decodeWindow(nActiveWindow))
              SetActiveWindow(nActiveWindow)
            EndIf
          EndIf
        EndIf
        
      EndIf
      
      ; debugMsg(sProcName, "sDisplayTime=" + sDisplayTime + ", nCanvasWidth=" + nCanvasWidth + ", nNewWidth=" + Str(nNewWidth))
      
    EndIf
    
  EndWith
  
EndProcedure

Procedure WTI_EventHandler()
  PROCNAMEC()
  
  With WTI
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WTI_Form_Unload()
        
      Case #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          debugMsg(sProcName, "calling WMN_processRightClick()")
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsTimer
            WTI_cvsTimer_Event()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WTI_hideWindowIfInactive()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WTI)
    If getWindowVisible(#WTI)
      setWindowVisible(#WTI, #False)
      grWTI\bCheckWindowExistsAndVisible = #True ; force window to be redisplayed if required
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", \bCheckWindowExistsAndVisible=" + strB(grWTI\bCheckWindowExistsAndVisible))
  
EndProcedure

; EOF
