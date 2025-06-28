; File: StartUp.pbi

EnableExplicit

Procedure AlreadyRunning() 
  ; check if the program is already running
  Protected App, bAlreadyRunning
  Protected sUniqueName.s
  
  sUniqueName = "MJD5837152678" + #SCS_TITLE
  App = CreateMutex_(#Null, 1, @sUniqueName) 
  If (App <> 0) And (GetLastError_() = #ERROR_ALREADY_EXISTS)
    CloseHandle_(App)
    bAlreadyRunning = #True
  EndIf
  ProcedureReturn bAlreadyRunning
EndProcedure 

Procedure getOSVersion()
  
  ; WARNING!! No calls to debugMsg() may be included in this procedure as it is called from initialisePart0() before it calls openLogFile().
  ;           This is because openLogFile() needs info from getOSVersioin().
  
  gnOSVersion = OSVersion()
  Select gnOSVersion
    Case #PB_OS_Windows_NT3_51
      gsOSVersion = "Windows NT 3_51"
    Case #PB_OS_Windows_95
      gsOSVersion = "Windows 95"
    Case #PB_OS_Windows_NT_4
      gsOSVersion = "Windows NT4"
    Case #PB_OS_Windows_98
      gsOSVersion = "Windows 98"
    Case #PB_OS_Windows_ME
      gsOSVersion = "Windows ME"
    Case #PB_OS_Windows_2000
      gsOSVersion = "Windows 2000"
    Case #PB_OS_Windows_XP
      gsOSVersion = "Windows XP"
    Case #PB_OS_Windows_Server_2003
      gsOSVersion = "Windows 2003"
    Case #PB_OS_Windows_Vista
      gsOSVersion = "Windows Vista"
    Case #PB_OS_Windows_Server_2008
      gsOSVersion = "Windows Server 2008"
    Case #PB_OS_Windows_7
      gsOSVersion = "Windows 7"
    Case #PB_OS_Windows_Server_2008_R2
      gsOSVersion = "Windows Server 2008 R2"
    Case #PB_OS_Windows_8
      gsOSVersion = "Windows 8"
    Case #PB_OS_Windows_Server_2012
      gsOSVersion = "Windows Server 2012"
    Case #PB_OS_Windows_8_1
      gsOSVersion = "Windows 8.1"
    Case #PB_OS_Windows_Server_2012_R2
      gsOSVersion = "Windows Server 2012 R2"
    Case #PB_OS_Windows_10
      gsOSVersion = "Windows 10"
    Case #PB_OS_Windows_11
      gsOSVersion = "Windows 11"
    Case #PB_OS_Windows_Future
      gsOSVersion = "Windows ?"
    Default
      gsOSVersion = "Windows OSVersion()=" + gnOSVersion
  EndSelect
  
EndProcedure

Procedure getLicLevel(sLicType.s)
  PROCNAMEC()
  Protected nLicLevel
  
  Select sLicType
    Case "Z", "H2", "H3", "H4", "HC", "NZ"
      nLicLevel = #SCS_LIC_PLAT
      
    Case "Q", "G2", "G3", "G4", "GC", "GS", "NQ"
      nLicLevel = #SCS_LIC_PLUS
      
    Case "P", "Y", "M2", "M3", "M4", "MC", "ES", "T", "NP"
      nLicLevel = #SCS_LIC_PRO
      
    Case "S", "NS", "F2", "F3", "F4", "FC", "FS"
      nLicLevel = #SCS_LIC_STD
      
    Case "L"
      nLicLevel = #SCS_LIC_LITE
      
    Case "W" ; Workshop
      nLicLevel = #SCS_LIC_PLUS
      
    Default
      nLicLevel = #SCS_LIC_DEMO
      
  EndSelect
  ; debugMsg(sProcName, "sLicType=" + sLicType + ", nLicLevel=" + Str(nLicLevel))
  
  ProcedureReturn nLicLevel
  
EndProcedure

Procedure.s getLicTypeCode(sLicType.s)
  PROCNAMEC()
  Protected sChar.s
  
  sChar = Left(sLicType, 1)
  Select sChar
    Case "E", "F", "G", "M", "N", "H"
      ProcedureReturn Left(sLicType, 2)
    Default
      ProcedureReturn Left(sLicType, 1)
  EndSelect
  
EndProcedure

Procedure.s comp92AuthString(pUserName.s, pType.s, pExpFactor = 0)
  CompilerIf #cDemo = #False And #cWorkshop = #False
    PROCNAMEC()
    Protected i, j, sChars.s, sLicTypeCode.s
    Protected qTemp.q, qTemp2.q, nChar
    Protected nCounter, nRem, nFactor
    Protected sTemp.s, sChar.s, sUserName.s, sType.s
    Protected nAscii.w
    Protected nAscA.w, nAscZ.w, nAsc0.w, nAsc9.w
    
    ; debugMsg(sProcName, #SCS_START + ", pUserName=" + pUserName + ", pType=" + pType + ", pExpFactor=" + Str(pExpFactor))
    nAscA = Asc("A")
    nAscZ = Asc("Z")
    nAsc0 = Asc("0")
    nAsc9 = Asc("9")
    
    sUserName = ""
    For i = 1 To Len(pUserName)
      sChar = UCase(Mid(pUserName, i, 1))
      nAscii = Asc(sChar)
      If (nAscii >= nAscA And nAscii <= nAscZ) Or (nAscii >= nAsc0 And nAscii <= nAsc9)
        sUserName = sUserName + sChar
      EndIf
    Next i
    
    sLicTypeCode = getLicTypeCode(pType)
    ; debugMsg(sProcName, "sLicTypeCode=" + sLicTypeCode)
    If sLicTypeCode = "L"
      nFactor = 155206
      sType = "LITE"
      
    ElseIf sLicTypeCode = "S"
      nFactor = 268546
      sType = "STD"
      
    ElseIf sLicTypeCode = "P"
      nFactor = 193734
      sType = "PRO"
      
    ElseIf sLicTypeCode = "M2"
      nFactor = 293734
      sType = "M2PRO"
    ElseIf sLicTypeCode = "M3"
      nFactor = 393734
      sType = "M3PRO"
    ElseIf sLicTypeCode = "M4"
      nFactor = 493734
      sType = "M4PRO"
    ElseIf sLicTypeCode = "MC"
      nFactor = 593734
      sType = "MCPRO"
    ElseIf sLicTypeCode = "ES"
      nFactor = 131465 + pExpFactor
      sType = "ESPRO"
      
    ElseIf sLicTypeCode = "Q"
      nFactor = 184733
      sType = "QPRO"
      
    ElseIf sLicTypeCode = "G2"
      nFactor = 284733
      sType = "G2PLU"
    ElseIf sLicTypeCode = "G3"
      nFactor = 384733
      sType = "G3PLU"
    ElseIf sLicTypeCode = "G4"
      nFactor = 484733
      sType = "G4PLU"
    ElseIf sLicTypeCode = "GC"
      nFactor = 584733
      sType = "GCPLU"
    ElseIf sLicTypeCode = "GS"
      nFactor = 597935 + pExpFactor
      sType = "GSPLU"
      
    ElseIf sLicTypeCode = "F2"
      nFactor = 299918
      sType = "F2STD"
    ElseIf sLicTypeCode = "F3"
      nFactor = 399918
      sType = "F3STD"
    ElseIf sLicTypeCode = "F4"
      nFactor = 499918
      sType = "F4STD"
    ElseIf sLicTypeCode = "FC"
      nFactor = 599918
      sType = "FCSTD"
    ElseIf sLicTypeCode = "FS"
      nFactor = 499930 + pExpFactor
      sType = "FSSTD"
      
    ElseIf sLicTypeCode = "T"
      nFactor = 258357
      sType = "TEMP"
      
    ElseIf sLicTypeCode = "NZ"
      nFactor = 171923 + pExpFactor
      sType = "NZ"
    ElseIf sLicTypeCode = "NQ"
      nFactor = 249249 + pExpFactor
      sType = "NQ"
    ElseIf sLicTypeCode = "NP"
      nFactor = 139849 + pExpFactor
      sType = "NP"
    ElseIf sLicTypeCode = "NS"
      nFactor = 302514 + pExpFactor
      sType = "NS"
      
    ElseIf sLicTypeCode = "Y"
      nFactor = 251038
      sType = "YPRO"
      
    ElseIf sLicTypeCode = "Z"
      nFactor = 371923
      sType = "PLAT"
    ElseIf sLicTypeCode = "H2"
      nFactor = 291923
      sType = "H2PLA"
    ElseIf sLicTypeCode = "H3"
      nFactor = 391923
      sType = "H3PLA"
    ElseIf sLicTypeCode = "H4"
      nFactor = 491923
      sType = "H4PLA"
    ElseIf sLicTypeCode = "HC"
      nFactor = 591923
      sType = "HCPLA"
      
    EndIf
    
    ; debugMsg(sProcName, "nFactor=" + Str(nFactor) + ", sType=" + sType)
    
    sUserName = sUserName + sType + sUserName
    ; debugMsg(sProcName, "sUserName=" + sUserName)
    
    qTemp = 0
    For i = 1 To Len(sUserName)
      nChar = Asc(UCase(Mid(sUserName, i, 1)))
      j = i % 8
      qTemp2 = nChar + j
      qTemp + (qTemp2 * nFactor)
      ; debugMsg(sProcName, "i=" + i + ", nChar=" + Str(nChar) + ", j=" + Str(j) + ", qTemp2=" + Str(qTemp2) + ", qTemp=" + Str(qTemp))
    Next i
    
    ; debugMsg(sProcName, "qTemp=" + Str(qTemp))
    
    sTemp = ""
    sChars = "PQRSEFGHABCDJKLMNTUVWXYZ"
    nCounter = 0
    While (qTemp > 0) And (nCounter < 12)
      nCounter + 1
      ; debugMsg(sProcName, "qTemp=" + Str(qTemp) + ", (qTemp / 24)=" + Str(qTemp / 24) + ", (qTemp / 5)=" + Str(qTemp / 5))
      nRem = qTemp - (24 * (qTemp / 24))
      qTemp = (qTemp / 5)
      sTemp + Mid(sChars, nRem + 1, 1)
      ; debugMsg(sProcName, "nRem=" + Str(nRem) + ", qTemp=" + Str(qTemp) + ", sTemp=" + sTemp)
      If nCounter = 4 Or nCounter = 8
        sTemp + "-"
      EndIf
    Wend
    
    ; debugMsg(sProcName, #SCS_END + " returning " + sTemp)
    ProcedureReturn sTemp
    
  CompilerEndIf
EndProcedure

Procedure setUpGENFonts()
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Int(gnDefFontSize * gdFontScale)
  debugMsg(sProcName, "gnDefFontSize=" + gnDefFontSize + ", gdFontScale=" + StrD(gdFontScale,4) + ", nNewFontSize=" + nNewFontSize)
  LoadFont(#SCS_FONT_GEN_NORMAL, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_NORMALSTRIKETHRU, gsDefFontName, nNewFontSize, #PB_Font_StrikeOut | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLD, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLDUL, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_Underline | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLDSTRIKETHRU, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_StrikeOut | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_ITALIC, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_UL, gsDefFontName, nNewFontSize, #PB_Font_Underline | #PB_Font_HighQuality)
  
  nNewFontSize = Int(7 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_NORMAL7, gsDefFontName, nNewFontSize, #PB_Font_HighQuality) ; used in WQF graph side-labels
  
  nNewFontSize = Int(9 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_NORMAL9, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLD9, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLDSTRIKETHRU9, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_StrikeOut | #PB_Font_HighQuality)
  
  nNewFontSize = Int(10 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_NORMAL10, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLD10, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_ITALIC10, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_UL10, gsDefFontName, nNewFontSize, #PB_Font_Underline | #PB_Font_HighQuality)
  
  nNewFontSize = Int(11 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_NORMAL11, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLD11, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)

  nNewFontSize = Int(12 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_NORMAL12, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_NORMALSTRIKETHRU12, gsDefFontName, nNewFontSize, #PB_Font_StrikeOut | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLD12, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_BOLDSTRIKETHRU12, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_StrikeOut | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_GEN_UL12, gsDefFontName, nNewFontSize, #PB_Font_Underline | #PB_Font_HighQuality)
  
  nNewFontSize = Int(16 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_ITALIC16, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
  
  nNewFontSize = Int(24 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_BOLD24, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  
  nNewFontSize = Int(gnDefFontSize * gdFontScale)
  LoadFont(#SCS_FONT_GEN_WINGDINGS8, "Wingdings", nNewFontSize, #PB_Font_HighQuality)
  nNewFontSize = Int(8 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_SYMBOL8, gsDefInfinityFontName, nNewFontSize, #PB_Font_HighQuality)
  nNewFontSize = Int(9 * gdFontScale)
  LoadFont(#SCS_FONT_GEN_SYMBOL9, gsDefInfinityFontName, nNewFontSize, #PB_Font_HighQuality)
  
  ; LoadFont(#SCS_FONT_GADGET, gsDefFontName, nNewFontSize)
  LoadFont(#SCS_FONT_GADGET, "Segoe UI", nNewFontSize, #PB_Font_HighQuality)
  
  If IsFont(#SCS_FONT_GEN_NORMAL)
    SetGadgetFont(#PB_Default, FontID(#SCS_FONT_GEN_NORMAL))
  EndIf
  
EndProcedure

Procedure setUpWMNFonts(bGrdCuesOnly=#False)
  PROCNAMEC()
  ; fonts used in fmMain (excluding cue panels) - names refer to the original settings, but the font sizes will be different when fmMain has been resized
  Protected nNewFontSize, fMyYFactor.f
  
  fMyYFactor = gfMainOrigYFactor
  
  If bGrdCuesOnly = #False
    nNewFontSize = Round(gnDefFontSize * fMyYFactor * gdFontScale, #PB_Round_Down)
    debugMsg(sProcName, "gnDefFontSize=" + gnDefFontSize + ", fMyYFactor=" + StrF(fMyYFactor,4) + ", gdFontScale=" + StrD(gdFontScale,4) + ", nNewFontSize=" + Str(nNewFontSize))
    LoadFont(#SCS_FONT_WMN_NORMAL, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
    debugMsg(sProcName, "#SCS_FONT_WMN_NORMAL fontsize=" + nNewFontSize)
    LoadFont(#SCS_FONT_WMN_BOLD, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
    LoadFont(#SCS_FONT_WMN_BOLDUL, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_Underline | #PB_Font_HighQuality)
    LoadFont(#SCS_FONT_WMN_ITALIC, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
    
    nNewFontSize = Round(9 * fMyYFactor * gdFontScale, #PB_Round_Down)
    LoadFont(#SCS_FONT_WMN_NORMAL9, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
    debugMsg(sProcName, "#SCS_FONT_WMN_NORMAL9 fontsize=" + nNewFontSize)
    LoadFont(#SCS_FONT_WMN_SYMBOL9, gsDefInfinityFontName, nNewFontSize, #PB_Font_HighQuality)
    
    nNewFontSize = Round(10 * fMyYFactor * gdFontScale, #PB_Round_Down)
    LoadFont(#SCS_FONT_WMN_NORMAL10, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
    debugMsg(sProcName, "#SCS_FONT_WMN_NORMAL10 fontsize=" + nNewFontSize)
    LoadFont(#SCS_FONT_WMN_BOLD10, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
    LoadFont(#SCS_FONT_WMN_ITALIC10, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
    
    nNewFontSize = Round(12 * fMyYFactor * gdFontScale, #PB_Round_Down)
    LoadFont(#SCS_FONT_WMN_BOLD12, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
    debugMsg(sProcName, "#SCS_FONT_WMN_BOLD12 fontsize=" + nNewFontSize)
    
    nNewFontSize = Round(16 * fMyYFactor * gdFontScale, #PB_Round_Down)
    LoadFont(#SCS_FONT_WMN_ITALIC16, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
    debugMsg(sProcName, "#SCS_FONT_WMN_ITALIC16 fontsize=" + nNewFontSize)
    
  EndIf
  
  If gbInOptionsWindow
    nNewFontSize = mrOperModeOptions(gnOperMode)\nCueListFontSize
  Else
    nNewFontSize = grOperModeOptions(gnOperMode)\nCueListFontSize
  EndIf
  If nNewFontSize <= 0
    nNewFontSize = Round(gnDefFontSize * fMyYFactor * gdFontScale, #PB_Round_Down)
  EndIf
  LoadFont(#SCS_FONT_WMN_GRDCUES, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  debugMsg(sProcName, "#SCS_FONT_WMN_GRDCUES fontsize=" + nNewFontSize)
  
EndProcedure

Procedure setUpCUEFonts(fReqdYFactor.f=0)
  PROCNAMEC()
  ; fonts used in excluding cue panels on fmMain - names refer to the original settings, but the font sizes will be different when cue panels are resized
  Protected nNewFontSize, fMyYFactor.f
  
  debugMsg(sProcName, #SCS_START + ", fReqdYFactor=" + StrF(fReqdYFactor,2))
  
  If fReqdYFactor = 0
    fMyYFactor = gfMainOrigYFactor
  Else
    fMyYFactor = fReqdYFactor
  EndIf
  
  nNewFontSize = Round(gnDefFontSize * fMyYFactor * gdFontScale, #PB_Round_Down)
  debugMsg(sProcName, "gnDefFontSize=" + gnDefFontSize + ", nNewFontSize=" + nNewFontSize + ", gdFontScale=" + StrD(gdFontScale,2))
  LoadFont(#SCS_FONT_CUE_NORMAL, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  debugMsg(sProcName, "#SCS_FONT_CUE_NORMAL fontsize=" + nNewFontSize)
  LoadFont(#SCS_FONT_CUE_BOLD, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_CUE_UNDERLINE, gsDefFontName, nNewFontSize, #PB_Font_Underline | #PB_Font_HighQuality)
  
  nNewFontSize = Round(9 * fMyYFactor * gdFontScale, #PB_Round_Down)
  LoadFont(#SCS_FONT_CUE_NORMAL9, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  debugMsg(sProcName, "#SCS_FONT_CUE_NORMAL9 fontsize=" + nNewFontSize)
  LoadFont(#SCS_FONT_CUE_ITALIC9, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_CUE_SYMBOL9, gsDefInfinityFontName, nNewFontSize, #PB_Font_HighQuality)
  
  nNewFontSize = Round(10 * fMyYFactor * gdFontScale, #PB_Round_Down)
  LoadFont(#SCS_FONT_CUE_NORMAL10, gsDefFontName, nNewFontSize, #PB_Font_HighQuality)
  debugMsg(sProcName, "#SCS_FONT_CUE_NORMAL10 fontsize=" + nNewFontSize)
  LoadFont(#SCS_FONT_CUE_BOLD10, gsDefFontName, nNewFontSize, #PB_Font_Bold | #PB_Font_HighQuality)
  LoadFont(#SCS_FONT_CUE_ITALIC10, gsDefFontName, nNewFontSize, #PB_Font_Italic | #PB_Font_HighQuality)
  
  grWMN\fYFactorForCuePanelFonts = fMyYFactor
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setUpWOPFonts()
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Int(gnDefFontSize * gdFontScale)
  LoadFont(#SCS_FONT_WOP_LISTS, gsDefFixedPitchFontName, nNewFontSize, #PB_Font_HighQuality)
  
EndProcedure

Procedure setUpWTCFont(fFontFactor.f)
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Round(36 * fFontFactor * gdFontScale, #PB_Round_Down)
  ; debugMsg(sProcName, "FontSize=36, nNewFontSize=" + Str(nNewFontSize))
  LoadFont(#SCS_FONT_WTC, "Verdana", nNewFontSize, #PB_Font_Bold) ; | #PB_Font_HighQuality)
  
EndProcedure

Procedure setUpWTIFont(fFontFactor.f)
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Round(36 * fFontFactor * gdFontScale, #PB_Round_Down)
  ; debugMsg(sProcName, "FontSize=36, nNewFontSize=" + Str(nNewFontSize))
  LoadFont(#SCS_FONT_WTI, "Verdana", nNewFontSize, #PB_Font_Bold) ; | #PB_Font_HighQuality)
  
EndProcedure

Procedure setUpWNEFont(fFontFactor.f)
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Round(36 * fFontFactor * gdFontScale, #PB_Round_Down)
  ; debugMsg(sProcName, "FontSize=36, nNewFontSize=" + Str(nNewFontSize))
  LoadFont(#SCS_FONT_WNE, "Verdana", nNewFontSize, #PB_Font_Bold) ; | #PB_Font_HighQuality)
  
EndProcedure

Procedure setUpWCLFont(fFontFactor.f)
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Round(36 * fFontFactor * gdFontScale, #PB_Round_Down)
  ; debugMsg(sProcName, "FontSize=36, nNewFontSize=" + Str(nNewFontSize))
  LoadFont(#SCS_FONT_WCL, "Verdana", nNewFontSize, #PB_Font_Bold) ; | #PB_Font_HighQuality)
  
EndProcedure

Procedure setUpWCDFont(fFontFactor.f)
  PROCNAMEC()
  Protected nNewFontSize
  
  nNewFontSize = Round(36 * fFontFactor * gdFontScale, #PB_Round_Down)
  ; debugMsg(sProcName, "FontSize=36, nNewFontSize=" + Str(nNewFontSize))
  LoadFont(#SCS_FONT_WCD, "Verdana", nNewFontSize, #PB_Font_Bold) ; | #PB_Font_HighQuality)
  
EndProcedure

Procedure.s scramb(strString.s)
  PROCNAMEC()
  Protected n, even.s, odd.s
  
  For n = 1 To Len(strString)
    If n % 2 = 0
      even + Mid(strString, n, 1)
    Else
      odd + Mid(strString, n, 1)
    EndIf
  Next n
  ; debugMsg3(sProcName, "strString=" + strString)
  ; debugMsg3(sProcName, "returning " + even + odd)
  ProcedureReturn even + odd
EndProcedure

Procedure.s unscramb(strString.s)
  PROCNAMEC()
  Protected n, evenint, oddint
  Protected even.s, odd.s, fin.s
  
  n = Len(strString) >> 1
  even = Mid(strString, 1, n)
  odd = Mid(strString, n + 1)
  For n = 1 To Len(strString)
    If n % 2 = 0
      evenint + 1
      fin + Mid(even, evenint, 1)
    Else
      oddint + 1
      fin + Mid(odd, oddint, 1)
    EndIf
  Next n
  ; debugMsg3(sProcName, "strString=" + strString)
  ; debugMsg3(sProcName, "returning " + fin)
  ProcedureReturn fin
EndProcedure

Procedure.s encryptRegKey(pPlain.s, pEncKey.s)
  PROCNAMEC()
  Protected sPlain.s
  Protected nAdjLetter.i
  Protected sAdjLetter.s
  Protected sLetter.s
  Protected sKeyNum.s
  Protected sEncStr.s
  Protected sTemp.s
  Protected sTemp2.s
  Protected nTempNum.i
  Protected nMath.i
  Protected m.i
  Protected n.i
  Dim encKEY(Len(pEncKey))
  
  For n = 1 To Len(pEncKey)       ;starts the values for the Encryption Key
    sKeyNum = Mid(pEncKey, n, 1)  ;gets the letter at index n
    encKEY(n) = Asc(sKeyNum)      ;sets the the Array value to ASC number for the letter
    If n = 1
      nMath = encKEY(n)           ;This is the first letter so just hold the value
    Else
      If n >= 2 And nMath - encKEY(n) >= 0 And encKEY(n) <= encKEY(n - 1)
        nMath - encKEY(n) ; compares the value to the previous value and then either adds/subtracts the value to the Math total
      EndIf
      If n >= 2 And nMath - encKEY(n) >= 0 And encKEY(n) <= encKEY(n - 1)
        nMath - encKEY(n)
      EndIf
      If n >= 2 And encKEY(n) >= nMath And encKEY(n) >= encKEY(n - 1)
        nMath + encKEY(n)
      EndIf
      If n >= 2 And encKEY(n) < nMath And encKEY(n) >= encKEY(n - 1)
        nMath + encKEY(n)
      EndIf
    EndIf
  Next n
  
  ; debugMsg(sProcName, "pEncKey=" + pEncKey + ", nMath=" + Str(nMath))
  
  sPlain = scramb(pPlain)
  ; debugMsg(sProcName, "pPlain=" + pPlain + ", sPlain=" + sPlain)
  For n = 1 To Len(sPlain)                                ;Now for the string to be encrypted
    sLetter = Mid(sPlain, n, 1)                           ;sets sLetter to the letter at index n
    nAdjLetter = Asc(sLetter) + nMath                     ;set nAdjLetter to the Asc value of sLetter + nMath (from the Key)
    sAdjLetter = Str(nAdjLetter)
    ; debugMsg(sProcName, "n=" + n + ", sLetter=" + sLetter + ", sAdjLetter=" + sAdjLetter)
    sTemp + Str(Len(sAdjLetter)) + sAdjLetter + " "
  Next n
  ; If Len(sTemp) % 2 = 1
    ; sTemp + "0"
  ; EndIf
  ; debugMsg(sProcName, "sTemp=" + sTemp)
  
  sTemp = ReplaceString(sTemp, " ", "")
  
  ; debugMsg(sProcName, "gs100Chars=" + gs100Chars)
  For n = 1 To Len(sTemp) Step 2
    m = Val(Mid(sTemp, n, 2)) + 1
    ; debugMsg(sProcName, "Mid(sTemp, " + n + ", 2)=" + Mid(sTemp, n, 2) + ", m=" + m)
    sEncStr + Mid(gs100Chars, m, 1)
  Next n
  
  ; debugMsg(sProcName, "sEncStr=" + sEncStr)
  
  ProcedureReturn sEncStr
  
EndProcedure

Procedure.s decryptRegKey(pEncrypted.s, pEncKey.s)
  PROCNAMEC()
  Protected sPlain.s
  Protected sLetter.s
  Protected sKeyNum.s
  Protected sTemp.s
  Protected sTemp2.s
  Protected nItemLength.i
  Protected nItemValue.i
  Protected nTempNum.i
  Protected nMath.i
  Protected m.i
  Protected n.i
  Dim encKEY(Len(pEncKey))
  
  debugMsgAS(sProcName, #SCS_START + ", pEncrypted=" + pEncrypted)
  
  For n = 1 To Len(pEncKey)       ;starts the values for the Encryption Key
    sKeyNum = Mid(pEncKey, n, 1)  ;gets the letter at index n
    encKEY(n) = Asc(sKeyNum)      ;sets the the Array value to ASC number for the letter
    If n = 1
      nMath = encKEY(n)           ;This is the first letter so just hold the value
    Else
      If n >= 2 And nMath - encKEY(n) >= 0 And encKEY(n) <= encKEY(n - 1)
        nMath - encKEY(n) ; compares the value to the previous value and then either adds/subtracts the value to the Math total
      EndIf
      If n >= 2 And nMath - encKEY(n) >= 0 And encKEY(n) <= encKEY(n - 1)
        nMath - encKEY(n)
      EndIf
      If n >= 2 And encKEY(n) >= nMath And encKEY(n) >= encKEY(n - 1)
        nMath + encKEY(n)
      EndIf
      If n >= 2 And encKEY(n) < nMath And encKEY(n) >= encKEY(n - 1)
        nMath + encKEY(n)
      EndIf
    EndIf
  Next n
  
  debugMsgAS(sProcName, "pEncKey=" + pEncKey + ", nMath=" + Str(nMath))
  debugMsgAS(sProcName, "gs100Chars=" + gs100Chars)
  
  For n = 1 To Len(pEncrypted)
    sTemp = Mid(pEncrypted, n, 1)
    m = FindString(gs100Chars, sTemp, 1) - 1
    ; debugMsg(sProcName, "sTemp=" + sTemp + ", m=" + m)
    If m >= 0
      sTemp2 + FormatUsingL(m, "00")
    EndIf
  Next n
  ; debugMsg(sProcName, "sTemp2=" + sTemp2)
  
  For n = 1 To Len(sTemp2)
    nItemLength = Val(Mid(sTemp2, n, 1))
    n + 1
    nItemValue = Val(Mid(sTemp2, n, nItemLength))
    ; debugMsg(sProcName, "n=" + Str(n-1) + ", nItemLength=" + Str(nItemLength) + ", nItemValue=" + Str(nItemValue))
    nItemValue - nMath
    sLetter = Chr(nItemValue)
    ; debugMsg(sProcName, "nItemValue=" + Str(nItemValue) + ", sLetter=" + sLetter)
    sPlain + sLetter
    n + nItemLength - 1   ; -1 because 'for' loop will add 1
  Next n
  
  debugMsgAS(sProcName, "sPlain=" + sPlain)
  sPlain = unscramb(sPlain)
  debugMsgAS(sProcName, "sPlain=" + sPlain)
  
  debugMsgAS(sProcName, #SCS_END + ", returning " + sPlain)
  ProcedureReturn sPlain
  
EndProcedure

Procedure unpackRegKey(sRegKey.s)
  PROCNAMEC()
  Protected sDecoded.s
  Protected nNameLen, nAuthLen
  Protected nDecodedLen, nPos
  Protected myLicInfo.tyLicInfo
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  debugMsgAS(sProcName, #SCS_START + ", sRegKey=" + sRegKey)
  
  myLicInfo = grLicInfo
  
  With myLicInfo
    nPos = 1
    debugMsgAS(sProcName, "hexStringToString(sRegKey)=" + hexStringToString(sRegKey))
    sDecoded = decryptRegKey(hexStringToString(sRegKey), #SCS_ENCRYPTION_KEY)
    nDecodedLen = Len(sDecoded)
    debugMsgAS(sProcName, "sDecoded=" + sDecoded)
    debugMsgAS(sProcName, "nDecodedLen=" + nDecodedLen)
    
    If nDecodedLen < 17
      ProcedureReturn #False
    EndIf
    
    CompilerIf #cDemo
      \sRegisteredLicType = "D"
      nPos + 1
    CompilerElseIf #cWorkshop
      \sRegisteredLicType = "W"
      nPos + 1
    CompilerElse
      Select Left(sDecoded, 1)
        Case "E", "M", "G", "F", "N", "H"
          \sRegisteredLicType = Left(sDecoded, 2)
          nPos + 2
        Default
          \sRegisteredLicType = Left(sDecoded, 1)
          nPos + 1
      EndSelect
    CompilerEndIf
    
    nNameLen = Val(Mid(sDecoded, nPos, 3))
    nPos + 3
    debugMsgAS(sProcName, "nNameLen=" + nNameLen)
    If nNameLen < 1 Or nNameLen > (nDecodedLen - nPos)
      ProcedureReturn #False
    EndIf
    \sLicUser = Mid(sDecoded, nPos, nNameLen)
    If icu(\sLicUser, \sAuthString) = #False
      debugMsg(sProcName, "iu")
      ProcedureReturn #False
    EndIf
    nPos + nNameLen
    debugMsgAS(sProcName, "\sLicUser=" + \sLicUser)
    
    \sLicType = \sRegisteredLicType
    
    debugMsgAS(sProcName, "\sLicType=" + \sLicType)
    Select \sLicType
      Case "E2"
        \sLicType = "M2"
      Case "EC"
        \sLicType = "MC"
      Case "D", "L", "S", "P", "T", "Y", "Q", "NP", "NS", "NQ", "M2", "M3", "M4", "MC", "ES", "F2", "F3", "F4", "FC", "FS", "G2", "G3", "G4", "GC", "GS", "Z", "H2", "H3", "H4", "HC", "NZ"
        ; OK
      Case "W" ; Workshop
        ; OK
      Default
        ProcedureReturn #False
    EndSelect
    
    debugMsgAS(sProcName, "Mid(" + #DQUOTE$ + sDecoded + #DQUOTE$ + ", " + nPos + ", 2)=" + Mid(sDecoded, nPos, 2))
    nAuthLen = Val(Mid(sDecoded, nPos, 2))
    nPos + 2
    debugMsgAS(sProcName, "nAuthLen=" + nAuthLen)
    If \sLicType = "D" And nAuthLen = 0
      \sAuthString = ""
    ElseIf \sLicType = "W" And nAuthLen = 0
      \sAuthString = ""
    ElseIf nAuthLen < 10 Or nAuthLen > (nDecodedLen - nPos + 1)
      debugMsgAS(sProcName, "nPos=" + nPos)
      ProcedureReturn #False
    Else
      If nAuthLen = 12
        \sAuthString = Mid(sDecoded, nPos, 4) + "-" + Mid(sDecoded, nPos + 4, 4) + "-" + Mid(sDecoded, nPos + 8, nAuthLen - 8)
        \sExpString = ""
      Else
        \sAuthString = Mid(sDecoded, nPos, 4) + "-" + Mid(sDecoded, nPos + 4, 4) + "-" + Mid(sDecoded, nPos + 8, 4)
        \sExpString = Mid(sDecoded, nPos + 12, nAuthLen - 12)
        \dLicExpDate = decodeExpString(\sExpString, @\nExpFactor)
      EndIf
    EndIf
    nPos + nAuthLen
    debugMsgAS(sProcName, "\sAuthString=" + \sAuthString + ", \sExpString=" + \sExpString + ", \dLicExpDate=" + \dLicExpDate + ", \nExpFactor=" + \nExpFactor)
    
    CompilerIf #cDemo = #False And #cWorkshop = #False
      debugMsgAS(sProcName, "comp92AuthString(" + \sLicUser + ", " + \sRegisteredLicType + ", " + \nExpFactor + ")=" + comp92AuthString(\sLicUser, \sRegisteredLicType, \nExpFactor))
      If \sAuthString <> comp92AuthString(\sLicUser, \sRegisteredLicType, \nExpFactor)
        ProcedureReturn #False
      EndIf
      \nLicLevel = getLicLevel(\sLicType)
      debugMsgAS(sProcName, "\sLicType=" + \sLicType + ", \nLicLevel=" + \nLicLevel)
    CompilerEndIf
    
    If \sLicType = "D" Or \sLicType = "T" Or \sLicType = "W"
      \nExpireDate = Val(Mid(sDecoded, nPos, 5))
      debugMsgAS(sProcName, "\nExpireDate=" + \nExpireDate)
      nPos + 6
      If \sLicType = "T"
        \nStartsLeft = Val(Mid(sDecoded, nPos, 3))
        nPos + 4
      EndIf
    EndIf
    debugMsgAS(sProcName, "\nExpireDate=" + \nExpireDate + ", \nStartsLeft=" + \nStartsLeft)
    
  EndWith
  
  grLicInfo = myLicInfo
  
  debugMsgAS(sProcName, "grLicInfo\sAuthStringHold=" + grLicInfo\sAuthStringHold)
  
  ProcedureReturn #True
  
EndProcedure

;- License limits
Procedure setLicLimitsEtc()
  PROCNAMEC()
  Protected n
  
  populateCueTypeArray()
  
  With grLicInfo
    
    debugMsg(sProcName, "grLicInfo\sLicType=" + \sLicType + ", \sLicUser=" + \sLicUser + ", \nLicLevel=" + \nLicLevel)
    
    ; Cards / Channel Pairs selectable
    ; Demo: 2, Lite: 1, Std: 2, Pro: 8, ProPlus: 16
    ; nMaxAudDevPerProd is 0-based so is one less than above
    If \sLicType = "D"
      \nMaxAudioOutputs = 4     ; actual count, so 1 based
      \nMaxVideoAudioOutputs = 1 ; added 4Mar2021 11.8.4
      \nMaxAudDevPerAud = 1     ; 0 based
      \nMaxCtrlSendDevs = 1     ; actual count
      \nMaxCtrlSendDevPerSub = 0
      \nMaxLiveInputs = 0       ; actual count    
      \nMaxLiveDevPerAud = -1
      \nMaxInGrps = 0
      \nMaxCueCtrlDev = 0
      \bCCDMXAvailable = #True
      \bDMXSendAvailable = #True
      \nMaxDMXPort = 1
      \nMaxDMXChannel = 32
      \nMaxDMXItemPerLightingSub = 7
      \nMaxFixtureItemPerLightingSub = 15
      \bCueTypeKAvailable = #True
      \nMaxLightingDevPerProd = 1   ; This represents 2 devices because it starts counting at 0
      \nMaxLightingDevPerSub = 0
      \nMaxChaseSteps = 4
      \nMaxFixTypes = 8
      \nMaxVideoCaptureDevs = 1
      
    Else
      
      Select \nLicLevel
        Case #SCS_LIC_LITE
          \nMaxAudioOutputs = 2
          \nMaxVideoAudioOutputs = 0
          \nMaxAudDevPerAud = 1 ; was 0
          \nMaxCtrlSendDevs = 0
          \nMaxCtrlSendDevPerSub = -1
          \nMaxLiveInputs = 0
          \nMaxLiveDevPerAud = -1
          \nMaxInGrps = 0
          \nMaxCueCtrlDev = -1
          \bCCDMXAvailable = #False
          \bDMXSendAvailable = #False
          \nMaxDMXPort = 0
          \nMaxDMXChannel = 0
          \bCueTypeKAvailable = #False
          \nMaxLightingDevPerProd = -1
          \nMaxLightingDevPerSub = -1
          
        Case #SCS_LIC_STD
          \nMaxAudioOutputs = 4
          \nMaxVideoAudioOutputs = 2
          \nMaxAudDevPerAud = 3 ; was 1
          \nMaxCtrlSendDevs = 0
          \nMaxCtrlSendDevPerSub = -1
          \nMaxLiveInputs = 0
          \nMaxLiveDevPerAud = -1
          \nMaxInGrps = 0
          \nMaxCueCtrlDev = -1
          \bCCDMXAvailable = #False
          \bDMXSendAvailable = #False
          \nMaxDMXPort = 0
          \nMaxDMXChannel = 0
          \bCueTypeKAvailable = #False
          \nMaxLightingDevPerProd = -1
          \nMaxLightingDevPerSub = -1
          
        Case #SCS_LIC_PRO
          \nMaxAudioOutputs = 16
          \nMaxVideoAudioOutputs = 8
          \nMaxVideoCaptureDevs = 2
          \nMaxAudDevPerAud = 15 ; was 7
          \nMaxCtrlSendDevs = 4
          \nMaxCtrlSendDevPerSub = 3
          \nMaxLiveInputs = 16
          \nMaxLiveDevPerAud = 7
          \nMaxInGrps = 8
          \nMaxCueCtrlDev = 3 ; Was 1 (ie max 2 cue control devices) in SCS 11.10.3 and earlier versions, but email from Scott Seigwald identified the fact that the documentation implies that 4 devices (C1-C4) are available.
                              ; Confirmed that nowhere in the Help does it mention a limit of 2 devices for SCS Professional, so now increased to allow for 4 devices.
          \bCCDMXAvailable = #False
          \bDMXSendAvailable = #True
          \nMaxDMXPort = 1
          \nMaxDMXChannel = 32
          \nMaxDMXItemPerLightingSub = 7
          \nMaxFixtureItemPerLightingSub = 23
          \bCueTypeKAvailable = #True
          \nMaxLightingDevPerProd = 0 ; This represents 1 device because it starts counting at 0
          \nMaxLightingDevPerSub = 0
          \nMaxChaseSteps = 8
          \nMaxFixTypes = 16
          
        Case #SCS_LIC_PLUS
          \nMaxAudioOutputs = 32
          \nMaxVideoAudioOutputs = 16
          \nMaxVideoCaptureDevs = 4
          \nMaxAudDevPerAud = 15
          \nMaxCtrlSendDevs = 8
          \nMaxCtrlSendDevPerSub = 7
          \nMaxLiveInputs = 32
          \nMaxLiveDevPerAud = 15
          \nMaxInGrps = 16
          \nMaxCueCtrlDev = 3
          \bCCDMXAvailable = #True
          \bDMXSendAvailable = #True
          \nMaxDMXPort = 8
          \nMaxDMXChannel = 512
          \nMaxDMXItemPerLightingSub = #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB
          \nMaxFixtureItemPerLightingSub = #SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB
          \bCueTypeKAvailable = #True
          \nMaxLightingDevPerProd = 1   ; This represents 2 devices because it starts counting at 0
          \nMaxLightingDevPerSub = 0
          \nMaxHotkeyBank = 6
          \nMaxChaseSteps = 24
          \nMaxFixTypes = 16
          
        Case #SCS_LIC_PLAT
          If gbUseSMS
            \nMaxAudioOutputs = 512
            \nMaxLiveInputs = 512
          Else
            \nMaxAudioOutputs = 32
            \nMaxLiveInputs = 32
          EndIf
          \nMaxLiveDevPerAud = 15
          \nMaxInGrps = 16
          \nMaxAudDevPerAud = 15
          \nMaxCueCtrlDev = 3
          \nMaxCtrlSendDevs = 256 ; increased from 16 12Apr2022 11.10.0 following request from Jason Mai (email 31Mar2022)
          \nMaxCtrlSendDevPerSub = 15
          \nMaxVideoAudioOutputs = 16
          \nMaxVideoCaptureDevs = 4
          \bCCDMXAvailable = #True
          \bDMXSendAvailable = #True
          \nMaxDMXPort = 8
          \nMaxDMXChannel = 512
          \nMaxDMXItemPerLightingSub = #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB
          \nMaxFixtureItemPerLightingSub = #SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB
          \bCueTypeKAvailable = #True
          \nMaxLightingDevPerProd = 1   ; This represents 2 devices because it starts counting at 0
          \nMaxLightingDevPerSub = 0
          \nMaxHotkeyBank = 12
          \nMaxChaseSteps = 24
          \nMaxFixTypes = 32
          
      EndSelect
    EndIf
    
    If \nLicLevel >= #SCS_LIC_STD
      \bASIOAvailable = #True
      \bAudFileLoopsAvailable = #True
      \bStartEndAvailable = #True
      \bCueMarkersAvailable = #True
      \bStepHotkeysAvailable = #True
      \bProductionTimerAvailable = #True
      \bTimeProfilesAvailable = #True
    EndIf
    
    If \nLicLevel >= #SCS_LIC_PRO
      \bExternalEditorsIncluded = #True
      \bImportCSVAvailable = #True
      \bImportDevsAvailable = #True
      \bSMSAvailable = #True
      \bStdLvlPtsAvailable = #True
      \bCSRDAvailable = #True
      \bTempoAndPitchAvailable = #True
      \bExtFaderCueControlAvailable = #True ; Moved from PLUS 21Mar2024 11.10.2bi following email from Bart Rawoe (Theater Frappant) and then finding the Help file states that 'Lighting Control by External Fader' is available in PRO And higher
    EndIf
    
    If \nLicLevel >= #SCS_LIC_PLUS
      \bCueStartConfirmationAvailable = #True
      CompilerIf #c_cuepanel_multi_dev_select
        \bDevLinkAvailable = #True
      CompilerEndIf
      \bFMAvailable = #True
      \bVSTPluginsAvailable = #True
      \nMaxVSTDevPlugin = #SCS_MAX_VST_DEV_PLUGIN
      \nLastVideoWindowNo = #WV_LAST
      \nLastMonitorWindowNo = #WM_LAST
      \nLastVidPicTarget = #SCS_VID_PIC_TARGET_LAST
      ; NB see also #cMaxScreenNo
      \bDMXCaptureAvailable = #True
      \bM2TAvailable = #True
      ; \bExtFaderCueControlAvailable = #True ; Moved to PRO 21Mar2024 11.10.2bi following email from Bart Rawoe (Theater Frappant) and then finding the Help file states that 'Lighting Control by External Fader' is available in PRO And higher
      \bHKClickAvailable = #True
    Else
      \nMaxVSTDevPlugin = -1
      \nLastVideoWindowNo = #WV5
      \nLastMonitorWindowNo = #WM5
      \nLastVidPicTarget = #SCS_VID_PIC_TARGET_F5
    EndIf
    
    If \nLicLevel >= #SCS_LIC_PLAT
      \bLTCAvailable = #True
      \bLockAudioToLTCAvailable = #True
    EndIf
    ; NOTE enable "staatstheater-darmstadt" to use LTC even though they have an SCS Plus license, not a Platinum license
    If LCase(Left(\sLicUser,23)) = "staatstheater-darmstadt"
      \bLTCAvailable = #True
    EndIf
    
    CompilerIf #c_include_tvg = #False
      \nMaxVideoCaptureDevs = 0
    CompilerEndIf
    
    \nMaxAudDevPerSub = \nMaxAudDevPerAud
    \nMaxAudDevPerProd = \nMaxAudioOutputs - 1
    \nMaxVidAudDevPerProd = \nMaxVideoAudioOutputs - 1
    \nMaxVidCapDevPerProd = \nMaxVideoCaptureDevs - 1
    \nMaxCtrlSendDevPerProd = \nMaxCtrlSendDevs - 1
    \nMaxLiveDevPerProd = \nMaxLiveInputs - 1
    \nMaxInGrpPerProd = \nMaxInGrps - 1
    \nMaxInGrpItemPerInGrp = \nMaxLiveDevPerProd
    \nMaxFixTypePerProd = \nMaxFixTypes - 1
    
    gnMaxPreOpenAudioFilesForLicLevel = 99 ; 80 ; Changed 21Mar2022 11.9.1aq to be the same as the maximium for video/iamge files (set in the next line)
    gnMaxPreOpenVideoImageFilesForLicLevel = 99 ; 30 ; Changed 12Mar2022 11.9.1aj following email from Christopher Long
    
    gnMaxMidiCommand = #SCS_MAX_MIDI_COMMAND
    
    For n = 0 To #SCS_MAX_MENU_ITEM
      gbMenuItemAvailable(n) = #True
      gbMenuItemEnabled(n) = #True
    Next n
    debugMsg(sProcName, "grLicInfo\nLicLevel=" + grLicInfo\nLicLevel)
    If \nLicLevel < #SCS_LIC_STD
      gbMenuItemAvailable(#WED_mnuAddQA) = #False
      gbMenuItemAvailable(#WED_mnuAddSA) = #False
      gbMenuItemAvailable(#WED_mnuAddQL) = #False
      gbMenuItemAvailable(#WED_mnuAddSL) = #False
      gbMenuItemAvailable(#WED_mnuAddQN) = #False
      gbMenuItemAvailable(#WED_mnuAddQP) = #False
      gbMenuItemAvailable(#WED_mnuAddSP) = #False
      
      gbMenuItemAvailable(#WED_mnuFavAddQA) = #False
      gbMenuItemAvailable(#WED_mnuFavAddSA) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQL) = #False
      gbMenuItemAvailable(#WED_mnuFavAddSL) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQN) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQP) = #False
      gbMenuItemAvailable(#WED_mnuFavAddSP) = #False
    EndIf
    If \nLicLevel < #SCS_LIC_PRO
      gbMenuItemAvailable(#WED_mnuAddQE) = #False   ; 'memo' cue
      gbMenuItemAvailable(#WED_mnuAddSE) = #False
      gbMenuItemAvailable(#WED_mnuAddQG) = #False   ; 'go to' cue
      gbMenuItemAvailable(#WED_mnuAddSG) = #False
      gbMenuItemAvailable(#WED_mnuAddQI) = #False   ; 'live input' cue
      gbMenuItemAvailable(#WED_mnuAddSI) = #False
      gbMenuItemAvailable(#WED_mnuAddQM) = #False   ; 'control send' cue
      gbMenuItemAvailable(#WED_mnuAddSM) = #False
      gbMenuItemAvailable(#WED_mnuAddQR) = #False   ; 'run external program' cue
      gbMenuItemAvailable(#WED_mnuAddSR) = #False
      gbMenuItemAvailable(#WED_mnuAddQT) = #False   ; 'set position' cue
      gbMenuItemAvailable(#WED_mnuAddST) = #False
      gbMenuItemAvailable(#WED_mnuAddQU) = #False   ; 'MTC' cue
      gbMenuItemAvailable(#WED_mnuAddSU) = #False
      gbMenuItemAvailable(#WED_mnuAddQQ) = #False   ; 'Call Cue' cue
      gbMenuItemAvailable(#WED_mnuAddSQ) = #False
      gbMenuItemAvailable(#WED_mnuAddQJ) = #False   ; 'enable/disable cues' cue
      gbMenuItemAvailable(#WED_mnuAddSJ) = #False
      
      gbMenuItemAvailable(#WED_mnuFavAddQG) = #False   ; 'go to' cue
      gbMenuItemAvailable(#WED_mnuFavAddSG) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQI) = #False   ; 'live input' cue
      gbMenuItemAvailable(#WED_mnuFavAddSI) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQM) = #False   ; 'control send' cue
      gbMenuItemAvailable(#WED_mnuFavAddSM) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQE) = #False   ; 'memo' cue
      gbMenuItemAvailable(#WED_mnuFavAddSE) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQR) = #False   ; 'run external program' cue
      gbMenuItemAvailable(#WED_mnuFavAddSR) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQT) = #False   ; 'set position' cue
      gbMenuItemAvailable(#WED_mnuFavAddST) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQQ) = #False   ; 'Call Cue' cue
      gbMenuItemAvailable(#WED_mnuFavAddSQ) = #False
      gbMenuItemAvailable(#WED_mnuFavAddQU) = #False   ; 'MTC' cue
      gbMenuItemAvailable(#WED_mnuFavAddSU) = #False
    EndIf
    ; debugMsg(sProcName, "\bCueTypeKAvailable=" + strB(\bCueTypeKAvailable))
    If \bCueTypeKAvailable = #False
      gbMenuItemAvailable(#WED_mnuAddQK) = #False   ; 'lighting' cue
      gbMenuItemAvailable(#WED_mnuAddSK) = #False
    EndIf
    
  EndWith
  
  If grLicInfo\nMaxVidAudDevPerProd >= 0
    With grProdDefForAdd\aVidAudLogicalDevs(0)
      \nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
      \sVidAudLogicalDev = Lang("Init", "DefVidAudDev")
      \nNrOfOutputChans = 2
      \bAutoInclude = #True
      gnNextDevId + 1
      \nDevId = gnNextDevId
      grProdDefForAdd\nMaxVidAudLogicalDev = 0
    EndWith
    REDIM_ARRAY2(grProdDefForAdd\aVidAudLogicalDevs, 1, grVidAudLogicalDevsDef)
  EndIf
  
EndProcedure

Procedure loadRegKeyFileArray()
  PROCNAMEC()
  Protected sExtPart.s, sRegKeyFile.s, sLine.s
  Protected nDirNo, nReadFileNo
  Protected n
  Protected bObsoleteRegKeyFileExists
  
  gnMaxRegKeyFile = -1
  sExtPart = GetExtensionPart(#SCS_PREFS_FILE_COMMON) ; will be scscp, scscd (for demo) or scsdw (for workshop)
  nDirNo = ExamineDirectory(#PB_Any, gsCommonAppDataPath, "*." + sExtPart)
  debugMsgAS(sProcName, "ExamineDirectory(#PB_Any, " + #DQUOTE$ + gsCommonAppDataPath + #DQUOTE$ + ", " + #DQUOTE$ + "*." + sExtPart + #DQUOTE$ + ") returned nDirNo=" + nDirNo)
  If nDirNo
    While NextDirectoryEntry(nDirNo)
      If DirectoryEntryType(nDirNo) = #PB_DirectoryEntry_File
        sRegKeyFile = DirectoryEntryName(nDirNo)
        debugMsgAS(sProcName, "sRegKeyFile=" + #DQUOTE$ + sRegKeyFile + #DQUOTE$)
        ; Added 4Mar2024 11.10.2ba
        If sRegKeyFile = "scs11." + sExtPart
          bObsoleteRegKeyFileExists = #True ; obsolete because no date info encrypted into the filename
        EndIf
        ; End added 4Mar2024 11.10.2ba
        gnMaxRegKeyFile + 1
        If gnMaxRegKeyFile > ArraySize(gaRegKeyFile())
          ReDim gaRegKeyFile(gnMaxRegKeyFile)
        EndIf
        With gaRegKeyFile(gnMaxRegKeyFile)
          \sRegKeyFolder = gsCommonAppDataPath
          \sRegKeyFile = sRegKeyFile
          nReadFileNo = ReadFile(#PB_Any, gsCommonAppDataPath + sRegKeyFile)
          debugMsgAS(sProcName, "ReadFile(#PB_Any, " + #DQUOTE$ + gsCommonAppDataPath + sRegKeyFile + #DQUOTE$ + ") returned nReadFileNo=" + nReadFileNo)
          If nReadFileNo
            While Eof(nReadFileNo) = 0
              sLine = ReadString(nReadFileNo)
              debugMsgAS(sProcName, "sLine=" + #DQUOTE$ + sLine + #DQUOTE$)
              If Left(sLine,6) = "CFDate"
                \qCFDate = Val(Trim(StringField(sLine, 2, "=")))
                debugMsgAS(sProcName, "gaRegKeyFile(" + gnMaxRegKeyFile + ")\qCFDate=" + \qCFDate)
              EndIf
              If Left(sLine,11) = "CommonFlags"
                \sRegKey = Trim(StringField(sLine, 2, "="))
                debugMsgAS(sProcName, "gaRegKeyFile(" + gnMaxRegKeyFile + ")\sRegKey=" + #DQUOTE$ + \sRegKey + #DQUOTE$)
              EndIf
            Wend
            CloseFile(nReadFileNo)
          EndIf
        EndWith
      EndIf ; EndIf DirectoryEntryType(nDirNo) = #PB_DirectoryEntry_File
    Wend ; End While NextDirectoryEntry(nDirNo)
    FinishDirectory(nDirNo)
  EndIf ; EndIf nDirNo
  
  If gnMaxRegKeyFile > 0
    If ArraySize(gaRegKeyFile()) > gnMaxRegKeyFile
      ReDim gaRegKeyFile(gnMaxRegKeyFile)
    EndIf
    SortStructuredArray(gaRegKeyFile(), #PB_Sort_Descending, OffsetOf(tyRegKeyFile\qCFDate), #PB_Quad)
  EndIf
  
  For n = 0 To gnMaxRegKeyFile
    With gaRegKeyFile(n)
      debugMsgAS(sProcName, "gaRegKeyFile(" + n + ")\sRegKeyFile=" + #DQUOTE$ + \sRegKeyFile + #DQUOTE$ + ", \qCFDate=" + \qCFDate + ", \sRegKey=" + \sRegKey)
    EndWith
  Next n
  
  ; Added 2Mar2024 11.10.2ba
  If bObsoleteRegKeyFileExists And gnMaxRegKeyFile > 0
    If gaRegKeyFile(0)\sRegKeyFile <> "scs11." + sExtPart
      debugMsgAS(sProcName, "Calling DeleteFile(" + #DQUOTE$ + gsCommonAppDataPath + "scs11." + sExtPart + #DQUOTE$ + ")")
      DeleteFile(gsCommonAppDataPath + "scs11.scscp") ; NOTE: Deletes file "C:\ProgramData\ShowCueSystem\scs11.scscp" if it exists
    EndIf
  EndIf
  ; End added 2Mar2024 11.10.2ba
  
EndProcedure

Procedure saveRegKey()
  PROCNAMEC()
  Protected sDirectory.s, sRegKeyFile.s, sFullFileName.s
  Protected n, sFilePart.s, sExtPart.s, sTryName.s, bNameOK
  Protected nFileNo, nResult, bCreateNewFile
  
  debugMsgAS(sProcName, #SCS_START)
  
  sDirectory = gsCommonAppDataPath
  debugMsgAS(sProcName, "sDirectory=" + #DQUOTE$ + sDirectory + #DQUOTE$)
  
  If gnMaxRegKeyFile < 0
    bCreateNewFile = #True
  Else
    sRegKeyFile = gaRegKeyFile(0)\sRegKeyFile
    ; try to open the file for read/write
    If FileSize(sDirectory + sRegKeyFile) >= 0
      nFileNo = OpenFile(#PB_Any, sDirectory + sRegKeyFile)
    EndIf
    If nFileNo = 0
      ; cannot open this file for read/write, probably because the file was created under a different Windows user login, so create a new file
      bCreateNewFile = #True
    EndIf
  EndIf
  
  If FileSize(sDirectory) <> -2
    ; nb shouldn't get here as the directory should have been created if necessary in initialisePart1()
    nResult = CreateDirectory(sDirectory)
    debugMsgAS(sProcName, "CreateDirectory(" + #DQUOTE$ + sDirectory + #DQUOTE$ + ") returned " + nResult)
    If nResult = 0
      grLicInfo\sRegErrorMsg = "CreateDirectory(" + #DQUOTE$ + sDirectory + #DQUOTE$ + ") failed"
      debugMsg(sProcName, "exiting #False because " + grLicInfo\sRegErrorMsg)
      ProcedureReturn #False
    EndIf
  EndIf
  
  If bCreateNewFile
    sFilePart = GetFilePart(#SCS_PREFS_FILE_COMMON, #PB_FileSystem_NoExtension) + "_" + Hex(Date() - Date(2018, 1, 1, 0, 0, 0))
    sExtPart = GetExtensionPart(#SCS_PREFS_FILE_COMMON)
    sRegKeyFile = sFilePart + "." + sExtPart
  EndIf
  
  If IsFile(nFileNo)
    CloseFile(nFileNo)
  EndIf
  ; Added 2Mar2024 11.10.2ba
  If FileSize(sDirectory + #SCS_PREFS_FILE_COMMON) >= 0
    DeleteFile(sDirectory + #SCS_PREFS_FILE_COMMON) ; NOTE: Deletes file "C:\ProgramData\ShowCueSystem\scs11.scscp" if it exists (or scs11d.scsp or scs11w.scsp if relevnt)
  EndIf
  ; End added 2Mar2024 11.10.2ba
  If FileSize(sDirectory + sRegKeyFile) >= 0
    DeleteFile(sDirectory + sRegKeyFile)
  EndIf
  nFileNo = CreateFile(#PB_Any, sDirectory + sRegKeyFile) ; NOTE: Create a file with a name like "C:\ProgramData\ShowCueSystem\scs11_xxxxxxx.scscp" where xxxxxxx will be the hex value of a calculated date, eg "scs11_67655E3.scscp"
  debugMsgAS(sProcName, "CreateFile(#PB_Any, " + #DQUOTE$ + sDirectory + sRegKeyFile + #DQUOTE$ + ") returned nFileNo=" + nFileNo)
  ; debugMsgAS(sProcName, "sRegKeyFile=" + #DQUOTE$ + sRegKeyFile + #DQUOTE$ + ", nFileNo=" + nFileNo)
  
  If nFileNo
    With grLicInfo
      debugMsgAS(sProcName, "saving to " + #DQUOTE$ + sDirectory + sRegKeyFile + #DQUOTE$)
      ; now save to the reg file in 'preferences' format to enable backward-compatibility - although that will only apply if the filename doesn't contain the (n) suffix
      ; sample format as displayed by UltraEdit:
      ;1   
      ;2 [AllUsers]
      ;3 CommonFlags = 6F3E6F506C2F6C2E6C616C3D6C2E6CA56F506C356C6E6FA36C676C626C636C416C376F296C636C5B6F426C2C6C2F6CA56F296C716C646C626C346C6E6C746C5A
      ;4 CFDate = 1524242945
      ;5 UserName = Mike
      ;6 
      WriteStringFormat(nFileNo, #PB_UTF8)  ; include this BOM (byte order mask) because preference files seem to have this at BOM the start (Ctrl/H in UltraEdit shows this)
      WriteStringN(nFileNo, "")                             ; line 1
      WriteStringN(nFileNo, "[AllUsers]")                   ; line 2
      WriteStringN(nFileNo, "CommonFlags = " + \sRegString) ; line 3
      WriteStringN(nFileNo, "CFDate = " + \qRegDate)        ; line 4
      WriteStringN(nFileNo, "UserName = " + UserName())     ; line 5
      ; WriteStringN(nFileNo, "")                             ; line 6
    EndWith
    CloseFile(nFileNo)
  EndIf
  
  debugMsgAS(sProcName, #SCS_END)
  
EndProcedure

Procedure packRegKey(pLicType.s, pLicUser.s, pAuthString.s, pExpireDate, pStartsLeft, pExpString.s, dLicExpDate, bAllUsers, bSetRegDate)
  PROCNAMEC()
  Protected sPrefsFile.s, sGroup.s, sPrefKey.s
  Protected sAuthStringPacked.s, sRegAppName.s
  Protected sNameLen.s, sAuthLen.s, sExpireDate.s
  Protected sStartsLeft.s, sRegSection.s
  Protected myLicInfo.tyLicInfo
;   Protected sPart1.s, sPart2.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected bPrefsOpen
  Protected sTestGroup.s, sTestKey.s, sTime.s
  Protected sDirectory.s, nResult
  
  debugMsgAS(sProcName, #SCS_START + ", pLicType=" + pLicType + ", pLicUser=" + pLicUser + ", pAuthString=" + pAuthString)
  
  grLicInfo\sRegErrorMsg = ""
  myLicInfo = grLicInfo
  With myLicInfo
    CompilerIf #cDemo
      \sRegisteredLicType = "D"
    CompilerElseIf #cWorkshop
      \sRegisteredLicType = "W"
    CompilerElse
      \sRegisteredLicType = pLicType
    CompilerEndIf
    \sAuthString = UCase(Trim(pAuthString))
    \sLicUser = Trim(pLicUser)
    \nExpireDate = pExpireDate
    debugMsgAS(sProcName, "\nExpireDate=" + \nExpireDate)
    \nStartsLeft = pStartsLeft
    \sExpString = pExpString
    \dLicExpDate = dLicExpDate
    debugMsgAS(sProcName, "\sRegisteredLicType=" + \sRegisteredLicType + ", \sLicUser=" + \sLicUser + ", \sAuthString=" + \sAuthString)
    
    sNameLen = FormatUsingL(Len(\sLicUser), "000")
    sAuthStringPacked = Left(\sAuthString, 4) + Mid(\sAuthString, 6, 4) + Right(\sAuthString, 4)
    Select \sRegisteredLicType
      Case "ES", "FS", "GS", "NP", "NS", "NQ", "NZ"
        sAuthStringPacked + \sExpString
    EndSelect
    sAuthLen = FormatUsingL(Len(sAuthStringPacked), "00")
    
    \sRegString = \sRegisteredLicType + sNameLen + \sLicUser + sAuthLen + sAuthStringPacked
    debugMsgAS(sProcName, "(1) \sRegString=" + \sRegString)
    If \sRegisteredLicType = "D" Or \sRegisteredLicType = "W" Or \sRegisteredLicType = "T"
      sExpireDate = FormatUsingL(\nExpireDate, "00000")
      \sRegString + sExpireDate + "."
      If \sRegisteredLicType = "T"
        sStartsLeft = FormatUsingL(\nStartsLeft, "000")
        \sRegString + sStartsLeft + "."
      EndIf
    EndIf
    
    debugMsgAS(sProcName, "(2) Len(\sRegString)=" + Len(\sRegString) + ", \sRegString=" + \sRegString)
    If Len(\sRegString) < 32
      \sRegString + Mid("mishebcjsbjvzkqa5dsjbupowqhdvfts", Len(\sRegString) + 1)
    EndIf
    debugMsgAS(sProcName, "(3) \sRegString=" + \sRegString)
    
    \sRegString = encryptRegKey(\sRegString, #SCS_ENCRYPTION_KEY)
    debugMsgAS(sProcName, "(4) \sRegString=" + \sRegString)
    \sRegString = stringToHexString(\sRegString)
    debugMsgAS(sProcName, "(5) \sRegString=" + \sRegString)
    debugMsgAS(sProcName, "\sRegisteredLicType=" + \sRegisteredLicType)
    If bSetRegDate
      \qRegDate = Date()
    EndIf
    
    grLicInfo = myLicInfo
    debugMsgAS(sProcName, "calling saveRegKey()")
    saveRegKey()
    
  EndWith
  
  debugMsgAS(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure loadWindowPrefs(sPrefKey.s, *rWindowInfo.tyWindow)
  PROCNAMEC()
  Protected sTmp.s
  Protected bReadPreference
  
  With *rWindowInfo
    \sPrefKey = sPrefKey
    \bPositionSet = #False
    \nLeft = -1
    \nTop = -1
    \nWidth = -1
    \nHeight = -1
    CompilerIf #cTutorialVideoOrScreenShots
      If sPrefKey = "Editor" Or sPrefKey = "DMXDisplay" Or sProcName = "VSTPlugin"
        bReadPreference = #True
      EndIf
    CompilerElse
      bReadPreference = #True
    CompilerEndIf
    If bReadPreference
      sTmp = ReadPreferenceString(sPrefKey, "")
      ; debugMsg(sProcName, "sTmp=" + sTmp)
      If sTmp
        ; debugMsg(sProcName, sPrefKey + "=" + sTmp)
        If (Left(sTmp,3) = "Max") ; And (sPrefKey <> "Editor")  ; test on Editor added 8Dec2017 because a maximized editor screen doesn't correctly handle movements of the vertical splitter bar
          \bMaximized = #True
          If CountString(sTmp, ";") >= 1
            \bPositionSet = #True
            \nLeft = Val(StringField(sTmp, 2, ";"))
            \nTop = Val(StringField(sTmp, 3, ";"))
          EndIf
        Else
          \bMaximized = #False
          If CountString(sTmp, ";") >= 1
            \bPositionSet = #True
            \nLeft = Val(StringField(sTmp, 1, ";"))
            \nTop = Val(StringField(sTmp, 2, ";"))
            If CountString(sTmp, ";") >= 3
              \nWidth = Val(StringField(sTmp, 3, ";"))
              \nHeight = Val(StringField(sTmp, 4, ";"))
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure deleteObsoletePrefs()
  PROCNAMEC()
  Protected nResult
  
  If gnPrefsReadVersion <= 110000
    nResult = PreferenceGroup("GeneralOptions")  ; PreferenceGroup("GeneralOptions")
    RemovePreferenceKey("AudioDriver")
    RemovePreferenceKey("DefaultAudioDriver")
  EndIf
  nResult = PreferenceGroup("AudioDriverBASS")  ; PreferenceGroup("AudioDriverBASS")
  RemovePreferenceKey("MinFileBufLen")
  
EndProcedure

Procedure loadPrefsFavFiles()
  PROCNAMEC()
  ; nb cannot use debugMsg() yet
  Protected sFileName.s
  Protected n
  
  Debug sProcName + ": start"
  
  OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
  gbPreferencesOpen = #True
  
  ; favorite files
  PreferenceGroup("FavoriteFiles")  ; PreferenceGroup("FavoriteFiles")
  gnFavFileCount = 0
  For n = 0 To #SCS_MAX_FAV_FILE
    sFileName = ReadPreferenceString("File" + Right("0" + Trim(Str(n+1)), 2), "")
    If (Len(sFileName) > 4) And (LCase(Right(sFileName, 4)) = ".scs")
      ; OK
    ElseIf (Len(sFileName) > 5) And (LCase(Right(sFileName, 5)) = ".scsq")
      ; OK
    ElseIf (Len(sFileName) > 6) And (LCase(Right(sFileName, 6)) = ".scs11")
      ; OK
    Else
      sFileName = ""  ; not OK so clear this entry
    EndIf
    If sFileName
      If FileExists(sFileName, #False)
        With gaFavoriteFiles(gnFavFileCount)
          \sFileName = sFileName
          ; \nShortcut = 0
        EndWith
        gnFavFileCount + 1
      EndIf
    EndIf
  Next n
  
  ClosePreferences()
  gbPreferencesOpen = #False
  
EndProcedure

Procedure loadPrefsTranslators()
  PROCNAMEC()
  ; nb cannot use debugMsg() yet
  
  CompilerIf #cTranslator
    OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
    gbPreferencesOpen = #True
    
    PreferenceGroup("GeneralOptions")   ; PreferenceGroup("GeneralOptions")
    With grGeneralOptions
      \bDisplayLangIds = ReadPreferenceInteger("DisplayLangIds", #False)
      Debug sProcName + ": \bDisplayLangIds=" + \bDisplayLangIds
    EndWith
    
    ClosePreferences()
    gbPreferencesOpen = #False
  CompilerEndIf
  
EndProcedure

Procedure loadPrefsPreSpecialStart()
  PROCNAMEC()
  ; nb cannot use debugMsg() yet
  Protected nResult
  Protected sDefaultLangCode.s
  Protected bLangCodeOK
  Protected n
  Protected sRegVersion.s
  Protected Dim sRegVersionParts.s(2)
  
  Debug sProcName + ": start"
  
  nResult = OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
  If nResult
    gbPreferencesOpen = #True
    
    PreferenceGroup("Version")  ; INFO load preference group "Version"
    sRegVersion = ReadPreferenceString("Version", #SCS_FILE_VERSION)
    For n = 1 To 3
      sRegVersionParts(n-1) = StringField(sRegVersion, n, ".")
    Next n
    gnPrefsReadVersion = (Val(sRegVersionParts(0)) * 10000) + (Val(sRegVersionParts(1)) * 100) + Val(sRegVersionParts(2))
    gnPrefsReadBuild = ReadPreferenceInteger("Build", 0)
    Debug sProcName + ": sRegVersion=" + sRegVersion + ", gnPrefsReadVersion=" + gnPrefsReadVersion + ", gnPrefsReadBuild=" + gnPrefsReadBuild
    
    PreferenceGroup("GeneralOptions")   ; INFO PreferenceGroup("GeneralOptions")
    With grGeneralOptions
      \sDfltFontName = ReadPreferenceString("DfltFontName", "")
      If \sDfltFontName
        \nDfltFontSize = ReadPreferenceInteger("DfltFontSize", gnSCSDfltFontSize)
        gsDefFontName = \sDfltFontName
        gnDefFontSize = \nDfltFontSize
        gdFontScale = 1.0
        Debug sProcName + ", gsDefFontName=" + gsDefFontName
      EndIf
      sDefaultLangCode = #SCS_DEFAULT_LANGUAGE
      grGeneralOptions\sLangCode = ReadPreferenceString("Language", sDefaultLangCode)
      ; check that sLangCode is valid (could be invalid if we removed a language)     ;Now checked in lang.pbi because we don't know gnLanguagecount until we read the language files
      ;For n = 0 To (gnLanguageCount-1)
      ;  If grGeneralOptions\sLangCode = gaLanguage(n)\sLangCode
      ;    bLangCodeOK = #True
      ;    Break
      ;  EndIf
      ;Next n
      ;If bLangCodeOK = #False
      ;  grGeneralOptions\sLangCode = sDefaultLangCode
      ;EndIf
      ; commented out - moved unconditionally to loadPrefsTranslators()
      ;     If bLangCodeOK
      ;       \bDisplayLangIds = ReadPreferenceInteger("DisplayLangIds", #False)
      ;       Debug sProcName + ": \bDisplayLangIds=" + \bDisplayLangIds
      ;     EndIf
    EndWith
    
    ClosePreferences()
    gbPreferencesOpen = #False
    
  Else
    ; preference file does not yet exist (will be created in loadPrefsPart0())
    With grGeneralOptions
      \sLangCode =  #SCS_DEFAULT_LANGUAGE
    EndWith
    
  EndIf
  
EndProcedure

Procedure loadPrefsPart0()
  PROCNAMEC()
  Protected sProcessKey.s, bUnpackResult
  Protected n, nOperMode
  Protected sTmp.s
  Protected sGroup.s
  Protected bNewFile, nResult
  Protected sDfltFontName.s
  Protected nPrevXAdj, nPrevYAdj
  
  debugMsg(sProcName, #SCS_START)
  Debug sProcName + ": start"
  
  ; nb must call debugPrefsFile() BEFORE calling OpenPreferences() or the ReadFile() command in debugPrefsFile() will fail
  debugPrefsFile(gsAppDataPath + #SCS_PREFS_FILE)
  
  nResult = OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
  debugMsg(sProcName, "OpenPreferences(" + gsAppDataPath + #SCS_PREFS_FILE + ") returned " + nResult)
  If nResult = 0
    CreatePreferences(gsAppDataPath + #SCS_PREFS_FILE)
    bNewFile = #True
  EndIf
  gbPreferencesOpen = #True
  ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  
  grMain\nDemoTime = #SCS_DEMO_TIME   ; default session time - overridden if licence expired
  
  If bNewFile = #False
    ; nb gnPrefsReadVersion must be set before calling deleteObsoletePrefs()
    deleteObsoletePrefs()
    ; nb deleteObsoletePrefs() may change the currently-selected PreferenceGroup, so a new call to PreferenceGroup() must be made before accessing any more prefs.
  EndIf
  
  nResult = PreferenceGroup("OperMode")  ; INFO load preference group "OperMode"
  ; debugMsg(sProcName, "PreferenceGroup('OperMode') returned " + nResult)
  gnOperMode = encodeOperMode(ReadPreferenceString("OperMode", "Design"))

  nResult = PreferenceGroup("GeneralOptions")  ; INFO load preference group "GeneralOptions"
  ; debugMsg(sProcName, "PreferenceGroup('GeneralOptions') returned " + nResult)
  With grGeneralOptions
    \bSwapMonitors1and2 = ReadPreferenceInteger("SwapMonitors1and2", #False)
    gbSwapMonitors1and2 = \bSwapMonitors1and2
    \nSwapMonitor = ReadPreferenceInteger("SwapMonitor", 2)
    gnSwapMonitor = \nSwapMonitor
    sTmp = ReadPreferenceString("FaderAssignments", "")
    If sTmp
      \nFaderAssignments = encodeFaderAssignments(sTmp)
    EndIf
  EndWith
  
  nResult = PreferenceGroup("DTMA")  ; INFO load preference group "DTMA"
  ; debugMsg(sProcName, "PreferenceGroup('DTMA') returned " + nResult)
  With grDontTellMeAgain
    \bVideoCodecs = ReadPreferenceInteger("VideoCodecs", #False)
  EndWith

  ; Added 3Dec2022 11.9.7ar
  nResult = PreferenceGroup("MISC")  ; INFO load preference group "MISC"
  ; debugMsg(sProcName, "PreferenceGroup('DTMA') returned " + nResult)
  With grMisc
    \bClockDisplayed = ReadPreferenceInteger("ClockDisplayed", #False)
  EndWith
  ; End added 3Dec2022 11.9.7ar

  nResult = PreferenceGroup("Memory")  ; INFO load preference group "Memory"
  ; debugMsg(sProcName, "PreferenceGroup('Memory') returned " + nResult)
  With grMemoryPrefs
    \nDMXDisplayPref = encodeDMXPref(ReadPreferenceString("DMXDisplayPref", "%"))
    \nDMXGridType = encodeDMXGridType(ReadPreferenceString("DMXGridType", "Universe"))
    CompilerIf #c_dmx_display_drop_gridline_and_backcolor_choices
      \nDMXBackColor = -1 ; standard back color (very light grey)
      \bDMXShowGridLines = 1 ; show grid lines
    CompilerElse
      \nDMXBackColor = ReadPreferenceInteger("DMXBackColor", -1)
      \bDMXShowGridLines = ReadPreferenceInteger("DMXShowGridLines", 1)
    CompilerEndIf
    \nDMXFixtureDisplayData = ReadPreferenceInteger("DMXFixtureDisplayData", #SCS_LT_DISP_ALL)
    CompilerIf #cDemo = #False And #cWorkshop = #False
      \sLastCheckForUpdate = ReadPreferenceString("LastCheckForUpdate", "")
    CompilerEndIf
    ; see also WMN_mnuHelpClearDTMAInds_Click() regarding the following
    \sDontAskCloseSCSDate = ReadPreferenceString(#SCS_DontAskCloseSCSDate, "")
    \sDontTellDMXChannelLimitDate = ReadPreferenceString(#SCS_DontTellDMXChannelLimitDate, "")
  EndWith

  ;- RAI options
  nResult = PreferenceGroup("RAIOptions")  ; INFO load preference group "RAIOptions"
  ; debugMsg(sProcName, "PreferenceGroup('RAIOptions') returned " + nResult)
  With grRAIOptions
    \bRAIEnabled = ReadPreferenceInteger("RAIEnabled", #False)
    sTmp = ReadPreferenceString("RAIApp", "")
    \nRAIApp = encodeRAIApp(sTmp)
    sTmp = ReadPreferenceString("RAIOSCVersion", "")
    If sTmp
      \nRAIOSCVersion = encodeOSCVersion(sTmp)
    Else
      \nRAIOSCVersion = #SCS_OSC_VER_1_0
    EndIf
    sTmp = ReadPreferenceString("NetworkProtocol", "")
    If sTmp
      \nNetworkProtocol = encodeNetworkProtocol(sTmp)
    Else
      \nNetworkProtocol = #SCS_NETWORK_PR_TCP
    EndIf
    ; debugMsg(sProcName, "grRAIOptions\nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol))
    \sLocalIPAddr = ReadPreferenceString("LocalIPAddr", "")
    ; debugMsg(sProcName, "grRAIOptions\sLocalIPAddr=" + \sLocalIPAddr)
    Select \nRAIApp
      Case #SCS_RAI_APP_OSC
        \nLocalPort = ReadPreferenceInteger("LocalPort", #SCS_DEFAULT_RAI_LOCAL_PORT_OSCAPP)
      Default
        \nLocalPort = ReadPreferenceInteger("LocalPort", #SCS_DEFAULT_RAI_LOCAL_PORT_SCSREMOTE)
    EndSelect
    ; debugMsg(sProcName, "grRAIOptions\nLocalPort=" + \nLocalPort)
  EndWith
  
  ; INFO load preference group "OM_Design" or "OM_Performance"
  For nOperMode = 0 To #SCS_OPERMODE_LAST
    Select nOperMode
      Case #SCS_OPERMODE_DESIGN
        sGroup = "OM_Design"
      Case #SCS_OPERMODE_REHEARSAL
        sGroup = "OM_Rehearsal"
      Case #SCS_OPERMODE_PERFORMANCE
        sGroup = "OM_Performance"
    EndSelect
    nResult = PreferenceGroup(sGroup)
    With grOperModeOptions(nOperMode)
      \sSchemeName = ReadPreferenceString("ColorScheme", grOperModeOptionDefs(nOperMode)\sSchemeName)
      sTmp = ReadPreferenceString("CtrlPanelPos", decodeCtrlPanelPos(grOperModeOptionDefs(nOperMode)\nCtrlPanelPos))
      \nCtrlPanelPos = encodeCtrlPanelPos(sTmp)
      sTmp = ReadPreferenceString("MainToolbarInfo", decodeMainToolBarInfo(grOperModeOptionDefs(nOperMode)\nMainToolBarInfo))
      \nMainToolBarInfo = encodeMainToolBarInfo(sTmp, nOperMode)
      sTmp = ReadPreferenceString("VisMode", decodeVisMode(grOperModeOptionDefs(nOperMode)\nVisMode))
      \nVisMode = encodeVisMode(sTmp)
      \bShowNextManualCue = ReadPreferenceInteger("ShowNextManualCue", grOperModeOptionDefs(nOperMode)\bShowNextManualCue)
      \bShowMasterFader = ReadPreferenceInteger("ShowMasterFader", grOperModeOptionDefs(nOperMode)\bShowMasterFader)
      \nCueListFontSize = ReadPreferenceFloat("CueListFontSize", grOperModeOptionDefs(nOperMode)\nCueListFontSize)
      \nCuePanelVerticalSizing = ReadPreferenceInteger("CuePanelVerticalSizing", grOperModeOptionDefs(nOperMode)\nCuePanelVerticalSizing)
      \bShowSubCues = ReadPreferenceInteger("ShowSubCues", grOperModeOptionDefs(nOperMode)\bShowSubCues)
      \bShowHiddenAutoStartCues = ReadPreferenceInteger("ShowHiddenAutoStartCues", grOperModeOptionDefs(nOperMode)\bShowHiddenAutoStartCues)
      \bShowHotkeyCuesInPanels = ReadPreferenceInteger("ShowHotkeyCuesInPanels", grOperModeOptionDefs(nOperMode)\bShowHotkeyCuesInPanels)
      \bShowHotkeyList = ReadPreferenceInteger("ShowHotkeyList", grOperModeOptionDefs(nOperMode)\bShowHotkeyList)
      \bShowTransportControls = ReadPreferenceInteger("ShowTransportControls", grOperModeOptionDefs(nOperMode)\bShowTransportControls)
      \bShowFaderAndPanControls = ReadPreferenceInteger("ShowFaderAndPanControls", grOperModeOptionDefs(nOperMode)\bShowFaderAndPanControls)
      \bAllowDisplayTimeout = ReadPreferenceInteger("AllowDisplayTimeout", grOperModeOptionDefs(nOperMode)\bAllowDisplayTimeout)
      \bShowToolTips = ReadPreferenceInteger("ShowToolTips", grOperModeOptionDefs(nOperMode)\bShowToolTips)
      \bDisplayAllMidiIn = ReadPreferenceInteger("DisplayAllMidiIn", grOperModeOptionDefs(nOperMode)\bDisplayAllMidiIn)
      \nMidiInDisplayTimeout = ReadPreferenceInteger("MidiInDisplayTimeout", grOperModeOptionDefs(nOperMode)\nMidiInDisplayTimeout)
      \bShowLvlCurvesPrim = ReadPreferenceInteger("ShowLvlCurvesPrim", grOperModeOptionDefs(nOperMode)\bShowLvlCurvesPrim)
      \bShowLvlCurvesOther = ReadPreferenceInteger("ShowLvlCurvesOther", grOperModeOptionDefs(nOperMode)\bShowLvlCurvesOther)
      \bShowPanCurvesPrim = ReadPreferenceInteger("ShowPanCurvesPrim", grOperModeOptionDefs(nOperMode)\bShowPanCurvesPrim)
      \bShowPanCurvesOther = ReadPreferenceInteger("ShowPanCurvesOther", grOperModeOptionDefs(nOperMode)\bShowPanCurvesOther)
      \bShowAudioGraph = ReadPreferenceInteger("ShowAudioGraph", grOperModeOptionDefs(nOperMode)\bShowAudioGraph)
      \bShowCueMarkers = ReadPreferenceInteger("ShowCueMarkers", grOperModeOptionDefs(nOperMode)\bShowCueMarkers)
      \bRequestConfirmCueClick = ReadPreferenceInteger("RequestConfirmCueClick", grOperModeOptionDefs(nOperMode)\bRequestConfirmCueClick)
      \bShowMidiCueInNextManual = ReadPreferenceInteger("ShowMidiCueInNextManual", grOperModeOptionDefs(nOperMode)\bShowMidiCueInNextManual)
      \bShowMidiCueInCuePanels = ReadPreferenceInteger("ShowMidiCueInCuePanels", grOperModeOptionDefs(nOperMode)\bShowMidiCueInCuePanels)
      \bLimitMovementOfMainWindowSplitterBar = ReadPreferenceInteger("LimitMovementOfMainWindowSplitterBar", grOperModeOptionDefs(nOperMode)\bLimitMovementOfMainWindowSplitterBar)
      sTmp = ReadPreferenceString("PeakMode", decodePeakMode(grOperModeOptionDefs(nOperMode)\nPeakMode))
      \nPeakMode = encodePeakMode(sTmp)
      sTmp = ReadPreferenceString("VUBarWidth", decodeVUBarWidth(grOperModeOptionDefs(nOperMode)\nVUBarWidth))
      \nVUBarWidth = encodeVUBarWidth(sTmp)
      \bHideCueList = ReadPreferenceInteger("HideCueList", grOperModeOptionDefs(nOperMode)\bHideCueList)
      ; \nMaxMonitor = ReadPreferenceInteger("MaxMonitor", grOperModeOptionDefs(nOperMode)\nMaxMonitor) ; added 11.6.0 ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
      sTmp = ReadPreferenceString("MonitorSize2", decodeMonitorSize(grOperModeOptionDefs(nOperMode)\nMonitorSize))  ; changed keyword at 11.3.0 when default value changed
      \nMonitorSize = encodeMonitorSize(sTmp)
      sTmp = ReadPreferenceString("MTCDispLocn", decodeMTCDispLocn(grOperModeOptionDefs(nOperMode)\nMTCDispLocn))
      \nMTCDispLocn = encodeMTCDispLocn(sTmp)
      sTmp = ReadPreferenceString("TimerDispLocn", decodeTimerDispLocn(grOperModeOptionDefs(nOperMode)\nTimerDispLocn))
      \nTimerDispLocn = encodeTimerDispLocn(sTmp)
      \rGrdCuesInfo\sLayoutString = ReadPreferenceString("MainGridColLayout2", grOperModeOptionDefs(nOperMode)\rGrdCuesInfo\sLayoutString)
    EndWith
  Next nOperMode
  
  ; the following must NOT be called BEFORE the Oper Mode preferences have been loaded as populateMonitorInfo() uses the \nMaxMonitor setting
  ; debugMsg(sProcName, "calling populateMonitorInfo()")
  populateMonitorInfo()
  CompilerIf #c_include_tvg
    ; call initTVG() NOW as this calculates the gaMonitors()\nDisplayScalingPercentage fields, which MAY be needed when displaying the splash screen (and others) 
    debugMsg(sProcName, "calling initTVG()")
    initTVG()
  CompilerEndIf
  gsMonitorKey = buildMonitorKey() ; cannot build monitor key until initTVG() has obtained the monitor bounds (which take into consideration display scaling), and also until gbSwapMonitors1and2 has been set
  debugMsg(sProcName, "gsMonitorKey=" + gsMonitorKey)
  loadPrefsWindows()  ; cannot load window prefs until gsMonitorKey has been set
  
  gsColorScheme = grOperModeOptions(gnOperMode)\sSchemeName
  gbShowToolTips = grOperModeOptions(gnOperMode)\bShowToolTips
  
  PreferenceGroup("Editor")  ; INFO load preference group "Editor"
  With grEditorPrefs
    \sFavItems = Trim(ReadPreferenceString("FavItems", "QF,QS,QL,QA"))
    
    ; obsolete preferences:
    RemovePreferenceKey("SplitterPosEdit1") ; replaced by SplitterPosEditV (vertical splitter position)
    RemovePreferenceKey("SplitterPosEdit2") ; replaced by SplitterPosEditH (horizontal splitter position)
    
    ; splitter positions now saved in "Windows_..." group
;     If bClearSavedWindowInfo
;       RemovePreferenceKey("SplitterPosEditV")
;       RemovePreferenceKey("SplitterPosEditH")
;     EndIf
;     \nSplitterPosEditV = ReadPreferenceInteger("SplitterPosEditV", -1)
;     ; debugMsg(sProcName, "\nSplitterPosEditV=" + Str(\nSplitterPosEditV))
;     \nSplitterPosEditH = ReadPreferenceInteger("SplitterPosEditH", -1)
;     ; debugMsg(sProcName, "\nSplitterPosEditH=" + Str(\nSplitterPosEditH))
    
    \bShowFileFoldersInEditor = ReadPreferenceInteger("ShowFileFoldersInEditor", #False)
    \bEditShowLvlCurvesSel = #True
    \bEditShowPanCurvesSel = #True
    \bEditShowLvlCurvesOther = #False
    \bEditShowPanCurvesOther = #False
    
    sTmp = ReadPreferenceString("GraphDisplayMode", decodeGraphDisplayMode(#SCS_GRAPH_FILE))
    \nGraphDisplayMode = encodeGraphDisplayMode(sTmp)
    ; debugMsg(sProcName, "\nGraphDisplayMode=" + decodeGraphDisplayMode(\nGraphDisplayMode))
    
    \bAutoScroll = ReadPreferenceInteger("AutoScroll", 0)
  EndWith
  
  With grEditingOptions
    \nFileScanMaxLengthAudio = ReadPreferenceInteger("FileScanMaxLength", 10)
    \nFileScanMaxLengthAudioMS = \nFileScanMaxLengthAudio * 60000
    \nFileScanMaxLengthVideo = ReadPreferenceInteger("FileScanMaxLengthV", 5)
    \nFileScanMaxLengthVideoMS = \nFileScanMaxLengthVideo * 60000
    \bSaveAlwaysOn = ReadPreferenceInteger("SaveAlwaysOn", 0)
    \bIgnoreTitleTags = ReadPreferenceInteger("IgnoreTitleTags", 0)
    grEditingOptions\bIncludeAllLevelPointDevices = ReadPreferenceInteger("IncludeAllLevelPointDevices", 0)
    ; \nAudioFileSelector = encodeFileSelector(ReadPreferenceString("AudioFileSelector", "scs_afs"))
    ; changed default 18Nov2019 11.8.2rc4 as windows file selector is much faster than the SCS/PB equivalent, although the SCS selector does have a 'test' function
    \nAudioFileSelector = encodeFileSelector(ReadPreferenceString("AudioFileSelector", "windows_fs"))
    \bCheckMainLostFocusWhenEditorOpen = ReadPreferenceInteger("CheckMainLostFocusWhenEditorOpen", 0)
    \bActivateOCMAutoStarts = ReadPreferenceInteger("ActivateOCMAutoStarts", 0)
    \nEditorCueListFontSize = ReadPreferenceInteger("EditorCueListFontSize", -1)
  EndWith
  
  PreferenceGroup("EditModal")  ; INFO load preference group "EditModal"
  With grWEM
    \sCntCueMarkersUsageDim = ReadPreferenceString("CueMarkersUsageDim", "")
  EndWith
  
  ClosePreferences()
  gbPreferencesOpen = #False
  ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  
  If gbInitialising
    ; save operational mode options as at session start
    For n = 0 To #SCS_OPERMODE_LAST
      grOperModeOptionsAtStart(n) = grOperModeOptions(n)
    Next n
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure loadPrefsWindows()
  PROCNAMEC()
  Protected nDisplayNo, sPrefKey.s, sVideoRenderer.s, nVideoRenderer, nIndex
  
  debugMsg(sProcName, "loading preference group " + #DQUOTE$ + "Windows_" + gsMonitorKey + #DQUOTE$)
  PreferenceGroup("Windows_" + gsMonitorKey)
  WritePreferenceInteger("DateLastUsed", Date() / (3600 * 24)) ; Added 27Aug2024 11.10.3bn
  grMainWindow\bMaximized = #True
  loadWindowPrefs("AGColors", @grAGColorsWindow)
  loadWindowPrefs("BulkEdit", @grBulkEditWindow)
  loadWindowPrefs("Clock", @grClockWindow)
  loadWindowPrefs("ColorScheme", @grColorSchemeWindow)
  loadWindowPrefs("Controllers", @grControllersWindow)
  loadWindowPrefs("Countdown", @grCountDownWindow)
  loadWindowPrefs("CtrlSetup", @grCtrlSetupWindow)
  loadWindowPrefs("DMXChannels", @grDMXChannelsWindow)
  loadWindowPrefs("DMXDisplay", @grDMXDisplayWindow)
  loadWindowPrefs("DMXTest", @grDMXTestWindow)
  loadWindowPrefs("EditModal", @grEditModalWindow)
  loadWindowPrefs("Editor", @grEditWindow)
  loadWindowPrefs("Export", @grExportWindow)
  loadWindowPrefs("FavFiles", @grFavFilesWindow)
  loadWindowPrefs("FavFileSelector", @grFavFileSelectorWindow)
  loadWindowPrefs("FileOpener", @grFileOpenerWindow)
  loadWindowPrefs("FileRename", @grFileRenameWindow)
  loadWindowPrefs("Find", @grFindWindow)
  loadWindowPrefs("Import", @grImportWindow)
  loadWindowPrefs("ImportCSV", @grImportCSVWindow)
  loadWindowPrefs("ImportDevs", @grImportDevsWindow)
  loadWindowPrefs("LabelChange", @grLabelChangeWindow)
  loadWindowPrefs("LinkDevs", @grLinkDevsWindow)
  loadWindowPrefs("Lock", @grLockWindow)
  loadWindowPrefs("Main", @grMainWindow)
  loadWindowPrefs("MemoMain", @grMemoWindowMain)
  loadWindowPrefs("MemoPreview", @grMemoWindowPreview)
  loadWindowPrefs("MIDITest", @grMidiTestWindow)
  loadWindowPrefs("MTCDisplay", @grMTCDisplayWindow)
  loadWindowPrefs("NearEndWarning", @grNearEndWarningWindow)
  loadWindowPrefs("Options", @grOptionsWindow)
  loadWindowPrefs("OSCCapture", @grOSCCaptureWindow)
  loadWindowPrefs("PrintCueList", @grPrintCueListWindow)
  loadWindowPrefs("ProdFolder", @grProdFolderWindow)
  loadWindowPrefs("ProdTimer", @grProdTimerWindow)
  loadWindowPrefs("ScribbleStrip", @grScribbleStripWindow)
  loadWindowPrefs("Templates", @grTemplatesWindow)
  loadWindowPrefs("TimeProfile", @grTimeProfileWindow)
  loadWindowPrefs("TimerDisplay", @grTimerDisplayWindow)
  loadWindowPrefs("VSTPlugin", @grVSTWindow)
  loadWindowPrefs("VSTPlugins", @grVSTPluginsWindow)
  
  grVideoMonitors\sMonitorPin = ReadPreferenceString("MonitorPin", "")
  gbFadersDisplayed = ReadPreferenceInteger("FadersDisplayed", #False)
  gbDMXDisplayDisplayed = ReadPreferenceInteger("DMXDisplayDisplayed", #False)
  
  With grWMN
    ; splitter positions - design mode
    \nCuelistMemoSplitterPosD = ReadPreferenceInteger("CuelistMemoSplitterPosD", -1)
    \nMainMemoSplitterPosD = ReadPreferenceInteger("MainMemoSplitterPosD", -1)
    \nNorthSouthSplitterPosD = ReadPreferenceInteger("NorthSouthSplitterPosD", -1)
    \nPanelsHotkeysSplitterEndPosD = ReadPreferenceInteger("PanelsHotkeysSplitterEndPosD", -1)
    ; splitter positions - rehearsal mode
    \nCuelistMemoSplitterPosR = ReadPreferenceInteger("CuelistMemoSplitterPosR", -1)
    \nMainMemoSplitterPosR = ReadPreferenceInteger("MainMemoSplitterPosR", -1)
    \nNorthSouthSplitterPosR = ReadPreferenceInteger("NorthSouthSplitterPosR", -1)
    \nPanelsHotkeysSplitterEndPosR = ReadPreferenceInteger("PanelsHotkeysSplitterEndPosR", -1)
    ; splitter positions - performance mode
    \nCuelistMemoSplitterPosP = ReadPreferenceInteger("CuelistMemoSplitterPosP", -1)
    \nMainMemoSplitterPosP = ReadPreferenceInteger("MainMemoSplitterPosP", -1)
    \nNorthSouthSplitterPosP = ReadPreferenceInteger("NorthSouthSplitterPosP", -1)
    \nPanelsHotkeysSplitterEndPosP = ReadPreferenceInteger("PanelsHotkeysSplitterEndPosP", -1)
    ; TEMP to fix an issue in 11.8.1rc1 - 11.8.1rc3
    If \nPanelsHotkeysSplitterEndPosD > 800 ; arbitrary max
      \nPanelsHotkeysSplitterEndPosD = -1
    EndIf
    If \nPanelsHotkeysSplitterEndPosR > 800
      \nPanelsHotkeysSplitterEndPosR = -1
    EndIf
    If \nPanelsHotkeysSplitterEndPosP > 800
      \nPanelsHotkeysSplitterEndPosP = -1
    EndIf
    ; end TEMP to fix an issue in 11.8.1rc1 - 11.8.1rc3
  EndWith
  
  With grEditorPrefs
    ; splitter positions - editor
    \nSplitterPosEditV = ReadPreferenceInteger("SplitterPosEditV", -1)
    \nSplitterPosEditH = ReadPreferenceInteger("SplitterPosEditH", -1)
  EndWith
  
  CompilerIf #c_blackmagic_card_support
    ; screen video renderers
    With grCurrScreenVideoRenderers
      \nMaxCurrScreenVideoRenderer = -1
      For nDisplayNo = 1 To #SCS_MAX_SPLIT_SCREENS
        sPrefKey = "ScreenVideoRenderer_" + nDisplayNo
        sVideoRenderer = ReadPreferenceString(sPrefKey, "")
        If sVideoRenderer
          nVideoRenderer = encodeVideoRenderer(sVideoRenderer)
          If nVideoRenderer <> #SCS_VR_AUTOSELECT
            \nMaxCurrScreenVideoRenderer + 1
            nIndex = \nMaxCurrScreenVideoRenderer
            If nIndex > ArraySize(\aCurrScreenVideoRenderer())
              ReDim \aCurrScreenVideoRenderer(nIndex)
            EndIf
            \aCurrScreenVideoRenderer(nIndex)\nDisplayNo = nDisplayNo
            \aCurrScreenVideoRenderer(nIndex)\nScreenVideoRenderer = nVideoRenderer
            debugMsg(sProcName, "grCurrScreenVideoRenderers\aCurrScreenVideoRenderer(" + nIndex + ")\nDisplayNo=" + \aCurrScreenVideoRenderer(nIndex)\nDisplayNo +
                                ", \nScreenVideoRenderer=" + decodeVideoRenderer(\aCurrScreenVideoRenderer(nIndex)\nScreenVideoRenderer))
          EndIf
        EndIf
      Next nDisplayNo
    EndWith
  CompilerEndIf
  
EndProcedure

Procedure findRegFile()
  PROCNAMEC()
  Protected bFound
  
  debugMsgAS(sProcName, #SCS_START)
  
  debugMsgAS(sProcName, "calling loadRegKeyFileArray()")
  loadRegKeyFileArray()
  debugMsgAS(sProcName, "gnMaxRegKeyFile=" + gnMaxRegKeyFile)
  If gnMaxRegKeyFile >= 0
    ; a regkey file (*.scscp) has been found in ProgramData\ShowCueSystems (or ProgramData\ShowCueSystemsD if demo, or ProgramData\ShowCueSystemsW if workshop)
    ; if more than one file was found then the latest file will have been sorted to the top, ie to gaRegKeyFile(0)
    bFound = #True
  EndIf
  
  debugMsgAS(sProcName, #SCS_END + ", returning bFound=" + strB(bFound))
  ProcedureReturn bFound

EndProcedure

Procedure loadPrefsRegistration()
  PROCNAMEC()
  Protected sPrefsFile.s, sGroup.s, sPrefKey.s
  Protected sRegKey.s, bUnpackResult
  Protected bNewDemo, bNewWork, nToday, nResponse
  Protected bRegFileFound, nRegFileNo
  Protected bCallPackRegKey
  Protected sMsg.s, bWarning
  Protected bAskReg
  Protected nGraceDays, nDays
  Protected sRegDate.s
  Protected bAllUsers
  Protected sDirectory.s, nResult
  Protected sRegFile.s
  Protected bSetRegDate
  
  Debug sProcName
  debugMsgAS(sProcName, #SCS_START)
  
  debugMsgAS(sProcName, "calling findRegFile()")
  bRegFileFound = findRegFile()
  If bRegFileFound
    sRegFile = gsCommonAppDataPath + gaRegKeyFile(0)\sRegKeyFile
    nRegFileNo = OpenPreferences(sRegFile)
    debugMsgAS(sProcName, "OpenPreferences(" + #DQUOTE$ + sRegFile + #DQUOTE$ + ") returned " + nRegFileNo)
  EndIf
  If nRegFileNo = 0
    ; shouldn't get here
    bRegFileFound = #False
  EndIf
  
  sGroup = "AllUsers"
  sPrefKey = "CommonFlags"

  With grLicInfo
    If bRegFileFound
      gbPreferencesOpen = #True
      ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
      nResult = PreferenceGroup(sGroup)
      debugMsgAS(sProcName, "PreferenceGroup(" + #DQUOTE$ + sGroup + #DQUOTE$ + ") returned " + nResult)
      sRegKey = ReadPreferenceString(sPrefKey, "")
      debugMsgAS(sProcName, "sPrefKey=" + sPrefKey + ", sRegKey=" + sRegKey)
    EndIf
    If bRegFileFound = #False Or Len(sRegKey) = 0
      ; Regfile not found, or keyword or value not found, so fallback to demo mode (unless workshop mode)
      CompilerIf #cWorkshop
        bNewWork = #True
        \sRegisteredLicType = "W"
        \sLicType = \sRegisteredLicType
      CompilerElse
        bNewDemo = #True
        \sRegisteredLicType = "D"
        \sLicType = \sRegisteredLicType
      CompilerEndIf
    Else
      ; keyword and value found - unpack and validate
      bUnpackResult = unpackRegKey(sRegKey) ; NB populates grLicInfo\nExpireDate for demo, workshop or temp, amongst other fields
      debugMsgAS(sProcName, "bUnpackResult=" + strB(bUnpackResult))
      If bUnpackResult
        \sRegString = sRegKey
      Else ; bUnpackResult = #False
        CompilerIf #cWorkshop
          bNewWork = #True
          \sRegisteredLicType = "W"
          \sLicType = \sRegisteredLicType
        CompilerElse
          bNewDemo = #True
          \sRegisteredLicType = "D"
          \sLicType = \sRegisteredLicType
        CompilerEndIf
      EndIf
    EndIf
    
    \nLicLevel = getLicLevel(\sLicType)
    debugMsgAS(sProcName, "grLicInfo\sLicType=" + \sLicType + ", \nLicLevel=" + \nLicLevel + ", bNewDemo=" + strB(bNewDemo) + ", bNewWork=" + strB(bNewWork))
    
    ; debugMsg(sProcName, "calling setLicLimitsEtc()")
    setLicLimitsEtc()
    ED_setDevDisplayMaximums(@grProdDefForAdd) ; setLicLimitsEtc() must be called BEFORE calling ED_setDevDisplayMaximums()
    
    Select \nLicLevel
      Case #SCS_LIC_DEMO
        gnMaxCueIndex = 25
      Case #SCS_LIC_LITE
        gnMaxCueIndex = 40
      Case #SCS_LIC_STD
        gnMaxCueIndex = 80
      Case #SCS_LIC_PRO
        gnMaxCueIndex = -1
      Case #SCS_LIC_PLUS
        gnMaxCueIndex = -1
      Case #SCS_LIC_PLAT
        gnMaxCueIndex = -1
    EndSelect
    
    \bPlayOnly = #False
    gbDemoMode = #False
    gbWorkshopMode = #False
    
    Select \sLicType
      Case "ES", "NP", "NS", "NQ"
        ; ES = Student time-limited, NP = Professional time-limited, NS = Standard time-limited, NQ = Professional Plus time-limited
        nGraceDays = 5  ; nb used to be 30 days
        If (Date() > \dLicExpDate) And (Date() <= (\dLicExpDate + nGraceDays))
          debugMsg(sProcName, "License expired " + formatDateAsDDMMMYYYY(\dLicExpDate))
          \bPlayOnly = #True
          gbEditorAndOptionsLocked = #True
          sMsg = LangPars("Main", "RegExpired", formatDateAsDDMMMYYYY(\dLicExpDate), formatDateAsDDMMMYYYY(\dLicExpDate+nGraceDays)) + Chr(10) + Chr(10)
          bAskReg = #True
        ElseIf Date() > (\dLicExpDate + nGraceDays)
          debugMsg(sProcName, "License expired " + formatDateAsDDMMMYYYY(\dLicExpDate))
          ; nb grace days used to be 30, hence the name "RegExpired30", but the message itself does not include '30'
          sMsg = LangPars("Main", "RegExpired30", formatDateAsDDMMMYYYY(\dLicExpDate)) + Chr(10) + Chr(10)
          bAskReg = #True
          gbDemoMode = #True
          grMain\nDemoTime = 5
        Else
          gnSplashDuration = 3500
        EndIf
        
      Case "T"
        ; T = Temporary time-limited
        If \nStartsLeft > 0
          \nStartsLeft - 1
          bCallPackRegKey = #True
        EndIf
        nToday = dateToNumber(Date())
        ;debugMsg(sProcName, "nToday=" + nToday + ", \nExpireDate=" + \nExpireDate)
        If (nToday > \nExpireDate) Or (\nStartsLeft < 1)
          debugMsg(sProcName, "temp expired")
          sMsg = Lang("Main", "TempExpired")
          ensureSplashNotOnTop()
          nResponse = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
          gbDemoMode = #True
          grMain\nDemoTime = 5
        Else
          gnSplashDuration = 3500
        EndIf
        
      Case "D"
        ; D = Demo
        gbDemoMode = #True
        gnSplashDuration = 5000
        If bNewDemo
          \sRegisteredLicType = "D"
          \sLicType = \sRegisteredLicType
          \nLicLevel = getLicLevel(\sLicType)
          \sLicUser = Lang("Main", "NotRegistered")
          \sAuthString = ""
          \sExpString = ""
          \nExpireDate = dateToNumber(Date()) + 30
          debugMsgAS(sProcName, "\nExpireDate=" + \nExpireDate)
          \nStartsLeft = 0
          bCallPackRegKey = #True
          bSetRegDate = #True
          gnMaxCueIndex = 25
        Else
          nToday = dateToNumber(Date())
          nDays = \nExpireDate - nToday
          If nToday > \nExpireDate
            debugMsg(sProcName, "expired")
            sMsg = Lang("Main", "30DaysExp") + Chr(10) + Chr(10) + Lang("Main", "5mins") + Chr(10) + Chr(10)
            bAskReg = #True
            grMain\nDemoTime = 5
          ElseIf nToday > (\nExpireDate - 8)
            If nDays > 1
              sMsg = LangPars("Main", "Expiring", Str(nDays))
            ElseIf nDays = 1
              sMsg = Lang("Main", "Expiring1")
            Else
              sMsg = Lang("Main", "Expiring0") ; expires today
            EndIf
            debugMsg(sProcName, sMsg)
            sMsg + Chr(10) + Chr(10) + Lang("Main", "NeedToRegister") + Chr(10)
            bAskReg = #True
          Else
            debugMsgAS(sProcName, "expiring in " + nDays)
          EndIf
        EndIf
        
      Case "W"
        ; W = Workshop
        gbWorkshopMode = #True
        gnSplashDuration = 3500
        If bNewWork
          \sRegisteredLicType = "W"
          \sLicType = \sRegisteredLicType
          \nLicLevel = getLicLevel(\sLicType)
          \sLicUser = "Workshop User"
          \sAuthString = ""
          \sExpString = ""
          \nExpireDate = dateToNumber(Date()) + 30
          debugMsgAS(sProcName, "\nExpireDate=" + \nExpireDate)
          \nStartsLeft = 0
          bCallPackRegKey = #True
          bSetRegDate = #True
          gnMaxCueIndex = -1
        Else
          nToday = dateToNumber(Date())
          nDays = \nExpireDate - nToday
          debugMsgAS(sProcName, "nToday=" + nToday + ", \nExpireDate=" + \nExpireDate + ", nDays=" + nDays)
          If nToday > \nExpireDate
            debugMsg(sProcName, "expired")
            sMsg = "Your 30-day period for SCS Workshop has expired." + Chr(10) + Chr(10) + Lang("Main", "5mins")
            bWarning = #True
            gbDemoMode = #True
            gbWorkshopMode = #False
            grMain\nDemoTime = 5
          ElseIf nToday > (\nExpireDate - 8)
            If nDays > 1
              sMsg = "Warning! Your 30-day period for SCS Workshop will expire in " + nDays + " days."
            ElseIf nDays = 1
              sMsg = "Warning! Your 30-day period for SCS Workshop will expire in 1 day."
            Else
              sMsg = "Warning! Your 30-day period for SCS Workshop expires today."
            EndIf
            bWarning = #True
          Else
            debugMsgAS(sProcName, "expiring in " + nDays)
          EndIf
        EndIf
        
      Default
        gnSplashDuration = 3500
        
    EndSelect
    
    If bAskReg = #False
      If bWarning
        ensureSplashNotOnTop()
        nResponse = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Warning)
      EndIf
    Else
      CompilerIf #cAgent
        sMsg + LangPars("Main", "RegAgent", #SCS_AGENT_NAME, #SCS_REGISTER_URL_DISPLAY)
      CompilerElse
        sMsg + LangPars("Main", "RegOnline", #SCS_REGISTER_URL_DISPLAY)
      CompilerEndIf
      sMsg + Chr(10) + Chr(10) + Lang("Main", "GoToRegPage?")
      ensureSplashNotOnTop()
      nResponse = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      debugMsg(sProcName, "nResponse=" + nResponse)
      If nResponse = #PB_MessageRequester_Yes
        OpenURL(#SCS_REGISTER_URL_DISPLAY)
      EndIf
    EndIf
    
    gsLicUser = grLicInfo\sLicUser
    gsRegAuthString = grLicInfo\sAuthString
    grLicInfo\sAuthString = ""
    
    If gbPreferencesOpen
      ClosePreferences()
      gbPreferencesOpen = #False
      ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
    EndIf
    
    debugMsgAS(sProcName, "\sRegisteredLicType=" + \sRegisteredLicType + ", \sLicType=" + \sLicType + ", \nLicLevel=" + \nLicLevel)
    debugMsgAS(sProcName, "bCallPackRegKey=" + strB(bCallPackRegKey))
    If bCallPackRegKey
      debugMsg(sProcName, "calling packRegKey(" + \sRegisteredLicType + ", " + \sLicUser + ", " + \sAuthString + ", " + \nExpireDate +
                          ", " + \nStartsLeft + ", " + \sExpString + ", " + \dLicExpDate + ", " + strB(bAllUsers) + ", " + strB(bSetRegDate) + ")")
      If packRegKey(\sRegisteredLicType, \sLicUser, \sAuthString, \nExpireDate, \nStartsLeft, \sExpString, \dLicExpDate, bAllUsers, bSetRegDate) = #False
        If grLicInfo\sRegErrorMsg
          sMsg = grLicInfo\sRegErrorMsg + Chr(10) + Chr(10) + "Please email this information to " + #SCS_EMAIL_SUPPORT
          ensureSplashNotOnTop()
          scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
        EndIf
      EndIf
    EndIf
    
  EndWith
    
  CompilerIf #c_vMix_in_video_cues And #c_force_vMix_if_included
    ; See also similar code in loadPrefsPart1()
    If grLicInfo\sLicUser = "Mike Daniell"
      grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      debugMsg(sProcName, "grVideoDriver\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(grVideoDriver\nVideoPlaybackLibrary))
    EndIf
  CompilerEndIf
  
  grLicInfo\bCommonPrefsLoaded = #True
  
  debugMsgAS(sProcName, #SCS_END)
EndProcedure

Procedure loadPrefsScreenSettings()
  PROCNAMEC()
  Protected nSplitScreenIndex, nScreenMapInfoMax
  Protected sPrefKey.s, sPrefValue.s
  Protected sDisplayNo.s, sRealScreenSize.s
  Protected nRealScreenWidth, nRealScreenHeight
  Protected sSplitScreenInfo.s
  Protected sTmp.s
  Protected bOpenedPreferences
  
  If gbPreferencesOpen = #False
    If OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
      bOpenedPreferences = #True
      gbPreferencesOpen = #True
    EndIf
  EndIf
  
  With grVideoDriver
    nSplitScreenIndex = -1
    nScreenMapInfoMax = -1
    If gbPreferencesOpen
      PreferenceGroup("VideoDriver")  ; INFO load preference group "VideoDriver"
      If ExaminePreferenceKeys()
        While NextPreferenceKey()
          sPrefKey = PreferenceKeyName()
          If Left(sPrefKey, 17) = "SplitScreenCount_"
            sTmp = Mid(sPrefKey, 18)
            sDisplayNo = StringField(sTmp, 1, ":")
            sRealScreenSize = StringField(StringField(sTmp, 2, ":"), 1, "@")
            sPrefValue = Trim(PreferenceKeyValue())
            debugMsg(sProcName, "sPrefKey=" + sPrefKey + ", sDisplayNo=" + sDisplayNo + ", sRealScreenSize=" + sRealScreenSize + ", sPrefValue=" + sPrefValue)
            If FindString(sRealScreenSize, "x") And IsInteger(sPrefValue) And IsInteger(sDisplayNo)  ; all should be #True
              nRealScreenWidth = Val(StringField(sRealScreenSize,1,"x"))
              nRealScreenHeight = Val(StringField(sRealScreenSize,2,"x"))
              If (nRealScreenWidth > 0) And (nRealScreenHeight > 0) ; should be #True
                If nSplitScreenIndex < #SCS_MAX_SPLIT_SCREENS
                  nSplitScreenIndex + 1
                  \aSplitScreenInfo[nSplitScreenIndex]\nDisplayNo = Val(sDisplayNo)
                  \aSplitScreenInfo[nSplitScreenIndex]\sRealScreenSize = sRealScreenSize
                  \aSplitScreenInfo[nSplitScreenIndex]\nRealScreenWidth = nRealScreenWidth
                  \aSplitScreenInfo[nSplitScreenIndex]\nRealScreenHeight = nRealScreenHeight
                  \aSplitScreenInfo[nSplitScreenIndex]\nSplitScreenCount = Val(sPrefValue)
                  If \aSplitScreenInfo[nSplitScreenIndex]\nSplitScreenCount < 1
                    \aSplitScreenInfo[nSplitScreenIndex]\nSplitScreenCount = 1  ; screen count 1 means 'do not split'
                  EndIf
                  debugMsg(sProcName, "\aSplitScreenInfo[" + nSplitScreenIndex + "]\sRealScreenSize=" + \aSplitScreenInfo[nSplitScreenIndex]\sRealScreenSize +
                                      ", \nSplitScreenCount=" + \aSplitScreenInfo[nSplitScreenIndex]\nSplitScreenCount)
                  \aSplitScreenInfo[nSplitScreenIndex]\nCurrentMonitorIndex = -1  ; will be set later, where appropriate, in updateSplitScreenArray()
                EndIf
              EndIf
            EndIf
            
;           ElseIf Left(sPrefKey, 11) = "ScreenVideoRenderer_"
;             ; eg "ScreenVideoRenderer_4_3 = vre_BlackMagic_Decklink" means TVG external renderer is BlackMagioc_Decklink for screen 3 in an arrangement of 4 screens
;             debugMsg(sProcName, "sPrefKey=" + sPrefKey + ", sPrefValue=" + sPrefValue)
;             sTmp = StringField(sPrefKey, 2, "_")
;             \aScreenTVGExtRndr(nScreenTVGExtRndrIndex)\nScreensValue = Val(sTmp)  ; number of screens (4 in the above example)
;             sTmp = StringField(sPrefKey, 3, "_")
;             \aScreenTVGExtRndr(nScreenTVGExtRndrIndex)\nScreenNo = Val(sTmp)      ; screen number for these adjustment settings (3 in the above example)
;             sPrefValue = Trim(PreferenceKeyValue())
;             \aScreenTVGExtRndr(nScreenTVGExtRndrIndex)\nTVGExtRndr = encodeTVGExternalRenderer(sPrefValue)
;             debugMsg(sProcName, "\aScreenTVGExtRndr(" + nScreenTVGExtRndrIndex + ")\nScreensValue=" + \aScreenTVGExtRndr(nScreenTVGExtRndrIndex)\nScreensValue +
;                                 ", \nScreenNo=" + \aScreenTVGExtRndr(nScreenTVGExtRndrIndex)\nScreenNo +
;                                 ", \nTVGExtRndr=" + decodeTVGExternalRenderer(\aScreenTVGExtRndr(nScreenTVGExtRndrIndex)\nTVGExtRndr))
            
          EndIf
        Wend
      EndIf
    EndIf
    \nSplitScreenArrayMax = nSplitScreenIndex
;     \nScreenTVGExtRndrMax = nScreenTVGExtRndrIndex
;     debugMsg(sProcName, "grVideoDriver\nSplitScreenArrayMax=" + \nSplitScreenArrayMax + ", \nScreenTVGExtRndrMax=" + \nScreenTVGExtRndrMax)
    listSplitScreenArray()
    
  EndWith
  
  If bOpenedPreferences
    ClosePreferences()
    gbPreferencesOpen = #False
  EndIf
  
EndProcedure

Procedure loadPrefsPart1()
  PROCNAMEC()
  Protected sPart1.s, sPart2.s, nPos
  Protected sTmp.s
  Protected nDefaultVideoPlaybackLibrary
  Protected n
  Protected nSplitScreenIndex
  Protected sPrefKey.s, sPrefValue.s
  Protected sDisplayNo.s, sRealScreenSize.s
  Protected nRealScreenWidth, nRealScreenHeight
  Protected sSplitScreenInfo.s
  
  ; debugMsg(sProcName, #SCS_START)
  Debug sProcName + ": start"
  
  If Len(gsMyDocsPath) = 0
    MessageRequester(sProcName, "gsMyDocsPath not yet set")
  EndIf
  
  If OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator) = 0
    CreatePreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
  EndIf
  gbPreferencesOpen = #True
  ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  
  PreferenceGroup("VideoDriver")  ; INFO load preference group "VideoDriver"
  With grVideoDriver
    CompilerIf #c_include_tvg
      \nVideoPlaybackLibrary = #SCS_VPL_TVG
      debugMsg(sProcName, "\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary))
      \nTVGVideoRenderer = encodeVideoRenderer(ReadPreferenceString("TVGVideoRenderer", decodeVideoRenderer(#SCS_VR_AUTOSELECT, #SCS_VPL_TVG)), #SCS_VPL_TVG)
      ; debugMsg(sProcName, "\nTVGVideoRenderer=" + \nTVGVideoRenderer + " (" + decodeVideoRenderer(\nTVGVideoRenderer, #SCS_VPL_TVG) + ")")
      setVideoRendererFlag(#SCS_VPL_TVG)
      \bTVGUse2DDrawingForImages = #False
      \nTVGPlayerHwAccel = encodeTVGPlayerHwAccel(ReadPreferenceString("TVGPlayerHwAccel", ""))
      debugMsg(sProcName, "\nTVGPlayerHwAccel=" + \nTVGPlayerHwAccel + " (" + decodeTVGPlayerHwAccel(\nTVGPlayerHwAccel) + ")")
      \bTVGDisplayVUMeters = ReadPreferenceInteger("TVGDisplayVUMeters", #False)
      debugMsg(sProcName, "\bTVGDisplayVUMeters=" + strB(\bTVGDisplayVUMeters))
      grTVGControl\bDisplayVUMeters = \bTVGDisplayVUMeters ; save for use in this session, as changing the option applies the next time SCS is started
    CompilerEndIf
    
    ; split screen and screen adjustment settings
    loadPrefsScreenSettings()
    grVideoDriver\bDisableVideoWarningMessage = ReadPreferenceInteger("DisableVideoWarningMessage", 0)
  EndWith
  grVideoDriverSession = grVideoDriver ; grVideoDriverSession is used for video driver settings that MUST use the start-of-session settings (eg video renderer)
  
  PreferenceGroup("AudioDriverSM-S")  ; INFO load preference group "AudioDriverSM-S"
  With grDriverSettings
    CompilerIf #cSMSOnThisMachineOnly
      \bSMSOnThisMachine = #True
    CompilerElse
      \bSMSOnThisMachine = ReadPreferenceInteger("SMSOnThisMachine", #True)
    CompilerEndIf
    ; debugMsg(sProcName, "\bSMSOnThisMachine=" + strB(\bSMSOnThisMachine))
    
    If \bSMSOnThisMachine
      \sSMSHost = "127.0.0.1"
    Else
      \sSMSHost = ReadPreferenceString("SMSHost", "")
    EndIf
    ; debugMsg(sProcName, "\sSMSHost=" + \sSMSHost)
    
    CompilerIf #cSMSOnThisMachineOnly
      \sAudioFilesRootFolder = ""
    CompilerElse
      \sAudioFilesRootFolder = ReadPreferenceString("AudioFilesRootFolder", gsMyDocsPath)
      If \sAudioFilesRootFolder
        If FolderExists(\sAudioFilesRootFolder) = #False
          \sAudioFilesRootFolder = gsMyDocsPath
        EndIf
      EndIf
      ; debugMsg(sProcName, "\sAudioFilesRootFolder=" + \sAudioFilesRootFolder)
    CompilerEndIf
    
    \nMinPChansNonHK = ReadPreferenceInteger("MinPChansNonHK", 4)
    ; debugMsg(sProcName, "\nMinPChansNonHK=" + Str(\nMinPChansNonHK))
    
  EndWith
  
  PreferenceGroup("AudioDriverBASS")  ; INFO load preference group "AudioDriverBASS"
  With grDriverSettings
    \bSWMixer = ReadPreferenceInteger("SWMixer", #False) ; nb default was True in SCS 10
    ; debugMsg(sProcName, "\bSWMixer=" + strB(\bSWMixer))
    
    \bNoFloatingPoint = ReadPreferenceInteger("NoFloat", #False)
    ; debugMsg(sProcName, "\bNoFloatingPoint=" + strB(\bNoFloatingPoint))
    
    \bSwap34with56 = ReadPreferenceInteger("Swap34with56", #False)
    ; debugMsg(sProcName, "\bSwap34with56=" + strB(\bSwap34with56))
    
    \bNoWASAPI = ReadPreferenceInteger("NoWASAPI", #False)
    ; debugMsg(sProcName, "\bNoWASAPI=" + strB(\bNoWASAPI))
    
    \bUseBASSMixer = ReadPreferenceInteger("UseBASSMixer", #False)
    ; debugMsg(sProcName, "\bUseBASSMixer=" + strB(\bUseBASSMixer))
    
    CompilerIf #cEnableFileBufLen
      \nFileBufLen = ReadPreferenceInteger("FileBufLen", 0)
      ; debugMsg(sProcName, "\nFileBufLen=" + Str(\nFileBufLen))
    CompilerEndIf
    
    \sPlaybackBufOption = ReadPreferenceString("PlaybackBufOption", "Default")
    ; debugMsg(sProcName, "\sPlaybackBufOption=" + \sPlaybackBufOption)
    If \sPlaybackBufOption = "User"
      \nPlaybackBufLength = ReadPreferenceInteger("PlaybackBufLength", 0)
    Else
      \nPlaybackBufLength = 0
    EndIf
    ; debugMsg(sProcName, "\nPlaybackBufLength=" + \nPlaybackBufLength)
    
    \sUpdatePeriodOption = ReadPreferenceString("UpdatePeriodOption", "Default")
    ; debugMsg(sProcName, "\sUpdatePeriodOption=" + \sUpdatePeriodOption)
    If \sUpdatePeriodOption = "User"
      \nUpdatePeriodLength = ReadPreferenceInteger("UpdatePeriodLength", 0)
    Else
      \nUpdatePeriodLength = 0
    EndIf
    ; debugMsg(sProcName, "\nUpdatePeriodLength=" + \nUpdatePeriodLength)
    
    \nDSSampleRate = ReadPreferenceInteger("SampleRate", 44100)
    ; debugMsg(sProcName, "\nDSSampleRate=" + \nDSSampleRate)
    
    \nLinkSyncPoint = ReadPreferenceInteger("LinkSyncPoint", 0)
    ; debugMsg(sProcName, "\nLinkSyncPoint=" + \nLinkSyncPoint)
    gdResetPosForLinked = \nLinkSyncPoint / 1000
    
    CompilerIf #cEnableASIOBufLen
      \nAsioBufLen = ReadPreferenceInteger("ASIOBufLen", #SCS_ASIOBUFLEN_PREF)
      ; debugMsg(sProcName, "\nAsioBufLen=" + \nAsioBufLen)
    CompilerEndIf
    
    grLicInfo\bDriverOptionsLoaded = #True
    
  EndWith
  
  PreferenceGroup("GeneralOptions")  ; PreferenceGroup("GeneralOptions")
  If grLicInfo\bPlayOnly
    gbEditorAndOptionsLocked = #True
  Else
    ; AudioFlags contains Y if editor is locked (see also MMFlags)
    If ReadPreferenceString("AudioFlags", "") = "Y"
      gbEditorAndOptionsLocked = #True
    Else
      gbEditorAndOptionsLocked = #False
    EndIf
  EndIf
  
  gsTipControl = ReadPreferenceString("TipControl", "")
  ; debugMsg(sProcName, "gsTipControl=" + gsTipControl)
  
  PreferenceGroup("Editing")  ; PreferenceGroup("Editing")
  With grEditingOptions
    ; \nDefFadeInTime = ReadPreferenceInteger("DefFadeInTime", -2)
    ; debugMsg(sProcName, "grEditingOptions\nDefFadeInTime=" + Str(\nDefFadeInTime))
    ; \nDefFadeOutTime = ReadPreferenceInteger("DefFadeOutTime", -2)
    ; debugMsg(sProcName, "grEditingOptions\nDefFadeOutTime=" + Str(\nDefFadeOutTime))
    ; \nDefLoopXFadeTime = ReadPreferenceInteger("DefLoopXFadeTime", -2)
    ; debugMsg(sProcName, "grEditingOptions\nDefLoopXFadeTime=" + Str(\nDefLoopXFadeTime))
    ; \nDefSFRTimeOverride = ReadPreferenceInteger("DefSFRTimeOverride", -2)
    ; debugMsg(sProcName, "grEditingOptions\nDefSFRTimeOverride=" + Str(\nDefSFRTimeOverride))
    ; \nDefFadeInTimeI = ReadPreferenceInteger("DefFadeInTimeI", -2)
    ; debugMsg(sProcName, "grEditingOptions\nDefFadeInTimeI=" + Str(\nDefFadeInTimeI))
    ; \nDefFadeOutTimeI = ReadPreferenceInteger("DefFadeOutTimeI", -2)
    ; debugMsg(sProcName, "grEditingOptions\nDefFadeOutTimeI=" + Str(\nDefFadeOutTimeI))
  EndWith
  
  PreferenceGroup("Print")  ; INFO load preference group "Print"
  grGrdCuePrintInfo\sLayoutString = ReadPreferenceString("PrintGridColLayout2", "")
  ; debugMsg(sProcName, "grGrdCuePrintInfo\sLayoutString=" + grGrdCuePrintInfo\sLayoutString)
  
  PreferenceGroup("FileOpener")  ; INFO load preference group "FileOpener"
  grWFO\rExpListInfo\sLayoutString = ReadPreferenceString("ExpListColLayout", "")
  ; debugMsg(sProcName, "grWFO\rExpListInfo\sLayoutString=" + grWFO\rExpListInfo\sLayoutString)
  grWFO\nSplitterPos = ReadPreferenceInteger("SplitterPosWFOV", -1)
  ; debugMsg(sProcName, "grWFO\nSplitterPos=" + grWFO\nSplitterPos)
  
  ClosePreferences()
  gbPreferencesOpen = #False
  ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure loadPrefsPart2()
  PROCNAMEC()
  Protected n
  Protected sTmp.s
  Protected bFileOK, sFileName.s
  Protected sTitle.s, sText.s, nResponse
  
  ; debugMsg(sProcName, #SCS_START + ", gnMaxCueIndex=" + gnMaxCueIndex)
  Debug sProcName + ": start"
  
  If OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
    gbPreferencesOpen = #True
    ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  EndIf
  
  If grLicInfo\sLicType <> "D"
    If gnMaxCueIndex > 0
      ReDim aCue(gnMaxCueIndex + 5)  ; must be at least gnMaxCueIndex+1 to allow for dummy 'End' cue
      ReDim aSub(gnMaxCueIndex * 2)
      ReDim aAud(gnMaxCueIndex * 2)
      ReDim gaFileData(gnMaxCueIndex * 2)
    Else
      ReDim aCue(200)
      ReDim aSub(200)
      ReDim aAud(200)
      ReDim gaFileData(200)
    EndIf
  Else
    ReDim aCue(gnMaxCueIndex + 5)  ; must be at least gnMaxCueIndex+1 to allow for dummy 'End' cue
    ReDim aSub(gnMaxCueIndex * 2)
    ReDim aAud(gnMaxCueIndex * 2)
    ReDim gaFileData(gnMaxCueIndex * 2)
  EndIf
  ; debugMsg(sProcName, "ArraySize(gaFileData())=" + ArraySize(gaFileData()))
  
  ReDim a2ndCue(1)
  ReDim a2ndSub(1)
  ReDim a2ndAud(1)
  ReDim a2ndFileData(1)
  
  INIT_ARRAY(aCue, grCueDef)
  INIT_ARRAY(aSub, grSubDef)
  INIT_ARRAY(aAud, grAudDef)
  INIT_ARRAY(gaFileData, grFileDataDef)
  
  INIT_ARRAY(a2ndCue, grCueDef)
  INIT_ARRAY(a2ndSub, grSubDef)
  INIT_ARRAY(a2ndAud, grAudDef)
  INIT_ARRAY(a2ndFileData, grFileDataDef)
  
  PreferenceGroup("RecentFiles")  ; PreferenceGroup("RecentFiles")
  gnRecentFileCount = 0
  For n = 1 To #SCS_MAXRFL_SAVED
    bFileOK = #False
    sFileName = ReadPreferenceString("File" + Trim(Str(n)), "")
    If Len(sFileName) > 4 And LCase(Right(Trim(sFileName), 4)) = ".scs"
      bFileOK = #True
    ElseIf Len(sFileName) > 5 And LCase(Right(Trim(sFileName), 5)) = ".scsq"
      bFileOK = #True
    ElseIf Len(sFileName) > 6 And LCase(Right(Trim(sFileName), 6)) = ".scs11"
      bFileOK = #True
    EndIf
    If bFileOK
      If FileExists(sFileName, #False)
        gsRecentFile(gnRecentFileCount) = sFileName
        ; debugMsg(sProcName, "gsRecentFile(" + gnRecentFileCount + ")=" + gsRecentFile(gnRecentFileCount))
        gnRecentFileCount + 1
      EndIf
    EndIf
  Next n
  ; debugMsg(sProcName, "gnRecentFileCount=" + Str(gnRecentFileCount))
  If gnRecentFileCount = 0
    ; Commented out 20Jun2020 11.8.3.2af because testing shows there could be a permissions problem when trying to rename file scs_demo.scs11 in <gsCommonAppDataPath>,
    ; so reinstated using <gsMyDocsPath>. Must be in sync with Inno setup scripts.
    ; If FileExists(gsCommonAppDataPath + "scs_demo\demo.scs11")
    ;   gsRecentFile(0) = gsCommonAppDataPath + "scs_demo\demo.scs11"
    ;   gnRecentFileCount = 1
    ; EndIf
;     If FileExists(gsMyDocsPath + "scs_demo\demo.scs11")
;       gsRecentFile(0) = gsMyDocsPath + "scs_demo\demo.scs11"
;       gnRecentFileCount = 1
;     EndIf
    ; Changed the above 28Oct2022 11.9.6 to use Dee's revised demo file
    If FileExists(gsMyDocsPath + "SCS_Demo\SCS11_Demo_v2.scs11")
      gsRecentFile(0) = gsMyDocsPath + "SCS_Demo\SCS11_Demo_v2.scs11"
      gnRecentFileCount = 1
    EndIf
  EndIf
  
  PreferenceGroup("LoadProd")
  With grLoadProdPrefs
    \bShowAtStart = ReadPreferenceInteger("ShowAtStart", 1)
    \nBlankCount = ReadPreferenceInteger("BlankCount", 0)
    ; Changed the following 9Jan2025 11.10.6-b02 to allow for no DirectSound available, as reported by Terry McKnight
    sTmp = ReadPreferenceString("AudioDriver", "")
    debugMsg0(sProcName, "gnDSDeviceCount=" + gnDSDeviceCount + ", gnWASAPIDeviceCount=" + gnWASAPIDeviceCount + ", sTmp=" + sTmp)
    If sTmp
      \nAudioDriver = encodeAudioDriver(sTmp)
      If \nAudioDriver = #SCS_DRV_BASS_DS And gnDSDeviceCount = 0
        \nAudioDriver = 0 ; not defined
      ElseIf \nAudioDriver = #SCS_DRV_BASS_WASAPI And gnWASAPIDeviceCount = 0
        \nAudioDriver = 0
      ElseIf \nAudioDriver = #SCS_DRV_BASS_ASIO And gnAsioDeviceCount = 0
        \nAudioDriver = 0
      EndIf
    Else
      \nAudioDriver = 0
    EndIf
    If \nAudioDriver = 0
      If gnDSDeviceCount > 0
        \nAudioDriver = #SCS_DRV_BASS_DS
      ElseIf gnWASAPIDeviceCount > 0
        \nAudioDriver = #SCS_DRV_BASS_WASAPI
      EndIf
    EndIf
    \sAudPrimaryDev = ReadPreferenceString("AudPrimaryDev", "")
    \sDevMapName = ReadPreferenceString("DevMapName", "")
  EndWith
  
  PreferenceGroup("GeneralOptions")  ; PreferenceGroup("GeneralOptions")
  With grGeneralOptions
    
    CompilerIf #cTutorialVideoOrScreenShots
      \sInitDir = "C:\Users\SCS-Mike\Dropbox\SCS General\SCS Tutorials"
      If FolderExists(\sInitDir) = #False
        \sInitDir = ReadPreferenceString("InitDir", gsMyDocsPath)
      EndIf
    CompilerElse
      \sInitDir = ReadPreferenceString("InitDir", gsMyDocsPath)
    CompilerEndIf
    If Len(\sInitDir) > 0
      If FolderExists(\sInitDir) = #False
        \sInitDir = gsMyDocsPath
      EndIf
    EndIf
    ; debugMsg(sProcName, "\sInitDir=" + \sInitDir)
    gsAudioFileDialogInitDir = \sInitDir
    gsVideoDefaultFile = \sInitDir
    gsMidiDefaultFile = \sInitDir
    
    \bDisableRightClickAsGo = ReadPreferenceInteger("DisableRightClickAsGo", #False)
    ; debugMsg(sProcName, "\bDisableRightClickAsGo=" + strB(\bDisableRightClickAsGo))
    
    \bCtrlOverridesExclCue = ReadPreferenceInteger("CtrlOverridesExclCue", #False)
    ; debugMsg(sProcName, "\bCtrlOverridesExclCue=" + strB(\bCtrlOverridesExclCue))
    
    \bHotkeysOverrideExclCue = ReadPreferenceInteger("HotkeysOverrideExclCue", #False)
    ; debugMsg(sProcName, "\bHotkeysOverrideExclCue=" + strB(\bHotkeysOverrideExclCue))
    
    \nDoubleClickTime = ReadPreferenceInteger("DoubleClickTime", 400)
    ; debugMsg(sProcName, "\nDoubleClickTime=" + \nDoubleClickTime)
    
    \nFadeAllTime = ReadPreferenceInteger("FadeAllTime", 1000)
    ; debugMsg(sProcName, "\nFadeAllTime=" + \nFadeAllTime)
    
    \bApplyTimeoutToOtherGos = ReadPreferenceInteger("ApplyTimeout", #True)
    ; debugMsg(sProcName, "\bApplyTimeoutToOtherGos=" + strB(\bApplyTimeoutToOtherGos))
    
    \nMaxPreOpenAudioFiles = ReadPreferenceInteger("MaxPreOpenFiles", 40)
    If \nMaxPreOpenAudioFiles > gnMaxPreOpenAudioFilesForLicLevel
      \nMaxPreOpenAudioFiles = gnMaxPreOpenAudioFilesForLicLevel
    EndIf
    If \nMaxPreOpenAudioFiles < 2
      \nMaxPreOpenAudioFiles = 2
    EndIf
    ; debugMsg(sProcName, "\nMaxPreOpenAudioFiles=" + \nMaxPreOpenAudioFiles)
    
    \nMaxPreOpenVideoImageFiles = ReadPreferenceInteger("MaxPreOpenVideoImageFiles", 20)
    If \nMaxPreOpenVideoImageFiles > gnMaxPreOpenVideoImageFilesForLicLevel
      \nMaxPreOpenVideoImageFiles = gnMaxPreOpenVideoImageFilesForLicLevel
    EndIf
    If \nMaxPreOpenVideoImageFiles < 2
      \nMaxPreOpenVideoImageFiles = 2
    EndIf
    ; debugMsg(sProcName, "\nMaxPreOpenVideoImageFiles=" + \nMaxPreOpenVideoImageFiles)
    
    \sTimeFormat = ReadPreferenceString("TimeFormat", "A")
    ; debugMsg(sProcName, "\sTimeFormat=" + \sTimeFormat)
    Select \sTimeFormat
      Case "A"
        \nTimeFormat = #SCS_TIME_FORMAT_A
      Case "B"
        \nTimeFormat = #SCS_TIME_FORMAT_B
      Default
        \nTimeFormat = #SCS_TIME_FORMAT_C
    EndSelect
    
    \sDBIncrement = ReadPreferenceString("DBIncrement", "0.3")
    ; debugMsg(sProcName, "\sDBIncrement=" + \sDBIncrement)
    
    CompilerIf #cDemo = #False And #cWorkshop = #False
      \bEnableAutoCheckForUpdate = ReadPreferenceInteger("EnableAutoCheckForUpdate", #True)
      \nDaysBetweenChecks = ReadPreferenceInteger("DaysBetweenChecks", #SCS_MISC_DFLT_DAYS_BETWEEN_CHECKS)
    CompilerEndIf
    
  EndWith
  
  PreferenceGroup("Shortcuts")  ; PreferenceGroup("Shortcuts")
  For n = 0 To ArraySize(gaShortcutsMain())
    With gaShortcutsMain(n)
      \sShortcutStr = Trim(ReadPreferenceString(\sFunctionPrefKey, \sDefaultShortcutStr))
      \nShortcut = encodeShortcut(\sShortcutStr)
      \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
      ; debugMsg(sProcName, "(1) gaShortcutsMain(" + n + ")\sFunctionPrefKey=" + \sFunctionPrefKey + ", \sShortcutStr=" + \sShortcutStr + ", \nShortcut=$" + Hex(\nShortcut) + ", \nShortcutVK=$" + Hex(\nShortcutVK))
    EndWith
  Next n
  
  PreferenceGroup("ShortcutsEditor")  ; PreferenceGroup("ShortcutsEditor")
  For n = 0 To ArraySize(gaShortcutsEditor())
    With gaShortcutsEditor(n)
      \sShortcutStr = Trim(ReadPreferenceString(\sFunctionPrefKey, \sDefaultShortcutStr))
      \nShortcut = encodeShortcut(\sShortcutStr)
      \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
      ; debugMsg(sProcName, "(2) gaShortcutsEditor(" + n + ")\sShortcutStr=" + \sShortcutStr + ", \nShortcut=$" + Hex(\nShortcut) + ", \nShortcutVK=$" + Hex(\nShortcutVK))
    EndWith
  Next n
  
  PreferenceGroup("Print")  ; INFO load preference group "Print"
  With grPrintOptions
    \bChkA = #False
    \bChkE = #False
    \bChkF = #False
    \bChkG = #False
    \bChkI = #False
    \bChkJ = #False
    \bChkK = #False
    \bChkL = #False
    \bChkM = #False
    \bChkN = #False
    \bChkP = #False
    \bChkQ = #False
    \bChkR = #False
    \bChkS = #False
    \bChkT = #False
    \bChkU = #False
    sTmp = ReadPreferenceString("CueTypes", "AEFGIJKLMNPQRSTU")
    If FindString(sTmp, "A", 1) > 0 : \bChkA = #True : EndIf
    If FindString(sTmp, "E", 1) > 0 : \bChkE = #True : EndIf
    If FindString(sTmp, "F", 1) > 0 : \bChkF = #True : EndIf
    If FindString(sTmp, "G", 1) > 0 : \bChkG = #True : EndIf
    If FindString(sTmp, "I", 1) > 0 : \bChkI = #True : EndIf
    If FindString(sTmp, "J", 1) > 0 : \bChkJ = #True : EndIf
    If FindString(sTmp, "K", 1) > 0 : \bChkK = #True : EndIf
    If FindString(sTmp, "L", 1) > 0 : \bChkL = #True : EndIf
    If FindString(sTmp, "M", 1) > 0 : \bChkM = #True : EndIf
    If FindString(sTmp, "N", 1) > 0 : \bChkN = #True : EndIf
    If FindString(sTmp, "P", 1) > 0 : \bChkP = #True : EndIf
    If FindString(sTmp, "Q", 1) > 0 : \bChkQ = #True : EndIf
    If FindString(sTmp, "R", 1) > 0 : \bChkR = #True : EndIf
    If FindString(sTmp, "S", 1) > 0 : \bChkS = #True : EndIf
    If FindString(sTmp, "T", 1) > 0 : \bChkT = #True : EndIf
    If FindString(sTmp, "U", 1) > 0 : \bChkU = #True : EndIf
    \bIncludeHotkeys = ReadPreferenceInteger("IncludeHotkeys", #True)
    \bIncludeSubCues = ReadPreferenceInteger("IncludeSubCues", #True)
    \bManualCuesOnly = ReadPreferenceInteger("ManualCuesOnly", #False)
  EndWith
  
  PreferenceGroup("Collect")  ; INFO load preference group "Collect"
  With grCollectOptions
    \bCopyColorFile = ReadPreferenceInteger("CopyColorFile", #True)
    \bExcludePlaylists = ReadPreferenceInteger("ExcludePlaylists", #False)
    \bSwitchToCollected = ReadPreferenceInteger("Switch", #True)
  EndWith
  
  PreferenceGroup("Editing")  ; INFO load preference group "Editing"
  With grEditingOptions
    
    \sAudioEditor = ReadPreferenceString("AudioEditor", "")
    ; debugMsg(sProcName, "\sAudioEditor=" + \sAudioEditor)
    If \sAudioEditor
      If FileExists(\sAudioEditor) = #False
        ; debugMsg(sProcName, "Audio Editor not found - clearing \sAudioEditor")
        \sAudioEditor = ""
      EndIf
    EndIf
    
    \sImageEditor = ReadPreferenceString("ImageEditor", "")
    ; debugMsg(sProcName, "\sImageEditor=" + \sImageEditor)
    If \sImageEditor
      If FileExists(\sImageEditor) = #False
        ; debugMsg(sProcName, "Image Editor not found - clearing \sImageEditor")
        \sImageEditor = ""
      EndIf
    EndIf
    
    \sVideoEditor = ReadPreferenceString("VideoEditor", "")
    ; debugMsg(sProcName, "\sVideoEditor=" + \sVideoEditor)
    If \sVideoEditor
      If FileExists(\sVideoEditor) = #False
        ; debugMsg(sProcName, "Video Editor not found - clearing \sVideoEditor")
        \sVideoEditor = ""
      EndIf
    EndIf
    
  EndWith
  
  ;- Functional Mode Options (ie SCS Primary, SCS Backup, or Stand-Alone)
  Debug sProcName + ": grLicInfo\bFMAvailable=" + strB(grLicInfo\bFMAvailable)
  With grFMOptions
    If grLicInfo\bFMAvailable
      PreferenceGroup("FMOptions")  ; INFO load preference group "FMOptions"
      sTmp = ReadPreferenceString("Mode", "")
      \nFunctionalMode = encodeFunctionalMode(sTmp)
      Debug sProcName + ": \nFunctionalMode=" + decodeFunctionalMode(\nFunctionalMode)
      \sFMServerName = ReadPreferenceString("FMServerName", "")
      \sFMLocalIPAddr = ReadPreferenceString("FMLocalIPAddr", "")
      If \nFunctionalMode <> #SCS_FM_STAND_ALONE
        sTitle = Lang("Common", "FunctionalMode")
        sText = LangPars("Requesters", "SetFM", UCase(decodeFunctionalModeL(\nFunctionalMode)))
        nResponse = scsMessageRequester(sTitle, sText, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
        If nResponse <> #PB_MessageRequester_Yes
          \nFunctionalMode = #SCS_FM_STAND_ALONE
        EndIf
      EndIf
      \bBackupIgnoreCSMIDI = ReadPreferenceInteger("B_IgnoreCSMIDI", #False)
      \bBackupIgnoreCSNetwork = ReadPreferenceInteger("B_IgnoreCSNetwork", #False)
      \bBackupIgnoreLightingDMX = ReadPreferenceInteger("B_IgnoreLightingDMX", #False)
      \bBackupIgnoreCCDevs = ReadPreferenceInteger("B_IgnoreCCDevs", #False) ; Added 30Oct2021 11.8.6bn
      If \nFunctionalMode <> #SCS_FM_STAND_ALONE
        samAddRequest(#SCS_SAM_INIT_FM, #False)
      EndIf
    Else
      \nFunctionalMode = #SCS_FM_STAND_ALONE
    EndIf
  EndWith
  
  ClosePreferences()
  gbPreferencesOpen = #False
  ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  
  ; debugMsg(sProcName, #SCS_END)
  Debug sProcName + ": End"
  
EndProcedure

Procedure setPrefOperModeDefaults()
  PROCNAMEC()
  
  ;- operational mode defaults
  
  ; design mode
  With grOperModeOptionDefs(#SCS_OPERMODE_DESIGN)
    ; see also WOP_btnDefaultDisplayOptions_Click() in fmOptions.pbi
    ; ordered below as per the screen layout
    
    ; Color Scheme
    \sSchemeName              = #SCS_COL_DEF_SCHEME_NAME
    
    ; Control Panel
    \nCtrlPanelPos            = #SCS_CTRLPANEL_TOP
    \nMainToolBarInfo         = #SCS_TOOL_DISPLAY_ALL
    \nVisMode                 = #SCS_VU_LEVELS
    \bShowNextManualCue       = #True
    \bShowMasterFader         = #True
    
    ; Cue List, Cue Panels and Hotkey List
    \nCueListFontSize         = -1
    \nCuePanelVerticalSizing  = 100
    \bShowSubCues             = #True
    \bShowHiddenAutoStartCues = #False
    \bShowHotkeyCuesInPanels  = #True
    \bShowHotkeyList          = #True
    \bShowTransportControls   = #True
    \bShowFaderAndPanControls = #True
    \bRequestConfirmCueClick  = #False
    \bLimitMovementOfMainWindowSplitterBar = #True
    
    ; Audio File Progress Slider extras
    \bShowLvlCurvesPrim       = #True
    \bShowLvlCurvesOther      = #True
    \bShowPanCurvesPrim       = #True
    \bShowPanCurvesOther      = #True
    \bShowAudioGraph          = #True
    \bShowCueMarkers          = #True
    
    ; Other Display Options
    \nMonitorSize             = #SCS_MON_NONE
    \nMTCDispLocn             = #SCS_MTC_DISP_VU_METERS
    \nTimerDispLocn           = #SCS_PTD_STATUS_LINE
    ; \nMaxMonitor              = -1 ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
    \bShowToolTips            = #True
    \nMidiInDisplayTimeout    = 5000
    
    ; hidden display options
    \bHideCueList             = #False
    \nPeakMode                = #SCS_PEAK_AUTO
    \nVUBarWidth              = #SCS_VUBARWIDTH_NARROW
    \rGrdCuesInfo\sLayoutString = ""
  EndWith
  
  ; rehearsal mode
  grOperModeOptionDefs(#SCS_OPERMODE_REHEARSAL) = grOperModeOptionDefs(#SCS_OPERMODE_DESIGN)
  With grOperModeOptionDefs(#SCS_OPERMODE_REHEARSAL)
    \bShowTransportControls   = #False
    \bRequestConfirmCueClick  = #True
    \nMonitorSize             = #SCS_MON_STD
  EndWith
  
  ; performance mode
  grOperModeOptionDefs(#SCS_OPERMODE_PERFORMANCE) = grOperModeOptionDefs(#SCS_OPERMODE_REHEARSAL)
  With grOperModeOptionDefs(#SCS_OPERMODE_PERFORMANCE)
    ; \nMainToolBarInfo         = #SCS_TOOL_DISPLAY_NONE
    ; As from 10Nov2021 11.8.6bv, the default maintoolbar info for performance mode was changed from 'none' to 'min' (see also encodeMainToolBarInfo())
    \nMainToolBarInfo         = #SCS_TOOL_DISPLAY_MIN
    \bShowSubCues             = #False
    \bShowFaderAndPanControls = #False
    \bShowToolTips            = #False
    \nMonitorSize             = #SCS_MON_STD
  EndWith
  
EndProcedure

Procedure setIndependantDefaults()
  PROCNAMEC()
  Protected d, n, m
  Protected sDefVidAudDev.s
  Protected sGroupName.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  sDefVidAudDev = Lang("Init", "DefVidAudDev")
  sGroupName = Lang("Common", "Group")
  
  ;- prod defaults
  ; debugMsg(sProcName, "set prod defaults")
  With grProdDef
    ;{
    \nProdId = -1
    \sTitle = #SCS_UNTITLED
    \nDefChaseSpeed = 80
    \nDefDMXFadeTime = -2
    \nDefFadeInTime = -2
    \nDefFadeInTimeI = -2
    \nDefFadeOutTime = -2
    \nDefFadeOutTimeI = -2
    \nDefLoopXFadeTime = -2
    \nDefSFRAction = #SCS_SFR_ACT_NA
    \nDefSFRTimeOverride = -2
    ; Added 5Feb2025 11.10.7aa for Video/Image sub-cues
    \nDefFadeInTimeA = -2
    \nDefFadeOutTimeA = -2
    \nDefDisplayTimeA = 5000
    \bDefRepeatA = #False
    \bDefPauseAtEndA = #False
    ; End added 5Feb2025 11.10.7aa for Video/Image sub-cues
    \nDefOutputScreen = 2 ; nb +2, not -2!
    \nCueAutoStartRange = #SCS_CUE_AUTO_START_RANGE_EARLIER
    \nSelectedDevMapPtr = -1
    ; logical device array info
    ; note that the array sizes must ALWAYS be at least one greater than the corresponding \nMax...LogicalDev value to allow fmEditProd to display a blank item for a new entry
    \nMaxAudioLogicalDev = -1
    \nMaxVidAudLogicalDev = -1
    \nMaxVidCapLogicalDev = -1
    \nMaxFixType = -1
    \nMaxLightingLogicalDev = -1
    \nMaxCtrlSendLogicalDev = -1
    \nMaxCueCtrlLogicalDev = -1
    \nMaxLiveInputLogicalDev = -1
    \nMaxInGrp = -1
    ; audio levels
    \fPreviewBVLevel = convertDBStringToBVLevel("0dB")
    \sTestToneDBLevel = StrF(-6.0, 1)  ; = "-6.0" or "-6,0"
    \fTestToneBVLevel = convertDBStringToBVLevel(\sTestToneDBLevel)
    \fTestTonePan = #SCS_PANCENTRE_SINGLE ; 4May2022am
    \nTestSound = #SCS_TEST_TONE_SINE ; 3May2022pm 11.9.1
    \sMasterDBVol = "0.0" ; 0dB
    \fMasterBVLevel = convertDBStringToBVLevel(\sMasterDBVol)
    \sDBLevelChangeIncrement = "1.0"
    \nMinDBLevel = -75 ; =75dB  Changed from -160 to -75 5Aug2023 11.10.0bx (it was -75dB pre SCS 11.8.3.2) 
    ;
    \nDMXMasterFaderValue = 100 ; 100% = no fade
    \bLabelsUCase = #True
    \nRunMode = #SCS_RUN_MODE_LINEAR   ; = linear mode (default)
    \nVisualWarningTime = #SCS_VWT_NOT_SET
    \nCueLabelIncrement = 1
    \nResetTOD = -1
    \nFocusPoint = #SCS_FOCUS_NEXT_MANUAL
    \nGridClickAction = #SCS_GRDCLICK_GOTO_CUE
    ;}
  EndWith
  
  ; debugMsg(sProcName, "calling setProdGlobals(#True)")
  ; must call setProdGlobals(#True) here (approx) as settings are required later in this procedure, particularly for setting the default dB levels for audio devices
  grProd = grProdDef
  setProdGlobals(#True, #True)
  
  ; NOTE: The following 'gr...LogicalDevsDef' globals must be populated AFTER calling setProdGlobals()
  
  ;- grAudioLogicalDevsDef
  With grAudioLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    \sDfltDBLevel = grLevels\sDefaultDBLevel
    \fDfltBVLevel = convertDBStringToBVLevel(\sDfltDBLevel)
    \sDfltDBTrim = #SCS_DEFAULT_DBTRIM
    \fDfltTrimFactor = dbTrimStringToFactor(\sDfltDBTrim)
    \fDfltPan = #SCS_PANCENTRE_SINGLE
    \nBassDevice = -1
    \nBassASIODevice = -1
    \nPhysicalDevPtr = -1
    ;}
  EndWith
  
  ;- grVidAudLogicalDevsDef
  With grVidAudLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    \sVidAudLogicalDev = ""
    \bAutoInclude = #False
    \sDfltDBLevel = grLevels\sDefaultDBLevel
    \fDfltBVLevel = convertDBStringToBVLevel(\sDfltDBLevel)
    \sDfltDBTrim = #SCS_DEFAULT_DBTRIM
    \fDfltTrimFactor = dbTrimStringToFactor(\sDfltDBTrim)
    \fDfltPan = #SCS_PANCENTRE_SINGLE
    \nPhysicalDevPtr = -1
    ;}
  EndWith
  
  ;- grVidCapLogicalDevsDef
  With grVidCapLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    \sLogicalDev = ""
    \bAutoInclude = #False
    \nPhysicalDevPtr = -1
    ;}
  EndWith
  
  ;- grFixTypeChanDef and grFixTypesDef
  With grFixTypeChanDef
    ;{
    \sDefault = "0"
    \nDMXTextColor = -1 ; indicates 'not set'
    ;}
  EndWith
  With grFixTypesDef
    ;{
    ReDim \aFixTypeChan(#SCS_MAX_FIX_TYPE_CHANNEL)
    For n = 0 To ArraySize(\aFixTypeChan())
      \aFixTypeChan(n) = grFixTypeChanDef
    Next n
    \nTotalChans = 1
    \aFixTypeChan(0)\nChanNo = 1
    ;}
  EndWith
  
  ;- grDevFixtureDef
  With grDevFixtureDef
    ;{
    \nDevDMXStartChannel = -2
    ;}
  EndWith
  
  ;- grLightingLogicalDevsDef
  With grLightingLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    \nDevId = -1
    \nMaxFixture = -1
    ;}
  EndWith
  
  ;- grCtrlSendLogicalDevsDef
  With grCtrlSendLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    \nDevId = -1
    \bM2TSkipEarlierCtrlMsgs = #False
    ; midi defaults
    \nCtrlMidiRemDevId = -1
    ; network defaults
    \nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_ANY
    \nOSCVersion = #SCS_OSC_VER_1_0
    \nNetworkProtocol = #SCS_NETWORK_PR_TCP
    \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
    \bReplyMsgAddCR = #True
    \bReplyMsgAddLF = #False
    \nDelayBeforeReloadNames = 100    ; 100 ms
    \nMaxMsgResponse = -1
    \nOSCVersion = -1 ; indicates not OSC
    ; dmx defaults
    ; rs232 defaults
    \nRS232BaudRate = grRS232ControlDefault\nRS232BaudRate
    \nRS232Parity = grRS232ControlDefault\nRS232Parity
    \nRS232DataBits = grRS232ControlDefault\nRS232DataBits
    \fRS232StopBits = grRS232ControlDefault\fRS232StopBits
    \nRS232Handshaking = grRS232ControlDefault\nRS232Handshaking
    \nRS232RTSEnable = grRS232ControlDefault\nRS232RTSEnable
    \nRS232DTREnable = grRS232ControlDefault\nRS232DTREnable
    ; midi defaults
    ;}
  EndWith
  
  ;- grMidiCommandDef
  ; (must be populated BEFORE grCueCtrlLogicalDevsDef)
  With grMidiCommandDef
    ;{
    \nCmd = -1
    \nCC = -1
    \nVV = -1
    ;}
  EndWith
  
  ;- grCueCtrlLogicalDevsDef
  ; (requires grMidiCommandDef to be populated)
  With grCueCtrlLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    ; \sCueCtrlLogicalDev = "C" + Str(d+1)
    \sCueCtrlLogicalDev = "C1"
    \nDevId = -1
    ; midi defaults
    For n = 0 To #SCS_MAX_MIDI_COMMAND
      \aMidiCommand[n] = grMidiCommandDef
    Next n
    ; network defaults
    \nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_ANY
    \nNetworkProtocol = #SCS_NETWORK_PR_TCP
    \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
    \nOSCVersion = -1 ; indicates not OSC
    ; dmx defaults
    \nDMXInPref = #SCS_DMX_NOTATION_0_255
    \nDMXTrgCtrl = #SCS_DMX_TRG_CHG_UP_TO_VALUE
    \nDMXTrgValue = 255
    For n = 0 To #SCS_MAX_DMX_COMMAND
      \aDMXCommand[n]\nChannel = -1
    Next n
    ; rs232 defaults
    \nRS232BaudRate = grRS232ControlDefault\nRS232BaudRate
    \nRS232Parity = grRS232ControlDefault\nRS232Parity
    \nRS232DataBits = grRS232ControlDefault\nRS232DataBits
    \fRS232StopBits = grRS232ControlDefault\fRS232StopBits
    \nRS232Handshaking = grRS232ControlDefault\nRS232Handshaking
    \nRS232RTSEnable = grRS232ControlDefault\nRS232RTSEnable
    \nRS232DTREnable = grRS232ControlDefault\nRS232DTREnable
    ;}
  EndWith
  
  ;- grLiveInputLogicalDevsDef
  With grLiveInputLogicalDevsDef
    ;{
    \nDevType = #SCS_DEVTYPE_NONE
    \sDfltInputDBLevel = grLevels\sDefaultDBLevel
    \fDfltInputLevel = convertDBStringToBVLevel(\sDfltInputDBLevel)
    \nPhysicalDevPtr = -1
    ;}
  EndWith
  
  With grInGrpsDef
    \nMaxInGrpItem = -1
  EndWith
  
  With grProdDef
    ;{
    \aAudioLogicalDevs(0) = grAudioLogicalDevsDef
    \aVidAudLogicalDevs(0) = grVidAudLogicalDevsDef
    \aVidCapLogicalDevs(0) = grVidCapLogicalDevsDef
    \aFixTypes(0) = grFixTypesDef
    \aLightingLogicalDevs(0) = grLightingLogicalDevsDef
    \aCtrlSendLogicalDevs(0) = grCtrlSendLogicalDevsDef
    \aCueCtrlLogicalDevs(0) = grCueCtrlLogicalDevsDef
    \aLiveInputLogicalDevs(0) = grLiveInputLogicalDevsDef
    \aInGrps(0) = grInGrpsDef
    ;}
  EndWith
  
  grProd = grProdDef
  grProdDefForAdd = grProdDef
  
  ;- template defaults
  grTmCueDef\bIncludeCue = #True
  grTmDevDef\bIncludeDev = #True
  grTmDevMapDef\bIncludeDevMap = #True
  
  ;- multimedia defaults
  With grMMedia
    \sTestToneFadeTime = "0.2"
    \nCurrGaplessSeqPtr = -1
  EndWith
  
  ;- vid pic target defaults
  With grVidPicTargetDef
    \nPlayingSubPtr = -1
    \nPrevPlayingSubPtr = -1
    \nPrevPrimaryAudPtr = -1
    \nPrimaryAudPtr = -1
    \nCurrentSubPtr = -1
    \nAudPtr1 = -1
    \nAudPtr2 = -1
  EndWith
  For n = 0 To ArraySize(grVidPicTarget())
    grVidPicTarget(n) = grVidPicTargetDef
  Next n
  
  ;- TVG defaults
  ; see also initTVG()
  With grTVGControl
    \nMaxTVGIndex = -1
    \nNextTVGNo = 5001
    \qTimeOfLastIsPlayingCheck = ElapsedMilliseconds()
    \nDisplayMonitor = -1
    \nTVGWorkControlIndex = -1
    \nMaxAudioDev = -1
  EndWith
  
  ;- MTC defaults
  With grMTCSendControlDef
    \nMTCSubPtr = -1
    \nMTCLinkedToAudPtr = -1
    \nMTCCuesPhysicalDevPtr = -1
    \nMTCPanelIndex = -1
  EndWith
  grMTCSendControl = grMTCSendControlDef
  ; debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(grMTCSendControl\bMTCCuesPortOpen))
  grWTC\bCheckWindowExistsAndVisible = #True
  grWTI\bCheckWindowExistsAndVisible = #True
  
  ;- device map defaults (see also setDefaults_All())
  ; debugMsg(sProcName, "set device map defaults")
  With grMaps
    \nMaxMapIndex = -1
    \nMaxDevIndex = -1
    \nMaxLiveGrpIndex = -1
  EndWith
  With grDevMapDef
    \nFirstDevIndex = -1
    \nFirstLiveGrpIndex = -1
  EndWith
;   For n = 0 To ArraySize(gaDevMap())
;     gaDevMap(n) = grDevMapDef
;   Next n
  
  ;- RS232 defaults
  With grRS232ControlDefault
    \bDummy = #False
    \bRS232In = #False
    \bRS232Out = #False
    ; default settings:
    \nRS232BaudRate = 9600
    \nRS232Parity = #PB_SerialPort_NoParity
    \nRS232DataBits = 8
    \fRS232StopBits = 1
    \nRS232Handshaking = #PB_SerialPort_XonXoffHandshake
    \nRS232RTSEnable = 0    ; No
    \nRS232DTREnable = 0    ; No
    \nInBufferSize = 1024
    \nOutBufferSize = 1024
  EndWith
  
  ;- device map device defaults
  ; debugMsg(sProcName, "set device map device defaults")
  With grDevMapDevDef
    \nDevGrp = #SCS_DEVGRP_NONE
    \nDevType = #SCS_DEVTYPE_NONE
    \nPrevDevIndex = -1
    \nNextDevIndex = -1
    \nPhysicalDevPtr = -1
    \nReassignDevMapDevPtr = -1
    \nMixerStreamPtr = -1
    \nDevMapId = -1
    \nDevId = -1
    
    ;- audio output values
    \sDevOutputGainDB = "0.0"
    \fDevOutputGain = convertDBStringToBVLevel(\sDevOutputGainDB)
    
    ;- live input values
    \sInputGainDB = "0.0"
    \fInputGain = convertDBStringToBVLevel(\sInputGainDB)
    
    ;- EQ
    \nInputLowCutFreq = 100
    For n = 0 To #SCS_MAX_EQ_BAND
      \aInputEQBand[n]\sEQGainDB = "0.0"
      Select n
        Case 0
          \aInputEQBand[n]\nEQFreq = 150
        Case 1
          \aInputEQBand[n]\nEQFreq = 600
      EndSelect
      \aInputEQBand[n]\fEQQ = 4.0
    Next n
    
    ;- ctrl send and cue ctrl values for Network connection
    \nLocalPort = -2
    \nRemotePort = -2
    \nCtrlSendDelay = -2     ; control send inter-message delay time (for network messages)
    ; for pre build 20150401
    \bReplyMsgAddCRx = #True
    \bReplyMsgAddLFx = #False
    \nMaxMsgResponsex = -1
    ; end of pre build 20150401
    
    ;- cue ctrl values for MIDI In
    \nMidiInPhysicalDevPtr = -1
    ; for pre build 20150401
    For n = 0 To #SCS_MAX_MIDI_COMMAND
      \aMidiCommandx[n]\nCmd = -1
      \aMidiCommandx[n]\nCC = -1
      \aMidiCommandx[n]\nVV = -1
    Next n
    
    ;- cue ctrl values for DMX In
    ; for pre build 20150401
    \nDMXTrgCtrlx = #SCS_DMX_TRG_CHG_UP_TO_VALUE
    \nDMXTrgValuex = 255
    For n = 0 To #SCS_MAX_DMX_COMMAND
      \aDMXCommandx[n]\nChannel = -1
    Next n
    
    ; lighting and cue ctrl DMX
    \sDMXIpAddress = "127.0.0.1"
    \nDMXPort = 1
    \nDMXRefreshRate = 40 ; 40 fps
    
  EndWith
  For n = 0 To ArraySize(grMaps\aDev())
    grMaps\aDev(n) = grDevMapDevDef
  Next n
  
  ; connected device defaults
  With grConnectedDevDef
    \nDevType = #SCS_DEVTYPE_NONE
    \nDevice = -1
  EndWith
  
  With grAudioDevDef
    \nBassDevice = -1
    \nDevBassASIODevice = -1
  EndWith
  
  With grDMXCommandDef
    \nChannel = -1
  EndWith
  
  ;- device map live input group defaults
  With grLiveGrpDef
    \nDevGrp = #SCS_DEVGRP_NONE
    \nDevType = #SCS_DEVTYPE_NONE
    \nPrevLiveGrpIndex = -1
    \nNextLiveGrpIndex = -1
  EndWith
  For n = 0 To ArraySize(grMaps\aLiveGrp())
    grMaps\aLiveGrp(n) = grLiveGrpDef
  Next n
  
  ;- mixer stream defaults
  ; debugMsg(sProcName, "set mixer stream defaults")
  With grMixerStreamDef
    \nBassDevice = -1
    \nBassASIODevice = -1
    \nFlags = #BASS_SAMPLE_FLOAT
    \nSampleRate = 44100
  EndWith
  For d = 0 To ArraySize(gaMixerStreams())
    gaMixerStreams(d) = grMixerStreamDef
  Next d
  
  ;- gapless seq defaults
  ; debugMsg(sProcName, "set gapless seq defaults")
  With grGaplessSeqDef
    \nFirstGaplessAudPtr = -1
    \nLastGaplessAudPtr = -1
    \nCurrGaplessAudPtr = -1
    \nSampleRate = 44100  ; TEMP !!!!!!!!!!!!!!!!!!!!!!!!
    \nTimeLineChannel = -1
  EndWith
  For n = 0 To ArraySize(gaGaplessSeqs())
    gaGaplessSeqs(n) = grGaplessSeqDef
  Next n
  
  ;- controller (control surface) defaults
  ; debugMsg(sProcName, "set controller defaults")
  With grCtrlSetupDef
    \nController = #SCS_CTRL_NONE; Changed 20Jun2022 11.9.4 - was #SCS_CTRL_MIDI_CUE_CONTROL
    \nCtrlMidiInPhysicalDevPtr = -1
    \nCtrlMidiOutPhysicalDevPtr = -1
  EndWith
  grCtrlSetup = grCtrlSetupDef
  
  ;- enable/disable defaults
  ; (must be before sub defaults)
  With grEnableDisableDef
    \nAction = #SCS_ENADIS_ENABLE
  EndWith
  
  ;- VST defaults
  With grDevVSTPluginDef
    \nDevVSTProgram = -1
    \nDevVSTMaxParam = -1
  EndWith
  
  With grAudVSTPluginDef
    \nAudVSTProgram = -1
    \nAudVSTMaxParam = -1
  EndWith
  
  With grVSTDef
    \nMaxLibVSTPlugin = -1
    \nMaxDevVSTPlugin = -1
    ; debugMsg(sProcName, "grVSTDef\nMaxDevVSTPlugin=" + grVSTDef\nMaxDevVSTPlugin)
  EndWith
  
  ;- cue defaults
  ; debugMsg(sProcName, "set cue defaults")
  With grCueDef
    \nCueId = -1
    \nFirstSubIndex = -1
    \nActivationMethod = #SCS_ACMETH_MAN
    \nActivationMethodReqd = \nActivationMethod
    \nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT
    \nAutoActCuePtr = -1
    \nAutoActSubNo = 1  ; +1, not -1 - used for OCM (On Cue Marker auto-start method) as cue markers are held in aAud() entries for a SubTypeF, which has only one associated aAud()
    \nAutoActAudNo = 1  ; +1, not -1 - used for OCM (On Cue Marker auto-start method) as cue markers are held in aAud() entries for a SubTypeA, which may have multiple associated aAud() entries
    \nAutoActPosn = #SCS_ACPOSN_DEFAULT
    \nAutoActTime = -2
    \nSecondToStart = -1
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      \nCueCountDownTimeLeftDisplayed = 9999999999
    CompilerElse
      \nCueCountDownTimeLeftDisplayed = 99999999
    CompilerEndIf
    \bCueEnabled = #True
    \bCueCurrentlyEnabled = \bCueEnabled
    \nPreEditPtr = -1
    \nOriginalCuePtr = -1
    \bWarningBeforeEnd = #True
    \nHideCueOpt = #SCS_HIDE_NO
    \bLockMixerStreamsOnPlayCue = #True ; lock by default
    \bUseCasForThisCue = #True
    \nCalledBySubPtr = -1
    \nExtFaderCC = -1
    \nMaxCallableCueParam = -1
    \nSMSGroup = -1
  EndWith
  
  ;- grCtrlSendDef
  ; (must be populated BEFORE grSubDef and BEFORE grEditMem)
  With grCtrlSendDef
    \nDevType = #SCS_DEVTYPE_NONE
    \nMSMsgType = #SCS_MSGTYPE_NONE
    \nRemDevMsgType = 0
    \nMSChannel = 0    ; valid channel numbers start at 1
    \nMSParam1 = -1    ; valid param1 values start at 0
    \nMSParam2 = -1    ; valid param2 values start at 0
    \nMSParam3 = -1    ; valid param3 values start at 0
    \nMSParam4 = -1    ; valid param4 values start at 0
    \nMSMacro = -1
    \nEntryMode = #SCS_ENTRYMODE_ASCII
    \bAddCR = #True
    \bAddLF = #False
    \nAudPtr = -1
    \nOSCItemNr = -2
    \fRemDevBVLevel = convertDBLevelToBVLevel(0.0) ; 0dB
    \nMaxScribbleStripItem = -1
  EndWith

  ;- sub defaults
  ; enable/disable defaults must be before this
  ; debugMsg(sProcName, "set sub defaults")
  With grSubDef
    \nSubId = -1
    \bExists = #True
    \nCueIndex = -1
    \nPrevSubIndex = -1
    \nNextSubIndex = -1
    \nSubRef = -1
    \bSubEnabled = #True
    \nFirstAudIndex = -1
    \nFirstPlayIndex = -1
    \nFirstPlayIndexThisRun = -1
    \nLastPlayIndex = -1
    \nCurrPlayIndex = -1
    \nRelStartMode = #SCS_RELSTART_DEFAULT
    \nRelStartTime = -2
    \nSubCueMarkerAudNo = 1  ; +1, not -1 - used for OCM (On Cue Marker relative-start method) as cue markers are held in aAud() entries for a SubTypeA, which may have multiple associated aAud() entries
    
    ;- sub defaults - audio file
    \nAFLinkedToMTCSubPtr = -1
    
    ;- sub defaults - SFR
    For n = 0 To #SCS_MAX_SFR
      \nSFRCueType[n] = #SCS_SFR_CUE_NA
      \nSFRAction[n] = #SCS_SFR_ACT_NA
      \nSFRSubNo[n] = -1
      \nSFRSubRef[n] = -1
      \nSFRCuePtr[n] = -1
      \nSFRSubPtr[n] = -1
      \nSFRLoopNo[n] = 1  ; nb +1, not -1
      \nSFRReleasedLoopInfoIndex[n] = -1
    Next n
    \nSFRTimeOverride = -2
    
    ;- sub defaults - playlist
    \nPLFadeInTime = -2
    \nPLFadeOutTime = -2
    \nPLCurrFadeInTime = \nPLFadeInTime
    \nPLCurrFadeOutTime = \nPLFadeOutTime
    \nPLAudPlayCount = 0
    \nPLFirstPlayNoThisPass = -1
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      \fSubMastBVLevel[d] = #SCS_MINVOLUME_SINGLE
      \nOutputDevMapDevPtr[d] = -1
      \sPLDBTrim[d] = #SCS_DEFAULT_DBTRIM
      \fSubTrimFactor[d] = dbTrimStringToFactor(\sPLDBTrim[d])
      \sPLMastDBLevel[d] = convertBVLevelToDBString(\fSubMastBVLevel[d])
      \fPLPan[d] = #SCS_PANCENTRE_SINGLE
      \nPLBassDevice[d] = -1
      \nPLBassASIODevice[d] = -1
      \bSubDisplayPan[d] = #True
    Next d
    
    ;- sub defaults - video/image
    \sVidAudLogicalDev = sDefVidAudDev
    \nVideoAudioDevPtr = -1
    \nOutputScreen = 2
    \nSubGaplessSeqPtr = -1
    \bLockMixerStreamsOnPlaySub = #True ; lock by default
    
    ;- sub defaults - level change
    \nLCSubNo = -1
    \nLCSubRef = -1
    \nLCCuePtr = -1
    \nLCSubPtr = -1
    \nLCAudPtr = -1
    \nLCAction = #SCS_LC_ACTION_ABSOLUTE
    \bLCSameTime = #True
    \bLCCalcSameTimeInd = #True
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      \bLCInclude[d] = #True
      \fLCReqdBVLevel[d] = #SCS_MINVOLUME_SINGLE
      \sLCReqdDBLevel[d] = convertBVLevelToDBString(\fLCReqdBVLevel[d])
      \fLCReqdPan[d] = #SCS_PANCENTRE_SINGLE
      \fLCInitBVLevel[d] = #SCS_NORMALVOLUME_SINGLE
      \fLCInitPan[d] = #SCS_PANCENTRE_SINGLE
    Next d
    \nLCType = #SCS_FADE_STD
    
    ;- sub defaults - ctrl send 
    For n = 0 To #SCS_MAX_CTRL_SEND
      \aCtrlSend[n] = grCtrlSendDef
    Next n
    
    ;- sub defaults - lighting
    grDMXSendItemDef\nDMXFadeTime = -2 ; -2 = not set (displayed as blank)
    For m = 0 To ArraySize(grChaseStepDef\aDMXSendItem())
      grChaseStepDef\aDMXSendItem(m) = grDMXSendItemDef
    Next m
    For m = 0 To ArraySize(\aChaseStep())
      \aChaseStep(m) = grChaseStepDef
    Next m
    
    grLTSubFixtureDef\nLTMaxDMXStartChannelIndex = -1
    For m = 0 To ArraySize(\aLTFixture())
      \aLTFixture(m) = grLTSubFixtureDef
    Next m
    
    ; -2 in the following times = not set (displayed as blank)
    \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_ITEMS ; Added 14Nov2021 11.8.6bx as SCS 11.8.5 had this as zero which was therefore the default
    \nLTBLFadeAction = #SCS_DMX_BL_FADE_ACTION_NONE
    \nLTBLFadeUserTime = -2
    \nLTDCFadeUpAction = #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    \nLTDCFadeUpUserTime = -2
    \nLTDCFadeDownAction = #SCS_DMX_DC_FADE_ACTION_USE_FADEUP_TIME
    \nLTDCFadeDownUserTime = -2
    ; 'Fade out others' for capture snapshot added 11Jul2023 11.10.0bq
    ;   but set to 0 (zero) to match earlier versions that had:
    ;   "All DMX channels not listed above will be set to 0 (zero) on starting this Lighting Cue (or Sub-Cue)"
    \nLTDCFadeOutOthersAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
    \nLTDCFadeOutOthersUserTime = 0 ; see above comment
    \nLTDIFadeUpAction = #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    \nLTDIFadeUpUserTime = -2
    \nLTDIFadeDownAction = #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME
    \nLTDIFadeDownUserTime = -2
    \nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
    \nLTDIFadeOutOthersUserTime = -2
    \nLTFIFadeUpAction = #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    \nLTFIFadeUpUserTime = -2
    \nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
    \nLTFIFadeDownUserTime = -2
    \nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
    \nLTFIFadeOutOthersUserTime = -2
    
    \nDMXControlPtr = -1
    \nMaxFixture = -1
    \nDMXPreHotkeyDataIndex = -1
    \nLTMaxCurrChanValue = -1
    
    ;- sub defaults - MTC/LTC
    \nMTCType = #SCS_MTC_TYPE_MTC
    \nMTCLinkedToAFSubPtr = -1
    \nMTCDuration = -2
    \nTCGenIndex = -1
    
    ;- sub defaults - memo
    \bMemoContinuous = #True
    \nMemoDisplayTime = -2
    \nMemoPageColor = RGB(254,255,153)  ; see also WQE_catchImages()
    \nMemoTextBackColor = -1  ; -1 = not defined, so would be same as page color
    \nMemoTextColor = #SCS_Black
    \nMemoScreen = 1
    \bMemoResizeFont = #True
    \nMemoAspectRatio = #SCS_AR_16_9
    \nMemoDesignWidth = 561 ; based on width set in fmCreateWQE()
    
    ;- sub defaults - call cue
    \nCallCuePtr = -1
    \nMaxCallCueParam = -1
    
    ;- sub defaults - enable/disable
    ; enable/disable defaults must be before this
    For n = 0 To #SCS_MAX_ENABLE_DISABLE
      \aEnableDisable[n] = grEnableDisableDef
    Next n
    
    ;- sub defaults - set position 
    \nSetPosAbsRel = #SCS_SETPOS_ABSOLUTE
    
    \nPreEditPtr = -1
  EndWith
  
  grSubDefForAdd = grSubDef
  
  ;- level point defaults
  ; MUST be before aud defaults (grAudDef)
  With grLevelPointItemDef
    \bItemInclude = #True
    \fItemPan = #SCS_PANCENTRE_SINGLE
  EndWith
  With grLevelPointDef
    \nPointType = #SCS_PT_STD
    \nPointMaxItem = -1
    For n = 0 To ArraySize(\aItem())
      \aItem(n) = grLevelPointItemDef
    Next n
  EndWith
  
  ;- loop info defaults
  ; MUST be before aud defaults (grAudDef)
  With grLoopInfoDef
    \nLoopStart = -2
    \nLoopEnd = -2
    \qLoopStartSamplePos = -2
    \qLoopEndSamplePos = -2
    \dLoopStartCPTime = -2.0
    \dLoopEndCPTime = -2.0
    \nLoopXFadeTime = -2
    \nNumLoops = -2
    \nLoopSyncIndex = -1
    \nSMSLoopSyncPointIndex1 = -1
    \nSMSLoopSyncPointIndex2 = -1
  EndWith
  
  ;- aud defaults
  ; level point defaults (grLevelPointDef) and loop info defaults (grLoopInfoDef) MUST be before aud defaults
  ; debugMsg(sProcName, "set aud defaults")
  With grAudDef
    \nAudId = -1
    \bExists = #True
    \nCueIndex = -1
    \nSubIndex = -1
    \nPrevAudIndex = -1
    \nNextAudIndex = -1
    \nPrevPlayIndex = -1
    \nNextPlayIndex = -1
    \nFileState = #SCS_FILESTATE_CLOSED
    \nFileDataPtr = -1
    \nFileStatsPtr = -1
    \nStartAt = -2
    \nEndAt = -2
    \qStartAtSamplePos = -2
    \qEndAtSamplePos = -2
    \dStartAtCPTime = -2.0
    \dEndAtCPTime = -2.0
    \nFadeInType = #SCS_FADE_STD
    \nFadeInTime = -2
    \nFadeOutType = #SCS_FADE_STD
    \nFadeOutTime = -2
    \nCurrFadeInTime = \nFadeInTime
    \nCurrFadeOutTime = \nFadeOutTime
    \nFirstAudLink = -1
    \nLinkedToAudPtr = -1
    \nMaxAudSetPtr2 = -1
    \nImagePtr = -1
    \nAlphaBlend = 100
    \nAspectRatioType = #SCS_ART_ORIGINAL
    \nSMSManualStartPos = -1
    \nAudGaplessSeqPtr = -1
    \nPosImagePos = -1
    \nMainTVGIndex = -1
    \nPreviewTVGIndex = -1
    \nPlayTVGIndex = -1
    \nCuePosTimeOffset = -2
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      \nOutputDevMapDevPtr[d] = -1
      \nBassDevice[d] = -1
      \nBassASIODevice[d] = -1
      \nMixerStreamPtr[d] = -1
      \sDBTrim[d] = #SCS_DEFAULT_DBTRIM
      \fTrimFactor[d] = dbTrimStringToFactor(\sDBTrim[d])
      \fBVLevel[d] = #SCS_MINVOLUME_SINGLE
      \fAudPlayBVLevel[d] = \fBVLevel[d]
      \sDBLevel[d] = convertBVLevelToDBString(\fBVLevel[d])
      \fPan[d] = #SCS_PANCENTRE_SINGLE
      \fCueVolNow[d] = \fBVLevel[d]
      \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
      \fCueTotalVolNow[d] = \fCueVolNow[d]
      \fCuePanNow[d] = \fPan[d]
      \bDisplayPan[d] = #True
      \fIncDecLevelBase[d] = #SCS_LEVELNOTSET_SINGLE
      \fSavedBVLevel[d] = \fBVLevel[d]
      \fSavedPan[d] = \fPan[d]
    Next d
    For d = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
      \nInputDevMapDevPtr[d] = -1
      \fInputLevel[d] = #SCS_MINVOLUME_SINGLE
      \sInputDBLevel[d] = convertBVLevelToDBString(\fInputLevel[d])
    Next d
    \nLevelChangeSubPtr = -1
    \nMidiPhysicalDevPtr = -1
    
    \nPLTransType = #SCS_TRANS_NONE
    \nPLRunTimeTransType = \nPLTransType
    \fPLRelLevel = 80
    \nPlayNo = -1
    \nAudNo = -1
    \nAutoFollowAudPtr = -1
    
    \nAudVidPicTarget = #SCS_VID_PIC_TARGET_NONE
    \nVideoSource = #SCS_VID_SRC_FILE
    
    \nPrimaryChan = -1
    
    \nPreEditPtr = -1
    \nPlayFromPos = -1
    \nPlayingPos = -1
    
    \nLvlPtLvlSel = #SCS_LVLSEL_INDIV
    \nLvlPtPanSel = #SCS_PANSEL_USEAUDDEV
    \nMaxLevelPoint = -1
    For n = 0 To ArraySize(\aPoint())
      \aPoint(n) = grLevelPointDef
    Next n
    \nMaxLoopInfo = -1
    For n = 0 To ArraySize(\aLoopInfo())
      \aLoopInfo(n) = grLoopInfoDef
    Next n
    \nCurrLoopInfoIndex = -1
    \nMaxCueMarker = -1
    \nVideoCaptureDeviceType = #SCS_DEVTYPE_NONE ; Start with a non-video capture mode
    \nVSTProgram = -1
    \nVSTMaxParam = -1
    \nVSTPluginSameAsSubRef = -1
  EndWith
  
  grAudDefForAdd = grAudDef
  
  ;- audio graph defaults
  With grMG2
    \nMGNumber = 2
    \sMGNumber = "grMG2"
    \nDfltGraphChannels = 2
    \nGraphMarkerIndex = -1
    
    \nSTColor = RGB(0, 255, 255)
    \nENColor = \nSTColor
    \nLSColorD = RGB(0, 255, 255)
    \nLEColorD = \nLSColorD
    \nLSColorN = RGB(0, 200, 200)
    \nLEColorN = \nLSColorN
    \nFIColor = \nSTColor
    \nFOColor = \nENColor
    \nLPColor = #SCS_Level_Color
    \nLPColor_Ctrl = #SCS_Level_Color_Ctrl_Hold
    \nLPColor2 = $00AAAA
    \nLVColor = RGB(64,64,255)  ; color of 'audio device level' line
    \nPanColor = #SCS_Pan_Color
    \nPanColor2 = $0060AA
    \nCursorShadowColor = #SCS_Grey
    \nINBGColor = RGB(20,20,20) ; #SCS_Very_Dark_Grey
    \nEXBGColor = RGB(10,10,10) ; #SCS_Very_Dark_Grey
    \nCMColor = RGB(107, 113, 115)
    \nCPColor = #SCS_Dark_Orange ; RGB(99, 233, 46)
    
    CompilerIf 1=2
      \nINFGColorL = RGB(0, 255, 0)
      \nEXFGColorL = RGB(0, 128, 0)
      \nINFGColorR = RGB(255, 0, 0)
      \nEXFGColorR = RGB(128, 0, 0)
      \nINBGColor = RGB(0, 0, 128)
      \nEXBGColor = RGB(0, 0, 0)
    CompilerElse
      ; now set in graphInit()
    CompilerEndIf
  EndWith
  grMG3 = grMG2
  With grMG3
    \nMGNumber = 3
    \sMGNumber = "grMG3"
  EndWith
  grMG4 = grMG2
  With grMG4
    \nMGNumber = 4
    \sMGNumber = "grMG4"
  EndWith
  grMG5 = grMG2
  With grMG5
    \nMGNumber = 5
    \sMGNumber = "grMG5"
  EndWith
  
  ;- memo defaults
  With grWEN
    \bLastMemoContinuous = grSubDef\bMemoContinuous
    \nLastMemoDisplayTime = grSubDef\nMemoDisplayTime
    \nLastMemoDisplayWidth = grSubDef\nMemoDisplayWidth
    \nLastMemoDisplayHeight = grSubDef\nMemoDisplayHeight
    \nLastMemoPageColor = grSubDef\nMemoPageColor
    \nLastMemoTextBackColor = grSubDef\nMemoTextBackColor
    \nLastMemoTextColor = grSubDef\nMemoTextColor
    \nLastMemoScreen = grSubDef\nMemoScreen
    \bLastMemoResizeFont = grSubDef\bMemoResizeFont
    \nMainSubPtr = -1
    \nPreviewSubPtr = -1
  EndWith
  
  ;- main defaults
  With grMain
    \nMainMemoSubPtr = -1
  EndWith
  
  ;- picture defaults
  With grLastPicInfo
    \nLastPicEndAt = 5000
    \nLastPicTransType = #SCS_TRANS_XFADE
    \nLastPicTransTime = 1000
  EndWith
  
  ;- file data defaults
  With grFileDataDef
    \nMaxInnerWidth = #SCS_GRAPH_MAX_INNER_WIDTH
  EndWith
  
  ;- general defaults
  With grWMN
    \nLastPlayingCuePtr = -1
    \nLastPlayingSubPtr = -1
    \nLastPlayingTimeOut = 10000 ; 10 seconds
  EndWith
  
  ;- MIDI device defaults
  With grMidiDeviceDef
    \nMidiThruInPhysicalDevPtr = -1
    \nCueControlOutPhysicalDevPtr = -1
  EndWith
  
  ;- network device defaults
  With grSendWhenReadyDef
    \nSWRSubPtr = -1
    \nSWRCtrlSendIndex = -1
  EndWith
  
  With grNetworkControlDef
    \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
    \nRemotePort = -2      ; displayed as blank
    \nLocalPort = -2
    \nOpenConnectionTimeout = 2000  ; 2 seconds
    \nDevMapDevPtr = -1
    \nDevNo = -1
    \nDevMapId = -1
    \aSendWhenReady(0) = grSendWhenReadyDef
  EndWith
  
  ;- RAI defaults
  With grRAI
    \nNetworkControlPtr1 = -1
    \nNetworkControlPtr2 = -1
    \nNetworkControlPtr3 = -1
  EndWith
  
  ;- vMix defaults
  CompilerIf #c_vMix_in_video_cues
    With grvMixInfo
      \nNextClipNo = 7000 ; arbitrary number for assigning unique 'nMainVideoNo' etc
      \nMaxIncomingMsg = -1
      \nMaxInputInfo = -1
      \nMaxInputKeyToRemoveWhenvMixIdle = -1
      \nTransition1Duration = -1 ; forces reset when required
    EndWith
  CompilerEndIf
  
  ;- dmx defaults
  With grDMX
    \nMaxDMXControl = -1
    \nDMXCueControlPtr = -1
    \nDMXCaptureControlPtr = -1
    \nMaxDMXCapture = -1
    \nMaxSubDMXDelayTimeIndex = -1
  EndWith
  With grDMXControlDef
    \nDevMapDevPtr = -1
    \nDevChgsDevMapDevPtr = -1
  EndWith
  With grDMXFadeItems
    \nMaxFadeItem = -1
  EndWith
  With grDMXPreHotkeyDataDef
    \nMaxPreHotkeyItem = -1
    \nSubPtr = -1
  EndWith
  
  With grLTFixChanDef
    \bRelChanIncluded = #True
    \sDMXDisplayValue = "0"
  EndWith
  
  ;- http defaults
  With grHTTPControl
    \nMaxHTTPSendMsg = -1
  EndWith
  
  ;- display panel defaults
  With grDispPanelDef
    \nDPCuePtr = -1
    \nDPSubPtr = -1
    \nDPAudPtr = -1
    \nDPSubState = #SCS_CUE_STATE_NOT_SET
    \nDPLinkedToAudPtr = -1 ; Added 2May2022 11.9.1
    \nDPAudLinkCount = 0    ; Added 2May2022 11.9.1
  EndWith
  
  ;- editing defaults
  With grEditMem
    \nLastAutoActPosn = #SCS_ACPOSN_AE
    \nLastMsgType = grCtrlSendDef\nMSMsgType
    \nLastRemDevMsgType = grCtrlSendDef\nRemDevMsgType
    For n = 0 To ArraySize(\aLastMsg())
      \aLastMsg(n)\nLastMSParam1 = grCtrlSendDef\nMSParam1
      \aLastMsg(n)\nLastMSParam2 = grCtrlSendDef\nMSParam2
      \aLastMsg(n)\nLastMSParam3 = grCtrlSendDef\nMSParam3
      \aLastMsg(n)\nLastMSParam4 = grCtrlSendDef\nMSParam4
    Next n
    \nLastNormToApply = #SCS_NORMALIZE_LUFS
  EndWith
  
  ;- bulk edit defaults
  With grBulkEditItemDef
    \nFileStatsPtr = -1
  EndWith
  
  ;- WQF defaults
  With rWQF
    \nDisplayedLoopInfoIndex = -1
  EndWith
  
  ;- M2T defaults
  With grM2T
    \nM2TPrimaryCuePtr = -1
    \nM2TPrimarySubPtr = -1
    \nM2TPrimaryAudPtr = -1
    \nM2TMaxItem = -1
    \nMoveToTime = 0
  EndWith
  
  ;- mixer defaults (for external mixer, eg A&H Qu-16)
  With grMixer
    \nMaxChannel = -1
    \nMaxDCA = -1
    \nMaxMuteGrp = -1
    \nMaxScene = -1
  EndWith
  
  ;- animated image defaults
  With grAnimImageDef
    \nMaxImageCanvas = -1
    \nImageAudPtr = -1
  EndWith
  gnMaxAnimImage = -1
  
  ;- GUI color defaults
  CompilerIf #c_new_gui
    With grUIColors
      ; the following defaults based on colors used by vMix 23.0.0.32 (26Dec2019)
      \nButtonBackColor = RGB(64,75,86)
      \nButtonBorderColor = RGB(96,112,129)
      \nButtonFrontColor = #SCS_WHITE
      \nLineColor = RGB(41,48,56)
      \nMainBackColor = RGB(30,35,40)
      \nTitleBackColor = RGB(10,15,20)
    EndWith
    ModuleEx::SetTheme(ModuleEx::#Theme_Dark)
  CompilerEndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure populateMonitorInfo()
  PROCNAMEC()
  Protected m, v, nBlanketDesktopIndex
  Protected nMinLeft, nMinTop
  Protected nMinLeft2, nMinTop2 ; Added 10May2021 11.8.4.2ba
  Protected nDummyWindow
  Protected nCumulativeDisplayScalingPercentage
  Protected Dim aDesktop.tyDesktop(0)
  
  gnMonitors = ExamineDesktops()
  nBlanketDesktopIndex = getBlanketDesktopIndex()
  If (nBlanketDesktopIndex > 0) And (nBlanketDesktopIndex = gnMonitors - 1)
    ; The last desktop entry is a 'blanket' (dummy) entry covering other desktop settings - can be caused when using a VNC connection (emails from Rob Widdicombe Oct2019), so ignore the last entry
    debugMsg(sProcName, "ignoring last 'desktop'")
    gnMonitors - 1
  EndIf
  
  ; The first part of this procedure obtains positions and sizes of the desktops.
  ; Unfortunately, the PB desktop index (#Desktop) may not not necessarily match the display numbers of the Windows Display Settings.
  ; The PB desktop index seems to depend on the order in which external displays have been connected, and can quite often change between sessions.
  ; To overcome this, as at SCS 11.8.0.2ag we are resorting the derived desktop array based on the positions of the displays, apart from index #0
  ; which is always the primary monitor.
  ; The sorting is based primarily on the X (left) position, and secondarily on the Y (top) position.
  ; SortStructuredArray() only supports a single sort field so \qSortkey is built for this sort. This is complicated by the fact that some desktop
  ; positions may be negative (ie to the left of or above the primary monitor) so the \qSortKey is calculated on positions relative to the
  ; left-most and top-most desktop positions. the \qSortKey of the primary monitor is set -ve to force this to the top of the sort order (although
  ; the call to SortStructuredArray() deliberately sorts from index 1, not index 0)
  ReDim aDesktop(gnMonitors-1)
  For m = 0 To gnMonitors-1
    With aDesktop(m)
      \nDesktopIndex = m
      \nDesktopLeft = DesktopX(m)
      \nDesktopTop = DesktopY(m)
      \nDesktopWidth = DesktopWidth(m)
      \nDesktopHeight = DesktopHeight(m)
      debugMsg(sProcName, "DesktopX(" + m + ")=" + DesktopX(m) + ", DesktopY(" + m + ")=" + DesktopY(m) + ", DesktopWidth(" + m + ")=" + DesktopWidth(m) + ", DesktopHeight(" + m + ")=" + DesktopHeight(m))
      If m = 0
        \qSortKey = -1
      Else
        If \nDesktopLeft < nMinLeft Or m = 1
          nMinLeft = \nDesktopLeft
        EndIf
        If \nDesktopTop < nMinTop Or m = 1
          nMinTop = \nDesktopTop
        EndIf
      EndIf
      If \nDesktopLeft < nMinLeft2 Or m = 0
        nMinLeft2 = \nDesktopLeft
      EndIf
      If \nDesktopTop < nMinTop2 Or m = 0
        nMinTop2 = \nDesktopTop
      EndIf
    EndWith
  Next m
  
  For m = 0 To gnMonitors-1
    With aDesktop(m)
      If m = 0
        \qSortKey2 = -1 ; added m=0 test 9Aug2021 11.8.5rc2 following email from Malcolm Gordon
      Else
        \qSortKey2 = ((\nDesktopLeft - nMinLeft2) * 1000000) + (\nDesktopTop - nMinTop2)
      EndIf
    EndWith
  Next m
  If gnMonitors > 1
    SortStructuredArray(aDesktop(), #PB_Sort_Ascending, OffsetOf(tyDesktop\qSortKey2), #PB_Quad, 0, (gnMonitors-1))
  EndIf
  For m = 0 To gnMonitors-1
    With aDesktop(m)
      \nDeskTopOrder = m + 1
      ; debugMsg(sProcName, "aDesktop(" + m + ")\qSortKey2=" + \qSortKey2 + ", \nDesktopLeft=" + \nDesktopLeft + ", \nDesktopTop=" + \nDesktopTop + ", \nDesktopIndex=" + \nDesktopIndex + ", \nDeskTopOrder=" + \nDeskTopOrder)
    EndWith
  Next m

  If gnMonitors > 2
    For m = 1 To gnMonitors-1
      With aDesktop(m)
        \qSortKey = ((\nDesktopLeft - nMinLeft) * 1000000) + (\nDesktopTop - nMinTop)
      EndWith
    Next m
    SortStructuredArray(aDesktop(), #PB_Sort_Ascending, OffsetOf(tyDesktop\qSortKey), #PB_Quad, 1, (gnMonitors-1))
;     For m = 0 To gnMonitors-1
;       With aDesktop(m)
;         debugMsg(sProcName, "aDesktop(" + m + ")\qSortKey=" + \qSortKey + ", \nDesktopLeft=" + \nDesktopLeft + ", \nDesktopTop=" + \nDesktopTop + ", \nDesktopIndex=" + \nDesktopIndex + ", \nDeskTopOrder=" + \nDeskTopOrder)
;       EndWith
;     Next m
  EndIf
  
  ; Deleted the following 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;   With grOperModeOptions(gnOperMode)
;     If (\nMaxMonitor > 0) And (\nMaxMonitor < gnMonitors)
;       gnMonitors = \nMaxMonitor
;     EndIf
;   EndWith
  If (#cMaxScreenNo > 0) And (#cMaxScreenNo < gnMonitors)
    gnMonitors = #cMaxScreenNo
  EndIf
  debugMsg(sProcName, "gnMonitors=" + gnMonitors + ", #cMaxScreenNo=" + #cMaxScreenNo)
  gnRealMonitors = gnMonitors
  If gnMonitors > 0
    ReDim gaMonitors(gnMonitors)
    For m = 0 To gnMonitors-1
      If (aDesktop(m)\nDesktopWidth > 0) And (aDesktop(m)\nDesktopHeight > 0)
        v + 1
        With gaMonitors(v)
          \nDisplayNo = v
          \nDesktopIndex = aDesktop(m)\nDesktopIndex
          \nDesktopLeft = aDesktop(m)\nDesktopLeft
          \nDesktopTop = aDesktop(m)\nDesktopTop
          \nDesktopWidth = aDesktop(m)\nDesktopWidth
          \nDesktopHeight = aDesktop(m)\nDesktopHeight
          \nDeskTopOrder = aDesktop(m)\nDeskTopOrder ; Added 10May2021 11.8.4.2ba
        EndWith
      EndIf
    Next m
    gnMonitors = v
  EndIf
  
EndProcedure

Procedure updateSplitScreenArray()
  PROCNAMEC()
  Protected n, n2
  Protected nDisplayNo
  Protected sRealScreenSize.s
  Protected bFound
  Protected Dim aSplitScreenInfo.tySplitScreenInfo(0)
  
  debugMsg(sProcName, #SCS_START + ", gnMonitors=" + gnMonitors + ", grVideoDriver\nSplitScreenArrayMax=" + grVideoDriver\nSplitScreenArrayMax)
  
  debugMsg(sProcName, "calling listSplitScreenArray()")
  listSplitScreenArray()
  
  ; 23/08/2014 (11.3.4) added the following to handle clearing \nCurrentMonitorIndex after losing a screen
  For n2 = 0 To grVideoDriver\nSplitScreenArrayMax
    With grVideoDriver\aSplitScreenInfo[n2]
      \nCurrentMonitorIndex = -1
    EndWith
  Next n2
  ; 23/08/2014 (11.3.4) end of added code

  For n = 1 To gnMonitors
    nDisplayNo = gaMonitors(n)\nDisplayNo
    sRealScreenSize = Str(gaMonitors(n)\nDeskTopWidth) + "x" + gaMonitors(n)\nDeskTopHeight
    debugMsg(sProcName, "n=" + n + ", nDisplayNo=" + nDisplayNo + ", sRealScreenSize=" + sRealScreenSize)
    ; scan split screen array for this monitor size
    bFound = #False
    For n2 = 0 To grVideoDriver\nSplitScreenArrayMax
      With grVideoDriver\aSplitScreenInfo[n2]
        If (\nDisplayNo = nDisplayNo) And (\sRealScreenSize = sRealScreenSize)
          \nCurrentMonitorIndex = n
          debugMsg(sProcName, "grVideoDriver\aSplitScreenInfo[" + n2 + "]\nCurrentMonitorIndex=" + \nCurrentMonitorIndex)
          bFound = #True
          Break
        EndIf
      EndWith
    Next n2
    If bFound = #False
      If grVideoDriver\nSplitScreenArrayMax < #SCS_MAX_SPLIT_SCREENS
        grVideoDriver\nSplitScreenArrayMax + 1
        With grVideoDriver\aSplitScreenInfo[grVideoDriver\nSplitScreenArrayMax]
          \nDisplayNo = nDisplayNo
          \sRealScreenSize = sRealScreenSize
          \nRealScreenWidth = gaMonitors(n)\nDeskTopWidth
          \nRealScreenHeight = gaMonitors(n)\nDeskTopHeight
          \nSplitScreenCount = 1  ; 1 (default value) means 'do not split'
          \nCurrentMonitorIndex = n
          debugMsg(sProcName, "grVideoDriver\aSplitScreenInfo[" + grVideoDriver\nSplitScreenArrayMax + "]\nCurrentMonitorIndex=" + \nCurrentMonitorIndex)
        EndWith
      EndIf
    EndIf
  Next n
  grVideoDriver\nRealScreensConnected = gnMonitors
  
  With grVideoDriver
    If \nSplitScreenArrayMax > 0
      ReDim aSplitScreenInfo(\nSplitScreenArrayMax)
      For n = 0 To \nSplitScreenArrayMax
        aSplitScreenInfo(n) = \aSplitScreenInfo[n]
      Next n
      SortStructuredArray(aSplitScreenInfo(), #PB_Sort_Ascending, OffsetOf(tySplitScreenInfo\nDisplayNo), TypeOf(tySplitScreenInfo\nDisplayNo))
      For n = 0 To \nSplitScreenArrayMax
        \aSplitScreenInfo[n] = aSplitScreenInfo(n)
      Next n
    EndIf
  EndWith
  debugMsg(sProcName, "calling listSplitScreenArray()")
  listSplitScreenArray()
  
  debugMsg(sProcName, #SCS_END + ", grVideoDriver\nRealScreensConnected=" + grVideoDriver\nRealScreensConnected + ", \nSplitScreenArrayMax=" + grVideoDriver\nSplitScreenArrayMax)
EndProcedure

Procedure initialisePart0()
  PROCNAMEC()
  ; InitialisePart0() executed before checking 'special start'
  Protected sAppDataFolder.s
  Protected nResult
  Protected n
  Protected sResult.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s

  Debug sProcName + ": start"
  
  ; check compiler settings (language translation not required)
  CompilerIf #PB_Compiler_Thread = #False
    CompilerError "Threadsafe compiler option not set"
  CompilerEndIf
  CompilerIf #PB_Compiler_Unicode = #False
    CompilerError "Unicode compiler option not set"
  CompilerEndIf
  
  ; gnLangMutex must be created before any call to Lang() or related procedures
  gnLangMutex = CreateMutex()
  
  getOSVersion()
  
  gsInitialCurrentDirectory = GetCurrentDirectory()
  Debug "gsInitialCurrentDirectory=" + #DQUOTE$ + gsInitialCurrentDirectory + #DQUOTE$
  
  ; INFO create the SCS AppData folder if necessary
  sAppDataFolder = GetUserDirectory(#PB_Directory_ProgramData) ; eg "C:\Users\Mike\AppData\Roaming\"
;   CompilerIf #cDemo
;     gsAppDataPath = sAppDataFolder + "ShowCueSystemD\"
;   CompilerElseIf #cWorkshop
;     gsAppDataPath = sAppDataFolder + "ShowCueSystemW\"
;   CompilerElse
    gsAppDataPath = sAppDataFolder + "ShowCueSystem\"
;   CompilerEndIf
  Debug "gsAppDataPath=" + #DQUOTE$ + gsAppDataPath + #DQUOTE$
  If FolderExists(gsAppDataPath) = #False
    nResult = CreateDirectory(gsAppDataPath)
    Debug "CreateDirectory(" + gsAppDataPath + ") returned " + nResult
  EndIf
  
  If FolderExists(gsAppDataPath + "\Languages") = #False
    nResult = CreateDirectory(gsAppDataPath + "\Languages")
    Debug "CreateDirectory(" + gsAppDataPath + "\Languages) returned " + nResult
  EndIf
  
  ; INFO set gsSCSDfltFontName and gnSCSDfltFontSize, the DEFAULT SCS font details
  CompilerIf #c_use_system_font
    getSystemFonts()
    For n = 1 To #Font_IconTitleFont
      debugMsg(sProcName, "SystemFont(" + n + ")\Name$=" + SystemFont(n)\Name$ + ", Size=" + SystemFont(n)\Size)
    Next n
    gsSCSDfltFontName = SystemFont(#Font_MsgBoxFont)\Name$
    gnSCSDfltFontSize = SystemFont(#Font_MsgBoxFont)\Size
  CompilerElseIf 1=1
    gsSCSDfltFontName = "Tahoma"
    gnSCSDfltFontSize = 8
  CompilerElse
    gsSCSDfltFontName = _SystemFont_
    gnSCSDfltFontSize = 9
  CompilerEndIf
  
  ; INFO set gsDefFontName and gnDefFontSize, the currently-selected font details
  gsDefFontName = gsSCSDfltFontName   ; may be overriden in loadPrefsPreSpecialStart()
  gnDefFontSize = gnSCSDfltFontSize   ; may be overriden in loadPrefsPreSpecialStart()
  gdFontScale = 1.0
  loadPrefsPreSpecialStart()  ; must call loadPrefsPreSpecialStart() before setting up fonts, but AFTER setting gsAppDataPath
  Debug sProcName + ": gsDefFontName=" + gsDefFontName + ", gnDefFontSize=" + gnDefFontSize
  
  ; INFO load fonts to be used in this run
  setMainXandYfactors()
  setUpGENFonts()
  setUpWMNFonts()
  setUpCUEFonts()
  setUpWOPFonts()
  
  CompilerIf #cTranslator
    ; must be called BEFORE calling LoadLanguage()
    loadPrefsTranslators()
    LoadLanguage("ENUS", grGeneralOptions\bDisplayLangIds)  ; fall-back language: English (US) (used for strings not found in requested language translations)
  CompilerElse
    LoadLanguage("ENUS")  ; fall-back language: English (US) (used for strings not found in requested language translations)
  CompilerEndIf
  
  With grGeneralOptions
    If \sLangCode <> "ENUS"
      If #cTranslator
        Debug "calling LoadLanguage(" + \sLangCode + ", " + strB(\bDisplayLangIds) + ")"
        LoadLanguage(\sLangCode, \bDisplayLangIds)
      Else
        Debug "calling LoadLanguage(" + \sLangCode + ")"
        LoadLanguage(\sLangCode)
      EndIf
    EndIf
    ; load common text after calling LoadLanguage()
    loadCommonText()
  EndWith
  
  ; Read user column text from prefs file. Added by Dee 24/030/2025
  ; If the column strings have been set and saved then overwrite the language data
  COND_OPEN_PREFS("UserColumns")
  sResult = ReadPreferenceString("Usercolumn1", "")
  gsUsercolumnOriginal1 = Lang("common", "Page")

  If Len(sResult) And sResult <> "Page"
    Lang("common", "Page", "", sResult)
    gnuserColumnChanged1 = #True
  EndIf
  
  sResult = ReadPreferenceString("Usercolumn2", "")
  gsUsercolumnOriginal2 = Lang("common", "WhenReqd")

  If Len(sResult) And sResult <> "When Required"
   Lang("common", "WhenReqd", "", sResult)
    gnuserColumnChanged2 = #True
  EndIf
  
  COND_CLOSE_PREFS()
  
  Debug "calling setSystemDefaults()"
  setSystemDefaults()
  
  setToolbarColors()
  
  UseMD5Fingerprint() ; required by SM-S and PJLink authentication
  
  ; video driver default renderers
  With grVideoDriver
    CompilerIf #c_include_tvg
      \nTVGDefaultVideoRenderer = #SCS_VR_AUTOSELECT
      \bTVGUse2DDrawingForImages = #True
    CompilerEndIf
  EndWith
  
  PNL_initCuePanels()
  
EndProcedure

Procedure initialisePart1()
  PROCNAMEC()
  ; initialisePart1() executed before splash screen displayed
  Protected nResult, sTmp.s
  Protected sMsg.s
  Protected n
  Protected nCompilerDate
  
  Debug sProcName + ": start"
  
  With grProgVersion
    nCompilerDate = #PB_Compiler_Date
    \sBuildDateTime = FormatDate("%yyyy/%mm/%dd %hh:%ii", nCompilerDate)
    \nBuildDate = (Year(nCompilerDate) * 10000) + (Month(nCompilerDate) * 100) + (Day(nCompilerDate))
  EndWith
  
  gnSCSColor = RGB(0, 169, 166)
  
  If AlreadyRunning()
    scsMessageRequester(#SCS_TITLE, Lang("Init", "AlreadyRunning"), #PB_MessageRequester_Error)
    End
  EndIf
  
  ; must set gqStartTime BEFORE any debug messages
  gqStartTime = ElapsedMilliseconds()
  gqTimeDiskActive = gqStartTime
  
  GetLocalTime_(@grStartTime)
  
  gnSessionId = Date()
  
  gsStartDateTime = FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", gnSessionId)
  gsDebugFileDateTime = FormatDate("%yyyy%mm%dd_%hh%ii%ss", gnSessionId)
  
  ; allocate memory for network buffers
  ; the maximum size for UDP is 2048, and 65536 for TCP, but 2048 (#SCS_MEM_SIZE_NETWORK_BUFFERS) is more than enough for SCS requirements - except for vMix
  *gmNetworkSendBuffer = AllocateMemory(#SCS_MEM_SIZE_NETWORK_BUFFERS)
  *gmNetworkReceiveBuffer = AllocateMemory(#SCS_MEM_SIZE_NETWORK_BUFFERS)
  *gmNetworkInputBuffer = AllocateMemory(#SCS_MEM_SIZE_NETWORK_BUFFERS)

  ; image decoders for LoadImage() and CatchImage()
  UseJPEGImageDecoder()
  UseJPEG2000ImageDecoder()
  UsePNGImageDecoder()
  UseGIFImageDecoder()
  
  ; image encoders for SaveImage() and EncodeImage()
  UseJPEGImageEncoder()
  UseJPEG2000ImageEncoder()
  UsePNGImageEncoder()
  
  ; SQLite for production database files
  UseSQLiteDatabase()
  
  gsMyDocsPath = GetUserDirectory(#PB_Directory_Documents)
  gsMyDocsLeafName = getLeafName(gsMyDocsPath)

  ; create gnDebugMutex unconditionally as required by logKeyEventProc() as well as debugMsg...()
  gnDebugMutex = CreateMutex()  ; created unconditionally as required by logKeyEventProc() as well as debugMsg...()
  
  ; open trace files if required
  gbDoDebug = #True
  gbDoSMSLogging = #True
  gbDoListLogging = #True
  setRandomSeed() ; must be called AFTER option to set gbDoListLogging
  
  If gbDoDebug Or gbDoSMSLogging
    openLogFile()
  EndIf
  
  purgeOldLogFiles()
  
  ; debugMsg(sProcName, "#cWorkshop=" + strB(#cWorkshop))
  
  ; debugMsg() calls now permitted
  setUpGENFonts() ; call this again to trace font sizes
  debugMsg(sProcName, "gsMyDocsPath=" + #DQUOTE$ + gsMyDocsPath + #DQUOTE$)
  debugMsg(sProcName, "gsDefFontName=" + gsDefFontName + ", gnDefFontSize=" + gnDefFontSize + ", gdFontScale=" + StrD(gdFontScale,4))
  debugMsg(sProcName, "gnTimePeriod=" + gnTimePeriod)
  
  ; load common text after calling LoadLanguage()
  loadCommonText()
  
  debugMsg(sProcName, "gbFTD2XXAvailable=" + strB(gbFTD2XXAvailable))
  
  ; internationalization settings
  ; determine decimal marker (eg . or ,)
  sTmp = StrF(1.1, 1)
  gsDecimalMarker = Mid(sTmp, 2, 1)
  debugMsg(sProcName, "sTmp=" + sTmp + ", gsDecimalMarker=" + gsDecimalMarker)
  
  ; level settings
  With grLevels
    \nMinDBLevel = -75
    \sMinDBLevel = Str(\nMinDBLevel) ; "-75"
    \fMinBVLevel = convertDBStringToBVLevel(\sMinDBLevel)
    \sZeroDBLevel = StrF(0, 1) ; = "0.0" or "0,0"
    \fZeroBVLevel = convertDBStringToBVLevel(\sZeroDBLevel)
    \sPlusZeroDB = "+" + StrF(0,1)  ; = "+0.0" or "+0,0"
    \fPlusZeroBV = convertDBStringToBVLevel(\sPlusZeroDB)
    \f12BVLevel = convertDBStringToBVLevel("12")
    \nMinRelDBLevel = \nMinDBLevel
    \fSilentBVLevel = 0.0 ; MUST be 0.0, which corresponds to a dB setting of -infinity (or "-INF" as displayed when the infinity symbol is not available)
  EndWith
  
  ; nb must set above level settings before calling setIndependantDefaults()
  ; debugMsg(sProcName, "calling setIndependantDefaults()")
  setIndependantDefaults()
  
  debugMsg(sProcName, "glSysColWindow=$" + Hex(glSysColWindow))
  debugMsg(sProcName, "glSysColWindowText=$" + Hex(glSysColWindowText))
  debugMsg(sProcName, "glSysCol3DFace=$" + Hex(glSysCol3DFace))
  
  debugMsg(sProcName, "glScrollBarWidth=" + glScrollBarWidth + ", glScrollBarHeight=" + glScrollBarHeight)
  debugMsg(sProcName, "gl3DBorderWidth=" + gl3DBorderWidth + ", gl3DBorderHeight=" + gl3DBorderHeight)
  debugMsg(sProcName, "gl3DBorderAllowanceX=" + gl3DBorderAllowanceX + ", gl3DBorderAllowanceY=" + gl3DBorderAllowanceY)
  debugMsg(sProcName, "glThumbWidth=" + glThumbWidth)

  debugMsg(sProcName, "gsAppDataPath=" + #DQUOTE$ + gsAppDataPath + #DQUOTE$) ; nb couldn't trace this when it was set in initialisePart0() because the trace files hadn't been opened
  
  gsTempFolderPath = GetTemporaryDirectory()
  debugMsg(sProcName, "gsTempFolderPath=" + #DQUOTE$ + gsTempFolderPath + #DQUOTE$)
  
  gsDevMapsPath = gsAppDataPath + "DevMaps\"
  debugMsg(sProcName, "gsDevMapsPath=" + #DQUOTE$ + gsDevMapsPath + #DQUOTE$)
  If FolderExists(gsDevMapsPath) = #False
    nResult = CreateDirectory(gsDevMapsPath)
    debugMsg(sProcName, "CreateDirectory(" + gsDevMapsPath + ") returned " + nResult)
  EndIf
  
  gsTemplatesFolder = gsAppDataPath + "Templates\"
  debugMsg(sProcName, "gsTemplatesFolder=" + #DQUOTE$ + gsTemplatesFolder + #DQUOTE$)
  If FolderExists(gsTemplatesFolder) = #False
    nResult = CreateDirectory(gsTemplatesFolder)
    debugMsg(sProcName, "CreateDirectory(" + #DQUOTE$ + gsTemplatesFolder + #DQUOTE$ + ") returned " + nResult)
  EndIf
  
  gsCommonAppDataPath = GetUserDirectory(#PB_Directory_AllUserData) ; "C:\ProgramData\"
;   CompilerIf #cDemo
;     gsCommonAppDataPath + "ShowCueSystemD\"
;   CompilerElseIf #cWorkshop
;     gsCommonAppDataPath + "ShowCueSystemW\"
;   CompilerElse
    gsCommonAppDataPath + "ShowCueSystem\"
;   CompilerEndIf
  debugMsg(sProcName, "gsCommonAppDataPath=" + #DQUOTE$ + gsCommonAppDataPath + #DQUOTE$)
  If FolderExists(gsCommonAppDataPath) = #False
    nResult = CreateDirectory(gsCommonAppDataPath)
    debugMsg(sProcName, "CreateDirectory(" + gsCommonAppDataPath + ") returned " + nResult)
  EndIf
  
  setPrefOperModeDefaults()
  loadPrefsPart0()
  loadPrefsPart1()
  
  obtainSplitterSeparatorSizes()
  obtainPanelContentOffsets()
  
  populateOrderedShortcutArray()
  
  ; the following commented out because calling InitMouse() seems to assume you want total control of the mouse, so normal mouse operations are
  ; ignored (such as clicking on the 'close window' button, or clicking on another program's window in the task bar, etc)
  ; so instead of that, we use Windows-only functions at the moment - see SCS functions isLeftMouseButtonDown() and isRightMouseButtonDown() in modMouse.pbi
  ; ; initialise the Mouse library
  ; nResult = InitMouse()
  ; debugMsg(sProcName,"InitMouse() returned " + nResult)
  
  gsAppPath = GetPathPart(ProgramFilename())
  If #PB_Compiler_Processor = #PB_Processor_x64
    If FileSize(gsAppPath + "x64\") = -2
      ; if FileSize() returns -2 then the 'file' is a directory, ie directory 'gsAppPath + "x64\"' exists
      ; nb the x64 directory exists in the development environment but not in an installed version where the x64 program and dll's
      ; are all (by default) under "C:\Program Files\SCS 11\"
      gsAppPath + "Runtime\x64\"
    EndIf
  EndIf
  If FileExists(gsAppPath + "bass.dll") = #False
    ; could be running from IDE, and the compiled .exe could therefore be in a temp folder, so use the source folder instead
    gsAppPath = #PB_Compiler_FilePath
    If #PB_Compiler_Processor = #PB_Processor_x64
      gsAppPath + "Runtime\x64\"
    EndIf
  EndIf
  debugMsg(sProcName, "gsAppPath=" + #DQUOTE$ + gsAppPath + #DQUOTE$)
  
  IMG_catchSplashScreenImages()
  IMG_catchLoadScreenImages()
  IMG_loadSpecialCursors()
  
  ; create mutex's
  debugMsg(sProcName, "create mutex's")
  gnCueListMutex = CreateMutex()
  gnImageMutex = CreateMutex()
  gnDMXSendMutex = CreateMutex()
  gnDMXReceiveMutex = CreateMutex()
  gnHTTPSendMutex = CreateMutex()
  gnTempDatabaseMutex = CreateMutex()
  gnLoadSamplesMutex = CreateMutex()
  gnNetworkSendMutex = CreateMutex()
  CompilerIf #c_vMix_in_video_cues
    gnvMixSendMutex = CreateMutex()
 CompilerEndIf
  
  ; the following code WAS in initialisePart1A()
  IMG_catchMainToolBarImages()
  IMG_catchCueTypeImages()
  IMG_catchTransportControlImages()
  IMG_catchPreviewControlImages()
  IMG_catchSideBarImages()
  IMG_catchMiscellaneousImages()
  IMG_catchEditorCueListImages()
  IMG_catchEditorToolBarImages()
  IMG_catchTemplateToolbarImages()
  WQE_catchImages()
  
  IMG_drawAudGraphMarkers()
  IMG_drawTrBtnImages13(20,14)
  
  gsHelpFile = gsAppPath + "scs11_help.chm"
  If FileExists(gsHelpFile, #False)
    ; debugMsg(sProcName, "Help file exists: " + #DQUOTE$ + gsHelpFile + #DQUOTE$)
  Else
    debugMsg(sProcName, "Help file not found: " + #DQUOTE$ + gsHelpFile + #DQUOTE$)
  EndIf
  
  ; set various time fields so that they have a meaningful time rather than 0 to avoid issues when millisecond timer has overflowed and gone negative
  gqLastChangeTime = gqStartTime
  gqLastRecoveryTime = gqStartTime
  gqStatusDisplayed = gqStartTime
  gqStopEverythingTime = gqStartTime
  gqTimeDiskActive = gqStartTime
  grMain\qCheckFocusTime = gqStartTime
  grMain\qCheckPauseAllTime = gqStartTime
  grMain\qDeviceCheckTime = gqStartTime
  grMMedia\qTimeOfLastMemoryCheck = gqStartTime
  gqTimeMouseClicked = gqStartTime - 5000  ; set gnTimeMouseClicked initially at a time that will not cause problems re double-click time
  gqTimeMainShortcutPressed = gqStartTime - 5000
  
  initUndoItems()
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure loadSFRActionDescrs()
  PROCNAMEC()
  Protected n
  Protected sTmp.s
  
  For n = 0 To #SCS_SFR_ACT_LAST
    With gaSFRAction(n)
      If n = #SCS_SFR_ACT_NA
        \sActDescr = ""
        \sActDescr2 = ""
      Else
        sTmp = "act" + decodeSFRAction(n)
        Select n
          Case #SCS_SFR_ACT_STOPALL
            \sActDescr = LangPars("WQS", sTmp, gaShortcutsMain(#SCS_ShortMain_StopAll)\sDefaultShortcutStr)
          Case #SCS_SFR_ACT_FADEALL
            \sActDescr = LangPars("WQS", sTmp, gaShortcutsMain(#SCS_ShortMain_FadeAll)\sDefaultShortcutStr)
          Case #SCS_SFR_ACT_PAUSEALL
            \sActDescr = LangPars("WQS", sTmp, gaShortcutsMain(#SCS_ShortMain_PauseResumeAll)\sDefaultShortcutStr)
          Default
            \sActDescr = Lang("WQS", sTmp)
        EndSelect
        \sActDescr2 = Lang("WQS", sTmp + "2")
      EndIf
      ; debugMsg(sProcName, "gaSFRAction(" + n + ")\sActDescr=" + \sActDescr + ", \sActDescr2=" + \sActDescr2)
    EndWith
  Next n
  
EndProcedure

Procedure loadShortcutMain(nIndex, sFunctionPrefKey.s, sDefaultShortcutStr.s, nShortcutFunction, sFunctionDescr.s="")
  With gaShortcutsMain(nIndex)
    \sFunctionPrefKey = sFunctionPrefKey
    \sDefaultShortcutStr = sDefaultShortCutStr
    \nShortcutFunction = nShortcutFunction
    \sFunctionDescr = Trim(RemoveString(sFunctionDescr, "..."))
    \sFunctionDescr = sFunctionDescr
  EndWith
EndProcedure

Procedure loadShortcutEditor(nIndex, sFunctionPrefKey.s, sDefaultShortcutStr.s, nShortcutFunction, sFunctionDescr.s="")
  With gaShortcutsEditor(nIndex)
    \sFunctionPrefKey = sFunctionPrefKey
    \sDefaultShortcutStr = sDefaultShortCutStr
    \nShortcutFunction = nShortcutFunction
    \sFunctionDescr = Trim(RemoveString(sFunctionDescr, "..."))
  EndWith
EndProcedure

Procedure initialisePart2()
  PROCNAMEC()
  Protected n
  Protected bMMInitResult
  Protected bTempDatabaseCreated
  Protected nMaxRemDevMsgType
  
  Debug sProcName + ": start"
  debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling initBassForSession()")
  initBassForSession()
  
  debugMsg(sProcName, "calling samInit()")
  samInit()
  
  debugMsg(sProcName, "calling casInit()")
  casInit()
  
  With grSession
    ; enable cue control devices by default
    \nMidiInEnabled = #SCS_DEVTYPE_ENABLED
    \nRS232InEnabled = #SCS_DEVTYPE_ENABLED
    \nDMXInEnabled = #SCS_DEVTYPE_ENABLED
    \nNetworkInEnabled = #SCS_DEVTYPE_ENABLED
    ; enable control send devices by default
    \nMidiOutEnabled = #SCS_DEVTYPE_ENABLED
    \nRS232OutEnabled = #SCS_DEVTYPE_ENABLED
    \nDMXOutEnabled = #SCS_DEVTYPE_ENABLED
    \nNetworkOutEnabled = #SCS_DEVTYPE_ENABLED
    debugMsg(sProcName, "grSession\nMidiInEnabled=" + strB(\nMidiInEnabled))
  EndWith
  
  ; initialise color handler and set default color scheme
  initColorHandler()
  
  SLD_initFaderConstants()
  
  debugMsg(sProcName, "gsCommand=" + gsCommand)
  
;   CompilerIf #c_include_tvg
;     ; nb need to call initTVG() before calling getConnectedTVGDevs(), which is called within the getAllPhysicalDevices() hierarchy
;     debugMsg(sProcName, "calling initTVG()")
;     initTVG()
;   CompilerEndIf
  
  debugMsg(sProcName, "calling getAllPhysicalDevices()")
  getAllPhysicalDevices()
  
  debugMsg(sProcName, "calling clearArrayCueOrSubForMTC()")
  clearArrayCueOrSubForMTC()
  
  ; initialise multimedia
  bMMInitResult = mmInit()
  If bMMInitResult = #False
    ; mmInit() failed, probably because no audio devices could be found
    earlyCloseDown()  ; early closedown - ends program
    ; ProcedureReturn #False
  EndIf
 
  ; initialise control structures and other variables
  initMidiControl()
  initRS232Control()
  initNetworkControl()
  DMX_initDMXControl()
  
  ReDim gaMixerStreams(grLicInfo\nMaxAudDevPerProd) ; Changed 15Dec2022 11.10.0ac (was #SCS_MAX_AUDIO_DEV_PER_PROD)
  For n = 0 To ArraySize(gaMixerStreams())
    gaMixerStreams(n)\nMixerStreamHandle = 0
  Next n
  
  CompilerIf 1=2 ; Blocked out 8Oct2020 11.8.3.2bj as loadArrayMidiDevs() has already been called from getAllPhysicalDevices(), which was called unconditionally earlier in this Procedure.
    debugMsg(sProcName, "calling loadArrayMidiDevs")
    loadArrayMidiDevs()
  CompilerEndIf
  
  initDevMapHandler()
  
  updateSplitScreenArray() ; must be called after split screen preferences loaded (which occurs in loadPrefsPart1(), as well as after populateMonitorInfo()
  populateScreenArray()
  
  If grLicInfo\bCCDMXAvailable Or grLicInfo\bDMXSendAvailable
    gbDMXAvailable = gbFTD2XXAvailable
    debugMsg(sProcName, "gbDMXAvailable=" + strB(gbDMXAvailable))
    DMX_loadArrayDMXDevs()
  Else
    gbDMXAvailable = #False
  EndIf
  
  If grTempDB\bTempDatabaseOpen = #False
    bTempDatabaseCreated = createTempDatabase()
  EndIf
  
  loadTemplatesArray()
  
  If grLicInfo\bCSRDAvailable
    CSRD_Init()
    nMaxRemDevMsgType = CSRD_GetMaxRemDevMsgType()
    If nMaxRemDevMsgType > ArraySize(grEditMem\aLastMsg())
      ReDim grEditMem\aLastMsg(nMaxRemDevMsgType)
    EndIf
  EndIf
  
  applyThreadExecutionState()
  
  debugMsg(sProcName, #SCS_END)
  Debug sProcName + ": end"
  ProcedureReturn #True
  
EndProcedure

Procedure initialisePart3()
  ; initialisePart3() is called from WMN_Form_Load() and may access forms
  ; note: initialisePart3() must NOT be called before #WMN has been created as it sets values in #WMN fields
  PROCNAMEC()
  Protected sStatusField.s
  
  Debug sProcName + ": start"
  debugMsg(sProcName, #SCS_START)
  
  samAddRequest(#SCS_SAM_SET_TIME_BASED_CUES, -1)
  
  debugMsg(sProcName, "calling setVidPicTargets()")
  setVidPicTargets()  ; must set screen sizes before calling ONC_openNextCues()
  debugMsg(sProcName, "calling ONC_openNextCues()")
  ONC_openNextCues()
  debugMsg(sProcName, "calling setCueDetailsInMain()")
  setCueDetailsInMain()
  
  scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuFavFiles, #True)
  
  CompilerIf #cTutorialVideoOrScreenShots
    WMN_setStatusField("", #SCS_STATUS_CLEAR)
  CompilerElse
    sStatusField = RTrim(" " + getMidiInfo() + " " + RTrim(getRS232Info() + " " + RTrim(DMX_getDMXInfo() + " " + getNetworkInfo())))
    If sStatusField
      sStatusField + ". "
    EndIf
    ; Added 24Jan2024 11.10.1
    If gsWhichTimeProfile
      sStatusField = Trim(sStatusField + " " + LangColon("Common", "TimeProfile") + gsWhichTimeProfile) + "."
    EndIf
    ; End added 24Jan2024 11.10.1
    sStatusField = Trim(sStatusField + " " + #SCS_TITLE + " " + Lang("Common", "LicensedTo") + " " + grLicInfo\sLicUser)
    WMN_setStatusField(sStatusField, #SCS_STATUS_WARN, 16000, #True)  ; leave initial display up for 20 seconds (16 + 4)
  CompilerEndIf
  
  If gbFadersDisplayed
    samAddRequest(#SCS_SAM_DISPLAY_FADERS)
  EndIf
  
  If gbDMXDisplayDisplayed
    samAddRequest(#SCS_SAM_DISPLAY_DMX_DISPLAY)
  EndIf
  
  If grRAIOptions\bRAIEnabled ; test added 6Mar2020 11.8.2.2bc following reports of port 58000 not being available even though the user had not enabled the remote app interface
    samAddRequest(#SCS_SAM_INIT_RAI)
  EndIf
  
  checkUSBPowerStates()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure initialiseEnd()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbSystemLocked = #False
  
  debugMsg(sProcName, "start control thread")
  THR_createOrResumeAThread(#SCS_THREAD_CONTROL)
  
  debugMsg(sProcName, "start system monitor thread")
  THR_createOrResumeAThread(#SCS_THREAD_SYSTEM_MONITOR)
  
  CompilerIf #c_scsltc
    debugMsg(sProcName, "start SCS LTC thread")
    THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)
  CompilerEndIf
  
  gbInitialising = #False
  debugMsg(sProcName, "gbInitialising=" + strB(gbInitialising))
  setRunState("R", #True)
  
  debugMsg(sProcName, #SCS_END)
  
  setDefaultTracing() ; nb call this AFTER "debugMsg(sProcName, #SCS_END)"
  
EndProcedure

Procedure setFileTypeList()
  PROCNAMEC()
  
  gsMidiFileTypes = "mid"
  gsMidiFilePattern = "MIDI Files|*.mid"
  
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    ; see also getFileFormat()
    ; m4v added 29Nov2020 11.8.3.3ar
    ; gif added 14Jan2022 11.9.0ak
    gsVideoImageFileTypes = "avi,wmv,asf,mpeg,mpg,mp4,mov,m4v,divx,mkv,flv,f4v,4fp,f4a,f4b,3gp,3g2,mts,m2ts,vob,bmp,jpg,jpeg,jp2,jpx,png,gif"
    gsVideoImageFilePattern = "Video/Image Files|*.avi;*.wmv;*.asf;*.mpeg;*.mpg;*.mp4;*.mov;*.m4v;*.divx;*.mkv;*.flv;*.f4v;*.f4p;*.f4a;*.f4b;*.3gp;*.3g2;*.mts;*m2ts;*.vob;*.bmp;*.jpg;*.jpeg;*.jp2;*.jpx;*.png;*.gif" +
                              "|Windows Video Files (*.avi, *.wmv, *.asf)|*.avi;*.wmv;*.asf" +
                              "|Movie Files (*.mpeg, *.mpg)|*.mpeg;*.mpg" +
                              "|MPEG-4 Files (*.mp4)|*.mp4" +
                              "|Mov Files (*.mov)|*.mov" +
                              "|iTunes Video Files (*.m4v)|*.m4v" +
                              "|DivX Files (*.divx)|*.divx" +
                              "|Matroska Video Files (*.mkv)|*.mkv" +
                              "|Flash Video Files (*.flv, *.f4v, *.f4p, *.f4a, *.f4b)|*.flv;*.f4v;*.f4p;*.f4a;*.f4b" +
                              "|3GPP/3GPP2 Files (*.3gp, *.3g2)|*.3gp;*.3g2" +
                              "|MPEG-2 Transport Stream (*.mts, *.m2ts)|*.mts;*m2ts" +
                              "|Video Object Files (*.vob)|*.vob" +
                              "|Image Files (*.bmp, *.jpg, *.jpeg, *.jp2, *.jpx, *.png)|*.bmp;*.jpg;*.jpeg;*.jp2;*.jpx;*.png;*.gif" +
                              "|All Files (*.*)|*.*"
  EndIf
  
  gsAudioFileTypes = "wav,mp3,wma,aac,m4a,ogg,aif,aiff" + ReplaceString(gsPluginAllAudioFilesPattern, ";*.", ",", #PB_String_NoCase)
  gsAudioFilePattern = "All Audio Files|*.wav;*.mp3;*.wma;*.aac;*.m4a;*.ogg;*.aif;*.aiff" +
                       gsPluginAllAudioFilesPattern +
                       "|WAV (Wave Audio) (*.wav)|*.wav" + 
                       "|MP3 (*.mp3)|*.mp3" +
                       "|WMA (Windows Media Audio) (*.wma)|*.wma" +
                       "|AAC (Advanced Audio Coding) (*.aac)|*.aac" +
                       "|M4A (MPEG-4 Audio) (*.m4a)|*.m4a" +
                       "|OGG (Ogg Vorbis) (*.ogg)|*.ogg" +
                       "|AIFF (Audio Interchange File Format) (*.aif;*.aiff)|*.aif;*.aiff" +
                       gsPluginAudioFilePattern +
                       "|All Files (*.*)|*.*"

  debugMsg(sProcName, "gsAudioFileTypes=" + gsAudioFileTypes)
  debugMsg(sProcName, "gsVideoImageFileTypes=" + gsVideoImageFileTypes)
  debugMsg(sProcName, "gsMidiFileTypes=" + gsMidiFileTypes)
  
  debugMsg(sProcName, "gsAudioFilePattern=" + gsAudioFilePattern)
  debugMsg(sProcName, "gsVideoImageFilePattern=" + gsVideoImageFilePattern)
  
EndProcedure

Procedure callTimeBeginPeriodIfReqd()
  ; do not use debugMsg() in this procedure as the procedure must be called before timeGetTime_() is used
  Protected rPowerStatus.SYSTEM_POWER_STATUS
  Protected rTimeCaps.TIMECAPS
  
  GetSystemPowerStatus_(rPowerStatus)
  If rPowerStatus\ACLineStatus = 1
    ; AC power status = online
    timeGetDevCaps_(rTimeCaps, SizeOf(TIMECAPS))  
    gnTimePeriod = rTimeCaps\wPeriodMin
  EndIf
  
  If gnTimePeriod > 0
    BASS_SetConfig(#BASS_CONFIG_NOTIMERES, 1) ; prevent BASS from also calling timeBeginPeriod() and timeEndPeriod()
    timeBeginPeriod_(gnTimePeriod)
  EndIf
  
EndProcedure

Procedure callTimeEndPeriodIfReqd()
  If gnTimePeriod > 0
    timeEndPeriod_(gnTimePeriod)
  EndIf
EndProcedure

Procedure isCueTypeAvailable(sCueType.s)
  PROCNAMEC()
  ; this procedure retruns #True if sCueType is available with the user's license level
  ; for example, sCueType "K" (Lighting) is only available with SCS Professional and higher licenses (subject to change, as set in setLicLimitsEtc())
  Protected nIndex
  
  nIndex = Asc(sCueType) - Asc("A") ; returns 0 for "A", 1 for "B", etc
  ; debugMsg(sProcName, "sCueType=" + sCueType + ", gaCueType(" + nIndex + ")\bCueTypeAvailable=" + strB(gaCueType(nIndex)\bCueTypeAvailable))
  ProcedureReturn gaCueType(nIndex)\bCueTypeAvailable
  
EndProcedure

Procedure setSystemDefaults()
  PROCNAMEC()
  ; prerequisite: language translations MUST be loaded before calling setSystemDefaults()
  Protected n, sTmp.s
  
  gaCueState(#SCS_CUE_NOT_LOADED) = Lang("CueState", "NOT_LOADED")
  gaCueState(#SCS_CUE_READY) = Lang("CueState", "READY")
  gaCueState(#SCS_CUE_COUNTDOWN_TO_START) = Lang("CueState", "COUNTDOWN_TO_START")
  gaCueState(#SCS_CUE_SUB_COUNTDOWN_TO_START) = Lang("CueState", "COUNTDOWN_TO_START")       ; nb same as above
  gaCueState(#SCS_CUE_PL_COUNTDOWN_TO_START) = Lang("CueState", "COUNTDOWN_TO_START") + "."  ; nb same as above, plus "."
  gaCueState(#SCS_CUE_WAITING_FOR_CONFIRM) = Lang("CueState", "WAITING_FOR_CONFIRM")
  gaCueState(#SCS_CUE_FADING_IN) = Lang("CueState", "FADING_IN")
  gaCueState(#SCS_CUE_TRANS_FADING_IN) = Lang("CueState", "TRANS_FADING_IN")
  gaCueState(#SCS_CUE_PLAYING) = Lang("CueState", "PLAYING")
  gaCueState(#SCS_CUE_CHANGING_LEVEL) = Lang("CueState", "CHANGING_LEVEL")
  gaCueState(#SCS_CUE_RELEASING) = Lang("CueState", "RELEASING")
  gaCueState(#SCS_CUE_STOPPING) = Lang("CueState", "STOPPING")
  gaCueState(#SCS_CUE_TRANS_MIXING_OUT) = Lang("CueState", "TRANS_MIXING_OUT")
  gaCueState(#SCS_CUE_TRANS_FADING_OUT) = Lang("CueState", "TRANS_FADING_OUT")
  gaCueState(#SCS_CUE_PAUSED) = Lang("CueState", "PAUSED")
  gaCueState(#SCS_CUE_HIBERNATING) = Lang("CueState", "HIBERNATING")
  gaCueState(#SCS_CUE_FADING_OUT) = Lang("CueState", "FADING_OUT")
  gaCueState(#SCS_CUE_PL_READY) = Lang("CueState", "READY") + "."  ; same as READY, plus "."
  gaCueState(#SCS_CUE_STANDBY) = Lang("CueState", "STANDBY")
  gaCueState(#SCS_CUE_COMPLETED) = Lang("CueState", "COMPLETED")
  gaCueState(#SCS_CUE_ERROR) = Lang("CueState", "ERROR")
  gaCueState(#SCS_CUE_IGNORED) = Lang("CueState", "IGNORED")
  gaCueState(#SCS_CUE_STATE_NOT_SET) = Lang("CueState", "STATE_NOT_SET")
  
  For n = 0 To #SCS_LAST_CUE_STATE
    gaCueStateForGrid(n) = gaCueState(n)
  Next n
  
  ; populate gaShortcutsMain
  ; cue control category
  loadShortcutMain(#SCS_ShortMain_GoButton, "FnGo", "Space", #SCS_WMNF_Go)
  loadShortcutMain(#SCS_ShortMain_GoConfirm, "FnGoConfirm", "", #SCS_WMNF_GoConfirm)
  loadShortcutMain(#SCS_ShortMain_PauseResumeAll, "FnPauseResumeAll", "Ctrl+U", #SCS_WMNF_PauseResumeAll)
  loadShortcutMain(#SCS_ShortMain_StopAll, "FnStopAll", "Esc", #SCS_WMNF_StopAll)
  loadShortcutMain(#SCS_ShortMain_FadeAll, "FnFadeAll", "Shift+Esc", #SCS_WMNF_FadeAll)
  loadShortcutMain(#SCS_ShortMain_CueListUpOneRow, "FnCueListUpOneRow", "Up", #SCS_WMNF_CueListUpOneRow)
  loadShortcutMain(#SCS_ShortMain_CueListDownOneRow, "FnCueListDownOneRow", "Down", #SCS_WMNF_CueListDownOneRow)
  loadShortcutMain(#SCS_ShortMain_CueListUpOnePage, "FnCueListUpOnePage", "Page Up", #SCS_WMNF_CueListUpOnePage)
  loadShortcutMain(#SCS_ShortMain_CueListDownOnePage, "FnCueListDownOnePage", "Page Down", #SCS_WMNF_CueListDownOnePage)
  loadShortcutMain(#SCS_ShortMain_CueListTop, "FnCueListTop", "Home", #SCS_WMNF_CueListTop)
  loadShortcutMain(#SCS_ShortMain_CueListEnd, "FnCueListEnd", "End", #SCS_WMNF_CueListEnd)
  loadShortcutMain(#SCS_ShortMain_FindCue, "FnFindCue", "Ctrl+F", #SCS_WMNF_FindCue)
  ; loadShortcutMain(#SCS_ShortMain_HotkeyBank0, "FnHotkeyBank0", "Ctrl+Shift+0", #SCS_WMNF_HB_00)
  loadShortcutMain(#SCS_ShortMain_HotkeyBank1, "FnHotkeyBank1", "Ctrl+Shift+F1", #SCS_WMNF_HB_01)
  ; file category
  ; loadShortcutMain(#SCS_ShortMain_Load, "FnLoad", "Ctrl+L", #WMN_mnuFileLoad) ; Ctrl+L superseded 19Apr2024 11.10.2ca by use of Ctrl+L for Link Devices
  ; loadShortcutMain(#SCS_ShortMain_Templates, "FnTemplates", "Ctrl+T", #WMN_mnuFileTemplates) ; deleted 19Apr2024 11.10.2ca as not really necessary, especially as #SCS_ShortMain_Load is now obsolete
  ; loadShortcutMain(#SCS_ShortMain_FavFile1, "FnFavFile1", "Ctrl+Shift+A", #SCS_WMNF_FavFile1) ; deleted 19Apr2024 11.10.2ca as not really necessary, especially as #SCS_ShortMain_Load is now obsolete
  loadShortcutMain(#SCS_ShortMain_Save, "FnSave", "Ctrl+S", #WMN_mnuSaveFile)
  loadShortcutMain(#SCS_ShortMain_SaveAs, "FnSaveAs", "Ctrl+W", #WMN_mnuSaveAs)
  loadShortcutMain(#SCS_ShortMain_Print, "FnPrint", "Ctrl+P", #WMN_mnuFilePrint)
  loadShortcutMain(#SCS_ShortMain_Options, "FnOptions", "Ctrl+O", #WMN_mnuOptions)
  ; editing category
  loadShortcutMain(#SCS_ShortMain_Editor, "FnEditor", "Ctrl+E", #WMN_mnuEditor)
  loadShortcutMain(#SCS_ShortMain_SaveCueSettings, "FnSaveCueSettings", "Shift+F10", #SCS_WMNF_SaveCueSettings)
  ; view category
  ; help category
  ; others
  loadShortcutMain(#SCS_ShortMain_MastFdrUp, "FnMastFdrUp", "Add", #SCS_WMNF_MastFdrUp)
  loadShortcutMain(#SCS_ShortMain_MastFdrDown, "FnMastFdrDown", "Subtract", #SCS_WMNF_MastFdrDown)
  loadShortcutMain(#SCS_ShortMain_MastFdrReset, "FnMastFdrReset", "Multiply", #SCS_WMNF_MastFdrReset)
  loadShortcutMain(#SCS_ShortMain_MastFdrMute, "FnMastFdrMute", "Shift+Subtract", #SCS_WMNF_MastFdrMute)
  loadShortcutMain(#SCS_ShortMain_DecPlayingCues, "FnDecPlayingCues", "Shift+F11", #SCS_WMNF_DecPlayingCues)
  loadShortcutMain(#SCS_ShortMain_IncPlayingCues, "FnIncPlayingCues", "Shift+F12", #SCS_WMNF_IncPlayingCues)
  loadShortcutMain(#SCS_ShortMain_DecLastPlayingCue, "FnDecLastPlayingCue", "Ctrl+F11", #SCS_WMNF_DecLastPlayingCue)
  loadShortcutMain(#SCS_ShortMain_IncLastPlayingCue, "FnIncLastPlayingCue", "Ctrl+F12", #SCS_WMNF_IncLastPlayingCue)
  loadShortcutMain(#SCS_ShortMain_ExclCueOverride, "FnExclCueOverride", "", #SCS_WMNF_ExclCueOverride)
  loadShortcutMain(#SCS_ShortMain_TapDelay, "FnTapDelay", "Ctrl+.", #SCS_WMNF_TapDelay)
  loadShortcutMain(#SCS_ShortMain_DMXMastFdrUp, "FnDMXMastFdrUp", "", #SCS_WMNF_DMXMastFdrUp)
  loadShortcutMain(#SCS_ShortMain_DMXMastFdrDown, "FnDMXMastFdrDown", "", #SCS_WMNF_DMXMastFdrDown)
  loadShortcutMain(#SCS_ShortMain_DMXMastFdrReset, "FnDMXMastFdrReset", "", #SCS_WMNF_DMXMastFdrReset)
  loadShortcutMain(#SCS_ShortMain_CueMarkerPrev, "FnCueMarkerPrev", "Ctrl+9", #SCS_WMNF_CueMarkerPrev) ; nb Ctrl+9, NOT Ctrl+Num9
  loadShortcutMain(#SCS_ShortMain_CueMarkerNext, "FnCueMarkerNext", "Ctrl+0", #SCS_WMNF_CueMarkerNext) ; nb Ctrl+0, NOT Ctrl+Num0
  loadShortcutMain(#SCS_ShortMain_MoveToTime, "FnMoveToTime", "Ctrl+M", #SCS_WMNF_MoveToTime)
  loadShortcutMain(#SCS_ShortMain_CallLinkDevs, "FnCallLinkDevs", "Ctrl+L", #SCS_WMNF_CallLinkDevs)
  
  ; now populate function descriptions from language array, and shortcut strings and codes from the defaults
  For n = 0 To ArraySize(gaShortcutsMain())
    With gaShortcutsMain(n)
      If n <> #SCS_ShortMain_ExclCueOverride
        If Len(\sFunctionDescr) = 0
          If \sFunctionPrefKey
            \sFunctionDescr = Lang("Init", \sFunctionPrefKey)
          EndIf
        EndIf
        ; debugMsg(sProcName, "gaShortcutsMain(" + n + ")\sFunctionPrefKey=" + \sFunctionPrefKey + ", \sFunctionDescr=" + \sFunctionDescr)
        \sShortcutStr = \sDefaultShortcutStr
        \nShortcut = encodeShortcut(\sShortcutStr)
        \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
        debugMsg(sProcName, "(4) gaShortcutsMain(" + n + ")\sFunctionDescr=" + \sFunctionDescr + ", \sShortcutStr=" + \sShortcutStr + ", \nShortcut=" + \nShortcut + ", \nShortcutVK=" + \nShortcutVK)
      EndIf
    EndWith
  Next n

  ; populate gaShortcutsEditor
  ; file category
  ; loadShortcutEditor(#SCS_ShortEditor_Open, "FnOpen", "Ctrl+O", #WED_mnuOpenFile)
  loadShortcutEditor(#SCS_ShortEditor_Save, "FnSave", "Ctrl+S", #SCS_WEDF_Save)
  loadShortcutEditor(#SCS_ShortEditor_SaveAs, "FnSaveAs", "Ctrl+W", #WED_mnuSaveAs)
  loadShortcutEditor(#SCS_ShortEditor_Print, "FnPrint", "Ctrl+P", #WED_mnuPrint)
  loadShortcutEditor(#SCS_ShortEditor_Options, "FnOptions", "Ctrl+O", #WED_mnuOptions)
  ; editing category
;   loadShortcutEditor(#SCS_ShortEditor_Cut, "FnCut", "Ctrl+X", #WED_mnuCut)
;   loadShortcutEditor(#SCS_ShortEditor_Copy, "FnCopy", "Ctrl+C", #WED_mnuCopy)
;   loadShortcutEditor(#SCS_ShortEditor_Paste, "FnPaste", "Ctrl+V", #WED_mnuPaste)
  ; nb above shortcuts (Ctrl+X/C/V) replaced with Ctrl+1/2/3 16/06/2015 to allow Ctrl+C etc to be used on individual fields, eg time fields
  loadShortcutEditor(#SCS_ShortEditor_Cut, "FnCut", "Ctrl+1", #WED_mnuCut)
  loadShortcutEditor(#SCS_ShortEditor_Copy, "FnCopy", "Ctrl+2", #WED_mnuCopy)
  loadShortcutEditor(#SCS_ShortEditor_Paste, "FnPaste", "Ctrl+3", #WED_mnuPaste)
  loadShortcutEditor(#SCS_ShortEditor_SelectAll, "FnSelAll", "Ctrl+A", #SCS_WEDF_SelectAll)
  loadShortcutEditor(#SCS_ShortEditor_FindCue, "FnFindCue", "Ctrl+F", #SCS_WEDF_FindCue)
  loadShortcutEditor(#SCS_ShortEditor_Undo, "FnUndo", "Ctrl+Z", #SCS_WEDF_Undo)
  loadShortcutEditor(#SCS_ShortEditor_Redo, "FnRedo", "Ctrl+Y", #SCS_WEDF_Redo)
  CompilerIf #c_cuepanel_multi_dev_select
    loadShortcutEditor(#SCS_ShortEditor_CallLinkDevs, "FnCallLinkDevs", "Ctrl+L", #SCS_WEDF_CallLinkDevs)
  CompilerEndIf
  loadShortcutEditor(#SCS_ShortEditor_ProdProps, "FnProdProps", "Ctrl+Q", #WED_mnuProdProperties, Lang("Menu", "mnuProdProperties"))
  loadShortcutEditor(#SCS_ShortEditor_Collect, "FnCollect", "Ctrl+K", #WED_mnuCollect, Lang("Menu", "mnuCollect"))
  loadShortcutEditor(#SCS_ShortEditor_ImportDevs, "FnImportDevs", "Ctrl+D", #WED_mnuImportDevs, Lang("Menu", "mnuImportDevs"))
  loadShortcutEditor(#SCS_ShortEditor_Timer, "FnTimer", "Ctrl+T", #WED_mnuProdTimer, Lang("Menu", "mnuProdTimer"))
  loadShortcutEditor(#SCS_ShortEditor_AddQF, "FnAddQF", "Alt+F",       #WED_mnuAddQF, Lang("Menu", "mnuAddQF"))
  loadShortcutEditor(#SCS_ShortEditor_AddSF, "FnAddSF", "Alt+Shift+F", #WED_mnuAddSF, Lang("Menu", "mnuAddSF"))
  loadShortcutEditor(#SCS_ShortEditor_AddQA, "FnAddQA", "Alt+V",       #WED_mnuAddQA, Lang("Menu", "mnuAddQA"))
  loadShortcutEditor(#SCS_ShortEditor_AddSA, "FnAddSA", "Alt+Shift+V", #WED_mnuAddSA, Lang("Menu", "mnuAddSA"))
  loadShortcutEditor(#SCS_ShortEditor_AddQI, "FnAddQI", "Alt+I",       #WED_mnuAddQI, Lang("Menu", "mnuAddQI"))
  loadShortcutEditor(#SCS_ShortEditor_AddSI, "FnAddSI", "Alt+Shift+I", #WED_mnuAddSI, Lang("Menu", "mnuAddSI"))
  loadShortcutEditor(#SCS_ShortEditor_AddQK, "FnAddQK", "Alt+K",       #WED_mnuAddQK, Lang("Menu", "mnuAddQK"))
  loadShortcutEditor(#SCS_ShortEditor_AddSK, "FnAddSK", "Alt+Shift+K", #WED_mnuAddSK, Lang("Menu", "mnuAddSK"))
  loadShortcutEditor(#SCS_ShortEditor_AddQS, "FnAddQS", "Alt+S",       #WED_mnuAddQS, Lang("Menu", "mnuAddQS"))
  loadShortcutEditor(#SCS_ShortEditor_AddSS, "FnAddSS", "Alt+Shift+S", #WED_mnuAddSS, Lang("Menu", "mnuAddSS"))
  loadShortcutEditor(#SCS_ShortEditor_AddQL, "FnAddQL", "Alt+L",       #WED_mnuAddQL, Lang("Menu", "mnuAddQL"))
  loadShortcutEditor(#SCS_ShortEditor_AddSL, "FnAddSL", "Alt+Shift+L", #WED_mnuAddSL, Lang("Menu", "mnuAddSL"))
  loadShortcutEditor(#SCS_ShortEditor_AddQM, "FnAddQM", "Alt+M",       #WED_mnuAddQM, Lang("Menu", "mnuAddQM"))
  loadShortcutEditor(#SCS_ShortEditor_AddSM, "FnAddSM", "Alt+Shift+M", #WED_mnuAddSM, Lang("Menu", "mnuAddSM"))
  loadShortcutEditor(#SCS_ShortEditor_AddQN, "FnAddQN", "Alt+N",       #WED_mnuAddQN, Lang("Menu", "mnuAddQN"))
  loadShortcutEditor(#SCS_ShortEditor_AddQE, "FnAddQE", "Alt+E",       #WED_mnuAddQE, Lang("Menu", "mnuAddQE"))
  loadShortcutEditor(#SCS_ShortEditor_AddSE, "FnAddSE", "Alt+Shift+E", #WED_mnuAddSE, Lang("Menu", "mnuAddSE"))
  loadShortcutEditor(#SCS_ShortEditor_AddQP, "FnAddQP", "Alt+P",       #WED_mnuAddQP, Lang("Menu", "mnuAddQP"))
  loadShortcutEditor(#SCS_ShortEditor_AddSP, "FnAddSP", "Alt+Shift+P", #WED_mnuAddSP, Lang("Menu", "mnuAddSP"))
  loadShortcutEditor(#SCS_ShortEditor_AddQG, "FnAddQG", "Alt+G",       #WED_mnuAddQG, Lang("Menu", "mnuAddQG"))
  loadShortcutEditor(#SCS_ShortEditor_AddSG, "FnAddSG", "Alt+Shift+G", #WED_mnuAddSG, Lang("Menu", "mnuAddSG"))
  loadShortcutEditor(#SCS_ShortEditor_AddQT, "FnAddQT", "Alt+T",       #WED_mnuAddQT, Lang("Menu", "mnuAddQT"))
  loadShortcutEditor(#SCS_ShortEditor_AddST, "FnAddST", "Alt+Shift+T", #WED_mnuAddST, Lang("Menu", "mnuAddST"))
  loadShortcutEditor(#SCS_ShortEditor_AddQU, "FnAddQU", "Alt+U",       #WED_mnuAddQU, Lang("Menu", "mnuAddQU"))
  loadShortcutEditor(#SCS_ShortEditor_AddSU, "FnAddSU", "Alt+Shift+U", #WED_mnuAddSU, Lang("Menu", "mnuAddSU"))
  loadShortcutEditor(#SCS_ShortEditor_AddQR, "FnAddQR", "Alt+R",       #WED_mnuAddQR, Lang("Menu", "mnuAddQR"))
  loadShortcutEditor(#SCS_ShortEditor_AddSR, "FnAddSR", "Alt+Shift+R", #WED_mnuAddSR, Lang("Menu", "mnuAddSR"))
  loadShortcutEditor(#SCS_ShortEditor_AddQQ, "FnAddQQ", "Alt+Q",       #WED_mnuAddQQ, Lang("Menu", "mnuAddQQ"))
  loadShortcutEditor(#SCS_ShortEditor_AddSQ, "FnAddSQ", "Alt+Shift+Q", #WED_mnuAddSQ, Lang("Menu", "mnuAddSQ"))
  loadShortcutEditor(#SCS_ShortEditor_AddQJ, "FnAddQJ", "Alt+J",       #WED_mnuAddQJ, Lang("Menu", "mnuAddQJ"))
  loadShortcutEditor(#SCS_ShortEditor_AddSJ, "FnAddSJ", "Alt+Shift+J", #WED_mnuAddSJ, Lang("Menu", "mnuAddSJ"))
  loadShortcutEditor(#SCS_ShortEditor_Renumber, "FnRenumber", "Ctrl+R", #WED_mnuRenumberCues, Lang("Menu", "mnuRenumberCues"))
  loadShortcutEditor(#SCS_ShortEditor_BulkEdit, "FnBulkEdit", "Ctrl+B", #WED_mnuBulkEditCues, Lang("Menu", "mnuBulkEditCues"))
  loadShortcutEditor(#SCS_ShortEditor_CopyMoveEtc, "FnCopyMoveEtc", "Ctrl+M", #WED_mnuMultiCueCopyEtc, LangWithAlt("Menu", "mnuMultiCueCopyEtc2", "mnuMultiCueCopyEtc"))
  loadShortcutEditor(#SCS_ShortEditor_ImportCues, "FnImportCues", "Ctrl+I", #WED_mnuImportCues, Lang("Menu", "mnuImportCues"))
  loadShortcutEditor(#SCS_ShortEditor_ExportCues, "FnExportCues", "Ctrl+E", #WED_mnuExportCues, Lang("Menu", "mnuExportCues"))
  ; help category
  ; others
  loadShortcutEditor(#SCS_ShortEditor_Rewind,    "FnRewind",    "F4",        #SCS_WEDF_Rewind)
  loadShortcutEditor(#SCS_ShortEditor_PlayPause, "FnPlayPause", "F5",        #SCS_WEDF_PlayPause)
  loadShortcutEditor(#SCS_ShortEditor_Stop,      "FnStop",      "F6",        #SCS_WEDF_Stop)
  loadShortcutEditor(#SCS_ShortEditor_AddCueMarker, "FnAddCueMarker", "F7",  #SCS_WEDF_AddCueMarker)
  loadShortcutEditor(#SCS_ShortEditor_CueMarkerPrev, "FnCueMarkerPrev", "Ctrl+9", #SCS_WEDF_CueMarkerPrev) ; nb Ctrl+9, NOT Ctrl+Num9
  loadShortcutEditor(#SCS_ShortEditor_CueMarkerNext, "FnCueMarkerNext", "Ctrl+0", #SCS_WEDF_CueMarkerNext) ; nb Ctrl+0, NOT Ctrl+Num0
  loadShortcutEditor(#SCS_ShortEditor_DecLevels, "FnDecLevels", "Shift+F11", #SCS_WEDF_DecLevels)
  loadShortcutEditor(#SCS_ShortEditor_IncLevels, "FnIncLevels", "Shift+F12", #SCS_WEDF_IncLevels)
  loadShortcutEditor(#SCS_ShortEditor_SkipBack, "FnSkipBack", "Shift+F8", #SCS_WEDF_SkipBack)
  loadShortcutEditor(#SCS_ShortEditor_SkipForward, "FnSkipForward", "Shift+F9", #SCS_WEDF_SkipForward)
  loadShortcutEditor(#SCS_ShortEditor_ChangeFreqTempoPitch, "FnChangeFreqTempoPitch", "Ctrl+N", #WQF_mnu_ChangeFreqTempoPitch)
  loadShortcutEditor(#SCS_ShortEditor_TapDelay, "FnTapDelay", "Ctrl+.", #SCS_WEDK_TapDelay)
  
  ; now populate function descriptions from language array, and shortcut strings and codes from the defaults
  For n = 0 To ArraySize(gaShortcutsEditor())
    With gaShortcutsEditor(n)
      If Len(\sFunctionDescr) = 0
        If \sFunctionPrefKey
          \sFunctionDescr = Lang("Init", \sFunctionPrefKey)
        EndIf
      EndIf
      ; Debug "gaShortcutsEditor(" + n + ")\sFunctionPrefKey=" + \sFunctionPrefKey + ", \sFunctionDescr=" + \sFunctionDescr
      \sShortcutStr = \sDefaultShortcutStr
      \nShortcut = encodeShortcut(\sShortcutStr)
      \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
      ; Debug "gaShortcutsEditor(" + n + ")\sShortcutStr=" + \sShortcutStr + ", \nShortcut=$" + Hex(\nShortcut) + ", \nShortcutVK=$" + Hex(\nShortcutVK)
    EndWith
  Next n
  
  With grHotkeyDef
    \nCuePtr = -1
    \nHotkeyPanelRowNo = -1
  EndWith
  
  ; populate SFR Cue Type descriptions from language array
  For n = 0 To #SCS_SFR_CUE_LAST
    With gaSFRCueType(n)
      If (n = #SCS_SFR_CUE_NA) Or (n = #SCS_SFR_CUE_SEL)
        \sCueType = ""
        \sCueType2 = ""
      Else
        sTmp = "cue" + decodeSFRCueType(n)
        \sCueType = Lang("WQS", sTmp)
        \sCueType2 = Lang("WQS", sTmp + "2")
      EndIf
      ; debugMsg(sProcName, "gaSFRCueType(" + n + ")\sCueType=" + \sCueType + ", \sCueType2=" + \sCueType2)
    EndWith
  Next n
  
  ; populate SFR Action descriptions from language array (must be performed AFTER array gaShortcutsMain() populated)
  loadSFRActionDescrs()
  
  gnLastCue = 0
  gnCueEnd = 1
  gnRowEnd = 0
  gnStandbyCuePtr = -1
  gnSaveSettingsCount = 0
  ReDim gaSaveSettings(20)
  gnPLFirstAndLastTime = -1
  gnPlayWhenReadyAudPtr = -1
  gnPreviewGaplessSeqPtr = -1
  gnPrevLCAction = #SCS_LC_ACTION_ABSOLUTE ; Added 2Nov2021 11.8.6bn after checking adding a new (first) level change cue in a test for Clive Richards
  gnValidateSubPtr = -1
  
  gnGap = 5
  gnGap2 = 8
  gnShortGap = 3
  gnBtnGap = 6
  gnBtnHeight = 23
  gnLblVOffsetC = 4 ; vertical offset for labels of combobox gadgets
  gnLblVOffsetS = 3 ; vertical offset for labels of string gadgets
  
EndProcedure

Procedure setMainXandYfactors()
  PROCNAMEC()
  Protected nTempWindowNo, nTempWindowWidth, nTempWindowHeight
  
  nTempWindowNo = OpenWindow(#PB_Any, 0, 0, 20, 20, "", #PB_Window_Maximize | #PB_Window_Invisible)
  If nTempWindowNo
    nTempWindowWidth = WindowWidth(nTempWindowNo)
    nTempWindowHeight = WindowHeight(nTempWindowNo)
    debugMsg(sProcName, "gnMainWindowDesignWidth=" + gnMainWindowDesignWidth + ", gnMainWindowDesignHeight=" + gnMainWindowDesignHeight +
                        ", nTempWindowWidth=" + nTempWindowWidth + ", nTempWindowHeight=" + nTempWindowHeight)
    gfMainOrigXFactor = nTempWindowWidth / gnMainWindowDesignWidth
    gfMainOrigYFactor = nTempWindowHeight / gnMainWindowDesignHeight ; * _ScaleDPI_Y_
    gfMainXFactor = gfMainOrigXFactor
    gfMainYFactor = gfMainOrigYFactor
    debugMsg(sProcName, "gfMainOrigXFactor=" + StrF(gfMainOrigXFactor,4) + ", gfMainOrigYFactor=" + StrF(gfMainOrigYFactor,4) +
                        ", gfMainXFactor=" + StrF(gfMainXFactor,4) + ", gfMainYFactor=" + StrF(gfMainYFactor,4))
    CloseWindow(nTempWindowNo)
  EndIf
EndProcedure

; EOF