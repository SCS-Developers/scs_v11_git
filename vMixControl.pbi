; File: vMixControl.pbi

; INFO: Currently (ie as at 8Dec2022) vMixControl.pbi is only included if the compiler constant #c_vMix_in_video_cues=#True (set in TopLevel.pbi)

; INFO =========== IMPORTANT ===========
; For details of the API Shortcuts, see the ONLINE document https://www.vmix.com/help23/
; Do NOT use the downloaded PDF file as this has cut off the right-hand side of the pages,
; omitting the 'Parameters' column of the table.

EnableExplicit

Procedure vMix_SetOrResetInputsForSCS(bMutexAlreadyLocked)
  PROCNAMEC()
  Protected sCommand.s, sResponse.s, bLockedMutex
  Protected nInputIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2715)
  EndIf
  
  ; clear all vMix inputs - (also loads start settings if grvMixInfo\bStartSettingsLoaded=#False, eg setting of FullScreenOn)
  vMixPopulateInputInfoArray(#True, #True)
  debugMsg(sProcName, "grvMixInfo\sEdition=" + grvMixInfo\sEdition)
  If grvMixInfo\sEdition
    grvMixInfo\bStartSettingsLoaded = #True
  EndIf
  
  If grvMixInfo\nMaxInputInfo >= 0
    debugMsg(sProcName, "grvMixInfo\nMaxInputInfo=" + grvMixInfo\nMaxInputInfo)
    For nInputIndex = grvMixInfo\nMaxInputInfo To 0 Step -1
      debugMsg(sProcName, "grvMixInfo\aInputInfo(" + nInputIndex + ")\sType=" + grvMixInfo\aInputInfo(nInputIndex)\sType + ", \sTitle=" + grvMixInfo\aInputInfo(nInputIndex)\sTitle)
      Select grvMixInfo\aInputInfo(nInputIndex)\sType
        Case "Blank"
          ; no action required
        Case "Capture"
          ; leave "capture" (camera) inputs as the vMix API doesn't support adding them
        Default
          sCommand = "FUNCTION RemoveInput Input=" + grvMixInfo\aInputInfo(nInputIndex)\sKey
          sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
      EndSelect
    Next nInputIndex
  EndIf ; EndIf grvMixInfo\nMaxInputInfo >= 0
  grvMixInfo\nMaxInputKeyToRemoveWhenvMixIdle = -1
  
  vMixLoadBlackImage(#True)
  ; Blackout the output
  vMixFadeToBlackImage(0, #True)
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_Init()
  PROCNAMEC()
  Protected nInitResult ; 0 = OK, -1 = InitNetwork() failed, #SCS_CANCEL_EDIT = Cancel edit, #SCS_CLOSE_CUE_FILE = Close cue file, #SCS_CLOSE_SCS = Close SCS
  Protected sCommand.s, sResponse.s, bLockedMutex
  Protected nMousePointer, bModalDisplayed, sTitle.s, sPrompt.s, sButtons.s, nReply, sTryAgain.s, nButtonWidth
  Protected sMessage.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grVMixControl
    \sIPAddress = "127.0.0.1"
    \nPortNo = 8099
    While #True
      \nConnection = OpenNetworkConnection(\sIPAddress, \nPortNo, #PB_Network_TCP)
      debugMsg(sProcName, "OpenNetworkConnection(" + \sIPAddress + ", " + \nPortNo + ", #PB_Network_TCP) returned " + \nConnection)
      If \nConnection = 0
        nMousePointer = GetMouseCursor()
        bModalDisplayed = gbModalDisplayed
        SetMouseCursorNormal()
        ensureSplashNotOnTop()
        gbModalDisplayed = #True
        sTitle = Lang("vMix", "ConnectionTitle")
        If gbInLoadCueFile
          sPrompt = LangPars("WLP", "Opening", #DQUOTE$ + grProd\sTitle + #DQUOTE$) + "||" +
                    Lang("vMix","ConnectionFail") + "||"
          sButtons = Lang("Network","btnTryAgain") + "|" +
                     Lang("Network","btnCloseFile")
          nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 200, #IDI_EXCLAMATION)
          gbModalDisplayed = bModalDisplayed
          SetMouseCursor(nMousePointer)
          Select nReply
            Case 1 ; retry connection
              Continue
            Case 2
              nInitResult = #SCS_CLOSE_CUE_FILE
          EndSelect
          Break
        Else
          sPrompt = Lang("vMix","ConnectionFail") + "||"
          sButtons = Lang("Network","btnTryAgain") + "|" +
                     Lang("Btns","Cancel")
          nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 200, #IDI_EXCLAMATION)
          gbModalDisplayed = bModalDisplayed
          SetMouseCursor(nMousePointer)
          Select nReply
            Case 1 ; retry connection
              Continue
            Case 2
              nInitResult = #SCS_CANCEL_EDIT
          EndSelect
          Break
        EndIf
        
      Else
        ; connection successful
        Break
      EndIf
    Wend
    
    ; vMix may return large messages - larger than the 2048 (#SCS_MEM_SIZE_NETWORK_BUFFERS) bytes normally set for *gmNetworkReceiveBuffer.
    ; So allocate a buffer with the TCP maximum size, ie 65536 bytes.
    ; NB: The maximum sizes of 2048 (UDP) and 65536 (TCP) are obtained from the PB documentation, but a search of the internet shows different
    ; maximums, particularly for UDP.
    If *gmNetworkReceiveBuffer
      If MemorySize(*gmNetworkReceiveBuffer) < 65536
        FreeMemory(*gmNetworkReceiveBuffer)
        *gmNetworkReceiveBuffer = 0
      EndIf
    EndIf
    If *gmNetworkReceiveBuffer = 0
      *gmNetworkReceiveBuffer = AllocateMemory(65536)
    EndIf
    
    If nInitResult = 0 ; connected OK
      
      scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2701)
      
      ; initially, clear all vMix inputs - (also loads start settings if grvMixInfo\bStartSettingsLoaded=#False, eg setting of FullScreenOn)
      vMix_SetOrResetInputsForSCS(#True)
      debugMsg(sProcName, "grvMixInfo\sEdition=" + grvMixInfo\sEdition)
      If grvMixInfo\bBasicEdition And grLicInfo\sLicUser <> "Mike Daniell"
        grvMixInfo\bvMixEditionNotSupported = #True
        sMessage = "vMix " + grvMixInfo\sEdition + " Edition is not supported by SCS"
        sTitle = Lang("vMix", "ConnectionTitle")
        scsMessageRequester(sTitle, sMessage, #PB_MessageRequester_Error)
        debugMsg(sProcName, "calling CloseNetworkConnection(" + \nConnection + ")")
        CloseNetworkConnection(\nConnection)
        \nConnection = 0
        nInitResult = #SCS_VMIX_EDITION_NOT_SUPPORTED
      Else
        If grvMixInfo\sEdition
          grvMixInfo\bStartSettingsLoaded = #True
        EndIf
        
        sCommand = "FUNCTION FullscreenOn"
        sResponse = vMixSendCommand(sProcName, sCommand, 2000, #True, #True)
        
        sCommand = "SUBSCRIBE ACTS"
        sResponse = vMixSendCommand(sProcName, sCommand, 2000, #True, #True)
      EndIf
      scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
      
      \bvMixInitDone = #True
      
    EndIf ; EndIf nInitResult = 0
    
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning " + nInitResult)
  ProcedureReturn nInitResult
  
EndProcedure

Procedure vMix_InitIfReqd()
  PROCNAMEC()
  Protected i, bInitReqd, nInitResult
  
  If grvMixControl\bvMixInitDone = #False
    For i = 1 To gnLastCue
      ; NB Do NOT check 'enabled' state or we would have to call this Procedure on enabling a cue.
      ; Much better to work on the premise that if there are ANY type A cues then we should call vMix_Init() if it hasn't yet been called.
      If aCue(i)\bSubTypeA
        bInitReqd = #True
        Break
      EndIf
    Next i
    If bInitReqd
      nInitResult = vMix_Init()
    EndIf
  EndIf
  
  ; Return nInitResult which will 0 if all OK, ie that vMix_Init() didn't have to be called, or that it was called and returned success.
  ; For other return values, see vMix_Init()
  ProcedureReturn nInitResult
  
EndProcedure

Procedure vMix_Disconnect()
  PROCNAMEC()
  Protected sCommand.s, sResponse.s, bLockedMutex, nInputIndex
  
  debugMsg(sProcName, #SCS_START)
  
  With grVMixControl
    
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2702)
    
    sCommand = "UNSUBSCRIBE ACTS"
    sResponse = vMixSendCommand(sProcName, sCommand, 1000, #True, #True)

    ; clear all vMix inputs
    vMixPopulateInputInfoArray(#True)
    If grvMixInfo\nMaxInputInfo >= 0
      For nInputIndex = grvMixInfo\nMaxInputInfo To 0 Step -1
        Select grvMixInfo\aInputInfo(nInputIndex)\sType
          Case "Blank"
            ; no action required
          Case "Capture"
            ; leave "capture" (camera) inputs as vMix API doesn't support adding them
          Default
            sCommand = "FUNCTION RemoveInput Input=" + grvMixInfo\aInputInfo(nInputIndex)\sKey
            sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        EndSelect
      Next nInputIndex
    EndIf
    grvMixInfo\nMaxInputKeyToRemoveWhenvMixIdle = -1
    
    If grvMixInfo\bStartSettingFullScreenOn = #False
      sCommand = "FUNCTION FullscreenOff"
      sResponse = vMixSendCommand(sProcName, sCommand, 1000, #True, #True)
    EndIf
    
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
    
    If \nConnection
      Delay(1000) ; Added this delay because without it vMix sometimes threw an error
      debugMsg(sProcName, "calling CloseNetworkConnection(" + \nConnection + ")")
      CloseNetworkConnection(\nConnection)
      \nConnection = 0
    EndIf
    
    \bvMixInitDone = #False
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s vMixSendCommand(sCaller.s, sCommand.s, nTimeout=-1, bTrace=#False, bMutexAlreadyLocked=#False)
  PROCNAMEC()
  Protected bLockedMutex
  Protected nConnection, nReqdByteLength, nByteLength, nBytesSent, nBytesReceived
  Protected qTimeout.q, nClientEvent, sResponse.s, nExpectedResponseIndex, sExpectedResponse.s
  Protected sWord1Sent.s, sWord1Received.s, nFirstIncomingLineIndex, nIncomingLineIndex
  Protected bWaitForXMLDetail, bXMLDetailReceived
  Protected bTraceGetData
  Static *mCommandString
  
  sProcName = #PB_Compiler_Procedure + "[" + sCaller + ", " + sCommand + "]"
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2703)
  EndIf

  debugMsgC(sProcName, #SCS_START)
  
  nConnection = grVMixControl\nConnection
  nExpectedResponseIndex = -1
  
  With grvMixInfo
    If (nConnection <> 0) And (sCommand)
      If *mCommandString = 0
        *mCommandString = AllocateMemory(256)
      EndIf
      nReqdByteLength = StringByteLength(sCommand + #CRLF$, #PB_UTF8)
      If nReqdByteLength > MemorySize(*mCommandString)
        FreeMemory(*mCommandString)
        *mCommandString = AllocateMemory(nReqdByteLength)
      EndIf
      nByteLength = PokeS(*mCommandString, sCommand + #CRLF$, -1, #PB_UTF8)
      nBytesSent = SendNetworkData(nConnection, *mCommandString, nByteLength)
      If nBytesSent < 0
        debugMsg(sProcName, "SendNetworkData(nConnection, " + #DQUOTE$ + sCommand + #DQUOTE$ + ", " + nByteLength + ") returned nBytesSent=" + nBytesSent)
      Else
        sWord1Sent = StringField(sCommand, 1, " ")
        ; debugMsg(sProcName, "sWord1Sent=" + sWord1Sent)
        Select sWord1Sent
          Case "XML"
            bWaitForXMLDetail = #True
        EndSelect
        If nTimeout < 0
          qTimeout = ElapsedMilliseconds() + 500 ; default timeout is 500ms
        Else
          qTimeout = ElapsedMilliseconds() + nTimeout
        EndIf
        Delay(5) ; expect some delay befor vMix responds, so avoid unnecessary additional processing here
        While #True
          nClientEvent = NetworkClientEvent(nConnection)
          Select nClientEvent
            Case #PB_NetworkEvent_None
              Continue
            Case #PB_NetworkEvent_Connect
              ; debugMsgC(sProcName, "#PB_NetworkEvent_Connect")
            Case #PB_NetworkEvent_Disconnect
              ; debugMsgC(sProcName, "#PB_NetworkEvent_Disconnect")
            Case #PB_NetworkEvent_Data
              ; debugMsgC(sProcName, "#PB_NetworkEvent_Data")
              ; ------------------------------------------
              ; Explanation of the following reqired here.
              ; ------------------------------------------
              ; Most commands sent to vMix return a single-line response, eg "FUNCTION PreviewInput Input=5\r\n" (where \r\n represents #CRLF$) may return "FUNCTION OK\r\n"
              ; (not "FUNCTION OK PreviewInput\r\n" as documented in the online Help!).
              ; However, the command "XML" (not "XMLTEXT") returns TWO lines, the first of which contains "XML <length>\r\n" eg "XML 1292\r\n", where the length is the length of text in
              ; the second line, and the second line contains an XML text string starting the "<vmix>" and ending with "</vmix>". As these two lines form the complete response to the
              ; "XML" request, this Procedure combines the two lines to send this full response.
              ; Procedure vMix_GetData() removed the trailing #CRLF$ (to simplify testing of expected responses), so for the two-line response to "XML" we need to reinsert the #CRLF$
              ; between the two lines, eg to return something like "XML 1292\r\n<vmix>...</vmix>".
              ; See also vMix_GetData().
              nFirstIncomingLineIndex = vMix_GetData(sProcName + "<" + sCaller + ">", bTraceGetData)
              If nFirstIncomingLineIndex >= 0
                For nIncomingLineIndex = nFirstIncomingLineIndex To \nMaxIncomingMsg
                  sResponse = \sIncomingMsg(nIncomingLineIndex)
                  ; debugMsgC(sProcName, "sResponse=" + sResponse)
                  sWord1Received = StringField(sResponse, 1, " ")
                  ; debugMsgC(sProcName, "sWord1Received=" + sWord1Received + ", sResponse=" + ReplaceString(sResponse, #CRLF$, "\r\n"))
                  If sWord1Received = sWord1Sent
                    ; seems we have the expected response
                    nExpectedResponseIndex = nIncomingLineIndex
                    sExpectedResponse = sResponse
                  EndIf
                  If bWaitForXMLDetail And FindString(sResponse, "<vmix>") > 0
                    bXMLDetailReceived = #True
                    ; debugMsg(sProcName, "bXMLDetailReceived=#True")
                    If FindString(sExpectedResponse, "<vmix>") = 0
                      debugMsg(sProcName, "appending sResponse to sExpectedResponse")
                      ; append sResponse to sExpectedResponse, but note that the 'lines' returned by vMix_GetData() have their separating #CRLF$ bytes removed,
                      ; so reinstate between sExpectedResponse and sResponse
                      sExpectedResponse + #CRLF$ + sResponse
                    EndIf
                  EndIf
                Next nIncomingLineIndex
                If nExpectedResponseIndex >= 0
                  If nExpectedResponseIndex = \nMaxIncomingMsg
                    \nMaxIncomingMsg - 1
                  Else
                    \sIncomingMsg(nExpectedResponseIndex) = ""
                  EndIf
                EndIf
              EndIf
          EndSelect
          If bWaitForXMLDetail
            If bXMLDetailReceived And nExpectedResponseIndex >= 0
              Break
            EndIf
          ElseIf nExpectedResponseIndex >= 0
            Break
          EndIf
          If ElapsedMilliseconds() > qTimeout
            debugMsg(sProcName, "timeout waiting for response to " + #DQUOTE$ + sCommand + #DQUOTE$)
            sExpectedResponse = "{Timeout}"
            Break
          EndIf
          Delay(20)
        Wend
      EndIf ; EndIf nBytesSent > 0
    EndIf ; EndIf (nConnection <> 0) And (sCommand)
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  If bTrace
    ; to reduce logging, do not log 'OK' responses, eg do not log "FUNCTION OK"
    If StringField(sExpectedResponse, 2, " ") <> "OK"
      debugMsgC(sProcName, #SCS_END + ", returning " + ReplaceString(sExpectedResponse, #CRLF$, "\r\n"))
    EndIf
  EndIf
  ProcedureReturn sExpectedResponse
EndProcedure

Procedure vMixGetXMLNodeInfoDetail(*CurrentNode, CurrentSublevel, bTrace=#False)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s, sAttributeName.s, sAttributeValue.s, nInputIndex
  Protected *ChildNode
  
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    sNodeName = GetXMLNodeName(*CurrentNode)
    Select sNodeName
      Case "input"
        grvMixInfo\nMaxInputInfo + 1
        nInputIndex = grvMixInfo\nMaxInputInfo
        If nInputIndex > ArraySize(grvMixInfo\aInputInfo())
          ReDim grvMixInfo\aInputInfo(nInputIndex)
        EndIf
        With grvMixInfo\aInputInfo(nInputIndex)
          \sName = GetXMLNodeText(*CurrentNode)
          debugMsgC(sProcName, "grvMixInfo\aInputInfo(" + nInputIndex + ")\sName=" + \sName)
          If ExamineXMLAttributes(*CurrentNode)
            While NextXMLAttribute(*CurrentNode)
              sAttributeName = XMLAttributeName(*CurrentNode)
              sAttributeValue = XMLAttributeValue(*CurrentNode)
              debugMsgC(sProcName, "sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue)
              Select sAttributeName
                Case "key"
                  \sKey = sAttributeValue
                Case "number"
                  \nNumber = Val(sAttributeValue)
                Case "type"
                  \sType = sAttributeValue
                Case "title"
                  \sTitle = sAttributeValue
                Case "state"
                  \sState = sAttributeValue
                Case "position"
                  \nPosition = Val(sAttributeValue)
                Case "duration"
                  \nDuration = Val(sAttributeValue)
                Case "muted"
                  \sMuted = sAttributeValue
                Case "volume"
                  \nVolume = Val(sAttributeValue)
                  ; note: this value appears to be the equivalent of (aAud()\fBVLevel * 100)
                  ; (that info may be useful if we later want to use \nVolume)
                Case "balance"
                  \nBalance = Val(sAttributeValue)
              EndSelect
            Wend
            If \sType = "Blank"
              ; ignore 'blank' entries
              grvMixInfo\nMaxInputInfo - 1
            EndIf
          EndIf
        EndWith
        
      Case "active"
        sNodeText = GetXMLNodeText(*CurrentNode)
        grvMixInfo\nActiveInputNo = Val(sNodeText)
        ; debugMsg0(sProcName, "grvMixInfo\nActiveInputNo=" + grvMixInfo\nActiveInputNo)
        
      Case "edition"
        If grvMixInfo\bStartSettingsLoaded = #False
          sNodeText = GetXMLNodeText(*CurrentNode)
          grvMixInfo\sEdition = sNodeText
          Select UCase(grvMixInfo\sEdition)
            Case "BASIC", "BASIC HD"
              grvMixInfo\bBasicEdition = #True
              grvMixInfo\nMaxInputNoForEdition = 4
              grvMixInfo\nMaxOutputNoForEdition = 1
            Case "SD", "HD"
              grvMixInfo\nMaxInputNoForEdition = 1000
              grvMixInfo\nMaxOutputNoForEdition = 1
            Default
              grvMixInfo\nMaxInputNoForEdition = 1000
              grvMixInfo\nMaxOutputNoForEdition = 4
          EndSelect
          debugMsg(sProcName, "grvMixInfo\sEdition=" + grvMixInfo\sEdition + ", \nMaxInputNoForEdition=" + grvMixInfo\nMaxInputNoForEdition + ", \nMaxOutputNoForEdition=" + grvMixInfo\nMaxOutputNoForEdition)
        EndIf
        
      Case "fullscreen"
        If grvMixInfo\bStartSettingsLoaded = #False
          sNodeText = GetXMLNodeText(*CurrentNode)
          If sNodeText = "True"
            grvMixInfo\bStartSettingFullScreenOn = #True
          EndIf
          debugMsg(sProcName, "grvMixInfo\bStartSettingFullScreenOn=" + strB(grvMixInfo\bStartSettingFullScreenOn))
        EndIf
        
      Default
        CompilerIf 1=2
          sNodeText = GetXMLNodeText(*CurrentNode)
          debugMsgC(sProcName, sNodeName + ": sNodeText=" + sNodeText)
          If ExamineXMLAttributes(*CurrentNode)
            While NextXMLAttribute(*CurrentNode)
              sAttributeName = XMLAttributeName(*CurrentNode)
              sAttributeValue = XMLAttributeValue(*CurrentNode)
              debugMsgC(sProcName, "sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue)
            Wend
          EndIf
        CompilerEndIf
        
    EndSelect
    *ChildNode = ChildXMLNode(*CurrentNode)
    While *ChildNode <> 0
      vMixGetXMLNodeInfoDetail(*ChildNode, CurrentSublevel + 1, bTrace)
      *ChildNode = NextXMLNode(*ChildNode)
    Wend
  EndIf
EndProcedure

Procedure vMixGetXMLInfoDetail(bTrace=#False)
  PROCNAMEC()
  Protected *MainNode
  
  debugMsgC(sProcName, "Start ====================================")
  grvMixInfo\nMaxInputInfo = -1
  *MainNode = MainXMLNode(#SCS_VMIX_XML)
  If *MainNode
    debugMsgC(sProcName, "calling vMixGetXMLNodeInfoDetail(*MainNode, 0)")
    vMixGetXMLNodeInfoDetail(*MainNode, 0, bTrace)
  EndIf
  debugMsg(sProcName, "grvMixInfo\nMaxInputInfo=" + grvMixInfo\nMaxInputInfo)
  debugMsgC(sProcName, "End   ====================================")
  
EndProcedure

Procedure vMixPopulateInputInfoArray(bMutexAlreadyLocked, bTrace=#False)
  PROCNAMEC()
  ; This procedure obtains data from vMix so that vMixGetXMLInfoDetail(), which is called within this procedure, can populate the array grvMixInfo\aInputInfo().
  Protected bLockedMutex
  Protected sResponse.s, sLine2.s, nParseResult, bResult
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2704)
  EndIf
  
  sResponse = vMixSendCommand(sProcName, "XML", 2500, #True, #True)
  If Left(sResponse, 3) = "XML"
    sLine2 = StringField(sResponse, 2, #CRLF$)
    If IsXML(#SCS_VMIX_XML)
      FreeXML(#SCS_VMIX_XML)
    EndIf
    If ParseXML(#SCS_VMIX_XML, sLine2)
      nParseResult = XMLStatus(#SCS_VMIX_XML)
      If nParseResult = #PB_XML_Success
        vMixGetXMLInfoDetail(bTrace)
        bResult = #True
      Else
        debugMsgC(sProcName, "XMLStatus(#SCS_VMIX_XML) returned " + nParseResult)
        debugMsgC(sProcName, "sLine2=" + sLine2)
      EndIf
    EndIf
  EndIf
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure vMixSetInputNrs()
  PROCNAMEC()
  ; The procedure must be called (after calling vMixPopulateInputInfoArray()) whenever SCS makes a change to the inputs in vMix, eg when adding or removing an input.
  Protected k, n, sThisKey.s, nInputNr
  
  With grvMixInfo
    If \nMaxInputInfo >= 0
      For k = 1 To gnLastAud
        If aAud(k)\bAudTypeA
          sThisKey = aAud(k)\svMixInputKey
          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\svMixInputKey=" + aAud(k)\svMixInputKey)
          If sThisKey
            nInputNr = 0
            For n = 0 To \nMaxInputInfo
              If grvMixInfo\aInputInfo(n)\sKey = sThisKey
                nInputNr = grvMixInfo\aInputInfo(n)\nNumber
                Break
              EndIf
            Next n
            If aAud(k)\nvMixInputNr <> nInputNr
              debugMsg(sProcName, "setting aAud(" + getAudLabel(k) + ")\nvMixInputNr=" + nInputNr + " (was " + aAud(k)\nvMixInputNr + ")")
              aAud(k)\nvMixInputNr = nInputNr
              If nInputNr = 0
                aAud(k)\svMixInputKey = ""
              EndIf
            EndIf
          EndIf ; EndIf sThisKey
        EndIf ; EndIf aAud(k)\bAudTypeA
      Next k
    EndIf ; EndIf \nInputCount > 0
  EndWith
  
EndProcedure

Procedure vMix_AddInput(pAudPtr, bMutexAlreadyLocked=#False)
  ; returns nClipNo - see end of procedure for details
  PROCNAMECA(pAudPtr)
  Protected bLockedMutex
  Protected nClipNo, sFileType.s, sFileName.s, nPhysicalDevPtr, sPartFileName.s, nPass
  Protected sCommand.s, sResponse.s, nInputIndex, sInputKey.s, nOldMaxInputInfo, nNewMaxInputInfo
  Protected nSubPtr, sScreens.s, nScreenCount, nvMixOutputNr, bOutputFound, n
  Static bTraceInputInfoOnce = #True
  
  debugMsg(sProcName, #SCS_START)
  
  If grvMixControl\bvMixInitDone = #False
    debugMsg(sProcName, "calling vMix_Init()")
    If vMix_Init() <> 0
      debugMsg(sProcName, "vMix_Init() failed, returning nClipNo=" + nClipNo)
      ; nb nClipNo will be 0 (zero)
      ProcedureReturn nClipNo
    EndIf
  EndIf
  
  If grvMixInfo\bvMixEditionNotSupported
    ; nb nClipNo will be 0 (zero)
    ProcedureReturn nClipNo
  EndIf
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2705)
  EndIf
  
  With aAud(pAudPtr)
    nSubPtr = \nSubIndex
    \svMixInputKey = grAudDef\svMixInputKey
    \nvMixInputNr = grAudDef\nvMixInputNr
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileFormat=" + decodeFileFormat(\nFileFormat))
    
    sScreens = aSub(nSubPtr)\sScreens
    nScreenCount = CountString(sScreens, ",") + 1
    debugMsg(sProcName, "sScreens=" + #DQUOTE$ + sScreens + #DQUOTE$ + ", nScreenCount=" + nScreenCount)
    For n = 1 To nScreenCount
      nvMixOutputNr = Val(StringField(sScreens, n, ",")) - 1
      If nvMixOutputNr <= grvMixInfo\nMaxOutputNoForEdition ; grvMixInfo\nMaxOutputNoForEdition will be 2 or 4
        \bvMixOutputReqd(nvMixOutputNr) = #True
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bvMixOutputReqd(" + nvMixOutputNr + ")=" + strB(\bvMixOutputReqd(nvMixOutputNr)))
        bOutputFound = #True
      EndIf
    Next n
    If bOutputFound = #False
      ; if no valid screen numbers found (eg user specified screen 9 only) then route to vMix Output1
      \bvMixOutputReqd(1) = #True
    EndIf
    
    If \nFileFormat = #SCS_FILEFORMAT_CAPTURE
      sFileType = "Capture"
      nPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_CAPTURE, \sVideoCaptureLogicalDevice)
      If nPhysicalDevPtr >= 0
        sFileName = gaVideoCaptureDev(nPhysicalDevPtr)\sVidCapName
        nInputIndex = vMixGetInputIndexForTypeAndTitle(sFileType, sFileName)
        debugMsg2(sProcName, "vMixGetInputIndexForTypeAndTitle(" + sFileType +  ", " + sFileName + ")", nInputIndex)
        If nInputIndex >= 0
          \svMixInputKey = grvMixInfo\aInputInfo(nInputIndex)\sKey
          \nvMixInputNr = grvMixInfo\aInputInfo(nInputIndex)\nNumber
          sInputKey = \svMixInputKey
          nClipNo = grvMixInfo\nNextClipNo ; 'clip no.' is an SCS-generated number used as a handle to the video/image
          grvMixInfo\nNextClipNo + 1
        EndIf
      EndIf
      
    Else
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        sFileType = "Image"
      Else
        sFileType = "Video"
      EndIf
      sFileName = \sFileName
      sPartFileName = GetFilePart(sFileName)
      sCommand = "FUNCTION AddInput Value=" + sFileType + "|" + sFileName
      debugMsg(sProcName, "calling vMixSendCommand(" + #DQUOTE$ + sCommand + #DQUOTE$ + ", 3500, #True, " + strB(#True) + ")")
      sResponse = vMixSendCommand(sProcName, sCommand, 3500, #True, #True)
      debugMsg(sProcName, "sResponse=" + sResponse)
      
      If Left(sResponse, 11) = "FUNCTION OK" Or sResponse = "{Timeout}" ; nb if timeout, check anyway
        For nPass = 1 To 2
          If nPass > 1
            debugMsg(sProcName, "nPass=" + nPass)
          EndIf
          If vMixPopulateInputInfoArray(#True, bTraceInputInfoOnce)
            nClipNo = -2
            nInputIndex = vMixGetInputIndexForTypeAndTitle(sFileType, sPartFileName)
            debugMsg2(sProcName, "vMixGetInputIndexForTypeAndTitle(" + sFileType +  ", " + sFileName + ")", nInputIndex)
            If nInputIndex >= 0
              \svMixInputKey = grvMixInfo\aInputInfo(nInputIndex)\sKey ; the vMix-generated unique key for this clip
              \nFileDuration = grvMixInfo\aInputInfo(nInputIndex)\nDuration ; the duration of the clip in milliseconds
              sInputKey = \svMixInputKey
              nClipNo = grvMixInfo\nNextClipNo ; 'clip no.' is an SCS-generated number used as a handle to the video/image
              grvMixInfo\nNextClipNo + 1
              ; a new vMix input has been added, so (re)set all aAud()\nvMixInputNr fields
              vMixSetInputNrs()
              Break ; Break nPass
            EndIf ; EndIf nInputIndex >= 0
          EndIf ; EndIf vMixPopulateInputInfoArray()
          ; If we get here then the \aInputInfo() array has not yet been updated, so wait 500ms and try again (once more only)
          If nPass < 2
            Delay(500)
          EndIf
        Next nPass
        bTraceInputInfoOnce = #False
        If nClipNo = -2 And sResponse = "{Timeout}"
          nClipNo = 0
        EndIf
        
      ElseIf Left(sResponse, 11) = "FUNCTION ER"
        If FindString(sResponse, "Input Limit", 1, #PB_String_NoCase)
          nClipNo = -1
          grvMixInfo\bInputLimitReached = #True
        EndIf
        
      EndIf
    EndIf
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  If nClipNo > 0
    debugMsg(sProcName, #SCS_END + ", returning nClipNo=" + nClipNo + ", sInputKey=" + sInputKey)
  Else
    debugMsg(sProcName, #SCS_END + ", returning nClipNo=" + nClipNo)
  EndIf
  ; nb nClipNo will be > 0 if the input was added OK
  ;                     -1 if the input could not be added because the limit has been reached on the number of permitted vMix inputs (determined by the vMix license)
  ;                     -2 if vMix reported the AddInput function was OK but, in fact, did not add the input
  ;                      0 if the input could not be added for some other reason
  ProcedureReturn nClipNo
  
EndProcedure

Procedure vMixPlayToOneOutput(pAudPtr, nvMixOutput, bFirstPlayingOutput, bMutexAlreadyLocked=#False)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s, bLockedMutex
  Protected nReqdFadeInTime, sReqdTransitionEffect.s

  debugMsg(sProcName, #SCS_START)
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2716)
  EndIf
  
  With aAud(pAudPtr)
    If nvMixOutput = 1
      ; Output1 (the main program output) is the only Output vMix supports for transitions from Preview
      If \nPrevAudIndex = -1
        nReqdFadeInTime = aSub(\nSubIndex)\nPLFadeInTime
      Else
        nReqdFadeInTime = \nFadeInTime
      EndIf
      If nReqdFadeInTime > 0
        sCommand = "FUNCTION PreviewInput Input=" + aAud(pAudPtr)\svMixInputKey
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        
        If grvMixInfo\nTransition1Duration <> nReqdFadeInTime
          sCommand = "FUNCTION SetTransitionDuration1 Value=" + nReqdFadeInTime
          sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
          grvMixInfo\nTransition1Duration = nReqdFadeInTime
        EndIf
        
        sReqdTransitionEffect = "Fade"
        ; For available effects see vMix Help: Transitions - Fade/Transition Buttons
        ; Currently: "Fade", "Zoom", "Wipe", "Slide", "Fly", "CrossZoom", "FlyRotate", "Cube", "CubeZoom", "VerticalWipe", "VerticalSlide", "Merge", "Stinger1", "Stinger2"
        If grvMixInfo\sTransition1Effect <> sReqdTransitionEffect
          sCommand = "FUNCTION SetTransitionEffect1 Value=" + sReqdTransitionEffect
          sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
          grvMixInfo\sTransition1Effect = sReqdTransitionEffect
        EndIf
        
        sCommand = "FUNCTION Transition1"
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        
      Else ; nReqdFadeInTime = 0
        sCommand = "FUNCTION CutDirect Input=" + aAud(pAudPtr)\svMixInputKey
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        sCommand = "FUNCTION PreviewInput Input=" + aAud(pAudPtr)\svMixInputKey
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        
      EndIf
      
    Else
      ; Output2-4 must be set directly - no transitions possible
      sCommand = "FUNCTION SetOutput" + nvMixOutput + " Value=Input&Input=" + aAud(pAudPtr)\svMixInputKey
      sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
      If bFirstPlayingOutput
        sCommand = "FUNCTION Play Input=" + aAud(pAudPtr)\svMixInputKey
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
      EndIf
      
    EndIf ; EndIf nvMixOutput = 1 / Else
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_PlayInput(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bLockedMutex
  Protected sCommand.s, sResponse.s, nReqdFadeInTime, sReqdTransitionEffect.s, bStartedInEditor, bPreviewOnOutputScreen
  Protected nSubPtr, nvMixOutput, bFirstPlayingOutput
  
  debugMsg(sProcName, #SCS_START)
  
  scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2706)
  
  With aAud(pAudPtr)
    If \nPrevAudIndex = -1
      nReqdFadeInTime = aSub(\nSubIndex)\nPLFadeInTime
    Else
      nReqdFadeInTime = \nFadeInTime
    EndIf
    
    bStartedInEditor = aSub(\nSubIndex)\bStartedInEditor
    If bStartedInEditor = #False
      debugMsg(sProcName, "grvMixInfo\nMaxOutputNoForEdition=" + grvMixInfo\nMaxOutputNoForEdition)
      bFirstPlayingOutput = #True
      For nvMixOutput = 1 To grvMixInfo\nMaxOutputNoForEdition
        If \bvMixOutputReqd(nvMixOutput)
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bvMixOutputReqd(" + nvMixOutput + ")=" + strB(\bvMixOutputReqd(nvMixOutput)))
          vMixPlayToOneOutput(pAudPtr, nvMixOutput, bFirstPlayingOutput, #True)
          bFirstPlayingOutput = #False
        EndIf
      Next nvMixOutput
      
    Else ; started in editor
      bPreviewOnOutputScreen = gbPreviewOnOutputScreen
      If bPreviewOnOutputScreen
        If WQA_checkPreviewOnOutputScreenAvailable(pAudPtr) = #False
          bPreviewOnOutputScreen = #False
        EndIf
      EndIf
      If bPreviewOnOutputScreen
        nvMixOutput = aSub(\nSubIndex)\nOutputScreen - 1 ; eg nOutputScreen 2 mapped to vMix Output1
        vMixPlayToOneOutput(pAudPtr, nvMixOutput, #True, #True)
      Else
        sCommand = "FUNCTION Play Input=" + aAud(pAudPtr)\svMixInputKey
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        sCommand = "FUNCTION AudioOn Input=" + aAud(pAudPtr)\svMixInputKey
        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
      EndIf
      vMix_DrawPreviewText(WQA\cvsPreview, pAudPtr)
    EndIf
  EndWith
  
  scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_FadeOutInput(pAudPtr, nReqdFadeOutTime)
  PROCNAMECA(pAudPtr)
  
  ; nb only 'fades out' if there is not another video playing, hence the call to vMix_CheckActive()
  debugMsg(sProcName, #SCS_START + ", nReqdFadeOutTime=" + nReqdFadeOutTime)
  
  If vMix_CheckActive(pAudPtr) = #False
    ; no videos/image currently playing except for pAudPtr, so fade to the black colour input (don't use 'fade to black' as that affects the whole output and leaves the pAudPtr image as the current image, even though then blacked out)
    vMixFadeToBlackImage(nReqdFadeOutTime, #False)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_PauseInput(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s
  
  debugMsg(sProcName, #SCS_START)
  
  sCommand = "FUNCTION Pause Input=" + aAud(pAudPtr)\svMixInputKey
  sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_ResumeInput(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s
  
  debugMsg(sProcName, #SCS_START)
  
  ; NB No 'Resume' shortcut in vMix
  sCommand = "FUNCTION Play Input=" + aAud(pAudPtr)\svMixInputKey
  sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_RestartInput(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    sCommand = "FUNCTION Restart Input=" + aAud(pAudPtr)\svMixInputKey
    sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_StopInput(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    ; NB No 'Stop' shortcut in vMix
    sCommand = "FUNCTION Pause Input=" + \svMixInputKey
    sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
    
    If aSub(\nSubIndex)\bStartedInEditor
      ; 'rewind' if stopped in the editor
      sCommand = "FUNCTION SetPosition Input=" + \svMixInputKey + "&Value=0"
      sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
      sCommand = "FUNCTION AudioOff Input=" + \svMixInputKey
      sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
    EndIf
    
    If aSub(\nSubIndex)\bStartedInEditor
      vMix_DrawPreviewText(WQA\cvsPreview, pAudPtr)
    EndIf

  EndWith

  If vMixCheckAnyInputsRunning() = #False
    vMixFadeToBlackImage(0, #False, #True)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_PreviewInput(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s
  
  debugMsg(sProcName, #SCS_START)
  
  sCommand = "FUNCTION PreviewInput Input=" + aAud(pAudPtr)\svMixInputKey
  sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_SetXYPosAndSize(pAudPtr, nPosSizeAdjustments=#SCS_PS_ALL, bMutexAlreadyLocked=#False, bTrace=#False)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s, bLockedMutex
  Protected fSize.f, fValue.f
  
  ; debugMsgC(sProcName, #SCS_START)
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2714)
  EndIf
  
  With aAud(pAudPtr)
    If nPosSizeAdjustments & #SCS_PS_XPOS
      ; X Position (vMix XPan)
      fValue = (\nXPos / 5000) * 2 ; Convert SCS XPos (range -5000 to +5000) to vMix XPan floating point value (range -2.0 to +2.0)
      sCommand = "FUNCTION SetPanX Input=" + \svMixInputKey + "&Value=" + StrF(fValue,3)
      sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, bMutexAlreadyLocked)
    EndIf
    
    If nPosSizeAdjustments & #SCS_PS_YPOS
      ; Y Position (vMix YPan)
      fValue = (\nYPos / 5000) * 2 ; Convert SCS YPos (range -5000 to +5000) to vMix XPan floating point value (range -2.0 to +2.0)
      fValue * -1                  ; invert or YPan adjustment moves image up when it should go down, and vice versa
      sCommand = "FUNCTION SetPanY Input=" + \svMixInputKey + "&Value=" + StrF(fValue,3)
      sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, bMutexAlreadyLocked)
    EndIf
    
    If nPosSizeAdjustments & #SCS_PS_SIZE
      ; Size (vMix Zoom)
      fSize = \nSize * -1
      ; SCS nSize range from -500 to +500, where 0 = no zoom (100%)
      ; vMix zoom range from 0 to 5, where 1=100%, 0.5=50%, 2=200%
      If fSize >= 0.0
        ; values 0 - 500 to be converted to vMix zoom values 1.0 to 5.0
        fValue = (fSize / 125) + 1.0
      Else
        ; values -500 to < 0.0 to be converted to vMix zoom values 0 to 1.0
        fValue = (fSize + 500) / 500
      EndIf
      If fValue = 0.0
        ; vMix treats 0.0 as 'no zoom', ie 100%
        fValue = 0.001
      EndIf
      sCommand = "FUNCTION SetZoom Input=" + \svMixInputKey + "&Value=" + StrF(fValue,3)
      sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, bMutexAlreadyLocked)
    EndIf
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  ; debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_CheckActive(pDoNotCheckAud=-1)
  PROCNAMEC()
  Protected i, j, k, nCueState, bvMixActive
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeA
      nCueState = aCue(i)\nCueState
      If nCueState >= #SCS_CUE_FADING_IN And nCueState <= #SCS_CUE_FADING_OUT And nCueState <> #SCS_CUE_HIBERNATING
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeA
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If k <> pDoNotCheckAud
                If aAud(k)\nAudState >= #SCS_CUE_FADING_IN And aAud(k)\nAudState <= #SCS_CUE_FADING_OUT
                  bvMixActive = #True
                  Break 3 ; Break k, j, i
                EndIf
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf ; EndIf aSub(j)\bSubTypeA
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf ; EndIf nCueState >= #SCS_CUE_FADING_IN And nCueState <= #SCS_CUE_FADING_OUT And nCueState <> #SCS_CUE_HIBERNATING
    EndIf ; EndIf aCue(i)\bSubTypeA
  Next i
  ProcedureReturn bvMixActive
EndProcedure

Procedure vMix_RemoveInput(pAudPtr, bForceRemove=#False, bMutexAlreadyLocked=#False)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s, bLockedMutex, nInputsRemoved
  
  debugMsg(sProcName, #SCS_START + ", bForceRemove=" + strB(bForceRemove))
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2707)
  EndIf
  
  With aAud(pAudPtr)
    If \nFileFormat = #SCS_FILEFORMAT_CAPTURE
      If vMix_CheckActive(pAudPtr) = #False
        ; vMix is not actively displaying an input other than that for pAudPtr, so blackout the output
        vMixFadeToBlackImage(0, #True)
      EndIf
    Else
      If \svMixInputKey
        If bForceRemove = #False And vMix_CheckActive(pAudPtr)
          vMixAddInputKeyToRemoveWhenvMixIdle(\svMixInputKey)
          ; NB Issuing RemoveInput while other inputs are playing can cause a brief black image to be displayed, so use this array to defer removing the input
          ; However, hide the image by setting the alpha to 0. (Tried using PreviewInput to the black image, but that seemd to set the output to the black image.)
          sCommand = "FUNCTION SetAlpha Input=" + \svMixInputKey + "&Value=0"
          sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        Else
          sCommand = "FUNCTION RemoveInput Input=" + \svMixInputKey
          sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
          nInputsRemoved + 1
          \svMixInputKey = grAudDef\svMixInputKey
          \nvMixInputNr = grAudDef\nvMixInputNr
        EndIf
      EndIf
    EndIf
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning nInputsRemoved=" + nInputsRemoved)
  ProcedureReturn nInputsRemoved
  
EndProcedure

Procedure vMixAddInputKeyToRemoveWhenvMixIdle(sInputKey.s)
  PROCNAMEC()
  
  With grvMixInfo
    If sInputKey
      \nMaxInputKeyToRemoveWhenvMixIdle + 1
      If \nMaxInputKeyToRemoveWhenvMixIdle > ArraySize(\sInputKeyToRemoveWhenvMixIdle())
        ReDim \sInputKeyToRemoveWhenvMixIdle(\nMaxInputKeyToRemoveWhenvMixIdle + 5)
      EndIf
      \sInputKeyToRemoveWhenvMixIdle(\nMaxInputKeyToRemoveWhenvMixIdle) = sInputKey
    EndIf
  EndWith
  
EndProcedure

Procedure vMix_RemoveRequestedInputs(bMutexAlreadyLocked)
  PROCNAMEC()
  Protected bLockedMutex
  Protected sCommand.s, sResponse.s, nIndex, nInputsRemoved
  
  debugMsg(sProcName, #SCS_START)
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2712)
  EndIf
  
  With grvMixInfo
    For nIndex = 0 To \nMaxInputKeyToRemoveWhenvMixIdle
      sCommand = "FUNCTION RemoveInput Input=" + \sInputKeyToRemoveWhenvMixIdle(nIndex)
      sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
      nInputsRemoved + 1
    Next nIndex
    \nMaxInputKeyToRemoveWhenvMixIdle = -1
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf

  debugMsg(sProcName, #SCS_END + ", returning nInputsRemoved=" + nInputsRemoved)
  ProcedureReturn nInputsRemoved
  
EndProcedure

Procedure vMix_GetPosition(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  PROCNAMEC() ; 'fast' setting of sProcName, as vMixSendCommand() requires this field
  Protected sCommand.s, sResponse.s, nFilePos
  
  sCommand = "XMLTEXT vmix/inputs/input[" + aAud(pAudPtr)\nvMixInputNr + "]/@position"
  ; sCommand = "XMLTEXT vmix/inputs/input[" + aAud(pAudPtr)\svMixInputKey + "]/@position"
  ; sCommand = "XMLTEXT vmix/inputs/input[" + #DQUOTE$ + aAud(pAudPtr)\svMixInputKey + #DQUOTE$ + "]/@position"
  sResponse = vMixSendCommand(sProcName, sCommand)
  If Left(sResponse,10) = "XMLTEXT OK"
    nFilePos = Val(StringField(sResponse, 3, " "))
  Else
    nFilePos = -1
  EndIf
  ; debugMsg(sProcName, "nFilePos=" + nFilePos)
  ProcedureReturn nFilePos
  
EndProcedure

Procedure vMix_SetPosition(pAudPtr, nPosition)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s, sResponse.s
  
  debugMsg(sProcName, #SCS_START + ", nPosition=" + nPosition)
  
  With aAud(pAudPtr)
    sCommand = "FUNCTION SetPosition Input=" + \svMixInputKey + "&Value=" + nPosition
    sResponse = vMixSendCommand(sProcName, sCommand, -1, #True)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_SetLevel(pAudPtr, fVideoLevelSingle.f)
  CompilerIf #cTraceSetLevels
    PROCNAMECA(pAudPtr)
  CompilerElse
    PROCNAMEC() ; 'fast' setting of sProcName, as vMixSendCommand() requires this field
  CompilerEndIf
  Protected sCommand.s, sResponse.s
  Protected nVolume, fdbSingle.f
  
  ; debugMsg(sProcName, #SCS_START + ", nLevel=" + nLevel)
  
  With aAud(pAudPtr)
    fdbSingle = convertBVLevelToDBLevel(fVideoLevelSingle)
    nVolume = vMixCalcVolume(fdbSingle)
    CompilerIf #cTraceSetLevels
      debugMsg(sProcName, "fVideoLevelSingle=" + StrF(fVideoLevelSingle,9) + ", fdbSingle=" + StrF(fdbSingle,3) + ", nVolume=" + nVolume)
    CompilerEndIf
    sCommand = "FUNCTION SetVolume Input=" + \svMixInputKey + "&Value=" + nVolume
    sResponse = vMixSendCommand(sProcName, sCommand, -1, #cTraceSetLevels)
    ; vMixPopulateInputInfoArray(#False, #True)
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_SetPan(pAudPtr, fPan.f)
  CompilerIf #cTraceSetLevels
    PROCNAMECA(pAudPtr)
  CompilerElse
    PROCNAMEC() ; 'fast' setting of sProcName, as vMixSendCommand() requires this field
  CompilerEndIf
  Protected sCommand.s, sResponse.s
  
  ; debugMsg(sProcName, #SCS_START + ", fPan=" + StrF(fPan,3))
  
  With aAud(pAudPtr)
    sCommand = "FUNCTION SetBalance Input=" + \svMixInputKey + "&Value=" + StrF(fPan,3)
    sResponse = vMixSendCommand(sProcName, sCommand, -1, #cTraceSetLevels)
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s vMix_GetState(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  PROCNAMEC() ; 'fast' setting of sProcName, as vMixSendCommand() requires this field
  Protected sCommand.s, sResponse.s, sState.s, nKeyPtr, nStatePtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    
    ; sCommand = "XMLTEXT vmix/inputs/input[" + aAud(pAudPtr)\nvMixInputNr + "]/@state"
    ; sResponse = vMixSendCommand(sProcName, sCommand)
    ; If Left(sResponse,10) = "XMLTEXT OK"
    ;   sState = StringField(sResponse, 3, " ")
    ; EndIf
    
    ; NOTE: Input Nr not always reliable - doesn't seem to get updated quickly - so use "XML" command instead, and search the response using the input key
    
    sResponse = vMixSendCommand(sProcName, "XML")
    ; debugMsg(sProcName, "sResponse=" + ReplaceString(sResponse, #CRLF$, "\r\n"))
    If Left(sResponse,4) = "XML "
      nKeyPtr = FindString(sResponse, \svMixInputKey)
      If nKeyPtr > 0
        nStatePtr = FindString(sResponse, "state", nKeyPtr + Len(\svMixInputKey))
        If nStatePtr > 0
          sState = StringField(Mid(sResponse, nStatePtr, 20), 2, #DQUOTE$)
        EndIf
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", nKeyPtr=" + nKeyPtr + ", nStatePtr=" + nStatePtr + ", returning sState=" + sState)
  ProcedureReturn sState
  
EndProcedure

Procedure vMixResetInputNrs(bMutexAlreadyLocked)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  vMixPopulateInputInfoArray(bMutexAlreadyLocked)
  vMixSetInputNrs()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMix_GetData(sCaller.s, bTrace=#False)
  PROCNAMEC()
  Protected nBytesReceived, sResponse.s, nLineCount, nLineIndex, sLine.s, nFirstLineIndex=-1, sPrevLine.s, bWaitForXMLInfo, nWaitCount
  
  debugMsgC(sProcName, #SCS_START + ", sCaller=" + sCaller)
  
  With grvMixInfo
    If *gmNetworkReceiveBuffer
      nBytesReceived = ReceiveNetworkData(grVMixControl\nConnection, *gmNetworkReceiveBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS)
      If nBytesReceived > 0
        sResponse = PeekS(*gmNetworkReceiveBuffer, nBytesReceived, #PB_Ascii)
        debugMsgC(sProcName, "PeekS(*gmNetworkReceiveBuffer, " + nBytesReceived + ", #PB_Ascii) returned " + ReplaceString(sResponse, #CRLF$, "\r\n"))
        nLineCount = CountString(sResponse, #CRLF$)
        For nLineIndex = 1 To nLineCount
          sLine = StringField(sResponse, nLineIndex, #CRLF$)
          If sLine
            If bWaitForXMLInfo
              ; continuation of an XML request (not XMLTEXT, just XML) so append this continuation line to the XML line
              \sIncomingMsg(\nMaxIncomingMsg) + #CRLF$ + sLine
            Else
              \nMaxIncomingMsg + 1
              If \nMaxIncomingMsg > ArraySize(\sIncomingMsg())
                ReDim \sIncomingMsg(\nMaxIncomingMsg + 20)
              EndIf
              \sIncomingMsg(\nMaxIncomingMsg) = sLine
              If nFirstLineIndex < 0
                nFirstLineIndex = \nMaxIncomingMsg
              EndIf
              bWaitForXMLInfo = #False
              If Left(sLine, 4) = "XML "
                If FindString(sLine, "<vmix>") = 0
                  bWaitForXMLInfo = #True
                EndIf
              EndIf
            EndIf
            debugMsgC(sProcName, "grvMixInfo\sIncomingMsg(" + \nMaxIncomingMsg + ")=" + ReplaceString(\sIncomingMsg(\nMaxIncomingMsg), #CRLF$, "\r\n"))
            sPrevLine = sLine
          EndIf
        Next nLineIndex
      EndIf
    EndIf
  EndWith
  
  debugMsgC(sProcName, #SCS_END + ", returning nFirstLineIndex=" + nFirstLineIndex)
  ProcedureReturn nFirstLineIndex

EndProcedure

Procedure vMix_ProcessIncomingMessages(bMutexAlreadyLocked)
  PROCNAMEC()
  Protected bLockedMutex
  Protected nLineIndex, sLine.s, sWord1.s, sWord2.s, sWord3.s, bCallResetInputNrs
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2708)
  EndIf

  With grvMixInfo
    ; debugMsg(sProcName, "grvMixInfo\nMaxIncomingMsg=" + \nMaxIncomingMsg)
    For nLineIndex = 0 To \nMaxIncomingMsg
      ; debugMsg(sProcName, "grvMixInfo\sIncomingMsg(" + nLineIndex + ")=" + ReplaceString(\sIncomingMsg(nLineIndex), #CRLF$, "\r\n"))
      sLine = \sIncomingMsg(nLineIndex)
      If sLine
        sWord1 = StringField(sLine, 1, " ")
        Select sWord1
          Case "VERSION"
            debugMsg(sProcName, sLine)
          Case "ACTS"
            sWord2 = StringField(sLine, 2, " ")
            sWord3 = StringField(sLine, 3, " ")
            If sWord2 = "OK" And sWord3 = "Input"
              ; We will call vMixResetInputNrs() later in this procedure if we receive messages like "ACTS OK Input 1 0" or "ACTS OK Input 2 1",
              ; which mean that a vMix Input has been stopped or started.
              ; Stopping an Input can also mean the Input is now closed, causing a renumbering of the remaining Inputs.
              bCallResetInputNrs = #True
            EndIf
          Case "FUNCTION"
            debugMsg(sProcName, sLine)
        EndSelect
        \sIncomingMsg(nLineIndex) = ""
      EndIf
    Next nLineIndex
    \nMaxIncomingMsg = -1 ; all messages processed or discarded, so clear the array
    If bCallResetInputNrs
      vMixResetInputNrs(#True)
    EndIf
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
EndProcedure

Procedure vMix_RemoveInputsNotPlaying(bMutexAlreadyLocked=#False, nMaxInputsToRemove=-1)
  PROCNAMEC()
  ; nMaxInputsToRemove = -1 means no limit to the number of inputs that may be removed
  Protected sCommand.s, sResponse.s, bLockedMutex
  Protected i, j, k, nCueState, bResetCueState, nInputsRemoved, bRemovedMaxInputs
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2713)
  EndIf
  
  ; The following loop is in reverse order of the cues, primarily for situations where nMaxInputsToRemove has been set, so the later cues in the cue list are checked first.
  ; (Not yet designed for hotkey cues, etc that may be required to stay open.)
  For i = gnLastCue To 1 Step -1
    bResetCueState = #False
    If aCue(i)\bSubTypeA
      nCueState = aCue(i)\nCueState
      If nCueState > #SCS_CUE_NOT_LOADED
        If nCueState < #SCS_CUE_FADING_IN Or nCueState > #SCS_CUE_FADING_OUT
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeA
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                With aAud(k)
                  If \nFileFormat <> #SCS_FILEFORMAT_CAPTURE
                    If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
                      If \svMixInputKey
                        sCommand = "FUNCTION RemoveInput Input=" + \svMixInputKey
                        sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
                        \svMixInputKey = grAudDef\svMixInputKey
                        \nvMixInputNr = grAudDef\nvMixInputNr
                        \nAudState = #SCS_CUE_NOT_LOADED
                        \nFileState = #SCS_FILESTATE_CLOSED
                        bResetCueState = #True
                        nInputsRemoved + 1
                        If nMaxInputsToRemove > 0
                          If nInputsRemoved >= nMaxInputsToRemove
                            bRemovedMaxInputs = #True
                            Break 2 ; Break k, j
                          EndIf
                        EndIf
                      EndIf
                    EndIf ; EndIf \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
                  EndIf ; EndIf \nFileFormat <> #SCS_FILEFORMAT_CAPTURE
                  k = aAud(k)\nNextAudIndex
                EndWith
              Wend
            EndIf ; EndIf aSub(j)\bSubTypeA
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf ; EndnCueState < #SCS_CUE_FADING_IN Or nCueState > #SCS_CUE_FADING_OUT
      EndIf ; EndIf nCueState > #SCS_CUE_NOT_LOADED
    EndIf ; EndIf aCue(i)\bSubTypeA
    If bResetCueState
      setCueState(i)
    EndIf
    If bRemovedMaxInputs
      Break
    EndIf
  Next i

  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning nInputsRemoved=" + nInputsRemoved)
  ProcedureReturn nInputsRemoved
  
EndProcedure

Procedure vMixBuildVideoList(pSubPtr)
  PROCNAMEC()
  Protected k, nCuePtr, sErrorMsg.s
  
  If grvMixInfo\bBasicEdition
    ; NB vMix VideoList not available in Basic and Basic HD editions
    k = aSub(pSubPtr)\nFirstPlayIndex
    While k >= 0
      aAud(k)\nAudState = #SCS_CUE_ERROR
      aAud(k)\nFileState = #SCS_FILESTATE_CLOSED
      k = aAud(k)\nNextPlayIndex
    Wend
    aSub(pSubPtr)\nSubState = #SCS_CUE_ERROR
    sErrorMsg = Lang("vMix", "NoVideoList") ; "vMix VideoList not supported in Basic editions"
    aSub(pSubPtr)\sErrorMsg = sErrorMsg
    nCuePtr = aSub(pSubPtr)\nCueIndex
    setCueState(nCuePtr)
    If aCue(nCuePtr)\nCueState = #SCS_CUE_ERROR And Len(aCue(nCuePtr)\sErrorMsg) = 0
      aCue(nCuePtr)\sErrorMsg = sErrorMsg
    EndIf
  Else
    ; TODO Create vMix VideoList
  EndIf
  
EndProcedure

Procedure vMixGetInputIndexForTypeAndTitle(sType.s, sTitle.s)
  PROCNAMEC()
  Protected nIndex, nInputIndex
  
  nInputIndex = -1
  For nIndex = grvMixInfo\nMaxInputInfo To 0 Step -1
    With grvMixInfo\aInputInfo(nIndex)
      If \sType = sType And \sTitle = sTitle
        nInputIndex = nIndex
        Break
      EndIf
    EndWith
  Next nIndex
  ProcedureReturn nInputIndex
EndProcedure

Procedure vMixFadeToBlackImage(nFadeTime, bMutexAlreadyLocked, bTrace=#False)
  PROCNAMEC()
  ; Use this Procedure rather than the vMix FadeToBlack transition as that fades the entire output and so the next video or image displayed will not be visible.
  ; See also vMix_FadeOutInput() which will this procedure if no SCS cues are currently playing (see note at top of vMix_FadeOutInput() for the reason)
  Protected bLockedMutex
  Protected sCommand.s, sResponse.s, sReqdTransitionEffect.s
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2709)
  EndIf
  
  If nFadeTime > 0
    sCommand = "FUNCTION PreviewInput Input=" +  grvMixInfo\sBlackColourKey
    sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, #True)
    
    If grvMixInfo\nTransition1Duration <> nFadeTime
      sCommand = "FUNCTION SetTransitionDuration1 Value=" + nFadeTime
      sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, #True)
      grvMixInfo\nTransition1Duration = nFadeTime
    EndIf
    
    sReqdTransitionEffect = "Fade"
    ; For available effects see vMix Help: Transitions - Fade/Transition Buttons
    ; Currently: "Fade", "Zoom", "Wipe", "Slide", "Fly", "CrossZoom", "FlyRotate", "Cube", "CubeZoom", "VerticalWipe", "VerticalSlide", "Merge", "Stinger1", "Stinger2"
    If grvMixInfo\sTransition1Effect <> sReqdTransitionEffect
      sCommand = "FUNCTION SetTransitionEffect1 Value=" + sReqdTransitionEffect
      sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, #True)
      grvMixInfo\sTransition1Effect = sReqdTransitionEffect
    EndIf
    
    sCommand = "FUNCTION Transition1"
    sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, #True)
    
  Else
    
    ; If nFadeTime = 0 then cut directly to the black image, but then also set the preview at the black image because CutDirect bypasses the preview
    sCommand = "FUNCTION CutDirect Input=" + grvMixInfo\sBlackColourKey
    sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, #True)
    
    sCommand = "FUNCTION PreviewInput Input=" +  grvMixInfo\sBlackColourKey
    sResponse = vMixSendCommand(sProcName, sCommand, -1, bTrace, #True)
    
  EndIf
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
EndProcedure

Procedure vMixLoadBlackImage(bMutexAlreadyLocked=#False)
  PROCNAMEC()
  Protected bLockedMutex
  Protected sCommand.s, sResponse.s, nPass, nInputIndex
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2710)
  EndIf
  
  sCommand = "FUNCTION AddInput Value=Colour|%23000000"
  sResponse = vMixSendCommand(sProcName, sCommand, 4000, #True, #True)
  If Left(sResponse, 11) = "FUNCTION OK" Or sResponse = "{Timeout}"
    For nPass = 1 To 2
      If vMixPopulateInputInfoArray(#True)
        nInputIndex = vMixGetInputIndexForTypeAndTitle("Colour", "Colour")
        debugMsg2(sProcName, "vMixGetInputIndexForTypeAndTitle(Colour, Colour)", nInputIndex)
        If nInputIndex >= 0
          ; Save the vMix-generated unique key for this input
          grvMixInfo\sBlackColourKey = grvMixInfo\aInputInfo(nInputIndex)\sKey
          Break ; Break nPass
        EndIf ; EndIf nInputIndex >= 0
      EndIf ; EndIf vMixPopulateInputInfoArray()
      ; If we get here then the \aInputInfo() array has not yet been updated, so wait 500ms and try again (once more only)
      If nPass < 2
        Delay(500)
      EndIf
    Next nPass
  EndIf
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf
  
EndProcedure

Procedure vMix_ReplaceBlackWithLogo(pAudPtr, bMutexAlreadyLocked=#False)
  PROCNAMECA(pAudPtr)
  Protected bLockedMutex
  Protected sCommand.s, sResponse.s, nClipNo
  
  If bMutexAlreadyLocked = #False
    scsLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2711)
  EndIf

  With aAud(pAudPtr)
    If \bLogo
      If FileExists(\sFileName)
        If grvMixInfo\sBlackColourKey
          sCommand = "FUNCTION RemoveInput Input=" + grvMixInfo\sBlackColourKey
          sResponse = vMixSendCommand(sProcName, sCommand, -1, #True, #True)
        EndIf
        nClipNo = vMix_AddInput(pAudPtr, #True)
        If nClipNo > 0
          grvMixInfo\sBlackColourKey = \svMixInputKey
        Else
          ; couldn't add the logo image for some reason, so reinstate the black image
          vMixLoadBlackImage(#True)
        EndIf
      EndIf ; EndIf FileExists(\sFileName)
    EndIf ; EndIf \bLogo
  EndWith
  
  If bMutexAlreadyLocked = #False
    scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
  EndIf

EndProcedure

Procedure vMix_DrawPreviewText(nCanvasGadgetNo, pAudPtr)
  PROCNAMECA(pAudPtr)
  Static sPreviewText.s, sPreviewPlaying.s, sPreviewPlaying2.s, sNoOutputScreen.s, bStaticLoaded
  Protected sCurrText.s, sCurrNoOuputScreen.s, nFrontColor, bNoOutputScreen, nOutputScreen, nVidPicTarget
  Protected nLeft, nTop, nWidth
  
  If bStaticLoaded = #False
    sPreviewText = Lang("vMix", "PreviewText") ; "See preview in vMix Control Panel"
    sPreviewPlaying = Lang("vMix", "PreviewPlaying") ; "Preview playing in vMix Control Panel"
    sPreviewPlaying2 = Lang("vMix", "PreviewPlaying2") ; "Preview playing in vMix Control Panel and on Screen $1"
    sNoOutputScreen = Lang("vMix", "NoOutputScreen") ; "Cannot preview on Screen $1 as $2 is currently playing"
    bStaticLoaded = #True
  EndIf
  
  sCurrText = sPreviewText
  nFrontColor = #SCS_Very_Light_Grey
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT
        nFrontColor = #SCS_Green
        sCurrText = sPreviewPlaying
        If gbPreviewOnOutputScreen
          nOutputScreen = aSub(\nSubIndex)\nOutputScreen
          If WQA_checkPreviewOnOutputScreenAvailable(pAudPtr)
            sCurrText = ReplaceString(sPreviewPlaying2, "$1", Str(nOutputScreen))
            sCurrNoOuputScreen = ""
          Else
            nVidPicTarget = getVidPicTargetForOutputScreen(nOutputScreen)
            sCurrNoOuputScreen = ReplaceString(sNoOutputScreen, "$1", Str(nOutputScreen))
            sCurrNoOuputScreen = ReplaceString(sCurrNoOuputScreen, "$2", getAudLabel(grVidPicTarget(nVidPicTarget)\nCurrAudPtr))
            bNoOutputScreen = #True
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  If IsGadget(nCanvasGadgetNo)
    If StartDrawing(CanvasOutput(nCanvasGadgetNo))
      debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasGadgetNo) + "))")
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
      debugMsgD(sProcName, "Box(0,0," + OutputWidth() + "," + OutputHeight() + ",#SCS_Black)")
      nTop = OutputHeight() >> 2
      nLeft = TextWidth("AAA")
      nWidth = OutputWidth() - nLeft - nLeft
      WrapTextInit()
      WrapTextCenter(nLeft, nTop, sCurrText, nWidth, nFrontColor, #SCS_Black)
      debugMsgD(sProcName, "WrapTextCenter(" + nLeft + ", " + nTop + ", " + #DQUOTE$ + sCurrText + #DQUOTE$ + ", " + nWidth + ", nFrontColor, #SCS_Black)")
      If bNoOutputScreen
        nTop + (TextHeight("Ag") * 2.5)
        WrapTextCenter(nLeft, nTop, sCurrNoOuputScreen, nWidth, #SCS_Light_Yellow, #SCS_Black)
        debugMsgD(sProcName, "WrapTextCenter(" + nLeft + ", " + nTop + ", " + #DQUOTE$ + sCurrNoOuputScreen + #DQUOTE$ + ", " + nWidth + ", #SCS_Light_Yellow, #SCS_Black)")
      EndIf        
      StopDrawing()
      debugMsgD(sProcName, "StopDrawing()")
    EndIf
  EndIf
  
EndProcedure

Procedure vMixCheckAnyInputsRunning()
  PROCNAMEC()
  Protected bInputsRunning, nInputIndex
  Protected i, j, nSubState
  
  ; The initial version of this procedure just called vMixPopulateInputInfoArray() and then checked for any input with a "Running" state.
  ; However, if a still image is currently displayed then that input is shown as "Paused", not "Running".
  ; So now we scan the sub-cues themselves
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeA
          nSubState = aSub(j)\nSubState
          If nSubState >= #SCS_CUE_FADING_IN And nSubState <= #SCS_CUE_FADING_OUT And nSubState <> #SCS_CUE_HIBERNATING
            If (aSub(j)\bStartedInEditor = #False) Or (aSub(j)\bStartedInEditor And gbPreviewOnOutputScreen)
              bInputsRunning = #True
              Break 2 ; Break j, i
            EndIf
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  If bInputsRunning = #False
    If vMixPopulateInputInfoArray(#False)
      With grvMixInfo
        For nInputIndex = 0 To \nMaxInputInfo
          If \aInputInfo(nInputIndex)\sState = "Running"
            If \aInputInfo(nInputIndex)\sKey <> grvMixInfo\sBlackColourKey
              bInputsRunning = #True
              Break
            EndIf
          EndIf
        Next nInputIndex
      EndWith
    EndIf
  EndIf
  
  ProcedureReturn bInputsRunning
  
EndProcedure

Procedure vMix_RemoveTargetPInput()
  PROCNAMEC()
  Protected nAudPtr, nInputsRemoved
  
  debugMsg(sProcName, #SCS_START)
  
  With grVidPicTarget(#SCS_VID_PIC_TARGET_P)
    debugMsg(sProcName, "\nCurrAudPtr=" + getAudLabel(\nCurrAudPtr) + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nMovieAudPtr=" + getAudLabel(\nMovieAudPtr) + ", \nMovieNo=" + \nMovieNo)
  EndWith
  
  nAudPtr = grVidPicTarget(#SCS_VID_PIC_TARGET_P)\nCurrAudPtr
  If nAudPtr >= 0
    With aAud(nAudPtr)
      If \svMixInputKey
        debugMsg(sProcName, "calling vMix_RemoveInput(" + getAudLabel(nAudPtr) + ", #True)")
        nInputsRemoved = vMix_RemoveInput(nAudPtr, #True)
        \nFileState = #SCS_FILESTATE_CLOSED
        \nAudState = #SCS_CUE_NOT_LOADED
        debugMsg(sProcName, "calling listCueStates(" + getCueLabel(\nCueIndex) + ")")
        listCueStates(\nCueIndex)
        setCueState(\nCueIndex)
        debugMsg(sProcName, "calling listCueStates(" + getCueLabel(\nCueIndex) + ")")
        listCueStates(\nCueIndex)
        updateGrid(\nCueIndex)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure vMixCalcVolume(fFaderdB.f)
  PROCNAMEC()
  Static Dim fdBLevel.f(100), bStaticLoaded
  Protected n, fReadEntry.f, nVolume
  
  DataSection
    vMixAudio:
    Data.f 0, 0.5, 1, 1.333, 1.667, 2, 2.5, 3, 3.333, 3.667, 4, 4.333, 4.667, 5, 5.5, 6, 6.333, 6.667, 7, 7.5, 8, 8.5, 9, 9.5,
           10, 10.333, 10.667, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 16, 16.5, 17, 17.5, 18, 18.5, 19,
           20, 20.5, 21, 21.5, 22, 23, 23.5, 24, 25, 26, 26.5, 27, 28, 29, 29.5,
           30, 31, 32, 33, 34, 35, 35.5, 36, 37, 39,
           40, 41, 42, 43, 44, 45, 47, 48, 50, 51, 53, 54, 56, 58, 60, 62, 64, 66, 68,
           71, 74, 77, 80, 84, 88, 92, 98, 104, 112, 122, 136, 160, 999
  EndDataSection
  
  If bStaticLoaded = #False
    Restore vMixAudio
    For n = 0 To 100
      Read.f fReadEntry
      fdBLevel(n) = fReadEntry * -1.0
    Next n
    CompilerIf 1=2
      For n = 0 To 100
        debugMsg(sProcName, "fdBLevel(" + n + ")=" + StrF(fdBLevel(n),4))
      Next n
    CompilerEndIf
    bStaticLoaded = #True
  EndIf
  
  If fFaderdB > grLevels\nMinDBLevel ; If fFaderdB <= grLevels\nMinDBLevel then nVolume will remain at 0.
    For n = 0 To 100
      If fFaderdB >= fdBLevel(n)
        nVolume = 100 - n
        Break
      EndIf
    Next n
  EndIf
  ; debugMsg(sProcName, "fFaderdB=" + StrF(fFaderdB,3) + ", nVolume=" + nVolume)
  ProcedureReturn nVolume
  
EndProcedure

Procedure vMixCalcVolume_NEW(fFaderdB.f)
  PROCNAMEC()
  Protected fAmplitude.f, fVolume.f, fVolume2.f, nVolume
  
  ; INFO: Couldn't get any algorithm to work, but leave this code in place as we may need to revisit this later.
  ; See also the Excel spreadsheet vMixAudioFader.xlsx, particularly the graph for Column A which contains the values in the DataSection in Procedure vMixCalcVolume().
  
  CompilerIf 1=2
    ; See "https://www.vmix.com/knowledgebase/article.aspx/144/vmix-api-audio-levels"
    ; Example:
    ;   dB.f = 6.25
    ;   Amplitude.f = dB / 100.0
    ;   Volume.f = Pow(Amplitude, 0.25) * 100.0
    ;   Debug "Volume = " + StrF(Volume,3)
    ; Result: Volume = 50.000
    
    ; fAmplitude = (fFaderdB * -1) / 100.0
    fAmplitude = fFaderdB / 100.0
    debugMsg(sProcName, "fFaderdB=" + StrF(fFaderdB,3) + ", fAmplitude=" + StrF(fAmplitude,3))
    fVolume = Pow(fAmplitude, 0.25) * 100.0
    debugMsg(sProcName, "fVolume=" + StrF(fVolume,3))
    fVolume2 = Pow(fVolume / 100.0, 0.25) * 100.0
    debugMsg(sProcName, "fVolume2=" + StrF(fVolume2,3))
    nVolume = Round(fVolume2, #PB_Round_Nearest)
    If nVolume < 0
      nVolume = 0
    ElseIf nVolume > 100
      nVolume = 100
    EndIf
    
    debugMsg(sProcName, "fFaderdB=" + StrF(fFaderdB,3) + ", nVolume=" + nVolume)
    ProcedureReturn nVolume
  CompilerEndIf
  
EndProcedure

; EOF