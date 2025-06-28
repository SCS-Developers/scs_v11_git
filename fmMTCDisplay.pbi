; File: fmMTCDisplay.pbi

EnableExplicit

Procedure WTC_Form_Unload()
  getFormPosition(#WTC, @grMTCDisplayWindow, #True)
  scsCloseWindow(#WTC)
EndProcedure

Procedure WTC_Form_Load(bMakeWindowVisible)
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected sSampleTime.s
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WTC) = #False
    setUpWTCFont(1.0)
    createfmMTCDisplay()
    If IsWindow(#WTC)
      sSampleTime = "23:59:59:29" ; hh:mm:ss:ff
      If StartDrawing(CanvasOutput(WTC\cvsMTC))
          scsDrawingFont(#SCS_FONT_WMN_NORMAL)
          grWTC\nCaptionHeight = TextHeight("8g") + 4
          scsDrawingFont(#SCS_FONT_WTC)
          grWTC\nTimeHeight = TextHeight("8") + 8   ; + 8 to allow for an 4 pixel margin top and bottom
          grWTC\nBaseTimeHeight = grWTC\nTimeHeight
          nCanvasWidth = TextWidth(sSampleTime) + 16  ; + 16 to allow for an 8 pixel margin left and right
          grWTC\nBaseTimeWidth = nCanvasWidth
          ; note: WTC_displayMTC() will increase the width of the canvas and window if necessary
          nCanvasHeight = grWTC\nCaptionHeight + grWTC\nTimeHeight
        StopDrawing()
        ResizeGadget(WTC\cvsMTC,#PB_Ignore,#PB_Ignore,nCanvasWidth,nCanvasHeight)
        ResizeWindow(#WTC,#PB_Ignore,#PB_Ignore,nCanvasWidth,nCanvasHeight)
        If StartDrawing(CanvasOutput(WTC\cvsMTC))
            Box(0,0,nCanvasWidth,grWTC\nCaptionHeight,$303030)
            Box(0,grWTC\nCaptionHeight,nCanvasWidth,grWTC\nTimeHeight,#SCS_Black)
            drawResizeHandle(#SCS_Yellow)
          StopDrawing()
        EndIf
        debugMsg(sProcName, "GadgetWidth(WTC\cvsMTC)=" + GadgetWidth(WTC\cvsMTC) + ", GadgetHeight(WTC\cvsMTC)=" + GadgetHeight(WTC\cvsMTC))
      EndIf
    EndIf
  EndIf
  
  If IsWindow(#WTC)
    setFormPosition(#WTC, @grMTCDisplayWindow, -1, #True)
    WTC_Form_Resize()
    If bMakeWindowVisible
      debugMsg(sProcName, "calling setWindowVisible(#WTC, #True)")
      setWindowVisible(#WTC, #True)
    EndIf
  EndIf
  
  With grWTC
    \n16PixelsX = 16
    \n4PixelsY = 4
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WTC_Form_Resize()
  PROCNAMEC()
  Protected nNewWidth, nNewHeight
  Protected fFactorX.f, fFactorY.f, fFontFactor.f
  Protected nNewFontSize
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWTC
    nNewWidth = WindowWidth(#WTC)
    nNewHeight = WindowHeight(#WTC)
    \nTimeHeight = nNewHeight - \nCaptionHeight
    ResizeGadget(WTC\cvsMTC, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
    fFactorX = nNewWidth / \nBaseTimeWidth
    fFactorY = \nTimeHeight / \nBaseTimeHeight
    If fFactorX < fFactorY
      fFontFactor = fFactorX
    Else
      fFontFactor = fFactorY
    EndIf
    setUpWTCFont(fFontFactor)
    \bRedoCaption = #True
    \nCanvasWidth = GadgetWidth(WTC\cvsMTC)
    \nCanvasHeight = GadgetHeight(WTC\cvsMTC)
    \bFastDrawAvailable = #False
    ; debugMsg(sProcName, "calling WTC_displayMTC('" + \sDisplayMTC + "', " + \nDragBarCaptionSubPtr + ", '" + \sPreRollText + "')")
    WTC_displayMTC(\sDisplayMTC, \nDragBarCaptionSubPtr, \sPreRollText)
  EndWith
EndProcedure

Procedure WTC_cvsMTC_Event()
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nMouseX, nMouseY
  
  With grWTC
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        nMouseX = GetGadgetAttribute(WTC\cvsMTC, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WTC\cvsMTC, #PB_Canvas_MouseY)
        If nMouseY < 15
          \nMTCStartLeft = WindowX(#WTC)
          \nMTCStartTop = WindowY(#WTC)
          \nMTCStartX = DesktopMouseX()
          \nMTCStartY = DesktopMouseY()
          \bMTCMoving = #True
          \bMTCResizing = #False
        ElseIf (nMouseY >= (GadgetHeight(WTC\cvsMTC) - 20)) And (nMouseX >= (GadgetWidth(WTC\cvsMTC) - 20))
          \nMTCStartX = DesktopMouseX()
          \nMTCStartY = DesktopMouseY()
          \nMTCStartWidth = GadgetWidth(WTC\cvsMTC)
          \nMTCStartHeight = GadgetHeight(WTC\cvsMTC)
          \bMTCResizing = #True
          \bMTCMoving = #False
          \bRedoCaption = #True
        EndIf
        
      Case #PB_EventType_MouseMove
        If \bMTCMoving
          nDeltaX = \nMTCStartX - DesktopMouseX()
          nDeltaY = \nMTCStartY - DesktopMouseY()
          nNewLeft = \nMTCStartLeft - nDeltaX
          nNewTop = \nMTCStartTop - nDeltaY
          ResizeWindow(#WTC, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
        ElseIf \bMTCResizing
          nDeltaX = \nMTCStartX - DesktopMouseX()
          nDeltaY = \nMTCStartY - DesktopMouseY()
          nNewWidth = \nMTCStartWidth - nDeltaX
          If nNewWidth < 110
            nNewWidth = 110
          EndIf
          nNewHeight = \nMTCStartHeight - nDeltaY
          If nNewHeight < 50
            nNewHeight = 50
          EndIf
          ResizeWindow(#WTC, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
          WTC_Form_Resize()
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bMTCMoving = #False
        \bMTCResizing = #False
        SetActiveWindow(#WMN)
        debugMsg(sProcName, "SetActiveWindow(#WMN), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WTC_displayMTC(sMTCTime.s, pSubPtr, sPreRollText.s, bForceDisplay=#False)
  PROCNAMEC()
  Protected nTextWidth, nLeft, nTop
  Protected sCaption.s, sDisplayMTC.s, sMTCType.s
  Protected nNewWidth
  Static sExternalMTC.s
  Static bStaticLoaded
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure may resize gadgets
  
  If bStaticLoaded = #False
    sExternalMTC = Lang("MIDI", "ExternalMTC")
    bStaticLoaded = #True
  EndIf
  
  ; Added 3Jan2023 11.10.0ab because if sMTCTime is blank then that can calculate and leave an incorrect grWTC\nTextLeft value, which is also used by WTC_fastDrawMTC()
  If Len(sMTCTime) = 0
    ProcedureReturn
  EndIf
  ; End added 3Jan2023 11.10.0ab
  
  With grWTC
    
    sDisplayMTC = sMTCTime
    If (sDisplayMTC <> \sDisplayMTC) Or (sPreRollText <> \sPreRollText) Or (bForceDisplay)
      \sDisplayMTC = sDisplayMTC
      
      If \bCheckWindowExistsAndVisible
        If IsWindow(#WTC) = #False
          debugMsg(sProcName, "calling WTC_Form_Load(#True)")
          WTC_Form_Load(#True)
        ElseIf getWindowVisible(#WTC) = #False
          debugMsg(sProcName, "calling setWindowVisible(#WTC, #True)")
          setWindowVisible(#WTC, #True)
        EndIf
        \bCheckWindowExistsAndVisible = #False
      EndIf
      
      If StartDrawing(CanvasOutput(WTC\cvsMTC))
        ; display time
        scsDrawingFont(#SCS_FONT_WTC)
        nTextWidth = TextWidth(sDisplayMTC)
        If nTextWidth > (\nCanvasWidth - \n16PixelsX)
          nNewWidth = nTextWidth + \n16PixelsX
        Else
          nNewWidth = \nCanvasWidth
          nLeft = (\nCanvasWidth - nTextWidth) >> 1
          Box(0, grWTC\nCaptionHeight, \nCanvasWidth, \nTimeHeight, #SCS_Black)
          drawResizeHandle(#SCS_Yellow)
          nTop = grWTC\nCaptionHeight+\n4PixelsY
          DrawText(nLeft, nTop, sDisplayMTC, #SCS_Yellow, #SCS_Black)
          ; debugMsg(sProcName, "DrawText(" + nLeft + ", " + nTop + ", " + sDisplayMTC + ", #SCS_Yellow, #SCS_Black)")
          \nTextLeft = nLeft
          \nTextTop = nTop
          ; caption (if necessary)
          ; debugMsg(sProcName, "sPreRollText=" + sPreRollText + ", grWTC\sPreRollText=" + \sPreRollText)
          If pSubPtr >= 0
            If (pSubPtr <> \nDragBarCaptionSubPtr) Or (sPreRollText <> \sPreRollText) Or (\bRedoCaption)
              \nDragBarCaptionSubPtr = pSubPtr
              \sPreRollText = sPreRollText
              sCaption = Trim(getSubLabel(pSubPtr) + "  " + sPreRollText)
              scsDrawingFont(#SCS_FONT_WMN_NORMAL)
              nTextWidth = TextWidth(sCaption)
              If nTextWidth < \nCanvasWidth
                nLeft = (\nCanvasWidth - nTextWidth) >> 1
              Else
                nLeft = 0
              EndIf
              Box(0, 0, \nCanvasWidth, grWTC\nCaptionHeight, $303030)
              If aSub(pSubPtr)\nMTCType = #SCS_MTC_TYPE_MTC
                sMTCType = "MTC"
              Else
                sMTCType = "LTC"
              EndIf
              DrawText(4, 0, sMTCType, #SCS_Yellow, $303030)
              DrawText(nLeft, 0, sCaption, #SCS_Yellow, $303030)
            EndIf
            
            If Len(sPreRollText) = 0
              \bFastDrawAvailable = #True
            Else
              \bFastDrawAvailable = #False
            EndIf
            
          ElseIf grMTCControl\bMTCControlActive
            scsDrawingFont(#SCS_FONT_WMN_NORMAL)
            Box(0,0,\nCanvasWidth,grWTC\nCaptionHeight,$303030)
            DrawText(4,0,sExternalMTC,#SCS_Yellow,$303030)
            
          Else
            ; shouldn't get here
            Box(0,0,\nCanvasWidth,grWTC\nCaptionHeight,$303030)
            
          EndIf
          
        EndIf
        StopDrawing()
      EndIf
      
      If nNewWidth > \nCanvasWidth
        debugMsg(sProcName, "sDisplayMTC=" + sDisplayMTC + ", \nCanvasWidth=" + \nCanvasWidth + ", nNewWidth=" + nNewWidth)
        ; debugMsg(sProcName, "calling ResizeGadget(WTC\cvsMTC,#PB_Ignore,#PB_Ignore," + nNewWidth + ",#PB_Ignore)")
        ResizeGadget(WTC\cvsMTC,#PB_Ignore,#PB_Ignore,nNewWidth,#PB_Ignore)
        ; debugMsg(sProcName, "calling ResizeWindow(#WTC,#PB_Ignore,#PB_Ignore," + nNewWidth + ",#PB_Ignore)")
        ResizeWindow(#WTC,#PB_Ignore,#PB_Ignore,nNewWidth,#PB_Ignore)
        \nCanvasWidth = GadgetWidth(WTC\cvsMTC)
        \nCanvasHeight = GadgetHeight(WTC\cvsMTC)
        ; debugMsg(sProcName, "setting \nDragBarCaptionSubPtr=-1")
        \nDragBarCaptionSubPtr = -1   ; forces redraw of caption
      EndIf
      
      ; debugMsg(sProcName, "sDisplayMTC=" + sDisplayMTC + ", nCanvasWidth=" + nCanvasWidth + ", nNewWidth=" + Str(nNewWidth))
      
    EndIf
    
  EndWith
  
EndProcedure

Procedure WTC_fastDrawMTC(sMTCTime.s)
  ; PROCNAMEC()
  
  With grWTC
    \sDisplayMTC = sMTCTime
    If StartDrawing(CanvasOutput(WTC\cvsMTC))
      scsDrawingFont(#SCS_FONT_WTC)
      DrawText(\nTextLeft, \nTextTop, sMTCTime, #SCS_Yellow, #SCS_Black)
      ; debugMsg(sProcName, "DrawText(" + \nTextLeft + ", " + \nTextTop + ", " + sMTCTime + ", #SCS_Yellow, #SCS_Black)")
      StopDrawing()
    EndIf
  EndWith
  
EndProcedure

Procedure WTC_EventHandler()
  PROCNAMEC()
  
  With WTC
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WTC_Form_Unload()
        
      Case #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsMTC
            WTC_cvsMTC_Event()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WTC_hideWindowIfInactive()
  PROCNAMEC()
  Protected bHideWindow
  
  ; debugMsg(sProcName, #SCS_START)
  
  If (grMTCSendControl\bMTCSendControlActive) And (grMTCSendControl\nMTCSubPtr = grMTCSendControlDef\nMTCSubPtr)
    bHideWindow = #True
  ElseIf grMTCControl\bMTCControlActive
    bHideWindow = #True
  EndIf
  
  If bHideWindow
    If IsWindow(#WTC)
      If getWindowVisible(#WTC)
        debugMsg(sProcName, "calling setWindowVisible(#WTC, #False)")
        setWindowVisible(#WTC, #False)
        grWTC\bCheckWindowExistsAndVisible = #True ; force window to be redisplayed if required
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF