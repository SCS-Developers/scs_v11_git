;  File: Lang.pbi

EnableExplicit

; AES Decryption function with UTF-8
; Pass in the string read from a line in the file along with the secret AES Key 
Procedure.s DecryptStringAES(sInput.s, sKey.s)
  Protected *buffer, nBufferSize, nDecryptedSize
  Protected sOutput.s, nDecodedSize
  
  If useAesEncryption = #False            ; if #false will bypass decryption.                                                 ; 
    ProcedureReturn sInput
  EndIf
  
  nBufferSize = Len(sInput) * 3 / 4 + 4  ; Approx decoded size + margin
  
  If nBufferSize < 64
    nBufferSize = 64
  EndIf
  
  *buffer = AllocateMemory(nBufferSize)
  
  If *buffer
    nDecodedSize = Base64Decoder(sInput, *buffer, nBufferSize)
    
    If nDecodedSize > 0
      AESDecoder(*buffer, *buffer, nDecodedSize, @sKey, StringByteLength(sKey, #PB_UTF8) * 8, #Null, #PB_Cipher_ECB)
      sOutput = PeekS(*buffer, -1, #PB_UTF8)  ; Convert back to UTF-8 string
    Else
      MessageRequester("Error", "Base64 decoding failed - buffer too small for input: " + sInput)
    EndIf
    
    FreeMemory(*buffer)
  Else
    MessageRequester("Error", "Memory allocation failed for Base64 decoding")
  EndIf  
  ProcedureReturn sOutput
EndProcedure

Procedure ReadLanguageFileInfo(filename.s)
  Protected sLine.s
  Protected hFilehandle.i
  Protected sTempString.s
  Protected sKey.s
  
  sKey = #SECRET_AES_KEY
  
  PROCNAMEC()
  hFilehandle = ReadFile(#PB_Any, filename)
  
  If hFilehandle
    AddElement(langConfig())
    langConfig()\sFilename = GetFilePart(filename)

    While Not Eof(hFilehandle)
      sLine = DecryptStringAES(Trim(ReadString(hFilehandle)), sKey)
      
      If Left(sLine, 10) = "\sLangCode"
        sTempString = Trim(Mid(sLine, FindString(sLine, "=") + 1))
        sTempString = RemoveString(sTempString, Chr(34))            ; Remove quotes
        sTempString = ReplaceString(sTempString, "  ", "")          ; Remove all spaces
        langConfig()\sLangCode = Trim(StringField(sTempString, 1, ";"))   ; Get first word (space as delimiter won't matter since we removed spaces)
      EndIf
      
      If Left(sLine, 10) = "\sLangName"
        sTempString = Trim(Mid(sLine, FindString(sLine, "=") + 1))
        sTempString = RemoveString(sTempString, Chr(34))
        sTempString = ReplaceString(sTempString, "  ", "")
        langConfig()\sLangName = Trim(StringField(sTempString, 1, ";"))
      EndIf
      
      If Left(sLine, 9) = "\sCreator"
        sTempString = Trim(Mid(sLine, FindString(sLine, "=") + 1))
        sTempString = RemoveString(sTempString, Chr(34))
        sTempString = ReplaceString(sTempString, "  ", "")
        langConfig()\sCreator = Trim(StringField(sTempString, 1, ";"))
      EndIf
    Wend
    CloseFile(hFilehandle)
  EndIf
EndProcedure

Procedure ParseFolder(folder.s)
  Protected hDIrExaminer
  Protected filename.s
  
  PROCNAMEC()
  
  If Right(folder, 1) <> "\"
    folder + "\"
  EndIf
  
  ClearList(langConfig())
  gnLanguageCount  = 0

  ; First pass: Look for scsLangENUS.lng specifically
  hDIrExaminer = ExamineDirectory(#PB_Any, folder, "scsLangENUS.lng")
  If hDIrExaminer
    While NextDirectoryEntry(hDIrExaminer)
      If DirectoryEntryType(hDIrExaminer) = #PB_DirectoryEntry_File
        filename = folder + DirectoryEntryName(hDIrExaminer)
        ReadLanguageFileInfo(filename)
        gnLanguageCount + 1
        
        If ArraySize(gaLanguage()) < gnLanguageCount
          ReDim gaLanguage(gnLanguageCount)
        EndIf
      EndIf
    Wend
    FinishDirectory(hDIrExaminer)
  EndIf
  
  ; Second pass: Process all other lng files
  hDIrExaminer = ExamineDirectory(#PB_Any, folder, "*.lng")
  If hDIrExaminer
    While NextDirectoryEntry(hDIrExaminer)
      If DirectoryEntryType(hDIrExaminer) = #PB_DirectoryEntry_File
        filename = folder + DirectoryEntryName(hDIrExaminer)
        ; Skip scsLangENUS.txt since we already processed it
        If GetFilePart(filename) <> "scsLangENUS.lng"
          ReadLanguageFileInfo(filename)
          gnLanguageCount + 1
           If ArraySize(gaLanguage()) < gnLanguageCount
            ReDim gaLanguage(gnLanguageCount)
          EndIf
        EndIf
      EndIf
    Wend
    FinishDirectory(hDIrExaminer)
  Else
    MessageRequester("Error", "Could not examine directory: " + folder)
  EndIf
  
  ; Sort the list alphabetically by sLangCode, keeping enus at the start
  FirstElement(langConfig())
  
  ; Sort from second element onwards
  If NextElement(langConfig())
    SortStructuredList(langConfig(), #PB_Sort_Ascending, OffsetOf(LangConfig\sLangCode), TypeOf(LangConfig\sLangCode), 1, ListSize(langConfig()) - 1)
  EndIf
EndProcedure

Procedure.i ParseLanguageFile(sFilename.s, nDocount.i)
  PROCNAMEC()
  Protected sLine.s
  Protected nLoop.i
  Protected inQuotes.b = #False
  Protected commentStart.i
  Protected Dim nQuotes(6), nQuoteCount.i, sTemp.s
  Protected nFileFormat.i, hFilehandle.i, sKey.s
  
  sKey = #SECRET_AES_KEY
  
  gsAppDataLanguagesPath = gsAppDataPath + "Languages\"
  hFilehandle = ReadFile(#PB_Any, gsAppDataLanguagesPath + sFilename)
    
  If hFilehandle
    nFileFormat = ReadStringFormat(hFilehandle)
    
    While Not Eof(hFilehandle)
      sLine = DecryptStringAES(Trim(ReadString(hFilehandle)), sKey)
      sTemp = sline
      
      ; Match valid data entries
      If FindString(sLine, "Data.s", 1) Or FindString(sLine, "_GROUP_", 1)
        If FindString(sLine, "_GROUP_", 1) <> 0
          AddElement(LanguageData())
          LanguageData()\Key = Mid(StringField(sLine, 1, ","), 8, Len(StringField(sLine, 1, ",")) - 2)
          LanguageData()\ShortText = Mid(StringField(sLine, 2, ","), 3, Len(StringField(sLine, 2, ",")) - 3)
          LanguageData()\LongText = Mid(StringField(sLine, 3, ","), 3, Len(StringField(sLine, 3, ",")) - 3)
          
          If nDocount
            gnLanguageGroups + 1
          EndIf
          
        ElseIf FindString(sLine, "_END_", 1) = 0
          AddElement(LanguageData())
          inQuotes = 0
          commentStart = 0
          
          ; Find the comment start, respecting quoted strings
          For nLoop = 1 To Len(sLine)
            If Mid(sLine, nLoop, 1) = #DQUOTE$
              inQuotes = ~inQuotes ; Toggle quote state
            ElseIf Mid(sLine, nLoop, 1) = ";" And Not inQuotes
              commentStart = nLoop
              Break
            EndIf
          Next
          
          ; Remove comment if found
          If commentStart
            sLine = Left(sLine, commentStart - 1)
          EndIf
          
          ; Check if it starts with "Data.s" and remove it
          If Left(sLine, 6) = "Data.s"
            sLine = Mid(sLine, 8)
          EndIf
          
          nQuoteCount = 0
          
          For nLoop = 1 To Len(sline)
            If Mid(sline, nLoop, 1) = #DQUOTE$
              nQuotes(nQuoteCount) = nLoop
              nQuoteCount + 1
            EndIf  
          Next
          
          If nQuoteCount = 6
            LanguageData()\Key = Trim(Mid(sline, nQuotes(0), nQuotes(1) - nQuotes(0)), #DQUOTE$)
            LanguageData()\ShortText = Trim(Mid(sline, nQuotes(2), nQuotes(3) - nQuotes(2)), #DQUOTE$)
            LanguageData()\LongText = Trim(Mid(sline, nQuotes(4), nQuotes(5) - nQuotes(4)), #DQUOTE$)
          Else
            ;Debug "Bad line: " + sline + "Orig: " + sTemp
          EndIf
          
          ; Debug "Data Found: " + LanguageData()\Key + ", " + LanguageData()\ShortText + " -> " + LanguageData()\LongText + " #" + nQuoteCount
          
          If nDocount
            gnLanguageStrings + 1
          EndIf
        EndIf
      EndIf
    Wend
    
    CloseFile(hFilehandle)
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure loadENUS(bDisplayLangIds=#False)
  PROCNAMEC()
  Protected sId.s, sName.s, sString.s
  Protected iGroup, iStringIndex, iChar
  Protected n
  
  ; do a quick count in the datasection first:
  gnLanguageGroups = 0
  gnLanguageStrings = 0
  
  ; Call the function
  If ParseLanguageFile("scsLangENUS.lng", 1) = #False       ;Parse the language file And set up all the counts
    MessageRequester("Critical startup error", "The language file scsLangENUS.lng is missing. \n Please re-install SCS")
    End                                                     ; our main language file is missing, reinstall SCS?
  EndIf
  
  gnLanguageGroups + 1
  gnLanguageStrings + 1

  ReDim gaLanguageGroups.tyLanguageGroup(gnLanguageGroups)  ; all one based here
  ReDim gsLanguageStrings.s(gnLanguageStrings)
  ReDim gsLanguageNames.s(gnLanguageStrings)
  ReDim gsLanguageIds.s(gnLanguageStrings)
  
  ClearList(langConfig())
  ParseFolder(gsAppDataLanguagesPath)  ; Replace with your folder path
  n = 0
  ResetList(langConfig())
  
  While NextElement(langConfig())
    gaLanguage(n)\sLangCode = langConfig()\sLangCode
    gaLanguage(n)\sLangName = langConfig()\sLangName
    gaLanguage(n)\sCreator = langConfig()\sCreator
    gaLanguage(n)\sFilename = langConfig()\sFilename
    n + 1
  Wend
  
  ClearList(langConfig())

  ; Now load the standard language (US English):
  iGroup = 0
  iStringIndex = 0
  
  ;Restore Language_ENUS
  ResetList(LanguageData())
    
  While NextElement(LanguageData())
    If LanguageData()
      sId = LanguageData()\Key
      sName = LanguageData()\ShortText
      sString = LanguageData()\LongText
    EndIf
    
      sName = UCase(sName)
    
    If sName = "_GROUP_"
      gaLanguageGroups(iGroup)\iGroupEnd = iStringIndex
      iGroup + 1
      
      gaLanguageGroups(iGroup)\sName = UCase(sString)
      gaLanguageGroups(iGroup)\iGroupStart = iStringIndex + 1
      
      For n = 0 To 255
        gaLanguageGroups(iGroup)\aIndexTable[n] = 0
      Next n
    Else
      iStringIndex + 1
      If 1=2
        gsLanguageNames(iStringIndex) = sName + Chr(1) + sString  ; keep name and string together for easier sorting
      Else
        If #cTranslator
          If bDisplayLangIds
            gsLanguageNames(iStringIndex) = sName + Chr(1) + LTrim(sId,"0") + sString
          Else
            gsLanguageNames(iStringIndex) = sName + Chr(1) + sString
          EndIf
        Else
          gsLanguageNames(iStringIndex) = sName + Chr(1) + sString
        EndIf
      EndIf
    EndIf
  Wend

  ClearList(LanguageData())
  gaLanguageGroups(iGroup)\iGroupEnd   = iStringIndex ; set end for the last group!
  
  ; Now do the sorting and the indexing for each group
  For iGroup = 1 To gnLanguageGroups
    If gaLanguageGroups(iGroup)\iGroupStart <= gaLanguageGroups(iGroup)\iGroupEnd  ; sanity check.. check for empty groups
      SortArray(gsLanguageNames(), 0, gaLanguageGroups(iGroup)\iGroupStart, gaLanguageGroups(iGroup)\iGroupEnd)
      iChar = 0
      
      For iStringIndex = gaLanguageGroups(iGroup)\iGroupStart To gaLanguageGroups(iGroup)\iGroupEnd
        gsLanguageStrings(iStringIndex) = StringField(gsLanguageNames(iStringIndex), 2, Chr(1)) ; split the value from the name
        gsLanguageNames(iStringIndex)   = StringField(gsLanguageNames(iStringIndex), 1, Chr(1))
        
        If Asc(Left(gsLanguageNames(iStringIndex), 1)) <> iChar
          iChar = Asc(Left(gsLanguageNames(iStringIndex), 1))
          
          If iChar > 255
            ; may occur for unicode non-ascii characters - use the 'last' element for anything > 255
            iChar = 255
          EndIf
          gaLanguageGroups(iGroup)\aIndexTable[iChar] = iStringIndex
        EndIf
      Next iStringIndex
      
    EndIf
  Next iGroup
  
EndProcedure

Procedure LoadLanguage(sLangCode.s, bDisplayLangIds=#False)
  PROCNAMEC()
  Protected sId.s, sName.s, sReadString.s, sString.s, sLangFilename.s
  Protected iGroup, iStringIndex
  Protected iGroupStart
  Protected iGroupEnd
  Protected bGroupFound
  
  loadENUS(bDisplayLangIds)
  Debug GetCurrentDirectory()
  
  ; now load non-english language data if applicable
  If sLangCode <> "ENUS"
    sLangFilename = "scsLang" + sLangCode + ".lng"
    
    If ParseLanguageFile(sLangFilename, 0) <> 0                ; Parse the language file and set up all the counts
      ResetList(LanguageData())
      
      While NextElement(LanguageData())
        If LanguageData()
          sId = LanguageData()\Key
          sName = LanguageData()\ShortText
          sReadString = LanguageData()\LongText
        EndIf
        
        sName = UCase(sName)
        sString = Trim(sReadString)
        
        If sName = "_GROUP_"
          bGroupFound = #False
          For iGroup = 1 To gnLanguageGroups
            If UCase(gaLanguageGroups(iGroup)\sName) = UCase(sString)
              bGroupFound = #True
              iGroupStart = gaLanguageGroups(iGroup)\iGroupStart
              iGroupEnd = gaLanguageGroups(iGroup)\iGroupEnd
            EndIf
          Next iGroup
          
        ElseIf sName = "_END_"
          Break
          
        ElseIf bGroupFound  ; ignores invalid group names, ie group names not declared in the standard language data list
          If sString
            If LCase(sString) <> "x" And sString <> "*" ; "x" or "*" means this string is not to be translated - specifically as required by Uwe Henkel for the German translations
              For iStringIndex = iGroupStart To iGroupEnd
                If gsLanguageNames(iStringIndex) = sName
                  If #cTranslator
                    If bDisplayLangIds
                      gsLanguageStrings(iStringIndex) = sId + sString
                    Else
                      gsLanguageStrings(iStringIndex) = sString
                    EndIf
                  Else
                    gsLanguageStrings(iStringIndex) = sString
                  EndIf
                  Break
                EndIf
              Next iStringIndex
            EndIf
          EndIf
        EndIf
      Wend
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.s Lang(pGroup.s, pName.s, sDefault.s="##### String not found! #####", sReplace.s="")
  PROCNAMEC()
  ; This function returns a string in the current language
  ; Each string is identified by a Group and a Name (both case insensitive)
  ;
  ; If the string is not found (not even in the included default language), the
  ; return is "##### String not found! #####" which helps to spot errors in the
  ; language code easily.
  ;
  Static iGroup  ; for quicker access when using the same group more than once.s
  Protected sString.s, iStringIndex, iResult, iChar
  Protected sGroup.s, sName.s
  Protected bFound
  Protected bLockedMutex
  
  ; added gnLangMutex 26Apr2017 11.6.1 as it appears that if Lang() is called simultaneously by two threads then they get confused and return the 'not found' result
  scsLockMutex(gnLangMutex, #SCS_MUTEX_LANG, 101)
  
  sGroup = UCase(pGroup)
  sName = UCase(pName)
  
  sString = sDefault
  
  If gaLanguageGroups(iGroup)\sName <> sGroup  ; check if it is the same group as last time
    For iGroup = 1 To gnLanguageGroups
      If sGroup = gaLanguageGroups(iGroup)\sName
        Break
      EndIf
    Next iGroup
    
    If iGroup > gnLanguageGroups  ; check if group was found
      iGroup = 0
    EndIf
  EndIf
  
  If iGroup <> 0
    iChar = Asc(Left(sName, 1))
    If iChar > 255
      ; may occur for unicode non-ascii characters - use the 'last' element for anything > 255
      iChar = 255
    EndIf
    iStringIndex = gaLanguageGroups(iGroup)\aIndexTable[iChar]
    If iStringIndex <> 0
      
      Repeat
        iResult = CompareMemoryString(@sName, @gsLanguageNames(iStringIndex))
        
        If iResult = 0
          sString = gsLanguageStrings(iStringIndex)
          bFound = #True
          Break
          
        ElseIf iResult = -1 ; string not found!
          Break
          
        EndIf
        
        iStringIndex + 1
      Until iStringIndex > gaLanguageGroups(iGroup)\iGroupEnd
    EndIf
  EndIf
  
  If bFound
    If Len(sReplace) > 0                ; added by Dee 25/03/2025, allow for replacings a string, Usercolumn names "Page" and "When required" can be user defined.
      gsLanguageStrings(iStringIndex) = sReplace
      sString = sReplace
    EndIf
    
    If FindString(sString, "\n") > 0
      sString = ReplaceString(sString, "\n", Chr(10))
    EndIf
    
    If FindString(sString, "\q") > 0
      sString = ReplaceString(sString, "\q", Chr(34))
    EndIf
  EndIf
  
  If bFound = #False
    If sDefault
      debugMsg0(sProcName, "Lang(" + #DQUOTE$ + pGroup + #DQUOTE$ + ", " + #DQUOTE$ + pName + #DQUOTE$ + ") not found #####")
    EndIf
  EndIf
  
  scsUnlockMutex(gnLangMutex, #SCS_MUTEX_LANG)
  ProcedureReturn sString
  
EndProcedure

Procedure.s LangWithAlt(pGroup.s, pName.s, pAltName.s)
  ; If pName not found then try pAltName.
  ; This was written to ease the transition to a new language item for language translations not yetr completed.
  ; For example, the window title for WMC was changed in SCS 11.8.2 from "Copy, Move or Delete a Range of Cues" to "Copy, Move, Delete or Sort a Range of Cues",
  ; so a new 'Name' was created (Window2) to replace the old 'Name' (Window).
  ; By calling LangWithAlt("WMC", "Window2", "Window") the program will select the new name (from Window2) if it exists in the translation, otherwise it will try for 'Window'.
  Protected sString.s
  sString = Lang(pGroup, pName, "#.#")
  If sString = "#.#"
    sString = Lang(pGroup, pAltName)
  EndIf
  ProcedureReturn sString
EndProcedure

Procedure.s LangEllipsis(pGroup.s, pName.s)
  ProcedureReturn Lang(pGroup, pName) + "..."
EndProcedure

Procedure.s LangSpace(pGroup.s, pName.s, pNumSpaces=1)
  ProcedureReturn Lang(pGroup, pName) + Space(pNumSpaces)
EndProcedure

Procedure.s LangColon(pGroup.s, pName.s)
  ProcedureReturn Lang(pGroup, pName) + ": "
EndProcedure

Procedure.s LangPars(pGroup.s, pName.s, pPar1.s, pPar2.s="*!*", pPar3.s="*!*", pPar4.s="*!*")
  ; PROCNAMEC()
  Protected sReturnString.s
  
  sReturnString = Lang(pGroup, pName)
  
  ; assume we can bail out as soon as we get a default parameter setting
  sReturnString = ReplaceString(sReturnString, "$1", pPar1)
  If pPar2 <> "*!*"
    sReturnString = ReplaceString(sReturnString, "$2", pPar2)
    If pPar3 <> "*!*"
      sReturnString = ReplaceString(sReturnString, "$3", pPar3)
      If pPar4 <> "*!*"
        sReturnString = ReplaceString(sReturnString, "$4", pPar4)
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn sReturnString
EndProcedure

Procedure loadCommonText()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  grProgVersion\sCopyRight = Lang("Init", "Copyright") + " © " + FormatDate("%yyyy", #PB_Compiler_Date) + " Show Cue Systems Pty Ltd"
  
  ; load common text after calling LoadLanguage()
  With grText
    ; "Common" items sorted
    \sTextActivation          = Lang("Common", "Activation")
    \sTextAnimated            = Lang("Common", "Animated")
    \sTextAudioLevel          = Lang("Common", "AudioLevel")
    \sTextAudioLevelManual    = Lang("Common", "AudioLevelManual")
    \sTextCopy                = Lang("Common", "Copy")
    \sTextCue                 = Lang("Common", "Cue")
    \sTextCut                 = Lang("Common", "Cut")
    \sTextDefault             = Lang("Common", "Default")
    \sTextDelete              = Lang("Common", "Delete")
    \sTextDescription         = Lang("Common", "Description")
    \sTextDevice              = Lang("Common", "Device")
    \sTextEditor              = Lang("Common", "SCSEditor")
    \sTextError               = Lang("Common", "Error")
    \sTextFile                = Lang("Common", "File")
    \sTextFileLength          = Lang("Common", "FileLength")
    \sTextFixture             = Lang("Common", "Fixture")
    \sTextGo                  = Lang("Common", "Go")
    \sTextLevel               = Lang("Common", "Level")
    \sTextLevelManual         = Lang("Common", "LevelManual")
    \sTextManual              = Lang("Common", "Manual")
    \sTextMute                = Lang("Common", "Mute")
    \sTextMuteAudio           = Lang("Common", "MuteAudio")
    \sTextNextManual          = Lang("Common", "NextManual")
    \sTextNextManualCue       = Lang("Common", "NextManualCue")
    \sTextOff                 = Lang("Common", "Off")
    \sTextOn                  = Lang("Common", "On")
    \sTextOptional            = Lang("Common", "Optional")
    \sTextPan                 = Lang("Common", "Pan")
    \sTextPanManual           = Lang("Common", "PanManual")
    \sTextPaste               = Lang("Common", "Paste")
    \sTextPlaceHolder         = Lang("Common", "PlaceHolder")
    \sTextPreRoll             = Lang("Common", "PreRoll")
    \sTextRepeat              = Lang("Common", "Repeat")
    \sTextRepositioning       = Lang("Common", "Repositioning")
    \sTextRightClick          = Lang("Common", "RightClick")
    \sTextSelect              = Lang("Common", "Select")
    \sTextSolo                = Lang("Common", "Solo")
    \sTextStoppingEverything  = Lang("Common", "StoppingEverything")
    \sTextFadingEverything    = Lang("Common", "FadingEverything")
    \sTextSub                 = Lang("Common", "Sub")
    \sTextTemplate            = Lang("Common", "Template")
    \sTextTrue                = Lang("Common", "True")
    \sTextUnmute              = Lang("Common", "Unmute")
    \sTextValErr              = Lang("Common", "ValErr")
    
    \sTextSave                = Lang("Menu", "mnuSave")
    \sTextSaveAs              = Lang("Menu", "mnuSaveAs")
    \sTextSaveReason          = Lang("Menu", "mnuSaveReason")
    
    \sTextCueState[#SCS_CUE_NOT_LOADED] = Lang("CueState", "NOT_LOADED")
    \sTextCueState[#SCS_CUE_READY] = Lang("CueState", "READY")
    \sTextCueState[#SCS_CUE_COUNTDOWN_TO_START] = Lang("CueState", "COUNTDOWN_TO_START")
    \sTextCueState[#SCS_CUE_SUB_COUNTDOWN_TO_START] = Lang("CueState", "COUNTDOWN_TO_START") + ".."
    \sTextCueState[#SCS_CUE_PL_COUNTDOWN_TO_START] = Lang("CueState", "COUNTDOWN_TO_START") + "."
    \sTextCueState[#SCS_CUE_WAITING_FOR_CONFIRM] = Lang("CueState", "WAITING_FOR_CONFIRM")
    \sTextCueState[#SCS_CUE_FADING_IN] = Lang("CueState", "FADING_IN")
    \sTextCueState[#SCS_CUE_TRANS_FADING_IN] = Lang("CueState", "TRANS_FADING_IN")
    \sTextCueState[#SCS_CUE_PLAYING] = Lang("CueState", "PLAYING")
    \sTextCueState[#SCS_CUE_CHANGING_LEVEL] = Lang("CueState", "CHANGING_LEVEL")
    \sTextCueState[#SCS_CUE_RELEASING] = Lang("CueState", "RELEASING")
    \sTextCueState[#SCS_CUE_STOPPING] = Lang("CueState", "STOPPING")
    \sTextCueState[#SCS_CUE_TRANS_MIXING_OUT] = Lang("CueState", "TRANS_MIXING_OUT")
    \sTextCueState[#SCS_CUE_TRANS_FADING_OUT] = Lang("CueState", "TRANS_FADING_OUT")
    \sTextCueState[#SCS_CUE_PAUSED] = Lang("CueState", "PAUSED")
    \sTextCueState[#SCS_CUE_HIBERNATING] = Lang("CueState", "HIBERNATING")
    \sTextCueState[#SCS_CUE_FADING_OUT] = Lang("CueState", "FADING_OUT")
    \sTextCueState[#SCS_CUE_PL_READY] = Lang("CueState", "READY") + "."
    \sTextCueState[#SCS_CUE_STANDBY] = Lang("CueState", "STANDBY")
    \sTextCueState[#SCS_CUE_COMPLETED] = Lang("CueState", "COMPLETED")
    \sTextCueState[#SCS_CUE_ERROR] = Lang("CueState", "ERROR")
    \sTextCueState[#SCS_CUE_IGNORED] = Lang("CueState", "IGNORED")
    \sTextCueState[#SCS_CUE_STATE_NOT_SET] = Lang("CueState", "STATE_NOT_SET")
    \sTextLive = Lang("CueState", "LIVE")
    
    \sTextDevGrp[#SCS_DEVGRP_AUDIO_OUTPUT] = Lang("DevGrp", "AudioOutput")
    \sTextDevGrp[#SCS_DEVGRP_VIDEO_AUDIO] = Lang("DevGrp", "VideoAudio")
    \sTextDevGrp[#SCS_DEVGRP_VIDEO_CAPTURE] = Lang("DevGrp", "VideoCapture")
    \sTextDevGrp[#SCS_DEVGRP_FIX_TYPE] = Lang("DevGrp", "FixType")
    \sTextDevGrp[#SCS_DEVGRP_LIGHTING] = Lang("DevGrp", "Lighting")
    \sTextDevGrp[#SCS_DEVGRP_CTRL_SEND] = Lang("DevGrp", "CtrlSend")
    \sTextDevGrp[#SCS_DEVGRP_CUE_CTRL] = Lang("DevGrp", "CueCtrl")
    \sTextDevGrp[#SCS_DEVGRP_IN_GRP] = Lang("DevGrp", "InGrp")
    \sTextDevGrp[#SCS_DEVGRP_LIVE_INPUT] = Lang("DevGrp", "LiveInput")
    \sTextDevGrp[#SCS_DEVGRP_EXT_CONTROLLER] = Lang("DevGrp", "ExtController") ; Added 18Jun2022 11.9.4
    
    loadCueTypeText()
    
    ; buttons
    \sTextBtnApply = Lang("Btns", "Apply")
    \sTextBtnCancel = Lang("Btns", "Cancel")
    \sTextBtnHelp = Lang("Btns", "Help")
    \sTextBtnOK = Lang("Btns", "OK")
    
  EndWith
  
  With grMMedia
    \sDefAudDevDesc = Lang("MMedia", "DefAudDev")
  EndWith
  
  gsPatternAllCueFiles = Lang("Requesters","AllCueFiles") + " (*.scs11,*.scsq,*.scs)|*.scs11;*.scsq;*.scs"
  
EndProcedure

; EOF