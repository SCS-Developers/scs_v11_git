; File DLLType.pbi

EnableExplicit

Procedure getDLLType(lpApplicationName$)
  ; based on code supplied by RASHAD and others in reply to my PB Forum posting 'Checking if a DLL is 32-bit or 64-bit?', 10Dec2018
  ; note that the #SCS constants in this procedure are Windows constants as used by the Windows function GetBinaryType
  ; returns:
  ;   32 for a 32-bit DLL
  ;   64 for a 64-bit DLL
  ;   0 for anything else
  ; nb return value settings could be expanded for other binary types if required
  PROCNAMEC()
  Protected nDLLType, hFile, hFileMap, PMapView
  
  #SCS_64BIT_BINARY = 6
  
  Define IDH.IMAGE_DOS_HEADER,INH.IMAGE_NT_HEADERS, lpBinaryType
  ;Define lpApplicationName$ = "e:\projects\stuff rashad\for_test\freak-dll-x64.exe"
  ;Define lpApplicationName$ = "c:\7-Zip\7-zip32.dll"
  ;Define lpApplicationName$ = "c:\7-Zip\7-zip.dll"
  ;Define lpApplicationName$ = "e:\projects\stuff rashad\for_test\freak-dll-test.pb"
  ;Define lpApplicationName$ = "C:\Program Files (x86)\Steinberg\VSTPlugins\TDR Nova.dll"
  ;Define lpApplicationName$ = "C:\Program Files\Steinberg\VSTPlugins\TDR Nova.dll"
  ;Define lpApplicationName$ = "C:\VSTPlugIns\ValhallaFreqEcho_x64.dll"
  ;Define lpApplicationName$ = "C:\Program Files (x86)\Common Files\VST3\OldSkoolVerb.vst3"
  ;Define lpApplicationName$ = "C:\Program Files\Common Files\VST3\FabFilter Pro-Q 2.vst3"
  
  hFile = CreateFile_(@lpApplicationName$, #GENERIC_READ, #FILE_SHARE_READ, 0, #OPEN_EXISTING, #FILE_ATTRIBUTE_NORMAL, 0)
  hFileMap = CreateFileMapping_(hFile, 0, #PAGE_READONLY, 0, 0, 0)
  PMapView = MapViewOfFile_(hFileMap, #FILE_MAP_READ, 0, 0, 0)
  CopyMemory(PMapView, @IDH,SizeOf(IMAGE_DOS_HEADER))
  If idh\e_magic = $5A4D And GetBinaryType_(@lpApplicationName$,@lpBinaryType) = 1  
    Select lpBinaryType
      Case #SCS_32BIT_BINARY
        debugMsg(sProcName,"A 32-bit Windows-based application")
      Case #SCS_64BIT_BINARY
        debugMsg(sProcName,"A 64-bit Windows-based application")
      Case #SCS_DOS_BINARY
        debugMsg(sProcName,"An MS-DOS-based application")
      Case #SCS_OS216_BINARY
        debugMsg(sProcName,"A 16-bit OS/2-based application")
      Case #SCS_PIF_BINARY
        debugMsg(sProcName,"A PIF file that executes an MS-DOS-based application")
      Case #SCS_POSIX_BINARY
        debugMsg(sProcName,"A POSIX-based application")
      Case #SCS_WOW_BINARY
        debugMsg(sProcName,"A 16-bit Windows-based application")
    EndSelect
  ElseIf idh\e_magic = $5A4D And GetBinaryType_(@lpApplicationName$,@lpBinaryType) = 0
    CopyMemory(PMapView+idh\e_lfanew, @INH,SizeOf(IMAGE_NT_HEADERS))
    If inh\Signature = $4550
      Select INH\FileHeader\Machine & $FFFF
        Case $014C
          debugMsg(sProcName,"A "+Str(32)+"-bit Windows DLL")
          nDLLType = 32
        Case $8664
          debugMsg(sProcName,"A "+Str(64)+"-bit Windows DLL")
          nDLLType = 64
      EndSelect
    EndIf
  Else
    debugMsg(sProcName,"Not a Windows DLL or EXE")
  EndIf
  CloseHandle_(hFile)
  CloseHandle_(hFileMap)
  UnmapViewOfFile_(PMapView)
  
  ProcedureReturn nDLLType
EndProcedure

; EOF
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 11
; Folding = -
; EnableThread
; EnableXP
; EnableOnError