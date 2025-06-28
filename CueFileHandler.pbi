; File: CueFileHandler.pbi
; abbreviation: CFH

; A 'Cue File' is the .scs11 file that contains details of the cues for a production.

EnableExplicit

; nFileVersion will be numeric equivalent of FileVersion, with 2 digits for each sub-component
; eg "9.4.6" will be 90406
;    "9.0"   will be 90000
;    "8"     will be 80000
;    "11"    will be 110000

Macro DEV_UPDATE(pLeft, pRight)
  rThisDev\pLeft = pRight
EndMacro

Procedure closeSCSCueFile(nFileNo)
  PROCNAMEC()
  debugMsg(sProcName, "gbCueFileOpen=" + strB(gbCueFileOpen) + ", nFileNo=" + nFileNo)
  If gbCueFileOpen
    CloseFile(nFileNo)
    gbCueFileOpen = #False
  EndIf
  gbOpeningCueFile = #False
EndProcedure

Procedure close2ndSCSCueFile(nFileNo)
  PROCNAMEC()
  debugMsg(sProcName, "gb2ndCueFileOpen=" + strB(gb2ndCueFileOpen) + ", nFileNo=" + nFileNo)
  If gb2ndCueFileOpen
    CloseFile(nFileNo)
    gb2ndCueFileOpen = #False
  EndIf
EndProcedure

Procedure.s decodeFileName(sStoredName.s, bPrimaryFile=#True, bConvertForwardSlashToBackSlash=#True, bCollecting=#False, bTemplate=#False, sCueFolder.s="")
  PROCNAMEC()
  Protected sMyStoredName.s, sMyName.s
  Protected sCode.s, nCodePos
  Protected sCodeSlash.s, nCodeSlashPos
  Protected sMyCueFolder.s
  ; Note: 'place holder' safe
  
  sMyStoredName = sStoredName
  
  ; Note that "$(cue)" is used in cues for references to files that are in the same folder as the cue file, eg "$(Cue)\fanfare.mp3".
  ; This is to simplify the transferring for productions (cue file plus all associated files) to another computer.
  ; If the entire folder is copied (or moved) then all these file references will still be valid.
  ; Note LCase as SCS normally saves this as "$(Cue)" not as "$(cue)".
  sCode = "$(cue)"
  sCodeSlash = "$(cue)\"
  nCodePos = FindString(LCase(sMyStoredName), sCode)
  nCodeSlashPos = FindString(LCase(sMyStoredName), sCodeSlash)
  If nCodePos > 0
    If bTemplate And sCueFolder
      sMyCueFolder = sCueFolder
    ElseIf bPrimaryFile
      If bCollecting
        sMyCueFolder = grWPF\sProdFolder
      Else
        sMyCueFolder = gsCueFolder
      EndIf
    Else
      sMyCueFolder = gs2ndCueFolder
    EndIf
    ; the following is to avoid a double-slash in the decoded filename
    If (nCodeSlashPos > 0) And (Right(sMyCueFolder,1) = "\")
      sMyName = ReplaceString(sMyStoredName, sCodeSlash, sMyCueFolder, #PB_String_NoCase)
    Else
      sMyName = ReplaceString(sMyStoredName, sCode, sMyCueFolder, #PB_String_NoCase)
    EndIf
    
  ElseIf LCase(Left(sMyStoredName, 10)) = "$(initdir)"   ; supported on input for backward-compatibility
    sMyName = grGeneralOptions\sInitDir + Mid(sMyStoredName, 11)
    
  ElseIf LCase(Left(sMyStoredName, 7)) = "$(init)"       ; as above
    sMyName = grGeneralOptions\sInitDir + Mid(sMyStoredName, 8)
    
  ElseIf LCase(Left(sMyStoredName, 10)) = "$(apppath)"   ; as above
    sMyName = gsAppPath + Mid(sMyStoredName, 11)
    
  ElseIf LCase(Left(sMyStoredName, 9)) = "$(mydocs)"     ; as above
    sMyName = gsMyDocsPath + Mid(sMyStoredName, 10)
    
  Else
    ; debugMsg(sProcName, "no code found")
    sMyName = sMyStoredName
    
  EndIf
  
  If bConvertForwardSlashToBackSlash
    sMyName = ReplaceString(sMyName, "/", "\")
  EndIf
  
  ; debugMsg(sProcName, "sStoredName=" + sStoredName + ", sMyName=" + sMyName)
  ProcedureReturn sMyName
  
EndProcedure

Procedure.s fieldDecode(pField.s)
  PROCNAMEC()
  Protected strWork1.s
  Protected strWork2.s
  Protected strChar.s
  Protected lngAmpPtr

  strWork1 = pField
  strWork2 = ""

  While Len(strWork1) > 0
    lngAmpPtr = FindString(strWork1, "&", 1)
    If lngAmpPtr = 0
      strWork2 + strWork1
      strWork1 = ""
    Else
      strWork2 + Left(strWork1, lngAmpPtr - 1)
      strChar = Mid(strWork1, lngAmpPtr, 2)
      If strChar = "&q"
        strWork2 + Chr(34)
      ElseIf strChar = "&&"
        strWork2 + "&"
      EndIf
      strWork1 = Mid(strWork1, lngAmpPtr + 2)
    EndIf
  Wend

  ProcedureReturn strWork2
EndProcedure

Procedure.s fieldEncode(pField.s)
  ; PROCNAMEC()
  Protected strWork1.s, strWork2.s, strChar.s
  Protected lngAmpPtr, lngQuotPtr, lngReqdPtr

  strWork1 = pField
  strWork2 = ""

  While Len(strWork1) > 0
    lngAmpPtr = FindString(strWork1, "&", 1)
    lngQuotPtr = FindString(strWork1, Chr(34), 1)
    If (lngAmpPtr = 0) And (lngQuotPtr = 0)
      strWork2 + strWork1
      strWork1 = ""
    Else
      If lngQuotPtr = 0
        lngReqdPtr = lngAmpPtr
      ElseIf lngAmpPtr = 0
        lngReqdPtr = lngQuotPtr
      ElseIf lngAmpPtr < lngQuotPtr
        lngReqdPtr = lngAmpPtr
      Else
        lngReqdPtr = lngQuotPtr
      EndIf
      strWork2 + Left(strWork1, lngReqdPtr - 1)
      strChar = Mid(strWork1, lngReqdPtr, 1)
      If strChar = "&"
        strWork2 + "&&"
      Else
        strWork2 + "&q"
      EndIf
      strWork1 = Mid(strWork1, lngReqdPtr + 1)
    EndIf
  Wend

  ProcedureReturn strWork2
EndProcedure

Procedure lineCount(sFileName.s)
  PROCNAMEC()
  Protected nMyFileNo, nLineCount, sLine.s
  Protected nStringFormat
  
  nLineCount = -1
  If FileExists(sFileName)
    nLineCount = 0
    nMyFileNo = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
    If nMyFileNo
      nStringFormat = ReadStringFormat(nMyFileNo)
      debugMsg(sProcName, "nStringFormat=" + decodeStringFormat(nStringFormat))
      While (Eof(nMyFileNo) = 0) And (nLineCount < 1000000)
        sLine = ReadString(nMyFileNo, nStringFormat)
        nLineCount + 1
      Wend
      CloseFile(nMyFileNo)
      If nLineCount >= 1000000
        ; never got to eof after 1000000 reads - something's wrong so return -2
        nLineCount = -2
      EndIf
    EndIf
  EndIf

  debugMsg(sProcName, Str(nLineCount) + " lines in " + #DQUOTE$ + sFileName + #DQUOTE$)
  ProcedureReturn nLineCount

EndProcedure

Procedure.s setDecSepForLocale(sData.s)
  Protected sResult.s
  ; procedure to allow handling a cue file that was created in a locale with a different decimal marker,
  ; by converting the original decimal marker to that of the current locale.
  ; intended for use only in reading SCS cue files.
  
  sResult = sData
  If (gsDecimalMarker <> ".") And (FindString(sData, ".") > 0)
    sResult = ReplaceString(sData, ".", gsDecimalMarker)
  ElseIf (gsDecimalMarker <> ",") And (FindString(sData, ",") > 0)
    sResult = ReplaceString(sData, ",", gsDecimalMarker)
  EndIf
  ProcedureReturn sResult
EndProcedure

Procedure.s encodeFileName(sFileName.s, bCollecting=#False, bTemplate=#False)
  PROCNAMEC()
  Protected sCueFolder.s
  Protected sEncodedFileName.s
  
  sEncodedFileName = sFileName
  If bTemplate = #False ; nb filenames stored in templates must be the full filename, not encoded
    If bCollecting
      sCueFolder = grWPF\sProdFolder
    Else
      sCueFolder = gsCueFolder
    EndIf
    If sCueFolder
      If FindString(LCase(sEncodedFileName), LCase(sCueFolder))
        sEncodedFileName = ReplaceString(sFileName, sCueFolder, "$(Cue)\", #PB_String_NoCase)
        While FindString(sEncodedFileName, "$(Cue)\\")
          sEncodedFileName = ReplaceString(sEncodedFileName, "$(Cue)\\", "$(Cue)\")
        Wend
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn sEncodedFileName
  
EndProcedure

Procedure nextInputChar(nFileNo, nStringFormat)
  ; PROCNAMEC()
  ; this procedure pulls the left-most character from gsLine and places it in gsChar, then drops that character from gsLine.
  ; when Len(gsLine) = 0, gsLine is re-populated with the next line from the file.
  Protected sItem.s, sLeft.s, sRight.s
  Protected nPosStart, nPosEnd

  While Len(gsLine) = 0
    If Eof(nFileNo)
      gbEOF = #True
      ProcedureReturn
    EndIf
    ; debugMsg(sProcName, "calling ReadString(" + nFileNo + ", " + decodeStringFormat(nStringFormat) + ")")
    gsLine = ReadString(nFileNo, nStringFormat)
    ; debugMsg(sProcName, "gsLine=" + gsLine)
    If gsLine
      ; Added 16Jul2022 11.9.3.1ad
      If Trim(gsLine) = "<MemoRTFText>"
        ; gsLine contains "<MemoRTFText>" and nothing more, ie the memo RTF text is in the following lines of the file.
        mergeMemoRTFText(nFileNo, nStringFormat)
        ; debugMsg(sProcName, "gsLine=" + gsLine)
      EndIf
      ; End added 16Jul2022 11.9.3.1ad
      ; added 11.6.0 to allow the original own-built SCS processing of XML files to handle empty tags
      ; eg "<PRCSNetworkReplyMsg/>" will be converted to "<PRCSNetworkReplyMsg></PRCSNetworkReplyMsg>"
      nPosEnd = FindString(gsLine, "/>")
      If nPosEnd  ; test nPosEnd first because very few lines (if any) will contain the string "/>"
        nPosStart = FindString(gsLine, "<")
        If (nPosStart) And (nPosEnd > nPosStart)
          sLeft = Left(gsLine, nPosStart-1)
          sRight = Mid(gsLine, nPosEnd+2)
          sItem = Mid(gsLine, nPosStart+1, nPosEnd-nPosStart-1)
          gsLine = sLeft + "<" + sItem + "></" + sItem + ">" + sRight
        EndIf
      EndIf
      ; end added 11.6.0
      ; replace tabs with single space
      gsLine = ReplaceString(gsLine, Chr(8), " ")
      ; add space to end of line to represent a space between word at eol and word at start of next line
      gsLine + " "
    EndIf
  Wend
  
  gsChar = Left(gsLine, 1)
  If Len(gsLine) = 1
    gsLine = ""
  Else
    gsLine = Mid(gsLine, 2)
  EndIf
  gbEOF = #False
  
EndProcedure

Procedure nextInputTag(nFileNo, nStringFormat)
  PROCNAMEC()
  Protected sTagParams.s, nAttributeNo, sAttributeName.s, sAttributeValue.s
  Protected nQuotePos1, nQuotePos2, nLength
  
  gsTag = ""

  If (Eof(nFileNo)) And (Len(gsLine) = 0)
    ProcedureReturn
  EndIf
  
  While (gsChar <> "<") And (Eof(nFileNo) = #False)
    ; ignore anything before "<"
    nextInputChar(nFileNo, nStringFormat)
  Wend
  
  If (Eof(nFileNo)) And (Len(gsLine) = 0)
    ProcedureReturn
  EndIf
  
  ; gsTag = characters between but not including "<" and ">" or first space
  ; get tag
  While (gsChar <> " ") And (gsChar <> ">") And (gbEOF = #False)
    If (gsChar = "<") And (Len(gsTag) = 0)
      ; do not save "<" at start of tag
    Else
      gsTag + gsChar
    EndIf
    nextInputChar(nFileNo, nStringFormat)
  Wend

  ; get tag params (if any)
  While (gsChar = " ") And (gbEOF = #False)
    ; ignore spaces between tag and params
    nextInputChar(nFileNo, nStringFormat)
  Wend

  While (gsChar <> ">") And (gbEOF = #False)
    sTagParams + gsChar
    nextInputChar(nFileNo, nStringFormat)
  Wend
  sTagParams = Trim(sTagParams)
  
  For nAttributeNo = 1 To 2 ; currently limited to a maximum of 2 attributes
    sAttributeName = ""
    sAttributeValue = ""
    If sTagParams
      nQuotePos1 = FindString(sTagParams, #DQUOTE$)
      If nQuotePos1 > 0
        nQuotePos2 = FindString(sTagParams, #DQUOTE$, nQuotePos1+1)
        If nQuotePos2 > 0
          sAttributeName = Trim(StringField(sTagParams, 1, "="))
          nLength = nQuotePos2 - nQuotePos1 - 1
          If nLength > 0
            sAttributeValue = XMLDecode(Mid(sTagParams, nQuotePos1+1, nLength))
          EndIf
        EndIf
      EndIf
      sTagParams = Trim(Mid(sTagParams, nQuotePos2+1))
    EndIf
    If nAttributeNo = 1
      gsTagAttributeName1 = sAttributeName
      gsTagAttributeValue1 = sAttributeValue
    Else
      gsTagAttributeName2 = sAttributeName
      gsTagAttributeValue2 = sAttributeValue
    EndIf
  Next nAttributeNo
;   If gsTagAttributeName1 Or gsTagAttributeName2
;     debugMsg0(sProcName, "gsTag=" + gsTag + ", gsTagAttributeName1=" + gsTagAttributeName1 + ", gsTagAttributeValue1=" + gsTagAttributeValue1 + ", gsTagAttributeName2=" + gsTagAttributeName2 + ", gsTagAttributeValue2=" + gsTagAttributeValue2)
;   EndIf
  
  gsChar = ""
  
  ; debugMsg(sProcName, #SCS_END + ", gsTag=" + gsTag + ", sTagParams=" + sTagParams + ", gsTagAttributeName1=" + gsTagAttributeName1 + ", gsTagAttributeValue1=" + gsTagAttributeValue1 + ", gbEOF=" + strB(gbEOF))
  
EndProcedure

Procedure nextInputData(nFileNo, nStringFormat)
  ; PROCNAMEC()
  ; debugMsg(sProcName, #SCS_START)
  gsData = ""
  ; gsData = characters up to but not including "<"
  While (gsChar <> "<") And (gbEOF = #False)
    gsData + gsChar
    nextInputChar(nFileNo, nStringFormat)
  Wend
  gsData = XMLDecode(gsData)
EndProcedure

Procedure openSCSCueFile(bCreateFromTemplate=#False, bTemplate=#False)
  PROCNAMEC()
  Protected nCueFile
  Protected sTmp.s, nPos, sMsg.s
  Protected bHoldModalDisplayed
  Protected sFileName.s
  
  debugMsg(sProcName, #SCS_START + ", bCreateFromTemplate=" + strB(bCreateFromTemplate) + ", bTemplate=" + strB(bTemplate))

  gbCueFileOpen = #False
  gbMidiWarningDisplayed = #False
  DMX_clearCueStartDMXSave()
  
  grWQMDevPopulated = grWQMDevPopulatedDef
  
  If bCreateFromTemplate Or bTemplate
    sFileName = gsTemplateFile
  Else
    sFileName = gsCueFile
  EndIf
  debugMsg(sProcName, "gsCueFile=" + #DQUOTE$ + gsCueFile + #DQUOTE$)
  debugMsg(sProcName, "gsTemplateFile=" + #DQUOTE$ + gsTemplateFile + #DQUOTE$)
  grCFH\sMostRecentCueFile = gsCueFile ; Added 5Jul2022 11.9.3.1ab
  grCFH\nMostRecentCueFileDateModified = GetFileDate(grCFH\sMostRecentCueFile, #PB_Date_Modified)
  debugMsg(sProcName, "grCFH\nMostRecentCueFileDateModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", grCFH\nMostRecentCueFileDateModified))
  debugMsg(sProcName, "grCFH\sMostRecentCueFile=" + #DQUOTE$ + grCFH\sMostRecentCueFile + #DQUOTE$) ; Changed 5Jul2022 11.9.3.1ab
  
  ; Open the file for reading
  nCueFile = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
  If nCueFile = 0
    ensureSplashNotOnTop()
    scsMessageRequester("File Open", "Error opening file " + sFileName)
    ProcedureReturn
  EndIf
  debugMsg(sProcName, "opened cue file " + sFileName)
  
  gnCueFileStringFormat = ReadStringFormat(nCueFile)
  ; debugMsg(sProcName, "gnCueFileStringFormat=" + decodeStringFormat(gnCueFileStringFormat))
  
  gsLine = ReadString(nCueFile, gnCueFileStringFormat)
  ; debugMsg(sProcName, "Line 1: " + gsLine)
  CloseFile(nCueFile)

  ; debugMsg(sProcName, "UCase(Left(gsLine, 5))=" + UCase(Left(gsLine, 5)) + ".")
  If UCase(Left(gsLine, 5)) = "<?XML"
    gbXMLFormat = #True
    gbCueFileOpen = #True
  Else
    gbXMLFormat = #False
    gbCueFileOpen = #False
    If Left(gsLine, 11) = #DQUOTE$ + "H" + #DQUOTE$ + "," + #DQUOTE$ + "SCS" + #DQUOTE$ + "," + #DQUOTE$   ; checking for: "H","SCS","
      sTmp = Mid(gsLine, 12)
      nPos = FindString(sTmp, #DQUOTE$, 1)
      If nPos > 1
        sTmp = Left(sTmp, nPos - 1)
        sMsg = "File " + GetFilePart(sFileName) + " was created by SCS " + sTmp + ". This format is not supported by SCS 11."
      Else
        sMsg = "File " + GetFilePart(sFileName) + " is corrupt or has a format unrecognized by SCS 11"
      EndIf
    Else
      sMsg = "File " + GetFilePart(sFileName) + " is corrupt or has a format unrecognized by SCS 11"
    EndIf
    debugMsg(sProcName, sMsg)
    bHoldModalDisplayed = gbModalDisplayed
    gbModalDisplayed = #True
    ensureSplashNotOnTop()
    scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Ok)
    gbModalDisplayed = bHoldModalDisplayed
    ProcedureReturn
  EndIf

  debugCueFile(sFileName)
  countCueFileItems(sFileName)
  
  nCueFile = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
  gnCueFileStringFormat = ReadStringFormat(nCueFile)  ; need to read this again to skip over the BOM if present
  gnCueFileNo = nCueFile
  debugMsg(sProcName, "gnCueFileNo=" + Str(gnCueFileNo) + ", gnCueFileStringFormat=" + decodeStringFormat(gnCueFileStringFormat))
  gsLine = ""
  gsChar = ""
  gbEOF = #False
  
  If bCreateFromTemplate Or bTemplate
    logKeyEvent("Template File Opened: " + gsTemplateFile)
  Else
    If gbRecovering
      gsCueFile = grRecoveryFileInfo\sCueFile
    EndIf
    gsCueFolder = GetPathPart(gsCueFile)
    debugMsg(sProcName, "gsCueFolder=" + gsCueFolder)
    logKeyEvent("Cue File Opened: " + gsCueFile)
    ; Get the Opened File Date Modified Value
    ; grCFH\nCueFileDateModified = GetFileDate(sFileName, #PB_Date_Modified) ; Deleted 5Jul2022 11.9.3.1ab
    ; debugMsg(sProcName, "grCFH\nCueFileDateModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", grCFH\nCueFileDateModified)) ; Deleted 5Jul2022 11.9.3.1ab
  EndIf
  
  If RAI_IsClientActive()
    grRAI\nStatus | #SCS_RAI_STATUS_FILE
    sendOSCStatus()
  EndIf
  grRAI\bNewCueFile = #False
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure open2ndSCSCueFile()
  PROCNAMEC()
  Protected n2ndCueFile
  
  debugMsg(sProcName, #SCS_START)
  
  gb2ndCueFileOpen = #False

  ; Open the file for reading
  n2ndCueFile = ReadFile(#PB_Any, gs2ndCueFile, #PB_File_SharedRead)
  If n2ndCueFile = 0
    ensureSplashNotOnTop()
    scsMessageRequester("File Open", "Error opening file " + gs2ndCueFile)
    ProcedureReturn
  EndIf
  
  gs2ndCueFolder = GetPathPart(gs2ndCueFile)
  debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
  debugMsg(sProcName, "opened cue file " + gs2ndCueFile)
  gb2ndCueFileOpen = #True
  gn2ndCueFileNo = n2ndCueFile
  
  gn2ndCueFileStringFormat = ReadStringFormat(n2ndCueFile)
  debugMsg(sProcName, "gn2ndCueFileStringFormat=" + decodeStringFormat(gn2ndCueFileStringFormat))
  
  gsLine = ReadString(n2ndCueFile, gn2ndCueFileStringFormat)
  debugMsg(sProcName, "Line 1: " + gsLine)
  If UCase(Left(gsLine, 5)) = "<?XML"
    gb2ndXMLFormat = #True
  Else
    gb2ndXMLFormat = #False
  EndIf
  debugMsg(sProcName, "gb2ndXMLFormat=" + strB(gb2ndXMLFormat))
  CloseFile(n2ndCueFile)
  n2ndCueFile = ReadFile(#PB_Any, gs2ndCueFile, #PB_File_SharedRead)
  gn2ndCueFileStringFormat = ReadStringFormat(n2ndCueFile)  ; need to read this again to skip over the BOM if present
  gn2ndCueFileNo = n2ndCueFile
  grCFH\s2ndLine = ""
  grCFH\s2ndChar = ""
  grCFH\b2ndEOF = #False
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure propagateFileInfo()
  PROCNAMEC()
  Protected f, k, i, j, nFileDataPtr
  Protected sFileName.s
  Protected bAddFileData
  Protected rFileData.tyFileData

  debugMsg(sProcName, #SCS_START + ", gnLastAud=" + gnLastAud + ", gnLastFileData=" + gnLastFileData)
  
  For k = 1 To gnLastAud
    aAud(k)\nFileDataPtr = -1
    aAud(k)\nFileStatsPtr = -1
  Next k

  For f = 1 To gnLastFileData
    With gaFileData(f)
      ; debugMsg(sProcName, "gaFileData(" + f + ")\sFileName=" + GetFilePart(\sFileName))
      If \nFileDuration = grFileDataDef\nFileDuration
        ; debugMsg(sProcName, "calling GetInfoAboutFile")
        If getInfoAboutFile(\sFileName)
          \nFileDuration = grInfoAboutFile\nFileDuration
          \qFileBytes = grInfoAboutFile\qFileBytes
          \qFileBytesForTenSecs = grInfoAboutFile\qFileBytesForTenSecs
          debugMsg(sProcName, "gaFileData(" + f + ")\nFileDuration=" + \nFileDuration + ", \qFileBytes=" + \qFileBytes + ", \qFileBytesForTenSecs=" + Str(\qFileBytesForTenSecs))
          \nxFileChannels = grInfoAboutFile\nFileChannels
          \bOKForSMS = grInfoAboutFile\bOKForSMS
          \bOKForAnalyzeFile = grInfoAboutFile\bOKForAnalyzeFile
          debugMsg(sProcName, "\sFileName=" + GetFilePart(\sFileName) + ", \nxFileChannels=" + \nxFileChannels + ", \bOKForSMS=" + strB(\bOKForSMS) + ", \bOKForAnalyzeFile=" + strB(\bOKForAnalyzeFile))
          ; debugMsg(sProcName, "calling setMaxInnerWidthForFile(" + f + ")")
          setMaxInnerWidthForFile(f)
        Else
          debugMsg(sProcName, "GetInfoAboutFile returned false for " + \sFileName)
        EndIf
      EndIf
      For k = 1 To gnLastAud
        If aAud(k)\bExists
          If aAud(k)\sFileName = \sFileName
            aAud(k)\nFileDataPtr = f
            aAud(k)\nFileDuration = \nFileDuration
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + "\nFileDuration=" + aAud(k)\nFileDuration)
            aAud(k)\nFileChannels = \nxFileChannels
            aAud(k)\sFileType = \sFileType
            aAud(k)\bOKForSMS = \bOKForSMS
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileName=" + GetFilePart(aAud(k)\sFileName) + ", \nFileChannels=" + Str(aAud(k)\nFileChannels) + ", \sFileType=" + \sFileType + ", \bOKForSMS=" + strB(\bOKForSMS))
            If (aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE) Or (aAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO)
              aAud(k)\nSourceWidth = \nSourceWidth
              aAud(k)\nSourceHeight = \nSourceHeight
            Else
              aAud(k)\nSourceWidth = grAudDef\nSourceWidth
              aAud(k)\nSourceHeight = grAudDef\nSourceHeight
            EndIf
            aAud(k)\sFileTitle = \sFileTitle
            If Len(aAud(k)\sFileTitle) = 0
              getFileDetail(k)
              \sFileTitle = grFileInfo\sFileTitle
              aAud(k)\sFileTitle = \sFileTitle
            EndIf
            aAud(k)\bInfoObtained = #True
            ; debugMsg(sProcName, "calling setDerivedAudFields(" + k + ")")
            setDerivedAudFields(k)
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileName=" + GetFilePart(aAud(k)\sFileName) +
                                ", \nFileDuration=" + aAud(k)\nFileDuration + ", \nCueDuration=" + aAud(k)\nCueDuration +
                                ", \nFileChannels=" + aAud(k)\nFileChannels + ", \sFileType=" + aAud(k)\sFileType + ", \sFileTitle=" + aAud(k)\sFileTitle)
          EndIf
        EndIf
      Next k
    EndWith
  Next f
  
  ; now scan for any aud's that do not currently have file info
  For k = 1 To gnLastAud
    bAddFileData = #False
    If aAud(k)\bExists
      If (aAud(k)\nFileDataPtr = -1) And (aAud(k)\bAudPlaceHolder = #False)
        sFileName = aAud(k)\sFileName
        If Trim(sFileName)
          If FileExists(sFileName, #False)
            rFileData = grFileDataDef
            Select aAud(k)\nFileFormat
              Case #SCS_FILEFORMAT_PICTURE
                aAud(k)\sFileType = getPictureInfoForAud(k)
                debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileType=" + aAud(k)\sFileType)
                bAddFileData = #True
                
              Case #SCS_FILEFORMAT_VIDEO
                aAud(k)\sFileType = UCase(GetExtensionPart(aAud(k)\sFileName))
                debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileType=" + aAud(k)\sFileType)
                getVideoInfoForAud(k)
                
              Case #SCS_FILEFORMAT_AUDIO
                If getInfoAboutFile(sFileName)
                  bAddFileData = #True
                  aAud(k)\nFileDuration = grInfoAboutFile\nFileDuration
                  aAud(k)\qFileBytes = grInfoAboutFile\qFileBytes
                  aAud(k)\qFileBytesForTenSecs = grInfoAboutFile\qFileBytesForTenSecs
                  debugMsg(sProcName, "aAud(" + getAudLabel(k) + "\nFileDuration=" + aAud(k)\nFileDuration + ", \qFileBytes=" + aAud(k)\qFileBytes + ", \qFileBytesForTenSecs=" + aAud(k)\qFileBytesForTenSecs)
                  aAud(k)\nFileChannels = grInfoAboutFile\nFileChannels
                  aAud(k)\sFileType = grInfoAboutFile\sFileInfo
                  aAud(k)\bOKForSMS = grInfoAboutFile\bOKForSMS
                  aAud(k)\bOKForAnalyzeFile = grInfoAboutFile\bOKForAnalyzeFile
                  debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileName=" + GetFilePart(aAud(k)\sFileName) + ", \nFileChannels=" + Str(aAud(k)\nFileChannels) + ", \sFileType=" + aAud(k)\sFileType + ", \bOKForSMS=" + strB(aAud(k)\bOKForSMS) + ", \bOKForAnalyzeFile=" + strB(aAud(k)\bOKForAnalyzeFile))
                  aAud(k)\sFileTitle = grInfoAboutFile\sFileTitle
                  aAud(k)\nSourceWidth = grAudDef\nSourceWidth
                  aAud(k)\nSourceHeight = grAudDef\nSourceHeight
                  debugMsg(sProcName, "calling setDerivedAudFields(" + k + ")")
                  setDerivedAudFields(k)
                  debugMsg(sProcName, aAud(k)\sAudLabel + " (b) \nFileDuration=" + Str(aAud(k)\nFileDuration) + ", \nCueDuration=" + Str(aAud(k)\nCueDuration)+ ", \nFileChannels=" + Str(aAud(k)\nFileChannels) + ", \sFileType=" + aAud(k)\sFileType + ", \sFileTitle=" + aAud(k)\sFileTitle)
                Else
                  debugMsg(sProcName, aAud(k)\sAudLabel + " (b) GetInfoAboutFile returned false for " + sFileName)
                EndIf
              Default
            EndSelect
            If bAddFileData
              With rFileData
                \sStoredFileName = aAud(k)\sStoredFileName
                \sFileName = aAud(k)\sFileName
                \sFileType = aAud(k)\sFileType
                \qFileSize = FileSize(\sFileName)
                \sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(\sFileName, #PB_Date_Modified))
                \nFileDuration = aAud(k)\nFileDuration
                \qFileBytes = aAud(k)\qFileBytes
                \qFileBytesForTenSecs = aAud(k)\qFileBytesForTenSecs
                \sFileTitle = aAud(k)\sFileTitle
                If Len(\sFileTitle) = 0
                  \sFileTitle = removeNonPrintingChars(ignoreExtension(GetFilePart(\sFileName)))
                EndIf
                \nxFileChannels = aAud(k)\nFileChannels
              EndWith
              gnLastFileData + 1
              ; debugMsg0(sProcName, "gnLastFileData=" + gnLastFileData)
              If ArraySize(gaFileData()) < gnLastFileData
                REDIM_ARRAY(gaFileData, gnLastFileData+20, grFileDataDef, "gaFileData()")
                debugMsg(sProcName, "ArraySize(gaFileData())=" + ArraySize(gaFileData()))
              EndIf
              gaFileData(gnLastFileData) = rFileData
              debugMsg(sProcName, "calling setMaxInnerWidthForFile(" + Str(gnLastFileData) + ")")
              setMaxInnerWidthForFile(gnLastFileData)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  Next k
  
  ; get video info for any video files without width and height recorded
  For k = 1 To gnLastAud
    If aAud(k)\bExists
      If aAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO
        If (aAud(k)\nSourceWidth = 0) Or (aAud(k)\nSourceHeight = 0)
          getVideoInfoForAud(k)
        EndIf
      EndIf
    EndIf
  Next k
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeAorP Or aSub(j)\bSubTypeF
        setAudDescrsForAorP(j)
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  For i = 1 To gnLastCue
    setLinksForCue(i)
  Next i
  
  ; set links for auds within each sub
  debugMsg(sProcName, "calling setLinksForAudsWithinSubsForCue() for each cue")
  For i = 1 To gnLastCue
    setLinksForAudsWithinSubsForCue(i)
  Next i
  
  setMTCLinksForAllCues()
  
  debugMsg(sProcName, "calling buildAudSetArray()")
  buildAudSetArray()
 
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure initProd()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  grProd = grProdDef
  grCtrlSetup = grCtrlSetupDef
  grVST = grVSTDef
  debugMsg(sProcName, "grVST\nMaxDevVSTPlugin=" + grVST\nMaxDevVSTPlugin)

  gnLastCue = 0
  gnLastSub = 0
  gnLastAud = 0
  gnMaxHotkey = -1
  gnMaxCurrHotkey = -1
  For n = 0 To ArraySize(gnLastHotkeyStepProcessed())
    gnLastHotkeyStepProcessed(n) = 0
  Next n
  
  ; debugMsg(sProcName, "calling clearArrayCueOrSubForMTC()")
  clearArrayCueOrSubForMTC()
  
  ; the following sorted for ease of checking
  gbCallGoClicked = #False
  gbCheckForResetTOD = #False ; Added 1Aug2024 11.10.3ax following bug reported by David Lambert 31Jul2024
  gbWaitForSetCueToGo = #False
  gnCallOpenNextCues = 0
  gnCueToGo = 0
  gnCueToGoState = #SCS_Q2GO_NOT_SET
  gnLastFileData = 0
  gnLastFileStats = 0
  gnLastLoopSync = 0
  gnLastResetDay = Day(Date())  ; prevents needless call to resetTOD() after loading cue file
  grMaps\nMaxMapIndex = -1
  gnPLFirstAndLastTime = -1
  gnProdTimerHistoryPtr = -1
  gnRowToGo = -1
  gnStandbyCuePtr = -1
  gnVisualWarningCuePtr = -1
  gnVisualWarningState = 0
  grMain\nMainMemoSubPtr = -1
  grMG2\nFileDataPtrForSamplesArray = -2
  grProdTimer\nPTState = #SCS_PTS_NOT_STARTED
  grTempDB\bTempDatabaseLoaded = #False
  grWEP\bFixtureTypeTabPopulated = #False
  WCN\bEQChanged = #False ; Added 27Jun2022 11.9.4 (checked by checkSaveToBeEnabled())
  
  initProdArrays(@grProd)
  
  initUndoItems()
  clearSaveSettings()
  If gbMainFormLoaded
    setSaveSettings()
  EndIf
  
EndProcedure

Procedure clearCueFile()
  PROCNAMEC()
  Protected bCuesChanged
  Protected sDefAudioDev.s, sDefVidAudDev.s
  
  debugMsg(sProcName, #SCS_START)
  
  ; under some situations, the 'file locator' window may be open when we get here, so we need to close it
  If IsWindow(#WFL)
    WFL_Form_Unload(#True)
  EndIf
  
  cancelAllLoadRequests() ; nb includes "THR_waitForAThreadToStop(#SCS_THREAD_SLIDER_FILE_LOADER)"
  gbCueFileLoaded = #False
  
  If IsWindow(#WCN) ; fmControllers
    WCN\bUseFaders = #False
    WCN_Form_Unload()
  EndIf
  
  WDD_hideWindowIfDisplayed() ; hide DMX Display window if currently displayed
  WPL_hideWindowIfDisplayed() ; ditto VST plugin editor window
  WVP_hideWindowIfDisplayed() ; ditto fmVSTPlugins
  
  If IsWindow(#WMN)
    ; clear 'last playing cue'
    setLastPlayingCue(-1)
  EndIf
  
  ; debugMsg(sProcName, "calling clearArrayCueOrSubForMTC()")
  clearArrayCueOrSubForMTC()
  
  debugMsg(sProcName, "calling PNL_clearAllDispPanelInfo()")
  PNL_clearAllDispPanelInfo()
  
  debugMsg(sProcName, "calling initProd()")
  initProd()
  
  gsCueFile = ""
  gsCueFolder = ""
  gbGridLoaded = #False
  gbDispPanelsLoaded = #False
  gsAudioFileDialogInitDir = grGeneralOptions\sInitDir
  gnFileNotFoundCount = 0
  ReDim gaFileNotFound(gnFileNotFoundCount)
  gbAudioFileOrPathChanged = #False
  gbSCSVersionChanged = #False
  gbGoToProdPropDevices = #False
  gbCloseCueFile = #False
  gnLogoAudPtr = -1 ; Added 15Mar2025 11.10.8al
  
  DMX_clearCueStartDMXSave()
  
  freeLogoImages()
  
  clearPtrsFromVidPicTargets()
  
  grWQMDevPopulated = grWQMDevPopulatedDef
  
  grProd = grProdDefForAdd
  
  addOneAudioLogicalDev(@grProd)
  With grProd\aAudioLogicalDevs(0)
    \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
    \sLogicalDev = Lang("Init", "DefAudioDev")
    \nNrOfOutputChans = 2
    \bAutoInclude = #True
    gnNextDevId + 1
    \nDevId = gnNextDevId
  EndWith
  
  gnUniqueProdId + 1
  grProd\nProdId = gnUniqueProdId ; integer 'nProdId', used internally
  grProd\sProdId = calcProdId()   ; string 'sProdId', saved in the cue file, and which is quite different to integer 'nProdId'
  gnNodeId + 1
  grProd\nNodeKey = gnNodeId
  gnCueEnd = gnLastCue + 1
  aCue(gnCueEnd) = grCueDef
  gbMidiWarningDisplayed = #False
  grProdTimer\nPTState = #SCS_PTS_NOT_STARTED
  gnProdTimerHistoryPtr = -1
  gnCueToGoOverride = -1
  gnLastPlayingAudioCue = -1
  gbScreenNotPresentWarningDisplayed = #False
  
  setCuePtrs(#True)
  gnLastResetDay = Day(Date())  ; prevents needless call to resetTOD() after loading cue file
  setTimeBasedCues()

  debugMsg(sProcName, "calling openAndReadXMLDevMapFile(#True)")
  openAndReadXMLDevMapFile(#True)
  
  If grProd\nSelectedDevMapPtr < 0
    If grMaps\nMaxMapIndex >= 0
      grProd\nSelectedDevMapPtr = 0
      grProd\sSelectedDevMapName = getDevMapName(grProd\nSelectedDevMapPtr)
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling setLogicalDevsDerivedFields")
  setLogicalDevsDerivedFields()
  
  debugMsg(sProcName, "calling setDisplayPanFlags")
  setDisplayPanFlags()
  
  setDefaults_PropogateProdDevs()
  
  debugMsg(sProcName, "calling setCueBassDevsAndMidiPortNos")
  bCuesChanged = setCueBassDevsAndMidiPortNos()
  
  grProd\sPreviewDevice = grProd\aAudioLogicalDevs(0)\sLogicalDev
  ; debugMsg(sProcName, "grProd\sPreviewDevice=" + grProd\sPreviewDevice)
  
  loadHotkeyArray() ; clears hotkey array
  loadCueMarkerArrays()
  
  debugMsg(sProcName, "calling setProdGlobals()")
  setProdGlobals()  ; nb also calls redrawAllLevelSliders()
  
  grMasterLevel\bUseControllerFaderMasterBVLevel = #False
  If gbMainFormLoaded
    SLD_setLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
  EndIf
  setMasterFader(grProd\fMasterBVLevel)
  debugMsg(sProcName, "calling setAllInputGains()")
  setAllInputGains()
  debugMsg(sProcName, "calling setAllLiveEQ()")
  setAllLiveEQ()
  
  If grLicInfo\bDMXSendAvailable
    If SLD_isSlider(WCN\sldDMXMasterFader)
      SLD_setValue(WCN\sldDMXMasterFader, grProd\nDMXMasterFaderValue)
    EndIf
    grDMXMasterFader\nDMXMasterFaderValue = grProd\nDMXMasterFaderValue
    grDMXMasterFader\nDMXMasterFaderResetValue = grProd\nDMXMasterFaderValue
  EndIf
  
  SLD_clearFocusSlider(#True)
  
  debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(grMTCSendControl\bMTCCuesPortOpen))
  grMTCSendControl = grMTCSendControlDef
  debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(grMTCSendControl\bMTCCuesPortOpen))
  
  setMaxAndMinOutputScreen()
  
  If RAI_IsClientActive()
    grRAI\nStatus | #SCS_RAI_STATUS_FILE
    sendOSCStatus()
  EndIf
  grRAI\bNewCueFile = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure readNoCueFile()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  ; grCFH\nCueFileDateModified = 0 ; Deleted 5Jul2022 11.9.3.1ab
  grCFH\nMostRecentCueFileDateModified = 0 ; Added 5Jul2022 11.9.3.1ab
  gbLoadingCueFile = #True
  grRAI\bNewCueFile = #True
  debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile) + ", grRAI\bNewCueFile=" + strB(grRAI\bNewCueFile))
  
  debugMsg(sProcName, "calling clearCueFile()")
  clearCueFile()
  grProd\bNewCueFile = #True ; Added 7Feb2025 11.10.7aa to address issue encountered in displayLabelsBASSandTVG() in VUDisplay.pbi
  loadCueBrackets()
  
  gbLoadingCueFile = #False
  debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getDevTypeFromLogicalDev(*rProd.tyProd, nDevGrp, sLogicalDev.s)
  ; PROCNAMEC()
  ; NOTE: currently only handles lighting and ctrl send devices - which are the only device types currently required in calls to this procedure
  Protected d, nDevIndex
  Protected nDevType
  
  nDevType = -1
  If sLogicalDev
    With *rProd
      Select nDevGrp
        Case #SCS_DEVGRP_LIGHTING
          For d = 0 To *rProd\nMaxLightingLogicalDev ; #SCS_MAX_LIGHTING_DEV_PER_PROD
            If \aLightingLogicalDevs(d)\sLogicalDev = sLogicalDev
              nDevType = \aLightingLogicalDevs(d)\nDevType
              Break
            EndIf
          Next d
          
        Case #SCS_DEVGRP_CTRL_SEND
          For d = 0 To \nMaxCtrlSendLogicalDev
            If \aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev
              nDevType = \aCtrlSendLogicalDevs(d)\nDevType
              Break
            EndIf
          Next d
          If nDevType = -1
            ; not found - possibly because the cue file was created by SCS 10, so create a new 'device' for this logical device
            nDevIndex = -1
            For d = 0 To *rProd\nMaxCtrlSendLogicalDev
              If (Len(\aCtrlSendLogicalDevs(d)\sLogicalDev) = 0) Or ((\aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev) And (\aCtrlSendLogicalDevs(d)\nDevType = -1))
                nDevIndex = d
                Break
              EndIf
            Next d
            If nDevIndex >= 0
              gnNextDevId + 1
              \aCtrlSendLogicalDevs(nDevIndex)\nDevId = gnNextDevId
              \aCtrlSendLogicalDevs(nDevIndex)\sLogicalDev = sLogicalDev
              \aCtrlSendLogicalDevs(nDevIndex)\nDevType = #SCS_DEVTYPE_CS_RS232_OUT
              nDevType = #SCS_DEVTYPE_CS_RS232_OUT
            EndIf
          EndIf
          
      EndSelect
    EndWith
  EndIf
  
  ProcedureReturn nDevType
  
EndProcedure

;----- readXMLCueFile
Procedure readXMLCueFile(nFileNo, bPrimaryFile, nStringFormat, sCueFile.s, bCreateFromTemplate=#False, bTemplate=#False)
  PROCNAMEC()
  Protected bOK
  Protected nCuePtr, nSubPtr, nAudPtr, nFileDataPtr
  Protected sUpTag.s, sTagCode.s, nTagIndex, nNumLength, sUpAttributeName1.s, sUpAttributeName2.s
  Protected nSubNo, nAudNo, d, d1
  Protected bCuesChanged
  Protected i, j, k, n, m
  Protected Dim sDefaultLogicalDev.s(0)
  Protected bDevFound, bFileFound
  Protected sCurrentFileModified.s, qCurrentFileSize.q
  Protected bInHead, bInAud, bInFile
  Protected nCtrlSendIndex, nCtrlSendDevType, nMSMsgType
  Protected nOldArraySize
  Protected nLTDevType
  Protected nInGrpIndex, nGrpItemIndex
  Protected nLevelPointIndex, nLevelPointItemIndex
  Protected rProd.tyProd, rVST.tyVST
  Protected rCtrlSetup.tyCtrlSetup
  Protected rFixture.tyFixtureLogical
  Protected rCue.tyCue
  Protected rSub.tySub
  Protected rAud.tyAud
  Protected rLoopInfo.tyLoopInfo
  Protected rFileData.tyFileData
  Protected bPhysicalDevInfoFound
  Protected sMsg.s, nReply
  Protected nDefaultDevPtr
  Protected nCtrlSendDevPtr, nCueCtrlDevPtr, nLightingDevPtr
  Protected nSubPtrAtCueStart, nAudPtrAtCueStart
  Protected nLeft
  Protected nOutputArrayIndex
  Protected nValidDevMapPtr
  Protected nCueFileSize, nCueFilePos
  Protected bFileChanged
  Protected sDefVidAudDev.s
  Protected bDefVidAudReqd
  Protected bItemRelDBLevelFound
  Protected sTmp.s
  Protected rEnableDisable.tyEnableDisable
  Protected nEnableDisableIndex
  Protected nDay
  Protected rThisMsgResponse.tyNetworkMsgResponse
  Protected nMsgResponseIndex
  Protected rThisMidiCommand.tyMidiCommand
  Protected nMidiCommandIndex
  Protected rThisX32Command.tyX32Command
  Protected nX32CommandIndex
  Protected rThisDMXCommand.tyDMXCommand
  Protected nDMXCommandIndex
  Protected rFixType.tyFixType, rFixTypeChan.tyFixTypeChan
  Protected nFixTypeIndex, nFTCIndex
  Protected bDMXValuesFound, bDMXItemFound, bMIDIFreeFormatFound
  Protected Dim aDMXSendItem.tyDMXSendItem(#SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB)
  Protected nChaseStepIndex, nDMXSendItemIndex, nFixtureItemIndex, nFixtureChanIndex
  Protected bConvertCtrlSendToLighting
  Protected nDMXFadeTime, nFixItemCount, sFixtureCode.s
  Protected nDotPtr
  Protected bIgnoreThisCSMsg, bIgnoreThisFixtureEntry
  Protected bFound, sCompareStr.s
  Protected bLTSubArraysSet
  Protected nLibPluginIndex, nDevPluginIndex, nVSTParamIndex
  ; the following two ID fields are used for MIDI Playback devices and Ctrl Send devices as SCS 10 and earlier uses 'writeIfReqd' for the logical dev fields,
  ; and this means there's no guaranteed first tag type for a MIDI PlayBack device or for a Ctrl Send device
  Protected nTagIndexID, nLastTagIndexID
  Protected nPRAudDevIndex, nPRAudDevVSTIndex, rAudVSTPlugin.tyAudVSTPlugin
  Protected nvMixInitResult
  Protected nSSItemCount, nSSIndex
  Protected bDMXCaptureConversionCheckReqd ; required for converting pre SCS 11.8.6ba entry type "CAP" to either "CAPSE" (sequence) or "CAPSN" (snapshot)
  Protected bDMXChannelLimit

  gbLoadingCueFile = #True
  grRAI\bNewCueFile = #True
  If bPrimaryFile
    grCFH\bReadingSecondaryCueFile = #False
  Else
    grCFH\bReadingSecondaryCueFile = #True
  EndIf
  debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile) + ", grRAI\bNewCueFile=" + strB(grRAI\bNewCueFile) + ", grCFH\bReadingSecondaryCueFile=" + strB(grCFH\bReadingSecondaryCueFile))
  gbSCSVersionChanged = #False
  grCFH\sFileVersion = ""

  debugMsg(sProcName, #SCS_START + ", nFileNo=" + nFileNo + ", bPrimaryFile=" + strB(bPrimaryFile) + ", gsCueFile=" + gsCueFile + ", bCreateFromTemplate=" + strB(bCreateFromTemplate) + ", bTemplate=" + strB(bTemplate))
  
  ReDim sDefaultLogicalDev(grLicInfo\nMaxAudDevPerAud)
  
  If bPrimaryFile
    initProd()
    ; check if a color file exists in the cue file's folder, and if so then load it now
    loadColorFileIfExists()
  Else
    nCueFileSize = FileSize(gs2ndCueFile)
  EndIf
  
  bOK = #True
  gbEOF = #False
  nCuePtr = 0
  nSubPtr = 0
  nAudPtr = 0
  nPRAudDevIndex = -1
  nCtrlSendDevPtr = -1
  nCueCtrlDevPtr = -1
  nLightingDevPtr = -1
  nLastTagIndexID = -1
  nInGrpIndex = -1
  nFileDataPtr = 0
  gnTagLevel = -1
  gsChar = ""
  gsLine = ""
  nDefaultDevPtr = -1
  sDefVidAudDev = Lang("Init", "DefVidAudDev")
  grCFH\nFileVersion = 80000 ; ie FileVersion 8.0.0 (which remains if no FileVersion tag found)
  If LCase(GetFilePart(gsCueFile)) = "demo.scs"
    gbDemoCueFile = #True
  Else
    gbDemoCueFile = #False
  EndIf
  
  rProd = grProdDef
  initProdArrays(@rProd) ; ReDim's arrays like \aAudioLogicalDevs() according to the number of device entries counted by countCueFileItems()
  
  If bPrimaryFile = #False
    ReDim a2ndCue(0)
    ReDim a2ndSub(0)
    ReDim a2ndAud(0)
    INIT_ARRAY(a2ndCue, grCueDef)
    INIT_ARRAY(a2ndSub, grSubDef)
    INIT_ARRAY(a2ndAud, grAudDef)
  EndIf

  gnFileNotFoundCount = 0
  ReDim gaFileNotFound(gnFileNotFoundCount)
  debugMsg(sProcName, "ArraySize(gaFileNotFound())=" + ArraySize(gaFileNotFound()))
  gbAudioFileOrPathChanged = #False
  
  While (bOK) And (gbEOF = #False)
    nextInputTag(nFileNo, nStringFormat)
    If bPrimaryFile = #False
      nCueFilePos = Loc(nFileNo)
      If IsWindow(#WIM)
        WIM_DrawProgress(nCueFilePos, nCueFileSize)
      EndIf
    EndIf
    sUpTag = UCase(gsTag)
    sUpAttributeName1 = UCase(gsTagAttributeName1)
    sUpAttributeName2 = UCase(gsTagAttributeName2)
    ; debugMsg(sProcName, "sUpTag=" + sUpTag + ", sUpAttributeName1=" + sUpAttributeName1 + ", sUpAttributeName2=" + sUpAttributeName2)
    If Left(sUpTag, 4) = "?XML"
      ; XML header
    ElseIf Left(gsTag, 1) <> "/"
      gnTagLevel + 1
      gasTagStack(gnTagLevel) = gsTag
    Else
      ; debugMsg(sProcName, "gnTagLevel=" + Str(gnTagLevel))
      If gnTagLevel < 0
        bOK = #False
        ensureSplashNotOnTop()
        sMsg = "Encountered <" + gsTag + ">" + " without matching <" + Mid(gsTag, 2) + ">"
        debugMsg(sProcName, sMsg)
        ensureSplashNotOnTop()
        scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Ok)
      ElseIf LCase(gasTagStack(gnTagLevel)) <> LCase(Mid(gsTag, 2))
        bOK = #False
        ensureSplashNotOnTop()
        sMsg = "Encountered <" + gsTag + ">" + " but expecting </" + gasTagStack(gnTagLevel) + ">"
        debugMsg(sProcName, sMsg)
        ensureSplashNotOnTop()
        scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Ok)
      Else
        gnTagLevel - 1
      EndIf
    EndIf
    
    If bOK
      If Left(sUpTag, 4) <> "?XML"
        nextInputData(nFileNo, nStringFormat)
      EndIf
      
      sTagCode = sUpTag
      nTagIndex = 0
      nNumLength = 0
      While (Right(sTagCode, 1) >= "0") And (Right(sTagCode, 1) <= "9")
        nNumLength + 1
        sTagCode = Left(sTagCode, Len(sTagCode) - 1)
      Wend
      If nNumLength > 0
        nTagIndex = Val(Right(sUpTag, nNumLength))
      EndIf
      
      ; note: this procedure ignores any tags not specifically named, so will ignore any recovery tags
      
      Select sTagCode
;{ A         
        Case "ACTIMEPROFILE"  ; ACTIMEPROFILE
          rCue\sTimeProfile[nTagIndex] = gsData
          
        ; TBC Project Changes 
        Case "ACTIMELATESTSTART"  ; ACTIMESTART
          rCue\sTimeBasedLatestStart[nTagIndex] = gsData  

        Case "ACTIMESTART"  ; ACTIMESTART
          CompilerIf #c_set_tbc_time_in_cues
            Protected sTBCTime.s
            sTBCTime = InputRequester("Cue " + rCue\sCue + " " + rCue\sCueDescr, "TBC Time (hh:mm)", gsData)
            If sTBCTime
              rCue\sTimeBasedStart[nTagIndex] = sTBCTime
            Else
              rCue\sTimeBasedStart[nTagIndex] = gsData
            EndIf
          CompilerElse
            rCue\sTimeBasedStart[nTagIndex] = gsData
          CompilerEndIf
          
        Case "ACTIVATIONMETHOD"  ; ACTIVATIONMETHOD
          rCue\nActivationMethod = encodeActivationMethod(gsData)
          If rCue\nActivationMethod & #SCS_ACMETH_EXT_BIT
            rCue\bExtAct = #True
          EndIf
          If rCue\nActivationMethod = #SCS_ACMETH_CALL_CUE
            rCue\bCallableCue = #True
          EndIf
          
        Case "ALLOWHKEYCLICK"  ; ALLOWHKEYCLICK
          rProd\bAllowHKeyClick = stringToBoolean(gsData)

        Case "ASPECT", "ASPECTRATIO" ; ASPECT, ASPECTRATIO ; deprecated as at 11.2.1
          rAud\nAspect = Val(gsData)
         
        Case "ASPECTRATIOHVAL" ; ASPECTRATIOHVAL
          rAud\nAspectRatioHVal = Val(gsData)
          
        Case "ASPECTRATIOTYPE" ; ASPECTRATIOTYPE
          rAud\nAspectRatioType = encodeAspectRatioType(gsData)
          
        Case "AUDIOFILE", "VIDEOFILE", "LIVEINPUT", "MIDIFILE" ; AUDIOFILE, VIDEOFILE, LIVEINPUT, MIDIFILE
          bInAud = #True
          ; set aud defaults
          rAud = grAudDef
          rAud\sCue = rCue\sCue       ; cue
          rAud\nSubNo = rSub\nSubNo   ; sub cue number
          rLoopInfo = grLoopInfoDef
          If grCFH\nFileVersion >= 90400
            ; de-inherit the default devices as they are for new audio cues only
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              rAud\sLogicalDev[d] = ""
              rAud\sDBLevel[d] = #SCS_INF_DBLEVEL
              rAud\fBVLevel[d] = #SCS_MINVOLUME_SINGLE
              rAud\fAudPlayBVLevel[d] = rAud\fBVLevel[d]
              rAud\fAudPlayPan[d] = rAud\fPan[d]
              rAud\fSavedBVLevel[d] = rAud\fBVLevel[d]
              rAud\fSavedPan[d] = rAud\fPan[d]
            Next d
          EndIf
          rAud\bAudTypeA = rSub\bSubTypeA
          rAud\bAudTypeF = rSub\bSubTypeF
          rAud\bAudTypeI = rSub\bSubTypeI
          rAud\bAudTypeM = rSub\bSubTypeM
          rAud\bAudTypeP = rSub\bSubTypeP
          rAud\bAudTypeAorF = rSub\bSubTypeAorF
          rAud\bAudTypeAorP = rSub\bSubTypeAorP
          rAud\bAudTypeForP = rSub\bSubTypeForP
          rAud\bLiveInput = rSub\bLiveInput
          nAudNo + 1
          rAud\nAudNo = nAudNo        ; audio track number
          nLevelPointIndex = rAud\nMaxLevelPoint
          
        Case "/AUDIOFILE", "/VIDEOFILE", "/LIVEINPUT", "/MIDIFILE" ; /AUDIOFILE, /VIDEOFILE, /LIVEINPUT, /MIDIFILE
          With rAud
            ; convert loop info pre SCS 11.7.0 (ie pre "LoopInfo" tags)
            If (\nMaxLoopInfo < 0) And (rLoopInfo\bContainsLoop)
              rAud\nMaxLoopInfo = 0
              rAud\aLoopInfo(rAud\nMaxLoopInfo) = rLoopInfo
            EndIf

            ; Sub-Cue Type - Not Live Inputs
            If rSub\bSubTypeI = #False
              Select \nVideoSource
                Case #SCS_VID_SRC_CAPTURE
                  \nFileFormat = #SCS_FILEFORMAT_CAPTURE
                Default
                  If \bAudPlaceHolder
                    \sStoredFileName = grText\sTextPlaceHolder
                  EndIf
                  \sFileName = decodeFileName(\sStoredFileName, bPrimaryFile)
                  ; debugMsg(sProcName, "\bAudPlaceHolder=" + strB(\bAudPlaceHolder) + ", \sStoredFileName=" + \sStoredFileName + ", \sFileName=" + \sFileName)
                  \nFileFormat = getFileFormat(\sFileName)
                  \sFileExt = GetExtensionPart(\sFileName)
                  If (\bAudTypeForP) And (\bAudPlaceHolder = #False)
                    If FileExists(\sFileName, #False)
                      ; grWFO\sFolder is only set to audio files because fmFioleOpener is (currently) only used for audio files
                      grWFO\sFolder = GetPathPart(\sFileName)
                    EndIf
                  EndIf
              EndSelect
            EndIf
            
            ; Sub-Cue Type - Video/Image and Capture
            If rSub\bSubTypeA
              d = 0
              \fBVLevel[d] = convertDBStringToBVLevel(\sDBLevel[d])
              \fAudPlayBVLevel[d] = \fBVLevel[d]
              If \nFadeInTime > 0
                \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
              Else
                \fCueVolNow[d] = \fBVLevel[d]
              EndIf
              \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
              \fCueTotalVolNow[d] = \fCueVolNow[d]
              \fAudPlayPan[d] = \fPan[d]
              \fCuePanNow[d] = \fPan[d]
              ; If \nAspect <> grAudDef\nAspect
                ; \nAspectRatioType = #SCS_ART_CUSTOM
                ; \nAspectRatioHVal = \nAspect
              ; EndIf
              
             ; Sub-Cue Types - Audio & Live Input
            ElseIf (rSub\bSubTypeF) Or (rSub\bSubTypeI)
              ; if no devices specified, use default devices (should only occur on pre-9.0 files)
              bDevFound = #False
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If \sLogicalDev[d]
                  bDevFound = #True
                  Break
                EndIf
              Next d
              If bDevFound = #False
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  \sLogicalDev[d] = grAudDef\sLogicalDev[d]
                  \sDBLevel[d] = grAudDef\sDBLevel[d]
                  \fBVLevel[d] = grAudDef\fBVLevel[d]
                  \fAudPlayBVLevel[d] = rAud\fBVLevel[d]
                  \fAudPlayPan[d] = rAud\fPan[d]
                Next d
              EndIf
              
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If \sLogicalDev[d]
                  \fBVLevel[d] = convertDBStringToBVLevel(\sDBLevel[d])
                  \fAudPlayBVLevel[d] = \fBVLevel[d]
                  If \nFadeInTime > 0
                    \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
                  Else
                    \fCueVolNow[d] = \fBVLevel[d]
                  EndIf
                  \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
                  \fCueTotalVolNow[d] = \fCueVolNow[d]
                  \fAudPlayPan[d] = \fPan[d]
                  \fCuePanNow[d] = \fPan[d]
                EndIf
              Next d
              
            ElseIf rSub\bSubTypeM
              ; further action deferred until after nAudId and nAudPtr set (which happens next)
              
            ElseIf rSub\bSubTypeP
              ; no further action required
              
            EndIf
            
            If \bAudTypeAorP
              For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                \fSavedBVLevel[d] = rSub\fSubMastBVLevel[d] * \fPLRelLevel / 100.0
                \fSavedPan[d] = rSub\fPLPan[d]
              Next d
            Else
              For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                \fSavedBVLevel[d] = \fBVLevel[d]
                \fSavedPan[d] = \fPan[d]
              Next d
            EndIf
              
            \nCurrFadeInTime = \nFadeInTime
            \nCurrFadeOutTime = \nFadeOutTime
            
          EndWith
          
          nAudPtr + 1
          If bPrimaryFile
            checkMaxAud(nAudPtr)
            aAud(nAudPtr) = rAud
            If aAud(nAudPtr)\nAudId = -1
              gnUniqueAudId + 1
              aAud(nAudPtr)\nAudId = gnUniqueAudId
            EndIf
          Else
            If ArraySize(a2ndAud()) < nAudPtr
              REDIM_ARRAY(a2ndAud, nAudPtr+20, grAudDef, "a2ndAud()")
            EndIf
            a2ndAud(nAudPtr) = rAud
            If a2ndAud(nAudPtr)\nAudId = -1
              gnUniqueAudId + 1
              a2ndAud(nAudPtr)\nAudId = gnUniqueAudId
            EndIf
          EndIf
          
          If rSub\bSubTypeM
            rSub\aCtrlSend[nCtrlSendIndex]\nAudPtr = nAudPtr
          EndIf
          
          If bPrimaryFile
            ; debugMsg(sProcName, "aAud(" + nAudPtr + ")\sFileName=" + aAud(nAudPtr)\sFileName)
            ; following test n length > 0 is because the filename may be blank if we are reading the recovery file
            If Trim(aAud(nAudPtr)\sFileName)
              ; debugMsg(sProcName, "calling FileExists()")
              If FileExists(aAud(nAudPtr)\sFileName) = #False
                debugMsg(sProcName, "FileExists() returned #False")
                If (rCue\bCueEnabled) And (rSub\bSubEnabled)
                  ; only record info about missing files if the item is enabled
                  gnFileNotFoundCount + 1
                  If gnFileNotFoundCount > ArraySize(gaFileNotFound())
                    ReDim gaFileNotFound(gnFileNotFoundCount + 10)
                    ; debugMsg(sProcName, "ArraySize(gaFileNotFound())=" + ArraySize(gaFileNotFound()))
                  EndIf
                  With gaFileNotFound(gnFileNotFoundCount)
                    \sFileName = aAud(nAudPtr)\sFileName
                    \nAudPtr = nAudPtr
                    \sNewFileName = ""
                    \bFound = #False
                  EndWith
                EndIf
              EndIf
              aAud(nAudPtr)\sFileExt = GetExtensionPart(aAud(nAudPtr)\sFileName)
              aAud(nAudPtr)\nFileFormat = getFileFormat(aAud(nAudPtr)\sFileName)
              If aAud(nAudPtr)\nFileFormat = #SCS_FILEFORMAT_AUDIO
                getInfoAboutFile(aAud(nAudPtr)\sFileName) ; call getInfoAboutFile() as it will call analyzeWavFile() etc ; Changed (removed trace=true) 5Oct2022 11.9.6
                aAud(nAudPtr)\nFileDuration = grInfoAboutFile\nFileDuration
                aAud(nAudPtr)\nFileChannels = grInfoAboutFile\nFileChannels
                aAud(nAudPtr)\qFileBytes = grInfoAboutFile\qFileBytes
                aAud(nAudPtr)\qFileBytesForTenSecs = grInfoAboutFile\qFileBytesForTenSecs
              EndIf
            EndIf
            ; debugMsg(sProcName, "calling removeNonExistentDevsFromLvlPts(" + nAudPtr + ")")
            removeNonExistentDevsFromLvlPts(nAudPtr)
            ; debugMsg(sProcName, "calling setDerivedAudFields(" + nAudPtr + ")")
            setDerivedAudFields(nAudPtr)
            saveLastPicInfo(nAudPtr)
            ; listLevelPoints(nAudPtr)
            
          Else
            debugMsg(sProcName, "a2ndAud(" + nAudPtr + ")\sFileName=" + a2ndAud(nAudPtr)\sFileName)
            If FileSize(a2ndAud(nAudPtr)\sFileName) < 0
              gnFileNotFoundCount = gnFileNotFoundCount + 1
              If gnFileNotFoundCount > ArraySize(gaFileNotFound())
                ReDim gaFileNotFound(gnFileNotFoundCount + 10)
                ; debugMsg(sProcName, "ArraySize(gaFileNotFound())=" + ArraySize(gaFileNotFound()))
              EndIf
              With gaFileNotFound(gnFileNotFoundCount)
                \sFileName = a2ndAud(nAudPtr)\sFileName
                \nAudPtr = nAudPtr
                \sNewFileName = ""
                \bFound = #False
              EndWith
            EndIf
          EndIf
          
          bInAud = #False
          
        Case "AUDNORMINFO" ; AUDNORMINFO
          rAud\fAudNormIntegrated = ValF(StringField(gsData, 1, ";"))
          rAud\fAudNormPeak = ValF(StringField(gsData, 2, ";"))
          rAud\fAudNormTruePeak = ValF(StringField(gsData, 3, ";"))
          rAud\bAudNormSet = #True
          
        Case "AUDPLACEHOLDER"  ; AUDPLACEHOLDER
          rAud\bAudPlaceHolder = stringToBoolean(gsData)
          
        Case "AUDTEMPOETCACTION" ; AUDTEMPOETCACTION
          rAud\nAudTempoEtcAction = encodeAFAction(gsData)
          
        Case "AUDTEMPOETCVALUE" ; AUDTEMPOETCVALUE
          rAud\fAudTempoEtcValue = ValF(gsData)
          
        Case "AUTOACTIVATEAUDNO"  ; AUTOACTIVATEAUDNO
          rCue\nAutoActAudNo = Val(gsData)
          
        Case "AUTOACTIVATECUE"  ; AUTOACTIVATECUE
          rCue\sAutoActCue = gsData
          
        Case "AUTOACTIVATECUETYPE"  ; AUTOACTIVATECUETYPE
          rCue\nAutoActCueSelType = encodeAutoActCueSelType(gsData)
          
        Case "AUTOACTIVATEMARKER" ; AUTOACTIVATEMARKER
          rCue\sAutoActCueMarkerName = gsData
          
        Case "AUTOACTIVATEPOSN"  ; AUTOACTIVATEPOSN
          rCue\nAutoActPosn = encodeAutoActPosn(gsData)
          ; added (temporarily?) 3Aug2019 11.8.1.3af as the 'position' OCM has been replaced by the OCM 'method'
          If rCue\nAutoActPosn = #SCS_ACPOSN_OCM
            rCue\nActivationMethod = #SCS_ACMETH_OCM
          EndIf
          If bPrimaryFile
            If rCue\nAutoActPosn <> #SCS_ACPOSN_OCM
              grEditMem\nLastAutoActPosn = rCue\nAutoActPosn
            EndIf
          EndIf
          ; end added (temporarily?) 3Aug2019 11.8.1.3af
          
        Case "AUTOACTIVATESUBNO"  ; AUTOACTIVATESUBNO
          rCue\nAutoActSubNo = Val(gsData)
          
        Case "AUTOACTIVATETIME"  ; AUTOACTIVATETIME
          rCue\nAutoActTime = Val(gsData)
;}
;{ B          
        Case "BUILD"
          rProd\nFileBuild = Val(gsData)
          
;}
;{ C          
         Case "CALLABLECUEPARAMS"
          rCue\sCallableCueParams = gsData
          
        Case "CALLCUE"   ; CALLCUE
          rSub\sCallCue = gsData
          
        Case "CALLCUEACTION"   ; CALLCUEACTION
          rSub\nCallCueAction = encodeCallCueAction(gsData)
          grWQQ\nLastCallCueAction = rSub\nCallCueAction
          
        Case "CALLCUEPARAMS"   ; CALLCUEPARAMS
          rSub\sCallCueParams = gsData
          
        Case "CMITEMDESC"
          rSub\aCtrlSend[nCtrlSendIndex]\sCSItemDesc = gsData
          
        Case "CMLOGICALDEV", "RS232DEV"  ; "RS232DEV" = SCS 10; "CMLOGICALDEV" = SCS 11
          nCtrlSendDevType = getDevTypeFromLogicalDev(@rProd, #SCS_DEVGRP_CTRL_SEND, gsData)
          ; debugMsg(sProcName, "nCtrlSendDevType=" + decodeDevType(nCtrlSendDevType) + ", rProd\aCtrlSendLogicalDevs(0)\sLogicalDev=" + rProd\aCtrlSendLogicalDevs(0)\sLogicalDev)
          rSub\aCtrlSend[nCtrlSendIndex]\nDevType = nCtrlSendDevType
          If (nCtrlSendDevType = #SCS_DEVTYPE_CS_RS232_OUT) And (grCFH\nFileVersion < 110000)
            rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev = convertSerialPortNameToPB(gsData)
          Else
            rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev = gsData
          EndIf
          
        Case "CONTINUOUS"  ; CONTINUOUS
          rAud\bContinuous = stringToBoolean(gsData)
          rAud\bDoContinuous = rAud\bContinuous
          If rAud\bContinuous
            rAud\nEndAt = grAudDef\nEndAt
          EndIf
          
        Case "CONTROLMESSAGE"  ; CONTROLMESSAGE
          nCtrlSendIndex + 1
          rSub\aCtrlSend[nCtrlSendIndex] = grCtrlSendDef
          
        Case "/CONTROLMESSAGE"  ; /CONTROLMESSAGE
          If rSub\aCtrlSend[nCtrlSendIndex]\nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
            rSub\aCtrlSend[nCtrlSendIndex]\nOSCCmdType = encodeOSCCmdType(rSub\aCtrlSend[nCtrlSendIndex]\sOSCCmdType)
            If bPrimaryFile
              grEditMem\nLastOSCCmdType = rSub\aCtrlSend[nCtrlSendIndex]\nOSCCmdType
            EndIf
          EndIf
          If bPrimaryFile
            grEditMem\sLastCtrlSendLogicalDev = rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev
            grEditMem\nLastCtrlSendDevType = rSub\aCtrlSend[nCtrlSendIndex]\nDevType
            Select rSub\aCtrlSend[nCtrlSendIndex]\nDevType
              Case #SCS_DEVTYPE_CS_HTTP_REQUEST
                grEditMem\sLastHTItemDesc = rSub\aCtrlSend[nCtrlSendIndex]\sCSItemDesc
              Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
                If rSub\aCtrlSend[nCtrlSendIndex]\nMSMsgType <> #SCS_MSGTYPE_NONE And rSub\aCtrlSend[nCtrlSendIndex]\nMSMsgType <> #SCS_MSGTYPE_SCRIBBLE_STRIP
                  grEditMem\nLastMsgType = rSub\aCtrlSend[nCtrlSendIndex]\nMSMsgType
                  ; debugMsg0(sProcName, "grEditMem\nLastMsgType=" + decodeMsgType(grEditMem\nLastMsgType))
                  nMSMsgType = grEditMem\nLastMsgType
                  grEditMem\aLastMsg(nMSMsgType)\sLastMSItemDesc = rSub\aCtrlSend[nCtrlSendIndex]\sCSItemDesc
                  If nMSMsgType < #SCS_MSGTYPE_DUMMY_LAST And nMSMsgType <> #SCS_MSGTYPE_SCRIBBLE_STRIP
                    grEditMem\aLastMsg(nMSMsgType)\nLastMSChannel = rSub\aCtrlSend[nCtrlSendIndex]\nMSChannel
                    grEditMem\aLastMsg(nMSMsgType)\nLastMSParam1 = rSub\aCtrlSend[nCtrlSendIndex]\nMSParam1
                    grEditMem\aLastMsg(nMSMsgType)\nLastMSParam2 = rSub\aCtrlSend[nCtrlSendIndex]\nMSParam2
                    grEditMem\aLastMsg(nMSMsgType)\nLastMSParam3 = rSub\aCtrlSend[nCtrlSendIndex]\nMSParam3
                    grEditMem\aLastMsg(nMSMsgType)\nLastMSParam4 = rSub\aCtrlSend[nCtrlSendIndex]\nMSParam4
                    grEditMem\aLastMsg(nMSMsgType)\sLastMSParam1Info = rSub\aCtrlSend[nCtrlSendIndex]\sMSParam1Info
                    grEditMem\aLastMsg(nMSMsgType)\sLastMSParam2Info = rSub\aCtrlSend[nCtrlSendIndex]\sMSParam2Info
                    grEditMem\aLastMsg(nMSMsgType)\sLastMSParam3Info = rSub\aCtrlSend[nCtrlSendIndex]\sMSParam3Info
                    grEditMem\aLastMsg(nMSMsgType)\sLastMSParam4Info = rSub\aCtrlSend[nCtrlSendIndex]\sMSParam4Info
                  EndIf
                EndIf
              Case #SCS_DEVTYPE_CS_NETWORK_OUT
                grEditMem\sLastNWItemDesc = rSub\aCtrlSend[nCtrlSendIndex]\sCSItemDesc
              Case #SCS_DEVTYPE_CS_RS232_OUT
                grEditMem\sLastRSItemDesc = rSub\aCtrlSend[nCtrlSendIndex]\sCSItemDesc
            EndSelect
          EndIf
          
        Case "CONTROLLER"   ; CONTROLLER
          rCtrlSetup\nController = encodeController(gsData)
          ; set the default configuration for the selected controller (may be overridden "CTRLCONFIG" setting)
          Select rCtrlSetup\nController
            Case #SCS_CTRL_BCF2000
              rCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_A
            Case #SCS_CTRL_BCR2000
              rCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_A
            Case #SCS_CTRL_NK2
              rCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_A
          EndSelect
          
        Case "CSDMXALLFADE"
          ; convert old DMX control send cues to lighting cues
          bConvertCtrlSendToLighting = #True
          If stringToBoolean(gsData)
            rSub\nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
          EndIf
          rSub\sSubType = "K"
          rSub\bSubTypeK = #True
          rSub\bSubTypeM = #False
          rSub\sLTLogicalDev = rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev ; convert old DMX control send cues to lighting cues
          rSub\nLTDevType = #SCS_DEVTYPE_LT_DMX_OUT
          
        Case "CSDMXALLFADETIME"
          ; convert old DMX control send cues to lighting cues
          bConvertCtrlSendToLighting = #True
          rSub\nLTFIFadeOutOthersUserTime = Val(gsData)
          rSub\sSubType = "K"
          rSub\bSubTypeK = #True
          rSub\bSubTypeM = #False
          rSub\sLTLogicalDev = rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev ; convert old DMX control send cues to lighting cues
          rSub\nLTDevType = #SCS_DEVTYPE_LT_DMX_OUT
          
        Case "CSDMXCHANNELS", "CSDMXCHANNEL"
          ; obsolete as a 'saved' field but retained for converting old-format DMX control send cues
          bConvertCtrlSendToLighting = #True
          rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\sDMXChannels = gsData
          
        Case "CSDMXVALUE"
          ; obsolete as a 'saved' field but retained for converting old-format DMX control send cues
          bConvertCtrlSendToLighting = #True
          rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\nDMXValue = ValD(gsData)
          
        Case "CSDMXFADE", "LTDMXFADEOUTOTHERS"
          ; obsolete but retained for converting old-format DMX control send cues
          bConvertCtrlSendToLighting = #True
          rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\bDMXFade = stringToBoolean(gsData)
          
        Case "CSDMXFADETIME", "LTDMXFADEOUTOTHERSETIME"
          ; obsolete as a 'saved' field but retained for converting old-format DMX control send cues
          bConvertCtrlSendToLighting = #True
          nDMXFadeTime = Val(gsData)
          
        Case "CSDMXITEM"
          ; obsolete as a 'saved' field but retained for converting old-format DMX control send cues
          If rSub\bSubTypeM
            bConvertCtrlSendToLighting = #True
            rSub\sSubType = "K"
            rSub\bSubTypeK = #True
            rSub\bSubTypeM = #False
            rSub\sLTLogicalDev = rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev ; convert old DMX control send cues to lighting cues
            rSub\nLTDevType = #SCS_DEVTYPE_LT_DMX_OUT
          EndIf
          nDMXSendItemIndex + 1
          If ArraySize(rSub\aChaseStep(0)\aDMXSendItem()) < nDMXSendItemIndex
            ReDim rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex+5)
          EndIf
          rSub\aChaseStep(0)\nDMXSendItemCount + 1
          bDMXItemFound = #True ; indicates this obsolete format found - used in processing /CONTROLMESSAGE
          
        Case "/CSDMXITEM"
          If (bConvertCtrlSendToLighting) And (nDMXSendItemIndex >= 0)
            sTmp = rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\sDMXChannels + "@d" + Str(rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\nDMXValue)
            rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\sDMXItemStr = sTmp
            DMX_unpackDMXSendItemStr(@rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex), @rProd, rSub\sLTLogicalDev)
          EndIf
          
        Case "CSDMXITEMSTR"
          ; convert old DMX control send cues to lighting cues
          bConvertCtrlSendToLighting = #True
          If rSub\bSubTypeM
            bConvertCtrlSendToLighting = #True
            rSub\sSubType = "K"
            rSub\bSubTypeK = #True
            rSub\bSubTypeM = #False
            rSub\sLTLogicalDev = rSub\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev ; convert old DMX control send cues to lighting cues
            rSub\nLTDevType = #SCS_DEVTYPE_LT_DMX_OUT
          EndIf
          nDMXSendItemIndex + 1
          If ArraySize(rSub\aChaseStep(0)\aDMXSendItem()) < nDMXSendItemIndex
            ReDim rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex+5)
          EndIf
          rSub\aChaseStep(0)\nDMXSendItemCount + 1
          rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\sDMXItemStr = gsData
          DMX_unpackDMXSendItemStr(@rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex), @rProd, rSub\sLTLogicalDev)
          
        Case "CSDMXVALUE"
          ; obsolete as a 'saved' field but retained for converting old-format DMX control send cues
          bConvertCtrlSendToLighting = #True
          rSub\aChaseStep(0)\aDMXSendItem(nDMXSendItemIndex)\nDMXValue = ValD(gsData)
          
        Case "CTRLCONFIG"   ; CTRLCONFIG
          rCtrlSetup\nCtrlConfig = encodeCtrlConfig(gsData)
          
        Case "CTRLINCLUDEGOETC" ; CTRLINCLUDEGOETC
          rCtrlSetup\bIncludeGoEtc = stringToBoolean(gsData)
          
        Case "CTRLMIDIIN"   ; CTRLMIDIIN
          rCtrlSetup\sCtrlMidiInPort = gsData
          
        Case "CTRLMIDIOUT"   ; CTRLMIDIOUT
          rCtrlSetup\sCtrlMidiOutPort = gsData
          
        Case "CTRLSETUP"  ; CTRLSETUP
          rCtrlSetup = grCtrlSetupDef
          
        Case "/CTRLSETUP"  ; /CTRLSETUP
          If bPrimaryFile
            ; Changed 25Jun2022 11.9.4
            setBooleanUseExternalController(@rCtrlSetup)
            grCtrlSetup = rCtrlSetup
            debugMsg(sProcName, "grCtrlSetup\bUseExternalController=" + strB(grCtrlSetup\bUseExternalController))
          EndIf
          
        Case "CUE"  ; CUE
          ; set cue defaults
          rCue = grCueDef
          nSubNo = 0
          nAudNo = 0
          rSub = grSubDef
          rAud = grAudDef
          nSubPtrAtCueStart = nSubPtr
          nAudPtrAtCueStart = nAudPtr
          
        Case "/CUE"  ; /CUE
          With rCue
            \nActivationMethodReqd = \nActivationMethod
            If (\nAutoActTime < 0) And ((\nActivationMethod = #SCS_ACMETH_AUTO) Or (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF))
              \nAutoActTime = 0
            EndIf
            ; Added 18Oct2024 11.10.6ar following a bug reported by Kenneth Zinkl
            ; If the user has not set a time against all the time profile entries when using an earlier version of SCS, and then subsequently changed the start time for a cue's time profile,
            ; then SCS would create a duplicate entry for that time profile.
            ; The code below looks for any duplicate time profile settings and removes the duplicates. This should only occur for cue files saved pre SCS 11.10.6ar.
            ; Changes have also been made in fmEditCue to stop the error occurring.
            Protected n1, n2, n3
            For n1 = 0 To #SCS_MAX_TIME_PROFILE
              ; debugMsg(sProcName, ">>>>> n1=" + n1 + ", \sTimeProfile[" + n1 + "]=" + #DQUOTE$ + \sTimeProfile[n1] + #DQUOTE$)
              If \sTimeProfile[n1]
                For n2 = 0 To (n1 - 1)
                  If \sTimeProfile[n2] = \sTimeProfile[n1]
                    ; duplicated entry, so remove the duplicate
                    ; debugMsg(sProcName, "DUPLICATE: \sTimeProfile[" + n2 + "]=" + #DQUOTE$ + \sTimeProfile[n2] + #DQUOTE$)
                    For n3 = n1 To (#SCS_MAX_TIME_PROFILE - 1)
                      \sTimeProfile[n3] = \sTimeProfile[n3 + 1]
                      \sTimeBasedStart[n3] = \sTimeBasedStart[n3 + 1]
                      \sTimeBasedLatestStart[n3] = \sTimeBasedLatestStart[n3 + 1]
                      ; debugMsg(sProcName, "\sTimeProfile[" + n3 + "] now = " +  #DQUOTE$ + \sTimeProfile[n3] + #DQUOTE$ + ", \sTimeBasedStart[" + n3 + "]=" + #DQUOTE$ + \sTimeBasedStart[n3] + #DQUOTE$)
                    Next n3
                    n3 = #SCS_MAX_TIME_PROFILE
                    \sTimeProfile[n3] = ""
                    \sTimeBasedStart[n3] = ""
                    \sTimeBasedLatestStart[n3] = ""
                    ; debugMsg(sProcName, "\sTimeProfile[" + n3 + "] now = " +  #DQUOTE$ + \sTimeProfile[n3] + #DQUOTE$ + ", \sTimeBasedStart[" + n3 + "]=" + #DQUOTE$ + \sTimeBasedStart[n3] + #DQUOTE$)
                    n2 - 1 ; step back because we have just removed a duplicate
                  EndIf
                Next n2
              EndIf
            Next n1
            ; End added 18Oct2024 11.10.6ar
          EndWith
          nCuePtr + 1
          If bPrimaryFile
            If checkMaxCue(nCuePtr) = #False
              ; cue limit exceeded - ignore this and remaining cues
              ; rollback nCuePtr, nSubPtr and nAudPtr to values prior to this cue
              nCuePtr - 1
              nSubPtr = nSubPtrAtCueStart
              nAudPtr = nAudPtrAtCueStart
              Break
            EndIf
            ; debugMsg(sProcName, "Storing cue " + nCuePtr + " (" + rCue\sCue + ")")
            aCue(nCuePtr) = rCue
            If aCue(nCuePtr)\nCueId = -1
              gnUniqueCueId + 1
              aCue(nCuePtr)\nCueId = gnUniqueCueId
            EndIf
          Else
            If ArraySize(a2ndCue()) < nCuePtr
              REDIM_ARRAY(a2ndCue, nCuePtr+20, grCueDef, "a2ndCue()")
            EndIf
            a2ndCue(nCuePtr) = rCue
            If a2ndCue(nCuePtr)\nCueId = -1
              gnUniqueCueId + 1
              a2ndCue(nCuePtr)\nCueId = gnUniqueCueId
            EndIf
          EndIf
          
        Case "CUEDURATION"  ; CUEDURATION (should only be present for picture cues in SCS 10 files, but in SCS 11 we use the EndAt field for the duration of picture cues)
          rAud\nEndAt = Val(gsData)
          
        Case "_CUEFILE_"  ; _CUEFILE_    ; original cue file stored in recovery file (ignore tag if not recovering)
          If gbRecovering
            gsCueFile = gsData
            gsCueFolder = GetPathPart(gsCueFile)
          EndIf
          
        Case "CUEGAPLESS"  ; CUEGAPLESS
          rCue\bCueGaplessIfPossible = stringToBoolean(gsData)
          
        Case "CUEID"  ; CUEID
          rCue\sCue = gsData
          rCue\sValidatedCue = rCue\sCue
          
        Case "CUELABELINCREMENT"  ; CUELABELINCREMENT
          rProd\nCueLabelIncrement = Val(gsData)
          
        Case "CUEMARKER" ; CUEMARKER
          rAud\nMaxCueMarker + 1
          ReDim rAud\aCueMarker(rAud\nMaxCueMarker)
          gnUniqueCueMarkerId + 1
          rAud\aCueMarker(rAud\nMaxCueMarker)\nCueMarkerId = gnUniqueCueMarkerId
          rAud\aCueMarker(rAud\nMaxCueMarker)\sCueMarkerName = gsTagAttributeValue1
          rAud\aCueMarker(rAud\nMaxCueMarker)\nCueMarkerPosition = 0 ; will be populated by "MARKERPOS"
          rAud\aCueMarker(rAud\nMaxCueMarker)\nCueMarkerType = #SCS_CMT_CM ; "SCS Cue Marker"
          
        Case "CUEPOSTIMEOFFSET" ; CUEPOSTIMEOFFSET
          rAud\nCuePosTimeOffset = Val(gsData)
          
        Case "CUETYPE"  ; CUETYPE    ; CUETYPE used in SCS 8 only (multiple types per cue type, of types F,S,L,M only)
          rSub\sSubType = gsData
          
;}
;{ D          
        Case "DBLEVEL"  ; DBLEVEL
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          If ValF(gsData) < ValF(grLevels\sMinDBLevel)
            gsData = grLevels\sMinDBLevel
          EndIf
          rAud\sDBLevel[nTagIndex] = gsData
          rAud\fSavedBVLevel[nTagIndex] = convertDBStringToBVLevel(gsData)
          rAud\fBVLevel[nTagIndex] = rAud\fSavedBVLevel[nTagIndex]
          ; debugMsg(sProcName, "gsData=" + gsData + ", rAud\sDBLevel[" + nTagIndex + "]=" + rAud\sDBLevel[nTagIndex] + ", rAud\fBVLevel[" + nTagIndex + "]=" + formatLevel(rAud\fBVLevel[nTagIndex]))
          
        Case "DBLEVELCHANGEINCREMENT"  ; DBLEVELCHANGEINCREMENT
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          rProd\sDBLevelChangeIncrement = gsData
          ; debugMsg(sProcName, "rProd\sDBLevelChangeIncrement=" + rProd\sDBLevelChangeIncrement)
          
        Case "DBTRIM"  ; DBTRIM
          rAud\sDBTrim[nTagIndex] = gsData
          rAud\fTrimFactor[nTagIndex] = dbTrimStringToFactor(gsData)
          
        Case "DEFAULTTIMEPROFILE"  ; DEFAULTTIMEPROFILE
          rProd\sDefaultTimeProfile = gsData
          
        Case "DEFAULTTIMEPROFILEFORDAY"  ; DEFAULTTIMEPROFILEFORDAY
          rProd\sDefaultTimeProfileForDay[nTagIndex] = gsData
          
        Case "DEFCHASESPEED"   ; DEFCHASESPEED
          rProd\nDefChaseSpeed = Val(gsData)
          
        Case "DEFDES"  ; DEFDES
          rCue\bDefaultCueDescrMayBeSet = stringToBoolean(gsData)
          
        Case "DEFDISPLAYTIMEA"  ; DEFDISPLAYTIMEA
          rProd\nDefDisplayTimeA = Val(gsData)
          
        Case "DEFDMXFADETIME"   ; DEFDMXFADETIME
          rProd\nDefDMXFadeTime = Val(gsData)
          
        Case "DEFFADEINTIME"  ; DEFFADEINTIME
          rProd\nDefFadeInTime = Val(gsData)
          
        Case "DEFFADEINTIMEA"  ; DEFFADEINTIMEA
          rProd\nDefFadeInTimeA = Val(gsData)
          
        Case "DEFFADEINTIMEI"  ; DEFFADEINTIMEI
          rProd\nDefFadeInTimeI = Val(gsData)
          
        Case "DEFFADEOUTTIME"  ; DEFFADEOUTTIME
          rProd\nDefFadeOutTime = Val(gsData)
          
        Case "DEFFADEOUTTIMEA"  ; DEFFADEOUTTIMEA
          rProd\nDefFadeOutTimeA = Val(gsData)
          
        Case "DEFFADEOUTTIMEI"  ; DEFFADEOUTTIMEI
          rProd\nDefFadeOutTimeI = Val(gsData)
          
        Case "DEFLOOPXFADETIME"  ; DEFLOOPXFADETIME
          rProd\nDefLoopXFadeTime = Val(gsData)
          
        Case "DEFOUTPUTSCREEN"  ; DEFOUTPUTSCREEN
          rProd\nDefOutputScreen = Val(gsData)
          
        Case "DEFPAUSEATENDA"  ; DEFPAUSEATENDA
          rProd\bDefPauseAtEndA = stringToBoolean(gsData)
          
        Case "DEFREPEATA"  ; DEFREPEATA
          rProd\bDefRepeatA = stringToBoolean(gsData)
          
        Case "DEFSFRACTION"  ; DEFSFRACTION
          rProd\nDefSFRAction = encodeSFRAction(gsData)
          
        Case "DEFSFRTIMEOVERRIDE"  ; DEFSFRTIMEOVERRIDE
          rProd\nDefSFRTimeOverride = Val(gsData)
          
        Case "DEFSUBDES"  ; DEFSUBDES
          rSub\bDefaultSubDescrMayBeSet = stringToBoolean(gsData)
          
        Case "DESCRIPTION"  ; DESCRIPTION
          rCue\sCueDescr = gsData
          rCue\sValidatedDescr = rCue\sCueDescr
          
        Case "DEVICE"
          rAud\sVideoCaptureLogicalDevice = gsData
          
        Case "DFLTDBLEVEL"  ; DFLTDBLEVEL
          ; nTagIndex present for SCS11 cue files - not present for older cue files
          If nNumLength > 0
            nDefaultDevPtr = nTagIndex
          EndIf
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          If ValF(gsData) < ValF(grLevels\sMinDBLevel)
            gsData = grLevels\sMinDBLevel
          EndIf
          ; debugMsg(sProcName, "sTagCode=" + sTagCode + ", nTagIndex=" + nTagIndex + ", nDefaultDevPtr=" + nDefaultDevPtr + ", gsData=" + gsData)
          If nDefaultDevPtr >= 0
            If gsData
              rProd\aAudioLogicalDevs(nDefaultDevPtr)\sDfltDBLevel = gsData
              rProd\aAudioLogicalDevs(nDefaultDevPtr)\fDfltBVLevel = convertDBStringToBVLevel(gsData)
            EndIf
          EndIf
          
        Case "DFLTDBTRIM"  ; DFLTDBTRIM
          ; nTagIndex present for SCS11 cue files - not present for older cue files
          If nNumLength > 0
            nDefaultDevPtr = nTagIndex
          EndIf
          If nDefaultDevPtr >= 0
            If gsData
              rProd\aAudioLogicalDevs(nDefaultDevPtr)\sDfltDBTrim = gsData
              rProd\aAudioLogicalDevs(nDefaultDevPtr)\fDfltTrimFactor = dbTrimStringToFactor(gsData)
            EndIf
          EndIf
          
        Case "DFLTLOGICALDEV"  ; DFLTLOGICALDEV
          For n = 0 To rProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD
            If rProd\aAudioLogicalDevs(n)\sLogicalDev = gsData
              nDefaultDevPtr = n
              rProd\aAudioLogicalDevs(nDefaultDevPtr)\bAutoInclude = #True
              Break
            EndIf
          Next n
          
        Case "DFLTPAN"  ; DFLTPAN
          ; nTagIndex present for SCS11 cue files - not present for older cue files
          If nNumLength > 0
            nDefaultDevPtr = nTagIndex
          EndIf
          If nDefaultDevPtr >= 0
            If gsData
              rProd\aAudioLogicalDevs(nDefaultDevPtr)\fDfltPan = panStringToSingle(gsData)
            EndIf
          EndIf
          
        Case "DFLTVIDAUDDBLEVEL"  ; DFLTVIDAUDDBLEVEL
          nDefaultDevPtr = nTagIndex
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          If ValF(gsData) < ValF(grLevels\sMinDBLevel)
            gsData = grLevels\sMinDBLevel
          EndIf
          debugMsg(sProcName, "sTagCode=" + sTagCode + ", nTagIndex=" + nTagIndex + ", nDefaultDevPtr=" + nDefaultDevPtr + ", gsData=" + gsData)
          If nDefaultDevPtr >= 0
            If gsData
              rProd\aVidAudLogicalDevs(nDefaultDevPtr)\sDfltDBLevel = gsData
              rProd\aVidAudLogicalDevs(nDefaultDevPtr)\fDfltBVLevel = convertDBStringToBVLevel(gsData)
            EndIf
          EndIf
          
        Case "DFLTVIDAUDDBTRIM"  ; DFLTVIDAUDDBTRIM
          nDefaultDevPtr = nTagIndex
          If nDefaultDevPtr >= 0
            If gsData
              rProd\aVidAudLogicalDevs(nDefaultDevPtr)\sDfltDBTrim = gsData
              rProd\aVidAudLogicalDevs(nDefaultDevPtr)\fDfltTrimFactor = dbTrimStringToFactor(gsData)
            EndIf
          EndIf
          
        Case "DFLTVIDAUDPAN"  ; DFLTVIDAUDPAN
          nDefaultDevPtr = nTagIndex
          If nDefaultDevPtr >= 0
            If gsData
              rProd\aVidAudLogicalDevs(nDefaultDevPtr)\fDfltPan = panStringToSingle(gsData)
            EndIf
          EndIf
          
        Case "DIMENSIONS"  ; DIMENSIONS
          ; will be cleared out later if FileProps has changed
          n = FindString(gsData, "x", 1)
          If n > 1
            rFileData\nSourceWidth = Val(Left(gsData, n - 1))
            rFileData\nSourceHeight = Val(Mid(gsData, n + 1))
            If (rFileData\nSourceWidth = 0) Or (rFileData\nSourceHeight = 0)
              rFileData\nSourceWidth = grFileDataDef\nSourceWidth
              rFileData\nSourceHeight = grFileDataDef\nSourceHeight
            EndIf
          EndIf
          
        Case "DMXMASTERFADER"  ; DMXMASTERFADER
            rProd\nDMXMasterFaderValue = Val(gsData) ; 0-255 (255 = no fade)
          
        Case "DONOTCALCCUESTARTVALUES"  ; DONOTCALCCUESTARTVALUES
          rProd\bDoNotCalcCueStartValues = stringToBoolean(gsData)
          
 ;}
;{ E          
        Case "EDACTION"   ; EDACTION
          rEnableDisable\nAction = encodeEnaDisAction(gsData)
          
        Case "EDCUEFIRST"   ; EDCUEFIRST
          rEnableDisable\sFirstCue = gsData
          ; debugMsg(sProcName, "EDCUEFIRST: rEnableDisable\sFirstCue=" + rEnableDisable\sFirstCue)
          
        Case "EDCUEITEM"   ; EDCUEITEM
          rEnableDisable = grEnableDisableDef
          
        Case "/EDCUEITEM"   ; /EDCUEITEM
          If nEnableDisableIndex < #SCS_MAX_ENABLE_DISABLE
            nEnableDisableIndex + 1
            rSub\aEnableDisable[nEnableDisableIndex] = rEnableDisable
          EndIf
          
        Case "EDCUELAST"   ; EDCUELAST
          rEnableDisable\sLastCue = gsData
          ; debugMsg(sProcName, "EDCUELAST: rEnableDisable\sLastCue=" + rEnableDisable\sLastCue)
          
        Case "ENABLED"  ; ENABLED
          rCue\bCueEnabled = stringToBoolean(gsData)
          rCue\bCueCurrentlyEnabled = rCue\bCueEnabled
          
        Case "ENABLEMIDICUE"  ; ENABLEMIDICUE
          rProd\bEnableMidiCue = stringToBoolean(gsData)
          
        Case "ENDAT"  ; ENDAT
          rAud\nEndAt = Val(gsData)
          
        Case "ENDATCPNAME"  ; ENDATCPNAME
          rAud\sEndAtCPName = gsData
          
        Case "ENDATSAMPLEPOS"  ; ENDATSAMPLEPOS
          rAud\qEndAtSamplePos = Val(gsData)
          
        Case "EXCLUSIVE"  ; EXCLUSIVE
          rCue\bExclusiveCue = stringToBoolean(gsData)
          
        Case "EXTFADERCC" ; EXTFADERCC
          rCue\nExtFaderCC = Val(gsData)
          
;}
;{ F          
         Case "FADEINCPNAME" ; FADEINCPNAME
          rAud\sFadeInCPName = gsData
          
        Case "FADEINENTRYTYPE"  ; FADEINENTRYTYPE
          rAud\nFadeInEntryType = encodeFadeEntryType(gsData)
          
        Case "FADEINMSPOS"  ; FADEINMSPOS
          rAud\nFadeInMSPos = Val(gsData)
          
        Case "FADEINSAMPLEPOS"  ; FADEINSAMPLEPOS
          rAud\qFadeInSamplePos = Val(gsData)
          
        Case "FADEINTIME"  ; FADEINTIME
          If rSub\bSubTypeA
            rSub\nPLFadeInTime = Val(gsData)
          Else
            macReadNumericOrStringParam(gsData, rAud\sFadeInTime, rAud\nFadeInTime, grAudDef\nFadeInTime, #False)
            ; Macro macReadNumericOrStringParam populates \sFadeInTime and \nFadeInTime from the value in gsData
            ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
            If rAud\sFadeInTime
              ; Indicates a callable cue parameter is in the 'fade-in time'
              rAud\nFadeInTime = 1 ; 'dummy' set of fade-in time (one millisecond) so that elsewhere in the program SCS will recognise that there is a fade-in time
                                   ; and so will create a 'fade-in' level point
            EndIf
            ; debugMsg(sProcName, "gsData=" + gsData + ", rAud\sFadeInTime=" + rAud\sFadeInTime + ", rAud\nFadeInTime=" + rAud\nFadeInTime)
          EndIf
          
        Case "FADEINTYPE"  ; FADEINTYPE
          If gsData = "fader"
            gsData = "std"
          EndIf
          rAud\nFadeInType = encodeFadeType(gsData)
          
        Case "FADEOUTCPNAME" ; FADEOUTCPNAME
          rAud\sFadeOutCPName = gsData
          
        Case "FADEOUTENTRYTYPE"  ; FADEOUTENTRYTYPE
          rAud\nFadeOutEntryType = encodeFadeEntryType(gsData)
          
        Case "FADEOUTMSPOS"  ; FADEOUTMSPOS
          rAud\nFadeOutMSPos = Val(gsData)
          
        Case "FADEOUTSAMPLEPOS"  ; FADEOUTSAMPLEPOS
          rAud\qFadeOutSamplePos = Val(gsData)
          
        Case "FADEOUTTIME"  ; FADEOUTTIME
          If rSub\bSubTypeA
            rSub\nPLFadeOutTime = Val(gsData)
          Else
            macReadNumericOrStringParam(gsData, rAud\sFadeOutTime, rAud\nFadeOutTime, grAudDef\nFadeOutTime, #False)
            ; Macro macReadNumericOrStringParam populates \sFadeOutTime and \nFadeOutTime from the value in gsData
            ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
            If rAud\sFadeOutTime
              ; Indicates a callable cue parameter is in the 'fade-out time'
              rAud\nFadeOutTime = 1 ; 'dummy' set of fade-out time (one millisecond) so that elsewhere in the program SCS will recognise that there is a fade-out time
                                    ; and so will create a 'fade-out' level point
            EndIf
            ; debugMsg(sProcName, "gsData=" + gsData + ", rAud\sFadeOutTime=" + rAud\sFadeOutTime + ", rAud\nFadeOutTime=" + rAud\nFadeOutTime)
          EndIf
          
        Case "FADEOUTTYPE"  ; FADEOUTTYPE
          If gsData = "fader"
            gsData = "std"
          EndIf
          rAud\nFadeOutType = encodeFadeType(gsData)
          
        Case "FILE"  ; FILE
          bInFile = #True
          ; set filedata defaults
          rFileData = grFileDataDef
          
        Case "/FILE"  ; /FILE
          If rFileData\qFileSize > 0
            With rFileData
              \sFileName = decodeFileName(\sStoredFileName, bPrimaryFile)
              ; debugMsg(sProcName, "\sStoredFileName=" + \sStoredFileName)
              bFileChanged = #False
              If FileExists(\sFileName, #False) = #False
                bFileChanged = #True
              Else
                qCurrentFileSize = FileSize(\sFileName)
                sCurrentFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(\sFileName, #PB_Date_Modified))
                If (sCurrentFileModified <> \sFileModified) Or (qCurrentFileSize <> \qFileSize)
                  bFileChanged = #True
                EndIf
              EndIf
              If bFileChanged
                debugMsg(sProcName, "Changed!!!")
                debugMsg(sProcName, "sCurrentFileModified=" + sCurrentFileModified + ", \sFileModified=" + \sFileModified + ", qCurrentFileSize=" + Str(qCurrentFileSize) + ", \qFileSize=" + Str(\qFileSize))
                ; file has changed - clear out file duration, file type and viewdata
                \nFileDuration = grFileDataDef\nFileDuration
                \sFileType = grFileDataDef\sFileType
                \sFileTitle = grFileDataDef\sFileTitle
                \nSourceWidth = grFileDataDef\nSourceWidth
                \nSourceHeight = grFileDataDef\nSourceHeight
                \nxFileChannels = grFileDataDef\nxFileChannels
              EndIf
             ;  debugMsg(sProcName, ".. \nFileDuration=" + \nFileDuration + ", \sFileType=" + \sFileType + ", \nxFileChannels=" + \nxFileChannels + ", \nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
            EndWith
            ; Added 29Aug2022 11.9.5ae following check of Michael Taylor's "Pride and Prejudice.scs11" which had multiple repeats of \File entries
            ; Comment 10Nov2022 11.9.7ad - see comments for 11.9.7ad in unloadGrid()
            bFileFound = #False
            For n = 0 To nFileDataPtr
              If bPrimaryFile
                If gaFileData(n)\sFileName = rFileData\sFileName
                  bFileFound = #True
                  Break
                EndIf
              Else
                If a2ndFileData(n)\sFileName = rFileData\sFileName
                  bFileFound = #True
                  Break
                EndIf
              EndIf
            Next n
            ; End added 29Aug2022 11.9.5ae
            If bFileFound = #False ; Test added 29Aug2022 11.9.5ae
              nFileDataPtr + 1
              If bPrimaryFile
                If ArraySize(gaFileData()) < nFileDataPtr
                  REDIM_ARRAY(gaFileData, nFileDataPtr+20, grFileDataDef, "gaFileData()")
                  debugMsg(sProcName, "ArraySize(gaFileData())=" + ArraySize(gaFileData()))
                EndIf
                gaFileData(nFileDataPtr) = rFileData
                ; debugMsg(sProcName, "gaFileData(" + Str(nFileDataPtr) + ")\sStoredFileName=" + gaFileData(nFileDataPtr)\sStoredFileName)
                setMaxInnerWidthForFile(nFileDataPtr)
              Else
                If ArraySize(a2ndFileData()) < nFileDataPtr
                  REDIM_ARRAY(a2ndFileData, nFileDataPtr+20, grFileDataDef, "a2ndFileData()")
                EndIf
                a2ndFileData(nFileDataPtr) = rFileData
              EndIf
            EndIf ; EndIf bFileFound = #False
          EndIf ; EndIf rFileData\qFileSize > 0
          bInFile = #False
          
        Case "FILECHANNELS"  ; FILECHANNELS
          rFileData\nxFileChannels = Val(gsData)
          
        Case "FILEDURATION"  ; FILEDURATION
          rFileData\nFileDuration = Val(gsData)   ; will be cleared out later if FileProps has changed
          
        Case "FILEMODIFIED"  ; FILEMODIFIED
          rFileData\sFileModified = gsData
          
        Case "FILENAME"  ; FILENAME
          gsData = ReplaceString(gsData, Chr(0), "")  ; added for problem raised by Jick Lee - see email 18/01/2010
          While FindString(gsData, "$(Cue)\\")
            gsData = ReplaceString(gsData, "$(Cue)\\", "$(Cue)\")
          Wend
          If bInAud
            rAud\sStoredFileName = gsData
            rAud\sFileName = decodeFileName(rAud\sStoredFileName, bPrimaryFile)
            ; debugMsg(sProcName, "(" + gsTag + ") rAud\sFileName=" + rAud\sFileName)
          ElseIf bInFile
            rFileData\sStoredFileName = gsData
            rFileData\sFileName = decodeFileName(rFileData\sStoredFileName, bPrimaryFile)
            ; debugMsg(sProcName, "(" + gsTag + ") rFileData\sFileName=" + rFileData\sFileName)
          EndIf
          
        Case "FILESIZE"  ; FILESIZE
          rFileData\qFileSize = Val(gsData)
          
        Case "FILETITLE"  ; FILETITLE
          ; removeNonPrintingChars() was added to help clean up cue files with 'File Titles' containing characters that throw errors in loadXML()
          rFileData\sFileTitle = removeNonPrintingChars(gsData) ; will be cleared out later if FileProps has changed
          
        Case "FILETYPE"  ; FILETYPE
          rFileData\sFileType = gsData ; will be cleared out later if FileProps has changed
          
        Case "FIXTYPE"  ; FIXTYPE
          rFixType = grFixTypesDef
          If sUpAttributeName1 = "FIXTYPENAME" ; should be #True
            rFixType\sFixTypeName = gsTagAttributeValue1
            If rFixType\sFixTypeName
              gnNextFixTypeId + 1
              rFixType\nFixTypeId = gnNextFixTypeId
            EndIf
          EndIf
          nFTCIndex = -1
          
        Case "/FIXTYPE" ; /FIXTYPE
          rProd\nMaxFixType + 1
          nFixTypeIndex = rProd\nMaxFixType
          REDIM_ARRAY2(rProd\aFixTypes, nFixTypeIndex, grFixTypesDef)
          rProd\aFixTypes(nFixTypeIndex) = rFixType
          
        Case "FIXTYPEDESC"  ; FIXTYPEDESC
          rFixType\sFixTypeDesc = gsData
          
        Case "FIXTYPETOTALCHANS"  ; FIXTYPETOTALCHANS
          rFixType\nTotalChans = Val(gsData)
          n = rFixType\nTotalChans - 1  ; nb do NOT use nFTCIndex as that will be used for stepping thru the FTC tags and was initialized under "FIXTYPE"
          If n > ArraySize(rFixType\aFixTypeChan())
            ReDim rFixType\aFixTypeChan(n)
          EndIf
          For n = 0 To (rFixType\nTotalChans - 1)
            rFixType\aFixTypeChan(n)\nChanNo = (n + 1)
          Next n
          
        Case "FLIP"  ; FLIP
          rAud\nFlip = encodeFlip(gsData)
          
        Case "FTC"  ; FTC   nb FTC = Fixture Type Channel
          rFixTypeChan = grFixTypeChanDef
          If sUpAttributeName1 = "FTCCHANNEL" ; should be #True
            rFixTypeChan\nChanNo = Val(gsTagAttributeValue1)
          EndIf
          
        Case "/FTC" ; /FTC
          nFTCIndex = rFixTypeChan\nChanNo - 1
          If (nFTCIndex >= 0) And (nFTCIndex <= ArraySize(rFixType\aFixTypeChan()))
            rFixType\aFixTypeChan(nFTCIndex) = rFixTypeChan
          EndIf
          
        Case "FTCDEFAULT"  ; FTCDEFAULT
          rFixTypeChan\sDefault = gsData
          rFixTypeChan\nDMXDefault = DMX_convertDMXValueStringToDMXValue(rFixTypeChan\sDefault)
          
        Case "FTCDESC"  ; FTCDESC
          rFixTypeChan\sChannelDesc = gsData
          
        Case "FTCDIMMERCHAN"  ; FTCDIMMERCHAN
          rFixTypeChan\bDimmerChan = stringToBoolean(gsData)
          
        Case "FTCTEXTCOLOR"  ; FTCTEXTCOLOR
          rFixTypeChan\nDMXTextColor = Val(gsData)
          
        Case "FULLSCREEN"  ; FULLSCREEN
          rAud\bFullScreen = stringToBoolean(gsData)
          If grCFH\nFileVersion < 110201
            rAud\nAspectRatioType = #SCS_ART_FULL
          EndIf
          
        Case "FOCUSPOINT" ; FOCUSPOINT
          rProd\nFocusPoint = encodeFocusPoint(gsData)
          
;}
;{ G          
         Case "GOTOCUE"  ; GOTOCUE
          rSub\sCueToGoTo = gsData
          
        Case "GOTOCUEBUTDONOTSTARTIT"  ; GOTOCUEBUTDONOTSTARTIT
          rSub\bGoToCueButDoNotStartIt = stringToBoolean(gsData)
          
        Case "GRIDCLICKACTION" ; GRIDCLICKACTION
          rProd\nGridClickAction = encodeGridClickAction(gsData)
          
;}
;{ H          
         Case "HEAD"  ; HEAD
          bInHead = #True
          ; similar processing required in initProd()
;           rProd = grProdDef
          rCtrlSetup = grCtrlSetupDef
          rVST = grVSTDef
          debugMsg(sProcName, "rVST\nMaxDevVSTPlugin=" + rVST\nMaxDevVSTPlugin)
          
        Case "/HEAD"  ; /HEAD
          ; code to fix an error in an earlier mod that resulted in speaker names like FRONTLEFT(M) being changed to FRONTLeft$(M)
          For d = 0 To ArraySize(rProd\aAudioLogicalDevs())
            rProd\aAudioLogicalDevs(d)\sSpeaker = ReplaceString(UCase(rProd\aAudioLogicalDevs(d)\sSpeaker), "$", "")
          Next d
          
          If rProd\sPreviewDevice = grProdDef\sPreviewDevice
            rProd\sPreviewDevice = rProd\aAudioLogicalDevs(0)\sLogicalDev
          EndIf
          
          setTimeProfileCount(@rProd) ; added 17Mar2020 11.8.2.3aa
          
          ; convert old DMX Send to lighting
          m = -1
          For n = 0 To rProd\nMaxCtrlSendLogicalDev
            If rProd\aCtrlSendLogicalDevs(n)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
              m + 1
              If m > ArraySize(rProd\aLightingLogicalDevs())
                ReDim rProd\aLightingLogicalDevs(m+5)
              EndIf
              rProd\aLightingLogicalDevs(m) = grLightingLogicalDevsDef
              If m > rProd\nMaxLightingLogicalDev : rProd\nMaxLightingLogicalDev = m : EndIf
              rProd\aLightingLogicalDevs(m)\nDevType = rProd\aCtrlSendLogicalDevs(n)\nDevType
              rProd\aLightingLogicalDevs(m)\sLogicalDev = rProd\aCtrlSendLogicalDevs(n)\sLogicalDev
              rProd\aLightingLogicalDevs(m)\nDevId = rProd\aCtrlSendLogicalDevs(n)\nDevId
              rProd\aCtrlSendLogicalDevs(n) = grCtrlSendLogicalDevsDef ; grCtrlSendLogicalDevsDef
            EndIf
          Next n
          
          If bPrimaryFile
            If bCreateFromTemplate
              rProd\sTitle = grAction\sTitle
              rProd\nProdId = grProdDef\nProdId
            Else
              rProd\bTemplate = bTemplate
              If bTemplate
                rProd\sTmName = getTemplateName(gsTemplateFile) ; nb sTmName is NOT stored in the template file, so if the user manually changes the name of a template file the 'template name' becomes the new name
              EndIf
            EndIf
            grWMN\bTemplateInfoSet = #False
            grProd = rProd
            If grProd\nProdId = -1
              gnUniqueProdId + 1
              grProd\nProdId = gnUniqueProdId
            EndIf
            If Len(grProd\sProdId) = 0
              grProd\sProdId = calcProdId()
            EndIf
            setProdGlobals() ; Added 18Dec2023 11.10.0dq
            setDefaults_PropogateProdDevs()
            If grProd\bTemplate
              gsWhichTimeProfile = ""
            Else
              gsWhichTimeProfile = grProd\sDefaultTimeProfile
              nDay = DayOfWeek(Date())
              If grProd\sDefaultTimeProfileForDay[nDay]
                gsWhichTimeProfile = grProd\sDefaultTimeProfileForDay[nDay]
              EndIf
              debugMsg(sProcName, "gsWhichTimeProfile=" + gsWhichTimeProfile + ", Len(gsWhichTimeProfile)=" + Len(gsWhichTimeProfile))
              If gsWhichTimeProfile
                If IsGadget(WSP\cvsSplash)
                  WSP_setTimeProfile(gsWhichTimeProfile)
                EndIf
              EndIf
            EndIf
            grVST = rVST
            debugMsg(sProcName, "grVST\nMaxDevVSTPlugin=" + grVST\nMaxDevVSTPlugin)

          Else
            gr2ndProd = rProd
            If gr2ndProd\nProdId = -1
              gnUniqueProdId + 1
              gr2ndProd\nProdId = gnUniqueProdId
            EndIf
            gr2ndVST = rVST
          EndIf
          
          bInHead = #False
          
        Case "HIDECUE"  ; HIDECUE  ; deprecated (replaced in 11.2.5 by HIDECUEOPT)
          ; rCue\bHideCue = stringToBoolean(gsData)
          If rCue\nHideCueOpt = grCueDef\nHideCueOpt
            rCue\nHideCueOpt = #SCS_HIDE_ENTIRE_CUE
          EndIf
          
        Case "HIDECUEOPT" ; HIDECUEOPT
          rCue\nHideCueOpt = encodeHideCueOpt(gsData)
          
        Case "HIDECUEPANEL"  ; HIDECUEPANEL  ; deprecated (replaced in 11.2.5 by HIDECUEOPT)
          ; rCue\bHideCuePanel = stringToBoolean(gsData)
          If rCue\nHideCueOpt = grCueDef\nHideCueOpt
            rCue\nHideCueOpt = #SCS_HIDE_CUE_PANEL
          EndIf
          
        Case "HOTKEY"  ; HOTKEY
          rCue\sHotkey = gsData
          rCue\bHotkey = #True
          
        Case "HOTKEYBANK"  ; HOTKEYBANK
          rCue\nHotkeyBank = Val(gsData)

        Case "HOTKEYLABEL"  ; HOTKEYLABEL
          rCue\sHotkeyLabel = gsData
          
;}
;{ I          
         Case "INPUTDBLEVEL"  ; INPUTDBLEVEL
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          If ValF(gsData) < ValF(grLevels\sMinDBLevel)
            gsData = grLevels\sMinDBLevel
          EndIf
          rAud\sInputDBLevel[nTagIndex] = gsData
          rAud\fInputLevel[nTagIndex] = convertDBStringToBVLevel(gsData)
          
        Case "INPUTLOGICALDEV"  ; INPUTLOGICALDEV
          rAud\sInputLogicalDev[nTagIndex] = gsData
          
        Case "INPUTOFF"  ; INPUTOFF
          rAud\bInputOff[nTagIndex] = stringToBoolean(gsData)
          
;}
;{ L          
         Case "LABELSFROZEN"  ; LABELSFROZEN
          rProd\bLabelsFrozen = stringToBoolean(gsData)
          
        Case "LABELSUCASE"  ; LABELSUCASE
          rProd\bLabelsUCase = stringToBoolean(gsData)
          
        Case "LCABSREL"  ; LCABSREL
          ; rSub\nLCAbsRel = Val(gsData)
          ; Added 20Aug2021 11.8.6
          Select Val(gsData)
            Case #SCS_LC_ABSOLUTE
              rSub\nLCAction = #SCS_LC_ACTION_ABSOLUTE
            Case #SCS_LC_RELATIVE
              rSub\nLCAction = #SCS_LC_ACTION_RELATIVE
          EndSelect
          ; End added 20Aug2021 11.8.6
          
        Case "LCACTION"  ; LCACTION
          rSub\nLCAction = encodeLCAction(gsData)
          
        Case "LCACTIONTIME"  ; LCACTIONTIME
          rSub\nLCActionTime = Val(gsData)
          
        Case "LCACTIONVALUE"  ; LCACTIONVALUE
          rSub\fLCActionValue = ValF(gsData)
          
        Case "LCCUE"  ; LCCUE
          rSub\sLCCue = gsData
          
        Case "LCCUETYPE"  ; LCCUETYPE
          rSub\nLCCueType = encodeLCCueType(gsData)
          
        Case "LCINCLUDE"  ; LCINCLUDE
          rSub\bLCInclude[nTagIndex] = stringToBoolean(gsData)
          
        Case "LCREQDDBLEVEL"  ; LCREQDDBLEVEL
          rSub\sLCReqdDBLevel[nTagIndex] = setDecSepForLocale(gsData)
          
        Case "LCREQDPAN"  ; LCREQDPAN
          rSub\fLCReqdPan[nTagIndex] = panStringToSingle(gsData)
          
        Case "LCSAMELEVEL"  ; LCSAMELEVEL
          rSub\bLCSameLevel = stringToBoolean(gsData)
          rSub\bLCCalcSameLevelInd = #False
          
        Case "LCSAMETIME"  ; LCSAMETIME
          rSub\bLCSameTime = stringToBoolean(gsData)
          rSub\bLCCalcSameTimeInd = #False
          
        Case "LCSTARTAT"  ; LCSTARTAT
          rSub\nLCStartAt = Val(gsData)
          
        Case "LCSUBNO"  ; LCSUBNO
          rSub\nLCSubNo = Val(gsData)
          
        Case "LCTIME"  ; LCTIME
          macReadNumericOrStringParam(gsData, rSub\sLCTime[nTagIndex], rSub\nLCTime[nTagIndex], grSubDef\nLCTime[nTagIndex], #False)
          ; Macro macReadNumericOrStringParam populates \sLCTime[nTagIndex] and \nLCTime[nTagIndex] from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "LCTYPE"  ; LCTYPE
          rSub\nLCType = encodeFadeType(gsData)
          
        Case "LOGICALDEV"  ; LOGICALDEV
          ; check logical dev exists in production properties (added 20/2/2015 due to bug in fmEditProd() that didn't check if a device to be deleted was used in a live input cue (Brian Larson)
          For d = 0 To rProd\nMaxAudioLogicalDev ; Changed 15Dec2022 11.10.0ac (was #SCS_MAX_AUDIO_DEV_PER_PROD)
            If rProd\aAudioLogicalDevs(d)\sLogicalDev = gsData
              ; device exists = OK to save
              rAud\sLogicalDev[nTagIndex] = gsData
              Break
            EndIf
          Next d
          
        Case "LOGO"  ; LOGO
          rAud\bLogo = stringToBoolean(gsData)
          If rAud\bLogo
            rAud\bContinuous = grAudDef\bContinuous
            rAud\bDoContinuous = grAudDef\bDoContinuous
            rAud\nEndAt = grAudDef\nEndAt
          EndIf
          
        Case "LOOP"  ; LOOP
          rLoopInfo\bContainsLoop = stringToBoolean(gsData)
          
        Case "LOOPEND"  ; LOOPEND
          rLoopInfo\nLoopEnd = Val(gsData)
          rLoopInfo\bContainsLoop = #True    ; should be set by the "Loop" cue file tag, but this didn't exist in SCS10. SCS10 relied on nLoopEnd>0 to set \bContainsLoop
          
        Case "LOOPENDCPNAME"  ; LOOPENDCPNAME
          rLoopInfo\sLoopEndCPName = gsData
          
        Case "LOOPENDSAMPLEPOS"  ; LOOPENDSAMPLEPOS
          rLoopInfo\qLoopEndSamplePos = Val(gsData)
          
        Case "LOOPINFO" ; LOOPINFO
          rLoopInfo = grLoopInfoDef
          
        Case "/LOOPINFO" ; /LOOPINFO
          rAud\nMaxLoopInfo + 1
          If rAud\nMaxLoopInfo > ArraySize(rAud\aLoopInfo())
            ReDim rAud\aLoopInfo(rAud\nMaxLoopInfo)
          EndIf
          rAud\aLoopInfo(rAud\nMaxLoopInfo) = rLoopInfo
          
        Case "LOOPLINKED"  ; LOOPLINKED                  ; added 2Nov2015 11.4.1.2g
          rAud\bLoopLinked = stringToBoolean(gsData)
          
        Case "LOOPSTART"  ; LOOPSTART
          rLoopInfo\nLoopStart = Val(gsData)
          
        Case "LOOPSTARTCPNAME"  ; LOOPSTARTCPNAME
          rLoopInfo\sLoopStartCPName = gsData
          
        Case "LOOPSTARTSAMPLEPOS"  ; LOOPSTARTSAMPLEPOS
          rLoopInfo\qLoopStartSamplePos = Val(gsData)
          
        Case "LOOPXFADETIME"  ; LOOPXFADETIME
          rLoopInfo\nLoopXFadeTime = Val(gsData)
          
        Case "LOSTFOCUSACTION" ; LOSTFOCUSACTION
          rProd\nLostFocusAction = encodeLostFocusAction(gsData)
          
        Case "LTAPPLYCURRVALUESASMINS"
          rSub\bLTApplyCurrValuesAsMins = stringToBoolean(gsData)
          
        Case "LTBLFADEACTION" ; fade action for entry type 'Blackout'
          rSub\nLTBLFadeAction = encodeDMXFadeActionBL(gsData)
          
        Case "LTBLFADEUSERTIME" ; user-specified fade time for entry type 'Blackout'
          macReadNumericOrStringParam(gsData, rSub\sLTBLFadeUserTime, rSub\nLTBLFadeUserTime, grSubDef\nLTBLFadeUserTime, #False)
          ; Macro macReadNumericOrStringParam populates \sLTBLFadeUserTime and \nLTBLFadeUserTime from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "LTCAPTUREDATA"
          rSub\sLTCaptureData = gsData
          
        Case "LTCAPTUREMODE"
          rSub\nLTCaptureMode = Val(gsData)
          
        Case "LTCAPTURETIME"
          rSub\nLTCaptureTime = Val(gsData)
          
        Case "LTCHASE"
          rSub\bChase = stringToBoolean(gsData)
          
        Case "LTCHASEMODE"
          rSub\nChaseMode = encodeDMXChaseMode(gsData)
          
        Case "LTCHASESPEED"
          rSub\nChaseSpeed = Val(gsData)
          
        Case "LTCHASESTEP"
          nChaseStepIndex + 1
          nDMXSendItemIndex = -1
          nFixtureItemIndex = -1
          
        Case "LTCHASESTEPS"
          rSub\nChaseSteps = Val(gsData)
          setLTMaxChaseStepIndex(@rProd, @rSub)
          
        Case "LTDCFADEDOWNACTION" ; fade down action for entry type 'capture snapshot'
          rSub\nLTDCFadeDownAction = encodeDMXFadeActionDC(gsData)
          
        Case "LTDCFADEDOWNUSERTIME" ; user-specified fade down time for entry type 'capture snapshot'
          macReadNumericOrStringParam(gsData, rSub\sLTDCFadeDownUserTime, rSub\nLTDCFadeDownUserTime, grSubDef\nLTDCFadeDownUserTime, #False)
          ; Macro macReadNumericOrStringParam populates \sLTDCFadeDownUserTime and \nLTDCFadeDownUserTime from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "LTDCFADEOUTOTHERSACTION" ; fade out others action for entry type 'capture snapshot'
          If gsData = "None"
            rSub\nLTDCFadeOutOthersAction = #SCS_DMX_DC_FADE_ACTION_DO_NOT_FADEOUTOTHERS
          Else
            rSub\nLTDCFadeOutOthersAction = encodeDMXFadeActionDC(gsData)
          EndIf
          
        Case "LTDCFADEOUTOTHERSUSERTIME" ; user-specified fade out others time for entry type 'capture snapshot'
          macReadNumericOrStringParam(gsData, rSub\sLTDCFadeOutOthersUserTime, rSub\nLTDCFadeOutOthersUserTime, grSubDef\nLTDCFadeOutOthersUserTime, #False)
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          ; Macro macReadNumericOrStringParam populates \sLTDCFadeOutOthersUserTime and \nLTDCFadeOutOthersUserTime from the value in gsData
          
        Case "LTDCFADEUPACTION" ; fade up action for entry type 'capture snapshot'
          rSub\nLTDCFadeUpAction = encodeDMXFadeActionDC(gsData)
          
        Case "LTDCFADEUPUSERTIME" ; user-specified fade up time for entry type 'capture snapshot'
          macReadNumericOrStringParam(gsData, rSub\sLTDCFadeUpUserTime, rSub\nLTDCFadeUpUserTime, grSubDef\nLTDCFadeUpUserTime, #False)
          ; Macro macReadNumericOrStringParam populates \sLTDCFadeUpUserTime and \nLTDCFadeUpUserTime from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "LTDEFFADEACTION" ; obsolete, replaced at 11.8.5 by LTBLFADEACTION, LTDIDEFAULTFADEACTION, LTFIFADEUPACTION and LTFIFADEDOWNACTION
          Select rSub\nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_BLACKOUT
              rSub\nLTBLFadeAction = encodeDMXFadeActionBL(gsData)
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
              ; rSub\nLTDIDefaultFadeAction = encodeDMXFadeActionDI(gsData) ; pre SCS 11.10.0, replaced by the following:
              rSub\nLTDIFadeUpAction = encodeDMXFadeActionDI(gsData)
              If gsData = "Prod"
                rSub\nLTDIFadeDownAction = encodeDMXFadeActionDI("Up") ; when converting from pre-11.8.5 "LTDEFFADEACTION", if the fade action was "Prod" then set the 'fade down' action to 'use the fade up action'.
              Else
                rSub\nLTDIFadeDownAction = encodeDMXFadeActionDI(gsData) ; otherwise (eg for "None" or "User") just use the same action for 'fade down' as for 'fade up'.
              EndIf
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              rSub\nLTFIFadeUpAction = encodeDMXFadeActionFI(gsData)
              If gsData = "Prod"
                rSub\nLTFIFadeDownAction = encodeDMXFadeActionFI("Up") ; when converting from pre-11.8.5 "LTDEFFADEACTION", if the fade action was "Prod" then set the 'fade down' action to 'use the fade up action'.
              Else
                rSub\nLTFIFadeDownAction = encodeDMXFadeActionFI(gsData) ; otherwise (eg for "None" or "User") just use the same action for 'fade down' as for 'fade up'.
              EndIf
          EndSelect
          
        Case "LTDEFFADEUSERTIME" ; obsolete, replaced at 11.8.5 by LTBLFADEUSERTIME, LTDIDEFAULTFADEUSERTIME, LTFIFADEUPUSERTIME and LTFIFADEDOWNUSERTIME
          Select rSub\nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_BLACKOUT
              rSub\nLTBLFadeUserTime = Val(gsData)
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
              ; rSub\nLTDIDefaultFadeAction = encodeDMXFadeActionDI(gsData) ; pre SCS 11.10.0, replaced by the following:
              rSub\nLTDIFadeUpUserTime = Val(gsData)
              rSub\nLTDIFadeDownUserTime = Val(gsData)
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              rSub\nLTFIFadeUpUserTime = Val(gsData)
              rSub\nLTFIFadeDownUserTime = Val(gsData)
          EndSelect
          
        Case "LTDIDEFAULTFADEACTION" ; default fade action for entry type 'DMX Items'
                                     ; rSub\nLTDIDefaultFadeAction = encodeDMXFadeActionDI(gsData); pre SCS 11.10.0, replaced by the following:
          rSub\nLTDIFadeUpAction = encodeDMXFadeActionDI(gsData)
          If gsData = "Prod"
            rSub\nLTDIFadeDownAction = encodeDMXFadeActionDI("Up") ; when converting from pre-11.8.5 "LTDEFFADEACTION", if the fade action was "Prod" then set the 'fade down' action to 'use the fade up action'.
          Else
            rSub\nLTDIFadeDownAction = encodeDMXFadeActionDI(gsData) ; otherwise (eg for "None" or "User") just use the same action for 'fade down' as for 'fade up'.
          EndIf
          
        Case "LTDIDEFAULTFADEUSERTIME" ; user-specified default fade time for entry type 'DMX Items'
          ; rSub\nLTDIDefaultFadeUserTime = Val(gsData) ; pre SCS 11.10.0, replaced by the following:
          rSub\nLTDIFadeUpUserTime = Val(gsData)
          rSub\nLTDIFadeDownUserTime = Val(gsData)
          
        Case "LTDIFADEDOWNACTION" ; fade down action for entry type 'Fixtures'
          rSub\nLTDIFadeDownAction = encodeDMXFadeActionDI(gsData)
          
        Case "LTDIFADEDOWNUSERTIME" ; user-specified fade down time for entry type 'Fixtures'
          macReadNumericOrStringParam(gsData, rSub\sLTDIFadeDownUserTime, rSub\nLTDIFadeDownUserTime, grSubDef\nLTDIFadeDownUserTime, #False)
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          ; Macro macReadNumericOrStringParam populates \sLTDIFadeDownUserTime and \nLTDIFadeDownUserTime from the value in gsData
          
        Case "LTDIFADEOUTOTHERSACTION" ; fade out others action for entry type 'Fixtures'
          If gsData = "None" ; Added 28Oct2021 11.8.6bj following test of 11.8.4.1 cue file from Willi Härtel
            rSub\nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS ; Added 28Oct2021 11.8.6aj
          ElseIf gsData = "Def"
            rSub\nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME; Added 7Nov2023 11.10.0cq
          Else
            rSub\nLTDIFadeOutOthersAction = encodeDMXFadeActionDI(gsData)
          EndIf
          
        Case "LTDIFADEOUTOTHERSUSERTIME" ; user-specified fade out others time for entry type 'Fixtures'
          macReadNumericOrStringParam(gsData, rSub\sLTDIFadeOutOthersUserTime, rSub\nLTDIFadeOutOthersUserTime, grSubDef\nLTDIFadeOutOthersUserTime, #False)
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          ; Macro macReadNumericOrStringParam populates \sLTDIFadeOutOthersUserTime and \nLTDIFadeOutOthersUserTime from the value in gsData
          
        Case "LTDIFADEUPACTION" ; fade up action for entry type 'Fixtures'
          rSub\nLTDIFadeUpAction = encodeDMXFadeActionDI(gsData)
          
        Case "LTDIFADEUPUSERTIME" ; user-specified fade up time for entry type 'Fixtures'
          macReadNumericOrStringParam(gsData, rSub\sLTDIFadeUpUserTime, rSub\nLTDIFadeUpUserTime, grSubDef\nLTDIFadeUpUserTime, #False)
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          ; Macro macReadNumericOrStringParam populates \sLTDIFadeUpUserTime and \nLTDIFadeUpUserTime from the value in gsData
          
        Case "LTDMXITEMSTR"
            If rSub\nChaseSteps = 0
              ; cue file doesn't have 'chase steps' (LTCHASESTEP), probably because there's no 'chase', so assign item string to first chase step
              rSub\nChaseSteps = 1
              rSub\nMaxChaseStepIndex = 0
              nChaseStepIndex = 0
            EndIf
            nDMXSendItemIndex + 1
            If ArraySize(rSub\aChaseStep(nChaseStepIndex)\aDMXSendItem()) < nDMXSendItemIndex
              ReDim rSub\aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXSendItemIndex+5)
            EndIf
            rSub\aChaseStep(nChaseStepIndex)\nDMXSendItemCount + 1
            rSub\aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXSendItemIndex)\sDMXItemStr = gsData
            DMX_unpackDMXSendItemStr(@rSub\aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXSendItemIndex), @rProd, rSub\sLTLogicalDev)
            ; The following, following processing of "LTENTRYTYPE", is handle converting pre SCS 11.8.6ba entry types "CAP" to either "CAPSE" (sequence) or "CAPSN" (snapshot)
            If bDMXCaptureConversionCheckReqd
              If FindString(gsData, "[") > 0
                ; a time value (eg "[1.8]") is found in the item string
                If rSub\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                  rSub\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
                  bDMXCaptureConversionCheckReqd = #False ; no need to continue with this test
                EndIf
              EndIf
            EndIf
            
          Case "LTENTRYTYPE"
            If gsData = "CAP" ; pre SCS 11.8.6ba
              rSub\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP ; may be changed to #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ if a time value (eg "[1.8]") is found in an item string
              bDMXCaptureConversionCheckReqd = #True
            Else
              rSub\nLTEntryType = encodeLTEntryType(gsData)
            EndIf
            ; debugMsg(sProcName, "gsData=" + gsData + ", rSub\nLTEntryType=" + rSub\nLTEntryType + " (" + decodeLTEntryType(rSub\nLTEntryType) + ")")
          
        Case "LTFADEOUTOTHERSACTION" ; obsolete (pre 11.8.5) fade out others action for entry type 'DMX Items'
          Select rSub\nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
              If gsData = "Def" ; pre SCS 11.8.5
                ; rSub\nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT ; #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME ; Corrected 9Oct2024 11.10.6aj following emails from Octavio Alcober
                rSub\nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
              ElseIf gsData = "None" ; Added 28Oct2021 11.8.6bj following test of 11.8.4.1 cue file from Willi Härtel
                rSub\nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS ; Added 28Oct2021 11.8.6aj
              Else
                rSub\nLTDIFadeOutOthersAction = encodeDMXFadeActionDI(gsData)
              EndIf
              ; debugMsg(sProcName, "rSub\nLTEntryType=" + decodeLTEntryType(rSub\nLTEntryType) + ", gsData=" + gsData + ", rSub\nLTDIFadeOutOthersAction=" + decodeDMXFadeActionDI(rSub\nLTDIFadeOutOthersAction))
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              If gsData = "Def" ; pre SCS 11.8.5
                rSub\nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
              ElseIf gsData = "None" ; Added 28Oct2021 11.8.6bj following test of 11.8.4.1 cue file from Willi Härtel
                rSub\nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS ; Added 28Oct2021 11.8.6aj
              Else
                rSub\nLTFIFadeOutOthersAction = encodeDMXFadeActionFI(gsData)
              EndIf
          EndSelect
          
        Case "LTFADEOUTOTHERSUSERTIME" ; obsolete (pre 11.8.5) user-specified fade out others time for entry type 'DMX Items'
          Select rSub\nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
              rSub\nLTDIFadeOutOthersUserTime = Val(gsData)
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              rSub\nLTFIFadeOutOthersUserTime = Val(gsData)
          EndSelect
          
        Case "LTFIFADEDOWNACTION" ; fade down action for entry type 'Fixtures'
          rSub\nLTFIFadeDownAction = encodeDMXFadeActionFI(gsData)
          
        Case "LTFIFADEDOWNUSERTIME" ; user-specified fade down time for entry type 'Fixtures'
          macReadNumericOrStringParam(gsData, rSub\sLTFIFadeDownUserTime, rSub\nLTFIFadeDownUserTime, grSubDef\nLTFIFadeDownUserTime, #False)
          ; Macro macReadNumericOrStringParam populates \sLTFIFadeDownUserTime and \nLTFIFadeDownUserTime from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "LTFIFADEOUTOTHERSACTION" ; fade out others action for entry type 'Fixtures'
          If gsData = "None" ; Added 28Oct2021 11.8.6bj following test of 11.8.4.1 cue file from Willi Härtel
            rSub\nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS ; Added 28Oct2021 11.8.6aj
          Else
            rSub\nLTFIFadeOutOthersAction = encodeDMXFadeActionFI(gsData)
          EndIf
          
        Case "LTFIFADEOUTOTHERSUSERTIME" ; user-specified fade out others time for entry type 'Fixtures'
          macReadNumericOrStringParam(gsData, rSub\sLTFIFadeOutOthersUserTime, rSub\nLTFIFadeOutOthersUserTime, grSubDef\nLTFIFadeOutOthersUserTime, #False) ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          ; Macro macReadNumericOrStringParam populates \sLTFIFadeOutOthersUserTime and \nLTFIFadeOutOthersUserTime from the value in gsData
          
        Case "LTFIFADEUPACTION" ; fade up action for entry type 'Fixtures'
          rSub\nLTFIFadeUpAction = encodeDMXFadeActionFI(gsData)
          
        Case "LTFIFADEUPUSERTIME" ; user-specified fade up time for entry type 'Fixtures'
          macReadNumericOrStringParam(gsData, rSub\sLTFIFadeUpUserTime, rSub\nLTFIFadeUpUserTime, grSubDef\nLTFIFadeUpUserTime, #False)
          ; Macro macReadNumericOrStringParam populates \sLTFIFadeUpUserTime and \nLTFIFadeUpUserTime from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "LTFIXTURECODE"
          ; The following test added 8Sep2021 11.8.6ag following a test of "VicPtSchool.scs11" that had some duplicated fixture entries - not sure why!
          bIgnoreThisFixtureEntry = #False
          For n = 0 To rSub\nMaxFixture
            If rSub\aLTFixture(n)\sLTFixtureCode = gsData
              bIgnoreThisFixtureEntry = #True
              Break
            EndIf
          Next n
          If bIgnoreThisFixtureEntry = #False
            rSub\nMaxFixture + 1
            If rSub\nMaxFixture > ArraySize(rSub\aLTFixture())
              REDIM_ARRAY(rSub\aLTFixture, rSub\nMaxFixture+5, grLTSubFixtureDef, "aLTFixture()")
            EndIf
            rSub\aLTFixture(rSub\nMaxFixture)\sLTFixtureCode = gsData
            If sUpAttributeName1 = "LINKGROUP"
              rSub\aLTFixture(rSub\nMaxFixture)\nFixtureLinkGroup = Val(gsTagAttributeValue1)
            Else
              rSub\aLTFixture(rSub\nMaxFixture)\nFixtureLinkGroup = 0
            EndIf
          EndIf
          
        Case "LTFIXTUREITEM"
          ; attribute = fixture code
          If bLTSubArraysSet = #False
            debugMsg(sProcName, "LTFIXTUREITEM calling setLTSubArrays(@rProd, @rSub, #True)")
            setLTSubArrays(@rProd, @rSub, #True)
            bLTSubArraysSet = #True
          EndIf
          nFixtureItemIndex = -1
          If sUpAttributeName1 = "FIXTURECODE" ; should be #True
            sFixtureCode = gsTagAttributeValue1
            For n = 0 To rSub\nMaxFixture
              If rSub\aLTFixture(n)\sLTFixtureCode = sFixtureCode
                nFixtureItemIndex = n
                Break
              EndIf
            Next n
          EndIf
          If rSub\nChaseSteps = 0
            ; cue file doesn't have 'chase steps' (LTCHASESTEP), probably because there's no 'chase', so assign item to first chase step
            rSub\nChaseSteps = 1
            rSub\nMaxChaseStepIndex = 0
            nChaseStepIndex = 0
          EndIf
          ; debugMsg(sProcName, "nFixtureItemIndex=" + nFixtureItemIndex + ", ArraySize(rSub\aChaseStep())=" + ArraySize(rSub\aChaseStep()))
          If (nFixtureItemIndex >= 0) And (nFixtureItemIndex <= ArraySize(rSub\aChaseStep(nChaseStepIndex)\aFixtureItem()))
            rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\sFixtureCode = gsTagAttributeValue1
          EndIf
          
        Case "LTFIXTUREITEMCHAN"
          ; attribute = relative channel number
          nFixtureChanIndex = -1
          If nFixtureItemIndex >= 0
            If sUpAttributeName1 = "RELCHAN" ; should be #True
              nFixtureChanIndex = Val(gsTagAttributeValue1) - 1
            EndIf
            ; added 9Aug2019 11.8.2ad following test of importing devices from "A Christmas Chaos - Lighting.scs11" which threw a subscript error when processing LTFIXTUREITEMCHANINC for fixture channel 1
            If nFixtureChanIndex > ArraySize(rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan())
              ReDim rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex+5)
            EndIf
            ; end added 9Aug2019 11.8.2ad
            If nFixtureChanIndex >= 0
              rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex) = grLTFixChanDef
              rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex)\nRelChanNo = Val(gsTagAttributeValue1)
            EndIf
          EndIf
          
        Case "LTFIXTUREITEMCHANAPPLYFADE"
          If (nFixtureItemIndex >= 0) And (nFixtureChanIndex >= 0)
            ; nb not used in chase cues, so always store in the first 'chase step' (index 0)
            rSub\aChaseStep(0)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex)\bApplyFadeTime = stringToBoolean(gsData)
          EndIf
          
        Case "LTFIXTUREITEMCHANINC"
          If (nFixtureItemIndex >= 0) And (nFixtureChanIndex >= 0)
            rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex)\bRelChanIncluded = stringToBoolean(gsData)
          EndIf
          
        Case "LTFIXTUREITEMCHANVAL"
          With rSub\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex)
            \sDMXDisplayValue = gsData
            If DMX_validateAndConvertDMXDisplayValue(gsData)
              \nDMXDisplayValue = grDMXValueInfo\nDMXDisplayValue
              \nDMXAbsValue = grDMXValueInfo\nDMXAbsValue
              \bDMXAbsValue = grDMXValueInfo\bDMXAbsValue
              ; debugMsg(sProcName, ".. rSub\aChaseStep(" + nChaseStepIndex + ")\aFixtureItem(" + nFixtureItemIndex + ")\aFixChan(" + nFixtureChanIndex + ")\nDMXAbsValue=" + \nDMXAbsValue)
            Else
              debugMsg(sProcName, ".. DMX_validateAndConvertDMXDisplayValue(" + gsData + ") returned #False")
            EndIf
          EndWith
            
        Case "LTFIXTURES"
          rSub\nMaxFixture = -1
          
        Case "/LTFIXTURES"
          debugMsg(sProcName, "/LTFIXTURES calling syncLightingSubForFixtures(@rProd, @rSub)")
          syncLightingSubForFixtures(@rProd, @rSub)
          
        Case "LTLOGICALDEV"
          rSub\sLTLogicalDev = gsData
          nLTDevType = getDevTypeFromLogicalDev(@rProd, #SCS_DEVGRP_LIGHTING, gsData)
          debugMsg(sProcName, "nLTDevType=" + decodeDevType(nLTDevType))
          rSub\nLTDevType = nLTDevType
          syncLightingSubForFixtures(@rProd, @rSub) ; nb need rSub\sLTLogicalDev populated before we can call this
          
        Case "LTMONITORTAPDELAY"
          rSub\bMonitorTapDelay = stringToBoolean(gsData)
          
        Case "LTNEXTLTSTOPSCHASE"
          rSub\bNextLTStopsChase = stringToBoolean(gsData)
          
        Case "LVLPT" ; LVLPT
          nLevelPointIndex + 1
          If nLevelPointIndex > ArraySize(rAud\aPoint())
            ReDim rAud\aPoint(nLevelPointIndex + 5)
          EndIf
          gnUniquePointId + 1
          rAud\aPoint(nLevelPointIndex) = grLevelPointDef
          rAud\aPoint(nLevelPointIndex)\nPointId = gnUniquePointId
          rAud\nMaxLevelPoint = nLevelPointIndex
          nLevelPointItemIndex = -1
          
        Case "/LVLPT"
          ; added 28Nov2019 11.8.2rc5b following investigation of Gene LeFave's 'Chess' Q159 issue, where he could not add a std lvl pt because existing std lvl pts (in the cue file) had no items
          ; if no items present for a standard level point the remove the level point entry
          If nLevelPointIndex >= 0
            If rAud\aPoint(nLevelPointIndex)\nPointType = #SCS_PT_STD
              If rAud\aPoint(nLevelPointIndex)\nPointMaxItem = grLevelPointDef\nPointMaxItem
                ; if we get here then no "LVLPTITEM" entries were found for this standard level point
                ; debugMsg(sProcName, "removing standard level point at " + rAud\aPoint(nLevelPointIndex)\nPointTime)
                nLevelPointIndex - 1
                rAud\nMaxLevelPoint = nLevelPointIndex
              EndIf
            EndIf
          EndIf
          ; end added 28Nov2019 11.8.2rc6
                
        Case "LVLPTITEM" ; LVLPTITEM
          If nLevelPointIndex >= 0
            nLevelPointItemIndex + 1
            If nLevelPointItemIndex > ArraySize(rAud\aPoint(nLevelPointIndex)\aItem())
              REDIM_ARRAY(rAud\aPoint(nLevelPointIndex)\aItem, nLevelPointItemIndex, grLevelPointItemDef, "rAud\aPoint(" + nLevelPointIndex + ")\aItem()")
            EndIf
          EndIf
          rAud\aPoint(nLevelPointIndex)\nPointMaxItem = nLevelPointItemIndex
          
        Case "LVLPTITEMINCLUDE" ; LVLPTITEMINCLUDE
          If (nLevelPointIndex >= 0) And (nLevelPointItemIndex >= 0)
            rAud\aPoint(nLevelPointIndex)\aItem(nLevelPointItemIndex)\bItemInclude = stringToBoolean(gsData)
          EndIf
          
        Case "LVLPTITEMLOGICALDEV" ; LVLPTITEMLOGICALDEV
          If (nLevelPointIndex >= 0) And (nLevelPointItemIndex >= 0)
            rAud\aPoint(nLevelPointIndex)\aItem(nLevelPointItemIndex)\sItemLogicalDev = gsData
          EndIf
          
        Case "LVLPTITEMPAN" ; LVLPTITEMPAN
          If (nLevelPointIndex >= 0) And (nLevelPointItemIndex >= 0)
            rAud\aPoint(nLevelPointIndex)\aItem(nLevelPointItemIndex)\fItemPan = panStringToSingle(gsData)
          EndIf
          
        Case "LVLPTITEMRELDBLEVEL" ; LVLPTITEMRELDBLEVEL
          bItemRelDBLevelFound = #True
          If (nLevelPointIndex >= 0) And (nLevelPointItemIndex >= 0)
            sTmp = setDecSepForLocale(gsData)
            rAud\aPoint(nLevelPointIndex)\aItem(nLevelPointItemIndex)\fItemRelDBLevel = convertDBStringToDBLevel(sTmp)
            ; debugMsg(sProcName, "rCue\sCue=" + rCue\sCue + ", gsData=" + gsData + ", sTmp=" + sTmp + ", rAud\aPoint(" + nLevelPointIndex + ")\aItem(" + nLevelPointItemIndex + ")\fItemRelDBLevel=" + StrF(rAud\aPoint(nLevelPointIndex)\aItem(nLevelPointItemIndex)\fItemRelDBLevel, 2))
          EndIf
          
        Case "LVLPTITEMTRACKS"  ; LVLPTITEMTRACKS
          If (nLevelPointIndex >= 0) And (nLevelPointItemIndex >= 0)
            rAud\aPoint(nLevelPointIndex)\aItem(nLevelPointItemIndex)\sItemTracks = gsData
          EndIf
          
        Case "LVLPTLVLSEL" ; LVLPTLVLSEL
          ; obsolete - was used if #c_lvlsel_in_aud = #False
          ; superceded by LVLPTLVLSELA
          
        Case "LVLPTLVLSELA" ; LVLPTLVLSELA
          rAud\nLvlPtLvlSel = encodeLvlPtLvlSel(gsData)
          
        Case "LVLPTTIME" ; LVLPTTIME
          If nLevelPointIndex >= 0
            rAud\aPoint(nLevelPointIndex)\nPointTime = Val(gsData)
          EndIf
          
        Case "LVLPTTYPE" ; LVLPTTYPE
          If nLevelPointIndex >= 0
            rAud\aPoint(nLevelPointIndex)\nPointType = encodeLevelPointType(gsData)
          EndIf
          
        Case "LVLPTPANSEL" ; LVLPTPANSEL
          ; obsolete - was used if #c_lvlsel_in_aud = #False
          ; superceded by LVLPTPANSELA
          
        Case "LVLPTPANSELA" ; LVLPTPANSELA
          rAud\nLvlPtPanSel = encodeLvlPtPanSel(gsData)
          
;}
;{ M          
         Case "MARKERPOS" ; SCS Cue Marker Position (see also "CUEMARKER")
          rAud\aCueMarker(rAud\nMaxCueMarker)\nCueMarkerPosition = Val(gsData) 
          
        Case "MASTERDBVOLUME"  ; MASTERDBVOLUME
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          rProd\sMasterDBVol = gsData
          rProd\fMasterBVLevel = convertDBStringToBVLevel(gsData)
          debugMsg(sProcName, "rProd\fMasterBVLevel=" + traceLevel(rProd\fMasterBVLevel))
          
        Case "MAXDBLEVEL"  ; MAXDBLEVEL ; see also "MINDBLEVEL"
          rProd\nMaxDBLevel = Val(gsData) ; 0 or 12, ie 0dB or +12dB
          
        Case "MAYUSEGAPLESS"  ; MAYUSEGAPLESS
          rSub\bMayUseGaplessStream = stringToBoolean(gsData)
          
        Case "MEMOASPECTRATIO"  ; MEMOASPECTRATIO
          rSub\nMemoAspectRatio = encodeAspectRatioValue(gsData)
          
        Case "MEMOCONTINUOUS"   ; MEMOCONTINUOUS
          rSub\bMemoContinuous = stringToBoolean(gsData)
          
        Case "MEMODESIGNWIDTH"  ; MEMODESIGNWIDTH
          rSub\nMemoDesignWidth  = Val(gsData)
          ; nb design height not currently required as SCS calculates design height using \nMemoDesignWidth and \nMemoAspectRatio
          
        Case "MEMODISPLAYHEIGHT"  ; MEMODISPLAYHEIGHT
          rSub\nMemoDisplayHeight  = Val(gsData)
          
        Case "MEMODISPLAYTIME"  ; MEMODISPLAYTIME
          rSub\nMemoDisplayTime  = Val(gsData)
          
        Case "MEMODISPLAYWIDTH"  ; MEMODISPLAYWIDTH
          rSub\nMemoDisplayWidth  = Val(gsData)
          
        Case "MEMOPAGECOLOR"  ; MEMOPAGECOLOR
          rSub\nMemoPageColor = Val(gsData)
          
        Case "MEMORESIZEFONT"   ; MEMORESIZEFONT
          rSub\bMemoResizeFont = stringToBoolean(gsData)
          
        Case "MEMORTFTEXT"  ; MEMORTFTEXT
          rSub\sMemoRTFText = gsData
          debugMsg(sProcName, "rSub\sMemoRTFText=" + rSub\sMemoRTFText)
          
        Case "MEMOSCREEN"  ; MEMOSCREEN
          rSub\nMemoScreen = Val(gsData)
          
        Case "MEMOTEXTBACKCOLOR"  ; MEMOTEXTBACKCOLOR
          rSub\nMemoTextBackColor = Val(gsData)
          
        Case "MEMOTEXTCOLOR"  ; MEMOTEXTCOLOR
          rSub\nMemoTextColor = Val(gsData)
          
        Case "MIDICUE"  ; MIDICUE
          rCue\sMidiCue = gsData
          
        Case "MIDILOGICALDEV"  ; MIDILOGICALDEV
          rAud\sLogicalDev[0] = gsData  ; SCS10 - this SubTypeF will be changed to SubTypeM in convertSCS10MidiFileCues()
          
        Case "MINDBLEVEL"  ; MINDBLEVEL ; see also "MAXDBLEVEL"
          rProd\nMinDBLevel = Val(gsData) ; -75, -120 or -160, ie -75dB, -120dB or -160dB
          debugMsg(sProcName, "rProd\nMinDBLevel=" + rProd\nMinDBLevel)
          
        Case "MSCHANNEL"  ; MSCHANNEL
          rSub\aCtrlSend[nCtrlSendIndex]\nMSChannel = Val(gsData)
          
        Case "MSMACRO"  ; MSMACRO
          rSub\aCtrlSend[nCtrlSendIndex]\nMSMacro = Val(gsData)
          
        Case "MSMSGTYPE"  ; MSMSGTYPE
          If gsData = "BRS"           ; 'Behringer Recall Snapshot' obsolete - equivalent to Program Change (1-128)
            gsData = "PC128"
          ElseIf gsData = "PC"        ; 'PC' in the cue file is translated to 'PC127' internally
            gsData = "PC127"
          EndIf
          nMSMsgType = encodeMSMsgType(gsData)
          rSub\aCtrlSend[nCtrlSendIndex]\nMSMsgType = nMSMsgType
          ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\nMSMsgType=" + decodeMsgType(rSub\aCtrlSend[nCtrlSendIndex]\nMSMsgType))
          If bPrimaryFile
            If nMSMsgType = #SCS_MSGTYPE_FREE
              bMIDIFreeFormatFound = #True
            EndIf
          EndIf
          
        Case "MSPARAM"  ; MSPARAM
          Select nTagIndex
            Case 1
              macReadNumericOrStringParam(gsData, rSub\aCtrlSend[nCtrlSendIndex]\sMSParam1, rSub\aCtrlSend[nCtrlSendIndex]\nMSParam1, grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1, #False)
              ; Macro macReadNumericOrStringParam populates \sMSParam1 and \nMSParam1 from the value in gsData
            Case 2
              macReadNumericOrStringParam(gsData, rSub\aCtrlSend[nCtrlSendIndex]\sMSParam2, rSub\aCtrlSend[nCtrlSendIndex]\nMSParam2, grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2, #False)
              ; Macro macReadNumericOrStringParam populates \sMSParam2 and \nMSParam2 from the value in gsData
            Case 3
              macReadNumericOrStringParam(gsData, rSub\aCtrlSend[nCtrlSendIndex]\sMSParam3, rSub\aCtrlSend[nCtrlSendIndex]\nMSParam3, grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam3, #False)
              ; Macro macReadNumericOrStringParam populates \sMSParam3 and \nMSParam3 from the value in gsData
            Case 4
              macReadNumericOrStringParam(gsData, rSub\aCtrlSend[nCtrlSendIndex]\sMSParam4, rSub\aCtrlSend[nCtrlSendIndex]\nMSParam4, grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam4, #False)
              ; Macro macReadNumericOrStringParam populates \sMSParam4 and \nMSParam4 from the value in gsData
          EndSelect
          
        Case "MSPARAM1INFO"  ; MSPARAM1NFO
          rSub\aCtrlSend[nCtrlSendIndex]\sMSParam1Info = gsData
          
        Case "MSPARAM2INFO"  ; MSPARAM2INFO
          rSub\aCtrlSend[nCtrlSendIndex]\sMSParam2Info = gsData
          
        Case "MSPARAM3INFO"  ; MSPARAM3INFO
          rSub\aCtrlSend[nCtrlSendIndex]\sMSParam3Info = gsData
          
        Case "MSPARAM4INFO"  ; MSPARAM4INFO
          rSub\aCtrlSend[nCtrlSendIndex]\sMSParam4Info = gsData
          
        Case "MSQNUMBER", "MSCTRLNUMBER"  ; MSQNUMBER, "MSCTRLNUMBER"
          rSub\aCtrlSend[nCtrlSendIndex]\sMSQNumber = gsData
          
        Case "MSQLIST", "MSCTRLVALUE"  ; MSQLIST, "MSCTRLVALUE"
          rSub\aCtrlSend[nCtrlSendIndex]\sMSQList = gsData
          
        Case "MSQPATH"  ; MSQPATH
          rSub\aCtrlSend[nCtrlSendIndex]\sMSQPath = gsData
          
        Case "MTCDURATION" ; MTCDURATION
          rSub\nMTCDuration = Val(gsData)
          
        Case "MTCDELAY", "MTCPREROLL" ; MTCDELAY, MTCPREROLL
          rSub\nMTCPreRoll = Val(gsData)
          If bPrimaryFile
            gnLastMTCPreRoll = rSub\nMTCPreRoll
          EndIf
          
        Case "MTCFRAMERATE" ; MTCFRAMERATE
          rSub\nMTCFrameRate = encodeMTCFrameRate(gsData)
          If bPrimaryFile
            gnLastMTCFrameRate = rSub\nMTCFrameRate
          EndIf
          
        Case "MTCSTARTTIME" ; MTCSTARTTIME
          rSub\nMTCStartTime = encodeMTCTime(gsData)
          ; debugMsg(sProcName, "\sTagCode=" + sTagCode + ", gsData=" + gsData + ", rSub\nMTCStartTime=" + rSub\nMTCStartTime)
          
        Case "MTCSTARTTIMEFORCUE" ; MTCSTARTTIMEFORCUE
          rCue\nMTCStartTimeForCue = encodeMTCTime(gsData)
          
        Case "MTCTYPE" ; MTCTYPE
          rSub\nMTCType = encodeMTCType(gsData)
          If bPrimaryFile
            gnLastMTCType = rSub\nMTCType
          EndIf
          
        Case "MUTEVIDEOAUDIO" ; MUTEVIDEOAUDIO
          rSub\bMuteVideoAudio = stringToBoolean(gsData)
          
;}
;{ N          
         Case "NOPRELOADVIDEOHOTKEYS"  ; NOPRELOADVIDEOHOTKEYS
          rProd\bNoPreLoadVideoHotkeys = stringToBoolean(gsData)
          
        Case "NUMLOOPS"  ; NUMLOOPS
          rLoopInfo\nNumLoops = Val(gsData)
          
;}
;{ O          
         Case "OSCCMDTYPE"  ; OSCCMDTYPE
          rSub\aCtrlSend[nCtrlSendIndex]\sOSCCmdType = gsData
          rSub\aCtrlSend[nCtrlSendIndex]\bIsOSC = #True
          
        Case "OSCITEMNR"  ; OSCITEMNR
          rSub\aCtrlSend[nCtrlSendIndex]\nOSCItemNr = Val(gsData)
          
        Case "OSCITEMPLACEHOLDER"  ; OSCITEMPLACEHOLDER
          rSub\aCtrlSend[nCtrlSendIndex]\bOSCItemPlaceHolder = stringToBoolean(gsData)
          
        Case "OSCITEMSTRING"  ; OSCITEMSTRING
          rSub\aCtrlSend[nCtrlSendIndex]\sOSCItemString = gsData
          If rSub\aCtrlSend[nCtrlSendIndex]\sOSCCmdType = "mutemain"
            If gsData = "LR"
              rSub\aCtrlSend[nCtrlSendIndex]\sOSCCmdType = "mutemainlr"
            Else
              rSub\aCtrlSend[nCtrlSendIndex]\sOSCCmdType = "mutemainmc"
            EndIf
          EndIf
          
        Case "OSCMUTEACTION"  ; OSCMUTEACTION
          ; See "REMDEVMUTEACTION" which supercedes "OSCMUTEACTION"
          If rSub\aCtrlSend[nCtrlSendIndex]\nRemDevMuteAction = grCtrlSendDef\nRemDevMuteAction
            rSub\aCtrlSend[nCtrlSendIndex]\nOSCMuteAction = encodeMuteAction(gsData)
          EndIf
          
        Case "OSCRELOADNAMES"  ; OSCRELOADNAMES
          rSub\aCtrlSend[nCtrlSendIndex]\bOSCReloadNamesGoScene = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastOSCReloadNamesGoScene = rSub\aCtrlSend[nCtrlSendIndex]\bOSCReloadNamesGoScene
          EndIf
          
        Case "OSCRELOADNAMESGOCUE"  ; OSCRELOADNAMESGOCUE
          rSub\aCtrlSend[nCtrlSendIndex]\bOSCReloadNamesGoCue = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastOSCReloadNamesGoCue = rSub\aCtrlSend[nCtrlSendIndex]\bOSCReloadNamesGoCue
          EndIf
          
        Case "OSCRELOADNAMESGOSNIPPET"  ; OSCRELOADNAMESGOSNIPPET
          rSub\aCtrlSend[nCtrlSendIndex]\bOSCReloadNamesGoSnippet = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastOSCReloadNamesGoScene = rSub\aCtrlSend[nCtrlSendIndex]\bOSCReloadNamesGoSnippet
          EndIf
          
        Case "OUTPUTDEVFORLIVETEST"   ; OUTPUTDEVFORLIVETEST
          rProd\sOutputDevForTestLiveInput = gsData
          
        Case "OUTPUTSCREEN"  ; OUTPUTSCREEN
          rSub\nOutputScreen = Val(gsData)
          
        Case "OVERLAY"  ; OVERLAY
          rAud\bOverlay = stringToBoolean(gsData)
          
;}
;{ P          
         Case "PAGENO" ; PAGENO
          rCue\sPageNo = gsData
          
        Case "PAN"  ; PAN
          rAud\fSavedPan[nTagIndex] = panStringToSingle(gsData)
          rAud\fPan[nTagIndex] = rAud\fSavedPan[nTagIndex]
          debugMsg(sProcName, "PAN: panStringToSingle(" + gsData + ")=" + StrF(panStringToSingle(gsData),4)) 
          
        Case "PAUSEATEND" ; PAUSEATEND
          rSub\bPauseAtEnd = stringToBoolean(gsData)
          
          ; playlist
        Case "PLFADEINTIME"  ; PLFADEINTIME
          rSub\nPLFadeInTime = Val(gsData)
        Case "PLFADEOUTTIME"  ; PLFADEOUTTIME
          rSub\nPLFadeOutTime = Val(gsData)
        Case "PLDBTRIM", "SUBDBTRIM"  ; PLDBTRIM, SUBDBTRIM
          rSub\sPLDBTrim[nTagIndex] = gsData
          rSub\fSubTrimFactor[nTagIndex] = dbTrimStringToFactor(gsData)
        Case "PLLOGICALDEV", "SUBLOGICALDEV"  ; PLLOGICALDEV, SUBLOGICALDEV
          rSub\sPLLogicalDev[nTagIndex] = gsData
          debugMsg(sProcName, "rSub\sPLLogicalDev[" + nTagIndex + "]=" + rSub\sPLLogicalDev[nTagIndex])
        Case "PLMASTDBLEVEL", "SUBDBLEVEL"  ; PLMASTDBLEVEL, SUBDBLEVEL
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          If ValF(gsData) < ValF(grLevels\sMinDBLevel)
            gsData = grLevels\sMinDBLevel
          EndIf
          rSub\sPLMastDBLevel[nTagIndex] = gsData
          rSub\fSubMastBVLevel[nTagIndex] = convertDBStringToBVLevel(setDecSepForLocale(gsData))
        Case "PLPAN", "SUBPAN"  ; PLPAN, SUBPAN
          rSub\fPLPan[nTagIndex] = panStringToSingle(gsData)
        Case "PLRANDOM"  ; PLRANDOM
          rSub\bPLRandom = stringToBoolean(gsData)
        Case "PLRELLEVEL", "RELLEVEL"  ; PLRELLEVEL, RELLEVEL
          rAud\fPLRelLevel = ValF(setDecSepForLocale(gsData))
        Case "PLREPEAT", "PLCONTINUOUS", "SUBCONTINUOUS"    ; PLREPEAT (SCS11) or PLCONTINUOUS (SCS10) or deprecated SUBCONTINUOUS
          rSub\bPLRepeat = stringToBoolean(gsData)
        Case "PLSAVEPOS"  ; PLSAVEPOS
          rSub\bPLSavePos = stringToBoolean(gsData)
        Case "PLTRACKS"  ; PLTRACKS
          rSub\sPLTracks[nTagIndex] = gsData
        Case "PLTRANSTIME", "TRANSTIME"  ; PLTRANSTIME, TRANSTIME
          rAud\nPLTransTime = Val(gsData)
          rAud\nPLRunTimeTransTime = rAud\nPLTransTime
        Case "PLTRANSTYPE", "TRANSTYPE"  ; PLTRANSTYPE, TRANSTYPE
          rAud\nPLTransType = encodeTransType(LCase(gsData))
          rAud\nPLRunTimeTransType = rAud\nPLTransType
          
        Case "PRAUDEVICE"
          If sUpAttributeName1 = "DEVNO" ; should be #True
            nPRAudDevIndex = Val(gsTagAttributeValue1)
            nPRAudDevVSTIndex = -1
          EndIf
          
        Case "/PRAUDEVICE"
          nPRAudDevIndex = -1
          
        Case "PRAUFORLTC"  ; PRAUFORLTC
          rProd\aAudioLogicalDevs(nTagIndex)\bForLTC = stringToBoolean(gsData)
          
        Case "PRAUTOINCLUDEDEV"  ; PRAUTOINCLUDEDEV
          rProd\aAudioLogicalDevs(nTagIndex)\bAutoInclude = stringToBoolean(gsData)
          
        Case "PRAUTOINCLUDEVIDAUD"  ; PRAUTOINCLUDEVIDAUD
          rProd\aVidAudLogicalDevs(nTagIndex)\bAutoInclude = stringToBoolean(gsData)
          
        Case "PRAUTOINCLUDEVIDCAP"  ; PRAUTOINCLUDEVIDCAP
          rProd\aVidCapLogicalDevs(nTagIndex)\bAutoInclude = stringToBoolean(gsData)
          
        Case "PRCCDEVICE"
          nCueCtrlDevPtr + 1
          REDIM_ARRAY2(rProd\aCueCtrlLogicalDevs, nCueCtrlDevPtr, grCueCtrlLogicalDevsDef)
          If nCueCtrlDevPtr > rProd\nMaxCueCtrlLogicalDev
            rProd\nMaxCueCtrlLogicalDev = nCueCtrlDevPtr
          EndIf
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\sCueCtrlLogicalDev = "C" + Str(nCueCtrlDevPtr + 1)   ; eg C1, C2, etc
          gnNextDevId + 1
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nDevId = gnNextDevId
          nMidiCommandIndex = -1
          
        Case "PRCCDEVTYPE"  ; (post build 20150401)
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nDevType = encodeDevType(gsData)
          
          ; cue control DMX
        Case "PRCCDMXPREF"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nDMXInPref = encodeDMXPref(gsData)
        Case "PRCCDMXTRGCTRL"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nDMXTrgCtrl = encodeDMXTrgCtrl(gsData)
        Case "PRCCDMXTRGVALUE"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nDMXTrgValue = Val(gsData)
        Case "PRCCDMXCOMMAND"
          rThisDMXCommand = grDMXCommandDef
          nDMXCommandIndex = -1
        Case "PRCCDMXCMDTYPE"
          nDMXCommandIndex = encodeDMXCommand(gsData)
        Case "PRCCDMXCMDCHANNEL"
          rThisDMXCommand\nChannel = Val(gsData)
        Case "/PRCCDMXCOMMAND"
          If (nDMXCommandIndex >= 0) And (nDMXCommandIndex <= #SCS_MAX_DMX_COMMAND)
            rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\aDMXCommand[nDMXCommandIndex] = rThisDMXCommand
          EndIf

          ; cue control MIDI
        Case "PRCCMIDICHANNEL"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nMidiChannel = Val(gsData)
        Case "PRCCMIDIDEVID"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nMscMmcMidiDevId = Val(gsData)
        Case "PRCCMIDICTRLMETHOD"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nCtrlMethod = encodeCtrlMethod(gsData)
        Case "PRCCMIDIMSCCMDFORMAT"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nMscCommandFormat = Val(gsData)
        Case "PRCCMIDIGOMACRO"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nGoMacro = Val(gsData)
        Case "PRCCMIDICOMMAND"
          rThisMidiCommand = grMidiCommandDef
          nMidiCommandIndex = -1
        Case "PRCCMIDICMDTYPE"
          nMidiCommandIndex = encodeMidiCommand(gsData, @rProd)
          ; debugMsg0(sProcName, "gsData=" + gsData + ", nMidiCommandIndex=" + nMidiCommandIndex)
        Case "PRCCMIDICMD"
          rThisMidiCommand\nCmd = Val(gsData)   ; 08H = Note Off, 09H = Note On, etc
        Case "PRCCMIDICC"
          rThisMidiCommand\nCC = Val(gsData)    ; CC or KK, etc
        Case "PRCCMIDIVV"
          rThisMidiCommand\nVV = Val(gsData)    ; 0-127, or #SCS_MIDI_ANY_VALUE (-99)
        Case "/PRCCMIDICOMMAND"
          If (nMidiCommandIndex >= 0) And (nMidiCommandIndex <= #SCS_MAX_MIDI_COMMAND)
            rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\aMidiCommand[nMidiCommandIndex] = rThisMidiCommand
          EndIf
        Case "PRCCMMCAPPLYFADEFORSTOP"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\bMMCApplyFadeForStop = stringToBoolean(gsData)

          ; cue control Network (TCP/UDP)
        Case "PRCCNETWORKMSGFORMAT"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nNetworkMsgFormat = encodeNetworkMsgFormat(gsData)
        Case "PRCCNETWORKPROTOCOL"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nNetworkProtocol = encodeNetworkProtocol(gsData)
        Case "PRCCNETWORKREMOTEDEV"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nCueNetworkRemoteDev = encodeCueNetworkRemoteDev(gsData)
        Case "PRCCNETWORKROLE"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nNetworkRole = encodeNetworkRole(gsData)
        Case "PRCCX32COMMAND"
          rThisX32Command = grX32CommandDef
          nX32CommandIndex = -1
        Case "PRCCX32CMDTYPE"
          nX32CommandIndex = encodeX32Command(gsData)
        Case "PRCCX32BTN"
          rThisX32Command\nX32Button = Val(gsData)
        Case "/PRCCX32COMMAND"
          If (nX32CommandIndex >= 0) And (nX32CommandIndex <= #SCS_MAX_X32_COMMAND)
            rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\aX32Command[nX32CommandIndex] = rThisX32Command
          EndIf
          
          ; cue control RS232
        Case "PRCCRS232DATABITS"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nRS232DataBits = Val(gsData)
        Case "PRCCRS232STOPBITS"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\fRS232StopBits = ValF(gsData)
        Case "PRCCRS232PARITY"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nRS232Parity = encodeParity(gsData)
        Case "PRCCRS232BAUDRATE"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nRS232BaudRate = Val(gsData)
        Case "PRCCRS232HANDSHAKING"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nRS232Handshaking = encodeHandshaking(gsData)
        Case "PRCCRS232RTSENABLE"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nRS232RTSEnable = Val(gsData)
        Case "PRCCRS232DTRENABLE"
          rProd\aCueCtrlLogicalDevs(nCueCtrlDevPtr)\nRS232DTREnable = Val(gsData)
          
        Case "PRCSDELAYBEFORERELOADNAMES"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDelayBeforeReloadNames = Val(gsData)
          
        Case "PRCSDEVICE"
          nCtrlSendDevPtr + 1
          REDIM_ARRAY2(rProd\aCtrlSendLogicalDevs, nCtrlSendDevPtr, grCtrlSendLogicalDevsDef)
          If nCtrlSendDevPtr > rProd\nMaxCtrlSendLogicalDev
            rProd\nMaxCtrlSendLogicalDev = nCtrlSendDevPtr
          EndIf
          gnNextDevId + 1
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevId = gnNextDevId
          nMsgResponseIndex = -1
          
        Case "/PRCSDEVICE"
          If rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
            debugMsg(sProcName, "converting Control Send DMX Device " + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev + " to a Lighting Device")
            ; DMX Send now handled by Lighting, so convert this Control Device to a Lighting Device
            nLightingDevPtr + 1
            If nLightingDevPtr > ArraySize(rProd\aLightingLogicalDevs())
              ReDim rProd\aLightingLogicalDevs(nLightingDevPtr+5)
            EndIf
            rProd\aLightingLogicalDevs(nLightingDevPtr) = grLightingLogicalDevsDef
            If nLightingDevPtr > rProd\nMaxLightingLogicalDev : rProd\nMaxLightingLogicalDev = nLightingDevPtr : EndIf
            rProd\aLightingLogicalDevs(nLightingDevPtr)\nDevId = rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevId
            rProd\aLightingLogicalDevs(nLightingDevPtr)\nDevType = rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevType
            rProd\aLightingLogicalDevs(nLightingDevPtr)\sLogicalDev = rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev
            nMsgResponseIndex = -1
            ; 'delete' the Control Send Device
            nCtrlSendDevPtr - 1
            rProd\nMaxCtrlSendLogicalDev - 1
          EndIf
          
        Case "PRCSDEVTYPE"  ; (post build 20150401)
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevType = encodeDevType(gsData)
          debugMsg(sProcName, "sTagCode=" + sTagCode + ", rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\nDevType=" + decodeDevType(rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevType))
          
        Case "PRCSLOGICALDEV"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev = gsData
          debugMsg(sProcName, "sTagCode=" + sTagCode + ", rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\sLogicalDev=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev)
          
        Case "PRCSM2TSKIPEARLIERCTRLMSGS"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bM2TSkipEarlierCtrlMsgs = stringToBoolean(gsData)
          
        Case "PRCSCONNECTWHENREQD", "PRCSMAYOPENWHENREQD" ; Added 19Sep2022 11.9.6
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bConnectWhenReqd = stringToBoolean(gsData)
          
        Case "PRCSGETREMDEVSCRIBBLESTRIPNAMES" ; Added 6May2024 11.10.2cn
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bGetRemDevScribbleStripNames = stringToBoolean(gsData)
          
          ; control send DMX
          
          ; control send HTTP
        Case "PRCSHTTPSTART"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sHTTPStart = gsData
          
          ; control send MIDI
        Case "PRCSMIDICHANNEL"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlMidiChannel = Val(gsData)
        Case "PRCSMIDIFORMTC"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bCtrlMidiForMTC = stringToBoolean(gsData)
        Case "PRCSMIDIREMOTEDEVCODE"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlMidiRemoteDevCode = gsData
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlMidiRemDevId = CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_MIDI_OUT, gsData)
          debugMsg(sProcName, "rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\sCtrlMidiRemoteDevCode=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlMidiRemoteDevCode +
                              ", \nCtrlMidiRemDevId=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlMidiRemDevId)
          
          ; control send Network (TCP/UDP)
        Case "PRCSNETWORKREMOTEDEV"
          CompilerIf #c_csrd_network_available
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlNetworkRemoteDevCode = gsData
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlNetworkRemoteDev = encodeCtrlNetworkRemoteDev(gsData)
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlNetworkRemDevId = CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_NETWORK_OUT, gsData)
            debugMsg(sProcName, "rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\sCtrlNetworkRemoteDevCode=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlNetworkRemoteDevCode +
                                ", \nCtrlNetworkRemoteDev=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlNetworkRemoteDev +
                                ", \nCtrlNetworkRemDevId=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlNetworkRemDevId)
          CompilerElse
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlNetworkRemoteDev = encodeCtrlNetworkRemoteDev(gsData)
;             ; Added 17May2025
;             Select gsData
;               Case "OSC-X32", "X32"
;                 rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlMidiRemoteDevCode = "BR_X32"
;                 rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlMidiRemDevId = CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_MIDI_OUT, "BR_X32")
;                 debugMsg0(sProcName, "rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\sCtrlMidiRemoteDevCode=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlMidiRemoteDevCode +
;                                      ", \nCtrlMidiRemDevId=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlMidiRemDevId)
;             EndSelect
;             ; End added 17May2025
          CompilerEndIf
        Case "PRCSNETWORKREMOTEDEVPW"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sCtrlNetworkRemoteDevPassword = gsData
        Case "PRCSNETWORKOSCVERSION"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nOSCVersion = encodeOSCVersion(gsData)
        Case "PRCSNETWORKPROTOCOL"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nNetworkProtocol = encodeNetworkProtocol(gsData)
        Case "PRCSNETWORKROLE"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nNetworkRole = encodeNetworkRole(gsData)
        Case "PRCSNETWORKMSGRESPONSE"
          rThisMsgResponse = grMsgResponse
        Case "PRCSNETWORKRECEIVEMSG"
          rThisMsgResponse\sReceiveMsg = gsData
          rThisMsgResponse\sComparisonMsg = makeComparisonMsg(rThisMsgResponse\sReceiveMsg)
        Case "PRCSNETWORKMSGACTION"
          rThisMsgResponse\nMsgAction = encodeNetworkMsgAction(gsData)
        Case "PRCSNETWORKREPLYMSG"
          rThisMsgResponse\sReplyMsg = gsData
        Case "/PRCSNETWORKMSGRESPONSE"
          debugMsg(sProcName, "/PRCSNETWORKMSGRESPONSE, nMsgResponseIndex=" + nMsgResponseIndex)
          bIgnoreThisCSMsg = #False
          Select rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nCtrlNetworkRemoteDev
            Case #SCS_CS_NETWORK_REM_PJLINK, #SCS_CS_NETWORK_REM_PJNET
              Select rThisMsgResponse\sReceiveMsg
                Case "Hello", "PJLINK 0", "PJLINK 1"
                  ; ignore - no longer necessary to list these messages (as at 11.6.1as) as processNetworkInput_NonOSC() tests for these specific messages
                  bIgnoreThisCSMsg = #True
              EndSelect
          EndSelect
          If bIgnoreThisCSMsg = #False
            If nMsgResponseIndex < #SCS_MAX_NETWORK_MSG_RESPONSE
              nMsgResponseIndex + 1
              rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\aMsgResponse[nMsgResponseIndex] = rThisMsgResponse
              If nMsgResponseIndex > rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nMaxMsgResponse
                rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nMaxMsgResponse = nMsgResponseIndex
              EndIf
            EndIf
            debugMsg(sProcName, "/PRCSNETWORKMSGRESPONSE, rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\nMaxMsgResponse=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nMaxMsgResponse)
          EndIf
        Case "PRCSNETWORKREPLYMSGADDCR"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bReplyMsgAddCR = stringToBoolean(gsData)
        Case "PRCSNETWORKREPLYMSGADDLF"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bReplyMsgAddLF = stringToBoolean(gsData)
          
          ; control send RS232
;         Case "PRCSRS232PORT"
;           rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sRS232PortAddress = gsData
        Case "PRCSRS232DATABITS"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nRS232DataBits = Val(gsData)
        Case "PRCSRS232STOPBITS"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\fRS232StopBits = ValF(gsData)
        Case "PRCSRS232PARITY"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nRS232Parity = encodeParity(gsData)
        Case "PRCSRS232BAUDRATE"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nRS232BaudRate = Val(gsData)
        Case "PRCSRS232HANDSHAKING"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nRS232Handshaking = encodeHandshaking(gsData)
        Case "PRCSRS232RTSENABLE"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nRS232RTSEnable = Val(gsData)
        Case "PRCSRS232DTRENABLE"
          rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nRS232DTREnable = Val(gsData)
          
        Case "PRCTRLSENDDEVDESC"  ; PRCTRLSENDDEVDESC    ; SCS10
          
        Case "PRCTRLSENDDEVTYPE"  ; PRCTRLSENDDEVTYPE    ; SCS11 (pre build 20150401)
          If rProd\nFileBuild < 20150401
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevType = encodeDevType(gsData)
          EndIf
          
        Case "PRCTRLSENDFORMTC"  ; PRCTRLSENDFORMTC  ; (pre build 20150401)
          If rProd\nFileBuild < 20150401
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\bCtrlMidiForMTC = stringToBoolean(gsData)
          EndIf
          
        Case "PRCTRLSENDLOGICALDEV"  ; PRCTRLSENDLOGICALDEV  ; (pre build 20150401)
          If rProd\nFileBuild < 20150401
            If Trim(gsData)
              nTagIndexID = 2000 + nTagIndex
              If nTagIndexID <> nLastTagIndexID
                nLastTagIndexID = nTagIndexID
                nCtrlSendDevPtr + 1
                If nCtrlSendDevPtr > ArraySize(rProd\aCtrlSendLogicalDevs())
                  ReDim rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr+5)
                EndIf
                rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr) = grCtrlSendLogicalDevsDef
                If nCtrlSendDevPtr > rProd\nMaxCtrlSendLogicalDev : rProd\nMaxCtrlSendLogicalDev = nCtrlSendDevPtr : EndIf
              EndIf
              rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev = gsData
              debugMsg(sProcName, "rProd\aCtrlSendLogicalDevs(" + nCtrlSendDevPtr + ")\sLogicalDev=" + rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev)
              gnNextDevId + 1
              rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\nDevId = gnNextDevId
              nMsgResponseIndex = -1
            EndIf
          EndIf
          
        Case "PRDEVVST"
          ; see also PRVSTPLUGIN
          If sUpAttributeName1 = "NAME"
            nDevPluginIndex + 1
            If nDevPluginIndex > ArraySize(rVST\aDevVSTPlugin())
              ReDim rVST\aDevVSTPlugin(nDevPluginIndex)
            EndIf
            rVST\aDevVSTPlugin(nDevPluginIndex) = grDevVSTPluginDef
            rVST\aDevVSTPlugin(nDevPluginIndex)\sDevVSTPluginName = gsTagAttributeValue1
          EndIf
          nVSTParamIndex = -1

        Case "PRDEVVSTBYPASS"
          rVST\aDevVSTPlugin(nDevPluginIndex)\bDevVSTBypass = stringToBoolean(gsData)
          
        Case "PRDEVVSTCHUNKDATA"
          rVST\aDevVSTPlugin(nDevPluginIndex)\rDevVSTChunk\sChunkData = gsData
          
        Case "PRDEVVSTCHUNKMAGIC"
          rVST\aDevVSTPlugin(nDevPluginIndex)\rDevVSTChunk\sChunkMagic = gsData
          If sUpAttributeName1 = "BYTESIZE"
            rVST\aDevVSTPlugin(nDevPluginIndex)\rDevVSTChunk\nByteSize = Val(gsTagAttributeValue1)
          EndIf
          debugMsg(sProcName, "rVST\aDevVSTPlugin(" + nDevPluginIndex + ")\rDevVSTChunk\sChunkMagic=" + rVST\aDevVSTPlugin(nDevPluginIndex)\rDevVSTChunk\sChunkMagic + ", \nByteSize=" + rVST\aDevVSTPlugin(nDevPluginIndex)\rDevVSTChunk\nByteSize)
          
        Case "PRDEVVSTCOMMENT"
          rVST\aDevVSTPlugin(nDevPluginIndex)\sDevVSTComment = gsData
          
        Case "PRDEVVSTDEVICE"
          rVST\aDevVSTPlugin(nDevPluginIndex)\sDevVSTLogicalDev = gsData
          
        Case "PRDEVVSTORDER"
          rVST\aDevVSTPlugin(nDevPluginIndex)\nDevVSTOrder = Val(gsData)
          
        Case "PRDEVVSTPROGRAM"
          rVST\aDevVSTPlugin(nDevPluginIndex)\nDevVSTProgram = Val(gsData)
          
        Case "PRDEVVSTPARAM"
          nVSTParamIndex + 1
          If nVSTParamIndex > ArraySize(rVST\aDevVSTPlugin(nDevPluginIndex)\aDevVSTParam())
            ReDim rVST\aDevVSTPlugin(nDevPluginIndex)\aDevVSTParam(nVSTParamIndex)
          EndIf
          rVST\aDevVSTPlugin(nDevPluginIndex)\nDevVSTMaxParam = nVSTParamIndex
          rVST\aDevVSTPlugin(nDevPluginIndex)\aDevVSTParam(nVSTParamIndex)\nVSTParamIndex = Val(gsTagAttributeValue1)
          rVST\aDevVSTPlugin(nDevPluginIndex)\aDevVSTParam(nVSTParamIndex)\fVSTParamValue = ValF(gsData)
          
        Case "PRELOADNEXTMANUALONLY"  ; PRELOADNEXTMANUALONLY
          rProd\bPreLoadNextManualOnly = stringToBoolean(gsData)
          
        Case "PREVIEWDEVICE"  ; PREVIEWDEVICE
          rProd\sPreviewDevice = gsData
          
        Case "PREVIEWLEVEL"  ; PREVIEWLEVEL
          rProd\fPreviewBVLevel = ValF(gsData)
          
        Case "PRINGRP"  ; PRINGRP
          nInGrpIndex + 1
          REDIM_ARRAY2(rProd\aInGrps, nInGrpIndex+5, grInGrpsDef)
          rProd\nMaxInGrp = nInGrpIndex
          nGrpItemIndex = -1
          rProd\aInGrps(nInGrpIndex)\nMaxInGrpItem = nGrpItemIndex
          rProd\aInGrps(nInGrpIndex)\nMaxInGrpItemDisplay = nGrpItemIndex + 1
          
        Case "PRINGRPDEV"  ; PRINGRPDEV
          nGrpItemIndex + 1
          rProd\aInGrps(nInGrpIndex)\nMaxInGrpItem = nGrpItemIndex
          rProd\aInGrps(nInGrpIndex)\nMaxInGrpItemDisplay = nGrpItemIndex + 1
          If nGrpItemIndex > ArraySize(rProd\aInGrps(nInGrpIndex)\aInGrpItem())
            ReDim rProd\aInGrps(nInGrpIndex)\aInGrpItem(nGrpItemIndex + 5)
          EndIf
          rProd\aInGrps(nInGrpIndex)\aInGrpItem(nGrpItemIndex)\sInGrpItemLiveInput = Trim(gsData)
          rProd\aInGrps(nInGrpIndex)\aInGrpItem(nGrpItemIndex)\nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT
          
        Case "PRINGRPNAME"  ; PRINGRPNAME
          rProd\aInGrps(nInGrpIndex)\sInGrpName = Trim(gsData)
          
        Case "PRINPUTFORLTC" ; PRINPUTFORLTC
          rProd\aLiveInputLogicalDevs(nTagIndex)\bInputForLTC = stringToBoolean(gsData)
          
        Case "PRINPUTLOGICALDEV"  ; PRINPUTLOGICALDEV
          REDIM_ARRAY2(rProd\aLiveInputLogicalDevs, nTagIndex, grLiveInputLogicalDevsDef)
          If nTagIndex > rProd\nMaxLiveInputLogicalDev
            rProd\nMaxLiveInputLogicalDev = nTagIndex
          EndIf
          rProd\aLiveInputLogicalDevs(nTagIndex)\sLogicalDev = gsData
          gnNextDevId + 1
          rProd\aLiveInputLogicalDevs(nTagIndex)\nDevId = gnNextDevId
          rProd\aLiveInputLogicalDevs(nTagIndex)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
          If rProd\aLiveInputLogicalDevs(nTagIndex)\nNrOfInputChans = 0
            rProd\aLiveInputLogicalDevs(nTagIndex)\nNrOfInputChans = 1
          EndIf
          
        Case "PRLOGICALDEV"  ; PRLOGICALDEV
          REDIM_ARRAY2(rProd\aAudioLogicalDevs, nTagIndex, grAudioLogicalDevsDef)
          If nTagIndex > rProd\nMaxAudioLogicalDev
            rProd\nMaxAudioLogicalDev = nTagIndex
          EndIf
          rProd\aAudioLogicalDevs(nTagIndex)\sLogicalDev = gsData
          gnNextDevId + 1
          rProd\aAudioLogicalDevs(nTagIndex)\nDevId = gnNextDevId
          rProd\aAudioLogicalDevs(nTagIndex)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          If rProd\aAudioLogicalDevs(nTagIndex)\nNrOfOutputChans = 0
            rProd\aAudioLogicalDevs(nTagIndex)\nNrOfOutputChans = 2
          EndIf
          
        Case "PRLOGICALDEVTYPE"  ; PRLOGICALDEVTYPE
          rProd\aAudioLogicalDevs(nTagIndex)\nDevType = encodeDevType(gsData)
          
        Case "PRLTDEVICE"
          nLightingDevPtr + 1
          REDIM_ARRAY2(rProd\aLightingLogicalDevs, nLightingDevPtr, grLightingLogicalDevsDef)
          If nLightingDevPtr > rProd\nMaxLightingLogicalDev
            rProd\nMaxLightingLogicalDev = nLightingDevPtr
          EndIf
          gnNextDevId + 1
          rProd\aLightingLogicalDevs(nLightingDevPtr)\nDevId = gnNextDevId
          nMsgResponseIndex = -1
          
        Case "PRLTDEVTYPE"
          rProd\aLightingLogicalDevs(nLightingDevPtr)\nDevType = encodeDevType(gsData)
        Case "PRLTFIXTURE"
          rFixture = grFixtureLogicalDef
          gnUniqueRef + 1
          rFixture\nFixtureId = gnUniqueRef
        Case "/PRLTFIXTURE"
          rProd\aLightingLogicalDevs(nLightingDevPtr)\nMaxFixture + 1
          n = rProd\aLightingLogicalDevs(nLightingDevPtr)\nMaxFixture
          If n > ArraySize(rProd\aLightingLogicalDevs(nLightingDevPtr)\aFixture())
            ReDim rProd\aLightingLogicalDevs(nLightingDevPtr)\aFixture(n+5)
          EndIf
          rProd\aLightingLogicalDevs(nLightingDevPtr)\aFixture(n) = rFixture
        Case "PRLTFIXTURECODE"
          rFixture\sFixtureCode = gsData
        Case "PRLTFIXTUREDESC"
          rFixture\sFixtureDesc = gsData
        Case "PRLTFIXTUREDFLTSTARTCHAN" ; Added 9Sep2021 11.8.6ah
          rFixture\nDefaultDMXStartChannel = Val(gsData)
        Case "PRLTFIXTURETYPE"
          rFixture\sFixTypeName = gsData
        Case "PRLTFIXTUREFADEABLECHANNELS", "PRLTFIXTUREDIMMABLECHANNELS"
          rFixture\sDimmableChannels = gsData
        Case "PRLTLOGICALDEV"
          rProd\aLightingLogicalDevs(nLightingDevPtr)\sLogicalDev = gsData
          
        Case "PRMEMODISPOPTFORPRIM"
          rProd\nMemoDispOptForPrim = encodeMemoDispOptForPrim(gsData)
          
        Case "PRMIDILOGICALDEV"  ; PRMIDILOGICALDEV ; SCS 10 - changed to ctrl send devices in SCS11
          If Trim(gsData)
            nTagIndexID = 1000 + nTagIndex
            If nTagIndexID <> nLastTagIndexID
              nLastTagIndexID = nTagIndexID
              nCtrlSendDevPtr + 1
              If nCtrlSendDevPtr > ArraySize(rProd\aCtrlSendLogicalDevs())
                ReDim rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)
              EndIf
              rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr) = grCtrlSendLogicalDevsDef
              If nCtrlSendDevPtr > rProd\nMaxCtrlSendLogicalDev : rProd\nMaxCtrlSendLogicalDev = nCtrlSendDevPtr : EndIf
            EndIf
            rProd\aCtrlSendLogicalDevs(nCtrlSendDevPtr)\sLogicalDev = gsData
          EndIf
          
        Case "PRMIDIPLAYBACKDEV"  ; PRMIDIPLAYBACKDEV    ; SCS10 physical dev for PRMIDILOGICALDEV (above)
          
        Case "PRNUMCHANS"  ; PRNUMCHANS
          rProd\aAudioLogicalDevs(nTagIndex)\nNrOfOutputChans = Val(gsData)
          
        Case "PRNUMINPUTCHANS"  ; PRNUMINPUTCHANS
          rProd\aLiveInputLogicalDevs(nTagIndex)\nNrOfInputChans = Val(gsData)
          
        Case "PRODID"  ; PRODID
          rProd\sProdId = gsData
          If rProd\sProdId
            rProd\bProdIdFoundInCueFile = #True
            ; the above flag is used to indicate if the associated device map file is expected to have the ProdId in the filename
          EndIf
          
        Case "PRODTIMERACTION"
          rCue\nProdTimerAction = encodeProdTimerAction(gsData)
          grWTI\bCheckWindowExistsAndVisible = #True
          
        Case "PRODTIMERSAVEHIST"
          rProd\bSaveProdTimerHistory = stringToBoolean(gsData)
          
        Case "PRODTIMERTIMESTAMPHIST"
          rProd\bTimeStampProdTimerHistoryFiles = stringToBoolean(gsData)
          
        Case "PRODUCTION"  ; PRODUCTION
          ; see also HEAD and /HEAD
          
        Case "PRSPEAKER"  ; PRSPEAKER
          ; If PRSPEAKER exists then this file is pre-SCS 10.8 and so populate values for PRFIRSTOUTPUTCHAN and PRNUMCHANS from the PRSPEAKER data
          ; nSpeaker = SpeakerInternalCode(gsData, @nSpeakerCount, @nFirstASIOChannel)
          nOutputArrayIndex = getOutputArrayIndexForSpeakerDesc(gsData)
          If nOutputArrayIndex >= 0
            With rProd\aAudioLogicalDevs(nTagIndex)
              \nNrOfOutputChans = gaOutputArray(nOutputArrayIndex)\nChans
              debugMsg(sProcName, "gsTag=" + gsTag + ", rProd\aAudioLogicalDevs(" + nTagIndex + ")\sLogicalDev=" + \sLogicalDev + ", \nNrOfOutputChans=" + \nNrOfOutputChans)
            EndWith
          EndIf
          
        Case "PRTAPALLOWED"
          rProd\bTapAllowed = stringToBoolean(gsData)
          
        Case "PRTAPSHORTCUT"
          rProd\sTapShortcutStr = Trim(gsData)
          
        Case "PRVIDAUDLOGICALDEV"  ; PRVIDAUDLOGICALDEV
          REDIM_ARRAY2(rProd\aVidAudLogicalDevs, nTagIndex, grVidAudLogicalDevsDef)
          If nTagIndex > rProd\nMaxVidAudLogicalDev
            rProd\nMaxVidAudLogicalDev = nTagIndex
          EndIf
          rProd\aVidAudLogicalDevs(nTagIndex)\sVidAudLogicalDev = gsData
          gnNextDevId + 1
          rProd\aVidAudLogicalDevs(nTagIndex)\nDevId = gnNextDevId
          rProd\aVidAudLogicalDevs(nTagIndex)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
          If rProd\aVidAudLogicalDevs(nTagIndex)\nNrOfOutputChans = 0
            rProd\aVidAudLogicalDevs(nTagIndex)\nNrOfOutputChans = 2
          EndIf
          
        Case "PRVIDAUDROUTETOAUDLOGICALDEV"  ; PRVIDAUDROUTETOAUDLOGICALDEV
          rProd\aVidAudLogicalDevs(nTagIndex)\sRouteToAudioLogicalDev = gsData
          
        Case "PRVIDCAPLOGICALDEV"  ; PRVIDCAPLOGICALDEV
          REDIM_ARRAY2(rProd\aVidCapLogicalDevs, nTagIndex, grVidCapLogicalDevsDef)
          If nTagIndex > rProd\nMaxVidCapLogicalDev
            rProd\nMaxVidCapLogicalDev = nTagIndex
          EndIf
          rProd\aVidCapLogicalDevs(nTagIndex)\sLogicalDev = gsData
          gnNextDevId + 1
          rProd\aVidCapLogicalDevs(nTagIndex)\nDevId = gnNextDevId
          rProd\aVidCapLogicalDevs(nTagIndex)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
          
        Case "PRVSTPLUGIN"
          ; see also PRDEVVST
          If sUpAttributeName1 = "NAME"
            nLibPluginIndex + 1
            If nLibPluginIndex > ArraySize(rVST\aLibVSTPlugin())
              ReDim rVST\aLibVSTPlugin(nLibPluginIndex)
            EndIf
            rVST\aLibVSTPlugin(nLibPluginIndex) = grLibVSTPluginDef
            rVST\aLibVSTPlugin(nLibPluginIndex)\sLibVSTPluginName = gsTagAttributeValue1
          EndIf
          
        Case "PRVSTPLUGINS"
          nLibPluginIndex = -1
          nDevPluginIndex = -1
          
        Case "/PRVSTPLUGINS"
          rVST\nMaxLibVSTPlugin = nLibPluginIndex
          rVST\nMaxDevVSTPlugin = nDevPluginIndex
          
;}
;{ R          
         Case "RELMTCSTARTTIMEFORSUB" ; RELMTCSTARTTIMEFORSUB
          rSub\nRelMTCStartTimeForSub = encodeMTCTime(gsData)
          
        Case "RELSTARTMODE"  ; RELSTARTMODE
          rSub\nRelStartMode = encodeRelStartMode(gsData)
          
        Case "RELSTARTSYNCWITHSUB"  ; RELSTARTSYNCWITHSUB
          rSub\sRelStartSyncWithSub = gsData
          
        Case "RELSTARTTIME", "SUBCUEDELAY" ; RELSTARTTIME, SUBCUEDELAY
          rSub\nRelStartTime = Val(gsData)
          
        Case "REMDEVLEVEL"  ; REMDEVLEVEL
          rSub\aCtrlSend[nCtrlSendIndex]\sRemDevLevel = gsData
          
        Case "REMDEVMSGTYPE" ; REMDEVMSGTYPE
          rSub\aCtrlSend[nCtrlSendIndex]\sRemDevMsgType = gsData
          ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\sRemDevMsgType=" + rSub\aCtrlSend[nCtrlSendIndex]\sRemDevMsgType)

        Case "REMDEVMUTEACTION", "REMDEVACTION"  ; REMDEVMUTEACTION (NB "MUTE" added to "REMDEVACTION" to clarify what this is exclusively used for)
          rSub\aCtrlSend[nCtrlSendIndex]\nRemDevMuteAction = encodeMuteAction(gsData)
          grEditMem\nLastRemDevMuteAction = rSub\aCtrlSend[nCtrlSendIndex]\nRemDevMuteAction
          
        Case "REMDEVVALUE"  ; REMDEVVALUE and REMDEVVALUE2
          If nTagIndex = 2
            rSub\aCtrlSend[nCtrlSendIndex]\sRemDevValue2 = gsData
            ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\sRemDevValue2=" + rSub\aCtrlSend[nCtrlSendIndex]\sRemDevValue2)
          Else
            rSub\aCtrlSend[nCtrlSendIndex]\sRemDevValue = gsData
            ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\sRemDevValue=" + rSub\aCtrlSend[nCtrlSendIndex]\sRemDevValue)
          EndIf
          
        Case "REPEATAT"  ; REPEATAT (SCS 8 equivalent of LoopEnd)
          rAud\aLoopInfo(0)\nLoopEnd = Val(gsData)
          rAud\aLoopInfo(0)\nLoopStart = -3   ; loop start in SCS 8 assumed StartAt
          
        Case "RESETTOD"  ; RESETTOD
          CompilerIf #c_set_tbc_time_in_cues
            Protected sResetTod.s
            sResetTod = Trim(InputRequester(sProcName, "Time to reset time-based-cues (seconds after midnight)", gsData))
            If sResetTod
              rProd\nResetTOD = Val(sResetTod)
            Else
              rProd\nResetTOD = Val(gsData)
            EndIf
          CompilerElse
            rProd\nResetTOD = Val(gsData)
          CompilerEndIf
          
        Case "ROTATE"  ; ROTATE
          rAud\nRotate = Val(gsData)
          
        Case "RPFILENAME"  ; RPFILENAME
          rSub\sRPFileName = decodeFileName(gsData, bPrimaryFile)
          
        Case "RPHIDE"  ; RPHIDE
          rSub\bRPHideSCS = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastRPHideSCS = rSub\bRPHideSCS
          EndIf
          
        Case "RPINVISIBLE"  ; RPINVISIBLE
          rSub\bRPInvisible = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastRPInvisible = rSub\bRPInvisible
          EndIf
          
        Case "RPPARAMS"  ; RPPARAMS
          rSub\sRPParams = decodeFileName(gsData, bPrimaryFile, #False)
          
        Case "RPSTARTFOLDER"  ; RPSTARTFOLDER
          rSub\sRPStartFolder = decodeFileName(gsData, bPrimaryFile)
          
        Case "RS232ADDCR", "NETWORKADDCR", "TELNETADDCR"  ; RS232ADDCR, NETWORKADDCR (TELNETADDCR included for backward-compatibility)
          rSub\aCtrlSend[nCtrlSendIndex]\bAddCR = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastAddCR = rSub\aCtrlSend[nCtrlSendIndex]\bAddCR
          EndIf
          ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\bAddCR=" + strB(rSub\aCtrlSend[nCtrlSendIndex]\bAddCR))
          
        Case "RS232ADDLF", "NETWORKADDLF", "TELNETADDLF"  ; RS232ADDLF, NETWORKADDLF
          rSub\aCtrlSend[nCtrlSendIndex]\bAddLF = stringToBoolean(gsData)
          If bPrimaryFile
            grEditMem\bLastAddLF = rSub\aCtrlSend[nCtrlSendIndex]\bAddLF
          EndIf
          ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\bAddLF=" + strB(rSub\aCtrlSend[nCtrlSendIndex]\bAddLF))
          
        Case "RS232DATA", "MIDIDATA", "NETWORKDATA", "OSCDATA", "TELNETDATA", "HTTPDATA"  ; RS232DATA, MIDIDATA, NETWORKDATA, OSCDATA, TELNETDATA. HTTPDATA
          rSub\aCtrlSend[nCtrlSendIndex]\sEnteredString = gsData
          ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\sEnteredString=" + rSub\aCtrlSend[nCtrlSendIndex]\sEnteredString)
          
        Case "RS232ENTRYMODE", "NETWORKENTRYMODE", "TELNETENTRYMODE"  ; RS232ENTRYMODE, NETWORKENTRYMODE
          rSub\aCtrlSend[nCtrlSendIndex]\nEntryMode = encodeEntryMode(gsData)
          If bPrimaryFile
            grEditMem\nLastEntryMode = rSub\aCtrlSend[nCtrlSendIndex]\nEntryMode
          EndIf
          ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\nEntryMode=" + decodeEntryMode(rSub\aCtrlSend[nCtrlSendIndex]\nEntryMode))
          
        Case "RUNMODE"  ; RUNMODE
          rProd\nRunMode = encodeRunMode(gsData)  ; modified 30Oct2015 11.4.1.2f (was Val(gsData))
          debugMsg(sProcName, "rProd\nRunMode=" + rProd\nRunMode + " (" + decodeRunMode(rProd\nRunMode) + ")")
          
;}
;{ S          
         Case "SCREENS", "OUTPUTSCREENS"  ; SCREENS, OUTPUTSCREENS
          rSub\sScreens = gsData
          
        Case "SCRIBBLESTRIP"
          rSub\aCtrlSend[nCtrlSendIndex]\nMaxScribbleStripItem = -1
          If sUpAttributeName1 = "SSITEMCOUNT"
            nSSItemCount = Val(gsTagAttributeValue1)
            If nSSItemCount > (ArraySize(rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem()) - 1)
              ReDim rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem(nSSItemCount-1)
            EndIf
          EndIf
          
        Case "SELHKBANK"  ; SELHKBANK
          rSub\nSelHKBank = Val(gsData)
          
        Case "SETPOSABSREL"  ; SETPOSABSREL
          rSub\nSetPosAbsRel = encodeSetPosAbsRel(gsData)
          
        Case "SETPOSCUE"  ; SETPOSCUE
          rSub\sSetPosCue = gsData
          
        Case "SETPOSCUEMARKER"  ; SETPOSCUEMARKER
          rSub\sSetPosCueMarker = gsData
          
        Case "SETPOSCUEMARKERSUBNO"  ; SETPOSCUEMARKERSUBNO
          rSub\nSetPosCueMarkerSubNo = Val(gsData)
          
        Case "SETPOSCUETYPE"  ; SETPOSCUETYPE ; Added 7Jun2022 11.9.2
          rSub\nSetPosCueType = encodeSetPosSetPosCueType(gsData)
          
        Case "SETPOSTIME"  ; SETPOSTIME
          rSub\nSetPosTime = Val(gsData)
          
        Case "SFRACTION"  ; SFRACTION
          rSub\nSFRAction[nTagIndex] = encodeSFRAction(gsData)
          
        Case "SFRCOMPLETEASSOCAUTOSTARTCUES"  ; SFRCOMPLETEASSOCAUTOSTARTCUES
          rSub\bSFRCompleteAssocAutoStartCues = stringToBoolean(gsData)
          
        Case "SFRCUE", "STOPCUE"    ; SFRCUE, STOPCUE
          rSub\sSFRCue[nTagIndex] = gsData
          
        Case "SFRCUETYPE", "STOPCUETYPE"  ; SFRCUETYPE, STOPCUETYPE
          If gsData = "apc"
            gsData = "play"
          EndIf
          rSub\nSFRCueType[nTagIndex] = encodeSFRCueType(gsData)
          
        Case "SFRGONEXT"  ; SFRGONEXT
          rSub\bSFRGoNext = stringToBoolean(gsData)
          
        Case "SFRGONEXTDELAY"  ; SFRGONEXTDELAY
          rSub\nSFRGoNextDelay = Val(gsData)
          
        Case "SFRHOLDASSOCAUTOSTARTCUES"  ; SFRHOLDASSOCAUTOSTARTCUES
          rSub\bSFRHoldAssocAutoStartCues = stringToBoolean(gsData)
          
        Case "SFRLOOPNO"  ; SFRLOOPNO
          rSub\nSFRLoopNo[nTagIndex] = Val(gsData)
          
        Case "SFRSUBNO"  ; SFRSUBNO
          rSub\nSFRSubNo[nTagIndex] = Val(gsData)
          
        Case "SFRTIMEOVERRIDE"  ; SFRTIMEOVERRIDE
          macReadNumericOrStringParam(gsData, rSub\sSFRTimeOverride, rSub\nSFRTimeOverride, grSubDef\nSFRTimeOverride, #False)
          ; Macro macReadNumericOrStringParam populates \sSFRTimeOverride and \nSFRTimeOverride from the value in gsData
          ; nb although this is a time field, pTimeField is set #False because in the cue file time fields are stored in milliseconds, not as n.n seconds
          
        Case "SIZE"  ; SIZE
          rAud\nSize = Val(gsData) * -1 ; negate to comply with pre-11.2.1 cue files
          
        Case "SOURCE" ; SOURCE of FILE/VIDEO/CAPTURE    
          rAud\nVideoSource = encodeVideoSource(gsData)  
          If rAud\nVideoSource = #SCS_VID_SRC_CAPTURE
            rAud\nVideoCaptureDeviceType = #SCS_DEVTYPE_VIDEO_CAPTURE
          EndIf
          
        Case "SSITEM" ; SSITEM (Scribble Strip Item)
          rSub\aCtrlSend[nCtrlSendIndex]\nMaxScribbleStripItem + 1
          nSSIndex = rSub\aCtrlSend[nCtrlSendIndex]\nMaxScribbleStripItem
          If nSSIndex > (ArraySize(rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem()))
            ; shouldn't get here as this ReDim should have occurred on processing "ScribbleStrip"
            ReDim rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem(nSSIndex)
          EndIf
          rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem(nSSIndex)\sSSItemName = gsData
          If sUpAttributeName1 = "SSCATEGORY"
            rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem(nSSIndex)\sSSValType = gsTagAttributeValue1
          EndIf
          If sUpAttributeName2 = "SSDATAVAL"
            rSub\aCtrlSend[nCtrlSendIndex]\aScribbleStripItem(nSSIndex)\nSSDataValue = Val(gsTagAttributeValue2)
          EndIf

        Case "STANDBY"  ; STANDBY
          rCue\nStandby = encodeStandby(gsData)
          
        Case "STARTAT"  ; STARTAT
          rAud\nStartAt = Val(gsData)
          
        Case "STARTATCPNAME"  ; STARTATCPNAME
          rAud\sStartAtCPName = gsData
          
        Case "STARTATSAMPLEPOS"  ; STARTATSAMPLEPOS
          rAud\qStartAtSamplePos = Val(gsData)
          
        Case "STOPALLINCLHIB"   ; STOPALLINCLHIB
          rProd\bStopAllInclHib = stringToBoolean(gsData)
          
        Case "SUB"  ; SUB
          ; set sub defaults
          rSub = grSubDef
          rSub\sCue = rCue\sCue       ; cue
          nSubNo + 1
          rSub\nSubNo = nSubNo        ; sub cue number
          nAudNo = 0
          nCtrlSendIndex = -1
          nCtrlSendDevType = #SCS_DEVTYPE_NONE
          nMSMsgType = #SCS_MSGTYPE_NONE
          bLTSubArraysSet = #False
          nChaseStepIndex = -1
          nDMXSendItemIndex = -1
          bConvertCtrlSendToLighting = #False
          nDMXFadeTime = -2
          bDMXItemFound = #False
          nEnableDisableIndex = -1
          rAud = grAudDef
          rFileData = grFileDataDef
          
        Case "/SUB"  ; /SUB
          With rSub
            If Len(\sSubDescr) = 0
              \sSubDescr = rCue\sCueDescr
            EndIf
            
            If \bSubTypeAorP
              For d = 0 To grLicInfo\nMaxAudDevPerSub
                \fSubMastBVLevel[d] = convertDBStringToBVLevel(\sPLMastDBLevel[d])
              Next d
              \nPLCurrFadeInTime = \nPLFadeInTime
              \nPLCurrFadeOutTime = \nPLFadeOutTime
              debugMsg(sProcName, \sSubLabel + ", \nPLCurrFadeInTime=" + \nPLCurrFadeInTime + ", \nPLCurrFadeOutTime=" + \nPLCurrFadeOutTime)
              If \bSubTypeA
                If \sVidAudLogicalDev = sDefVidAudDev
                  bDefVidAudReqd = #True
                EndIf
              EndIf
              
            ElseIf \bSubTypeE
              grWEN\bLastMemoContinuous = \bMemoContinuous
              grWEN\nLastMemoDisplayTime = \nMemoDisplayTime
              grWEN\nLastMemoDisplayWidth = \nMemoDisplayWidth
              grWEN\nLastMemoDisplayHeight = \nMemoDisplayHeight
              grWEN\nLastMemoPageColor = \nMemoPageColor
              grWEN\nLastMemoTextBackColor = \nMemoTextBackColor
              grWEN\nLastMemoTextColor = \nMemoTextColor
              grWEN\nLastMemoScreen = \nMemoScreen
              grWEN\bLastMemoResizeFont = \bMemoResizeFont
              grWEN\nLastMemoAspectRatio = \nMemoAspectRatio
              
            ElseIf \bSubTypeK
              ; no action here
              
            ElseIf \bSubTypeL
              Select \nLCAction
                Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
                  For d = 0 To grLicInfo\nMaxAudDevPerAud
                    If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                      \sLCReqdDBLevel[d] = readDBLevel(\sLCReqdDBLevel[d])
                      If ValF(\sLCReqdDBLevel[d]) < ValF(grLevels\sMinDBLevel)
                        \sLCReqdDBLevel[d] = grLevels\sMinDBLevel
                      EndIf
                    EndIf
                    \fLCReqdBVLevel[d] = convertDBStringToBVLevel(\sLCReqdDBLevel[d])
                  Next d
              EndSelect
              gnPrevLCAction = \nLCAction
              
            ElseIf \bSubTypeM
              For n = 0 To #SCS_MAX_CTRL_SEND
                If \aCtrlSend[n]\sRemDevMsgType
                  ; debugMsg(sProcName, \sSubLabel + ": \aCtrlSend[" + n + "]\sRemDevMsgType=" + \aCtrlSend[n]\sRemDevMsgType + ", \aCtrlSend[" + n + "]\sCSLogicalDev=" + \aCtrlSend[n]\sCSLogicalDev)
                  \aCtrlSend[n]\nRemDevId = CSRD_GetRemDevIdForLogicalDev(\aCtrlSend[n]\nDevType, \aCtrlSend[n]\sCSLogicalDev)
                  ; debugMsg(sProcName, \sSubLabel + ": \aCtrlSend[" + n + "]\nRemDevId=" + \aCtrlSend[n]\nRemDevId)
                  If \aCtrlSend[n]\nRemDevId > 0 ; should be #True
                    \aCtrlSend[n]\nRemDevMsgType = CSRD_EncodeRemDevMsgType(\aCtrlSend[n]\nRemDevId, \aCtrlSend[n]\sRemDevMsgType)
                    ; debugMsg(sProcName, \sSubLabel + ": \aCtrlSend[" + n + "]\nRemDevMsgType=" + \aCtrlSend[n]\nRemDevMsgType)
                    If \aCtrlSend[n]\nRemDevMsgType > 0 ; should be #True
                      If \aCtrlSend[n]\sRemDevLevel
                        ; debugMsg(sProcName, \sSubLabel + ": calling convertDBStringToBVLevel(" + \aCtrlSend[n]\sRemDevLevel + ", " + \aCtrlSend[n]\nRemDevMsgType + ")")
                        \aCtrlSend[n]\fRemDevBVLevel = convertDBStringToBVLevel(\aCtrlSend[n]\sRemDevLevel, \aCtrlSend[n]\nRemDevMsgType)
                        ; debugMsg(sProcName, \sSubLabel + ": \aCtrlSend[" + n + "]\fRemDevBVLevel=" + StrF(\aCtrlSend[n]\fRemDevBVLevel))
                      EndIf
                      ; debugMsg(sProcName, "calling CSRD_buildRemDisplayInfoForCtrlSendItem(@rSub, " + n + ")")
                      CSRD_buildRemDisplayInfoForCtrlSendItem(@rSub, n)
                      grEditMem\nLastRemDevMsgType = \aCtrlSend[n]\nRemDevMsgType
                      ; debugMsg0(sProcName, "grEditMem\nLastRemDevMsgType=" + decodeMsgType(grEditMem\nLastRemDevMsgType))
                    EndIf
                  EndIf
                Else
                  buildDisplayInfoForCtrlSend(@rSub, n, bPrimaryFile) ; nb bPrimaryFile only used for #SCS_MSGTYPE_FILE
                EndIf
              Next n
              
            EndIf
            
          EndWith
          
          nSubPtr + 1
          If bPrimaryFile
            checkMaxSub(nSubPtr)
            aSub(nSubPtr) = rSub
            If aSub(nSubPtr)\nSubId = -1
              gnUniqueSubId + 1
              aSub(nSubPtr)\nSubId = gnUniqueSubId
              ; debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nSubId=" + aSub(nSubPtr)\nSubId)
            EndIf
          Else
            ; debugMsg(sProcName, "nSubPtr=" + nSubPtr + ", ArraySize(a2ndSub())=" + ArraySize(a2ndSub()))
            If ArraySize(a2ndSub()) < nSubPtr
              REDIM_ARRAY(a2ndSub, nSubPtr+20, grSubDef, "a2ndSub()")
            EndIf
            a2ndSub(nSubPtr) = rSub
            If a2ndSub(nSubPtr)\nSubId = -1
              gnUniqueSubId + 1
              a2ndSub(nSubPtr)\nSubId = gnUniqueSubId
            EndIf
          EndIf
          
        Case "SUBCUEMARKER" ; SUBCUEMARKER
          rSub\sSubCueMarkerName = gsData
          
        Case "SUBCUEMARKERAUDNO" ; SUBCUEMARKERAUDNO
          rSub\nSubCueMarkerAudNo = Val(gsData)
          
        Case "SUBDESCRIPTION"  ; SUBDESCRIPTION
          rSub\sSubDescr = gsData
          rSub\sValidatedSubDescr = gsData
          
        Case "SUBENABLED"  ; SUBENABLED
          rSub\bSubEnabled = stringToBoolean(gsData)
          
        Case "SUBPLACEHOLDER"  ; SUBPLACEHOLDER
          rSub\bSubPlaceHolder = stringToBoolean(gsData)
          
        Case "SUBSTART"  ; SUBSTART
          rSub\nSubStart = encodeSubStart(gsData)
          
        Case "SUBTYPE"  ; SUBTYPE
          rSub\sSubType = gsData
          macSetSubTypeBooleansForSub(rSub)
          Select UCase(gsData)
            Case "A"  ; A (video/image/capture sub-cue)
              If Len(rSub\sVidAudLogicalDev) = 0
                rSub\sVidAudLogicalDev = sDefVidAudDev
              EndIf
          EndSelect
          
        Case "SYNCLEVELS"  ; SYNCLEVELS
          rAud\bSyncLevels = stringToBoolean(gsData)
          
;}
;{ T          
         Case "TESTDBLEVEL"  ; TESTDBLEVEL
          gsData = readDBLevel(gsData)  ; nb includes call to setDecSepForLocale()
          If ValF(gsData) < ValF(grLevels\sMinDBLevel)
            gsData = grLevels\sMinDBLevel
          EndIf
          rProd\sTestToneDBLevel = gsData
          rProd\fTestToneBVLevel = convertDBStringToBVLevel(gsData)
          debugMsg(sProcName, "rProd\sTestToneDBLevel=" + rProd\sTestToneDBLevel + ", rProd\fTestToneBVLevel=" + formatLevel(rProd\fTestToneBVLevel))
          
        Case "TESTPAN"  ; TESTPAN
          ; 4May2022am 11.9.1
          rProd\fTestTonePan = panStringToSingle(gsData)
          
        Case "TESTTONESOUND"  ; TESTTONESOUND
          ; 3May2022pm 11.9.1
          rProd\nTestSound = encodeTestToneSound(gsData)
          
        Case "TIMEPROFILE"  ; TIMEPROFILE
          rProd\sTimeProfile[nTagIndex] = gsData
          
        Case "TITLE"  ; TITLE
          rProd\sTitle = gsData
          If bPrimaryFile
            If IsGadget(WSP\cvsSplash)
              WSP_setProdTitle(rProd\sTitle)
            EndIf
          Else
            If IsGadget(WIM\txtProdTitle)
              SGT(WIM\txtProdTitle, rProd\sTitle)
            EndIf
          EndIf
          
        Case "TMDESC"
          rProd\sTmDesc = gsData
          
        Case "TRACKS"  ; TRACKS
          rAud\sTracks[nTagIndex] = gsData
          
;}
;{ V          
         Case "VERSION"  ; VERSION  ; FileVersion
          grCFH\sFileVersion = gsData
          For n = 1 To 4
            grCFH\sVersionParts[n-1] = StringField(gsData, n, ".")
          Next n
          grCFH\nFileVersion = (Val(grCFH\sVersionParts[0]) * 10000) + (Val(grCFH\sVersionParts[1]) * 100) + Val(grCFH\sVersionParts[2])
          debugMsg(sProcName, "nFileVersion=" + grCFH\nFileVersion)
          If grCFH\nFileVersion = 90400
            grCFH\nFileVersion = 90405 ; FileVersion was 9.4 only at version 9.4.5
          ElseIf (grCFH\nFileVersion = 90000) And (LCase(GetFilePart(gsCueFile)) <> "demo.scs")
            askForVersion(bPrimaryFile)
          EndIf
          ; added the following 24Oct2015 11.4.1.1 following query from Merek Press about reading SCS 9 cue files. Test using SCS 9 demo failed, so added code to set the audio output device.
          If grCFH\nFileVersion < 110000   ; added
            With rProd\aAudioLogicalDevs(0)
              If \nDevType = grAudioLogicalDevsDef\nDevType And \sLogicalDev = grAudioLogicalDevsDef\sLogicalDev
                debugMsg(sProcName, "setting pre-SCS 11 defaults for rProd\aAudioLogicalDevs(0)")
                \sLogicalDev = "FOH"
                gnNextDevId + 1
                \nDevId = gnNextDevId
                \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
                \nNrOfOutputChans = 2
              EndIf
            EndWith
          EndIf
            
        Case "VIDEOLOGICALAUDIODEV", "QALOGICALDEV"  ; VIDEOLOGICALAUDIODEV, QALOGICALDEV
          rSub\sVidAudLogicalDev = gsData
          
        Case "VIDEOLOGICALDEV"  ; VIDEOLOGICALDEV
          rSub\sVidAudLogicalDev = gsData   ; nb SCS10 aud tag "VIDEOLOGICALDEV" replaced in SCS11 by sub tag "VIDEOLOGICALAUDIODEV" or "QALOGICALDEV"
          
        Case "VIDEOREPEAT", "VIDEOCONTINUOUS"  ; VIDEOREPEAT (SCS11) or VIDEOCONTINUOUS (SCS10)
          rSub\bPLRepeat = stringToBoolean(gsData)
          
        Case "VIDEOSOURCE"  ; VIDEOSOURCE
          rAud\nVideoSource = encodeVideoSource(gsData)
          
        Case "VISUALWARNING"  ; VISUALWARNING
          rProd\nVisualWarningTime = Val(gsData)
          
        Case "VISUALWARNINGFORMAT"  ; VISUALWARNINGFORMAT
          rProd\nVisualWarningFormat = Val(gsData)
          
        Case "VSTCHUNKDATA"
          rAud\rVSTChunk\sChunkData = gsData
          
        Case "VSTCHUNKMAGIC"
          rAud\rVSTChunk\sChunkMagic = gsData
          If sUpAttributeName1 = "BYTESIZE"
            rAud\rVSTChunk\nByteSize = Val(gsTagAttributeValue1)
          EndIf
          debugMsg(sProcName, "rAud\rVSTChunk\sChunkMagic=" + rAud\rVSTChunk\sChunkMagic + ", rAud\rVSTChunk\nByteSize=" + rAud\rVSTChunk\nByteSize)
          
        Case "VSTPLUGIN"
          If sUpAttributeName1 = "NAME"
            rAud\sVSTPluginName = gsTagAttributeValue1
          EndIf
          nVSTParamIndex = -1
          
        Case "VSTPLUGINSAMEASCUE"
          CompilerIf #c_vst_same_as
            rAud\sVSTPluginSameAsCue = gsData
          CompilerEndIf
  
        Case "VSTPLUGINSAMEASSUBNO"
          CompilerIf #c_vst_same_as
            rAud\nVSTPluginSameAsSubNo = Val(gsData)
          CompilerEndIf
  
        Case "VSTPROGRAM"
          rAud\nVSTProgram = Val(gsData)
          
        Case "VSTBYPASS"
          rAud\bVSTBypass = stringToBoolean(gsData)
          
        Case "VSTCOMMENT"
          rAud\sVSTComment = gsData
          
        Case "VSTPARAM"
          nVSTParamIndex + 1
          If nVSTParamIndex > ArraySize(rAud\aVSTParam())
            ReDim rAud\aVSTParam(nVSTParamIndex)
          EndIf
          rAud\nVSTMaxParam = nVSTParamIndex
          rAud\aVSTParam(nVSTParamIndex)\nVSTParamIndex = Val(gsTagAttributeValue1)
          rAud\aVSTParam(nVSTParamIndex)\fVSTParamValue = ValF(gsData)
          
;}
;{ W          
         Case "WARNINGBEFOREEND"  ; WARNINGBEFOREEND
          rCue\bWarningBeforeEnd = stringToBoolean(gsData)
          
        Case "WHENREQD"  ; WHENREQD
          rCue\sWhenReqd = gsData
          
;}
;{ X          
         Case "XPOS"  ; XPOS
          rAud\nXPos = Val(gsData)
          
;}
;{ Y          
         Case "YPOS"  ; YPOS
          rAud\nYPos = Val(gsData)
          
;}
      EndSelect
      
    EndIf
  Wend
  debugMsg(sProcName, "bOK=" + strB(bOK) + ", gbEOF=" + strB(gbEOF) + ", gsLine=" + gsLine + ", gsTag=" + gsTag + ", gsTagAttributeName1=" + gsTagAttributeName1 + ", gsTagAttributeValue1=" + gsTagAttributeValue1 + ", gsChar=" + gsChar)
  
  If bPrimaryFile
    gnLastFileData = nFileDataPtr
    gnLastAud = nAudPtr
    gnLastSub = nSubPtr
    gnLastCue = nCuePtr
    gnCueEnd = gnLastCue + 1
    If ArraySize(aCue()) < gnCueEnd
      REDIM_ARRAY(aCue, gnCueEnd+20, grCueDef, "aCue()")
    EndIf
    aCue(gnCueEnd) = grCueDef
    setCuePtrs(#True)
    If grProd\nMaxVidAudLogicalDev = -1 ; Test added 27Apr2023 11.10.0av to prevent 'default' device being added when there is already at least one video audio device defined
      addVidAudLogicalDevIfReqd(@grProd, sDefVidAudDev)
    EndIf
    If grCFH\nFileVersion < 110000
      convertSCS10SpecialNotes(#True) ; setCuePtrs() must be called before convertSCS10SpecialNotes(#True)
      convertSCS10CtrlSendCues(#True)
      convertSCS10VideoImageCues(#True)
    EndIf
    ED_renumberCueCtrlLogicalDevs(@grProd)
    setDerivedProdFields()
    DMX_setDerivedDMXTextColors(@grProd)
    setMaxAndMinOutputScreen()
    loadCueBrackets(#True)
    setLightingPre118Flag(@grProd)
    setVideoFilePresent() ; Added 30Apr2024 11.10.2ck
    DMX_clearCueStartDMXSave()
    ED_setDevDisplayMaximums(@grProd)
    checkProdArraysAllowForNewEntry(@grProd) ; must be called AFTER calling ED_setDevDisplayMaximums() as checkProdArraysAllowForNewEntry() uses values set by ED_setDevDisplayMaximums()
    debugMsg(sProcName, "calling CSRD_convertPreRemDevX32CtrlSendCuesToRemDev()")
    CSRD_convertPreRemDevX32CtrlSendCuesToRemDev()
    debugMsg(sProcName, "calling debugProd(@grProd)")
    debugProd(@grProd)
    
  Else
    gn2ndLastFileData = nFileDataPtr
    gn2ndLastAud = nAudPtr
    gn2ndLastSub = nSubPtr
    gn2ndLastCue = nCuePtr
    gn2ndCueEnd = gn2ndLastCue + 1
    If ArraySize(a2ndCue()) < gn2ndCueEnd
      REDIM_ARRAY(a2ndCue, gn2ndCueEnd+20, grCueDef, "a2ndCue()")
    EndIf
    a2ndCue(gn2ndCueEnd) = grCueDef
    setCuePtrs2nd(#True)
    If gr2ndProd\nMaxVidAudLogicalDev = -1 ; Test added 27Apr2023 11.10.0av to prevent 'default' device being added when there is already at least one video audio device defined
      addVidAudLogicalDevIfReqd(@gr2ndProd, sDefVidAudDev)
    EndIf
    If grCFH\nFileVersion < 110000
      convertSCS10SpecialNotes(#False) ; setCuePtrs2nd() must be called before convertSCS10SpecialNotes(#False)
      convertSCS10CtrlSendCues(#False)
      convertSCS10VideoImageCues(#False)
    EndIf
    DMX_setDerivedDMXTextColors(@gr2ndProd)
    setLightingPre118Flag(@gr2ndProd) ; added 3Feb2020 11.8.2.2af
    ED_setDevDisplayMaximums(@gr2ndProd)
    checkProdArraysAllowForNewEntry(@gr2ndProd) ; must be called AFTER calling ED_setDevDisplayMaximums() as checkProdArraysAllowForNewEntry() uses values set by ED_setDevDisplayMaximums()
  EndIf
  
  ; Deleted 3Dec2021 11.8.6cq as any sub-cue relative MTC start times have not yet been calculated, and loadArrayCueOrSubForMTC() is called later in loadCueFile()
  ;   If bPrimaryFile
  ;     debugMsg(sProcName, "calling loadArrayCueOrSubForMTC()")
  ;     loadArrayCueOrSubForMTC()
  ;   EndIf
  ; End deleted 3Dec2021 11.8.6cq
  
  If bPrimaryFile
    ; set unique node keys for production editor tree
    gnNodeId + 1
    grProd\nNodeKey = gnNodeId
    
    For i = 1 To gnLastCue
      gnNodeId + 1
      aCue(i)\nNodeKey = gnNodeId
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nNodeKey=" + Str(aCue(i)\nNodeKey))
    Next i
    
    For j = 1 To gnLastSub
      If aSub(j)\bExists
        gnNodeId + 1
        aSub(j)\nNodeKey = gnNodeId
        ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nNodeKey=" + Str(aSub(j)\nNodeKey))
      EndIf
    Next j
    
  Else
    ; set unique node keys for production editor tree
    gnNodeId + 1
    gr2ndProd\nNodeKey = gnNodeId
    
    For i = 1 To gn2ndLastCue
      gnNodeId + 1
      a2ndCue(i)\nNodeKey = gnNodeId
    Next i
    
    For j = 1 To gn2ndLastSub
      If a2ndSub(j)\bExists
        gnNodeId + 1
        a2ndSub(j)\nNodeKey = gnNodeId
      EndIf
    Next j
    
  EndIf

  If bPrimaryFile
    For i = 1 To gnLastCue
      ; debugMsg(sProcName, "calling setInitCueStates(" + getCueLabel(i) + ", -1, #False, " + strB(bPrimaryFile) + ")")
      setInitCueStates(i, -1, #False, bPrimaryFile)
    Next i
    
    If bMIDIFreeFormatFound
      grProd\nMidiFreeConvertedToNrpn = convertMidiFreesToNRPNIfRequired()
    EndIf
    grProd\nMidiCCsConvertedToNRPN = convertMidiCCToNRPNIfRequired()
    If grProd\nMidiCCsConvertedToNRPN > 0
      debugMsg(sProcName, "Some MIDI CC's converted to " + grProd\nMidiCCsConvertedToNRPN + " NRPN commands")
    EndIf
    
  Else    ; secondary file (ie import file)
    For i = 1 To gn2ndLastCue
      With a2ndCue(i)
        j = \nFirstSubIndex
        While j >= 0
          setDerivedSubFields(j, bPrimaryFile)
          If (a2ndSub(j)\bSubTypeF) Or (a2ndSub(j)\bSubTypeP) Or (a2ndSub(j)\bSubTypeA)
            debugMsg(sProcName, "calling generatePlayOrder(" + buildSubLabel2(j) + ", " + strB(bPrimaryFile) + ")")
            generatePlayOrder(j, bPrimaryFile)
          EndIf
          j = a2ndSub(j)\nNextSubIndex
        Wend
      EndWith
    Next i
  EndIf
  
  If bPrimaryFile
    
    debugMsg(sProcName, "gnFileNotFoundCount=" + Str(gnFileNotFoundCount))
    If gnFileNotFoundCount > 0
      If gbInitialising
        gbShowFileLocatorAfterInitialisation = #True
      Else
        ensureSplashNotOnTop()
        WFL_populateFileList(bPrimaryFile)
        setMouseCursorNormal()
        debugMsg(sProcName, "calling WFL_Form_Show(#True)")
        WFL_Form_Show(#True)
      EndIf
    EndIf
    
    grMasterLevel\bUseControllerFaderMasterBVLevel = #False
    If gbMainFormLoaded
      SLD_setLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
    EndIf
    setMasterFader(grProd\fMasterBVLevel)
    debugMsg(sProcName, "calling setAllInputGains()")
    setAllInputGains()
    debugMsg(sProcName, "calling setAllLiveEQ()")
    setAllLiveEQ()
    
    If grLicInfo\bDMXSendAvailable
      If SLD_isSlider(WCN\sldDMXMasterFader)
        SLD_setValue(WCN\sldDMXMasterFader, grProd\nDMXMasterFaderValue)
      EndIf
      grDMXMasterFader\nDMXMasterFaderValue = grProd\nDMXMasterFaderValue
      grDMXMasterFader\nDMXMasterFaderResetValue = grProd\nDMXMasterFaderValue
    EndIf
    
    If gnLastAud > 0
      debugMsg(sProcName, "aAud(" + getAudLabel(gnLastAud) + ")\sFileName=" + aAud(gnLastAud)\sFileName)
      gsAudioFileDialogInitDir = GetPathPart(aAud(gnLastAud)\sFileName)
      debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
    Else
      gsAudioFileDialogInitDir = gsCueFolder
      debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
    EndIf
    
    debugMsg(sProcName, "calling setTimeBasedCues()")
    setTimeBasedCues()
    
    setDelayHideInds()
    
    debugMsg(sProcName, "calling openAndReadXMLDevMapFile(" + strB(bPrimaryFile) + ", #False, " + strB(bCreateFromTemplate) + ", " + strB(bTemplate) + ")")
    nValidDevMapPtr = openAndReadXMLDevMapFile(bPrimaryFile, #False, bCreateFromTemplate, bTemplate)
    debugMsg(sProcName, "nValidDevMapPtr=" + nValidDevMapPtr + ", grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr + ", grProd\sSelectedDevMapName=" + grProd\sSelectedDevMapName)
    
    debugMsg(sProcName, "calling propagateFileInfo()")
    propagateFileInfo()
    
    debugMsg(sProcName, "calling DMX_populateAllFixtureDMXStartChannelsArrays()")
    DMX_populateAllFixtureDMXStartChannelsArrays()
    
    Select nValidDevMapPtr
      Case -1
        If bPrimaryFile
          debugMsg(sProcName, "calling createInitialDevMapForProd()")
          nValidDevMapPtr = createInitialDevMapForProd()
          debugMsg(sProcName, "createInitialDevMapForProd() returned " + nValidDevMapPtr)
        EndIf
        
      Case #SCS_REVIEW_DEVMAP   ; change device map
        gbGoToProdPropDevices = #True
        debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
        ; samAddRequest(#SCS_SAM_CHANGE_DEVMAP)
        gbKillSplashTimerEarly = #True
        gbLoadingCueFile = #False
        debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile))
        ProcedureReturn
        
      Case #SCS_CLOSE_CUE_FILE   ; close cue file
        gbCloseCueFile = #True
        gbKillSplashTimerEarly = #True
        gbLoadingCueFile = #False
        debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile))
        ProcedureReturn
        
    EndSelect
    
    ; need to call setMIDIEnabled() and setRS232Enabled() AFTER setting grProd\nSelectedDevMapPtr
    debugMsg(sProcName, "calling setMIDIEnabled()")
    setMIDIEnabled()
    debugMsg(sProcName, "calling setRS232Enabled()")
    setRS232Enabled()
    
    DMX_setChaseCueCount()  ; counts lighting cues that contain chase
    
    If IsGadget(WSP\cvsSplash)
      If (grMaps\nMaxMapIndex > 0) And (grProd\sSelectedDevMapName)
        WSP_setDevMap(grProd\sSelectedDevMapName)
      EndIf
    EndIf
    
    debugMsg(sProcName, "calling mapAudLogicalDevsToPhysicalDevs(" + decodeDriver(gnCurrAudioDriver) + ")")
    mapAudLogicalDevsToPhysicalDevs(gnCurrAudioDriver)
    
    debugMsg(sProcName, "calling mapVidCapLogicalDevsToPhysicalDevs()")
    mapVidCapLogicalDevsToPhysicalDevs()
    
    debugMsg(sProcName, "calling mapCtrlLogicalDevsToPhysicalDevs()")
    mapCtrlLogicalDevsToPhysicalDevs()
    
    debugMsg(sProcName, "calling mapLiveLogicalDevsToPhysicalDevs()")
    mapLiveLogicalDevsToPhysicalDevs()
    
    debugMsg(sProcName, "calling setDisplayPanFlags()")
    setDisplayPanFlags()
    
    ; originally called propagateFileInfo earlier, but now cannot call it until we have initialised a BASS device,
    ; which is done by the above call to mapAudLogicalDevsToPhysicalDevs
    propagateFileInfo()
    DoEvents()    ; give Windows a chance to check program is 'responding'
    
    If gbRS232Started
      debugMsg(sProcName, "calling checkRS232DevsForCtrlSends()")
      checkRS232DevsForCtrlSends()
    EndIf
    
    If gbNetworkStarted
      debugMsg(sProcName, "calling checkNetworkDevsForCtrlSends")
      checkNetworkDevsForCtrlSends()
    EndIf
    
    debugMsg(sProcName, "calling setCueBassDevsAndMidiPortNos")
    bCuesChanged = setCueBassDevsAndMidiPortNos()
    
    setIgnoreDevInds()
    listIgnoreDevInds()
    
    debugMsg(sProcName, "calling setDevMapPtrs(" + strB(bPrimaryFile) + ")")
    setDevMapPtrs(bPrimaryFile)
    
    setConnectWhenReqdForDevs() ; Added 19Sep2022 11.9.6 (for primary file only)
    
    samAddRequest(#SCS_SAM_OPEN_MIDI_PORTS, #False)
    samAddRequest(#SCS_SAM_OPEN_RS232_PORTS)
    If gbDMXAvailable
      samAddRequest(#SCS_SAM_OPEN_DMX_DEVS)
    EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      samAddRequest(#SCS_SAM_START_NETWORK)
    EndIf
    
    If gbUseBASS
      If gbUseBASSMixer = #False
        If isTempoEtcInUse()
          debugMsg(sProcName, "isTempoEtcInUse() returned #True, so setting gbUseBASSMixer=#True")
          gbUseBASSMixer = #True
          mmSetPlaybackBufLength()
          mmSetUpdatePeriodLength()
        EndIf
      EndIf
    EndIf
    
    setLockMixerStreamInds()
    
    sanityCheck()
    
    If IsWindow(#WED)
      fcEditLabelsFrozen()
    EndIf
    
    ; THR_createOrResumeAThread(#SCS_THREAD_SLIDER_FILE_LOADER)
    
  Else  ; bPrimaryFile = #False
    
    debugMsg(sProcName, "calling openAndReadXMLDevMapFile(" + strB(bPrimaryFile) + ", #False, #False, " + strB(bTemplate) + ")")
    nValidDevMapPtr = openAndReadXMLDevMapFile(bPrimaryFile, #False, #False, bTemplate)
    debugMsg(sProcName, "nValidDevMapPtr=" + nValidDevMapPtr + ", gr2ndProd\nSelectedDevMapPtr=" + gr2ndProd\nSelectedDevMapPtr + ", gr2ndProd\sSelectedDevMapName=" + gr2ndProd\sSelectedDevMapName)
    
    debugMsg(sProcName, "calling setDevMapPtrs(" + strB(bPrimaryFile) + ")")
    setDevMapPtrs(bPrimaryFile)
    
  EndIf
  
  gbLoadingCueFile = #False
  gbCueFileLoaded = #True
  grCFH\bReadingSecondaryCueFile = #False
  debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile) + ", gbCueFileLoaded=" + strB(gbCueFileLoaded) + ", grCFH\bReadingSecondaryCueFile=" + strB(grCFH\bReadingSecondaryCueFile))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure confirmOldFormat(sThisCueFile.s, nSaveAsFormat, sTitle.s)
  PROCNAMEC()
  Protected sMsg.s, nReply
  
  sMsg = LangPars("Requesters", "OldFormat1", GetFilePart(sThisCueFile), decodeSaveAsFormat(nSaveAsFormat))
  sMsg + #CRLF$ + #CRLF$ + LangPars("Requesters", "OldFormat2", decodeSaveAsFormat(nSaveAsFormat))
  ; sMsg + #CRLF$ + lang("Requesters", "OldFormat3")
  ensureSplashNotOnTop()
  nReply = scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
  If nReply = #PB_MessageRequester_Yes
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure writeXMLCueFile(bExport, bCopyFiles, bForceNewProdId=#False, bCollecting=#False, bTemplate=#False)
  PROCNAMEC()
  Protected nCueFile, sBakFile.s, sLine.s, sTmpFile.s
  Protected sThisCueOrTemplateFile.s, sExportTitle.s
  Protected sInitialDir.s
  Protected sThisFolder.s
  Protected nMousePointer
  Protected nAttributes
  Protected nDateTimeNow
  Protected sReqdExt.s, sPattern.s, sFileExt.s, sDefaultFile.s
  Protected nSelectedFilePattern
  Protected nFormatOK = #True
  Protected bCancel, bRenameToBAKFailed, bRenameToSCSFailed
  Protected sTitle.s
  Protected bFileExists
  Protected sHoldDefaultFile.s
  Protected sCopySuffix.s
  Protected nCopyPos
  Protected nCopyCount
  Protected sProdId.s
  Protected bSaveToTemplateFolder
  Protected nCurrentFileModified
  Protected sModifiedCueFileSaveOption.s
  Protected bEMCFSaveAs ; 'EMCF' = externally modified cue file - see SCS Project 2019/02
  Protected sPrompt.s, sButtons.s, bModalDisplayed, nReply
  Protected bMyForceNewProdId
  Protected nLineCount
  
  debugMsg(sProcName, #SCS_START + ", bExport=" + strB(bExport) + ", bCopyFiles=" + strB(bCopyFiles) + ", bCollecting=" + strB(bCollecting) + ", bTemplate=" + strB(bTemplate))
  
  If bCollecting = #False
    debugMsg(sProcName, "calling sanityCheck()")
    If sanityCheck() = #False
      scsMessageRequester(#SCS_TITLE, LangPars("Errors", "FileNotSaved", GetFilePart(gsCueFile)), #MB_ICONEXCLAMATION)
      ProcedureReturn
    EndIf
  EndIf
  
  bMyForceNewProdId = bForceNewProdId
  
  If (bTemplate = #False) And (bCollecting = #False)
    ; debugMsg(sProcName, "grCFH\nMostRecentCueFileDateModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", grCFH\nMostRecentCueFileDateModified))
    ; debugMsg(sProcName, "grCFH\sMostRecentCueFile=" + #DQUOTE$ + grCFH\sMostRecentCueFile + #DQUOTE$)
    If grCFH\nMostRecentCueFileDateModified <> 0 And grCFH\sMostRecentCueFile = gsCueFile ; Changed 5Jul2022 11.9.3.1ab
      ;Debug(sProcName + " - running file modification check")
      nCurrentFileModified = GetFileDate(gsCueFile, #PB_Date_Modified)
      ;Debug "Closing File Modified Date/Time is: "+FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nCurrentFileModified)
      If nCurrentFileModified <> grCFH\nMostRecentCueFileDateModified ; Changed 5Jul2022 11.9.3.1ab
        debugMsg(sProcName, "nCurrentFileModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nCurrentFileModified) + ", grCFH\nMostRecentCueFileDateModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", grCFH\nMostRecentCueFileDateModified))
        nMousePointer = GetMouseCursor()
        SetMouseCursorNormal()
        bModalDisplayed = gbModalDisplayed
        gbModalDisplayed = #True
        sPrompt = Lang("CFH", "EMCF") + #CRLF$ + #CRLF$
        sTitle = GetFilePart(gsCueFile)
        sButtons = Lang("Btns", "Overwrite") + "|" + LangEllipsis("Btns", "SaveAs") + "|" + Lang("Btns", "Cancel")
        debugMsg(sProcName, "sPrompt=" + #DQUOTE$ + Trim(ReplaceString(sPrompt, #CRLF$, " ")) + #DQUOTE$ + ", gsCueFile=" + gsCueFile) ; Added 5Jul2022 11.9.3.1ab
        ensureSplashNotOnTop()
        nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 200, #IDI_EXCLAMATION)
        gbModalDisplayed = bModalDisplayed
        SetMouseCursor(nMousePointer)
        Select nReply
          Case 1
            debugMsg(sProcName, "nReply='Overwrite'")
          Case 2
            debugMsg(sProcName, "nReply='Save As...'")
            bEMCFSaveAs = #True
            bMyForceNewProdId = #True
          Case 3, 0 ; 3 = cancel, 0 = user pressed ESC
            debugMsg(sProcName, "nReply='Cancel'")
            bCancel = #True
        EndSelect
      EndIf
    EndIf
  EndIf
  
  gbInWriteXMLCueFile = #True
  nMousePointer = GetMouseCursor()
  
  If bTemplate
    sThisCueOrTemplateFile = gsTemplateFile
    bSaveToTemplateFolder = #True
  ElseIf bCollecting
    sThisCueOrTemplateFile = grWPF\sCueFile
    gs2ndCueFile = sThisCueOrTemplateFile
    gs2ndCueFolder = GetPathPart(gs2ndCueFile)
  Else
    sThisCueOrTemplateFile = gsCueFile
  EndIf
  debugMsg(sProcName, "sThisCueOrTemplateFile=" + sThisCueOrTemplateFile)
  
  sPattern = Lang("Requesters", "SCS11CueFile") + " (*.scs11)|*.scs11"
  
  While #True ; loop just to allow use of Break instead of GoTo's, for error conditions
    
    If bCancel
      debugMsg(sProcName, "writeXMLCueFile_Cancelled: returning #False")
      ProcedureReturn #False
    EndIf
    
    If bCollecting = #False
      If (Len(sThisCueOrTemplateFile) = 0) Or (gbSaveAs) Or (gbXMLFormat = #False) Or (bExport) Or (bEMCFSaveAs)
        ; gbSaveAs = #False   ; defer setting gbSaveAs = #False until after unloadProd, or a new ProdId will not be created when using 'Save As'
        If bExport = #False
          sTitle = Lang("Requesters", "SaveCueFile")
          debugMsg(sProcName, "gsCueFolder=" + gsCueFolder + ", grGeneralOptions\sInitDir=" + grGeneralOptions\sInitDir)
          If Trim(gsCueFolder)
            sInitialDir = Trim(gsCueFolder)
          ElseIf Trim(grGeneralOptions\sInitDir)
            sInitialDir = Trim(grGeneralOptions\sInitDir)
          EndIf
          
          debugMsg(sProcName, "sThisCueOrTemplateFile=" + sThisCueOrTemplateFile + ", sInitialDir=" + sInitialDir)
          If Len(sThisCueOrTemplateFile) = 0
            sThisCueOrTemplateFile = suggestFileNameFromTitle(grProd\sTitle)
          EndIf
          
          sDefaultFile = sInitialDir + "\" + GetFilePart(ignoreExtension(sThisCueOrTemplateFile)) ; Changed 26Jan2024 11.10.2 (inserted \ between directory and filename)
          debugMsg(sProcName, "sDefaultFile=" + sDefaultFile)
          bFileExists = FileExists(sDefaultFile + ".scs11")
          If bFileExists
            sHoldDefaultFile = sDefaultFile
            ; Added 7Mar2022 11.9.1ah (production title may have been changed for the 'save as', so try a filename based on this possibly hcnaged title)
            sDefaultFile = sInitialDir + "\" + suggestFileNameFromTitle(grProd\sTitle) ; Changed 26Jan2024 11.10.2 (inserted \ between directory and filename)
            debugMsg(sProcName, "sDefaultFile=" + sDefaultFile)
            bFileExists = FileExists(sDefaultFile + ".scs11")
            ; End added 7Mar2022 11.9.1ah (end, apart from some related code below)
            If bFileExists
              sDefaultFile = sHoldDefaultFile
              sCopySuffix = " - " + Lang("Requesters", "Copy")
              If Len(sDefaultFile) > Len(sCopySuffix)
                If Right(sDefaultFile, Len(sCopySuffix)) = sCopySuffix
                  sHoldDefaultFile = Left(sDefaultFile, (Len(sDefaultFile) - Len(sCopySuffix)))
                ElseIf Right(sDefaultFile, 1) = ")"
                  nCopyPos = FindString(sDefaultFile, sCopySuffix + "(")
                  If nCopyPos > 1
                    sHoldDefaultFile = Left(sDefaultFile, nCopyPos-1)
                  EndIf
                EndIf
              EndIf
              nCopyCount = 0
              While bFileExists
                nCopyCount + 1
                sDefaultFile = sHoldDefaultFile + " - " + Lang("Requesters", "Copy")
                If nCopyCount > 1
                  sDefaultFile + "(" + nCopyCount + ")"
                EndIf
                bFileExists = FileExists(sDefaultFile + ".scs11")
              Wend
            EndIf
          EndIf
          debugMsg(sProcName, "sDefaultFile=" + sDefaultFile)
          sThisCueOrTemplateFile = SaveFileRequester(sTitle, sDefaultFile, sPattern, 0)
          
          debugMsg(sProcName, "sThisCueOrTemplateFile=" + sThisCueOrTemplateFile)
          nSelectedFilePattern = SelectedFilePattern()
          debugMsg(sProcName, "nSelectedFilePattern=" + nSelectedFilePattern)
          If nSelectedFilePattern < 0
            bCancel = #True
            Break
          EndIf
          Select nSelectedFilePattern
            Case 0
              sThisCueOrTemplateFile = ignoreExtension(sThisCueOrTemplateFile) + ".scs11"
              gnSaveAsFormat = #SCS_SAVEAS_SCS11
          EndSelect
          gsCueFile = sThisCueOrTemplateFile
          gsCueFolder = GetPathPart(gsCueFile)
          updateRFL(sThisCueOrTemplateFile)
          WMN_setWindowTitle()
          
        Else ; bExport
          sTitle = Lang("Requesters", "ExportCues")
          sExportTitle = GetGadgetText(WEX\txtProdTitle)
          sThisCueOrTemplateFile = suggestFileNameFromTitle(sExportTitle)
          
          If Trim(gsCueFolder)
            sInitialDir = Trim(gsCueFolder)
          ElseIf Trim(grGeneralOptions\sInitDir)
            sInitialDir = Trim(grGeneralOptions\sInitDir)
          EndIf
          
          sDefaultFile = sInitialDir + "\" + ignoreExtension(sThisCueOrTemplateFile) ; Changed 26Jan2024 11.10.2 (inserted \ between directory and filename)
          
          sThisCueOrTemplateFile = SaveFileRequester(sTitle, sDefaultFile, sPattern, 0)
          nSelectedFilePattern = SelectedFilePattern()
          If nSelectedFilePattern < 0
            bCancel = #True
            Break
          EndIf
          Select nSelectedFilePattern
            Case 0
              sThisCueOrTemplateFile = ignoreExtension(sThisCueOrTemplateFile) + ".scs11"
              gnSaveAsFormat = #SCS_SAVEAS_SCS11
          EndSelect
          gs2ndCueFile = sThisCueOrTemplateFile
          gs2ndCueFolder = GetPathPart(gs2ndCueFile)
          updateRFL(sThisCueOrTemplateFile)
          
        EndIf
        
      ElseIf bTemplate
        gnSaveAsFormat = #SCS_SAVEAS_SCS11
        
      Else
        ; make sure file to be saved has .scs11 as the extension
        gnSaveAsFormat = #SCS_SAVEAS_SCS11
        If LCase(GetExtensionPart(sThisCueOrTemplateFile)) <> "scs11"
          sThisCueOrTemplateFile = ignoreExtension(sThisCueOrTemplateFile) + ".scs11"
          gsCueFile = sThisCueOrTemplateFile
          gsCueFolder = GetPathPart(gsCueFile)
          updateRFL(sThisCueOrTemplateFile)
          WMN_setWindowTitle()
        EndIf
        
      EndIf
      
    EndIf ; EndIf bCollecting = #False
    
    ; check attributes
    If FileExists(sThisCueOrTemplateFile)
      nAttributes = GetFileAttributes(sThisCueOrTemplateFile)
      debugMsg(sProcName, "nAttributes=" + Str(nAttributes))
      If nAttributes & #PB_FileSystem_ReadOnly
        debugMsg(sProcName, "File is Read-Only: " + Chr(34) + sThisCueOrTemplateFile + Chr(34))
        ensureSplashNotOnTop()
        scsMessageRequester(sTitle,"File "+Chr(34)+sThisCueOrTemplateFile+Chr(34)+" is Read-Only, so cannot be updated. " + "Please use " + Chr(34) + "Save As..." + Chr(34) + " to save your cue file.", #PB_MessageRequester_Ok)
        bCancel = #True
        Break
      EndIf
    EndIf
  
    ; save to tmp file --------------------------------------------------
    sTmpFile = ignoreExtension(sThisCueOrTemplateFile) + ".$$$"
    nCueFile = CreateFile(#PB_Any, sTmpFile)
    debugMsg(sProcName, "CreateFile(#PB_Any, " + #DQUOTE$ + sTmpFile + #DQUOTE$ + ") returned nCueFile=" + nCueFile)
    If nCueFile = 0
      debugMsg(sProcName, "File " + Chr(34) + sTmpFile + Chr(34) + " not created")
      ensureSplashNotOnTop()
      scsMessageRequester(sTitle, "Cannot create a file in folder " + Chr(34) + GetPathPart(sTmpFile) + Chr(34) + ". Try saving your cue file elsewhere.", #PB_MessageRequester_Ok)
      bCancel = #True
      Break
    EndIf
    
    setMouseCursorBusy()
    
    CompilerIf #PB_Compiler_Unicode
      If gnSaveAsFormat = #SCS_SAVEAS_SCS11
        debugMsg(sProcName, "calling WriteStringFormat(" + nCueFile + ", #PB_UTF8)")
        WriteStringFormat(nCueFile, #PB_UTF8)
      EndIf
    CompilerEndIf
    
    writeXMLHeader(nCueFile)
    writeTag(nCueFile, "Production")
    
    ; write the production properties
    sProdId = unloadProd(nCueFile, #False, bExport, sExportTitle, bMyForceNewProdId, bCollecting, bTemplate)
    If (bMyForceNewProdId) And (sProdId)
      grProd\sProdId = sProdId
    EndIf
    
    ; write the control setup properties (for a control surface, such as a Behringer BCR2000)
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      unloadCtrlSetup(nCueFile)
    EndIf
    
    ; write the cues
    ; debugMsg(sProcName, "calling unloadGrid(" + nCueFile + ", #False, " + strB(bExport) + ", " + Str(bCopyFiles) + ", " + strB(bCollecting) + ", " + strB(bTemplate) + ")")
    unloadGrid(nCueFile, #False, bExport, bCopyFiles, bCollecting, bTemplate)
    
    ; write file save info
    nDateTimeNow = Date()
    writeTag(nCueFile, "FileSaveInfo")
    writeTagWithContent(nCueFile, "_CueFile_", sThisCueOrTemplateFile)
    writeTagWithContent(nCueFile, "_Saved_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nDateTimeNow))
    writeTagWithContent(nCueFile, "_SCS_Version_", #SCS_VERSION)
    writeTagWithContent(nCueFile, "_SCS_Build_", grProgVersion\sBuildDateTime)
    writeUnTag(nCueFile, "FileSaveInfo")
    
    writeUnTag(nCueFile, "Production")
    
    ; debugMsg(sProcName, "calling CloseFile(" + nCueFile + ")")
    CloseFile(nCueFile)
    
    nLineCount = lineCount(sTmpFile)
    ; debugMsg(sProcName, "nLineCount=" + nLineCount)
    If nLineCount >= 3
      ; at least three lines in tmp file - assume file written OK
      If FileExists(sThisCueOrTemplateFile)
        sBakFile = ignoreExtension(sThisCueOrTemplateFile) + ".bak"
        If lineCount(sThisCueOrTemplateFile) >= 3
          If FileExists(sBakFile)
            ; debugMsg(sProcName, "Removing " + sBakFile)
            DeleteFile(sBakFile)
          EndIf
          ; debugMsg(sProcName, "Renaming " + sThisCueOrTemplateFile + " to " + sBakFile)
          If RenameFile(sThisCueOrTemplateFile, sBakFile) = #False
            bRenameToBAKFailed = #True
            Break
          EndIf
        EndIf
      EndIf
      ; debugMsg(sProcName, "Renaming " + sTmpFile + " to " + sThisCueOrTemplateFile)
      If RenameFile(sTmpFile, sThisCueOrTemplateFile) = #False
        bRenameToSCSFailed = #True
        Break
      EndIf
      grCFH\sMostRecentCueFile = gsCueFile
      grCFH\nMostRecentCueFileDateModified = GetFileDate(grCFH\sMostRecentCueFile, #PB_Date_Modified)
      ; debugMsg(sProcName, "grCFH\nMostRecentCueFileDateModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", grCFH\nMostRecentCueFileDateModified))
      ; debugMsg(sProcName, "grCFH\sMostRecentCueFile=" + #DQUOTE$ + grCFH\sMostRecentCueFile + #DQUOTE$)
    EndIf
    
    If bExport = #False
      gbCueFileOpen = #False
      gbDataChanged = #False
      gbXMLFormat = #True
      gbAudioFileOrPathChanged = #False
      gbUnsavedRecovery = #False
      gbNewDevMapFileCreated = #False
      gnUnsavedEditorGraphs = 0
      gsUnsavedEditorGraphs = ""
      gnUnsavedSliderGraphs = 0
      gbUnsavedVideoImageData = #False
      grCtrlSetup\bDataChanged = #False ; Added 27Jun2022 11.9.4 (checked by checkSaveToBeEnabled())
      WCN\bEQChanged = #False ; Added 27Jun2022 11.9.4 (checked by checkSaveToBeEnabled())
      
      ; The following two lines moved to savePlaylistOrdersToProdDatabase() 4Jul2023 11.10.0bn
      ; gbUnsavedPlaylistOrderInfo = #False
      ; debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
      
      gbImportedCues = #False
      gbNewCueFile = #False
      ; when writing the device map file, use the sProdId returned by unloadProd,
      ; which will have been recalculated if the user is exporting or 'saving as...'
      debugMsg(sProcName, "calling writeXMLDevMapFile(" + grProd\sSelectedDevMapName + ", " + sProdId + ", #False, #False, " + strB(bSaveToTemplateFolder) + ")")
      grProd\sDevMapFile = writeXMLDevMapFile(grProd\sSelectedDevMapName, sProdId, #False, #False, bSaveToTemplateFolder)
      debugMsg(sProcName, "grProd\sDevMapFile=" + #DQUOTE$ + grProd\sDevMapFile + #DQUOTE$)
      setLatestUndoGroupIdAtSave()
      setUnsavedChanges(#False)
      setFileSave()
    EndIf
    
    If bTemplate = #False
      killRecoveryFile()
    EndIf
    
    Break
  Wend

  setMouseCursor(nMousePointer)
  
  If bTemplate = #False
    gbSaveAs = #False
    bEMCFSaveAs = #False
  EndIf
  gbInWriteXMLCueFile = #False
  
  If bCancel
    debugMsg(sProcName, "writeXMLCueFile_Cancelled: returning #False")
    ProcedureReturn #False
  EndIf
  
  If bRenameToBAKFailed
    ensureSplashNotOnTop()
    scsMessageRequester(sTitle,"Trying to rename " + GetFilePart(sThisCueOrTemplateFile) + " to " + GetFilePart(sBakFile) + " has failed." + #CRLF$ + #CRLF$ + "This may be due to a permissions failure in updating files in " + GetPathPart(sBakFile) + "." + #CRLF$ + #CRLF$ + "Please use the menu item 'File / Save As...' to save your file to another folder, such as " + Chr(34) + gsMyDocsLeafName + Chr(34) + ".", #PB_MessageRequester_Ok)
    debugMsg(sProcName, "rename_to_bak_failed: returning #False")
    ProcedureReturn #False
  EndIf

  If bRenameToSCSFailed
    ensureSplashNotOnTop()
    scsMessageRequester(sTitle,"Trying to rename " + GetFilePart(sTmpFile) + " to " + GetFilePart(sThisCueOrTemplateFile) + " has failed." +
                               #CRLF$ + #CRLF$ + "This may be due to a permissions failure in updating files in " + GetPathPart(sThisCueOrTemplateFile) + "." +
                               #CRLF$ + #CRLF$ + "Please use the menu item 'File / Save As...' to save your file to another folder, such as " +
                               Chr(34) + gsMyDocsLeafName + Chr(34) + ".", #PB_MessageRequester_Ok)
    debugMsg(sProcName, "rename_to_scs_failed: returning #False")
    ProcedureReturn #False
  EndIf
  
  grWVP\bReadyToSaveToCueFile = #False
  
  logKeyEvent("Cue File Saved: " + #DQUOTE$ + sThisCueOrTemplateFile + #DQUOTE$)
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True

EndProcedure

Procedure writeXMLRecoveryFile()
  PROCNAMEC()
  Protected nRecoveryFile, sTmpFile.s
  Protected sExportTitle.s   ; not used, but required by call to unloadProd
  Protected nDateNow
  Protected sProdId.s

  If gbInWriteXMLCueFile
    ProcedureReturn      ; bail out if writeXMLCueFile has started
  EndIf

  If (gqLastChangeTime - gqLastRecoveryTime) <= 0
    ProcedureReturn   ; no changes since recovery file last written, or no changes at all
  EndIf

  ; exit if less than 1.5 seconds since the last change, as this may imply the user is dragging a level slider or similar
  If (gqTimeNow - gqLastChangeTime) < 1500
    ProcedureReturn
  EndIf

  gqLastRecoveryTime = ElapsedMilliseconds()
  nDateNow = Date()

  ; save to tmp file --------------------------------------------------
  sTmpFile = ignoreExtension(gsRecoveryFile) + ".$$$"

  If gbInWriteXMLCueFile
    ProcedureReturn                  ; bail out if writeXMLCueFile has started
  EndIf
  
  nRecoveryFile = CreateFile(#PB_Any, sTmpFile)
  
  If nRecoveryFile
    
    While #True  ; loop just to allow use of Break instead of GoTo's
      
      If gbInWriteXMLCueFile
        Break   ; bail out if writeXMLCueFile has started
      EndIf
      
      CompilerIf #PB_Compiler_Unicode
        ; debugMsg(sProcName, "calling WriteStringFormat(" + Str(nRecoveryFile) + ", #PB_UTF8)")
        WriteStringFormat(nRecoveryFile, #PB_UTF8)
      CompilerEndIf
      
      writeXMLHeader(nRecoveryFile)
      ;Call debugMsg(sProcName, "Header written")
      If gbInWriteXMLCueFile
        Break   ; bail out if writeXMLCueFile has started
      EndIf
      
      writeTag(nRecoveryFile, "Recovery") ; 'root' tag - only one root tag permitted in an XML file
      
      writeTag(nRecoveryFile, "RecoveryInfo")
      If grProd\bTemplate
        writeTagWithContent(nRecoveryFile, "_TemplateFile_", gsTemplateFile)
      Else
        writeTagWithContent(nRecoveryFile, "_CueFile_", gsCueFile)
      EndIf
      writeTagWithContent(nRecoveryFile, "_Saved_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nDateNow))
      writeTagWithContent(nRecoveryFile, "_TimeStamp_", Str(gqLastRecoveryTime))
      writeTagWithContent(nRecoveryFile, "_SCS_Version_", #SCS_VERSION)
      writeTagWithContent(nRecoveryFile, "_SCS_Build_", grProgVersion\sBuildDateTime)
      writeTagWithContent(nRecoveryFile, "_QP_", Str(nEditCuePtr))
      writeUnTag(nRecoveryFile, "RecoveryInfo")
      
      writeTag(nRecoveryFile, "Production")
      ; write the production properties
      sProdId = unloadProd(nRecoveryFile, #True, #False, sExportTitle, #False, #False, grProd\bTemplate)
      ; write the cues
      unloadGrid(nRecoveryFile, #True, #False, #False, #False, grProd\bTemplate)
      writeUnTag(nRecoveryFile, "Production")
      
      writeUnTag(nRecoveryFile, "Recovery") ; cloase the root tage
      
      Break
    Wend
    
    CloseFile(nRecoveryFile)
    
    If gbInWriteXMLCueFile
      ProcedureReturn
    EndIf
    If FileExists(gsRecoveryFile, #False)
      DeleteFile(gsRecoveryFile)
    EndIf
    RenameFile(sTmpFile, gsRecoveryFile)
    
  EndIf

EndProcedure

Procedure setCueDetailsInMain()
  PROCNAMEC()
  Protected nCuePtr, bTryPrevious

  debugMsg(sProcName, #SCS_START + ", gnCueToGo=" + getCueLabel(gnCueToGo) + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue))
  
  debugMsg(sProcName, "calling WMN_setWindowTitle")
  WMN_setWindowTitle()
  
  If SLD_getBaseLevel(WMN\sldMasterFader) <> grProd\fMasterBVLevel
    SLD_setBaseLevel(WMN\sldMasterFader, grProd\fMasterBVLevel, 1)
  EndIf
  
  gbForceGridReposition = #True
  gnCueToGoOverride = -1
  
  debugMsg(sProcName, "calling setGoButton()")
  setGoButton()
  
  debugMsg(sProcName, "calling loadHotkeyPanel()")
  WMN_loadHotkeyPanel()

  debugMsg(sProcName, "calling populateGrid()")
  populateGrid()
  debugMsg(sProcName, "gnLastCue=" + getCueLabel(gnLastCue) + ", gnRowEnd=" + gnRowEnd)

  WMN_updateToolBar()
  WMN_buildPopupMenu_SaveSettings()
  
  ; modified 8Nov2019 11.8.2bt following bug reported by Andrew Charnley which turned out to be related to editApplyChanges() calling setCueDetailsInMain() for Time-Based Cues
  ; previous code was: highlightLine(getFirstEnabledCue())
  ; new code:
  nCuePtr = getFirstEnabledCue()
  If (gnHighlightedCue > 0) And (gnHighlightedCue < gnCueEnd)
    With aCue(gnHighlightedCue)
      If gnHighlightedRow = \nGrdCuesRowNo
        If (\bCueEnabled ) And (\nHideCueOpt <> #SCS_HIDE_ENTIRE_CUE)
          nCuePtr = gnHighlightedCue
        EndIf
      EndIf
    EndWith
  EndIf
  highlightLine(nCuePtr)
  ; end modified 8Nov2019 11.8.2rc1
  
  debugMsg(sProcName, "gnCueEnd=" + gnCueEnd)
  If gnCueEnd > 1
    ; make sure 'End' cue is not colored as 'next manual cue'
    colorLine(gnCueEnd)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", gnCueToGo=" + getCueLabel(gnCueToGo) + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue))
  
EndProcedure

Procedure.s readDBLevel(sDBLevel.s)
  PROCNAMEC()
  Protected dDBLevel.d, sReturnString.s
  
  ; debugMsg(sProcName, #SCS_START + ", sDBLevel=" + sDBLevel)
  
  sReturnString = Trim(setDecSepForLocale(sDBLevel))
  If sReturnString
    If sReturnString <> #SCS_INF_DBLEVEL
      dDBLevel = ValD(sReturnString)
      If dDBLevel < ValD(grLevels\sMinDBLevel)
        sReturnString = #SCS_INF_DBLEVEL
      Else
        sReturnString = StrD(dDBLevel, 1)
      EndIf
    EndIf
  EndIf
  ProcedureReturn sReturnString
EndProcedure

Procedure.s unloadDBLevel(sDBLevel.s)
  PROCNAMEC()
  Protected sReturnString.s
  
  sReturnString = Trim(sDBLevel)
  If sReturnString
    If sReturnString <> #SCS_INF_DBLEVEL
      sReturnString = StrD(ValD(sDBLevel), 1)
    EndIf
  EndIf
  ProcedureReturn sReturnString
EndProcedure

Procedure writeSubHeader(nFileNo, pSubPtr)
  PROCNAMEC()

  With aSub(pSubPtr)
    writeTag(nFileNo, "Sub")
    writeTagWithContent(nFileNo, "SubType", \sSubType)
    
    writeTagIfReqd(nFileNo, "SubStart", decodeSubStart(\nSubStart), decodeSubStart(grSubDef\nSubStart))
    Select \nSubStart
      Case #SCS_SUBSTART_REL_TIME
        If (\nRelStartTime > 0) Or (\nRelStartMode = #SCS_RELSTART_AS_PREV_SUB) Or (\nRelStartMode = #SCS_RELSTART_AE_PREV_SUB) Or (\nRelStartMode = #SCS_RELSTART_BE_PREV_SUB)
          writeTagIfReqd(nFileNo, "RelStartMode", decodeRelStartMode(\nRelStartMode), decodeRelStartMode(grSubDef\nRelStartMode))
          Select \nRelStartMode
            Case #SCS_RELSTART_DEFAULT, #SCS_RELSTART_AS_CUE, #SCS_RELSTART_AS_PREV_SUB, #SCS_RELSTART_AE_PREV_SUB, #SCS_RELSTART_BE_PREV_SUB
              writeTagIfReqd(nFileNo, "RelStartTime", Str(\nRelStartTime), Str(grSubDef\nRelStartTime))
          EndSelect
        EndIf
      Case #SCS_SUBSTART_REL_MTC
        writeTagIfReqd(nFileNo, "RelMTCStartTimeForSub", decodeMTCTime(\nRelMTCStartTimeForSub), decodeMTCTime(grSubDef\nRelMTCStartTimeForSub))
      Case #SCS_SUBSTART_OCM
        writeTagIfReqd(nFileNo, "SubCueMarker", \sSubCueMarkerName, grSubDef\sSubCueMarkerName)
        writeTagIfReqd(nFileNo, "SubCueMarkerAudNo", Str(\nSubCueMarkerAudNo), Str(grSubDef\nSubCueMarkerAudNo))
    EndSelect
    
    writeTagIfReqd(nFileNo, "SubEnabled", booleanToString(\bSubEnabled), booleanToString(grSubDef\bSubEnabled))
    
    If \bSubTypeN = #False
      writeTagIfReqd(nFileNo, "SubDescription", \sSubDescr, grSubDef\sSubDescr)
      writeTagIfReqd(nFileNo, "DefSubDes", booleanToString(\bDefaultSubDescrMayBeSet), booleanToString(grSubDef\bDefaultSubDescrMayBeSet))
    EndIf
    
  EndWith
  
EndProcedure

Procedure writeCueMarkersForAud(nFileNo, nAudPtr)
  ; write cue marker info for types A and F
  PROCNAMEC()
  Protected nMarkerCount
  
  For nMarkerCount = 0 To aAud(nAudPtr)\nMaxCueMarker
    If aAud(nAudPtr)\aCueMarker(nMarkerCount)\nCueMarkerType = #SCS_CMT_CM
      writeTagWithAttribute(nFileNo, "CueMarker", "MarkerName", aAud(nAudPtr)\aCueMarker(nMarkerCount)\sCueMarkerName)
      writeTagWithContent(nFileNo, "MarkerPos", Str(aAud(nAudPtr)\aCueMarker(nMarkerCount)\nCueMarkerPosition))
      writeUnTag(nFileNo, "CueMarker")
    EndIf
  Next nMarkerCount
EndProcedure

Procedure unloadGrid(nFileNo, bRecovery, bExport, bCopyFiles, bCollecting=#False, bTemplate=#False)
  PROCNAMEC()
  Protected h, i, j, k, d, f, n, m, p, v, n2
  Protected nTagIndex
  Protected s2ndStoredFileName.s, s2ndFileName.s
  Protected sTmp1.s, sTmp2.s
  Protected sMyFileModified.s, qMyFileSize.q
  Protected sMyStoredFileName.s
  ; Protected bSaveThisFile
  Protected bWantThis, bWantThisLevelPoint
  Protected bSavePointTime
  Protected nCtrlSendIndex
  Protected nEnableDisableNo
  Protected bSwitchProdFolder = #True
  Protected nTotalChans, bSaveFixtureChanInfo, bFixtureItemTagWritten
  Protected sSelectedVSTPluginName.s, sPluginName.s
  Protected nVSTParamPtr, nSSItemCount
  Protected sThisFileName.s, f2 ; Added 10Nov2022 11.9.7ad
  
  If bTemplate
    debugMsg(sProcName, #SCS_START + ", gsTemplatesFolder=" + gsTemplatesFolder + ", gsTemplateFile=" + gsTemplateFile + ", bTemplate=" + strB(bTemplate))
  ElseIf bExport Or bCollecting
    debugMsg(sProcName, #SCS_START + ", gs2ndCueFolder=" + gs2ndCueFolder + ", gs2ndCueFile=" + gs2ndCueFile + ", bExport=" + strB(bExport) + ", bCopyFiles=" + strB(bCopyFiles))
  Else
    debugMsg(sProcName, #SCS_START + ", gsCueFolder=" + gsCueFolder + ", gsCueFile=" + gsCueFile + ", bExport=" + strB(bExport) + ", bCopyFiles=" + strB(bCopyFiles) + ", bCollecting=" + strB(bCollecting) +
                        ", bTemplate=" + strB(bTemplate))
  EndIf
  
  For i = 1 To gnLastCue
    If bExport
      If WEX_exportThisCue(i) = #False
        Continue
      EndIf
    EndIf
    
    With aCue(i)
      ;{
      writeTag(nFileNo, "Cue")
      
      writeTagWithContent(nFileNo, "CueId", \sCue)
      writeTagIfReqd(nFileNo, "MIDICue", \sMidiCue, grCueDef\sMidiCue)
      writeTagIfReqd(nFileNo, "Description", \sCueDescr, grCueDef\sCueDescr)
      writeTagIfReqd(nFileNo, "DefDes", booleanToString(\bDefaultCueDescrMayBeSet), booleanToString(grCueDef\bDefaultCueDescrMayBeSet))
      writeTagIfReqd(nFileNo, "PageNo", \sPageNo, grCueDef\sPageNo)
      writeTagIfReqd(nFileNo, "WhenReqd", \sWhenReqd, grCueDef\sWhenReqd)
      writeTagIfReqd(nFileNo, "HotkeyBank", Str(\nHotkeyBank), Str(grCueDef\nHotkeyBank))
      writeTagIfReqd(nFileNo, "Hotkey", \sHotkey, grCueDef\sHotkey)
      writeTagIfReqd(nFileNo, "HotkeyLabel", \sHotkeyLabel, grCueDef\sHotkeyLabel)
      If (bExport) And (\bExportAsManualStart)
        ; exporting as manual start, so ignore the activation fields (see WEX_btnExport_Click() for details of why \bExportAsManualStart may be set)
      Else
        writeTagIfReqd(nFileNo, "ActivationMethod", decodeActivationMethod(\nActivationMethod), decodeActivationMethod(grCueDef\nActivationMethod))
        Select \nActivationMethod
          Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF ; this test added 24Sep2016 11.5.2.2 following cue file from Dieter that included "AutoActivatePosn" for a hotkey
            writeTagIfReqd(nFileNo, "AutoActivateCueType", decodeAutoActCueSelType(\nAutoActCueSelType), decodeAutoActCueSelType(grCueDef\nAutoActCueSelType))
            If \nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT
              writeTagIfReqd(nFileNo, "AutoActivateCue", \sAutoActCue, grCueDef\sAutoActCue)
            EndIf
            If (\nAutoActCueSelType = #SCS_ACCUESEL_CM)
              writeTagIfReqd(nFileNo, "AutoActivateCue", \sAutoActCue, grCueDef\sAutoActCue)
            EndIf
            writeTagIfReqd(nFileNo, "AutoActivatePosn", decodeAutoActPosn(\nAutoActPosn), decodeAutoActPosn(grCueDef\nAutoActPosn))
            If (\nAutoActPosn = #SCS_ACPOSN_OCM)
              writeTagIfReqd(nFileNo, "AutoActivateSubNo", Str(\nAutoActSubNo), Str(grCueDef\nAutoActSubNo))
              writeTagIfReqd(nFileNo, "AutoActivateAudNo", Str(\nAutoActAudNo), Str(grCueDef\nAutoActAudNo))
              writeTagIfReqd(nFileNo, "AutoActivateMarker", \sAutoActCueMarkerName, grCueDef\sAutoActCueMarkerName)
            Else
              writeTagIfReqd(nFileNo, "AutoActivateTime", Str(\nAutoActTime), Str(grCueDef\nAutoActTime))
            EndIf
          Case #SCS_ACMETH_OCM
            writeTagIfReqd(nFileNo, "AutoActivateCue", \sAutoActCue, grCueDef\sAutoActCue)
            writeTagIfReqd(nFileNo, "AutoActivateSubNo", Str(\nAutoActSubNo), Str(grCueDef\nAutoActSubNo))
            writeTagIfReqd(nFileNo, "AutoActivateAudNo", Str(\nAutoActAudNo), Str(grCueDef\nAutoActAudNo))
            writeTagIfReqd(nFileNo, "AutoActivateMarker", \sAutoActCueMarkerName, grCueDef\sAutoActCueMarkerName)
          Case #SCS_ACMETH_EXT_FADER
            If grLicInfo\bExtFaderCueControlAvailable
              writeTagIfReqd(nFileNo, "ExtFaderCC", Str(\nExtFaderCC), Str(grCueDef\nExtFaderCC))
            EndIf
          Case #SCS_ACMETH_CALL_CUE
            writeTagIfReqd(nFileNo, "CallableCueParams", Trim(\sCallableCueParams), grCueDef\sCallableCueParams)
        EndSelect
      EndIf
      writeTagIfReqd(nFileNo, "Standby", decodeStandby(\nStandby), decodeStandby(grCueDef\nStandby))
      writeTagIfReqd(nFileNo, "Enabled", booleanToString(\bCueEnabled), booleanToString(grCueDef\bCueEnabled))
      writeTagIfReqd(nFileNo, "Exclusive", booleanToString(\bExclusiveCue), booleanToString(grCueDef\bExclusiveCue))
      writeTagIfReqd(nFileNo, "WarningBeforeEnd", booleanToString(\bWarningBeforeEnd), booleanToString(grCueDef\bWarningBeforeEnd))
      ; writeTagIfReqd(nFileNo, "HideCue", booleanToString(\bHideCue), booleanToString(grCueDef\bHideCue)) ; deprecated (replaced in 11.2.5 by HideCueOpt)
      ; writeTagIfReqd(nFileNo, "HideCuePanel", booleanToString(\bHideCuePanel), booleanToString(grCueDef\bHideCuePanel)) ; deprecated (replaced in 11.2.5 by HideCueOpt)
      writeTagIfReqd(nFileNo, "HideCueOpt", decodeHideCueOpt(\nHideCueOpt), decodeHideCueOpt(grCueDef\nHideCueOpt))
      writeTagIfReqd(nFileNo, "CueGapless", booleanToString(\bCueGaplessIfPossible), booleanToString(grCueDef\bCueGaplessIfPossible))
      writeTagIfReqd(nFileNo, "ProdTimerAction", decodeProdTimerAction(\nProdTimerAction), decodeProdTimerAction(grCueDef\nProdTimerAction))
      
      Select \nActivationMethod
        Case #SCS_ACMETH_TIME
          m = 0
          For n = 0 To #SCS_MAX_TIME_PROFILE
            If Len(\sTimeBasedStart[n]) <> 0
              writeTagIfReqd(nFileNo, "ACTimeProfile"+ m, \sTimeProfile[n], grCueDef\sTimeProfile[n])
              writeTagIfReqd(nFileNo, "ACTimeStart"+ m, \sTimeBasedStart[n], grCueDef\sTimeBasedStart[n])
              ; TBC Project Changes
              writeTagIfReqd(nFileNo, "ACTimeLatestStart"+m, \sTimeBasedLatestStart[n], grCueDef\sTimeBasedLatestStart[n])
              m + 1
            EndIf
          Next n
          
        Case #SCS_ACMETH_MTC, #SCS_ACMETH_LTC
          writeTagWithContent(nFileNo, "MTCStartTimeForCue", decodeMTCTime(\nMTCStartTimeForCue))
          
      EndSelect
      ;}
    EndWith
    
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      nCtrlSendIndex = -1
      writeSubHeader(nFileNo, j)
      If aSub(j)\bSubTypeF ; INFO Saving \bSubTypeF
        ;{
        k = aSub(j)\nFirstAudIndex ; nb Audio File Sub-Cues (\bSubTypeF) have only one associated aAud()
        With aAud(k)
          removeNonExistentDevsFromLvlPts(k)
          writeTag(nFileNo, "AudioFile")
          If bRecovery = #False
            \sStoredFileName = encodeFileName(\sFileName, bCollecting, bTemplate)
            ; debugMsg(sProcName, "\sFileName=" + \sFileName)
            ; debugMsg(sProcName, "\sStoredFileName=" + \sStoredFileName)
          EndIf
          If bExport Or bCollecting
            s2ndStoredFileName = \sStoredFileName
            If (bExport) And (bCopyFiles) And (\bAudPlaceHolder = #False)
              If LCase(GetPathPart(\sFileName)) <> LCase(gs2ndCueFolder)
                sTmp1 = \sFileName
                sTmp2 = gs2ndCueFolder + GetFilePart(sTmp1)
                If FileExists(sTmp2, #False) = #False
                  SetGadgetText(WEX\lblExportStatus, "Copying " + GetFilePart(\sFileName) + "...")
                  CopyFile(sTmp1, sTmp2)
                  SetGadgetText(WEX\lblExportStatus, "")
                EndIf
              EndIf
              s2ndStoredFileName = "$(Cue)\" + GetFilePart(\sFileName)
              While FindString(s2ndStoredFileName, "$(Cue)\\")
                s2ndStoredFileName = ReplaceString(s2ndStoredFileName, "$(Cue)\\", "$(Cue)\")
              Wend
            EndIf
            If \bAudPlaceHolder
              writeTagWithContent(nFileNo, "AudPlaceHolder", booleanToString(\bAudPlaceHolder))
            Else
              writeTagWithContent(nFileNo, "FileName", s2ndStoredFileName)
            EndIf
            
          Else
            If \bAudPlaceHolder
              writeTagWithContent(nFileNo, "AudPlaceHolder", booleanToString(\bAudPlaceHolder))
            Else
              writeTagWithContent(nFileNo, "FileName", \sStoredFileName)
            EndIf
            
          EndIf
          
          If \bAudNormSet And \fAudNormIntegrated <> -Infinity()
            writeTagWithContent(nFileNo, "AudNormInfo", StrF(\fAudNormIntegrated,5) + ";" + StrF(\fAudNormPeak,5) + ";" + StrF(\fAudNormTruePeak,5))
          EndIf
          
          If \nCuePosTimeOffset > 0
            writeTagWithContent(nFileNo, "CuePosTimeOffset", Str(\nCuePosTimeOffset))
          EndIf
          
          writeTagIfReqd(nFileNo, "StartAt", Str(\nStartAt), Str(grAudDef\nStartAt))
          If (\sStartAtCPName) And (\qStartAtSamplePos >= 0)
            writeTagWithContent(nFileNo, "StartAtCPName", \sStartAtCPName)
            writeTagWithContent(nFileNo, "StartAtSamplePos", Str(\qStartAtSamplePos))
          EndIf
          writeTagIfReqd(nFileNo, "EndAt", Str(\nEndAt), Str(grAudDef\nEndAt))
          If (\sEndAtCPName) And (\qEndAtSamplePos >= 0)
            writeTagWithContent(nFileNo, "EndAtCPName", \sEndAtCPName)
            writeTagWithContent(nFileNo, "EndAtSamplePos", Str(\qEndAtSamplePos))
          EndIf
          writeTagIfReqd(nFileNo, "FadeInEntryType", decodeFadeEntryType(\nFadeInEntryType), decodeFadeEntryType(grAudDef\nFadeInEntryType))
          If \nFadeInEntryType = #SCS_FADE_ENTRY_POS
            If (\sFadeInCPName) And (\qFadeInSamplePos >= 0)
              writeTagWithContent(nFileNo, "FadeInCPName", \sFadeInCPName)
              writeTagWithContent(nFileNo, "FadeInSamplePos", Str(\qFadeInSamplePos))
            Else
              writeTagIfReqd(nFileNo, "FadeInMSPos", Str(\nFadeInMSPos), Str(grAudDef\nFadeInMSPos))
            EndIf
          Else
            macWriteTagForNumericOrStringParam("FadeInTime", \sFadeInTime, \nFadeInTime, grAudDef\nFadeInTime)
            ; debugMsg0(sProcName, "\sFadeInTime=" + \sFadeInTime + ", \nFadeInTime=" + \nFadeInTime; )
          EndIf
          writeTagIfReqd(nFileNo, "FadeInType", decodeFadeType(\nFadeInType), decodeFadeType(grAudDef\nFadeInType))
          
          writeTagIfReqd(nFileNo, "FadeOutEntryType", decodeFadeEntryType(\nFadeOutEntryType), decodeFadeEntryType(grAudDef\nFadeOutEntryType))
          If \nFadeOutEntryType = #SCS_FADE_ENTRY_POS
            If (\sFadeOutCPName) And (\qFadeOutSamplePos >= 0)
              writeTagWithContent(nFileNo, "FadeOutCPName", \sFadeOutCPName)
              writeTagWithContent(nFileNo, "FadeOutSamplePos", Str(\qFadeOutSamplePos))
            Else
              writeTagIfReqd(nFileNo, "FadeOutMSPos", Str(\nFadeOutMSPos), Str(grAudDef\nFadeOutMSPos))
            EndIf
          Else
            macWriteTagForNumericOrStringParam("FadeOutTime", \sFadeOutTime, \nFadeOutTime, grAudDef\nFadeOutTime)
          EndIf
          writeTagIfReqd(nFileNo, "FadeOutType", decodeFadeType(\nFadeOutType), decodeFadeType(grAudDef\nFadeOutType))
          
          For n = 0 To \nMaxLoopInfo
            writeTag(nFileNo, "LoopInfo")
            writeTagWithContent(nFileNo, "Loop", booleanToString(\aLoopInfo(n)\bContainsLoop))
            writeTagIfReqd(nFileNo, "LoopStart", Str(\aLoopInfo(n)\nLoopStart), Str(grAudDef\aLoopInfo(0)\nLoopStart))
            If (\aLoopInfo(n)\sLoopStartCPName) And (\aLoopInfo(n)\qLoopStartSamplePos >= 0)
              writeTagWithContent(nFileNo, "LoopStartCPName", \aLoopInfo(n)\sLoopStartCPName)
              writeTagWithContent(nFileNo, "LoopStartSamplePos", Str(\aLoopInfo(n)\qLoopStartSamplePos))
            EndIf
            writeTagIfReqd(nFileNo, "LoopEnd", Str(\aLoopInfo(n)\nLoopEnd), Str(grAudDef\aLoopInfo(0)\nLoopEnd))
            If (\aLoopInfo(n)\sLoopEndCPName) And (\aLoopInfo(n)\qLoopEndSamplePos >= 0)
              writeTagWithContent(nFileNo, "LoopEndCPName", \aLoopInfo(n)\sLoopEndCPName)
              writeTagWithContent(nFileNo, "LoopEndSamplePos", Str(\aLoopInfo(n)\qLoopEndSamplePos))
            EndIf
            writeTagIfReqd(nFileNo, "LoopXFadeTime", Str(\aLoopInfo(n)\nLoopXFadeTime), Str(grAudDef\aLoopInfo(0)\nLoopXFadeTime))
            writeTagIfReqd(nFileNo, "NumLoops", Str(\aLoopInfo(n)\nNumLoops), Str(grAudDef\aLoopInfo(0)\nNumLoops))
            writeUnTag(nFileNo, "LoopInfo")
          Next n
          writeTagIfReqd(nFileNo, "LoopLinked", booleanToString(\bLoopLinked), booleanToString(grAudDef\bLoopLinked))  ; added 2Nov2015 11.4.1.2g
          
          CompilerIf #c_include_sync_levels
            writeTagIfReqd(nFileNo, "SyncLevels", booleanToString(\bSyncLevels), booleanToString(grAudDef\bSyncLevels))
          CompilerEndIf
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \sLogicalDev[d]
              writeTagWithContent(nFileNo, "LogicalDev" + d, \sLogicalDev[d])
              If \sTracks[d] <> #SCS_TRACKS_DFLT
                writeTagIfReqd(nFileNo, "Tracks" + d, \sTracks[d], grAudDef\sTracks[d])
              EndIf
              If \fTrimFactor[d] <> grAudDef\fTrimFactor[d]
                writeTagIfReqd(nFileNo, "DBTrim" + d, \sDBTrim[d], grAudDef\sDBTrim[d])
              EndIf
              writeTagWithContent(nFileNo, "DBLevel" + d, unloadDBLevel(convertBVLevelToDBString(\fSavedBVLevel[d])))
              writeTagIfReqd(nFileNo, "Pan" + d, panSingleToString(\fPan[d]), panSingleToString(grAudDef\fPan[d]))
            EndIf
          Next d
          writeTagIfReqd(nFileNo, "LvlPtLvlSelA", decodeLvlPtLvlSel(\nLvlPtLvlSel), decodeLvlPtLvlSel(grAudDef\nLvlPtLvlSel))
          writeTagIfReqd(nFileNo, "LvlPtPanSelA", decodeLvlPtPanSel(\nLvlPtPanSel), decodeLvlPtPanSel(grAudDef\nLvlPtPanSel))
          ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(k) + ")")
          ; listLevelPoints(k)
          For n = 0 To \nMaxLevelPoint
            bWantThisLevelPoint = #False
            bSavePointTime = #False
            Select \aPoint(n)\nPointType
              Case #SCS_PT_STD
                bWantThisLevelPoint = #True
                bSavePointTime = #True
              Case #SCS_PT_FADE_IN, #SCS_PT_FADE_OUT
                bWantThisLevelPoint = #True
              Case #SCS_PT_START
                If \nFadeInTime <= 0
                  For n2 = 0 To \aPoint(n)\nPointMaxItem
                    If \aPoint(n)\aItem(n2)\sItemLogicalDev
                      If (\aPoint(n)\aItem(n2)\fItemRelDBLevel <> grLevelPointItemDef\fItemRelDBLevel) Or (\aPoint(n)\aItem(n2)\fItemPan <> grLevelPointItemDef\fItemPan)
                        bWantThisLevelPoint = #True
                        Break
                      EndIf
                    EndIf
                  Next n2
                Else
                  ; if fade-in time specified then only save the level point info if the pan is not the default pan
                  For n2 = 0 To \aPoint(n)\nPointMaxItem
                    If \aPoint(n)\aItem(n2)\sItemLogicalDev
                      If \aPoint(n)\aItem(n2)\fItemPan <> grLevelPointItemDef\fItemPan
                        bWantThisLevelPoint = #True
                        Break
                      EndIf
                    EndIf
                  Next n2
                EndIf
              Case #SCS_PT_END
                If \nFadeOutTime <= 0
                  bWantThisLevelPoint = #True
                Else
                  ; if fade-out time specified then only save the level point info if the pan is not the default pan
                  For n2 = 0 To \aPoint(n)\nPointMaxItem
                    If \aPoint(n)\aItem(n2)\sItemLogicalDev
                      If \aPoint(n)\aItem(n2)\fItemPan <> grLevelPointItemDef\fItemPan
                        bWantThisLevelPoint = #True
                        Break
                      EndIf
                    EndIf
                  Next n2
                EndIf
            EndSelect
            If bWantThisLevelPoint
              writeTag(nFileNo, "LvlPt")
              If bSavePointTime
                writeTagWithContent(nFileNo, "LvlPtTime", Str(\aPoint(n)\nPointTime))
              EndIf
              writeTagWithContent(nFileNo, "LvlPtType", decodeLevelPointType(\aPoint(n)\nPointType))
              For n2 = 0 To \aPoint(n)\nPointMaxItem
                If \aPoint(n)\aItem(n2)\sItemLogicalDev
                  writeTag(nFileNo, "LvlPtItem")
                  writeTagWithContent(nFileNo, "LvlPtItemLogicalDev", \aPoint(n)\aItem(n2)\sItemLogicalDev)
                  writeTagIfReqd(nFileNo, "LvlPtItemTracks", \aPoint(n)\aItem(n2)\sItemTracks, grLevelPointItemDef\sItemTracks)
                  writeTagIfReqd(nFileNo, "LvlPtItemInclude", booleanToString(\aPoint(n)\aItem(n2)\bItemInclude), booleanToString(grLevelPointItemDef\bItemInclude))
                  writeTagWithContent(nFileNo, "LvlPtItemRelDBLevel", convertDBLevelToDBString(\aPoint(n)\aItem(n2)\fItemRelDBLevel))
                  writeTagIfReqd(nFileNo, "LvlPtItemPan", panSingleToString(\aPoint(n)\aItem(n2)\fItemPan), panSingleToString(grLevelPointItemDef\fItemPan))
                  writeUnTag(nFileNo, "LvlPtItem")
                EndIf
              Next n2
              writeUnTag(nFileNo, "LvlPt")
            EndIf
          Next n
          
          ; Cue Markers for Audio Files
          If \nMaxCueMarker >= 0
            writeCueMarkersForAud(nFileNo, k)
          EndIf
          
          ; VST Save Selected VST Plugin Data for given aAud File
          If grLicInfo\bVSTPluginsAvailable
            sSelectedVSTPluginName = \sVSTPluginName 
            If (sSelectedVSTPluginName <> "None") And (sSelectedVSTPluginName <> "")
              writeTagWithAttribute(nFileNo, "VSTPlugin", "Name", \sVSTPluginName)
              ; chunk
              If \rVSTChunk\nByteSize > 0
                writeTagWithContentAndAttributes(nFileNo, "VSTChunkMagic", \rVSTChunk\sChunkMagic, "ByteSize", Str(\rVSTChunk\nByteSize))
                writeTagWithContent(nFileNo, "VSTChunkData", \rVSTChunk\sChunkData)
              EndIf
              ; program
              If \nVSTProgram >= 0               
                writeTagWithContent(nFileNo, "VSTProgram", Str(\nVSTProgram))                
              EndIf
              ; parameters
              For nVSTParamPtr = 0 To \nVSTMaxParam
                ; debugMsg(sProcName, "\aVSTParam(" + nVSTParamPtr + ")\fVSTParamValue=" + StrF(\aVSTParam(nVSTParamPtr)\fVSTParamValue) +
                ;                     ", \aVSTParam(" + nVSTParamPtr + ")\fVSTParamDefaultValue=" + StrF(\aVSTParam(nVSTParamPtr)\fVSTParamDefaultValue))
                If \aVSTParam(nVSTParamPtr)\fVSTParamValue <> \aVSTParam(nVSTParamPtr)\fVSTParamDefaultValue
                  writeTagWithContentAndAttributes(nFileNo, "VSTParam", StrF(\aVSTParam(nVSTParamPtr)\fVSTParamValue), "Index", Str(\aVSTParam(nVSTParamPtr)\nVSTParamIndex))
                EndIf
              Next nVSTParamPtr
              ; bypass
              writeTagIfReqd(nFileNo, "VSTBypass", Str(aAud(k)\bVSTBypass), "0")          
              writeUnTag(nFileNo, "VSTPlugin")
            EndIf
            CompilerIf #c_vst_same_as
              If \sVSTPluginSameAsCue ; nb mutually exclusive with \sVSTPluginName
                writeTagWithContent(nFileNo, "VSTPluginSameAsCue", \sVSTPluginSameAsCue)
                writeTagWithContent(nFileNo, "VSTPluginSameAsSubNo", Str(\nVSTPluginSameAsSubNo))
              EndIf
            CompilerEndIf
          EndIf ; EndIf grLicInfo\bVSTPluginsAvailable
          
          If grLicInfo\bTempoAndPitchAvailable
            If \nAudTempoEtcAction <> #SCS_AF_ACTION_NONE
              writeTagWithContent(nFileNo, "AudTempoEtcAction", decodeAFAction(\nAudTempoEtcAction))
              writeTagWithContent(nFileNo, "AudTempoEtcValue", strFTrimmed(\fAudTempoEtcValue,3))
            EndIf
          EndIf ; EndIf grLicInfo\bTempoAndPitchAvailable
          
          ; End of the Audio File tag for XML
          writeUnTag(nFileNo, "AudioFile")
          
        EndWith
        ;}
        
      ElseIf aSub(j)\bSubTypeA  ; INFO Saving \bSubTypeA
        ;{
        If aSub(j)\nAudCount = 0
          writeTagIfReqd(nFileNo, "SubPlaceHolder", booleanToString(aSub(j)\bSubPlaceHolder), booleanToString(grSubDef\bSubPlaceHolder))
        EndIf
        writeTagIfReqd(nFileNo, "VideoRepeat", booleanToString(aSub(j)\bPLRepeat), booleanToString(grSubDef\bPLRepeat))
        writeTagIfReqd(nFileNo, "PauseAtEnd", booleanToString(aSub(j)\bPauseAtEnd), booleanToString(grSubDef\bPauseAtEnd))
        writeTagIfReqd(nFileNo, "MayUseGapless", booleanToString(aSub(j)\bMayUseGaplessStream), booleanToString(grSubDef\bMayUseGaplessStream))
        writeTagWithContent(nFileNo, "OutputScreen", Str(aSub(j)\nOutputScreen))
        writeTagWithContent(nFileNo, "Screens", aSub(j)\sScreens)
        d = 0
        If aSub(j)\bMuteVideoAudio
          writeTagWithContent(nFileNo, "MuteVideoAudio" + d, booleanToString(aSub(j)\bMuteVideoAudio))
        ElseIf Len(aSub(j)\sVidAudLogicalDev) > 0
          writeTagWithContent(nFileNo, "VideoLogicalAudioDev", aSub(j)\sVidAudLogicalDev)
          If aSub(j)\fSubTrimFactor[d] <> grSubDef\fSubTrimFactor[d]
            writeTagIfReqd(nFileNo, "SubDBTrim" + d, aSub(j)\sPLDBTrim[d], grSubDef\sPLDBTrim[d])
          EndIf
          writeTagWithContent(nFileNo, "SubDBLevel" + d, unloadDBLevel(aSub(j)\sPLMastDBLevel[d]))
          writeTagIfReqd(nFileNo, "SubPan" + d, panSingleToString(aSub(j)\fPLPan[d]), panSingleToString(grSubDef\fPLPan[d]))
        EndIf
        writeTagIfReqd(nFileNo, "PLFadeInTime", Str(aSub(j)\nPLFadeInTime), Str(grSubDef\nPLFadeInTime))
        writeTagIfReqd(nFileNo, "PLFadeOutTime", Str(aSub(j)\nPLFadeOutTime), Str(grSubDef\nPLFadeOutTime))
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          With aAud(k)
            writeTag(nFileNo, "VideoFile") ; Warning: VideoFile tag is also used for non-files (eg for capture devices).
                                           ; This is because pre-11.6.0 only VideoFile existed and this group contains tags which are required for other sources, such as tags for xPos, aspect ration, and so on.
            Select \nVideoSource
              Case #SCS_VID_SRC_FILE
                If bRecovery = #False
                  \sStoredFileName = encodeFileName(\sFileName, bCollecting, bTemplate)
                EndIf
                writeTagWithContent(nFileNo, "Source", decodeVideoSource(\nVideoSource))
                If bExport Or bCollecting
                  s2ndStoredFileName = \sStoredFileName
                  If (bExport) And (bCopyFiles) And (\bAudPlaceHolder = #False)
                    If LCase(GetPathPart(\sFileName)) <> LCase(gs2ndCueFolder)
                      sTmp1 = \sFileName
                      sTmp2 = gs2ndCueFolder + GetFilePart(sTmp1)
                      If FileExists(sTmp2, #False) = #False
                        SetGadgetText(WEX\lblExportStatus, "Copying " + GetFilePart(\sFileName) + "...")
                        CopyFile(sTmp1, sTmp2)
                        SetGadgetText(WEX\lblExportStatus, "")
                      EndIf
                    EndIf
                    s2ndStoredFileName = "$(Cue)\" + GetFilePart(\sFileName)
                  EndIf
                  If \bAudPlaceHolder
                    writeTagWithContent(nFileNo, "AudPlaceHolder", booleanToString(\bAudPlaceHolder))
                  Else
                    writeTagWithContent(nFileNo, "FileName", s2ndStoredFileName)
                  EndIf
                  
                Else
                  If \bAudPlaceHolder
                    writeTagWithContent(nFileNo, "AudPlaceHolder", booleanToString(\bAudPlaceHolder))
                  Else
                    writeTagWithContent(nFileNo, "FileName", \sStoredFileName)
                  EndIf
                  
                EndIf
                
                Select \nFileFormat
                  Case #SCS_FILEFORMAT_VIDEO
                    writeTagIfReqd(nFileNo, "StartAt", Str(\nStartAt), Str(grAudDef\nStartAt))
                    writeTagIfReqd(nFileNo, "EndAt", Str(\nEndAt), Str(grAudDef\nEndAt))
                    writeTagWithContent(nFileNo, "RelLevel", StrF(\fPLRelLevel,0))
                  Case #SCS_FILEFORMAT_PICTURE
                    If (\bContinuous = #False) And (\bLogo = #False)
                      writeTagIfReqd(nFileNo, "EndAt", Str(\nEndAt), Str(grAudDef\nEndAt))
                    EndIf
                    writeTagIfReqd(nFileNo, "Logo", booleanToString(\bLogo), booleanToString(grAudDef\bLogo))
                    writeTagIfReqd(nFileNo, "Overlay", booleanToString(\bOverlay), booleanToString(grAudDef\bOverlay))
                    writeTagIfReqd(nFileNo, "Continuous", booleanToString(\bContinuous), booleanToString(grAudDef\bContinuous))
                    writeTagIfReqd(nFileNo, "Rotate", Str(\nRotate), Str(grAudDef\nRotate))
                    writeTagIfReqd(nFileNo, "Flip", decodeFlip(\nFlip), decodeFlip(grAudDef\nFlip))
                EndSelect
                
              ; Saving the Video Capture Settings  
              Case #SCS_VID_SRC_CAPTURE   
                writeTagWithContent(nFileNo, "Source", decodeVideoSource(\nVideoSource))
                writeTagIfReqd(nFileNo, "Continuous", booleanToString(\bContinuous), booleanToString(grAudDef\bContinuous))
                If (\bContinuous = #False)
                  writeTagIfReqd(nFileNo, "EndAt", Str(\nEndAt), Str(grAudDef\nEndAt)) 
                EndIf
                writeTagIfReqd(nFileNo, "Device", \sVideoCaptureLogicalDevice, grAudDef\sVideoCaptureLogicalDevice)
                
            EndSelect
            
            writeTagIfReqd(nFileNo, "xPos", Str(\nXPos), Str(grAudDef\nXPos))
            writeTagIfReqd(nFileNo, "yPos", Str(\nYPos), Str(grAudDef\nYPos))
            writeTagIfReqd(nFileNo, "Size", Str(\nSize * -1), Str(grAudDef\nSize * -1)) ; negate to comply with pre-11.2.1 cue files
            writeTagIfReqd(nFileNo, "Aspect", Str(\nAspect), Str(grAudDef\nAspect))     ; deprecated as at 11.2.1
            writeTagIfReqd(nFileNo, "AspectRatioType", decodeAspectRatioType(\nAspectRatioType), decodeAspectRatioType(grAudDef\nAspectRatioType))   ; new in 11.2.1
            If \nAspectRatioType = #SCS_ART_CUSTOM
              writeTagWithContent(nFileNo, "AspectRatioHVal", Str(\nAspectRatioHVal))   ; new in 11.2.1
            EndIf
            writeTagIfReqd(nFileNo, "TransType", decodeTransType(\nPLTransType), decodeTransType(grAudDef\nPLTransType))
            writeTagIfReqd(nFileNo, "TransTime", Str(\nPLTransTime), "0")
            ; Cue Markers for Video Files
            If \nMaxCueMarker >= 0
              writeCueMarkersForAud(nFileNo, k)
            EndIf
            writeUnTag(nFileNo, "VideoFile")
            k = \nNextAudIndex
          EndWith
        Wend
        ;}
        
      ElseIf aSub(j)\bSubTypeP  ; INFO Saving \bSubTypeP
        ;{
        If aSub(j)\nAudCount = 0
          writeTagIfReqd(nFileNo, "SubPlaceHolder", booleanToString(aSub(j)\bSubPlaceHolder), booleanToString(grSubDef\bSubPlaceHolder))
        EndIf
        With aSub(j)
          writeTagIfReqd(nFileNo, "PLRandom", booleanToString(\bPLRandom), booleanToString(grSubDef\bPLRandom))
          writeTagIfReqd(nFileNo, "PLRepeat", booleanToString(\bPLRepeat), booleanToString(grSubDef\bPLRepeat))
          writeTagIfReqd(nFileNo, "PLSavePos", booleanToString(\bPLSavePos), booleanToString(grSubDef\bPLSavePos))
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \sPLLogicalDev[d]
              writeTagWithContent(nFileNo, "PLLogicalDev" + d, \sPLLogicalDev[d])
              If \sPLTracks[d] <> #SCS_TRACKS_DFLT
                writeTagIfReqd(nFileNo, "PLTracks" + d, \sPLTracks[d], grSubDef\sPLTracks[d])
              EndIf
              If \fSubTrimFactor[d] <> grSubDef\fSubTrimFactor[d]
                writeTagIfReqd(nFileNo, "PLDBTrim" + d, \sPLDBTrim[d], grSubDef\sPLDBTrim[d])
              EndIf
              writeTagWithContent(nFileNo, "PLMastDBLevel" + d, unloadDBLevel(\sPLMastDBLevel[d]))
              writeTagIfReqd(nFileNo, "PLPan" + d, panSingleToString(\fPLPan[d]), panSingleToString(grSubDef\fPLPan[d]))
            EndIf
          Next d
          writeTagIfReqd(nFileNo, "PLFadeInTime", Str(\nPLFadeInTime), Str(grSubDef\nPLFadeInTime))
          writeTagIfReqd(nFileNo, "PLFadeOutTime", Str(\nPLFadeOutTime), Str(grSubDef\nPLFadeOutTime))
        EndWith
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          With aAud(k)
            writeTag(nFileNo, "AudioFile")
            If bRecovery = #False
              \sStoredFileName = encodeFileName(\sFileName, bCollecting, bTemplate)
            EndIf
            If bExport Or bCollecting
              s2ndStoredFileName = \sStoredFileName
              If (bExport) And (bCopyFiles)
                If LCase(GetPathPart(\sFileName)) <> LCase(gs2ndCueFolder)
                  sTmp1 = \sFileName
                  ; sTmp2 = gs2ndCueFolder + "\" + GetFilePart(sTmp1)
                  sTmp2 = gs2ndCueFolder + GetFilePart(sTmp1)
                  If FileExists(sTmp2, #False) = #False
                    SetGadgetText(WEX\lblExportStatus, "Copying " + GetFilePart(\sFileName) + "...")
                    CopyFile(sTmp1, sTmp2)
                    SetGadgetText(WEX\lblExportStatus, "")
                  EndIf
                EndIf
                s2ndStoredFileName = "$(Cue)\" + GetFilePart(\sFileName)
              EndIf
              writeTagWithContent(nFileNo, "FileName", s2ndStoredFileName)
              
            Else
              writeTagWithContent(nFileNo, "FileName", \sStoredFileName)
              
            EndIf
            
            If \bAudNormSet And \fAudNormIntegrated <> -Infinity()
              writeTagWithContent(nFileNo, "AudNormInfo", StrF(\fAudNormIntegrated,5) + ";" + StrF(\fAudNormPeak,5) + ";" + StrF(\fAudNormTruePeak,5))
            EndIf
            writeTagIfReqd(nFileNo, "StartAt", Str(\nStartAt), Str(grAudDef\nStartAt))
            writeTagIfReqd(nFileNo, "EndAt", Str(\nEndAt), Str(grAudDef\nEndAt))
            writeTagWithContent(nFileNo, "PLRelLevel", StrF(\fPLRelLevel,0))
            writeTagIfReqd(nFileNo, "PLTransType", decodeTransType(\nPLTransType), decodeTransType(grAudDef\nPLTransType))
            writeTagIfReqd(nFileNo, "PLTransTime", Str(\nPLTransTime), "0")
            writeUnTag(nFileNo, "AudioFile")
            k = \nNextAudIndex
          EndWith
        Wend
        ;}
        
      ElseIf aSub(j)\bSubTypeI  ; INFO Saving \bSubTypeI
        ;{
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          With aAud(k)
            writeTag(nFileNo, "LiveInput")
            For d = 0 To grLicInfo\nMaxLiveDevPerAud
              If Len(\sInputLogicalDev[d]) > 0
                writeTagWithContent(nFileNo, "InputLogicalDev" + d, \sInputLogicalDev[d])
                If \bInputOff[d]
                  writeTagWithContent(nFileNo, "InputOff" + d, booleanToString(\bInputOff[d]))
                Else
                  writeTagWithContent(nFileNo, "InputDBLevel" + d, unloadDBLevel(\sInputDBLevel[d]))
                EndIf
              EndIf
            Next d
            writeTagIfReqd(nFileNo, "FadeInTime", Str(\nFadeInTime), Str(grAudDef\nFadeInTime))
            writeTagIfReqd(nFileNo, "FadeInType", decodeFadeType(\nFadeInType), decodeFadeType(grAudDef\nFadeInType))
            writeTagIfReqd(nFileNo, "FadeOutTime", Str(\nFadeOutTime), Str(grAudDef\nFadeOutTime))
            writeTagIfReqd(nFileNo, "FadeOutType", decodeFadeType(\nFadeOutType), decodeFadeType(grAudDef\nFadeOutType))
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If \sLogicalDev[d]
                writeTagWithContent(nFileNo, "LogicalDev" + d, \sLogicalDev[d])
                If \fTrimFactor[d] <> grAudDef\fTrimFactor[d]
                  writeTagIfReqd(nFileNo, "DBTrim" + d, \sDBTrim[d], grAudDef\sDBTrim[d])
                EndIf
                writeTagWithContent(nFileNo, "DBLevel" + d, unloadDBLevel(convertBVLevelToDBString(\fSavedBVLevel[d])))
                writeTagIfReqd(nFileNo, "Pan" + d, panSingleToString(\fSavedPan[d]), panSingleToString(grAudDef\fSavedPan[d]))
              EndIf
            Next d
            writeUnTag(nFileNo, "LiveInput")
            k = \nNextAudIndex
          EndWith
        Wend
        ;}
        
      EndIf
      
      With aSub(j)
        If \bSubTypeE   ; INFO Saving \bSubTypeE
          ;{
          writeTagWithContent(nFileNo, "MemoRTFText", \sMemoRTFText)
          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sMemoRTFText=" + \sMemoRTFText)
          writeTagIfReqd(nFileNo, "MemoContinuous", booleanToString(\bMemoContinuous), booleanToString(grSubDef\bMemoContinuous))
          If \bMemoContinuous = #False
            writeTagIfReqd(nFileNo, "MemoDisplayTime", Str(\nMemoDisplayTime), Str(grSubDef\nMemoDisplayTime))
          EndIf
          writeTagWithContent(nFileNo, "MemoAspectRatio", decodeAspectRatioValue(\nMemoAspectRatio))
          writeTagWithContent(nFileNo, "MemoDesignWidth", Str(\nMemoDesignWidth))
          ; writeTagWithContent(nFileNo, "MemoDesignHeight", Str(\nMemoDesignHeight)) ; design height not currently required as SCS calculates design height using \nMemoDesignWidth and \nMemoAspectRatio
          writeTagIfReqd(nFileNo, "MemoDisplayWidth", Str(\nMemoDisplayWidth), Str(grSubDef\nMemoDisplayWidth))
          writeTagIfReqd(nFileNo, "MemoDisplayHeight", Str(\nMemoDisplayHeight), Str(grSubDef\nMemoDisplayHeight))
          writeTagIfReqd(nFileNo, "MemoPageColor", Str(\nMemoPageColor), Str(grSubDef\nMemoPageColor))
          writeTagIfReqd(nFileNo, "MemoTextBackColor", Str(\nMemoTextBackColor), Str(grSubDef\nMemoTextBackColor))
          writeTagIfReqd(nFileNo, "MemoTextColor", Str(\nMemoTextColor), Str(grSubDef\nMemoTextColor))
          writeTagIfReqd(nFileNo, "MemoScreen", Str(\nMemoScreen), Str(grSubDef\nMemoScreen))
          writeTagIfReqd(nFileNo, "MemoResizeFont", booleanToString(\bMemoResizeFont), booleanToString(grSubDef\bMemoResizeFont))
          ;}
        EndIf
        
        If \bSubTypeG   ; INFO Saving \bSubTypeG
          ;{
          writeTagWithContent(nFileNo, "GoToCue", \sCueToGoTo)
          writeTagIfReqd(nFileNo, "GoToCueButDoNotStartIt", booleanToString(\bGoToCueButDoNotStartIt), booleanToString(grSubDef\bGoToCueButDoNotStartIt))
          ;}
        EndIf
        
        If \bSubTypeJ   ; INFO Saving \bSubTypeJ
          ;{
          nEnableDisableNo = -1
          For n = 0 To #SCS_MAX_ENABLE_DISABLE
            If \aEnableDisable[n]\sFirstCue
              writeTag(nFileNo, "EDCueItem")
              writeTagWithContent(nFileNo, "EDCueFirst", \aEnableDisable[n]\sFirstCue)
              writeTagIfReqd(nFileNo, "EDCueLast", \aEnableDisable[n]\sLastCue, grEnableDisableDef\sLastCue)
              writeTagWithContent(nFileNo, "EDAction", decodeEnaDisAction(\aEnableDisable[n]\nAction))
              writeUnTag(nFileNo, "EDCueItem")
            EndIf
          Next n
          ;}
        EndIf
        
        If \bSubTypeK   ; INFO Saving \bSubTypeK
          ;{
          writeTagWithContent(nFileNo, "LTLogicalDev", \sLTLogicalDev)
          writeTagWithContent(nFileNo, "LTEntryType", decodeLTEntryType(\nLTEntryType))
          Select \nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              If \nMaxFixture >= 0
                writeTag(nFileNo, "LTFixtures")
                For n = 0 To \nMaxFixture
                  If \aLTFixture(n)\sLTFixtureCode
                    If \aLTFixture(n)\nFixtureLinkGroup > 0
                      writeTagWithContentAndAttributes(nFileNo, "LTFixtureCode", \aLTFixture(n)\sLTFixtureCode, "LinkGroup", Str(\aLTFixture(n)\nFixtureLinkGroup))
                    Else
                      writeTagWithContent(nFileNo, "LTFixtureCode", \aLTFixture(n)\sLTFixtureCode)
                    EndIf
                  EndIf
                Next n
                writeUnTag(nFileNo, "LTFixtures")
              EndIf
              
          EndSelect
          
          If aCue(i)\nActivationMethod = #SCS_ACMETH_EXT_FADER
            writeTagIfReqd(nFileNo, "LTApplyCurrValuesAsMins", booleanToString(\bLTApplyCurrValuesAsMins), booleanToString(grSubDef\bLTApplyCurrValuesAsMins))
          EndIf
          
          If (\bChase) And (aCue(i)\nActivationMethod <> #SCS_ACMETH_EXT_FADER)
            writeTagWithContent(nFileNo, "LTChase", booleanToString(\bChase))
            writeTagIfReqd(nFileNo, "LTChaseMode", decodeDMXChaseMode(\nChaseMode), decodeDMXChaseMode(grSubDef\nChaseMode))
            writeTagWithContent(nFileNo, "LTChaseSteps", Str(\nChaseSteps))
            writeTagWithContent(nFileNo, "LTChaseSpeed", Str(\nChaseSpeed))
            writeTagIfReqd(nFileNo, "LTNextLTStopsChase", booleanToString(\bNextLTStopsChase), booleanToString(grSubDef\bNextLTStopsChase))
            writeTagIfReqd(nFileNo, "LTMonitorTapDelay", booleanToString(\bMonitorTapDelay), booleanToString(grSubDef\bMonitorTapDelay))
            ; debugMsg0(sProcName, "aSub(" + \sSubLabel + ")\nMaxChaseStepIndex=" + \nMaxChaseStepIndex + ", \nLTEntryType=" + decodeLTEntryType(\nLTEntryType))
            For n = 0 To \nMaxChaseStepIndex
              If \nMaxChaseStepIndex > 0
                writeTag(nFileNo, "LTChaseStep")
              EndIf
              Select \nLTEntryType
                Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                  ; For m = 0 To \aChaseStep(0)\nDMXSendItemCount - 1 ; grLicInfo\nMaxDMXItemPerLightingSub
                  For m = 0 To \aChaseStep(n)\nDMXSendItemCount - 1 ; Changed 12Jan2022 11.9ag following bug reported by Vince (Nelly Productions)
                    ; debugMsg0(sProcName, "n=" + n + ", \aChaseStep(0)\nDMXSendItemCount=" + \aChaseStep(0)\nDMXSendItemCount + ", m=" + m)
                    If \aChaseStep(n)\aDMXSendItem(m)\sDMXItemStr
                      writeTagWithContent(nFileNo, "LTDMXItemStr", \aChaseStep(n)\aDMXSendItem(m)\sDMXItemStr)
                    EndIf
                  Next m
                  
                Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                  For m = 0 To \nMaxFixture
                    If \aChaseStep(n)\aFixtureItem(m)\sFixtureCode
                      bFixtureItemTagWritten = #False
                      nTotalChans = getTotalChansForFixture(@grProd, @aSub(j), \aChaseStep(n)\aFixtureItem(m)\sFixtureCode)
                      For p = 0 To nTotalChans-1
                        If p <= ArraySize(\aChaseStep(n)\aFixtureItem(m)\aFixChan())
                          bSaveFixtureChanInfo = #True
                          If (\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bRelChanIncluded = grLTFixChanDef\bRelChanIncluded) And
                             (Len(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue) = 0 Or \aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue = grLTFixChanDef\sDMXDisplayValue)
                            bSaveFixtureChanInfo = #False
                          EndIf
                          If bSaveFixtureChanInfo
                            If bFixtureItemTagWritten = #False
                              writeTagWithAttribute(nFileNo, "LTFixtureItem", "FixtureCode", \aChaseStep(n)\aFixtureItem(m)\sFixtureCode)
                              bFixtureItemTagWritten = #True
                            EndIf
                            writeTagWithAttribute(nFileNo, "LTFixtureItemChan", "RelChan", Str(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\nRelChanNo))
                            writeTagIfReqd(nFileNo, "LTFixtureItemChanInc", booleanToString(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bRelChanIncluded), booleanToString(grLTFixChanDef\bRelChanIncluded))
                            If \aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue
                              writeTagIfReqd(nFileNo, "LTFixtureItemChanVal", \aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue, grLTFixChanDef\sDMXDisplayValue)
                            EndIf
                            If \bChase = #False
                              ; nb n will be 0 if we get here
                              writeTagIfReqd(nFileNo, "LTFixtureItemChanApplyFade", booleanToString(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bApplyFadeTime), booleanToString(grLTFixChanDef\bApplyFadeTime))
                            EndIf
                            writeUnTag(nFileNo, "LTFixtureItemChan")
                          EndIf
                        EndIf
                      Next p
                      If bFixtureItemTagWritten
                        writeUnTag(nFileNo, "LTFixtureItem")
                      EndIf
                    EndIf
                  Next m
                  
              EndSelect
              If \nMaxChaseStepIndex > 0
                writeUnTag(nFileNo, "LTChaseStep")
              EndIf
            Next n
          Else
            Select \nLTEntryType
              Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                For m = 0 To \aChaseStep(0)\nDMXSendItemCount - 1 ; grLicInfo\nMaxDMXItemPerLightingSub
                  If \aChaseStep(0)\aDMXSendItem(m)\sDMXItemStr
                    writeTagWithContent(nFileNo, "LTDMXItemStr", \aChaseStep(0)\aDMXSendItem(m)\sDMXItemStr)
                  EndIf
                Next m
                
              Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                For m = 0 To \nMaxFixture
                  n = 0 ; n used as step index, as in above code
                  If \aChaseStep(n)\aFixtureItem(m)\sFixtureCode
                    bFixtureItemTagWritten = #False
                    nTotalChans = getTotalChansForFixture(@grProd, @aSub(j), \aChaseStep(n)\aFixtureItem(m)\sFixtureCode)
                    For p = 0 To nTotalChans-1
                      If p <= ArraySize(\aChaseStep(n)\aFixtureItem(m)\aFixChan())
                        bSaveFixtureChanInfo = #True
                        If (\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bRelChanIncluded = grLTFixChanDef\bRelChanIncluded) And
                           (\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bApplyFadeTime = grLTFixChanDef\bApplyFadeTime) And
                           (Len(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue) = 0 Or \aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue = grLTFixChanDef\sDMXDisplayValue)
                          bSaveFixtureChanInfo = #False
                        EndIf
                        If bSaveFixtureChanInfo
                          If bFixtureItemTagWritten = #False
                            writeTagWithAttribute(nFileNo, "LTFixtureItem", "FixtureCode", \aChaseStep(n)\aFixtureItem(m)\sFixtureCode)
                            bFixtureItemTagWritten = #True
                          EndIf
                          writeTagWithAttribute(nFileNo, "LTFixtureItemChan", "RelChan", Str(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\nRelChanNo))
                          writeTagIfReqd(nFileNo, "LTFixtureItemChanInc", booleanToString(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bRelChanIncluded), booleanToString(grLTFixChanDef\bRelChanIncluded))
                          If \aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue
                            writeTagIfReqd(nFileNo, "LTFixtureItemChanVal", \aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\sDMXDisplayValue, grLTFixChanDef\sDMXDisplayValue)
                          EndIf
                          writeTagIfReqd(nFileNo, "LTFixtureItemChanApplyFade", booleanToString(\aChaseStep(n)\aFixtureItem(m)\aFixChan(p)\bApplyFadeTime), booleanToString(grLTFixChanDef\bApplyFadeTime))
                          writeUnTag(nFileNo, "LTFixtureItemChan")
                        EndIf
                      EndIf
                    Next p
                    If bFixtureItemTagWritten
                      writeUnTag(nFileNo, "LTFixtureItem")
                    EndIf
                  EndIf
                Next m
                
            EndSelect
          EndIf
          If aCue(i)\nActivationMethod <> #SCS_ACMETH_EXT_FADER
            Select \nLTEntryType
              Case #SCS_LT_ENTRY_TYPE_BLACKOUT
                writeTagWithContent(nFileNo, "LTBLFadeAction", decodeDMXFadeActionBL(\nLTBLFadeAction))
                If \nLTBLFadeAction = #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTBLFadeUserTime", \sLTBLFadeUserTime, \nLTBLFadeUserTime, grSubDef\nLTBLFadeUserTime)
                EndIf
                
              Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
                
              Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                writeTagWithContent(nFileNo, "LTDCFadeUpAction", decodeDMXFadeActionDC(\nLTDCFadeUpAction))
                If \nLTDCFadeUpAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTDCFadeUpUserTime", \sLTDCFadeUpUserTime, \nLTDCFadeUpUserTime, grSubDef\nLTDCFadeUpUserTime)
                EndIf
                writeTagWithContent(nFileNo, "LTDCFadeDownAction", decodeDMXFadeActionDC(\nLTDCFadeDownAction))
                If \nLTDCFadeDownAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTDCFadeDownUserTime", \sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime, grSubDef\nLTDCFadeDownUserTime)
                EndIf
                writeTagWithContent(nFileNo, "LTDCFadeOutOthersAction", decodeDMXFadeActionDC(\nLTDCFadeOutOthersAction))
                If \nLTDCFadeOutOthersAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTDCFadeOutOthersUserTime", \sLTDCFadeOutOthersUserTime, \nLTDCFadeOutOthersUserTime, grSubDef\nLTDCFadeOutOthersUserTime)
                EndIf
                
              Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
                ; NOTE: Added 6Nov2023 11.10.0cp - save 'obsolete' strings for backward-compatibility, where possible
                ; These cue file entries MUST be saved BEFORE the new entries so that on reading the cue file by SCS 11.10.0 (or later) the new entries will override any saved 'obsolete' entries
                Select \nLTDIFadeUpAction
                  Case #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
                    writeTagWithContent(nFileNo, "LTDefFadeAction", "Prod")
                  Case #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
                    writeTagWithContent(nFileNo, "LTDefFadeAction", "User")
                    macWriteTagForNumericOrStringParam("LTDefFadeUserTime", \sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime, grSubDef\nLTDIFadeUpUserTime)
                EndSelect
                Select \nLTDIFadeOutOthersAction
                  Case #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
                    writeTagWithContent(nFileNo, "LTFadeOutOthersAction", "Def")
                  Default
                    writeTagWithContent(nFileNo, "LTFadeOutOthersAction", decodeDMXFadeActionDI(\nLTDIFadeOutOthersAction))
                EndSelect
                If \nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTFadeOutOthersUserTime", \sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime, grSubDef\nLTDIFadeOutOthersUserTime)
                EndIf
                ; NOTE: End added 6Nov2023 11.10.0cp
                writeTagWithContent(nFileNo, "LTDIFadeUpAction", decodeDMXFadeActionDI(\nLTDIFadeUpAction))
                If \nLTDIFadeUpAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTDIFadeUpUserTime", \sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime, grSubDef\nLTDIFadeUpUserTime)
                EndIf
                writeTagWithContent(nFileNo, "LTDIFadeDownAction", decodeDMXFadeActionDI(\nLTDIFadeDownAction))
                If \nLTDIFadeDownAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTDIFadeDownUserTime", \sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime, grSubDef\nLTDIFadeDownUserTime)
                EndIf
                writeTagWithContent(nFileNo, "LTDIFadeOutOthersAction", decodeDMXFadeActionDI(\nLTDIFadeOutOthersAction))
                If \nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTDIFadeOutOthersUserTime", \sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime, grSubDef\nLTDIFadeOutOthersUserTime)
                EndIf
                
              Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                writeTagWithContent(nFileNo, "LTFIFadeUpAction", decodeDMXFadeActionFI(\nLTFIFadeUpAction))
                If \nLTFIFadeUpAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
                  ; debugMsg0(sProcName, "\sLTFIFadeUpUserTime=" + \sLTFIFadeUpUserTime + ", \nLTFIFadeUpUserTime=" + \nLTFIFadeUpUserTime)
                  macWriteTagForNumericOrStringParam("LTFIFadeUpUserTime", \sLTFIFadeUpUserTime, \nLTFIFadeUpUserTime, grSubDef\nLTFIFadeUpUserTime)
                EndIf
                writeTagWithContent(nFileNo, "LTFIFadeDownAction", decodeDMXFadeActionFI(\nLTFIFadeDownAction))
                If \nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTFIFadeDownUserTime", \sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime, grSubDef\nLTFIFadeDownUserTime)
                EndIf
                writeTagWithContent(nFileNo, "LTFIFadeOutOthersAction", decodeDMXFadeActionFI(\nLTFIFadeOutOthersAction))
                If \nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
                  macWriteTagForNumericOrStringParam("LTFIFadeOutOthersUserTime", \sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime, grSubDef\nLTFIFadeOutOthersUserTime)
                EndIf
                
            EndSelect
          EndIf ; EndIf aCue(i)\nActivationMethod <> #SCS_ACMETH_EXT_FADER
          ;}
        EndIf ; EndIf \bSubTypeK
        
        If \bSubTypeL   ; INFO Saving \bSubTypeL
          ;{
          writeTagIfReqd(nFileNo, "LCCue", \sLCCue, grSubDef\sLCCue)
          writeTagIfReqd(nFileNo, "LCSubNo", Str(\nLCSubNo), Str(grSubDef\nLCSubNo))
          ; Kept for backward-compatibility 20Aug2021 11.8.6 - was: writeTagIfReqd(nFileNo, "LCAbsRel", Str(\nLCAbsRel), Str(grSubDef\nLCAbsRel))
          If \nLCAction <> grSubDef\nLCAction
            If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
              writeTagWithContent(nFileNo, "LCAbsRel", Str(#SCS_LC_ABSOLUTE))
            ElseIf \nLCAction = #SCS_LC_ACTION_RELATIVE
              writeTagWithContent(nFileNo, "LCAbsRel", Str(#SCS_LC_RELATIVE))
            EndIf
          EndIf
          ; End kept for backward-compatibility 20Aug2021 11.8.6
          writeTagIfReqd(nFileNo, "LCAction", decodeLCAction(\nLCAction), decodeLCAction(grSubDef\nLCAction)) ; Added 20Aug2021 11.8.6
          Select \nLCAction
            Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
              writeTagWithContent(nFileNo, "LCSameLevel", booleanToString(\bLCSameLevel))
              writeTagWithContent(nFileNo, "LCSameTime", booleanToString(\bLCSameTime))
              If \bLCTargetIsF Or \bLCTargetIsI
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  bWantThis = #False
                  If \nLCAudPtr = -1
                    bWantThis = #True
                  ElseIf aAud(\nLCAudPtr)\sLogicalDev[d]
                    bWantThis = #True
                  EndIf
                  If bWantThis
                    writeTagIfReqd(nFileNo, "LCInclude" + d, booleanToString(\bLCInclude[d]), booleanToString(grSubDef\bLCInclude[d]))
                    If \bLCInclude[d]
                      If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                        writeTagWithContent(nFileNo, "LCReqdDBLevel" + d, unloadDBLevel(\sLCReqdDBLevel[d]))
                      Else
                        writeTagWithContent(nFileNo, "LCReqdDBLevel" + d, \sLCReqdDBLevel[d])
                      EndIf
                      writeTagIfReqd(nFileNo, "LCReqdPan" + d, panSingleToString(\fLCReqdPan[d]), panSingleToString(grSubDef\fLCReqdPan[d]))
                      macWriteTagForNumericOrStringParam("LCTime" + d, \sLCTime[d], \nLCTime[d], grSubDef\nLCTime[d])
                      ; debugMsg0(sProcName, "\sLCTime[" + d + "]=" + \sLCTime[d] + ", \nLCTime[" + d + "]=" + \nLCTime[d])
                    EndIf
                  EndIf
                Next d
                
              ElseIf \bLCTargetIsA
                d = 0
                writeTagIfReqd(nFileNo, "LCInclude" + d, booleanToString(\bLCInclude[d]), booleanToString(grSubDef\bLCInclude[d]))
                If \bLCInclude[d]
                  If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                    writeTagWithContent(nFileNo, "LCReqdDBLevel" + d, unloadDBLevel(\sLCReqdDBLevel[d]))
                  Else
                    writeTagWithContent(nFileNo, "LCReqdDBLevel" + d, \sLCReqdDBLevel[d])
                  EndIf
                  writeTagIfReqd(nFileNo, "LCReqdPan" + d, panSingleToString(\fLCReqdPan[d]), panSingleToString(grSubDef\fLCReqdPan[d]))
                  macWriteTagForNumericOrStringParam("LCTime" + d, \sLCTime[d], \nLCTime[d], grSubDef\nLCTime[d])
                EndIf
                
              ElseIf \bLCTargetIsP
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  bWantThis = #False
                  If \nLCSubPtr = -1
                    bWantThis = #True
                  ElseIf Len(aSub(\nLCSubPtr)\sPLLogicalDev[d]) > 0
                    bWantThis = #True
                  EndIf
                  If bWantThis
                    writeTagIfReqd(nFileNo, "LCInclude" + d, booleanToString(\bLCInclude[d]), booleanToString(grSubDef\bLCInclude[d]))
                    If \bLCInclude[d]
                      If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                        writeTagWithContent(nFileNo, "LCReqdDBLevel" + d, unloadDBLevel(\sLCReqdDBLevel[d]))
                      Else
                        writeTagWithContent(nFileNo, "LCReqdDBLevel" + d, \sLCReqdDBLevel[d])
                      EndIf
                      writeTagIfReqd(nFileNo, "LCReqdPan" + d, panSingleToString(\fLCReqdPan[d]), panSingleToString(grSubDef\fLCReqdPan[d]))
                      macWriteTagForNumericOrStringParam("LCTime" + d, \sLCTime[d], \nLCTime[d], grSubDef\nLCTime[d])
                    EndIf
                  EndIf
                Next d
              EndIf
              
              writeTagIfReqd(nFileNo, "LCType", decodeFadeType(\nLCType), decodeFadeType(grSubDef\nLCType))
              writeTagIfReqd(nFileNo, "LCStartAt", Str(\nLCStartAt), Str(grSubDef\nLCStartAt))
              
            Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
              writeTagIfReqd(nFileNo, "LCActionValue", strFTrimmed(\fLCActionValue,3), strFTrimmed(grSubDef\fLCActionValue,3))
              writeTagIfReqd(nFileNo, "LCActionTime", Str(\nLCActionTime), Str(grSubDef\nLCActionTime))
              
          EndSelect
          ;}
        EndIf
        
        If \bSubTypeM  ; INFO Saving \bSubTypeM
          ;{
          For n = 0 To #SCS_MAX_CTRL_SEND
            If Trim(\aCtrlSend[n]\sCSLogicalDev)
              nCtrlSendIndex + 1
              writeTag(nFileNo, "ControlMessage")
              writeTagWithContent(nFileNo, "CMLogicalDev", \aCtrlSend[n]\sCSLogicalDev)
              writeTagIfReqd(nFileNo, "CMItemDesc", Trim(\aCtrlSend[n]\sCSItemDesc), grCtrlSendDef\sCSItemDesc)
              
              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n + "]\nDevType=" + decodeDevType(\aCtrlSend[n]\nDevType) + ", \aCtrlSend[" + n + "]\sRemDevMsgType=" + \aCtrlSend[n]\sRemDevMsgType)
              Select \aCtrlSend[n]\nDevType
                Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_NETWORK_OUT
                  If \aCtrlSend[n]\sRemDevMsgType
                    writeTagWithContent(nFileNo, "RemDevMsgType", \aCtrlSend[n]\sRemDevMsgType)
                    If LCase(Left(\aCtrlSend[n]\sRemDevMsgType, 4)) = "mute"
                      writeTagWithContent(nFileNo, "RemDevMuteAction", decodeMuteAction(\aCtrlSend[n]\nRemDevMuteAction))
                    EndIf
                    If \aCtrlSend[n]\sRemDevValue
                      writeTagWithContent(nFileNo, "RemDevValue", \aCtrlSend[n]\sRemDevValue)
                    EndIf
                    If \aCtrlSend[n]\sRemDevValue2
                      writeTagWithContent(nFileNo, "RemDevValue2", \aCtrlSend[n]\sRemDevValue2)
                    EndIf
                    If LCase(Left(\aCtrlSend[n]\sRemDevMsgType, 4)) <> "mute"
                      If \aCtrlSend[n]\sRemDevLevel
                        writeTagWithContent(nFileNo, "RemDevLevel", \aCtrlSend[n]\sRemDevLevel)
                      EndIf
                    EndIf
                  EndIf
              EndSelect
              
              Select \aCtrlSend[n]\nDevType
                Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
                  If \aCtrlSend[n]\nMSMsgType <> #SCS_MSGTYPE_NONE
                    writeTagWithContent(nFileNo, "MSMsgType", decodeMsgType(\aCtrlSend[n]\nMSMsgType))
                  EndIf
                  
                  Select \aCtrlSend[n]\nMSMsgType
                    Case #SCS_MSGTYPE_SCRIBBLE_STRIP
                      If \aCtrlSend[n]\nMaxScribbleStripItem >= 0
                        ; count non-blank items as we only need to save the non-blank items
                        nSSItemCount = 0
                        For n2 = 0 To \aCtrlSend[n]\nMaxScribbleStripItem
                          If Trim(\aCtrlSend[n]\aScribbleStripItem(n2)\sSSItemName)
                            nSSItemCount + 1
                          EndIf
                        Next n2
                        If nSSItemCount > 0
                          ; at least one non-blank item, so now save the scribble strip for this control send item
                          writeTagWithAttribute(nFileNo, "ScribbleStrip", "SSItemCount", Str(nSSItemCount))
                          ; save the non-blank items
                          For n2 = 0 To \aCtrlSend[n]\nMaxScribbleStripItem
                            If Trim(\aCtrlSend[n]\aScribbleStripItem(n2)\sSSItemName)
                              writeTagWithContentAndAttributes(nFileNo, "SSItem", \aCtrlSend[n]\aScribbleStripItem(n2)\sSSItemName, "SSCategory", \aCtrlSend[n]\aScribbleStripItem(n2)\sSSValType, "SSDataVal", Str(\aCtrlSend[n]\aScribbleStripItem(n2)\nSSDataValue))
                            EndIf
                          Next n2
                          writeUnTag(nFileNo, "ScribbleStrip")
                        EndIf
                      EndIf
                  EndSelect
                  
                  Select \aCtrlSend[n]\nMSMsgType
                    Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF, #SCS_MSGTYPE_MSC, #SCS_MSGTYPE_MMC, #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
                      writeTagIfReqd(nFileNo, "MSChannel", Str(\aCtrlSend[n]\nMSChannel), Str(grSubDef\aCtrlSend[n]\nMSChannel))
                  EndSelect
                  
                  Select \aCtrlSend[n]\nMSMsgType
                    Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF, #SCS_MSGTYPE_MSC, #SCS_MSGTYPE_MMC, #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM ;,
                         ; #SCS_MSGTYPE_MXR_FADER, #SCS_MSGTYPE_MXR_PEQ_IN_OUT, #SCS_MSGTYPE_MXR_PEQ_SETTING
                      ; writeTagIfReqd(nFileNo, "MSParam1", Str(\aCtrlSend[n]\nMSParam1), Str(grSubDef\aCtrlSend[n]\nMSParam1))
                      macWriteTagForNumericOrStringParam("MSParam1", \aCtrlSend[n]\sMSParam1, \aCtrlSend[n]\nMSParam1, grSubDef\aCtrlSend[n]\nMSParam1)
                  EndSelect
                  
                  Select \aCtrlSend[n]\nMSMsgType
                    Case #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF, #SCS_MSGTYPE_MSC, #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM ;, #SCS_MSGTYPE_MXR_PEQ_SETTING
                      ; writeTagIfReqd(nFileNo, "MSParam2", Str(\aCtrlSend[n]\nMSParam2), Str(grSubDef\aCtrlSend[n]\nMSParam2))
                      macWriteTagForNumericOrStringParam("MSParam2", \aCtrlSend[n]\sMSParam2, \aCtrlSend[n]\nMSParam2, grSubDef\aCtrlSend[n]\nMSParam2)
                  EndSelect
                  
                  Select \aCtrlSend[n]\nMSMsgType
                    Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
                      ; writeTagIfReqd(nFileNo, "MSParam3", Str(\aCtrlSend[n]\nMSParam3), Str(grSubDef\aCtrlSend[n]\nMSParam3))
                      ; writeTagIfReqd(nFileNo, "MSParam4", Str(\aCtrlSend[n]\nMSParam4), Str(grSubDef\aCtrlSend[n]\nMSParam4))
                      macWriteTagForNumericOrStringParam("MSParam3", \aCtrlSend[n]\sMSParam3, \aCtrlSend[n]\nMSParam3, grSubDef\aCtrlSend[n]\nMSParam3)
                      macWriteTagForNumericOrStringParam("MSParam4", \aCtrlSend[n]\sMSParam4, \aCtrlSend[n]\nMSParam4, grSubDef\aCtrlSend[n]\nMSParam4)
                      writeTagIfReqd(nFileNo, "MSParam1Info", \aCtrlSend[n]\sMSParam1Info, grSubDef\aCtrlSend[n]\sMSParam1Info)
                      writeTagIfReqd(nFileNo, "MSParam2Info", \aCtrlSend[n]\sMSParam2Info, grSubDef\aCtrlSend[n]\sMSParam2Info)
                      writeTagIfReqd(nFileNo, "MSParam3Info", \aCtrlSend[n]\sMSParam3Info, grSubDef\aCtrlSend[n]\sMSParam3Info)
                      writeTagIfReqd(nFileNo, "MSParam4Info", \aCtrlSend[n]\sMSParam4Info, grSubDef\aCtrlSend[n]\sMSParam4Info)
                  EndSelect
                  
                  If \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_MSC
                    Select \aCtrlSend[n]\nMSParam2
                      Case $1, $2, $3, $5, $B, $10
                        ; commands with q_number, q_list and q_path
                        writeTagIfReqd(nFileNo, "MSQNumber", \aCtrlSend[n]\sMSQNumber, grSubDef\aCtrlSend[n]\sMSQNumber)
                        writeTagIfReqd(nFileNo, "MSQList", \aCtrlSend[n]\sMSQList, grSubDef\aCtrlSend[n]\sMSQList)
                        writeTagIfReqd(nFileNo, "MSQPath", \aCtrlSend[n]\sMSQPath, grSubDef\aCtrlSend[n]\sMSQPath)
                      Case $6
                        ; set command uses q_number and q_list for control number and control value
                        writeTagIfReqd(nFileNo, "MSCtrlNumber", \aCtrlSend[n]\sMSQNumber, grSubDef\aCtrlSend[n]\sMSQNumber)
                        writeTagIfReqd(nFileNo, "MSCtrlValue", \aCtrlSend[n]\sMSQList, grSubDef\aCtrlSend[n]\sMSQList)
                      Case $7
                        ; command with macro number
                        writeTagIfReqd(nFileNo, "MSMacro", Str(\aCtrlSend[n]\nMSMacro), Str(grSubDef\aCtrlSend[n]\nMSMacro))
                      Case $1B, $1C
                        writeTagIfReqd(nFileNo, "MSQList", \aCtrlSend[n]\sMSQList, grSubDef\aCtrlSend[n]\sMSQList)
                      Case $1D, $1E
                        writeTagIfReqd(nFileNo, "MSQPath", \aCtrlSend[n]\sMSQPath, grSubDef\aCtrlSend[n]\sMSQPath)
                      Default
                        ; no extra info or unsupported
                    EndSelect
                    
                  ElseIf \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FREE
                    writeTagWithContent(nFileNo, "MIDIData", \aCtrlSend[n]\sEnteredString)
                    
                  ElseIf \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FILE
                    k = \aCtrlSend[n]\nAudPtr
                    If k >=0
                      writeTag(nFileNo, "MIDIFile")
                      If bRecovery = #False
                        aAud(k)\sStoredFileName = encodeFileName(aAud(k)\sFileName, bCollecting, bTemplate)
                      EndIf
                      If bExport Or bCollecting
                        s2ndStoredFileName = aAud(k)\sStoredFileName
                        If (bExport) And (bCopyFiles)
                          If LCase(GetPathPart(aAud(k)\sFileName)) <> LCase(gs2ndCueFolder)
                            sTmp1 = aAud(k)\sFileName
                            sTmp2 = gs2ndCueFolder + GetFilePart(sTmp1)
                            If FileExists(sTmp2, #False) = #False
                              SetGadgetText(WEX\lblExportStatus, "Copying " + GetFilePart(aAud(k)\sFileName) + "...")
                              CopyFile(sTmp1, sTmp2)
                              SetGadgetText(WEX\lblExportStatus, "")
                            EndIf
                          EndIf
                          s2ndStoredFileName = "$(Cue)\" + GetFilePart(aAud(k)\sFileName)
                        EndIf
                        writeTagWithContent(nFileNo, "FileName", s2ndStoredFileName)
                        
                      Else
                        writeTagWithContent(nFileNo, "FileName", aAud(k)\sStoredFileName)
                        
                      EndIf
                      writeTagIfReqd(nFileNo, "StartAt", Str(aAud(k)\nStartAt), Str(grAudDef\nStartAt))
                      debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nEndAt=" + Str(aAud(k)\nEndAt))
                      writeTagIfReqd(nFileNo, "EndAt", Str(aAud(k)\nEndAt), Str(grAudDef\nEndAt))
                      writeUnTag(nFileNo, "MIDIFile")
                    EndIf
                    
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_RS232_OUT ; #SCS_DEVTYPE_CS_RS232_OUT
                  writeTagWithContent(nFileNo, "RS232EntryMode", decodeEntryMode(\aCtrlSend[n]\nEntryMode))
                  writeTagWithContent(nFileNo, "RS232AddCR", booleanToString(\aCtrlSend[n]\bAddCR))
                  writeTagWithContent(nFileNo, "RS232AddLF", booleanToString(\aCtrlSend[n]\bAddLF))
                  writeTagWithContent(nFileNo, "RS232Data", \aCtrlSend[n]\sEnteredString)
                  
                Case #SCS_DEVTYPE_CS_NETWORK_OUT  ; #SCS_DEVTYPE_CS_NETWORK_OUT
                  If \aCtrlSend[n]\bIsOSC
                    writeTagWithContent(nFileNo, "OSCCmdType", decodeOSCCmdType(\aCtrlSend[n]\nOSCCmdType))
                    If \aCtrlSend[n]\bOSCItemPlaceHolder
                      writeTagWithContent(nFileNo, "OSCItemPlaceHolder", booleanToString(\aCtrlSend[n]\bOSCItemPlaceHolder))
                    ElseIf \aCtrlSend[n]\nRemDevMsgType = 0
                      writeTagIfReqd(nFileNo, "OSCItemNr", Str(\aCtrlSend[n]\nOSCItemNr), Str(grCtrlSendDef\nOSCItemNr))
                      writeTagIfReqd(nFileNo, "OSCItemString", \aCtrlSend[n]\sOSCItemString, grCtrlSendDef\sOSCItemString)
                    EndIf
                    Select \aCtrlSend[n]\nOSCCmdType
                      Case #SCS_CS_OSC_MUTE_FIRST To #SCS_CS_OSC_MUTE_LAST
                        If Len(Trim(\aCtrlSend[n]\sRemDevMsgType)) = 0
                          ; Do not save OSCMuteAction for rem dev message types as "RemDevAction" has already saved this info
                          writeTagWithContent(nFileNo, "OSCMuteAction", decodeMuteAction(\aCtrlSend[n]\nOSCMuteAction))
                        EndIf
                      Case #SCS_CS_OSC_GOSCENE
                        writeTagIfReqd(nFileNo, "OSCReloadNames", booleanToString(\aCtrlSend[n]\bOSCReloadNamesGoScene), booleanToString(grSubDef\aCtrlSend[n]\bOSCReloadNamesGoScene))
                      Case #SCS_CS_OSC_GOSNIPPET
                        writeTagIfReqd(nFileNo, "OSCReloadNamesGoSnippet", booleanToString(\aCtrlSend[n]\bOSCReloadNamesGoSnippet), booleanToString(grSubDef\aCtrlSend[n]\bOSCReloadNamesGoSnippet))
                      Case #SCS_CS_OSC_GOCUE
                        writeTagIfReqd(nFileNo, "OSCReloadNamesGoCue", booleanToString(\aCtrlSend[n]\bOSCReloadNamesGoCue), booleanToString(grSubDef\aCtrlSend[n]\bOSCReloadNamesGoCue))
                      Case #SCS_CS_OSC_FREEFORMAT
                        writeTagWithContent(nFileNo, "OSCData", \aCtrlSend[n]\sEnteredString)
                    EndSelect
                  Else
                    writeTagWithContent(nFileNo, "NetworkEntryMode", decodeEntryMode(\aCtrlSend[n]\nEntryMode))
                    writeTagWithContent(nFileNo, "NetworkAddCR", booleanToString(\aCtrlSend[n]\bAddCR))
                    writeTagWithContent(nFileNo, "NetworkAddLF", booleanToString(\aCtrlSend[n]\bAddLF))
                    writeTagWithContent(nFileNo, "NetworkData", \aCtrlSend[n]\sEnteredString)
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
                  writeTagWithContent(nFileNo, "HTTPData", \aCtrlSend[n]\sEnteredString)
                  
              EndSelect
              
              writeUnTag(nFileNo, "ControlMessage")
            EndIf
          Next n
          ;}
        EndIf
        
        If \bSubTypeQ   ; INFO Saving \bSubTypeQ
          ;{
          writeTagIfReqd(nFileNo, "CallCueAction", decodeCallCueAction(\nCallCueAction), decodeCallCueAction(grSubDef\nCallCueAction))
          Select \nCallCueAction
            Case #SCS_QQ_CALLCUE
              writeTagIfReqd(nFileNo, "CallCue", \sCallCue, grSubDef\sCallCue)
              writeTagIfReqd(nFileNo, "CallCueParams", \sCallCueParams, grSubDef\sCallCueParams)
            Case #SCS_QQ_SELHKBANK
              writeTagIfReqd(nFileNo, "SelHKBank", Str(\nSelHKBank), Str(grSubDef\nSelHKBank))
          EndSelect
          ;}
        EndIf
        
        If \bSubTypeR   ; INFO Saving \bSubTypeR
          ;{
          If \sRPFileName
            writeTagWithContent(nFileNo, "RPFileName", encodeFileName(\sRPFileName, bCollecting, bTemplate))
            writeTagIfReqd(nFileNo, "RPParams", encodeFileName(\sRPParams, #False, bTemplate), "")
            writeTagIfReqd(nFileNo, "RPStartFolder", encodeFileName(\sRPStartFolder, bCollecting, bTemplate), "")
            If \bRPHideSCS
              writeTagWithContent(nFileNo, "RPHide", booleanToString(\bRPHideSCS))
            EndIf
            If \bRPInvisible
              writeTagWithContent(nFileNo, "RPInvisible", booleanToString(\bRPInvisible))
            EndIf
          EndIf
          ;}
        EndIf
        
        If \bSubTypeS   ; INFO Saving \bSubTypeS
          ;{
          nTagIndex = -1
          For h = 0 To #SCS_MAX_SFR
            If (\nSFRAction[h] <> #SCS_SFR_ACT_NA) Or (\nSFRCueType[h] <> #SCS_SFR_CUE_NA)
              nTagIndex + 1
              writeTagWithContent(nFileNo, "SFRAction" + nTagIndex, decodeSFRAction(\nSFRAction[h]))
              Select \nSFRAction[h]
                Case #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_FADEALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
                  ; no cue info
                Default
                  writeTagWithContent(nFileNo, "SFRCueType" + nTagIndex, decodeSFRCueType(\nSFRCueType[h]))
                  If \nSFRCueType[h] = #SCS_SFR_CUE_SEL
                    writeTagWithContent(nFileNo, "SFRCue" + nTagIndex, \sSFRCue[h])
                    writeTagIfReqd(nFileNo, "SFRSubNo" + nTagIndex, Str(\nSFRSubNo[h]), Str(grSubDef\nSFRSubNo[h]))
                    writeTagIfReqd(nFileNo, "SFRLoopNo" + nTagIndex, Str(\nSFRLoopNo[h]), Str(grSubDef\nSFRLoopNo[h]))
                  EndIf
              EndSelect
            EndIf
          Next h
          macWriteTagForNumericOrStringParam("SFRTimeOverride", \sSFRTimeOverride, \nSFRTimeOverride, grSubDef\nSFRTimeOverride)
          ; debugMsg0(sProcName, "\sSFRTimeOverRide=" + \sSFRTimeOverride + ", \nSFRTimeOverRide=" + \nSFRTimeOverride)
          writeTagIfReqd(nFileNo, "SFRCompleteAssocAutoStartCues", booleanToString(\bSFRCompleteAssocAutoStartCues), booleanToString(grSubDef\bSFRCompleteAssocAutoStartCues))
          writeTagIfReqd(nFileNo, "SFRHoldAssocAutoStartCues", booleanToString(\bSFRHoldAssocAutoStartCues), booleanToString(grSubDef\bSFRHoldAssocAutoStartCues))
          If \bSFRGoNext
            writeTagWithContent(nFileNo, "SFRGoNext", booleanToString(\bSFRGoNext))
            writeTagIfReqd(nFileNo, "SFRGoNextDelay", Str(\nSFRGoNextDelay), Str(grSubDef\nSFRGoNextDelay))
          EndIf
          ;}
        EndIf
        
        If \bSubTypeT   ; INFO Saving \bSubTypeT
          ;{
          ; Changed 7Jun2022 11.9.2
          If \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA
            writeTagWithContent(nFileNo, "SetPosCue", \sSetPosCue)
          Else
            writeTagWithContent(nFileNo, "SetPosCueType", decodeSetPosSetPosCueType(\nSetPosCueType))
          EndIf
          writeTagIfReqd(nFileNo, "SetPosAbsRel", decodeSetPosAbsRel(\nSetPosAbsRel), decodeSetPosAbsRel(grSubDef\nSetPosAbsRel))
          Select \nSetPosAbsRel
            Case #SCS_SETPOS_CUE_MARKER
              writeTagWithContent(nFileNo, "SetPosCueMarkerSubNo", Str(\nSetPosCueMarkerSubNo))
              writeTagWithContent(nFileNo, "SetPosCueMarker", \sSetPosCueMarker)
            Default
              writeTagWithContent(nFileNo, "SetPosTime", Str(\nSetPosTime))
          EndSelect
          ;}
        EndIf
        
        If \bSubTypeU   ; INFO Saving \bSubTypeU
          ;{
          writeTagIfReqd(nFileNo, "MTCType", decodeMTCType(\nMTCType), decodeMTCType(grSubDef\nMTCType))
          writeTagWithContent(nFileNo, "MTCStartTime", decodeMTCTime(\nMTCStartTime))
          writeTagWithContent(nFileNo, "MTCFrameRate", decodeMTCFrameRate(\nMTCFrameRate))
          writeTagIfReqd(nFileNo, "MTCPreRoll", Str(\nMTCPreRoll), Str(grSubDef\nMTCPreRoll))
          writeTagIfReqd(nFileNo, "MTCDuration", Str(\nMTCDuration), Str(grSubDef\nMTCDuration))
          ;}
        EndIf
        
        writeUnTag(nFileNo, "Sub")
        j = \nNextSubIndex
      EndWith
    Wend
    
    writeUnTag(nFileNo, "Cue")
    
  Next i
  
  If bRecovery = #False
    
    writeTag(nFileNo, "Files")
    
    For f = 1 To gnLastFileData
      With gaFileData(f)
        sMyStoredFileName = encodeFileName(\sFileName, #False, bTemplate)
        If bCollecting = #False
          \sStoredFileName = sMyStoredFileName
        EndIf
        ; check if this file is (still) used
        \bSaveThisFile = #False
        For k = 1 To gnLastAud
          If aAud(k)\bExists
            If (aAud(k)\sStoredFileName = sMyStoredFileName) And (aAud(k)\bAudPlaceHolder = #False)
              If bExport
                i = aAud(k)\nCueIndex
                If WEX_exportThisCue(i) = #True
                  \bSaveThisFile = #True
                  Break
                EndIf
              Else
                \bSaveThisFile = #True
                Break
              EndIf
            EndIf
          EndIf
        Next k
        ; Added 10Nov2022 11.9.7ad - now check that we haven't already saved "File" info for this \sFileName.
        ; Comment by Mike: I found that duplicate gaFileData array entries can be created in fmMultiCueCopyEtc.pbi, even when deleting a range of cues.
        ; I didn't want to try to prevent these duplicates from being created in gaFileData() because the entries are directly linked to aAud's by \nFileDataPtr.
        ; So I deemed it safer just to prevent the duplicates being saved in the cue file (which doesn't save file data pointers).
        ; The code below checks if the "File" about to be saved has already been saved, and if so then sets \bSaveThisFile = #False to prevent it being saved again.
        If \bSaveThisFile
          sThisFileName = \sFileName
          For f2 = 1 To (f - 1)
            If gaFileData(f2)\sFileName = sThisFileName And gaFileData(f2)\bSaveThisFile
              ; debugMsg(sProcName, "Ignoring saving duplication of " + #DQUOTE$ + sThisFileName + #DQUOTE$)
              \bSaveThisFile = #False
              Break
            EndIf
          Next f2
        EndIf
        ; End added 10Nov2022 11.9.7ad
        If \bSaveThisFile
          writeTag(nFileNo, "File")
          If bExport Or bCollecting
            s2ndStoredFileName = \sStoredFileName
            If (bExport) And (bCopyFiles)
              ; no need to copy as this has already been done
              s2ndStoredFileName = "$(Cue)\" + GetFilePart(\sFileName)
            EndIf
            writeTagWithContent(nFileNo, "FileName", s2ndStoredFileName)
            s2ndFileName = decodeFileName(s2ndStoredFileName, #False, #True, bCollecting)
            If FileExists(s2ndFileName)
              qMyFileSize = FileSize(s2ndFileName)
              sMyFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(s2ndFileName, #PB_Date_Modified))
              writeTagIfReqd(nFileNo, "FileModified", sMyFileModified, grFileDataDef\sFileModified)
              writeTagIfReqd(nFileNo, "FileSize", Str(qMyFileSize), Str(grFileDataDef\qFileSize))
            EndIf
            
          Else
            writeTagWithContent(nFileNo, "FileName", \sStoredFileName)
            If FileExists(\sFileName)
              qMyFileSize = FileSize(\sFileName)
              sMyFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(\sFileName, #PB_Date_Modified))
              writeTagIfReqd(nFileNo, "FileModified", sMyFileModified, grFileDataDef\sFileModified)
              writeTagIfReqd(nFileNo, "FileSize", Str(qMyFileSize), Str(grFileDataDef\qFileSize))
            EndIf
            
          EndIf
          writeTagIfReqd(nFileNo, "FileType", \sFileType, grFileDataDef\sFileType)
          writeTagIfReqd(nFileNo, "FileTitle", \sFileTitle, grFileDataDef\sFileTitle)
          If (\nSourceWidth > 0) And (\nSourceHeight > 0)
            writeTagWithContent(nFileNo, "Dimensions", Str(\nSourceWidth) + "x" + Str(\nSourceHeight))
          EndIf
          writeTagIfReqd(nFileNo, "FileDuration", Str(\nFileDuration), Str(grFileDataDef\nFileDuration))
          writeTagIfReqd(nFileNo, "FileChannels", Str(\nxFileChannels), Str(grFileDataDef\nxFileChannels))
          writeUnTag(nFileNo, "File")
        EndIf ; \bSaveThisFile
      EndWith
    Next f
    
    writeUnTag(nFileNo, "Files")
    
  EndIf ; EndIf bRecovery = #False
  
EndProcedure

Procedure.s unloadProd(nFileNo, bRecovery, bExport, sExportTitle.s, bForceNewProdId, bCollecting=#False, bTemplate=#False)
  PROCNAMEC()
  ; returns sProdId written to the cue file
  Protected d, d1, d2, n, m, bSavePlugins
  Protected n3, nVSTParamPtr
  Protected sProdId.s
  Protected nDevMapDevPtr, nDefaultDMXStartChannel
  Protected nCtrlNetworkRemoteDev
  Protected bSaveScribble, bSaveDelay
  
  If bTemplate
    debugMsg(sProcName, #SCS_START + ", gsTemplatesFolder=" + gsTemplatesFolder + ", gsTemplateFile=" + gsTemplateFile + ", bTemplate=" + strB(bTemplate))
  ElseIf bExport Or bCollecting
    debugMsg(sProcName, #SCS_START + ", gs2ndCueFolder=" + gs2ndCueFolder + ", gs2ndCueFile=" + gs2ndCueFile + ", bExport=" + strB(bExport) + ", bCollecting=" + strB(bCollecting))
  Else
    debugMsg(sProcName, #SCS_START + ", gsCueFolder=" + gsCueFolder + ", gsCueFile=" + gsCueFile + ", bForceNewProdId=" + strB(bForceNewProdId) + ", bExport=" + strB(bExport) + ", bCollecting=" + strB(bCollecting) + ", bTemplate=" + strB(bTemplate))
  EndIf
  
  writeTag(nFileNo, "Head")
  
  With grProd
    If bTemplate
      writeTagWithContent(nFileNo, "TmDesc", \sTmDesc)
    ElseIf bExport
      writeTagWithContent(nFileNo, "Title", sExportTitle)
    Else
      writeTagWithContent(nFileNo, "Title", \sTitle)
    EndIf
    
    If bTemplate = #False
      If bExport Or bForceNewProdId
        sProdId = calcProdId()
      Else
        sProdId = \sProdId
      EndIf
      ; nb sProdId will be returned at the end of this procedure
      If sProdId
        writeTagWithContent(nFileNo, "ProdId", sProdId)
      EndIf
    EndIf
    
    If bTemplate
      writeTagWithContent(nFileNo, "Version", #SCS_FILE_VERSION)
      writeTagWithContent(nFileNo, "Build", Str(grProgVersion\nBuildDate))
    Else
      writeTagWithContent(nFileNo, "Version", #SCS_FILE_VERSION)
      writeTagWithContent(nFileNo, "Build", Str(grProgVersion\nBuildDate))
      gbSCSVersionChanged = #False
    EndIf
    
    ;- save prod audio logical devices
    ;{
    d1 = -1 ; d1 is used to give consecutive numbering of output devices, ignoring 'deleted' devices and devices of a different device type
    d2 = -1 ; d2 = same for MIDI playback
    For d = 0 To \nMaxAudioLogicalDev
      If Len(\aAudioLogicalDevs(d)\sLogicalDev) > 0
        Select \aAudioLogicalDevs(d)\nDevType
          Case #SCS_DEVTYPE_AUDIO_OUTPUT
            d1 + 1
            writeTagWithContent(nFileNo, "PRLogicalDev" + d1, \aAudioLogicalDevs(d)\sLogicalDev)
            writeTagWithContent(nFileNo, "PRNumChans" + d1, Str(\aAudioLogicalDevs(d)\nNrOfOutputChans))
            writeTagIfReqd(nFileNo, "PRAutoIncludeDev" + d1, booleanToString(\aAudioLogicalDevs(d)\bAutoInclude), booleanToString(grAudioLogicalDevsDef\bAutoInclude))
            writeTagIfReqd(nFileNo, "PRAUForLTC" + d1, booleanToString(\aAudioLogicalDevs(d)\bForLTC), booleanToString(grAudioLogicalDevsDef\bForLTC))
            If \aAudioLogicalDevs(d)\sLogicalDev
              writeTagIfReqd(nFileNo, "DfltDBTrim" + d1, \aAudioLogicalDevs(d)\sDfltDBTrim, grAudioLogicalDevsDef\sDfltDBTrim)
              writeTagWithContent(nFileNo, "DfltDBLevel" + d1, unloadDBLevel(\aAudioLogicalDevs(d)\sDfltDBLevel))
              writeTagIfReqd(nFileNo, "DfltPan" + d1, panSingleToString(\aAudioLogicalDevs(d)\fDfltPan), panSingleToString(grAudioLogicalDevsDef\fDfltPan))
            EndIf
            
          Case #SCS_DEVTYPE_MIDI_PLAYBACK
            d2 + 1
            writeTagWithContent(nFileNo, "PRMidiLogicalDev" + d2, \aAudioLogicalDevs(d)\sLogicalDev)
        EndSelect
      EndIf
    Next d
    
    writeTagIfReqd(nFileNo, "TestToneSound", decodeTestToneSound(\nTestSound), decodeTestToneSound(grProdDef\nTestSound)) ; 3May2022pm 11.9.1
    writeTagIfReqd(nFileNo, "TestDBLevel", unloadDBLevel(\sTestToneDBLevel), unloadDBLevel(grProdDef\sTestToneDBLevel))
    writeTagIfReqd(nFileNo, "TestPan", panSingleToString(\fTestTonePan), panSingleToString(grProdDef\fTestTonePan)) ; 4May2022am 11.9.1
    writeTagIfReqd(nFileNo, "OutputDevForTestLiveInput", \sOutputDevForTestLiveInput, grProdDef\sOutputDevForTestLiveInput)
    
    writeTagIfReqd(nFileNo, "PreviewDevice", \sPreviewDevice, grProdDef\sPreviewDevice)
    writeTagIfReqd(nFileNo, "PreviewLevel", formatLevel(\fPreviewBVLevel), formatLevel(grProdDef\fPreviewBVLevel))
    ;}
    ;- save prod video audio devices
    ;{
    d1 = -1
    For d = 0 To \nMaxVidAudLogicalDev
      If \aVidAudLogicalDevs(d)\sVidAudLogicalDev
        d1 + 1
        writeTagWithContent(nFileNo, "PRVidAudLogicalDev" + d1, \aVidAudLogicalDevs(d)\sVidAudLogicalDev)
        writeTagIfReqd(nFileNo, "PRAutoIncludeVidAud" + d1, booleanToString(\aVidAudLogicalDevs(d)\bAutoInclude), booleanToString(grVidAudLogicalDevsDef\bAutoInclude))
        If \aVidAudLogicalDevs(d)\sVidAudLogicalDev
          writeTagIfReqd(nFileNo, "DfltVidAudDBTrim" + d1, \aVidAudLogicalDevs(d)\sDfltDBTrim, grVidAudLogicalDevsDef\sDfltDBTrim)
          writeTagWithContent(nFileNo, "DfltVidAudDBLevel" + d1, unloadDBLevel(\aVidAudLogicalDevs(d)\sDfltDBLevel))
          writeTagIfReqd(nFileNo, "DfltVidAudPan" + d1, panSingleToString(\aVidAudLogicalDevs(d)\fDfltPan), panSingleToString(grVidAudLogicalDevsDef\fDfltPan))
        EndIf
        CompilerIf #c_allow_video_audio_routed_to_audio_device
          writeTagIfReqd(nFileNo, "PRVidAudRouteToAudLogicalDev" + d1, \aVidAudLogicalDevs(d)\sRouteToAudioLogicalDev)
        CompilerEndIf
      EndIf
    Next d
    ;}
    ;- save prod video capture devices
    ;{
    d1 = -1
    For d = 0 To \nMaxVidCapLogicalDev
      If \aVidCapLogicalDevs(d)\sLogicalDev
        d1 + 1
        writeTagWithContent(nFileNo, "PRVidCapLogicalDev" + d1, \aVidCapLogicalDevs(d)\sLogicalDev)
        writeTagIfReqd(nFileNo, "PRAutoIncludeVidCap" + d1, booleanToString(\aVidCapLogicalDevs(d)\bAutoInclude), booleanToString(grVidCapLogicalDevsDef\bAutoInclude))
      EndIf
    Next d
    ;}
    ;- save prod live input devices
    ;{
    d1 = -1
    For d = 0 To \nMaxLiveInputLogicalDev
      If \aLiveInputLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
        If Trim(\aLiveInputLogicalDevs(d)\sLogicalDev)
          d1 + 1
          writeTagWithContent(nFileNo, "PRInputLogicalDev" + d1, \aLiveInputLogicalDevs(d)\sLogicalDev)
          writeTagWithContent(nFileNo, "PRNumInputChans" + d1, Str(\aLiveInputLogicalDevs(d)\nNrOfInputChans))
          writeTagIfReqd(nFileNo, "PRInputForLTC" + d1, booleanToString(\aLiveInputLogicalDevs(d)\bInputForLTC), booleanToString(grLiveInputLogicalDevsDef\bInputForLTC))
        EndIf
      EndIf
    Next d
    ;}
    ;- save prod input groups
    ;{
    For d = 0 To \nMaxInGrp
      If Trim(\aInGrps(d)\sInGrpName)
        writeTag(nFileNo, "PRInGrp")
        writeTagWithContent(nFileNo, "PRInGrpName", \aInGrps(d)\sInGrpName)
        For d2 = 0 To \aInGrps(d)\nMaxInGrpItem
          If \aInGrps(d)\aInGrpItem(d2)\nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT
            If \aInGrps(d)\aInGrpItem(d2)\sInGrpItemLiveInput
              writeTagWithContent(nFileNo, "PRInGrpDev", \aInGrps(d)\aInGrpItem(d2)\sInGrpItemLiveInput)
            EndIf
          EndIf
        Next d2
        writeUnTag(nFileNo, "PRInGrp")
      EndIf
    Next d
    ;}
    ;- save prod fixture types
    ;{
    For d = 0 To \nMaxFixType
      If \aFixTypes(d)\sFixTypeName
        writeTagWithAttribute(nFileNo, "FixType", "FixTypeName", \aFixTypes(d)\sFixTypeName)
        writeTagWithContent(nFileNo, "FixTypeDesc", \aFixTypes(d)\sFixTypeDesc)
        If \aFixTypes(d)\nTotalChans > 0
          writeTagWithContent(nFileNo, "FixTypeTotalChans", Str(\aFixTypes(d)\nTotalChans))
          For n = 0 To (\aFixTypes(d)\nTotalChans - 1)
            If (\aFixTypes(d)\aFixTypeChan(n)\sChannelDesc) Or (\aFixTypes(d)\aFixTypeChan(n)\bDimmerChan) Or
               ((\aFixTypes(d)\aFixTypeChan(n)\sDefault) And (\aFixTypes(d)\aFixTypeChan(n)\sDefault <> grFixTypeChanDef\sDefault))
              writeTagWithAttribute(nFileNo, "FTC", "FTCChannel", Str(\aFixTypes(d)\aFixTypeChan(n)\nChanNo))
              writeTagIfReqd(nFileNo, "FTCDesc", \aFixTypes(d)\aFixTypeChan(n)\sChannelDesc)
              writeTagIfReqd(nFileNo, "FTCDimmerChan", booleanToString(\aFixTypes(d)\aFixTypeChan(n)\bDimmerChan), booleanToString(grFixTypeChanDef\bDimmerChan))
              If \aFixTypes(d)\aFixTypeChan(n)\sDefault ; nb 'default' is 0 (zero), so do not save tag if 0 or blank
                writeTagIfReqd(nFileNo, "FTCDefault", \aFixTypes(d)\aFixTypeChan(n)\sDefault, grFixTypeChanDef\sDefault)
              EndIf
              writeTagIfReqd(nFileNo, "FTCTextColor", Str(\aFixTypes(d)\aFixTypeChan(n)\nDMXTextColor), Str(grFixTypeChanDef\nDMXTextColor))
              writeUnTag(nFileNo, "FTC")
            EndIf
          Next n
        EndIf
        writeUnTag(nFileNo, "FixType")
      EndIf
    Next d
    ;}
    ;- save prod lighting devices
    ;{
    For d = 0 To \nMaxLightingLogicalDev
      If \aLightingLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
        If Trim(\aLightingLogicalDevs(d)\sLogicalDev)
          writeTag(nFileNo, "PRLTDevice")
          writeTagWithContent(nFileNo, "PRLTLogicalDev", \aLightingLogicalDevs(d)\sLogicalDev)
          writeTagWithContent(nFileNo, "PRLTDevType", decodeDevType(\aLightingLogicalDevs(d)\nDevType))
          nDevMapDevPtr = getDevMapDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, d)
          ; debugMsg0(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
          For n = 0 To \aLightingLogicalDevs(d)\nMaxFixture
            If \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode ; Test added 19Sep2021 11.8.6aj following email from Dave Jenkins where there was a blank fixture, and that caused problems as it could not be removed
              writeTag(nFileNo, "PRLTFixture")
              writeTagWithContent(nFileNo, "PRLTFixtureCode", \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode)
              writeTagIfReqd(nFileNo, "PRLTFixtureDesc", \aLightingLogicalDevs(d)\aFixture(n)\sFixtureDesc, "")
              writeTagIfReqd(nFileNo, "PRLTFixtureType", \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName, "")
              ; If \bLightingPre118 ; Test commented out 9Oct2024 11.10.6aj following emails from Octavio Alcober
                writeTagIfReqd(nFileNo, "PRLTFixtureDimmableChannels", Trim(\aLightingLogicalDevs(d)\aFixture(n)\sDimmableChannels), "")
              ; EndIf
              ; Added 9Sep2021 11.8.6ah
              If nDevMapDevPtr >= 0
                nDefaultDMXStartChannel = DMX_getFixtureDMXStartChannel(nDevMapDevPtr, \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode)
                ; debugMsg0(sProcName, "getFixtureDMXStartChannel(" + nDevMapDevPtr + ", " + \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode + ") returned " + nDefaultDMXStartChannel)
                If nDefaultDMXStartChannel > 0
                  writeTagWithContent(nFileNo, "PRLTFixtureDfltStartChan", Str(nDefaultDMXStartChannel))
                EndIf
                ; End added 9Sep2021 11.8.6ah
              EndIf
              writeUnTag(nFileNo, "PRLTFixture")
            EndIf
          Next n
          writeUnTag(nFileNo, "PRLTDevice")
        EndIf
      EndIf
    Next d
    ;}
    ;- save prod control send pre build 20150401 format
    ;{
    d1 = -1
    For d = 0 To \nMaxCtrlSendLogicalDev
      If \aCtrlSendLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
        If Trim(\aCtrlSendLogicalDevs(d)\sLogicalDev)
          d1 + 1
          writeTagWithContent(nFileNo, "PRCtrlSendLogicalDev" + d1, \aCtrlSendLogicalDevs(d)\sLogicalDev)
          writeTagWithContent(nFileNo, "PRCtrlSendDevType" + d1, decodeDevType(\aCtrlSendLogicalDevs(d)\nDevType))
          If \aCtrlSendLogicalDevs(d)\nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
            writeTagIfReqd(nFileNo, "PRCtrlSendForMTC" + d1, booleanToString(\aCtrlSendLogicalDevs(d)\bCtrlMidiForMTC), booleanToString(grCtrlSendLogicalDevsDef\bCtrlMidiForMTC))
          EndIf
        EndIf
      EndIf
    Next d
    ;}
    ;- save prod control send post build 20150401 format
    ;{
    For d = 0 To \nMaxCtrlSendLogicalDev
      If \aCtrlSendLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
        If Trim(\aCtrlSendLogicalDevs(d)\sLogicalDev)
          writeTag(nFileNo, "PRCSDevice")
          writeTagWithContent(nFileNo, "PRCSLogicalDev", \aCtrlSendLogicalDevs(d)\sLogicalDev)
          writeTagWithContent(nFileNo, "PRCSDevType", decodeDevType(\aCtrlSendLogicalDevs(d)\nDevType))
          writeTagIfReqd(nFileNo, "PRCSM2TSkipEarlierCtrlMsgs", booleanToString(\aCtrlSendLogicalDevs(d)\bM2TSkipEarlierCtrlMsgs), booleanToString(grCtrlSendLogicalDevsDef\bM2TSkipEarlierCtrlMsgs))
          Select \aCtrlSendLogicalDevs(d)\nDevType
            Case #SCS_DEVTYPE_LT_DMX_OUT
              
            Case #SCS_DEVTYPE_CS_MIDI_OUT
              writeTagIfReqd(nFileNo, "PRCSMidiRemoteDevCode", \aCtrlSendLogicalDevs(d)\sCtrlMidiRemoteDevCode, grCtrlSendLogicalDevsDef\sCtrlMidiRemoteDevCode)
              writeTagIfReqd(nFileNo, "PRCSMidiChannel", Str(\aCtrlSendLogicalDevs(d)\nCtrlMidiChannel), Str(grCtrlSendLogicalDevsDef\nCtrlMidiChannel))
              writeTagIfReqd(nFileNo, "PRCSMidiForMTC", booleanToString(\aCtrlSendLogicalDevs(d)\bCtrlMidiForMTC), booleanToString(grCtrlSendLogicalDevsDef\bCtrlMidiForMTC))
              
            Case #SCS_DEVTYPE_CS_NETWORK_OUT
              nCtrlNetworkRemoteDev = \aCtrlSendLogicalDevs(d)\nCtrlNetworkRemoteDev
              bSaveScribble = #False : bSaveDelay = #False
              Select nCtrlNetworkRemoteDev
                Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                  bSaveScribble = #True : bSaveDelay = #True
                Default
                  CompilerIf #c_csrd_network_available And 1=2
                    If nCtrlNetworkRemoteDev > #SCS_MAX_CS_NETWORK_REM_DEV
                      For n = 0 To grCSRD\nMaxRemDev
                        If grCSRD\aRemDev(n)\nCSRD_DevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grCSRD\aRemDev(n)\nCSRD_RemDevId = nCtrlNetworkRemoteDev
                          If grCSRD\aRemDev(n)\sCSRD_GetSSNames : bSaveScribble = #True : EndIf
                          If grCSRD\aRemDev(n)\sCSRD_DelayBeforeReloadNames : bSaveDelay = #True : EndIf
                          Break
                        EndIf
                      Next n
                    EndIf
                  CompilerEndIf
              EndSelect
              writeTagIfReqd(nFileNo, "PRCSNetworkRemoteDev", decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev), decodeCtrlNetworkRemoteDev(grCtrlSendLogicalDevsDef\nCtrlNetworkRemoteDev))
              writeTagIfReqd(nFileNo, "PRCSNetworkRemoteDevPW", \aCtrlSendLogicalDevs(d)\sCtrlNetworkRemoteDevPassword, grCtrlSendLogicalDevsDef\sCtrlNetworkRemoteDevPassword)
              Select nCtrlNetworkRemoteDev
                Case #SCS_CS_NETWORK_REM_OSC_OTHER ; nb may add others
                  writeTagIfReqd(nFileNo, "PRCSNetworkOSCVersion", decodeOSCVersion(\aCtrlSendLogicalDevs(d)\nOSCVersion), decodeOSCVersion(grCtrlSendLogicalDevsDef\nOSCVersion))
              EndSelect
              writeTagWithContent(nFileNo, "PRCSNetworkProtocol", decodeNetworkProtocol(\aCtrlSendLogicalDevs(d)\nNetworkProtocol))
              writeTagWithContent(nFileNo, "PRCSNetworkRole", decodeNetworkRole(\aCtrlSendLogicalDevs(d)\nNetworkRole))
              If \aCtrlSendLogicalDevs(d)\nNetworkRole <> #SCS_ROLE_DUMMY
                writeTagIfReqd(nFileNo, "PRCSConnectWhenReqd", booleanToString(\aCtrlSendLogicalDevs(d)\bConnectWhenReqd), booleanToString(grCtrlSendLogicalDevsDef\bConnectWhenReqd))
              EndIf
              debugMsg(sProcName, "\aCtrlSendLogicalDevs(" + d + ")\nMaxMsgResponse=" + \aCtrlSendLogicalDevs(d)\nMaxMsgResponse)
              For n = 0 To \aCtrlSendLogicalDevs(d)\nMaxMsgResponse
                If \aCtrlSendLogicalDevs(d)\aMsgResponse[n]\sReceiveMsg
                  writeTag(nFileNo, "PRCSNetworkMsgResponse")
                  writeTagWithContent(nFileNo, "PRCSNetworkReceiveMsg", \aCtrlSendLogicalDevs(d)\aMsgResponse[n]\sReceiveMsg)
                  writeTagWithContent(nFileNo, "PRCSNetworkMsgAction", decodeNetworkMsgAction(\aCtrlSendLogicalDevs(d)\aMsgResponse[n]\nMsgAction))
                  If \aCtrlSendLogicalDevs(d)\aMsgResponse[n]\nMsgAction = #SCS_NETWORK_ACT_REPLY
                    writeTagWithContent(nFileNo, "PRCSNetworkReplyMsg", \aCtrlSendLogicalDevs(d)\aMsgResponse[n]\sReplyMsg)
                  EndIf
                  writeUnTag(nFileNo, "PRCSNetworkMsgResponse")
                EndIf
              Next n
              writeTagWithContent(nFileNo, "PRCSNetworkReplyMsgAddCR", booleanToString(\aCtrlSendLogicalDevs(d)\bReplyMsgAddCR))
              writeTagWithContent(nFileNo, "PRCSNetworkReplyMsgAddLF", booleanToString(\aCtrlSendLogicalDevs(d)\bReplyMsgAddLF))
              If bSaveScribble
                writeTagIfReqd(nFileNo, "PRCSGetRemDevScribbleStripNames", booleanToString(\aCtrlSendLogicalDevs(d)\bGetRemDevScribbleStripNames), booleanToString(grCtrlSendLogicalDevsDef\bGetRemDevScribbleStripNames)) ; Added 7May2024 11.10.2cn
              EndIf
              If bSaveDelay
                writeTagWithContent(nFileNo, "PRCSDelayBeforeReloadNames", Str(\aCtrlSendLogicalDevs(d)\nDelayBeforeReloadNames))
              EndIf
              
            Case #SCS_DEVTYPE_CS_RS232_OUT
              writeTagWithContent(nFileNo, "PRCSRS232DataBits", Str(\aCtrlSendLogicalDevs(d)\nRS232DataBits))
              writeTagWithContent(nFileNo, "PRCSRS232StopBits", StrF(\aCtrlSendLogicalDevs(d)\fRS232StopBits,1))
              writeTagWithContent(nFileNo, "PRCSRS232BaudRate", Str(\aCtrlSendLogicalDevs(d)\nRS232BaudRate))
              writeTagWithContent(nFileNo, "PRCSRS232Parity", decodeParity(\aCtrlSendLogicalDevs(d)\nRS232Parity))
              writeTagIfReqd(nFileNo, "PRCSRS232Handshaking", decodeHandshaking(\aCtrlSendLogicalDevs(d)\nRS232Handshaking), decodeHandshaking(grCtrlSendLogicalDevsDef\nRS232Handshaking))
              writeTagIfReqd(nFileNo, "PRCSRS232RTSEnable", Str(\aCtrlSendLogicalDevs(d)\nRS232RTSEnable), Str(grCtrlSendLogicalDevsDef\nRS232RTSEnable))
              writeTagIfReqd(nFileNo, "PRCSRS232DTREnable", Str(\aCtrlSendLogicalDevs(d)\nRS232DTREnable), Str(grCtrlSendLogicalDevsDef\nRS232DTREnable))
              
            Case #SCS_DEVTYPE_CS_HTTP_REQUEST
              writeTagIfReqd(nFileNo, "PRCSHTTPStart", \aCtrlSendLogicalDevs(d)\sHTTPStart, grCtrlSendLogicalDevsDef\sHTTPStart)
              
          EndSelect
          writeUnTag(nFileNo, "PRCSDevice")
        EndIf
      EndIf
    Next d
    ;}
    ;- save prod cue control post build 20150401 format
    ;{
    For d = 0 To \nMaxCueCtrlLogicalDev
      If \aCueCtrlLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
        If Trim(\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev)
          writeTag(nFileNo, "PRCCDevice")
          writeTagWithContent(nFileNo, "PRCCDevType", decodeDevType(\aCueCtrlLogicalDevs(d)\nDevType))
          Select \aCueCtrlLogicalDevs(d)\nDevType
            Case #SCS_DEVTYPE_CC_DMX_IN
              writeTagWithContent(nFileNo, "PRCCDMXPref", decodeDMXPref(\aCueCtrlLogicalDevs(d)\nDMXInPref))
              writeTagWithContent(nFileNo, "PRCCDMXTrgCtrl", decodeDMXTrgCtrl(\aCueCtrlLogicalDevs(d)\nDMXTrgCtrl))
              writeTagWithContent(nFileNo, "PRCCDMXTrgValue", Str(\aCueCtrlLogicalDevs(d)\nDMXTrgValue))
              For n3 = 0 To #SCS_MAX_DMX_COMMAND
                If \aCueCtrlLogicalDevs(d)\aDMXCommand[n3]\nChannel >= 0
                  writeTag(nFileNo, "PRCCDMXCommand")
                  writeTagWithContent(nFileNo, "PRCCDMXCmdType", decodeDMXCommand(n3))
                  writeTagWithContent(nFileNo, "PRCCDMXCmdChannel", Str(\aCueCtrlLogicalDevs(d)\aDMXCommand[n3]\nChannel))
                  writeUnTag(nFileNo, "PRCCDMXCommand")
                EndIf
              Next n3
              
            Case #SCS_DEVTYPE_CC_MIDI_IN
              writeTagWithContent(nFileNo, "PRCCMidiCtrlMethod", decodeCtrlMethod(\aCueCtrlLogicalDevs(d)\nCtrlMethod))
              Select \aCueCtrlLogicalDevs(d)\nCtrlMethod
                Case #SCS_CTRLMETHOD_MTC
                  ; nothing else to save
                Case #SCS_CTRLMETHOD_MSC
                  writeTagWithContent(nFileNo, "PRCCMidiDevId", Str(\aCueCtrlLogicalDevs(d)\nMscMmcMidiDevId))
                  writeTagWithContent(nFileNo, "PRCCMidiMSCCmdFormat", Str(\aCueCtrlLogicalDevs(d)\nMscCommandFormat))
                  If \aCueCtrlLogicalDevs(d)\nGoMacro > 0
                    writeTagWithContent(nFileNo, "PRCCMidiGoMacro", Str(\aCueCtrlLogicalDevs(d)\nGoMacro))
                  EndIf
                Case #SCS_CTRLMETHOD_MMC
                  writeTagWithContent(nFileNo, "PRCCMidiDevId", Str(\aCueCtrlLogicalDevs(d)\nMscMmcMidiDevId))
                  ; Added 16Nov2020 11.8.3.3ah
                  If \aCueCtrlLogicalDevs(d)\bMMCApplyFadeForStop
                    writeTagWithContent(nFileNo, "PRCCMMCApplyFadeForStop", booleanToString(\aCueCtrlLogicalDevs(d)\bMMCApplyFadeForStop))
                  EndIf
                  ; End added 16Nov2020 11.8.3.3ah
                Default
                  writeTagWithContent(nFileNo, "PRCCMidiChannel", Str(\aCueCtrlLogicalDevs(d)\nMidiChannel))
                  For n3 = 0 To #SCS_MAX_MIDI_COMMAND
                    If \aCueCtrlLogicalDevs(d)\aMidiCommand[n3]\nCmd > 0
                      writeTag(nFileNo, "PRCCMidiCommand")
                      writeTagWithContent(nFileNo, "PRCCMidiCmdType", decodeMidiCommand(n3))
                      writeTagWithContent(nFileNo, "PRCCMidiCmd", Str(\aCueCtrlLogicalDevs(d)\aMidiCommand[n3]\nCmd))  ; 8 = Note Off, 9 = Note On, 15 = Pitch Bend, etc
                      writeTagIfReqd(nFileNo, "PRCCMidiCC", Str(\aCueCtrlLogicalDevs(d)\aMidiCommand[n3]\nCC), Str(grCueCtrlLogicalDevsDef\aMidiCommand[n3]\nCC))
                      writeTagIfReqd(nFileNo, "PRCCMidiVV", Str(\aCueCtrlLogicalDevs(d)\aMidiCommand[n3]\nVV), Str(grCueCtrlLogicalDevsDef\aMidiCommand[n3]\nVV))
                      writeUnTag(nFileNo, "PRCCMidiCommand")
                    EndIf
                  Next n3
              EndSelect
              
            Case #SCS_DEVTYPE_CC_NETWORK_IN
              writeTagIfReqd(nFileNo, "PRCCNetworkRemoteDev", decodeCueNetworkRemoteDev(\aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev), decodeCueNetworkRemoteDev(grCueCtrlLogicalDevsDef\nCueNetworkRemoteDev))
              writeTagIfReqd(nFileNo, "PRCCNetworkProtocol", decodeNetworkProtocol(\aCueCtrlLogicalDevs(d)\nNetworkProtocol), decodeNetworkProtocol(grCueCtrlLogicalDevsDef\nNetworkProtocol))
              writeTagWithContent(nFileNo, "PRCCNetworkRole", decodeNetworkRole(\aCueCtrlLogicalDevs(d)\nNetworkRole))
              Select \aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev
                Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
                  For n3 = 0 To #SCS_MAX_X32_COMMAND
                    If \aCueCtrlLogicalDevs(d)\aX32Command[n3]\nX32Button > 0
                      writeTag(nFileNo, "PRCCX32Command")
                      writeTagWithContent(nFileNo, "PRCCX32CmdType", decodeX32Command(n3))
                      writeTagWithContent(nFileNo, "PRCCX32Btn", Str(\aCueCtrlLogicalDevs(d)\aX32Command[n3]\nX32Button))
                      writeUnTag(nFileNo, "PRCCX32Command")
                    EndIf
                  Next n3
                Default
                  writeTagIfReqd(nFileNo, "PRCCNetworkMsgFormat", decodeNetworkMsgFormat(\aCueCtrlLogicalDevs(d)\nNetworkMsgFormat), decodeNetworkMsgFormat(grCueCtrlLogicalDevsDef\nNetworkMsgFormat))
              EndSelect
              
            Case #SCS_DEVTYPE_CC_RS232_IN
              writeTagWithContent(nFileNo, "PRCCRS232DataBits", Str(\aCueCtrlLogicalDevs(d)\nRS232DataBits))
              writeTagWithContent(nFileNo, "PRCCRS232StopBits", StrF(\aCueCtrlLogicalDevs(d)\fRS232StopBits,1))
              writeTagWithContent(nFileNo, "PRCCRS232BaudRate", Str(\aCueCtrlLogicalDevs(d)\nRS232BaudRate))
              writeTagWithContent(nFileNo, "PRCCRS232Parity", decodeParity(\aCueCtrlLogicalDevs(d)\nRS232Parity))
              writeTagIfReqd(nFileNo, "PRCCRS232Handshaking", decodeHandshaking(\aCueCtrlLogicalDevs(d)\nRS232Handshaking), decodeHandshaking(grCueCtrlLogicalDevsDef\nRS232Handshaking))
              writeTagIfReqd(nFileNo, "PRCCRS232RTSEnable", Str(\aCueCtrlLogicalDevs(d)\nRS232RTSEnable), Str(grCueCtrlLogicalDevsDef\nRS232RTSEnable))
              writeTagIfReqd(nFileNo, "PRCCRS232DTREnable", Str(\aCueCtrlLogicalDevs(d)\nRS232DTREnable), Str(grCueCtrlLogicalDevsDef\nRS232DTREnable))
              
          EndSelect
          writeUnTag(nFileNo, "PRCCDevice")
        EndIf
      EndIf
    Next d
    ;}
    writeTagIfReqd(nFileNo, "CueLabelIncrement", Str(\nCueLabelIncrement), Str(grProdDef\nCueLabelIncrement))
    writeTagIfReqd(nFileNo, "LabelsFrozen", booleanToString(\bLabelsFrozen), booleanToString(grProdDef\bLabelsFrozen))
    writeTagIfReqd(nFileNo, "LabelsUCase", booleanToString(\bLabelsUCase), booleanToString(grProdDef\bLabelsUCase))
    writeTagIfReqd(nFileNo, "EnableMidiCue", booleanToString(\bEnableMidiCue), booleanToString(grProdDef\bEnableMidiCue))
    
    writeTagIfReqd(nFileNo, "DefChaseSpeed", Str(\nDefChaseSpeed), Str(grProdDef\nDefChaseSpeed))
    writeTagIfReqd(nFileNo, "DefDMXFadeTime", Str(\nDefDMXFadeTime), Str(grProdDef\nDefDMXFadeTime))
    writeTagIfReqd(nFileNo, "DefFadeInTime", Str(\nDefFadeInTime), Str(grProdDef\nDefFadeInTime))
    writeTagIfReqd(nFileNo, "DefFadeInTimeI", Str(\nDefFadeInTimeI), Str(grProdDef\nDefFadeInTimeI))
    writeTagIfReqd(nFileNo, "DefFadeOutTime", Str(\nDefFadeOutTime), Str(grProdDef\nDefFadeOutTime))
    writeTagIfReqd(nFileNo, "DefFadeOutTimeI", Str(\nDefFadeOutTimeI), Str(grProdDef\nDefFadeOutTimeI))
    writeTagIfReqd(nFileNo, "DefLoopXFadeTime", Str(\nDefLoopXFadeTime), Str(grProdDef\nDefLoopXFadeTime))
    writeTagIfReqd(nFileNo, "DefSFRTimeOverride", Str(\nDefSFRTimeOverride), Str(grProdDef\nDefSFRTimeOverride))
    
    ; Added 5Feb2025 11.10.7aa for Video/Image sub-cues
    writeTagIfReqd(nFileNo, "DefFadeInTimeA", Str(\nDefFadeInTimeA), Str(grProdDef\nDefFadeInTimeA))
    writeTagIfReqd(nFileNo, "DefFadeOutTimeA", Str(\nDefFadeOutTimeA), Str(grProdDef\nDefFadeOutTimeA))
    writeTagIfReqd(nFileNo, "DefDisplayTimeA", Str(\nDefDisplayTimeA), Str(grProdDef\nDefDisplayTimeA))
    writeTagIfReqd(nFileNo, "DefRepeatA", booleanToString(\bDefRepeatA), booleanToString(grProdDef\bDefRepeatA))
    writeTagIfReqd(nFileNo, "DefPauseAtEndA", booleanToString(\bDefPauseAtEndA), booleanToString(grProdDef\bDefPauseAtEndA))
    ; End added 5Feb2025 11.10.7aa for Video/Image sub-cues
    writeTagIfReqd(nFileNo, "DefOutputScreen", Str(\nDefOutputScreen), Str(grProdDef\nDefOutputScreen))
    
    writeTagIfReqd(nFileNo, "PreLoadNextManualOnly", booleanToString(\bPreLoadNextManualOnly), booleanToString(grProdDef\bPreLoadNextManualOnly))
    writeTagIfReqd(nFileNo, "NoPreLoadVideoHotkeys", booleanToString(\bNoPreLoadVideoHotkeys), booleanToString(grProdDef\bNoPreLoadVideoHotkeys))
    writeTagIfReqd(nFileNo, "StopAllInclHib", booleanToString(\bStopAllInclHib), booleanToString(grProdDef\bStopAllInclHib))
    writeTagIfReqd(nFileNo, "AllowHKeyClick", booleanToString(\bAllowHKeyClick), booleanToString(grProdDef\bAllowHKeyClick))
    writeTagIfReqd(nFileNo, "DoNotCalcCueStartValues", booleanToString(\bDoNotCalcCueStartValues), booleanToString(grProdDef\bDoNotCalcCueStartValues))
    
    writeTagIfReqd(nFileNo, "VisualWarning", Str(\nVisualWarningTime), Str(grProdDef\nVisualWarningTime))
    writeTagIfReqd(nFileNo, "VisualWarningFormat", Str(\nVisualWarningFormat), Str(grProdDef\nVisualWarningFormat))
    writeTagIfReqd(nFileNo, "RunMode", decodeRunMode(\nRunMode), decodeRunMode(grProdDef\nRunMode))
    writeTagIfReqd(nFileNo, "MaxDBLevel", Str(\nMaxDBLevel), Str(grProdDef\nMaxDBLevel)) ; numeric only, 0 or 12, ie 0dB or +12dB
    writeTagIfReqd(nFileNo, "MinDBLevel", Str(\nMinDBLevel), Str(grProdDef\nMinDBLevel)) ; signed numeric only, -75, -120 or -160, ie -75dB, -120dB or -160dB
    writeTagIfReqd(nFileNo, "MasterDBVolume", unloadDBLevel(\sMasterDBVol), unloadDBLevel(grProdDef\sMasterDBVol))
    writeTagIfReqd(nFileNo, "DMXMasterFader", Str(\nDMXMasterFaderValue), Str(grProdDef\nDMXMasterFaderValue))
    writeTagIfReqd(nFileNo, "DBLevelChangeIncrement", unloadDBLevel(\sDBLevelChangeIncrement), unloadDBLevel(grProdDef\sDBLevelChangeIncrement))
    writeTagIfReqd(nFileNo, "GridClickAction", decodeGridClickAction(\nGridClickAction), decodeGridClickAction(grProdDef\nGridClickAction))
    writeTagIfReqd(nFileNo, "LostFocusAction", decodeLostFocusAction(\nLostFocusAction), decodeLostFocusAction(grProdDef\nLostFocusAction))
    
    m = 0
    For n = 0 To #SCS_MAX_TIME_PROFILE
      If Len(\sTimeProfile[n]) > 0
        writeTagIfReqd(nFileNo, "TimeProfile" + m, \sTimeProfile[n], grProdDef\sTimeProfile[n])
        m + 1
      EndIf
    Next n
    writeTagIfReqd(nFileNo, "DefaultTimeProfile", \sDefaultTimeProfile, grProdDef\sDefaultTimeProfile)
    For n = 0 To 6
      writeTagIfReqd(nFileNo, "DefaultTimeProfileForDay" + n, \sDefaultTimeProfileForDay[n], grProdDef\sDefaultTimeProfileForDay[n])
    Next n
    writeTagIfReqd(nFileNo, "ResetTOD", Str(\nResetTOD), Str(grProdDef\nResetTOD))
    
    writeTagWithContent(nFileNo, "FocusPoint", decodeFocusPoint(\nFocusPoint))
    
    writeTagIfReqd(nFileNo, "PRTapAllowed", booleanToString(\bTapAllowed), booleanToString(grProdDef\bTapAllowed))
    writeTagIfReqd(nFileNo, "PRTapShortcut", \sTapShortcutStr, grProdDef\sTapShortcutStr)

    writeTagIfReqd(nFileNo, "ProdTimerSaveHist", booleanToString(\bSaveProdTimerHistory), booleanToString(grProdDef\bSaveProdTimerHistory))
    writeTagIfReqd(nFileNo, "ProdTimerTimeStampHist", booleanToString(\bTimeStampProdTimerHistoryFiles), booleanToString(grProdDef\bTimeStampProdTimerHistoryFiles))
    
    writeTagIfReqd(nFileNo, "PRMemoDispOptForPrim", decodeMemoDispOptForPrim(\nMemoDispOptForPrim), decodeMemoDispOptForPrim(grProdDef\nMemoDispOptForPrim))
    
  EndWith
  ;- save VST plugins
  ;{
  For n = 0 To grVST\nMaxLibVSTPlugin
    If grVST\aLibVSTPlugin(n)\sLibVSTPluginName
      bSavePlugins = #True
      Break
    EndIf
  Next n
  If bSavePlugins
    writeTag(nFileNo, "PRVSTPlugins")
    ; save VST library tags
    For n = 0 To grVST\nMaxLibVSTPlugin
      If grVST\aLibVSTPlugin(n)\sLibVSTPluginName
        writeTagWithContentAndAttributes(nFileNo, "PRVSTPlugin", "", "Name", grVST\aLibVSTPlugin(n)\sLibVSTPluginName)
      EndIf
    Next n
    ; save VST device tags
    For n = 0 To grVST\nMaxDevVSTPlugin
      If grVST\aDevVSTPlugin(n)\sDevVSTPluginName
        With grVST\aDevVSTPlugin(n)
          debugMsg(sProcName, "grVST\aDevVSTPlugin(" + n + ")\sDevVSTLogicalDev=" + \sDevVSTLogicalDev + ", \sDevVSTPluginName=" + \sDevVSTPluginName +
                              ", \rDevVSTChunk\nByteSize=" + \rDevVSTChunk\nByteSize + #CRLF$ + ", \rDevVSTChunk\sChunkData=" + \rDevVSTChunk\sChunkData + #CRLF$ + ", \rDevVSTChunk\sChunkMagic=" + \rDevVSTChunk\sChunkMagic)
          writeTagWithAttribute(nFileNo, "PRDevVST", "Name", \sDevVSTPluginName)
          writeTagWithContent(nFileNo, "PRDevVSTDevice", \sDevVSTLogicalDev)
          writeTagWithContent(nFileNo, "PRDevVSTOrder", Str(\nDevVSTOrder))
          writeTagIfReqd(nFileNo, "PRDevVSTComment", \sDevVSTComment)
          ; chunk
          If \rDevVSTChunk\nByteSize > 0
            writeTagWithContentAndAttributes(nFileNo, "PRDevVSTChunkMagic", \rDevVSTChunk\sChunkMagic, "ByteSize", Str(\rDevVSTChunk\nByteSize))
            writeTagWithContent(nFileNo, "PRDevVSTChunkData", \rDevVSTChunk\sChunkData)
          EndIf
          ; program
          If \nDevVSTProgram >= 0               
            writeTagWithContent(nFileNo, "PRDevVSTProgram", Str(\nDevVSTProgram))                
          EndIf
          ; parameters
          For nVSTParamPtr = 0 To \nDevVSTMaxParam
            If \aDevVSTParam(nVSTParamPtr)\fVSTParamValue <> \aDevVSTParam(nVSTParamPtr)\fVSTParamDefaultValue
              writeTagWithContentAndAttributes(nFileNo, "PRDevVSTParam", StrF(\aDevVSTParam(nVSTParamPtr)\fVSTParamValue), "Index", Str(\aDevVSTParam(nVSTParamPtr)\nVSTParamIndex))
            EndIf
          Next nVSTParamPtr
          ; bypass
          writeTagIfReqd(nFileNo, "PRDevVSTBypass", booleanToString(\bDevVSTBypass), booleanToString(#False))
          writeUnTag(nFileNo, "PRDevVST")
        EndWith
      EndIf ; EndIf grVST\aDevVSTPlugin(n)\sDevVSTPluginName
    Next n
    ; end of tags for PRVSTPlugins
    writeUnTag(nFileNo, "PRVSTPlugins")
  EndIf ; EndIf bSavePlugins
  ;}
  
  writeUnTag(nFileNo, "Head")
  
  debugMsg(sProcName, #SCS_END + ", returning sProdId=" + sProdId)
  ProcedureReturn sProdId
  
EndProcedure

Procedure unloadCtrlSetup(nFileNo)
  PROCNAMEC()
  Protected d, d1, d2, n, m
  
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    With grCtrlSetup
      If \nController <> #SCS_CTRL_MIDI_CUE_CONTROL
        If \nController <> #SCS_CTRL_NONE ; Test added 9Oct2024 11.10.6aj to prevent writing an unncessary <CtrlSetup> ... NONE ... entry in the cue file
          writeTag(nFileNo, "CtrlSetup")
          writeTagWithContent(nFileNo, "Controller", decodeController(\nController))
          If \nCtrlConfig > 0
            writeTagWithContent(nFileNo, "CtrlConfig", decodeCtrlConfig(\nCtrlConfig))
            writeTagIfReqd(nFileNo, "CtrlIncludeGoEtc", booleanToString(\bIncludeGoEtc), booleanToString(#False))
          EndIf
          writeTagIfReqd(nFileNo, "CtrlMidiIn", \sCtrlMidiInPort, "")
          writeTagIfReqd(nFileNo, "CtrlMidiOut", \sCtrlMidiOutPort, "")
          writeUnTag(nFileNo, "CtrlSetup")
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure writeXMLHeader(nFileNo)
  ; PROCNAMEC()
  Protected sLine.s
  
  sLine = "<?xml version='1.0' encoding='UTF-8'?>"
  WriteStringN(nFileNo, ReplaceString(sLine, "'", #DQUOTE$), gnWriteStringFormat)    ; writes <?xml version="1.0" encoding="UTF-8"?>
  gnTagLevel = -1
  
EndProcedure

Procedure writeTag(nFileNo, sTag.s)
  ; PROCNAMEC()
  Protected sLine.s

  gnTagLevel + 1
  If gnTagLevel > 0
    sLine = Space(gnTagLevel * 3)
  EndIf
  sLine + "<" + sTag + ">"
  WriteStringN(nFileNo, sLine, gnWriteStringFormat)
EndProcedure

Procedure writeTagWithAttribute(nFileNo, sTag.s, sAttributeName.s, sAttributeValue.s)
  ; PROCNAMEC()
  Protected sLine.s

  gnTagLevel + 1
  If gnTagLevel > 0
    sLine = Space(gnTagLevel * 3)
  EndIf
  sLine + "<" + sTag + " " + sAttributeName + "=" + #DQUOTE$ + XMLEncode(sAttributeValue) + #DQUOTE$ + ">" ; eg <FixtureType Code="MAC350">
  WriteStringN(nFileNo, sLine, gnWriteStringFormat)
EndProcedure

Procedure writeTagWithContent(nFileNo, sTag.s, sContent.s)
  ; PROCNAMEC()
  Protected sLine.s

  gnTagLevel + 1
  If gnTagLevel > 0
    sLine = Space(gnTagLevel * 3)
  EndIf
  sLine + "<" + sTag + ">" + XMLEncode(sContent) + "</" + sTag + ">"

  WriteStringN(nFileNo, sLine)
  gnTagLevel - 1

EndProcedure

Procedure writeTagWithContentAndAttributes(nFileNo, sTag.s, sContent.s, sAttributeName1.s, sAttributeValue1.s, sAttributeName2.s="", sAttributeValue2.s="")
  ; PROCNAMEC()
  Protected sLine.s

  gnTagLevel + 1
  If gnTagLevel > 0
    sLine = Space(gnTagLevel * 3)
  EndIf
  sLine + "<" + sTag
  If sAttributeName1
    sLine + " " + sAttributeName1 + "=" + #DQUOTE$ + XMLEncode(sAttributeValue1) + #DQUOTE$
  EndIf
  If sAttributeName2
    sLine + " " + sAttributeName2 + "=" + #DQUOTE$ + XMLEncode(sAttributeValue2) + #DQUOTE$
  EndIf
  sLine + ">" + XMLEncode(sContent)
  sLine + "</" + sTag + ">"

  WriteStringN(nFileNo, sLine)
  gnTagLevel - 1

EndProcedure

Procedure writeTagIfReqd(nFileNo, sTag.s, sValue.s, sDefault.s="")
  ; PROCNAMEC()
  If Trim(sValue) <> Trim(sDefault)
    writeTagWithContent(nFileNo, sTag, Trim(sValue))
  EndIf
EndProcedure

Procedure writeUnTag(nFileNo, sTag.s)
  ; PROCNAMEC()
  Protected sLine.s

  If gnTagLevel > 0
    sLine = Space(gnTagLevel * 3)
  EndIf
  sLine = sLine + "</" + sTag + ">"
  WriteStringN(nFileNo, sLine)
  gnTagLevel - 1
EndProcedure

Procedure.s XMLDecode(sXMLString.s)
  ; PROCNAMEC()
  Protected sOutput.s, sMyChar.s
  Protected n

  If FindString(sXMLString, "&") = 0
    ProcedureReturn sXMLString
  EndIf

  n = 1
  While n <= Len(sXMLString)
    sMyChar = Mid(sXMLString, n, 1)
    If sMyChar = "&"
      If LCase(Mid(sXMLString, n, 4)) = "&lt;"
        sOutput + "<"
        n + 4
      ElseIf LCase(Mid(sXMLString, n, 4)) = "&gt;"
        sOutput + ">"
        n + 4
      ElseIf LCase(Mid(sXMLString, n, 5)) = "&amp;"
        sOutput + "&"
        n + 5
      ElseIf LCase(Mid(sXMLString, n, 6)) = "&apos;"
        sOutput + "'"
        n + 6
      ElseIf LCase(Mid(sXMLString, n, 6)) = "&quot;"
        sOutput + Chr(34)
        n + 6
      ElseIf LCase(Mid(sXMLString, n, 5)) = LCase("&#xD;")
        sOutput + #CR$
        n + 5
      ElseIf LCase(Mid(sXMLString, n, 5)) = LCase("&#xA;")
        sOutput + #LF$
        n + 5
      Else
        sOutput + sMyChar
        n + 1
      EndIf
      
    Else
      sOutput + sMyChar
      n + 1
    EndIf
  Wend
  ProcedureReturn sOutput

EndProcedure

Procedure.s XMLEncode(sXMLString.s)
  Protected sOutput.s, sMyChar.s
  Protected n

  For n = 1 To Len(sXMLString)
    sMyChar = Mid(sXMLString, n, 1)
    Select sMyChar
      Case "<"
        sMyChar = "&lt;"
        
      Case ">"
        sMyChar = "&gt;"
        
      Case "&"
        sMyChar = "&amp;"
        
      Case "'"
        sMyChar = "&apos;"
        
      Case Chr(34)
        sMyChar = "&quot;"
        
      Case #CR$
        sMyChar = "&#xD;"
        
      Case #LF$
        sMyChar = "&#xA;"
        
    EndSelect
    sOutput + sMyChar
  Next n
  ProcedureReturn sOutput
EndProcedure

Procedure askForVersion(bPrimaryFile)
  PROCNAMEC()
  Protected sTmp.s, sMsg.s, bAsk, bFormatOK, n, bRangeOK
  Protected bModalDisplayed

  bAsk = #True
  bFormatOK = #True
  bRangeOK = #True
  bModalDisplayed = gbModalDisplayed
  gbModalDisplayed = #True
  ensureSplashNotOnTop()
  
  While bAsk
    If bFormatOK = #False
      sMsg = "Format of version number (" + sTmp + ") is incorrect." + #CRLF$ + #CRLF$
    ElseIf bRangeOK = #False
      sMsg = "Version number (" + sTmp + ") is out of range." + #CRLF$ + #CRLF$
    EndIf
    sTmp = Trim(InputRequester(#SCS_TITLE, sMsg + "Please enter the SCS 9 version number that file '" + GetFilePart(gsCueFile) + "' was last saved with." +
                                           #CRLF$ + #CRLF$ + "This should be a number like 9.3.6, or 9.1.2.", ""))
    
    bFormatOK = #True
    bRangeOK = #True
    
    ; if user hits ESC or just doesn't enter anything, use whatever has been supplied
    If sTmp = ""
      sTmp = grCFH\sFileVersion
    EndIf
    
    If CountString(sTmp, ".") > 2
      ; too many parts to the version number
      bFormatOK = #False
      Continue
    EndIf
    
    For n = 1 To 4
      grCFH\sVersionParts[n-1] = StringField(sTmp, n, ".")
    Next
    grCFH\nFileVersion = (Val(grCFH\sVersionParts[0]) * 10000) + (Val(grCFH\sVersionParts[1]) * 100) + Val(grCFH\sVersionParts[2])
    
    debugMsg(sProcName, "nFileVersion=" + grCFH\nFileVersion)
    If grCFH\nFileVersion >= 90500 Or grCFH\nFileVersion < 80000
      bRangeOK = #False
      Continue
    EndIf
    
    bAsk = #False ; all OK
    grCFH\sFileVersion = sTmp
    
  Wend
  
  If bPrimaryFile
    gbSCSVersionChanged = #True
    gqLastChangeTime = ElapsedMilliseconds()
  EndIf
  
  gbModalDisplayed = bModalDisplayed
  
EndProcedure

Procedure getRecoveryFileInfo()
  PROCNAMEC()
  Protected nRecFile
  Protected sUpTag.s, sTagCode.s, nTagIndex, nNumLength, sUpAttributeName1.s
  Protected bOK
  Protected bProductionFound, bEndProductionFound
  Protected nResponse, sMsg.s
  Protected bReply
  Protected nStringFormat

  debugMsg(sProcName, #SCS_START)
  
  With grRecoveryFileInfo
    \bRecFileFound = #False
    \sCueFile = ""
    \sProdTitle = ""
    \sSaveDateTime = ""
    \fMasterBVLevel = -1
    \nEditCuePtr = -1
    
    If FileSize(gsRecoveryFile) >= 0
      nRecFile = ReadFile(#PB_Any, gsRecoveryFile, #PB_File_SharedRead)
      debugMsg(sProcName, "nRecFile=" + Str(nRecFile) + ", gsRecoveryFile=" + gsRecoveryFile)
      nStringFormat = ReadStringFormat(nRecFile)
      
      bOK = #True
      gsLine = ""
      gsChar = ""
      gbEOF = #False
      gnTagLevel = -1
      
      While (bOK) And (gbEOF = #False)
        nextInputTag(nRecFile, nStringFormat)
        If gbEOF = #False
          sUpTag = UCase(gsTag)
          sUpAttributeName1 = UCase(gsTagAttributeName1)
          ; debugMsg(sProcName, "sUpTag=" + sUpTag)
          If Left(sUpTag, 4) = "?XML"
            ; XML header
          ElseIf Left(gsTag, 1) <> "/"
            gnTagLevel + 1
            gasTagStack(gnTagLevel) = gsTag
          Else
            If gnTagLevel < 0
              bOK = #False
              sMsg = "Encountered <" + gsTag + ">" + " without matching <" + Mid(gsTag, 2) + ">"
              debugMsg(sProcName, sMsg)
              ensureSplashNotOnTop()
              scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
            ElseIf LCase(gasTagStack(gnTagLevel)) <> LCase(Mid(gsTag, 2))
              bOK = #False
              sMsg = "Encountered <" + gsTag + ">" + " but expecting </" + gasTagStack(gnTagLevel) + ">"
              debugMsg(sProcName, sMsg)
              ensureSplashNotOnTop()
              scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
            Else
              gnTagLevel - 1
            EndIf
          EndIf
          
          If bOK
            If Left(sUpTag, 4) <> "?XML"
              nextInputData(nRecFile, nStringFormat)
            EndIf
;             If Left(sUpTag, 1) <> "/"
;               debugMsg(sProcName, "tag=" + sUpTag + ", data=" + gsData)
;             EndIf
            
            sTagCode = sUpTag
            
            Select sTagCode
              Case "_CUEFILE_"
                \sCueFile = gsData
                
              Case "_SAVED_"
                \sSaveDateTime = gsData
                
              Case "_MVOL_"
                \fMasterBVLevel = ValF(gsData)
                
              Case "_QP_"
                \nEditCuePtr = Val(gsData)
                
              Case "PRODUCTION"
                bProductionFound = #True
                
              Case "TITLE"
                \sProdTitle = gsData
                
              Case "/PRODUCTION"
                bEndProductionFound = #True
                
              Default
                ; ignore everything else
                
            EndSelect
            
          EndIf
          
        EndIf
        
      Wend
      
      CloseFile(nRecFile)
      
      \bRecFileFound = #True
      
      ; debugMsg(sProcName, "\sCueFile=" + \sCueFile)
      ; debugMsg(sProcName, "FileSize(\sCueFile)=" + Str(FileSize(\sCueFile)))
      If (Len(\sCueFile) > 0) And (FileSize(\sCueFile) < 0)
        \bRecFileFound = #False
      EndIf
      
      ; debugMsg(sProcName, "bProductionFound=" + strB(bProductionFound) + ", bEndProductionFound=" + strB(bEndProductionFound))
      If bProductionFound = #False Or bEndProductionFound = #False
        \bRecFileFound = #False
      EndIf
      
    EndIf
    
    If \bRecFileFound
      ;sMsg = "Do you want to recover your last SCS edit? The recovery details are as follows:" + #CRLF$ + #CRLF$
      sMsg = Lang("CFH", "Recover1") + " " + Lang("CFH", "Recover2") +":" + #CRLF$ + #CRLF$
      sMsg = sMsg + Lang("CFH", "CueFile") +": " + GetFilePart(\sCueFile) + #CRLF$
      sMsg = sMsg + Lang("CFH", "LastSave") + ": " + \sSaveDateTime + #CRLF$
      sMsg = sMsg + Lang("CFH", "ProdTitle") + ": " + \sProdTitle
      ensureSplashNotOnTop()
      nResponse = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_YesNo)
      If nResponse = #PB_MessageRequester_Yes
        bReply = #True
      EndIf
    EndIf
    
  EndWith
  
  ProcedureReturn bReply
EndProcedure

Procedure addXMLNode(*nParentNode, sNodeName.s)
  ; PROCNAMEC()
  Protected *nNodeId
  
  ; debugMsg(sProcName, #SCS_START + ", sNodeName=" + sNodeName)
  
  *nNodeId = CreateXMLNode(*nParentNode, sNodeName, -1)
  ProcedureReturn *nNodeId
EndProcedure

Procedure addXMLNodeWithAttributes(*nParentNode, sNodeName.s, sAttributeName1.s, sAttributeValue1.s, sAttributeName2.s="", sAttributeValue2.s="")
  ; PROCNAMEC()
  Protected *nNodeId
  
  ; debugMsg(sProcName, #SCS_START + ", sNodeName=" + sNodeName)
  
  *nNodeId = CreateXMLNode(*nParentNode, sNodeName, -1)
  SetXMLAttribute(*nNodeId, sAttributeName1, sAttributeValue1)
  If sAttributeName2
    SetXMLAttribute(*nNodeId, sAttributeName2, sAttributeValue2)
  EndIf
  ProcedureReturn *nNodeId
EndProcedure

Procedure addXMLItem(*nParentNode, sNodeName.s, sNodeValue.s)
  ; PROCNAMEC()
  Protected *nItemNode
  
  ; debugMsg(sProcName, #SCS_START + ", sNodeName=" + sNodeName + ", sNodeValue=" + sNodeValue)
  
  *nItemNode = CreateXMLNode(*nParentNode, sNodeName, -1)
  SetXMLNodeText(*nItemNode, sNodeValue.s)
EndProcedure

Procedure addXMLItemIfReqd(*nParentNode, sNodeName.s, sNodeValue.s, sDefaultValue.s="")
  ; PROCNAMEC()
  Protected *nItemNode
  
  ; debugMsg(sProcName, #SCS_START + ", sNodeName=" + sNodeName + ", sNodeValue=" + sNodeValue)

  If sNodeValue <> sDefaultValue
    *nItemNode = CreateXMLNode(*nParentNode, sNodeName, -1)
    SetXMLNodeText(*nItemNode, sNodeValue.s)
  EndIf
EndProcedure

Procedure addXMLItemWithAttribute(*nParentNode, sNodeName.s, sAttributeName.s, sAttributeValue.s, sNodeValue.s)
  ; PROCNAMEC()
  Protected *nItemNode
  
  ; debugMsg(sProcName, #SCS_START + ", sNodeName=" + sNodeName + ", sNodeValue=" + sNodeValue)
  
  *nItemNode = CreateXMLNode(*nParentNode, sNodeName, -1)
  SetXMLAttribute(*nItemNode, sAttributeName, sAttributeValue)
  SetXMLNodeText(*nItemNode, sNodeValue.s)
EndProcedure

Procedure addXMLItemWithAttributeIfReqd(*nParentNode, sNodeName.s, sAttributeName.s, sAttributeValue.s, sNodeValue.s, sDefaultValue.s="")
  ; PROCNAMEC()
  Protected *nItemNode
  
  ; debugMsg(sProcName, #SCS_START + ", sNodeName=" + sNodeName + ", sNodeValue=" + sNodeValue)

  If sNodeValue <> sDefaultValue
    *nItemNode = CreateXMLNode(*nParentNode, sNodeName, -1)
    SetXMLAttribute(*nItemNode, sAttributeName, sAttributeValue)
    SetXMLNodeText(*nItemNode, sNodeValue.s)
  EndIf
EndProcedure

Procedure.s convertSerialPortNameToPB(sOldSerialPortName.s)
  ; PROCNAMEC()
  
  ; remove spaces and convert to uppercase
  ; eg convert "Com 1" to "COM1"
  ProcedureReturn UCase(RemoveString(sOldSerialPortName, " "))
EndProcedure

Procedure openMostRecentFile()
  PROCNAMEC()
  Protected bFileFound
  
  debugMsg(sProcName, #SCS_START)
  
  ; note: this procedure should ONLY be called when SCS is started, so it is NOT necessary to protect the cue list by passing 'loadcuefile' to SAM
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  debugMsg(sProcName, "gbRecovering=" + strB(gbRecovering) + ", gsCommand=" + gsCommand + ", Len(gsCommand)=" + Len(gsCommand) +
                      ", gbOpenRecentFile=" + strB(gbOpenRecentFile) + ", gnRecentFileCount=" + gnRecentFileCount)
  If gbRecovering
    gsCueFile = gsRecoveryFile
    gqLastChangeTime = ElapsedMilliseconds()
    
  ElseIf gsCommand
    gsCueFile = gsCommand
    
  ElseIf (gbOpenRecentFile) And (gnRecentFileCount > 0)
    If FileExists(gsRecentFile(0))
      gsCueFile = gsRecentFile(0)
    Else
      gsCueFile = ""
      debugMsg(sProcName, "File not found: " + gsRecentFile(0))
    EndIf
    
  Else
    gsCueFile = ""
    
  EndIf
  debugMsg(sProcName, "gsCueFile=" + gsCueFile)
  
  If grMain\nMainMemoSubPtr > 0
    WMN_clearMainMemoIfReqd(grMain\nMainMemoSubPtr)
  EndIf
  
  If gbRecovering
    gbUnsavedRecovery = #True
  Else
    gbUnsavedRecovery = #False
  EndIf
  gbNewDevMapFileCreated = #False
  gnUnsavedEditorGraphs = 0
  gsUnsavedEditorGraphs = ""
  gnUnsavedSliderGraphs = 0
  gbUnsavedVideoImageData = #False
  gbUnsavedPlaylistOrderInfo = #False
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  gbImportedCues = #False
  gbNewCueFile = #False
  
  debugMsg(sProcName, "calling loadCueFile()")
  loadCueFile() ; nb handles no file to open
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openSelectedFile(sFileName.s, bCreateFromTemplate=#False, bTemplate=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", sFileName=" + #DQUOTE$ + GetFilePart(sFileName) + #DQUOTE$ + ", bCreateFromTemplate=" + strB(bCreateFromTemplate) + ", bTemplate=" + strB(bTemplate))
  
  ; note: this procedure should ONLY be called when any current cue list is closed, so it is NOT necessary to protect the cue list by passing 'loadcuefile' to SAM
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  If gsCueFile
    debugMsg(sProcName, "calling clearCueFile()")
    clearCueFile()
  EndIf

  If Len(sFileName) = 0
    ; nb may occur for cue files, but should not occur for templates
    gsCueFile = ""
    gsTemplateFile = ""
  ElseIf FileExists(sFileName) = #False
    debugMsg(sProcName, "exiting because FileExists() returned #False")
    ProcedureReturn
  ElseIf bCreateFromTemplate Or bTemplate
    gsTemplateFile = sFileName
    gsCueFile = ""
  Else
    gsCueFile = sFileName
    gsTemplateFile = ""
  EndIf
  If bCreateFromTemplate Or bTemplate
    debugMsg(sProcName, "gsTemplateFile=" + #DQUOTE$ + gsTemplateFile + #DQUOTE$ + ", gsCueFile=" + #DQUOTE$ + gsCueFile + #DQUOTE$)
  Else
    debugMsg(sProcName, "gsCueFile=" + #DQUOTE$ + gsCueFile + #DQUOTE$)
  EndIf
  
  cancelAllLoadRequests() ; nb includes "THR_waitForAThreadToStop(#SCS_THREAD_SLIDER_FILE_LOADER)"
  
  If grMain\nMainMemoSubPtr > 0
    WMN_clearMainMemoIfReqd(grMain\nMainMemoSubPtr)
  EndIf
  
  gbUnsavedRecovery = #False
  gbNewDevMapFileCreated = #False
  gnUnsavedEditorGraphs = 0
  gsUnsavedEditorGraphs = ""
  gnUnsavedSliderGraphs = 0
  gbUnsavedVideoImageData = #False
  gbUnsavedPlaylistOrderInfo = #False
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  gbImportedCues = #False
  If bCreateFromTemplate
    gbNewCueFile = #True
  Else
    gbNewCueFile = #False
  EndIf
  debugMsg(sProcName, "gbNewCueFile=" + strB(gbNewCueFile))
  
  debugMsg(sProcName, "calling PNL_clearAllDispPanelInfo()")
  PNL_clearAllDispPanelInfo()
  
  If gbGlobalPause
    setToolBarCurrentImageIndex(#SCS_TBMB_PAUSE_RESUME, 0)
    gbGlobalPause = #False
    debugMsg(sProcName, "gbGlobalPause=" + strB(gbGlobalPause))
  EndIf
  If IsWindow(#WNE)
    If getWindowVisible(#WNE)
      setWindowVisible(#WNE, #False)
    EndIf
  EndIf

  debugMsg(sProcName, "calling loadCueFile(" + strB(bCreateFromTemplate) + ", " + strB(bTemplate) + ")")
  loadCueFile(bCreateFromTemplate, bTemplate) ; nb handles no file to open (for cue files, not templates)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openRecentFile(pFileNr)
  PROCNAMEC()
  Protected bCancel, sMsg.s, nCallEditorCuePtr
  
  debugMsg(sProcName, #SCS_START + ", pFileNr=" + Str(pFileNr))
  
  WEN_closeMemoWindowsIfOpen()
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not open new file
    ProcedureReturn
  EndIf
  setMonitorPin()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  If FileExists(gsRecentFile(pFileNr-1)) = #False
    sMsg = LangPars("Errors", "FileNotFound", gsRecentFile(pFileNr-1))
    debugMsg(sProcName, sMsg)
    ensureSplashNotOnTop()
    scsMessageRequester(#SCS_TITLE, sMsg)
    deleteFromRFL(gsRecentFile(pFileNr-1))
    ProcedureReturn
  EndIf
  
  gbUnsavedRecovery = #False
  gnUnsavedEditorGraphs = 0
  gsUnsavedEditorGraphs = ""
  gnUnsavedSliderGraphs = 0
  gbUnsavedVideoImageData = #False
  gbUnsavedPlaylistOrderInfo = #False
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  gbImportedCues = #False
  gbNewCueFile = #False
  If gbOpenRecentFile
    gsCueFile = gsRecentFile(pFileNr - 1)
    gsCueFolder = GetPathPart(gsCueFile)
  Else
    gsCueFile = ""
    gsCueFolder = ""
  EndIf
  debugMsg(sProcName, "gsCueFile=" + gsCueFile + ", gsCueFolder=" + gsCueFolder)
  
  If gbEditing
    nCallEditorCuePtr = -1
  EndIf
  samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, nCallEditorCuePtr)
  
EndProcedure

Procedure closeAndReopenCurrCueFile()
  PROCNAMEC()
  Protected nCallEditorCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  WEN_closeMemoWindowsIfOpen()
  setMonitorPin()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  gbUnsavedRecovery = #False
  gnUnsavedEditorGraphs = 0
  gsUnsavedEditorGraphs = ""
  gnUnsavedSliderGraphs = 0
  gbUnsavedVideoImageData = #False
  gbUnsavedPlaylistOrderInfo = #False
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  gbImportedCues = #False
  gbNewCueFile = #False
  debugMsg(sProcName, "gbNewCueFile=" + strB(gbNewCueFile))
  
  If gbEditing
    nCallEditorCuePtr = -1
  EndIf
  samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, nCallEditorCuePtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadCueFile(bCreateFromTemplate=#False, bTemplate=#False)
  PROCNAMEC()
  Protected sStatusField.s, nvMixInitResult
  
  debugMsg(sProcName, #SCS_START + ", bCreateFromTemplate=" + strB(bCreateFromTemplate) + ", bTemplate=" + strB(bTemplate))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  ; grCFH\nCueFileDateModified = 0 ; Deleted 5Jul2022 11.9.3.1ab
  grCFH\nMostRecentCueFileDateModified = 0 ; Added 5Jul2022 11.9.3.1ab
  gbInLoadCueFile = #True
  gbCuePanelLoadingMessageDisplayed = #False
  gbOpeningCueFile = #True
  gbCloseCueFile = #False     ; may be set #True by primeAndInitSMS()
  gbReviewDevMap = #False     ; may be set #True by primeAndInitSMS() or findValidDevMap()
  debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap))
  
  If IsWindow(#WCN) ; fmControllers
    WCN\bUseFaders = #False
    WCN_Form_Unload()
  EndIf
  
  WDD_hideWindowIfDisplayed() ; fmDMXDisplay
  WPL_hideWindowIfDisplayed() ; VST plugin editor window
  WVP_hideWindowIfDisplayed() ; fmVSTPlugins
  
  If IsWindow(#WMN)
    ; clear 'last playing cue'
    setLastPlayingCue(-1)
  EndIf
  
  debugMsg(sProcName, "calling closeAllDevices(#False, #False)")
  closeAllDevices(#False, #False)
  
  debugMsg(sProcName, "calling clearProdLogicalDevs()")
  clearProdLogicalDevs()
  
  gbRS232Started = #False
  
  debugMsg(sProcName, "calling freeLogoImages()")
  freeLogoImages()
  
  debugMsg(sProcName, "calling clearPtrsFromVidPicTargets()")
  clearPtrsFromVidPicTargets()

  debugMsg(sProcName, "calling DMX_initDMXControl()") ; Added 3Jul2022 11.9.4 (retrofitted to 11.9.3.1 5Jul2022)
  DMX_initDMXControl() ; Added 3Jul2022 11.9.4 (retrofitted to 11.9.3.1 5Jul2022)

  If bCreateFromTemplate Or bTemplate
    ; template file
    openSCSCueFile(bCreateFromTemplate, bTemplate)
    If (gbCueFileOpen = #False) Or (gbXMLFormat = #False)
      gbInLoadCueFile = #False
      ProcedureReturn
    EndIf
  Else
    ; cue file
    If Len(gsCueFile) = 0
      gbCueFileOpen = #False
      gbXMLFormat = #True
    Else
      openSCSCueFile()
    EndIf
  EndIf
  
  gnHighlightedCue = -1
  gnHighlightedRow = -1
  debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow)
  gnNonLinearCue = -1
  gnDependencyCue = -1
  
  debugMsg(sProcName, "calling WEP_resetCurrentDataFields()")
  WEP_resetCurrentDataFields()  ; nb doesn't matter if WEP isn't currently loaded as this procedure only resets fields in the grWEP global structure
  WQK_resetCurrentDataFields()
  
  If gbCueFileOpen
    If (bCreateFromTemplate = #False) And (bTemplate = #False)
      debugMsg(sProcName, "calling updateRFL()")
      updateRFL()
    EndIf
    
    If gbXMLFormat
      debugMsg(sProcName, "calling readXMLCueFile()")
      readXMLCueFile(gnCueFileNo, #True, gnCueFileStringFormat, gsCueFile, bCreateFromTemplate, bTemplate)
      debugMsg(sProcName, "returned from readXMLCueFile()")
      If gbCloseCueFile
        debugMsg(sProcName, "calling closeCueFile()")
        closeCueFile()
        gbCloseCueFile = #False
        gbInLoadCueFile = #False
        debugMsg(sProcName, "ProcedureReturn")
        ProcedureReturn
      ElseIf gbCloseSCS
        gbInLoadCueFile = #False
        debugMsg(sProcName, "ProcedureReturn")
        ProcedureReturn
      EndIf
      debugMsg(sProcName, "calling syncOutputChans(#True)")
      syncOutputChans(#True)
      grCFH\sMostRecentCueFile = gsCueFile ; Added 5Jul2022 11.9.3.1ab
      grCFH\nMostRecentCueFileDateModified = GetFileDate(grCFH\sMostRecentCueFile, #PB_Date_Modified)
      debugMsg(sProcName, "grCFH\nMostRecentCueFileDateModified=" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", grCFH\nMostRecentCueFileDateModified))
      debugMsg(sProcName, "grCFH\sMostRecentCueFile=" + #DQUOTE$ + grCFH\sMostRecentCueFile + #DQUOTE$) ; Changed 5Jul2022 11.9.3.1ab
    Else
      debugMsg(sProcName, "calling readNoCueFile()")
      readNoCueFile()
      grCFH\sMostRecentCueFile = ""            ; Added 5Jul2022 11.9.3.1ab
      grCFH\nMostRecentCueFileDateModified = 0 ; Added 5Jul2022 11.9.3.1ab
      debugMsg(sProcName, "grCFH\nMostRecentCueFileDateModified=0")
      debugMsg(sProcName, "grCFH\sMostRecentCueFile=" + #DQUOTE$ + grCFH\sMostRecentCueFile + #DQUOTE$) ; Changed 5Jul2022 11.9.3.1ab
    EndIf
    
  Else
    debugMsg(sProcName, "calling readNoCueFile()")
    readNoCueFile()
    grCFH\sMostRecentCueFile = ""            ; Added 5Jul2022 11.9.3.1ab
    grCFH\nMostRecentCueFileDateModified = 0 ; Added 5Jul2022 11.9.3.1ab
    debugMsg(sProcName, "grCFH\nMostRecentCueFileDateModified=0")
    debugMsg(sProcName, "grCFH\sMostRecentCueFile=" + #DQUOTE$ + grCFH\sMostRecentCueFile + #DQUOTE$) ; Changed 5Jul2022 11.9.3.1ab
  EndIf
  
  debugMsg(sProcName, "calling loadCueMarkerArrays()")
  loadCueMarkerArrays()
  
  debugMsg(sProcName, "calling setAutoActCueMarkerSubAndAudNos()")
  setAutoActCueMarkerSubAndAudNos()
  debugMsg(sProcName, "returned from setAutoActCueMarkerSubAndAudNos()")
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      If grvMixControl\bvMixInitDone
        ; vMix already initialised, so as we are loading a new cue file (or no cue file), remove any existing vMix inputs and reset the 'black' image
        vMix_SetOrResetInputsForSCS(#False)
      Else
        nvMixInitResult = vMix_InitIfReqd()
        debugMsg2(sProcName, "vMix_InitIfReqd()", nvMixInitResult)
        Select nvMixInitResult
          Case 0
            ; vMix connection OK - no further action required here
          Case #SCS_CLOSE_CUE_FILE
            gbCloseCueFile = #True
        EndSelect
      EndIf
    EndIf
  CompilerEndIf
  
  gbDataChanged = #False
  setUnsavedChanges(#False)
  debugMsg(sProcName, "calling setFileSave()")
  setFileSave()
  
  debugMsg(sProcName, "gbCloseCueFile=" + strB(gbCloseCueFile))
  If gbCloseCueFile
    ; gbCloseCueFile may be set #True in primeAndInitSMS()
    debugMsg(sProcName, "calling closeCueFile()")
    closeCueFile()
    debugMsg(sProcName, "calling readNoCueFile()")
    readNoCueFile()
  EndIf
  
  debugMsg(sProcName, "calling setGaplessInfo()")
  setGaplessInfo()
  
  If gbInitialising = #False
    With grDispControl
      \nCuePtr = -1
      \nSubPtr = -1
      \nAudPtr = -1
      \nSubNo = 0
      \nPlayNo = 0
      \bUseNext = #False
    EndWith
    
    debugMsg(sProcName, "calling setVidPicTargets(#False, #True)")
    setVidPicTargets(#False, #True)
    
    debugMsg(sProcName, "calling clearVDisplay()")
    clearVUDisplay()
    
    debugMsg(sProcName, "calling setCueDetailsInMain()")
    setCueDetailsInMain()
    
    resetPeaks(#True)
    
    GoToCue(getFirstEnabledCue())
  EndIf
  
  If gbCueFileOpen
    closeSCSCueFile(gnCueFileNo)
  EndIf
  
  If grTempDB\bTempDatabaseLoaded = #False
    debugMsg(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  grProd\qTimeProdLoaded = ElapsedMilliseconds()
  grProd\bTimeProdLoadedSet = #True
  debugMsg(sProcName, "grProd\qTimeProdLoaded=" + traceTime(grProd\qTimeProdLoaded))
  
  grMasterLevel\bUseControllerFaderMasterBVLevel = #False
  debugMsg(sProcName, "calling setMasterFader(" + formatLevel(grProd\fMasterBVLevel) + ")")
  setMasterFader(grProd\fMasterBVLevel)
  debugMsg(sProcName, "calling setAllInputGains()")
  setAllInputGains()
  debugMsg(sProcName, "calling setAllLiveEQ()")
  setAllLiveEQ()
  
  grDMXMasterFader\nDMXMasterFaderValue = grProd\nDMXMasterFaderValue
  grDMXMasterFader\nDMXMasterFaderResetValue = grProd\nDMXMasterFaderValue
  
  debugMsg(sProcName, "loadArrayCueOrSubForMTC()")
  loadArrayCueOrSubForMTC()
  
  debugMsg(sProcName, "calling checkIfMTCCuesIncluded()")
  If checkIfMTCCuesIncluded()
    ; use SAM to initiate the open to ensure this is performed after SAM has processed openMidiPorts()
    samAddRequest(#SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD, #True)
  EndIf
  
  If DMX_IsDMXOutDevPresent()
    If grProd\bLightingPre118
      DMX_loadDMXDimmableChannelArray()
    Else
      DMX_loadDMXDimmableChannelArrayFI()
    EndIf
    DMX_loadDMXTextColorsArray()
  EndIf
  
  If gbInitialising = #False
    sStatusField = RTrim(" " + getMidiInfo() + " " + RTrim(getRS232Info() + " " + RTrim(DMX_getDMXInfo() + " " + getNetworkInfo())))
    If sStatusField
      WMN_setStatusField(sStatusField, #SCS_STATUS_WARN, 6000, #True)
    EndIf
  EndIf
  
  gbForceStartEditor = #True
  gbInLoadCueFile = #False
  
  debugMsg(sProcName, "calling listFileDataArray()")
  listFileDataArray()
  debugMsg(sProcName, "calling listFileStatsArray()")
  listFileStatsArray()
  
  debugMsg(sProcName, "calling debugProd(@grProd)")
  debugProd(@grProd)
  debugMsg(sProcName, "calling debugCuePtrs()")
  debugCuePtrs()
  
  ; Commented out 4Oct2024 11.10.6af - can cause excessive logging (Octavio)
  ; debugMsg(sProcName, "calling listCueMarkerInfo()")
  ; listCueMarkerInfo()
  
  THR_createOrResumeAThread(#SCS_THREAD_GET_FILE_STATS)
  
  gbLogProcessorEvents = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeCueFile()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbCloseCueFile = #False
  
  If grMain\nMainMemoSubPtr > 0
    WMN_clearMainMemoIfReqd(grMain\nMainMemoSubPtr)
  EndIf
  
  debugMsg(sProcName, "calling closeAllDevices(#False, #False)")
  closeAllDevices(#False, #False)
  
  debugMsg(sProcName, "calling clearProdLogicalDevs()")
  clearProdLogicalDevs()
  
  debugMsg(sProcName, "calling freeLogoImages()")
  freeLogoImages()
  
  gbDataChanged = #False
  gbUnsavedRecovery = #False
  gbNewDevMapFileCreated = #False
  gnUnsavedEditorGraphs = 0
  gsUnsavedEditorGraphs = ""
  gnUnsavedSliderGraphs = 0
  gbUnsavedVideoImageData = #False
  gbUnsavedPlaylistOrderInfo = #False
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  gbImportedCues = #False
  gbNewCueFile = #False
  debugMsg(sProcName, "gbNewCueFile=" + strB(gbNewCueFile))
  setUnsavedChanges(#False)
  debugMsg(sProcName, "calling setFileSave()")
  setFileSave()
  
  debugMsg(sProcName, "calling clearCueFile()")
  clearCueFile()
  
  setFileSave()
  
  gqMainThreadRequest | #SCS_MTH_VU_CLEAR | #SCS_MTH_DISPLAY_OR_HIDE_HOTKEYS
  
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True, gbForceReloadAllDispPanels=#True")
  gbCallLoadDispPanels = #True
  gbForceReloadAllDispPanels = #True ; this is to override a test in PNL_loadDispPanels() that may skip reloading panels for performance reasons
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  gbCallSetNavigateButtons = #True
  
  gqMainThreadRequest | #SCS_MTH_REFRESH_GRDCUES  ; force refresh of grid so column headers are repainted
  
  gbEditing = #False   ; force repopulating editor in case user requests 'New' while the editor window is also displayed
  debugMsg(sProcName, "gbEditing=" + strB(gbEditing))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure newCueFile()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling closeCueFile()")
  closeCueFile()
  
  grProd\nFileBuild = grProgVersion\nBuildDate
  
  debugMsg(sProcName, "calling setCueDetailsInMain()")
  setCueDetailsInMain()
  
  gbForceStartEditor = #True
  gbLogProcessorEvents = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure saveFormattedXML(xmlId, xmlFile.s, flags=0, indentStep=2)
  PROCNAMEC()
  ; code from PB Forum, posted by Little John
  ; note: do NOT call FormatXML() on the source XML tree!
  Protected *buffer, encoding, size, OFN, Lpos, Rpos, indent=0
  Protected xml.s, prevLeft.s, prevRight.s, txt.s, curTag.s
  
  debugMsg(sProcName, #SCS_START + ", xmlFile=" + GetFilePart(xmlFile))
  
  ; Initialize
  If IsXML(xmlId) = 0
    ; error
    ProcedureReturn #False
  EndIf
  
  encoding = GetXMLEncoding(xmlId)
  Select encoding
    Case #PB_Ascii
      debugMsg(sProcName, "encoding=#PB_Ascii")
    Case #PB_Unicode
      debugMsg(sProcName, "encoding=#PB_Unicode")
    Case #PB_UTF8
      debugMsg(sProcName, "encoding=#PB_UTF8")
    Default
      debugMsg(sProcName, "encoding=" + encoding)
  EndSelect
  
  CompilerIf #PB_Unicode
    size = (ExportXMLSize(xmlId) + 1) * 2
  CompilerElse
    size = (ExportXMLSize(xmlId) + 1)
  CompilerEndIf
  debugMsg(sProcName, "AllocateMemory(" + size + ")")
  *buffer = AllocateMemory(size)
  If *buffer = 0
    ProcedureReturn #False                                                 ; error
  EndIf
  
  If ExportXML(xmlId, *buffer, size) = 0
    FreeMemory(*buffer)
    ProcedureReturn #False                                                 ; error
  EndIf
  
  xml = PeekS(*buffer, -1, encoding)
  FreeMemory(*buffer)
  debugMsg(sProcName, "Len(xml)=" + Len(xml) + ", StringByteLength(xml)=" + StringByteLength(xml))
  ; debugMsg(sProcName, "xml=[[[" + xml + "]]]")
  
  OFN = CreateFile(#PB_Any, xmlFile)
  If OFN = 0
    ProcedureReturn #False                                                 ; error
  EndIf
  
  If flags & #PB_XML_StringFormat
    WriteStringFormat(OFN, encoding)
  EndIf
  
  ; Get and write XML declaration
  Lpos = FindString(xml, "<", 1)
  Rpos = FindString(xml, ">", Lpos) + 1
  curTag = Mid(xml, Lpos, Rpos-Lpos)
  WriteString(OFN, curTag, encoding)
  
  ; Get and write the other elements
  Lpos = FindString(xml, "<", Rpos)
  While Lpos
    prevLeft  = Left(curTag, 2)
    prevRight = Right(curTag, 2)
    
    txt = Mid(xml, Rpos, Lpos-Rpos)
    
    If Mid(xml, Lpos, 9) = "<![CDATA["
      Rpos = FindString(xml, "]]>", Lpos) + 3
    Else
      Rpos = FindString(xml, ">", Lpos) + 1
    EndIf
    curTag = Mid(xml, Lpos, Rpos-Lpos)
    
    If (FindString("</<!<?", prevLeft, 1) = 0) And (prevRight <> "/>")
      If Left(curTag, 2) = "</"                                     ; <tag>text</tag>
        WriteString(OFN, txt + curTag, encoding)
      Else                                                           ; <tag1><tag2>
        indent + indentStep
        WriteString(OFN, #LF$ + Space(indent) + curTag, encoding)
      EndIf
    Else
      If Left(curTag, 2) = "</"                                     ; </tag2>text</tag1>
        If Len(txt)
          WriteString(OFN, #LF$ + Space(indent) + txt, encoding)
        EndIf
        indent - indentStep
      EndIf
      WriteString(OFN, #LF$ + Space(indent) + curTag, encoding)
    EndIf
    
    Lpos = FindString(xml, "<", Rpos)
  Wend
  
  WriteString(OFN, #LF$, encoding)
  CloseFile(OFN)
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True ; success
EndProcedure

Procedure removeUnusedDevices()
  PROCNAMEC()
  Protected j, k, m
  Protected d1, d2, bFound, nDeletedCount
  Protected sLogicalDev.s
  Protected nDevType
  Protected Dim bDeleteAudioDev(0) ; Changed 15Dec2022 11.10.0ac (was fixed size of #SCS_MAX_AUDIO_DEV_PER_PROD)
  Protected Dim bDeleteCtrlSendDev(0)
  
  ; look for any MIDI playback devices in grProd that are not used in aAud's
  ; Added 15Dec2022 11.10.0ac
  If grProd\nMaxAudioLogicalDev > ArraySize(bDeleteAudioDev())
    ReDim bDeleteAudioDev(grProd\nMaxAudioLogicalDev)
  EndIf
  ; End added 15Dec2022 11.10.0ac
  For d1 = 0 To grProd\nMaxAudioLogicalDev
    bDeleteAudioDev(d1) = #False
    If grProd\aAudioLogicalDevs(d1)\nDevType = #SCS_DEVTYPE_MIDI_PLAYBACK
      sLogicalDev = grProd\aAudioLogicalDevs(d1)\sLogicalDev
      bFound = #False
      For k = 1 To gnLastAud
        If aAud(k)\nFileFormat = #SCS_FILEFORMAT_MIDI
          For d2 = 0 To grLicInfo\nMaxAudDevPerAud
            If aAud(k)\sLogicalDev[d2] = sLogicalDev
              bFound = #True
              Break 2   ; break out of d2 loop and k loop
            EndIf
          Next d2
        EndIf
      Next k
      If bFound = #False
        bDeleteAudioDev(d1) = #True
      EndIf
    EndIf
  Next d1
  
  ; remove from grProd any MIDI playback devices identified in the above test
  nDeletedCount = 0
  For d1 = grProd\nMaxAudioLogicalDev To 0 Step -1
    If bDeleteAudioDev(d1)
      debugMsg(sProcName, "removing audio logical dev " + grProd\aAudioLogicalDevs(d1)\sLogicalDev)
      For d2 = (d1+1) To grProd\nMaxAudioLogicalDev
        grProd\aAudioLogicalDevs(d2-1) = grProd\aAudioLogicalDevs(d2)
      Next d2
      nDeletedCount + 1
    EndIf
  Next d1
  grProd\nMaxAudioLogicalDev - nDeletedCount
  
  ; look for any control send devices in grProd that are not used in control send aSub's
  If grProd\nMaxCtrlSendLogicalDev > ArraySize(bDeleteCtrlSendDev())
    ReDim bDeleteCtrlSendDev(grProd\nMaxCtrlSendLogicalDev)
  EndIf
  For d1 = 0 To grProd\nMaxCtrlSendLogicalDev
    bDeleteCtrlSendDev(d1) = #False
    If grProd\aCtrlSendLogicalDevs(d1)\nDevType <> #SCS_DEVTYPE_NONE
      nDevType = grProd\aCtrlSendLogicalDevs(d1)\nDevType
      sLogicalDev = grProd\aCtrlSendLogicalDevs(d1)\sLogicalDev
      bFound = #False
      For j = 1 To gnLastSub
        If aSub(j)\bSubTypeM
          For m = 0 To #SCS_MAX_CTRL_SEND
            If (aSub(j)\aCtrlSend[m]\nDevType = nDevType) And (aSub(j)\aCtrlSend[m]\sCSLogicalDev = sLogicalDev)
              bFound = #True
              Break 2   ; break out of m loop and j loop
            EndIf
          Next m
        EndIf
      Next j
      If bFound = #False
        bDeleteCtrlSendDev(d1) = #True
      EndIf
    EndIf
  Next d1
  
  ; remove from grProd any control send devices identified in the above test
  nDeletedCount = 0
  For d1 = grProd\nMaxCtrlSendLogicalDev To 0 Step -1
    If bDeleteCtrlSendDev(d1)
      debugMsg(sProcName, "removing control send dev " + grProd\aCtrlSendLogicalDevs(d1)\sLogicalDev)
      For d2 = (d1+1) To grProd\nMaxCtrlSendLogicalDev
        grProd\aCtrlSendLogicalDevs(d2-1) = grProd\aCtrlSendLogicalDevs(d2)
      Next d2
      nDeletedCount + 1
    EndIf
  Next d1
  grProd\nMaxCtrlSendLogicalDev - nDeletedCount
  
EndProcedure

Procedure convertSCS10SpecialNotes(bPrimaryFile)
  PROCNAMEC()
  Protected i
  Protected sGoToCue.s, nGoToCuePtr
  Protected sSetPosCue.s, nSetPosCuePtr, sSetPosTime.s, nSetPosTime
  Protected rSub.tySub
  Protected nSubPtr
  Protected nSpacePos, sTmp.s
  Protected nQuotePos, nSlashPos, nParamsPos, sParams.s
  Protected sFileName.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    If bPrimaryFile
      For i = 1 To gnLastCue
        With aCue(i)
          If \bSubTypeN
            If Left(LCase(\sCueDescr), 5) = "$goto" ; $GoTo
              sGoToCue = StringField(\sCueDescr, 2, " ")
              nGoToCuePtr = getCuePtr(sGoToCue)
              If nGoToCuePtr > 0
                debugMsg(sProcName, "converting Note cue to Go To cue: " + \sCue + " (" + \sCueDescr + ")")
                ; sGoToCue found so convert the Note cue to a GoTo cue
                rSub = grSubDef
                rSub\sCue = \sCue
                rSub\nCueIndex = i
                rSub\nSubNo = 1
                rSub\sSubType = "G"
                rSub\sSubDescr = Mid(\sCueDescr, 2)  ; set sub-cue description at cue description, omitting the leading "$"
                rSub\sCueToGoTo = sGoToCue
                gnUniqueSubId + 1
                rSub\nSubId = gnUniqueSubId
                nSubPtr = gnLastSub + 1
                checkMaxSub(nSubPtr)
                aSub(nSubPtr) = rSub
                gnLastSub = nSubPtr
                setDerivedSubFields(nSubPtr, #True)
                ; now change the parent cue
                \nFirstSubIndex = nSubPtr
                \sCueDescr = Mid(\sCueDescr, 2)   ; remove "$" from start of description
                setDerivedCueFields(i, #False)
              EndIf
              
            ElseIf Left(LCase(\sCueDescr), 7) = "$setpos" ; $SetPos
              sSetPosCue = Trim(StringField(\sCueDescr, 2, " "))
              sSetPosTime = Trim(StringField(\sCueDescr, 3, " "))
              If (Len(sSetPosCue) > 0) And (Len(sSetPosTime) > 0)
                nSetPosCuePtr = getCuePtr(sSetPosCue)
                nSetPosTime = stringToTime(sSetPosTime, #True)
                If (nSetPosCuePtr > 0) And (nSetPosTime >= 0)
                  debugMsg(sProcName, "converting Note cue to Set Position cue: " + \sCue + " (" + \sCueDescr + ")")
                  ; sSetPosCue found and sSetPosTime is valid, so convert the Note cue to a Set Position cue
                  rSub = grSubDef
                  rSub\sCue = \sCue
                  rSub\nCueIndex = i
                  rSub\nSubNo = 1
                  rSub\sSubType = "T"
                  rSub\sSubDescr = Mid(\sCueDescr, 2)  ; set sub-cue description at cue description, omitting the leading "$"
                  rSub\sSetPosCue = sSetPosCue
                  rSub\nSetPosTime = nSetPosTime
                  gnUniqueSubId + 1
                  rSub\nSubId = gnUniqueSubId
                  nSubPtr = gnLastSub + 1
                  checkMaxSub(nSubPtr)
                  aSub(nSubPtr) = rSub
                  gnLastSub = nSubPtr
                  setDerivedSubFields(nSubPtr, #True)
                  ; now change the parent cue
                  \nFirstSubIndex = nSubPtr
                  \sCueDescr = Mid(\sCueDescr, 2)   ; remove "$" from start of description
                  setDerivedCueFields(i, #False)
                EndIf
              EndIf
              
            ElseIf Left(LCase(\sCueDescr), 5) = "$open"  ; $Open and $OpenH
              debugMsg(sProcName, "converting Note cue to Run Program cue: " + \sCue + " (" + \sCueDescr + ")")
              rSub = grSubDef
              rSub\sCue = \sCue
              rSub\nCueIndex = i
              rSub\nSubNo = 1
              rSub\sSubType = "R"
              rSub\sSubDescr = Mid(\sCueDescr, 2)  ; set sub-cue description at cue description, omitting the leading "$"
              If Left(LCase(\sCueDescr), 6) = "$openh"
                rSub\bRPHideSCS = #True
              EndIf
              nSpacePos = FindString(\sCueDescr, " ")
              If nSpacePos > 0
                sFileName = Mid(\sCueDescr, nSpacePos+1)
                rSub\sRPFileName = Trim(RemoveString(decodeFileName(sFileName, bPrimaryFile), #DQUOTE$))
              EndIf
              gnUniqueSubId + 1
              rSub\nSubId = gnUniqueSubId
              nSubPtr = gnLastSub + 1
              checkMaxSub(nSubPtr)
              aSub(nSubPtr) = rSub
              gnLastSub = nSubPtr
              setDerivedSubFields(nSubPtr, #True)
              ; now change the parent cue
              \nFirstSubIndex = nSubPtr
              \sCueDescr = Mid(\sCueDescr, 2)   ; remove "$" from start of description
              setDerivedCueFields(i, #False)
              
            ElseIf Left(LCase(\sCueDescr), 4) = "$run"  ; $Run and $RunH
              debugMsg(sProcName, "converting Note cue to Run Program cue: " + \sCue + " (" + \sCueDescr + ")")
              rSub = grSubDef
              rSub\sCue = \sCue
              rSub\nCueIndex = i
              rSub\nSubNo = 1
              rSub\sSubType = "R"
              rSub\sSubDescr = Mid(\sCueDescr, 2)  ; set sub-cue description at cue description, omitting the leading "$"
              If Left(LCase(\sCueDescr), 5) = "$runh"
                rSub\bRPHideSCS = #True
              EndIf
              nSpacePos = FindString(\sCueDescr, " ")
              If nSpacePos > 0
                sTmp = Trim(Mid(\sCueDescr, nSpacePos+1))
                nParamsPos = 0
                nSlashPos = FindString(sTmp, "/")
                If nSlashPos > 0
                  nParamsPos = nSlashPos
                EndIf
                nQuotePos = FindString(sTmp, #DQUOTE$)
                If nQuotePos > 1  ; ignore quote if name of executable has been enclosed in quotes
                  If nQuotePos < nSlashPos
                    nParamsPos = nQuotePos
                  EndIf
                EndIf
                If nParamsPos > 0
                  sParams = Mid(sTmp, nParamsPos)
                  sFileName = Left(sTmp, nParamsPos-1)
                Else
                  sParams = ""
                  sFileName = sTmp
                EndIf
                rSub\sRPFileName = Trim(RemoveString(decodeFileName(sFileName, bPrimaryFile), #DQUOTE$))
                rSub\sRPParams = decodeFileName(sParams, bPrimaryFile, #False)
              EndIf
              gnUniqueSubId + 1
              rSub\nSubId = gnUniqueSubId
              nSubPtr = gnLastSub + 1
              checkMaxSub(nSubPtr)
              aSub(nSubPtr) = rSub
              gnLastSub = nSubPtr
              setDerivedSubFields(nSubPtr, #True)
              ; now change the parent cue
              \nFirstSubIndex = nSubPtr
              \sCueDescr = Mid(\sCueDescr, 2)   ; remove "$" from start of description
              setDerivedCueFields(i, #False)
              
            EndIf
          EndIf
        EndWith
      Next i
      
    Else ; bPrimaryFile = #False
      For i = 1 To gn2ndLastCue
        With a2ndCue(i)
          If \bSubTypeN
            If Left(LCase(\sCueDescr), 5) = "$goto" ; $GoTo
              sGoToCue = StringField(\sCueDescr, 2, " ")
              nGoToCuePtr = getCuePtr2(sGoToCue)
              If nGoToCuePtr > 0
                debugMsg(sProcName, "converting Note cue to Go To cue: " + \sCue + " (" + \sCueDescr + ")")
                ; sGoToCue found so convert the Note cue to a GoTo cue
                rSub = grSubDef
                rSub\sCue = \sCue
                rSub\nCueIndex = i
                rSub\nSubNo = 1
                rSub\sSubType = "G"
                rSub\sSubDescr = Mid(\sCueDescr, 2)  ; set sub-cue description at cue description, omitting the leading "$"
                rSub\sCueToGoTo = sGoToCue
                gnUniqueSubId + 1
                rSub\nSubId = gnUniqueSubId
                nSubPtr = gn2ndLastSub + 1
                checkMaxSub(nSubPtr, #False)
                a2ndSub(nSubPtr) = rSub
                gn2ndLastSub = nSubPtr
                setDerivedSubFields(nSubPtr, #False)
                ; now change the parent cue
                \nFirstSubIndex = nSubPtr
                \sCueDescr = Mid(\sCueDescr, 2)   ; remove "$" from start of description
                setDerivedCueFields2(i, #False)
              EndIf
              
            ElseIf Left(LCase(\sCueDescr), 7) = "$setpos" ; $SetPos
              sSetPosCue = Trim(StringField(\sCueDescr, 2, " "))
              sSetPosTime = Trim(StringField(\sCueDescr, 3, " "))
              If (Len(sSetPosCue) > 0) And (Len(sSetPosTime) > 0)
                nSetPosCuePtr = getCuePtr2(sSetPosCue)
                nSetPosTime = stringToTime(sSetPosTime, #True)
                If (nSetPosCuePtr > 0) And (nSetPosTime >= 0)
                  debugMsg(sProcName, "converting Note cue to Set Position cue: " + \sCue + " (" + \sCueDescr + ")")
                  ; sSetPosCue found and sSetPosTime is valid, so convert the Note cue to a Set Position cue
                  rSub = grSubDef
                  rSub\sCue = \sCue
                  rSub\nCueIndex = i
                  rSub\nSubNo = 1
                  rSub\sSubType = "T"
                  rSub\sSubDescr = Mid(\sCueDescr, 2)  ; set sub-cue description at cue description, omitting the leading "$"
                  rSub\sSetPosCue = sSetPosCue
                  rSub\nSetPosTime = nSetPosTime
                  gnUniqueSubId + 1
                  rSub\nSubId = gnUniqueSubId
                  nSubPtr = gn2ndLastSub + 1
                  checkMaxSub(nSubPtr, #False)
                  a2ndSub(nSubPtr) = rSub
                  gn2ndLastSub = nSubPtr
                  setDerivedSubFields(nSubPtr, #False)
                  ; now change the parent cue
                  \nFirstSubIndex = nSubPtr
                  \sCueDescr = Mid(\sCueDescr, 2)   ; remove "$" from start of description
                  setDerivedCueFields2(i, #False)
                EndIf
              EndIf
            EndIf
          EndIf
        EndWith
      Next i
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addCtrlSendLogicalDevIfReqd(nDevType, sLogicalDev.s, bPrimaryFile)
  PROCNAMEC()
  Protected d, bFound, bAdded
  
  If bPrimaryFile
    
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      If grProd\aCtrlSendLogicalDevs(d)\nDevType = nDevType
        If grProd\aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev
          bFound = #True
          Break
        EndIf
      EndIf
    Next d
    If bFound = #False
      ; new device - add to Ctrl Send devices
      For d = 0 To grProd\nMaxCtrlSendLogicalDev
        If grProd\aCtrlSendLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
          With grProd\aCtrlSendLogicalDevs(d)
            \nDevType = nDevType
            \sLogicalDev = sLogicalDev
            bAdded = #True
          EndWith
          Break
        EndIf
      Next d
      If bAdded = #False
        grProd\nMaxCtrlSendLogicalDev + 1
        d = grProd\nMaxCtrlSendLogicalDev
        If d > ArraySize(grProd\aCtrlSendLogicalDevs())
          ReDim grProd\aCtrlSendLogicalDevs(d)
        EndIf
        grProd\aCtrlSendLogicalDevs(d) = grCtrlSendLogicalDevsDef
        With grProd\aCtrlSendLogicalDevs(d)
          \nDevType = nDevType
          \sLogicalDev = sLogicalDev
        EndWith
      EndIf
    EndIf
    
  Else  ; bPrimaryFile = #False
    
    For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
      If gr2ndProd\aCtrlSendLogicalDevs(d)\nDevType = nDevType
        If gr2ndProd\aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev
          bFound = #True
          Break
        EndIf
      EndIf
    Next d
    If bFound = #False
      ; new device - add to Ctrl Send devices
      For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
        If gr2ndProd\aCtrlSendLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
          With gr2ndProd\aCtrlSendLogicalDevs(d)
            \nDevType = nDevType
            \sLogicalDev = sLogicalDev
            bAdded = #True
          EndWith
          Break
        EndIf
      Next d
      If bAdded = #False
        gr2ndProd\nMaxCtrlSendLogicalDev + 1
        d = gr2ndProd\nMaxCtrlSendLogicalDev
        If d > ArraySize(gr2ndProd\aCtrlSendLogicalDevs())
          ReDim gr2ndProd\aCtrlSendLogicalDevs(d)
        EndIf
        gr2ndProd\aCtrlSendLogicalDevs(d) = grCtrlSendLogicalDevsDef
        With gr2ndProd\aCtrlSendLogicalDevs(d)
          \nDevType = nDevType
          \sLogicalDev = sLogicalDev
        EndWith
      EndIf
    EndIf
    
  EndIf

EndProcedure

Procedure addVidAudLogicalDevIfReqd(*rProd.tyProd, sLogicalDev.s)
  PROCNAMEC()
  Protected d, bFound
  
  debugMsg(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev)
  
  With *rProd
    For d = 0 To \nMaxVidAudLogicalDev
      If \aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDev
        bFound = #True
        Break
      EndIf
    Next d
    If bFound = #False
      ; new device - add to video audio devices
      debugMsg(sProcName, "calling addOneVidAudLogicalDev")
      addOneVidAudLogicalDev(*rProd)
      d = \nMaxVidAudLogicalDevDisplay
      \aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDev
      gnNextDevId + 1
      \aVidAudLogicalDevs(d)\nDevId = gnNextDevId
    EndIf
  EndWith
  
EndProcedure

Procedure convertSCS10VideoImageCues(bPrimaryFile)
  PROCNAMEC()
  Protected i, j, k
  
  If bPrimaryFile ; primary file
    For i = 1 To gnLastCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubTypeA=" + strB(aSub(j)\bSubTypeA))
        If aSub(j)\bSubTypeA
          If aSub(j)\bPLRepeat
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\bContinuous
                If aAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO
                  debugMsg(sProcName, "setting aAud(" + getAudLabel(k) + ")\bContinuous = #False") 
                  aAud(k)\bContinuous = #False
                ElseIf aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                  debugMsg(sProcName, "setting aSub(" + getSubLabel(j) + ")\bPLRepeat = #False")
                  aSub(j)\bPLRepeat = #False
                EndIf
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    Next i
    
  Else  ; secondary file
    For i = 1 To gn2ndLastCue
      j = a2ndCue(i)\nFirstSubIndex
      While j >= 0
        If a2ndSub(j)\bSubTypeA
          If a2ndSub(j)\bPLRepeat
            k = a2ndSub(j)\nFirstAudIndex
            While k >= 0
              If a2ndAud(k)\bContinuous
                If a2ndAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO
                  a2ndAud(k)\bContinuous = #False
                ElseIf a2ndAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                  a2ndSub(j)\bPLRepeat = #False
                EndIf
              EndIf
              k = a2ndAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf
        j = a2ndSub(j)\nNextSubIndex
      Wend
    Next i
    
  EndIf
EndProcedure

Procedure convertSCS10CtrlSendCues(bPrimaryFile)
  PROCNAMEC()
  Protected d, i, j, n
  Protected sMidiLogicalDev.s, sRS232LogicalDev.s, sNetworkLogicalDev.s
  
  debugMsg(sProcName, #SCS_START)
  
  If bPrimaryFile ; primary file
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      With grProd\aCtrlSendLogicalDevs(d)
        ; debugMsg(sProcName, "grProd\aCtrlSendLogicalDevs(" + d + ")\nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", sMidiLogicalDev=" + sMidiLogicalDev)
        Select \nDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            If Len(sMidiLogicalDev) = 0
              sMidiLogicalDev = \sLogicalDev
            EndIf
          Case #SCS_DEVTYPE_CS_RS232_OUT
            If Len(sRS232LogicalDev) = 0
              sRS232LogicalDev = \sLogicalDev
            EndIf
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            If Len(sNetworkLogicalDev) = 0
              sNetworkLogicalDev = \sLogicalDev
            EndIf
        EndSelect
      EndWith
    Next d
    
  Else  ; secondary file
    For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
      With gr2ndProd\aCtrlSendLogicalDevs(d)
        ; debugMsg(sProcName, "gr2ndProd\aCtrlSendLogicalDevs(" + d + ")\nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", sMidiLogicalDev=" + sMidiLogicalDev)
        Select \nDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            If Len(sMidiLogicalDev) = 0
              sMidiLogicalDev = \sLogicalDev
            EndIf
          Case #SCS_DEVTYPE_CS_RS232_OUT
            If Len(sRS232LogicalDev) = 0
              sRS232LogicalDev = \sLogicalDev
            EndIf
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            If Len(sNetworkLogicalDev) = 0
              sNetworkLogicalDev = \sLogicalDev
            EndIf
        EndSelect
      EndWith
    Next d
  EndIf
  
  ; common
  If Len(sMidiLogicalDev) = 0
    sMidiLogicalDev = "MIDI"
  EndIf
  If Len(sRS232LogicalDev) = 0
    sRS232LogicalDev = "RS232"
  EndIf
  If Len(sNetworkLogicalDev) = 0
    sNetworkLogicalDev = "Network"
  EndIf
  
  If bPrimaryFile ; primary file
    For i = 1 To gnLastCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            With aSub(j)\aCtrlSend[n]
              If (\nMSMsgType <> #SCS_MSGTYPE_NONE) And (\nDevType = #SCS_DEVTYPE_NONE)
                Select \nMSMsgType
                  Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF, #SCS_MSGTYPE_MSC, #SCS_MSGTYPE_FREE
                    \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
                    \sCSLogicalDev = sMidiLogicalDev
                  Case #SCS_MSGTYPE_RS232
                    \nDevType = #SCS_DEVTYPE_CS_RS232_OUT
                    \sCSLogicalDev = sRS232LogicalDev
                  Case #SCS_MSGTYPE_NETWORK
                    \nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
                    \sCSLogicalDev = sNetworkLogicalDev
                EndSelect
                addCtrlSendLogicalDevIfReqd(\nDevType, \sCSLogicalDev, bPrimaryFile)
              EndIf
            EndWith
            ; debugMsg(sProcName, "Calling buildDisplayInfoForCtrlSend")
            buildDisplayInfoForCtrlSend(@aSub(j), n)
          Next n
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    Next i
    
  Else  ; secondary file
    For i = 1 To gn2ndLastCue
      j = a2ndCue(i)\nFirstSubIndex
      While j >= 0
        If a2ndSub(j)\bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            With a2ndSub(j)\aCtrlSend[n]
              If (\nMSMsgType <> #SCS_MSGTYPE_NONE) And (\nDevType = #SCS_DEVTYPE_NONE)
                Select \nMSMsgType
                  Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF, #SCS_MSGTYPE_MSC, #SCS_MSGTYPE_FREE
                    \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
                    \sCSLogicalDev = sMidiLogicalDev
                  Case #SCS_MSGTYPE_RS232
                    \nDevType = #SCS_DEVTYPE_CS_RS232_OUT
                    \sCSLogicalDev = sRS232LogicalDev
                  Case #SCS_MSGTYPE_NETWORK
                    \nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
                    \sCSLogicalDev = sNetworkLogicalDev
                EndSelect
                addCtrlSendLogicalDevIfReqd(\nDevType, \sCSLogicalDev, bPrimaryFile)
              EndIf
            EndWith
            ; debugMsg(sProcName, "Calling buildDisplayInfoForCtrlSend")
            buildDisplayInfoForCtrlSend(@a2ndSub(j), n, #False)
          Next n
        EndIf
        j = a2ndSub(j)\nNextSubIndex
      Wend
    Next i
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s suggestFileNameFromTitle(sProdTitle.s)
  PROCNAMEC()
  Protected sFileName.s
  Protected sInvalidChars.s
  Protected nPtr, nLength, n
  
  sInvalidChars = "\/:*?<>|" + Chr(34)
  sFileName = Trim(sProdTitle)
  
  ; the following code terminates sFileName at the first invalid character, if any
  ; for example, if sProdTitle contains "Easter 2011: Resurrection" then sFileName will be set to "Easter 2011"
  For n = 1 To Len(sInvalidChars)
    nPtr = InStr(sFileName, Mid(sInvalidChars, n, 1))
    If nPtr > 0
      sFileName = Left(sFileName, nPtr - 1)
    EndIf
  Next n
  
  debugMsg(sProcName, "sProdTitle=" + #DQUOTE$ + sProdTitle + #DQUOTE$ + ", sFileName=" + Trim(sFileName))
  ProcedureReturn Trim(sFileName)
  
EndProcedure

Procedure mapCtrlLogicalDevsToPhysicalDevs()
  PROCNAMEC()
  Protected d1, d2, k, bModalDisplayed
  Protected bFound, bFound2
  Protected bCheckDevices
  Protected nNotFoundCount, sNotFoundString.s, sMyPhysicalDev.s
  Protected nMousePointer
  Protected nReply
  Protected sPrompt.s, sTitle.s, sCheckText.s, sButtons.s
  Protected sMsg.s
  Protected bRetryMIDI, bRetryRS232, bRetryNetwork, bRetryDMX
  Protected nDevMapPtr, nDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  bModalDisplayed = gbModalDisplayed
  gbInMapProdLogicalDevs = #True
  
  For d2 = 0 To (gnNumMidiOutDevs-1)
    With gaMidiOutDevice(d2)
      \bCtrlSend = #False  ; may be set #True later in this procedure
      \bMidiDevForMTC = #False ; may be set #True later in this procedure
      debugMsg(sProcName, "gaMidiOutDevice(" + d2 + ")\sName=" + \sName + ", \bCtrlSend=" + strB(\bCtrlSend) + ", \bCtrlMidiForMTC=" + strB(\bMidiDevForMTC))
    EndWith
  Next d2
  
  ; check all required devices exist
  bCheckDevices = #True
  While bCheckDevices
    nNotFoundCount = 0
    sNotFoundString = ""
    bRetryMIDI = #False
    bRetryRS232 = #False
    bRetryNetwork = #False
    bRetryDMX = #False
    
    d1 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While d1 >= 0
      With grMaps\aDev(d1)
        debugMsg(sProcName, "grMaps\aDev(" + d1 + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) +
                            ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \bExists=" + strB(\bExists))
        If (\bExists) And (\nDevGrp = #SCS_DEVGRP_CTRL_SEND) And (\nDevType <> #SCS_DEVTYPE_NONE) And (\bIgnoreDevThisRun = #False)
          bFound = #False
          bFound2 = #False
          Select \nDevType
            Case #SCS_DEVTYPE_CS_MIDI_OUT
              For d2 = 0 To (gnNumMidiOutDevs-1)
                If (gaMidiOutDevice(d2)\sName = \sPhysicalDev) Or (gaMidiOutDevice(d2)\bDummy And \bDummy)
                  ; added \bDummy test 22Nov2016 11.5.2.4 following email from Lluís Vilarrasa about dummy device not being recognized when changing the language
                  bFound = #True
                  \nPhysicalDevPtr = d2
                  nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev)
                  If nDevNo >= 0
                    If grProd\aCtrlSendLogicalDevs(nDevNo)\bCtrlMidiForMTC
                      gaMidiOutDevice(d2)\bMidiDevForMTC = #True
                    Else
                      gaMidiOutDevice(d2)\bCtrlSend = #True
                    EndIf
                    debugMsg(sProcName, "grMaps\aDev(" + d1 + ")\sLogicalDev=" + \sLogicalDev + ", gaMidiOutDevice(" + d2 + ")\sName=" + gaMidiOutDevice(d2)\sName +
                                        ", \bCtrlSend=" + strB(gaMidiOutDevice(d2)\bCtrlSend) + ", \bMidiDevForMTC=" + strB(gaMidiOutDevice(d2)\bMidiDevForMTC))
                  EndIf
                  Break
                EndIf
              Next d2
              
            Case #SCS_DEVTYPE_CS_MIDI_THRU
              ; must process IN device first as \nMidiThruInPhysicalDevPtr needs to be set before processing OUT device
              For d2 = 0 To (gnNumMidiInDevs-1)
                If (gaMidiInDevice(d2)\sName = \sMidiThruInPhysicalDev) Or (gaMidiInDevice(d2)\bDummy And \bMidiThruInDummy)
                  bFound2 = #True
                  \nMidiThruInPhysicalDevPtr = d2
                  gaMidiInDevice(d2)\bConnectPort = #True
                  debugMsg(sProcName, "grMaps\aDev(" + d1 + ")\sLogicalDev=" + \sLogicalDev + ", gaMidiInDevice(" + d2 + ")\sName=" + gaMidiInDevice(d2)\sName +
                                      ", \bConnectPort=" + strB(gaMidiInDevice(d2)\bConnectPort))
                  Break
                EndIf
              Next d2
              For d2 = 0 To (gnNumMidiOutDevs-1)
                If (gaMidiOutDevice(d2)\sName = \sPhysicalDev) Or (gaMidiOutDevice(d2)\bDummy And \bDummy)
                  bFound = #True
                  \nPhysicalDevPtr = d2
                  gaMidiOutDevice(d2)\bCtrlSend = #True
                  gaMidiOutDevice(d2)\bThruPort = #True
                  gaMidiOutDevice(d2)\nMidiThruInPhysicalDevPtr = \nMidiThruInPhysicalDevPtr
                  debugMsg(sProcName, "grMaps\aDev(" + d1 + ")\sLogicalDev=" + \sLogicalDev + ", gaMidiOutDevice(" + d2 + ")\sName=" + gaMidiOutDevice(d2)\sName +
                                      ", \bCtrlSend=" + strB(gaMidiOutDevice(d2)\bCtrlSend) + ", \bThruPort=" + strB(gaMidiOutDevice(d2)\bThruPort) +
                                      ", \nMidiThruInPhysicalDevPtr=" + gaMidiOutDevice(d2)\nMidiThruInPhysicalDevPtr)
                  Break
                EndIf
              Next d2
              
            Case #SCS_DEVTYPE_CS_RS232_OUT
              debugMsg(sProcName, "grMaps\aDev(" + d1 + ")\sPhysicalDev=" + \sPhysicalDev)
              For d2 = 0 To gnMaxRS232Control
                debugMsg(sProcName, "gaRS232Control(" + d2 + ")\sRS232PortAddress=" + gaRS232Control(d2)\sRS232PortAddress)
                If (gaRS232Control(d2)\sRS232PortAddress = \sPhysicalDev) Or (gaRS232Control(d2)\bDummy And \bDummy)
                  ; added \bDummy test 22Nov2016 11.5.2.4 following email from Lluís Vilarrasa about dummy device not being recognized when changing the language
                  debugMsg(sProcName, "FOUND")
                  bFound = #True
                  \nPhysicalDevPtr = d2
                  nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev)
                  If nDevNo >= 0
                    ; the following fields listed in the order of the corresponding properties displayed under Production Properties - Cue Control Devices - RS232
                    gaRS232Control(d2)\nRS232DataBits = grProd\aCtrlSendLogicalDevs(nDevNo)\nRS232DataBits
                    gaRS232Control(d2)\fRS232StopBits = grProd\aCtrlSendLogicalDevs(nDevNo)\fRS232StopBits
                    gaRS232Control(d2)\nRS232Parity = grProd\aCtrlSendLogicalDevs(nDevNo)\nRS232Parity
                    gaRS232Control(d2)\nRS232BaudRate = grProd\aCtrlSendLogicalDevs(nDevNo)\nRS232BaudRate
                    gaRS232Control(d2)\nRS232Handshaking = grProd\aCtrlSendLogicalDevs(nDevNo)\nRS232Handshaking
                    gaRS232Control(d2)\nRS232RTSEnable = grProd\aCtrlSendLogicalDevs(nDevNo)\nRS232RTSEnable
                    gaRS232Control(d2)\nRS232DTREnable = grProd\aCtrlSendLogicalDevs(nDevNo)\nRS232DTREnable
                  EndIf
                  debugMsg(sProcName, "gaRS232Control(" + d2 + ")\nRS232BaudRate=" + gaRS232Control(d2)\nRS232BaudRate)
                  Break
                EndIf
              Next d2
              
            Case #SCS_DEVTYPE_CS_NETWORK_OUT
              For d2 = 0 To gnMaxNetworkControl
                ; debugMsg(sProcName, "gaNetworkControl(" + d2 + ")\sNetworkDevDesc=" + gaNetworkControl(d2)\sNetworkDevDesc)
                If (gaNetworkControl(d2)\sNetworkDevDesc = \sPhysicalDev) Or (gaNetworkControl(d2)\bNWDummy And \bDummy)
                  ; added \bDummy test 22Nov2016 11.5.2.4 following email from Lluís Vilarrasa about dummy device not being recognized when changing the language
                  bFound = #True
                  \nPhysicalDevPtr = d2
                  Break
                EndIf
              Next d2
              ; debugMsg(sProcName, "grMaps\aDev(" + d1 + ")\sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
              
            Case #SCS_DEVTYPE_LT_DMX_OUT
              For d2 = 0 To grDMX\nMaxDMXControl
                If ((gaDMXControl(d2)\sDMXName = \sPhysicalDev) And (gaDMXControl(d2)\sDMXSerial = \sDMXSerial)) Or (gaDMXControl(d2)\bDMXDummyPort And \bDummy)
                  ; added \bDummy test 22Nov2016 11.5.2.4 following email from Lluís Vilarrasa about dummy device not being recognized when changing the language
                  bFound = #True
                  \nPhysicalDevPtr = d2
                  Break
                EndIf
              Next d2
              
            Case #SCS_DEVTYPE_CS_HTTP_REQUEST
              If grHTTPControl\sHTTPDevDesc = \sPhysicalDev
                bFound = #True
              EndIf
              
          EndSelect
          
          If bFound = #False
            If \sPhysicalDev
              nNotFoundCount + 1
              ; sNotFoundString + "|" + \sPhysicalDev + " (assigned to " + \sLogicalDev + ")"
              sMyPhysicalDev = \sPhysicalDev
              Select \nDevType
                Case #SCS_DEVTYPE_CS_MIDI_OUT
                  bRetryMIDI = #True
                Case #SCS_DEVTYPE_CS_RS232_OUT
                  bRetryRS232 = #True
                Case #SCS_DEVTYPE_CS_NETWORK_OUT
                  bRetryNetwork = #True
                  sMyPhysicalDev = ReplaceString(sMyPhysicalDev, "?", " ")
                Case #SCS_DEVTYPE_LT_DMX_OUT
                  bRetryDMX = #True
              EndSelect
              sNotFoundString + "|" + \sLogicalDev + " (assigned to " + sMyPhysicalDev + ")"
            EndIf
          EndIf
          If (bFound2 = #False) And (\nDevType = #SCS_DEVTYPE_CS_MIDI_THRU)
            If \sMidiThruInPhysicalDev
              nNotFoundCount + 1
              ; sNotFoundString + "|" + \sMidiThruInPhysicalDev + " (assigned to " + \sLogicalDev + ")"
              sNotFoundString + "|" + \sLogicalDev + " (assigned to " + \sMidiThruInPhysicalDev + ")"
              bRetryMIDI = #True
            EndIf
          EndIf
        EndIf
        d1 = \nNextDevIndex
      EndWith
    Wend
    
    If nNotFoundCount = 0
      bCheckDevices = #False
    Else
      nMousePointer = GetMouseCursor()
      SetMouseCursorNormal()
      gbModalDisplayed = #True
      sPrompt = LangPars("DevMap", "DevsNotFound", decodeDevGrpL(#SCS_DEVGRP_CTRL_SEND)) + "|" + sNotFoundString + "|"
      sTitle = GetFilePart(gsCueFile)
      debugMsg(sProcName, sTitle + ": " + sPrompt)
      ensureSplashNotOnTop()
      ; nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, "Retry|Cancel", 100, #IDI_EXCLAMATION)
      sButtons = Lang("DevMap", "TryAgain") + "|" + Lang("DevMap", "chgDevMap")
      nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 200, #IDI_QUESTION)
      gbModalDisplayed = bModalDisplayed
      SetMouseCursor(nMousePointer)
      Select nReply
        Case 1 ; try again
          If bRetryMIDI
            debugMsg(sProcName, "calling loadArrayMidiDevs()")
            loadArrayMidiDevs()
          EndIf
          If bRetryRS232
            initRS232Control()
          EndIf
          If bRetryNetwork
            initNetworkControl()
          EndIf
          If bRetryDMX
            DMX_initDMXControl()
          EndIf
        Case 2 ; change/review device map
          ; Added 18Jun2021 11.8.5al
          gbGoToProdPropDevices = #True
          debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
          ; End added 18Jun2021 11.8.5al
          bCheckDevices = #False
      EndSelect
    EndIf
  Wend
  
  debugMsg(sProcName, "calling setLogicalDevsDerivedFields")
  setLogicalDevsDerivedFields()
  
  gbInMapProdLogicalDevs = #False
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure mapLiveLogicalDevsToPhysicalDevs()
  PROCNAMEC()
  ;- to be done (live input)
EndProcedure

Procedure doDatabaseUpdate(nDatabase, sSQLRequest.s, bTrace=#False)
  PROCNAMEC()
  Protected nResult
  Protected sDatabase.s
  Protected sMsg.s
  
  nResult = DatabaseUpdate(nDatabase, sSQLRequest)
  If bTrace
    Select nDatabase
      Case grTempDB\nTempDatabaseNo
        sDatabase = "(T) "
      Case grProd\nDatabaseNo
        sDatabase = "(P) "
    EndSelect
    If nResult = 0
      sMsg = sDatabase + "sSQLRequest=" + sSQLRequest + "; failed: " + DatabaseError()
    Else
      sMsg = sDatabase + "sSQLRequest=" + sSQLRequest + "; successful"
    EndIf
    debugMsg(sProcName, sMsg)
  EndIf
  
  ProcedureReturn nResult
EndProcedure

; Uncle Berikco's routine to properly replace single quotes with double for SQL passing
Procedure.s RepQuote(sInstring.s)
  Protected n, sTemporaryString.s
  
  For n = 1 To Len(sInstring)
    If Mid(sInstring.s, n, 1) = "'"
      sTemporaryString + "''"
    Else
      sTemporaryString + Mid(sInstring, n, 1)
    EndIf
  Next n
  ProcedureReturn sTemporaryString
EndProcedure

; Kill double quotes in strings for display purposes
Procedure.s KillQuote(sInstring.s)
  ProcedureReturn ReplaceString(sInstring, "''", "'")
EndProcedure

Procedure createTableFileData(nDatabaseNo)
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the FileData table
  ; NormalizeFactorInt stored as INT to avoid any localisation issues re "." or "," in StrF() possibly clashing with SQLite standards
  ; NormalizeFactorInt = NormalizeFactor * 1000
  sSQLRequest = "CREATE TABLE FileData(" +
                "FileName TEXT NOT NULL, FileModified TEXT, FileSize INT, GraphWidth INT, GraphChannels INT, MaxPeak INT," +
                " NormalizeFactorInt INT, FileBlob BLOB, FileBlobSize INT, ViewStart INT, ViewEnd INT, DBVersion INT," +
                " UNIQUE (FileName, GraphWidth, GraphChannels, ViewStart, ViewEnd))"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  ; note: see also saveGraphDataToTempDatabase()
  
EndProcedure

Procedure createTableFileStats(nDatabaseNo)
  ; Changed 3Oct2022 11.9.6 to add 75dB and 60dB
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the FileStats table
  ; MaxAbsSample stored as INT to avoid any localisation issues re "." or "," in StrF() possibly clashing with SQLite standards
  ; MaxAbsSample = MaxSample * 10000
  sSQLRequest = "CREATE TABLE FileStats(" +
                "FileName TEXT NOT NULL, FileModified TEXT, FileSize INT, FileDuration INT," +
                " SilenceStartAt INT, SilenceEndAt INT, M75dBStartAt INT, M75dBEndAt INT, M60dBStartAt INT, M60dBEndAt INT, M45dBStartAt INT, M45dBEndAt INT, M30dBStartAt INT, M30dBEndAt INT," +
                " MaxAbsSample INT," + ; see comment above
                " UNIQUE (FileName))"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  
EndProcedure

Procedure createTableProgSldrs(nDatabaseNo)
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the ProgSldrs table
  ; NormalizeFactorInt stored as INT to avoid any localisation issues re "." or "," in StrF() possibly clashing with SQLite standards
  ; NormalizeFactorInt = NormalizeFactor * 1000
  sSQLRequest = "CREATE TABLE ProgSldrs(" +
                "FileName TEXT NOT NULL, FileModified TEXT, FileSize INT, GraphWidth INT, GraphChannels INT, AbsMin INT, AbsMax INT, MaxPeak INT, NormalizeFactorInt INT, SldrBlob BLOB, SldrBlobSize INT, DBVersion INT," +
                " UNIQUE (FileName, GraphWidth, GraphChannels, AbsMin, AbsMax))"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  
EndProcedure

Procedure createTableImageData(nDatabaseNo)
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the ImageData table
  ; ImageBlobSize only kept for diagnostic purposes because 'SQLite Database Browser' doesn't report blob size - in fact it doesn't handle blobs very well at all.
  sSQLRequest = "CREATE TABLE ImageData(" +
                "FileName TEXT NOT NULL, FileModified TEXT, FileSize INT, Width INT, Height INT, SizeEtc TEXT, FilePos INT, ShellThumbnail INT, ImageBlob BLOB, ImageBlobSize INT, DBVersion INT," +
                " UNIQUE (FileName, Width, Height, SizeEtc, FilePos))"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  
EndProcedure

Procedure createTableImageFrames(nDatabaseNo)
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the ImageFrames table
  ; ImageBlobSize only kept for diagnostic purposes because 'SQLite Database Browser' doesn't report blob size - in fact it doesn't handle blobs very well at all.
  sSQLRequest = "CREATE TABLE ImageFrames(" +
                "FileId INT, TargetWidth INT, TargetHeight INT, FrameIndex INT, FrameDelay INT, FileName TEXT, ImageBlob BLOB, ImageBlobSize INT," +
                " UNIQUE (FileId, TargetWidth, TargetHeight, FrameIndex))"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  
EndProcedure

Procedure createTableCueStartDMXSave(nDatabaseNo)
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the CueStartDMXSave table (only held in the temp database)
  ; DMXBlobSize only kept for diagnostic purposes because 'SQLite Database Browser' doesn't report blob size - in fact it doesn't handle blobs very well at all.
  sSQLRequest = "CREATE TABLE CueStartDMXSave(" +
                "PlayCue TEXT NOT NULL, DMXSaveBlob BLOB, DMXSaveBlobSize INT)"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  
EndProcedure

Procedure createTablePlaylistOrder(nDatabaseNo)
  PROCNAMEC()
  Protected sSQLRequest.s
  
  ; create the PlaylistOrder table
  sSQLRequest = "CREATE TABLE PlaylistOrder(" +
                "PlaylistCue TEXT NOT NULL, PlaylistSubNo INT, ListOrder TEXT, LastPlayed INT," +
                " UNIQUE (PlaylistCue, PlaylistSubNo))"
  doDatabaseUpdate(nDatabaseNo, sSQLRequest)
  
EndProcedure

Procedure loadPlaylistOrderFromDatabase(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sRequest.s
  Protected nDatabaseNo
  Protected nListCount
  Protected bInfoFound
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bPLDatabaseInfoLoaded = #False
        \sPLListOrder = grSubDef\sPLListOrder
        \nPLAudNoLastPlayed = grSubDef\nPLAudNoLastPlayed
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nPLAudNoLastPlayed=" + \nPLAudNoLastPlayed)
        If IsDatabase(grProd\nDatabaseNo) = #False
          openProdDatabase()
        EndIf
        debugMsg(sProcName, "grProd\nDatabaseNo=" + grProd\nDatabaseNo)
        nDatabaseNo = grProd\nDatabaseNo
        If IsDatabase(nDatabaseNo)
          sRequest = "SELECT ListOrder, LastPlayed" +
                     " FROM PlaylistOrder WHERE PlaylistCue = '" + RepQuote(\sCue) + "' AND PlaylistSubNo = " + \nSubNo
          If DatabaseQuery(nDatabaseNo, sRequest)
            If NextDatabaseRow(nDatabaseNo)
              \sPLListOrder = Trim(GetDatabaseString(nDatabaseNo, 0))  ; nb may be blank for non-random playlists
              \nPLAudNoLastPlayed = GetDatabaseLong(nDatabaseNo, 1)
              debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nPLAudNoLastPlayed=" + \nPLAudNoLastPlayed)
              If \bPLRandom
                If \sPLListOrder
                  nListCount = CountString(\sPLListOrder, ",") + 1
                EndIf
                debugMsg(sProcName, "\bPLRandom=" + strB(\bPLRandom) + ", \sPLListOrder=" + #DQUOTE$ + \sPLListOrder + #DQUOTE$ + ", \nPLAudNoLastPlayed=" + \nPLAudNoLastPlayed + ", nListCount=" + nListCount + ", \nAudCount=" + \nAudCount)
                If (nListCount = \nAudCount) Or (nListCount = 0) ; nb as mentioned above, \sPLListOrder may be blank, in which case nListCount will be zero
                  bInfoFound = #True
                EndIf
              Else  ; not random so no need to check \sPLListOrder
                debugMsg(sProcName, "\bPLRandom=" + strB(\bPLRandom) + ", \nPLAudNoLastPlayed=" + \nPLAudNoLastPlayed + ", \nAudCount=" + \nAudCount)
                If \nPLAudNoLastPlayed <= \nAudCount
                  bInfoFound = #True
                EndIf
              EndIf
              If bInfoFound = #False
                ; if we get here then the number of files in the playlist sub-cue must have been changed since the info was last saved to the production database
                \sPLListOrder = grSubDef\sPLListOrder
                \nPLAudNoLastPlayed = grSubDef\nPLAudNoLastPlayed
                debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nPLAudNoLastPlayed=" + \nPLAudNoLastPlayed)
              EndIf
            EndIf
            FinishDatabaseQuery(nDatabaseNo)
          EndIf
        Else
          debugMsg(sProcName, "IsDatabase(" + nDatabaseNo + ") returned #False")
        EndIf
        \bPLDatabaseInfoLoaded = #True
        \nPlayOrderAudNo = \nPLAudNoLastPlayed
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bInfoFound))
  ProcedureReturn bInfoFound
  
EndProcedure

Procedure savePlaylistOrdersToProdDatabase()
  PROCNAMEC()
  Protected sSQLRequest.s, nSQLResult
  Protected nDatabaseNo
  Protected i, j
  Protected nLastPlayed
  Protected nBracketPos, sMyPlayOrder.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nDatabaseNo)
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeP
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          With aSub(j)
            If \bSubTypeP
              ; delete any existing row for this playlist
              sSQLRequest = "DELETE FROM PlaylistOrder WHERE PlaylistCue = '" + RepQuote(\sCue) + "'" + " AND PlaylistSubNo = " + \nSubNo
              nSQLResult = DatabaseUpdate(nDatabaseNo, sSQLRequest)
              debugMsg2(sProcName, "sSQLRequest=" + sSQLRequest, nSQLResult)
              If \bPLSavePos
                sMyPlayOrder = \sPlayOrder
                nBracketPos = FindString(sMyPlayOrder, "(") ; will be present if "(repeat)" included at the end of \sPlayOrder
                If nBracketPos > 0
                  sMyPlayOrder = Trim(Left(sMyPlayOrder, nBracketPos-1))
                EndIf
                ; This saves both the play order (eg "17,16,9,8,12,14,5,3,2,6,18,4,10,15,13,1,11,7"),
                ; and also the nAudNo of the audio file last played in this playlist (eg 7).
                ; If this playlist has not been played this run, then the values saved (if the procedure has been called)
                ; will be unchanged as they will be resaved with the values loaded by loadPlaylistOrderFromDatabase().
                sSQLRequest = "INSERT INTO PlaylistOrder" +
                              " (PlaylistCue, PlaylistSubNo, ListOrder, LastPlayed) " +
                              "VALUES (" + "'" + RepQuote(\sCue) + "', " + \nSubNo + ", '" + RemoveString(RepQuote(sMyPlayOrder), " ") + "', " + \nPlayOrderAudNo + ")"
                nSQLResult = doDatabaseUpdate(nDatabaseNo, sSQLRequest)
              EndIf
            EndIf
            j = \nNextSubIndex
          EndWith
        Wend
      EndIf
    Next i
  EndIf
  
  ; Moved here 4Jul2023 11.10.0bn - was in writeXMLCueFile()
  gbUnsavedPlaylistOrderInfo = #False
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  ; End moved here 4Jul2023 11.10.0bn
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createTempDatabase()
  PROCNAMEC()
  Protected sSQLRequest.s
  Protected sMsg.s
  Protected bCreateOrOpenFailed
  Protected sError.s
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  With grTempDB
    While \bTempDatabaseOpen = #False
      bCreateOrOpenFailed = #False
      \sTempDatabaseFile = gsAppDataPath + "scs11tempdb.scsdb"
      gnNextFileNo + 1
      If CreateFile(gnNextFileNo, \sTempDatabaseFile)
        debugMsg(sProcName, "database file created: " + \sTempDatabaseFile)
        CloseFile(gnNextFileNo)
      Else
        debugMsg(sProcName, "cannot create the database file " + \sTempDatabaseFile)
        bCreateOrOpenFailed = #True
      EndIf
      
      If bCreateOrOpenFailed = #False
        gnNextDatabaseNo + 1
        \nTempDatabaseNo = gnNextDatabaseNo
        If OpenDatabase(\nTempDatabaseNo, \sTempDatabaseFile, "", "")
          debugMsg(sProcName, "temp database opened ok")
          \bTempDatabaseOpen = #True
          ; create the tables
          createTableFileData(\nTempDatabaseNo)
          createTableProgSldrs(\nTempDatabaseNo)
          createTableImageData(\nTempDatabaseNo)
          createTableFileStats(\nTempDatabaseNo)
          createTableImageFrames(\nTempDatabaseNo)
          createTableCueStartDMXSave(\nTempDatabaseNo) ; this table is only required in the temp database
        Else
          sError = DatabaseError()
          debugMsg(sProcName, "cannot open temp database. error: " + sError)
          bCreateOrOpenFailed = #True
        EndIf
      EndIf
      
      If bCreateOrOpenFailed
        sMsg = LangPars("Errors", "CannotCreateTempDatabase", \sTempDatabaseFile)
        debugMsg(sProcName, sMsg)
        nResponse = MessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
        If nResponse = #PB_MessageRequester_No
          End
        EndIf
      EndIf
      
    Wend
    
  EndWith
  ProcedureReturn #True
  
EndProcedure

Procedure openProdDatabase()
  PROCNAMEC()
  Protected sSQLRequest.s
  Protected nTempDatabaseNo, nProdDatabaseNo
  Protected nResult
  Protected bOpenedProdDatabase
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grProd
    If Len(\sDatabaseFile) = 0
      If \bTemplate
        \sDatabaseFile = ignoreExtension(gsTemplateFile) + ".scsdb"
      Else
        \sDatabaseFile = ignoreExtension(gsCueFile) + ".scsdb"
      EndIf
    EndIf
    If FileExists(\sDatabaseFile)
      If IsDatabase(\nDatabaseNo)
        bOpenedProdDatabase = #True
      Else
        gnNextDatabaseNo + 1
        nProdDatabaseNo = gnNextDatabaseNo
        nResult = OpenDatabase(nProdDatabaseNo, \sDatabaseFile, "", "")
        If nResult
          \nDatabaseNo = nProdDatabaseNo
          bOpenedProdDatabase = #True
        EndIf
      EndIf
    EndIf
  EndWith
  
  If bOpenedProdDatabase = #False
    debugMsg(sProcName, #SCS_END + ", returning bOpenedProdDatabase=" + strB(bOpenedProdDatabase))
  EndIf
  ProcedureReturn bOpenedProdDatabase
  
EndProcedure

Procedure loadTempDatabaseFromProdDatabase()
  PROCNAMEC()
  Protected sSQLRequest.s
  Protected nTempDatabaseNo, nProdDatabaseNo
  Protected nResult
  Protected bOpenedProdDatabase
  Protected qDatabaseSize.q
  Protected bDisplayInfoMsgs
  
  ; debugMsg(sProcName, #SCS_START)
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  If IsDatabase(nTempDatabaseNo)
    ; check if a prod database exists and if so then populate the temp database tables from the prod database
    With grProd
      bOpenedProdDatabase = openProdDatabase()
      If bOpenedProdDatabase
        nProdDatabaseNo = grProd\nDatabaseNo
        sSQLRequest = "ATTACH DATABASE '" + RepQuote(\sDatabaseFile) + "' AS proddb"
        doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
        
        copyTableFromProdDatabaseToTempDatabase("FileData")
        copyTableFromProdDatabaseToTempDatabase("ImageData")
        copyTableFromProdDatabaseToTempDatabase("ProgSldrs")
        copyTableFromProdDatabaseToTempDatabase("FileStats")
        ; now populate the array gaFileStats() from the FileStats table
        loadFileStatsArrayFromProdDatabase()
        
        grTempDB\bTempDatabaseLoaded = #True
        grTempDB\bTempDatabaseChanged = #False
        
        CloseDatabase(nProdDatabaseNo)
        
        sSQLRequest = "DETACH DATABASE proddb"
        doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
        
        ; debugMsg(sProcName, "calling setFileStatsPtrs()")
        setFileStatsPtrs()
        
        ; debugMsg(sProcName, "calling setPeakAndMinDataPopulateStates()")
        setPeakAndMinDataPopulateStates()
        
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setPeakAndMinDataPopulateStates()
  PROCNAMEC()
  Protected f
  
  debugMsg(sProcName, #SCS_START)
  
  For f = 1 To gnLastFileData
    gaFileData(f)\nSamplesArrayStatus = #SCS_SAP_NONE
    ; debugMsg(sProcName, "gaFileData(" + f + ")\nSamplesArrayStatus=#SCS_SAP_NONE")
  Next f
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createProdDatabase()
  PROCNAMEC()
  ; called when cue file saved - creates the production's database and populates the tables by copying tables from the temp database
  Protected sSQLRequest.s
  Protected sCueOrTemplateFile.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    If \bTemplate
      sCueOrTemplateFile = gsTemplateFile
    Else
      sCueOrTemplateFile = gsCueFile
    EndIf
    
    If sCueOrTemplateFile
      If FileExists(sCueOrTemplateFile)
        
        gnNextFileNo + 1
        \sDatabaseFile = ignoreExtension(sCueOrTemplateFile) + ".scsdb"
        If CreateFile(gnNextFileNo, \sDatabaseFile)
          debugMsg(sProcName, "database file created: " + \sDatabaseFile)
          CloseFile(gnNextFileNo)
        ElseIf 1=2 ; Changed from "Else" 4Jul2023 11.10.0bn
          debugMsg(sProcName, "cannot create the database file " + \sDatabaseFile)
          \sDatabaseFile = ""
          ProcedureReturn
        EndIf
        
        gnNextDatabaseNo + 1
        \nDatabaseNo = gnNextDatabaseNo
        If OpenDatabase(\nDatabaseNo, \sDatabaseFile, "", "")
          
          ; attach the temp database for use in 'copy' functions
          sSQLRequest = "ATTACH DATABASE '" + RepQuote(grTempDB\sTempDatabaseFile) + "' AS 'tempdb'"
          doDatabaseUpdate(\nDatabaseNo, sSQLRequest)
          
          ; create and populate the FileData table
          createTableFileData(\nDatabaseNo)
          copyFileDataToProdDatabase()
          
          ; create and populate the ProgSldrs table
          createTableProgSldrs(\nDatabaseNo)
          copyProgSldrsToProdDatabase()
          
          ; create and populate the ImageData table
          createTableImageData(\nDatabaseNo)
          copyImageDataToProdDatabase()
          
          ; create and populate the FileStats table
          createTableFileStats(\nDatabaseNo)
          copyFileStatsToProdDatabase()
          
          ; all temp database tables now copied to prod database, so clear the 'database changed' flag
          grTempDB\bTempDatabaseChanged = #False
          
          If \bTemplate = #False
            createTablePlaylistOrder(\nDatabaseNo)
            savePlaylistOrdersToProdDatabase()  ; saved directly from aSub() etc, not copied from the temp database
          EndIf
          
          ; close the production database
          CloseDatabase(\nDatabaseNo)
          
        Else
          debugMsg(sProcName, "OpenDatabase(" + \nDatabaseNo + ", " + #DQUOTE$ + \sDatabaseFile + #DQUOTE$ + ", '', '') failed")
          debugMsg(sProcName, "DatabaseError() returned " + DatabaseError())
        EndIf
        
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createProdDatabaseIfReqd()
  PROCNAMEC()
  Protected sSQLRequest.s
  Protected sCueOrTemplateFile.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    debugMsg(sProcName, "grProd\sDatabaseFile=" + #DQUOTE$ + \sDatabaseFile + #DQUOTE$ + ", \nDatabaseNo=" + \nDatabaseNo)
    If (Len(\sDatabaseFile) = 0) Or (FileExists(\sDatabaseFile) = #False)
      If \bTemplate
        sCueOrTemplateFile = gsTemplateFile
      Else
        sCueOrTemplateFile = gsCueFile
      EndIf
      If sCueOrTemplateFile
        If FileExists(sCueOrTemplateFile)
          \sDatabaseFile = ignoreExtension(sCueOrTemplateFile) + ".scsdb"
          gnNextFileNo + 1
          If CreateFile(gnNextFileNo, \sDatabaseFile)
            debugMsg(sProcName, "database file created: " + \sDatabaseFile)
            CloseFile(gnNextFileNo)
          Else
            debugMsg(sProcName, "cannot create the database file " + \sDatabaseFile)
            \sDatabaseFile = ""
            ProcedureReturn
          EndIf
          gnNextDatabaseNo + 1
          \nDatabaseNo = gnNextDatabaseNo
          If OpenDatabase(\nDatabaseNo, \sDatabaseFile, "", "")
            createTableFileData(\nDatabaseNo)
            createTableProgSldrs(\nDatabaseNo)
            createTableImageData(\nDatabaseNo)
            createTableFileStats(\nDatabaseNo)
            If \bTemplate = #False
              createTablePlaylistOrder(\nDatabaseNo)
            EndIf
            CloseDatabase(\nDatabaseNo)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure saveProgSldrGraphToTempDatabase(*rMG.tyMG, *mPeakAndMinData, nMemorySize, fNormalizeFactor.f, nGraphWidth)
  PROCNAMEC()
  Protected nResult
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected nGraphChannels
  Protected nAudPtr
  Protected qFileSize.q, sFileModified.s
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START + ", *rMG\sMGNumber=" + *rMG\sMGNumber + ", *mPeakAndMinData=" + *mPeakAndMinData + ", nMemorySize=" + nMemorySize +
                      ", fNormalizeFactor=" + StrF(fNormalizeFactor.f,4) + ", nGraphWidth=" + nGraphWidth)
  
  LockTempDatabaseMutex(1)
  
  If grTempDB\bTempDatabaseLoaded = #False
    debugMsg(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  nAudPtr = *rMG\nAudPtr
  debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr))
  If nAudPtr >= 0
    With aAud(nAudPtr)
      If (\sFileName) And (\bAudPlaceHolder = #False)
        nGraphChannels = \nFileChannels
        ; delete any existing row for this file, with the same abs min and abs max positions (see also table's unique constraint)
        sSQLRequest = "DELETE FROM ProgSldrs WHERE FileName = '" + RepQuote(\sFileName) + "'" +
                      " AND GraphChannels = " + nGraphChannels +
                      " AND AbsMin = " + \nAbsMin +
                      " AND AbsMax = " + \nAbsMax
        nResult = DatabaseUpdate(nTempDatabaseNo, sSQLRequest)
        debugMsg2(sProcName, "sSQLRequest=" + sSQLRequest, nResult)
        
        ; create a new row for this file
        SetDatabaseBlob(nTempDatabaseNo, 0, *mPeakAndMinData, nMemorySize)
debugMsg(sProcName, "SetDatabaseBlob(" + nTempDatabaseNo + ", 0, *mPeakAndMinData, " + nMemorySize + ")")
        qFileSize = FileSize(\sFileName)
        sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(\sFileName, #PB_Date_Modified))
        sSQLRequest = "INSERT INTO ProgSldrs "
        sSQLRequest + "(FileName, FileModified, FileSize, GraphWidth, GraphChannels, AbsMin, AbsMax, MaxPeak, NormalizeFactorInt, SldrBlob, SldrBlobSize, DBVersion)"
        sSQLRequest + " VALUES ("
        sSQLRequest + "'" + RepQuote(\sFileName) + "', "
        sSQLRequest + "'" + RepQuote(sFileModified) + "', "
        sSQLRequest + Str(qFileSize) + ", "
        sSQLRequest + Str(nGraphWidth) + ", "
        sSQLRequest + Str(nGraphChannels) + ", "
        sSQLRequest + Str(\nAbsMin) + ", "
        sSQLRequest + Str(\nAbsMax) + ", "
        sSQLRequest + Str(#SCS_GRAPH_MAX_PEAK) + ", "
        sSQLRequest + Str(fNormalizeFactor * 1000) + ", "
        sSQLRequest + "?, " + Str(nMemorySize) + ", " + #SCS_DATABASE_VERSION + ")" ; ? for SldrBlob
        doDatabaseUpdate(nTempDatabaseNo, sSQLRequest, #True)
        
        grTempDB\bTempDatabaseChanged = #True
        
      EndIf
      
    EndWith
  EndIf
  
  UnlockTempDatabaseMutex()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure saveGraphDataToTempDatabase(nFileDataPtr, *mSlicePeakAndMinData, nMemorySize, fNormalizeFactor.f, nGraphWidth, nGraphChannels, nViewStart, nViewEnd)
  PROCNAMEC()
  Protected nResult
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START + ", nFileDataPtr=" + nFileDataPtr + ", nMemorySize=" + nMemorySize + ", fNormalizeFactor=" + StrF(fNormalizeFactor,4) +
                      ", nGraphWidth=" + nGraphWidth + ", nGraphChannels=" + nGraphChannels +
                      ", nViewStart=" + nViewStart + ", nViewEnd=" + nViewEnd)
  
  LockTempDatabaseMutex(2)
  
  If grTempDB\bTempDatabaseLoaded = #False
    debugMsg(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  If nFileDataPtr >= 0
    With gaFileData(nFileDataPtr)
      If (\sFileName) And (\sFileName <> grText\sTextPlaceHolder)
        ; delete any existing row for this file and display fields (see also table's unique constraint)
        sSQLRequest = "DELETE FROM FileData where FileName = '" + RepQuote(\sFileName) + "'" +
                      " AND GraphWidth = " + nGraphWidth +
                      " AND GraphChannels = " + nGraphChannels +
                      " AND ViewStart = " + nViewStart +
                      " AND ViewEnd = " + nViewEnd
        nResult = DatabaseUpdate(nTempDatabaseNo, sSQLRequest)
        debugMsg2(sProcName, "sSQLRequest=" + sSQLRequest, nResult)
        
        ; create a new row for this file
        SetDatabaseBlob(nTempDatabaseNo, 0, *mSlicePeakAndMinData, nMemorySize)
debugMsg(sProcName, "SetDatabaseBlob(" + nTempDatabaseNo + ", 0, *mSlicePeakAndMinData, " + nMemorySize + ")")
        ; commented out the following two tests as the file may have been edited externally since data initially loaded and so these values may have changed
        ; If \qFileSize = 0
        \qFileSize = FileSize(\sFileName)
        ; EndIf
        ; If Len(\sFileModified) = 0
        \sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(\sFileName, #PB_Date_Modified))
        ; EndIf
        sSQLRequest = "INSERT INTO FileData "
        sSQLRequest + "(FileName, FileModified, FileSize, GraphWidth, ViewStart, ViewEnd, GraphChannels, MaxPeak, NormalizeFactorInt, FileBlob, FileBlobSize, DBVersion)"
        sSQLRequest + " VALUES ("
        sSQLRequest + "'" + RepQuote(\sFileName) + "', "
        sSQLRequest + "'" + RepQuote(\sFileModified) + "', "
        sSQLRequest + \qFileSize + ", "
        sSQLRequest + nGraphWidth + ", "
        sSQLRequest + nViewStart + ", "
        sSQLRequest + nViewEnd + ", "
        sSQLRequest + nGraphChannels + ", "
        sSQLRequest + #SCS_GRAPH_MAX_PEAK + ", "
        sSQLRequest + Str(fNormalizeFactor * 1000) + ", "
        sSQLRequest + "?, " + nMemorySize + ", " + #SCS_DATABASE_VERSION + ")" ; ? for FileBlob
        doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
        
        grTempDB\bTempDatabaseChanged = #True
        
      EndIf
      
    EndWith
  EndIf
  
  UnlockTempDatabaseMutex()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure readFileBlob(*rMG.tyMG, nFileDataPtr)
  PROCNAMEC()
  Protected nResult
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected bLockedMutex
  Protected nBlobSize
  
  ; debugMsg(sProcName, #SCS_START + ", nFileDataPtr=" + nFileDataPtr)
  
  If nFileDataPtr >= 0
    With gaFileData(nFileDataPtr)
      If \sFileName
        If \bForceReadFileBlob = #False
          If (grFileBlobInfo\sFileName = \sFileName) And (grFileBlobInfo\sFileModified = \sFileModified) And (grFileBlobInfo\qFileSize = \qFileSize) And
             (grFileBlobInfo\nGraphWidth = *rMG\nGraphWidth) And (grFileBlobInfo\nGraphChannels = *rMG\nGraphChannels) And (grFileBlobInfo\nMaxPeak = #SCS_GRAPH_MAX_PEAK) And
             (\fNormalizeFactor <> grFileDataDef\fNormalizeFactor) And (*gmFileBlob)
            ; file blob already loaded
            debugMsg(sProcName, "exiting because file already loaded: " + grFileBlobInfo\sFileName)
            ProcedureReturn #True
          EndIf
        Else
          ; skipped the above test, so we can now clear this boolean
          \bForceReadFileBlob = #False
        EndIf
        
        nTempDatabaseNo = grTempDB\nTempDatabaseNo
        
        LockTempDatabaseMutex(3)
        
        ; read row for this file
        sSQLRequest = "SELECT FileBlob, NormalizeFactorInt FROM FileData "
        sSQLRequest + "WHERE FileName = '" + RepQuote(\sFileName) + "' "
        sSQLRequest + "AND FileModified = '" + RepQuote(\sFileModified) + "' "
        sSQLRequest + "AND FileSize = " + \qFileSize + " "
        sSQLRequest + "AND GraphWidth = " + *rMG\nGraphWidth + " "
        sSQLRequest + "AND GraphChannels = " + *rMG\nGraphChannels + " "
        sSQLRequest + "AND MaxPeak = " + Str(#SCS_GRAPH_MAX_PEAK) + " "
        sSQLRequest + "LIMIT 1"
        ; debugMsg(sProcName, "(T) sSQLRequest=" + sSQLRequest)
        If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
          If NextDatabaseRow(nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
            nBlobSize = DatabaseColumnSize(grTempDB\nTempDatabaseNo, 0)
            If nBlobSize > 0
              ; store blob etc
              If *gmFileBlob
                ; free memory for the previous use of this area
                FreeMemory(*gmFileBlob)
                *gmFileBlob = 0
              EndIf
              grFileBlobInfo\sFileName = \sFileName
              grFileBlobInfo\sFileModified = \sFileModified
              grFileBlobInfo\qFileSize = \qFileSize
              grFileBlobInfo\nGraphWidth = *rMG\nGraphWidth
              grFileBlobInfo\nGraphChannels = *rMG\nGraphChannels
              ; debugMsg(sProcName, "grFileBlobInfo\nGraphChannels=" + grFileBlobInfo\nGraphChannels)
              grFileBlobInfo\nMaxPeak = #SCS_GRAPH_MAX_PEAK
              \fNormalizeFactor = GetDatabaseLong(nTempDatabaseNo, 1) / 1000
              ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\fNormalizeFactor=" + StrF(\fNormalizeFactor, 3))
              *gmFileBlob = AllocateMemory(nBlobSize, #PB_Memory_NoClear)
              ; debugMsg(sProcName, "AllocateMemory(" + nBlobSize + ", #PB_Memory_NoClear) returned *gmFileBlob=" + *gmFileBlob)
              If *gmFileBlob = 0
                ; debugMsg(sProcName, "AllocateMemory(" + nBlobSize + ", #PB_Memory_NoClear) failed")
                FinishDatabaseQuery(nTempDatabaseNo)
                UnlockTempDatabaseMutex()
                ProcedureReturn #False
              Else
                ; debugMsg(sProcName, "MemorySize(*gmFileBlob)=" + MemorySize(*gmFileBlob))
              EndIf
              nResult = GetDatabaseBlob(nTempDatabaseNo, 0, *gmFileBlob, nBlobSize)
              ; debugMsg(sProcName, "GetDatabaseBlob(" + nTempDatabaseNo + ", 0, *gmFileBlob, " + nBlobSize + ") returned " + nResult)
            EndIf
            
          Else
            debugMsg(sProcName, "no row found")
            FinishDatabaseQuery(nTempDatabaseNo)
            UnlockTempDatabaseMutex()
            ProcedureReturn #False
            
          EndIf
          FinishDatabaseQuery(nTempDatabaseNo)
          
        Else
          debugMsg(sProcName, "DatabaseQuery() failed")
          FinishDatabaseQuery(nTempDatabaseNo)
          UnlockTempDatabaseMutex()
          ProcedureReturn #False
          
        EndIf
        
        UnlockTempDatabaseMutex()
        
      EndIf
      
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure readProgSldrGraphFromTempDatabase(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nResult
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected bLockedMutex
  Protected nBlobSize
  Protected sFileName.s
  Protected qFileSize.q, sFileModified.s
  Protected bRowFound
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", grTempDB\nTempDatabaseNo=" + grTempDB\nTempDatabaseNo)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      sFileName = \sFileName
      If (sFileName) And (\bAudPlaceHolder = #False)
        
        nTempDatabaseNo = grTempDB\nTempDatabaseNo
        
        ; added 19Oct2019 11.8.2bb - may be #False during closedown
        If IsDatabase(nTempDatabaseNo) = 0
          ProcedureReturn #False
        EndIf
        ; end added 19Oct2019 11.8.2bb
        
        LockTempDatabaseMutex(5)
        
        ; read row for this file
        qFileSize = FileSize(sFileName)
        sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
        sSQLRequest = "SELECT SldrBlob, NormalizeFactorInt FROM ProgSldrs" +
                      " WHERE FileName = '" + RepQuote(sFileName) + "'" +
                      " AND FileModified = '" + RepQuote(sFileModified) + "'" +
                      " AND FileSize = " + qFileSize +
                      " AND GraphWidth = " + grMG3\nGraphWidth +
                      " AND GraphChannels = " + grMG3\nGraphChannels +
                      " AND AbsMin = " + \nAbsMin +
                      " AND AbsMax = " + \nAbsMax +
                      " AND MaxPeak = " + #SCS_GRAPH_MAX_PEAK +
                      " LIMIT 1"
        debugMsgC(sProcName, "(T) sSQLRequest=" + sSQLRequest)
        If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
          debugMsgC(sProcName, "DatabaseQuery() successful")
          If NextDatabaseRow(nTempDatabaseNo)
            bRowFound = #True
          EndIf
          If bRowFound = #False
            FinishDatabaseQuery(nTempDatabaseNo)
            ; Added 14Jun2021 11.8.5aj, along with associated bRowFound code
            ; try again ignoring the GraphChannels check (following test using cue that used a stereo file played to a mono output)
            sSQLRequest = "SELECT SldrBlob, NormalizeFactorInt FROM ProgSldrs" +
                          " WHERE FileName = '" + RepQuote(sFileName) + "'" +
                          " AND FileModified = '" + RepQuote(sFileModified) + "'" +
                          " AND FileSize = " + qFileSize +
                          " AND GraphWidth = " + grMG3\nGraphWidth +
                          " AND AbsMin = " + \nAbsMin +
                          " AND AbsMax = " + \nAbsMax +
                          " AND MaxPeak = " + #SCS_GRAPH_MAX_PEAK +
                          " LIMIT 1"
            debugMsgC(sProcName, "(T) sSQLRequest=" + sSQLRequest)
            If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
              debugMsgC(sProcName, "DatabaseQuery() successful")
              If NextDatabaseRow(nTempDatabaseNo)
                bRowFound = #True
              EndIf
            EndIf
            ; End added 14Jun2021 11.8.5aj, along with associated bRowFound code
          EndIf
          If bRowFound
            debugMsgC(sProcName, "row found")
            nBlobSize = DatabaseColumnSize(grTempDB\nTempDatabaseNo, 0)
            debugMsgC(sProcName, "nBlobSize=" + nBlobSize + ", *gmSldrBlob=" + *gmSldrBlob)
            If nBlobSize > 0
              If *gmSldrBlob
                If MemorySize(*gmSldrBlob) < nBlobSize
                  FreeMemory(*gmSldrBlob)
                  *gmSldrBlob = AllocateMemory(nBlobSize, #PB_Memory_NoClear)
                EndIf
              Else
                *gmSldrBlob = AllocateMemory(nBlobSize, #PB_Memory_NoClear)
              EndIf
              If *gmSldrBlob = 0
                debugMsg(sProcName, "AllocateMemory(" + nBlobSize + ", #PB_Memory_NoClear) failed")
                FinishDatabaseQuery(nTempDatabaseNo)
                UnlockTempDatabaseMutex()
                ProcedureReturn #False
              EndIf
              grSldrBlobInfo\nAudPtr = pAudPtr
              grSldrBlobInfo\nAbsMin = \nAbsMin
              grSldrBlobInfo\nAbsMax = \nAbsMax
              grSldrBlobInfo\sFileName = \sFileName
              If \nFileDataPtr >= 0
                grSldrBlobInfo\sFileModified = gaFileData(\nFileDataPtr)\sFileModified
                grSldrBlobInfo\qFileSize = gaFileData(\nFileDataPtr)\qFileSize
              EndIf
              grSldrBlobInfo\nGraphWidth = grMG3\nGraphWidth
              grSldrBlobInfo\nGraphChannels = grMG3\nGraphChannels
              debugMsgC(sProcName, "grSldrBlobInfo\nGraphChannels=" + grSldrBlobInfo\nGraphChannels)
              grSldrBlobInfo\nMaxPeak = #SCS_GRAPH_MAX_PEAK
              debugMsgC(sProcName, "calling GetDatabaseLong(" + nTempDatabaseNo + ", 1)")
              grSldrBlobInfo\fNormalizeFactor = GetDatabaseLong(nTempDatabaseNo, 1) / 1000
              
              debugMsgC(sProcName, "calling GetDatabaseBlob(" + nTempDatabaseNo + ", 0, " + *gmSldrBlob + ", " + nBlobSize + ")")
              nResult = GetDatabaseBlob(nTempDatabaseNo, 0, *gmSldrBlob, nBlobSize)
              debugMsgC(sProcName, "GetDatabaseBlob(" + nTempDatabaseNo + ", 0, *gmSldrBlob, " + nBlobSize + ") returned " + nResult)
              
            EndIf
            
          Else
            debugMsgC(sProcName, "no row found")
            FinishDatabaseQuery(nTempDatabaseNo)
            UnlockTempDatabaseMutex()
            ProcedureReturn #False
            
          EndIf
          FinishDatabaseQuery(nTempDatabaseNo)
          
        Else
          debugMsg(sProcName, "DatabaseQuery() failed")
          FinishDatabaseQuery(nTempDatabaseNo)
          UnlockTempDatabaseMutex()
          ProcedureReturn #False
          
        EndIf
        
        UnlockTempDatabaseMutex()
        
      EndIf
      
    EndWith
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure readImageFromTempDatabase(sFileName.s, nWidth, nHeight, sSizeEtc.s, nFilePos, bTrace=#False)
  PROCNAMEC()
  Protected nResult
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected bLockedMutex
  Protected *mImageBlob
  Protected nBlobSize, bShellThumbnail
  Protected sFileModified.s, qFileSize.q
  
  debugMsgC(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName) + ", nWidth=" + nWidth + ", nHeight=" + nHeight + ", sSizeEtc=" + sSizeEtc + ", nFilePos=" + nFilePos)
  
  If Len(sFileName) = 0
    ProcedureReturn #False
  EndIf
  If FileExists(sFileName, #False) = #False
    ProcedureReturn #False
  EndIf
  
  If grTempDB\bTempDatabaseLoaded = #False
    debugMsgC(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  qFileSize = FileSize(sFileName)
  sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
  
  With grImageBlobInfo
    If (\sFileName = sFileName) And (\sFileModified = sFileModified) And (\qFileSize = qFileSize) And
       (\nWidth = nWidth) And (\nHeight = nHeight) And (\sSizeEtc = sSizeEtc) And (\nFilePos = nFilePos) And (IsImage(\nImageNo))
      ; image already loaded
      debugMsgC(sProcName, "exiting because image already loaded: " + sFileName)
      ProcedureReturn #True
    EndIf
    
    nTempDatabaseNo = grTempDB\nTempDatabaseNo
    
    LockTempDatabaseMutex(6)
    
    ; read row for this file
    sSQLRequest = "SELECT ImageBlob, ShellThumbnail FROM ImageData "
    sSQLRequest + "WHERE FileName = '" + RepQuote(sFileName) + "' "
    sSQLRequest + "AND FileModified = '" + RepQuote(sFileModified) + "' "
    sSQLRequest + "AND FileSize = " + qFileSize + " "
    sSQLRequest + "AND Width = " + nWidth + " "
    sSQLRequest + "AND Height = " + nHeight + " "
    sSQLRequest + "AND SizeEtc = '" + RepQuote(sSizeEtc) + "' "
    sSQLRequest + "AND FilePos = " + nFilePos + " "
    sSQLRequest + "AND DBVersion = " + #SCS_DATABASE_VERSION + " "
    sSQLRequest + "LIMIT 1"
    debugMsgC(sProcName, "(T) sSQLRequest=" + sSQLRequest)
    If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
      If NextDatabaseRow(nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
        nBlobSize = DatabaseColumnSize(grTempDB\nTempDatabaseNo, 0)
        If nBlobSize > 0
          \sFileName = sFileName
          \sFileModified = sFileModified
          \qFileSize = qFileSize
          \nWidth = nWidth
          \nHeight = nHeight
          \sSizeEtc = sSizeEtc
          \nFilePos = nFilePos
          \bShellThumbnail = GetDatabaseLong(grTempDB\nTempDatabaseNo, 1)
          If *mImageBlob
            FreeMemory(*mImageBlob)
            *mImageBlob = 0
          EndIf
          *mImageBlob = AllocateMemory(nBlobSize)
          If *mImageBlob = 0
            debugMsgC(sProcName, "AllocateMemory(" + nBlobSize + ") failed")
            FinishDatabaseQuery(nTempDatabaseNo)
            UnlockTempDatabaseMutex()
            ProcedureReturn #False
          EndIf
          If GetDatabaseBlob(nTempDatabaseNo, 0, *mImageBlob, nBlobSize)
            If IsImage(\nImageNo)
              ; free image previously created
              FreeImage(\nImageNo)
              \nImageNo = 0
            EndIf
            gnNextImageNo + 1
            If CatchImage(gnNextImageNo, *mImageBlob, nBlobSize)
              \nImageNo = gnNextImageNo
            EndIf
            debugMsgC(sProcName, "\nImageNo=" + \nImageNo)
          EndIf
          FreeMemory(*mImageBlob)
          *mImageBlob = 0
        EndIf
        
      Else
        debugMsgC(sProcName, "no row found")
        FinishDatabaseQuery(nTempDatabaseNo)
        UnlockTempDatabaseMutex()
        ProcedureReturn #False
        
      EndIf
      FinishDatabaseQuery(nTempDatabaseNo)
    EndIf
    
    UnlockTempDatabaseMutex()
    
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure saveImageDataToTempDatabase(pAudPtr, nImageNo, nFilePos=0, bTrace=#False)
  PROCNAMECA(pAudPtr)
  ; nFilePos used for videos where the start time (or thumbnail position time when implemented) is greater than 0
  Protected nResult
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected bLockedMutex
  Protected sFileName.s, nWidth, nHeight
  Protected *mImageBuffer
  Protected nMemorySize
  Protected qFileSize.q
  Protected sFileModified.s
  Protected sSizeEtc.s
  Protected bRowAlreadyExists
  
  debugMsgC(sProcName, #SCS_START)
  
  LockTempDatabaseMutex(7)
  
  If grTempDB\bTempDatabaseLoaded = #False
    debugMsgC(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  If IsDatabase(nTempDatabaseNo)
    If (pAudPtr >= 0) And (IsImage(nImageNo))
      sFileName = aAud(pAudPtr)\sFileName
      nWidth = ImageWidth(nImageNo)
      nHeight = ImageHeight(nImageNo)
      sSizeEtc = buildSizeEtc(pAudPtr)
      debugMsgC(sProcName, "sFileName=" + sFileName + ", nWidth=" + nWidth + ", nHeight=" + nHeight + ", nFilePos=" + Str(nFilePos))
      If sFileName
        qFileSize = FileSize(sFileName)
        sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
        
        ; check if a row already exists for this file with ALL the same column values
        sSQLRequest = "SELECT FileName FROM ImageData WHERE FileName = '" + RepQuote(sFileName) + "'"
        sSQLRequest + " AND FileModified = '" + RepQuote(sFileModified) + "'"
        sSQLRequest + " AND FileSize = " + qFileSize
        sSQLRequest + " AND Width = " + nWidth
        sSQLRequest + " AND Height = " + nHeight
        sSQLRequest + " AND SizeEtc = '" + RepQuote(sSizeEtc) + "'"
        sSQLRequest + " AND FilePos = " + nFilePos
        sSQLRequest + " LIMIT 1"
        debugMsgC(sProcName, "(T) sSQLRequest=" + sSQLRequest)
        If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
          If NextDatabaseRow(nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
            bRowAlreadyExists = #True
            debugMsgC(sProcName, "(SQL) row already exists")
          EndIf
        EndIf
        
        If bRowAlreadyExists = #False
          
          ; delete any existing row for this file and image dimensions (see also table's unique constraint)
          sSQLRequest = "DELETE FROM ImageData WHERE FileName = '" + RepQuote(sFileName) + "'"
          sSQLRequest + " AND Width = " + nWidth +
                        " AND Height = " + nHeight +
                        " AND SizeEtc = '" + RepQuote(sSizeEtc) + "'" +
                        " AND FilePos = " + nFilePos
          nResult = DatabaseUpdate(nTempDatabaseNo, sSQLRequest)
          
          ; create a new row for this file
          *mImageBuffer = EncodeImage(nImageNo, #PB_ImagePlugin_JPEG)
          debugMsgC2(sProcName, "EncodeImage(" + nImageNo + ")", *mImageBuffer)
          If *mImageBuffer
            nMemorySize = MemorySize(*mImageBuffer)
            If nMemorySize > 0
              SetDatabaseBlob(nTempDatabaseNo, 0, *mImageBuffer, nMemorySize)
              ; debugMsg(sProcName, "SetDatabaseBlob(" + nTempDatabaseNo + ", 0, *mImageBuffer, " + nMemorySize + ")")
              ; qFileSize = FileSize(sFileName)
              ; sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
              sSQLRequest = "INSERT INTO ImageData "
              sSQLRequest + "(FileName, FileModified, FileSize, Width, Height, SizeEtc, FilePos, ShellThumbnail, ImageBlob, ImageBlobSize, DBVersion)"
              sSQLRequest + " VALUES ("
              sSQLRequest + "'" + RepQuote(sFileName) + "', "
              sSQLRequest + "'" + RepQuote(sFileModified) + "', "
              sSQLRequest + qFileSize + ", "
              sSQLRequest + nWidth + ", "
              sSQLRequest + nHeight + ", "
              sSQLRequest + "'" + RepQuote(sSizeEtc) + "', "
              sSQLRequest + nFilePos + ", "
              sSQLRequest + aAud(pAudPtr)\bUsingShellThumbnail + ", "
              sSQLRequest + "?, " + nMemorySize + ", " + #SCS_DATABASE_VERSION + ")" ; ? for ImageBlob
              doDatabaseUpdate(nTempDatabaseNo, sSQLRequest, bTrace)
            EndIf
            FreeMemory(*mImageBuffer)
            gbUnsavedVideoImageData = #True
            grTempDB\bTempDatabaseChanged = #True
            setFileSave()
          EndIf
        EndIf
        
      EndIf ; EndIf sFileName
    EndIf ; EndIf (pAudPtr >= 0) And (IsImage(nImageNo))
  EndIf ; EndIf IsDatabase(nTempDatabaseNo)
  
  UnlockTempDatabaseMutex()
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure saveFileStatsToTempDatabase(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nTempDatabaseNo, sSQLRequest.s, nSQLResult
  Protected bLockedMutex
  Protected sFileName.s, qFileSize.q, sFileModified.s
  Protected nFileStatsPtr
  Protected bRowAlreadyExists
  
  ; debugMsg(sProcName, #SCS_START)
  
  LockTempDatabaseMutex(71)
  
  If grTempDB\bTempDatabaseLoaded = #False
    ; debugMsg(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  If IsDatabase(nTempDatabaseNo)
    If pAudPtr >= 0
      If (aAud(pAudPtr)\bAudPlaceHolder = #False) And (aAud(pAudPtr)\sFileName)
        sFileName = aAud(pAudPtr)\sFileName
        CompilerIf 1=2 ; 'CompilerIf' added 7Jul2023 11.10.0bq - replace the row anyway
          ; check if a row already exists for this file
          sSQLRequest = "SELECT FileName FROM FileStats WHERE FileName = '" + RepQuote(sFileName) + "'" + " LIMIT 1"
          debugMsg(sProcName, "(T) sSQLRequest=" + sSQLRequest)
          If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
            If NextDatabaseRow(nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
              bRowAlreadyExists = #True
              debugMsg(sProcName, "(SQL) row already exists")
            EndIf
          EndIf
          If bRowAlreadyExists = #False
            ; delete any existing row for this file
            sSQLRequest = "DELETE FROM FileStats WHERE FileName = '" + RepQuote(sFileName) + "'"
            nSQLResult = DatabaseUpdate(nTempDatabaseNo, sSQLRequest)
          EndIf
        CompilerElse
          ; delete any existing row for this file
          sSQLRequest = "DELETE FROM FileStats WHERE FileName = '" + RepQuote(sFileName) + "'"
          nSQLResult = DatabaseUpdate(nTempDatabaseNo, sSQLRequest)
        CompilerEndIf
        ; now create a new or replacement row for this file
        qFileSize = FileSize(sFileName)
        sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
        nFileStatsPtr = aAud(pAudPtr)\nFileStatsPtr
        If nFileStatsPtr >= 0
          With gaFileStats(nFileStatsPtr)
            ; check that nFileStatsPtr does point to the correct gaFileStats() entry before saving (btw, it should do!)
            If (sFileName = \sFileName) And (qFileSize = \qFileSize) And (sFileModified = \sFileModified)
              sSQLRequest = "INSERT INTO FileStats" +
                            " (FileName, FileModified, FileSize, FileDuration, SilenceStartAt, SilenceEndAt, " +
                            "M75dBStartAt, M75dBEndAt, M60dBStartAt, M60dBEndAt, M45dBStartAt, M45dBEndAt, M30dBStartAt, M30dBEndAt, MaxAbsSample) " +
                            "VALUES (" +
                            "'" + RepQuote(\sFileName) + "', " + "'" + RepQuote(\sFileModified) + "', " + \qFileSize + ", " + \nFileDuration + ", " +
                            \nSilenceStartAt + ", " + \nSilenceEndAt + ", " +
                            \nM75dBStartAt + ", " + \nM75dBEndAt + ", " +
                            \nM60dBStartAt + ", " + \nM60dBEndAt + ", " +
                            \nM45dBStartAt + ", " + \nM45dBEndAt + ", " +
                            \nM30dBStartAt + ", " + \nM30dBEndAt + ", " +
                            \nMaxAbsSample + ")"
              doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
              ; gbUnsavedFileStats = #True
              grTempDB\bTempDatabaseChanged = #True
              ;setFileSave()
            EndIf
          EndWith
        EndIf
      EndIf ; EndIf (aAud(pAudPtr)\bAudPlaceHolder = #False) And (aAud(pAudPtr)\sFileName)
    EndIf ; EndIf pAudPtr >= 0
  EndIf ; EndIf IsDatabase(nTempDatabaseNo)
  
  UnlockTempDatabaseMutex()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure compareTableStructures(sTableName.s)
  ; PROCNAMEC()
  Protected sSQLRequest.s
  Protected nDatabaseNo
  Protected sTempSQL.s, sProdSQL.s
  Protected bIdenticalStructures
  
  sSQLRequest = "SELECT sql FROM sqlite_master WHERE type = 'table' and tbl_name = '" + sTableName + "' LIMIT 1"
  ; debugMsg(sProcName, "sSQLRequest=" + sSQLRequest)
  
  nDatabaseNo = grTempDB\nTempDatabaseNo
  If IsDatabase(nDatabaseNo)
    If DatabaseQuery(nDatabaseNo, sSQLRequest)
      If NextDatabaseRow(nDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
        sTempSQL = GetDatabaseString(nDatabaseNo, 0)
      EndIf
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  
  nDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nDatabaseNo)
    If DatabaseQuery(nDatabaseNo, sSQLRequest)
      If NextDatabaseRow(nDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
        sProdSQL = GetDatabaseString(nDatabaseNo, 0)
      EndIf
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "sTempSQL=" + sTempSQL)
  ; debugMsg(sProcName, "sProdSQL=" + sProdSQL)
  
  If (sProdSQL) And (sProdSQL = sTempSQL)
    ; debugMsg(sProcName, "returning #True")
    ProcedureReturn #True
  Else
    ; debugMsg(sProcName, "returning #False")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure copyFileDataToProdDatabase()
  PROCNAMEC()
  Protected sSQLRequest.s, nSQLResult
  Protected nDatabaseNo, bFound
  Protected f, k, n, nSaveCount
  Structure tyMyFileDataFileInfo
    sFileName.s
    nViewStart.i
    nViewEnd.i
  EndStructure
  Protected rThisRow.tyMyFileDataFileInfo
  Protected Dim aKillRow.tyMyFileDataFileInfo(0)
  Protected nMaxKillRow = -1

  debugMsg(sProcName, #SCS_START)
  
  nDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nDatabaseNo)
    For f = 1 To gnLastFileData
      With gaFileData(f)
        \bSaveThisFile = #False
        For k = 1 To gnLastAud
          If aAud(k)\bExists
            If (aAud(k)\sFileName = \sFileName) And (aAud(k)\bAudPlaceHolder = #False)
              \bSaveThisFile = #True
              nSaveCount + 1
              Break ; Break k
            EndIf
          EndIf
        Next k
      EndWith
    Next f
    
    sSQLRequest = "SELECT FileName, ViewStart, ViewEnd FROM tempdb.FileData"
    If DatabaseQuery(nDatabaseNo, sSQLRequest)
      While NextDatabaseRow(nDatabaseNo)
        rThisRow\sFileName = GetDatabaseString(nDatabaseNo, 0)
        rThisRow\nViewStart = GetDatabaseLong(nDatabaseNo, 1)
        rThisRow\nViewEnd = GetDatabaseLong(nDatabaseNo, 2)
        ; check if this is still used
        bFound = #False
        For f = 1 To gnLastFileData
          With gaFileData(f)
            If (\bSaveThisFile) And (\sFileName = rThisRow\sFileName)
              If (rThisRow\nViewStart = 0) And (rThisRow\nViewEnd = \nFileDuration-1)
                bFound = #True
              Else
                For k = 1 To gnLastAud
                  If aAud(k)\bExists
                    If aAud(k)\nFileDataPtr = f
                      If (rThisRow\nViewStart = aAud(k)\nAbsStartAt) And (rThisRow\nViewEnd = aAud(k)\nAbsEndAt)
                        bFound = #True
                        Break 2 ; Break f
                      EndIf
                    EndIf
                  EndIf
                Next k
              EndIf
            EndIf
          EndWith
        Next f
        If bFound = #False
          ; debugMsg(sProcName, "not found")
          ; this row no longer required
          nMaxKillRow + 1
          If nMaxKillRow > ArraySize(aKillRow())
            ReDim aKillRow(nMaxKillRow+10)
          EndIf
          aKillRow(nMaxKillRow) = rThisRow
        EndIf
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
    ; having finished the database query, delete any rows no longer required
    ; debugMsg(sProcName, "nMaxKillRow=" + nMaxKillRow)
    For n = 0 To nMaxKillRow
      With aKillRow(n)
        sSQLRequest = "DELETE FROM tempdb.FileData WHERE FileName = '" + RepQuote(\sFileName) + "'" + " AND ViewStart=" + \nViewStart + " AND ViewEnd=" + \nViewEnd
        nSQLResult = doDatabaseUpdate(nDatabaseNo, sSQLRequest)
        ; debugMsg(sProcName, "n=" + n + ", nSQLResult=" + nSQLResult)
      EndWith
    Next n
    ; now copy the temp table to the prod database
    ; debugMsg(sProcName, "calling copyTableFromTempDatabaseToProdDatabase('FileData')")
    copyTableFromTempDatabaseToProdDatabase("FileData")
    
  EndIf
  
  ; debugMsg(sProcName, "calling listDatabaseFileData(grTempDB\nTempDatabaseNo)")
  ; listDatabaseFileData(grTempDB\nTempDatabaseNo)
  ; debugMsg(sProcName, "calling listDatabaseFileData(grProd\nDatabaseNo)")
  ; listDatabaseFileData(grProd\nDatabaseNo)
  
  debugMsg(sProcName, "calling findDuplicateFileDataRows(grProd\nDatabaseNo)")
  findDuplicateFileDataRows(grProd\nDatabaseNo)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure copyFileStatsToProdDatabase()
  PROCNAMEC()
  Protected nDatabaseNo, sSQLRequest.s, nSQLResult, bFound
  Protected i, j, k, n
  Structure tyMyFileStatsFileInfo
    sFileName.s
  EndStructure
  Protected rThisRow.tyMyFileStatsFileInfo
  Protected Dim aKillRow.tyMyFileStatsFileInfo(0)
  Protected nMaxKillRow = -1
  
  debugMsg(sProcName, #SCS_START)
  
  nDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nDatabaseNo)
    sSQLRequest = "SELECT FileName FROM tempdb.FileStats"
    If DatabaseQuery(nDatabaseNo, sSQLRequest)
      ; copy image rows from the temp database for images that are required
      While NextDatabaseRow(nDatabaseNo)
        rThisRow\sFileName = GetDatabaseString(nDatabaseNo, 0)
        ; check if this is still used
        bFound = #False
        For i = 1 To gnLastCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              With aAud(k)
                If \bAudPlaceHolder = #False
                  If aAud(k)\sFileName = rThisRow\sFileName
                    bFound = #True
                    ; debugMsg(sProcName, "found at aAud(" + getAudLabel(k) + ")")
                    Break 3 ; Break i
                  EndIf
                EndIf
                k = \nNextAudIndex
              EndWith
            Wend
            j = aSub(j)\nNextSubIndex
          Wend
        Next i
        If bFound = #False
          ; debugMsg(sProcName, "not found")
          ; this row no longer required
          nMaxKillRow + 1
          If nMaxKillRow > ArraySize(aKillRow())
            ReDim aKillRow(nMaxKillRow+10)
          EndIf
          aKillRow(nMaxKillRow) = rThisRow
        EndIf
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
    ; having finished the database query, delete any rows no longer required
    ; debugMsg(sProcName, "nMaxKillRow=" + nMaxKillRow)
    For n = 0 To nMaxKillRow
      With aKillRow(n)
        sSQLRequest = "DELETE FROM tempdb.FileStats WHERE FileName = '" + RepQuote(\sFileName) + "'"
        nSQLResult = doDatabaseUpdate(nDatabaseNo, sSQLRequest)
        ; debugMsg(sProcName, "n=" + n + ", nSQLResult=" + nSQLResult)
      EndWith
    Next n
    ; now copy the temp table to the prod database
    ; debugMsg(sProcName, "calling copyTableFromTempDatabaseToProdDatabase('FileStats')")
    copyTableFromTempDatabaseToProdDatabase("FileStats")
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure copyProgSldrsToProdDatabase()
  PROCNAMEC()
  ; this procedure was modified 19May2018 11.7.1aq to make it much faster to save the ProgSldr data,
  ; by removing any non-required rows from the Temp table (and there will be few if any of those),
  ; and then copying the resultant Temp table to the Prod database in one operation.
  ; previously, this procedure copied the table row-by-row.
  Protected nDatabaseNo, sSQLRequest.s, nSQLResult, bFound
  Protected i, j, k, n
  Structure tyMyProgSldrFileInfo
    sFileName.s
    nAbsMin.i
    nAbsMax.i
  EndStructure
  Protected rThisRow.tyMyProgSldrFileInfo
  Protected Dim aKillRow.tyMyProgSldrFileInfo(0)
  Protected nMaxKillRow = -1
  
  debugMsg(sProcName, #SCS_START)
  
  nDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nDatabaseNo)
    sSQLRequest = "SELECT FileName, AbsMin, AbsMax FROM tempdb.ProgSldrs"
    If DatabaseQuery(nDatabaseNo, sSQLRequest)
      While NextDatabaseRow(nDatabaseNo)
        rThisRow\sFileName = GetDatabaseString(nDatabaseNo, 0)
        rThisRow\nAbsMin = GetDatabaseLong(nDatabaseNo, 1)
        rThisRow\nAbsMax = GetDatabaseLong(nDatabaseNo, 2)
        ; check if this is still used
        bFound = #False
        For i = 1 To gnLastCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              With aAud(k)
                If \bAudPlaceHolder = #False
                  If (\sFileName = rThisRow\sFileName) And (\nAbsMin = rThisRow\nAbsMin) And (\nAbsMax = rThisRow\nAbsMax)
                    bFound = #True
                    ; debugMsg(sProcName, "found at aAud(" + getAudLabel(k) + ")")
                    Break 3 ; Break k, j, i
;                   ElseIf (\sFileName = rThisRow\sFileName)
;                     debugMsg(sProcName, "mismatch: aAud(" + getAudLabel(k) + ")\sFileName=" + #DQUOTE$ + GetFilePart(\sFileName) + #DQUOTE$ +
;                                         ", \nAbsMin=" + \nAbsMin + ", rThisRow\nAbsMin=" + rThisRow\nAbsMin +
;                                         ", \nAbsMax=" + \nAbsMax + ", rThisRow\nAbsMax=" + rThisRow\nAbsMax)
                  EndIf
                EndIf
                k = \nNextAudIndex
              EndWith
            Wend
            j = aSub(j)\nNextSubIndex
          Wend
        Next i
        If bFound = #False
          ; debugMsg(sProcName, "not found")
          ; this row no longer required
          nMaxKillRow + 1
          If nMaxKillRow > ArraySize(aKillRow())
            ReDim aKillRow(nMaxKillRow+10)
          EndIf
          aKillRow(nMaxKillRow) = rThisRow
        EndIf
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
    ; having finished the database query, delete any rows no longer required
    ; debugMsg(sProcName, "nMaxKillRow=" + nMaxKillRow)
    For n = 0 To nMaxKillRow
      With aKillRow(n)
        sSQLRequest = "DELETE FROM tempdb.ProgSldrs WHERE FileName = '" + RepQuote(\sFileName) + "'" + " AND AbsMin=" + \nAbsMin + " AND AbsMax=" + \nAbsMax
        nSQLResult = doDatabaseUpdate(nDatabaseNo, sSQLRequest)
        ; debugMsg(sProcName, "n=" + n + ", nSQLResult=" + nSQLResult)
      EndWith
    Next n
    ; now copy the temp table to the prod database
    ; debugMsg(sProcName, "calling copyTableFromTempDatabaseToProdDatabase('ProgSldrs')")
    copyTableFromTempDatabaseToProdDatabase("ProgSldrs")
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure copyImageDataToProdDatabase()
  PROCNAMEC()
  Protected nDatabaseNo, sSQLRequest.s, nSQLResult, bFound
  Protected i, j, k, n
  Structure tyMyImageDataFileInfo
    sFileName.s
    sSizeEtc.s
    nFilePos.i
  EndStructure
  Protected rThisRow.tyMyImageDataFileInfo
  Protected Dim aKillRow.tyMyImageDataFileInfo(0)
  Protected nMaxKillRow = -1
  
  debugMsg(sProcName, #SCS_START)
  
  nDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nDatabaseNo)
    sSQLRequest = "SELECT DISTINCT FileName, SizeEtc, FilePos FROM tempdb.ImageData"
    If DatabaseQuery(nDatabaseNo, sSQLRequest)
      ; copy image rows from the temp database for images that are required
      While NextDatabaseRow(nDatabaseNo)
        rThisRow\sFileName = GetDatabaseString(nDatabaseNo, 0)
        rThisRow\sSizeEtc = GetDatabaseString(nDatabaseNo, 1)
        rThisRow\nFilePos = GetDatabaseLong(nDatabaseNo, 2)
        ; check if this is still used
        bFound = #False
        For i = 1 To gnLastCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              With aAud(k)
                If \bAudPlaceHolder = #False
                  If aAud(k)\sFileName = rThisRow\sFileName
                    If (buildSizeEtc(k) = rThisRow\sSizeEtc) And (aAud(k)\nAbsStartAt = rThisRow\nFilePos)
                      bFound = #True
                      ; debugMsg(sProcName, "found at aAud(" + getAudLabel(k) + ")")
                      Break 3 ; Break i
                    EndIf
                  EndIf
                EndIf
                k = \nNextAudIndex
              EndWith
            Wend
            j = aSub(j)\nNextSubIndex
          Wend
        Next i
        If bFound = #False
          ; debugMsg(sProcName, "not found")
          ; this row no longer required
          nMaxKillRow + 1
          If nMaxKillRow > ArraySize(aKillRow())
            ReDim aKillRow(nMaxKillRow+10)
          EndIf
          aKillRow(nMaxKillRow) = rThisRow
        EndIf
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
    ; having finished the database query, delete any rows no longer required
    ; debugMsg(sProcName, "nMaxKillRow=" + nMaxKillRow)
    For n = 0 To nMaxKillRow
      With aKillRow(n)
        sSQLRequest = "DELETE FROM tempdb.ImageData WHERE FileName = '" + RepQuote(\sFileName) + "'" +
                      " AND SizeEtc = '" + RepQuote(\sSizeEtc) + "'" +
                      " AND FilePos = " + Str(\nFilePos)
        nSQLResult = doDatabaseUpdate(nDatabaseNo, sSQLRequest)
        ; debugMsg(sProcName, "n=" + n + ", nSQLResult=" + nSQLResult)
      EndWith
    Next n
    ; now copy the temp table to the prod database
    ; debugMsg(sProcName, "calling copyTableFromTempDatabaseToProdDatabase('ImageData')")
    copyTableFromTempDatabaseToProdDatabase("ImageData")
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkForDuplicateFileDataEntries(nDatabaseNo)
  PROCNAMEC()
  Protected sCurrFileName.s, nCurrGraphWidth, nCurrGraphChannels, nCurrViewStart, nCurrViewEnd
  Protected sThisFileName.s, nThisGraphWidth, nThisGraphChannels, nThisViewStart, nThisViewEnd
  Protected bDuplicateFound
  Protected sMsg.s
  
  If DatabaseQuery(nDatabaseNo, "SELECT Filename, GraphWidth, GraphChannels, ViewStart, ViewEnd FROM FileData " +
                                "ORDER BY FileName, GraphWidth, GraphChannels, ViewStart, ViewEnd")
    While NextDatabaseRow(nDatabaseNo)
      sThisFileName = GetDatabaseString(nDatabaseNo, 0)
      nThisGraphWidth = GetDatabaseLong(nDatabaseNo, 1)
      nThisGraphChannels = GetDatabaseLong(nDatabaseNo, 2)
      nThisViewStart = GetDatabaseLong(nDatabaseNo, 3)
      nThisViewEnd = GetDatabaseLong(nDatabaseNo, 4)
      If (sThisFileName = sCurrFileName) And (nThisGraphWidth = nCurrGraphWidth) And (nThisGraphChannels = nCurrGraphChannels) And
         (nThisViewStart = nCurrViewStart) And (nThisViewEnd = nCurrViewEnd)
        If Len(sCurrFileName) > 0
          sMsg = "Duplicate FileData entry found for " + sCurrFileName +
                 ", GraphWidth=" + nCurrGraphWidth +
                 ", GraphChannels=" + nCurrGraphChannels +
                 ", ViewStart=" + nCurrViewStart +
                 ", ViewEnd=" + nCurrViewEnd
          Debug "!!! " + sProcName + ": " + sMsg
          debugMsg(sProcName, sMsg)
          bDuplicateFound = #True
          Break
        EndIf
        sCurrFileName = sThisFileName
        nCurrGraphWidth = nThisGraphWidth
        nCurrGraphChannels = nThisGraphChannels
        nCurrViewStart = nThisViewStart
        nCurrViewEnd = nThisViewEnd
      EndIf
    Wend
    FinishDatabaseQuery(nDatabaseNo)
  EndIf
  ProcedureReturn bDuplicateFound
  
EndProcedure

Procedure copyTableFromProdDatabaseToTempDatabase(sTableName.s)
  PROCNAMEC()
  Protected sSQLRequest.s
  Protected nTempDatabaseNo
  Protected nProdDatabaseNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  nProdDatabaseNo = grProd\nDatabaseNo
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  ; debugMsg(sProcName, "nProdDatabaseNo=" + nProdDatabaseNo + ", nTempDatabaseNo=" + nTempDatabaseNo)
  If IsDatabase(nTempDatabaseNo)
    If compareTableStructures(sTableName) = #False
      ; tables are not the same structure - possibly because the prod table was saved using an older version of the table structure
      ; if the structures are not the same then just ignore the old version of the table - it will be re-created as required
      debugMsg(sProcName, "exiting because table structures differ (sTableName=" + sTableName + ")")
      ProcedureReturn
    EndIf
    
    If grCFH\nFileVersion = 110302
      ; database file size was excessive in 11.3.2, so force re-creation
      debugMsg(sProcName, "exiting because grCFH\nFileVersion=" + grCFH\nFileVersion)
      ProcedureReturn
    ElseIf grCFH\nFileVersion = 110303
      If FileSize(grProd\sDatabaseFile) > 5000000
        debugMsg(sProcName, "exiting because grCFH\nFileVersion=" + grCFH\nFileVersion + ", FileSize(" + GetFilePart(grProd\sDatabaseFile) + ")=" + FileSize(grProd\sDatabaseFile))
        ; database was probably created in 11.3.2 but was not re-created in 11.3.3, so force re-creation now (in 11.3.4 or later)
        ProcedureReturn
      EndIf
    EndIf
    
    ; clear existing rows from the 'temp' table
    sSQLRequest = "DELETE FROM " + sTableName
    doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
    
    If sTableName = "FileData"
      ; due to an error in SCS pre 11.3.8, some FileData tables contained multiple rows for some FileName's
      ; so if we have such an instance then ignore the table completely
      If IsDatabase(nProdDatabaseNo)
        If checkForDuplicateFileDataEntries(nProdDatabaseNo)
          ; at least one duplicated entry found, so ignore the FileData table
          debugMsg(sProcName, "exiting because duplicate entries found")
          ProcedureReturn
        EndIf
      EndIf
    EndIf
    
    ; table structures are the same, so copy the 'prod' table to the 'temp' table
    sSQLRequest = "INSERT INTO " + sTableName + " SELECT * FROM proddb." + sTableName
    ; debugMsg(sProcName, "sSQLRequest=" + sSQLRequest)
    doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure copyTableFromTempDatabaseToProdDatabase(sTableName.s)
  PROCNAMEC()
  Protected sSQLRequest.s
  Protected nProdDatabaseNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  nProdDatabaseNo = grProd\nDatabaseNo
  If IsDatabase(nProdDatabaseNo)
    ; clear existing rows from the 'prod' table
    sSQLRequest = "DELETE FROM " + sTableName
    doDatabaseUpdate(nProdDatabaseNo, sSQLRequest)
    
    ; copy the 'temp' table to the 'prod' table
    sSQLRequest = "INSERT INTO " + sTableName + " SELECT * FROM tempdb." + sTableName
    doDatabaseUpdate(nProdDatabaseNo, sSQLRequest)
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeTempDatabase()
  PROCNAMEC()
  
  With grTempDB
    If \bTempDatabaseOpen
      CloseDatabase(\nTempDatabaseNo)
      \bTempDatabaseOpen = #False
    EndIf
  EndWith
EndProcedure

Procedure.s buildSizeEtc(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sSizeEtc.s
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      sSizeEtc = Str(\nSize * -1) + "|" + \nXPos + "|" + \nYPos + "|" + decodeAspectRatioType(\nAspectRatioType)
      If \nAspectRatioType = #SCS_ART_CUSTOM
        sSizeEtc + ":" + \nAspectRatioHVal
      EndIf
      If \nRotate <> 0
        sSizeEtc + "|r" + \nRotate
      EndIf
      If \nFlip <> 0
        sSizeEtc + "|f" + \nFlip
      EndIf
    EndWith
  EndIf
  ProcedureReturn sSizeEtc
EndProcedure

Procedure sortLevelPointsArray(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
;       debugMsg(sProcName, "aAud(" + pAudPtr + ")\nMaxLevelPoint=" + \nMaxLevelPoint)
      If \nMaxLevelPoint >= 1
        ; nb Redim array if necessary to remove any dead (null) entries at the end of the array, otherwise SortStructuredArray() would sort these to the start of the array
        If ArraySize(\aPoint()) > \nMaxLevelPoint
          ReDim \aPoint(\nMaxLevelPoint)
        EndIf
        SortStructuredArray(\aPoint(), #PB_Sort_Ascending, OffsetOf(tyLevelPoint\nPointTime), TypeOf(tyLevelPoint\nPointTime))
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getAudDevNoForLogicalDev(pAudPtr, sLogicalDev.s, sTracks.s)
  PROCNAMECA(pAudPtr)
  Protected d, nDevNo
  
  nDevNo = -1
  If sLogicalDev
    If pAudPtr >= 0
      With aAud(pAudPtr)
        For d = \nFirstDev To \nLastDev
          If (\sLogicalDev[d] = sLogicalDev) And (\sTracks[d] = sTracks)
            nDevNo = d
            Break
          EndIf
        Next d
      EndWith
    EndIf
  EndIf
  ProcedureReturn nDevNo
EndProcedure

Procedure getNrOfOutputChansForLogicalDev(nDevType, sLogicalDev.s)
  PROCNAMEC()
  Protected d, nNrOfOutputChans
  
  With grProd
    Select nDevType
      Case #SCS_DEVTYPE_AUDIO_OUTPUT
        For d = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
            nNrOfOutputChans = \aAudioLogicalDevs(d)\nNrOfOutputChans
            Break
          EndIf
        Next d
      Case #SCS_DEVTYPE_VIDEO_AUDIO
        For d = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDev
            nNrOfOutputChans = \aVidAudLogicalDevs(d)\nNrOfOutputChans
            Break
          EndIf
        Next d
    EndSelect
  EndWith
  ProcedureReturn nNrOfOutputChans
EndProcedure

Procedure getDevNoForLogicalDev(*rProd.tyProd, nDevGrp, sLogicalDev.s)
  PROCNAMEC()
  Protected d, nDevNo
  
  nDevNo = -1
  With *rProd
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        For d = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        For d = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        For d = 0 To \nMaxVidCapLogicalDev
          If \aVidCapLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_FIX_TYPE
        For d = 0 To \nMaxFixType
          If \aFixTypes(d)\sFixTypeName = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_LIGHTING
        For d = 0 To \nMaxLightingLogicalDev
          If \aLightingLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CTRL_SEND
        For d = 0 To \nMaxCtrlSendLogicalDev
          If \aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CUE_CTRL
        For d = 0 To \nMaxCueCtrlLogicalDev
          If \aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_LIVE_INPUT
        For d = 0 To \nMaxLiveInputLogicalDev
          If \aLiveInputLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_IN_GRP
        For d = 0 To \nMaxInGrp
          If \aInGrps(d)\sInGrpName = sLogicalDev
            nDevNo = d
            Break
          EndIf
        Next d
        
    EndSelect
  EndWith

  ProcedureReturn nDevNo
EndProcedure

Procedure getDevIdForLogicalDev(*rProd.tyProd, nDevGrp, sLogicalDev.s)
  PROCNAMEC()
  Protected nDevId, d
  
  nDevId = -1
  With *rProd
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        For d = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevId = \aAudioLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        For d = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDev
            nDevId = \aVidAudLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        For d = 0 To \nMaxVidCapLogicalDev
          If \aVidCapLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevId = \aVidCapLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_FIX_TYPE
        For d = 0 To \nMaxFixType
          If \aFixTypes(d)\sFixTypeName = sLogicalDev
            nDevId = \aFixTypes(d)\nFixTypeId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_LIGHTING
        For d = 0 To \nMaxLightingLogicalDev
          If \aLightingLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevId = \aLightingLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CTRL_SEND
        For d = 0 To \nMaxCtrlSendLogicalDev
          If \aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevId = \aCtrlSendLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CUE_CTRL
        For d = 0 To \nMaxCueCtrlLogicalDev
          If \aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev = sLogicalDev
            nDevId = \aCueCtrlLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_LIVE_INPUT
        For d = 0 To \nMaxLiveInputLogicalDev
          If \aLiveInputLogicalDevs(d)\sLogicalDev = sLogicalDev
            nDevId = \aLiveInputLogicalDevs(d)\nDevId
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_IN_GRP
        For d = 0 To \nMaxInGrp
          If \aInGrps(d)\sInGrpName = sLogicalDev
            nDevId = \aInGrps(d)\nInGrpId
            Break
          EndIf
        Next d
        
    EndSelect
  EndWith

  ProcedureReturn nDevId
EndProcedure

Procedure getDevNoForFreeDev(*rProd.tyProd, nDevGrp)
  PROCNAMEC()
  Protected nDevNo, d
  
  nDevNo = -1
  With *rProd
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        For d = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxAudDevPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxAudDevPerAud
          addOneAudioLogicalDev(*rProd)
          nDevNo = \nMaxAudioLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        For d = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxVidAudDevPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxVidAudDevPerProd
          debugMsg(sProcName, "calling addOneVidAudLogicalDev")
          addOneVidAudLogicalDev(*rProd)
          nDevNo = \nMaxVidAudLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        For d = 0 To \nMaxVidCapLogicalDev
          If \aVidCapLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxVidCapDevPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxVidCapDevPerProd
          addOneVidCapLogicalDev(*rProd)
          nDevNo = \nMaxVidCapLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_FIX_TYPE
        For d = 0 To \nMaxFixType
          If Len(\aFixTypes(d)\sFixTypeName) = 0
            If d <= grLicInfo\nMaxFixTypePerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxFixTypePerProd
          addOneFixType(*rProd)
          nDevNo = \nMaxFixType
        EndIf
        
      Case #SCS_DEVGRP_LIGHTING
        For d = 0 To \nMaxLightingLogicalDev
          If \aLightingLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxLightingDevPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxLightingDevPerProd
          addOneLightingLogicalDev(*rProd)
          nDevNo = \nMaxLightingLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_CTRL_SEND
        For d = 0 To \nMaxCtrlSendLogicalDev
          If \aCtrlSendLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxCtrlSendDevPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxCtrlSendDevPerProd
          addOneCtrlSendLogicalDev(*rProd)
          nDevNo = \nMaxCtrlSendLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_CUE_CTRL
        For d = 0 To \nMaxCueCtrlLogicalDev
          If \aCueCtrlLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxCueCtrlDev
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxCueCtrlDev
          addOneCueCtrlLogicalDev(*rProd)
          nDevNo = \nMaxCueCtrlLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_LIVE_INPUT
        For d = 0 To \nMaxLiveInputLogicalDev
          If \aLiveInputLogicalDevs(d)\nDevType = #SCS_DEVTYPE_NONE
            If d <= grLicInfo\nMaxLiveDevPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxLiveDevPerProd
          addOneLiveInputLogicalDev(*rProd)
          nDevNo = \nMaxLiveInputLogicalDev
        EndIf
        
      Case #SCS_DEVGRP_IN_GRP
        For d = 0 To \nMaxInGrp
          If Len(\aInGrps(d)\sInGrpName) = 0
            If d <= grLicInfo\nMaxInGrpPerProd
              nDevNo = d
            EndIf
            Break
          EndIf
        Next d
        If nDevNo < 0 And d < grLicInfo\nMaxInGrpPerProd
          addOneInGrp(*rProd)
          nDevNo = \nMaxInGrp
        EndIf
        
    EndSelect
  EndWith
  ProcedureReturn nDevNo
EndProcedure

Procedure getDevNoForInputForLTCDev(*rProd.tyProd)
  PROCNAMEC()
  Protected nDevNo, d
  
  nDevNo = -1
  With *rProd
    For d = 0 To \nMaxLiveInputLogicalDev
      If \aLiveInputLogicalDevs(d)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
        If \aLiveInputLogicalDevs(d)\bInputForLTC
          nDevNo = d
        EndIf
        Break
      EndIf
    Next d
  EndWith
  ProcedureReturn nDevNo
EndProcedure

Procedure.s getLogicalDevForInputForLTCDev(*rProd.tyProd)
  PROCNAMEC()
  Protected sLogicalDev.s, d
  
  With *rProd
    For d = 0 To \nMaxLiveInputLogicalDev
      If \aLiveInputLogicalDevs(d)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
        If \aLiveInputLogicalDevs(d)\bInputForLTC
          sLogicalDev = \aLiveInputLogicalDevs(d)\sLogicalDev
        EndIf
        Break
      EndIf
    Next d
  EndWith
  ProcedureReturn sLogicalDev
EndProcedure

Procedure getPanAvailableForLogicalDev(sLogicalDev.s)
  PROCNAMEC()
  Protected bPanAvailable
  Protected d
  
  With grProd
    For d = 0 To \nMaxAudioLogicalDev
      If \aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
        If \aAudioLogicalDevs(d)\nNrOfOutputChans = 2
          bPanAvailable = #True
        EndIf
        Break
      EndIf
    Next d
  EndWith
  ProcedureReturn bPanAvailable
EndProcedure

Procedure setGraphChannelsForLogicalDev(pCaller, sLogicalDev.s)
  PROCNAMEC()
  Protected nGraphChannels
  
  If sLogicalDev
    If pCaller = 2 Or pCaller = 3
      nGraphChannels = getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, sLogicalDev)
      ; debugMsg(sProcName, "getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, " + sLogicalDev + ") returned " + nGraphChannels)
    ElseIf pCaller = 5
      nGraphChannels = getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_VIDEO_AUDIO, sLogicalDev)
      ; debugMsg(sProcName, "getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_VIDEO_AUDIO, " + sLogicalDev + ") returned " + nGraphChannels)
    EndIf
  EndIf
  
  If nGraphChannels = 0
    nGraphChannels = 1
  ElseIf nGraphChannels > 2
    ; Comment added 30Jul2024 11.10.3av
    ; In SCS, audio/video files that have more than 2 channels will have their audio graphs displayed as just two channels.
    ; The 'left' channel will be the sum of channels 1, 3, 5, etc, and the 'right' channel will be the sum of channels 2, 4, 6, etc.
    ; So the number of 'graph channels' for these files should be set to 2.
    ; End comment added 30Jul2024 11.10.3av
    nGraphChannels = 2
  EndIf
  
  Select pCaller
    Case 2
      grMG2\nGraphChannels = nGraphChannels
      grMG2\sGraphLogicalDev = sLogicalDev
    Case 3
      grMG3\nGraphChannels = nGraphChannels
      grMG3\sGraphLogicalDev = sLogicalDev
    Case 5
      grMG5\nGraphChannels = nGraphChannels
      grMG5\sGraphLogicalDev = sLogicalDev
      ; debugMsg(sProcName, "grMG5\nGraphChannels=" + grMG5\nGraphChannels + ", grMG5\sGraphLogicalDev=" + grMG5\sGraphLogicalDev)
  EndSelect
EndProcedure

Procedure calcLevelsForDevNo(pCaller, pAudPtr, pDevNo, nGraphChannels)
  PROCNAMECA(pAudPtr)
  Protected fBVLevel.f, fPan.f, fPanFactor.f
  Protected fBVLevelLeft.f = 1.0, fBVLevelRight.f = 1.0
  
  If (pAudPtr >= 0) And (pDevNo >= 0)
    With aAud(pAudPtr)
      fBVLevel = \fBVLevel[pDevNo]
      If nGraphChannels = 2
        fPan = \fPan[pDevNo]
      Else
        fPan = #SCS_PANCENTRE_SINGLE
      EndIf
      
      If fPan = #SCS_PANCENTRE_SINGLE
        fBVLevelLeft = fBVLevel
        fBVLevelRight = fBVLevel
      ElseIf fPan < 0  ; pan left
        fBVLevelLeft = fBVLevel
        fPanFactor = 1 - (fPan * -1)
        fBVLevelRight = fBVLevel * fPanFactor
      Else              ; pan right
        fBVLevelRight = fBVLevel
        fPanFactor = 1 - fPan
        fBVLevelLeft = fBVLevel * fPanFactor
      EndIf
    EndWith
    
    Select pCaller
      Case 2
        grMG2\fBVLevel = fBVLevel
        grMG2\fBVLevelLeft = fBVLevelLeft
        grMG2\fBVLevelRight = fBVLevelRight
      Case 3
        grMG3\fBVLevel = fBVLevel
        grMG3\fBVLevelLeft = fBVLevelLeft
        grMG3\fBVLevelRight = fBVLevelRight
    EndSelect
    
  EndIf
EndProcedure

Procedure calcLevelsForPos(pCaller, pAudPtr, pDevNo, nPosInFile) ;, nGraphChannels)
  PROCNAMECA(pAudPtr)
  Protected fBVLevel.f, fPan.f, fPanFactor.f
  Protected fBVLevelLeft.f = 1.0, fBVLevelRight.f = 1.0
  Protected nTimeWithinFadeIn, nTimeToGoFadingOut
  Protected fPrevPan.f, fNextPan.f
  Protected nPrevTime, nNextTime
  Protected fPrevLevel.f, fNextLevel.f
  Protected nPrevLevelPointIndex, nNextLevelPointIndex
  Protected nPrevItemIndex, nNextItemIndex
  Protected fDevLevel.f
  Protected fDevDBSingle.f
  Protected nTimeWithinLevelPointChange
  Protected fTimeFactor.f
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      fDevLevel = \fBVLevel[pDevNo]
      fDevDBSingle = convertBVLevelToDBLevel(fDevLevel)
      
      nPrevLevelPointIndex = getPrevIncludedLevelPointIndex(pAudPtr, pDevNo, nPosInFile)
      nPrevItemIndex = getItemIndexForDevNo(pAudPtr, nPrevLevelPointIndex, pDevNo)
      If (nPrevLevelPointIndex >= 0) And (nPrevItemIndex >= 0)
        nPrevTime = \aPoint(nPrevLevelPointIndex)\nPointTime
        fPrevLevel = convertDBLevelToBVLevel(fDevDBSingle + \aPoint(nPrevLevelPointIndex)\aItem(nPrevItemIndex)\fItemRelDBLevel)
        If fPrevLevel > grLevels\fMaxBVLevel
          fPrevLevel = grLevels\fMaxBVLevel
        EndIf
        fPrevPan = \aPoint(nPrevLevelPointIndex)\aItem(nPrevItemIndex)\fItemPan
      Else
        nPrevTime = \nAbsStartAt
        If \nFadeInTime > 0
          fPrevLevel = #SCS_MINVOLUME_SINGLE
        Else
          fPrevLevel = \fBVLevel[pDevNo]
        EndIf
        fPrevPan = \fPan[pDevNo]
      EndIf
      
      nNextLevelPointIndex = getNextIncludedLevelPointIndex(pAudPtr, pDevNo, nPosInFile - 1)  ; "nPosInFile - 1" in case nPosInFile exactly matches a level point time
      nNextItemIndex = getItemIndexForDevNo(pAudPtr, nNextLevelPointIndex, pDevNo)
      If (nNextLevelPointIndex >= 0) And (nNextItemIndex >= 0)
        nNextTime = \aPoint(nNextLevelPointIndex)\nPointTime
        fNextLevel = convertDBLevelToBVLevel(fDevDBSingle + \aPoint(nNextLevelPointIndex)\aItem(nNextItemIndex)\fItemRelDBLevel)
        If fNextLevel > grLevels\fMaxBVLevel
          fNextLevel = grLevels\fMaxBVLevel
        EndIf
        fNextPan = \aPoint(nNextLevelPointIndex)\aItem(nNextItemIndex)\fItemPan
      Else
        nNextTime = \nAbsEndAt
        fNextLevel = fPrevLevel
        fNextPan = fPrevPan
      EndIf
      
      ; debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", nPosInFile=" + Str(nPosInFile) + ", nPrevTime=" + Str(nPrevTime) + ", nNextTime=" + Str(nNextTime) + ", fPrevLevel=" + traceLevel(fPrevLevel) + ", fNextLevel=" + traceLevel(fNextLevel) +
      ; ", fPrevPan=" + formatPan(fPrevPan) + ", fNextPan=" + formatPan(fNextPan))
      
      If nNextTime = nPrevTime
        ; avoid crash due to division by zero, ie division by (nNextTime - nPrevTime)
        fBVLevel = fPrevLevel
        fPan = fPrevPan
      Else
        fTimeFactor = (nPosInFile - nPrevTime) / (nNextTime - nPrevTime)
        fBVLevel = fPrevLevel + ((fNextLevel - fPrevLevel) * fTimeFactor)
        If fBVLevel > grLevels\fMaxBVLevel
          fBVLevel = grLevels\fMaxBVLevel
        EndIf
        fPan = fPrevPan + ((fNextPan - fPrevPan) * fTimeFactor)
        ; debugMsg(sProcName, "fTimeFactor=" + StrF(fTimeFactor,3) + ", fBVLevel=" + formatLevel(fBVLevel) + ", fPan=" + formatPan(fPan))
      EndIf
      
      If fPan = #SCS_PANCENTRE_SINGLE
        fBVLevelLeft = fBVLevel
        fBVLevelRight = fBVLevel
      ElseIf fPan < 0  ; pan left
        fBVLevelLeft = fBVLevel
        fPanFactor = 1 - (fPan * -1)
        fBVLevelRight = fBVLevel * fPanFactor
      Else              ; pan right
        fBVLevelRight = fBVLevel
        fPanFactor = 1 - fPan
        fBVLevelLeft = fBVLevel * fPanFactor
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, "pCaller=" + Str(pCaller) + ", pAudPtr=" + getAudLabel(pAudPtr) + ", pDevNo=" + Str(pDevNo) + ", nPosInFile=" + Str(nPosInFile) + ", nGraphChannels=" + Str(nGraphChannels) +
  ; ", fBVLevel=" + traceLevel(fBVLevel) + ", fBVLevelLeft=" + traceLevel(fBVLevelLeft) + ", fBVLevelRight=" + traceLevel(fBVLevelRight))
  
  Select pCaller
    Case 2
      grMG2\fBVLevel = fBVLevel
      grMG2\fBVLevelLeft = fBVLevelLeft
      grMG2\fBVLevelRight = fBVLevelRight
    Case 3
      grMG3\fBVLevel = fBVLevel
      grMG3\fBVLevelLeft = fBVLevelLeft
      grMG3\fBVLevelRight = fBVLevelRight
  EndSelect
  
EndProcedure

Procedure.s makeProdTimerHistFileName(bUseWPTFields=#False)
  Protected sTimerHistFileName.s
  Protected bSaveProdTimerHistory, bTimeStampProdTimerHistoryFiles
  
  If (bUseWPTFields) And (IsGadget(WPT\chkSaveProdTimerHistory))
    bSaveProdTimerHistory = GGS(WPT\chkSaveProdTimerHistory)
    bTimeStampProdTimerHistoryFiles = GGS(WPT\chkTimeStampProdTimerHistoryFiles)
  Else
    bSaveProdTimerHistory = grProd\bSaveProdTimerHistory
    bTimeStampProdTimerHistoryFiles = grProd\bTimeStampProdTimerHistoryFiles
  EndIf
  
  If bSaveProdTimerHistory
    sTimerHistFileName = ignoreExtension(gsCueFile) + " (PT)"
    If bTimeStampProdTimerHistoryFiles
      If bUseWPTFields
        sTimerHistFileName + " " + FormatDate("%yyyy-%mm-%dd_%hh%ii%ss", Date())
      Else
        sTimerHistFileName + " " + FormatDate("%yyyy-%mm-%dd_%hh%ii%ss", gaProdTimerHistory(0)\nDateTime)
      EndIf
    EndIf
    sTimerHistFileName + ".csv"
  EndIf
  ProcedureReturn sTimerHistFileName
EndProcedure

Procedure saveProdTimerHistIfReqd()
  PROCNAMEC()
  Protected sTimerHistFileName.s
  Protected nTimesFile
  Protected n
  Protected sLine.s
  
  If grProd\bSaveProdTimerHistory
    If gnProdTimerHistoryPtr >= 0
      sTimerHistFileName = makeProdTimerHistFileName()
      nTimesFile = CreateFile(#PB_Any,sTimerHistFileName)
      If nTimesFile
        WriteStringFormat(nTimesFile, #PB_UTF8)
        For n = 0 To gnProdTimerHistoryPtr
          With gaProdTimerHistory(n)
            sLine = FormatDate("%yyyy-%mm-%dd", \nDateTime)
            sLine + "," + FormatDate("%hh:%ii:%ss", \nDateTime)
            sLine + "," + #DQUOTE$ + decodeProdTimerHistActionL(\nHistAction) + #DQUOTE$
            sLine + "," + TimeInSecsToString(\nTimeInSecs)
            sLine + "," + #DQUOTE$ + ReplaceString(\sCue, #DQUOTE$, "'") + #DQUOTE$
            sLine + "," + #DQUOTE$ + ReplaceString(\sCueDescr, #DQUOTE$, "'") + #DQUOTE$
            sLine + "," + #DQUOTE$ + decodeProdTimerActionL(\nProdTimerAction) + #DQUOTE$
          EndWith
          WriteStringN(nTimesFile, sLine)
        Next n
        CloseFile(nTimesFile)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure listFileDataArray()
  PROCNAMEC()
  Protected f
  
  For f = 1 To gnLastFileData
    With gaFileData(f)
      debugMsg(sProcName, "gaFileData(" + f + ")\sFileName=" + GetFilePart(\sFileName) + ", \qFileSize=" + \qFileSize + ", \nFileDuration=" + \nFileDuration)
    EndWith
  Next f
EndProcedure

Procedure listFileStatsArray()
  PROCNAMEC()
  Protected f
  
  For f = 1 To gnLastFileStats
    With gaFileStats(f)
      debugMsg(sProcName, "gaFileStats(" + f + ")\sFileName=" + GetFilePart(\sFileName) + ", \qFileSize=" + \qFileSize + ", \nFileDuration=" + \nFileDuration)
    EndWith
  Next f
EndProcedure

Procedure listDatabaseFileData(nDatabaseNo)
  PROCNAMEC()
  Protected sRequest.s
  Protected sFileName.s, sFileModified.s, nFileSize, nGraphWidth, nGraphChannels, nMaxPeak, nNormalizeFactor, nFileBlobSize
  Protected nViewStart, nViewEnd
  
  Select nDatabaseNo
    Case grTempDB\nTempDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Temp Database)")
    Case grProd\nDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Prod Database)")
    Default
      ; shouldn't get here
      debugMsg(sProcName, #SCS_START + ", nDatabaseNo=" + nDatabaseNo)
  EndSelect
  
  If IsDatabase(nDatabaseNo)
    sRequest = "SELECT FileName, FileModified, FileSize, GraphWidth, GraphChannels, MaxPeak, NormalizeFactorInt, FileBlobSize, ViewStart, ViewEnd FROM FileData ORDER BY FileName, GraphWidth"
    If DatabaseQuery(nDatabaseNo, sRequest)
      While NextDatabaseRow(nDatabaseNo)
        sFileName = GetDatabaseString(nDatabaseNo, 0)
        sFileModified = GetDatabaseString(nDatabaseNo, 1)
        nFileSize = GetDatabaseLong(nDatabaseNo, 2)
        nGraphWidth = GetDatabaseLong(nDatabaseNo, 3)
        nGraphChannels = GetDatabaseLong(nDatabaseNo, 4)
        nMaxPeak = GetDatabaseLong(nDatabaseNo, 5)
        nNormalizeFactor = GetDatabaseLong(nDatabaseNo, 6)
        nFileBlobSize = GetDatabaseLong(nDatabaseNo, 7)
        nViewStart = GetDatabaseLong(nDatabaseNo, 8)
        nViewEnd = GetDatabaseLong(nDatabaseNo, 9)
        debugMsg(sProcName, "FileName=" + #DQUOTE$ + sFileName + #DQUOTE$)
        debugMsg(sProcName, ".. FileModified=" + #DQUOTE$ + sFileModified + #DQUOTE$ +
                            ", FileSize=" + nFileSize + ", GraphWidth=" + nGraphWidth + ", GraphChannels=" + nGraphChannels +
                            ", MaxPeak=" + nMaxPeak + ", NormalizeFactor=" + nNormalizeFactor + ", FileBlobSize=" + nFileBlobSize +
                            ", ViewStart=" + nViewStart + ", nViewEnd=" + nViewEnd)
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listDatabaseProgSldrsData(nDatabaseNo)
  PROCNAMEC()
  Protected sRequest.s
  Protected sFileName.s, sFileModified.s, nFileSize, nGraphWidth, nGraphChannels, nMaxPeak, nNormalizeFactor, nFileBlobSize
  Protected nAbsMin, nAbsMax
  
  Select nDatabaseNo
    Case grTempDB\nTempDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Temp Database)")
    Case grProd\nDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Prod Database)")
    Default
      ; shouldn't get here
      debugMsg(sProcName, #SCS_START + ", nDatabaseNo=" + nDatabaseNo)
  EndSelect
  
  If IsDatabase(nDatabaseNo)
    sRequest = "SELECT FileName, FileModified, FileSize, GraphWidth, GraphChannels, MaxPeak, NormalizeFactorInt, SldrBlobSize, AbsMin, AbsMax FROM ProgSldrs ORDER BY FileName, GraphWidth"
    If DatabaseQuery(nDatabaseNo, sRequest)
      While NextDatabaseRow(nDatabaseNo)
        sFileName = GetDatabaseString(nDatabaseNo, 0)
        sFileModified = GetDatabaseString(nDatabaseNo, 1)
        nFileSize = GetDatabaseLong(nDatabaseNo, 2)
        nGraphWidth = GetDatabaseLong(nDatabaseNo, 3)
        nGraphChannels = GetDatabaseLong(nDatabaseNo, 4)
        nMaxPeak = GetDatabaseLong(nDatabaseNo, 5)
        nNormalizeFactor = GetDatabaseLong(nDatabaseNo, 6)
        nFileBlobSize = GetDatabaseLong(nDatabaseNo, 7)
        nAbsMin = GetDatabaseLong(nDatabaseNo, 8)
        nAbsMax = GetDatabaseLong(nDatabaseNo, 9)
        debugMsg(sProcName, "FileName=" + #DQUOTE$ + sFileName + #DQUOTE$)
        debugMsg(sProcName, ".. FileModified=" + #DQUOTE$ + sFileModified + #DQUOTE$ +
                            ", FileSize=" + nFileSize + ", GraphWidth=" + nGraphWidth + ", GraphChannels=" + nGraphChannels +
                            ", MaxPeak=" + nMaxPeak + ", NormalizeFactor=" + nNormalizeFactor + ", FileBlobSize=" + nFileBlobSize +
                            ", ViewStart=" + nAbsMin + ", nAbsMax=" + nAbsMax)
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure findDuplicateFileDataRows(nDatabaseNo)
  PROCNAMEC()
  Protected sRequest.s
  Protected sFileName.s, sFileModified.s, nFileSize, nGraphWidth, nGraphChannels, nMaxPeak, nNormalizeFactor, nFileBlobSize
  Protected nViewStart, nViewEnd
  Protected nCount
  Protected bLockMutex
  Protected bLockedMutex
  
  Select nDatabaseNo
    Case grTempDB\nTempDatabaseNo
      bLockMutex = #True
      debugMsg(sProcName, #SCS_START + " (Temp Database)")
    Case grProd\nDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Prod Database)")
    Default
      ; shouldn't get here
      debugMsg(sProcName, #SCS_START + ", nDatabaseNo=" + nDatabaseNo)
  EndSelect
  
  If bLockMutex
    LockTempDatabaseMutex(9)
  EndIf
  
  If IsDatabase(nDatabaseNo)
    sRequest = "SELECT FileName, FileModified, FileSize, GraphWidth, GraphChannels, MaxPeak, NormalizeFactorInt, FileBlobSize, ViewStart, ViewEnd, COUNT(*) FROM FileData " +
               "WHERE COUNT(*) > 1 " +
               "GROUP BY FileName, FileModified, FileSize, GraphWidth, GraphChannels, MaxPeak, NormalizeFactorInt, FileBlobSize, ViewStart, ViewEnd"
    If DatabaseQuery(nDatabaseNo, sRequest)
      While NextDatabaseRow(nDatabaseNo)
        sFileName = GetDatabaseString(nDatabaseNo, 0)
        sFileModified = GetDatabaseString(nDatabaseNo, 1)
        nFileSize = GetDatabaseLong(nDatabaseNo, 2)
        nGraphWidth = GetDatabaseLong(nDatabaseNo, 3)
        nGraphChannels = GetDatabaseLong(nDatabaseNo, 4)
        nMaxPeak = GetDatabaseLong(nDatabaseNo, 5)
        nNormalizeFactor = GetDatabaseLong(nDatabaseNo, 6)
        nFileBlobSize = GetDatabaseLong(nDatabaseNo, 7)
        nViewStart = GetDatabaseLong(nDatabaseNo, 8)
        nViewEnd = GetDatabaseLong(nDatabaseNo, 9)
        nCount = GetDatabaseLong(nDatabaseNo, 10)
        debugMsg(sProcName, "FileName=" + #DQUOTE$ + sFileName + #DQUOTE$ + ", Count=" + nCount)
        debugMsg(sProcName, ".. FileModified=" + #DQUOTE$ + sFileModified + #DQUOTE$ +
                            ", FileSize=" + nFileSize + ", GraphWidth=" + nGraphWidth + ", GraphChannels=" + nGraphChannels +
                            ", MaxPeak=" + nMaxPeak + ", NormalizeFactor=" + nNormalizeFactor + ", FileBlobSize=" + nFileBlobSize +
                            ", ViewStart=" + nViewStart + ", nViewEnd=" + nViewEnd)
        Debug sProcName + ": Count=" + nCount + ", FileName=" + GetFilePart(sFileName)
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  
  If bLockMutex
    UnlockTempDatabaseMutex()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getDatabaseChangesCount(nDatabaseNo)
  Protected nChangesCount.l
  
  If IsDatabase(nDatabaseNo)
    If DatabaseQuery(nDatabaseNo, "SELECT changes()")
      If NextDatabaseRow(nDatabaseNo)
        nChangesCount = GetDatabaseLong(nDatabaseNo, 0)
      EndIf
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  ProcedureReturn nChangesCount
  
EndProcedure

Procedure.s getTitleFromCueFile(sFileName.s)
  PROCNAMEC()
  Protected sTitle.s
  Protected nFileNo
  Protected sLine.s
  Protected nPos1, nPos2
  
  If FileExists(sFileName, #False)
    nFileNo = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
    While Eof(nFileNo) = 0
      sLine = Trim(ReadString(nFileNo))
      If Left(sLine, 7) = "<Title>"
        nPos1 = 8
        nPos2 = FindString(sLine, "</Title>")
        If nPos2 > nPos1
          sTitle = XMLDecode(Mid(sLine, nPos1, (nPos2 - nPos1)))
        EndIf
        Break
      EndIf
    Wend
    CloseFile(nFileNo)
  EndIf
  
  ProcedureReturn sTitle
EndProcedure

Procedure.s getProdIdFromCueFile(sFileName.s)
  PROCNAMEC()
  Protected sProdId.s
  Protected nFileNo
  Protected sLine.s
  Protected nPos1, nPos2
  
  If FileExists(sFileName, #False)
    nFileNo = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
    While Eof(nFileNo) = 0
      sLine = Trim(ReadString(nFileNo))
      If Left(sLine, 8) = "<ProdId>"
        nPos1 = 9
        nPos2 = FindString(sLine, "</ProdId>")
        If nPos2 > nPos1
          sProdId = XMLDecode(Mid(sLine, nPos1, (nPos2 - nPos1)))
        EndIf
        Break
      EndIf
    Wend
    CloseFile(nFileNo)
  EndIf
  
  ProcedureReturn sProdId
EndProcedure

Procedure.s getDescFromTemplateFile(sFileName.s)
  PROCNAMEC()
  Protected sDesc.s
  Protected nFileNo
  Protected sLine.s
  Protected nPos1, nPos2
  
  If FileExists(sFileName, #False)
    nFileNo = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
    While Eof(nFileNo) = 0
      sLine = Trim(ReadString(nFileNo))
      If Left(sLine, 8) = "<TmDesc>"
        nPos1 = 9
        nPos2 = FindString(sLine, "</TmDesc>")
        If nPos2 > nPos1
          sDesc = XMLDecode(Mid(sLine, nPos1, (nPos2 - nPos1)))
        EndIf
        Break
      EndIf
    Wend
    CloseFile(nFileNo)
  EndIf
  
  ProcedureReturn sDesc
EndProcedure

Procedure loadTemplatesArray()
  PROCNAMEC()
  Protected nDirectory
  Protected sTemplateFileName.s, sTemplateDevMapFileName.s, sTemplateDatabaseFileName.s, sTemplateBakFileName.s
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  gnTemplateCount = 0
  nDirectory = ExamineDirectory(#PB_Any, gsTemplatesFolder, "*.scstm")
  If nDirectory
    While NextDirectoryEntry(nDirectory)
      If DirectoryEntryType(nDirectory) = #PB_DirectoryEntry_File
        sTemplateFileName = gsTemplatesFolder + DirectoryEntryName(nDirectory)
        sTemplateDevMapFileName = ignoreExtension(sTemplateFileName) + ".scstd"
        sTemplateDatabaseFileName = ignoreExtension(sTemplateFileName) + ".scsdb"
        sTemplateBakFileName = ignoreExtension(sTemplateFileName) + ".bak"
        If gnTemplateCount > ArraySize(gaTemplate())
          ReDim gaTemplate(gnTemplateCount+5)
        EndIf
        gaTemplate(gnTemplateCount) = grTemplateDef
        With gaTemplate(gnTemplateCount)
          \sName = ignoreExtension(GetFilePart(sTemplateFileName))
          \sDesc = getDescFromTemplateFile(sTemplateFileName)
          \sOrigTemplateFileName = sTemplateFileName
          \sCurrTemplateFileName = sTemplateFileName
          If FileExists(sTemplateDevMapFileName, #False)
            \sOrigTemplateDevMapFileName = sTemplateDevMapFileName
            \sCurrTemplateDevMapFileName = sTemplateDevMapFileName
          EndIf
          If FileExists(sTemplateDatabaseFileName, #False)
            \sOrigTemplateDatabaseFileName = sTemplateDatabaseFileName
            \sCurrTemplateDatabaseFileName = sTemplateDatabaseFileName
          EndIf
          If FileExists(sTemplateBakFileName, #False)
            \sOrigTemplateBakFileName = sTemplateBakFileName
            \sCurrTemplateBakFileName = sTemplateBakFileName
          EndIf
        EndWith
        gnTemplateCount + 1
      EndIf
    Wend
    FinishDirectory(nDirectory)
  EndIf
  
  If gnTemplateCount > 0
    ReDim gaTemplate(gnTemplateCount-1)
    SortStructuredArray(gaTemplate(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(tyTemplate\sName), #PB_String)
    For n = 0 To ArraySize(gaTemplate())
      With gaTemplate(n)
        debugMsg(sProcName, "gaTemplate(" + n + ")\sName=" + \sName + ", \sDesc=" + \sDesc)
      EndWith
    Next n
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", gnTemplateCount=" + gnTemplateCount)
  
EndProcedure

Procedure scanXMLTemplateFile(*CurrentNode, CurrentSublevel)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s
  Protected sTagCode.s, nTagIndex, nNumLength
  Protected sParentNodeName.s
  Protected sAttributeName.s, sAttributeValue.s
  Protected *nChildNode
  Protected nColorIndex
  Static rTmCue.tyTmCue
  Static nTmCuePtr
  Static sLogicalDev.s, nDevType, nRemoteDev, nCueCtrlDevs
  Static nProdDevSeq
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    If ExamineXMLAttributes(*CurrentNode)
      While NextXMLAttribute(*CurrentNode)
        sAttributeName = XMLAttributeName(*CurrentNode)
        sAttributeValue = XMLAttributeValue(*CurrentNode)
        Break ; no more than one attribute is used for XML nodes in SCS cue files
      Wend
    EndIf
    
    sTagCode = sNodeName
    nTagIndex = 0
    nNumLength = 0
    While (Right(sTagCode, 1) >= "0") And (Right(sTagCode, 1) <= "9")
      nNumLength + 1
      sTagCode = Left(sTagCode, Len(sTagCode) - 1)
    Wend
    If nNumLength > 0
      nTagIndex = Val(Right(sNodeName, nNumLength))
    EndIf

    ; debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue)
    Select sTagCode
        
      Case "ActivationMethod"
        rTmCue\nActivationMethod = encodeActivationMethod(sNodeText)
        
      Case "AutoActivateCue"
        rTmCue\sAutoActCue = sNodeText
        
      Case "AutoActivateCueType"
        rTmCue\nAutoActCueSelType = encodeAutoActCueSelType(sNodeText)
        
      Case "AutoActivatePosn"
        rTmCue\nAutoActPosn = encodeAutoActPosn(sNodeText)
        
      Case "AutoActivateTime"
        rTmCue\nAutoActTime = Val(sNodeText)
        
      Case "Cue"
        rTmCue = grTmCueDef
        
      Case "CueId"
        rTmCue\sCue = sNodeText
        
      Case "Description"
        rTmCue\sCueDescr = sNodeText
        
      Case "Hotkey", "HotKey"
        rTmCue\sHotkey = sNodeText
        
      Case "MTCStartTimeForCue"
        ; also handles LTC
        rTmCue\nMTCStartTimeForCue = encodeMTCTime(sNodeText)
        
      Case "PRLogicalDev", "PRVidAudLogicalDev", "PRVidCapLogicalDev", "PRInputLogicalDev"
        gnLastTmDev + 1
        If ArraySize(gaTmDev()) < gnLastTmDev
          REDIM_ARRAY(gaTmDev, gnLastTmDev+10, grTmDevDef, "gaTmDev()")
        EndIf
        With gaTmDev(gnLastTmDev)
          \sNodeName = sNodeName  ; full node name (eg PRLogicalDev0)
          If sTagCode <> UCase(sNodeName)
            nProdDevSeq + 1
            \nProdDevSeq = nProdDevSeq
            ; debugMsg(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", \nProdDevSeq=" + \nProdDevSeq)
          EndIf
          Select sTagCode
            Case "PRLogicalDev"
              \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            Case "PRVidAudLogicalDev"
              \nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
            Case "PRVidCapLogicalDev"
              \nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
            Case "PRInputLogicalDev"
              \nDevType = #SCS_DEVTYPE_LIVE_INPUT
          EndSelect
          \sLogicalDev = sNodeText
          \sDevTypeL = decodeDevTypeL(\nDevType)
          \nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nTextColor
          \nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nBackColor
          ; debugMsg(sProcName, "sTagCode=" + sTagCode + ", sNodeText=" + sNodeText + ", gaTmDev(" + gnLastTmDev + ")\sDevTypeL=" + \sDevTypeL + ", \nNode=" + \nNode)
        EndWith
        
      Case "PRCCDevice", "PRCSDevice", "PRLTDevice"
        sLogicalDev = ""
        nDevType = #SCS_DEVTYPE_NONE
        nRemoteDev = 0
        nProdDevSeq + 1
        ; debugMsg(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", nProdDevSeq=" + nProdDevSeq)
        
      Case "PRCCDevType", "PRCSDevType", "PRLTDevType"
        nDevType = encodeDevType(sNodeText)
        
      Case "PRCSLogicalDev", "PRLTLogicalDev"
        sLogicalDev = sNodeText
        
      Case "Production"
        nTmCuePtr = 0
        nCueCtrlDevs = 0
        nProdDevSeq = 0
        
      Case "SubType"
        If rTmCue\sCueType = grTmCueDef\sCueType
          rTmCue\sCueType = sNodeText
        EndIf
        
    EndSelect
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      scanXMLTemplateFile(*nChildNode, CurrentSublevel + 1)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
    ; process any end-of-node requirements
    Select sTagCode
      Case "Cue"
        With rTmCue
          If \sCueType
            \sCueTypeL = decodeSubTypeL(\sCueType, -1)
          EndIf
          \sActivationMethodL = getCueActivationMethodForTemplate(@rTmCue)
          If \nActivationMethod = #SCS_ACMETH_CALL_CUE
            \sColorCode = "CC"
          ElseIf (\nActivationMethod & #SCS_ACMETH_HK_BIT) Or (\nActivationMethod & #SCS_ACMETH_EXT_BIT)
            \sColorCode = "HK"
          ElseIf FindString(#SCS_ALL_SUBTYPES, \sCueType)
            \sColorCode = "Q" + \sCueType
          Else
            \sColorCode = "QF"
          EndIf
          nColorIndex = encodeColorItemCode(\sColorCode)
          If nColorIndex >= 0
            \nBackColor = grColorScheme\aItem[nColorIndex]\nBackColor
            \nTextColor = grColorScheme\aItem[nColorIndex]\nTextColor
          EndIf
          debugMsg(sProcName, "rTmCue\sCue=" + \sCue + ", \sColorCode=" + \sColorCode + ", nColorIndex=" + nColorIndex + ", \nBackColor=$" + Hex(\nBackColor,#PB_Long) + ", \nTextColor=$" + Hex(\nTextColor,#PB_Long))
        EndWith
        nTmCuePtr + 1
        If ArraySize(gaTmCue()) < nTmCuePtr
          REDIM_ARRAY(gaTmCue, nTmCuePtr+20, grTmCueDef, "gaTmCue()")
        EndIf
        gaTmCue(nTmCuePtr) = rTmCue
        debugMsg(sProcName, "gaTmCue(" + nTmCuePtr + ")\sCue=" + gaTmCue(nTmCuePtr)\sCue)
        
      Case "PRCCDevice", "PRCSDevice", "PRLTDevice"
        gnLastTmDev + 1
        If ArraySize(gaTmDev()) < gnLastTmDev
          REDIM_ARRAY(gaTmDev, gnLastTmDev+10, grTmDevDef, "gaTmDev()")
        EndIf
        With gaTmDev(gnLastTmDev)
          \sNodeName = sNodeName
          \nProdDevSeq = nProdDevSeq
          \nDevType = nDevType
          If sTagCode = "PRCCDevice"
            nCueCtrlDevs + 1
            \sLogicalDev = "C" + Str(nCueCtrlDevs)
          Else
            \sLogicalDev = sLogicalDev
          EndIf
          \sDevTypeL = decodeDevTypeL(\nDevType)
          \nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nTextColor
          \nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nBackColor
          debugMsg(sProcName, "sTagCode=" + sTagCode + ", sNodeText=" + sNodeText + ", gaTmDev(" + gnLastTmDev + ")\sDevTypeL=" + \sDevTypeL + ", \nProdDevSeq=" + \nProdDevSeq)
        EndWith
        
      Case "Production"
        gnLastTmCue = nTmCuePtr
        
    EndSelect
    
  EndIf
  
EndProcedure

Procedure incLastTmDev()
  PROCNAMEC()
  
  gnLastTmDev + 1
  If ArraySize(gaTmDev()) < gnLastTmDev
    REDIM_ARRAY(gaTmDev, gnLastTmDev+10, grTmDevDef, "gaTmDev()")
  EndIf
EndProcedure

Procedure.s readXMLTemplateFile(sFileName.s)
  PROCNAMEC()
  ; sFileName may be either a template file (*.scstm) or a cue file (*.scs11)
  Protected n, d, i, j
  Protected bFileReadOK
  Protected nProdDevSeq
  
  debugMsg(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName))
  
  ; initialize arrays
  gnLastTmCue = 0
  gnLastTmDev = -1
  For n = 0 To ArraySize(gaTmCue())
    gaTmCue(n) = grTmCueDef
  Next n
  For n = 0 To ArraySize(gaTmDev())
    gaTmDev(n) = grTmDevDef
  Next n
  
  If FileExists(sFileName)
    gs2ndCueFile = sFileName
    gs2ndCueFolder = GetPathPart(gs2ndCueFile)
    debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
    open2ndSCSCueFile()
    If gb2ndCueFileOpen
      If gb2ndXMLFormat
        debugMsg(sProcName, "calling readXMLCueFile(" + gn2ndCueFileNo + ", #False, " + gn2ndCueFileStringFormat + ", " + GetFilePart(sFileName) + ", #False, #True)")
        readXMLCueFile(gn2ndCueFileNo, #False, gn2ndCueFileStringFormat, sFileName, #False, #True)
        debugMsg(sProcName, "returned from readXMLCueFile()")
        bFileReadOK = #True
      EndIf
      close2ndSCSCueFile(gn2ndCueFileNo)
    EndIf
  EndIf
  
  If bFileReadOK
    For i = 1 To gn2ndLastCue
      j = a2ndCue(i)\nFirstSubIndex
      gnLastTmCue + 1
      If gnLastTmCue > ArraySize(gaTmCue())
        REDIM_ARRAY(gaTmCue, (gnLastTmCue+50), grTmCueDef, "gaTmCue()")
      EndIf
      With gaTmCue(gnLastTmCue)
        \sCue = a2ndCue(i)\sCue
        \sCueDescr = a2ndCue(i)\sCueDescr
        \sHotkey = a2ndCue(i)\sHotkey
        \nActivationMethod = a2ndCue(i)\nActivationMethod
        \sAutoActCue = a2ndCue(i)\sAutoActCue
        \nAutoActCueSelType = a2ndCue(i)\nAutoActCueSelType
        \nAutoActPosn = a2ndCue(i)\nAutoActPosn
        \nAutoActTime = a2ndCue(i)\nAutoActTime
        \nMTCStartTimeForCue = a2ndCue(i)\nMTCStartTimeForCue
        \nBackColor = a2ndCue(i)\nBackColor
        \nTextColor = a2ndCue(i)\nTextColor
        If j >= 0
          \sCueType = a2ndSub(j)\sSubType
          \sCueTypeL = decodeSubTypeL(\sCueType, -1)
        EndIf
        ; must be called AFTER setting other values in gaTmCue(gnLastTmCue) :-
        \sActivationMethodL = getCueActivationMethodForTemplate(@gaTmCue(gnLastTmCue))
      EndWith
    Next i
    
    With gr2ndProd
      For d = 0 To \nMaxAudioLogicalDev
        If \aAudioLogicalDevs(d)\sLogicalDev
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          gaTmDev(gnLastTmDev)\sLogicalDev = \aAudioLogicalDevs(d)\sLogicalDev
        EndIf
      Next d
      For d = 0 To \nMaxVidAudLogicalDev
        If \aVidAudLogicalDevs(d)\sVidAudLogicalDev
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
          gaTmDev(gnLastTmDev)\sLogicalDev = \aVidAudLogicalDevs(d)\sVidAudLogicalDev
        EndIf
      Next d
      For d = 0 To \nMaxVidCapLogicalDev
        If \aVidCapLogicalDevs(d)\sLogicalDev
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
          gaTmDev(gnLastTmDev)\sLogicalDev = \aVidCapLogicalDevs(d)\sLogicalDev
        EndIf
      Next d
      ; no 'device type' for fixture types
      For d = 0 To \nMaxLightingLogicalDev
        If \aLightingLogicalDevs(d)\sLogicalDev
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
          gaTmDev(gnLastTmDev)\sLogicalDev = \aLightingLogicalDevs(d)\sLogicalDev
        EndIf
      Next d
      For d = 0 To \nMaxCtrlSendLogicalDev
        If \aCtrlSendLogicalDevs(d)\sLogicalDev
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = \aCtrlSendLogicalDevs(d)\nDevType
          gaTmDev(gnLastTmDev)\sLogicalDev = \aCtrlSendLogicalDevs(d)\sLogicalDev
        EndIf
      Next d
      For d = 0 To \ nMaxCueCtrlLogicalDev
        If \aCueCtrlLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = \aCueCtrlLogicalDevs(d)\nDevType
          gaTmDev(gnLastTmDev)\sLogicalDev = \aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
        EndIf
      Next d
      For d = 0 To \nMaxLiveInputLogicalDev
        If \aLiveInputLogicalDevs(d)\sLogicalDev
          incLastTmDev()
          gaTmDev(gnLastTmDev)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
          gaTmDev(gnLastTmDev)\sLogicalDev = \aLiveInputLogicalDevs(d)\sLogicalDev
        EndIf
      Next d
      ; no 'device type' for input groups
    EndWith
    For n = 0 To gnLastTmDev
      With gaTmDev(n)
        \bIncludeDev = #True
        \sDevTypeL = decodeDevTypeL(\nDevType)
        \nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nTextColor
        \nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nBackColor
        \nProdDevSeq = n + 1
      EndWith
    Next n
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure updateOrCreateXMLNode(nParentNode, sPath.s, sNodeText.s, nPreviousNode=-1)
  Protected nWorkNode
  
  nWorkNode = XMLNodeFromPath(nParentNode, sPath)
  If nWorkNode = 0
    nWorkNode = CreateXMLNode(nParentNode, sPath, nPreviousNode)
  EndIf
  If nWorkNode
    SetXMLNodeText(nWorkNode, sNodeText)
  EndIf
  ProcedureReturn nWorkNode
EndProcedure

Procedure deleteXMLNodePath(nParentNode, sPath.s)
  PROCNAMEC()
  Protected nWorkNode
  
  nWorkNode = XMLNodeFromPath(nParentNode, sPath)
  If nWorkNode
    debugMsg(sProcName, "calling DeleteXMLNode(" + nWorkNode + "), sPath=" + sPath)
    DeleteXMLNode(nWorkNode)
  EndIf
EndProcedure

Procedure scanXMLTemplate(*CurrentNode, CurrentSublevel, nTemplatePtr)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s
  Protected sTagCode.s, nTagIndex, nTagNumLength
  Protected sParentNodeName.s
  Protected sAttributeName.s, sAttributeValue.s
  Protected *nChildNode
  Protected i, n
  Protected nPrevNode
  Protected bIncludeDev
  Protected sFileName.s
  Protected sReqdNodeName.s
  Static rTmCue.tyTmCue
  Static rTMDev.tyTmDev
  Static nProdNode, nHeadNode, nCueNode, bThisDevIncluded
  Static sCueFolder.s
  Static nProdDevSeq, nReqdTagIndex
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    If ExamineXMLAttributes(*CurrentNode)
      While NextXMLAttribute(*CurrentNode)
        sAttributeName = XMLAttributeName(*CurrentNode)
        sAttributeValue = XMLAttributeValue(*CurrentNode)
        Break ; no more than one attribute is used for XML nodes in SCS cue files
      Wend
    EndIf
    
    sTagCode = sNodeName
    nTagIndex = 0
    nTagNumLength = 0
    While (Right(sTagCode, 1) >= "0") And (Right(sTagCode, 1) <= "9")
      nTagNumLength + 1
      sTagCode = Left(sTagCode, Len(sTagCode) - 1)
    Wend
    If nTagNumLength > 0
      nTagIndex = Val(Right(sNodeName, nTagNumLength))
    EndIf

    debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sTagCode=" + sTagCode + ", sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue)
    Select sTagCode
      Case "Cue"
        rTmCue = grTmCueDef
        nCueNode = *CurrentNode
        
      Case "CueId"
        rTmCue\sCue = sNodeText
        debugMsg(sProcName, "rTmCue\sCue=" + rTmCue\sCue + ", nCueNode=" + nCueNode)
        
      Case "FileName"
        If FindString(sNodeText, "$")
          sFileName = decodeFileName(sNodeText, #False, #True, #False, #True, sCueFolder)
          SetXMLNodeText(*CurrentNode, sFileName)
        EndIf
        
      Case "Head"
        nHeadNode = *CurrentNode
        
      Case "PRLogicalDev", "PRVidAudLogicalDev", "PRVidCapLogicalDev", "PRInputLogicalDev", "PRCCDevice", "PRCSDevice", "PRLTDevice"
        bIncludeDev = #False
        nProdDevSeq + 1
        debugMsg(sProcName, "nProdDevSeq=" + nProdDevSeq)
        If nTagIndex = 0
          nReqdTagIndex = -1
        EndIf
        For n = 0 To gnLastTmDev
          debugMsg(sProcName, "gaTmDev(" + n + ")\nProdDevSeq=" + gaTmDev(n)\nProdDevSeq + ", \sLogicalDev=" + gaTmDev(n)\sLogicalDev)
          If gaTmDev(n)\nProdDevSeq = nProdDevSeq
            bIncludeDev = gaTmDev(n)\bIncludeDev
            Break
          EndIf
        Next n
        bThisDevIncluded = bIncludeDev   ; bThisDevIncluded is static and will be used by associated tags, eg PRNumChans
        If bThisDevIncluded
          nReqdTagIndex + 1
          If (nTagNumLength > 0) And (nReqdTagIndex <> nTagIndex)
            ; we get here typically if the user has excluded one or more audio output devices but has retained later audio output devices,
            ; ig if the Node "PRLogicalDev1" needs to be changed to "PRLogicalDev0" (because device 0 was excluded)
            sReqdNodeName = sTagCode + Str(nReqdTagIndex)
            SetXMLNodeName(*CurrentNode, sReqdNodeName)
          EndIf
        Else
          debugMsg(sProcName, "calling DeleteXMLNode(" + *CurrentNode + "), sNodeText=" + sNodeText)
          DeleteXMLNode(*CurrentNode)
        EndIf
        
      Case "PRNumChans", "PRAutoIncludeDev", "DfltDBTrim", "DfltDBLevel", "DfltPan", "PRAutoIncludeVidAud", "DfltVidAudDBTrim", "DfltVidAudDBLevel", "DfltVidAudPan", "PRAutoIncludeVidCap", "PRNumInputChans"
        If bThisDevIncluded   ; bThisDevIncluded is static and was set by tag, eg PRLogicalDev
          If (nTagNumLength > 0) And (nReqdTagIndex <> nTagIndex)
            ; see comments above
            sReqdNodeName = sTagCode + Str(nReqdTagIndex)
            SetXMLNodeName(*CurrentNode, sReqdNodeName)
          EndIf
        Else
          debugMsg(sProcName, "calling DeleteXMLNode(" + *CurrentNode + "), sNodeText=" + sNodeText)
          DeleteXMLNode(*CurrentNode)
        EndIf
        
      Case "PreviewDevice", "OutputDevForTestLiveInput"
        bIncludeDev = #False
        For n = 0 To gnLastTmDev
          If (gaTmDev(n)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (gaTmDev(n)\sLogicalDev = sNodeText)
            bIncludeDev = gaTmDev(n)\bIncludeDev
            Break
          EndIf
        Next n
        If bIncludeDev = #False
          debugMsg(sProcName, "calling DeleteXMLNode(" + *CurrentNode + "), sNodeText=" + sNodeText)
          DeleteXMLNode(*CurrentNode)
        EndIf
        
      Case "Production"
        nProdNode = *CurrentNode
        If nTemplatePtr >= 0
          sCueFolder = GetPathPart(gaTemplate(nTemplatePtr)\sCueFileName)
        Else
          sCueFolder = ""
        EndIf
        nProdDevSeq = 0
        debugMsg(sProcName, "sCueFolder=" + #DQUOTE$ + sCueFolder + #DQUOTE$)
        
    EndSelect
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      scanXMLTemplate(*nChildNode, CurrentSublevel+1, nTemplatePtr)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
    ; process any end-of-node requirements
    Select sTagCode
      Case "Cue"
        For i = 1 To gnLastTmCue
          If gaTmCue(i)\sCue = rTmCue\sCue
            If gaTmCue(i)\bIncludeCue = #False
              debugMsg(sProcName, "deleting cue " + rTmCue\sCue)
              debugMsg(sProcName, "calling DeleteXMLNode(" + nCueNode + "), sNodeText=" + sNodeText)
              DeleteXMLNode(nCueNode)
            EndIf
            Break
          EndIf
        Next i
        
      Case "Head"
        nPrevNode = 0
        ; add nodes required for templates
        If Trim(gaTemplate(nTemplatePtr)\sDesc)
          nPrevNode = updateOrCreateXMLNode(nHeadNode, "TmDesc", Trim(gaTemplate(nTemplatePtr)\sDesc), nPrevNode)
        EndIf
        ; update selected nodes
        nPrevNode = updateOrCreateXMLNode(nHeadNode, "Version", #SCS_FILE_VERSION, nPrevNode)
        nPrevNode = updateOrCreateXMLNode(nHeadNode, "Build", Str(grProgVersion\nBuildDate), nPrevNode)
        ; remove nodes not required in templates
        deleteXMLNodePath(nHeadNode, "Title")
        deleteXMLNodePath(nHeadNode, "ProdId")
        
      Case "Production"
        ; remove nodes not required in templates
        deleteXMLNodePath(nProdNode, "Files")
        
    EndSelect
    
  EndIf
  
EndProcedure

Procedure saveXMLTemplateFile(nTemplatePtr, bCreateFromCueFile)
  PROCNAMEC()
  Protected xmlTemplate
  Protected sMsg.s
  Protected *nRootNode
  Protected nFileSaveNode, nPrevNode
  Protected sBaseFileName.s
  
  debugMsg(sProcName, #SCS_START + ", nTemplatePtr=" + nTemplatePtr + ", bCreateFromCueFile=" + strB(bCreateFromCueFile))
  
  If nTemplatePtr >= 0
    With gaTemplate(nTemplatePtr)
      If bCreateFromCueFile
        sBaseFileName = \sCueFileName
      Else
        sBaseFileName = \sOrigTemplateFileName
      EndIf
      debugMsg(sProcName, "sBaseFileName=" + #DQUOTE$ + sBaseFileName + #DQUOTE$)
      If FileExists(sBaseFileName, #False)
        xmlTemplate = LoadXML(#PB_Any, sBaseFileName)
        If xmlTemplate
          ; Display an error message if there was a markup error
          If XMLStatus(xmlTemplate) <> #PB_XML_Success
            sMsg = "Error in the XML file " + GetFilePart(sBaseFileName) + ":" + Chr(13)
            sMsg + "Message: " + XMLError(xmlTemplate) + Chr(13)
            sMsg + "Line: " + XMLErrorLine(xmlTemplate) + "   Character: " + XMLErrorPosition(xmlTemplate)
            debugMsg(sProcName, sMsg)
            scsMessageRequester(grText\sTextError, sMsg)
          Else
            *nRootNode = MainXMLNode(xmlTemplate)      
            If *nRootNode
              scanXMLTemplate(*nRootNode, 0, nTemplatePtr)
            EndIf
          EndIf
          nFileSaveNode = XMLNodeFromPath(*nRootNode, "/Production/FileSaveInfo")
          If nFileSaveNode
            nPrevNode = updateOrCreateXMLNode(nFileSaveNode, "_Saved_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", Date()), nPrevNode)
            nPrevNode = updateOrCreateXMLNode(nFileSaveNode, "_SCS_Version_", #SCS_VERSION, nPrevNode)
            nPrevNode = updateOrCreateXMLNode(nFileSaveNode, "_SCS_Build_", grProgVersion\sBuildDateTime, nPrevNode)
          EndIf
          FormatXML(xmlTemplate, #PB_XML_ReduceNewline|#PB_XML_ReFormat|#PB_XML_WindowsNewline, 2)
          SetXMLEncoding(xmlTemplate, #PB_UTF8)
          debugMsg(sProcName, "calling SaveXML(xmlTemplate, " + #DQUOTE$ + \sCurrTemplateFileName + #DQUOTE$ + ", #PB_XML_StringFormat)")
          SaveXML(xmlTemplate, \sCurrTemplateFileName, #PB_XML_StringFormat)
          FreeXML(xmlTemplate)
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getTemplatePtr(sTemplateFileName.s)
  PROCNAMEC()
  Protected n, nTemplatePtr = -1
  
  debugMsg(sProcName, #SCS_START + ", sTemplateFileName=" + #DQUOTE$ + sTemplateFileName + #DQUOTE$)
  If sTemplateFileName
    For n = 0 To (gnTemplateCount-1)
      debugMsg(sProcName, "gaTemplate(" + n + ")\sOrigTemplateFileName=" + #DQUOTE$ + gaTemplate(n)\sOrigTemplateFileName + #DQUOTE$)
      If gaTemplate(n)\sOrigTemplateFileName = sTemplateFileName
        nTemplatePtr = n
        Break
      EndIf
    Next n
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + nTemplatePtr)
  ProcedureReturn nTemplatePtr
  
EndProcedure

Procedure setCurrTemplateFileNames()
  PROCNAMEC()
  Protected nTemplatePtr, sTemplateName.s
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grProd\sTmName=" + grProd\sTmName)
  sTemplateName = Trim(grProd\sTmName)
  If sTemplateName
    nTemplatePtr = getTemplatePtr(gsTemplateFile)
    debugMsg2(sProcName, "getTemplatePtr(" + #DQUOTE$ + gsTemplateFile + #DQUOTE$ + ")", nTemplatePtr)
    If nTemplatePtr >= 0
      With gaTemplate(nTemplatePtr)
        \sName = sTemplateName
        \sCurrTemplateFileName = gsTemplatesFolder + sTemplateName + ".scstm"
        debugMsg(sProcName, "gaTemplate(" + nTemplatePtr + ")\sCurrTemplateFileName=" + #DQUOTE$ + \sCurrTemplateFileName + #DQUOTE$)
        \sCurrTemplateDevMapFileName = gsTemplatesFolder + sTemplateName + ".scstd"
        \sCurrTemplateDatabaseFileName = gsTemplatesFolder + sTemplateName + ".scsdb"
        \sCurrTemplateBakFileName = gsTemplatesFolder + sTemplateName + ".bak"
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure renameTemplateFilesIfReqd()
  PROCNAMEC()
  Protected nTemplatePtr
  Protected nResult
  
  debugMsg(sProcName, #SCS_START)
  
  nTemplatePtr = getTemplatePtr(gsTemplateFile)
  debugMsg2(sProcName, "getTemplatePtr(" + #DQUOTE$ + gsTemplateFile + #DQUOTE$ + ")", nTemplatePtr)
  If nTemplatePtr >= 0
    With gaTemplate(nTemplatePtr)
      debugMsg(sProcName, "gaTemplate(" + nTemplatePtr + ")\sCurrTemplateFileName=" + #DQUOTE$ + \sCurrTemplateFileName + #DQUOTE$)
      debugMsg(sProcName, "gaTemplate(" + nTemplatePtr + ")\sOrigTemplateFileName=" + #DQUOTE$ + \sOrigTemplateFileName + #DQUOTE$)
      If (\sCurrTemplateFileName) And (\sCurrTemplateFileName <> \sOrigTemplateFileName)
        If FileExists(\sOrigTemplateFileName,#False)
          If FileExists(\sCurrTemplateFileName,#False) = #False
            nResult = RenameFile(\sOrigTemplateFileName, \sCurrTemplateFileName)
            debugMsg2(sProcName, "RenameFile(" + #DQUOTE$ + \sOrigTemplateFileName + #DQUOTE$ + ", " + #DQUOTE$ + \sCurrTemplateFileName + #DQUOTE$ + ")", nResult)
            If nResult
              ; rename of template file succeeded
              If FileExists(\sOrigTemplateDevMapFileName)
                RenameFile(\sOrigTemplateDevMapFileName, \sCurrTemplateDevMapFileName)
              EndIf
              If FileExists(\sOrigTemplateDatabaseFileName)
                RenameFile(\sOrigTemplateDatabaseFileName, \sCurrTemplateDatabaseFileName)
              EndIf
              If FileExists(\sOrigTemplateBakFileName)
                RenameFile(\sOrigTemplateBakFileName, \sCurrTemplateBakFileName)
              EndIf
              ; nb do not call loadTemplatesArray() yet as that may invalidate the current nTemplatePtr setting,
              ; so just reset the 'original' fields
              \sOrigTemplateFileName = \sCurrTemplateFileName
              \sOrigTemplateDevMapFileName = \sCurrTemplateDevMapFileName
              \sOrigTemplateDatabaseFileName = \sCurrTemplateDatabaseFileName
              \sOrigTemplateBakFileName = \sCurrTemplateBakFileName
              ; now reset gsTemplateFile
              gsTemplateFile = \sCurrTemplateFileName
              ; debugMsg(sProcName, "gsTemplateFile=" + #DQUOTE$ + gsTemplateFile + #DQUOTE$)
              WMN_setWindowTitle()
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure countFileStatsToBeObtainedForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k, n, bWantThis, nReqdCount, nFileStatsPtr
  
  debugMsg(sProcName, #SCS_START)
  
  k = aSub(pSubPtr)\nFirstAudIndex
  While k >= 0
    With aAud(k)
      bWantThis = #False
      If \bAudPlaceHolder = #False
        nFileStatsPtr = \nFileStatsPtr
        If nFileStatsPtr = grAudDef\nFileStatsPtr
          bWantThis = #True
        ElseIf gaFileStats(nFileStatsPtr)\sFileName <> \sFileName
          \nFileStatsPtr = grAudDef\nFileStatsPtr
          bWantThis = #True
        EndIf
      EndIf
      If bWantThis
        nReqdCount + 1
      EndIf
      k = \nNextAudIndex
    EndWith
  Wend
  
  debugMsg(sProcName, #SCS_END + ", returning " + nReqdCount)
  ProcedureReturn nReqdCount
  
EndProcedure

Procedure getFileStats(pAudPtr)
  ; Changed 3Oct2022 11.9.6 to include -75dB and -60dB in addition to -45dB and -30dB
  PROCNAMECA(pAudPtr)
  Protected n, nFileStatsPtr, sFileName.s, sFileModified.s, qFileSize.q, nFileDuration
  Protected bProcessThisFile
  Protected nStream.l, nSampleBufPtr, nSamples, nBassResult.l
  Protected nFlags.l
  Protected Dim afBuf.f(25000)  ; 25000 floats, for reading 100000 bytes
  Protected fThisAbsFloat.f, fMaxAbsFloat.f
  Protected nSamplesInStartSilence, nSamplesInStart75, nSamplesInStart60, nSamplesInStart45, nSamplesInStart30
  Protected bStartSilenceDone, bStart75Done, bStart60Done, bStart45Done, bStart30Done
  Protected nSamplesBeforeEndSilence, nSamplesBeforeEnd75, nSamplesBeforeEnd60, nSamplesBeforeEnd45, nSamplesBeforeEnd30
  Protected nSampleCount, nSamplesInFile
  Protected qPos.q, dSeconds.d
  Protected nDatabaseNo, sSQLRequest.s, nSQLResult
  Protected sSubType.s
  Static fThresholdSilence.f, fThreshold75.f, fThreshold60.f, fThreshold45.f, fThreshold30.f
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    fThresholdSilence = 0
    fThreshold75 = convertDBLevelToBVLevel(-75)
    fThreshold60 = convertDBLevelToBVLevel(-60)
    fThreshold45 = convertDBLevelToBVLevel(-45)
    fThreshold30 = convertDBLevelToBVLevel(-30)
    bStaticLoaded = #True
  EndIf
  
  ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bAudPlaceHolder=" + strB(aAud(pAudPtr)\bAudPlaceHolder) + ", \nFileStatsPtr=" + aAud(pAudPtr)\nFileStatsPtr)
  If aAud(pAudPtr)\bAudPlaceHolder = #False
    sFileName = aAud(pAudPtr)\sFileName
    qFileSize = FileSize(sFileName)
    sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
    nFileStatsPtr = aAud(pAudPtr)\nFileStatsPtr
    nFileDuration = aAud(pAudPtr)\nFileDuration
    sSubType = getSubTypeForAud(pAudPtr)
    If nFileDuration <= getFileScanMaxLengthMS(sSubType) Or getFileScanMaxLengthMS(sSubType) < 0
      If nFileStatsPtr = grAudDef\nFileStatsPtr
        ; no file stats yet recorded for aAud(pAudPtr), but check to see if we already have stats for this file (probably from another aAud())
        For n = 1 To gnLastFileStats
          With gaFileStats(n)
            If (\sFileName = sFileName) And (\qFileSize = qFileSize) And (\sFileModified = sFileModified)
              ; stats for this file already exist, so use this gaFileStats() entry for aAud(pAudPtr)
              nFileStatsPtr = n
              aAud(pAudPtr)\nFileStatsPtr = nFileStatsPtr
              Break
            EndIf
          EndWith
        Next n
        If nFileStatsPtr = grAudDef\nFileStatsPtr
          ; no stats found for this file in gaFileStats() so process this file now
          bProcessThisFile = #True
        EndIf
      Else
        With gaFileStats(nFileStatsPtr)
          If (\sFileName <> sFileName) Or (\qFileSize <> qFileSize) Or (\sFileModified <> sFileModified)
            ; the assigned gaFileStats() entry for aAud(pAudPtr) is obsolete, proably because the nominated file has been changed or edited, so process this file now to create a new entry in gaFileStats()
            bProcessThisFile = #True
          EndIf
        EndWith
      EndIf
    Else
      ; debugMsg(sProcName, "ignored because nFileDuration=" + nFileDuration)
      aAud(pAudPtr)\nFileStatsPtr = -2  ; indicates file is to be excluded from future calls to getFileStats()
    EndIf                               ; EndIf nFileDuration < (grEditingOptions\nFileScanMaxLength * 60000)
    
    ; debugMsg(sProcName, "bProcessThisFile=" + strB(bProcessThisFile))
    If bProcessThisFile
      nFlags = #BASS_STREAM_DECODE | #SCS_BASS_UNICODE | #BASS_STREAM_PRESCAN | #BASS_SAMPLE_FLOAT
      nStream = BASS_StreamCreateFile(#BASSFALSE, @sFileName, 0, 0, nFlags)
      ; debugMsg3(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ") returned " + nStream)
      If nStream = 0
        ; debugMsg3(sProcName, "BASS_StreamCreateFile() Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
        ProcedureReturn
      EndIf
      qPos = BASS_ChannelGetLength(nStream, #BASS_POS_BYTE)
      dSeconds = BASS_ChannelBytes2Seconds(nStream, qPos)
      nFileDuration = (dSeconds * 1000)
      gnLastFileStats + 1
      If gnLastFileStats > ArraySize(gaFileStats())
        ReDim gaFileStats(gnLastFileStats+20)
      EndIf
      gaFileStats(gnLastFileStats) = grFileStatsDef
      nFileStatsPtr = gnLastFileStats
      With gaFileStats(gnLastFileStats)
        \sFileName = sFileName
        \qFileSize = qFileSize
        \sFileModified = sFileModified
        \nFileDuration = nFileDuration
        
        aAud(pAudPtr)\nFileStatsPtr = nFileStatsPtr
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileStatsPtr=" + aAud(pAudPtr)\nFileStatsPtr)
        
        ; INFO: start of 'get data' loop
        ; debugMsg(sProcName, "start loop")
        
        DisableDebugger
        
        While #True
          nBassResult = BASS_ChannelGetData(nStream, @afBuf(0), 100000 | #BASS_DATA_FLOAT) ; decode some data
          ; debugMsg2(sProcName, "BASS_ChannelGetData(" + nStream + ", @afBuf(0), 100000 | #BASS_DATA_FLOAT)", nBassResult)
          If nBassResult = -1
            If BASS_ErrorGetCode() = #BASS_ERROR_ENDED
              ; Debug "end of file"
              Break
            Else
              ; Debug "other error"
              Break
            EndIf
          ElseIf nBassResult >= 0
            nSamples = nBassResult >> 2
            nSamplesInFile + nSamples
            nSampleBufPtr = 0
            While (nSampleBufPtr < nSamples)
              fThisAbsFloat = Abs(afBuf(nSampleBufPtr))
              If fThisAbsFloat > fMaxAbsFloat
                ; debugMsg(sProcName, "sFileName=" + GetFilePart(sFileName) +  ", nSampleBufPtr=" + nSampleBufPtr + ", fThisAbsFloat=" + fThisAbsFloat)
                fMaxAbsFloat = fThisAbsFloat
              EndIf
              nSampleCount + 1
              
              If fThisAbsFloat <= fThresholdSilence
                If bStartSilenceDone = #False
                  nSamplesInStartSilence + 1
                EndIf
              Else
                bStartSilenceDone = #True
                nSamplesBeforeEndSilence = nSampleCount
              EndIf
              
              If fThisAbsFloat <= fThreshold75
                If bStart75Done = #False
                  nSamplesInStart75 + 1
                EndIf
              Else
                bStart75Done = #True
                nSamplesBeforeEnd75 = nSampleCount
              EndIf
              
              If fThisAbsFloat <= fThreshold60
                If bStart60Done = #False
                  nSamplesInStart60 + 1
                EndIf
              Else
                bStart60Done = #True
                nSamplesBeforeEnd60 = nSampleCount
              EndIf
              
              If fThisAbsFloat <= fThreshold45
                If bStart45Done = #False
                  nSamplesInStart45 + 1
                EndIf
              Else
                bStart45Done = #True
                nSamplesBeforeEnd45 = nSampleCount
              EndIf
              
              If fThisAbsFloat <= fThreshold30
                If bStart30Done = #False
                  nSamplesInStart30 + 1
                EndIf
              Else
                bStart30Done = #True
                nSamplesBeforeEnd30 = nSampleCount
              EndIf
              
              nSampleBufPtr + 1
              
            Wend ; End While (nSampleBufPtr < nSamples)
          EndIf ; EndIf nBassResult > 0
        Wend    ; end While BASS_ChannelIsActive(nStream)
        
        EnableDebugger
        
        ; debugMsg(sProcName, "end loop")
        ; INFO: end of 'get data' loop
        
        If nSamplesInStartSilence > 0
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesInStartSilence << 2)
          \nSilenceStartAt = (dSeconds * 1000)
          If \nSilenceStartAt > 1
            ; step back one millisecond to make sure any rounding doesn't clip the start of the sound
            \nSilenceStartAt - 1
          EndIf
        EndIf
        If nSamplesInStart75 > 0
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesInStart75 << 2)
          \nM75dBStartAt = (dSeconds * 1000)
          If \nM75dBStartAt > 1
            ; step back one millisecond to make sure any rounding doesn't clip the start of the sound
            \nM75dBStartAt - 1
          EndIf
        EndIf
        If nSamplesInStart60 > 0
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesInStart60 << 2)
          \nM60dBStartAt = (dSeconds * 1000)
          If \nM60dBStartAt > 1
            ; step back one millisecond to make sure any rounding doesn't clip the start of the sound
            \nM60dBStartAt - 1
          EndIf
        EndIf
        If nSamplesInStart45 > 0
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesInStart45 << 2)
          \nM45dBStartAt = (dSeconds * 1000)
          If \nM45dBStartAt > 1
            ; step back one millisecond to make sure any rounding doesn't clip the start of the sound
            \nM45dBStartAt - 1
          EndIf
        EndIf
        If nSamplesInStart30 > 0
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesInStart30 << 2)
          \nM30dBStartAt = (dSeconds * 1000)
          If \nM30dBStartAt > 1
            ; step back one millisecond to make sure any rounding doesn't clip the start of the sound
            \nM30dBStartAt - 1
          EndIf
        EndIf
        
        If nSamplesBeforeEndSilence < nSamplesInFile
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesBeforeEndSilence << 2)
          \nSilenceEndAt = (dSeconds * 1000)
          If \nSilenceEndAt < (nFileDuration - 2)
            ; step forward one millisecond to make sure any rounding doesn't clip the end of the sound
            \nSilenceEndAt + 1
          EndIf
        Else
          \nSilenceEndAt = -2 ; -2 used in many numerc 'positive' fields to indicate blank when displayed
        EndIf
        If nSamplesBeforeEnd75 < nSamplesInFile
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesBeforeEnd75 << 2)
          \nM75dBEndAt = (dSeconds * 1000)
          If \nM75dBEndAt < (nFileDuration - 2)
            ; step forward one millisecond to make sure any rounding doesn't clip the end of the sound
            \nM75dBEndAt + 1
          EndIf
        Else
          \nM75dBEndAt = -2 ; -2 used in many numerc 'positive' fields to indicate blank when displayed
        EndIf
        If nSamplesBeforeEnd60 < nSamplesInFile
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesBeforeEnd60 << 2)
          \nM60dBEndAt = (dSeconds * 1000)
          If \nM60dBEndAt < (nFileDuration - 2)
            ; step forward one millisecond to make sure any rounding doesn't clip the end of the sound
            \nM60dBEndAt + 1
          EndIf
        Else
          \nM60dBEndAt = -2 ; -2 used in many numerc 'positive' fields to indicate blank when displayed
        EndIf
        If nSamplesBeforeEnd45 < nSamplesInFile
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesBeforeEnd45 << 2)
          \nM45dBEndAt = (dSeconds * 1000)
          If \nM45dBEndAt < (nFileDuration - 2)
            ; step forward one millisecond to make sure any rounding doesn't clip the end of the sound
            \nM45dBEndAt + 1
          EndIf
        Else
          \nM45dBEndAt = -2 ; -2 used in many numerc 'positive' fields to indicate blank when displayed
        EndIf
        If nSamplesBeforeEnd30 < nSamplesInFile
          dSeconds = BASS_ChannelBytes2Seconds(nStream, nSamplesBeforeEnd30 << 2)
          \nM30dBEndAt = (dSeconds * 1000)
          If \nM30dBEndAt < (nFileDuration - 2)
            ; step forward one millisecond to make sure any rounding doesn't clip the end of the sound
            \nM30dBEndAt + 1
          EndIf
        Else
          \nM30dBEndAt = -2 ; -2 used in many numerc 'positive' fields to indicate blank when displayed
        EndIf
        
        \nMaxAbsSample = fMaxAbsFloat * 10000
        
      EndWith ; EndWith gaFileStats(gnLastFileStats)
      nBassResult = BASS_StreamFree(nStream)
      ; debugMsg2(sProcName, "BASS_StreamFree(" + nStream + ")", nBassResult)
      gbFileStatsChanged = #True
      
      ; update temp database table FileStats
      saveFileStatsToTempDatabase(pAudPtr)
      
    EndIf ; EndIf bProcessThisFile
    
  EndIf ; EndIf aAud(pAudPtr)\bAudPlaceHolder = #False
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listDatabaseFileStats(nDatabaseNo)
  ; Changed 3Oct2022 11.9.6 to add -75dB and -60dB
  PROCNAMEC()
  Protected sRequest.s
  Protected sFileName.s, sFileModified.s, nFileSize
  Protected nFileDuration, nSilenceStartAt, nSilenceEndAt, nM45dBStartAt, nM45dBEndAt, nM30dBStartAt, nM30dBEndAt, nMaxAbsSample
  Protected nM75dBStartAt, nM75dBEndAt, nM60dBStartAt, nM60dBEndAt
  
  Select nDatabaseNo
    Case grTempDB\nTempDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Temp Database)")
    Case grProd\nDatabaseNo
      debugMsg(sProcName, #SCS_START + " (Prod Database)")
    Default
      ; shouldn't get here
      debugMsg(sProcName, #SCS_START + ", nDatabaseNo=" + nDatabaseNo)
  EndSelect
  
  If IsDatabase(nDatabaseNo)
    sRequest = "SELECT FileName, FileModified, FileSize, FileDuration, SilenceStartAt, SilenceEndAt, " +
               "M75dBStartAt, M75dBEndAt, M60dBStartAt, M60dBEndAt, M45dBStartAt, M45dBEndAt, M30dBStartAt, M30dBEndAt, MaxAbsSample " +
               "from FileStats ORDER BY FileName"
    If DatabaseQuery(nDatabaseNo, sRequest)
      While NextDatabaseRow(nDatabaseNo)
        sFileName = GetDatabaseString(nDatabaseNo, 0)
        sFileModified = GetDatabaseString(nDatabaseNo, 1)
        nFileSize = GetDatabaseLong(nDatabaseNo, 2)
        nFileDuration = GetDatabaseLong(nDatabaseNo, 3)
        nSilenceStartAt = GetDatabaseLong(nDatabaseNo, 4)
        nSilenceEndAt = GetDatabaseLong(nDatabaseNo, 5)
        nM75dBStartAt = GetDatabaseLong(nDatabaseNo, 6)
        nM75dBEndAt = GetDatabaseLong(nDatabaseNo, 7)
        nM60dBStartAt = GetDatabaseLong(nDatabaseNo, 8)
        nM60dBEndAt = GetDatabaseLong(nDatabaseNo, 9)
        nM45dBStartAt = GetDatabaseLong(nDatabaseNo, 10)
        nM45dBEndAt = GetDatabaseLong(nDatabaseNo, 11)
        nM30dBStartAt = GetDatabaseLong(nDatabaseNo, 12)
        nM30dBEndAt = GetDatabaseLong(nDatabaseNo, 13)
        nMaxAbsSample = GetDatabaseLong(nDatabaseNo, 14)
        debugMsg(sProcName, "FileName=" + #DQUOTE$ + sFileName + #DQUOTE$)
        debugMsg(sProcName, ".. FileModified=" + #DQUOTE$ + sFileModified + #DQUOTE$ +
                            ", FileSize=" + nFileSize + ", FileDuration=" + nFileDuration +
                            ", SilenceStartAt=" + nSilenceStartAt + ", SilenceEndAt=" + nSilenceEndAt +
                            ", M75dBStartAt=" + nM75dBStartAt + ", M75dBEndAt=" + nM75dBEndAt +
                            ", M60dBStartAt=" + nM60dBStartAt + ", M60dBEndAt=" + nM60dBEndAt +
                            ", M45dBStartAt=" + nM45dBStartAt + ", M45dBEndAt=" + nM45dBEndAt +
                            ", M30dBStartAt=" + nM30dBStartAt + ", M30dBEndAt=" + nM30dBEndAt +
                            ", MaxAbsSample=" + nMaxAbsSample)
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadFileStatsArrayFromProdDatabase()
  ; Changed 3Oct2022 11.9.6 to add -75dB and -60dB
  PROCNAMEC()
  Protected sRequest.s
  Protected nDatabaseNo
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grProd\nDatabaseNo=" + grProd\nDatabaseNo)
  nDatabaseNo = grProd\nDatabaseNo
  gnLastFileStats = 0
  gbFileStatsChanged = #False
  
  If IsDatabase(nDatabaseNo)
    sRequest = "SELECT FileName, FileModified, FileSize, FileDuration, SilenceStartAt, SilenceEndAt, " +
               "M75dBStartAt, M75dBEndAt, M60dBStartAt, M60dBEndAt, M45dBStartAt, M45dBEndAt, M30dBStartAt, M30dBEndAt, MaxAbsSample " +
               "from FileStats ORDER BY FileName"
    If DatabaseQuery(nDatabaseNo, sRequest)
      While NextDatabaseRow(nDatabaseNo)
        gnLastFileStats + 1
        If gnLastFileStats > ArraySize(gaFileStats())
          ReDim gaFileStats(gnLastFileStats+20)
        EndIf
        gaFileStats(gnLastFileStats) = grFileStatsDef
        With gaFileStats(gnLastFileStats)
          \sFileName = GetDatabaseString(nDatabaseNo, 0)
          \sFileModified = GetDatabaseString(nDatabaseNo, 1)
          \qFileSize = GetDatabaseQuad(nDatabaseNo, 2)
          \nFileDuration = GetDatabaseLong(nDatabaseNo, 3)
          \nSilenceStartAt = GetDatabaseLong(nDatabaseNo, 4)
          \nSilenceEndAt = GetDatabaseLong(nDatabaseNo, 5)
          \nM75dBStartAt = GetDatabaseLong(nDatabaseNo, 6)
          \nM75dBEndAt = GetDatabaseLong(nDatabaseNo, 7)
          \nM60dBStartAt = GetDatabaseLong(nDatabaseNo, 8)
          \nM60dBEndAt = GetDatabaseLong(nDatabaseNo, 9)
          \nM45dBStartAt = GetDatabaseLong(nDatabaseNo, 10)
          \nM45dBEndAt = GetDatabaseLong(nDatabaseNo, 11)
          \nM30dBStartAt = GetDatabaseLong(nDatabaseNo, 12)
          \nM30dBEndAt = GetDatabaseLong(nDatabaseNo, 13)
          \nMaxAbsSample = GetDatabaseLong(nDatabaseNo, 14)
          debugMsg(sProcName, "gaFileStats(" + gnLastFileStats + ")\sFileName=" + GetFilePart(\sFileName) + ", \nSilenceStartAt=" + \nSilenceStartAt + ", \nSilenceEndAt=" + \nSilenceEndAt +
                              ", \nM75dBStartAt=" + \nM75dBStartAt + ", \nM75dBEndAt=" + \nM75dBEndAt + ", \nM60dBStartAt=" + \nM60dBStartAt + ", \nM60dBEndAt=" + \nM60dBEndAt +
                              ", \nM45dBStartAt=" + \nM45dBStartAt + ", \nM45dBEndAt=" + \nM45dBEndAt + ", \nM30dBStartAt=" + \nM30dBStartAt + ", \nM30dBEndAt=" + \nM30dBEndAt +
                              ", \nMaxAbsSample=" + \nMaxAbsSample)
        EndWith
      Wend
      FinishDatabaseQuery(nDatabaseNo)
    EndIf
  Else
    debugMsg(sProcName, "IsDatabase(" + nDatabaseNo + ") returned #False")
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", gnLastFileStats=" + gnLastFileStats)
  
EndProcedure

Procedure setFileStatsPtrs()
  PROCNAMEC()
  Protected f, k, nFileDataPtr
  
  debugMsg(sProcName, #SCS_START)
  
  ; load aAud()\nFileStatsPtr values
  For k = 1 To gnLastAud
    With aAud(k)
      nFileDataPtr = \nFileDataPtr
      \nFileStatsPtr = grAudDef\nFileStatsPtr
      For f = 1 To gnLastFileStats
        If gaFileStats(f)\sFileName = \sFileName
          If nFileDataPtr > 0
            If (gaFileStats(f)\sFileModified = gaFileData(nFileDataPtr)\sFileModified) And
               (gaFileStats(f)\qFileSize = gaFileData(nFileDataPtr)\qFileSize)
              \nFileStatsPtr = f
              Break ; Break f
            EndIf
          EndIf
        EndIf
      Next f
    EndWith
  Next k
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getFixTypeIndexForFixture(*rProd.tyProd, *rSub.tySub, sFixtureCode.s)
  PROCNAMEC()
  Protected nProdDevNo, n, sFixTypeName.s, nFixTypeIndex=-1
  
  nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, *rSub\sLTLogicalDev)
  If nProdDevNo >= 0
    With *rProd\aLightingLogicalDevs(nProdDevNo)
      For n = 0 To \nMaxFixture
        If \aFixture(n)\sFixtureCode = sFixtureCode
          sFixTypeName = \aFixture(n)\sFixTypeName
          Break
        EndIf
      Next n
    EndWith
    If sFixTypeName
      With *rProd
        For n = 0 To \nMaxFixType
          If \aFixTypes(n)\sFixTypeName = sFixTypeName
            nFixTypeIndex = n
            Break
          EndIf
        Next n
      EndWith
    EndIf
  EndIf
  ProcedureReturn nFixTypeIndex
EndProcedure

Procedure getTotalChansForFixture(*rProd.tyProd, *rSub.tySub, sFixtureCode.s)
  PROCNAMEC()
  Protected nFixTypeIndex, nTotalChans
  
  nFixTypeIndex = getFixTypeIndexForFixture(*rProd, *rSub, sFixtureCode)
  If nFixTypeIndex >= 0
    nTotalChans = *rProd\aFixTypes(nFixTypeIndex)\nTotalChans
  EndIf
  ; debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", nFixTypeIndex=" + nFixTypeIndex + ", nTotalChans=" + nTotalChans)
  ProcedureReturn nTotalChans
EndProcedure

Procedure.s getFixtureTypeForLightingDeviceFixtureCode(*rProd.tyProd, sLogicalDev.s, sFixtureCode.s)
  ; PROCNAMEC()
  Protected d, n, sFixtureType.s
  
  With *rProd
    For d = 0 To \nMaxLightingLogicalDev
      If \aLightingLogicalDevs(d)\sLogicalDev = sLogicalDev
        For n = 0 To \aLightingLogicalDevs(d)\nMaxFixture
          If \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode = sFixtureCode
            sFixtureType = \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName
            Break 2
          EndIf
        Next n
        Break
      EndIf
    Next d
    ; debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", sFixtureCode=" + sFixtureCode + ", sFixtureType=" + sFixtureType)
    ProcedureReturn sFixtureType
  EndWith
EndProcedure

Procedure getFixtureDfltStartChanForLightingDeviceFixtureCode(*rProd.tyProd, sLogicalDev.s, sFixtureCode.s)
  ; PROCNAMEC()
  Protected d, n, nDfltStartChan
  
  With *rProd
    For d = 0 To \nMaxLightingLogicalDev
      If \aLightingLogicalDevs(d)\sLogicalDev = sLogicalDev
        For n = 0 To \aLightingLogicalDevs(d)\nMaxFixture
          If \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode = sFixtureCode
            nDfltStartChan = \aLightingLogicalDevs(d)\aFixture(n)\nDefaultDMXStartChannel
            Break 2
          EndIf
        Next n
        Break
      EndIf
    Next d
    ; debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", sFixtureCode=" + sFixtureCode + ", nDfltStartChan=" + nDfltStartChan)
    ProcedureReturn nDfltStartChan
  EndWith
EndProcedure

Procedure getTotalChansForFixtureType(*rProd.tyProd, sFixtureType.s)
  ; PROCNAMEC()
  Protected nLightingIndex, nFixTypeIndex, nTotalChans
  
  With *rProd
    For nFixTypeIndex = 0 To \nMaxFixType
      If \aFixTypes(nFixTypeIndex)\sFixTypeName = sFixtureType
        nTotalChans = *rProd\aFixTypes(nFixTypeIndex)\nTotalChans
        Break
      EndIf
    Next nFixTypeIndex
  EndWith
  ; debugMsg(sProcName, "sFixtureType=" + sFixtureType + ", nTotalChans=" + nTotalChans)
  ProcedureReturn nTotalChans
EndProcedure

Procedure syncLightingSubForFixtures(*rProd.tyProd, *rSub.tySub, nChaseStepIndex=-1, nFixtureIndex=-1)
  PROCNAMEC()
  Protected nMyChaseStepIndex, nFromChaseStepIndex, nUpToChaseStepIndex
  Protected nMyFixtureIndex, nFromFixtureIndex, nUpToFixtureIndex, nMyChanIndex
  Protected sFixtureCode.s, nTotalChans
  Protected sFixTypeName.s, nFixTypeIndex
  
  debugMsg(sProcName, #SCS_START + ", nChaseStepIndex=" + nChaseStepIndex + ", nFixtureIndex=" + nFixtureIndex + ", *rSub\nMaxFixture=" + *rSub\nMaxFixture)
  
  If (*rSub\nMaxChaseStepIndex >= 0) And (*rSub\nMaxFixture >= 0)
    
    ; set chase step range
    If nChaseStepIndex >= 0
      nFromChaseStepIndex = nChaseStepIndex
      nUpToChaseStepIndex = nChaseStepIndex
    Else
      nFromChaseStepIndex = 0
      nUpToChaseStepIndex = *rSub\nMaxChaseStepIndex
    EndIf
    
    ; set fixture range
    If nFixtureIndex >= 0
      nFromFixtureIndex = nFixtureIndex
      nUpToFixtureIndex = nFixtureIndex
    Else
      nFromFixtureIndex = 0
      nUpToFixtureIndex = *rSub\nMaxFixture
    EndIf
    
    For nMyChaseStepIndex = nFromChaseStepIndex To nUpToChaseStepIndex
      If nMyChaseStepIndex <= *rSub\nMaxChaseStepIndex
        With *rSub\aChaseStep(nMyChaseStepIndex)
          ReDim \aFixtureItem(*rSub\nMaxFixture)
          For nMyFixtureIndex = nFromFixtureIndex To nUpToFixtureIndex
            If nMyFixtureIndex <= *rSub\nMaxFixture ; nb nMyFixtureIndex could be > *rSub\nMaxFixture if the user reduces the number of chase steps
              sFixtureCode = *rSub\aLTFixture(nMyFixtureIndex)\sLTFixtureCode
              \aFixtureItem(nMyFixtureIndex)\sFixtureCode = sFixtureCode
              nFixTypeIndex = getFixTypeIndexForFixture(*rProd, *rSub, sFixtureCode)
              If nFixTypeIndex >= 0
                nTotalChans = *rProd\aFixTypes(nFixTypeIndex)\nTotalChans
                If nTotalChans > 0
                  ReDim \aFixtureItem(nMyFixtureIndex)\aFixChan(nTotalChans-1)
                  For nMyChanIndex = 0 To nTotalChans-1
                    \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex) = grLTFixChanDef
                    \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\nRelChanNo = nMyChanIndex+1
                    If gbLoadingCueFile = #False
                      \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\sDMXDisplayValue = *rProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nMyChanIndex)\sDefault
                      If DMX_validateAndConvertDMXDisplayValue(\aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\sDMXDisplayValue)
                        \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\nDMXDisplayValue = grDMXValueInfo\nDMXDisplayValue
                        \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\nDMXAbsValue = grDMXValueInfo\nDMXAbsValue
                        \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\bDMXAbsValue = grDMXValueInfo\bDMXAbsValue
                      EndIf
                      If *rProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nMyChanIndex)\bDimmerChan
                        \aFixtureItem(nMyFixtureIndex)\aFixChan(nMyChanIndex)\bApplyFadeTime = #True
                      EndIf
                    EndIf
                  Next nMyChanIndex
                EndIf ; EndIf nTotalChans > 0
              EndIf ; EndIf nFixTypeIndex >= 0
            EndIf ; EndIf nMyFixtureIndex <= *rSub\nMaxFixture
          Next nMyFixtureIndex
        EndWith
      EndIf ; EndIf nMyChaseStepIndex <= *rSub\nMaxChaseStepIndex
    Next nMyChaseStepIndex
  EndIf
  
EndProcedure

Procedure.s SizeIt(Value.q)
  ; from PB Windows Forum posting for topic "Getting Free Disk Space" https://www.purebasic.fr/english/viewtopic.php?f=5&t=51332#p445263
  Protected unit.b=0, byte.q, nSize.s, pos.l
 
  byte = Value
  While byte >= 1024
    byte / 1024 : unit + 1
  Wend
 
  If unit : nSize = StrD(Value/Pow(1024, unit), 15) : pos = FindString(nSize, ".") : Else : nSize = Str(Value) : EndIf
 
  If unit : If pos <  4 : nSize=Mid(nSize,1,pos+2) : Else : nSize = Mid(nSize, 1, pos-1) : EndIf : EndIf
 
  ProcedureReturn nSize + " " + StringField("bytes,KB,MB,GB,TB,PB", unit+1, ",") 
EndProcedure

Procedure getDriveFreeSpace(sDrive.s)
  ; based on code from PB Windows Forum posting for topic "Getting Free Disk Space" https://www.purebasic.fr/english/viewtopic.php?f=5&t=51332#p445263
  Protected sDriveId.s, qBytesFreeToCaller.q, qTotalBytes.q, qTotalFreeBytes.q, qReturnValue.q
  Protected dwResult.l, dwError.l, sMsgBuf.s, nMsgLen
  
  SetErrorMode_(#SEM_FAILCRITICALERRORS)
  sDriveId = sDrive
  dwResult = GetDiskFreeSpaceEx_(@sDriveId, @qBytesFreeToCaller, @qTotalBytes, @qTotalFreeBytes)
  If dwResult = 0
    dwError = GetLastError_()
    sMsgBuf = Space(256)
    nMsgLen = FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM, 0, dwError, 0, @sMsgBuf, 256, 0)
    grCFH\bDriveFreeSpaceResult = #False
    grCFH\qDriveFreeSpaceBytes = 0
    grCFH\sDriveFreeSpaceMsg = Left(sMsgBuf, nMsgLen)
  Else
    grCFH\bDriveFreeSpaceResult = #True
    grCFH\qDriveFreeSpaceBytes = qBytesFreeToCaller
    grCFH\sDriveFreeSpaceMsg = SizeIt(qBytesFreeToCaller)
  EndIf
  SetErrorMode_(0)
  
  ; nb all results returned in grCFH
  
EndProcedure

Procedure setLightingPre118Flag(*rProd.tyProd)
  PROCNAMEC()
  Protected i, j, nLightingCueCount, nEmptyCount, bLightingPre118
  
  ; If we have at least one lighting cue (enabled or not) but no fixture types, then this must be a pre-11.8 lighting definition
  
  With *rProd
    ; debugMsg(sProcName, "*rProd\nMaxFixType=" + \nMaxFixType)
    If \nMaxFixType < 0
      bLightingPre118 = #True
      For i = 1 To gnLastCue
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bSubTypeK=" + strB(aCue(i)\bSubTypeK))
        If aCue(i)\bSubTypeK
          nLightingCueCount + 1
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeK
              Select aSub(j)\nLTEntryType
                Case 0, #SCS_LT_ENTRY_TYPE_BLACKOUT, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP, #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS ; 12Nov2021 11.8.6bw added 0 following email from Phil Cohen
                  bLightingPre118 = #False
                  Break 2 ; Break j, i
              EndSelect
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      Next i
    EndIf
    If nLightingCueCount = 0
      bLightingPre118 = #False
    EndIf
    \bLightingPre118 = bLightingPre118
    If bLightingPre118
      debugMsg(sProcName, "*rProd\bLightingPre118=" + strB(\bLightingPre118))
    EndIf
  EndWith
  
EndProcedure

Procedure setVideoFilePresent()
  ; Added 30Apr2024 11.10.2ck
  PROCNAMEC()
  Protected i, j, k, bVideoFilePresent
  
  For i = 1 To gnLastCue
    If aCue(1)\bCueEnabled And aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled And aSub(j)\bSubTypeA And aSub(j)\bMuteVideoAudio = #False
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            If aAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO
              bVideoFilePresent = #True
              Break 3 ; Break k, j, i
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  If grProd\bVideoFilePresent <> bVideoFilePresent
    grProd\bVideoFilePresent = bVideoFilePresent
    debugMsg(sProcName, "grProd\bVideoFilePresent=" + strB(grProd\bVideoFilePresent))
    displayLabels(#True, #True)
  EndIf
  
EndProcedure

Procedure getCtrlMidiRemoteDevForLogicalDev(sCSLogicalDev.s)
  PROCNAMEC()
  Protected nDevPtr, nCtrlMidiRemoteDev
  
  nDevPtr = getProdLogicalDevPtrForLogicalDev(sCSLogicalDev, #SCS_DEVGRP_CTRL_SEND)
  If nDevPtr >= 0
    nCtrlMidiRemoteDev = grProd\aCtrlSendLogicalDevs(nDevPtr)\nCtrlMidiRemoteDev
  Else
    nCtrlMidiRemoteDev = -1
  EndIf
  ProcedureReturn nCtrlMidiRemoteDev
  
EndProcedure

Procedure.s getCtrlMidiRemoteDevCodeForLogicalDev(sCSLogicalDev.s)
  PROCNAMEC()
  Protected nDevPtr, sCtrlMidiRemoteDevCode.s
  
  nDevPtr = getProdLogicalDevPtrForLogicalDev(sCSLogicalDev, #SCS_DEVGRP_CTRL_SEND)
  If nDevPtr >= 0
    sCtrlMidiRemoteDevCode = grProd\aCtrlSendLogicalDevs(nDevPtr)\sCtrlMidiRemoteDevCode
  EndIf
  ProcedureReturn sCtrlMidiRemoteDevCode
  
EndProcedure

Procedure getCtrlMidiChannelForLogicalDev(sCSLogicalDev.s)
  PROCNAMEC()
  Protected nDevPtr, nCtrlMidiChannel
  
  nDevPtr = getProdLogicalDevPtrForLogicalDev(sCSLogicalDev, #SCS_DEVGRP_CTRL_SEND)
  If nDevPtr >= 0
    nCtrlMidiChannel = grProd\aCtrlSendLogicalDevs(nDevPtr)\nCtrlMidiChannel
  Else
    nCtrlMidiChannel = -1
  EndIf
  ProcedureReturn nCtrlMidiChannel
  
EndProcedure

Procedure addOneAudioLogicalDev(*rProd.tyProd)
  *rProd\nMaxAudioLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneVidAudLogicalDev(*rProd.tyProd)
  *rProd\nMaxVidAudLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneVidCapLogicalDev(*rProd.tyProd)
  *rProd\nMaxVidCapLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneFixType(*rProd.tyProd)
  *rProd\nMaxFixType + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneLightingLogicalDev(*rProd.tyProd)
  *rProd\nMaxLightingLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneCtrlSendLogicalDev(*rProd.tyProd)
  *rProd\nMaxCtrlSendLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneCueCtrlLogicalDev(*rProd.tyProd)
  *rProd\nMaxCueCtrlLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
  ED_renumberCueCtrlLogicalDevs(*rProd)
EndProcedure

Procedure addOneLiveInputLogicalDev(*rProd.tyProd)
  *rProd\nMaxLiveInputLogicalDev + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneInGrp(*rProd.tyProd)
  *rProd\nMaxInGrp + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure addOneInGrpLiveInput(*rProd.tyProd, nInGrpNo)
  *rProd\aInGrps(nInGrpNo)\nMaxInGrpItem + 1
  ED_setDevDisplayMaximums(*rProd)
EndProcedure

Procedure scanCueFileItems(*CurrentNode, CurrentSublevel)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s, sTagCode.s
  Protected sParentNodeName.s
  Protected *nChildNode
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    ; NOTE: not interested in XML Attributes when determining counts
    
    ; debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue)
    
    ; Remove any trailing digits from the node name, eg if sNodeName = "PRLogicalDev2" then sTagCode will be set to "PRLogicalDev"
    sTagCode = sNodeName
    While (Right(sTagCode, 1) >= "0") And (Right(sTagCode, 1) <= "9")
      sTagCode = Left(sTagCode, Len(sTagCode) - 1)
    Wend
    
    With grCueFileItemCounts
      Select sTagCode
          
        Case "PRLogicalDev"
          If sParentNodeName = "Head" : \nCountAudioLogicalDevs + 1 : EndIf
          
        Case "PRVidAudLogicalDev"
          If sParentNodeName = "Head" : \nCountVidAudLogicalDevs + 1 : EndIf
          
        Case "PRVidCapLogicalDev"
          If sParentNodeName = "Head" : \nCountVidCapLogicalDevs + 1 : EndIf
          
        Case "FixType"
          If sParentNodeName = "Head" : \nCountFixTypes + 1 : EndIf
          
        Case "PRLTDevice"
          If sParentNodeName = "Head" : \nCountLightingLogicalDevs + 1 : EndIf
          
        Case "PRCSDevice"
          If sParentNodeName = "Head" : \nCountCtrlSendLogicalDevs + 1 : EndIf
          
        Case "PRCCDevice"
          If sParentNodeName = "Head" : \nCountCueCtrlLogicalDevs + 1 : EndIf
          
        Case "PRInputLogicalDev"
          If sParentNodeName = "Head" : \nCountLiveInputLogicalDevs + 1 : EndIf
          
        Case "PRInGrp"
          If sParentNodeName = "Head" : \nCountInGrps + 1 : EndIf
          
        Case "Cue"
          If sParentNodeName = "Production" : \nCountCues + 1 : EndIf
          
        Case "Sub"
          If sParentNodeName = "Cue" : \nCountSubs + 1 : EndIf
          
        Case "AudioFile", "VideoFile"
          If sParentNodeName = "Sub" : \nCountAuds + 1 : EndIf

      EndSelect
      
      ; Now get the first child node (if any)
      *nChildNode = ChildXMLNode(*CurrentNode)
      
      While *nChildNode <> 0
        ; Loop through all available child nodes and call this procedure again
        scanCueFileItems(*nChildNode, CurrentSublevel + 1)
        *nChildNode = NextXMLNode(*nChildNode)
      Wend        
      
    EndWith
    
  EndIf
  
EndProcedure

Procedure.s countCueFileItems(sCueFileName.s)
  PROCNAMEC()
  Protected rCueFileItemCountsDef.tyCueFileItemCounts
  Protected xmlCueFile
  Protected sMsg.s
  Protected *nRootNode
  
  debugMsg(sProcName, #SCS_START + ", sCueFileName=" + GetFilePart(sCueFileName))
  
  ; initialize counts
  grCueFileItemCounts = rCueFileItemCountsDef
  
  If FileExists(sCueFileName)
    xmlCueFile = LoadXML(#PB_Any, sCueFileName)
    If xmlCueFile
      ; Display an error message if there was a markup error
      If XMLStatus(xmlCueFile) <> #PB_XML_Success
        sMsg = "Error in the XML file " + GetFilePart(sCueFileName) + ":" + Chr(13)
        sMsg + "Message: " + XMLError(xmlCueFile) + Chr(13)
        sMsg + "Line: " + XMLErrorLine(xmlCueFile) + "   Character Position: " + XMLErrorPosition(xmlCueFile)
        debugMsg(sProcName, sMsg)
        ensureSplashNotOnTop()
        scsMessageRequester(grText\sTextError, sMsg)
      Else
        *nRootNode = MainXMLNode(xmlCueFile)      
        If *nRootNode
          scanCueFileItems(*nRootNode, 0)
        EndIf
      EndIf
      FreeXML(xmlCueFile)
    EndIf
  EndIf
  
  With grCueFileItemCounts
    If \nCountAudioLogicalDevs > 0 : debugMsg(sProcName, "\nCountAudioLogicalDevs=" + \nCountAudioLogicalDevs) : EndIf
    If \nCountVidAudLogicalDevs > 0 : debugMsg(sProcName, "\nCountVidAudLogicalDevs=" + \nCountVidAudLogicalDevs) : EndIf
    If \nCountVidCapLogicalDevs > 0 : debugMsg(sProcName, "\nCountVidCapLogicalDevs=" + \nCountVidCapLogicalDevs) : EndIf
    If \nCountFixTypes > 0 : debugMsg(sProcName, "\nCountFixTypes=" + \nCountFixTypes) : EndIf
    If \nCountLightingLogicalDevs > 0 : debugMsg(sProcName, "\nCountLightingLogicalDevs=" + \nCountLightingLogicalDevs) : EndIf
    If \nCountCtrlSendLogicalDevs > 0 : debugMsg(sProcName, "\nCountCtrlSendLogicalDevs=" + \nCountCtrlSendLogicalDevs) : EndIf
    If \nCountCueCtrlLogicalDevs > 0 : debugMsg(sProcName, "\nCountCueCtrlLogicalDevs=" + \nCountCueCtrlLogicalDevs) : EndIf
    If \nCountLiveInputLogicalDevs > 0 : debugMsg(sProcName, "\nCountLiveInputLogicalDevs=" + \nCountLiveInputLogicalDevs) : EndIf
    If \nCountInGrps > 0 : debugMsg(sProcName, "\nCountInGrps=" + \nCountInGrps) : EndIf
    If \nCountCues > 0 : debugMsg(sProcName, "\nCountCues=" + \nCountCues) : EndIf
    If \nCountSubs > 0 : debugMsg(sProcName, "\nCountSubs=" + \nCountSubs) : EndIf
    If \nCountAuds > 0 : debugMsg(sProcName, "\nCountAuds=" + \nCountAuds) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure initProdArrays(*rProd.tyProd)
  PROCNAMEC()
  ; WARNING: This procedure must only be called BEFORE any *rProd device details are stored as the INIT_ARRAY() calls will set ALL array items to the supplied default
  Protected n ; used by INIT_ARRAY() macro
  
  ; Note that the array sizes must ALWAYS be at least one greater than the existing counts to allow fmEditProd to display a blank item for a new entry.
  ; This is handled here as the counts are 1-based but array sizes (and indexes) are 0-based.
  ; So, for example, if there is 1 audio device then the array size of *rProd\aAudioLogicalDevs() will be 1, which supports two entries (indexes 0 and 1).
  
  With *rProd
    If grCueFileItemCounts\nCountAudioLogicalDevs > ArraySize(\aAudioLogicalDevs())
      ReDim \aAudioLogicalDevs(grCueFileItemCounts\nCountAudioLogicalDevs)
    EndIf
    INIT_ARRAY(\aAudioLogicalDevs, grAudioLogicalDevsDef)
    
    If grCueFileItemCounts\nCountVidAudLogicalDevs > ArraySize(\aVidAudLogicalDevs())
      ReDim \aVidAudLogicalDevs(grCueFileItemCounts\nCountVidAudLogicalDevs)
    EndIf
    INIT_ARRAY(\aVidAudLogicalDevs, grVidAudLogicalDevsDef)
    
    If grCueFileItemCounts\nCountVidCapLogicalDevs > ArraySize(\aVidCapLogicalDevs())
      ReDim \aVidCapLogicalDevs(grCueFileItemCounts\nCountVidCapLogicalDevs)
    EndIf
    INIT_ARRAY(\aVidCapLogicalDevs, grVidCapLogicalDevsDef)
    
    If grCueFileItemCounts\nCountFixTypes > ArraySize(\aFixTypes())
      ReDim \aFixTypes(grCueFileItemCounts\nCountFixTypes)
    EndIf
    INIT_ARRAY(\aFixTypes, grFixTypesDef)
    
    If grCueFileItemCounts\nCountLightingLogicalDevs > ArraySize(\aLightingLogicalDevs())
      ReDim \aLightingLogicalDevs(grCueFileItemCounts\nCountLightingLogicalDevs)
    EndIf
    INIT_ARRAY(\aLightingLogicalDevs, grLightingLogicalDevsDef)
    
    If grCueFileItemCounts\nCountCtrlSendLogicalDevs > ArraySize(\aCtrlSendLogicalDevs())
      ReDim \aCtrlSendLogicalDevs(grCueFileItemCounts\nCountCtrlSendLogicalDevs)
    EndIf
    INIT_ARRAY(\aCtrlSendLogicalDevs, grCtrlSendLogicalDevsDef)
    
    If grCueFileItemCounts\nCountCueCtrlLogicalDevs > ArraySize(\aCueCtrlLogicalDevs())
      ReDim \aCueCtrlLogicalDevs(grCueFileItemCounts\nCountCueCtrlLogicalDevs)
    EndIf
    INIT_ARRAY(\aCueCtrlLogicalDevs, grCueCtrlLogicalDevsDef)
    
    If grCueFileItemCounts\nCountLiveInputLogicalDevs > ArraySize(\aLiveInputLogicalDevs())
      ReDim \aLiveInputLogicalDevs(grCueFileItemCounts\nCountLiveInputLogicalDevs)
    EndIf
    INIT_ARRAY(\aLiveInputLogicalDevs, grLiveInputLogicalDevsDef)
    
    If grCueFileItemCounts\nCountInGrps > ArraySize(\aInGrps())
      ReDim \aInGrps(grCueFileItemCounts\nCountInGrps)
    EndIf
    INIT_ARRAY(\aInGrps, grInGrpsDef)
  EndWith
  
EndProcedure

Procedure checkProdArraysAllowForNewEntry(*rProd.tyProd)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", *rProd=" + getProdGlobal(*rProd))
  
  With *rProd
    ; note that the array sizes must ALWAYS be at least the size of the matching \nMax...DevDisplay field to allow fmEditProd to display a blank item for a new entry
    REDIM_ARRAY2(\aAudioLogicalDevs, \nMaxAudioLogicalDevDisplay, grAudioLogicalDevsDef)
    REDIM_ARRAY2(\aVidAudLogicalDevs, \nMaxVidAudLogicalDevDisplay, grVidAudLogicalDevsDef)
    REDIM_ARRAY2(\aVidCapLogicalDevs, \nMaxVidCapLogicalDevDisplay, grVidCapLogicalDevsDef)
    REDIM_ARRAY2(\aFixTypes, \nMaxFixTypeDisplay, grFixTypesDef)
    REDIM_ARRAY2(\aLightingLogicalDevs, \nMaxLightingLogicalDevDisplay, grLightingLogicalDevsDef)
    REDIM_ARRAY2(\aCtrlSendLogicalDevs, \nMaxCtrlSendLogicalDevDisplay, grCtrlSendLogicalDevsDef)
    REDIM_ARRAY2(\aCueCtrlLogicalDevs, \nMaxCueCtrlLogicalDevDisplay, grCueCtrlLogicalDevsDef)
    REDIM_ARRAY2(\aLiveInputLogicalDevs, \nMaxLiveInputLogicalDevDisplay, grLiveInputLogicalDevsDef)
    REDIM_ARRAY2(\aInGrps, \nMaxInGrpDisplay, grInGrpsDef)
  EndWith
  
EndProcedure

Procedure mergeMemoRTFText(nFileNo, nStringFormat)
  ; Added 16Jul2022 11.9.3.1ad following a bug reported by Bernie Howatt 14Jul2022.
  ; The RTF text for memo cues are stored line-by-line in a template file, whereas the RTF text is stored in a single line in cue files.
  ; This is not a simple 'fix' for template files due to the logic in saveXMLTemplateFile() and related procedures, so this procedure provides a simple solution that converts a multi-line template memo text line to a single-line.
  
  ; EXAMPLE CUE FILE:
  ; <MemoRTFText>{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fnil\fcharset0 Arial;}}&#xD;&#xA;{\colortbl ;\red0\green0\blue0;}&#xD;&#xA;\viewkind4\uc1\pard\qc\cf1\fs36\par&#xD;&#xA;\par&#xD;&#xA;\par&#xD;&#xA;The main mix L/R fader should have moved to minimum.\par&#xD;&#xA;\par&#xD;&#xA;When you press the space bar again it should return to the Zero position\par&#xD;&#xA;}&#xD;&#xA;</MemoRTFText>
  
  ; EXAMPLE TEMPLATE FILE (same cue):
  ;  <MemoRTFText>
  ;    {\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fnil\fcharset0 Arial;}}
  ;    {\colortbl ;\red0\green0\blue0;}
  ;    \viewkind4\uc1\pard\qc\cf1\fs36\par
  ;    \par
  ;    \par
  ;    The main mix L/R fader should have moved to minimum.\par
  ;    \par
  ;    When you press the space bar again it should return to the Zero position\par
  ;    }
  ;  </MemoRTFText>
  
  ; The required gsLine value should be the single line entry as shown for 'example cue file'.

  PROCNAMEC()
  Protected sReadLine.s, sWorkLine.s, bFirstLine
  
  sWorkLine = gsLine
  bFirstLine = #True
  While #True
    sReadLine = Trim(ReadString(nFileNo, nStringFormat))
    If sReadLine = "</MemoRTFText>"
      sWorkLine + sReadLine
      Break
    Else
      sWorkLine + sReadLine + "&#xD;&#xA;"
    EndIf
  Wend
  gsLine = sWorkLine
  
EndProcedure

; EOF