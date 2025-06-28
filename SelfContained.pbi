; File SelfContained.pbi

; self-contained procedures, ie procedures that do not call any other procedures (except tracing if required)

EnableExplicit

Procedure.s FormatUsingL(nNumber, sFormat.s)
  ; Print Using example by PB. Free for any use. :) 
  
  ; Usage: string$=Using(nNumber,sFormat) 
  ; string$ = "" if number can't be formatted. 
  ; Only one sFormat per call (see multiple example). 
  
  ; sFormat can contain these characters: 
  ;  # = next digit in number, or nothing if no next digit. 
  ;  0 = next digit in number, or Chr(48) if no next digit. 
  ;  _ = next digit in number, or space if no next digit.
  ;  . = decimal separator (NOT aligned to real decimal position as 'number' is integer, not single or double) - added by MJD
  
  Protected sChar.s, sNumberString.s, t$, d$, u$, d, f, p
  
  sNumberString = Str(nNumber)
  d = Len(sNumberString) + 1 
  f = CountString(sFormat, "#") + CountString(sFormat, "0") + CountString(sFormat, "_")
  
  If d-1 < f+1 ; Number fits into sFormat, so do it. 
    For p = Len(sFormat) To 1 Step -1 
      sChar = Mid(sFormat, p, 1) 
      Select sChar 
        Case "#"
          d - 1
          If d < 1
            d$ = ""
          Else
            d$ = Mid(sNumberString,d,1)
          EndIf
          
        Case "0"
          d - 1
          If d < 1
            d$ = "0"
          Else
            d$ = Mid(sNumberString,d,1)
          EndIf
          
        Case "_"
          d - 1
          If d < 1
            d$ = " "
          Else
            d$ = Mid(sNumberString,d,1)
          EndIf
          
        Case "."  ; added by MJD
          d$ = gsDecimalMarker
          
        Default
          d$ = sChar
          
      EndSelect 
      t$ + d$ 
    Next 
    For p = Len(t$) To 1 Step -1
      u$ + Mid(t$,p,1)
    Next p
  EndIf 
  ProcedureReturn Trim(u$)
  
  ; Examples:
  ;   num=123 
  ;   Debug "Number = "+Str(num) 
  ;   Debug Using(num,"With hash = #####") ; Returns "With hash = 123" 
  ;   Debug Using(num,"With zero = 0,000") ; Returns "With zero = 0,123" 
  ;   Debug Using(num,"With line = $____") ; Returns "With line = $ 123" 
  ;   Debug Using(num,"Multiple  = 0000000 and ")+Using(num,"$#######") 
  
EndProcedure 

Procedure.s FormatUsingQ(qNumber.q, sFormat.s)
  ; based on FormatUsingL()
  
  ; Usage: string$=Using(nNumber,sFormat) 
  ; string$ = "" if number can't be formatted. 
  ; Only one sFormat per call (see multiple example). 
  
  ; sFormat can contain these characters: 
  ;  # = next digit in number, or nothing if no next digit. 
  ;  0 = next digit in number, or Chr(48) if no next digit. 
  ;  _ = next digit in number, or space if no next digit.
  ;  . = decimal separator (NOT aligned to real decimal position as 'number' is integer, not single or double) - added by MJD
  
  Protected sChar.s, sNumberString.s, t$, d$, u$, d, f, p
  
  sNumberString = Str(qNumber)
  d = Len(sNumberString) + 1 
  f = CountString(sFormat, "#") + CountString(sFormat, "0") + CountString(sFormat, "_")
  
  If d-1 < f+1 ; Number fits into sFormat, so do it. 
    For p = Len(sFormat) To 1 Step -1 
      sChar = Mid(sFormat, p, 1) 
      Select sChar 
        Case "#"
          d - 1
          If d < 1
            d$ = ""
          Else
            d$ = Mid(sNumberString,d,1)
          EndIf
          
        Case "0"
          d - 1
          If d < 1
            d$ = "0"
          Else
            d$ = Mid(sNumberString,d,1)
          EndIf
          
        Case "_"
          d - 1
          If d < 1
            d$ = " "
          Else
            d$ = Mid(sNumberString,d,1)
          EndIf
          
        Case "."  ; added by MJD
          d$ = gsDecimalMarker
          
        Default
          d$ = sChar
          
      EndSelect 
      t$ + d$ 
    Next 
    For p = Len(t$) To 1 Step -1
      u$ + Mid(t$,p,1)
    Next p
  EndIf 
  ProcedureReturn Trim(u$)
  
EndProcedure 

Procedure setGlobalError(nErrorCode, nParam1=0, nParam2=0, sInfo.s="", pProcName.s="")
  PROCNAMEC()
  ; no language translation - we want this in English!
  Select nErrorCode
    Case #SCS_ERROR_GADGET_NO_NOT_SET
      gsError = "Gadget No. not set"
    Case #SCS_ERROR_GADGET_NO_INVALID
      gsError = "Gadget No. invalid (" + nParam1 + ")"
    Case #SCS_ERROR_GADGET_NO_OUT_OF_RANGE
      gsError = "Gadget No. out of range (" + nParam1 + ")"
    Case #SCS_ERROR_FONT_NOT_SET
      gsError = "Font No. not set"
    Case #SCS_ERROR_FONT_INVALID
      gsError = "Font No. invalid (" + nParam1 + ")"
    Case #SCS_ERROR_SUBSCRIPT_OUT_OF_RANGE
      gsError = "Subscript out of range (value=" + nParam1 + ", max=" + nParam2 + "), " + sInfo
    Case #SCS_ERROR_ARRAY_SIZE_INVALID
      gsError = "Array size invalid (required=" + nParam1 + ", actual=" + nParam2 + "), " + sInfo
    Case #SCS_ERROR_POINTER_OUT_OF_RANGE
      gsError = "Pointer out of range (value=" + nParam1 + ", max=" + nParam2 + "), " + sInfo
    Case #SCS_ERROR_MISC
      gsError = sInfo
    Default
      gsError = "<unhandled error code>"
  EndSelect
  If Len(pProcName) > 0
    ; gsError + Chr(10) + "Procedure " + pProcName
    gsError + ", Procedure " + pProcName
  EndIf
  debugMsg(sProcName, "gsError=" + gsError)
EndProcedure

