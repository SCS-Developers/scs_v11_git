; File: fmFileLocator.pbi

EnableExplicit

Procedure WFL_displaySaveMsg()
  PROCNAMEC()
  Protected sTitle.s
  Protected sMessage.s
  
  ; display message: "To save your changes, go to the Editor and click the Save button"
  sMessage = Lang("WFL", "saveChanges")
  sTitle = Lang("WFL", "Window")  ; need to get the window title from the language array, not from GetWindowTitle() as the window may have been close
  debugMsg(sProcName, sMessage)
  ensureSplashNotOnTop()
  scsMessageRequester(sTitle, Lang("WFL", "saveChanges"), #PB_MessageRequester_Ok)
EndProcedure

Procedure WFL_populateFileList(pPrimaryFile.i)
  PROCNAMEC()
  Protected n, m, sFileName.s
  Protected bAlreadyInList
  
  If IsWindow(#WFL) = #False
    createfmFileLocator()
  EndIf
  
  grWFL\bPrimaryFile = pPrimaryFile
  
  If grWFL\bPrimaryFile
    SGT(WFL\lblFileList, Lang("WFL","lblFileList") + " " + GetFilePart(gsCueFile))
  Else
    SGT(WFL\lblFileList, Lang("WFL","lblFileList") + " " + GetFilePart(gs2ndCueFile))
  EndIf
  ClearGadgetItems(WFL\tvwFileList)
  For n = 1 To gnFileNotFoundCount
    If gaFileNotFound(n)\bFound = #False
      sFileName = gaFileNotFound(n)\sFileName
      bAlreadyInList = #False
      For m = 1 To (n - 1)
        If gaFileNotFound(m)\bFound = #False
          If sFileName = gaFileNotFound(m)\sFileName
            bAlreadyInList = #True
            Break
          EndIf
        EndIf
      Next m
      If bAlreadyInList = #False
debugMsg(sProcName, "calling AddGadgetItem(WFL\tvwFileList, -1, " + GetFilePart(sFileName) + ")")
        AddGadgetItem(WFL\tvwFileList, -1, sFileName)
      EndIf
    EndIf
  Next n
  
  If CountGadgetItems(WFL\tvwFileList) > 0
    SGS(WFL\tvwFileList, 0)
  EndIf
  
  setWindowVisible(#WFL, #True)
  
EndProcedure

Procedure WFL_lookForMissingFiles(sThisPath.s)
  PROCNAMEC()
  Protected nDirectory
  Protected sPattern.s
  Protected sFileName.s, sExtension.s
  Protected sFilePart.s
  Protected n, m
  Protected sType.s, sSize.s
  
  debugMsg(sProcName, #SCS_START + ", sThisPath=" + sThisPath)
  
  nDirectory = ExamineDirectory(#PB_Any, sThisPath, sPattern)
  Debug "nDirectory=" + nDirectory + ", sThisPath=" + sThisPath
  If nDirectory
    While NextDirectoryEntry(nDirectory)
      If DirectoryEntryType(nDirectory) = #PB_DirectoryEntry_File
        sType = "[File] "
        sSize = " (Size: " + DirectoryEntrySize(nDirectory) + ")"
        sFileName = DirectoryEntryName(nDirectory)
        sFilePart = GetFilePart(sFileName)
        For n = 1 To gnFileNotFoundCount
          If gaFileNotFound(n)\bFound = #False
            If LCase(GetFilePart(gaFileNotFound(n)\sFileName)) = LCase(sFilePart)
              gaFileNotFound(n)\sNewFileName = sFileName
              gaFileNotFound(n)\bFound = #True
              Debug "Found " + sFileName
            EndIf
          EndIf
        Next n
      Else
        sType = "[Directory] "
        sSize = "" ; A directory doesn't have a size
      EndIf
      
      ; Debug sType + DirectoryEntryName(nDirectory) + sSize
    Wend
    FinishDirectory(nDirectory)
  EndIf
  
EndProcedure

Procedure WFL_Form_Unload(bOnlyUnload=#False)
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START)
  
  If bOnlyUnload = #False
    If gbAudioFileOrPathChanged And grWFL\bPrimaryFile
      ; call ONC_openNextCues() so that cues using files now found may be successfully opened
      ONC_openNextCues()
      ; then re-populate the display panels as the cues not opened would have been omitted
      PNL_loadDispPanels()
    EndIf
  EndIf
  
  gbModalDisplayed = #False
  scsCloseWindow(#WFL)
  gbFileLocatorActive = #False
  gbShowFileLocatorAfterInitialisation = #False

  debugMsg(sProcName, "calling setFileSave()")
  setFileSave() ; added 17Nov2016 11.5.2.4.005 (see also 11.5.2.4.005 mod in setDerivedAudTimes())
  
  If bOnlyUnload = #False
    If gbGoToProdPropDevices
      debugMsg(sProcName, "calling callEditor()")
      callEditor()
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFL_btnClose_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  WFL_Form_Unload()
  If gbAudioFileOrPathChanged
    WFL_displaySaveMsg()  ; nb OK to display this message after the form has been unloaded
  EndIf
EndProcedure

Procedure WFL_btnLocate_ClickNew()
  PROCNAMEC()
  Protected sThisFileName.s, sThisFolder.s
  Protected sTitle.s
  Protected sPath.s
  Static sInitDir.s
  
  sThisFileName = GetGadgetText(WFL\tvwFileList)
  sThisFolder = GetPathPart(sThisFileName)

  If FolderExists(sThisFolder)
    sInitDir = sThisFolder
  ElseIf Len(Trim(gsCdlgBrowseInitDir)) > 0
    sInitDir = Trim(gsCdlgBrowseInitDir)
  ElseIf grGeneralOptions\sInitDir
    sInitDir = grGeneralOptions\sInitDir
  Else
    sInitDir = GetCurrentDirectory()
  EndIf
  Debug "sInitDir=" + sInitDir
  
  sTitle = LangPars("WFL", "FindFile", #DQUOTE$ + GetFilePart(sThisFileName) + #DQUOTE$)
  sPath = PathRequester(sTitle, sInitDir)
  debugMsg(sProcName, "sPath=" + sPath)
  
  WFL_lookForMissingFiles(sPath)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFL_btnLocate_Click()
  PROCNAMEC()
  Static lFilter
  Protected sThisFileName.s, sThisFolder.s
  Protected sNewFolder.s
  Protected n, nAudPtr, sTryFileName.s
  Protected bAllFound
  Static sInitDir.s
  Protected sTitle.s, sDefaultFile.s, sPattern.s
  Protected sFileExt.s
  Protected sMyFileName.s
  
  debugMsg(sProcName, #SCS_START)
  
  sThisFileName = GetGadgetText(WFL\tvwFileList)
  sThisFolder = GetPathPart(sThisFileName)

  If FolderExists(sThisFolder)
    sInitDir = sThisFolder
  ElseIf Len(Trim(gsCdlgBrowseInitDir)) > 0
    sInitDir = Trim(gsCdlgBrowseInitDir)
  EndIf
  
  sTitle = LangPars("WFL", "FindFile", #DQUOTE$ + GetFilePart(sThisFileName) + #DQUOTE$)
  ; sPattern = Lang("Requesters", "AllFiles") + " (*.*)|*.*"
  sFileExt = GetExtensionPart(sThisFileName)
  sPattern = LangPars("Requesters", "ExtFiles", UCase(sFileExt)) + "|*." + LCase(sFileExt)
  sDefaultFile = GetFilePart(sThisFileName)
  
  ; Open the file for reading
  sMyFileName = OpenFileRequester(sTitle, sDefaultFile, sPattern, 0)
  
  If Len(sMyFileName) = 0
    ; cancelled without selecting a file
    ProcedureReturn
  EndIf

  ;Save the current information
  For n = 1 To gnFileNotFoundCount
    
    If gaFileNotFound(n)\sFileName = sThisFileName
      If FileExists(sMyFileName)
        nAudPtr = gaFileNotFound(n)\nAudPtr
        If grWFL\bPrimaryFile
          With aAud(nAudPtr)
            \sFileName = sMyFileName
            \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
            If \nAudState = #SCS_CUE_ERROR
              \nAudState = #SCS_CUE_NOT_LOADED
            EndIf
            \nFileDataPtr = grAudDef\nFileDataPtr
          EndWith
        Else
          With a2ndAud(nAudPtr)
            \sFileName = sMyFileName
            \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
            If \nAudState = #SCS_CUE_ERROR
              \nAudState = #SCS_CUE_NOT_LOADED
            EndIf
            \nFileDataPtr = grAudDef\nFileDataPtr
          EndWith
        EndIf
        gaFileNotFound(n)\sNewFileName = sMyFileName
        gaFileNotFound(n)\bFound = #True
        gbAudioFileOrPathChanged = #True
        gqLastChangeTime = ElapsedMilliseconds()
      EndIf
      
    ElseIf gaFileNotFound(n)\bFound = #False
      sNewFolder = GetPathPart(sMyFileName)
      sTryFileName = sNewFolder + GetFilePart(gaFileNotFound(n)\sFileName)
      debugMsg(sProcName, "sTryFileName=" + sTryFileName)
      If FileExists(sTryFileName)
        nAudPtr = gaFileNotFound(n)\nAudPtr
        If grWFL\bPrimaryFile
          With aAud(nAudPtr)
            \sFileName = sTryFileName
            \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
            If \nAudState = #SCS_CUE_ERROR
              \nAudState = #SCS_CUE_NOT_LOADED
            EndIf
            \nFileDataPtr = grAudDef\nFileDataPtr
          EndWith
        Else
          With a2ndAud(nAudPtr)
            \sFileName = sTryFileName
            \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
            If \nAudState = #SCS_CUE_ERROR
              \nAudState = #SCS_CUE_NOT_LOADED
            EndIf
            \nFileDataPtr = grAudDef\nFileDataPtr
          EndWith
        EndIf
        gaFileNotFound(n)\sNewFileName = sTryFileName
        gaFileNotFound(n)\bFound = #True
        gbAudioFileOrPathChanged = #True
        gqLastChangeTime = ElapsedMilliseconds()
      EndIf
      
    EndIf
  Next n

  bAllFound = #True
  For n = 1 To gnFileNotFoundCount
    If gaFileNotFound(n)\bFound = #False
      bAllFound = #False
      Break
    EndIf
  Next n

  WFL_populateFileList(grWFL\bPrimaryFile)
  If bAllFound
    WFL_Form_Unload()
    If (gbAudioFileOrPathChanged) And (grWFL\bPrimaryFile)
      WFL_displaySaveMsg()  ; nb OK to display this message after the form has been unloaded
    EndIf
  EndIf

EndProcedure

Procedure WFL_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  If IsWindow(#WFL) = #False
    createfmFileLocator()
  EndIf
  gbModalDisplayed = #True
  setWindowVisible(#WFL, #True)
EndProcedure

Procedure WFL_Form_Show(bModal=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  gbFileLocatorActive = #True
  If IsWindow(#WFL) = #False
    WFL_Form_Load()
  EndIf
  setWindowVisible(#WFL, #True)
  gbKillSplashTimerNow = #True
  debugMsg(sProcName, "gbKillSplashTimerNow=" + strB(gbKillSplashTimerNow))
  
EndProcedure

Procedure WFL_EventHandler()
  PROCNAMEC()
  
  With WFL
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WFL_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
          Case \btnClose
            WFL_btnClose_Click()
          Case \btnLocate
            WFL_btnLocate_Click()
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF