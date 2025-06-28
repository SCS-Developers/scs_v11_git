; File: fmFavFiles.pbi

EnableExplicit

Procedure WFF_applyChanges()
  PROCNAMEC()
  Protected n
  
  gnFavFileCount = 0
  For n = 0 To #SCS_MAX_FAV_FILE
    gaFavoriteFiles(n) = grWFF\maFavoriteFiles[n]
    If gaFavoriteFiles(n)\sFileName
      gnFavFileCount = n + 1
    EndIf
  Next n
  WMN_setKeyboardShortcuts()
  savePreferencesForFavFiles()
  grWFF\bFavFileChanges = #False
  
EndProcedure

Procedure WFF_setupGrdFavFiles()
  PROCNAMEC()
  Protected n
  Protected nCurRow
  
  debugMsg(sProcName, #SCS_START)
  
  If CountGadgetItems(WFF\grdFavFiles) > 0
    nCurRow = GGS(WFF\grdFavFiles)
  EndIf
  
  ClearGadgetItems(WFF\grdFavFiles)
  
  For n = 0 To #SCS_MAX_FAV_FILE
    AddGadgetItem(WFF\grdFavFiles, -1, "#" + Str(n+1) + Chr(10) + GetFilePart(grWFF\maFavoriteFiles[n]\sFileName))
  Next n
  debugMsg(sProcName, "CountGadgetItems(WFF\grdFavFiles)=" + Str(CountGadgetItems(WFF\grdFavFiles)))
  autoFitGridCol(WFF\grdFavFiles,1)
  
  If nCurRow < CountGadgetItems(WFF\grdFavFiles)
    SGS(WFF\grdFavFiles, nCurRow)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WFF_setButtonsEtc()
  PROCNAMEC()
  Protected n, nIndex, sCurrFileName.s, bFileExists
  Protected nSpare
  Protected nMinFavFile = -1, nMaxFavFile = -1
  
  With WFF
    For n = 0 To #SCS_MAX_FAV_FILE
      If Len(Trim(grWFF\maFavoriteFiles[n]\sFileName)) = 0
        nSpare + 1
      Else
        If nMinFavFile < 0
          nMinFavFile = n
        EndIf
        nMaxFavFile = n
      EndIf
    Next n
    
    nIndex = GGS(WFF\grdFavFiles)
    If nIndex >= 0
      sCurrFileName = Trim(grWFF\maFavoriteFiles[nIndex]\sFileName)
      If Len(sCurrFileName) > 0
        If FileExists(sCurrFileName)
          bFileExists = #True
        EndIf
      EndIf
    EndIf
    debugMsg(sProcName, "nIndex=" + nIndex + ", sCurrFileName=" + GetFilePart(sCurrFileName))
    
    If sCurrFileName
      If bFileExists
        setEnabled(\btnOpen, #True)
      Else
        setEnabled(\btnOpen, #False)
      EndIf
      setEnabled(\btnRemoveEntry, #True)
      setEnabled(\btnClearEntry, #True)
    Else
      setEnabled(\btnOpen, #False)
      setEnabled(\btnRemoveEntry, #False)
      setEnabled(\btnClearEntry, #False)
    EndIf
    
    If (nSpare > 0) And (Len(Trim(gsCueFile)) > 0)
      setEnabled(\btnAddCurrent, #True)
    Else
      setEnabled(\btnAddCurrent, #False)
    EndIf
    
    If nSpare > 0
      setEnabled(\btnAddFile, #True)
    Else
      setEnabled(\btnAddFile, #False)
    EndIf
    
    If (nIndex > 0) And (sCurrFileName)
      setEnabled(\btnMoveUp, #True)
    Else
      setEnabled(\btnMoveUp, #False)
    EndIf
    
    If (nIndex < nMaxFavFile) And (sCurrFileName)
      setEnabled(\btnMoveDown, #True)
    Else
      setEnabled(\btnMoveDown, #False)
    EndIf
    
    If grWFF\bFavFileChanges
      setEnabled(\btnApply, #True)
    Else
      setEnabled(\btnApply, #False)
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WFF_displayFavFileInfo(nFileIndex, bForceDisplay = #False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If (nFileIndex >= 0) And (nFileIndex <= #SCS_MAX_FAV_FILE)
    With grWFF\maFavoriteFiles[nFileIndex]
      If Len(Trim(\sFileName)) > 0
        If FileExists(\sFileName)
          SGT(WFF\lblFileInfo, \sFileName)
          scsSetGadgetFont(WFF\lblFileInfo, #SCS_FONT_GEN_NORMAL)
        Else
          SGT(WFF\lblFileInfo, LangPars("Errors", "FileNotFound", \sFileName))
          scsSetGadgetFont(WFF\lblFileInfo, #SCS_FONT_GEN_BOLD)
        EndIf
      Else
        SGT(WFF\lblFileInfo, "")
        scsSetGadgetFont(WFF\lblFileInfo, #SCS_FONT_GEN_NORMAL)
      EndIf
    EndWith
  Else
    SGT(WFF\lblFileInfo, "")
    scsSetGadgetFont(WFF\lblFileInfo, #SCS_FONT_GEN_NORMAL)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFF_btnAddCurrent_Click()
  PROCNAMEC()
  Protected sMyFileName.s
  Protected n, nIndex

  debugMsg(sProcName, #SCS_START)

  sMyFileName = gsCueFile

  If Len(Trim(sMyFileName)) > 0
    nIndex = GGS(WFF\grdFavFiles)
    If Len(Trim(grWFF\maFavoriteFiles[nIndex]\sFileName)) > 0
      For n = (#SCS_MAX_FAV_FILE-1) To nIndex Step -1
        grWFF\maFavoriteFiles[n+1] = grWFF\maFavoriteFiles[n]
      Next n
    EndIf
    grWFF\maFavoriteFiles[nIndex]\sFileName = sMyFileName
    grWFF\bFavFileChanges = #True
    WFF_setupGrdFavFiles()
    SGS(WFF\grdFavFiles, nIndex)
    WFF_displayFavFileInfo(nIndex)
  EndIf
  WFF_setButtonsEtc()

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFF_btnAddFile_Click()
  PROCNAMEC()
  Protected sMyFileName.s
  Protected n, nIndex
  Protected sTitle.s, sDefaultFile.s
  Protected sTmp.s
  
  debugMsg(sProcName, #SCS_START)
  
  sTitle = GetWindowTitle(#WFF)
  If Len(Trim(gsCueFolder)) > 0
    sDefaultFile = Trim(gsCueFolder)
  ElseIf Len(Trim(grGeneralOptions\sInitDir)) > 0
    sDefaultFile = Trim(grGeneralOptions\sInitDir)
  EndIf
  
  ; Open the file for reading
  sTmp = OpenFileRequester(sTitle, sDefaultFile, gsPatternAllCueFiles, 0)
  If Len(sTmp) = 0
    ; no file selected
    ProcedureReturn
  EndIf
  
  sMyFileName = sTmp
  
  If Len(Trim(sMyFileName)) > 0
    nIndex = GGS(WFF\grdFavFiles)
    If Len(Trim(grWFF\maFavoriteFiles[nIndex]\sFileName)) > 0
      For n = (#SCS_MAX_FAV_FILE-1) To nIndex Step -1
        grWFF\maFavoriteFiles[n+1] = grWFF\maFavoriteFiles[n]
      Next n
    EndIf
    grWFF\maFavoriteFiles[nIndex]\sFileName = sMyFileName
    grWFF\bFavFileChanges = #True
    WFF_setupGrdFavFiles()
    SGS(WFF\grdFavFiles, nIndex)
    WFF_displayFavFileInfo(nIndex)
  EndIf
  WFF_setButtonsEtc()

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFF_btnClearEntry_Click()
  PROCNAMEC()
  Protected sMyFileName.s
  Protected nIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = GGS(WFF\grdFavFiles)
  grWFF\maFavoriteFiles[nIndex]\sFileName = ""
  grWFF\bFavFileChanges = #True
  WFF_setupGrdFavFiles()
  SGS(WFF\grdFavFiles, nIndex)
  WFF_displayFavFileInfo(nIndex)
  WFF_setButtonsEtc()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFF_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WFF, @grFavFilesWindow)
  
  If grWFF\bFavFileChanges
    ensureSplashNotOnTop()
    nResponse = scsMessageRequester(GWT(#WFF), Lang("WFF", "SaveChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        ProcedureReturn
        
      Case #PB_MessageRequester_Yes
        WFF_applyChanges()
        
    EndSelect
  EndIf
  
  grWED\bReturnToEditorAfterFavFiles = #False  ; this variable used, if required, in WFF_btnOpen_Click() and can now be cleared
  
  ; note - must close window before calling unsetWindowModal() as unsetWindowModal() may call a return function
  scsCloseWindow(#WFF)
  unsetWindowModal(#WFF)
  
EndProcedure

Procedure WFF_btnOpen_Click()
  PROCNAMEC()
  Protected sMyFileName.s
  Protected n, nIndex
  Protected nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  If grWFF\bFavForPrimary
    WEN_closeMemoWindowsIfOpen()
    If checkDataChanged(#True)
      ; either user cancelled when asked about saving, or an error was detected during validation so do not open new file
      ProcedureReturn
    EndIf
    setMonitorPin()
    debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
    saveProdTimerHistIfReqd()
  EndIf
  
  WFF_applyChanges()
  WFF_setButtonsEtc()
  
  If grWED\bReturnToEditorAfterFavFiles
    nCuePtr = 1
  EndIf
  
  If grWFF\bFavForPrimary
    nIndex = GGS(WFF\grdFavFiles)
    If nIndex >= 0
      sMyFileName = Trim(grWFF\maFavoriteFiles[nIndex]\sFileName)
      If sMyFileName
        If FileExists(sMyFileName)
          If grWFF\nParentWindow = #WLP
            grAction\nParentWindow = grWFF\nParentWindow
            grAction\sSelectedFileName = sMyFileName
            grAction\nAction = #SCS_ACTION_OPEN_FILE
            gqMainThreadRequest | #SCS_MTH_PROCESS_ACTION
          Else
            gsCueFile = sMyFileName
            gsCueFolder = GetPathPart(gsCueFile)
            samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, nCuePtr)  ; p1: 1 = primary file.  if p3=0 then do NOT call editor after loading, else call editor with this cueptr
          EndIf
          WFF_Form_Unload()
        EndIf
      EndIf
    EndIf
    
  Else    ; secondary (ie import) cue file
    nIndex = GGS(WFF\grdFavFiles)
    If nIndex >= 0
      sMyFileName = Trim(grWFF\maFavoriteFiles[nIndex]\sFileName)
      If sMyFileName
        If FileExists(sMyFileName)
          gs2ndCueFile = sMyFileName
          gs2ndCueFolder = GetPathPart(gs2ndCueFile)
          debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
          If IsGadget(WIM\txtCueFile)
            SGT(WIM\txtCueFile, gs2ndCueFile)
          EndIf
          samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 2, 0, 0)  ; p1: 2 = secondary file.  p3: 0 = do NOT call editor after loading
          WFF_Form_Unload()
        EndIf
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFF_btnRemoveEntry_Click()
  PROCNAMEC()
  Protected n, nIndex

  debugMsg(sProcName, #SCS_START)

  nIndex = GGS(WFF\grdFavFiles)
  If nIndex >= 0
    For n = (nIndex + 1) To (#SCS_MAX_FAV_FILE)
      grWFF\maFavoriteFiles[n-1] = grWFF\maFavoriteFiles[n]
    Next n
    n = #SCS_MAX_FAV_FILE
    grWFF\maFavoriteFiles[n]\sFileName = ""
    grWFF\bFavFileChanges = #True
  EndIf
  WFF_setupGrdFavFiles()
  SGS(WFF\grdFavFiles, nIndex)
  WFF_displayFavFileInfo(nIndex)
  WFF_setButtonsEtc()

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFF_btnMoveUp_Click()
  PROCNAMEC()
  Protected nIndex
  Protected rFavoriteFile.tyFavoriteFile

  debugMsg(sProcName, #SCS_START)
  
  With grWFF
    nIndex = GGS(WFF\grdFavFiles)
    If nIndex >= 1
      rFavoriteFile = \maFavoriteFiles[nIndex-1]
      \maFavoriteFiles[nIndex-1] = \maFavoriteFiles[nIndex]
      \maFavoriteFiles[nIndex] = rFavoriteFile
      \bFavFileChanges = #True
    EndIf
    nIndex - 1
  EndWith
  WFF_setupGrdFavFiles()
  SGS(WFF\grdFavFiles, nIndex)
  WFF_displayFavFileInfo(nIndex)
  WFF_setButtonsEtc()

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFF_btnMoveDown_Click()
  PROCNAMEC()
  Protected nIndex
  Protected rFavoriteFile.tyFavoriteFile

  debugMsg(sProcName, #SCS_START)
  
  With grWFF
    nIndex = GGS(WFF\grdFavFiles)
    If (nIndex >= 0) And (nIndex < #SCS_MAX_FAV_FILE)
      rFavoriteFile = \maFavoriteFiles[nIndex+1]
      \maFavoriteFiles[nIndex+1] = \maFavoriteFiles[nIndex]
      \maFavoriteFiles[nIndex] = rFavoriteFile
      \bFavFileChanges = #True
    EndIf
    nIndex + 1
  EndWith
  WFF_setupGrdFavFiles()
  SGS(WFF\grdFavFiles, nIndex)
  WFF_displayFavFileInfo(nIndex)
  WFF_setButtonsEtc()

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFF_Form_Load(nParentWindow)
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  If (IsWindow(#WFF) = #False) Or (gaWindowProps(#WFF)\nParentWindow <> nParentWindow)
    createfmFavFiles(nParentWindow)
  EndIf
  setFormPosition(#WFF, @grFavFilesWindow)
  
  ; WFF_setupGrdFavFiles()
  ; WFF_setButtonsEtc()
  
  setWindowVisible(#WFF, #True)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFF_grdFavFiles_CurCellChange()
  PROCNAMEC()
  Protected nIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = GGS(WFF\grdFavFiles)
  WFF_displayFavFileInfo(nIndex)
  WFF_setButtonsEtc()
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WFF_Form_Show(nParentWindow, bModal=#False, nReturnFunction=0, bPrimaryFile=#True)
  PROCNAMEC()
  Protected n, nIndex
  
  If IsWindow(#WFF) = #False Or gaWindowProps(#WFF)\nParentWindow <> nParentWindow
    WFF_Form_Load(nParentWindow)
  EndIf
  setWindowModal(#WFF, bModal, nReturnFunction)
  
  grWFF\nParentWindow = nParentWindow
  grWFF\bFavForPrimary = bPrimaryFile
  
  For n = 0 To #SCS_MAX_FAV_FILE
    grWFF\maFavoriteFiles[n] = gaFavoriteFiles(n)
  Next n
  grWFF\bFavFileChanges = #False
  
  WFF_setupGrdFavFiles()
  nIndex = GGS(WFF\grdFavFiles)
  WFF_displayFavFileInfo(nIndex)
  WFF_setButtonsEtc()
  
  setWindowVisible(#WFF, #True)
  SetActiveWindow(#WFF)
  
EndProcedure

Procedure WFF_EventHandler()
  PROCNAMEC()
  
  With WFF
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WFF_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOpen)
              WFF_btnOpen_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            grWFF\bFavFileChanges = #False   ; prevents WFF asking if changes are to be saved
            WFF_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnAddCurrent
            WFF_btnAddCurrent_Click()
            
          Case \btnAddFile
            WFF_btnAddFile_Click()
            
          Case \btnClearEntry
            WFF_btnClearEntry_Click()
            
          Case \btnHelp
            displayHelpTopic("fav_files.htm")
            
          Case \btnMoveDown
            WFF_btnMoveDown_Click()
            
          Case \btnMoveUp
            WFF_btnMoveUp_Click()
            
          Case \btnOpen
            WFF_btnOpen_Click()
            
          Case \btnRemoveEntry
            WFF_btnRemoveEntry_Click()
            
          Case \btnApply
            WFF_applyChanges()
            WFF_setButtonsEtc()
            
          Case \btnCancel
            grWFF\bFavFileChanges = #False   ; prevents WFF asking if changes are to be saved
            WFF_Form_Unload()
            
          Case \btnOK
            WFF_applyChanges()
            WFF_Form_Unload()
            
          Case \grdFavFiles
            If gnEventType = #PB_EventType_Change
              WFF_grdFavFiles_CurCellChange()
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF