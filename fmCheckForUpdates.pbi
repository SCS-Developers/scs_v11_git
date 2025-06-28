; File: fmCheckForUpdate.pbi

EnableExplicit

Procedure.s WUP_GetCurrentReleaseVersion(nTimeout=3000, bTrace=#False)
  PROCNAMEC()
  Protected sVersionNo.s
  Protected nResult
  Protected sWebFile.s, sLocalFile.s
  Protected qWaitUntil.q
  Protected nFileNo, nStringFormat
  
  CompilerIf 1=1
    sWebFile = "https://www.showcuesystems.com/versionfile.txt"   ; To test change the file extension to one the webserver will not find.
  CompilerElse
    sWebFile = "https://www.showcuesystems.com/versionfileTemp.txt"
  CompilerEndIf
  sLocalFile = gsTempFolderPath + "scsversion.txt"
  debugMsgC(sProcName, "sWebFile=" + sWebFile)
  debugMsgC(sProcName, "sLocalFile=" + sLocalFile)
  
  If FileExists(sLocalFile)
    nResult = DeleteFile(sLocalFile)
    debugMsgC(sProcName, "DeleteFile(" + sLocalFile + ") returned " + nResult)
  EndIf
  
  debugMsgC(sProcName, "calling URLDownloadToFileW")
  nResult = ReceiveHTTPFile(sWebFile, sLocalFile)                 ; Dee 18/02/2025, replace dependance on external dll call with inbuilt PB call

  If nResult
    debugMsgC(sProcName, "Update version file recieved and written to disk.")
  Else
    debugMsgC(sProcName, "No file recieved (network error).")
  EndIf

  debugMsgC(sProcName, "CallFunction() returned " + nResult)
  Delay(100)
  If FileExists(sLocalFile) = #False
    qWaitUntil = ElapsedMilliseconds() + nTimeout
    Delay(200)
    While #True
      If (FileExists(sLocalFile)) Or ((qWaitUntil - ElapsedMilliseconds()) <= 0)
        Break
        Delay(200)
      EndIf
    Wend
  EndIf
  nFileNo = OpenFile(#PB_Any, sLocalFile)
  If nFileNo
    nStringFormat = ReadStringFormat(nFileNo)
    debugMsgC(sProcName, "nStringFormat=" + decodeStringFormat(nStringFormat))
    sVersionNo = Trim(ReadString(nFileNo, nStringFormat))
    CloseFile(nFileNo)
  Else
    sVersionNo = "*2"
  EndIf
  
  ; If the webserver is unable to find the file it returns a txt file containing the error message, the text file is a html page and will contain "<".
  If FindString(sVersionNo, "<") <> 0  
    sVersionNo = "*1"
  EndIf
    
  If FileExists(sLocalFile)
    nResult = DeleteFile(sLocalFile)
    debugMsgC(sProcName, "DeleteFile(" + sLocalFile + ") returned " + nResult)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + sVersionNo)
  ProcedureReturn sVersionNo
  
EndProcedure

Procedure.s WUP_GetUpdateAvailable(nTimeout=3000, bTrace=#False)
  PROCNAMEC()
  Protected sUpdateAvailable.s
  Protected sCurVersionNo.s, sUpdVersionNo.s
  Protected Dim sVersionParts.s(3)
  Protected nCurVersionNo, nUpdVersionNo
  Protected n
  
  sCurVersionNo = #SCS_PROG_VERSION
  sUpdVersionNo = WUP_GetCurrentReleaseVersion(nTimeout, bTrace)
  debugMsgC(sProcName, "sCurVersionNo=" + sCurVersionNo + ", sUpdVersionNo=" + sUpdVersionNo)
  
  For n = 1 To 4
    sVersionParts(n-1) = StringField(sCurVersionNo, n, ".")
  Next n
  nCurVersionNo = (Val(sVersionParts(0)) * 1000000) + (Val(sVersionParts(1)) * 10000) + (Val(sVersionParts(2)) * 100) + (Val(sVersionParts(3)) * 1)
  
  Select sUpdVersionNo
    Case "*1", "*2"
      sUpdateAvailable = "*"
      
    Default
      For n = 1 To 4
        sVersionParts(n-1) = StringField(sUpdVersionNo, n, ".")
      Next n
      nUpdVersionNo = (Val(sVersionParts(0)) * 1000000) + (Val(sVersionParts(1)) * 10000) + (Val(sVersionParts(2)) * 100) + (Val(sVersionParts(3)) * 1)
      debugMsgC(sProcName, "nCurVersionNo=" + nCurVersionNo + ", nUpdVersionNo=" + nUpdVersionNo)
      If nUpdVersionNo > nCurVersionNo
        sUpdateAvailable = sUpdVersionNo
      EndIf
      
  EndSelect
  
  ; return new version number if update available; blank if current version is up-to-date; or * if not able to check
  ProcedureReturn sUpdateAvailable
  
EndProcedure


Procedure WUP_Form_Show(bModal=#False)
  PROCNAMEC()
  Protected sCurVersionNo.s, sUpdVersionNo.s
  Protected Dim sVersionParts.s(3)
  Protected nCurVersionNo, nUpdVersionNo
  Protected n
  
  If IsWindow(#WUP) = #False
    createfmCheckForUpdate()
  EndIf
  
  sCurVersionNo = #SCS_PROG_VERSION
  sUpdVersionNo = WUP_GetCurrentReleaseVersion()
  debugMsg(sProcName, "sCurVersionNo=" + sCurVersionNo + ", sUpdVersionNo=" + sUpdVersionNo)
  
  For n = 1 To 4
    sVersionParts(n-1) = StringField(sCurVersionNo, n, ".")
  Next n
  nCurVersionNo = (Val(sVersionParts(0)) * 1000000) + (Val(sVersionParts(1)) * 10000) + (Val(sVersionParts(2)) * 100) + (Val(sVersionParts(3)) * 1)
  
  With WUP
    Select sUpdVersionNo
      Case "*1", "*2"
        SGT(\lblUpdateStatus, Lang("WUP", "CannotCheck"))
        setVisible(\cntUpdateInfo, #False)
        setVisible(\cntDownloadInfo, #False)
        
      Default
        For n = 1 To 4
          sVersionParts(n-1) = StringField(sUpdVersionNo, n, ".")
        Next n
        nUpdVersionNo = (Val(sVersionParts(0)) * 1000000) + (Val(sVersionParts(1)) * 10000) + (Val(sVersionParts(2)) * 100) + (Val(sVersionParts(3)) * 1)
        debugMsg(sProcName, "nCurVersionNo=" + nCurVersionNo + ", nUpdVersionNo=" + nUpdVersionNo)
        
        SGT(\lblCurVersion, sCurVersionNo)
        SGT(\lblUpdVersion, sUpdVersionNo)
        setVisible(\cntUpdateInfo, #True)
        
        If nUpdVersionNo > nCurVersionNo
          SGT(\lblUpdateStatus, Lang("WUP", "UpdateAvailable"))
          SGT(\lblDownloadMsg, LangPars("WUP","lblDownloadMsg",gsLicUser))
          setVisible(\cntDownloadInfo, #True)
        Else
          SGT(\lblUpdateStatus, Lang("WUP", "UpToDate"))
          setVisible(\cntDownloadInfo, #False)
        EndIf
        
    EndSelect
  EndWith
  
  ensureSplashNotOnTop()
  setWindowModal(#WUP, bModal)
  setWindowVisible(#WUP, #True)
  SetActiveWindow(#WUP)
EndProcedure

Procedure WUP_Form_Unload()
  unsetWindowModal(#WUP)
  scsCloseWindow(#WUP)
EndProcedure

Procedure WUP_EventHandler()
  PROCNAMEC()
  
  With WUP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WUP_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            WUP_Form_Unload()
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WUP_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnClose   ; btnClose
            WUP_Form_Unload()
            
          Case \lblDownloadLink   ; lblDownloadLink
            OpenURL(#SCS_DOWNLOAD_LINK)
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF