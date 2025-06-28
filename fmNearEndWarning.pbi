; File: fmNearEndWarning.pbi

EnableExplicit

Procedure WNE_Form_Unload()
  getFormPosition(#WNE, @grNearEndWarningWindow, #True)
  scsCloseWindow(#WNE)
EndProcedure

Procedure WNE_Form_Load(bMakeWindowVisible)
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected sSampleTime.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WNE) = #False
    setUpWNEFont(1.0)
    createfmNearEndWarning()
    If IsWindow(#WNE)
      sSampleTime = "9999"  ; only used for establishing the base width
      If StartDrawing(CanvasOutput(WNE\cvsNearEnd))
        scsDrawingFont(#SCS_FONT_WMN_NORMAL)
        grWNE\nCaptionHeight = TextHeight("8g") + 4
        scsDrawingFont(#SCS_FONT_WNE)
        
        grWNE\nTimeHeight = TextHeight("8") + 8   ; + 8 to allow for an 4 pixel margin top and bottom
        grWNE\nBaseTimeHeight = grWNE\nTimeHeight
        nCanvasWidth = TextWidth(sSampleTime) + 16  ; + 16 to allow for an 8 pixel margin left and right
        grWNE\nBaseTimeWidth = nCanvasWidth
        ; note: WNE_displayNearEndTime() will increase the width of the canvas and window if necessary
        nCanvasHeight = grWNE\nCaptionHeight + grWNE\nTimeHeight
        StopDrawing()
        ResizeGadget(WNE\cvsNearEnd,#PB_Ignore,#PB_Ignore,nCanvasWidth,nCanvasHeight)
        ResizeWindow(#WNE,#PB_Ignore,#PB_Ignore,nCanvasWidth,nCanvasHeight)
        If StartDrawing(CanvasOutput(WNE\cvsNearEnd))
          Box(0,0,nCanvasWidth,grWNE\nCaptionHeight,$303030)
          Box(0,grWNE\nCaptionHeight,nCanvasWidth,grWNE\nTimeHeight,#SCS_Black)
          drawResizeHandle(#SCS_Yellow)
          StopDrawing()
        EndIf
      EndIf
    EndIf
    
  EndIf
  
  If IsWindow(#WNE)
    setFormPosition(#WNE, @grNearEndWarningWindow, -1, #True)
    WNE_Form_Resize()
    If bMakeWindowVisible
      setWindowVisible(#WNE, #True)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WNE_Form_Resize()
  ; PROCNAMEC()
  Protected nNewWidth, nNewHeight
  Protected fFactorX.f, fFactorY.f, fFontFactor.f
  Protected nNewFontSize
  
  With grWNE
    nNewWidth = WindowWidth(#WNE)
    nNewHeight = WindowHeight(#WNE)
    \nTimeHeight = nNewHeight - \nCaptionHeight
    ResizeGadget(WNE\cvsNearEnd, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
    fFactorX = nNewWidth / \nBaseTimeWidth
    fFactorY = \nTimeHeight / \nBaseTimeHeight
    If fFactorX < fFactorY
      fFontFactor = fFactorX
    Else
      fFontFactor = fFactorY
    EndIf
    setUpWNEFont(fFontFactor)
    \bRedoCaption = #True
    WNE_displayNearEndTime(\nDisplayTime, \nDragBarCaptionCuePtr, \nDragBarCaptionSubPtr, \nCuePosTimeOffset, \bFileVisualWarningTimeAvailable) ; Changed 30Sep2022 11.9.6.
  EndWith
EndProcedure

Procedure WNE_cvsNearEnd_Event()
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nMouseX, nMouseY
  
  With grWNE
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        nMouseX = GetGadgetAttribute(WNE\cvsNearEnd, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WNE\cvsNearEnd, #PB_Canvas_MouseY)
        If nMouseY < 15
          \nNearEndStartLeft = WindowX(#WNE)
          \nNearEndStartTop = WindowY(#WNE)
          \nNearEndStartX = DesktopMouseX()
          \nNearEndStartY = DesktopMouseY()
          \bNearEndMoving = #True
          \bNearEndResizing = #False
        ElseIf (nMouseY >= GadgetHeight(WNE\cvsNearEnd) - 20) And (nMouseX >= GadgetWidth(WNE\cvsNearEnd) - 20)
          \nNearEndStartX = DesktopMouseX()
          \nNearEndStartY = DesktopMouseY()
          \nNearEndStartWidth = GadgetWidth(WNE\cvsNearEnd)
          \nNearEndStartHeight = GadgetHeight(WNE\cvsNearEnd)
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
          ResizeWindow(#WNE, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
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
          ResizeWindow(#WNE, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
          WNE_Form_Resize()
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bNearEndMoving = #False
        \bNearEndResizing = #False
        SAW(#WMN)
        debugMsg(sProcName, "SetActiveWindow(#WMN), GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WNE_displayNearEndTime(nDisplayTime, pCuePtr, pSubPtr, nCuePosTimeOffset, bFileVisualWarningTimeAvailable) ; Added bFileVisualWarningTimeAvailable 30Sep2022 11.9.6
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight, nTextWidth, nLeft
  Protected sCaption.s, sDisplayTime.s
  Protected nNewWidth
  Static nTimeTop, sCuePos.s, sFilePos.s
  Static bStaticLoaded
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure may resize gadgets
  
  If bStaticLoaded = #False
    nTimeTop = grWNE\nCaptionHeight + 4
    sCuePos = Lang("WEP", "CuePos")
    sFilePos = Lang("WEP", "FilePos")
    bStaticLoaded = #True
  EndIf
  
  With grWNE
    
    Select grProd\nVisualWarningFormat
      Case #SCS_VWF_SECS
        ; seconds only (eg 9)
        Select grProd\nVisualWarningTime
          Case #SCS_VWT_CUEPOS, #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET, #SCS_VWT_FILEPOS
            ; cue position, cue position plus optional time offset, or file position
            sDisplayTime = FormatUsingL(Round(nDisplayTime / 1000, #PB_Round_Down), "####0")
          Default
            ; count down
            sDisplayTime = FormatUsingL(Round(nDisplayTime / 1000, #PB_Round_Up), "####0")
        EndSelect
      Case #SCS_VWF_TIME
        ; full time, eg minutes:seconds.hundredths (eg 8.75)
        sDisplayTime = timeToString(nDisplayTime)
      Case #SCS_VWF_HHMMSS
        ; hours:minutes:seconds
        sDisplayTime = timeToStringHHMMSS(nDisplayTime)
    EndSelect
    
    If (sDisplayTime <> \sDisplayTime) Or (nDisplayTime < 1000) ; force display if nDisplayTime < 1 second
      \sDisplayTime = sDisplayTime
      \nDisplayTime = nDisplayTime
      \bFileVisualWarningTimeAvailable = bFileVisualWarningTimeAvailable ; Added 30Sep2022 11.9.6
      
      If \bCheckWindowExistsAndVisible
        debugMsg(sProcName, "\bCheckWindowExistsAndVisible=" + strB(\bCheckWindowExistsAndVisible))
        If IsWindow(#WNE) = #False
          debugMsg(sProcName, "calling WNE_Form_Load(#True)")
          WNE_Form_Load(#True)
        ElseIf getWindowVisible(#WNE) = #False
          debugMsg(sProcName, "calling setWindowVisible(#WNE, #True)")
          setWindowVisible(#WNE, #True)
        EndIf
        \bCheckWindowExistsAndVisible = #False
        debugMsg(sProcName, "\bCheckWindowExistsAndVisible=" + strB(\bCheckWindowExistsAndVisible))
      EndIf
      
      nCanvasWidth = GadgetWidth(WNE\cvsNearEnd)
      nCanvasHeight = GadgetHeight(WNE\cvsNearEnd)
      If StartDrawing(CanvasOutput(WNE\cvsNearEnd))
        ; display time
        scsDrawingFont(#SCS_FONT_WNE)
        nTextWidth = TextWidth(sDisplayTime)
        If nTextWidth > (nCanvasWidth - 16)
          nNewWidth = nTextWidth + 16
          ResizeGadget(WNE\cvsNearEnd, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
          ResizeWindow(#WNE, #PB_Ignore, #PB_Ignore, nNewWidth, #PB_Ignore)
          nCanvasWidth = GadgetWidth(WNE\cvsNearEnd)
          \bRedoCaption = #True
        EndIf
        nLeft = (nCanvasWidth - nTextWidth) >> 1
        Box(0, grWNE\nCaptionHeight, nCanvasWidth, grWNE\nTimeHeight, #SCS_Black)
        drawResizeHandle(#SCS_Yellow)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(nLeft, nTimeTop, sDisplayTime, #SCS_Yellow, #SCS_Black)
        ; caption (if necessary)
        If (pCuePtr <> \nDragBarCaptionCuePtr) Or (pSubPtr <> \nDragBarCaptionSubPtr) Or (\bRedoCaption)
          \nDragBarCaptionCuePtr = pCuePtr
          \nDragBarCaptionSubPtr = pSubPtr
          If pSubPtr >= 0
            sCaption = getSubLabel(pSubPtr)
          Else
            sCaption = getCueLabel(pCuePtr)
          EndIf
          If grProd\nVisualWarningTime = #SCS_VWT_CUEPOS
            sCaption + " " + sCuePos
          ElseIf grProd\nVisualWarningTime = #SCS_VWT_FILEPOS
;             ; filepos only supported for audio file cues
;             If aSub(pSubPtr)\bSubTypeF And aCue(pCuePtr)\bSubTypeAorP = #False
;               sCaption + " " + sFilePos
;             Else
;               sCaption + " " + sCuePos
;             EndIf
            ; Changed the above 30Sep2022 11.9.6
            If aSub(pSubPtr)\bSubTypeAorF And bFileVisualWarningTimeAvailable
              sCaption + " " + sFilePos
            Else
              sCaption + " " + sCuePos
            EndIf
            ; End changed the above 30Sep2022 11.9.6
          ElseIf grProd\nVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
            sCaption + " " + sCuePos
            ; cuepos+timeoffset only supported for audio file cues
            If aSub(pSubPtr)\bSubTypeF And aCue(pCuePtr)\bSubTypeAorP = #False
              If nCuePosTimeOffset > 0
                sCaption + " + " + timeToStringT(nCuePosTimeOffset)
              EndIf
            EndIf
          EndIf
          ; debugMsg(sProcName, "sCaption=" + sCaption)
          scsDrawingFont(#SCS_FONT_WMN_NORMAL)
          nTextWidth = TextWidth(sCaption)
          If nTextWidth < nCanvasWidth
            nLeft = (nCanvasWidth - nTextWidth) >> 1
          Else
            nLeft = 0
          EndIf
          Box(0, 0, nCanvasWidth, grWNE\nCaptionHeight, $303030)
          DrawText(nLeft, 0, sCaption, #SCS_Yellow, $303030)
        EndIf
        StopDrawing()
      EndIf
      
      ; debugMsg(sProcName, "nDisplayTime=" + ttszt(nDisplayTime) + ", sDisplayTime=" + sDisplayTime)
      ; debugMsg(sProcName, "sDisplayTime=" + sDisplayTime + ", nCanvasWidth=" + nCanvasWidth + ", nNewWidth=" + nNewWidth)
      
    EndIf
    
    \nCuePosTimeOffset = nCuePosTimeOffset
    
  EndWith
  
EndProcedure

Procedure WNE_EventHandler()
  PROCNAMEC()
  
  With WNE
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WNE_Form_Unload()
        
      Case #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsNearEnd
            WNE_cvsNearEnd_Event()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF