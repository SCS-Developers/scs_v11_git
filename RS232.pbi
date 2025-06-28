; File: RS232.pbi

EnableExplicit

Procedure.s buildSendString(pSubPtr, nCtrlSendIndex, bPrimaryFile=#True)
  PROCNAME(buildSubProcName("buildSendString", pSubPtr, bPrimaryFile))
  Protected sMsg.s, n
  Protected sChar.s
  Protected nCtlByte.b
  Protected sNoSpaces.s, bOK
  Protected sCharString.s, bCtlFound
  Protected nBufSize, nBufLen
  Protected rCtrlSend.tyCtrlSend

  debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex + ", bPrimaryFile=" + strB(bPrimaryFile))
  
  If pSubPtr >= 0
    If bPrimaryFile
      rCtrlSend = aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
    Else
      rCtrlSend = a2ndSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
    EndIf
      
    With rCtrlSend
      debugMsg(sProcName, "\bRS232Send=" + strB(\bRS232Send) + ", \nEntryMode=" + decodeEntryMode(\nEntryMode) + ", \sEnteredString=" + #DQUOTE$ + \sEnteredString + #DQUOTE$ +
                          ", \bAddCR=" + strB(\bAddCR) + ", \bAddLF=" + strB(\bAddLF))
      If \bRS232Send
        ; nBufSize = Len(\sEnteredString) << 1  ; make sure we allocated more than enough memory for the data to be sent
        ; increased nBugSize 17Oct2019 11.8.2bb following email and log from Octavio Alcober about SCS sometimes crashing
        ; possibly due to adding CR and/or LF to buffer
        nBufSize = (Len(\sEnteredString) << 1) + 8  ; make sure we allocated more than enough memory for the data to be sent
