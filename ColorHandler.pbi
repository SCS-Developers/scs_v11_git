; File: ColorHandler.pbi

EnableExplicit

Procedure colorCodeToRRGGBB(nColorCode)
  Protected nRed, nGreen, nBlue
  
  nRed = Red(nColorCode)
  nGreen = Green(nColorCode)
  nBlue = Blue(nColorCode)
  
  ProcedureReturn (nRed * 65536) + (nGreen * 256) + nBlue
EndProcedure

Procedure.s debugColorCode(nColorCode)
  Protected nRed, nGreen, nBlue
  
  nRed = Red(nColorCode)
  nGreen = Green(nColorCode)
  nBlue = Blue(nColorCode)
  
  ProcedureReturn "RGB(" + nRed + "," + nGreen + "," + nBlue + ")"
  
EndProcedure

Procedure.s decodeColNXAction(nColNXAction)
  Protected sColNXAction.s
  
  Select nColNXAction
    Case #SCS_COL_NX_USE_CUE_COLORS
      sColNXAction = "UseCueColors"
    Case #SCS_COL_NX_SWAP_CUE_COLORS
      sColNXAction = "SwapCueColors"
    Case #SCS_COL_NX_LIGHTEN_OTHERS
      sColNXAction = "LightenOthers"
    Case #SCS_COL_NX_DARKEN_OTHERS
      sColNXAction = "DarkenOthers"
    Default ; includes #SCS_COL_NX_USE_NX_COLORS
      sColNXAction = "UseNXColors"
  EndSelect
  ProcedureReturn sColNXAction
EndProcedure

Procedure.s decodeColNXActionL(nColNXAction)
  ProcedureReturn Lang("WCS", "ColNX" + decodeColNXAction(nColNXAction))
EndProcedure

Procedure encodeColNXAction(sColNXAction.s)
  Protected nColNXAction
  
  Select sColNXAction
    Case "UseCueColors"
      nColNXAction = #SCS_COL_NX_USE_CUE_COLORS
    Case "SwapCueColors"
      nColNXAction = #SCS_COL_NX_SWAP_CUE_COLORS
    Case "LightenOthers"
      nColNXAction = #SCS_COL_NX_LIGHTEN_OTHERS
    Case "DarkenOthers"
      nColNXAction = #SCS_COL_NX_DARKEN_OTHERS
    Default ; includes "UseNXColors"
      nColNXAction = #SCS_COL_NX_USE_NX_COLORS
  EndSelect
  ProcedureReturn nColNXAction
EndProcedure

Procedure encodeColorItemCode(sItemCode.s)
  Protected nColorItemIndex
  
  Select sItemCode
    Case "DF"
      nColorItemIndex = #SCS_COL_ITEM_DF  ; Default colours
    Case "QA"
      nColorItemIndex = #SCS_COL_ITEM_QA  ; Video/Image cue
    Case "QE"
      nColorItemIndex = #SCS_COL_ITEM_QE  ; Memo cue
    Case "QF"
      nColorItemIndex = #SCS_COL_ITEM_QF  ; Audio File cue
    Case "QG"
      nColorItemIndex = #SCS_COL_ITEM_QG  ; Go To cue
    Case "QI"
      nColorItemIndex = #SCS_COL_ITEM_QI  ; Live Input cue
    Case "QJ"
      nColorItemIndex = #SCS_COL_ITEM_QJ  ; Enable/Disable cue
    Case "QK"
      nColorItemIndex = #SCS_COL_ITEM_QK  ; Lighting cue
    Case "QL"
      nColorItemIndex = #SCS_COL_ITEM_QL  ; Level Change cue
    Case "QM"
      nColorItemIndex = #SCS_COL_ITEM_QM  ; Control Send cue
    Case "QN"
      nColorItemIndex = #SCS_COL_ITEM_QN  ; Note cue
    Case "QP"
      nColorItemIndex = #SCS_COL_ITEM_QP  ; Playlist cue
    Case "QQ"
      nColorItemIndex = #SCS_COL_ITEM_QQ  ; 'Call Cue' cue
    Case "QR"
      nColorItemIndex = #SCS_COL_ITEM_QR  ; Run External Program cue
    Case "QS"
      nColorItemIndex = #SCS_COL_ITEM_QS  ; SFR cue
    Case "QT"
      nColorItemIndex = #SCS_COL_ITEM_QT  ; Set Position cue
    Case "QU"
      nColorItemIndex = #SCS_COL_ITEM_QU  ; MTC cue
    Case "EN"
      nColorItemIndex = #SCS_COL_ITEM_EN  ; End
    Case "HK"
      nColorItemIndex = #SCS_COL_ITEM_HK  ; Hotkeys
    Case "CQ"
      nColorItemIndex = #SCS_COL_ITEM_CC  ; Callable Cues
    Case "RU"
      nColorItemIndex = #SCS_COL_ITEM_RU  ; Running...
    Case "CT"
      nColorItemIndex = #SCS_COL_ITEM_CT  ; Counting Down
    Case "CM"
      nColorItemIndex = #SCS_COL_ITEM_CM  ; Completed
    Case "DP"
      nColorItemIndex = #SCS_COL_ITEM_DP  ; Display Panel (Inactive)
    Case "DA"
      nColorItemIndex = #SCS_COL_ITEM_DA  ; Display Panel (Active)
    Case "PR"
      nColorItemIndex = #SCS_COL_ITEM_PR  ; Production Propeties
    Case "CP"
      nColorItemIndex = #SCS_COL_ITEM_CP  ; Cue Properties
    Case "MW"
      nColorItemIndex = #SCS_COL_ITEM_MW  ; Main Window
    Case "NX"
      nColorItemIndex = #SCS_COL_ITEM_NX  ; Next Cue
  EndSelect
  
  ProcedureReturn nColorItemIndex
  
EndProcedure

Procedure.s decodeColorItemIndex(nColorItemIndex)
  Protected sItemCode.s
  
  Select nColorItemIndex
    Case #SCS_COL_ITEM_DF   ; Default colours
      sItemCode = "DF"
    Case #SCS_COL_ITEM_QA   ; Video/Image cue
      sItemCode = "QA"
    Case #SCS_COL_ITEM_QE   ; Memo cue
      sItemCode = "QE"
    Case #SCS_COL_ITEM_QF   ; Audio File cue
      sItemCode = "QF"
    Case #SCS_COL_ITEM_QG   ; Go To cue
      sItemCode = "QG"
    Case #SCS_COL_ITEM_QI   ; Live Input cue
      sItemCode = "QI"
    Case #SCS_COL_ITEM_QJ   ; Enable/Disable cue
      sItemCode = "QJ"
    Case #SCS_COL_ITEM_QK   ; Lighting cue
      sItemCode = "QK"
    Case #SCS_COL_ITEM_QL   ; Level Change cue
      sItemCode = "QL"
    Case #SCS_COL_ITEM_QM   ; Control Send cue
      sItemCode = "QM"
    Case #SCS_COL_ITEM_QN   ; Note cue
      sItemCode = "QN"
    Case #SCS_COL_ITEM_QP   ; Playlist cue
      sItemCode = "QP"
    Case #SCS_COL_ITEM_QQ   ; 'Call Cue' cue
      sItemCode = "QQ"
    Case #SCS_COL_ITEM_QR   ; Run External Program cue
      sItemCode = "QR"
    Case #SCS_COL_ITEM_QS   ; SFR cue
      sItemCode = "QS"
    Case #SCS_COL_ITEM_QT   ; Set Position cue
      sItemCode = "QT"
    Case #SCS_COL_ITEM_QU   ; MTC cue
      sItemCode = "QU"
    Case #SCS_COL_ITEM_EN   ; End
      sItemCode = "EN"
    Case #SCS_COL_ITEM_HK   ; Hotkeys
      sItemCode = "HK"
    Case #SCS_COL_ITEM_CC   ; Callable Cues
      sItemCode = "CQ"
    Case #SCS_COL_ITEM_RU   ; Running...
      sItemCode = "RU"
    Case #SCS_COL_ITEM_CT   ; Counting Down
      sItemCode = "CT"
    Case #SCS_COL_ITEM_CM   ; Completed
      sItemCode = "CM"
    Case #SCS_COL_ITEM_DP   ; Display Panel (Inactive)
      sItemCode = "DP"
    Case #SCS_COL_ITEM_DA   ; Display Panel (Active)
      sItemCode = "DA"
    Case #SCS_COL_ITEM_PR   ; Production Propeties
      sItemCode = "PR"
    Case #SCS_COL_ITEM_CP   ; Cue Properties
      sItemCode = "CP"
    Case #SCS_COL_ITEM_MW   ; Main Window
      sItemCode = "MW"
    Case #SCS_COL_ITEM_NX   ; Next Cue
      sItemCode = "NX"
  EndSelect
  
  ProcedureReturn sItemCode
  
