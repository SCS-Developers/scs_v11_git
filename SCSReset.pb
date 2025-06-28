; file: SCSReset.pb

EnableExplicit

#SCS_PREFS_FILE = "scs11.scsp"
#SCS_PREFS_FILE_COMMON = "scs11.scscp"

Global gnScanCount
Global gqTimer.q
Global gsProgress.s

Procedure scanFolder(sFolder.s, nAction)
  Protected nDirectory
  Protected sFileName.s, sFullPathName.s
  Protected nResponse
  Protected qTimeNow.q
  
  nDirectory = ExamineDirectory(#PB_Any, sFolder, "*.*")
  If nDirectory
    While NextDirectoryEntry(nDirectory)
      sFileName = DirectoryEntryName(nDirectory)
      Select sFileName
        Case ".", ".."
          Continue
        Default
          If Left(sFileName,1) = "$"
            Continue
          ElseIf Left(sFileName,13) = "Program Files"
            Continue
          ElseIf Left(sFileName,7) = "Windows"
            Continue
          EndIf
      EndSelect
      qTimeNow = ElapsedMilliseconds()
      If (qTimeNow - gqTimer) >= 1000
        gsProgress + "."
        SetGadgetText(3, gsProgress)
        gqTimer = qTimeNow
      EndIf
      If DirectoryEntryType(nDirectory) = #PB_DirectoryEntry_Directory
        scanFolder(sFolder + "\" + sFileName, nAction)
      Else
        Select LCase(sFileName)
          Case #SCS_PREFS_FILE, #SCS_PREFS_FILE_COMMON
            sFullPathName = sFolder + "\" + sFileName
            gnScanCount + 1
            Debug Str(gnScanCount) + ": " + sFullPathName
            If nAction = 1
              AddGadgetItem(2, -1, sFullPathName)
              UpdateWindow_(WindowID(0))
              DeleteFile(sFullPathName, #PB_FileSystem_Force)
            EndIf
            ;             If nAction = 2
            ;               nResponse = MessageRequester("Delete File?", "Delete file " + #DQUOTE$ + sFullPathName + #DQUOTE$ + "?", #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
            ;               If nResponse = #PB_MessageRequester_Yes
            ;                 DeleteFile(sFullPathName, #PB_FileSystem_Force)
            ;               EndIf
            ;             EndIf
        EndSelect
      EndIf
    Wend
    FinishDirectory(nDirectory)
  EndIf
  
EndProcedure

Procedure doScan()
  Protected nEvent
  Protected sFolder.s
  Protected nResponse
  Protected bFirstTime = #True
  
  nResponse = MessageRequester("SCS Reset",
                               "Warning! This 'reset' program will de-register SCS on this computer. The first time you run SCS after de-registering you will need to re-enter your registration details " +
                               "(User Name and Authorization String)." + Chr(10) + Chr(10) +
                               "Note that all SCS options and the list of recent files will also be reset." + Chr(10) + Chr(10) +
                               "This program does NOT 'uninstall' SCS - it only applies a complete 'factory reset' which includes clearing the registration details." + Chr(10) + Chr(10) +
                               "Do you wish to proceed with the reset?", #PB_MessageRequester_YesNo|#MB_ICONWARNING)
  If nResponse = #PB_MessageRequester_Yes
    If OpenWindow(0, 100, 200, 600, 400, "SCS Reset")
      TextGadget(3, 10, 10, 580, 26, "")
      ListViewGadget(2,  10, 40, 580, 300)
      ButtonGadget(4, 250, 360, 80, 23, "Close")
      
      Repeat
        nEvent = WaitWindowEvent(1000)
        If bFirstTime
          bFirstTime = #False
          ClearGadgetItems(2)
          gnScanCount = 0
          sFolder = "C:"
          gsProgress = "Scanning " + sFolder + " (please wait) "
          SetGadgetText(3, gsProgress)
          UpdateWindow_(WindowID(0))
          gqTimer = ElapsedMilliseconds()
          scanFolder(sFolder, 1)
          SetGadgetText(3, "")
          AddGadgetItem(2, -1, "")
          AddGadgetItem(2, -1, "SCS Registration Files deleted: " + gnScanCount)
        EndIf
        Select nEvent
          Case #PB_Event_Gadget
            Select EventGadget()
              Case 4
                Break
            EndSelect
        EndSelect
      Until nEvent = #PB_Event_CloseWindow
    EndIf
  EndIf
EndProcedure

doScan()


; IDE Options = PureBasic 5.43 LTS (Windows - x64)
; CursorPosition = 76
; FirstLine = 53
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; Executable = Runtime\scsreset.exe
; CurrentDirectory = Runtime\
; Compiler = PureBasic 5.43 LTS (Windows - x86)