Procedure FileExists(sFileName.s, bTrace=#False)
  ; returns true if a file or drive exists
  PROCNAMEC()
  Protected qFileSize.q
  
  If sFileName = grText\sTextPlaceHolder
    debugMsg(sProcName, "place holder 'found':" + sFileName)
    ProcedureReturn #True
  EndIf
  
  ; remainer of this procedure obtained from PB Forum topic "avoid No Disk error?"
  Protected oldmode.l, attribute.l
  ;
  ; *** check if a file exists (as original FileExists() but should skip error messages)
  ;
  ; returns true if the file exists
  ;
  oldmode = SetErrorMode_(1)
  attribute = GetFileAttributes_(@sFileName)
  SetErrorMode_(oldmode)
  If attribute >= 0
    If bTrace
      qFileSize = FileSize(sFileName)
      debugMsg(sProcName, "file found: " + #DQUOTE$ + sFileName + #DQUOTE$ + ", qFileSize=" + qFileSize)
    EndIf
    ProcedureReturn #True
  Else
    GetLastError_()
    SetLastError_(0)
    If bTrace
      debugMsg(sProcName, "file not found: " + sFileName)
    EndIf
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure FolderExists(sPathName.s)
  PROCNAMEC()
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

Procedure.s firstWord(pString.s)
  ProcedureReturn Left(pString, FindString(pString + " ", " ", 1) - 1)
EndProcedure

Procedure.s nextWord(sString.s, nNextWordNo, sWordSeparators.s)
  Protected sMyString.s, sChar.s, sNextWord.s, n, nWordNo, bWordFound
  
  sMyString = sString + Left(sWordSeparators,1)
  nWordNo = 1
  If nNextWordNo = nWordNo
    bWordFound = #True
  EndIf
  For n = 1 To Len(sMyString)
    sChar = Mid(sMyString, n, 1)
    If FindString(sWordSeparators, sChar)
      If bWordFound
        ; must be at the end of the required word, so break
        Break
      EndIf
      nWordNo + 1
      If nWordNo = nNextWordNo
        bWordFound = #True
      EndIf
    EndIf
    If bWordFound
      sNextWord + sChar
    EndIf
  Next n
  ProcedureReturn sNextWord
EndProcedure

Procedure wordCount(sString.s, sWordSeparators.s)
  Protected sMyString.s, sChar.s, n, nWordCount
  
  sMyString = sString + Left(sWordSeparators,1)
  For n = 1 To Len(sMyString)
    sChar = Mid(sMyString, n, 1)
    If FindString(sWordSeparators, sChar)
      nWordCount + 1
    EndIf
  Next n
  ProcedureReturn nWordCount
EndProcedure

Procedure.s formatLevel(fBVLevel.f)
  ; see also traceLevel()
  If fBVLevel = #SCS_NOVOLCHANGE_SINGLE
    ProcedureReturn "(no change)"
  Else
    ProcedureReturn StrF(fBVLevel)
  EndIf
EndProcedure

Procedure.s formatTrim(fTrim.f)
  ProcedureReturn StrF(fTrim,1)
EndProcedure

Procedure.s formatPan(fPan.f)
  If fPan = #SCS_NOPANCHANGE_SINGLE
    ProcedureReturn "(no change)"
  Else
    ProcedureReturn StrF(fPan,2)
  EndIf
EndProcedure

Procedure.s sDBTrimToDisplay(sDBTrim.s)
  Protected sDisplay.s
  
  If Len(Trim(sDBTrim)) = 0
    sDisplay = #SCS_ZERO_DBTRIM
  Else
    sDisplay = Trim(sDBTrim)
  EndIf
  If Right(sDisplay,2) <> "dB"
    sDisplay + "dB"
  EndIf
  ProcedureReturn sDisplay
EndProcedure

Procedure.s ignoreExtension(sFile.s)
  ; PROCNAMEC()
  Protected sExtPart.s, nReqdLength
  
  sExtPart = GetExtensionPart(sFile)
  If sExtPart
    nReqdLength = Len(sFile) - Len(sExtPart) - 1
  Else
    nReqdLength = Len(sFile)
  EndIf
  ProcedureReturn Left(sFile, nReqdLength)
EndProcedure

Procedure.s strB(bBoolean)
  ; note: in an If statement in PB, 0 = #False, anything else (+ve or -ve) = #True
  ; you should therefore NEVER use statements like "If x = #True". It IS acceptable to use "If x", or to use "If x = #False".
  If bBoolean = 0
    ProcedureReturn "#False"
  Else
    ProcedureReturn "#True"
  EndIf
EndProcedure

Procedure.s strPlus(Value)
  ; as Str(Value) but precedes value with a "+" if greater than zero
  If Value > 0
    ProcedureReturn "+" + Str(Value)
  Else
    ProcedureReturn Str(Value)
  EndIf
EndProcedure

Procedure.s strFTrimmed(fValue.f, nNbDecimals=-1)
  Protected sValue.s
  
  If nNbDecimals < 0
    sValue = StrF(fValue)
  Else
    sValue = StrF(fValue, nNbDecimals)
  EndIf
  ; now remove unnecessary trailing zeros and decimal marker
  ; eg for sValue = 123.4500 return 123.45
  ;    for sValue = 123.0000 return 123
  ;    for sValue = 0 return 0
  If FindString(sValue, gsDecimalMarker)
    sValue = RTrim(sValue, "0")
    sValue = RTrim(sValue, gsDecimalMarker)
  EndIf
  ProcedureReturn sValue
EndProcedure

Procedure.s strDTrimmed(dValue.d, nNbDecimals=-1)
  Protected sValue.s
  
  If nNbDecimals < 0
    sValue = StrD(dValue)
  Else
    sValue = StrD(dValue, nNbDecimals)
  EndIf
  ; now remove unnecessary trailing zeros and decimal marker
  ; eg for sValue = 123.4500 return 123.45
  ;    for sValue = 123.0000 return 123
  ;    for sValue = 0 return 0
  If FindString(sValue, gsDecimalMarker)
    sValue = RTrim(sValue, "0")
    sValue = RTrim(sValue, gsDecimalMarker)
  EndIf
  ProcedureReturn sValue
EndProcedure

Procedure.l stringHexToLong(psMyString.s)
  ; PROCNAMEC()
  Protected sMyString.s, nMyLong.l, n
  
  sMyString = UCase(Trim(psMyString))
  nMyLong = 0
  For n = 1 To Len(sMyString)
    nMyLong = (nMyLong << 4) | (FindString(#SCS_HEX_VALID_CHARS, (Mid(sMyString, n, 1)), 1) - 1)
  Next n
  ProcedureReturn nMyLong
EndProcedure

Procedure.s stringNVL(psString.s, psNullValue.s)
  PROCNAMEC()
  If Len(Trim(psString)) = 0
    ProcedureReturn psNullValue
  Else
    ProcedureReturn psString
  EndIf
EndProcedure

Procedure stringToBoolean(psString.s)
  ; PROCNAMEC()
  ; allow for language-specific values, but also language-independent values (see also booleanToString)
  Select psString
    Case grText\sTextTrue, "True", "Y", "1"
      ProcedureReturn #True
    Default
      ProcedureReturn #False
  EndSelect
EndProcedure

Procedure.s stringToHexString(pString.s, pLength=-1)
  ; PROCNAMEC()
  Protected sHexString.s, n
  Protected nLength
  
  If pLength >= 0
    nLength = pLength
  Else
    nLength = Len(pString)
  EndIf
  For n = 1 To nLength
    sHexString + Right("0" + Hex(Asc(Mid(pString, n, 1))), 2)
  Next n
  ProcedureReturn sHexString
EndProcedure

Procedure.s memoryToHexString(*MemoryPtr, nLength, bTrimTrailingZeroBytes=#False)
  ; PROCNAMEC()
  ; Added bTrimTrailingZeroBytes 23Sep2020 11.8.3.2bb to reduce logging line lengths for some DMX data that consists of 512 values, where usually (in testing) there are many trailing zero values
  Protected sHexString.s, n, aByte.a, nLastNonZeroByte, nReqdLength
  
  nLastNonZeroByte = -1
  For n = 0 To nLength-1
    aByte = PeekA(*MemoryPtr+n)
    If aByte > 0
      nLastNonZeroByte = n
    EndIf
    sHexString + Right("0" + Hex(aByte,#PB_Byte), 2)
  Next n
  If bTrimTrailingZeroBytes And nLastNonZeroByte < (nLength-6)
    nReqdLength = (nLastNonZeroByte + 3) * 2 ; "nLastNonZeroByte + 3" because n (and therefore nLastNonZeroByte) is 0-based, and we also want to return a "0000..." at the end
    sHexString = Left(sHexString, nReqdLength) + "..."
  EndIf
  ProcedureReturn sHexString
EndProcedure

Procedure.s stringToNetworkString(pString.s)
  ; PROCNAMEC()
  Protected sNetworkString.s, n
  Protected sChar.s, nAsc
  Protected nLength
  Protected sLowCodes.s = "NUL,SOH,STX,ETX,EOT,ENQ,ACK,BEL,BS,TAB,LF,VT,FF,CR,SO,SI,DLE,DC1,DC2,DC3,DC4,NAK,SYN,ETB,CAN,EM,SUB,ESC,FS,GS,RS,US"
  
  nLength = Len(pString)
  For n = 1 To nLength
    sChar = Mid(pString, n, 1)
    nAsc = Asc(sChar)
    If nAsc < 32
      sChar = "<" + StringField(sLowCodes,nAsc+1,",") + ">"
    ElseIf nAsc = 127
      sChar = "<DEL>"
    EndIf
    sNetworkString + sChar
  Next n
  ProcedureReturn sNetworkString
EndProcedure

Procedure stringToTime(pString.s, pNullIsZero=#False)
  ; PROCNAMEC()
  Protected sString.s, sLower.s
  Protected sMinutes.s, sSeconds.s, nColonPtr
  
  sString = Trim(pString)
  sLower = LCase(sString)
  If sLower = "end" Or sLower = "e"
    ProcedureReturn -1
  ElseIf sLower = "start" Or sLower = "s"
    ProcedureReturn -3
  Else
    If Len(sString) = 0
      If pNullIsZero
        ProcedureReturn 0
      Else
        ProcedureReturn -2
      EndIf
    Else
      nColonPtr = FindString(sString, ":", 1)
      If nColonPtr = 0
        ProcedureReturn ValD(sString) * 1000
      Else
        sMinutes = Left(sString, nColonPtr - 1)
        sSeconds = Right(sString, Len(sString) - nColonPtr)
        ProcedureReturn (ValD(sMinutes) * 60000) + (ValD(sSeconds) * 1000)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure stringToRelativeTime(pString.s)
  ; Also used for non-relative times that may be negative (modified for M2T)
  ; PROCNAMEC()
  Protected nRelativeTime, sString.s, sSign.s
  Protected sMinutes.s, sSeconds.s, nColonPtr
  
  sString = Trim(pString)
  If sString
    sSign = Left(sString,1)
    If sSign = "-" Or sSign = "+"
      sString = Mid(sString,2)
    EndIf
    nColonPtr = FindString(sString, ":", 1)
    If nColonPtr = 0
      nRelativeTime = ValD(sString) * 1000
    Else
      sMinutes = Left(sString, nColonPtr - 1)
      sSeconds = Right(sString, Len(sString) - nColonPtr)
      nRelativeTime = (ValD(sMinutes) * 60000) + (ValD(sSeconds) * 1000)
    EndIf
    If sSign = "-"
      nRelativeTime * -1
    EndIf
  EndIf
  ; debugMsg0(sProcName, "sString=" + sString + ", nRelativeTime=" + nRelativeTime + ", sSign=" + sSign + ", sMinutes=" + sMinutes + ", sSeconds=" + sSeconds + ", nColonPtr=" + nColonPtr)
  ProcedureReturn nRelativeTime
EndProcedure

Procedure.d stringToTimeDbl(pString.s, pNullIsZero=#False)
  ; PROCNAMEC()
  Protected sString.s, sLower.s
  Protected sMinutes.s, sSeconds.s, nColonPtr
  
  sString = Trim(pString)
  sLower = LCase(sString)
  If sLower = "end" Or sLower = "e"
    ProcedureReturn -1.0
  ElseIf sLower = "start" Or sLower = "s"
    ProcedureReturn -3.0
  Else
    If Len(sString) = 0
      If pNullIsZero
        ProcedureReturn 0.0
      Else
        ProcedureReturn -2.0
      EndIf
    Else
      nColonPtr = FindString(sString, ":", 1)
      If nColonPtr = 0
        ProcedureReturn ValD(sString)
      Else
        sMinutes = Left(sString, nColonPtr - 1)
        sSeconds = Right(sString, Len(sString) - nColonPtr)
        ProcedureReturn (ValD(sMinutes) * 60.0) + (ValD(sSeconds))
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure stringToDateSeconds(sTimeOfDay.s)
  PROCNAMEC()
  ; accepts TBC time-of-day and returns this as number of seconds since base date of Date(), which is 01/01/1970 0:00:00
  ; other return values:
  ;  -99 if sTimeOfDay="Manual"
  ;  -2  if sTimeOfDay=""
  Protected sMyString.s
  Protected sHours.s, sMinutes.s, sSeconds.s
  Protected nHours, nMinutes, nSeconds
  Protected nYear, nMonth, nDay
  Protected nPtr, sChar.s, nDateSeconds, sAMPM.s, nAMPMPtr
  
  sMyString = Trim(sTimeOfDay)
  
  If (sMyString = "Manual") Or (sMyString = grText\sTextManual)
    nDateSeconds = -99
    
  ElseIf sMyString
    
    nPtr = FindString(sMyString, ":", 1)
    If nPtr = 0
      nAMPMPtr = FindString(sMyString, "am", 1, #PB_String_NoCase)
      If nAMPMPtr > 0
        sMyString = ReplaceString(sMyString, "am", ":00am", #PB_String_NoCase, 1, 1)
      Else
        nAMPMPtr = FindString(sMyString, "pm", 1, #PB_String_NoCase)
        If nAMPMPtr > 0
          sMyString = ReplaceString(sMyString, "pm", ":00pm", #PB_String_NoCase, 1, 1)
        EndIf
      EndIf
      nPtr = FindString(sMyString, ":", 1)
    EndIf
    
    sHours = Left(sMyString, nPtr - 1)
    If sHours
      nHours = Val(sHours)
    EndIf
    
    nPtr + 1
    sChar = Mid(sMyString, nPtr, 1)
    If (sChar >= "0") And (sChar <= "9")
      sMinutes = sChar
      nPtr + 1
      sChar = Mid(sMyString, nPtr, 1)
      If (sChar >= "0") And (sChar <= "9")
        sMinutes + sChar
        nPtr + 1
      EndIf
    EndIf
    
    If sMinutes
      nMinutes = Val(sMinutes)
    EndIf
    
    If nPtr <= Len(sMyString)
      sChar = Mid(sMyString, nPtr, 1)
      If sChar = ":"
        nPtr + 1
        sChar = Mid(sMyString, nPtr, 1)
        If (sChar >= "0") And (sChar <= "9")
          sSeconds = sChar
          nPtr + 1
          sChar = Mid(sMyString, nPtr, 1)
          If (sChar >= "0") And (sChar <= "9")
            sSeconds + sChar
            nPtr + 1
          EndIf
        EndIf
      EndIf
      
      If sSeconds
        nSeconds = Val(sSeconds)
      EndIf
      
    EndIf
    
    If nPtr <= Len(sMyString)
      sAMPM = UCase(Trim(Mid(sMyString, nPtr))) ; ignore any spaces
      If (sAMPM = "AM") Or (sAMPM = "PM")
        If nHours = 12 And (nMinutes <> 0 Or nSeconds <> 0)
          nHours = 0
        EndIf
        If sAMPM = "PM"
          nHours + 12
        EndIf
      EndIf
    EndIf
    
    ; nTOD = ((((nHours * 60) + nMinutes) * 60) + nSeconds)
    nYear = Year(Date())
    nMonth = Month(Date())
    nDay = Day(Date())
    nDateSeconds = Date(nYear, nMonth, nDay, nHours, nMinutes, nSeconds)
    
  Else
    ; nTOD = -2
    nDateSeconds = -2
  EndIf
  
  ; debugMsg(sProcName, pTOD + ", nDateSeconds=" + Str(nDateSeconds))
  
  ProcedureReturn nDateSeconds
EndProcedure

Procedure.s trimZeroDecimals(pString.s)
  Protected n
  ; procedure to trim trailing zeros from a decimal field.
  ; eg 123.450 is returned as 123.45
  ;    123.000 is returned as 123
  ;    120.000 is returned as 120
  ;    123.456 is returned as 123.456
  
  If FindString(pString, gsDecimalMarker, 1) = 0
    ProcedureReturn pString
  Else
    For n = Len(pString) To 0 Step -1
      If Mid(pString, n, 1) <> "0"
        Break
      EndIf
    Next n
    If Mid(pString, n, 1) = gsDecimalMarker
      ; if right-most character after trim is the decimal marker, then remove that as well
      n - 1
    EndIf
    ProcedureReturn Left(pString, n)
  EndIf
EndProcedure

Procedure.s trimZeroDecimalsHT(pString.s)
  Protected n
  ; procedure to trim trailing 'hundredths' and 'thousandths' zeros from a decimal field.
  ; eg 123.450 is returned as 123.45
  ;    123.000 is returned as 123.0
  ;    120.000 is returned as 120.0
  ;    123.456 is returned as 123.456
  
  ProcedureReturn pString ; INFO: temp(?) disabled this function (NB comment 14Aug2020: don't know why this has been disabled)
  
  If FindString(pString, gsDecimalMarker, 1) = 0
    ProcedureReturn pString + gsDecimalMarker + "0"
  Else
    For n = Len(pString) To 0 Step -1
      If Mid(pString, n, 1) <> "0"
        Break
      EndIf
    Next n
    If Mid(pString, n, 1) = gsDecimalMarker
      ; if right-most character after trim is the decimal marker, then add "0" for the 'tenths' digit
      ProcedureReturn Left(pString, n) + "0"
    Else
      ProcedureReturn Left(pString, n)
    EndIf
  EndIf
EndProcedure

Procedure.s timeToStringBWZ(pTime, pRefTime=0)
  ; Changed 17Oct2022 11.9.6
  ; PROCNAMEC()
  Protected nMinutes, nHundredths, nRefTime, nTmpTime
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  nTmpTime = pTime
  
  ; convert from milliseconds to hundredths
  If nTmpTime > 0 And nTmpTime <> #SCS_CONTINUOUS_END_AT And nTmpTime <> #SCS_CONTINUOUS_LENGTH
    nTmpTime = Round(nTmpTime / 10, #PB_Round_Nearest)
  EndIf
  If nRefTime > 0 And nRefTime <> #SCS_CONTINUOUS_END_AT And nRefTime <> #SCS_CONTINUOUS_LENGTH
    nRefTime = Round(nRefTime / 10, #PB_Round_Nearest)
  EndIf
  
  Select nTmpTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Case 0
      ProcedureReturn ""
    Default
      If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (nTmpTime >= 6000)
        nMinutes = Round(nTmpTime/6000, #PB_Round_Down)
        nHundredths = nTmpTime - (nMinutes * 6000)
      Else
        nMinutes = 0
        nHundredths = nTmpTime
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 6000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        ProcedureReturn Str(nMinutes) + ":" + FormatUsingL(nHundredths, "00.00")
      Else
        ProcedureReturn StrF(nHundredths/100, 2)
      EndIf
  EndSelect
EndProcedure

Procedure.s timeToStringBWZD(pTime, pRefTime=0)
  ; PROCNAMEC()
  ; as timeToStringBWZ() but seconds in tenths instead of hundredths
  Protected nMinutes, nTenths, nRefTime, nTmpTime
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  nTmpTime = pTime
  
  ; convert from milliseconds to tenths
  If nTmpTime > 0 And nTmpTime <> #SCS_CONTINUOUS_END_AT And nTmpTime <> #SCS_CONTINUOUS_LENGTH
    nTmpTime = Round(nTmpTime / 100, #PB_Round_Nearest)
  EndIf
  If nRefTime > 0 And nRefTime <> #SCS_CONTINUOUS_END_AT And nRefTime <> #SCS_CONTINUOUS_LENGTH
    nRefTime = Round(nRefTime / 100, #PB_Round_Nearest)
  EndIf
  
  Select nTmpTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Case 0
      ProcedureReturn ""
    Default
      If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (nTmpTime >= 600)
        nMinutes = Round(nTmpTime/600, #PB_Round_Down)
        nTenths = nTmpTime - (nMinutes * 600)
      Else
        nMinutes = 0
        nTenths = nTmpTime
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 60000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        ProcedureReturn Str(nMinutes) + ":" + FormatUsingL(nTenths, "00.0")
      Else
        ProcedureReturn StrF(nTenths/10, 1)
      EndIf
  EndSelect
EndProcedure

Procedure.s timeToStringBWZT(pTime, pRefTime=0)
  ; PROCNAMEC()
  ; as timeToStringBWZ() but seconds in thousandths instead of hundredths
  Protected nMinutes, nMilliSeconds, nRefTime, sTime.s
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  Select pTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Case 0
      ProcedureReturn ""
    Default
      If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (pTime >= 60000)
        nMinutes = Round(pTime/60000, #PB_Round_Down)
        nMilliSeconds = pTime - (nMinutes * 60000)
      Else
        nMinutes = 0
        nMilliSeconds = pTime
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 60000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        sTime = Str(nMinutes) + ":" + FormatUsingL(nMilliSeconds, "00.000")
      Else
        sTime = StrF(nMilliSeconds/1000, 3)
      EndIf
      ProcedureReturn trimZeroDecimalsHT(sTime)
  EndSelect
EndProcedure

Procedure.s timeToString(pTime, pRefTime=0, bShowHours=#False, bRelativeTime=#False)
  ; Changed 17Oct2022 11.9.6
  ; PROCNAMEC()
  Protected nHours, nMinutes, nHundredths, nRefTime, nTmpTime
  Protected sTime.s, bTimeSet, sSign.s
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  nTmpTime = pTime
  
  ; convert from milliseconds to hundredths
  If bRelativeTime
    nTmpTime = Round(nTmpTime / 10, #PB_Round_Nearest)
  ElseIf nTmpTime > 0 And nTmpTime <> #SCS_CONTINUOUS_END_AT And nTmpTime <> #SCS_CONTINUOUS_LENGTH
    nTmpTime = Round(nTmpTime / 10, #PB_Round_Nearest)
  EndIf
  If nRefTime > 0 And nRefTime <> #SCS_CONTINUOUS_END_AT And nRefTime <> #SCS_CONTINUOUS_LENGTH
    nRefTime = Round(nRefTime / 10, #PB_Round_Nearest)
  EndIf
  
  If bRelativeTime
    ; 'relative times' must always be displayed with a leading + or -
    If nTmpTime >= 0
      sSign = "+"
    Else
      sSign = "-"
      nTmpTime * -1
    EndIf
  Else
    Select pTime
      Case -1
        sTime = "end"
        bTimeSet = #True
      Case -2
        sTime = ""
        bTimeSet = #True
      Case -3
        sTime = "start"
        bTimeSet = #True
      Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
        sTime = ""
        bTimeSet = #True
    EndSelect
  EndIf
  
  If bTimeSet = #False
    If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (nTmpTime >= 6000)
      If bShowHours
        nHours = Round(nTmpTime / 360000, #PB_Round_Down)
        nTmpTime - (nHours * 360000)
      EndIf
      nMinutes = Round(nTmpTime / 6000, #PB_Round_Down)
      nTmpTime - (nMinutes * 6000)
      nHundredths = nTmpTime
    Else
      nHundredths = nTmpTime
    EndIf
    If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 6000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
      If bShowHours And nHours > 0
        sTime = Str(nHours) + ":" + RSet(Str(nMinutes),2,"0")  + ":" + FormatUsingL(nHundredths, "00.00")
      Else
        sTime = Str(nMinutes) + ":" + FormatUsingL(nHundredths, "00.00")
      EndIf
    Else
      sTime = StrF(nHundredths/100, 2)
    EndIf
  EndIf
  ProcedureReturn Trim(sSign + sTime)
EndProcedure

Procedure.s timeToStringT(pTime, pRefTime=0)
  ; PROCNAMEC()
  ; as timeToString() but seconds in thousandths instead of hundredths
  Protected nMinutes, nMilliSeconds, nRefTime, sTime.s
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  Select pTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Default
      If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (pTime >= 60000)
        nMinutes = Round(pTime/60000, #PB_Round_Down)
        nMilliSeconds = pTime - (nMinutes * 60000)
      Else
        nMinutes = 0
        nMilliSeconds = pTime
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 60000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        sTime = Str(nMinutes) + ":" + FormatUsingL(nMilliSeconds, "00.000")
      Else
        sTime = StrF(nMilliSeconds/1000, 3)
      EndIf
      ProcedureReturn trimZeroDecimalsHT(sTime)
  EndSelect
EndProcedure

Procedure.s timeToStringD(pTime, pRefTime=0, pDropDecimalIfZero=#False)
  ; PROCNAMEC()
  ; as timeToString() but seconds in tenths instead of hundredths
  Protected nMinutes, nTenths, nRefTime, sTime.s, nTmpTime
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  nTmpTime = pTime
  
  ; convert from milliseconds to tenths
  If nTmpTime > 0 And nTmpTime <> #SCS_CONTINUOUS_END_AT And nTmpTime <> #SCS_CONTINUOUS_LENGTH
    nTmpTime = Round(nTmpTime / 100, #PB_Round_Nearest)
  EndIf
  If nRefTime > 0 And nRefTime <> #SCS_CONTINUOUS_END_AT And nRefTime <> #SCS_CONTINUOUS_LENGTH
    nRefTime = Round(nRefTime / 100, #PB_Round_Nearest)
  EndIf
  Select nTmpTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Default
      If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (nTmpTime >= 600)
        nMinutes = Round(nTmpTime / 600, #PB_Round_Down)
        nTenths = nTmpTime - (nMinutes * 600)
      Else
        nMinutes = 0
        nTenths = nTmpTime
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 60000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        sTime = Str(nMinutes) + ":" + FormatUsingL(nTenths, "00.0")
      Else
        sTime = StrF(nTenths/10, 1)
      EndIf
      sTime = trimZeroDecimalsHT(sTime)
      ;' sTime now contains 1 decimal place, eg 123.4, or 123.0
      If pDropDecimalIfZero
        sTime = RTrim(RTrim(sTime,"0"),".")
      EndIf
      ProcedureReturn sTime
  EndSelect
EndProcedure

Procedure.s timeToStringS(pTime, pRefTime=0)
  ; PROCNAMEC()
  ; as timeToString() but seconds only instead of hundredths
  Protected nMinutes, nSeconds, nRefTime, sTime.s, nTmpTime
  
  nRefTime = pRefTime
  If nRefTime = 0
    nRefTime = pTime
  EndIf
  nTmpTime = pTime
  
  ; convert from milliseconds to seconds
  If nTmpTime > 0 And nTmpTime <> #SCS_CONTINUOUS_END_AT And nTmpTime <> #SCS_CONTINUOUS_LENGTH
    nTmpTime = Round(nTmpTime / 1000, #PB_Round_Nearest)
  EndIf
  If nRefTime > 0 And nRefTime <> #SCS_CONTINUOUS_END_AT And nRefTime <> #SCS_CONTINUOUS_LENGTH
    nRefTime = Round(nRefTime / 1000, #PB_Round_Nearest)
  EndIf
  
  Select nTmpTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Default
      If nTmpTime >= 60
        nMinutes = Round(nTmpTime / 60, #PB_Round_Down)
        nSeconds = nTmpTime - (nMinutes * 60)
      Else
        nMinutes = 0
        nSeconds = nTmpTime
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 60000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        sTime = Str(nMinutes) + ":" + FormatUsingL(nSeconds, "00")
      Else
        sTime = Str(nSeconds)
      EndIf
      ProcedureReturn sTime
  EndSelect
EndProcedure

Procedure.s timeDblToStringHT(pTime.d, pRefTime=0)
  ; PROCNAMEC()
  ; as timeToString() but seconds in hundred-thousandths - used for cue points
  Protected nMinutes, nHTSeconds, nRefTime, sTime.s
  
  ; debugMsg(sProcName, "pTime=" + StrD(pTime,4) + ", pRefTime=" + pRefTime)
  nRefTime = pRefTime
  If nRefTime <= 0
    nRefTime = pTime * 1000 ; nb RefTime is in milliseconds
  EndIf
  Select pTime
    Case -1
      ProcedureReturn "end"
    Case -2
      ProcedureReturn ""
    Case -3
      ProcedureReturn "start"
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      ProcedureReturn ""
    Default
      If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (pTime >= 60)
        nMinutes = Round(pTime / 60, #PB_Round_Down)
        nHTSeconds = (pTime - (nMinutes * 60)) * 100000
      Else
        nMinutes = 0
        nHTSeconds = pTime * 100000
      EndIf
      If (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A And (nMinutes > 0 Or nRefTime > 60000)) Or grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B
        sTime = Str(nMinutes) + ":" + FormatUsingL(nHTSeconds, "00.00000")
        ; debugMsg(sProcName, "nMinutes=" + nMinutes + ", nHTSeconds=" + nHTSeconds + ", sTime=" + sTime)
      Else
        sTime = StrF(nHTSeconds / 100000, 5)
      EndIf
      ; debugMsg(sProcName, "returning " + #DQUOTE$ + sTime + #DQUOTE$)
      ProcedureReturn sTime   ; do not trim excess zeros from right
  EndSelect
EndProcedure

Procedure.s timeToStringHHMMSS(pTime)
  ; PROCNAMEC()
  Protected nTimeInSeconds, nHours, nMinutes, nSeconds
  Protected sTime.s
  
  nTimeInSeconds = Round(pTime / 1000, #PB_Round_Nearest)
  nHours = Round(nTimeInSeconds / 3600, #PB_Round_Down)
  nTimeInSeconds - (nHours * 3600)
  nMinutes = Round(nTimeInSeconds / 60, #PB_Round_Down)
  nSeconds = nTimeInSeconds - (nMinutes * 60)
  If nHours > 0
    sTime = Str(nHours) + ":" + RSet(Str(nMinutes),2,"0") + ":" + RSet(Str(nSeconds),2,"0")
  Else
    sTime = Str(nMinutes) + ":" + RSet(Str(nSeconds),2,"0")
  EndIf
  ProcedureReturn sTime
EndProcedure

Procedure.s ttsz(pTime)
  ; shorthand function name
  ProcedureReturn timeToString(pTime, pTime)
EndProcedure

Procedure.s ttszt(pTime)
  ; shorthand function name
  ProcedureReturn timeToStringT(pTime, pTime)
EndProcedure

Procedure.s RelStartToString(pRelStartTime, pRelStartMode)
  PROCNAMEC()
  Protected nRelStartTime
  Protected nMinutes, nMilliSeconds, nRefTime
  Protected sRelStartString.s
  
  nRelStartTime = pRelStartTime
  If nRelStartTime = -2
    If pRelStartMode = #SCS_RELSTART_DEFAULT
      ProcedureReturn ""
    Else
      nRelStartTime = 0
    EndIf
  EndIf
  
  nRefTime = nRelStartTime
  Select pRelStartMode
    Case #SCS_RELSTART_AS_PREV_SUB
      sRelStartString = "S+"
    Case #SCS_RELSTART_AE_PREV_SUB
      sRelStartString = "E+"
    Default
      sRelStartString = ""
  EndSelect
  If (grGeneralOptions\nTimeFormat & #SCS_TIME_FORMAT_A_OR_B) And (nRelStartTime >= 60000)
    nMinutes = Round(nRelStartTime / 60000, #PB_Round_Down)
    nMilliSeconds = nRelStartTime - (nMinutes * 60000)
  Else
    nMinutes = 0
    nMilliSeconds = nRelStartTime
  EndIf
  If ((grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_A) And ((nMinutes > 0 Or nRefTime > 60000))) Or (grGeneralOptions\nTimeFormat = #SCS_TIME_FORMAT_B)
    sRelStartString + Str(nMinutes) + ":" + FormatUsingL(Round(nMilliSeconds/10, #PB_Round_Nearest), "00.00")
  Else
    sRelStartString + StrF(nMilliSeconds / 1000, 2)
  EndIf
  ProcedureReturn sRelStartString
EndProcedure

Procedure.s TimeInSecsToString(nTimeInSecs)
  PROCNAMEC()
  Protected nHours, nMinutes, nSeconds
  Protected sTime.s
  
  nSeconds = nTimeInSecs - (nHours * 3600) - (nMinutes * 60)
  If nTimeInSecs >= 3600
    nHours = Round(nTimeInSecs / 3600, #PB_Round_Down)
    sTime = Str(nHours) + ":"
    nMinutes = Round((nTimeInSecs - (nHours * 3600)) / 60, #PB_Round_Down)
    If nMinutes < 10
      sTime + "0" + Str(nMinutes) + ":"
    Else
      sTime + Str(nMinutes) + ":"
    EndIf
    nSeconds = nTimeInSecs - (nHours * 3600) - (nMinutes * 60)
  Else
    nMinutes = Round(nTimeInSecs / 60, #PB_Round_Down)
    sTime + Str(nMinutes) + ":"
    nSeconds = nTimeInSecs - (nMinutes * 60)
  EndIf
  If nSeconds < 10
    sTime + "0" + Str(nSeconds)
  Else
    sTime + Str(nSeconds)
  EndIf
  
  ProcedureReturn sTime
  
EndProcedure

Procedure.s trimAtNull(pString.s)
  ; PROCNAMEC()
  If FindString(pString, Chr(0), 1) = 0
    ProcedureReturn pString
  Else
    ProcedureReturn Left(pString, FindString(pString, Chr(0), 1) - 1)
  EndIf
EndProcedure

Procedure getIndexForVideoWindowNo(nWindowNo)
  ProcedureReturn nWindowNo - #WV2
EndProcedure

Procedure getIndexForMonitorWindowNo(nWindowNo)
  ProcedureReturn nWindowNo - #WM2
EndProcedure

Procedure getVidPicTargetForOutputScreen(nOutputScreen)
  ProcedureReturn #SCS_VID_PIC_TARGET_F2 + nOutputScreen - 2
EndProcedure

Procedure getVidPicTargetForVideoWindowNo(nWindowNo)
  ProcedureReturn #SCS_VID_PIC_TARGET_F2 + nWindowNo - #WV2
EndProcedure

Procedure.s decodeNumChans(nNrOfOutputChans)
  Protected sNumChans.s
  
  Select nNrOfOutputChans
    Case 1
      sNumChans = "1 (mono)"
    Case 2
      sNumChans = "2 (stereo)"
    Case 3 To 16
      sNumChans = Str(nNrOfOutputChans) + " (multi)"
    Default
      sNumChans = Str(nNrOfOutputChans)
  EndSelect
  
  ProcedureReturn sNumChans
  
EndProcedure

Procedure encodeFocusPoint(sFocusPoint.s)
  Protected nFocusPoint
  
  Select sFocusPoint
    Case "Playing"
      nFocusPoint = #SCS_FOCUS_LAST_PLAYING
    Case "NextManual"
      nFocusPoint = #SCS_FOCUS_NEXT_MANUAL
    Default
      nFocusPoint = #SCS_FOCUS_NEXT_MANUAL
  EndSelect
  ProcedureReturn nFocusPoint
EndProcedure

Procedure.s decodeFocusPoint(nFocusPoint)
  Protected sFocusPoint.s
  
  Select nFocusPoint
    Case #SCS_FOCUS_LAST_PLAYING
      sFocusPoint = "Playing"
    Default
      sFocusPoint = "NextManual"
  EndSelect
  ProcedureReturn sFocusPoint
EndProcedure

Procedure encodeGridClickAction(sGridClickAction.s)
  Protected nGridClickAction
  
  Select sGridClickAction
    Case "GoToCue"
      nGridClickAction = #SCS_GRDCLICK_GOTO_CUE
    Case "GoBtnOnly"
      nGridClickAction = #SCS_GRDCLICK_SET_GO_BUTTON_ONLY
    Case "Ignore"
      nGridClickAction = #SCS_GRDCLICK_IGNORE
    Default
      nGridClickAction = #SCS_GRDCLICK_GOTO_CUE
  EndSelect
  ProcedureReturn nGridClickAction
EndProcedure

Procedure.s decodeGridClickAction(nGridClickAction)
  Protected sGridClickAction.s
  
  Select nGridClickAction
    Case #SCS_GRDCLICK_GOTO_CUE
      sGridClickAction = "GoToCue"
    Case #SCS_GRDCLICK_SET_GO_BUTTON_ONLY
      sGridClickAction = "GoBtnOnly"
    Case #SCS_GRDCLICK_IGNORE
      sGridClickAction = "Ignore"
  EndSelect
  ProcedureReturn sGridClickAction
EndProcedure

Procedure InStr(pString.s, pFindString.s)
  ProcedureReturn FindString(pString, pFindString, 1)
EndProcedure

Procedure skipChars(sString.s, sCharsToSkip.s, nStartPos, nMode=#PB_String_CaseSensitive)
  ; from the specifed nStartPos in sString, skip past all characters that match a character in sCharsToSkip, and return a pointer to the next character in sString
  ; if all remaining characters in sString are skipped then return 0
  ; eg: skipChars("hello   world", " ", 6) returns 9
  ;     skipChars("abc123def", "0123456789", 4) returns 7
  Protected n, nNewPos, nSkipPtr
  Protected sChar.s
  
  For n = nStartPos To Len(sString)
    sChar = Mid(sString, n, 1)
    nSkipPtr = FindString(sCharsToSkip, sChar, nMode)
    If nSkipPtr = 0
      nNewPos = n
      Break
    EndIf
  Next n
  ProcedureReturn nNewPos
EndProcedure

Procedure.s getDriveRootFolder(sFileName.s)
  Protected nStartPos, nPos, sDriveRootFolder.s
  
  If Left(sFileName,2) = "\\"
    nStartPos = 3   ; will return a root folder like "\\LAPTOP3\"
  Else
    nStartPos = 1   ; will return a root folder like "C:\"
  EndIf
  
  nPos = FindString(sFileName, "\", nStartPos)
  If nPos > 0
    sDriveRootFolder = UCase(Left(sFileName, nPos))
  EndIf
  ProcedureReturn sDriveRootFolder
  
EndProcedure

Procedure getDriveType(sDriveRootFolder.s)
  Static sPrevDriveRootFolder.s
  Static nDriveType.l   ; long
  
  If Len(sDriveRootFolder) = 0
    ; shouldn't happen
    ProcedureReturn #DRIVE_UNKNOWN
  Else
    If sDriveRootFolder <> sPrevDriveRootFolder
      nDriveType = GetDriveType_(sDriveRootFolder)
      ; nb GetDriveType_("\\LAPTOP3\") called from LAPTOP4 returned DRIVE_NO_ROOT_DIR but I think it should have returned #DRIVE_REMOTE as it's a network drive.
      ; trouble is, DRIVE_NO_ROOT_DIR is also returned for GetDriveType_("\\LAPTOP4\") called from LAPTOP4, ie the same machine.
      ; so comment out the following 'fix' for now.
      ; If nDriveType = #DRIVE_NO_ROOT_DIR
        ; If Len(sDriveRootFolder) > 2
          ; If Left(sDriveRootFolder,2) = "\\"
            ; nDriveType = #DRIVE_REMOTE
          ; EndIf
        ; EndIf
      ; EndIf
      sPrevDriveRootFolder = sDriveRootFolder
    EndIf
    ProcedureReturn nDriveType
  EndIf
EndProcedure

Procedure indexForComboBoxRow(hComboBox, sText.s, nIndexIfNotFound = -1, bCheckFirstWordOnly = #False)
  ; PROCNAMEC()
  Protected nListIndex, n2, m, bFound
  Protected sMyText.s, sTmp.s
  Protected nCount
  
  sMyText = Trim(sText)
  nListIndex = nIndexIfNotFound
  nCount = CountGadgetItems(hComboBox)
  If nCount = 0
    nListIndex = -1
  EndIf
  
  For m = 0 To (nCount - 1)
    If Trim(GetGadgetItemText(hComboBox,m)) = sMyText
      bFound = #True
      nListIndex = m
      Break
    EndIf
  Next m
  
  If bFound = #False
    If bCheckFirstWordOnly
      n2 = FindString(sMyText, " ", 1)
      If n2 > 1
        sMyText = Left(sMyText, n2 - 1)
      EndIf
      For m = 0 To (nCount - 1)
        sTmp = Trim(GetGadgetItemText(hComboBox,m))
        n2 = FindString(sTmp, " ", 1)
        If n2 > 1
          sTmp = Left(sTmp, n2 - 1)
        EndIf
        If sTmp = sMyText
          bFound = #True
          nListIndex = m
          Break
        EndIf
      Next m
    EndIf
  EndIf
  
  ProcedureReturn nListIndex
EndProcedure

Procedure indexForPhysDevComboBoxRow(hComboBox, sText.s, nIndexIfNotFound = -1)
  Protected nListIndex, n2, m, bFound
  Protected sMyText.s, sTmp.s
  Protected nCount, nPass
  
  sMyText = Trim(sText)
  nListIndex = nIndexIfNotFound
  nCount = CountGadgetItems(hComboBox)
  If nCount = 0
    nListIndex = -1
  EndIf
  
  For nPass = 1 To 2
    For m = 0 To (nCount - 1)
      If comparePhysDevDescs(Trim(GetGadgetItemText(hComboBox,m)), sMyText, nPass)
        bFound = #True
        nListIndex = m
        Break
      EndIf
    Next m
    If bFound
      Break
    EndIf
  Next nPass
  
  ProcedureReturn nListIndex
EndProcedure

Procedure indexForComboBoxData(hComboBox, nData, nIndexIfNotFound=-1)
  Protected nListIndex, m, nCount
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(hComboBox)
  nListIndex = nIndexIfNotFound
  Select gaGadgetProps(nGadgetPropsIndex)\nModGadgetType
    Case #SCS_MG_COMBOBOX
      nCount = ComboBoxEx::CountItems(hComboBox)
      For m = 0 To (nCount - 1)
        If ComboBoxEx::GetItemData(hComboBox, m) = nData
          nListIndex = m
          Break
        EndIf
      Next m
    Default
      nCount = CountGadgetItems(hComboBox)
      For m = 0 To (nCount - 1)
        If GetGadgetItemData(hComboBox, m) = nData
          nListIndex = m
          Break
        EndIf
      Next m
  EndSelect
  
  ProcedureReturn nListIndex
EndProcedure

Procedure.i setComboBoxByString(hComboBox, sData.s, nIndexIfNotFound=-1)
  Protected nListIndex, m
  Protected nCount
  
  nListIndex = nIndexIfNotFound
  nCount = CountGadgetItems(hComboBox)
  
  For m = 0 To (nCount - 1)
    If GetGadgetItemText(hComboBox, m) = sData
      nListIndex = m
      Break
    EndIf
  Next m
  
  If GGS(hComboBox) <> nListIndex
    SGS(hComboBox, nListIndex)
  EndIf
  
  ProcedureReturn nListIndex
EndProcedure

Procedure setComboBoxByData(hComboBox, nData, nIndexIfNotFound=-1)
  Protected nListIndex, m
  Protected nCount
  
  nListIndex = nIndexIfNotFound
  nCount = CountGadgetItems(hComboBox)
  
  For m = 0 To (nCount - 1)
    If GetGadgetItemData(hComboBox, m) = nData
      nListIndex = m
      Break
    EndIf
  Next m
  
  If GGS(hComboBox) <> nListIndex
    SGS(hComboBox, nListIndex)
  EndIf
  
  ProcedureReturn nListIndex ; Added 10Jun2021 11.8.5ag
EndProcedure

Procedure indexForGadgetItemData(nGadgetNo, nData, nIndexIfNotFound=-1)
  Protected nListIndex, m
  Protected nCount
  
  nListIndex = nIndexIfNotFound
  nCount = CountGadgetItems(nGadgetNo)
  
  For m = 0 To (nCount - 1)
    If GetGadgetItemData(nGadgetNo, m) = nData
      nListIndex = m
      Break
    EndIf
  Next m
  
  ProcedureReturn nListIndex
EndProcedure

Procedure setGadgetItemByData(nGadgetNo, nData, nIndexIfNotFound=-1)
  Protected nListIndex, m
  Protected nCount
  
  nListIndex = nIndexIfNotFound
  nCount = CountGadgetItems(nGadgetNo)
  
  For m = 0 To (nCount - 1)
    If GetGadgetItemData(nGadgetNo, m) = nData
      nListIndex = m
      Break
    EndIf
  Next m
  
  If GGS(nGadgetNo) <> nListIndex
    SGS(nGadgetNo, nListIndex)
  EndIf
  
  ProcedureReturn nListIndex
EndProcedure

Procedure getCurrentItemData(nGadgetNo, nDataIfNotFound=-1)
  Protected nItem, nItemData
  
  nItemData = nDataIfNotFound
  Select getModGadgetType(nGadgetNo)
    Case #SCS_MG_COMBOBOX
      nItem = ComboBoxEx::GetState(nGadgetNo)
      If nItem >= 0
        nItemData = ComboBoxEx::GetItemData(nGadgetNo, nItem)
      EndIf
    Default
      nItem = GetGadgetState(nGadgetNo)
      If nItem >= 0
        nItemData = GetGadgetItemData(nGadgetNo, nItem)
      EndIf
  EndSelect
  ProcedureReturn nItemData
EndProcedure

Procedure.s decodeEvent(nEvent)
  Protected sEvent.s
  Select nEvent
    Case #PB_Event_Menu
      sEvent = "#PB_Event_Menu"
    Case #PB_Event_Gadget
      sEvent = "#PB_Event_Gadget"
    Case #PB_Event_SysTray
      sEvent = "#PB_Event_SysTray"
    Case #PB_Event_Timer
      sEvent = "#PB_Event_Timer"
    Case #PB_Event_CloseWindow
      sEvent = "#PB_Event_CloseWindow"
    Case #PB_Event_Repaint
      sEvent = "#PB_Event_Repaint"
    Case #PB_Event_SizeWindow
      sEvent = "#PB_Event_SizeWindow"
    Case #PB_Event_MoveWindow
      sEvent = "#PB_Event_MoveWindow"
    Case #PB_Event_MinimizeWindow
      sEvent = "#PB_Event_MinimizeWindow"
    Case #PB_Event_MaximizeWindow
      sEvent = "#PB_Event_MaximizeWindow"
    Case #PB_Event_RestoreWindow
      sEvent = "#PB_Event_RestoreWindow"
    Case #PB_Event_ActivateWindow
      sEvent = "#PB_Event_ActivateWindow"
    Case #PB_Event_DeactivateWindow
      sEvent = "#PB_Event_DeactivateWindow"
    Case #PB_Event_WindowDrop
      sEvent = "#PB_Event_WindowDrop"
    Case #PB_Event_GadgetDrop
      sEvent = "#PB_Event_GadgetDrop"
    Case #PB_Event_RightClick
      sEvent = "#PB_Event_RightClick"
    Case #PB_Event_LeftClick
      sEvent = "#PB_Event_LeftClick"
    Case #PB_Event_LeftDoubleClick
      sEvent = "#PB_Event_LeftDoubleClick"
      
    Case #WM_KEYDOWN
      sEvent = "#WM_KEYDOWN"
    Case #WM_KEYUP
      sEvent = "#WM_KEYUP"
    Case #WM_LBUTTONDOWN
      sEvent = "#WM_LBUTTONDOWN"
    Case #WM_LBUTTONUP
      sEvent = "#WM_LBUTTONUP"
    Case #WM_MOUSELEAVE
      sEvent = "#WM_MOUSELEAVE"
    Case #WM_MOUSEMOVE
      sEvent = "#WM_MOUSEMOVE"
    Case #WM_NCLBUTTONDOWN
      sEvent = "#WM_NCLBUTTONDOWN"
    Case #WM_NCLBUTTONUP
      sEvent = "#WM_NCLBUTTONUP"
    Case #WM_NCLBUTTONDBLCLK
      sEvent = "#WM_NCLBUTTONDBLCLK"
    Case #WM_NCMOUSELEAVE
      sEvent = "#WM_NCMOUSELEAVE"
    Case #WM_NCMOUSEMOVE
      sEvent = "#WM_NCMOUSEMOVE"
    Case #WM_NCRBUTTONDOWN
      sEvent = "#WM_NCRBUTTONDOWN"
    Case #WM_NCRBUTTONUP
      sEvent = "#WM_NCRBUTTONUP"
    Case #WM_NCRBUTTONDBLCLK
      sEvent = "#WM_NCRBUTTONDBLCLK"
    Case #WM_PAINT
      sEvent = "#WM_PAINT"
    Case #WM_RBUTTONDOWN
      sEvent = "#WM_RBUTTONDOWN"
    Case #WM_RBUTTONUP
      sEvent = "#WM_RBUTTONUP"
    Case #WM_SIZE
      sEvent = "#WM_SIZE"
    Case #WM_SYSKEYDOWN
      sEvent = "#WM_SYSKEYDOWN"
    Case #WM_SYSKEYUP
      sEvent = "#WM_SYSKEYUP"
    Case #WM_SYSTIMER
      sEvent = "WM_SYSTIMER"
    Case #WM_TIMER
      sEvent = "#WM_TIMER"
      
    Case 77   ; $4D
      sEvent = "WM_KEYF1"
      
    Default
      sEvent = "$" + Hex(nEvent) + " (" + Str(nEvent) + ")"
      
  EndSelect
  ProcedureReturn sEvent
EndProcedure

Procedure.s decodeEventType(pGadgetNoOrMinusOne = -999)
  ; If pGadgetNoOrMinusOne not supplied (or = -999) then use gnEventGadgetNo when checking the gadget type.
  ; If pGadgetNoOrMinusOne = -1 then do not check any gadget but just decode gnEventType.
  PROCNAMEC()
  Protected sEventType.s
  Protected nGadgetType
  Protected nGadgetNo
  Protected bDecodeThis
  
  If pGadgetNoOrMinusOne = -1
    bDecodeThis = #True
  Else
    If pGadgetNoOrMinusOne = -999
      nGadgetNo = gnEventGadgetNo
    Else
      nGadgetNo = pGadgetNoOrMinusOne
    EndIf
    If IsGadget(nGadgetNo)
      nGadgetType = GadgetType(nGadgetNo)
      Select nGadgetType
        Case #PB_GadgetType_Canvas, #PB_GadgetType_ComboBox, #PB_GadgetType_Container, #PB_GadgetType_Date, #PB_GadgetType_Editor, #PB_GadgetType_ExplorerList, #PB_GadgetType_ExplorerTree,
             #PB_GadgetType_Image, #PB_GadgetType_ListIcon, #PB_GadgetType_ListView, #PB_GadgetType_OpenGL, #PB_GadgetType_Panel, #PB_GadgetType_ScrollArea, #PB_GadgetType_Spin,
             #PB_GadgetType_String, #PB_GadgetType_Tree, #PB_GadgetType_Web
          ; gadget types that support PB event types
          bDecodeThis = #True
      EndSelect
    EndIf
  EndIf
  
  If bDecodeThis
    Select gnEventType
        ; sorted
      Case #PB_EventType_Change
        sEventType = "#PB_EventType_Change"
        
      Case #PB_EventType_DragStart
        sEventType = "#PB_EventType_DragStart"
        
      Case #PB_EventType_Focus
        sEventType = "#PB_EventType_Focus"
        
      Case #PB_EventType_Input
        sEventType = "#PB_EventType_Input"
        
      Case #PB_EventType_KeyDown
        sEventType = "#PB_EventType_KeyDown"
        
      Case #PB_EventType_KeyUp
        sEventType = "#PB_EventType_KeyUp"
        
      Case #PB_EventType_LeftClick
        sEventType = "#PB_EventType_LeftClick"
        
      Case #PB_EventType_LeftButtonDown
        sEventType = "#PB_EventType_LeftButtonDown"
        
      Case #PB_EventType_LeftButtonUp
        sEventType = "#PB_EventType_LeftButtonUp"
        
      Case #PB_EventType_LeftDoubleClick
        sEventType = "#PB_EventType_LeftDoubleClick"
        
      Case #PB_EventType_LostFocus
        sEventType = "#PB_EventType_LostFocus"
        
      Case #PB_EventType_MiddleButtonDown
        sEventType = "#PB_EventType_MiddleButtonDown"
        
      Case #PB_EventType_MiddleButtonUp
        sEventType = "#PB_EventType_MiddleButtonUp"
        
      Case #PB_EventType_MouseEnter
        sEventType = "#PB_EventType_MouseEnter"
        
      Case #PB_EventType_MouseLeave
        sEventType = "#PB_EventType_MouseLeave"
        
      Case #PB_EventType_MouseMove
        sEventType = "#PB_EventType_MouseMove"
        
      Case #PB_EventType_MouseWheel
        sEventType = "#PB_EventType_MouseWheel"
        
      Case #PB_EventType_Resize
        sEventType = "#PB_EventType_Resize"
        
      Case #PB_EventType_RightButtonDown
        sEventType = "#PB_EventType_RightButtonDown"
        
      Case #PB_EventType_RightButtonUp
        sEventType = "#PB_EventType_RightButtonUp"
        
      Case #PB_EventType_RightClick
        sEventType = "#PB_EventType_RightClick"
        
      Case #PB_EventType_RightDoubleClick
        sEventType = "#PB_EventType_RightDoubleClick"
        
    EndSelect
    
  EndIf
  
  If Len(sEventType) = 0
    Select gnEventType
      Case #WM_KEYDOWN
        sEventType = "#WM_KEYDOWN"
      Case #WM_KEYUP
        sEventType = "#WM_KEYDOWN"
      Case #WM_MOUSEMOVE
        sEventType = "#WM_MOUSEMOVE"
      Case #WM_CUT
        sEventType = "#WM_CUT (" + gnEventType + ", $" + Hex(gnEventType, #PB_Long) + ")"
      ; Case 256
        ; sEventType = "#EN_SETFOCUS"
      Default
        sEventType = Str(gnEventType) + "($" + Hex(gnEventType,#PB_Long) + ")" ; + ", nGadgetType=" + nGadgetType + ", #PB_GadgetType_Canvas=" + #PB_GadgetType_Canvas
    EndSelect
  EndIf
  
  ProcedureReturn sEventType
EndProcedure

Procedure.s decodeWindow(nWindowNo, bOmitHash=#False)
  PROCNAMEC()
  Protected sWindow.s
  
  Select nWindowNo
    Case #WAB
      sWindow = "#WAB"
    Case #WAC
      sWindow = "#WAC"
    Case #WBE
      sWindow = "#WBE"
    Case #WCD
      sWindow = "#WCD"
    Case #WCI
      sWindow = "#WCI"
    Case #WCL
      sWindow = "#WCL"
    Case #WCM
      sWindow = "#WCM"
    Case #WCN
      sWindow = "#WCN"
    Case #WCP
      sWindow = "#WCP"
    Case #WCS
      sWindow = "#WCS"
    Case #WDD
      sWindow = "#WDD"
    Case #WDT
      sWindow = "#WDT"
    Case #WDU
      sWindow = "#WDU"
    Case #WE1
      sWindow = "#WE1"
    Case #WE2
      sWindow = "#WE2"
    Case #WEM
      sWindow = "#WEM"
    Case #WED
      sWindow = "#WED"
    Case #WES
      sWindow = "#WES"
    Case #WEV
      sWindow = "#WEV"
    Case #WEX
      sWindow = "#WEX"
    Case #WFF
      sWindow = "#WFF"
    Case #WFI
      sWindow = "#WFI"
    Case #WFL
      sWindow = "#WFL"
    Case #WFO
      sWindow = "#WFO"
    Case #WFR
      sWindow = "#WFR"
    Case #WFS
      sWindow = "#WFS"
    Case #WIC
      sWindow = "#WIC"
    Case #WID
      sWindow = "#WID"
    Case #WIM
      sWindow = "#WIM"
    Case #WIR
      sWindow = "#WIR"
    Case #WLC
      sWindow = "#WLC"
    Case #WLD
      sWindow = "#WLD"
    Case #WLE
      sWindow = "#WLE"
    Case #WLP
      sWindow = "#WLP"
    Case #WLV
      sWindow = "#WLV"
    Case #WM2
      sWindow = "#WM2"
    Case #WM3
      sWindow = "#WM3"
    Case #WM4
      sWindow = "#WM4"
    Case #WM5
      sWindow = "#WM5"
    Case #WM6
      sWindow = "#WM6"
    Case #WM7
      sWindow = "#WM7"
    Case #WM8
      sWindow = "#WM8"
    Case #WM9
      sWindow = "#WM9"
    Case #WMC
      sWindow = "#WMC"
    Case #WMI
      sWindow = "#WMI"
    Case #WMN
      sWindow = "#WMN"
    Case #WMT
      sWindow = "#WMT"
    Case #WNE
      sWindow = "#WNE"
    Case #WOC
      sWindow = "#WOC"
    Case #WOP
      sWindow = "#WOP"
    Case #WPF
      sWindow = "#WPF"
    Case #WPL
      sWindow = "#WPL"
    Case #WPR
      sWindow = "#WPR"
    Case #WPT
      sWindow = "#WPT"
    Case #WRG
      sWindow = "#WRG"
    Case #WSP
      sWindow = "#WSP"
    Case #WSS
      sWindow = "#WSS"
    Case #WST
      sWindow = "#WST"
    Case  #WTC
      sWindow = "#WTC"
    Case #WTI
      sWindow = "#WTI"
    Case #WTM
      sWindow = "#WTM"
    Case #WTP
      sWindow = "#WTP"
    Case #WUP
      sWindow = "#WUP"
    Case #WV2
      sWindow = "#WV2"
    Case #WV3
      sWindow = "#WV3"
    Case #WV4
      sWindow = "#WV4"
    Case #WV5
      sWindow = "#WV5"
    Case #WV6
      sWindow = "#WV6"
    Case #WV7
      sWindow = "#WV7"
    Case #WV8
      sWindow = "#WV8"
    Case #WV9
      sWindow = "#WV9"
    Case #WVP
      sWindow = "#WVP"
    Case #WYY
      sWindow = "#WYY"
    Case #WZZ
      sWindow = "#WZZ"
    Default
      sWindow = Str(nWindowNo)
  EndSelect
  If bOmitHash
    ProcedureReturn RemoveString(sWindow, "#")
  Else
    ProcedureReturn sWindow
  EndIf
EndProcedure

Procedure.s decodeEditorComponent(nEditorComponent)
  Protected sEditorComponent.s
  
  Select nEditorComponent
    Case #WEP
      sEditorComponent = "#WEP"
    Case #WEC
      sEditorComponent = "#WEC"
    Case #WQA
      sEditorComponent = "#WQA"
    Case #WQE
      sEditorComponent = "#WQE"
    Case #WQF
      sEditorComponent = "#WQF"
    Case #WQG
      sEditorComponent = "#WQG"
    Case #WQI
      sEditorComponent = "#WQI"
    Case #WQJ
      sEditorComponent = "#WQJ"
    Case #WQK
      sEditorComponent = "#WQK"
    Case #WQL
      sEditorComponent = "#WQL"
    Case #WQM
      sEditorComponent = "#WQM"
    Case #WQP
      sEditorComponent = "#WQP"
    Case #WQQ
      sEditorComponent = "#WQQ"
    Case #WQR
      sEditorComponent = "#WQR"
    Case #WQS
      sEditorComponent = "#WQS"
    Case #WQT
      sEditorComponent = "#WQT"
    Case #WQU
      sEditorComponent = "#WQU"
    Default
      sEditorComponent = Str(nEditorComponent)
  EndSelect
  ProcedureReturn sEditorComponent
EndProcedure

Procedure.s decodeMenuItem(nMenuItem)
  Protected sMenuItem.s
  
  Select nMenuItem
    Case #SCS_mnuKeyboardReturn
      sMenuItem = "#SCS_mnuKeyboardReturn"
    Case #SCS_mnuKeyboardEscape
      sMenuItem = "#SCS_mnuKeyboardEscape"
;     Case #SCS_mnuKeyboardCtrlA
;       sMenuItem = "#SCS_mnuKeyboardCtrlA"
;     Case #SCS_mnuKeyboardCtrlC
;       sMenuItem = "#SCS_mnuKeyboardCtrlC"
    Case #WLE_mnuLock
      sMenuItem = "#WLE_mnuLock"
    Case #WLE_mnuCancel
      sMenuItem = "#WLE_mnuCancel"
    Case #WMN_mnuASIOControl
      sMenuItem = "#WMN_mnuASIOControl"
    Case #WMN_mnuCloseAndReOpenDMXDevs
      sMenuItem = "#WMN_mnuCloseAndReOpenDMXDevs"
    Case #WMN_mnuCueControl
      sMenuItem = "#WMN_mnuCueControl"
    Case #WMN_mnuCurrInfo
      sMenuItem = "#WMN_mnuCurrInfo"
    Case #WMN_mnuDevMap
      sMenuItem = "#WMN_mnuDevMap"
    Case #WMN_mnuDMXMastFaderReset
      sMenuItem = "#WMN_mnuDMXMastFaderReset"
    Case #WMN_mnuDMXMastFaderSave
      sMenuItem = "#WMN_mnuDMXMastFaderSave"
    Case #WMN_mnuEditor
      sMenuItem = "#WMN_mnuEditor"
    Case #WMN_mnuFadeAll
      sMenuItem = "#WMN_mnuFadeAll"
    Case #WMN_mnuFavFiles
      sMenuItem = "#WMN_mnuFavFiles"
    Case #WMN_mnuFile
      sMenuItem = "#WMN_mnuFile"
    Case #WMN_mnuFileExit
      sMenuItem = "#WMN_mnuFileExit"
    Case #WMN_mnuFileLoad
      sMenuItem = "#WMN_mnuFileLoad"
    Case #WMN_mnuFileTemplates
      sMenuItem = "#WMN_mnuFileTemplates"
    Case #WMN_mnuFilePrint
      sMenuItem = "#WMN_mnuFilePrint"
    Case #WMN_mnuGo
      sMenuItem = "#WMN_mnuGo"
    Case #WMN_mnuHelp
      sMenuItem = "#WMN_mnuHelp"
    Case #WMN_mnuHelpAbout
      sMenuItem = "#WMN_mnuHelpAbout"
    Case #WMN_mnuHelpCheckForUpdate
      sMenuItem = "#WMN_mnuHelpCheckForUpdate"
    Case #WMN_mnuHelpClearDTMAInds
      sMenuItem = "#WMN_mnuHelpClearDTMAInds"
    Case #WMN_mnuHelpContents
      sMenuItem = "#WMN_mnuHelpContents"
    Case #WMN_mnuHelpForums
      sMenuItem = "#WMN_mnuHelpForums"
    Case #WMN_mnuHelpRegistration
      sMenuItem = "#WMN_mnuHelpRegistration"
    Case #WMN_mnuTracing
      sMenuItem = "#WMN_mnuTracing"
    Case #WMN_mnuMastFaderReset
      sMenuItem = "#WMN_mnuMastFaderReset"
    Case #WMN_mnuMastFaderSave
      sMenuItem = "#WMN_mnuMastFaderSave"
    Case #WMN_mnuMtrsDMXDisplay
      sMenuItem = "#WMN_mnuMtrsDMXDisplay"
    Case #WMN_mnuMtrsPeakAuto
      sMenuItem = "#WMN_mnuMtrsPeakAuto"
    Case #WMN_mnuMtrsPeakHdg
      sMenuItem = "#WMN_mnuMtrsPeakHdg"
    Case #WMN_mnuMtrsPeakHold
      sMenuItem = "#WMN_mnuMtrsPeakHold"
    Case #WMN_mnuMtrsPeakOff
      sMenuItem = "#WMN_mnuMtrsPeakOff"
    Case #WMN_mnuMtrsPeakReset
      sMenuItem = "#WMN_mnuMtrsPeakReset"
    Case #WMN_mnuMtrsVUHdg
      sMenuItem = "#WMN_mnuMtrsVUHdg"
    Case #WMN_mnuMtrsVULevels
      sMenuItem = "#WMN_mnuMtrsVULevels"
    Case #WMN_mnuMtrsVUNone
      sMenuItem = "#WMN_mnuMtrsVUNone"
    Case #WMN_mnuNavBack
      sMenuItem = "#WMN_mnuNavBack"
    Case #WMN_mnuNavEnd
      sMenuItem = "#WMN_mnuNavEnd"
    Case #WMN_mnuNavFind
      sMenuItem = "#WMN_mnuNavFind"
    Case #WMN_mnuNavigate
      sMenuItem = "#WMN_mnuNavigate"
    Case #WMN_mnuNavNext
      sMenuItem = "#WMN_mnuNavNext"
    Case #WMN_mnuNavToCueMarker
      sMenuItem = "#WMN_mnuNavToCueMarker"
    Case #WMN_mnuNavTop
      sMenuItem = "#WMN_mnuNavTop"
    Case #WMN_mnuOpen
      sMenuItem = "#WMN_mnuOpen"
    Case #WMN_mnuOpenFile
      sMenuItem = "#WMN_mnuOpenFile"
    Case #WMN_mnuOptions
      sMenuItem = "#WMN_mnuOptions"
    Case #WMN_mnuPauseAll
      sMenuItem = "#WMN_mnuPauseAll"
    Case #WMN_mnuRecentFile_0
      sMenuItem = "#WMN_mnuRecentFile_0"
    Case #WMN_mnuRecentFile_1
      sMenuItem = "#WMN_mnuRecentFile_1"
    Case #WMN_mnuRecentFile_2
      sMenuItem = "#WMN_mnuRecentFile_2"
    Case #WMN_mnuRecentFile_3
      sMenuItem = "#WMN_mnuRecentFile_3"
    Case #WMN_mnuRecentFile_4
      sMenuItem = "#WMN_mnuRecentFile_4"
    Case #WMN_mnuRecentFile_5
      sMenuItem = "#WMN_mnuRecentFile_5"
    Case #WMN_mnuRecentFile_6
      sMenuItem = "#WMN_mnuRecentFile_6"
    Case #WMN_mnuRecentFile_7
      sMenuItem = "#WMN_mnuRecentFile_7"
    Case #WMN_mnuRecentFile_8
      sMenuItem = "#WMN_mnuRecentFile_8"
    Case #WMN_mnuRecentFile_9
      sMenuItem = "#WMN_mnuRecentFile_9"
    Case #WMN_mnuResetStepHKs
      sMenuItem = "#WMN_mnuResetStepHKs"
    Case #WMN_mnuSave
      sMenuItem = "#WMN_mnuSave"
    Case #WMN_mnuSaveAs
      sMenuItem = "#WMN_mnuSaveAs"
    Case #WMN_mnuSaveFile
      sMenuItem = "#WMN_mnuSaveFile"
    Case #WMN_mnuSaveReason
      sMenuItem = "#WMN_mnuSaveReason"
    Case #WMN_mnuSaveSettings
      sMenuItem = "#WMN_mnuSaveSettings"
    Case #WMN_mnuSaveSettingsAllCues
      sMenuItem = "#WMN_mnuSaveSettingsAllCues"
    Case #WMN_mnuSaveSettingsCue_00
      sMenuItem = "#WMN_mnuSaveSettingsCue_00"
    Case #WMN_mnuSaveSettingsCue_01
      sMenuItem = "#WMN_mnuSaveSettingsCue_01"
    Case #WMN_mnuSaveSettingsCue_02
      sMenuItem = "#WMN_mnuSaveSettingsCue_02"
    Case #WMN_mnuSaveSettingsCue_03
      sMenuItem = "#WMN_mnuSaveSettingsCue_03"
    Case #WMN_mnuSaveSettingsCue_04
      sMenuItem = "#WMN_mnuSaveSettingsCue_04"
    Case #WMN_mnuSaveSettingsCue_05
      sMenuItem = "#WMN_mnuSaveSettingsCue_05"
    Case #WMN_mnuSaveSettingsCue_06
      sMenuItem = "#WMN_mnuSaveSettingsCue_06"
    Case #WMN_mnuSaveSettingsCue_07
      sMenuItem = "#WMN_mnuSaveSettingsCue_07"
    Case #WMN_mnuSaveSettingsCue_08
      sMenuItem = "#WMN_mnuSaveSettingsCue_08"
    Case #WMN_mnuSaveSettingsCue_09
      sMenuItem = "#WMN_mnuSaveSettingsCue_09"
    Case #WMN_mnuSaveSettingsCue_10
      sMenuItem = "#WMN_mnuSaveSettingsCue_10"
    Case #WMN_mnuSaveSettingsCue_11
      sMenuItem = "#WMN_mnuSaveSettingsCue_11"
    Case #WMN_mnuSaveSettingsCue_12
      sMenuItem = "#WMN_mnuSaveSettingsCue_12"
    Case #WMN_mnuSaveSettingsCue_13
      sMenuItem = "#WMN_mnuSaveSettingsCue_13"
    Case #WMN_mnuSaveSettingsCue_14
      sMenuItem = "#WMN_mnuSaveSettingsCue_14"
    Case #WMN_mnuSaveSettingsCue_15
      sMenuItem = "#WMN_mnuSaveSettingsCue_15"
    Case #WMN_mnuSaveSettingsCue_16
      sMenuItem = "#WMN_mnuSaveSettingsCue_16"
    Case #WMN_mnuSaveSettingsCue_17
      sMenuItem = "#WMN_mnuSaveSettingsCue_17"
    Case #WMN_mnuSaveSettingsCue_18
      sMenuItem = "#WMN_mnuSaveSettingsCue_18"
    Case #WMN_mnuSaveSettingsCue_19
      sMenuItem = "#WMN_mnuSaveSettingsCue_19"
    Case #WMN_mnuStandbyGo
      sMenuItem = "#WMN_mnuStandbyGo"
    Case #WMN_mnuStopAll
      sMenuItem = "#WMN_mnuStopAll"
    Case #WMN_mnuTimeProfile
      sMenuItem = "#WMN_mnuTimeProfile"
    Case #WMN_mnuView
      sMenuItem = "#WMN_mnuView"
    Case #WMN_mnuVST
      sMenuItem = "#WMN_mnuVST"
    Case #WMN_mnuVUMedium
      sMenuItem = "#WMN_mnuVUMedium"
    Case #WMN_mnuVUNarrow
      sMenuItem = "#WMN_mnuVUNarrow"
    Case #WMN_mnuVUWide
      sMenuItem = "#WMN_mnuVUWide"
    Case #WMN_mnuWindowMenu
      sMenuItem = "#WMN_mnuWindowMenu"
    Case #WMN_mnuViewClock
      sMenuItem = "#WMN_mnuViewClock"
    Case #WMN_mnuViewCountdown
      sMenuItem = "#WMN_mnuViewCountdown"
    Case #WMN_mnuViewClearCountdownClock
      sMenuItem = "#WMN_mnuViewClearCountdownClock"
    Case #WMN_mnuViewOperModeDesign
      sMenuItem = "#WMN_mnuViewOperModeDesign"
    Case #WMN_mnuViewOperModePerformance
      sMenuItem = "#WMN_mnuViewOperModePerformance"
    Case #WMN_mnuViewOperModeRehearsal
      sMenuItem = "#WMN_mnuViewOperModeRehearsal"
    Case #WED_mnuAddQA
      sMenuItem = "#WED_mnuAddQA"
    Case #WED_mnuAddQE
      sMenuItem = "#WED_mnuAddQE"
    Case #WED_mnuAddQF
      sMenuItem = "#WED_mnuAddQF"
    Case #WED_mnuAddQG
      sMenuItem = "#WED_mnuAddQG"
    Case #WED_mnuAddQI
      sMenuItem = "#WED_mnuAddQI"
    Case #WED_mnuAddQJ
      sMenuItem = "#WED_mnuAddQJ"
    Case #WED_mnuAddQK
      sMenuItem = "#WED_mnuAddQK"
    Case #WED_mnuAddQL
      sMenuItem = "#WED_mnuAddQL"
    Case #WED_mnuAddQM
      sMenuItem = "#WED_mnuAddQM"
    Case #WED_mnuAddQN
      sMenuItem = "#WED_mnuAddQN"
    Case #WED_mnuAddQP
      sMenuItem = "#WED_mnuAddQP"
    Case #WED_mnuAddQQ
      sMenuItem = "#WED_mnuAddQQ"
    Case #WED_mnuAddQR
      sMenuItem = "#WED_mnuAddQR"
    Case #WED_mnuAddQS
      sMenuItem = "#WED_mnuAddQS"
    Case #WED_mnuAddQT
      sMenuItem = "#WED_mnuAddQT"
    Case #WED_mnuAddQU
      sMenuItem = "#WED_mnuAddQU"
    Case #WED_mnuAddSA
      sMenuItem = "#WED_mnuAddSA"
    Case #WED_mnuAddSE
      sMenuItem = "#WED_mnuAddSE"
    Case #WED_mnuAddSF
      sMenuItem = "#WED_mnuAddSF"
    Case #WED_mnuAddSG
      sMenuItem = "#WED_mnuAddSG"
    Case #WED_mnuAddSI
      sMenuItem = "#WED_mnuAddSI"
    Case #WED_mnuAddSJ
      sMenuItem = "#WED_mnuAddSJ"
    Case #WED_mnuAddSK
      sMenuItem = "#WED_mnuAddSK"
    Case #WED_mnuAddSL
      sMenuItem = "#WED_mnuAddSL"
    Case #WED_mnuAddSM
      sMenuItem = "#WED_mnuAddSM"
    Case #WED_mnuAddSP
      sMenuItem = "#WED_mnuAddSP"
    Case #WED_mnuAddSQ
      sMenuItem = "#WED_mnuAddSQ"
    Case #WED_mnuAddSR
      sMenuItem = "#WED_mnuAddSR"
    Case #WED_mnuAddSS
      sMenuItem = "#WED_mnuAddSS"
    Case #WED_mnuAddST
      sMenuItem = "#WED_mnuAddST"
    Case #WED_mnuAddSU
      sMenuItem = "#WED_mnuAddSU"
    Case #WED_mnuBulkEditCues
      sMenuItem = "#WED_mnuBulkEditCues"
    Case #WED_mnuCollect
      sMenuItem = "#WED_mnuCollect"
    Case #WED_mnuCopy
      sMenuItem = "#WED_mnuCopy"
    Case #WED_mnuCopyProps
      sMenuItem = "#WED_mnuCopyProps"
    Case #WED_mnuCueListPopupMenu
      sMenuItem = "#WED_mnuCueListPopupMenu"
    Case #WED_mnuCuesMenu
      sMenuItem = "#WED_mnuCuesMenu"
    Case #WED_mnuCut
      sMenuItem = "#WED_mnuCut"
    Case #WED_mnuDelete
      sMenuItem = "#WED_mnuDelete"
    Case #WED_mnuExportCues
      sMenuItem = "#WED_mnuExportCues"
    Case #WED_mnuFavFiles
      sMenuItem = "#WED_mnuFavFiles"
    Case #WED_mnuFile
      sMenuItem = "#WED_mnuFile"
    Case #WED_mnuHelp
      sMenuItem = "#WED_mnuHelp"
    Case #WED_mnuHelpContents
      sMenuItem = "#WED_mnuHelpContents"
    Case #WED_mnuHelpEditor
      sMenuItem = "#WED_mnuHelpEditor"
    Case #WED_mnuImportCSV
      sMenuItem = "#WED_mnuImportCSV"
    Case #WED_mnuImportCues
      sMenuItem = "#WED_mnuImportCues"
    Case #WED_mnuImportDevs
      sMenuItem = "#WED_mnuImportDevs"
    Case #WED_mnuMultiCueCopyEtc
      sMenuItem = "#WED_mnuMultiCueCopyEtc"
    Case #WED_mnuNew
      sMenuItem = "#WED_mnuNew"
    Case #WED_mnuOpen
      sMenuItem = "#WED_mnuOpen"
    Case #WED_mnuOpenFile
      sMenuItem = "#WED_mnuOpenFile"
    Case #WED_mnuOptions
      sMenuItem = "#WED_mnuOptions"
    Case #WED_mnuOtherActions
      sMenuItem = "#WED_mnuOtherActions"
    Case #WED_mnuPaste
      sMenuItem = "#WED_mnuPaste"
    Case #WED_mnuPlaylist
      sMenuItem = "#WED_mnuPlaylist"
    Case #WED_mnuPLRemove
      sMenuItem = "#WED_mnuPLRemove"
    Case #WED_mnuPLRename
      sMenuItem = "#WED_mnuPLRename"
    Case #WED_mnuPrint
      sMenuItem = "#WED_mnuPrint"
    Case #WED_mnuProdMenu
      sMenuItem = "#WED_mnuProdMenu"
    Case #WED_mnuProdFolder
      sMenuItem = "#WED_mnuProdFolder"
    Case #WED_mnuProdImportExport
      sMenuItem = "#WED_mnuProdImportExport"
    Case #WED_mnuProdProperties
      sMenuItem = "#WED_mnuProdProperties"
    Case #WED_mnuRecentFile_0
      sMenuItem = "#WED_mnuRecentFile_0"
    Case #WED_mnuRecentFile_1
      sMenuItem = "#WED_mnuRecentFile_1"
    Case #WED_mnuRecentFile_2
      sMenuItem = "#WED_mnuRecentFile_2"
    Case #WED_mnuRecentFile_3
      sMenuItem = "#WED_mnuRecentFile_3"
    Case #WED_mnuRecentFile_4
      sMenuItem = "#WED_mnuRecentFile_4"
    Case #WED_mnuRecentFile_5
      sMenuItem = "#WED_mnuRecentFile_5"
    Case #WED_mnuRecentFile_6
      sMenuItem = "#WED_mnuRecentFile_6"
    Case #WED_mnuRecentFile_7
      sMenuItem = "#WED_mnuRecentFile_7"
    Case #WED_mnuRecentFile_8
      sMenuItem = "#WED_mnuRecentFile_8"
    Case #WED_mnuRecentFile_9
      sMenuItem = "#WED_mnuRecentFile_9"
    Case #WED_mnuRenumberCues
      sMenuItem = "#WED_mnuRenumberCues"
    Case #WED_mnuSaveAs
      sMenuItem = "#WED_mnuSaveAs"
    Case #WED_mnuSubsMenu
      sMenuItem = "#WED_mnuSubsMenu"
    Case #WED_mnuTapDelay
      sMenuItem = "#WED_mnuTapDelay"
    Case #WED_mnuUndoRedoMenu
      sMenuItem = "#WED_mnuUndoRedoMenu"
    Case #WED_mnuUndoRedoInfo
      sMenuItem = "#WED_mnuUndoRedoInfo"
    Case #WED_mnuFavStart
      sMenuItem = "#WED_mnuFavStart"
    Case #WED_mnuFavAddQA
      sMenuItem = "#WED_mnuFavAddQA"
    Case #WED_mnuFavAddQE
      sMenuItem = "#WED_mnuFavAddQE"
    Case #WED_mnuFavAddQF
      sMenuItem = "#WED_mnuFavAddQF"
    Case #WED_mnuFavAddQG
      sMenuItem = "#WED_mnuFavAddQG"
    Case #WED_mnuFavAddQI
      sMenuItem = "#WED_mnuFavAddQI"
    Case #WED_mnuFavAddQK
      sMenuItem = "#WED_mnuFavAddQK"
    Case #WED_mnuFavAddQL
      sMenuItem = "#WED_mnuFavAddQL"
    Case #WED_mnuFavAddQM
      sMenuItem = "#WED_mnuFavAddQM"
    Case #WED_mnuFavAddQN
      sMenuItem = "#WED_mnuFavAddQN"
    Case #WED_mnuFavAddQP
      sMenuItem = "#WED_mnuFavAddQP"
    Case #WED_mnuFavAddQQ
      sMenuItem = "#WED_mnuFavAddQQ"
    Case #WED_mnuFavAddQR
      sMenuItem = "#WED_mnuFavAddQR"
    Case #WED_mnuFavAddQS
      sMenuItem = "#WED_mnuFavAddQS"
    Case #WED_mnuFavAddQT
      sMenuItem = "#WED_mnuFavAddQT"
    Case #WED_mnuFavAddQU
      sMenuItem = "#WED_mnuFavAddQU"
    Case #WED_mnuFavAddSA
      sMenuItem = "#WED_mnuFavAddSA"
    Case #WED_mnuFavAddSE
      sMenuItem = "#WED_mnuFavAddSE"
    Case #WED_mnuFavAddSF
      sMenuItem = "#WED_mnuFavAddSF"
    Case #WED_mnuFavAddSG
      sMenuItem = "#WED_mnuFavAddSG"
    Case #WED_mnuFavAddSI
      sMenuItem = "#WED_mnuFavAddSI"
    Case #WED_mnuFavAddSK
      sMenuItem = "#WED_mnuFavAddSK"
    Case #WED_mnuFavAddSL
      sMenuItem = "#WED_mnuFavAddSL"
    Case #WED_mnuFavAddSM
      sMenuItem = "#WED_mnuFavAddSM"
    Case #WED_mnuFavAddSP
      sMenuItem = "#WED_mnuFavAddSP"
    Case #WED_mnuFavAddSQ
      sMenuItem = "#WED_mnuFavAddSQ"
    Case #WED_mnuFavAddSR
      sMenuItem = "#WED_mnuFavAddSR"
    Case #WED_mnuFavAddSS
      sMenuItem = "#WED_mnuFavAddSS"
    Case #WED_mnuFavAddST
      sMenuItem = "#WED_mnuFavAddST"
    Case #WED_mnuFavAddSU
      sMenuItem = "#WED_mnuFavAddSU"
    Case #WED_mnuFavEnd
      sMenuItem = "#WED_mnuFavEnd"
    Case #WED_mnuFavsInfo
      sMenuItem = "#WED_mnuFavsInfo"
    Case #WED_mnuFavsMenu
      sMenuItem = "#WED_mnuFavsMenu"
      
    Case #WPR_mnuColAC
      sMenuItem = "#WPR_mnuColAC"
    Case #WPR_mnuColCS
      sMenuItem = "#WPR_mnuColCS"
    Case #WPR_mnuColCT
      sMenuItem = "#WPR_mnuColCT"
    Case #WPR_mnuColCU
      sMenuItem = "#WPR_mnuColCU"
    Case #WPR_mnuColDE
      sMenuItem = "#WPR_mnuColDE"
    Case #WPR_mnuColDefaults
      sMenuItem = "#WPR_mnuColDefaults"
    Case #WPR_mnuColDU
      sMenuItem = "#WPR_mnuColDU"
    Case #WPR_mnuColFN
      sMenuItem = "#WPR_mnuColFN"
    Case #WPR_mnuColFT
      sMenuItem = "#WPR_mnuColFT"
    Case #WPR_mnuColLV
      sMenuItem = "#WPR_mnuColLV"
    Case #WPR_mnuColMC
      sMenuItem = "#WPR_mnuColMC"
    Case #WPR_mnuColPG
      sMenuItem = "#WPR_mnuColPG"
    Case #WPR_mnuColRevert
      sMenuItem = "#WPR_mnuColRevert"
    Case #WPR_mnuColSD
      sMenuItem = "#WPR_mnuColSD"
    Case #WPR_mnuColWR
      sMenuItem = "#WPR_mnuColWR"
    Case #WPR_mnuFileClose
      sMenuItem = "#WPR_mnuFileClose"
    Case #WPR_mnuFilePrint
      sMenuItem = "#WPR_mnuFilePrint"
    Case #WPR_mnuWindowMenu
      sMenuItem = "#WPR_mnuWindowMenu"
      
    Case #WQA_mnuFlipH
      sMenuItem = "#WQA_mnuFlipH"
    Case #WQA_mnuFlipV
      sMenuItem = "#WQA_mnuFlipV"
    Case #WQA_mnuOther
      sMenuItem = "#WQA_mnuOther"
    Case #WQA_mnuOtherCopy
      sMenuItem = "#WQA_mnuOtherCopy"
    Case #WQA_mnuOtherDefault
      sMenuItem = "#WQA_mnuOtherDefault"
    Case #WQA_mnuOtherPaste
      sMenuItem = "#WQA_mnuOtherPaste"
    Case #WQA_mnuRotate
      sMenuItem = "#WQA_mnuRotate"
    Case #WQA_mnuRotate180
      sMenuItem = "#WQA_mnuRotate180"
    Case #WQA_mnuRotateL90
      sMenuItem = "#WQA_mnuRotateL90"
    Case #WQA_mnuRotateR90
      sMenuItem = "#WQA_mnuRotateR90"
    Case #WQA_mnuRotateReset
      sMenuItem = "#WQA_mnuRotateReset"
    Case #WQA_mnu_GraphContextMenu
      sMenuItem = "#WQA_mnu_GraphContextMenu"
    Case #WQA_mnu_EditCueMarker
      sMenuItem = "#WQA_mnu_EditCueMarker"
    Case #WQA_mnu_RemoveCueMarker
      sMenuItem = "#WQA_mnu_RemoveCueMarker"
    Case #WQA_mnu_SetCueMarkerPos  
      sMenuItem = "#WQA_mnu_SetCueMarkerPos"
    Case #WQA_mnu_ViewOnCues
      sMenuItem = "#WQA_mnu_ViewOnCues"
    Case #WQA_mnu_ViewCueMarkersUsage
      sMenuItem = "#WQA_mnu_ViewCueMarkersUsage"
    Case #WQA_mnu_AddQuickCueMarkers
      sMenuItem = "#WQA_mnu_AddQuickCueMarkers"
    Case #WQA_mnu_RemoveAllUnusedCueMarkersFromThisFile
      sMenuItem = "#WQA_mnu_RemoveAllUnusedCueMarkersFromThisFile"
    Case #WQA_mnu_RemoveAllUnusedCueMarkers
      sMenuItem = "#WQA_mnu_RemoveAllUnusedCueMarkers"
      
    Case #WQF_mnu_GraphContextMenu
      sMenuItem = "#WQF_mnu_GraphContextMenu"
    Case #WQF_mnu_AddFadeInLvlPt
      sMenuItem = "#WQF_mnu_AddFadeInLvlPt"
    Case #WQF_mnu_AddFadeOutLvlPt
      sMenuItem = "#WQF_mnu_AddFadeOutLvlPt"
    Case #WQF_mnu_AddStdLvlPt
      sMenuItem = "#WQF_mnu_AddStdLvlPt"
    Case #WQF_mnu_ChangeFreqTempoPitch
      sMenuItem = "#WQF_mnu_ChangeFreqTempoPitch"
    Case #WQF_mnu_ClearAll
      sMenuItem = "#WQF_mnu_ClearAll"
    Case #WQF_mnu_EndTrim30
      sMenuItem = "#WQF_mnu_EndTrim30"
    Case #WQF_mnu_EndTrim45
      sMenuItem = "#WQF_mnu_EndTrim45"
    Case #WQF_mnu_EndTrim60 ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQF_mnu_EndTrim60"
    Case #WQF_mnu_EndTrim75 ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQF_mnu_EndTrim75"
    Case #WQF_mnu_EndTrimSilence
      sMenuItem = "#WQF_mnu_EndTrimSilence"
    Case #WQF_mnu_RemoveLvlPt
      sMenuItem = "#WQF_mnu_RemoveLvlPt"
    Case #WQF_mnu_ResetAll
      sMenuItem = "#WQF_mnu_ResetAll"
    Case #WQF_mnu_SameLvlAsPrev
      sMenuItem = "#WQF_mnu_SameLvlAsPrev"
    Case #WQF_mnu_SameLvlAsNext
      sMenuItem = "#WQF_mnu_SameLvlAsNext"
    Case #WQF_mnu_SamePanAsPrev
      sMenuItem = "#WQF_mnu_SamePanAsPrev"
    Case #WQF_mnu_SamePanAsNext
      sMenuItem = "#WQF_mnu_SamePanAsNext"
    Case #WQF_mnu_SameAsPrev
      sMenuItem = "#WQF_mnu_SameAsPrev"
    Case #WQF_mnu_SameAsNext
      sMenuItem = "#WQF_mnu_SameAsNext"
    Case #WQF_mnu_ShowLvlCurvesSel
      sMenuItem = "#WQF_mnu_ShowLvlCurvesSel"
    Case #WQF_mnu_ShowPanCurvesSel
      sMenuItem = "#WQF_mnu_ShowPanCurvesSel"
    Case #WQF_mnu_ShowLvlCurvesOther
      sMenuItem = "#WQF_mnu_ShowLvlCurvesOther"
    Case #WQF_mnu_ShowPanCurvesOther
      sMenuItem = "#WQF_mnu_ShowPanCurvesOther"
    Case #WQF_mnu_SetPos
      sMenuItem = "#WQF_mnu_SetPos"
    Case #WQF_mnu_SetStartAt
      sMenuItem = "#WQF_mnu_SetStartAt"
    Case #WQF_mnu_SetEndAt
      sMenuItem = "#WQF_mnu_SetEndAt"
    Case #WQF_mnu_SetLoopStart
      sMenuItem = "#WQF_mnu_SetLoopStart"
    Case #WQF_mnu_SetLoopEnd
      sMenuItem = "#WQF_mnu_SetLoopEnd"
    Case #WQF_mnu_StartTrim30
      sMenuItem = "#WQF_mnu_StartTrim30"
    Case #WQF_mnu_StartTrim45
      sMenuItem = "#WQF_mnu_StartTrim45"
    Case #WQF_mnu_StartTrim60 ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQF_mnu_StartTrim60"
    Case #WQF_mnu_StartTrim75 ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQF_mnu_StartTrim75"
    Case #WQF_mnu_StartTrimSilence
      sMenuItem = "#WQF_mnu_StartTrimSilence"
    Case #WQF_mnu_EditCueMarker
      sMenuItem = "#WQF_mnu_EditCueMarker"
    Case #WQF_mnu_RemoveCueMarker
      sMenuItem = "#WQF_mnu_RemoveCueMarker"
    Case #WQF_mnu_SetCueMarkerPos  
      sMenuItem = "#WQF_mnu_SetCueMarkerPos"
    Case #WQF_mnu_ViewOnCues
      sMenuItem = "#WQF_mnu_ViewOnCues"
    Case #WQF_mnu_ViewCueMarkersUsage
      sMenuItem = "#WQF_mnu_ViewCueMarkersUsage"
    Case #WQF_mnu_AddQuickCueMarkers
      sMenuItem = "#WQF_mnu_AddQuickCueMarkers"
    Case #WQF_mnu_RemoveAllUnusedCueMarkersFromThisFile
      sMenuItem = "#WQF_mnu_RemoveAllUnusedCueMarkersFromThisFile"
    Case #WQF_mnu_RemoveAllUnusedCueMarkers
      sMenuItem = "#WQF_mnu_RemoveAllUnusedCueMarkers"
      
    Case #WQP_mnu_ClearAll
      sMenuItem = "#WQP_mnu_ClearAll"
    Case #WQP_mnu_ClearSel
      sMenuItem = "#WQP_mnu_ClearSel"
    Case #WQP_mnu_LUFSNorm100All
      sMenuItem = "#WQP_mnu_LUFSNorm100All"
    Case #WQP_mnu_LUFSNorm90All
      sMenuItem = "#WQP_mnu_LUFSNorm90All"
    Case #WQP_mnu_LUFSNorm80All
      sMenuItem = "#WQP_mnu_LUFSNorm80All"
    CompilerIf #c_include_peak
    Case #WQP_mnu_PeakNormAll
      sMenuItem = "#WQP_mnu_PeakNormAll"
    CompilerEndIf
    Case #WQP_mnu_TruePeakNorm100All
      sMenuItem = "#WQP_mnu_TruePeakNorm100All"
    Case #WQP_mnu_TruePeakNorm90All
      sMenuItem = "#WQP_mnu_TruePeakNorm90All"
    Case #WQP_mnu_TruePeakNorm80All
      sMenuItem = "#WQP_mnu_TruePeakNorm80All"
    Case #WQP_mnu_PeakNorm100All
      sMenuItem = "#WQP_mnu_PeakNorm100All"
    Case #WQP_mnu_PeakNorm90All
      sMenuItem = "#WQP_mnu_PeakNorm90All"
    Case #WQP_mnu_PeakNorm80All
      sMenuItem = "#WQP_mnu_PeakNorm80All"
    Case #WQP_mnu_ResetAll
      sMenuItem = "#WQP_mnu_ResetAll"
    Case #WQP_mnu_ResetSel
      sMenuItem = "#WQP_mnu_ResetSel"
    Case #WQP_mnu_Trim30All
      sMenuItem = "#WQP_mnu_Trim30All"
    Case #WQP_mnu_Trim45All
      sMenuItem = "#WQP_mnu_Trim45All"
    Case #WQP_mnu_Trim60All ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQP_mnu_Trim60All"
    Case #WQP_mnu_Trim75All ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQP_mnu_Trim75All"
    Case #WQP_mnu_TrimSilenceAll
      sMenuItem = "#WQP_mnu_TrimSilenceAll"
    Case #WQP_mnu_Trim30Sel
      sMenuItem = "#WQP_mnu_Trim30Sel"
    Case #WQP_mnu_Trim45Sel
      sMenuItem = "#WQP_mnu_Trim45Sel"
    Case #WQP_mnu_Trim60Sel ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQP_mnu_Trim60Sel"
    Case #WQP_mnu_Trim75Sel ; Added 3Oct2022 11.9.6
      sMenuItem = "#WQP_mnu_Trim75Sel"
    Case #WQP_mnu_TrimSilenceSel
      sMenuItem = "#WQP_mnu_TrimSilenceSel"
    Case #WQP_mnu_RemoveAllFiles
      sMenuItem = "#WQP_mnu_RemoveAllFiles"
      
    Case #SCS_WMNF_ExclCueOverride
      sMenuItem = "#SCS_WMNF_ExclCueOverride"
    Case #SCS_WMNF_Go
      sMenuItem = "#SCS_WMNF_Go"
    Case #SCS_WMNF_GoConfirm
      sMenuItem = "#SCS_WMNF_GoConfirm"
    Case #SCS_WMNF_PauseResumeAll
      sMenuItem = "#SCS_WMNF_PauseResumeAll"
    Case #SCS_WMNF_StopAll
      sMenuItem = "#SCS_WMNF_StopAll"
    Case #SCS_WMNF_FadeAll
      sMenuItem = "#SCS_WMNF_FadeAll"
    Case #SCS_WMNF_MastFdrUp
      sMenuItem = "#SCS_WMNF_MastFdrUp"
    Case #SCS_WMNF_MastFdrDown
      sMenuItem = "#SCS_WMNF_MastFdrDown"
    Case #SCS_WMNF_MastFdrReset
      sMenuItem = "#SCS_WMNF_MastFdrReset"
    Case #SCS_WMNF_MastFdrMute
      sMenuItem = "#SCS_WMNF_MastFdrMute"
    Case #SCS_WMNF_DecPlayingCues
      sMenuItem = "#SCS_WMNF_DecPlayingCues"
    Case #SCS_WMNF_IncPlayingCues
      sMenuItem = "#SCS_WMNF_IncPlayingCues"
    Case #SCS_WMNF_DecLastPlayingCue
      sMenuItem = "#SCS_WMNF_DecLastPlayingCue"
    Case #SCS_WMNF_IncLastPlayingCue
      sMenuItem = "#SCS_WMNF_IncLastPlayingCue"
    Case #SCS_WMNF_SaveCueSettings
      sMenuItem = "#SCS_WMNF_SaveCueSettings"
    Case #SCS_WMNF_CueListUpOneRow
      sMenuItem = "#SCS_WMNF_CueListUpOneRow"
    Case #SCS_WMNF_CueListDownOneRow
      sMenuItem = "#SCS_WMNF_CueListDownOneRow"
    Case #SCS_WMNF_CueListUpOnePage
      sMenuItem = "#SCS_WMNF_CueListUpOnePage"
    Case #SCS_WMNF_CueListDownOnePage
      sMenuItem = "#SCS_WMNF_CueListDownOnePage"
    Case #SCS_WMNF_CueListTop
      sMenuItem = "#SCS_WMNF_CueListTop"
    Case #SCS_WMNF_CueListEnd
      sMenuItem = "#SCS_WMNF_CueListEnd"
    Case #SCS_WMNF_CueMarkerNext
      sMenuItem = "#SCS_WMNF_CueMarkerNext"
    Case #SCS_WMNF_CueMarkerPrev
      sMenuItem = "#SCS_WMNF_CueMarkerPrev"
    Case #SCS_WMNF_FindCue
      sMenuItem = "#SCS_WMNF_FindCue"
    Case #SCS_WMNF_ExclCueOverride
      sMenuItem = "#SCS_WMNF_ExclCueOverride"
    Case #SCS_WMNF_TapDelay
      sMenuItem = "#SCS_WMNF_TapDelay"
    Case #SCS_WMNF_DMXMastFdrUp
      sMenuItem = "#SCS_WMNF_DMXMastFdrUp"
    Case #SCS_WMNF_DMXMastFdrDown
      sMenuItem = "#SCS_WMNF_DMXMastFdrDown"
    Case #SCS_WMNF_DMXMastFdrReset
      sMenuItem = "#SCS_WMNF_DMXMastFdrReset"
    Case #SCS_WMNF_MoveToTime
      sMenuItem = "#SCS_WMNF_MoveToTime"
    Case #SCS_WMNF_CallLinkDevs
      sMenuItem = "#SCS_WMNF_CallLinkDevs"
    Case #SCS_WMNF_FavFile1
      sMenuItem = "#SCS_WMNF_FavFile1"
    Case #SCS_WMNF_FavFile2
      sMenuItem = "#SCS_WMNF_FavFile2"
    Case #SCS_WMNF_FavFile3
      sMenuItem = "#SCS_WMNF_FavFile3"
    Case #SCS_WMNF_FavFile4
      sMenuItem = "#SCS_WMNF_FavFile4"
    Case #SCS_WMNF_FavFile5
      sMenuItem = "#SCS_WMNF_FavFile5"
    Case #SCS_WMNF_FavFile6
      sMenuItem = "#SCS_WMNF_FavFile6"
    Case #SCS_WMNF_FavFile7
      sMenuItem = "#SCS_WMNF_FavFile7"
    Case #SCS_WMNF_FavFile8
      sMenuItem = "#SCS_WMNF_FavFile8"
    Case #SCS_WMNF_FavFile9
      sMenuItem = "#SCS_WMNF_FavFile9"
    Case #SCS_WMNF_FavFile10
      sMenuItem = "#SCS_WMNF_FavFile10"
    Case #SCS_WMNF_FavFile11
      sMenuItem = "#SCS_WMNF_FavFile11"
    Case #SCS_WMNF_FavFile12
      sMenuItem = "#SCS_WMNF_FavFile12"
    Case #SCS_WMNF_FavFile13
      sMenuItem = "#SCS_WMNF_FavFile13"
    Case #SCS_WMNF_FavFile14
      sMenuItem = "#SCS_WMNF_FavFile14"
    Case #SCS_WMNF_FavFile15
      sMenuItem = "#SCS_WMNF_FavFile15"
    Case #SCS_WMNF_FavFile16
      sMenuItem = "#SCS_WMNF_FavFile16"
    Case #SCS_WMNF_FavFile17
      sMenuItem = "#SCS_WMNF_FavFile17"
    Case #SCS_WMNF_FavFile18
      sMenuItem = "#SCS_WMNF_FavFile18"
    Case #SCS_WMNF_FavFile19
      sMenuItem = "#SCS_WMNF_FavFile19"
    Case #SCS_WMNF_FavFile20
      sMenuItem = "#SCS_WMNF_FavFile20"
      
    Case #SCS_WMNF_HB_00
      sMenuItem = "#SCS_WMNF_HB_00"
    Case #SCS_WMNF_HB_01
      sMenuItem = "#SCS_WMNF_HB_01"
    Case #SCS_WMNF_HB_02
      sMenuItem = "#SCS_WMNF_HB_02"
    Case #SCS_WMNF_HB_03
      sMenuItem = "#SCS_WMNF_HB_03"
    Case #SCS_WMNF_HB_04
      sMenuItem = "#SCS_WMNF_HB_04"
    Case #SCS_WMNF_HB_05
      sMenuItem = "#SCS_WMNF_HB_05"
    Case #SCS_WMNF_HB_06
      sMenuItem = "#SCS_WMNF_HB_06"
    Case #SCS_WMNF_HB_07
      sMenuItem = "#SCS_WMNF_HB_07"
    Case #SCS_WMNF_HB_08
      sMenuItem = "#SCS_WMNF_HB_08"
    Case #SCS_WMNF_HB_09
      sMenuItem = "#SCS_WMNF_HB_09"
    Case #SCS_WMNF_HB_10
      sMenuItem = "#SCS_WMNF_HB_10"
    Case #SCS_WMNF_HB_11
      sMenuItem = "#SCS_WMNF_HB_11"
    Case #SCS_WMNF_HB_12
      sMenuItem = "#SCS_WMNF_HB_12"
      
    Case #SCS_WMNF_HK_0
      sMenuItem = "#SCS_WMNF_HK_0"
    Case #SCS_WMNF_HK_1
      sMenuItem = "#SCS_WMNF_HK_1"
    Case #SCS_WMNF_HK_2
      sMenuItem = "#SCS_WMNF_HK_2"
    Case #SCS_WMNF_HK_3
      sMenuItem = "#SCS_WMNF_HK_3"
    Case #SCS_WMNF_HK_4
      sMenuItem = "#SCS_WMNF_HK_4"
    Case #SCS_WMNF_HK_5
      sMenuItem = "#SCS_WMNF_HK_5"
    Case #SCS_WMNF_HK_6
      sMenuItem = "#SCS_WMNF_HK_6"
    Case #SCS_WMNF_HK_7
      sMenuItem = "#SCS_WMNF_HK_7"
    Case #SCS_WMNF_HK_8
      sMenuItem = "#SCS_WMNF_HK_8"
    Case #SCS_WMNF_HK_9
      sMenuItem = "#SCS_WMNF_HK_9"
    Case #SCS_WMNF_HK_A
      sMenuItem = "#SCS_WMNF_HK_A"
    Case #SCS_WMNF_HK_B
      sMenuItem = "#SCS_WMNF_HK_B"
    Case #SCS_WMNF_HK_C
      sMenuItem = "#SCS_WMNF_HK_C"
    Case #SCS_WMNF_HK_D
      sMenuItem = "#SCS_WMNF_HK_D"
    Case #SCS_WMNF_HK_E
      sMenuItem = "#SCS_WMNF_HK_E"
    Case #SCS_WMNF_HK_F
      sMenuItem = "#SCS_WMNF_HK_F"
    Case #SCS_WMNF_HK_G
      sMenuItem = "#SCS_WMNF_HK_G"
    Case #SCS_WMNF_HK_H
      sMenuItem = "#SCS_WMNF_HK_H"
    Case #SCS_WMNF_HK_I
      sMenuItem = "#SCS_WMNF_HK_I"
    Case #SCS_WMNF_HK_J
      sMenuItem = "#SCS_WMNF_HK_J"
    Case #SCS_WMNF_HK_K
      sMenuItem = "#SCS_WMNF_HK_K"
    Case #SCS_WMNF_HK_L
      sMenuItem = "#SCS_WMNF_HK_L"
    Case #SCS_WMNF_HK_M
      sMenuItem = "#SCS_WMNF_HK_M"
    Case #SCS_WMNF_HK_N
      sMenuItem = "#SCS_WMNF_HK_N"
    Case #SCS_WMNF_HK_O
      sMenuItem = "#SCS_WMNF_HK_O"
    Case #SCS_WMNF_HK_P
      sMenuItem = "#SCS_WMNF_HK_P"
    Case #SCS_WMNF_HK_Q
      sMenuItem = "#SCS_WMNF_HK_Q"
    Case #SCS_WMNF_HK_R
      sMenuItem = "#SCS_WMNF_HK_R"
    Case #SCS_WMNF_HK_S
      sMenuItem = "#SCS_WMNF_HK_S"
    Case #SCS_WMNF_HK_T
      sMenuItem = "#SCS_WMNF_HK_T"
    Case #SCS_WMNF_HK_U
      sMenuItem = "#SCS_WMNF_HK_U"
    Case #SCS_WMNF_HK_V
      sMenuItem = "#SCS_WMNF_HK_V"
    Case #SCS_WMNF_HK_W
      sMenuItem = "#SCS_WMNF_HK_W"
    Case #SCS_WMNF_HK_X
      sMenuItem = "#SCS_WMNF_HK_X"
    Case #SCS_WMNF_HK_Y
      sMenuItem = "#SCS_WMNF_HK_Y"
    Case #SCS_WMNF_HK_Z
      sMenuItem = "#SCS_WMNF_HK_Z"
      
    Case #SCS_WMNF_HK_F1
      sMenuItem = "#SCS_WMNF_HK_F1"
    Case #SCS_WMNF_HK_F2
      sMenuItem = "#SCS_WMNF_HK_F2"
    Case #SCS_WMNF_HK_F3
      sMenuItem = "#SCS_WMNF_HK_F3"
    Case #SCS_WMNF_HK_F4
      sMenuItem = "#SCS_WMNF_HK_F4"
    Case #SCS_WMNF_HK_F5
      sMenuItem = "#SCS_WMNF_HK_F5"
    Case #SCS_WMNF_HK_F6
      sMenuItem = "#SCS_WMNF_HK_F6"
    Case #SCS_WMNF_HK_F7
      sMenuItem = "#SCS_WMNF_HK_F7"
    Case #SCS_WMNF_HK_F8
      sMenuItem = "#SCS_WMNF_HK_F8"
    Case #SCS_WMNF_HK_F9
      sMenuItem = "#SCS_WMNF_HK_F9"
    Case #SCS_WMNF_HK_F10
      sMenuItem = "#SCS_WMNF_HK_F10"
    Case #SCS_WMNF_HK_F11
      sMenuItem = "#SCS_WMNF_HK_F11"
    Case #SCS_WMNF_HK_F12
      sMenuItem = "#SCS_WMNF_HK_F12"
; Added 25Jul2020 but commented out when I realised that some of these 'shortcut keys' are already used as Master Fader shortcut keys
;     Case #SCS_WMNF_HK_ADD
;       sMenuItem = "#SCS_WMNF_HK_ADD"
;     Case #SCS_WMNF_HK_SUBTRACT
;       sMenuItem = "#SCS_WMNF_HK_SUBTRACT"
;     Case #SCS_WMNF_HK_DIVIDE
;       sMenuItem = "#SCS_WMNF_HK_DIVIDE"
;     Case #SCS_WMNF_HK_MULTIPLY
;       sMenuItem = "#SCS_WMNF_HK_MULTIPLY"
;     Case #SCS_WMNF_HK_DECIMAL
;       sMenuItem = "#SCS_WMNF_HK_DECIMAL"
      
    Case #SCS_WMNF_HK_PGUP ; Added 17Apr2022 11.9.1bb
      sMenuItem = "#SCS_WMNF_HK_PGUP"
    Case #SCS_WMNF_HK_PGDN ; Added 17Apr2022 11.9.1bb
      sMenuItem = "#SCS_WMNF_HK_PGDN"
      
    Case #SCS_WEDF_FindCue
      sMenuItem = "#SCS_WEDF_FindCue"
    Case #SCS_WEDF_Save
      sMenuItem = "#SCS_WEDF_Save"
    Case #SCS_WEDF_Undo
      sMenuItem = "#SCS_WEDF_Undo"
    Case #SCS_WEDF_Redo
      sMenuItem = "#SCS_WEDF_Redo"
    Case #SCS_WEDF_Rewind
      sMenuItem = "#SCS_WEDF_Rewind"
    Case #SCS_WEDF_PlayPause
      sMenuItem = "#SCS_WEDF_PlayPause"
    Case #SCS_WEDF_Stop
      sMenuItem = "#SCS_WEDF_Stop"
    Case #SCS_WEDF_IncLevels
      sMenuItem = "#SCS_WEDF_IncLevels"
    Case #SCS_WEDF_DecLevels
      sMenuItem = "#SCS_WEDF_DecLevels"
    Case #SCS_WEDF_SkipBack
      sMenuItem = "#SCS_WEDF_SkipBack"
    Case #SCS_WEDF_SkipForward
      sMenuItem = "#SCS_WEDF_SkipForward"
    Case #SCS_WEDF_SelectAll
      sMenuItem = "#SCS_WEDF_SelectAll"
    Case #SCS_WEDF_AddCueMarker
      sMenuItem = "#SCS_WEDF_AddCueMarker"
    Case #SCS_WEDF_CueMarkerPrev
      sMenuItem = "#SCS_WEDF_CueMarkerPrev"
    Case #SCS_WEDF_CueMarkerNext
      sMenuItem = "#SCS_WEDF_CueMarkerNext"
    Case #SCS_WEDF_CallLinkDevs
      sMenuItem = "#SCS_WEDF_CallLinkDevs"
      
    Case #SCS_WEDK_TapDelay
      sMenuItem = "#SCS_WEDK_TapDelay"
      
    Case #SCS_ALLF_BumpLeft
      sMenuItem = "#SCS_ALLF_BumpLeft"
    Case #SCS_ALLF_BumpRight
      sMenuItem = "#SCS_ALLF_BumpRight"
      
    Case #WQE_mnu_PageColor
      sMenuItem = "#WQE_mnu_PageColor"
    Case #WQE_mnu_TextBackColor
      sMenuItem = "#WQE_mnu_TextBackColor"
    Case #WQE_mnu_TextColor
      sMenuItem = "#WQE_mnu_TextColor"
    Case #WQE_mnu_Font
      sMenuItem = "#WQE_mnu_Font"
    Case #WQE_mnu_Search
      sMenuItem = "#WQE_mnu_Search"
    Case #WQE_mnu_Cut
      sMenuItem = "#WQE_mnu_Cut"
    Case #WQE_mnu_Copy
      sMenuItem = "#WQE_mnu_Copy"
    Case #WQE_mnu_Paste
      sMenuItem = "#WQE_mnu_Paste"
    Case #WQE_mnu_Undo
      sMenuItem = "#WQE_mnu_Undo"
    Case #WQE_mnu_Redo
      sMenuItem = "#WQE_mnu_Redo"
    Case #WQE_mnu_Bold
      sMenuItem = "#WQE_mnu_Bold"
    Case #WQE_mnu_Italic
      sMenuItem = "#WQE_mnu_Italic"
    Case #WQE_mnu_Underline
      sMenuItem = "#WQE_mnu_Underline"
    Case #WQE_mnu_Left
      sMenuItem = "#WQE_mnu_Left"
    Case #WQE_mnu_Center
      sMenuItem = "#WQE_mnu_Center"
    Case #WQE_mnu_Right
      sMenuItem = "#WQE_mnu_Right"
    Case #WQE_mnu_SelectAll
      sMenuItem = "#WQE_mnu_SelectAll"
    Case #WQE_mnu_Indent
      sMenuItem = "#WQE_mnu_Indent"
    Case #WQE_mnu_Outdent
      sMenuItem = "#WQE_mnu_Outdent"
    Case #WQE_mnu_List
      sMenuItem = "#WQE_mnu_List"
    Case #WQE_mnu_misc_popup_menu
      sMenuItem = "#WQE_mnu_misc_popup_menu"
    Case #WQE_mnu_linespacing_1
      sMenuItem = "#WQE_mnu_linespacing_1"
    Case #WQE_mnu_linespacing_1_5
      sMenuItem = "#WQE_mnu_linespacing_1_5"
    Case #WQE_mnu_linespacing_2_0
      sMenuItem = "#WQE_mnu_linespacing_2_0"
    Case #WQE_mnu_pct_10
      sMenuItem = "#WQE_mnu_pct_10"
    Case #WQE_mnu_pct_25
      sMenuItem = "#WQE_mnu_pct_25"
    Case #WQE_mnu_pct_50
      sMenuItem = "#WQE_mnu_pct_50"
    Case #WQE_mnu_pct_75
      sMenuItem = "#WQE_mnu_pct_75"
    Case #WQE_mnu_pct_100
      sMenuItem = "#WQE_mnu_pct_100"
    Case #WQE_mnu_pct_125
      sMenuItem = "#WQE_mnu_pct_125"
    Case #WQE_mnu_pct_150
      sMenuItem = "#WQE_mnu_pct_150"
    Case #WQE_mnu_pct_200
      sMenuItem = "#WQE_mnu_pct_200"
    Case #WQE_mnu_pct_400
      sMenuItem = "#WQE_mnu_pct_400"
      
    Case #PNL_mnu_switch_cue
      sMenuItem = "#PNL_mnu_switch_cue"
    Case #PNL_mnu_switch_file
      sMenuItem = "#PNL_mnu_switch_file"
    Case #PNL_mnu_switch_popup
      sMenuItem = "#PNL_mnu_switch_popup"
    Case #PNL_mnu_switch_sub
      sMenuItem = "#PNL_mnu_switch_sub"
      
    Case #WDD_mnu_BackColor_Default
      sMenuItem = "#WDD_mnu_BackColor_Default"
    Case #WDD_mnu_BackColor_Picker
      sMenuItem = "#WDD_mnu_BackColor_Picker"
    Case #WDD_mnu_BackColor_Popup
      sMenuItem = "#WDD_mnu_BackColor_Popup"
      
    Case #WOP_mnuASIODevs
      sMenuItem = "#WOP_mnuASIODevs"
    Case #WOP_mnuASIODev0 To #WOP_mnuASIODevLast
      sMenuItem = "#WOP_mnuASIODev" + Str(nMenuItem - #WOP_mnuASIODev0)
      
    Default
      sMenuItem = Str(nMenuItem)
  EndSelect
  ProcedureReturn sMenuItem
EndProcedure

Procedure dateToNumber(pDate)
  PROCNAMEC()
  ;  ProcedureReturn DateDiff("d", #7/6/1944, pdate)
  Protected nTimeDiff, nNumber
  
  nTimeDiff = pDate - Date(1970,1,1,0,0,0)           ; seconds between 1Jan1970 and pDate (1Jan1970 is earliest date the PB Date library handles)
  nNumber = Round(nTimeDiff / 86400, #PB_Round_Down) ; days between 1Jan1970 and pDate
  nNumber + 9310                                     ; 9310 = number of days between 6Jul1944 and 1Jan1970. 6Jul1944 is 'base date' used in SCS 10 and used in time-limited authorisation strings
  debugMsgAS(sProcName, "pDate=" + FormatDate("%yyyy/%mm/%dd", pDate) + ", nTimeDiff=" + nTimeDiff + ", nNumber=" + nNumber)
  ProcedureReturn nNumber
  
EndProcedure

Procedure numberToDate(pNumber)
  PROCNAMEC()
  ;ProcedureReturn #7/6/1944 + pNumber
  Protected nNumber, dtDate
  
  nNumber = pNumber - 9310        ; 9310 = number of days between 6Jul1944 and 1Jan1970. 6Jul1944 is 'base date' used in SCS 10 and used in time-limited authorisation strings
  dtDate = Date(1970,1,1,0,0,0)   ; 1Jan1970 is earliest date the PB Date library handles
  ; debugMsg(sProcName, "dtDate=" + FormatDate("%yyyy/%mm/%dd", dtDate))
  dtDate = AddDate(dtDate, #PB_Date_Day, nNumber)
  debugMsgAS(sProcName, "pNumber=" + pNumber + ", nNumber=" + nNumber + ", dtDate=" + FormatDate("%yyyy/%mm/%dd", dtDate))
  ProcedureReturn dtDate
EndProcedure

Procedure getTimeOfDayInSeconds()
  PROCNAMEC()
  Protected nDate = Date()
  
  ProcedureReturn (Hour(nDate) * 3600) + (Minute(nDate) * 60) + (Second(nDate))
EndProcedure

Procedure.s FormatUsingF(fNumber.f, sFormat.s)
  PROCNAMEC()
  ; adapted for Floats from "Procedure.s FormatUsingL"
  ; warning - not yet working - displays decimal point twice, eg 0..06 instead of 0.06
  Protected sChar.s, sNumberString.s, t$, d$, u$, d, f, p
  
  debugMsg(sProcName, #SCS_START + ", fNumber=" + StrF(fNumber) + ", sFormat=" + sFormat)
  p = FindString(sFormat, ".", 1)
  If p = 0
    d = 0
  Else
    d = Len(sFormat) - p
  EndIf
  debugMsg(sProcName, "d=" + d)
  
  sNumberString = StrF(fNumber, d)
  d = Len(sNumberString)+1 
  f = CountString(sFormat,"#") + CountString(sFormat,"0") + CountString(sFormat,"_") 
  debugMsg(sProcName,"sNumberString=" + sNumberString + ", d=" + d + ", f=" + f + ", sFormat=" + sFormat)
  If (d-1) < (f+1) ; Number fits into sFormat, so do it. 
    For p = Len(sFormat) To 1 Step -1 
      sChar = Mid(sFormat,p,1) 
      Select sChar 
          Case "#" : d-1 : If d<1 : d$="" : Else : d$=Mid(sNumberString,d,1) : EndIf 
          Case "0" : d-1 : If d<1 : d$="0" : Else : d$=Mid(sNumberString,d,1) : EndIf 
          Case "_" : d-1 : If d<1 : d$=" " : Else : d$=Mid(sNumberString,d,1) : EndIf 
        Default : d$=sChar 
      EndSelect 
      t$+d$ 
    Next 
    For p=Len(t$) To 1 Step -1 : u$+Mid(t$,p,1) : Next p
  EndIf
  debugMsg(sProcName, #SCS_END + ", returning " + Trim(u$))
  ProcedureReturn Trim(u$)
EndProcedure 

Procedure.s FormatUsingD(dNumber.d, sFormat.s)
  ; adapted for Doubles from "Procedure.s FormatUsingF"
  Protected sChar.s, sNumberString.s, t$, d$, u$, d, f, p
  
  sNumberString = StrD(dNumber)
  d = Len(sNumberString)+1 
  f = CountString(sFormat,"#") + CountString(sFormat,"0") + CountString(sFormat,"_")
  If d-1 < f+1 ; Number fits into sFormat, so do it. 
    For p = Len(sFormat) To 1 Step -1 
      sChar = Mid(sFormat,p,1) 
      Select sChar 
          Case "#" : d-1 : If d<1 : d$="" : Else : d$=Mid(sNumberString,d,1) : EndIf 
          Case "0" : d-1 : If d<1 : d$="0" : Else : d$=Mid(sNumberString,d,1) : EndIf 
          Case "_" : d-1 : If d<1 : d$=" " : Else : d$=Mid(sNumberString,d,1) : EndIf 
        Default : d$=sChar 
      EndSelect 
      t$+d$ 
    Next 
    For p=Len(t$) To 1 Step -1 : u$+Mid(t$,p,1) : Next p
  EndIf 
  ProcedureReturn Trim(u$)
EndProcedure 

Procedure.s decodeActiveState(nActiveState)
  Protected sActiveState.s
  Select nActiveState
    Case #BASS_ACTIVE_STOPPED
      sActiveState = "BASS_ACTIVE_STOPPED"
    Case #BASS_ACTIVE_PLAYING
      sActiveState = "BASS_ACTIVE_PLAYING"
    Case #BASS_ACTIVE_STALLED
      sActiveState = "BASS_ACTIVE_STALLED"
    Case #BASS_ACTIVE_PAUSED
      sActiveState = "BASS_ACTIVE_PAUSED"
    Case #BASS_ACTIVE_PAUSED_DEVICE
      sActiveState = "BASS_ACTIVE_PAUSED_DEVICE"
    Default
      sActiveState = Str(nActiveState)
  EndSelect
  ProcedureReturn sActiveState
EndProcedure

Procedure.s decodeAsioBufLen(nAsioBufLen)
  Protected sAsioBufLen.s
  Select nAsioBufLen
    Case #SCS_ASIOBUFLEN_MAX
      sAsioBufLen = "SCS_ASIOBUFLEN_MAX"
    Case #SCS_ASIOBUFLEN_PREF
      sAsioBufLen = "SCS_ASIOBUFLEN_PREF"
    Default
      sAsioBufLen = Str(nAsioBufLen)
  EndSelect
  ProcedureReturn sAsioBufLen
EndProcedure

Procedure.s decodeHandle(nHandle)
  ; see notes for macro newHandle()
  Protected n
  
  If nHandle <> 0
    For n = 0 To gnMaxHandleIndex
      If n <= ArraySize(gaHandle()) ; Test added 18Apr2025 11.10.8az following bug report from Miquel Riera
        If gaHandle(n)\nHandle = nHandle
          ProcedureReturn gaHandle(n)\sMnemonic
        EndIf
      Else
        Break
      EndIf
    Next n
  EndIf
  ProcedureReturn Str(nHandle)
  
EndProcedure

Procedure.s decodeMutex(nMutexNo)
  Protected sMutex.s
  
  Select nMutexNo
    Case #SCS_MUTEX_CUE_LIST
      sMutex = "#SCS_MUTEX_CUE_LIST"
    Case #SCS_MUTEX_DEBUG
      sMutex = "#SCS_MUTEX_DEBUG"
    Case #SCS_MUTEX_DMX_SEND
      sMutex = "#SCS_MUTEX_DMX_SEND"
    Case #SCS_MUTEX_HTTP_SEND
      sMutex = "#SCS_MUTEX_HTTP_SEND"
    Case #SCS_MUTEX_IMAGE
      sMutex = "#SCS_MUTEX_IMAGE"
    Case #SCS_MUTEX_MTC_SEND
      sMutex = "#SCS_MUTEX_MTC_SEND"
    Case #SCS_MUTEX_NETWORK_SEND
      sMutex = "#SCS_MUTEX_NETWORK_SEND"
    Case #SCS_MUTEX_SMS_NETWORK
      sMutex = "#SCS_MUTEX_SMS_NETWORK"
    Case #SCS_MUTEX_TEMP_DATABASE
      sMutex = "#SCS_MUTEX_TEMP_DATABASE"
    Case #SCS_MUTEX_LOAD_SAMPLES
      sMutex = "#SCS_MUTEX_LOAD_SAMPLES"
    Case #SCS_MUTEX_VMIX_SEND
      sMutex = "#SCS_MUTEX_VMIX_SEND"
    Default
      sMutex = Str(nMutexNo)
  EndSelect
  ProcedureReturn sMutex
EndProcedure

Procedure.s decodeCueToGoState(nCueToGoState)
  Protected sCueToGoState.s
  
  Select nCueToGoState
    Case #SCS_Q2GO_NOT_SET
      sCueToGoState = "not set"
    Case #SCS_Q2GO_ENABLED
      sCueToGoState = "enabled"
    Case #SCS_Q2GO_DISABLED
      sCueToGoState = "disabled"
    Case #SCS_Q2GO_END
      sCueToGoState = "end"
    Default
      sCueToGoState = Str(nCueToGoState)
  EndSelect
  ProcedureReturn sCueToGoState
EndProcedure

Procedure condFreeFont(nFontId)
  If IsFont(nFontId)
    FreeFont(nFontId)
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure condFreeGadget(nGadgetId)
  PROCNAMEC()
  
  If IsGadget(nGadgetId)
    scsFreeGadget(nGadgetId)
    debugMsg(sProcName, "scsFreeGadget(G" + nGadgetId + ")")
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure.s traceTime(qTime.q)
  ; PROCNAMEC()
  Protected qMillisecondsSinceStart.q
  Protected nHours, nMins, nSecs, nMillisecs
  Protected nHours2, nMins2, nSecs2, nMillisecs2, nOverflow
  Protected sTraceTime.s
  
  If qTime = 0
    sTraceTime = "ns"
  Else
    qMillisecondsSinceStart = qTime - gqStartTime
    nHours = Round(qMillisecondsSinceStart / 3600000, #PB_Round_Down)
    qMillisecondsSinceStart - (nHours * 3600000)
    nMins = Round(qMillisecondsSinceStart / 60000, #PB_Round_Down)
    qMillisecondsSinceStart - (nMins * 60000)
    nSecs = Round(qMillisecondsSinceStart / 1000, #PB_Round_Down)
    nMillisecs = qMillisecondsSinceStart - (nSecs * 1000)
    
    With grStartTime
      nMillisecs2 = nMillisecs + \wMilliseconds
      If nMillisecs2 >= 1000
        nOverflow = Round(nMillisecs2 / 1000, #PB_Round_Down)
        nMillisecs2 - (nOverflow * 1000)
      Else
        nOverflow = 0
      EndIf
      nSecs2 = nSecs + \wSecond + nOverflow
      If nSecs2 >= 60
        nOverflow = Round(nSecs2 / 60, #PB_Round_Down)
        nSecs2 - (nOverflow * 60)
      Else
        nOverflow = 0
      EndIf
      nMins2 = nMins + \wMinute + nOverflow
      ; debugMsg(sProcName, "(a) qTime=" + qTime + ", nMins=" + nMins + ", \wMinute=" + \wMinute + ", nOverflow=" + nOverflow + ", nMins2=" + nMins2)
      If nMins2 >= 60
        nOverflow = Round(nMins2 / 60, #PB_Round_Down)
        nMins2 - (nOverflow * 60)
      Else
        nOverflow = 0
      EndIf
      ; debugMsg(sProcName, "(b) qTime=" + qTime + ", nMins=" + nMins + ", \wMinute=" + \wMinute + ", nOverflow=" + nOverflow + ", nMins2=" + nMins2)
      nHours2 = nHours + \wHour + nOverflow
      If nHours >= 24
        nOverflow = Round(nHours2 / 24, #PB_Round_Down)
        nHours2 - (nOverflow * 24)
      Else
        nOverflow = 0
      EndIf
    EndWith
    sTraceTime = RSet(Str(nHours2),2,"0") + ":" + RSet(Str(nMins2),2,"0") + ":" + RSet(Str(nSecs2),2,"0") + "." + RSet(Str(nMillisecs2),3,"0")
  EndIf
  
  ; Debug "sTraceTime=" + sTraceTime
  ProcedureReturn sTraceTime
  
EndProcedure

Procedure SetTopMostWindow(nWindowNo, bTopmost)
  PROCNAMEC()
  ; Function sets a window as always on top, or turns this off
  ; bTopmost - do you want it always on top or not
  Protected nFlags.l, nResult.l
  
  debugMsg(sProcName, #SCS_START + ", nWindowNo=" + decodeWindow(nWindowNo) + ", bTopmost=" + strB(bTopmost))
  nFlags = #SWP_NOMOVE | #SWP_NOSIZE
  If bTopmost = #True ;make the window topmost
    nResult = SetWindowPos_(WindowID(nWindowNo), #HWND_TOPMOST, 0, 0, 0, 0, nFlags)
  Else
    nResult = SetWindowPos_(WindowID(nWindowNo), #HWND_NOTOPMOST, 0, 0, 0, 0, nFlags)
  EndIf
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn nResult
EndProcedure

Procedure IsNumeric(sText.s)
  PROCNAMEC()
  Protected sMyText1.s, sMyText2.s
  Protected nDotPos, nDecLength
  
  sMyText1 = LTrim(Trim(UCase(sText)), "0")   ; NB LTrim removes leading zeros - necessary for comparisons against Str(ValF(...))
  If Len(sMyText1) = 0
    ; sText is blank or only contains zeros
    ProcedureReturn #True
  EndIf
  
  nDotPos = FindString(sMyText1, ".", 1)
  If nDotPos = 0
    nDotPos = FindString(sMyText1, ",", 1)
  EndIf
  If nDotPos > 0
    If nDotPos = 1
      ; convert something like ".2" to "0.2"
      sMyText2 = "0" + sMyText1
      sMyText1 = sMyText2
      nDotPos + 1
    EndIf
    nDecLength = Len(sMyText1) - nDotPos
    sMyText2 = StrF(ValF(sMyText1), nDecLength)
    ; can't use debugMsg() as it hasn't been declared yet
    ; Debug sProcName + " (a) sMyText1=" + sMyText1 + ", sMyText2=" + sMyText2
    If sMyText2 = Left(LSet(sMyText1, Len(sMyText2), "0"), Len(sMyText2))
      ; Debug "(a) OK"
      ProcedureReturn #True
    Else
      ; Debug "(a) Failed"
    EndIf
  Else
    ; Changed ValF() to Val() 20May2022 11.9.2ab following test of Brian Larsen's DMX issue
    ; sMyText2 = Str(ValF(sText))
    sMyText2 = Str(Val(sText))
    ; can't use debugMsg() as it hasn't been declared yet
    ; Debug sProcName + " (b) sMyText1=" + sMyText1 + ", sMyText2=" + sMyText2
    If sMyText2 = sMyText1
      ; Debug "(b) OK"
      ProcedureReturn #True
    Else
      ; Debug "(b) Failed"
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure 

Procedure IsInteger(pString.s)
  Protected sMyString.s
  
  sMyString = Trim(pString)
  If sMyString
    If IsNumeric(sMyString) = #False
      ProcedureReturn #False
    ElseIf CountString(sMyString, ".") > 0 Or CountString(sMyString, ",") > 0
      ProcedureReturn #False
    Else
      ProcedureReturn #True
    EndIf
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure IsHexString(pString.s)
  Protected sWorkString.s, nPos, bIsHexString
  
  sWorkString = UCase(pString)
  bIsHexString = #True
  For nPos = 1 To Len(sWorkString)
    If FindString(#SCS_HEX_VALID_CHARS, Mid(sWorkString, nPos, 1)) = 0
      bIsHexString = #False
      Break
    EndIf
  Next nPos
  ProcedureReturn bIsHexString
EndProcedure

Procedure DoEvents()
  ; not sure what to do here, if anything. freak suggested the following but I think I could lose the event.
  ; While WindowEvent() : Wend
  ; also, it should probably have a delay(n) included to yield to other processes.
  Delay(10)
EndProcedure

Procedure setSliderShortcuts(nWindowNo)
  ; AddKeyboardShortcut(nWindowNo, #PB_Shortcut_Control | #PB_Shortcut_Left, #SCS_ALLF_BumpLeft)
  ; AddKeyboardShortcut(nWindowNo, #PB_Shortcut_Control | #PB_Shortcut_Right, #SCS_ALLF_BumpRight)
EndProcedure

Procedure booleanToCheckboxState(bBoolean)
  ; nb obviously does not handle setting the checkbox state to #PB_Checkbox_Inbetween
  If bBoolean
    ProcedureReturn #PB_Checkbox_Checked
  Else
    ProcedureReturn #PB_Checkbox_Unchecked
  EndIf
EndProcedure

Procedure.s booleanToString(bBoolean)
  If bBoolean
    ProcedureReturn "1"
  Else
    ProcedureReturn "0"
  EndIf
EndProcedure

Procedure.s decodeSaveAsFormat(nSaveAsFormat)
  Protected sSaveAsFormat.s
  
  Select nSaveAsFormat
    Case #SCS_SAVEAS_SCS11
      sSaveAsFormat = "SCS 11"
    Default
      sSaveAsFormat = Str(nSaveAsFormat)
  EndSelect
  ProcedureReturn sSaveAsFormat
EndProcedure

Procedure.s buildAudLabel(pAudPtr)
  If pAudPtr >= 0
    ProcedureReturn aAud(pAudPtr)\sCue + "<" + Str(aAud(pAudPtr)\nSubNo) + "." + Str(aAud(pAudPtr)\nAudNo) + ">"
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure.s buildSubLabel(pSubPtr)
  If pSubPtr >= 0
    ProcedureReturn aSub(pSubPtr)\sCue + "<" + Str(aSub(pSubPtr)\nSubNo) + ">"
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure.s buildSubLabel2(pSubPtr)
  If pSubPtr >= 0
    ProcedureReturn a2ndSub(pSubPtr)\sCue + "<" + Str(a2ndSub(pSubPtr)\nSubNo) + ">"
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure.s getAudLabelProc(pAudPtr, pProcName.s)
  PROCNAMEC()
  Protected sAudLabel.s
  
  If pAudPtr >= 0
    CheckSubInRange(pAudPtr, ArraySize(aAud()), "aAud(), pProcName=" + pProcName)
    sAudLabel = aAud(pAudPtr)\sAudLabel
  EndIf
  If Len(sAudLabel) = 0
    sAudLabel = "{" + pAudPtr + "}"
  EndIf
  ProcedureReturn sAudLabel
EndProcedure

Macro getAudLabel(pAudPtr)
  getAudLabelProc(pAudPtr, sProcName)
EndMacro

Procedure.s getAudLabel2(pAudPtr)
  PROCNAMEC()
  Protected sAudLabel.s
  
  If pAudPtr >= 0
    CheckSubInRange(pAudPtr, ArraySize(a2ndAud()), "a2ndAud()")
    sAudLabel = a2ndAud(pAudPtr)\sAudLabel
  EndIf
  If Len(sAudLabel) = 0
    sAudLabel = "{" + pAudPtr + "}"
  EndIf
  ProcedureReturn sAudLabel
EndProcedure

Procedure.s buildAudProcName(pProcName.s, pAudPtr, bPrimaryFile=#True)
  PROCNAME(pProcName)
  
  If pAudPtr >= 0
    If bPrimaryFile
      ProcedureReturn pProcName + "[" + getAudLabel(pAudPtr) + "]"
    Else
      ProcedureReturn pProcName + "[" + getAudLabel2(pAudPtr) + "]"
    EndIf
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s getSubLabel(pSubPtr)
  PROCNAMEC()
  Protected sSubLabel.s
  
  If pSubPtr >= 0
    CheckSubInRange(pSubPtr, ArraySize(aSub()), "aSub()")
    sSubLabel = aSub(pSubPtr)\sSubLabel
  EndIf
  If Len(sSubLabel) = 0
    sSubLabel = "{" + pSubPtr + "}"
  EndIf
  ProcedureReturn sSubLabel
EndProcedure

Procedure.s getSubLabel2(pSubPtr)
  PROCNAMEC()
  Protected sSubLabel.s
  
  If pSubPtr >= 0
    CheckSubInRange(pSubPtr, ArraySize(a2ndSub()), "a2ndSub()")
    sSubLabel = a2ndSub(pSubPtr)\sSubLabel
  EndIf
  If Len(sSubLabel) = 0
    sSubLabel = "{" + pSubPtr + "}"
  EndIf
  ProcedureReturn sSubLabel
EndProcedure

Procedure.s buildSubProcName(pProcName.s, pSubPtr, bPrimaryFile=#True)
  ; PROCNAME(pProcName)
  
  If pSubPtr >= 0
    If bPrimaryFile
      ProcedureReturn pProcName + "[" + getSubLabel(pSubPtr) + "]"
    Else
      ProcedureReturn pProcName + "[" + getSubLabel2(pSubPtr) + "]"
    EndIf
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s getProdGlobal(*rProd.tyProd)
  Protected sProdGlobal.s
  
  Select *rProd
    Case @grProd
      sProdGlobal = "grProd"
    Case @grProdForDevChgs
      sProdGlobal = "grProdForDevChgs"
    Case @grProdForChecker
      sProdGlobal = "grProdForChecker"
    Case @grProdDef
      sProdGlobal = "grProdDef"
    Case @grProdDefForAdd
      sProdGlobal = "grProdDefForAdd"
    Default
      sProdGlobal = "?"
  EndSelect
  ProcedureReturn sProdGlobal
EndProcedure

Procedure.s getCueLabel(pCuePtr)
  ; PROCNAMEC()
  Protected sCueLabel.s
  
  If pCuePtr = gnCueEnd
    sCueLabel = "[End]"
  ElseIf (pCuePtr > 0) And (pCuePtr < gnCueEnd)
    sCueLabel = aCue(pCuePtr)\sCue
  EndIf
  If Len(sCueLabel) = 0
    sCueLabel = "{" + pCuePtr + "}"
  EndIf
  ProcedureReturn sCueLabel
EndProcedure

Procedure.s getCueLabel2(pCuePtr)
  ; PROCNAMEC()
  Protected sCueLabel.s
  
  If pCuePtr = gn2ndCueEnd
    sCueLabel = "[End]"
  ElseIf (pCuePtr > 0) And (pCuePtr < gn2ndCueEnd)
    sCueLabel = a2ndCue(pCuePtr)\sCue
  EndIf
  If Len(sCueLabel) = 0
    sCueLabel = "{" + pCuePtr + "}"
  EndIf
  ProcedureReturn sCueLabel
EndProcedure

Procedure.s buildCueProcName(pProcName.s, pCuePtr)
  If pCuePtr >= 0
    ProcedureReturn pProcName + "[" + getCueLabel(pCuePtr) + "]"
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s buildCueProcName2(pProcName.s, pCuePtr)
  If pCuePtr >= 0
    ProcedureReturn pProcName + "[" + getCueLabel2(pCuePtr) + "]"
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s buildCuePanelProcName(pProcName.s, h)
  If h >= 0
    ProcedureReturn pProcName + "{" + h + "}"
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s buildSliderProcName(pProcName.s, nSldPtr)
  If nSldPtr >= 0
    ProcedureReturn pProcName + "[" + gaSlider(nSldPtr)\sName + "]"
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure.s decodeCtrlPanelPos(nCtrlPanelPos)
  Protected sCtrlPanelPos.s
  
  Select nCtrlPanelPos
    Case #SCS_CTRLPANEL_BOTTOM
      sCtrlPanelPos = "Bottom"
    Case #SCS_CTRLPANEL_NONE
      sCtrlPanelPos = "None"
    Case #SCS_CTRLPANEL_TOP
      sCtrlPanelPos = "Top"
  EndSelect
  ProcedureReturn sCtrlPanelPos
EndProcedure

Procedure encodeCtrlPanelPos(sCtrlPanelPos.s)
  Protected nCtrlPanelPos
  
  Select sCtrlPanelPos
    Case "Bottom"
      nCtrlPanelPos = #SCS_CTRLPANEL_BOTTOM
    Case "None"
      nCtrlPanelPos = #SCS_CTRLPANEL_NONE
    Default
      nCtrlPanelPos = #SCS_CTRLPANEL_TOP
  EndSelect
  ProcedureReturn nCtrlPanelPos
EndProcedure

Procedure.s decodeCtrlType(nCtrlType)
  ; currently only used for debugging, which is why there is no need for an encodeCtrlType() procedure
  Protected sCtrltype.s
  
  Select nCtrlType
    Case #SCS_CTRLTYPE_LIVE_INPUT
      sCtrltype = "Live_Input"
    Case #SCS_CTRLTYPE_OUTPUT
      sCtrltype = "Output"
    Case #SCS_CTRLTYPE_MASTER
      sCtrltype = "Master"
    Case #SCS_CTRLTYPE_DMX_MASTER
      sCtrltype = "DMX Master"
    Case #SCS_CTRLTYPE_EQ_SELECT
      sCtrltype = "EQ_Select"
    Case #SCS_CTRLTYPE_EQ_KNOB
      sCtrltype = "EQ_Knob"
    Case #SCS_CTRLTYPE_EQ_BTN
      sCtrltype = "EQ_Btn"
    Case #SCS_CTRLTYPE_MUTE
      sCtrltype = "Mute"
    Case #SCS_CTRLTYPE_SOLO ; Added 24Jun2022 11.9.4
      sCtrltype = "Solo"
    Case #SCS_CTRLTYPE_DIMMER_CHANNEL ; Added 11Jul2022 11.9.4
      sCtrltype = "Dimmer Channel"
    Case #SCS_CTRLTYPE_PLAYING ; Added 28Aug2023 11.10.0by
      sCtrltype = "Playing"
    Default
      sCtrltype = Str(nCtrlType)
  EndSelect
  ProcedureReturn sCtrltype
EndProcedure

Procedure.s decodeGraphDisplayMode(nGraphDisplayMode)
  Protected sGraphDisplayMode.s
  
  Select nGraphDisplayMode
    Case #SCS_GRAPH_ADJ
      sGraphDisplayMode = "Adj"
    Case #SCS_GRAPH_ADJN
      sGraphDisplayMode = "AdjN"
    Case #SCS_GRAPH_FILE
      sGraphDisplayMode = "File"
    Case #SCS_GRAPH_FILEN
      sGraphDisplayMode = "FileN"
  EndSelect
  ProcedureReturn sGraphDisplayMode
EndProcedure

Procedure encodeGraphDisplayMode(sGraphDisplayMode.s)
  Protected nGraphDisplayMode
  
  Select sGraphDisplayMode
    Case "Adj"
      nGraphDisplayMode = #SCS_GRAPH_ADJ
    Case "AdjN"
      nGraphDisplayMode = #SCS_GRAPH_ADJN
    Case "File"
      nGraphDisplayMode = #SCS_GRAPH_FILE
    Case "FileN"
      nGraphDisplayMode = #SCS_GRAPH_FILEN
    Default
      nGraphDisplayMode = #SCS_GRAPH_FILE
  EndSelect
  ProcedureReturn nGraphDisplayMode
EndProcedure

Procedure.s decodeTransType(nTransType)
  Protected sTransType.s
  
  Select nTransType
    Case #SCS_TRANS_XFADE
      sTransType = "xfade"
    Case #SCS_TRANS_MIX
      sTransType = "mix"
    Case #SCS_TRANS_WAIT
      sTransType = "wait"
    Default
      sTransType = ""
  EndSelect
  ProcedureReturn sTransType
EndProcedure

Procedure encodeTransType(sTransType.s)
  Protected nTransType
  
  Select sTransType
    Case "xfade"
      nTransType = #SCS_TRANS_XFADE
    Case "mix"
      nTransType = #SCS_TRANS_MIX
    Case "wait"
      nTransType = #SCS_TRANS_WAIT
    Default
      nTransType = #SCS_TRANS_NONE
  EndSelect
  ProcedureReturn nTransType
EndProcedure

Procedure.s decodeMainToolBarInfo(nMainToolBarInfo)
  Protected sMainToolBarInfo.s
  
  Select nMainToolBarInfo
    Case #SCS_TOOL_DISPLAY_MIN
      sMainToolBarInfo = "Min"
    Case #SCS_TOOL_DISPLAY_NONE
      sMainToolBarInfo = "None"
    Case #SCS_TOOL_DISPLAY_ALL
      sMainToolBarInfo = "All"
  EndSelect
  ProcedureReturn sMainToolBarInfo
EndProcedure

Procedure encodeMainToolBarInfo(sMainToolBarInfo.s, nOperMode)
  Protected nMainToolBarInfo
  
  Select sMainToolBarInfo
    Case "Min"
      nMainToolBarInfo = #SCS_TOOL_DISPLAY_MIN
    Case "None"
      If grProgVersion\nBuildDate < 20211111 And nOperMode = #SCS_OPERMODE_PERFORMANCE
        ; As from 10Nov2021 11.8.6bv, the default maintoolbar info for performance mode was changed from 'none' to 'min' (see also setPrefOperModeDefaults())
        nMainToolBarInfo = #SCS_TOOL_DISPLAY_MIN
      Else
        nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
      EndIf
    Default
      nMainToolBarInfo = #SCS_TOOL_DISPLAY_ALL
  EndSelect
  ProcedureReturn nMainToolBarInfo
EndProcedure

Procedure.s decodeRunMode(nRunMode)
  Protected sRunMode.s
  
  Select nRunMode
    Case #SCS_RUN_MODE_LINEAR
      sRunMode = "Linear"
    Case #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND
      sRunMode = "NonLinear_Demand"
    Case #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
      sRunMode = "NonLinear_All"
    Case #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND
      sRunMode = "Both_Demand"
    Case #SCS_RUN_MODE_BOTH_PREOPEN_ALL
      sRunMode = "Both_All"
    Default
      sRunMode = "Linear"
  EndSelect
  ProcedureReturn sRunMode
EndProcedure

Procedure encodeRunMode(sRunMode.s)
  Protected nRunMode
  
  Select sRunMode
      ; note: numeric values, eg "0", are to accept cue files pre 11.4.1.2f
    Case "0"
      nRunMode = #SCS_RUN_MODE_LINEAR
    Case "1"
      nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND
    Case "2"
      nRunMode = #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
    Case "3"
      nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND
    Case "4"
      nRunMode = #SCS_RUN_MODE_BOTH_PREOPEN_ALL
      
    Case "Linear"
      nRunMode = #SCS_RUN_MODE_LINEAR
    Case "NonLinear_Demand"
      nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND
    Case "NonLinear_All"
      nRunMode = #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
    Case "Both_Demand"
      nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND
    Case "Both_All"
      nRunMode = #SCS_RUN_MODE_BOTH_PREOPEN_ALL
      
    Default
      nRunMode = #SCS_RUN_MODE_LINEAR
      
  EndSelect
  ProcedureReturn nRunMode
EndProcedure

Procedure.s decodeCasAction(nAction)
  PROCNAMEC()
  Protected sAction.s
  
  Select nAction
    Case #SCS_CAS_MIXER_UNPAUSE
      sAction = "SCS_CAS_MIXER_UNPAUSE"
    Case #SCS_CAS_MIXER_PAUSE
      sAction = "SCS_CAS_MIXER_PAUSE"
    Case #SCS_CAS_FADE_OUT
      sAction = "SCS_CAS_FADE_OUT"
    Case #SCS_CAS_MCI_STRING
      sAction = "SCS_CAS_MCI_STRING"
    Case #SCS_CAS_PLAY_VIDEO
      sAction = "SCS_CAS_PLAY_VIDEO"
    Case #SCS_CAS_PLAY_AUD
      sAction = "SCS_CAS_PLAY_AUD"
    Default
      sAction = Str(nAction)
  EndSelect
  ProcedureReturn sAction
EndProcedure

Procedure.s decodeVidPicTarget(nVidPicTarget)
  ; for debugging use only - language translation not required
  Protected sVidPicTarget.s
  
  Select nVidPicTarget
    Case #SCS_VID_PIC_TARGET_P
      sVidPicTarget = "P"
    Case #SCS_VID_PIC_TARGET_T
      sVidPicTarget = "T"
    Case #SCS_VID_PIC_TARGET_F2
      sVidPicTarget = "F2"
    Case #SCS_VID_PIC_TARGET_F3
      sVidPicTarget = "F3"
    Case #SCS_VID_PIC_TARGET_F4
      sVidPicTarget = "F4"
    Case #SCS_VID_PIC_TARGET_F5
      sVidPicTarget = "F5"
    Case #SCS_VID_PIC_TARGET_F6
      sVidPicTarget = "F6"
    Case #SCS_VID_PIC_TARGET_F7
      sVidPicTarget = "F7"
    Case #SCS_VID_PIC_TARGET_F8
      sVidPicTarget = "F8"
    Case #SCS_VID_PIC_TARGET_F9
      sVidPicTarget = "F9"
    Case #SCS_VID_PIC_TARGET_NONE
      sVidPicTarget = "None"
    Case #SCS_VID_PIC_TARGET_FRAME_CAPTURE
      sVidPicTarget = "FrameCapture"
    Case #SCS_VID_PIC_TARGET_TEST
      sVidPicTarget = "Test"
    Case #SCS_VID_PIC_TARGET_UNKNOWN
      sVidPicTarget = "Unknown"
    Default
      sVidPicTarget = Str(nVidPicTarget)
  EndSelect
  ProcedureReturn sVidPicTarget
EndProcedure

Procedure encodePeakMode(sPeakMode.s)
  PROCNAMEC()
  Protected nPeakMode
  Select sPeakMode
    Case "None"
      nPeakMode = #SCS_PEAK_NONE
    Case "Auto"
      nPeakMode = #SCS_PEAK_AUTO
    Default
      nPeakMode = #SCS_PEAK_HOLD
  EndSelect
  ProcedureReturn nPeakMode
EndProcedure

Procedure.s decodePeakMode(nPeakMode)
  Protected sPeakMode.s
  Select nPeakMode
    Case #SCS_PEAK_AUTO
      sPeakMode = "Auto"
    Case #SCS_PEAK_HOLD
      sPeakMode = "Hold"
    Case #SCS_PEAK_NONE
      sPeakMode = "None"
  EndSelect
  ProcedureReturn sPeakMode
EndProcedure

Procedure.s decodeSamplesArrayStatus(nSamplesArrayStatus)
  Protected sPMPStatus.s
  Select nSamplesArrayStatus
    Case #SCS_SAP_NONE
      sPMPStatus = "#SCS_SAP_NONE"
    Case #SCS_SAP_REQUESTED
      sPMPStatus = "#SCS_SAP_REQUESTED"
    Case #SCS_SAP_IN_PROGRESS
      sPMPStatus = "#SCS_SAP_IN_PROGRESS"
    Case #SCS_SAP_DONE
      sPMPStatus = "#SCS_SAP_DONE"
    Default
      sPMPStatus = Str(nSamplesArrayStatus)
  EndSelect
  ProcedureReturn sPMPStatus
EndProcedure

Procedure encodeVUBarWidth(sVUBarWidth.s)
  PROCNAMEC()
  Protected nVUBarWidth
  Select sVUBarWidth
    Case "Narrow"
      nVUBarWidth = #SCS_VUBARWIDTH_NARROW
    Case "Medium"
      nVUBarWidth = #SCS_VUBARWIDTH_MEDIUM
    Case "Wide"
      nVUBarWidth = #SCS_VUBARWIDTH_WIDE
  EndSelect
  ProcedureReturn nVUBarWidth
EndProcedure

Procedure.s decodeVUBarWidth(nVUBarWidth)
  Protected sVUBarWidth.s
  Select nVUBarWidth
    Case #SCS_VUBARWIDTH_NARROW
      sVUBarWidth = "Narrow"
    Case #SCS_VUBARWIDTH_MEDIUM
      sVUBarWidth = "Medium"
    Case #SCS_VUBARWIDTH_WIDE
      sVUBarWidth = "Wide"
  EndSelect
  ProcedureReturn sVUBarWidth
EndProcedure

Procedure encodeVideoPlaybackLibrary(sVideoPlaybackLibrary.s)
  Protected nVideoPlaybackLibrary
  Select sVideoPlaybackLibrary
    Case "Image"
      nVideoPlaybackLibrary = #SCS_VPL_IMAGE
    Case "TVG"
      nVideoPlaybackLibrary = #SCS_VPL_TVG
    Case "vMix"
      CompilerIf #c_vMix_in_video_cues
        nVideoPlaybackLibrary = #SCS_VPL_VMIX
      CompilerElse
        nVideoPlaybackLibrary = #SCS_VPL_TVG
      CompilerEndIf
    Default
      nVideoPlaybackLibrary = #SCS_VPL_NOT_SET
  EndSelect
  ProcedureReturn nVideoPlaybackLibrary
EndProcedure

Procedure.s decodeVideoPlaybackLibrary(nVideoPlaybackLibrary)
  Protected sVideoPlaybackLibrary.s
  Select nVideoPlaybackLibrary
    Case #SCS_VPL_IMAGE
      sVideoPlaybackLibrary = "Image"
    Case #SCS_VPL_TVG
      sVideoPlaybackLibrary = "TVG"
    Case #SCS_VPL_VMIX
      CompilerIf #c_vMix_in_video_cues
        sVideoPlaybackLibrary = "vMix"
      CompilerElse
        sVideoPlaybackLibrary = "TVG"
      CompilerEndIf
  EndSelect
  ProcedureReturn sVideoPlaybackLibrary
EndProcedure

Procedure.s decodeVideoPlaybackLibraryL(nVideoPlaybackLibrary)
  Protected sVideoPlaybackLibrary.s
  Select nVideoPlaybackLibrary
    Case #SCS_VPL_IMAGE
      sVideoPlaybackLibrary = "Image"
    Case #SCS_VPL_TVG
      sVideoPlaybackLibrary = "TVideoGrabber (TVG)"
    Case #SCS_VPL_VMIX
      CompilerIf #c_vMix_in_video_cues
        sVideoPlaybackLibrary = "vMix"
      CompilerElse
        sVideoPlaybackLibrary = "TVideoGrabber (TVG)"
      CompilerEndIf
  EndSelect
  ProcedureReturn sVideoPlaybackLibrary
EndProcedure

Procedure OptionRequester(XPos, YPos, sTitle.s, sButtons.s, nMaxButtonW=100, hImage=0, hHostWindow=0, sDontTellMeAgainText.s="", nMinButtonW=0, nSpecialAction=0, nWindowColor=#PB_Default, nTextColor=#PB_Default, nExtraWidth=0, nExtraHeight=0)
  ;- A GFA style Configurable MessageRequester()
  PROCNAMEC()
  ; ==========================================================================
  ; Function : An alternative to MessageRequester() that allows multiple user defined buttons 
  
  ; Displays title and optional instructions from Title$. Separate fields with '|'
  ; Displays a button for each of the options in Buttons$, use '|' separators 
  ; Returns index of button in string 'Buttons$', else... 
  ; Returns 0 if close window 'X' or ESC are pressed. 
  ; Returns negative number if PB failure detected.
  ; Saves the calling Window's number and re-instates window focus on exit. 
  ; Centres in User's Window/Screen if XPos and YPos are both zero. 
  ; Safe if no caller window. 
  ; Shows all of a long title even when the buttons are short. 
  ; Uses multi row buttons to allow more words
  ; Displays Icons or Images 
  
  ; Inputs   : 'X' and 'Y' position. Set both to 0 use Window or Screen centre
  ;            Title with optional extension to provide instructions. Use '|' separators
  ;            Button texts with '|' separators. Buttons can be multi-line.
  ;            Optional user specified maximum button width.
  ;            Optional user specified icon/image.
  
  ; Return   : Button index, base 1, else zero to indicate ESC etc.
  
  ; (c)R J Leman 2008, 2009.
  
  ; Licence: Do as you like. No warranty of any type. 
  ; ========================================================================
  
  ; Enable one of the following...
  ; ==============================
  ; QImage.l = 0
  
  ; QImage.l = LoadImage(#PB_Any,"C:\MEMSWORK\SLIDESHO\truck.bmp")
  ;  ResizeImage(QImage,200,150) ; Yes, can be a big image!
  
  ; QImage.l  = CreateImage(#PB_Any,100,75)
  ; StartDrawing(ImageOutput(QImage.l))
  ; FillArea(2,2,#Blue,#Red)  
  ; StopDrawing()
  
  ; #IDI_HAND             ;X - Stop sign icon
  ; #IDI_QUESTION         ;? - Question-mark icon
  ; #IDI_EXCLAMATION     ;! - Exclamation Point icon
  ; #IDI_ASTERISK         ;i - Letter "i" in a circle
  ; #IDI_WINLOGO         ;Windows Logo icon
  
  Static SponFont
  Protected KeepActiveWindow, HostWindow
  Protected NumPrompts, PromptHt, TitleW, WinW, WinH, WinFlag
  Protected NumButs, MaxPromptLen, ButHMax, SpaceWidth
  Protected MyWin, OR_Win
  Protected ImageX, ImageY, ImageW, ImageH, mImage
  Protected X, Y, k, l, m, n, w
  Protected sTmp.s, sText.s, sTooltip.s, sWord.s
  Protected LeftP, RightP, EndP, PixLineLen, PixWordWidth
  Protected But0X, ButY, ButW, ButHt, ButNum
  Protected chkItem1, chkItem2, chkDontTellMeAgain, ChkBoxHt
  Protected nEventGadget, nReqdWidth
  
  ; must be called from the main thread as the procedure uses OpenWindow() which PB says must be called from the main thread and will crash the program if it's not
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  gbInOptionRequester = #True ; Added 17Nov2023 11.10.0-b03
  
  debugMsg(sProcName, "sTitle=" + #DQUOTE$ + sTitle + #DQUOTE$)
  
  If getWindowVisible(#WMI)
    ; the 'information' window may be being displayed if OptionRequester() is called during the opening of a cue file, etc (by fmLoadProd())
    WMI_Form_Unload()
  EndIf
  
  ; Save the number of the calling window.
  ; hHostWindow added 1Jul2016 11.5.1
  If IsWindow(hHostWindow)
    KeepActiveWindow = hHostWindow
  Else
    KeepActiveWindow = GetActiveWindow()  ; -1 If None
  EndIf
  
  HostWindow = KeepActiveWindow
  Select HostWindow
    Case #WMN, #WSP, #WED, #WVP, #WOP
      ; continue
    Default
      If IsWindow(#WMN)
        HostWindow = #WMN
      ElseIf IsWindow(#WSP)
        HostWindow = #WSP
      EndIf
  EndSelect
  
  ; Specify the font to be used.
  If SponFont = 0
    ; SponFont = LoadFont(#PB_Any,"system fixed",10)
    SponFont = #SCS_FONT_GEN_NORMAL10                       ; modified for SCS
  EndIf
  
  ; Find the number of fields in the title 
  ; Example: Title|Prompt1|Prompt2|Prompt3
  NumPrompts = CountString(sTitle, "|")
  
  ; Include Icon/Image 
  ImageX = 0 ; Defaults...
  ImageY = 0
  ImageW = 0
  ImageH = 0
  
  ; If an Image is specified...
  If hImage
    
    ; If image ID is in range of Windows Icon Handles...
    ; get the Icon and draw it in an image
    If (hImage >= #IDI_APPLICATION) And (hImage <= #IDI_WINLOGO)
      mImage  = CreateImage(#PB_Any,32,32)
      logCreateImage(10, hImage)
      StartDrawing(ImageOutput(mImage))
      ; FillArea(2,2,#Blue,GetSysColor_(#COLOR_MENU))
      ; FillArea(2,2,#SCS_Blue,GetSysColor_(#COLOR_MENU)) ; modified for SCS (changed #Blue to #SCS_Blue)
      FillArea(2,2,#SCS_Blue,$F0F0F0) ; changed 7Aug2023 as #COLOR_MENU is apparently not supported in Windows 10 and greater
      DrawImage(LoadIcon_(0, hImage),0,0,32,32)  
      StopDrawing()
      hImage = mImage
    EndIf
    
    ImageX = 5
    ImageY = 5
    ImageH = ImageHeight(hImage)
    ImageW = ImageWidth(hImage)
    
  EndIf
  
  ; Find number of buttons and width of widest. 
  ; Also, find the button height to allow multi word prompts. (Must have spaces between words.) 
  NumButs = CountString(sButtons, "|") + 1                    ; Count fields 
;   ButW  = 0                                                   ; Init button width 
  ButW  = nMinButtonW                                         ; Init button width 
  ButHt = 1                                                   ; One row of text
  MaxPromptLen = 0
  ChkBoxHt = 17
  
  MyWin = OpenWindow(#PB_Any,1,1,1,1,"",#PB_Window_Invisible) ; Needed for TextWidth() to work 
  If MyWin 
    
    If StartDrawing(WindowOutput(MyWin)) 
      ; Find button height for multi rows of text        
      DrawingFont(FontID(SponFont))
      ButHMax = 1                                           ; Default to one row of characters on the button
      SpaceWidth = TextWidth("    ")/4
      For n = 1 To NumButs                                  ; For each button... 
        
        ;- Find how many ROWS are needed for this button... 
        sTmp = Trim(StringField(sButtons, n, "|"))          ; Extract a button's text
        sText = Trim(StringField(sTmp, 1, "~"))
        sTooltip = Trim(StringField(sTmp, 2, "~"))
        ButHt  = 1                                          ; There must be a first row.
        LeftP  = 1                                          ; Start at beginning of button text...
        EndP   = Len(sText)                                 ; Character length of button text
        PixLineLen = 0
        m = 0                                               ; Width of widest row of text, so far.
        Repeat                                              ; For each word in the button prompt
          
          RightP   = FindString(sText," ",LeftP)            ; Find position of end of word as defined by following space
          If RightP  = 0                                    ; No position found,
            RightP = EndP + 1                               ; so end of word is end of string.
          EndIf
          
          sWord = Mid(sText, LeftP, RightP - LeftP)         ; Isolate the word
          PixWordWidth = TextWidth(sWord ) + SpaceWidth   ; Find pixel length + allowance for space
          
          If PixLineLen + PixWordWidth > nMaxButtonW-10        ; If adding next word would overflow the button width...
            ButHt + 1                                         ; add another row.
            PixLineLen = PixWordWidth + SpaceWidth          ; Start next row with width of word that would have bust previous row.
            
          Else
            PixLineLen + PixWordWidth                         ; Add word width onto button width
            PixLineLen + SpaceWidth                           ; and a space.       
          EndIf
          ; Keep the widest row.
          If PixLineLen > m
            m = PixLineLen
          EndIf
          
          LeftP = RightP + 1
        Until LeftP >= EndP
        
        ;- Keep largest number of rows
        If ButHt > ButHMax
          ButHMax = ButHt
        EndIf
        
        ;- Force a minimum button width
        If m < 10                                            
          m = 10                   
        EndIf 
        
        ;- Keep largest button width 
        If m > ButW                                       ; Keep widest button. 
          ; ButW = m + 10
          ButW = m + 20
        EndIf 
        ; Debug "sWord=" + sWord + ", m=" + m + ", ButW=" + ButW
        
      Next n
      ; Find width of widest prompt... if any.
      If NumPrompts
        For n = 2 To NumPrompts + 1
          sTmp = StringField(sTitle, n, "|")
          m = TextWidth(sTmp)
          If nSpecialAction = 1
            m + 20
          EndIf
          If m > MaxPromptLen
            MaxPromptLen = m
          EndIf
        Next
      EndIf
      
      PromptHt = TextHeight("Ay")
      ; Debug "PromptHt=" + PromptHt
      If PromptHt > ChkBoxHt
        ChkBoxHt = PromptHt
      EndIf
      TitleW   = TextWidth(StringField(sTitle, 1, "|")) 
      TitleW + (TitleW >> 4) + 36 ; Need to find how to get this properly... bold font?
      StopDrawing() 
    Else
      gbInOptionRequester = #False ; Added 17Nov2023 11.10.0-b03
      ProcedureReturn (-2) ; Graphic error, cannot start drawing
    EndIf 
    CloseWindow(MyWin) 
    
  Else 
    gbInOptionRequester = #False ; Added 17Nov2023 11.10.0-b03
    ProcedureReturn -1     ; Graphic error, cannot open window
  EndIf 
  
  ButHMax * PromptHt 
  ButHMax + 8 
  
  ;- Calculate window width
  w = (NumButs * ButW) + ((NumButs - 1) * 5) ; Width of buttons + spaces
  WinW = w  
  
  ; Correct window width if required for long title
  If TitleW > WinW
    WinW = TitleW
  EndIf
  
  ; If image plus prompts are wider than window then increase width
  If (ImageW + MaxPromptLen) > WinW
    WinW = ImageW + MaxPromptLen
  EndIf
  
  ; If image and prompt both exist then we need an extra margin
  If ImageW And  MaxPromptLen
    WinW + 5
  EndIf
  
  ; Always a margin left and right
  WinW + 5 + 5 + nExtraWidth
  
  ;- Calculate position of left button
  But0X = (WinW - w)/2 
  
  ;- Calculate window height and Y position for buttons 
  ; Number of prompt rows * text height
  WinH = (NumPrompts  * PromptHt)  
  If sDontTellMeAgainText
    WinH + PromptHt + ChkBoxHt
  EndIf
  ButY = 5 
  
  ; If image is higher than prompts then use larger of the two
  If ImageH > WinH
    WinH = ImageH
  EndIf
  
  ; If image or prompts exist then we need an extra margin
  ; and buttons move down
  If WinH
    WinH + 5
    ButY + WinH 
  EndIf
  
  If ButHMax < gnBtnHeight
    ButHMax = gnBtnHeight
  EndIf
  
  ; Add height of buttons plus margin to window height
  WinH + 5 + ButHMax + 5 + nExtraHeight
  
  ;{- Open window for user input 
  ; Work out co-ords of visible Window 
  WinFlag = #PB_Window_TitleBar ; | #PB_Window_SystemMenu
  
  If gbInLoadCueFile
    WinFlag | #PB_Window_ScreenCentered
    OR_Win = OpenWindow(#PB_Any, XPos, YPos, WinW, WinH, StringField(sTitle, 1, "|"), WinFlag)
    ; debugMsg(sProcName, "(a) WinFlag=" + WinFlag + ", XPos=" + XPos + ", YPos=" + Ypos + ", WinW=" + WinW + ", WinH=" + WinH)
    
  ElseIf (XPos = 0) And (YPos = 0) And (IsWindow(HostWindow))   ; If no position and called from a window...
    WinFlag | #PB_Window_WindowCentered                         ; centre in host window
    ; OR_Win = OpenWindow(#PB_Any, XPos, YPos, WinW, WinH, StringField(sTitle, 1, "|"), WinFlag, WindowID(HostWindow))
    ; debugMsg0(sProcName, "(b) WinFlag=" + WinFlag + ", XPos=" + XPos + ", YPos=" + Ypos + ", WinW=" + WinW + ", WinH=" + WinH + ", HostWindow=" + decodeWindow(HostWindow))
    ; Changed 15Oct2020 11.8.3.2br following bug report and emails from Keith Jewell - seems WindowCentered doesn't always work, so procedure scsOpenWindow was added to properly handle #PB_Window_WindowCentered.
    OR_Win = scsOpenWindow(#PB_Any, XPos, YPos, WinW, WinH, StringField(sTitle, 1, "|"), WinFlag, HostWindow) ; nb scsOpenWindow() requires last parameter to be HostWindow, not WindowID(HostWindow)
    ; debugMsg(sProcName, "(b) WinFlag=" + WinFlag + ", XPos=" + XPos + ", YPos=" + Ypos + ", WinW=" + WinW + ", WinH=" + WinH + ", HostWindow=" + decodeWindow(HostWindow))
    
  ElseIf (HostWindow <> -1)
    OR_Win = OpenWindow(#PB_Any, XPos, YPos, WinW, WinH, StringField(sTitle, 1, "|"), WinFlag)
    ; debugMsg(sProcName, "(c) WinFlag=" + WinFlag + ", XPos=" + XPos + ", YPos=" + Ypos + ", WinW=" + WinW + ", WinH=" + WinH)
    
  Else
    WinFlag | #PB_Window_ScreenCentered
    OR_Win = OpenWindow(#PB_Any, XPos, YPos, WinW, WinH, StringField(sTitle, 1, "|"), WinFlag)
    ; debugMsg(sProcName, "(d) WinFlag=" + WinFlag + ", XPos=" + XPos + ", YPos=" + Ypos + ", WinW=" + WinW + ", WinH=" + WinH)
    
  EndIf
  
  If OR_Win = 0
    gbInOptionRequester = #False ; Added 17Nov2023 11.10.0-b03
    ProcedureReturn -3
  EndIf 
  
  StickyWindow(OR_Win,1)                                      ; Stay on top
  AddKeyboardShortcut(OR_Win, #PB_Shortcut_Escape, 100)       ; ESC hotkey for exit 
  AddKeyboardShortcut(OR_Win, #PB_Shortcut_Return, 101)       ; Return hotkey for exit
  If nWindowColor <> #PB_Default
    SetWindowColor(OR_Win, nWindowColor)
  EndIf
  ;}
  ;- Draw optional Image
  If hImage                                                   ; If Image was specified,
    If NumPrompts = 0                                         ; and no prompts specified
      ImageX = (WinW - ImageW) / 2                            ; X position for image is in centre of window
    EndIf
    ImageGadget(#PB_Any,ImageX,ImageY,0,0,ImageID(hImage))    ; Put image in window
  EndIf
  
  ;{- Draw prompts 
  X = 5 + (nExtraWidth / 2)                                   ; Left offset of prompt
  If ImageW                                                   ; If an image is present...
    X + ImageW + 5                                            ; Prompts start to it's right, plus and extraf margin
  EndIf
  
  Y = 5                                                       ; Vertical position of first prompt
  For n = 2 To NumPrompts + 1
    If n = 2 And nSpecialAction = 1
      chkItem1 = CheckBoxGadget(#PB_Any, X, Y, WinW-10, ChkBoxHt, StringField(sTitle,n,"|"))
      SetGadgetFont(chkItem1, FontID(SponFont))
      Y + ChkBoxHt
    ElseIf n = 3 And nSpecialAction = 1
      Y + 4
      chkItem2 = CheckBoxGadget(#PB_Any, X, Y, WinW-10, ChkBoxHt, StringField(sTitle,n,"|"))
      SetGadgetFont(chkItem2, FontID(SponFont))
      Y + ChkBoxHt
    Else
      l = TextGadget(#PB_Any, X, Y, WinW-10, PromptHt, StringField(sTitle,n,"|"))
      SetGadgetFont(l, FontID(SponFont))
      If nWindowColor <> #PB_Default
        SetGadgetColor(l, #PB_Gadget_BackColor, nWindowColor)
      EndIf
      If nTextColor <> #PB_Default
        SetGadgetColor(l, #PB_Gadget_FrontColor, nTextColor)
      EndIf
      Y + PromptHt
    EndIf
  Next
  ;}
  
  If sDontTellMeAgainText
    If nSpecialAction = 1
      Y + 5
    Else
      Y + PromptHt
    EndIf
    chkDontTellMeAgain = CheckBoxGadget(#PB_Any, X, Y, WinW-10, ChkBoxHt, sDontTellMeAgainText)
    SetGadgetFont(chkDontTellMeAgain, FontID(SponFont))
    nReqdWidth = GadgetWidth(chkDontTellMeAgain, #PB_Gadget_RequiredSize)
    X = (WinW - nReqdWidth) / 2
    ResizeGadget(chkDontTellMeAgain, X, #PB_Ignore, nReqdWidth, #PB_Ignore)
    Y + ChkBoxHt + 5
  EndIf
  
  ;{- Draw buttons   
  ; Calculate Y position of buttons
  If hImage                                                   ; If Image used
    If Y < (ImageY + ImageH)                                  ; and Image is larger than the text...
      Y = ImageY + ImageH   
    EndIf
    Y + 5
  EndIf
  
  If Y > ButY
    ButY = Y
  EndIf
  
  ResizeWindow(OR_Win, #PB_Ignore, #PB_Ignore, #PB_Ignore, (ButY+ButHMax+8+nExtraHeight))
  
  ButY + (nExtraHeight / 2)
  
  X = But0X                                                   ; X Offset of first button 
  ButNum = #SCS_OR_BUTTON_BASE
  For n = 1 To NumButs                                        ; For each button... 
    sTmp = StringField(sButtons, n, "|")
    sText = StringField(sTmp, 1, "~")
    sTooltip = StringField(sTmp, 2, "~")
    If sText="" : sText=" " : EndIf                                 ; Swap null string to a space
    ; debugMsg(sProcName, "sButtons=" + sButtons + ", sTmp=" + sTmp + ", + sText=" + sText + ", sTooltip=" + sTooltip)
    ButtonGadget(ButNum,X,ButY,ButW,ButHMax,sText,#PB_Button_MultiLine); draw it... 
    If sTooltip
      scsToolTip(ButNum, sTooltip)
    EndIf
    SetGadgetFont(ButNum,FontID(SponFont))
    ButNum + 1
    X + ButW + 5                                              ; Adjust left margin 
  Next n
  SetActiveGadget(#SCS_OR_BUTTON_BASE) 
  
  ; added 1Jul2016 11.5.1
  ; seems to need this or OR_Win may not be initially visible, even though we have already made it sticky
  ; encountered the issue when testing drag-and-drop of audio files into the editor
  SAW(HostWindow) 
  ; end of added 1July2016 11.5.1
  
  ; Added 4Nov2021 11.8.6bq following test of WMN_CheckOkToGoToCue() where focus was still on the main window
  Delay(100)
  SAW(OR_Win)
  ; End added 4Nov2021 11.8.6bq
  
  ; While WindowEvent() : Wend                                  ; Ensure refresh  ; deleted 1Jul2016 11.5.1 - seems superfluous
  ;}
  ;{- Local event manager 
  Repeat                                                      ; Start... 
    Select WaitWindowEvent() 
        
      Case #PB_Event_CloseWindow        
        If EventWindow() = OR_Win 
          k = 0
          Break 
        EndIf 
        
      Case #PB_Event_Menu 
        Select EventMenu() 
          Case 100                                            ; ESC key 
            k = 0
            Break 
            
          Case 101                                            ; Return key 
            k = GetActiveGadget() - #SCS_OR_BUTTON_BASE + 1
            Break 
            
        EndSelect 
        
      Case #PB_Event_Gadget 
        nEventGadget = EventGadget()
        If (nEventGadget = chkItem1) And (IsGadget(chkItem1))
          If IsGadget(chkItem2)
            If GetGadgetState(chkItem1) = #PB_Checkbox_Checked
              SetGadgetState(chkItem2, #PB_Checkbox_Unchecked)
            EndIf
          EndIf
        ElseIf (nEventGadget = chkItem2) And (IsGadget(chkItem2))
          If IsGadget(chkItem1)
            If GetGadgetState(chkItem2) = #PB_Checkbox_Checked
              SetGadgetState(chkItem1, #PB_Checkbox_Unchecked)
            EndIf
          EndIf
        Else
          k = EventGadget() - #SCS_OR_BUTTON_BASE + 1   ; Return button index (base 1)
          If (k > 0) And (k =< NumButs)
            Break 
          EndIf
        EndIf
        
    EndSelect 
  ForEver 
  ;}
  ;{- Return focus to calling window 
  If (KeepActiveWindow > 0)
    SAW(KeepActiveWindow)
  EndIf 
  ;}
  ; Close Window 
  RemoveKeyboardShortcut(OR_Win,#PB_Shortcut_All)       ; Kill hotkeys
  
  If k > 0
    If (sDontTellMeAgainText) And (IsGadget(chkDontTellMeAgain))
      If GetGadgetState(chkDontTellMeAgain) = #PB_Checkbox_Checked
        k | $10000
      EndIf
    EndIf
    If nSpecialAction = 1
      If IsGadget(chkItem1)
        If GetGadgetState(chkItem1) = #PB_Checkbox_Checked
          k | $100000
        EndIf
      EndIf
      If IsGadget(chkItem2)
        If GetGadgetState(chkItem2) = #PB_Checkbox_Checked
          k | $200000
        EndIf
      EndIf
    EndIf
  EndIf
  
  CloseWindow(OR_Win)
  
  gbInOptionRequester = #False ; Added 17Nov2023 11.10.0-b03
  ProcedureReturn k                                   ; Cancel / Key index or negative for internal error
;  EnableExplicit  ; reinstate EnableExplicit !!!!!!!!!!!!!!!!!!
EndProcedure 

Procedure.s createWrapTextForOptionRequester(nMaxLineLength, sText.s)
  PROCNAMEC()
  Protected sWrapText.s, sWorkText.s, sLine.s, sHoldLine.s, nWordCount, n
  Static nTextImage
  
  ; debugMsg(sProcName, #SCS_START + ", nMaxLineLength=" + nMaxLineLength + ", sText=" + #DQUOTE$ + sText + #DQUOTE$)
  
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  
  If IsImage(nTextImage)
    If StartDrawing(ImageOutput(nTextImage))
      DrawingFont(FontID(#SCS_FONT_GEN_NORMAL)) ; font used by OptionRequester()
      sWorkText = sText
      nWordCount = CountString(sWorkText, " ")
      n = 1
      While n <= nWordCount
        sLine = StringField(sWorkText, n, " ")
        sHoldLine = sLine
        While TextWidth(sLine) <= nMaxLineLength
          sHoldLine = sLine
          n + 1
          sLine + " " + StringField(sWorkText, n, " ")
        Wend
        ; debugMsg(sProcName, "TextWidth(sHoldLine)=" + TextWidth(sHoldLine) + ", sHoldLine=" + #DQUOTE$ + sHoldLine + #DQUOTE$)
        sWrapText + sHoldLine
        If n < nWordCount
          sWrapText + "|"
        EndIf
      Wend
      StopDrawing()
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", sWrapText=" + #DQUOTE$ + sWrapText + #DQUOTE$)
  ProcedureReturn sWrapText
  
EndProcedure

Procedure applyValidChars(nGadgetNo, sValidChars.s)
  PROCNAMEC()
  Protected sGadgetText.s, sNewString.s
  Protected n, nKeepIt
  Protected hStringGadget.l, nCaretPos.l   ; longs
  
  sGadgetText = GetGadgetText(nGadgetNo)
  hStringGadget = GadgetID(nGadgetNo)
  For n = 1 To Len(sGadgetText)
    ; see if all characters in the string gadget are valid
    nKeepIt = FindString(sValidChars, Mid(sGadgetText,n,1), 1)
    If nKeepIt = 0
      ; invalid character found
      ; get current cursor position
      SendMessage_(hStringGadget, #EM_GETSEL, @nCaretPos, 0)
      ; remove invalid character
      sNewString = RemoveString(sGadgetText, Mid(sGadgetText,n,1), 0, 1, 1)
      SetGadgetText(nGadgetNo, sNewString)
      ; set cursor position to last position after setting sNewString
      If nCaretPos > 0
        nCaretPos - 1
      EndIf
      SendMessage_(hStringGadget, #EM_SETSEL, nCaretPos, nCaretPos)
    EndIf
  Next n
  
EndProcedure

Procedure.s removeInvalidChars(sCurrString.s, sValidChars.s)
  PROCNAMEC()
  Protected sNewString.s
  Protected n
  
  For n = 1 To Len(sCurrString)
    If FindString(sValidChars, Mid(sCurrString,n,1), 1)
      sNewString + Mid(sCurrString,n,1)
    EndIf
  Next n
  
  ProcedureReturn sNewString
  
EndProcedure

Procedure.s removeLF(sOldString.s)
  ; see also macro GLT()
  ProcedureReturn Trim(ReplaceString(sOldString, Chr(10), " "))
EndProcedure

Procedure.s RemoveMultiSpace(sText.s)
  ; obtained from PB Forum topic "Strip/replace double or multiple spaces with single", but changed and simplified (changed because the original procedure didn't handle sText without any spaces!)
  Protected sText2.s, sTemp.s
  Protected iCnt.i, iSub.i, iTotal.i
  Protected nFieldNo
  
  sText2 = LTrim(sText)
  iSub = 1
  iTotal = CountString(sText2, Chr(32)) + 1
  Dim sSub.s(iTotal)
  
  ; Debug "iTotal=" + iTotal
  For nFieldNo = 1 To iTotal
    sTemp = Trim(StringField(sText2, nFieldNo, Chr(32)))
    ; Debug "sTemp=" + sTemp
    If Len(sTemp) > 0
      sSub(iSub) = sTemp
      iSub = iSub + 1
    EndIf
  Next nFieldNo
  sText2 = ""
  For iCnt = 1 To iTotal
    sText2 + sSub(iCnt) + Chr(32)
  Next iCnt
  
  ProcedureReturn(Trim(sText2))
  
EndProcedure

Procedure.s removeDigits(sText.s)
  PROCNAMEC()
  Static nRegExp
  
  If IsRegularExpression(nRegExp) = #False
    nRegExp = CreateRegularExpression(#PB_Any, "[0-9]")
  EndIf
  ProcedureReturn ReplaceRegularExpression(nRegExp, sText, "")
  
EndProcedure

Procedure.s removeNonPrintingChars(sText.s, bAllowCR=#False)
  ; Also removes extended ASCII characters
  ; PROCNAMEC()
  Protected sNewText.s, sChar.s
  Protected nTextLength, n
  
  nTextLength = Len(sText)
  For n = 1 To nTextLength
    sChar = Mid(sText, n, 1)
    If Asc(sChar) > 127
      ; Ignore extended ASCII
      Continue
    EndIf
    If (Asc(sChar) >= 32) And (Asc(sChar) <> 127) ; 32 = space, 127 = del
      sNewText + sChar
    ElseIf (bAllowCR) And (sChar = #CR$)
      sNewText + sChar
    EndIf
  Next n
  ProcedureReturn Trim(sNewText)
EndProcedure

Procedure.s removeNoiseChars(sText.s, sConvertCharToCR.s="")
  ; PROCNAMEC()
  Protected sOldText.s
  Protected sNewText.s
  Protected nQuoteCount, nFieldCount, nFieldNr
  Protected sField.s
  
  ; debugMsg(sProcName, #SCS_START + ", sText=" + #DQUOTE$ + sText + #DQUOTE$ + ", sConvertCharToCR=" + #DQUOTE$ + sConvertCharToCR + #DQUOTE$)
  
  sOldText = Trim(sText)
  nQuoteCount = CountString(sOldText, #DQUOTE$)
  If nQuoteCount > 0
    If nQuoteCount & 1
      ; Debug "odd number of quotes"
      nFieldCount = ((nQuoteCount + 1) >> 1)
    Else
      ; Debug "even number of quotes"
      nFieldCount = (nQuoteCount >> 1)
    EndIf
    nFieldCount << 1
    nFieldCount + 1
  Else
    nFieldCount = 1
  EndIf
  ; Debug "nFieldCount=" + nFieldCount
  
  For nFieldNr = 1 To nFieldCount
    sField = StringField(sOldText, nFieldNr, #DQUOTE$)
    ; Debug "nFieldNr=" + nFieldNr + ", sField=" + sField
    If nFieldNr & 1
      ; Debug "odd numbered field, so not within quotes"
      If sConvertCharToCR
        sField = ReplaceString(sField, sConvertCharToCR, #CR$)
        ; Debug "sField=" + sField
      EndIf
      sNewText + removeNonPrintingChars(sField, #True)
    Else
      ; Debug "even numbered field, so within quotes"
      sNewText + #DQUOTE$ + Trim(sField) + #DQUOTE$
    EndIf
  Next nFieldNr
  
  ProcedureReturn sNewText
  
EndProcedure

Procedure checkValidChars(sCurrString.s, sValidChars.s)
  PROCNAMEC()
  Protected n
  
  For n = 1 To Len(sCurrString)
    If FindString(sValidChars, Mid(sCurrString,n,1)) = 0
      ProcedureReturn #False  ; found an invalid char
    EndIf
  Next n
  ProcedureReturn #True ; all chars valid
  
EndProcedure

Procedure applyUpperCase(nGadgetNo)
  PROCNAMEC()
  Protected sGadgetText.s, sNewString.s
  Protected hStringGadget.l, nCaretPos.l   ; longs
  
  sGadgetText = GetGadgetText(nGadgetNo)
  sNewString = UCase(sGadgetText)
  If sNewString <> sGadgetText
    hStringGadget = GadgetID(nGadgetNo)
    ; get current cursor position
    SendMessage_(hStringGadget, #EM_GETSEL, @nCaretPos, 0)
    SetGadgetText(nGadgetNo, sNewString)
    ; set cursor position to last position after setting sNewString
    SendMessage_(hStringGadget, #EM_SETSEL, nCaretPos, nCaretPos)
  EndIf
  
EndProcedure

Procedure.s decodeStdBtnType(nButtonType)
  Protected sButtonType.s
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_REWIND
      sButtonType = "REWIND"
    Case #SCS_STANDARD_BTN_PLAY
      sButtonType = "PLAY"
    Case #SCS_STANDARD_BTN_PAUSE
      sButtonType = "PAUSE"
    Case #SCS_STANDARD_BTN_RELEASE
      sButtonType = "RELEASE"
    Case #SCS_STANDARD_BTN_FADEOUT
      sButtonType = "FADEOUT"
    Case #SCS_STANDARD_BTN_STOP
      sButtonType = "STOP"
    Case #SCS_STANDARD_BTN_SHUFFLE
      sButtonType = "SHUFFLE"
    Case #SCS_STANDARD_BTN_MOVE_UP
      sButtonType = "MOVE_UP"
    Case #SCS_STANDARD_BTN_MOVE_DOWN
      sButtonType = "MOVE_DOWN"
    Case #SCS_STANDARD_BTN_MOVE_LEFT
      sButtonType = "MOVE_LEFT"
    Case #SCS_STANDARD_BTN_MOVE_RIGHT
      sButtonType = "MOVE_RIGHT"
    Case #SCS_STANDARD_BTN_MOVE_RIGHT_UP
      sButtonType = "MOVE_RIGHT_UP"
    Case #SCS_STANDARD_BTN_EXPAND_ALL
      sButtonType = "EXPAND_ALL"
    Case #SCS_STANDARD_BTN_COLLAPSE_ALL
      sButtonType = "COLLAPSE_ALL"
    Case #SCS_STANDARD_BTN_CUT
      sButtonType = "CUT"
    Case #SCS_STANDARD_BTN_COPY
      sButtonType = "COPY"
    Case #SCS_STANDARD_BTN_PASTE
      sButtonType = "PASTE"
    Case #SCS_STANDARD_BTN_DELETE
      sButtonType = "DELETE"
    Case #SCS_STANDARD_BTN_PLUS
      sButtonType = "PLUS"
    Case #SCS_STANDARD_BTN_MINUS
      sButtonType = "MINUS"
    Case #SCS_STANDARD_BTN_FIRST
      sButtonType = "FIRST"
    Case #SCS_STANDARD_BTN_LAST
      sButtonType = "LAST"
    Case #SCS_STANDARD_BTN_PREV
      sButtonType = "PREV"
    Case #SCS_STANDARD_BTN_NEXT
      sButtonType = "NEXT"
    Case #SCS_STANDARD_BTN_TICK
      sButtonType = "TICK"
    Case #SCS_STANDARD_BTN_CROSS
      sButtonType = "CROSS"
    Default
      sButtonType = Str(nButtonType)
  EndSelect

  ProcedureReturn sButtonType
EndProcedure

Procedure.s decodeStringFormat(nStringFormat)
  Protected sStringFormat.s
  
  Select nStringFormat
    Case #PB_Ascii
      sStringFormat = "#PB_Ascii"
    Case #PB_UTF8
      sStringFormat = "#PB_UTF8"
    Case #PB_Unicode
      sStringFormat = "#PB_Unicode"
    Case #PB_UTF16BE
      sStringFormat = "#PB_UTF16BE"
    Case #PB_UTF32
      sStringFormat = "#PB_UTF32"
    Case #PB_UTF32BE
      sStringFormat = "#PB_UTF32BE"
    Default
      sStringFormat = Str(nStringFormat)
  EndSelect
  ProcedureReturn sStringFormat
  
EndProcedure

Procedure.s decodeAspectRatioValue(nAspectRatioValue)
  Protected sAspectRatioValue.s
  
  Select nAspectRatioValue
    Case #SCS_AR_16_9 ; 1609
      sAspectRatioValue = "16:9"
    Case #SCS_AR_4_3  ; 403
      sAspectRatioValue = "4:3"
    Case #SCS_AR_185_1
      sAspectRatioValue = "1.85:1"
    Case #SCS_AR_235_1
      sAspectRatioValue = "2.35:1"
    Default  ; other aspect ratio, or user is not sure
      sAspectRatioValue = ""
  EndSelect
  ProcedureReturn sAspectRatioValue
EndProcedure

Procedure encodeAspectRatioValue(sAspectRatioValue.s)
  Protected nAspectRatioValue
  
  Select sAspectRatioValue
    Case "16:9", "16x9"
      nAspectRatioValue = #SCS_AR_16_9 ; 1609
    Case "4:3", "4x3"
      nAspectRatioValue = #SCS_AR_4_3 ; 403
    Case "1.85:1"
      nAspectRatioValue = #SCS_AR_185_1
    Case "2.35:1"
      nAspectRatioValue = #SCS_AR_235_1
    Case ""  ; other aspect ratio, or user is not sure
      nAspectRatioValue = 0
  EndSelect
  ProcedureReturn nAspectRatioValue
EndProcedure

Procedure.s decodeAspectRatioType(nAspectRatioType)
  Protected sAspectRatioType.s
  
  Select nAspectRatioType
    Case #SCS_ART_ORIGINAL
      sAspectRatioType = "Original"
    Case #SCS_ART_FULL
      sAspectRatioType = "Full"
    Case #SCS_ART_16_9
      sAspectRatioType = "16:9"
    Case #SCS_ART_4_3
      sAspectRatioType = "4:3"
    Case #SCS_ART_185_1
      sAspectRatioType = "1.85:1"
    Case #SCS_ART_235_1
      sAspectRatioType = "2.35:1"
    Case #SCS_ART_CUSTOM
      sAspectRatioType = "Custom"
  EndSelect
  ProcedureReturn sAspectRatioType
EndProcedure

Procedure encodeAspectRatioType(sAspectRatioType.s)
  Protected nAspectRatioType
  
  Select sAspectRatioType
    Case "Original", "Image"
      nAspectRatioType = #SCS_ART_ORIGINAL
    Case "Full"
      nAspectRatioType = #SCS_ART_FULL
    Case "16:9"
      nAspectRatioType = #SCS_ART_16_9
    Case "4:3"
      nAspectRatioType = #SCS_ART_4_3
    Case "1.85:1"
      nAspectRatioType = #SCS_ART_185_1
    Case "2.35:1"
      nAspectRatioType = #SCS_ART_235_1
    Case "Custom"
      nAspectRatioType = #SCS_ART_CUSTOM
  EndSelect
  ProcedureReturn nAspectRatioType
EndProcedure

Procedure.s getLeafName(sFolderName.s)
  Protected sLeafName.s, sWork.s
  Protected nPartCount, sSeparator.s
  
  sWork = Trim(sFolderName)
  sSeparator = "\"
  nPartCount = CountString(sWork, sSeparator)
  If nPartCount = 0
    sSeparator = "/"
    nPartCount = CountString(sWork, sSeparator)
  EndIf
  If nPartCount > 0
    If Right(sWork,1) = sSeparator
      sLeafName = StringField(sWork, nPartCount, sSeparator)
    Else
      sLeafName = StringField(sWork, nPartCount+1, sSeparator)
    EndIf
    sLeafName + sSeparator
  Else
    sLeafName = sWork
  EndIf
  Debug "sFolderName=" + sFolderName
  Debug "sLeafName=" + sLeafName
  ProcedureReturn sLeafName
EndProcedure

Procedure allowWindowToRefresh(qTime.q)
  PROCNAMEC()
  ; this procedure was written to allow a window to refresh while waiting for a process to end.
  ; it was originally written for the SMS Connection screen while wating for the 'retry' to test the SMS connection.
  ; without this procedure being called, the mouse cursor would not go to 'busy' and the gadgets would not change to 'disabled'.
  ; warning: qTime should be the minimum necessary for the required effect as this procedure will throw away window events.
  ; in initial testing, the events thrown away were: repaint, mouse move, mouse leave, and WM_TIMER
  Protected qWaitUntil, nWindowEvent, nTimeLeft
  
  qWaitUntil = ElapsedMilliseconds() + qTime
  nWindowEvent = WaitWindowEvent(qTime)
  ; debugMsg(sProcName, "nWindowEvent=" + decodeEvent(nWindowEvent))
  ; While ElapsedMilliseconds() < qWaitUntil
  nTimeLeft = qWaitUntil - ElapsedMilliseconds()
  While nTimeLeft > 0
    nTimeLeft = qWaitUntil - ElapsedMilliseconds()
    nWindowEvent = WaitWindowEvent(nTimeLeft)
    ; debugMsg(sProcName, "nWindowEvent=" + decodeEvent(nWindowEvent))
  Wend
  
EndProcedure

Procedure HighlightTreeviewItem(nGadgetNo, nNodeID, nHighlightFlag)
  ; code supplied by Shardik in PB Forum Topic "Treeview color", 28 Feb 2012
  PROCNAMEC()
  Protected nItemHandle
  Protected TVHitTest.TV_HITTESTINFO
  Protected TVItem.TV_ITEM
  
  If nNodeID >= 0
    nItemHandle = GadgetItemID(nGadgetNo, nNodeID)
    
    If nItemHandle <> 0
      If TVHitTest\flags <> #TVHT_ONITEMBUTTON
        TVItem\Mask = #TVIF_STATE
        TVItem\hItem = nItemHandle
        
        If nHighlightFlag = #True
          TVItem\StateMask = #TVIS_DROPHILITED
          TVItem\State = #TVIS_DROPHILITED
        Else
          TVItem\StateMask = #TVIS_DROPHILITED
          TVItem\State = 0
        EndIf
        
        SendMessage_(GadgetID(nGadgetNo), #TVM_SETITEM, 0, @TVItem)
        
        RedrawWindow_(GadgetID(nGadgetNo), 0, 0, #RDW_UPDATENOW)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure isCursorOnGadget(nGadgetNo)
  If (DesktopMouseX() >= GadgetX(nGadgetNo,#PB_Gadget_ScreenCoordinate)) And (DesktopMouseX() < GadgetX(nGadgetNo,#PB_Gadget_ScreenCoordinate) + GadgetWidth(nGadgetNo))
    If (DesktopMouseY() >= GadgetY(nGadgetNo,#PB_Gadget_ScreenCoordinate)) And (DesktopMouseY() < GadgetY(nGadgetNo,#PB_Gadget_ScreenCoordinate) + GadgetHeight(nGadgetNo))
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure myDelay(nDelayTime)
  Protected qTimeNow.q
  
  qTimeNow = ElapsedMilliseconds()
  While (ElapsedMilliseconds() - qTimeNow) < nDelayTime
    WaitWindowEvent(10)
  Wend
EndProcedure

Procedure isCtrlKeyDown()
  If GetAsyncKeyState_(#VK_CONTROL) & 32768
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure isShiftKeyDown()
  If GetAsyncKeyState_(#VK_SHIFT) & 32768
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure isAltKeyDown()
  ; nb Alt key is VK_MENU
  If GetAsyncKeyState_(#VK_MENU) & 32768
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure.s decodeEnaDisAction(nAction)
  Protected sAction.s
  
  Select nAction
    Case #SCS_ENADIS_ENABLE
      sAction = "Enable"
    Case #SCS_ENADIS_DISABLE
      sAction = "Disable"
  EndSelect
  ProcedureReturn sAction
EndProcedure

Procedure encodeEnaDisAction(sAction.s)
  Protected nAction
  
  Select sAction
    Case "Enable"
      nAction = #SCS_ENADIS_ENABLE
    Case "Disable"
      nAction = #SCS_ENADIS_DISABLE
  EndSelect
  ProcedureReturn nAction
EndProcedure

Procedure changeColorBrightness(nColor, fCorrectionFactor.f=0.5)
  ; based on http://www.pvladov.com/2012/09/make-color-lighter-or-darker.html
  ; nColor: Color to correct
  ; fCorrectionFactor: The brightness correction factor. Must be between -1 and 1.
  Protected fMyCorrectionFactor.f
  Protected fRed.f, fGreen.f, fBlue.f
  
  If fCorrectionFactor < 0
    ; negative factors produce darker colors
    fMyCorrectionFactor = 1 + fCorrectionFactor
    fRed = Red(nColor) * fMyCorrectionFactor
    fGreen = Green(nColor) * fMyCorrectionFactor
    fBlue = Blue(nColor) * fMyCorrectionFactor
  Else
    ; positive factors produce lighter colors
    fMyCorrectionFactor = fCorrectionFactor
    fRed = (255 - Red(nColor)) * fMyCorrectionFactor + Red(nColor)
    fGreen = (255 - Green(nColor)) * fMyCorrectionFactor + Green(nColor)
    fBlue = (255 - Blue(nColor)) * fMyCorrectionFactor + Blue(nColor)
  EndIf
  
  ProcedureReturn RGB(fRed, fGreen, fBlue)
  
EndProcedure

Procedure getContrastColor(nColor)
  ; based on http://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color
  Protected dLuminance.d
  Protected nRed, nGreen, nBlue
  Protected nContrastColor
  
  Select nColor
    Case #SCS_Black
      nContrastColor = #SCS_White
    Case #SCS_White
      nContrastColor = #SCS_Black
    Default
      ; Get RGB from Color
      nRed = Red(nColor)
      nGreen = Green(nColor)
      nBlue = Blue(nColor)
      ; Counting the perceptive luminance - human eye favors green color...
      dLuminance = 1 - ( 0.299 * nRed + 0.587 * nGreen + 0.114 * nBlue) / 255
      If (dLuminance < 0.5)
        nContrastColor = #SCS_Black  ; bright colors - black font
      Else
        nContrastColor = #SCS_White  ; dark colors - white font
      EndIf
  EndSelect
  
  ProcedureReturn nContrastColor
  
EndProcedure

; PB 5.2 - set windows transparency (Mac,Linux,Windows)
; published by eddy in Tricks 'n' Tips Forum topic "PB5.2 : set windows transparency (cross-platform)", July 2013
; could be useful for cross-fading images with videos if they are in different windows
CompilerIf #PB_Compiler_OS=#PB_OS_Linux
  ImportC "-gtk"
    gtk_window_set_opacity(*Window.i, Opacity.d);
    gtk_widget_is_composited(*Widget)
  EndImport
  
  Procedure.i SetWindowTransparency(Window, Transparency=255)
    Protected *windowID=WindowID(Window), alpha.d=Transparency/255.0
    If Transparency>=0 And Transparency<=255
      If gtk_widget_is_composited(*windowID)
        gtk_window_set_opacity(*windowID, alpha.d)
        ProcedureReturn #True
      EndIf
    EndIf
  EndProcedure
CompilerElseIf #PB_Compiler_OS=#PB_OS_MacOS
  Procedure.i SetWindowTransparency(Window, Transparency=255)
    Protected *windowID=WindowID(Window), alpha.CGFloat=Transparency/255.0
    If Transparency>=0 And Transparency<=255
      CocoaMessage(0, *windowID, "setOpaque:", #NO)
      If CocoaMessage(0, *windowID, "isOpaque")=#NO
        CocoaMessage(0, *windowID, "setAlphaValue:@", @alpha)
        ProcedureReturn #True
      EndIf
    EndIf
  EndProcedure
CompilerElseIf #PB_Compiler_OS=#PB_OS_Windows
  Procedure.i SetWindowTransparency(Window, Transparency=255)
    Protected *windowID=WindowID(Window), exStyle=GetWindowLongPtr_(*windowID, #GWL_EXSTYLE)
    If Transparency>=0 And Transparency<=255
      SetWindowLongPtr_(*windowID, #GWL_EXSTYLE, exStyle | #WS_EX_LAYERED)
      SetLayeredWindowAttributes_(*windowID, 0, Transparency, #LWA_ALPHA)
      ProcedureReturn #True
    EndIf
  EndProcedure
CompilerEndIf

Procedure.s expandNumbersInString(sString.s, nNumberLength)
  Protected sOldString.s, sNewString.s
  Protected sChar.s, sNumber.s
  Protected n, bReadingNumber
  
  sOldString = sString
  For n = 1 To Len(sOldString)
    sChar = Mid(sOldString, n, 1)
    If (sChar >= "0") And (sChar <= "9")
      ; numeric character
      sNumber + sChar
      bReadingNumber = #True
    Else
      ; non-numeric character
      If bReadingNumber
        ; end of the number
        If Len(sNumber) < nNumberLength
          sNewString + RSet(sNumber, nNumberLength, "0")
        Else
          sNewString + sNumber
        EndIf
        sNumber = ""
        bReadingNumber = #False
      EndIf
      sNewString + sChar
    EndIf
  Next n
  If bReadingNumber
    If Len(sNumber) < nNumberLength
      sNewString + RSet(sNumber, nNumberLength, "0")
    Else
      sNewString + sNumber
    EndIf
  EndIf
  ProcedureReturn sNewString
  
EndProcedure

Procedure.s decodeCallCueAction(nCallCueAction)
  Protected sCallCueAction.s
  Select nCallCueAction
    Case #SCS_QQ_CALLCUE
      sCallCueAction = "CallCue"
    Case #SCS_QQ_SELHKBANK
      sCallCueAction = "SelHKBank"
  EndSelect
  ProcedureReturn sCallCueAction
EndProcedure

Procedure encodeCallCueAction(sCallCueAction.s)
  Protected nCallCueAction
  Select sCallCueAction
    Case "CallCue"
      nCallCueAction = #SCS_QQ_CALLCUE
    Case "SelHKBank"
      nCallCueAction = #SCS_QQ_SELHKBANK
  EndSelect
  ProcedureReturn nCallCueAction
EndProcedure

Procedure.s decodeFormat(nFormat)
  Protected sFormat.s
  
  Select nFormat
    Case #PB_Ascii
      sFormat = "#PB_Ascii"
    Case #PB_Unicode
      sFormat = "#PB_Unicode"
    Case #PB_UTF8
      sFormat = "#PB_UTF8"
    Default
      sFormat = Str(nFormat)
  EndSelect
  ProcedureReturn sFormat
EndProcedure

Procedure.s decodeLTransportSwitch(nTransportSwitch)
  Protected sTransportSwitch.s
  
  Select nTransportSwitch
    Case #SCS_TRANSPORT_SWITCH_CUE
      sTransportSwitch = grText\sTextCue
    Case #SCS_TRANSPORT_SWITCH_SUB
      sTransportSwitch = grText\sTextSub
    Case #SCS_TRANSPORT_SWITCH_FILE
      sTransportSwitch = grText\sTextFile
  EndSelect
  ProcedureReturn sTransportSwitch
EndProcedure

Procedure encodeTestToneSound(sTestToneSound.s)
  ; Added 3May2022pm 11.9.1
  Protected nTestToneSound
  
  Select sTestToneSound
    Case "Pink"
      nTestToneSound = #SCS_TEST_TONE_PINK
    Default
      nTestToneSound = #SCS_TEST_TONE_SINE
  EndSelect
  ProcedureReturn nTestToneSound
EndProcedure

Procedure.s decodeTestToneSound(nTestToneSound)
  ; Added 3May2022pm 11.9.1
  Protected sTestToneSound.s
  
  Select nTestToneSound
    Case #SCS_TEST_TONE_PINK
      sTestToneSound = "Pink"
    Default
      sTestToneSound = "Sine"
  EndSelect
  ProcedureReturn sTestToneSound
EndProcedure

Procedure.s decodeNormalize(nNormalize)
  Protected sNormalize.s
  
  CompilerIf #c_include_peak
    Select nNormalize
      Case #SCS_NORMALIZE_LUFS
        sNormalize = "Normalize LUFS"
      Case #SCS_NORMALIZE_PEAK
        sNormalize = "Normalize Peak"
      Case #SCS_NORMALIZE_TRUE_PEAK
        sNormalize = "Normalize True Peak"
    EndSelect
  CompilerElse
    Select nNormalize
      Case #SCS_NORMALIZE_LUFS
        sNormalize = "Normalize LUFS"
      Case #SCS_NORMALIZE_TRUE_PEAK
        sNormalize = "Normalize True Peak"
    EndSelect
  CompilerEndIf
  ProcedureReturn sNormalize
EndProcedure

; EOF