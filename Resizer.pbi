; File: Resizer.pbi

EnableExplicit

Procedure resizeControl(nGadgetNo, nToolBarHeight, fReqdYFactor.f=0, nReqdWidth=-1, bTrace=#False, fReqdXFactor.f=0, bChangeLeft=#True, bChangeTop=#True, bChangeWidth=#True, bChangeHeight=#True)
  PROCNAMECG(nGadgetNo)
  Protected nCurrLeft, nCurrTop, nCurrWidth, nCurrHeight
  Protected nLeft, nTop, nWidth, nHeight
  Protected bFixLeft, bFixTop, bFixWidth, bFixHeight
  Protected nResizeFlags
  Protected nGadgetPropsIndex
  Protected fMyYFactor.f, fMyXFactor.f

  ; debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  nResizeFlags = getResizeFlags(nGadgetNo)
  If (nResizeFlags & #SCS_RESIZE_IGNORE) <> 0
    ProcedureReturn
  EndIf
  If (nResizeFlags & #SCS_RESIZE_FIX_LEFT) <> 0
    bFixLeft = #True
  EndIf
  If (nResizeFlags & #SCS_RESIZE_FIX_TOP) <> 0
    bFixTop = #True
  EndIf
  If (nResizeFlags & #SCS_RESIZE_FIX_WIDTH) <> 0
    bFixWidth = #True
  EndIf
  If (nResizeFlags & #SCS_RESIZE_FIX_HEIGHT) <> 0
    bFixHeight = #True
  EndIf
  ; If bTrace
    ; debugMsg(sProcName, "nResizeFlags=" + nResizeFlags + ", bFixLeft=" + strB(bFixLeft) + ", bFixTop=" + strB(bFixTop) + ", bFixWidth=" + strB(bFixWidth) + ", bFixHeight=" + strB(bFixHeight))
  ; EndIf
  
  If fReqdXFactor = 0
    fMyXFactor = gfMainXFactor
  Else
    fMyXFactor = fReqdXFactor
  EndIf
  
  If fReqdYFactor = 0
    fMyYFactor = gfMainYFactor
  Else
    fMyYFactor = fReqdYFactor
  EndIf
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  With gaGadgetProps(nGadgetPropsIndex)
    debugMsgC(sProcName, "gaGadgetProps(" + nGadgetPropsIndex + ")\nOrigLeft=" + \nOrigLeft + ", \nOrigTop=" + \nOrigTop + ", \nOrigWidth=" + \nOrigWidth + ", \nOrigHeight=" + \nOrigHeight)
    nLeft = \nOrigLeft
    nTop = \nOrigTop
    nWidth = \nOrigWidth
    nHeight = \nOrigHeight
  EndWith
  
  If bFixLeft = #False
    nLeft * fMyXFactor
  EndIf
  
  If bFixTop = #False
    nTop = ((nTop - nToolBarHeight) * fMyYFactor) + nToolBarHeight
  EndIf
  
  If nReqdWidth >= 0
    nWidth = nReqdWidth
  ElseIf bFixWidth = #False
    nWidth * fMyXFactor
  EndIf
  
  If bFixHeight = #False
    nHeight * fMyYFactor
  EndIf
  
  If bChangeLeft = #False
    nLeft = #PB_Ignore
  EndIf
  If bChangeTop = #False
    nTop = #PB_Ignore
  EndIf
  If bChangeWidth = #False
    nWidth = #PB_Ignore
  EndIf
  If bChangeHeight = #False
    nHeight = #PB_Ignore
  EndIf
  
  ; 01Jun2019 11.8.1.1ae added test on current size and position following bug reported by Dan Virtue that caused a stack overflow
  nCurrLeft = GadgetX(nGadgetNo)
  nCurrTop = GadgetY(nGadgetNo)
  nCurrWidth = GadgetWidth(nGadgetNo)
  nCurrHeight = GadgetHeight(nGadgetNo)
  If nLeft <> nCurrLeft Or nTop <> nCurrTop Or nWidth <> nCurrWidth Or nHeight <> nCurrHeight
    debugMsgC(sProcName, "calling ResizeGadget(" + getGadgetName(nGadgetNo) + ", " + nLeft + ", " + nTop + ", " + nWidth + ", " + nHeight + ")  currently " +
                         GadgetX(nGadgetNo) + ", " + GadgetY(nGadgetNo) + ", " + GadgetWidth(nGadgetNo) + ", " + GadgetHeight(nGadgetNo))
    ResizeGadget(nGadgetNo, nLeft, nTop, nWidth, nHeight)
    If bFixHeight = #False
      ; debugMsg(sProcName, "calling scsSetGadgetFont(G" + nGadgetNo + ", " + gaGadgetProps(nGadgetNo)\nFontNo + ")")
      scsSetGadgetFont(nGadgetNo, gaGadgetProps(nGadgetPropsIndex)\nFontNo)
    EndIf
  EndIf

EndProcedure

Procedure resizeForm(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected isVisible 
  Protected n, nToolBarHeight 
  Protected nGadgetPropsIndex
  Protected bTrace

  debugMsg(sProcName, #SCS_START)
  
  If grResizer\bRunning = #False
    grResizer\bRunning = #True
    CompilerIf #cTraceGadgets Or #cTraceResizer
      bTrace = #True
    CompilerEndIf
    
    nToolBarHeight = gaWindowProps(nWindowNo)\nToolBarHeight
    debugMsg(sProcName, "nToolBarHeight=" + nToolBarHeight)
    
    isVisible = getWindowVisible(nWindowNo)
    
    For n = (#SCS_GADGET_BASE_NO+1) To gnMaxGadgetNo
      nGadgetPropsIndex = getGadgetPropsIndex(n)
      With gaGadgetProps(nGadgetPropsIndex)
        If \nGWindowNo = nWindowNo
          ; ignore cue panels and slider controls - they are resized separately
          If (\nCuePanelNo = -1) And (\nSliderNo = -1)
            If \nContainerLevel = 0
              resizeControl(n, nToolBarHeight, 0, -1, bTrace)
            Else
              resizeControl(n, 0, 0, -1, bTrace)
            EndIf
          EndIf
        EndIf
      EndWith
    Next n
    
    If getWindowVisible(nWindowNo) <> isVisible
      ; debugMsg(sProcName, "(>2) WindowX(#WMN)=" + WindowX(#WMN) + ", WindowY(#WMN)=" + WindowY(#WMN) + ", WindowWidth(#WMN)=" + WindowWidth(#WMN) + ", WindowHeight(#WMN)=" + WindowHeight(#WMN))
      setWindowVisible(nWindowNo, isVisible)
      ; debugMsg(sProcName, "(>3) WindowX(#WMN)=" + WindowX(#WMN) + ", WindowY(#WMN)=" + WindowY(#WMN) + ", WindowWidth(#WMN)=" + WindowWidth(#WMN) + ", WindowHeight(#WMN)=" + WindowHeight(#WMN))
    EndIf
    
    grResizer\bRunning = #False
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

; EOF