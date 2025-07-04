; File: GetKnownFolderPath.pbi
; code by GJ-68 in PB Forum Topic "SHGetKnownFolderPath_()" at http://www.purebasic.fr/english/viewtopic.php?f=5&t=55173

EnableExplicit

#KF_FLAG_SIMPLE_IDLIST = $00000100
#KF_FLAG_NOT_PARENT_RELATIVE = $00000200
#KF_FLAG_DEFAULT_PATH = $00000400
#KF_FLAG_INIT = $00000800
#KF_FLAG_NO_ALIAS = $00001000
#KF_FLAG_DONT_UNEXPAND = $00002000
#KF_FLAG_DONT_VERIFY = $00004000
#KF_FLAG_CREATE = $00008000
#KF_FLAG_NO_APPCONTAINER_REDIRECTION = $00010000 ; <- Introduced in Windows 7.
#KF_FLAG_ALIAS_ONLY = $80000000

Prototype.i ProtoSHGetKnownFolderPath(*rfid, dwFlags.l ,hToken.i, *ppszPath)

Procedure.s GetKnownFolderPath(*rfid, kfFlag.l = 0, hToken.i = #Null)
  Protected SHGetKnownFolderPath.ProtoSHGetKnownFolderPath
  Protected hLib.i, RetVal.i, sFolderPath.s, *Path
  
  hLib = OpenLibrary(#PB_Any, "shell32.dll")
  If hLib
    SHGetKnownFolderPath = GetFunction(hLib, "SHGetKnownFolderPath")
    If SHGetKnownFolderPath
      RetVal = SHGetKnownFolderPath(*rfid, kfFlag, hToken, @*Path)
      If (RetVal = #S_OK) And *Path
        sFolderPath = PeekS(*Path, -1, #PB_Unicode)
        CoTaskMemFree_(*Path)
      EndIf
    EndIf
    CloseLibrary(hLib)
  EndIf
  ; ProcedureReturn sFolderPath ; <- Does not include a trailing backslash
  ProcedureReturn sFolderPath + "\"   ; trailing backslash added by MJD
EndProcedure

; 
; Debug GetKnownFolderPath(?FOLDERID_Desktop)
; Debug GetKnownFolderPath(?FOLDERID_RoamingAppData)
; Debug GetKnownFolderPath(?FOLDERID_Documents)
; Debug GetKnownFolderPath(?FOLDERID_ProgramData)
; 
; XIncludeFile "KnownFolders.pbi" 
; jaPBe Version=3.12.12.878
; Build=0
; Language=0x0000 Language Neutral
; FirstLine=0
; CursorPosition=44
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF