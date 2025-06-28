; File: SMSControl.pbi

EnableExplicit

Procedure setSMSDefaults(bSetSMSCheck=#False)
  PROCNAMEC()
  Protected n
  
  debugMsgSMS(sProcName, #SCS_START)
  
  If bSetSMSCheck
    With grSMSCheck
      \sServerName = grDriverSettings\sSMSHost
      \nPortNo = 20000
      \nConnectionTimeOut = 200
      debugMsgSMS(sProcName, "grSMSCheck\sServerName=" + \sServerName + ", \nPortNo=" + \nPortNo)
    EndWith
  Else
    With grSMS
      \sServerName = grDriverSettings\sSMSHost
      \nPortNo = 20000
      \nConnectionTimeOut = 200
      debugMsgSMS(sProcName, "grSMS\sServerName=" + \sServerName + ", \nPortNo=" + \nPortNo)
    EndWith
  EndIf
  
  For n = 0 To ArraySize(gaSMSTCGenerator())
    With gaSMSTCGenerator(n)
      \sTCChannel = Str(1000 + n) ; 8 generators available, so the range will be P1000 - P1007 (omit 'P' in \sTCChannel as it is not required in operations like "set chan px1000.2 gaindb 0")
      \nSubPtr = -1               ; -1 = this generator not currently assigned to a Sub
      debugMsgSMS(sProcName, "gaSMSTCGenerator(" + n + ")\sTCChannel=" + \sTCChannel + ", \nSubPtr=" + \nSubPtr)
    EndWith
  Next n
  
EndProcedure

Procedure.i getUTCDate()
  ; returns the number of seconds since 1 Jan 1970 UTC
  ; nb the PB function Date() returns the number of seconds since 1 Jan 1970 local time, not UTC
  Protected UTCSystemTime.SYSTEMTIME
  Protected UTCFileTime.FILETIME
  Protected qDate.q
  
  GetSystemTime_(UTCSystemTime)
  SystemTimeToFileTime_(UTCSystemTime, UTCFileTime)
  
  qDate = (PeekQ(@UTCFileTime) - 116444736000000000) / 10000000
  ProcedureReturn qDate
EndProcedure

Procedure.l lrotl(pSource.l, pShift)
  ; long rotate left
  Protected nTmp.l, nSource.l, nTarget.l
  Protected nBit0.l
  
  nSource = pSource
  If nSource < 0
    nBit0 = 1 << (pShift-1)
    nSource & $7FFFFFFF
  EndIf
  ; Debug "nBit0=$" + Hex(nBit0,#PB_Long) + ", nSource=$" + Hex(nSource,#PB_Long)
  nTmp = nSource >> (32 - pShift)
  nTmp | nBit0
  ; Debug "nTmp=$" + Hex(nTmp, #PB_Long)
  nTarget = nSource << pShift
  ; Debug "nTarget=" + Hex(nTarget, #PB_Long)
  nTarget | nTmp
  ; Debug "nTarget=" + Hex(nTarget,#PB_Long)
  ProcedureReturn nTarget
EndProcedure

Procedure.s makeSCSKeyForSMS()
  PROCNAMEC()
  Protected sMachineId.s, nMachineId.l, nMachineId3.l
  Protected sSerialNumber.s, nSerialNumber.l, nSerialNumber11.l
  Protected nTime.l, nTime17.l, nNotTime17.l
  Protected nTest.l, qTest.q
  Protected sKey.s
  
  ; info from Loren in email dated 1 Aug 2013, subject "Identifying SCS":
  ; The decoding algorithm uses
  ;
  ;    ULONG test = _lrotl(hid, 3) ^ _lrotl(ser, 11) ^ ~_lrotl(tim, 17);
  ; Each of hid, ser, and tim are 32 bit unsigned numbers. the _lrotl function is a built-in for a 32 bit left rotate instruction. The ^ is an xor operator and ~ is bitwise negation.
  ; 
  ; The key value wants to be an unsigned decimal number, not hex. Leading zeros are immaterial, but it needs to start with a digit.
  
  With grMMedia
    sendSMSCommand("config get machineid", #False)
    If grSMS\sFirstWordLC = "machineid"
      sMachineId = Trim(getSMSResponseField(1, 3))
      nMachineId = Val("$"+sMachineId)
      nMachineId3 = lrotl(nMachineId,3)
      CompilerIf #cTraceSMSKey
        debugMsgSMS(sProcName, "sMachineId=" + sMachineId + ", %" + RSet(Bin(nMachineId,#PB_Long),32,"0"))
      CompilerEndIf
    EndIf
    
    sendSMSCommand("config get serialnumber", #False)
    If grSMS\sFirstWordLC = "serialnumber"
      sSerialNumber = Trim(getSMSResponseField(1, 3))
      nSerialNumber = Val("$"+sSerialNumber)
      nSerialNumber11 = lrotl(nSerialNumber,11)
      CompilerIf #cTraceSMSKey
        debugMsgSMS(sProcName, "sSerialNumber=" + sSerialNumber + ", %" + RSet(Bin(nSerialNumber,#PB_Long),32,"0"))
      CompilerEndIf
    EndIf
    
    ; nTime = Date()  ; returns number of seconds since 01/01/1970
    nTime = getUTCDate()  ; returns number of seconds since 01/01/1970
    nTime17 = lrotl(nTime, 17)
    nNotTime17 = ~nTime17
    CompilerIf #cTraceSMSKey
      debugMsgSMS(sProcName, "nTime=" + nTime + ", %" + RSet(Bin(nTime,#PB_Long),32,"0"))
    CompilerEndIf
    
    CompilerIf #cTraceSMSKey
      debugMsgSMS(sProcName, "nMachineId3    =%" + RSet(Bin(nMachineId3,#PB_Long),32,"0"))
      debugMsgSMS(sProcName, "nSerialNumber11=%" + RSet(Bin(nSerialNumber11,#PB_Long),32,"0"))
      debugMsgSMS(sProcName, "nNotTime17     =%" + RSet(Bin(nNotTime17,#PB_Long),32,"0"))
      debugMsgSMS(sProcName, "(nMachineId3 ! nSerialNumber11)=%" + RSet(Bin(nMachineId3 ! nSerialNumber11,#PB_Long),32,"0"))
    CompilerEndIf
    
    nTest = nMachineId3 ! nSerialNumber11 ! nNotTime17
    CompilerIf #cTraceSMSKey
      debugMsgSMS(sProcName, "nTest=%" + RSet(Bin(nTest,#PB_Long),32,"0") + ", " + nTest)
    CompilerEndIf
    If nTest < 0
      nTest & $7FFFFFFF
      qTest = nTest + $80000000
    Else
      qTest = nTest
    EndIf
    sKey = Str(qTest)
    CompilerIf #cTraceSMSKey
      debugMsgSMS(sProcName, "sKey=" + sKey)
    CompilerEndIf
    
  EndWith
  
  ProcedureReturn sKey
  
EndProcedure

Procedure getSMSInputsOutputsPlaybacks()
  PROCNAMEC()
  
  With grMMedia
    
    sendSMSCommand("config get inputs")
    If grSMS\sFirstWordLC = "inputs"
      \nSMSMaxInputs = Val(getSMSResponseField(1, 3))
    EndIf
    
    sendSMSCommand("config get outputs")
    If grSMS\sFirstWordLC = "outputs"
      \nSMSMaxOutputs = Val(getSMSResponseField(1, 3))
      ; cap max outputs if necessary, according to the SCS License level
      If (\nSMSMaxOutputs > grLicInfo\nMaxAudioOutputs) And (grLicInfo\nMaxAudioOutputs > 0)
        \nSMSMaxOutputs = grLicInfo\nMaxAudioOutputs
      EndIf
    EndIf
    
    sendSMSCommand("config get playbacks")
    If grSMS\sFirstWordLC = "playbacks"
      \nSMSMaxPlaybacks = Val(getSMSResponseField(1, 3))
    EndIf
    
    CompilerIf #cSMS_16_16_64
      debugMsgSMS(sProcName, "#cSMS_16_16_64=#True")
      \nSMSMaxInputs = 16
      \nSMSMaxOutputs = 16
      \nSMSMaxPlaybacks = 64
    CompilerEndIf
    
    CompilerIf #cSMS_8_8_48
      debugMsgSMS(sProcName, "#cSMS_8_8_48=#True")
      \nSMSMaxInputs = 8
      \nSMSMaxOutputs = 8
      \nSMSMaxPlaybacks = 48
    CompilerEndIf
    
    If \nSMSMaxPlaybacks > 0
      ReDim gaPlayback(\nSMSMaxPlaybacks - 1)
      clearPlaybacks()
    EndIf
    
    debugMsgSMS(sProcName, "Inputs=" + \nSMSMaxInputs + ", Outputs=" + \nSMSMaxOutputs + ", Playbacks=" + \nSMSMaxPlaybacks)
    
  EndWith
  
EndProcedure

Procedure initSMS()
  PROCNAMEC()
  Protected fUnitFactor.f
  Protected nSliderVal
  Protected fBVLevel.f, nGain
  Protected n
  Protected nResult
  
  debugMsgSMS(sProcName, #SCS_START)
  
  If gnSMSNetworkMutex = 0
    gnSMSNetworkMutex = CreateMutex()
    debugMsgSMS(sProcName, "gnSMSNetworkMutex=" + gnSMSNetworkMutex)
  EndIf
  
  ReDim gaSMSSyncPoint(20)
  gnMaxSMSSyncPoint = -1
  debugMsgSMS(sProcName, "gnMaxSMSSyncPoint=" + gnMaxSMSSyncPoint)
  
  grASIOGroup\sNameWithQuotes = #DQUOTE$ + "SCS ASIOGROUP" + #DQUOTE$
  
  With grMMedia
    CompilerIf #cDisplaySMSWindow
      sendSMSCommand("config set window visible")    ; makes SM-S UI window visible, which helps if you want to see the SM-S VU meters
    CompilerElse
      sendSMSCommand("config set window minimized")  ; minimize SM-S UI window (also deactivates SM-S UI VU and other processing)
    CompilerEndIf
    
    sendSMSCommand("config get version")
    If grSMS\sFirstWordLC = "version"
      \sSMSVersion = getSMSResponseField(1, 2)
    EndIf
    ; debugMsgSMS(sProcName, "grSMS\sFirstWordLC=" + grSMS\sFirstWordLC + ", \sSMSVersion=" + \sSMSVersion)
    debugMsgSMS(sProcName, "SMS Version=" + \sSMSVersion)
    
    ; delete the SCS asiogroup if it currently exists, which may occur if SCS crashed and therefore didn't clean up on closedown
    ; nb no need to check responses
    sendSMSCommand("config close interface")
    sendSMSCommand("config clear asiogroup " + grASIOGroup\sNameWithQuotes)
    
    SLD_initFaderConstants()
    \sGainTableString = "" ; Added 24Dec2022 11.9.8aa
    fUnitFactor = #SCS_MAXVOLUME_SLD / 127
    For n = 0 To 127
      nSliderVal = Round(fUnitFactor * n, #PB_Round_Nearest)
      fBVLevel = SLD_SliderValueToBVLevel(nSliderVal)
      nGain = fBVLevel * 32767
      If nGain > 32767
        nGain = 32767
      EndIf
      ; debugMsgSMS(sProcName, "n=" + n + ", fBVLevel=" + formatLevel(fBVLevel) + ", nGain=" + nGain + ", " + convertBVLevelToDBString(fBVLevel))
      \sGainTableString + " " + nGain
    Next n
    
  EndWith
  
  CompilerIf #cSMSOnThisMachineOnly
    gsEncFilesPath = gsAppDataPath + "EncFiles\"
  CompilerElse
    gsAudioFilesRootFolder = grDriverSettings\sAudioFilesRootFolder
    debugMsgSMS(sProcName, "gsAudioFilesRootFolder=" + gsAudioFilesRootFolder)
    gsEncFilesPath = gsAudioFilesRootFolder + "SCS EncFiles11\"
  CompilerEndIf
  debugMsgSMS(sProcName, "gsEncFilesPath=" + gsEncFilesPath)
  If FolderExists(gsEncFilesPath) = #False
    nResult = CreateDirectory(gsEncFilesPath)
    debugMsgSMS(sProcName, "CreateDirectory(" + gsEncFilesPath + ") returned " + nResult)
  EndIf
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure writeSMSLog(pProcName.s, sCommandString.s)
  PROCNAMEC()
  
  If gbDoSMSLogging
    gsLogLine = sCommandString
    writeSMSLogProc(pProcName, gsLogLine, grSMS)
  EndIf
  
EndProcedure

Procedure writeSMSLogLine(pProcName.s, sLogLine.s)
  PROCNAMEC()
  Protected sLogTime.s
  
  If gbDoSMSLogging
    debugMsgSMS(pProcName, sLogLine)
  EndIf
  
EndProcedure

Procedure writeSMSCheckLog(pProcName.s, sCommandString.s)
  PROCNAMEC()
  
  If gbDoSMSLogging
    gsLogLine = sCommandString
    writeSMSLogProc(pProcName, gsLogLine, grSMSCheck)
  EndIf
  
EndProcedure

Procedure openSMSConnection()
  PROCNAMEC()
  
  debugMsgSMS(sProcName, #SCS_START)
  
  If ArraySize(gsSMSResponse()) < 100
    ReDim gsSMSResponse(100)     ; must be done before first call to getSMSResponse()
  EndIf
  
  With grSMS
    
    ; if the connection is currently open then close it
    If \nSMSClientConnection
      debugMsgSMS(sProcName, "calling CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      CloseNetworkConnection(\nSMSClientConnection)
      writeSMSLogLine(sProcName, "CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      freeHandle(\nSMSClientConnection)
      \nSMSClientConnection = 0
    EndIf
    
    If gnSMSReceiveBufferSize = 0
      ; allocate memory for the receive buffer (only need to allocate this once)
      *SMSReceiveBuffer = AllocateMemory(#SCS_SMS_RECEIVE_BUFFER_SIZE << 1) ; double the allocated memory size to be 'safe' re unicode
      gnSMSReceiveBufferSize = #SCS_SMS_RECEIVE_BUFFER_SIZE
    EndIf
    
    \sFirstWordLC = ""
    \qSendTime = ElapsedMilliseconds()  ; \qSendTime set for writeSMSLog()
    GetLocalTime_(@\rSendTime)
    debugMsgSMS(sProcName, "calling OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ", #PB_Network_TCP, " + \nConnectionTimeOut + ")")
    \nSMSClientConnection = OpenNetworkConnection(\sServerName, \nPortNo, #PB_Network_TCP, \nConnectionTimeOut)
    debugMsgSMS(sProcName, "OpenNetworkConnection(OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ", #PB_Network_TCP, " + \nConnectionTimeOut + ") returned " + \nSMSClientConnection)
    writeSMSLogLine(sProcName, "OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ", #PB_Network_TCP, " + \nConnectionTimeOut + ") returned " + \nSMSClientConnection)
    
    If \nSMSClientConnection
      newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nSMSClientConnection)
      ; wait for SoundMan-Server Welcome Message
      debugMsgSMS(sProcName, "calling getSMSResponse(#True)")
      getSMSResponse(#True)
      writeSMSLog(sProcName, "OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ")") ; logs connection and response
    EndIf
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure openSMSCheckConnection(sServerName.s, nPortNo, bKeepConnectionOpen=#False)
  PROCNAMEC()
  Protected bResult
  Protected qWaitUntil.q
  Protected nBytesReceived, sInBuff.s
  
  debugMsgSMS(sProcName, #SCS_START + ", sServerName=" + sServerName + ", nPortNo=" + nPortNo + ", bKeepConnectionOpen=" + strB(bKeepConnectionOpen))
  
  ; initialize grSMSCheck from grSMS
  grSMSCheck = grSMS
  With grSMSCheck
    If \nSMSClientConnection
      freeHandle(\nSMSClientConnection)
    EndIf
    \nSMSClientConnection = 0    ; do not close or use the grSMS\nSMSClientConnection
    
    \sServerName = sServerName
    \nPortNo = nPortNo
    
    If Len(Trim(sServerName)) = 0 Or nPortNo = 0
      debugMsgSMS(sProcName, "exiting because sServerName or nPortNo not set, returning " + strB(bResult))
      ProcedureReturn bResult
    EndIf
    
    If gnSMSCheckReceiveBufferSize = 0
      ; allocate memory for the receive buffer (only need to allocate this once)
      *SMSCheckReceiveBuffer = AllocateMemory(#SCS_SMS_RECEIVE_BUFFER_SIZE << 1) ; double the allocated memory size to be 'safe' re unicode
      gnSMSCheckReceiveBufferSize = #SCS_SMS_RECEIVE_BUFFER_SIZE
    EndIf
    
    \qSendTime = ElapsedMilliseconds()  ; \nSendTime set for writeSMSLog()
    GetLocalTime_(@\rSendTime)
    debugMsgSMS(sProcName, "calling OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ")")
    \nSMSClientConnection = OpenNetworkConnection(\sServerName, \nPortNo)
    debugMsgSMS(sProcName, "OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ") returned " + \nSMSClientConnection)
    ; writeSMSLogLine(sProcName, "OpenNetworkConnection(" + \sServerName + ", " + \nPortNo + ") returned " + \nSMSClientConnection + "; openSMSCheckConnection()")
    
    If \nSMSClientConnection
      newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nSMSClientConnection)
      qWaitUntil = \qSendTime + gnSMSReceiveTimeOut
      \qReceiveTime = -1
      While #True
        If NetworkClientEvent(\nSMSClientConnection) = #PB_NetworkEvent_Data
          debugMsgSMS(sProcName, "NetworkClientEvent(" + decodeHandle(\nSMSClientConnection) + ") returned #PB_NetworkEvent_Data")
          nBytesReceived = ReceiveNetworkData(\nSMSClientConnection, *SMSCheckReceiveBuffer, gnSMSCheckReceiveBufferSize)
          debugMsgSMS(sProcName, "nBytesReceived=" + nBytesReceived + ", \nSMSClientConnection=" + decodeHandle(\nSMSClientConnection) +
                              ", *SMSCheckReceiveBuffer=" + *SMSCheckReceiveBuffer + ", gnSMSCheckReceiveBufferSize=" + gnSMSCheckReceiveBufferSize)
          If nBytesReceived >= 2
            sInBuff = PeekS(*SMSCheckReceiveBuffer, nBytesReceived, #PB_Ascii)
            debugMsgSMS(sProcName, "sInBuff=" + sInBuff)
            If Left(sInBuff, 2) = "OK"
              \qReceiveTime = ElapsedMilliseconds()
              GetLocalTime_(@\rReceiveTime)
              bResult = #True
              Break
            EndIf
          EndIf
        EndIf
        If (qWaitUntil - ElapsedMilliseconds()) > 0
          Delay(2)
        EndIf
      Wend
      
    EndIf
    
  EndWith
  
  If bKeepConnectionOpen = #False
    closeSMSCheckConnection()
  EndIf
  
  debugMsgSMS(sProcName, #SCS_END + " returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure closeSMSConnection()
  PROCNAMEC()
  Protected qWaitUntil.q
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With grSMS
    If \nSMSClientConnection
      gnSuspendGetCurrInfo + 1  ; suspends any processing of 'getSMSCurrInfo()' during this procedure
      
      If gbInGetSMSCurrInfo
        qWaitUntil = ElapsedMilliseconds() + 2000
        While (qWaitUntil - ElapsedMilliseconds()) > 0
          Delay(200)
          If gbInGetSMSCurrInfo = #False
            Break
          EndIf
        Wend
      EndIf
      
      ; silence all channels
      sendSMSCommand("set matrix off")
      
      deleteASIOGroup()
      
      Delay(200) ; added 4Oct2017 11.7.0 - possibly not necessary for SM-S 1.0.113.0, but earlier versions could hang if the network connection was closed immediately ater sending a message to SM-S
      
      debugMsgSMS(sProcName, "calling CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      CloseNetworkConnection(\nSMSClientConnection)
      debugMsgSMS(sProcName, "CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      writeSMSLogLine(sProcName, "CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      
      ; do not free memory *SMSReceiveBuffer as there may be a current SM-S request outstanding - leave PB to free this memory on closedown
      
      freeHandle(\nSMSClientConnection)
      \nSMSClientConnection = 0
      \bInterfaceOpen = #False
      gnSuspendGetCurrInfo - 1
    EndIf
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure closeSMSCheckConnection()
  PROCNAMEC()
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With grSMSCheck
    If \nSMSClientConnection
      gnSuspendGetCurrInfo + 1  ; suspends any processing of 'getSMSCurrInfo()' during this procedure
      debugMsgSMS(sProcName, "calling CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      CloseNetworkConnection(\nSMSClientConnection)
      debugMsgSMS(sProcName, "CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + ")")
      ; writeSMSLogLine(sProcName, "CloseNetworkConnection(" + decodeHandle(\nSMSClientConnection) + "); closeSMSCheckConnection()")
      
      ; do not free memory *SMSCheckReceiveBuffer as there may be a current SM-S request outstanding - leave PB to free this memory on closedown
      
      freeHandle(\nSMSClientConnection)
      \nSMSClientConnection = 0
      \bInterfaceOpen = #False
      gnSuspendGetCurrInfo - 1
    EndIf
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure handleSMSInput()
  PROCNAMEC()
  Protected sInBuff.s, sBuffWork.s, sBuffPart.s
  Protected nBytesReceived
  Protected n
  Protected bThisPartReady
  Protected n2, nSCSPtr, nEOMPtr
  Protected bThisPartProcessed
  Static bInArrayListed

  ; debugMsgSMS(sProcName, #SCS_START)
  
  If grSMS\nSMSClientConnection
    If NetworkClientEvent(grSMS\nSMSClientConnection) = #PB_NetworkEvent_Data
      nBytesReceived = ReceiveNetworkData(grSMS\nSMSClientConnection, *SMSReceiveBuffer, gnSMSReceiveBufferSize)
      ; debugMsgSMS(sProcName, "ReceiveNetworkData(" + grSMS\nSMSClientConnection + ", *SMSReceiveBuffer, " + gnSMSReceiveBufferSize + ") returned " + nBytesReceived)
    EndIf
  EndIf
  If nBytesReceived <= 0
    ProcedureReturn #False  ; #False indicates nothing received
  EndIf
  
  sInBuff = PeekS(*SMSReceiveBuffer, nBytesReceived, #PB_Ascii)
  If nBytesReceived = gnSMSReceiveBufferSize
    ; more data is available to be read (see PB Help)
    While nBytesReceived = gnSMSReceiveBufferSize
      nBytesReceived = ReceiveNetworkData(grSMS\nSMSClientConnection, *SMSReceiveBuffer, gnSMSReceiveBufferSize)
      If nBytesReceived <= 0
        Break
      EndIf
      sInBuff + PeekS(*SMSReceiveBuffer, nBytesReceived, #PB_Ascii)
    Wend
  EndIf
  ; debugMsgSMS(sProcName, "sInBuff=" + ReplaceString(sInBuff, #CRLF$, "")) ; + ", Len(sInBuff)=" + Len(sInBuff) + "[" + stringToHexString(sInBuff) + "]")
  
  sBuffWork = RemoveString(sInBuff, Chr(10)) ; removing LF effectively leaves CR as the single-character line separator
  
  While Len(sBuffWork) > 0
    nEOMPtr = InStr(sBuffWork, Chr(13))
    If nEOMPtr > 0
      sBuffPart = Trim(Left(sBuffWork, nEOMPtr))
      If nEOMPtr = Len(sBuffWork)
        sBuffWork = ""
      Else
        sBuffWork = Mid(sBuffWork, nEOMPtr + 1)
      EndIf
      bThisPartReady = #True
    Else
      sBuffPart = Trim(sBuffWork)
      sBuffWork = ""
      bThisPartReady = #True
    EndIf
    ; sBuffPart = Trim(sBuffPart, #CR$) ; Added but then deleted 17Aug2023. Deleted because this was causing SCS to hang on connecting to SM-S.
    
    ; debugMsgSMS(sProcName, "sBuffPart=$" + stringToHexString(sBuffPart))
    ; debugMsgSMS(sProcName, "sBuffPart=" + sBuffPart)
    
    bThisPartProcessed = #False
    If Left(sBuffPart, 11) = "TrackStatus"
      grSMS\sPStatusResponse = StringField(sBuffPart, 1, ";")
;       If Right(sBuffPart, 1) = ";"
;         grSMS\sPStatusResponse = Left(sBuffPart, Len(sBuffPart) - 1)
;       Else
;         grSMS\sPStatusResponse = sBuffPart
;       EndIf
      grSMS\qPStatusResponseReceived = ElapsedMilliseconds()
      bThisPartProcessed = #True
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "(TrackStatus) grSMS\sPStatusResponse=" + stringToNetworkString(grSMS\sPStatusResponse))
      CompilerEndIf
      
    ElseIf Left(sBuffPart, 9) = "TrackTime"
      grSMS\sPTimeResponse = StringField(sBuffPart, 1, ";")
;       If Right(sBuffPart, 1) = ";"
;         grSMS\sPTimeResponse = Left(sBuffPart, Len(sBuffPart) - 1)
;         ; debugMsg(sProcName, "grSMS\sPTimeResponse=" + grSMS\sPTimeResponse)
;       Else
;         grSMS\sPTimeResponse = sBuffPart
;         ; debugMsg(sProcName, "grSMS\sPTimeResponse=" + grSMS\sPTimeResponse)
;       EndIf
      grSMS\qPTimeResponseReceived = ElapsedMilliseconds()
      calcRelFilePostions(sBuffPart)
      bThisPartProcessed = #True
      CompilerIf #cTraceSMSCurrInfo Or #cTraceSMSTrackTime
        debugMsgSMS(sProcName, "(TrackTime) grSMS\sPTimeResponse=" + stringToNetworkString(grSMS\sPTimeResponse))
      CompilerEndIf
      
    ElseIf Left(sBuffPart, 6) = "GaindB"
      grSMS\sPXGainResponse = StringField(sBuffPart, 1, ";")
;       If Right(sBuffPart, 1) = ";"
;         grSMS\sPXGainResponse = Left(sBuffPart, Len(sBuffPart) - 1)
;       Else
;         grSMS\sPXGainResponse = sBuffPart
;       EndIf
      ;grSMS\nPXGainResponseReceived = ElapsedMilliseconds()
      bThisPartProcessed = #True
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "(GaindB) grSMS\sPXGainResponse=" + stringToNetworkString(grSMS\sPXGainResponse))
      CompilerEndIf
      
    ElseIf Left(sBuffPart, 4) = "Gain"
      grSMS\sPXGainResponse = StringField(sBuffPart, 1, ";")
;       If Right(sBuffPart, 1) = ";"
;         grSMS\sPXGainResponse = Left(sBuffPart, Len(sBuffPart) - 1)
;       Else
;         grSMS\sPXGainResponse = sBuffPart
;       EndIf
      ;grSMS\nPXGainResponseReceived = ElapsedMilliseconds()
      bThisPartProcessed = #True
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "(Gain) grSMS\sPXGainResponse=" + stringToNetworkString(grSMS\sPXGainResponse))
      CompilerEndIf
      
    ElseIf Left(sBuffPart, 2) = "VU"
      grSMS\sOVUResponse = StringField(sBuffPart, 1, ";")
;       If Right(sBuffPart, 1) = ";"
;         grSMS\sOVUResponse = Left(sBuffPart, Len(sBuffPart) - 1)
;       Else
;         grSMS\sOVUResponse = sBuffPart
;       EndIf
      ; debugMsgSMS(sProcName, "grSMS\sOVUResponse=" + grSMS\sOVUResponse)
      ; debugMsgSMS(sProcName, "grSMS\sOVUResponse=" + grSMS\sOVUResponse)
      If gbClosingDown = #False
        gbRefreshVUDisplay = #True
      EndIf
      bThisPartProcessed = #True
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "(VU) grSMS\sOVUResponse=" + stringToNetworkString(grSMS\sOVUResponse))
      CompilerEndIf
      
    ElseIf Left(sBuffPart, 11) = "TcGenerator"
      grSMS\sTcGenResponse = StringField(sBuffPart, 1, ";")
;       If Right(sBuffPart, 1) = ";"
;         grSMS\sTcGenResponse = Left(sBuffPart, Len(sBuffPart) - 1)
;       Else
;         grSMS\sTcGenResponse = sBuffPart
;       EndIf
      ; debugMsgSMS(sProcName, "grSMS\sTcGenResponse=" + grSMS\sTcGenResponse)
      ; debugMsgSMS(sProcName, "grSMS\sTcGenResponse=" + grSMS\sTcGenResponse)
      If gbClosingDown = #False
        gbRefreshVUDisplay = #True
      EndIf
      bThisPartProcessed = #True
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "(TcGenerator) grSMS\sTcGenResponse=" + stringToNetworkString(grSMS\sTcGenResponse))
      CompilerEndIf
      
    EndIf
    
    If bThisPartProcessed = #False
      If (Not gbReadingSMSMessage) Or (gnSMSInCount = 0)
        gbReadingSMSMessage = #True
        gbSMSInLocked = #True
        n2 = gnSMSInCount
        gnSMSCurrentIndex = n2
        ; debugMsgSMS(sProcName, "gnSMSCurrentIndex=" + gnSMSCurrentIndex + ", ArraySize(gaSMSIns())=" + ArraySize(gaSMSIns()) + ", sBuffPart=" + #DQUOTE$ + sBuffPart + #DQUOTE$)
        If gnSMSCurrentIndex > ArraySize(gaSMSIns())
          If bInArrayListed = #False
            debugMsgSMS(sProcName, "ElapsedMilliseconds()=" + Str(ElapsedMilliseconds()))
            For n = 0 To ArraySize(gaSMSIns())
              With gaSMSIns(n)
                debugMsgSMS(sProcName, "gaSMSIns(" + n + ")\qTimeIn=" + \qTimeIn + ", \bDone=" + \bDone + ", \bReady=" + \bReady + ", \bRAI=" + \bRAI + ", \sMessage=" + #DQUOTE$ + \sMessage + #DQUOTE$)
              EndWith
            Next n
            bInArrayListed = #True
          EndIf
          ReDim gaSMSIns(gnSMSCurrentIndex + 20)
        EndIf
        CheckSubInRange(gnSMSCurrentIndex, ArraySize(gaSMSIns()), "gaSMSIns()")
        With gaSMSIns(gnSMSCurrentIndex)
          \sMessage = LTrim(sBuffPart)
          \bReady = bThisPartReady
          \bDone = #False
          \qTimeIn = ElapsedMilliseconds()
          ; debugMsgSMS(sProcName, "gnSMSCurrentIndex=" + gnSMSCurrentIndex + ", \sMessage=" + \sMessage)
        EndWith
        gnSMSInCount = n2 + 1
        gbSMSInLocked = #False
        ; debugMsgSMS(sProcName, "gnSMSInCount=" + gnSMSInCount)
      Else
        With gaSMSIns(gnSMSCurrentIndex)
          \sMessage + sBuffPart
          \bReady = bThisPartReady
          ; debugMsgSMS(sProcName, "gnSMSCurrentIndex=" + gnSMSCurrentIndex + ", \sMessage=" + \sMessage)
        EndWith
      EndIf
      
      If bThisPartReady
        gbReadingSMSMessage = #False
      Else
        gbReadingSMSMessage = #True
      EndIf
      
    EndIf
    
  Wend
  
  ; debugMsgSMS(sProcName, #SCS_END + ", gbReadingSMSMessage=" + strB(gbReadingSMSMessage) + ", gnSMSInCount=" + gnSMSInCount)
  ProcedureReturn #True
  
EndProcedure

Procedure getSMSResponse(bConnectionResponse=#False, sAssociatedCommandString.s="")
  PROCNAMEC()
  ; bConnectionResponse should be set #True when getSMSResponse() is called to get the pseudo-response from a connection request.
  ; This is because the SM-S Welcome message can break the single-line / multi-line convention in that the response may be a
  ; multi-line message that starts with OK. The documentation says that a line that starts with OK is a single-line response.
  Protected qWaitUntil.q
  Protected nLengthInBytes
  Protected sResponse.s
  Protected n, nPtr, nLineLength, nPartLineCount
  Protected bSingleLineResponse, bEndOfResponseFound
  Protected nInPtr, nFirstLine
  Protected bExitWhile
  Protected bAllDone
  Protected nLoopCount
  Protected nHoldSMSInCount
  
  ; debugMsgSMS(sProcName, #SCS_START)
  
  If THR_getThreadState(#SCS_THREAD_NETWORK) <> #SCS_THREAD_STATE_ACTIVE
    debugMsgSMS(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_NETWORK)")
    THR_createOrResumeAThread(#SCS_THREAD_NETWORK)
  EndIf
  
  nFirstLine = -1
  With grSMS
    ; wait for a response up until the timeout period
    qWaitUntil = \qSendTime + gnSMSReceiveTimeOut
    ; debugMsgSMS(sProcName, "\nSendTime=" + traceTime(\nSendTime) + ", qWaitUntil=" + traceTime(qWaitUntil))
    bExitWhile = #False
    nLoopCount = 0
    ; debugMsgSMS(sProcName, "gnSMSInCount=" + gnSMSInCount)
    While bExitWhile = #False
      If (gnSMSInCount > 0) And (gbSMSInLocked = #False)
        gbSMSInLocked = #True
        If gnSMSInCount > ArraySize(gsSMSResponse())
          ReDim gsSMSResponse(gnSMSInCount)
        EndIf
        nHoldSMSInCount = gnSMSInCount
        For nInPtr = 0 To nHoldSMSInCount - 1
          If gaSMSIns(nInPtr)\bDone = #False
            If gaSMSIns(nInPtr)\bReady
              If nFirstLine = -1
                nFirstLine = nInPtr
              EndIf
              sResponse = gaSMSIns(nInPtr)\sMessage
              nLengthInBytes = Len(sResponse)
              If gbDoSMSLogging
                \qReceiveTime = ElapsedMilliseconds()
                GetLocalTime_(@\rReceiveTime)
              EndIf
              If nLengthInBytes >= 0
                If nPtr = nFirstLine
                  ; first data for this of getSMSResponse()
                  If Left(sResponse, 2) = "OK" And bConnectionResponse = #False
                    bSingleLineResponse = #True
                  ElseIf Left(sResponse, 5) = "ERROR"
                    bSingleLineResponse = #True
                  ElseIf Len(sResponse) >= 2
                    ; debugMsgSMS(sProcName, "stringToHexString(Right(sResponse, 2))=" + stringToHexString(right(sResponse, 2)))
                    If Right(sResponse, 2) = (";" + Chr(13))
                      bSingleLineResponse = #True
                    EndIf
                  EndIf
                  If bSingleLineResponse
                    bEndOfResponseFound = #True
                  EndIf
                  ; debugMsgSMS(sProcName, "nPtr=" + nPtr + ", bSingleLineResponse=" + bSingleLineResponse + ", bEndOfResponseFound=" + bEndOfResponseFound)
                Else
                  ; second or subsequent data for this of getSMSResponse(), therefore part of a multiline response
                EndIf
                nPartLineCount = CountString(sResponse, Chr(13))
                ; debugMsgSMS(sProcName, "nPartLineCount=" + nPartLineCount)
                For n = 1 To nPartLineCount
                  If nPtr > ArraySize(gsSMSResponse())
                    ReDim gsSMSResponse(nPtr + 20)
                  EndIf
                  gsSMSResponse(nPtr) = StringField(sResponse + Chr(13), n, Chr(13))
                  ; debugMsgSMS(sProcName, "gsSMSResponse(" + nPtr + ")=" + gsSMSResponse(nPtr))
                  If (nPtr > 0) And (gsSMSResponse(nPtr) = ".")
                    bEndOfResponseFound = #True
                  EndIf
                  ; debugMsgSMS(sProcName, "nPtr=" + nPtr + ", bEndOfResponseFound=" + strB(bEndOfResponseFound))
                  nPtr + 1
                Next n
                If bEndOfResponseFound
                  gaSMSIns(nInPtr)\bDone = #True
                  ; debugMsgSMS(sProcName, "gaSMSIns(" + nInPtr + ")\bDone=#True")
                  bExitWhile = #True
                  Break
                EndIf
              EndIf
              gaSMSIns(nInPtr)\bDone = #True
              ; debugMsgSMS(sProcName, "gaSMSIns(" + nInPtr + ")\bDone=#True")
            EndIf
          EndIf
        Next nInPtr
        ; debugMsgSMS(sProcName, "gnSMSInCount=" + gnSMSInCount)
        If gnSMSInCount > 0
          bAllDone = #True
          For nInPtr = 0 To gnSMSInCount - 1
            If gaSMSIns(nInPtr)\bDone = #False
              ; debugMsgSMS(sProcName, "gaSMSIns(" + nInPtr + ")\bDone=#False")
              bAllDone = #False
              Break
            EndIf
          Next nInPtr
        EndIf
        If bAllDone
          gnSMSInCount = 0
        EndIf
        gbSMSInLocked = #False
      EndIf
      
      If bExitWhile = #False
        ; Added 19Jan2023 11.9.8ag
        If gbClosingDown
          sResponse = "SCS closing down"
          \qReceiveTime = -1
          bExitWhile = #True
          Break
        EndIf
        ; End added 19Jan2023 11.9.8ag
        If (qWaitUntil - ElapsedMilliseconds()) > 0
          nLoopCount + 1
          Delay(2)
        Else
          debugMsgSMS(sProcName, "TIMED OUT" + ", gnSMSInCount=" + gnSMSInCount + ", nInPtr=" + nInPtr + ", sResponse=" + stringToNetworkString(sResponse) + ", sAssociatedCommandString=" + stringToNetworkString(sAssociatedCommandString))
          sResponse = "SCS_FAIL 9101 - Timeout waiting for network data;"
          \qReceiveTime = -1
          bExitWhile = #True
          Break
        EndIf
      EndIf
      
    Wend
    
    \nResponseLineCount = nPtr
    ; debugMsgSMS(sProcName, "\nResponseLineCount=" + \nResponseLineCount + ", nFirstLine=" + nFirstLine)
    ; unpack first word in lower case
    If nFirstLine >= 0
      \sFirstWordLC = LCase(Left(gsSMSResponse(nFirstLine) + " ", FindString(gsSMSResponse(nFirstLine) + " ", " ", 1) - 1))
      ; debugMsgSMS(sProcName, "\sFirstWordLC=" + \sFirstWordLC) ; + ", FindString(sResponse, ; ;, 1)=" + FindString(sResponse, " ", 1))
      ; debugMsgSMS(sProcName, "nLoopCount=" + nLoopCount + ", gsSMSResponse(" + nFirstLine + ")=" + gsSMSResponse(nFirstLine))
      If Len(sResponse) = 0
        sResponse = gsSMSResponse(nFirstLine)
      EndIf
    Else
      \sFirstWordLC = ""
    EndIf
    \sFirstLine = sResponse
  EndWith
  
  ; debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure sendSMSCommandProc(sCommandString.s, bLogCommand=#True, pProcName.s="", nLabel=0)
  PROCNAMEC()
  Protected sSMSCommandString.s
  Protected sResponse.s
  Protected bDoLog
  
  If Len(sCommandString) = 0
    ProcedureReturn
  EndIf
  
  ; Added 19Jan2023 11.9.8ag
  If gbClosingDown
    If sCommandString = "set matrix off" Or sCommandString = "config close interface" Or FindString(sCommandString, "config clear asiogroup")
      ; OK to process
    Else
      debugMsgSMS(sProcName, "Exiting because SCS closing down. sCommandString=" + #DQUOTE$ + sCommandString + #DQUOTE$)
      ProcedureReturn
    EndIf
  EndIf
  ; End added 19Jan2023 11.9.8ag
  
  sSMSCommandString = sCommandString
  If (bLogCommand) And (pProcName)
    sSMSCommandString + "; " + pProcName
    If nLabel > 0
      sSMSCommandString + "[" + nLabel + "]"
    EndIf
  EndIf
  
  With grSMS
    SendNetworkStringAscii(\nSMSClientConnection, sSMSCommandString + #CR$) ; SM-S requires carriage return at the end of each command line 
    \qSendTime = ElapsedMilliseconds()
    GetLocalTime_(@\rSendTime)
    ; now wait for a response
    getSMSResponse(#False, sSMSCommandString)
  EndWith
  
  ; Changed the following 30Apr2023 11.10.0ax to skip logging "set ... gain/gaindb/gainmidi ..." commands unless #cTraceSetLevels=#True, or bLogCommand=#True
;   If (bLogCommand) Or Left(sSMSCommandString,3) = "set"
;     writeSMSLog(pProcName, sSMSCommandString) ; logs the command and the response
;   EndIf
  bDoLog = bLogCommand
  If bDoLog = #False
    If Left(sSMSCommandString,3) = "set"
      CompilerIf #cTraceSetLevels
        ; trace 'set gain' etc commands
        bDoLog = #True
      CompilerElse
        If FindString(sSMSCommandString, "gain") = 0
          ; NOT a 'set gain' etc command
          bDoLog = #True
        EndIf
      CompilerEndIf
    EndIf
  EndIf
  If bDoLog
    writeSMSLog(pProcName, sSMSCommandString) ; logs the command and the response
  EndIf
  
  ; debugMsgSMS(sProcName, #SCS_END)
  
  ProcedureReturn
EndProcedure

Procedure clearPlaybacks()
  PROCNAMEC()
  Protected n, nAudPtr
  
  With grMMedia
    debugMsgSMS(sProcName, "\nSMSMaxPlaybacks=" + \nSMSMaxPlaybacks)
    For n = 0 To ArraySize(gaPlayback())
      If gaPlayback(n)\nAssignedTo > #SCS_PLB_UNASSIGNED
        sendSMSCommand("stop p" + n)
      EndIf
      gaPlayback(n)\nAssignedTo = #SCS_PLB_UNASSIGNED
      ;debugMsgSMS(sProcName, "gaPlayback(" + n + ")\nAssignedTo=#SCS_PLB_UNASSIGNED")
      nAudPtr = gaPlayback(n)\nAudPtr
      If nAudPtr > 0
        aAud(nAudPtr)\nSMSPChanCount = 0
      EndIf
      gaPlayback(n)\nAudPtr = -1
      gaPlayback(n)\nPrimaryChan = -1
    Next n
  EndWith
  
EndProcedure

Procedure.s getSMSResponseField(nLineNo, nFieldNo) ; nLineNo and nFieldNo are both base 1
  PROCNAMEC()
  Protected sLine.s, sField.s, sChar.s, sTerminator.s
  Protected n, nFieldCounter, nTerminatorPtr
  
  sLine = Trim(gsSMSResponse(nLineNo - 1))
  ;  debugMsgSMS(sProcName, "gsSMSResponse(" + (nLineNo - 1) + ") returned " + sLine)
  If Len(sLine) < 1
    ProcedureReturn ""
  EndIf
  
  If Right(sLine, 1) = ";"
    sLine = Left(sLine, Len(sLine) - 1)
  EndIf
  sLine + " "
  ;debugMsgSMS(sProcName, "sLine=" + sLine + ", nFieldNo=" + nFieldNo)
  
  n = 1
  nFieldCounter = 0
  While (nFieldCounter < nFieldNo) And (n < Len(sLine))
    While (Mid(sLine, n, 1) = " ") And (n < Len(sLine))
      ; ignore spaces before a field
      n + 1
    Wend
    If Mid(sLine, n, 1) = #DQUOTE$
      ; field is in quotes, eg an interface name
      sTerminator = #DQUOTE$
      n + 1 ; skip over the starting quotes character
    Else
      ; field is not in quotes, so will be terminated by the next space
      sTerminator = " "
    EndIf
    nTerminatorPtr = FindString(sLine, sTerminator, n)
    sField = Mid(sLine, n, (nTerminatorPtr - n))
    ;debugMsgSMS(sProcName, "nFieldCounter=" + Str(nFieldCounter) + ", n=" + n + ", nTerminatorPtr=" + Str(nTerminatorPtr) + ", sField=" + sField)
    n = nTerminatorPtr + 1
    nFieldCounter = nFieldCounter + 1
  Wend
  If nFieldCounter < nFieldNo
    ; asked for a field that doesn;t exist
    sField = ""
  EndIf
  ;debugMsgSMS(sProcName, #SCS_END + ", returning " + sField)
  ProcedureReturn sField
EndProcedure

Procedure getSMSDongleState()
  PROCNAMEC()
  Protected sField.s
  
  With grMMedia
    sendSMSCommand("config get dongle")
    If grSMS\sFirstWordLC = "dongle"
      sField = getSMSResponseField(1, 3)
      If sField = "1"
        \bDongleDetected = #True
      Else
        \bDongleDetected = #False
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure convertAudioFileToWAV(sInputFile.s, sOutputFile.s)
  ; returns #True if converted OK, #False if not converted (eg format not supported by BASS, such as MIDI)
  PROCNAMEC()
  
  ; sample code from BASS Forum:
  ; HSTREAM decoder=BASS_StreamCreateFile(FALSE, "input.mp3", 0, 0, BASS_STREAM_DECODE); // create a decoding channel from the source file
  ; BASS_Encode_Start(decoder, "output.wav", BASS_ENCODE_PCM|BASS_ENCODE_AUTOFREE, NULL, 0); // set a WAV writer on it
  ;
  ; While (BASS_ChannelIsActive(decoder)) { // Not reached the End yet...
  ;   BYTE buf[20000];
  ;   BASS_ChannelGetData(decoder, buf, SizeOf(buf)); // process some data (decode and write)
  ; }
  ;
  ; BASS_StreamFree(decoder); // free the decoder (and encoder due to AUTOFREE)
  
  Protected nDecoder.l, nEncoder.l, nFlags.l    ; longs
  Protected sCmdLine.s
  Protected qTime.q
  Protected nBassError.l
  Protected *buffer
  
  debugMsgSMS(sProcName, "converting " + GetFilePart(sInputFile) + " to " + GetFilePart(sOutputFile))
  qTime = ElapsedMilliseconds()
  
  sCmdLine = sOutputFile
  gsFile = sInputFile
  nFlags = #BASS_STREAM_DECODE | #SCS_BASS_UNICODE
  nDecoder = BASS_StreamCreateFile(#BASSFALSE, @gsFile, 0, 0, nFlags)
  debugMsgSMS(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(gsFile) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ") returned " + nDecoder)
  newHandle(#SCS_HANDLE_SOURCE, nDecoder)
  If nDecoder = 0
    nBassError = BASS_ErrorGetCode()
    If nBassError = #BASS_ERROR_FILEFORM
      debugMsgSMS(sProcName, "unsupported file format")
      ProcedureReturn #False
    Else
      Error_(sProcName, "BASS_StreamCreateFile failed")
      ProcedureReturn #False
    EndIf
  EndIf
  
  nFlags = #BASS_ENCODE_PCM | #BASS_ENCODE_FP_16BIT | #BASS_ENCODE_AUTOFREE | #SCS_BASS_UNICODE
  nEncoder = BASS_Encode_Start(nDecoder, @sCmdLine, nFlags, 0, 0)
  debugMsgSMS(sProcName, "BASS_Encode_Start(" + nDecoder + ", " + sCmdLine + ", " + decodeStreamCreateFlags(nFlags) + ", 0, 0) returned " + nEncoder)
  If nEncoder = 0
    Error_(sProcName, "BASS_Encode_Start failed, output file: " + GetFilePart(sOutputFile)) ; Added file name 16Jan2025 11.10.6-b04
    ProcedureReturn #False
  EndIf
  
  *buffer = AllocateMemory(20000)
  While (BASS_ChannelIsActive(nDecoder))  ; not reached the end yet...
    FillMemory(*buffer, 20000)
    BASS_ChannelGetData(nDecoder, *buffer, 20000)   ; process some data (decode and write)
  Wend
  FreeMemory(*buffer)
  
  BASS_StreamFree(nDecoder) ; free the decoder (and encoder due to AUTOFREE)
  freeHandle(nDecoder)
  
  debugMsgSMS(sProcName, "conversion completed in " + StrF((ElapsedMilliseconds() - qTime) / 1000.0, 3) + " seconds")
  
  If FileExists(sCmdLine)
    debugMsgSMS(sProcName, "File exists: " + sCmdLine)
  Else
    debugMsgSMS(sProcName, "File DOES NOT EXIST: " + sCmdLine)
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure unassignPlaybackChannel(nChannel)
  PROCNAMEC()
  ; Added 22Nov2021 11.8.6cd following emails from Chris Bryan where a new file was assigned to a playback channel that was still fading out another file
  ; See also 22Nov2021 changes in freeFilePlaybacks() below
  Protected n
  
  For n = 0 To ArraySize(gaPlayback())
    With gaPlayback(n)
      If \nPrimaryChan = nChannel
        \nAssignedTo = #SCS_PLB_UNASSIGNED
        debugMsgSMS(sProcName, "gaPlayback(" + n + ")\nAssignedTo=#SCS_PLB_UNASSIGNED")
        If \nAudPtr > 0
          aAud(\nAudPtr)\nSMSPChanCount = 0
        EndIf
        \nAudPtr = -1
        \nPrimaryChan = -1
        clearPChanResponses(n)
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure freeFilePlaybacks(nPrimaryChan)
  PROCNAMEC()
  Protected n
  Protected sPrimaryChan.s, sChanList.s
  Protected nAudPtr
  
  debugMsgSMS(sProcName, #SCS_START + ", nPrimaryChan=p" + nPrimaryChan)
  
  If nPrimaryChan = -1
    ProcedureReturn
  EndIf
  
  If gaPlayback(nPrimaryChan)\nAssignedTo <> #SCS_PLB_UNASSIGNED
    sPrimaryChan = "p" + nPrimaryChan
    sChanList = sPrimaryChan
    For n = 0 To ArraySize(gaPlayback())
      If n <> nPrimaryChan
        With gaPlayback(n)
          If \nPrimaryChan = nPrimaryChan
            If \nAssignedTo <> #SCS_PLB_UNASSIGNED
              sChanList + " p" + n
            EndIf
          EndIf
        EndWith
      EndIf
    Next n
    
    If getSMSTrackStatus(sPrimaryChan) = "play"
      sendSMSCommand("stop " + sChanList)
    EndIf
    
    ; Deleted 22Nov2021 11.8.6cd
;     For n = 0 To ArraySize(gaPlayback())
;       With gaPlayback(n)
;         If \nPrimaryChan = nPrimaryChan
;           \nAssignedTo = #SCS_PLB_UNASSIGNED
;           ; debugMsgSMS(sProcName, "gaPlayback(" + n + ")\nAssignedTo=#SCS_PLB_UNASSIGNED")
;           nAudPtr = \nAudPtr
;           If nAudPtr > 0
;             aAud(nAudPtr)\nSMSPChanCount = 0
;           EndIf
;           \nAudPtr = -1
;           \nPrimaryChan = -1
;           clearPChanResponses(n)
;         EndIf
;       EndWith
;     Next n
    ; End deleted 22Nov2021 11.8.6cd
    samAddRequest(#SCS_SAM_UNASSIGN_SMS_PLAYBACK_CHANNEL, nPrimaryChan, 0, 0, "", ElapsedMilliseconds()+5000) ; Added 22Nov2021 11.8.6cd
    
  EndIf
  
EndProcedure

Procedure freePreviewPlaybacks()
  PROCNAMEC()
  Protected n, nPrimaryChan
  
  nPrimaryChan = -1
  For n = 0 To ArraySize(gaPlayback())
    If gaPlayback(n)\nAssignedTo = #SCS_PLB_PREVIEW
      nPrimaryChan = gaPlayback(n)\nPrimaryChan
      Break
    EndIf
  Next n
  
  debugMsgSMS(sProcName, "nPrimaryChan=" + nPrimaryChan)
  
  If nPrimaryChan <> -1
    debugMsgSMS(sProcName, "calling freeFilePlaybacks(" + nPrimaryChan + ")")
    freeFilePlaybacks(nPrimaryChan)
    With grPreview
      \sPPrimaryChan = ""
      \sPChanList = ""
      \sPXChanList = ""
      gbPreviewPlaying = #False
    EndWith
  EndIf
  
EndProcedure

Procedure setTrackTimesCommandStrings(pAudPtr, bIncludeStartTime, nLoopInfoIndex)
  PROCNAMECA(pAudPtr)
  Protected nMainCount
  Protected nReqdStartTime, nAltReqdStartTime, nReqdStopTime, nReqdRepeatTime
  Protected nReqdStartSamplePos, nAltReqdStartSamplePos, nReqdStopSamplePos, nReqdRepeatSamplePos
  Protected sTrackTimesCommandString.s, sAltTrackTimesCommandString.s
  Protected sTrackRepeatOffCommandString.s
  Protected bUsingXFade
  
  debugMsgSMS(sProcName, #SCS_START + ", bIncludeStartTime=" + strB(bIncludeStartTime) + ", nLoopInfoIndex=" + nLoopInfoIndex)
  
  With aAud(pAudPtr)
    nMainCount = 1
    nReqdStartTime = \nAbsStartAt
    nReqdRepeatTime = -2
    nAltReqdStartTime = -2
    nReqdStartSamplePos = \qStartAtSamplePos
    nReqdRepeatSamplePos = -2
    nAltReqdStartSamplePos = -2
    If \nMaxLoopInfo >= 0
      If usingLoopXFade(pAudPtr) = #False
        nReqdRepeatTime = \aLoopInfo(nLoopInfoIndex)\nAbsLoopStart
        nReqdStopTime = \aLoopInfo(nLoopInfoIndex)\nAbsLoopEnd
        nReqdRepeatSamplePos = \aLoopInfo(nLoopInfoIndex)\qLoopStartSamplePos
        nReqdStopSamplePos = \aLoopInfo(nLoopInfoIndex)\qLoopEndSamplePos
      Else
        bUsingXFade = #True
        nMainCount = 2 ; because we need to open the file twice, once for the main playback and once for the alt playback
        ; nReqdStopTime = \nAbsLoopEnd
        ; do not set stop time for cross-faded loops as (a) it's not necessary, and (b) a bug in SM-S stalls output at loop-end on releasing the loop
        nReqdStopTime = -2
        nAltReqdStartTime = \aLoopInfo(nLoopInfoIndex)\nAbsLoopStart
        nReqdStopSamplePos = -2
        nAltReqdStartSamplePos = \aLoopInfo(nLoopInfoIndex)\qLoopStartSamplePos
      EndIf
    Else
      nReqdStopTime = \nAbsEndAt
      nReqdStopSamplePos = \qEndAtSamplePos
    EndIf
    If nReqdStopTime = \nFileDuration
      nReqdStopTime = -2
      nReqdStopSamplePos = -2
    EndIf
    
    If bIncludeStartTime
      If nReqdStartSamplePos > 0
        sTrackTimesCommandString + " start samples " + nReqdStartSamplePos
      ElseIf nReqdStartTime > 0
        sTrackTimesCommandString + " start time " + makeSMSTimeString(nReqdStartTime)
      EndIf
      If nAltReqdStartSamplePos > 0
        sAltTrackTimesCommandString + " start samples " + nAltReqdStartSamplePos
      ElseIf nAltReqdStartTime > 0
        sAltTrackTimesCommandString + " start time " + makeSMSTimeString(nAltReqdStartTime)
      EndIf
    EndIf
    
    If nReqdRepeatSamplePos >= 0  ; nb may be 0
      sTrackRepeatOffCommandString = " repeat off"
      sTrackTimesCommandString + " repeat samples " + nReqdRepeatSamplePos
      ; repeat time not used for xfade loops, so no need to include in sAltTrackTimesCommandString
    ElseIf nReqdRepeatTime >= 0  ; nb may be 0
      sTrackRepeatOffCommandString = " repeat off"
      sTrackTimesCommandString + " repeat time " + makeSMSTimeString(nReqdRepeatTime)
      ; repeat time not used for xfade loops, so no need to include in sAltTrackTimesCommandString
    EndIf
    
    If nReqdStopSamplePos >= 0
      sTrackTimesCommandString + " stop samples " + nReqdStopSamplePos
      sAltTrackTimesCommandString + " stop samples " + nReqdStopSamplePos
    ElseIf nReqdStopTime >= 0
      sTrackTimesCommandString + " stop time " + makeSMSTimeString(nReqdStopTime)
      sAltTrackTimesCommandString + " stop time " + makeSMSTimeString(nReqdStopTime)
    EndIf
  EndWith
  
  With grSMS
    \nMainCount = nMainCount
    \sTrackRepeatOffCommandString = sTrackRepeatOffCommandString
    \sTrackTimesCommandString = sTrackTimesCommandString
    \sAltTrackTimesCommandString = sAltTrackTimesCommandString
    debugMsgSMS(sProcName, #SCS_END + ", bUsingXFade=" + strB(bUsingXFade) + ", grSMS\nMainCount=" + \nMainCount +
                        ", \sTrackRepeatOffCommandString=" + #DQUOTE$ + \sTrackRepeatOffCommandString + #DQUOTE$ +
                        ", \sTrackTimesCommandString=" + #DQUOTE$ + \sTrackTimesCommandString + #DQUOTE$ +
                        ", \sAltTrackTimesCommandString=" + #DQUOTE$ + \sAltTrackTimesCommandString + #DQUOTE$)
  EndWith
  
EndProcedure

Procedure assignFileTracksToPlaybacks(pAudPtr, sFileName.s, nTrackCount, nAssignTo)
  PROCNAMECA(pAudPtr)
  ; returns playback channel assigned to track 1, + alt playback channel * 4096, or -1 if no tracks assigned, or -2 if SM-S cannot open the file
  Protected n, nPrimaryChan, nPlaybackChanCounter, nChan, nAltPrimaryChan
  Protected Dim aChan(0)
  Protected sMsg.s
  Protected sCmd.s
  Protected sPChanList.s, sAltPChanList.s
  Protected nReqdStartTime, nAltReqdStartTime, nReqdStopTime, nReqdRepeatTime
  Protected nReqdStartSamplePos, nAltReqdStartSamplePos, nReqdStopSamplePos, nReqdRepeatSamplePos
  Protected sTrackTimesCommandString.s, sAltTrackTimesCommandString.s
  Protected nMainCount
  Protected sMuteXPointsCommandString.s
  Protected nDevMapPtr, d1, d2
  Protected nPlaybackIndex
  
  debugMsgSMS(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName) + ", nTrackCount=" + Str(nTrackCount))
  
  nMainCount = 1
  If pAudPtr >= 0 ; nb will be -1 for preview, which is why sFileName and nTrackCount are included in the procedure's parameters
    With aAud(pAudPtr)
      setTrackTimesCommandStrings(pAudPtr, #True, 0)
      nMainCount = grSMS\nMainCount
      sTrackTimesCommandString = grSMS\sTrackTimesCommandString
      sAltTrackTimesCommandString = grSMS\sAltTrackTimesCommandString
      debugMsgSMS(sProcName, "nMainCount=" + nMainCount + ", sTrackTimesCommandString=" + #DQUOTE$ + sTrackTimesCommandString + #DQUOTE$ +
                          ", sAltTrackTimesCommandString=" + #DQUOTE$ + sAltTrackTimesCommandString + #DQUOTE$)
      
      If usingLoopXFade(pAudPtr)
        \nSMSPChansReqd = \nFileChannels * 2
      Else
        \nSMSPChansReqd = \nFileChannels
      EndIf
      
      debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileChannels=" + aAud(pAudPtr)\nFileChannels + ", \nSMSPChansReqd=" + aAud(pAudPtr)\nSMSPChansReqd)
    EndWith
  EndIf
  
  nPrimaryChan = -1
  nAltPrimaryChan = -1
  ReDim aChan(nTrackCount * nMainCount)
  
  ; check that we have sufficient playback channels available
  
  For nPlaybackIndex = 0 To ArraySize(gaPlayback())
    With gaPlayback(nPlaybackIndex)
      ;debugMsgSMS(sProcName, "gaPlayback(" + n + ")\nAssignedTo=" + decodePLBAssignedTo(\nAssignedTo) + ", \sFileName=" + GetFilePart(\sFileName) + ", \nFileTrackNo=" + \nFileTrackNo)
      If \nAssignedTo = #SCS_PLB_UNASSIGNED
        nPlaybackChanCounter + 1
        If nPlaybackChanCounter = (nTrackCount * nMainCount)
          ; sufficient playback channels available
          Break
        EndIf
      EndIf
    EndWith
  Next nPlaybackIndex
  
  If nPlaybackChanCounter < (nTrackCount * nMainCount)
    sMsg = "couldn't find sufficient available playback channels for " + GetFilePart(sFileName) + ". Required " + Str(nTrackCount * nMainCount) + ", found " + Str(nPlaybackChanCounter) + "."
    debugMsgSMS(sProcName, sMsg)
    ;MsgBox sMsg, #MB_ICONEXCLAMATION, #SCS_TITLE
    If pAudPtr >= 0
      aAud(pAudPtr)\nSMSPChanCount = 0
    EndIf
    ProcedureReturn -1
  EndIf
  
  nPlaybackChanCounter = 0
  For nPlaybackIndex = 0 To ArraySize(gaPlayback())
    With gaPlayback(nPlaybackIndex)
      If \nAssignedTo = #SCS_PLB_UNASSIGNED
        nPlaybackChanCounter + 1
        \nAssignedTo = nAssignTo  ; eg #SCS_PLB_PREVIEW
        \qTimeAssigned = ElapsedMilliseconds()
        If nPlaybackChanCounter = 1
          nPrimaryChan = nPlaybackIndex ; track 1 is primary channel;
        ElseIf nPlaybackChanCounter = (nTrackCount + 1)
          nAltPrimaryChan = nPlaybackIndex
        EndIf
        If nPlaybackChanCounter <= nTrackCount
          \nPrimaryChan = nPrimaryChan
          \nFileTrackNo = nPlaybackChanCounter
        Else
          \nPrimaryChan = nAltPrimaryChan
          \nFileTrackNo = nPlaybackChanCounter - nTrackCount
        EndIf
        \sFileName = sFileName
        \nFileTrackCount = nTrackCount
        debugMsgSMS(sProcName, "gaPlayback(" + nPlaybackIndex + ")\sFileName=" + GetFilePart(\sFileName) + ", \nFileTrackNo=" + \nFileTrackNo + ", \nPrimaryChan=" + \nPrimaryChan)
        aChan(nPlaybackChanCounter) = nPlaybackIndex ; nPlaybackIndex is the index to the item in the array gaPlayback(), and it is used as the SM-S playback channel as it will be unique.
                                                     ; This also means that later on we can use an SM-S playback channel (eg 2 from P2) as a direct index into gaPlayback()
        
        ;debugMsgSMS(sProcName, "aChanPlaybackIndex(" + nPlaybackChanCounter + ")=" + aChanPlaybackIndex(nPlaybackChanCounter))
        If nPlaybackChanCounter = (nTrackCount * nMainCount)
          ; all tracks assigned for main and (if applicable) alt
          Break
        EndIf
      EndIf
    EndWith
  Next nPlaybackIndex
  
  For n = 1 To nPlaybackChanCounter
    ; step through the channels for this aAud(pAudPtr), eg step through p2, p3, p4, etc which would be in index positions 1, 2, 3y etc
    nChan = aChan(n) ; see comments earlier in this Procedure against "aChan(nPlaybackChanCounter) = nPlaybackIndex"
    With gaPlayback(nChan)
      If n <= nTrackCount
        \sTrackCommandString = " track file " + #DQUOTE$ + sFileName + #DQUOTE$ + " track " + \nFileTrackNo + sTrackTimesCommandString + " gain 1"
        sCmd = "set chan p" + nChan + \sTrackCommandString
        sendSMSCommand(sCmd)
        debugMsgSMS(sProcName, "grSMS\sFirstWordLC=" + grSMS\sFirstWordLC)
        If grSMS\sFirstWordLC <> "ok"
          ; SM-S couldn't open the file
          nPrimaryChan = -2
          If pAudPtr >= 0
            aAud(pAudPtr)\sErrorMsg = grSMS\sFirstLine
          EndIf
          Break
        EndIf
        sPChanList + " p" + nChan
      Else
        \sTrackCommandString = " track file " + #DQUOTE$ + sFileName + #DQUOTE$ + " track " + \nFileTrackNo + sAltTrackTimesCommandString + " gain 1"
        sCmd = "set chan p" + nChan + \sTrackCommandString
        sendSMSCommand(sCmd)
        debugMsgSMS(sProcName, "grSMS\sFirstWordLC=" + grSMS\sFirstWordLC)
        If grSMS\sFirstWordLC <> "ok"
          ; SM-S couldn't open the file
          nPrimaryChan = -2
          If pAudPtr >= 0
            aAud(pAudPtr)\sErrorMsg = grSMS\sFirstLine
          EndIf
          Break
        EndIf
        sAltPChanList + " p" + nChan
      EndIf
      \nAudPtr = pAudPtr
    EndWith
    sMuteXPointsCommandString + " px" + nChan + ".0-" + Str(grASIOGroup\nGroupOutputs - 1)
  Next n
  
  If nPrimaryChan >= 0
    
    If pAudPtr >= 0
      aAud(pAudPtr)\nSMSPChanCount = nPlaybackChanCounter
    EndIf
    ; mute all XPoints to ensure we clear out any previous gain settings for an earlier use of these playback channels
    If Len(sMuteXPointsCommandString) > 0
      sCmd = "set chan" + sMuteXPointsCommandString + " gain 0"
      sendSMSCommand(sCmd)
    EndIf
    
    If nPrimaryChan >= 0
      debugMsgSMS(sProcName, "sPChanList=" + Trim(sPChanList))
      gaPlayback(nPrimaryChan)\sPChanListPrimary = Trim(sPChanList)
    EndIf
    
    If nAltPrimaryChan >= 0
      debugMsgSMS(sProcName, "sAltPChanList=" + Trim(sAltPChanList))
      gaPlayback(nAltPrimaryChan)\sPChanListPrimary = Trim(sAltPChanList)
    EndIf
    
;     ; INFO TEMP START !!!!!!!!!!!!!!!!!!!!!! 31Aug2021 11.8.6af
; ;     sCmd = "set chan p0 p1 track pitch -24 fadetime 5.0"
; ;     sendSMSCommand(sCmd)
;     sCmd = "set chan p0 p1 track speed 2.0 FADETIME 5.0"
;     sendSMSCommand(sCmd)
;     ; INFO TEMP END   !!!!!!!!!!!!!!!!!!!!!! 31Aug2021 11.8.6af
    
    
  EndIf
  
  If (nPrimaryChan < 0) Or (pAudPtr < 0)
    ProcedureReturn nPrimaryChan
  Else
    ProcedureReturn (nPrimaryChan + (nAltPrimaryChan << 16))
  EndIf
  
EndProcedure

Procedure.s buildXChanListForInputDev(pAudPtr, nInputDevNo, nOutputDevNo)
  PROCNAMECA(pAudPtr)
  Protected Dim aInputChan(0)
  Protected Dim aOutputChan(0)
  Protected nInputNo, nOutputNo
  Protected sXChanListLeft.s, sXChanListRight.s
  Protected bNoDevice
  Protected nDevMapPtr
  Protected nInputDevMapDevPtr, nOutputDevMapDevPtr
  Protected nNrOfInputChans, nNrOfOutputChans
  Protected nPhysicalDevPtr
  Protected nMyOutputChan
  Protected n1, n2
  
  debugMsgSMS(sProcName, #SCS_START + ", nInputDevNo=" + nInputDevNo + ", nOutputDevNo=" + nOutputDevNo)
  
  If pAudPtr < 0
    ProcedureReturn ""
  EndIf
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn ""
  EndIf
  
  With aAud(pAudPtr)
    nInputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, \sInputLogicalDev[nInputDevNo])
    nOutputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, \sLogicalDev[nOutputDevNo])
    If nInputDevMapDevPtr < 0 Or nOutputDevMapDevPtr < 0
      ProcedureReturn ""
    EndIf
    
    ; build array of input channels
    nNrOfInputChans = 1 ; currently assume all inputs are mono
    ReDim aInputChan(nNrOfInputChans)
    For nInputNo = 1 To nNrOfInputChans
      aInputChan(nInputNo) = grMaps\aDev(nInputDevMapDevPtr)\nFirst1BasedInputChan - 1 + nInputNo - 1
    Next nInputNo
    
    ; build array of output channels
    nNrOfOutputChans = grMaps\aDev(nOutputDevMapDevPtr)\nNrOfDevOutputChans
    debugMsgSMS(sProcName, "nNrOfOutputChans=" + nNrOfOutputChans)
    ReDim aOutputChan(nNrOfOutputChans)
    
    debugMsgSMS(sProcName, "grMaps\aDev(" + nOutputDevMapDevPtr + ")\bNoDevice=" + strB(grMaps\aDev(nOutputDevMapDevPtr)\bNoDevice) + ", \nPhysicalDevPtr=" + Str(grMaps\aDev(nOutputDevMapDevPtr)\nPhysicalDevPtr))
    bNoDevice = grMaps\aDev(nOutputDevMapDevPtr)\bNoDevice
    If bNoDevice = #False
      nPhysicalDevPtr = grMaps\aDev(nOutputDevMapDevPtr)\nPhysicalDevPtr
      If nPhysicalDevPtr < 0
        ProcedureReturn ""
      EndIf
      CheckSubInRange(nPhysicalDevPtr, ArraySize(gaAudioDev()), "gaAudioDev()")
      debugMsgSMS(sProcName, "grMaps\aDev(" + nOutputDevMapDevPtr + ")\nFirst1BasedOutputChan=" + grMaps\aDev(nOutputDevMapDevPtr)\nFirst1BasedOutputChan)
      debugMsgSMS(sProcName, "gaAudioDev(" + nPhysicalDevPtr + ")\nFirst0BasedOutputChanAG=" + Str(gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG))
      ; nMyOutputChan = grMaps\aDev(nOutputDevMapDevPtr)\nFirst1BasedOutputChan - 1 + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG
      nMyOutputChan = grMaps\aDev(nOutputDevMapDevPtr)\nFirst0BasedOutputChanAG ; Changed 27Dec2022 11.9.8aa
      For nOutputNo = 1 To nNrOfOutputChans
        aOutputChan(nOutputNo) = nMyOutputChan
        debugMsgSMS(sProcName, "aOutputChan(" + nOutputNo + ")=o" + aOutputChan(nOutputNo))
        nMyOutputChan + 1
      Next nOutputNo
    Else
      nOutputNo = 1
      nNrOfOutputChans = 1
      aOutputChan(nOutputNo) = 1000
      debugMsgSMS(sProcName, "aOutputChan(" + nOutputNo + ")=o" + aOutputChan(nOutputNo))
    EndIf
    
    If nNrOfOutputChans = 0
      ProcedureReturn ""
    EndIf
    
    ; build crosspoint lists
    If nNrOfInputChans = nNrOfOutputChans
      ; same number of Inputs as outputs, so 1:1 mapping
      For n1 = 1 To nNrOfInputChans
        n2 = n1
        If nNrOfOutputChans = 2 And n2 = 2
          sXChanListRight + " x" + aInputChan(n1) + "." + aOutputChan(n2)
        Else
          sXChanListLeft + " x" + aInputChan(n1) + "." + aOutputChan(n2)
        EndIf
      Next n1
      
    ElseIf nNrOfInputChans < nNrOfOutputChans
      ; more outputs than Inputs, so cycle Inputs thru outputs
      n1 = 1
      For n2 = 1 To nNrOfOutputChans
        If nNrOfOutputChans = 2 And n2 = 2
          sXChanListRight + " x" + aInputChan(n1) + "." + aOutputChan(n2)
        Else
          sXChanListLeft + " x" + aInputChan(n1) + "." + aOutputChan(n2)
        EndIf
        n1 + 1
        If n1 > nNrOfInputChans
          n1 = 1
        EndIf
      Next n2
      
    Else
      ; more Inputs than ouputs, so downmix
      n2 = 1
      For n1 = 1 To nNrOfInputChans
        If nNrOfOutputChans = 2 And n2 = 2
          sXChanListRight + " x" + aInputChan(n1) + "." + aOutputChan(n2)
        Else
          sXChanListLeft + " x" + aInputChan(n1) + "." + aOutputChan(n2)
        EndIf
        n2 + 1
        If n2 > nNrOfOutputChans
          n2 = 1
        EndIf
      Next n1
    EndIf
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END + ", sXChanListLeft=" + Trim(sXChanListLeft) + ", sXChanListRight=" + Trim(sXChanListRight))
  
  ProcedureReturn Trim(sXChanListLeft) + " | " + Trim(sXChanListRight)
  
EndProcedure

Procedure.s buildPXChanList(nPrimaryPlaybackChan, nLogicalDevPtr, sTracks.s)
  PROCNAMEC()
  ; returns playback crosspoint channel list
  Protected nPlaybackChans, nNrOfOutputChans, n1, n2, nTrackNo, nOutputNo
  Protected nMyOutputChan
  Protected Dim aPlaybackChan(0)
  Protected Dim aPlaybackChanTrack(0)
  Protected Dim aOutputChan(0)
  Protected sPXChanListLeft.s, sPXChanListRight.s
  Protected sTCRChanList.s
  Protected sReturnList.s
  Protected nPhysicalDevPtr, bNoDevice
  Protected sMyTracks.s, sThisTrackNo.s, bWantThisTrack
  Protected nPChanNo
  Protected d, nDevMapDevPtr
  Protected bDownMix
  
  debugMsgSMS(sProcName, #SCS_START + ", nPrimaryPlaybackChan=" + nPrimaryPlaybackChan + ", sTracks=" + sTracks)
  
  If nPrimaryPlaybackChan < 0
    ProcedureReturn ""
  EndIf
  
  nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, grProd\aAudioLogicalDevs(nLogicalDevPtr)\sLogicalDev)
  debugMsgSMS(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
  
  If nDevMapDevPtr = -1
    ProcedureReturn ""
  EndIf
  
  sMyTracks = Trim(sTracks)
  If Len(sMyTracks) = 0
    sMyTracks = #SCS_TRACKS_DFLT
  EndIf
  
  ; build array of playback channels
  nPlaybackChans = gaPlayback(nPrimaryPlaybackChan)\nFileTrackCount
  debugMsgSMS(sProcName, "nPlaybackChans=" + nPlaybackChans)
  ReDim aPlaybackChan(nPlaybackChans)
  ReDim aPlaybackChanTrack(nPlaybackChans)
  
  nPlaybackChans = 0
  For nTrackNo = 1 To ArraySize(aPlaybackChan())
    aPlaybackChan(nTrackNo) = -1
    For n1 = 0 To ArraySize(gaPlayback())
      If gaPlayback(n1)\nPrimaryChan = nPrimaryPlaybackChan
        If gaPlayback(n1)\nFileTrackNo = nTrackNo
          sThisTrackNo = Str(nTrackNo)
          Select sMyTracks
            Case "", #SCS_TRACKS_DFLT, #SCS_TRACKS_ALL, sThisTrackNo
              bWantThisTrack = #True
            Default
              bWantThisTrack = #False
          EndSelect
          debugMsgSMS(sProcName, "gaPlayback(" + n1 + ")\nFileTrackNo=" + gaPlayback(n1)\nFileTrackNo + ", sThisTrackNo=" + sThisTrackNo + ", sMyTracks=" + sMyTracks + ", bWantThisTrack=" + strB(bWantThisTrack))
          If bWantThisTrack
            nPlaybackChans + 1
            aPlaybackChan(nPlaybackChans) = n1
            aPlaybackChanTrack(nPlaybackChans) = nTrackNo
            debugMsgSMS(sProcName, "aPlaybackChan(" + nPlaybackChans + ")=p" + aPlaybackChan(nPlaybackChans) + ", nTrackNo=" + nTrackNo)
          EndIf
          Break
        EndIf
      EndIf
    Next n1
  Next nTrackNo
  
  ; build array of output channels
  nNrOfOutputChans = grMaps\aDev(nDevMapDevPtr)\nNrOfDevOutputChans
  debugMsgSMS(sProcName, "nNrOfOutputChans=" + nNrOfOutputChans)
  ReDim aOutputChan(nNrOfOutputChans)
  
  debugMsgSMS(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\bNoDevice=" + strB(grMaps\aDev(nDevMapDevPtr)\bNoDevice) + ", \nPhysicalDevPtr=" + grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr)
  bNoDevice = grMaps\aDev(nDevMapDevPtr)\bNoDevice
  If bNoDevice = #False
    nPhysicalDevPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
    If nPhysicalDevPtr < 0
      ProcedureReturn ""
      ; listAllDevMaps()
    EndIf
    CheckSubInRange(nPhysicalDevPtr, ArraySize(gaAudioDev()), "gaAudioDev()")
    debugMsgSMS(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\nFirst1BasedOutputChan=" + grMaps\aDev(nDevMapDevPtr)\nFirst1BasedOutputChan)
    debugMsgSMS(sProcName, "gaAudioDev(" + nPhysicalDevPtr + ")\nFirst0BasedOutputChan=" + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG)
    ; nMyOutputChan = grMaps\aDev(nDevMapDevPtr)\nFirst1BasedOutputChan - 1 + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG
    nMyOutputChan = grMaps\aDev(nDevMapDevPtr)\nFirst0BasedOutputChanAG ; Changed 27Dec2022 11.9.8aa
    For nOutputNo = 1 To nNrOfOutputChans
      ; added 16/07/2014 to handle outputs > those supported by the SM-S dongle or demo version - drops outputs back to be within range
      While nMyOutputChan > (grASIOGroup\nGroupOutputs - 1)
        nMyOutputChan - 2
      Wend
      ; end added 16/07/2014
      aOutputChan(nOutputNo) = nMyOutputChan
      debugMsgSMS(sProcName, "aOutputChan(" + nOutputNo + ")=o" + aOutputChan(nOutputNo))
      nMyOutputChan + 1
    Next nOutputNo
  Else
    nOutputNo = 1
    nNrOfOutputChans = 1
    aOutputChan(nOutputNo) = 1000
    debugMsgSMS(sProcName, "aOutputChan(" + nOutputNo + ")=o" + aOutputChan(nOutputNo))
  EndIf
  
  If nPlaybackChans = 0 Or nNrOfOutputChans = 0
    ProcedureReturn ""
  EndIf
  
  CompilerIf #c_include_tcreader
    sPXChanListLeft = " px" + Str(aPlaybackChan(1)) + "." + Str(aOutputChan(1))
    sPXChanListRight = " px" + Str(aPlaybackChan(1)) + "." + Str(aOutputChan(2))
    sTCRChanList = " px" + Str(aPlaybackChan(1)) + ".o1000"
    debugMsgSMS(sProcName, "sPXChanListLeft=" + Trim(sPXChanListLeft) + ", sPXChanListRight=" + Trim(sPXChanListRight) + ", sTCRChanList=" + Trim(sTCRChanList))
    sReturnList = Trim(sPXChanListLeft) + " | " + Trim(sPXChanListRight) + " | " + Trim(sTCRChanList)
    
  CompilerElse
    Select sMyTracks
      Case #SCS_TRACKS_DFLT
        If nPlaybackChans = nNrOfOutputChans
          ; same number of playbacks as outputs, so 1:1 mapping
          For n1 = 1 To nPlaybackChans
            n2 = n1
            If (nNrOfOutputChans = 2) And (n2 = 2)
              sPXChanListRight + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
            Else
              sPXChanListLeft + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
            EndIf
          Next n1
          
        ElseIf nPlaybackChans < nNrOfOutputChans
          ; more outputs than playbacks, so cycle playbacks thru outputs
          n1 = 1
          For n2 = 1 To nNrOfOutputChans
            If (nNrOfOutputChans = 2) And (n2 = 2)
              sPXChanListRight + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
            Else
              sPXChanListLeft + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
            EndIf
            n1 + 1
            If n1 > nPlaybackChans
              n1 = 1
            EndIf
          Next n2
          
        Else
          ; more playbacks than ouputs, so downmix
          n2 = 1
          For n1 = 1 To nPlaybackChans
            If (nNrOfOutputChans = 2) And (n2 = 2)
              sPXChanListRight + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
            Else
              sPXChanListLeft + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
            EndIf
            n2 + 1
            If n2 > nNrOfOutputChans
              n2 = 1
            EndIf
          Next n1
          bDownMix = #True
        EndIf
        
      Case #SCS_TRACKS_ALL
        ; downmix all playback channels to all outputs
        For n1 = 1 To nPlaybackChans
          For n2 = 1 To nNrOfOutputChans
            sPXChanListLeft + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
          Next n2
        Next n1
        
      Default
        If IsNumeric(sMyTracks)
          ; upmix selected track only
          nTrackNo = Val(sMyTracks)
          For n1 = 1 To nPlaybackChans
            If aPlaybackChanTrack(n1) = nTrackNo
              For n2 = 1 To nNrOfOutputChans
                sPXChanListLeft + " px" + aPlaybackChan(n1) + "." + aOutputChan(n2)
              Next n2
            EndIf
          Next n1
        EndIf
        
    EndSelect
    If bDownMix
      debugMsgSMS(sProcName, "nPlaybackChans=" + nPlaybackChans + ", sPXChanListLeft=" + Trim(sPXChanListLeft) + ", sPXChanListRight=" + Trim(sPXChanListRight) + ", bDownMix=" + strB(bDownMix))
      sReturnList = Trim(sPXChanListLeft) + " | " + Trim(sPXChanListRight) + " | DM"
    Else
      debugMsgSMS(sProcName, "nPlaybackChans=" + nPlaybackChans + ", sPXChanListLeft=" + Trim(sPXChanListLeft) + ", sPXChanListRight=" + Trim(sPXChanListRight))
      sReturnList = Trim(sPXChanListLeft) + " | " + Trim(sPXChanListRight)
    EndIf
    
  CompilerEndIf
  
  ProcedureReturn sReturnList
  
EndProcedure

Procedure.s buildXChanListForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected sXChanList.s
  Protected j, k
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      If \bSubTypeI
        j = \nFirstSubIndex
        While j >= 0
          If (aSub(j)\bSubTypeI) And (aSub(j)\bSubEnabled)
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              sXChanList + " " + aAud(k)\sSyncXChanList
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        
      EndIf
    EndWith
  EndIf
  ProcedureReturn Trim(sXChanList)
  
EndProcedure

Procedure.s buildXChanListForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sXChanList.s
  Protected k
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeI
        k = \nFirstAudIndex
        While k >= 0
          sXChanList + " " + aAud(k)\sSyncXChanList
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
    EndWith
  EndIf
  ProcedureReturn Trim(sXChanList)
  
EndProcedure

Procedure.s silenceDuplicatePXChans(sPXChanList.s, bFirstDev)
  PROCNAMEC()
  Protected sOldPXChanList.s, sNewPXChanList.s
  Protected sPXChanListLeft.s, sPXChanListRight.s
  Static sPrevPXChanLists.s
  Protected nPtr, nPXPtr, nSpacePtr
  Protected sPXItem.s, sNewPXItem.s
  Protected nPrevPtr
  Protected nDotPtr
  Static nFakeOutputNr
  
  sOldPXChanList = sPXChanList + " "
  
  If bFirstDev
    sPrevPXChanLists = ""
    nFakeOutputNr = 1000     ; SMS output for a fake output channel (range 1000 - 1007) - actually an SMPTE generator
                             ; comment added 23Nov2017: by default, dongles only permit 2 SMPTE generators, not 8, so just use 1000, not 1000 - 1007
  EndIf
  
  nPtr = 1
  While nPtr < Len(sOldPXChanList)
    nPXPtr = FindString(sOldPXChanList, "px", nPtr)
    If nPXPtr = 0
      ; no more px items found so force While loop to end
      nPtr = Len(sOldPXChanList)
    Else
      nSpacePtr = FindString(sOldPXChanList, " ", nPXPtr)
      sPXItem = Mid(sOldPXChanList, nPXPtr, (nSpacePtr - nPXPtr))
      ; now search for this px item in previous lists
      nPrevPtr = InStr(sPrevPXChanLists, sPXItem + " ")
      If nPrevPtr > 0
        ; px item already exists so convert the current item to a silent (fake) output
        nDotPtr = InStr(sPXItem, ".")
        sNewPXItem = Left(sPXItem, nDotPtr) + nFakeOutputNr
        debugMsgSMS(sProcName, "sPXItem=" + sPXItem + ", sNewPXItem=" + sNewPXItem)
        ; commented out 23Nov2017: by default, dongles only permit 2 SMPTE generators, not 8, so just use 1000, not 1000 - 1007
        ; If nFakeOutputNr < 1007
        ;   nFakeOutputNr + 1
        ; EndIf
        sPXItem = sNewPXItem
      EndIf
      sNewPXChanList + sPXItem + " "
      nPtr = nSpacePtr    ; position nPtr after current item
    EndIf
  Wend
  
  sPrevPXChanLists + Trim(sNewPXChanList) + " "
  
  ; debugMsgSMS(sProcName, "sPXChanList=" + sPXChanList + ", sNewPXChanList=" + Trim(sNewPXChanList))
  ProcedureReturn Trim(sNewPXChanList)
  
EndProcedure

Procedure resetSMS()
  PROCNAMEC()
  Protected sField.s
  Protected n
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  If grSMS\nSMSClientConnection
    
    writeSMSLogLine(sProcName, "resetting SM-S")
    
    If grSMS\bInterfaceOpen
      sendSMSCommand("set matrix off")
    EndIf
    clearPlaybacks()
    
    With grMMedia
      If \nSMSOutputsUsed > 0
        ; set gain of all outputs on this device to full
        sendSMSCommand("set chan out 0-" + Str(\nSMSOutputsUsed - 1) + " gain 1")
      EndWith
      
    EndIf
    
  EndIf
  
EndProcedure

Procedure.s makeSMSTimeString(nTime)
  PROCNAMEC()
  Protected sTime.s, nSigDigits
  ; NB StrD seems To give a more accurate result than StrF To Toe right of the decimal point
  sTime = ReplaceString(StrD(nTime / 1000, 3), ",", ".")  ; Replace is to change comma decimal separator to period
  
  nSigDigits = Len(sTime)
  If Mid(sTime, nSigDigits, 1) = "0"        ; thousandths
    nSigDigits - 1
    If Mid(sTime, nSigDigits, 1) = "0"      ; hundredths
      nSigDigits - 1
      If Mid(sTime, nSigDigits, 1) = "0"    ; tenths
        nSigDigits - 2              ; ignore decimal separator as well as "0" tenths digit
      EndIf
    EndIf
  EndIf
  If nSigDigits = 0
    ProcedureReturn "0"
  Else
    ProcedureReturn Left(sTime, nSigDigits)
  EndIf
  
EndProcedure

Procedure.s makeSMSGainString(fGain.f)
  PROCNAMEC()
  Protected sGain.s, nSigDigits
  
  sGain = ReplaceString(StrF(fGain, 3), ",", ".") ; Replace is to change comma decimal separator to period
  
  nSigDigits = Len(sGain)
  If Mid(sGain, nSigDigits, 1) = "0"        ; thousandths
    nSigDigits - 1
    If Mid(sGain, nSigDigits, 1) = "0"      ; hundredths
      nSigDigits - 1
      If Mid(sGain, nSigDigits, 1) = "0"    ; tenths
        nSigDigits - 2              ; ignore decimal separator as well as "0" tenths digit
      EndIf
    EndIf
  EndIf
  If nSigDigits = 0
    ProcedureReturn "0"
  Else
    ProcedureReturn Left(sGain, nSigDigits)
  EndIf
  
EndProcedure

Procedure.s makeSMSGainDBString(fGain.f)
  PROCNAMEC()
  Protected sGain.s
  
  sGain = convertBVLevelToDBString(fGain)
  If sGain = #SCS_INF_DBLEVEL
    sGain = "-160"        ; SM-S equivalent of -INF
  EndIf
  ProcedureReturn sGain
  
EndProcedure

Procedure.s makeSMSGainMIDIString(fGain.f)
  PROCNAMEC()
  Protected nGain
  Protected sGain.s
  
  debugMsgSMS(sProcName, "fGain=" + formatLevel(fGain))
  If fGain >= 1
    nGain = 127
  Else
    ; nGain = (SLD_BVLevelToSliderValue(fGain) * 127) / #SCS_MAXVOLUME_SLD
    nGain = Round((SLD_BVLevelToSliderValue(fGain) * 127) / #SCS_MAXVOLUME_SLD, #PB_Round_Down) ; round down to make sure nGain does not represent a level greater than fGain
  EndIf
  sGain = Str(nGain)
  debugMsgSMS(sProcName, "nGain=" + Str(nGain) + ", sGain=" + sGain)
  ProcedureReturn sGain
  
EndProcedure

Procedure.s makeSMSFadeType(nFadeType)
  PROCNAMEC()
  Protected sSMSFadeType.s
  
  Select nFadeType
    Case #SCS_FADE_STD                      ; standard
      sSMSFadeType = ""
      
    Case #SCS_FADE_LIN, #SCS_FADE_LIN_SE    ; linear
      sSMSFadeType = "lin"
      
    Case #SCS_FADE_LOG, #SCS_FADE_LOG_SE    ; log
      sSMSFadeType = "log"
      
    Case #SCS_FADE_EXP                      ; exponential
      sSMSFadeType = "exp"
      
  EndSelect
  
  ProcedureReturn sSMSFadeType
  
EndProcedure

Procedure buildGetSMSCurrInfoCommandStrings()
  ; PROCNAMEC()
  Protected sCurrPList.s, sCurrPXList.s
  Protected sCurrAltPList.s
  Protected k
  
  ; debugMsgSMS(sProcName, #SCS_START)
  
  For k = 1 To gnLastAud
    With aAud(k)
      If \bExists
        ; debugMsgSMS(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState) + ", \sFileState=" + \sFileState + ", \sPPrimaryChan=" + \sPPrimaryChan + ", \sAudPXChanList=" + \sAudPXChanList)
        If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
          If \bAudTypeForP
            sCurrPList + " " + \sPPrimaryChan
            sCurrPXList + " " + \sAudPXChanList
            If Len(\sAltPPrimaryChan) > 0
              sCurrAltPList + " " + \sAltPPrimaryChan
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next k
  
  With grPreview
    ; debugMsgSMS(sProcName, "gbPreviewPlaying=" + strB(gbPreviewPlaying))
    If gbPreviewPlaying
      sCurrPList + " " + \sPChanList
      sCurrPXList + " " + \sPXChanList
    EndIf
  EndWith
  
  With grSMS
    \sPStatusCommandString = ""
    \sPTimeCommandString = ""
    \sPXGainCommandString = ""
    If \nSMSClientConnection
      If Len(Trim(sCurrPList)) > 0
        \sPStatusCommandString = "get chan " + Trim(sCurrPList) + " track status"
        \sPTimeCommandString = "get chan " + Trim(sCurrPList + sCurrAltPList) + " track time"
        ; NB get "track time" not "track position", as "track time" returns seconds (x.xxx) but "track position" returns samples
      EndIf
      If Len(Trim(sCurrPXList)) > 0
        \sPXGainCommandString = "get chan " + Trim(sCurrPXList) + " gaindb"
      EndIf
    EndIf
    ; debugMsgSMS(sProcName, "\sPStatusCommandString=" + \sPStatusCommandString + ", \sPTimeCommandString=" + \sPTimeCommandString + ", \sPXGainCommandString=" + \sPXGainCommandString)
  EndWith
  
  ; debugMsgSMS(sProcName, "calling clearAllResponses()")
  clearAllResponses()
  
  ; debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure waitForSMSInput(nMaxWaitTime=100)
  PROCNAMEC()
  Protected n, bResult, nTimeToGo
  Protected bLockReqd, bLockedMutex
  
  ;scsTryLockMutex(gnSMSNetworkMutex, #SCS_MUTEX_SMS_NETWORK, 358)
  TryLockSMSNetworkMutex(358)
  If (bLockReqd = #False) Or (bLockedMutex)
    bResult = handleSMSInput()
    If bResult = #False
      nTimeToGo = nMaxWaitTime
      While nTimeToGo > 0
        Delay(5)
        bResult = handleSMSInput()
        If bResult
          Break
        EndIf
        nTimeToGo - 5
      Wend
    EndIf
    ;scsUnlockMutex(gnSMSNetworkMutex, #SCS_MUTEX_SMS_NETWORK)
    UnlockSMSNetworkMutex()
  EndIf
EndProcedure

Procedure getSMSCurrInfo(bGetVUReadings)
  PROCNAMEC()
  Protected n, bResult
  
  ; debugMsgSMS(sProcName, #SCS_START + ", grASIOGroup\bGroupInitialized=" + strB(grASIOGroup\bGroupInitialized) +
  ; ", gnSuspendGetCurrInfo=" + gnSuspendGetCurrInfo + ", grSMS\sPXGainCommandString=" + grSMS\sPXGainCommandString)
  
  If (grASIOGroup\bGroupInitialized = #False) Or (gnSuspendGetCurrInfo > 0) Or (gbInReposAuds)
    ; temporarily suspending getSMSCurrInfo(), or closing down
    ProcedureReturn
  EndIf

  If gbInGetSMSCurrInfo
    ProcedureReturn
  EndIf
  gbInGetSMSCurrInfo = #True
  
  With grSMS
    If \sPStatusCommandString
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "\sPStatusCommandString=" + \sPStatusCommandString)
      CompilerEndIf
      SendNetworkStringAscii(\nSMSClientConnection, \sPStatusCommandString + #CR$, #False)   ; must terminate command with CR for SM-S
      waitForSMSInput()
      
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "\sPTimeCommandString=" + \sPTimeCommandString)
      CompilerEndIf
      SendNetworkStringAscii(\nSMSClientConnection, \sPTimeCommandString + #CR$, #False)
      waitForSMSInput()
    EndIf
    
    If \sPXGainCommandString
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "\sPXGainCommandString=" + \sPXGainCommandString)
      CompilerEndIf
      SendNetworkStringAscii(\nSMSClientConnection, \sPXGainCommandString + #CR$, #False)
      waitForSMSInput()
    EndIf
    
    If \bLTCRunning
      If \sGetTimeCodeCommandString
        CompilerIf #cTraceSMSCurrInfo
          debugMsgSMS(sProcName, "\sGetTimeCodeCommandString=" + \sGetTimeCodeCommandString)
        CompilerEndIf
        SendNetworkStringAscii(\nSMSClientConnection, \sGetTimeCodeCommandString + #CR$, #False)
        waitForSMSInput()
      EndIf
    EndIf
    
    ; debugMsgSMS(sProcName, "bGetVUReadings=" + strB(bGetVUReadings) + ", \sOVUCommandString=" + \sOVUCommandString + ", gnVisMode=" + decodeVisMode(gnVisMode))
    If (bGetVUReadings) And (\sOVUCommandString) And (gnVisMode = #SCS_VU_LEVELS)
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "\sOVUCommandString=" + \sOVUCommandString)
      CompilerEndIf
      SendNetworkStringAscii(\nSMSClientConnection, \sOVUCommandString + #CR$, #False)
      \bVUCommandStringChanged = #False
      waitForSMSInput()
    EndIf
    
  EndWith
  
  gbInGetSMSCurrInfo = #False
  
EndProcedure

Procedure getAndWaitForTrackTime(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  Protected sSMSCommand.s
  
  With aAud(pAudPtr)
    If \sAudPChanList
      sSMSCommand = "get channel " + StringField(\sAudPChanList, 1, " ") + " track time"
      SendNetworkStringAscii(grSMS\nSMSClientConnection, sSMSCommand + #CR$, #False)
      waitForSMSInput()
    EndIf
  EndWith
  
EndProcedure

Procedure.s extractCurrInfo(sBuff.s)
  PROCNAMEC()
  ; NB this Procedure not currently used.
  Protected sMyResponse.s, sMyResponseLine.s, sReturnResponse.s
  Protected n, nLengthInBytes, nMyResponseLineCount
  Protected bLineProcessed
  
  sMyResponse = sBuff
  sReturnResponse = sMyResponse
  nLengthInBytes = Len(sMyResponse)
  If nLengthInBytes > 0
    nMyResponseLineCount = CountString(sMyResponse, #CR$)
    ; debugMsgSMS(sProcName, "nMyResponseLineCount=" + nMyResponseLineCount)
    For n = 1 To nMyResponseLineCount
      sMyResponseLine = StringField(sMyResponse + #CR$, n, #CR$)
      CompilerIf #cTraceSMSCurrInfo
        debugMsgSMS(sProcName, "sMyResponseLine=" + sMyResponseLine)
      CompilerEndIf
      If Len(sMyResponseLine) > 0
        bLineProcessed = #False
        If Right(sMyResponseLine, 1) = ";"
          sMyResponseLine = Left(sMyResponseLine, Len(sMyResponseLine) - 1) ; remove trailing semicolon
        EndIf
        
        If Left(sMyResponseLine, 11) = "TrackStatus"
          grSMS\sPStatusResponse = sMyResponseLine
          bLineProcessed = #True
          
        ElseIf Left(sMyResponseLine, 9) = "TrackTime"
          grSMS\sPTimeResponse = sMyResponseLine
          ; debugMsg(sProcName, "grSMS\sPTimeResponse=" + grSMS\sPTimeResponse)
          bLineProcessed = #True
          
        ElseIf Left(sMyResponseLine, 4) = "Gain"
          grSMS\sPXGainResponse = sMyResponseLine
          bLineProcessed = #True
          
        ElseIf Left(sMyResponseLine, 2) = "VU"
          If grSMS\bVUCommandStringChanged
            grSMS\sOVUResponse = ""
          Else
            grSMS\sOVUResponse = sMyResponseLine
          EndIf
          bLineProcessed = #True
          If gbClosingDown = #False
            gbRefreshVUDisplay = #True
          EndIf
          
        EndIf
        
        If bLineProcessed
          sReturnResponse = ReplaceString(sReturnResponse, sMyResponse + #CR$, "")
        EndIf
        
      EndIf
    Next n
  EndIf
  
  If sReturnResponse = ";"
    sReturnResponse = ""
  EndIf
  ProcedureReturn sReturnResponse
  
EndProcedure

Procedure.s getSMSTrackStatus(sPChan.s)
  PROCNAMEC()
  Protected n1, n2, n3
  Protected sMyStatusResponse.s, sMyStatusField.s
  Protected nCommaPtr
  
  If Len(Trim(sPChan)) = 0
    ProcedureReturn ""
  EndIf
  
  nCommaPtr = InStr(grSMS\sPStatusResponse, ";")
  If nCommaPtr > 0
    sMyStatusResponse = LCase(Left(grSMS\sPStatusResponse, (nCommaPtr - 1)) + " ")
  Else
    sMyStatusResponse = LCase(grSMS\sPStatusResponse + " ")
  EndIf
  n1 = FindString(sMyStatusResponse, LCase(sPChan), 1)
  If n1 > 0
    n2 = FindString(sMyStatusResponse, "=", n1)
    n3 = FindString(sMyStatusResponse, " ", n2)
    sMyStatusField = Mid(sMyStatusResponse, n2 + 1, n3 - n2 - 1)
  EndIf
  
  ;debugMsgSMS(sProcName, "sPChan=" + sPChan + ", sMyStatusResponse=" + sMyStatusResponse + ", n1=" + n1 + ", n2=" + n2 + ", n3=" + n3 + ", sMyStatusField=" + sMyStatusField)
  ProcedureReturn Trim(sMyStatusField)
  
EndProcedure

Procedure.s getSMSTrackRepeatTime(sPChan.s)
  PROCNAMEC()
  Protected sField.s
  Protected nPtr
  Protected sTrackRepeatTime.s
  
  If Len(Trim(sPChan)) = 0
    ProcedureReturn ""
  EndIf
  
  With grMMedia
    sendSMSCommand("get chan " + sPChan + " track repeat time")
    If grSMS\sFirstWordLC = "trackrepeat"
      sField = getSMSResponseField(1, 2)
      nPtr = InStr(sField, "=")
      If nPtr > 0
        sTrackRepeatTime = Mid(sField, nPtr + 1)
        ; debugMsgSMS(sProcName, "sTrackRepeatTime=" + sTrackRepeatTime)
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn Trim(sTrackRepeatTime)
  
EndProcedure

Procedure.s getSMSTrackStartTime(sPChan.s)
  PROCNAMEC()
  Protected sField.s
  Protected nPtr
  Protected sTrackStartTime.s
  
  If Len(Trim(sPChan)) = 0
    ProcedureReturn ""
  EndIf
  
  With grMMedia
    sendSMSCommand("get chan " + sPChan + " track start time")
    If grSMS\sFirstWordLC = "trackstart"
      sField = getSMSResponseField(1, 2)
      nPtr = InStr(sField, "=")
      If nPtr > 0
        sTrackStartTime = Mid(sField, nPtr + 1)
        ; debugMsgSMS(sProcName, "sTrackStartTime=" + sTrackStartTime)
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn Trim(sTrackStartTime)
  
EndProcedure

Procedure getSMSTrackTimeInMS(sPPrimaryChan.s)
  PROCNAMEC()
  Protected n1, n2, n3, nTime
  Protected sMyTimeResponse.s, sMyTimeField.s
  
  If Len(Trim(sPPrimaryChan)) = 0
    ProcedureReturn 0
  EndIf
  
  sMyTimeResponse = LCase(grSMS\sPTimeResponse + " ")
  n1 = FindString(sMyTimeResponse, LCase(sPPrimaryChan), 1)
  If n1 > 0
    n2 = FindString(sMyTimeResponse, "=", n1)
    n3 = FindString(sMyTimeResponse, " ", n2)
    sMyTimeField = Mid(sMyTimeResponse, n2 + 1, n3 - n2 - 1)
    nTime = (ValF(sMyTimeField) * 1000.0)
  EndIf
  
;   debugMsgSMS(sProcName, "sPPrimaryChan=" + sPPrimaryChan + ", sMyTimeResponse=" + sMyTimeResponse + ", n1=" + n1 + ", n2=" + n2 + ", n3=" + Str(n3) + ", sMyTimeField=" + sMyTimeField + ", nTime=" + Str(nTime))
  ProcedureReturn nTime
  
EndProcedure

Procedure calcRelFilePostions(sTrackTimeResponse.s)
  ; PROCNAMEC()
  Protected n, nChanCount, nChanNo, sResponseCut.s, sChanPart.s, sTimeField.s, nTime, nAudPtr, nNewRelFilePos
  
  nChanCount = CountString(sTrackTimeResponse, "=")
  sResponseCut.s = Trim(Mid(sTrackTimeResponse, 11), ";")
  For n = 1 To nChanCount
    sChanPart.s = StringField(sResponseCut, n, " ")
    nChanNo = Val(StringField(Mid(sChanPart,2), 1, "="))
    sTimeField = StringField(sChanPart, 2, "=")
    nTime = (ValF(sTimeField) * 1000.0)
    If nChanNo >= 0 And nChanNo < ArraySize(gaPlayback())
      nAudPtr = gaPlayback(nChanNo)\nAudPtr
      If nAudPtr >= 0
        With aAud(nAudPtr)
          If nChanNo = \nPrimaryChan
            nNewRelFilePos = nTime - \nAbsMin
            If nNewRelFilePos <> \nRelFilePos
              ; debugMsg(sProcName, "sTrackTimeResponse=" + sTrackTimeResponse + ", setting aAud(" + getAudLabel(nAudPtr) + ")\nRelFilePos=" + nNewRelFilePos)
              \nRelFilePos = nNewRelFilePos
              \nPlayingPos = nNewRelFilePos
              If \nRelFilePos < 0
                \nRelFilePos = 0
                \nPlayingPos = \nRelFilePos
              ElseIf \nRelFilePos > \nRelPassEnd
                \nRelFilePos = \nRelPassEnd
                \nPlayingPos = \nRelFilePos
              EndIf
            EndIf
          EndIf
        EndWith
      EndIf
    EndIf
  Next n
  
EndProcedure

Procedure.f getSMSGain(sPXChan.s)
  PROCNAMEC()
  ; NB also used for input/output crosspoints, ie X as well as PX
  Protected n1, n2, n3, fGain.f
  Protected sMyPXChan.s, sMyGainResponse.s, sMyGainField.s
  
  If Len(Trim(sPXChan)) = 0
    ProcedureReturn 0.0
  EndIf
  
  fGain = -1.0     ; -1 means no 'gain' entry found for this sPXChan
  sMyPXChan = StringField(sPXChan, 1, " ")
  sMyGainResponse = LCase(RemoveString(grSMS\sPXGainResponse,Chr(13)) + " ")
  n1 = FindString(sMyGainResponse, LCase(sMyPXChan), 1)
  If n1 > 0
    n2 = FindString(sMyGainResponse, "=", n1)
    n3 = FindString(sMyGainResponse, " ", n2)
    sMyGainField = Mid(sMyGainResponse, n2 + 1, n3 - n2 - 1)
    If sMyGainField
      fGain = convertDBStringToBVLevel(sMyGainField)
      ; debugMsgSMS(sProcName,"sMyGainResponse=" + sMyGainResponse + ", GaindB sPXChan=" + sPXChan + ", sMyGainField=" + sMyGainField + ", fGain=" + traceLevel(fGain))
    EndIf
  EndIf
  
  CompilerIf #cTraceGetLevels
    debugMsgSMS(sProcName, "sPXChan=" + sPXChan + ", sMyGainResponse=" + Trim(sMyGainResponse) + ", n1=" + n1 + ", n2=" + n2 + ", n3=" + n3 + ", sMyGainField=" + sMyGainField + ", fGain=" + makeSMSGainString(fGain))
  CompilerEndIf
  ProcedureReturn fGain
  
EndProcedure

Procedure.s getSMSGainString(sPXChan.s)
  PROCNAMEC()
  Protected n1, n2, n3, nPtr
  Protected sMyPXChan.s, sMyGainResponse.s, sMyGainField.s
  
  If Len(Trim(sPXChan)) = 0
    ProcedureReturn ""
  EndIf
  
  sMyPXChan = StringField(sPXChan, 1, " ")
  sMyGainResponse = LCase(RemoveString(grSMS\sPXGainResponse,Chr(13))) + " "
  n1 = FindString(sMyGainResponse, LCase(sMyPXChan), 1)
  If n1 > 0
    n2 = FindString(sMyGainResponse, "=", n1)
    n3 = FindString(sMyGainResponse, " ", n2)
    sMyGainField = Mid(sMyGainResponse, n2 + 1, n3 - n2 - 1)
    nPtr = FindString(sMyGainField, ";", 1)
    If nPtr > 0
      sMyGainField = Left(sMyGainField, nPtr - 1)
    EndIf
  EndIf
  
  ; debugMsgSMS(sProcName, "sPXChan=" + sPXChan + ", sMyGainResponse=" + Trim(sMyGainResponse) + ", n1=" + n1 + ", n2=" + n2 + ", n3=" + Str(n3) + ", sMyGainField=" + sMyGainField)
  ProcedureReturn Trim(sMyGainField)    ; nb will be "" if no 'gain' entry found for this sPXChan
  
EndProcedure

Procedure freeOnePlaybackChanList(sPChanList.s, bIssueStopCommand)
  PROCNAMEC()
  Protected sMyPChanList.s, sPChan.s
  Protected n, nChan, nPtr, nAudPtr
  
  debugMsgSMS(sProcName, #SCS_START + ", sPChanList=" + sPChanList)
  
  sMyPChanList = Trim(sPChanList)
  If Len(sMyPChanList) > 0
    If bIssueStopCommand
      ; stop the file
      sendSMSCommand("stop " + sMyPChanList)
    EndIf
    ; clear the playback entry from gaPlayback()
    n = 1
    sPChan = Trim(StringField(sMyPChanList, n, " "))
    While Len(sPChan) > 0
      If LCase(Left(sPChan, 1)) = "p"
        nChan = Val(Mid(sPChan, 2))   ; extract channel number after "p", eg "p23" returns 23
        If nChan <= ArraySize(gaPlayback())
          gaPlayback(nChan)\nAssignedTo = #SCS_PLB_UNASSIGNED
          debugMsgSMS(sProcName, "gaPlayback(" + nChan + ")\nAssignedTo=#SCS_PLB_UNASSIGNED")
          nAudPtr = gaPlayback(nChan)\nAudPtr
          If nAudPtr > 0
            aAud(nAudPtr)\nSMSPChanCount = 0
          EndIf
          gaPlayback(nChan)\nAudPtr = -1
        EndIf
        clearPChanResponses(nChan)
      EndIf
      n + 1
      sPChan = Trim(StringField(sMyPChanList, n, " "))
    Wend
  EndIf
  
EndProcedure

Procedure.s extractSMSChanItem(sResponse.s, sChan.s)
  ; extracts the response for a nominated channel
  ; eg if sResponse contains "TrackStatus P3=STOP P4=PLAY P5=STOP" and sChan contains "P4" Sub returns "PLAY"
  PROCNAMEC()
  Protected sReply.s, nPtr
  
  If Len(Trim(sChan)) > 0
    nPtr = FindString(sResponse, UCase(sChan + "="), 1)
    If nPtr > 0
      nPtr + Len(sChan) + 1 ; step over sChan + "="
      sReply = StringField(Mid(sResponse, nPtr), 1, " ")
      nPtr = FindString(sReply, ";", 1)
      If nPtr > 0
        sReply = Left(sReply, nPtr - 1)
      EndIf
    EndIf
  EndIf
  ;debugMsgSMS(sProcName, "sResponse=" + sResponse + ", sChan=" + sChan + ", sReply=" + sReply)
  ProcedureReturn sReply
  
EndProcedure

Procedure.s getPlayableFile(sFileName.s, bOKForSMS, bPreviewing = #False)
  PROCNAMEC()
  Protected sPlayableFileName.s, sFilePart.s
  Protected bPlayableFile, bKeep, n
  Protected bListToBeSaved
  Protected sSourceFileModified.s, qSourceFileSize.q
  Protected sEncFilesIndexName.s
  Protected nFileIndex
  
  debugMsgSMS(sProcName, #SCS_START + ", sFileName=" + sFileName + ", bOKForSMS=" + strB(bOKForSMS))
  
  If bPreviewing
    bKeep = #False
  Else
    bKeep = #True
  EndIf
  
  If gbUseBASS ; BASS
    sPlayableFileName = sFileName
    
  Else  ; SM-S
    sEncFilesIndexName = gsEncFilesPath + #SCS_ENCFILESINDEX_NAME
    
    If grSMS\bEncFilesIndexLoaded = #False
      readXMLEncFilesIndex()
      grSMS\bEncFilesIndexLoaded = #True
    EndIf
    
    If FileExists(sFileName)
      qSourceFileSize = FileSize(sFileName)
      sSourceFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
    EndIf
    
    debugMsgSMS(sProcName, "gnEncodedFileCount=" + Str(gnEncodedFileCount))
    For nFileIndex = 0 To (gnEncodedFileCount - 1)
      With glEncodedFileInfo(nFileIndex)
        ; debugMsgSMS(sProcName, "glEncodedFileInfo(" + Str(nFileIndex) + ")\sSourceFile=" + \sSourceFile)
        ; debugMsgSMS(sProcName, "sFileName=" + sFileName)
        ; debugMsgSMS(sProcName, "\sEncodedFile=" + \sEncodedFile)
        ; debugMsgSMS(sProcName, "\sSourceModified=" + \sSourceModified + ", sSourceFileModified=" + sSourceFileModified)
        ; debugMsgSMS(sProcName, "\qSourceSize=" + Str(\qSourceSize) + ", qSourceFileSize=" + Str(qSourceFileSize))
        If LCase(\sSourceFile) = LCase(sFileName) And \sSourceModified = sSourceFileModified And \qSourceSize = qSourceFileSize
          debugMsgSMS(sProcName, "matched")
          sPlayableFileName = \sEncodedFile
          If FileExists(sPlayableFileName)
            debugMsgSMS(sProcName, "file already in glEncodedFileInfo(): " + sFileName)
            If bKeep
              If \bKeep = #False
                \bKeep = #True
                grMMedia\bEncodedFileInfoListChanged = #True
                bListToBeSaved = #True
              EndIf
            EndIf
            Break
          Else
            debugMsgSMS(sProcName, "Not found: " + sPlayableFileName)
            sPlayableFileName = ""
            \sSourceFile = ""
            \sSourceModified = ""
            \qSourceSize = 0
            \sEncodedFile = ""
            grMMedia\bEncodedFileInfoListChanged = #True
            bListToBeSaved = #True
          EndIf
        EndIf
      EndWith
    Next nFileIndex
    
    If Len(sPlayableFileName) = 0
      ; we do not yet have an encoded file for this source file
      ; check if there may be another already-encoded instance of an identical file
      sFilePart = GetFilePart(sFileName)
      For nFileIndex = 0 To (gnEncodedFileCount - 1)
        With glEncodedFileInfo(nFileIndex)
          If \sFilePart = sFilePart
            sPlayableFileName = \sEncodedFile
            If FileExists(sPlayableFileName)
              If compareFiles(sFileName, \sSourceFile)
                ; source files identical, so use this encoded file
                debugMsgSMS(sProcName, "files identical: " + sFileName + ", " + \sSourceFile)
                If bKeep
                  If \bKeep = #False
                    \bKeep = #True
                    grMMedia\bEncodedFileInfoListChanged = #True
                    bListToBeSaved = #True
                  EndIf
                EndIf
                Break
              EndIf
            Else
              sPlayableFileName = ""
              \sSourceFile = ""
              \sSourceModified = ""
              \qSourceSize = 0
              \sEncodedFile = ""
              grMMedia\bEncodedFileInfoListChanged = #True
              bListToBeSaved = #True
            EndIf
          EndIf
        EndWith
      Next nFileIndex
    EndIf
    
    If Len(sPlayableFileName) = 0
      ; we do not yet have an encoded file for this source file
      ; try to use an encoded filename using the same file part (except for the extension)
      sPlayableFileName = gsEncFilesPath + ignoreExtension(GetFilePart(sFileName)) + ".wav"
      If FileExists(sPlayableFileName)
        ; an encoded file with that name already exists - check if the source files are identical
        ; that encoded filename has already been taken, so add a numeric suffix and try until we get a unique name
        n = 2
        sPlayableFileName = gsEncFilesPath + ignoreExtension(GetFilePart(sFileName)) + "_" + Trim(Str(n)) + ".wav"
        While FileExists(sPlayableFileName)
          n + 1
          sPlayableFileName = gsEncFilesPath + ignoreExtension(GetFilePart(sFileName)) + "_" + Trim(Str(n)) + ".wav"
        Wend
      Else
        ; that encoded filename has not yet been taken, so use that
      EndIf
      debugMsgSMS(sProcName, "sPlayableFileName=" + GetFilePart(sPlayableFileName) + ", bOKForSMS=" + strB(bOKForSMS))
      ; we now have either the initial encoded file name (eg test.wav for test.mp3) or a modifed version of that name (eg test_2.wav)
      If bOKForSMS
        CopyFile(sFileName, sPlayableFileName)
        bPlayableFile = FileExists(sPlayableFileName)
      Else
        bPlayableFile = convertAudioFileToWAV(sFileName, sPlayableFileName)
      EndIf
      If bPlayableFile
        debugMsgSMS(sProcName, "converted OK")
        ; converted ok
        gnEncodedFileCount = gnEncodedFileCount + 1
        If gnEncodedFileCount > ArraySize(glEncodedFileInfo())
          ReDim glEncodedFileInfo(gnEncodedFileCount + 20)
        EndIf
        With glEncodedFileInfo(gnEncodedFileCount - 1)
          \sSourceFile = sFileName
          \sSourceModified = sSourceFileModified
          \qSourceSize = qSourceFileSize
          \sEncodedFile = sPlayableFileName
          \bKeep = bKeep
        EndWith
        grMMedia\bEncodedFileInfoListChanged = #True
        bListToBeSaved = #True
      EndIf
    EndIf
    
    If bListToBeSaved
      saveXMLEncFilesIndex()
      debugMsgSMS(sProcName, "saved " + GetFilePart(sEncFilesIndexName))
    EndIf
    
  EndIf
  
  debugMsgSMS(sProcName, #SCS_END + ", returning " + sPlayableFileName)
  ProcedureReturn sPlayableFileName
  
EndProcedure

Procedure saveXMLEncFilesIndex()
  PROCNAMEC()
  Protected xmlEncFiles
  Protected *nRootNode, *nEncFileNode
  Protected n
  Protected sFile.s
  Protected nResult
  
  debugMsgSMS(sProcName, #SCS_START)
  
  ; Create xml tree
  xmlEncFiles = CreateXML(#PB_Any)
  *nRootNode = CreateXMLNode(RootXMLNode(xmlEncFiles), "EncFiles")
  
  For n = 0 To gnEncodedFileCount
    With glEncodedFileInfo(n)
      If Len(\sEncodedFile) > 0 And \bKeep = #True
        *nEncFileNode = addXMLNode(*nRootNode, "EncFile")
        addXMLItem(*nEncFileNode, "SourceFile", \sSourceFile)
        addXMLItem(*nEncFileNode, "SourceModified", \sSourceModified)
        addXMLItem(*nEncFileNode, "SourceSize", Str(\qSourceSize))
        addXMLItem(*nEncFileNode, "EncodedFile", GetFilePart(\sEncodedFile))
      EndIf
    EndWith
  Next n
  
  sFile = gsEncFilesPath + #SCS_ENCFILESINDEX_NAME
  debugMsgSMS(sProcName, "saving " + sFile)
  nResult = saveFormattedXML(xmlEncFiles, sFile)
  debugMsgSMS(sProcName, "saveFormattedXML(" + Str(xmlEncFiles) + ", " + sFile + ") returned" + strB(nResult))
  
  FreeXML(xmlEncFiles)
  
EndProcedure

Procedure scanXMLEncFilesIndex(*CurrentNode, CurrentSublevel)
  ; PROCNAMEC()
  Protected sNodeName.s, sNodeText.s
  Protected sParentNodeName.s
  Protected sAttributeName.s, sAttributeValue.s
  Static nEncFilePtr
  Protected *nChildNode
  
  ; debugMsgSMS(sProcName, #SCS_START + ", *CurrentNode=" + *CurrentNode + ", CurrentSublevel=" + CurrentSublevel + ", XMLNodeType(*CurrentNode)=" + XMLNodeType(*CurrentNode) + ", #PB_XML_Normal=" + #PB_XML_Normal)
  
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
        Break ; no more than one attribute is used for XML nodes in the Prod Devices file
      Wend
    EndIf
    
    ; debugMsgSMS(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText)
    Select sNodeName
      Case "EncFiles"
        gnEncodedFileCount = 0
        ReDim glEncodedFileInfo(20)
        
      Case "EncFile"
        gnEncodedFileCount + 1
        nEncFilePtr = gnEncodedFileCount - 1
        If nEncFilePtr > ArraySize(glEncodedFileInfo())
          ReDim glEncodedFileInfo(nEncFilePtr+20)
        EndIf
        With glEncodedFileInfo(nEncFilePtr)
          \bKeep = #True
          \sEncodedFile = ""
          \sFilePart = ""
          \sSourceFile = ""
          \sSourceModified = ""
          \qSourceSize = 0
        EndWith
        
      Case "SourceFile"
        glEncodedFileInfo(nEncFilePtr)\sSourceFile = sNodeText
        
      Case "SourceModified"
        glEncodedFileInfo(nEncFilePtr)\sSourceModified = sNodeText
        
      Case "SourceSize"
        glEncodedFileInfo(nEncFilePtr)\qSourceSize = Val(sNodeText)
        
      Case "EncodedFile"
        glEncodedFileInfo(nEncFilePtr)\sEncodedFile = gsEncFilesPath + sNodeText
        
      Case "/EncFile"
        ; no action
        
    EndSelect
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      scanXMLEncFilesIndex(*nChildNode, CurrentSublevel + 1)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
  EndIf
  
EndProcedure

Procedure readXMLEncFilesIndex()
  PROCNAMEC()
  Protected sFile.s
  Protected xmlEncFiles
  Protected sMsg.s
  Protected *nRootNode
  
  debugMsgSMS(sProcName, #SCS_START)
  
  sFile = gsEncFilesPath + #SCS_ENCFILESINDEX_NAME
  debugMsgSMS(sProcName, "sFile=" + sFile)
  
  gnEncodedFileCount = 0
  ReDim glEncodedFileInfo(20)
  If FileExists(sFile)
    debugMsgSMS(sProcName, "File exists")
  Else
    debugMsgSMS(sProcName, "File does NOT exist")
    ProcedureReturn
  EndIf
  
  xmlEncFiles = LoadXML(#PB_Any, sFile)
  If xmlEncFiles
    ; Display an error message if there was a markup error
    If XMLStatus(xmlEncFiles) <> #PB_XML_Success
      sMsg = "Error in the XML file " + GetFilePart(sFile) + ":" + #CR$
      sMsg + "Message: " + XMLError(xmlEncFiles) + #CR$
      sMsg + "Line: " + XMLErrorLine(xmlEncFiles) + "   Character: " + XMLErrorPosition(xmlEncFiles)
      debugMsgSMS(sProcName, sMsg)
      scsMessageRequester(grText\sTextError, sMsg)
    Else
      *nRootNode = MainXMLNode(xmlEncFiles)      
      If *nRootNode
        scanXMLEncFilesIndex(*nRootNode, 0)
      EndIf
    EndIf
    FreeXML(xmlEncFiles)
  EndIf
  
EndProcedure

Procedure compareFiles(sFileName1.s, sFileName2.s)
  Protected qLen1.q, qLen2.q
  Protected sMD51.s, sMD52.s
  
  qLen1 = FileSize(sFileName1)
  qLen2 = FileSize(sFileName2)
  If (qLen1 <> qLen2) Or (qLen1 < 0)  ; if FileSize < 0 then file is not found or is a directory (see PB Help)
    ProcedureReturn #False
  EndIf
  
  sMD51 = FileFingerprint(sFileName1, #PB_Cipher_MD5)
  sMD52 = FileFingerprint(sFileName2, #PB_Cipher_MD5)
  If sMD51 <> sMD52
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure openFileForSMS(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nAssignResult, nPrimaryChan, nAltPrimaryChan
  Protected d, nLogicalDevPtr
  Protected sTmp.s
  Protected sDevPXChanListLeft.s, sDevPXChanListRight.s, sAudPXChanList.s
  Protected sAltDevPXChanListLeft.s, sAltDevPXChanListRight.s, sAltAudPXChanList.s
  Protected sAudSetGainCommandString.s, sSetCommandItem.s, sLevelInfo.s, sFinalSetCommandItem.s
  Protected fReqdBVLevel.f, fReqdPan.f, nReqdFadeInTime, fReqdSpeed.f
  Protected sTrackLength.s, sTrackSampleRate.s
  Protected bFirstTime, bAltFirstTime
  Protected nResult
  Protected sField1.s, sField2.s, sField3.s, sField4.s
  Protected sDevPXDownMix.s, sAltDevPXDownMix.s, fReqdDBLevel.f
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    ; send command(s) to SM-S to assign file tracks to playback channel(s)
    If GetInfoAboutFile(\sFileName)
      \nFileChannels = grInfoAboutFile\nFileChannels
      \sFileType = grInfoAboutFile\sFileInfo
      \bOKForSMS = grInfoAboutFile\bOKForSMS
      \qFileBytes = grInfoAboutFile\qFileBytes
      \qFileBytesForTenSecs = grInfoAboutFile\qFileBytesForTenSecs
      \nBytesPerSamplePos = grInfoAboutFile\nBytesPerSamplePos
    EndIf
    debugMsgSMS(sProcName, "\bOKForSMS=" + strB(\bOKForSMS))
    If \bOKForSMS
      If grDriverSettings\bSMSOnThisMachine
        ; SM-S is on the same machine as SCS so can see all files that SCS can see, so no need to check if the file is under Audio Root Folder
        \sPlayableFileName = \sFileName
      ElseIf gsAudioFilesRootFolder
        If Left(\sFileName, Len(gsAudioFilesRootFolder)) = gsAudioFilesRootFolder
          ; file is within audio files root folder
          \sPlayableFileName = \sFileName
        Else
          ; file is not within audio files root folder
          \sPlayableFileName = getPlayableFile(\sFileName, grBCI\bOKForSMS)
        EndIf
      Else
        \sPlayableFileName = \sFileName
      EndIf
    Else
      \sPlayableFileName = getPlayableFile(\sFileName, grBCI\bOKForSMS)
    EndIf
    nAssignResult = assignFileTracksToPlaybacks(pAudPtr, \sPlayableFileName, \nFileChannels, #SCS_PLB_NORMAL)
    debugMsgSMS(sProcName, "assignFileTracksToPlaybacks(" + getAudLabel(pAudPtr) + ", " + GetFilePart(\sPlayableFileName) + ", " + \nFileChannels + ", #SCS_PLB_NORMAL) returned " + nAssignResult)
  EndWith
  
  If nAssignResult = -2
    ; SM-S failed to open the file
    ProcedureReturn -2
  EndIf
  If nAssignResult = -1
    ; insufficient playback channels available so cannot open the file
    aAud(pAudPtr)\bInsufficientSMSPlaybacks = #True
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bInsufficientSMSPlaybacks=" + strB(aAud(pAudPtr)\bInsufficientSMSPlaybacks))
    ProcedureReturn -1
  Else
    aAud(pAudPtr)\bInsufficientSMSPlaybacks = #False
  EndIf
  
  With aAud(pAudPtr)
    nPrimaryChan = nAssignResult & $FFFF
    If usingLoopXFade(pAudPtr)
      nAltPrimaryChan = nAssignResult >> 16 ; \ &H10000
    Else
      nAltPrimaryChan = -1
    EndIf
    debugMsgSMS(sProcName, "nAssignResult=" + nAssignResult + " $" + Hex(nAssignResult,#PB_Long) + ", nPrimaryChan=" + nPrimaryChan + ", nAltPrimaryChan=" + Str(nAltPrimaryChan))
    \nPrimaryChan = nPrimaryChan
    \sPPrimaryChan = "p" + nPrimaryChan
    \sAudPChanList = gaPlayback(nPrimaryChan)\sPChanListPrimary
    \nAltPrimaryChan = nAltPrimaryChan
    If nAltPrimaryChan >= 0
      \sAltPPrimaryChan = "p" + Trim(Str(nAltPrimaryChan))
      \sAltAudPChanList = gaPlayback(nAltPrimaryChan)\sPChanListPrimary
    Else
      \sAltPPrimaryChan = ""
      \sAltAudPChanList = ""
    EndIf
    debugMsgSMS(sProcName, "\nPrimaryChan=" + \nPrimaryChan + ", \nAltPrimaryChan=" + \nAltPrimaryChan +
                           ", \sPPrimaryChan=" + \sPPrimaryChan + ", \sAltPPrimaryChan=" + \sAltPPrimaryChan +
                           ", \sAudPChanList=" + \sAudPChanList + ", \sAltAudPChanList=" + \sAltAudPChanList)
    
    sendSMSCommand("get chan " + \sPPrimaryChan + " track length")
    If grSMS\sFirstWordLC = "tracklength"
      sTrackLength = Trim(StringField(getSMSResponseField(1, 2), 2, "="))
      debugMsgSMS(sProcName, "sTrackLength=" + sTrackLength)
      If IsNumeric(sTrackLength)
        \nFileDuration = ValF(sTrackLength) * 1000
      Else
        \nFileDuration = 0
      EndIf
    EndIf
    
    sendSMSCommand("get chan " + \sPPrimaryChan + " track samplerate")
    If grSMS\sFirstWordLC = "tracksr"   ; nb SM-S returned "TrackSR", not "TrackSampleRate"
      sTrackSampleRate = Trim(StringField(getSMSResponseField(1, 2), 2, "="))
      debugMsgSMS(sProcName, "sTrackSampleRate=" + sTrackSampleRate)
      If IsNumeric(sTrackSampleRate)
        \nSampleRate = Val(sTrackSampleRate)
      Else
        \nSampleRate = 0
      EndIf
    Else
      \nSampleRate = 0
    EndIf
    
    If grLicInfo\bTempoAndPitchAvailable
      If \nAudTempoEtcAction = #SCS_AF_ACTION_FREQ
        If \fAudTempoEtcValue <> grAudDef\fAudTempoEtcValue
          If \nSampleRate > 0
            fReqdSpeed = \fAudTempoEtcValue
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fAudTempoEtcValue=" + StrF(\fAudTempoEtcValue,2) + ", fReqdSpeed=" + StrF(fReqdSpeed,2))
            ; Apply abitrary limits that equate to the BASS_FX freq limits - same limits applied in setAudTempoEtcForLvlChgSub()
            If fReqdSpeed < 0.05
              fReqdSpeed = 0.05
            ElseIf fReqdSpeed > 50
              fReqdSpeed = 50
            EndIf
            sendSMSCommand("set chan " + \sPPrimaryChan + " track speed " + StrF(fReqdSpeed,2))
          EndIf
        EndIf
      EndIf
    EndIf              
    
    \bSetLevelsWhenPlayAud = #False
    
    If \bAudTypeF
      debugMsgSMS(sProcName, "\nFirstDev=" + \nFirstDev + ", \nLastDev=" + \nLastDev)
      bFirstTime = #True
      bAltFirstTime = #True
      sFinalSetCommandItem = ""
      For d = \nFirstDev To \nLastDev
        ; debugMsgSMS(sProcName, "\sLogicalDev[" + d + "]=" + \sLogicalDev[d] + ", \bIgnoreDev[" + d + "]=" + strB(\bIgnoreDev[d]))
        If (\sLogicalDev[d]) And (\bIgnoreDev[d] = #False)
          nLogicalDevPtr = getProdLogicalDevPtrForLogicalDev(\sLogicalDev[d])
          ; debugMsgSMS(sProcName, "\sLogicalDev(" + d + ")=" + \sLogicalDev[d] + ", nLogicalDevPtr=" + nLogicalDevPtr)
          If nLogicalDevPtr >= 0
            ; debugMsgSMS(sProcName, "calling buildPXChanList(" + decodeHandle(nPrimaryChan) + ", " + nLogicalDevPtr + ", " + \sTracks[d] + ")")
            sTmp = buildPXChanList(nPrimaryChan, nLogicalDevPtr, \sTracks[d])
            sDevPXChanListLeft = Trim(StringField(sTmp, 1, "|"))
            sDevPXChanListRight = Trim(StringField(sTmp, 2, "|"))
            sDevPXDownMix = Trim(StringField(sTmp, 3, "|"))
            sDevPXChanListLeft = splitDuplicatePXChans(pAudPtr, sDevPXChanListLeft, bFirstTime, #False)
            sDevPXChanListLeft = silenceDuplicatePXChans(sDevPXChanListLeft, bFirstTime)  ; silence any remaining duplicates
            bFirstTime = #False
            sDevPXChanListRight = splitDuplicatePXChans(pAudPtr, sDevPXChanListRight, bFirstTime, #False)
            sDevPXChanListRight = silenceDuplicatePXChans(sDevPXChanListRight, bFirstTime)
            \sDevPXChanListLeft[d] = sDevPXChanListLeft
            \sDevPXChanListRight[d] = sDevPXChanListRight
            \sDevPXDownMix[d] = sDevPXDownMix
            ; debugMsgSMS(sProcName, "\sDevPXChanListLeft[" + d + "]=" + \sDevPXChanListLeft[d] + ", \sDevPXChanListRight[" + d + "]=" + \sDevPXChanListRight[d] +
            ;                        ", \sDevPXDownMix[" + d + "]=" + \sDevPXDownMix[d])
            sAudPXChanList = sAudPXChanList + " " + sDevPXChanListLeft
            If Len(sDevPXChanListRight) > 0
              sAudPXChanList + " " + sDevPXChanListRight
              \bDisplayPan[d] = #True
            Else
              \bDisplayPan[d] = #False     ; pan not available for mono or >2 channels
            EndIf
            If \bAudTypeP
              aSub(\nSubIndex)\bSubDisplayPan[d] = \bDisplayPan[d]
            EndIf
            
            If nAltPrimaryChan >= 0
              ; debugMsgSMS(sProcName, "calling buildPXChanList(" + decodeHandle(nAltPrimaryChan) + ", " + nLogicalDevPtr + ", " + \sTracks[d] + ")")
              sTmp = buildPXChanList(nAltPrimaryChan, nLogicalDevPtr, \sTracks[d])
              ; debugMsgSMS(sProcName, "sTmp=" + sTmp)
              sAltDevPXChanListLeft = Trim(StringField(sTmp, 1, "|"))
              sAltDevPXChanListRight = Trim(StringField(sTmp, 2, "|"))
              sAltDevPXDownMix = Trim(StringField(sTmp, 3, "|"))
              sAltDevPXChanListLeft = splitDuplicatePXChans(pAudPtr, sAltDevPXChanListLeft, bAltFirstTime, #True)
              sAltDevPXChanListLeft = silenceDuplicatePXChans(sAltDevPXChanListLeft, bAltFirstTime)
              bAltFirstTime = #False
              sAltDevPXChanListRight = splitDuplicatePXChans(pAudPtr, sAltDevPXChanListRight, bAltFirstTime, #True)
              sAltDevPXChanListRight = silenceDuplicatePXChans(sAltDevPXChanListRight, bAltFirstTime)
              \sAltDevPXChanListLeft[d] = sAltDevPXChanListLeft
              \sAltDevPXChanListRight[d] = sAltDevPXChanListRight
              \sAltDevPXDownMix[d] = sAltDevPXDownMix
              ; debugMsgSMS(sProcName, "\sAltDevPXChanListLeft[" + d + "]=" + \sAltDevPXChanListLeft[d] + ", \sAltDevPXChanListRight[" + d + "]=" + \sAltDevPXChanListRight[d] +
              ;                        ", \sAltDevPXDownMix[" + d + "]=" + \sAltDevPXDownMix[d])
              sAltAudPXChanList + " " + sAltDevPXChanListLeft
              If Len(sAltDevPXChanListRight) > 0
                sAltAudPXChanList + " " + sAltDevPXChanListRight
              EndIf
            EndIf
            
            ; add entry or entries to sAudSetGainCommandString to set levels and fadein for each playback crosspoint
            If \bCueVolManual[d] = #False
              If \nFadeInTime > 0
                \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
                \bSetLevelsWhenPlayAud = #True
              Else
                \fCueVolNow[d] = \fBVLevel[d]
              EndIf
              ; debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bSetLevelsWhenPlayAud=" + strB(\bSetLevelsWhenPlayAud))
              fReqdBVLevel = \fBVLevel[d]
              nReqdFadeInTime = \nFadeInTime
              \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
              \fCueTotalVolNow[d] = \fCueVolNow[d]
              ; debugMsgSMS(sProcName, "\fCueTotalVolNow(" + d + ")=" + formatLevel(\fCueTotalVolNow[d]))
            Else
              fReqdBVLevel = \fCueVolNow[d]
              nReqdFadeInTime = 0
            EndIf
            
            If \bCuePanManual[d] = #False
              \fCuePanNow[d] = \fPan[d]
            EndIf
            fReqdPan = \fCuePanNow[d]
            
            If fReqdBVLevel > #SCS_MINVOLUME_SINGLE
              sLevelInfo = setLevelsForSMSOutputDev(pAudPtr, d, fReqdBVLevel, fReqdPan, nReqdFadeInTime, \nFadeInType)
              ; debugMsgSMS(sProcName, "d=" + d + ", sLevelInfo=" + sLevelInfo)
              ; debugMsgSMS(sProcName, "fReqdBVLevel=" + formatLevel(fReqdBVLevel) + ", dB=" + convertBVLevelToDBString(fReqdBVLevel) + ", fReqdPan=" + StrF(fReqdPan,3))
              sField1 = StringField(sLevelInfo, 1, "|")
              sField2 = StringField(sLevelInfo, 2, "|")
              sField3 = StringField(sLevelInfo, 3, "|")
              sField4 = StringField(sLevelInfo, 4, "|")
              If fReqdPan = #SCS_PANCENTRE_SINGLE
                sSetCommandItem = " chan " + sDevPXChanListLeft + " " + sDevPXChanListRight + " " + sField1
                If Len(sField3) > 0
                  sFinalSetCommandItem + " chan " + sDevPXChanListLeft + " " + sDevPXChanListRight + " " + sField3
                EndIf
              Else
                sSetCommandItem = " chan " + sDevPXChanListLeft + " " + sField1
                If Len(sDevPXChanListRight) > 0
                  sSetCommandItem + " chan " + sDevPXChanListRight + " " + sField2
                EndIf
                If Len(sField3) > 0
                  sFinalSetCommandItem + " chan " + sDevPXChanListLeft + " " + sField3
                  If Len(sDevPXChanListRight) > 0
                    sFinalSetCommandItem + " chan " + sDevPXChanListRight + " " + sField4
                  EndIf
                EndIf
              EndIf
              ; debugMsgSMS(sProcName, "sSetCommandItem=" + sSetCommandItem)
;               If Len(sFinalSetCommandItem) > 0
;                 debugMsgSMS(sProcName, "sFinalSetCommandItem=" + sFinalSetCommandItem)
;               EndIf
              sAudSetGainCommandString + sSetCommandItem
            EndIf
            
          EndIf
        EndIf
      Next d
      \sAudFinalSetGainCommandString = sFinalSetCommandItem   ; nb may be blank
      ; debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sPPrimaryChan=" + \sPPrimaryChan + ", \sAudPChanList=" + \sAudPChanList + ", \sAudFinalSetGainCommandString=" + \sAudFinalSetGainCommandString)
      ; debugMsgSMS(sProcName, "calling setNextCueMarker(" + getAudLabel(pAudPtr) + ", 0)")
      setNextCueMarker(pAudPtr, 0)
      
    ElseIf \bAudTypeP
      bFirstTime = #True
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If aSub(\nSubIndex)\sPLLogicalDev[d]
          nLogicalDevPtr = getProdLogicalDevPtrForLogicalDev(aSub(\nSubIndex)\sPLLogicalDev[d])
          If nLogicalDevPtr >= 0
            ; debugMsgSMS(sProcName, "calling buildPXChanList(" + decodeHandle(nPrimaryChan) + ", " + nLogicalDevPtr + ", " + aSub(\nSubIndex)\sPLTracks[d] + ")")
            sTmp = buildPXChanList(nPrimaryChan, nLogicalDevPtr, aSub(\nSubIndex)\sPLTracks[d])
            ;debugMsgSMS(sProcName, "sTmp=" + sTmp)
            sDevPXChanListLeft = Trim(StringField(sTmp, 1, "|"))
            sDevPXChanListRight = Trim(StringField(sTmp, 2, "|"))
            sDevPXChanListLeft = splitDuplicatePXChans(pAudPtr, sDevPXChanListLeft, bFirstTime, #False)
            sDevPXChanListLeft = silenceDuplicatePXChans(sDevPXChanListLeft, bFirstTime)  ; silence any remaining duplicates
            bFirstTime = #False
            sDevPXChanListRight = splitDuplicatePXChans(pAudPtr, sDevPXChanListRight, bFirstTime, #False)
            sDevPXChanListRight = silenceDuplicatePXChans(sDevPXChanListRight, bFirstTime)
            \sDevPXChanListLeft[d] = sDevPXChanListLeft
            \sDevPXChanListRight[d] = sDevPXChanListRight
            sAudPXChanList + " " + sDevPXChanListLeft
            If sDevPXChanListRight
              sAudPXChanList + " " + sDevPXChanListRight
              \bDisplayPan[d] = #True
            Else
              \bDisplayPan[d] = #False     ; pan not available for mono or >2 channels
            EndIf
            aSub(\nSubIndex)\bSubDisplayPan[d] = \bDisplayPan[d]
            
            ; add entry or entries to sAudSetGainCommandString to set levels and fadein for each playback crosspoint
            If \bCueVolManual[d] = #False
              If \nFadeInTime > 0
                \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
                \bSetLevelsWhenPlayAud = #True
              Else
                \fCueVolNow[d] = \fBVLevel[d]
              EndIf
              debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bSetLevelsWhenPlayAud=" + strB(\bSetLevelsWhenPlayAud))
              fReqdBVLevel = \fBVLevel[d]
              nReqdFadeInTime = \nFadeInTime
              \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
              \fCueTotalVolNow[d] = \fCueVolNow[d]
              debugMsgSMS(sProcName, "\fCueTotalVolNow(" + d + ")=" + formatLevel(\fCueTotalVolNow[d]))
            Else
              fReqdBVLevel = \fCueVolNow[d]
              nReqdFadeInTime = 0
            EndIf
            \bSetLevelsWhenPlayAud = #True
            debugMsgSMS(sProcName, "\bSetLevelsWhenPlayAud=" + strB(\bSetLevelsWhenPlayAud))
            
            If \bCuePanManual[d] = #False
              \fCuePanNow[d] = \fPan[d]
            EndIf
            fReqdPan = \fCuePanNow[d]
            
            If fReqdBVLevel > #SCS_MINVOLUME_SINGLE
              sLevelInfo = setLevelsForSMSOutputDev(pAudPtr, d, fReqdBVLevel, fReqdPan, nReqdFadeInTime, \nFadeInType)
              debugMsgSMS(sProcName, "d=" + d + ", sLevelInfo=" + sLevelInfo)
              debugMsgSMS(sProcName, "fReqdBVLevel=" + formatLevel(fReqdBVLevel) + ", dB=" + convertBVLevelToDBString(fReqdBVLevel) + ", fReqdPan=" + StrF(fReqdPan,3))
              If fReqdPan = #SCS_PANCENTRE_SINGLE
                sSetCommandItem = " chan " + sDevPXChanListLeft + " " + sDevPXChanListRight + " " + StringField(sLevelInfo, 1, "|")
              Else
                sSetCommandItem = " chan " + sDevPXChanListLeft + " " + StringField(sLevelInfo, 1, "|")
                If Len(sDevPXChanListRight) > 0
                  sSetCommandItem + " chan " + sDevPXChanListRight + " " + StringField(sLevelInfo, 2, "|")
                EndIf
              EndIf
              debugMsgSMS(sProcName, "sSetCommandItem=" + sSetCommandItem)
              sAudSetGainCommandString + sSetCommandItem
            EndIf
            
          EndIf
        EndIf
      Next d
      debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sPPrimaryChan=" + \sPPrimaryChan + ", \sAudPChanList=" + \sAudPChanList)
    EndIf
    
    ; tidy up sAudPXChanList, converting double-spaces to single-spaces, and trimming result
    \sAudPXChanList = Trim(ReplaceString(sAudPXChanList, "  ", " "))
    \sAltAudPXChanList = Trim(ReplaceString(sAltAudPXChanList, "  ", " "))
    debugMsgSMS(sProcName, "\sAudPXChanList=" + \sAudPXChanList + ", \sAltAudPXChanList=" + \sAltAudPXChanList)
    
    ; tidy up sAudSetGainCommandString, converting double-spaces to single-spaces, and trimming result
    \sAudSetGainCommandString = Trim(ReplaceString(sAudSetGainCommandString, "  ", " "))
    ;????\sAltAudSetGainCommandString = Trim(ReplaceString(sAltAudSetGainCommandString, "  ", " "))
    debugMsgSMS(sProcName, "\sAudSetGainCommandString=" + \sAudSetGainCommandString + ", \sAltAudSetGainCommandString=" + \sAltAudSetGainCommandString)
    
    If \bSetLevelsWhenPlayAud
      ; ; initially mute all this Aud's crosspoint channels
      ; sendSMSCommand("set chan " + \sAudPXChanList + " gain 0")
    Else
      If \sAudSetGainCommandString
        sendSMSCommand("set " + \sAudSetGainCommandString)
      EndIf
    EndIf
    
    ; debugCuePtrs()
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
  ProcedureReturn 0
  
EndProcedure

Procedure setGainCommandStringsForInputs(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d, d2, n
  Protected sInputLogicalDev.s, sLogicalDev.s
  Protected nLogicalDevPtr
  Protected nInputDevMapDevPtr, nOutputDevMapDevPtr
  Protected nNrOfInputChans
  Protected nNrOfOutputChans, nFirst0BasedOutputChan
  Protected sAudChanList.s
  Protected sAudXChanList.s
  Protected nAssignResult, nPrimaryChan
  Protected sTmp.s
  Protected sDevXChanListLeft.s, sDevXChanListRight.s
  Protected sAudSetGainCommandString.s, sSetCommandItem.s, sLevelInfo.s, sFinalSetCommandItem.s
  Protected fReqdBVLevel.f, fReqdPan.f, nReqdFadeInTime
  Protected bFirstTime
  Protected nResult
  Protected sField1.s, sField2.s, sField3.s, sField4.s
  Protected bStereoInput, bStereoOutput
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    
    debugMsgSMS(sProcName, "\sAudChanList=" + \sAudChanList + ", \sAudXChanList=" + \sAudXChanList)
    debugMsgSMS(sProcName, "\nFirstInputDev=" + \nFirstInputDev + ", \nLastInputDev=" + \nLastInputDev + ", \nFirstDev=" + \nFirstDev + ", \nLastDev=" + \nLastDev)
    sFinalSetCommandItem = ""
    For d2 = \nFirstInputDev To \nLastInputDev
      If \bInputOff[d2]
        Continue
      EndIf
      nInputDevMapDevPtr = \nInputDevMapDevPtr[d2]
      If nInputDevMapDevPtr >= 0
        If grMaps\aDev(nInputDevMapDevPtr)\nNrOfInputChans = 2
          bStereoInput = #True
        Else
          bStereoInput = #False
        EndIf
        \fCueInputVolNow[d2] = \fInputLevel[d2]
        debugMsgSMS(sProcName, "\fCueInputVolNow[" + d2 + "]=" + traceLevel(\fCueInputVolNow[d2]))
        \fCueInputTotalVolNow[d2] = \fInputLevel[d2]
        
        \bSetLevelsWhenPlayAud = #True  ; ALWAYS set "\bSetLevelsWhenPlayAud = #True" for live inputs as that's how we 'turn on' the inputs
        For d = \nFirstDev To \nLastDev
          debugMsgSMS(sProcName, "\sLogicalDev[" + d + "]=" + \sLogicalDev[d] + ", \bIgnoreDev[" + d + "]=" + strB(\bIgnoreDev[d]))
          If (\sLogicalDev[d]) And (\bIgnoreDev[d] = #False)
            nLogicalDevPtr = getProdLogicalDevPtrForLogicalDev(\sLogicalDev[d])
            debugMsgSMS(sProcName, "\sLogicalDev(" + d + ")=" + \sLogicalDev[d] + ", nLogicalDevPtr=" + nLogicalDevPtr)
            If nLogicalDevPtr >= 0
              nOutputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, \sLogicalDev[d])
              If nOutputDevMapDevPtr < 0
                ; shouldn't happen
                Continue
              EndIf
              If grProd\aAudioLogicalDevs(nLogicalDevPtr)\nNrOfOutputChans = 2
                \bDisplayPan[d] = #True
                bStereoOutput = #True
              Else
                \bDisplayPan[d] = #False     ; pan not available for mono or >2 channels
                bStereoOutput = #False
              EndIf
              
              ; \bSetLevelsWhenPlayAud = #True  ; ALWAYS set "\bSetLevelsWhenPlayAud = #True" for live inputs as that's how we 'turn on' the inputs
              ; add entry or entries to sAudSetGainCommandString to set levels and fadein for each playback crosspoint
              If \bCueVolManual[d] = #False
                If \nFadeInTime > 0
                  \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
                  ; \bSetLevelsWhenPlayAud = #True
                Else
                  \fCueVolNow[d] = \fBVLevel[d]
                EndIf
                debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bSetLevelsWhenPlayAud=" + strB(\bSetLevelsWhenPlayAud))
                fReqdBVLevel = \fBVLevel[d]
                nReqdFadeInTime = \nFadeInTime
                \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
                \fCueTotalVolNow[d] = \fCueVolNow[d]
                debugMsgSMS(sProcName, "\fCueTotalVolNow(" + d + ")=" + formatLevel(\fCueTotalVolNow[d]))
              Else
                fReqdBVLevel = \fCueVolNow[d]
                nReqdFadeInTime = 0
              EndIf
              
              If \bCuePanManual[d] = #False
                \fCuePanNow[d] = \fPan[d]
              EndIf
              fReqdPan = \fCuePanNow[d]
              
              If fReqdBVLevel > #SCS_MINVOLUME_SINGLE
                If bStereoInput And bStereoOutput
                  sDevXChanListLeft = "x" + grMaps\aDev(nInputDevMapDevPtr)\nFirst0BasedInputChanAG + "." + grMaps\aDev(nOutputDevMapDevPtr)\nFirst0BasedOutputChanAG
                  sDevXChanListRight = "x" + Str(grMaps\aDev(nInputDevMapDevPtr)\nFirst0BasedInputChanAG+1) + "." + Str(grMaps\aDev(nOutputDevMapDevPtr)\nFirst0BasedOutputChanAG+1)
                Else
                  sDevXChanListLeft = "x" + grMaps\aDev(nInputDevMapDevPtr)\nFirst0BasedInputChanAG + "." + grMaps\aDev(nOutputDevMapDevPtr)\nFirst0BasedOutputChanAG
                  If grMaps\aDev(nOutputDevMapDevPtr)\nNrOfDevOutputChans = 2
                    sDevXChanListRight = "x" + grMaps\aDev(nInputDevMapDevPtr)\nFirst0BasedInputChanAG + "." + Str(grMaps\aDev(nOutputDevMapDevPtr)\nFirst0BasedOutputChanAG+1)
                  Else
                    sDevXChanListRight = ""
                  EndIf
                EndIf
                If d2 = \nFirstInputDev
                  \sDevXChanListLeft[d] = sDevXChanListLeft
                  \sDevXChanListRight[d] = sDevXChanListRight
                  ; debugMsgSMS(sProcName, "\sDevXChanListLeft[" + d + "]=" + \sDevXChanListLeft[d] + ", \sDevXChanListRight[" + d + "]=" + \sDevXChanListRight[d])
                EndIf
                sLevelInfo = setLevelsForSMSOutputDev(pAudPtr, d, fReqdBVLevel, fReqdPan, nReqdFadeInTime, \nFadeInType, d2)
                debugMsgSMS(sProcName, "d=" + d + ", sLevelInfo=" + sLevelInfo + ", fReqdBVLevel=" + formatLevel(fReqdBVLevel) + ", dB=" + convertBVLevelToDBString(fReqdBVLevel) + ", fReqdPan=" + StrF(fReqdPan,3))
                sField1 = StringField(sLevelInfo, 1, "|")
                sField2 = StringField(sLevelInfo, 2, "|")
                sField3 = StringField(sLevelInfo, 3, "|")
                sField4 = StringField(sLevelInfo, 4, "|")
                If fReqdPan = #SCS_PANCENTRE_SINGLE
                  sSetCommandItem = " chan " + sDevXChanListLeft + " " + sDevXChanListRight + " " + sField1
                  If Len(sField3) > 0
                    sFinalSetCommandItem + " chan " + sDevXChanListLeft + " " + sDevXChanListRight + " " + sField3
                  EndIf
                Else
                  sSetCommandItem = " chan " + sDevXChanListLeft + " " + sField1
                  If Len(sDevXChanListRight) > 0
                    sSetCommandItem + " chan " + sDevXChanListRight + " " + sField2
                  EndIf
                  If Len(sField3) > 0
                    sFinalSetCommandItem + " chan " + sDevXChanListLeft + " " + sField3
                    If Len(sDevXChanListRight) > 0
                      sFinalSetCommandItem + " chan " + sDevXChanListRight + " " + sField4
                    EndIf
                  EndIf
                EndIf
                debugMsgSMS(sProcName, "sSetCommandItem=" + sSetCommandItem)
                If Len(sFinalSetCommandItem) > 0
                  debugMsgSMS(sProcName, "sFinalSetCommandItem=" + sFinalSetCommandItem)
                EndIf
                sAudSetGainCommandString + sSetCommandItem
              EndIf
              
            EndIf
          EndIf
        Next d
      EndIf
    Next d2
    \sAudFinalSetGainCommandString = sFinalSetCommandItem   ; nb may be blank
    debugMsgSMS(sProcName, "\sAudFinalSetGainCommandString=" + \sAudFinalSetGainCommandString)
    ; debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sPPrimaryChan=" + \sPPrimaryChan + ", \sAudPChanList=" + \sAudPChanList)
    
    ; ; tidy up sAudXChanList, converting double-spaces to single-spaces, and trimming result
    ; \sAudXChanList = Trim(ReplaceString(sAudXChanList, "  ", " "))
    ; debugMsgSMS(sProcName, "\sAudXChanList=" + \sAudXChanList)
    
    ; tidy up sAudSetGainCommandString, converting double-spaces to single-spaces, and trimming result
    \sAudSetGainCommandString = Trim(ReplaceString(sAudSetGainCommandString, "  ", " "))
    debugMsgSMS(sProcName, "\sAudSetGainCommandString=" + \sAudSetGainCommandString)
    
    ; If \bSetLevelsWhenPlayAud
      ; ; ; initially mute all this Aud's crosspoint channels
      ; ; sendSMSCommand("set chan " + \sAudXChanList + " gain 0")
    ; Else
      ; If Len(\sAudSetGainCommandString) > 0
        ; sendSMSCommand("set " + \sAudSetGainCommandString)
      ; EndIf
    ; EndIf
    
    ; debugMsgSMS(sProcName, "calling setXChanListForMonitoring(" + getAudLabel(pAudPtr) + ")")
    ; setXChanListForMonitoring(pAudPtr)
    
    ; debugCuePtrs()
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure setGainCommandStringForSoloLiveInput(nCtrlIndex)
  PROCNAMEC()
  Protected d, d2, n
  Protected sInputLogicalDev.s, sLogicalDev.s
  Protected nLogicalDevPtr
  Protected nInputDevMapDevPtr, nOutputDevMapDevPtr
  Protected nNrOfInputChans
  Protected nNrOfOutputChans, nFirst0BasedOutputChan
  Protected sAudChanList.s
  Protected sAudXChanList.s
  Protected nAssignResult, nPrimaryChan
  Protected sTmp.s
  Protected sDevXChanListLeft.s, sDevXChanListRight.s
  Protected sAudSetGainCommandString.s, sSetCommandItem.s, sLevelInfo.s, sFinalSetCommandItem.s
  Protected fReqdBVLevel.f, fReqdPan.f, nReqdFadeInTime
  Protected bFirstTime
  Protected nResult
  Protected sField1.s, sField2.s, sField3.s, sField4.s
  Protected bStereoInput, bStereoOutput
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With WCN\aController(nCtrlIndex)
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure openInputsForSMS(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d, d2, n, n2
  Protected sInputLogicalDev.s, sLogicalDev.s
  Protected nLogicalDevPtr
  Protected nInputDevMapDevPtr, nOutputDevMapDevPtr
  Protected nInputChanAG
  Protected nNrOfInputChans
  Protected nNrOfOutputChans, nFirst0BasedOutputChanAG
  Protected sAudChanList.s
  Protected sAudXChanList.s
  Protected nAssignResult, nPrimaryChan
  Protected sTmp.s
  Protected sAudSetGainCommandString.s, sSetCommandItem.s, sLevelInfo.s, sFinalSetCommandItem.s
  Protected fReqdBVLevel.f, fReqdPan.f, nReqdFadeInTime
  Protected bFirstTime
  Protected nResult
  Protected sField1.s, sField2.s, sField3.s, sField4.s
  Protected bStereoInput, bStereoOutput
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    If \bAudTypeI = #False
      ProcedureReturn
    EndIf
    \bOKForSMS = #True
    
    For d2 = \nFirstInputDev To \nLastInputDev
      sInputLogicalDev = \sInputLogicalDev[d2]
      \bInputCurrentlyOff[d2] = \bInputOff[d2]
      If (Len(sInputLogicalDev) > 0) And (\bInputOff[d2] = #False)
        nInputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, sInputLogicalDev)
        \nInputDevMapDevPtr[d2] = nInputDevMapDevPtr
        debugMsgSMS(sProcName, "\sInputLogicalDev[" + d2 + "]=" + \sInputLogicalDev[d2] + ", \nInputDevMapDevPtr[" + d2 + "]=" + Str(\nInputDevMapDevPtr[d2]))
        If nInputDevMapDevPtr >= 0
          If grMaps\aDev(nInputDevMapDevPtr)\nNrOfInputChans = 2
            bStereoInput = #True
          Else
            bStereoInput = #False
          EndIf
          For n2 = 1 To grMaps\aDev(nInputDevMapDevPtr)\nNrOfInputChans
;             nInputChan = grMaps\aDev(nInputDevMapDevPtr)\nFirst1BasedInputChan - 1 + (n2-1)
            nInputChanAG = grMaps\aDev(nInputDevMapDevPtr)\nFirst0BasedInputChanAG + (n2-1)
            sAudChanList + " " + Str(nInputChanAG)
            nNrOfInputChans + 1
            For d = \nFirstDev To \nLastDev
              sLogicalDev = \sLogicalDev[d]
              If sLogicalDev
                nOutputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
                \nOutputDevMapDevPtr[d] = nOutputDevMapDevPtr
                If nOutputDevMapDevPtr >= 0
;                   nFirst0BasedOutputChan = grMaps\aDev(nOutputDevMapDevPtr)\nFirst1BasedOutputChan - 1
                  nFirst0BasedOutputChanAG = grMaps\aDev(nOutputDevMapDevPtr)\nFirst0BasedOutputChanAG
                  nNrOfOutputChans = grMaps\aDev(nOutputDevMapDevPtr)\nNrOfDevOutputChans
                  If nNrOfOutputChans = 2
                    bStereoOutput = #True
                  Else
                    bStereoOutput = #False
                  EndIf
                  If bStereoInput And bStereoOutput
                    If n2 = 1
                      sAudXChanList + " x" + Str(nInputChanAG) + "." + Str(nFirst0BasedOutputChanAG)
                    Else
                      sAudXChanList + " x" + Str(nInputChanAG) + "." + Str(nFirst0BasedOutputChanAG + 1)
                    EndIf
                  Else
                    For n = 0 To (nNrOfOutputChans-1)
                      sAudXChanList + " x" + Str(nInputChanAG) + "." + Str(nFirst0BasedOutputChanAG + n)
                    Next n
                  EndIf
                EndIf
              EndIf
            Next d
          Next n2
        EndIf
      EndIf
    Next d2
    
    \nNrOfInputChans = nNrOfInputChans
    \sAudChanList = Trim(sAudChanList)
    \sAudXChanList = Trim(sAudXChanList)
    ; debugMsgSMS(sProcName, "calling setXChanListForMonitoring(" + getAudLabel(pAudPtr) + ")")
    ; setXChanListForMonitoring(pAudPtr)
    debugMsgSMS(sProcName, "\sAudChanList=" + \sAudChanList)
    debugMsgSMS(sProcName, "\sAudXChanList=" + \sAudXChanList)
    
    \nFileDuration = 0
    \nSampleRate = 0
    
    \bSetLevelsWhenPlayAud = #False
    
    debugMsgSMS(sProcName, "calling setGainCommandStringsForInputs(" + getAudLabel(pAudPtr) + ")")
    setGainCommandStringsForInputs(pAudPtr)
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
  ProcedureReturn 0
  
EndProcedure

Procedure.s setLevelsForSMSOutputDev(pAudPtr, nOutputDevNo, fBVLevel.f, fPan.f, nFadeTime=0, nFadeType=#SCS_FADE_STD, nInputDevNo=-1)
  ; returns SM-S GAIN strings for left and right, split by "|"
  PROCNAMECA(pAudPtr)
  Protected fBVLevelLeft.f, fBVLevelRight.f, fPanFactor.f, fReqdDBLevel.f
  Protected sLeft.s, sRight.s, sFadeString.s
  Protected sLeftFinal.s, sRightFinal.s, sFadeStringFinal.s
  Protected fMyLevel.f, fMyPan.f
  Protected sSMSFadeType.s
  Protected sReturnString.s
  Protected fInputLevel.f
  Protected nFirstInputDev, nLastInputDev
  Protected d2
  
  With aAud(pAudPtr)
    CompilerIf #cTraceSetLevels
      If #cTraceSetLevelsFirstDevOnly = #False Or nOutputDevNo = 0
        debugMsgSMS(sProcName, #SCS_START + ", nOutputDevNo=" + nOutputDevNo + ", fBVLevel=" + traceLevel(fBVLevel) + ", fPan=" + formatPan(fPan) + ", nFadeTime=" + nFadeTime)
      EndIf
    CompilerEndIf
    ; debugMsg0(sProcName, "\sDevPXDownMix[" + nOutputDevNo + "]=" + \sDevPXDownMix[nOutputDevNo])
    
    If fBVLevel = #SCS_NOVOLCHANGE_SINGLE
      debugMsgSMS(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueVolNow[" + nOutputDevNo + "]=" + traceLevel(\fCueVolNow[nOutputDevNo]))
      fMyLevel = \fCueVolNow[nOutputDevNo]
    Else
      fMyLevel = fBVLevel
    EndIf
    If fPan = #SCS_NOPANCHANGE_SINGLE
      fMyPan = \fCuePanNow[nOutputDevNo]
    Else
      fMyPan = fPan
    EndIf
    
    If \bAudTypeI
      If nInputDevNo = -1
        nFirstInputDev = \nFirstInputDev
        nLastInputDev = \nLastInputDev
      Else  ; just one input device to be set
        nFirstInputDev = nInputDevNo
        nLastInputDev = nInputDevNo
      EndIf
    Else
      ; dummy settings to control main loop, providing one pass thru the loop
      nFirstInputDev = 0
      nLastInputDev = 0
    EndIf
    
    For d2 = nFirstInputDev To nLastInputDev
      If fMyPan = #SCS_PANCENTRE_SINGLE
        fBVLevelLeft = fMyLevel
        fBVLevelRight = fMyLevel
      ElseIf fMyPan < 0  ; pan left
        fBVLevelLeft = fMyLevel
        fPanFactor = 1 - (fMyPan * -1)
        fBVLevelRight = fMyLevel * fPanFactor
      Else              ; pan right
        fBVLevelRight = fMyLevel
        fPanFactor = 1 - fMyPan
        fBVLevelLeft = fMyLevel * fPanFactor
      EndIf
      
      If \bAudTypeI
        If \nInputDevMapDevPtr[d2] < 0
          ; no device specified for this index
          Continue
        EndIf
        fInputLevel = \fInputLevel[d2]
        fBVLevelLeft * fInputLevel
        fBVLevelRight * fInputLevel
      EndIf
      
      If \sDevPXDownMix[nOutputDevNo] = "DM"
        macSMSLevelMinus6dB(fBVLevelLeft)
        macSMSLevelMinus6dB(fBVLevelRight)
      EndIf
      
      If (nFadeType = #SCS_FADE_STD) And (nFadeTime > 500) And (grLevels\bSMSUseGainMidi)
        sLeft = "gainmidi " + makeSMSGainMIDIString(fBVLevelLeft)
        sRight = "gainmidi " + makeSMSGainMIDIString(fBVLevelRight)
        If fBVLevelLeft <> #SCS_MINVOLUME_SINGLE Or fBVLevelRight <> #SCS_MINVOLUME_SINGLE
          sLeftFinal = "gaindb " + makeSMSGainDBString(fBVLevelLeft)
          sRightFinal = "gaindb " + makeSMSGainDBString(fBVLevelRight)
        Else
          sLeftFinal = "gain " + makeSMSGainString(fBVLevelLeft)
          sRightFinal = "gain " + makeSMSGainString(fBVLevelRight)
        EndIf
      Else
        If fBVLevelLeft <> #SCS_MINVOLUME_SINGLE Or fBVLevelRight <> #SCS_MINVOLUME_SINGLE
          sLeft = "gaindb " + makeSMSGainDBString(fBVLevelLeft)
          sRight = "gaindb " + makeSMSGainDBString(fBVLevelRight)
        Else
          sLeft = "gain " + makeSMSGainString(fBVLevelLeft)
          sRight = "gain " + makeSMSGainString(fBVLevelRight)
        EndIf
      EndIf
      
      If nFadeTime > 0
        sFadeString = RTrim(" fadetime " + makeSMSTimeString(nFadeTime) + " " + makeSMSFadeType(nFadeType))
        sLeft + sFadeString
        sRight + sFadeString
        If Len(sLeftFinal) > 0
          sLeftFinal + " fadetime 0.5"
          sRightFinal + " fadetime 0.5"
        EndIf
      EndIf
      
      If grLevels\bSMSUseGainMidi = #False And nFadeTime > 0
        sLeft + " lin"
        sRight + " lin"
      EndIf
      
      If Len(sLeftFinal) > 0
        sReturnString = sLeft + "|" + sRight + "|" + sLeftFinal + "|" + sRightFinal
      Else
        sReturnString = sLeft + "|" + sRight
      EndIf
      
    Next d2
    
  EndWith
  
  CompilerIf #cTraceSetLevels
    debugMsgSMS(sProcName, "nOutputDevNo=" + nOutputDevNo + ", fBVLevel=" + traceLevel(fBVLevel) + ", fPan=" + tracePan(fPan) + ", returning " + sReturnString)
  CompilerEndIf
  ProcedureReturn sReturnString ; nb may be blank
  
EndProcedure

Procedure setLevelsForSMSInputDev(pAudPtr, nInputDev, nReqdFadeTime=0)
  PROCNAMECA(pAudPtr)
  Protected d
  Protected fReqdBVLevel.f
  
  CompilerIf #cTraceSetLevels
    debugMsgSMS(sProcName, #SCS_START + ", nInputDevNo=" + Str(nInputDev))
  CompilerEndIf
  
  With aAud(pAudPtr)
    If \bInputCurrentlyOff[nInputDev]
      fReqdBVLevel = #SCS_MINVOLUME_SINGLE
    Else
      fReqdBVLevel = #SCS_NOVOLCHANGE_SINGLE
    EndIf
    debugMsgSMS(sProcName, "\bInputOff[" + Str(nInputDev) + "]=" + strB(aAud(pAudPtr)\bInputOff[nInputDev]) + ", fReqdBVLevel=" + StrF(fReqdBVLevel))
    For d = \nFirstDev To \nLastDev
      If \nOutputDevMapDevPtr[d] >= 0
        setLevelsAny(pAudPtr, d, fReqdBVLevel, #SCS_NOPANCHANGE_SINGLE, nInputDev, nReqdFadeTime)
      EndIf
    Next d
  EndWith
  
EndProcedure

Procedure setSyncPChanListForAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  ; nb also used for live inputs
  Protected k, k2
  Protected nAudLinkCount
  Protected sSyncChanList.s
  Protected sSyncPChanList.s
  Protected sSyncXChanList.s
  Protected sSyncPXChanList.s
  Protected sSyncSetGainList.s
  Protected sAltSyncPChanList.s
  Protected sAltSyncPXChanList.s
  
  If gbUseSMS = #False
    ProcedureReturn
  EndIf
  
  ; debugMsgSMS(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    k = pAudPtr
    With aAud(k)
      If \sAudSetGainCommandString
        debugMsgSMS(sProcName, "aAud(" + getAudLabel(k) + ")\sAudSetGainCommandString=" + \sAudSetGainCommandString)
      EndIf
      sSyncChanList = \sAudChanList
      sSyncPChanList = \sAudPChanList
      sSyncXChanList = \sAudXChanList
      sSyncPXChanList = \sAudPXChanList
      sSyncSetGainList = \sAudSetGainCommandString
      sAltSyncPChanList = \sAltAudPChanList
      sAltSyncPXChanList = \sAltAudPXChanList
      If \nAudLinkCount > 0 And \nLinkedToAudPtr = -1
        nAudLinkCount = \nAudLinkCount
        k2 = \nFirstAudLink
        While nAudLinkCount > 0 And k2 <= gnLastAud
          If aAud(k2)\nLinkedToAudPtr = k
            If aAud(k2)\bExists
              If aAud(k2)\sAudChanList : sSyncChanList + " " + aAud(k2)\sAudChanList : EndIf
              aAud(k2)\sSyncChanList = aAud(k2)\sAudChanList
              If aAud(k2)\sAudPChanList : sSyncPChanList + " " + aAud(k2)\sAudPChanList : EndIf
              aAud(k2)\sSyncPChanList = aAud(k2)\sAudPChanList
              If aAud(k2)\sAudXChanList : sSyncXChanList + " " + aAud(k2)\sAudXChanList : EndIf
              aAud(k2)\sSyncXChanList = aAud(k2)\sAudXChanList
              If aAud(k2)\sAudPXChanList : sSyncPXChanList + " " + aAud(k2)\sAudPXChanList : EndIf
              aAud(k2)\sSyncPXChanList = aAud(k2)\sAudPXChanList
              If aAud(k2)\sAudSetGainCommandString : sSyncSetGainList + " " + aAud(k2)\sAudSetGainCommandString : EndIf
              aAud(k2)\sSyncSetGainList = aAud(k2)\sAudSetGainCommandString
              If aAud(k2)\sAltAudPChanList : sAltSyncPChanList + " " + aAud(k2)\sAltAudPChanList : EndIf
              aAud(k2)\sAltSyncPChanList = aAud(k2)\sAltAudPChanList
              If aAud(k2)\sAltAudPXChanList : sAltSyncPXChanList + " " + aAud(k2)\sAltAudPXChanList : EndIf
              aAud(k2)\sAltSyncPXChanList = aAud(k2)\sAltAudPXChanList
            EndIf
          EndIf
          k2 + 1
        Wend
      EndIf
      \sSyncChanList = sSyncChanList
      \sSyncPChanList = sSyncPChanList
      \sSyncXChanList = sSyncXChanList
      \sSyncPXChanList = sSyncPXChanList
      \sSyncSetGainList = sSyncSetGainList
      \sAltSyncPChanList = sAltSyncPChanList
      \sAltSyncPXChanList = sAltSyncPXChanList
      If sSyncChanList Or sSyncPChanList Or sSyncPXChanList Or sSyncSetGainList Or sSyncXChanList
        debugMsgSMS(sProcName, "aAud(" + getAudLabel(k) + ")\sSyncChanList=" + \sSyncChanList + ", \sSyncXChanList=" + \sSyncXChanList +
                               ", \sSyncPChanList=" + \sSyncPChanList + ", \sSyncPXChanList=" + \sSyncPXChanList +
                               ", \sSyncSetGainList=" + \sSyncSetGainList +
                               ", \sAltSyncPChanList=" + \sAltSyncPChanList + ", \sAltSyncPXChanList=" + \sAltSyncPXChanList)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure setSyncPChanListForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, k
  
  debugMsgSMS(sProcName, #SCS_START)
  
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If aSub(j)\bSubTypeHasAuds And aSub(j)\bSubEnabled
      k = aSub(j)\nFirstAudIndex
      While k >= 0
        setSyncPChanListForAud(k)
        k = aAud(k)\nNextAudIndex
      Wend
    EndIf
    j = aSub(j)\nNextSubIndex
  Wend
  
  setFastCuePlayCommandString(pCuePtr)
  
EndProcedure

Procedure setSMSSyncPointLoopReleased(pAudPtr, nLoopInfoIndex, bLoopReleased)
  PROCNAMECA(pAudPtr)
  Protected n
  
  For n = 0 To gnMaxSMSSyncPoint
    With gaSMSSyncPoint(n)
      If (\nAudPtr = pAudPtr) And (\nLoopInfoIndex = nLoopInfoIndex)
        \bLoopReleased = bLoopReleased
      EndIf
    EndWith
  Next n
EndProcedure

Procedure setSMSSyncPoint(pAudPtr, pSyncType, pSyncPos, pSyncProcedure.s, nLoopSyncIndex=-1, nLoopInfoIndex=-1)
  PROCNAMECA(pAudPtr)
  Protected n, nIndex
  
  debugMsgSMS(sProcName, #SCS_START)
  
  ; nb pAudPtr = -2 for preview channel
  
  nIndex = -1
  For n = 0 To gnMaxSMSSyncPoint
    With gaSMSSyncPoint(n)
      If \nAudPtr = -1
        nIndex = n
      ElseIf (\nAudPtr = pAudPtr) And (\nSyncType = pSyncType) And (\sSyncProcedure = pSyncProcedure) And (\nLoopInfoIndex = nLoopInfoIndex)
        nIndex = n
      EndIf
    EndWith
    If nIndex >= 0
      Break
    EndIf
  Next n
  
  If nIndex = -1
    nIndex = gnMaxSMSSyncPoint + 1
    If nIndex > ArraySize(gaSMSSyncPoint())
      ReDim gaSMSSyncPoint(nIndex + 20)
    EndIf
  EndIf
  
  With gaSMSSyncPoint(nIndex)
    \nAudPtr = pAudPtr
    \nSyncType = pSyncType
    \nSyncPos = pSyncPos
    \sSyncProcedure = pSyncProcedure
    \nLoopSyncIndex = nLoopSyncIndex
    \nLoopInfoIndex = nLoopInfoIndex
    debugMsgSMS(sProcName, "gaSMSSyncPoint(" + nIndex + ")\nAudPtr=" + getAudLabel(\nAudPtr) + ", \nSyncType=" + \nSyncType +
                        ", \nLoopInfoIndex=" + \nLoopInfoIndex + ", \sSyncProcedure=" + \sSyncProcedure)
  EndWith
  
  If nIndex > gnMaxSMSSyncPoint
    gnMaxSMSSyncPoint = nIndex
    debugMsgSMS(sProcName, "gnMaxSMSSyncPoint=" + gnMaxSMSSyncPoint)
  EndIf
  
  ProcedureReturn nIndex    ; return handle of sync point
  
EndProcedure

Procedure removeSMSSyncPoint(pAudPtr, pSyncIndex)
  PROCNAMECA(pAudPtr)
  Protected bResult, n, l2, nMyMaxSyncPoint
  
  debugMsgSMS(sProcName, #SCS_START + ", pSyncIndex=" + pSyncIndex + ", gnMaxSMSSyncPoint=" + gnMaxSMSSyncPoint)
  
  ; nb pAudPtr = -2 for preview channel
  
  If (pSyncIndex >= 0) And (pSyncIndex <= ArraySize(gaSMSSyncPoint()))
    If gaSMSSyncPoint(pSyncIndex)\nAudPtr = pAudPtr
      gaSMSSyncPoint(pSyncIndex)\nAudPtr = -1
      bResult = #True
      nMyMaxSyncPoint = -1
      For n = gnMaxSMSSyncPoint To 0 Step -1
        If gaSMSSyncPoint(n)\nAudPtr <> -1
          nMyMaxSyncPoint = n
          Break
        EndIf
      Next n
      gnMaxSMSSyncPoint = nMyMaxSyncPoint
      debugMsgSMS(sProcName, "gnMaxSMSSyncPoint=" + gnMaxSMSSyncPoint)
    EndIf
    If pAudPtr >= 0
      For l2 = 0 To aAud(pAudPtr)\nMaxLoopInfo
        With aAud(pAudPtr)\aLoopInfo(l2)
          If \nSMSLoopSyncPointIndex1 = pSyncIndex
            \nSMSLoopSyncPointIndex1 = grAudDef\aLoopInfo(0)\nSMSLoopSyncPointIndex1
          EndIf
          If \nSMSLoopSyncPointIndex2 = pSyncIndex
            \nSMSLoopSyncPointIndex2 = grAudDef\aLoopInfo(0)\nSMSLoopSyncPointIndex2
          EndIf
        EndWith
      Next l2
    EndIf
  EndIf
  
;   For n = 0 To gnMaxSMSSyncPoint
;     With gaSMSSyncPoint(n)
;       debugMsgSMS(sProcName, "gaSMSSyncPoint(" + n + ")\nAudPtr=" + getAudLabel(\nAudPtr) + ", \nLoopSyncIndex=" + \nLoopSyncIndex +
;                           ", \nSyncPos=" + \nSyncPos + ", \nSyncType=" + \nSyncType + ", \sSyncProcedure=" + \sSyncProcedure)
;     EndWith
;   Next n
  
  ProcedureReturn bResult
  
EndProcedure

Procedure checkSMSSyncPoints()
  PROCNAMEC()
  Protected n, bRemoveSyncPoint, nAudPtr, nLoopSyncIndex, bSyncPointRemoved, bLoopReleased
  Protected nTrackTimeInMS
  
  ;debugMsgSMS(sProcName, #SCS_START)
  
  For n = 0 To gnMaxSMSSyncPoint
    ; debugMsgSMS(sProcName, "gaSMSSyncPoint(" + n + ")\nAudPtr=" + getAudLabel(gaSMSSyncPoint(n)\nAudPtr) + ", \bLoopReleased=" + strB(gaSMSSyncPoint(n)\bLoopReleased))
    If (gaSMSSyncPoint(n)\nAudPtr <> -1) And (gaSMSSyncPoint(n)\bLoopReleased = #False)
      nAudPtr = gaSMSSyncPoint(n)\nAudPtr
      ; nb nAudPtr = -2 for preview channel
      If nAudPtr >= 0
        With aAud(nAudPtr)
          nLoopSyncIndex = gaSMSSyncPoint(n)\nLoopSyncIndex
          bRemoveSyncPoint = #False
          If \nAudState >= #SCS_CUE_COMPLETED
            bRemoveSyncPoint = #True
          EndIf
          If bRemoveSyncPoint = #False
            Select gaSMSSyncPoint(n)\nSyncType
              Case #SCS_SMS_SYNC_POS
                Select gaSMSSyncPoint(n)\sSyncProcedure
                    
                  Case "LoopSyncProcSMSXFade"
                    nTrackTimeInMS = getSMSTrackTimeInMS(\sPPrimaryChan)
                    ; debugMsgSMS(sProcName, "LoopSyncProcSMSXFade POS getSMSTrackTimeInMS(" + \sPPrimaryChan + ")="+ nTrackTimeInMS + ", gaSMSSyncPoint(" + n + ")\nSyncPos=" + gaSMSSyncPoint(n)\nSyncPos)
                    If nTrackTimeInMS >= gaSMSSyncPoint(n)\nSyncPos
                      debugMsg_S(sProcName, "LoopSyncProcSMSXFade POS getSMSTrackTimeInMS(" + \sPPrimaryChan + ")="+ nTrackTimeInMS + ", gaSMSSyncPoint(" + n + ")\nSyncPos=" + gaSMSSyncPoint(n)\nSyncPos)
                      bLoopReleased = LoopSyncProcSMSXFade(nAudPtr, n)
                    EndIf
                    
                  Case "LoopSyncProcSMSLE"
                    nTrackTimeInMS = getSMSTrackTimeInMS(\sAltPPrimaryChan)
                    ; debugMsgSMS(sProcName, "LoopSyncProcSMSLE POS getSMSTrackTimeInMS(" + \sAltPPrimaryChan + ")="+ nTrackTimeInMS + ", gaSMSSyncPoint(" + n + ")\nSyncPos=" + gaSMSSyncPoint(n)\nSyncPos)
                    If nTrackTimeInMS >= (gaSMSSyncPoint(n)\nSyncPos + 750)
                      debugMsg_S(sProcName, "LoopSyncProcSMSLE POS getSMSTrackTimeInMS(" + \sAltPPrimaryChan + ")="+ nTrackTimeInMS + ", gaSMSSyncPoint(" + n + ")\nSyncPos=" + gaSMSSyncPoint(n)\nSyncPos)
                      LoopSyncProcSMSLE(nAudPtr, n)
                    EndIf
                    
                  Case "LoopSyncProcSMSNOXFade"
                    nTrackTimeInMS = getSMSTrackTimeInMS(\sPPrimaryChan)
                    ; debugMsgSMS(sProcName, "LoopSyncProcSMSNOXFade POS getSMSTrackTimeInMS(" + \sPPrimaryChan + ")="+ nTrackTimeInMS + ", gaSMSSyncPoint(" + n + ")\nSyncPos=" + gaSMSSyncPoint(n)\nSyncPos)
                    If nTrackTimeInMS >= gaSMSSyncPoint(n)\nSyncPos
                      debugMsg_S(sProcName, "LoopSyncProcSMSNOXFade POS getSMSTrackTimeInMS(" + \sPPrimaryChan + ")="+ nTrackTimeInMS + ", gaSMSSyncPoint(" + n + ")\nSyncPos=" + gaSMSSyncPoint(n)\nSyncPos)
                      bLoopReleased = LoopSyncProcSMSNOXFade(nAudPtr, n)
                    EndIf
                    
                  Default
                    ; debugMsgSMS(sProcName, "gaSMSSyncPoint(" + n + ")\sSyncProcedure=" + gaSMSSyncPoint(n)\sSyncProcedure)
                    
                EndSelect
                
              Case #SCS_SMS_SYNC_END
                Select gaSMSSyncPoint(n)\sSyncProcedure
                    
                  Case "WFO_endSyncPreview"
                    nTrackTimeInMS = getSMSTrackTimeInMS(grPreview\sPPrimaryChan)
                    ; debugMsgSMS(sProcName, "getSMSTrackTimeInMS(" + grPreview\sPPrimaryChan + ")=" + nTrackTimeInMS + ", nPreviewTrackLengthInMS=" + grPreview\nPreviewTrackLengthInMS)
                    If nTrackTimeInMS > (grPreview\nPreviewTrackLengthInMS - 100)
                      If getSMSTrackStatus(grPreview\sPPrimaryChan) = "stop"
                        ; samAddRequest(#SCS_SAM_PREVIEW_ENDED)
                        gbPreviewEnded = #True
                        bRemoveSyncPoint = #True
                      EndIf
                    EndIf
                    
                  Case "LoopSyncProcSMSXFade"
                    nTrackTimeInMS = getSMSTrackTimeInMS(\sPPrimaryChan)
                    ; debugMsgSMS(sProcName, "LoopSyncProcSMSXFade END getSMSTrackTimeInMS(" + \sPPrimaryChan + ")=" + nTrackTimeInMS + ", aAud(" + getAudLabel(nAudPtr) + ")\nAbsEndAt=" + \nAbsEndAt)
                    If nTrackTimeInMS >= \nAbsEndAt
                      bLoopReleased = LoopSyncProcSMSXFade(nAudPtr, n)
                      bRemoveSyncPoint = #True
                    EndIf
                    
                  Case "LoopSyncProcSMSNOXFade"
                    nTrackTimeInMS = getSMSTrackTimeInMS(\sPPrimaryChan)
                    ; debugMsgSMS(sProcName, "LoopSyncProcSMSNOXFade END getSMSTrackTimeInMS(" + \sPPrimaryChan + ")=" + nTrackTimeInMS + ", aAud(" + getAudLabel(nAudPtr) + ")\nAbsEndAt=" + \nAbsEndAt)
                    If nTrackTimeInMS >= \nAbsEndAt
                      bLoopReleased = LoopSyncProcSMSNOXFade(nAudPtr, n)
                      bRemoveSyncPoint = #True
                    EndIf
                    
                  Default
                    ; debugMsgSMS(sProcName, "gaSMSSyncPoint(" + n + ")\sSyncProcedure=" + gaSMSSyncPoint(n)\sSyncProcedure)
                    
                EndSelect
                
              Default
                ; debugMsgSMS(sProcName, "gaSMSSyncPoint(" + n + ")\nSyncType=" + gaSMSSyncPoint(n)\nSyncType)
                
            EndSelect
          EndIf
          
          If bLoopReleased
            gaSMSSyncPoint(n)\bLoopReleased = bLoopReleased
          EndIf
          
          If bRemoveSyncPoint
            debugMsgSMS(sProcName, "calling removeSMSSyncPoint(" + getAudLabel(nAudPtr) + ", " + n + ")")
            removeSMSSyncPoint(nAudPtr, n)
            bSyncPointRemoved = #True
          EndIf
        EndWith
      EndIf
    EndIf
  Next n
  
  If bSyncPointRemoved Or bLoopReleased
    debugMsgSMS(sProcName, "calling listSMSSyncPoints()")
    listSMSSyncPoints()
  EndIf
  
EndProcedure

Procedure.s decodePLBAssignedTo(nAssignedTo)
  Protected sAssignedTo.s
  
  Select nAssignedTo
    Case #SCS_PLB_UNASSIGNED
      sAssignedTo = "Unassigned"
    Case #SCS_PLB_PREVIEW
      sAssignedTo = "Preview"
    Case #SCS_PLB_NORMAL
      sAssignedTo = "Normal"
    Default
      sAssignedTo = Str(nAssignedTo)
  EndSelect
  
  ProcedureReturn sAssignedTo
  
EndProcedure

Procedure getLoopInfoIndexForSMSSyncPoint(pAudPtr, nSMSSyncPoint)
  PROCNAMECA(pAudPtr)
  Protected nLoopInfoIndex = -1
  Protected l2
  
  For l2 = 0 To aAud(pAudPtr)\nMaxLoopInfo
    With aAud(pAudPtr)\aLoopInfo(l2)
      Select nSMSSyncPoint
        Case \nSMSLoopSyncPointIndex1, \nSMSLoopSyncPointIndex2
          nLoopInfoIndex = l2
          Break
      EndSelect
    EndWith
  Next l2
  ProcedureReturn nLoopInfoIndex
EndProcedure

Procedure setSMSLoopEnd(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n, l2, s2.s
  Protected nLoopSyncIndex
  Protected nLoopEndPosXFade, nLoopEndPosLE, nFileDuration
  Protected nChannel, nAltChannel
  Protected nMyAbsLoopEnd
  Protected nSyncPos
  
  debugMsgSMS(sProcName, #SCS_START)
  
  debugMsgSMS(sProcName, "calling removeAudChannelLoopSyncs(" + pAudPtr + ")")
  removeAudChannelLoopSyncs(pAudPtr)
  
  If gbUseBASS
    ProcedureReturn
  EndIf
  
  If aAud(pAudPtr)\nMaxLoopInfo < 0
    ; no loop
    ProcedureReturn
  EndIf
  
  If aAud(pAudPtr)\nLinkedToAudPtr <> -1
    ; don't set loop syncs for linked aud's as loop sync repositioning is performed from the loop sync proc of the primary aud
    ProcedureReturn
  EndIf
  
  With aAud(pAudPtr)
    nChannel = \nPrimaryChan
    nAltChannel = \nAltPrimaryChan
    nFileDuration = \nFileDuration
  EndWith
  
  For l2 = 0 To aAud(pAudPtr)\nMaxLoopInfo
    s2 = "l2=" + l2 + ", "
    With aAud(pAudPtr)\aLoopInfo(l2)
      nLoopSyncIndex = -1
      For n = 1 To gnLastLoopSync
        If gaLoopSync(n)\bActive = #False
          nLoopSyncIndex = n
          Break
        EndIf
      Next n
      If nLoopSyncIndex = -1
        gnLastLoopSync + 1
        If gnLastLoopSync > ArraySize(gaLoopSync())
          ReDim gaLoopSync(gnLastLoopSync + 50)
        EndIf
        nLoopSyncIndex = gnLastLoopSync
      EndIf
      gaLoopSync(nLoopSyncIndex)\bActive = #True
      gaLoopSync(nLoopSyncIndex)\bChannelSwapAtXFade = #False
      
      nMyAbsLoopEnd = \nAbsLoopEnd
      If \nLoopXFadeTime > 0
        nLoopEndPosXFade = nMyAbsLoopEnd - \nLoopXFadeTime
      Else
        nLoopEndPosXFade = nMyAbsLoopEnd
      EndIf
      If (\nLoopXFadeTime <= 0) And ((nMyAbsLoopEnd + 100) < aAud(pAudPtr)\nFileDuration)
        nLoopEndPosLE = nMyAbsLoopEnd
        gaLoopSync(nLoopSyncIndex)\bChannelSwapAtXFade = #True
      Else
        nLoopEndPosLE = nMyAbsLoopEnd
      EndIf
      debugMsgSMS(sProcName, s2 + "\aLoopInfo(" + l2 + ")\nAbsLoopEnd=" + nMyAbsLoopEnd + ", \nLoopXFadeTime=" + \nLoopXFadeTime)
      
      gaLoopSync(nLoopSyncIndex)\nAudPtr = pAudPtr
      gaLoopSync(nLoopSyncIndex)\nLoopInfoIndex = l2
      gaLoopSync(nLoopSyncIndex)\nDevNo = 0
      gaLoopSync(nLoopSyncIndex)\nChannel = nChannel
      gaLoopSync(nLoopSyncIndex)\nAltChannel = nAltChannel
      gaLoopSync(nLoopSyncIndex)\nLoopXFadeTime = \nLoopXFadeTime
      gaLoopSync(nLoopSyncIndex)\nLoopSyncPassNo = 1
      gaLoopSync(nLoopSyncIndex)\nLoopSyncPassesReqd = \nNumLoops
      gaLoopSync(nLoopSyncIndex)\bSwapped = #False
      
      \nLoopSyncIndex = nLoopSyncIndex
      
      If nLoopEndPosLE = nLoopEndPosXFade
        ; ===================================================================================
        ; no cross-fade requested or possible, so only set one sync ("Both") for each channel
        ; ===================================================================================
        If nLoopEndPosLE >= nFileDuration
          ; set sync point at end
          nSyncPos = 0
          \nSMSLoopSyncPointIndex1 = setSMSSyncPoint(pAudPtr, #SCS_SMS_SYNC_END, nSyncPos, "LoopSyncProcSMSNOXFade", nLoopSyncIndex, -1)
        Else
          ; set sync point at specified position
          nSyncPos = nLoopEndPosLE
          \nSMSLoopSyncPointIndex1 = setSMSSyncPoint(pAudPtr, #SCS_SMS_SYNC_POS, nSyncPos, "LoopSyncProcSMSNOXFade", nLoopSyncIndex, l2)
        EndIf
        \nSMSLoopSyncPointIndex2 = grAudDef\aLoopInfo(0)\nSMSLoopSyncPointIndex2
        
      Else
        ; =======================================================================================
        ; cross-fade requested and possible, so set two syncs ("XFade" and "LE") for each channel
        ; =======================================================================================
        ; XFade sync point
        If nLoopEndPosXFade >= nFileDuration
          ; set sync point at end
          nSyncPos = 0
          \nSMSLoopSyncPointIndex1 = setSMSSyncPoint(pAudPtr, #SCS_SMS_SYNC_END, nSyncPos, "LoopSyncProcSMSXFade", nLoopSyncIndex, -1)
          \nSMSLoopSyncPointIndex2 = grAudDef\aLoopInfo(0)\nSMSLoopSyncPointIndex2
        Else
          ; set sync point at specified position
          nSyncPos = nLoopEndPosXFade
          \nSMSLoopSyncPointIndex1 = setSMSSyncPoint(pAudPtr, #SCS_SMS_SYNC_POS, nSyncPos, "LoopSyncProcSMSXFade", nLoopSyncIndex, l2)
          nSyncPos = nMyAbsLoopEnd
          \nSMSLoopSyncPointIndex2 = setSMSSyncPoint(pAudPtr, #SCS_SMS_SYNC_POS, nSyncPos, "LoopSyncProcSMSLE", nLoopSyncIndex, l2)
        EndIf
        
        gaLoopSync(nLoopSyncIndex)\bChannelSwapAtXFade = #True
        debugMsgSMS(sProcName, s2 + "gaLoopSync(" + nLoopSyncIndex + ")\bChannelSwapAtXFade=" + strB(gaLoopSync(nLoopSyncIndex)\bChannelSwapAtXFade))
        
      EndIf
      
      If \nSMSLoopSyncPointIndex1 >= 0
        gaSMSSyncPoint(\nSMSLoopSyncPointIndex1)\bLoopReleased = \bLoopReleased
      EndIf
      If \nSMSLoopSyncPointIndex2 >= 0
        gaSMSSyncPoint(\nSMSLoopSyncPointIndex2)\bLoopReleased = \bLoopReleased
      EndIf
      
    EndWith
  Next l2
  
  debugMsgSMS(sProcName, "calling listSMSSyncPoints()")
  listSMSSyncPoints()
  
EndProcedure

Procedure setSMSLoopStart(pAudPtr)
;   PROCNAMECA(pAudPtr)
  
  If gbUseBASS
    ProcedureReturn
  EndIf
  
  ; no action required for SM-S
  
EndProcedure

Procedure LoopSyncProcSMSXFade(pAudPtr, nLoopSyncIndex)
  PROCNAMECA(pAudPtr)
  Protected nAudPtr
  Protected d
  Protected rMyLoopSync.tyLoopSync
  Protected nPanelIndex
  Protected nFadeInTime, nFadeOutTime
  Protected sFadeInString.s, sFadeOutString.s
  Protected nChannel, nAltChannel
  Protected h, nTmpAudPtr
  Protected qTimeNow.q
  Protected sPXChanLeft.s, sAltPXChanLeft.s
  Protected sPXChanRight.s, sAltPXChanRight.s
  Protected sGain.s
  Protected sSetGainString.s, sAltSetGainString.s
  Protected sTrackStatus.s
  Protected sTrackStartTime.s, sCurrTrackStartTime.s
  Protected nTmp, sTmp.s
  Protected sSMSCommand.s
  Protected l2, bLoopReleased
  
  ; this callback occurs when the loop crossfade is due to start
  
  debugMsg_S(sProcName, #SCS_START + ", nLoopSyncIndex=" + nLoopSyncIndex)
  
  qTimeNow = ElapsedMilliseconds()
  nAudPtr = pAudPtr
  l2 = getLoopInfoIndexForSMSSyncPoint(pAudPtr, nLoopSyncIndex)
  debugMsgSMS(sProcName, "l2=" + l2)
  If l2 >= 0
    bLoopReleased = aAud(nAudPtr)\aLoopInfo(l2)\bLoopReleased
    debugMsgSMS(sProcName, "bLoopReleased=" + strB(bLoopReleased))
  EndIf
  
  If (nLoopSyncIndex >= 0) And (bLoopReleased = #False)
    rMyLoopSync = gaLoopSync(nLoopSyncIndex)
    
    nFadeInTime = rMyLoopSync\nLoopXFadeTime
    If rMyLoopSync\nLoopXFadeTime > 0
      nFadeOutTime = rMyLoopSync\nLoopXFadeTime
      sFadeInString = " fadetime " + makeSMSTimeString(nFadeInTime)
      sFadeOutString = " fadetime " + makeSMSTimeString(nFadeOutTime)
    Else
      nFadeOutTime = 0
      sFadeInString = ""
      sFadeOutString = ""
    EndIf
    
    rMyLoopSync\bInXfade = #True
    
    For d = aAud(nAudPtr)\nFirstDev To aAud(nAudPtr)\nLastDev
      sPXChanLeft = aAud(nAudPtr)\sDevPXChanListLeft[d]
      If sPXChanLeft
        sAltPXChanLeft = aAud(nAudPtr)\sAltDevPXChanListLeft[d]
      EndIf
      sPXChanRight = aAud(nAudPtr)\sDevPXChanListRight[d]
      If sPXChanRight
        sAltPXChanRight = aAud(nAudPtr)\sAltDevPXChanListRight[d]
      EndIf
      
      If sPXChanLeft
        sGain = getSMSGainString(sPXChanLeft)
        ; debugMsgSMS(sProcName, "getSMSGainString(" + sPXChanLeft + ") returned " + sGainDB)
        sSetGainString + " chan " + sPXChanLeft + " gain 0" + sFadeOutString
        sAltSetGainString + " chan " + sAltPXChanLeft + " gaindb " + sGain + sFadeInString
      EndIf
      
      If sPXChanRight
        sGain = getSMSGainString(sPXChanRight)
        ; debugMsgSMS(sProcName, "getSMSGainString(" + sPXChanRight + ") returned " + sGainDB)
        sSetGainString + " chan " + sPXChanRight + " gain 0" + sFadeOutString
        sAltSetGainString + " chan " + sAltPXChanRight + " gaindb " + sGain + sFadeInString
      EndIf
      
    Next d
    
    If aAud(nAudPtr)\rCurrLoopInfo\qLoopStartSamplePos >= 0
      sSMSCommand = "set chan " + aAud(nAudPtr)\sAltAudPChanList + " track start samples " + aAud(nAudPtr)\rCurrLoopInfo\qLoopStartSamplePos
      sendSMSCommand(sSMSCommand)
    Else
      sTrackStartTime = makeSMSTimeString(aAud(nAudPtr)\rCurrLoopInfo\nAbsLoopStart)
      sCurrTrackStartTime = getSMSTrackStartTime(aAud(nAudPtr)\sAltPPrimaryChan)
      debugMsgSMS(sProcName, "sTrackStartTime=" + sTrackStartTime + ", sCurrTrackStartTime=" + sCurrTrackStartTime)
      If sTrackStartTime <> sCurrTrackStartTime
        sSMSCommand = "set chan " + aAud(nAudPtr)\sAltAudPChanList + " track start time " + makeSMSTimeString(aAud(nAudPtr)\rCurrLoopInfo\nAbsLoopStart)
        sendSMSCommand(sSMSCommand)
      EndIf
    EndIf
    sTrackStatus = getSMSTrackStatus(aAud(nAudPtr)\sAltPPrimaryChan)
    debugMsgSMS(sProcName, "getSMSTrackStatus(" + aAud(nAudPtr)\sAltPPrimaryChan + ") returned " + sTrackStatus)
    If sTrackStatus = "play"
      sendSMSCommand("stop " + aAud(nAudPtr)\sAltAudPChanList)
    EndIf
    sendSMSCommand("set " + Trim(sSetGainString) + " " + Trim(sAltSetGainString))
    
    sendSMSCommand("set chan " + aAud(nAudPtr)\sAltAudPChanList + " mute off")
    sendSMSCommand("play " + aAud(nAudPtr)\sAltAudPChanList)
    
    aAud(nAudPtr)\qTimePassStarted = qTimeNow
    
    ; swap channel and altChannel
    For d = aAud(nAudPtr)\nFirstDev To aAud(nAudPtr)\nLastDev
      sPXChanLeft = aAud(nAudPtr)\sDevPXChanListLeft[d]
      aAud(nAudPtr)\sDevPXChanListLeft[d] = aAud(nAudPtr)\sAltDevPXChanListLeft[d]
      aAud(nAudPtr)\sAltDevPXChanListLeft[d] = sPXChanLeft
      sPXChanRight = aAud(nAudPtr)\sDevPXChanListRight[d]
      aAud(nAudPtr)\sDevPXChanListRight[d] = aAud(nAudPtr)\sAltDevPXChanListRight[d]
      aAud(nAudPtr)\sAltDevPXChanListRight[d] = sPXChanRight
    Next d
    
    nTmp = aAud(nAudPtr)\nPrimaryChan
    aAud(nAudPtr)\nPrimaryChan = aAud(nAudPtr)\nAltPrimaryChan
    aAud(nAudPtr)\nAltPrimaryChan = nTmp
    
    sTmp = aAud(nAudPtr)\sPPrimaryChan
    aAud(nAudPtr)\sPPrimaryChan = aAud(nAudPtr)\sAltPPrimaryChan
    aAud(nAudPtr)\sAltPPrimaryChan = sTmp
    
    sTmp = aAud(nAudPtr)\sAudPChanList
    aAud(nAudPtr)\sAudPChanList = aAud(nAudPtr)\sAltAudPChanList
    aAud(nAudPtr)\sAltAudPChanList = sTmp
    
    sTmp = aAud(nAudPtr)\sAudPXChanList
    aAud(nAudPtr)\sAudPXChanList = aAud(nAudPtr)\sAltAudPXChanList
    aAud(nAudPtr)\sAltAudPXChanList = sTmp
    
    sTmp = aAud(nAudPtr)\sSyncPChanList
    aAud(nAudPtr)\sSyncPChanList = aAud(nAudPtr)\sAltSyncPChanList
    aAud(nAudPtr)\sAltSyncPChanList = sTmp
    
    sTmp = aAud(nAudPtr)\sSyncPXChanList
    aAud(nAudPtr)\sSyncPXChanList = aAud(nAudPtr)\sAltSyncPXChanList
    aAud(nAudPtr)\sAltSyncPXChanList = sTmp
    
    sTmp = aAud(nAudPtr)\sAudSetGainCommandString
    aAud(nAudPtr)\sAudSetGainCommandString = aAud(nAudPtr)\sAltAudSetGainCommandString
    aAud(nAudPtr)\sAltAudSetGainCommandString = sTmp
    
    buildGetSMSCurrInfoCommandStrings()
    
    ; save gaLoopSync changes
    gaLoopSync(nLoopSyncIndex) = rMyLoopSync
    
  EndIf
  
  debugMsg_S(sProcName, #SCS_END + ", returning " + strB(bLoopReleased))
  ProcedureReturn bLoopReleased
  
EndProcedure

Procedure LoopSyncProcSMSLE(pAudPtr, nLoopSyncIndex)
  PROCNAMECA(pAudPtr)
  Protected sAltAudPChanList.s
  Protected sSMSCommand.s
  
  ; this callback occurs when the loop crossfade ends
  
  debugMsg_S(sProcName, #SCS_START + ", nLoopSyncIndex=" + nLoopSyncIndex)
  
  sAltAudPChanList = aAud(pAudPtr)\sAltAudPChanList
  If aAud(pAudPtr)\rCurrLoopInfo\qLoopStartSamplePos >= 0
    sSMSCommand = "set chan " + sAltAudPChanList + " track start samples " + aAud(pAudPtr)\rCurrLoopInfo\qLoopStartSamplePos
    sendSMSCommand(sSMSCommand)
  Else
    sSMSCommand = "set chan " + sAltAudPChanList + " track start time " + makeSMSTimeString(aAud(pAudPtr)\rCurrLoopInfo\nAbsLoopStart)
    sendSMSCommand(sSMSCommand)
  EndIf
  sendSMSCommand("rewind " + sAltAudPChanList)
  
  debugMsg_S(sProcName, #SCS_END)
  
EndProcedure

Procedure LoopSyncProcSMSNOXFade(pAudPtr, nLoopSyncIndex)
  PROCNAMECA(pAudPtr)
  Protected l2, bLoopReleased
  
  ; this callback occurs when the loop crossfade is due to start
  
  debugMsg_S(sProcName, #SCS_START + ", nLoopSyncIndex=" + nLoopSyncIndex)
  
  With aAud(pAudPtr)
    l2 = getLoopInfoIndexForSMSSyncPoint(pAudPtr, nLoopSyncIndex)
    debugMsgSMS(sProcName, "l2=" + l2)
    If l2 >= 0
      bLoopReleased = \aLoopInfo(l2)\bLoopReleased
      debugMsgSMS(sProcName, "bLoopReleased=" + strB(bLoopReleased))
      If bLoopReleased
        loadCurrLoopInfo(pAudPtr, \aLoopInfo(l2)\nRelLoopEnd+1)
      EndIf
    EndIf
  EndWith
  
  debugMsg_S(sProcName, #SCS_END + ", returning " + strB(bLoopReleased))
  ProcedureReturn bLoopReleased
  
EndProcedure

Procedure createASIOGroup()
  PROCNAMEC()
  Protected sSMSCommand.s
  Protected sCreateGroupSMSCommand.s
  Protected d, d2, nFirst0BasedOutputChanAG, nFirst0BasedInputChanAG
  Protected sConnectedPhysicalDevDesc.s
  Protected bWantThis
  Protected sMsg.s
  Protected nFirstInputChanAG, nFirstOutputChanAG
  Protected n, nPass
  Protected nChannelsAdjusted
  Protected nDevMapPtr
  
  debugMsgSMS(sProcName, #SCS_START)
  
  ; if group already exists with the required devices, do not re-create the group
  
  gnSuspendGetCurrInfo + 1
  
  If grSMS\nSMSClientConnection = 0
    debugMsgSMS(sProcName, "calling openSMSConnection()")
    openSMSConnection()
  EndIf
  
  nDevMapPtr = getDevMapPtr(@grMapsForChecker, grMapsForChecker\sSelectedDevMapName)
  debugMsg(sProcName, "grMapsForChecker\sSelectedDevMapName=" + #DQUOTE$ + grMapsForChecker\sSelectedDevMapName + #DQUOTE$ + ", nDevMapPtr=" + nDevMapPtr)
  
  grASIOGroup\nMaxAsioDevIndex = -1
  For d = 0 To gnMaxConnectedDev
    If gaConnectedDev(d)\nDriver = #SCS_DRV_SMS_ASIO
      If (gaConnectedDev(d)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) ; Or (gaConnectedDev(d)\nDevType = #SCS_DEVTYPE_LIVE_INPUT)
        ; debugMsgSMS(sProcName, "gaConnectedDev(" + d + ")\sPhysicalDevDesc=" + gaConnectedDev(d)\sPhysicalDevDesc)
        sConnectedPhysicalDevDesc = gaConnectedDev(d)\sPhysicalDevDesc
        bWantThis = #False
        ; debugMsgSMS(sProcName, "grMapsForChecker\aMap(" + getDevMapName(nDevMapPtr) + ")\nFirstDevIndex=" + grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex)
        d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
        While d2 >= 0
          CheckSubInRange(d2, ArraySize(grMapsForChecker\aDev()), "grMapsForChecker\aDev()")
          With grMapsForChecker\aDev(d2)
            If \bExists
              If (\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) Or (\nDevType = #SCS_DEVTYPE_LIVE_INPUT)
                If \sPhysicalDev = sConnectedPhysicalDevDesc
                  bWantThis = #True
                  Break
                EndIf
              EndIf
            EndIf
            ; debugMsgSMS(sProcName, "grMapsForChecker\aDev(" + d2 + ")\bExists=" + strB(\bExists) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDev=" + \sPhysicalDev + ", bWantThis=" + strB(bWantThis))
            d2 = \nNextDevIndex
          EndWith
        Wend
        If bWantThis
          With grASIOGroup
            \nMaxAsioDevIndex + 1
            If \nMaxAsioDevIndex > ArraySize(\sAsioDev())
              ReDim \sAsioDev(\nMaxAsioDevIndex)
              ReDim \nFirstInputChanAG(\nMaxAsioDevIndex)
              ReDim \nFirstOutputChanAG(\nMaxAsioDevIndex)
            EndIf
            \sAsioDev(\nMaxAsioDevIndex) = gaConnectedDev(d)\sPhysicalDevDesc
            \nFirstInputChanAG(\nMaxAsioDevIndex) = nFirstInputChanAG
            \nFirstOutputChanAG(\nMaxAsioDevIndex) = nFirstOutputChanAG
            debugMsgSMS(sProcName, "\sAsioDev(" + \nMaxAsioDevIndex + ")=" + \sAsioDev(\nMaxAsioDevIndex) +
                                ", \nFirstInputChanAG(" + \nMaxAsioDevIndex + ")=" + \nFirstInputChanAG(\nMaxAsioDevIndex) +
                                ", \nFirstOutputChanAG(" + \nMaxAsioDevIndex + ")=" + \nFirstOutputChanAG(\nMaxAsioDevIndex))
          EndWith
          sCreateGroupSMSCommand + " interface " + #DQUOTE$ + gaConnectedDev(d)\sPhysicalDevDesc + #DQUOTE$
          debugMsgSMS(sProcName, "sCreateGroupSMSCommand=" + sCreateGroupSMSCommand)
          nFirstInputChanAG + gaConnectedDev(d)\nInputs
          nFirstOutputChanAG + gaConnectedDev(d)\nOutputs
        EndIf
      EndIf
    EndIf
  Next d
  
  If (grASIOGroup\bGroupCreated) And (grASIOGroup\bGroupInitialized) And (grASIOGroup\sCreateGroupSMSCommand = sCreateGroupSMSCommand)
    debugMsgSMS(sProcName, "exiting because group structure not changed (sCreateGroupSMSCommand=" + sCreateGroupSMSCommand + ")")
    gnSuspendGetCurrInfo - 1
    ProcedureReturn
  EndIf
  
  With grASIOGroup
    If \bGroupCreated
      If gbInitialising = #False
        debugMsgSMS(sProcName, "calling stopEverythingPart1(-1, #False)")
        stopEverythingPart1(-1, #False)
      EndIf
      sSMSCommand = "config close interface; createASIOGroup()"
      sendSMSCommand(sSMSCommand)
      \bGroupInitialized = #False
      sSMSCommand = "config clear asiogroup " + \sNameWithQuotes + "; createASIOGroup()"
      sendSMSCommand(sSMSCommand)
      \bGroupCreated = #False
      debugMsgSMS(sProcName, "grASIOGroup\bGroupCreated=" + strB(\bGroupCreated))
      \sErrorMsg = ""
    EndIf
    
    For nPass = 1 To 2 ; Added 19Jan2023 11.9.8ag - try up to 2 times
      \nGroupInputs = 0
      \nGroupOutputs = 0
      \nInterfaceCount = 0
      \nSampleRate = 0 ; Added 24Dec2022 11.9.8aa
      
      sCreateGroupSMSCommand = ""
      ; debugMsgSMS(sProcName, "sCreateGroupSMSCommand=" + sCreateGroupSMSCommand)
      For d = 0 To gnMaxConnectedDev
        If gaConnectedDev(d)\nDriver = #SCS_DRV_SMS_ASIO
          If (gaConnectedDev(d)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) ; Or (gaConnectedDev(d)\nDevType = #SCS_DEVTYPE_LIVE_INPUT)
            sConnectedPhysicalDevDesc = gaConnectedDev(d)\sPhysicalDevDesc
            gaConnectedDev(d)\bAssignedToASIOGroup = #False
            d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
            debugMsgSMS(sProcName, "grMapsForChecker\aMap(" + getDevMapName(nDevMapPtr) + ")\nFirstDevIndex=" + grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex)
            While d2 >= 0
              ; debugMsgSMS(sProcName, "grMapsForChecker\aDev(" + d2 + ")\bExists=" + strB(grMapsForChecker\aDev(d2)\bExists) + ", \nDevType=" + decodeDevType(grMapsForChecker\aDev(d2)\nDevType))
              If grMapsForChecker\aDev(d2)\bExists
                If (grMapsForChecker\aDev(d2)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) Or (grMapsForChecker\aDev(d2)\nDevType = #SCS_DEVTYPE_LIVE_INPUT)
                  ; debugMsgSMS(sProcName, "grMapsForChecker\aDev(" + d2 + ")\sPhysicalDev=" + grMapsForChecker\aDev(d2)\sPhysicalDev +
                  ;                     ", gaConnectedDev(" + d + ")\sPhysicalDevDesc=" + gaConnectedDev(d)\sPhysicalDevDesc)
                  If grMapsForChecker\aDev(d2)\sPhysicalDev = sConnectedPhysicalDevDesc
                    gaConnectedDev(d)\bAssignedToASIOGroup = #True
                    Break
                  EndIf
                EndIf
              EndIf
              d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
            Wend
            If gaConnectedDev(d)\bAssignedToASIOGroup
              \nInterfaceCount + 1
              sCreateGroupSMSCommand + " interface " + #DQUOTE$ + gaConnectedDev(d)\sPhysicalDevDesc + #DQUOTE$
              debugMsgSMS(sProcName, "sCreateGroupSMSCommand=" + sCreateGroupSMSCommand)
              gaConnectedDev(d)\nFirst0BasedOutputChanAG = nFirst0BasedOutputChanAG
              \nGroupInputs + gaConnectedDev(d)\nInputs
              \nGroupOutputs + gaConnectedDev(d)\nOutputs
              ; Changed 24Dec2022 11.9.8aa
              If \nSampleRate = 0
                \nSampleRate + gaConnectedDev(d)\nDefaultSampleRate
              EndIf
              debugMsgSMS(sProcName, "gaConnectedDev(" + d + ")\nInputs=" + gaConnectedDev(d)\nInputs +
                                     ", \nOutputs=" + gaConnectedDev(d)\nOutputs +
                                     ", \nDefaultSampleRate=" + gaConnectedDev(d)\nDefaultSampleRate)
              ; End changed 24Dec2022 11.9.8aa
              nFirst0BasedOutputChanAG + gaConnectedDev(d)\nOutputs
            EndIf
          EndIf
        EndIf
      Next d
      debugMsgSMS(sProcName, "grASIOGroup\nGroupInputs=" + \nGroupInputs + ", \nGroupOutputs=" + \nGroupOutputs)
      
      sSMSCommand = "config set asiogroup " + \sNameWithQuotes + sCreateGroupSMSCommand
      
      debugMsgSMS(sProcName, "grASIOGroup\bGroupCreated=" + strB(\bGroupCreated) + ", \nInterfaceCount=" + \nInterfaceCount + ", \nGroupInputs=" + \nGroupInputs + ", \nGroupOutputs=" + \nGroupOutputs)
      
      If \nInterfaceCount > 0
        sendSMSCommand(sSMSCommand)
        \sCreateGroupSMSCommand = sCreateGroupSMSCommand
        If grSMS\sFirstWordLC = "ok"
          \bGroupCreated = #True
          debugMsgSMS(sProcName, "grASIOGroup\bGroupCreated=" + strB(\bGroupCreated))
          \sErrorMsg = ""
        Else
          \bGroupCreated = #False
          debugMsgSMS(sProcName, "grASIOGroup\bGroupCreated=" + strB(\bGroupCreated))
          \sErrorMsg = gsSMSResponse(0)
          sMsg = "SM-S command failed:" + #CRLF$ + "C: " + sSMSCommand + #CRLF$ + "R: " + \sErrorMsg
          debugMsgSMS(sProcName, sMsg)
          ; Added 19Jan2023 11.9.8ag
          If FindString(\sErrorMsg, "Duplicate ASIOGROUP name")
            sSMSCommand = "config close interface; createASIOGroup()"
            sendSMSCommand(sSMSCommand)
            \bGroupInitialized = #False
            sSMSCommand = "config clear asiogroup " + \sNameWithQuotes + "; createASIOGroup()"
            sendSMSCommand(sSMSCommand)
            If nPass = 1
              \sErrorMsg = ""
              debugMsgSMS(sProcName, "try again")
              Continue ; Try once more, having now closed and cleared the existing asio group
            EndIf
          EndIf
          ; End added 19Jan2023 11.9.8ag
        EndIf
      EndIf
      Break ; Added 19Jan2023 11.9.8ag
    Next nPass ; Added 19Jan2023 11.9.8ag
    
  EndWith
  
  If grASIOGroup\bGroupCreated
    initInterface()
    If grASIOGroup\bGroupInitialized
      For d = 0 To gnMaxConnectedDev
        If gaConnectedDev(d)\bAssignedToASIOGroup
          gaConnectedDev(d)\bInitialized = #True
        EndIf
      Next d
    EndIf
  EndIf
  
  ; re-assign device channels to match the ASIO group channels
  If (grASIOGroup\bGroupCreated) And (grASIOGroup\bGroupInitialized)
    d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
    While d2 >= 0
      With grMapsForChecker\aDev(d2)
        If \nDevType <> #SCS_DEVTYPE_NONE
          debugMsgSMS(sProcName, "grMapsForChecker\aDev(" + d2 + ")\bExists=" + strB(\bExists) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDev=" + \sPhysicalDev +
                                 ", \nFirst0BasedOutputChanAG=" + \nFirst0BasedOutputChanAG + ", \nFirst0BasedInputChanAG=" + \nFirst0BasedInputChanAG)
        EndIf
        If \bExists
          Select \nDevType
            Case #SCS_DEVTYPE_AUDIO_OUTPUT
              For n = 0 To grASIOGroup\nMaxAsioDevIndex
                If grASIOGroup\sAsioDev(n) = \sPhysicalDev
                  nFirst0BasedOutputChanAG = grASIOGroup\nFirstOutputChanAG(n) + \nFirst0BasedOutputChan
                  ; added 17/07/2014 to handle outputs > those supported by the SM-S dongle or demo version - drops outputs back to be within range
                  ; debugMsgSMS(sProcName, "nFirst0BasedOutputChanAG=" + nFirst0BasedOutputChanAG + ", grASIOGroup\nGroupOutputs=" + grASIOGroup\nGroupOutputs)
                  If nFirst0BasedOutputChanAG > (grASIOGroup\nGroupOutputs - 1)
                    While nFirst0BasedOutputChanAG > (grASIOGroup\nGroupOutputs - 1)
                      nFirst0BasedOutputChanAG - 2
                    Wend
                    If nFirst0BasedOutputChanAG < 0
                      nFirst0BasedOutputChanAG = 0
                    EndIf
                    nChannelsAdjusted + \nNrOfDevOutputChans
                  EndIf
                  ; end added 17/07/2014
                  If \nNrOfDevOutputChans = 1
                    \s0BasedOutputRangeAG = Str(nFirst0BasedOutputChanAG)
                  Else
                    \s0BasedOutputRangeAG = Str(nFirst0BasedOutputChanAG) + "-" + Str(nFirst0BasedOutputChanAG + \nNrOfDevOutputChans - 1)
                  EndIf
                  \nFirst0BasedOutputChanAG = nFirst0BasedOutputChanAG
                  Break
                EndIf
              Next n
              debugMsgSMS(sProcName, "grMapsForChecker\aDev(" + d2 + ")\nDevType=" + decodeDevType(\nDevType) +
                                     ", \sLogicalDev=" + \sLogicalDev +
                                     ", \nFirst0BasedOutputChanAG=" + \nFirst0BasedOutputChanAG +
                                     ", \s0BasedOutputRangeAG=" + \s0BasedOutputRangeAG)
              
            Case #SCS_DEVTYPE_LIVE_INPUT
              For n = 0 To grASIOGroup\nMaxAsioDevIndex
                If grASIOGroup\sAsioDev(n) = \sPhysicalDev
                  nFirst0BasedInputChanAG = grASIOGroup\nFirstInputChanAG(n) + \nFirst0BasedInputChan
                  If \nNrOfInputChans = 1
                    \s0BasedInputRangeAG = Str(nFirst0BasedInputChanAG)
                  Else
                    \s0BasedInputRangeAG = Str(nFirst0BasedInputChanAG) + "-" + Str(nFirst0BasedInputChanAG + \nNrOfInputChans - 1)
                  EndIf
                  \nFirst0BasedInputChanAG = nFirst0BasedInputChanAG
                  Break
                EndIf
              Next n
              debugMsgSMS(sProcName, "grMapsForChecker\aDev(" + d2 + ")\nDevType=" + decodeDevType(\nDevType) +
                                     ", \sLogicalDev=" + \sLogicalDev +
                                     ", \nFirst0BasedInputChanAG=" + \nFirst0BasedInputChanAG +
                                     ", \s0BasedInputRangeAG=" + \s0BasedInputRangeAG)
              
          EndSelect
        EndIf
        d2 = \nNextDevIndex
      EndWith
    Wend
    If nChannelsAdjusted > 0
      sMsg = LangPars("SMS", "OutputsAdj", Str(nChannelsAdjusted), "1-" + Str(grASIOGroup\nGroupOutputs))
      debugMsgSMS(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
    EndIf
  EndIf
  ; end of re-assign device channels
  
  gnSuspendGetCurrInfo - 1
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure deleteASIOGroup()
  PROCNAMEC()
  Protected sSMSCommand.s
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With grASIOGroup
    If \bGroupCreated
      gnSuspendGetCurrInfo + 1
      sSMSCommand = "config close interface"
      sendSMSCommand(sSMSCommand)
      \bGroupInitialized = #False
      sSMSCommand = "config clear asiogroup " + \sNameWithQuotes
      sendSMSCommand(sSMSCommand)
      \bGroupCreated = #False
      debugMsgSMS(sProcName, "grASIOGroup\bGroupCreated=" + strB(\bGroupCreated))
      gnSuspendGetCurrInfo - 1
    EndIf
  EndWith
  
EndProcedure

Procedure initInterface()
  PROCNAMEC()
  Protected sSMSCommand.s
  Protected sMsg.s
  Protected sKey.s
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With grASIOGroup
    
    sKey = makeSCSKeyForSMS()
    
    debugMsgSMS(sProcName, "\nGroupOutputs=" + \nGroupOutputs + ", grLicInfo\nMaxAudioOutputs=" + grLicInfo\nMaxAudioOutputs)
    If (\nGroupOutputs > grLicInfo\nMaxAudioOutputs) And (grLicInfo\nMaxAudioOutputs > 0)
      \nGroupOutputs = grLicInfo\nMaxAudioOutputs
    EndIf
    
    sSMSCommand = "config set interface " + \sNameWithQuotes + " inputs " + \nGroupInputs + " outputs " + \nGroupOutputs
    If \nSampleRate > 0
      sSMSCommand + " samplerate " + \nSampleRate
    EndIf
    sSMSCommand + " mode SCS " + sKey
    sendSMSCommand(sSMSCommand)
    If grSMS\sFirstWordLC = "ok"
      \bGroupInitialized = #True
      grSMS\bInterfaceOpen = #True
    Else
      ; failed when using mode "SCS", so retry without this mode
      sSMSCommand = "config set interface " + \sNameWithQuotes + " inputs " + \nGroupInputs + " outputs " + \nGroupOutputs ; + " analogfirst"
      If \nSampleRate > 0
        sSMSCommand + " samplerate " + \nSampleRate
      EndIf
      sendSMSCommand(sSMSCommand)
      If grSMS\sFirstWordLC = "ok"
        \bGroupInitialized = #True
        grSMS\bInterfaceOpen = #True
      EndIf
    EndIf
    debugMsgSMS(sProcName, "grSMS\sFirstWordLC=" + grSMS\sFirstWordLC + ", \bGroupInitialized=" + strB(\bGroupInitialized))
    
    getSMSInputsOutputsPlaybacks()
    
    ; cap \nGroupInputs and \nGroupOutputs according to SM-S license
    If \nGroupInputs > grMMedia\nSMSMaxInputs
      \nGroupInputs = grMMedia\nSMSMaxInputs
      sMsg = "Inputs limited to " + Str(grMMedia\nSMSMaxInputs) + " by SM-S License (dongle)"
      writeSMSLogLine(sProcName, sMsg)
    EndIf
    
    If \nGroupOutputs > grMMedia\nSMSMaxOutputs
      \nGroupOutputs = grMMedia\nSMSMaxOutputs
      sMsg = "Outputs limited to " + Str(grMMedia\nSMSMaxOutputs) + " by SM-S License (dongle)"
      writeSMSLogLine(sProcName, sMsg)
    EndIf
    
    If \bGroupInitialized
      sendSMSCommand("config set gaintable xpoint " + Trim(grMMedia\sGainTableString))
      
      grMMedia\nSMSOutputsUsed = \nGroupOutputs
      debugMsgSMS(sProcName, "grMMedia\nSMSOutputsUsed=" + Str(grMMedia\nSMSOutputsUsed))
      
      buildSMSOutputArray()
      
      sendSMSCommand("set matrix off")
      
      If gbMainFormLoaded
        clearVUDisplay() ; clear VU display, and display VU labels
      EndIf
      
      If gbMainFormLoaded
        grMasterLevel\fProdMasterBVLevel = SLD_getLevel(WMN\sldMasterFader)  ; SLD_SliderValueToBVLevel(fmMain\sldMasterVolume\value)
      Else
        grMasterLevel\fProdMasterBVLevel = grProd\fMasterBVLevel
      EndIf
      debugMsgSMS(sProcName, "grMasterLevel\fProdMasterBVLevel=" + traceLevel(grMasterLevel\fProdMasterBVLevel))
      setMasterFader(grMasterLevel\fProdMasterBVLevel, #False, #True)
      debugMsgSMS(sProcName, "calling setAllInputGains()")
      setAllInputGains()
      debugMsgSMS(sProcName, "calling setAllLiveEQ()")
      setAllLiveEQ()
      
      If Len(grDriverSettings\sAudioFilesRootFolder) > 0
        sendSMSCommand("set chan p0 track path " + #DQUOTE$ + grDriverSettings\sAudioFilesRootFolder + #DQUOTE$)
        If grSMS\sFirstWordLC = "ok"
          debugMsgSMS(sProcName, "grDriverSettings\sAudioFilesRootFolder OK")
        Else
          debugMsgSMS(sProcName, "grDriverSettings\sAudioFilesRootFolder not accessible")
        EndIf
      EndIf
      
    EndIf
    
  EndWith
  
  debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure clearPChanResponses(nPChan)
  ; PROCNAMEC()
  Protected sMyPChan.s, sMyPXChan.s, nPtr
  
  sMyPChan = "P" + nPChan
  sMyPXChan = "PX" + nPChan
  
  With grSMS
    
    nPtr = FindString(\sPStatusResponse, sMyPChan, 1)
    ; debugMsgSMS(sProcName, "sMyPChan=" + sMyPChan + ", \sPStatusResponse=" + \sPStatusResponse + ", nPtr=" + nPtr)
    If nPtr > 0
      \sPStatusResponse = ReplaceString(\sPStatusResponse, sMyPChan + "=", "ZZ=")
      \sPStatusResponse = ReplaceString(\sPStatusResponse, sMyPChan + ".", "ZZ.")
      ; debugMsgSMS(sProcName, "\sPStatusResponse=" + \sPStatusResponse)
    EndIf
    
    nPtr = FindString(\sPTimeResponse, sMyPChan, 1)
    ; debugMsgSMS(sProcName, "sMyPChan=" + sMyPChan + ", \sPTimeResponse=" + \sPTimeResponse + ", nPtr=" + nPtr)
    If nPtr > 0
      \sPTimeResponse = ReplaceString(\sPTimeResponse, sMyPChan + "=", "ZZ=")
      \sPTimeResponse = ReplaceString(\sPTimeResponse, sMyPChan + ".", "ZZ.")
      ; debugMsgSMS(sProcName, "\sPTimeResponse=" + \sPTimeResponse)
    EndIf
    
    nPtr = FindString(\sPXGainResponse, sMyPXChan, 1)
    ; debugMsgSMS(sProcName, "sMyPXChan=" + sMyPXChan + ", \sPXGainResponse=" + \sPXGainResponse + ", nPtr=" + nPtr)
    If nPtr > 0
      \sPXGainResponse = ReplaceString(\sPXGainResponse, sMyPXChan + "=", "ZZ=")
      \sPXGainResponse = ReplaceString(\sPXGainResponse, sMyPXChan + ".", "ZZ.")
      ; debugMsgSMS(sProcName, "\sPXGainResponse=" + \sPXGainResponse)
    EndIf
    
  EndWith
  
  ; debugMsgSMS(sProcName, #SCS_END)
  
EndProcedure

Procedure clearAllResponses()
  PROCNAMEC()
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With grSMS
    \sPStatusResponse = ""
    \sPTimeResponse = ""
    \sPXGainResponse = ""
    \sOVUResponse = ""
  EndWith
  
EndProcedure

Procedure buildVUCommandString()
  PROCNAMEC()
  Protected nFirstOutputIndex, nLastOutputIndex
  Protected nFirstInputIndex, nLastInputIndex
  Protected n
  Protected nStart, nPrev
  Protected sCommandString.s, sPart.s
  
  debugMsgSMS(sProcName, #SCS_START)
  
  With grMVUD
    If gnSMSOutputCount < 1
      \nSMSFirstOutputIndex = 0
      \nSMSLastOutputIndex = 0
      gnVUMeters = 0
      gnVUInputMeters = 0
      grSMS\sOVUCommandString = ""
      debugMsgSMS(sProcName, "grSMS\sOVUCommandString=" + grSMS\sOVUCommandString)
      ProcedureReturn
    EndIf
  EndWith
  
  If gnVUBank < 0
    gnVUBank = Round((gnSMSOutputCount - 1) / gnVUMaxMeters, #PB_Round_Down)
  EndIf
  
  nFirstOutputIndex = gnVUMaxMeters * gnVUBank
  If nFirstOutputIndex > (gnSMSOutputCount - 1)
    ; something's wrong, or the user has clicked the right pointer after the last output, so revert to start position
    gnVUBank = 0
    nFirstOutputIndex = 0
  EndIf
  
  nLastOutputIndex = nFirstOutputIndex + gnVUMaxMeters - 1
  If nLastOutputIndex > (gnSMSOutputCount - 1)
    nLastOutputIndex = (gnSMSOutputCount - 1)
    nFirstOutputIndex = nLastOutputIndex - gnVUMaxMeters + 1
    If nFirstOutputIndex < 0
      nFirstOutputIndex = 0
    EndIf
  EndIf
  
  nStart = -999999
  nPrev = -999999
  For n = nFirstOutputIndex To nLastOutputIndex
    If n <= (gnSMSOutputCount - 1)
      With gaSMSOutput(n)
        If \n0BasedOutputChanAG <> (nPrev + 1)
          If nPrev >= 0
            If nPrev = nStart
              sCommandString + " " + nStart
            Else
              sCommandString + " " + nStart + "-" + nPrev
            EndIf
          EndIf
          nStart = \n0BasedOutputChanAG
        EndIf
        nPrev = \n0BasedOutputChanAG
      EndWith
    EndIf
  Next n
  If nPrev >= 0
    If nPrev = nStart
      sCommandString + " " + nStart
    Else
      sCommandString + " " + nStart + "-" + nPrev
    EndIf
  EndIf
  
  With grMVUD
    debugMsgSMS(sProcName, "gnSMSOutputCount=" + gnSMSOutputCount + ", gnVUMaxMeters=" + gnVUMaxMeters +
                        ", nFirstOutputIndex=" + nFirstOutputIndex + ", nLastOutputIndex=" + nLastOutputIndex)
    \nSMSFirstOutputIndex = nFirstOutputIndex
    \nSMSLastOutputIndex = nLastOutputIndex
    gnVUMeters = nLastOutputIndex - nFirstOutputIndex + 1
    
    gnVUInputMeters = 0   ; may be changed below
    
    If Len(grSMS\sOVUCommandString) > 0 And Len(sCommandString) > 0
      grSMS\bVUCommandStringChanged = #True
    EndIf
    If sCommandString
      grSMS\sOVUCommandString = "get vu o " + Trim(sCommandString)
      If grTestLiveInput\bRunningTestLiveInput
        grSMS\sOVUCommandString + " i " + grTestLiveInput\nTestLiveInputChan
        gnVUInputMeters = 1
      EndIf
    Else
      If grTestLiveInput\bRunningTestLiveInput
        grSMS\sOVUCommandString = "get vu i " + grTestLiveInput\nTestLiveInputChan
        gnVUInputMeters = 1
      EndIf
    EndIf
    debugMsgSMS(sProcName, "gnVUMeters=" + gnVUMeters + ", gnVUInputMeters=" + gnVUInputMeters + ", grSMS\sOVUCommandString=" + grSMS\sOVUCommandString)
    grSMS\sOVUResponse = ""  ; clear any existing response
  EndWith

EndProcedure

Procedure buildSMSOutputArray()
  PROCNAMEC()
  Protected nOutputIndex
  Protected nDevMapPtr
  Protected d, n
  Protected sLogicalDev.s
  Protected nThis0BasedOutputChanAG
  Protected n2, nExistingEntryIndex
  Protected nPhysicalDevPtr
  
  debugMsgSMS(sProcName, #SCS_START + ", grASIOGroup\nGroupOutputs=" + grASIOGroup\nGroupOutputs)

  gnSMSOutputCount = 0
  If grASIOGroup\nGroupOutputs < 1
    ProcedureReturn
  EndIf
  
  ReDim gaSMSOutput(grASIOGroup\nGroupOutputs - 1)  ; max size
  nOutputIndex = -1
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    d = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While d >= 0
      If grMaps\aDev(d)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
        sLogicalDev = grMaps\aDev(d)\sLogicalDev
        If sLogicalDev
          debugMsgSMS(sProcName, "sLogicalDev=" + sLogicalDev + ", grMaps\aDev(" + d + ")\nNrOfDevOutputChans=" + grMaps\aDev(d)\nNrOfDevOutputChans)
          For n = 0 To (grMaps\aDev(d)\nNrOfDevOutputChans - 1)
            ; nThis0BasedOutputChan = (grMaps\aDev(d)\nFirst1BasedOutputChan - 1) + n
            nPhysicalDevPtr = grMaps\aDev(d)\nPhysicalDevPtr
            If nPhysicalDevPtr >= 0
              debugMsgSMS(sProcName, "calling setDevTypeVariablesForSMS(@grMaps\aDev(" + d + "))") ; Added 27Dec2022 11.9.8aa
              setDevTypeVariablesForSMS(@grMaps\aDev(d)) ; Added 27Dec2022 11.9.8aa
              debugMsgSMS(sProcName, "gaAudioDev(" + nPhysicalDevPtr + ")\nFirst0BasedOutputChanAG=" + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG) ; Added 27Dec2022 11.9.8aa
              ; nThis0BasedOutputChanAG = grMaps\aDev(d)\nFirst0BasedOutputChan + n + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG
              nThis0BasedOutputChanAG = grMaps\aDev(d)\nFirst0BasedOutputChanAG + n ; Changed 27Dec2022 11.9.8aa
              ; check if there is already an entry in gaSMSOutput() for this n0BasedOutputChanAG
              nExistingEntryIndex = -1
              For n2 = 0 To nOutputIndex
                CheckSubInRange(n2, ArraySize(gaSMSOutput()), "gaSMSOutput()")
                If gaSMSOutput(n2)\n0BasedOutputChanAG = nThis0BasedOutputChanAG
                  nExistingEntryIndex = n2
                  Break
                EndIf
              Next n2
              If nExistingEntryIndex >= 0
                ; an entry already exists for this n0BasedOutputChan
                CheckSubInRange(nExistingEntryIndex, ArraySize(gaSMSOutput()), "gaSMSOutput()")
                With gaSMSOutput(nExistingEntryIndex)
                  \nLastDevPtr = d
                EndWith
              Else
                ; new entry
                nOutputIndex + 1
                If nOutputIndex > ArraySize(gaSMSOutput())
                  ReDim gaSMSOutput(nOutputIndex+8)
                EndIf
                CheckSubInRange(nOutputIndex, ArraySize(gaSMSOutput()), "gaSMSOutput()")
                With gaSMSOutput(nOutputIndex)
                  ; \n0BasedOutputChanAG = (grMaps\aDev(d)\nFirst1BasedOutputChan - 1) + n
                  ; \n0BasedOutputChanAG = grMaps\aDev(d)\nFirst0BasedOutputChan + n + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG
                  \n0BasedOutputChanAG = grMaps\aDev(d)\nFirst0BasedOutputChanAG + n ; Changed 27Dec2022 11.9.8aa
                  ; added 16/07/2014 to handle outputs > those supported by the SM-S dongle or demo version - drops outputs back to be within range
                  While \n0BasedOutputChanAG > (grASIOGroup\nGroupOutputs - 1)
                    \n0BasedOutputChanAG - 2
                  Wend
                  ; end added 16/07/2014
                  \nFirstDevPtr = d
                  \nLastDevPtr = d
                EndWith
              EndIf
            EndIf
          Next n
        EndIf
      EndIf
      d = grMaps\aDev(d)\nNextDevIndex
    Wend
    
    For n = 0 To nOutputIndex
      With gaSMSOutput(n)
        debugMsgSMS(sProcName, "gaSMSOutput(" + n + ")\n0BasedOutputChanAG=" + \n0BasedOutputChanAG +
                            ", \nFirstDevPtr=" + \nFirstDevPtr + ", \nLastDevPtr=" + \nLastDevPtr)
      EndWith
    Next n
    
  EndIf
  gnSMSOutputCount = nOutputIndex + 1
  debugMsgSMS(sProcName, #SCS_END + ", gnSMSOutputCount=" + gnSMSOutputCount)
  
EndProcedure

Procedure listSMSSyncPoints()
  PROCNAMEC()
  Protected n
  
  For n = 0 To gnMaxSMSSyncPoint
    With gaSMSSyncPoint(n)
      debugMsgSMS(sProcName, "gaSMSSyncPoint(" + n + ")\nAudPtr=" + getAudLabel(\nAudPtr) + ", \nSyncType=" + \nSyncType + ", \nSyncPos=" + \nSyncPos +
                             ", \sSyncProcedure=" + \sSyncProcedure + ", \nLoopInfoIndex=" + \nLoopInfoIndex + ", \nLoopSyncIndex=" + \nLoopSyncIndex +
                             ", \bLoopReleased=" + strB(\bLoopReleased))
    EndWith
  Next n
EndProcedure

Procedure listPlaybackArray()
  PROCNAMEC()
  Protected n
  
  If gbUseSMS
    For n = 0 To ArraySize(gaPlayback())
      With gaPlayback(n)
        If \nAssignedTo <> #SCS_PLB_UNASSIGNED
          debugMsgSMS(sProcName, "gaPlayback(" + n + ")\nAssignedTo=" + decodePLBAssignedTo(\nAssignedTo) + ", \nAudPtr=" + getAudLabel(\nAudPtr) +
                                 ", \nFileTrackNo=" + \nFileTrackNo + ", \nPrimaryChan=p" + \nPrimaryChan + ", \sPChanListPrimary=" + \sPChanListPrimary + ; ", \sTrackCommandString=" + \sTrackCommandString +
                                 ", \qTimeAssigned=" + traceTime(\qTimeAssigned))
        EndIf
      EndWith
    Next n
  EndIf
EndProcedure

Procedure setFastCuePlayCommandString(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, k
  Protected sPlayCommandString.s, sLiveCommandString.s
  Protected sSyncPChanList.s
  Protected bExitLoops
  
  With aCue(pCuePtr)
    
    \sFastCuePlayCommandString = ""
    ; \sFastCueLiveCommandString = ""
    
    If gbUseBASS
      ProcedureReturn
    EndIf
    
    Select aCue(pCuePtr)\nActivationMethodReqd
      Case #SCS_ACMETH_MAN, #SCS_ACMETH_AUTO, #SCS_ACMETH_HK_TRIGGER, #SCS_ACMETH_TIME  ; exclude activation types requiring confirmation, and toggle, note and step variations of hotkeys
        j = aCue(pCuePtr)\nFirstSubIndex
        While (j >= 0) And (bExitLoops = #False)
          If aSub(j)\bSubTypeF
            k = aSub(j)\nFirstAudIndex
            While (k >= 0) And (bExitLoops = #False)
              If (aAud(k)\nMaxLoopInfo) And (usingLoopXFade(k))
                ; exclude cues with cross-faded loops
                sPlayCommandString = ""
                sLiveCommandString = ""
                bExitLoops = #True
              Else
                sSyncPChanList = aAud(k)\sSyncChanList
                If FindString(sPlayCommandString+" ", sSyncPChanList+" ") = 0   ; add " " to each to make sure something like p1 doesn't match p10
                  sPlayCommandString + " " + sSyncPChanList
                EndIf
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
            
          ElseIf aSub(j)\bSubTypeI
            CompilerIf 1=2
              k = aSub(j)\nFirstAudIndex
              While (k >= 0) And (bExitLoops = #False)
                sLiveCommandString + " " + aAud(k)\sAudChanList
                k = aAud(k)\nNextAudIndex
              Wend
            CompilerEndIf
            
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
    EndSelect
    
    aCue(pCuePtr)\sFastCuePlayCommandString = Trim(ReplaceString(sPlayCommandString, "  ", " "))
    debugMsgSMS(sProcName, "\sFastCuePlayCommandString=" + sPlayCommandString)
    ; aCue(pCuePtr)\sFastCueLiveCommandString = Trim(ReplaceString(sLiveCommandString, "  ", " "))
    ; debugMsgSMS(sProcName, "\sFastCueLiveCommandString=" + sLiveCommandString)
    
  EndWith
  
EndProcedure

Procedure primeAndInitSMS(bConnectionOptional=#False)
  PROCNAMEC()
  Protected n, sTmp.s, bConnectingToSMS, nReply
  Protected sMsg.s, sStatus.s
  Protected nMousePointer
  Protected qTimeConnectionStarted.q, qTimeNow.q
  Protected sTitle.s, sPrompt.s, sButtons.s
  Protected sSMSHost.s, sSMSPort.s
  Protected bModalDisplayed
  Protected nRetryBtn, nDevMapBtn, nCloseFileBtn, nCloseSCSBtn
  Protected i
  Protected bCanSwitch

  debugMsgSMS(sProcName, #SCS_START)
  
  If gnSMSNetworkMutex = 0
    gnSMSNetworkMutex = CreateMutex()
    debugMsgSMS(sProcName, "gnSMSNetworkMutex=" + Str(gnSMSNetworkMutex))
  EndIf
  
  debugMsgSMS(sProcName, "initialising SM-S")
  setSMSDefaults()
  debugMsgSMS(sProcName, "opening TCP connection with SM-S")
  bConnectingToSMS = #True
  qTimeConnectionStarted = ElapsedMilliseconds()
  While bConnectingToSMS
    openSMSConnection()
    If (grSMS\nSMSClientConnection = 0) And (bConnectionOptional)
      bConnectingToSMS = #False
      Break
    EndIf
    If grSMS\sFirstWordLC = "ok"
      bConnectingToSMS = #False
      Break
    Else
      nMousePointer = GetMouseCursor()
      bModalDisplayed = gbModalDisplayed
      SetMouseCursorNormal()
      ensureSplashNotOnTop()
      gbModalDisplayed = #True
      sTitle = Lang("SMS", "msgTitle")
      sPrompt = Lang("SMS", "Failed") + "||"
      If grDriverSettings\bSMSOnThisMachine
        ; sPrompt + Lang("SMS", "SMSOnThisMachine") + "|"
        sPrompt + Lang("SMS", "SMSOnThisMachine") + ": "
        sSMSHost = "127.0.0.1"
        sSMSPort = "20000"
      Else
        sSMSHost = grDriverSettings\sSMSHost
        sSMSPort = "20000"
      EndIf
      sPrompt + LangPars("SMS", "SMSAddr", sSMSHost, sSMSPort) + "||"
      debugMsgSMS(sProcName, sTitle + ": " + sPrompt)
      nRetryBtn = 1
      nDevMapBtn = 2
      If gbInLoadCueFile
        ; if in loadCueFile() then offer the option to close the cue file
        nCloseFileBtn = 3
        nCloseSCSBtn = 4
        sButtons = Lang("SMS","btnTryAgain") + "|" + Lang("DevMap","chgDevMap") + "|" + Lang("SMS","btnCloseFile") + "|" + Lang("SMS","btnCloseSCS")
      Else
        nCloseFileBtn = 0   ; button not displayed
        nCloseSCSBtn = 3
        sButtons = Lang("SMS","btnTryAgain") + "|" + Lang("DevMap","chgDevMap") + "|" + Lang("SMS","btnCloseSCS")
      EndIf
      nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 140, #IDI_EXCLAMATION)
      gbModalDisplayed = bModalDisplayed
      SetMouseCursor(nMousePointer)
      Select nReply
        Case nRetryBtn
          ; retry connection to SM-S
          debugMsgSMS(sProcName, "user requested retry connection")
          
        Case nDevMapBtn
          debugMsgSMS(sProcName, "user requested review/change device map")
          gbReviewDevMap = #True
          debugMsgSMS(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap))
          ProcedureReturn #False
          
        Case nCloseFileBtn
          ; close cue file
          debugMsgSMS(sProcName, "user requested close cue file")
          gbCloseCueFile = #True
          ProcedureReturn #False
          
        Case nCloseSCSBtn
          ; close SCS
          gbForceTracing = #True
          debugMsgSMS(sProcName, "user requested close SCS")
          closeLogFile()
          Debug "END OF RUN"
          End
          
      EndSelect
    EndIf
  Wend
  debugMsgSMS(sProcName, "grSMS\nSMSClientConnection=" + grSMS\nSMSClientConnection)
  If grSMS\nSMSClientConnection = 0
    ProcedureReturn #False
  EndIf
  
  initSMS()
  
  debugMsgSMS(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure.s splitDuplicatePXChans(pAudPtr, sPXChanList.s, bFirstDev, bAltChannel)
  PROCNAMECA(pAudPtr)
  Protected sOldPXChanList.s, sNewPXChanList.s
  Protected sPXChanListLeft.s, sPXChanListRight.s
  Static sPrevPXChanLists.s
  Protected nPtr, nPXPtr, nSpacePtr
  Protected sPXItem.s, sNewPXItem.s
  Protected nPrevPtr
  Protected nDotPtr
  Protected sOldPChanNo.s
  Protected nOldPChanNo, nNewPChanNo
  Protected n
  Protected nPrimaryChan
  Protected sCmd.s
  
  debugMsgSMS(sProcName, #SCS_START + ", sPXChanList=" + sPXChanList + ", bFirstDev=" + strB(bFirstDev) + ", bAltChannel=" + strB(bAltChannel))
  
  sOldPXChanList = sPXChanList + " "
  
  CompilerIf 1=1    ; added 17Nov2017 11.6.2.2ad following logs from J Hutchinson that showed duplicate entries being created in gaPlaybacks(). not sure why this 'split duplicates' procedure exists.
    sPrevPXChanLists = "" ; setting this static variable blank unconditionally prevents any splitting
  CompilerElse    
    If bFirstDev
      sPrevPXChanLists = ""
    EndIf
  CompilerEndIf
  
  nPtr = 1
  While nPtr < Len(sOldPXChanList)
    nPXPtr = FindString(sOldPXChanList, "px", nPtr)
    If nPXPtr = 0
      ; no more px items found so force While loop to end
      nPtr = Len(sOldPXChanList)
    Else
      nSpacePtr = FindString(sOldPXChanList, " ", nPXPtr)
      sPXItem = Mid(sOldPXChanList, nPXPtr, (nSpacePtr - nPXPtr))
      sNewPXItem = sPXItem
      ; now search for this px item in previous lists
      nPrevPtr = InStr(sPrevPXChanLists, sPXItem + " ")
      If nPrevPtr > 0
        ; px item already exists so convert the current item to a silent (fake) output
        nDotPtr = InStr(sPXItem, ".")
        sOldPChanNo = Mid(sPXItem, 3, nDotPtr-1)
        nOldPChanNo = Val(sOldPChanNo)
        ; search for an unassigned playback channel
        nNewPChanNo = -1
        For n = 0 To ArraySize(gaPlayback())
          With gaPlayback(n)
            ;debugMsgSMS(sProcName, "gaPlayback(" + n + ")\nAssignedTo=" + decodePLBAssignedTo(\nAssignedTo) + ", \sFileName=" + GetFilePart(\sFileName) + ", \nFileTrackNo=" + \nFileTrackNo)
            If \nAssignedTo = #SCS_PLB_UNASSIGNED
              nNewPChanNo = n
              Break
            EndIf
          EndWith
        Next n
        ; debugMsgSMS(sProcName, "sPXItem=" + sPXItem + ", nOldPChanNo=" + Str(nOldPChanNo) + ", nNewPChanNo=" + Str(nNewPChanNo))
        If nNewPChanNo >= 0
          ; unassigned playback channel found
          ; replicate previously-assigned playback channel
          gaPlayback(nNewPChanNo) = gaPlayback(nOldPChanNo)
          With gaPlayback(nNewPChanNo)
            \sPChanListPrimary = ""  ; held for primary channel only
            sCmd = "set chan p" + nNewPChanNo + \sTrackCommandString
            sendSMSCommand(sCmd)
            ; debugMsgSMS(sProcName, "grSMS\sFirstWordLC=" + grSMS\sFirstWordLC)
            If grSMS\sFirstWordLC = "ok"
              sNewPXItem = "px" + nNewPChanNo + Mid(sPXItem, nDotPtr)
              debugMsgSMS(sProcName, "sPXItem=" + sPXItem + ", sNewPXItem=" + sNewPXItem)
              ; mute crosspoints
              sCmd = "set chan px" + nNewPChanNo + ".0-" + Str(grASIOGroup\nGroupOutputs-1) + " gain 0"
              sendSMSCommand(sCmd)
              ; update list of playback channels
              nPrimaryChan = \nPrimaryChan
              gaPlayback(nPrimaryChan)\sPChanListPrimary + " p" + nNewPChanNo
              If bAltChannel = #False
                aAud(pAudPtr)\sAudPChanList = gaPlayback(nPrimaryChan)\sPChanListPrimary
              Else
                aAud(pAudPtr)\sAltAudPChanList = gaPlayback(nPrimaryChan)\sPChanListPrimary
              EndIf
            EndIf
          EndWith
        EndIf
      EndIf
      sNewPXChanList + sNewPXItem + " "
      nPtr = nSpacePtr    ; position nPtr after current item
    EndIf
  Wend
  
  sPrevPXChanLists + Trim(sNewPXChanList) + " "
  
  debugMsgSMS(sProcName, #SCS_END + ", returning sNewPXChanList=" + Trim(sNewPXChanList))
  ProcedureReturn Trim(sNewPXChanList)
  
EndProcedure

Procedure activateAudInputs(pAudPtr, sCallingProcName)
  PROCNAMECA(pAudPtr)
  Protected d, d2
  Protected nDevMapDevPtr
  Protected sSMSCommandString.s
  Protected sSMSIChans.s, sSMSXChans.s
  Protected sInputGainDB.s
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      sSMSCommandString = "set chan"
      For d = 0 To grLicInfo\nMaxLiveDevPerAud
        nDevMapDevPtr = \nInputDevMapDevPtr[d]
        If nDevMapDevPtr >= 0
          If grMaps\aDev(nDevMapDevPtr)\nFirst1BasedInputChan >= 1
            If grMaps\aDev(nDevMapDevPtr)\nInputPlayCount = 0
              If Len(sInputGainDB) > 0
                If grMaps\aDev(nDevMapDevPtr)\sInputGainDB <> sInputGainDB
                  sSMSIChans + " gaindb " + sInputGainDB
                  sInputGainDB = grMaps\aDev(nDevMapDevPtr)\sInputGainDB
                EndIf
                sSMSIChans + " i" + Str(grMaps\aDev(nDevMapDevPtr)\nFirst1BasedInputChan - 1)
              EndIf
            EndIf
            grMaps\aDev(nDevMapDevPtr)\nInputPlayCount + 1
          EndIf
          For d2 = 0 To grLicInfo\nMaxAudDevPerAud
            
          Next d2
        EndIf
      Next d
      If Len(sInputGainDB) > 0
        sSMSIChans + " gaindb " + sInputGainDB
      EndIf
      ; If nInputsIncluded > 0
        ; sSMSCommandString + " gain 1"
        ; sendSMSCommand(sSMSCommandString)
      ; EndIf
      
    EndWith
  EndIf
EndProcedure

Procedure deactivateAudInputs(pAudPtr, sCallingProcName.s)
  PROCNAMECA(pAudPtr)
  Protected d
  Protected nDevMapDevPtr
  Protected sSMSCommandString.s
  Protected nInputsIncluded
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      sSMSCommandString = "set chan"
      For d = 0 To grLicInfo\nMaxLiveDevPerAud
        nDevMapDevPtr = \nInputDevMapDevPtr[d]
        If nDevMapDevPtr >= 0
          If grMaps\aDev(nDevMapDevPtr)\nFirst1BasedInputChan >= 1
            grMaps\aDev(nDevMapDevPtr)\nInputPlayCount - 1
            If grMaps\aDev(nDevMapDevPtr)\nInputPlayCount = 0 ; only deactivate when there are no more Aud's with this input channel active
              nInputsIncluded + 1
              sSMSCommandString + " i" + Str(grMaps\aDev(nDevMapDevPtr)\nFirst1BasedInputChan - 1)
            EndIf
          EndIf
        EndIf
      Next d
      If nInputsIncluded > 0
        sSMSCommandString + " gain 0; " + sCallingProcName
        sendSMSCommand(sSMSCommandString)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure adjustLiveEQ(*rDev.tyDevMapDev, bSetOnOff=#False)
  PROCNAMEC()
  Protected sSMSCommandString.s
  Protected nBands
  Protected nBandNo, n
  Protected fBandWidth.f
  Protected bSendSMSMsg
  
  With *rDev
    If grSMS\bInterfaceOpen
      If Len(Trim(\s0BasedInputRangeAG)) > 0
        sSMSCommandString + "set chan i" + Trim(\s0BasedInputRangeAG)
        If \bInputEQOn = #False
          If bSetOnOff
            sSMSCommandString + " eq off"
            bSendSMSMsg = #True
          EndIf
        Else
          If \bInputLowCutSelected
            nBands + 1
          EndIf
          For n = 0 To #SCS_MAX_EQ_BAND
            If \aInputEQBand[n]\bEQBandSelected
              nBands + 1
            EndIf
          Next n
          If nBands = 0
            ; nb shouldn't get here because \bInputEQOn should be #False if the above 'selected' flags are all #False
            If bSetOnOff
              sSMSCommandString + " eq off ; (b)"
              bSendSMSMsg = #True
            EndIf
          Else
            sSMSCommandString + " eq on bands " + Str(nBands)
          EndIf
          
          If \bInputLowCutSelected
            nBandNo + 1
            sSMSCommandString + " eq band " + Str(nBandNo) + " on shape hp12 freq " + Str(\nInputLowCutFreq) + " gaindb -100"
            bSendSMSMsg = #True
          EndIf
          
          For n = 0 To #SCS_MAX_EQ_BAND
            If \aInputEQBand[n]\bEQBandSelected
              nBandNo + 1
              sSMSCommandString + " eq band " + Str(nBandNo) + " on shape bp"
              sSMSCommandString + " freq " + Str(\aInputEQBand[n]\nEQFreq)
              sSMSCommandString + " gaindb " + \aInputEQBand[n]\sEQGainDB
              ; sSMSCommandString + " q " + StrF(\aInputEQBand[n]\fEQQ,0)
              If \aInputEQBand[n]\fEQQ > 0
                fBandWidth = 1.0 / \aInputEQBand[n]\fEQQ
                sSMSCommandString + " bw " + StrF(fBandWidth,3) + "; Q=" + StrF(\aInputEQBand[n]\fEQQ,1)
              EndIf
              bSendSMSMsg = #True
            EndIf
          Next n
          
        EndIf
        
        If bSendSMSMsg
          sendSMSCommand(sSMSCommandString, #True)
        EndIf
        
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure setAllLiveEQ()
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapDevPtr
  Protected sLogicalDev.s
  Protected d
  
  If gbUseSMS
    debugMsgSMS(sProcName, #SCS_START)
    
    For d = 0 To grProd\nMaxLiveInputLogicalDev
      sLogicalDev = grProd\aLiveInputLogicalDevs(d)\sLogicalDev
      If sLogicalDev
        nDevMapPtr = grProd\nSelectedDevMapPtr
        If nDevMapPtr >= 0
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
          If nDevMapDevPtr >= 0
            adjustLiveEQ(@grMaps\aDev(nDevMapDevPtr), #True)
          EndIf
        EndIf
      EndIf
    Next d
    
    debugMsgSMS(sProcName, #SCS_END)
  EndIf
  
EndProcedure

Procedure adjust0BasedOutputChanIfReqd(p0BasedOutputChan, pAudioDriver=-1)
  PROCNAMEC()
  Protected nAudioDriver
  Protected n0BasedOutputChan
  
  n0BasedOutputChan = p0BasedOutputChan
  If pAudioDriver = -1
    nAudioDriver = getCurrAudioDriver()
  Else
    nAudioDriver = pAudioDriver
  EndIf
  If (nAudioDriver = #SCS_DRV_SMS_ASIO) And (grASIOGroup\bGroupInitialized)
    While n0BasedOutputChan > (grASIOGroup\nGroupOutputs - 1)
      n0BasedOutputChan - 2
    Wend
    If n0BasedOutputChan < 0
      n0BasedOutputChan = 0
    EndIf
  EndIf
  ProcedureReturn n0BasedOutputChan
EndProcedure

Procedure setDevTypeVariablesForSMS(*rDev.tyDevMapDev)
  PROCNAMEC()
  Protected n, nFirst0BasedOutputChanAG, nFirst0BasedInputChanAG
  
  With *rDev
    Select \nDevType
      Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; #SCS_DEVTYPE_AUDIO_OUTPUT
        \nFirst1BasedOutputChan = getFirst1BasedChanFromRange(\s1BasedOutputRange)
        \nFirst0BasedOutputChan = \nFirst1BasedOutputChan - 1
        \nNrOfDevOutputChans = getNumChansFromRange(\s1BasedOutputRange)
        debugMsg(sProcName, "*rDev\sPhysicalDev=" + \sPhysicalDev + ", \s1BasedOutputRange=" + \s1BasedOutputRange + ", \nFirst0BasedOutputChan=" + \nFirst0BasedOutputChan + ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
        debugMsg(sProcName, "grASIOGroup\nMaxAsioDevIndex=" + grASIOGroup\nMaxAsioDevIndex) ; SCS 11.9.8aa
        For n = 0 To grASIOGroup\nMaxAsioDevIndex
          debugMsg(sProcName, "grASIOGroup\sAsioDev(" + n + ")=" + grASIOGroup\sAsioDev(n)) ; SCS 11.9.8aa
          If grASIOGroup\sAsioDev(n) = \sPhysicalDev
            debugMsg(sProcName, "grASIOGroup\nFirstOutputChanAG(" + n + ")=" + grASIOGroup\nFirstOutputChanAG(n)) ; SCS 11.9.8aa
            nFirst0BasedOutputChanAG = grASIOGroup\nFirstOutputChanAG(n) + \nFirst0BasedOutputChan
            ; added 17/07/2014 to handle outputs > those supported by the SM-S dongle or demo version - drops outputs back to be within range
            ; debugMsgSMS(sProcName, "nFirst0BasedOutputChanAG=" + nFirst0BasedOutputChanAG + ", grASIOGroup\nGroupOutputs=" + grASIOGroup\nGroupOutputs)
            If nFirst0BasedOutputChanAG > (grASIOGroup\nGroupOutputs - 1)
              While nFirst0BasedOutputChanAG > (grASIOGroup\nGroupOutputs - 1)
                nFirst0BasedOutputChanAG - 2
              Wend
              If nFirst0BasedOutputChanAG < 0
                nFirst0BasedOutputChanAG = 0
              EndIf
            EndIf
            ; end added 17/07/2014
            If \nNrOfDevOutputChans = 1
              \s0BasedOutputRangeAG = Str(nFirst0BasedOutputChanAG)
            Else
              \s0BasedOutputRangeAG = Str(nFirst0BasedOutputChanAG) + "-" + Str(nFirst0BasedOutputChanAG + \nNrOfDevOutputChans - 1)
            EndIf
            \nFirst0BasedOutputChanAG = nFirst0BasedOutputChanAG
            Break
          EndIf
        Next n
        debugMsg(sProcName, "*rDev\nFirst0BasedOutputChanAG=" + \nFirst0BasedOutputChanAG) ; SCS 11.9.8aa
        
      Case #SCS_DEVTYPE_LIVE_INPUT  ; #SCS_DEVTYPE_LIVE_INPUT
        \nFirst1BasedInputChan = getFirst1BasedChanFromRange(\s1BasedInputRange)
        \nFirst0BasedInputChan = \nFirst1BasedInputChan - 1
        \nNrOfInputChans = getNumChansFromRange(\s1BasedInputRange)
        ; debugMsg(sProcName, "\nFirst0BasedInputChan=" + \nFirst0BasedInputChan + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan + ", \nNrOfInputChans=" + \nNrOfInputChans)
        For n = 0 To grASIOGroup\nMaxAsioDevIndex
          If grASIOGroup\sAsioDev(n) = \sPhysicalDev
            nFirst0BasedInputChanAG = grASIOGroup\nFirstInputChanAG(n) + \nFirst0BasedInputChan
            If \nNrOfInputChans = 1
              \s0BasedInputRangeAG = Str(nFirst0BasedInputChanAG)
            Else
              \s0BasedInputRangeAG = Str(nFirst0BasedInputChanAG) + "-" + Str(nFirst0BasedInputChanAG + \nNrOfInputChans - 1)
            EndIf
            \nFirst0BasedInputChanAG = nFirst0BasedInputChanAG
            Break
          EndIf
        Next n
        debugMsg(sProcName, "*rDev\nFirst0BasedInputChanAG=" + \nFirst0BasedInputChanAG) ; SCS 11.9.8aa
        
    EndSelect
  EndWith
EndProcedure

Procedure checkUsingPlaybackRateChangeOnly(bEditingASubCue=#False)
  PROCNAMEC()
  Protected i, j, k, bDisplayWarning, bListThisSub, sSubs.s
  Protected sMsg.s, sButton.s, sDontTellMeAgainText.s, nOption
  
  ; debugMsg(sProcName, #SCS_START)
  
  If grTempoEtc\bDontTellMeAgainAboutPlaybackRateChangeOnly = #False And gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
    If bEditingASubCue
      ; called when editing a sub-cue that we know has a change tempo or pitch action
      bDisplayWarning = #True
    Else
      For i = 1 To gnLastCue
        If aCue(i)\bCueEnabled
          If aCue(i)\bSubTypeF Or aCue(i)\bSubTypeL
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                bListThisSub = #False
                If aSub(j)\bSubTypeF And aSub(j)\bSubPlaceHolder = #False
                  k = aSub(j)\nFirstAudIndex
                  Select aAud(k)\nAudTempoEtcAction
                    Case #SCS_AF_ACTION_TEMPO, #SCS_AF_ACTION_PITCH
                      bDisplayWarning = #True
                      bListThisSub = #True
                  EndSelect
                ElseIf aSub(j)\bSubTypeL
                  Select aSub(j)\nLCAction
                    Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
                      bDisplayWarning = #True
                      bListThisSub = #True
                  EndSelect
                EndIf
                If bListThisSub
                  If Len(sSubs) = 0
                    sSubs = "|  " + getSubLabel(j)
                  ElseIf Len(sSubs) > 40
                    sSubs + ", ..."
                    Break 2 ; Break j, i
                  Else
                    sSubs + ", " + getSubLabel(j)
                  EndIf
                EndIf ; EndIf bListThisSub
              EndIf ; EndIf aSub(j)\bSubEnabled
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf ; EndIf aCue(i)\bSubTypeF Or aCue(i)\bSubTypeL
        EndIf ; EndIf aCue(i)\bCueEnabled
      Next i
    EndIf
    If bDisplayWarning
      sMsg = Lang("Menu", "mnuWQFChangeFreqTempoPitch") + "|" + createWrapTextForOptionRequester(300, Lang("DevMap", "PlaybackRateOnly") + sSubs)
      sButton = Lang("Btns", "OK")
      sDontTellMeAgainText = Lang("Common", "DontTellMeAgain") ; "Don't tell me this again during this SCS session."
      debugMsg(sProcName, sMsg)
      nOption = OptionRequester(0, 0, sMsg, sButton, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
      debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
      If nOption & $10000
        ; user selected checkbox for "Don't tell me this again this SCS session"
        grTempoEtc\bDontTellMeAgainAboutPlaybackRateChangeOnly = #True
      EndIf
    EndIf ; EndIf bDisplayWarning
  EndIf
  
EndProcedure

Procedure unlockTimeCode(pCuePtr, bDisplayWarning=#True)
  ; PROCNAMECQ(pCuePtr)
  Protected sSMSCommand.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aCue(pCuePtr)
    sSMSCommand = "set group g" + \nSMSGroup + " tc unlock"
    sendSMSCommand(sSMSCommand)
    \bSMSTimeCodeLocked = #False
    If bDisplayWarning
      WMN_setStatusField(LangPars("SMS", "UnlockedTC", \sCue), #SCS_STATUS_WARN, 6000) ; leave display up for 10 seconds (6 + 4)
    EndIf
  EndWith
  
EndProcedure

; EOF