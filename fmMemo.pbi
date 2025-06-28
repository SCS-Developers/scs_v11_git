; File: fmMemo.pbi

EnableExplicit

Procedure WEN_Form_Unload(nWindowNo)
  PROCNAMECW(nWindowNo)
  
  debugMsg(sProcName, #SCS_START)
  
  With grWEN
    Select nWindowNo
      Case #WE1 ; main window
        getFormPosition(nWindowNo, @grMemoWindowMain, #True)
        setWindowVisible(nWindowNo, #False)
        \nMainSubPtr = -1
        SAW(#WMN)
        
      Case #WE2 ; preview window
        getFormPosition(nWindowNo, @grMemoWindowPreview, #True)
        ; scsCloseWindow(nWindowNo)
        setWindowVisible(nWindowNo, #False)
        unsetWindowModal(nWindowNo)
        \nPreviewSubPtr = -1
        WQE_setPreviewBtn(0)
        SAW(#WED)
        
    EndSelect
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEN_closeMemoWindowsIfOpen(bMainOnly=#False)
  PROCNAMEC()
  
  With grWEN
    If \nMainSubPtr >= 0
      If IsWindow(#WE1)
        getFormPosition(#WE1, @grMemoWindowMain, #True)
        setWindowVisible(#WE1, #False)
        \nMainSubPtr = -1
      EndIf
    EndIf
    
    If bMainOnly = #False
      If \nPreviewSubPtr >= 0
        ; shouldn't theoretically get here as #WE2 is a modal window and this procedure is called from fmMain
        If IsWindow(#WE2)
          getFormPosition(#WE2, @grMemoWindowPreview, #True)
          ; scsCloseWindow(#WE2)
          setWindowVisible(#WE2, #False)
          unsetWindowModal(#WE2)
          \nPreviewSubPtr = -1
          WQE_setPreviewBtn(0)
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WEN_drawCanvases(nWindowNo, bFirstTime=#False)
  PROCNAMECW(nWindowNo)
  Protected nIndex
  Protected nWidth, nHeight
  Protected n
  
  nIndex = nWindowNo - #WE1
  With WEN(nIndex)
    nWidth = GadgetWidth(\cvsDragBar)
    nHeight = GadgetHeight(\cvsDragBar)
    If StartDrawing(CanvasOutput(\cvsDragBar))
      Box(0,0,nWidth,nHeight,$303030)
      StopDrawing()
    EndIf
    
    nWidth = GadgetWidth(\cvsStatusBar)
    nHeight = GadgetHeight(\cvsStatusBar)
    If StartDrawing(CanvasOutput(\cvsStatusBar))
      Box(0,0,nWidth,nHeight,$303030)
      StopDrawing()
    EndIf
    
    If bFirstTime
      nWidth = GadgetWidth(\cvsCloseIcon)
      nHeight = GadgetHeight(\cvsCloseIcon)
      If StartDrawing(CanvasOutput(\cvsCloseIcon))
        Box(0,0,nWidth,nHeight,$303030)
        LineXY(0,3,nWidth-11,12,#SCS_White)
        LineXY(1,3,nWidth-10,12,#SCS_White)
        LineXY(0,12,nWidth-11,3,#SCS_White)
        LineXY(1,12,nWidth-10,3,#SCS_White)
        StopDrawing()
      EndIf
      
      nWidth = GadgetWidth(\cvsResizeIcon)
      nHeight = GadgetHeight(\cvsResizeIcon)
      If StartDrawing(CanvasOutput(\cvsResizeIcon))
        Box(0,0,nWidth,nHeight,$303030)
        For n = 0 To nHeight Step 5
          LineXY(nWidth-n,nHeight,nWidth,nHeight-n,#SCS_White)
        Next n
        StopDrawing()
      EndIf
      
    EndIf
  EndWith
EndProcedure

Procedure WEN_Form_Load(nWindowNo)
  PROCNAMECW(nWindowNo)
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(nWindowNo) = #False
    createfmMemo(nWindowNo)
    WEN_drawCanvases(nWindowNo, #True)
  EndIf
  
  Select nWindowNo
    Case #WE1
      setFormPosition(#WE1, @grMemoWindowMain)
      debugMsg(sProcName, "calling WMN_setKeyboardShortcuts(" + decodeWindow(nWindowNo) + ")")
      WMN_setKeyboardShortcuts(nWindowNo)
    Case #WE2
      setFormPosition(#WE2, @grMemoWindowPreview)
  EndSelect
  
  WEN_Form_Resize(nWindowNo)
  
  setWindowVisible(nWindowNo, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEN_Form_Resize(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected nIndex
  Protected nWindowWidth, nWindowHeight
  Protected nIconWidth
  Protected nMemoHeight, nDragBarHeight, nStatusBarHeight
  Protected nTop
  Protected nSubPtr
  Protected nMinWidth, nMinHeight
  Static nPrevWindowNo, nPrevSubPtr, nPrevWindowWidth, nPrevWindowHeight
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEN\bInFormResize
    ProcedureReturn
  EndIf
  grWEN\bInFormResize = #True
  
  nIndex = nWindowNo - #WE1
  
  If IsWindow(nWindowNo)
    
    Select nWindowNo
      Case #WE1
        nSubPtr = grWEN\nMainSubPtr
      Case #WE2
        nSubPtr = grWEN\nPreviewSubPtr
    EndSelect
    
    If nSubPtr >= 0
      ; set minimum width and height
      nMinWidth = 120
      nMinHeight = calcHeightFromWidthAndAspectRation(nMinWidth, aSub(nSubPtr)\nMemoAspectRatio)
      ; check resize does not make window smaller than the minimum width and height
      nWindowWidth = WindowWidth(nWindowNo)
      nWindowHeight = WindowHeight(nWindowNo)
      If (nWindowWidth < nMinWidth) And (nWindowHeight < nMinHeight)
        ResizeWindow(nWindowNo, #PB_Ignore, #PB_Ignore, nMinWidth, nMinHeight)
      ElseIf nWindowWidth < nMinWidth
        ResizeWindow(nWindowNo, #PB_Ignore, #PB_Ignore, nMinWidth, #PB_Ignore)
      ElseIf nWindowHeight < nMinHeight
        ResizeWindow(nWindowNo, #PB_Ignore, #PB_Ignore, #PB_Ignore, nMinHeight)
      EndIf
      
      nWindowWidth = WindowWidth(nWindowNo)
      nWindowHeight = WindowHeight(nWindowNo)
      If (nWindowNo <> nPrevWindowNo) Or (nSubPtr <> nPrevSubPtr) Or (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) ; test avoids continual repainting
        
        With WEN(nIndex)
          nIconWidth = GadgetWidth(\cvsCloseIcon)
          nDragBarHeight = GadgetHeight(\cvsDragBar)
          nStatusBarHeight = GadgetHeight(\cvsStatusBar)
          nMemoHeight = nWindowHeight - nDragBarHeight - nStatusBarHeight
          ; dragbar
          ResizeGadget(\cvsDragBar,#PB_Ignore,#PB_Ignore,nWindowWidth-nIconWidth,#PB_Ignore)
          ResizeGadget(\cvsCloseIcon,nWindowWidth-nIconWidth,#PB_Ignore,#PB_Ignore,#PB_Ignore)
          ; memo gadget
          \rchMemoObject\Resize(0, nDragBarHeight, nWindowWidth, nMemoHeight)
          debugMsg(sProcName, "calling WEN_displayMemo(" + getSubLabel(nSubPtr) + ", " + nIndex + ")")
          WEN_displayMemo(nSubPtr, nIndex)
          ; status bar
          ResizeGadget(\cvsStatusBar, #PB_Ignore, (nWindowHeight-nStatusBarHeight), (nWindowWidth-nIconWidth), #PB_Ignore)
          debugMsg(sProcName, "ResizeGadget(\cvsStatusBar, #PB_Ignore, " + Str(nWindowHeight-nStatusBarHeight) + ", " + Str(nWindowWidth-nIconWidth) + ", #PB_Ignore)")
          ResizeGadget(\cvsResizeIcon, (nWindowWidth-nIconWidth), (nWindowHeight-nStatusBarHeight), #PB_Ignore, #PB_Ignore)
          WEN_drawCanvases(nWindowNo)
        EndWith
        
        If gbEditing
          grWEN\bFormResizedInEditor = #True
        EndIf
        nPrevWindowNo = nWindowNo
        nPrevSubPtr = nSubPtr
        nPrevWindowWidth = nWindowWidth
        nPrevWindowHeight = nWindowHeight
        
      EndIf
    EndIf
  EndIf
  
  grWEN\bInFormResize = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEN_setInitialSize(nWindowNo, pSubPtr)
  PROCNAMECW(nWindowNo)
  Protected nIndex
  Protected nReqdWindowWidth, nReqdWindowHeight
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = nWindowNo - #WE1
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nMemoDisplayWidth=" + \nMemoDisplayWidth + ", \nMemoDisplayHeight=" + \nMemoDisplayHeight)
      If (\nMemoDisplayWidth > 0) And (\nMemoDisplayHeight > 0)
        nReqdWindowWidth = \nMemoDisplayWidth
        nReqdWindowHeight = \nMemoDisplayHeight + GadgetHeight(WEN(nIndex)\cvsDragBar) + GadgetHeight(WEN(nIndex)\cvsStatusBar)
        ; debugMsg(sProcName, "calling ResizeWindow(" + decodeWindow(nWindowNo) + ", #PB_Ignore, #PB_Ignore, " + nReqdWindowWidth + ", " + nReqdWindowHeight + ")")
        If (WindowWidth(nWindowNo) <> nReqdWindowWidth) Or (WindowHeight(nWindowNo) <> nReqdWindowHeight)
          debugMsg(sProcName, "ResizeWindow(nWindowNo, #PB_Ignore, #PB_Ignore, " + nReqdWindowWidth + ", " + nReqdWindowHeight + ")")
          ResizeWindow(nWindowNo, #PB_Ignore, #PB_Ignore, nReqdWindowWidth, nReqdWindowHeight)
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEN_drawTitleBarForMainMemoPanel(pSubPtr=-1, bHot=#False)
  PROCNAMECS(pSubPtr)
  Protected nMemoWidth, nMemoTitleWidth
  Protected nSize
  Protected nLeft, nRight, nTop, nBottom
  Protected sTitle.s, nCloseBackColor, nTitleBarInternalHeight
  Static nCurrSubPtr, bCurrHot, nCurrMemoWidth
  
  ; debugMsg(sProcName, #SCS_START + ", bHot=" + strB(bHot))
  
  With WMN
    nMemoWidth = GadgetWidth(\cntMemo)
    nMemoTitleWidth = GadgetWidth(\cvsMemoTitleBar)
    ; debugMsg(sProcName, "pSubPtr=" + pSubPtr + ", nMemoWidth=" + nMemoWidth + ", nCurrMemoWidth=" + nCurrMemoWidth + ", nMemoTitleWidth=" + nMemoTitleWidth)
    If (pSubPtr = nCurrSubPtr) And (bHot = bCurrHot) And (nMemoWidth = nCurrMemoWidth) And (nMemoTitleWidth = nMemoWidth)
      ; no change to memo title bar, so exit
      ; debugMsg(sProcName, "no change")
      ProcedureReturn
    EndIf
    If IsGadget(\cvsMemoTitleBar)
      If nMemoTitleWidth <> nMemoWidth
        ResizeGadget(\cvsMemoTitleBar, #PB_Ignore, #PB_Ignore, nMemoWidth, #PB_Ignore)
        ; debugMsg(sProcName, "ResizeGadget(\cvsMemoTitleBar, #PB_Ignore, #PB_Ignore, " + nMemoWidth + ", #PB_Ignore)")
      EndIf
      If StartDrawing(CanvasOutput(WMN\cvsMemoTitleBar))
        Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
        nTitleBarInternalHeight = OutputHeight() - 1  ; 'internal height' excludes the single-line border that will be drawn at the bottom of the title bar
        If pSubPtr >= 0
          ; draw sub-cue no. and description
          sTitle = Trim(getSubLabel(pSubPtr) + "  " + aSub(pSubPtr)\sSubDescr)
          DrawText(5, 2, sTitle, #SCS_White, #SCS_Black)
          ; draw X close button
          nSize = nTitleBarInternalHeight - 8
          nTop = 4
          nRight = OutputWidth() - 6
          nLeft = nRight - nSize - 1
          nBottom = nTop + nSize - 1
          If bHot
            nCloseBackColor = #SCS_Red
          Else
            nCloseBackColor = #SCS_Black
          EndIf
          Box(nLeft-5, 0, OutputWidth()-(nLeft-5), nTitleBarInternalHeight, nCloseBackColor)
          LineXY(nLeft, nTop, nRight, nBottom, #SCS_White)
          LineXY(nLeft, nBottom, nRight, nTop, #SCS_White)
          grMain\nMainMemoSubPtr = pSubPtr
          grMain\nMainMemoCloseButtonLeft = nLeft - 6
          grMain\bMainMemoCloseButtonVisible = #True
          ; now draw the single-line border at the bottom of the title bar (omitted if the title bar content is not displayed)
          LineXY(0, OutputHeight()-1, OutputWidth(), OutputHeight()-1, #SCS_Light_Grey)
        Else
          grMain\nMainMemoSubPtr = -1
          grMain\bMainMemoCloseButtonVisible = #False
        EndIf
        StopDrawing()
      EndIf ; EndIf StartDrawing(CanvasOutput(WMN\cvsMemoTitleBar))
    EndIf ; EndIf IsGadget(\cvsMemoTitleBar)
    nCurrSubPtr = pSubPtr
    bCurrHot = bHot
    nCurrMemoWidth = nMemoWidth
  EndWith
  
EndProcedure

Procedure WEN_displayMemoInMainMemoPanel(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nTargetWidth, nTargetHeight
  Protected sMyRTFText.s
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      WMN\rchMainMemoObject\SetCtrlBackColor(\nMemoPageColor)
      WMN\rchMainMemoObject\SetTextBackColor(\nMemoPageColor)
      WMN\rchMainMemoObject\SetTextColor(\nMemoTextColor)
      If \nMemoTextBackColor <> -1
        WMN\rchMainMemoObject\SetTextBackColor(\nMemoTextBackColor)
      EndIf
      nTargetWidth = WMN\rchMainMemoObject\GetWidth()
      nTargetHeight = WMN\rchMainMemoObject\GetHeight()
      
      ; debugMsg(sProcName, "nTargetWidth=" + nTargetWidth + ", nTargetHeight=" + nTargetHeight) 
      
      sMyRTFText = WEN_resizeMemoFonts(pSubPtr, nTargetWidth, nTargetHeight)
      ; debugMsg(sProcName, "sMyRTFText=" + #DQUOTE$ + sMyRTFText + #DQUOTE$)
      WMN\rchMainMemoObject\SetTextEx(sMyRTFText)
      
;       ; AUTOSCROLL
;       SendMessage_(GadgetID(WMN\rchMainMemo), #EM_SETSEL, -1, -1)

      ; debugMsg(sProcName, "calling WEN_drawTitleBarForMainMemoSplitScreen(" + getSubLabel(pSubPtr) + ")")
      WEN_drawTitleBarForMainMemoPanel(pSubPtr)
      
      UpdateWindow_(WindowID(#WMN))
      
    EndWith
  EndIf
  
EndProcedure

Procedure WEN_displayMemo(pSubPtr, nIndex)
  PROCNAMECS(pSubPtr)
  Protected nTargetWidth, nTargetHeight
  Protected sMyRTFText.s
  Protected nWindowNo
  
  debugMsg(sProcName, #SCS_START + ", pSubPtr=" + pSubPtr + ", nIndex=" + nIndex)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      nWindowNo = #WE1 + nIndex
      If GetWindowColor(nWindowNo) <> \nMemoPageColor
        SetWindowColor(nWindowNo, \nMemoPageColor)
      EndIf
      WEN(nIndex)\rchMemoObject\SetCtrlBackColor(\nMemoPageColor)
      WEN(nIndex)\rchMemoObject\SetTextBackColor(\nMemoPageColor)
      WEN(nIndex)\rchMemoObject\SetTextColor(\nMemoTextColor)
      If \nMemoTextBackColor <> -1
        WEN(nIndex)\rchMemoObject\SetTextBackColor(\nMemoTextBackColor)
      EndIf
      nTargetWidth = WEN(nIndex)\rchMemoObject\GetWidth()
      nTargetHeight = WEN(nIndex)\rchMemoObject\GetHeight()
      debugMsg(sProcName, "nWindowNo=" + decodeWindow(nWindowNo) + ", nTargetWidth=" + nTargetWidth + ", nTargetHeight=" + nTargetHeight) 
      
      sMyRTFText = WEN_resizeMemoFonts(pSubPtr, nTargetWidth, nTargetHeight)
      WEN(nIndex)\rchMemoObject\SetTextEx(sMyRTFText)
      
      ; added 25Jan2019 11.8.0.2
      ; the following call to UpdateWindow_() appears to be necessary following testing of Marco's "space journey demo" cue file that contains many memo cues
      ; but which were not being displayed at the correct times - sometimes the displayt would appear slightly late or not at all until a later memo cue was played
      UpdateWindow_(WindowID(nWindowNo))
      ; end added 25Jan2019 11.8.0.2
      
    EndWith
  EndIf
  
EndProcedure

Procedure WEN_Form_Show(nWindowNo, pSubPtr)
  PROCNAMECW(nWindowNo)
  Protected nIndex
  
  debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr))
  
  ; moved here 29Jan2019 11.8.0.2ad as setting grWEN\nMainSubPtr or grWEN\nPreviewSubPtr must be done BEFORE calling WEN_Form_Load() as WEN_Form_Load() calls WEN_Form_Resize() which needs these fields
  Select nWindowNo
    Case #WE1 ; main window
      grWEN\nMainSubPtr = pSubPtr
    Case #WE2 ; preview window
      grWEN\nPreviewSubPtr = pSubPtr
  EndSelect
  ; end moved here 29Jan2019 11.8.0.2ad
  
  If IsWindow(nWindowNo) = #False
    WEN_Form_Load(nWindowNo)
  EndIf
  
  If nWindowNo = #WE1
    If GetActiveWindow() <> #WMN
      SAW(#WMN)
    EndIf
  EndIf
  
  WEN_setInitialSize(nWindowNo, pSubPtr)
  
  ; the code above to set grWEN\nMainSubPtr etc was here pre 11.8.0.2ad
  
  If nWindowNo = #WE2
    setWindowModal(#WE2, #True)
  EndIf
  
  nIndex = nWindowNo - #WE1
  debugMsg(sProcName, "calling WEN_displayMemo(" + getSubLabel(pSubPtr) + ", " + nIndex + ")")
  WEN_displayMemo(pSubPtr, nIndex)
  
  setWindowVisible(nWindowNo, #True)
  
;   ; CS 31-07-2018 - Fix for Memo Issue relating to incorrect sizing and control location
;   If grWEN\bFormResizedInEditor
;     ; debugMsg(sProcName, "calling ResizeWindow(" + decodeWindow(nWindowNo) + ", " + Str(WindowX(nWindowNo)+1) + ", " + Str(WindowY(nWindowNo)+1) + ", " + Str(WindowWidth(nWindowNo)+1) + ", " + Str(WindowHeight(nWindowNo)+1) + ")")
;     ResizeWindow(nWindowNo, WindowX(nWindowNo)+1, WindowY(nWindowNo)+1, WindowWidth(nWindowNo)+1, WindowHeight(nWindowNo)+1)
;     grWEN\bFormResizedInEditor = #False
;   EndIf

  If nWindowNo = #WE1
    If GetActiveWindow() <> #WMN
      SAW(#WMN)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEN_cvsDragBar_Event(nWindowNo)
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop
  
  With grWEN
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        \nWindowStartLeft = WindowX(nWindowNo)
        \nWindowStartTop = WindowY(nWindowNo)
        \nDragBarStartX = DesktopMouseX()
        \nDragBarStartY = DesktopMouseY()
        \bDragBarMoving = #True
        
      Case #PB_EventType_MouseMove
        If \bDragBarMoving
          nDeltaX = \nDragBarStartX - DesktopMouseX()
          nDeltaY = \nDragBarStartY - DesktopMouseY()
          nNewLeft = \nWindowStartLeft - nDeltaX
          nNewTop = \nWindowStartTop - nDeltaY
          ; debugMsg(sProcName, "calling ResizeWindow(" + decodeWindow(nWindowNo) + ", " + nNewLeft + ", " + nNewTop + ", #PB_Ignore, #PB_Ignore)")
          ResizeWindow(nWindowNo, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bDragBarMoving = #False
        If nWindowNo = #WE1
          SAW(#WMN)
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WEN_cvsResizer_Event(nWindowNo)
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewWidth, nNewHeight
  Protected nMemoWidth, nMemoHeight
  Protected nSubPtr
  Protected u
  Protected nIndex
  
  nIndex = nWindowNo - #WE1
  
  With grWEN
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        \nWindowStartWidth = WindowWidth(nWindowNo)
        \nWindowStartHeight = WindowHeight(nWindowNo)
        \nResizerStartX = DesktopMouseX()
        \nResizerStartY = DesktopMouseY()
        \bResizerMoving = #True
        
      Case #PB_EventType_MouseMove
        If \bResizerMoving
          nDeltaX = \nResizerStartX - DesktopMouseX()
          nDeltaY = \nResizerStartY - DesktopMouseY()
          nNewWidth = \nWindowStartWidth - nDeltaX
          nNewHeight = \nWindowStartHeight - nDeltaY
          ; debugMsg(sProcName, "calling ResizeWindow(" + decodeWindow(nWindowNo) + ", #PB_Ignore, #PB_Ignore, " + nNewWidth + ", " + nNewHeight + ")")
          ResizeWindow(nWindowNo, #PB_Ignore, #PB_Ignore, nNewWidth, nNewHeight)
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bResizerMoving = #False
        
        If nWindowNo = #WE2 ; preview, so called from editor
          If grWEN\nPreviewSubPtr >= 0
            nSubPtr = grWEN\nPreviewSubPtr
            nMemoWidth = GadgetWidth(WEN(nIndex)\rchMemo)
            nMemoHeight = GadgetHeight(WEN(nIndex)\rchMemo)
            If (nMemoWidth <> aSub(nSubPtr)\nMemoDisplayWidth) Or (nMemoHeight <> aSub(nSubPtr)\nMemoDisplayHeight)
              u = preChangeSubL(#True, Lang("WEN","Resize"))
              aSub(nSubPtr)\nMemoDisplayWidth = nMemoWidth
              aSub(nSubPtr)\nMemoDisplayHeight = nMemoHeight
              debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nMemoDisplayWidth=" + aSub(nSubPtr)\nMemoDisplayWidth + ", \nMemoDisplayHeight=" + aSub(nSubPtr)\nMemoDisplayHeight)
              postChangeSubL(u, #False)
            EndIf
          EndIf
        EndIf
        
        If nWindowNo = #WE1
          SAW(#WMN)
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WEN_EventHandler()
  PROCNAMEC()
  Protected nIndex
  
  nIndex = gnEventWindowNo - #WE1
  With WEN(nIndex)
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow  ; #PB_Event_CloseWindow
        WEN_Form_Unload(gnEventWindowNo)
        
      Case #PB_Event_SizeWindow ; #PB_Event_SizeWindow
        WEN_Form_Resize(gnEventWindowNo)
        
      Case #PB_Event_Menu ; #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + gnEventMenu + " (" + decodeMenuItem(gnEventMenu) + ")")
        Select gnEventMenu
            ; fmMain keyboard shortcut functions
          Case #SCS_ALLF_DummyFirst To #SCS_ALLF_DummyLast
            Debug "gnEventMenu=" + decodeMenuItem(gnEventMenu)
            If gnEventWindowNo = #WE1
              WMN_processShortcut(gnEventMenu)
            EndIf
        EndSelect
        
      Case #WM_RBUTTONDOWN  ; #WM_RBUTTONDOWN
        ; Debug "#WM_RBUTTONDOWN"
        If gnEventWindowNo = #WE1
          If WMN_processRightClick()
            ProcedureReturn
          EndIf
        EndIf
        
      Case #PB_Event_Gadget ; #PB_Event_Gadget
        If gnEventType = #PB_EventType_RightClick
          If gnEventWindowNo = #WE1
            If WMN_processRightClick()
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \cvsCloseIcon
            If gnEventType = #PB_EventType_LeftClick
              If gnEventWindowNo = #WE1 ; main window
                If grWEN\nMainSubPtr >= 0
                  If (aSub(grWEN\nMainSubPtr)\bSubTypeE) And (aSub(grWEN\nMainSubPtr)\nSubState < #SCS_CUE_COMPLETED)
                    stopSub(grWEN\nMainSubPtr, "E", #True, #False)
                  EndIf
                EndIf
              EndIf
              WEN_Form_Unload(gnEventWindowNo)
            EndIf
            
          Case \cvsDragBar
            WEN_cvsDragBar_Event(gnEventWindowNo)
            
          Case \cvsStatusBar
            ; do nothing
            
          Case \cvsResizeIcon
            WEN_cvsResizer_Event(gnEventWindowNo)
            
          Default
            ; debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName( gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure.s WEN_resizeMemoFonts(pSubPtr, pTargetWidth, pTargetHeight)
  PROCNAMECS(pSubPtr)
  Protected nDesignWidth, nDesignHeight
  Protected fResizeFactorX.f, fResizeFactorY.f, fResizeFactor.f
  Protected sMyRTFText.s, sNewRTFText.s
  Protected sOldFontSize.s, nNewFontSize
  Protected n, nPos, nFSPos
  Protected sChar.s
  
  With aSub(pSubPtr)
    sMyRTFText = \sMemoRTFText
    If (\bMemoResizeFont) And (\nMemoDesignWidth > 0) ; nb \nMemoDesignWidth should be > 0 but test added to avoid possible 'divide by zero' crash
      nDesignWidth = \nMemoDesignWidth
      nDesignHeight = calcHeightFromWidthAndAspectRation(nDesignWidth, \nMemoAspectRatio)
      fResizeFactorX = pTargetWidth / nDesignWidth
      fResizeFactorY = pTargetHeight / nDesignHeight
      debugMsg(sProcName, "pTargetWidth=" + pTargetWidth + ", nDesignWidth=" + nDesignWidth + ", fResizeFactorX=" + StrF(fResizeFactorX,2))
      debugMsg(sProcName, "pTargetHeight=" + pTargetHeight + ", nDesignHeight=" + nDesignHeight + ", fResizeFactorY=" + StrF(fResizeFactorY,2))
      If fResizeFactorX < fResizeFactorY
        fResizeFactor = fResizeFactorX
      Else
        fResizeFactor = fResizeFactorY
      EndIf
      fResizeFactor = fResizeFactorX + fResizeFactorY / 2.0
      sNewRTFText = ""
      nPos = 1
      debugMsg(sProcName, "sMyRTFText =" + sMyRTFText)
      debugMsg(sProcName, "Len(sMyRTFText)=" + Len(sMyRTFText))
      While nPos < Len(sMyRTFText)
        nFSPos = FindString(sMyRTFText, "\fs", nPos)
        ; debugMsg(sProcName, "nPos=" + nPos + ", nFSPos=" + nFSPos)
        If nFSPos > 0
          nFSPos + 3
          sNewRTFText + Mid(sMyRTFText, nPos, (nFSPos - nPos))
          sOldFontSize = ""
          sChar = Mid(sMyRTFText, nFSPos, 1)
          ; debugMsg(sProcName, "Mid(sMyRTFText, " + Str(nFSPos) + ", 1) returned " + sChar)
          While (sChar <> " ") And (sChar <> "\")
            sOldFontSize + sChar
            nFSPos + 1
            sChar = Mid(sMyRTFText, nFSPos, 1)
            ; debugMsg(sProcName, "Mid(sMyRTFText, " + Str(nFSPos) + ", 1) returned " + sChar)
          Wend
          If IsNumeric(sOldFontSize)
            nNewFontSize = Val(sOldFontSize) * fResizeFactor
            ; make sure nNewFontSize is even
            nNewFontSize >> 1
            nNewFontSize << 1
            sNewRTFText + Str(nNewFontSize)
          EndIf
          debugMsg(sProcName, "nFSPos=" + nFSPos + ", sOldFontSize=" + sOldFontSize + ", fResizeFactor=" + StrF(fResizeFactor,2) + ", nNewFontSize=" + nNewFontSize)
        Else
          sNewRTFText + Mid(sMyRTFText, nPos)
          Break
        EndIf
        nPos = nFSPos
        ; debugMsg(sProcName, "nPos=" + Str(nPos))
      Wend
      debugMsg(sProcName, "sNewRTFText=" + sNewRTFText)
      sMyRTFText = sNewRTFText
    EndIf
  EndWith
  ProcedureReturn sMyRTFText
EndProcedure

Procedure WEN_displayMemoOnSecondaryScreen(pSubPtr, pVidPicTarget)
  PROCNAME(buildSubProcName(#PB_Compiler_Procedure, pSubPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nWindowIndex
  Protected nTargetWidth, nTargetHeight
  Protected sMyRTFText.s
  Protected nPrevPrimaryAudPtr, nPrevPlayingSubPtr
  
  debugMsg(sProcName, #SCS_START)
  
  ; If gnThreadNo > #SCS_THREAD_MAIN
    ; ; debugMsg3(sProcName, "transfer request to main thread")
    ; ; in the following call, set pCuePtrForRequestTime to prevent the control thread checking this cue until the SAM process has been actioned
    ; samAddRequest(#SCS_SAM_DISPLAY_PICTURE, pAudPtr, 0.0, pVidPicTarget, "", 0, bIgnoreFadein, aAud(pAudPtr)\nCueIndex)
    ; ProcedureReturn #True
  ; EndIf
  
  With aSub(pSubPtr)
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nWindowIndex = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(grVidPicTarget(pVidPicTarget)\nPrimaryAudPtr) + ", \nPlayingSubPtr=" + getSubLabel(grVidPicTarget(pVidPicTarget)\nPlayingSubPtr))
        nPrevPrimaryAudPtr = grVidPicTarget(pVidPicTarget)\nPrimaryAudPtr
        ; nPrevPlayingAudPtr = grVidPicTarget(pVidPicTarget)\nPlayingAudPtr
        nPrevPlayingSubPtr = grVidPicTarget(pVidPicTarget)\nPlayingSubPtr
        WVN(nWindowIndex)\rchMemoObject\SetCtrlBackColor(\nMemoPageColor)
        WVN(nWindowIndex)\rchMemoObject\SetTextBackColor(\nMemoPageColor)
        WVN(nWindowIndex)\rchMemoObject\SetTextColor(\nMemoTextColor)
        If \nMemoTextBackColor <> -1
          WVN(nWindowIndex)\rchMemoObject\SetTextBackColor(\nMemoTextBackColor)
        EndIf
        nTargetWidth = WVN(nWindowIndex)\rchMemoObject\GetWidth()
        nTargetHeight = WVN(nWindowIndex)\rchMemoObject\GetHeight()
        
        sMyRTFText = WEN_resizeMemoFonts(pSubPtr, nTargetWidth, nTargetHeight)
        WVN(nWindowIndex)\rchMemoObject\SetTextEx(sMyRTFText)
        HideGadget(WVN(nWindowIndex)\rchMemo, #False)
        CompilerIf #cTraceSetVisible
          debugMsg(sProcName, "(SetVisible) HideGadget(WVN(" + Str(nWindowIndex) + ")\rchMemo, #False)")
        CompilerEndIf
        
        grVidPicTarget(pVidPicTarget)\nPlayingSubPtr = pSubPtr
        debugMsg(sProcName, "(d1) grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(grVidPicTarget(pVidPicTarget)\nPlayingSubPtr))
        ; grVidPicTarget(pVidPicTarget)\nPlayingAudPtr = -1
        grVidPicTarget(pVidPicTarget)\nPrimaryAudPtr = -1
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(grVidPicTarget(pVidPicTarget)\nPrimaryAudPtr))
        
        debugMsg(sProcName, "calling closeWhatWasPlayingOnVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ", " + getAudLabel(nPrevPrimaryAudPtr) + ", " + getSubLabel(nPrevPlayingSubPtr) + ")")
        closeWhatWasPlayingOnVidPicTarget(pVidPicTarget, nPrevPrimaryAudPtr, nPrevPlayingSubPtr)
        
        ; repeat setting \nPlayingSubPtr as it may have been cleared by the close...() procedure
        grVidPicTarget(pVidPicTarget)\nPlayingSubPtr = pSubPtr
        debugMsg(sProcName, "(d2) grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(grVidPicTarget(pVidPicTarget)\nPlayingSubPtr))
        
      Default
        debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
        
    EndSelect
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEN_hideMemoOnSecondaryScreen(pVidPicTarget)
  PROCNAMEC()
  Protected nWindowIndex
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_HIDE_MEMO_ON_SECONDARY_SCREEN, pVidPicTarget)
  Else
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nWindowIndex = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
        HideGadget(WVN(nWindowIndex)\rchMemo, #True)
        CompilerIf #cTraceSetVisible
          debugMsg(sProcName, "(SetVisible) HideGadget(WVN(" + Str(nWindowIndex) + ")\rchMemo, #False)")
        CompilerEndIf
    EndSelect
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF
