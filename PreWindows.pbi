; File PreWindows.pbi

; self-contained procedures that MAY have tracing and primarily are required by Windows.pbi

EnableExplicit

Procedure scsErrorHandler(nErrorCode, pProcName.s, nParam1=0, nParam2=0, sInfo.s="")
  ; no language translation - we want this in English!
  PROCNAMEC()
  Protected sErrorMessage.s
  
  gbForceTracing = #True
  
  debugMsg(sProcName, #SCS_START + ", nErrorCode=" + nErrorCode)
  
  sErrorMessage = "A program error was detected:" + Chr(10) 
  sErrorMessage + Chr(10)
  sErrorMessage + "Error Message:  "
  Select nErrorCode
    Case #SCS_ERROR_GADGET_NO_NOT_SET
      sErrorMessage + "Gadget No. not set"
    Case #SCS_ERROR_GADGET_NO_INVALID
      sErrorMessage + "Gadget No. invalid (" + Str(nParam1) + ")"
    Case #SCS_ERROR_GADGET_NO_OUT_OF_RANGE
      sErrorMessage + "Gadget No. out of range (" + Str(nParam1) + ")"
    Case #SCS_ERROR_FONT_NOT_SET
      sErrorMessage + "Font No. not set"
    Case #SCS_ERROR_FONT_INVALID
      sErrorMessage + "Font No. invalid (" + Str(nParam1) + ")"
    Case #SCS_ERROR_SUBSCRIPT_OUT_OF_RANGE
      sErrorMessage + "Subscript out of range (value=" + Str(nParam1) + ", max=" + Str(nParam2) + "), " + sInfo
    Case #SCS_ERROR_ARRAY_SIZE_INVALID
      sErrorMessage + "Array size invalid (required=" + Str(nParam1) + ", actual=" + Str(nParam2) + "), " + sInfo
    Case #SCS_ERROR_POINTER_OUT_OF_RANGE
      sErrorMessage + "Pointer out of range (value=" + Str(nParam1) + ", max=" + Str(nParam2) + "), " + sInfo
    Default
      sErrorMessage + "(unhandled error code)"
  EndSelect
  sErrorMessage + Chr(10)
  sErrorMessage + "Error Code: " + nErrorCode + Chr(10)  
  sErrorMessage + "Procedure: " + pProcName + Chr(10)
  sErrorMessage + "SCS version: " + #SCS_VERSION + Chr(10)
  
  debugMsg(sProcName, ReplaceString(sErrorMessage, Chr(13), #CRLF$))
  If IsWindow(#WSP)
    HideWindow(#WSP, #True)   ; don't use setWindowVisible in the error handler
  EndIf
  scsMessageRequester(#SCS_TITLE, sErrorMessage)
  closeLogFile()
  End
  
EndProcedure

Procedure killRecoveryFile()
  PROCNAMEC()
  Protected nResult, sTmpFile.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  gqLastRecoveryTime = ElapsedMilliseconds()
  nResult = DeleteFile(gsRecoveryFile)
  ; debugMsg(sProcName, "DeleteFile (" + gsRecoveryFile + ") returned " + nResult)
  
  sTmpFile = ignoreExtension(gsRecoveryFile) + ".$$$"
  nResult = DeleteFile(sTmpFile)
  ; debugMsg(sProcName, "DeleteFile (" + sTmpFile + ") returned " + nResult)
  
EndProcedure

Procedure getGadgetArrayIndex(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nArrayIndex
  Else
    ProcedureReturn -1
  EndIf
EndProcedure

Procedure getGType(sProcName.s, nGadgetNo)
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nGType
EndProcedure

Procedure.s getGadgetNameProc(sProcName.s, nGadgetNo, bIncludeWindow=#True)
  Protected nGadgetPropsIndex
  Protected sGadgetName.s
  
  If (nGadgetNo > 0) And (nGadgetNo <= gnMaxGadgetNo)
    nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    If nGadgetPropsIndex >= 0 ; Test added 30Sep2022 11.9.6
      If bIncludeWindow
        sGadgetName = RemoveString(decodeWindow(gaGadgetProps(nGadgetPropsIndex)\nGWindowNo), "#") + "\"
      EndIf
      sGadgetName + gaGadgetProps(nGadgetPropsIndex)\sName
    EndIf
  EndIf
  ProcedureReturn sGadgetName
EndProcedure

Procedure getGadgetWindowNo(sProcName.s, nGadgetNo)
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nGWindowNo
EndProcedure

Procedure getGadgetReqdWidth(sProcName.s, nGadgetNo)
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nReqdWidth
EndProcedure

Procedure scsToolTip(nGadgetNo, sToolTip.s)
  ; see also setToolTipControls()
  If gbShowToolTips
    If gnOperMode <> #SCS_OPERMODE_PERFORMANCE  ; test added 18Nov2016 11.5.2.4 following problem reported by Mike Pope (tooltip displaying on video screen)
      If (sToolTip) And (sToolTip <> "*")
        GadgetToolTip(nGadgetNo, sToolTip)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure drawCheckBoxGadget2(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex, nImageNo, nTop
  
  ; debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    With gaGadgetProps(nGadgetPropsIndex)
      If StartDrawing(CanvasOutput(nGadgetNo))
        Box(0, 0, GadgetWidth(nGadgetNo), GadgetHeight(nGadgetNo), \nBackColor)
        If \bEnabled
          Select \nState
            Case #PB_Checkbox_Checked
              nImageNo = hMiCheckBoxOnEn
            Case #PB_Checkbox_Inbetween
              nImageNo = hMiCheckBoxBothEn
            Default
              nImageNo = hMiCheckBoxOffEn
          EndSelect
        Else  ; disabled
          Select \nState
            Case #PB_Checkbox_Checked
              nImageNo = hMiCheckBoxOnDi
            Case #PB_Checkbox_Inbetween
              nImageNo = hMiCheckBoxBothDi
            Default
              nImageNo = hMiCheckBoxOffDi
          EndSelect
        EndIf
        nTop = (GadgetHeight(nGadgetNo) - 13) >> 1
        DrawImage(ImageID(nImageNo),0,nTop,13,13)
        If \sText
          DrawingFont(FontID(\nFontNo))
          If \bEnabled Or \bIgnoreDisabledColor
            DrawText(17, nTop, \sText, \nFrontColor, \nBackColor)
          Else
            DrawText(17, nTop, \sText, glSysColGrayText, \nBackColor)
          EndIf
        EndIf
        \nReqdWidth = 17 + TextWidth(\sText)
        StopDrawing()
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure drawOptionGadget2(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex, nImageNo, nTop
  
  ; debugMsg(sProcName, #SCS_START)
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    With gaGadgetProps(nGadgetPropsIndex)
      If StartDrawing(CanvasOutput(nGadgetNo))
        Box(0, 0, GadgetWidth(nGadgetNo), GadgetHeight(nGadgetNo), \nBackColor)
        If \bEnabled
          If \nState = 0
            nImageNo = hMiOptionOffEn
          Else
            nImageNo = hMiOptionOnEn
          EndIf
        Else  ; disabled
          If \nState = 0
            nImageNo = hMiOptionOffDi
          Else
            nImageNo = hMiOptionOnDi
          EndIf
        EndIf
        nTop = (GadgetHeight(nGadgetNo) - 13) / 2.0
        DrawAlphaImage(ImageID(nImageNo),0,nTop)
        If \sText
          DrawingFont(FontID(\nFontNo))
          If \bEnabled Or \bIgnoreDisabledColor
            DrawText(16, nTop, \sText, \nFrontColor, \nBackColor)
          Else
            DrawText(16, nTop, \sText, glSysColGrayText, \nBackColor)
          EndIf
        EndIf
        \nReqdWidth = 16 + TextWidth(\sText)
        StopDrawing()
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure drawOwnGadget(nGadgetNo, nGadgetType)
  Select nGadgetType
    Case #SCS_GTYPE_CHECKBOX2
      drawCheckBoxGadget2(nGadgetNo)
    Case #SCS_GTYPE_OPTION2
      drawOptionGadget2(nGadgetNo)
    Case #SCS_GTYPE_BUTTON2
      drawButtonGadget2(nGadgetNo)
  EndSelect
EndProcedure

Procedure getOwnFlags(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nFlags
EndProcedure

Procedure setOwnFont(nGadgetNo, nFontNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    \nFontNo = nFontNo
    drawOwnGadget(nGadgetNo, \nGType)
  EndWith
EndProcedure

Procedure getOwnValue(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nValue
EndProcedure

Procedure setOwnValue(nGadgetNo, nValue)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    \nValue = nValue
    drawOwnGadget(nGadgetNo, \nGType)
  EndWith
EndProcedure

Procedure getOwnState(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nState
EndProcedure

Procedure setOwnState(nGadgetNo, nState)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  ; NOTE: (note written 30Sep2019)
  ; There are MANY calls to setOwnState() for checkboxes, where the nState parameter has been passed as #True or #False.
  ; That is technically incorrect - the nState should be set to #PB_Checkbox_Checked, #PB_Checkbox_Unchecked Or #PB_Checkbox_Inbetween.
  ; However, the PB constant #PB_Checkbox_Checked = 1 and #True = 1, and #PB_Checkbox_Unchecked = 0 and #False = 0, so using #True and #False will work,
  ; but any future use should apply the appropriate #PB_Checkbox_... constant.
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    \nState = nState
    drawOwnGadget(nGadgetNo, \nGType)
  EndWith
EndProcedure

Procedure getOwnEnabled(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\bEnabled
EndProcedure

Procedure setOwnEnabled(nGadgetNo, bEnabled)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    If \bEnabled <> bEnabled
      ; only execute the following if the enabled state is to be changed
      \bEnabled = bEnabled
      drawOwnGadget(nGadgetNo, \nGType)
      If bEnabled
        DisableGadget(nGadgetNo, #False)
      Else
        DisableGadget(nGadgetNo, #True)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure.s getOwnText(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\sText
EndProcedure

Procedure setOwnText(nGadgetNo, sText.s)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    \sText = sText
    drawOwnGadget(nGadgetNo, \nGType)
  EndWith
EndProcedure

Procedure setOwnColor(nGadgetNo, nColorType, nColor)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    Select nColorType
      Case #PB_Gadget_FrontColor
        \nFrontColor = nColor
      Case #PB_Gadget_BackColor
        \nBackColor = nColor
    EndSelect
    drawOwnGadget(nGadgetNo, \nGType)
  EndWith
EndProcedure

Procedure setGType(nGadgetNo, nGType)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    \nGType = nGType
  EndWith
EndProcedure

Procedure.s buildWindowProcName(pProcName.s, pWindowNo)
  If pWindowNo > 0
    ProcedureReturn pProcName + "[" + decodeWindow(pWindowNo) + "]"
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s buildGadgetProcName(pProcName.s, nGadgetNo)
  PROCNAMEC()
  Protected sReqdProcName.s = pProcName
  Protected nGadgetPropsIndex
  Protected nGWindowNo, nEditorComponent, nCuePanelNo
  
  ; debugMsg(sProcName, #SCS_START + ", pProcName=" + pProcName + ", nGadgetNo=G" + nGadgetNo)
  
  If nGadgetNo > 0
    nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    If nGadgetPropsIndex >= 0
      If Len(gaGadgetProps(nGadgetPropsIndex)\sName) = 0
        sReqdProcName + "[" + nGadgetNo + "]"
      Else
        sReqdProcName + "["
        nGWindowNo = gaGadgetProps(nGadgetPropsIndex)\nGWindowNo
        If nGWindowNo > 0
          sReqdProcName + decodeWindow(nGWindowNo) + "\"
        EndIf
        nEditorComponent = gaGadgetProps(nGadgetPropsIndex)\nEditorComponent
        If nEditorComponent > 0
          sReqdProcName + RemoveString(decodeEditorComponent(nEditorComponent),"#") + "\"
        EndIf
        nCuePanelNo = gaGadgetProps(nGadgetPropsIndex)\nCuePanelNo
        If nCuePanelNo >= 0
          sReqdProcName + gaPnlVars(nCuePanelNo)\sName + "\"
        EndIf
        sReqdProcName + gaGadgetProps(nGadgetPropsIndex)\sName + "]"
      EndIf
    EndIf
  EndIf
  ProcedureReturn sReqdProcName
EndProcedure

Procedure scsSetGadgetFont(nGadgetNo, nFontNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  If nFontNo = 0
    scsErrorHandler(#SCS_ERROR_FONT_NOT_SET, sProcName)
  ElseIf IsFont(nFontNo) = #False
    scsErrorHandler(#SCS_ERROR_FONT_INVALID, sProcName)
  EndIf
  
  If nGadgetNo = #PB_Default
    SetGadgetFont(#PB_Default, FontID(nFontNo))
    gnDefaultFontNo = nFontNo
  ElseIf IsGadget(nGadgetNo)
    nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    SetGadgetFont(nGadgetNo, FontID(nFontNo))
    gaGadgetProps(nGadgetPropsIndex)\nFontNo = nFontNo
  EndIf
EndProcedure

Procedure obtainSplitterSeparatorSizes()
  PROCNAMEC()
  Protected nButton1, nButton2, nButton3, nButton4, nSplitter1, nSplitter2
  
  debugMsg(sProcName, #SCS_START)
  
  If OpenWindow(#WYY, 0, 0, 260, 300, "", #PB_Window_Invisible)
    
    ; horizontal splitter
    nButton1 = ButtonGadget(#PB_Any, 0, 0, 0, 0, "1") ; No need to specify size or coordiantes
    nButton2 = ButtonGadget(#PB_Any, 0, 0, 0, 0, "2") ; as they will be sized automatically
    nSplitter1 = SplitterGadget(#PB_Any, 5, 5, 220, 100, nButton1, nButton2, #PB_Splitter_Separator)
    
    ; vertical splitter
    nButton3 = ButtonGadget(#PB_Any, 0, 0, 0, 0, "3") ; No need to specify size or coordiantes
    nButton4 = ButtonGadget(#PB_Any, 0, 0, 0, 0, "4") ; as they will be sized automatically
    nSplitter2 = SplitterGadget(#PB_Any, 5, 110, 220, 100, nButton3, nButton4, #PB_Splitter_Separator|#PB_Splitter_Vertical)
    
    ; calculate separator sizes
    gnHSplitterSeparatorHeight = GadgetHeight(nSplitter1) - GadgetHeight(nButton1) - GadgetHeight(nButton2)
    gnVSplitterSeparatorWidth = GadgetWidth(nSplitter2) - GadgetWidth(nButton3) - GadgetWidth(nButton4)
    debugMsg(sProcName, "gnHSplitterSeparatorHeight=" + Str(gnHSplitterSeparatorHeight) + ", gnVSplitterSeparatorWidth=" + Str(gnVSplitterSeparatorWidth))
    
    ; now destroy the temporary window
    FreeGadget(nButton1)
    FreeGadget(nButton2)
    FreeGadget(nButton3)
    FreeGadget(nButton4)
    FreeGadget(nSplitter1)
    FreeGadget(nSplitter2)
    CloseWindow(#WYY)
    
  EndIf
EndProcedure

Procedure obtainPanelContentOffsets()
  PROCNAMEC()
  Protected nPanelGadgetNo
  
  If OpenWindow(#WYY, 0, 0, 260, 300, "", #PB_Window_Invisible)
    
    ; panel gadget
    nPanelGadgetNo = PanelGadget(#PB_Any, 0, 0, 200, 180)
    AddGadgetItem (nPanelGadgetNo, -1, "Panel 1")
    ; CloseGadgetList()
    
    debugMsg(sProcName, "Panel ItemWidth=" + GetGadgetAttribute(nPanelGadgetNo, #PB_Panel_ItemWidth) +
                        ", ItemHeight=" + GetGadgetAttribute(nPanelGadgetNo, #PB_Panel_ItemHeight) +
                        ", TabHeight=" + GetGadgetAttribute(nPanelGadgetNo, #PB_Panel_TabHeight))
    
    ; calc panel content offsets
    gnPanelContentXOffset = ((GadgetWidth(nPanelGadgetNo) - GetGadgetAttribute(nPanelGadgetNo, #PB_Panel_ItemWidth)) >> 1) ; - 1
    gnPanelContentYOffset = GetGadgetAttribute(nPanelGadgetNo, #PB_Panel_TabHeight)
    debugMsg(sProcName, "gnPanelContentXOffset=" + gnPanelContentXOffset + ", gnPanelContentYOffset=" + gnPanelContentYOffset)
    
    ; now destroy the temporary window
    FreeGadget(nPanelGadgetNo)
    ; debugMsg(sProcName, "FreeGadget(G" + Str(nPanelGadgetNo) + ")")
    CloseWindow(#WYY)
    
  EndIf
EndProcedure

Procedure.s GadgetNoAndName(nGadgetNo=-1)
  PROCNAMEC()
  Protected nMyGadgetNo, nMyGadgetPropsIndex
  Protected sGadgetNoAndName.s
  
  If nGadgetNo = -1
    nMyGadgetNo = gnEventGadgetNo
    nMyGadgetPropsIndex = gnEventGadgetPropsIndex
    sGadgetNoAndName = Str(nMyGadgetNo) + "(" + gaGadgetProps(nMyGadgetPropsIndex)\sName + ")"
  ElseIf IsGadget(nGadgetNo)
    nMyGadgetNo = nGadgetNo
    nMyGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    sGadgetNoAndName = Str(nMyGadgetNo) + "(" + gaGadgetProps(nMyGadgetPropsIndex)\sName + ")"
  Else
    sGadgetNoAndName = Str(nMyGadgetNo)
  EndIf
  ProcedureReturn sGadgetNoAndName
EndProcedure

;- WINDOW PROPERTIES
;- Window Property: Enabled
Procedure getWindowEnabled(nWindowNo)
  ProcedureReturn gaWindowProps(nWindowNo)\bEnabled
EndProcedure

Procedure setWindowEnabled(nWindowNo, bEnable)
  If bEnable
    DisableWindow(nWindowNo, #False)
  Else
    DisableWindow(nWindowNo, #True)
  EndIf
  gaWindowProps(nWindowNo)\bEnabled = bEnable
EndProcedure

;- Window Property: Name
Procedure.s getWindowName(nWindowNo)
  ProcedureReturn gaWindowProps(nWindowNo)\sName
EndProcedure

Procedure setWindowName(nWindowNo, sName.s)
  gaWindowProps(nWindowNo)\sName = sName
EndProcedure

;- Window Property: Visible
Procedure getWindowVisible(nWindowNo)
  ProcedureReturn gaWindowProps(nWindowNo)\bVisible
EndProcedure

Procedure setWindowVisible(nWindowNo, bVisible)
  PROCNAMECW(nWindowNo)
  Protected nActiveWindow
  
  debugMsg(sProcName, #SCS_START + ", bVisible=" + strB(bVisible))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_SET_WINDOW_VISIBLE, nWindowNo, 0, bVisible)
    ProcedureReturn
  EndIf
  
  If IsWindow(nWindowNo)
    nActiveWindow = GetActiveWindow()
    Select nWindowNo
      Case #WV2 To #WV_LAST
        ; video windows
        If gbVideosOnMainWindow
          If bVisible
            HideWindow(nWindowNo, #False)
          Else
            HideWindow(nWindowNo, #True)
          EndIf
        Else
          If bVisible
            ShowWindow_(WindowID(nWindowNo), #SW_SHOWNOACTIVATE)
          Else
            ShowWindow_(WindowID(nWindowNo), #SW_HIDE)
          EndIf
        EndIf
      Default
        ; all other windows
        If bVisible
          HideWindow(nWindowNo, #False)
        Else
          HideWindow(nWindowNo, #True)
        EndIf
    EndSelect
    gaWindowProps(nWindowNo)\bVisible = bVisible
    If IsWindow(nActiveWindow)
      SAW(nActiveWindow)
    EndIf
  EndIf
EndProcedure

;- Window Property: Sticky
Procedure getWindowSticky(nWindowNo)
  ProcedureReturn gaWindowProps(nWindowNo)\bSticky
EndProcedure

Procedure setWindowSticky(nWindowNo, bSticky)
  PROCNAMECW(nWindowNo)
  Protected nActiveWindow
  
  ; debugMsg(sProcName, #SCS_START + ", bSticky=" + strB(bSticky))
  
  nActiveWindow = GetActiveWindow()
  StickyWindow(nWindowNo, bSticky)
  gaWindowProps(nWindowNo)\bSticky = bSticky
  If IsWindow(nActiveWindow)
    SAW(nActiveWindow)
  EndIf
EndProcedure

;- GADGET PROPERTIES
;- Gadget Property: AllowEditorColors
Procedure getAllowEditorColors(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\bAllowEditorColors
EndProcedure

Procedure setAllowEditorColors(nGadgetNo, bAllowEditorColors)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\bAllowEditorColors = bAllowEditorColors
EndProcedure

;- Gadget Property: ButtonType
Procedure getButtonType(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nButtonType
EndProcedure

Procedure setButtonType(nGadgetNo, nButtonType)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\nButtonType = nButtonType
EndProcedure

;- Gadget Property: Enabled
Procedure getEnabled(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\bEnabled
EndProcedure

Procedure setEnabled(nGadgetNo, bEnable, bSetBackgroundColor=#False)
  ; PROCNAMEC()
  Protected nGadgetPropsIndex
  
  ; debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo) + ", bEnable=" + strB(bEnable))
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ; CheckSubInRange(nGadgetPropsIndex, ArraySize(gaGadgetProps()), "gaGadgetProps()")
  With gaGadgetProps(nGadgetPropsIndex)
    If \bEnabled <> bEnable
      ; only execute the following if the enabled state is to be changed
      ; debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo) + ", bEnable=" + bEnable + ", gaGadgetProps(" + nGadgetPropsIndex + ")\bEnabled=" + \bEnabled + ", \nButtonType=" + \nButtonType)
      If bEnable
        DisableGadget(nGadgetNo, #False)
      Else
        DisableGadget(nGadgetNo, #True)
      EndIf
      If \nButtonType > 0
        If bEnable
          SetGadgetAttribute(nGadgetNo, #PB_Button_Image, ImageID(\hImageEn))
        Else
          SetGadgetAttribute(nGadgetNo, #PB_Button_Image, ImageID(\hImageDi))
        EndIf
      EndIf
      \bEnabled = bEnable
      If bSetBackgroundColor
        setTextBoxBackColor(nGadgetNo)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure refreshEnabledState(nGadgetNo)
  PROCNAMEC()
  ; primarily designed for ScrollBar gadgets as there is a bug(?) in PB4.60B4 whereby issuing SetGadgetState() on a disabled scrollbar gadget will re-enable the gadget
  ; reported as a bug 5 Sep 2011
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    ; debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo) + ", gaGadgetProps(" + nGadgetPropsIndex + ")\bEnabled=" + \bEnabled)
    If \bEnabled
      DisableGadget(nGadgetNo, #False)
    Else
      DisableGadget(nGadgetNo, #True)
    EndIf
    If \nButtonType > 0
      If \bEnabled
        SetGadgetAttribute(nGadgetNo, #PB_Button_Image, ImageID(\hImageEn))
      Else
        SetGadgetAttribute(nGadgetNo, #PB_Button_Image, ImageID(\hImageDi))
      EndIf
    EndIf
  EndWith
EndProcedure

;- Gadget Property: ResizeFlags
Procedure getResizeFlags(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nResizeFlags
EndProcedure

Procedure setResizeFlags(nGadgetNo, nResizeFlags)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\nResizeFlags = nResizeFlags
EndProcedure

;- Gadget Property: ReverseEditorColors
Procedure getReverseEditorColors(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\bReverseEditorColors
EndProcedure

Procedure setReverseEditorColors(nGadgetNo, bReverseEditorColors)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\bReverseEditorColors = bReverseEditorColors
EndProcedure

;- Gadget Property: IgnoreDisabledColor
Procedure getIgnoreDisabledColor(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\bIgnoreDisabledColor
EndProcedure

Procedure setIgnoreDisabledColor(nGadgetNo, bIgnoreDisabledColor)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\bIgnoreDisabledColor = bIgnoreDisabledColor
EndProcedure

;- Gadget Property: UpperCase
Procedure getUpperCase(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\bUpperCase
EndProcedure

Procedure setUpperCase(nGadgetNo, bUpperCase)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\bUpperCase = bUpperCase
EndProcedure

;- Gadget Property: ValidChars
Procedure.s getValidChars(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\sValidChars
EndProcedure

Procedure setValidChars(nGadgetNo, sValidChars.s)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\sValidChars = sValidChars
  If Len(sValidChars) = 0
    gaGadgetProps(nGadgetPropsIndex)\bValidCharsPresent = #False
  Else
    gaGadgetProps(nGadgetPropsIndex)\bValidCharsPresent = #True
  EndIf
EndProcedure

;- Gadget Property: Visible
Procedure getVisible(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex, bVisible
  
  If IsGadget(nGadgetNo)
    nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    bVisible = gaGadgetProps(nGadgetPropsIndex)\bVisible
  EndIf
  ProcedureReturn bVisible
EndProcedure

Procedure setVisible(nGadgetNo, bVisible)
  gnLabelPre = #PB_Compiler_Line
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  gnLabelPre = #PB_Compiler_Line
  If IsGadget(nGadgetNo)
    gnLabelPre = #PB_Compiler_Line
    nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    gnLabelPre = #PB_Compiler_Line
    If gaGadgetProps(nGadgetPropsIndex)\bVisible = bVisible
      gnLabelPre = #PB_Compiler_Line
      ProcedureReturn
      gnLabelPre = #PB_Compiler_Line
    EndIf
    gnLabelPre = #PB_Compiler_Line
    
    CompilerIf #cTraceSetVisible
      debugMsg(sProcName, sProcName + "(" + gaGadgetProps(nGadgetPropsIndex)\sGWindow + "\" + gaGadgetProps(nGadgetPropsIndex)\sName + ", " + strB(bVisible) + ")")
    CompilerElse
      CompilerIf #cTraceSetVisible_excl_WMN_WED
        Select gaGadgetProps(nGadgetPropsIndex)\nGWindowNo
          Case #WMN, #WED
            ; no trace
          Default
            debugMsg(sProcName, sProcName + "(" + gaGadgetProps(nGadgetPropsIndex)\sGWindow + "\" + gaGadgetProps(nGadgetPropsIndex)\sName + ", " + strB(bVisible) + ")")
        EndSelect
      CompilerEndIf
    CompilerEndIf
    
    gnLabelPre = #PB_Compiler_Line
    If bVisible
      gnLabelPre = #PB_Compiler_Line
      HideGadget(nGadgetNo, #False)
      gnLabelPre = #PB_Compiler_Line
    Else
      gnLabelPre = #PB_Compiler_Line
      HideGadget(nGadgetNo, #True)
      gnLabelPre = #PB_Compiler_Line
    EndIf
    gnLabelPre = #PB_Compiler_Line
    gaGadgetProps(nGadgetPropsIndex)\bVisible = bVisible
    gnLabelPre = #PB_Compiler_Line
  EndIf
  gnLabelPre = #PB_Compiler_Line
EndProcedure

;- Gadget Property: WindowNo
Procedure getWindowNo(nGadgetNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ProcedureReturn gaGadgetProps(nGadgetPropsIndex)\nGWindowNo
EndProcedure

Procedure setWindowNo(nGadgetNo, nGWindowNo)
  PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\nGWindowNo = nGWindowNo
EndProcedure

;- MENU ITEMS
Procedure scsEnableMenuItem(nMenu, nMenuItem, bEnable)
  PROCNAMEC()
  If gbMenuItemAvailable(nMenuItem)
    If IsMenu(nMenu)
      If bEnable
        ; debugMsg(sProcName, "calling DisableMenuItem(" + decodeMenuItem(nMenu)  + ", " + decodeMenuItem(nMenuItem) + ", 0)")
        DisableMenuItem(nMenu, nMenuItem, 0)
      Else
        ; debugMsg(sProcName, "calling DisableMenuItem(" + decodeMenuItem(nMenu)  + ", " + decodeMenuItem(nMenuItem) + ", 1)")
        DisableMenuItem(nMenu, nMenuItem, 1)
      EndIf
      gbMenuItemEnabled(nMenuItem) = bEnable
    EndIf
  Else
    debugMsg(sProcName, "gbMenuItemAvailable(" + decodeMenuItem(nMenuItem) + ")=" + strB(gbMenuItemAvailable(nMenuItem)))
  EndIf
EndProcedure

Procedure scsEnableMenuItem2(nMenu, nMenuItem, bEnable, nMenu2)
  PROCNAMEC()
  If gbMenuItemAvailable(nMenuItem)
    If IsMenu(nMenu)
      If bEnable
        ; debugMsg(sProcName, "calling DisableMenuItem(" + decodeMenuItem(nMenu)  + ", " + decodeMenuItem(nMenuItem) + ", 0)")
        DisableMenuItem(nMenu, nMenuItem, 0)
      Else
        ; debugMsg(sProcName, "calling DisableMenuItem(" + decodeMenuItem(nMenu)  + ", " + decodeMenuItem(nMenuItem) + ", 1)")
        DisableMenuItem(nMenu, nMenuItem, 1)
      EndIf
    EndIf
    If IsMenu(nMenu2)
      If bEnable
        ; debugMsg(sProcName, "calling DisableMenuItem(" + decodeMenuItem(nMenu2)  + ", " + decodeMenuItem(nMenuItem) + ", 0)")
        DisableMenuItem(nMenu2, nMenuItem, 0)
      Else
        ; debugMsg(sProcName, "calling DisableMenuItem(" + decodeMenuItem(nMenu2)  + ", " + decodeMenuItem(nMenuItem) + ", 1)")
        DisableMenuItem(nMenu2, nMenuItem, 1)
      EndIf
    EndIf
    gbMenuItemEnabled(nMenuItem) = bEnable
  EndIf
EndProcedure

Procedure scsSetMenuItemText(nMenu, nMenuItem, sText.s)
  ; PROCNAMEC()
  If gbMenuItemAvailable(nMenuItem)
    If IsMenu(nMenu)
      If sText ; nb SetMenuItemText crashes if sText is null
        ; debugMsg(sProcName, "calling SetMenuItemText(" + decodeMenuItem(nMenu) + ", " + decodeMenuItem(nMenuItem) + ", " + #DQUOTE$ + sText + #DQUOTE$ + ")")
        SetMenuItemText(nMenu, nMenuItem, sText)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure newGadget(sName.s, nOrigLeft, nOrigTop, nOrigWidth, nOrigHeight, nGType=0, nGadgetNoForEvHdlr=0, nModGadgetType=0)
  PROCNAMEC()
  Protected nPos, nLen, sMyName.s
  Protected sMsg.s
  Protected n, nThisGadgetNo
  Protected bUseGadgetNoForEvHdlr
  
  nThisGadgetNo = -1
  If gnFreeGadgetCount > 0
    ; find a free entry
    For n = #SCS_GADGET_BASE_NO To gnMaxGadgetNo
      If gaGadgetProps(n - #SCS_GADGET_BASE_NO)\nGType = -1
        ; found the first freed entry
        nThisGadgetNo = n
        gnFreeGadgetCount - 1
        Break
      EndIf
    Next n
  EndIf
  If nThisGadgetNo < 0
    gnNextGadgetNo + 1
    gnMaxGadgetNo = gnNextGadgetNo
    If (gnNextGadgetNo - #SCS_GADGET_BASE_NO) > ArraySize(gaGadgetProps())
      ReDim gaGadgetProps(gnNextGadgetNo - #SCS_GADGET_BASE_NO + 200)
    EndIf
    nThisGadgetNo = gnNextGadgetNo
  EndIf
  
  With gaGadgetProps(nThisGadgetNo - #SCS_GADGET_BASE_NO)
    \sName = sName
    \nGType = nGType  ; nb may be 0 - see also \nModGadgetType below
    \nModGadgetType = nModGadgetType ; see enumeration #SCS_MG_... (0 if not a module-created gadget, eg not created by TextEx::Gadget(), etc)
    \nGWindowNo = gnCurrentWindowNo
    \sGWindow = gsCurrentWindow
    \nCuePanelNo = gnCurrentCuePanelNo
    \nSliderNo = gnCurrentSliderNo
    \nEditorComponent = gnCurrentEditorComponent
    \bVisible = #True
    \bEnabled = #True
    \nOrigLeft = nOrigLeft
    \nOrigTop = nOrigTop
    \nOrigWidth = nOrigWidth
    \nOrigHeight = nOrigHeight
    \nFontNo = gnDefaultFontNo
    \nContainerLevel = gnContainerLevel
    \nContainerGadgetNo = gaContainerLevelGadgetNo(gnContainerLevel)
    \bSlider = gbCreatingSliderGadgets
    \nArrayIndex = 0  ; nb \nArrayIndex must be 0 for non-array items as this is copied to gnEventGadgetArrayIndex which may be used in SCS Event Handlers, such as in WQM_EventHandler()
                      ; if the value was -1 (as it was in pre 11.4.2 versions) the event handler could throw a subscript error when checking fields like WQM\sldDMXValue[gnEventGadgetArrayIndex]
                      ; when the current event gadget is a non-array item
    nPos = FindString(sName, "[", 1)
    If nPos > 0
      nLen = FindString(sName, "]", nPos) - nLen - 1
    Else
      nPos = FindString(sName, "(", 1)
      If nPos > 0
        nLen = FindString(sName, ")", nPos) - nLen - 1
      EndIf
    EndIf
    If nPos > 0
      \sNameGroup = Left(sName, nPos-1)
      If nLen > 0
        \nArrayIndex = Val(Mid(sName, nPos+1, nLen))
      EndIf
      If nGadgetNoForEvHdlr > 0
        If IsGadget(nGadgetNoForEvHdlr)
          bUseGadgetNoForEvHdlr = #True
        ElseIf (nGadgetNoForEvHdlr >= #SCS_G4EH_FIRST) And (nGadgetNoForEvHdlr <= #SCS_G4EH_LAST)
          bUseGadgetNoForEvHdlr = #True
        EndIf
      EndIf
      If bUseGadgetNoForEvHdlr
        \nGadgetNoForEvHdlr = nGadgetNoForEvHdlr
      Else
        \nGadgetNoForEvHdlr = nThisGadgetNo
        If \nArrayIndex <> 0
          ; find [0] instance of this gadget name, going backwards from the current gadget
          For n = (nThisGadgetNo - #SCS_GADGET_BASE_NO - 1) To 0 Step -1
            If gaGadgetProps(n)\sNameGroup = \sNameGroup
              If gaGadgetProps(n)\nArrayIndex = 0
                \nGadgetNoForEvHdlr = n + #SCS_GADGET_BASE_NO
                Break
              EndIf
            EndIf
          Next n
        EndIf
      EndIf
    Else
      \sNameGroup = \sName
      If (nGadgetNoForEvHdlr > 0) And (IsGadget(nGadgetNoForEvHdlr))
        \nGadgetNoForEvHdlr = nGadgetNoForEvHdlr
      Else
        \nGadgetNoForEvHdlr = nThisGadgetNo
      EndIf
    EndIf
    If \nArrayIndex < 0
      ; shouldn't get here, but see comment above against "\nArrayIndex = 0"
      \nArrayIndex = 0
    EndIf
    
    ; set up \sLogName for key event logging
    If \nEditorComponent > 0
      \sLogName = RemoveString(decodeEditorComponent(\nEditorComponent),"#") + "\" + \sName
    Else
      \sLogName = RemoveString(\sGWindow,"#") + "\" + \sName
    EndIf
    
    ; initial values for owner-drawn gadgets
    \sText = ""
    \nFrontColor = -1
    \nBackColor = -1
    
    CompilerIf #cTraceGadgets
      If sName
        sMyName = sName
      Else
        sMyName = "!!! NO NAME !!!"
      EndIf
      sMsg = "GadgetId G" + nThisGadgetNo + " = " + sMyName + ", \nContainerLevel=" + \nContainerLevel + ", \nContainerGadgetNo=G" + \nContainerGadgetNo +
             ", X=" + nOrigLeft + ", Y=" + nOrigTop + ", Width=" + nOrigWidth + ", Height=" + nOrigHeight
      sMsg + ", \nGWindowNo=" + decodeWindow(\nGWindowNo)
      If \nEditorComponent > 0
        sMsg + ", \nEditorComponent=" + decodeEditorComponent(\nEditorComponent)
      EndIf
      If \nSliderNo >= 0
        sMsg + ", \nSliderNo=" + \nSliderNo
      EndIf
      If \nArrayIndex >= 0
        sMsg + ", \nArrayIndex=" + \nArrayIndex
      EndIf
      sMsg + ", nGadgetNoForEvHdlr=" + nGadgetNoForEvHdlr
      sMsg + ", \nGadgetNoForEvHdlr=G" + \nGadgetNoForEvHdlr
      debugMsg(sProcName, sMsg)
    CompilerEndIf
    
  EndWith
  gnNextX = nOrigLeft + nOrigWidth
  ProcedureReturn nThisGadgetNo
EndProcedure

Procedure scsFreeGadget(nGadgetNo)
  PROCNAMEC()
  
  If IsGadget(nGadgetNo)
    If (nGadgetNo >= #SCS_GADGET_BASE_NO) And (nGadgetNo <= gnMaxGadgetNo)
      With gaGadgetProps(nGadgetNo - #SCS_GADGET_BASE_NO)
        \nGType = -1
      EndWith
      gnFreeGadgetCount + 1
      debugMsg(sProcName, "nGadgetNo=G" + nGadgetNo + ", gnFreeGadgetCount=" + gnFreeGadgetCount)
    EndIf
    FreeGadget(nGadgetNo)
  EndIf
  
EndProcedure
  
Procedure setGadgetNoForEvHdlr(nGadgetNo, nGadgetNoForEvHdlr)
  ; PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    \nGadgetNoForEvHdlr = nGadgetNoForEvHdlr
    ; debugMsg(sProcName, "gaGadgetProps(" + nGadgetPropsIndex + ")\sName=" + \sName + ", \nGadgetNoForEvHdlr=" + \nGadgetNoForEvHdlr + ", \nSliderNo=" + \nSliderNo)
  EndWith
EndProcedure

Procedure scsButtonGadget(X, Y, Width, Height, Text$, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for ButtonGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr)
  ButtonGadget(nGadgetNo, X, Y, Width, Height, Text$, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure modButtonGadget(X, Y, Width, Height, Text$, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for ButtonEx::Gadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr, #SCS_MG_BUTTON)
  ButtonEx::Gadget(nGadgetNo, X, Y, Width, Height, Text$, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsButtonImageGadget(X, Y, Width, Height, ImageId, flags=0, sName.s="")
  ; SCS wrapper for ButtonImageGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ButtonImageGadget(nGadgetNo, X, Y, Width, Height, ImageId, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsCanvasGadget(X, Y, Width, Height, flags=0, sName.s="", nGadgetNoForEvHdlr=0, nGType=0)
  ; SCS wrapper for CanvasGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, nGType, nGadgetNoForEvHdlr)
  CanvasGadget(nGadgetNo, X, Y, Width, Height, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsCheckBoxGadget(X, Y, Width, Height, Text$, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for CheckBoxGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr)
  CheckBoxGadget(nGadgetNo, X, Y, Width, Height, Text$, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsCheckBoxGadget2(X, Y, Width, Height, Text$, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; owner-drawn checkbox gadget to allow setting colors
  PROCNAMEC()
  Protected nGadgetPropsIndex, nImageNo
  Protected nMyWidth
  
  ; Width <= 0 causes auto-size
  If Width > 0
    nMyWidth = Width
  Else
    nMyWidth = 100
  EndIf
  
  Protected nGadgetNo = newGadget(sName, X, Y, nMyWidth, Height, #SCS_GTYPE_CHECKBOX2, nGadgetNoForEvHdlr)
  ; CanvasGadget(nGadgetNo, X, Y, nMyWidth, Height, 0)
  ; 14Aug2018 11.7.2 added #PB_Canvas_Keyboard so user can tab to the checkbox, and #PB_Canvas_DrawFocus so user can see the checkbox has focus
  CanvasGadget(nGadgetNo, X, Y, nMyWidth, Height, #PB_Canvas_Keyboard|#PB_Canvas_DrawFocus)
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    With gaGadgetProps(nGadgetPropsIndex)
      \sText = Text$
      \nFlags = flags
      \bAllowEditorColors = #True
    EndWith
  EndIf
  drawCheckBoxGadget2(nGadgetNo)
  If Width <= 0
    If nGadgetPropsIndex >= 0
      With gaGadgetProps(nGadgetPropsIndex)
        If \nReqdWidth > 16
          ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, \nReqdWidth, #PB_Ignore)
          gnNextX = GadgetX(nGadgetNo) + GadgetWidth(nGadgetNo)
        EndIf
      EndWith
    EndIf
  EndIf
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsButtonGadget2(X, Y, Width, Height, Text$, flags=0, nOGFlags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; owner-drawn button gadget to allow setting colors and rounded corners
  PROCNAMEC()
  Protected nGadgetPropsIndex, nImageNo
  Protected nMyWidth
  
  ; Width <= 0 causes auto-size
  If Width > 0
    nMyWidth = Width
  Else
    nMyWidth = 100
  EndIf
  
  Protected nGadgetNo = newGadget(sName, X, Y, nMyWidth, Height, #SCS_GTYPE_BUTTON2, nGadgetNoForEvHdlr)
  CanvasGadget(nGadgetNo, X, Y, nMyWidth, Height, #PB_Canvas_Keyboard|#PB_Canvas_DrawFocus)
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    With gaGadgetProps(nGadgetPropsIndex)
      \sText = Text$
      \nFlags = flags
      \nOGFlags = nOGFlags
      \bAllowEditorColors = #True
      \nBackColor = RGB(26, 115, 232) ; as used by Google Chrome 'Settings'
      \nFrontColor = RGB(231, 240, 253)
    EndWith
  EndIf
  drawButtonGadget2(nGadgetNo)
  If Width <= 0
    If nGadgetPropsIndex >= 0
      With gaGadgetProps(nGadgetPropsIndex)
        If \nReqdWidth > 16
          ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, \nReqdWidth, #PB_Ignore)
          drawButtonGadget2(nGadgetNo)
          gnNextX = GadgetX(nGadgetNo) + GadgetWidth(nGadgetNo)
        EndIf
      EndWith
    EndIf
  EndIf
  ProcedureReturn nGadgetNo
EndProcedure

Procedure drawButtonGadget2(nGadgetNo)
  ; PROCNAMEC()
  Protected nGadgetPropsIndex, nTextWidth, nLeft, nTop
  
  ; debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    With gaGadgetProps(nGadgetPropsIndex)
      If StartDrawing(CanvasOutput(nGadgetNo))
        Box(0, 0, GadgetWidth(nGadgetNo), GadgetHeight(nGadgetNo), \nBackColor)
        nTop = (GadgetHeight(nGadgetNo) - 13) / 2.0
        ; debugMsg(sProcName, "\sText=" + #DQUOTE$ + \sText + #DQUOTE$)
        If \sText
          DrawingFont(FontID(\nFontNo))
          nTextWidth = TextWidth(\sText)
          If nTextWidth < GadgetWidth(nGadgetNo)
            nLeft = (GadgetWidth(nGadgetNo) - nTextWidth) >> 1
          EndIf
          If \bEnabled Or \bIgnoreDisabledColor
            DrawText(nLeft, nTop, \sText, \nFrontColor, \nBackColor)
            ; debugMsg(sProcName, "DrawText(" + nLeft + ", " + nTop + ", " + \sText + ", $" + hex6(\nFrontColor) + ", $" + hex6(\nBackColor) + ")")
          Else
            DrawText(nLeft, nTop, \sText, glSysColGrayText, \nBackColor)
            ; debugMsg(sProcName, "DrawText(" + nLeft + ", " + nTop + ", " + \sText + ", $" + hex6(glSysColGrayText) + ", $" + hex6(\nBackColor) + ")")
          EndIf
        EndIf
        \nReqdWidth = nTextWidth + 8
        StopDrawing()
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setButtonGadget2Text(nGadgetNo, sText.s)
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    gaGadgetProps(nGadgetPropsIndex)\sText = sText
    drawButtonGadget2(nGadgetNo)
  EndIf
  
EndProcedure

Procedure scsCloseGadgetList()
  ; SCS wrapper for CloseGadgetList command
  PROCNAMEC()
  CompilerIf #cTraceGadgets Or #cTraceContainerGadgets
    debugMsg(sProcName, "gnContainerLevel=" + gnContainerLevel)
  CompilerEndIf
  CloseGadgetList()
  gnContainerLevel - 1
EndProcedure

Procedure scsComboBoxGadget(X, Y, Width, Height, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for ComboBoxGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr)
  ComboBoxGadget(nGadgetNo, X, Y, Width, Height, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure modComboBoxGadget(X, Y, Width, Height, maxListHeight=80, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for ComboBoxEx::Gadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr, #SCS_MG_COMBOBOX)
  ComboBoxEx::Gadget(nGadgetNo, X, Y, Width, Height, maxListHeight, "", flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsContainerGadget(X, Y, Width, Height, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for ContainerGadget command
  PROCNAMEC()
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr)
  ContainerGadget(nGadgetNo, X, Y, Width, Height, flags)
  gaGadgetProps(nGadgetNo - #SCS_GADGET_BASE_NO)\bAllowEditorColors = #True
  gnContainerLevel + 1
  gaContainerLevelGadgetNo(gnContainerLevel) = nGadgetNo
  CompilerIf #cTraceContainerGadgets
    traceContainer(nGadgetNo)
  CompilerEndIf
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, sName + ", gnContainerLevel=" + gnContainerLevel)
  CompilerEndIf
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsMyGridGadget(nWindowNo, X, Y, Width, Height, Rows, Cols, DoNotDraw=#False, NoColScrollBar=#False, NoRowScrollBar=#False, sName.s="", nGadgetNoForEvHdlr=0)
  PROCNAMEC()
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr)
  MyGrid_New(nWindowNo, nGadgetNo, X, Y, Width, Height, Rows, Cols, DoNotDraw, NoColScrollBar, NoRowScrollBar)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsCopyImage(nSourceImageNo)
  gnNextImageNo + 1
  If CopyImage(nSourceImageNo, gnNextImageNo)
    ProcedureReturn gnNextImageNo
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure scsUseGadgetList(nWindowID, nGadgetNo=0)
  PROCNAMEC()
  
  If nGadgetNo <> 0
    ; new level
    gnContainerLevel + 1
    gaContainerLevelGadgetNo(gnContainerLevel) = nGadgetNo
    CompilerIf #cTraceContainerGadgets
      traceContainerNoPosOrSize(nGadgetNo)
    CompilerEndIf
  Else
    ; reverting to previous level
    gnContainerLevel - 1
  EndIf
  ProcedureReturn UseGadgetList(nWindowID)
EndProcedure

Procedure scsCreateImage(Width, Height, Depth=24)
  PROCNAMEC()
  ; modified to ensure minimum width and height are 1 pixel each, or CreateImage() will crash
  ; this situation can occur when setting the 'size' in #WQA (video/image cue) to the minimum value
  Protected nReqdWidth, nReqdHeight
  
  gnNextImageNo + 1
  nReqdWidth = Width
  If nReqdWidth < 1
    nReqdWidth = 1
  EndIf
  nReqdHeight = Height
  If nReqdHeight < 1
    nReqdHeight = 1
  EndIf
  If CreateImage(gnNextImageNo, nReqdWidth, nReqdHeight, Depth)
    ProcedureReturn gnNextImageNo
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure scsCreateMenu(nMenuHandle, nWindowNo)
  ; SCS wrapper for CreateMenu command
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nMenuHandle=" + decodeMenuItem(nMenuHandle) + ", nWindowNo=" + decodeWindow(nWindowNo))
  If IsMenu(nMenuHandle)
    FreeMenu(nMenuHandle)
  EndIf
  If CreateMenu(nMenuHandle, WindowID(nWindowNo))
    debugMsg(sProcName, "CreateMenu successful")
    ProcedureReturn #True
  Else
    debugMsg(sProcName, "CreateMenu failed")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure scsCreatePopupImageMenu(nMenuHandle, flags=0)
  ; SCS wrapper for CreatePopupImageMenu command
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nMenuHandle=" + decodeMenuItem(nMenuHandle))
  If IsMenu(nMenuHandle)
    FreeMenu(nMenuHandle)
  EndIf
  CreatePopupImageMenu(nMenuHandle, flags)
  If IsMenu(nMenuHandle)
    ProcedureReturn #True
  Else
    debugMsg(sProcName, "CreatePopupImageMenu failed")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure scsCreatePopupMenu(nMenuHandle)
  ; SCS wrapper for CreatePopupMenu command
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nMenuHandle=" + decodeMenuItem(nMenuHandle))
  If IsMenu(nMenuHandle)
    FreeMenu(nMenuHandle)
  EndIf
  If CreatePopupMenu(nMenuHandle)
    ProcedureReturn #True
  Else
    debugMsg(sProcName, "CreatePopupMenu failed")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure scsDrawingFont(nFontNo)
  PROCNAMEC()
  
  If nFontNo = 0
    scsErrorHandler(#SCS_ERROR_FONT_NOT_SET, sProcName)
  ElseIf IsFont(nFontNo) = #False
    scsErrorHandler(#SCS_ERROR_FONT_INVALID, sProcName)
  EndIf
  
  DrawingFont(FontID(nFontNo))
EndProcedure

Procedure scsEditorGadget(X, Y, Width, Height, flags=0, sName.s="")
  ; SCS wrapper for EditorGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  EditorGadget(nGadgetNo, X, Y, Width, Height, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsFrameGadget(X, Y, Width, Height, Text$, flags=0, sName.s="")
  ; SCS wrapper for FrameGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  FrameGadget(nGadgetNo, X, Y, Width, Height, Text$, flags)
  ; commented out - SetGadgetColor not supported by FrameGadget()
  ; gaGadgetProps(nGadgetNo-#SCS_GADGET_BASE_NO)\bAllowEditorColors = #True
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsHyperLinkGadget(X, Y, Width, Height, Text$, Color, flags=0, sName.s="")
  ; SCS wrapper for HyperLinkGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  HyperLinkGadget(nGadgetNo, X, Y, Width, Height, Text$, Color, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsImageGadget(X, Y, Width, Height, ImageId, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  PROCNAMEC()
  Protected nResult
  Protected sMsg.s
  ; SCS wrapper for ImageGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, 0, nGadgetNoForEvHdlr)
  nResult = ImageGadget(nGadgetNo, X, Y, Width, Height, ImageId, flags)
  If nResult = 0
    sMsg = "ImageGadget(" + nGadgetNo + ", " + X + ", " + Y + ", " + Width + ", " + Height + ", " + ImageId + ", " + flags + ") failed"
  EndIf
  If nResult = 0
    Debug sMsg
    debugMsg(sProcName, sMsg)
  EndIf
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsIPAddressGadget(X, Y, Width, Height, sName.s="")
  ; SCS wrapper for IPAddressGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  IPAddressGadget(nGadgetNo, X, Y, Width, Height)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsLineGadget(X, Y, Width, Height, nColor, flags=0, sName.s="")
  ; PB doesn't have a line gadget, and drawing a line using 2D drawing will not draw in a container, so use a TextGadget for the line
  ; (NB only horizontal or vertical 'lines' can be drawn this way, but that's all we need in SCS)
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  TextGadget(nGadgetNo, X, Y, Width, Height, "", flags)
  SetGadgetColor(nGadgetNo, #PB_Gadget_BackColor, nColor)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsListIconGadget(X, Y, Width, Height, Title$, TitleWidth, flags=0, sName.s="")
  ; SCS wrapper for ListIconGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ListIconGadget(nGadgetNo, X, Y, Width, Height, Title$, TitleWidth, flags)
  If gbShowToolTips
    SendMessage_(GadgetID(nGadgetNo), #LVM_SETEXTENDEDLISTVIEWSTYLE, #LVS_EX_LABELTIP, -1) ; causes values wider than the column width to be displayed as a tooltip
  EndIf
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsListViewGadget(X, Y, Width, Height, flags=0, sName.s="")
  ; SCS wrapper for ListViewGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ListViewGadget(nGadgetNo, X, Y, Width, Height, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsLoadImage(sFileName.s)
  PROCNAMEC()
  Protected nResult
  
  If FileExists(sFileName)
    gnNextImageNo + 1
    nResult = LoadImage(gnNextImageNo, sFileName)
    If nResult
      ProcedureReturn gnNextImageNo
    Else
      ProcedureReturn 0
    EndIf
  Else
    debugMsg(sProcName, "File " + #DQUOTE$ + sFileName + #DQUOTE$ + " does not exist")
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure scsMenuButtonGadget(X, Y, Width, Height, sText.s, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  PROCNAMEC()
  ; owner-drawn gadget for buttons that display pop-up menus
  ; partly based on code supplied by Michael Vogel on PB Forum, 26Jun2011
  Protected nMyImage, nTextHeight, nTextWidth
  Protected nLeft, nTop, nBorderWidth, nNextX
  
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ButtonImageGadget(nGadgetNo, X, Y, Width, Height, 0)
  
  nMyImage = CreateImage(#PB_Any, Width, Height, 32) ; | #PB_Image_Transparent)
  logCreateImage(120, nMyImage, -1, #SCS_VID_PIC_TARGET_NONE, "menu button image")
  If IsImage(nMyImage)
    If StartDrawing(ImageOutput(nMyImage))
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      nTextHeight = TextHeight("Wg")
      nTextWidth = TextWidth(sText+" ") + 6   ; 6 = width of down-pointing triangle, drawn later in this procedure
      If Height > nTextHeight
        nTop = (Height - nTextHeight) >> 1
      Else
        nTop = 0
      EndIf
      nBorderWidth = 5
      
      If flags & #PB_Button_Left
        nLeft = nBorderWidth
        
      ElseIf flags & #PB_Button_Right
        If Width > (nTextWidth + nBorderWidth)
          nLeft = (Width - (nTextWidth + nBorderWidth))
        Else
          nLeft = nBorderWidth
        EndIf
        
      Else  ; align center (default)
        If Width > nTextWidth
          nLeft = (Width - nTextWidth) >> 1
        Else
          nLeft = nBorderWidth
        EndIf
      EndIf
      
      DrawingMode(#PB_2DDrawing_AlphaChannel)
      Box(0,0,Width,Height,$00000000)
      
      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
      ; FrontColor($FF000000)
      FrontColor($FF333333) ; make the font grey rather than black as DrawText() doesn't draw as clearly as text normally shown on gadgets - grey text softens the contrast
      nNextX = DrawText(nLeft, nTop, sText+" ")
      ; draw down-pointing triangle
      nTop = ((Height - 4) >> 1) + 1
      ; debugMsg0(sProcName, "Width=" + Width + ", Height=" + Height + ", nNextX=" + nNextX + ", nTop=" + nTop)
      LineXY(nNextX+0, nTop+0, nNextX+6, nTop+0)  ; if you change the width of the triangle, also change the setting of nTextWidth earlier in this procedure
      LineXY(nNextX+1, nTop+1, nNextX+5, nTop+1)
      LineXY(nNextX+2, nTop+2, nNextX+4, nTop+2)
      Plot(nNextX+3, nTop+3)
      StopDrawing()
      SetGadgetAttribute(nGadgetNo, #PB_Button_Image, ImageID(nMyImage))
    EndIf
    
  Else
    DebugMsg(sProcName, "CreateImage() failed")
  EndIf
  
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsMenuItem(nMenuItemNo, sText.s, sShortcut.s="", bLookupMenuText=#True, nImageNo=0)
  ; SCS wrapper for MenuItem command
  PROCNAMEC()
  Protected sMyMenuText.s, sMyShortcut.s
  
  ; debugMsg(sProcName, "nMenuItemNo=" + nMenuItemNo + ", sText=" + sText + ", gbMenuItemAvailable(" + nMenuItemNo + ")=" + strB(gbMenuItemAvailable(nMenuItemNo)))
  If gbMenuItemAvailable(nMenuItemNo) = #False
    ; debugMsg(sProcName, "exiting because gbMenuItemAvailable(" + decodeMenuItem(nMenuItemNo) + ")=" + strB(gbMenuItemAvailable(nMenuItemNo)))
    ProcedureReturn
  EndIf
  
  If bLookupMenuText
    sMyMenuText = Lang("Menu", sText)
  Else
    sMyMenuText = sText
  EndIf
  sMyMenuText = ReplaceString(sMyMenuText, Chr(10), " ")  ; counter the effect of \n being translated to Chr(10) by Lang(), such as in "Pause\nAll"
  
  Select sShortcut
    Case "*E"
      sMyShortcut = getEditorShortcutStr(nMenuItemNo)
    Case "*M"
      sMyShortcut = getMainShortcutStr(nMenuItemNo)
    Default
      sMyShortcut = sShortcut
  EndSelect
  If sMyShortcut
    sMyMenuText + Chr(9) + sMyShortCut
  EndIf
  
  If (nImageNo <> 0) And (IsImage(nImageNo))
    MenuItem(nMenuItemNo, sMyMenuText, ImageID(nImageNo))
  Else
    MenuItem(nMenuItemNo, sMyMenuText)
  EndIf
  
EndProcedure

Procedure scsExplorerComboGadget(X, Y, Width, Height, sDirectory.s, flags=0, sName.s="")
  ; SCS wrapper for ExplorerComboGadget
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ExplorerComboGadget(nGadgetNo, X, Y, Width, Height, sDirectory, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsExplorerTreeGadget(X, Y, Width, Height, sDirectory.s, flags=0, sName.s="")
  ; SCS wrapper for ExplorerTreeGadget
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ExplorerTreeGadget(nGadgetNo, X, Y, Width, Height, sDirectory, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsExplorerListGadget(X, Y, Width, Height, sDirectory.s, flags=0, sName.s="")
  ; SCS wrapper for ExplorerListGadget
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ExplorerListGadget(nGadgetNo, X, Y, Width, Height, sDirectory, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsCueTypeMenuItem(sCueType.s, nMenuItemNo, sText.s, sShortCut.s="", bLookupMenuText=#True, nImageNo=0)
  PROCNAMEC()
  If isCueTypeAvailable(sCueType)
    scsMenuItem(nMenuItemNo, sText, sShortCut, bLookupMenuText, nImageNo)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure scsMenuItemFast(nMenuItemNo, sFastText.s, sShortCut.s="", nImageNo=0)
  ; SCS wrapper for MenuItem command using pre-loaded text
  PROCNAMEC()
  Protected sMyMenuText.s
  
  If gbMenuItemAvailable(nMenuItemNo) = #False
    ProcedureReturn
  EndIf
  
  sMyMenuText = ReplaceString(sFastText, Chr(10), " ")  ; counter the effect of \n being translated to Chr(10) by Lang(), such as in "Pause\nAll"
  
  If sShortCut
    sMyMenuText + Chr(9) + sShortCut
  EndIf
  
  If (nImageNo <> 0) And (IsImage(nImageNo))
    MenuItem(nMenuItemNo, sMyMenuText, ImageID(nImageNo))
  Else
    MenuItem(nMenuItemNo, sMyMenuText)
  EndIf
  
EndProcedure
  
Procedure scsOpenGadgetList(nGadgetNo, nGadgetItem=-1)
  ; SCS wrapper for OpenGadgetList command
  PROCNAMEC()
  
  If nGadgetItem = -1
    OpenGadgetList(nGadgetNo)
  Else
    OpenGadgetList(nGadgetNo, nGadgetItem)
  EndIf
  gnContainerLevel + 1
  gaContainerLevelGadgetNo(gnContainerLevel) = nGadgetNo
  CompilerIf #cTraceContainerGadgets
    traceContainerNoPosOrSize(nGadgetNo)
  CompilerEndIf
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, "nGadgetNo=G" + nGadgetNo + ", nGadgetItem=" + nGadgetItem + ", gnContainerLevel=" + gnContainerLevel)
  CompilerEndIf
EndProcedure

Procedure scsOptionGadget(X, Y, Width, Height, Text$, sName.s="")
  ; SCS wrapper for OptionGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  OptionGadget(nGadgetNo, X, Y, Width, Height, Text$)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsOptionGadget2(X, Y, Width, Height, Text$, sName.s="")
  ; owner-drawn option gadget to allow setting colors
  PROCNAMEC()
  Protected nGadgetPropsIndex, nImageNo
  Protected nMyWidth
  
  ; Width <= 0 causes auto-size
  If Width > 0
    nMyWidth = Width
  Else
    nMyWidth = 100
  EndIf
  
  Protected nGadgetNo = newGadget(sName, X, Y, nMyWidth, Height, #SCS_GTYPE_OPTION2)
  CanvasGadget(nGadgetNo, X, Y, nMyWidth, Height, 0)
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    With gaGadgetProps(nGadgetPropsIndex)
      \sText = Text$
      \nFlags = 0
      \bAllowEditorColors = #True
    EndWith
  EndIf
  drawOptionGadget2(nGadgetNo)
  If Width <= 0
    If nGadgetPropsIndex >= 0
      With gaGadgetProps(nGadgetPropsIndex)
        If \nReqdWidth > 16
          ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, \nReqdWidth, #PB_Ignore)
          gnNextX = GadgetX(nGadgetNo) + GadgetWidth(nGadgetNo)
        EndIf
      EndWith
    EndIf
  EndIf
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsPanelGadget(X, Y, Width, Height, sName.s="")
    PROCNAMEC()
  ; SCS wrapper for PanelGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height, #SCS_GTYPE_PANEL)
  PanelGadget(nGadgetNo, X, Y, Width, Height)
  gaGadgetProps(nGadgetNo-#SCS_GADGET_BASE_NO)\bAllowEditorColors=#True
  gnContainerLevel + 1
  gaContainerLevelGadgetNo(gnContainerLevel) = nGadgetNo
  CompilerIf #cTraceContainerGadgets
    traceContainer(nGadgetNo)
  CompilerEndIf
  ; debugMsg(sProcName,"gnContainerLevel=" + gnContainerLevel)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsProgressBarGadget(X, Y, Width, Height, Minimum, Maximum, flags=0, sName.s="")
  ; SCS wrapper for ProgressBarGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ProgressBarGadget(nGadgetNo, X, Y, Width, Height, Minimum, Maximum, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsShortcutGadget(X, Y, Width, Height, Shortcut=0, sName.s="")
  ; SCS wrapper for ShortcutGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ; use ShortcutGadgetEx provided by netmaestro as PB's shortcutGadget doesn't raise events for 'Enter' or 'Space' (or a number of other keys)
  ShortcutGadgetEx(nGadgetNo, X, Y, Width, Height, Shortcut)
  ; ShortcutGadget(nGadgetNo, X, Y, Width, Height, Shortcut)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsScrollAreaGadget(X, Y, Width, Height, ScrollAreaWidth, ScrollAreaHeight, ScrollStep, flags=0, sName.s="")
    PROCNAMEC()
  ; SCS wrapper for ScrollAreaGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, "sName=" + sName + ", X=" + X + ", Y=" + Y + ", Width=" + Width + ", Height=" + Height +
                          ", ScrollAreaWidth=" + ScrollAreaWidth + ", ScrollAreaHeight=" + ScrollAreaHeight + ", ScrollStep=" + ScrollStep)
  CompilerEndIf
  ScrollAreaGadget(nGadgetNo, X, Y, Width, Height, ScrollAreaWidth, ScrollAreaHeight, ScrollStep, flags)
  ; debugMsg("scsScrollAreaGadget", "ScrollAreaGadget(" + nGadgetNo + ", " + X + ", " + Y + ", " + Width + ", " + Height + ", " + ScrollAreaWidth + ", " + ScrollAreaHeight + ", " + ScrollStep + ", " + flags + ")")
  gaGadgetProps(nGadgetNo-#SCS_GADGET_BASE_NO)\bAllowEditorColors = #True
  gnContainerLevel + 1
  gaContainerLevelGadgetNo(gnContainerLevel) = nGadgetNo
  CompilerIf #cTraceContainerGadgets
    traceContainer(nGadgetNo)
  CompilerEndIf
  ; debugMsg(sProcName,"gnContainerLevel=" + (gnContainerLevel)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsScrollBarGadget(X, Y, Width, Height, Minimum, Maximum, PageLength, flags=0, sName.s="")
  PROCNAMEC()
  ; SCS wrapper for ScrollBarGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  ScrollBarGadget(nGadgetNo, X, Y, Width, Height, Minimum, Maximum, PageLength, flags)
  
  ; bug(?) in PB: PB seems to deduct 1 from Maximum (see my PB Forum posting, 23/02/2010)
  ; so check if this is the case and if so then reset the maximum 1 higher
  Protected nCurrMax, nDiff
  nCurrMax=GetGadgetAttribute(nGadgetNo, #PB_ScrollBar_Maximum)
  debugMsg(sProcName, "Maximum=" + Maximum + ", nCurrMax=" + nCurrMax)
  If nCurrMax <> Maximum
    nDiff = Maximum - nCurrMax
    debugMsg(sProcName, "nDiff=" + nDiff)
    SetGadgetAttribute(nGadgetNo, #PB_ScrollBar_Maximum, (Maximum + nDiff))
    nCurrMax=GetGadgetAttribute(nGadgetNo, #PB_ScrollBar_Maximum)
    debugMsg(sProcName, "(new) nCurrMax=" + nCurrMax)
  EndIf
  
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsSplitterGadget(X, Y, Width, Height, nGadget1, nGadget2, flags=0, sName.s="")
  ; SCS wrapper for SplitterGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  SplitterGadget(nGadgetNo, X, Y, Width, Height, nGadget1, nGadget2, flags)
  gaGadgetProps(nGadget1-#SCS_GADGET_BASE_NO)\nContainerGadgetNo = nGadgetNo
  gaGadgetProps(nGadget2-#SCS_GADGET_BASE_NO)\nContainerGadgetNo = nGadgetNo
  ProcedureReturn nGadgetNo
EndProcedure

; Added length parameter, Dee 24/03/2025. This should not affect old use cases.
Procedure scsStringGadget(X, Y, Width, Height, Content.s, flags=0, sName.s="", nGadgetNoForEvHdlr=0, nLength=0)
  ; SCS wrapper for StringGadget command
  Protected nGType = #SCS_GTYPE_STRING_ENTERABLE
  Protected nGadgetNo, nGadgetHeight
  Protected sTempString.s
 
  If flags & #PB_String_ReadOnly
    nGType = #SCS_GTYPE_STRING_READONLY
  EndIf
    
  If Height = -1
    nGadgetHeight = 20 ; default height for string gadget as at 13Oct2020 11.8.3.2bp (was previously 21)
  Else
    nGadgetHeight = Height
  EndIf
  
  If nLength <> 0
    sTempString = Left(Content, nLength)
  EndIf
    
  nGadgetNo = newGadget(sName, X, Y, Width, nGadgetHeight, nGType, nGadgetNoForEvHdlr)
  StringGadget(nGadgetNo, X, Y, Width, nGadgetHeight, sTempString, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsTextGadget(X, Y, Width, Height, Text.s, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for TextGadget command
  Protected nGadgetNo, nGadgetHeight
  
  If Height = -1
    nGadgetHeight = 15 ; default height for text gadget
  Else
    nGadgetHeight = Height
  EndIf
  
  nGadgetNo = newGadget(sName, X, Y, Width, nGadgetHeight, #SCS_GTYPE_TEXT, nGadgetNoForEvHdlr)
  TextGadget(nGadgetNo, X, Y, Width, nGadgetHeight, Text, flags)
  gaGadgetProps(nGadgetNo-#SCS_GADGET_BASE_NO)\bAllowEditorColors = #True
  ProcedureReturn nGadgetNo
EndProcedure

Procedure modTextGadget(X, Y, Width, Height, Text.s, flags=0, sName.s="", nGadgetNoForEvHdlr=0)
  ; SCS wrapper for TextEx::Gadget command
  Protected nGadgetNo, nGadgetHeight
  If Height = -1
    nGadgetHeight = 15 ; default height for text gadget
  Else
    nGadgetHeight = Height
  EndIf
  nGadgetNo = newGadget(sName, X, Y, Width, nGadgetHeight, #SCS_GTYPE_TEXT, nGadgetNoForEvHdlr, #SCS_MG_TEXT)
  TextEx::Gadget(nGadgetNo, X, Y, Width, nGadgetHeight, Text, flags)
  gaGadgetProps(nGadgetNo-#SCS_GADGET_BASE_NO)\bAllowEditorColors = #True
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsTrackBarGadget(X, Y, Width, Height, Minimum, Maximum, flags=0, sName.s="")
  ; SCS wrapper for TrackBarGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  TrackBarGadget(nGadgetNo, X, Y, Width, Height, Minimum, Maximum, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsTreeGadget(X, Y, Width, Height, flags=0, sName.s="")
  ; SCS wrapper for TreeGadget command
  Protected nGadgetNo = newGadget(sName, X, Y, Width, Height)
  TreeGadget(nGadgetNo, X, Y, Width, Height, flags)
  ProcedureReturn nGadgetNo
EndProcedure

Procedure scsStandardButton(X, Y, Width, Height, nButtonType, sName.s="", bUseSmall=#False)
  PROCNAMEC()
  Protected hEnabled, hDisabled, nButton
  Protected nGadgetPropsIndex, sToolTip.s
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_REWIND
      hEnabled = hTrRewindEn
      hDisabled = hTrRewindDi
      sToolTip = Lang("Btns","RewindTT")
    Case #SCS_STANDARD_BTN_PLAY
      hEnabled = hTrPlayEn
      hDisabled = hTrPlayDi
      sToolTip = Lang("Btns","PlayTT")
    Case #SCS_STANDARD_BTN_PAUSE
      hEnabled = hTrPauseEn
      hDisabled = hTrPauseDi
      sToolTip = Lang("Btns","PauseTT")
    Case #SCS_STANDARD_BTN_RELEASE
      hEnabled = hTrReleaseEn
      hDisabled = hTrReleaseDi
      sToolTip = Lang("Btns","ReleaseTT")
    Case #SCS_STANDARD_BTN_FADEOUT
      hEnabled = hTrFadeOutEn
      hDisabled = hTrFadeOutDi
      sToolTip = Lang("Btns","FadeOutTT")
    Case #SCS_STANDARD_BTN_STOP
      hEnabled = hTrStopEn
      hDisabled = hTrStopDi
      sToolTip = Lang("Btns","StopTT")
    Case #SCS_STANDARD_BTN_SHUFFLE
      hEnabled = hTrShuffleEn
      hDisabled = hTrShuffleDi
      sToolTip = Lang("Btns","ShuffleTT")
    Case #SCS_STANDARD_BTN_MOVE_UP
      If bUseSmall
        hEnabled = hMiMoveUpSmallEn
        hDisabled = hMiMoveUpSmallDi
      Else
        hEnabled = hSbMoveUpEn
        hDisabled = hSbMoveUpDi
      EndIf
    Case #SCS_STANDARD_BTN_MOVE_DOWN
      If bUseSmall
        hEnabled = hMiMoveDownSmallEn
        hDisabled = hMiMoveDownSmallDi
      Else
        hEnabled = hSbMoveDownEn
        hDisabled = hSbMoveDownDi
      EndIf
    Case #SCS_STANDARD_BTN_MOVE_LEFT
      hEnabled = hSbMoveLeftEn
      hDisabled = hSbMoveLeftDi
    Case #SCS_STANDARD_BTN_MOVE_RIGHT
      hEnabled = hSbMoveRightEn
      hDisabled = hSbMoveRightDi
    Case #SCS_STANDARD_BTN_MOVE_RIGHT_UP
      hEnabled = hSbMoveRightUpEn
      hDisabled = hSbMoveRightUpDi
    Case #SCS_STANDARD_BTN_EXPAND_ALL
      hEnabled = hSbExpAllEn
      hDisabled = hSbExpAllDi
      sToolTip = Lang("Btns","ExpandAllTT")
    Case #SCS_STANDARD_BTN_COLLAPSE_ALL
      hEnabled = hSbColAllEn
      hDisabled = hSbColAllDi
      sToolTip = Lang("Btns","CollapseAllTT")
    Case #SCS_STANDARD_BTN_CUT
      hEnabled = hSbCutEn
      hDisabled = hSbCutDi
    Case #SCS_STANDARD_BTN_COPY
      hEnabled = hSbCopyEn
      hDisabled = hSbCopyDi
    Case #SCS_STANDARD_BTN_PASTE
      hEnabled = hSbPasteEn
      hDisabled = hSbPasteDi
    Case #SCS_STANDARD_BTN_DELETE
      hEnabled = hSbDeleteEn
      hDisabled = hSbDeleteDi
    Case #SCS_STANDARD_BTN_PLUS
      If bUseSmall
        hEnabled = hMiPlusSmallEn
        hDisabled = hMiPlusSmallDi
      Else
        hEnabled = hSbPlusEn
        hDisabled = hSbPlusDi
      EndIf
    Case #SCS_STANDARD_BTN_MINUS
      If bUseSmall
        hEnabled = hMiMinusSmallEn
        hDisabled = hMiMinusSmallDi
      Else
        hEnabled = hSbMinusEn
        hDisabled = hSbMinusDi
      EndIf
    Case #SCS_STANDARD_BTN_FIND
      hEnabled = hSbFindEn
      hDisabled = hSbFindDi
      sToolTip = Lang("Btns","FindTT")
    Case #SCS_STANDARD_BTN_COPY_PROPS
      hEnabled = hSbCopyPropsEn
      hDisabled = hSbCopyPropsDi
      sToolTip = Lang("Btns","CopyPropsTT")
    Case #SCS_STANDARD_BTN_FIRST
      hEnabled = hTrFirstEn
      hDisabled = hTrFirstDi
      sToolTip = Lang("Btns","FirstTT")
    Case #SCS_STANDARD_BTN_LAST
      hEnabled = hTrLastEn
      hDisabled = hTrLastDi
      sToolTip = Lang("Btns","LastTT")
    Case #SCS_STANDARD_BTN_PREV
      hEnabled = hTrPrevEn
      hDisabled = hTrPrevDi
      sToolTip = Lang("Btns","PrevTT")
    Case #SCS_STANDARD_BTN_NEXT
      hEnabled = hTrNextEn
      hDisabled = hTrNextDi
      sToolTip = Lang("Btns","NextTT")
    Case #SCS_STANDARD_BTN_TICK
      hEnabled = hMiTickEn
      hDisabled = hMiTickDi
    Case #SCS_STANDARD_BTN_CROSS
      hEnabled = hMiCrossEn
      hDisabled = hMiCrossDi
  EndSelect
  
  nButton = scsButtonImageGadget(X, Y, Width, Height, ImageID(hEnabled), 0, sName)
  nGadgetPropsIndex = getGadgetPropsIndex(nButton)
  With gaGadgetProps(nGadgetPropsIndex)
    \nButtonType = nButtonType
    \nToolBarBtnId = nButtonType
    \hImageEn = hEnabled
    \hImageDi = hDisabled
  EndWith
  If sToolTip
    scsToolTip(nButton, sToolTip)
  EndIf
  
  ProcedureReturn nButton
EndProcedure

Procedure redrawCvsBtn(nButton)
  PROCNAMEC()
  Protected nPropsIndex, hImage
  
  nPropsIndex = getGadgetPropsIndex(nButton)
  With gaGadgetProps(nPropsIndex)
    If \bEnabled
      If \bMouseOver
        hImage = \hImageMo
      Else
        hImage = \hImageEn
      EndIf
    Else
      hImage = \hImageDi
    EndIf
    If StartDrawing(CanvasOutput(nButton))
      DrawImage(ImageID(hImage),0,0)
      StopDrawing()
    EndIf
  EndWith
EndProcedure

Procedure scsStandardCanvasButton(X, Y, Width, Height, nButtonType, sName.s="")
  PROCNAMEC()
  Protected hEnabled, hDisabled, hMouseOver, nButton
  Protected nGadgetPropsIndex, sToolTip.s
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_REWIND
      hEnabled = hTrRewindEn13
      hDisabled = hTrRewindDi13
      hMouseOver = hTrRewindMo13
      sToolTip = Lang("Btns","RewindTT")
    Case #SCS_STANDARD_BTN_PLAY
      hEnabled = hTrPlayEn13
      hDisabled = hTrPlayDi13
      hMouseOver = hTrPlayMo13
      sToolTip = Lang("Btns","PlayTT")
    Case #SCS_STANDARD_BTN_PAUSE
      hEnabled = hTrPauseEn13
      hDisabled = hTrPauseDi13
      hMouseOver = hTrPauseMo13
      sToolTip = Lang("Btns","PauseTT")
    Case #SCS_STANDARD_BTN_RELEASE
      hEnabled = hTrReleaseEn13
      hDisabled = hTrReleaseDi13
      hMouseOver = hTrReleaseMo13
      sToolTip = Lang("Btns","ReleaseTT")
    Case #SCS_STANDARD_BTN_FADEOUT
      hEnabled = hTrFadeOutEn13
      hDisabled = hTrFadeOutDi13
      hMouseOver = hTrFadeOutMo13
      sToolTip = Lang("Btns","FadeOutTT")
    Case #SCS_STANDARD_BTN_STOP
      hEnabled = hTrStopEn13
      hDisabled = hTrStopDi13
      hMouseOver = hTrStopMo13
      sToolTip = Lang("Btns","StopTT")
    Case #SCS_STANDARD_BTN_SHUFFLE
      hEnabled = hTrShuffleEn13
      hDisabled = hTrShuffleDi13
      hMouseOver = hTrShuffleMo13
      sToolTip = Lang("Btns","ShuffleTT")
    Case #SCS_STANDARD_BTN_FIRST
      hEnabled = hTrFirstEn13
      hDisabled = hTrFirstDi13
      hMouseOver = hTrFirstMo13
      sToolTip = Lang("Btns","FirstTT")
  EndSelect
  
  nButton = scsCanvasGadget(X, Y, Width, Height, 0, sName)
  nGadgetPropsIndex = getGadgetPropsIndex(nButton)
  With gaGadgetProps(nGadgetPropsIndex)
    \nButtonType = nButtonType
    \nToolBarBtnId = nButtonType
    \hImageEn = hEnabled
    \hImageDi = hDisabled
    \hImageMo = hMouseOver
    \bStandardCanvasButton = #True
  EndWith
  If sToolTip
    scsToolTip(nButton, sToolTip)
  EndIf
  redrawCvsBtn(nButton)
  
  ProcedureReturn nButton
EndProcedure

Procedure setCurrWindowGlobals(nWindowNo)
  gnCurrentWindowNo = nWindowNo
  gsCurrentWindow = RemoveString(decodeWindow(nWindowNo), "#")
EndProcedure

Procedure registerWindow(nWindowNo, sWindowName.s, nParentWindow=0)
  PROCNAMECW(nWindowNo)
  
  debugMsg(sProcName, "creating window " + sWindowName + " in thread " + gnThreadNo)
  ASSERT_THREAD(#SCS_THREAD_MAIN)   ; ALL windows must be created by the main thread
  
  With gaWindowProps(nWindowNo)
    \sName = sWindowName
    \nOrigLeft = WindowX(nWindowNo)
    \nOrigTop = WindowY(nWindowNo)
    \nOrigWidth = WindowWidth(nWindowNo)
    \nOrigHeight = WindowHeight(nWindowNo)
    \nParentWindow = nParentWindow
    setCurrWindowGlobals(nWindowNo)
    If nWindowNo = #WMN
      gnCurrentCuePanelNo = -1
      gnCurrentSliderNo = -1
      gnContainerLevel = 0
    EndIf
    ; Debug "gaWindowProps(" + nWindowNo + ")\sName=" + \sName + ", \nOrigHeight=" + \nOrigHeight + ", \nOrigWidth=" + \nOrigWidth
  EndWith
EndProcedure

Procedure registerGrid(*pGridInfo.tyGridInfo, nGadgetNo, nGridType, sColTypes.s)
  PROCNAMEC()
  Protected n, sMsg.s, sOneColType.s, nMyMaxColNo
  Protected nColIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  nMyMaxColNo = CountString(sColTypes, ",")
  
  With *pGridInfo
    ; register the grid
    \nGadgetNo = nGadgetNo              ; gadget no. of the grid
    \nMaxColNo = nMyMaxColNo            ; max possible colno for this table
    \nMaxVisibleColNo = -1              ; max colno currently visible
    ; DO NOT clear \sLayoutString as this may have been set in a loadPrefs...() proceure
    
    ReDim \aCol(\nMaxColNo)
    ; initialise array
    For n = 0 To \nMaxColNo
      \aCol(n)\sTitle = ""              ; column title
      \aCol(n)\nDefColNo = -1           ; default PB column number of this column (-1 if not visible)
      \aCol(n)\nIniColNo = -1           ; initial PB column number of this column (when WMN_setupGrid(), or equivalent for other grids, was first executed this session)
      \aCol(n)\nCurColNo = -1           ; current PB column number of this column (when WMN_setupGrid(), or equivalent for other grids, was last executed)
      \aCol(n)\nDefWidth = 0            ; default width of this column
      \aCol(n)\nIniWidth = 0            ; initial width of this column (this session)
      \aCol(n)\nCurWidth = 0            ; current width of this column
      \aCol(n)\nCurColOrder = -1        ; current physical position of this column - set the same as nCurcolNo by WMN_setupGrd() or equivalent, but reset by updateGridInfoFromPhysicalLayout()
      \aCol(n)\bColVisible = #False     ; indicates if column is currently visible
    Next n
    
    ; now register the columns
    For n = 0 To nMyMaxColNo
      sOneColType = Trim(StringField(sColTypes, (n+1), ","))
      nColIndex = getIndexForColType(nGridType, sOneColType)
      If nColIndex >= 0
        \aCol(nColIndex)\sColType = sOneColType   ; 2-character column type as held externally, eg in layout definition in the preferences files
      EndIf
    Next n
    
  EndWith
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure addGadgetItemWithData(nGadgetNo, sText.s, nData)
  Select getModGadgetType(nGadgetNo)
    Case #SCS_MG_COMBOBOX
      ComboBoxEx::AddItem(nGadgetNo, ComboBoxEx::#LastItem, sText)
      ComboBoxEx::SetItemData(nGadgetNo, ComboBoxEx::CountItems(nGadgetNo)-1, nData)
    Default
      AddGadgetItem(nGadgetNo, -1, sText)
      SetGadgetItemData(nGadgetNo, CountGadgetItems(nGadgetNo)-1, nData)
  EndSelect
EndProcedure

Procedure setVisibleAndEnabled(nGadgetNo, bVisibleAndEnabled)
  ; PROCNAMEC()
  setVisible(nGadgetNo, bVisibleAndEnabled)
  setEnabled(nGadgetNo, bVisibleAndEnabled)
EndProcedure

Procedure autoFitGridCol(nGadgetNo, nColNo=-1)
  PROCNAMECG(nGadgetNo)
  Protected nReqdColNo, nReqdColCurrWidth, nReqdColNewWidth, n
  Protected nColCount, nMaxColNo
  Protected nColWidth, nTotalColWidth
  Protected nVScrollWidth
  Protected nAvailableWidth
  Protected Dim aNewColWidth(0)
  Protected nNewTotalColWidth, nIterations
  
  If (GetWindowLongPtr_(GadgetID(nGadgetNo), #GWL_STYLE) & #WS_VSCROLL) <> 0
    nVScrollWidth = glScrollBarWidth
  EndIf
  nAvailableWidth = GadgetWidth(nGadgetNo) - nVScrollWidth - gl3DBorderAllowanceX ; - gl3DBorderAllowanceX
  ; debugMsg(sProcName, "nVScrollWidth=" + nVScrollWidth + ", gadgetWidth=" + GadgetWidth(nGadgetNo) + ", nAvailableWidth=" + nAvailableWidth)
  
  nColCount = getGadgetColumnCount(nGadgetNo)
  If nColCount = 0
    ProcedureReturn
  EndIf
  
  nMaxColNo = nColCount - 1
  doReDim(aNewColWidth, nMaxColNo, "aNewColWidth()")
  
  For n = 0 To nMaxColNo
    nColWidth = GetGadgetItemAttribute(nGadgetNo, 0, #PB_ListIcon_ColumnWidth, n)
    ; debugMsg(sProcName, "G" + nGadgetNo + " column " + n + " width = " + Str(nColWidth))
    aNewColWidth(n) = nColWidth
    nTotalColWidth + nColWidth
    If (nColNo >= 0) And (n = nColNo)
      ; required column is specified column
      nReqdColNo = n
      nReqdColCurrWidth = nColWidth
    ElseIf (nColNo = -1) And (nColWidth > nReqdColCurrWidth)
      ; required column is widest column
      nReqdColNo = n
      nReqdColCurrWidth = nColWidth
    ElseIf (nColNo = -2) And (n = nMaxColNo)
      ; required column is last column
      nReqdColNo = n
      nReqdColCurrWidth = nColWidth
    EndIf
  Next n
  ; debugMsg(sProcName, "nTotalColWidth=" + Str(nTotalColWidth) + ", nReqdColNo=" + Str(nReqdColNo) + ", nReqdColCurrWidth=" + Str(nReqdColCurrWidth))
  
  If nTotalColWidth < nAvailableWidth
    nReqdColNewWidth = nReqdColCurrWidth + (nAvailableWidth - nTotalColWidth)
    ; debugMsg(sProcName, "nReqdColNewWidth=" + Str(nReqdColNewWidth))
    SetGadgetItemAttribute(nGadgetNo, 0, #PB_ListIcon_ColumnWidth, nReqdColNewWidth, nReqdColNo)
    
  ElseIf nTotalColWidth > nAvailableWidth
    nReqdColNewWidth = nReqdColCurrWidth + (nAvailableWidth - nTotalColWidth)
    debugMsg(sProcName, "nReqdColNewWidth=" + Str(nReqdColNewWidth))
    If nReqdColNewWidth >= 20
      ; required new width >= the arbitrarily-defined 'minimum' width (20 pixels)
      SetGadgetItemAttribute(nGadgetNo, 0, #PB_ListIcon_ColumnWidth, nReqdColNewWidth, nReqdColNo)
    Else
      ; otherwise scale back all column widths
      While (nTotalColWidth > nAvailableWidth) And (nIterations < 4)  ; iteration limit prevents looping if cannot resolve widths
        nNewTotalColWidth = 0
        For n = 0 To nMaxColNo
          nColWidth = Round((aNewColWidth(n) * nAvailableWidth) / nTotalColWidth, #PB_Round_Nearest)
          If nColWidth < 20
            nColWidth = 20
          EndIf
          aNewColWidth(n) = nColWidth
          nNewTotalColWidth + nColWidth
        Next n
        nTotalColWidth = nNewTotalColWidth
        nIterations + 1
      Wend
      For n = 0 To nMaxColNo
        nColWidth = aNewColWidth(n)
        ; debugMsg(sProcName, "calling SetGadgetItemAttribute(G" + nGadgetNo + ", 0, #PB_ListIcon_ColumnWidth, " + Str(nColWidth) + ", " + n + ")")
        SetGadgetItemAttribute(nGadgetNo, 0, #PB_ListIcon_ColumnWidth, nColWidth, n)
      Next n
    EndIf
  EndIf
  
EndProcedure

Procedure scsCloseWindow(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected n, nMyWindowNo
  Protected nGadgetPropsIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  If IsWindow(nWindowNo)
    CloseWindow(nWindowNo)
  EndIf
  
  ; now disassociate gadget properties
  For n = #SCS_GADGET_BASE_NO+1 To gnMaxGadgetNo
    nGadgetPropsIndex = getGadgetPropsIndex(n)
    With gaGadgetProps(nGadgetPropsIndex)
      ; debugMsg(sProcName, "n=" + n + ", nGadgetPropsIndex=" + Str(nGadgetPropsIndex) + ", \sName=" + \sName)
      If \nGWindowNo = nWindowNo
        \nGWindowNo = -1   ; dis-associate with the window
      EndIf
    EndWith
  Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkSaveToBeEnabled()
  PROCNAMEC()
  ; return value: 0 = save not to be enabled
  ;               1 = save to be enabled; save reason not to be enabled
  ;               2 = save and save reason to be enabled
  ;               3 = 'save always on' but no other reason found
  ; See also listReasonsForSave (in aaMain.pbi). These two procedures should contain the same tests.
  Protected nEnableSave
  
  ; debugMsg(sProcName, #SCS_START + ", gbNewCueFile=" + strB(gbNewCueFile))
  ; debugMsg(sProcName, "grCtrlSetup\bDataChanged=" + strB(grCtrlSetup\bDataChanged))
  
  If gbEditorAndOptionsLocked Or grLicInfo\bPlayOnly
    nEnableSave = 0
    
  ElseIf (gbUnsavedRecovery) Or (gbImportedCues) Or (gbAudioFileOrPathChanged) Or (gbSCSVersionChanged) Or (gnUnsavedEditorGraphs) Or (gbUnsavedVideoImageData) Or (gbNewCueFile) Or (gbUnsavedPlaylistOrderInfo)
    nEnableSave = 21
    
  ElseIf changedSinceLastSave()
    ; debugMsg(sProcName, "changedSinceLastSave() returned #True")
    nEnableSave = 22
    
  ElseIf (grCtrlSetup\bDataChanged) Or (WCN\bEQChanged)
    ; debugMsg(sProcName, "grCtrlSetup\bDataChanged=" + strB(grCtrlSetup\bDataChanged) + ", WCN\bEQChanged=" + strB(WCN\bEQChanged))
    nEnableSave = 23
    
  ElseIf grWVP\bReadyToSaveToCueFile
    nEnableSave = 24
    
  ElseIf grEditingOptions\bSaveAlwaysOn
    nEnableSave = 3
    
  ElseIf grProd\nMidiFreeConvertedToNrpn > 0 Or grProd\nMidiCCsConvertedToNRPN > 0
    nEnableSave = 25
    
  Else
    nEnableSave = 0
    
  EndIf
  
;   If nEnableSave <> 0
;     debugMsg(sProcName, "nEnableSave=" + nEnableSave)
;   EndIf
  
  ProcedureReturn nEnableSave
  
EndProcedure

Procedure centreForm(hWindow)
  PROCNAME(#PB_Compiler_Procedure + "[" + decodeWindow(hWindow) + "]")
  Protected nLeft, nTop, nWidth, nHeight
  Protected rWorkArea.RECT
  Protected nCaptionHeight, nBorderHeight, nMaxWindowHeight, nMaxWindowWidth
  
  debugMsg(sProcName, #SCS_START)
  
  SystemParametersInfo_(#SPI_GETWORKAREA, 0, @rWorkArea, 0)
  nCaptionHeight = GetSystemMetrics_(#SM_CYCAPTION)
  nBorderHeight = GetSystemMetrics_(#SM_CYFIXEDFRAME)
  nMaxWindowHeight = rWorkArea\bottom - rWorkArea\top - nCaptionHeight - (nBorderHeight * 2) - 7
  nMaxWindowWidth = rWorkArea\right - rWorkArea\left ; - nCaptionHeight - (nBorderHeight * 2) - 7
  ; debugMsg(sProcName, "nCaptionHeight=" + Str(nCaptionHeight) + ", nBorderHeight=" + Str(nBorderHeight) + ", nMaxWindowHeight=" + Str(nMaxWindowHeight))
  
  nWidth = WindowWidth(hWindow)
  nHeight = WindowHeight(hWindow)
  
  If hWindow = #WED
    If nWidth > nMaxWindowWidth
      nWidth = nMaxWindowWidth
    EndIf
    If nHeight > nMaxWindowHeight
      nHeight = nMaxWindowHeight
    EndIf
  EndIf
  
  nLeft = (nMaxWindowWidth >> 1) - (nWidth >> 1)
  nTop = (nMaxWindowHeight >> 1) - (nHeight >> 1)
  ; ensure top-left of window is visible! (encountered issue with editor window when display size set to 140%)
  If nLeft < 0
    nLeft = 0
  EndIf
  If nTop < 0
    nTop = 0
  EndIf
  
  ResizeWindow(hWindow, nLeft, nTop, nWidth, nHeight)
  debugMsg(sProcName, "ResizeWindow(" + decodeWindow(hWindow) + ", " + nLeft + ", " + nTop + ", " + nWidth + ", " + nHeight + ")")
  
EndProcedure

Procedure getFormPosition(hWindow, *rWindowInfo.tyWindow, bSetSize=#False)
  PROCNAMEC()
  Protected sPrefString.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  ; debugMsg(sProcName, #SCS_START + ", hWindow=" + decodeWindow(hWindow) + ", bSetSize=" + strB(bSetSize))
  
  If GetWindowState(hWindow) = #PB_Window_Minimize
    ProcedureReturn
  EndIf
  
  ; form positions and sizes saved for DPI = 100%
  
  With *rWindowInfo
    
    ; debugMsg(sProcName, "\sPrefKey=" + \sPrefKey)
    If GetWindowState(hWindow) = #PB_Window_Maximize
      \bMaximized = #True
      \nLeft = WindowX(hWindow, #PB_Window_InnerCoordinate)
      debugMsg(sProcName, "WindowX(" + decodeWindow(hWindow) + ")=" + WindowX(hWindow) + ", WindowX(" + decodeWindow(hWindow) + ", #PB_Window_FrameCoordinate)=" + WindowX(hWindow, #PB_Window_FrameCoordinate) +
                          ", WindowX(" + decodeWindow(hWindow) + ", #PB_Window_InnerCoordinate)=" + WindowX(hWindow, #PB_Window_InnerCoordinate) + ", \nLeft=" + \nLeft)
      \nTop = WindowY(hWindow, #PB_Window_InnerCoordinate)
      debugMsg(sProcName, "WindowY(" + decodeWindow(hWindow) + ")=" + WindowY(hWindow) + ", WindowY(" + decodeWindow(hWindow) + ", #PB_Window_FrameCoordinate)=" + WindowY(hWindow, #PB_Window_FrameCoordinate) +
                          ", WindowY(" + decodeWindow(hWindow) + ", #PB_Window_InnerCoordinate)=" + WindowY(hWindow, #PB_Window_InnerCoordinate) + ", \nTop=" + \nTop)
      If (\nLeft < 0) And (\nLeft >= -120)
        \nLeft = 0
      EndIf
      If (\nTop < 0) And (\nTop >= -120)
        \nTop = 0
      EndIf
      \bPositionSet = #True
    Else
      \bMaximized = #False
      \nLeft = WindowX(hWindow)
      \nTop = WindowY(hWindow)
      ; debugmsg(sProcName, "\nLeft=" + Str(\nLeft) + "\nTop=" + Str(\nTop))
      If (\nLeft = \nCenteredLeft) And (\nTop = \nCenteredTop)
        \bPositionSet = #False
      Else
        \bPositionSet = #True
      EndIf
      
      \bSizeSet = bSetSize
      If bSetSize
        \nWidth = WindowWidth(hWindow)
        \nHeight = WindowHeight(hWindow)
      Else
        \nWidth = -1
        \nHeight = -1
      EndIf
    EndIf
    
    ; copied from savePreferencesForWindow() - which is now obsolete
    If \bMaximized
      sPrefString = "Max;" + Str(\nLeft) + ";" + Str(\nTop)
    ElseIf bSetSize
      sPrefString = Str(\nLeft) + ";" + Str(\nTop) + ";" + Str(\nWidth) + ";" + Str(\nHeight)
    ElseIf \bPositionSet
      sPrefString = Str(\nLeft) + ";" + Str(\nTop)
    EndIf
    ; debugMsg(sProcName, "sPrefString=" + sPrefString)
    
    If (#cTutorialVideoOrScreenShots = #False Or \sPrefKey = "DMXDisplay" Or \sPrefKey = "Editor" Or \sPrefKey = "VSTPlugin")
      COND_OPEN_PREFS("Windows_" + gsMonitorKey)
      If sPrefString
        ; debugMsg(sProcName, "calling WritePreferenceString(" + \sPrefKey + ", " + sPrefString + ")")
        WritePreferenceString(\sPrefKey, sPrefString)
      Else
        ; debugMsg(sProcName, "calling RemovePreferenceKey(" + \sPrefKey + ")")
        RemovePreferenceKey(\sPrefKey)
      EndIf
      COND_CLOSE_PREFS()
    EndIf
    
  EndWith
  
EndProcedure

Procedure calcTextWidth(nWindowNo, nGadgetNo, sValue.s)
  PROCNAMEC()
  Protected sTmp.s, nLen
  
  nLen = GadgetWidth(nGadgetNo)
  If StartDrawing(WindowOutput(nWindowNo))
    DrawingFont(GetGadgetFont(nGadgetNo))
    nLen = TextWidth(sValue)
    StopDrawing()
  EndIf
  
  ProcedureReturn nLen
  
EndProcedure

Procedure getMaxTextWidth(nMinWidth, sText1.s, sText2.s="", sText3.s="", sText4.s="", nFontNo=#SCS_FONT_GEN_NORMAL)
  PROCNAMEC()
  Protected nTextWidth, nMaxTextWidth
  
  nMaxTextWidth = nMinWidth
  nTextWidth = GetTextWidth(sText1, nFontNo)
  ; debugMsg(sProcName, "sText1=" + #DQUOTE$ + sText1 + #DQUOTE$ + ", nTextWidth=" + nTextWidth)
  If nTextWidth > nMaxTextWidth
    nMaxTextWidth = nTextWidth
  EndIf
  If sText2
    nTextWidth = GetTextWidth(sText2, nFontNo)
    ; debugMsg(sProcName, "sText2=" + #DQUOTE$ + sText2 + #DQUOTE$ + ", nTextWidth=" + nTextWidth)
    If nTextWidth > nMaxTextWidth
      nMaxTextWidth = nTextWidth
    EndIf
  EndIf
  If sText3
    nTextWidth = GetTextWidth(sText3, nFontNo)
    If nTextWidth > nMaxTextWidth
      nMaxTextWidth = nTextWidth
    EndIf
  EndIf
  If sText4
    nTextWidth = GetTextWidth(sText4, nFontNo)
    If nTextWidth > nMaxTextWidth
      nMaxTextWidth = nTextWidth
    EndIf
  EndIf
  ; debugMsg(sProcName, "nMaxTextWidth=" + nMaxTextWidth)
  ProcedureReturn nMaxTextWidth
EndProcedure

Procedure getMonitorNrForXY(X, Y)
  ; PROCNAMEC()
  Protected nMonitorNr, n
  
  nMonitorNr = -1
  ; nb returns -1 if X, Y not found on any available monitor
  For n = 1 To gnMonitors
    With gaMonitors(n)
      If (X >= \nDesktopLeft) And (X < (\nDesktopLeft + \nDesktopWidth))
        If (Y >= \nDesktopTop) And (Y < (\nDesktopTop + \nDesktopHeight))
          nMonitorNr = n
          Break
        EndIf
      EndIf
    EndWith
  Next n
  ; debugMsg(sProcName, "X=" + X + ", Y=" + Y + ", nMonitorNr=" + nMonitorNr)
  ProcedureReturn nMonitorNr
EndProcedure

Procedure setFormPosition(hWindow, *rWindowInfo.tyWindow, nTotalWidthOfWindows=-1, bAllowCrossMonitor=#False)
  PROCNAMECW(hWindow)
  ; nb nTotalWidthOfWindows only required for video window (#WV2) and gives the total width of #WV2 to the last #WVn window created
  ; this is to enable setFormPosition() to ensure that all #WVn windows are fully enclosed in the viewable area (of the primary monitor)
  Protected n, nWindowState
  Protected nViewableLeft, nViewableTop, nViewableWidth, nViewableHeight
  Protected nReqdLeft, nReqdTop, nReqdWidth, nReqdHeight
  Protected bCenterForm, bCheckPos
  Protected nMonitorNr
  Protected sWindow.s
  Protected bTrace=#True
  
  debugMsgC(sProcName, #SCS_START + ", nTotalWidthOfWindows=" + nTotalWidthOfWindows + ", gnMonitors=" + gnMonitors)
  
  sWindow = decodeWindow(hWindow)
  
  For n = 1 To gnMonitors
    With gaMonitors(n)
      If \nDesktopLeft < nViewableLeft
        nViewableLeft = \nDesktopLeft
      EndIf
      If \nDesktopTop < nViewableTop
        nViewableTop = \nDesktopTop
      EndIf
      nViewableWidth + \nDesktopWidth
      nViewableHeight + \nDesktopHeight
    EndWith
  Next n
  
  With *rWindowInfo
    
    debugMsgC(sProcName, "nViewableLeft=" + nViewableLeft + ", nViewableTop=" + nViewableTop + ", nViewableWidth=" + nViewableWidth + ", nViewableHeight=" + nViewableHeight + ",\bMaximized=" + strB(\bMaximized))
    If (hWindow = #WMN) And (#c1280x720 Or #c1600x900)
      If (\bPositionSet) And (\nLeft <> -1)
        nReqdLeft = \nLeft
        nReqdTop = \nTop
      Else
        nReqdLeft = 0
        nReqdTop = 0
      EndIf
      If #c1280x720
        nReqdWidth = 1280
        nReqdHeight = 720 - 32 ; 32 is the height of the Windows title bar. This can also be obtained dynamically but is quite complicated to do so. Since this is only required for creating video tutorials then hard-coding the height should be OK.
                               ; See also https://learn.microsoft.com/en-us/windows/apps/design/basics/titlebar-design
      ElseIf #c1600x900
        nReqdWidth = 1600
        nReqdHeight = 900 - 32
      EndIf
      ; nReqdWidth = 1920
      ; nReqdHeight = 1080 - 32
      bCheckPos = #True
      
    ElseIf \bMaximized
      nReqdLeft = WindowX(hWindow)
      nReqdTop = WindowY(hWindow)
      If (\bPositionSet) And (\nLeft <> -1)
        nReqdLeft = \nLeft
        nReqdTop = \nTop
        bCheckPos = #True
      EndIf
      
    Else
      
      ; debugMsgC(sProcName, "\bPositionSet=" + strB(\bPositionSet))
      If \bPositionSet = #False
        bCenterForm = #True
        
      Else
        nReqdLeft = WindowX(hWindow)
        nReqdTop = WindowY(hWindow)
        If nTotalWidthOfWindows = -1
          nReqdWidth = WindowWidth(hWindow)
        Else
          nReqdWidth = nTotalWidthOfWindows
        EndIf
        nReqdHeight = WindowHeight(hWindow)
        
        If (\bPositionSet) And (\nLeft <> -1)
          nReqdLeft = \nLeft
          nReqdTop = \nTop
          bCheckPos = #True
        Else
          bCenterForm = #True
        EndIf
        
        If (\nWidth <> -1) And (nTotalWidthOfWindows = -1)
          nReqdWidth = \nWidth
          bCheckPos = #True
        EndIf
        
        If \nHeight <> -1
          nReqdHeight = \nHeight
          bCheckPos = #True
        EndIf
        
      EndIf
      
    EndIf
    
    debugMsgC(sProcName, "nReqdLeft=" + nReqdLeft + ", nReqdTop=" + nReqdTop + ", nReqdWidth=" + nReqdWidth + ", nReqdHeight=" + nReqdHeight + ", bCheckPos=" + strB(bCheckPos) +
                         ", gaMonitors(" + nMonitorNr + ")\nDesktopLeft=" + gaMonitors(nMonitorNr)\nDesktopLeft + ", gaMonitors(" + nMonitorNr + ")\nDeskTopWidth=" + gaMonitors(nMonitorNr)\nDeskTopWidth)
    
    If bCheckPos
      nMonitorNr = getMonitorNrForXY(nReqdLeft, nReqdTop)
      If (nMonitorNr >= 0) And (bAllowCrossMonitor = #False)
        ; if required position is not completely with the bounds of the monitor, set flag to center the form
        If (nReqdLeft + nReqdWidth) > (gaMonitors(nMonitorNr)\nDesktopLeft + gaMonitors(nMonitorNr)\nDeskTopWidth)
          bCenterForm = #True
          debugMsgC(sProcName, "bCenterForm=" + strB(bCenterForm))
        ElseIf (nReqdTop + nReqdHeight) > (gaMonitors(nMonitorNr)\nDesktopTop + gaMonitors(nMonitorNr)\nDeskTopHeight)
          bCenterForm = #True
          debugMsgC(sProcName, "bCenterForm=" + strB(bCenterForm))
        EndIf
        
      Else  ; nMonitor = -1
            ; if required position is not completely with the current viewable area, set flag to center the form
        If (nReqdLeft < nViewableLeft) Or (nReqdLeft > (nViewableLeft + nViewableWidth))
          bCenterForm = #True
          debugMsgC(sProcName, "bCenterForm=" + strB(bCenterForm))
        ElseIf (nReqdTop < nViewableTop) Or (nReqdTop > (nViewableTop + nViewableHeight))
          bCenterForm = #True
          debugMsgC(sProcName, "bCenterForm=" + strB(bCenterForm))
        ElseIf (nReqdLeft + nReqdWidth) > (nViewableLeft + nViewableWidth)
          bCenterForm = #True
          debugMsgC(sProcName, "bCenterForm=" + strB(bCenterForm))
        ElseIf (nReqdTop + nReqdHeight) > (nViewableTop + nViewableHeight)
          bCenterForm = #True
          debugMsgC(sProcName, "bCenterForm=" + strB(bCenterForm))
        EndIf
      EndIf
    EndIf
    
    If bCenterForm
      If (hWindow = #WV2) And (gbVideosOnMainWindow)
        ; ignore bCentreForm and leave exactly where is has been created
      ElseIf hWindow = #WTI And IsWindow(#WMN)
        ; don't centre Production Timer but place bottom right of the main window
        nReqdWidth = WindowWidth(hWindow)
        nReqdHeight = WindowHeight(hWindow)
        nMonitorNr = getMonitorNrForXY(nReqdLeft, nReqdTop)
        nReqdLeft = WindowX(#WMN) + WindowWidth(#WMN) - nReqdWidth
        nReqdTop = WindowY(#WMN) + WindowHeight(#WMN) - nReqdHeight
        debugMsgC(sProcName, "calling ResizeWindow(#WTI, " + nReqdLeft + ", " + nReqdTop + ", " + nReqdWidth + ", " + nReqdHeight + ")")
        ResizeWindow(#WTI, nReqdLeft, nReqdTop, nReqdWidth, nReqdHeight)
      Else
        debugMsgC(sProcName, "calling centreForm(" + sWindow + ")")
        centreForm(hWindow)
        \nCenteredLeft = WindowX(hWindow)
        \nCenteredTop = WindowY(hWindow)
      EndIf
    Else
      If (hWindow = #WMN) And (#c1280x720 Or #c1600x900)
        ; set #WMN window width and height before calling centreForm()
        ResizeWindow(hWindow, nReqdLeft, nReqdTop, nReqdWidth, nReqdHeight)
        debugMsgC(sProcName, "ResizeWindow(#WMN, " + nReqdLeft + ", " + nReqdTop + ", " + nReqdWidth + ", " + nReqdHeight + ")")
        debugMsgC(sProcName, "calling centreForm(" + sWindow + ")")
        centreForm(hWindow)
        \nCenteredLeft = WindowX(hWindow)
        \nCenteredTop = WindowY(hWindow)
        
      ElseIf \bMaximized
        ResizeWindow(hWindow, nReqdLeft, nReqdTop, #PB_Ignore, #PB_Ignore) ; set X and Y to ensure window is on the required display before issuing maximize
        debugMsgC(sProcName, "ResizeWindow(" + sWindow + ", " + nReqdLeft + ", " + nReqdTop + ", #PB_Ignore, #PB_Ignore)")
        SetWindowState(hWindow, #PB_Window_Maximize)
        ; debugMsgC(sProcName, "SetWindowState(" + sWindow + ", #PB_Window_Maximize)")
        ; added 15-16Dec2020 11.8.3.3-reissue and 11.8.3.4aa following email from Dee Ireland
        nWindowState = GetWindowState(hWindow)
        If nWindowState <> #PB_Window_Maximize
          HideWindow(hWindow, #False) ; Added 15Dec2020 11.8.3.3 reissue following bug report from Dee Ireland
          SetWindowState(hWindow, #PB_Window_Maximize)
          debugMsgC(sProcName, "SetWindowState(" + sWindow + ", #PB_Window_Maximize)")
          nWindowState = GetWindowState(hWindow)
          Select nWindowState
            Case #PB_Window_Normal
              debugMsgC(sProcName, "GetWindowState(" + decodeWindow(hWindow) + ") returned #PB_Window_Normal")
            Case #PB_Window_Maximize
              ; debugMsg0(sProcName, "GetWindowState(" + decodeWindow(hWindow) + ") returned #PB_Window_Maximize")
            Case #PB_Window_Minimize
              debugMsgC(sProcName, "GetWindowState(" + decodeWindow(hWindow) + ") returned #PB_Window_Minimize")
            Default
              debugMsg0(sProcName, "GetWindowState(" + decodeWindow(hWindow) + ") returned " + nWindowState)
          EndSelect
        EndIf
        ; debugMsgC(sProcName, "WindowWidth(" + hWindow + ")=" + WindowWidth(hWindow) + ", WindowHeight(" + hWindow + ")=" + WindowHeight(hWindow))

      Else
        nMonitorNr = getMonitorNrForXY(nReqdLeft, nReqdTop)
        If nMonitorNr >= 0
          ; Modified the following 25May2020 11.8.3rc5c following a test where the main window's status bar was not displayed, and found that this was due to
          ; the window height stored in the preferences file being equal to the desktop height. That must have been caused by previously having the main
          ; window displayed on a larger monitor, and that monitor not being available on the next run, so SCS set the window height to the monitor's desktop
          ; height, which includes the Windows Task Bar. So now, under these circumstances, we maximize the window on the selected monitor. By issuing a
          ; 'maximize' this ensures the new size is within the bounds of the usable space on the desktop, ie above the task bar.
          If nReqdWidth > gaMonitors(nMonitorNr)\nDesktopWidth
            nReqdLeft = gaMonitors(nMonitorNr)\nDesktopLeft
            ; nReqdWidth = gaMonitors(nMonitorNr)\nDesktopWidth ; Deleted 25May2020 11.8.3rc5c
            \bMaximized = #True ; Added 25May2020 11.8.3rc5c
          EndIf
          If nReqdHeight > gaMonitors(nMonitorNr)\nDesktopHeight
            nReqdTop = gaMonitors(nMonitorNr)\nDesktopTop
            ; nReqdHeight = gaMonitors(nMonitorNr)\nDesktopHeight ; Deleted 25May2020 11.8.3rc5c
            \bMaximized = #True ; Added 25May2020 11.8.3rc5c
          EndIf
        EndIf
        If \bMaximized ; Added 25May2020 11.8.3rc5c
          ; Added 25May2020 11.8.3rc5c
          ResizeWindow(hWindow, nReqdLeft, nReqdTop, #PB_Ignore, #PB_Ignore)
          debugMsgC(sProcName, "ResizeWindow(" + sWindow + ", " + nReqdLeft + ", " + nReqdTop + ", #PB_Ignore, #PB_Ignore)")
          SetWindowState(hWindow, #PB_Window_Maximize)
          debugMsgC(sProcName, "SetWindowState(" + sWindow + ", #PB_Window_Maximize)")
          ; End added 25May2020 11.8.3rc5c
        Else
          ResizeWindow(hWindow, nReqdLeft, nReqdTop, nReqdWidth, nReqdHeight)
          debugMsgC(sProcName, "ResizeWindow(" + sWindow + ", " + nReqdLeft + ", " + nReqdTop + ", " + nReqdWidth + ", " + nReqdHeight + ")")
        EndIf
      EndIf
    EndIf
    
  EndWith
  
  debugMsgC(sProcName, #SCS_END +
                       ", WindowX(" + sWindow + ")=" + WindowX(hWindow) + ", WindowY(" + sWindow + ")=" + WindowY(hWindow) +
                       ", WindowWidth(" + sWindow + ")=" + WindowWidth(hWindow) + ", WindowHeight(" + sWindow + ")=" + WindowHeight(hWindow))
  
EndProcedure

Procedure getPhysicalDevPtr(nDevType, sPhysicalDev.s, nAudioDriver=0, sDMXSerial.s="", nDMXSerial.l=0, bDummy=#False, bDefaultDev=#False)
  ; PROCNAMEC()
  Protected nPhysicalDevPtr, n
  Protected nPass, bCompareResult
  
  ; debugMsg(sProcName, #SCS_START + ", nDevType=" + decodeDevType(nDevType) + ", sPhysicalDev=" + sPhysicalDev + ", nAudioDriver=" + decodeDriver(nAudioDriver) +
  ;                     ", sDMXSerial=" + sDMXSerial + ", nDMXSerial=" + nDMXSerial + ", bDummy=" + strB(bDummy) + ", bDefaultDev=" + strB(bDefaultDev))
  
  nPhysicalDevPtr = -1
  
  If sPhysicalDev
    Select nDevType
      Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_LIVE_INPUT
        For nPass = 1 To 2
          ; 2 passes allowed in comparePhysDevDescs()
          For n = 0 To (gnPhysicalAudDevs-1)
            If gaAudioDev(n)\nAudioDriver = nAudioDriver
              If comparePhysDevDescs(gaAudioDev(n)\sDesc, sPhysicalDev, nPass)
                nPhysicalDevPtr = n
                Break
              EndIf
            EndIf
          Next n
          If nPhysicalDevPtr >= 0
            Break
          EndIf
        Next nPass
        If nPhysicalDevPtr = -1
          ; if neither pass 1 not pass 2 find a match, then search for the default device if bDefaultDev = #True
          If bDefaultDev
            For n = 0 To (gnPhysicalAudDevs-1)
              If gaAudioDev(n)\nAudioDriver = nAudioDriver
                If gaAudioDev(n)\bDefaultDev
                  nPhysicalDevPtr = n
                  Break
                EndIf
              EndIf
            Next n
          EndIf
        EndIf
        
      Case #SCS_DEVTYPE_VIDEO_AUDIO
        For n = 0 To (gnNumVideoAudioDevs-1)
          If gaVideoAudioDev(n)\sVidAudName = sPhysicalDev
            nPhysicalDevPtr = n
            Break
          EndIf
        Next n
        
      Case #SCS_DEVTYPE_VIDEO_CAPTURE
        For n = 0 To (gnNumVideoCaptureDevs-1)
          If gaVideoCaptureDev(n)\sVidCapName = sPhysicalDev
            nPhysicalDevPtr = n
            Break
          EndIf
        Next n
        
      Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_EXTCTRL_MIDI_IN ; Changed 25Jun2022 11.9.4
        For n = 0 To (gnNumMidiInDevs-1)
          If (gaMidiInDevice(n)\sName = sPhysicalDev) Or ((bDummy) And (gaMidiInDevice(n)\bDummy))
            nPhysicalDevPtr = n
            Break
          EndIf
        Next n
        
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU, #SCS_DEVTYPE_EXTCTRL_MIDI_OUT ; Changed 25Jun2022 11.9.4
        For n = 0 To (gnNumMidiOutDevs-1)
          If (gaMidiOutDevice(n)\sName = sPhysicalDev) Or ((bDummy) And (gaMidiOutDevice(n)\bDummy))
            nPhysicalDevPtr = n
            Break
          EndIf
        Next n
        
      Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
        For n = 0 To gnMaxRS232Control
          If (gaRS232Control(n)\sRS232PortAddress = sPhysicalDev) Or ((bDummy) And (gaRS232Control(n)\bDummy))
            nPhysicalDevPtr = n
            Break
          EndIf
        Next n
        
      Case #SCS_DEVTYPE_CS_NETWORK_OUT, #SCS_DEVTYPE_CC_NETWORK_IN
        For n = 0 To gnMaxNetworkControl
          If (gaNetworkControl(n)\sNetworkDevDesc = sPhysicalDev) Or ((bDummy) And (gaNetworkControl(n)\bNWDummy))
            nPhysicalDevPtr = n
            Break
          EndIf
        Next n
        
      Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
        If nDMXSerial
          For n = 0 To (grDMX\nNumDMXDevs-1)
            If ((gaDMXDevice(n)\sName = sPhysicalDev) And (gaDMXDevice(n)\nSerial = nDMXSerial)) Or ((bDummy) And (gaDMXDevice(n)\bDummy))
              nPhysicalDevPtr = n
              Break
            EndIf
          Next n
        EndIf
        If nPhysicalDevPtr < 0
          If sDMXSerial
            For n = 0 To (grDMX\nNumDMXDevs-1)
              ; debugMsg(sProcName, "gaDMXDevice(" + n + ")\sName=" + gaDMXDevice(n)\sName + ", \sSerial=" + gaDMXDevice(n)\sSerial)
              If (gaDMXDevice(n)\sName = sPhysicalDev) And (gaDMXDevice(n)\sSerial = sDMXSerial)
                nPhysicalDevPtr = n
                Break
              EndIf
            Next n
          EndIf
        EndIf
        
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        nPhysicalDevPtr = 0
        
    EndSelect
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning nPhysicalDevPtr=" + nPhysicalDevPtr)
  ProcedureReturn nPhysicalDevPtr
  
EndProcedure

Procedure getPhysicalDevPtrOfDefaultDev(nDevType)
  PROCNAMEC()
  Protected nPhysicalDevPtr=-1
  Protected n
  
  Select nDevType
    Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_LIVE_INPUT
      For n = 0 To (gnPhysicalAudDevs-1)
        If gaAudioDev(n)\bDefaultDev
          nPhysicalDevPtr = n
          Break
        EndIf
      Next n
      
    Case #SCS_DEVTYPE_VIDEO_AUDIO
      For n = 0 To (gnNumVideoAudioDevs-1)
        If gaVideoAudioDev(n)\bDefaultDev
          nPhysicalDevPtr = n
          Break
        EndIf
      Next n
      
  EndSelect
  
  ProcedureReturn nPhysicalDevPtr
EndProcedure

Procedure countAudioDevsRequested(*prProd.tyProd)
  Protected nDevsRequested, d
  
  For d = 0 To *prProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD
    If *prProd\aAudioLogicalDevs(d)\sLogicalDev
      nDevsRequested + 1
    EndIf
  Next d
  ProcedureReturn nDevsRequested
EndProcedure

Procedure setWindowModal(nWindowNo, bModal, nReturnFunction=0, nReturnFunctionParam=0)
  PROCNAMECW(nWindowNo)
  ; to make a window 'modal', this procedure disables all other windows, but records their
  ; current 'enabled' state in an array so they can be re-enabled where necessary when the
  ; modal window is closed (see unsetWindowModal())
  
  ; note that modal window event processing is handled by the main thread via handleWindowEvents(),
  ; so these modal windows are not handled like VB6 modal windows, ie they are *not* blocking
  ; windows with their own independent WaitWindowEvent() loop
  
  Protected n, sMsg.s
  
  debugMsg(sProcName, #SCS_START + ", bModal=" + strB(bModal) + ", nReturnFunction=" + nReturnFunction)
  
  If bModal
    gbModalDisplayed = #True
    If gnModalWindowStackPtr >= ArraySize(gaModalWindowStack(), 1)
      sMsg = "Modal Window Stack Overflow: gnModalWindowStackPtr=" + gnModalWindowStackPtr
      debugMsg(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
      ProcedureReturn
    EndIf
    
    gnModalWindowStackPtr + 1
    For n = 0 To (#WZZ-1)
      With gaModalWindowStack(gnModalWindowStackPtr, n)
        If IsWindow(n)
          \bWindowCreated = #True
          \bEnabled = getWindowEnabled(n)
          If n <> nWindowNo
            setWindowEnabled(n, #False)
          EndIf
        Else
          \bWindowCreated = #False
          \bEnabled = #False
        EndIf
      EndWith
    Next n
  EndIf
  
  setWindowEnabled(nWindowNo, #True)
  
  gaWindowProps(nWindowNo)\bModal = bModal
  gaWindowProps(nWindowNo)\nReturnFunction = nReturnFunction
  gaWindowProps(nWindowNo)\nReturnFunctionParam = nReturnFunctionParam
  
EndProcedure

Procedure unsetWindowModal(nWindowNo, nReturnFunctionResult=0)
  PROCNAMECW(nWindowNo)
  Protected n, nReturnFunction, nReturnFunctionParam
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gaWindowProps(nWindowNo)\bModal
    For n = 0 To (#WZZ-1)
      With gaModalWindowStack(gnModalWindowStackPtr, n)
        If \bWindowCreated And \bEnabled
          If IsWindow(n)
            setWindowEnabled(n, #True)
          EndIf
        EndIf
      EndWith
    Next n
    gnModalWindowStackPtr - 1
    gaWindowProps(nWindowNo)\bModal = #False
    If gnModalWindowStackPtr < 0
      gbModalDisplayed = #False
    EndIf
    nReturnFunction = gaWindowProps(nWindowNo)\nReturnFunction
    nReturnFunctionParam = gaWindowProps(nWindowNo)\nReturnFunctionParam
    gaWindowProps(nWindowNo)\nReturnFunction = 0
    gaWindowProps(nWindowNo)\nReturnFunctionParam = 0
  EndIf
  
  If nReturnFunction <> 0
    samAddRequest(#SCS_SAM_CALL_MODRETURN_FUNCTION, nReturnFunction, 0, nReturnFunctionResult, "", 0, nReturnFunctionParam)
  EndIf
  
EndProcedure

Procedure OpenURL(sURL.s)
  PROCNAMEC()
  Protected sFullURL.s
  
  If Left(sURL,7) = "http://"
    sFullURL = sURL
  ElseIf Left(sURL,8) = "https://"
    sFullURL = sURL
  Else
    sFullURL = "http://" + sURL
  EndIf
  debugMsg(sProcName, sFullURL)
  RunProgram(sFullURL)
  
EndProcedure

Procedure chkToBoolean(hCheckBox)
  If GetGadgetState(hCheckBox) = 1
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure setTextBoxBackColor(pTxtField)
  PROCNAMEC()
  
  If getEnabled(pTxtField) Or (getGType(sProcName, pTxtField) = #SCS_GTYPE_STRING_READONLY)
    SetGadgetColor(pTxtField, #PB_Gadget_BackColor, glSysColWindow)   ; this color was used effectively on SCS 10 (VB6 color &H80000005)
  Else
    SetGadgetColor(pTxtField, #PB_Gadget_BackColor, glSysColBtnFace)  ; this color was used effectively on SCS 10 (VB6 color &H8000000F)
  EndIf
EndProcedure

Procedure condFreeImage(nImageNo, nLineNumber=0)
  PROCNAMEC()
  Protected n
  Protected bKeepOpen
  
  If nImageNo <> 0 And nLineNumber > 0
    debugMsg(sProcName, "nImageNo=" + decodeHandle(nImageNo) + ", nLineNumber=" + nLineNumber)
  EndIf
  If IsImage(nImageNo) And (nImageNo <> hVideoCaptionLogo)
    For n = 0 To gnLastImageData
      If gaImageData(n)\nImageNo = nImageNo
        gaImageData(n)\nImageOpenCount - 1
        debugMsg(sProcName, "gaImageData(" + n + ")\sFileName=" + GetFilePart(gaImageData(n)\sFileName) +
                            ", \nImageNo=" + decodeHandle(gaImageData(n)\nImageNo) + ", \nImageOpenCount=" + Str(gaImageData(n)\nImageOpenCount))
        If gaImageData(n)\nImageOpenCount > 0
          bKeepOpen = #True
        EndIf
        Break
      EndIf
    Next n
    If bKeepOpen = #False
      ; debugMsg(sProcName, "calling FreeImage(" + decodeHandle(nImageNo) + "), ImageID=" + Str(ImageID(nImageNo)))
      FreeImage(nImageNo)
      debugMsg3(sProcName, "FreeImage(" + decodeHandle(nImageNo) + ")")
      logFreeImage(99, nImageNo)
    EndIf
  EndIf
EndProcedure

Procedure GetTextWidth(sText.s, nFontNo=#SCS_FONT_GEN_NORMAL)
  PROCNAMEC()
  Static nTextImage
  Protected nTextWidth
  
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  
  If IsImage(nTextImage)
    If StartDrawing(ImageOutput(nTextImage))
      DrawingFont(FontID(nFontNo))
      nTextWidth = TextWidth(sText)
      StopDrawing()
    EndIf
  EndIf
  ProcedureReturn nTextWidth
EndProcedure

Procedure GetTextWidthForGadget(sText.s, nGadgetNo)
  ; PROCNAMEC()
  Static nTextImage
  Protected nTextWidth
  
  ; debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo) + ", sText=" + #DQUOTE$ + sText + #DQUOTE$)
  
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  
  If IsImage(nTextImage)
    If StartDrawing(ImageOutput(nTextImage))
      DrawingFont(GetGadgetFont(nGadgetNo))
      nTextWidth = TextWidth(sText)
      StopDrawing()
    EndIf
  EndIf
  ProcedureReturn nTextWidth
EndProcedure

Procedure GetTextWidthForStringGadget(sText.s)
  ; PROCNAMEC()
  Protected nTextWidth
  
  If IsGadget(WMN\txtDummy)
    SetGadgetText(WMN\txtDummy, sText)
    nTextWidth = GadgetWidth(WMN\txtDummy, #PB_Gadget_RequiredSize) + (gl3DBorderAllowanceX * 3) ; nb "+ (gl3DBorderAllowanceX * 3)" decided by trial and error
    ; debugMsg0(sProcName, "sText=" + sText + ", nTextWidth=" + nTextWidth)
  EndIf
  ProcedureReturn nTextWidth
EndProcedure

Procedure GetTextHeight(sText.s, nFontNo=#SCS_FONT_GEN_NORMAL)
  PROCNAMEC()
  Static nTextImage
  Protected nTextHeight
  
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  
  If IsImage(nTextImage)
    If StartDrawing(ImageOutput(nTextImage))
      DrawingFont(FontID(nFontNo))
      nTextHeight = TextHeight(sText)
      StopDrawing()
    EndIf
  EndIf
  ProcedureReturn nTextHeight
EndProcedure

Procedure GetTextHeightForGadget(sText.s, nGadgetNo)
  PROCNAMEC()
  Static nTextImage
  Protected nTextHeight
  
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  
  If IsImage(nTextImage)
    If StartDrawing(ImageOutput(nTextImage))
      DrawingFont(GetGadgetFont(nGadgetNo))
      nTextHeight = TextHeight(sText)
      StopDrawing()
    EndIf
  EndIf
  ProcedureReturn nTextHeight
EndProcedure

Procedure setToolTipControls()
  ; PROCNAMEC()
  ; this code provided by RASHAD in reply to my forum topic "Increase display time of tooltip?", 27 May 2013
  ; needs to be called for any window that needs it (???)
  Protected ttip
  
  ttip = FindWindow_("tooltips_class32", 0)
  ; debugMsg(sProcName, "ttip=" + ttip)
  If ttip
;     SendMessage_(ttip, #TTM_SETMAXTIPWIDTH, 0, 500)
;     ; commented-out setting initial start to 0 as that can cause unnecessary flickering due to tooltips being instantly displayed
;     ;     SendMessage_(ttip, #TTM_SETDELAYTIME,#TTDT_INITIAL, 0)
    SendMessage_(ttip, #TTM_SETDELAYTIME, #TTDT_INITIAL, -1)   ; -1 returns the delay time to it's default value, which = double-click time, which has a default of 500ms
    SendMessage_(ttip, #TTM_SETDELAYTIME, #TTDT_AUTOPOP, 32767);32767 is the highest value
  EndIf
  
EndProcedure

Procedure setToolTipFromTextIfReqd(nGadgetNo, bMayChangeDuringRun=#False)
  PROCNAMEC()
  ; this procedure created initially because the French translations of the device map buttons exceed the available with of those buttons
  Protected nReqdWidth
  Protected sToolTip.s
  Protected bSetToolTip
  
  If gnOperMode <> #SCS_OPERMODE_PERFORMANCE  ; test added 18Nov2016 11.5.2.4 following problem reported by Mike Pope (tooltip displaying on video screen)
    If IsGadget(nGadgetNo)
      nReqdWidth = GadgetWidth(nGadgetNo, #PB_Gadget_RequiredSize)
      If nReqdWidth > GadgetWidth(nGadgetNo)
        sToolTip = GetGadgetText(nGadgetNo)
        bSetToolTip = #True
      ElseIf bMayChangeDuringRun
        bSetToolTip = #True
      EndIf
      If bSetToolTip
        GadgetToolTip(nGadgetNo, sToolTip)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure setGadgetWidth(nGadgetNo, nMinWidth=-1, bResetNextX=#False, nMaxWidth=-1, bIncreaseHeightIfReqd=#False)
  PROCNAMECG(nGadgetNo)
  Protected nNewWidth, nReqdWidth, nGadgetHeight, nGadgetPropsIndex
  
  If IsGadget(nGadgetNo)
    Select getModGadgetType(nGadgetNo)
      Case #SCS_MG_TEXT
        TextEx::AdjustSize(nGadgetNo, TextEx::#Width, 0)
        nNewWidth = GadgetWidth(nGadgetNo)
        If nNewWidth < nMinWidth
          ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, nMinWidth, #PB_Ignore)
          CompilerIf #cTraceGadgets
            debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nGadgetNo) + ", #PB_ignore, #PB_Ignore, " + nMinWidth + ", #PB_Ignore)")
          CompilerEndIf
        EndIf
        
      Default
        nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
        Select gaGadgetProps(nGadgetPropsIndex)\nGType
          Case #SCS_GTYPE_STRING_ENTERABLE, #SCS_GTYPE_STRING_READONLY
            nReqdWidth = GetTextWidthForStringGadget(GetGadgetText(nGadgetNo))
            ; PB does not support GadgetWidth(nGadgetNo, #PB_Gadget_RequiredSize) for string gadgets, so use home-grown attempt to calculate the required width
          Default
            nReqdWidth = GadgetWidth(nGadgetNo, #PB_Gadget_RequiredSize)
        EndSelect
        nGadgetHeight = GadgetHeight(nGadgetNo)
        If nReqdWidth < nMinWidth
          nReqdWidth = nMinWidth
        EndIf
        If nMaxWidth > 0
          If nReqdWidth > nMaxWidth
            nReqdWidth = nMaxWidth
            If bIncreaseHeightIfReqd
              ; nGadgetHeight = GadgetHeight(nGadgetNo, #PB_Gadget_RequiredSize)
              nGadgetHeight * 2
            EndIf
          EndIf
        EndIf
        ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, nReqdWidth, nGadgetHeight)
        CompilerIf #cTraceGadgets
          debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nGadgetNo) + ", #PB_ignore, #PB_Ignore, " + nReqdWidth + ", " + nGadgetHeight + ")")
        CompilerEndIf
        
    EndSelect
    
    If bResetNextX
      gnNextX = GadgetX(nGadgetNo) + GadgetWidth(nGadgetNo)
    EndIf
    
  EndIf
  
EndProcedure

Procedure setTextGadgetHeight(nGadgetNo, nMinHeight=-1)
  PROCNAMECG(nGadgetNo)
  ; this procedure can be used with text gadgets that may become multi-line, to calculate the number of lines that will be displayed and hence calculate and set the required gadget height
  ; the calculated is returned by the procedure
  Protected nGadgetWidth, nReqdWidth, nLineHeight, nReqdHeight, sGadgetText.s
  Protected nWordNo, sWord.s, sLine.s
  Static nTextImage
  Protected nLineWidth
  
  nGadgetWidth = GadgetWidth(nGadgetNo)
  nReqdWidth = GadgetWidth(nGadgetNo, #PB_Gadget_RequiredSize)
  nLineHeight = GadgetHeight(nGadgetNo, #PB_Gadget_RequiredSize)
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  If IsImage(nTextImage) = #False
    ; shouldn't get here
    nReqdHeight = nLineHeight
  ElseIf nReqdWidth <= nGadgetWidth
    ; text all fits in the gadget width so no need to calculate the number of lines
    nReqdHeight = nLineHeight
  Else
    sGadgetText = Trim(GGT(nGadgetNo))
    ; convert any double spaces or multiple spaces to single spaces
    While FindString(sGadgetText, "  ")
      sGadgetText = ReplaceString(sGadgetText, "  ", " ")
    Wend
    If StartDrawing(ImageOutput(nTextImage))
      DrawingFont(GetGadgetFont(nGadgetNo))
      nWordNo = 1
      While #True
        sWord = StringField(sGadgetText, nWordNo, " ")
        If Len(sWord) = 0
          Break
        EndIf
        If sLine
          sLine + " "
        EndIf
        sLine + sWord
        nLineWidth = TextWidth(sLine)
        If nLineWidth > nGadgetWidth
          nReqdHeight + nLineHeight
          sLine = sWord
        EndIf
        nWordNo + 1
      Wend
      nReqdHeight + nLineHeight
      StopDrawing()
    EndIf
  EndIf
  If nReqdHeight < nMinHeight
    nReqdHeight = nMinHeight
  EndIf
  ; debugMsg(sProcName, "nGadgetWidth=" + nGadgetWidth + ", nReqdWidth=" + nReqdWidth + ", nLineHeight=" + nLineHeight + ", nReqdHeight=" + nReqdHeight)
  ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdHeight)
  ProcedureReturn nReqdHeight
EndProcedure

Procedure resetNextX(nGadgetNo)
  If IsGadget(nGadgetNo)
    gnNextX = GadgetX(nGadgetNo) + GadgetWidth(nGadgetNo)
  EndIf
EndProcedure

Procedure resetScaWidth(nScaGadgetNo, nLastEmbeddedGadgetNo, nPadding=0)
  PROCNAMEC()
  ; sets a ScrollAreaGadget width and inner width based on the position and width of the last gadget within the scroll area
  ; designed specifically for the various device tabs in production properties
  Protected nScaWidth, nScaInnerWidth
  
  If (IsGadget(nScaGadgetNo)) And (IsGadget(nLastEmbeddedGadgetNo))
    nScaInnerWidth = GadgetX(nLastEmbeddedGadgetNo) + GadgetWidth(nLastEmbeddedGadgetNo) + nPadding
    nScaWidth = nScaInnerWidth + glScrollBarWidth + gl3DBorderAllowanceX
    SetGadgetAttribute(nScaGadgetNo, #PB_ScrollArea_InnerWidth, nScaInnerWidth)
    ResizeGadget(nScaGadgetNo, #PB_Ignore, #PB_Ignore, nScaWidth, #PB_Ignore)
    CompilerIf #cTraceGadgets
      debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nScaGadgetNo) + ", #PB_Ignore, #PB_Ignore, " + nScaWidth + ", #PB_Ignore)")
    CompilerEndIf
  EndIf
  
EndProcedure

Procedure resetActiveWindowIfReqd(nActiveWindow, nDefaultWindow=#WMN)
  PROCNAMEC()
  ; Modified 22Apr2020 11.8.2.3ay, to avoid calling SetActiveWindow() with -1 as the window number
  Protected nReqdWindow
  
  If IsWindow(nActiveWindow)
    nReqdWindow = nActiveWindow
  Else
    nReqdWindow = nDefaultWindow
  EndIf
  If IsWindow(nReqdWindow)
    If GetActiveWindow() <> nReqdWindow
      SAW(nReqdWindow)
    EndIf
  EndIf
EndProcedure

Procedure.i setComboBoxWidth(nComboBoxGadgetNo, nMinWidth=-1, bResetNextX=#False, nMaxWidth=999)
  PROCNAMEC()
  ; Added parameter nMaxWidth 7Jun2022 11.9.2.
  Protected nCalcMaxWidth, nWidth, n
  
  If IsGadget(nComboBoxGadgetNo)
    Select getModGadgetType(nComboBoxGadgetNo)
      Case #SCS_MG_COMBOBOX
        For n = 0 To (ComboBoxEx::CountItems(nComboBoxGadgetNo) - 1)
          nWidth = GetTextWidth(ComboBoxEx::GetItemText(nComboBoxGadgetNo, n))
          If nWidth > nCalcMaxWidth
            nCalcMaxWidth = nWidth
          EndIf
        Next n
      Default
        For n = 0 To (CountGadgetItems(nComboBoxGadgetNo) - 1)
          nWidth = GetTextWidth(GetGadgetItemText(nComboBoxGadgetNo, n))
          If nWidth > nCalcMaxWidth
            nCalcMaxWidth = nWidth
          EndIf
        Next n
    EndSelect
    
    nCalcMaxWidth + glScrollBarWidth + gl3DBorderAllowanceX + gl3DBorderAllowanceX
    If nMinWidth > nCalcMaxWidth
      nCalcMaxWidth = nMinWidth
    EndIf
    If nCalcMaxWidth > nMaxWidth
      nCalcMaxWidth = nMaxWidth
    EndIf
    If GadgetWidth(nComboBoxGadgetNo) <> nCalcMaxWidth
      ResizeGadget(nComboBoxGadgetNo, #PB_Ignore, #PB_Ignore, nCalcMaxWidth, #PB_Ignore)
    EndIf
    
    If bResetNextX
      gnNextX = GadgetX(nComboBoxGadgetNo) + GadgetWidth(nComboBoxGadgetNo)
    EndIf
    
  EndIf
  ProcedureReturn nCalcMaxWidth
EndProcedure

Procedure getComboBoxMaxTextWidth(nComboBoxGadgetNo)
  Protected nMaxWidth, nWidth, n
  
  If IsGadget(nComboBoxGadgetNo)
    Select getModGadgetType(nComboBoxGadgetNo)
      Case #SCS_MG_COMBOBOX
        For n = 0 To (ComboBoxEx::CountItems(nComboBoxGadgetNo) - 1)
          nWidth = GetTextWidth(ComboBoxEx::GetItemText(nComboBoxGadgetNo, n))
          If nWidth > nMaxWidth
            nMaxWidth = nWidth
          EndIf
        Next n
      Default
        For n = 0 To (CountGadgetItems(nComboBoxGadgetNo) - 1)
          nWidth = GetTextWidth(GetGadgetItemText(nComboBoxGadgetNo, n))
          If nWidth > nMaxWidth
            nMaxWidth = nWidth
          EndIf
        Next n
    EndSelect
  EndIf
  ProcedureReturn nMaxWidth
EndProcedure

Procedure setComboBoxesWidth(nMinWidth, nComboBoxGadgetNo1, nComboBoxGadgetNo2=0, nComboBoxGadgetNo3=0, nComboBoxGadgetNo4=0, nComboBoxGadgetNo5=0)
  PROCNAMEC()
  Protected nMaxWidth, nWidth, nMyMinWidth
  
  nMyMinWidth = nMinWidth
  If nMyMinWidth < 0
    nMyMinWidth = GadgetWidth(nComboBoxGadgetNo1)
  EndIf
  nWidth = getComboBoxMaxTextWidth(nComboBoxGadgetNo1)
  If nWidth > nMaxWidth
    nMaxWidth = nWidth
  EndIf
  nWidth = getComboBoxMaxTextWidth(nComboBoxGadgetNo2)
  If nWidth > nMaxWidth
    nMaxWidth = nWidth
  EndIf
  nWidth = getComboBoxMaxTextWidth(nComboBoxGadgetNo3)
  If nWidth > nMaxWidth
    nMaxWidth = nWidth
  EndIf
  nWidth = getComboBoxMaxTextWidth(nComboBoxGadgetNo4)
  If nWidth > nMaxWidth
    nMaxWidth = nWidth
  EndIf
  nWidth = getComboBoxMaxTextWidth(nComboBoxGadgetNo5)
  If nWidth > nMaxWidth
    nMaxWidth = nWidth
  EndIf
  
  nMaxWidth + glScrollBarWidth + gl3DBorderAllowanceX + gl3DBorderAllowanceX
  If nMyMinWidth > nMaxWidth
    nMaxWidth = nMyMinWidth
  EndIf
  If IsGadget(nComboBoxGadgetNo1)
    ResizeGadget(nComboBoxGadgetNo1, #PB_Ignore, #PB_Ignore, nMaxWidth, #PB_Ignore)
  EndIf
  If IsGadget(nComboBoxGadgetNo2)
    ResizeGadget(nComboBoxGadgetNo2, #PB_Ignore, #PB_Ignore, nMaxWidth, #PB_Ignore)
  EndIf
  If IsGadget(nComboBoxGadgetNo3)
    ResizeGadget(nComboBoxGadgetNo3, #PB_Ignore, #PB_Ignore, nMaxWidth, #PB_Ignore)
  EndIf
  If IsGadget(nComboBoxGadgetNo4)
    ResizeGadget(nComboBoxGadgetNo4, #PB_Ignore, #PB_Ignore, nMaxWidth, #PB_Ignore)
  EndIf
  If IsGadget(nComboBoxGadgetNo5)
    ResizeGadget(nComboBoxGadgetNo5, #PB_Ignore, #PB_Ignore, nMaxWidth, #PB_Ignore)
  EndIf
  ProcedureReturn nMaxWidth
EndProcedure

Procedure setComboBoxForText(nComboBoxGadgetNo, sText.s)
  Protected n, nReqdState
  
  nReqdState = -1
  If IsGadget(nComboBoxGadgetNo)
    Select getModGadgetType(nComboBoxGadgetNo)
      Case #SCS_MG_COMBOBOX
        For n = 0 To (ComboBoxEx::CountItems(nComboBoxGadgetNo) - 1)
          If LCase(ComboBoxEx::GetItemText(nComboBoxGadgetNo, n)) = LCase(sText)
            nReqdState = n
            Break
          EndIf
        Next n
        ComboBoxEx::SetState(nComboBoxGadgetNo, nReqdState)
      Default
        For n = 0 To (CountGadgetItems(nComboBoxGadgetNo) - 1)
          If LCase(GetGadgetItemText(nComboBoxGadgetNo, n)) = LCase(sText)
            nReqdState = n
            Break
          EndIf
        Next n
        SGS(nComboBoxGadgetNo, nReqdState)
    EndSelect
  EndIf
  ProcedureReturn nReqdState
EndProcedure

Procedure makeGadgetBorderless(nGadgetNo)
  Protected nStyle, nNewStyle
  
  nStyle = GetWindowLongPtr_(GadgetID(nGadgetNo), #GWL_EXSTYLE) 
  nNewStyle = nStyle &(~#WS_EX_CLIENTEDGE) 
  SetWindowLongPtr_(GadgetID(nGadgetNo), #GWL_EXSTYLE, nNewStyle) 
  SetWindowPos_(GadgetID(nGadgetNo), 0, 0, 0, 0, 0, #SWP_SHOWWINDOW | #SWP_NOSIZE | #SWP_NOMOVE | #SWP_FRAMECHANGED)
EndProcedure

Procedure setSpecialColor(nGadgetNo, nBackColor)
  ; designed for debug only, especially for setting the background color of a container
  SetGadgetColor(nGadgetNo, #PB_Gadget_BackColor, #SCS_White)
  setAllowEditorColors(nGadgetNo, #False)
EndProcedure

Procedure ensureScrollAreaItemVisible(nSCAGadgetNo, nItemHeight, nItemIndex)
  ; PROCNAMECG(nSCAGadgetNo)
  Protected nScrollAreaHeight, nScrollAreaTopVisible, nScrollAreaBottomVisible
  Protected nFirstItemVisible, nLastItemVisible
  Protected nItemTop, nMyItemHeight
  Protected nMaxItemsVisible
  Protected nReqdTopVisible
  
  ; debugMsg(sProcName, #SCS_START + ", nItemIndex=" + nItemIndex)
  
  nScrollAreaHeight = GadgetHeight(nSCAGadgetNo)
  nScrollAreaTopVisible = GetGadgetAttribute(nSCAGadgetNo, #PB_ScrollArea_Y)
  nScrollAreaBottomVisible = nScrollAreaTopVisible + nScrollAreaHeight
  ; debugMsg(sProcName, "nScrollAreaTopVisible=" + nScrollAreaTopVisible + ", nScrollAreaBottomVisible=" + nScrollAreaBottomVisible)
  
  If nItemHeight > 0
    nMyItemHeight = nItemHeight
  Else
    nMyItemHeight = GetGadgetAttribute(nSCAGadgetNo, #PB_ScrollArea_ScrollStep)
  EndIf
  
  nMaxItemsVisible = Round(nScrollAreaHeight / nMyItemHeight, #PB_Round_Down)
  nFirstItemVisible = nScrollAreaTopVisible / nMyItemHeight
  nLastItemVisible = ((nScrollAreaTopVisible + nScrollAreaHeight) / nMyItemHeight) - 1
  ; debugMsg(sProcName, "nItemHeight=" + nItemHeight + ", nMaxItemsVisible=" + nMaxItemsVisible + ", nFirstItemVisible=" + nFirstItemVisible + ", nLastItemVisible=" + nLastItemVisible)
  
  If nItemIndex < nFirstItemVisible
    nReqdTopVisible = nItemIndex * nMyItemHeight
    ; debugMsg(sProcName, "nReqdTopVisible=" + nReqdTopVisible)
    SetGadgetAttribute(nSCAGadgetNo, #PB_ScrollArea_Y, nReqdTopVisible)
  ElseIf nItemIndex > nLastItemVisible
    nReqdTopVisible = (nItemIndex - nMaxItemsVisible + 1) * nMyItemHeight
    ; debugMsg(sProcName, "nReqdTopVisible=" + nReqdTopVisible)
    SetGadgetAttribute(nSCAGadgetNo, #PB_ScrollArea_Y, nReqdTopVisible)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

;========================================================
;  AutoSize() for automatically sizing text gadgets -
;  expands the width of an undersized text gadget to
;  fit the longest word in the caption, or shrinks an
;  oversized text gadget to the width of the longest
;  possible phrase in the caption - height corresponds
;
;  for Windows, OSX (and Linux?)
;
;  tested with PureBasic v5.31 on Windows 8.1 Pro (x64)
;  and PureBasic v5.2 on on OSX 10.7.5 (x64)
;
;  by TI-994A - free to use, improve, share...
;
;  18th December 2014
;========================================================

;==============================================================================================
; fully cross-platform, self-contained text gadget auto-sizing function - just pop-in and call
;==============================================================================================
; PROCEDURE MODIFIED FOR SCS BY MJD
Procedure AutoSize(gadgetNo, alignFlag=0, nMinWidth=0)
  PROCNAMEC()
  ; Shared alignFlag
  Protected gadgetWt, gadgetHt, gadgetText.s, tempGadget, expanded, textIndex, textIndexWidth, currentStringWidth, spacer$, maxWidth, lines
  
  gadgetWt = GadgetWidth(gadgetNo)
  gadgetHt = GadgetHeight(gadgetNo, #PB_Gadget_RequiredSize)
  gadgetText.s = (ReplaceString(Trim(GetGadgetText(gadgetNo)), "  ", " ")) + " "
  tempGadget = TextGadget(#PB_Any, -1000, -1000, gadgetWt, gadgetHt, "", alignFlag)
  SetGadgetFont(tempGadget, GetGadgetFont(gadgetNo))
  HideGadget(tempGadget, 1)
  For textIndex = 1 To CountString(gadgetText, " ")
    If alignFlag = #PB_Text_Right
      SetGadgetText(tempGadget, " " + StringField(gadgetText, textIndex, " "))
    Else
      SetGadgetText(tempGadget, StringField(gadgetText, textIndex, " "))
    EndIf
    textIndexWidth = GadgetWidth(tempGadget, #PB_Gadget_RequiredSize)
    If textIndexWidth > gadgetWt
      gadgetWt = textIndexWidth
      expanded = 1
    EndIf
  Next textIndex
  
  If Not expanded
    textIndexWidth = 0
    For textIndex = 1 To CountString(gadgetText, " ")
      SetGadgetText(tempGadget, spacer$ + StringField(gadgetText, textIndex, " "))
      currentStringWidth = GadgetWidth(tempGadget, #PB_Gadget_RequiredSize) - 2
      textIndexWidth + currentStringWidth
      If textIndexWidth => gadgetWt
        If textIndexWidth - currentStringWidth > maxWidth
          maxWidth = textIndexWidth - currentStringWidth
        EndIf
        If textIndexWidth > gadgetWt
          spacer$ = " " 
        Else 
          spacer$ = ""
        EndIf        
        If alignFlag = #PB_Text_Right
          SetGadgetText(tempGadget, " " + StringField(gadgetText, textIndex, " "))
        Else
          SetGadgetText(tempGadget, StringField(gadgetText, textIndex, " "))
        EndIf      
        textIndexWidth = GadgetWidth(tempGadget, #PB_Gadget_RequiredSize) - 2
      Else 
        spacer$ = " "
      EndIf  
    Next textIndex
    
    If textIndexWidth > maxWidth
      maxWidth = textIndexWidth
    EndIf    
    
    If maxWidth
      gadgetWt = maxWidth + 2
    EndIf
  EndIf
  
  spacer$ = ""
  textIndexWidth = 0
  
  For textIndex = 1 To CountString(gadgetText, " ")
    SetGadgetText(tempGadget, spacer$ + StringField(gadgetText, textIndex, " "))
    textIndexWidth + GadgetWidth(tempGadget, #PB_Gadget_RequiredSize) - 2
    If textIndexWidth => gadgetWt
      If textIndexWidth > gadgetWt
        spacer$ = " " 
      Else 
        spacer$ = ""
      EndIf
      If textIndex = CountString(gadgetText, " ")
        lines + 2
      Else
        lines + 1
      EndIf
      If alignFlag = #PB_Text_Right
        spacer$ = " " 
        SetGadgetText(tempGadget, " " + StringField(gadgetText, textIndex, " "))
      Else
        SetGadgetText(tempGadget, StringField(gadgetText, textIndex, " "))
      EndIf
      If textIndexWidth > gadgetWt
        textIndexWidth = GadgetWidth(tempGadget, #PB_Gadget_RequiredSize) - 2
      Else
        textIndexWidth = 0
      EndIf
    Else 
      spacer$ = " "
      If textIndex = CountString(gadgetText, " ")
        lines + 1
      EndIf
    EndIf
  Next textIndex
  
  gadgetHt * lines
  
  ResizeGadget(gadgetNo, #PB_Ignore, #PB_Ignore, gadgetWt, gadgetHt)
  CompilerIf #cTraceGadgets Or #cTraceResizer
    debugMsg(sProcName, "ResizeGadget(" + getGadgetName(gadgetNo) + ", #PB_Ignore, #PB_Ignore, " + gadgetWt + ", " + gadgetHt + ")")
  CompilerEndIf
  SetGadgetText(gadgetNo, Trim(gadgetText))
  FreeGadget(tempGadget) 
  
  ; additional code by MJD:
  If nMinWidth > gadgetWt
    gnNextX = GadgetX(gadgetNo) + nMinWidth
  Else
    gnNextX = GadgetX(gadgetNo) + gadgetWt
  EndIf
  
EndProcedure

Procedure getGadgetColumnCount(nGadgetNo)
  Protected nHeaderCtrl.l, nColumnCount.l
  
  ; Count gadget columns
  nHeaderCtrl  = SendMessage_(GadgetID(nGadgetNo), #LVM_GETHEADER, 0, 0)
  nColumnCount = SendMessage_(nHeaderCtrl, #HDM_GETITEMCOUNT, 0, 0)
  ProcedureReturn nColumnCount
EndProcedure

Procedure removeAllGadgetColumns(nGadgetNo)
  ; This procedure was written to replace the PureBasic command RemoveGadgetColumn(#Gadget, #PB_All) because of a possible PB bug.
  ; In one instance When RemoveGadgetColumn(#Gadget, #PB_All) was used, the program crashed on a subsequent call to AddGadgetColumn().
  Protected nColumnCount, n
  
  ; remove all existing columns
  nColumnCount = getGadgetColumnCount(nGadgetNo)
  For n = (nColumnCount-1) To 0 Step -1
    RemoveGadgetColumn(nGadgetNo, n)
  Next n
EndProcedure

Procedure setCheckboxStateFromBoolean(nGadgetNo, bBoolean)
  ; Do NOT use for scsCheckBoxGadget2() gadgets - use setOwnState() for those
  If bBoolean
    SGS(nGadgetNo, #PB_Checkbox_Checked)
  Else
    SGS(nGadgetNo, #PB_Checkbox_Unchecked)
  EndIf
EndProcedure

Procedure bringWindowToFront(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected bStickyStatus
  
  debugMsg(sProcName, #SCS_START)
  
  bStickyStatus = getWindowSticky(nWindowNo)
  If bStickyStatus = #False
    setWindowSticky(nWindowNo, #True)   ; forces window to front
    setWindowSticky(nWindowNo, #False)  ; now clear the sticky state
  EndIf
  
EndProcedure

Procedure scsOpenWindow(WindowNo, x, y, InnerWidth, InnerHeight, Title$, Flags, HostWindow)
  ; PROCNAMEC()
  ; This procedure created 15Oct2020 11.8.3.2br following bug report and emails from Keith Jewell.
  ; It seems that the flag #PB_Window_WindowCentered doesn't always work, which I was able to reproduce.
  ; scsOpenWindow therefore simulates #PB_Window_WindowCentered by calculating the required x and y positions for the window.
  
  ; Note that calls to scsOpenWindow() require the last parameter to be HostWindow, not WindowID(HostWindow)
  
  Protected nReqdXPos, nReqdYPos, nReqdFlags
  Protected nHostWindowX, nHostWindowY, nHostWindowHeight, nHostWindowWidth
  Protected nResult
  
  ; debugMsg0(sProcName, #SCS_START + ", WindowNo=" + WindowNo + ", HostWindow=" + decodeWindow(HostWindow))
  If IsWindow(HostWindow)
    If Flags & #PB_Window_WindowCentered
      nReqdFlags = Flags ! #PB_Window_WindowCentered
      nHostWindowX = WindowX(HostWindow)
      nHostWindowY = WindowY(HostWindow)
      nHostWindowWidth = WindowWidth(HostWindow)
      nHostWindowHeight = WindowHeight(HostWindow)
      ; debugMsg0(sProcName, "nHostWindowX=" + nHostWindowX + ", nHostWindowY=" + nHostWindowY + ", nHostWindowWidth=" + nHostWindowWidth + ", nHostWindowHeight=" + nHostWindowHeight)
      nReqdXPos = nHostWindowX + ((nHostWindowWidth - InnerWidth) / 2)
      nReqdYPos = nHostWindowY + ((nHostWindowHeight - InnerHeight) / 2)
      ; debugMsg0(sProcName, "calling OpenWindow(" + WindowNo + ", " + nReqdXPos + ", " + nReqdYPos + ", " + InnerWidth + ", " + InnerHeight + ", " + #DQUOTE$ + Title$ + #DQUOTE$ + ", $" + Hex(nReqdFlags) + ", WindowID(" + decodeWindow(HostWindow) + ")")
      nResult = OpenWindow(WindowNo, nReqdXPos, nReqdYPos, InnerWidth, InnerHeight, Title$, nReqdFlags, WindowID(HostWindow))
    Else
      nResult = OpenWindow(WindowNo, x, y, InnerWidth, InnerHeight, Title$, Flags, WindowID(HostWindow))
    EndIf
  Else
    nResult = OpenWindow(WindowNo, x, y, InnerWidth, InnerHeight, Title$, Flags)
  EndIf
  ProcedureReturn nResult
  
EndProcedure

Procedure getGadgetContainerBackColor(nGadgetNo)
  ; This procedure was created to assist with own-drawn gadgets with rounded corners, to enable the area outside the required boundaries of the gadget to be painted with the backcolor of the parent container
  Protected nGadgetPropsIndex, nContainerGadgetNo, nContainerBackColor
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  If nGadgetPropsIndex >= 0
    nContainerGadgetNo = gaGadgetProps(nGadgetPropsIndex)\nContainerGadgetNo
    If IsGadget(nContainerGadgetNo)
      nContainerBackColor = GetGadgetColor(nContainerGadgetNo, #PB_Gadget_BackColor)
      ; debugMsg0(sProcName, getGadgetName(nContainerGadgetNo) + ", BackColor=RGB(" + Red(nContainerBackColor) + "," + Green(nContainerBackColor) + "," + Blue(nContainerBackColor) + ")")
    EndIf
  EndIf
  ProcedureReturn nContainerBackColor
EndProcedure

Procedure IsBitSet(InByte.a, Bit.a)
  ;Is het n'de bit van InByte gezet of niet?
  ; ProcedureReturn ((InByte & (2 ^ Bit)) > 0)
  ProcedureReturn (InByte & (1 << Bit))
EndProcedure

Procedure GadgetCallBackForIgnoreMouseWheel(hWnd, Message, wParam, lParam)
  ; Based on code posted by RSBasic in reply to my PB Forum Topic "Disable mouse wheel action on combobox?" posted 13Nov2017
  Protected lpPrevWndFunc.i, n
  
  Select Message
    Case #WM_MOUSEWHEEL
      ProcedureReturn 1
  EndSelect
  ; Not a mouse wheel event:
  For n = 0 To gnMaxGadgetCallBackInfo
    If hWnd = gaGadgetCallbackInfo(n)\cbGadgetId
      lpPrevWndFunc = gaGadgetCallbackInfo(n)\cbPrevWndFunc
      Break
    EndIf
  Next n
  ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Message, wParam, lParam)
EndProcedure

Procedure ignoreMouseWheelEvents(nGadgetNo, nArrayIncrement=20)
  ; Procedure that may be called for any gadget (particularly combobox gadgets) to prevent the mouse wheel changing values in the gadget
  
  gnMaxGadgetCallBackInfo + 1
  If gnMaxGadgetCallBackInfo > ArraySize(gaGadgetCallbackInfo())
    ReDim gaGadgetCallbackInfo(gnMaxGadgetCallBackInfo + nArrayIncrement)
  EndIf
  With gaGadgetCallbackInfo(gnMaxGadgetCallBackInfo)
    \cbGadgetId = GadgetID(nGadgetNo)
    \cbPrevWndFunc = SetWindowLongPtr_(\cbGadgetId, #GWL_WNDPROC, @GadgetCallBackForIgnoreMouseWheel()) ; callback to ignore mouse scroll wheel
  EndWith
EndProcedure

Procedure setScaInnerWidth(nGadgetNo, bBorderless=#True)
  ; The purpose of this procedure is to prevent the 'unnecessary' display of a HORIZONTAL scrollbar in a scrollable gadget.
  ; This procedure should only be called for sca's where all the required child gadgets for a row are to be visible.
  ; Originally written for Production Properties / Devices.
  Protected nViewableHeight, nReqdInnerWidth
  
  nViewableHeight = GadgetHeight(nGadgetNo)
  If bBorderless = #False
    nViewableHeight - gl3DBorderAllowanceY
  EndIf
  If GetGadgetAttribute(nGadgetNo, #PB_ScrollArea_InnerHeight) > nViewableHeight
    ; If the INNER HEIGHT of the sca is greater than the GADGET HEIGHT (less border allowabce if applicable) then a VERTICAL scrollbar
    ; will be displayed by PB, so set the required inner width to be the gadget width minus the width of the vertical scrollbar
    nReqdInnerWidth = GadgetWidth(nGadgetNo) - glScrollBarWidth
  Else
    nReqdInnerWidth = GadgetWidth(nGadgetNo)
  EndIf
  If bBorderless = #False
    nReqdInnerWidth - gl3DBorderAllowanceX
  EndIf
  If GetGadgetAttribute(nGadgetNo, #PB_ScrollArea_InnerWidth) <> nReqdInnerWidth
    SetGadgetAttribute(nGadgetNo, #PB_ScrollArea_InnerWidth, nReqdInnerWidth)
  EndIf
  
EndProcedure

; EOF