;         If nBufSize = 0
;           debugMsg(sProcName, "exiting because nBufSize=" + nBufSize)
;           ProcedureReturn sMsg
;         EndIf
        If \Buffer
          If nBufSize > MemorySize(\Buffer)
            debugMsg(sProcName, "calling FreeMemory(" + \Buffer + ")")
            FreeMemory(\Buffer)
            \Buffer = AllocateMemory(nBufSize)
            debugMsg2(sProcName, "AllocateMemory(" + nBufSize + ")", \Buffer)
          EndIf
        Else
          \Buffer = AllocateMemory(nBufSize)
          debugMsg2(sProcName, "AllocateMemory(" + nBufSize + ")", \Buffer)
        EndIf
        
        \sSendString = ""
        Select \nEntryMode
          Case #SCS_ENTRYMODE_ASCII, #SCS_ENTRYMODE_UTF8
            ; ASCII or UTF8 mode
            For n = 1 To Len(RTrim(\sEnteredString))
              sChar = Mid(\sEnteredString, n, 1)
              sMsg + " " + stringToHexString(sChar)
              \sSendString + sChar
            Next n
            \nBufLen = Len(\sSendString)
            debugMsg(sProcName, "\nBufLen=" + \nBufLen)
            If \nEntryMode = #SCS_ENTRYMODE_ASCII
              PokeS(\Buffer, \sSendString, \nBufLen, #PB_Ascii)
            Else
              PokeS(\Buffer, \sSendString, \nBufLen, #PB_UTF8)
            EndIf
            
          Case #SCS_ENTRYMODE_HEX
            ; Hex mode
            bOK = #True
            sNoSpaces = RemoveString(\sEnteredString, " ")     ; remove all spaces from entered string
            For n = 1 To Len(sNoSpaces)
              sChar = UCase(Mid(sNoSpaces, n, 1))
              If FindString(#SCS_HEX_VALID_CHARS, sChar, 1) = 0
                ; illegal hex character (shouldn't happen)
                bOK = #False
                Break
              EndIf
              sMsg + " " + sChar
              n + 1
              If n <= Len(sNoSpaces)
                sChar = UCase(Mid(sNoSpaces, n, 1))
                If FindString(#SCS_HEX_VALID_CHARS, sChar, 1) = 0
                  ; illegal hex character (shouldn't happen)
                  bOK = #False
                  Break
                EndIf
                sMsg + sChar
              EndIf
            Next n
            If bOK
              \nBufLen = hexStringToBuffer(sNoSpaces, \Buffer, nBufSize)
              debugMsg(sProcName, "\nBufLen=" + \nBufLen)
            EndIf
            
          Case #SCS_ENTRYMODE_ASCII_PLUS_CTL
            ; ASCII+CTL mode
            \nBufLen = 0
            For n = 1 To Len(RTrim(\sEnteredString))
              debugMsg(sProcName, "n=" + n + ", \nBufLen=" + \nBufLen)
              bCtlFound = #False
              If Mid(\sEnteredString, n, 1) = "<"
                If Mid(\sEnteredString + "    ", n+3, 1) = ">"
                  sCharString = Mid(\sEnteredString, n, 4)
                  bCtlFound = #True
                ElseIf Mid(\sEnteredString + "     ", n+4, 1) = ">"
                  sCharString = Mid(\sEnteredString, n, 5)
                  bCtlFound = #True
                EndIf
                
                If bCtlFound
                  Select UCase(sCharString)
                    Case "<NUL>"
                      nCtlByte = $0
                    Case "<SOH>"
                      nCtlByte = $1
                    Case "<STX>"
                      nCtlByte = $2
                    Case "<ETX>"
                      nCtlByte = $3
                    Case "<EOT>"
                      nCtlByte = $4
                    Case "<ENQ>"
                      nCtlByte = $5
                    Case "<ACK>"
                      nCtlByte = $6
                    Case "<BEL>"
                      nCtlByte = $7
                    Case "<BS>"
                      nCtlByte = $8
                    Case "<TAB>"
                      nCtlByte = $9
                    Case "<LF>"
                      nCtlByte = $A
                    Case "<VT>"
                      nCtlByte = $B
                    Case "<FF>"
                      nCtlByte = $C
                    Case "<CR>"
                      nCtlByte = $D
                    Case "<SO>"
                      nCtlByte = $E
                    Case "<SI>"
                      nCtlByte = $F
                    Case "<DLE>"
                      nCtlByte = $10
                    Case "<DC1>"
                      nCtlByte = $11
                    Case "<DC2>"
                      nCtlByte = $12
                    Case "<DC3>"
                      nCtlByte = $13
                    Case "<DC4>"
                      nCtlByte = $14
                    Case "<NAK>"
                      nCtlByte = $15
                    Case "<SYN>"
                      nCtlByte = $16
                    Case "<ETB>"
                      nCtlByte = $17
                    Case "<CAN>"
                      nCtlByte = $18
                    Case "<EM>"
                      nCtlByte = $19
                    Case "<SUB>"
                      nCtlByte = $1A
                    Case "<ESC>"
                      nCtlByte = $1B
                    Case "<FS>"
                      nCtlByte = $1C
                    Case "<GS>"
                      nCtlByte = $1D
                    Case "<RS>"
                      nCtlByte = $1E
                    Case "<US>"
                      nCtlByte = $1F
                    Case "<DEL>"
                      nCtlByte = $7F
                    Default
                      bCtlFound = #False
                  EndSelect
                EndIf
              EndIf
              If bCtlFound
                PokeB(\Buffer+\nBufLen, nCtlByte)
                sMsg + " " + RSet(Hex(nCtlByte,#PB_Byte),2,"0")
                \nBufLen + 1
                n + Len(sCharString) - 1
              Else
                sChar = Mid(\sEnteredString, n, 1)
                PokeS(\Buffer+\nBufLen, sChar, 1, #PB_Ascii)
                sMsg + " " + stringToHexString(sChar)
                \nBufLen + 1
              EndIf
            Next n
            debugMsg(sProcName, "\nBufLen=" + \nBufLen)
            
        EndSelect
        
        If \bAddCR
          PokeB(\Buffer+\nBufLen, $D)
          sMsg + " 0D"
          \nBufLen + 1
        EndIf
        
        If \bAddLF
          PokeB(\Buffer+\nBufLen, $A)
          sMsg + " 0A"
          \nBufLen + 1
        EndIf
        
        If Len(sMsg) > 2
          If Left(sMsg, 1) = " "
            sMsg = Mid(sMsg, 2)   ; chops off leading space (do not use LTrim as there may be legitimate spaces at the start of an ASCII message)
          EndIf
        EndIf
        
      EndIf
      
    EndWith
    
    If bPrimaryFile
      aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex] = rCtrlSend
    Else
      a2ndSub(pSubPtr)\aCtrlSend[nCtrlSendIndex] = rCtrlSend
    EndIf
    
  EndIf

  debugMsg(sProcName, #SCS_END + ", rCtrlSend\nBufLen=" + rCtrlSend\nBufLen + ", returning " + sMsg)
  ProcedureReturn sMsg    ; return message formatted for editor 'Message (Hex)' field

EndProcedure

Procedure checkRS232DevsForCtrlSends(bUseDevChgs=#False)
  PROCNAMEC()
  Protected i, j, n, m, bOK
  Protected sCtrlSendLogicalDev.s
  Protected sCtrlSendDevDesc.s
  Protected Dim bUnavailable(0)
  Protected Dim sSubCueLabels.s(0)
  Protected Dim sCtrlSendLogicalDev.s(0)
  Protected Dim bOpen(0)
  Protected bAllAvailable, bAllOpen
  Protected sMsg.s
  Protected nReply
  Protected bPortsChanged
  Protected bModalDisplayed
  Protected nFlags

  debugMsg(sProcName, #SCS_START)
  
  listRS232Controls()
  
  bOK = #True
  bAllAvailable = #True
  bAllOpen = #True
  bModalDisplayed = gbModalDisplayed

  m = ArraySize(gaRS232Control())+1
  ReDim bUnavailable(m)
  ReDim sSubCueLabels(m)
  ReDim sCtrlSendLogicalDev(m)
  ReDim bOpen(m)
  For m = 0 To ArraySize(bUnavailable())
    bUnavailable(m) = #False
    bOpen(m) = #True
  Next m

  For i = 1 To gnLastCue
    If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\bSubTypeM)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If (aSub(j)\bExists) And (aSub(j)\bSubTypeM) And (aSub(j)\bSubEnabled)
          For n = 0 To #SCS_MAX_CTRL_SEND
            With aSub(j)\aCtrlSend[n]
              If \bRS232Send
                \nCtrlSendIndex = getRS232ControlIndexForLogicalDev(\sCSLogicalDev)
                debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n + "]\sCSLogicalDev=" + \sCSLogicalDev + ", \nCtrlSendIndex=" + \nCtrlSendIndex)
                m = \nCtrlSendIndex + 1
                If \nCtrlSendIndex = -1
                  If bUnavailable(m) = #False
                    bUnavailable(m) = #True
                    sSubCueLabels(m) = aSub(j)\sSubLabel
                    sCtrlSendLogicalDev(m) = \sCSLogicalDev
                    bAllAvailable = #False
                  EndIf
                Else
                  debugMsg(sProcName, "gaRS232Control(" + \nCtrlSendIndex + ")\bRS232Out=" + strB(gaRS232Control(\nCtrlSendIndex)\bRS232Out))
                  If gaRS232Control(\nCtrlSendIndex)\bRS232Out = #False
                    If bUnavailable(m) = #False
                      bUnavailable(m) = #True
                      sSubCueLabels(m) = aSub(j)\sSubLabel
                      sCtrlSendLogicalDev(m) = \sCSLogicalDev
                      bAllAvailable = #False
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndWith
          Next n
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  debugMsg(sProcName, "bAllAvailable=" + strB(bAllAvailable))
  If bAllAvailable = #False
    For m = 0 To ArraySize(bUnavailable())
      If bUnavailable(m)
        If m = 0
          sMsg = LangPars("Errors", "SerialReqd1", sCtrlSendLogicalDev(m), sSubCueLabels(m))
          debugMsg(sProcName, sMsg)
          ensureSplashNotOnTop()
          gbModalDisplayed = #True
          scsMessageRequester(Lang("Requesters","RS232Check"), sMsg, #PB_MessageRequester_Error)
          bOK = #False
          
        ElseIf gaRS232Control(m-1)\bRS232In = #False
          sMsg = LangPars("Errors", "SerialReqd2", gaRS232Control(m-1)\sRS232PortAddress, sSubCueLabels(m))
          debugMsg(sProcName, sMsg)
          ensureSplashNotOnTop()
          gbModalDisplayed = #True
          nReply = scsMessageRequester(Lang("Requesters","RS232Check"), sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
          If nReply = #PB_MessageRequester_Yes
            debugMsg(sProcName, "nReply=Y")
            gaRS232Control(m-1)\bRS232Out = #True
            bPortsChanged = #True
          Else
            debugMsg(sProcName, "nReply=N")
            bOK = #False
          EndIf
          
        Else
          sMsg = LangPars("Errors", "SerialReqd3", gaRS232Control(m-1)\sRS232PortAddress, sSubCueLabels(m))
          debugMsg(sProcName, sMsg)
          ensureSplashNotOnTop()
          gbModalDisplayed = #True
          scsMessageRequester(Lang("Requesters","RS232Check"), sMsg, #PB_MessageRequester_Error)
          bOK = #False
          
        EndIf
      EndIf
    Next m
    
    If bPortsChanged
      closeRS232()
      setRS232InOutInds(bUseDevChgs)
      startRS232()
    EndIf
  EndIf

  For i = 1 To gnLastCue
    If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\bSubTypeM)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If (aSub(j)\bExists) And (aSub(j)\bSubTypeM) And (aSub(j)\bSubEnabled)
          For n = 0 To #SCS_MAX_CTRL_SEND
            With aSub(j)\aCtrlSend[n]
              If \bRS232Send
                \nCtrlSendIndex = getRS232ControlIndexForLogicalDev(\sCSLogicalDev)
                If \nCtrlSendIndex >= 0
                  If gaRS232Control(\nCtrlSendIndex)\bRS232Out = #True
                    If (gaRS232Control(\nCtrlSendIndex)\nRS232PortNo = 0) And (gaRS232Control(\nCtrlSendIndex)\bDummy = #False)
                      m = \nCtrlSendIndex + 1
                      If bOpen(m) = #True
                        bOpen(m) = #False
                        sSubCueLabels(m) = aSub(j)\sSubLabel
                        bAllOpen = #False
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndWith
          Next n
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
;   For m = 0 To ArraySize(gaRS232Control())
;     debugMsg(sProcName, "gaRS232Control(" + m + ")\sRS232PortAddress=" + gaRS232Control(m)\sRS232PortAddress +
;                         ", \bDummy=" + strB(gaRS232Control(m)\bDummy) +
;                         ", \bHideWarning=" + strB(gaRS232Control(m)\bHideWarning) +
;                         ", bOpen(" + Str(m+1) + ")=" + strB(bOpen(m+1)))
;   Next m
  
  debugMsg(sProcName, "bAllOpen=" + strB(bAllOpen))
  If bAllOpen = #False
    For m = 1 To ArraySize(bOpen()) ; skip m=0
      If (bOpen(m) = #False) And (gaRS232Control(m-1)\bHideWarning = #False)
        sMsg = LangPars("Errors", "SerialReqd4", gaRS232Control(m-1)\sRS232PortAddress, sSubCueLabels(m))
        debugMsg(sProcName, sMsg)
        ensureSplashNotOnTop()
        gbModalDisplayed = #True
        nFlags = #MB_ICONEXCLAMATION
        nReply = scsMessageRequester(Lang("Requesters", "RS232Check"), sMsg, nFlags)
        gaRS232Control(m-1)\bHideWarning = #True
      EndIf
    Next m
  EndIf

  gbModalDisplayed = bModalDisplayed
  debugMsg(sProcName, #SCS_END + " returning " + strB(bOK))
  ProcedureReturn bOK
EndProcedure

Procedure.s getCtrlSendDevDescForLogicalDev(sCtrlSendLogicalDev.s, *bDummyDev)
  PROCNAMEC()
  Protected d
  Protected nDevMapPtr
  Protected sCtrlSendDevDesc.s
  Protected bDummy

  If Trim(sCtrlSendLogicalDev)
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      d = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While d >= 0
        If grMaps\aDev(d)\nDevGrp = #SCS_DEVGRP_CTRL_SEND
          If grMaps\aDev(d)\sLogicalDev = sCtrlSendLogicalDev
            sCtrlSendDevDesc = grMaps\aDev(d)\sPhysicalDev
            bDummy = grMaps\aDev(d)\bDummy
            Break
          EndIf
        EndIf
        d = grMaps\aDev(d)\nNextDevIndex
      Wend
    EndIf
  EndIf
  
  PokeI(*bDummyDev, bDummy)
  debugMsg(sProcName, "sCtrlSendLogicalDev=" + sCtrlSendLogicalDev + ", returning " + sCtrlSendDevDesc + ", bDummyDev=" + strB(bDummy))
  ProcedureReturn sCtrlSendDevDesc
EndProcedure

Procedure getRS232ControlIndexForLogicalDev(sCtrlSendLogicalDev.s)
  PROCNAMEC()
  Protected m
  Protected nCtrlSendIndex
  Protected sCtrlSendDevDesc.s, bDummy

  nCtrlSendIndex = -1
  If sCtrlSendLogicalDev
    sCtrlSendDevDesc = getCtrlSendDevDescForLogicalDev(sCtrlSendLogicalDev, @bDummy)
    debugMsg(sProcName, "sCtrlSendLogicalDev=" + sCtrlSendLogicalDev + ", sCtrlSendDevDesc=" + sCtrlSendDevDesc + ", bDummy=" + strB(bDummy))
    If sCtrlSendDevDesc
      For m = 0 To ArraySize(gaRS232Control())
        debugMsg(sProcName, "gaRS232Control("+ m + ")\sRS232PortAddress=" + gaRS232Control(m)\sRS232PortAddress)
        If (UCase(gaRS232Control(m)\sRS232PortAddress) = UCase(sCtrlSendDevDesc)) Or (bDummy And gaRS232Control(m)\bDummy)
          nCtrlSendIndex = m
          Break
        EndIf
      Next m
    EndIf
  EndIf

  debugMsg(sProcName, "sCtrlSendLogicalDev=" + sCtrlSendLogicalDev + ", returning " + nCtrlSendIndex)
  ProcedureReturn nCtrlSendIndex
EndProcedure

Procedure getRS232ControlIndexForRS232PortAddress(sRS232PortAddress.s, bDummy)
  PROCNAMEC()
  Protected m
  Protected nCtrlSendIndex
  
  nCtrlSendIndex = -1
  If sRS232PortAddress Or bDummy
    For m = 0 To ArraySize(gaRS232Control())
      If (gaRS232Control(m)\bDummy And bDummy) Or UCase(gaRS232Control(m)\sRS232PortAddress) = UCase(sRS232PortAddress)
        nCtrlSendIndex = m
        Break
      EndIf
    Next m
  EndIf
  
  debugMsg(sProcName, "sRS232PortAddress=" + sRS232PortAddress + ", bDummy=" + strB(bDummy) + ", returning " + nCtrlSendIndex)
  ProcedureReturn nCtrlSendIndex
EndProcedure

Procedure handleRS232Input(InBuff.s, nIndex)
  PROCNAMEC()
  Protected sBuffWork.s, sBuffPart.s
  Protected n
  Protected bThisPartReady
  Protected i, nSCSPtr, nEOMPtr

  debugMsg(sProcName, "InBuff=$" + stringToHexString(InBuff))
  sBuffWork = InBuff
  
  While Len(sBuffWork) > 0
    nEOMPtr = FindString(sBuffWork, Chr($D), 1)
    If nEOMPtr > 0
      sBuffPart = Left(sBuffWork, nEOMPtr + 1)
      If nEOMPtr = Len(sBuffWork)
        sBuffWork = ""
      Else
        sBuffWork = Mid(sBuffWork, nEOMPtr + 1)
      EndIf
      bThisPartReady = #True
    Else
      sBuffPart = sBuffWork
      sBuffWork = ""
      bThisPartReady = #False
    EndIf
    
    debugMsg(sProcName, "sBuffPart=$" + stringToHexString(sBuffPart))
    
    If (Not gbReadingRS232Message) Or (gnRS232InCount = 0)
      gbReadingRS232Message = #True
      gbRS232InLocked = #True
      i = gnRS232InCount
      gnRS232CurrentIndex = i
      With gaRS232Ins(gnRS232CurrentIndex)
        \sMessage = LTrim(sBuffPart)
        \bReady = bThisPartReady
        \bDone = #False
        \qTimeIn = ElapsedMilliseconds()
        debugMsg(sProcName, "a. gnRS232CurrentIndex=" + gnRS232CurrentIndex + ", \sMessage=" + \sMessage)
      EndWith
      gnRS232InCount = i + 1
      gbRS232InLocked = #False
      debugMsg(sProcName, "gnRS232InCount=" + gnRS232InCount)
    Else
      With gaRS232Ins(gnRS232CurrentIndex)
        \sMessage = \sMessage + sBuffPart
        \bReady = bThisPartReady
        debugMsg(sProcName, "b. gnRS232CurrentIndex=" + gnRS232CurrentIndex + ", \sMessage=" + \sMessage)
      EndWith
    EndIf
    
    If bThisPartReady
      With gaRS232Ins(gnRS232CurrentIndex)
        nSCSPtr = FindString(LCase(\sMessage), "scs", 1)
        If nSCSPtr > 1
          \sMessage = Mid(\sMessage, nSCSPtr)
        EndIf
      EndWith
      gbReadingRS232Message = #False
    Else
      gbReadingRS232Message = #True
    EndIf
    
  Wend

  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
EndProcedure

Procedure.s getRS232Info()
  PROCNAMEC()
  Protected sInfo.s, n, bOpenResult

  ; debugMsg(sProcName, #SCS_START)
  
  For n = 0 To ArraySize(gaRS232Control())
    With gaRS232Control(n)
      If \bRS232In
        debugMsg(sProcName, "calling openSerialPortIfReqd(" + n + ")")
        If openSerialPortIfReqd(n)
          sInfo = "RS232 Control Enabled"
        EndIf
        Break
      EndIf
    EndWith
  Next n

  ; debugMsg(sProcName, #SCS_END + ", returning " + sInfo)
  
  ProcedureReturn sInfo
EndProcedure

Procedure initRS232Control()
  PROCNAMEC()
  Protected d, n
;   Protected sMsg.s

  ; debugMsg(sProcName, #SCS_START + ", gnMaxRS232Control=" + gnMaxRS232Control)
  
  ReDim gaRS232Control(gnMaxRS232Control)
  d = -1
  For n = 0 To gnMaxConnectedDev
    If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_CC_RS232_IN
      d + 1
      gaRS232Control(d) = grRS232ControlDefault
      With gaRS232Control(d)
        \sRS232PortAddress = gaConnectedDev(n)\sPhysicalDevDesc
        \bDummy = gaConnectedDev(n)\bDummy
;         sMsg = "gaRS232Control(" + d + ")\sRS232PortAddress=" + #DQUOTE$ + \sRS232PortAddress + #DQUOTE$
;         If \bDummy
;           sMsg + ", \bDummy=" + strB(\bDummy)
;         EndIf
;         debugMsg(sProcName, sMsg)
      EndWith
    EndIf
  Next n
  
  With grEditMem
    \sLastCtrlSendLogicalDev = #SCS_DEFAULT_RS232_LOGICALDEV
    \nLastCtrlSendDevType = #SCS_DEVTYPE_CS_RS232_OUT
    \nLastEntryMode = #SCS_ENTRYMODE_ASCII
    \bLastAddCR = #True
    \bLastAddLF = #False
  EndWith
  
  ; debugMsg(sProcName, "calling listRS232Controls()")
  listRS232Controls()
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure.s sendRS232String(pCtrlSendLogicalDev.s, pMsg.s)
  PROCNAMEC()
  Protected nCtrlSendIndex
  Protected sPortName.s
  Protected nResult
  
  debugMsg(sProcName, #SCS_START + ", pCtrlSendLogicalDev=" + pCtrlSendLogicalDev + ", pMsg=$" + stringToHexString(pMsg))
  If Len(pMsg) <= 0
    ProcedureReturn
  EndIf

  nCtrlSendIndex = getRS232ControlIndexForLogicalDev(pCtrlSendLogicalDev)
  sPortName = ""
  If nCtrlSendIndex >= 0
    With gaRS232Control(nCtrlSendIndex)
      sPortName = \sRS232PortAddress
      ; debugMsg(sProcName, "sPortName=" + sPortName)
      If (\bDummy = #False And grSession\nRS232OutEnabled = #SCS_DEVTYPE_ENABLED)
        debugMsg(sProcName, "gaRS232Control(" + nCtrlSendIndex + ")\sRS232PortAddress=" + gaRS232Control(nCtrlSendIndex)\sRS232PortAddress)
        If IsSerialPort(\nRS232PortNo)
          nResult = WriteSerialPortString(\nRS232PortNo, pMsg)
          debugMsg2(sProcName, "WriteSerialPortString(" + \nRS232PortNo + ", pMsg)", nResult)
        Else
          debugMsg3(sProcName, "IsSerialPort(" + \nRS232PortNo + ") returned 0")
          sPortName = #SCS_RS232_PORT_NOT_OPEN
        EndIf
      EndIf
    EndWith
  EndIf

  ProcedureReturn sPortName
EndProcedure

Procedure.s sendRS232Data(pCtrlSendLogicalDev.s, *pBuffer, pLength)
  PROCNAMEC()
  Protected nCtrlSendIndex
  Protected sPortName.s
  Protected nResult
  
  debugMsg(sProcName, #SCS_START + ", pCtrlSendLogicalDev=" + pCtrlSendLogicalDev)
  If *pBuffer = 0 Or pLength = 0
    ProcedureReturn
  EndIf
  
  nCtrlSendIndex = getRS232ControlIndexForLogicalDev(pCtrlSendLogicalDev)
  sPortName = ""
  If nCtrlSendIndex >= 0
    With gaRS232Control(nCtrlSendIndex)
      sPortName = \sRS232PortAddress
      ; debugMsg(sProcName, "sPortName=" + sPortName)
      If (\bDummy = #False And grSession\nRS232OutEnabled = #SCS_DEVTYPE_ENABLED)
        debugMsg(sProcName, "gaRS232Control(" + nCtrlSendIndex + ")\sRS232PortAddress=" + \sRS232PortAddress)
        If IsSerialPort(\nRS232PortNo)
          debugMsg(sProcName, "sending $" + bufferToHexString(*pBuffer, pLength))
          nResult = WriteSerialPortData(\nRS232PortNo, *pBuffer, pLength)
          debugMsg2(sProcName, "WriteSerialPortData(" + \nRS232PortNo + ", *pBuffer, " + pLength + ")", nResult)
        Else
          debugMsg(sProcName, "IsSerialPort(" + \nRS232PortNo + ") returned 0")
          sPortName = #SCS_RS232_PORT_NOT_OPEN
        EndIf
      Else
        debugMsg(sProcName, "$" + bufferToHexString(*pBuffer, pLength) + " not sent: gaRS232Control(" + nCtrlSendIndex + ")\sRS232PortAddress=" + \sRS232PortAddress +
                            ", \bDummy=" + strB(\bDummy) + ", grSession\nRS232OutEnabled=" + grSession\nRS232OutEnabled)
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn sPortName
EndProcedure

Procedure initRS232Device(nRS232DevNo, nDevType)
  PROCNAMEC()
  Protected bInitResult
  Protected bOpenThis, bOpenResult
  
  debugMsg(sProcName, #SCS_START + ", nRS232DevNo=" + nRS232DevNo + ", nDevType=" + decodeDevType(nDevType))
  
  If nRS232DevNo >= 0
    With gaRS232Control(nRS232DevNo)
      If \bDummy
        debugMsg(sProcName, "gaRS232Control(" + nRS232DevNo + ")\bDummy=#True")
        bInitResult = #True
      ElseIf nDevType = #SCS_DEVTYPE_CC_RS232_IN And grSession\nRS232InEnabled <> #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nRS232InEnabled=" + grSession\nRS232InEnabled)
        bInitResult = #True
      ElseIf nDevType = #SCS_DEVTYPE_CS_RS232_OUT And grSession\nRS232OutEnabled <> #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nRS232OutEnabled=" + grSession\nRS232OutEnabled)
        bInitResult = #True
      Else
        debugMsg(sProcName, "calling openSerialPortIfReqd(" + nRS232DevNo + ")")
        bInitResult = openSerialPortIfReqd(nRS232DevNo)
      EndIf
      \bInitialized = bInitResult
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure startRS232()
  PROCNAMEC()
  Protected n
  Protected sStatusField.s
  Protected bInFound

  debugMsg(sProcName, #SCS_START)

  gnRS232CurrentIndex = -1
  gbReadingRS232Message = #False

  For n = 0 To gnMaxRS232Control
    With gaRS232Control(n)
      debugMsg(sProcName, "gaRS232Control(" + n + ")\bRS232In=" + strB(\bRS232In) + ", \bRS232Out=" + strB(\bRS232Out) +
                          ", grSession\nRS232InEnabled=" + grSession\nRS232InEnabled + ", grSession\nRS232OutEnabled=" + grSession\nRS232OutEnabled)
      If (\bRS232In And grSession\nRS232InEnabled = #SCS_DEVTYPE_ENABLED)
        bInFound = #True
      EndIf
      If (\bRS232In And grSession\nRS232InEnabled = #SCS_DEVTYPE_ENABLED)
        debugMsg(sProcName, "calling initRS232Device(" + n + ", #SCS_DEVTYPE_CC_RS232_IN)")
        initRS232Device(n, #SCS_DEVTYPE_CC_RS232_IN)
      EndIf
      If (\bRS232Out And grSession\nRS232OutEnabled = #SCS_DEVTYPE_ENABLED)
        debugMsg(sProcName, "calling initRS232Device(" + n + ", #SCS_DEVTYPE_CS_RS232_OUT)")
        initRS232Device(n, #SCS_DEVTYPE_CS_RS232_OUT)
      EndIf
    EndWith
  Next n
  
  If bInFound
    sStatusField = RTrim(" " + getMidiInfo() + " " + RTrim(getRS232Info() + " " + RTrim(DMX_getDMXInfo() + " " + getNetworkInfo())))
    If sStatusField
      WMN_setStatusField(sStatusField, #SCS_STATUS_WARN, 6000, #True)
    EndIf
    THR_createOrResumeAThread(#SCS_THREAD_RS232_RECEIVE)
  EndIf
  
  gbRS232Started = #True
  
  debugMsg(sProcName, "calling listRS232Controls()")
  listRS232Controls()
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure closeRS232()
  PROCNAMEC()
  Protected n

  debugMsg(sProcName, #SCS_START)

  THR_stopAThread(#SCS_THREAD_RS232_RECEIVE)
  THR_waitForAThreadToStop(#SCS_THREAD_RS232_RECEIVE)
  
  For n = 0 To ArraySize(gaRS232Control())
    With gaRS232Control(n)
      If IsSerialPort(\nRS232PortNo)
        CloseSerialPort(\nRS232PortNo)
        debugMsg3(sProcName, "CloseSerialPort(" + \nRS232PortNo + ")")
      EndIf
      \nRS232PortNo = 0
      \bInitialized = #False
      \bRS232In = #False
      \bRS232Out = #False
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s decodeEntryMode(nEntryMode)
  PROCNAMEC()
  Protected sEntryMode.s
  
  Select nEntryMode
    Case #SCS_ENTRYMODE_ASCII
      sEntryMode = "ASCII"
    Case #SCS_ENTRYMODE_HEX
      sEntryMode = "Hex"
    Case #SCS_ENTRYMODE_ASCII_PLUS_CTL
      sEntryMode = "ASCII+CTL"
    Case #SCS_ENTRYMODE_UTF8
      sEntryMode = "UTF8"
  EndSelect
  ProcedureReturn sEntryMode
  
EndProcedure

Procedure encodeEntryMode(sEntryMode.s)
  PROCNAMEC()
  Protected nEntryMode

  Select UCase(sEntryMode)
    Case "ASCII"
      nEntryMode = #SCS_ENTRYMODE_ASCII
    Case "HEX"
      nEntryMode = #SCS_ENTRYMODE_HEX
    Case "ASCII+CTL"
      nEntryMode = #SCS_ENTRYMODE_ASCII_PLUS_CTL
    Case "UTF8"
      nEntryMode = #SCS_ENTRYMODE_UTF8
  EndSelect
  ProcedureReturn nEntryMode

EndProcedure

Procedure.s decodeParity(nRS232Parity)
  PROCNAMEC()
  Protected sParity.s
  
  Select nRS232Parity
    Case #PB_SerialPort_NoParity
      sParity = "None"
    Case #PB_SerialPort_EvenParity
      sParity = "Even"
    Case #PB_SerialPort_MarkParity
      sParity = "Mark"
    Case #PB_SerialPort_OddParity
      sParity = "Odd"
    Case #PB_SerialPort_SpaceParity
      sParity = "Space"
    Default
      sParity = "None"
  EndSelect
  ProcedureReturn sParity
  
EndProcedure

Procedure encodeParity(sParity.s)
  PROCNAMEC()
  Protected nRS232Parity
  
  Select sParity
    Case "None"
      nRS232Parity = #PB_SerialPort_NoParity
    Case "Even"
      nRS232Parity = #PB_SerialPort_EvenParity
    Case "Mark"
      nRS232Parity = #PB_SerialPort_MarkParity
    Case "Odd"
      nRS232Parity = #PB_SerialPort_OddParity
    Case "Space"
      nRS232Parity = #PB_SerialPort_SpaceParity
    Default
      nRS232Parity = #PB_SerialPort_NoParity
  EndSelect
  ProcedureReturn nRS232Parity
  
EndProcedure

Procedure.s decodeHandshaking(nRS232Handshaking)
  PROCNAMEC()
  Protected sHandshaking.s
  
  Select nRS232Handshaking
    Case #PB_SerialPort_NoHandshake
      sHandshaking = "No"
    Case #PB_SerialPort_XonXoffHandshake
      sHandshaking = "XonXoff"
    Case #PB_SerialPort_RtsCtsHandshake
      sHandshaking = "RtsCts"
    Case #PB_SerialPort_RtsHandshake
      sHandshaking = "Rts"
    Default
      sHandshaking = "XonXoff"
  EndSelect
  
  ; debugMsg(sProcName, "nRS232Handshaking=" + nRS232Handshaking + ", sHandshaking=" + sHandshaking)
  ProcedureReturn sHandshaking
  
EndProcedure

Procedure encodeHandshaking(sHandshaking.s)
  PROCNAMEC()
  Protected nRS232Handshaking
  
  Select sHandshaking
    Case "No"
      nRS232Handshaking = #PB_SerialPort_NoHandshake
    Case "XonXoff"
      nRS232Handshaking = #PB_SerialPort_XonXoffHandshake
    Case "RtsCts"
      nRS232Handshaking = #PB_SerialPort_RtsCtsHandshake
    Case "Rts"
      nRS232Handshaking = #PB_SerialPort_RtsHandshake
    Default
      nRS232Handshaking = #PB_SerialPort_NoHandshake
  EndSelect
  ; debugMsg(sProcName, "sHandshaking=" + sHandshaking + ", nRS232Handshaking=" + nRS232Handshaking)
  ProcedureReturn nRS232Handshaking
  
EndProcedure

Procedure doRS232In_Proc()
  PROCNAMEC()
  Protected n, nQuotePtr, nCountNotDone, nCRPtr
  Protected sWork.s, txt.s, txt2.s, sRS232Cue.s
  Protected sAction.s
  Protected qTimeNow.q

  debugMsg(sProcName, "gbRS232InLocked=" + strB(gbRS232InLocked))
  If gbRS232InLocked
    ProcedureReturn
  EndIf
  
  For n = 0 To gnRS232InCount - 1
    debugMsg(sProcName, "n=" + n + ", gnRS232InCount=" + gnRS232InCount)
    
    sAction = ""
    sRS232Cue = ""
    txt = ""
    
    With gaRS232Ins(n)
      debugMsg(sProcName, "\bReady=" + strB(\bReady) + ", \sMessage=" + \sMessage)
      If \bReady
        
        sRS232Cue = ""
        debugMsg(sProcName, "\sMessage = " + \sMessage)
        
        If LCase(Left(\sMessage, 8)) = "scsgotop"
          sAction = "GOTOP"
          txt = "Go Top"
          
        ElseIf LCase(Left(\sMessage, 10)) = "scsgo(" + #DQUOTE$ + "0" + #DQUOTE$ + ")"
          sAction = "GO"
          sRS232Cue = "0"
          txt = "Go Button"
          
        ElseIf LCase(Left(\sMessage, 7)) = "scsgo(" + #DQUOTE$
          If Len(\sMessage) > 9 ; length of scsgo("")
            sWork = Mid(\sMessage, 8)
            nQuotePtr = FindString(sWork, #DQUOTE$, 1)
            If nQuotePtr > 1
              sAction = "GO"
              sRS232Cue = Left(sWork, nQuotePtr - 1)
              txt = "Activate Cue " + sRS232Cue
            EndIf
          EndIf
          
        ElseIf LCase(Left(\sMessage, 10)) = "scsstopall"
          sAction = "STOPALL"
          txt = "Stop All"
          
        ElseIf LCase(Left(\sMessage, 9)) = "scsstop(" + #DQUOTE$
          If Len(\sMessage) > 11 ; length of scsstop("")
            sWork = Mid(\sMessage, 10)
            nQuotePtr = FindString(sWork, #DQUOTE$, 1)
            If nQuotePtr > 1
              sAction = "STOP"
              sRS232Cue = Left(sWork, nQuotePtr - 1)
              txt = "Stop Cue " + sRS232Cue
            EndIf
          EndIf
          
        EndIf
        
        If gbMidiTestWindow = #False
          gbInExternalControl = #True
          If sAction = "GO" And Len(sRS232Cue) > 0
            processRS232GoCommand(sRS232Cue)
          ElseIf sAction = "GOTOP"
            processRS232GoTopCommand()
          ElseIf sAction = "STOP" And Len(sRS232Cue) > 0
            processRS232StopCommand(sRS232Cue)
          ElseIf sAction = "STOPALL"
            processRS232StopAllCommand()
          EndIf
          gbInExternalControl = #False
        EndIf
        
        debugMsg(sProcName, "txt=" + txt)
        
        If txt Or gbMidiTestWindow
          If gbMidiTestWindow
            nCRPtr = FindString(\sMessage, Chr($D), 1)
            If nCRPtr > 0
              txt2 = txt
              txt = Left(\sMessage, nCRPtr - 1)
            EndIf
            AddGadgetItem(WMT\lstTestMidiInfo, -1, txt)
            If txt2
              AddGadgetItem(WMT\lstTestMidiInfo, -1, "  " + txt2)
            EndIf
            ; scroll to last entry, so entry just added is visible
            SetGadgetState(WMT\lstTestMidiInfo,CountGadgetItems(WMT\lstTestMidiInfo)-1)
            SetGadgetState(WMT\lstTestMidiInfo,-1)
          Else
            WMN_setStatusField(RTrim(" RS232 IN  " + txt + "  " + txt2))
          EndIf
        EndIf
        \bDone = #True
        \bReady = #False
      Else
        qTimeNow = ElapsedMilliseconds()
        If qTimeNow > \qTimeIn + 1000
          ; discard message if CR not received within 1 second
          debugMsg(sProcName, "discarding " + \sMessage)
          \bDone = #True
        EndIf
      EndIf
      
    EndWith
  Next n
  
  If gbRS232InLocked
    ProcedureReturn
  EndIf

  nCountNotDone = 0
  For n = 0 To gnRS232InCount - 1
    If gaRS232Ins(n)\bDone = #False
      nCountNotDone + 1
    EndIf
  Next n
  If nCountNotDone = 0
    gnRS232InCount = 0
  EndIf

EndProcedure

Procedure processRS232GoCommand(sRS232Cue.s)
  PROCNAMEC()
  Protected nHotkeyCuePtr, i

  debugMsg(sProcName, "sRS232Cue=" + sRS232Cue)

  If sRS232Cue = "0"
    goIfOK()
  Else
    For i = 1 To gnLastCue
      If (aCue(i)\sCue = sRS232Cue) And (aCue(i)\bCueCurrentlyEnabled)
        If aCue(i)\bKeepOpen
          ; hotkey cue or non-linear cue or external trigger cue
          If aCue(i)\nActivationMethodReqd = #SCS_ACMETH_HK_TOGGLE
            ; hotkey (toggle) activation method, so fade out / stop cue IF cue is currrently playing
            If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
              debugMsg(sProcName, "calling fadeOutCue(" + aCue(i)\sCue + ", False)")
              fadeOutCue(i, #False)
            Else
              debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(i) + ")")
              playCueViaCas(i)
            EndIf
          Else
            debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(i) + ")")
            playCueViaCas(i)
          EndIf
          If aCue(i)\nHideCueOpt = #SCS_HIDE_NO
            gbCallLoadDispPanels = #True
          EndIf
          Break
        Else
          ; non-hotkey etc cue
          setGridRow(i)
          If i <> gnCueToGo
            GoToCue(i)
          EndIf
          debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(i) + ")")
          playCueViaCas(i)
          highlightLine(i)
          gbCallLoadDispPanels = #True
          debugMsg(sProcName, "calling setCueToGo()")
          setCueToGo()
          gbCallSetNavigateButtons = #True
          Break
        EndIf
      EndIf
    Next i
  EndIf

EndProcedure

Procedure processRS232GoTopCommand()
  PROCNAMEC()

  GoToCue(getFirstEnabledCue())

EndProcedure

Procedure processRS232StopCommand(sRS232Cue.s)
  PROCNAMEC()
  Protected i

  debugMsg(sProcName, "sRS232Cue = " + sRS232Cue)

  For i = 1 To gnLastCue
    If aCue(i)\sCue = sRS232Cue
      debugMsg(sProcName, "calling stopCue(" + getCueLabel(i) + ", 'ALL', #True)")
      stopCue(i, "ALL", #True)
      Break
    EndIf
  Next i

EndProcedure

Procedure processRS232StopAllCommand()
  PROCNAMEC()

  ; stopEverythingPart1()
  processStopAll() ; Changed 19May2025 11.10.8ba2

EndProcedure

Procedure runRS232ReceiveThread(*nThreadValue)          ;serial input thread
  ; main 'serial input thread' code obtained from PB Forum thread http://www.purebasic.fr/english/viewtopic.php?f=13&t=39374&p=301997
  ; wrapped up in SCS thread code
  PROCNAMEC()
  Protected nComId
  Protected nResult
  Protected sComRcv.s
  Protected bComRcvPrimed
  Protected Buffer.b
  Protected n
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  
  debugMsg(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_RS232_RECEIVE)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    doThreadLoopStart(#SCS_THREAD_RS232_RECEIVE, 50) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    For n = 0 To ArraySize(gaRS232Control())
      With gaRS232Control(n)
        If \bRS232In
          nComId = \nRS232PortNo
          If IsSerialPort(nComId)
            bComRcvPrimed = #False
            While AvailableSerialPortInput(nComId)
              If bComRcvPrimed = #False
                If (ElapsedMilliseconds() - \qTimeReceived) <= 1000
                  sComRcv = \sComRcv
                Else
                  ; discard \sComRcv if CR not received with 1 second
                  sComRcv = ""
                EndIf
                bComRcvPrimed = #True
              EndIf
              nResult = ReadSerialPortData(nComId, @Buffer, 1)
              Select Buffer ;Asc(char)
                Case 13, 32 To 126    ; 13 = hex(0D) = CR     ; 32 to 126 = normal character set, eg 0-9, A-Z, a-z, special characters
                  sComRcv + Chr(Buffer)
              EndSelect
              If Right(sComRcv,1) = #CR$
                If Len(sComRcv) > 1
                  handleRS232Input(sComRcv, n)
                EndIf
                sComRcv = ""
              EndIf
            Wend
            If bComRcvPrimed
              \sComRcv = sComRcv
              If Len(sComRcv) > 0
                \qTimeReceived = ElapsedMilliseconds()
              Else
                \qTimeReceived = 0
              EndIf
            EndIf  
          EndIf
        EndIf
      EndWith
    Next n
    
    ; yield to other processes for 10ms before looping back to the start
    Delay(10)
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_RS232_RECEIVE)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_RS232_RECEIVE)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

Procedure openSerialPortIfReqd(nRS232DevNo)
  PROCNAMEC()
  Protected bOpenThis, nResult
  Protected bOpenResult
  Protected nFlag
  
  debugMsg(sProcName, #SCS_START + ", nRS232DevNo=" + nRS232DevNo)
  
  If nRS232DevNo >= 0
    With gaRS232Control(nRS232DevNo)
      If \bDummy
        \bInitialized = #True
      ElseIf \bInitialized = #False
        bOpenThis = #True
        nFlag = 1
      ElseIf IsSerialPort(\nRS232PortNo) = #False
        bOpenThis = #True
        nFlag = 2
      ElseIf \sRS232PortAddress <> \sCurrRS232PortAddress
        bOpenThis = #True
        nFlag = 3
      ElseIf (\nRS232BaudRate <> \nCurrBaudRate) Or (\nRS232Parity <> \nCurrParity) Or (\nRS232DataBits <> \nCurrDataBits) Or (\fRS232StopBits <> \fCurrStopBits) Or
             (\nRS232Handshaking <> \nCurrHandshaking) Or (\nInBufferSize <> \nCurrInBufferSize) Or (\nOutBufferSize <> \nCurrOutBufferSize)
        bOpenThis = #True
        nFlag = 4
      ElseIf (\nRS232RTSEnable <> \nCurrRTSEnable) Or (\nRS232DTREnable <> \nCurrDTREnable)
        bOpenThis = #True
        nFlag = 5
      EndIf
      debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", nFlag=" + nFlag)
      
      ; if bOpenThis = #False then the port is already open with the required settings, so no need to close and re-open
      ; else do the following:
      If bOpenThis
        If IsSerialPort(\nRS232PortNo)
          CloseSerialPort(\nRS232PortNo)
          debugMsg3(sProcName, "CloseSerialPort(" + \nRS232PortNo + ")")
          \bInitialized = #False
        EndIf
        
        If \nRS232PortNo = 0
          gnNextSerialPortNo + 1
          \nRS232PortNo = gnNextSerialPortNo
        EndIf
        
        ; Added 13Dec2021 11.8.6cw
        If IsSerialPort(\nRS232PortNo)
          CloseSerialPort(\nRS232PortNo)
          debugMsg3(sProcName, "CloseSerialPort(" + \nRS232PortNo + ")")
          \bInitialized = #False
        EndIf
        ; End added 13Dec2021 11.8.6cw
        
        nResult = OpenSerialPort(\nRS232PortNo, \sRS232PortAddress, \nRS232BaudRate, \nRS232Parity, \nRS232DataBits, \fRS232StopBits, \nRS232Handshaking, \nInBufferSize, \nOutBufferSize)
        debugMsg2(sProcName, "OpenSerialPort(" + \nRS232PortNo + ", " + \sRS232PortAddress + ", " + \nRS232BaudRate + ", " + \nRS232Parity + ", " + \nRS232DataBits +
                             ", " + StrF(\fRS232StopBits,1) + ", " + \nRS232Handshaking + ", " + \nInBufferSize + ", " + \nOutBufferSize + ")", \nRS232PortNo)
        If IsSerialPort(\nRS232PortNo)
          If \nRS232RTSEnable = 1
            SetSerialPortStatus(\nRS232PortNo, #PB_SerialPort_RTS, 1)
            debugMsg3(sProcName, "SetSerialPortStatus(" + \nRS232PortNo + ", #PB_SerialPort_RTS, 1)")
          EndIf
          If \nRS232DTREnable = 1
            SetSerialPortStatus(\nRS232PortNo, #PB_SerialPort_DTR, 1)
            debugMsg3(sProcName, "SetSerialPortStatus(" + \nRS232PortNo + ", #PB_SerialPort_DTR, 1)")
          EndIf
          \bInitialized = #True
          \sCurrRS232PortAddress = \sRS232PortAddress
          \nCurrBaudRate = \nRS232BaudRate
          \nCurrParity = \nRS232Parity
          \nCurrDataBits = \nRS232DataBits
          \fCurrStopBits = \fRS232StopBits
          \nCurrHandshaking = \nRS232Handshaking
          \nCurrInBufferSize = \nInBufferSize
          \nCurrOutBufferSize = \nOutBufferSize
          \nCurrRTSEnable = \nRS232RTSEnable
          \nCurrDTREnable = \nRS232DTREnable
        Else
          debugMsg(sProcName, "IsSerialPort(" + \nRS232PortNo + ") returned #False")
        EndIf
      EndIf
      
      ; Changed 13Dec2021 11.8.6cw
      If \bDummy
        bOpenResult = #True
      Else
        If IsSerialPort(\nRS232PortNo)
          bOpenResult = #True
        Else
          debugMsg(sProcName, "IsSerialPort(" + \nRS232PortNo + ") returned #False")
        EndIf
      EndIf
      ; End changed 13Dec2021 11.8.6cw
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bOpenResult))
  ProcedureReturn bOpenResult
  
EndProcedure

Procedure setRS232InOutInds(bUseDevChgs=#False)
  PROCNAMEC()
  Protected nDevMapPtr, nDevPtr
  Protected n

  ; debugMsg(sProcName, #SCS_START + ", bUseDevChgs=" + strB(bUseDevChgs))
  
  For n = 0 To gnMaxRS232Control
    With gaRS232Control(n)
      \bRS232In = #False
      \bRS232Out = #False
    EndWith
  Next n
  
  If bUseDevChgs
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevPtr = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
      While nDevPtr >= 0
        With grMapsForDevChgs\aDev(nDevPtr)
          If \nPhysicalDevPtr >= 0
            If (\nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (\nDevType = #SCS_DEVTYPE_CC_RS232_IN)
              gaRS232Control(\nPhysicalDevPtr)\bRS232In = #True
              debugMsg(sProcName, gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress + " \bRS232In=#True")
            ElseIf (\nDevGrp = #SCS_DEVGRP_CTRL_SEND) And (\nDevType = #SCS_DEVTYPE_CS_RS232_OUT)
              gaRS232Control(\nPhysicalDevPtr)\bRS232Out = #True
              debugMsg(sProcName, gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress + " \bRS232Out=#True")
            EndIf
          EndIf
          nDevPtr = \nNextDevIndex
        EndWith
      Wend
    EndIf
    
  Else
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevPtr = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While nDevPtr >= 0
        With grMaps\aDev(nDevPtr)
          If \nPhysicalDevPtr >= 0
            If (\nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (\nDevType = #SCS_DEVTYPE_CC_RS232_IN)
              gaRS232Control(\nPhysicalDevPtr)\bRS232In = #True
              debugMsg(sProcName, gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress + " \bRS232In=#True")
            ElseIf (\nDevGrp = #SCS_DEVGRP_CTRL_SEND) And (\nDevType = #SCS_DEVTYPE_CS_RS232_OUT)
              gaRS232Control(\nPhysicalDevPtr)\bRS232Out = #True
              debugMsg(sProcName, gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress + " \bRS232Out=#True")
            EndIf
          EndIf
          nDevPtr = \nNextDevIndex
        EndWith
      Wend
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "calling listRS232Controls()")
  listRS232Controls()

  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listRS232Controls()
  PROCNAMEC()
  Protected n
  
  ;  debugMsg(sProcName, #SCS_START)
  debugMsg(sProcName, "RS232 devices")
  
  For n = 0 To gnMaxRS232Control
    With gaRS232Control(n)
      debugMsg(sProcName, "gaRS232Control(" + n + ")\sRS232PortAddress=" + \sRS232PortAddress +
                          ", \nRS232PortNo=" + \nRS232PortNo +
                          ", \bDummy=" + strB(\bDummy) +
                          ", \bInitialized=" + strB(\bInitialized) +
                          ", \bRS232In=" + strB(\bRS232In) +
                          ", \bRS232Out=" + strB(\bRS232Out))
    EndWith
  Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF