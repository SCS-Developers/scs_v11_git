; File: common.pbi

EnableExplicit

Procedure ensureSplashNotOnTop()
  ; A window can be made to stay 'on top' of other windows using the PureBasic command StickyWindow().
  ; If the splash screen is currently on top then this could hide a MessageRequester() message, so
  ; this Procedure can be called to turn off the stick property.
  If gbSplashOnTop
    If IsWindow(#WSP)
      setWindowSticky(#WSP, #False)
    EndIf
    gbSplashOnTop = #False
  EndIf
EndProcedure

Procedure.s formatDateAsDDMMMYYYY(pDate)
  Protected nMonth, sMonthCode.s, sFormattedDate.s
  
  nMonth = Month(pDate)
  If nMonth < 10
    sMonthCode = "MMM_0" + nMonth
  Else
    sMonthCode = "MMM_" + nMonth
  EndIf
  sFormattedDate = FormatDate("%dd ", pDate) + Lang("Common", sMonthCode) + FormatDate(" %yyyy", pDate)
  ProcedureReturn sFormattedDate
EndProcedure

Procedure.s decodeLicType(pLicType.s, dExpDate)
  Protected sDecoded.s
  Select pLicType
    Case "D"
      sDecoded = "Demo"
      
    Case "L"
      sDecoded = "SCS Lite"
      
    Case "S"
      sDecoded = "SCS Standard"
    Case "F2"
      sDecoded = "SCS Standard (2-user)"
    Case "F3"
      sDecoded = "SCS Standard (3-user)"
    Case "F4"
      sDecoded = "SCS Standard (4-user)"
    Case "FC"
      sDecoded = "SCS Standard (Corporate)"
    Case "FS"
      sDecoded = "SCS Standard (Student)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
      
    Case "P"
      sDecoded = "SCS Professional"
    Case "M2"
      sDecoded = "SCS Professional (2-user)"
    Case "M3"
      sDecoded = "SCS Professional (3-user)"
    Case "M4"
      sDecoded = "SCS Professional (4-user)"
    Case "MC"
      sDecoded = "SCS Professional (Corporate)"
    Case "ES"
      sDecoded = "SCS Professional (Student)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
    Case "Y"
      sDecoded = "SCS Professional (Corporate)"
      
    Case "T"
      sDecoded = "Temporary"
      
    Case "Q"
      sDecoded = "SCS Professional Plus"
    Case "G2"
      sDecoded = "SCS Professional Plus (2-user)"
    Case "G3"
      sDecoded = "SCS Professional Plus (3-user)"
    Case "G4"
      sDecoded = "SCS Professional Plus (4-user)"
    Case "GC"
      sDecoded = "SCS Professional Plus (Corporate)"
    Case "GS"
      sDecoded = "SCS Professional Plus (Student)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
      
    Case "Z"
      sDecoded = "SCS Platinum"
    Case "H2"
      sDecoded = "SCS Platinum (2-user)"
    Case "H3"
      sDecoded = "SCS Platinum (3-user)"
    Case "H4"
      sDecoded = "SCS Platinum (4-user)"
    Case "HC"
      sDecoded = "SCS Platinum (Corporate)"
      
    Case "NS"
      sDecoded = "SCS Standard (Time-Limited)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
    Case "NP"
      sDecoded = "SCS Professional (Time-Limited)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
    Case "NQ"
      sDecoded = "SCS Professional Plus (Time-Limited)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
    Case "NZ"
      sDecoded = "SCS Platinum (Time-Limited)" + #CRLF$ + "License expires " + formatDateAsDDMMMYYYY(dExpDate)
      
    Default
      sDecoded = ""
      
  EndSelect
  ProcedureReturn sDecoded
  
EndProcedure

Procedure.f convertDBLevelToBVLevel(fDBLevel.f, nRemDevMsgType=0)
  ; PROCNAMEC()
  ; Convert dB level to 'BASS Volume' (BASS_ATTRIB_VOL) level
  Protected fBVLevel.f
  Static nMyRemDevMsgType=-1, fMyMinDBLevel.f, fMyMaxDBLevel.f
  
  If fDBLevel = -Infinity() ; Added 16Oct2024 11.10.6ap
    fBVLevel = 0.0
  ElseIf nRemDevMsgType = 0
    fBVLevel = Pow(10, (fDBLevel / 20))
    ; eg if fDBLevel = 0.0, fBVLevel = 1.0
    ;    if fDBLevel = 12.0, fBVLevel = 3.9810717106
    ;    if fDBLevel = -12.0, fBVLevel = 0.2511886358
    ;    if fDBLevel = -75.0, fBVLevel = 0.0001778279
    ;    if fDBLevel = -120.0, fBVLevel = 0.000001
    ;    if fDBLevel = -160.0, fBVLevel = 0.00000001
    
    ; NOTE: Deleted 26Apr2024 11.10.2cf
    ; If fBVLevel <= grLevels\fMinBVLevel
    ;   fBVLevel = 0.0 ; BASS Volume 'silent'
    ; EndIf
    ; NOTE: End deleted 26Apr2024 11.10.2cf
    
  Else
    ; remote device processing - no relative levels
    If nRemDevMsgType <> nMyRemDevMsgType
      fMyMinDBLevel = CSRD_GetMinFaderLevelDBForRemDevMsgType(nRemDevMsgType)
      fMyMaxDBLevel = CSRD_GetMaxFaderLevelDBForRemDevMsgType(nRemDevMsgType)
      nMyRemDevMsgType = nRemDevMsgType
    EndIf
    ; NOTE: Deleted 26Apr2024 11.10.2cf
    ; If fDBLevel <= fMyMinDBLevel
    ;   fBVLevel = 0.0 ; BASS Volume 'silent'
    ; ElseIf fDBLevel > fMyMaxDBLevel
    ;   fBVLevel = Pow(10, (fMyMaxDBLevel / 20))
    ; Else
    ; NOTE: End deleted 26Apr2024 11.10.2cf
      fBVLevel = Pow(10, (fDBLevel / 20))
    ; EndIf ; NOTE: Deleted 26Apr2024 11.10.2cf

  EndIf
  ProcedureReturn fBVLevel
  
EndProcedure

Procedure.f convertBVLevelToDBLevel(fBVLevel.f)
  ; PROCNAMEC()
  ; Convert 'BASS Volume' (BASS_ATTRIB_VOL) level to dB level
  Protected fDBLevel.f, fDBLevel2.f
  
  fDBLevel = (20 * Log10(fBVLevel))
  ; remove unwanted decimals after the 'tenth' position
  fDBLevel2 = Round(fDBLevel * 10, #PB_Round_Nearest) / 10
  ; debugMsg(sProcName, "fDBLevel2=" + StrF(fDBLevel2,4))
  ProcedureReturn fDBLevel2
EndProcedure

Procedure.s convertBVLevelToDBString(fBVLevel.f, bRelativeLevel=#False, bAddPlusForGtZero=#True, nRemDevMsgType=0)
  ; PROCNAMEC()
  ; Convert 'BASS Volume' (BASS_ATTRIB_VOL) level to dB string
  Protected fDBLevel.f, sDBLevel.s, nDecimalPlaces
  
  If fBVLevel = grLevels\fSilentBVLevel ; = 0.0
    sDBLevel = #SCS_INF_DBLEVEL ; "-INF"
  Else
    fDBLevel = convertBVLevelToDBLevel(fBVLevel)
    If fDBLevel > -100.0 And fDBLevel < 100.0
      nDecimalPlaces = 1
    EndIf
    
    If bRelativeLevel
      If fDBLevel >= 0.0
        sDBLevel = "+" + StrF(fDBLevel, nDecimalPlaces)
      Else
        sDBLevel = StrF(fDBLevel, nDecimalPlaces)
      EndIf
    Else
      If (fDBLevel > 0.0) And (bAddPlusForGtZero)
        sDBLevel = "+" + StrF(fDBLevel, nDecimalPlaces)
      Else
        sDBLevel = StrF(fDBLevel, nDecimalPlaces)
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "fBVLevel=" + formatLevel(fBVLevel) + ", bRelativeLevel=" + strB(bRelativeLevel) + ", sDBLevel=" + sDBLevel)
  ProcedureReturn sDBLevel
  
EndProcedure

Procedure.s convertBVLevelToDBStringWithMinusInf(fBVLevel.f, bAddPlusForGtZero=#True)
  ; PROCNAMEC()
  Protected fDBLevel.f, sDBLevel.s, nDecimalPlaces
  
  ; debugMsg(sProcName, "fBVLevel=" + StrF(fBVLevel,4) + ", grLevels\sMaxDBLevel=" + grLevels\sMaxDBLevel + ", grLevels\fMaxBVLevel=" + StrF(grLevels\fMaxBVLevel,4) + ", gfFdrDBHeadroom=" + StrF(gfFdrDBHeadroom,4))
  
  If fBVLevel <= grLevels\fMinBVLevel
    sDBLevel = #SCS_INF_DBLEVEL ; "-INF"
  Else
    fDBLevel = convertBVLevelToDBLevel(fBVLevel)
    If fDBLevel > -100.0 And fDBLevel < 100.0
      nDecimalPlaces = 1
    EndIf
    If (fDBLevel > 0.0) And (bAddPlusForGtZero)
      sDBLevel = "+" + StrF(fDBLevel, nDecimalPlaces)
    Else
      sDBLevel = StrF(fDBLevel, nDecimalPlaces)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "fBVLevel=" + formatLevel(fBVLevel) + ", bRelativeLevel=" + strB(bRelativeLevel) + ", sDBLevel=" + sDBLevel)
  ProcedureReturn sDBLevel
  
EndProcedure

Procedure.f convertDBStringToBVLevel(sDBString.s, nRemDevMsgType=0)
  ; PROCNAMEC()
  ; Procedure to convert a dB string to the 'BASS Volume' equivalent (BASS_ATTRIB_VOL)
  Protected fDBLevel.f, fBVLevel.f, sdB.s
  
  sdB = Trim(sDBString)
  If Len(sdB) = 0 Or sdB = #SCS_INF_DBLEVEL ; #SCS_INF_DBLEVEL = "-INF"
    fBVLevel = grLevels\fSilentBVLevel
  Else
    fDBLevel = ValF(sdB)
    fBVLevel = convertDBLevelToBVLevel(fDBLevel, nRemDevMsgType)
  EndIf
  ProcedureReturn fBVLevel
  
EndProcedure

Procedure.f convertDBStringToDBLevel(sDBString.s, nRemDevMsgType=0)
  PROCNAMEC()
  Protected fDBLevel.f, sdB.s
  Static nMyRemDevMsgType=-1, fMyMinDBLevel.f
  
  ; Modified 9Dec2023 11.10.0dk to ALWAYS set fMyMinDBLevel from grLevels\nMinDBLevel if nRemDevMsgType=0
  ; to allow for the user changing the minimum audible dB level in Production Properties,
  ; or opening a new cue file that has a different minimum.
  If nRemDevMsgType = 0
    fMyMinDBLevel = grLevels\nMinDBLevel
  ElseIf nRemDevMsgType <> nMyRemDevMsgType
    fMyMinDBLevel = CSRD_GetMinFaderLevelDBForRemDevMsgType(nRemDevMsgType)
    nMyRemDevMsgType = nRemDevMsgType
  EndIf
  
  sdB = Trim(ReplaceString(sDBString, "db", "", #PB_String_NoCase))
  If Len(sdB) = 0 Or sdB = #SCS_INF_DBLEVEL
    fDBLevel = fMyMinDBLevel
  Else
    fDBLevel = ValF(sdB)
  EndIf
  ProcedureReturn fDBLevel
  
EndProcedure

Procedure.s convertDBLevelToDBString(fDBLevel.f)
  Protected sDBString.s, nDecimalPlaces
  
  If fDBLevel > -100.0 And fDBLevel < 100.0
    nDecimalPlaces = 1
  EndIf
  If fDBLevel >= 0.0
    sDBString = "+" + StrF(fDBLevel, nDecimalPlaces)
  Else
    sDBString = StrF(fDBLevel, nDecimalPlaces)
  EndIf
  ProcedureReturn sDBString
  
EndProcedure

Procedure.f dbTrimStringToFactor(pdBString.s)
;  PROCNAMEC()
  Protected nSliderValNoTrim, nSliderValThisTrim, fFactor.f
  
  nSliderValNoTrim = SLD_BVLevelToSliderValue(convertDBStringToBVLevel("0"))
  nSliderValThisTrim = SLD_BVLevelToSliderValue(convertDBStringToBVLevel(pdBString))
  fFactor = nSliderValNoTrim / nSliderValThisTrim
  ProcedureReturn fFactor
EndProcedure

Procedure.f dbTrimStringToSingle(pdBString.s)
  ; PROCNAMEC()
  Protected fdB.f, sdB.s
  
  sdB = Trim(ReplaceString(pdBString, "db", "", #PB_String_NoCase))
  fdB = ValF(sdB)
  
  ; debugMsg(sProcName, "pdBString=" + pdBString + ",fdB=" + StrF(fdB,2))
  ProcedureReturn fdB
EndProcedure

Procedure dbStringToMixerLevel(pdBString.s)
  ; PROCNAMEC()
  Protected fdB.f, sdB.s
  Protected nMixerLevel
  
  sdB = Trim(pdBString)
  If sdB
    fdB = ValF(sdB)
    nMixerLevel = gnMaxMixerLevel * Pow(10,(fdB/20))
  EndIf
  ProcedureReturn nMixerLevel
EndProcedure

Procedure.s decToHex2(pDec)
  ; PROCNAMEC()
  Protected nTmp
  
  nTmp = pDec & $FF
  ProcedureReturn RSet(Hex(nTmp), 2, "0")
  
EndProcedure

Procedure decodeExpString(sExpString.s, *nExpFactor.Long)
  PROCNAMEC()
  Protected sStudent.s, sTmp.s, nDays, n
  Protected nBase, sChar.s, nMyDate
  
  debugMsg(sProcName, #SCS_START + " *")
  
  sStudent = UCase("7zaQ9Ws" + "3xc5DeRF" + "v6bGTyHNm84jUklP")
  nBase = Len(sStudent)
  nDays = 0
  sTmp = UCase(sExpString)
  For n = Len(sTmp) To 1 Step -1
    sChar = Mid(sTmp, n, 1)
    nDays = (nDays * nBase) + FindString(sStudent, sChar, 1) - 1
  Next n
  CompilerIf #cTraceAuthString
    debugMsgAS(sProcName, "nDays=" + nDays)
  CompilerEndIf
  nMyDate = numberToDate(nDays)
  *nExpFactor\l = nDays
  ProcedureReturn nMyDate
EndProcedure

Procedure.s encodeExpString(dExpDate, *nExpFactor.Long)
  PROCNAMEC()
  Protected sStudent.s, sTmp.s
  Protected nDays
  Protected n, nBase, nTmp
  
  debugMsg(sProcName, #SCS_START + " *")
  
  sStudent = UCase("7zaQ9Ws" + "3xc5DeRF" + "v6bGTyHNm84jUklP")
  nBase = Len(sStudent)
  
  nDays = dateToNumber(dExpDate)
  
  sTmp = ""
  nTmp = nDays
  While nTmp > 0
    n = (nTmp % nBase) + 1
    sTmp + Mid(sStudent, n, 1)
    nTmp = Round(nTmp / nBase, #PB_Round_Down)
  Wend
  
  *nExpFactor\l = nDays
  ProcedureReturn sTmp
  
EndProcedure

Procedure.s decodeSubTypeL(pSubType.s, pSubPtr)
  PROCNAMEC()
  Protected sSubTypeDescr.s, n, sTmp.s
  Protected nStop, nFadeOut, nRelease, nTrack, nUnique
  Protected nHibernate, nResume, nPause, nCancelRepeat
  Protected nStopAll, nFadeAll, nPauseAll, nStopMTC, nStopChase
  Protected nEnable, nDisable
  Protected nAudPtr
  Protected nSFRCueType, nSFRAction
  Static bStaticLoaded
  Static sStop.s, sFadeOut.s, sRelease.s, sTrack.s, sPause.s, sResume.s, sHibernate.s, sCancelRepeat.s
  Static sStopAll.s, sFadeAll.s, sPauseAll.s, sStopMTC.s, sStopChase.s
  Static sEnable.s, sDisable.s
  
  If bStaticLoaded = #False
    sStop = Lang("SFR_Short", "Stop") + "&"
    sFadeOut = Lang("SFR_Short", "FadeOut") + "&"
    sRelease = Lang("SFR_Short", "Release") + "&"
    sCancelRepeat = Lang("SFR_Short", "CancelRepeat") + "&"
    sTrack = Lang("SFR_Short", "Track") + "&"
    sPause = Lang("SFR_Short", "Pause") + "&"
    sResume = Lang("SFR_Short", "Resume") + "&"
    sHibernate = Lang("SFR_Short", "Hibernate") + "&"
    sStopAll = Lang("SFR_Short", "StopAll") + "&"
    sFadeAll = Lang("SFR_Short", "FadeAll") + "&"
    sPauseAll = Lang("SFR_Short", "PauseAll") + "&"
    sEnable = Lang("Common", "Enable")
    sDisable = Lang("Common", "Disable")
    If grLicInfo\bLTCAvailable
      sStopMTC = Lang("SFR_Short", "StopMTCLTC") + "&"
    Else
      sStopMTC = Lang("SFR_Short", "StopMTC") + "&"
    EndIf
    sStopChase = Lang("SFR_Short", "StopChase") + "&"
    bStaticLoaded = #True
  EndIf
  
  Select UCase(pSubType)
    Case "A"
      sSubTypeDescr = Lang("CueType", "AV")
      If pSubPtr >= 0
        nAudPtr = aSub(pSubPtr)\nFirstAudIndex
        If nAudPtr >= 0
          If aAud(nAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE
            sSubTypeDescr = Lang("CueType", "AI")
          ElseIf aAud(nAudPtr)\nFileFormat = #SCS_FILEFORMAT_CAPTURE
            sSubTypeDescr = Lang("CueType", "AC")
          EndIf
        EndIf
      EndIf
      
    Case "E"
      sSubTypeDescr = grText\sTextCueTypeE
      
    Case "F"
      sSubTypeDescr = grText\sTextCueTypeF
      
    Case "G"
      sSubTypeDescr = grText\sTextCueTypeG
      
    Case "H"
      sSubTypeDescr = grText\sTextCueTypeH
      
    Case "I"
      sSubTypeDescr = grText\sTextCueTypeI
      
    Case "J"
      If pSubPtr >= 0
        For n = 0 To #SCS_MAX_ENABLE_DISABLE
          With aSub(pSubPtr)\aEnableDisable[n]
            If \sFirstCue
              Select \nAction
                Case #SCS_ENADIS_ENABLE
                  nEnable = 1
                Case #SCS_ENADIS_DISABLE
                  nDisable = 1
              EndSelect
            EndIf
          EndWith
        Next n
      EndIf
      If (nEnable = 1) And (nDisable = 0)
        sSubTypeDescr = sEnable
      ElseIf (nDisable = 1) And (nEnable = 0)
        sSubTypeDescr = sDisable
      Else
        sSubTypeDescr = grText\sTextCueTypeJ
      EndIf
      
    Case "L"
      sSubTypeDescr = grText\sTextCueTypeL
      
    Case "M"
      sSubTypeDescr = grText\sTextCueTypeM
      
    Case "N"
      sSubTypeDescr = grText\sTextCueTypeN
      
    Case "P"
      sSubTypeDescr = grText\sTextCueTypeP
      
    Case "Q"
      sSubTypeDescr = grText\sTextCueTypeQ
      
    Case "R"
      sSubTypeDescr = grText\sTextCueTypeR
      
    Case "S"
      sSubTypeDescr = grText\sTextCueTypeS
      If pSubPtr >= 0
        With aSub(pSubPtr)
          For n = 0 To #SCS_MAX_SFR
            nSFRCueType = \nSFRCueType[n]
            nSFRAction = \nSFRAction[n]
            If (\sSFRCue[n]) Or (nSFRCueType <> #SCS_SFR_CUE_NA)
              sSubTypeDescr = gaSFRAction(nSFRAction)\sActDescr2
              Select nSFRAction
                Case #SCS_SFR_ACT_STOP
                  nStop = 1
                Case #SCS_SFR_ACT_FADEOUT
                  nFadeOut = 1
                Case #SCS_SFR_ACT_RELEASE
                  nRelease = 1
                Case #SCS_SFR_ACT_CANCELREPEAT
                  nCancelRepeat = 1
                Case #SCS_SFR_ACT_TRACK
                  nTrack = 1
                Case #SCS_SFR_ACT_PAUSEHIB
                  nPause = 1
                  nHibernate = 1
                Case #SCS_SFR_ACT_FADEOUTHIB
                  nFadeOut = 1
                  nHibernate = 1
                Case #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT, #SCS_SFR_ACT_RESUME
                  nResume = 1
                Case #SCS_SFR_ACT_PAUSE
                  nPause = 1
                Case #SCS_SFR_ACT_STOPALL
                  nStopAll = 1
                Case #SCS_SFR_ACT_FADEALL
                  nFadeAll = 1
                Case #SCS_SFR_ACT_PAUSEALL
                  nPauseAll = 1
                Case #SCS_SFR_ACT_STOPMTC
                  nStopMTC = 1
                Case #SCS_SFR_ACT_STOPCHASE
                  nStopChase = 1
              EndSelect
            EndIf
          Next n
          nUnique = nStop + nFadeOut + nRelease + nCancelRepeat + nTrack + nHibernate + nResume + nPause + nStopAll + nFadeAll + nPauseAll + nStopMTC + nStopChase
          If nUnique > 1
            sTmp = ""
            If nStop > 0 : sTmp = sStop : EndIf
            If nFadeOut > 0 : sTmp + sFadeOut : EndIf
            If nRelease > 0 : sTmp + sRelease : EndIf
            If nCancelRepeat > 0 : sTmp + sCancelRepeat : EndIf
            If nTrack > 0 : sTmp + sTrack : EndIf
            If nPause > 0 : sTmp + sPause : EndIf
            If nResume > 0 : sTmp + sResume : EndIf
            If nHibernate > 0 : sTmp + sHibernate : EndIf
            If nStopAll > 0 : sTmp + sStopAll : EndIf
            If nFadeAll > 0 : sTmp + sFadeAll : EndIf
            If nPauseAll > 0 : sTmp + sPauseAll : EndIf
            If nStopMTC > 0 : sTmp + sStopMTC : EndIf
            If nStopChase > 0 : sTmp + sStopChase : EndIf
            If sTmp : sTmp = Left(sTmp, Len(sTmp) - 1) : EndIf
            sSubTypeDescr = sTmp
          EndIf
        EndWith
      EndIf
      
    Case "T"
      sSubTypeDescr = grText\sTextCueTypeT
      
    Case "U"
      sSubTypeDescr = grText\sTextCueTypeU
      
    Default
      sSubTypeDescr = Lang("CueType", pSubType)
      
  EndSelect
  ProcedureReturn sSubTypeDescr
EndProcedure

Procedure.s decode2ndSubType(pSubType.s, pSubPtr)
  PROCNAMEC()
  Protected sSubTypeDescr.s, n, sTmp.s
  Protected nStop, nFadeOut, nRelease, nTrack, nUnique
  Protected nStopAll, nFadeAll, nPauseAll, nStopMTC, nStopChase
  Protected nHibernate, nResume, nPause, nCancelRepeat
  Protected nAudPtr
  Protected nSFRCueType, nSFRAction
  Static bStaticLoaded
  Static sStop.s, sFadeOut.s, sRelease.s, sTrack.s, sPause.s, sResume.s, sHibernate.s, sCancelRepeat.s
  Static sStopAll.s, sFadeAll.s, sPauseAll.s, sStopMTC.s, sStopChase.s
  Static sEnable.s, sDisable.s
  
  If bStaticLoaded = #False
    sStop = Lang("SFR_Short", "Stop") + "&"
    sFadeOut = Lang("SFR_Short", "FadeOut") + "&"
    sRelease = Lang("SFR_Short", "Release") + "&"
    sCancelRepeat = Lang("SFR_Short", "CancelRepeat") + "&"
    sTrack = Lang("SFR_Short", "Track") + "&"
    sPause = Lang("SFR_Short", "Pause") + "&"
    sResume = Lang("SFR_Short", "Resume") + "&"
    sHibernate = Lang("SFR_Short", "Hibernate") + "&"
    sStopAll = Lang("SFR_Short", "StopAll") + "&"
    sFadeAll = Lang("SFR_Short", "FadeAll") + "&"
    sPauseAll = Lang("SFR_Short", "PauseAll") + "&"
    sEnable = Lang("Common", "Enable")
    sDisable = Lang("Common", "Disable")
    If grLicInfo\bLTCAvailable
      sStopMTC = Lang("SFR_Short", "StopMTCLTC") + "&"
    Else
      sStopMTC = Lang("SFR_Short", "StopMTC") + "&"
    EndIf
    sStopChase = Lang("SFR_Short", "StopChase") + "&"
    bStaticLoaded = #True
  EndIf
  
  sSubTypeDescr = Lang("CueType", pSubType)
  
  Select UCase(pSubType)
    Case "A"
      sSubTypeDescr = Lang("CueType", "AV")
      If pSubPtr >= 0
        nAudPtr = a2ndSub(pSubPtr)\nFirstAudIndex
        If nAudPtr >= 0
          If a2ndAud(nAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE
            sSubTypeDescr = Lang("CueType", "AI")
          EndIf
        EndIf
      EndIf
      
    Case "S"
      sSubTypeDescr = grText\sTextCueTypeS
      If pSubPtr >= 0
        With a2ndSub(pSubPtr)
          For n = 0 To #SCS_MAX_SFR
            nSFRCueType = \nSFRCueType[n]
            nSFRAction = \nSFRAction[n]
            If (\sSFRCue[n]) Or (nSFRCueType <> #SCS_SFR_CUE_NA)
              sSubTypeDescr = gaSFRAction(nSFRAction)\sActDescr2
              Select nSFRAction
                Case #SCS_SFR_ACT_STOP
                  nStop = 1
                Case #SCS_SFR_ACT_FADEOUT
                  nFadeOut = 1
                Case #SCS_SFR_ACT_RELEASE
                  nRelease = 1
                Case #SCS_SFR_ACT_CANCELREPEAT
                  nCancelRepeat = 1
                Case #SCS_SFR_ACT_TRACK
                  nTrack = 1
                Case #SCS_SFR_ACT_PAUSEHIB
                  nPause = 1
                  nHibernate = 1
                Case #SCS_SFR_ACT_FADEOUTHIB
                  nFadeOut = 1
                  nHibernate = 1
                Case #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT, #SCS_SFR_ACT_RESUME
                  nResume = 1
                Case #SCS_SFR_ACT_PAUSE
                  nPause = 1
                Case #SCS_SFR_ACT_STOPALL
                  nStopAll = 1
                Case #SCS_SFR_ACT_FADEALL
                  nFadeAll = 1
                Case #SCS_SFR_ACT_PAUSEALL
                  nPauseAll = 1
                Case #SCS_SFR_ACT_STOPMTC
                  nStopMTC = 1
                Case #SCS_SFR_ACT_STOPCHASE
                  nStopChase = 1
              EndSelect
            EndIf
          Next n
          nUnique = nStop + nFadeOut + nRelease + nCancelRepeat + nTrack + nHibernate + nResume + nPause + nStopAll + nFadeAll + nPauseAll + nStopMTC + nStopChase
          If nUnique > 1
            sTmp = ""
            If nStop > 0 : sTmp = sStop : EndIf
            If nFadeOut > 0 : sTmp + sFadeOut : EndIf
            If nRelease > 0 : sTmp + sRelease : EndIf
            If nCancelRepeat > 0 : sTmp + sCancelRepeat : EndIf
            If nTrack > 0 : sTmp + sTrack : EndIf
            If nPause > 0 : sTmp + sPause : EndIf
            If nResume > 0 : sTmp + sResume : EndIf
            If nHibernate > 0 : sTmp + sHibernate : EndIf
            If nStopAll > 0 : sTmp + sStopAll : EndIf
            If nFadeAll > 0 : sTmp + sFadeAll : EndIf
            If nPauseAll > 0 : sTmp + sPauseAll : EndIf
            If nStopMTC > 0 : sTmp + sStopMTC : EndIf
            If nStopChase > 0 : sTmp + sStopChase : EndIf
            If sTmp : sTmp = Left(sTmp, Len(sTmp) - 1) : EndIf
            sSubTypeDescr = sTmp
          EndIf
        EndWith
      EndIf
      
  EndSelect
  ProcedureReturn sSubTypeDescr
EndProcedure

Procedure.s getCueActivationMethodForDisplay(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nSubPtr, nAudPtr, n
  Protected nLinkedToAudPtr, nMTCLinkedToAFSubPtr
  Protected sMethod.s
  Protected nCueMarkerPlaybackPosition
  Static sTextLinked.s, sTextCallableCue.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sTextLinked = Lang("Common", "Linked")
    sTextCallableCue = Lang("WEC", "acmCallQ")
    bStaticLoaded = #True
  EndIf
  
  nSubPtr = -1
  nAudPtr = -1
  nLinkedToAudPtr = -1
  nMTCLinkedToAFSubPtr = -1
  
  If pCuePtr >= 0
    nSubPtr = aCue(pCuePtr)\nFirstSubIndex
    If nSubPtr >= 0
      If aSub(nSubPtr)\bSubTypeHasAuds
        nAudPtr = aSub(nSubPtr)\nFirstAudIndex
        If nAudPtr >= 0
          nLinkedToAudPtr = aAud(nAudPtr)\nLinkedToAudPtr
        EndIf
      ElseIf aSub(nSubPtr)\bSubTypeU
        If aSub(nSubPtr)\nMTCLinkedToAFSubPtr >= 0
          nMTCLinkedToAFSubPtr = aSub(nSubPtr)\nMTCLinkedToAFSubPtr
        EndIf
      EndIf
    EndIf
    
    If nLinkedToAudPtr >= 0 Or nMTCLinkedToAFSubPtr >= 0
      sMethod = sTextLinked
    Else
      With aCue(pCuePtr)
        Select \nActivationMethod
          Case #SCS_ACMETH_MAN
            sMethod = grText\sTextManual
            
          Case #SCS_ACMETH_MAN_PLUS_CONF
            sMethod = Lang("Common", "Manual+Conf")
            
          Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
            If \nAutoActPosn <> #SCS_ACPOSN_OCM
              sMethod = timeToString(\nAutoActTime)
            EndIf
            ; debugMsg(sProcName, "\nAutoActTime=" + \nAutoActTime + ", sMethod=" + sMethod)
            Select \nAutoActPosn
              Case #SCS_ACPOSN_AS
                sMethod + " as "
              Case #SCS_ACPOSN_AE
                sMethod + " ae "
              Case #SCS_ACPOSN_BE
                sMethod + " be "
              Case #SCS_ACPOSN_LOAD
                sMethod + " aft.load"
              Case #SCS_ACPOSN_OCM
                ; not used for cue files SAVED by SCS 11.8.2 or later as cue activation method #SCS_ACMETH_OCM supercedes this
                sMethod = "ocm "
            EndSelect
            If \nAutoActPosn <> #SCS_ACPOSN_LOAD
              If (\nAutoActCueSelType = #SCS_ACCUESEL_PREV) And (\nAutoActPosn <> #SCS_ACPOSN_OCM)
                sMethod + "Prev"
              ElseIf \nAutoActCuePtr >= 0
                If (\nAutoActCueSelType = #SCS_ACCUESEL_CM) Or (Trim(sMethod) = Trim(decodeAutoActPosn(#SCS_ACPOSN_OCM)))
                  ; Add the OCM and Marker Name for Auto Activation
;                   debugMsg(sProcName, "\nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) +
;                                       ", \nAutoActSubNo=" + \nAutoActSubNo +
;                                       ", \nAutoActAudNo=" + \nAutoActAudNo +
;                                       ", \sAutoActCueMarkerName=" + \sAutoActCueMarkerName)
                  For n = 0 To gnMaxCueMarkerInfo
                    If gaCueMarkerInfo(n)\bOCMAvailable
                      If (gaCueMarkerInfo(n)\nHostCuePtr = \nAutoActCuePtr) And
                         (gaCueMarkerInfo(n)\nHostSubNo = \nAutoActSubNo) And
                         (gaCueMarkerInfo(n)\nHostAudNo = \nAutoActAudNo) And
                         (gaCueMarkerInfo(n)\sCueMarkerName = \sAutoActCueMarkerName)
                        sMethod + gaCueMarkerInfo(n)\sCueMarkerDisplayInfo
                        Break
                      EndIf
                    EndIf
                  Next n
                Else
                  sMethod + aCue(\nAutoActCuePtr)\sCue
                EndIf
              EndIf
              If \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
                sMethod + ",+C"
              EndIf
            EndIf
            
          Case #SCS_ACMETH_CALL_CUE
            sMethod = sTextCallableCue
            
          Case #SCS_ACMETH_HK_TRIGGER
            sMethod = "HKey(trig) " + \sHotkey
          Case #SCS_ACMETH_HK_TOGGLE
            sMethod = "HKey(togl) " + \sHotkey
          Case #SCS_ACMETH_HK_NOTE
            sMethod = "HKey(note) " + \sHotkey
          Case #SCS_ACMETH_HK_STEP
            sMethod = "HKey(step) " + \sHotkey + "#" + \nCueHotkeyStepNo
            
          Case #SCS_ACMETH_TIME
            If Len(\sTimeBasedLatestStartReqd) > 0 And (\sTimeBasedLatestStartReqd <> \sTimeBasedStartReqd)
              sMethod = \sTimeBasedStartReqd +" - "+ \sTimeBasedLatestStartReqd
            Else
              sMethod = \sTimeBasedStartReqd
            EndIf
            
          Case #SCS_ACMETH_EXT_TRIGGER
            sMethod = "Ext(trig)"
          Case #SCS_ACMETH_EXT_TOGGLE
            sMethod = "Ext(togl)"
          Case #SCS_ACMETH_EXT_NOTE
            sMethod = "Ext(note)"
          Case #SCS_ACMETH_EXT_STEP
            sMethod = "Ext(step)"
          Case #SCS_ACMETH_EXT_COMPLETE
            sMethod = "Ext(comp)"
          Case #SCS_ACMETH_EXT_FADER
            sMethod = "ExtFader"
            If \nExtFaderCC <> grCueDef\nExtFaderCC
              sMethod + " cc " + \nExtFaderCC
            EndIf
            
          Case #SCS_ACMETH_MTC
            sMethod = "MTC " + decodeMTCTime(\nMTCStartTimeForCue)
          Case #SCS_ACMETH_LTC
            sMethod = "LTC " + decodeMTCTime(\nMTCStartTimeForCue)
            
          Case #SCS_ACMETH_OCM
            sMethod = "OCM "
            For n = 0 To gnMaxCueMarkerInfo
              If gaCueMarkerInfo(n)\bOCMAvailable
                If (gaCueMarkerInfo(n)\nHostCuePtr = \nAutoActCuePtr) And
                   (gaCueMarkerInfo(n)\nHostSubNo = \nAutoActSubNo) And
                   (gaCueMarkerInfo(n)\nHostAudNo= \nAutoActAudNo) And
                   (gaCueMarkerInfo(n)\sCueMarkerName = \sAutoActCueMarkerName)
                  sMethod + gaCueMarkerInfo(n)\sCueMarkerDisplayInfo
                  Break
                EndIf
              EndIf
            Next n
            
          Default
            sMethod = "$" + Hex(\nActivationMethod)
            
        EndSelect
      EndWith
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + #DQUOTE$ + sMethod + #DQUOTE$)
  ProcedureReturn sMethod
  
EndProcedure

Procedure.s getCueActivationMethodForTemplate(*rTmCue.tyTmCue)
  PROCNAMEC()
  Protected sMethod.s
  Static sCallableCue.s, sTimeBased.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sCallableCue = Lang("WEC", "acmCallQ")
    sTimeBased = Lang("WEC", "acmTime")
    bStaticLoaded = #True
  EndIf
  
      With *rTmCue
        Select \nActivationMethod
          Case #SCS_ACMETH_MAN
            sMethod = grText\sTextManual
            
          Case #SCS_ACMETH_MAN_PLUS_CONF
            sMethod = Lang("Common", "Manual+Conf")
            
          Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
            sMethod = timeToString(\nAutoActTime)
            ; debugMsg(sProcName, "\nAutoActTime=" + \nAutoActTime + ", sMethod=" + sMethod)
            Select \nAutoActPosn
              Case #SCS_ACPOSN_AS
                sMethod + " as "
              Case #SCS_ACPOSN_AE
                sMethod + " ae "
              Case #SCS_ACPOSN_BE
                sMethod + " be "
              Case #SCS_ACPOSN_LOAD
                sMethod + " aft.load"
            EndSelect
            If \nAutoActPosn <> #SCS_ACPOSN_LOAD
              If \nAutoActCueSelType = #SCS_ACCUESEL_PREV
                sMethod + "Prev"
              ElseIf \sAutoActCue
                sMethod + \sAutoActCue
              EndIf
              If \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
                sMethod + ",+C"
              EndIf
            EndIf
            
          Case #SCS_ACMETH_CALL_CUE
            sMethod = sCallableCue
            
          Case #SCS_ACMETH_HK_TRIGGER
            sMethod = "HKey(trig) " + \sHotkey
          Case #SCS_ACMETH_HK_TOGGLE
            sMethod = "HKey(togl) " + \sHotkey
          Case #SCS_ACMETH_HK_NOTE
            sMethod = "HKey(note) " + \sHotkey
          Case #SCS_ACMETH_HK_STEP
            sMethod = "HKey(step) " + \sHotkey
            
          Case #SCS_ACMETH_TIME
            sMethod = sTimeBased
            
          Case #SCS_ACMETH_EXT_TRIGGER
            sMethod = "Ext(trig)"
          Case #SCS_ACMETH_EXT_TOGGLE
            sMethod = "Ext(togl)"
          Case #SCS_ACMETH_EXT_NOTE
            sMethod = "Ext(note)"
          Case #SCS_ACMETH_EXT_STEP
            sMethod = "Ext(step)"
          Case #SCS_ACMETH_EXT_COMPLETE
            sMethod = "Ext(comp)"
          Case #SCS_ACMETH_EXT_FADER
            sMethod = "ExtFader"
            
          Case #SCS_ACMETH_MTC
            sMethod = "MTC " + decodeMTCTime(\nMTCStartTimeForCue)
          Case #SCS_ACMETH_LTC
            sMethod = "LTC " + decodeMTCTime(\nMTCStartTimeForCue)
            
          Default
            sMethod = "$" + Hex(\nActivationMethod)
            
        EndSelect
      EndWith
  
  ProcedureReturn sMethod
  
EndProcedure

Procedure encodeAutoActCueSelType(sAutoActCueSelType.s)
  Protected nAutoActCueSelType
  
  Select sAutoActCueSelType
    Case "prev"
      nAutoActCueSelType = #SCS_ACCUESEL_PREV
    Default
      nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT
  EndSelect
  ProcedureReturn nAutoActCueSelType
EndProcedure

Procedure.s decodeAutoActCueSelType(nAutoActCueSelType)
  Protected sAutoActCueSelType.s
  
  Select nAutoActCueSelType
    Case #SCS_ACCUESEL_PREV
      sAutoActCueSelType = "prev"
    Default
      sAutoActCueSelType = ""
  EndSelect
  ProcedureReturn sAutoActCueSelType
EndProcedure

Procedure.s decodeDriver(nDriver)
  Protected sDriver.s
  
  Select nDriver
    Case #SCS_DRV_BASS_DS
      sDriver = "BASS_DS"
    Case #SCS_DRV_BASS_WASAPI
      sDriver = "BASS_WASAPI"
    Case #SCS_DRV_BASS_ASIO
      sDriver = "BASS_ASIO"
    Case #SCS_DRV_SMS_ASIO
      sDriver = "SMS_ASIO"
    Case #SCS_DRV_TVG
      sDriver = "TVG"
  EndSelect
  ProcedureReturn sDriver
EndProcedure

Procedure.s decodeDriverL(nDriver, bShort=#False)
  ; PROCNAMEC()
  Protected sName.s, sDriver.s
  
;   If nDriver = #SCS_DRV_SMS_ASIO
;     sName = "SMS_ASIO_PRO"  ; nb no language entry for "SMS_ASIO", only "SMS_ASIO_PRO", as not necessary to have both
;   ElseIf (grLicInfo\nLicLevel >= #SCS_LIC_PRO) And (bShort = #False)
;     sName = decodeDriver(nDriver) + "_PRO"
;   Else
;     sName = decodeDriver(nDriver)
;   EndIf
  If nDriver = #SCS_DRV_BASS_DS
    sName = "BASS_DS"
  ElseIf nDriver = #SCS_DRV_BASS_WASAPI
    sName = "BASS_WASAPI"
  ElseIf (nDriver = #SCS_DRV_BASS_ASIO) And (grLicInfo\nLicLevel >= #SCS_LIC_PRO) And (bShort = #False)
    sName = "BASS_ASIO_PRO"
  Else
    sName = decodeDriver(nDriver)
  EndIf
  sDriver = Lang("AudioDriver", sName)
  ; debugMsg(sProcName, "grLicInfo\nLicLevel=" + grLicInfo\nLicLevel + ", sDriver=" + sDriver)
  ProcedureReturn sDriver
EndProcedure

Procedure encodeAudioDriver(sDriver.s)
  Protected nDriver
  
  Select sDriver
    Case "BASS_DS"
      nDriver = #SCS_DRV_BASS_DS
    Case "BASS_WASAPI"
      nDriver = #SCS_DRV_BASS_WASAPI
    Case "BASS_ASIO", "BASS_ASIO_PRO"
      nDriver = #SCS_DRV_BASS_ASIO
    Case "SMS_ASIO", "SMS_ASIO_PRO"
      nDriver = #SCS_DRV_SMS_ASIO
    Case "TVG"
      nDriver = #SCS_DRV_TVG
  EndSelect
  ProcedureReturn nDriver
EndProcedure

Procedure.s decodeDevGrp(nDevGrp)
  PROCNAMEC()
  Protected sDevGrp.s
  
  Select nDevGrp
    Case #SCS_DEVGRP_AUDIO_OUTPUT
      sDevGrp = "AudioOutput"
    Case #SCS_DEVGRP_VIDEO_AUDIO
      sDevGrp = "VideoAudio"
    Case #SCS_DEVGRP_VIDEO_CAPTURE
      sDevGrp = "VideoCapture"
    Case #SCS_DEVGRP_LIVE_INPUT
      sDevGrp = "LiveInput"
    Case #SCS_DEVGRP_LIGHTING
      sDevGrp = "Lighting"
    Case #SCS_DEVGRP_CTRL_SEND
      sDevGrp = "CtrlSend"
    Case #SCS_DEVGRP_CUE_CTRL
      sDevGrp = "CueCtrl"
    Case #SCS_DEVGRP_IN_GRP
      sDevGrp = "InGrp"
    Case #SCS_DEVGRP_IN_GRP_LIVE_INPUT
      sDevGrp = "InGrpLiveInput"
    Case #SCS_DEVGRP_FIX_TYPE
      sDevGrp = "FixType"
    Case #SCS_DEVGRP_EXT_CONTROLLER
      sDevGrp = "ExtController"
  EndSelect
  ProcedureReturn sDevGrp
EndProcedure

Procedure.s decodeDevGrpL(nDevGrp)
  PROCNAMEC()
  Protected sDevGrp.s
  
  If (nDevGrp >= #SCS_DEVGRP_FIRST) And (nDevGrp <= #SCS_DEVGRP_VERY_LAST)
    sDevGrp = grText\sTextDevGrp[nDevGrp]
  EndIf
  ProcedureReturn sDevGrp
EndProcedure

Procedure.s decodeDevType(nDevType)
  PROCNAMEC()
  Protected sDevType.s
  
  Select nDevType
    Case #SCS_DEVTYPE_AUDIO_OUTPUT
      sDevType = "AudioOut"
    Case #SCS_DEVTYPE_VIDEO_AUDIO
      sDevType = "VideoAudio"
    Case #SCS_DEVTYPE_VIDEO_CAPTURE
      sDevType = "VideoCapture"
    Case #SCS_DEVTYPE_MIDI_PLAYBACK
      sDevType = "MIDIPlayBack"
    Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_EXTCTRL_MIDI_IN ; Changed 25Jun2022 11.9.4
      sDevType = "MIDIIn"
    Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_EXTCTRL_MIDI_OUT ; Changed 25Jun2022 11.9.4
      sDevType = "MIDIOut"
    Case #SCS_DEVTYPE_CS_MIDI_THRU
      sDevType = "MIDIThru"
    Case #SCS_DEVTYPE_CC_RS232_IN
      sDevType = "RS232In"
    Case #SCS_DEVTYPE_CS_RS232_OUT
      sDevType = "RS232Out"
    Case #SCS_DEVTYPE_CC_DMX_IN
      sDevType = "DMXIn"
    Case #SCS_DEVTYPE_LT_DMX_OUT
      sDevType = "DMXOut"
    Case #SCS_DEVTYPE_CC_NETWORK_IN
      sDevType = "NetworkIn"
    Case #SCS_DEVTYPE_CS_NETWORK_OUT
      sDevType = "NetworkOut"
    Case #SCS_DEVTYPE_LIVE_INPUT
      sDevType = "LiveInput"
    Case #SCS_DEVTYPE_CS_HTTP_REQUEST
      sDevType = "HTTPRequest"
    Case #SCS_DEVTYPE_NONE
      sDevType = ""
  EndSelect
  ProcedureReturn sDevType
EndProcedure

Procedure.s decodeDevTypeL(nDevType)
  ProcedureReturn Lang("DevType", decodeDevType(nDevType))
EndProcedure

Procedure encodeDevType(sDevType.s)
  PROCNAMEC()
  Protected nDevType
  
  Select sDevType
    Case "AudioOut", "Sound"
      nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
    Case "VideoAudio"
      nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
    Case "VideoCapture"
      nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
    Case "MIDIPlayBack"
      nDevType = #SCS_DEVTYPE_MIDI_PLAYBACK
    Case "MIDIIn"
      nDevType = #SCS_DEVTYPE_CC_MIDI_IN
    Case "MIDIOut"
      nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
    Case "MIDIThru"
      nDevType = #SCS_DEVTYPE_CS_MIDI_THRU
    Case "RS232In"
      nDevType = #SCS_DEVTYPE_CC_RS232_IN
    Case "RS232Out"
      nDevType = #SCS_DEVTYPE_CS_RS232_OUT
    Case "DMXIn"
      nDevType = #SCS_DEVTYPE_CC_DMX_IN
    Case "DMXOut"
      nDevType = #SCS_DEVTYPE_LT_DMX_OUT
    Case "NetworkIn", "TelnetIn"
      nDevType = #SCS_DEVTYPE_CC_NETWORK_IN
    Case "NetworkOut", "TelnetOut"
      nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
    Case "LiveInput"
      nDevType = #SCS_DEVTYPE_LIVE_INPUT
    Case "HTTPRequest"
      nDevType = #SCS_DEVTYPE_CS_HTTP_REQUEST
    Case ""
      nDevType = #SCS_DEVTYPE_NONE
  EndSelect
  ProcedureReturn nDevType
EndProcedure

Procedure encodeDevGrp(sDevGrp.s)
  PROCNAMEC()
  Protected nDevGrp
  
  Select sDevGrp
    Case "AudioOutput"
      nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
    Case "VideoAudio"
      nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
    Case "VideoCapture"
      nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
    Case "LiveInput"
      nDevGrp = #SCS_DEVGRP_LIVE_INPUT
    Case "Lighting"
      nDevGrp = #SCS_DEVGRP_LIGHTING
    Case "CtrlSend"
      nDevGrp = #SCS_DEVGRP_CTRL_SEND
    Case "CueCtrl"
      nDevGrp = #SCS_DEVGRP_CUE_CTRL
  EndSelect
  ProcedureReturn nDevGrp
EndProcedure

Procedure.s decodeDevState(nDevState)
  PROCNAMEC()
  Protected sDevState.s
  
  Select nDevState
    Case #SCS_DEVSTATE_NA
      sDevState = ""
    Case #SCS_DEVSTATE_ACTIVE
      sDevState = "Active"
    Case #SCS_DEVSTATE_INACTIVE
      sDevState = "Inactive"
  EndSelect
  ProcedureReturn sDevState
EndProcedure

Procedure.s decodeDriveType(nDriveType)
  Protected sDriveType.s
  
  ; see Microsoft function GetDriveType for list of values
  Select nDriveType
    Case #DRIVE_UNKNOWN         ; The drive type cannot be determined.
      sDriveType = "Unknown"
    Case #DRIVE_NO_ROOT_DIR     ; The root path is invalid; for example, there is no volume mounted at the specified path.
      sDriveType = "Invalid"
    Case #DRIVE_REMOVABLE       ; The drive has removable media; for example, a floppy drive, thumb drive, or flash card reader.
      sDriveType = "Removable"
    Case #DRIVE_FIXED           ; The drive has fixed media; for example, a hard disk drive or flash drive.
      sDriveType = "Fixed"
    Case #DRIVE_REMOTE          ; The drive is a remote (network) drive.
      sDriveType = "Remote"
    Case #DRIVE_CDROM           ; The drive is a CD-ROM drive.
      sDriveType = "CD-ROM"
    Case #DRIVE_RAMDISK         ; The drive is a RAM disk.
      sDriveType = "RAM"
    Default
      sDriveType = Str(nDriveType)
  EndSelect
  ProcedureReturn sDriveType
EndProcedure

Procedure.s decodeDriveTypeL(nDriveType)
  ProcedureReturn Lang("DriveType", decodeDriveType(nDriveType))
EndProcedure

Procedure encodeHideCueOpt(sHideCueOpt.s)
  Protected nHideCueOpt
  
  Select sHideCueOpt
    Case "EC"
      nHideCueOpt = #SCS_HIDE_ENTIRE_CUE
    Case "CP"
      nHideCueOpt = #SCS_HIDE_CUE_PANEL
    Default
      nHideCueOpt = #SCS_HIDE_NO
  EndSelect
  ProcedureReturn nHideCueOpt
EndProcedure

Procedure.s decodeHideCueOpt(nHideCueOpt)
  Protected sHideCueOpt.s
  
  Select nHideCueOpt
    Case #SCS_HIDE_ENTIRE_CUE
      sHideCueOpt = "EC"
    Case #SCS_HIDE_CUE_PANEL
      sHideCueOpt = "CP"
    Default
      sHideCueOpt = ""
  EndSelect
  ProcedureReturn sHideCueOpt
EndProcedure

Procedure.s decodeHideCueOptL(nHideCueOpt)
  Protected sHideCueOpt.s
  
  Select nHideCueOpt
    Case #SCS_HIDE_NO
      sHideCueOpt = Lang("HideCueOpt", "NO")
    Case #SCS_HIDE_ENTIRE_CUE
      sHideCueOpt = Lang("HideCueOpt", "EC")
    Case #SCS_HIDE_CUE_PANEL
      sHideCueOpt = Lang("HideCueOpt", "CP")
    Default
      sHideCueOpt = Lang("HideCueOpt", "NO")
  EndSelect
  ProcedureReturn sHideCueOpt
EndProcedure

Procedure encodeMonitorSize(sMonitorSize.s)
  PROCNAMEC()
  Protected nMonitorSize
  
  Select sMonitorSize
    Case "None"
      nMonitorSize = #SCS_MON_NONE
    Case "Small"
      nMonitorSize = #SCS_MON_SMALL
    Case "Std"
      nMonitorSize = #SCS_MON_STD
    Case "Large"
      nMonitorSize = #SCS_MON_LARGE
    Default
      nMonitorSize = #SCS_MON_STD
  EndSelect
  ProcedureReturn nMonitorSize
EndProcedure

Procedure.s decodeMonitorSize(nMonitorSize)
  PROCNAMEC()
  Protected sMonitorSize.s
  
  Select nMonitorSize
    Case #SCS_MON_NONE
      sMonitorSize = "None"
    Case #SCS_MON_SMALL
      sMonitorSize = "Small"
    Case #SCS_MON_STD
      sMonitorSize = "Std"
    Case #SCS_MON_LARGE
      sMonitorSize = "Large"
    Default
      sMonitorSize = "Std"
  EndSelect
  ProcedureReturn sMonitorSize
EndProcedure

Procedure.s decodeMonitorSizeL(nMonitorSize)
  ProcedureReturn Lang("MonitorSize", decodeMonitorSize(nMonitorSize))
EndProcedure

Procedure.s decodeFlip(nFlip)
  Protected sFlip.s
  
  If (nFlip & #SCS_FLIPH)
    sFlip + "H"
  EndIf
  If (nFlip & #SCS_FLIPV)
    sFlip + "V"
  EndIf
  ProcedureReturn sFlip
EndProcedure

Procedure encodeFlip(sFlip.s)
  Protected nFlip
  
  If FindString(sFlip, "H")
    nFlip | #SCS_FLIPH
  EndIf
  If FindString(sFlip, "V")
    nFlip | #SCS_FLIPV
  EndIf
  ProcedureReturn nFlip
EndProcedure

Procedure.s decodeLostFocusAction(nLostFocusAction)
  Protected sLostFocusAction.s
  Select nLostFocusAction
    Case #SCS_LOSTFOCUS_IGNORE
      sLostFocusAction = "Ignore"
    Case #SCS_LOSTFOCUS_WARN
      sLostFocusAction = "Warn"
    Default
      sLostFocusAction = "Warn"
  EndSelect
  ProcedureReturn sLostFocusAction
EndProcedure

Procedure.s decodeLostFocusActionL(nLostFocusAction)
  ProcedureReturn Lang("LFA", decodeLostFocusAction(nLostFocusAction))
EndProcedure

Procedure encodeLostFocusAction(sLostFocusAction.s)
  Protected nLostFocusAction
  Select sLostFocusAction
    Case "Ignore"
      nLostFocusAction = #SCS_LOSTFOCUS_IGNORE
    Case "Warn "
      nLostFocusAction = #SCS_LOSTFOCUS_WARN
    Default
      nLostFocusAction = #SCS_LOSTFOCUS_WARN
  EndSelect
  ProcedureReturn nLostFocusAction
EndProcedure

Procedure encodeMTCDispLocn(sMTCDispLocn.s)
  Protected nMTCDispLocn
  Select sMTCDispLocn
    Case "Meters"
      nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
    Case "Window"
      nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
    Default
      nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
  EndSelect
  ProcedureReturn nMTCDispLocn
EndProcedure

Procedure.s decodeMTCDispLocn(nMTCDispLocn)
  Protected sMTCDispLocn.s
  Select nMTCDispLocn
    Case #SCS_MTC_DISP_VU_METERS
      sMTCDispLocn = "Meters"
    Case #SCS_MTC_DISP_SEPARATE_WINDOW
      sMTCDispLocn = "Window"
    Default
      sMTCDispLocn = "Meters"
  EndSelect
  ProcedureReturn sMTCDispLocn
EndProcedure

Procedure.s decodeMTCDispLocnL(nMTCDispLocn)
  ProcedureReturn Lang("MTCDispLocn", decodeMTCDispLocn(nMTCDispLocn))
EndProcedure

Procedure encodeTimerDispLocn(sTimerDispLocn.s)
  Protected nTimerDispLocn
  Select sTimerDispLocn
    Case "Status"
      nTimerDispLocn = #SCS_PTD_STATUS_LINE
    Case "Window"
      nTimerDispLocn = #SCS_PTD_SEPARATE_WINDOW
    Default
      nTimerDispLocn = #SCS_PTD_STATUS_LINE
  EndSelect
  ProcedureReturn nTimerDispLocn
EndProcedure

Procedure.s decodeTimerDispLocn(nTimerDispLocn)
  Protected sTimerDispLocn.s
  Select nTimerDispLocn
    Case #SCS_PTD_SEPARATE_WINDOW
      sTimerDispLocn = "Window"
    Default
      sTimerDispLocn = "Status"
  EndSelect
  ProcedureReturn sTimerDispLocn
EndProcedure

Procedure.s decodeTimerDispLocnL(nTimerDispLocn)
  ProcedureReturn Lang("TimerDispLocn", decodeTimerDispLocn(nTimerDispLocn))
EndProcedure

Procedure.s getTypeForColIndex(nGridType, nColIndex)
  Protected sColType.s
  
  Select nGridType
    Case #SCS_GT_GRDCUES  ; #SCS_GT_GRDCUES
      Select nColIndex
        Case #SCS_GRDCUES_CU   ; Cue
          sColType = "CU"
        Case #SCS_GRDCUES_DE   ; Description
          sColType = "DE"
        Case #SCS_GRDCUES_CT   ; Cue Type
          sColType = "CT"
        Case #SCS_GRDCUES_CS   ; Cue State
          sColType = "CS"
        Case #SCS_GRDCUES_AC   ; Activation
          sColType = "AC"
        Case #SCS_GRDCUES_FN   ; File / Info
          sColType = "FN"
        Case #SCS_GRDCUES_DU   ; Length (Duration)
          sColType = "DU"
        Case #SCS_GRDCUES_SD   ; Device
          sColType = "SD"
        Case #SCS_GRDCUES_WR   ; When Required
          sColType = "WR"
        Case #SCS_GRDCUES_MC   ; MIDI Cue Case #
          sColType = "MC"
        Case #SCS_GRDCUES_FT   ; File Type
          sColType = "FT"
        Case #SCS_GRDCUES_PG   ; Page
          sColType = "PG"
      EndSelect
      
    Case #SCS_GT_GRDCUEPRINT  ; #SCS_GT_GRDCUEPRINT
      Select nColIndex
        Case #SCS_GRDCUEPRINT_CU   ; Cue
          sColType = "CU"
        Case #SCS_GRDCUEPRINT_DE   ; Description
          sColType = "DE"
        Case #SCS_GRDCUEPRINT_CT   ; Cue Type
          sColType = "CT"
        Case #SCS_GRDCUEPRINT_AC   ; Activation
          sColType = "AC"
        Case #SCS_GRDCUEPRINT_FN   ; File / Info
          sColType = "FN"
        Case #SCS_GRDCUEPRINT_DU   ; Length (Duration)
          sColType = "DU"
        Case #SCS_GRDCUEPRINT_SD   ; Device
          sColType = "SD"
        Case #SCS_GRDCUEPRINT_WR   ; When Required
          sColType = "WR"
        Case #SCS_GRDCUEPRINT_MC   ; MIDI Cue Case #
          sColType = "MC"
        Case #SCS_GRDCUEPRINT_FT   ; File Type
          sColType = "FT"
        Case #SCS_GRDCUEPRINT_PG   ; Page
          sColType = "PG"
      EndSelect
      
  EndSelect
  ProcedureReturn sColType
  
EndProcedure

Procedure getIndexForColType(nGridType, sColType.s)
  Protected nColIndex
  
  nColIndex = -1
  Select nGridType
    Case #SCS_GT_GRDCUES  ; #SCS_GT_GRDCUES
      Select sColType
        Case "CU"
          nColIndex = #SCS_GRDCUES_CU   ; Cue
        Case "DE"
          nColIndex = #SCS_GRDCUES_DE   ; Description
        Case "CT"
          nColIndex = #SCS_GRDCUES_CT   ; Cue Type
        Case "CS"
          nColIndex = #SCS_GRDCUES_CS   ; Cue State
        Case "AC"
          nColIndex = #SCS_GRDCUES_AC   ; Activation
        Case "FN"
          nColIndex = #SCS_GRDCUES_FN   ; File / Info
        Case "DU"
          nColIndex = #SCS_GRDCUES_DU   ; Length (Duration)
        Case "SD"
          nColIndex = #SCS_GRDCUES_SD   ; Device
        Case "WR"
          nColIndex = #SCS_GRDCUES_WR   ; When Required
        Case "MC"
          nColIndex = #SCS_GRDCUES_MC   ; MIDI Cue nColIndex = #
        Case "FT"
          nColIndex = #SCS_GRDCUES_FT   ; File Type
        Case "PG"
          nColIndex = #SCS_GRDCUES_PG   ; Page
        Case "LV"
          nColIndex = #SCS_GRDCUES_LV   ; Level (dB)
      EndSelect
      
    Case #SCS_GT_GRDCUEPRINT  ; #SCS_GT_GRDCUEPRINT
      Select sColType
        Case "CU"
          nColIndex = #SCS_GRDCUEPRINT_CU   ; Cue
        Case "DE"
          nColIndex = #SCS_GRDCUEPRINT_DE   ; Description
        Case "CT"
          nColIndex = #SCS_GRDCUEPRINT_CT   ; Cue Type
        Case "AC"
          nColIndex = #SCS_GRDCUEPRINT_AC   ; Activation
        Case "FN"
          nColIndex = #SCS_GRDCUEPRINT_FN   ; File / Info
        Case "DU"
          nColIndex = #SCS_GRDCUEPRINT_DU   ; Length (Duration)
        Case "SD"
          nColIndex = #SCS_GRDCUEPRINT_SD   ; Device
        Case "WR"
          nColIndex = #SCS_GRDCUEPRINT_WR   ; When Required
        Case "MC"
          nColIndex = #SCS_GRDCUEPRINT_MC   ; MIDI Cue nColIndex = #
        Case "FT"
          nColIndex = #SCS_GRDCUEPRINT_FT   ; File Type
        Case "PG"
          nColIndex = #SCS_GRDCUEPRINT_PG   ; Page
        Case "LV"
          nColIndex = #SCS_GRDCUEPRINT_LV   ; Level (dB)
      EndSelect
      
    Case #SCS_GT_EXPWFO   ; #SCS_GT_EXPWFO
      Select sColType
        Case "NM"
          nColIndex = #SCS_WFOLIST_NM   ; Name
        Case "SZ"
          nColIndex = #SCS_WFOLIST_SZ   ; Size
        Case "TY"
          nColIndex = #SCS_WFOLIST_TY   ; Type
        Case "DM"
          nColIndex = #SCS_WFOLIST_DM   ; Date Modified
        Case "LN"
          nColIndex = #SCS_WFOLIST_LN   ; Length
        Case "TI"
          nColIndex = #SCS_WFOLIST_TI   ; Title
      EndSelect
      
  EndSelect
  ProcedureReturn nColIndex
  
EndProcedure

Procedure.s decodeMSCCommand(pCommand)
  PROCNAMEC()
  Protected sDecoded.s
  
  Select pCommand
    Case $1
      sDecoded = "Go"
    Case $2
      sDecoded = "Stop"
    Case $3
      sDecoded = "Resume"
    Case $4
      sDecoded = "Timed Go"
    Case $5
      sDecoded = "Load"
    Case $6
      sDecoded = "Set"
    Case $7
      sDecoded = "Fire"
    Case $8
      sDecoded = "All Off"
    Case $9
      sDecoded = "Restore"
    Case $A
      sDecoded = "Reset"
    Case $B
      sDecoded = "Go Off"
    Case $10
      sDecoded = "Go/Jam Clock"
    Case $11
      sDecoded = "StandBy +"
    Case $12
      sDecoded = "StandBy -"
    Case $13
      sDecoded = "Sequence +"
    Case $14
      sDecoded = "Sequence -"
    Case $15
      sDecoded = "Start Clock"
    Case $16
      sDecoded = "Stop Clock"
    Case $17
      sDecoded = "Zero Clock"
    Case $18
      sDecoded = "Set Clock"
    Case $19
      sDecoded = "MTC Chase On"
    Case $1A
      sDecoded = "MTC Chase Off"
    Case $1B
      sDecoded = "Open Cue List"
    Case $1C
      sDecoded = "Close Cue List"
    Case $1D
      sDecoded = "Open Cue Path"
    Case $1E
      sDecoded = "Close Cue Path"
    Default
      sDecoded = Trim(Str(pCommand))
  EndSelect
  ProcedureReturn sDecoded
EndProcedure

Procedure.s decodeCueState(pCueState, bLiveInput=#False)
  PROCNAMEC()
  ; no language translation required - to be used for debug messages etc only. Use decodeCueStateL() for language translated values.
  Protected sCueState.s
  
  Select pCueState
    Case #SCS_CUE_NOT_LOADED
      sCueState = "Not Loaded"
    Case #SCS_CUE_READY
      sCueState = "Ready"
    Case #SCS_CUE_COUNTDOWN_TO_START
      sCueState = "Countdown to Start"
    Case #SCS_CUE_SUB_COUNTDOWN_TO_START
      sCueState = "Countdown to Start.."
    Case #SCS_CUE_PL_COUNTDOWN_TO_START
      sCueState = "Countdown to Start."
    Case #SCS_CUE_WAITING_FOR_CONFIRM
      sCueState = "Waiting for Ext"
    Case #SCS_CUE_FADING_IN
      sCueState = "Fading In"
    Case #SCS_CUE_TRANS_FADING_IN
      sCueState = "Transition(S)"
    Case #SCS_CUE_PLAYING
      If bLiveInput
        sCueState = "Live"
      Else
        sCueState = "Playing"
      EndIf
    Case #SCS_CUE_CHANGING_LEVEL
      sCueState = "Changing Level"
    Case #SCS_CUE_RELEASING
      sCueState = "Releasing"
    Case #SCS_CUE_STOPPING
      sCueState = "Stopping"
    Case #SCS_CUE_TRANS_MIXING_OUT
      sCueState = "Transition(M)"
    Case #SCS_CUE_TRANS_FADING_OUT
      sCueState = "Transition(E)"
    Case #SCS_CUE_PAUSED
      sCueState = "Paused"
    Case #SCS_CUE_HIBERNATING
      sCueState = "Hibernating"
    Case #SCS_CUE_FADING_OUT
      sCueState = "Fading Out"
    Case #SCS_CUE_PL_READY
      sCueState = "Ready."
    Case #SCS_CUE_STANDBY
      sCueState = "Standby"
    Case #SCS_CUE_COMPLETED
      sCueState = "Completed"
    Case #SCS_CUE_ERROR
      sCueState = "Error !"
    Case #SCS_CUE_IGNORED
      sCueState = "Ignored"
    Case #SCS_CUE_STATE_NOT_SET
      sCueState = "State Not Set"
    Default
      sCueState = Str(pCueState)
  EndSelect
  ProcedureReturn sCueState
EndProcedure

Procedure.s decodeCueStateL(nCueState, bLiveInput=#False)
  PROCNAMEC()
  
  If nCueState <= #SCS_LAST_CUE_STATE
    If bLiveInput And nCueState = #SCS_CUE_PLAYING
      ProcedureReturn grText\sTextLive
    Else
      ProcedureReturn grText\sTextCueState[nCueState]
    EndIf
  Else
    ; shouldn't happen
    ProcedureReturn Str(nCueState)
  EndIf
EndProcedure

Procedure getCueStateForDisplayEtc(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, nCueState, nSubState
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      nCueState = \nCueState
      If nCueState = #SCS_CUE_SUB_COUNTDOWN_TO_START
        ; check to see if any sub is playing, and if so then set that as the cue state for the grid
        j = \nFirstSubIndex
        While j >= 0
          nSubState = aSub(j)\nSubState
          If (nSubState = #SCS_CUE_FADING_IN) And (nCueState = #SCS_CUE_SUB_COUNTDOWN_TO_START)
            ; first 'playing' sub is fading in, so set this as  the state unless it subsequently gets overridden by a higher playing state
            nCueState = #SCS_CUE_FADING_IN
          ElseIf (nSubState > #SCS_CUE_FADING_IN) And (nSubState <= #SCS_CUE_FADING_OUT)
            nCueState = #SCS_CUE_PLAYING
            Break
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      ; debugMsg(sProcName, "\nCueState=" + decodeCueState(\nCueState) + ", sGridCueState=" + sGridCueState)
    EndWith
  EndIf
  ProcedureReturn nCueState
EndProcedure

Procedure.s getCueStateForGrid(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected sGridCueState.s
  Protected bNextManualCue
  Protected nCueState
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      nCueState = getCueStateForDisplayEtc(pCuePtr)
      If nCueState <= #SCS_LAST_CUE_STATE
        If (\bLiveInput) And (nCueState = #SCS_CUE_PLAYING)
          sGridCueState = grText\sTextLive
        Else
          If (pCuePtr >= 0) And (pCuePtr = gnCueToGo)
            If nCueState = #SCS_CUE_READY
              bNextManualCue = #True
            EndIf
          EndIf
          If bNextManualCue
            sGridCueState = grText\sTextNextManual
          Else
            sGridCueState = gaCueStateForGrid(nCueState)
          EndIf
        EndIf
      Else
        ; shouldn't happen
        sGridCueState = Str(\nCueState)
      EndIf
      ; debugMsg(sProcName, "\nCueState=" + decodeCueState(\nCueState) + ", sGridCueState=" + sGridCueState)
    EndWith
  EndIf
  ProcedureReturn sGridCueState
EndProcedure

Procedure.s decodeProdTimerAction(nProdTimerAction)
  PROCNAMEC()
  Protected sProdTimerAction.s
  Select nProdTimerAction
    Case #SCS_PTA_START_S
      sProdTimerAction = "Start_S"
    Case #SCS_PTA_PAUSE_S
      sProdTimerAction = "Pause_S"
    Case #SCS_PTA_RESUME_S
      sProdTimerAction = "Resume_S"
    Case #SCS_PTA_START_E
      sProdTimerAction = "Start_E"
    Case #SCS_PTA_PAUSE_E
      sProdTimerAction = "Pause_E"
    Case #SCS_PTA_RESUME_E
      sProdTimerAction = "Resume_E"
    CompilerIf #c_prod_timer_extra_actions
      Case #SCS_PTA_SHOW_TIMER
        sProdTimerAction = "Show_Timer"
      Case #SCS_PTA_HIDE_TIMER
        sProdTimerAction = "Hide_Timer"
      Case #SCS_PTA_SHOW_CLOCK
        sProdTimerAction = "Show_Clock"
      Case #SCS_PTA_HIDE_CLOCK
        sProdTimerAction = "Hide_Clock"
    CompilerEndIf
    Default
      sProdTimerAction = ""
  EndSelect
  ProcedureReturn sProdTimerAction
EndProcedure

Procedure.s decodeProdTimerActionL(nProdTimerAction)
  Protected sProdTimerAction.s
  If nProdTimerAction = #SCS_PTA_NO_ACTION
    sProdTimerAction = ""
  Else
    sProdTimerAction = Lang("PTA", decodeProdTimerAction(nProdTimerAction))
  EndIf
  ProcedureReturn sProdTimerAction
EndProcedure

Procedure.s decodeProdTimerActionAbbr(nProdTimerAction)
  PROCNAMEC()
  Protected sProdTimerAction.s
  Select nProdTimerAction
    Case #SCS_PTA_START_S
      sProdTimerAction = "(TS)"
    Case #SCS_PTA_PAUSE_S
      sProdTimerAction = "(TP)"
    Case #SCS_PTA_RESUME_S
      sProdTimerAction = "(TR)"
    Case #SCS_PTA_START_E
      sProdTimerAction = "(TSe)"
    Case #SCS_PTA_PAUSE_E
      sProdTimerAction = "(TPe)"
    Case #SCS_PTA_RESUME_E
      sProdTimerAction = "(TRe)"
    CompilerIf #c_prod_timer_extra_actions
      Case #SCS_PTA_SHOW_TIMER
        sProdTimerAction = "(TShow)"
      Case #SCS_PTA_HIDE_TIMER
        sProdTimerAction = "(THide)"
      Case #SCS_PTA_SHOW_CLOCK
        sProdTimerAction = "(Clock)"
      Case #SCS_PTA_HIDE_CLOCK
        sProdTimerAction = "(NoClock)"
    CompilerEndIf
    Default
      sProdTimerAction = ""
  EndSelect
  ProcedureReturn sProdTimerAction
EndProcedure

Procedure encodeProdTimerAction(sProdTimerAction.s)
  PROCNAMEC()
  Protected nProdTimerAction
  Select sProdTimerAction
    Case "Start_S"
      nProdTimerAction = #SCS_PTA_START_S
    Case "Pause_S"
      nProdTimerAction = #SCS_PTA_PAUSE_S
    Case "Resume_S"
      nProdTimerAction = #SCS_PTA_RESUME_S
    Case "Start_E"
      nProdTimerAction = #SCS_PTA_START_E
    Case "Pause_E"
      nProdTimerAction = #SCS_PTA_PAUSE_E
    Case "Resume_E"
      nProdTimerAction = #SCS_PTA_RESUME_E
    CompilerIf #c_prod_timer_extra_actions
      Case "Show_Timer"
        nProdTimerAction = #SCS_PTA_SHOW_TIMER
      Case "Hide_Timer"
        nProdTimerAction = #SCS_PTA_HIDE_TIMER
      Case "Show_Clock"
        nProdTimerAction = #SCS_PTA_SHOW_CLOCK
      Case "Hide_Clock"
        nProdTimerAction = #SCS_PTA_HIDE_CLOCK
    CompilerEndIf
    Default
      nProdTimerAction = #SCS_PTA_NO_ACTION
  EndSelect
  ProcedureReturn nProdTimerAction
EndProcedure

Procedure.s decodeProdTimerHistAction(nHistAction)
  Protected sHistAction.s
  Select nHistAction
    Case #SCS_PTHA_STARTED
      sHistAction = "Started"
    Case #SCS_PTHA_PAUSED
      sHistAction = "Paused"
    Case #SCS_PTHA_RESUMED
      sHistAction = "Resumed"
  EndSelect
  ProcedureReturn sHistAction
EndProcedure

Procedure.s decodeProdTimerHistActionL(nHistAction)
  ProcedureReturn Lang("PTA", decodeProdTimerHistAction(nHistAction))
EndProcedure

Procedure.s decodeSubStart(nSubStart)
  Protected sSubStart.s
  
  Select nSubStart
    Case #SCS_SUBSTART_REL_TIME
      sSubStart = ""
    Case #SCS_SUBSTART_REL_MTC
      sSubStart = "Rel_MTC"
    Case #SCS_SUBSTART_OCM
      sSubStart = "OCM"
    Default
      sSubStart = ""
  EndSelect
  ProcedureReturn sSubStart
EndProcedure

Procedure.s decodeSubStartL(nSubStart)
  Protected sSubStart.s
  Static sRelStart.s, sRelMTC.s, sOCM.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sRelStart = Lang("Common", "RelativeStart")
    sRelMTC = Lang("Common", "RelativeMTC")
    sOCM = Lang("Common", "OCM")
    bStaticLoaded = #True
  EndIf
  
  Select nSubStart
    Case #SCS_SUBSTART_REL_TIME
      sSubStart = sRelStart
    Case #SCS_SUBSTART_REL_MTC
      sSubStart = sRelMTC
    Case #SCS_SUBSTART_OCM
      sSubStart = sOCM
  EndSelect
  ProcedureReturn sSubStart
EndProcedure

Procedure encodeSubStart(sSubStart.s)
  Protected nSubStart
  
  Select sSubStart
    Case "Rel_MTC"
      nSubStart = #SCS_SUBSTART_REL_MTC
    Case "OCM"
      nSubStart = #SCS_SUBSTART_OCM
    Default
      nSubStart = #SCS_SUBSTART_REL_TIME
  EndSelect
  ProcedureReturn nSubStart
EndProcedure

Procedure.s decodeRelStartMode(nRelStartMode)
  PROCNAMEC()
  Protected sRelStartMode.s
  
  Select nRelStartMode
    Case #SCS_RELSTART_DEFAULT
      sRelStartMode = ""
    Case #SCS_RELSTART_AS_CUE
      sRelStartMode = "as_cue"
    Case #SCS_RELSTART_AS_PREV_SUB
      sRelStartMode = "as_prev_sub"
    Case #SCS_RELSTART_AE_PREV_SUB
      sRelStartMode = "ae_prev_sub"
    Case #SCS_RELSTART_BE_PREV_SUB
      sRelStartMode = "be_prev_sub"
  EndSelect
  ProcedureReturn sRelStartMode
EndProcedure

Procedure encodeRelStartMode(sRelStartMode.s)
  PROCNAMEC()
  Protected nRelStartMode
  
  Select sRelStartMode
    Case ""
      nRelStartMode = #SCS_RELSTART_DEFAULT
    Case "as_cue"
      nRelStartMode = #SCS_RELSTART_AS_CUE
    Case "as_prev_sub"
      nRelStartMode = #SCS_RELSTART_AS_PREV_SUB
    Case "ae_prev_sub"
      nRelStartMode = #SCS_RELSTART_AE_PREV_SUB
    Case "be_prev_sub"
      nRelStartMode = #SCS_RELSTART_BE_PREV_SUB
  EndSelect
  ProcedureReturn nRelStartMode
EndProcedure

Procedure.s decodeRemCmd(nRemCmd, p1.s="")
  Protected sRemCmd.s
  
  Select nRemCmd
    Case #SCS_OSCINP_CTRL_GO
      sRemCmd = "GoButton"
    Case #SCS_OSCINP_CTRL_GO_CONFIRM
      sRemCmd = "GoConfirm"
    Case #SCS_OSCINP_CTRL_STOP_ALL
      sRemCmd = "StopAll"
    Case #SCS_OSCINP_CTRL_PAUSE_RESUME_ALL
      sRemCmd = "PauseResumeAll"
    Case #SCS_OSCINP_CTRL_STOP_MTC
      sRemCmd = "StopMTC"
    Case #SCS_OSCINP_CTRL_GO_TO_TOP
      sRemCmd = "GoToTop"
    Case #SCS_OSCINP_CTRL_GO_BACK
      sRemCmd = "GoBack"
    Case #SCS_OSCINP_CTRL_GO_TO_NEXT
      sRemCmd = "GoToNext"
    Case #SCS_OSCINP_CTRL_GO_TO_END
      sRemCmd = "GoToEnd"
      
    Case #SCS_OSCINP_CTRL_GO_TO_CUE
      sRemCmd = "GoToCue " + p1
    Case #SCS_OSCINP_CUE_PLAY
      sRemCmd = "PlayCue " + p1
    Case #SCS_OSCINP_CUE_STOP
      sRemCmd = "StopCue " + p1
    Case #SCS_OSCINP_CUE_PAUSE_RESUME
      sRemCmd = "PauseResumeCue " + p1
      
    Case #SCS_OSCINP_HKEY_GO
      sRemCmd = "HkeyGo " + p1
    Case #SCS_OSCINP_HKEY_ON
      sRemCmd = "HkeyOn " + p1
    Case #SCS_OSCINP_HKEY_OFF
      sRemCmd = "HkeyOff " + p1

    Case #SCS_OSCINP_CUE_GET_POS
      sRemCmd = "GetCuePos " + p1
    Case #SCS_OSCINP_CUE_SET_POS
      sRemCmd = "SetCuePos " + p1
    Case #SCS_OSCINP_CUE_GET_LENGTH
      sRemCmd = "GetCueLength " + p1
    Case #SCS_OSCINP_CUE_GET_NAME
      sRemCmd = "GetCueName " + p1
    Case #SCS_OSCINP_CUE_GET_PAGE
      sRemCmd = "GetCuePage " + p1
    Case #SCS_OSCINP_CUE_GET_WHEN_REQD
      sRemCmd = "GetCueWhenRqed " + p1
    Case #SCS_OSCINP_CUE_GET_TYPE
      sRemCmd = "GetCueType " + p1
      
    Case #SCS_OSCINP_FADER_GET_MASTER, #SCS_OSCINP_FADER_GET_MASTER_PERCENT
      sRemCmd = "GetMasterFader"
    Case #SCS_OSCINP_FADER_SET_MASTER, #SCS_OSCINP_FADER_SET_MASTER_PERCENT, #SCS_OSCINP_FADER_SET_MASTER_RELATIVE
      sRemCmd = "SetMasterFader"
      
    Case #SCS_OSCINP_FADER_GET_DEVICE, #SCS_OSCINP_FADER_GET_DEVICE_PERCENT
      sRemCmd = "GetDeviceFader"
    Case #SCS_OSCINP_FADER_SET_DEVICE, #SCS_OSCINP_FADER_SET_DEVICE_PERCENT, #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
      sRemCmd = "SetDeviceFader"
      
    Case #SCS_OSCINP_IGNORE
      sRemCmd = "<ignore>"
      
    Default
      sRemCmd = Str(nRemCmd)
      
  EndSelect
  
  ProcedureReturn Trim(sRemCmd)

EndProcedure

Procedure.s decodeRemCmdL(nRemCmd, p1.s="")
  Protected sRemCmd.s
  
  Select nRemCmd
    Case #SCS_OSCINP_CTRL_GO
      sRemCmd = Lang("Remote", "GoButton")
    Case #SCS_OSCINP_CTRL_GO_CONFIRM
      sRemCmd = Lang("Remote", "GoConfirm")
    Case #SCS_OSCINP_CTRL_STOP_ALL
      sRemCmd = Lang("Remote", "StopAll")
    Case #SCS_OSCINP_CTRL_PAUSE_RESUME_ALL
      sRemCmd = Lang("Remote", "PauseResumeAll")
    Case #SCS_OSCINP_CTRL_STOP_MTC
      sRemCmd = Lang("Remote", "StopMTC")
    Case #SCS_OSCINP_CTRL_GO_TO_TOP
      sRemCmd = Lang("Remote", "GoToTop")
    Case #SCS_OSCINP_CTRL_GO_BACK
      sRemCmd = Lang("Remote", "GoBack")
    Case #SCS_OSCINP_CTRL_GO_TO_NEXT
      sRemCmd = Lang("Remote", "GoToNext")
    Case #SCS_OSCINP_CTRL_GO_TO_END
      sRemCmd = Lang("Remote", "GoToEnd")
      
    Case #SCS_OSCINP_CTRL_GO_TO_CUE
      sRemCmd = LangPars("Remote", "GoToCue", p1)
    Case #SCS_OSCINP_CUE_PLAY
      sRemCmd = LangPars("Remote", "PlayCue", p1)
    Case #SCS_OSCINP_CUE_STOP
      sRemCmd = LangPars("Remote", "StopCue", p1)
    Case #SCS_OSCINP_CUE_PAUSE_RESUME
      sRemCmd = LangPars("Remote", "PauseResumeCue", p1)
      
    Case #SCS_OSCINP_HKEY_GO
      sRemCmd = LangPars("Remote", "HkeyGo", p1)
    Case #SCS_OSCINP_HKEY_ON
      sRemCmd = LangPars("Remote", "HkeyOn", p1)
    Case #SCS_OSCINP_HKEY_OFF
      sRemCmd = LangPars("Remote", "HkeyOff", p1)

    Case #SCS_OSCINP_CUE_GET_POS
      sRemCmd = LangPars("Remote", "GetCuePos", p1)
    Case #SCS_OSCINP_CUE_SET_POS
      sRemCmd = LangPars("Remote", "SetCuePos", p1)
    Case #SCS_OSCINP_CUE_GET_LENGTH
      sRemCmd = LangPars("Remote", "GetCueLength", p1)
    Case #SCS_OSCINP_CUE_GET_NAME
      sRemCmd = LangPars("Remote", "GetCueName", p1)
    Case #SCS_OSCINP_CUE_GET_PAGE
      sRemCmd = LangPars("Remote", "GetCuePage", p1)
    Case #SCS_OSCINP_CUE_GET_WHEN_REQD
      sRemCmd = LangPars("Remote", "GetCueWhenReqd", p1)
    Case #SCS_OSCINP_CUE_GET_TYPE
      sRemCmd = LangPars("Remote", "GetCueType", p1)
      
    Case #SCS_OSCINP_FADER_GET_MASTER, #SCS_OSCINP_FADER_GET_MASTER_PERCENT
      sRemCmd = Lang("Remote", "GetMasterFader")
    Case #SCS_OSCINP_FADER_SET_MASTER, #SCS_OSCINP_FADER_SET_MASTER_PERCENT, #SCS_OSCINP_FADER_SET_MASTER_RELATIVE
      sRemCmd = Lang("Remote", "SetMasterFader")
      
    Case #SCS_OSCINP_FADER_GET_DEVICE, #SCS_OSCINP_FADER_GET_DEVICE_PERCENT
      sRemCmd = Lang("Remote", "GetDeviceFader")
    Case #SCS_OSCINP_FADER_SET_DEVICE, #SCS_OSCINP_FADER_SET_DEVICE_PERCENT, #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
      sRemCmd = Lang("Remote", "SetDeviceFader")
      
    Case #SCS_OSCINP_IGNORE
      sRemCmd = "<ignore>"
      
    Default
      sRemCmd = Str(nRemCmd)
      
  EndSelect
  
  ProcedureReturn sRemCmd

EndProcedure

Procedure.s decodeSFRAction(nSFRAction)
  Protected sSFRAction.s  ; as saved in cue files
  
  Select nSFRAction
    Case #SCS_SFR_ACT_NA
      sSFRAction = ""
    Case #SCS_SFR_ACT_STOP
      sSFRAction = "stop"
    Case #SCS_SFR_ACT_FADEOUT
      sSFRAction = "fadeout"
    Case #SCS_SFR_ACT_RELEASE
      sSFRAction = "release"
    Case #SCS_SFR_ACT_CANCELREPEAT
      sSFRAction = "cancelrepeat"
    Case #SCS_SFR_ACT_TRACK
      sSFRAction = "track"
    Case #SCS_SFR_ACT_PAUSE
      sSFRAction = "pause"
    Case #SCS_SFR_ACT_RESUME
      sSFRAction = "resume"
    Case #SCS_SFR_ACT_PAUSEHIB
      sSFRAction = "pausehib"
    Case #SCS_SFR_ACT_FADEOUTHIB
      sSFRAction = "fadeouthib"
    Case #SCS_SFR_ACT_RESUMEHIB
      sSFRAction = "resumehib"
    Case #SCS_SFR_ACT_RESUMEHIBNEXT
      sSFRAction = "resumehibnext"
    Case #SCS_SFR_ACT_STOPALL
      sSFRAction = "stopall"
    Case #SCS_SFR_ACT_FADEALL
      sSFRAction = "fadeall"
    Case #SCS_SFR_ACT_PAUSEALL
      sSFRAction = "pauseall"
    Case #SCS_SFR_ACT_STOPMTC
      If grLicInfo\bLTCAvailable
        sSFRAction = "stopmtcltc"
      Else
        sSFRAction = "stopmtc"
      EndIf
    Case #SCS_SFR_ACT_STOPCHASE
      sSFRAction = "stopchase"
  EndSelect
  ProcedureReturn sSFRAction
EndProcedure

Procedure encodeSFRAction(sSFRAction.s)
  Protected nSFRAction
  
  Select sSFRAction
    Case ""
      nSFRAction = #SCS_SFR_ACT_NA
    Case "stop"
      nSFRAction = #SCS_SFR_ACT_STOP
    Case "fadeout"
      nSFRAction = #SCS_SFR_ACT_FADEOUT
    Case "release"
      nSFRAction = #SCS_SFR_ACT_RELEASE
    Case "cancelrepeat"
      nSFRAction = #SCS_SFR_ACT_CANCELREPEAT
    Case "track"
      nSFRAction = #SCS_SFR_ACT_TRACK
    Case "pause"
      nSFRAction = #SCS_SFR_ACT_PAUSE
    Case "resume"
      nSFRAction = #SCS_SFR_ACT_RESUME
    Case "pausehib"
      nSFRAction = #SCS_SFR_ACT_PAUSEHIB
    Case "fadeouthib"
      nSFRAction = #SCS_SFR_ACT_FADEOUTHIB
    Case "resumehib"
      nSFRAction = #SCS_SFR_ACT_RESUMEHIB
    Case "resumehibnext"
      nSFRAction = #SCS_SFR_ACT_RESUMEHIBNEXT
    Case "stopall"
      nSFRAction = #SCS_SFR_ACT_STOPALL
    Case "fadeall"
      nSFRAction = #SCS_SFR_ACT_FADEALL
    Case "pauseall"
      nSFRAction = #SCS_SFR_ACT_PAUSEALL
    Case "stopmtc", "stopmtcltc"  ; Added "stopmtcltc" 8Jun2024 11.10.3ak as it could already be set in decodeSFRAction()
      nSFRAction = #SCS_SFR_ACT_STOPMTC
    Case "stopchase"
      nSFRAction = #SCS_SFR_ACT_STOPCHASE
  EndSelect
  ProcedureReturn nSFRAction
EndProcedure

Procedure.s decodeSFRCueType(nSFRCueType)
  Protected sSFRCueType.s   ; as saved in cue files
  
  Select nSFRCueType
    Case #SCS_SFR_CUE_NA
      sSFRCueType = ""
    Case #SCS_SFR_CUE_ALL_ANY
      sSFRCueType = "all"
    Case #SCS_SFR_CUE_ALL_AUDIO
      sSFRCueType = "allaud"
    Case #SCS_SFR_CUE_ALL_VIDEO_IMAGE
      sSFRCueType = "allvid"
    Case #SCS_SFR_CUE_ALL_LIVE
      sSFRCueType = "alllive"
    Case #SCS_SFR_CUE_PLAY_ANY
      sSFRCueType = "play"
    Case #SCS_SFR_CUE_PLAY_AUDIO
      sSFRCueType = "playaud"
    Case #SCS_SFR_CUE_PLAY_VIDEO_IMAGE
      sSFRCueType = "playvid"
    Case #SCS_SFR_CUE_PLAY_LIVE
      sSFRCueType = "playlive"
    Case #SCS_SFR_CUE_ALLEXCEPT
      sSFRCueType = "allexcept"
    Case #SCS_SFR_CUE_PLAYEXCEPT
      sSFRCueType = "playexcept"
    Case #SCS_SFR_CUE_PREV
      sSFRCueType = "prev"
    Case #SCS_SFR_CUE_SEL
      sSFRCueType = "sel"
  EndSelect
  ProcedureReturn sSFRCueType
EndProcedure

Procedure encodeSFRCueType(sSFRCueType.s)
  Protected nSFRCueType
  
  Select sSFRCueType
    Case ""
      nSFRCueType = #SCS_SFR_CUE_NA
    Case "all"
      nSFRCueType = #SCS_SFR_CUE_ALL_ANY
    Case "allaud"
      nSFRCueType = #SCS_SFR_CUE_ALL_AUDIO
    Case "allvid"
      nSFRCueType = #SCS_SFR_CUE_ALL_VIDEO_IMAGE
    Case "alllive"
      nSFRCueType = #SCS_SFR_CUE_ALL_LIVE
    Case "play"
      nSFRCueType = #SCS_SFR_CUE_PLAY_ANY
    Case "playaud"
      nSFRCueType = #SCS_SFR_CUE_PLAY_AUDIO
    Case "playvid"
      nSFRCueType = #SCS_SFR_CUE_PLAY_VIDEO_IMAGE
    Case "playlive"
      nSFRCueType = #SCS_SFR_CUE_PLAY_LIVE
    Case "allexcept"
      nSFRCueType = #SCS_SFR_CUE_ALLEXCEPT
    Case "playexcept"
      nSFRCueType = #SCS_SFR_CUE_PLAYEXCEPT
    Case "prev"
      nSFRCueType = #SCS_SFR_CUE_PREV
    Case "sel"
      nSFRCueType = #SCS_SFR_CUE_SEL
  EndSelect
  ProcedureReturn nSFRCueType
EndProcedure

Procedure.s decodeLCCueType(nLCCueType)
  Protected sLCCueType.s   ; as saved in cue files
  
  Select nLCCueType
    Case #SCS_LC_CUE_NA
      sLCCueType = ""
    Case #SCS_LC_CUE_PLAY_AUDIO
      sLCCueType = "playaud"
    Case #SCS_LC_CUE_SEL
      sLCCueType = "sel"
  EndSelect
  ProcedureReturn sLCCueType
EndProcedure

Procedure encodeLCCueType(sLCCueType.s)
  Protected nLCCueType
  
  Select sLCCueType
    Case ""
      nLCCueType = #SCS_LC_CUE_NA
    Case "playaud"
      nLCCueType = #SCS_LC_CUE_PLAY_AUDIO
    Case "sel"
      nLCCueType = #SCS_LC_CUE_SEL
  EndSelect
  ProcedureReturn nLCCueType
EndProcedure

Procedure.s decodeLCAction(nLCAction)
  Protected sLCAction.s   ; as saved in cue files
  
  Select nLCAction
    Case #SCS_LC_ACTION_ABSOLUTE
      sLCAction = "abs"
    Case #SCS_LC_ACTION_RELATIVE
      sLCAction = "rel"
    Case #SCS_LC_ACTION_TEMPO
      sLCAction = "tempo"
    Case #SCS_LC_ACTION_PITCH
      sLCAction = "pitch"
    Case #SCS_LC_ACTION_FREQ
      sLCAction = "freq"
    Default
      sLCAction = "abs"
  EndSelect
  ProcedureReturn sLCAction
EndProcedure

Procedure encodeLCAction(sLCAction.s)
  Protected nLCAction
  
  Select sLCAction
    Case "abs"
      nLCAction = #SCS_LC_ACTION_ABSOLUTE
    Case "rel"
      nLCAction = #SCS_LC_ACTION_RELATIVE
    Case "tempo"
      nLCAction = #SCS_LC_ACTION_TEMPO
    Case "pitch"
      nLCAction = #SCS_LC_ACTION_PITCH
    Case "freq"
      nLCAction = #SCS_LC_ACTION_FREQ
    Default
      nLCAction = #SCS_LC_ACTION_ABSOLUTE
  EndSelect
  ProcedureReturn nLCAction
EndProcedure

Procedure.s decodeAFAction(nAFAction)
  Protected sAFAction.s   ; as saved in cue files
  
  Select nAFAction
    Case #SCS_AF_ACTION_FREQ
      sAFAction = "freq"
    Case #SCS_AF_ACTION_TEMPO
      sAFAction = "tempo"
    Case #SCS_AF_ACTION_PITCH
      sAFAction = "pitch"
    Default
      sAFAction = ""
  EndSelect
  ProcedureReturn sAFAction
EndProcedure

Procedure encodeAFAction(sAFAction.s)
  Protected nAFAction
  
  Select sAFAction
    Case "freq"
      nAFAction = #SCS_AF_ACTION_FREQ
    Case "tempo"
      nAFAction = #SCS_AF_ACTION_TEMPO
    Case "pitch"
      nAFAction = #SCS_AF_ACTION_PITCH
    Default
      nAFAction = #SCS_AF_ACTION_NONE
  EndSelect
  ProcedureReturn nAFAction
EndProcedure

Procedure.s decodeChangeCode(nChangeCode)
  ; only used for debugging, so no 'encodeChangeCode()' procedure required
  Protected sChangeCode.s
  
  Select nChangeCode
    Case #SCS_CHANGE_NONE
      sChangeCode = "none"
    Case #SCS_CHANGE_FREQ
      sChangeCode = "freq"
    Case #SCS_CHANGE_TEMPO
      sChangeCode = "tempo"
    Case #SCS_CHANGE_PITCH
      sChangeCode = "pitch"
  EndSelect
  ProcedureReturn sChangeCode
EndProcedure

Procedure encodeVisMode(sVisMode.s)
  PROCNAMEC()
  Protected nVisMode
  Select UCase(sVisMode)
    Case "NONE"
      nVisMode = #SCS_VU_NONE
    Default
      nVisMode = #SCS_VU_LEVELS
  EndSelect
  ProcedureReturn nVisMode
EndProcedure

Procedure.s decodeVisMode(nVisMode)
  Protected sVisMode.s
  Select nVisMode
    Case #SCS_VU_NONE
      sVisMode = "NONE"
    Default
      sVisMode = "LEVELS"
  EndSelect
  ProcedureReturn sVisMode
EndProcedure

Procedure.s decodeVisModeL(nVisMode)
  ProcedureReturn Lang("WOP", "VisMode" + decodeVisMode(nVisMode))
EndProcedure

Procedure.s getDevTypeDesc(nDevType)
  Protected sDevType.s
  
  sDevType = decodeDevType(nDevType)
  If Len(sDevType) = 0
    ProcedureReturn ""
  Else
    ProcedureReturn Lang("DevType", sDevType)
  EndIf
EndProcedure

Procedure setLabels(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, k, sLabel.s, nAudCount

  ; debugMsg(sProcName, #SCS_START)
  
  If pCuePtr < 0
    ProcedureReturn
  EndIf

  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If aSub(j)\nPrevSubIndex = -1 And aSub(j)\nNextSubIndex = -1
      sLabel = aSub(j)\sCue
    Else
      sLabel = aSub(j)\sCue + "<" + aSub(j)\nSubNo + ">"
    EndIf
    aSub(j)\sSubLabel = sLabel
    ; debugMsg(sProcName, "aSub(" + j + ")\sSubLabel=" + aSub(j)\sSubLabel)
    If aSub(j)\bSubTypeHasAuds
      nAudCount = aSub(j)\nAudCount
      If nAudCount = 0
        ; probably not set yet, so calculate this field now
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          nAudCount + 1
          aAud(k)\nAudNo = nAudCount
          k = aAud(k)\nNextAudIndex
        Wend
        aSub(j)\nAudCount = nAudCount
;         debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nAudCount=" + aSub(j)\nAudCount)
      EndIf
      k = aSub(j)\nFirstAudIndex
      While k >= 0
        With aAud(k)
          If nAudCount <= 1
            \sAudLabel = sLabel
          ElseIf Right(sLabel, 1) = ">"
            \sAudLabel = Left(sLabel, Len(sLabel) - 1) + "." + \nAudNo + ">"
          Else
            \sAudLabel = aSub(j)\sSubLabel + "<" + "." + \nAudNo + ">"
          EndIf
          ; debugMsg(sProcName, "aAud(" + k + ")\sAudLabel=" + aAud(k)\sAudLabel)
          k = \nNextAudIndex
        EndWith
      Wend
    EndIf
    j = aSub(j)\nNextSubIndex
  Wend

EndProcedure

Procedure set2ndLabels(pCuePtr)
  PROCNAMEC()
  Protected j, k, sLabel.s, nAudCount

  If pCuePtr < 0
    ProcedureReturn
  EndIf

  j = a2ndCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If a2ndSub(j)\nPrevSubIndex = -1 And a2ndSub(j)\nNextSubIndex = -1
      sLabel = a2ndSub(j)\sCue
    Else
      sLabel = a2ndSub(j)\sCue + "<" + a2ndSub(j)\nSubNo + ">"
    EndIf
    a2ndSub(j)\sSubLabel = sLabel
    If a2ndSub(j)\bSubTypeHasAuds
      nAudCount = a2ndSub(j)\nAudCount
      If nAudCount = 0
        ; probably not set yet, so calculate this field now
        k = a2ndSub(j)\nFirstAudIndex
        While k >= 0
          nAudCount + 1
          a2ndAud(k)\nAudNo = nAudCount
          k = a2ndAud(k)\nNextAudIndex
        Wend
        a2ndSub(j)\nAudCount = nAudCount
      EndIf
      k = a2ndSub(j)\nFirstAudIndex
      While k >= 0
        With a2ndAud(k)
          If nAudCount <= 1
            \sAudLabel = sLabel
          ElseIf Right(sLabel, 1) = ">"
            \sAudLabel = Left(sLabel, Len(sLabel) - 1) + "." + \nAudNo + ">"
          Else
            \sAudLabel = a2ndSub(j)\sSubLabel + "<" + "." + \nAudNo + ">"
          EndIf
          k = \nNextAudIndex
        EndWith
      Wend
    EndIf
    j = a2ndSub(j)\nNextSubIndex
  Wend

EndProcedure

Procedure.s calcProdId()
  PROCNAMEC()
  Protected dDateNow, dDateBase
  Protected nSeconds, sMyProdId.s
  
  dDateBase = Date(2005, 1, 1, 0, 0, 0)
  dDateNow = Date()
  nSeconds = dDateNow - dDateBase
  
  sMyProdId = Hex(nSeconds)
  ProcedureReturn sMyProdId
EndProcedure

Procedure indexForCtrlMethod(pCtrlMethod.s)
  PROCNAMEC()
  Protected nIndex
  Select pCtrlMethod
    Case "MSC"
      nIndex = 1
    Case "MMC"
      nIndex = 2
    Case "Note"
      nIndex = 3
    Case "PC127"
      nIndex = 4
    Case "PC128"
      nIndex = 5
    Case "ETC AB"
      nIndex = 6
    Case "ETC CD"
      nIndex = 7
    Case "Palladium"
      nIndex = 8
    Case "Custom"
      nIndex = 9
    Default
      nIndex = 0
  EndSelect
  ProcedureReturn nIndex
EndProcedure

Procedure compactLabel(hField, sValue.s, nMinLength=20)
  PROCNAMEC()
  Protected sTmp.s, nLen, nChars
  Protected nFieldWidth
  
  sTmp = sValue
  nFieldWidth = GadgetWidth(hField)
  
  StartDrawing(WindowOutput(#WMN))
  DrawingFont(GetGadgetFont(hField))
  nLen = TextWidth(sTmp)
  If nLen > nFieldWidth
    nChars = Len(sValue)
    While (nLen > nFieldWidth) And (nChars > nMinLength)
      nChars - 1
      sTmp = Left(sValue, nChars) + "..."
      nLen = TextWidth(sTmp)
    Wend
  EndIf
  StopDrawing()
  SetGadgetText(hField, sTmp)

EndProcedure

Procedure.s compactTextForCanvas(sText.s, nMaxWidth)
  PROCNAMEC()
  ; Must be called within a StartDrawing() / StopDrawing() sequence, with DrawingFont() also set
  Protected sTmp.s, nTmpTextWidth, nChars
  
  sTmp = sText
  nTmpTextWidth = TextWidth(sTmp)
  If nTmpTextWidth > nMaxWidth
    nChars = Len(sTmp)
    While (nTmpTextWidth > nMaxWidth) And (nChars > 0)
      nChars - 1
      sTmp = Left(sText, nChars) + "..."
      nTmpTextWidth = TextWidth(sTmp)
    Wend
  EndIf
  ProcedureReturn sTmp
  
EndProcedure

Procedure displayHelpContents()
  PROCNAMEC()
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  If FileExists(gsHelpFile)
    OpenHelp(gsHelpFile, #SCS_HELP_CONTENTS_ID + ".htm")
  Else
    sMsg = LangPars("Errors", "HelpFileNotFound", gsHelpFile)
    debugMsg(sProcName, sMsg)
    ensureSplashNotOnTop()
    scsMessageRequester(#SCS_TITLE, sMsg)
  EndIf
EndProcedure

Procedure displayHelpTopic(pTopicFile.s)
  PROCNAMEC()
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START + ", pTopicFile=" + #DQUOTE$ + pTopicFile + #DQUOTE$)
  
  If FileExists(gsHelpFile)
    OpenHelp(gsHelpFile, pTopicFile)
  Else
    sMsg = LangPars("Errors", "HelpFileNotFound", gsHelpFile)
    debugMsg(sProcName, sMsg)
    ensureSplashNotOnTop()
    scsMessageRequester(#SCS_TITLE, sMsg)
  EndIf
EndProcedure

Procedure.s decodeController(nController)
  Protected sController.s
  
  Select nController
    Case #SCS_CTRL_NONE ; 20Jun2022 11.9.4
      sController = "NONE"
    Case #SCS_CTRL_MIDI_CUE_CONTROL
      sController = "MIDICUECTRL"
    Case #SCS_CTRL_BCF2000
      sController = "BCF2000"
    Case #SCS_CTRL_BCR2000
      sController = "BCR2000"
    Case #SCS_CTRL_NK2 ; 14Jun2022 11.9.4
      sController = "NK2"
    Default
      sController = Str(nController)
  EndSelect
  ProcedureReturn sController
EndProcedure

Procedure.s decodeControllerL(nController)
  ProcedureReturn Lang("WCM", decodeController(nController))
EndProcedure

Procedure encodeController(sController.s)
  Protected nController
  
  Select sController
    Case "NONE" ; 20Jun2022 11.9.4
      nController = #SCS_CTRL_NONE
    Case "MIDICUECTRL"
      nController = #SCS_CTRL_MIDI_CUE_CONTROL
    Case "BCF2000"
      nController = #SCS_CTRL_BCF2000
    Case "BCR2000"
      nController = #SCS_CTRL_BCR2000
    Case "NK2" ; 14Jun2022 11.9.4
      nController = #SCS_CTRL_NK2
    Default
      nController = #SCS_CTRL_NONE ; Changed 20Jun2022 11.9.4 - was #SCS_CTRL_MIDI_CUE_CONTROL
  EndSelect
  ProcedureReturn nController
EndProcedure

Procedure.s decodeCtrlConfig(nCtrlConfig)
  Protected sCtrlConfig.s
  
  Select nCtrlConfig
    Case #SCS_CTRLCONF_BCF2000_PRESET_A
      sCtrlConfig = "BCF2000PresetA"
    Case #SCS_CTRLCONF_BCF2000_PRESET_C
      sCtrlConfig = "BCF2000PresetC"
    Case #SCS_CTRLCONF_BCR2000_PRESET_A
      sCtrlConfig = "BCR2000PresetA"
    Case #SCS_CTRLCONF_BCR2000_PRESET_B
      sCtrlConfig = "BCR2000PresetB"
    Case #SCS_CTRLCONF_BCR2000_PRESET_C
      sCtrlConfig = "BCR2000PresetC"
    Case #SCS_CTRLCONF_NK2_PRESET_A
      sCtrlConfig = "NK2PresetA"
    Case #SCS_CTRLCONF_NK2_PRESET_B
      sCtrlConfig = "NK2PresetB"
    Case #SCS_CTRLCONF_NK2_PRESET_C
      sCtrlConfig = "NK2PresetC"
    Default
      sCtrlConfig = Str(nCtrlConfig)
  EndSelect
  ProcedureReturn sCtrlConfig
EndProcedure

Procedure.s decodeCtrlConfigL(nCtrlConfig)
  ProcedureReturn Lang("WCM", decodeCtrlConfig(nCtrlConfig))
EndProcedure

Procedure encodeCtrlConfig(sCtrlConfig.s)
  Protected nCtrlConfig
  Select sCtrlConfig
    Case "BCF2000PresetA"
      nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_A
    Case "BCF2000PresetC"
      nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_C
    Case "BCR2000PresetA"
      nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_A
    Case "BCR2000PresetB"
      nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_B
    Case "BCR2000PresetC"
      nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_C
    Case "NK2PresetA"
      nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_A
    Case "NK2PresetB"
      nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
    Case "NK2PresetC"
      nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_C
  EndSelect
  ProcedureReturn nCtrlConfig
EndProcedure

Procedure.s decodeFaderAssignments(nFaderAssignments)
  Protected sFaderAssignments.s
  Select nFaderAssignments
    Case #SCS_FADER_INPUTS_1_8
      sFaderAssignments = "IN_1_8"
    Case #SCS_FADER_OUTPUTS_1_7_M
      sFaderAssignments = "OUT_1_7_M"
    Case #SCS_FADER_PLAYING_1_7_M
      sFaderAssignments = "PLAY_1_7_M"
  EndSelect
  ProcedureReturn sFaderAssignments
EndProcedure

Procedure encodeFaderAssignments(sFaderAssignments.s)
  Protected nFaderAssignments
  Select sFaderAssignments
    Case "IN_1_8"
      nFaderAssignments = #SCS_FADER_INPUTS_1_8
    Case "OUT_1_7_M"
      nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M
    Case "PLAY_1_7_M"
      nFaderAssignments = #SCS_FADER_PLAYING_1_7_M
  EndSelect
  ProcedureReturn nFaderAssignments
EndProcedure

Procedure.s decodeCtrlItemType(nCtrlItemType)
  Protected sCtrlItemType.s
  Select nCtrlItemType
    Case #SCS_CTRLITEMTYPE_DMX_MASTER_FADER
      sCtrlItemType = "DMXMaster"
    Case #SCS_CTRLITEMTYPE_MASTER_FADER
      sCtrlItemType = "Master"
    Case #SCS_CTRLITEMTYPE_MUTE
      sCtrlItemType = "Mute"
    Case #SCS_CTRLITEMTYPE_OUTPUT_GAIN_FADER
      sCtrlItemType = "Output_Gain"
    Case #SCS_CTRLITEMTYPE_SOLO
      sCtrlItemType = "Solo"
  EndSelect
  ProcedureReturn sCtrlItemType
EndProcedure

Procedure encodeCtrlItemType(sCtrlItemType.s)
  Protected nCtrlItemType
  Select sCtrlItemType
    Case "DMXMaster"
      nCtrlItemType = #SCS_CTRLITEMTYPE_DMX_MASTER_FADER
    Case "Master"
      nCtrlItemType = #SCS_CTRLITEMTYPE_MASTER_FADER
    Case "Mute"
      nCtrlItemType = #SCS_CTRLITEMTYPE_MUTE
    Case "Output_Gain"
      nCtrlItemType = #SCS_CTRLITEMTYPE_OUTPUT_GAIN_FADER
    Case "Solo"
      nCtrlItemType = #SCS_CTRLITEMTYPE_SOLO
  EndSelect
  ProcedureReturn nCtrlItemType
EndProcedure

Procedure getMsgType(nMSMsgType, nRemDevMsgType)
  Protected nMsgType
  
  If grLicInfo\bCSRDAvailable
    If nMSMsgType = #SCS_MSGTYPE_NONE And nRemDevMsgType > 0
      nMsgType = nRemDevMsgType
    Else
      nMsgType = nMSMsgType
    EndIf
  Else
    nMsgType = nMSMsgType
  EndIf
  ProcedureReturn nMsgType
EndProcedure

Procedure.s decodeMsgType(nMsgType)
  ; PROCNAMEC()
  Protected sMsgType.s
  
  Select nMsgType
    Case #SCS_MSGTYPE_NONE
      sMsgType = ""
    Case #SCS_MSGTYPE_CC
      sMsgType = "CC"
    Case #SCS_MSGTYPE_FILE
      sMsgType = "FILE"
    Case #SCS_MSGTYPE_FREE
      sMsgType = "FREE"
    Case #SCS_MSGTYPE_MMC
      sMsgType = "MMC"
    Case #SCS_MSGTYPE_MSC
      sMsgType = "MSC"
    Case #SCS_MSGTYPE_OFF
      sMsgType = "OFF"
    Case #SCS_MSGTYPE_ON
      sMsgType = "ON"
    Case #SCS_MSGTYPE_NRPN_GEN
      sMsgType = "NRPNGEN"
    Case #SCS_MSGTYPE_NRPN_YAM
      sMsgType = "NRPNYAM"
    Case #SCS_MSGTYPE_PC127
      sMsgType = "PC127"
    Case #SCS_MSGTYPE_PC128
      sMsgType = "PC128"
    Case #SCS_MSGTYPE_OSC_OVER_MIDI
      sMsgType = "OSCMIDI"
    Case #SCS_MSGTYPE_RS232
      sMsgType = "RS232"
    Case #SCS_MSGTYPE_NETWORK
      sMsgType = "NETWORK"
    Case #SCS_MSGTYPE_SCRIBBLE_STRIP
      sMsgType = "SCRIB"
    Default
      sMsgType = CSRD_DecodeRemDevMsgType(nMsgType)
      ; debugMsg(sProcName, "CSRD_DecodeRemDevMsgType(" + nMsgType + ") returned " + sMsgType)
  EndSelect
  ProcedureReturn sMsgType
EndProcedure

Procedure.s decodeMsgTypeL(nMsgType)
  Protected sMsgTypeL.s
  If nMsgType > #SCS_MSGTYPE_DUMMY_LAST
    sMsgTypeL = CSRD_GetMsgDescForRemDevMsgType(nMsgType)
  ElseIf nMsgType <> #SCS_MSGTYPE_NONE
    sMsgTypeL = Lang("Ctrl", decodeMsgType(nMsgType))
  EndIf
  ProcedureReturn sMsgTypeL
EndProcedure

Procedure.s decodeMsgTypeShortL(nMsgType, nAction=#False)
  Protected sMsgTypeShortL.s
  If nMsgType > #SCS_MSGTYPE_DUMMY_LAST
    sMsgTypeShortL = CSRD_GetMsgShortDescForRemDevMsgType(nMsgType, nAction)
  ElseIf nMsgType <> #SCS_MSGTYPE_NONE
    sMsgTypeShortL = Lang("Ctrl", "Short"+decodeMsgType(nMsgType))
  EndIf
  ProcedureReturn sMsgTypeShortL
EndProcedure

Procedure encodeMSMsgType(sMsgType.s)
  Protected nMSMsgType
  
  Select UCase(sMsgType)
    Case "CC"
      nMSMsgType = #SCS_MSGTYPE_CC
    Case "FILE"
      nMSMsgType = #SCS_MSGTYPE_FILE
    Case "FREE", "MIDI" ; was "MIDI" in SCS 10; "FREE" in SCS 11
      nMSMsgType = #SCS_MSGTYPE_FREE
    Case "MMC"
      nMSMsgType = #SCS_MSGTYPE_MMC
    Case "MSC"
      nMSMsgType = #SCS_MSGTYPE_MSC
    Case "NRPNGEN"
      nMSMsgType = #SCS_MSGTYPE_NRPN_GEN
    Case "NRPNYAM"
      nMSMsgType = #SCS_MSGTYPE_NRPN_YAM
    Case "OFF"
      nMSMsgType = #SCS_MSGTYPE_OFF
    Case "ON"
      nMSMsgType = #SCS_MSGTYPE_ON
    Case "PC127"
      nMSMsgType = #SCS_MSGTYPE_PC127
    Case "PC128"
      nMSMsgType = #SCS_MSGTYPE_PC128
    Case "OSCMIDI"
      nMSMsgType = #SCS_MSGTYPE_OSC_OVER_MIDI
    Case "RS232"
      nMSMsgType = #SCS_MSGTYPE_RS232
    Case "NETWORK"
      nMSMsgType = #SCS_MSGTYPE_NETWORK
    Case "SCRIB"
      nMSMsgType = #SCS_MSGTYPE_SCRIBBLE_STRIP
    Default
      nMSMsgType = #SCS_MSGTYPE_NONE
  EndSelect
  ProcedureReturn nMSMsgType
EndProcedure

Procedure.s decodeCtrlMethod(nCtrlMethod)
  Protected sCtrlMethod.s
  
  Select nCtrlMethod
    Case #SCS_CTRLMETHOD_MTC
      sCtrlMethod = "MTC"
    Case #SCS_CTRLMETHOD_MSC
      sCtrlMethod = "MSC"
    Case #SCS_CTRLMETHOD_MMC
      sCtrlMethod = "MMC"
    Case #SCS_CTRLMETHOD_NOTE
      sCtrlMethod = "ON"
    Case #SCS_CTRLMETHOD_PC127
      sCtrlMethod = "PC127"
    Case #SCS_CTRLMETHOD_PC128
      sCtrlMethod = "PC128"
    Case #SCS_CTRLMETHOD_ETC_AB
      sCtrlMethod = "ETC AB"
    Case #SCS_CTRLMETHOD_ETC_CD
      sCtrlMethod = "ETC CD"
    Case #SCS_CTRLMETHOD_PALLADIUM
      sCtrlMethod = "Palladium"
    Case #SCS_CTRLMETHOD_CUSTOM
      sCtrlMethod = "Custom"
    Default
      sCtrlMethod = Str(nCtrlMethod)
  EndSelect
  ProcedureReturn sCtrlMethod
EndProcedure

Procedure.s decodeCtrlMethodL(nCtrlMethod)
  ProcedureReturn Lang("Ctrl", decodeCtrlMethod(nCtrlMethod))
EndProcedure

Procedure encodeCtrlMethod(sCtrlMethod.s)
  Protected nCtrlMethod
  
  Select UCase(sCtrlMethod)
    Case "MTC"
      nCtrlMethod = #SCS_CTRLMETHOD_MTC
    Case "MSC"
      nCtrlMethod = #SCS_CTRLMETHOD_MSC
    Case "MMC"
      nCtrlMethod = #SCS_CTRLMETHOD_MMC
    Case "ON"
      nCtrlMethod = #SCS_CTRLMETHOD_NOTE
    Case "PC127"
      nCtrlMethod = #SCS_CTRLMETHOD_PC127
    Case "PC128"
      nCtrlMethod = #SCS_CTRLMETHOD_PC128
    Case "ETC AB"
      nCtrlMethod = #SCS_CTRLMETHOD_ETC_AB
    Case "ETC CD"
      nCtrlMethod = #SCS_CTRLMETHOD_ETC_CD
    Case "PALLADIUM"
      nCtrlMethod = #SCS_CTRLMETHOD_PALLADIUM
    Case "CUSTOM"
      nCtrlMethod = #SCS_CTRLMETHOD_CUSTOM
  EndSelect
  ProcedureReturn nCtrlMethod
EndProcedure

Procedure.s decodeCtrlCommandL(nCtrlCommand, sPar1.s="")
  Protected sCtrlCommand.s
  
  Select nCtrlCommand
    Case #SCS_CCC_GO
      sCtrlCommand = Lang("Remote", "GoButton")
    Case #SCS_CCC_GO_CONFIRM
      sCtrlCommand = Lang("Remote", "GoConfirm")
    Case #SCS_CCC_STOP_ALL
      sCtrlCommand = Lang("Remote", "StopAll")
    Case #SCS_CCC_FADE_ALL
      sCtrlCommand = Lang("Remote", "FadeAll")
    Case #SCS_CCC_PAUSE_RESUME_ALL
      sCtrlCommand = Lang("Remote", "PauseResumeAll")
    Case #SCS_CCC_GO_TO_TOP
      sCtrlCommand = Lang("Remote", "GoToTop")
    Case #SCS_CCC_GO_BACK
      sCtrlCommand = Lang("Remote", "GoBack")
    Case #SCS_CCC_GO_TO_NEXT
      sCtrlCommand = Lang("Remote", "GoToNext")
    Case #SCS_CCC_GO_TO_END
      sCtrlCommand = Lang("Remote", "GoToEnd")
    Case #SCS_CCC_GO_TO_CUE_X
      sCtrlCommand = LangPars("Remote", "GoToCue", sPar1)
    Case #SCS_CCC_PLAY_CUE_X
      sCtrlCommand = LangPars("Remote", "PlayCue", sPar1)
    Case #SCS_CCC_STOP_CUE_X
      sCtrlCommand = LangPars("Remote", "StopCue", sPar1)
    Case #SCS_CCC_PAUSE_RESUME_CUE_X
      sCtrlCommand = LangPars("Remote", "PauseResumeCue", sPar1)
    Case #SCS_CCC_PLAY_HOTKEY_X
      sCtrlCommand = LangPars("Remote", "HkeyGo", sPar1)
    Case #SCS_CCC_START_NOTE_HOTKEY_X
      sCtrlCommand = LangPars("Remote", "HkeyOn", sPar1)
    Case #SCS_CCC_STOP_NOTE_HOTKEY_X
      sCtrlCommand = LangPars("Remote", "HkeyOff", sPar1)
    Case #SCS_CCC_SET_MASTER_FADER_DB
      sCtrlCommand = Lang("Remote", "SetMasterFader")
    Case #SCS_CCC_SET_DEVICE_FADER_DB
      sCtrlCommand = Lang("Remote", "SetDeviceFader")
    Default
      sCtrlCommand = Str(nCtrlCommand)
  EndSelect
  ProcedureReturn sCtrlCommand
EndProcedure

Procedure.s decodeMidiCommand(nMidiCommand)
  Protected sMidiCommand.s, nAudNo, nDimmerIndex, bUseDevChgs, sLogicalDev.s, sFixtureCode.s
  
  Select nMidiCommand
    Case #SCS_MIDI_PLAY_CUE
      sMidiCommand = "Play"
    Case #SCS_MIDI_PAUSE_RESUME_CUE
      sMidiCommand = "Pause"
    Case #SCS_MIDI_RELEASE_CUE
      sMidiCommand = "Release"
    Case #SCS_MIDI_FADE_OUT_CUE
      sMidiCommand = "Fade"
    Case #SCS_MIDI_STOP_CUE
      sMidiCommand = "Stop"
    Case #SCS_MIDI_GO_TO_CUE
      sMidiCommand = "GoTo"
    Case #SCS_MIDI_LOAD_CUE
      sMidiCommand = "Load"
    Case #SCS_MIDI_UNLOAD_CUE
      sMidiCommand = "Unload"
    Case #SCS_MIDI_GO_BUTTON
      sMidiCommand = "Go"
    Case #SCS_MIDI_STOP_ALL
      sMidiCommand = "StopAll"
    Case #SCS_MIDI_FADE_ALL ; 7May2022
      sMidiCommand = "FadeAll"
    Case #SCS_MIDI_PAUSE_RESUME_ALL
      sMidiCommand = "PauseAll"
    Case #SCS_MIDI_GO_TO_TOP
      sMidiCommand = "GoTop"
    Case #SCS_MIDI_GO_BACK
      sMidiCommand = "GoBack"
    Case #SCS_MIDI_GO_TO_NEXT
      sMidiCommand = "GoNext"
    Case #SCS_MIDI_PAGE_UP
      sMidiCommand = "PageUp"
    Case #SCS_MIDI_PAGE_DOWN
      sMidiCommand = "PageDown"
    Case #SCS_MIDI_MASTER_FADER
      sMidiCommand = "Master"
    Case #SCS_MIDI_GO_CONFIRM
      sMidiCommand = "Confirm"
    Case #SCS_MIDI_OPEN_FAV_FILE
      sMidiCommand = "OpenFavFile"
    Case #SCS_MIDI_SET_HOTKEY_BANK
      sMidiCommand = "SetHotkeyBank"
    Case #SCS_MIDI_TAP_DELAY
      sMidiCommand = "TapDelay"
    Case #SCS_MIDI_EXT_FADER
      sMidiCommand = "ExtFader"
    Case #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER
      nAudNo = nMidiCommand - #SCS_MIDI_DEVICE_1_FADER
      If IsGadget(WEP\btnApplyDevChgs)
        If getEnabled(WEP\btnApplyDevChgs)
          bUseDevChgs = #True
        EndIf
      EndIf
      If bUseDevChgs
        If nAudNo <= grProdForDevChgs\nMaxAudioLogicalDev
          sLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nAudNo)\sLogicalDev
        EndIf
      Else
        If nAudNo <= grProd\nMaxAudioLogicalDev
          sLogicalDev = grProd\aAudioLogicalDevs(nAudNo)\sLogicalDev
        EndIf
      EndIf
      sMidiCommand = "AudFader_" + sLogicalDev
    Case #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER
      nDimmerIndex = nMidiCommand - #SCS_MIDI_DIMMER_1_FADER
      If IsGadget(WEP\btnApplyDevChgs)
        If getEnabled(WEP\btnApplyDevChgs)
          bUseDevChgs = #True
        EndIf
      EndIf
      If bUseDevChgs
        sFixtureCode = WCN_getDimmerIndexFixtureCode(nDimmerIndex)
      Else
;         If nDevNo <= grProd\nMaxCueCtrlLogicalDev
;           sLogicalDev = grProd\aCueCtrlLogicalDevs(nDevNo)\sCueCtrlLogicalDev
;         EndIf
      EndIf
      sMidiCommand = "Dimmer_" + sFixtureCode
    Case #SCS_MIDI_DMX_MASTER
      sMidiCommand = "DMXMaster"
    Case #SCS_MIDI_CUE_MARKER_PREV    ; 3May2022 11.9.1
      sMidiCommand = "CueMarkerPrev"
    Case #SCS_MIDI_CUE_MARKER_NEXT    ; 3May2022 11.9.1
      sMidiCommand = "CueMarkerNext"
    Default
      sMidiCommand = Str(nMidiCommand)
  EndSelect
  ProcedureReturn sMidiCommand
EndProcedure

Procedure encodeMidiCommand(sMidiCommand.s, *rProd.tyProd)
  ; PROCNAMEC()
  Protected nMidiCommand, d, nAudNo, nDevNo, sLogicalDev.s
  
  Select UCase(sMidiCommand)
    Case "PLAY"
      nMidiCommand = #SCS_MIDI_PLAY_CUE
    Case "PAUSE"
      nMidiCommand = #SCS_MIDI_PAUSE_RESUME_CUE
    Case "RELEASE"
      nMidiCommand = #SCS_MIDI_RELEASE_CUE
    Case "FADE"
      nMidiCommand = #SCS_MIDI_FADE_OUT_CUE
    Case "STOP"
      nMidiCommand = #SCS_MIDI_STOP_CUE
    Case "GOTO"
      nMidiCommand = #SCS_MIDI_GO_TO_CUE
    Case "LOAD"
      nMidiCommand = #SCS_MIDI_LOAD_CUE
    Case "UNLOAD"
      nMidiCommand = #SCS_MIDI_UNLOAD_CUE
    Case "GO"
      nMidiCommand = #SCS_MIDI_GO_BUTTON
    Case "STOPALL"
      nMidiCommand = #SCS_MIDI_STOP_ALL
    Case "FADEALL" ; 7May2022 11.9.1
      nMidiCommand = #SCS_MIDI_FADE_ALL
    Case "PAUSEALL"
      nMidiCommand = #SCS_MIDI_PAUSE_RESUME_ALL
    Case "GOTOP"
      nMidiCommand = #SCS_MIDI_GO_TO_TOP
    Case "GOBACK"
      nMidiCommand = #SCS_MIDI_GO_BACK
    Case "GONEXT"
      nMidiCommand = #SCS_MIDI_GO_TO_NEXT
    Case "PAGEUP"
      nMidiCommand = #SCS_MIDI_PAGE_UP
    Case "PAGEDOWN"
      nMidiCommand = #SCS_MIDI_PAGE_DOWN
    Case "MASTER"
      nMidiCommand = #SCS_MIDI_MASTER_FADER
    Case "CONFIRM"
      nMidiCommand = #SCS_MIDI_GO_CONFIRM
    Case "OPENFAVFILE"
      nMidiCommand = #SCS_MIDI_OPEN_FAV_FILE
    Case "SETHOTKEYBANK"
      nMidiCommand = #SCS_MIDI_SET_HOTKEY_BANK
    Case "TAPDELAY"
      nMidiCommand = #SCS_MIDI_TAP_DELAY
    Case "EXTFADER"
      nMidiCommand = #SCS_MIDI_EXT_FADER
    Case "DMXMASTER"
      nMidiCommand = #SCS_MIDI_DMX_MASTER
    Case "CUEMARKERPREV"    ; 3May2022 11.9.1
      nMidiCommand = #SCS_MIDI_CUE_MARKER_PREV
    Case "CUEMARKERNEXT"    ; 3May2022 11.9.1
      nMidiCommand = #SCS_MIDI_CUE_MARKER_NEXT
    Default
      If Left(UCase(sMidiCommand), 9) = "AUDFADER_"
        sLogicalDev = Mid(sMidiCommand, 10)
        nAudNo = -1
        For d = 0 To *rProd\nMaxAudioLogicalDev
          If *rProd\aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
            nAudNo = d
            Break
          EndIf
        Next d
        nMidiCommand = #SCS_MIDI_DEVICE_1_FADER + nAudNo
        If nMidiCommand < #SCS_MIDI_DEVICE_1_FADER Or nMidiCommand > #SCS_MIDI_DEVICE_LAST_FADER
          ; invalid (shouldn't happen)
          nMidiCommand = 0
        EndIf
      ElseIf Left(UCase(sMidiCommand), 7) = "DIMMER_"
        sLogicalDev = Mid(sMidiCommand, 8)
        nDevNo = -1
        For d = 0 To *rProd\nMaxCueCtrlLogicalDev
          If *rProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        nMidiCommand = #SCS_MIDI_DIMMER_1_FADER + nDevNo
        If nMidiCommand < #SCS_MIDI_DIMMER_1_FADER Or nMidiCommand > #SCS_MIDI_DIMMER_LAST_FADER
          ; invalid (shouldn't happen)
          nMidiCommand = 0
        EndIf
      EndIf
  EndSelect
  ProcedureReturn nMidiCommand
EndProcedure

Procedure.s decodeX32Command(nX32Command)
  Protected sX32Command.s
  
  Select nX32Command
;     Case #SCS_X32_PLAY_CUE
;       sX32Command = "Play"
;     Case #SCS_X32_PAUSE_RESUME_CUE
;       sX32Command = "Pause"
;     Case #SCS_X32_RELEASE_CUE
;       sX32Command = "Release"
;     Case #SCS_X32_FADE_OUT_CUE
;       sX32Command = "Fade"
;     Case #SCS_X32_STOP_CUE
;       sX32Command = "Stop"
;     Case #SCS_X32_GO_TO_CUE
;       sX32Command = "GoTo"
;     Case #SCS_X32_LOAD_CUE
;       sX32Command = "Load"
;     Case #SCS_X32_UNLOAD_CUE
;       sX32Command = "Unload"
    Case #SCS_X32_GO_BUTTON
      sX32Command = "Go"
    Case #SCS_X32_STOP_ALL
      sX32Command = "StopAll"
    Case #SCS_X32_FADE_ALL
      sX32Command = "FadeAll"
    Case #SCS_X32_PAUSE_RESUME_ALL
      sX32Command = "PauseAll"
    Case #SCS_X32_GO_TO_TOP
      sX32Command = "GoTop"
    Case #SCS_X32_GO_BACK
      sX32Command = "GoBack"
    Case #SCS_X32_GO_TO_NEXT
      sX32Command = "GoNext"
    Case #SCS_X32_TAP_DELAY
      sX32Command = "TapDelay"
;     Case #SCS_X32_PAGE_UP
;       sX32Command = "PageUp"
;     Case #SCS_X32_PAGE_DOWN
;       sX32Command = "PageDown"
;     Case #SCS_X32_MASTER_FADER
;       sX32Command = "Master"
;     Case #SCS_X32_GO_CONFIRM
;       sX32Command = "Confirm"
;     Case #SCS_X32_OPEN_FAV_FILE
;       sX32Command = "OpenFavFile"
  EndSelect
  ProcedureReturn sX32Command
EndProcedure

Procedure encodeX32Command(sX32Command.s)
  Protected nX32Command
  
  Select UCase(sX32Command)
;     Case "PLAY"
;       nX32Command = #SCS_X32_PLAY_CUE
;     Case "PAUSE"
;       nX32Command = #SCS_X32_PAUSE_RESUME_CUE
;     Case "RELEASE"
;       nX32Command = #SCS_X32_RELEASE_CUE
;     Case "FADE"
;       nX32Command = #SCS_X32_FADE_OUT_CUE
;     Case "STOP"
;       nX32Command = #SCS_X32_STOP_CUE
;     Case "GOTO"
;       nX32Command = #SCS_X32_GO_TO_CUE
;     Case "LOAD"
;       nX32Command = #SCS_X32_LOAD_CUE
;     Case "UNLOAD"
;       nX32Command = #SCS_X32_UNLOAD_CUE
    Case "GO"
      nX32Command = #SCS_X32_GO_BUTTON
    Case "STOPALL"
      nX32Command = #SCS_X32_STOP_ALL
    Case "FADEALL"
      nX32Command = #SCS_X32_FADE_ALL
    Case "PAUSEALL"
      nX32Command = #SCS_X32_PAUSE_RESUME_ALL
    Case "GOTOP"
      nX32Command = #SCS_X32_GO_TO_TOP
    Case "GOBACK"
      nX32Command = #SCS_X32_GO_BACK
    Case "GONEXT"
      nX32Command = #SCS_X32_GO_TO_NEXT
    Case "TAPDELAY"
      nX32Command = #SCS_X32_TAP_DELAY
;     Case "PAGEUP"
;       nX32Command = #SCS_X32_PAGE_UP
;     Case "PAGEDOWN"
;       nX32Command = #SCS_X32_PAGE_DOWN
;     Case "MASTER"
;       nX32Command = #SCS_X32_MASTER_FADER
;     Case "CONFIRM"
;       nX32Command = #SCS_X32_GO_CONFIRM
;     Case "OPENFAVFILE"
;       nX32Command = #SCS_X32_OPEN_FAV_FILE
  EndSelect
  ProcedureReturn nX32Command
EndProcedure

Procedure.s decodeYesNoL(nYesNo)
  Protected sYesNo.s
  
  Select nYesNo
    Case 0
      sYesNo = Lang("Common", "No")
    Default
      sYesNo = Lang("Common", "Yes")
  EndSelect
  ProcedureReturn sYesNo
EndProcedure

Procedure.s decodeMemoDispOptForPrim(nMemoDispOptForPrim)
  Protected sMemoDispOptForPrim.s
  
  Select nMemoDispOptForPrim
    Case #SCS_MEMO_DISP_PRIM_POPUP
      sMemoDispOptForPrim = "Popup"
    Case #SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST
      sMemoDispOptForPrim = "ShareCueList"
    Case #SCS_MEMO_DISP_PRIM_SHARE_MAIN
      sMemoDispOptForPrim = "ShareMain"
    Default
      sMemoDispOptForPrim = Str(nMemoDispOptForPrim)
  EndSelect
  ProcedureReturn sMemoDispOptForPrim
EndProcedure

Procedure.s decodeMemoDispOptForPrimL(nMemoDispOptForPrim)
  ProcedureReturn Lang("WEP", "Memo" + decodeMemoDispOptForPrim(nMemoDispOptForPrim))
EndProcedure

Procedure encodeMemoDispOptForPrim(sMemoDispOptForPrim.s)
  Protected nMemoDispOptForPrim
  
  Select sMemoDispOptForPrim
    Case "Popup"
      nMemoDispOptForPrim = #SCS_MEMO_DISP_PRIM_POPUP
    Case "ShareCueList"
      nMemoDispOptForPrim = #SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST
    Case "ShareMain"
      nMemoDispOptForPrim = #SCS_MEMO_DISP_PRIM_SHARE_MAIN
  EndSelect
  ProcedureReturn nMemoDispOptForPrim
EndProcedure

Procedure getAbsTime(pAudPtr, pField.s, pLoopInfoIndex=0, bPrimaryFile=#True)
  Protected nTmp
  
  If bPrimaryFile
    With aAud(pAudPtr)
      Select pField
        Case "ST"
          nTmp = \nStartAt
        Case "LS"
          nTmp = \aLoopInfo(pLoopInfoIndex)\nLoopStart
        Case "LE"
          nTmp = \aLoopInfo(pLoopInfoIndex)\nLoopEnd
          If (nTmp = -2) And (\aLoopInfo(pLoopInfoIndex)\bContainsLoop) ; 29Jun2017 11.6.3ab: changed (\nLoopStart >= 0) to (\bContainsLoop)
            nTmp = (\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
          EndIf
        Case "EN"
          nTmp = \nEndAt
          If nTmp = -2
            If \nFileFormat = #SCS_FILEFORMAT_PICTURE
              nTmp = #SCS_CONTINUOUS_END_AT
            Else
              nTmp = (\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
            EndIf
          EndIf
      EndSelect
      If nTmp = -1
        nTmp = \nEndAt
        If nTmp = -2
          If \nFileFormat = #SCS_FILEFORMAT_PICTURE
            nTmp = #SCS_CONTINUOUS_END_AT
          Else
            nTmp = (\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
          EndIf
        EndIf
      ElseIf nTmp = -3
        nTmp = \nStartAt
      EndIf
    EndWith
  Else
    With a2ndAud(pAudPtr)
      Select pField
        Case "ST"
          nTmp = \nStartAt
        Case "LS"
          nTmp = \aLoopInfo(pLoopInfoIndex)\nLoopStart
        Case "LE"
          nTmp = \aLoopInfo(pLoopInfoIndex)\nLoopEnd
          If (nTmp = -2) And (\aLoopInfo(pLoopInfoIndex)\bContainsLoop) ; 29Jun2017 11.6.3ab: changed (\nLoopStart >= 0) to (\bContainsLoop)
            nTmp = (\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
          EndIf
        Case "EN"
          nTmp = \nEndAt
          If nTmp = -2
            If \nFileFormat = #SCS_FILEFORMAT_PICTURE
              nTmp = #SCS_CONTINUOUS_END_AT
            Else
              nTmp = (\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
            EndIf
          EndIf
      EndSelect
      If nTmp = -1
        nTmp = \nEndAt
        If nTmp = -2
          If \nFileFormat = #SCS_FILEFORMAT_PICTURE
            nTmp = #SCS_CONTINUOUS_END_AT
          Else
            nTmp = (\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
          EndIf
        EndIf
      ElseIf nTmp = -3
        nTmp = \nStartAt
      EndIf
    EndWith
  EndIf
  If nTmp = -2
    nTmp = 0
  EndIf
  
  ProcedureReturn nTmp

EndProcedure

Procedure getCuePtr(sCue.s)
  PROCNAMEC()
  Protected nCuePtr, i

  nCuePtr = -1
  If sCue
    For i = 1 To gnLastCue
      If UCase(aCue(i)\sCue) = UCase(sCue)
        nCuePtr = i
        Break
      EndIf
    Next i
  EndIf
  ProcedureReturn nCuePtr
EndProcedure

Procedure getCuePtr2(sCue.s)
  PROCNAMEC()
  Protected nCuePtr, i
  
  nCuePtr = -1
  If sCue
    For i = 1 To gn2ndLastCue
      If UCase(a2ndCue(i)\sCue) = UCase(sCue)
        nCuePtr = i
        Break
      EndIf
    Next i
  EndIf
  ProcedureReturn nCuePtr
EndProcedure

Procedure getAudPtrForAudNo(nSubPtr, nAudNo)
  PROCNAMEC()
  Protected k, nAudPtr = -1
  
  k = aSub(nSubPtr)\nFirstAudIndex
  While k >= 0
    If aAud(k)\nAudNo = nAudNo
      nAudPtr = k
      Break
    EndIf
    k = aAud(k)\nNextAudIndex
  Wend
  ProcedureReturn nAudPtr
EndProcedure

Procedure.s getErrorInfo()
  Protected sMsg.s
  
  sMsg = ErrorMessage() + " File: " + ErrorFile() + ", Line: " + ErrorLine()
  ProcedureReturn sMsg
  ; ProcedureReturn Str(GetErrorNumber()) + "  " + GetErrorDescription()
EndProcedure

Procedure getGridHeaderHeight(nGadgetNo)
  PROCNAMEC()
  Protected headerhWnd
  Protected nHeaderHeight
  Protected rc.RECT
  
  headerhWnd = SendMessage_(GadgetID(nGadgetNo), #LVM_GETHEADER, 0, 0)
  GetClientRect_(headerhWnd, rc.RECT)
  nHeaderHeight = rc\bottom

  ProcedureReturn nHeaderHeight
  
EndProcedure

Procedure getGridRowHeight(nGadgetNo)
  PROCNAMEC()
  Protected nRowHeight
  Protected rc.RECT
  
  rc.rect\left = #LVIR_BOUNDS
  SendMessage_(GadgetID(nGadgetNo), #LVM_GETITEMRECT, 0, rc)
  nRowHeight = rc\bottom - rc\top + 1
  
  ProcedureReturn nRowHeight
  
EndProcedure

Procedure resizeGridForRows(nGadgetNo, nRows, nMaxHeight, nTop=-9999)
  PROCNAMEC()
  Protected nMyRows, nHeaderHeight, nRowHeight, nCalcHeight, nCurrTop, nReqdTop
  
  If IsGadget(nGadgetNo)
    nCurrTop = GadgetY(nGadgetNo)
    If nTop = -9999
      nReqdTop = nCurrTop
    Else
      nReqdTop = nTop
    EndIf
    nHeaderHeight = getGridHeaderHeight(nGadgetNo)
    nRowHeight = getGridRowHeight(nGadgetNo)
    nMyRows = nRows
    If nMyRows < 0
      nMyRows = CountGadgetItems(nGadgetNo)
    EndIf
    nCalcHeight = nHeaderHeight + (nRowHeight * nMyRows)
    ; debugMsg0(sProcName, "nHeaderHeight=" + nHeaderHeight + ", nRowHeight=" + nRowHeight + ", nCalcHeight=" + nCalcHeight)
    If nCalcHeight > nMaxHeight
      nCalcHeight = nMaxHeight
    EndIf
    If nCalcHeight <> GadgetHeight(nGadgetNo) Or nReqdTop <> nCurrTop
      ; debugMsg0(sProcName, "calling ResizeGadget(" + getGadgetName(nGadgetNo) + ", #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nCalcHeight + ")")
      ResizeGadget(nGadgetNo, #PB_Ignore, nReqdTop, #PB_Ignore, nCalcHeight)
    EndIf
  EndIf
  
EndProcedure

Procedure getGridRowInfo(nGadgetNo)
  PROCNAMEC()
  Protected nRowHeight
  
  ; debugMsg(sProcName, #SCS_START + ", nGadgetNo=G" + nGadgetNo)
  
  With grGridRowInfo
    \nSelectedRow = GetGadgetState(nGadgetNo)
    \nFirstRowVisible = 0
    \nLastRowVisible = 0
    \nMaxRowsVisible = 0
    
    If CountGadgetItems(nGadgetNo) < 1
      ProcedureReturn
    EndIf
    
    nRowHeight = getGridRowHeight(nGadgetNo)
    \nMaxRowsVisible = Round(GadgetHeight(nGadgetNo) / nRowHeight, #PB_Round_Down) - 1  ; minus 1 to allow for header
    ; debugMsg(sProcName, "GadgetHeight(" + getGadgetName(nGadgetNo) + ")=" + GadgetHeight(nGadgetNo) + ", nRowHeight=" + nRowHeight + ", \nMaxRowsVisible=" + \nMaxRowsVisible)
    
    \nFirstRowVisible = SendMessage_(GadgetID(nGadgetNo), #LVM_GETTOPINDEX, 0, 0)
    \nLastRowVisible = \nFirstRowVisible + \nMaxRowsVisible - 1
    If \nLastRowVisible > CountGadgetItems(nGadgetNo)
      \nLastRowVisible = CountGadgetItems(nGadgetNo)
    EndIf
    ; debugMsg(sProcName, "\nFirstRowVisible=" + \nFirstRowVisible + ", \nMaxRowsVisible=" + \nMaxRowsVisible + ", \nLastRowVisible=" + \nLastRowVisible)
  EndWith
  
EndProcedure

Procedure getSubPtrForSubRef(pSubRef)
  PROCNAMEC()
  Protected nSubPtr, j

  ; debugMsg(sProcName, #SCS_START + ", pSubRef=" + pSubRef)
  nSubPtr = -1
  For j = 1 To gnLastSub
    ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bExists=" + strB(aSub(j)\bExists) + ", \nSubRef=" + aSub(j)\nSubRef)
    If aSub(j)\bExists
      If aSub(j)\nSubRef = pSubRef
        nSubPtr = j
        Break
      EndIf
    EndIf
  Next j
  ProcedureReturn nSubPtr
EndProcedure

Procedure getSubPtrForCueSubNo(pCuePtr, pSubNo)
  PROCNAMEC()
  Protected nSubPtr, j
  
  nSubPtr = -1
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If aSub(j)\nSubNo = pSubNo
      nSubPtr = j
      Break
    EndIf
    j = aSub(j)\nNextSubIndex
  Wend
  ProcedureReturn nSubPtr
  
EndProcedure

Procedure hexToDec(pHex.s)
  Protected sHex.s, nDec

  sHex = LCase(pHex)
  If sHex <= "9"
    nDec = Val(sHex)
  Else
    Select sHex
      Case "a": nDec = 10
      Case "b": nDec = 11
      Case "c": nDec = 12
      Case "d": nDec = 13
      Case "e": nDec = 14
      Case "f": nDec = 15
    EndSelect
  EndIf
  ProcedureReturn nDec
EndProcedure

Procedure.s hexStringToString(pHexString.s)
  PROCNAMEC()
  Protected n, nChar, sMyString.s
  
  ; debugMsg(sProcName, "Len(pHexString)=" + Len(pHexString) + ", pHexString=" + pHexString)
  For n = 1 To Len(pHexString) Step 2
    nChar = hexToDec(Mid(pHexString, n, 1)) * 16
    nChar + hexToDec(Mid(pHexString, n + 1, 1))
    sMyString + Chr(nChar)
    ; debugMsg(sProcName, "n=" + n + ", nChar=" + nChar + ", Chr(nChar)=" + Chr(nChar))
    ; debugMsg(sProcName, "Len(sMyString)=" + Len(sMyString) + ", sMyString=" + sMyString)
  Next n
  ProcedureReturn sMyString
EndProcedure

Procedure hexStringToBuffer(pHexString.s, *pBuffer, pMaxLen)
  PROCNAMEC()
  Protected n, nChar
  Protected nBufLen
  
  debugMsg(sProcName, "Len(pHexString)=" + Len(pHexString) + ", pHexString=" + pHexString)
  For n = 1 To Len(pHexString) Step 2
    nChar = hexToDec(Mid(pHexString, n, 1)) * 16
    nChar + hexToDec(Mid(pHexString, n + 1, 1))
    If nBufLen < pMaxLen
      PokeB(*pBuffer+nBufLen, nChar)
      nBufLen + 1
    EndIf
    ; debugMsg(sProcName, "n=" + n + ", nChar=" + nChar + ", nBufLen=" + nBufLen)
  Next n
  ProcedureReturn nBufLen
EndProcedure

Procedure.s bufferToHexString(*pBuffer, pBufLen, pSeparator.s="")
  Protected sMyString.s
  Protected n
  Protected nByte.b
  
  For n = 0 To (pBufLen-1)
    If n > 0
      sMyString + pSeparator
    EndIf
    nByte = PeekB(*pBuffer+n)
    sMyString + RSet(Hex(nByte,#PB_Byte),2,"0")
  Next n
  ProcedureReturn sMyString
EndProcedure

Procedure.s bufferToAsciiString(*pBuffer, pBufLen)
  Protected sMyString.s, n, nAsc.b, sChar.s
  Static sStdChars.s = "NUL,SOH,STX,ETX,EOT,ENQ,ACK,BEL,BS,TAB,LF,VT,FF,CR,SO,SI,DLE,DC1,DC2,DC3,DC4,NAK,SYN,ETB,CAN,EM,SUB,ESC,FS,GS,RS,US"
  
  For n = 0 To (pBufLen-1)
    nAsc = PeekA(*pBuffer+n)
    If nAsc < 32 And nAsc >= 0
      sChar = "<" + StringField(sStdChars, (nAsc+1), ",") + ">"
    ElseIf nAsc < 0
      sChar = "$" + Hex(nAsc, #PB_Byte)
    Else
      sChar = Chr(nAsc)
    EndIf
    sMyString + sChar
  Next n
  ProcedureReturn sMyString
EndProcedure

Procedure.s bufferToUTF8String(*pBuffer, pBufLen)
  Protected sTempString.s, sMyString.s, n, nByte.b, sChar.s
  Static sStdChars.s = "NUL,SOH,STX,ETX,EOT,ENQ,ACK,BEL,BS,TAB,LF,VT,FF,CR,SO,SI,DLE,DC1,DC2,DC3,DC4,NAK,SYN,ETB,CAN,EM,SUB,ESC,FS,GS,RS,US"
  
  sTempString = PeekS(*pBuffer, pBufLen, #PB_UTF8)
  For n = 1 To Len(sTempString)
    nByte = Asc(Mid(sTempString, n, 1))
    ; Debug "nByte=" + nByte
    If nByte < 32 And nByte >= 0
      sChar = "<" + StringField(sStdChars, (nByte+1), ",") + ">"
    Else
      sChar = Mid(sTempString, n, 1)
    EndIf
    sMyString + sChar
  Next n
  ProcedureReturn sMyString
EndProcedure

Procedure.s hex2(aByte.a)
  ProcedureReturn RSet(Hex(aByte), 2, "0")
EndProcedure

Procedure.s hex6(nNumber)
  ; designed for color codes
  ProcedureReturn RSet(Hex(nNumber), 6, "0")
EndProcedure

Procedure.s revStr(pString.s)
  Protected sString.s
  Protected n

  For n = Len(pString) To 1 Step -1
    sString + Mid(pString, n, 1)
  Next n
  ProcedureReturn sString
EndProcedure

Procedure icu(sUN.s, sAS.s)
  ; PROCNAMEC()
  Protected bResult = #True
  Protected i, sChar.s, sUserName.s
  Protected nAscii.w
  Protected nAscA.w, nAscZ.w, nAsc0.w, nAsc9.w
  
  nAscA = Asc("A")
  nAscZ = Asc("Z")
  nAsc0 = Asc("0")
  nAsc9 = Asc("9")
  
  ; remove spaces and any other non-numeric, non-alphabetic characters
  sUserName = ""
  For i = 1 To Len(sUN)
    sChar = UCase(Mid(sUN, i, 1))
    nAscii = Asc(sChar)
    If (nAscii >= nAscA And nAscii <= nAscZ) Or (nAscii >= nAsc0 And nAscii <= nAsc9)
      sUserName = sUserName + sChar
    EndIf
  Next i
  
  ; debugMsg(sProcName, revStr(stringToHexString("thebitterend"))))
  If revStr(stringToHexString(LCase(sUserName))) = "46E656275647479626568647"
    bResult = #False
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure.s panSingleToString(nPanSingle.f)
  ProcedureReturn Trim(StrF((nPanSingle * 500) + 500, 0))
EndProcedure

Procedure panToSliderValue(nPanSingle.f)
  ProcedureReturn (nPanSingle * 500) + 500
EndProcedure

Procedure.f panSliderValToSingle(nPan)
  ProcedureReturn (nPan - 500) / 500
EndProcedure

Procedure.s traceLevel(fBVLevel.f)
  If fBVLevel = #SCS_NOVOLCHANGE_SINGLE
    ProcedureReturn "(no change)"
  Else
    ProcedureReturn formatLevel(fBVLevel) + " (" + convertBVLevelToDBString(fBVLevel) + "dB)"
  EndIf
EndProcedure

Procedure.s traceLevel2(fBVLevel.f, fMinBVLevel.f, fMaxBVLevel.f)
  If fBVLevel = #SCS_NOVOLCHANGE_SINGLE
    ProcedureReturn "(no change)"
  Else
    ProcedureReturn formatLevel(fBVLevel) + " (" + convertBVLevelToDBString(fBVLevel) + "dB)"
  EndIf
EndProcedure

Procedure.s tracePan(fPan.f)
  If fPan = #SCS_NOPANCHANGE_SINGLE
    ProcedureReturn "(no change)"
  Else
    ProcedureReturn formatPan(fPan) + " (" + panSingleToString(fPan) + ")"
  EndIf
EndProcedure

Procedure.s intToStrBWZ(nValue)
  PROCNAMEC()
  If nValue = 0
    ProcedureReturn ""
  Else
    ProcedureReturn Str(nValue)
  EndIf
EndProcedure

Procedure.s portIntToStr(nPort)
  PROCNAMEC()
  If nPort = -2   ; -2 = blank
    ProcedureReturn ""
  Else
    ProcedureReturn Str(nPort)
  EndIf
EndProcedure

Procedure portStrToInt(sPort.s)
  If Len(Trim(sPort)) = 0
    ProcedureReturn -2
  Else
    ProcedureReturn Val(Trim(sPort))
  EndIf
EndProcedure

Procedure MsgBoxOrValMsg(sPrompt.s, nFlags=#PB_MessageRequester_Ok, sTitle.s="")
  PROCNAMEC()
  debugMsg(sProcName, "sPrompt=" + sPrompt)
  debugMsg(sProcName, "sTitle=" + sTitle)
  If gbNoWait
    gnValMsgCount = gnValMsgCount + 1
    ReDim gaValMsg.s(gnValMsgCount)
    gaValMsg(gnValMsgCount) = sPrompt
  Else
    ensureSplashNotOnTop()
    scsMessageRequester(sTitle, sPrompt, nFlags)
  EndIf
EndProcedure

Procedure getMouseCursor()
  ProcedureReturn gnCurrMouseCursor
EndProcedure

Procedure setMouseCursor(nCursorType)
  PROCNAMEC()
  Protected nActiveWindow
  
  If nCursorType <> gnCurrMouseCursor
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      
      ; nCursorType values:
      #IDC_ARROW = 32512
      #IDC_IBEAM = 32513
      #IDC_WAIT = 32514
      #IDC_CROSS = 32515
      #IDC_UPARROW = 32516
      #IDC_SIZE = 32640
      #IDC_ICON = 32641
      #IDC_SIZENWSE = 32642
      #IDC_SIZENESW = 32643
      #IDC_SIZEWE = 32644
      #IDC_SIZENS = 32645
      #IDC_SIZEALL = 32646
      #IDC_NO = 32648
      #IDC_HAND = 32649
      #IDC_APPSTARTING = 32650
      #IDC_HELP = 32651
      
      nActiveWindow = GetActiveWindow()
      ; debugMsg(sProcName, "nActiveWindow=" + nActiveWindow + ", nCursorType=" + nCursorType + ", gnCurrMouseCursor=" + gnCurrMouseCursor)
      
      If IsWindow(nActiveWindow) = #False
        ; no active window - probably because another application has focus - so try again after 1 second
        samAddRequest(#SCS_SAM_SET_MOUSE_CURSOR, nCursorType, 0, 0, "", ElapsedMilliseconds()+1000)
        ProcedureReturn
      EndIf
      
      If nCursorType = 0
        gnCurrMouseCursor = #IDC_ARROW
      Else
        gnCurrMouseCursor = nCursorType
      EndIf
      
      SetClassLong_(WindowID(nActiveWindow),#GCL_HCURSOR,LoadCursor_(0,gnCurrMouseCursor))
      
    CompilerElse
      gnCurrMouseCursor = nCursorType
      
    CompilerEndIf
  EndIf
  
EndProcedure

Procedure setMouseCursorBusy()
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    setMouseCursor(#IDC_WAIT)
  CompilerEndIf
EndProcedure

Procedure setMouseCursorNormal()
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    setMouseCursor(#IDC_ARROW)
  CompilerEndIf
EndProcedure

Procedure selectWholeField(hTxtField)
  SendMessage_(GadgetID(hTxtField),#EM_SETSEL,0,-1) 
EndProcedure

Procedure setFileSave(bSkipEditorProcessing=#False)
  PROCNAMEC()
  Static bInSetFileSave
  
  ; debugMsg(sProcName, #SCS_START + ", bSkipEditorProcessing=" + strB(bSkipEditorProcessing))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    If bSkipEditorProcessing = #False
      gqMainThreadRequest | #SCS_MTH_CALL_SETFILESAVE
      ProcedureReturn
    EndIf
  EndIf
  
  If bInSetFileSave
    ; debugMsg(sProcName, "exiting because bInSetFileSave=#True")
    ProcedureReturn
  EndIf
  bInSetFileSave = #True
  
  ; debugMsg(sProcName, "calling WMN_buildPopupMenu_SaveFile()")
  WMN_buildPopupMenu_SaveFile()
  
  If bSkipEditorProcessing = #False
    If IsWindow(#WED)
      ; debugMsg(sProcName, "calling WED_setEditorButtons()")
      WED_setEditorButtons()
    EndIf
  EndIf
  
  bInSetFileSave = #False
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure validateCBOField(hComboBox, pPrompt.s)
  PROCNAMEC()
  ; if valid returns ListIndex, else returns #SCS_CBO_ENTRY_INVALID
  Protected sMsg.s 
  Protected nListCount
  Protected sLowest.s, sHighest.s
  Protected sField.s, sTmp.s, n
  Protected nListIndex
  Protected bValidationOK
  Protected sItem.s
  
  debugMsg(sProcName, #SCS_START + ", hComboBox=" + getGadgetName(hComboBox))
  
  bValidationOK = #False
  While #True   ; dummy loop to allow 'Break' instead of 'GoTo'
    
    nListIndex = -1
    sField = Trim(UCase(GetGadgetText(hComboBox)))
    debugMsg(sProcName, "sField=" + sField)
    
    nListCount = CountGadgetItems(hComboBox)
    debugMsg(sProcName, "nListCount=" + nListCount)
    If nListCount = 0
      Break
    EndIf
    
    nListIndex = indexForComboBoxRow(hComboBox, UCase(sField), -1, #True)
    debugMsg(sProcName, "indexForComboBoxRow() returned " + nListIndex)
    If nListIndex <> -1
      ; value found in list, so no need to check range
      bValidationOK = #True
      Break
    EndIf
    ; try with hex notation
    If Len(sField) > 1
      If Right(sField,1) = "H"
        nListIndex = -1
        For n = 0 To CountGadgetItems(hComboBox)-1
          sItem = GetGadgetItemText(hComboBox, n)
          If FindString(sItem, sField)
            nListIndex = n
            bValidationOK = #True
            Break
          EndIf
        Next n
        debugMsg(sProcName, "after hex check, nListIndex=" + nListIndex)
        If bValidationOK
          Break
        EndIf
      EndIf
    EndIf
    
    If Trim(GetGadgetItemText(hComboBox,0))
      sTmp = Trim(GetGadgetItemText(hComboBox,0))
      sLowest = ReplaceString(sTmp, "  ", " ")
      
    ElseIf nListCount = 1
      Break
      
    ElseIf Trim(GetGadgetItemText(hComboBox,1))
      sTmp = Trim(GetGadgetItemText(hComboBox,1))
      sLowest = ReplaceString(sTmp, "  ", " ")
    EndIf
    
    sTmp = Trim(GetGadgetItemText(hComboBox,CountGadgetItems(hComboBox) - 1))
    sHighest = ReplaceString(sTmp, "  ", " ")
    
    ensureSplashNotOnTop()
    sMsg = Lang("Common","TheValueIn")+" '"+pPrompt+"' ("+sField+") "+Lang("Common","MustBeBetween")+" "+sLowest+" "+Lang("Common","And")+" "+sHighest
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    Break
    
  Wend

  debugMsg(sProcName, "bValidationOK=" + strB(bValidationOK) + ", nListIndex=" + nListIndex)
  If bValidationOK
    ProcedureReturn nListIndex
  Else
    ProcedureReturn #SCS_CBO_ENTRY_INVALID
  EndIf

EndProcedure

Procedure validateNumberField(pField.s)
  PROCNAMEC()
  Protected bNumberOK
  Protected sField.s, sChar.s
  Protected n, nFieldLength, nDotCount
  
  sField = Trim(pField)
  nFieldLength = Len(sField)
  
  bNumberOK = #True
  For n = 1 To nFieldLength
    sChar = Mid(sField,n,1)
    Select sChar
      Case "+", "-"
        If n > 1
          bNumberOK = #False
        EndIf
      Case ".", ","
        nDotCount + 1
      Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
        ; OK
      Default
        ; anything else
        bNumberOK = #False
    EndSelect
    If bNumberOK = #False
      Break
    EndIf
  Next n
  
  If nDotCount > 1
    bNumberOK = #False
  EndIf
  
  ProcedureReturn bNumberOK
  
EndProcedure

Procedure validateTimeField(pField.s, pPrompt.s, pStartOk, pEndOk, pRefTime=0, bZeroOK=#False, bThousandths=#False, bTenths=#False, bRelative=#False, bNegativeOK=#False)
  ; NB bRelative and bNegativeOK are mutually exclusive
  ; bNegativeOK was added for M2T to support a negative M2T, which means time from end
  PROCNAMEC()
  Protected nTmpTime, sMyString.s, sLower.s, sMsg.s
  Protected sMinutes.s, sSeconds.s
  Protected nMinutes, nSeconds
  Protected nColonPtr, nDotPtr
  Protected nValidationFailPoint
  Protected nDotCount, sTmp.s, sSign.s
  
  sMyString = Trim(pField)
  
  debugMsg(sProcName, "pField=" + pField + ", sMyString=" + sMyString + ", bZeroOK=" + strB(bZeroOK) + ", bThousandths=" + strB(bThousandths) + ", bTenths=" + strB(bTenths) + ", bRelative=" + strB(bRelative) + ", bNegativeOK=" + strB(bNegativeOK))
  
  ; mod to allow "." instead of ":" as per Stas Ushomirsky's Feature Request "Time fields: Allow period instead of colon", 16 Nov 2013
  ; examples from this Feature Request:
  ;   .8 ==> interpret as 0:00:800 (this already works)
  ;   25 ==> interpret as 0:25.00 (this already works)
  ;   1.41 ==> interpret as 0:01.410 (this already works)
  ;   2.1.7 ==> interpret as 2:01.700 (this is the proposed new behavior)
  ; so if the field has two or more dots, then all but the last dot are to be converted to colons
  nDotCount = CountString(sMyString, ".")
  If nDotCount > 1
    sTmp = ReplaceString(sMyString, ".", ":", 0, 1, (nDotCount-1))
    sMyString = sTmp
  EndIf
  ; end of mod to allow "." instead of ":"
  
  While #True
    If sMyString
      sSign = ""
      If bRelative
        sSign = Left(sMyString,1)
        If sSign = "-" Or sSign = "+"
          sMyString = Mid(sMyString,2)
        Else
          nValidationFailPoint = 7
          debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", sMyString=" + sMyString)
          Break
        EndIf
      ElseIf bNegativeOK
        If Left(sMyString,1) = "-"
          sSign = "-"
          sMyString = Mid(sMyString,2)
        EndIf
      EndIf
      sLower = LCase(sMyString)
      If (sLower = "end" Or sLower = "e") And (pEndOk)
        gsTmpString = "end"
      ElseIf (sLower = "start" Or sLower = "s") And (pStartOk)
        gsTmpString = "start"
      Else
        nColonPtr = FindString(sMyString, ":", 1)
        nDotPtr = FindString(sMyString, ".", 1)
        ; debugMsg(sProcName, "nColonPtr=" + nColonPtr + ", nDotPtr=" + nDotPtr)
        If nColonPtr = 0
          If sMyString = "."
            nTmpTime = 0
          Else
            If IsNumeric(sMyString) = #False
              nValidationFailPoint = 1
              debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", sMyString=" + sMyString)
              Break
            EndIf
;             nTmpTime = Int(ValF(sMyString) * 1000)
            nTmpTime = (ValF(sMyString) * 1000) ; 31Jan2017 11.6.0 removed Int() around expression as "0.334" got rounded down to 0.333 (when using Int())
          EndIf
        Else
          If nDotPtr > 0
            If (nDotPtr < nColonPtr) Or (nDotPtr > (nColonPtr + 3))
              nValidationFailPoint = 2
              debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", nDotPtr=" + nDotPtr + ", nColonPtr=" + nColonPtr)
              Break
            EndIf
          EndIf
          sMinutes = Left(sMyString, nColonPtr - 1)
          ; debugMsg(sProcName, "sMinutes=" + sMinutes)
          If Len(sMinutes) = 0
            nMinutes = 0
          Else
            If IsInteger(sMinutes) = #False
              nValidationFailPoint = 3
              debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", sMinutes=" + sMinutes)
              Break
            EndIf
            nMinutes = Val(sMinutes)
          EndIf
          sSeconds = Right(sMyString, Len(sMyString) - nColonPtr)
          ; debugMsg(sProcName, "sSeconds=" + sSeconds + ", sMyString=" + sMyString + ", Len(sMyString)=" + Len(sMyString) + ", nColonPtr=" + nColonPtr)
          If Len(sSeconds) = 0 Or (Len(sSeconds) = 1 And nDotPtr > 0)
            nSeconds = 0
          Else
            If IsNumeric(sSeconds) = #False
              nValidationFailPoint = 4
              debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", sSeconds=" + sSeconds)
              Break
            EndIf
            ; nSeconds = Int(ValF(sSeconds) * 1000)
            nSeconds = (ValF(sSeconds) * 1000)  ; 31Jan2017 11.6.0 removed Int() around expression
          EndIf
          If nSeconds > 60000
            nValidationFailPoint = 5
            debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", nSeconds=" + nSeconds)
            Break
          EndIf
          nTmpTime = (nMinutes * 60000) + nSeconds
        EndIf
        
        If nTmpTime < 0
          nValidationFailPoint = 6
          debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint + ", nTmpTime=" + nTmpTime)
          Break
        EndIf
        
        If bThousandths
          If bZeroOK
            gsTmpString = timeToStringT(nTmpTime, pRefTime)
          Else
            gsTmpString = timeToStringBWZT(nTmpTime, pRefTime)
          EndIf
          ; debugMsg(sProcName, "pField=" + pField + ", nTmpTime=" + nTmpTime + ", pRefTime=" + pRefTime + ", gsTmpString=" + gsTmpString)
        ElseIf bTenths
          If bZeroOK
            gsTmpString = timeToStringD(nTmpTime, pRefTime)
          Else
            gsTmpString = timeToStringBWZD(nTmpTime, pRefTime)
          EndIf
        Else
          If bZeroOK
            gsTmpString = timeToString(nTmpTime, pRefTime)
          Else
            gsTmpString = timeToStringBWZ(nTmpTime, pRefTime)
          EndIf
        EndIf
      EndIf
      If bRelative Or bNegativeOK
        gsTmpString = sSign + gsTmpString
      EndIf
    Else
      gsTmpString = ""
    EndIf
    Break
  Wend
  ; debugMsg(sProcName, "gsTmpString=" + gsTmpString)
  
  If nValidationFailPoint = 0
    ProcedureReturn #True
  Else
    ensureSplashNotOnTop()
    If nValidationFailPoint = 7
      sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + Lang("Errors", "MustStartWithPlusOrMinus")
    Else
      Select sLower
        Case "end", "e", "start", "s"
          sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + Lang("Common", "NotValidForField")
        Default
          sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + Lang("Common", "NotValidForTime")
      EndSelect
    EndIf
    debugMsg(sProcName, sMsg)
    debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint)
    ; Debug "calling MessageRequester, sMsg=" + sMsg
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ; Debug "returned from MessageRequester"
    ProcedureReturn #False
  EndIf

EndProcedure

Procedure validateTimeFieldT(pField.s, pPrompt.s, pStartOk, pEndOk, pRefTime=0, bZeroOK=#False, bRelative=#False, bNegativeOK=#False)
  ; calls validateTimeField() with bThousandths=#True
  ProcedureReturn validateTimeField(pField, pPrompt, pStartOk, pEndOk, pRefTime, bZeroOK, #True, #False, bRelative, bNegativeOK)
EndProcedure

Procedure validateTimeFieldD(pField.s, pPrompt.s, pStartOk, pEndOk, pRefTime=0, bZeroOK=#False, bRelative=#False, bNegativeOK=#False)
  ; calls validateTimeField() with bTenths=#True
  ProcedureReturn validateTimeField(pField, pPrompt, pStartOk, pEndOk, pRefTime, bZeroOK, #False, #True, bRelative, bNegativeOK)
EndProcedure

Procedure validateDbChangeField(pField.s, pPrompt.s)
  PROCNAMEC()
  Protected fTmpDb.f, sdB.s, sMsg.s
  Protected nValidationFailPoint
  
  gsTmpString = ""
  While #True
    sdB = Trim(pField)
    If sdB = "0"
      fTmpDb = 0.0
      Break
    ElseIf sdB
      If (Left(sdB, 1) <> "+") And (Left(sdB, 1) <> "-")
        ; sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") must start with + (to increase the level) or - (to decrease the level)"
        sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + Lang("Errors", "MustStartWithPlusOrMinus")
        nValidationFailPoint = 1
        Break
      EndIf
      If validateNumberField(sdB) = #False
        nValidationFailPoint = 2
        Break
      EndIf
      fTmpDb = ValF(sdB)
    EndIf
    Break
  Wend
  
  If nValidationFailPoint = 0
    gsTmpString = StrF(fTmpDb,1)
    ProcedureReturn #True
  Else
    ensureSplashNotOnTop()
    If Len(sMsg) = 0
      sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") is not valid for a dB level change field"
    EndIf
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure validateDbIncrementField(pField.s, pPrompt.s)
  PROCNAMEC()
  Protected fTmpDb.f, sdB.s, sMsg.s
  Protected nValidationFailPoint
  
  gsTmpString = ""
  While #True
    sdB = Trim(pField)
    If sdB = "0"
      fTmpDb = 0.0
      Break
    ElseIf sdB
      If validateNumberField(sdB) = #False
        nValidationFailPoint = 2
        Break
      EndIf
      fTmpDb = ValF(sdB)
      ; ignore negative sign - convert to positive
      If fTmpDb < 0
        fTmpDb = 0 - fTmpDb
      EndIf
    EndIf
    Break
  Wend
  
  If nValidationFailPoint = 0
    gsTmpString = StrF(fTmpDb,1)
    ProcedureReturn #True
  Else
    ensureSplashNotOnTop()
    If Len(sMsg) = 0
      sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") is not valid for a dB increment field"
    EndIf
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure validateDbField(pField.s, pPrompt.s, bQuiet=#False, bMinusInfOk=#True, nRemDevMsgType=0)
  PROCNAMEC()
  Protected fTmpDb.f, sdB.s, sMsg.s
  Protected nValidationFailPoint
  Static nMyRemDevMsgType=-1, fMyMinDBLevel.f, sMyMinDBLevel.s, fMyMaxDBLevel.f, sMyMaxDBLevel.s
  
  If nRemDevMsgType <> nMyRemDevMsgType
    If nRemDevMsgType = 0
      fMyMinDBLevel = grLevels\nMinDBLevel
      sMyMinDBLevel = grLevels\sMinDBLevel
      fMyMaxDBLevel = grLevels\nMaxDBLevel
      sMyMaxDBLevel = grLevels\sMaxDBLevel
    Else
      fMyMinDBLevel = CSRD_GetMinFaderLevelDBForRemDevMsgType(nRemDevMsgType)
      sMyMinDBLevel = convertDBLevelToDBString(fMyMinDBLevel)
      fMyMaxDBLevel = CSRD_GetMaxFaderLevelDBForRemDevMsgType(nRemDevMsgType)
      sMyMaxDBLevel = convertDBLevelToDBString(fMyMaxDBLevel)
    EndIf
    nMyRemDevMsgType = nRemDevMsgType
  EndIf
  
  gsTmpString = ""
  While #True
    sdB = Trim(pField)
    If sdB
      If UCase(sdB) = UCase(#SCS_INF_DBLEVEL)
        gsTmpString = #SCS_INF_DBLEVEL
      Else
        If validateNumberField(pField) = #False
          nValidationFailPoint = 1
          Break
        EndIf
        fTmpDb = ValF(sdB)
        If fTmpDb > fMyMaxDBLevel Or fTmpDb < fMyMinDBLevel
          nValidationFailPoint = 2
          Break
        EndIf
        If fTmpDb >= 0.0
          gsTmpString = "+" + StrF(fTmpDb,1)
        Else
          gsTmpString = StrF(fTmpDb,1)
        EndIf
      EndIf
    EndIf
    Break
  Wend
  
  If nValidationFailPoint = 0
    ProcedureReturn #True
  Else
    If bQuiet = #False
      ensureSplashNotOnTop()
      sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") is not valid for this dB level field." + #CRLF$ + #CRLF$ + "Please enter a dB level between " + sMyMinDBLevel + " and " + sMyMaxDBLevel
      If bMinusInfOk
        sMsg + ", or " + #SCS_INF_DBLEVEL
      EndIf
      debugMsg(sProcName, sMsg)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    EndIf
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure.f panStringToSingle(sPanString.s)
  If Len(Trim(sPanString)) = 0
    ProcedureReturn 0
  Else
    ProcedureReturn (ValF(sPanString) - 500) / 500
  EndIf
EndProcedure

Procedure validatePanTextField(pField.s, pPrompt.s)
  PROCNAMEC()
  Protected fTmp.f, sMsg.s
  
  If IsInteger(Trim(pField)) = #False
    fTmp = #SCS_MINPAN_SINGLE - 9999 ; force error
  Else
    fTmp = panStringToSingle(Trim(pField))
    debugMsg(sProcName, "pField=" + pField + ", fTmp=" + StrF(fTmp,3))
  EndIf
  If fTmp < #SCS_MINPAN_SINGLE Or fTmp > #SCS_MAXPAN_SINGLE
    ensureSplashNotOnTop()
    sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") is not a valid pan value." + #CRLF$ + #CRLF$ + "Please enter a pan value between 0 (left) and 1000 (right)."
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure validateTODField(pField.s, pPrompt.s)
  PROCNAMEC()
  Protected sString.s, sMsg.s
  Protected sHours.s, sMinutes.s, sSeconds.s
  Protected nHours, nMinutes, nSeconds
  Protected nPtr, sChar.s, sAMPM.s, nAMPtr, nPMPtr
  Protected nValidationFailPoint

  sString = ReplaceString(pField, " ", "")

  While #True
    If sString
      nPtr = FindString(sString, ":", 1)
      nAMPtr = FindString(sString, "am", 1, #PB_String_NoCase)
      nPMPtr = FindString(sString, "pm", 1, #PB_String_NoCase)
      If nPtr = 0
        If nAMPtr > 0
          sString = ReplaceString(sString, "am", ":00am", #PB_String_NoCase, 1, 1)
        Else
          If nPMPtr > 0
            sString = ReplaceString(sString, "pm", ":00pm", #PB_String_NoCase, 1, 1)
          Else
            nValidationFailPoint = 1
            Break
          EndIf
        EndIf
        nPtr = FindString(sString, ":", 1)
      EndIf
      
      sHours = Left(sString, nPtr - 1)
      If sHours
        If IsInteger(sHours) = #False
          nValidationFailPoint = 2
          Break
        EndIf
        nHours = Val(sHours)
        If (nHours > 23) Or (nHours > 12 And (nAMPtr > 0 Or nPMPtr > 0))
          nValidationFailPoint = 3
          Break
        EndIf
      EndIf
      
      nPtr + 1    ; skip over ":"
      sChar = Mid(sString, nPtr, 1)
      If sChar >= "0" And sChar <= "9"
        sMinutes = sChar
        nPtr + 1
        sChar = Mid(sString, nPtr, 1)
        If sChar >= "0" And sChar <= "9"
          sMinutes + sChar
          nPtr + 1
        EndIf
      EndIf
      
      If sMinutes
        If IsInteger(sMinutes) = #False
          debugMsg(sProcName, "sMinutes=" + sMinutes)
          nValidationFailPoint = 4
          Break
        EndIf
        nMinutes = Val(sMinutes)
        If nMinutes > 59
          nValidationFailPoint = 5
          Break
        EndIf
      EndIf
      
      If nPtr <= Len(sString)
        sChar = Mid(sString, nPtr, 1)
        If sChar = ":"
          nPtr + 1
          sChar = Mid(sString, nPtr, 1)
          If sChar >= "0" And sChar <= "9"
            sSeconds = sChar
            nPtr + 1
            sChar = Mid(sString, nPtr, 1)
            If sChar >= "0" And sChar <= "9"
              sSeconds + sChar
              nPtr + 1
            EndIf
          EndIf
        EndIf
        
        If sSeconds
          If IsInteger(sSeconds) = #False
            nValidationFailPoint = 6
            Break
          EndIf
          nSeconds = Val(sSeconds)
          If nSeconds > 59
            nValidationFailPoint = 7
            Break
          EndIf
        EndIf
        
      EndIf
      
      If nPtr <= Len(sString)
        sAMPM = UCase(Mid(sString, nPtr))
        If sAMPM <> "AM" And sAMPM <> "PM"
          nValidationFailPoint = 8
          Break
        EndIf
      EndIf
      
    Else
      gsTmpString = ""
      
    EndIf
    
    Break
  Wend
  
  If nValidationFailPoint = 0
    ProcedureReturn #True
  Else
    ensureSplashNotOnTop()
    ; sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") is not valid for a time-of-day field"
    sMsg = LangPars("Errors", "NotTimeOfDay", pPrompt, pField)
    debugMsg(sProcName, sMsg)
    debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf

EndProcedure

Procedure unpackGridLayoutString(*pGridInfo.tyGridInfo, nGridType)
  PROCNAMEC()
  Protected n, nColCount
  Protected sColEntry.s   ; structure of sColEntry: sColType:nCurWidth:nCurColNo;
  Protected sColType.s, nCurWidth, nCurColNo
  Protected nColIndex, m
  
  With *pGridInfo
    nColCount = CountString(\sLayoutString, ";") + 1
    If nColCount > 0
      ; if \sLayoutString is NOT empty then clear the default current column numbers as they may clash with real current column assignments
      For m = 0 To ArraySize(\aCol())
        \aCol(m)\nCurColNo = -1
      Next m
    EndIf
    For n = 1 To nColCount
      sColEntry = StringField(\sLayoutString, n, ";")
      sColType = StringField(sColEntry, 1, ":")
      nColIndex = -1
      For m = 0 To \nMaxColNo
        If \aCol(m)\sColType = sColType
          nColIndex = m
          Break
        EndIf
      Next m
      If nColIndex >= 0
        nCurWidth = Val(StringField(sColEntry, 2, ":"))
        nCurColNo = Val(StringField(sColEntry, 3, ":"))
        If nCurColNo >= 0
          ; ignore entry if this nCurColNo has already been used (can occur if new col added in new SCS version)
          For m = 0 To \nMaxColNo
            If (\aCol(m)\nCurColNo = nCurColNo) And (\aCol(m)\sColType <> sColType)
              ; debugMsg(sProcName, "ignore n=" + n + ", nCurColNo=" + nCurColNo + ", sColType=" + sColType + ", \aCol("+ m + ")\nCurColNo=" + \aCol(m)\nCurColNo + ", \aCol("+ m + ")\sColType=" + \aCol(m)\sColType)
              nColIndex = -1
              Break
            EndIf
          Next m
        EndIf
      EndIf
      If nColIndex >= 0
        \aCol(nColIndex)\nCurWidth = nCurWidth
        \aCol(nColIndex)\nCurColNo = nCurColNo
        ; debugMsg(sProcName, "n=" + n + ", sColEntry=" + sColEntry + ", nColIndex=" + nColIndex + ", nCurColNo=" + nCurColNo + ", \aCol(" + nColIndex + ")\nCurColNo=" + \aCol(nColIndex)\nCurColNo)
      ; Else
        ; debugMsg(sProcName, "n=" + n + ", sColEntry=" + sColEntry + ", nColIndex=" + nColIndex + ", nCurColNo=" + nCurColNo)
      EndIf
    Next n
  EndWith
  
EndProcedure

Procedure updateGridInfoFromPhysicalLayout(*pGridInfo.tyGridInfo)
  PROCNAMEC()
  Protected sMyLayoutString.s
  Protected nColIndex, nCurColNo, nColOrder
  Protected Dim aColOrder.l(0)
  Protected n, m, sColHeader.s, sColWidth.s
  Protected nNumCols.l, nColNo.l
  Protected nResult.l
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *pGridInfo
    
    ; debugMsg(sProcName, "\nMaxVisibleColNo=" + \nMaxVisibleColNo)
    If \nMaxVisibleColNo >= 0
      
      nNumCols = \nMaxVisibleColNo + 1
      
      ; setup aColOrder() with current column order, which may have been changed by the user dragging column headers
      ReDim aColOrder(\nMaxVisibleColNo)
      nResult = SendMessage_(GadgetID(\nGadgetNo), #LVM_GETCOLUMNORDERARRAY, nNumCols, @aColOrder(0))
      ; debugMsg(sProcName, "SendMessage_(GadgetID(" + getGadgetName(\nGadgetNo) + "), #LVM_GETCOLUMNORDERARRAY, " + nNumCols + ", @aColOrder(0)) returned " + nResult)
      If nResult
        
        For n = 0 To \nMaxVisibleColNo
          m = aColOrder(n)
          sColHeader = GetGadgetItemText(\nGadgetNo, -1, m)
          ; debugMsg(sProcName, "aColOrder(" + n + ")="+ m + ", sColHeader=" + sColHeader)
        Next n
        
        For nColIndex = 0 To \nMaxColNo
          nCurColNo = \aCol(nColIndex)\nCurColNo  ; nb ColNo is zero-based, ie first column is 0 (see PB help on AddGadgetColumn())
          nColOrder = -1
          If (nCurColNo >= 0) And (nCurColNo <= \nMaxVisibleColNo)
            ; column is visible
            ; get current width of displayed column
            \aCol(nColIndex)\nCurWidth = GetGadgetItemAttribute(\nGadgetNo, -1, #PB_ListIcon_ColumnWidth, nCurColNo)
            sColWidth = ", \nCurWidth=" + \aCol(nColIndex)\nCurWidth
            ; find where nCurColNo is currently displayed
            For n = 0 To \nMaxVisibleColNo
              If aColOrder(n) = nCurColNo
                nColOrder = n
                Break
              EndIf
            Next n
          Else
            ; column is not visible
            sColWidth = ""
            ; leave \aCol(nColIndex)\nCurWidth unchanged
            ; nColOrder is already -1, so no further action required
          EndIf
          \aCol(nColIndex)\nCurColOrder = nColOrder
          ; debugMsg(sProcName, "nColIndex=" + nColIndex + ", sColType=" + \aCol(nColIndex)\sColType + ", nCurColNo=" + nCurColNo + ", nColOrder=" + nColOrder + sColWidth)
          
          If nColIndex > 0
            sMyLayoutString + ";"
          EndIf
          sMyLayoutString + \aCol(nColIndex)\sColType + ":" + \aCol(nColIndex)\nCurWidth + ":" + nColOrder
          
        Next nColIndex
        
        \sLayoutString = sMyLayoutString
        ; debugMsg(sProcName, "\sLayoutString=" + \sLayoutString)
        
      EndIf
      
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure encodeFadeType(sFadeType.s)
  Protected nFadeType
  
  Select sFadeType
    Case "std"
      nFadeType = #SCS_FADE_STD
    Case "lin"
      nFadeType = #SCS_FADE_LIN
    Case "log"
      nFadeType = #SCS_FADE_LOG
    Case "linse"
      nFadeType = #SCS_FADE_LIN_SE
    Case "logse"
      nFadeType = #SCS_FADE_LOG_SE
    Case "exp"
      nFadeType = #SCS_FADE_EXP
    Default
      nFadeType = #SCS_FADE_STD
  EndSelect
  ProcedureReturn nFadeType
EndProcedure

Procedure.s decodeFadeType(nFadeType)
  Protected sFadeType.s
  
  Select nFadeType
    Case #SCS_FADE_STD
      sFadeType = "std"
    Case #SCS_FADE_LIN
      sFadeType = "lin"
    Case #SCS_FADE_LOG
      sFadeType = "log"
    Case #SCS_FADE_LIN_SE
      sFadeType = "linse"
    Case #SCS_FADE_LOG_SE
      sFadeType = "logse"
    Case #SCS_FADE_EXP
      sFadeType = "exp"
    Default
      sFadeType = "std"
  EndSelect
  ProcedureReturn sFadeType
EndProcedure

Procedure.s decodeFadeTypeL(nFadeType)
  ProcedureReturn Lang("FadeType", decodeFadeType(nFadeType))
EndProcedure

Procedure.s decodeFadeEntryType(nFadeEntryType)
  Protected sFadeEntryType.s
  
  Select nFadeEntryType
    Case #SCS_FADE_ENTRY_POS
      sFadeEntryType = "pos"
    Default
      sFadeEntryType = "time"
  EndSelect
  ProcedureReturn sFadeEntryType
EndProcedure

Procedure encodeFadeEntryType(sFadeEntryType.s)
  Protected nFadeEntryType
  
  Select sFadeEntryType
    Case "pos"
      nFadeEntryType = #SCS_FADE_ENTRY_POS
    Default
      nFadeEntryType = #SCS_FADE_ENTRY_TIME
  EndSelect
  ProcedureReturn nFadeEntryType
EndProcedure

Procedure.s decodeFadeFieldType(nFadeFieldType)
  ; only used for debugging
  Protected sFadeFieldType.s
  
  Select nFadeFieldType
    Case #SCS_FADE_IN_FIELD
      sFadeFieldType = "FadeIn"
    Case #SCS_FADE_OUT_FIELD
      sFadeFieldType = "FadeOut"
    Default
      sFadeFieldType = Str(nFadeFieldType)
  EndSelect
  ProcedureReturn sFadeFieldType
EndProcedure

Procedure.s decodeFileState(nFileState)
  Protected sDecoded.s
  
  Select nFileState
    Case #SCS_FILESTATE_CLOSED
      sDecoded = "closed"
    Case #SCS_FILESTATE_OPEN
      sDecoded = "open"
    Default
      sDecoded = Str(nFileState)
  EndSelect
  ProcedureReturn sDecoded
EndProcedure

Procedure encodeFileSelector(sFileSelector.s)
  Protected nFileSelector
  
  Select sFileSelector
    Case "scs_afs"
      nFileSelector = #SCS_FO_SCS_AFS
    Case "windows_fs"
      nFileSelector = #SCS_FO_WINDOWS_FS
  EndSelect
  ProcedureReturn nFileSelector
EndProcedure

Procedure.s decodeFileSelector(nFileSelector)
  Protected sFileSelector.s
  
  Select nFileSelector
    Case #SCS_FO_SCS_AFS
      sFileSelector = "scs_afs"
    Case #SCS_FO_WINDOWS_FS
      sFileSelector = "windows_fs"
  EndSelect
  ProcedureReturn sFileSelector
EndProcedure

Procedure encodeSetPosAbsRel(sAbsRel.s)
  Protected nAbsRel
  
  Select sAbsRel
    Case "ABS", "0"
      nAbsRel = #SCS_SETPOS_ABSOLUTE      
    Case "REL", "1"
      nAbsRel = #SCS_SETPOS_RELATIVE
    Case "CM"
      nAbsRel = #SCS_SETPOS_CUE_MARKER
    Case "BE" ; Added 7Jun2022 11.9.2
      nAbsRel = #SCS_SETPOS_BEFORE_END
  EndSelect
  ProcedureReturn nAbsRel
EndProcedure

Procedure.s decodeSetPosAbsRel(nAbsRel)
  Protected sAbsRel.s
  
  Select nAbsRel
    Case #SCS_SETPOS_ABSOLUTE
      sAbsRel = "ABS"
    Case #SCS_SETPOS_RELATIVE
      sAbsRel = "REL"
    Case #SCS_SETPOS_CUE_MARKER
      sAbsRel = "CM"
    Case #SCS_SETPOS_BEFORE_END ; Added 7Jun2022 11.9.2
      sAbsRel = "BE"
  EndSelect
  ProcedureReturn sAbsRel
EndProcedure

Procedure encodeSetPosSetPosCueType(sSetPosCueType.s)
  ; Added 7Jun2022 11.9.2
  Protected nSetPosCueType
  
  Select sSetPosCueType
    Case ""
      nSetPosCueType = #SCS_SETPOS_CUETYPE_NA
    Case "playaud"
      nSetPosCueType = #SCS_SETPOS_CUETYPE_PLAY_AUDIO
    Case "playvid"
      nSetPosCueType = #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE
  EndSelect
  ProcedureReturn nSetPosCueType
EndProcedure

Procedure.s decodeSetPosSetPosCueType(nSetPosCueType)
  ; Added 7Jun2022 11.9.2
  Protected sSetPosCueType.s
  
  Select nSetPosCueType
    Case #SCS_SETPOS_CUETYPE_NA
      sSetPosCueType = ""
    Case #SCS_SETPOS_CUETYPE_PLAY_AUDIO
      sSetPosCueType = "playaud"
    Case #SCS_SETPOS_CUETYPE_PLAY_VIDEO_IMAGE
      sSetPosCueType = "playvid"
  EndSelect
  ProcedureReturn sSetPosCueType
EndProcedure

Procedure encodeActivationMethod(sActivationMethod.s)
  Protected nActivationMethod
  
  Select sActivationMethod
    Case "man"
      nActivationMethod = #SCS_ACMETH_MAN
    Case "m+c"
      nActivationMethod = #SCS_ACMETH_MAN_PLUS_CONF
    Case "auto"
      nActivationMethod = #SCS_ACMETH_AUTO
    Case "a+c"
      nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
    Case "callq"
      nActivationMethod = #SCS_ACMETH_CALL_CUE
    Case "chase"
      nActivationMethod = #SCS_ACMETH_CHASE
    Case "hot"
      nActivationMethod = #SCS_ACMETH_HK_TRIGGER
    Case "hktg"
      nActivationMethod = #SCS_ACMETH_HK_TOGGLE
    Case "hknt"
      nActivationMethod = #SCS_ACMETH_HK_NOTE
    Case "hkst"
      nActivationMethod = #SCS_ACMETH_HK_STEP
    Case "time"
      nActivationMethod = #SCS_ACMETH_TIME
    Case "ext"
      nActivationMethod = #SCS_ACMETH_EXT_TRIGGER
    Case "extg"
      nActivationMethod = #SCS_ACMETH_EXT_TOGGLE
    Case "exnt"
      nActivationMethod = #SCS_ACMETH_EXT_NOTE
    Case "exst"
      nActivationMethod = #SCS_ACMETH_EXT_STEP
    Case "excom"
      nActivationMethod = #SCS_ACMETH_EXT_COMPLETE
    Case "extfdr"
      nActivationMethod = #SCS_ACMETH_EXT_FADER
    Case "mtc"
      nActivationMethod = #SCS_ACMETH_MTC
    Case "ltc"
      nActivationMethod = #SCS_ACMETH_LTC
    Case "ocm"
      nActivationMethod = #SCS_ACMETH_OCM
  EndSelect
  ProcedureReturn nActivationMethod
EndProcedure

Procedure.s decodeActivationMethod(nActivationMethod)
  Protected sActivationMethod.s
  
  Select nActivationMethod
    Case #SCS_ACMETH_MAN
      sActivationMethod = "man"
    Case #SCS_ACMETH_MAN_PLUS_CONF
      sActivationMethod = "m+c"
    Case #SCS_ACMETH_AUTO
      sActivationMethod = "auto"
    Case #SCS_ACMETH_AUTO_PLUS_CONF
      sActivationMethod = "a+c"
    Case #SCS_ACMETH_CALL_CUE
      sActivationMethod = "callq"
    Case #SCS_ACMETH_HK_TRIGGER
      sActivationMethod = "hot"
    Case #SCS_ACMETH_HK_TOGGLE
      sActivationMethod = "hktg"
    Case #SCS_ACMETH_HK_NOTE
      sActivationMethod = "hknt"
    Case #SCS_ACMETH_HK_STEP
      sActivationMethod = "hkst"
    Case #SCS_ACMETH_TIME
      sActivationMethod = "time"
    Case #SCS_ACMETH_EXT_TRIGGER
      sActivationMethod = "ext"
    Case #SCS_ACMETH_EXT_TOGGLE
      sActivationMethod = "extg"
    Case #SCS_ACMETH_EXT_NOTE
      sActivationMethod = "exnt"
    Case #SCS_ACMETH_EXT_STEP
      sActivationMethod = "exst"
    Case #SCS_ACMETH_EXT_COMPLETE
      sActivationMethod = "excom"
    Case #SCS_ACMETH_EXT_FADER
      sActivationMethod = "extfdr"
    Case #SCS_ACMETH_MTC
      sActivationMethod = "mtc"
    Case #SCS_ACMETH_LTC
      sActivationMethod = "ltc"
    Case #SCS_ACMETH_OCM
      sActivationMethod = "ocm"
    Default
      sActivationMethod = "$" + Hex(nActivationMethod)
  EndSelect
  ProcedureReturn sActivationMethod
EndProcedure

Procedure.s decodeActivationMethodL(nActivationMethod)
  ProcedureReturn Lang("WEC", "acm" + decodeActivationMethod(nActivationMethod))
EndProcedure

Procedure encodeAutoActPosn(sAutoActPosn.s)
  Protected nAutoActPosn
  
  Select sAutoActPosn
    Case "start"
      nAutoActPosn = #SCS_ACPOSN_AS
    Case "end"
      nAutoActPosn = #SCS_ACPOSN_AE
    Case "b4end"
      nAutoActPosn = #SCS_ACPOSN_BE
    Case "load"
      nAutoActPosn = #SCS_ACPOSN_LOAD
    Case "ocm" ; replaced 3Aug2019 11.8.1.3af by cue activation method #SCS_ACMETH_OCM
      nAutoActPosn = #SCS_ACPOSN_OCM
    Default
      nAutoActPosn = #SCS_ACPOSN_DEFAULT
  EndSelect
  ProcedureReturn nAutoActPosn
EndProcedure

Procedure.s decodeAutoActPosn(nAutoActPosn)
  Protected sAutoActPosn.s
  
  Select nAutoActPosn
    Case #SCS_ACPOSN_AS
      sAutoActPosn = "start"
    Case #SCS_ACPOSN_AE
      sAutoActPosn = "end"
    Case #SCS_ACPOSN_BE
      sAutoActPosn = "b4end"
    Case #SCS_ACPOSN_LOAD
      sAutoActPosn = "load"
    Case #SCS_ACPOSN_OCM ; replaced 3Aug2019 11.8.1.3af by cue activation method #SCS_ACMETH_OCM
      sAutoActPosn = "ocm"
    Default
      sAutoActPosn = ""
  EndSelect
  ProcedureReturn sAutoActPosn
EndProcedure

Procedure.s decodeStandby(nStandby)
  Protected sStandby.s
  
  Select nStandby
    Case #SCS_STANDBY_SET
      sStandby = "set"
    Case #SCS_STANDBY_CANCEL
      sStandby = "cancel"
  EndSelect
  ProcedureReturn sStandby
EndProcedure

Procedure.s decodeStandbyL(nStandby)
  Protected sStandby.s
  
  Select nStandby
    Case #SCS_STANDBY_SET
      sStandby = Lang("WEC", "StandbySet")
    Case #SCS_STANDBY_CANCEL
      sStandby = Lang("WEC", "StandbyCancel")
  EndSelect
  ProcedureReturn sStandby
EndProcedure

Procedure encodeStandby(sStandby.s)
  Protected nStandby
  
  Select sStandby
    Case "set"
      nStandby = #SCS_STANDBY_SET
    Case "cancel"
      nStandby = #SCS_STANDBY_CANCEL
  EndSelect
  ProcedureReturn nStandby
EndProcedure

Procedure getGrdCuesRedrawState()
  ProcedureReturn grWMN\bGrdCuesRedrawState
EndProcedure

Procedure setGrdCuesRedrawState(bRedrawState)
  SendMessage_(GadgetID(WMN\grdCues), #WM_SETREDRAW, bRedrawState, 0)
  grWMN\bGrdCuesRedrawState = bRedrawState
EndProcedure

Procedure.l JustifyListIconColumn(GadgetID.l,column.l,flag.l)    ;Justify ListIcon Column. flag: 0=Left 1=Right 2=Center
  ; obtained from PB Forum topic "how to align numerical cells of a ListIcon to the right?"
  Protected lvc.LV_COLUMN
  
  lvc\Mask = #LVCF_FMT 
  Select flag
    Case 1
      lvc\fmt = #LVCFMT_RIGHT
    Case 2
      lvc\fmt = #LVCFMT_CENTER
    Default
      lvc\fmt = #LVCFMT_LEFT
  EndSelect
  ProcedureReturn SendMessage_(GadgetID(GadgetID),#LVM_SETCOLUMN,column,@lvc)
EndProcedure

Procedure setCboToolTipAtSelectedText(nGadgetNo)
  Protected sToolTip.s
  Protected nListIndex
  
  If gnOperMode <> #SCS_OPERMODE_PERFORMANCE  ; test added 18Nov2016 11.5.2.4 following problem reported by Mike Pope (tooltip displaying on video screen)
    If IsGadget(nGadgetNo)
      nListIndex = GGS(nGadgetNo)
      If nListIndex >= 0
        sToolTip = GGT(nGadgetNo)
      EndIf
      GadgetToolTip(nGadgetNo, sToolTip)
    EndIf
  EndIf
EndProcedure

Procedure.f convertSizeToPercentage(nSize)
  PROCNAMEC()
  Protected fPercentage.f
  ; The size field is used in Video/Image cues and is held internally and in cue files as a value in the range -500 to +500, representing zero size to double-size.
  ; The value in the cue file was negated in CueFileHandler.pbi to comply with pre-11.2.1 cue files.
  ; For example, -100 in the cue file (meaning a reduction in size by 20%) gets converted in CueFileHandler.pbi to +100, so now we have to re-negate the value.
  
  fPercentage = ((0 - nSize) / 5) + 100
  ProcedureReturn fPercentage
  
EndProcedure

Procedure calcDisplayPosAndSize3(pAudPtr, pSourceWidth, pSourceHeight, pTargetWidth, pTargetHeight, pTarget2Width, pTarget2Height, bAllowCropping=#True, bApplyAspectRatio=#False)
  PROCNAMECA(pAudPtr)
  ; nb does NOT update anything in aAud(pAudPtr), etc, but returns results in the global structure grDPS
  Protected nMySourceWidth, nMySourceHeight, bRotatedQuarterTurn ; = pSourceWidth and pSourceHeight, or those values swapped if \nRotate = 90 or 270
  Protected nMyTargetWidth, nMyTargetHeight, nMyTarget2Width, nMyTarget2Height, bTargetsSwapped ; = pTargetWidth etc, or swapped with pTarget2 etc if pTarget2Width > pTargetWidth
  Protected nAdjXPos, nAdjYPos, fPercentage.f
  Protected nCalcMidPointX, nCalcMidPointY
  ; Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nNewMidPointX, nNewMidPointY, nNewHalfWidth, nNewHalfHeight
  Protected nNewOutsideLeft, nNewOutsideTop, nNewOutsideRight, nNewOutsideBottom
  ; Protected nAspectLeft, nAspectTop, nAspectWidth, nAspectHeight, nAspectWidthHalfDiff, nAspectHeightHalfDiff
  Protected dAspectRatioToUse.d
  Protected fRescaleWidthFactor.f, fRescaleHeightFactor.f, fRescaleFactor.f
  Protected bCropReqd, fCropWidthFactor.f, fCropHeightFactor.f
  Protected nDisplayLeft, nDisplayTop, nDisplayWidth, nDisplayHeight
  Protected nDisplay2Left, nDisplay2Top, nDisplay2Width, nDisplay2Height
  Protected nCropLeft, nCropTop, nCropWidth, nCropHeight
  Protected nSize
  Protected bTrace = #cTraceVidPicDrawing
  
  debugMsgC(sProcName, #SCS_START + ", pSourceWidth=" + pSourceWidth + ", pSourceHeight=" + pSourceHeight +
                       ", pTargetWidth=" + pTargetWidth + ", pTargetHeight=" + pTargetHeight +
                       ", pTarget2Width=" + pTarget2Width + ", pTarget2Height=" + pTarget2Height +
                       ", bAllowCropping=" + strB(bAllowCropping) + ", bApplyAspectRatio=" + strB(bApplyAspectRatio))
  
  ;  --------------------------------------------
  ; |                Target W,H                  |
  ; |                                            |
  ; |              -------------------           |
  ; |             |      Display      |          |
  ; |             |      X,Y,W,H      |          |
  ; |             |                   |          |
  ; |              -------------------           |
  ; |                                            |
  ; |                                            |
  ;  --------------------------------------------
  ;    W = width (display width may be greater than target width)
  ;    H = height (display height may be greater than target height)
  ;    X = display left (within target, may be negative)
  ;    Y = display top (within target, may be negative)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      
      nMySourceWidth = pSourceWidth
      nMySourceHeight = pSourceHeight
      
      If pTargetWidth >= pTarget2Width
        nMyTargetWidth = pTargetWidth
        nMyTargetHeight = pTargetHeight
        nMyTarget2Width = pTarget2Width
        nMyTarget2Height = pTarget2Height
      Else
        nMyTargetWidth = pTarget2Width
        nMyTargetHeight = pTarget2Height
        nMyTarget2Width = pTargetWidth
        nMyTarget2Height = pTargetHeight
        bTargetsSwapped = #True
      EndIf
      
      nSize = \nSize * -1
      
      ; ---------------------------------------------------------------------------------------
      ; 1. Calculate image width and height to fill target according to specified aspect ratio.
      nDisplayHeight = nMySourceHeight
      nDisplayWidth = nMySourceWidth
      Select \nAspectRatioType
        Case #SCS_ART_ORIGINAL
          ; no further action
        Case #SCS_ART_FULL
          nDisplayHeight = nMyTargetHeight
          nDisplayWidth = nMyTargetWidth
        Case #SCS_ART_16_9
          nDisplayWidth = (nDisplayHeight * 16) / 9
        Case #SCS_ART_4_3
          nDisplayWidth = (nDisplayHeight * 4) / 3
        Case #SCS_ART_185_1
          nDisplayWidth = (nDisplayHeight * 185) / 100
        Case #SCS_ART_235_1
          nDisplayWidth = (nDisplayHeight * 235) / 100
        Case #SCS_ART_CUSTOM
          nDisplayWidth = pSourceWidth + (pSourceWidth * nSize / 500)
          nDisplayWidth + (nDisplayWidth * \nAspectRatioHVal / 500)
      EndSelect
      ; dAspectRatioToUse = nDisplayWidth / nDisplayHeight
      ; debugMsgC(sProcName, "\nAspectRatioType=" + decodeAspectRatioType(\nAspectRatioType) + ", dAspectRatioToUse=" + StrD(dAspectRatioToUse,4) +
      ;                      ", pSourceWidth=" + pSourceWidth + ", pSourceHeight=" + pSourceHeight + ", \nRotate=" + \nRotate + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight)
      debugMsgC(sProcName, "\nAspectRatioType=" + decodeAspectRatioType(\nAspectRatioType) +
                           ", pSourceWidth=" + pSourceWidth + ", pSourceHeight=" + pSourceHeight + ", \nRotate=" + \nRotate + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight)
      
      fRescaleWidthFactor = nDisplayWidth / nMyTargetWidth
      fRescaleHeightFactor = nDisplayHeight / nMyTargetHeight
      If fRescaleWidthFactor > fRescaleHeightFactor
        fRescaleFactor = fRescaleWidthFactor
      Else
        fRescaleFactor = fRescaleHeightFactor
      EndIf
      ; nb need to use same factor for width and height or we may get a distorted image,
      ; especially if image is cropped and dAspectRatioToUse is re-calculated
      ; (tested with "Image Size Test.scs11", Q10: "itworks-HDTV_720P.png")
      nDisplayWidth / fRescaleFactor
      nDisplayHeight / fRescaleFactor
      debugMsgC(sProcName, "1. fRescaleFactor=" + StrF(fRescaleFactor,2) + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight)
      
      ; --------------------------------------------------------------------------
      ; 2. Adjust calculated width and height according to the user-specified size
      If \nSize <> 0
        fPercentage = convertSizeToPercentage(\nSize)
        nDisplayWidth * fPercentage / 100
        nDisplayHeight * fPercentage / 100
      EndIf
      nNewHalfWidth = nDisplayWidth / 2
      nNewHalfHeight = nDisplayHeight / 2
      nCalcMidPointX = nDisplayWidth / 2
      nCalcMidPointY = nDisplayHeight / 2
      If \nSize <> 0
        debugMsgC(sProcName, "2. \nSize=" + \nSize + ", fPercentage=" + StrF(fPercentage,2) + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight + ", nCalcMidPointX=" + nCalcMidPointX + ", nCalcMidPointY=" + nCalcMidPointY)
      Else
        debugMsgC(sProcName, "2. \nSize=" + \nSize + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight + ", nCalcMidPointX=" + nCalcMidPointX + ", nCalcMidPointY=" + nCalcMidPointY)
      EndIf
      
      ; --------------------------------------------------------------------------------------------------------------------------------
      ; 3. Calculate the left, top and midpoint coordinates of the displayed image after applying user-specified XPos and YPos settings.
      nAdjXPos = \nXPos + 5000
      nAdjYPos = \nYPos + 5000
      ; The following left and top formulae handle a full movement in either direction moving the 'new' image just off screen.
      nDisplayLeft = ((nMyTargetWidth + nDisplayWidth) * nAdjXPos / 10000) - nDisplayWidth
      nDisplayTop  = ((nMyTargetHeight + nDisplayHeight) * nAdjYPos / 10000) - nDisplayHeight
      nNewMidPointX = nDisplayLeft + nNewHalfWidth
      nNewMidPointY = nDisplayTop + nNewHalfHeight
      debugMsgC(sProcName, "3. nDisplayLeft=" + nDisplayLeft + ", nDisplayTop=" + nDisplayTop + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight +
                           ", nNewMidPointX=" + nNewMidPointX + ", nNewMidPointY=" + nNewMidPointY)
      
      ; -----------------------------------------------------------------------------------------------------------------------------------------
      ; 4. Calculate width or height of any portions of the new image that are outside the boundaries of target and therefore need to be cropped.
      If nDisplayLeft < 0
        nNewOutsideLeft = nDisplayLeft * -1
      EndIf
      If nDisplayTop < 0
        nNewOutsideTop = nDisplayTop * -1
      EndIf
      If (nNewMidPointX + nNewHalfWidth) > nMyTargetWidth
        nNewOutsideRight = nNewMidPointX + nNewHalfWidth - nMyTargetWidth
      EndIf
      If (nNewMidPointY + nNewHalfHeight) > nMyTargetHeight
        nNewOutsideBottom = nNewMidPointY + nNewHalfHeight - nMyTargetHeight
      EndIf
      debugMsgC(sProcName, "4. nNewOutsideLeft=" + nNewOutsideLeft + ", nNewOutsideRight=" + nNewOutsideRight + ", nNewOutsideTop=" + nNewOutsideTop + ", nNewOutsideBottom=" + nNewOutsideBottom)
      
      ; ----------------------------------------------
      ; 5. Calculate image cropping values if required
      If bAllowCropping
        If (nNewOutsideLeft > 0) Or (nNewOutsideTop > 0) Or (nNewOutsideRight > 0) Or (nNewOutsideBottom > 0) ; Or (\nSize <> 0) ; Mod 18May2020 11.8.3rc5b added "Or (\nSize <> 0)"
          bCropReqd = #True
          fCropWidthFactor = nMySourceWidth / nDisplayWidth
          fCropHeightFactor = nMySourceHeight / nDisplayHeight
          nCropLeft = nNewOutsideLeft * fCropWidthFactor
          nCropTop = nNewOutsideTop * fCropHeightFactor
          If nNewOutsideRight > 0
            nCropWidth = nMySourceWidth - (nNewOutsideRight * fCropWidthFactor) - nCropLeft
          Else
            nCropWidth = nMySourceWidth - nCropLeft
          EndIf
          If nNewOutsideBottom > 0
            nCropHeight = nMySourceHeight - (nNewOutsideBottom * fCropHeightFactor) - nCropTop
          Else
            nCropHeight = nMySourceHeight - nCropTop
          EndIf
          If nDisplayLeft < 0
            nDisplayLeft = 0
          EndIf
          If nDisplayTop < 0
            nDisplayTop = 0
          EndIf
          nDisplayWidth = nCropWidth * nDisplayWidth / nMySourceWidth
          nDisplayHeight = nCropHeight * nDisplayHeight / nMySourceHeight
          ; dAspectRatioToUse = nDisplayWidth / nDisplayHeight
        EndIf
        \bTVGCropping = bCropReqd
        \nTVGCroppingX = nCropLeft
        \nTVGCroppingY = nCropTop
        \nTVGCroppingWidth = nCropWidth
        \nTVGCroppingHeight = nCropHeight
        \dTVGCroppingZoom = 1.0 ; convertSizeToTVGCroppingZoom(\nSize)
        debugMsgC(sProcName, "5. bCropReqd=" + strB(bCropReqd) + ", nCropLeft=" + nCropLeft + ", nCropTop=" + nCropTop + ", nCropWidth=" + nCropWidth + ", nCropHeight=" + nCropHeight)
        debugMsgC(sProcName, "5. nDisplayLeft=" + nDisplayLeft + ", nDisplayTop=" + nDisplayTop + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight)
      EndIf
      
    EndWith
    
;     ; ---------------------------------
;     ; 6. apply aspect ratio if required
;     If bApplyAspectRatio
;       nAspectWidth = nDisplayWidth
;       nAspectHeight = nAspectWidth / dAspectRatioToUse
;       If nAspectHeight > nDisplayHeight
;         nAspectHeight = nDisplayHeight
;         nAspectWidth = nAspectHeight * dAspectRatioToUse
;       EndIf
;       nAspectWidthHalfDiff = (nDisplayWidth - nAspectWidth) / 2
;       nAspectHeightHalfDiff = (nDisplayHeight - nAspectHeight) / 2
;       nAspectLeft = nDisplayLeft + nAspectWidthHalfDiff
;       nAspectTop = nDisplayTop + nAspectHeightHalfDiff
;       nDisplayLeft = nAspectLeft
;       nDisplayTop = nAspectTop
;       nDisplayWidth = nAspectWidth
;       nDisplayHeight = nAspectHeight
;       debugMsgC(sProcName, "ASPECT: dAspectRatioToUse=" + StrD(dAspectRatioToUse,4) + ", nDisplayLeft=" + nDisplayLeft + ", nDisplayTop=" + nDisplayTop + ", nDisplayWidth=" + nDisplayWidth + ", nDisplayHeight=" + nDisplayHeight)
;     EndIf
    
    ; -------------------------------------
    ; 7. Store calculation results in grDPS
    With grDPS
      \nDisplayLeft = nDisplayLeft
      \nDisplayTop = nDisplayTop
      \nDisplayWidth = nDisplayWidth
      \nDisplayHeight = nDisplayHeight
      \dAspectRatioToUse = \nDisplayWidth / \nDisplayHeight
      If nMyTarget2Width > 0 And nMyTargetHeight > 0
        \nDisplay2Left = nDisplayLeft * nMyTarget2Width / nMyTargetWidth
        \nDisplay2Top = nDisplayTop * nMyTarget2Height / nMyTargetHeight
        \nDisplay2Width = nDisplayWidth * nMyTarget2Width / nMyTargetWidth
        \nDisplay2Height = nDisplayHeight * nMyTarget2Height / nMyTargetHeight
        If bTargetsSwapped
          Swap \nDisplayLeft, \nDisplay2Left
          Swap \nDisplayTop, \nDisplay2Top
          Swap \nDisplayWidth, \nDisplay2Width
          Swap \nDisplayHeight, \nDisplay2Height
        EndIf
      EndIf
      debugMsgC(sProcName, "nDisplayHeight=" + nDisplayHeight + ", nMyTarget2Height=" + nMyTarget2Height + ", nMyTargetHeight=" + nMyTargetHeight + ", \nDisplayHeight=" + \nDisplayHeight + ", \nDisplay2Height=" + \nDisplay2Height +
                           ", bTargetsSwapped=" + strB(bTargetsSwapped))
      ; \dAspectRatioToUse = dAspectRatioToUse
      debugMsgC(sProcName, "END: grDPS\nDisplayLeft=" + \nDisplayLeft + ", \nDisplayTop=" + \nDisplayTop + ", \nDisplayWidth=" + \nDisplayWidth + ", \nDisplayHeight=" + \nDisplayHeight + ", \dAspectRatioToUse=" + StrD(\dAspectRatioToUse,4))
      If \nDisplay2Width > 0
        debugMsgC(sProcName, "END: grDPS\nDisplay2Left=" + \nDisplay2Left + ", \nDisplay2Top=" + \nDisplay2Top + ", \nDisplay2Width=" + \nDisplay2Width + ", \nDisplay2Height=" + \nDisplay2Height)
      EndIf
    EndWith
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure encodeVideoRenderer(sVideoRenderer.s, nVideoPlaybackLibrary=#SCS_VPL_TVG)
  Protected nVideoRenderer
  
  Select sVideoRenderer
    Case "VR_AutoSelect"
      nVideoRenderer = #SCS_VR_AUTOSELECT
    Case "VR_EVR"
      nVideoRenderer = #SCS_VR_EVR
    Case "VR_VMR9"
      nVideoRenderer = #SCS_VR_VMR9
    Case "VR_VMR7"
      nVideoRenderer = #SCS_VR_VMR7
    Case "VR_Standard"
      nVideoRenderer = #SCS_VR_STANDARD
    Case "VR_Overlay"
      nVideoRenderer = #SCS_VR_OVERLAY
    Case "VR_Blackmagic_DeckLink"
      nVideoRenderer = #SCS_VR_BLACKMAGIC_DECKLINK
    Default
      nVideoRenderer = #SCS_VR_AUTOSELECT
  EndSelect
  ProcedureReturn nVideoRenderer
EndProcedure

Procedure.s decodeVideoRenderer(nVideoRenderer, nVideoPlaybackLibrary=#SCS_VPL_TVG)
  Protected sVideoRenderer.s
  
  Select nVideoPlaybackLibrary
    Case #SCS_VPL_TVG
      CompilerIf #c_include_tvg
        Select nVideoRenderer
          Case #SCS_VR_AUTOSELECT
            sVideoRenderer = "VR_AutoSelect"
          Case #SCS_VR_EVR
            sVideoRenderer = "VR_EVR"
          Case #SCS_VR_VMR9
            sVideoRenderer = "VR_VMR9"
          Case #SCS_VR_VMR7
            sVideoRenderer = "VR_VMR7"
          Case #SCS_VR_STANDARD
            sVideoRenderer = "VR_Standard"
          Case #SCS_VR_OVERLAY
            sVideoRenderer = "VR_Overlay"
          Case #SCS_VR_BLACKMAGIC_DECKLINK
            sVideoRenderer = "VR_Blackmagic_DeckLink"
          Default
            sVideoRenderer = Str(nVideoRenderer)
        EndSelect
      CompilerEndIf
      
  EndSelect
  ProcedureReturn sVideoRenderer
EndProcedure

Procedure.s decodeVideoRendererL(nVideoRenderer, nVideoPlaybackLibrary=#SCS_VPL_TVG)
  Protected sVideoRenderer.s
  
  Select nVideoPlaybackLibrary
    Case #SCS_VPL_TVG
      CompilerIf #c_include_tvg
        Select nVideoRenderer
          Case #SCS_VR_AUTOSELECT
            sVideoRenderer = Lang("TVG", "vr_auto")
          Case #SCS_VR_EVR
            sVideoRenderer = "EVR"
          Case #SCS_VR_VMR9
            sVideoRenderer = "VMR9"
          Case #SCS_VR_VMR7
            sVideoRenderer = "VMR7"
          Case #SCS_VR_STANDARD
            sVideoRenderer = Lang("TVG", "vr_standard")
          Case #SCS_VR_OVERLAY
            sVideoRenderer = Lang("TVG", "vr_overlay")
          Case #SCS_VR_BLACKMAGIC_DECKLINK
            sVideoRenderer = "Blackmagic DeckLink"
          Default
            sVideoRenderer = Str(nVideoRenderer)
        EndSelect
      CompilerEndIf
      
  EndSelect
  ProcedureReturn sVideoRenderer
EndProcedure

Procedure.s decodeVideoRendererWithDefault(nVideoRenderer, nVideoPlaybackLibrary=#SCS_VPL_TVG)
  Protected sVideoRenderer.s
  
  sVideoRenderer = decodeVideoRendererL(nVideoRenderer, nVideoPlaybackLibrary)
  Select nVideoRenderer
    Case #SCS_VR_AUTOSELECT
      sVideoRenderer + " (" + grText\sTextDefault + ")"
  EndSelect
  
  ProcedureReturn sVideoRenderer
EndProcedure

Procedure.s decodeVideoSource(nVideoSource)
  Protected sVideoSource.s
  
  Select nVideoSource
    Case #SCS_VID_SRC_FILE
      sVideoSource = "File"
    Case #SCS_VID_SRC_CAPTURE
      sVideoSource = "Capture"
    Default
      sVideoSource = "File"  ; default is 'File' because that's all that existed in SCS prior to the addition of video capture
  EndSelect
  ProcedureReturn sVideoSource
EndProcedure

Procedure encodeVideoSource(sVideoSource.s)
  Protected nVideoSource
  
  Select sVideoSource
    Case "File"
      nVideoSource = #SCS_VID_SRC_FILE
    Case "Capture"
      nVideoSource = #SCS_VID_SRC_CAPTURE
    Default
      nVideoSource = #SCS_VID_SRC_FILE  ; default is 'FILE' because that's all that existed in SCS prior to the addition of video capture
  EndSelect
  ProcedureReturn nVideoSource
  
EndProcedure

Procedure.s decodeLevelPointType(nPointType)
  Protected sPointType.s
  
  Select nPointType
    Case #SCS_PT_FADE_IN
      sPointType = "FadeIn"
    Case #SCS_PT_FADE_OUT
      sPointType = "FadeOut"
    Case #SCS_PT_STD
      sPointType = "Std"
    Case #SCS_PT_START
      sPointType = "Start"
    Case #SCS_PT_END
      sPointType = "End"
    Case #SCS_PT_UNUSED_BOF
      sPointType = "UnusedBOF"
    Case #SCS_PT_UNUSED_MIN
      sPointType = "UnusedMIN"
    Case #SCS_PT_UNUSED_MAX
      sPointType = "UnusedMAX"
    Case #SCS_PT_UNUSED_EOF
      sPointType = "UnusedEOF"
    Default
      sPointType = Str(nPointType)
  EndSelect
  ProcedureReturn sPointType
EndProcedure

Procedure.s decodeLevelPointTypeL(nPointType)
  Protected sPointType.s
  
  Select nPointType
    Case #SCS_PT_UNUSED_BOF, #SCS_PT_UNUSED_MIN, #SCS_PT_UNUSED_MAX, #SCS_PT_UNUSED_EOF
      ; no language translations for 'unused' level point types as they are never displayed to the user (or shouldn't be!)
      sPointType = decodeLevelPointType(nPointType)
    Default
      sPointType = Lang("LvlPtType", decodeLevelPointType(nPointType))
  EndSelect
  ProcedureReturn sPointType
EndProcedure

Procedure encodeLevelPointType(sPointType.s)
  Protected nPointType
  
  Select sPointType
    Case "FadeIn"
      nPointType = #SCS_PT_FADE_IN
    Case "FadeOut"
      nPointType = #SCS_PT_FADE_OUT
    Case "Std"
      nPointType = #SCS_PT_STD
    Case "Start"
      nPointType = #SCS_PT_START
    Case "End"
      nPointType = #SCS_PT_END
    Case "UnusedBOF"
      nPointType = #SCS_PT_UNUSED_BOF
    Case "UnusedMIN"
      nPointType = #SCS_PT_UNUSED_MIN
    Case "UnusedMAX"
      nPointType = #SCS_PT_UNUSED_MAX
    Case "UnusedEOF"
      nPointType = #SCS_PT_UNUSED_EOF
  EndSelect
  ProcedureReturn nPointType
EndProcedure

Procedure.s decodeLvlPtLvlSel(nLvlPtLvlSel)
  Protected sLvlPtLvlSel.s
  
  Select nLvlPtLvlSel
    Case #SCS_LVLSEL_INDIV
      sLvlPtLvlSel = "LvlIndiv"
    Case #SCS_LVLSEL_SYNC
      sLvlPtLvlSel = "LvlSync"
    Case #SCS_LVLSEL_LINK
      sLvlPtLvlSel = "LvlLink"
    Default
      sLvlPtLvlSel = Str(nLvlPtLvlSel)
  EndSelect
  ProcedureReturn sLvlPtLvlSel
EndProcedure

Procedure.s decodeLvlPtLvlSelL(nLvlPtLvlSel)
  ProcedureReturn Lang("WQF", decodeLvlPtLvlSel(nLvlPtLvlSel))
EndProcedure

Procedure encodeLvlPtLvlSel(sLvlPtLvlSel.s)
  Protected nLvlPtLvlSel
  
  Select sLvlPtLvlSel
    Case "LvlIndiv"
      nLvlPtLvlSel = #SCS_LVLSEL_INDIV
    Case "LvlSync"
      nLvlPtLvlSel = #SCS_LVLSEL_SYNC
    Case "LvlLink"
      nLvlPtLvlSel = #SCS_LVLSEL_LINK
    Default
      nLvlPtLvlSel = #SCS_LVLSEL_INDIV
  EndSelect
  ProcedureReturn nLvlPtLvlSel
EndProcedure

Procedure.s decodeLvlPtPanSel(nLvlPtPanSel)
  Protected sLvlPtPanSel.s
  
  Select nLvlPtPanSel
    Case #SCS_PANSEL_USEAUDDEV
      sLvlPtPanSel = "PanUseAudDev"
    Case #SCS_PANSEL_INDIV
      sLvlPtPanSel = "PanIndiv"
    Case #SCS_PANSEL_SYNC
      sLvlPtPanSel = "PanSync"
    Default
      sLvlPtPanSel = Str(nLvlPtPanSel)
  EndSelect
  ProcedureReturn sLvlPtPanSel
EndProcedure

Procedure.s decodeLvlPtPanSelL(nLvlPtPanSel)
  ProcedureReturn Lang("WQF", decodeLvlPtPanSel(nLvlPtPanSel))
EndProcedure

Procedure encodeLvlPtPanSel(sLvlPtPanSel.s)
  Protected nLvlPtPanSel
  
  Select sLvlPtPanSel
    Case "PanUseAudDev"
      nLvlPtPanSel = #SCS_PANSEL_USEAUDDEV
    Case "PanIndiv"
      nLvlPtPanSel = #SCS_PANSEL_INDIV
    Case "PanSync"
      nLvlPtPanSel = #SCS_PANSEL_SYNC
    Default
      nLvlPtPanSel = #SCS_PANSEL_USEAUDDEV
  EndSelect
  ProcedureReturn nLvlPtPanSel
EndProcedure

Procedure.s decodeOperMode(nOperMode)
  Protected sOperMode.s
  
  Select nOperMode
    Case #SCS_OPERMODE_PERFORMANCE
      sOperMode = "Performance"
    Case #SCS_OPERMODE_REHEARSAL
      sOperMode = "Rehearsal"
    Case #SCS_OPERMODE_DESIGN
      sOperMode = "Design"
  EndSelect
  ProcedureReturn sOperMode
EndProcedure

Procedure.s decodeOperModeL(nOperMode)
  Protected sOperMode.s
  
  Select nOperMode
    Case #SCS_OPERMODE_PERFORMANCE
      sOperMode = Lang("OperMode", "Performance")
    Case #SCS_OPERMODE_REHEARSAL
      sOperMode = Lang("OperMode", "Rehearsal")
    Case #SCS_OPERMODE_DESIGN
      sOperMode = Lang("OperMode", "Design")
  EndSelect
  ProcedureReturn sOperMode
EndProcedure

Procedure encodeOperMode(sOperMode.s)
  Protected nOperMode
  
  Select sOperMode
    Case "Performance"
      nOperMode = #SCS_OPERMODE_PERFORMANCE
    Case "Rehearsal"
      nOperMode = #SCS_OPERMODE_REHEARSAL
    Default
      nOperMode = #SCS_OPERMODE_DESIGN
  EndSelect
  ProcedureReturn nOperMode
EndProcedure

Procedure AbsInt(pValue)
  ; Abs() for integers. AbsInt() added because the PB documentation states that Abs() is for floats and may fail with integers.
  If pValue < 0
    ProcedureReturn (0 - pValue)
  Else
    ProcedureReturn pValue
  EndIf
EndProcedure

Procedure drawResizeHandle(nColor)
  Protected n
  For n = 5 To 15 Step 5
    LineXY(OutputWidth()-n, OutputHeight(),OutputWidth(),OutputHeight()-n,nColor)
  Next n
EndProcedure

Procedure.s dropIllegalFilenameChars(sFileName.s)
  Protected sNewFilename.s
  Protected sChar.s
  Protected n
  
  If CheckFilename(sFileName)
    sNewFilename = sFileName
  Else
    ; the following code applicable to Windows only - see http://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx#naming_conventions
    For n = 1 To Len(sFileName)
      sChar = Mid(sFileName,n,1)
      Select sChar
        Case "<", ">", ":", #DQUOTE$, "/", "\", "|", "?", "*"
          ; illegal character - ignore
        Default
          Select Asc(sChar)
            Case 0 To 31
              ; all or some of these are illegal - ignore
            Default
              sNewFilename + sChar
          EndSelect
      EndSelect
    Next n
    sNewFilename = Trim(Trim(Trim(sNewFilename),".")) ; cannot start or end with space or period
    Select UCase(sNewFilename)
      Case "CON", "PRN", "AUX", "NUL",
           "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
           "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
        ; illegal name
        sNewFilename = ""
    EndSelect
  EndIf
  
  ProcedureReturn Trim(sNewFilename)
  
EndProcedure
  
Procedure encodeMuteAction(sMuteAction.s)
  Protected nMuteAction
  
  Select sMuteAction
    Case "Mute"
      nMuteAction = #SCS_MUTE_ON
    Case "Unmute"
      nMuteAction = #SCS_MUTE_OFF
  EndSelect
  ProcedureReturn nMuteAction
EndProcedure

Procedure.s decodeMuteAction(nMuteAction)
  Protected sMuteAction.s
  
  Select nMuteAction
    Case #SCS_MUTE_ON
      sMuteAction = "Mute"
    Case #SCS_MUTE_OFF
      sMuteAction = "Unmute"
  EndSelect
  ProcedureReturn sMuteAction
EndProcedure

Procedure.s decodeMuteActionL(nMuteAction)
  ProcedureReturn Lang("Common", decodeMuteAction(nMuteAction))
EndProcedure

Procedure encodeMTCType(sMTCType.s)
  Protected nMTCType
  
  Select sMTCType
    Case "MTC"
      nMTCType = #SCS_MTC_TYPE_MTC
    Case "LTC"
      nMTCType = #SCS_MTC_TYPE_LTC
  EndSelect
  ProcedureReturn nMTCType
EndProcedure

Procedure.s decodeMTCType(nMTCType)
  Protected sMTCType.s
  
  Select nMTCType
    Case #SCS_MTC_TYPE_MTC
      sMTCType = "MTC"
    Case #SCS_MTC_TYPE_LTC
      sMTCType = "LTC"
  EndSelect
  ProcedureReturn sMTCType
EndProcedure

Procedure.s decodeMTCTypeL(nMTCType)
  ProcedureReturn Lang("Common", decodeMTCType(nMTCType))
EndProcedure

Procedure encodeLTEntryType(sLTEntryType.s)
  Protected nLTEntryType
  
  Select sLTEntryType
    Case "FI"
      nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
    Case "DBO"
      nLTEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
    Case "CAPSE"
      nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
    Case "CAPSN"
      nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
    Default
      nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_ITEMS
  EndSelect
  ProcedureReturn nLTEntryType
EndProcedure

Procedure.s decodeLTEntryType(nLTEntryType)
  Protected sLTEntryType.s
  
  Select nLTEntryType
    Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
      sLTEntryType = "FI"
    Case #SCS_LT_ENTRY_TYPE_BLACKOUT
      sLTEntryType = "DBO"
    Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
      sLTEntryType = "CAPSE"
    Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
      sLTEntryType = "CAPSN"
    Default
      sLTEntryType = "DI"
  EndSelect
  ProcedureReturn sLTEntryType
EndProcedure

Procedure.s decodeLTEntryTypeL(nLTEntryType)
  ProcedureReturn Lang("WQK", decodeLTEntryType(nLTEntryType))
EndProcedure

Procedure TogglePasswordVisibility(StringGadgetID.I)
  ; supplied in the PB Coding Questions Forum under the topic "StringGadget for passwords - toggle '*'?"
  Static PasswordChar
  Static PasswordCharIsKnown
  
  If PasswordCharIsKnown = #False
    PasswordChar = SendMessage_(GadgetID(StringGadgetID), #EM_GETPASSWORDCHAR, 0, 0)
    PasswordCharIsKnown = #True
  EndIf
  
  If GetWindowLongPtr_(GadgetID(StringGadgetID), #GWL_STYLE) & #ES_PASSWORD
    SendMessage_(GadgetID(StringGadgetID), #EM_SETPASSWORDCHAR, 0, 0)
  Else
    SendMessage_(GadgetID(StringGadgetID), #EM_SETPASSWORDCHAR, PasswordChar, 0)
  EndIf
  
  InvalidateRect_(GadgetID(StringGadgetID), 0, 1)
EndProcedure

Procedure drawPasswordEye(cvsPasswordEyeGadget)
  If StartDrawing(CanvasOutput(cvsPasswordEyeGadget))
    Box(0, 0, OutputWidth(), OutputHeight(), glSysColBtnFace)
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(hMiEye), 0, 0, OutputWidth(), OutputHeight())
    StopDrawing()
  EndIf
EndProcedure

Procedure processPasswordEyeEvent(txtGadget)
  Select gnEventType
    Case #PB_EventType_LeftButtonDown, #PB_EventType_LeftButtonUp
      TogglePasswordVisibility(txtGadget)
  EndSelect
  
EndProcedure

Procedure processSplitterRepositioned(nSplitterMoving, bEndOfMove=#False)
  PROCNAMEC()
  
  Select nSplitterMoving
    Case WMN\splCueListMemo, WMN\splMainMemo, WMN\splNorthSouth, WMN\splPanelsHotkeys
      ; debugMsg(sProcName, "calling WMN_processSplitterRepositioned(" + getGadgetName(nSplitterMoving) + ", " + "bEndOfMove=" + strB(bEndOfMove) + ")")
      WMN_processSplitterRepositioned(nSplitterMoving, bEndOfMove)
  EndSelect
  
EndProcedure

Procedure BlendColor(Color1, Color2, Scale=50)
  Protected R1, G1, B1, R2, G2, B2, Scl.f = Scale/100
  
  R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
  R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
  ProcedureReturn RGB((R1*Scl) + (R2 * (1-Scl)), (G1*Scl) + (G2 * (1-Scl)), (B1*Scl) + (B2 * (1-Scl)))
  
EndProcedure

Procedure lightenRGBColor(nCurrColor, nLightenFactor=-1)
  Protected nNewColor, nRed, nGreen, nBlue, nReqdLightenFactor
  
  If nLightenFactor = -1
    nReqdLightenFactor = 20
  Else
    nReqdLightenFactor = nLightenFactor ; nb may be zero
  EndIf
  nRed = Red(nCurrColor) + nReqdLightenFactor
  nGreen = Green(nCurrColor) + nReqdLightenFactor
  nBlue = Blue(nCurrColor) + nReqdLightenFactor
  If nRed < 0 : nRed = 0 : ElseIf nRed > 255 : nRed = 255 : EndIf
  If nGreen < 0 : nGreen = 0 : ElseIf nGreen > 255 : nGreen = 255 : EndIf
  If nBlue < 0 : nBlue = 0 : ElseIf nBlue > 255 : nBlue = 255 : EndIf
  nNewColor = RGB(nRed, nGreen, nBlue)
  ProcedureReturn nNewColor
  
EndProcedure

Procedure.s checkForUpdateIfReqd(bForceCheck=#False)
  PROCNAMEC()
  Protected sUpdateAvailable.s, bDoCheck
  Protected nLastCheckForUpdate, nNextCheckForUpdate
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  CompilerIf #cDemo = #False And #cWorkshop = #False
    If bForceCheck
      bDoCheck = #True
    Else
      If grGeneralOptions\bEnableAutoCheckForUpdate
        If grMemoryPrefs\sLastCheckForUpdate
          nLastCheckForUpdate = ParseDate("%yyyy%mm%dd", grMemoryPrefs\sLastCheckForUpdate)
          nNextCheckForUpdate = AddDate(nLastCheckForUpdate, #PB_Date_Day, grGeneralOptions\nDaysBetweenChecks)
          ; debugMsg(sProcName, "nLastCheckForUpdate=" + FormatDate("%yyyy%mm%dd", nLastCheckForUpdate) + ", grGeneralOptions\nDaysBetweenChecks=" + grGeneralOptions\nDaysBetweenChecks + ", nNextCheckForUpdate=" + FormatDate("%yyyy%mm%dd", nNextCheckForUpdate))
        EndIf
        If Date() >= nNextCheckForUpdate
          bDoCheck = #True
        EndIf
      EndIf
    EndIf
    If bDoCheck
      sUpdateAvailable = WUP_GetUpdateAvailable(1500)
      ; debugMsg(sProcName, "sUpdateAvailable=" + sUpdateAvailable)
      COND_OPEN_PREFS("Memory")  ; OPEN_PREF_GROUP("Memory")
      WritePreferenceString("LastCheckForUpdate", FormatDate("%yyyy%mm%dd", Date()))
      COND_CLOSE_PREFS()
    EndIf
  CompilerEndIf
  ProcedureReturn sUpdateAvailable
EndProcedure

Procedure getShortcutForKey(sKey.s)
  Protected nShortcut
  
  Select sKey
    Case "A"
      nShortcut = #PB_Shortcut_A
    Case "B"
      nShortcut = #PB_Shortcut_B
    Case "C"
      nShortcut = #PB_Shortcut_C
    Case "D"
      nShortcut = #PB_Shortcut_D
    Case "E"
      nShortcut = #PB_Shortcut_E
    Case "F"
      nShortcut = #PB_Shortcut_F
    Case "G"
      nShortcut = #PB_Shortcut_G
    Case "H"
      nShortcut = #PB_Shortcut_H
    Case "I"
      nShortcut = #PB_Shortcut_I
    Case "J"
      nShortcut = #PB_Shortcut_J
    Case "K"
      nShortcut = #PB_Shortcut_K
    Case "L"
      nShortcut = #PB_Shortcut_L
    Case "M"
      nShortcut = #PB_Shortcut_M
    Case "N"
      nShortcut = #PB_Shortcut_N
    Case "O"
      nShortcut = #PB_Shortcut_O
    Case "P"
      nShortcut = #PB_Shortcut_P
    Case "Q"
      nShortcut = #PB_Shortcut_Q
    Case "R"
      nShortcut = #PB_Shortcut_R
    Case "S"
      nShortcut = #PB_Shortcut_S
    Case "T"
      nShortcut = #PB_Shortcut_T
    Case "U"
      nShortcut = #PB_Shortcut_U
    Case "V"
      nShortcut = #PB_Shortcut_V
    Case "W"
      nShortcut = #PB_Shortcut_W
    Case "X"
      nShortcut = #PB_Shortcut_X
    Case "Y"
      nShortcut = #PB_Shortcut_Y
    Case "Z"
      nShortcut = #PB_Shortcut_Z
    Case "1"
      nShortcut = #PB_Shortcut_1
    Case "2"
      nShortcut = #PB_Shortcut_2
    Case "3"
      nShortcut = #PB_Shortcut_3
    Case "4"
      nShortcut = #PB_Shortcut_4
    Case "5"
      nShortcut = #PB_Shortcut_5
    Case "6"
      nShortcut = #PB_Shortcut_6
    Case "7"
      nShortcut = #PB_Shortcut_7
    Case "8"
      nShortcut = #PB_Shortcut_8
    Case "9"
      nShortcut = #PB_Shortcut_9
    Case "0"
      nShortcut = #PB_Shortcut_0
    Case "PGUP" ; Added 17Apr2022 11.9.1bb
      nShortcut = #PB_Shortcut_PageUp
    Case "PGDN" ; Added 17Apr2022 11.9.1bb
      nShortcut = #PB_Shortcut_PageDown
    Case "F1"
      nShortcut = #PB_Shortcut_F1
    Case "F2"
      nShortcut = #PB_Shortcut_F2
    Case "F3"
      nShortcut = #PB_Shortcut_F3
    Case "F4"
      nShortcut = #PB_Shortcut_F4
    Case "F5"
      nShortcut = #PB_Shortcut_F5
    Case "F6"
      nShortcut = #PB_Shortcut_F6
    Case "F7"
      nShortcut = #PB_Shortcut_F7
    Case "F8"
      nShortcut = #PB_Shortcut_F8
    Case "F9"
      nShortcut = #PB_Shortcut_F9
    Case "F10"
      nShortcut = #PB_Shortcut_F10
    Case "F11"
      nShortcut = #PB_Shortcut_F11
    Case "F12"
      nShortcut = #PB_Shortcut_F12
  EndSelect
  ProcedureReturn nShortcut
EndProcedure

Procedure.s decodeTouchPanelPos(nTouchPanelPos)
  Protected sTouchPanelPos.s
  Select nTouchPanelPos
    Case #SCS_TOUCH_PANEL_POS_BOTTOM
      sTouchPanelPos = "Bottom"
    Case #SCS_TOUCH_PANEL_POS_TOP
      sTouchPanelPos = "Top"
    Default ; including #SCS_TOUCH_PANEL_POS_NONE
      sTouchPanelPos = ""
  EndSelect
  ProcedureReturn sTouchPanelPos
EndProcedure

Procedure encodeTouchPanelPos(sTouchPanelPos.s)
  Protected nTouchPanelPos
  Select sTouchPanelPos
    Case "Bottom"
      nTouchPanelPos = #SCS_TOUCH_PANEL_POS_BOTTOM
    Case "Top"
      nTouchPanelPos = #SCS_TOUCH_PANEL_POS_TOP
    Default
      nTouchPanelPos = #SCS_TOUCH_PANEL_POS_NONE
  EndSelect
  ProcedureReturn nTouchPanelPos
EndProcedure

Procedure.s decodeFTStatus(ftStatus.l)
  Protected sStatus.s
  
  Select ftStatus
    Case #FT_OK
      sStatus = "FT_OK"
    Case #FT_INVALID_HANDLE
      sStatus = "FT_INVALID_HANDLE"
    Case #FT_DEVICE_NOT_FOUND
      sStatus = "FT_INVALID_HANDLE"
    Case #FT_DEVICE_NOT_OPENED
      sStatus = "FT_DEVICE_NOT_OPENED"
    Case #FT_IO_ERROR
      sStatus = "FT_IO_ERROR"
    Case #FT_INSUFFICIENT_RESOURCES
      sStatus = "FT_INSUFFICIENT_RESOURCES"
    Case #FT_INVALID_PARAMETER
      sStatus = "FT_INVALID_PARAMETER"
    Case #FT_INVALID_BAUD_RATE
      sStatus = "FT_INVALID_BAUD_RATE"
    Case #FT_DEVICE_NOT_OPENED_FOR_ERASE
      sStatus = "FT_DEVICE_NOT_OPENED_FOR_ERASE"
    Case #FT_DEVICE_NOT_OPENED_FOR_WRITE
      sStatus = "FT_DEVICE_NOT_OPENED_FOR_WRITE"
    Case #FT_FAILED_TO_WRITE_DEVICE
      sStatus = "FT_FAILED_TO_WRITE_DEVICE"
    Case #FT_EEPROM_READ_FAILED
      sStatus = "FT_EEPROM_READ_FAILED"
    Case #FT_EEPROM_WRITE_FAILED
      sStatus = "FT_EEPROM_WRITE_FAILED"
    Case #FT_EEPROM_ERASE_FAILED
      sStatus = "FT_EEPROM_ERASE_FAILED"
    Case #FT_EEPROM_NOT_PRESENT
      sStatus = "FT_EEPROM_NOT_PRESENT"
    Case #FT_EEPROM_NOT_PROGRAMMED
      sStatus = "FT_EEPROM_NOT_PROGRAMMED"
    Case #FT_INVALID_ARGS
      sStatus = "FT_INVALID_ARGS"
    Case #FT_NOT_SUPPORTED
      sStatus = "FT_NOT_SUPPORTED"
    Case #FT_OTHER_ERROR
      sStatus = "FT_OTHER_ERROR"
    Case #FT_DEVICE_LIST_NOT_READY
      sStatus = ""
    Default
      sStatus = Str(ftStatus)
  EndSelect
  ProcedureReturn sStatus
  
EndProcedure

Procedure.s decodeDMXAPILabel(nLabel.a)
  Protected sLabel.s
  ; NB Omitted RDM-only labels as we are not using RDM in SCS. Any such labels will fall into the Default case.
  ; Also omitted Show labels.
  
  Select nLabel
    Case #ENTTEC_GET_WIDGET_PARAMS_PORT1 ; 3
      sLabel = "#ENTTEC_GET_WIDGET_PARAMS_PORT1"
    Case #ENTTEC_GET_WIDGET_PARAMS_PORT2 ; 196
      sLabel = "#ENTTEC_GET_WIDGET_PARAMS_PORT2"
    Case #ENTTEC_SET_WIDGET_PARAMS_PORT1 ; 4
      sLabel = "#ENTTEC_SET_WIDGET_PARAMS_PORT1"
    Case #ENTTEC_SET_WIDGET_PARAMS_PORT2 ; 156
      sLabel = "#ENTTEC_SET_WIDGET_PARAMS_PORT2"
    Case #ENTTEC_RECEIVED_DMX_PORT1 ; 5
      sLabel = "#ENTTEC_RECEIVED_DMX_PORT1"
    Case #ENTTEC_RECEIVED_DMX_PORT2 ; 210
      sLabel = "#ENTTEC_RECEIVED_DMX_PORT2"
    Case #ENTTEC_SEND_DMX_PORT1 ; 6
      sLabel = "#ENTTEC_SEND_DMX_PORT1"
    Case #ENTTEC_SEND_DMX_PORT2 ; 132
      sLabel = "#ENTTEC_SEND_DMX_PORT2"
    Case #ENTTEC_SEND_DMX_RDM_TX_PORT1 ; 7
      sLabel = "#ENTTEC_SEND_DMX_RDM_TX_PORT1"
    Case #ENTTEC_SEND_DMX_RDM_TX_PORT2 ; 226
      sLabel = "#ENTTEC_SEND_DMX_RDM_TX_PORT2"
    Case #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT1 ; 8
      sLabel = "#ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT1"
    Case #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT2 ; 128
      sLabel = "#ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT2"
    Case #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1 ; 9
      sLabel = "#ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1"
    Case #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2 ; 212
      sLabel = "#ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2"
    Case #ENTTEC_GET_WIDGET_SN ; 10
      sLabel = "#ENTTEC_GET_WIDGET_SN"
    Case #ENTTEC_SET_API_KEY ; 13
      sLabel = "#ENTTEC_SET_API_KEY"
    Case #ENTTEC_HARDWARE_VERSION ; 14
      sLabel = "#ENTTEC_HARDWARE_VERSION"
    Case #ENTTEC_GET_PORT_ASSIGNMENT ; 220
      sLabel = "#ENTTEC_GET_PORT_ASSIGNMENT"
    Case #ENTTEC_SET_PORT_ASSIGNMENT ; 201
      sLabel = "#ENTTEC_SET_PORT_ASSIGNMENT"
    Case #ENTTEC_RECEIVED_MIDI ; 225
      sLabel = "#ENTTEC_RECEIVED_MIDI"
    Case #ENTTEC_SEND_MIDI ; 191
      sLabel = "#ENTTEC_SEND_MIDI"
    Default
      sLabel = Str(nLabel)
  EndSelect
  ProcedureReturn sLabel
  
EndProcedure

Procedure.s decodeDMXMode(nDMXMode)
  Protected sDMXMode.s
  
  Select nDMXMode
    Case #SCS_DMX_MODE_INPUT
      sDMXMode = "Input"
    Case #SCS_DMX_MODE_OUTPUT
      sDMXMode = "Output"
    Default
      sDMXMode = Str(nDMXMode)
  EndSelect
  ProcedureReturn sDMXMode
  
EndProcedure

Procedure.s decodeDMXPref(nPref)
  PROCNAMEC()
  Protected sDecoded.s

  Select nPref
    Case #SCS_DMX_NOTATION_0_255
      sDecoded = "0-255"
    Case #SCS_DMX_NOTATION_PERCENT
      sDecoded = "%"
  EndSelect
  ProcedureReturn sDecoded

EndProcedure

Procedure encodeDMXPref(sPref.s)
  PROCNAMEC()
  Protected nEncoded

  Select sPref
    Case "0-255"
      nEncoded = #SCS_DMX_NOTATION_0_255
    Case "%"
      nEncoded = #SCS_DMX_NOTATION_PERCENT
    Default
      nEncoded = #SCS_DMX_NOTATION_0_255
  EndSelect
  ProcedureReturn nEncoded

EndProcedure

Procedure.s decodeDMXGridType(nGridType)
  PROCNAMEC()
  Protected sDecoded.s

  Select nGridType
    Case #SCS_DMX_GRIDTYPE_UNIVERSE
      sDecoded = "Universe"
    Case #SCS_DMX_GRIDTYPE_ALL_FIXTURES
      sDecoded = "AllFix"
  EndSelect
  ProcedureReturn sDecoded

EndProcedure

Procedure encodeDMXGridType(sGridType.s)
  PROCNAMEC()
  Protected nEncoded

  Select sGridType
    Case "Universe"
      nEncoded = #SCS_DMX_GRIDTYPE_UNIVERSE
    Case "AllFix"
      nEncoded = #SCS_DMX_GRIDTYPE_ALL_FIXTURES
    Default
      nEncoded = #SCS_DMX_GRIDTYPE_UNIVERSE
  EndSelect
  ProcedureReturn nEncoded

EndProcedure

Procedure.s decodeDMXTrgCtrl(nTrgCtrl)
  PROCNAMEC()
  Protected sTrgCtrl.s
  
  Select nTrgCtrl
    Case #SCS_DMX_TRG_CHG_UP_TO_VALUE
      sTrgCtrl = "UpToVal"
    Case #SCS_DMX_TRG_CHG_FROM_ZERO
      sTrgCtrl = "FromZero"
    Case #SCS_DMX_TRG_ANY_CHG
      sTrgCtrl = "Any"
  EndSelect
  ProcedureReturn sTrgCtrl
  
EndProcedure

Procedure encodeDMXTrgCtrl(sTrgCtrl.s)
  PROCNAMEC()
  Protected nDMXTrgCtrl
  
  Select sTrgCtrl
    Case "UpToVal"
      nDMXTrgCtrl = #SCS_DMX_TRG_CHG_UP_TO_VALUE
    Case "FromZero"
      nDMXTrgCtrl = #SCS_DMX_TRG_CHG_FROM_ZERO
    Case "Any"
      nDMXTrgCtrl = #SCS_DMX_TRG_ANY_CHG
    Default
      nDMXTrgCtrl = #SCS_DMX_TRG_ANY_CHG
  EndSelect
  ProcedureReturn nDMXTrgCtrl
  
EndProcedure

Procedure.s decodeDMXCommand(nDMXCommand)   ; was DMXCmdAbbrForCmdNo()
  PROCNAMEC()
  Protected sDMXCommand.s
  
  ; NO TRANSLATION REQUIRED! Used for storing values in device maps
  Select nDMXCommand
    Case #SCS_DMX_GO_BUTTON
      sDMXCommand = "GoButton"
    Case #SCS_DMX_STOP_ALL
      sDMXCommand = "StopAll"
    Case #SCS_DMX_PAUSE_RESUME_ALL
      sDMXCommand = "PauseResumeAll"
    Case #SCS_DMX_GO_TO_TOP
      sDMXCommand = "GoToTop"
    Case #SCS_DMX_GO_BACK
      sDMXCommand = "GoBack"
    Case #SCS_DMX_GO_TO_NEXT
      sDMXCommand = "GoToNext"
    Case #SCS_DMX_MASTER_FADER
      sDMXCommand = "MasterFader"
    Case #SCS_DMX_PLAY_DMX_CUE_0
      sDMXCommand = "PlayDMXCue0"
    Case #SCS_DMX_PLAY_DMX_CUE_MAX
      sDMXCommand = "PlayDMXCueMax"
  EndSelect
  ProcedureReturn sDMXCommand
EndProcedure

Procedure.s decodeDMXCommandL(nDMXCommand)
  ProcedureReturn Lang("Remote", decodeDMXCommand(nDMXCommand))
EndProcedure

Procedure encodeDMXCommand(sDMXCommand.s)  ; was DMXCmdNoForCmdAbbr()
  PROCNAMEC()
  Protected nDMXCommand
  
  ; NO TRANSLATION REQUIRED!
  Select sDMXCommand
    Case "GoButton"
      nDMXCommand = #SCS_DMX_GO_BUTTON
    Case "StopAll"
      nDMXCommand = #SCS_DMX_STOP_ALL
    Case "PauseResumeAll"
      nDMXCommand = #SCS_DMX_PAUSE_RESUME_ALL
    Case "GoToTop"
      nDMXCommand = #SCS_DMX_GO_TO_TOP
    Case "GoBack"
      nDMXCommand = #SCS_DMX_GO_BACK
    Case "GoToNext"
      nDMXCommand = #SCS_DMX_GO_TO_NEXT
    Case "MasterFader"
      nDMXCommand = #SCS_DMX_MASTER_FADER
    Case "PlayDMXCue0"
      nDMXCommand = #SCS_DMX_PLAY_DMX_CUE_0
    Case "PlayDMXCueMax"
      nDMXCommand = #SCS_DMX_PLAY_DMX_CUE_MAX
    Default
      nDMXCommand = -1
  EndSelect
  ProcedureReturn nDMXCommand
EndProcedure

Procedure.s decodeDMXDevType(nDMXDevType)
  Protected sDMXDevType.s
  
  Select nDMXDevType
    Case #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB
      sDMXDevType = "OPEN DMX USB"
    Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO
      sDMXDevType = "DMX USB PRO"
    Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
      sDMXDevType = "DMX USB PRO Mk2"
    Case #SCS_DMX_DEV_FTDI_USB_RS485
      sDMXDevType = "FT USB_RS485"
  EndSelect
  ProcedureReturn sDMXDevType
EndProcedure

Procedure.s decodeDMXFadeActionFI(nFadeActionFI)
  Protected sFadeActionFI.s
  
  Select nFadeActionFI
    Case #SCS_DMX_FI_FADE_ACTION_NONE
      sFadeActionFI = "None"
    Case #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
      sFadeActionFI = "Def"
    Case #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
      sFadeActionFI = "User"
    Case #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
      sFadeActionFI = "Up"
    Case #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
      sFadeActionFI = "Down"
    Case #SCS_DMX_FI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
      sFadeActionFI = "Others"
    Case #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
      sFadeActionFI = "DoNot"
    Default
      sFadeActionFI = "None"
  EndSelect
  ProcedureReturn sFadeActionFI
EndProcedure

Procedure encodeDMXFadeActionFI(sFadeActionFI.s)
  Protected nFadeActionFI
  
  Select sFadeActionFI
    Case "None"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_NONE
    Case "Def", "Prod"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    Case "User"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
    Case "Up"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
    Case "Down"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
    Case "Others"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
    Case "DoNot"
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
    Default
      nFadeActionFI = #SCS_DMX_FI_FADE_ACTION_NONE
  EndSelect
  ProcedureReturn nFadeActionFI
EndProcedure

Procedure.s decodeDMXFadeActionBL(nFadeActionBL)
  Protected sFadeActionBL.s
  
  Select nFadeActionBL
    Case #SCS_DMX_BL_FADE_ACTION_NONE
      sFadeActionBL = "None"
    Case #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
      sFadeActionBL = "Def"
    Case #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
      sFadeActionBL = "User"
    Default
      sFadeActionBL = "None"
  EndSelect
  ProcedureReturn sFadeActionBL
EndProcedure

Procedure encodeDMXFadeActionBL(sFadeActionBL.s)
  Protected nFadeActionBL
  
  Select sFadeActionBL
    Case "None"
      nFadeActionBL = #SCS_DMX_BL_FADE_ACTION_NONE
    Case "Def", "Prod"
      nFadeActionBL = #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    Case "User"
      nFadeActionBL = #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
    Default
      nFadeActionBL = #SCS_DMX_BL_FADE_ACTION_NONE
  EndSelect
  ProcedureReturn nFadeActionBL
EndProcedure

Procedure.s decodeDMXFadeActionDI(nFadeActionDI)
  Protected sFadeActionDI.s
  
  Select nFadeActionDI
    Case #SCS_DMX_DI_FADE_ACTION_NONE
      sFadeActionDI = "None"
    Case #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
      sFadeActionDI = "Def"
    Case #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
      sFadeActionDI = "User"
    Case #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME
      sFadeActionDI = "Up"
    Case #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
      sFadeActionDI = "Down"
    Case #SCS_DMX_DI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
      sFadeActionDI = "Others"
    Case #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
      sFadeActionDI = "DoNot"
    Default
      sFadeActionDI = "None"
  EndSelect
  ProcedureReturn sFadeActionDI
EndProcedure

Procedure encodeDMXFadeActionDI(sFadeActionDI.s)
  Protected nFadeActionDI
  
  Select sFadeActionDI
    Case "None"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_NONE
    Case "Def", "Prod"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    Case "User"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
    Case "Up"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME
    Case "Down"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
    Case "Others"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
    Case "DoNot"
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
    Default
      nFadeActionDI = #SCS_DMX_DI_FADE_ACTION_NONE
  EndSelect
  ProcedureReturn nFadeActionDI
EndProcedure

Procedure.s decodeDMXFadeActionDC(nFadeActionDC)
  Protected sFadeActionDC.s
  
  Select nFadeActionDC
    Case #SCS_DMX_DC_FADE_ACTION_NONE
      sFadeActionDC = "None"
    Case #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
      sFadeActionDC = "Def"
    Case #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
      sFadeActionDC = "User"
    Case #SCS_DMX_DC_FADE_ACTION_USE_FADEUP_TIME
      sFadeActionDC = "Up"
    Case #SCS_DMX_DC_FADE_ACTION_USE_FADEDOWN_TIME
      sFadeActionDC = "Down"
    Case #SCS_DMX_DC_FADE_ACTION_USE_FADEOUTOTHERS_TIME
      sFadeActionDC = "Others"
    Case #SCS_DMX_DC_FADE_ACTION_DO_NOT_FADEOUTOTHERS
      sFadeActionDC = "DoNot"
    Default
      sFadeActionDC = "None"
  EndSelect
  ProcedureReturn sFadeActionDC
EndProcedure

Procedure encodeDMXFadeActionDC(sFadeActionDC.s)
  Protected nFadeActionDC
  
  Select sFadeActionDC
    Case "None"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_NONE
    Case "Def", "Prod"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
    Case "User"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
    Case "Up"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_USE_FADEUP_TIME
    Case "Down"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_USE_FADEDOWN_TIME
    Case "Others"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_USE_FADEOUTOTHERS_TIME
    Case "DoNot"
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_DO_NOT_FADEOUTOTHERS
    Default
      nFadeActionDC = #SCS_DMX_DC_FADE_ACTION_NONE
  EndSelect
  ProcedureReturn nFadeActionDC
EndProcedure

Procedure.s decodeDMXChaseMode(nChaseMode)
  PROCNAMEC()
  Protected sDecoded.s

  Select nChaseMode
    Case #SCS_DMX_CHASE_MODE_FORWARD
      sDecoded = "For"
    Case #SCS_DMX_CHASE_MODE_REVERSE
      sDecoded = "Rev"
    Case #SCS_DMX_CHASE_MODE_BOUNCE
      sDecoded = "Bnc"
    Case #SCS_DMX_CHASE_MODE_RANDOM
      sDecoded = "Rdm"
  EndSelect
  ProcedureReturn sDecoded

EndProcedure

Procedure encodeDMXChaseMode(sChaseMode.s)
  PROCNAMEC()
  Protected nEncoded

  Select sChaseMode
    Case "For"
      nEncoded = #SCS_DMX_CHASE_MODE_FORWARD
    Case "Rev"
      nEncoded = #SCS_DMX_CHASE_MODE_REVERSE
    Case "Bnc"
      nEncoded = #SCS_DMX_CHASE_MODE_BOUNCE
    Case "Rdm"
      nEncoded = #SCS_DMX_CHASE_MODE_RANDOM
    Default
      nEncoded = #SCS_DMX_CHASE_MODE_FORWARD
  EndSelect
  ProcedureReturn nEncoded

EndProcedure

Procedure.s decodeOSCVersionL(nOSCVersion)
  Protected sOSCVersion.s
  
  Select nOSCVersion
    Case #SCS_OSC_VER_1_0
      sOSCVersion = "OSC 1.0"
    Case #SCS_OSC_VER_1_1
      sOSCVersion = "OSC 1.1"
    Default
      sOSCVersion = "" ; indicates not OSC
  EndSelect
  ProcedureReturn sOSCVersion
  
EndProcedure

Procedure.s decodeOSCVersion(nOSCVersion)
  Protected sOSCVersion.s
  
  Select nOSCVersion
    Case #SCS_OSC_VER_1_0
      sOSCVersion = "1.0"
    Case #SCS_OSC_VER_1_1
      sOSCVersion = "1.1"
    Default
      sOSCVersion = "" ; indicates not OSC
  EndSelect
  ProcedureReturn sOSCVersion
  
EndProcedure

Procedure encodeOSCVersion(sOSCVersion.s)
  Protected nOSCVersion
  
  Select sOSCVersion
    Case "1.0"
      nOSCVersion = #SCS_OSC_VER_1_0
    Case "1.1"
      nOSCVersion = #SCS_OSC_VER_1_1
    Default
      nOSCVersion = -1 ; indicates not OSC
  EndSelect
  ProcedureReturn nOSCVersion
EndProcedure

; EOF