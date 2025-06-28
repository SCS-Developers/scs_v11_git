; File: fmFavFileSelector.pbi

EnableExplicit

Procedure WFS_setupgrdFavFiles()
  PROCNAMEC()
  Protected n
  Protected nCurRow
  
  debugMsg(sProcName, #SCS_START)
  
  If CountGadgetItems(WFS\grdFavFiles) > 0
    nCurRow = GGS(WFS\grdFavFiles)
  EndIf
  
  ClearGadgetItems(WFS\grdFavFiles)
  
  For n = 0 To #SCS_MAX_FAV_FILE
    AddGadgetItem(WFS\grdFavFiles, -1, "#" + Str(n+1) + Chr(10) + GetFilePart(grWFS\maFavoriteFiles[n]\sFileName))
  Next n
  debugMsg(sProcName, "CountGadgetItems(WFS\grdFavFiles)=" + Str(CountGadgetItems(WFS\grdFavFiles)))
  autoFitGridCol(WFS\grdFavFiles,1)
  
  If nCurRow < CountGadgetItems(WFS\grdFavFiles)
    SGS(WFS\grdFavFiles, nCurRow)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WFS_setButtonsEtc()
  PROCNAMEC()
  Protected n, nIndex, sCurrFileName.s, bFileExists
  
  nIndex = GGS(WFS\grdFavFiles)
  If nIndex >= 0
    sCurrFileName = grWFS\maFavoriteFiles[nIndex]\sFileName
    If Len(sCurrFileName) > 0
      If FileExists(sCurrFileName)
        bFileExists = #True
      EndIf
    EndIf
  EndIf
  debugMsg(sProcName, "nIndex=" + nIndex + ", sCurrFileName=" + GetFilePart(sCurrFileName))
  
  If bFileExists
    setEnabled(WFS\btnOpen, #True)
  Else
    setEnabled(WFS\btnOpen, #False)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WFS_displayFavFileInfo(nFileIndex, bForceDisplay = #False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If nFileIndex >= 0 And nFileIndex <= #SCS_MAX_FAV_FILE
    With grWFS\maFavoriteFiles[nFileIndex]
      If Len(Trim(\sFileName)) > 0
        If FileExists(\sFileName)
          SGT(WFS\lblFileInfo, \sFileName)
          scsSetGadgetFont(WFS\lblFileInfo, #SCS_FONT_GEN_NORMAL)
        Else
          SGT(WFS\lblFileInfo, LangPars("Errors", "FileNotFound", \sFileName))
          scsSetGadgetFont(WFS\lblFileInfo, #SCS_FONT_GEN_BOLD)
        EndIf
      Else
        SGT(WFS\lblFileInfo, "")
        scsSetGadgetFont(WFS\lblFileInfo, #SCS_FONT_GEN_NORMAL)
      EndIf
    EndWith
  Else
    SGT(WFS\lblFileInfo, "")
    scsSetGadgetFont(WFS\lblFileInfo, #SCS_FONT_GEN_NORMAL)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFS_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WFS, @grFavFileSelectorWindow)
  
  ; note - must close window before calling unsetWindowModal() as unsetWindowModal() may call a return function
  scsCloseWindow(#WFS)
  unsetWindowModal(#WFS)
  
EndProcedure

Procedure WFS_btnOpen_Click()
  PROCNAMEC()
  Protected sMyFileName.s
  Protected n, nIndex
  Protected nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grWFS\bFavForPrimary=" + strB(grWFS\bFavForPrimary))
  If grWFS\bFavForPrimary
    WEN_closeMemoWindowsIfOpen()
    If checkDataChanged(#True)
      ; either user cancelled when asked about saving, or an error was detected during validation so do not open new file
      ProcedureReturn
    EndIf
    setMonitorPin()
    debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
    saveProdTimerHistIfReqd()
  EndIf
  
  WFS_setButtonsEtc()
  
  If grWFS\bFavForPrimary
    nIndex = GGS(WFS\grdFavFiles)
    If nIndex >= 0
      sMyFileName = grWFS\maFavoriteFiles[nIndex]\sFileName
      If Len(Trim(sMyFileName)) > 0
        If FileExists(sMyFileName)
          gsCueFile = sMyFileName
          gsCueFolder = GetPathPart(gsCueFile)
          samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, nCuePtr)  ; p1: 1 = primary file.  if p3=0 then do NOT call editor after loading, else call editor with this cueptr
          WFS_Form_Unload()
        EndIf
      EndIf
    EndIf
    
  Else    ; secondary (ie import) cue file
    nIndex = GGS(WFS\grdFavFiles)
    If nIndex >= 0
      sMyFileName = grWFS\maFavoriteFiles[nIndex]\sFileName
      If Len(Trim(sMyFileName)) > 0
        If FileExists(sMyFileName)
          gs2ndCueFile = sMyFileName
          gs2ndCueFolder = GetPathPart(gs2ndCueFile)
          debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
          If IsGadget(WIM\txtCueFile)
            SGT(WIM\txtCueFile, gs2ndCueFile)
          EndIf
          samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 2, 0, 0)  ; p1: 2 = secondary file.  p3: 0 = do NOT call editor after loading
          WFS_Form_Unload()
        EndIf
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFS_Form_Load(nParentWindow)
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  If (IsWindow(#WFS) = #False) Or (gaWindowProps(#WFS)\nParentWindow <> nParentWindow)
    createfmFavFileSelector(nParentWindow)
  EndIf
  setFormPosition(#WFS, @grFavFileSelectorWindow)
  
  ; WFS_setupgrdFavFiles()
  ; WFS_setButtonsEtc()
  
  setWindowVisible(#WFS, #True)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFS_setupFavFileSelectorForm(nParentWindow, bPrimaryFile)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  grWFS\bFavForPrimary = bPrimaryFile
  If IsWindow(#WFS) = #False Or gaWindowProps(#WFS)\nParentWindow <> nParentWindow
    WFS_Form_Load(nParentWindow)
  EndIf
  
  For n = 0 To #SCS_MAX_FAV_FILE
    grWFS\maFavoriteFiles[n] = gaFavoriteFiles(n)
  Next n
  
  WFS_setupgrdFavFiles()
  WFS_setButtonsEtc()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFS_grdFavFiles_CurCellChange()
  PROCNAMEC()
  Protected nIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = GGS(WFS\grdFavFiles)
  WFS_displayFavFileInfo(nIndex)
  WFS_setButtonsEtc()
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WFS_Form_Show(nParentWindow, bModal=#False, nReturnFunction=0)
  If IsWindow(#WFS) = #False Or gaWindowProps(#WFS)\nParentWindow <> nParentWindow
    WFS_Form_Load(nParentWindow)
  EndIf
  setWindowModal(#WFS, bModal, nReturnFunction)
  setWindowVisible(#WFS, #True)
  SetActiveWindow(#WFS)
EndProcedure

Procedure WFS_EventHandler()
  PROCNAMEC()
  
  With WFS
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WFS_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOpen)
              WFS_btnOpen_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WFS_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnOpen
            WFS_btnOpen_Click()
            
          Case \btnCancel
            WFS_Form_Unload()
            
          Case \grdFavFiles
            If gnEventType = #PB_EventType_Change
              WFS_grdFavFiles_CurCellChange()
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF