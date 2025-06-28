; cdf.pb
; create declare file

EnableExplicit

XIncludeFile "KnownFolders.pbi"
XIncludeFile "GetKnownFolderPath.pbi"

Procedure CreateDeclareFile()
  Protected sMyDocsPath.s
  Protected sSourceFile.s, sDeclareFile.s, sPathPart.s, sFilePart.s
  Protected sPattern.s
  Protected nPatternPos
  Protected sLine.s
  Protected nLinesWritten
  Protected sDefaultFile.s
  Protected nResponse
  
  sMyDocsPath = GetKnownFolderPath(?FOLDERID_Documents)
  sDefaultFile = sMyDocsPath + "SCS\scs_v11\scs_v11_curr_development\"
  ; sDefaultFile = "C:\Users\Mike\Documents\SCS\scs_v11\scs_v11_curr_development\"
  sPattern = "PureBasic Include (*.pbi)|*.pbi|All files (*.*)|*.*"
  nPatternPos = 0
  
  sSourceFile = OpenFileRequester("Open PB Source File", sDefaultFile, sPattern, nPatternPos)
  If sSourceFile
    If ReadFile(0, sSourceFile)
      sPathPart = GetPathPart(sSourceFile)
      sFilePart = GetFilePart(sSourceFile)
      If LCase(Right(sFilePart,4)) + ".pbi"
        sFilePart = ReplaceString(sFilePart, ".pbi", ".pbd", #PB_String_NoCase)
      EndIf
      sDeclareFile = sPathPart + "declare\" + sFilePart
      If ReadFile(2, sDeclareFile)
        CloseFile(2)
        nResponse = #PB_MessageRequester_Yes
      Else
        nResponse = MessageRequester("Create Declare File",
                                     "There is no existing " + GetFilePart(sDeclareFile) + Chr(10) +
                                     "OK to create one?", #PB_MessageRequester_YesNo)
      EndIf
      If nResponse = #PB_MessageRequester_Yes
        If CreateFile(1, sDeclareFile)
          While Eof(0) = #False
            sLine = ReadString(0)
            If Left(sLine, 10) = "Procedure "
              WriteStringN(1, "Declare " + Mid(sLine,11))
              nLinesWritten + 1
            ElseIf Left(sLine, 10) = "Procedure."
              WriteStringN(1, "Declare." + Mid(sLine,11))
              nLinesWritten + 1
            ElseIf Left(sLine, 6) = "Macro " And 1=2    ; try omitting macro declarations (following syntax error reported by compiler on the declare of a macro that had a string default, ie:
                                                        ; Declare macCreateDevMap(bInitialDevMap, prProd, paDevMap, paDev, pDevMapName="", pAudioDriver=0)
              WriteStringN(1, "Declare " + Mid(sLine,7))
              nLinesWritten + 1
            EndIf
          Wend
          CloseFile(1)
          Debug Str(nLinesWritten) + " lines written to " + GetFilePart(sDeclareFile)
          ; Debug "sDeclareFile=" + #DQUOTE$ + sDeclareFile + #DQUOTE$
          ; Debug "FileSize(sDeclareFile)=" + FileSize(sDeclareFile)
        EndIf
      EndIf
      CloseFile(0)
    EndIf
  EndIf
  
EndProcedure

Debug "start"
CreateDeclareFile()
Debug "end"

End

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 6
; Folding = -
; EnableThread
; EnableXP
; EnableOnError
; Executable = cdf.exe
; CPU = 1
; EnableUnicode