EndProcedure

Procedure checkMaxScheme(nSchemePtr)
  PROCNAMEC()
  Protected nSchemeArraySize
  
  nSchemeArraySize = ArraySize(gaColorScheme())
  ; debugMsg(sProcName, "nSchemePtr=" + nSchemePtr + ", nSchemeArraySize=" + nSchemeArraySize)
  If nSchemePtr > (nSchemeArraySize - 2)
    nSchemeArraySize = nSchemePtr
    ReDim gaColorScheme(nSchemeArraySize)
    ; debugMsg(sProcName, "gaColorScheme redim new size = " + ArraySize(gaColorScheme()))
  EndIf
EndProcedure

Procedure loadGlobalColorScheme(sSchemeName.s)
  PROCNAMEC()
  Protected n, bFound
  
  For n = 0 To ArraySize(gaColorScheme())
    If gaColorScheme(n)\sSchemeName = sSchemeName
      grColorScheme = gaColorScheme(n)
      gsColorScheme = grColorScheme\sSchemeName
      bFound = #True
      Break
    EndIf
  Next n
  If bFound = #False
    grColorScheme = gaColorScheme(0)
    gsColorScheme = grColorScheme\sSchemeName
  EndIf
  
EndProcedure

Procedure setColorItem(*rColorScheme.tyColorScheme, nItemCode, nBackColor, nTextColor, bUseDflt=#False)
  PROCNAMEC()
  
  With *rColorScheme
    \aItem[nItemCode]\nBackColor = nBackColor
    \aItem[nItemCode]\nTextColor = nTextColor
    \aItem[nItemCode]\bUseDflt = bUseDflt
  EndWith
  
EndProcedure

Procedure setDefaultColorItem(*rColorScheme.tyColorScheme)
  PROCNAMEC()
  
  With *rColorScheme
    ; set default colors the same as the immediately following item (QF)
    \aItem[#SCS_COL_ITEM_DF]\nBackColor = \aItem[#SCS_COL_ITEM_DF+1]\nBackColor
    \aItem[#SCS_COL_ITEM_DF]\nTextColor = \aItem[#SCS_COL_ITEM_DF+1]\nTextColor
    \aItem[#SCS_COL_ITEM_DF]\bUseDflt = #False
  EndWith
  
EndProcedure

Procedure setAudioGraphColorItems(*rColorScheme.tyColorScheme, nLeftColor, nRightColor, bRightSameAsLeft, nCursorColor, nDarkenFactor, nLeftColorPlay, nRightColorPlay)
  PROCNAMEC()
  
  With *rColorScheme\rColorAudioGraph
    \nLeftColor = nLeftColor
    \nRightColor = nRightColor
    \bRightSameAsLeft = bRightSameAsLeft
    \nCursorColor = nCursorColor
    \nShadowColor = #SCS_Grey
    \nCursorTransparencyFactor = 200
    \nCuePanelCursorColor = RGBA(Red(\nCursorColor), Green(\nCursorColor), Blue(\nCursorColor), \nCursorTransparencyFactor)
    \nCuePanelShadowColor = RGBA(Red(\nShadowColor), Green(\nShadowColor), Blue(\nShadowColor), \nCursorTransparencyFactor)
    \nDarkenFactor = nDarkenFactor
    \nLeftColorPlay = nLeftColorPlay
    \nRightColorPlay = nRightColorPlay
    debugMsg(sProcName, "\nLeftColor=" + debugColorCode(\nLeftColor) + ", \nLeftColorPlay=" + debugColorCode(\nLeftColorPlay))
  EndWith
  
EndProcedure

Procedure applyUseDfltColors(*rColorScheme.tyColorScheme, nItemCode=-1)
  PROCNAMEC()
  Protected nFirstItemCode, nLastItemCode
  Protected nThisItemCode
  
  If nItemCode = -1
    nFirstItemCode = 0
    nLastItemCode = #SCS_COL_ITEM_LAST
  Else
    nFirstItemCode = nItemCode
    nLastItemCode = nItemCode
  EndIf
  
  For nThisItemCode = nFirstItemCode To nLastItemCode
    If nThisItemCode <> #SCS_COL_ITEM_DF
      With *rColorScheme\aItem[nThisItemCode]
        If \bUseDflt
          \nBackColor = *rColorScheme\aItem[#SCS_COL_ITEM_DF]\nBackColor
          \nTextColor = *rColorScheme\aItem[#SCS_COL_ITEM_DF]\nTextColor
        EndIf
      EndWith
    EndIf
  Next nThisItemCode
  
EndProcedure

Procedure readXMLColorFile(sReqdColorFile.s="")
  PROCNAMEC()
  Protected bOK
  Protected nSchemePtr
  Protected sUpTag.s, sUpAttributeName1.s, sUpAttributeName2.s, sFile.s
  Protected sItemCode.s, nItemIndex, sChar1.s
  Protected nColor, nColorFile
  Protected bUseDflt
  Protected nFileStringFormat
  Protected bDAFound  ; will be used to set DA colors to DP colors if no DA entries found (except for default color scheme)
  Protected bENFound  ; pre 11.4.0 the 'End/Note' was QE but that clashes with Memo. if no EN found then QE will be copied to EN and QN
  Protected bDFFound  ; 'default' color item found
  Protected bColorAudioGraph
  
  bOK = #True
  gbEOF = #False
  nSchemePtr = #SCS_MAX_INTERNAL_COL_SCHEME     ; schemes read from this file to be added after the internal schemes
  gnTagLevel = -1
  gsChar = ""
  gsLine = ""
  
  If sReqdColorFile
    If FileExists(sReqdColorFile, #False)
      sFile = sReqdColorFile
    EndIf
  EndIf
  
  If Len(sFile) = 0
    sFile = gsAppDataPath + "scs_colors.scsc"     ; SCS 11 color scheme file
    If FileExists(sFile, #False) = #False
      sFile = gsMyDocsPath + "scs_colors.scc"     ; SCS 10 color scheme file
      If FileExists(sFile, #False) = #False
        debugMsg(sProcName, "Color Scheme file not found")
        gsColorFile = ""
        gsColorFolder = ""
        ProcedureReturn
      EndIf
    EndIf
    gbDfltColorFile = #True
  Else
    If sFile = gsAppDataPath + "scs_colors.scsc"      ; SCS 11 color scheme file
      gbDfltColorFile = #True
    ElseIf sFile = gsMyDocsPath + "scs_colors.scc"    ; SCS 10 color scheme file
      gbDfltColorFile = #True
    Else
      gbDfltColorFile = #False
    EndIf
  EndIf
  debugMsg(sProcName, "sFile=" + sFile)
  
  gsColorFile = sFile
  gsColorFolder = GetPathPart(sFile)
  
  gnNextFileNo + 1
  nColorFile = gnNextFileNo
  If ReadFile(nColorFile, sFile, #PB_File_SharedRead) = #False
    ProcedureReturn
  EndIf
  
  nFileStringFormat = ReadStringFormat(nColorFile)
  debugMsg(sProcName, "gnXMLFileStringFormat=" + decodeStringFormat(nFileStringFormat))
  
  While (bOK) And (gbEOF = #False)
    nextInputTag(nColorFile, nFileStringFormat)
    If Not gbEOF
      ; debugMsg(sProcName, "gsTag=" + gsTag + ", Left(gsTag, 1)=" + Left(gsTag, 1))
      sUpTag = UCase(gsTag)
      sUpAttributeName1 = UCase(gsTagAttributeName1)
      sUpAttributeName2 = UCase(gsTagAttributeName2)
      sChar1 = Left(gsTag, 1)
      If Left(sUpTag, 4) = "?XML"
        ; XML header
      ElseIf sChar1 <> "/"
        ; debugMsg(sProcName, "/ not found, sChar1=" + #DQUOTE$ + sChar1 + #DQUOTE$)
        gnTagLevel + 1
        ; debugMsg(sProcName, "gnTagLevel=" + gnTagLevel)
        CheckSubInRange(gnTagLevel, ArraySize(gasTagStack()), "gasTagStack()")
        gasTagStack(gnTagLevel) = gsTag
      Else
        ; debugMsg(sProcName, "/ found")
        If gnTagLevel < 0
          bOK = #False
          ensureSplashNotOnTop()
          scsMessageRequester(GetFilePart(sFile), "Encountered <" + gsTag + ">" + " without matching <" + Mid(gsTag, 2) + ">", #PB_MessageRequester_Error)
        ElseIf LCase(gasTagStack(gnTagLevel)) <> LCase(Mid(gsTag, 2))
          bOK = #False
          ensureSplashNotOnTop()
          scsMessageRequester(GetFilePart(sFile), "Encountered <" + gsTag + ">" + " but expecting </" + gasTagStack(gnTagLevel) + ">", #PB_MessageRequester_Error)
        Else
          gnTagLevel - 1
          ; debugMsg(sProcName, "gnTagLevel=" + gnTagLevel)
        EndIf
      EndIf
      If bOK
        If Left(sUpTag, 4) <> "?XML"
          nextInputData(nColorFile, nFileStringFormat)
        EndIf
        
        Select sUpTag
          Case "SCHEME"
            ; initialise with default scheme so any missing items will use defaults
            grWorkScheme = grColHnd\rDefaultScheme
            grWorkScheme\bInternalScheme = #False
            sItemCode = ""
            bDAFound = #False
            bENFound = #False
            bDFFound = #False
            
          Case "/SCHEME"
            If grWorkScheme\sSchemeName
              If bDAFound = #False
                With grWorkScheme
                  \aItem[#SCS_COL_ITEM_DA] = \aItem[#SCS_COL_ITEM_DP]
                EndWith
              EndIf
              If bENFound = #False
                With grWorkScheme
                  \aItem[#SCS_COL_ITEM_EN] = \aItem[#SCS_COL_ITEM_QE]
                  \aItem[#SCS_COL_ITEM_QN] = \aItem[#SCS_COL_ITEM_QE]
                EndWith
              EndIf
              If bDFFound = #False
                setDefaultColorItem(@grWorkScheme)
              EndIf
              applyUseDfltColors(@grWorkScheme)
              nSchemePtr + 1
              checkMaxScheme(nSchemePtr)
              ; debugMsg(sProcName, "Storing scheme " + nSchemePtr + " (" + grWorkScheme\sSchemeName + ")")
              gaColorScheme(nSchemePtr) = grWorkScheme
            EndIf
            
          Case "NAME"
            grWorkScheme\sSchemeName = gsData
            debugMsg(sProcName, "grWorkScheme\sSchemeName=" + grWorkScheme\sSchemeName)
            
          Case "COLORITEM"
            sItemCode = ""
            nItemIndex = -1
            
          Case "ITEMCODE"
            sItemCode = gsData
            nItemIndex = encodeColorItemCode(sItemCode)
            ; debugMsg(sProcName, "sItemCode=" + sItemCode)
            
          Case "BACKCOLOR"
            If Left(gsData, 1) = "#"
              If nItemIndex >= 0
                nColor = stringHexToLong(Mid(gsData, 2))
                grWorkScheme\aItem[nItemIndex]\nBackColor = nColor
                ; debugMsg(sProcName, "grWorkScheme\aItem[" + nItemIndex + "]\nBackColor=" + debugColorCode(grWorkScheme\aItem[nItemIndex]\nBackColor) + ", gsData=" + gsData)
                Select nItemIndex
                  Case #SCS_COL_ITEM_DF
                    bDFFound = #True
                  Case #SCS_COL_ITEM_DA
                    bDAFound = #True
                  Case #SCS_COL_ITEM_EN
                    bENFound = #True
                EndSelect
              EndIf
            EndIf
            
          Case "FONTCOLOR", "TEXTCOLOR"
            If Left(gsData, 1) = "#"
              If nItemIndex >= 0
                nColor = stringHexToLong(Mid(gsData, 2))
                grWorkScheme\aItem[nItemIndex]\nTextColor = nColor
                ; debugMsg(sProcName, "grWorkScheme\aItem[" + nItemIndex + "]\nTextColor=" + debugColorCode(grWorkScheme\aItem[nItemIndex]\nTextColor) + ", gsData=" + gsData)
                Select nItemIndex
                  Case #SCS_COL_ITEM_DF
                    bDFFound = #True
                  Case #SCS_COL_ITEM_DA
                    bDAFound = #True
                  Case #SCS_COL_ITEM_EN
                    bENFound = #True
                EndSelect
              EndIf
            EndIf
            
          Case "USEDEFAULT"
            If nItemIndex >= 0
              bUseDflt = stringToBoolean(gsData)
              grWorkScheme\aItem[nItemIndex]\bUseDflt = bUseDflt
            EndIf
;             debugMsg(sProcName, "grWorkScheme\aItem[" + decodeColorItemIndex(nItemIndex) + "]\bUseDflt=" + strB(grWorkScheme\aItem[nItemIndex]\bUseDflt))
            
          Case "/COLORITEM"
            sItemCode = ""
            nItemIndex = -1
            
          Case "COLNXACTION"
            grWorkScheme\nColNXAction = encodeColNXAction(gsData)
            
          Case "COLORAUDIOGRAPH"
            bColorAudioGraph = #True
            grWorkScheme\rColorAudioGraph\nLeftColorPlay = -1
            grWorkScheme\rColorAudioGraph\nRightColorPlay = -1
            
          Case "AGLEFT"
            nColor = stringHexToLong(Mid(gsData, 2))
            grWorkScheme\rColorAudioGraph\nLeftColor = nColor
            
          Case "AGLEFTPLAY"
            nColor = stringHexToLong(Mid(gsData, 2))
            grWorkScheme\rColorAudioGraph\nLeftColorPlay = nColor
            
          Case "AGRIGHT"
            nColor = stringHexToLong(Mid(gsData, 2))
            grWorkScheme\rColorAudioGraph\nRightColor = nColor
            
          Case "AGRIGHTPLAY"
            nColor = stringHexToLong(Mid(gsData, 2))
            grWorkScheme\rColorAudioGraph\nRightColorPlay = nColor
            
          Case "AGSAME"
            grWorkScheme\rColorAudioGraph\bRightSameAsLeft = stringToBoolean(gsData)
            
          Case "AGCURSOR"
            nColor = stringHexToLong(Mid(gsData, 2))
            grWorkScheme\rColorAudioGraph\nCursorColor = nColor
            
          Case "AGDARKENFACTOR"
            grWorkScheme\rColorAudioGraph\nDarkenFactor = Val(gsData)
            
          Case "/COLORAUDIOGRAPH"
            With grWorkScheme\rColorAudioGraph
              If \nLeftColorPlay = -1
                If \nLeftColor = #SCS_Green ; 'classic' color
                  \nLeftColorPlay = \nLeftColor
                Else
                  \nLeftColorPlay = grColorScheme\aItem[#SCS_COL_ITEM_RU]\nBackColor
                EndIf
              EndIf
              If \nRightColorPlay = -1
                If \nRightColor = #SCS_Red ; 'classic' color
                  \nRightColorPlay = \nRightColor
                Else
                  \nRightColorPlay = grColorScheme\aItem[#SCS_COL_ITEM_RU]\nBackColor
                EndIf
              EndIf
              \nCuePanelCursorColor = RGBA(Red(\nCursorColor), Green(\nCursorColor), Blue(\nCursorColor), \nCursorTransparencyFactor)
              \nCuePanelShadowColor = RGBA(Red(\nShadowColor), Green(\nShadowColor), Blue(\nShadowColor), \nCursorTransparencyFactor)
            EndWith
            bColorAudioGraph = #False
            
        EndSelect
      EndIf
    EndIf
  Wend
  
  CloseFile(nColorFile)
  
  ProcedureReturn
EndProcedure

Procedure importColorScheme(sFile.s="")
  PROCNAMEC()
  Protected bOK
  Protected sUpTag.s, sUpAttributeName1.s, sUpAttributeName2.s
  Protected sItemCode.s, nItemIndex
  Protected nColor, nColorFile
  Protected bUseDflt
  Protected nFileStringFormat
  Protected bDAFound  ; will be used to set DA colors to DP colors if no DA entries found (except for default color scheme)
  Protected bENFound  ; pre 11.4.0 the 'End/Note' was QE but that clashes with Memo. if no EN found then QE will be copied to EN and QN
  Protected bDFFound  ; 'default' color item found
  Protected rColorScheme.tyColorScheme
  Protected n
  Protected bSchemeAlreadyExists
  Protected sTitle.s, sMsg.s
  Protected nImportedSchemePtr
  Protected bColorAudioGraph
  
  bOK = #True
  gbEOF = #False
  gnTagLevel = -1
  gsChar = ""
  gsLine = ""
  nImportedSchemePtr = -1
  
  If sFile
    If FileExists(sFile) = #False
      ProcedureReturn -1
    EndIf
  EndIf
  
  gnNextFileNo + 1
  nColorFile = gnNextFileNo
  If ReadFile(nColorFile, sFile, #PB_File_SharedRead) = #False
    ProcedureReturn -1
  EndIf
  
  nFileStringFormat = ReadStringFormat(nColorFile)
  debugMsg(sProcName, "gnXMLFileStringFormat=" + decodeStringFormat(nFileStringFormat))
  
  While (bOK) And (gbEOF = #False)
    nextInputTag(nColorFile, nFileStringFormat)
    If Not gbEOF
      sUpTag = UCase(gsTag)
      sUpAttributeName1 = UCase(gsTagAttributeName1)
      sUpAttributeName2 = UCase(gsTagAttributeName2)
      If Left(sUpTag, 4) = "?XML"
        ; XML header
      ElseIf Left(gsTag, 1) <> "/"
        gnTagLevel + 1
        gasTagStack(gnTagLevel) = gsTag
      Else
        If gnTagLevel < 0
          bOK = #False
          ensureSplashNotOnTop()
          scsMessageRequester(GetFilePart(sFile), "Encountered <" + gsTag + ">" + " without matching <" + Mid(gsTag, 2) + ">", #PB_MessageRequester_Error)
        ElseIf LCase(gasTagStack(gnTagLevel)) <> LCase(Mid(gsTag, 2))
          bOK = #False
          ensureSplashNotOnTop()
          scsMessageRequester(GetFilePart(sFile), "Encountered <" + gsTag + ">" + " but expecting </" + gasTagStack(gnTagLevel) + ">", #PB_MessageRequester_Error)
        Else
          gnTagLevel - 1
        EndIf
      EndIf
      If bOK
        If Left(sUpTag, 4) <> "?XML"
          nextInputData(nColorFile, nFileStringFormat)
        EndIf
        
        Select sUpTag
          Case "SCHEME"
            ; initialise with default scheme so any missing items will use defaults
            rColorScheme = grColHnd\rDefaultScheme
            rColorScheme\bInternalScheme = #False
            sItemCode = ""
            bDAFound = #False
            bENFound = #False
            bDFFound = #False
            
          Case "/SCHEME"
            If rColorScheme\sSchemeName
              If bDAFound = #False
                With rColorScheme
                  \aItem[#SCS_COL_ITEM_DA] = \aItem[#SCS_COL_ITEM_DP]
                EndWith
              EndIf
              
              If bENFound = #False
                With rColorScheme
                  \aItem[#SCS_COL_ITEM_EN] = \aItem[#SCS_COL_ITEM_QE]
                  \aItem[#SCS_COL_ITEM_QN] = \aItem[#SCS_COL_ITEM_QE]
                EndWith
              EndIf
              
              If bDFFound = #False
                setDefaultColorItem(@rColorScheme)
              EndIf
              
              applyUseDfltColors(@rColorScheme)
              
              ; check if this scheme name already exists
              bSchemeAlreadyExists = #False
              For n = 0 To ArraySize(gaColorScheme())
                If gaColorScheme(n)\sSchemeName = rColorScheme\sSchemeName
                  bSchemeAlreadyExists = #True
                  Break
                EndIf
              Next n
              If bSchemeAlreadyExists
                sTitle = Lang("WCS", "btnImport")
                sMsg = LangPars("Errors", "SchemeExists", rColorScheme\sSchemeName)
                debugMsg(sProcName, sMsg)
                scsMessageRequester(sTitle, sMsg, #MB_ICONEXCLAMATION)
                ProcedureReturn -1
              EndIf
              nImportedSchemePtr = ArraySize(gaColorScheme()) + 1
              checkMaxScheme(nImportedSchemePtr)
              debugMsg(sProcName, "Storing scheme " + nImportedSchemePtr + " (" + rColorScheme\sSchemeName + ")")
              gaColorScheme(nImportedSchemePtr) = rColorScheme
              Break ; we only import one scheme - although there should only be one scheme in the import file anyway
            EndIf
            
          Case "NAME"
            rColorScheme\sSchemeName = gsData
            debugMsg(sProcName, "rColorScheme\sSchemeName=" + rColorScheme\sSchemeName)
            
          Case "COLORITEM"
            sItemCode = ""
            nItemIndex = -1
            
          Case "ITEMCODE"
            sItemCode = gsData
            nItemIndex = encodeColorItemCode(sItemCode)
            
          Case "BACKCOLOR"
            If Left(gsData, 1) = "#"
              If nItemIndex >= 0
                nColor = stringHexToLong(Mid(gsData, 2))
                rColorScheme\aItem[nItemIndex]\nBackColor = nColor
                Select nItemIndex
                  Case #SCS_COL_ITEM_DF
                    bDFFound = #True
                  Case #SCS_COL_ITEM_DP
                    bDAFound = #True
                  Case #SCS_COL_ITEM_EN
                    bENFound = #True
                EndSelect
              EndIf
            EndIf
            
          Case "FONTCOLOR", "TEXTCOLOR"
            If Left(gsData, 1) = "#"
              If nItemIndex >= 0
                nColor = stringHexToLong(Mid(gsData, 2))
                rColorScheme\aItem[nItemIndex]\nTextColor = nColor
                Select nItemIndex
                  Case #SCS_COL_ITEM_DF
                    bDFFound = #True
                  Case #SCS_COL_ITEM_DP
                    bDAFound = #True
                  Case #SCS_COL_ITEM_EN
                    bENFound = #True
                EndSelect
              EndIf
            EndIf
            
          Case "USEDEFAULT"
            If nItemIndex >= 0
              bUseDflt = stringToBoolean(gsData)
              rColorScheme\aItem[nItemIndex]\bUseDflt = bUseDflt
            EndIf
;             debugMsg(sProcName, "rColorScheme\aItem[" + decodeColorItemIndex(nItemIndex) + "]\bUseDflt=" + strB(rColorScheme\aItem[nItemIndex]\bUseDflt))
            
          Case "/COLORITEM"
            sItemCode = ""
            nItemIndex = -1
            
          Case "COLNXACTION"
            rColorScheme\nColNXAction = encodeColNXAction(gsData)
            
          Case "COLORAUDIOGRAPH"
            bColorAudioGraph = #True
            
          Case "AGLEFT"
            nColor = stringHexToLong(Mid(gsData, 2))
            rColorScheme\rColorAudioGraph\nLeftColor = nColor
            
          Case "AGRIGHT"
            nColor = stringHexToLong(Mid(gsData, 2))
            rColorScheme\rColorAudioGraph\nRightColor = nColor
            
          Case "AGLEFTPLAY"
            nColor = stringHexToLong(Mid(gsData, 2))
            rColorScheme\rColorAudioGraph\nLeftColorPlay = nColor
            
          Case "AGRIGHTPLAY"
            nColor = stringHexToLong(Mid(gsData, 2))
            rColorScheme\rColorAudioGraph\nRightColorPlay = nColor
            
          Case "AGSAME"
            rColorScheme\rColorAudioGraph\bRightSameAsLeft = stringToBoolean(gsData)
            
          Case "AGCURSOR"
            nColor = stringHexToLong(Mid(gsData, 2))
            rColorScheme\rColorAudioGraph\nCursorColor = nColor
            
          Case "AGDARKENFACTOR"
            rColorScheme\rColorAudioGraph\nDarkenFactor = Val(gsData)
            
          Case "/COLORAUDIOGRAPH"
            With rColorScheme\rColorAudioGraph
              \nCuePanelCursorColor = RGBA(Red(\nCursorColor), Green(\nCursorColor), Blue(\nCursorColor), \nCursorTransparencyFactor)
              \nCuePanelShadowColor = RGBA(Red(\nShadowColor), Green(\nShadowColor), Blue(\nShadowColor), \nCursorTransparencyFactor)
            EndWith
            bColorAudioGraph = #False
            
        EndSelect
      EndIf
    EndIf
  Wend
  
  CloseFile(nColorFile)
  
  ProcedureReturn nImportedSchemePtr
  
EndProcedure

Procedure initColorHandler(sReqdColorFile.s="")
  PROCNAMEC()
  Protected n
  Protected nBackColorDflt, nTextColorDflt
  
  debugMsg(sProcName, #SCS_START + ", sReqdColorFile=" + sReqdColorFile)
  
  ; INFO Load colors for 'SCS Classic' scheme
  With grColHnd\rClassicScheme
    \sSchemeName = #SCS_COL_DEF_SCHEME_NAME
    \sSchemeDescr = Lang("WCS", "SCS11Classic")
    \nColNXAction = #SCS_COL_NX_USE_NX_COLORS
    \bInternalScheme = #True
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QA, RGB(244,228,227), $484CB0)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QE, $001060, RGB(255,255,223))
    ; setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QF, $E8E4D0, $5B2E0F)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QF, $FFE4B3, $5B2E0F) ; changed 19Apr2016 11.5.0 (made a bit more blue to provide better 'light' color for 'SCS Light' scheme)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QG, RGB(225,252,205), $001060)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QI, $E8E4D0, $5B2E0F)
    ; setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QJ, $001060, RGB(255,255,223))
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QJ, RGB(236, 225, 221), $001060) ; changed 6Apr2022 11.9.1az
    ; setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QK, $2CF9F9, $002953)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QK, RGB(248,222,126), $002953) ; changed 2Sep2020 11.8.3.2at to moderate the brightness of the yellow background
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QL, $ACFDFD, $004080)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QM, $50E488, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QN, $001060, RGB(255,255,223))
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QP, $7CF1E0, $001060)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QQ, RGB(255,255,223), $800080)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QR, RGB(225,252,205), $001060)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QS, $ACFDFD, $183890)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QT, RGB(225,252,205), $001060)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_QU, RGB(225,252,205), $001060)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_EN, $001060, RGB(255,255,223))
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_DP, $989898, $C0FFFF)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_DA, $C0C0C0, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_HK, $F8F8F8, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_CC, $9D9DD7, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_RU, $8FF8BC, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_CT, $80FFFF, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_CM, $808080, $E5E5E5)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_PR, $9BF9F7, $000000)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_CP, $50E488, $204498)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_MW, $808080, $FFFFFF)
    setColorItem(@grColHnd\rClassicScheme, #SCS_COL_ITEM_NX, $000000, $FFFFFF)
    setDefaultColorItem(@grColHnd\rClassicScheme)
    setAudioGraphColorItems(@grColHnd\rClassicScheme, $EFD4A3, $EFD4A3, #True, RGB(255,255,0), -50, $8FF8BC, $8FF8BC) ; playing colors to be same as #SCS_COL_ITEM_RU backcolor
    applyUseDfltColors(@grColHnd\rClassicScheme)  ; nb won't actually do anything as there are no 'use dflt' settings in this scheme, but retain for possible future changes
  EndWith
  
  ; INFO Load colors for 'SCS Light' scheme
  grColHnd\rLightScheme = grColHnd\rClassicScheme
  With grColHnd\rLightScheme
    \sSchemeName = #SCS_COL_LIGHT_SCHEME_NAME
    \sSchemeDescr = Lang("WCS", "SCSLight")
    \bInternalScheme = #True
    \nColNXAction = #SCS_COL_NX_LIGHTEN_OTHERS
  EndWith
    
  ; INFO Load colors for 'SCS Dark' scheme
  grColHnd\rDarkScheme = grColHnd\rClassicScheme
  With grColHnd\rDarkScheme
    \sSchemeName = #SCS_COL_DARK_SCHEME_NAME
    \sSchemeDescr = Lang("WCS", "SCSDark")
    \bInternalScheme = #True
    \nColNXAction = #SCS_COL_NX_DARKEN_OTHERS
  EndWith
  
  CompilerIf #c_color_scheme_classic
    ; INFO Load colors for 'SCS Default' scheme (as from SCS 11.8.3.2)
    With grColHnd\rDefaultScheme
      \sSchemeName = #SCS_COL_DEF_SCHEME_NAME
      \sSchemeDescr = Lang("WCS", "SCS11Default")
      \nColNXAction = #SCS_COL_NX_USE_NX_COLORS
      \bInternalScheme = #True
      
      nBackColorDflt = $404040
      nTextColorDflt = $E6E6E6
      
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_DF, nBackColorDflt, nTextColorDflt) ; default colors
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QA, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QE, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QF, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QG, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QI, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QJ, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QK, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QL, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QM, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QN, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QP, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QQ, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QR, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QS, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QT, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_QU, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_EN, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_DP, $7D7D7D, $C0FFFF, #False) ; display panel (inactive)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_DA, $9A9A9A, $000000, #False) ; display panel (active)
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_HK, nBackColorDflt, nTextColorDflt, #True) ; hotkeys
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_CC, nBackColorDflt, nTextColorDflt, #True) ; callable cue
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_RU, $2DB868, $000000, #False) ; running...
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_CT, $80FFFF, $000000, #False) ; counting down
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_CM, changeColorBrightness(nBackColorDflt, 0.2), $E5E5E5) ; completed cues
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_PR, nBackColorDflt, nTextColorDflt, #True) ; production properties in editor
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_CP, nBackColorDflt, nTextColorDflt, #True) ; cue properties in editor
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_SC, $666666, nTextColorDflt, #False) ; sub-cue properties in editor
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_MW, $808080, $FFFFFF, #False) ; main window
      setColorItem(@grColHnd\rDefaultScheme, #SCS_COL_ITEM_NX, $000000, $FFFFFF, #False)
      
      setAudioGraphColorItems(@grColHnd\rDefaultScheme, $EFD4A3, $EFD4A3, #True, RGB(255,255,0), -50, $2DB868, $2DB868) ; playing colors to be same as #SCS_COL_ITEM_RU backcolor
      applyUseDfltColors(@grColHnd\rDefaultScheme)
    EndWith
  CompilerElse
    
    grColHnd\rDefaultScheme = grColHnd\rClassicScheme ; Prior to SCS 11.8.3.2, the default was what is now the 'classic' scheme
    With grColHnd\rDefaultScheme
      \sSchemeName = #SCS_COL_DEF_SCHEME_NAME
      \sSchemeDescr = Lang("WCS", "SCS11Default")
      \nColNXAction = #SCS_COL_NX_USE_NX_COLORS
      \bInternalScheme = #True
    EndWith
    
    ; INFO Load colors for 'Windows Default' scheme (obsolete as at SCS 11.8.3.2)
    grColHnd\rWinDefScheme = grColHnd\rDefaultScheme
    With grColHnd\rWinDefScheme
      \sSchemeName = #SCS_COL_WIN_DEF
      \sSchemeDescr = Lang("WCS", "WinDef")
      \bInternalScheme = #True
      \nColNXAction = #SCS_COL_NX_USE_NX_COLORS
      
      nBackColorDflt = glSysCol3DFace
      nTextColorDflt = glSysColWindowText
      
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_DF, nBackColorDflt, nTextColorDflt)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QA, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QE, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QF, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QG, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QI, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QJ, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QK, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QL, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QM, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QN, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QP, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QQ, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QR, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QS, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QT, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_QU, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_EN, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_DP, $989898, $C0FFFF, #False)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_DA, $D8D8D8, $000000, #False)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_HK, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_CC, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_RU, $8FF8BC, $000000, #False)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_CT, $80FFFF, $000000, #False)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_CM, $D8D8D8, $000000, #False)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_PR, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_CP, nBackColorDflt, nTextColorDflt, #True)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_MW, $808080, $FFFFFF, #False)
      setColorItem(@grColHnd\rWinDefScheme, #SCS_COL_ITEM_NX, $000000, $FFFFFF, #False)
      applyUseDfltColors(@grColHnd\rWinDefScheme)
    EndWith
  CompilerEndIf
  
  ReDim gaColorScheme(3)
  CompilerIf #c_color_scheme_classic
    gaColorScheme(0) = grColHnd\rDefaultScheme
    gaColorScheme(1) = grColHnd\rClassicScheme
    gaColorScheme(2) = grColHnd\rLightScheme
    gaColorScheme(3) = grColHnd\rDarkScheme
  CompilerElse
    gaColorScheme(0) = grColHnd\rDefaultScheme
    gaColorScheme(1) = grColHnd\rLightScheme
    gaColorScheme(2) = grColHnd\rDarkScheme
    gaColorScheme(3) = grColHnd\rWinDefScheme
  CompilerEndIf
  
  readXMLColorFile(sReqdColorFile)
  
;   For n = 0 To ArraySize(gaColorScheme())
;     debugMsg(sProcName, "gaColorScheme(" + n + ")\sSchemeName=" + #DQUOTE$ + gaColorScheme(n)\sSchemeName + #DQUOTE$)
;   Next n
  
  debugMsg(sProcName, "calling loadGlobalColorScheme(" + #DQUOTE$ + gsColorScheme + #DQUOTE$ + ")")
  loadGlobalColorScheme(gsColorScheme)
  
  If gbMainFormLoaded
    WMN_setFormColors()
  EndIf

EndProcedure

Procedure.s longToHexColor(nColor)
  ; used by saveColorItem (which is called by saveXMLColorFile)
  ProcedureReturn "#" + Right("000000" + Hex(nColor), 6)
EndProcedure

Procedure saveColorItem(nFileNo, *rColorScheme.tyColorScheme, nItemCode)
  PROCNAMEC()
  
  If nItemCode >= 0
    With *rColorScheme\aItem[nItemCode]
      writeTag(nFileNo, "ColorItem")
      writeTagWithContent(nFileNo, "ItemCode", decodeColorItemIndex(nItemCode))
      If (nItemCode <> #SCS_COL_ITEM_DF) And (\bUseDflt)
        writeTagWithContent(nFileNo, "UseDefault", booleanToString(\bUseDflt))
      Else
        writeTagWithContent(nFileNo, "BackColor", longToHexColor(\nBackColor))
        writeTagWithContent(nFileNo, "TextColor", longToHexColor(\nTextColor))
      EndIf
      writeUnTag(nFileNo, "ColorItem")
    EndWith
  EndIf

EndProcedure

Procedure saveAudioGraphColorItems(nFileNo, *rColorScheme.tyColorScheme)
  PROCNAMEC()
  
  With *rColorScheme\rColorAudioGraph
    writeTag(nFileNo, "ColorAudioGraph")
    writeTagWithContent(nFileNo, "AGLeft", longToHexColor(\nLeftColor))
    writeTagWithContent(nFileNo, "AGRight", longToHexColor(\nRightColor))
    writeTagWithContent(nFileNo, "AGSame", booleanToString(\bRightSameAsLeft))
    writeTagWithContent(nFileNo, "AGCursor", longToHexColor(\nCursorColor))
    writeTagWithContent(nFileNo, "AGDarkenFactor", Str(\nDarkenFactor))
    writeTagWithContent(nFileNo, "AGLeftPlay", longToHexColor(\nLeftColorPlay))
    writeTagWithContent(nFileNo, "AGRightPlay", longToHexColor(\nRightColorPlay))
    writeUnTag(nFileNo, "ColorAudioGraph")
  EndWith

EndProcedure

Procedure saveXMLColorFile(sReqdSaveFolder.s="")
  PROCNAMEC()
  Protected n, nItemCode
  Protected rTmpScheme.tyColorScheme
  Protected sFile.s, sString.s, nColorFile
  
  If Len(sReqdSaveFolder) = 0
    sFile = gsAppDataPath + "scs_colors.scsc"
  Else
    sFile = sReqdSaveFolder + "scs_colors.scsc"
  EndIf
  
  nColorFile = CreateFile(#PB_Any, sFile)
  If nColorFile = 0
    ensureSplashNotOnTop()
    scsMessageRequester(#SCS_TITLE, "Error opening file " + sFile, #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf

  gnTagLevel = -1

  writeXMLHeader(nColorFile)

  writeTag(nColorFile, "ColorSchemes")

  ; do not 'save' internal schemes, so start 'for' loop after the last internal scheme
  For n = (#SCS_MAX_INTERNAL_COL_SCHEME + 1) To ArraySize(gaColorScheme())
    rTmpScheme = gaColorScheme(n)
    
    With rTmpScheme
      If \sSchemeName
        writeTag(nColorFile, "Scheme")
        writeTagWithContent(nColorFile, "Name", \sSchemeName)
        For nItemCode = 0 To #SCS_COL_ITEM_LAST
          saveColorItem(nColorFile, @rTmpScheme, nItemCode)
        Next nItemCode
        If \nColNXAction > 0
          writeTagWithContent(nColorFile, "ColNXAction", decodeColNXAction(\nColNXAction))
        EndIf
        saveAudioGraphColorItems(nColorFile, @rTmpScheme)
        writeUnTag(nColorFile, "Scheme")
      EndIf
    EndWith
    
  Next n

  writeUnTag(nColorFile, "ColorSchemes")

  CloseFile(nColorFile)
  
  gsColorFile = sFile
  gsColorFolder = GetPathPart(sFile)
  
EndProcedure

Procedure exportColorScheme(*rColorScheme.tyColorScheme)
  PROCNAMEC()
  Protected nItemCode
  Protected sInitialDir.s, sDefaultFile.s, sThisExportFile.s, sPattern.s, sTitle.s
  Protected nColorFile
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  With *rColorScheme
    If \sSchemeName
      
      ensureSplashNotOnTop()
      
      If Trim(gsCueFolder)
        sInitialDir = Trim(gsCueFolder)
      EndIf
      
      sTitle = Lang("Requesters", "ExportColorScheme") + " " + \sSchemeName
      sPattern = Lang("Requesters", "ColorScheme") + " (*.scscs)|*.scscs"
      sDefaultFile = sInitialDir + Trim("scs_colors " +  dropIllegalFilenameChars(\sSchemeName)) + ".scscs"
      
      sThisExportFile = SaveFileRequester(sTitle, sDefaultFile, sPattern, 0)
      If sThisExportFile
        
        If FileExists(sThisExportFile)
          nResponse = scsMessageRequester(sTitle, LangPars("Requesters", "ReplaceFile", sThisExportFile), #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
          If nResponse = #PB_MessageRequester_No
            ProcedureReturn
          EndIf
        EndIf
        
        nColorFile = CreateFile(#PB_Any, sThisExportFile)
        If nColorFile = 0
          scsMessageRequester(sTitle, LangPars("Requesters", "CreateError", sThisExportFile), #PB_MessageRequester_Error)
          ProcedureReturn
        EndIf
        
        debugMsg(sProcName, "exporting color scheme '" + \sSchemeName + "' to " + sThisExportFile)
        
        gnTagLevel = -1
        writeXMLHeader(nColorFile)
        writeTag(nColorFile, "ColorSchemes")
        writeTag(nColorFile, "Scheme")
        writeTagWithContent(nColorFile, "Name", \sSchemeName)
        For nItemCode = 0 To #SCS_COL_ITEM_LAST
          saveColorItem(nColorFile, *rColorScheme, nItemCode)
        Next nItemCode
        If \nColNXAction > 0
          writeTagWithContent(nColorFile, "ColNXAction", decodeColNXAction(\nColNXAction))
        EndIf
        saveAudioGraphColorItems(nColorFile, *rColorScheme)
        writeUnTag(nColorFile, "Scheme")
        writeUnTag(nColorFile, "ColorSchemes")
        
        CloseFile(nColorFile)
        
      EndIf
      
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadColorFileIfExists()
  PROCNAMEC()
  Protected sColorFile.s
  Protected n, bSchemeFound
  
  If gsCueFolder
    sColorFile = gsCueFolder + "scs_colors.scsc"   ; SCS 11 color file
    If FileExists(sColorFile) = #False
      sColorFile = gsCueFolder + "scs_colors.scc"  ; SCS 10 color file
    EndIf
    initColorHandler(sColorFile)  ; nb initColorHandler() and subordinate procedures ignore sColorFile if it doesn't exist
    For n = 0 To ArraySize(gaColorScheme())
      If gaColorScheme(n)\sSchemeName = gsColorScheme
        grColorScheme = gaColorScheme(n)
        bSchemeFound = #True
        Break
      EndIf
    Next n
    If bSchemeFound = #False
      gsColorScheme = ""
    EndIf
    debugMsg(sProcName, "grColorScheme\sSchemeName=" + grColorScheme\sSchemeName)
    If gbMainFormLoaded
      WMN_setFormColors()
    EndIf
  EndIf
  
EndProcedure

Procedure getSubTextColor(pSubPtr=-5, bCheckHK=#False)
  Protected nSubPtr
  Protected sItemCode.s
  Protected nItemCode
  Protected nTextColor
  
  If pSubPtr = -5
    nSubPtr = nEditSubPtr
  Else
    nSubPtr = pSubPtr
  EndIf
  
  If nSubPtr >= 0
    With aSub(nSubPtr)
      If \bHotkey Or \bExtAct
        sItemCode = "HK"
      ElseIf \bCallableCue
        sItemCode = "CC"
      Else
        sItemCode = "Q" + \sSubType
      EndIf
      nItemCode = encodeColorItemCode(sItemCode)
      If nItemCode >= 0
        nTextColor = grColorScheme\aItem[nItemCode]\nTextColor
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn nTextColor
EndProcedure

Procedure getSubBackColor(pSubPtr=-5, bCheckHK=#False)
  Protected nSubPtr
  Protected sItemCode.s
  Protected nItemCode
  Protected nBackColor
  
  If pSubPtr = -5
    nSubPtr = nEditSubPtr
  Else
    nSubPtr = pSubPtr
  EndIf
  
  If nSubPtr >= 0
    With aSub(nSubPtr)
      If \bHotkey Or \bExtAct
        sItemCode = "HK"
      ElseIf \bCallableCue
        sItemCode = "CC"
      Else
        sItemCode = "Q" + \sSubType
      EndIf
      nItemCode = encodeColorItemCode(sItemCode)
      If nItemCode >= 0
        nBackColor = grColorScheme\aItem[nItemCode]\nBackColor
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn nBackColor
EndProcedure

Procedure setNXColorsForItemColors(nItemCode, nBackColor, nTextColor, *nNXBackColor, *nNXTextColor)
  PROCNAMEC()
  Protected nNewBackColor, nNewTextColor
  
  With grWorkScheme
    Select nItemCode
      Case #SCS_COL_ITEM_Q_FIRST To #SCS_COL_ITEM_Q_LAST, #SCS_COL_ITEM_DF
        Select \nColNXAction
          Case #SCS_COL_NX_USE_CUE_COLORS
            nNewBackColor = nBackColor
            nNewTextColor = nTextColor
          Case #SCS_COL_NX_SWAP_CUE_COLORS
            nNewBackColor = nTextColor
            nNewTextColor = nBackColor
          Case #SCS_COL_NX_LIGHTEN_OTHERS
            nNewBackColor = changeColorBrightness(nBackColor, 0.7)
            nNewTextColor = getContrastColor(nNewBackColor)
          Case #SCS_COL_NX_DARKEN_OTHERS
            nNewBackColor = changeColorBrightness(nBackColor, -0.2)
            nNewTextColor = getContrastColor(nNewBackColor)
          Default ; includes #SCS_COL_NX_USE_NX_COLORS
            nNewBackColor = \aItem[#SCS_COL_ITEM_NX]\nBackColor
            nNewTextColor = \aItem[#SCS_COL_ITEM_NX]\nTextColor
        EndSelect
        
      Default
        nNewBackColor = nBackColor
        nNewTextColor = nTextColor
        
    EndSelect
  EndWith
  
  PokeL(*nNXBackColor, nNewBackColor)
  PokeL(*nNXTextColor, nNewTextColor)
  
EndProcedure

Procedure setNXColorsForAudioGraphItems()
  PROCNAMEC()
  
  With grWorkScheme\rColorAudioGraph
    Select grWorkScheme\nColNXAction
      Case #SCS_COL_NX_LIGHTEN_OTHERS
    EndSelect
  EndWith
  
EndProcedure

Procedure setColorsForNextManualCue(nBackColor, nTextColor, *nNXBackColor, *nNXTextColor)
  PROCNAMEC()
  Protected nNewBackColor, nNewTextColor
  
  With grColorScheme
    Select \nColNXAction
      Case #SCS_COL_NX_USE_NX_COLORS
        nNewBackColor = \aItem[#SCS_COL_ITEM_NX]\nBackColor
        nNewTextColor = \aItem[#SCS_COL_ITEM_NX]\nTextColor
      Case #SCS_COL_NX_SWAP_CUE_COLORS
        nNewBackColor = nTextColor
        nNewTextColor = nBackColor
      Default
        nNewBackColor = nBackColor
        nNewTextColor = nTextColor
    EndSelect
  EndWith
  
  PokeL(*nNXBackColor, nNewBackColor)
  PokeL(*nNXTextColor, nNewTextColor)
  
  ; debugMsg(sProcName, #SCS_END + ", nBackColor=$" + Hex(nBackColor,#PB_Long) + ", nNewBackColor=$" + Hex(nNewBackColor,#PB_Long))
  
EndProcedure

Procedure setColorsForOtherCues(nBackColor, nTextColor, *nNXBackColor, *nNXTextColor)
  ; set background and text colors for cues OTHER THAN the 'next manual cue'
  PROCNAMEC()
  Protected nNewBackColor, nNewTextColor
  
  With grColorScheme
    Select \nColNXAction
      Case #SCS_COL_NX_LIGHTEN_OTHERS
        nNewBackColor = changeColorBrightness(nBackColor, 0.7)
        nNewTextColor = getContrastColor(nNewBackColor)
      Case #SCS_COL_NX_DARKEN_OTHERS
        nNewBackColor = changeColorBrightness(nBackColor, -0.2)
        nNewTextColor = getContrastColor(nNewBackColor)
      Default
        nNewBackColor = nBackColor
        nNewTextColor = nTextColor
    EndSelect
  EndWith
  
  PokeL(*nNXBackColor, nNewBackColor)
  PokeL(*nNXTextColor, nNewTextColor)
  
  ; debugMsg(sProcName, #SCS_END + ", nBackColor=$" + Hex(nBackColor,#PB_Long) + ", nNewBackColor=$" + Hex(nNewBackColor,#PB_Long))
  
EndProcedure

Procedure getBackColorFromColorScheme(nItemIndex)
  PROCNAMEC()
  Protected nBackColor
  
  If nItemIndex >= 0
    If grColorScheme\aItem[nItemIndex]\bUseDflt
      nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DF]\nBackColor
    Else
      nBackColor = grColorScheme\aItem[nItemIndex]\nBackColor
    EndIf
  EndIf
  ProcedureReturn nBackColor
EndProcedure

Procedure getTextColorFromColorScheme(nItemIndex)
  PROCNAMEC()
  Protected nTextColor
  
  If nItemIndex >= 0
    If grColorScheme\aItem[nItemIndex]\bUseDflt
      nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DF]\nTextColor
    Else
      nTextColor = grColorScheme\aItem[nItemIndex]\nTextColor
    EndIf
  EndIf
  ProcedureReturn nTextColor
EndProcedure

Procedure getCurrColorsForCue(pCuePtr, *mBackColor, *mTextColor)
  PROCNAMEC()
  Protected nItemIndex = -1
  Protected nBackColor.l, nTextColor.l
  
  With aCue(pCuePtr)
    If pCuePtr = gnCueEnd
      nItemIndex = #SCS_COL_ITEM_EN
      
    ElseIf \nCueState = #SCS_CUE_ERROR
      nBackColor = #SCS_Red   ; grColorScheme\nBackColorNotFound
      nTextColor = #SCS_White ; grColorScheme\nTextColorNotFound
      
    ElseIf \bHotkey Or \bExtAct
      nItemIndex = #SCS_COL_ITEM_HK
      
    ElseIf \bCallableCue
      nItemIndex = #SCS_COL_ITEM_CC
      
    Else
      nBackColor = \nBackColor
      nTextColor = \nTextColor
      
    EndIf
    
    If (pCuePtr <> gnCueEnd) And (pCuePtr <> gnHighlightedCue)
      If (\nCueState = #SCS_CUE_COMPLETED) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
        nItemIndex = #SCS_COL_ITEM_CM
        
      ElseIf (\nCueState >= #SCS_CUE_FADING_IN) And (\nCueState <= #SCS_CUE_FADING_OUT) And (\nCueState <> #SCS_CUE_HIBERNATING)
        nItemIndex = #SCS_COL_ITEM_RU
        
      ElseIf (\nCueState = #SCS_CUE_COUNTDOWN_TO_START) Or (\nCueState = #SCS_CUE_SUB_COUNTDOWN_TO_START) Or (\nCueState = #SCS_CUE_PL_COUNTDOWN_TO_START)
        nItemIndex = #SCS_COL_ITEM_CT
      EndIf
    EndIf
    
    If nItemIndex >= 0
      nBackColor = grColorScheme\aItem[nItemIndex]\nBackColor
      nTextColor = grColorScheme\aItem[nItemIndex]\nTextColor
    EndIf
  EndWith
  
  PokeL(*mBackColor, nBackColor)
  PokeL(*mTextColor, nTextColor)
  
EndProcedure

; EOF