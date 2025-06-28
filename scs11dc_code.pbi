; file: scs11dc_code.pbi

; 'data clean' program to be run at the start of an uninstall

; INFO: compile using scs11dc_x64.pb and scs11dc_x86.pb

EnableExplicit

Procedure FolderExists(sPathName.s)
  ; obtained from PB Forum topic "avoid No Disk error?"
  Protected oldmode.l
  Protected mdir
  
  ; see also FileExists
  
  oldmode = SetErrorMode_(1)
  mdir = ExamineDirectory(#PB_Any, sPathName, "*.*")
  SetErrorMode_(oldmode)
  If IsDirectory(mdir)
    FinishDirectory(mdir)
    ProcedureReturn #True
  Else
    GetLastError_()
    SetLastError_(0)
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure doClean()
  Protected nResponse
  Protected sAppDataFolder.s, sAppDataPath.s
  Protected bDevMapsExist, bTemplatesExist
  Protected sMsg.s
  Protected sMyDocsPath.s, sLogsFolder.s, sDiagsFolder.s, sDemoFolder.s, sCommonAppDataPath.s
  
  sAppDataFolder = GetUserDirectory(#PB_Directory_ProgramData) ; eg "C:\Users\Mike\AppData\Roaming\"
  If sAppDataFolder
    If FileSize(sAppDataFolder) = -2
      sAppDataPath = sAppDataFolder + "ShowCueSystem\"
      If FileSize(sAppDataPath) = -2
        If FileSize(sAppDataPath + "DevMaps\")
          bDevMapsExist = #True
        EndIf
        If FileSize(sAppDataPath + "Templates\")
          bTemplatesExist = #True
        EndIf
        If bDevMapsExist Or bTemplatesExist
          sMsg = "Do you want to delete all SCS Device Maps"
          If bTemplatesExist
            sMsg + ", Templates"
          EndIf
          sMsg + " and other data from " + #DQUOTE$ + sAppDataPath + #DQUOTE$ + "?"
          nResponse = MessageRequester("SCS Uninstall", sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
          If nResponse = #PB_MessageRequester_Yes
            DeleteDirectory(sAppDataPath, "*.*", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  sCommonAppDataPath = GetUserDirectory(#PB_Directory_AllUserData) ; "C:\ProgramData"
  sCommonAppDataPath  + "ShowCueSystem\"
  If FileSize(sCommonAppDataPath) = -2
    DeleteDirectory(sCommonAppDataPath, "*.*", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf

  sMyDocsPath = GetUserDirectory(#PB_Directory_Documents)
  sLogsFolder = sMyDocsPath + "SCS Logs\"
  If FolderExists(sLogsFolder)
    DeleteDirectory(sLogsFolder, "*.*", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf
  
  sDiagsFolder = sMyDocsPath + "SCS Diagnostics\"
  If FolderExists(sDiagsFolder)
    DeleteDirectory(sDiagsFolder, "*.*", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf
  
  sDemoFolder = sMyDocsPath + "SCS_Demo\"
  If FolderExists(sDemoFolder)
    DeleteDirectory(sDemoFolder, "*.*", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf

EndProcedure

doClean()

; EOF