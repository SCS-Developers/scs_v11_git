; File: AudFileRequester.pbi

; See also fmFileOpener.pbi

; AudFileRequester handles file opens using the Windows Open File dialog, eg using the PB OpenFileRequester function,
; but fmFileOpener handles audio file opens using the 'SCS Open Audio File Dialog', which includes facilities to preview the file.
; Although the 'SCS Open Audio File Dialog' is more versatile, it's not very efficient so is not the default setting under 'Editing Options'.

EnableExplicit

Procedure clearSelectedFileInfo()
  gnSelectedFileCount = 0
  gsSelectedDirectory = ""
EndProcedure

Procedure audioFileRequester(sRequesterTitle.s, bAllowMultiSelect=#False, nWindowNo=#WED, sDefaultFile.s="")
  PROCNAMEC()
  Static lFilter
  Static sLastFile.s
  Static sInitDir.s
  Protected bShowPlaces
  Protected nFileCount
  Protected sFileName.s
  Protected nFlags
  Protected sCurrDefaultFile.s
  Protected nActiveWindow
  
  debugMsg(sProcName, #SCS_START)
  
  nActiveWindow = GetActiveWindow()
  
  If sDefaultFile
    sCurrDefaultFile = sDefaultFile
  Else
    sCurrDefaultFile = sLastFile
  EndIf
  CompilerIf #cTutorialVideoOrScreenShots
    ; Added 28Jan2025
    sCurrDefaultFile = grGeneralOptions\sInitDir
    If Right(sCurrDefaultFile, 1) <> "\"
      sCurrDefaultFile + "\"
    EndIf
  CompilerEndIf
  
  bShowPlaces = #True
  If Len(Trim(sLastFile)) = 0
    If Len(Trim(gsAudioFileDialogInitDir)) > 0
      sInitDir = Trim(gsAudioFileDialogInitDir)
    EndIf
  EndIf
  
  CompilerIf #cSMSOnThisMachineOnly = #False
    If (gbUseSMS) And (gsAudioFilesRootFolder)
      If Left(sInitDir, Len(gsAudioFilesRootFolder)) <> gsAudioFilesRootFolder
        sInitDir = gsAudioFilesRootFolder
      EndIf
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
  ; debugMsg(sProcName, "gsAudioFilesRootFolder=" + gsAudioFilesRootFolder)
  debugMsg(sProcName, "sInitDir=" + sInitDir)
  
  gsSelectedFileErrorMsg = ""
  If bAllowMultiSelect
    nFlags = #PB_Requester_MultiSelection
  EndIf
  sFileName = OpenFileRequester(sRequesterTitle, sCurrDefaultFile, gsAudioFilePattern, gnAudioFilePatternPosition, nFlags)
  nFileCount = 0
  If sFileName
    gsSelectedDirectory = GetPathPart(sFileName)
    While sFileName
      If nFileCount > ArraySize(gsSelectedFile())
        doRedim(gsSelectedFile, (nFileCount+10), "gsSelectedFile()")
      EndIf
      gsSelectedFile(nFileCount) = GetFilePart(sFileName)
      nFileCount + 1
      sFileName = NextSelectedFileName()
    Wend
  EndIf
  gnSelectedFileCount = nFileCount
  debugMsg(sProcName, "nFileCount=" + nFileCount)
  
  If nFileCount = 0
    ; didn't select anything, or an error occurred
    If gsSelectedFileErrorMsg
      debugMsg(sProcName, "gsSelectedFileErrorMsg=" + #DQUOTE$ + gsSelectedFileErrorMsg + #DQUOTE$)
      scsMessageRequester(sRequesterTitle, gsSelectedFileErrorMsg, #PB_MessageRequester_Ok|#MB_ICONEXCLAMATION)
    EndIf
  Else
    gsAudioFileDialogInitDir = ""
    debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
    sLastFile = gsSelectedDirectory + gsSelectedFile(nFileCount-1)
    sInitDir = gsSelectedDirectory
    debugMsg(sProcName, "sLastFile=" + #DQUOTE$ + sLastFile + #DQUOTE$ + ", sInitDir =" + #DQUOTE$ + sInitDir + #DQUOTE$)
  EndIf
  
  ; Added 4Jan2020 11.8.2.1aw: reset active window following email from Peter Holmes about focus going to main window after browsing for a file in a playlist
  ; As Peter had also found this problem elsewhere in SCS, suspect it's related to the use of functions like OpenFileRequester()
  If IsWindow(nActiveWindow) ; Test added 12Feb2022 11.9.0 following memory error report from Joe Eaton
    SAW(nActiveWindow)
  EndIf
  ; End added 4Jan2020 11.8.2.1aw
  
  debugMsg(sProcName, #SCS_END + ", returning nFileCount=" + nFileCount)
  ProcedureReturn nFileCount
  
EndProcedure

; EOF