; File: fmAGColors.pbi
; AGColors = Audio Graph Colors

EnableExplicit

Procedure WAC_displaySamples()
  PROCNAMEC()
  Protected n
  Protected byPeakL.b, byMinL.b, byPeakR.b, byMinR.b
  Protected X
  Protected nEXFGColorL, nINFGColorL, nEXFGColorR, nINFGColorR
  Protected nINFGColorLPlay, nINFGColorRPlay
  Protected nCursorColor, nCuePanelCursorColor, nCuePanelShadowColor
  Protected fCorrectionFactor.f
  Static bStaticLoaded
  Static nArraySize
  Static nSTColor, nENColor, nCursorShadowColor, nBackColor
  Static nSEBarTop, nSEBarBottom, nSEBarHeight
  Static nCPGraphLeftBaseY, nCPGraphRightBaseY, nCPGraphTop, nCPGraphHeight, nCPGraphBottom, nCPGraphPartHeight, fCPYFactor.f, nCPGraphHalfHeight
  Static nEDGraphLeftBaseY, nEDGraphRightBaseY, nEDGraphTop, nEDGraphHeight, nEDGraphBottom, nEDGraphPartHeight, fEDYFactor.f, nEDGraphHalfHeight
  Static byHighestPeak.b, byLowestMin.b, fNormalizeFactor.f
  
  With grWAC
    If bStaticLoaded = #False
      ; the following grMG2 colors are set in setIndependantDefaults() in StartUp.pbi
      nSTColor = grMG2\nSTColor
      nENColor = grMG2\nENColor
      nBackColor = grMG2\nINBGColor
      nCursorShadowColor = grMG2\nCursorShadowColor
      ; dimensions
      nArraySize = GadgetWidth(WAC\cvsEDSample)
      ; sizes etc for cue panel sample
      nCPGraphTop = 0
      nCPGraphHeight = GadgetHeight(WAC\cvsCPSample) - nCPGraphTop
      nCPGraphBottom = nCPGraphTop + nCPGraphHeight - 1
      nCPGraphLeftBaseY = nCPGraphTop + (nCPGraphHeight >> 2)
      nCPGraphRightBaseY = nCPGraphTop + (nCPGraphHeight * 3 / 4)
      nCPGraphPartHeight = nCPGraphHeight >> 2
      fCPYFactor = nCPGraphPartHeight / 128
      nCPGraphHalfHeight = nCPGraphHeight >> 1
      If (nCPGraphHalfHeight << 1) < nCPGraphHeight
        nCPGraphHalfHeight + 1
      EndIf
      ; sizes etc for editor sample
      nEDGraphTop = 0
      nSEBarHeight = 9
      nEDGraphHeight = GadgetHeight(WAC\cvsEDSample) - nEDGraphTop - nSEBarHeight
      nEDGraphBottom = nEDGraphTop + nEDGraphHeight - 1
      nSEBarTop = nEDGraphTop + nEDGraphHeight
      nSEBarBottom = nSEBarTop + nSEBarHeight - 1
      nEDGraphLeftBaseY = nEDGraphTop + (nEDGraphHeight >> 2)
      nEDGraphRightBaseY = nEDGraphTop + (nEDGraphHeight * 3 / 4)
      nEDGraphPartHeight = nEDGraphHeight >> 2
      fEDYFactor = nEDGraphPartHeight / 128
      nEDGraphHalfHeight = nEDGraphHeight >> 1
;       If (nEDGraphHalfHeight << 1) < nEDGraphHeight
;         nEDGraphHalfHeight + 1
;       EndIf
      ; static loaded
      bStaticLoaded = #True
    EndIf
    
    If \bArraysLoaded = #False
      ReDim \aSlicePeakL(nArraySize)
      ReDim \aSliceMinL(nArraySize)
      ReDim \aSlicePeakR(nArraySize)
      ReDim \aSliceMinR(nArraySize)
      Restore AG_EDSampleData
      For n = 0 To nArraySize
        Read.b \aSlicePeakL(n)
        Read.b \aSliceMinL(n)
        Read.b \aSlicePeakR(n)
        Read.b \aSliceMinR(n)
        If \aSlicePeakL(n) > byHighestPeak
          byHighestPeak = \aSlicePeakL(n)
        EndIf
        If \aSlicePeakR(n) > byHighestPeak
          byHighestPeak = \aSlicePeakR(n)
        EndIf
        If \aSliceMinL(n) < byLowestMin
          byLowestMin = \aSliceMinL(n)
        EndIf
        If \aSliceMinR(n) < byLowestMin
          byLowestMin = \aSliceMinR(n)
        EndIf
      Next n
      fNormalizeFactor = 1
      If byHighestPeak >= (byLowestMin * -1)
        If byHighestPeak <> 0
          fNormalizeFactor = #SCS_GRAPH_MAX_PEAK / byHighestPeak
        EndIf
      Else
        If byLowestMin <> 0
          fNormalizeFactor = #SCS_GRAPH_MAX_PEAK / (byLowestMin * -1)
        EndIf
      EndIf
      fCPYFactor * fNormalizeFactor
      fEDYFactor * fNormalizeFactor
      debugMsg(sProcName, "byHighestPeak=" + byHighestPeak + ", byLowestMin=" + byLowestMin + ", fNormalizeFactor=" + StrF(fNormalizeFactor,4) +
                          ", fCPYFactor=" + StrF(fCPYFactor,4) + ", fEDYFactor=" + StrF(fEDYFactor,4))
      \bArraysLoaded = #True
    EndIf
    
    ; colors
    nINFGColorL = \rColorAudioGraph\nLeftColor
    nINFGColorLPlay = \rColorAudioGraph\nLeftColorPlay
    If \rColorAudioGraph\bRightSameAsLeft
      nINFGColorR = nINFGColorL
      nINFGColorRPlay = nINFGColorLPlay
    Else
      nINFGColorR = \rColorAudioGraph\nRightColor
      nINFGColorRPlay = \rColorAudioGraph\nRightColorPlay
    EndIf
    fCorrectionFactor = \rColorAudioGraph\nDarkenFactor / 100
    nEXFGColorL = changeColorBrightness(nINFGColorL, fCorrectionFactor)
    nEXFGColorR = changeColorBrightness(nINFGColorR, fCorrectionFactor)
    nCursorColor = \rColorAudioGraph\nCursorColor
    nCuePanelCursorColor = \rColorAudioGraph\nCuePanelCursorColor
    nCuePanelShadowColor = \rColorAudioGraph\nCuePanelShadowColor
    
    ; draw cue panel sample
    If StartDrawing(CanvasOutput(WAC\cvsCPSample))
      Box(0, 0, OutputWidth(), OutputHeight(), grMG4\nINBGColor) ; grMG4\nINBGColor is set from grMG2\nINBGColor in setIndependantDefaults() in StartUp.pbi
      X = 0
      For n = \nFirstIncludedSlice To \nLastIncludedSlice
        byPeakL = \aSlicePeakL(n) * fCPYFactor
        byMinL = \aSliceMinL(n) * fCPYFactor
        byPeakR = \aSlicePeakR(n) * fCPYFactor
        byMinR = \aSliceMinR(n) * fCPYFactor
        If (byPeakL <> 0) Or (byMinL <> 0)
          LineXY(X, nCPGraphLeftBaseY - byMinL, X, nCPGraphLeftBaseY - byPeakL + 1, nINFGColorL)
        EndIf
        If (byPeakR <> 0) Or (byMinR <> 0)
          LineXY(X, nCPGraphRightBaseY - byMinR, X, nCPGraphRightBaseY - byPeakR + 1, nINFGColorR)
        EndIf
        X + 1
      Next n
      ; draw cursor ('current position')
      X = \nCursorPos - \nFirstIncludedSlice
      drawPosCursor(X, nCPGraphTop, nCPGraphBottom, nCuePanelCursorColor, nCuePanelShadowColor, #True)
      StopDrawing()
    EndIf
    
    ; draw cue panel playing sample
    If StartDrawing(CanvasOutput(WAC\cvsCPSamplePlay))
      Box(0, 0, OutputWidth(), OutputHeight(), grMG4\nINBGColor) ; grMG4\nINBGColor is set from grMG2\nINBGColor in setIndependantDefaults() in StartUp.pbi
      X = 0
      For n = \nFirstIncludedSlice To \nLastIncludedSlice
        byPeakL = \aSlicePeakL(n) * fCPYFactor
        byMinL = \aSliceMinL(n) * fCPYFactor
        byPeakR = \aSlicePeakR(n) * fCPYFactor
        byMinR = \aSliceMinR(n) * fCPYFactor
        If (byPeakL <> 0) Or (byMinL <> 0)
          LineXY(X, nCPGraphLeftBaseY - byMinL, X, nCPGraphLeftBaseY - byPeakL + 1, nINFGColorLPlay)
        EndIf
        If (byPeakR <> 0) Or (byMinR <> 0)
          LineXY(X, nCPGraphRightBaseY - byMinR, X, nCPGraphRightBaseY - byPeakR + 1, nINFGColorRPlay)
        EndIf
        X + 1
      Next n
      ; draw cursor ('current position')
      X = \nCursorPosPlay - \nFirstIncludedSlice
      drawPosCursor(X, nCPGraphTop, nCPGraphBottom, nCuePanelCursorColor, nCuePanelShadowColor, #True)
      StopDrawing()
    EndIf
  
    ; draw editor sample
    If StartDrawing(CanvasOutput(WAC\cvsEDSample))
      Box(0, 0, OutputWidth(), nEDGraphHeight, nBackColor)
      Box(0, nSEBarTop, OutputWidth(), nSEBarHeight, #SCS_Black)
      X = 0
      For n = 0 To nArraySize
        byPeakL = \aSlicePeakL(n) * fEDYFactor
        byMinL = \aSliceMinL(n) * fEDYFactor
        byPeakR = \aSlicePeakR(n) * fEDYFactor
        byMinR = \aSliceMinR(n) * fEDYFactor
        If (byPeakL <> 0) Or (byMinL <> 0)
          If (n < \nFirstIncludedSlice) Or (n > \nLastIncludedSlice)
            LineXY(X, nEDGraphLeftBaseY - byMinL, X, nEDGraphLeftBaseY - byPeakL + 1, nEXFGColorL)
          Else
            LineXY(X, nEDGraphLeftBaseY - byMinL, X, nEDGraphLeftBaseY - byPeakL + 1, nINFGColorL)
          EndIf
        EndIf
        If (byPeakR <> 0) Or (byMinR <> 0)
          If (n < \nFirstIncludedSlice) Or (n > \nLastIncludedSlice)
            LineXY(X, nEDGraphRightBaseY - byMinR, X, nEDGraphRightBaseY - byPeakR + 1, nEXFGColorR)
          Else
            LineXY(X, nEDGraphRightBaseY - byMinR, X, nEDGraphRightBaseY - byPeakR + 1, nINFGColorR)
          EndIf
        EndIf
        X + 1
      Next n
      ; draw start marker
      X = \nFirstIncludedSlice
      LineXY(X, nEDGraphTop, X, n, nSTColor)
      LineXY(X, nSEBarBottom-9, X+9, nSEBarBottom, nSTColor)   ; diagonal line
      LineXY(X, nSEBarBottom, X+9, nSEBarBottom, nSTColor)     ; base of triangle
      FillArea(X+1, nSEBarBottom-1, nSTColor, nSTColor)
      ; draw end marker
      X = \nLastIncludedSlice
      LineXY(X, nEDGraphTop, X, nSEBarBottom, nENColor)
      LineXY(X, nSEBarBottom-9, X-9, nSEBarBottom, nENColor)   ; diagonal line
      LineXY(X-9, nSEBarBottom, X, nSEBarBottom, nENColor)     ; base of triangle
      FillArea(X-1, nSEBarBottom-1, nENColor, nENColor)
      ; draw cursor ('current position')
      X = \nCursorPosEdit
      drawPosCursor(X, nEDGraphTop, nEDGraphBottom, nCursorColor, nCursorShadowColor, #False)
      ; draw 'time mark'
      Box(X-1, nSEBarTop, 3, 2, #SCS_Yellow)
      StopDrawing()
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_checkAGColorsAltered(*rColorAudioGraph.tyColorAudioGraph)
  PROCNAMEC()
  Protected bAltered
  
  With *rColorAudioGraph
    While #True ; While loop so we can 'break' at any time
      bAltered = #True
      If \nLeftColor <> grWAC\rColorAudioGraph\nLeftColor
        Break
      EndIf
      If \nLeftColorPlay <> grWAC\rColorAudioGraph\nLeftColorPlay
        Break
      EndIf
      If \bRightSameAsLeft <> grWAC\rColorAudioGraph\bRightSameAsLeft
        Break
      EndIf
      If \bRightSameAsLeft = #False
        If \nRightColor <> grWAC\rColorAudioGraph\nRightColor
          Break
        EndIf
        If \nRightColorPlay <> grWAC\rColorAudioGraph\nRightColorPlay
          Break
        EndIf
      EndIf
      If \nDarkenFactor <> grWAC\rColorAudioGraph\nDarkenFactor
        Break
      EndIf
      If \nCursorColor <> grWAC\rColorAudioGraph\nCursorColor
        Break
      EndIf
      ; if we get here then all items are unchanged
      bAltered = #False
      Break
    Wend
  EndWith
  
  ProcedureReturn bAltered
  
EndProcedure

Procedure WAC_setButtons()
  PROCNAMEC()
  Protected bResetEnabled, bUseDfltsEnabled, bUseClassicEnabled
  
  If WAC_checkAGColorsAltered(@grWorkScheme\rColorAudioGraph)
    bResetEnabled = #True
  EndIf
  If WAC_checkAGColorsAltered(@grColHnd\rDefaultScheme\rColorAudioGraph)
    bUseDfltsEnabled = #True
  EndIf
  If WAC_checkAGColorsAltered(@grWAC\rClassicColors)
    bUseClassicEnabled = #True
  EndIf
  
  setEnabled(WAC\btnReset, bResetEnabled)
  setEnabled(WAC\btnUseDflts, bUseDfltsEnabled)
  setEnabled(WAC\btnUseClassic, bUseClassicEnabled)
  
EndProcedure

Procedure WAC_Form_Unload(bCheckForChange=#True)
  PROCNAMEC()
  Protected bAltered, nResponse
  Protected n
  
  If bCheckForChange
    bAltered = WAC_checkAGColorsAltered(@grWorkScheme\rColorAudioGraph)
    If bAltered
      nResponse = scsMessageRequester(GWT(#WAC), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel | #MB_ICONQUESTION)
      Select nResponse
        Case #PB_MessageRequester_Cancel
          ProcedureReturn
        Case #PB_MessageRequester_Yes
          grWorkScheme\rColorAudioGraph = grWAC\rColorAudioGraph
          grColHnd\bAudioGraphColorsChanged = #True
          grColHnd\bSchemeAltered = #True ; indicates to fmColorScheme.pbi that something in the color scheme has been changed
          WCS_setAGColorsButtonText()
      EndSelect
    EndIf
  EndIf
  
  getFormPosition(#WAC, @grAGColorsWindow)
  unsetWindowModal(#WAC)
  scsCloseWindow(#WAC)
  
EndProcedure

Procedure WAC_btnOK_Click()
  PROCNAMEC()
  Protected bAltered
  
  debugMsg(sProcName, #SCS_START)
  
  bAltered = WAC_checkAGColorsAltered(@grWorkScheme\rColorAudioGraph)
  If bAltered
    grWorkScheme\rColorAudioGraph = grWAC\rColorAudioGraph
    grColHnd\bAudioGraphColorsChanged = #True
    grColHnd\bSchemeAltered = #True ; indicates to fmColorScheme.pbi that something in the color scheme has been changed
    WCS_setAGColorsButtonText()
  EndIf
  WAC_Form_Unload(#False)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_btnCancel_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  WAC_Form_Unload()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_btnReset_Click()
  PROCNAMEC()
  
  grWAC\rColorAudioGraph = grWorkScheme\rColorAudioGraph
  WAC_displayColorInfo()
  WAC_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_displayColorInfo()
  PROCNAMEC()
  Protected nColor
  
  debugMsg(sProcName, #SCS_START)
  
  With grWAC\rColorAudioGraph
    nColor = \nLeftColor
    If StartDrawing(CanvasOutput(WAC\cvsLeftColor))
      Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
      Box(1,1,OutputWidth()-2,OutputHeight()-2,nColor)
      StopDrawing()
    EndIf
    SGS(WAC\chkRightSameAsLeft, \bRightSameAsLeft)
    If \bRightSameAsLeft
      nColor = \nLeftColor
    Else
      nColor = \nRightColor
    EndIf
    If StartDrawing(CanvasOutput(WAC\cvsRightColor))
      Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
      Box(1,1,OutputWidth()-2,OutputHeight()-2,nColor)
      StopDrawing()
    EndIf
    nColor = \nLeftColorPlay
    If StartDrawing(CanvasOutput(WAC\cvsLeftColorPlay))
      Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
      Box(1,1,OutputWidth()-2,OutputHeight()-2,nColor)
      StopDrawing()
    EndIf
    If \bRightSameAsLeft
      nColor = \nLeftColorPlay
    Else
      nColor = \nRightColorPlay
    EndIf
    If StartDrawing(CanvasOutput(WAC\cvsRightColorPlay))
      Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
      Box(1,1,OutputWidth()-2,OutputHeight()-2,nColor)
      StopDrawing()
    EndIf
    SGS(WAC\trbDarkenFactor, (\nDarkenFactor * -1))
    nColor = \nCursorColor
    If StartDrawing(CanvasOutput(WAC\cvsCursorColor))
      Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
      Box(1,1,OutputWidth()-2,OutputHeight()-2,nColor)
      StopDrawing()
    EndIf
    
    WAC_displaySamples()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_Form_Show()
  PROCNAMEC()
  Protected nLeft, nWidth
  
  debugMsg(sProcName, #SCS_START)
  
  With WAC
    If IsWindow(#WAC) = #False
      createfmAGColors()
    EndIf
    setFormPosition(#WAC, @grAGColorsWindow)
    ClearGadgetItems(\cboScheme)
    AddGadgetItem(\cboScheme, -1, grWorkScheme\sSchemeDescr)
    SGS(\cboScheme, 0)
  EndWith
  
  grWAC\rClassicColors = grColHnd\rDefaultScheme\rColorAudioGraph ; to set values common to both, such as shadow color and transparency factor
  With grWAC\rClassicColors
    \nLeftColor = RGB(0, 255, 0)
    \nRightColor = RGB(255, 0, 0)
    \bRightSameAsLeft = #False
    \nLeftColorPlay = \nLeftColor
    \nRightColorPlay = \nRightColor
    \nDarkenFactor = -50
    \nCursorColor = #SCS_White
    \nCuePanelCursorColor = RGBA(Red(\nCursorColor), Green(\nCursorColor), Blue(\nCursorColor), \nCursorTransparencyFactor)
  EndWith
  
  With grWAC
    \rColorAudioGraph = grWorkScheme\rColorAudioGraph
    ; special positions for the editor sample graph, which also influence the width of the cue panel sample graph
    \nFirstIncludedSlice = 30
    \nLastIncludedSlice = 330
    \nCursorPos = \nFirstIncludedSlice + 20
    \nCursorPosPlay = \nCursorPos
    \nCursorPosEdit = \nCursorPos
    ; now resize the cue panel sample graph as this only displays the playable ('included') part of the graph
    nWidth = \nLastIncludedSlice - \nFirstIncludedSlice + 1
    nLeft = (WindowWidth(#WAC) - nWidth) >> 1
    ResizeGadget(WAC\cvsCPSample, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(WAC\cvsCPSamplePlay, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
  EndWith

  WAC_displayColorInfo()
  
  WAC_setButtons()
  setWindowModal(#WAC, #True)
  setWindowVisible(#WAC, #True)
  SetActiveWindow(#WAC)
  
EndProcedure

Procedure WAC_cvsColor_Click(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nCurrItemColor, nSelectedColor
  Protected bIgnore
  
  debugMsg(sProcName, #SCS_START)
  
  With grWAC\rColorAudioGraph
    Select nGadgetNo
      Case WAC\cvsLeftColor
        nCurrItemColor = \nLeftColor
      Case WAC\cvsRightColor
        If \bRightSameAsLeft
          bIgnore = #True
        Else
          nCurrItemColor = \nRightColor
        EndIf
      Case WAC\cvsLeftColorPlay
        nCurrItemColor = \nLeftColorPlay
      Case WAC\cvsRightColorPlay
        If \bRightSameAsLeft
          bIgnore = #True
        Else
          nCurrItemColor = \nRightColorPlay
        EndIf
      Case WAC\cvsCursorColor
        nCurrItemColor = \nCursorColor
    EndSelect
    If bIgnore = #False
      nSelectedColor = ColorRequester(nCurrItemColor)
      debugMsg(sProcName, "nCurrItemColor=$" + Hex(nCurrItemColor) + ", nSelectedColor=$" + Hex(nSelectedColor))
      If nSelectedColor = -1
        debugMsg(sProcName, "user cancelled ColorRequester")
      Else
        If nSelectedColor <> nCurrItemColor
          Select nGadgetNo
            Case WAC\cvsLeftColor
              \nLeftColor = nSelectedColor
            Case WAC\cvsRightColor
              \nRightColor = nSelectedColor
            Case WAC\cvsLeftColorPlay
              \nLeftColorPlay = nSelectedColor
            Case WAC\cvsRightColorPlay
              \nRightColorPlay = nSelectedColor
            Case WAC\cvsCursorColor
              \nCursorColor = nSelectedColor
              \nCuePanelCursorColor = RGBA(Red(\nCursorColor), Green(\nCursorColor), Blue(\nCursorColor), \nCursorTransparencyFactor)
          EndSelect
          WAC_displayColorInfo()
        EndIf
      EndIf
    EndIf
  EndWith
  
  If bIgnore = #False
    WAC_setButtons()
    SAG(-1)
  EndIf
  
EndProcedure

Procedure WAC_btnUseDflts_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  grWAC\rColorAudioGraph = grColHnd\rDefaultScheme\rColorAudioGraph
  WAC_displayColorInfo()
  WAC_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_btnUseClassic_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  grWAC\rColorAudioGraph = grWAC\rClassicColors
  WAC_displayColorInfo()
  WAC_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_chkRightSameAsLeft_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grWAC\rColorAudioGraph
    \bRightSameAsLeft = GetGadgetState(WAC\chkRightSameAsLeft)
    WAC_displayColorInfo()
    WAC_setButtons()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WAC_trbDarkenFactor_Change()
  PROCNAMEC()
  
  With grWAC\rColorAudioGraph
    \nDarkenFactor = GGS(WAC\trbDarkenFactor) * -1
    WAC_displayColorInfo()
    WAC_setButtons()
  EndWith
  
EndProcedure

Procedure WAC_EventHandler()
  PROCNAMEC()
  
  With WAC
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        ; WAC_Form_Unload()
        WAC_btnOK_Click()   ; nb asks user if changes are to be saved
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOK)
              WAC_btnOK_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WAC_btnCancel_Click()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            WAC_btnCancel_Click()
            
          Case \btnOK
            WAC_btnOK_Click()
            
          Case \btnReset
            WAC_btnReset_Click()
            
          Case \btnUseClassic
            WAC_btnUseClassic_Click()
            
          Case \btnUseDflts
            WAC_btnUseDflts_Click()
            
          Case \chkRightSameAsLeft
            WAC_chkRightSameAsLeft_Click()
            
          Case \cvsCursorColor, \cvsLeftColor, \cvsRightColor, \cvsLeftColorPlay, \cvsRightColorPlay
            If gnEventType = #PB_EventType_LeftClick
              WAC_cvsColor_Click(gnEventGadgetNo)
            EndIf
            
          Case \cvsCPSample, \cvsEDSample
            ; ignore events
            
          Case \trbDarkenFactor
            WAC_trbDarkenFactor_Change()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

DataSection
  AG_EDSampleData:
  ; built from the debugMsg() calls in loadSlicePeakAndMinArraysFromDatabase() in Graph2.pbi
  ;   debugMsg(sProcName, "Data.b " + byPeakL + ", " + byMinL + ", " + byPeakR + ", " + byMinR + " ; " + n)
  ; the data below is from the Ray Conniff track "Speak Softly Love" in "16 Most Requested Songs"
  Data.b 0, 0, 0, 0 ; 0
  Data.b 0, 0, 0, 0 ; 1
  Data.b 0, 0, 0, 0 ; 2
  Data.b 0, 0, 0, 0 ; 3
  Data.b 7, -5, 8, -6 ; 4
  Data.b 7, -9, 7, -8 ; 5
  Data.b 7, -8, 7, -7 ; 6
  Data.b 7, -8, 9, -11; 7
  Data.b 6, -7, 10, -11 ; 8
  Data.b 7, -7, 12, -11 ; 9
  Data.b 7, -6, 9, -10  ; 10
  Data.b 23, -27, 28, -36 ; 11
  Data.b 25, -25, 28, -37 ; 12
  Data.b 21, -24, 24, -32 ; 13
  Data.b 24, -26, 33, -25 ; 14
  Data.b 21, -18, 34, -36 ; 15
  Data.b 23, -24, 25, -26 ; 16
  Data.b 20, -15, 24, -24 ; 17
  Data.b 17, -19, 25, -33 ; 18
  Data.b 19, -15, 30, -23 ; 19
  Data.b 31, -28, 38, -37 ; 20
  Data.b 27, -27, 37, -46 ; 21
  Data.b 35, -27, 42, -44 ; 22
  Data.b 23, -26, 37, -34 ; 23
  Data.b 22, -28, 36, -32 ; 24
  Data.b 25, -29, 31, -33 ; 25
  Data.b 36, -29, 42, -40 ; 26
  Data.b 24, -22, 30, -29 ; 27
  Data.b 23, -24, 34, -45 ; 28
  Data.b 25, -25, 28, -32 ; 29
  Data.b 22, -26, 30, -36 ; 30
  Data.b 33, -35, 41, -50 ; 31
  Data.b 33, -29, 27, -42 ; 32
  Data.b 23, -25, 32, -29 ; 33
  Data.b 22, -22, 32, -36 ; 34
  Data.b 23, -25, 44, -42 ; 35
  Data.b 21, -21, 27, -30 ; 36
  Data.b 24, -22, 30, -26 ; 37
  Data.b 17, -16, 27, -27 ; 38
  Data.b 18, -18, 21, -28 ; 39
  Data.b 22, -21, 29, -28 ; 40
  Data.b 22, -22, 29, -38 ; 41
  Data.b 16, -19, 25, -26 ; 42
  Data.b 13, -15, 24, -29 ; 43
  Data.b 15, -14, 34, -31 ; 44
  Data.b 17, -17, 31, -31 ; 45
  Data.b 20, -17, 21, -26 ; 46
  Data.b 13, -17, 18, -25 ; 47
  Data.b 11, -13, 22, -19 ; 48
  Data.b 10, -12, 16, -16 ; 49
  Data.b 8, -13, 12, -20  ; 50
  Data.b 19, -21, 28, -30 ; 51
  Data.b 32, -37, 29, -33 ; 52
  Data.b 24, -25, 29, -36 ; 53
  Data.b 30, -30, 33, -34 ; 54
  Data.b 28, -28, 28, -34 ; 55
  Data.b 33, -36, 32, -41 ; 56
  Data.b 25, -23, 32, -31 ; 57
  Data.b 25, -27, 31, -29 ; 58
  Data.b 37, -30, 43, -38 ; 59
  Data.b 29, -32, 27, -36 ; 60
  Data.b 32, -32, 36, -38 ; 61
  Data.b 23, -28, 20, -25 ; 62
  Data.b 26, -27, 26, -31 ; 63
  Data.b 24, -25, 33, -28 ; 64
  Data.b 25, -25, 27, -28 ; 65
  Data.b 23, -28, 34, -41 ; 66
  Data.b 25, -27, 30, -31 ; 67
  Data.b 25, -25, 30, -28 ; 68
  Data.b 23, -20, 26, -22 ; 69
  Data.b 27, -26, 35, -27 ; 70
  Data.b 39, -33, 44, -42 ; 71
  Data.b 26, -20, 25, -25 ; 72
  Data.b 18, -22, 24, -26 ; 73
  Data.b 21, -27, 28, -30 ; 74
  Data.b 16, -16, 27, -33 ; 75
  Data.b 15, -24, 38, -26 ; 76
  Data.b 18, -17, 26, -25 ; 77
  Data.b 15, -13, 24, -24 ; 78
  Data.b 16, -17, 21, -35 ; 79
  Data.b 20, -16, 23, -30 ; 80
  Data.b 28, -25, 33, -29 ; 81
  Data.b 23, -24, 23, -22 ; 82
  Data.b 20, -22, 19, -25 ; 83
  Data.b 19, -19, 28, -31 ; 84
  Data.b 13, -16, 19, -23 ; 85
  Data.b 19, -22, 25, -37 ; 86
  Data.b 23, -26, 22, -27 ; 87
  Data.b 23, -23, 21, -21 ; 88
  Data.b 21, -21, 18, -18 ; 89
  Data.b 21, -19, 24, -20 ; 90
  Data.b 28, -27, 33, -29 ; 91
  Data.b 15, -16, 21, -26 ; 92
  Data.b 13, -18, 24, -22 ; 93
  Data.b 14, -19, 18, -24 ; 94
  Data.b 18, -20, 21, -19 ; 95
  Data.b 17, -18, 19, -21 ; 96
  Data.b 11, -13, 17, -21 ; 97
  Data.b 11, -12, 14, -17 ; 98
  Data.b 15, -20, 24, -23 ; 99
  Data.b 13, -21, 13, -25 ; 100
  Data.b 30, -26, 34, -24 ; 101
  Data.b 14, -15, 17, -19 ; 102
  Data.b 16, -12, 18, -18 ; 103
  Data.b 37, -36, 46, -37 ; 104
  Data.b 26, -30, 32, -31 ; 105
  Data.b 40, -45, 37, -48 ; 106
  Data.b 40, -51, 44, -51 ; 107
  Data.b 30, -32, 37, -36 ; 108
  Data.b 44, -41, 47, -55 ; 109
  Data.b 44, -45, 48, -45 ; 110
  Data.b 39, -38, 49, -50 ; 111
  Data.b 36, -46, 41, -43 ; 112
  Data.b 25, -33, 32, -31 ; 113
  Data.b 34, -41, 42, -46 ; 114
  Data.b 35, -37, 38, -45 ; 115
  Data.b 40, -52, 54, -46 ; 116
  Data.b 34, -34, 34, -41 ; 117
  Data.b 24, -24, 22, -28 ; 118
  Data.b 39, -34, 44, -39 ; 119
  Data.b 40, -42, 39, -36 ; 120
  Data.b 46, -42, 58, -48 ; 121
  Data.b 32, -39, 40, -43 ; 122
  Data.b 24, -31, 35, -38 ; 123
  Data.b 23, -23, 32, -33 ; 124
  Data.b 29, -24, 28, -25 ; 125
  Data.b 30, -36, 44, -45 ; 126
  Data.b 23, -22, 32, -34 ; 127
  Data.b 28, -29, 32, -35 ; 128
  Data.b 30, -29, 32, -36 ; 129
  Data.b 31, -38, 39, -38 ; 130
  Data.b 39, -36, 40, -44 ; 131
  Data.b 32, -38, 38, -42 ; 132
  Data.b 30, -32, 30, -41 ; 133
  Data.b 26, -25, 30, -36 ; 134
  Data.b 25, -28, 34, -33 ; 135
  Data.b 26, -28, 29, -27 ; 136
  Data.b 23, -26, 24, -24 ; 137
  Data.b 19, -16, 22, -24 ; 138
  Data.b 22, -24, 30, -27 ; 139
  Data.b 32, -27, 42, -29 ; 140
  Data.b 24, -26, 29, -36 ; 141
  Data.b 17, -17, 21, -25 ; 142
  Data.b 17, -22, 26, -29 ; 143
  Data.b 38, -41, 39, -52 ; 144
  Data.b 42, -46, 41, -53 ; 145
  Data.b 38, -50, 49, -51 ; 146
  Data.b 33, -38, 39, -44 ; 147
  Data.b 31, -37, 34, -42 ; 148
  Data.b 40, -38, 49, -51 ; 149
  Data.b 35, -35, 57, -44 ; 150
  Data.b 31, -36, 57, -52 ; 151
  Data.b 27, -33, 45, -43 ; 152
  Data.b 17, -19, 25, -35 ; 153
  Data.b 33, -25, 36, -45 ; 154
  Data.b 34, -32, 39, -49 ; 155
  Data.b 27, -28, 29, -32 ; 156
  Data.b 24, -29, 29, -39 ; 157
  Data.b 28, -35, 38, -35 ; 158
  Data.b 35, -40, 44, -50 ; 159
  Data.b 37, -40, 38, -50 ; 160
  Data.b 27, -28, 31, -37 ; 161
  Data.b 20, -21, 29, -23 ; 162
  Data.b 29, -30, 27, -36 ; 163
  Data.b 28, -33, 45, -44 ; 164
  Data.b 35, -37, 36, -51 ; 165
  Data.b 30, -30, 31, -34 ; 166
  Data.b 27, -24, 24, -29 ; 167
  Data.b 34, -27, 34, -31 ; 168
  Data.b 26, -37, 38, -44 ; 169
  Data.b 30, -37, 37, -43 ; 170
  Data.b 35, -40, 33, -36 ; 171
  Data.b 30, -36, 40, -38 ; 172
  Data.b 28, -34, 33, -38 ; 173
  Data.b 30, -37, 34, -33 ; 174
  Data.b 30, -45, 32, -31 ; 175
  Data.b 30, -33, 31, -37 ; 176
  Data.b 19, -26, 25, -31 ; 177
  Data.b 25, -24, 25, -26 ; 178
  Data.b 19, -26, 20, -20 ; 179
  Data.b 25, -27, 33, -33 ; 180
  Data.b 18, -24, 22, -25 ; 181
  Data.b 15, -16, 26, -18 ; 182
  Data.b 26, -20, 29, -32 ; 183
  Data.b 28, -38, 31, -43 ; 184
  Data.b 36, -44, 40, -43 ; 185
  Data.b 30, -30, 35, -38 ; 186
  Data.b 34, -46, 43, -50 ; 187
  Data.b 45, -47, 50, -46 ; 188
  Data.b 29, -32, 34, -38 ; 189
  Data.b 36, -40, 49, -55 ; 190
  Data.b 31, -48, 40, -53 ; 191
  Data.b 34, -36, 32, -35 ; 192
  Data.b 36, -40, 34, -42 ; 193
  Data.b 33, -36, 38, -44 ; 194
  Data.b 34, -43, 41, -43 ; 195
  Data.b 32, -40, 39, -44 ; 196
  Data.b 38, -31, 41, -39 ; 197
  Data.b 32, -31, 38, -32 ; 198
  Data.b 29, -34, 31, -34 ; 199
  Data.b 30, -33, 41, -41 ; 200
  Data.b 20, -25, 26, -30 ; 201
  Data.b 23, -26, 21, -24 ; 202
  Data.b 32, -36, 35, -41 ; 203
  Data.b 30, -28, 29, -33 ; 204
  Data.b 33, -41, 31, -49 ; 205
  Data.b 32, -46, 46, -45 ; 206
  Data.b 35, -37, 41, -54 ; 207
  Data.b 37, -34, 40, -38 ; 208
  Data.b 27, -31, 31, -42 ; 209
  Data.b 37, -43, 39, -39 ; 210
  Data.b 32, -29, 39, -34 ; 211
  Data.b 35, -30, 32, -35 ; 212
  Data.b 28, -38, 30, -36 ; 213
  Data.b 29, -34, 32, -32 ; 214
  Data.b 35, -37, 35, -36 ; 215
  Data.b 33, -35, 38, -40 ; 216
  Data.b 29, -36, 29, -45 ; 217
  Data.b 34, -33, 36, -35 ; 218
  Data.b 26, -24, 30, -27 ; 219
  Data.b 25, -31, 41, -34 ; 220
  Data.b 18, -22, 19, -27 ; 221
  Data.b 14, -19, 17, -25 ; 222
  Data.b 28, -23, 36, -35 ; 223
  Data.b 25, -30, 30, -35 ; 224
  Data.b 28, -34, 34, -37 ; 225
  Data.b 26, -30, 29, -32 ; 226
  Data.b 21, -22, 35, -27 ; 227
  Data.b 26, -38, 31, -36 ; 228
  Data.b 31, -35, 49, -43 ; 229
  Data.b 40, -46, 36, -56 ; 230
  Data.b 34, -33, 29, -32 ; 231
  Data.b 23, -33, 28, -29 ; 232
  Data.b 28, -38, 30, -33 ; 233
  Data.b 32, -45, 33, -43 ; 234
  Data.b 28, -37, 43, -40 ; 235
  Data.b 31, -26, 37, -34 ; 236
  Data.b 29, -22, 23, -33 ; 237
  Data.b 33, -36, 35, -38 ; 238
  Data.b 29, -28, 36, -36 ; 239
  Data.b 30, -36, 33, -36 ; 240
  Data.b 26, -23, 31, -29 ; 241
  Data.b 28, -34, 29, -32 ; 242
  Data.b 30, -34, 32, -42 ; 243
  Data.b 45, -47, 49, -45 ; 244
  Data.b 29, -41, 36, -39 ; 245
  Data.b 21, -26, 22, -28 ; 246
  Data.b 22, -22, 25, -24 ; 247
  Data.b 20, -26, 22, -24 ; 248
  Data.b 34, -30, 35, -31 ; 249
  Data.b 19, -27, 32, -38 ; 250
  Data.b 17, -22, 26, -32 ; 251
  Data.b 25, -25, 24, -28 ; 252
  Data.b 21, -24, 30, -24 ; 253
  Data.b 31, -26, 37, -30 ; 254
  Data.b 21, -25, 21, -25 ; 255
  Data.b 23, -23, 25, -22 ; 256
  Data.b 24, -32, 28, -31 ; 257
  Data.b 22, -20, 27, -30 ; 258
  Data.b 34, -35, 44, -40 ; 259
  Data.b 22, -19, 30, -26 ; 260
  Data.b 15, -17, 22, -17 ; 261
  Data.b 26, -23, 33, -39 ; 262
  Data.b 40, -43, 47, -58 ; 263
  Data.b 30, -32, 27, -26 ; 264
  Data.b 34, -38, 38, -63 ; 265
  Data.b 33, -31, 33, -36 ; 266
  Data.b 22, -24, 33, -29 ; 267
  Data.b 31, -38, 35, -42 ; 268
  Data.b 17, -25, 21, -31 ; 269
  Data.b 30, -32, 43, -49 ; 270
  Data.b 35, -37, 40, -44 ; 271
  Data.b 34, -39, 39, -43 ; 272
  Data.b 32, -41, 35, -44 ; 273
  Data.b 32, -36, 33, -42 ; 274
  Data.b 41, -35, 42, -42 ; 275
  Data.b 34, -37, 34, -39 ; 276
  Data.b 31, -33, 40, -41 ; 277
  Data.b 31, -37, 40, -49 ; 278
  Data.b 23, -30, 32, -36 ; 279
  Data.b 39, -52, 53, -66 ; 280
  Data.b 47, -53, 51, -57 ; 281
  Data.b 38, -38, 49, -52 ; 282
  Data.b 31, -44, 36, -51 ; 283
  Data.b 27, -30, 31, -34 ; 284
  Data.b 38, -46, 40, -52 ; 285
  Data.b 39, -41, 46, -50 ; 286
  Data.b 36, -33, 39, -42 ; 287
  Data.b 28, -33, 32, -39 ; 288
  Data.b 21, -21, 25, -26 ; 289
  Data.b 32, -35, 39, -38 ; 290
  Data.b 22, -32, 32, -40 ; 291
  Data.b 23, -42, 26, -42 ; 292
  Data.b 25, -28, 30, -41 ; 293
  Data.b 23, -28, 30, -30 ; 294
  Data.b 38, -37, 29, -44 ; 295
  Data.b 24, -25, 24, -27 ; 296
  Data.b 12, -15, 16, -19 ; 297
  Data.b 19, -27, 22, -31 ; 298
  Data.b 13, -16, 18, -21 ; 299
  Data.b 33, -27, 37, -35 ; 300
  Data.b 14, -16, 16, -23 ; 301
  Data.b 14, -14, 17, -22 ; 302
  Data.b 32, -25, 32, -32 ; 303
  Data.b 25, -30, 33, -37 ; 304
  Data.b 35, -43, 43, -60 ; 305
  Data.b 36, -30, 35, -36 ; 306
  Data.b 23, -22, 38, -37 ; 307
  Data.b 28, -30, 45, -36 ; 308
  Data.b 23, -28, 32, -40 ; 309
  Data.b 33, -56, 40, -58 ; 310
  Data.b 27, -27, 41, -34 ; 311
  Data.b 25, -28, 33, -31 ; 312
  Data.b 29, -28, 32, -37 ; 313
  Data.b 27, -31, 34, -41 ; 314
  Data.b 33, -38, 41, -44 ; 315
  Data.b 23, -32, 30, -36 ; 316
  Data.b 20, -27, 23, -33 ; 317
  Data.b 28, -26, 31, -33 ; 318
  Data.b 29, -39, 27, -37 ; 319
  Data.b 30, -40, 50, -48 ; 320
  Data.b 31, -36, 35, -37 ; 321
  Data.b 24, -26, 28, -32 ; 322
  Data.b 23, -24, 24, -31 ; 323
  Data.b 25, -34, 31, -34 ; 324
  Data.b 53, -44, 40, -42 ; 325
  Data.b 29, -35, 33, -37 ; 326
  Data.b 26, -26, 40, -39 ; 327
  Data.b 40, -40, 40, -40 ; 328
  Data.b 30, -38, 36, -40 ; 329
  Data.b 36, -43, 43, -33 ; 330
  Data.b 29, -32, 33, -41 ; 331
  Data.b 30, -35, 34, -42 ; 332
  Data.b 30, -30, 35, -41 ; 333
  Data.b 30, -35, 35, -47 ; 334
  Data.b 30, -37, 37, -43 ; 335
  Data.b 28, -34, 38, -44 ; 336
  Data.b 33, -29, 30, -31 ; 337
  Data.b 23, -26, 30, -24 ; 338
  Data.b 25, -30, 31, -34 ; 339
  Data.b 30, -44, 34, -51 ; 340
  Data.b 28, -31, 19, -31 ; 341
  Data.b 17, -19, 18, -23 ; 342
  Data.b 20, -20, 18, -20 ; 343
  Data.b 44, -49, 53, -46 ; 344
  Data.b 34, -30, 29, -34 ; 345
  Data.b 40, -47, 51, -52 ; 346
  Data.b 49, -46, 39, -40 ; 347
  Data.b 27, -29, 26, -36 ; 348
  Data.b 44, -42, 65, -53 ; 349
  Data.b 44, -40, 54, -64 ; 350
  Data.b 46, -49, 54, -54 ; 351
  Data.b 35, -34, 37, -41 ; 352
  Data.b 22, -26, 22, -29 ; 353
  Data.b 29, -33, 39, -44 ; 354
  Data.b 36, -48, 39, -51 ; 355
  Data.b 34, -37, 39, -43 ; 356
  Data.b 30, -35, 36, -35 ; 357
  Data.b 25, -25, 33, -29 ; 358
  Data.b 34, -48, 43, -48 ; 359
EndDataSection

; EOF
