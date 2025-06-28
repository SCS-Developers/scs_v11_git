; File: fmEditor.pbi

EnableExplicit

; the following structure and global code is used in the code for drag-and-drop a cue
; and is based on an example in the PB Forum topic "Drag-n-Drop with image" posted by srod and modified by netmaestro
; a couple of Global fields for use when dragging our image window.
Structure _drag
  winDrag.i
  isHidden.i
  wdfont.i
  wdwidth.i
  wdheight.i
  wdimage.i
  wdig.i
  text.s
EndStructure
Global gDrag._drag

Procedure WED_mnuOpenFile_Click()
  openProd()
EndProcedure

Procedure WED_imgButtonTBS_Click(nButtonId)
  PROCNAMEC()
  Protected i, j, bCurrentState, nNodeKey, nCuePtr, nSubPtr
  Protected nNodePos
  Protected bHoldHotkeysInUse, bReloadCueMarkerArrays, bReloadHotkeyArray
  
  With WED
    
    bHoldHotkeysInUse = gbHotkeysInUse
    
    logKeyEvent(decodeStdBtnType(nButtonId) + ", gnSelectedNodeCuePtr=" + getCueLabel(gnSelectedNodeCuePtr) + ", gnSelectedNodeSubPtr=" + getSubLabel(gnSelectedNodeSubPtr) + ", gnSelectedNodeKey=" + gnSelectedNodeKey)
    
    Select nButtonId
      Case #SCS_STANDARD_BTN_EXPAND_ALL       ; expand all
        For nNodePos = 1 To CountGadgetItems(\tvwProdTree)
          If GetGadgetItemState(\tvwProdTree, nNodePos) & #PB_Tree_Collapsed
            nNodeKey = GetGadgetItemData(WED\tvwProdTree, nNodePos)
            nCuePtr = WED_getCueIndexForNodeKey(nNodeKey)
            If nCuePtr >= 0
              nSubPtr = aCue(nCuePtr)\nFirstSubIndex
              If nSubPtr >= 0
                If aSub(nSubPtr)\nNextSubIndex >= 0
                  SetGadgetItemState(WED\tvwProdTree, nNodePos, #PB_Tree_Expanded)
                EndIf
              EndIf
            EndIf
          EndIf
        Next nNodePos
        WED_setTBSButtons()
        
      Case #SCS_STANDARD_BTN_COLLAPSE_ALL       ; collapse all
        For nNodePos = 1 To CountGadgetItems(\tvwProdTree)
          If GetGadgetItemState(\tvwProdTree, nNodePos) & #PB_Tree_Expanded
            SetGadgetItemState(WED\tvwProdTree, nNodePos, #PB_Tree_Collapsed)
          EndIf
        Next nNodePos
        WED_setTBSButtons()
        
      Case #SCS_STANDARD_BTN_MOVE_UP       ; move up
        moveUpOrDown(gnSelectedNodeCuePtr, gnSelectedNodeSubPtr, gnSelectedNodeKey, #True)
        bReloadCueMarkerArrays = #True
        bReloadHotkeyArray = #True
        
      Case #SCS_STANDARD_BTN_MOVE_DOWN     ; move down
        moveUpOrDown(gnSelectedNodeCuePtr, gnSelectedNodeSubPtr, gnSelectedNodeKey, #False)
        bReloadCueMarkerArrays = #True
        bReloadHotkeyArray = #True
        
      Case #SCS_STANDARD_BTN_MOVE_RIGHT_UP  ; move right up (merge cue into previous cue)
        moveRightUp(gnSelectedNodeCuePtr, gnSelectedNodeSubPtr, gnSelectedNodeKey)
        bReloadCueMarkerArrays = #True
        
      Case #SCS_STANDARD_BTN_MOVE_LEFT     ; move left (make a sub-cue into a cue)
        moveLeft(gnSelectedNodeCuePtr, gnSelectedNodeSubPtr, gnSelectedNodeKey)
        bReloadCueMarkerArrays = #True
        bReloadHotkeyArray = #True
        
      Case #SCS_STANDARD_BTN_CUT    ; cut
        If WED_validateDisplayedItem()
          delCueOrSubCheck("Cut")
          WED_setTBSButtons()
          bReloadCueMarkerArrays = #True
          bReloadHotkeyArray = #True
        EndIf
        
      Case #SCS_STANDARD_BTN_COPY   ; copy
        If WED_validateDisplayedItem()
          copyCueOrSubToClipboard()
          WED_setTBSButtons()
        EndIf
        
      Case #SCS_STANDARD_BTN_PASTE  ; paste
        If WED_validateDisplayedItem()
          pasteFromClipboard(#True)
          WED_setTBSButtons()
          bReloadCueMarkerArrays = #True
          bReloadHotkeyArray = #True
        EndIf
       
      Case #SCS_STANDARD_BTN_DELETE ; delete
        delCueOrSubCheck("Delete")
        WED_setTBSButtons()
        bReloadCueMarkerArrays = #True
        bReloadHotkeyArray = #True
        
      Case #SCS_STANDARD_BTN_FIND ; find
        WED_processFindCue()
        
      Case #SCS_STANDARD_BTN_COPY_PROPS ; copy properties
        If WED_validateDisplayedItem()
          WCP_Form_Show(#True)
          WED_setTBSButtons()
        EndIf
        bReloadCueMarkerArrays = #True
        bReloadHotkeyArray = #True
        
    EndSelect
    
    If bReloadCueMarkerArrays
      debugMsg(sProcName, "calling loadCueMarkerArrays()")
      loadCueMarkerArrays()
    EndIf

    If gbHotkeysInUse <> bHoldHotkeysInUse Or bReloadHotkeyArray
      samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
    EndIf
    
    SAG(-1)
    
  EndWith

EndProcedure

Procedure WED_Form_Activate()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)

  If gbInImportFromCueFile Or gbInImportAudioFiles
    ProcedureReturn
  EndIf

  gbEditHasFocus = #True

  If grWED\bActivated = #False
    nCurrPos = -1
  EndIf

  setMouseCursorNormal()

  grWED\bActivated = #True
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WED_windowCallback(hwnd, uMsg, wparam, lparam)
  ; WED\tvwProdTree processing based on code supplied by srod in PB 'Coding Questions' forum topic: 'TreeGadget - left click problem'
  
  ; blocked out 3Dec2015 11.4.1.2q as the callback can require the user to click a second time on the sub-node of an expanded node, and on
  ; testing this there doesn't appear to be any reason for this callback - maybe the 'problem' reported in the forum topic has been fixed
  
  ; nb code in this procedure was totally removed 27Aug2019 11.8.2ai, but this 'dummy' procedure was left in as a reminder of the issue should there be some future consideration to use SetWindowCallback() for #WED
  ; if you want to view that removed code, see the source file fmEditor.pbi for SCS 11.8.1
  
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure 

Procedure WED_setsplEditVPos(bForceDefaultPos=#False)
  PROCNAMEC()
  Protected nSplitterLeft
  Protected nMaxSplitterLeft  ; nb max is also default
  
  nMaxSplitterLeft = WindowWidth(#WED) - gnEditorCntRightFixedWidth - gnVSplitterSeparatorWidth - gl3DBorderAllowanceX - GadgetX(WED\splEditV)
  If (grEditorPrefs\nSplitterPosEditV > 100) And (grEditorPrefs\nSplitterPosEditV < nMaxSplitterLeft) And (bForceDefaultPos = #False)
    nSplitterLeft = grEditorPrefs\nSplitterPosEditV
  Else
    nSplitterLeft = nMaxSplitterLeft
  EndIf
  
  If GGS(WED\splEditV) <> nSplitterLeft
    debugMsg(sProcName, "grEditorPrefs\nSplitterPosEditV=" + Str(grEditorPrefs\nSplitterPosEditV) + ", WindowWidth(#WED)=" + WindowWidth(#WED) + ", gnEditorCntRightFixedWidth=" + Str(gnEditorCntRightFixedWidth) + ", gnVSplitterSeparatorWidth=" + Str(gnVSplitterSeparatorWidth) + ", GadgetX(WED\splEditV)=" + Str(GadgetX(WED\splEditV)))
    debugMsg(sProcName, "calling SetGadgetState(WED\splEditV, " + Str(nSplitterLeft) + ")  (was " + Str(GetGadgetState(WED\splEditV)) + ")")
    SetGadgetState(WED\splEditV, nSplitterLeft)
    debugMsg(sProcName, "splitter repositioned, now at " + Str(GetGadgetState(WED\splEditV)))
  EndIf
  
EndProcedure

Procedure WED_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  If IsWindow(#WED)
    ; added 8Oct2019 11.8.2at following bug reports from Michael Schulte-Eickholt and 'Trohwold' (Forum)
    ; if #WED is minimized when fmCreateQF() is processed then errors occur because WindowWidth(#WED) returns 0 if the window is minimized
    If GetWindowState(#WED) = #PB_Window_Minimize
      debugMsg(sProcName, "calling SetWindowState(#WED, #PB_Window_Normal) because #WED currently minimized")
      SetWindowState(#WED, #PB_Window_Normal)
      debugMsg(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
    EndIf
    ; end added 8Oct2019 11.8.2at
    debugMsg(sProcName, "exiting because form already loaded")
    ProcedureReturn
  EndIf
  
  WED_loadFavArray()
  createfmEditor()
  
  WED_setEditorCueListFontSize()
  
  If grWED\nFormMinWidth = 0
    grWED\nFormMinWidth = WindowWidth(#WED)
    grWED\nCntLeftMinWidth = GadgetWidth(WED\cntLeft)
    grWED\nTreeMinWidth = GadgetWidth(WED\tvwProdTree)
    grWED\nFormMinHeight = WindowHeight(#WED)
  EndIf
  debugMsg(sProcName, "nFormMinWidth=" + Str(grWED\nFormMinWidth) + ", nCntLeftMinWidth=" + Str(grWED\nCntLeftMinWidth) + ",  nTreeMinWidth=" + Str(grWED\nTreeMinWidth))
  
  setFormPosition(#WED, @grEditWindow)
  
  WED_setsplEditVPos()
  WED_splEditVRepositioned()
  
  ; the 'design' state of the buttons is 'enabled'
  grWED\mbUndoEnabled = #True
  grWED\mbRedoEnabled = #True
  grWED\msUndoToolTip = ""
  grWED\msRedoToolTip = ""
  grWED\mbSaveEnabled = #True

  gbEditorFormLoaded = #True
  gnSelectedNodeCuePtr = -2
  gnSelectedNodeSubPtr = -2

  debugMsg(sProcName, "set keyboard shortcuts")
  WED_setKeyboardShortcuts()
  setSliderShortcuts(#WED)    ; not required directly by WED but by sub-forms like WQF
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nSplitterWidth, nSplitterHeight
  Protected nTreeHeight
  Protected nTemplateInfoTop, nClipboardInfoTop
  Protected nLeftOfCntLeftItems, nWidthOfCntLeftItems
  Protected nWindowWidth, nWindowHeight, nWindowState
  Static nPrevWindowWidth, nPrevWindowHeight, nPrevWindowState, bFirstTime = #True
  Protected nSplitterPosEditH, nSplitterPosEditV
  Protected nTop, nWidth
  Static bInProcedure
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  ; debugMsg(sProcName, #SCS_START + ", bForceProcessing=" + strB(bForceProcessing))
  If bInProcedure
    debugMsg(sProcName, "exiting because bInProcedure=" + strB(bInProcedure))
    ProcedureReturn
  EndIf
  bInProcedure = #True
  
  nWindowState = GetWindowState(#WED)
  If nWindowState <> #PB_Window_Minimize
    
    With WED
      
      nWindowWidth = WindowWidth(#WED)
      nWindowHeight = WindowHeight(#WED)
      ; debugMsg(sProcName, "nWindowWidth=" + nWindowWidth + ", nPrevWindowWidth=" + nPrevWindowWidth + ", nWindowHeight=" + nWindowHeight + ", nPrevWindowHeight=" + nPrevWindowHeight)
      ; only execute the main logic if the form really has been resized (or bForceProcessing) as this event is often raised for other reasons
      If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
        nPrevWindowWidth = nWindowWidth
        nPrevWindowHeight = nWindowHeight
        
        nSplitterWidth = nWindowWidth - GadgetX(\splEditV)
        nSplitterHeight = nWindowHeight - GadgetY(\splEditV)
        If grCED\bQADisplayed
          nSplitterHeight - GadgetHeight(WED\cntSpecialQA)
        ElseIf grCED\bQFDisplayed
          nSplitterHeight - GadgetHeight(WED\cntSpecialQF)
        EndIf
        
        grWED\bSkipNextSplitterRepositioned = #True  ; prevents recursive calls, as an event fires for the splitter gadget on resizing the splitter
        ResizeGadget(\splEditV, #PB_Ignore, #PB_Ignore, nSplitterWidth, nSplitterHeight)
        ; debugMsg(sProcName, "ResizeGadget(\splEditV, #PB_Ignore, #PB_Ignore, " + nSplitterWidth + ", " + nSplitterHeight + ")")
        ; now reset splitter position as it was prior to ResizeGadget() as ResizeGadget() may have changed the position
        ; debugMsg(sProcName, "calling WED_setsplEditVPos(#True)")
        WED_setsplEditVPos(#True)
        
        ResizeGadget(\cntTopPanel, #PB_Ignore, #PB_Ignore, nWindowWidth, #PB_Ignore)
        
        ResizeGadget(\cntLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSplitterHeight)
        ResizeGadget(\cntRight, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSplitterHeight)
        
        nWidthOfCntLeftItems = GadgetWidth(\cntLeft) - GadgetX(\tvwProdTree)
        nClipboardInfoTop = nSplitterHeight - GadgetHeight(\lblClipboardInfo) - gl3DBorderAllowanceY
        ResizeGadget(\lblClipboardInfo, #PB_Ignore, nClipboardInfoTop, nWidthOfCntLeftItems, #PB_Ignore)
        
        If grProd\bTemplate
          nTemplateInfoTop = nClipboardInfoTop - GadgetHeight(\cntTemplate)
          ResizeGadget(\cntTemplate, #PB_Ignore, nTemplateInfoTop, nWidthOfCntLeftItems, #PB_Ignore)
          ResizeGadget(\lblTemplateInfo, #PB_Ignore, #PB_Ignore, nWidthOfCntLeftItems, #PB_Ignore)
          setVisible(\cntTemplate, #True)
          nTreeHeight = nTemplateInfoTop - GadgetY(\tvwProdTree)
        Else
          setVisible(\cntTemplate, #False)
          nTreeHeight = nClipboardInfoTop - GadgetY(\tvwProdTree)
        EndIf
        
        ResizeGadget(\tvwProdTree, #PB_Ignore, #PB_Ignore, nWidthOfCntLeftItems, nTreeHeight)
        
        If IsGadget(WEC\splEditH)
          nSplitterPosEditH = GGS(WEC\splEditH)
          ; clear minimum sizes before resizing gadget
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_FirstMinimumSize, 0)
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondMinimumSize, 0)
          ; debugMsg(sProcName, "calling ResizeGadget(WEC\splEditH, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nSplitterHeight + ")")
          ResizeGadget(WEC\splEditH, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSplitterHeight)
          ; now recalculate and set minimum sizes
          WEC_setSplitterHMinSizes()
          ; now reset splitter position as it was prior to the above as ResizeGadget() or WEC_setSplitterHMinSizes() may have changed the position
          If GGS(WEC\splEditH) <> nSplitterPosEditH
            ; debugMsg(sProcName, "calling SGS(WEC\splEditH, " + nSplitterPosEditH + ")")
            SGS(WEC\splEditH, nSplitterPosEditH)
          EndIf
        EndIf
        
        If IsGadget(WEP\scaProdProperties)
          ; debugMsg(sProcName, "calling ResizeGadget(WEP\scaProdProperties, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + GadgetHeight(WED\cntRight) + ")")
          ResizeGadget(WEP\scaProdProperties, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(WED\cntRight))
        EndIf
        
        adjustEditorDetailsForSplitterSize()
        
        nWidth = nWindowWidth
        
        nTop = nWindowHeight - GadgetHeight(\cntSpecialQA)
        If GadgetY(\cntSpecialQA) <> nTop Or GadgetWidth(\cntSpecialQA) <> nWidth
          ; debugMsg(sProcName, "calling ResizeGadget(\cntSpecialQA, #PB_Ignore, " + nTop + ", " + nWidth + ", #PB_Ignore)")
          ResizeGadget(\cntSpecialQA, #PB_Ignore, nTop, nWidth, #PB_Ignore)
          SetGadgetAttribute(WED\cntSpecialQA, #PB_ScrollArea_InnerWidth, GadgetWidth(WED\cntSpecialQA))
          SetGadgetAttribute(WED\cntSpecialQA, #PB_ScrollArea_InnerHeight, GadgetHeight(WED\cntSpecialQA))
        EndIf
        
        nTop = nWindowHeight - GadgetHeight(\cntSpecialQF)
        ResizeGadget(\cntSpecialQF, #PB_Ignore, nTop, nWidth, #PB_Ignore)
        ; debugMsg(sProcName, "ResizeGadget(\cntSpecialQF, #PB_Ignore, " + nTop + ", " + nWidth + ", #PB_Ignore)")
        
      EndIf
      
      ; the following coding ensures the state (position) of \splEditV is correctly set after the form has been resized
      ; nb it took quite a bot of trial-and-error to get this right
      If GetWindowState(#WED) = #PB_Window_Maximize
        SetGadgetAttribute(\splEditV, #PB_Splitter_FirstMinimumSize, GadgetWidth(\cntLeft))
        SetGadgetAttribute(\splEditV, #PB_Splitter_SecondMinimumSize, GadgetWidth(\cntRight))
      Else
        If nPrevWindowState <> #PB_Window_Normal
          SetGadgetAttribute(\splEditV, #PB_Splitter_FirstMinimumSize, 50)
          SetGadgetAttribute(\splEditV, #PB_Splitter_SecondMinimumSize, GadgetWidth(\cntRight))
          WED_setsplEditVPos()
        EndIf
      EndIf
      
      grMG2\dSamplePositionsPerPixel = 0.0 ; forces \dSamplePositionsPerPixel to be recalculated
      
    EndWith
    
    ; debugMsg(sProcName, "WindowHeight(#WED)=" + WindowHeight(#WED) + ", WindowWidth(#WED)=" + WindowWidth(#WED))
    
  Else
    nPrevWindowWidth = -1
    
  EndIf
  
  nPrevWindowState = nWindowState
  bFirstTime = #False
  bInProcedure = #False
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_mnuCollect_Click()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  If gbMenuItemAvailable(#WED_mnuCollect) And gbMenuItemEnabled(#WED_mnuCollect)
    If validateChanges() = #False
      ProcedureReturn
    EndIf
    If WPF_Form_Show(#True, #SCS_MODRETURN_CREATE_PROD_FOLDER)
      ; if WPF_Form_Show() returns #True then windows was created, else user probably cancelled the 'collect' request when asked about saving changes
      SAW(#WPF)
    EndIf
  EndIf
  
EndProcedure

Procedure WED_mnuExportCues_Click()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  If gbMenuItemAvailable(#WED_mnuExportCues) And gbMenuItemEnabled(#WED_mnuExportCues)
    If valProd()
      If WED_validateDisplayedItem()
        WEX_Form_Show(#True)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure WED_mnuCreateOrResyncProdFolder_ModReturn(nProdFolderAction)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If nProdFolderAction = #PB_MessageRequester_Ok   ; indicates user clicked the 'OK' button, not the 'Cancel' or 'close window' buttons
    If grCollectOptions\bSwitchToCollected
      WED_applyChangesWrapper()
      debugMsg(sProcName, "calling redisplayEditorComponent()")
      redisplayEditorComponent()
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_mnuRecentFile_Click(Index)
  PROCNAMEC()
  Protected nFileNr
  
  nFileNr = Index + 1
  openRecentFile(nFileNr)
  SAW(#WED)
EndProcedure

Procedure WED_mnuProdTimer_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  WPT_Form_Show(#WED, #True)
  SAW(#WPT)
  
EndProcedure

Procedure WED_makeToolBarTBS() ; TBS = ToolBar Side
  PROCNAMEC()
  Protected n

  debugMsg(sProcName, #SCS_START)

  For n = 0 To 5
    setEnabled(WED\imgButtonTBS[n], #True)
  Next n

EndProcedure

Procedure WED_enableTBSButton(nButtonType, bEnable, sToolTipText.s = "")
  ; PROCNAMEC()
  Protected nIndex
  
  nIndex = WED_getTBSIndex(nButtonType)
  
  setEnabled(WED\imgButtonTBS[nIndex], bEnable)
  If Len(sToolTipText) > 0
    ; debugMsg(sProcName, "GadgetToolTip(G" + Str(WED\imgButtonTBS[nIndex]) + ", " + sToolTipText + ")")
    scsToolTip(WED\imgButtonTBS[nIndex], sToolTipText)
  EndIf
  
EndProcedure

Procedure WED_applyChangesWrapper()
  PROCNAMEC()
  Protected bValidationOK

  debugMsg(sProcName, #SCS_START)

  setMouseCursorBusy()
  
  If (grEditingOptions\bSaveAlwaysOn) And (gbEditorAndOptionsLocked = #False) And (grLicInfo\bPlayOnly = #False)
    WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
  Else
    WED_enableTBTButton(#SCS_TBEB_SAVE, #False)
  EndIf

  bValidationOK = editApplyChanges()
  If bValidationOK
    ; force a new undo group to be created on the next change
    debugMsg(sProcName, "setting grMUR\nPrimaryUndoGroupId=-1 (was " + grMUR\nPrimaryUndoGroupId + ")")
    grMUR\nPrimaryUndoGroupId = -1
    If (grRAI\nStatus & 7) <> 0
      ; grRAI/nStatus contains at least one of #SCS_RAI_STATUS_FILE (1), #SCS_RAI_STATUS_PROD (2) or #SCS_RAI_STATUS_CUE (4)
      sendOSCStatus()
    EndIf
  Else
    WED_setEditorButtons()
  EndIf
  
  setMouseCursorNormal()

  debugMsg(sProcName, #SCS_END + ", returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WED_setTBSButtons()
  PROCNAMEC()
  Protected i, bMulti
  Protected bEnableCollapseAll, bEnableExpandAll
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableMoveRightUp, sToolTipMoveRightUp.s
  Protected bEnableMoveLeft, sToolTipMoveLeft.s
  Protected sCue.s, sSubCue.s, nSubPtr
  Protected bEnableCut, sToolTipCut.s, sMenuTextCut.s
  Protected bEnableCopy, sToolTipCopy.s, sMenuTextCopy.s
  Protected bEnablePaste, sToolTipPaste.s, sMenuTextPaste.s
  Protected bEnableDelete, sToolTipDelete.s, sMenuTextDelete.s
  Protected bEnableCopyProps
  Protected nEndSubrCuePtr
  Protected sSubType.s
  Protected n, nNodeKey, nCuePtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling WED_setCueNodeExpandedBooleanFromTreeItemStates()")
  WED_setCueNodeExpandedBooleanFromTreeItemStates()
  
  If gnSelectedNodeCuePtr >= 1
    If gnSelectedNodeSubPtr < 0
      sCue = aCue(gnSelectedNodeCuePtr)\sCue + " (" + aCue(gnSelectedNodeCuePtr)\sCueDescr + ")"
      ; a cue has been selected
      If gnSelectedNodeCuePtr > 1
        bEnableMoveUp = #True
        ; sToolTipMoveUp = "Move " + sCue + " up"
        sToolTipMoveUp = LangPars("WED", "MoveCueUp", sCue)
      EndIf
      If gnSelectedNodeCuePtr < (gnCueEnd - 1)
        bEnableMoveDown = #True
        ; sToolTipMoveDown = "Move " + sCue + " down"
        sToolTipMoveDown = LangPars("WED", "MoveCueDn", sCue)
      EndIf
      If gnSelectedNodeCuePtr > 1
        bEnableMoveRightUp = #True
        ; sToolTipMoveRightUp = "Make " + sCue + " a sub-cue of " + aCue(gnSelectedNodeCuePtr-1)\sCue
        sToolTipMoveRightUp = LangPars("WED", "MakeCueASubcue", sCue, aCue(gnSelectedNodeCuePtr-1)\sCue)
        nSubPtr = aCue(gnSelectedNodeCuePtr)\nFirstSubIndex
        If nSubPtr >= 0
          If aSub(nSubPtr)\nNextSubIndex >= 0
            ; at least two sub-cues
            ; sToolTipMoveRightUp = "Move the sub-cues of " + sCue + " into " + aCue(gnSelectedNodeCuePtr-1)\sCue
            sToolTipMoveRightUp = LangPars("WED", "MoveSubcuesIntoCue", sCue, aCue(gnSelectedNodeCuePtr-1)\sCue)
          EndIf
        EndIf
      EndIf
    Else
      ; a sub-cue has been selected
      With aSub(gnSelectedNodeSubPtr)
        sCue = \sCue
        sSubCue = \sSubLabel + " (" + \sSubDescr + ")"
        If \nPrevSubIndex >= 0
          bEnableMoveUp = #True
          ; sToolTipMoveUp = "Move sub-cue " + sSubCue + " up within " + sCue
          sToolTipMoveUp = LangPars("WED", "MoveSubcueUpWithinCue", sSubCue, sCue)
        ElseIf gnSelectedNodeCuePtr > 1
          bEnableMoveUp = #True
          ; sToolTipMoveUp = "Move sub-cue " + sSubCue + " up into " + aCue(gnSelectedNodeCuePtr-1)\sCue
          sToolTipMoveUp = LangPars("WED", "MoveSubcueUpIntoCue", sSubCue, aCue(gnSelectedNodeCuePtr-1)\sCue)
        EndIf
        If \nNextSubIndex >= 0
          bEnableMoveDown = #True
          ; sToolTipMoveDown = "Move sub-cue " + sSubCue + " down within " + sCue
          sToolTipMoveDown = LangPars("WED", "MoveSubcueDnWithinCue", sSubCue, sCue)
        ElseIf gnSelectedNodeCuePtr < (gnCueEnd - 1)
          bEnableMoveDown = #True
          ; sToolTipMoveDown = "Move sub-cue " + sSubCue + " down into " + aCue(gnSelectedNodeCuePtr+1)\sCue
          sToolTipMoveDown = LangPars("WED", "MoveSubcueDnIntoCue", sSubCue, aCue(gnSelectedNodeCuePtr+1)\sCue)
        EndIf
        If \nPrevSubIndex >= 0  ; left2
          bEnableMoveLeft = #True
          If \nNextSubIndex < 0
            ; sToolTipMoveLeft = "Make sub-cue " + sSubCue + " a new cue"
            sToolTipMoveLeft = LangPars("WED", "MakeSubcueANewCue", sSubCue)
          Else
            ; sToolTipMoveLeft = "Make sub-cue " + sSubCue + " and the following sub-cues within " + sCue + ", a new cue"
            sToolTipMoveLeft = LangPars("WED", "MakeSubcuesANewCue", sSubCue, sCue)
          EndIf
        EndIf ; left2
      EndWith
    EndIf
  EndIf
  
  For i = 1 To gnLastCue
    bMulti = #False
    If aCue(i)\nFirstSubIndex >= 0
      If aSub(aCue(i)\nFirstSubIndex)\nNextSubIndex >= 0
        bMulti = #True
      EndIf
    EndIf
    If bMulti
      If aCue(i)\bNodeExpanded
        bEnableCollapseAll = #True
      Else
        bEnableExpandAll = #True
      EndIf
    EndIf
  Next i
  
  WED_enableTBSButton(#SCS_STANDARD_BTN_EXPAND_ALL, bEnableExpandAll)
  WED_enableTBSButton(#SCS_STANDARD_BTN_COLLAPSE_ALL, bEnableCollapseAll)

  WED_enableTBSButton(#SCS_STANDARD_BTN_MOVE_UP, bEnableMoveUp, sToolTipMoveUp)
  WED_enableTBSButton(#SCS_STANDARD_BTN_MOVE_DOWN, bEnableMoveDown, sToolTipMoveDown)
  WED_enableTBSButton(#SCS_STANDARD_BTN_MOVE_RIGHT_UP, bEnableMoveRightUp, sToolTipMoveRightUp)
  WED_enableTBSButton(#SCS_STANDARD_BTN_MOVE_LEFT, bEnableMoveLeft, sToolTipMoveLeft)
  
  If gnSelectedNodeCuePtr >= 0
    bEnableCut = #True
    sToolTipCut = Trim(grText\sTextCut + " " + gsSelectedNodeInfo)
    sMenuTextCut = sToolTipCut
    If gaShortcutsEditor(#SCS_ShortEditor_Cut)\sShortcutStr
      sMenuTextCut + Chr(9) + gaShortcutsEditor(#SCS_ShortEditor_Cut)\sShortcutStr
    EndIf
    
    bEnableCopy = #True
    sToolTipCopy = Trim(grText\sTextCopy + " " + gsSelectedNodeInfo)
    sMenuTextCopy = sToolTipCopy
    If gaShortcutsEditor(#SCS_ShortEditor_Copy)\sShortcutStr
      sMenuTextCopy + Chr(9) + gaShortcutsEditor(#SCS_ShortEditor_Copy)\sShortcutStr
    EndIf
    
    bEnableDelete = #True
    sToolTipDelete = Trim(grText\sTextDelete + " " + gsSelectedNodeInfo)
    sMenuTextDelete = sToolTipDelete
    ; no shortcut for delete, ie #SCS_ShortEditor_Delete does not exist
;     If gaShortcutsEditor(#SCS_ShortEditor_Delete)\sShortcutStr
;       sMenuTextDelete + Chr(9) + gaShortcutsEditor(#SCS_ShortEditor_Delete)\sShortcutStr
;     EndIf
  EndIf
  
  With WED
    WED_enableTBSButton(#SCS_STANDARD_BTN_CUT, bEnableCut, sToolTipCut)
    scsEnableMenuItem(#WED_mnuCueListPopupMenu, #WED_mnuCut, bEnableCut)
    scsSetMenuItemText(#WED_mnuCueListPopupMenu, #WED_mnuCut, sMenuTextCut)
    
    WED_enableTBSButton(#SCS_STANDARD_BTN_COPY, bEnableCopy, sToolTipCopy)
    scsEnableMenuItem(#WED_mnuCueListPopupMenu, #WED_mnuCopy, bEnableCopy)
    scsSetMenuItemText(#WED_mnuCueListPopupMenu, #WED_mnuCopy, sMenuTextCopy)
    
    WED_enableTBSButton(#SCS_STANDARD_BTN_DELETE, bEnableDelete, sToolTipDelete)
    scsEnableMenuItem(#WED_mnuCueListPopupMenu, #WED_mnuDelete, bEnableDelete)
    scsSetMenuItemText(#WED_mnuCueListPopupMenu, #WED_mnuDelete, sMenuTextDelete)
  EndWith
  
  If gbClipPopulated
    bEnablePaste = #True
    If (gnClipCueCount = 0) And (gnSelectedNodeCuePtr <= 0)
      bEnablePaste = #False
    EndIf
    If bEnablePaste
      If gnClipCueCount > 0
        sToolTipPaste = Trim(LangPars("WED", "PasteCueFromClipboard", gsSelectedCueInfo))
      ElseIf gnClipSubCount > 0
        sToolTipPaste = Trim(LangPars("WED", "PasteSubcueFromClipboard", gsSelectedNodeInfo))
      EndIf
      sMenuTextPaste = sToolTipPaste
      If gaShortcutsEditor(#SCS_ShortEditor_Paste)\sShortcutStr
        sMenuTextPaste + Chr(9) + gaShortcutsEditor(#SCS_ShortEditor_Paste)\sShortcutStr
      EndIf
    EndIf
  EndIf
  WED_enableTBSButton(#SCS_STANDARD_BTN_PASTE, bEnablePaste, sToolTipPaste)
  scsEnableMenuItem(#WED_mnuCueListPopupMenu, #WED_mnuPaste, bEnablePaste)
  scsSetMenuItemText(#WED_mnuCueListPopupMenu, #WED_mnuPaste, sMenuTextPaste)
  
  If gnSelectedNodeCuePtr >= 1
    If gnSelectedNodeSubPtr >= 0
      nSubPtr = gnSelectedNodeSubPtr
    Else
      nSubPtr = aCue(gnSelectedNodeCuePtr)\nFirstSubIndex
    EndIf
    If nSubPtr >= 0
      sSubType = aSub(nSubPtr)\sSubType
      If WCP_checkSubTypeSupported(sSubType)
        bEnableCopyProps = #True
      EndIf
    EndIf
  EndIf
  WED_enableTBSButton(#SCS_STANDARD_BTN_COPY_PROPS, bEnableCopyProps)
  scsEnableMenuItem(#WED_mnuCueListPopupMenu, #WED_mnuCopyProps, bEnableCopyProps)
  
EndProcedure

Procedure WED_refreshTBSButton(nButtonType)
  ; Procedures WED_refreshTBSButton() and WED_refreshTBSButtons() were added in 11.4.0 to work around a refresh problem with ButtonImageGadgets, which has been often
  ; reported in the PB forums. In SCS 11.4.0 when Ctrl/E was added to the main window as a way to call the editor, using Ctrl/E resulted in the sidebar buttons usually
  ; being hidden until either you move the cursor over the position of a button, or you click on a node or something that caused the buttons to be refreshed.
  ; The work around seems to be to refresh the image, or to refresh the 'enabled' state.
  Protected nIndex, bEnabled
  
  With WED
    nIndex = WED_getTBSIndex(nButtonType)
    bEnabled = getEnabled(\imgButtonTBS[nIndex])
    If bEnabled
      setEnabled(WED\imgButtonTBS[nIndex], #False)
      setEnabled(WED\imgButtonTBS[nIndex], #True)
    Else
      setEnabled(WED\imgButtonTBS[nIndex], #True)
      setEnabled(WED\imgButtonTBS[nIndex], #False)
    EndIf
  EndWith
  
EndProcedure

Procedure WED_refreshTBSButtons()
  ; see comment at start of WED_refreshTBSButton(nButtonType)
  PROCNAMEC()
  
  WED_refreshTBSButton(#SCS_STANDARD_BTN_EXPAND_ALL)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_COLLAPSE_ALL)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_MOVE_UP)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_MOVE_DOWN)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_MOVE_RIGHT_UP)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_MOVE_LEFT)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_CUT)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_COPY)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_PASTE)
  WED_refreshTBSButton(#SCS_STANDARD_BTN_DELETE)
EndProcedure

Procedure WED_refreshMiscButton(nGadgetNo)
  ; see comment at start of WED_refreshTBSButton(nButtonType)
  PROCNAMEC()
  
  If IsGadget(nGadgetNo)
    If getEnabled(nGadgetNo)
      setEnabled(nGadgetNo, #False)
      setEnabled(nGadgetNo, #True)
    Else
      setEnabled(nGadgetNo, #True)
      setEnabled(nGadgetNo, #False)
    EndIf
  EndIf
  
EndProcedure

Procedure WED_refreshMiscButtons()
  ; see comment at start of WED_refreshTBSButton(nButtonType)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, "grCED\sDisplayedSubType=" + grCED\sDisplayedSubType)
  
  Select grCED\sDisplayedSubType
    Case "A"
      With WQA
        WED_refreshMiscButton(\btnFadeOut)
        WED_refreshMiscButton(\btnFirst)
        WED_refreshMiscButton(\btnLast)
        WED_refreshMiscButton(\btnNext)
        WED_refreshMiscButton(\btnPause)
        WED_refreshMiscButton(\btnPlay)
        WED_refreshMiscButton(\btnPrev)
        WED_refreshMiscButton(\btnStop)
        For n = 0 To 3
          WED_refreshMiscButton(\imgButtonTBS[n])
        Next n
      EndWith
      
    Case "F"
      With WQF
        WED_refreshMiscButton(\btnEditFadeOut)
        WED_refreshMiscButton(\btnEditPause)
        WED_refreshMiscButton(\btnEditPlay)
        WED_refreshMiscButton(\btnEditRelease)
        WED_refreshMiscButton(\btnEditRewind)
        WED_refreshMiscButton(\btnEditStop)
      EndWith
      
    Case "I"
      With WQI
        WED_refreshMiscButton(\btnEditFadeOut)
        WED_refreshMiscButton(\btnEditPause)
        WED_refreshMiscButton(\btnEditPlay)
        WED_refreshMiscButton(\btnEditStop)
      EndWith
      
    Case "L"
      With WQL
        WED_refreshMiscButton(\btnLCPause)
        WED_refreshMiscButton(\btnLCPlay)
        WED_refreshMiscButton(\btnLCRewind)
        WED_refreshMiscButton(\btnLCStop)
      EndWith
      
    Case "P"
      With WQP
        WED_refreshMiscButton(\btnPLFadeOut)
        WED_refreshMiscButton(\btnPLPause)
        WED_refreshMiscButton(\btnPLPlay)
        WED_refreshMiscButton(\btnPLRewind)
        WED_refreshMiscButton(\btnPLShuffle)
        WED_refreshMiscButton(\btnPLStop)
        For n = 0 To 3
          WED_refreshMiscButton(\imgButtonTBS[n])
        Next n
      EndWith
      
  EndSelect
  
EndProcedure

Procedure WED_enableTBTButton(nButtonId, bEnable)
  PROCNAMEC()

  ; debugMsg(sProcName, #SCS_START + ", nButtonId=" + nButtonId + ", bEnable=" + strB(bEnable))
  
  If IsWindow(#WED)
    Select nButtonId
      Case #SCS_TBEB_SAVE
        If (grEditingOptions\bSaveAlwaysOn) And (gbEditorAndOptionsLocked = #False) And (grLicInfo\bPlayOnly = #False)
          setToolBarBtnEnabled(#SCS_TBEB_SAVE, #True)
          grWED\mbSaveEnabled = #True
        Else
          ; If bEnable <> grWED\mbSaveEnabled
          ; debugMsg(sProcName, "calling setToolBarBtnEnabled(#SCS_TBEB_SAVE, " + strB(bEnable) + ")")
          setToolBarBtnEnabled(#SCS_TBEB_SAVE, bEnable)
          grWED\mbSaveEnabled = bEnable
          ; EndIf
        EndIf
        setFileSave(#True)  ; MUST use #True or program will loop on starting the Editor
        
      Default
        setToolBarBtnEnabled(nButtonId, bEnable)
        
    EndSelect
  EndIf
  
EndProcedure

Procedure WED_getTBSIndex(nButtonType)
  Protected n, nIndex
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_EXPAND_ALL
      nIndex = #SCS_SIDEBAR_BTN_EXPAND_ALL
      
    Case #SCS_STANDARD_BTN_COLLAPSE_ALL
      nIndex = #SCS_SIDEBAR_BTN_COLLAPSE_ALL
      
    Case #SCS_STANDARD_BTN_MOVE_UP
      nIndex = #SCS_SIDEBAR_BTN_MOVE_UP
      
    Case #SCS_STANDARD_BTN_MOVE_DOWN
      nIndex = #SCS_SIDEBAR_BTN_MOVE_DOWN
      
    Case #SCS_STANDARD_BTN_MOVE_RIGHT_UP
      nIndex = #SCS_SIDEBAR_BTN_MOVE_RIGHT_UP
      
    Case #SCS_STANDARD_BTN_MOVE_LEFT
      nIndex = #SCS_SIDEBAR_BTN_MOVE_LEFT
      
    Case #SCS_STANDARD_BTN_CUT
      nIndex = #SCS_SIDEBAR_BTN_CUT
      
    Case #SCS_STANDARD_BTN_COPY
      nIndex = #SCS_SIDEBAR_BTN_COPY
      
    Case #SCS_STANDARD_BTN_PASTE
      nIndex = #SCS_SIDEBAR_BTN_PASTE
      
    Case #SCS_STANDARD_BTN_DELETE
      nIndex = #SCS_SIDEBAR_BTN_DELETE
      
    Case #SCS_STANDARD_BTN_COPY_PROPS
      nIndex = #SCS_SIDEBAR_BTN_COPY_PROPS
      
    Default
      nIndex = -1
      
  EndSelect
  
  ProcedureReturn nIndex
EndProcedure

Procedure WED_checkNodeKeyExists(nNodeKey)
  PROCNAMEC()
  Protected n, bNodeKeyExists
  
  For n = 1 To CountGadgetItems(WED\tvwProdTree)
    If GetGadgetItemData(WED\tvwProdTree, n-1) = nNodeKey
      bNodeKeyExists = #True
      Break
    EndIf
  Next n
  debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", bNodeKeyExists=" + strB(bNodeKeyExists)) 
  ProcedureReturn bNodeKeyExists
EndProcedure

Procedure WED_getCueIndexForNodeKey(nNodeKey)
  ; PROCNAMEC()
  Protected i, nCueIndex

  nCueIndex = -1
  For i = 1 To gnLastCue
    If aCue(i)\nNodeKey = nNodeKey
      nCueIndex = i
      Break
    EndIf
  Next i
  ProcedureReturn nCueIndex
EndProcedure

Procedure WED_getSubIndexForNodeKey(nNodeKey)
  ; PROCNAMEC()
  Protected j, nSubIndex

  nSubIndex = -1
  For j = 1 To gnLastSub
    If aSub(j)\bExists And aSub(j)\nNodeKey = nNodeKey
      nSubIndex = j
      Break
    EndIf
  Next j
  ProcedureReturn nSubIndex
EndProcedure

Procedure WED_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  WEP_stopProdTestIfRunning()
  
  If valProd() = #False
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "calling WED_validateDisplayedItem()") 
  If WED_validateDisplayedItem() = #False
    debugMsg(sProcName, "exiting because WED_validateDisplayedItem() returned #False")
    ProcedureReturn
  EndIf
  
  samAddRequest(#SCS_SAM_CLOSE_EDITOR, 0, 0, 0, "", ElapsedMilliseconds()+200)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_delayedCloseEditor()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling closeEditor")
  closeEditor()
  
  getFormPosition(#WED, @grEditWindow, #True)
  gbEditorFormLoaded = #False
  gbInNodeClick = #False
  setWindowVisible(#WED, #False)
  ; scsCloseWindow(#WED)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_splEditVRepositioned()
  PROCNAMEC()
  Protected nWidth
  Protected nWindowWidth
  
  ; debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If grWED\bSkipNextSplitterRepositioned
    ; avoids continuous recursive calls following the call to ResizeGadget(\splEditV, ...) which is called from WED_Form_Resized()
    debugMsg(sProcName, "exiting because bSkipNextSplitterRepositioned=#True")
    grWED\bSkipNextSplitterRepositioned = #False
    ProcedureReturn
  EndIf
  
  With WED
    
    nWidth = GadgetWidth(\cntLeft) - GadgetX(\tvwProdTree)
    ResizeGadget(\tvwProdTree, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(\lblClipboardInfo, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(\cntTemplate, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(\lblTemplateInfo, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    
    Select GetWindowState(#WED)
      Case #PB_Window_Normal
        debugMsg(sProcName, "GGS(WED\splEditV)=" + GGS(\splEditV))
        nWindowWidth = GadgetX(\splEditV) + GetGadgetState(\splEditV) + gnVSplitterSeparatorWidth + gnEditorCntRightFixedWidth + gl3DBorderAllowanceX
        debugMsg(sProcName, "call ResizeWindow(#WED, #PB_Ignore, #PB_Ignore, " + nWindowWidth + ", #PB_Ignore)")
        ResizeWindow(#WED, #PB_Ignore, #PB_Ignore, nWindowWidth, #PB_Ignore)
        debugMsg(sProcName, "returned from ResizeWindow(#WED, #PB_Ignore, #PB_Ignore, " + nWindowWidth + ", #PB_Ignore)")
        ; see also WED_Form_Resized(), which will be activated next
        
    EndSelect
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_processSave()
  PROCNAMEC()
  Protected bChangesApplied
  
  If grWED\mbSaveEnabled
    If WED_validateDisplayedItem()
      debugMsg(sProcName, "WED_validateDisplayedItem returned #True")
      bChangesApplied = WED_applyChangesWrapper()
    Else
      debugMsg(sProcName, "WED_validateDisplayedItem returned #False")
    EndIf
  EndIf
EndProcedure

Procedure WED_processFindCue()
  PROCNAMEC()
  
  If WED_validateDisplayedItem()
    WFI_Form_Show(#True, #WED)
    WED_setTBSButtons()
  EndIf
EndProcedure

Procedure WED_tbEditor_ButtonClick(nButtonId)
  PROCNAME(#PB_Compiler_Procedure + "[" + nButtonId + "]")
  Protected nLeft, nTop, nWidth, nHeight
  Protected nFileCount, sFileName.s, sTitle.s
  Protected bQuit
  Protected nResponse
  Protected bCreatePlaceHolder, nVideoImageCues
  Protected nCuePtr, n
  
  debugMsg(sProcName, #SCS_START)
  
  If getToolBarBtnEnabled(nButtonId) = #False
    ; ignore button click if the button is not enabled
    ProcedureReturn
  EndIf
  
  If gbInUndoOrRedo
    ; if currently processing an undo or redo then the user may have double-clicked the undo action,
    ; resulting in the second click ocurring on a toolbar button, so ignore this second click
    ProcedureReturn
  EndIf
  
  WEP_stopProdTestIfRunning()
  clearSelectedFileInfo() ; Added 13Jul2017 11.8.5au
  
  Select nButtonId
    Case #SCS_TBEB_OTHER_ACTIONS
      debugMsg(sProcName, "#SCS_TBEB_OTHER_ACTIONS")
      If WED_validateDisplayedItem()
        DisplayPopupMenu(#WED_mnuOtherActions, WindowID(#WED))
      EndIf
      
    Case #SCS_TBEB_PROD
      debugMsg(sProcName, "#SCS_TBEB_PROD")
      If WED_validateDisplayedItem()
        DisplayPopupMenu(#WED_mnuProdMenu, WindowID(#WED))
      EndIf
      
    Case #SCS_TBEB_CUES
      debugMsg(sProcName, "#SCS_TBEB_CUES")
      If WED_validateDisplayedItem()
        DisplayPopupMenu(#WED_mnuCuesMenu, WindowID(#WED))
      EndIf
      
    Case #SCS_TBEB_SUBS
      debugMsg(sProcName, "#SCS_TBEB_SUBS")
      If WED_validateDisplayedItem()
        DisplayPopupMenu(#WED_mnuSubsMenu, WindowID(#WED))
      EndIf
      
    Case #SCS_TBEB_SAVE
      debugMsg(sProcName, "#SCS_TBEB_SAVE")
      WED_processSave()
      
    Case #SCS_TBEB_HELP
      debugMsg(sProcName, "#SCS_TBEB_HELP")
      displayHelpTopic("scs_cue_edit.htm")
      
    Case #SCS_TBEB_UNDO
      debugMsg(sProcName, "#SCS_TBEB_UNDO")
      ; debugUndoArrays()
      WED_showUndoRedoList(#True)
      DoEvents()
      
    Case #SCS_TBEB_REDO
      debugMsg(sProcName, "#SCS_TBEB_REDO")
      ; debugUndoArrays()
      WED_showUndoRedoList(#False)
      DoEvents()
      
    Case #SCS_TBEB_ADD_QA
      ; identical coding in WED_EventHandler()
      If WED_validateDisplayedItem()
        If WED_checkVideoPlaybackLibrary()
          clearSelectedFileInfo()
          ; Add a placeholder only when Video/Image/Capture is active
          If checkif_VidCapDevsDefined()
            addCueWithSubCue("A", #True, #True, "", #True)
          Else
            sTitle = Lang("Requesters","AddQA")
            debugMsg(sProcName, "ADD_QA calling videoFileRequester()")
            nFileCount = videoFileRequester(sTitle, #True)
            debugMsg(sProcName, "SCS_TBEB_ADD_QA: nFileCount=" + nFileCount)
            If nFileCount = 0
              nResponse = scsMessageRequester(sTitle, Lang("Requesters", "PlaceHolderA"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
              If nResponse = #PB_MessageRequester_Yes
                bCreatePlaceHolder = #True
              EndIf
            EndIf
            If (nFileCount > 0) Or (bCreatePlaceHolder)
              If nFileCount > 50
                If checkManyFilesOK(nFileCount) = #False
                  bQuit = #True
                EndIf
              EndIf
              If bQuit = #False
                If nFileCount > 1
                  sTitle = getToolBarBtnCaption(#SCS_TBEB_ADD_QA)
                  nVideoImageCues = askHowManyVideoCues(nFileCount, sTitle)
                Else
                  nVideoImageCues = 1
                EndIf
                If nVideoImageCues = 1
                  addCueWithSubCue("A", #True, #True, "", #True)
                Else
                  For n = 1 To nVideoImageCues
                    sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
                    nCuePtr = addCueWithSubCue("A", #True, #True, "", #True, #True, sFileName)
                    debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nCueState=" + decodeCueState(aCue(nCuePtr)\nCueState))
                    If aCue(nCuePtr)\nCueState = #SCS_CUE_READY
                      ; close the cue to free any TVG control - important if many video files are added in this paste
                      debugMsg(sProcName, "calling closeCue(" + getCueLabel(nCuePtr) + ")")
                      closeCue(nCuePtr)
                    EndIf
                  Next n
                EndIf
              EndIf ; EndIf bQuit = #False
            EndIf ; EndIf (nFileCount > 0) Or (bCreatePlaceHolder)
          EndIf ; End If checkif_VidCapDevsDefined() / Else
        EndIf ; EndIf WED_checkVideoPlaybackLibrary()
      EndIf ; EndIf WED_validateDisplayedItem()
      
    Case #SCS_TBEB_ADD_QE
      addCueWithSubCue("E", #True)
      
    Case #SCS_TBEB_ADD_QF
      ; identical coding in WED_EventHandler()
      If WED_validateDisplayedItem()
        Select grEditingOptions\nAudioFileSelector
          Case #SCS_FO_SCS_AFS
            WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddQF", #True)
          Case #SCS_FO_WINDOWS_FS
            nFileCount = audioFileRequester(Lang("Requesters", "AddQF"), #True, #WED)
            debugMsg(sProcName, "SCS_TBEB_ADD_QF: nFileCount=" + Str(nFileCount))
            bQuit = #False
            If nFileCount = 0
              nResponse = scsMessageRequester(Lang("Requesters", "AddQF"), Lang("Requesters", "PlaceHolderF"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
              If nResponse = #PB_MessageRequester_Yes
                bCreatePlaceHolder = #True
              EndIf
            EndIf
            If (nFileCount > 0) Or (bCreatePlaceHolder)
              If nFileCount > 50
                If checkManyFilesOK(nFileCount) = #False
                  bQuit = #True
                EndIf
              EndIf
              If bQuit = #False
                WED_importAudioFiles(#SCS_IMPORT_AUDIO_CUES, Lang("WED", "FavAddQF"), #False, "", bCreatePlaceHolder)
              EndIf
            EndIf
        EndSelect
      EndIf
      
    Case #SCS_TBEB_ADD_QG
      addCueWithSubCue("G", #True)
      
    Case #SCS_TBEB_ADD_QI
      addCueWithSubCue("I", #True)
      
;     Case #SCS_TBEB_ADD_QJ
;       addCueWithSubCue("J", #True)
      
    Case #SCS_TBEB_ADD_QK
      addCueWithSubCue("K", #True)
      
    Case #SCS_TBEB_ADD_QL
      addCueWithSubCue("L", #True)
      
    Case #SCS_TBEB_ADD_QM
      addCueWithSubCue("M", #True)
      
    Case #SCS_TBEB_ADD_QN
      addCueWithSubCue("N", #True)
      
    Case #SCS_TBEB_ADD_QP
      ; identical coding in WED_EventHandler()
      If WED_validateDisplayedItem()
        Select grEditingOptions\nAudioFileSelector
          Case #SCS_FO_SCS_AFS
            WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddQP", #True)
          Case #SCS_FO_WINDOWS_FS
            nFileCount = audioFileRequester(Lang("Requesters", "AddQP"), #True, #WED)
            If nFileCount = 0
              nResponse = scsMessageRequester(Lang("Requesters", "AddQP"), Lang("Requesters", "PlaceHolderP"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
              If nResponse = #PB_MessageRequester_Yes
                bCreatePlaceHolder = #True
              EndIf
            EndIf
            If (nFileCount > 0) Or (bCreatePlaceHolder)
              If nFileCount > 50
                If checkManyFilesOK(nFileCount) = #False
                  bQuit = #True
                EndIf
              EndIf
              If bQuit = #False
                addCueWithSubCue("P", #True, #True, "", #True)
              EndIf
            EndIf
        EndSelect
      EndIf
      
    Case #SCS_TBEB_ADD_QQ
      addCueWithSubCue("Q", #True)
      
    Case #SCS_TBEB_ADD_QR
      addCueWithSubCue("R", #True)
      
    Case #SCS_TBEB_ADD_QS
      addCueWithSubCue("S", #True)
      
    Case #SCS_TBEB_ADD_QT
      addCueWithSubCue("T", #True)
      
    Case #SCS_TBEB_ADD_QU
      addCueWithSubCue("U", #True)
      
    Case #SCS_TBEB_ADD_SA
      ; identical coding in WED_EventHandler()
      If WED_validateDisplayedItem()
        If WED_checkVideoPlaybackLibrary()
          clearSelectedFileInfo()
          If checkif_VidCapDevsDefined()
            addSubCue("A", #True, "", #True)
          Else
            debugMsg(sProcName, "ADD_SA calling videoFileRequester()")
            nFileCount = videoFileRequester(Lang("Requesters", "AddSA"), #True)
            If nFileCount = 0
              nResponse = scsMessageRequester(Lang("Requesters", "AddSA"), Lang("Requesters", "PlaceHolderA"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
              If nResponse = #PB_MessageRequester_Yes
                bCreatePlaceHolder = #True
              EndIf
            EndIf
            If (nFileCount > 0) Or (bCreatePlaceHolder)
              If nFileCount > 50
                If checkManyFilesOK(nFileCount) = #False
                  bQuit = #True
                EndIf
              EndIf
              If bQuit = #False
                addSubCue("A", #True, "", #True)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      
    Case #SCS_TBEB_ADD_SE
      addSubCue("E")
      
    Case #SCS_TBEB_ADD_SF
      ; identical coding in WED_EventHandler()
      If WED_validateDisplayedItem()
        Select grEditingOptions\nAudioFileSelector
          Case #SCS_FO_SCS_AFS
            WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddSF", #False)
          Case #SCS_FO_WINDOWS_FS
            nFileCount = audioFileRequester(Lang("Requesters", "AddSF"), #False, #WED)
            If nFileCount = 0
              nResponse = scsMessageRequester(Lang("Requesters", "AddSF"), Lang("Requesters", "PlaceHolderF"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
              If nResponse = #PB_MessageRequester_Yes
                bCreatePlaceHolder = #True
              EndIf
            EndIf
            If (nFileCount > 0) Or (bCreatePlaceHolder)
              If nFileCount > 50
                If checkManyFilesOK(nFileCount) = #False
                  bQuit = #True
                EndIf
              EndIf
              If bQuit = #False
                If bCreatePlaceHolder
                  sFileName = grText\sTextPlaceHolder
                Else
                  sFileName = gsSelectedDirectory + gsSelectedFile(0)
                EndIf
                debugMsg(sProcName, "sFileName=" + sFileName)
                addSubCue("F", #True, sFileName, #True)
              EndIf
            EndIf
        EndSelect
      EndIf
      
    Case #SCS_TBEB_ADD_SG
      addSubCue("G")
      
    Case #SCS_TBEB_ADD_SI
      addSubCue("I")
      
;     Case #SCS_TBEB_ADD_SJ
;       addSubCue("J")
      
    Case #SCS_TBEB_ADD_SK
      addSubCue("K")
      
    Case #SCS_TBEB_ADD_SL
      addSubCue("L")
      
    Case #SCS_TBEB_ADD_SM
      addSubCue("M")
      
    Case #SCS_TBEB_ADD_SP
      ; identical coding in WED_EventHandler()
      If WED_validateDisplayedItem()
        Select grEditingOptions\nAudioFileSelector
          Case #SCS_FO_SCS_AFS
            WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddSP", #True)
          Case #SCS_FO_WINDOWS_FS
            nFileCount = audioFileRequester(Lang("Requesters", "AddSP"), #True, #WED)
            If nFileCount = 0
              nResponse = scsMessageRequester(Lang("Requesters", "AddSP"), Lang("Requesters", "PlaceHolderP"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
              If nResponse = #PB_MessageRequester_Yes
                bCreatePlaceHolder = #True
              EndIf
            EndIf
            If (nFileCount > 0) Or (bCreatePlaceHolder)
              If nFileCount > 50
                If checkManyFilesOK(nFileCount) = #False
                  bQuit = #True
                EndIf
              EndIf
              If bQuit = #False
                addSubCue("P", #True, "", #True)
              EndIf
            EndIf
        EndSelect
      EndIf
      
    Case #SCS_TBEB_ADD_SQ
      addSubCue("Q")
      
    Case #SCS_TBEB_ADD_SR
      addSubCue("R")
      
    Case #SCS_TBEB_ADD_SS
      addSubCue("S")
      
    Case #SCS_TBEB_ADD_ST
      addSubCue("T")
      
    Case #SCS_TBEB_ADD_SU
      addSubCue("U")
      
  EndSelect
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WED_tvwProdTree_DropFiles()
  PROCNAMEC()
  Protected u
  Protected sFileList.s
  Protected nSelectedItem, nNodeKey, nFirstNewNodeKey
  
  debugMsg(sProcName, #SCS_START)
  
  nSelectedItem = GetGadgetState(WED\tvwProdTree)
  debugMsg(sProcName, "nSelectedItem=" + nSelectedItem)
  If nSelectedItem < 0
    ; probably positioned after last item, so the previously selected item is still displayed highlighted (albeit non-focused)
    nSelectedItem = grCED\nSelectedItemForDragAndDrop
    If nSelectedItem >= 0
      SGS(WED\tvwProdTree, nSelectedItem)
    EndIf
  EndIf
  If nSelectedItem >= 0
    nNodeKey = GetGadgetItemData(WED\tvwProdTree, nSelectedItem)
    debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", " + GetGadgetItemText(WED\tvwProdTree, nSelectedItem))
    sFileList = EventDropFiles()
    debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
    
    gbInDragDrop = #True
    
    nFirstNewNodeKey = pasteCuesFromOLE(sFileList)
    debugMsg(sProcName, "nFirstNewNodeKey=" + nFirstNewNodeKey)
    If nFirstNewNodeKey >= 0
      setCuePtrs(#False)
      setTimeBasedCues()
      redoCueListTree(nFirstNewNodeKey)
      WED_setEditorButtons()
      populateGrid()
      PNL_loadDispPanels()
      ONC_openNextCues(1)
      loadHotkeyArray()
      loadCueMarkerArrays()
    EndIf
    SAW(#WED)
    WED_publicNodeClick(nFirstNewNodeKey)
    setMouseCursorNormal()
    
    gbInDragDrop = #False
    
  EndIf
  grCED\nSelectedItemForDragAndDrop = -1
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_tvwProdTree_NodeClick(bForceRedisplay=#False)
  PROCNAMEC()
  Protected nSelectedItem, nNodeKey
  Protected qStartTime.q, qEndTime.q

  debugMsg(sProcName, #SCS_START + ", bForceRedisplay=" + strB(bForceRedisplay))
  
  qStartTime = ElapsedMilliseconds()
  
  WEP_stopProdTestIfRunning()
  
  nSelectedItem = GetGadgetState(WED\tvwProdTree)
  ; debugMsg(sProcName, "nSelectedItem=" + nSelectedItem)
  If nSelectedItem >= 0
    nNodeKey = GetGadgetItemData(WED\tvwProdTree, nSelectedItem)
    debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", " + GetGadgetItemText(WED\tvwProdTree, nSelectedItem))
    WED_publicNodeClick(nNodeKey, #False, #False, bForceRedisplay)
  Else
    WED_EnableDisableMenuItems() ; nb WED_EnableDisableMenuItems() called within WED_publicNodeClick() so only need to call it now under this 'Else' condition
  EndIf
  
  qEndTime = ElapsedMilliseconds()
  debugMsg(sProcName, #SCS_END + ", time: " + Str(qEndTime - qStartTime))

EndProcedure

Procedure WED_doNodeClick(nNodeKey, bSuppressNodeDisplay=#False, bForceRedisplay=#False)
  PROCNAME(#PB_Compiler_Procedure + "[NodeKey:" + nNodeKey + "]")
  Protected i, j, k, n
  Protected nThisNodeCuePtr, nThisNodeSubPtr, nThisNodeType, bCallValCue
  Protected nCompletedCuePtr
  Protected nSelectedItem
  Protected bFound
  Protected nRow
  Protected nNodeClickExit
  Protected qStartTime.q, qEndTime.q
  Static nPrevSelectedItem = -1

  debugMsg(sProcName, #SCS_START + ", bSuppressNodeDisplay=" + strB(bSuppressNodeDisplay) + ", bForceRedisplay=" + strB(bForceRedisplay) + ", gnSelectedNodeKey=" + gnSelectedNodeKey)
  qStartTime = ElapsedMilliseconds()
  
  If (nNodeKey = gnSelectedNodeKey) And (bForceRedisplay = #False)
    ; no change in selected node, so exit immediately
    debugMsg(sProcName, "nNodeKey=gnSelectedNodeKey (" + nNodeKey + ") so exiting immediately")
    ProcedureReturn
  EndIf
  
  gbKillNodeClick = #False
  gbInNodeClick = #True
  nCompletedCuePtr = -1
  gnClickThisNode = -1

  ; debugMsg(sProcName, "GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree))
  setMouseCursorBusy()
  
  If grTestTone\bPlayingTestTone
    stopTestTone()
  EndIf
  
  If grTestLiveInput\bRunningTestLiveInput
    debugMsg(sProcName, "calling stopTestLiveInput()")
    stopTestLiveInput()
  EndIf
  
  If grWQE\nPreviewMemoScreen > 0
    WQE_closeMemoPreviewIfReqd()
  EndIf
  
  If gnPreviewOnOutputScreenNo > 0
    WQA_clearPreviewOnOutputScreen(gnPreviewOnOutputScreenNo)
    gnPreviewOnOutputScreenNo = 0
  EndIf
  
  WPL_hideWindowIfDisplayed(#SCS_VST_HOST_AUD) ; hide VST plugin editor window if displaying an audio file cue plugin
  
  nSelectedItem = -1
  ; debugMsg(sProcName,"CountGadgetItems(G" + WED\tvwProdTree + ")=" + CountGadgetItems(WED\tvwProdTree))
  For n = 0 To CountGadgetItems(WED\tvwProdTree)-1
    ; debugMsg(sProcName,"GetGadgetItemData(G" + WED\tvwProdTree + ", " + n + ")=" + GetGadgetItemData(WED\tvwProdTree, n))
    If GetGadgetItemData(WED\tvwProdTree, n) = nNodeKey
      nSelectedItem = n
      Break
    EndIf
  Next n
  ; debugMsg(sProcName, "nSelectedItem=" + nSelectedItem)
  
  If GGS(WED\tvwProdTree) <> nSelectedItem
    ; debugMsg(sProcName, "calling SGS(WED\tvwProdTree, " + nSelectedItem + ")")
    SGS(WED\tvwProdTree, nSelectedItem)
  EndIf
  ; debugMsg(sProcName, "GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree))
  If nPrevSelectedItem <> nSelectedItem
    If nPrevSelectedItem >= 0
      HighlightTreeviewItem(WED\tvwProdTree, nPrevSelectedItem, #False)
    EndIf
  EndIf
  HighlightTreeviewItem(WED\tvwProdTree, nSelectedItem, #True)
  nPrevSelectedItem = nSelectedItem
  
  If nSelectedItem = -1
    ; nothing selected
    setMouseCursorNormal()
    debugMsg(sProcName, "exiting because nSelectedItem=" + nSelectedItem)
    ProcedureReturn
  EndIf
  
  grWED\nNodeClickKey = nNodeKey
  
  ; search cues and subs to find which cue or sub has this nNodeKey
  nThisNodeCuePtr = -2
  nThisNodeSubPtr = -2
  bFound = #False
  If grProd\nNodeKey = nNodeKey
    nThisNodeType = #SCS_NODE_TYPE_PROD
    ; debugMsg(sProcName, "nThisNodeType=#SCS_NODE_TYPE_PROD")
    logKeyEvent("nThisNodeType=#SCS_NODE_TYPE_PROD")
    bFound = #True
  Else
    For i = 1 To gnLastCue
      ; debugMsg(sProcName,"aCue(" + i + ")\nNodeKey=" + aCue(i)\nNodeKey)
      If aCue(i)\nNodeKey = nNodeKey
        nThisNodeCuePtr = i
        nThisNodeSubPtr = aCue(i)\nFirstSubIndex
        nThisNodeType = #SCS_NODE_TYPE_CUE
        ; debugMsg(sProcName, "nThisNodeType=#SCS_NODE_TYPE_CUE, nThisNodeCuePtr=" + getCueLabel(nThisNodeCuePtr))
        logKeyEvent("nThisNodeType=#SCS_NODE_TYPE_CUE, nThisNodeCuePtr=" + getCueLabel(nThisNodeCuePtr))
        bFound = #True
        Break
      Else
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\nNodeKey = nNodeKey
            nThisNodeCuePtr = i
            nThisNodeSubPtr = j
            nThisNodeType = #SCS_NODE_TYPE_SUB
            ; debugMsg(sProcName, "nThisNodeType=#SCS_NODE_TYPE_SUB, nThisNodeSubPtr=" + getSubLabel(nThisNodeSubPtr))
            logKeyEvent("nThisNodeType=#SCS_NODE_TYPE_SUB, nThisNodeSubPtr=" + getSubLabel(nThisNodeSubPtr))
            bFound = #True
            Break
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      If bFound
        Break
      EndIf
    Next i
  EndIf

  If (nThisNodeCuePtr <> nEditCuePtr) Or (nThisNodeSubPtr <> nEditSubPtr)
    If nEditSubPtr >= 0
      With aSub(nEditSubPtr)
        If \bStartedInEditor
          If (\nSubState >= #SCS_CUE_FADING_IN) And (\nSubState <= #SCS_CUE_FADING_OUT)
            debugMsg(sProcName, "calling stopSub(" + getSubLabel(nEditSubPtr) + ", 'ALL', #False, #False)")
            stopSub(nEditSubPtr, "ALL", #False, #False)
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  
  While #True   ; dummy loop to allow 'Break' instead of 'GoTo'
    
    If gbIgnoreNodeClick
      gbIgnoreNodeClick = #False
      nNodeClickExit = 1
      Break
    EndIf
    
;     debugMsg(sProcName, "gbSkipValidation=" + strB(gbSkipValidation) + ", nThisNodeCuePtr=" + getCueLabel(nThisNodeCuePtr) + ", nEditCuePtr=" + getCueLabel(nEditCuePtr) +
;                         ", nThisNodeSubPtr=" + getSubLabel(nThisNodeSubPtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr))
    If gbSkipValidation = #False
      
      If grCED\bProdForLTCChanged
        debugMsg(sProcName, "calling valForLTC()")
        If valForLTC() = #False
          debugMsg(sProcName, "valForLTC failed")
          gbIgnoreNodeClick = #True
          nNodeClickExit = 5
          Break
        Else
          debugMsg(sProcName, "valForLTC OK")
        EndIf
      EndIf
      
      If grCED\bProdForMTCChanged
        debugMsg(sProcName, "calling valForMTC()")
        If valForMTC() = #False
          debugMsg(sProcName, "valForMTC failed")
          gbIgnoreNodeClick = #True
          nNodeClickExit = 6
          Break
        Else
          debugMsg(sProcName, "valForMTC OK")
        EndIf
      EndIf
      
      If (nThisNodeCuePtr <> nEditCuePtr) Or (nThisNodeSubPtr <> nEditSubPtr)
        
        If nEditCuePtr >= 0
          bCallValCue = #True
          If nThisNodeSubPtr >= 0
            If aSub(nThisNodeSubPtr)\nCueIndex = nEditCuePtr
              bCallValCue = #False
            EndIf
          EndIf
          If bCallValCue
            debugMsg(sProcName, "calling valCue(#False)")
            If valCue(#False) = #False
              debugMsg(sProcName, "valCue failed")
              gbIgnoreNodeClick = #True
              nNodeClickExit = 2
;               ; Added 6Jan2022 11.9ad (NOT YET WORKING)
;               gbLastVALResult = #False
;               If gnFocusGadgetNo = 0
;                 gnFocusGadgetNo = gnValidateGadgetNo
;               EndIf
;               ; End added 6Jan2022 11.9ad
              Break
            Else
              debugMsg(sProcName, "valCue OK")
            EndIf
          Else
            debugMsg(sProcName, "bCallValCue=#False")
            If valSub() = #False
              debugMsg(sProcName, "valSub failed")
              gbIgnoreNodeClick = #True
              nNodeClickExit = 2
              Break
            EndIf
          EndIf
          
        ElseIf nThisNodeType <> gnSelectedNodeType
          If gnSelectedNodeType = #SCS_NODE_TYPE_PROD
            debugMsg(sProcName, "calling WEP_valProdProperties(#True)")
            If WEP_valProdProperties(#True) = #False
              debugMsg(sProcName, "WEP_valProdProperties failed")
              gnClickThisNode = gnSelectedNodeKey
              nNodeClickExit = 3
              Break
            Else
              debugMsg(sProcName, "WEP_valProdProperties OK")
            EndIf
          EndIf
        EndIf
        
      ElseIf nThisNodeType <> gnSelectedNodeType
        If gnSelectedNodeType = #SCS_NODE_TYPE_PROD
          If grCED\bProdCreated ; added this test 8Oct2019 11.8.2at
            debugMsg(sProcName, "calling WEP_valProdProperties(#True)")
            If WEP_valProdProperties(#True) = #False
              debugMsg(sProcName, "WEP_valProdProperties failed")
              gnClickThisNode = gnSelectedNodeKey
              nNodeClickExit = 4
              Break
            Else
              debugMsg(sProcName, "WEP_valProdProperties OK")
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
    If nThisNodeCuePtr <> nEditCuePtr
      If nEditCuePtr >= 0
        If aCue(nEditCuePtr)\bCueCompletedBeforeOpenedInEditor
          debugMsg(sProcName, "calling closeCue(" + getCueLabel(nEditCuePtr) + ", #False, #True) because \bCueCompletedBeforeOpenedInEditor=#True")
          closeCue(nEditCuePtr, #False, #True)
          ; debugMsg(sProcName, "setting aCue(" + getCueLabel(nEditCuePtr) + ")\bCueCompletedBeforeOpenedInEditor=#False")
          aCue(nEditCuePtr)\bCueCompletedBeforeOpenedInEditor = #False
          j = aCue(nEditCuePtr)\nFirstSubIndex
          While j >= 0
            ; debugMsg(sProcName, "setting aSub(" + getSubLabel(j) + ")\bSubCompletedBeforeOpenedInEditor=#False")
            aSub(j)\bSubCompletedBeforeOpenedInEditor = #False
            If aSub(j)\bSubTypeHasAuds
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                aAud(k)\nAudState = #SCS_CUE_COMPLETED
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
            aSub(j)\nSubState = #SCS_CUE_COMPLETED
            ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
            j = aSub(j)\nNextSubIndex
          Wend
          aCue(nEditCuePtr)\nCueState = #SCS_CUE_COMPLETED
          nCompletedCuePtr = nEditCuePtr
        EndIf
      EndIf
      
      If nThisNodeCuePtr >= 0
        If aCue(nThisNodeCuePtr)\nCueState = #SCS_CUE_COMPLETED
          aCue(nThisNodeCuePtr)\bCueCompletedBeforeOpenedInEditor = #True
        Else
          aCue(nThisNodeCuePtr)\bCueCompletedBeforeOpenedInEditor = #False ; added 25Feb2020 11.8.2.2at following email from Dave Korman about a cue that was started in the main window being stopped on closing the editor
        EndIf
        j = aCue(nThisNodeCuePtr)\nFirstSubIndex
        While j >= 0
          aSub(j)\nSubStateBeforeOpenedInEditor = aSub(j)\nSubState
          If aSub(j)\nSubState = #SCS_CUE_COMPLETED
            aSub(j)\bSubCompletedBeforeOpenedInEditor = #True
          Else
            aSub(j)\bSubCompletedBeforeOpenedInEditor = #False ; added 25Feb2020 11.8.2.2at following email from Dave Korman about a cue that was started in the main window being stopped on closing the editor
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      
    ElseIf nThisNodeSubPtr <> nEditSubPtr
      If nEditSubPtr >= 0
        If aSub(nEditSubPtr)\bSubCompletedBeforeOpenedInEditor
          debugMsg(sProcName, "calling closeSub(" + getSubLabel(nEditSubPtr) + ", #True, #True) because \bSubCompletedBeforeOpenedInEditor=#True")
          closeSub(nEditSubPtr, #True, #True)
          ; debugMsg(sProcName, "setting aSub(" + getSubLabel(nEditSubPtr) + ")\bSubCompletedBeforeOpenedInEditor=#False")
          aSub(nEditSubPtr)\bSubCompletedBeforeOpenedInEditor = #False
          If aSub(nEditSubPtr)\bSubTypeHasAuds
            k = aSub(nEditSubPtr)\nFirstAudIndex
            While k >= 0
              aAud(k)\nAudState = #SCS_CUE_COMPLETED
              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          aSub(nEditSubPtr)\nSubState = #SCS_CUE_COMPLETED
          ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState))
          nCompletedCuePtr = nEditCuePtr
        EndIf
      EndIf
      If nThisNodeSubPtr >= 0
        aSub(nThisNodeSubPtr)\nSubStateBeforeOpenedInEditor = aSub(nThisNodeSubPtr)\nSubState
        If aSub(nThisNodeSubPtr)\nSubState = #SCS_CUE_COMPLETED
          aSub(nThisNodeSubPtr)\bSubCompletedBeforeOpenedInEditor = #True
        Else
          aSub(nThisNodeSubPtr)\bSubCompletedBeforeOpenedInEditor = #False ; added 25Feb2020 11.8.2.2at following email from Dave Korman about a cue that was started in the main window being stopped on closing the editor
        EndIf
      EndIf
    EndIf
    
    gnSelectedNodeKey = nNodeKey
    ; debugMsg(sProcName, "gnSelectedNodeKey=" + gnSelectedNodeKey)
    
    If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey)
      Break
    EndIf
    
    Select nThisNodeType
      Case #SCS_NODE_TYPE_CUE, #SCS_NODE_TYPE_MULTI
        gnSelectedNodeCuePtr = nThisNodeCuePtr
        gnSelectedNodeSubPtr = -2
        gnSelectedCueNodeKey = nNodeKey
      Case #SCS_NODE_TYPE_SUB
        gnSelectedNodeCuePtr = nThisNodeCuePtr
        gnSelectedNodeSubPtr = nThisNodeSubPtr
        If nThisNodeSubPtr >= 0
          If aSub(nThisNodeSubPtr)\nPrevSubIndex < 0 And aSub(nThisNodeSubPtr)\nNextSubIndex < 0
            ; if only one subcue treat as cue for delete and other operations
            gnSelectedNodeSubPtr = -2
          EndIf
        EndIf
        ; do not set gsSelectedCueNodeKey for sub's
      Default
        gnSelectedNodeCuePtr = nThisNodeCuePtr
        gnSelectedNodeSubPtr = nThisNodeSubPtr
        gnSelectedCueNodeKey = nNodeKey
    EndSelect
    
    If nThisNodeType <> gnSelectedNodeType
      gnSelectedNodeType = nThisNodeType
      gbForceNodeDisplay = #True ; Added 29Dec2023 11.10.0dt following test of adding an audio file cue to an empty production, and then undoing the change. Previously the 'undo' would not clear the audio file cue display and that caused all sorts of problems.
    EndIf
    
    ; debugMsg(sProcName, "gnSelectedNodeCuePtr=" + getCueLabel(gnSelectedNodeCuePtr) + ", gnSelectedNodeSubPtr=" + getSubLabel(gnSelectedNodeSubPtr) + ", gnSelectedCueNodeKey=" + gnSelectedCueNodeKey + ", gnSelectedNodeType=" + gnSelectedNodeType)
    
    If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey) : Break : EndIf
    WED_setSelectedNodeInfo()
    
    If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey) : Break : EndIf
    
    If bSuppressNodeDisplay = #False
      If (gbForceNodeDisplay) Or (nThisNodeCuePtr <> gnDisplayedCuePtr) Or (nThisNodeSubPtr <> gnDisplayedSubPtr)
        gnDisplayedCuePtr = nThisNodeCuePtr
        gnDisplayedSubPtr = nThisNodeSubPtr
        gnDisplayedAudPtr = -1
        grCED\sDisplayedSubType = ""
        ; debugMsg(sProcName, "grCED\sDisplayedSubType=" + grCED\sDisplayedSubType)
        ; debugMsg0(sProcName, "Setting nEditCuePtr (" + getCueLabel(nEditCuePtr) + ") to " + getCueLabel(nThisNodeCuePtr) + " and nEditSubPtr (" + getSubLabel(nEditSubPtr) + ") to " + getSubLabel(nThisNodeSubPtr))
        nEditCuePtr = nThisNodeCuePtr
        nEditSubPtr = nThisNodeSubPtr
        ; debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
        setEditAudPtr(-1)
        If nEditSubPtr >= 0
          If aSub(nEditSubPtr)\bSubTypeHasAuds
            setEditAudPtr(aSub(nEditSubPtr)\nFirstAudIndex)
            gnDisplayedAudPtr = nEditAudPtr
          EndIf
        EndIf
        If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey) : Break : EndIf
        Select nThisNodeType
          Case #SCS_NODE_TYPE_PROD
            debugMsg(sProcName, "calling displayProd()")
            displayProd()
          Case #SCS_NODE_TYPE_CUE, #SCS_NODE_TYPE_MULTI
            debugMsg(sProcName, "calling displayCue(" + getCueLabel(nEditCuePtr) + ", " + getSubLabel(nEditSubPtr) + ")")
            displayCue(nEditCuePtr, nEditSubPtr)
          Case #SCS_NODE_TYPE_SUB
            debugMsg(sProcName, "calling displayCue(" + getCueLabel(nEditCuePtr) + ", " + getSubLabel(nEditSubPtr) + ")")
            displayCue(nEditCuePtr, nEditSubPtr)
        EndSelect
      EndIf
      
    EndIf
    
    gbForceNodeDisplay = #False
    ; debugMsg(sProcName, "gbForceNodeDisplay=" + strB(gbForceNodeDisplay))
    
    If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey) : Break : EndIf
    ; debugMsg(sProcName, "Calling setEditorButtons")
    WED_setEditorButtons()
    
    If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey) : Break : EndIf
    ; debugMsg(sProcName, "Calling setTBTButtons")
    WED_setTBTButtons()
    
    If (gbKillNodeClick) Or (nNodeKey <> grWED\nNodeClickKey) : Break : EndIf
    ; debugMsg(sProcName, "Calling setTBSButtons")
    WED_setTBSButtons()
    
    ; debugMsg(sProcName, "nCompletedCuePtr=" + getCueLabel(nCompletedCuePtr))
    If nCompletedCuePtr <> -1
      ;gbCallLoadDispPanels = True
      gnRefreshCuePtr = nEditCuePtr
      gnRefreshSubPtr = nEditSubPtr
      gnRefreshAudPtr = nEditAudPtr
      gbCallRefreshDispPanel = #True
      ; debugMsg(sProcName, "gbCallRefreshDispPanel=" + strB(gbCallRefreshDispPanel) + ", gnRefreshCuePtr=" + getCueLabel(gnRefreshCuePtr) + ", gnRefreshSubPtr=" + getSubLabel(gnRefreshSubPtr) + ", gnRefreshAudPtr=" + getAudLabel(gnRefreshAudPtr))
      With aCue(nCompletedCuePtr)
        ; the following based on code from updateGrid
        nRow = \nGrdCuesRowNo
        If nRow >= 0
          WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_CS, getCueStateForGrid(nCompletedCuePtr))
        EndIf
        ; end of code from updateGrid
      EndWith
      colorLine(nCompletedCuePtr)
    EndIf
    
    Break
    
  Wend
  
  If nNodeClickExit > 0
    debugMsg(sProcName, "quit because nNodeClickExit=" + nNodeClickExit)
  ElseIf gbKillNodeClick
    debugMsg(sProcName, "quit because gbKillNodeClick=#True")
  ElseIf nNodeKey <> grWED\nNodeClickKey
    debugMsg(sProcName, "quit because nNodeKey (" + nNodeKey + ") <> nNodeClickKey (" + grWED\nNodeClickKey + ")")
  EndIf
  
  setMouseCursorNormal()
  gbKillNodeClick = #False
  gbInNodeClick = #False
  If nNodeClickExit > 0
    ; reinstate previously-selected node (which has reported an error during validation)
    gnClickThisNode = gnSelectedNodeKey
  EndIf
  If gnClickThisNode > 0
    gqMainThreadRequest | #SCS_MTH_SET_WED_NODE
  EndIf
  
  ; debugMsg(sProcName, "GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree))
  
  qEndTime = ElapsedMilliseconds()
  debugMsg(sProcName, #SCS_END + ", time: " + Str(qEndTime - qStartTime) + ", gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels) + ", gnClickThisNode=" + gnClickThisNode)
  
EndProcedure

Procedure WED_setNode(nNodeKey=-1)
  PROCNAMEC()
  Protected n, nListIndex
  Protected nSelectedItem
  
  debugMsg(sProcName, #SCS_START)
  
  With WED
    If nNodeKey >= 0
      gnClickThisNode = nNodeKey
    EndIf
    If gnClickThisNode >= 0
      If IsGadget(\tvwProdTree)
        nSelectedItem = GGS(\tvwProdTree)
        ; SGS(WED\tvwProdTree,-1)
        ; debugMsg(sProcName, "GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree))
        nListIndex = -1
        For n = 0 To (CountGadgetItems(WED\tvwProdTree)-1)
          If GetGadgetItemData(WED\tvwProdTree, n) = gnClickThisNode
            nListIndex = n
          EndIf
        Next n
        If nListIndex >= 0
          debugMsg(sProcName, "Selecting node " + nListIndex)
          SGS(WED\tvwProdTree, nListIndex)
          HighlightTreeviewItem(WED\tvwProdTree, nListIndex, #True)
          If (nListIndex <> nSelectedItem) And (nSelectedItem >= 0)
            HighlightTreeviewItem(WED\tvwProdTree, nSelectedItem, #False)
          EndIf
          SAG(WED\tvwProdTree)
        EndIf
      EndIf
      gnClickThisNode = -1
      gbIgnoreNodeClick = #False
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_publicNodeClick(nNodeKey, bCueListMutexLockedByCaller=#False, bSuppressNodeDisplay=#False, bForceRedisplay=#False)
  PROCNAMEC()
  Protected bLockedMutex, bValidationResult
  Protected qStartTime.q, qEndTime.q
  
  debugMsg(sProcName, #SCS_START +  ", nNodeKey=" + nNodeKey + ", gnThreadNo=" + THR_decodeThreadIndex(gnThreadNo) +
                      ", bCueListMutexLockedByCaller=" + strB(bCueListMutexLockedByCaller) + ", bSuppressNodeDisplay=" + strB(bSuppressNodeDisplay))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_EDITOR_NODE_CLICK, nNodeKey)
    ProcedureReturn
  EndIf
  
  ; Added 20Jun2022 11.9.3aa following bug report from Dave Pursey "Crash on Control Sub-Cue Edit"
  ; The problem is that it appears that clicking on a node in the tree activate the 'node click' event BEFORE it activates the Lost Focus event.
  ; So forcing 'Lost Focus' by setting focus to the (new) txtDummy gadget, and then using SAM to repeat the 'Node Click' action after a short delay (short delay essential) then
  ; this enables the relevant gadget validation to be processed.
  ; This is only necessary if gnValidateGadgetNo is set.
  ; debugMsg0(sProcName, "gnValidateGadgetNo=" + getGadgetName(gnValidateGadgetNo))
  ; commonValidation call and test added 17Nov2023 11.10.0-b03 as just calling samAddRequest again was rejected as a duplicate entry, and never acheived the desired outcome.
  If gnValidateGadgetNo > 0
    SAG(WED\txtDummy)
    ; samAddRequest(#SCS_SAM_EDITOR_NODE_CLICK, nNodeKey, 0, 0, "", ElapsedMilliseconds()+100)
    debugMsg(sProcName, "Calling commonValidation(), gnValidateGadgetNo=" + getGadgetName(gnValidateGadgetNo))
    bValidationResult = commonValidation()
    debugMsg(sProcName, "commonValidation() returned " + strB(bValidationResult))
    If bValidationResult = #False
      ProcedureReturn
    EndIf
  EndIf
  ; End added 20Jun2022 11.9.3aa
  
  qStartTime = ElapsedMilliseconds()
  gbInEditorDoPublicNodeClick = #True ; suspends mutex lock timeout testing, as the processing can take quite a while, especially building an audio graph for a lengthy audio file
  
  If WED_checkNodeKeyExists(nNodeKey)
    If bCueListMutexLockedByCaller
      WED_doNodeClick(nNodeKey, bSuppressNodeDisplay, bForceRedisplay)
    Else
      If gnTraceMutexLocking > 0
        debugMsg3(sProcName, "calling LockMutex(gnCueListMutex), gnCueListMutexLockThread=" + gnCueListMutexLockThread +
                             ", gnThreadNo=" + gnThreadNo +
                             ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime) +
                             ", gnCueListMutexLockNo=" + gnCueListMutexLockNo)
      EndIf
      LockCueListMutex(816)
      WED_doNodeClick(nNodeKey, bSuppressNodeDisplay, bForceRedisplay)
      UnlockCueListMutex()
    EndIf
  EndIf
  
  WED_EnableDisableMenuItems()
  
  gbInEditorDoPublicNodeClick = #False  ; resume mutex lock timeout testing
  qEndTime = ElapsedMilliseconds()
  
  debugMsg(sProcName, #SCS_END + ", time: " + Str(qEndTime - qStartTime))
  
EndProcedure

Procedure WED_setSelectedNodeInfo()
  PROCNAMEC()

  gsSelectedNodeInfo = ""
  gsSelectedCueInfo = ""

  If gnSelectedNodeCuePtr >= 0
    With aCue(gnSelectedNodeCuePtr)
      gsSelectedCueInfo = "Cue " + \sCue + " (" + \sCueDescr + ")"
    EndWith
  EndIf
  
  If gnSelectedNodeCuePtr >= 0 And gnSelectedNodeSubPtr < 0
    gsSelectedNodeInfo = gsSelectedCueInfo
    
  ElseIf gnSelectedNodeCuePtr >= 0 And gnSelectedNodeSubPtr >= 0
    With aSub(gnSelectedNodeSubPtr)
      gsSelectedNodeInfo = "Sub-Cue " + \sCue + " <" + \nSubNo + "> (" + \sSubDescr + ")"
    EndWith
    
  EndIf
  
  ; debugMsg(sProcName, "gsSelectedNodeInfo=" + gsSelectedNodeInfo)

EndProcedure

Procedure WED_setCollectMenuItem()
  ; PROCNAMEC()
  Protected bEnableCollect
  Protected i, j, k
  Protected sFileName.s
  Protected bAllFilesInProdFolder
  Protected nLenCueFolder
  
  If grProd\bTemplate = #False  ; 'collect' not currently available for templates - too many of the features are not applicable
    bEnableCollect = #True
    nLenCueFolder = Len(gsCueFolder)
    If (nLenCueFolder > 0) And (gsCueFile)
      bAllFilesInProdFolder = #True
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeHasAuds
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              sFileName = aAud(k)\sFileName
              If Len(sFileName) > nLenCueFolder
                If LCase(Left(sFileName, nLenCueFolder)) <> LCase(gsCueFolder)
                  bAllFilesInProdFolder = #False
                  Break 3 ; break out of cue loop (variable i)
                EndIf
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      Next i
    EndIf
  EndIf

  ; debugMsg(sProcName, "bEnableCollect=" + strB(bEnableCollect))
  scsEnableMenuItem(#WED_mnuProdMenu, #WED_mnuCollect, bEnableCollect)

EndProcedure

Procedure WED_setProdNodeText()
  ; PROCNAMEC()

  ; debugMsg(sProcName, #SCS_START)
  
  With grProd
    If WED_checkNodeKeyExists(\nNodeKey)
      If \bTemplate
        SetGadgetItemText(WED\tvwProdTree, WED_getNodeNoForNodeKey(\nNodeKey), \sTmName + " (" + grText\sTextTemplate + ")")
      Else
        SetGadgetItemText(WED\tvwProdTree, WED_getNodeNoForNodeKey(\nNodeKey), \sTitle)
      EndIf
    EndIf
  EndWith
  WED_setSelectedNodeInfo()
  WED_setTBTButtons()

EndProcedure

Procedure.s WED_buildCueNodeText(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nCueCol, nMidiCueCol, nPageCol
  Protected sNodeText.s
  Protected nColNo, nMaxColNo
  
  nCueCol = grOperModeOptions(gnOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_CU)\nCurColNo
  If nCueCol > nMaxColNo
    nMaxColNo = nCueCol
  EndIf
  nMidiCueCol = grOperModeOptions(gnOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_MC)\nCurColNo
  If nMidiCueCol > nMaxColNo
    nMaxColNo = nMidiCueCol
  EndIf
  nPageCol = grOperModeOptions(gnOperMode)\rGrdCuesInfo\aCol(#SCS_GRDCUES_PG)\nCurColNo
  If nPageCol > nMaxColNo
    nMaxColNo = nPageCol
  EndIf
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      For nColNo = 0 To nMaxColNo
        Select nColNo
          Case nCueCol
            sNodeText + \sCue + " "
          Case nMidiCueCol
            If \sMidiCue
              sNodeText + "[" + \sMidiCue + "] "
            EndIf
          Case nPageCol
            If \sPageNo
              sNodeText + \sPageNo + " "
            EndIf
        EndSelect
      Next nColNo
      sNodeText + \sCueDescr
    EndWith
  EndIf

  ProcedureReturn Trim(sNodeText)
EndProcedure

Procedure WED_setCueNodeText(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  ; see also addCueNode()
  Protected nMyNodeNo, sNodeText.s
  
  If pCuePtr > 0
    With aCue(pCuePtr)
      nMyNodeNo = WED_getNodeNoForNodeKey(\nNodeKey)
      ; debugMsg(sProcName, "pCuePtr=" + pCuePtr + ", nMyNodeNo=" + nMyNodeNo + ", \nNodeKey=" + \nNodeKey + ", \sCueDescr=" + \sCueDescr)
      If \nNodeKey <> 0
        If nMyNodeNo >= 0
          sNodeText = WED_buildCueNodeText(pCuePtr)
          If GetGadgetItemText(WED\tvwProdTree, nMyNodeNo) <> sNodeText
            SetGadgetItemText(WED\tvwProdTree, nMyNodeNo, sNodeText)
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  If gbInApplyLabelChanges = #False
    WED_setSelectedNodeInfo()
    WED_setTBTButtons()
  EndIf
  
EndProcedure

Procedure WED_setSubNodeText(pSubPtr)
  ; PROCNAMECS(pSubPtr)
  Protected nMyNodeNo, sNodeText.s
  
  If pSubPtr > 0
    With aSub(pSubPtr)
      nMyNodeNo = WED_getNodeNoForNodeKey(\nNodeKey)
      ; debugMsg(sProcName, "pSubPtr=" + pSubPtr + ", nMyNodeNo=" + nMyNodeNo + ", \nNodeKey=" + \nNodeKey + ", \sSubDescr=" + \sSubDescr)
      If \nNodeKey <> 0
        If nMyNodeNo >= 0
          sNodeText = "<" + \nSubNo + "> " + \sSubDescr
          If GetGadgetItemText(WED\tvwProdTree, nMyNodeNo) <> sNodeText
            SetGadgetItemText(WED\tvwProdTree, nMyNodeNo, sNodeText)
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  If gbInApplyLabelChanges = #False
    WED_setSelectedNodeInfo()
    WED_setTBTButtons()
  EndIf
  
EndProcedure

Procedure WED_setTBTButtonToolTip(nButtonId, sToolTip.s)
  ; PROCNAMEC()

  ; debugMsg(sProcName, "nButtonId=" + nButtonId + ", sToolTip=" + Trim(sToolTip))
  setToolBarBtnToolTip(nButtonId, sToolTip)
  
EndProcedure

Procedure WED_setTBSButtonToolTip(nButtonId, sToolTip.s)
  PROCNAMEC()
  Protected nIndex
  
  nIndex = WED_getTBSIndex(nButtonId)
  scsToolTip(WED\imgButtonTBS[nIndex], sToolTip)
  
EndProcedure

Procedure WED_setEditorButtons()
  PROCNAMEC()
  Protected bEnableUndo, bEnableRedo, bEnableSave
  Protected bEnableSaveAs, bEnableExportCues
  Protected sUndoToolTip.s, sRedoTooltip.s
  Protected nCheckSaveResult

  ; debugMsg(sProcName, #SCS_START)
  
  bEnableUndo = undoAvailable()
  sUndoToolTip = gsToolTipText
  bEnableRedo = redoAvailable()
  sRedoTooltip = gsToolTipText
  ; debugMsg(sProcName, "bEnableUndo=" + strB(bEnableUndo) + ", bEnableRedo=" + strB(bEnableRedo))
  
  
  If bEnableUndo <> grWED\mbUndoEnabled
    ; debugMsg(sProcName, "calling WED_enableTBTButton(#SCS_TBEB_ALL_UNDO, " + strB(bEnableUndo) + ")")
    WED_enableTBTButton(#SCS_TBEB_UNDO, bEnableUndo)
    grWED\mbUndoEnabled = bEnableUndo
  EndIf

  If sUndoToolTip <> grWED\msUndoToolTip
    WED_setTBTButtonToolTip(#SCS_TBEB_UNDO, " Undo " + sUndoToolTip + " ")
    grWED\msUndoToolTip = sUndoToolTip
  EndIf

  If bEnableRedo <> grWED\mbRedoEnabled
    WED_enableTBTButton(#SCS_TBEB_REDO, bEnableRedo)
    grWED\mbRedoEnabled = bEnableRedo
  EndIf

  If sRedoTooltip <> grWED\msRedoToolTip
    WED_setTBTButtonToolTip(#SCS_TBEB_REDO, " Redo " + sRedoTooltip + " ")
    grWED\msRedoToolTip = sRedoTooltip
  EndIf
  
  If grProd\bTemplate = #False
    bEnableSaveAs = #True
    bEnableExportCues = #True
  EndIf
  scsEnableMenuItem(#WED_mnuOtherActions, #WED_mnuSaveAs, bEnableSaveAs)
  scsEnableMenuItem2(#WED_mnuCuesMenu, #WED_mnuExportCues, bEnableExportCues, #WED_mnuCueListPopupMenu)

  nCheckSaveResult = checkSaveToBeEnabled()
  ; debugMsg(sProcName, "checkSaveToBeEnabled() returned " + Str(nCheckSaveResult))
  If nCheckSaveResult > 0
    bEnableSave = #True
    If nCheckSaveResult <> 3
      setUnsavedChanges(#True)
    EndIf
  EndIf
  WED_enableTBTButton(#SCS_TBEB_SAVE, bEnableSave)
  
  ; debugMsg(sProcName, "calling WED_setCollectMenuItem()")
  WED_setCollectMenuItem()

EndProcedure

Procedure WED_setTBTButtons()
  PROCNAMEC()
  Protected bCueTmp, bSubTmp
  Protected i, j

  ; debugMsg(sProcName, #SCS_START)
  
  bCueTmp = #True
  If gnSelectedNodeCuePtr >= 0
    bSubTmp = #True
  Else
    bSubTmp = #False
  EndIf

  ; available with all license levels
  WED_enableTBTButton(#SCS_TBEB_ADD_SF, bSubTmp)   ; audio file sub-cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SS, bSubTmp)   ; SFR sub-cues
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSF, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSS, bSubTmp, #WED_mnuSubsMenu)
  
  If gnLastCue > 0
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuRenumberCues, #True)
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuMultiCueCopyEtc, #True)
  Else
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuRenumberCues, #False)
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuMultiCueCopyEtc, #False)
  EndIf
  
  ; available with SCS Standard and higher
  If (grLicInfo\nLicLevel >= #SCS_LIC_STD) And (gnLastCue > 0)
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuBulkEditCues, #True)
  Else
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuBulkEditCues, #False)
  EndIf

  ; available with SCS Standard and higher
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    bCueTmp = #True
    If gnSelectedNodeCuePtr >= 0
      bSubTmp = #True
    Else
      bSubTmp = #False
    EndIf
  Else
    bCueTmp = #False
    bSubTmp = #False
  EndIf
  WED_enableTBTButton(#SCS_TBEB_ADD_QA, bCueTmp)        ; video cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SA, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QL, bCueTmp)        ; level change cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SL, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QN, bCueTmp)        ; note cues
  WED_enableTBTButton(#SCS_TBEB_ADD_QP, bCueTmp)        ; playlist cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SP, bSubTmp)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQA, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSA, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQL, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSL, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQN, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQP, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSP, bSubTmp, #WED_mnuSubsMenu)

  ; available with Professional and higher
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    bCueTmp = #True
    If gnSelectedNodeCuePtr >= 0
      bSubTmp = #True
    Else
      bSubTmp = #False
    EndIf
  Else
    bCueTmp = #False
    bSubTmp = #False
  EndIf
  WED_enableTBTButton(#SCS_TBEB_ADD_QE, bCueTmp)   ; memo cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SE, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QG, bCueTmp)   ; 'go to' cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SG, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QK, bCueTmp)   ; lighting cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SK, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QM, bCueTmp)   ; control send cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SM, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QQ, bCueTmp)   ; 'Call Cue' cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SQ, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QR, bCueTmp)   ; 'run external program' cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SR, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QT, bCueTmp)   ; 'set position' cues
  WED_enableTBTButton(#SCS_TBEB_ADD_ST, bSubTmp)
  WED_enableTBTButton(#SCS_TBEB_ADD_QU, bCueTmp)   ; 'MTC' cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SU, bSubTmp)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQE, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSE, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQG, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSG, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQJ, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSJ, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQK, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSK, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQM, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSM, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQQ, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSQ, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQR, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSR, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQT, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddST, bSubTmp, #WED_mnuSubsMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQU, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSU, bSubTmp, #WED_mnuSubsMenu)
  
  If grLicInfo\nMaxLiveInputs > 0
    bCueTmp = #True
    If gnSelectedNodeCuePtr >= 0
      bSubTmp = #True
    Else
      bSubTmp = #False
    EndIf
  Else
    bCueTmp = #False
    bSubTmp = #False
  EndIf
  WED_enableTBTButton(#SCS_TBEB_ADD_QI, bCueTmp)   ; live input cues
  WED_enableTBTButton(#SCS_TBEB_ADD_SI, bSubTmp)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddQI, bCueTmp, #WED_mnuCuesMenu)
  scsEnableMenuItem2(#WED_mnuCueListPopupMenu, #WED_mnuAddSI, bSubTmp, #WED_mnuSubsMenu)
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WED_performUndoOrRedoChanges(bPerformUndo, nSelectedRow)
  PROCNAMEC()
  Protected nMyUndoGroupPtr, nUndoTypes, nUndoFlags
  Protected rLastGroupInfo.tyLastGroupInfo
  Protected nNodeKey
  Protected n
  Protected bDisplayCalled
  Protected bSaveOrSetCalled
  
  setMouseCursorBusy()
  gbInUndoOrRedo = #True
  
  debugMsg(sProcName, #SCS_START + ", bPerformUndo=" + strB(bPerformUndo) + ", nSelectedRow=" + nSelectedRow)
  
  WED_hideUndoRedoList()
  
  If nEditAudPtr >= 0
    If aAud(nEditAudPtr)\bAudTypeF
      debugMsg(sProcName, "calling WQF_saveOrSetDisplayInfo(#SCS_SAVEORSET_SAVE)")
      WQF_saveOrSetDisplayInfo(#SCS_SAVEORSET_SAVE)
      bSaveOrSetCalled = #True
    EndIf
  EndIf
  
  For n = 1 To nSelectedRow
    If bPerformUndo
      debugMsg(sProcName, "calling undoLastGroup")
      nMyUndoGroupPtr = undoLastGroup(@rLastGroupInfo) ; pointers may be returned in nCuePtr1 and nCuePtr2
      ; nMyUndoGroupPtr points to group just undone, or -1 if undo failed
    Else
      debugMsg(sProcName, "calling redoLastGroup")
      nMyUndoGroupPtr = redoLastGroup(@rLastGroupInfo) ; ditto
      ; nMyUndoGroupPtr points to group just redone, or -1 if redo failed
    EndIf
    
    With rLastGroupInfo
      
      debugMsg(sProcName, "nMyUndoGroupPtr=" + nMyUndoGroupPtr)
      debugMsg(sProcName, "nCuePtr1="+ \nCuePtr1 + ", nCuePtr2=" + \nCuePtr2 + ", nSubPtr=" + \nSubPtr + ", nAudPtr=" + \nAudPtr +
                          ", nUndoTypes=" + \nUndoTypes + ", nUndoFlags=" + \nUndoFlags)
      If nMyUndoGroupPtr < 0
        debugMsg(sProcName, "exiting loop because nMyUndoGroupPtr=" + nMyUndoGroupPtr)
        Break
      EndIf
      
      If (\nUndoFlags & #SCS_UNDO_FLAG_OPEN_FILE)
        If \nAudPtr >= 0
          If aAud(\nAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
            openMediaFile(\nAudPtr)
          EndIf
        EndIf
      EndIf
      
      If (\nUndoFlags & #SCS_UNDO_FLAG_GENERATE_PLAYORDER)
        If \nSubPtr >= 0
          debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(\nSubPtr) + ")")
          generatePlayOrder(\nSubPtr)
          setLabels(aSub(\nSubPtr)\nCueIndex)
        EndIf
      EndIf
      
      nUndoTypes | \nUndoTypes
      nUndoFlags | \nUndoFlags
      
      debugMsg(sProcName, "gaUndoGroup(" + nMyUndoGroupPtr + ")\nSelectedNodeKey=" + gaUndoGroup(nMyUndoGroupPtr)\nSelectedNodeKey)
      nNodeKey = gaUndoGroup(nMyUndoGroupPtr)\nSelectedNodeKey
      
      If n = nSelectedRow
        ; last iteration of loop
        If (nUndoTypes & #SCS_UNDO_TYPE_PROD)
          If grCED\bProdDisplayed
            debugMsg(sProcName, "calling displayProd()")
            displayProd()
            bDisplayCalled = #True
            nNodeKey = grProd\nNodeKey
          EndIf
        EndIf
        
        If (nUndoTypes & #SCS_UNDO_TYPE_CUE)
          If grCED\bCueDisplayed
            If nEditCuePtr >= 0
              debugMsg(sProcName, "calling displayCue")
              displayCue(nEditCuePtr, nEditSubPtr)
              bDisplayCalled = #True
              nNodeKey = aCue(nEditCuePtr)\nNodeKey
            Else
              nNodeKey = grProd\nNodeKey
            EndIf
          EndIf
        EndIf
        
        If ((nUndoTypes & #SCS_UNDO_TYPE_SUB)) Or ((nUndoTypes & #SCS_UNDO_TYPE_AUD))
          If grCED\bCueDisplayed
            If nEditCuePtr >= 0
              debugMsg(sProcName, "calling displayCue")
              displayCue(nEditCuePtr, nEditSubPtr)
              If nEditAudPtr >= 0
                If aAud(nEditAudPtr)\bAudTypeA
                  WQA_positionVideoForOption()
                EndIf
              EndIf
              bDisplayCalled = #True
              nNodeKey = aCue(nEditCuePtr)\nNodeKey
              If aCue(nEditCuePtr)\bNodeExpanded
                If nEditSubPtr >= 0
                  nNodeKey = aSub(nEditSubPtr)\nNodeKey
                EndIf
              EndIf
            Else
              nNodeKey = grProd\nNodeKey
            EndIf
          EndIf
        EndIf
        
      EndIf  ; end if last iteration of loop
      
      ; debugMsg(sProcName, "nCuePtr1="+ \nCuePtr1 + ", nCuePtr2=" + \nCuePtr2)
      If (\nCuePtr1 >= 0) Or (\nCuePtr2 >= 0)
        
        If \nCuePtr1 >= 0
          renumberSubNos(\nCuePtr1)
          setLabels(\nCuePtr1)
          setDerivedCueFields(\nCuePtr1, #False)
          loadGridRow(\nCuePtr1)
        EndIf
        
        If (\nCuePtr2 >= 0) And (\nCuePtr2 <> \nCuePtr1)
          renumberSubNos(\nCuePtr2)
          setLabels(\nCuePtr2)
          setDerivedCueFields(\nCuePtr2, #False)
          loadGridRow(\nCuePtr2)
        EndIf
        
      EndIf
      
      debugMsg(sProcName, "nNodeKey=" + nNodeKey)
      
    EndWith
    
  Next n
  
  resyncCuePtrs()
  loadCueBrackets()
  setTimeBasedCues()
  loadHotkeyArray()
  loadCueMarkerArrays()
  debugMsg(sProcName, "calling displayOrHideVideoWindows()")
  displayOrHideVideoWindows()
  
  gbCallLoadDispPanels = #True
  gbCallPopulateGrid = #True ; Added 11Jul2023 11.10.0bq
  
  debugMsg(sProcName, "nUndoFlags=" + nUndoFlags + " ($" + Hex(nUndoFlags) + ")")
  If nUndoFlags <> 0
    
    If (nUndoFlags & #SCS_UNDO_FLAG_REDO_PHYSICAL_DEVS)
      debugMsg(sProcName, "calling redoPhysicalDevs")
      redoPhysicalDevs()
    EndIf
    
    If (nUndoFlags & #SCS_UNDO_FLAG_SET_CUE_PTRS)
      debugMsg(sProcName, "calling setCuePtrs(#False)")
      setCuePtrs(#False)
    EndIf
    
    If ((nUndoFlags & #SCS_UNDO_FLAG_REDO_TREE)) Or ((nUndoFlags & #SCS_UNDO_FLAG_SET_PROD_NODE_TEXT)) Or ((nUndoFlags & #SCS_UNDO_FLAG_SET_CUE_NODE_TEXT)) Or ((nUndoFlags & #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT))
      debugMsg(sProcName, "calling redoCueListTree(" + nNodeKey + ")")
      redoCueListTree(nNodeKey)
      bDisplayCalled = #True
      
    ElseIf (nUndoFlags & #SCS_UNDO_FLAG_DISPLAYSUB)     ; displaySub call not necessary if redoCueListTree called - hence the ElseIf
      displaySub(nEditSubPtr)
      bDisplayCalled = #True
      
    EndIf
    
    If (nUndoFlags & #SCS_UNDO_FLAG_REDO_PHYSICAL_DEVS)
      debugMsg(sProcName, "calling applyDevChanges()")
      applyDevChanges()
    EndIf
    
    If (nUndoFlags & #SCS_UNDO_FLAG_SET_MAX_LEVEL) Or (nUndoFlags & #SCS_UNDO_FLAG_SET_LOW_LEVEL)
      setProdGlobals() ; nb also calls redrawAllLevelSliders()
    EndIf
    
    If (nUndoFlags & #SCS_UNDO_FLAG_SET_MASTER_VOL)
      setMasterFader(grProd\fMasterBVLevel)
      If gbMainFormLoaded
        SLD_setLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
        If grProd\fMasterBVLevel < 0
          SLD_setBaseLevel(WMN\sldMasterFader, #SCS_SLD_NO_BASE)
        Else
          SLD_setBaseLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
        EndIf
      EndIf
    EndIf
    
    If (nUndoFlags & #SCS_UNDO_FLAG_SET_DMX_MASTER_FADER)
      DMX_setDMXMasterFader(grProd\nDMXMasterFaderValue)
      If SLD_isSlider(WCN\sldDMXMasterFader)
        SLD_setValue(WCN\sldDMXMasterFader, grProd\nDMXMasterFaderValue)
      EndIf
    EndIf
    
    If (nUndoFlags & #SCS_UNDO_FLAG_REDO_MAIN)
      If gbMainFormLoaded
        setCueDetailsInMain()
      EndIf
    EndIf
    
    If (bDisplayCalled = #False) And (nNodeKey <> 0)
      debugMsg(sProcName, "calling publicNodeClick(" + nNodeKey + ")")
      debugMsg3(sProcName, "calling WED_publicNodeClick(nNodeKey)") 
      WED_publicNodeClick(nNodeKey)
    EndIf
    
  EndIf
  
  If bSaveOrSetCalled
    debugMsg(sProcName, "calling WQF_saveOrSetDisplayInfo(#SCS_SAVEORSET_SET)")
    WQF_saveOrSetDisplayInfo(#SCS_SAVEORSET_SET)
  EndIf
  
  debugMsg(sProcName, "calling setEditorButtons")
  WED_setEditorButtons()
  
  sanityCheck()
  
  ; TEMP ??? 7Sep2023
  debugProd(@grProd)
  debugCuePtrs()
  ; END TEMP ??? 7Sep2023
  
  setMouseCursorNormal()
  
  gbInUndoOrRedo = #False
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_showUndoRedoList(bUndoList)
  PROCNAMEC()
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  buildUndoRedoList(bUndoList)
  HideMenu(#WED_mnuUndoRedoMenu, #False)
  
EndProcedure

Procedure WED_hideUndoRedoList()
  PROCNAMEC()
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  HideMenu(#WED_mnuUndoRedoMenu, #True)
  
EndProcedure

Procedure WED_mnuUndoRedo_Click(nUndoRedoNum)
  PROCNAMEC()
  Protected bPerformUndo
  
  If grMUR\sUndoRedo = "UNDO"
    bPerformUndo = #True
  EndIf
  WED_performUndoOrRedoChanges(bPerformUndo, nUndoRedoNum)
  debugMsg(sProcName, "calling debugProd(@grProd)")
  debugProd(@grProd)
  
EndProcedure

Procedure WED_importAudioFiles(nImportType, sTitle.s="", bDragAndDrop=#False, sFileList.s="", bCreatePlaceHolder=#False, nParentWindow=#WED)
  PROCNAMEC()
  Protected sMyTitle.s
  Protected sFileName.s
  Protected sCueType.s
  Protected nNewCues
  Protected nCuePtr
  Protected sMsg.s
  Protected n
  Protected u
  Protected u2, u3
  Protected Dim u4(0)
  Protected Dim sNewFileName.s(0)
  Protected Dim nNewAudPtr(0)
  Protected sUndoDescr.s
  Protected nFirstCueNodeKey
  Protected nFileCount
  Protected bPlaceHolderReqd
  
  debugMsg(sProcName, #SCS_START + ", nImportType=" + nImportType + ", bCreatePlaceHolder=" + strB(bCreatePlaceHolder))
  
  sMyTitle = Trim(sTitle)
  If Len(sMyTitle) = 0
    sMyTitle = Lang("WED", "ImportAudioFiles")   ; used in message box titles, and also used as 'undo' description
  EndIf
  
  If bDragAndDrop
    nFileCount = CountString(sFileList, Chr(10)) + 1
  Else
    nFileCount = gnSelectedFileCount
  EndIf
  
  If (nFileCount = 0) And (bCreatePlaceHolder)
    bPlaceHolderReqd = #True
    nFileCount = 1
  EndIf
  
  If nFileCount = 1
    nNewCues = nFileCount
    
  Else
    Select nImportType
      Case #SCS_IMPORT_AUDIO_CUES
        nNewCues = nFileCount
        
      Case #SCS_IMPORT_PLAYLIST
        nNewCues = 1
        
      Case #SCS_IMPORT_CANCEL
        gbInImportAudioFiles = #False
        ProcedureReturn -1
        
    EndSelect
  EndIf
  
  debugMsg(sProcName, "gnLastCue=" + gnLastCue + ", nNewCues=" + Str(nNewCues))
  If ((gnLastCue + nNewCues) > gnMaxCueIndex) And (gnMaxCueIndex >= 0)
    sMsg = LangPars("Errors", "CannotAddCues", Str(nNewCues))
    debugMsg(sProcName, sMsg)
    scsMessageRequester(sMyTitle, sMsg, #PB_MessageRequester_Error)
    gbInImportAudioFiles = #False
    ProcedureReturn -1 ; abandon import !!!!!!!!!!!!!
  EndIf
  
  ReDim u4(nFileCount)
  ReDim sNewFileName(nFileCount)
  ReDim nNewAudPtr(nFileCount)
  
  sUndoDescr = sMyTitle
  If nParentWindow = #WED
    u = preChangeProdL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_IMPORT_FILES, -1, #SCS_UNDO_FLAG_REDO_TREE, grProd\nProdId)
    If nEditCuePtr > 0
      nCuePtr = nEditCuePtr
    Else
      nCuePtr = 0
    EndIf
  Else
    nCuePtr = 0
  EndIf
  
  debugMsg(sProcName, "setting gbInPaste")
  gbInPaste = #True     ; suppresses screen refreshing
  
  Select nImportType
    Case #SCS_IMPORT_AUDIO_CUES
      setMouseCursorBusy()
      sCueType = "F"
      nEditCuePtr = nCuePtr
      For n = 1 To nFileCount
        If bPlaceHolderReqd
          sFileName = grText\sTextPlaceHolder
        ElseIf bDragAndDrop
          sFileName = StringField(sFileList, n, Chr(10))
        Else
          sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
          debugMsg(sProcName, "gsSelectedDirectory=" + gsSelectedDirectory + ", gsSelectedFile(" + Str(n-1) + ")=" + gsSelectedFile(n-1))
        EndIf
        addCueWithSubCue("F", #True, #True, "", #True, #True, sFileName)
        debugMsg(sProcName, "calling setCuePtrs(#False)")
        setCuePtrs(#False)
        If nFirstCueNodeKey = 0
          nFirstCueNodeKey = aCue(nEditCuePtr)\nNodeKey
        EndIf
      Next n
      
    Case #SCS_IMPORT_PLAYLIST
      setMouseCursorBusy()
      u2 = newCue()
      If u2 >= 0
        u3 = newSub(nEditCuePtr, 0, "P")
        If u3 >= 0
          aSub(nEditSubPtr)\sSubDescr = LangPars("WQP", "dfltDescr", Str(gnSelectedFileCount))
          aCue(nEditCuePtr)\sCueDescr = aSub(nEditSubPtr)\sSubDescr
          For n = 1 To nFileCount
            If bDragAndDrop
              sFileName = StringField(sFileList, n, Chr(10))
            Else
              sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
            EndIf
            debugMsg(sProcName, "n=" + n + ", sFileName=" + sFileName)
            u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
            nNewAudPtr(n) = nEditAudPtr
            debugMsg(sProcName, "call createAudTypeP(" + GetFilePart(sFileName) + ")")
            createAudTypeP(sFileName)
          Next n
          ; debugMsg(sProcName, "calling setCuePtrs(#False)")
          setCuePtrs(#False)
          ; debugMsg(sProcName, "calling setDerivedSubFields(" + getSubLabel(nEditSubPtr) + ", #True)")
          setDerivedSubFields(nEditSubPtr, #True)
          ; debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nEditSubPtr) + ")")
          generatePlayOrder(nEditSubPtr)
          debugMsg(sProcName, "calling WQP_doPLTotals()")
          WQP_doPLTotals()
          For n = 1 To nFileCount
            ; debugMsg(sProcName, "calling postChangeAudL(u4(" + n + "), #False, " + getAudLabel(nNewAudPtr(n)) + ")")
            postChangeAudL(u4(n), #False, nNewAudPtr(n))
          Next n
          ; debugMsg(sProcName, "calling postChangeSubL(u3, #False)")
          postChangeSubL(u3, #False)
        EndIf
        ; debugMsg(sProcName, "calling postChangeCueL(u2, #False)")
        postChangeCueL(u2, #False)
        nFirstCueNodeKey = aCue(nEditCuePtr)\nNodeKey
      EndIf
      
  EndSelect
  
  debugMsg(sProcName, "calling setCueBassDevsAndMidiPortNos()")
  setCueBassDevsAndMidiPortNos()
  
  gbInPaste = #False
  
  If nParentWindow = #WED
    postChangeProdL(u, #False)
  EndIf
  
  gbInImportAudioFiles = #False
  
  If gbInDragDrop = #False
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    gnCallOpenNextCues = 1
    If nParentWindow = #WED
      redoCueListTree(nFirstCueNodeKey)
      WED_setEditorButtons()
    EndIf
    setMouseCursorNormal()
    SAG(-1)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn nFirstCueNodeKey
  
EndProcedure

Procedure WED_importVideoOrImageFiles()
  PROCNAMEC()
  Protected nFileCount, n
  Protected sTitle.s
  Protected sMyFileName.s
  Protected sFileName.s
  Protected nReply, sCueType.s
  Protected nNewCues
  Protected nCuePtr
  Protected sMsg.s
  Protected u
  Protected u2, u3
  Protected Dim u4(0)
  Protected Dim sNewFileName.s(0)
  Protected Dim nNewAudPtr(0)
  Protected sUndoDescr.s
  Protected nFirstCueNodeKey
  Protected Dim sFileNames.s(10)
  
  sTitle = Lang("Requesters", "VideoFiles")  ; used in message box titles, and also used as 'undo' description
  gbInImportAudioFiles = #True
  
  ; Open the file for reading
  sMyFileName = OpenFileRequester(sTitle, gsVideoDefaultFile, gsVideoImageFilePattern, gnVideoImageFilePatternPosition, #PB_Requester_MultiSelection)
  If Len(sMyFileName) = 0
    ; didn't select anything
    gbInImportAudioFiles = #False
    ProcedureReturn
  EndIf
  gnVideoImageFilePatternPosition = SelectedFilePattern()
  gsVideoDefaultFile = GetPathPart(sMyFileName)
  
  While sMyFileName
    If nFileCount > ArraySize(sFileNames())
      ReDim sFileNames(nFileCount + 10)
    EndIf
    sFileNames(nFileCount) = sMyFileName
    nFileCount + 1
    sMyFileName = NextSelectedFileName()
  Wend
  debugMsg(sProcName, "nFileCount=" + nFileCount)
  For n = 0 To nFileCount - 1
    debugMsg(sProcName, "sFileNames(" + n + ")=" + sFileNames(n))
  Next n
  
  gsAudioFileDialogInitDir = ""
  debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
  
  sCueType = "A"
  nReply = 1
  nNewCues = nFileCount
  
  debugMsg(sProcName, "gnLastCue=" + gnLastCue + ", nNewCues=" + Str(nNewCues))
  If (gnLastCue + nNewCues) > gnMaxCueIndex And gnMaxCueIndex >= 0
    sMsg = LangPars("Errors", "CannotAddCues", Str(nNewCues))
    debugMsg(sProcName, sMsg)
    scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_Error)
    gbInImportAudioFiles = #False
    ProcedureReturn ; abandon import !!!!!!!!!!!!!
  EndIf
  
  sUndoDescr = sTitle
  u = preChangeProdL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_IMPORT_FILES, -1, #SCS_UNDO_FLAG_REDO_TREE, grProd\nProdId)
  
  ReDim u4(nFileCount + 1)
  ReDim sNewFileName(nFileCount + 1)
  ReDim nNewAudPtr(nFileCount + 1)
  
  If nEditCuePtr > 0
    nCuePtr = nEditCuePtr
  Else
    nCuePtr = 0
  EndIf
  
  ; debugMsg(sProcName, "setting gbInPaste")
  gbInPaste = #True     ; suppresses screen refreshing
  
  setMouseCursorBusy()
  DoEvents()
  sCueType = "A"
  nEditCuePtr = nCuePtr
  For n = 1 To nFileCount
    debugMsg(sProcName, "calling createCueTypeA(" + GetFilePart(sFileName) + ")")
    createCueTypeA(sFileName)
    debugMsg(sProcName, "calling setCuePtrs(#False)")
    setCuePtrs(#False)
    If nFirstCueNodeKey = 0
      nFirstCueNodeKey = aCue(nEditCuePtr)\nNodeKey
    EndIf
  Next n
  
  gbInPaste = #False
  
  postChangeProdL(u, #False)
  
  gbInImportAudioFiles = #False
  gbCallPopulateGrid = #True
  gbCallLoadDispPanels = #True
  gnCallOpenNextCues = 1
  redoCueListTree(nFirstCueNodeKey)
  
  WED_setEditorButtons()
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_getNodeNoForNodeKey(nNodeKey)
  PROCNAMEC()
  Protected n, nMyNodeNo
  
  nMyNodeNo = -1
  For n = 0 To CountGadgetItems(WED\tvwProdTree)-1
    If GetGadgetItemData(WED\tvwProdTree, n) = nNodeKey
      nMyNodeNo = n
      Break
    EndIf
  Next n
  
  ProcedureReturn nMyNodeNo
  
EndProcedure

Procedure WED_validateDisplayedItem()
  PROCNAMEC()
  Protected bValidationOK
  
  debugMsg(sProcName, #SCS_START)
  
  bValidationOK = #True
  
  debugMsg(sProcName, "gbSkipValidation=" + strB(gbSkipValidation))
  If gbSkipValidation = #False
    
    If grCED\bProdDisplayed
      debugMsg(sProcName, "calling valProdProperties")
      If WEP_valProdProperties(#True) = #False
        debugMsg(sProcName, "WEP_valProdProperties failed")
        bValidationOK = #False
      Else
        debugMsg(sProcName, "WEP_valProdProperties OK")
      EndIf
      
    ElseIf grCED\bCueDisplayed
      debugMsg(sProcName, "calling valCue")
      If valCue(#False) = #False
        debugMsg(sProcName, "valCue failed")
        bValidationOK = #False
      Else
        debugMsg(sProcName, "valCue OK")
      EndIf
      
    EndIf
    
  EndIf
  
  debugMsg(sProcName, "bValidationOK=" + strB(bValidationOK))
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WED_getFavBtnForFavMnu(nMenuItemNo)
  Protected nBtnId
  
  Select nMenuItemNo
    Case #WED_mnuFavAddQA To #WED_mnuFavAddQU
      nBtnId = #SCS_TBEB_ADD_QA + (nMenuItemNo - #WED_mnuFavAddQA)
    Case #WED_mnuFavAddSA To #WED_mnuFavAddSU
      nBtnId = #SCS_TBEB_ADD_SA + (nMenuItemNo - #WED_mnuFavAddSA)
  EndSelect
  ProcedureReturn nBtnId
EndProcedure

Procedure WED_tbEditor_CategoryClick(nCatId)
  PROCNAMEC()
  Protected n, nMenuItemNo, nBtnId
  Protected nReqdState
  
  debugMsg(sProcName, #SCS_START)
  If nCatId = #SCS_TBEC_FAV
    debugMsg(sProcName, "Favorites")
    If WED_validateDisplayedItem()
      For nMenuItemNo = (#WED_mnuFavStart + 1) To (#WED_mnuFavEnd - 1)
        nReqdState = 0
        nBtnId = WED_getFavBtnForFavMnu(nMenuItemNo)
        If nBtnId > 0
          For n = 0 To #SCS_MAX_ED_FAV
            If grWED\nFavBtnId[n] = nBtnId
              nReqdState = 1
              Break
            EndIf
          Next n
        EndIf
        SetMenuItemState(#WED_mnuFavsMenu, nMenuItemNo, nReqdState)
      Next nMenuItemNo
      DisplayPopupMenu(#WED_mnuFavsMenu, WindowID(#WED))
    EndIf
  EndIf
  
EndProcedure

Procedure WED_mnuFavFiles_Click()
  grWED\bReturnToEditorAfterFavFiles = #True
  WFF_Form_Show(#WED, #True)
EndProcedure

Procedure WED_mnuFav_Click(nMenuItemNo)
  PROCNAMEC()
  Protected nState, nBtnId
  Protected n1, n2, bAdded, sMsg.s
  Protected nMinReqdContainerWidth, nMinReqdWindowWidth
  
  nState = GetMenuItemState(#WED_mnuFavsMenu, nMenuItemNo)
  nBtnId = WED_getFavBtnForFavMnu(nMenuItemNo)
  ; debugMsg(sProcName, "nMenuItemNo=" + nMenuItemNo + ", #WED_mnuFavStart=" + #WED_mnuFavStart + ", nBtnId=" + nBtnId + ", nState=" + nState)
  
  With grWED
    If nState = 1
      ; currently selected (checked) so we need to de-select this favorite
      n2 = -1
      For n1 = 0 To #SCS_MAX_ED_FAV
        If \nFavBtnId[n1] = nBtnId
          \nFavBtnId[n1] = 0
        Else
          n2 + 1
          \nFavBtnId[n2] = \nFavBtnId[n1]
        EndIf
      Next n1
      While n2 < #SCS_MAX_ED_FAV
        n2 + 1
        \nFavBtnId[n2] = 0
      Wend
      
    Else
      ; currently de-selected (unchecked) so we need to select this favorite (add to the end of the list)
      For n1 = 0 To #SCS_MAX_ED_FAV
        If \nFavBtnId[n1] = 0
          \nFavBtnId[n1] = nBtnId
          ; debugMsg(sProcName, "\nFavBtnId[" + n1 + "]=" + \nFavBtnId[n1])
          bAdded = #True
          Break
        EndIf
      Next n1
      If bAdded = #False
        sMsg = LangPars("WED", "MaxFavs", Str(#SCS_MAX_ED_FAV+1), getToolBarBtnCaption(nBtnId))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(getToolBarCatCaption(#SCS_TBEC_FAV), sMsg, #MB_ICONEXCLAMATION)
        ProcedureReturn
      EndIf
    EndIf
    
;     For n1 = 0 To #SCS_MAX_ED_FAV
;       debugMsg(sProcName, "\nFavBtnId[" + n1 + "]=" + \nFavBtnId[n1])
;     Next n1
    
    WED_unloadFavArray()
    
    showEditorFavorites()
    
  EndWith
  
  With WED
;     debugMsg0(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", GadgetX(\cntTopPanel)=" + GadgetX(\cntTopPanel) + ", GadgetWidth(\cntTopPanel)=" + GadgetWidth(\cntTopPanel) +
;                          ", GadgetX(\tbEditor)=" + GadgetX(\tbEditor) + ", GadgetWidth(WED\tbEditor)=" + GadgetWidth(WED\tbEditor))
    nMinReqdContainerWidth = GadgetX(\tbEditor) + GadgetWidth(\tbEditor)
    If nMinReqdContainerWidth > GadgetWidth(\cntTopPanel)
      ResizeGadget(\cntTopPanel, #PB_Ignore, #PB_Ignore, nMinReqdContainerWidth, #PB_Ignore)
      nMinReqdWindowWidth = GadgetX(\cntTopPanel) + GadgetWidth(\cntTopPanel)
      If nMinReqdWindowWidth > WindowWidth(#WED)
        ResizeWindow(#WED, #PB_Ignore, #PB_Ignore, nMinReqdWindowWidth, #PB_Ignore)
        debugMsg(sProcName, "Calling WED_Form_Resized()")
        WED_Form_Resized()
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_loadFavArray()
  PROCNAMEC()
  Protected n, nPos
  Protected sItem.s
  Protected sBtnList.s
  Protected nBtnId
  
  ; sBtnList must be populated in same order as toolbar button id's between #SCS_TBEB_FAV_START and #SCS_TBEB_FAV_END
  sBtnList = "QA,QF,QG,QI,QK,QL,QM,QN,QE,QP,QR,QS,QT,QQ,QU"
  sBtnList + ",SA,SF,SG,SI,SK,SL,SM,SE,SP,SR,SS,ST,SQ,SU"
  
  With grWED
    debugMsg(sProcName, "grEditorPrefs\sFavItems=" + grEditorPrefs\sFavItems)
    For n = 0 To #SCS_MAX_ED_FAV
      nBtnId = 0
      sItem = StringField(grEditorPrefs\sFavItems, (n+1), ",")
      If sItem
        nPos = FindString(sBtnList, sItem)
        If nPos > 0
          nBtnId = #SCS_TBEB_FAV_START + ((nPos+2)/3)
        EndIf
        ; debugMsg(sProcName, "n=" + n + ", sItem=" + sItem + ", nPos=" + Str(nPos) + ", nBtnId=" + Str(nBtnId) + ", #SCS_TBEB_FAV_START=" + Str(#SCS_TBEB_FAV_START))
      EndIf
      \nFavBtnId[n] = nBtnId
    Next n
  EndWith
  
EndProcedure

Procedure WED_unloadFavArray()
  PROCNAMEC()
  Protected n, nPos, nBtnId
  Protected sItem.s
  Protected sFavItems.s
  Protected sBtnList.s
  
  ; sBtnList must be populated in same order as toolbar button id's between #SCS_TBEB_FAV_START and #SCS_TBEB_FAV_END
  sBtnList = "QA,QF,QG,QI,QK,QL,QM,QN,QE,QP,QR,QS,QT,QQ,QU"
  sBtnList + ",SA,SF,SG,SI,SK,SL,SM,SE,SP,SR,SS,ST,SQ,SU"
  
  With grWED
    For n = 0 To #SCS_MAX_ED_FAV
      nBtnId = \nFavBtnId[n]
      If nBtnId > 0
        nPos = ((nBtnId - #SCS_TBEB_FAV_START) * 3) - 2
        sItem = Mid(sBtnList, nPos, 2)
        If sFavItems
          sFavItems + ","
        EndIf
        sFavItems + sItem
        ; debugMsg(sProcName, "n=" + n + ", nBtnId=" + Str(nBtnId) + ", #SCS_TBEB_FAV_START=" + Str(#SCS_TBEB_FAV_START) + ", nPos=" + Str(nPos) + ", sItem=" + sItem)
      EndIf
    Next n
    grEditorPrefs\sFavItems = sFavItems
    debugMsg(sProcName, "grEditorPrefs\sFavItems=" + grEditorPrefs\sFavItems)
  EndWith
  
EndProcedure

Procedure WED_HoldOrRestoreEditPtrs(bHold)
  ; If bHold = #True then hold and set bPtrsChanged=#True; else restore if bPtrsChanged
  PROCNAMEC()
  Static nHoldEditCuePtr, nHoldEditSubPtr, nHoldEditAudPtr, bPtrsChanged
  Protected nNodeKey
  
  If bHold
    nHoldEditCuePtr = nEditCuePtr
    nHoldEditSubPtr = nEditSubPtr
    nHoldEditAudPtr = nEditAudPtr
    nEditSubPtr = gnValidateSubPtr
    If nEditSubPtr >= 0
      ; debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
      nEditCuePtr = aSub(nEditSubPtr)\nCueIndex
    EndIf
    bPtrsChanged = #True
    
  Else ; bHold = #False
    If bPtrsChanged
      ; debugMsg(sProcName, "gbLastVALResult=" + strB(gbLastVALResult) + ", gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnFocusGadgetNo=" + getGadgetName(gnFocusGadgetNo))
      nEditCuePtr = nHoldEditCuePtr
      nEditSubPtr = nHoldEditSubPtr
      ; debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
      nEditAudPtr = nHoldEditAudPtr
      bPtrsChanged = #False
      ; NB the following not yet working properly, so tvwProdTree still has the 'new' node selected, not the node related to the error
      If gbLastVALResult = #False
        If IsGadget(WED\tvwProdTree)
          If gnValidateSubPtr >= 0
            nNodeKey = aSub(gnValidateSubPtr)\nNodeKey
            SGS(WED\tvwProdTree, -1)
            ; debugMsg(sProcName, "gnValidateSubPtr=" + getSubLabel(gnValidateSubPtr) + ", calling setGadgetItemByData(WED\tvwProdTree, " + nNodeKey + ")")
            setGadgetItemByData(WED\tvwProdTree, nNodeKey)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure WED_EventHandler()
  PROCNAMEC()
  Protected nEditorComponent
  Protected nNodeKey, nCuePtr
  Protected nToolBarCatId
  Protected nFileCount, sFileName.s
  Protected nWindowLeft, nWindowTop, nWindowHeight
  Protected nActiveGadgetNo, nActiveWindow
  Protected bValidationResult
  Protected bProcessThisEvent
  Protected nEventParam
  Protected nPosition
  Protected bQuit
  Protected nResponse
  Protected bCreatePlaceHolder
  Protected nIndex
  Protected bDoTab
  Protected dragrow, dragtxt.s, draggadget, oldgadgetlist, width, height
  Protected nSourceItem
  Protected nTreeItem, nTreeItemState
;   Protected nHoldEditCuePtr, nHoldEditSubPtr, nHoldEditAudPtr, bPtrsChanged
  Protected sTitle.s, nVideoImageCues, n
  
  ; debugMsg0(sProcName, #SCS_START + ", gnWindowEvent=" + decodeEvent(gnWindowEvent) + ", grCED\sDisplayedSubType=" + grCED\sDisplayedSubType + ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
  
  With WED
    
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        If IsWindow(#WPL)
          If grWPL\nVSTHost = #SCS_VST_HOST_AUD
            debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(grWPL\nVSTHandleForPluginShowing) + ", #False)")
            WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, grWPL\nVSTHandleForPluginShowing, #False)
          EndIf
        EndIf
        WED_Form_Unload()
        ProcedureReturn
        
      Case #PB_Event_ActivateWindow
        ; Added 21Apr2020 11.8.2.3ay
        ; INFO: Comments about ActivateWindow and DeactivateWindow
        ; While testing 'BlastOff.scs11' for Theo Anderson, Scitech, Perth WA, I found that if cues are playing in the main window while the editor is open
        ; then on changing cues in the main window the focus would frequently switch between the editor and the main window, and may even end up on the main
        ; window, not on the editor. This frequent change of focus is quite distracting and unprofessional. After some experimenting, I found that we could
        ; make the editor window sticky (ie stay on top) unless focus is deliberately moved away from the editor window.
        ; So under #PB_Event_ActivateWindow (editor window gains focus) we set the sticky state, and under #PB_Event_DeactivateWindow we clear the sticky
        ; state UNLESS the editor is still the active window. (See comments under #PB_Event_DeactivateWindow regarding this condition.)
        If GetActiveWindow() = #WED
          ; should be true, I presume
          If getWindowSticky(#WED) = #False
            debugMsg(sProcName, "activatewindow calling setWindowSticky(#WED, #True)")
            setWindowSticky(#WED, #True)
          EndIf
        EndIf
        ; End added 21Apr2020 11.8.2.3ay
        
      Case #PB_Event_DeactivateWindow
        ; INFO: See comments under #PB_Event_ActivateWindow
        nActiveWindow = GetActiveWindow()
        ; debugMsg(sProcName, "deactivate window, GetActiveWindow()=" + decodeWindow(nActiveWindow))
        ; nb #PB_Event_DeactivateWindow for #WED seems to occur even if the 'active window' is still #WED. Don't know why, but do not want to continue this processing if the active window is still #WED.
        If nActiveWindow <> #WED
          ; Added 21Apr2020 11.8.2.3ay
          If getWindowSticky(#WED)
            ; debugMsg(sProcName, "deactivatewindow calling setWindowSticky(#WED, #False)")
            setWindowSticky(#WED, #False)
            If IsWindow(nActiveWindow)
              ; Seems we need to force nActiveWindow (eg #WMN) to the front or the editor window stays in front until the user clicks a second time on nActiveWindow.
              ; Even issuing SetActiveWindow(nActiveWindow) doesn't force nActiveWindow to the front. Procedure bringWindowToFront() was written specifically for
              ; this requirement.
              ; debugMsg0(sProcName, "calling bringWindowToFront(" + decodeWindow(nActiveWindow) + ")")
              bringWindowToFront(nActiveWindow)
            EndIf
          EndIf
          ; End added 21Apr2020 11.8.2.3ay
          If IsWindow(#WVP) ; #WVP is VST Plugins window
            debugMsg(sProcName, "calling WVP_refreshWindow(#False)")
            WVP_refreshWindow(#False)
          EndIf
        EndIf
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        clearSelectedFileInfo() ; Added 13Jul2021 11.8.3au
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn
            ; added 5Jul2016 11.5.1 following emails from C.Peters asking the ENTER be treated as TAB
            PostMessage_(WindowID(#WED), #WM_KEYDOWN, #VK_TAB, 0)
            PostMessage_(WindowID(#WED), #WM_KEYUP, #VK_TAB, 0)
            ; see also code later in this procedure where the keyboard shortcut is removed while an editor gadgetr has focus
            ; this is to enable 'return' to be used correctly when setting up or maintaining a memo
            
          ; Case #SCS_mnuKeyboardEscape   ; Escape
          ;   WED_Form_Unload()
            ; 23Jun2015 11.4.0: commented out the above having decided it's not a good idea to close the editor window if the user presses Esc
            
            ;
            ; keyboard shortcuts
            ;
;           Case #SCS_mnuKeyboardCtrlA  ; 'select all' (only used by some sub types, eg video/image cues)
          Case #SCS_WEDF_SelectAll  ; 'select all' (only used by some sub types, eg video/image cues)
            Select grCED\sDisplayedSubType
              Case "A"
                WQA_EventHandler()
              Case "E"
                WQE_EventHandler()
              Case "F"
                WQF_EventHandler()
              Case "G"
                WQG_EventHandler()
              Case "I"
                WQI_EventHandler()
              Case "J"
                WQJ_EventHandler()
              Case "K"
                WQK__EventHandler()
              Case "L"
                WQL_EventHandler()
              Case "M"
                WQM_EventHandler()
              Case "P"
                WQP_EventHandler()
              Case "Q"
                WQQ_EventHandler()
              Case "R"
                WQR_EventHandler()
              Case "S"
                WQS_EventHandler()
              Case "T"
                WQT_EventHandler()
              Case "U"
                WQU_EventHandler()
            EndSelect
            
          ; menu items under 'Other Actions' button
          Case #WED_mnuNew
            If valProd()
              If WED_validateDisplayedItem()
                newProd()
              EndIf
            EndIf
            
          Case #WED_mnuOpen
            If valProd()
              If WED_validateDisplayedItem()
                DisplayPopupMenu(#WED_mnuOpenFile, WindowID(#WED))
              EndIf
            EndIf
            
          Case #WED_mnuOpenFile
            WED_mnuOpenFile_Click()
            
          Case #WED_mnuOptions
            If WED_validateDisplayedItem()
              setMouseCursorBusy()
              WOP_Form_Show(#True, #WED, #SCS_OPTNODE_EDITING)
            EndIf
            
          Case #SCS_WEDF_Save
            WED_processSave()
            
          Case #WED_mnuSaveAs
            If grProd\bTemplate = #False
              If valProd()
                If WED_validateDisplayedItem()
                  gbSaveAs = #True
                  debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #True)")
                  writeXMLCueFile(#False, #False, #True)
                  WED_setWindowTitle()
                EndIf
              EndIf
            EndIf
            
          Case #SCS_WEDF_FindCue
            WED_processFindCue()
            
          Case #SCS_WEDF_CallLinkDevs
            Select grCED\sDisplayedSubType
              Case "F"
                WQF_EventHandler()
            EndSelect
            
          Case #WED_mnuPrint
            If valProd()
              If WED_validateDisplayedItem()
                WPR_Form_Show(#WED, #True)
              EndIf
            EndIf
            
          Case #WED_mnuFavFiles
            WED_mnuFavFiles_Click()
            
            ; 'Recent File' popup menu items
          Case #WED_mnuRecentFile_0 To #WED_mnuRecentFile_9
            WED_mnuRecentFile_Click(gnEventMenu - #WED_mnuRecentFile_0) ; argument is index in the range 0-9
            
            ; menu items under P button
          Case #WED_mnuProdProperties
            If WED_validateDisplayedItem()
              WED_publicNodeClick(grProd\nNodeKey)
            EndIf
            
          Case #WED_mnuProdTimer
            If WED_validateDisplayedItem()
              WED_mnuProdTimer_Click()
            EndIf
            
          Case #WED_mnuCollect
            WED_mnuCollect_Click()
            
          ; menu items under Q button or cue list right-click menu
          Case #WED_mnuAddQA
            ; addCueWithSubCue("A", #True)
            ; identical coding under WED_tbEditor_ButtonClick()
            If WED_validateDisplayedItem()
              If WED_checkVideoPlaybackLibrary()
                ; If we have Video/Image & Capture available just do a placeholder setting for later choosing.
                If checkif_VidCapDevsDefined()
                  addCueWithSubCue("A", #True, #True, "", #True)
                Else
                  debugMsg(sProcName, "mnuAddQA calling videoFileRequester()")
                  nFileCount = videoFileRequester(Lang("Requesters", "AddQA"), #True)
                  If nFileCount = 0
                    nResponse = scsMessageRequester(Lang("Requesters", "AddQA"), Lang("Requesters", "PlaceHolderA"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                    If nResponse = #PB_MessageRequester_Yes
                      bCreatePlaceHolder = #True
                    EndIf
                  EndIf
                  If (nFileCount > 0) Or (bCreatePlaceHolder)
                    If nFileCount > 50
                      If checkManyFilesOK(nFileCount) = #False
                        bQuit = #True
                      EndIf
                    EndIf
                    If bQuit = #False
                      ; addCueWithSubCue("A", #True, #True, "", #True) ; Deleted 14Feb2022 11.9.0
                      ; Added 14Feb2022 11.9.0 (copied from #SCS_TBEB_ADD_QA processing in WED_tbEditor_ButtonClick())
                      If nFileCount > 1
                        sTitle = Lang("Menu", "mnuAddQA")
                        nVideoImageCues = askHowManyVideoCues(nFileCount, sTitle)
                      Else
                        nVideoImageCues = 1
                      EndIf
                      If nVideoImageCues = 1
                        addCueWithSubCue("A", #True, #True, "", #True)
                      Else
                        For n = 1 To nVideoImageCues
                          sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
                          nCuePtr = addCueWithSubCue("A", #True, #True, "", #True, #True, sFileName)
                          debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nCueState=" + decodeCueState(aCue(nCuePtr)\nCueState))
                          If aCue(nCuePtr)\nCueState = #SCS_CUE_READY
                            ; close the cue to free any TVG control - important if many video files are added in this paste
                            debugMsg(sProcName, "calling closeCue(" + getCueLabel(nCuePtr) + ")")
                            closeCue(nCuePtr)
                          EndIf
                        Next n
                      EndIf
                      ; End added 14Feb2022 11.9.0 (copied from )
                    EndIf ; EndIf bQuit = #False
                  EndIf ; EndIf (nFileCount > 0) Or (bCreatePlaceHolder)
                EndIf ; EndIf checkif_VidCapDevsDefined()/ Else
              EndIf ; EndIf WED_checkVideoPlaybackLibrary()
            EndIf ; EndIf WED_validateDisplayedItem()
            
          Case #WED_mnuAddQE
            addCueWithSubCue("E", #True)
            
          Case #WED_mnuAddQF
            ; identical coding under WED_tbEditor_ButtonClick()
            If WED_validateDisplayedItem()
              Select grEditingOptions\nAudioFileSelector
                Case #SCS_FO_SCS_AFS
                  WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddQF", #True)
                Case #SCS_FO_WINDOWS_FS
                  nFileCount = audioFileRequester(Lang("Requesters", "AddQF"), #True, #WED)
                  bQuit = #False
                  If nFileCount = 0
                    nResponse = scsMessageRequester(Lang("Requesters", "AddQF"), Lang("Requesters", "PlaceHolderF"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                    If nResponse = #PB_MessageRequester_Yes
                      bCreatePlaceHolder = #True
                    EndIf
                  EndIf
                  If (nFileCount > 0) Or (bCreatePlaceHolder)
                    If nFileCount > 50
                      If checkManyFilesOK(nFileCount) = #False
                        bQuit = #True
                      EndIf
                    EndIf
                    If bQuit = #False
                      WED_importAudioFiles(#SCS_IMPORT_AUDIO_CUES, Lang("WED", "FavAddQF"),#False,"",bCreatePlaceHolder)
                    EndIf
                  EndIf
              EndSelect
            EndIf
            
          Case #WED_mnuAddQG
            addCueWithSubCue("G", #True)
          Case #WED_mnuAddQI
            addCueWithSubCue("I", #True)
          Case #WED_mnuAddQJ
            addCueWithSubCue("J", #True)
          Case #WED_mnuAddQK
            addCueWithSubCue("K", #True)
          Case #WED_mnuAddQL
            addCueWithSubCue("L", #True)
          Case #WED_mnuAddQM
            addCueWithSubCue("M", #True)
          Case #WED_mnuAddQN
            addCueWithSubCue("N", #True)
            
          Case #WED_mnuAddQP
            ; identical coding under WED_tbEditor_ButtonClick()
            If WED_validateDisplayedItem()
              Select grEditingOptions\nAudioFileSelector
                Case #SCS_FO_SCS_AFS
                  WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddQP", #True)
                Case #SCS_FO_WINDOWS_FS
                  nFileCount = audioFileRequester(Lang("Requesters", "AddQP"), #True, #WED)
                  If nFileCount = 0
                    nResponse = scsMessageRequester(Lang("Requesters", "AddQP"), Lang("Requesters", "PlaceHolderP"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                    If nResponse = #PB_MessageRequester_Yes
                      bCreatePlaceHolder = #True
                    EndIf
                  EndIf
                  If (nFileCount > 0) Or (bCreatePlaceHolder)
                    If nFileCount > 50
                      If checkManyFilesOK(nFileCount) = #False
                        bQuit = #True
                      EndIf
                    EndIf
                    If bQuit = #False
                      addCueWithSubCue("P", #True, #True, "", #True)
                    EndIf
                  EndIf
              EndSelect
            EndIf
            
          Case #WED_mnuAddQQ
            addCueWithSubCue("Q", #True)
          Case #WED_mnuAddQR
            addCueWithSubCue("R", #True)
          Case #WED_mnuAddQS
            addCueWithSubCue("S", #True)
          Case #WED_mnuAddQT
            addCueWithSubCue("T", #True)
          Case #WED_mnuAddQU
            addCueWithSubCue("U", #True)
            
          Case #WED_mnuImportCues
            If valProd()
              If WED_validateDisplayedItem()
                WIM_Form_Show(#True)
              EndIf
            EndIf
            
          Case #WED_mnuImportCSV
            If valProd()
              If WED_validateDisplayedItem()
                WIC_Form_Show(#True)
              EndIf
            EndIf
            
          Case #WED_mnuImportDevs
            If valProd()
              If WED_validateDisplayedItem()
                WID_Form_Show(#True)
              EndIf
            EndIf
            
          Case #WED_mnuExportCues
            WED_mnuExportCues_Click()
            
          Case #WED_mnuRenumberCues
            If valProd()
              If WED_validateDisplayedItem()
                WLC_Form_Show(#True)
              EndIf
            EndIf
            
          Case #WED_mnuBulkEditCues
            If valProd()
              If WED_validateDisplayedItem()
                WBE_Form_Show(#True)
              EndIf
            EndIf
            
          Case #WED_mnuCopyProps
            If valProd()
              If WED_validateDisplayedItem()
                WCP_Form_Show(#True)
              EndIf
            EndIf
            
          Case #WED_mnuMultiCueCopyEtc
            If valProd()
              If WED_validateDisplayedItem()
                debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr))
                WED_HoldOrRestoreEditPtrs(#True) ; Added 17Nov2023 11.10.0-b03 following crash reported by Michel Winogradoff where nEditCueptr end up at -1 after multi-cue copy when user tried to click on the activation method of the cue
                ; debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr))
                WMC_Form_Show(#True)
                debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr))
                WED_HoldOrRestoreEditPtrs(#False) ; Added 17Nov2023 11.10.0-b03
                debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr))
              EndIf
            EndIf
            
            ;/
            ; menu items under S button or cue list right-click menu
            ;/
          Case #WED_mnuAddSA
            ; identical coding under WED_tbEditor_ButtonClick()
            If WED_validateDisplayedItem()
              If WED_checkVideoPlaybackLibrary()
                clearSelectedFileInfo()
                If checkif_VidCapDevsDefined()
                  addSubCue("A", #True, "", #True)
                Else
                  debugMsg(sProcName, "ADD_SA calling videoFileRequester()")
                  nFileCount = videoFileRequester(Lang("Requesters", "AddSA"), #True)
                  If nFileCount = 0
                    nResponse = scsMessageRequester(Lang("Requesters", "AddSA"), Lang("Requesters", "PlaceHolderA"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                    If nResponse = #PB_MessageRequester_Yes
                      bCreatePlaceHolder = #True
                    EndIf
                  EndIf
                  If (nFileCount > 0) Or (bCreatePlaceHolder)
                    If nFileCount > 50
                      If checkManyFilesOK(nFileCount) = #False
                        bQuit = #True
                      EndIf
                    EndIf
                    If bQuit = #False
                      addSubCue("A", #True, "", #True)
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
            
          Case #WED_mnuAddSE
            addSubCue("E")
            
          Case #WED_mnuAddSF
            ; identical coding under WED_tbEditor_ButtonClick()
            If WED_validateDisplayedItem()
              Select grEditingOptions\nAudioFileSelector
                Case #SCS_FO_SCS_AFS
                  WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddSF", #False)
                Case #SCS_FO_WINDOWS_FS
                  nFileCount = audioFileRequester(Lang("Requesters", "AddSF"), #False, #WED)
                  If nFileCount = 0
                    nResponse = scsMessageRequester(Lang("Requesters", "AddSF"), Lang("Requesters", "PlaceHolderF"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                    If nResponse = #PB_MessageRequester_Yes
                      bCreatePlaceHolder = #True
                    EndIf
                  EndIf
                  If (nFileCount > 0) Or (bCreatePlaceHolder)
                    If nFileCount > 50
                      If checkManyFilesOK(nFileCount) = #False
                        bQuit = #True
                      EndIf
                    EndIf
                    If bQuit = #False
                      If bCreatePlaceHolder
                        sFileName = grText\sTextPlaceHolder
                      Else
                        sFileName = gsSelectedDirectory + gsSelectedFile(0)
                      EndIf
                      debugMsg(sProcName, "sFileName=" + sFileName)
                      addSubCue("F", #True, sFileName, #True)
                    EndIf
                  EndIf
              EndSelect
            EndIf
            
          Case #WED_mnuAddSG
            addSubCue("G")
          Case #WED_mnuAddSI
            addSubCue("I")
          Case #WED_mnuAddSJ
            addSubCue("J")
          Case #WED_mnuAddSK
            addSubCue("K")
          Case #WED_mnuAddSL
            addSubCue("L")
          Case #WED_mnuAddSM
            addSubCue("M")
            
          Case #WED_mnuAddSP
            ; identical coding under WED_tbEditor_ButtonClick()
            If WED_validateDisplayedItem()
              Select grEditingOptions\nAudioFileSelector
                Case #SCS_FO_SCS_AFS
                  WFO_Form_Show(#True, #SCS_MODRETURN_FILE_OPENER, "AddSP", #True)
                Case #SCS_FO_WINDOWS_FS
                  nFileCount = audioFileRequester(Lang("Requesters", "AddSP"), #True, #WED)
                  If nFileCount = 0
                    nResponse = scsMessageRequester(Lang("Requesters", "AddSP"), Lang("Requesters", "PlaceHolderP"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                    If nResponse = #PB_MessageRequester_Yes
                      bCreatePlaceHolder = #True
                    EndIf
                  EndIf
                  If (nFileCount > 0) Or (bCreatePlaceHolder)
                    If nFileCount > 50
                      If checkManyFilesOK(nFileCount) = #False
                        bQuit = #True
                      EndIf
                    EndIf
                    If bQuit = #False
                      addSubCue("P", #True, "", #True)
                    EndIf
                  EndIf
              EndSelect
            EndIf
            
          Case #WED_mnuAddSQ
            addSubCue("Q")
          Case #WED_mnuAddSR
            addSubCue("R")
          Case #WED_mnuAddSS
            addSubCue("S")
          Case #WED_mnuAddST
            addSubCue("T")
          Case #WED_mnuAddSU
            addSubCue("U")
            
            ; menu items under Favorites category
          Case #WED_mnuFavStart To #WED_mnuFavEnd
            WED_mnuFav_Click(gnEventMenu)
            
            ; WQA menu items
          Case #WQA_mnu_DummyFirst To #WQA_mnu_DummyLast
            WQA_EventHandler()
            
;           Case #WQA_mnuRotate To #WQA_mnuRotateDummyLast
;             WQA_EventHandler()
;             
;           Case #WQA_mnuOther To #WQA_mnuOtherDummyLast
;             WQA_EventHandler()
            
            ; WQE menu items
          Case #WQE_mnu_DummyFirst To #WQE_mnu_DummyLast
            WQE_EventHandler()
            
            ; WQF menu items
          Case #WQF_mnu_DummyFirst To #WQF_mnu_DummyLast
            WQF_EventHandler()
            
            ; WQP menu items
          Case #WQP_mnu_DummyFirst To #WQP_mnu_DummyLast
            WQP_EventHandler()
            
            ; cut, copy, paste and delete on cue list right-click menu
          Case #WED_mnuCut
            nIndex = WED_getTBSIndex(#SCS_STANDARD_BTN_CUT)
            If getEnabled(WED\imgButtonTBS[nIndex])
              WED_imgButtonTBS_Click(#SCS_STANDARD_BTN_CUT)
            EndIf
          Case #WED_mnuCopy
            nIndex = WED_getTBSIndex(#SCS_STANDARD_BTN_COPY)
            If getEnabled(WED\imgButtonTBS[nIndex])
              WED_imgButtonTBS_Click(#SCS_STANDARD_BTN_COPY)
            EndIf
          Case #WED_mnuPaste
            nIndex = WED_getTBSIndex(#SCS_STANDARD_BTN_PASTE)
            If getEnabled(WED\imgButtonTBS[nIndex])
              WED_imgButtonTBS_Click(#SCS_STANDARD_BTN_PASTE)
            EndIf
          Case #WED_mnuDelete
            nIndex = WED_getTBSIndex(#SCS_STANDARD_BTN_DELETE)
            If getEnabled(WED\imgButtonTBS[nIndex])
              WED_imgButtonTBS_Click(#SCS_STANDARD_BTN_DELETE)
            EndIf
            
            ; timefield bump left/right
          Case #SCS_ALLF_BumpLeft, #SCS_ALLF_BumpRight
            nActiveGadgetNo = GetActiveGadget()
            debugMsg(sProcName, "nActiveGadgetNo=" + getWindowName(getGadgetWindowNo(sProcName, nActiveGadgetNo)) + "\" + getGadgetName(nActiveGadgetNo))
            Select nActiveGadgetNo
              Case WQF\txtStartAt
                WQF_txtStartAt_KeyDown(gnEventMenu)
              Case WQF\txtEndAt
                WQF_txtEndAt_KeyDown(gnEventMenu)
              Case WQF\txtLoopStart
                WQF_txtLoopStart_KeyDown(gnEventMenu)
              Case WQF\txtLoopEnd
                WQF_txtLoopEnd_KeyDown(gnEventMenu)
              Case WQF\txtLoopXFadeTime
                WQF_txtLoopXFadeTime_KeyDown(gnEventMenu)
              Case WQF\txtFadeInTime
                WQF_txtFadeInTime_KeyDown(gnEventMenu)
              Case WQF\txtFadeOutTime
                WQF_txtFadeOutTime_KeyDown(gnEventMenu)
            EndSelect
            
          Case #SCS_WEDF_DecLevels, #SCS_WEDF_IncLevels
            ; debugMsg(sProcName, "grCED\sDisplayedSubType=" + grCED\sDisplayedSubType)
            Select grCED\sDisplayedSubType
              Case "A"
                WQA_EventHandler()
              Case "F"
                WQF_EventHandler()
              Case "L"
                WQL_EventHandler()
            EndSelect
            
          Case #SCS_WEDF_SkipBack, #SCS_WEDF_SkipForward
            Select grCED\sDisplayedSubType
              Case "A"
                WQA_EventHandler()
              Case "F"
                WQF_EventHandler()
              Case "P"
                WQP_EventHandler()
            EndSelect
            
          Case #SCS_WEDF_Rewind, #SCS_WEDF_PlayPause, #SCS_WEDF_Stop
            Select grCED\sDisplayedSubType
              Case "A"
                WQA_EventHandler()
              Case "F"
                WQF_EventHandler()
              Case "L"
                WQL_EventHandler()
              Case "P"
                WQP_EventHandler()
            EndSelect
            
          Case #SCS_WEDF_AddCueMarker, #SCS_WEDF_CueMarkerNext, #SCS_WEDF_CueMarkerPrev
            Select grCED\sDisplayedSubType
              Case "A"
                WQA_EventHandler()
              Case "F"
                WQF_EventHandler()
            EndSelect
            
          Case #SCS_WEDF_Undo
            debugMsg(sProcName, "#SCS_WEDF_Undo=" + #SCS_WEDF_Undo)
            If grWED\mbUndoEnabled
              WED_performUndoOrRedoChanges(#True, 1)
            EndIf

          Case #SCS_WEDF_Redo
            If grWED\mbRedoEnabled
              WED_performUndoOrRedoChanges(#False, 1)
            EndIf
            
          Case #SCS_WEDK_TapDelay
            If grCED\sDisplayedSubType = "K"
              WQK__EventHandler()
            EndIf
            
          Case #WEP_mnuGridColors To #WEP_mnuGridColorsDummyLast
            WEP_mnuGridColor_Selection(gnEventMenu)
            
          Case #WEP_mnuCSDevTypeMidiOut, #WEP_mnuCSDevTypeMidiThru, #WEP_mnuCSDevTypeRS232Out, #WEP_mnuCSDevTypeNetworkOut, #WEP_mnuCSDevTypeHTTPRequest
            WEP_mnuCSDevType_Selection(gnEventMenu)
            
          Default
            If gnEventMenu >= #WED_mnuUndoRedo_01
              ; undo/redo menu items
              WED_mnuUndoRedo_Click(gnEventMenu - #WED_mnuUndoRedo_01 + 1)
            Else
              debugMsg0(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
            EndIf
            
        EndSelect
        If gbModalDisplayed = #False  ; 23Sep2017 11.7.0 - do not issue SAW(#WED) if a modal window (such as #WLC) is currently displayed
          SAW(#WED) ; added 18Aug2017 11.7.0
        EndIf
        
      Case #PB_Event_Gadget
        nEditorComponent = gaGadgetProps(gnEventGadgetPropsIndex)\nEditorComponent
        ; debugMsg0(sProcName, "nEditorComponent=" + nEditorComponent + ", gnEventGadgetType=" + gnEventGadgetType)
        If gnEventGadgetType = #SCS_GTYPE_TOOLBAR_CAT
          nToolBarCatId = gaGadgetProps(gnEventGadgetPropsIndex)\nToolBarCatId
        EndIf
        
        Select gnEventType
          Case #PB_EventType_Focus, #PB_EventType_LostFocus
            If gnEventGadgetPropsIndex >= 0
              If IsGadget(gaGadgetProps(gnEventGadgetPropsIndex)\nGadgetNoForEvHdlr)
                Select GadgetType(gaGadgetProps(gnEventGadgetPropsIndex)\nGadgetNoForEvHdlr)
                  Case #PB_GadgetType_Editor
                    If gnEventType = #PB_EventType_Focus
                      RemoveKeyboardShortcut(#WED, #PB_Shortcut_Return)
                    Else
                      AddKeyboardShortcut(#WED, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
                    EndIf
                EndSelect
              EndIf
            EndIf
        EndSelect
        
        If gnEventSliderNo > 0
          ; debugMsg(sProcName, "gnSliderEvent=" + gnSliderEvent + ", nEditorComponent=" + nEditorComponent)
          Select nEditorComponent
            Case #WEP
              WEP__EventHandler()
            Case #WEC
              WEC_EventHandler()
            Case #WQA
              WQA_EventHandler()
            Case #WQE
              WQE_EventHandler()
            Case #WQF
              WQF_EventHandler()
            Case #WQG
              WQG_EventHandler()
            Case #WQI
              WQI_EventHandler()
            Case #WQJ
              WQJ_EventHandler()
            Case #WQK
              WQK__EventHandler()
            Case #WQL
              WQL_EventHandler()
            Case #WQM
              WQM_EventHandler()
            Case #WQP
              WQP_EventHandler()
            Case #WQQ
              WQQ_EventHandler()
            Case #WQR
              WQR_EventHandler()
            Case #WQS
              WQS_EventHandler()
            Case #WQT
              WQT_EventHandler()
            Case #WQU
              WQU_EventHandler()
          EndSelect
          ProcedureReturn
        EndIf
        
        If nEditorComponent = 0
          ; WED event
          ; debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventGadgetType=" + gnEventGadgetType + ", gnEventButtonId=" + gnEventButtonId + ", nToolBarCatId=" + nToolBarCatId)
          If gnEventButtonId > 0
            ; gadget is a standard button or a toolbar button
            ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId)
            If gnEventGadgetType = #SCS_GTYPE_TOOLBAR_BTN
              Select gnEventType
                Case #PB_EventType_LeftClick
                  ; debugMsg(sProcName, "calling WED_tbEditor_ButtonClick(" + gnEventButtonId + ")")
                  ; WED_tbEditor_ButtonClick(gnEventButtonId)
                  ; The above replaced 4Jul2016 11.5.1 following bug report from Peter Wintle who reported that changing the cue number and then immediately clicking the Save button
                  ; without tabbing out of the field would throw a sanity check error. This was caused by PB(?) raising the click event on the button BEFORE the lost-focus event on
                  ; the cue label text field. SAG(-1) forces the lost focus event, but just adding that alone did not help - we need to defer processing the click event
                  ; until at least an extra cycle, so to do that we pass the button click event to SAM with a 100ms delay.
                  SAG(-1)
                  samAddRequest(#SCS_SAM_EDITOR_BTN_CLICK, gnEventButtonId, 0, 0, "", ElapsedMilliseconds()+100)
                  
                Case #PB_EventType_MouseEnter, #PB_EventType_MouseLeave
                  setToolBarBtnMouseOver(gnEventButtonId, gnEventType)
                  
              EndSelect
            Else
              If gnEventType = #PB_EventType_LeftClick
                WED_imgButtonTBS_Click(gnEventButtonId)
              EndIf
            EndIf
            
          ElseIf nToolBarCatId > 0
            ; gadget is a toolbar category
            Select gnEventType
              Case #PB_EventType_LeftClick
                debugMsg(sProcName, "calling WED_tbEditor_CategoryClick(" + nToolBarCatId + "), #PB_EventType_LeftClick=" + #PB_EventType_LeftClick + ", gnWindowEvent=" + decodeEvent(gnWindowEvent))
                WED_tbEditor_CategoryClick(nToolBarCatId)
                
              Case #PB_EventType_MouseEnter, #PB_EventType_MouseLeave
                setToolBarCatMouseOver(nToolBarCatId, gnEventType)
                
            EndSelect
            
          Else
            ; some other gadget
            Select gnEventGadgetNoForEvHdlr
              Case \splEditV
                WED_splEditVRepositioned()
                grEditorPrefs\nSplitterPosEditV = GGS(\splEditV)
                
              Case \tvwProdTree
                ; debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
                ; debugMsg0(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()) + ", nEditorComponent=" + nEditorComponent +
                ;                      ", gnValidateGadgetNo=" + getGadgetName(gnValidateGadgetNo) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr))
                Select gnEventType
                  Case #PB_EventType_LeftClick
                    debugMsg(sProcName, decodeEventType() + ": calling WED_setTBSButtons()")
                    WED_setTBSButtons()
                    
                  Case #PB_EventType_Change, #PB_EventType_RightClick
                    debugMsg(sProcName, decodeEventType() + ": GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree) + ", grCED\nSelectedItemForDragAndDrop=" + grCED\nSelectedItemForDragAndDrop)
                    bProcessThisEvent = #True
                    If gnEventType = #PB_EventType_Change
                      If (GGS(WED\tvwProdTree) = -1) And (grCED\nSelectedItemForDragAndDrop >= 0)
                        bProcessThisEvent = #False
                      EndIf
                    EndIf
                    If bProcessThisEvent
                      grCED\nTreeEventCount + 1
                      If grCED\nTreeEventCount > 2
                        scsToolTip(\tvwProdTree,"")
                      EndIf
                      If grWED\nTreeGadgetItemExpanded > 0   ; set by WED_windowCallback()
                                                             ; 1 = collapsed, 2 = expanded, 0 = something else
                        debugMsg(sProcName, "grWED\nTreeGadgetItem=" + grWED\nTreeGadgetItem + ", grWED\nTreeGadgetItemExpanded=" + grWED\nTreeGadgetItemExpanded)
                        If grWED\nTreeGadgetItem > 0
                          ; not the root (prod) node
                          nNodeKey = GetGadgetItemData(WED\tvwProdTree, grWED\nTreeGadgetItem)
                          nCuePtr = WED_getCueIndexForNodeKey(nNodeKey)
                          If (nCuePtr > 0) And (nCuePtr <= gnLastCue)
                            If grWED\nTreeGadgetItemExpanded = 2
                              aCue(nCuePtr)\bNodeExpanded = #True
                            Else
                              aCue(nCuePtr)\bNodeExpanded = #False
                            EndIf
                          EndIf
                          debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", nCuePtr=" + getCueLabel(nCuePtr) + ", \bNodeExpanded=" + strB(aCue(nCuePtr)\bNodeExpanded))
                        EndIf
                        grWED\nTreeGadgetItemExpanded = 0
                        If GGS(\tvwProdTree) <> grWED\nTreeGadgetItem
                          debugMsg(sProcName, "calling SGS(\tvwProdTree, " + grWED\nTreeGadgetItem + ")")
                          SGS(\tvwProdTree, grWED\nTreeGadgetItem)
                        EndIf
                        HighlightTreeviewItem(\tvwProdTree, grWED\nTreeGadgetItem, #True)
                      EndIf
                      debugMsg(sProcName, "calling WED_tvwProdTree_NodeClick()")
                      WED_tvwProdTree_NodeClick()
                      debugMsg(sProcName, "returned from WED_tvwProdTree_NodeClick()")
                      
                      If gnEventType = #PB_EventType_RightClick
                        DisplayPopupMenu(#WED_mnuCueListPopupMenu, WindowID(#WED))
                      EndIf
                      SAG(\tvwProdTree)
                    EndIf
                    
                  Case #PB_EventType_DragStart
                    grCED\bDragCue = #False
                    If WED_validateDisplayedItem()
                      nSourceItem = GGS(WED\tvwProdTree)
                      If nSourceItem > 0
                        ; not the root (prod) node
                        nNodeKey = GetGadgetItemData(WED\tvwProdTree, nSourceItem)
                        nCuePtr = WED_getCueIndexForNodeKey(nNodeKey)
                        If (nCuePtr > 0) And (nCuePtr <= gnLastCue)
                          grCED\nDragCueSourceItem = GetGadgetState(\tvwProdTree)
                          grCED\sDragSourceCue = aCue(nCuePtr)\sCue
                          grCED\bDragCue = #True
                        EndIf
                      EndIf ; EndIf nSourceItem > 0
                    EndIf ; EndIf WED_validateDisplayedItem()
                    If grCED\bDragCue
                      debugMsg(sProcName, "#PB_EventType_DragStart, grCED\nDragCueSourceItem=" + grCED\nDragCueSourceItem + ", grCED\sDragSourceCue=" + grCED\sDragSourceCue)
                      ; ------------------------------------------------------------------
                      ; the following code is based on an example in the PB Forum topic "Drag-n-Drop with image" posted by srod and modified by netmaestro
                      dragrow = GetGadgetState(EventGadget()) 
                      dragtxt.s = Space(4) + GetGadgetItemText(EventGadget(), dragrow) 
                      ; Debug "dragrow=" + dragrow + ", dragTxt=" + #DQUOTE$ + dragtxt + #DQUOTE$
                      draggadget = EventGadget() 
                      ;Create drag image window.
                      StartDrawing(WindowOutput(#WED))
                      DrawingFont(GetGadgetFont(draggadget))
                      width = TextWidth(dragtxt) : height = TextHeight(dragtxt)
                      StopDrawing()
                      oldgadgetlist = UseGadgetList(WindowID(#WED))
                      gDrag\winDrag  = OpenWindow(#PB_Any, 0, 0, width, height, "", #PB_Window_BorderLess|#PB_Window_Invisible)
                      gDrag\isHidden = #True
                      gDrag\wdwidth  = width
                      gDrag\wdheight = height
                      gDrag\wdfont   = GetGadgetFont(draggadget)
                      gDrag\wdimage  = CreateImage(#PB_Any, width,height,24)
                      gDrag\text     = dragtxt
                      
                      UseGadgetList(WindowID(gDrag\winDrag))
                      gDrag\wdig = ImageGadget(#PB_Any,0,0,width,height,0)
                      UseGadgetList(oldgadgetlist)
                      
                      ;We enable drops (mimicking our intended drop type) on this window so that the drag cursor behaves itself!
                      EnableWindowDrop(gDrag\winDrag, #PB_Drop_Private, #PB_Drag_Move) 
                      ; SetClassLongPtr_(WindowID(gDrag\winDrag), #GCL_HBRBACKGROUND, hBrush)
                      ;Instigate the drag.
                      SetDragCallback(@WED_DragCallBack())
                      DragPrivate(#SCS_PRIVTYPE_DRAG_CUE, #PB_Drag_Move)  ; nb doesn't continue until the user has released the mouse button, ie until the 'drop'
                      ;Now tidy up.
                      CloseWindow(gDrag\winDrag)
                      FreeImage(gDrag\wdimage)
                      ; ------------------------------------------------------------------
                    Else
                      debugMsg(sProcName, "#PB_EventType_DragStart ignored")
                      
                    EndIf ; EndIf/Else grCED\bDragCue
                    
                EndSelect
                
              Default
                ; debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo) + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
                
            EndSelect
          EndIf
          
        Else
          ; Added 5Jan2022 11.9ad following a test of the following:
          ; - Selected a lighting cue (didn't have to be a lighting cue)
          ; - Set user time field to an invalid value, eg 1.2.3, but did NOT tab out of the field
          ; - Clicked another node in tvwProdTree
          ; - SCS called the appropriate validation procedure (eg WQK_txtDIFadeUpUserTime_Validate()) but with nEditSubPtr set incorrectly to that of the NEW node clicked
          If gnEventType = #PB_EventType_LostFocus And gnValidateSubPtr >= 0
            WED_HoldOrRestoreEditPtrs(#True) ; moved the following to WED_HoldOrRestoreEditPtrs() 17Nov2023 11.10.0-b03 as we need the same processing elsewhere
;             nHoldEditCuePtr = nEditCuePtr
;             nHoldEditSubPtr = nEditSubPtr
;             nHoldEditAudPtr = nEditAudPtr
;             nEditSubPtr = gnValidateSubPtr
;             ; debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
;             nEditCuePtr = aSub(nEditSubPtr)\nCueIndex
;             bPtrsChanged = #True
          EndIf
          ; End added 5Jan2022 11.9ad
          Select nEditorComponent
            Case #WEP
              WEP__EventHandler()
            Case #WEC
              WEC_EventHandler()
            Case #WQA
              WQA_EventHandler()
            Case #WQE
              WQE_EventHandler()
            Case #WQF
              WQF_EventHandler()
            Case #WQG
              WQG_EventHandler()
            Case #WQI
              WQI_EventHandler()
            Case #WQJ
              WQJ_EventHandler()
            Case #WQK
              WQK__EventHandler()
            Case #WQL
              WQL_EventHandler()
            Case #WQM
              WQM_EventHandler()
            Case #WQP
              WQP_EventHandler()
            Case #WQQ
              WQQ_EventHandler()
            Case #WQR
              WQR_EventHandler()
            Case #WQS
              WQS_EventHandler()
            Case #WQT
              WQT_EventHandler()
            Case #WQU
              WQU_EventHandler()
          EndSelect
          ; Added 5Jan2022 11.9ad (see comments above)
          WED_HoldOrRestoreEditPtrs(#False) ; moved the following to WED_HoldOrRestoreEditPtrs() 17Nov2023 11.10.0-b03 as we need the same processing elsewhere
;           If bPtrsChanged
;             ; debugMsg(sProcName, "gbLastVALResult=" + strB(gbLastVALResult) + ", gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnFocusGadgetNo=" + getGadgetName(gnFocusGadgetNo))
;             nEditCuePtr = nHoldEditCuePtr
;             nEditSubPtr = nHoldEditSubPtr
;             ; debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
;             nEditAudPtr = nHoldEditAudPtr
;             bPtrsChanged = #False
;             ; NB the following not yet working properly, so tvwProdTree still has the 'new' node selected, not the node related to the error
;             If gbLastVALResult = #False
;               If IsGadget(WED\tvwProdTree)
;                 If gnValidateSubPtr >= 0
;                   nNodeKey = aSub(gnValidateSubPtr)\nNodeKey
;                   SGS(WED\tvwProdTree, -1)
;                   ; debugMsg(sProcName, "gnValidateSubPtr=" + getSubLabel(gnValidateSubPtr) + ", calling setGadgetItemByData(WED\tvwProdTree, " + nNodeKey + ")")
;                   setGadgetItemByData(WED\tvwProdTree, nNodeKey)
;                 EndIf
;               EndIf
;             EndIf
;           EndIf
          ; End added 5Jan2022 11.9ad
        EndIf
        
      Case #PB_Event_GadgetDrop
        debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnWindowEvent=" + decodeEvent(gnWindowEvent))
        Select gnEventGadgetNo
          Case \tvwProdTree
            Select EventDropType()
              Case #PB_Drop_Private
                If EventDropPrivate() = #SCS_PRIVTYPE_DRAG_CUE ; drag'n'drop a cue
                  WED_dragCue()
                EndIf
                
              Case #PB_Drop_Files ; drop files
                debugMsg(sProcName, "#PB_Event_GadgetDrop: (drop_files) GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree) + ", grCED\nSelectedItemForDragAndDrop=" + grCED\nSelectedItemForDragAndDrop)
                WED_tvwProdTree_DropFiles()
                
            EndSelect
            
          Default
            nEditorComponent = gaGadgetProps(gnEventGadgetPropsIndex)\nEditorComponent
            Select nEditorComponent
              Case #WQA
                WQA_EventHandler()
              Case #WQF
                WQF_EventHandler()
              Case #WQP
                WQP_EventHandler()
            EndSelect
        EndSelect
        
      Case #MyGrid_Event_DummyFirst To #MyGrid_Event_DummyLast
        ; Debug "gnEventGadgetPropsIndex=" + gnEventGadgetPropsIndex
        nEditorComponent = gaGadgetProps(gnEventGadgetPropsIndex)\nEditorComponent
        ; Debug "nEditorComponent=" + decodeEditorComponent(nEditorComponent)
        Select nEditorComponent
          Case #WQP
            WQP_EventHandler()
        EndSelect
        
      Case #PB_Event_Timer
        nEditorComponent = gaGadgetProps(gnEventGadgetPropsIndex)\nEditorComponent
        Select nEditorComponent
          Case #WEP
            ; debugMsg(sProcName, "#PB_Event_Timer calling WEP__EventHandler()")
            WEP__EventHandler()  ; will be test tone timer
          Case #WQK
            ; debugMsg(sProcName, "#PB_Event_Timer calling WQK__EventHandler()")
            WQK__EventHandler()  ; will be DMX capture timer
        EndSelect
        
      Case #PB_Event_SizeWindow
        ; debugMsg(sProcName, "WindowX(#WED)=" + WindowX(#WED) + ", WindowY(#WED)=" + WindowY(#WED) + ", WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
        debugMsg(sProcName, "#PB_Event_SizeWindow calling WED_Form_Resized()")
        WED_Form_Resized()
        
      Case #PB_Event_ActivateWindow
        ; debugMsg(sProcName, "#PB_Event_ActivateWindow")
        ; debugMsg(sProcName, "WindowX(#WED)=" + WindowX(#WED) + ", WindowY(#WED)=" + WindowY(#WED) + ", WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
        
      Case #PB_Event_MaximizeWindow
        ; debugMsg(sProcName, "WindowX(#WED)=" + WindowX(#WED) + ", WindowY(#WED)=" + WindowY(#WED) + ", WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
        debugMsg(sProcName, "#PB_Event_MaximizeWindow calling WED_Form_Resized()")
        WED_Form_Resized()
        
      Case #PB_Event_MoveWindow
        ; debugMsg0(sProcName, "calling WED_moveWindowEvent(), WindowX(#WED)=" + WindowX(#WED) + ", WindowY(#WED)=" + WindowY(#WED))
        WED_moveWindowEvent()
        
      Case #PB_Event_RestoreWindow
        debugMsg(sProcName, "#PB_Event_RestoreWindow calling WED_Form_Resized()")
        WED_Form_Resized()
        
      Case #PB_Event_Repaint
        ; do nothing
        
      Case #WM_MOUSEMOVE, #WM_MOUSELEAVE, #WM_NCMOUSEMOVE, #WM_NCMOUSELEAVE, #WM_TIMER
        ; do nothing
        
      Case #WM_LBUTTONUP
        ; debugMsg(sProcName, "#WM_LBUTTONUP")
        If gnValidateGadgetNo = 0
          bValidationResult = #True
        Else
          debugMsg(sProcName, "#WM_LBUTTONUP - calling commonValidation()")
          bValidationResult = commonValidation()
        EndIf
        If bValidationResult = #True
          nActiveGadgetNo = GetActiveGadget()
          Select nActiveGadgetNo
            ; Deleted WQM checks 1Jan2025 11.10.6cc
            ; Case WQM\cboMSChannel, WQM\cboMSMacro, WQM\cboMSParam1, WQM\cboMSParam2
            ;   WQM_process_cbo_click(nActiveGadgetNo)
            Case WQE\rchMemo
              WQE_EventHandler()
          EndSelect
        Else
          debugMsg(sProcName, "commonValidation() returned " + strB(bValidationResult) + ", gnValidateGadgetNo=" + getGadgetName(gnValidateGadgetNo))
        EndIf
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent) +", gnValidateGadgetNo=G" + gnValidateGadgetNo)
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WED_setWindowTitle()
  PROCNAMEC()
  Static sWindowTitle.s
  Static bStaticLoaded
  Protected sTitleOrName.s, sCaption.s
  
  If bStaticLoaded = #False
    sWindowTitle = Lang("WED", "Window")
    bStaticLoaded = #True
  EndIf
  
  With grProd
    If IsWindow(#WED)
      sCaption = sWindowTitle
      If \bTemplate
        sTitleOrName = \sTmName
      ElseIf \sTitle <> #SCS_UNTITLED
        sTitleOrName = \sTitle
      EndIf
      If sTitleOrName
        sCaption + " - " + #DQUOTE$ + Trim(sTitleOrName) + #DQUOTE$
      EndIf
      If \bTemplate
        sCaption + " - (" + grText\sTextTemplate + ")"
      EndIf
      ; debugMsg(sProcName, "gbDataChanged=" + strB(gbDataChanged) + ", gbUnsavedChanges=" + strB(gbUnsavedChanges))
      If gbDataChanged Or gbUnsavedChanges
        sCaption + " *"
      EndIf
      If GetWindowTitle(#WED) <> sCaption
        SetWindowTitle(#WED, sCaption)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WED_setKeyboardShortcuts(nWindowNo=#WED)
  PROCNAMEC()
  Protected n
  Protected bTrace = #cTraceKeyboardShortcuts
  
  debugMsgC(sProcName, #SCS_START)
  
  If IsWindow(nWindowNo)
    ; start by removing all shortcuts
    ; RemoveKeyboardShortcut(nWindowNo, #PB_Shortcut_All)
    For n = 0 To ArraySize(gaShortcutsEditor())
      With gaShortcutsEditor(n)
        If \nCurrShortcut
          RemoveKeyboardShortcut(nWindowNo, \nCurrShortcut)
          debugMsgC(sProcName, "RemoveKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nCurrShortcut) + ")")
          \nCurrShortcut = 0
        EndIf
      EndWith
    Next n
    For n = 0 To ArraySize(gaShortcutsEditor())
      With gaShortcutsEditor(n)
        If \nShortcut
          AddKeyboardShortcut(nWindowNo, \nShortcut, \nShortcutFunction)
          debugMsgC(sProcName, "AddKeyboardShortcut(" + decodeWindow(nWindowNo) + ", " + decodeShortcut(\nShortcut) + ", " + decodeMenuItem(\nShortcutFunction) + ") " + \sFunctionDescr)
          \nCurrShortcut = \nShortcut
        EndIf
      EndWith
    Next n
    
    ; AddKeyboardShortcut(#WED, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    ; 23Jun2015 11.4.0: commented out the above having decided it's not a good idea to close the editor window if the user presses Esc
    
    ; AddKeyboardShortcut(#WED, #PB_Shortcut_Control|#PB_Shortcut_A, #SCS_mnuKeyboardCtrlA)
    ; AddKeyboardShortcut(#WED, #PB_Shortcut_Control|#PB_Shortcut_C, #SCS_mnuKeyboardCtrlC)
    ; AddKeyboardShortcut(#WED, #PB_Shortcut_Tab, #SCS_mnuKeyboardTab)
    
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WED_redrawTVGGadgets()
  repositionTVGDisplay(WEP\cvsTestVidCap, #SCS_VID_PIC_TARGET_TEST)
  repositionTVGDisplay(WQA\cntPreview, #SCS_VID_PIC_TARGET_P)
EndProcedure

Procedure WED_moveWindowEvent()
  PROCNAMEC()
  Protected nWindowX, nWindowY
  Static nPrevWindowX, nPrevWindowY
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; Added 31Oct2024 11.10.6ba because it appears that theevent #PB_Event_WindowMove is called multiple times, and only at the end of the move.
  ; Note sure why this happens in SCS as in a test program the event is called just once, but also at the end of the move.
  nWindowX = WindowX(#WED)
  nWindowY = WindowY(#WED)
  If nWindowX = nPrevWindowX And nWindowY = nPrevWindowY And nWindowX <> 0
    ; Window has NOT moved since last call to this procedure
    ProcedureReturn
  EndIf
  nPrevWindowX = nWindowX
  nPrevWindowY = nWindowY
  ; End added 31Oct2024 11.10.6ba
  
  CompilerIf #c_include_tvg
    ; Repositioning the TVG display(s) was moved to a SAM request with a 500ms delay to reduce the likelihood of this being called repetitively when the editor window is moved.
    ; This change was applied 5Feb2022 11.9.0 in response to an email from CPeters 4Feb2022 about the movement being sluggish. Don't know why, but hopefully this change will help.
    ; NB The SAM request #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS is in the range where only the LATEST unprocessed request is kept.
    If IsGadget(WEP\cvsTestVidCap) Or IsGadget(WQA\cntPreview)
      samAddRequest(#SCS_SAM_REDRAW_EDITOR_TVG_GADGETS, 0, 0, 0, "", ElapsedMilliseconds()+500)
    EndIf
  CompilerEndIf
  
EndProcedure

Procedure WED_displayTemplateInfoIfReqd(bForce=#False, bEnableFlicker=#False)
  PROCNAMEC()
  Protected nProdTreeHeight
  Protected sTemplateText.s
  
  With WED
    If grProd\bTemplate
      If (grWED\bTemplateInfoSet = #False) Or (getVisible(\cntTemplate) = #False) Or (bForce)
        sTemplateText = LangPars("WMN", "lblTemplateInfo", #DQUOTE$ + grProd\sTmName + #DQUOTE$)  ; nb use text of corresponding WMN lblTemplateInfo
        SGT(\lblTemplateInfo, sTemplateText)
        scsSetGadgetFont(\lblTemplateInfo, #SCS_FONT_WMN_ITALIC)
        setVisible(\cntTemplate, #True)
        If IsGadget(WEP\lblTemplateInfo)
          SGT(WEP\lblTemplateInfo, sTemplateText)
          scsSetGadgetFont(WEP\lblTemplateInfo, #SCS_FONT_WMN_ITALIC)
        EndIf
        grWED\bTemplateInfoSet = #True
        If bEnableFlicker
          grWED\nFlickerCount = -1
          grWED\bFlickerTemplateInfo = #True
        EndIf
      EndIf
      nProdTreeHeight = GadgetY(\cntTemplate) - GadgetY(\tvwProdTree)
    Else
      setVisible(\cntTemplate, #False)
      nProdTreeHeight = GadgetY(\lblClipboardInfo) - GadgetY(\tvwProdTree)
      grWED\bFlickerTemplateInfo = #False
    EndIf
    If GadgetHeight(\tvwProdTree) <> nProdTreeHeight
      debugMsg(sProcName, "calling ResizeGadget(\tvwProdTree, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nProdTreeHeight + ")")
      ResizeGadget(\tvwProdTree, #PB_Ignore, #PB_Ignore, #PB_Ignore, nProdTreeHeight)
    EndIf
  EndWith
  
EndProcedure

Procedure WED_flickerTemplateInfo()
  Static nOriginalBackColor, nAltBackColor
  Static bStaticLoaded
  Static qLastFlickerTime.q
  Protected nThisBackColor, qTimeNow.q
  Protected bDoFlicker
  
  With WED
    If IsGadget(\cntTemplate)
      If bStaticLoaded = #False
        nOriginalBackColor = GetGadgetColor(\cntTemplate, #PB_Gadget_BackColor) ; = RGB(0,102,204)
        nAltBackColor = RGB(0,150,244)
        bStaticLoaded = #True
      EndIf
      If grWED\nFlickerCount < 0
        qLastFlickerTime = ElapsedMilliseconds()
        grWED\nFlickerCount = 0
      Else
        qTimeNow = ElapsedMilliseconds()
        If (qTimeNow - qLastFlickerTime) > 500    ; flicker every .5 second
          If grWED\nFlickerCount >= 10
            ; stop flickering after 5 seconds (10 * 0.5 second)
            grWED\bFlickerTemplateInfo = #False
            nThisBackColor = nOriginalBackColor
          Else
            grWED\nFlickerCount + 1
            qLastFlickerTime = qTimeNow
            If grWED\nFlickerCount & 1
              nThisBackColor = nAltBackColor
            Else
              nThisBackColor = nOriginalBackColor
            EndIf
          EndIf
          SetGadgetColor(\cntTemplate, #PB_Gadget_BackColor, nThisBackColor)
          SetGadgetColor(\lblTemplateInfo, #PB_Gadget_BackColor, nThisBackColor)
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Macro WED_macAddCueMenuItemToArray(pCueType, pMenuItemNo, pFavMenuItemNo, pName, pImageNo)
  nMaxCueMenuItem + 1
  aCueMenuItem(nMaxCueMenuItem)\sCueType = pCueType
  aCueMenuItem(nMaxCueMenuItem)\nMenuItemNo = pMenuItemNo
  aCueMenuItem(nMaxCueMenuItem)\nFavMenuItemNo = pFavMenuItemNo
  aCueMenuItem(nMaxCueMenuItem)\sMenuItemText = Lang("Menu", pName)
  aCueMenuItem(nMaxCueMenuItem)\nImageNo = pImageNo
EndMacro

Macro WED_macAddSubMenuItemToArray(pCueType, pMenuItemNo, pFavMenuItemNo, pName, pImageNo)
  nMaxSubMenuItem + 1
  aSubMenuItem(nMaxSubMenuItem)\sCueType = pCueType
  aSubMenuItem(nMaxSubMenuItem)\nMenuItemNo = pMenuItemNo
  aSubMenuItem(nMaxSubMenuItem)\nFavMenuItemNo = pFavMenuItemNo
  aSubMenuItem(nMaxSubMenuItem)\sMenuItemText = Lang("Menu", pName)
  aSubMenuItem(nMaxSubMenuItem)\nImageNo = pImageNo
EndMacro

Procedure WED_buildEditorMenus()
  PROCNAMEC()
  Protected sMenuText.s
  Structure tyMenuItem
    sMenuItemText.s ; will be used as the sort key
    sCueType.s
    nMenuItemNo.i
    nFavMenuItemNo.i
    nImageNo.i
  EndStructure
  Protected Dim aCueMenuItem.tyMenuItem(20) ; at least as large as the number of cue types
  Protected Dim aSubMenuItem.tyMenuItem(20) ; at least as large as the number of sub-cue types
  Protected nMaxCueMenuItem, nMaxSubMenuItem, n
  
  debugMsg(sProcName, #SCS_START)
  
  ; NOTE: Populate and sort the cue type / sub-cue type arrays so that the menu items can be displayed in alphabetical order, regardless of language
  
  nMaxCueMenuItem = -1
  nMaxSubMenuItem = -1
  ; cue types available in all license levels
  WED_macAddCueMenuItemToArray("F", #WED_mnuAddQF, #WED_mnuFavAddQF, "mnuAddQF", hClAudio)
  WED_macAddSubMenuItemToArray("F", #WED_mnuAddSF, #WED_mnuFavAddSF, "mnuAddSF", hClAudio)
  WED_macAddCueMenuItemToArray("S", #WED_mnuAddQS, #WED_mnuFavAddQS, "mnuAddQS", hClSFR)
  WED_macAddSubMenuItemToArray("S", #WED_mnuAddSS, #WED_mnuFavAddSS, "mnuAddSS", hClSFR)
  
  ; cue types available in professional and higher levels
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    WED_macAddCueMenuItemToArray("E", #WED_mnuAddQE, #WED_mnuFavAddQE, "mnuAddQE", hClMemo)
    WED_macAddSubMenuItemToArray("E", #WED_mnuAddSE, #WED_mnuFavAddSE, "mnuAddSE", hClMemo)
    WED_macAddCueMenuItemToArray("G", #WED_mnuAddQG, #WED_mnuFavAddQG, "mnuAddQG", hClGoToCue)
    WED_macAddSubMenuItemToArray("G", #WED_mnuAddSG, #WED_mnuFavAddSG, "mnuAddSG", hClGoToCue)
    WED_macAddCueMenuItemToArray("I", #WED_mnuAddQI, #WED_mnuFavAddQI, "mnuAddQI", hClLiveInput)
    WED_macAddSubMenuItemToArray("I", #WED_mnuAddSI, #WED_mnuFavAddSI, "mnuAddSI", hClLiveInput)
    WED_macAddCueMenuItemToArray("J", #WED_mnuAddQJ, 0, "mnuAddQJ", hClEnaDis) ; not included in Favorites
    WED_macAddSubMenuItemToArray("J", #WED_mnuAddSJ, 0, "mnuAddSJ", hClEnaDis) ; not included in Favorites
    WED_macAddCueMenuItemToArray("K", #WED_mnuAddQK, #WED_mnuFavAddQK, "mnuAddQK", hClLighting)
    WED_macAddSubMenuItemToArray("K", #WED_mnuAddSK, #WED_mnuFavAddSK, "mnuAddSK", hClLighting)
    WED_macAddCueMenuItemToArray("M", #WED_mnuAddQM, #WED_mnuFavAddQM, "mnuAddQM", hClCtrlSend)
    WED_macAddSubMenuItemToArray("M", #WED_mnuAddSM, #WED_mnuFavAddSM, "mnuAddSM", hClCtrlSend)
    WED_macAddCueMenuItemToArray("Q", #WED_mnuAddQQ, #WED_mnuFavAddQQ, "mnuAddQQ", hClCallCue)
    WED_macAddSubMenuItemToArray("Q", #WED_mnuAddSQ, #WED_mnuFavAddSQ, "mnuAddSQ", hClCallCue)
    WED_macAddCueMenuItemToArray("R", #WED_mnuAddQR, #WED_mnuFavAddQR, "mnuAddQR", hClRun)
    WED_macAddSubMenuItemToArray("R", #WED_mnuAddSR, #WED_mnuFavAddSR, "mnuAddSR", hClRun)
    WED_macAddCueMenuItemToArray("T", #WED_mnuAddQT, #WED_mnuFavAddQT, "mnuAddQT", hClSetPos)
    WED_macAddSubMenuItemToArray("T", #WED_mnuAddST, #WED_mnuFavAddST, "mnuAddST", hClSetPos)
    WED_macAddCueMenuItemToArray("U", #WED_mnuAddQU, #WED_mnuFavAddQU, "mnuAddQU", hClMTC)
    WED_macAddSubMenuItemToArray("U", #WED_mnuAddSU, #WED_mnuFavAddSU, "mnuAddSU", hClMTC)
  EndIf
  
  ; cue types available in standard and higher levels
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    WED_macAddCueMenuItemToArray("A", #WED_mnuAddQA, #WED_mnuFavAddQA, "mnuAddQA", hClVideo)
    WED_macAddSubMenuItemToArray("A", #WED_mnuAddSA, #WED_mnuFavAddSA, "mnuAddSA", hClVideo)
    WED_macAddCueMenuItemToArray("L", #WED_mnuAddQL, #WED_mnuFavAddQL, "mnuAddQL", hClLvlChg)
    WED_macAddSubMenuItemToArray("L", #WED_mnuAddSL, #WED_mnuFavAddSL, "mnuAddSL", hClLvlChg)
    WED_macAddCueMenuItemToArray("N", #WED_mnuAddQN, #WED_mnuFavAddQN, "mnuAddQN", hClNote)
    WED_macAddCueMenuItemToArray("P", #WED_mnuAddQP, #WED_mnuFavAddQP, "mnuAddQP", hClPlaylist)
    WED_macAddSubMenuItemToArray("P", #WED_mnuAddSP, #WED_mnuFavAddSP, "mnuAddSP", hClPlaylist)
  EndIf
  
  SortStructuredArray(aCueMenuItem(), #PB_Sort_Ascending, OffsetOf(tyMenuItem\sMenuItemText), #PB_String, 0, nMaxCueMenuItem)
  SortStructuredArray(aSubMenuItem(), #PB_Sort_Ascending, OffsetOf(tyMenuItem\sMenuItemText), #PB_String, 0, nMaxSubMenuItem)
  
  ; popup menu on Other Actions button
  If scsCreatePopupImageMenu(#WED_mnuOtherActions, #PB_Menu_ModernLook)
    scsMenuItem(#WED_mnuSaveAs, "mnuSaveAs", "*E")
    MenuBar()
    scsMenuItem(#WED_mnuPrint, "mnuPrint", "*E")
    MenuBar()
    scsMenuItem(#WED_mnuOptions, "mnuOptions", "*E")
  EndIf
  
  ; popup menu on Production button
  If scsCreatePopupImageMenu(#WED_mnuProdMenu, #PB_Menu_ModernLook)
    scsMenuItem(#WED_mnuProdProperties, "mnuProdProperties", "*E", #True, hClProd)
    MenuBar()
    scsMenuItem(#WED_mnuCollect, "mnuCollect", "*E")
    If grLicInfo\bImportDevsAvailable
      MenuBar()
      scsMenuItem(#WED_mnuImportDevs, "mnuImportDevs", "*E")
    EndIf
    If grLicInfo\bProductionTimerAvailable
      MenuBar()
      scsMenuItem(#WED_mnuProdTimer, "mnuProdTimer", "*E")
    EndIf
  EndIf
  
  ; popup menu on Cues button
  If scsCreatePopupImageMenu(#WED_mnuCuesMenu, #PB_Menu_ModernLook)
    For n = 0 To nMaxCueMenuItem
      scsCueTypeMenuItem(aCueMenuItem(n)\sCueType, aCueMenuItem(n)\nMenuItemNo, aCueMenuItem(n)\sMenuItemText, "*E", #False, aCueMenuItem(n)\nImageNo)
    Next n
    MenuBar()
    scsMenuItem(#WED_mnuRenumberCues, "mnuRenumberCues", "*E")
    scsMenuItem(#WED_mnuBulkEditCues, "mnuBulkEditCues", "*E")
    scsMenuItem(#WED_mnuMultiCueCopyEtc, LangWithAlt("Menu", "mnuMultiCueCopyEtc2", "mnuMultiCueCopyEtc"), "*E", #False)
    scsMenuItem(#WED_mnuCopyProps, "mnuCopyProps", "*E")
    MenuBar()
    scsMenuItem(#WED_mnuImportCues, "mnuImportCues", "*E")
    If grLicInfo\bImportCSVAvailable
      scsMenuItem(#WED_mnuImportCSV, "mnuImportCSV", "*E")
    EndIf
    scsMenuItem(#WED_mnuExportCues, "mnuExportCues", "*E")
  EndIf
  
  ; popup menu on Sub-Cues button
  If scsCreatePopupImageMenu(#WED_mnuSubsMenu, #PB_Menu_ModernLook)
    For n = 0 To nMaxSubMenuItem
      scsCueTypeMenuItem(aSubMenuItem(n)\sCueType, aSubMenuItem(n)\nMenuItemNo, aSubMenuItem(n)\sMenuItemText, "*E", #False, aSubMenuItem(n)\nImageNo)
    Next n
  EndIf
  
  ; popup menu for right-click on cue list (tree gadget)
  If scsCreatePopupImageMenu(#WED_mnuCueListPopupMenu, #PB_Menu_ModernLook)
    scsMenuItemFast(#WED_mnuCut, grText\sTextCut, gaShortcutsEditor(#SCS_ShortEditor_Cut)\sShortcutStr, hSbCutEn)
    scsMenuItemFast(#WED_mnuCopy, grText\sTextCopy, gaShortcutsEditor(#SCS_ShortEditor_Copy)\sShortcutStr, hSbCopyEn)
    scsMenuItemFast(#WED_mnuPaste, grText\sTextPaste, gaShortcutsEditor(#SCS_ShortEditor_Paste)\sShortcutStr, hSbPasteEn)
    scsMenuItemFast(#WED_mnuDelete, grText\sTextDelete, "", hSbDeleteEn)
    ; nb the above menu items will have their text and shortcuts re-populated dynamically in WED_setTBSButtons()
    MenuBar()
    scsMenuItem(#WED_mnuCopyProps, "mnuCopyProps", "*E")
    If grLicInfo\bImportDevsAvailable
      MenuBar()
      scsMenuItem(#WED_mnuImportDevs, "mnuImportDevs", "*E")
    EndIf
    MenuBar()
    OpenSubMenu(Lang("Menu", "mnuAddCue"))
    For n = 0 To nMaxCueMenuItem
      scsCueTypeMenuItem(aCueMenuItem(n)\sCueType, aCueMenuItem(n)\nMenuItemNo, aCueMenuItem(n)\sMenuItemText, "*E", #False, aCueMenuItem(n)\nImageNo)
    Next n
    CloseSubMenu()
    MenuBar()
    OpenSubMenu(Lang("Menu", "mnuProdImportExport", "*E"))
      scsMenuItem(#WED_mnuImportCues, "mnuImportCues", "*E")
      If grLicInfo\bImportCSVAvailable
        scsMenuItem(#WED_mnuImportCSV, "mnuImportCSV")
      EndIf
      scsMenuItem(#WED_mnuExportCues, "mnuExportCues", "*E")
    CloseSubMenu()
    MenuBar()
    OpenSubMenu(Lang("Menu", "mnuAddSubCue"))
      For n = 0 To nMaxSubMenuItem
        scsCueTypeMenuItem(aSubMenuItem(n)\sCueType, aSubMenuItem(n)\nMenuItemNo, aSubMenuItem(n)\sMenuItemText, "*E", #False, aSubMenuItem(n)\nImageNo)
      Next n
    CloseSubMenu()
    If grLicInfo\bTempoAndPitchAvailable
      MenuBar()
      sMenuText = LangEllipsis("Menu", "mnuWQFChangeFreqTempoPitch")
      scsMenuItem(#WQF_mnu_ChangeFreqTempoPitch, sMenuText, "*E", #False)
    EndIf
  EndIf
  
  ; popup menu on Favorites category
  If scsCreatePopupMenu(#WED_mnuFavsMenu)
    scsMenuItem(#WED_mnuFavsInfo, "mnuFavsInfo")
    DisableMenuItem(#WED_mnuFavsMenu, #WED_mnuFavsInfo, #True)
    MenuBar()
    For n = 0 To nMaxCueMenuItem
      If aCueMenuItem(n)\nFavMenuItemNo <> 0
        scsCueTypeMenuItem(aCueMenuItem(n)\sCueType, aCueMenuItem(n)\nFavMenuItemNo, aCueMenuItem(n)\sMenuItemText, "", #False)
      EndIf
    Next n
    MenuBar()
    For n = 0 To nMaxSubMenuItem
      If aSubMenuItem(n)\nFavMenuItemNo <> 0
        scsCueTypeMenuItem(aSubMenuItem(n)\sCueType, aSubMenuItem(n)\nFavMenuItemNo, aSubMenuItem(n)\sMenuItemText, "", #False)
      EndIf
    Next n
  EndIf
  
EndProcedure

Procedure WED_dragCue()
  PROCNAMEC()
  Protected u
  Protected nCueToMove, nTargetCuePtr, nNodeKeyOfCueToMove, nNodeKeyOfTargetCue
  Protected sCue.s, sUndoDescr.s, nNewCuePtr
  
  grCED\nDragCueTargetItem = GetGadgetState(WED\tvwProdTree)
  debugMsg(sProcName, "grCED\nDragCueSourceItem=" + grCED\nDragCueSourceItem + ", grCED\nDragCueTargetItem=" + grCED\nDragCueTargetItem)
  ; nothing to do if source and target are equal
  If grCED\nDragCueSourceItem <> grCED\nDragCueTargetItem
    ; INFO DRAG CUE
    nNodeKeyOfCueToMove = GetGadgetItemData(WED\tvwProdTree, grCED\nDragCueSourceItem)
    nCueToMove = getCuePtrForNodeKey(nNodeKeyOfCueToMove)
    nNodeKeyOfTargetCue = GetGadgetItemData(WED\tvwProdTree, grCED\nDragCueTargetItem)
    nTargetCuePtr = getCuePtrForNodeKey(nNodeKeyOfTargetCue)
    If nTargetCuePtr < 1
      If nNodeKeyOfTargetCue = grProd\nNodeKey ; target is production properties node
        nTargetCuePtr = 0
      EndIf
    EndIf
    If nTargetCuePtr >= 0
      sCue = aCue(nCueToMove)\sCue
      sUndoDescr = Lang("WED", "DragCue")
      u = preChangeCueL(#True, sUndoDescr, nCueToMove, #SCS_UNDO_ACTION_DRAG_CUE, -1, #SCS_UNDO_FLAG_REDO_TREE, 0, nTargetCuePtr)
      moveCue(nCueToMove, nTargetCuePtr)
      nNewCuePtr = getCuePtr(sCue)
      postChangeCueL(u, #False, nNewCuePtr)
      redoCueListTree(nNodeKeyOfCueToMove)
    EndIf
  EndIf
  grCED\bDragCue = #False
EndProcedure

Procedure WED_DragCallback(nAction.l)
  PROCNAMEC()
  ; dragcallback for drag-and-drop a cue
  ; this procedure is based on an example in the PB Forum topic "Drag-n-Drop with image" posted by srod and modified by netmaestro
  Protected pt.point, rc.RECT, top, target, hdcin, hdcout, mappedpt.POINT
  
  GetCursorPos_(pt)
  GetWindowRect_(GadgetID(WED\tvwProdTree), rc)
  If PtInRect_(rc, pt\x + pt\y<<32)
    If gDrag\isHidden
      HideWindow(gDrag\winDrag, 0)
      gDrag\isHidden=#False
    EndIf
    target = WindowFromPoint_(pt\x|(pt\y<<32))
    hdcin = GetDC_(target)
    hdcout = StartDrawing(ImageOutput(gDrag\wdimage))
    mappedpt.POINT = pt
    ScreenToClient_(target, mappedpt)
    BitBlt_(hdcout,0,0,gDrag\wdwidth,gDrag\wdheight,hdcin,mappedpt\x+1,mappedpt\y,#SRCCOPY)
    ReleaseDC_(target,hdcin)
    DrawingFont(gDrag\wdfont)
    ; DrawingMode(#PB_2DDrawing_Transparent)
    ; DrawText(0,0,gDrag\text, #Black)
    DrawingMode(#PB_2DDrawing_Default)
    DrawText(0,0,gDrag\text,#White,#Black)
    StopDrawing()
    SetGadgetState(gDrag\wdig, ImageID(gDrag\wdimage))
    ResizeWindow(gDrag\winDrag, pt\x+1, pt\y, #PB_Ignore, #PB_Ignore)
  Else
    If gDrag\isHidden = #False
      HideWindow(gDrag\winDrag, 1)
      gDrag\isHidden=#True
    EndIf
  EndIf
  ProcedureReturn #True
  
EndProcedure

Procedure WED_DropCallback(TargetHandle, State, Format, Action, X, Y)
  PROCNAMEC()
  ; WARNING! only one DropCallBack procedure may be active, which is why TargetHandle is provided
  Protected nIdWEDProdTree, nIdWQATimeLine, nIdWQPFiles
  ; fields for WED\tvwProdTree drop callback
  Static sClipboardInfo.s
  ; fields for WQA\scaTimeLine drop callback
  Protected nItemX, nTimeLineX, nInnerX
  Protected nScrollAreaX, nItemNo
  ; fields for WQP\scaFiles
  Protected nLineY, nFilesY
  Protected nScrollAreaY, nFirstVisibleRowNo, nVisibleRowNo, nActualRowNo

  nIdWEDProdTree = GadgetID(WED\tvwProdTree)
  If IsGadget(WQA\scaTimeLine)
    nIdWQATimeLine = GadgetID(WQA\scaTimeLine)
  EndIf
  If IsGadget(WQP\scaFiles)
    nIdWQPFiles = GadgetID(WQP\scaFiles)
  EndIf
  
  Select TargetHandle
    Case nIdWEDProdTree ; WED\tvwProdTree ------------------------------------------------------------------
      ; debugMsg(sProcName, "WED\tvwProdTree, State=" + decodeDragAndDropState(State) + ", X=" + X + ", Y=" + Y)
      Select State
        Case #PB_Drag_Enter
          debugMsg(sProcName, "#PB_Drag_Enter: GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree))
          sClipboardInfo = GGT(WED\lblClipboardInfo)
          If grCED\bDragCue
            SGT(WED\lblClipboardInfo, LangPars("CED", "MoveCueInfo", grCED\sDragSourceCue))
          Else
            SGT(WED\lblClipboardInfo, Lang("CED", "DropInfo"))
          EndIf
          scsSetGadgetFont(WED\lblClipboardInfo, #SCS_FONT_GEN_BOLD)
        Case #PB_Drag_Update
          ; no action
        Case #PB_Drag_Leave
          SGT(WED\lblClipboardInfo, sClipboardInfo)
          scsSetGadgetFont(WED\lblClipboardInfo, #SCS_FONT_GEN_NORMAL)
        Case #PB_Drag_Finish
          debugMsg(sProcName, "#PB_Drag_Finish: GGS(WED\tvwProdTree)=" + GGS(WED\tvwProdTree))
          grCED\nSelectedItemForDragAndDrop = GGS(WED\tvwProdTree)     ; hold selected item on entering - will be used if no item selected on dropping (see WED_tvwProdTree_DropFiles())
          SGT(WED\lblClipboardInfo, sClipboardInfo)
          scsSetGadgetFont(WED\lblClipboardInfo, #SCS_FONT_GEN_NORMAL)
      EndSelect
      
    Case nIdWQATimeLine ; WQA\scaTimeLine ------------------------------------------------------------------
      nTimeLineX = GadgetX(WQA\scaTimeLine)
      nScrollAreaX = GetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X)
      nInnerX = nScrollAreaX + X
      nItemNo = Round(nInnerX / #SCS_QAITEM_WIDTH, #PB_Round_Nearest)
      If nItemNo > aSub(nEditSubPtr)\nAudCount
        nItemNo = aSub(nEditSubPtr)\nAudCount
      EndIf
      nItemX = (nItemNo * #SCS_QAITEM_WIDTH) - nScrollAreaX
      ; debugMsg(sProcName, "X=" + X + ", nScrollAreaX=" + Str(nScrollAreaX) + ", nInnerX=" + Str(nInnerX) + ", nItemNo=" + Str(nItemNo) + ", nItemX=" + Str(nItemX))
      
      Select State
        Case #PB_Drag_Enter
          ; debugMsg(sProcName, "State=#PB_Drag_Enter, X=" + X + ", Y=" + Y + ", nItemX=" + Str(nItemX))
          ResizeGadget(WQA\lnDropMarker, nTimeLineX + nItemX, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          setVisible(WQA\lnDropMarker, #True)
          
        Case #PB_Drag_Update
          ; debugMsg(sProcName, "State=#PB_Drag_Update, X=" + X + ", Y=" + Y + ", nItemX=" + Str(nItemX))
          ResizeGadget(WQA\lnDropMarker, nTimeLineX + nItemX, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          
        Case #PB_Drag_Leave
          ; debugMsg(sProcName, "State=#PB_Drag_Leave, X=" + X + ", Y=" + Y)
          setVisible(WQA\lnDropMarker, #False)
          
        Case #PB_Drag_Finish
          ; debugMsg(sProcName, "State=#PB_Drag_Finish, X=" + X + ", Y=" + Y)
          setVisible(WQA\lnDropMarker, #False)
          
      EndSelect
      
      
    Case nIdWQPFiles ; WQP\scaFiles ------------------------------------------------------------------
      nFilesY = GadgetY(WQP\scaFiles)
      nScrollAreaY = GetGadgetAttribute(WQP\scaFiles, #PB_ScrollArea_Y)
      nFirstVisibleRowNo = Round(nScrollAreaY / (21), #PB_Round_Nearest)
      nVisibleRowNo = Round(Y / (21), #PB_Round_Nearest)
      nActualRowNo = nFirstVisibleRowNo + nVisibleRowNo
      If nActualRowNo > aSub(nEditSubPtr)\nAudCount
        nVisibleRowNo = aSub(nEditSubPtr)\nAudCount - nFirstVisibleRowNo
        If nVisibleRowNo < 0
          nVisibleRowNo = 0
        EndIf
      EndIf
      nLineY = nVisibleRowNo * 21
      
      Select State
        Case #PB_Drag_Enter
          ; debugMsg(sProcName, "State=#PB_Drag_Enter, X=" + X + ", Y=" + Y + ", nLineY=" + Str(nLineY))
          ResizeGadget(WQP\lnDropMarker, #PB_Ignore, nFilesY + nLineY, #PB_Ignore, #PB_Ignore)
          setVisible(WQP\lnDropMarker, #True)
          
        Case #PB_Drag_Update
          ; debugMsg(sProcName, "State=#PB_Drag_Update, X=" + X + ", Y=" + Y + ", nLineY=" + Str(nLineY))
          ResizeGadget(WQP\lnDropMarker, #PB_Ignore, nFilesY + nLineY, #PB_Ignore, #PB_Ignore)
          
        Case #PB_Drag_Leave
          ; debugMsg(sProcName, "State=#PB_Drag_Leave, X=" + X + ", Y=" + Y)
          setVisible(WQP\lnDropMarker, #False)
          
        Case #PB_Drag_Finish
          ; debugMsg(sProcName, "State=#PB_Drag_Finish, X=" + X + ", Y=" + Y)
          setVisible(WQP\lnDropMarker, #False)
          
      EndSelect

  EndSelect
  ProcedureReturn #True
EndProcedure

Procedure WED_getProdTreeStateForNode(nNodeKey)
  PROCNAMEC()
  Protected n, nSelectedItem = -1
  
  For n = 0 To CountGadgetItems(WED\tvwProdTree)-1
    ; debugMsg(sProcName,"GetGadgetItemData(G" + WED\tvwProdTree + ", " + n + ")=" + GetGadgetItemData(WED\tvwProdTree, n))
    If GetGadgetItemData(WED\tvwProdTree, n) = nNodeKey
      nSelectedItem = n
      Break
    EndIf
  Next n
  
  ProcedureReturn nSelectedItem
EndProcedure

Procedure WED_setCueNodeExpandedBooleanFromTreeItemStates()
  PROCNAMEC()
  ; sets aCue()\bNodeExpanded True for all cue nodes currently expanded; False for cue nodes not expanded
  ; does not check item 0 as that is the production properties node
  Protected n, nNodeKey, nCuePtr
  
  For nCuePtr = 1 To gnLastCue
    aCue(nCuePtr)\bNodeExpanded = #False
  Next nCuePtr
  
  For n = 1 To CountGadgetItems(WED\tvwProdTree)
    If GetGadgetItemState(WED\tvwProdTree, n) = #PB_Tree_Expanded
      nNodeKey = GetGadgetItemData(WED\tvwProdTree, n)
      nCuePtr = WED_getCueIndexForNodeKey(nNodeKey)
      If nCuePtr >= 0
        aCue(nCuePtr)\bNodeExpanded = #True
      EndIf
    EndIf
  Next n
  
EndProcedure

Procedure WED_checkVideoPlaybackLibrary()
  PROCNAMEC()
  Protected bResult, nvMixInitResult
  
  bResult = #True
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      If grvMixControl\bvMixInitDone = #False
        nvMixInitResult = vMix_Init()
        If nvMixInitResult <> 0
          bResult = #False
        EndIf
      ElseIf grvMixInfo\bvMixEditionNotSupported
        bResult = #False
      EndIf
    EndIf
  CompilerEndIf
  
  ProcedureReturn bResult
EndProcedure

Procedure WED_setEditorCueListFontSize()
  PROCNAMEC()
  ; See also savePreferences() and WOP_Form_Show()
  Protected nEditorCueListFontSize, nReqdFont

  ; debugMsg(sProcName, #SCS_START)
  
  If gbInOptionsWindow
    nEditorCueListFontSize = mrEditingOptions\nEditorCueListFontSize
  Else
    nEditorCueListFontSize = grEditingOptions\nEditorCueListFontSize
  EndIf
  
  Select nEditorCueListFontSize
    Case 109
      nReqdFont = #SCS_FONT_GEN_NORMAL9
    Case 9
      nReqdFont = #SCS_FONT_GEN_BOLD9
    Case 110
      nReqdFont = #SCS_FONT_GEN_NORMAL10
    Case 10
      nReqdFont = #SCS_FONT_GEN_BOLD10
    Case 111
      nReqdFont = #SCS_FONT_GEN_NORMAL11
    Case 11
      nReqdFont = #SCS_FONT_GEN_BOLD11
    Case 112
      nReqdFont = #SCS_FONT_GEN_NORMAL12
    Case 12
      nReqdFont = #SCS_FONT_GEN_BOLD12
    Default
      nReqdFont = #SCS_FONT_GEN_NORMAL9
  EndSelect
  
  scsSetGadgetFont(WED\tvwProdTree, nReqdFont)
  
EndProcedure

Procedure WED_EnableDisableMenuItems()
  PROCNAMECS(nEditSubPtr)
  Protected bDisable
  
  ; debugMsg(sProcName, #SCS_START)
  
  bDisable = #True
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If grLicInfo\bTempoAndPitchAvailable
        If \bSubTypeF And \bSubPlaceHolder = #False
          bDisable = #False
;         Else
;           bDisable = #True
        EndIf
;         DisableMenuItem(#WED_mnuCueListPopupMenu, #WQF_mnu_ChangeFreqTempoPitch, bDisable)
      EndIf
    EndWith
  EndIf
  DisableMenuItem(#WED_mnuCueListPopupMenu, #WQF_mnu_ChangeFreqTempoPitch, bDisable)
  
EndProcedure

; EOF