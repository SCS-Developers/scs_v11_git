; File: Network.pbi

EnableExplicit

Procedure.s decodeNetworkRole(nNetworkRole)
  PROCNAMEC()
  Protected sDecoded.s
  
  ; no langage translation - used for dev map file handler
  Select nNetworkRole
    Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
      sDecoded = "Client"
    Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
      sDecoded = "Server"
    Case #SCS_ROLE_DUMMY
      sDecoded = "Dummy"
  EndSelect
  
  ProcedureReturn sDecoded
EndProcedure

Procedure encodeNetworkRole(sNetworkRole.s)
  PROCNAMEC()
  Protected nEncoded
  
  ; no langage translation - used for dev map file handler
  Select sNetworkRole
    Case "Client"
      nEncoded = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
    Case "Server"
      nEncoded = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
    Case "Dummy"
      nEncoded = #SCS_ROLE_DUMMY
  EndSelect
  
  ProcedureReturn nEncoded
EndProcedure

Procedure.s decodeNetworkMsgAction(nMsgAction)
  Protected sMsgAction.s
  
  Select nMsgAction
    Case #SCS_NETWORK_ACT_REPLY
      sMsgAction = "ActReply"
    Case #SCS_NETWORK_ACT_READY
      sMsgAction = "ActReady"
    Case #SCS_NETWORK_ACT_AUTHENTICATE
      sMsgAction = "ActAuth"
    Default
      sMsgAction = "ActNone"
  EndSelect
  ProcedureReturn sMsgAction
EndProcedure

Procedure.s decodeNetworkMsgActionL(nMsgAction)
  ProcedureReturn Lang("Network", decodeNetworkMsgAction(nMsgAction))
EndProcedure

Procedure encodeNetworkMsgAction(sMsgAction.s)
  Protected nMsgAction
  
  Select sMsgAction
    Case "ActReply"
      nMsgAction = #SCS_NETWORK_ACT_REPLY
    Case "ActReady"
      nMsgAction = #SCS_NETWORK_ACT_READY
    Case "ActAuth"
      nMsgAction = #SCS_NETWORK_ACT_AUTHENTICATE
    Default
      nMsgAction = #SCS_NETWORK_ACT_NONE
  EndSelect
  ProcedureReturn nMsgAction
EndProcedure

Procedure.s decodeNetworkMsgFormat(nNetworkMsgFormat)
  PROCNAMEC()
  Protected sDecoded.s
  
  ; no langage translation
  Select nNetworkMsgFormat
    Case #SCS_NETWORK_MSG_OSC
      sDecoded = "OSC"
    Default
      sDecoded = "ASCII"
  EndSelect
  
  ProcedureReturn sDecoded
EndProcedure

Procedure encodeNetworkMsgFormat(sNetworkMsgFormat.s)
  PROCNAMEC()
  Protected nEncoded
  
  ; no langage translation
  Select sNetworkMsgFormat
    Case "OSC"
      nEncoded = #SCS_NETWORK_MSG_OSC
    Default
      nEncoded = #SCS_NETWORK_MSG_ASCII
  EndSelect
  
  ProcedureReturn nEncoded
EndProcedure

Procedure.s decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev)
  Protected sCtrlNetworkRemoteDev.s
  
  Select nCtrlNetworkRemoteDev
    Case #SCS_CS_NETWORK_REM_ANY
      sCtrlNetworkRemoteDev = "AnyDev"
    Case #SCS_CS_NETWORK_REM_SCS
      sCtrlNetworkRemoteDev = "SCS"
    Case #SCS_CS_NETWORK_REM_PJLINK
      sCtrlNetworkRemoteDev = "PJLink"
    Case #SCS_CS_NETWORK_REM_PJNET
      sCtrlNetworkRemoteDev = "PJNet"
    Case #SCS_CS_NETWORK_REM_OSC_X32
      sCtrlNetworkRemoteDev = "OSC-X32"
    Case #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
      sCtrlNetworkRemoteDev = "OSC-X32C"
    Case #SCS_CS_NETWORK_REM_OSC_X32TC
      sCtrlNetworkRemoteDev = "OSC-X32TC"
    Case #SCS_CS_NETWORK_REM_OSC_OTHER
      sCtrlNetworkRemoteDev = "OSC-Other"
    Case #SCS_CS_NETWORK_REM_LF
      sCtrlNetworkRemoteDev = "LF"
    Case #SCS_CS_NETWORK_REM_VMIX
      sCtrlNetworkRemoteDev = "vMix"
    Default
      sCtrlNetworkRemoteDev = "AnyDev"
  EndSelect
  ProcedureReturn sCtrlNetworkRemoteDev
EndProcedure

Procedure.s decodeCtrlNetworkRemoteDevL(nCtrlNetworkRemoteDev)
  ; Changed 28Nov2022 11.9.7aq to force English spelling for these devices, instead of looking up language translations that probably don't match the actual product names in that language
  Protected sCtrlNetworkRemoteDev.s, sCtrlNetworkRemoteDevL.s
  
  Select nCtrlNetworkRemoteDev
    Case #SCS_CS_NETWORK_REM_OSC_X32
      sCtrlNetworkRemoteDevL = "Behringer X32 Digital Mixer"
    Case #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
      sCtrlNetworkRemoteDevL = "Behringer X32 Compact Mixer"
    Case #SCS_CS_NETWORK_REM_OSC_X32TC
      ; Product name changed from "X32 Theatre Control" to "TheatreMix" - see email from James Holt 20Nov2022
      sCtrlNetworkRemoteDevL = "TheatreMix"
    Case #SCS_CS_NETWORK_REM_LF
      sCtrlNetworkRemoteDevL = "LightFactory"
    Case #SCS_CS_NETWORK_REM_VMIX
      sCtrlNetworkRemoteDevL = "vMix"
    Default
      sCtrlNetworkRemoteDev = decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev)
      If sCtrlNetworkRemoteDev
        sCtrlNetworkRemoteDevL = Lang("Network", sCtrlNetworkRemoteDev)
      EndIf
  EndSelect
  ProcedureReturn sCtrlNetworkRemoteDevL
  
EndProcedure

Procedure.s decodeCtrlNetworkRemoteDevLShort(nCtrlNetworkRemoteDev)
  ; Changed 28Nov2022 11.9.7aq to be compatible with decodeCtrlNetworkRemoteDevL()
  Protected sCtrlNetworkRemoteDevL.s
  Protected nLeftBracket
  
  sCtrlNetworkRemoteDevL = decodeCtrlNetworkRemoteDevL(nCtrlNetworkRemoteDev)
  If sCtrlNetworkRemoteDevL
    nLeftBracket = FindString(sCtrlNetworkRemoteDevL, "(")
    If nLeftBracket >= 2
      sCtrlNetworkRemoteDevL = RTrim(Left(sCtrlNetworkRemoteDevL, (nLeftBracket-1)))
    EndIf
  EndIf
  ProcedureReturn sCtrlNetworkRemoteDevL
  
EndProcedure

Procedure encodeCtrlNetworkRemoteDev(sCtrlNetworkRemoteDev.s)
  Protected nCtrlNetworkRemoteDev
  
  Select sCtrlNetworkRemoteDev
    Case "AnyDev"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_ANY
    Case "SCS"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_SCS
    Case "PJLink"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJLINK
    Case "PJNet", "RemSanyoProj"    ; RemSanyoProj for users who tested early versions for the Sanyo projector control
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJNET
    Case "X32", "OSC-X32"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32
    Case "X32C", "OSC-X32C"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
    Case "X32TC", "OSC-X32TC"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32TC
    Case "OSC-Other"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_OTHER
    Case "LF"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_LF
    Case "vMix"
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_VMIX
    Default
      nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_ANY
  EndSelect
  ProcedureReturn nCtrlNetworkRemoteDev
EndProcedure

Procedure.s decodeCueNetworkRemoteDev(nCueNetworkRemoteDev)
  Protected sCueNetworkRemoteDev.s
  
  Select nCueNetworkRemoteDev
    Case #SCS_CC_NETWORK_REM_ANY
      sCueNetworkRemoteDev = "AnyDev"
    Case #SCS_CC_NETWORK_REM_SCS
      sCueNetworkRemoteDev = "SCS"
    Case #SCS_CC_NETWORK_REM_OSC_X32
      sCueNetworkRemoteDev = "OSC-X32"
    Case #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
      sCueNetworkRemoteDev = "OSC-X32C"
    Case #SCS_CC_NETWORK_REM_OSC_X32TC
      sCueNetworkRemoteDev = "OSC-X32TC"
    Case #SCS_CC_NETWORK_REM_LF
      sCueNetworkRemoteDev = "LF"
    Default
      sCueNetworkRemoteDev = "AnyDev"
  EndSelect
  ProcedureReturn sCueNetworkRemoteDev
EndProcedure

Procedure.s decodeCueNetworkRemoteDevL(nCueNetworkRemoteDev)
  ; Changed 28Nov2022 11.9.7aq to force English spelling for these devices, instead of looking up language translations that probably don't match the actual product names in that language
  Protected sCueNetworkRemoteDev.s, sCueNetworkRemoteDevL.s
  
  Select nCueNetworkRemoteDev
    Case #SCS_CC_NETWORK_REM_OSC_X32
      sCueNetworkRemoteDevL = "Behringer X32 Digital Mixer"
    Case #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
      sCueNetworkRemoteDevL = "Behringer X32 Compact Mixer"
    Case #SCS_CC_NETWORK_REM_OSC_X32TC
      ; Product name changed from "X32 Theatre Control" to "TheatreMix" - see email from James Holt 20Nov2022
      sCueNetworkRemoteDevL = "TheatreMix"
    Case #SCS_CC_NETWORK_REM_LF
      sCueNetworkRemoteDevL = "LightFactory"
    Default
      sCueNetworkRemoteDev = decodeCueNetworkRemoteDev(nCueNetworkRemoteDev)
      If sCueNetworkRemoteDev
        sCueNetworkRemoteDevL = Lang("Network", sCueNetworkRemoteDev)
      EndIf
  EndSelect
  ProcedureReturn sCueNetworkRemoteDevL
EndProcedure

Procedure encodeCueNetworkRemoteDev(sCueNetworkRemoteDev.s)
  Protected nCueNetworkRemoteDev
  
  Select sCueNetworkRemoteDev
    Case "AnyDev"
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_ANY
    Case "SCS"
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_SCS
    Case "X32", "OSC-X32"
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_OSC_X32
    Case "X32C", "OSC-X32C"
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
    Case "X32TC", "OSC-X32TC"
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_OSC_X32TC
    Case "LF"
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_LF
    Default
      nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_ANY
  EndSelect
  ProcedureReturn nCueNetworkRemoteDev
EndProcedure

Procedure.s decodeNetworkProtocol(nNetworkProtocol)
  Protected sNetworkProtocol.s
  
  Select nNetworkProtocol
    Case #SCS_NETWORK_PR_TCP
      sNetworkProtocol = "TCP"
    Case #SCS_NETWORK_PR_UDP
      sNetworkProtocol = "UDP"
    Default
      sNetworkProtocol = Str(nNetworkProtocol)
  EndSelect
  ProcedureReturn sNetworkProtocol
EndProcedure

Procedure encodeNetworkProtocol(sNetworkProtocol.s)
  Protected nNetworkProtocol
  
  Select sNetworkProtocol
    Case "UDP"
      nNetworkProtocol = #SCS_NETWORK_PR_UDP
    Default
      nNetworkProtocol = #SCS_NETWORK_PR_TCP
  EndSelect
  ProcedureReturn nNetworkProtocol
EndProcedure

Procedure buildNetworkDevDesc(*pNetworkControl.tyNetworkControl)
  PROCNAMEC()
  Static sClient.s, sServer.s, sDummy.s, sRemote.s, sLocal.s
  Static bStaticLoaded
  
  ; populate static variables if necessary
  If bStaticLoaded = #False
    sClient = Lang("Network", "Client")
    sServer = Lang("Network", "Server")
    sDummy = Lang("Network", "Dummy")
    sRemote = Lang("Network", "Remote")
    sLocal = Lang("Network", "Local")
    bStaticLoaded = #True
  EndIf
  
  With *pNetworkControl
    If \bNWDummy
      \sNetworkDevDesc = sDummy
    Else
      Select \nNetworkRole
        Case #SCS_ROLE_DUMMY
          \sNetworkDevDesc = sDummy
        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
          ; \sNetworkDevDesc = sClient + "[" + sRemote + "=" + stringNVL(\sRemoteHost,"?") + ":" + stringNVL(portIntToStr(\nRemotePort),"?") + "]"
          \sNetworkDevDesc = sRemote + "=" + stringNVL(\sRemoteHost,"?") + ":" + stringNVL(portIntToStr(\nRemotePort),"?")
        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
          ; \sNetworkDevDesc = sServer + "[" + sLocal + "=" + stringNVL(portIntToStr(\nLocalPort),"?") + "]"
          \sNetworkDevDesc = sLocal + "=" + stringNVL(portIntToStr(\nLocalPort),"?")
      EndSelect
    EndIf
  EndWith
  
EndProcedure

Procedure.s makeNetworkDevDesc(pDevGrp, pDevNo)
  PROCNAMEC()
  Static sClient.s, sServer.s, sDummy.s, sRemote.s, sLocal.s
  Static bStaticLoaded
  Protected nNetworkRole = -1
  Protected nNetworkProtocol
  Protected sLogicalDev.s
  Protected sRemoteHost.s, nRemotePort, nLocalPort
  Protected sNetworkDevDesc.s
  Protected nDevMapDevPtr
  Protected bDummy
  
  ; debugMsg(sProcName, #SCS_START + ", pDevGrp=" + decodeDevGrp(pDevGrp) + ", pDevNo=" + pDevNo)
  
  ; populate static variables if necessary
  If bStaticLoaded = #False
    sClient = Lang("Network", "Client")
    sServer = Lang("Network", "Server")
    sDummy = Lang("Network", "Dummy")
    sRemote = Lang("Network", "Remote")
    sLocal = Lang("Network", "Local")
    bStaticLoaded = #True
  EndIf
  
  If pDevNo >= 0
    Select pDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        nNetworkProtocol = grProdForDevChgs\aCtrlSendLogicalDevs(pDevNo)\nNetworkProtocol
        nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(pDevNo)\nNetworkRole
        sLogicalDev = grProdForDevChgs\aCtrlSendLogicalDevs(pDevNo)\sLogicalDev
        
      Case #SCS_DEVGRP_CUE_CTRL
        nNetworkProtocol = grProdForDevChgs\aCueCtrlLogicalDevs(pDevNo)\nNetworkProtocol
        nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(pDevNo)\nNetworkRole
        sLogicalDev = grProdForDevChgs\aCueCtrlLogicalDevs(pDevNo)\sCueCtrlLogicalDev
    EndSelect
  EndIf
  
  Select nNetworkProtocol
    Case #SCS_NETWORK_PR_TCP
      sNetworkDevDesc = "TCP "
    Case #SCS_NETWORK_PR_UDP
      sNetworkDevDesc = "UDP "
  EndSelect
  
  nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, pDevGrp, sLogicalDev)
  If nDevMapDevPtr >= 0
    bDummy = grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
    sRemoteHost = grMapsForDevChgs\aDev(nDevMapDevPtr)\sRemoteHost
    nRemotePort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort
    nLocalPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort
  EndIf
  
  If bDummy
    sNetworkDevDesc + sDummy
  Else
    Select nNetworkRole
      Case #SCS_ROLE_DUMMY
        sNetworkDevDesc + sDummy
      Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
        sNetworkDevDesc + sClient + ", " + sRemote + " = " + stringNVL(sRemoteHost,"?") + ":" + stringNVL(portIntToStr(nRemotePort),"?")
        ; sNetworkDevDesc + sRemote + " = " + stringNVL(sRemoteHost,"?") + ":" + stringNVL(portIntToStr(nRemotePort),"?")
      Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
        sNetworkDevDesc + sServer + ", " + sLocal + " = " + stringNVL(portIntToStr(nLocalPort),"?")
        ; sNetworkDevDesc + sLocal + " = " + stringNVL(portIntToStr(nLocalPort),"?")
    EndSelect
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + sNetworkDevDesc)
  ProcedureReturn sNetworkDevDesc
EndProcedure

Procedure getOSCItemNumber(nNetworkControlPtr, nOSCCmdType, sOSCItemString.s, bOSCItemPlaceHolder)
  PROCNAMEC()
  Protected n
  Protected nNumber
  Protected sItemString.s
  Protected bItemNumberIs2Digits  ; channel, auxin, fxrtn, bus, matrix
  Protected bItemNumberIs1Digit   ; dca group, main, mute group
  
  ; debugMsg0(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nOSCCmdType=" + nOSCCmdType + " (" + decodeOSCCmdType(nOSCCmdType) + "), sOSCItemString=" + #DQUOTE$ + sOSCItemString + #DQUOTE$ + ", bOSCItemPlaceHolder=" + strB(bOSCItemPlaceHolder))
  
  nNumber = -1
  If bOSCItemPlaceHolder = #False
    sItemString = Trim(sOSCItemString)
    If sItemString
      If nNetworkControlPtr >= 0
        With gaNetworkControl(nNetworkControlPtr)
          Select nOSCCmdType
            Case #SCS_CS_OSC_GOCUE
              For n = 0 To \rX32NWData\nMaxCue
                If \rX32NWData\sCue(n) = sItemString
                  nNumber = n
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_GOSCENE
              For n = 0 To \rX32NWData\nMaxScene
                If \rX32NWData\sScene(n) = sItemString
                  nNumber = n
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_GOSNIPPET
              For n = 0 To \rX32NWData\nMaxSnippet
                If \rX32NWData\sSnippet(n) = sItemString
                  nNumber = n
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_MUTECHANNEL
              bItemNumberIs2Digits = #True
              For n = 0 To \rX32NWData\nMaxChannel
                If \rX32NWData\sChannel(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_MUTEDCAGROUP
              bItemNumberIs1Digit = #True
              For n = 0 To \rX32NWData\nMaxDCAGroup
                If \rX32NWData\sDCAGroup(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_MUTEAUXIN
              bItemNumberIs2Digits = #True
              For n = 0 To \rX32NWData\nMaxAuxIn
                If \rX32NWData\sAuxIn(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_MUTEFXRTN
              bItemNumberIs2Digits = #True
              For n = 0 To \rX32NWData\nMaxFXReturn
                If \rX32NWData\sFXReturn(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_MUTEBUS
              bItemNumberIs2Digits = #True
              For n = 0 To \rX32NWData\nMaxBus
                If \rX32NWData\sBus(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
            Case #SCS_CS_OSC_MUTEMATRIX
              bItemNumberIs2Digits = #True
              For n = 0 To \rX32NWData\nMaxMatrix
                If \rX32NWData\sMatrix(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
;             Case #SCS_CS_OSC_MUTEMAIN
;               bItemNumberIs1Digit = #True
;               For n = 0 To \rX32NWData\nMaxMain
;                 If \rX32NWData\sMain(n) = sItemString
;                   nNumber = n + 1
;                   Break
;                 EndIf
;               Next n
              
            Case #SCS_CS_OSC_MUTEMG
              bItemNumberIs1Digit = #True
              For n = 0 To \rX32NWData\nMaxMuteGroup
                If \rX32NWData\sMuteGroup(n) = sItemString
                  nNumber = n + 1
                  Break
                EndIf
              Next n
              
          EndSelect
        EndWith
        ; debugMsg(sProcName, "sOSCItemString=" + #DQUOTE$ + sOSCItemString + #DQUOTE$ + ", nNumber=" + nNumber + ", sItemString=" + sItemString + ", bItemNumberIs2Digits=" + strB(bItemNumberIs2Digits) + ", bItemNumberIs1Digit=" + strB(bItemNumberIs1Digit))
        If nNumber = -1
          ; string not found, so use string itself if it is numeric
          ; (mod applied 16Jul2015 11.4.0.2 following forum bug report by Onno Rietveld)
          If IsNumeric(sItemString)
            nNumber = Val(sItemString)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nNumber)
  ProcedureReturn nNumber
  
EndProcedure

Procedure.s getOSCItemString(nNetworkControlPtr, nOSCCmdType, nOSCItemNr)
  PROCNAMEC()
  Protected n
  Protected sItemString.s
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)\rX32NWData
      n = nOSCItemNr
      If n >= 0
        Select nOSCCmdType
          Case #SCS_CS_OSC_GOCUE
            If n <= \nMaxCue
              sItemString = \sCue(n)
            EndIf
            
          Case #SCS_CS_OSC_GOSCENE
            If n <= \nMaxScene
              sItemString = \sScene(n)
            EndIf
            
          Case #SCS_CS_OSC_GOSNIPPET
            If n <= \nMaxSnippet
              sItemString = \sSnippet(n)
            EndIf
            
          Default
            n = nOSCItemNr - 1
            If n >= 0
              Select nOSCCmdType
                Case #SCS_CS_OSC_MUTECHANNEL
                  If n <= \nMaxChannel
                    sItemString = \sChannel(n)
                  EndIf
                  
                Case #SCS_CS_OSC_MUTEDCAGROUP
                  If n <= \nMaxDCAGroup
                    sItemString = \sDCAGroup(n)
                  EndIf
                  
                Case #SCS_CS_OSC_MUTEAUXIN
                  If n <= \nMaxAuxIn
                    sItemString = \sAuxIn(n)
                  EndIf
                  
                Case #SCS_CS_OSC_MUTEFXRTN
                  If n <= \nMaxFXReturn
                    sItemString = \sFXReturn(n)
                  EndIf
                  
                Case #SCS_CS_OSC_MUTEBUS
                  If n <= \nMaxBus
                    sItemString = \sBus(n)
                  EndIf
                  
                Case #SCS_CS_OSC_MUTEMATRIX
                  If n <= \nMaxMatrix
                    sItemString = \sMatrix(n)
                  EndIf
                  
                Case #SCS_CS_OSC_MUTEMAINLR
                  ; If n <= \nMaxMain
                    sItemString = \sMain(0)
                  ; EndIf
                  
                Case #SCS_CS_OSC_MUTEMAINMC
                  ; If n <= \nMaxMain
                    sItemString = \sMain(1)
                  ; EndIf
                  
                Case #SCS_CS_OSC_MUTEMG
                  If n <= \nMaxMuteGroup
                    sItemString = \sMuteGroup(n)
                  EndIf
                  
              EndSelect
            EndIf
        EndSelect
      EndIf
    EndWith
  EndIf
  ProcedureReturn sItemString
  
EndProcedure

Procedure.s buildNetworkSendString(pSubPtr, nCtrlSendIndex, bPrimaryFile=#True)
  PROCNAME(buildSubProcName(#PB_Compiler_Procedure, pSubPtr, bPrimaryFile))
  Protected sMsg.s, n, sTmp.s
  Protected bCtlFound
  Protected sNoSpaces.s, bOK
  Protected sCharString.s
  Protected bGetItemNumber, nItemNumber
  Protected bItemNumberIs2Digits  ; channel, auxin, fxrtn, bus, matrix
  Protected bItemNumberIs1Digit   ; dca group, mute group
  Protected bParam1IsItemNumber, bParam1IsItemString
  Protected bGetItemString, sItemString.s
  Protected sChannelEtc.s
  Protected rCtrlSend.tyCtrlSend
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  If pSubPtr >= 0
    If bPrimaryFile
      rCtrlSend = aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
    Else
      rCtrlSend = a2ndSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
    EndIf
      
    With rCtrlSend
      If \bNetworkSend
        \sSendString = ""
        If \bIsOSC
          Select \nOSCCmdType
            Case #SCS_CS_OSC_GOCUE
              sMsg = "/-action/gocue"
              bGetItemNumber = #True
              bParam1IsItemNumber = #True
              
            Case #SCS_CS_OSC_GOSCENE
              sMsg = "/-action/goscene"
              bGetItemNumber = #True
              bParam1IsItemNumber = #True
              
            Case #SCS_CS_OSC_GOSNIPPET
              sMsg = "/-action/gosnippet"
              bGetItemNumber = #True
              bParam1IsItemNumber = #True
              
            Case #SCS_CS_OSC_MUTECHANNEL
              sMsg = "/ch/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              ; set lVal as reverse of mute as address is 'mix on', not 'mute'
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 0"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 1"
              EndSelect
              
            Case #SCS_CS_OSC_MUTEDCAGROUP
              sMsg = "/dca/?/on"  ; nb no /mix
              bGetItemNumber = #True
              bItemNumberIs1Digit = #True
              ; set lVal as reverse of mute as address is 'mix on', not 'mute'
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 0"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 1"
              EndSelect
              
            Case #SCS_CS_OSC_MUTEAUXIN
              sMsg = "/auxin/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              ; set lVal as reverse of mute as address is 'mix on', not 'mute'
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 0"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 1"
              EndSelect
              
            Case #SCS_CS_OSC_MUTEFXRTN
              sMsg = "/fxrtn/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              ; set lVal as reverse of mute as address is 'mix on', not 'mute'
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 0"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 1"
              EndSelect
              
            Case #SCS_CS_OSC_MUTEBUS
              sMsg = "/bus/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              ; set lVal as reverse of mute as address is 'mix on', not 'mute'
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 0"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 1"
              EndSelect
              
            Case #SCS_CS_OSC_MUTEMATRIX
              sMsg = "/mtx/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              ; set lVal as reverse of mute as address is 'mix on', not 'mute'
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 0"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 1"
              EndSelect
              
            Case #SCS_CS_OSC_MUTEMAINLR, #SCS_CS_OSC_MUTEMAINMC
;               nItemNumber = getOSCItemNumber(\nCSPhysicalDevPtr, \nOSCCmdType, \sOSCItemString, \bOSCItemPlaceHolder)
;               debugMsg2(sProcName, "getOSCItemNumber(" + \nCSPhysicalDevPtr + ", " + decodeOSCCmdType(\nOSCCmdType) + ", '" + \sOSCItemString + "', " + strB(\bOSCItemPlaceHolder) + ")", nItemNumber)
;               If nItemNumber = 1
;                 sMsg = "/main/st/mix/on"
;               ElseIf nItemNumber = 2
;                 sMsg = "/main/m/mix/on"
;               Else
;                 sMsg = ""
;               EndIf
              If \nOSCCmdType = #SCS_CS_OSC_MUTEMAINLR
                sMsg = "/main/st/mix/on"
              Else
                sMsg = "/main/m/mix/on"
              EndIf
              If sMsg
                bGetItemNumber = #False
                Select \nOSCMuteAction
                  Case #SCS_MUTE_ON
                    sMsg + " ,i 1"
                  Case #SCS_MUTE_OFF
                    sMsg + " ,i 0"
                EndSelect
              EndIf                
              
            Case #SCS_CS_OSC_MUTEMG
              sMsg = "/config/mute/?"
              bGetItemNumber = #True
              bItemNumberIs1Digit = #True
              Select \nOSCMuteAction
                Case #SCS_MUTE_ON
                  sMsg + " ,i 1"
                Case #SCS_MUTE_OFF
                  sMsg + " ,i 0"
              EndSelect
              
            Case #SCS_CS_OSC_FREEFORMAT
              sMsg = \sOSCItemString
              
            Case #SCS_CS_OSC_TC_GO
              sMsg = "/go"
              
            Case #SCS_CS_OSC_TC_BACK
              sMsg = "/back"
              
            Case #SCS_CS_OSC_TC_JUMP
              sMsg = "/jump"
              bGetItemString = #True
              bParam1IsItemString = #True
              
          EndSelect
          
          If bGetItemNumber
            If \nOSCItemNr >= 0
              nItemNumber = \nOSCItemNr
            Else
              nItemNumber = getOSCItemNumber(\nCSPhysicalDevPtr, \nOSCCmdType, \sOSCItemString, \bOSCItemPlaceHolder)
            EndIf
            ; debugMsg2(sProcName, "getOSCItemNumber(" + \nCSPhysicalDevPtr + ", " + decodeOSCCmdType(\nOSCCmdType) + ", '" + \sOSCItemString + "', " + strB(\bOSCItemPlaceHolder) + ")", nItemNumber)
            If nItemNumber >= 0
              If bItemNumberIs2Digits
                sChannelEtc = RSet(Str(nItemNumber),2,"0")
                sMsg = ReplaceString(sMsg, "?", sChannelEtc)
              ElseIf bItemNumberIs1Digit
                sMsg = ReplaceString(sMsg, "?", Str(nItemNumber))
              EndIf
              If bParam1IsItemNumber
                sMsg + " ,i " + Str(nItemNumber)
              EndIf
            Else
              ; will get here if X32 not connected and message requires an item from the X32, eg a snippet name and number
              If bParam1IsItemNumber
                sMsg + " ,i ?"
              EndIf
            EndIf
          EndIf
          
          If bGetItemString
            sItemString = \sOSCItemString
            If bParam1IsItemString
              sMsg + " ,s " + Trim(sItemString)
            EndIf
          EndIf
          
          \sSendString = sMsg
          
        Else
          ; debugMsg(sProcName, "\nEntryMode=" + decodeEntryMode(\nEntryMode) + ", \sEnteredString=" + \sEnteredString)
          Select \nEntryMode
            Case #SCS_ENTRYMODE_ASCII, #SCS_ENTRYMODE_UTF8
              ; ASCII or UTF8 mode
              For n = 1 To Len(RTrim(\sEnteredString))
                sTmp = Mid(\sEnteredString, n, 1)
                sMsg + " " + stringToHexString(sTmp)
                \sSendString + sTmp
              Next n
              
            Case #SCS_ENTRYMODE_HEX
              ; Hex mode
              bOK = #True
              sNoSpaces = ReplaceString(\sEnteredString, " ", "")     ; remove all spaces from entered string
              For n = 1 To Len(sNoSpaces)
                sTmp = UCase(Mid(sNoSpaces, n, 1))
                If FindString(#SCS_HEX_VALID_CHARS, sTmp) = 0
                  ; illegal hex character (shouldn't happen)
                  bOK = #False
                  Break
                EndIf
                sMsg + " " + sTmp
                n = n + 1
                If n <= Len(sNoSpaces)
                  sTmp = UCase(Mid(sNoSpaces, n, 1))
                  If FindString(#SCS_HEX_VALID_CHARS, sTmp) = 0
                    ; illegal hex character (shouldn't happen)
                    bOK = #False
                    Break
                  EndIf
                  sMsg + sTmp
                EndIf
              Next n
              If bOK
                \sSendString = hexStringToString(sNoSpaces)
              EndIf
              
            Case #SCS_ENTRYMODE_ASCII_PLUS_CTL
              ; ASCII+CTL mode
              For n = 1 To Len(RTrim(\sEnteredString))
                bCtlFound = #False
                ;debugMsg(sProcName, "Mid(\sEnteredString, " + n + ", 1)=" + Mid(\sEnteredString, n, 1))
                If Mid(\sEnteredString, n, 1) = "<"
                  ;debugMsg(sProcName, "Mid(\sEnteredString, " + n + 3 + ", 1)=" + Mid(\sEnteredString + "    ", n + 3, 1))
                  ;debugMsg(sProcName, "Mid(\sEnteredString, " + n + 4 + ", 1)=" + Mid(\sEnteredString + "     ", n + 4, 1))
                  If Mid(\sEnteredString + "    ", n + 3, 1) = ">"
                    sCharString = Mid(\sEnteredString, n, 4)
                    bCtlFound = #True
                  ElseIf Mid(\sEnteredString + "     ", n + 4, 1) = ">"
                    sCharString = Mid(\sEnteredString, n, 5)
                    bCtlFound = #True
                  EndIf
                  ;debugMsg(sProcName, "bCtlFound=" + bCtlFound + ", sCharString=" + sCharString)
                  If bCtlFound
                    Select UCase(sCharString)
                      Case "<NUL>"
                        sTmp = Chr($0)
                      Case "<SOH>"
                        sTmp = Chr($1)
                      Case "<STX>"
                        sTmp = Chr($2)
                      Case "<ETX>"
                        sTmp = Chr($3)
                      Case "<EOT>"
                        sTmp = Chr($4)
                      Case "<ENQ>"
                        sTmp = Chr($5)
                      Case "<ACK>"
                        sTmp = Chr($6)
                      Case "<BEL>"
                        sTmp = Chr($7)
                      Case "<BS>"
                        sTmp = Chr($8)
                      Case "<TAB>"
                        sTmp = Chr($9)
                      Case "<LF>"
                        sTmp = Chr($A)
                      Case "<VT>"
                        sTmp = Chr($B)
                      Case "<FF>"
                        sTmp = Chr($C)
                      Case "<CR>"
                        sTmp = Chr($D)
                      Case "<SO>"
                        sTmp = Chr($E)
                      Case "<SI>"
                        sTmp = Chr($F)
                      Case "<DLE>"
                        sTmp = Chr($10)
                      Case "<DC1>"
                        sTmp = Chr($11)
                      Case "<DC2>"
                        sTmp = Chr($12)
                      Case "<DC3>"
                        sTmp = Chr($13)
                      Case "<DC4>"
                        sTmp = Chr($14)
                      Case "<NAK>"
                        sTmp = Chr($15)
                      Case "<SYN>"
                        sTmp = Chr($16)
                      Case "<ETB>"
                        sTmp = Chr($17)
                      Case "<CAN>"
                        sTmp = Chr($18)
                      Case "<EM>"
                        sTmp = Chr($19)
                      Case "<SUB>"
                        sTmp = Chr($1A)
                      Case "<ESC>"
                        sTmp = Chr($1B)
                      Case "<FS>"
                        sTmp = Chr($1C)
                      Case "<GS>"
                        sTmp = Chr($1D)
                      Case "<Network>"
                        sTmp = Chr($1E)
                      Case "<US>"
                        sTmp = Chr($1F)
                      Case "<DEL>"
                        sTmp = Chr($7F)
                      Default
                        bCtlFound = #False
                    EndSelect
                  EndIf
                EndIf
                If bCtlFound
                  n = n + Len(sCharString) - 1
                Else
                  sTmp = Mid(\sEnteredString, n, 1)
                EndIf
                sMsg + " " + stringToHexString(sTmp)
                \sSendString + sTmp
              Next n
              
          EndSelect
          
          If \bAddCR
            sMsg + " 0D"
            \sSendString + Chr($D)
          EndIf
          
          If \bAddLF
            sMsg + " 0A"
            \sSendString + Chr($A)
          EndIf
          
          If Len(sMsg) > 2
            If Left(sMsg, 1) = " "
              sMsg = Mid(sMsg, 2)   ; chops off leading space (do not use LTrim as there may be legitimate spaces at the start of an ASCII message)
            EndIf
          EndIf
          
        EndIf
        
      EndIf ; EndIf \bNetworkSend
      
    EndWith
    
    If bPrimaryFile
      aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex] = rCtrlSend
    Else
      a2ndSub(pSubPtr)\aCtrlSend[nCtrlSendIndex] = rCtrlSend
    EndIf
      
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + sMsg)
  ProcedureReturn sMsg
  
EndProcedure

Procedure listNetworkControl()
  PROCNAMEC()
  Protected n, sLine.s
  
  debugMsg(sProcName, #SCS_START + ", gnMaxNetworkControl=" + gnMaxNetworkControl)
  For n = 0 To gnMaxNetworkControl
    With gaNetworkControl(n)
      sLine = "gaNetworkControl(" + n + ")\nDevType=" + decodeDevType(\nDevType)
      Select \nDevType
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          sLine + ", \nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev)
        Case #SCS_DEVTYPE_CC_NETWORK_IN
          sLine + ", \nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev)
      EndSelect
      sLine + ", \bNetworkDevInitialized=" + strB(\bNetworkDevInitialized)
      If \bConnectWhenReqd
        sLine + ", \bConnectWhenReqd=" + strB(\bConnectWhenReqd)
      EndIf
      If \nUseNetworkControlPtr >= 0
        sLine + ", \nUseNetworkControlPtr=" + \nUseNetworkControlPtr
      EndIf
      If \bRAIDev
        sLine + ", \bRAIDev=" + strB(\bRAIDev)
      EndIf
      If \nOSCVersion
        sLine + ", \nOSCVersion=" + decodeOSCVersion(\nOSCVersion)
      EndIf
      debugMsg(sProcName, sLine)
      debugMsg(sProcName, ".. \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) +
                          ", \sNetworkDevDesc=" + #DQUOTE$ + \sNetworkDevDesc + #DQUOTE$ + ", \nDevMapId=" + \nDevMapId + ", \nDevMapDevPtr=" + \nDevMapDevPtr + ", \nDevNo=" + \nDevNo + ", \bConnectWhenReqd=" + strB(\bConnectWhenReqd))
      Select \nNetworkRole
        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
          debugMsg(sProcName, ".. \nNetworkRole=" + decodeNetworkRole(\nNetworkRole) + ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort + ", \nClientConnection=" + decodeHandle(\nClientConnection))
        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
          debugMsg(sProcName, ".. \nNetworkRole=" + decodeNetworkRole(\nNetworkRole) + ", \nLocalPort=" + \nLocalPort + ", \nServerConnection=" + decodeHandle(\nServerConnection))
        Default
          debugMsg(sProcName, ".. \nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
      EndSelect
    EndWith
  Next n
EndProcedure

Procedure checkNetworkDevsForCtrlSends()
  PROCNAMEC()
  Protected i, j, n, m, bOK
  Protected Dim abUnavailable(0)
  Protected Dim asSubCueLabels.s(0)
  Protected Dim abOpen(0)
  Protected bAllAvailable, bAllOpen
  Protected sMsg.s
  Protected nReply
  Protected bPortsChanged
  Protected bModalDisplayed
  Protected sCheckText.s
  Protected nFlags
  Protected nLabel
  
  debugMsg(sProcName, #SCS_START)
  
  ;- to be done (checkNetworkDevsForCtrlSends)
  
  bOK = #True
  bAllAvailable = #True
  bAllOpen = #True
  bModalDisplayed = gbModalDisplayed
  
  nLabel = 6000
  gbModalDisplayed = bModalDisplayed
  debugMsg(sProcName, #SCS_END + " returning " + strB(bOK))
  ProcedureReturn bOK
EndProcedure

Procedure processNetworkGoButtonCommand()
  PROCNAMEC()
  samAddRequest(#SCS_SAM_GO_REMOTE, -1)
  ProcedureReturn #True
EndProcedure

Procedure processGoRemote(pCuePtr)
  PROCNAMECQ(pCuePtr)
  ; note: this procedure is only called from SAM (via #SCS_SAM_GO_REMOTE) so is only executed from the main thread
  Protected bIgnoreInputMsg
  
  debugMsg(sProcName, #SCS_START)
  
  If pCuePtr = -1
    debugMsg(sProcName, "calling goIfOK()")
    goIfOK()
  Else
    With aCue(pCuePtr)
      If \bCueCurrentlyEnabled
        If \bKeepOpen
          ; hotkey cue or non-linear cue or external trigger cue
          If \nActivationMethodReqd = #SCS_ACMETH_HK_TOGGLE Or \nActivationMethodReqd = #SCS_ACMETH_EXT_TOGGLE
            ; hotkey (toggle) activation method, so fade out / stop cue IF cue is currrently playing
            If (\nCueState >= #SCS_CUE_FADING_IN) And (\nCueState <= #SCS_CUE_FADING_OUT)
              debugMsg(sProcName, "calling fadeOutCue(" + \sCue + ", #False)")
              fadeOutCue(pCuePtr, #False)
            Else
              debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(pCuePtr) + ")")
              playCueViaCas(pCuePtr)
              If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
                FMP_sendCommandIfReqd(#SCS_OSCINP_CUE_PLAY, pCuePtr)
              EndIf
            EndIf
          ElseIf \nActivationMethodReqd = #SCS_ACMETH_EXT_COMPLETE
            If \nCueState >= #SCS_CUE_FADING_IN And \nCueState <= #SCS_CUE_FADING_OUT
              ; cue is currently playing so ignore this request
              debugMsg(sProcName, "ignore request to play cue " + getCueLabel(pCuePtr) + " as it is currently playing and the activation method is #SCS_ACMETH_EXT_COMPLETE")
              WMN_setStatusField(LangPars("Errors", "ExtCannotPlayComp", getCueLabel(pCuePtr)), #SCS_STATUS_ERROR)
              bIgnoreInputMsg = #True
            Else
              debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(pCuePtr) + ")")
              playCueViaCas(pCuePtr)
              If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
                FMP_sendCommandIfReqd(#SCS_OSCINP_CUE_PLAY, pCuePtr)
              EndIf
            EndIf
          Else
            debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(pCuePtr) + ")")
            playCueViaCas(pCuePtr)
            If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
              FMP_sendCommandIfReqd(#SCS_OSCINP_CUE_PLAY, pCuePtr)
            EndIf
          EndIf
          If bIgnoreInputMsg = #False
            If \nHideCueOpt = #SCS_HIDE_NO
              gbCallLoadDispPanels = #True
            EndIf
          EndIf
        Else
          ; non-hotkey etc cue
          setGridRow(pCuePtr)
          If pCuePtr <> gnCueToGo
            GoToCue(pCuePtr)
          EndIf
          debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(pCuePtr) + ")")
          playCueViaCas(pCuePtr)
          If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
            FMP_sendCommandIfReqd(#SCS_OSCINP_CUE_PLAY, pCuePtr)
          EndIf
          ; debugMsg(sProcName, "calling highlightLine(" + getCueLabel(pCuePtr) + ")")
          highlightLine(pCuePtr)
          gbCallLoadDispPanels = #True
          debugMsg(sProcName, "calling setCueToGo()")
          setCueToGo()
          gbCallSetNavigateButtons = #True
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkGoCommand(sNetworkCue.s, sExpectedCue.s="")
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  Protected nCuePtr
  Protected bResult, sThisCue.s
  Protected bIgnoreInputMsg
  
  debugMsg(sProcName, #SCS_START + ", sNetworkCue=" + sNetworkCue + ", sExpectedCue=" + sExpectedCue)
  
  gsProcessNetworkCommandError = ""
  If sNetworkCue = "0" Or Len(sNetworkCue) = 0
    bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(1000)
    If bIgnoreInputMsg = #False
      If sExpectedCue
        sThisCue = sExpectedCue
        nCuePtr = getCuePtr(sExpectedCue)
        If nCuePtr >= 0
          If aCue(nCuePtr)\bCueCurrentlyEnabled
            samAddRequest(#SCS_SAM_GO_WITH_EXPECTED_CUE, nCuePtr)
            bResult = #True
          EndIf
        EndIf
      Else
        samAddRequest(#SCS_SAM_GO_REMOTE, -1)
        bResult = #True
      EndIf
    EndIf
  Else
    sThisCue = sNetworkCue  
    nCuePtr = getCuePtr(sNetworkCue)
    If nCuePtr >= 0
      bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(1000 + nCuePtr)
      If bIgnoreInputMsg = #False
        With aCue(nCuePtr)
          If \bCueCurrentlyEnabled
            If \nActivationMethod = #SCS_ACMETH_EXT_COMPLETE
              If \nCueState >= #SCS_CUE_FADING_IN And \nCueState <= #SCS_CUE_FADING_OUT
                ; cue is currently playing so ignore this request
                debugMsg(sProcName, "ignore request to play cue " + getCueLabel(nCuePtr) + " as it is currently playing and the activation method is #SCS_ACMETH_EXT_COMPLETE")
                WMN_setStatusField(LangPars("Errors", "ExtCannotPlayComp", getCueLabel(nCuePtr)), #SCS_STATUS_ERROR)
                bIgnoreInputMsg = #True
              Else
                samAddRequest(#SCS_SAM_GO_REMOTE, nCuePtr)
                bResult = #True
              EndIf
            Else
              samAddRequest(#SCS_SAM_GO_REMOTE, nCuePtr)
              bResult = #True
            EndIf
          EndIf ; EndIf \bCueCurrentlyEnabled
        EndWith
      EndIf
    EndIf
  EndIf
  If bIgnoreInputMsg = #False
    If (bResult = #False) And (sThisCue)
      gsProcessNetworkCommandError = LangPars("Errors", "CueNotFound", sThisCue)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure processNetworkGoToTopCommand()
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  
  debugMsg(sProcName, #SCS_START)
  
  CompilerIf #c_use_sam_for_network_cue_control
    samAddRequest(#SCS_SAM_GOTO_SPECIAL, #SCS_GOTO_TOP)
  CompilerElse
    debugMsg(sProcName, "calling PostEvent(#SCS_Event_GoTo_Top_Cue, #WMN, 0)")
    PostEvent(#SCS_Event_GoTo_Top_Cue, #WMN, 0)
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkGoToNextCommand()
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  
  debugMsg(sProcName, #SCS_START)
  
  CompilerIf #c_use_sam_for_network_cue_control
    samAddRequest(#SCS_SAM_GOTO_SPECIAL, #SCS_GOTO_NEXT)
  CompilerElse
    debugMsg(sProcName, "calling PostEvent(#SCS_Event_GoTo_Next_Cue, #WMN, 0)")
    PostEvent(#SCS_Event_GoTo_Next_Cue, #WMN, 0)
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkGoBackCommand()
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  
  debugMsg(sProcName, #SCS_START)
  
  CompilerIf #c_use_sam_for_network_cue_control
    samAddRequest(#SCS_SAM_GOTO_SPECIAL, #SCS_GOTO_PREV)
  CompilerElse
    debugMsg(sProcName, "calling PostEvent(#SCS_Event_GoTo_Prev_Cue, #WMN, 0)")
    PostEvent(#SCS_Event_GoTo_Prev_Cue, #WMN, 0)
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkGoToEndCommand()
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  
  debugMsg(sProcName, #SCS_START)
  
  CompilerIf #c_use_sam_for_network_cue_control
    samAddRequest(#SCS_SAM_GOTO_SPECIAL, #SCS_GOTO_END)
  CompilerElse
    debugMsg(sProcName, "calling PostEvent(#SCS_Event_GoTo_End_Cue, #WMN, 0)")
    PostEvent(#SCS_Event_GoTo_End_Cue, #WMN, 0)
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkGoToCueCommand(sNetworkCue.s)
  PROCNAMEC()
  Protected nCuePtr
  ; note: all significant processing is passed to the main thread by SAM requests
  
  debugMsg(sProcName, #SCS_START + ", sNetworkCue=" + sNetworkCue)
  
  nCuePtr = getCuePtr(sNetworkCue)
  If nCuePtr >= 0
    samAddRequest(#SCS_SAM_GOTO_CUE, nCuePtr)
  Else
    debugMsg(sProcName, "getCuePtr(" + #DQUOTE$ + sNetworkCue + #DQUOTE$ + ") returned " + nCuePtr)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkFireNextCommand()
  PROCNAMEC()
  ; note: significant processing is performed in processNetworkGoCommand(), which passes processing to the main thread by SAM requests
  Protected i, nLastPlayingCue, nNextCue, bResult = #True
  Protected sCue.s
  
  debugMsg(sProcName, #SCS_START)
  
  nLastPlayingCue = -1
  For i = 1 To gnLastCue
    If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
      nLastPlayingCue = i
    EndIf
  Next i
  If nLastPlayingCue >= 0
    nNextCue = nLastPlayingCue + 1
    If nNextCue <= gnLastCue
      With aCue(nNextCue)
        While (\bCueCurrentlyEnabled = #False) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False) And (\nActivationMethod <> #SCS_ACMETH_TIME)
          ; skip over disabled cues, hotkey cues, external activated cues, and time-based-cues
          nNextCue + 1
          If nNextCue > gnLastCue
            Break
          EndIf
        Wend
      EndWith
    EndIf
    If nNextCue <= gnLastCue
      sCue = aCue(nNextCue)\sCue
      debugMsg(sProcName, "calling processNetworkGoCommand('" + sCue + "')")
      bResult = processNetworkGoCommand(sCue)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure processNetworkStopCommand(sNetworkCue.s)
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  Protected i
  
  debugMsg(sProcName, #SCS_START + ", sNetworkCue=" + sNetworkCue)
  
  For i = 1 To gnLastCue
    If LCase(aCue(i)\sCue) = LCase(sNetworkCue)
      samAddRequest(#SCS_SAM_STOP_CUE, i, 0, #True, "ALL")  ; requests stopCue(i, "ALL", #True)
      Break
    EndIf
  Next i
  
EndProcedure

Procedure processNetworkStopAllCommand()
  PROCNAMEC()
  ; nb not necessary to pass this to SAM as stopEverything() has built-in thread test
  
  ; debugMsg(sProcName, "calling stopEverythingPart1()")
  ; stopEverythingPart1()
  debugMsg(sProcName, "calling processStopAll()") ; Changed 19May2025 11.10.8ba2
  processStopAll()
  
EndProcedure

Procedure processNetworkFadeAllCommand()
  PROCNAMEC()
  ; nb not necessary to pass this to SAM as processFadeAll() calls stopEverything() which has built-in thread test
  
  debugMsg(sProcName, "calling processFadeAll()")
  processFadeAll()
  
EndProcedure

Procedure processNetworkPauseResumeAllCommand()
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  
  debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_PAUSE_RESUME_ALL)")
  samAddRequest(#SCS_SAM_PAUSE_RESUME_ALL)
  
EndProcedure

Procedure processNetworkStopMTCCommand()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling stopMTC()")
  stopMTC()
  
EndProcedure

Procedure processNetworkPauseCueCommand(sNetworkCue.s)
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  Protected i
  
  debugMsg(sProcName, #SCS_START + ", sNetworkCue=" + sNetworkCue)
  
  For i = 1 To gnLastCue
    If LCase(aCue(i)\sCue) = LCase(sNetworkCue)
      samAddRequest(#SCS_SAM_PAUSE_RESUME_CUE, i, 0, #SCS_MM_PAUSE)
      Break
    EndIf
  Next i
  
EndProcedure

Procedure processNetworkResumeCueCommand(sNetworkCue.s)
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  Protected i
  
  debugMsg(sProcName, #SCS_START + ", sNetworkCue=" + sNetworkCue)
  
  For i = 1 To gnLastCue
    If LCase(aCue(i)\sCue) = LCase(sNetworkCue)
;       debugMsg(sProcName, "calling resumeCue(" + getCueLabel(i) + ")")
;       resumeCue(i)
      samAddRequest(#SCS_SAM_PAUSE_RESUME_CUE, i, 0, #SCS_MM_RESUME)
      Break
    EndIf
  Next i
  
EndProcedure

Procedure processNetworkPauseResumeCommand(sNetworkCue.s)
  PROCNAMEC()
  ; note: all significant processing is passed to the main thread by SAM requests
  Protected i
  
  debugMsg(sProcName, #SCS_START + ", sNetworkCue=" + sNetworkCue)
  
  For i = 1 To gnLastCue
    If LCase(aCue(i)\sCue) = LCase(sNetworkCue)
;       debugMsg(sProcName, "calling PauseOrResumeCue(" + getCueLabel(i) + ")")
;       PauseOrResumeCue(i)
      samAddRequest(#SCS_SAM_PAUSE_RESUME_CUE, i, 0, #SCS_MM_PAUSE_OR_RESUME)
      Break
    EndIf
  Next i
  
EndProcedure

Procedure processNetworkPollRequest()
  PROCNAMEC()
  Protected sPollResponse.s
  
  sPollResponse = "scspr 1 " + FormatDate("%hh:%ii:%ss", Date())
  debugMsg(sProcName, "sPollResponse=" + sPollResponse)
  SendNetworkStringAscii(gnEventClient, sPollResponse)
  debugMsg(sProcName, "sent '" + sPollResponse + "'")
  
EndProcedure

Procedure doNetworkIn_Proc()
  PROCNAMEC()
  Protected n, nQuotePtr1, nQuotePtr2, nCountNotDone, nCRPtr
  Protected sWork.s
  Protected qTimeNow.q
  Protected bClearLog
  Protected nExpIndex
  Protected rCueCtrlData.tyCueCtrlData
  Protected rCueCtrlDataDef.tyCueCtrlData
  Protected bUnpackOSCResult
  Protected sDevType.s
  Protected bResult = #True
  Static sNetworkIn.s, sRemoteApp.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sNetworkIn = decodeDevTypeL(#SCS_DEVTYPE_CC_NETWORK_IN)
    sRemoteApp = Lang("RAI", "RemoteApp")
    bStaticLoaded = #True
  EndIf
  
  If gbNetworkInLocked
    debugMsg(sProcName, "gbNetworkInLocked=" + strB(gbNetworkInLocked))
    ProcedureReturn
  EndIf
  
  For n = 0 To (gnNetworkInCount-1)
    debugMsg(sProcName, "n=" + n + ", gnNetworkInCount=" + gnNetworkInCount)
    
    rCueCtrlData = rCueCtrlDataDef  ; clear all fields in rCueCtrlData
    
    With rCueCtrlData
      
      If gaNetworkIns(n)\bReady
        If gaNetworkIns(n)\bRAI
          sDevType = sRemoteApp
        Else
          sDevType = sNetworkIn
        EndIf
        \sMessage = gaNetworkIns(n)\sMessage
        \txt = \sMessage + ": "
        If Left(\sMessage, 1) <> "/"
          debugMsg(sProcName, "gaNetworkIns(" + n + ")\sMessage=" + gaNetworkIns(n)\sMessage)
          
          If gaNetworkIns(n)\bVMix ; vMix code added 20Sep2020
            If Left(\sMessage, 7) = "VERSION" ; unsolicited 'version' message sent by vMix on connection, eg "VERSION OK 23.0.0.62"
              \txt = \sMessage
            ElseIf Left(\sMessage, 8) = "FUNCTION"
              \txt = ""
            EndIf
            
          ElseIf (LCase(Left(\sMessage, 8)) = "scsgotop") Or (LCase(Left(\sMessage, 10)) = "scsgototop")
            \sAction = "GOTOTOP"
            \txt + "Go to Top"
            
          ElseIf LCase(Left(\sMessage, 7)) = "scsgo(" + #DQUOTE$
            If Len(\sMessage) > 9 ; length of scsgo("")
              sWork = Mid(\sMessage, 8)
              nExpIndex = FindString(sWork, "[exp ")
              If nExpIndex > 1
                \sCommand = Trim(Left(sWork, nExpIndex-1))
                \sExpString = Mid(sWork, nExpIndex)
              Else
                \sCommand = sWork
                \sExpString = ""
              EndIf
              nQuotePtr2 = FindString(\sCommand, #DQUOTE$)
              If nQuotePtr2 > 1
                \sAction = "GO"
                \sNetworkCue = Trim(Left(\sCommand, nQuotePtr2 - 1))
                If \sNetworkCue <> "0"
                  \txt + "Activate Cue " + \sNetworkCue
                Else
                  \txt + "GO"
                EndIf
              EndIf
              If nExpIndex > 1
                nQuotePtr1 = FindString(\sExpString, #DQUOTE$, 1)
                If nQuotePtr1 > 1
                  nQuotePtr2 = FindString(\sExpString, #DQUOTE$, nQuotePtr1+1)
                  If nQuotePtr2 > 1
                    \sExpectedCue = Mid(\sExpString, (nQuotePtr1 + 1), (nQuotePtr2 - nQuotePtr1 - 1))
                  EndIf
                EndIf
              EndIf
            EndIf
            
          ElseIf LCase(Left(\sMessage, 10)) = "scsstopall"
            \sAction = "STOPALL"
            \txt + "Stop All"
            
          ElseIf LCase(Left(\sMessage, 9)) = "scsstop(" + #DQUOTE$
            If Len(\sMessage) > 11 ; length of scsstop("")
              sWork = Mid(\sMessage, 10)
              nQuotePtr2 = FindString(sWork, #DQUOTE$)
              If nQuotePtr2 > 1
                \sAction = "STOP"
                \sNetworkCue = Left(sWork, nQuotePtr2 - 1)
                \txt + "Stop Cue " + \sNetworkCue
              EndIf
            EndIf
            
          ElseIf LCase(Left(\sMessage, 9)) = "scsgoto(" + #DQUOTE$
            ; Added 10Oct2022 11.9.6
            If Len(\sMessage) > 11 ; length of scsgoto("")
              sWork = Mid(\sMessage, 10)
              nQuotePtr2 = FindString(sWork, #DQUOTE$)
              If nQuotePtr2 > 1
                \sAction = "GOTO"
                \sNetworkCue = Left(sWork, nQuotePtr2 - 1)
                \txt + "Go To Cue " + \sNetworkCue
              EndIf
            EndIf
            
          ElseIf LCase(Left(\sMessage, 11)) = "scsgotonext"
            \sAction = "GOTONEXT"
            \txt + "Go to Next"
            
          ElseIf LCase(Left(\sMessage, 9)) = "scsgoback"
            \sAction = "GOBACK"
            \txt + "Go Back"
            
          ElseIf LCase(Left(\sMessage, 9)) = "scsgoconfirm"
            \sAction = "GOCONFIRM"
            \txt + "Go Confirm"
            
          ElseIf LCase(Left(\sMessage, 11)) = "scsfirenext"
            \sAction = "FIRENEXT"
            \txt + "Fire Next"
            
          ElseIf LCase(Left(\sMessage, 13)) = "scscheckfocus"
            ; 28/11/2013 (SCS 11.2.6a) added specifically for SCSTestController, which is run as a separate program on the same machine as SCS
            sWork = Trim(RemoveString(Mid(\sMessage, 14), "="))
            If sWork = "0"
              gbIgnoreLostFocus = #True
              \txt + "Ignore Lost Focus"
            ElseIf sWork = "1"
              gbIgnoreLostFocus = #False
              \txt + "Check Lost Focus"
            EndIf
            checkMainHasFocus(10)
            
          ElseIf LCase(Left(\sMessage, 7)) = "scspoll"
            ; 29/11/2013 (SCS 11.2.6a) added specifically for SCSTestController
            \sAction = "POLL"
            \txt = ""
            
          ElseIf LCase(Left(\sMessage, 11)) = "scsclearlog"
            ; 02/12/2013 (SCS 11.2.6b) added specifically for SCSTestController
            bClearLog = #True
            debugMsg(sProcName, "bClearLog=" + strB(bClearLog))
            \txt = ""
            
          ElseIf (Asc(Left(\sMessage,1)) < 32) Or (Asc(Left(\sMessage,1)) = 127)
            ; ignore messages like <ACK> as sent by PJ projectors
            
          Else
            \txt + Lang("CueCtrl", "Unknown")
            
          EndIf
          
        EndIf
        
        If gbMidiTestWindow = #False
          gbInExternalControl = #True
          If (\sAction = "GO") And (\sNetworkCue)
            debugMsg(sProcName, "calling processNetworkGoCommand('" + \sNetworkCue + "', '" + \sExpectedCue + "')")
            bResult = processNetworkGoCommand(\sNetworkCue, \sExpectedCue)
          ElseIf \sAction = "GOTOTOP"
            processNetworkGoToTopCommand()
          ElseIf (\sAction = "STOP") And (\sNetworkCue)
            processNetworkStopCommand(\sNetworkCue)
          ElseIf \sAction = "STOPALL"
            processNetworkStopAllCommand()
          ElseIf (\sAction = "GOTO") And (\sNetworkCue) ; Added 10Oct2022 11.9.6
            processNetworkGoToCueCommand(\sNetworkCue)  ; Added 10Oct2022 11.9.6
          ElseIf \sAction = "GOTONEXT"
debugMsg(sProcName, "calling processNetworkGoToNextCommand")
            processNetworkGoToNextCommand()
          ElseIf \sAction = "GOBACK"
            processNetworkGoBackCommand()
          ElseIf \sAction = "FIRENEXT"
            processNetworkFireNextCommand()
          ElseIf \sAction = "POLL"
            processNetworkPollRequest()
          EndIf
          gbInExternalControl = #False
        EndIf
        
        If bResult = #False
          \txt = gsProcessNetworkCommandError
        EndIf
        If \txt
          debugMsg(sProcName, "\txt=" + \txt)
        EndIf
        
        If \txt
          If gbMidiTestWindow
            nCRPtr = FindString(\sMessage, Chr($D), 1)
            If nCRPtr > 0
              \txt2 = \txt
              \txt = Left(\sMessage, nCRPtr - 1)
            EndIf
            AddGadgetItem(WMT\lstTestMidiInfo, -1, \txt)
            If \txt2
              AddGadgetItem(WMT\lstTestMidiInfo, -1, \txt2)
            EndIf
            ; scroll to last entry, so entry just added is visible
            SetGadgetState(WMT\lstTestMidiInfo,CountGadgetItems(WMT\lstTestMidiInfo)-1)
            SetGadgetState(WMT\lstTestMidiInfo,-1)
          Else
            If bResult
              WMN_setStatusField(RTrim(sDevType + ": " + \txt + "  " + \txt2))
            Else
              WMN_setStatusField(RTrim(sDevType + ": " + \txt + "  " + \txt2), #SCS_STATUS_WARN)
            EndIf
          EndIf
        EndIf
        
        gaNetworkIns(n)\bDone = #True
        gaNetworkIns(n)\bReady = #False
        
      Else  ; gaNetworkIns(n)\bReady = #False
        qTimeNow = ElapsedMilliseconds()
        If (qTimeNow - gaNetworkIns(n)\qTimeIn) > 1000
          ; discard message if CR not received within 1 second
          debugMsg(sProcName, "discarding " + gaNetworkIns(n)\sMessage)
          gaNetworkIns(n)\bDone = #True
        EndIf
        
      EndIf ; EndIf gaNetworkIns(n)\bReady
      
    EndWith
  Next n
  
  If gbNetworkInLocked
    ProcedureReturn
  EndIf
  
  nCountNotDone = 0
  For n = 0 To gnNetworkInCount - 1
    If gaNetworkIns(n)\bDone = #False
      nCountNotDone + 1
    EndIf
  Next n
  If nCountNotDone = 0
    gnNetworkInCount = 0
  EndIf
  
  ; 02/12/2013 (SCS 11.2.6b) added specifically for SCSTestController
  If bClearLog
    debugMsg(sProcName, "calling closeLogFile(#False)")
    closeLogFile(#False)
    openLogFile()
    debugMsg(sProcName, "Network 'scsClearLog' request processed")
  EndIf
  
EndProcedure

Procedure processNetworkInput_NonOSC(InBuff.s, nNetworkControlPtr=-1)
  PROCNAMEC()
  Protected sBuff.s, sBuffNoCrLf.s, sBuffWork.s, sBuffPart.s
  Protected bThisPartReady
  Protected n, nSCSPtr, nEOMPtr
  Protected sComparisonMsg.s, sReplyMsg.s
  Protected bInputProcessed
  Protected nDevNo
  Protected bRAI, bPJLink, bPJNet, bVMix
  Static bAuthWarningDisplayed
  Protected sMsg.s
  Protected sHexString.s, sPassword.s, sEncryptedPassword.s, sFirstCommand.s, nStringFormat
  Protected bFirstWaitingMsgSent
  Static sNetworkIn.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", InBuff=" + stringToNetworkString(InBuff) + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  If bStaticLoaded = #False
    sNetworkIn = decodeDevTypeL(#SCS_DEVTYPE_CC_NETWORK_IN)
    bStaticLoaded = #True
  EndIf
  
  If (nNetworkControlPtr >= 0) And (InBuff)
    nDevNo = gaNetworkControl(nNetworkControlPtr)\nDevNo
    bRAI = gaNetworkControl(nNetworkControlPtr)\bRAIDev
    If (bRAI = #False) And (nDevNo >= 0)
      Select grProd\aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev
        Case #SCS_CS_NETWORK_REM_PJLINK
          bPJLink = #True
        Case #SCS_CS_NETWORK_REM_PJNET
          bPJNet = #True
        Case #SCS_CS_NETWORK_REM_VMIX
          bVMix = #True
      EndSelect
    EndIf
    debugMsg(sProcName, "nDevNo=" + nDevNo + ", bRAI=" + strB(bRAI) + ", bPJLink=" + strB(bPJLink) + ", bPJNet=" + strB(bPJNet) + ", bVMix=" + strB(bVMix))
    If bPJLink Or bPJNet
      sBuff = InBuff
      sBuffNoCrLf = Trim(RemoveString(RemoveString(InBuff,#CR$),#LF$))  ; added following log from Brian O'Connor showing PJ-Net sending strings with <CR><LF> at the start
      
      If UCase(Left(sBuff, 8)) = "PJLINK 1"
        ; INFO PJLink authentication (security on)
        ; Added 10Apr2017 11.6.1af following Feature Request postings under the topic "PJLink Protocol for Projector Control"
        ; See https://pjlink.jbmia.or.jp/english/dl_class2.html
        ; or the document "PJLink_5-1.pdf" under "Documents\Manuals\PJLink"
        If Len(sBuff) >= 17
          sHexString = Mid(sBuff, 10, 8)
          If Len(gaNetworkControl(nNetworkControlPtr)\sCtrlNetworkRemoteDevPassword) = 0
            sPassword = sHexString + "JBMIAProjectorLink"
          Else
            sPassword = sHexString + gaNetworkControl(nNetworkControlPtr)\sCtrlNetworkRemoteDevPassword
          EndIf
          sEncryptedPassword = StringFingerprint(sPassword, #PB_Cipher_MD5, 256, #PB_Ascii) ; modified 31Aug2020 11.8.3.2as to add #PB_Ascii as the format, following emails from Marek Cihar
          debugMsg(sProcName, "sHexString=" + sHexString + ", sPassword=" + sPassword + ", sEncryptedPassword=" + sEncryptedPassword)
          If gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady > 0
            With gaNetworkControl(nNetworkControlPtr)\aSendWhenReady(0)
              sFirstCommand = \sSWRSendWhenReady
              nStringFormat = \nSWRStringFormat
              If Right(sFirstCommand,1) <> #CR$
                sFirstCommand + #CR$
              EndIf
            EndWith
            If gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady = 1
              gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady = 0
            Else
              bFirstWaitingMsgSent = #True
            EndIf
          Else
            sFirstCommand = "%1POWR ?" + #CR$
            nStringFormat = #PB_Ascii ; added 31Aug2020 11.8.3.2as
          EndIf
          sReplyMsg = sEncryptedPassword + sFirstCommand
          debugMsg(sProcName, "calling sendNetworkMessage(" + nNetworkControlPtr + ", sReplyMsg, #True, nStringFormat)")
          sendNetworkMessage(nNetworkControlPtr, sReplyMsg, #True, nStringFormat) ; nb must ignore ready state as this message may precede the incoming message that indicates 'ready'
          gaNetworkControl(nNetworkControlPtr)\bClientConnectionReady = #True
          If gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady > 0
            Delay(50)  ; pause for authentication to complete before sending waiting messages
            debugMsg(sProcName, "calling sendWaitingNetworkMsgs(" + nNetworkControlPtr + ", " + strB(bFirstWaitingMsgSent) + ")")
            sendWaitingNetworkMsgs(nNetworkControlPtr, bFirstWaitingMsgSent)
          EndIf
        EndIf
        bInputProcessed = #True
        
      ElseIf UCase(Left(sBuff, 6)) = "%1POWR"
        debugMsg(sProcName, "ignoring response to 'power ?' message as this is a dummy message included in the authentication procedure")
        bInputProcessed = #True
        
      ElseIf UCase(Left(sBuff, 8)) = "PJLINK 0"
        ; INFO PJLink no authentication (security off) - device now ready
        gaNetworkControl(nNetworkControlPtr)\bClientConnectionReady = #True
        If gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady > 0
          debugMsg(sProcName, "calling sendWaitingNetworkMsgs(" + nNetworkControlPtr + ")")
          sendWaitingNetworkMsgs(nNetworkControlPtr)
        EndIf
        bInputProcessed = #True
        
      ElseIf UCase(Left(sBuffNoCrLf, 8)) = "PASSWORD"
        sReplyMsg = Trim(gaNetworkControl(nNetworkControlPtr)\sCtrlNetworkRemoteDevPassword) + #CR$ + #LF$
        debugMsg(sProcName, "calling sendNetworkMessage(" + nNetworkControlPtr + ", sReplyMsg, #True)")
        sendNetworkMessage(nNetworkControlPtr, sReplyMsg, #True) ; nb must ignore ready state
        
      ElseIf UCase(Left(sBuffNoCrLf, 5)) = "HELLO"
        ; INFO PJNet(?) password accepted - device now ready
        gaNetworkControl(nNetworkControlPtr)\bClientConnectionReady = #True
        If gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady > 0
          debugMsg(sProcName, "calling sendWaitingNetworkMsgs(" + nNetworkControlPtr + ")")
          sendWaitingNetworkMsgs(nNetworkControlPtr)
        EndIf
        bInputProcessed = #True
        
      ElseIf UCase(Right(sBuffNoCrLf, 2)) = "OK"
        debugMsg(sProcName, "ignoring OK response from projector")
        ; OK response from the projector to a command sent by an SCS Control Send Cue - no further processing required
        bInputProcessed = #True
        
      EndIf
      
      If bInputProcessed
        sMsg = sNetworkIn + ": " + sBuffNoCrLf
        Debug sMsg
        WMN_setStatusField(sMsg)
      EndIf
      
    EndIf ; EndIf bPJLink Or bPJNet
    
    If bInputProcessed = #False
      sBuff = removeNoiseChars(InBuff, "|")
      ; debugMsg(sProcName, "sBuff=" + stringToNetworkString(sBuff))
      sComparisonMsg = makeComparisonMsg(sBuff)
      ; debugMsg(sProcName, "sComparisonMsg=" + sComparisonMsg + ", $" + stringToHexString(sComparisonMsg))
      If nDevNo >= 0
        With grProd\aCtrlSendLogicalDevs(nDevNo)
          For n = 0 To \nMaxMsgResponse
            If \aMsgResponse[n]\sComparisonMsg = sComparisonMsg
              Select \aMsgResponse[n]\nMsgAction
                Case #SCS_NETWORK_ACT_REPLY  ; #SCS_NETWORK_ACT_REPLY
                  sReplyMsg = \aMsgResponse[n]\sReplyMsg
                  debugMsg(sProcName, "MsgResponse found - sending " + sReplyMsg)
                  If \bReplyMsgAddCR
                    sReplyMsg + #CR$
                  EndIf
                  If \bReplyMsgAddLF
                    sReplyMsg + #LF$
                  EndIf
                  debugMsg(sProcName, "calling sendNetworkMessage(" + nNetworkControlPtr + ", sReplyMsg, #True)")
                  sendNetworkMessage(nNetworkControlPtr, sReplyMsg, #True) ; nb must ignore ready state as this message may precede the incoming message that indicates 'ready'
                  
                Case #SCS_NETWORK_ACT_READY  ; #SCS_NETWORK_ACT_READY
                  gaNetworkControl(nNetworkControlPtr)\bClientConnectionReady = #True
                  If gaNetworkControl(nNetworkControlPtr)\nCountSendWhenReady > 0
                    debugMsg(sProcName, "calling sendWaitingNetworkMsgs(" + nNetworkControlPtr + ")")
                    sendWaitingNetworkMsgs(nNetworkControlPtr)
                  EndIf
                  
              EndSelect
              bInputProcessed = #True
              Break
            EndIf
          Next n
        EndWith
      EndIf
    EndIf
    If bInputProcessed
      ; debugMsg(sProcName, "exiting because bInputProcessed=" + strB(bInputProcessed))
      ProcedureReturn
    EndIf
  EndIf
  
  sBuffWork = sBuff
  
  While sBuffWork
    
    nEOMPtr = FindString(sBuffWork, #CR$)
    ; debugMsg(sProcName, "nEOMPtr=" + nEOMPtr + ", sBuffWork=" + sBuffWork)
    If nEOMPtr > 0
      sBuffPart = Left(sBuffWork, nEOMPtr - 1)
      If nEOMPtr = Len(sBuffWork)
        sBuffWork = ""
      Else
        sBuffWork = Mid(sBuffWork, nEOMPtr + 1)
      EndIf
      bThisPartReady = #True
    Else
      sBuffPart = sBuffWork
      sBuffWork = ""
      bThisPartReady = #True
    EndIf
    
    ; debugMsg(sProcName, "sBuffPart=$" + stringToHexString(sBuffPart))
    
    If (gbReadingNetworkMessage = #False) Or (gnNetworkInCount = 0)
      gbReadingNetworkMessage = #True
      gbNetworkInLocked = #True
      n = gnNetworkInCount
      gnNetworkCurrentIndex = n
      With gaNetworkIns(gnNetworkCurrentIndex)
        \sMessage = LTrim(sBuffPart)
        \bReady = bThisPartReady
        \bDone = #False
        \qTimeIn = ElapsedMilliseconds()
        \bRAI = bRAI
        \bVMix = bVMix
        debugMsg(sProcName, "gnNetworkCurrentIndex=" + gnNetworkCurrentIndex + ", \sMessage=" + \sMessage)
      EndWith
      gnNetworkInCount = n + 1
      gbNetworkInLocked = #False
      debugMsg(sProcName, "gnNetworkInCount=" + gnNetworkInCount)
    Else
      With gaNetworkIns(gnNetworkCurrentIndex)
        \sMessage = \sMessage + sBuffPart
        \bReady = bThisPartReady
        debugMsg(sProcName, "gnNetworkCurrentIndex=" + gnNetworkCurrentIndex + ", \sMessage=" + \sMessage)
      EndWith
    EndIf
    
    If bThisPartReady
      With gaNetworkIns(gnNetworkCurrentIndex)
        nSCSPtr = FindString(LCase(\sMessage), "scs")
        If nSCSPtr > 1
          \sMessage = Mid(\sMessage, nSCSPtr)
        EndIf
      EndWith
      gbReadingNetworkMessage = #False
    Else
      gbReadingNetworkMessage = #True
    EndIf
    
  Wend
  
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
  If gnNetworkInCount > 0
    doNetworkIn_Proc()
  EndIf
  
EndProcedure

Procedure processNetworkReceiveBuffer(nNetworkControlPtr, nCueNetworkRemoteDev, bHideTracing=#False)
  ; bHideTracing used in debugMsgN()
  PROCNAMEC()
  Protected sBuff.s
  Protected bUnpackOSCResult
  Protected bSupportOSCTextMsgs
  Protected n, nLFCount
  Protected nThisStartPos, nThisEndPos
  Protected nByteOffset, sIgnoredBytes.s
  Protected bOSCMessage
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(nCueNetworkRemoteDev) + ", gnNetworkBytesReceived=" + gnNetworkBytesReceived + ", bHideTracing=" + strB(bHideTracing))
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If gnNetworkBytesReceived > 0
;         ; Added 3Apr2020 11.8.2.3al following bug report from Jörg Deitz
;         ; Reset, if necessary, *gmNetworkReceiveBuffer and gnNetworkBytesReceived to ignore leading nulls, FS, etc, as received from Sound2Light
;         For n = 0 To 3
;           If PeekB(*gmNetworkReceiveBuffer + n) >= 32 ; ASCII 32 = space, which is the first visible character
;             Break
;           EndIf
;           nByteOffset + 1
;           sIgnoredBytes + bufferToAsciiString(*gmNetworkReceiveBuffer + n, 1)
;         Next n
        ; debugMsg(sProcName, bufferToHexString(*gmNetworkReceiveBuffer, gnNetworkBytesReceived, " "))
        If PeekA(*gmNetworkReceiveBuffer) = 0 And PeekA(*gmNetworkReceiveBuffer + 1) = 0 And PeekA(*gmNetworkReceiveBuffer + 4) = Asc("/")
          ; looks like an OSC 1.0 message, so remove this length int32 at the start before further processing
          nByteOffset = 4
          bOSCMessage = #True
        EndIf
        If nByteOffset > 0
;           debugMsgN(sProcName, "removing first " + nByteOffset + " bytes from *gmNetworkReceiveBuffer: " + sIgnoredBytes)
          debugMsgN(sProcName, "removing first " + nByteOffset + " bytes from *gmNetworkReceiveBuffer")
          gnNetworkBytesReceived - nByteOffset
          If gnNetworkBytesReceived > 0
            ; Note: The PB command MoveMemory() handles source and destination memory areas overlapping
            MoveMemory(*gmNetworkReceiveBuffer+nByteOffset, *gmNetworkReceiveBuffer, gnNetworkBytesReceived)
          Else
            ; nothing left to process
            ProcedureReturn
          EndIf
        EndIf
;         ; End added 3Apr2020 11.8.2.3al
        If PeekA(*gmNetworkReceiveBuffer) = Asc("/")
          If \bRAIDev And grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And nNetworkControlPtr = grRAI\nNetworkControlPtr1
            debugMsgN(sProcName, "calling unpackOSCMsg(" + nNetworkControlPtr + ", #False, " + strB(bHideTracing) + ")")
            bUnpackOSCResult = unpackOSCMsg(nNetworkControlPtr, #False, bHideTracing)
            If bUnpackOSCResult
              debugMsgN(sProcName, "calling processNetworkInput_OSC(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
              processNetworkInput_OSC(nNetworkControlPtr, bHideTracing)
            EndIf
          Else
            ; debugMsgN(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev))
            Select nCueNetworkRemoteDev
              Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
                debugMsgN(sProcName, "calling unpackOSCMsg(" + nNetworkControlPtr + ", #False, " + strB(bHideTracing) + ")")
                bUnpackOSCResult = unpackOSCMsg(nNetworkControlPtr, #False, bHideTracing)
                If bUnpackOSCResult
                  debugMsgN(sProcName, "calling processNetworkInput_X32(" + nNetworkControlPtr + ")")
                  processNetworkInput_X32(nNetworkControlPtr)
                EndIf
                
              Default ; not X32
                If bOSCMessage = #False
                  For n = 0 To (gnNetworkBytesReceived-1)
                    If PeekA(*gmNetworkReceiveBuffer + n) = #LF
                      nLFCount + 1
                      ; debugMsg(sProcName, "LF at position " + Str(n+1))
                    EndIf
                  Next n
                  ; debugMsg(sProcName, "nLFCount=" + nLFCount)
                  If nLFCount = 0
                    If \bRAIDev And grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE
                      PokeA(*gmNetworkReceiveBuffer + gnNetworkBytesReceived, #LF)
                      gnNetworkBytesReceived + 1
                      nLFCount + 1
                    EndIf
                  EndIf
                  nThisStartPos = 0
                  For n = 0 To (gnNetworkBytesReceived-1)
                    If PeekA(*gmNetworkReceiveBuffer + n) = #LF
                      nThisEndPos = n
                      If nThisEndPos > nThisStartPos
                        ; not a blank message
                        debugMsgN(sProcName, "calling unpackOSCMsg(" + nNetworkControlPtr + ", #True, " + strB(bHideTracing) + ", " + nThisStartPos + ", " + nThisEndPos + ")")
                        bUnpackOSCResult = unpackOSCMsg(nNetworkControlPtr, #True, bHideTracing, nThisStartPos, nThisEndPos)
                        If bUnpackOSCResult
                          debugMsgN(sProcName, "calling processNetworkInput_OSC(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
                          processNetworkInput_OSC(nNetworkControlPtr, bHideTracing)
                        EndIf
                      EndIf
                      nThisStartPos = nThisEndPos + 1
                    EndIf
                  Next n
                EndIf ; EndIf bOSCMessage = #False
                nThisEndPos = gnNetworkBytesReceived - 1
                If nThisEndPos > nThisStartPos
                  ; not a blank message
                  debugMsgN(sProcName, "calling unpackOSCMsg(" + nNetworkControlPtr + ", #True, " + strB(bHideTracing) + ", " + nThisStartPos + ", " + nThisEndPos + ")")
                  bUnpackOSCResult = unpackOSCMsg(nNetworkControlPtr, #True, bHideTracing, nThisStartPos, nThisEndPos)
                  If bUnpackOSCResult
                    debugMsgN(sProcName, "calling processNetworkInput_OSC(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
                    processNetworkInput_OSC(nNetworkControlPtr, bHideTracing)
                  EndIf
                EndIf
                nThisStartPos = nThisEndPos + 1
            EndSelect
          EndIf
        Else
          If \bRAIDev = #False
            sBuff = PeekS(*gmNetworkReceiveBuffer, gnNetworkBytesReceived, #PB_UTF8)
            debugMsgN(sProcName, "gnNetworkBytesReceived=" + gnNetworkBytesReceived + ", UTF8: " + bufferToUTF8String(*gmNetworkReceiveBuffer, gnNetworkBytesReceived) + ", HEX: " + bufferToHexString(*gmNetworkReceiveBuffer, gnNetworkBytesReceived, " "))
            processNetworkInput_NonOSC(sBuff, nNetworkControlPtr)
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure processNetworkInput_X32(nNetworkControlPtr)
  PROCNAMEC()
  Protected sPath.s
  Protected sButtonNo.s, nButtonNo
  Protected n, nCmdNo = -1
  Protected sCmdDescr.s
  Protected sOSCText.s
  Protected nStringIndex=-1, nLongIndex=-1, nFloatIndex=-1
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      sPath = \sOSCPath
      If Left(sPath,15) = "/-stat/userpar/"
        If \nOSCLong(0) > 0
          sButtonNo = StringField(sPath, 4, "/")
          debugMsg(sProcName, "sButtonNo=" + sButtonNo)
          If IsInteger(sButtonNo)
            nButtonNo = Val(sButtonNo)
            debugMsg(sProcName, "X32 Button " + nButtonNo + " pressed")
            If (nButtonNo > 0) And (nButtonNo < 25)
              For n = 0 To #SCS_MAX_X32_COMMAND
                If grX32CueControl\aX32Command[n]\nX32Button = nButtonNo
                  nCmdNo = n
                  Break
                EndIf
              Next n
;               Select nCmdNo
;                 Case #SCS_X32_GO_BUTTON
;                   sCmdDescr = Lang("Remote", "GoButton") ; "'Go' Button"
;                 Case #SCS_X32_STOP_ALL
;                   sCmdDescr = "Stop Everything"
;                 Case #SCS_X32_PAUSE_RESUME_ALL
;                   sCmdDescr = "Pause/Resume All"
;                 Case #SCS_X32_GO_TO_TOP
;                   sCmdDescr = "Go To Top"
;                 Case #SCS_X32_GO_BACK
;                   sCmdDescr = "Go Back"
;                 Case #SCS_X32_GO_TO_NEXT
;                   sCmdDescr = "Go To Next"
;                 Case #SCS_X32_TAP_DELAY
;                   sCmdDescr = "Tap Delay"
; ;                 Case #SCS_X32_PAGE_UP
; ;                   sCmdDescr = "Page Up"
; ;                 Case #SCS_X32_PAGE_DOWN
; ;                   sCmdDescr = "Page Down"
; ;                 Case #SCS_X32_MASTER_FADER
; ;                   sCmdDescr = "Master Fader"
; ;                 Case #SCS_X32_GO_CONFIRM
; ;                   sCmdDescr = "Go Confirm"
;               EndSelect
              sCmdDescr = X32CmdDescrForCmdNo(nCmdNo)
            EndIf
          EndIf
        EndIf
      EndIf
      If (sCmdDescr) Or (gbMidiTestWindow)
        sOSCText = sPath
        If \sOSCTagTypes
          sOSCText + " ," + \sOSCTagTypes
          For n = 1 To Len(\sOSCTagTypes)
            Select Mid(\sOSCTagTypes,n,1)
              Case "s"
                nStringIndex + 1
                sOSCText + " " + \sOSCString(nStringIndex)
              Case "i"
                nLongIndex + 1
                sOSCText + " " + \nOSCLong(nLongIndex)
              Case "f"
                nFloatIndex + 1
                sOSCText + " " + StrF(\fOSCFloat(nFloatIndex))
            EndSelect
          Next n
        EndIf
        If sCmdDescr
          sOSCText + ": " + sCmdDescr
        EndIf
        
        If gbMidiTestWindow
          WMT_addMiscListItem(sOSCText)
        Else
          Select nCmdNo
            Case #SCS_X32_GO_BUTTON
              processNetworkGoButtonCommand()
              
            Case #SCS_X32_STOP_ALL
              processNetworkStopAllCommand()
              
            Case #SCS_X32_FADE_ALL
              processNetworkFadeAllCommand()
              
            Case #SCS_X32_PAUSE_RESUME_ALL
              processNetworkPauseResumeAllCommand()
              
            Case #SCS_X32_GO_TO_TOP
              processNetworkGoToTopCommand()
              
            Case #SCS_X32_GO_BACK
              processNetworkGoBackCommand()
              
            Case #SCS_X32_GO_TO_NEXT
              ; debugMsg(sProcName, "calling processNetworkGoToNextCommand")
              processNetworkGoToNextCommand()
              
            Case #SCS_X32_TAP_DELAY
              DMX_processTapDelayShortcutOrCommand()
              
;             Case #SCS_X32_PAGE_UP
;             Case #SCS_X32_PAGE_DOWN
;             Case #SCS_X32_MASTER_FADER
;             Case #SCS_X32_GO_CONFIRM
          EndSelect
          WMN_setStatusField(RTrim(" Network IN  " + sOSCText))
        EndIf
      EndIf
      
    EndWith
  EndIf
  
EndProcedure

Procedure processOSCStatusRequest(nNetworkControlPtr, bHideTracing=#False)
  PROCNAMEC()
  Protected i, nCueState
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_RAI_REQUEST, nNetworkControlPtr, 0, #SCS_OSCINP_STATUS, "", 0, 0, -1, #True, #True)
    PostEvent(#SCS_Event_WakeUp, #WMN, 0) ; wake up main thread's WaitWindowEvent()
    ProcedureReturn
  EndIf
  
  If nNetworkControlPtr >= 0
    
    For i = 1 To gnLastCue
      nCueState = aCue(i)\nCueState
      If (nCueState >= #SCS_CUE_FADING_IN) And (nCueState <= #SCS_CUE_FADING_OUT)
        grRAI\nStatus | #SCS_RAI_STATUS_PLAYING
        Break
      EndIf
    Next i
    
    With gaNetworkControl(nNetworkControlPtr)
      \sOSCTagTypes = "i"
      \nOSCLongCount = 1
      \nOSCLong(0) = grRAI\nStatus
      populateOSCMessageDataIfReqd(nNetworkControlPtr)
      sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
    EndWith
    
    grRAI\nStatus = 0   ; need to clear RAI status after sending the current status, so status always contains flags set since the last /status request
    
  EndIf
  
EndProcedure

Procedure sendOSCStatus(bHideTracing=#False)
  PROCNAMEC()
  ; nb deliberately handles only status values < 8, ie values 1, 2 and 4
  Protected nMyStatus, nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nNetworkControlPtr = getNetworkControlPtrForRAI()
  If nNetworkControlPtr >= 0
    nMyStatus = grRAI\nStatus & 7
    If nMyStatus <> 0
      With gaNetworkControl(nNetworkControlPtr)
        \bOSCTextMsg = #True
        \bAddLF = #True
        \sOSCPathOriginal = "/_status"
        \sOSCPath = "/status"
        \sOSCTagTypes = "i"
        \nOSCLongCount = 1
        \nOSCLong(0) = nMyStatus
        populateOSCMessageDataIfReqd(nNetworkControlPtr)
        sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
      EndWith
      grRAI\nStatus ! nMyStatus ; clear nMyStatus flags from grRAI\nStatus
    EndIf
  EndIf
  
EndProcedure

Procedure processOSCBeatRequest(nNetworkControlPtr, bHideTracing=#False)
  PROCNAMEC()
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      \sOSCTagTypes = ""
      sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
    EndWith
  EndIf
  
EndProcedure

Procedure.s getCueLabelForRAICueNumber(nNumber)
  PROCNAMEC()
  Protected sCue.s
  Protected i, nCueCount
  Protected nActivationMethod
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueEnabled
      nActivationMethod = aCue(i)\nActivationMethod
      If (nActivationMethod & #SCS_ACMETH_HK_BIT) Or (nActivationMethod & #SCS_ACMETH_EXT_BIT)
        ; ignore hotkey and external control cues
      Else
        nCueCount + 1
        If nCueCount = nNumber
          sCue = aCue(i)\sCue
          Break
        EndIf
      EndIf
    EndIf
  Next i
  
  ProcedureReturn sCue
EndProcedure

Procedure processOSCInfoRequest(nNetworkControlPtr, nCmd, nNumber, sPath.s)
  PROCNAMEC()
  Protected nSCSVersion
  Protected i, nCueCount, nHKeyCount
  Protected nCurrCueNumber = -1, nNextCueNumber = -1
  Protected nCueNumber = -1, nCuePtr = -1, nSubPtr = -1
  Protected nHKeyNumber = -1, nHKeyCuePtr = -1, sHKeyType.s
  Protected nActivationMethod
     Protected nMaxTagIndex, nTagIndex, nStringIndex, nLongindex, nFloatIndex
  Protected bHideTracing
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCmd=" + nCmd + ", nNumber=" + nNumber + ", sPath=" + sPath)
  
  If #cTraceNetworkMsgs = #False
    bHideTracing = #True
  EndIf
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      
      If gnThreadNo > #SCS_THREAD_MAIN
        samAddRequest(#SCS_SAM_RAI_REQUEST, nNetworkControlPtr, 0, nCmd, sPath, 0, nNumber, -1, #True, #True)
        ProcedureReturn
      EndIf
      
      If nCmd = #SCS_OSCINP_INFO_SCS_VERSION
        ; convert SCS Version to 6-digit integer, eg 11.5.1 -> 110501
        nSCSVersion = Val(StringField(#SCS_VERSION,1,".")) * 10000
        nSCSVersion + Val(StringField(#SCS_VERSION,2,".")) * 100
        nSCSVersion + Val(StringField(#SCS_VERSION,3,"."))
        \sOSCTagTypes = "ii"
        \nOSCLongCount = 2
        ReDim \nOSCLong(\nOSCLongCount-1)
        \nOSCLong(0) = nSCSVersion
        \nOSCLong(1) = grLicInfo\nLicLevel
        debugMsg(sProcName, "nCmd=#SCS_OSCINP_INFO_SCS_VERSION, nSCSVersion=" + nSCSVersion)
        
      ElseIf nCmd = #SCS_OSCINP_INFO_GET_COLORS
        \sOSCTagTypes = "ss"
        \nOSCStringCount = 2
        ReDim \sOSCString(\nOSCStringCount-1)
        \sOSCString(0) = decodeColorItemIndex(nNumber)
        \sOSCString(1) = "#" + hex6(colorCodeToRRGGBB(getBackColorFromColorScheme(nNumber))) + ", #" + hex6(colorCodeToRRGGBB(getTextColorFromColorScheme(nNumber)))
        
      Else
        \sOSCPathOriginal = sPath
        Select nCmd
          Case #SCS_OSCINP_INFO_GET_CUE
            nCueNumber = nNumber
          Case #SCS_OSCINP_INFO_GET_HKEY
            nHKeyNumber = nNumber
        EndSelect
        ; count enabled cues and set relevant pointers
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            nActivationMethod = aCue(i)\nActivationMethod
            If nActivationMethod & #SCS_ACMETH_HK_BIT
              nHKeyCount + 1
              If nHKeyCount = nHKeyNumber
                nHKeyCuePtr = i
              EndIf
            ElseIf nActivationMethod & #SCS_ACMETH_EXT_BIT
              ; ignore external control cues
            Else
              nCueCount + 1
              If nCueCount = nCueNumber
                nCuePtr = i
                nSubPtr = aCue(i)\nFirstSubIndex
              EndIf
              If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
                nCurrCueNumber = nCueCount
              EndIf
              If i = gnCueToGo
                nNextCueNumber = nCueCount
              EndIf
            EndIf
          EndIf
        Next i
        debugMsgN(sProcName, "nCueCount=" + nCueCount + ", nCurrCueNumber=" + nCurrCueNumber + ", nNextCueNumber=" + nNextCueNumber + ", nCuePtr=" + getCueLabel(nCuePtr) +
                             ", nSubPtr=" + getSubLabel(nSubPtr) + ", nHKeyCount=" + nHKeyCount+ ", nHKeyCuePtr=" + getCueLabel(nHKeyCuePtr))
        If nCurrCueNumber < 0
          nCurrCueNumber = nNextCueNumber
        EndIf
        Select nCmd
          Case #SCS_OSCINP_INFO_FINAL_CUE
            \sOSCTagTypes = "i"
            \nOSCLongCount = 1
            \nOSCLong(0) = nCueCount
            
          Case #SCS_OSCINP_INFO_CURR_CUE
            \sOSCTagTypes = "i"
            \nOSCLongCount = 1
            \nOSCLong(0) = nCurrCueNumber
            
          Case #SCS_OSCINP_INFO_NEXT_CUE
            \sOSCTagTypes = "i"
            \nOSCLongCount = 1
            \nOSCLong(0) = nNextCueNumber
            
          Case #SCS_OSCINP_INFO_GET_CUE
            If nCuePtr >= 0
              \sOSCTagTypes = "is"
              \nOSCLongCount = 1
              \nOSCStringCount = 1
              \nOSCLong(0) = nCueNumber
              \sOSCString(0) = aCue(nCuePtr)\sCue
            EndIf
            
          Case #SCS_OSCINP_INFO_HKEY_COUNT
            \sOSCTagTypes = "i"
            \nOSCLongCount = 1
            \nOSCLong(0) = nHKeyCount
            
          Case #SCS_OSCINP_INFO_GET_HKEY
            If nHKeyCuePtr >= 0
              \sOSCTagTypes = "issss"
              \nOSCLongCount = 1
              \nOSCStringCount = 4
              ReDim \sOSCString(\nOSCStringCount-1)
              \nOSCLong(0) = nHKeyNumber
              \sOSCString(0) = aCue(nHKeyCuePtr)\sCue
              \sOSCString(1) = aCue(nHKeyCuePtr)\sHotkey
              Select aCue(nHKeyCuePtr)\nActivationMethod
                Case #SCS_ACMETH_HK_TRIGGER
                  sHKeyType = "trigger"
                Case #SCS_ACMETH_HK_TOGGLE
                  sHKeyType = "toggle"
                Case #SCS_ACMETH_HK_NOTE
                  sHKeyType = "note"
                Case #SCS_ACMETH_HK_STEP
                  sHKeyType = "step"
              EndSelect
              \sOSCString(2) = sHKeyType
              \sOSCString(3) = aCue(nHKeyCuePtr)\sHotkeyLabel
            EndIf
            
          Case #SCS_OSCINP_INFO_PRODUCT
            ; Added for X32TC
            debugMsgN(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\sOSCPath=" + \sOSCPath)
            \sOSCTagTypes = "s"
            \nOSCStringCount = 1
            \sOSCString(0) = decodeLicType(grLicInfo\sLicType, grLicInfo\dLicExpDate)
            debugMsgN(sProcName, "cmd=#SCS_OSCINP_INFO_PRODUCT, \sOSCString(0)=" + \sOSCString(0))
            
          Case #SCS_OSCINP_INFO_CUE_FILE
            ; Added for X32TC
            \sOSCTagTypes = "s"
            \nOSCStringCount = 1
            \sOSCString(0) = GetFilePart(gsCueFile, #PB_FileSystem_NoExtension)
            debugMsgN(sProcName, "cmd=#SCS_OSCINP_INFO_CUE_FILE, \sOSCString(0)=" + \sOSCString(0))
            
          Case #SCS_OSCINP_INFO_TITLE
            ; Same as #SCS_OSCINP_PROD_GET_TITLE but added for X32TC
            \sOSCTagTypes = "s"
            \nOSCStringCount = 1
            \sOSCString(0) = grProd\sTitle
            debugMsgN(sProcName, "cmd=#SCS_OSCINP_INFO_TITLE, \sOSCString(0)=" + \sOSCString(0))
            
        EndSelect
        
      EndIf
      
      debugMsg(sProcName, "calling populateOSCMessageDataIfReqd(" + nNetworkControlPtr + ")")
      populateOSCMessageDataIfReqd(nNetworkControlPtr)
      
      debugMsg(sProcName, "grRAI\bRAIClientActive=" + strB(grRAI\bRAIClientActive))
      
      If RAI_IsClientActive()
        If grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC
          debugMsg(sProcName, "grRAI\nNetworkControlPtr1=" + grRAI\nNetworkControlPtr1 + ", nNetworkControlPtr=" + nNetworkControlPtr)
          If grRAI\nNetworkControlPtr1 = nNetworkControlPtr
            grOSCMsgData = grOSCMsgDataDef
            grOSCMsgData\sOSCAddress = \sOSCPath
            grOSCMsgData\sTagString = \sOSCTagTypes
            grOSCMsgData\nTagCount = Len(\sOSCTagTypes)
            debugMsg(sProcName, "grOSCMsgData\sOSCAddress=" + grOSCMsgData\sOSCAddress + ", grOSCMsgData\sTagString=" + grOSCMsgData\sTagString)
            nMaxTagIndex = grOSCMsgData\nTagCount - 1
            For nTagIndex = 0 To nMaxTagIndex
              Select LCase(Mid(\sOSCTagTypes, (nTagIndex + 1), 1))
                Case "s"
                  grOSCMsgData\aTagData(nTagIndex)\sString = \sOSCString(nStringIndex)
                  nStringIndex + 1
                Case "i"
                  grOSCMsgData\aTagData(nTagIndex)\nInteger = \nOSCLong(nLongindex)
                  nLongindex + 1
                Case "f"
                  grOSCMsgData\aTagData(nTagIndex)\fFloat= \fOSCFloat(nFloatIndex)
                  nFloatIndex + 1
              EndSelect
            Next nTagIndex
          EndIf
        EndIf
      EndIf
      
      debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
      sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
      
    EndWith
      
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  debugMsgN(sProcName, #SCS_END)
  
EndProcedure

Procedure processOSCProdRequest(nNetworkControlPtr, nCmd)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCmd=" + nCmd)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      Select nCmd
        Case #SCS_OSCINP_PROD_GET_TITLE
          \sOSCTagTypes = "s"
          \nOSCStringCount = 1
          ; \sOSCString(0) = #DQUOTE$ + grProd\sTitle + #DQUOTE$
          \sOSCString(0) = grProd\sTitle
      EndSelect
    EndWith
    
    populateOSCMessageDataIfReqd(nNetworkControlPtr)
    
    debugMsg(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ")")
    sendOSCComplexMessage(nNetworkControlPtr)
    
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processOSCCueRequest(nNetworkControlPtr, nCmd, sCue.s, nNumber=0, bHideTracing=#False)
  PROCNAMEC()
  Protected nCuePtr = -1, nSubPtr = -1, nAudPtr
  Protected bMsgSent
  Protected nBackColor.l, nTextColor.l
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCmd=" + nCmd + ", sCue=" + sCue)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      
      nCuePtr = getCuePtr(sCue)
      If nCuePtr >= 0
        nSubPtr = aCue(nCuePtr)\nFirstSubIndex
        Select nCmd
          Case #SCS_OSCINP_CUE_GET_NAME
            \sOSCTagTypes = "ss"
            \nOSCStringCount = 2
            ReDim \sOSCString(1)
            \sOSCString(0) = sCue
            \sOSCString(1) = aCue(nCuePtr)\sCueDescr
            
          Case #SCS_OSCINP_CUE_GET_PAGE
            \sOSCTagTypes = "ss"
            \nOSCStringCount = 2
            ReDim \sOSCString(1)
            \sOSCString(0) = sCue
            \sOSCString(1) = aCue(nCuePtr)\sPageNo
            
          Case #SCS_OSCINP_CUE_GET_WHEN_REQD
            \sOSCTagTypes = "ss"
            \nOSCStringCount = 2
            ReDim \sOSCString(1)
            \sOSCString(0) = sCue
            \sOSCString(1) = aCue(nCuePtr)\sWhenReqd
            
          Case #SCS_OSCINP_CUE_GET_TYPE
            \sOSCTagTypes = "ss"
            \nOSCStringCount = 2
            ReDim \sOSCString(1)
            \sOSCString(0) = sCue
            If nSubPtr >= 0
              \sOSCString(1) = aSub(nSubPtr)\sSubType
            Else
              ; nb shouldn't get here except possibly for very old cue files, because even 'note' cues now have a sub-cue
              \sOSCString(1) = "N"
            EndIf
            
          Case #SCS_OSCINP_CUE_GET_LENGTH
            \sOSCTagTypes = "si"
            \nOSCStringCount = 1
            \nOSCLongCount = 1
            \sOSCString(0) = sCue
            \nOSCLong(0) = stringToTime(getLengthForGrid(nCuePtr), #True)
            ; Debug "getLengthForGrid(" + getCueLabel(nCuePtr) + ")=" + getLengthForGrid(nCuePtr)
            
          Case #SCS_OSCINP_CUE_GET_POS
            \sOSCTagTypes = "si"
            \nOSCStringCount = 1
            \nOSCLongCount = 1
            \sOSCString(0) = sCue
            If nSubPtr >= 0
              \nOSCLong(0) = aSub(nSubPtr)\nSubPosition
              If aSub(nSubPtr)\bSubTypeHasAuds
                nAudPtr = aSub(nSubPtr)\nCurrPlayIndex
                If nAudPtr < 0
                  nAudPtr = aSub(nSubPtr)\nFirstPlayIndex
                EndIf
                If nAudPtr >= 0
                  If aAud(nAudPtr)\bAudPlaceHolder = #False
                    \nOSCLong(0) = aAud(nAudPtr)\nCuePos
                  EndIf
                EndIf
              EndIf
            Else
              \nOSCLong(0) = 0
            EndIf
            ; debugMsgN(sProcName, "nSubPtr=" + getSubLabel(nSubPtr) + ", \nOSCLong(0)=" + \nOSCLong(0))
            
          Case #SCS_OSCINP_CUE_SET_POS
            samAddRequest(#SCS_SAM_REPOS_CUE, nCuePtr, 0, nNumber)
            
          Case #SCS_OSCINP_CUE_GET_STATE
            \sOSCTagTypes = "si"
            \nOSCStringCount = 1
            \nOSCLongCount = 1
            \sOSCString(0) = sCue
            ; \nOSCLong(0) = aCue(nCuePtr)\nRAICueState
            \nOSCLong(0) = getRAICueState(nCuePtr)
            
          Case #SCS_OSCINP_CUE_GET_COLORS
            \sOSCTagTypes = "ss"
            \nOSCStringCount = 2
            ReDim \sOSCString(\nOSCStringCount-1)
            \sOSCString(0) = sCue
            getCurrColorsForCue(nCuePtr, @nBackColor, @nTextColor)
            \sOSCString(1) = "#" + hex6(colorCodeToRRGGBB(nBackColor)) + ", #" + hex6(colorCodeToRRGGBB(nTextColor))
            
        EndSelect
        
        If nCmd > 1000
          populateOSCMessageDataIfReqd(nNetworkControlPtr)
          debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
          sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
          bMsgSent = #True
        EndIf
        
      EndIf
      
      If bMsgSent = #False
        sendErrToRemoteApp(nNetworkControlPtr, bHideTracing)
      EndIf
      
    EndWith
    
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processOSCCueGetItems(nNetworkControlPtr, nCmd, nCue, sCue.s, sItemCodes.s, bHideTracing=#False)
  PROCNAMEC()
  Protected nItemCount, n, sThisItemCode.s
  Protected nCuePtr = -1, nSubPtr = -1, nAudPtr
  Protected j, k
  Protected bPLRepeat, bContainsLoop
  Protected bMsgSent
  Protected nBackColor.l, nTextColor.l
  Protected sString.s, sMyCue.s
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCmd=" + nCmd + ", nCue=" + nCue + ", sCue=" + sCue + ", sItemCodes=" + sItemCodes)
  
  nItemCount = Len(sItemCodes)
  
  If (nNetworkControlPtr >= 0) And (nItemCount > 0)
    With gaNetworkControl(nNetworkControlPtr)
      If nCmd = #SCS_OSCINP_CUE_GET_ITEMS_N
        sMyCue = getCueLabelForRAICueNumber(nCue)
      Else
        sMyCue = sCue
      EndIf
      nCuePtr = getCuePtr(sMyCue)
      If nCuePtr >= 0
        nSubPtr = aCue(nCuePtr)\nFirstSubIndex
        ; set initial part of return message
        If nCmd = #SCS_OSCINP_CUE_GET_ITEMS_N
          \sOSCTagTypes = "is"
          ReDim \nOSCLong(0)
          \nOSCLong(0) = nCue
          \nOSCLongCount = 1
          ReDim \sOSCString(0)
          \sOSCString(0) = sItemCodes
          \nOSCStringCount = 1
        Else
          \sOSCTagTypes = "ss"
          ReDim \sOSCString(1)
          \sOSCString(0) = sCue
          \sOSCString(1) = sItemCodes
          \nOSCStringCount = 2
        EndIf
        ; now process each requested item code
        For n = 1 To Len(sItemCodes)
          sThisItemCode = Mid(sItemCodes, n, 1)
          Select sThisItemCode  ; listed below in alphabetical order
              
            Case "A"  ; Activation Method
              \sOSCTagTypes + "s"
              ReDim \sOSCString(\nOSCStringCount)
              \sOSCString(\nOSCStringCount) = decodeActivationMethod(aCue(nCuePtr)\nActivationMethod)
              \nOSCStringCount + 1
            
            Case "C"  ; Colors
              \sOSCTagTypes + "s"
              ReDim \sOSCString(\nOSCStringCount)
              getCurrColorsForCue(nCuePtr, @nBackColor, @nTextColor)
              \sOSCString(\nOSCStringCount) = "#" + hex6(colorCodeToRRGGBB(nBackColor)) + ", #" + hex6(colorCodeToRRGGBB(nTextColor))
              \nOSCStringCount + 1
              
            Case "L"  ; Length
              \sOSCTagTypes + "i"
              ReDim \nOSCLong(\nOSCLongCount)
              \nOSCLong(\nOSCLongCount) = stringToTime(getLengthForGrid(nCuePtr), #True)
              \nOSCLongCount + 1
              
            Case "N"  ; Name
              \sOSCTagTypes + "s"
              ReDim \sOSCString(\nOSCStringCount)
              \sOSCString(\nOSCStringCount) = aCue(nCuePtr)\sCueDescr
              \nOSCStringCount + 1
            
            Case "P"  ; Position
              \sOSCTagTypes + "i"
              ReDim \nOSCLong(\nOSCLongCount)
              If nSubPtr >= 0
                \nOSCLong(\nOSCLongCount) = aSub(nSubPtr)\nSubPosition
                If aSub(nSubPtr)\bSubTypeHasAuds
                  nAudPtr = aSub(nSubPtr)\nCurrPlayIndex
                  If nAudPtr < 0
                    nAudPtr = aSub(nSubPtr)\nFirstPlayIndex
                  EndIf
                  If nAudPtr >= 0
                    If aAud(nAudPtr)\bAudPlaceHolder = #False
                      \nOSCLong(\nOSCLongCount) = aAud(nAudPtr)\nCuePos
                    EndIf
                  EndIf
                EndIf
              Else
                \nOSCLong(\nOSCLongCount) = 0
              EndIf
              \nOSCLongCount + 1
              
            Case "Q"  ; Cue
              \sOSCTagTypes + "s"
              ReDim \sOSCString(\nOSCStringCount)
              \sOSCString(\nOSCStringCount) = aCue(nCuePtr)\sCue
              \nOSCStringCount + 1
            
            Case "R"  ; Repeat
              \sOSCTagTypes + "i"
              ReDim \nOSCLong(\nOSCLongCount)
              j = aCue(nCuePtr)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeAorP And aSub(j)\bSubEnabled
                  If aSub(j)\bPLRepeat
                    bPLRepeat = 1
                    Break
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
              \nOSCLong(\nOSCLongCount) = bPLRepeat
              \nOSCLongCount + 1
              
            Case "S"  ; State
              \sOSCTagTypes + "i"
              ReDim \nOSCLong(\nOSCLongCount)
              \nOSCLong(\nOSCLongCount) = getRAICueState(nCuePtr)
              \nOSCLongCount + 1
              
            Case "T"  ; Type
              \sOSCTagTypes + "s"
              ReDim \sOSCString(\nOSCStringCount)
              If nSubPtr >= 0
                \sOSCString(\nOSCStringCount) = aSub(nSubPtr)\sSubType
              Else
                ; nb shouldn't get here except possibly for very old cue files, because even 'note' cues now have a sub-cue
                \sOSCString(\nOSCStringCount) = "N"
              EndIf
              \nOSCStringCount + 1
              
            Case "W"  ; When Required
              \sOSCTagTypes + "s"
              ReDim \sOSCString(\nOSCStringCount)
              \sOSCString(\nOSCStringCount) = aCue(nCuePtr)\sWhenReqd
              \nOSCStringCount + 1
            
            Case "Z"  ; Loop
              \sOSCTagTypes + "i"
              ReDim \nOSCLong(\nOSCLongCount)
              j = aCue(nCuePtr)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
                  k = aSub(j)\nFirstAudIndex
                  If aAud(k)\nMaxLoopInfo >= 0
                    bContainsLoop = 1
                    Break
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
              \nOSCLong(\nOSCLongCount) = bContainsLoop
              \nOSCLongCount + 1
              
          EndSelect
          
        Next n
        
        populateOSCMessageDataIfReqd(nNetworkControlPtr)
        debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
        sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
        bMsgSent = #True
        
      EndIf
      
      If bMsgSent = #False
        sendErrToRemoteApp(nNetworkControlPtr, bHideTracing)
      EndIf
      
    EndWith
    
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processOSCConfigName(nNetworkControlPtr, sPath.s, sConfigName.s)
  PROCNAMEC()
  Protected sItemType.s, sItemNumber.s, nItemNumber, n
  Protected sTrimName.s
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", sPath=" + #DQUOTE$ + sPath + #DQUOTE$ + ", sConfigName=" + #DQUOTE$ + sConfigName + #DQUOTE$)
  
  ; this procedure handles responses to messages sent by the procedures listed below, AND ALSO changes made directly ny the X32 operator
  ;   getX32ChannelNames(nNetworkControlPtr)
  ;   getX32AuxInNames(nNetworkControlPtr)
  ;   getX32FXReturnNames(nNetworkControlPtr)
  ;   getX32BusNames(nNetworkControlPtr)
  ;   getX32MatrixNames(nNetworkControlPtr)
  ;   getX32DCAGroupNames(nNetworkControlPtr)
  ;   getX32MainNames(nNetworkControlPtr)
  ;   getX32CueNames(nNetworkControlPtr)
  ;   getX32SceneNames(nNetworkControlPtr)
  ;   getX32SnippetNames(nNetworkControlPtr)
  ;   getX32MuteGroups(nNetworkControlPtr)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)\rX32NWData
      sTrimName = Trim(sConfigName) ; intentionally trim sConfigName so that, for example, channel scribble strip name " BR" will be processed as "BR"
      Select sPath
        Case "/main/st/config/name"
          \sMain(0) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEMAINLR, 1))
          \nMainNameCount + 1
        Case "/main/m/config/name"
          \sMain(1) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEMAINMC, 2))
          \nMainNameCount + 1
        Default
          If Left(sPath, 16) = "/-show/showfile/"
            sItemType = StringField(sPath, 4, "/") ; eg cue, scene or snippet
            sItemNumber = StringField(sPath, 5, "/")
            If IsNumeric(sItemNumber)
              nItemNumber = Val(sItemNumber)
              n = nItemNumber ; nb do not subtract 1 from these item numbers for the item index as the X32 uses base 0 for cue numbers, etc
              Select sItemType
                Case "cue"
                  \sCue(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_GOCUE, nItemNumber))
                  \nCueNameCount + 1
                Case "scene"
                  \sScene(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_GOSCENE, nItemNumber))
                  \nSceneNameCount + 1
                Case "snippet"
                  \sSnippet(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_GOSNIPPET, nItemNumber))
                  \nSnippetNameCount + 1
              EndSelect ; EndSelect sItemType
            EndIf       ; EndIf IsNumeric(sItemNumber)
          Else
            sItemType = StringField(sPath, 2, "/")
            sItemNumber = StringField(sPath, 3, "/")
            If IsNumeric(sItemNumber)
              nItemNumber = Val(sItemNumber)
              n = nItemNumber - 1 ; nb subtract 1 from these item numbers for the item index as the X32 uses base 1 for channel numbers, etc
              Select sItemType
                Case "ch"
                  \sChannel(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTECHANNEL, nItemNumber))
                  \nChannelNameCount + 1
                Case "auxin"
                  \sAuxIn(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEAUXIN, nItemNumber))
                  \nAuxInNameCount + 1
                Case "fxrtn"
                  \sFXReturn(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEFXRTN, nItemNumber))
                  \nFXReturnNameCount + 1
                Case "bus"
                  \sBus(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEBUS, nItemNumber))
                  \nBusNameCount + 1
                Case "mtx"
                  \sMatrix(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEMATRIX, nItemNumber))
                  \nMatrixNameCount + 1
                Case "dca"
                  \sDCAGroup(n) = stringNVL(sTrimName, makeX32ItemId(#SCS_CS_OSC_MUTEDCAGROUP, nItemNumber))
                  ; debugMsg(sProcName, "(DCA) nItemNumber=" + nItemNumber + ", sTrimName=" + sTrimName + ", makeX32ItemId(#SCS_CS_OSC_MUTEDCAGROUP, " + nItemNumber + ")=" + makeX32ItemId(#SCS_CS_OSC_MUTEDCAGROUP, nItemNumber))
                  \nDCAGroupNameCount + 1
              EndSelect ; EndSelect sItemType
            EndIf       ; EndIf IsNumeric(sItemNumber)
          EndIf
      EndSelect ; EndSelect sPath
    EndWith
  EndIf
  
EndProcedure

Procedure sendErrToRemoteApp(nNetworkControlPtr, bHideTracing=#False)
  PROCNAMEC()
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      \sOSCTagTypes = "s"
      \nOSCStringCount = 1
      \sOSCString(0) = "ERR"
      debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
      sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
    EndWith
  EndIf
  
  debugMsgN(sProcName, #SCS_END)
  
EndProcedure

Procedure processOSCFaderRequest(nNetworkControlPtr, nCmd, fFloat.f=0, nPercentage=0, sLogicalDev.s="")
  PROCNAMEC()
  Protected fBVLevel.f, fDBLevel.f, nDevMapDevPtr, nDevNo
  
  ; debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCmd=" + decodeOSCCmdType(nCmd) + ", fFloat=" + StrF(fFloat) + ", sLogicalDev=" + sLogicalDev)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      
      Select nCmd
        Case #SCS_OSCINP_FADER_GET_DEVICE, #SCS_OSCINP_FADER_GET_DEVICE_PERCENT, #SCS_OSCINP_FADER_SET_DEVICE, #SCS_OSCINP_FADER_SET_DEVICE_PERCENT, #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
          nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
          If nDevMapDevPtr < 0 Or nDevNo < 0
            ; shouldn't get here
            debugMsg0(sProcName, "Exiting because nDevMapDevPtr=" + nDevMapDevPtr + ", nDevNo=" + nDevNo)
            ProcedureReturn
          EndIf
      EndSelect
      
      Select nCmd
        ; Master Fader
        ; ============
        Case #SCS_OSCINP_FADER_GET_MASTER
          \sOSCTagTypes = "fff"
          \nOSCFloatCount = 3
          ReDim \fOSCFloat(2)
          \fOSCFloat(0) = convertBVLevelToDBLevel(grMasterLevel\fProdMasterBVLevel)
          \fOSCFloat(1) = grLevels\nMinDBLevel
          \fOSCFloat(2) = grLevels\nMaxDBLevel
          
        Case #SCS_OSCINP_FADER_GET_MASTER_PERCENT
          \sOSCTagTypes = "i"
          \nOSCLongCount = 1
          \nOSCLong(0) = SLD_levelToPercentage(grMasterLevel\fProdMasterBVLevel)
          
        Case #SCS_OSCINP_FADER_SET_MASTER
          fDBLevel = fFloat
          samAddRequest(#SCS_SAM_SET_MASTER_FADER, 0, convertDBLevelToBVLevel(fDBLevel), #True)
          
        Case #SCS_OSCINP_FADER_SET_MASTER_PERCENT
          fBVLevel = SLD_percentageToLevel(nPercentage)
          samAddRequest(#SCS_SAM_SET_MASTER_FADER, 0, fBVLevel, #True)
          
        Case #SCS_OSCINP_FADER_SET_MASTER_RELATIVE
          If grMasterLevel\bUseControllerFaderMasterBVLevel
            fBVLevel = grMasterLevel\fControllerFaderMasterBVLevel
          Else
            fBVLevel = grMasterLevel\fProdMasterBVLevel
          EndIf
          fDBLevel = convertBVLevelToDBLevel(fBVLevel) + fFloat ; nb fFloat may be positive or negative dB
          If fDBLevel > grProd\nMaxDBLevel
            fDBLevel = grProd\nMaxDBLevel
          EndIf
          samAddRequest(#SCS_SAM_SET_MASTER_FADER, 0, convertDBLevelToBVLevel(fDBLevel), #True)
          
        ; Device Fader
        ; ============
        Case #SCS_OSCINP_FADER_GET_DEVICE
          \sOSCTagTypes = "sfff"
          \nOSCStringCount = 1
          \sOSCString(0) = sLogicalDev
          \nOSCFloatCount = 3
          ReDim \fOSCFloat(2)
          \fOSCFloat(0) = convertBVLevelToDBLevel(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain)
          \fOSCFloat(1) = grLevels\nMinDBLevel
          \fOSCFloat(2) = grLevels\nMaxDBLevel
          
        Case #SCS_OSCINP_FADER_GET_DEVICE_PERCENT
          \sOSCTagTypes = "si"
          \nOSCStringCount = 1
          \sOSCString(0) = sLogicalDev
          \nOSCLongCount = 1
          \nOSCLong(0) = SLD_levelToPercentage(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain)
          
        Case #SCS_OSCINP_FADER_SET_DEVICE
          fDBLevel = fFloat
          samAddRequest(#SCS_SAM_SET_DEVICE_FADER, nDevNo, convertDBLevelToBVLevel(fDBLevel))
          
        Case #SCS_OSCINP_FADER_SET_DEVICE_PERCENT
          fBVLevel = SLD_percentageToLevel(nPercentage)
          samAddRequest(#SCS_SAM_SET_DEVICE_FADER, nDevNo, fBVLevel, #True)
          
        Case #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
          If grMaps\aDev(nDevMapDevPtr)\bUseFaderOutputGain
            fBVLevel = grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain
          Else
            fBVLevel = grMaps\aDev(nDevMapDevPtr)\fDevOutputGain
          EndIf
          fDBLevel = convertBVLevelToDBLevel(fBVLevel) + fFloat ; nb fFloat may be positive or negative dB
          If fDBLevel > grProd\nMaxDBLevel
            fDBLevel = grProd\nMaxDBLevel
          EndIf
          samAddRequest(#SCS_SAM_SET_DEVICE_FADER, nDevNo, convertDBLevelToBVLevel(fDBLevel))
          
      EndSelect
      
      If nCmd > 1000
        populateOSCMessageDataIfReqd(nNetworkControlPtr)
        debugMsg(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ")")
        sendOSCComplexMessage(nNetworkControlPtr)
      EndIf
      
    EndWith
    
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkInput_OSC(nNetworkControlPtr, bHideTracing=#False)
  PROCNAMEC()
  Protected sPath.s, sCommand.s, sPathNumericsToStar.s
  Protected sCmdDescr.s, sMsg.s, sErrorMsg.s
  Protected nCmd = -1
  Protected bParam1IsString, bParam1IsCue, bParam1IsHKey, bParam1IsNumber, bParam1IsFloat, bParam1IsColorCode, bParam1IsFileName, bParam1IsAudioDevice
  Protected bParam2IsNumber, bParam2IsFloat, bParam2IsString, bParam2IsCue
  Protected sCue.s, nCuePtr
  Protected sColorCode.s
  Protected sFMBFileName.s, sFMBCue.s
  Protected sHotkey.s, nHotkeyPtr, nHotkeyNr
  Protected sAudioDevice.s, nDevNo
  Protected nNumber, sString.s
  Protected fFloat.f
  Protected bUnknownCommand, bError
  Protected bQuiet
  Protected bDoNotIncludeinTestWindow ; Added 18Jan2025 11.10.6-b05, primarily to hide /eos messages
  Protected bEchoCommandIfReqd  ; nb 'echo command if reqd' means echo command if required by this network connection, eg by the remote app, but not by the SCS Primary
  Protected bNoEcho
  Protected nThisStartPos, nThisEndPos
  Protected nGoCue, bGoResult
  Protected nSubPtr, nSubLength
  Protected nBankIndex, nKeyIndex
  Protected n, sDebug.s
  Protected nCmdQualifierPtr, sCmdQualifier.s, nCmdQualifier
  Protected sConfigName.s
  Static bStaticLoaded
  Static sNetworkIn.s, nRegExpNumerics
  
  ; debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bHideTracing=" + strB(bHideTracing))
  
  If bStaticLoaded = #False
    sNetworkIn = decodeDevTypeL(#SCS_DEVTYPE_CC_NETWORK_IN)
    nRegExpNumerics = CreateRegularExpression(#PB_Any, "\d+") ; matches all instances of 1 or more consecutive digits
    bStaticLoaded = #True
  EndIf
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      sPath = LCase(Trim(removeNonPrintingChars(\sOSCPath)))
      sCommand = StringField(sPath, 1, " ")
      If \bRAIDev
        If grRAIOptions\bRAIEnabled
          nCmdQualifierPtr = FindString(sCommand, "/^")
          If nCmdQualifierPtr
            sCmdQualifier = Mid(sPath, nCmdQualifierPtr)
            sPath = RemoveString(sPath, sCmdQualifier)
            nCmdQualifier = Val(Mid(sCmdQualifier,3))
            If nCmdQualifier & 1
              bNoEcho = #True
            EndIf
            If nCmdQualifier & 2
              bQuiet = #True
            EndIf
          EndIf
        Else
          ; Remote App Interface currently disabled
          debugMsg(sProcName, "Ignoring input message because the Remote App Interface is currently disabled")
          ProcedureReturn
        EndIf
      EndIf
      ; debugMsg(sProcName, "\sOSCPath=$" + stringToHexString(\sOSCPath))
      debugMsgN(sProcName, "sPath=$" + stringToHexString(sPath) + ", bNoEcho=" + strB(bNoEcho) + ", bQuiet=" + strB(bQuiet))
      
      ; having /scs at the start of the path is optional. /scs included 2Jul2016 11.5.1 following email from LSC with the subject "LX300 OSC output?"
      ; the following is safer than using RemoveString as this test and logic will not affect an \sOSCPath that happens to contain /scs later in the string
      If Left(sPath, 4) = "/scs"
        sPath = Mid(sPath, 5) ; slightly safer than using RemoveString as this test and logic will not affect an \sOSCPath that happens to contain /scs later in the string
      EndIf
      If bHideTracing = #False
        sDebug = "sPath=" + sPath + ", \nOSCLongCount=" + \nOSCLongCount + ", \nOSCFloatCount=" + \nOSCFloatCount + ", \nOSCStringCount=" + \nOSCStringCount
        For n = 0 To (\nOSCLongCount-1)
          sDebug + ", \nOSCLong(" + n + ")=" + \nOSCLong(n)
        Next n
        For n = 0 To (\nOSCFloatCount-1)
          sDebug + ", \nOSCFloat(" + n + ")=" + StrF(\fOSCFloat(n), 6)
        Next n
        For n = 0 To (\nOSCStringCount-1)
          sDebug + ", \sOSCString(" + n + ")=" + \sOSCString(n)
        Next n
        sDebug + ", \sOSCTextParam1=" + \sOSCTextParam1 + ", \sOSCTextParam2=" + \sOSCTextParam2
        ; debugMsgN(sProcName, sDebug)
        debugMsg(sProcName, sDebug)
      EndIf
      
      Select sPath
        Case "/beat" ; X32TC
          nCmd = #SCS_OSCINP_BEAT
          bQuiet = #True
        Case "/status" ; X32
          nCmd = #SCS_OSCINP_STATUS
          bQuiet = #True
        Case "/info" ; X32
          nCmd = #SCS_OSCINP_INFO
        Case "/xinfo" ; X32
          nCmd = #SCS_OSCINP_XINFO
          
        Case "/file/open"
          nCmd = #SCS_OSCINP_FILE_OPEN
          If \nOSCStringCount > 0
            sFMBFileName = Trim(\sOSCString(0))
            If \nOSCStringCount > 1
              sFMBCue = Trim(\sOSCString(1))
            EndIf
          EndIf
          
        Case "/fmh/bca" ; functional mode handler / backup connection accepted (sent from the primary and received by the backup)
          grFMOptions\qTimeBCAReceived = ElapsedMilliseconds()
          If \nOSCStringCount > 0
            grFMOptions\sPrimaryVersion = Trim(\sOSCString(0))
          EndIf
          bQuiet = #True
          
        Case "/poll" ; Added 16Jan2024 11.10.0 to maintain primary/backup network connection
          bQuiet = #True
          bDoNotIncludeinTestWindow = #True
          
        Case "/ctrl/opennextcues"
          nCmd = #SCS_OSCINP_CTRL_OPEN_NEXT_CUES
          bParam1IsCue = #True
        Case "/ctrl/go"
          nCmd = #SCS_OSCINP_CTRL_GO
          bEchoCommandIfReqd = #True
        Case "/ctrl/goconfirm"
          nCmd = #SCS_OSCINP_CTRL_GO_CONFIRM
          bEchoCommandIfReqd = #True
        Case "/ctrl/stopall"
          nCmd = #SCS_OSCINP_CTRL_STOP_ALL
          bEchoCommandIfReqd = #True
        Case "/ctrl/fadeall"
          nCmd = #SCS_OSCINP_CTRL_FADE_ALL
          bEchoCommandIfReqd = #True
        Case "/ctrl/pauseresumeall"
          nCmd = #SCS_OSCINP_CTRL_PAUSE_RESUME_ALL
          bEchoCommandIfReqd = #True
        Case "/ctrl/stopmtc"
          nCmd = #SCS_OSCINP_CTRL_STOP_MTC
          bEchoCommandIfReqd = #True
        Case "/ctrl/gotop"
          nCmd = #SCS_OSCINP_CTRL_GO_TO_TOP
          bEchoCommandIfReqd = #True
        Case "/ctrl/goback"
          nCmd = #SCS_OSCINP_CTRL_GO_BACK
          bEchoCommandIfReqd = #True
        Case "/ctrl/gotonext"
          nCmd = #SCS_OSCINP_CTRL_GO_TO_NEXT
          bEchoCommandIfReqd = #True
        Case "/ctrl/gotoend"
          nCmd = #SCS_OSCINP_CTRL_GO_TO_END
          bEchoCommandIfReqd = #True
        Case "/ctrl/gotocue"
          nCmd = #SCS_OSCINP_CTRL_GO_TO_CUE
          bParam1IsCue = #True
          bEchoCommandIfReqd = #True
          
        Case "/ctrl/setplayorder"
          nCmd = #SCS_OSCINP_SET_PLAYORDER
          ; parameters will be extracted in FMB_setPlayOrder(nNetworkControlPtr)
          
        Case "/cue/go"
          nCmd = #SCS_OSCINP_CUE_PLAY
          bParam1IsCue = #True
          bEchoCommandIfReqd = #True
        Case "/cue/stop"
          nCmd = #SCS_OSCINP_CUE_STOP
          bParam1IsCue = #True
          bEchoCommandIfReqd = #True
        Case "/cue/pauseresume"
          nCmd = #SCS_OSCINP_CUE_PAUSE_RESUME
          bParam1IsCue = #True
          bEchoCommandIfReqd = #True
          
        Case "/hkey/go"
          nCmd = #SCS_OSCINP_HKEY_GO
          bParam1IsHKey = #True
          bEchoCommandIfReqd = #True
        Case "/hkey/on"
          nCmd = #SCS_OSCINP_HKEY_ON
          bParam1IsHKey = #True
          bEchoCommandIfReqd = #True
        Case "/hkey/off"
          nCmd = #SCS_OSCINP_HKEY_OFF
          bParam1IsHKey = #True
          bEchoCommandIfReqd = #True
          
        Case "/pnlbtn"
          nCmd = #SCS_OSCINP_PNL_BTN_CLICK
          
        Case "/info/scsversion"
          nCmd = #SCS_OSCINP_INFO_SCS_VERSION
        Case "/info/finalcue"
          nCmd = #SCS_OSCINP_INFO_FINAL_CUE
          debugMsg(sProcName, "nCmd=#SCS_OSCINP_INFO_FINAL_CUE")
        Case "/info/currcue"
          nCmd = #SCS_OSCINP_INFO_CURR_CUE
          debugMsg(sProcName, "nCmd=#SCS_OSCINP_INFO_CURR_CUE")
        Case "/info/nextcue"
          nCmd = #SCS_OSCINP_INFO_NEXT_CUE
          debugMsg(sProcName, "nCmd=#SCS_OSCINP_INFO_NEXT_CUE")
        Case "/info/getcue"
          nCmd = #SCS_OSCINP_INFO_GET_CUE
          bParam1IsNumber = #True
        Case "/info/hkeycount"
          nCmd = #SCS_OSCINP_INFO_HKEY_COUNT
          debugMsg(sProcName, "nCmd=#SCS_OSCINP_INFO_HKEY_COUNT")
        Case "/info/gethkey"
          nCmd = #SCS_OSCINP_INFO_GET_HKEY
          bParam1IsNumber = #True
        Case "/info/getcolors"
          nCmd = #SCS_OSCINP_INFO_GET_COLORS
          bParam1IsColorCode = #True
          
        Case "/info/product" ; Added for X32TC
          nCmd = #SCS_OSCINP_INFO_PRODUCT
        Case "/info/cuefile" ; Added for X32TC
          nCmd = #SCS_OSCINP_INFO_CUE_FILE
        Case "/info/title" ; Same as #SCS_OSCINP_PROD_GET_TITLE but added for X32TC
          nCmd = #SCS_OSCINP_INFO_TITLE
          
        Case "/prod/gettitle"
          nCmd = #SCS_OSCINP_PROD_GET_TITLE
          
        Case "/cue/getitemsn"
          nCmd = #SCS_OSCINP_CUE_GET_ITEMS_N
          bParam1IsNumber = #True
          bParam2IsString = #True
        Case "/cue/getitemsx", "/cue/getitems"  ; nb "/cue/getitems" for backwards-compatibility
          nCmd = #SCS_OSCINP_CUE_GET_ITEMS_X
          bParam1IsCue = #True
          bParam2IsString = #True
          
        Case "/cue/getname"
          nCmd = #SCS_OSCINP_CUE_GET_NAME
          bParam1IsCue = #True
        Case "/cue/getpage"
          nCmd = #SCS_OSCINP_CUE_GET_PAGE
          bParam1IsCue = #True
        Case "/cue/getwhenreqd"
          nCmd = #SCS_OSCINP_CUE_GET_WHEN_REQD
          bParam1IsCue = #True
        Case "/cue/gettype"
          nCmd = #SCS_OSCINP_CUE_GET_TYPE
          bParam1IsCue = #True
        Case "/cue/getlength"
          nCmd = #SCS_OSCINP_CUE_GET_LENGTH
          bParam1IsCue = #True
        Case "/cue/getstate"
          nCmd = #SCS_OSCINP_CUE_GET_STATE
          bParam1IsCue = #True
        Case "/cue/getpos"
          nCmd = #SCS_OSCINP_CUE_GET_POS
          bParam1IsCue = #True
          bQuiet = #True
        Case "/cue/setpos"
          nCmd = #SCS_OSCINP_CUE_SET_POS
          bParam1IsCue = #True
          bParam2IsNumber = #True
        Case "/cue/getcolors"
          nCmd = #SCS_OSCINP_CUE_GET_COLORS
          bParam1IsCue = #True
          
        Case "/fader/getmaster"
          nCmd = #SCS_OSCINP_FADER_GET_MASTER
        Case "/fader/getmaster%"
          nCmd = #SCS_OSCINP_FADER_GET_MASTER_PERCENT
        Case "/fader/setmaster"
          nCmd = #SCS_OSCINP_FADER_SET_MASTER
          bParam1IsFloat = #True
        Case "/fader/setmasterrel"
          nCmd = #SCS_OSCINP_FADER_SET_MASTER_RELATIVE
          bParam1IsFloat = #True
        Case "/fader/setmaster%"
          nCmd = #SCS_OSCINP_FADER_SET_MASTER_PERCENT
          bParam1IsNumber = #True
          
        Case "/fader/getdevice"
          nCmd = #SCS_OSCINP_FADER_GET_DEVICE
          bParam1IsAudioDevice = #True
        Case "/fader/getdevice%"
          nCmd = #SCS_OSCINP_FADER_GET_DEVICE_PERCENT
          bParam1IsAudioDevice = #True
        Case "/fader/setdevice"
          nCmd = #SCS_OSCINP_FADER_SET_DEVICE
          bParam1IsAudioDevice = #True
          bParam2IsFloat = #True
        Case "/fader/setdevicerel"
          nCmd = #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
          bParam1IsAudioDevice = #True
          bParam2IsFloat = #True
        Case "/fader/setdevice%"
          nCmd = #SCS_OSCINP_FADER_SET_DEVICE_PERCENT
          bParam1IsAudioDevice = #True
          bParam2IsNumber = #True
          
        Default
          If Left(sPath, 4) = "/eos" ; Added /eos test 13Jan2025 11.10.6-b03
            bQuiet = #True
            bDoNotIncludeinTestWindow = #True  ; Added 18Jan2025 11.10.6-b05
            nCmd = #SCS_OSCINP_IGNORE
          ElseIf IsRegularExpression(nRegExpNumerics)
            sPathNumericsToStar = ReplaceRegularExpression(nRegExpNumerics, sPath, "*")
            ; above converts all instances of 1 or more consecutive digits to a single *
            ; eg "/ch/07/config/name" is converted to "/ch/*/config/name"
            Select sPathNumericsToStar
              Case "/ch/*/config/name", "/auxin/*/config/name", "/fxrtn/*/config/name", "/bus/*/config/name", "/mtx/*/config/name", "/dca/*/config/name",
                   "/main/st/config/name", "/main/m/config/name",
                   "/-show/showfile/cue/*/name", "/-show/showfile/scene/*/name", "/-show/showfile/snippet/*/name"
                nCmd = #SCS_OSCINP_X32_CONFIG_NAME
                If \nOSCStringCount > 0
                  sConfigName = \sOSCString(0)
                EndIf
              Default
                nCmd = #SCS_OSCINP_IGNORE
            EndSelect
          Else
            nCmd = #SCS_OSCINP_IGNORE
          EndIf
          
      EndSelect
      
      ; added 21Mar2019 11.8.0.2ci following report from Michael Dahlen that "SCS crashes on when being triggered by Steam Deck via Companion"
      ; this due to assuming the device was an SCSRemote app which echoes data to the client connection, but since this device was connected via UDP then no connection request was received (see PB help for NetworkServerEvent)
      ; modified 31May2019 11.8.1.1ad to include "And (\nCurrNetworkProtocol = #SCS_NETWORK_PR_UDP)" because without this, the genuine Remote App wouldn't reposition the cue list on the remote app itself
      If (\nClientConnection) And (\nCurrNetworkProtocol = #SCS_NETWORK_PR_UDP)
        bEchoCommandIfReqd = #False
      EndIf
      ; end added 21Mar2019 11.8.0.2ci
      
      If bParam1IsCue ; INFO bParam1IsCue
        bParam1IsString = #True
        If \bOSCTextMsg
          sCue = Trim(\sOSCTextParam1)
        ElseIf \nOSCStringCount > 0
          sCue = Trim(\sOSCString(0))
        EndIf
        debugMsgN(sProcName, "sCue=" + sCue)
        If sCue
          nCuePtr = getCuePtr(sCue)
          ; debugMsg(sProcName, "nCuePtr=" + nCuePtr)
          If nCuePtr >= 0
            If aCue(nCuePtr)\bCueEnabled = #False
              nCuePtr = -1
            EndIf
          EndIf
          If nCuePtr < 0
            sErrorMsg = LangPars("Errors", "CueNotFound", sCue) ; "Cue $1 not found or not enabled"
            bError = #True
          EndIf
        EndIf
        
      ElseIf bParam1IsHKey ; INFO bParam1IsHKey
        bParam1IsString = #True
        If \bOSCTextMsg
          sHotkey = Trim(\sOSCTextParam1)
        ElseIf \nOSCStringCount > 0
          sHotkey = Trim(\sOSCString(0))
        EndIf
        If sHotkey
          nHotkeyPtr = getHotkeyPtrForHotkey(sHotkey)
          If nHotkeyPtr >= 0
            nCuePtr = gaCurrHotkeys(nHotkeyPtr)\nCuePtr
            nHotkeyNr = gaCurrHotkeys(nHotkeyPtr)\nHotkeyNr
            If nCuePtr >= 0
              If aCue(nCuePtr)\bCueEnabled = #False
                nHotkeyPtr = -1
              EndIf
            Else
              nHotkeyPtr = -1
            EndIf
          EndIf
          If nHotkeyPtr < 0
            sErrorMsg = LangPars("Errors", "HKNotFound", sHotkey) ; "Hotkey $1 not found or cue not enabled"
            bError = #True
          EndIf
          ; debugMsg(sProcName, "sHotkey=" + sHotkey + ", nHotkeyPtr=" + nHotkeyPtr + ", nHotkeyNr=" + nHotkeyNr)
        EndIf
        
      ElseIf bParam1IsAudioDevice ; INFO bParam1IsAudioDevice
        bParam1IsString = #True
        If \bOSCTextMsg
          sAudioDevice = Trim(\sOSCTextParam1)
        ElseIf \nOSCStringCount > 0
          sAudioDevice = Trim(\sOSCString(0))
        EndIf
        If sAudioDevice
          nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_AUDIO_OUTPUT, sAudioDevice)
          If nDevNo < 0
            sErrorMsg = LangPars("Errors", "DevNotAssigned", sAudioDevice) ; "Device $1 has not been assigned to an Audio Device in the Production Properties"
            bError = #True
          EndIf
        EndIf
        
      ElseIf bParam1IsNumber ; INFO bParam1IsNumber
        If \bOSCTextMsg
          If IsInteger(Trim(\sOSCTextParam1))
            nNumber = Val(Trim(\sOSCTextParam1))
          Else
            sErrorMsg = LangPars("Errors", "MustBeNumeric", \sOSCTextParam1)
            bError = #True
          EndIf
        ElseIf \nOSCLongCount > 0
          nNumber = \nOSCLong(0)
        EndIf
        If bError = #False
          If nCmd = #SCS_OSCINP_FADER_SET_MASTER_PERCENT
            If (nNumber < 0) Or (nNumber > 100)
              bError = #True
            EndIf
          EndIf
        EndIf
        debugMsgN(sProcName, "bParam1IsNumber=" + strB(bParam1IsNumber) + ", \bOSCTextMsg=" + strB(\bOSCTextMsg) + ", \sOSCTextParam1=" + \sOSCTextParam1 + ", nNumber=" + nNumber)
        
      ElseIf bParam1IsFloat ; INFO bParam1IsFloat
        If \bOSCTextMsg
          If validateNumberField(Trim(\sOSCTextParam1))
            fFloat = ValF(Trim(\sOSCTextParam1))
          Else
            bError = #True
          EndIf
        Else
          If \nOSCFloatCount > 0
            fFloat = \fOSCFloat(0)
          EndIf
        EndIf
        If bError = #False
          If nCmd = #SCS_OSCINP_FADER_SET_MASTER
            If fFloat < grLevels\nMinDBLevel
              fFloat = grLevels\nMinDBLevel
            ElseIf fFloat > grLevels\nMaxDBLevel
              fFloat = grLevels\nMaxDBLevel
            EndIf
          EndIf
        EndIf
        If bError
          If \bOSCTextMsg
            sErrorMsg = LangPars("Errors", "MustBeBetween", \sOSCTextParam1, grLevels\sMinDBLevel, grLevels\sMaxDBLevel)
          Else
            sErrorMsg = LangPars("Errors", "MustBeBetween", StrF(fFloat), grLevels\sMinDBLevel, grLevels\sMaxDBLevel)
          EndIf
        EndIf
          
      ElseIf bParam1IsColorCode ; INFO bParam1IsColorCode
        bParam1IsString = #True
        If \bOSCTextMsg
          sColorCode = Trim(\sOSCTextParam1)
        ElseIf \nOSCStringCount > 0
          sColorCode = Trim(\sOSCString(0))
        EndIf
        If sColorCode
          nNumber = encodeColorItemCode(sColorCode)
        EndIf
        debugMsgN(sProcName, "sColorCode=" + sColorCode + ", nNumber=" + nNumber)
        
      EndIf
      
      ; ================================================
      ; END OF PARAM 1 CHECKING - START PARAM 2 CHECKING
      ; ================================================
      
      If bError = #False
        If bParam2IsNumber ; INFO bParam2IsNumber
          If \bOSCTextMsg
            If IsInteger(Trim(\sOSCTextParam2))
              nNumber = Val(Trim(\sOSCTextParam2))
            Else
              sErrorMsg = LangPars("Errors", "MustBeNumeric", \sOSCTextParam2)
              bError = #True
            EndIf
          ElseIf \nOSCLongCount > 0
            nNumber = \nOSCLong(0)
          EndIf
          If bError = #False
            If nCmd = #SCS_OSCINP_FADER_SET_DEVICE_PERCENT
              If (nNumber < 0) Or (nNumber > 100)
                bError = #True
              EndIf
            EndIf
          EndIf
          debugMsgN(sProcName, "bParam2IsNumber=" + strB(bParam2IsNumber) + ", \bOSCTextMsg=" + strB(\bOSCTextMsg) + ", \nOSCLongCount=" + \nOSCLongCount +
                               ", \sOSCTextParam2=" + \sOSCTextParam2 + ", nNumber=" + nNumber)
          
        ElseIf bParam2IsFloat ; INFO bParam2IsFloat
          If \bOSCTextMsg
            If validateNumberField(Trim(\sOSCTextParam2))
              fFloat = ValF(Trim(\sOSCTextParam2))
            Else
              bError = #True
            EndIf
          Else
            If \nOSCFloatCount > 0
              fFloat = \fOSCFloat(0)
            EndIf
          EndIf
          If bError = #False
            If nCmd = #SCS_OSCINP_FADER_SET_DEVICE
              If fFloat < grLevels\nMinDBLevel
                fFloat = grLevels\nMinDBLevel
              ElseIf fFloat > grLevels\nMaxDBLevel
                fFloat = grLevels\nMaxDBLevel
              EndIf
            EndIf
          EndIf
          If bError
            If \bOSCTextMsg
              sErrorMsg = LangPars("Errors", "MustBeBetween", \sOSCTextParam2, grLevels\sMinDBLevel, grLevels\sMaxDBLevel)
            Else
              sErrorMsg = LangPars("Errors", "MustBeBetween", StrF(fFloat), grLevels\sMinDBLevel, grLevels\sMaxDBLevel)
            EndIf
          EndIf
          
        ElseIf bParam2IsString ; INFO bParam2IsString
          If \bOSCTextMsg
            sString = Trim(\sOSCTextParam2)
          ElseIf (bParam1IsString = #False) And (\nOSCStringCount > 0)
            sString = Trim(\sOSCString(0))
          ElseIf \nOSCStringCount > 1
            sString = Trim(\sOSCString(1))
          EndIf
          debugMsgN(sProcName, "bParam2IsString=" + strB(bParam2IsString) + ", \sOSCTextParam2=" + \sOSCTextParam2 + ", sString=" + sString)
          
        EndIf
        
      EndIf ; EndIf bError = #False
      
      ; =======================
      ; END OF PARAM 2 CHECKING
      ; =======================
      
      If (bQuiet = #False) Or (gbMidiTestWindow)
        If bUnknownCommand Or nCmd = #SCS_OSCINP_IGNORE
          sCmdDescr = Lang("Remote", "Unknown")
          bError = #True
        Else
          If sCue
            sCmdDescr = decodeRemCmdL(nCmd, sCue)
          ElseIf sHotkey
            sCmdDescr = decodeRemCmdL(nCmd, sHotkey)
          EndIf
        EndIf
      EndIf
      
      sMsg = sNetworkIn + ": " + \sOSCDisplayMsg
      If sCmdDescr
        sMsg + ": " + sCmdDescr
      EndIf
      If bError And sErrorMsg
        sMsg + " [" + sErrorMsg + "]"
      EndIf
      
      If gbMidiTestWindow
        If bDoNotIncludeinTestWindow = #False ; Added 18Jan2025 11.10.6-b05, primarily to hide /eos messages
          WMT_addMiscListItem(sMsg)
        EndIf
        
      ElseIf bError
        WMN_setStatusField(sMsg, #SCS_STATUS_ERROR)
        If \bRAIDev
          debugMsg(sProcName, "calling sendErrToRemoteApp(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
          sendErrToRemoteApp(nNetworkControlPtr, bHideTracing)
        EndIf
        
      Else
        
        If bEchoCommandIfReqd
          If bNoEcho = #False
            If \bRAIDev
              echoReceivedData(nNetworkControlPtr, bHideTracing)
            EndIf
          EndIf
          bEchoCommandIfReqd = #False
        EndIf
        
        Select nCmd
          Case #SCS_OSCINP_BEAT
            processOSCBeatRequest(nNetworkControlPtr, bHideTracing)
            
          Case #SCS_OSCINP_STATUS
            processOSCStatusRequest(nNetworkControlPtr, bHideTracing)
            
          Case #SCS_OSCINP_CTRL_GO
            nGoCue = gnCueToGo
            bGoResult = processNetworkGoButtonCommand()
            If (bGoResult) And (nGoCue >= 0)
              sCue = aCue(nGoCue)\sCue
              nSubPtr = aCue(nGoCue)\nFirstSubIndex
              If nSubPtr >= 0
                nSubLength = getSubLength(nSubPtr)
              EndIf
            EndIf
            If bEchoCommandIfReqd
              \sOSCTagTypes = "si"
              \nOSCStringCount = 1
              \nOSCLongCount = 1
              \sOSCString(0) = sCue
              \nOSCLong(0) = nSubLength
              sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
            EndIf
            
          Case #SCS_OSCINP_CTRL_STOP_ALL
            processNetworkStopAllCommand()
          Case #SCS_OSCINP_CTRL_FADE_ALL
            processNetworkFadeAllCommand()
          Case #SCS_OSCINP_CTRL_STOP_MTC
            processNetworkStopMTCCommand()
          Case #SCS_OSCINP_CTRL_PAUSE_RESUME_ALL
            processNetworkPauseResumeAllCommand()
          Case #SCS_OSCINP_CTRL_GO_TO_TOP
            processNetworkGoToTopCommand()
          Case #SCS_OSCINP_CTRL_GO_BACK
            processNetworkGoBackCommand()
          Case #SCS_OSCINP_CTRL_GO_TO_NEXT
            ; debugMsg(sProcName, "calling processNetworkGoToNextCommand")
            processNetworkGoToNextCommand()
          Case #SCS_OSCINP_CTRL_GO_TO_END
            processNetworkGoToEndCommand()
          Case #SCS_OSCINP_CTRL_GO_TO_CUE
            processNetworkGoToCueCommand(sCue)
          Case #SCS_OSCINP_CTRL_GO_CONFIRM
            confirmGo(#SCS_OSCINP_CTRL_GO_CONFIRM)
            
          Case #SCS_OSCINP_CUE_PLAY
            ; debugMsg(sProcName, "calling processNetworkGoCommand('" + sCue + "')")
            processNetworkGoCommand(sCue)
          Case #SCS_OSCINP_CUE_STOP
            processNetworkStopCommand(sCue)
          Case #SCS_OSCINP_CUE_PAUSE_RESUME
            processNetworkPauseResumeCommand(sCue)
            
          Case #SCS_OSCINP_HKEY_GO
            ; WMN_processHotkey(nHotkeyPtr, #True)
            WMN_processHotkey(nHotkeyNr, #True)
          Case #SCS_OSCINP_HKEY_ON
            ; WMN_processHotkey(nHotkeyPtr, #True)
            WMN_processHotkey(nHotkeyNr, #True)
          Case #SCS_OSCINP_HKEY_OFF
;             gaCurrHotkeys(nHotkeyPtr)\bExternallyTriggered = #False ; allows checkForNoteHotkeysReleased() to complete cue
            If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP ; Added 30Jun2023
              nCuePtr = gaCurrHotkeys(nHotkeyPtr)\nCuePtr
              If nCuePtr >= 0
                If aCue(nCuePtr)\nCueState < #SCS_CUE_FADING_OUT
                  ; debugMsg(sProcName, "calling fadeOutCue(" + getCueLabel(nCuePtr) + ", #False, #True)")
                  fadeOutCue(nCuePtr, #False, #True)
                  gbCallLoadDispPanels = #True
                EndIf
              EndIf
            Else
              gaCurrHotkeys(nHotkeyPtr)\bExternallyTriggered = #False ; allows checkForNoteHotkeysReleased() to complete cue
            EndIf
            
          Case #SCS_OSCINP_PNL_BTN_CLICK
            PNL_processOSCPanlBtnClick(\sOSCString(0), \sOSCString(1), \nOSCLong(0), \nOSCLong(1))
            
          Case #SCS_OSCINP_INFO_CURR_CUE, #SCS_OSCINP_INFO_FINAL_CUE, #SCS_OSCINP_INFO_GET_CUE, #SCS_OSCINP_INFO_NEXT_CUE, #SCS_OSCINP_INFO_SCS_VERSION, #SCS_OSCINP_INFO_GET_COLORS, #SCS_OSCINP_INFO_HKEY_COUNT, #SCS_OSCINP_INFO_GET_HKEY,
               #SCS_OSCINP_INFO_PRODUCT, #SCS_OSCINP_INFO_CUE_FILE, #SCS_OSCINP_INFO_TITLE
            ; debugMsg(sProcName, ">> \sOSCPathOriginal=" + \sOSCPathOriginal)
            ; debugMsg(sProcName, ">> \sOSCPath=" + \sOSCPath)
            processOSCInfoRequest(nNetworkControlPtr, nCmd, nNumber, \sOSCPathOriginal)
            
          Case #SCS_OSCINP_PROD_GET_TITLE
            processOSCProdRequest(nNetworkControlPtr, nCmd)
            
          Case #SCS_OSCINP_CUE_GET_ITEMS_N, #SCS_OSCINP_CUE_GET_ITEMS_X
            processOSCCueGetItems(nNetworkControlPtr, nCmd, nNumber, sCue, UCase(Trim(sString)), bHideTracing)
            
          Case #SCS_OSCINP_CUE_GET_LENGTH, #SCS_OSCINP_CUE_GET_NAME, #SCS_OSCINP_CUE_GET_PAGE, #SCS_OSCINP_CUE_GET_POS, #SCS_OSCINP_CUE_GET_STATE, #SCS_OSCINP_CUE_GET_TYPE, #SCS_OSCINP_CUE_GET_COLORS, #SCS_OSCINP_CUE_GET_WHEN_REQD
            processOSCCueRequest(nNetworkControlPtr, nCmd, sCue, nNumber, bHideTracing)
          Case #SCS_OSCINP_CUE_SET_POS
            processOSCCueRequest(nNetworkControlPtr, nCmd, sCue, nNumber, bHideTracing)
            bEchoCommandIfReqd = #True
            
          Case #SCS_OSCINP_FADER_GET_MASTER, #SCS_OSCINP_FADER_GET_MASTER_PERCENT
            processOSCFaderRequest(nNetworkControlPtr, nCmd)
          Case #SCS_OSCINP_FADER_SET_MASTER, #SCS_OSCINP_FADER_SET_MASTER_RELATIVE
            processOSCFaderRequest(nNetworkControlPtr, nCmd, fFloat)
            bEchoCommandIfReqd = #True
          Case #SCS_OSCINP_FADER_SET_MASTER_PERCENT
            processOSCFaderRequest(nNetworkControlPtr, nCmd, 0, nNumber)
            bEchoCommandIfReqd = #True
            
          Case #SCS_OSCINP_FADER_GET_DEVICE, #SCS_OSCINP_FADER_GET_DEVICE_PERCENT
            processOSCFaderRequest(nNetworkControlPtr, nCmd)
          Case #SCS_OSCINP_FADER_SET_DEVICE, #SCS_OSCINP_FADER_SET_DEVICE_RELATIVE
            processOSCFaderRequest(nNetworkControlPtr, nCmd, fFloat, 0, sAudioDevice)
            bEchoCommandIfReqd = #True
          Case #SCS_OSCINP_FADER_SET_DEVICE_PERCENT
            processOSCFaderRequest(nNetworkControlPtr, nCmd, 0, nNumber, sAudioDevice)
            bEchoCommandIfReqd = #True
            
          Case #SCS_OSCINP_FILE_OPEN
            FMB_openCueFile(sFMBFileName, sFMBCue)
          Case #SCS_OSCINP_SET_PLAYORDER
            FMB_setPlayOrder(nNetworkControlPtr)
            
          Case #SCS_OSCINP_CTRL_OPEN_NEXT_CUES
            ; debugMsg(sProcName, "calling samAddRequest(SCS_SAM_OPEN_NEXT_CUES, " + nCuePtr + "(" + getCueLabel(nCuePtr) + "))")
            samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, nCuePtr)
            
          Case #SCS_OSCINP_X32_CONFIG_NAME
            processOSCConfigName(nNetworkControlPtr, sPath, sConfigName)
            
        EndSelect
        If bQuiet = #False
          WMN_setStatusField(sMsg)
        EndIf
        If bEchoCommandIfReqd
          If \bRAIDev
            echoReceivedData(nNetworkControlPtr, bHideTracing)
          EndIf
          bEchoCommandIfReqd = #False
        EndIf
        
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure.s getNetworkInfo()
  PROCNAMEC()
  Protected sInfo.s
  
  If gnNetworkCueControlPtr >= 0
    ; sInfo = "Network Control Enabled (SCS is " + gaNetworkControl(gnNetworkCueControlPtr)\sNetworkDevDesc + ")"
    sInfo = LangPars("Network", "NWCtrlEnabled", gaNetworkControl(gnNetworkCueControlPtr)\sNetworkDevDesc)
  EndIf
  ProcedureReturn sInfo
EndProcedure

Procedure getNetworkControlPtrForNetworkDevDesc(nDevType, sNetworkDevDesc.s, bDummy)
  PROCNAMEC()
  Protected m
  Protected nNetworkControlPtr
  
  nNetworkControlPtr = -1
  If Trim(sNetworkDevDesc) Or bDummy
    For m = 0 To ArraySize(gaNetworkControl())
      With gaNetworkControl(m)
        debugMsg(sProcName, "gaNetworkControl(" + m + ")\nDevType=" + decodeDevType(\nDevType) + ", \sNetworkDevDesc=" + \sNetworkDevDesc + ", \bNWDummy=" + strB(\bNWDummy))
        If \nDevType = nDevType
          If (\bNWDummy And bDummy) Or UCase(\sNetworkDevDesc) = UCase(sNetworkDevDesc)
            nNetworkControlPtr = m
            Break
          EndIf
        EndIf
      EndWith
    Next m
  EndIf
  If nNetworkControlPtr = -1
    debugMsg(sProcName, "nDevType=" + decodeDevType(nDevType) + ", sNetworkDevDesc=" + #DQUOTE$ + sNetworkDevDesc + #DQUOTE$ + ", bDummy=" + strB(bDummy) + ", returning " + nNetworkControlPtr)
  EndIf
  ProcedureReturn nNetworkControlPtr
EndProcedure

Procedure getNetworkControlPtrForDevNo(nDevType, nDevNo)
  PROCNAMEC()
  Protected m
  Protected nNetworkControlPtr
  
  nNetworkControlPtr = -1
  For m = 0 To ArraySize(gaNetworkControl())
    With gaNetworkControl(m)
      If \nDevType = nDevType
        If \nDevNo = nDevNo
          nNetworkControlPtr = m
          Break
        EndIf
      EndIf
    EndWith
  Next m
  If nNetworkControlPtr = -1
    debugMsg(sProcName, "nDevType=" + decodeDevType(nDevType) + ", nDevNo=" + nDevNo + ", nNetworkControlPtr=" + nNetworkControlPtr)
  EndIf
  ProcedureReturn nNetworkControlPtr
EndProcedure

Procedure getNetworkControlPtrForServerConnection(nServerConnection)
  PROCNAMEC()
  Protected m
  Protected nNetworkControlPtr
  
  nNetworkControlPtr = -1
  For m = 0 To ArraySize(gaNetworkControl())
    With gaNetworkControl(m)
      If \nServerConnection = nServerConnection
        nNetworkControlPtr = m
        Break
      EndIf
    EndWith
  Next m
  If nNetworkControlPtr = -1
    debugMsg(sProcName, "nServerConnection=" + decodeHandle(nServerConnection) + ", nNetworkControlPtr=" + nNetworkControlPtr)
  EndIf
  ProcedureReturn nNetworkControlPtr
EndProcedure

Procedure getNetworkControlPtrForClientConnection(nClientConnection, bDummy)
  PROCNAMEC()
  Protected m
  Protected nNetworkControlPtr
  
  nNetworkControlPtr = -1
  For m = 0 To ArraySize(gaNetworkControl())
    With gaNetworkControl(m)
      If (\nClientConnection = nClientConnection) Or (\bNWDummy And bDummy)
        nNetworkControlPtr = m
        Break
      EndIf
    EndWith
  Next m
  If nNetworkControlPtr = -1
    debugMsg(sProcName, "nClientConnection=" + decodeHandle(nClientConnection) + ", bDummy=" + strB(bDummy) + ", nNetworkControlPtr=" + nNetworkControlPtr)
  EndIf
  ProcedureReturn nNetworkControlPtr
EndProcedure

Procedure getNetworkControlPtrForServerAndClientConnection(nServerConnection, nClientConnection, bFMEvent=#False)
  PROCNAMEC()
  Protected m, nNetworkControlPtr, sClientIP.s, nClientPort
  
  nNetworkControlPtr = -1
  For m = 0 To ArraySize(gaNetworkControl())
    With gaNetworkControl(m)
      If (\nServerConnection = nServerConnection) And (\nClientConnection = nClientConnection)
        nNetworkControlPtr = m
        Break
      EndIf
    EndWith
  Next m
  
  ; If (nNetworkControlPtr = -1) And (grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY) And (bFMEvent)
  If (nNetworkControlPtr = -1) And (grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY Or grFMOptions\nFunctionalMode = #SCS_FM_BACKUP) And (bFMEvent)
    sClientIP = IPString(GetClientIP(nClientConnection))
    nClientPort = GetClientPort(nClientConnection)
    debugMsg(sProcName, "nClientConnection=" + nClientConnection + ", sClientIP=" + sClientIP + ", nClientPort=" + nClientPort + ", grFMOptions\nFMClientId=" + grFMOptions\nFMClientId)
    For m = 0 To ArraySize(gaNetworkControl())
      With gaNetworkControl(m)
        debugMsg(sProcName, "gaNetworkControl(" + m + ")\sClientIP=" + \sClientIP + ", \nClientPort=" + \nClientPort + ", \bSCSBackupDev=" + strB(\bSCSBackupDev))
        If (\sClientIP = sClientIP) And (\bSCSBackupDev)
          ; found match of IP address and port, so assume previous SCS client instance was closed and a new SCS client instance has been started
          ; which means we can use the same gaNetworkControl() entry - just need to change the \nClientConnection
          debugMsg(sProcName, "changing gaNetworkControl(" + m + ")\nClientConnection from " + \nClientConnection + " to " + nClientConnection)
          \nClientConnection = nClientConnection
          nNetworkControlPtr = m
          Break
        EndIf
      EndWith
    Next m
  EndIf
  
  If nNetworkControlPtr = -1
    debugMsg(sProcName, "nServerConnection=" + decodeHandle(nServerConnection) + ", nClientConnection=" + decodeHandle(nClientConnection) + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bFMEvent=" + strB(bFMEvent))
  EndIf
  ProcedureReturn nNetworkControlPtr
EndProcedure

Procedure initNetworkControl()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)

  For n = 0 To ArraySize(gaNetworkControl())
    gaNetworkControl(n) = grNetworkControlDef
    debugMsg(sProcName, "gaNetworkControl(" + n + ")\nOpenConnectionTimeout=" + gaNetworkControl(n)\nOpenConnectionTimeout)
  Next n
  gnMaxNetworkControl = -1
  
  gnNetworkCueControlPtr = -1
  With grEditMem
    \nLastEntryMode = #SCS_ENTRYMODE_ASCII
    \bLastAddCR = #True
    \bLastAddLF = #False
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure initNetworkDevice(nNetworkControlPtr, nDevType, bInDevChgs=#False, nDevForDevCheckerIndex=-1)
  PROCNAMEC()
  Protected bInitResult, bDevNotInitialized
  Protected bRealNetworkReqd
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nDevType=" + decodeDevType(nDevType) + ", bInDevChgs=" + strB(bInDevChgs) + ", nDevForDevCheckerIndex=" + nDevForDevCheckerIndex)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If \bNWIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
        debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNWIgnoreDevThisRun=#True")
        bInitResult = #True
        
      ElseIf \bNWDummy
        debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNWDummy=#True")
        bInitResult = #True
        
      ElseIf nDevType = #SCS_DEVTYPE_CC_NETWORK_IN And grSession\nNetworkInEnabled <> #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nNetworkInEnabled=" + grSession\nNetworkInEnabled)
        bInitResult = #True
        
      ElseIf nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grSession\nNetworkOutEnabled <> #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nNetworkOutEnabled=" + grSession\nNetworkOutEnabled)
        bInitResult = #True
        
      ; ElseIf nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And \nNetworkProtocol = #SCS_NETWORK_PR_TCP And \bConnectWhenReqd ; Added 22Sep2022 11.9.6
      ElseIf nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And \bConnectWhenReqd ; Added 22Sep2022 11.9.6
        debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bConnectWhenReqd=" + strB(\bConnectWhenReqd))
        bInitResult = #False
        
      Else
        Select \nNetworkRole
          Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT, #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            bRealNetworkReqd = #True
        EndSelect
        If bRealNetworkReqd = #False
          bInitResult = #True
        ElseIf \bConnectWhenReqd ; Test added 7Feb2024 11.10.2af
          debugMsg(sProcName, "bypass opening as \bConnectWhenReqd=#True")
          bInitResult = #True
          bDevNotInitialized = #True
        Else
          debugMsg(sProcName, "calling openNetworkPortIfReqd(" + nNetworkControlPtr + ", " + strB(bInDevChgs) + ", " + nDevForDevCheckerIndex + ")")
          bInitResult = openNetworkPortIfReqd(nNetworkControlPtr, bInDevChgs, nDevForDevCheckerIndex)
        EndIf
      EndIf
      If bInitResult And bDevNotInitialized = #False
        Select \nNetworkRole
          Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            If \nClientConnection
              \bNetworkDevInitialized = #True
              debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
            EndIf
          Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            If \nServerConnection
              \bNetworkDevInitialized = #True
              debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
            EndIf
        EndSelect
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bInitResult))
  ProcedureReturn bInitResult
  
EndProcedure

Procedure.s sendNetworkMessage(nNetworkControlPtr, pMsg.s, bIgnoreReadyState=#False, nStringFormat=#PB_Ascii)
  PROCNAMEC()
  Protected sMyConnection.s
  Protected nMode, sMode.s, sMsgSuffix.s
  Protected nBytesSent
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", pMsg=" + stringToNetworkString(pMsg) + ; " ($" + stringToHexString(pMsg) + ")" +
                      ", bIgnoreReadyState=" + strB(bIgnoreReadyState) + ", nStringFormat=" + decodeFormat(nStringFormat))
  
  If (Len(pMsg) = 0) Or (nNetworkControlPtr < 0)
    ProcedureReturn ""
  EndIf
  
  sMyConnection = #SCS_NETWORK_CONNECTION_NOT_OPEN
  With gaNetworkControl(nNetworkControlPtr)
    If \bNWDummy
      sMyConnection = \sNetworkDevDesc
      
    ElseIf \bNWIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
      sMyConnection = \sNetworkDevDesc
      
    Else
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
      Select \nNetworkRole
        Case #SCS_ROLE_DUMMY
          sMyConnection = \sNetworkDevDesc
          
        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
          debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection) + ", \bClientConnectionLive=" + strB(\bClientConnectionLive))
          If (\nClientConnection) Or (\bClientConnectionLive = #False)
            If \bClientConnectionLive = #False
              If \nClientConnection
                CloseNetworkConnection(\nClientConnection)
                debugMsg(sProcName, "CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
                freeHandle(\nClientConnection)
                \nClientConnection = 0
                debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection))
              EndIf
              \bNetworkDevInitialized = #False
              debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
              If \nNetworkProtocol = #SCS_NETWORK_PR_UDP
                nMode = #PB_Network_UDP
                sMode = "#PB_Network_UDP"
              Else
                nMode = #PB_Network_TCP
                sMode = "#PB_Network_TCP"
              EndIf
              debugMsg(sProcName, "calling OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", " + sMode +", " + \nOpenConnectionTimeout + ")")
              \nClientConnection = OpenNetworkConnection(\sRemoteHost, \nRemotePort, nMode, \nOpenConnectionTimeout)
              debugMsg2(sProcName, "OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", " + sMode +", " + \nOpenConnectionTimeout + ")", \nClientConnection)
              If \nClientConnection
                newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nClientConnection)
                \bNetworkDevInitialized = #True
                debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
                \bClientConnectionLive = #True
                If \bClientConnectionNeedsReady
                  \bClientConnectionReady = #False
                Else
                  \bClientConnectionReady = #True
                EndIf
              EndIf
            EndIf
            debugMsg(sProcName, "\bClientConnectionLive=" + strB(\bClientConnectionLive) + ", \bClientConnectionReady=" + strB(\bClientConnectionReady) + ", bIgnoreReadyState=" + strB(bIgnoreReadyState))
            If \bClientConnectionLive
              ; added 7Oct2019 11.8.2as following problem reported by Guy Jackson about an Epson projector not responding to SCS commands
              If \nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJLINK Or \nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJNET
                If Len(pMsg) > 2
                  If Right(pMsg,1) <> #CR$
                    sMsgSuffix = #CR$
                  EndIf
                EndIf
              EndIf
              ; end added 7Oct2019 11.8.2as
              If (\bClientConnectionReady) Or (bIgnoreReadyState)
                debugMsg(sProcName, "Calling SendNetworkStringAscii(" + decodeHandle(\nClientConnection) + ", pMsg+sMsgSuffix, #True, " + nStringFormat + ")")
                SendNetworkStringAscii(\nClientConnection, pMsg + sMsgSuffix, #True, nStringFormat) ; sMsgSuffix added 7Oct2019 11.8.2as ; nStringFormat added 14Apr2020 11.8.2.3ar
                sMyConnection = \sRemoteHost + ":" + \nRemotePort
              Else
                If \nCountSendWhenReady > ArraySize(\aSendWhenReady())
                  REDIM_ARRAY(\aSendWhenReady, \nCountSendWhenReady, grSendWhenReadyDef, "\aSendWhenReady()")
                EndIf
                \aSendWhenReady(\nCountSendWhenReady)\sSWRSendWhenReady = pMsg + sMsgSuffix
                \aSendWhenReady(\nCountSendWhenReady)\nSWRStringFormat = nStringFormat
                debugMsg(sProcName, "\aSendWhenReady(" + \nCountSendWhenReady + ")\sSWRSendWhenReady=" + stringToNetworkString(\aSendWhenReady(\nCountSendWhenReady)\sSWRSendWhenReady))
                \nCountSendWhenReady + 1
                sMyConnection = \sRemoteHost + ":" + \nRemotePort
              EndIf
            Else
              ; sMyConnection = "Failed to send message to " + \sRemoteHost + ":" + \nRemotePort
              ; 19/01/2015: commented out the above because playSubtypeM() needs sendNetwork() to reply blank or #SCS_NETWORK_CONNECTION_NOT_OPEN if no message is sent
            EndIf
          EndIf
          
        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
          debugMsg(sProcName, "\nServerConnection=" + decodeHandle(\nServerConnection) + ", \nClientConnection=" + decodeHandle(\nClientConnection) + ", \sClientIP=" + \sClientIP + ", \nClientPort=" + \nClientPort)
          If \nServerConnection
            If \nClientConnection
              debugMsg(sProcName, "Calling SendNetworkStringAscii(" + decodeHandle(\nClientConnection) + ", pMsg, #True, " + decodeStringFormat(nStringFormat) + ")")
              SendNetworkStringAscii(\nClientConnection, pMsg, #True, nStringFormat) ; nStringFormat added 14Apr2020 11.8.2.3ar
              sMyConnection = \sClientIP + ":" + \nClientPort
            EndIf
          EndIf
          
      EndSelect
    EndIf
  EndWith

  debugMsg(sProcName, "returning " + sMyConnection)
  ProcedureReturn sMyConnection
EndProcedure

Procedure sendWaitingNetworkMsgs(nNetworkControlPtr, bFirstWaitingMsgSent=#False)
  PROCNAMEC()
  Protected n, nStartIndex
  
  If bFirstWaitingMsgSent
    nStartIndex = 1
  EndIf
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If (\nClientConnection) And (\bClientConnectionReady)
        For n = nStartIndex To (\nCountSendWhenReady-1)
          If \aSendWhenReady(n)\sSWRSendWhenReady
            debugMsg(sProcName, "Calling SendNetworkStringAscii(" + decodeHandle(\nClientConnection) +
                                #DQUOTE$ + \aSendWhenReady(n)\sSWRSendWhenReady + #DQUOTE$ + ", #True, " + decodeStringFormat(\aSendWhenReady(n)\nSWRStringFormat) + ")")
            SendNetworkStringAscii(\nClientConnection, \aSendWhenReady(n)\sSWRSendWhenReady, #True, \aSendWhenReady(n)\nSWRStringFormat) ; Added \nStringFormatForSendWhenReady(n) 14Apr2020 11.8.2.3ar
          ElseIf \aSendWhenReady(n)\nSWRSubPtr >= 0
            debugMsg(sProcName, "calling sendNetworkDataMessage(" + nNetworkControlPtr + ", " + getSubLabel(\aSendWhenReady(n)\nSWRSubPtr) + ", " + \aSendWhenReady(n)\nSWRCtrlSendIndex + ", #True)")
            sendNetworkDataMessage(nNetworkControlPtr, \aSendWhenReady(n)\nSWRSubPtr, \aSendWhenReady(n)\nSWRCtrlSendIndex, #True)
          EndIf
        Next n
        \nCountSendWhenReady = 0
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure startNetwork(nNetworkControlPtr=-1, bInDevChgs=#False, nDevForDevCheckerIndex=-1)
  PROCNAMEC()
  Protected n
  Protected sStatusField.s
  Protected nOpenInCount
  Protected bStartThreadEtc
  Protected nFirstNetworkControlPtr, nLastNetworkControlPtr

  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bInDevChgs=" + strB(bInDevChgs) + ", nDevForDevCheckerIndex=" + nDevForDevCheckerIndex +
                      ", gbInApplyDevChanges=" + strB(gbInApplyDevChanges))
  
  gnNetworkCurrentIndex = -1
  gbReadingNetworkMessage = #False
  
  If nNetworkControlPtr = -1
    nFirstNetworkControlPtr = 0
    nLastNetworkControlPtr = gnMaxNetworkControl
  Else
    nFirstNetworkControlPtr = nNetworkControlPtr
    nLastNetworkControlPtr = nNetworkControlPtr
  EndIf
  
  setNetworkEnabled(bInDevChgs)
  For n = nFirstNetworkControlPtr To nLastNetworkControlPtr
    With gaNetworkControl(n)
      debugMsg(sProcName, "gaNetworkControl(" + n + ")\nDevType=" + decodeDevType(\nDevType) + ", \bNWDummy=" + strB(\bNWDummy) + ", \bNWIgnoreDevThisRun=" + strB(\bNWIgnoreDevThisRun))
      Select \nDevType
        Case #SCS_DEVTYPE_CC_NETWORK_IN
          If \bNWDummy
            bStartThreadEtc = #True
          ElseIf \bRAIDev
            If grRAIOptions\bRAIEnabled
              If \nServerConnection = 0
                debugMsg(sProcName, "calling RAI_Init()")
                RAI_Init()
                bStartThreadEtc = #True
              EndIf
            EndIf
          ElseIf grSession\nNetworkInEnabled = #SCS_DEVTYPE_ENABLED
            debugMsg(sProcName, "calling initNetworkDevice(" + n + ", #SCS_DEVTYPE_CC_NETWORK_IN, " + strB(bInDevChgs) + ", " + nDevForDevCheckerIndex + ")")
            If initNetworkDevice(n, #SCS_DEVTYPE_CC_NETWORK_IN, bInDevChgs, nDevForDevCheckerIndex)
              nOpenInCount + 1
              bStartThreadEtc = #True
            EndIf
          EndIf
          
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          If \bNWDummy
            bStartThreadEtc = #True
            ; added 27Apr2017 11.6.1at
            Select \nCtrlNetworkRemoteDev
              Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                debugMsg(sProcName, "calling getX32Data(" + n + ")")
                ; note that although getX32Data() cannot get anything from a dummy X32, the procedure will populate arrays with fixed data, such as mute groups and channels
                getX32Data(n)
            EndSelect
            ; end added 27Apr2017 11.6.1at
          ElseIf grSession\nNetworkOutEnabled = #SCS_DEVTYPE_ENABLED
            If gbInApplyDevChanges  ; Test added 9Feb2024 11.10.2aj
              If \bConnectWhenReqd And \bNetworkDevInitialized
                debugMsg(sProcName, "calling closeANetworkConnection(" + n + ")")
                closeANetworkConnection(n)
              Else
                debugMsg(sProcName, "calling initNetworkDevice(" + n + ", #SCS_DEVTYPE_CS_NETWORK_OUT, " + strB(bInDevChgs) + ", " + nDevForDevCheckerIndex + ")")
                If initNetworkDevice(n, #SCS_DEVTYPE_CS_NETWORK_OUT, bInDevChgs, nDevForDevCheckerIndex)
                  bStartThreadEtc = #True
                EndIf
              EndIf
            Else
              debugMsg(sProcName, "calling initNetworkDevice(" + n + ", #SCS_DEVTYPE_CS_NETWORK_OUT, " + strB(bInDevChgs) + ", " + nDevForDevCheckerIndex + ")")
              If initNetworkDevice(n, #SCS_DEVTYPE_CS_NETWORK_OUT, bInDevChgs, nDevForDevCheckerIndex)
                bStartThreadEtc = #True
              EndIf
            EndIf
          EndIf
          
      EndSelect
      
    EndWith
  Next n
  
  If gnMaxNetworkControl >= 0
    listNetworkControl()
  EndIf
  
  If nNetworkControlPtr = -1
    If nOpenInCount > 0
      sStatusField = RTrim(" " + getMidiInfo() + " " + RTrim(getRS232Info() + " " + RTrim(DMX_getDMXInfo() + " " + getNetworkInfo())))
      If Len(sStatusField) > 0
        WMN_setStatusField(sStatusField, #SCS_STATUS_WARN, 2500, #True)
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "bStartThreadEtc=" + strB(bStartThreadEtc))
  If bStartThreadEtc
    gbNetworkStarted = #True
    debugMsg(sProcName, "calling setX32CueControl()")
    setX32CueControl()
    If THR_getThreadState(#SCS_THREAD_NETWORK) <> #SCS_THREAD_STATE_ACTIVE
      debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_NETWORK)")
      THR_createOrResumeAThread(#SCS_THREAD_NETWORK)
      THR_waitForAThreadToBeCreated(#SCS_THREAD_NETWORK)
    EndIf
    debugMsg(sProcName, "gnNetworkServersActive=" + gnNetworkServersActive + ", gnNetworkClientsActive=" + gnNetworkClientsActive + ", gnNetworkResponseCount=" + gnNetworkResponseCount)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure closeNetwork(bIncludeRAI=#True, bIncludeFM=#True)
  ; Added bIncludeFM 16Aug2021 11.8.5.1aa
  PROCNAMEC()
  Protected n, n2
  Protected bCloseThisConnection, bKeepNetworkStarted
  Protected nThisClientConnection, nThisServerConnection
  
  debugMsg(sProcName, #SCS_START + ", bIncludeRAI=" + strB(bIncludeRAI) + ", bIncludeFM=" + strB(bIncludeFM))
  
  If grX32CueControl\nX32ClientConnection
    debugMsg(sProcName, "grX32CueControl\nX32ClientConnection=" + decodeHandle(grX32CueControl\nX32ClientConnection))
    grX32CueControl\nX32ClientConnection = 0
    Delay(100)  ; make sure any existing /xremote command sent to the X32 by THR_runNetworkThread() has time to complete before closing the connection
  EndIf
  
  debugMsg(sProcName, "calling listNetworkControl()")
  listNetworkControl()
  
  For n = 0 To gnMaxNetworkControl
    ; debugMsg(sProcName, "n=" + n)
    bCloseThisConnection = #True
    If bIncludeRAI = #False
      If (n = grRAI\nNetworkControlPtr1) Or (n = grRAI\nNetworkControlPtr2) Or (n = grRAI\nNetworkControlPtr3)
        bCloseThisConnection = #False
        bKeepNetworkStarted = #True
      EndIf
    EndIf
    ; Added 16Aug2021 11.8.5.1aa
    If bIncludeFM
      If n = grFMOptions\nFMClientNetworkControlPtr
        bCloseThisConnection = #False
        bKeepNetworkStarted = #True
      EndIf
    EndIf
    ; End added 16Aug2021 11.8.5.1aa
    If bCloseThisConnection
      If gaNetworkControl(n)\nUseNetworkControlPtr < 0
        nThisClientConnection = gaNetworkControl(n)\nClientConnection
        If nThisClientConnection
          ; close this network connection and all references to it
          debugMsg(sProcName, "calling CloseNetworkConnection(" + decodeHandle(nThisClientConnection) + ")")
          CloseNetworkConnection(nThisClientConnection)
          debugMsg(sProcName, "CloseNetworkConnection(" + decodeHandle(nThisClientConnection) + ")")
          For n2 = 0 To gnMaxNetworkControl
            With gaNetworkControl(n2)
              If \nClientConnection = nThisClientConnection
                gaNetworkControl(n2) = grNetworkControlDef
              EndIf
            EndWith
          Next n2
          freeHandle(nThisClientConnection)
        EndIf
      EndIf
      
      nThisServerConnection = gaNetworkControl(n)\nServerConnection
      If nThisServerConnection
        ; close this server connection and all references to it
        debugMsg(sProcName, "calling CloseNetworkServer(" + decodeHandle(nThisServerConnection) + ")")
        CloseNetworkServer(nThisServerConnection)
        debugMsg(sProcName, "CloseNetworkServer(" + decodeHandle(nThisServerConnection) + ")")
        gaNetworkControl(n)\bNetworkDevInitialized = #False
        debugMsg(sProcName, "gaNetworkControl(" + n + ")\bNetworkDevInitialized=" + strB(gaNetworkControl(n)\bNetworkDevInitialized))
        gnNetworkServersActive - 1
        For n2 = 0 To gnMaxNetworkControl
          With gaNetworkControl(n2)
            If \nServerConnection = nThisServerConnection
              gaNetworkControl(n2) = grNetworkControlDef
            EndIf
          EndWith
        Next n2
        With grRAI
          If \nServerConnection1 = nThisServerConnection
            \nServerConnection1 = 0
            If \nClientConnection1
              freeHandle(\nClientConnection1)
              \nClientConnection1 = 0
            EndIf
          ElseIf \nServerConnection2 = nThisServerConnection
            \nServerConnection2 = 0
            If \nClientConnection2
              freeHandle(\nClientConnection2)
              \nClientConnection2 = 0
            EndIf
          ElseIf \nServerConnection3 = nThisServerConnection
            \nServerConnection3 = 0
            If \nClientConnection3
              freeHandle(\nClientConnection3)
              \nClientConnection3 = 0
            EndIf
          EndIf
        EndWith
        freeHandle(nThisServerConnection)
      EndIf
      
    EndIf ; EndIf bCloseThisConnection
    
  Next n
  
  If bKeepNetworkStarted = #False
    gbNetworkStarted = #False
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getBlankNetworkControlEntry()
  PROCNAMEC()
  Protected nNetworkControlPtr
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", gnMaxNetworkControl=" + gnMaxNetworkControl)
  
  nNetworkControlPtr = -1
  For n = 0 To gnMaxNetworkControl
    ; debugMsg(sProcName, "gaNetworkControl(" + n + ")\bControlExists=" + strB(gaNetworkControl(n)\bControlExists))
    If gaNetworkControl(n)\bControlExists = #False
      nNetworkControlPtr = n
      Break
    EndIf
  Next n
  ; debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr)
  If nNetworkControlPtr < 0
    nNetworkControlPtr = gnMaxNetworkControl + 1
    If nNetworkControlPtr > ArraySize(gaNetworkControl())
      REDIM_ARRAY(gaNetworkControl, nNetworkControlPtr, grNetworkControlDef, "gaNetworkControl()")
    EndIf
    gnMaxNetworkControl = nNetworkControlPtr
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning nNetworkControlPtr=" + nNetworkControlPtr)
  ProcedureReturn nNetworkControlPtr
  
EndProcedure

Procedure setUseNetworkControlPtrs()
  PROCNAMEC()
  Protected nUseNetworkControlPtr
  Protected n1, n2
  
  debugMsg(sProcName, #SCS_START + ", gnMaxNetworkControl=" + gnMaxNetworkControl)
  
  For n1 = gnMaxNetworkControl To 0 Step -1
    nUseNetworkControlPtr = -1
    For n2 = 0 To (n1 - 1)
      With gaNetworkControl(n2)
        If (\bControlExists) And (\bNWDummy = #False) And (\bNWIgnoreDevThisRun = #False) ; added \bNWIgnoreDevThisRun 16Mar2020 11.8.2.3aa
          If (\nNetworkProtocol = gaNetworkControl(n1)\nNetworkProtocol) And (\nNetworkRole = gaNetworkControl(n1)\nNetworkRole) ; And (\nDevType = gaNetworkControl(n1)\nDevType) ; Added \nDevType test 13Jan2022 11.9.0aj
            ; Added the following test 16Dec2023 11.10.0dp
            If gaNetworkControl(n1)\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN And \bConnectWhenReqd
              ; ignore (prevent a network cue control device 'using' a matching control send device if that control send device is marked as 'connect when required')
            Else
              Select \nNetworkRole
                Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                  If (\sRemoteHost = gaNetworkControl(n1)\sRemoteHost) And (\nRemotePort = gaNetworkControl(n1)\nRemotePort)
                    nUseNetworkControlPtr = n2
                    Break
                  EndIf
                Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                  If (\nLocalPort = gaNetworkControl(n1)\nLocalPort)
                    nUseNetworkControlPtr = n2
                    Break
                  EndIf
              EndSelect
            EndIf
          EndIf
        EndIf
      EndWith
    Next n2
    gaNetworkControl(n1)\nUseNetworkControlPtr = nUseNetworkControlPtr
    debugMsg(sProcName, "gaNetworkControl(" + n1 + ")\nUseNetworkControlPtr=" + gaNetworkControl(n1)\nUseNetworkControlPtr)
  Next n1
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadNetworkControl(bUseDevChgs)
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapId
  Protected d, d2
  Protected nNetworkControlPtr
  Protected n, m
  Protected nDevGrp, nDevType, sLogicalDev.s
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", bUseDevChgs=" + strB(bUseDevChgs))
  
  If bUseDevChgs
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
    EndIf
    debugMsg(sProcName, "CtrlSend ----------------")
    For d = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
      nDevGrp = #SCS_DEVGRP_CTRL_SEND
      nDevType = grProdForDevChgs\aCtrlSendLogicalDevs(d)\nDevType
      sLogicalDev = grProdForDevChgs\aCtrlSendLogicalDevs(d)\sLogicalDev
      Select nDevType
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          nNetworkControlPtr = -1
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, nDevGrp, sLogicalDev)
          If nDevMapDevPtr >= 0
            nNetworkControlPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
          EndIf
          If nNetworkControlPtr < 0
            debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
            nNetworkControlPtr = getBlankNetworkControlEntry()
          EndIf
          If nNetworkControlPtr >= 0
            With gaNetworkControl(nNetworkControlPtr)
              \bControlExists = #True
              \nDevType = nDevType
              \nDevNo = d
              \sLogicalDev = sLogicalDev
              \nDevMapDevPtr = nDevMapDevPtr
              \nDevMapId = nDevMapId
              \nCtrlNetworkRemoteDev = grProdForDevChgs\aCtrlSendLogicalDevs(d)\nCtrlNetworkRemoteDev
              \nNetworkProtocol = grProdForDevChgs\aCtrlSendLogicalDevs(d)\nNetworkProtocol
              \nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(d)\nNetworkRole
              Select \nCtrlNetworkRemoteDev
                Case #SCS_CS_NETWORK_REM_OSC_OTHER
                  \nOSCVersion = grProdForDevChgs\aCtrlSendLogicalDevs(d)\nOSCVersion
                Default
                  \nOSCVersion = grCtrlSendLogicalDevsDef\nOSCVersion
              EndSelect
              \sCtrlNetworkRemoteDevPassword = grProdForDevChgs\aCtrlSendLogicalDevs(d)\sCtrlNetworkRemoteDevPassword
              \bConnectWhenReqd = grProdForDevChgs\aCtrlSendLogicalDevs(d)\bConnectWhenReqd ; Added 22Sep2022 11.9.6
              If nDevMapDevPtr >= 0
                \sRemoteHost = grMapsForDevChgs\aDev(nDevMapDevPtr)\sRemoteHost
                \nRemotePort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort
                \nLocalPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort
                \bNWDummy = grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
                \bNWIgnoreDevThisRun = grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
                \nCtrlSendDelay = grMapsForDevChgs\aDev(nDevMapDevPtr)\nCtrlSendDelay
                buildNetworkDevDesc(@gaNetworkControl(nNetworkControlPtr))
                grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev = \sNetworkDevDesc
                grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr = nNetworkControlPtr
                grMapsForDevChgs\aDev(nDevMapDevPtr)\bConnectWhenReqd = \bConnectWhenReqd ; Added 22Sep2022 11.9.6
              EndIf
            EndWith
            ; added 6Nov2018 11.8.0aq or gnMaxNetworkControl could remain on -1, which could then cause the first remoate app network connection to overwrite the existing first entry in the array gaNetworkControl()
            If nNetworkControlPtr > gnMaxNetworkControl
              gnMaxNetworkControl = nNetworkControlPtr
            EndIf
            ; end added 6Nov2018 11.8.0aq
          EndIf
      EndSelect
    Next d
    
    debugMsg(sProcName, "CueCtrl ----------------")
    For d = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
      nDevGrp = #SCS_DEVGRP_CUE_CTRL
      nDevType = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDevType
      sLogicalDev = grProdForDevChgs\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
      Select nDevType
        Case #SCS_DEVTYPE_CC_NETWORK_IN
          nNetworkControlPtr = -1
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, nDevGrp, sLogicalDev)
          If nDevMapDevPtr >= 0
            nNetworkControlPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
          EndIf
          If nNetworkControlPtr < 0
            debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
            nNetworkControlPtr = getBlankNetworkControlEntry()
          EndIf
          If nNetworkControlPtr >= 0
            With gaNetworkControl(nNetworkControlPtr)
              \bControlExists = #True
              \nDevType = nDevType
              \nDevNo = d
              \sLogicalDev = sLogicalDev
              \nDevMapDevPtr = nDevMapDevPtr
              \nDevMapId = nDevMapId
              \nCueNetworkRemoteDev = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev
              \nNetworkProtocol = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nNetworkProtocol
              \nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nNetworkRole
              \nOSCVersion = grCueCtrlLogicalDevsDef\nOSCVersion
              If nDevMapDevPtr >= 0
                \sRemoteHost = grMapsForDevChgs\aDev(nDevMapDevPtr)\sRemoteHost
                \nRemotePort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort
                \nLocalPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort
                \bNWDummy = grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
                \bNWIgnoreDevThisRun = grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
                \nCtrlSendDelay = grMapsForDevChgs\aDev(nDevMapDevPtr)\nCtrlSendDelay
                buildNetworkDevDesc(@gaNetworkControl(nNetworkControlPtr))
                grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev = \sNetworkDevDesc
                grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr = nNetworkControlPtr
              EndIf
            EndWith
            ; added 6Nov2018 11.8.0aq or gnMaxNetworkControl could remain on -1, which could then cause the first remote app network connection to overwrite the existing first entry in the array gaNetworkControl()
            If nNetworkControlPtr > gnMaxNetworkControl
              gnMaxNetworkControl = nNetworkControlPtr
            EndIf
            ; end added 6Nov2018 11.8.0aq
          EndIf
      EndSelect
    Next d
    
  Else
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevMapId = grMaps\aMap(nDevMapPtr)\nDevMapId
    EndIf
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      nDevGrp = #SCS_DEVGRP_CTRL_SEND
      nDevType = grProd\aCtrlSendLogicalDevs(d)\nDevType
      sLogicalDev = grProd\aCtrlSendLogicalDevs(d)\sLogicalDev
      Select nDevType
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          nNetworkControlPtr = -1
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, nDevGrp, sLogicalDev)
          debugMsg(sProcName, "getDevMapDevPtrForLogicalDev(@grMaps, " + decodeDevGrp(nDevGrp) + ", " + sLogicalDev + ") returned nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            nNetworkControlPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
            debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr + ", nNetworkControlPtr=" + nNetworkControlPtr)
          EndIf
          If nNetworkControlPtr < 0
            debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
            nNetworkControlPtr = getBlankNetworkControlEntry()
          EndIf
          debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr)
          If nNetworkControlPtr >= 0
            With gaNetworkControl(nNetworkControlPtr)
              \bControlExists = #True
              \nDevType = nDevType
              \nDevNo = d
              \sLogicalDev = sLogicalDev
              \nDevMapDevPtr = nDevMapDevPtr
              \nDevMapId = nDevMapId
              \nCtrlNetworkRemoteDev = grProd\aCtrlSendLogicalDevs(d)\nCtrlNetworkRemoteDev
              \nNetworkProtocol = grProd\aCtrlSendLogicalDevs(d)\nNetworkProtocol
              \nNetworkRole = grProd\aCtrlSendLogicalDevs(d)\nNetworkRole
              Select \nCtrlNetworkRemoteDev
                Case #SCS_CS_NETWORK_REM_OSC_OTHER
                  \nOSCVersion = grProd\aCtrlSendLogicalDevs(d)\nOSCVersion
                Default
                  \nOSCVersion = grCtrlSendLogicalDevsDef\nOSCVersion
              EndSelect
              \sCtrlNetworkRemoteDevPassword= grProd\aCtrlSendLogicalDevs(d)\sCtrlNetworkRemoteDevPassword
              \bConnectWhenReqd = grProd\aCtrlSendLogicalDevs(d)\bConnectWhenReqd ; Added 22Sep2022 11.9.6
              If nDevMapDevPtr >= 0
                \sRemoteHost = grMaps\aDev(nDevMapDevPtr)\sRemoteHost
                \nRemotePort = grMaps\aDev(nDevMapDevPtr)\nRemotePort
                \nLocalPort = grMaps\aDev(nDevMapDevPtr)\nLocalPort
                \bNWDummy = grMaps\aDev(nDevMapDevPtr)\bDummy
                \bNWIgnoreDevThisRun = grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
                \nCtrlSendDelay = grMaps\aDev(nDevMapDevPtr)\nCtrlSendDelay
                buildNetworkDevDesc(@gaNetworkControl(nNetworkControlPtr))
                grMaps\aDev(nDevMapDevPtr)\sPhysicalDev = \sNetworkDevDesc
                grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr = nNetworkControlPtr
                grMaps\aDev(nDevMapDevPtr)\bConnectWhenReqd = \bConnectWhenReqd ; Added 22Sep2022 11.9.6
              EndIf
            EndWith
            ; added 6Nov2018 11.8.0aq or gnMaxNetworkControl could remain on -1, which could then cause the first remoate app network connection to overwrite the existing first entry in the array gaNetworkControl()
            If nNetworkControlPtr > gnMaxNetworkControl
              gnMaxNetworkControl = nNetworkControlPtr
            EndIf
            ; end added 6Nov2018 11.8.0aq
          EndIf
          debugMsg(sProcName, "(OUT) d=" + d + ", nNetworkControlPtr=" + nNetworkControlPtr + ", gnMaxNetworkControl=" + gnMaxNetworkControl)
      EndSelect
    Next d
    
    For d = 0 To grProd\nMaxCueCtrlLogicalDev
      nDevGrp = #SCS_DEVGRP_CUE_CTRL
      nDevType = grProd\aCueCtrlLogicalDevs(d)\nDevType
      sLogicalDev = grProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
      Select nDevType
        Case #SCS_DEVTYPE_CC_NETWORK_IN
          nNetworkControlPtr = -1
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, nDevGrp, sLogicalDev)
          debugMsg(sProcName, "getDevMapDevPtrForLogicalDev(@grMaps, " + decodeDevGrp(nDevGrp) + ", " + sLogicalDev + ") returned nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            nNetworkControlPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
            debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr + ", nNetworkControlPtr=" + nNetworkControlPtr)
          EndIf
          If nNetworkControlPtr < 0
            debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
            nNetworkControlPtr = getBlankNetworkControlEntry()
          EndIf
          debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr)
          If nNetworkControlPtr >= 0
            With gaNetworkControl(nNetworkControlPtr)
              \bControlExists = #True
              \nDevType = nDevType
              \nDevNo = d
              \sLogicalDev = sLogicalDev
              \nDevMapDevPtr = nDevMapDevPtr
              \nDevMapId = nDevMapId
              \nCueNetworkRemoteDev = grProd\aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev
              \nNetworkProtocol = grProd\aCueCtrlLogicalDevs(d)\nNetworkProtocol
              \nNetworkRole = grProd\aCueCtrlLogicalDevs(d)\nNetworkRole
              \nOSCVersion = grCueCtrlLogicalDevsDef\nOSCVersion
              If nDevMapDevPtr >= 0
                \sRemoteHost = grMaps\aDev(nDevMapDevPtr)\sRemoteHost
                \nRemotePort = grMaps\aDev(nDevMapDevPtr)\nRemotePort
                \nLocalPort = grMaps\aDev(nDevMapDevPtr)\nLocalPort
                \bNWDummy = grMaps\aDev(nDevMapDevPtr)\bDummy
                \bNWIgnoreDevThisRun = grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
                \nCtrlSendDelay = grMaps\aDev(nDevMapDevPtr)\nCtrlSendDelay
                buildNetworkDevDesc(@gaNetworkControl(nNetworkControlPtr))
                grMaps\aDev(nDevMapDevPtr)\sPhysicalDev = \sNetworkDevDesc
                grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr = nNetworkControlPtr
              EndIf
            EndWith
            ; added 6Nov2018 11.8.0aq or gnMaxNetworkControl could remain on -1, which could then cause the first remoate app network connection to overwrite the existing first entry in the array gaNetworkControl()
            If nNetworkControlPtr > gnMaxNetworkControl
              gnMaxNetworkControl = nNetworkControlPtr
            EndIf
            ; end added 6Nov2018 11.8.0aq
          EndIf
          debugMsg(sProcName, "(IN) d=" + d + ", nNetworkControlPtr=" + nNetworkControlPtr + ", gnMaxNetworkControl=" + gnMaxNetworkControl)
      EndSelect
    Next d
    
  EndIf
  
  debugMsg(sProcName, "calling setDerivedNetworkFields()")
  setDerivedNetworkFields()
  
  debugMsg(sProcName, "calling setUseNetworkControlPtrs()")
  setUseNetworkControlPtrs()
  
  debugMsg(sProcName, "calling setX32CueControl()")
  setX32CueControl()
  
  debugMsg(sProcName, "calling listNetworkControl()")
  listNetworkControl()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkConnection()
  ; Processes a genuine #PB_NetworkEvent_Connect network server event, and also a pseudo 'connect' event raised on receiving the message /fmh/bcr (backup connection request) from an SCS backup
  ; Note: UDP connections do not raise #PB_NetworkEvent_Connect network server events, which is why the /fmh/bcr message is sent by the backup
  ; See also the PB Help on NetworkServerEvent(), which mentions the UDP limitations.
  PROCNAMEC()
  Protected bRAIEvent, bHideTracing, bFMEvent, bMultipleClientsAllowed, nFMBackupIndex
  Protected sClientIP.s, nClientPort, sMsg.s
  Protected nNetworkControlPtr
  Protected i, j, k, sCue.s, nSubNo, nFirstPlayingAudPtr, nFirstPlayingAudNo, sPlayOrder.s
  
  debugMsg(sProcName, #SCS_START + ", gnEventServer=" + decodeHandle(gnEventServer))
  
  If gnEventServer = grRAI\nServerConnection1
    bRAIEvent = #True
    ; debugMsg(sProcName, "bRAIEvent=" + strB(bRAIEvent))
    bHideTracing = #c_hide_rai_input_tracing
  EndIf
  
  If gnEventServer = grFMOptions\nFMServerId
    bFMEvent = #True
    bMultipleClientsAllowed = #True
    ; debugMsg(sProcName, "bFMEvent=#True")
  EndIf
  
  sClientIP = IPString(GetClientIP(gnEventClient))
  nClientPort = GetClientPort(gnEventClient)
  Select gnEventServer
    Case grRAI\nServerConnection1 ; default port = 58000
      ; debugMsg(sProcName, "grRAIOptions\bRAIEnabled=" + strB(grRAIOptions\bRAIEnabled))
      If grRAIOptions\bRAIEnabled = #False
        sMsg = LangPars("RAI", "RAIDisabled", sClientIP + ":" + nClientPort)
        debugMsg(sProcName, sMsg)
        WMN_setStatusField(sMsg, #SCS_STATUS_WARN, 3000, #True)
        If gbMidiTestWindow
          WMT_addMiscListItem(sMsg)
        EndIf
        CloseNetworkConnection(gnEventClient)
        debugMsg(sProcName, "CloseNetworkConnection(" + decodeHandle(gnEventClient) + ")")
        ProcedureReturn
      EndIf
      grRAI\nClientConnection1 = gnEventClient
      sMsg = LangPars("RAI", "AppConnected", sClientIP + ":" + nClientPort)
      grRAI\bRAIClientActive = #True
      
    Case grRAI\nServerConnection2 ; default port = 58001
      grRAI\nClientConnection2 = gnEventClient
      ; do not display a message for the connection for the remote app second port (eg 58001)
      
    Case grRAI\nServerConnection3 ; default port = 58002
      grRAI\nClientConnection3 = gnEventClient
      ; do not display a message for the connection for the remote app third port (eg 58002)
      
    Case grFMOptions\nFMServerId ; port 59650
      nFMBackupIndex = FMP_BackupConnectionRequest()
      sMsg = LangPars("Network", "ClientConnected", sClientIP + ":" + nClientPort)
      
    Default
      sMsg = LangPars("Network", "ClientConnected", sClientIP + ":" + nClientPort)
      
  EndSelect
  newHandle(#SCS_HANDLE_NETWORK_CLIENT, gnEventClient)
  If sMsg
    debugMsg(sProcName, sMsg)
    WMN_setStatusField(sMsg)
  EndIf
  If gbMidiTestWindow
    WMT_addMiscListItem(sMsg)
  EndIf
  If bMultipleClientsAllowed
    nNetworkControlPtr = getNetworkControlPtrForServerAndClientConnection(gnEventServer, gnEventClient, bFMEvent)
  Else
    nNetworkControlPtr = getNetworkControlPtrForServerConnection(gnEventServer)
  EndIf
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If bFMEvent = #False
        If \nClientConnection
          ; if an existing client is connected to the server then close that connection as SCS supports only one client at a time (except for 'SCS Backup' connections, but that should have just created a new gaNetworkControl() entry)
          debugMsg(sProcName, "calling CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
          CloseNetworkConnection(\nClientConnection)
          debugMsg(sProcName, "CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
          freeHandle(\nClientConnection)
          \nClientConnection = 0
        EndIf
        \nClientConnection = gnEventClient ; to allow server (SCS) replies to be sent back to the client
      EndIf
      \sClientIP = sClientIP
      \nClientPort = nClientPort
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + decodeHandle(\nServerConnection) +
                          ", \nClientConnection=" + decodeHandle(\nClientConnection) + ", \sClientIP=" + \sClientIP + ", \nClientPort=" + \nClientPort)
      debugMsg(sProcName, "gnEventServer=" + decodeHandle(gnEventServer) + ", grRAI\nServerConnection1=" + decodeHandle(grRAI\nServerConnection1) + ", grRAI\nServerConnection2=" + decodeHandle(grRAI\nServerConnection2))
      Select gnEventServer
        Case grRAI\nServerConnection1 ; default port = 58000, or 58100 for OSC remote
          grRAI\nStatus = 0           ; clear RAI status on connecting
          If grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC
            \bOSCTextMsg = #False
            \sOSCPath = "/connected"
            \sOSCTagTypes = ""
            populateOSCMessageDataIfReqd(nNetworkControlPtr)
            sendOSCComplexMessage(nNetworkControlPtr)
            ; sendOSCMessage(nNetworkControlPtr, "/connected")
          EndIf
          
        Case grRAI\nServerConnection2 ; default port = 58001
          sendOSCMessage(nNetworkControlPtr, "/connected" + #LF$)
          
        Case grRAI\nServerConnection3 ; default port = 58002
          ; no action on third connection
          
        Case grFMOptions\nFMServerId ; port 59650
          sendOSCMessage(nNetworkControlPtr, "/fmh/bca", "s", 0.0, 0, #SCS_VERSION)
          Delay(100)
          FMP_sendCueFileName(nFMBackupIndex)
          For i = 1 To gnLastCue
            If aCue(i)\bSubTypeP
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeP
                  If aSub(j)\bPLRandom
                    sPlayOrder = aSub(j)\sPlayOrder
                    nSubNo = aSub(j)\nSubNo
                    nFirstPlayingAudPtr = aSub(j)\nFirstPlayIndexThisRun
                    If nFirstPlayingAudPtr >= 0
                      nFirstPlayingAudNo = aAud(nFirstPlayingAudPtr)\nAudNo
                    Else
                      nFirstPlayingAudNo = 1
                    EndIf
                    FMP_sendCommandIfReqd(#SCS_OSCINP_SET_PLAYORDER, i, nSubNo, nFirstPlayingAudNo, sPlayOrder)
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            EndIf
          Next i
      EndSelect
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkDisconnection()
  ; Processes a genuine #PB_NetworkEvent_Disconnect network server event, and also a pseudo 'disconnect' event raised on receiving the message /bye from an SCS backup.
  ; Note: UDP connections do not raise #PB_NetworkEvent_Disconnect network server events, which is why the /bye message is sent by the backup.
  ; See also the PB Help on NetworkServerEvent(), which mentions the UDP limitations.
  PROCNAMEC()
  Protected bRAIEvent, bHideTracing, bFMEvent, bMultipleClientsAllowed
  Protected sClientIP.s, nClientPort, sMsg.s
  Protected nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START + ", gnEventServer=" + decodeHandle(gnEventServer))
  
  If gnEventServer = grRAI\nServerConnection1
    bRAIEvent = #True
    ; debugMsg(sProcName, "bRAIEvent=" + strB(bRAIEvent))
    bHideTracing = #c_hide_rai_input_tracing
  EndIf
  
  If gnEventServer = grFMOptions\nFMServerId
    bFMEvent = #True
    bMultipleClientsAllowed = #True
    debugMsg0(sProcName, "bFMEvent=#True")
  EndIf
  
  If bMultipleClientsAllowed
    nNetworkControlPtr = getNetworkControlPtrForServerAndClientConnection(gnEventServer, gnEventClient)
  Else
    nNetworkControlPtr = getNetworkControlPtrForServerConnection(gnEventServer)
  EndIf
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      sClientIP = \sClientIP
      nClientPort = \nClientPort
      freeHandle(\nClientConnection)
      \nClientConnection = grNetworkControlDef\nClientConnection
      \sClientIP = grNetworkControlDef\sClientIP
      \nClientPort = grNetworkControlDef\nClientPort
      Select gnEventServer
        Case grRAI\nServerConnection1 ; default port = 58000
          sMsg = LangPars("RAI", "AppDisconnected", sClientIP + ":" + nClientPort)
          grRAI\bRAIClientActive = #False
          
        Case grRAI\nServerConnection2 ; default port = 58001
          ; no message for disconnection of the second connection
          
        Case grRAI\nServerConnection3 ; default port = 58000
          ; no message for disconnection of the third connection
          
        Case grFMOptions\nFMServerId ; port 59650
          FMP_BackupDisconnectionRequest()
          sMsg = LangPars("Network", "ClientDisconnected", sClientIP + ":" + nClientPort)
          
        Default
          sMsg = LangPars("Network", "ClientDisconnected", sClientIP + ":" + nClientPort)
      EndSelect
      If sMsg
        debugMsg(sProcName, sMsg)
        WMN_setStatusField(sMsg)
        If gbMidiTestWindow
          WMT_addMiscListItem(sMsg)
        EndIf
      EndIf
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + decodeHandle(\nServerConnection) +
                          ", \nClientConnection=" + decodeHandle(\nClientConnection) + ", \sClientIP=" + \sClientIP + ", \nClientPort=" + \nClientPort)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure extractSLIPDatagram(pStartBytePos)
  PROCNAMEC()
  ; NOTE: For details of SLIP (Serial Line IP) message formats, see https://flylib.com/books/en/3.223.1.35/1/
  Protected nReadBytePos, nWriteBytePos, aThisByte.a, aNextByte.a
  
  ; debugMsg(sProcName, #SCS_START + ", pStartBytePos=" + pStartBytePos)
  
  If *gmSLIPDatagram = 0
    *gmSLIPDatagram = AllocateMemory(#SCS_MEM_SIZE_NETWORK_BUFFERS)
  EndIf
  
  nReadBytePos = pStartBytePos + 1 ; Skip over the starting $C0
  nWriteBytePos = 0
  
  While nReadBytePos < gnNetworkInputLength
    aThisByte = PeekA(*gmNetworkInputBuffer + nReadBytePos)
    ; debugMsg(sProcName, "nReadBytePos=" + nReadBytePos + ", aThisByte=$" + Hex(aThisByte,#PB_Ascii))
    If aThisByte = $C0
      ; End of SLIP Datagram
      nReadBytePos + 1
      Break
    ElseIf aThisByte = $DB
      aNextByte = PeekA(*gmNetworkInputBuffer + nReadBytePos + 1)
      If aNextByte = $DC
        ; $DB $DC is SLIP encoding for $C0
        aThisByte = $C0
        nReadBytePos + 1
      ElseIf aNextByte = $DD
        ; $DB $DD is SLIP encoding for $DB
        aThisByte = $DB
        nReadBytePos + 1
      EndIf
    EndIf
    PokeA(*gmSLIPDatagram + nWriteBytePos, aThisByte)
    nWriteBytePos + 1
    nReadBytePos + 1
  Wend
  
  ; Set gnSLIPDatagramLength to the size of the extracted datagram
  gnSLIPDatagramLength = nWriteBytePos
  ; Return the position of the NEXT byte (if any) in the incoming network message (in *gmNetworkReceiveBuffer)
  ProcedureReturn nReadBytePos
  
EndProcedure

Procedure processNetworkData()
  PROCNAMEC()
  Protected bFMEvent, bMultipleClientsAllowed, bDataProcessed, bIgnoreThisMessage
  Protected nNetworkControlPtr, sAsciiString.s
  Protected nReadBytePos, nNextReadBytePos, bMessageReady
  Protected bSLIPEncoded ; Added 30Aug2024 11.10.3br
  
  If gnEventServer = grFMOptions\nFMServerId
    bFMEvent = #True
    bMultipleClientsAllowed = #True
  EndIf
  
  If *gmNetworkInputBuffer
    FillMemory(*gmNetworkInputBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS)
    gnNetworkInputLength = ReceiveNetworkData(gnEventClient, *gmNetworkInputBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS)
    ; debugMsg(sProcName, "gnNetworkInputLength=" + gnNetworkInputLength + ", bFMEvent=" + strB(bFMEvent))
    If gnNetworkInputLength > 0
      FillMemory(*gmNetworkReceiveBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS) ; Added 27May2025 11.10.8be following bug report from Dik Thacker
      If bMultipleClientsAllowed
        nNetworkControlPtr = getNetworkControlPtrForServerAndClientConnection(gnEventServer, gnEventClient, bFMEvent)
      Else
        nNetworkControlPtr = getNetworkControlPtrForServerConnection(gnEventServer)
      EndIf
      nReadBytePos = 0
      While nReadBytePos < (gnNetworkInputLength - 1)
        bMessageReady = #False
        bIgnoreThisMessage = #False
        bDataProcessed = #False
        ; debugMsg(sProcName, "PeekA(*gmNetworkInputBuffer + " + nReadBytePos + ")=" + Hex(PeekA(*gmNetworkInputBuffer + nReadBytePos), #PB_Ascii))
        If PeekA(*gmNetworkInputBuffer + nReadBytePos) = $C0
          ; Looks like a SPLIT-encoded message
          ; debugMsg(sProcName, "SLIP")
          nNextReadBytePos = extractSLIPDatagram(nReadBytePos)
          ; debugMsg(sProcName, "gnSLIPDatagramLength=" + gnSLIPDatagramLength)
          If gnSLIPDatagramLength > 0
            bSLIPEncoded = #True ; Added 30Aug2024 11.10.3br
            CopyMemory(*gmSLIPDatagram, *gmNetworkReceiveBuffer, gnSLIPDatagramLength)
            gnNetworkBytesReceived = gnSLIPDatagramLength
            bMessageReady = #True
            nReadBytePos = nNextReadBytePos
          EndIf
        EndIf
        If bMessageReady = #False
          gnNetworkBytesReceived = gnNetworkInputLength - nReadBytePos
          CopyMemory(*gmNetworkInputBuffer + nReadBytePos, *gmNetworkReceiveBuffer, gnNetworkBytesReceived)
          bMessageReady = #True
          nReadBytePos + gnNetworkBytesReceived
        EndIf
        If nNetworkControlPtr >= 0
          ; Added 31Aug2024 11.10.3br
          ; gaNetworkControl(nNetworkControlPtr)\bSLIPEncodedInputMsg = bSLIPEncoded ; Added 30Aug2024 11.10.3br
          If bSLIPEncoded
            gaNetworkControl(nNetworkControlPtr)\nOSCVersion = #SCS_OSC_VER_1_1
          EndIf
          ; End added 31Aug2024 11.10.3br
          If gaNetworkControl(nNetworkControlPtr)\bRAIDev And #c_hide_rai_input_tracing = #False
            debugMsgR("R" + decodeRAIClient(gnEventClient), bufferToUTF8String(*gmNetworkReceiveBuffer, gnNetworkBytesReceived))
          EndIf
        EndIf
        If bFMEvent
          sAsciiString = bufferToAsciiString(*gmNetworkReceiveBuffer, gnNetworkBytesReceived)
          Select sAsciiString
            Case "/fmh/bcr" ; functional mode handler / backup connection request
              processNetworkConnection()
              bDataProcessed = #True
            Case "/fmh/bdi" ; functional mode handler / backup disconnect
              processNetworkDisconnection()
              bDataProcessed = #True
          EndSelect
        ElseIf grLicInfo\bFMAvailable
          If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
            If grFMOptions\bBackupIgnoreCCDevs
              bIgnoreThisMessage = #True ; ignores all network Cue Control messages EXCEPT those from the Primary (ie bFMEvent = #False)
            EndIf
          EndIf
        EndIf
        If bDataProcessed = #False And bIgnoreThisMessage = #False
          processNetworkReceiveBuffer(nNetworkControlPtr, gaNetworkControl(nNetworkControlPtr)\nCueNetworkRemoteDev, #c_hide_rai_input_tracing)
        EndIf
      Wend
    EndIf
  EndIf
  
EndProcedure

Procedure processNetworkServerEvent()
  PROCNAMEC()
  
  gnEventServer = EventServer()
  gnEventClient = EventClient()
  
  If gnEventServer = 0 Or gnEventClient = 0
    debugMsg0(sProcName, "gnEventServer=" + decodeHandle(gnEventServer) + ", gnEventClient=" + decodeHandle(gnEventClient) + ", gnServerEvent=" + gnServerEvent)
    ProcedureReturn
  EndIf
  
  Select gnServerEvent
    Case #PB_NetworkEvent_Connect
      ; INFO: #PB_NetworkEvent_Connect event
      ; NOTE: A connection event is NOT raised for UDP connections - see the PB Help on 'NetworkServerEvent'
      ; However, UDP connections are preferred over TCP because UDP recognises message boundaries, whereas TCP doesn't. This means that with TCP it is often necessary to introduce time delays between successive messages.
      debugMsg(sProcName, "gnEventServer=" + decodeHandle(gnEventServer) + ", gnEventClient=" + decodeHandle(gnEventClient) + ", gnServerEvent=#PB_NetworkEvent_Connect")
      processNetworkConnection()
      
    Case #PB_NetworkEvent_Disconnect
      ; INFO: #PB_NetworkEvent_Disconnect event
      ; NOTE: A disconnection event is NOT raised for UDP connections - see the PB Help on 'NetworkServerEvent'
      debugMsg(sProcName, "gnEventServer=" + decodeHandle(gnEventServer) + ", gnEventClient=" + decodeHandle(gnEventClient) + ", gnServerEvent=#PB_NetworkEvent_Disconnect")
      processNetworkDisconnection()
      
    Case #PB_NetworkEvent_Data
      ; INFO: #PB_NetworkEvent_Data event
      ; debugMsg(sProcName, "gnEventServer=" + decodeHandle(gnEventServer) + ", gnEventClient=" + decodeHandle(gnEventClient) + ", gnServerEvent=#PB_NetworkEvent_Data")
      processNetworkData()
      
  EndSelect
  
EndProcedure

Procedure closeANetworkConnection(nNetworkControlPtr, bTrace=#True)
  PROCNAMEC()
  Protected n, bDoNotClose
  
  debugMsgC(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_CLOSE_NETWORK_CONNECTION, nNetworkControlPtr)
    ProcedureReturn
  EndIf
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If \nClientConnection
        ; before closing this network connection, make sure that no other gaNetworkControl() items use the same connection
        For n = 0 To gnMaxNetworkControl
          If n <> nNetworkControlPtr
            If gaNetworkControl(n)\nClientConnection = \nClientConnection
              debugMsgC(sProcName, "setting bDoNoClose=#True because gaNetworkControl(" + n + ")\nClientConnection=" + gaNetworkControl(nNetworkControlPtr)\nClientConnection + ", ie " + decodeHandle(\nClientConnection))
              bDoNotClose = #True
              Break
            EndIf
          EndIf
        Next n
        If bDoNotClose = #False
          debugMsgC(sProcName, "calling CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
          CloseNetworkConnection(\nClientConnection)
          debugMsgC(sProcName, "CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
        EndIf
        ; ok to 'close' the info in this gaNetworkControl() item as that will not affect any other items that use the same \nClientConnection
        \bClientConnectionLive = #False
        If grFMOptions\nFMClientId = \nClientConnection
          grFMOptions\nFMClientId = 0
        EndIf
        \nClientConnection = 0
        \bNetworkDevInitialized = #False ; Added 1Feb2024 11.10.2ad
      EndIf
    EndWith
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure processNetworkClientEvent(nNetworkControlPtr, bTraceOn=#True)
  PROCNAMEC()
  Protected bHideTracing
  
  ; debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", gnClientEvent=" + gnClientEvent + ", bTraceOn=" + strB(bTraceOn))
  
  If bTraceOn = #False
    bHideTracing = #True
  EndIf
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      Select gnClientEvent
          
        Case #PB_NetworkEvent_Data
          debugMsgN(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr + ", gnClientEvent=#PB_NetworkEvent_Data, gaNetworkControl(" + nNetworkControlPtr + ")\nUseNetworkControlPtr=" + \nUseNetworkControlPtr)
          If *gmNetworkReceiveBuffer
            FillMemory(*gmNetworkReceiveBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS)
            gnNetworkBytesReceived = ReceiveNetworkData(\nClientConnection, *gmNetworkReceiveBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS)
            gnNetworkBytesProcessed = 0
            If gnNetworkBytesReceived > 0
              ; processNetworkReceiveBuffer(nNetworkControlPtr) ; del 24Apr2019 11.8.1ah (see immediately below)
              ; added 24Apr2019 11.8.1ah because some messages received back from the X32 were processed by the wrong gaNetworkControl entry -
              ; this procedure should be checking if \nUseNetworkControlPtr has been set
              If \nUseNetworkControlPtr >= 0
                processNetworkReceiveBuffer(\nUseNetworkControlPtr, \nCueNetworkRemoteDev, bHideTracing)
              Else
                processNetworkReceiveBuffer(nNetworkControlPtr, \nCueNetworkRemoteDev, bHideTracing)
              EndIf
              ; end added 24Apr2019 11.8.1ah
            EndIf
          EndIf
          
        Case #PB_NetworkEvent_Disconnect
          debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr + ", gnClientEvent=#PB_NetworkEvent_Disconnect")
          closeANetworkConnection(nNetworkControlPtr)
          
      EndSelect
    EndWith
  EndIf
EndProcedure

Procedure.s makeComparisonMsg(sReceiveMsg.s)
  Protected sComparisonMsg.s
  
  If UCase(Left(sReceiveMsg,8)) = "PJLINK 1"
    sComparisonMsg = "PJLINK 1" ; nb drop off the 'random number' for message comparison purposes
  Else
    sComparisonMsg = Trim(RemoveString(RemoveString(LCase(sReceiveMsg), Chr(10)), Chr(13)))
  EndIf
  ProcedureReturn sComparisonMsg
EndProcedure

Procedure buildOSCMessage(*mBuffer, sAddress.s, sTypeTag.s="", fVal.f=0.0, lVal.l=0, sString.s="")
  PROCNAMEC()
  ; based on example found in PB Forum Topic "OSC (OpenSoundControl) and PB"
  Protected nPtr, sMsgTypeTag.s
  
  ; OSC Type Tag
  ; i	int32
  ; f	float32
  ; s	OSC-string
  ; b	OSC-blob
  
  If *mBuffer
    
    ; clear memory buffer to ensure nulls in 'unused' bytes
    FillMemory(*mBuffer, MemorySize(*mBuffer))
    
    PokeS(*mBuffer, sAddress, -1, #PB_Ascii)
    nPtr + Len(sAddress) + 1
    While nPtr % 4
      nPtr + 1
    Wend
    
    ; added 2Dec2018 11.8.0cb following email from Dee that wireshark reports (some) SCS OSC messages as 'Malformed OSC', which appears to be because SCS omitted
    ; the tag type string from the OSC message if sTagTypes was blank. That appears to be regarded as no longer correct, even though the OSC specification states:
    ; Note: some older implementations of OSC may omit the OSC Type Tag string. Until all such implementations are updated, OSC implementations should be robust in the case of a missing OSC Type Tag String.
    sMsgTypeTag = "," + Trim(sTypeTag)
    PokeS(*mBuffer + nPtr, sMsgTypeTag, -1, #PB_Ascii)
    nPtr + Len(sMsgTypeTag) + 1
    While nPtr % 4
      nPtr + 1
    Wend
    ; end added 2Dec2018 11.8.0cb
    
    ; commented out 2Dec2018 11.8.0cb because sTypeTag may be blank (see above)
;     Select sTypeTag
;       Case "f", "i", "s"
;         sMsgTypeTag = "," + sTypeTag
;         PokeS(*mBuffer + nPtr, sMsgTypeTag, -1, #PB_Ascii)
;         nPtr + Len(sMsgTypeTag) + 1
;         While nPtr % 4
;           nPtr + 1
;         Wend
        
        Select sTypeTag
          Case "f"
            ; Make BigEndian float32 (= PB float)
            PokeB(*mBuffer + nPtr, PeekB(@fVal+3))
            nPtr + 1
            PokeB(*mBuffer + nPtr, PeekB(@fVal+2))
            nPtr + 1
            PokeB(*mBuffer + nPtr, PeekB(@fVal+1))
            nPtr + 1
            PokeB(*mBuffer + nPtr, PeekB(@fVal+0))
            nPtr + 1
            
          Case "i"
            ; Make BigEndian int32 (= PB long)
            PokeB(*mBuffer + nPtr, PeekB(@lVal+3))
            nPtr + 1
            PokeB(*mBuffer + nPtr, PeekB(@lVal+2))
            nPtr + 1
            PokeB(*mBuffer + nPtr, PeekB(@lVal+1))
            nPtr + 1
            PokeB(*mBuffer + nPtr, PeekB(@lVal+0))
            nPtr + 1
            
          Case "s"
            PokeS(*mBuffer + nPtr, sString, -1, #PB_Ascii)
            nPtr + Len(sString) + 1
            While nPtr % 4
              nPtr + 1
            Wend
            
        EndSelect
;     EndSelect
    
  EndIf
  
  ProcedureReturn nPtr
  
EndProcedure

Procedure buildOSCMessageNew(nNetworkControlPtr, nStringFormat, bHideTracing=#False)
  PROCNAMEC()
  Protected nPtr
  Protected sMsgTags.s, sThisTag.s
  Protected sOSCTextMsg.s
  Protected nPokeBytes
  Protected nTagCount, nTagPtr
  Protected fFloat.f, nInteger, sString.s
  Protected nFloatPtr=-1, nIntegerPtr=-1, nStringPtr=-1
  
  ; OSC Type Tag
  ; i	int32
  ; f	float32
  ; s	OSC-string
  ; b	OSC-blob
  
  If (nNetworkControlPtr >= 0) And (*gmNetworkSendBuffer)
    With gaNetworkControl(nNetworkControlPtr)
      debugMsgN(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\sOSCTagTypes=" + \sOSCTagTypes + ", \sOSCPathOriginal=" + \sOSCPathOriginal)
      ; clear memory buffer to ensure nulls in 'unused' bytes
      FillMemory(*gmNetworkSendBuffer, MemorySize(*gmNetworkSendBuffer))
      
      ; debugMsgN(sProcName, "\bOSCTextMsg=" + strB(\bOSCTextMsg) + ", \sOSCPath=" + \sOSCPath)
      If \bOSCTextMsg
        sOSCTextMsg = \sOSCPathOriginal
      Else
        nPokeBytes = PokeS(*gmNetworkSendBuffer + nPtr, \sOSCPath, -1, #PB_Ascii)
        nPtr + nPokeBytes + 1 ; + 1 to allow for the null terminator
        While nPtr % 4
          nPtr + 1
        Wend
      EndIf
      
      ; added 2Dec2018 11.8.0cb following email from Dee that wireshark reports (some) SCS OSC messages as 'Malformed OSC', which appears to be because SCS omitted
      ; the tag type string from the OSC message if sTagTypes was blank. That appears to be regarded as no longer correct, even though the OSC specification states:
      ; Note: some older implementations of OSC may omit the OSC Type Tag string. Until all such implementations are updated, OSC implementations should be robust in the case of a missing OSC Type Tag String.
      sMsgTags = "," + Trim(\sOSCTagTypes)
      If \bOSCTextMsg = #False
        nPokeBytes = PokeS(*gmNetworkSendBuffer + nPtr, sMsgTags, -1, #PB_Ascii)
        nPtr + nPokeBytes + 1  ; + 1 to allow for the null terminator
        While nPtr % 4
          nPtr + 1
        Wend
      EndIf
      ; end added 2Dec2018 11.8.0cb
      
      nTagCount = Len(\sOSCTagTypes)
      ; commented out 2Dec2018 11.8.0cb because sTypeTag may be blank (see above)
;       If nTagCount > 0
;         sMsgTags = "," + \sOSCTagTypes
;         If \bOSCTextMsg = #False
;           nPokeBytes = PokeS(*gmNetworkSendBuffer + nPtr, sMsgTags, -1, #PB_Ascii)
;           nPtr + nPokeBytes + 1  ; + 1 to allow for the null terminator
;           While nPtr % 4
;             nPtr + 1
;           Wend
;         EndIf
        
        For nTagPtr = 1 To nTagCount
          sThisTag = Mid(\sOSCTagTypes, nTagPtr, 1)
          Select sThisTag
            Case "f"
              nFloatPtr + 1
              fFloat = \fOSCFloat(nFloatPtr)
              If \bOSCTextMsg
                sOSCTextMsg + " " + StrF(fFloat)
              Else
                ; Make BigEndian float32 (= PB float)
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@fFloat+3))
                nPtr + 1
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@fFloat+2))
                nPtr + 1
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@fFloat+1))
                nPtr + 1
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@fFloat+0))
                nPtr + 1
              EndIf
              
            Case "i"
              nIntegerPtr + 1
              nInteger = \nOSCLong(nIntegerPtr)
              ; debugMsgN(sProcName, "sThisTag=" + sThisTag + ", nInteger=" + nInteger)
              If \bOSCTextMsg
                sOSCTextMsg + " " + Str(nInteger)
              Else
                ; Make BigEndian int32 (= PB long)
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@nInteger+3))
                nPtr + 1
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@nInteger+2))
                nPtr + 1
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@nInteger+1))
                nPtr + 1
                PokeB(*gmNetworkSendBuffer + nPtr, PeekB(@nInteger+0))
                nPtr + 1
              EndIf
              
            Case "s"
              nStringPtr + 1
              sString = \sOSCString(nStringPtr)
              If \bOSCTextMsg
                sOSCTextMsg + " " + #DQUOTE$ + EscapeString(sString) + #DQUOTE$
              Else
                ; nPokeBytes = PokeS(*gmNetworkSendBuffer + nPtr, sString, -1, #PB_Ascii)
                nPokeBytes = PokeS(*gmNetworkSendBuffer + nPtr, sString, -1, nStringFormat)
                nPtr + nPokeBytes + 1  ; + 1 to allow for the null terminator
                While nPtr % 4
                  nPtr + 1
                Wend
              EndIf
              
          EndSelect
        Next nTagPtr
;       EndIf ; EndIf \nTagCount > 0
      
      If \bOSCTextMsg
        If sOSCTextMsg
          ; Debug sProcName + ": sOSCTextMsg=" + #DQUOTE$ + sOSCTextMsg + #DQUOTE$ + ", \bAddLF=" + strB(\bAddLF) + ", \bRAIDev=" + strB(\bRAIDev)
          If \bAddLF
            sOSCTextMsg + #LF$
          EndIf
          nPokeBytes = PokeS(*gmNetworkSendBuffer, sOSCTextMsg, -1, #PB_Ascii)
          nPtr = nPokeBytes + 1  ; + 1 to allow for the null terminator
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  ProcedureReturn nPtr
  
EndProcedure

Procedure buildOSCComplexMessage(*mBuffer, nOSCVersion, nStringFormat, bHideTracing=#False)
  PROCNAMEC()
  Protected nPtr, nTagPtr
  Protected sMsgTags.s, sThisTag.s
  Protected rTagData.tyOSCTagData
  Protected sOSCTextMsg.s
  Protected nPokeBytes
  
  ; OSC Type Tag
  ; i	int32
  ; f	float32
  ; s	OSC-string
  ; b	OSC-blob (not supported in SCS)
  
  debugMsgN(sProcName, #SCS_START + ", nOSCVersion=" + decodeOSCVersion(nOSCVersion) + ", nStringFormat=" + decodeStringFormat(nStringFormat))
  
  With grOSCMsgData
    If *mBuffer
      ; clear memory buffer to ensure nulls in 'unused' bytes
      FillMemory(*mBuffer, MemorySize(*mBuffer))
      
      debugMsgN(sProcName, "grOSCMsgData\bOSCTextMsg=" + strB(\bOSCTextMsg) + ", \sOSCAddress=" + \sOSCAddress + ", \nTagCount=" + \nTagCount)
      
      If \bOSCTextMsg
        sOSCTextMsg = \sOSCAddress
      Else
        nPokeBytes = PokeS(*mBuffer + nPtr, \sOSCAddress, -1, #PB_Ascii)
        nPtr + nPokeBytes + 1 ; + 1 to allow for the null terminator
        While nPtr % 4
          nPtr + 1
        Wend
      EndIf
      
      ; added 2Dec2018 11.8.0cb following email from Dee that wireshark reports (some) SCS OSC messages as 'Malformed OSC', which appears to be because SCS omitted
      ; the tag type string from the OSC message if sTagTypes was blank. That appears to be regarded as no longer correct, even though the OSC specification states:
      ; Note: some older implementations of OSC may omit the OSC Type Tag string. Until all such implementations are updated, OSC implementations should be robust in the case of a missing OSC Type Tag String.
      If \nTagCount = 0 And Left(\sOSCAddress, 4) = "/eos" And 1=2 ; Test added 1Nov2021 11.8.6bn to try to resolve ETC Ion intreface issue raised by Allan Noel
        ; do not include ","
      Else
        sMsgTags = "," + Trim(\sTagString)
        If \bOSCTextMsg = #False
          nPokeBytes = PokeS(*mBuffer + nPtr, sMsgTags, -1, #PB_Ascii)
          nPtr + nPokeBytes + 1  ; + 1 to allow for the null terminator
          While nPtr % 4
            nPtr + 1
          Wend
        EndIf
      EndIf
      ; end added 2Dec2018 11.8.0cb
      
      ; commented out 2Dec2018 11.8.0cb because sTypeTag may be blank (see above)
        
;       If \nTagCount > 0
;         sMsgTags = "," + \sTagString
;         If \bOSCTextMsg = #False
;           nPokeBytes = PokeS(*mBuffer + nPtr, sMsgTags, -1, #PB_Ascii)
;           nPtr + nPokeBytes + 1  ; + 1 to allow for the null terminator
;           While nPtr % 4
;             nPtr + 1
;           Wend
;         EndIf
        
        For nTagPtr = 1 To \nTagCount
          sThisTag = Mid(\sTagString, nTagPtr, 1)
          rTagData = \aTagData(nTagPtr-1)
          Select sThisTag
            Case "i"
              If \bOSCTextMsg
                sOSCTextMsg + " " + rTagData\nInteger
              Else
                ; Make BigEndian int32 (= PB long)
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\nInteger+3))
                nPtr + 1
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\nInteger+2))
                nPtr + 1
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\nInteger+1))
                nPtr + 1
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\nInteger+0))
                nPtr + 1
              EndIf
              
            Case "f"
              If \bOSCTextMsg
                sOSCTextMsg + " " + StrF(rTagData\fFloat)
              Else
                ; Make BigEndian float32 (= PB float)
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\fFloat+3))
                nPtr + 1
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\fFloat+2))
                nPtr + 1
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\fFloat+1))
                nPtr + 1
                PokeB(*mBuffer + nPtr, PeekB(@rTagData\fFloat+0))
                nPtr + 1
              EndIf
              
            Case "s"
              ; debugMsg(sProcName, "rTagData\sString=" + rTagData\sString)
              If \bOSCTextMsg
                sOSCTextMsg + " " + #DQUOTE$ + EscapeString(rTagData\sString) + #DQUOTE$
              Else
                ; nPokeBytes = PokeS(*mBuffer + nPtr, rTagData\sString, -1, #PB_Ascii)
                nPokeBytes = PokeS(*mBuffer + nPtr, rTagData\sString, -1, nStringFormat)
                nPtr + nPokeBytes + 1  ; + 1 to allow for the null terminator
                While nPtr % 4
                  nPtr + 1
                Wend
              EndIf
              
          EndSelect
        Next nTagPtr
;       EndIf ; EndIf \nTagCount > 0
      
      If \bOSCTextMsg
        If sOSCTextMsg
          If \bAddLF
            sOSCTextMsg + #LF$
          EndIf
          PokeS(*mBuffer, sOSCTextMsg, -1, #PB_Ascii)
          nPtr = Len(sOSCTextMsg)
        EndIf
      EndIf
      
    EndIf ; EndIf *mBuffer
    
  EndWith
  
  ProcedureReturn nPtr
  
EndProcedure

Procedure sendOSCMessage(nNetworkControlPtr, sAddress.s, sTypeTag.s="", fVal.f=0.0, lVal.l=0, sVal.s="", bHideTracing=#False)
  PROCNAMEC()
  Protected bResult
  Protected nSize, nBytesSent, bLockedMutex
  Protected sLogTypeTag.s, sOSCValue.s
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", sAddress=" + stringToNetworkString(sAddress) + ", sTypeTag=" + sTypeTag)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If \nClientConnection
        scsLockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND, 802)
        If *gmNetworkSendBuffer
          ; debugMsgN(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + \nClientConnection)
          nSize = buildOSCMessage(*gmNetworkSendBuffer, sAddress, sTypeTag, fVal, lVal, sVal)
          ; debugMsgN(sProcName, "nSize=" + nSize)
          If nSize > 0
            If Right(sAddress,1) = #LF$
              ; if sAddress ends with #LF$ then trim any trailing nulls from the send buffer
              While nSize > 0
                If PeekA(*gmNetworkSendBuffer + nSize - 1) = 0
                  nSize - 1
                Else
                  Break
                EndIf
              Wend
            EndIf
            ; debugMsgN(sProcName, "nSize=" + nSize)
            If nSize > 0
              If \bRAIDev
                debugMsgR("S" + decodeRAIClient(\nClientConnection), bufferToUTF8String(*gmNetworkSendBuffer, nSize))
              Else
                debugMsgN(sProcName, "sending " + nSize + " bytes: UTF8: " + bufferToUTF8String(*gmNetworkSendBuffer, nSize) + ", HEX: " + bufferToHexString(*gmNetworkSendBuffer, nSize, " "))
              EndIf
              nBytesSent = formatAndSendNetworkData(\nClientConnection, *gmNetworkSendBuffer, nSize, nNetworkControlPtr)
              ; debugMsgN(sProcName, "nBytesSent=" + nBytesSent)
              Select sTypeTag
                Case "f"
                  sLogTypeTag = " ,f"
                  sOSCValue = StrF(fVal)
                Case "i"
                  sLogTypeTag = " ,i"
                  sOSCValue = Str(lVal)
                Case "s"
                  sLogTypeTag = ", s"
                  sOSCValue = sVal
              EndSelect
              \sMsgSent = Trim(sAddress + sLogTypeTag + " " + sOSCValue)
              ; debugMsgN(sProcName, "Sent '" + \sMsgSent + "', sent " + nBytesSent + " bytes")
              \qSendTime = ElapsedMilliseconds()
              ; debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\qSendTime=" + \qSendTime)
              GetLocalTime_(@\rSendTime)
              bResult = #True
            EndIf
          EndIf
        EndIf
        scsUnlockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND)
      EndIf ; EndIf \nClientConnection
    EndWith
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  ; debugMsgN(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure echoReceivedData(nNetworkControlPtr, bHideTracing=#False)
  PROCNAMEC()
  Protected nLength, nBytesSent, bLockedMutex
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bHideTracing=" + strB(bHideTracing))
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If \nClientConnection
        scsLockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND, 803)
        If *gmNetworkReceiveBuffer And gnNetworkBytesReceived
          nLength = gnNetworkBytesReceived
          If \bRAIDev And grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC
            ; No action
          Else
            nLength = gnNetworkBytesReceived
            While nLength > 0
              If PeekA(*gmNetworkReceiveBuffer + nLength - 1) = 0
                nLength - 1
              Else
                Break
              EndIf
            Wend
          EndIf
          If \bRAIDev
            debugMsgR("S" + decodeRAIClient(\nClientConnection), bufferToUTF8String(*gmNetworkReceiveBuffer, nLength))
          ElseIf bHideTracing = #False
            debugMsgN(sProcName, "sending " + nLength + " bytes: UTF8: " + bufferToUTF8String(*gmNetworkReceiveBuffer, nLength) + ", HEX: " + bufferToHexString(*gmNetworkReceiveBuffer, nLength, " "))
          EndIf
          nBytesSent = formatAndSendNetworkData(\nClientConnection, *gmNetworkReceiveBuffer, nLength, nNetworkControlPtr)
        EndIf ; EndIf *gmNetworkReceiveBuffer And gnNetworkBytesReceived
        scsUnlockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure sendOSCComplexMessage(nNetworkControlPtr, bHideTracing=#False)
  PROCNAMEC()
  Protected bResult
  Protected nSize, nBytesSent, bLockedMutex
  Protected qTimeNow.q
  Protected nMinDelay = 50
  Protected nThisConnection, bUseMessageNew
  Protected nStringFormat, sStringFormat.s ; nb sStringFormat only for logging
  Protected nOSCVersion
  Protected bInitResult, nMode, sMode.s
  
  debugMsgN(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bHideTracing=" + strB(bHideTracing))
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      ; When adding support for X32TC, which needs to use \nServerConnection, I originally selected server or client connection based on \nNetworkRole (server or client).
      ; However, that broke the Remote App interface, because although SCS is a server to the remote app, the remote app requires messages to be sent by SCS via a
      ; second client port, which is handled by \nClientConnection.
      ; So, to be safe, I specifically test for X32TC.
      If \nCueNetworkRemoteDev = #SCS_CC_NETWORK_REM_OSC_X32TC
        nThisConnection = gnEventClient ; \nServerConnection
        nStringFormat = #PB_UTF8
        sStringFormat = "PB_UTF8"
        bUseMessageNew = #True
      Else
        nThisConnection = \nClientConnection
        nStringFormat = #PB_Ascii
        sStringFormat = "PB_Ascii"
      EndIf
      debugMsgN(sProcName, "nThisConnection=" + decodeHandle(nThisConnection) + ", gaNetworkControl(" + nNetworkControlPtr + ")\nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol))
      If nThisConnection
        scsLockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND, 804)
        debugMsgN(sProcName, "*gmNetworkSendBuffer=" + *gmNetworkSendBuffer + ", nThisConnection=" + decodeHandle(nThisConnection) +
                             ", gaNetworkControl(" + nNetworkControlPtr + ")\nOSCVersion=" + decodeOSCVersion(\nOSCVersion) + ", \bOSCTextMsg=" + strB(\bOSCTextMsg))
        If *gmNetworkSendBuffer
          If \bOSCTextMsg Or bUseMessageNew
            nSize = buildOSCMessageNew(nNetworkControlPtr, nStringFormat, bHideTracing)
            debugMsgN2(sProcName, "buildOSCMessageNew(" + nNetworkControlPtr + ", " + sStringFormat + ", " + strB(bHideTracing) + ")", nSize)
          Else
            nSize = buildOSCComplexMessage(*gmNetworkSendBuffer, \nOSCVersion, nStringFormat, bHideTracing)
            debugMsgN2(sProcName, "buildOSCComplexMessage(*gmNetworkSendBuffer, " + decodeOSCVersion(\nOSCVersion) + ", " + sStringFormat + ", " + strB(bHideTracing) + ")", nSize)
          EndIf
          If nSize > 0
            If \bOSCTextMsg
              ; if text message then trim any trailing nulls from the send buffer
              While nSize > 0
                If PeekA(*gmNetworkSendBuffer + nSize - 1) = 0
                  nSize - 1
                Else
                  Break
                EndIf
              Wend
            EndIf
            If nSize > 0
              ; debugMsgN(sProcName, "*gmNetworkSendBuffer=" + *gmNetworkSendBuffer + ", MemorySize(*gmNetworkSendBuffer)=" + MemorySize(*gmNetworkSendBuffer))
              If nSize > MemorySize(*gmNetworkSendBuffer)
                ; shouldn't get here
                scsUnlockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND)
                MessageRequester(sProcName, "nSize=" + nSize + ", MemorySize(*gmNetworkSendBuffer)=" + MemorySize(*gmNetworkSendBuffer), #MB_ICONERROR)
                ProcedureReturn #False
              EndIf
              ; comment 21Mar2019: there appears to be an issue in the remote app in that when a cue is playing the progress is not always shown in the remote app.
              ; this is sometimes(!) alleviated by enabling tracing of the \cue\setpos message which is why bHideTracing is not tested for \bRAIDev, but there's no rational
              ; explanation for this, and it doesn't always fix the problem. Need to follow up with Simone Giusti.
              If \bRAIDev And bHideTracing = #False And grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE
                debugMsgR("S" + decodeRAIClient(nThisConnection), bufferToUTF8String(*gmNetworkSendBuffer, nSize))
              ElseIf bHideTracing = #False
                If nStringFormat = #PB_UTF8
                  debugMsgN(sProcName, "sending " + nSize + " bytes: UTF8: " + bufferToUTF8String(*gmNetworkSendBuffer, nSize) + ", HEX: " + bufferToHexString(*gmNetworkSendBuffer, nSize, " "))
                Else
                  debugMsgN(sProcName, "sending " + nSize + " bytes: ASCII: " + bufferToAsciiString(*gmNetworkSendBuffer, nSize) + ", HEX: " + bufferToHexString(*gmNetworkSendBuffer, nSize, " "))
                EndIf
              EndIf
              qTimeNow = ElapsedMilliseconds()
              If (qTimeNow - \qSendTime) < nMinDelay
                Delay(nMinDelay) ; added delay to prevent consecutive messages being combined in the app (or remote device)
              EndIf
              nBytesSent = formatAndSendNetworkData(nThisConnection, *gmNetworkSendBuffer, nSize, nNetworkControlPtr)
              debugMsgN2(sProcName, "formatAndSendNetworkData(" + decodeHandle(nThisConnection) + ", *gmNetworkSendBuffer, " + nSize + ", " + nNetworkControlPtr + ")", nBytesSent)
              \sMsgSent = grOSCMsgData\sOSCItemString
              \qSendTime = ElapsedMilliseconds()
              GetLocalTime_(@\rSendTime)
              bResult = #True
            EndIf
          EndIf
        EndIf ; EndIf *gmNetworkSendBuffer
        scsUnlockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND)
      EndIf ; EndIf nThisConnection
    EndWith
  EndIf ; EndIf nNetworkControlPtr >= 0
  
  debugMsgN(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure.s sendOSCCtrlMessage(pSubPtr, nCtrlSendIndex)
  PROCNAMECS(pSubPtr)
  Protected nNetworkControlPtr
  Protected sMyConnection.s
  Protected sAddress.s
  Protected sTypeTag.s
  Protected fVal.f, lVal.l, sVal.s
  Protected bGetItemNumber, nItemNumber
  Protected bItemNumberIs2Digits  ; channel, auxin, fxrtn, bus, matrix
  Protected bItemNumberIs1Digit   ; dca group, mute group
  Protected bParam1IsItemNumber, bParam1IsItemString
  Protected bGetItemString, sItemString.s
  Protected sChannelEtc.s
  Protected bMessageComplete
  Protected bReloadNames
  Protected bUnpackResult
  Protected nLogicalDev, nDelayBeforeReloadNames
  Protected sReqdOSCItemString.s
  Protected bGetRemDevScribbleStripNames
  Protected sMsgAddress.s
  Protected nMuteAction
  Protected bMuteCommand
  
  debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  If (pSubPtr >= 0) And (nCtrlSendIndex >= 0)
    With aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
      debugMsg(sProcName, "\aCtrlSend[" + nCtrlSendIndex + "]\sCSLogicalDev=" + \sCSLogicalDev + ", \nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr + ", \bIsOSC=" + strB(\bIsOSC))
      If \bIsOSC
        nNetworkControlPtr = \nCSPhysicalDevPtr
        CheckSubInRange(nNetworkControlPtr, ArraySize(gaNetworkControl()), "gaNetworkControl()")
        If gaNetworkControl(nNetworkControlPtr)\bNWDummy
          sMyConnection = gaNetworkControl(nNetworkControlPtr)\sNetworkDevDesc
        ElseIf gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
          sMyConnection = gaNetworkControl(nNetworkControlPtr)\sNetworkDevDesc
        Else
          sMyConnection = gaNetworkControl(nNetworkControlPtr)\sRemoteHost + ":" + gaNetworkControl(nNetworkControlPtr)\nRemotePort
          debugMsg(sProcName, "\nOSCCmdType=" + decodeOSCCmdType(\nOSCCmdType) + ", \sOSCItemString=" + #DQUOTE$ + \sOSCItemString + #DQUOTE$)
          If \nRemDevMsgType
            debugMsg(sProcName, "\sRemDevMsgType=" + \sRemDevMsgType + ", \sRemDevValue=" + \sRemDevValue + ", \sRemDevValue2=" + \sRemDevValue2 + ", \sRemDevLevel=" + \sRemDevLevel + ", \nOSCMuteAction=" + \nOSCMuteAction)
            nMuteAction = \nRemDevMuteAction
          Else
            nMuteAction = \nOSCMuteAction
          EndIf
          Select \nOSCCmdType
              ; NOTE GO commands
            Case #SCS_CS_OSC_GOCUE
              sAddress = "/-action/gocue"
              bGetItemNumber = #True
              bParam1IsItemNumber = #True
              bReloadNames = \bOSCReloadNamesGoCue
              
            Case #SCS_CS_OSC_GOSCENE
              sAddress = "/-action/goscene"
              bGetItemNumber = #True
              bParam1IsItemNumber = #True
              bReloadNames = \bOSCReloadNamesGoScene
              
            Case #SCS_CS_OSC_GOSNIPPET
              sAddress = "/-action/gosnippet"
              bGetItemNumber = #True
              bParam1IsItemNumber = #True
              bReloadNames = \bOSCReloadNamesGoSnippet
              
              ; NOTE: MUTE commands
            Case #SCS_CS_OSC_MUTEAUXIN
              sAddress = "/auxin/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEBUS
              sAddress = "/bus/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTECHANNEL
              sAddress = "/ch/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEDCAGROUP
              sAddress = "/dca/?/on" ; nb no /mix
              bGetItemNumber = #True
              bItemNumberIs1Digit = #True ; nb single digit for DCA's
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEFXRTN
              sAddress = "/fxrtn/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEMAINLR
              sAddress = "/main/st/mix/on"
              bGetItemNumber = #False ; nb no item number
              bMessageComplete = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEMAINMC
              sAddress = "/main/m/mix/on"
              bGetItemNumber = #False ; nb no item number
              bMessageComplete = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEMATRIX
              sAddress = "/mtx/?/mix/on"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              bMuteCommand = #True
              
            Case #SCS_CS_OSC_MUTEMG
              sAddress = "/config/mute/?"
              bGetItemNumber = #True
              bItemNumberIs1Digit = #True
              sTypeTag = "i"
              Select nMuteAction
                Case #SCS_MUTE_ON
                  lVal = 1
                Case #SCS_MUTE_OFF
                  lVal = 0
              EndSelect
              
              ; NOTE: FADER commands
            Case #SCS_CS_OSC_AUXINLEVEL
              sAddress = "/auxin/?/mix/fader"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_BUSLEVEL
              sAddress = "/bus/?/mix/fader"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_CHANNELLEVEL
              sAddress = "/ch/?/mix/fader"
              ; sAddress = "/ch/04/mix/fader 3"
              ; sTypeTag = "s"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_DCALEVEL
              sAddress = "/dca/?/fader" ; nb no /mix
              bGetItemNumber = #True
              bItemNumberIs1Digit = #True ; nb single digit for DCA's
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_FXRTNLEVEL
              sAddress = "/fxrtn/?/mix/fader"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_MAINLRFADER
              sAddress = "/main/st/mix/fader"
              bGetItemNumber = #False ; nb no item number
              bMessageComplete = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_MAINMCFADER
              sAddress = "/main/m/mix/fader"
              bGetItemNumber = #False ; nb no item number
              bMessageComplete = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
            Case #SCS_CS_OSC_MATRIXLEVEL
              sAddress = "/mtx/?/mix/fader"
              bGetItemNumber = #True
              bItemNumberIs2Digits = #True
              sTypeTag = "f" : fVal = ValF(\sRemDevLevel)
              
              ; NOTE OTHER commands
            Case #SCS_CS_OSC_FREEFORMAT
              bUnpackResult = unpackOSCEnteredString(\sEnteredString)
              If bUnpackResult
                bMessageComplete = #True
              EndIf
              
            Case #SCS_CS_OSC_TC_GO
              sAddress = "/go"
              bMessageComplete = #True
              
            Case #SCS_CS_OSC_TC_BACK
              sAddress = "/back"
              bMessageComplete = #True
              
            Case #SCS_CS_OSC_TC_JUMP
              sAddress = "/jump"
              bGetItemString = #True
              bParam1IsItemString = #True
              
          EndSelect
          
          If bMuteCommand
            sTypeTag = "i"
            ; set lVal as reverse of mute as address is 'mix on', not 'mute'
            Select nMuteAction
              Case #SCS_MUTE_ON  : lVal = 0
              Case #SCS_MUTE_OFF : lVal = 1
            EndSelect
          EndIf
          
          debugMsg(sProcName, "sAddress=" + sAddress)
          If \nRemDevMsgType > 0
            debugMsg(sProcName, "calling CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(" + getSubLabel(pSubPtr) + "), " + nCtrlSendIndex + ")")
            CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(pSubPtr), nCtrlSendIndex)
            If bGetItemNumber
              debugMsg(sProcName, "grCSRD\nMaxDataValueIndex=" + grCSRD\nMaxDataValueIndex)
              For nItemNumber = 0 To grCSRD\nMaxDataValueIndex
                If grCSRD\bDataValueSelected(nItemNumber)
                  If bItemNumberIs2Digits
                    sChannelEtc = RSet(Str(nItemNumber),2,"0")
                    sMsgAddress = ReplaceString(sAddress, "?", sChannelEtc)
                  ElseIf bItemNumberIs1Digit
                    sMsgAddress = ReplaceString(sAddress, "?", Str(nItemNumber))
                  Else
                    sMsgAddress = sAddress
                  EndIf
                  If bParam1IsItemNumber
                    sTypeTag = "i"
                    lVal = nItemNumber
                  EndIf
                  debugMsg(sProcName, "calling sendOSCMessage(" + nNetworkControlPtr + ", " + #DQUOTE$ + sMsgAddress + #DQUOTE$ + ", " + sTypeTag + ", " + fVal + ", " + lVal + ", " + sVal + ")")
                  sendOSCMessage(nNetworkControlPtr, sMsgAddress, sTypeTag, fVal, lVal, sVal)
                EndIf
              Next nItemNumber
            Else
              sMsgAddress = sAddress
              debugMsg(sProcName, "calling sendOSCMessage(" + nNetworkControlPtr + ", " + #DQUOTE$ + sMsgAddress + #DQUOTE$ + ", " + sTypeTag + ", " + fVal + ", " + lVal + ", " + sVal + ")")
              sendOSCMessage(nNetworkControlPtr, sMsgAddress, sTypeTag, fVal, lVal, sVal)
            EndIf
          Else
            If bGetItemNumber
              nItemNumber = getOSCItemNumber(nNetworkControlPtr, \nOSCCmdType, \sOSCItemString, \bOSCItemPlaceHolder)
              debugMsg2(sProcName, "getOSCItemNumber(" + nNetworkControlPtr + ", " + decodeOSCCmdType(\nOSCCmdType) + ", '" + \sOSCItemString + "', " + strB(\bOSCItemPlaceHolder) + ")", nItemNumber)
              If nItemNumber = -1 And \bOSCItemPlaceHolder = #False And \nOSCItemNr >= 0
                ; Try to determine the internal item number if the above returned -1, which can occur if a scribble strip item name is not found
                ; This can occur if the original cue obtained scribble strip names directly from an X32, but in the current run the X32 scribble strip has changed or has not been set up.
                If \nOSCCmdType = #SCS_CS_OSC_MUTECHANNEL
                  sReqdOSCItemString = "Ch" + RSet(Str(\nOSCItemNr),2,"0")
                  nItemNumber = getOSCItemNumber(nNetworkControlPtr, \nOSCCmdType, sReqdOSCItemString, \bOSCItemPlaceHolder)
                  debugMsg2(sProcName, "getOSCItemNumber(" + nNetworkControlPtr + ", " + decodeOSCCmdType(\nOSCCmdType) + ", '" + sReqdOSCItemString + "', " + strB(\bOSCItemPlaceHolder) + ")", nItemNumber)
                EndIf
              EndIf
              If \bOSCItemPlaceHolder
                bMessageComplete = #True
              ElseIf nItemNumber >= 0
                If bItemNumberIs2Digits
                  sChannelEtc = RSet(Str(nItemNumber),2,"0")
                  sAddress = ReplaceString(sAddress, "?", sChannelEtc)
                ElseIf bItemNumberIs1Digit
                  sAddress = ReplaceString(sAddress, "?", Str(nItemNumber))
                EndIf
                If bParam1IsItemNumber
                  sTypeTag = "i"
                  lVal = nItemNumber
                EndIf
                bMessageComplete = #True
              EndIf
            EndIf
            
            If bGetItemString
              sItemString = \sOSCItemString
              If bParam1IsItemString
                sTypeTag = "s"
                sVal = Trim(sItemString)
              EndIf
              bMessageComplete = #True
            EndIf
            
            If bMessageComplete
              If \bOSCItemPlaceHolder = #False
                If \nOSCCmdType = #SCS_CS_OSC_FREEFORMAT
                  sendOSCComplexMessage(nNetworkControlPtr)
                Else
                  sendOSCMessage(nNetworkControlPtr, sAddress, sTypeTag, fVal, lVal, sVal)
                EndIf
                If bReloadNames
                  ; Changed 7May2024 11.10.2cn to support \bGetRemDevScribbleStripNames
                  nLogicalDev = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_CTRL_SEND, \sCSLogicalDev)
                  If nLogicalDev >= 0
                    If grProd\aCtrlSendLogicalDevs(nLogicalDev)\bGetRemDevScribbleStripNames
                      nDelayBeforeReloadNames = grProd\aCtrlSendLogicalDevs(nLogicalDev)\nDelayBeforeReloadNames
                      Delay(nDelayBeforeReloadNames)
                      debugMsg(sProcName, "reloading channel names, etc")
                      getX32Names(nNetworkControlPtr, #False)
                    EndIf
                  EndIf
                  ; End changed 7May2024 11.10.2cn
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn sMyConnection
  
EndProcedure

Procedure.w xchEndianW(e.w)
  ; procedure to change endian (2-byte)
  ; published on PB Forum 20Jan2005 by 'traumatic' under topic 'Big endian to little endian without asm?'
  ProcedureReturn (e & $ff) << 8 + (e >> 8) & $ff
EndProcedure

Procedure xchEndianL(e.l)
  ; procedure to change endian (4-byte)
  ; published on PB Forum 20Jan2005 by 'traumatic' under topic 'Big endian to little endian without asm?'
  ProcedureReturn (e & $ff) << 24 + (e & $ff00) << 8 + (e >> 8) & $ff00 + (e >> 24) & $ff
EndProcedure

Procedure next4BytePos(n)
  Protected nPos
  
  nPos = n + 3
  nPos >> 2
  nPos << 2
  ProcedureReturn nPos
EndProcedure

Procedure unpackOSCMsg(nNetworkControlPtr, bSupportOSCTextMsgs, bHideTracing=#False, nStartPos=0, nEndPos=-1)
  PROCNAMEC()
  Protected sPathOriginal.s, sTagTypes.s, nTagTypeCount, sThisTagType.s
  Protected nPartNo
  Protected ascAsciiChar.a
  Dim sString.s(0)
  Dim nLong.l(0)
  Dim fFloat.f(0)
  Protected bOSCTextMsg, bAddLF
  Protected sOSCTextMsg.s
  Protected sOSCTextParams.s, sOSCTextParam1.s, sOSCTextParam2.s, sOSCTextParam3.s
  Protected sThisParam.s
  Protected nOSCTextParamsLength, nSpacePtr
  Protected nTagTypeIndex, nStringIndex, nLongIndex, nFloatIndex
  Protected n
  Protected nParamCount, nParamStartPtr, nParamCurrPtr, nParamLength, bEndQuoteFound, bEndSpaceFound
  Protected sDisplayMsg.s
  Static *mFloat
  Protected nThisStartPos, nThisEndPos, nThisBytes, nBuffStart
  Protected sUTF8String.s ; Added 16Jun2021 11.8.5ak
  
  If *mFloat = 0
    *mFloat = AllocateMemory(4)
  EndIf
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      \sOSCPath = ""
      \sOSCTagTypes = ""
      \nOSCStringCount = 0
      \nOSCLongCount = 0
      \nOSCFloatCount = 0
      \sOSCTextParam1 = ""
      \sOSCTextParam2 = ""
      \sOSCTextParam3 = ""
      \bOSCTextMsg = #False
      \bAddLF = #False
      If *gmNetworkReceiveBuffer
        
        ; nb start and end positions are 0-based
        nThisStartPos = nStartPos
        nThisEndPos = nEndPos
        If nThisEndPos = -1
          nThisEndPos = gnNetworkBytesReceived - 1
        EndIf
        nThisBytes = nThisEndPos - nThisStartPos + 1
        nBuffStart = *gmNetworkReceiveBuffer + nThisStartPos
        
        ; debugMsgN(sProcName, "received " + nThisBytes + " bytes: ASCII: " + bufferToAsciiString(nBuffStart, nThisBytes))
        debugMsgN(sProcName, "received " + nThisBytes + " bytes: UTF8: " + bufferToUTF8String(nBuffStart, nThisBytes))
        debugMsgN(sProcName, "HEX: " + bufferToHexString(nBuffStart, nThisBytes, " "))
        
        If bSupportOSCTextMsgs
          If nThisBytes > 1
            If PeekA(nBuffStart+1) = Asc("_")
              bOSCTextMsg = #True
            EndIf
          EndIf
        EndIf
        For n = 1 To 2
          ; Loop added 28May2025 11.10.8be so that terminating #LF$ and/or #CR$ will be removed, even if both are present and the #CR$ is last
          If PeekA(*gmNetworkReceiveBuffer + nThisBytes - 1) = Asc(#LF$)
            debugMsgN(sProcName, "last byte in buffer is LF, so ignore that byte, but replace with NULL")
            PokeA(*gmNetworkReceiveBuffer + nThisBytes - 1, 0) ; Replace with NULL - the standard string terminator. Added 28May2025 11.10.8be
            nThisBytes - 1
          EndIf
          If PeekA(*gmNetworkReceiveBuffer + nThisBytes - 1) = Asc(#CR$)
            debugMsgN(sProcName, "last byte in buffer is CR, so ignore that byte, but replace with NULL")
            PokeA(*gmNetworkReceiveBuffer + nThisBytes - 1, 0) ; Replace with NULL - the standard string terminator. Added 28May2025 11.10.8be
            nThisBytes - 1
          EndIf
        Next n
        debugMsgN(sProcName, "nThisBytes=" + nThisBytes)
        
        If \bRAIDev
          bAddLF = #True  ; if RAI then force adding LF to end of outgoing message
        EndIf

        ; debugMsgN(sProcName, "bSupportOSCTextMsgs=" + strB(bSupportOSCTextMsgs) + ", bOSCTextMsg=" + strB(bOSCTextMsg))
        If bOSCTextMsg
          sOSCTextMsg = Trim(Trim(PeekS(nBuffStart, nThisBytes, #PB_Ascii)),#LF$)
          ; added 11Dec2017 11.6.2.2aj following reports from two users that ETC adds a comma to the end of OSC text messages
          sOSCTextMsg = RTrim(RTrim(sOSCTextMsg, ","))
          ; end added 11Dec2017 11.6.2.2aj
          debugMsgN(sProcName, "sOSCTextMsg=" + sOSCTextMsg)
          nSpacePtr = FindString(sOSCTextMsg, " ")
          If nSpacePtr > 1
            sPathOriginal = Left(sOSCTextMsg, nSpacePtr-1)
            sOSCTextParams = Trim(Mid(sOSCTextMsg, nSpacePtr+1))
            nOSCTextParamsLength = Len(sOSCTextParams)
            nParamStartPtr = 1
            For nParamCount = 1 To 3
              ; currently supports no more than 3 parameters (\sOSCTextParam1, \sOSCTextParam2 and \sOSCTextParam3)
              ; note that the first parameter is the RAI message id
              ; skip any leading spaces
              While nParamStartPtr <= nOSCTextParamsLength
                If Mid(sOSCTextParams, nParamStartPtr, 1) <> " "
                  Break
                EndIf
                nParamStartPtr + 1
              Wend
              If nParamStartPtr <= nOSCTextParamsLength
                If Mid(sOSCTextParams, nParamStartPtr, 1) = #DQUOTE$
                  ; start of string parameter
                  bEndQuoteFound = #False
                  nParamCurrPtr = nParamStartPtr + 1
                  While nParamCurrPtr <= nOSCTextParamsLength
                    If Mid(sOSCTextParams, nParamCurrPtr, 1) = #DQUOTE$
                      ; end of string parameter
                      bEndQuoteFound = #True
                      Break
                    EndIf
                    If Mid(sOSCTextParams, nParamCurrPtr, 1) = "\"
                      ; 'escape' character - skip over the next character
                      nParamCurrPtr + 1
                    EndIf
                    nParamCurrPtr + 1
                  Wend
                  nParamLength = nParamCurrPtr - nParamStartPtr - 1
                  sThisParam = UnescapeString(Mid(sOSCTextParams, (nParamStartPtr+1), nParamLength))
                  nParamStartPtr = nParamCurrPtr + 1
                Else
                  ; not a string parameter
                  bEndSpaceFound = #False
                  nParamCurrPtr = nParamStartPtr
                  While nParamCurrPtr <= nOSCTextParamsLength
                    If Mid(sOSCTextParams, nParamCurrPtr, 1) = " "
                      ; end of non-string parameter
                      bEndSpaceFound = #True
                      Break
                    EndIf
                    nParamCurrPtr + 1
                  Wend
                  nParamLength = nParamCurrPtr - nParamStartPtr
                  sThisParam = Mid(sOSCTextParams, nParamStartPtr, nParamLength)
                  nParamStartPtr = nParamCurrPtr + 1
                EndIf
                Select nParamCount
                  Case 1
                    sOSCTextParam1 = sThisParam
                  Case 2
                    sOSCTextParam2 = sThisParam
                  Case 3
                    sOSCTextParam3 = sThisParam
                EndSelect
              EndIf
            Next nParamCount
            debugMsgN(sProcName, "sOSCTextParam1=" + sOSCTextParam1 + ", sOSCTextParam2=" + sOSCTextParam2 + ", sOSCTextParam3=" + sOSCTextParam3)
          Else
            sPathOriginal = sOSCTextMsg
            sOSCTextParam1 = ""
            sOSCTextParam2 = ""
            sOSCTextParam3 = ""
          EndIf
          sDisplayMsg = sOSCTextMsg
          
        Else
          
          nPartNo = 1
          For n = 0 To (nThisBytes - 1)
            ; debugMsg(sProcName, "n=" + n + ", nThisBytes=" + nThisBytes + ", nPartNo=" + nPartNo)
            Select nPartNo
              Case 1
                ; extracting <path>
                ascAsciiChar = PeekA(nBuffStart + n)
                Select ascAsciiChar
                  Case 44
                    ; comma - precedes <type>
                    ; debugMsg(sProcName, "sPathOriginal=" + sPathOriginal)
                    sDisplayMsg + " ,"
                    nPartNo + 1
                  Case 0, 32
                    ; null or space - ignore
                  Default
                    ; save as the next character in <path>
                    sPathOriginal + Chr(ascAsciiChar)
                    sDisplayMsg = sPathOriginal
                EndSelect
                
              Case 2
                ; extracting <type> (may be more than one <type>, eg /info returns ssss as there are 4 string fields)
                ascAsciiChar = PeekA(nBuffStart + n)
                Select ascAsciiChar
                  Case 0, 32
                    ; null or space - treat as end of <type>, provided at least something has been saved in sTagTypes, otherwise just ignore
                    If sTagTypes
                      sDisplayMsg + sTagTypes + " "
                      If ascAsciiChar = 0
                        ; if genuine OSC then move to the next 4-byte boundary, but if not 'genuine' OSC but SCS text format then just allow loop to progress to the next character
                        n = next4BytePos(n+1) - 1
                      EndIf
                      nTagTypeCount = Len(sTagTypes)
                      If nTagTypeCount > 0
                        ReDim sString(nTagTypeCount-1)
                        ReDim nLong(nTagTypeCount-1)
                        ReDim fFloat(nTagTypeCount-1)
                      EndIf
                      nPartNo + 1
                      nTagTypeIndex = 1 ; changed 1Sep2016 11.5.2 (was 0, which was incorrect as Mid() start position is 1-based not 0-based)
                      sThisTagType = Mid(sTagTypes, nTagTypeIndex, 1)
                      debugMsgN(sProcName, "sTagTypes=" + sTagTypes + ", sThisTagType=" + sThisTagType)
                    EndIf
                  Default
                    ; save as the next character in <type>
                    sTagTypes + Chr(ascAsciiChar)
                EndSelect
                
              Case 3
                ; extracting tag values
                ; debugMsg(sProcName, "sTagTypes=" + sTagTypes + ", sThisTagType=" + sThisTagType + ", nTagTypeIndex=" + nTagTypeIndex + ", nLongIndex=" + nLongIndex + ", n=" + n)
                Select sThisTagType
                  Case Chr(0)
                    ; null - end of message
                    Break
                    
                  Case "f"
                    PokeB(*mFloat+3, PeekB(nBuffStart+n+0))
                    PokeB(*mFloat+2, PeekB(nBuffStart+n+1))
                    PokeB(*mFloat+1, PeekB(nBuffStart+n+2))
                    PokeB(*mFloat+0, PeekB(nBuffStart+n+3))
                    fFloat(nFloatIndex) = PeekF(*mFloat)
                    sDisplayMsg + StrF(fFloat(nFloatIndex),2) + " "
                    ; debugMsgN(sProcName, "fFloat(" + nFloatIndex + ")=" + StrF(fFloat(nFloatIndex)))
                    nFloatIndex + 1
                    nTagTypeIndex + 1
                    sThisTagType = Mid(sTagTypes, nTagTypeIndex, 1)
                    n = next4BytePos(n+4) - 1
                    
                  Case "i"
                    CheckSubInRange(nLongIndex, ArraySize(nLong()), "nLong()")
                    nLong(nLongIndex) = xchEndianL(PeekL(nBuffStart + n))
                    sDisplayMsg + Str(nLong(nLongIndex)) + " "
                    ; debugMsgN(sProcName, "n=" + n + ", PeekL(nBuffStart + " + n + ")=" + PeekL(nBuffStart + n))
                    debugMsgN(sProcName, "nLong(" + nLongIndex + ")=" + nLong(nLongIndex))
                    nLongIndex + 1
                    nTagTypeIndex + 1
                    sThisTagType = Mid(sTagTypes, nTagTypeIndex, 1)
                    ; debugMsg(sProcName, "Mid(" + #DQUOTE$ + sTagTypes + #DQUOTE$ + ", " + nTagTypeIndex + ", 1) returned " + #DQUOTE$ + sThisTagType + #DQUOTE$)
                    n = next4BytePos(n+4) - 1
                    ; debugMsgN(sProcName, "(i next byte pos) n=" + n)
                    
                  Case "s"
                    sUTF8String = PeekS(nBuffStart + n, -1, #PB_UTF8)
                    ; debugMsgN(sProcName, "n=" + n + ", PeekS(nBuffStart + " + n + ", -1, #PB_UTF8)=" + PeekS(nBuffStart + n, -1, #PB_UTF8))
                    ; debugMsg0(sProcName, "sUTF8String=" + sUTF8String)
                    sString(nStringIndex) + sUTF8String
                    sDisplayMsg + sUTF8String
                    n + Len(sUTF8String) + 1 ; + 1 to point to the trailing null
                    ; n = next4BytePos(n+1) - 1
                    n = next4BytePos(n) - 1 ; Changed 3Jul2023 11.10.0bm
                    ; debugMsgN(sProcName, "(s next byte pos) n=" + n)
                    nStringIndex + 1
                    nTagTypeIndex + 1
                    sThisTagType = Mid(sTagTypes, nTagTypeIndex, 1)
                    sDisplayMsg + " "
                    
                EndSelect ; EndSelect sThisTagType
                
            EndSelect ; EndSelect nPartNo
          Next n
        EndIf
        
      EndIf
      
;       debugMsgN(sProcName, "sPathOriginal=" + sPathOriginal + ", sTagTypes=" + sTagTypes)
      \bAddLF = bAddLF
      \bOSCTextMsg = bOSCTextMsg
      \sOSCPathOriginal = sPathOriginal
      If bOSCTextMsg
        \sOSCPath = RemoveString(sPathOriginal, "_" ,#PB_String_CaseSensitive, 2, 1)  ; changes paths like "/_ctrl/go" to "/ctrl/go" to standardize later processing
        \sOSCTextParam1 = sOSCTextParam1
        \sOSCTextParam2 = sOSCTextParam2
        
      Else  ; bOSCTextMsg = #False
        \sOSCPath = sPathOriginal
        \sOSCTagTypes = sTagTypes
        \nOSCStringCount = CountString(sTagTypes,"s")
        ; debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\sOSCTagTypes=" + \sOSCTagTypes + ", \nOSCStringCount=" + \nOSCStringCount)
        If \nOSCStringCount > 0
          ReDim \sOSCString(\nOSCStringCount-1)
          For n = 0 To (\nOSCStringCount-1)
            debugMsgN(sProcName, "sString(" + n + ")=" + sString(n))
            CheckSubInRange(n,ArraySize(sString()),"sString()")
            CheckSubInRange(n,ArraySize(\sOSCString()),"\sOSCString()")
            \sOSCString(n) = RTrim(RTrim(sString(n)), ",")  ; added RTrim's following reports from two users that ETC adds a comma to the end of text commands
          Next n
        EndIf
        
        \nOSCLongCount = CountString(sTagTypes,"i")
        If \nOSCLongCount > 0
          ReDim \nOSCLong(\nOSCLongCount-1)
          For n = 0 To (\nOSCLongCount-1)
            debugMsgN(sProcName, "nLong(" + n + ")=" + nLong(n))
            CheckSubInRange(n,ArraySize(nLong()),"nLong()")
            CheckSubInRange(n,ArraySize(\nOSCLong()),"\nOSCLong()")
            \nOSCLong(n) = nLong(n)
          Next n
        EndIf
        
        \nOSCFloatCount = CountString(sTagTypes,"f")
        If \nOSCFloatCount > 0
          ReDim \fOSCFloat(\nOSCFloatCount-1)
          For n = 0 To (\nOSCFloatCount-1)
            debugMsgN(sProcName, "fFloat(" + n + ")=" + StrF(fFloat(n)))
            CheckSubInRange(n,ArraySize(fFloat()),"fFloat()")
            CheckSubInRange(n,ArraySize(\fOSCFloat()),"\fOSCFloat()")
            \fOSCFloat(n) = fFloat(n)
          Next n
        EndIf
        
;         ; INFO TEMP START !!!!!!!!!!!!!!!!!!!!!!!!!!!!
;         If \sOSCPath = "/ch/03/mix/on"
;           debugMsg0(sProcName, "SIMULATING BTN ON")
;           \sOSCPath = "/-stat/userpar/17/value"
;           \nOSCLong(0) = 127
;           sDisplayMsg = \sOSCPath + " ,i " + \nOSCLong(0)
;         EndIf
;         ; INFO TEMP END !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
      EndIf ; EndIf bOSCTextMsg / Else
      
      \sOSCDisplayMsg = Trim(removeNonPrintingChars(sDisplayMsg))
      ; debugMsgN(sProcName, "\sOSCDisplayMsg=" + \sOSCDisplayMsg)
      ; debugMsg(sProcName, "\sOSCDisplayMsg=" + \sOSCDisplayMsg) ; 25Apr2019: changed debugMsgN() to debugMsg() to always log the OSC message received
      
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure getOSCResponse(nNetworkControlPtr, bHideTracing=#False, sExpectedPathOfResponse.s="")
  PROCNAMEC()
  Protected bResult
  Protected qWaitUntil.q
  Protected n
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If *gmNetworkReceiveBuffer
        If \nClientConnection
          ; wait for a response up until the timeout period
          qWaitUntil = \qSendTime + gnUDPReceiveTimeOut
          ; debugMsgN(sProcName, "\qSendTime=" + \qSendTime + ", qWaitUntil=" + qWaitUntil)
          \qReceiveTime = -1
          While #True
            If NetworkClientEvent(\nClientConnection) = #PB_NetworkEvent_Data
              debugMsgN(sProcName, "NetworkClientEvent(" + decodeHandle(\nClientConnection) + ") returned #PB_NetworkEvent_Data")
              gnNetworkBytesReceived = ReceiveNetworkData(\nClientConnection, *gmNetworkReceiveBuffer, #SCS_MEM_SIZE_NETWORK_BUFFERS)
              debugMsgN2(sProcName, "ReceiveNetworkData(" + decodeHandle(\nClientConnection) + ", *gmNetworkReceiveBuffer, " + #SCS_MEM_SIZE_NETWORK_BUFFERS + ")", gnNetworkBytesReceived)
              If gnNetworkBytesReceived > 0
                \qReceiveTime = ElapsedMilliseconds()
                GetLocalTime_(@\rReceiveTime)
                bResult = #True
                unpackOSCMsg(nNetworkControlPtr, #False, bHideTracing)
                If sExpectedPathOfResponse
                  If \sOSCPath <> sExpectedPathOfResponse
                    debugMsg(sProcName, "Expected " + sExpectedPathOfResponse + " but received \sOSCPath=" + \sOSCPath)
                    debugMsg(sProcName, ".. \sOSCDisplayMsg=" + \sOSCDisplayMsg)
                    Debug sProcName + ": Expected " + sExpectedPathOfResponse + " but received \sOSCPath=" + \sOSCPath
                    Debug sProcName + ": .. \sOSCDisplayMsg=" + \sOSCDisplayMsg
                    Continue
                  EndIf
                EndIf
                Break
              EndIf
            EndIf
            If (qWaitUntil - ElapsedMilliseconds()) > 0
              Delay(2)
            Else
              debugMsgN(sProcName, "timed out - \qSendTime=" + \qSendTime + ", qWaitUntil=" + qWaitUntil + ", \sMsgSent=" + \sMsgSent)
              Break ; timed out
            EndIf
          Wend
        EndIf
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure getMaxX32ItemIndex(nNetworkControlPtr, nOSCCmdType)
  PROCNAMEC()
  Protected nMaxX32ItemIndex
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    Select nOSCCmdType
      Case #SCS_CS_OSC_MUTECHANNEL
        nMaxX32ItemIndex = \nMaxChannel
      Case #SCS_CS_OSC_MUTEDCAGROUP
        nMaxX32ItemIndex = \nMaxDCAGroup
      Case #SCS_CS_OSC_MUTEAUXIN
        nMaxX32ItemIndex = \nMaxAuxIn
      Case #SCS_CS_OSC_MUTEFXRTN
        nMaxX32ItemIndex = \nMaxFXReturn
      Case #SCS_CS_OSC_MUTEBUS
        nMaxX32ItemIndex = \nMaxBus
      Case #SCS_CS_OSC_MUTEMATRIX
        nMaxX32ItemIndex = \nMaxMatrix
      Case #SCS_CS_OSC_MUTEMG
        nMaxX32ItemIndex = \nMaxMuteGroup
    EndSelect
  EndWith
  ProcedureReturn nMaxX32ItemIndex
EndProcedure

Procedure.s makeX32ItemId(nOSCCmdType, nItemNumber)
  PROCNAMEC()
  Protected sItemId.s
  
  ; procedure modified 8Jun2019 11.8.1.2ab to remove spaces from and to correctly fromat some item id's, eg "CH01" instead of "CH 1"
  ; this change applied following issue reported by Roei Luster where 11.8.1 was not recognising some items saved by an earlier version of SCS
  
  Select nOSCCmdType
    Case #SCS_CS_OSC_MUTECHANNEL
      sItemId = "Ch" + RSet(Str(nItemNumber),2,"0")
    Case #SCS_CS_OSC_MUTEDCAGROUP
      sItemId = "DCA" + nItemNumber
    Case #SCS_CS_OSC_MUTEAUXIN
      sItemId = "Aux" + RSet(Str(nItemNumber),2,"0")
    Case #SCS_CS_OSC_MUTEFXRTN
      sItemId = "Fx" + Str(((nItemNumber-1)>>1)+1)
      If nItemNumber & 1
        sItemId + "L"
      Else
        sItemId + "R"
      EndIf
    Case #SCS_CS_OSC_MUTEBUS
      sItemId = "Bus" + nItemNumber
    Case #SCS_CS_OSC_MUTEMAINLR
      sItemId = "Main LR"
    Case #SCS_CS_OSC_MUTEMAINMC
      sItemId = "Main M/C"
    Case #SCS_CS_OSC_MUTEMATRIX
      sItemId = "Matrix " + nItemNumber
    Case #SCS_CS_OSC_MUTEMG
      sItemId = "MuteGrp " + nItemNumber
    Case #SCS_CS_OSC_GOCUE
      sItemId = "Cue " + nItemNumber
    Case #SCS_CS_OSC_GOSCENE
      sItemId = "Scene " + nItemNumber
    Case #SCS_CS_OSC_GOSNIPPET
      sItemId = "Snippet " + nItemNumber
  EndSelect
  ProcedureReturn sItemId
  
EndProcedure

Procedure.s makeX32ItemInfo(nOSCCmdType, nItemNumber, sItemText.s)
  PROCNAMEC()
  Protected sItemInfo.s
  
  sItemInfo = makeX32ItemId(nOSCCmdType, nItemNumber)
  If sItemInfo <> sItemText
    sItemInfo + ": " + sItemText
  EndIf
  ProcedureReturn sItemInfo

EndProcedure

Procedure getX32ChannelNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sChannel()) < 31
      ReDim \sChannel(31)
    EndIf
    \nMaxChannel = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 31
        \sChannel(n) = "Ch" + RSet(Str(n+1),2,"0")
        \nMaxChannel = n
        debugMsg(sProcName, "\sChannel(" + n + ")=" + \sChannel(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 31
        ; nb X32 channel numbers are 1-32 (ie base 1)
        sAddress = "/ch/" + RSet(Str(n+1),2,"0") + "/config/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sChannel(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg channel scribble strip name " BR" will be stored as "BR"
            CompilerIf #c_emulate_x32_returning_scribblestrip_names
              If Len(\sChannel(n)) = 0
                Select (n + 1) ; nb channel numbers are 1-32 (ie base 1)
                  Case 1: \sChannel(n) = "Carole"
                  Case 2: \sChannel(n) = "Clint"
                  Case 3: \sChannel(n) = "Elaine"
                  Case 4: \sChannel(n) = "Elisabeth"
                  Case 5: \sChannel(n) = "Helen"
                  Case 6: \sChannel(n) = "Lee"
                  Case 7: \sChannel(n) = "Marilyn"
                  Case 8: \sChannel(n) = "Robyn"
                  Case 9: \sChannel(n) = "Sarah"
                  Case 10: \sChannel(n) = "Tauba"
                  Case 11: \sChannel(n) = "Tim"
                  Case 12: \sChannel(n) = "Wendy"
                  Case 14: \sChannel(n) = "MC"
                EndSelect
              EndIf
            CompilerEndIf
            \nMaxChannel = n
            If bTraceNames : debugMsg(sProcName, "\sChannel(" + n + ")=" + \sChannel(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxChannel=" + \nMaxChannel) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32AuxInNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sAuxIn()) < 7
      ReDim \sAuxIn(7)
    EndIf
    \nMaxAuxIn = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 7
        \sAuxIn(n) = "Aux" + Str(n+1)
        \nMaxAuxIn = n
        debugMsg(sProcName, "\sAuxIn(" + n + ")=" + \sAuxIn(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 7
        ; nb X32 AuxIn numbers are 1-8 (ie base 1)
        sAddress = "/auxin/" + RSet(Str(n+1),2,"0") + "/config/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sAuxIn(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg AuxIn scribble strip name " BR" will be stored as "BR"
            CompilerIf #c_emulate_x32_returning_scribblestrip_names
              If Len(\sAuxIn(n)) = 0
                Select (n + 1) ; X32 AuxIn numbers are 1-8 (ie base 1)
                  Case 1: \sAuxIn(n) = "Player1"
                  Case 4: \sAuxIn(n) = "Device2"
                  Case 5: \sAuxIn(n) = "Something3"
                EndSelect
              EndIf
            CompilerEndIf
            \nMaxAuxIn = n
            If bTraceNames : debugMsg(sProcName, "\sAuxIn(" + n + ")=" + \sAuxIn(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxAuxIn=" + \nMaxAuxIn) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32FXReturnNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n, nNumber
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sFXReturn()) < 7
      ReDim \sFXReturn(7)
    EndIf
    \nMaxFXReturn = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 7
        \sFXReturn(n) = "Fx" + Str((n>>1)+1)
        If n & 1
          \sFXReturn(n) + "R"
        Else
          \sFXReturn(n) + "L"
        EndIf
        \nMaxFXReturn = n
        debugMsg(sProcName, "\sFXReturn(" + n + ")=" + \sFXReturn(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 7
        ; nb X32 FX return numbers are 1-8 (ie base 1)
        sAddress = "/fxrtn/" + RSet(Str(n+1),2,"0") + "/config/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sFXReturn(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg channel scribble strip name " BR" will be stored as "BR"
            If Len(\sFXReturn(n)) = 0
              \sFXReturn(n) = "Fx" + Str((n>>1)+1)
              If n & 1
                \sFXReturn(n) + "R"
              Else
                \sFXReturn(n) + "L"
              EndIf
            EndIf
            \nMaxFXReturn = n
            If bTraceNames : debugMsg(sProcName, "\sFXReturn(" + n + ")=" + \sFXReturn(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxFXReturn=" + \nMaxFXReturn) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32BusNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sBus()) < 15
      ReDim \sBus(15)
    EndIf
    \nMaxBus = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 15
        If n < 9
          \sBus(n) = "Bus" + Str(n+1)
        Else
          \sBus(n) = "Bs" + Str(n+1)
        EndIf
        \nMaxBus = n
        debugMsg(sProcName, "\sBus(" + n + ")=" + \sBus(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 15
        ; nb X32 Bus numbers are 1-16 (ie base 1)
        sAddress = "/bus/" + RSet(Str(n+1),2,"0") + "/config/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sBus(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg Bus scribble strip name " BR" will be stored as "BR"
            CompilerIf #c_emulate_x32_returning_scribblestrip_names
              If Len(\sBus(n)) = 0
                Select (n + 1) ; X32 Bus numbers are 1-16 (ie base 1)
                  Case 1: \sBus(n) = "FOH"
                  Case 2: \sBus(n) = "Rear"
                  Case 3: \sBus(n) = "Left Front"
                  Case 4: \sBus(n) = "Right Front"
                EndSelect
              EndIf
            CompilerEndIf
            \nMaxBus = n
            If bTraceNames : debugMsg(sProcName, "\sBus(" + n + ")=" + \sBus(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxBus=" + \nMaxBus) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32MatrixNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sMatrix()) < 5
      ReDim \sMatrix(5)
    EndIf
    \nMaxMatrix = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 5
        \sMatrix(n) = "Mtx" + Str(n+1)
        \nMaxMatrix = n
        debugMsg(sProcName, "\sMatrix(" + n + ")=" + \sMatrix(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 5
        ; nb X32 Matrix numbers are 1-6 (ie base 1)
        sAddress = "/mtx/" + RSet(Str(n+1),2,"0") + "/config/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sMatrix(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg Matrix scribble strip name " BR" will be stored as "BR"
            \nMaxMatrix = n
            If bTraceNames : debugMsg(sProcName, "\sMatrix(" + n + ")=" + \sMatrix(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxMatrix=" + \nMaxMatrix) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32DCAGroupNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sDCAGroup()) < 7
      ReDim \sDCAGroup(7)
    EndIf
    \nMaxDCAGroup = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 7
        \sDCAGroup(n) = "DCA" + Str(n+1)
        \nMaxDCAGroup = n
        debugMsg(sProcName, "\sDCAGroup(" + n + ")=" + \sDCAGroup(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 7
        ; nb X32 DCA Group numbers are 1-8 (ie base 1)
        sAddress = "/dca/" + Str(n+1) + "/config/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sDCAGroup(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg DCAGroup scribble strip name " BR" will be stored as "BR"
            CompilerIf #c_emulate_x32_returning_scribblestrip_names
              If Len(\sDCAGroup(n)) = 0
                Select (n + 1) ; X32 DCA Group numbers are 1-8 (ie base 1)
                  Case 1: \sDCAGroup(n) = "Vocals"
                  Case 2: \sDCAGroup(n) = "Band"
                EndSelect
              EndIf
            CompilerEndIf
            \nMaxDCAGroup = n
            If bTraceNames : debugMsg(sProcName, "\sDCAGroup(" + n + ")=" + \sDCAGroup(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxDCAGroup=" + \nMaxDCAGroup) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32MainNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sMain()) < 1
      ReDim \sMain(1)
    EndIf
    \nMaxMain = -1
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      For n = 0 To 1
        If n = 0
          \sMain(n) = "LR"
        Else
          \sMain(n) = "M/C"
        EndIf
        \nMaxMain = n
        debugMsg(sProcName, "\sMain(" + n + ")=" + \sMain(n))
      Next n
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 1
        If n = 0
          sAddress = "/main/st/config/name" ; main stereo
        Else
          sAddress = "/main/m/config/name"  ; main mono
        EndIf
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sMain(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!) eg Main scribble strip name " BR" will be stored as "BR"
            If Len(\sMain(n)) = 0
              If n = 0
                \sMain(n) = "LR"
              Else
                \sMain(n) = "M/C"
              EndIf
            EndIf
            \nMaxMain = n
            If bTraceNames : debugMsg(sProcName, "\sMain(" + n + ")=" + \sMain(n)) : EndIf
          EndIf
        EndIf
      Next n
    EndIf
    If bTraceNames : debugMsg(sProcName, "\nMaxMain=" + \nMaxMain) : EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32CueNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sCue()) < 99
      ReDim \sCue(99)
    EndIf
    \nMaxCue = -1
    
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      ; no action
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 99
        ; nb X32 cue numbers are 0-99 (ie base 0)
        sAddress = "/-show/showfile/cue/" + RSet(Str(n),3,"0") + "/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sCue(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!)
            If Len(\sCue(n)) > 0
              \nMaxCue = n
              If bTraceNames : debugMsg(sProcName, "\sCue(" + n + ")=" + \sCue(n)) : EndIf
            EndIf
          EndIf
        EndIf
      Next n
    EndIf
    
    If bTraceNames : debugMsg(sProcName, "\nMaxCue=" + \nMaxCue) : EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32MuteGroups(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sMuteGroup()) < 5
      ReDim \sMuteGroup(5)
    EndIf
    ; mute groups (exactly 6, unnamed, so not dependent on X32 currently being connected)
;     For n = 0 To 5
;       \sMuteGroup(n) = Str(n+1)
;     Next n
    \nMaxMuteGroup = 5
    
    If bTraceNames : debugMsg(sProcName, "\nMaxMuteGroup=" + \nMaxMuteGroup) : EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32SceneNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sScene()) < 99
      ReDim \sScene(99)
    EndIf
    \nMaxScene = -1
    
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      ; no action
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 99
        ; nb X32 scene numbers are 0-99 (ie base 0)
        sAddress = "/-show/showfile/scene/" + RSet(Str(n),3,"0") + "/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sScene(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!)
            CompilerIf #c_emulate_x32_returning_scribblestrip_names
              If Len(\sScene(n)) = 0
                Select n ; X32 scene numbers are 0-99 (ie base 0)
                  Case 0: \sScene(n) = "Christmas 2024"
                  Case 1: \sScene(n) = "Much Ado"
                  Case 2: \sScene(n) = "Jane Thinks Mink"
                  Case 3: \sScene(n) = "Can't You See We're Acting?"
                EndSelect
              EndIf
            CompilerEndIf
            If Len(\sScene(n)) > 0
              \nMaxScene = n
              If bTraceNames : debugMsg(sProcName, "\sScene(" + n + ")=" + \sScene(n)) : EndIf
            EndIf
          EndIf
        EndIf
      Next n
    EndIf
    
    If bTraceNames : debugMsg(sProcName, "\nMaxScene=" + \nMaxScene) : EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32SnippetNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bGetRemDevScribbleStripNames=" + strB(bGetRemDevScribbleStripNames))
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If ArraySize(\sSnippet()) < 99
      ReDim \sSnippet(99)
    EndIf
    \nMaxSnippet = -1
    
    If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun Or (bGetRemDevScribbleStripNames = #False)
      ; no action
    ElseIf *gmNetworkSendBuffer
      For n = 0 To 99
        ; nb X32 snippet numbers are 0-99 (ie base 0)
        sAddress = "/-show/showfile/snippet/" + RSet(Str(n),3,"0") + "/name"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sSnippet(n) = Trim(sStringData)  ; note: also trims any leading spaces (intentionally!)
            If Len(\sSnippet(n)) > 0
              \nMaxSnippet = n
              If bTraceNames : debugMsg(sProcName, "\sSnippet(" + n + ")=" + \sSnippet(n)) : EndIf
            EndIf
          EndIf
        EndIf
      Next n
    EndIf
    
    If bTraceNames : debugMsg(sProcName, "\nMaxSnippet=" + \nMaxSnippet) : EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32Names(nNetworkControlPtr, bIncludeCueNamesEtc=#True)
  PROCNAMEC()
  Protected nThreadState
  Protected nLogicalDev, bGetRemDevScribbleStripNames
  Protected bTraceNames = #True
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bIncludeCueNamesEtc=" + strB(bIncludeCueNamesEtc))
  
  If gnThreadNo <> #SCS_THREAD_NETWORK
    nThreadState = THR_getThreadState(#SCS_THREAD_NETWORK)
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_NETWORK)")
    THR_suspendAThreadAndWait(#SCS_THREAD_NETWORK)
  EndIf
  
  nLogicalDev = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_CTRL_SEND, gaNetworkControl(nNetworkControlPtr)\sLogicalDev)
  If nLogicalDev >= 0
    bGetRemDevScribbleStripNames = grProd\aCtrlSendLogicalDevs(nLogicalDev)\bGetRemDevScribbleStripNames
  EndIf

  ; nb all the following procedures handle \bDummy = #True
  getX32AuxInNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32BusNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32ChannelNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32DCAGroupNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32FXReturnNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32MainNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32MatrixNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  getX32MuteGroups(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  If bIncludeCueNamesEtc
    getX32CueNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
    getX32SceneNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
    getX32SnippetNames(nNetworkControlPtr, bGetRemDevScribbleStripNames, bTraceNames)
  EndIf
  
  If gnThreadNo <> #SCS_THREAD_NETWORK
    If nThreadState = #SCS_THREAD_STATE_ACTIVE
      debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_NETWORK)")
      THR_resumeAThread(#SCS_THREAD_NETWORK)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkAllX32NamesReceived(nNetworkControlPtr)
  PROCNAMEC()
  Protected bAllReceived
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If \nChannelNameCount >= (\nMaxChannel + 1) And
       \nAuxInNameCount >= (\nMaxAuxIn + 1) And
       \nFXReturnNameCount >= (\nMaxFXReturn + 1) And
       \nBusNameCount >= (\nMaxBus + 1) And
       \nMatrixNameCount >= (\nMaxMatrix + 1) And
       \nMainNameCount >= (\nMaxMain + 1) And
       \nCueNameCount >= (\nMaxCue + 1) And
       \nSceneNameCount >= (\nMaxScene + 1) And
       \nSnippetNameCount >= (\nMaxSnippet + 1)
      bAllReceived = #True
    EndIf
;     debugMsg(sProcName, "\nChannelNameCount=" + \nChannelNameCount + ", \nMaxChannel=" + \nMaxChannel +
;                         ", \nAuxInNameCount=" + \nAuxInNameCount + ", \nMaxAuxIn=" + \nMaxAuxIn +
;                         ", \nFXReturnNameCount=" + \nFXReturnNameCount + ", \nMaxFXReturn=" + \nMaxFXReturn +
;                         ", \nBusNameCount=" + \nBusNameCount + ", \nMaxBus=" + \nMaxBus +
;                         ", \nMatrixNameCount=" + \nMatrixNameCount + ", \nMaxMatrix=" + \nMaxMatrix +
;                         ", \nMainNameCount=" + \nMainNameCount + ", \nMaxMain=" + \nMaxMain +
;                         ", \nCueNameCount=" + \nCueNameCount + ", \nMaxCue=" + \nMaxCue +
;                         ", \nSceneNameCount=" + \nSceneNameCount + ", \nMaxScene=" + \nMaxScene +
;                         ", \nSnippetNameCount=" + \nSnippetNameCount + ", \nMaxSnippet=" + \nMaxSnippet)
  EndWith
  
  ProcedureReturn bAllReceived
EndProcedure

Procedure getX32ItemNumberForItemName(nNetworkControlPtr, nOSCCmdType, sOSCItemName.s)
  PROCNAMEC()
  Protected nOSCItemNumber, n
  
  nOSCItemNumber = grCtrlSendDef\nOSCItemNr
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    Select nOSCCmdType
      Case #SCS_CS_OSC_MUTEAUXIN
        For n = 0 To \nMaxAuxIn
          If \sAuxIn(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_MUTEBUS
        For n = 0 To \nMaxBus
          If \sBus(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_MUTECHANNEL
        For n = 0 To \nMaxChannel
          If \sChannel(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_MUTEDCAGROUP
        For n = 0 To \nMaxDCAGroup
          If \sDCAGroup(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_MUTEFXRTN
        For n = 0 To \nMaxFXReturn
          If \sFXReturn(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_MUTEMAINLR, #SCS_CS_OSC_MUTEMAINMC
        For n = 0 To \nMaxMain
          If \sMain(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_MUTEMATRIX
        For n = 0 To \nMaxMatrix
          If \sMatrix(n) = sOSCItemName
            nOSCItemNumber = (n + 1)
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_GOCUE
        For n = 0 To \nMaxCue
          If \sCue(n) = sOSCItemName
            nOSCItemNumber = n
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_GOSCENE
        For n = 0 To \nMaxScene
          If \sScene(n) = sOSCItemName
            nOSCItemNumber = n
            Break
          EndIf
        Next n
      Case #SCS_CS_OSC_GOSNIPPET
        For n = 0 To \nMaxSnippet
          If \sSnippet(n) = sOSCItemName
            nOSCItemNumber = n
            Break
          EndIf
        Next n
    EndSelect
  EndWith
  
  ProcedureReturn nOSCItemNumber
EndProcedure

Procedure.s getX32ItemNameForItemNumber(nNetworkControlPtr, nOSCCmdType, nOSCItemNumber)
  PROCNAMEC()
  Protected sOSCItemName.s, nItemIndex
  
  sOSCItemName = grCtrlSendDef\sOSCItemString
  nItemIndex = nOSCItemNumber - 1
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    Select nOSCCmdType
      Case #SCS_CS_OSC_MUTEAUXIN
        If nItemIndex >= 0 And nItemIndex <= \nMaxAuxIn
          sOSCItemName = \sAuxIn(nItemIndex)
        EndIf
      Case #SCS_CS_OSC_MUTEBUS
        If nItemIndex >= 0 And nItemIndex <= \nMaxBus
          sOSCItemName = \sBus(nItemIndex)
        EndIf
      Case #SCS_CS_OSC_MUTECHANNEL
        If nItemIndex >= 0 And nItemIndex <= \nMaxChannel
          sOSCItemName = \sChannel(nItemIndex)
        EndIf
      Case #SCS_CS_OSC_MUTEDCAGROUP
        If nItemIndex >= 0 And nItemIndex <= \nMaxDCAGroup
          sOSCItemName = \sDCAGroup(nItemIndex)
        EndIf
      Case #SCS_CS_OSC_MUTEFXRTN
        If nItemIndex >= 0 And nItemIndex <= \nMaxFXReturn
          sOSCItemName = \sFXReturn(nItemIndex)
        EndIf
      Case #SCS_CS_OSC_MUTEMAINLR, #SCS_CS_OSC_MUTEMAINMC
        If nItemIndex >= 0 And nItemIndex <= \nMaxMain
          sOSCItemName = \sMain(nItemIndex)
        EndIf
      Case #SCS_CS_OSC_MUTEMATRIX
        If nItemIndex >= 0 And nItemIndex <= \nMaxMatrix
          sOSCItemName = \sMatrix(nItemIndex)
        EndIf
      Default
        nItemIndex = nOSCItemNumber
        Select nOSCCmdType
          Case #SCS_CS_OSC_GOCUE
            If nItemIndex >= 0 And nItemIndex <= \nMaxCue
              sOSCItemName = \sCue(nItemIndex)
            EndIf
          Case #SCS_CS_OSC_GOSCENE
            If nItemIndex >= 0 And nItemIndex <= \nMaxScene
              sOSCItemName = \sScene(nItemIndex)
            EndIf
          Case #SCS_CS_OSC_GOSNIPPET
            If nItemIndex >= 0 And nItemIndex <= \nMaxSnippet
              sOSCItemName = \sSnippet(nItemIndex)
            EndIf
        EndSelect
    EndSelect
  EndWith
  ProcedureReturn sOSCItemName
  
EndProcedure

Procedure loadAnyMissingOSCItemInfo(nNetworkControlPtr, pCuePtr=-1, bFirstCall=#False)
  PROCNAMEC()
  Protected nFirstCuePtr, nLastCuePtr, i, j, n, sOSCItemName.s
  Static nCallCount
  
  ; debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", pCuePtr=" + getCueLabel(pCuePtr) + ", bFirstCall=" + strB(bFirstCall))
  
  If bFirstCall
    nCallCount = 0
  EndIf
  nCallCount + 1
  
  If checkAllX32NamesReceived(nNetworkControlPtr) = #False
    If nCallCount < 20
      samAddRequest(#SCS_SAM_LOAD_MISSING_OSC_INFO, nNetworkControlPtr, 0, pCuePtr, "", ElapsedMilliseconds()+250, #False)
    EndIf
    
  Else ; checkAllX32NamesReceived(nNetworkControlPtr) returned #True
    If pCuePtr > 0
      nFirstCuePtr = pCuePtr
      nLastCuePtr = pCuePtr
    Else
      nFirstCuePtr = 1
      nLastCuePtr = gnLastCue
    EndIf
    For i = nFirstCuePtr To nLastCuePtr
      If aCue(i)\bSubTypeM
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeM
            For n = 0 To #SCS_MAX_CTRL_SEND
              With aSub(j)\aCtrlSend[n]
                If \bIsOSC
                  If (\nOSCItemNr = grCtrlSendDef\nOSCItemNr) And (\sOSCItemString <> grCtrlSendDef\sOSCItemString)
                    \nOSCItemNr = getX32ItemNumberForItemName(nNetworkControlPtr, \nOSCCmdType, \sOSCItemString)
                  ElseIf (\sOSCItemString = grCtrlSendDef\sOSCItemString) And (\nOSCItemNr <> grCtrlSendDef\nOSCItemNr)
                    \sOSCItemString = getX32ItemNameForItemNumber(nNetworkControlPtr, \nOSCCmdType, \nOSCItemNr)
                  EndIf
                  \sDisplayInfo = \sCSLogicalDev + " " + buildOSCDisplayInfo(@aSub(j), n)
                EndIf
              EndWith
            Next n
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    Next i
    ; debugMsg(sProcName, "calling debugCuePtrs(" + getCueLabel(pCuePtr) + ")")
    ; debugCuePtrs(pCuePtr)
  EndIf
  
EndProcedure

Procedure getX32ItemOnStates(nNetworkControlPtr, nOSCCmdType, bSuspendNetworkThread)
  PROCNAMEC()
  Protected sAddressStart.s, sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected nLongData
  Protected nThreadState
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  Protected nMaxX32ItemIndex
  
  ;  #SCS_CS_OSC_MUTECHANNEL   /ch/[01...32]/mix/on
  ;  #SCS_CS_OSC_MUTEAUXIN     /auxin/[01...08]/mix/on
  ;  #SCS_CS_OSC_MUTEFXRTN     /fxrtn/[01...08]/mix/on
  ;  #SCS_CS_OSC_MUTEBUS       /bus/[01...16]/mix/on
  ;  #SCS_CS_OSC_MUTEMATRIX    /mtx/[01...06]/mix/on
  ;  #SCS_CS_OSC_MUTEMG        /config/mute/[1...6]
  ;  #SCS_CS_OSC_MUTEDCAGROUP  /dca/[1...8]/on

  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nOSCCmdType=" + decodeOSCCmdType(nOSCCmdType) + ", bSuspendNetworkThread=" + strB(bSuspendNetworkThread))
  
  If bSuspendNetworkThread
    nThreadState = THR_getThreadState(#SCS_THREAD_NETWORK)
    THR_suspendAThreadAndWait(#SCS_THREAD_NETWORK)
  EndIf
  
  nMaxX32ItemIndex = getMaxX32ItemIndex(nNetworkControlPtr, nOSCCmdType)
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    If nMaxX32ItemIndex >= 0
      If ArraySize(\nX32ItemOn()) < nMaxX32ItemIndex
        ReDim \nX32ItemOn(nMaxX32ItemIndex)
      EndIf
      If gaNetworkControl(nNetworkControlPtr)\bNWDummy Or gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun ; added bNWIgnoreDevThisRun 16Mar2020 11.8.2.3aa
        For n = 0 To nMaxX32ItemIndex
          \nX32ItemOn(n) = 1
        Next n
      ElseIf *gmNetworkSendBuffer
        For n = 0 To nMaxX32ItemIndex
          Select nOSCCmdType
            Case #SCS_CS_OSC_MUTECHANNEL
              sAddress = "/ch/" + RSet(Str(n+1),2,"0") + "/mix/on"
            Case #SCS_CS_OSC_MUTEDCAGROUP
              sAddress = "/dca/" + Str(n+1) + "/on"
            Case #SCS_CS_OSC_MUTEAUXIN
              sAddress = "/auxin/" + RSet(Str(n+1),2,"0") + "/mix/on"
            Case #SCS_CS_OSC_MUTEFXRTN
              sAddress = "/fxrtn/" + RSet(Str(n+1),2,"0") + "/mix/on"
            Case #SCS_CS_OSC_MUTEBUS
              sAddress = "/bus/" + RSet(Str(n+1),2,"0") + "/mix/on"
            Case #SCS_CS_OSC_MUTEMATRIX
              sAddress = "/mtx/" + RSet(Str(n+1),2,"0") + "/mix/on"
            Case #SCS_CS_OSC_MUTEMG
              sAddress = "/config/mute/" + Str(n+1)
          EndSelect
          bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
          If bMsgSent
            bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
            If bResponseReceived
              ; debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nOSCLongCount=" + gaNetworkControl(nNetworkControlPtr)\nOSCLongCount)
              If gaNetworkControl(nNetworkControlPtr)\nOSCLongCount > 0
                nLongData = gaNetworkControl(nNetworkControlPtr)\nOSCLong(0)
                Select nLongData
                  Case 0, 1
                    \nX32ItemOn(n) = nLongData
                  Default
                    debugMsg(sProcName, "unexpected return value from " + sAddress + " : " + nLongData)
                EndSelect
                debugMsg(sProcName, "\nX32ItemOn(" + n + ")=" + \nX32ItemOn(n))
              EndIf
            EndIf
          EndIf
        Next n
      EndIf
    EndIf
  EndWith
  
  If bSuspendNetworkThread
    If nThreadState = #SCS_THREAD_STATE_ACTIVE
      THR_resumeAThread(#SCS_THREAD_NETWORK)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure getX32Data(nNetworkControlPtr)
  PROCNAMEC()
  Protected sAddress.s
  Protected bMsgSent, bResponseReceived
  Protected n
  Protected sStringData.s, nStringIndex
  CompilerIf #cTraceX32Sends
    Protected bHideTracing = #False
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  Protected nThreadState
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  If gnThreadNo <> #SCS_THREAD_NETWORK
    nThreadState = THR_getThreadState(#SCS_THREAD_NETWORK)
    If nThreadState = #SCS_THREAD_STATE_ACTIVE
      debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_NETWORK)")
      THR_suspendAThreadAndWait(#SCS_THREAD_NETWORK)
    EndIf
  EndIf
  
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
    
    If (gaNetworkControl(nNetworkControlPtr)\bNWDummy = #False) And (gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun = #False) ; added bNWIgnoreDevThisRun 16Mar2020 11.8.2.3aa
      If *gmNetworkSendBuffer
        sAddress = "/info"
        bMsgSent = sendOSCMessage(nNetworkControlPtr, sAddress, "", 0.0, 0, "", bHideTracing)
        If bMsgSent
          bResponseReceived = getOSCResponse(nNetworkControlPtr, bHideTracing, sAddress)
          If bResponseReceived
            sStringData = ""
            For nStringIndex = 0 To (gaNetworkControl(nNetworkControlPtr)\nOSCStringCount-1)
              sStringData + gaNetworkControl(nNetworkControlPtr)\sOSCString(nStringIndex) + " "
            Next nStringIndex
            \sInfo = Trim(sStringData)
            debugMsg(sProcName, "\sInfo=" + \sInfo)
          EndIf
        EndIf
        If bResponseReceived = #False
          gaNetworkControl(nNetworkControlPtr)\bUDPServerResponding = #False
          debugMsg(sProcName, "exiting because no response received from " + sAddress)
          ProcedureReturn #False
        Else
          gaNetworkControl(nNetworkControlPtr)\bUDPServerResponding = #True
        EndIf
      EndIf
    EndIf
    
    getX32Names(nNetworkControlPtr)
    
    If (gaNetworkControl(nNetworkControlPtr)\bNWDummy = #False) And (gaNetworkControl(nNetworkControlPtr)\bNWIgnoreDevThisRun = #False) ; added bNWIgnoreDevThisRun 16Mar2020 11.8.2.3aa
      samAddRequest(#SCS_SAM_LOAD_MISSING_OSC_INFO, nNetworkControlPtr, 0, -1, "", ElapsedMilliseconds()+2000, #True)
    EndIf
    
  EndWith
  
  If gnThreadNo <> #SCS_THREAD_NETWORK
    If nThreadState = #SCS_THREAD_STATE_ACTIVE
      debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_NETWORK)")
      THR_resumeAThread(#SCS_THREAD_NETWORK)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure setX32CueControl()
  PROCNAMEC()
  Protected rX32CueControl.tyX32CueControl
  Protected n, d, m
  
  For n = 0 To gnMaxNetworkControl
    With gaNetworkControl(n)
      Select \nCueNetworkRemoteDev
        Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
          If (\nClientConnection) And (\bNetworkDevInitialized)
            rX32CueControl\bCueControlActive = #True
            rX32CueControl\nX32ClientConnection = \nClientConnection
            rX32CueControl\qLastXRemoteTime = ElapsedMilliseconds() - 60000
            debugMsg(sProcName, "rX32CueControl\bCueControlActive=" + strB(rX32CueControl\bCueControlActive) + ", \nX32ClientConnection=" + rX32CueControl\nX32ClientConnection)
            For d = 0 To grProd\nMaxCueCtrlLogicalDev
              Select grProd\aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev
                Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
                  For m = 0 To #SCS_MAX_X32_COMMAND
                    rX32CueControl\aX32Command[m] = grProd\aCueCtrlLogicalDevs(d)\aX32Command[m]
                    If rX32CueControl\aX32Command[m]\nX32Button > 0
                      debugMsg(sProcName, "rX32CueControl\aX32Command[" + m + "]\nX32Button=" + rX32CueControl\aX32Command[m]\nX32Button)
                    EndIf
                  Next m
                  Break
              EndSelect
            Next d
            Break
          EndIf
      EndSelect
    EndWith
  Next n
  
  grX32CueControl = rX32CueControl
  
EndProcedure

Procedure setDerivedNetworkFields(pNetworkControlPtr=-1)
  PROCNAMEC()
  Protected nNetworkControlPtr, nFirst, nLast
  
  debugMsg(sProcName, #SCS_START)
  
  If pNetworkControlPtr >= 0
    nFirst = pNetworkControlPtr
    nLast = pNetworkControlPtr
  Else
    nFirst = 0
    nLast = gnMaxNetworkControl
  EndIf
  
  For nNetworkControlPtr = nFirst To nLast
    With gaNetworkControl(nNetworkControlPtr)
      Select \nCtrlNetworkRemoteDev
        Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT, #SCS_CS_NETWORK_REM_OSC_X32TC, #SCS_CS_NETWORK_REM_OSC_OTHER
          \bOSCServer = #True
        Default
          \bOSCServer = #False
      EndSelect
      Select \nCueNetworkRemoteDev
        Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT, #SCS_CC_NETWORK_REM_OSC_X32TC
          \bOSCClient = #True
        Default
          \bOSCClient = #False
      EndSelect
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev) + ", \bOSCServer=" + strB(\bOSCServer) +
                          ", \nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev) + ", \bOSCClient=" + strB(\bOSCClient))
    EndWith
  Next nNetworkControlPtr
  
EndProcedure

Procedure.s decodeOSCCmdType(nOSCCmdType)
  Protected sOSCCmdType.s
  
  Select nOSCCmdType
    Case #SCS_CS_OSC_GOCUE
      sOSCCmdType = "gocue"
    Case #SCS_CS_OSC_GOSCENE
      sOSCCmdType = "goscene"
    Case #SCS_CS_OSC_GOSNIPPET
      sOSCCmdType = "gosnippet"
    Case #SCS_CS_OSC_MUTECHANNEL
      sOSCCmdType = "mutechannel"
    Case #SCS_CS_OSC_MUTEDCAGROUP
      sOSCCmdType = "mutedcagroup"
    Case #SCS_CS_OSC_MUTEAUXIN
      sOSCCmdType = "muteauxin"
    Case #SCS_CS_OSC_MUTEFXRTN
      sOSCCmdType = "mutefxrtn"
    Case #SCS_CS_OSC_MUTEBUS
      sOSCCmdType = "mutebus"
    Case #SCS_CS_OSC_MUTEMATRIX
      sOSCCmdType = "mutematrix"
    Case #SCS_CS_OSC_MUTEMAINLR
      sOSCCmdType = "mutemainlr"
    Case #SCS_CS_OSC_MUTEMAINMC
      sOSCCmdType = "mutemainmc"
    Case #SCS_CS_OSC_MUTEMG
      sOSCCmdType = "mutemg"
    Case #SCS_CS_OSC_AUXINLEVEL
      sOSCCmdType = "faderauxin"
    Case #SCS_CS_OSC_BUSLEVEL
      sOSCCmdType = "faderbus"
    Case #SCS_CS_OSC_CHANNELLEVEL
      sOSCCmdType = "faderchannel"
    Case #SCS_CS_OSC_DCALEVEL
      sOSCCmdType = "faderdcagroup"
    Case #SCS_CS_OSC_FXRTNLEVEL
      sOSCCmdType = "faderfxrtn"
    Case #SCS_CS_OSC_MAINLRFADER
      sOSCCmdType = "fadermainlr"
    Case #SCS_CS_OSC_MAINMCFADER
      sOSCCmdType = "fadermainmc"
    Case #SCS_CS_OSC_MATRIXLEVEL
      sOSCCmdType = "fadermatrix"
    Case #SCS_CS_OSC_FREEFORMAT
      sOSCCmdType = "free"
    Case #SCS_CS_OSC_TC_GO
      sOSCCmdType = "tc_go"
    Case #SCS_CS_OSC_TC_BACK
      sOSCCmdType = "tc_back"
    Case #SCS_CS_OSC_TC_JUMP
      sOSCCmdType = "tc_jump"
    Default
      sOSCCmdType = Str(nOSCCmdType)
  EndSelect
  ProcedureReturn sOSCCmdType
EndProcedure

Procedure.s decodeOSCCmdTypeL(nOSCCmdType)
  If nOSCCmdType = #SCS_CS_OSC_NOT_SET
    ProcedureReturn ""
  Else
    ProcedureReturn Lang("OSC", decodeOSCCmdType(nOSCCmdType))
  EndIf
EndProcedure

Procedure encodeOSCCmdType(sOSCCmdType.s)
  Protected nOSCCmdType
  
  Select sOSCCmdType
    Case "gocue"
      nOSCCmdType = #SCS_CS_OSC_GOCUE
    Case "goscene"
      nOSCCmdType = #SCS_CS_OSC_GOSCENE
    Case "gosnippet"
      nOSCCmdType = #SCS_CS_OSC_GOSNIPPET
    Case "mutechannel"
      nOSCCmdType = #SCS_CS_OSC_MUTECHANNEL
    Case "mutedcagroup"
      nOSCCmdType = #SCS_CS_OSC_MUTEDCAGROUP
    Case "muteauxin"
      nOSCCmdType = #SCS_CS_OSC_MUTEAUXIN
    Case "mutefxrtn"
      nOSCCmdType = #SCS_CS_OSC_MUTEFXRTN
    Case "mutebus"
      nOSCCmdType = #SCS_CS_OSC_MUTEBUS
    Case "mutematrix"
      nOSCCmdType = #SCS_CS_OSC_MUTEMATRIX
    Case "mutemainlr"
      nOSCCmdType = #SCS_CS_OSC_MUTEMAINLR
    Case "mutemainmc"
      nOSCCmdType = #SCS_CS_OSC_MUTEMAINMC
    Case "mutemg"
      nOSCCmdType = #SCS_CS_OSC_MUTEMG
    Case "faderauxin"
      nOSCCmdType = #SCS_CS_OSC_AUXINLEVEL
    Case "faderbus"
      nOSCCmdType = #SCS_CS_OSC_BUSLEVEL
    Case "faderchannel"
      nOSCCmdType = #SCS_CS_OSC_CHANNELLEVEL
    Case "faderdcagroup"
      nOSCCmdType = #SCS_CS_OSC_DCALEVEL
    Case "faderfxrtn"
      nOSCCmdType = #SCS_CS_OSC_FXRTNLEVEL
    Case "fadermainlr"
      nOSCCmdType = #SCS_CS_OSC_MAINLRFADER
    Case "fadermainmc"
      nOSCCmdType = #SCS_CS_OSC_MAINMCFADER
    Case "fadermatrix"
      nOSCCmdType = #SCS_CS_OSC_MATRIXLEVEL
    Case "free"
      nOSCCmdType = #SCS_CS_OSC_FREEFORMAT
    Case "tc_go"
      nOSCCmdType = #SCS_CS_OSC_TC_GO
    Case "tc_back"
      nOSCCmdType = #SCS_CS_OSC_TC_BACK
    Case "tc_jump"
      nOSCCmdType = #SCS_CS_OSC_TC_JUMP
    Default
      nOSCCmdType = #SCS_CS_OSC_NOT_SET
  EndSelect
  ProcedureReturn nOSCCmdType
EndProcedure

Procedure.s getLabelForOSCCmdType(nOSCCmdType)
  Protected sOSCCmdLabel.s
  
  Select nOSCCmdType
    Case #SCS_CS_OSC_GOCUE
      sOSCCmdLabel = "cue"
    Case #SCS_CS_OSC_GOSCENE
      sOSCCmdLabel = "scene"
    Case #SCS_CS_OSC_GOSNIPPET
      sOSCCmdLabel = "snippet"
    Case #SCS_CS_OSC_MUTECHANNEL
      sOSCCmdLabel = "channel"
    Case #SCS_CS_OSC_MUTEDCAGROUP
      sOSCCmdLabel = "dcagroup"
    Case #SCS_CS_OSC_MUTEAUXIN
      sOSCCmdLabel = "auxin"
    Case #SCS_CS_OSC_MUTEFXRTN
      sOSCCmdLabel = "fxrtn"
    Case #SCS_CS_OSC_MUTEBUS
      sOSCCmdLabel = "bus"
    Case #SCS_CS_OSC_MUTEMATRIX
      sOSCCmdLabel = "matrix"
    Case #SCS_CS_OSC_MUTEMAINLR
      sOSCCmdLabel = "mainlr"
    Case #SCS_CS_OSC_MUTEMAINMC
      sOSCCmdLabel = "mainmc"
    Case #SCS_CS_OSC_MUTEMG
      sOSCCmdLabel = "mg"
    Case #SCS_CS_OSC_FREEFORMAT
      sOSCCmdLabel = "free"
    Case #SCS_CS_OSC_TC_JUMP
      sOSCCmdLabel = "cue"
  EndSelect
  
  If sOSCCmdLabel
    ProcedureReturn Lang("OSC", sOSCCmdLabel)
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

Procedure.s buildOSCDisplayInfo(*rSub.tySub, nCtrlSendIndex)
  PROCNAMEC()
  Protected sDisplayInfo.s
  Protected sOSCItemString.s, sOSCItemId.s, nMuteAction, sMuteActionL.s
  Static sChannel.s, sAuxIn.s, sFXRtn.s, sBus.s, sMatrix.s, sDCAGroup.s, sMain.s, sMuteGroup.s, sGo.s, sMainLR.s, sMainMC.s
  Static sTCGo.s, sTCBack.s, sTCJump.s
  Static sFader.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  If bStaticLoaded = #False
    sChannel = Lang("OSC", "channel")
    sAuxIn = Lang("OSC", "auxin")
    sFXRtn = Lang("OSC", "fxrtn")
    sBus = Lang("OSC", "bus")
    sMatrix = Lang("OSC", "matrix")
    sDCAGroup = Lang("OSC", "dcagroup")
    sMain = Lang("OSC", "main")
    sMainLR = Lang("OSC", "mainlr")
    sMainMC = Lang("OSC", "mainmc")
    sFader = Lang("OSC", "fader")
    sMuteGroup = Lang("OSC", "mg")
    sGo = Lang("Common", "Go")
    sTCGo = Trim(StringField(Lang("OSC", "tc_go"), 1, "(")) ; eg from "Go (fire the next cue)" select "Go"
    sTCBack = Trim(StringField(Lang("OSC", "tc_back"), 1, "("))
    sTCJump = Trim(StringField(Lang("OSC", "tc_jump"), 1, "("))
    bStaticLoaded = #True
  EndIf
  
  With *rSub\aCtrlSend[nCtrlSendIndex]
    ; debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\nOSCCmdType=" + decodeOSCCmdType(\nOSCCmdType))
    If \bIsOSC
      If \bOSCItemPlaceHolder
        sOSCItemString = "?"
      Else
        sOSCItemString = \sOSCItemString
      EndIf
      
      If \nRemDevMsgType
        nMuteAction = \nRemDevMuteAction
      Else
        nMuteAction = \nOSCMuteAction
      EndIf
      sMuteActionL = decodeMuteActionL(nMuteAction)
      
      If (\nOSCItemNr >= 0) And (\bOSCItemPlaceHolder = #False)
        Select \nOSCCmdType
          Case #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEMATRIX               
            sOSCItemId = makeX32ItemId(\nOSCCmdType, \nOSCItemNr)
            If sOSCItemId = sOSCItemString
              sDisplayInfo = sMuteActionL + " " + sOSCItemString
            Else
              sDisplayInfo = sMuteActionL + " " + makeX32ItemId(\nOSCCmdType, \nOSCItemNr) + ": " + sOSCItemString
            EndIf
            
          Case #SCS_CS_OSC_MUTEMAINLR, #SCS_CS_OSC_MUTEMAINMC
            sDisplayInfo = sMuteActionL + " " + sOSCItemString
            
          Case #SCS_CS_OSC_GOCUE, #SCS_CS_OSC_GOSCENE, #SCS_CS_OSC_GOSNIPPET
            sOSCItemId = makeX32ItemId(\nOSCCmdType, \nOSCItemNr)
            If sOSCItemId = sOSCItemString
              sDisplayInfo = sGo + " " + sOSCItemString
            Else
              sDisplayInfo = sGo + " " + makeX32ItemId(\nOSCCmdType, \nOSCItemNr) + ": " + sOSCItemString
            EndIf
            
        EndSelect
      EndIf
      
      If Len(sDisplayInfo) = 0
        Select \nOSCCmdType
          Case #SCS_CS_OSC_MUTEAUXIN
            sDisplayInfo = sMuteActionL + " " + sAuxIn + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEBUS
            sDisplayInfo = sMuteActionL + " " + sBus + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTECHANNEL
            sDisplayInfo = sMuteActionL + " " + sChannel + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEDCAGROUP
            sDisplayInfo = sMuteActionL + " " + sDCAGroup + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEFXRTN
            sDisplayInfo = sMuteActionL + " " + sFXRtn + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEMAINLR
            sDisplayInfo = sMuteActionL + " " + sMainLR + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEMAINMC
            sDisplayInfo = sMuteActionL + " " + sMainMC + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEMATRIX
            sDisplayInfo = sMuteActionL + " " + sMatrix + " " + sOSCItemString
          Case #SCS_CS_OSC_MUTEMG
            sDisplayInfo = sMuteActionL + " " + sMuteGroup + " " + sOSCItemString
          Case #SCS_CS_OSC_FREEFORMAT
            sDisplayInfo = "OSC " + sOSCItemString
          Case #SCS_CS_OSC_TC_GO
            sDisplayInfo = sTCGo
          Case #SCS_CS_OSC_TC_BACK
            sDisplayInfo = sTCBack
          Case #SCS_CS_OSC_TC_JUMP
            sDisplayInfo = sTCJump + " " + sOSCItemString
          Case #SCS_CS_OSC_CHANNELLEVEL
            sDisplayInfo = sChannel + " " + sFader + " " + sOSCItemString
          Default
            sDisplayInfo = decodeOSCCmdTypeL(\nOSCCmdType) + " " + sOSCItemString
        EndSelect
      EndIf
    EndIf
    debugMsg(sProcName, "rSub\aCtrlSend[" + nCtrlSendIndex + "]\nOSCCmdType=" + decodeOSCCmdType(\nOSCCmdType) + ", \nOSCItemNr=" + \nOSCItemNr + ", \sOSCItemString=" + \sOSCItemString + ", sDisplayInfo=" + sDisplayInfo)
  EndWith
  ProcedureReturn sDisplayInfo
  
EndProcedure

Procedure updateNetworkControlForDevChgsDev(nDevMapDevPtr, nDevNo)
  PROCNAMEC()
  Protected nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START + ", nDevMapDevPtr=" + nDevMapDevPtr + ", nDevNo=" + nDevNo)
  
  If (nDevMapDevPtr >= 0) And (nDevNo >= 0)
    nNetworkControlPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
    debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr)
    If nNetworkControlPtr >= 0
      With gaNetworkControl(nNetworkControlPtr)
        Select grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevGrp
          Case #SCS_DEVGRP_CTRL_SEND
            \nCtrlNetworkRemoteDev = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev
            \nNetworkProtocol = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkProtocol
            \nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkRole
            \sRemoteHost = grMapsForDevChgs\aDev(nDevMapDevPtr)\sRemoteHost
            \nRemotePort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort
            \nLocalPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort
            \nCtrlSendDelay = grMapsForDevChgs\aDev(nDevMapDevPtr)\nCtrlSendDelay
            debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev) +
                                ", \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) +
                                ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole) +
                                ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort +
                                ", \nLocalPort=" + \nLocalPort + ", \nCtrlSendDelay=" + \nCtrlSendDelay + ", \bConnectWhenReqd=" + strB(\bConnectWhenReqd))
            
          Case #SCS_DEVGRP_CUE_CTRL
            \nCueNetworkRemoteDev = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nCueNetworkRemoteDev
            \nNetworkProtocol = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkProtocol
            \nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkRole
            \sRemoteHost = grMapsForDevChgs\aDev(nDevMapDevPtr)\sRemoteHost
            \nRemotePort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort
            \nLocalPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort
            debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nCueNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(\nCueNetworkRemoteDev) +
                                ", \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) +
                                ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole) +
                                ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort +
                                ", \nLocalPort=" + \nLocalPort)
            
        EndSelect
        
        debugMsg(sProcName, "calling setDerivedNetworkFields(" + nNetworkControlPtr + ")")
        setDerivedNetworkFields(nNetworkControlPtr)
        
        debugMsg(sProcName, "calling setUseNetworkControlPtrs()")
        setUseNetworkControlPtrs()
        
        debugMsg(sProcName, "calling setX32CueControl()")
        setX32CueControl()
        
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openNetworkPortIfReqd(nNetworkControlPtr, bInDevChgs=#False, nDevForDevCheckerIndex=-1, bTrace=#True)
  PROCNAMEC()
  Protected bOpenThis, nResult
  Protected bOpenResult
  Protected nFlag
  Protected sStatusField.s
  Protected m, n2
  Protected bRealNetworkReqd, bRealUDPReqd
  Protected nDevNo
  Protected nMaxMsgResponse
  Protected nMode, sMode.s
  Protected bDeviceResponding
  Protected sTitle.s, sPrompt.s, sButtons.s
  Protected nMousePointer
  Protected bModalDisplayed
  Protected nRetryBtn, nConCloseFileBtn, nCloseSCSBtn
  Protected nReply
  Protected sRemoteDev.s
  Protected nDevMapDevPtr, bForceIgnoreDevThisRun
  Protected sRemoteHost.s, sPromptNewIPAddress.s
  Protected nTryAgain = -1, nContinue = -1, nChangeIPAddress = -1, nCloseFile = -1, nCloseSCS = -1
  Static bX32FailMsgDisplayed
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", bInDevChgs=" + strB(bInDevChgs) + ", nDevForDevCheckerIndex=" + nDevForDevCheckerIndex)
  
  If nNetworkControlPtr >= 0
    While #True ; 'While' statement just so we can 'Break' to the end
      With gaNetworkControl(nNetworkControlPtr)
        debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bControlExists=" + strB(\bControlExists) + ", \bNWDummy=" + strB(\bNWDummy) + ", \bNWIgnoreDevThisRun=" + strB(\bNWIgnoreDevThisRun) +
                             ", \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole) + ", \bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
        bOpenThis = #False
        If \bNWIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
          Break
        EndIf
        If \bNetworkDevInitialized = #False
          bOpenThis = #True
          nFlag = 1
        ElseIf \nNetworkProtocol <> \nCurrNetworkProtocol
          bOpenThis = #True
          nFlag = 3
        ElseIf \nNetworkRole <> \nCurrNetworkRole
          bOpenThis = #True
          nFlag = 3
        ElseIf \nDevType <> \nCurrDevType And 1=2
          ; Added 13Jan2022 11.9.0aj following log file from Beverley Grover that showed an input and output device sharing the same connection, and then one of them being closed
          bOpenThis = #True
          nFlag = 4
        Else
          Select \nNetworkRole
            Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
              If (\sRemoteHost <> \sCurrRemoteHost) Or (\nRemotePort <> \nCurrRemotePort)
                bOpenThis = #True
                nFlag = 5
              EndIf
            Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
              If \nLocalPort <> \nCurrLocalPort
                bOpenThis = #True
                nFlag = 6
              EndIf
          EndSelect
        EndIf
        Select \nNetworkRole
          Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            If \nRemotePort < 0 Or Len(\sRemoteHost) = 0
              bOpenThis = #False
            EndIf
          Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            If \nLocalPort < 0
              bOpenThis = #False
            EndIf
        EndSelect
        debugMsgC(sProcName, "bOpenThis=" + strB(bOpenThis) + ", nFlag=" + nFlag)
        
        ; if bOpenThis = #False then the port is already open with the required settings, so no need to close and re-open
        ; else do the following:
        If bOpenThis
          debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nDevNo=" + \nDevNo)
          nDevNo = \nDevNo
          Select \nDevType
            Case #SCS_DEVTYPE_CS_NETWORK_OUT
              If bInDevChgs
                nMaxMsgResponse = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nMaxMsgResponse
                For m = 0 To nMaxMsgResponse
                  Select grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\aMsgResponse[m]\nMsgAction
                    Case #SCS_NETWORK_ACT_READY, #SCS_NETWORK_ACT_AUTHENTICATE
                      \bClientConnectionNeedsReady = #True
                      Break
                  EndSelect
                Next m
              Else
                debugMsgC(sProcName, "grProd\aCtrlSendLogicalDevs(" + nDevNo + ")\nMaxMsgResponse=" + grProd\aCtrlSendLogicalDevs(nDevNo)\nMaxMsgResponse)
                nMaxMsgResponse = grProd\aCtrlSendLogicalDevs(nDevNo)\nMaxMsgResponse
                For m = 0 To nMaxMsgResponse
                  Select grProd\aCtrlSendLogicalDevs(nDevNo)\aMsgResponse[m]\nMsgAction
                    Case #SCS_NETWORK_ACT_READY, #SCS_NETWORK_ACT_AUTHENTICATE
                      \bClientConnectionNeedsReady = #True
                      Break
                  EndSelect
                Next m
              EndIf
              debugMsgC(sProcName, "nMaxMsgResponse=" + nMaxMsgResponse + ", \bClientConnectionNeedsReady=" + strB(\bClientConnectionNeedsReady) + ", \nUseNetworkControlPtr=" + \nUseNetworkControlPtr)
            Case #SCS_DEVTYPE_CC_NETWORK_IN
              ; no action
          EndSelect
          
          If \nUseNetworkControlPtr >= 0
            \nClientConnection       = gaNetworkControl(\nUseNetworkControlPtr)\nClientConnection
            \nServerConnection       = gaNetworkControl(\nUseNetworkControlPtr)\nServerConnection
            \bNetworkDevInitialized  = gaNetworkControl(\nUseNetworkControlPtr)\bNetworkDevInitialized
            \bClientConnectionLive   = gaNetworkControl(\nUseNetworkControlPtr)\bClientConnectionLive
            \bClientConnectionReady  = gaNetworkControl(\nUseNetworkControlPtr)\bClientConnectionReady
          EndIf
          
          debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection) + ", \nUseNetworkControlPtr=" + \nUseNetworkControlPtr + ", \bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
          If (\nClientConnection) And (\nUseNetworkControlPtr < 0)
            If grX32CueControl\nX32ClientConnection = \nClientConnection
              grX32CueControl\nX32ClientConnection = 0
              Delay(100)  ; make sure any existing /xremote command sent to the X32 by THR_runNetworkThread() has time to complete before closing the connection
            EndIf
            debugMsgC(sProcName, "calling CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
            CloseNetworkConnection(\nClientConnection)
            debugMsgC(sProcName, "CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
            For n2 = 0 To gnMaxNetworkControl
              If n2 <> nNetworkControlPtr
                If gaNetworkControl(n2)\nClientConnection = \nClientConnection
                  gaNetworkControl(n2) = grNetworkControlDef
                EndIf
              EndIf
            Next n2
            freeHandle(\nClientConnection)
            \nClientConnection = 0
            \bNetworkDevInitialized = #False
            debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection) + ", grX32CueControl\nX32ClientConnection=" + grX32CueControl\nX32ClientConnection + ", \bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
            \bClientConnectionLive = #False
            \bClientConnectionReady = #False
            \nCountSendWhenReady = 0
            gnNetworkClientsActive - 1
            debugMsgC(sProcName, "gnNetworkClientsActive=" + gnNetworkClientsActive)
            If nMaxMsgResponse >= 0
              gnNetworkResponseCount - 1
            EndIf
          EndIf
          
          debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + decodeHandle(\nServerConnection) + ", \nUseNetworkControlPtr=" + \nUseNetworkControlPtr)
          If (\nServerConnection) And (\nUseNetworkControlPtr < 0)
            debugMsgC(sProcName, "calling CloseNetworkServer(" + decodeHandle(\nServerConnection) + ")")
            CloseNetworkServer(\nServerConnection)
            debugMsgC(sProcName, "CloseNetworkServer(" + decodeHandle(\nServerConnection) + ")")
            freeHandle(\nServerConnection)
            \nServerConnection = 0
            \bNetworkDevInitialized = #False
            debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + decodeHandle(\nServerConnection) + ", \bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
            gnNetworkServersActive - 1
            debugMsgC(sProcName, "gnNetworkServersActive=" + gnNetworkServersActive)
          EndIf
          
          debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
          Select \nNetworkRole
            Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
              debugMsgC(sProcName, "#SCS_NETWORK_ROLE_SCS_IS_A_CLIENT")
              debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort)
              If \sRemoteHost
                If \nNetworkProtocol = #SCS_NETWORK_PR_UDP
                  nMode = #PB_Network_UDP
                  sMode = "#PB_Network_UDP"
                Else
                  nMode = #PB_Network_TCP
                  sMode = "#PB_Network_TCP"
                EndIf
                If \nUseNetworkControlPtr < 0
                  debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nOpenConnectionTimeout=" + \nOpenConnectionTimeout)
                  \nClientConnection = OpenNetworkConnection(\sRemoteHost, \nRemotePort, nMode, \nOpenConnectionTimeout)
                  newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nClientConnection)
                  debugMsgC(sProcName, "OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", " + sMode +", " + \nOpenConnectionTimeout + ") returned " + decodeHandle(\nClientConnection))
                EndIf
                If \nClientConnection
                  \bNetworkDevInitialized = #True
                  \bClientConnectionLive = #True
                  gnNetworkClientsActive + 1
                  debugMsgC(sProcName, "gnNetworkClientsActive=" + gnNetworkClientsActive)
                  bOpenResult = #True
                  debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev) + ", \nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev) + ", \bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
                  Select \nCtrlNetworkRemoteDev
                    Case #SCS_CS_NETWORK_REM_PJLINK, #SCS_CS_NETWORK_REM_PJNET
                      \bClientConnectionNeedsReady = #True
                      
                    Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                      debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + gaNetworkControl(nNetworkControlPtr)\nClientConnection)
                      debugMsgC(sProcName, "calling getX32Data(" + nNetworkControlPtr + ")")
                      bDeviceResponding = getX32Data(nNetworkControlPtr)
                      If bDeviceResponding = #False
                        If bX32FailMsgDisplayed
                          debugMsgC(sProcName, "bX32FailMsgDisplayed=" + strB(bX32FailMsgDisplayed) + " so do not display message again but just continue without device connected")
                          ; #True means the message 'SCS failed to connect to the X32' has already been displayed AND the user requested 'continue without device connected'
                          ; so here we reproduce that same 'continue without device connected' code
                          \bNetworkDevInitialized = #False
                          debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
                          bForceIgnoreDevThisRun = #True
                          bOpenResult = #False
                        Else
                          nMousePointer = GetMouseCursor()
                          bModalDisplayed = gbModalDisplayed
                          SetMouseCursorNormal()
                          ensureSplashNotOnTop()
                          gbModalDisplayed = #True
                          sRemoteDev = decodeCtrlNetworkRemoteDevL(\nCtrlNetworkRemoteDev)
                          sTitle = LangPars("Network","msgTitle",sRemoteDev)
                          sPrompt = LangPars("Network","Failed",sRemoteDev) + "||"
                          debugMsgC(sProcName, sTitle + ": " + sPrompt)
                          If gbEditing
                            sButtons = Lang("Network","btnTryAgain") + "|" +
                                       Lang("Network","btnContinue")
                            nTryAgain = 1
                            nContinue = 2
                            nChangeIPAddress = -1
                            nCloseFile = -1
                            nCloseSCS = -1
                            nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 140, #IDI_EXCLAMATION)
                          Else
                            ; sButtons = Lang("Network","btnTryAgain") + "|" + Lang("Network","btnContinue")  + "|" + Lang("Network","btnCloseFile") + "|" + Lang("Network","btnCloseSCS")
                            ; nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 140, #IDI_EXCLAMATION)
                            sButtons = Lang("Network","btnTryAgain") + "|" +
                                       Lang("Network","ChangeAddress") + "|" +
                                       Lang("Network","btnContinue")  + "|" +
                                       Lang("Network","btnCloseFile") + "|" +
                                       Lang("Network","btnCloseSCS")
                            nTryAgain = 1
                            nChangeIPAddress = 2
                            nContinue = 3
                            nCloseFile = 4
                            nCloseSCS = 5
                            nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 140, #IDI_EXCLAMATION)
                          EndIf
                          
                          gbModalDisplayed = bModalDisplayed
                          SetMouseCursor(nMousePointer)
                          Select nReply
                            Case nTryAgain
                              ; retry connection
                              debugMsg(sProcName, "user requested retry connection")
                              Continue  ; try again
                              
                            Case nChangeIPAddress
                              ; change IP address and try again
                              sPromptNewIPAddress = Lang("Network","TempNewAddress") ; "Temporary New IP Address"
                              sRemoteHost = \sRemoteHost
                              While #True
                                sRemoteHost = Trim(InputRequester(sTitle, sPromptNewIPAddress, sRemoteHost))
                                debugMsg(sProcName, "InputRequester() returned sRemoteHost=" + sRemoteHost)
                                If sRemoteHost
;                                   If looksLikeIPAddress(sRemoteHost)
;                                     debugMsg(sProcName, "looksLikeIPAddress('" + sRemoteHost + "') returned #True")
                                    If validateIPAddressFormat(sRemoteHost, sPromptNewIPAddress, #False) = #False
                                      debugMsg(sProcName, "validateIPAddressFormat('" + sRemoteHost + "', '" + sPromptNewIPAddress + "') returned #False")
                                      scsMessageRequester(sTitle, sRemoteHost + " " + Lang("Errors", "NotValidForIP"))
                                      Continue
                                    EndIf
;                                   EndIf
                                    \sRemoteHost = sRemoteHost
                                    debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\sRemoteHost=" + \sRemoteHost)
                                EndIf
                                Break
                              Wend
                              Continue
                              
                            Case nContinue
                              ; continue without device connected
                              debugMsg(sProcName, "user requested continue without device connected")
                              \bNetworkDevInitialized = #False
                              debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
                              bForceIgnoreDevThisRun = #True
                              bOpenResult = #False
                              bX32FailMsgDisplayed = #True
                              
                            Case nCloseFile
                              ; close cue file (button only visible if gbEditing = #False)
                              debugMsg(sProcName, "user requested close cue file")
                              gbCloseCueFile = #True
                              Break
                              
                            Case nCloseSCS
                              ; close SCS (button only visible if gbEditing = #False)
                              debugMsg(sProcName, "user requested close SCS")
                              closeDown(#True)
                              BASS_ASIO_Free()
                              BASS_Free()
                              Debug "END OF RUN"
                              End
                              
                          EndSelect
                          
                        EndIf
                        
                      EndIf
                      
                    Default
                      ; no action here
                      
                  EndSelect
                  
                EndIf
                If \bClientConnectionNeedsReady
                  \bClientConnectionReady = #False
                Else
                  \bClientConnectionReady = #True
                EndIf
                \nCountSendWhenReady = 0
;                 gnNetworkClientsActive + 1
;                 debugMsg(sProcName, "gnNetworkClientsActive=" + gnNetworkClientsActive)
                If nMaxMsgResponse >= 0
                  gnNetworkResponseCount + 1
                EndIf
                debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bClientConnectionNeedsReady=" + strB(\bClientConnectionNeedsReady) +
                                     ", \bClientConnectionReady=" + strB(\bClientConnectionReady) +
                                     ", \nCountSendWhenReady=" + \nCountSendWhenReady +
                                     ", gnNetworkResponseCount=" + gnNetworkResponseCount)
              EndIf
              
            Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
              debugMsgC(sProcName, "#SCS_NETWORK_ROLE_SCS_IS_A_SERVER")
              If \nNetworkProtocol = #SCS_NETWORK_PR_UDP
                nMode = #PB_Network_UDP
                sMode = "#PB_Network_UDP"
              Else
                nMode = #PB_Network_TCP
                sMode = "#PB_Network_TCP"
              EndIf
              debugMsgC(sProcName, "sMode=" + sMode + ", \nUseNetworkControlPtr=" + \nUseNetworkControlPtr)
              If \nUseNetworkControlPtr < 0
                debugMsgC(sProcName, "calling CreateNetworkServer(#PB_Any, " + \nLocalPort + ", " + sMode + ")")
                \nServerConnection = CreateNetworkServer(#PB_Any, \nLocalPort, nMode)
                debugMsgC(sProcName, "CreateNetworkServer(#PB_Any, " + \nLocalPort + ", " + sMode + ") returned \nServerConnection=" + \nServerConnection)
              EndIf
              ; debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + \nServerConnection)
              If \nServerConnection
                newHandle(#SCS_HANDLE_NETWORK_SERVER, \nServerConnection)
                debugMsgC(sProcName, "CreateNetworkServer(#PB_Any, " + \nLocalPort + ", " + sMode + ") returned " + \nServerConnection + " (" + decodeHandle(\nServerConnection) + ")")
                \bNetworkDevInitialized = #True
                debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
                bOpenResult = #True
                gnNetworkServersActive + 1
                debugMsgC(sProcName, "gnNetworkServersActive=" + gnNetworkServersActive)
              Else
                debugMsg(sProcName, "CreateNetworkServer(#PB_Any, " + \nLocalPort + ", " + sMode + ") returned " + \nServerConnection)
              EndIf
              
          EndSelect
          
          debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
          If \bNetworkDevInitialized
            \nCurrNetworkProtocol = \nNetworkProtocol
            \nCurrNetworkRole = \nNetworkRole
            \sCurrRemoteHost = \sRemoteHost
            \nCurrRemotePort = \nRemotePort
            \nCurrLocalPort = \nLocalPort
            ; \nCurrDevType = \nDevType ; Added 13Jan2022 11.9.0aj following log file from Beverley Grover that showed an input and output device sharing the same connection, and then one of them being closed
          EndIf
          
        Else
          ; Added 10May2024 11.10.2cp
          If gbInApplyDevChanges
            If \nClientConnection
              Select \nCtrlNetworkRemoteDev
                Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                  debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + gaNetworkControl(nNetworkControlPtr)\nClientConnection)
                  debugMsgC(sProcName, "calling getX32Data(" + nNetworkControlPtr + ")")
                  bDeviceResponding = getX32Data(nNetworkControlPtr)
              EndSelect
            EndIf
          EndIf
          ; End added 10May2024 11.10.2cp
          
        EndIf
        
        If \nDevMapDevPtr >= 0
          If bForceIgnoreDevThisRun ; bForceIgnoreDevThisRun added 17Mar2020 11.8.2.2aa
            If bInDevChgs
              grMapsForDevChgs\aDev(\nDevMapDevPtr)\bIgnoreDevThisRun = #True
              debugMsgC(sProcName, "grMapsForDevChgs\aDev(" + \nDevMapDevPtr + ")\bIgnoreDevThisRun=" + strB(grMapsForDevChgs\aDev(\nDevMapDevPtr)\bIgnoreDevThisRun))
            Else
              grMaps\aDev(\nDevMapDevPtr)\bIgnoreDevThisRun = #True
              debugMsgC(sProcName, "grMaps\aDev(" + \nDevMapDevPtr + ")\bIgnoreDevThisRun=" + strB(grMaps\aDev(\nDevMapDevPtr)\bIgnoreDevThisRun))
            EndIf
          EndIf
        EndIf
        If nDevForDevCheckerIndex >= 0
          If bForceIgnoreDevThisRun ; bForceIgnoreDevThisRun added 17Mar2020 11.8.2.2aa
            grMapsForChecker\aDev(nDevForDevCheckerIndex)\bIgnoreDevThisRun = #True
            debugMsgC(sProcName, "grMapsForChecker\aDev(" + nDevForDevCheckerIndex + ")\bIgnoreDevThisRun=" + strB(grMapsForChecker\aDev(nDevForDevCheckerIndex)\bIgnoreDevThisRun))
          EndIf
        EndIf
        
      EndWith
      Break
    Wend
  EndIf
  
  If bOpenThis = #False
    bOpenResult = #True
  EndIf
  
;   If bTrace
;     debugMsg(sProcName, "calling listNetworkControl()")
;     listNetworkControl()
;   EndIf
  
  If bOpenResult = #False Or bTrace
    debugMsg(sProcName, #SCS_END + ", returning " + strB(bOpenResult))
  EndIf
  ProcedureReturn bOpenResult
EndProcedure

Procedure.s X32CmdDescrForCmdNo(nCmdNo)
  PROCNAMEC()
  Protected sCmdDescr.s

;   debugMsg(sProcName, #SCS_START + ", nCmdNo=" + nCmdNo)

  Select nCmdNo
    Case #SCS_X32_GO_BUTTON
      ; sCmdDescr = Lang("Remote", "GoButton") ; 'Go' Button
      sCmdDescr = Lang("Init", "FnGo") ; 'Go' Button
    Case #SCS_X32_STOP_ALL
      ; sCmdDescr = "Stop All"
      sCmdDescr = Lang("Init", "FnStopAll")
    Case #SCS_X32_FADE_ALL
      sCmdDescr = Lang("Init", "FnFadeAll")
    Case #SCS_X32_PAUSE_RESUME_ALL
      ; sCmdDescr = "Pause/Resume All"
      sCmdDescr = Lang("Init", "FnPauseResumeAll")
    Case #SCS_X32_GO_TO_TOP
      sCmdDescr = "Go To Top"
    Case #SCS_X32_GO_BACK
      sCmdDescr = "Go Back"
    Case #SCS_X32_GO_TO_NEXT
      sCmdDescr = "Go To Next"
    Case #SCS_X32_TAP_DELAY
      sCmdDescr = "Tap Delay"
;     Case #SCS_X32_PAGE_UP
;       sCmdDescr = "Page Up"
;     Case #SCS_X32_PAGE_DOWN
;       sCmdDescr = "Page Down"
;     Case #SCS_X32_MASTER_FADER
;       sCmdDescr = "Master Fader"
;     Case #SCS_X32_GO_CONFIRM
;       sCmdDescr = "Go Confirm"
    Case -1
      sCmdDescr = ""
    Default
      sCmdDescr = Str(nCmdNo)
  EndSelect
  ProcedureReturn Trim(sCmdDescr)
EndProcedure

Procedure unpackOSCEnteredString(sEnteredString.s)
  PROCNAMEC()
  Protected bResult
  Protected sWorkString.s, sChar.s, sTag.s, sData.s
  Protected n, nCharPos, nDataStart, nDataEnd
  Protected nTagIndex
  
  debugMsg(sProcName, #SCS_START + ", sEnteredString=" + sEnteredString)
  
  bResult = #True
  
  With grOSCMsgData
    \sOSCItemString = sEnteredString
    \sOSCAddress = ""
    \sTagString = ""
    \nTagCount = 0
    
    If Len(sEnteredString) > 0
      If Left(sEnteredString, 1) = "/"
        nCharPos = FindString(sEnteredString, ",")
        If nCharPos = 0
          \sOSCAddress = Trim(sEnteredString)
        Else
          \sOSCAddress = Trim(Left(sEnteredString, (nCharPos-1)))
          sWorkString = Trim(Mid(sEnteredString, (nCharPos+1)))
          For n = 1 To Len(sWorkString)
            sChar = Mid(sWorkString, n, 1)
            Select LCase(sChar)
              Case "i", "f", "s"
                \sTagString + LCase(sChar)
                \nTagCount + 1
              Case " "  ; end of tag string
                Break
              Default
                debugMsg(sProcName, "sChar=" + sChar + ", setting bResult=#False")
                bResult = #False
                Break
            EndSelect
          Next n
          If ArraySize(\aTagData()) < (\nTagCount-1)
            ReDim \aTagData(\nTagCount-1)
          EndIf
          sWorkString = Trim(Mid(sWorkString, (\nTagCount+1)))
          nCharPos = 1
          nTagIndex = -1
          For n = 1 To \nTagCount
            sTag = Mid(\sTagString,n,1)
            nTagIndex + 1
            nDataStart = 0
            nDataEnd = 0
            Select sTag
              Case "i", "f"
                ; data for "i" and "f" must be enclosed in spaces
                nDataStart = skipChars(sWorkString, " ", nCharPos)
                If nDataStart > 0
                  nDataEnd = FindString(sWorkString, " ", nDataStart)
                  If nDataEnd = 0
                    nDataEnd = Len(sWorkString)
                  ElseIf nDataEnd > 0
                    nDataEnd - 1
                  EndIf
                EndIf
                
              Case "s"
                ; data for "s" may be enclosed in quotes (double-quotes)
                nDataStart = skipChars(sWorkString, " ", nCharPos)
                If nDataStart > 0
                  If Mid(sWorkString,nDataStart,1) = #DQUOTE$
                    ; string enclosed in double-quotes
                    nDataStart + 1
                    nDataEnd = FindString(sWorkString,#DQUOTE$,nDataStart)
                    If nDataEnd > 0
                      nDataEnd - 1
                    EndIf
                  Else
                    ; string not enclosed in double-quotes so assumed to be fully enclosed in spaces
                    nDataEnd = FindString(sWorkString, " ", nDataStart)
                    If nDataEnd > 0
                      nDataEnd - 1
                    EndIf
                  EndIf
                  If nDataEnd = 0
                    nDataEnd = Len(sWorkString)
                  EndIf
                EndIf
                
            EndSelect
            debugMsg(sProcName, "nTagIndex=" + nTagIndex + ", sTag=" + sTag + ", sWorkString=" + sWorkString + ", nDataStart=" + nDataStart + ", nDataEnd=" + nDataEnd)
            
            If nDataStart = 0 Or nDataEnd = 0
              ; no data or invalid data for this tag
              debugMsg(sProcName, "setting bResult=#False")
              bResult = #False
              Break
            EndIf
            
            sData = Mid(sWorkString, nDataStart, (nDataEnd-nDataStart+1))
            debugMsg(sProcName, "sData=" + sData)
            nCharPos = nDataEnd + 1
            
            Select sTag
              Case "i"
                If IsInteger(sData)
                  \aTagData(nTagIndex)\nInteger = Val(sData)
                Else
                  debugMsg(sProcName, "setting bResult=#False")
                  bResult = #False
                  Break
                EndIf
              Case "f"
                If IsNumeric(sData)
                  \aTagData(nTagIndex)\fFloat = ValF(sData)
                Else
                  debugMsg(sProcName, "setting bResult=#False")
                  bResult = #False
                  Break
                EndIf
              Case "s"
                \aTagData(nTagIndex)\sString = sData
            EndSelect
          Next n
        EndIf
      Else
        ; message doesn't start with "/"
        bResult = #False
      EndIf ; EndIf Left(sEnteredString, 1) = "/"
    EndIf ; EndIf Len(sEnteredString) > 0
    
    debugMsg(sProcName, "\sOSCItemString=" + \sOSCItemString)
    debugMsg(sProcName, "\sOSCAddress=" + \sOSCAddress)
    debugMsg(sProcName, "\sTagString=" + \sTagString + ", \nTagCount=" + \nTagCount)
    For n = 1 To \nTagCount
      sTag = Mid(\sTagString,n,1)
      Select sTag
        Case "i"
          debugMsg(sProcName, "\aTagData(" + Str(n-1) + ")\nInteger=" + \aTagData(n-1)\nInteger)
        Case "f"
          debugMsg(sProcName, "\aTagData(" + Str(n-1) + ")\fFloat=" + StrF(\aTagData(n-1)\fFloat))
        Case "s"
          debugMsg(sProcName, "\aTagData(" + Str(n-1) + ")\sString=" + \aTagData(n-1)\sString)
      EndSelect
    Next n
    
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure.s getCompIPAddresses()
  PROCNAMEC()
  ; returns IPv4 addresses for this machine, separated by line feeds (#LF$)
  Protected sIPAddresses.s
  Protected nIPAddr
  
  ExamineIPAddresses() 
  Repeat
    nIPAddr = NextIPAddress()
    If nIPAddr = 0
      Break
    EndIf
    If Len(sIPAddresses) > 0
      sIPAddresses + #LF$
    EndIf
    sIPAddresses + IPString(nIPAddr)
  ForEver
  ProcedureReturn sIPAddresses
EndProcedure

Procedure displayCompIPAddresses()
  PROCNAMEC()
  Protected sIPAddresses.s
  Protected nIPAddr
  Protected nActiveWindow
  Protected nReply
  
  nActiveWindow = GetActiveWindow()
  
  ExamineIPAddresses() 
  Repeat
    nIPAddr = NextIPAddress()
    If nIPAddr = 0
      Break
    EndIf
    If Len(sIPAddresses) > 0
      sIPAddresses + #LF$
    EndIf
    sIPAddresses + Lang("Network", "IPAddr") + ": " + IPString(nIPAddr)
  ForEver
  sIPAddresses + #LF$ + #LF$ + Lang("Network", "MoreInfo")
  
  ensureSplashNotOnTop()
  nReply = scsMessageRequester(Lang("Network", "CompIPAddresses"), sIPAddresses, #PB_MessageRequester_YesNo)
  
  If nReply = #PB_MessageRequester_Yes
    showMoreInfoForCompIPAddresses()
  EndIf
  
  If IsWindow(nActiveWindow)
    SAW(nActiveWindow)
  EndIf
  
EndProcedure

Procedure showMoreInfoForCompIPAddresses()
  PROCNAMEC()
  ; this procedure displays a message box with the results of the Windows function ipconfig, but displaying info only for adapters that include "ipv4" somewhere in their properties
  Protected nProg
  Protected sTitle.s, sOutput.s, sAdapterInfo.s, sTemp.s
  Protected bLookingForAdapter, bSkipRead, bWantThisAdapter
  
  debugMsg(sProcName, #SCS_START)
  
  nProg = RunProgram("ipconfig", "", "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  ; debugMsg(sProcName, "nProg=" + nProg)
  If nProg
    bLookingForAdapter = #True
    While ProgramRunning(nProg)
      ; debugMsg(sProcName, "ProgramRunning")
      If AvailableProgramOutput(nProg)
        ; debugMsg(sProcName, "AvailableProgramOutput(" + nProg + ")")
        If bSkipRead = #False
          sTemp = ReadProgramString(nProg)
          ; debugMsg(sProcName, "sTemp=" + #DQUOTE$ + sTemp + #DQUOTE$)
        Else
          bSkipRead = #False
        EndIf
        If bLookingForAdapter
          If Len(sTemp) > 1
            If Left(sTemp,1) <> " "
              sAdapterInfo = sTemp + Chr(10)
              bLookingForAdapter = #False
              ; debugMsg(sProcName, "bLookingForAdapter=" + strB(bLookingForAdapter) + ", sAdaptorInfo=" + #DQUOTE$ + ReplaceString(sAdapterInfo, Chr(10), "<CR>") + #DQUOTE$)
              bWantThisAdapter = #False
            EndIf
          EndIf
        Else
          If Len(sTemp) > 1
            If Left(sTemp,1) = " "
              If FindString(sTemp,"ipv4", 1, #PB_String_NoCase)
                bWantThisAdapter = #True
              EndIf
              sAdapterInfo + sTemp + Chr(10)
              ; debugMsg(sProcName, "bWantThisAdapter=" + strB(bWantThisAdapter) + ", sAdaptorInfo=" + #DQUOTE$ + ReplaceString(sAdapterInfo, Chr(10), "<CR>") + #DQUOTE$)
            Else
              If bWantThisAdapter
                If Len(sOutput) > 0
                  sOutput + Chr(10)
                EndIf
                sOutput + sAdapterInfo
              EndIf
              bLookingForAdapter = #True
              bSkipRead = #True
            EndIf
          EndIf
        EndIf
      EndIf
    Wend
    CloseProgram(nProg) ; close the connection to the program
    
    ; Added 15Oct2024 11.10.6ao
    If bWantThisAdapter And bLookingForAdapter = #False
      If Len(sOutput) > 0
        sOutput + Chr(10)
      EndIf
      sOutput + sAdapterInfo
    EndIf
    ; End added 15Oct2024 11.10.6ao
  EndIf
  
  debugMsg(sProcName, sOutput)
  
  sTitle = Lang("WOP", "btnRAIIPINfo") ; nb not quite the same as the button text as the button text is populated from LangEllipsis()
  scsMessageRequester(sTitle, sOutput)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure RAI_Init()
  PROCNAMEC()
  Protected nLocalPort1, nLocalPort2, nLocalPort3
  Protected nNetworkProtocol
  Protected nMode, sMode.s
  Protected sMsg.s
  Protected nReply
  
  debugMsg(sProcName, #SCS_START)
  
  If grRAI\bRAIInitialized
    debugMsg(sProcName, "exiting because grRAI\bRAIInitialized=" + strB(grRAI\bRAIInitialized))
    ProcedureReturn
  EndIf
  
  With grRAIOptions
    debugMsg(sProcName, "\bRAIEnabled=" + strB(\bRAIEnabled))
    Select \nNetworkProtocol
      Case #SCS_NETWORK_PR_UDP
        nMode = #PB_Network_UDP
        sMode = "#PB_Network_UDP"
      Default
        nMode = #PB_Network_TCP
        sMode = "#PB_Network_TCP"
    EndSelect
    nNetworkProtocol = \nNetworkProtocol
    nLocalPort1 = \nLocalPort         ; port used by remote app to send commands to SCS, and for SCS to send back replies (by default this will be 58000)
    If \nRAIApp = #SCS_RAI_APP_SCSREMOTE
      nLocalPort2 = nLocalPort1 + 1     ; port used to send SCS-initiated messages to the remote app, eg GETSTATE (eg 58001 if above is 58000)
      nLocalPort3 = nLocalPort2 + 1     ; port used to send progress message to the remote app
    EndIf
  EndWith
  
  With grRAI
    
    If (grLicInfo\bFMAvailable) And (grFMOptions\nFunctionalMode = #SCS_FM_BACKUP)
      debugMsg(sProcName, "Remote App Interface not to be enabled for SCS Backup instances")
      \bRAIAvailable = #False
      ProcedureReturn #False
    EndIf
    
    While #True
      ; do NOT use the \sLocalIPAddr but always allow connection from any IP address
      \nServerConnection1 = CreateNetworkServer(#PB_Any, nLocalPort1, nMode)
      ; debugMsg2(sProcName, "CreateNetworkServer(#PB_Any, " + nLocalPort1 + ", " + sMode + ")", \nServerConnection1)
      If \nServerConnection1
        newHandle(#SCS_HANDLE_NETWORK_SERVER, \nServerConnection1, #False)
        debugMsg(sProcName, "CreateNetworkServer(#PB_Any, " + nLocalPort1 + ", " + sMode + ") returned " + \nServerConnection1 + " (" + decodeHandle(\nServerConnection1) + ")")
        Break ; opened successfully so Break from the loop
      Else
        sMsg = LangPars("Network", "CannotOpenServer", decodeNetworkProtocol(nNetworkProtocol), Str(nLocalPort1))
        debugMsg(sProcName, sMsg)
        nReply = scsMessageRequester(Lang("RAI","RAI"), sMsg, #PB_MessageRequester_YesNo)
        If nReply = #PB_MessageRequester_Yes
          Continue
        Else
          \bRAIAvailable = #False
          ProcedureReturn #False
        EndIf
      EndIf
    Wend
    
    If nLocalPort2
      ; now open 2nd port, but ignore if it cannot be opened (although that is unlikely if the first port was opened!)
      \nServerConnection2 = CreateNetworkServer(#PB_Any, nLocalPort2, nMode)
      If \nServerConnection2
        newHandle(#SCS_HANDLE_NETWORK_SERVER, \nServerConnection2, #False)
        debugMsg(sProcName, "CreateNetworkServer(#PB_Any, " + nLocalPort2 + ", " + sMode + ") returned " + \nServerConnection2 + " (" + decodeHandle(\nServerConnection2) + ")")
      EndIf
    Else
      \nServerConnection2 = 0
    EndIf
    
    If nLocalPort3
      ; now open 3rd port, but ignore if it cannot be opened
      \nServerConnection3 = CreateNetworkServer(#PB_Any, nLocalPort3, nMode)
      If \nServerConnection3
        newHandle(#SCS_HANDLE_NETWORK_SERVER, \nServerConnection3, #False)
        debugMsg(sProcName, "CreateNetworkServer(#PB_Any, " + nLocalPort3 + ", " + sMode + ") returned " + \nServerConnection3 + " (" + decodeHandle(\nServerConnection3) + ")")
      EndIf
    Else
      \nServerConnection3 = 0
    EndIf
    
    If \nNetworkControlPtr1 < 0
      debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
      \nNetworkControlPtr1 = getBlankNetworkControlEntry()
    EndIf
    If \nNetworkControlPtr1 >= 0
      gaNetworkControl(\nNetworkControlPtr1)\bControlExists = #True
      gaNetworkControl(\nNetworkControlPtr1)\bRAIDev = #True
      gaNetworkControl(\nNetworkControlPtr1)\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN
      gaNetworkControl(\nNetworkControlPtr1)\nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
      gaNetworkControl(\nNetworkControlPtr1)\nNetworkProtocol = nNetworkProtocol
      gaNetworkControl(\nNetworkControlPtr1)\nLocalPort = nLocalPort1
      gaNetworkControl(\nNetworkControlPtr1)\nServerConnection = \nServerConnection1
      gaNetworkControl(\nNetworkControlPtr1)\bNetworkDevInitialized = #True
    EndIf
    gnNetworkServersActive + 1
    
    If \nServerConnection2
      If \nNetworkControlPtr2 < 0
        debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
        \nNetworkControlPtr2 = getBlankNetworkControlEntry()
      EndIf
      If \nNetworkControlPtr2 >= 0
        gaNetworkControl(\nNetworkControlPtr2)\bControlExists = #True
        gaNetworkControl(\nNetworkControlPtr2)\bRAIDev = #True
        gaNetworkControl(\nNetworkControlPtr2)\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN
        gaNetworkControl(\nNetworkControlPtr2)\nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
        gaNetworkControl(\nNetworkControlPtr2)\nNetworkProtocol = nNetworkProtocol
        gaNetworkControl(\nNetworkControlPtr2)\nLocalPort = nLocalPort2
        gaNetworkControl(\nNetworkControlPtr2)\nServerConnection = \nServerConnection2
        gaNetworkControl(\nNetworkControlPtr2)\bNetworkDevInitialized = #True
      EndIf
      gnNetworkServersActive + 1
    EndIf
    
    If \nServerConnection3
      If \nNetworkControlPtr3 < 0
        debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
        \nNetworkControlPtr3 = getBlankNetworkControlEntry()
      EndIf
      If \nNetworkControlPtr3 >= 0
        gaNetworkControl(\nNetworkControlPtr3)\bControlExists = #True
        gaNetworkControl(\nNetworkControlPtr3)\bRAIDev = #True
        gaNetworkControl(\nNetworkControlPtr3)\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN
        gaNetworkControl(\nNetworkControlPtr3)\nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
        gaNetworkControl(\nNetworkControlPtr3)\nNetworkProtocol = nNetworkProtocol
        gaNetworkControl(\nNetworkControlPtr3)\nLocalPort = nLocalPort3
        gaNetworkControl(\nNetworkControlPtr3)\nServerConnection = \nServerConnection3
        gaNetworkControl(\nNetworkControlPtr3)\bNetworkDevInitialized = #True
      EndIf
      gnNetworkServersActive + 1
    EndIf
    
    debugMsg(sProcName, "gnNetworkServersActive=" + gnNetworkServersActive + ", grRAI\nNetworkControlPtr1=" + \nNetworkControlPtr1 +
                        ", grRAI\nNetworkControlPtr2=" + \nNetworkControlPtr2 + ", grRAI\nNetworkControlPtr3=" + \nNetworkControlPtr3)
    
    \bRAIAvailable = #True
    \bRAIInitialized = #True
    
    If THR_getThreadState(#SCS_THREAD_NETWORK) <> #SCS_THREAD_STATE_ACTIVE
      debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_NETWORK)")
      THR_createOrResumeAThread(#SCS_THREAD_NETWORK)
    EndIf

  EndWith
  
;   debugMsg(sProcName, "calling listNetworkControl()")
;   listNetworkControl()
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure RAI_IsClientActive()
  PROCNAMEC()
  Protected nNetworkControlPtr
  
  nNetworkControlPtr = getNetworkControlPtrForRAI(#True)
  ; debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr)
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If (grRAI\bRAIClientActive = #False Or \nClientConnection = 0) And \nNetworkProtocol = #SCS_NETWORK_PR_UDP
        ; debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + \nServerConnection + ", gnEventClient=" + gnEventClient)
        If \nServerConnection And gnEventClient
          debugMsg(sProcName, "GetClientIP(" + decodeHandle(gnEventClient) + ")=" + IPString(GetClientIP(gnEventClient)) + ", GetClientPort(" + decodeHandle(gnEventClient) + ")=" + GetClientPort(gnEventClient))
          \sRemoteHost = IPString(GetClientIP(gnEventClient))
          \nRemotePort = GetClientPort(gnEventClient)
          debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nOpenConnectionTimeout=" + \nOpenConnectionTimeout)
          \nClientConnection = OpenNetworkConnection(\sRemoteHost, \nRemotePort, #PB_Network_UDP, \nOpenConnectionTimeout)
          newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nClientConnection)
          debugMsg(sProcName, "OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", #PB_Network_UDP, " + \nOpenConnectionTimeout + ") returned " + decodeHandle(\nClientConnection))
          If \nClientConnection
            grRAI\nClientConnection1 = \nClientConnection
            grRAI\bRAIClientActive = #True
          EndIf
        EndIf
        debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection) + ", \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol))
        debugMsg(sProcName, "grRAI\bRAIClientActive=" + strB(grRAI\bRAIClientActive))
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning grRAI\bRAIClientActive=" + strB(grRAI\bRAIClientActive))
  ProcedureReturn grRAI\bRAIClientActive
  
EndProcedure

Procedure RAI_Terminate()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grRAI
    If \bRAIAvailable
      
      debugMsg(sProcName, "grRAI\nServerConnection1=" + decodeHandle(\nServerConnection1) + ", \nClientConnection1=" + decodeHandle(\nClientConnection1) + ", \nNetworkControlPtr1=" + \nNetworkControlPtr1 +
                          ", \nServerConnection2=" + decodeHandle(\nServerConnection2) + ", \nClientConnection2=" + decodeHandle(\nClientConnection2) + ", \nNetworkControlPtr2=" + \nNetworkControlPtr2 +
                          ", \nServerConnection3=" + decodeHandle(\nServerConnection3) + ", \nClientConnection3=" + decodeHandle(\nClientConnection3) + ", \nNetworkControlPtr3=" + \nNetworkControlPtr3)
      
      If (\nServerConnection2) And (\nClientConnection2) And (\nNetworkControlPtr2)
        sendOSCMessage(\nNetworkControlPtr2, "/disconnecting" + #LF$)
        Delay(100)
      EndIf
      
      If \nServerConnection1
        debugMsg(sProcName, "calling CloseNetworkServer(" + decodeHandle(\nServerConnection1) + ")")
        CloseNetworkServer(\nServerConnection1)
        debugMsg(sProcName, "CloseNetworkServer(" + decodeHandle(\nServerConnection1) + ")")
        If \nNetworkControlPtr1 >= 0
          If gaNetworkControl(\nNetworkControlPtr1)\nServerConnection = \nServerConnection1
            gaNetworkControl(\nNetworkControlPtr1)\nServerConnection = 0
            If gaNetworkControl(\nNetworkControlPtr1)\nClientConnection = \nClientConnection1
              gaNetworkControl(\nNetworkControlPtr1)\nClientConnection = 0
            EndIf
            gaNetworkControl(\nNetworkControlPtr1)\bNetworkDevInitialized = #False
          EndIf
        EndIf
        freeHandle(\nServerConnection1)
        \nServerConnection1 = 0
        If \nClientConnection1
          freeHandle(\nClientConnection1)
          \nClientConnection1 = 0
        EndIf
        gnNetworkServersActive - 1
      EndIf
      
      If \nServerConnection2
        debugMsg(sProcName, "calling CloseNetworkServer(" + decodeHandle(\nServerConnection2) + ")")
        CloseNetworkServer(\nServerConnection2)
        debugMsg(sProcName, "CloseNetworkServer(" + decodeHandle(\nServerConnection2) + ")")
        If \nNetworkControlPtr2 >= 0
          If gaNetworkControl(\nNetworkControlPtr2)\nServerConnection = \nServerConnection2
            gaNetworkControl(\nNetworkControlPtr2)\nServerConnection = 0
            If gaNetworkControl(\nNetworkControlPtr2)\nClientConnection = \nClientConnection2
              gaNetworkControl(\nNetworkControlPtr2)\nClientConnection = 0
            EndIf
            gaNetworkControl(\nNetworkControlPtr2)\bNetworkDevInitialized = #False
          EndIf
        EndIf
        freeHandle(\nServerConnection2)
        \nServerConnection2 = 0
        If \nClientConnection2
          freeHandle(\nClientConnection2)
          \nClientConnection2 = 0
        EndIf
        gnNetworkServersActive - 1
      EndIf
      
      If \nServerConnection3
        debugMsg(sProcName, "calling CloseNetworkServer(" + decodeHandle(\nServerConnection3) + ")")
        CloseNetworkServer(\nServerConnection3)
        debugMsg(sProcName, "CloseNetworkServer(" + decodeHandle(\nServerConnection3) + ")")
        If \nNetworkControlPtr3 >= 0
          If gaNetworkControl(\nNetworkControlPtr3)\nServerConnection = \nServerConnection3
            gaNetworkControl(\nNetworkControlPtr3)\nServerConnection = 0
            If gaNetworkControl(\nNetworkControlPtr3)\nClientConnection = \nClientConnection3
              gaNetworkControl(\nNetworkControlPtr3)\nClientConnection = 0
            EndIf
            gaNetworkControl(\nNetworkControlPtr3)\bNetworkDevInitialized = #False
          EndIf
        EndIf
        freeHandle(\nServerConnection3)
        \nServerConnection3 = 0
        If \nClientConnection3
          freeHandle(\nClientConnection3)
          \nClientConnection3 = 0
        EndIf
        gnNetworkServersActive - 1
      EndIf
    EndIf
    
    \bRAIInitialized = #False
    debugMsg(sProcName, "gnNetworkServersActive=" + gnNetworkServersActive)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getRAICueState(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nCurrState, nRAICueState, nSubState
  Protected j
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      nCurrState = getCueStateForDisplayEtc(pCuePtr)
      j = \nFirstSubIndex
      While j >= 0
        If aSub(j)\bStartedInEditor
          nSubState = aSub(j)\nSubState
          If (nSubState >= #SCS_CUE_FADING_IN) And (nSubState <= #SCS_CUE_FADING_OUT)
            nCurrState = nSubState
            Break
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
      If (nCurrState = #SCS_CUE_SUB_COUNTDOWN_TO_START)
        nRAICueState = #SCS_RAI_CUE_STATE_PLAYING
        
      ElseIf (nCurrState < #SCS_CUE_FADING_IN) Or (nCurrState = #SCS_CUE_PL_READY) Or (nCurrState = #SCS_CUE_STANDBY)
        nRAICueState = #SCS_RAI_CUE_STATE_WAITING
        
      ElseIf (nCurrState = #SCS_CUE_PAUSED) Or (nCurrState = #SCS_CUE_HIBERNATING)
        nRAICueState = #SCS_RAI_CUE_STATE_PAUSED
        
      ElseIf (nCurrState >= #SCS_CUE_FADING_IN) And (nCurrState <= #SCS_CUE_FADING_OUT)
        nRAICueState = #SCS_RAI_CUE_STATE_PLAYING
        
      Else
        nRAICueState = #SCS_RAI_CUE_STATE_ENDED
        
      EndIf
    EndWith
  EndIf
  ProcedureReturn nRAICueState
  
EndProcedure

Procedure getCueStartedInEditor(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, bStartedInEditor
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bStartedInEditor
        bStartedInEditor = #True
        Break
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
  ProcedureReturn bStartedInEditor
EndProcedure

Procedure sendRAICueStateIfReqd(pCuePtr, bHideTracing=#False)
  PROCNAMEC()
  Protected nCueState, nRAICueState
  Protected bSendReqd
  Protected nNetworkControlPtr = -1
  Protected sQualifier.s
  
  If RAI_IsClientActive()
    If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
      If pCuePtr >= 0
        With aCue(pCuePtr)
          nCueState = \nCueState
          nRAICueState = getRAICueState(pCuePtr)
          If \nRAICueState <> nRAICueState
            \nRAICueState = nRAICueState
            bSendReqd = #True
            If getCueStartedInEditor(pCuePtr)
              sQualifier = "/^4"
            ElseIf pCuePtr = nEditCuePtr
              If GetActiveWindow() = #WED
                sQualifier = "/^4"
              EndIf
            EndIf
          EndIf
        EndWith
        
        If bSendReqd
          nNetworkControlPtr = getNetworkControlPtrForRAI()
          If nNetworkControlPtr >= 0
            With gaNetworkControl(nNetworkControlPtr)
              \bOSCTextMsg = #True
              \bAddLF = #True
              \sOSCPathOriginal = "/_cue/statechange" + sQualifier
              \sOSCPath = "/cue/statechange" + sQualifier
              \sOSCTagTypes = "si"
              \nOSCStringCount = 1
              \nOSCLongCount = 1
              \sOSCString(0) = aCue(pCuePtr)\sCue
              \nOSCLong(0) = nRAICueState
              populateOSCMessageDataIfReqd(nNetworkControlPtr)
              debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
              sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
            EndWith
          EndIf
        EndIf
      EndIf 
    EndIf
  EndIf
  
EndProcedure

Procedure sendRAICueSetPosIfReqd(pAudPtr, bUsePort3=#False, bHideTracing=#False)
  ; PROCNAMECA(pAudPtr)
  Protected nCuePtr
  Protected sQualifier.s
  Protected nNetworkControlPtr

  If (RAI_IsClientActive()) And (pAudPtr >= 0)
    If aAud(pAudPtr)\nAudState < #SCS_CUE_COMPLETED
      nCuePtr = aAud(pAudPtr)\nCueIndex
      If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE) And (bUsePort3) And (grRAI\nClientConnection3 <> 0) And (grRAI\nNetworkControlPtr3 >= 0)
        nNetworkControlPtr = grRAI\nNetworkControlPtr3
      Else
        nNetworkControlPtr = getNetworkControlPtrForRAI()
      EndIf
      If nNetworkControlPtr >= 0
        If getCueStartedInEditor(nCuePtr)
          sQualifier = "/^4"
        ElseIf pAudPtr = nEditAudPtr
          If GetActiveWindow() = #WED
            sQualifier = "/^4"
          EndIf
        EndIf
        With gaNetworkControl(nNetworkControlPtr)
          \bOSCTextMsg = #True
          \bAddLF = #True
          \sOSCPathOriginal = "/_cue/setpos" + sQualifier
          \sOSCPath = "/cue/setpos" + sQualifier
          \sOSCTagTypes = "si"
          \nOSCStringCount = 1
          \nOSCLongCount = 1
          \sOSCString(0) = aCue(nCuePtr)\sCue
          If aAud(pAudPtr)\nRelFilePos >= 0
            \nOSCLong(0) = aAud(pAudPtr)\nRelFilePos
            aAud(pAudPtr)\nRAIRelFilePos = aAud(pAudPtr)\nRelFilePos
          Else
            \nOSCLong(0) = aAud(pAudPtr)\nCuePos
          EndIf
          populateOSCMessageDataIfReqd(nNetworkControlPtr)
          ; debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
          sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
          ; sendOSCComplexMessage(nNetworkControlPtr, #False)
        EndWith
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure checkForAndSendSetPosMsgs()
  PROCNAMEC()
  Protected k
  
  If grRAI\nSendSetPosCount > 0
    For k = 1 To gnLastAud
      If aAud(k)\bRAISendSetPos
        sendRAICueSetPosIfReqd(k, #True, #True)
        aAud(k)\bRAISendSetPos = #False
        grRAI\nSendSetPosCount - 1
        If grRAI\nSendSetPosCount = 0
          Break
        EndIf
      EndIf
    Next k
  EndIf
  
EndProcedure

Procedure sendRAIGlobalCommand(sCommand.s, bHideTracing=#False)
  PROCNAMEC()
  Protected nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START + ", sCommand=" + #DQUOTE$ + sCommand + #DQUOTE$ + ", grRAI\bRAIClientActive=" + strB(grRAI\bRAIClientActive))
  
  If RAI_IsClientActive()
    nNetworkControlPtr = getNetworkControlPtrForRAI()
    If nNetworkControlPtr >= 0
      With gaNetworkControl(nNetworkControlPtr)
        \bOSCTextMsg = #True
        \bAddLF = #True
        \sOSCPathOriginal = "/_global/" + sCommand
        \sOSCPath = "/global/" + sCommand
        \sOSCTagTypes = ""
        \nOSCStringCount = 0
        \nOSCLongCount = 0
        populateOSCMessageDataIfReqd(nNetworkControlPtr)
        debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
        sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure sendRAIProdTimerCommand(sCommand.s, bHideTracing=#False)
  PROCNAMEC()
  Protected nNetworkControlPtr
  
  If RAI_IsClientActive()
    nNetworkControlPtr = getNetworkControlPtrForRAI()
    If nNetworkControlPtr >= 0
      With gaNetworkControl(nNetworkControlPtr)
        \bOSCTextMsg = #True
        \bAddLF = #True
        \sOSCPathOriginal = "/_pt/" + sCommand
        \sOSCPath = "/pt/" + sCommand
        \sOSCTagTypes = ""
        \nOSCStringCount = 0
        \nOSCLongCount = 0
        populateOSCMessageDataIfReqd(nNetworkControlPtr)
        debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
        sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure sendRAICurrCueAndNextCue(bHideTracing=#False)
  PROCNAMEC()
  Protected i, nCueCount
  Protected nCurrCueNumber = -1, nNextCueNumber = -1
  Protected nCueNumber = -1
  Protected nCuePtr = -1, nSubPtr = -1
  Protected nActivationMethod, nNetworkControlPtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  If RAI_IsClientActive()
    ; debugMsg(sProcName, "grRAI\nClientConnection1=" + grRAI\nClientConnection1)
    If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
      ; count enabled cues and set relevant pointers
      For i = 1 To gnLastCue
        If aCue(i)\bCueEnabled
          nActivationMethod = aCue(i)\nActivationMethod
          If (nActivationMethod & #SCS_ACMETH_HK_BIT) Or (nActivationMethod & #SCS_ACMETH_EXT_BIT)
            ; ignore hotkey and external control cues
          Else
            nCueCount + 1
            If nCueCount = nCueNumber
              nCuePtr = i
              nSubPtr = aCue(i)\nFirstSubIndex
            EndIf
            If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
              nCurrCueNumber = nCueCount
            EndIf
            If i = gnCueToGo
              nNextCueNumber = nCueCount
            EndIf
          EndIf
        EndIf
      Next i
      debugMsg(sProcName, "nCueCount=" + nCueCount + ", nCurrCueNumber=" + nCurrCueNumber + ", nNextCueNumber=" + nNextCueNumber + ", nCuePtr=" + getCueLabel(nCuePtr) + ", nSubPtr=" + getSubLabel(nSubPtr))
      If nCurrCueNumber < 0
        nCurrCueNumber = nNextCueNumber
      EndIf
      
      nNetworkControlPtr = getNetworkControlPtrForRAI()
      If nNetworkControlPtr >= 0
        With gaNetworkControl(nNetworkControlPtr)
          If nCurrCueNumber > 0
            \bOSCTextMsg = #True
            \bAddLF = #True
            \sOSCPathOriginal = "/_info/currcue"
            \sOSCPath = "/info/currcue"
            \sOSCTagTypes = "i"
            \nOSCLongCount = 1
            \nOSCLong(0) = nCurrCueNumber
            populateOSCMessageDataIfReqd(nNetworkControlPtr)
            debugMsgN(sProcName, "(curr) calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
            sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
          EndIf
          If nNextCueNumber > 0
            \bOSCTextMsg = #True
            \bAddLF = #True
            \sOSCPathOriginal = "/_info/nextcue"
            \sOSCPath = "/info/nextcue"
            \sOSCTagTypes = "i"
            \nOSCLongCount = 1
            \nOSCLong(0) = nNextCueNumber
            populateOSCMessageDataIfReqd(nNetworkControlPtr)
            debugMsgN(sProcName, "(next) calling sendOSCComplexMessage(" + nNetworkControlPtr + ", " + strB(bHideTracing) + ")")
            sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
          EndIf
        EndWith
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s decodeRAIClient(nClientConnection)
  Protected sRAIClient.s
  
  With grRAI
    Select nClientConnection
      Case \nClientConnection1
        sRAIClient = "1"
      Case \nClientConnection2
        sRAIClient = "2"
      Case \nClientConnection3
        sRAIClient = "3"
      Default
        sRAIClient = decodeHandle(nClientConnection)
    EndSelect
  EndWith
  ProcedureReturn sRAIClient
EndProcedure

Procedure.s decodeRAIApp(nRAIApp)
  Protected sRAIApp.s
  
  Select nRAIApp
    Case #SCS_RAI_APP_SCSREMOTE
      sRAIApp = "SCSremote"
    Case #SCS_RAI_APP_OSC
      sRAIApp = "OSC_APP"
    Default
      sRAIApp = "SCSremote"
  EndSelect
  ProcedureReturn sRAIApp
EndProcedure

Procedure encodeRAIApp(sRAIApp.s)
  Protected nRAIApp
  
  Select sRAIApp
    Case "SCSremote"
      nRAIApp = #SCS_RAI_APP_SCSREMOTE
    Case "OSC_APP"
      nRAIApp = #SCS_RAI_APP_OSC
    Default
      nRAIApp = #SCS_RAI_APP_SCSREMOTE
  EndSelect
  ProcedureReturn nRAIApp

EndProcedure

Procedure FM_init(bForceClose)
  PROCNAMEC()
  Protected nFMServerIndex, nNetworkControlPtr
  Protected sTitle.s, sText.s, nResponse, bResult, nIPAddr
  Protected nBytesSent
  Protected sPrompt.s, sButtons.s, nTryAgain, nChangeIPAddress, nStandAlone, sRemoteHost.s, sPromptNewIPAddress.s
  
  debugMsg(sProcName, #SCS_START)
  
  If gnFMUniqueMsgId = 0
    gnFMUniqueMsgId = Val(FormatDate("%hh%ii%ss", Date())) * 10000
  EndIf
  
  With grFMOptions
    ; these fields are not really an 'option' but a convenient way to set TCP or UDP
    \nFMNetworkMode = #PB_Network_UDP
    \sFMNetworkMode = "#PB_Network_UDP"
    
    ; close any network server or connection not required
    If \nFMServerId
      If (\nFunctionalMode <> #SCS_FM_PRIMARY) Or (bForceClose)
        CloseNetworkServer(\nFMServerId)
        debugMsg(sProcName, "CloseNetworkServer(" + decodeHandle(\nFMServerId) + ")")
        \nFMServerId = 0
        gnNetworkServersActive - 1
      EndIf
    EndIf
    
    If \nFMClientId
      If (\nFunctionalMode <> #SCS_FM_BACKUP) Or (bForceClose)
        If \nFMNetworkMode = #PB_Network_UDP
          nBytesSent = SendNetworkString(\nFMClientId, "/fmh/bdi", #PB_Ascii) ; functional mode handler / backup connection disconnect
          debugMsg(sProcName, "SendNetworkString(\nFMClientId, " + #DQUOTE$ + "/fmh/bdi" + #DQUOTE$ + ", #PB_Ascii) returned nBytesSent=" + nBytesSent)
        EndIf
        nNetworkControlPtr = getNetworkControlPtrForClientConnection(\nFMClientId, #False)
        If nNetworkControlPtr >= 0
          closeANetworkConnection(nNetworkControlPtr)
        Else
          CloseNetworkConnection(\nFMClientId)
          debugMsg(sProcName, "CloseNetworkConnection(" + decodeHandle(\nFMClientId) + ")")
        EndIf
        \nFMClientId = 0
        gnNetworkClientsActive - 1
        debugMsg(sProcName, "gnNetworkClientsActive=" + gnNetworkClientsActive)
      EndIf
    EndIf
    
    debugMsg(sProcName, "grFMOptions\nFunctionalMode=" + decodeFunctionalMode(\nFunctionalMode))
    ; now create or open any network server or connection required
    Select \nFunctionalMode
      Case #SCS_FM_STAND_ALONE
        ; no action
        
      Case #SCS_FM_PRIMARY
        If \nFMServerId = 0
          \nFMServerId = CreateNetworkServer(#PB_Any, #SCS_PRIMARY_SERVER_PORT, \nFMNetworkMode)
          If \nFMServerId
            newHandle(#SCS_HANDLE_NETWORK_SERVER, \nFMServerId)
            debugMsg(sProcName, "CreateNetworkServer(#PB_Any, " + #SCS_PRIMARY_SERVER_PORT + ", " + \sFMNetworkMode + ") returned grFMOptions\nFMServerId=" + \nFMServerId + " (" + decodeHandle(\nFMServerId) + ")")
            gnNetworkServersActive + 1
            ; Added 16Aug2021 11.8.5.1aa
            If THR_getThreadState(#SCS_THREAD_NETWORK) <> #SCS_THREAD_STATE_ACTIVE
              debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_NETWORK)")
              THR_createOrResumeAThread(#SCS_THREAD_NETWORK)
            EndIf
            ; End added 16Aug2021 11.8.5.1aa
          Else
            debugMsg(sProcName, "CreateNetworkServer(#PB_Any, " + #SCS_PRIMARY_SERVER_PORT + ", " + \sFMNetworkMode + ") returned grFMOptionsnFMServerId=" + \nFMServerId)
          EndIf
        EndIf
        ; Added 4Sep2021 11.8.6af when trying to work out why Paul Finch's primary didn't respond to the backup
        bResult = ExamineIPAddresses()
        debugMsg(sProcName, "ExamineIPAddresses() returned " + strB(bResult))
        Repeat
          nIPAddr = NextIPAddress()
          If nIPAddr = 0
            Break
          EndIf
          debugMsg(sProcName, "NextIPAddress() returned " + nIPAddr + ", IPString(" + nIPAddr + ")=" + IPString(nIPAddr))
        ForEver
        ; End added 4Sep2021 11.8.6af
        
      Case #SCS_FM_BACKUP
        debugMsg(sProcName, "\sFMServerName=" + \sFMServerName + ", \nFMClientId=" + \nFMClientId)
        If \sFMServerName
          If \nFMClientId = 0
            While #True
              \nFMClientId = OpenNetworkConnection(\sFMServerName, #SCS_PRIMARY_SERVER_PORT, \nFMNetworkMode, 4000)
              If \nFMClientId = 0
                debugMsg(sProcName, "OpenNetworkConnection(" + #DQUOTE$ + \sFMServerName + #DQUOTE$ + ", " + #SCS_PRIMARY_SERVER_PORT + ", " + \sFMNetworkMode + ", 4000) returned " + \nFMClientId)
                sTitle = Lang("Common", "FunctionalMode") + ": " + UCase(Lang("Common", "Backup"))
                sText = LangPars("Errors", "CannotConnectToPrimary", \sFMServerName)
                nResponse = scsMessageRequester(sTitle, sText, #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
                If nResponse = #PB_MessageRequester_Yes
                  Continue  ; try again
                Else
                  ; switch to stand-alone
                  \nFunctionalMode = #SCS_FM_STAND_ALONE
                  Break ; break out of 'While #True' loop
                EndIf
              Else  ; \nFMClient <> 0
                newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nFMClientId)
                debugMsg(sProcName, "OpenNetworkConnection(" + #DQUOTE$ + \sFMServerName + #DQUOTE$ + ", " + #SCS_PRIMARY_SERVER_PORT + ", " + \sFMNetworkMode + ", 4000) returned " + \nFMClientId + " (" + decodeHandle(\nFMClientId) + ")")
                gnNetworkClientsActive + 1
                nNetworkControlPtr = FMB_ServerConnectionRequest()
                If nNetworkControlPtr >= 0
                  \qTimeBCAReceived = 0
                  grFMOptions\nFMClientNetworkControlPtr = nNetworkControlPtr ; Added 16Aug2021 11.8.5.1aa
                  debugMsg(sProcName, "grFMOptions\nFMClientNetworkControlPtr=" + grFMOptions\nFMClientNetworkControlPtr)
                  If \nFMNetworkMode = #PB_Network_UDP
                    nBytesSent = SendNetworkString(\nFMClientId, "/fmh/bcr", #PB_Ascii) ; functional mode handler / backup connection request
                    debugMsg(sProcName, "SendNetworkString(" + decodeHandle(\nFMClientId) + ", " + #DQUOTE$ + "/fmh/bcr" + #DQUOTE$ + ", #PB_Ascii) returned nBytesSent=" + nBytesSent)
                  EndIf
                  \qTimeBCRSent = ElapsedMilliseconds()
                  If THR_getThreadState(#SCS_THREAD_NETWORK) <> #SCS_THREAD_STATE_ACTIVE
                    debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_NETWORK)")
                    THR_createOrResumeAThread(#SCS_THREAD_NETWORK)
                  EndIf
                  While ElapsedMilliseconds() < (\qTimeBCRSent + 500)
                    If \qTimeBCAReceived <> 0
                      Break
                    EndIf
                    Delay(100)
                  Wend
                  sTitle = Lang("Common", "FunctionalMode") + ": " + UCase(Lang("Common", "Backup"))
                  If \qTimeBCAReceived <> 0
                    If \sPrimaryVersion
                      If \sPrimaryVersion <> #SCS_VERSION
                        scsMessageRequester(sTitle, LangPars("Network", "VersionsDiffer", \sPrimaryVersion, #SCS_VERSION), #PB_MessageRequester_Warning)
                        ; nb - only a warning, so carry on
                      EndIf
                    EndIf
                    Break ; break out of 'While #True' loop
                  EndIf
                  ; connection to primary not yet established
                  sPrompt = LangPars("Errors", "CannotConnectToPrimary2", \sFMServerName)
                  sButtons = Lang("Network","btnTryAgain") + "|" +
                             Lang("Network","ChangeAddress") + "|" +
                             Lang("Network","btnStandAlone")
                  nTryAgain = 1
                  nChangeIPAddress = 2
                  nStandAlone = 3
                  nResponse = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 140, #IDI_EXCLAMATION)
                  Select nResponse
                    Case nTryAgain
                      Continue  ; try again
                    Case nChangeIPAddress
                      ; change IP address and try again
                      sPromptNewIPAddress = Lang("Network", "NewAddress") ; "New IP Address"
                      sRemoteHost = \sFMServerName
                      While #True
                        sRemoteHost = Trim(InputRequester(sTitle, sPromptNewIPAddress, sRemoteHost))
                        debugMsg(sProcName, "InputRequester() returned sRemoteHost=" + sRemoteHost)
                        If sRemoteHost
                          If validateIPAddressFormat(sRemoteHost, sPromptNewIPAddress, #False) = #False
                            debugMsg(sProcName, "validateIPAddressFormat('" + sRemoteHost + "', '" + sPromptNewIPAddress + "') returned #False")
                            scsMessageRequester(sTitle, sRemoteHost + " " + Lang("Errors", "NotValidForIP"))
                            Continue
                          EndIf
                          \sFMServerName = sRemoteHost
                          debugMsg(sProcName, "grFMOptions\sFMServerName=" + \sFMServerName)
                        EndIf
                        Break
                      Wend
                      Continue
                      
                    Case nStandAlone
                      ; switch to stand-alone
                      \nFunctionalMode = #SCS_FM_STAND_ALONE
                      Break ; break out of 'While #True' loop
                  EndSelect
                EndIf
                Break ; break out of 'While #True' loop
              EndIf
            Wend
          EndIf
        EndIf
    EndSelect
    
  EndWith
  
  debugMsg(sProcName, "gnNetworkServersActive=" + gnNetworkServersActive + ", gnNetworkClientsActive=" + gnNetworkClientsActive)
  
  debugMsg(sProcName, "calling setMidiEnabled()")
  setMidiEnabled()
  debugMsg(sProcName, "calling setNetworkEnabled()")
  setNetworkEnabled()
  debugMsg(sProcName, "calling setDMXEnabled()")
  setDMXEnabled()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; INFO FMP Procedures (Functional Mode Primary)

Procedure FMP_BackupConnectionRequest()
  PROCNAMEC()
  Protected nNetworkControlPtr
  Protected n, nFMBackupIndex = -1
  
  debugMsg(sProcName, #SCS_START)
  
  nNetworkControlPtr = getNetworkControlPtrForServerAndClientConnection(gnEventServer, gnEventClient, #True)
  If nNetworkControlPtr >= 0
    For n = 0 To gnLastFMBackup
      If gaFMBackup(n)\nNetworkControlPtr = nNetworkControlPtr
        nFMBackupIndex = n
        Break
      EndIf
    Next n
  EndIf
  
  If nFMBackupIndex < 0
    ; look for a free gaFMBackup slot
    For n = 0 To gnLastFMBackup
      If gaFMBackup(n)\nBackupId = 0
        nFMBackupIndex = n
        Break
      EndIf
    Next n
  EndIf
  If nFMBackupIndex < 0
    gnLastFMBackup + 1
    nFMBackupIndex = gnLastFMBackup
  EndIf
  If nFMBackupIndex > ArraySize(gaFMBackup())
    ReDim gaFMBackup(nFMBackupIndex)
  EndIf
  If nNetworkControlPtr < 0
    debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
    nNetworkControlPtr = getBlankNetworkControlEntry()
  EndIf
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      \bSCSBackupDev = #True
      \nServerConnection = gnEventServer
      \nClientConnection = gnEventClient
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + \nServerConnection + ", \nClientConnection=" + \nClientConnection)
      ; other items will be populated in processServerEvent(), frrom which this procedure is called
    EndWith
    gaFMBackup(nFMBackupIndex)\nNetworkControlPtr = nNetworkControlPtr
    gaFMBackup(nFMBackupIndex)\nBackupId = gnEventClient
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning nFMBackupIndex=" + nFMBackupIndex)
  ProcedureReturn nFMBackupIndex
  
EndProcedure

Procedure FMP_sendCueFileName(nFMBackupIndex)
  PROCNAMEC()
  Protected nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START + ", nFMBackupIndex=" + nFMBackupIndex)
  
  If nFMBackupIndex >= 0
    nNetworkControlPtr = gaFMBackup(nFMBackupIndex)\nNetworkControlPtr
    If gsCueFile
      If nNetworkControlPtr >= 0
        With grOSCMsgData
          \bOSCTextMsg = #False
          \bAddLF = #False
          ; send "/file/open ,s filename" or "/file/open ,ss filename cue"
          \sOSCAddress = "/file/open"
          \nTagCount = 1
          \sTagString = "s"
          \aTagData(0)\sString = GetFilePart(gsCueFile)
          If (gnCueToGo > 0) And (gnCueToGo < gnCueEnd)
            \nTagCount + 1
            \sTagString + "s"
            \aTagData(1)\sString = aCue(gnCueToGo)\sCue
          EndIf
          sendOSCComplexMessage(nNetworkControlPtr)
        EndWith
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure FMP_sendCommandIfReqd(nOSCINP_Command, nCuePtr=0, nParam2=0, nParam3=0, sParam4.s="", bHideTracing=#False)
  PROCNAMEC()
  Protected nFMBackupIndex, nNetworkControlPtr
  Protected nSubPtr, nAudPtr, sTags.s
  
  If gnLastFMBackup >= 0
    debugMsgN(sProcName, #SCS_START + ", nOSCINP_Command=" + decodeRemCmd(nOSCINP_Command) + ", gnLastFMBackup=" + gnLastFMBackup + ", bHideTracing=" + strB(bHideTracing))
  EndIf
  
  For nFMBackupIndex = 0 To gnLastFMBackup
    If gaFMBackup(nFMBackupIndex)\nBackupId > 0
      nNetworkControlPtr = gaFMBackup(nFMBackupIndex)\nNetworkControlPtr
      debugMsgN(sProcName, "gaFMBackup(" + nFMBackupIndex + ")\nNetworkControlPtr=" + gaFMBackup(nFMBackupIndex)\nNetworkControlPtr)
      If nNetworkControlPtr >= 0
        With grOSCMsgData
          \bOSCTextMsg = #False
          \bAddLF = #False
          \sOSCAddress = ""
          \nTagCount = 0
          \sTagString = ""
          Select nOSCINP_Command
            Case #SCS_OSCINP_POLL
              \sOSCAddress = "/poll"
              
            Case #SCS_OSCINP_CUE_PLAY
              \sOSCAddress = "/cue/go"
              \nTagCount = 1
              \sTagString = "s"
              \aTagData(0)\sString = getCueLabel(nCuePtr)
              sTags = \sTagString + ", " + \aTagData(0)\sString
              
            Case #SCS_OSCINP_CUE_SET_POS
              \sOSCAddress = "/cue/setpos"
              \nTagCount = 2
              \sTagString = "si"
              \aTagData(0)\sString = getCueLabel(nCuePtr)
              nAudPtr = nParam2
              If aAud(nAudPtr)\nRelFilePos >= 0
                \aTagData(1)\nInteger = aAud(nAudPtr)\nRelFilePos
              Else
                \aTagData(1)\nInteger = aAud(nAudPtr)\nCuePos
              EndIf
              sTags = \sTagString + ", " + \aTagData(0)\sString + ", " + \aTagData(1)\nInteger
              
            Case #SCS_OSCINP_CTRL_GO
              \sOSCAddress = "/ctrl/go"
              
            Case #SCS_OSCINP_CTRL_GO_CONFIRM
              \sOSCAddress = "/ctrl/goconfirm"
              
            Case #SCS_OSCINP_CTRL_GO_BACK
              \sOSCAddress = "/ctrl/goback"
              
            Case #SCS_OSCINP_CTRL_GO_TO_CUE
              \sOSCAddress = "/ctrl/gotocue"
              \nTagCount = 1
              \sTagString = "s"
              \aTagData(0)\sString = getCueLabel(nCuePtr)
              sTags = \sTagString + ", " + \aTagData(0)\sString
              
            Case #SCS_OSCINP_CTRL_GO_TO_END
              \sOSCAddress = "/ctrl/gotoend"
              
            Case #SCS_OSCINP_CTRL_GO_TO_NEXT
              \sOSCAddress = "/ctrl/gotonext"
              
            Case #SCS_OSCINP_CTRL_GO_TO_TOP
              \sOSCAddress = "/ctrl/gotop"
              
            Case #SCS_OSCINP_CTRL_OPEN_NEXT_CUES
              \sOSCAddress = "/ctrl/opennextcues"
              
            Case #SCS_OSCINP_CTRL_PAUSE_RESUME_ALL
              \sOSCAddress = "/ctrl/pauseresumeall"
              
            Case #SCS_OSCINP_CTRL_STOP_ALL
              \sOSCAddress = "/ctrl/stopall"
              
            Case #SCS_OSCINP_CTRL_FADE_ALL
              \sOSCAddress = "/ctrl/fadeall"
              
            Case #SCS_OSCINP_CTRL_STOP_MTC
              \sOSCAddress = "/ctrl/stopmtc"
              
           Case #SCS_OSCINP_HKEY_GO ; Added 30Jun2023
              \sOSCAddress = "/hkey/go"
              \nTagCount = 1
              \sTagString = "s"
              \aTagData(0)\sString = sParam4
              sTags = \sTagString + ", " + \aTagData(0)\sString
              
            Case #SCS_OSCINP_HKEY_ON ; Added 30Jun2023
              \sOSCAddress = "/hkey/on"
              \nTagCount = 1
              \sTagString = "s"
              \aTagData(0)\sString = sParam4
              sTags = \sTagString + ", " + \aTagData(0)\sString
              
            Case #SCS_OSCINP_HKEY_OFF ; Added 30Jun2023
              \sOSCAddress = "/hkey/off"
              \nTagCount = 1
              \sTagString = "s"
              \aTagData(0)\sString = sParam4
              sTags = \sTagString + ", " + \aTagData(0)\sString
              
             Case #SCS_OSCINP_PNL_BTN_CLICK
              \sOSCAddress = "/pnlbtn"
              \nTagCount = 4
              \sTagString = "ssii"
              \aTagData(0)\sString = sParam4  ; the button that was clicked, eg "play"
              \aTagData(1)\sString = getCueLabel(gaDispPanel(nParam2)\nDPCuePtr)
              nSubPtr = gaDispPanel(nParam2)\nDPSubPtr
              If nSubPtr >= 0
                \aTagData(2)\nInteger = aSub(nSubPtr)\nSubNo
              Else
                \aTagData(2)\nInteger = -1
              EndIf
              nAudPtr = gaDispPanel(nParam2)\nDPAudPtr
              If nAudPtr >= 0
                \aTagData(3)\nInteger = aAud(nAudPtr)\nAudNo
              Else
                \aTagData(3)\nInteger = -1
              EndIf
              sTags = \sTagString + ", " + \aTagData(0)\sString + ", " + \aTagData(1)\sString + ", " + \aTagData(2)\nInteger + ", " + \aTagData(3)\nInteger
              
            Case #SCS_OSCINP_SET_PLAYORDER
              \sOSCAddress = "/ctrl/setplayorder"
              \nTagCount = 4
              \sTagString = "sisi"
              \aTagData(0)\sString = getCueLabel(nCuePtr)
              \aTagData(1)\nInteger = nParam2 ; nSubNo
              \aTagData(2)\sString = sParam4  ; the playorder
              \aTagData(3)\nInteger = nParam3 ; nAudNo of nFirstPlayIndexThisRun
              sTags = \sTagString + ", " + \aTagData(0)\sString + ", " + \aTagData(1)\nInteger + \aTagData(2)\sString + \aTagData(3)\nInteger
              
          EndSelect
          If \sOSCAddress
            gnFMUniqueMsgId + 1
            \aTagData(\nTagCount)\sString = Str(gnFMUniqueMsgId)
            \sTagString + "s"
            \nTagCount + 1
            debugMsgN(sProcName, "calling sendOSCComplexMessage(" + nNetworkControlPtr + ") for \sOSCAddress=" + #DQUOTE$ + \sOSCAddress + #DQUOTE$ + ", " + sTags + ", UniqueId=" + gnFMUniqueMsgId)
            sendOSCComplexMessage(nNetworkControlPtr, bHideTracing)
          EndIf
        EndWith
      EndIf
    EndIf
  Next nFMBackupIndex
  
  If gnLastFMBackup >= 0
    debugMsgN(sProcName, #SCS_END)
  EndIf
  
EndProcedure

Procedure FMP_BackupDisconnectionRequest()
  PROCNAMEC()
  Protected n, nFMBackupIndex = -1
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To gnLastFMBackup
    If gaFMBackup(n)\nBackupId = gnEventClient
      nFMBackupIndex = n
      Break
    EndIf
  Next n
  With gaFMBackup(nFMBackupIndex)
    \nBackupId = 0  ; free this entry
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning nFMBackupIndex=" + nFMBackupIndex)
  ProcedureReturn nFMBackupIndex
  
EndProcedure

; INFO FMB Procedures (Functional Mode Backup)

Procedure FMB_ServerConnectionRequest()
  PROCNAMEC()
  Protected nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nNetworkControlPtr = getNetworkControlPtrForServerAndClientConnection(0, grFMOptions\nFMClientId)
  If nNetworkControlPtr < 0
    debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
    nNetworkControlPtr = getBlankNetworkControlEntry()
  EndIf
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      \nDevType = #SCS_DEVTYPE_CC_NETWORK_IN ; Added 16Aug2021 11.8.5.1aa
      \bControlExists = #True ; Added 17Aug2021 11.8.5.1aa
      \nServerConnection = 0
      \nClientConnection = grFMOptions\nFMClientId
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nServerConnection=" + \nServerConnection + ", \nClientConnection=" + decodeHandle(\nClientConnection))
    EndWith
    gnNetworkClientsActive + 1
    debugMsg(sProcName, "gnNetworkClientsActive=" + gnNetworkClientsActive)
  EndIf
  
  ProcedureReturn nNetworkControlPtr
  debugMsg(sProcName, #SCS_END + ", returning nNetworkControlPtr=" + nNetworkControlPtr)
  
EndProcedure

Procedure FMB_openCueFile(sFilename.s, sCue.s)
  PROCNAMEC()
  Protected sFilePart.s, sFullFileName.s
  Protected n, nCuePtr
  
  debugMsg(sProcName, #SCS_START + ", sFilename=" + #DQUOTE$ + sFilename + #DQUOTE$ + ", sCue=" + #DQUOTE$ + sCue + #DQUOTE$)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_FMB_FILE_OPEN, 0, 0, 0, sFilename, 0, 0, -1, #True, #False, 0, 0, sCue)
    ProcedureReturn
  EndIf
  
  ; find this file based on the filepart
  sFilePart = GetFilePart(sFilename)
  debugMsg(sProcName, "sFilePart=" + #DQUOTE$ + sFilePart + #DQUOTE$)
  
  ; check if this file is in the 'recent file list'
  For n = 0 To (gnRecentFileCount - 1)
    If GetFilePart(gsRecentFile(n)) = sFilePart
      If FileExists(gsRecentFile(n), #False)
        sFullFileName = gsRecentFile(n)
        debugMsg(sProcName, "found in gsRecentFile(" + n + "), sFullFileName=" + #DQUOTE$ + sFullFileName + #DQUOTE$)
        Break
      EndIf
    EndIf
  Next n
  
  If Len(sFullFileName) = 0
    ; not found in the 'recent file list', so now check 'favorite files'
    For n = 0 To (gnFavFileCount - 1)
      If GetFilePart(gaFavoriteFiles(n)\sFileName) = sFilePart
        If FileExists(gaFavoriteFiles(n)\sFileName, #False)
          sFullFileName = gaFavoriteFiles(n)\sFileName
          debugMsg(sProcName, "found in gaFavoriteFiles(" + n + "), sFullFileName=" + #DQUOTE$ + sFullFileName + #DQUOTE$)
          Break
        EndIf
      EndIf
    Next n
  EndIf
  
  If Len(sFullFileName) = 0
    ; not found in the 'favorite files', so now look for file in the 'initial folder'
    If grGeneralOptions\sInitDir
      If FileSize(grGeneralOptions\sInitDir) = -2
        ; initial folder exists
        If FileExists(grGeneralOptions\sInitDir + sFilePart, #False)
          sFullFileName = grGeneralOptions\sInitDir + sFilePart
          debugMsg(sProcName, "found in 'initial folder', sFullFileName=" + #DQUOTE$ + sFullFileName + #DQUOTE$)
        EndIf
      EndIf
    EndIf
  EndIf
  
  If sFullFileName
    If IsWindow(#WLP)
      debugMsg(sProcName, "calling WLP_FMOpenCueFile(" + #DQUOTE$ + sFullFileName + #DQUOTE$ + ")")
      WLP_FMOpenCueFile(sFullFileName)
    Else
      gsCueFile = sFullFileName
      gsCueFolder = GetPathPart(gsCueFile)
      gbUnsavedRecovery = #False
      gnUnsavedEditorGraphs = 0
      gsUnsavedEditorGraphs = ""
      gnUnsavedSliderGraphs = 0
      gbUnsavedVideoImageData = #False
      gbUnsavedPlaylistOrderInfo = #False
      gbImportedCues = #False
      gbNewCueFile = #False
      debugMsg(sProcName, "calling loadCueFile()")
      loadCueFile()
      If sCue
        nCuePtr = getCuePtr(sCue)
        If nCuePtr >= 0
          debugMsg(sProcName, "calling GoToCue(" + getCueLabel(nCuePtr) + ")")
          GoToCue(nCuePtr)
        EndIf
      EndIf
    EndIf
    
  Else
    ; sFullFileName is still blank, which means we didn't find the file in 'recent files', 'favorites', or the 'initial folder'
    scsMessageRequester(#SCS_TITLE, LangPars("Network", "CannotFindCueFile", #DQUOTE$ + sFilePart + #DQUOTE$), #PB_MessageRequester_Warning)
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure FMB_setPlayOrder(nNetworkControlPtr)
  PROCNAMEC()
  Protected sCue.s, nSubNo, nAudNo, sPlayOrder.s
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      ; info passed through from primary
      sCue = \sOSCString(0)
      nSubNo = \nOSCLong(0)
      nAudNo = \nOSCLong(1)
      sPlayOrder = \sOSCString(1)
      debugMsg(sProcName, "sCue=" + sCue + ", nSubNo=" + nSubNo + ", sPlayOrder=" + #DQUOTE$ + sPlayOrder + #DQUOTE$ + ", nAudNo=" + nAudNo)
      ; nSubNo in \p1Long
      ; nAudNo in \p3Long (nAudNo of \nFirstPlayIndexThisRun)
      ; sCue in \p4String
      ; sPlayOrder in \p8String
      samAddRequest(#SCS_SAM_SET_PLAYORDER, nSubNo, 0, nAudNo, sCue, 0, 0, -1, #True, #False, 0, 0, sPlayOrder)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure encodeFunctionalMode(sFunctionalMode.s)
  Protected nFunctionalMode
  
  Select UCase(sFunctionalMode)
    Case "P"
      nFunctionalMode = #SCS_FM_PRIMARY
    Case "B"
      nFunctionalMode = #SCS_FM_BACKUP
    Default
      nFunctionalMode = #SCS_FM_STAND_ALONE
  EndSelect
  ProcedureReturn nFunctionalMode
EndProcedure

Procedure.s decodeFunctionalMode(nFunctionalMode)
  Protected sFunctionalMode.s
  
  Select nFunctionalMode
    Case #SCS_FM_PRIMARY
      sFunctionalMode = "P"
    Case #SCS_FM_BACKUP
      sFunctionalMode = "B"
    Default
      sFunctionalMode = "S"
  EndSelect
  ProcedureReturn sFunctionalMode
EndProcedure

Procedure.s decodeFunctionalModeL(nFunctionalMode)
  Protected sFunctionalMode.s
  
  Select nFunctionalMode
    Case #SCS_FM_PRIMARY
      sFunctionalMode = Lang("Common", "Primary")
    Case #SCS_FM_BACKUP
      sFunctionalMode = Lang("Common", "Backup")
    Default
      sFunctionalMode = Lang("Common", "Stand-Alone")
  EndSelect
  ProcedureReturn sFunctionalMode
EndProcedure

Procedure splitNetworkMsg(sNetworkMsg.s)
  PROCNAMEC()
  Protected nMsgCount
  Protected sMsgWork.s
  
  sMsgWork = Trim(sNetworkMsg)
  
EndProcedure

Procedure looksLikeIPAddress(sValue.s)
  PROCNAMEC()
  Protected bLooksLikeIPAddress
  Protected sMyValue.s
  Protected n
  
  sMyValue = Trim(sValue)
  If sMyValue
    bLooksLikeIPAddress = #True
    For n = 1 To Len(sMyValue)
      Select Mid(sMyValue,n,1)
        Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."
          ; acceptable
        Default
          ; not acceptable
          bLooksLikeIPAddress = #False
          Break
      EndSelect
    Next n
  EndIf
  
  ProcedureReturn bLooksLikeIPAddress
EndProcedure

Procedure validateIPAddressFormat(pField.s, pPrompt.s, bDisplayError=#True)
  PROCNAMEC()
  Protected sIPAddress.s, sMsg.s
  Protected nValidationFailPoint
  Protected n
  Protected sPart.s
  
  While #True
    sIPAddress = Trim(pField)
    If sIPAddress
      If CountString(sIPAddress,".") <> 3
        nValidationFailPoint = 1
        Break
      EndIf
      For n = 1 To 4
        sPart = StringField(sIPAddress,n,".")
        If IsInteger(sPart) = #False
          nValidationFailPoint = 2
          Break 2
        EndIf
        If Val(sPart) > 255
          nValidationFailPoint = 3
          Break 2
        EndIf
      Next n
    EndIf
    Break
  Wend
  
  If nValidationFailPoint = 0
    ProcedureReturn #True
  Else
    If bDisplayError
      ensureSplashNotOnTop()
      sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + Lang("Errors", "NotValidForIP")
      debugMsg(sProcName, sMsg)
      debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    EndIf
    ProcedureReturn #False
  EndIf

EndProcedure

Procedure validateIPPortNumber(pField.s, pPrompt.s)
  PROCNAMEC()
  Protected sPortNumber.s, nPortNumber, sMsg.s
  Protected nValidationFailPoint
  
  sPortNumber = Trim(pField)
  If IsInteger(sPortNumber) = #False
    nValidationFailPoint = 1
  Else
    nPortNumber = Val(sPortNumber)
    If nPortNumber < 1 Or nPortNumber > 65535
      nValidationFailPoint = 2
    EndIf
  EndIf
  
  If nValidationFailPoint = 0
    ProcedureReturn #True
  Else
    ensureSplashNotOnTop()
    sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + Lang("Errors", "NotValidForPort")
    debugMsg(sProcName, sMsg)
    debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf

EndProcedure

Procedure makeIPAddressFromString(sIPAddress.s)
  PROCNAMEC()
  Protected Dim nField(3)
  Protected n
  Protected sTmp.s
  
  If Len(sIPAddress) = 0
    ProcedureReturn MakeIPAddress(0,0,0,0)
  Else
    For n = 0 To 3
      sTmp = StringField(sIPAddress, n+1, ".")
      If IsInteger(sTmp)
        nField(n) = Val(sTmp)
        If nField(n) > 255
          nField(n) = 0
        EndIf
      EndIf
    Next n
    ProcedureReturn MakeIPAddress(nField(0), nField(1), nField(2), nField(3))
  EndIf
EndProcedure

Procedure SendNetworkStringAscii(nConnection, sString.s, bTrace=#False, nStringFormat=#PB_Ascii)
  ; original procedure supplied by Trond in PB Forum topic: "How do I send ASCII string with SendNetworkString?"
  ; optimized 2Sep2016 11.5.2 to minimize calls to AllocateMemory()
  ; nb PB generates code to free allocated memory on closing the program, so it doesn't matter that we do not call FreeMemory()
  ; the old version of this procedure did need to call FreeMemory() because it was re-allocating memory in every call
  
  ; nStringFormat added 14Apr2020 11.8.2.3ar following forum postings from bgaudio re CasparCG, which requires messages in UTF8 format
  
  PROCNAMEC()
  Protected nBufferLen = Len(sString) + 1
  Protected nBytesSent, bLockedMutex
  Static *buffer
  Protected *newbuffer
  
  debugMsgC(sProcName, #SCS_START + ", nConnection=" + decodeHandle(nConnection) + ", Len(sString)=" + Len(sString))
  
  scsLockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND, 801)
  
  If *buffer = 0
    debugMsg(sProcName, "calling AllocateMemory(" + Str(nBufferLen << 1) + ")")
    *buffer = AllocateMemory(nBufferLen << 1)
  ElseIf MemorySize(*buffer) < (nBufferLen << 1)
    debugMsg(sProcName, "calling ReAllocateMemory(*buffer, " + Str(nBufferLen << 1) + ")")
    *newbuffer = ReAllocateMemory(*buffer, nBufferLen << 1)
    If *newbuffer
      *buffer = *newbuffer
    EndIf
  EndIf
  
  If *buffer
    If nBufferLen > 1
      If nConnection
        ; debugMsg(sProcName, "nConnection=" + nConnection + ", sString=" + sString + ", nBufferLen=" + Str(nBufferLen))
        ; PokeS(*buffer, sString, -1, #PB_Ascii)
        ; PokeS(*buffer, sString, nBufferLen-1, #PB_Ascii) ; changed 'Length' from -1 to BufferLen-1   (MJD 2012/04/07)
        PokeS(*buffer, sString, nBufferLen-1, nStringFormat) ; modified 14Apr2020 11.8.2.3ar (see comment about nStringFormat near top of this procedure)
        nBytesSent = SendNetworkData(nConnection, *buffer, nBufferLen-1)
        If bTrace
          debugMsg2(sProcName, "SendNetworkData(" + decodeHandle(nConnection) + ", *buffer, " + Str(nBufferLen-1) + ")", nBytesSent)
          debugMsg(sProcName, "nBytesSent=" + nBytesSent + ", sString=" + stringToNetworkString(sString) + ", nStringFormat=" + nStringFormat)
        EndIf
      EndIf
    EndIf
  EndIf
  
  scsUnlockMutex(gnNetworkSendMutex, #SCS_MUTEX_NETWORK_SEND)
  
EndProcedure

Procedure.s sendNetworkDataMessage(nNetworkControlPtr, pSubPtr, nCtrlSendIndex, bIgnoreReadyState=#False)
  ; Procedure added 24Nov2020 11.8.3.3an
  PROCNAMECS(pSubPtr)
  Protected sMyConnection.s
  Protected nMode, sMode.s, sMsgSuffix.s
  Protected nBytesSent
  Protected sNoSpaces.s, nReqdMemorySize, nBufferLen
  Static *buffer
  
  debugMsg(sProcName, #SCS_START + ", nNetworkControlPtr=" + nNetworkControlPtr + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
      If \nEntryMode = #SCS_ENTRYMODE_HEX
        ; Hex mode
        sNoSpaces = ReplaceString(\sEnteredString, " ", "")     ; remove all spaces from entered string
        nReqdMemorySize = (Len(sNoSpaces) / 2) + 2
        If *buffer = 0
          *buffer = AllocateMemory(nReqdMemorySize)
        ElseIf nReqdMemorySize > MemorySize(*buffer)
          *buffer = ReAllocateMemory(*buffer, nReqdMemorySize, #PB_Memory_NoClear)
        EndIf
        nBufferLen = hexStringToBuffer(sNoSpaces, *buffer, nReqdMemorySize)
        If \bAddCR
          PokeB(*buffer+nBufferLen, $0D)
          nBufferLen + 1
        EndIf
        If \bAddLF
          PokeB(*buffer+nBufferLen, $0A)
          nBufferLen + 1
        EndIf
      EndIf
    EndWith
  EndIf
  
  With gaNetworkControl(nNetworkControlPtr)
    If \bNWDummy
      sMyConnection = \sNetworkDevDesc
      
    ElseIf \bNWIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
      sMyConnection = \sNetworkDevDesc
      
    Else
      debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
      Select \nNetworkRole
        Case #SCS_ROLE_DUMMY
          sMyConnection = \sNetworkDevDesc
          
        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
          debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection) + ", \bClientConnectionLive=" + strB(\bClientConnectionLive))
          If (\nClientConnection) Or (\bClientConnectionLive = #False)
            If \bClientConnectionLive = #False
              If \nClientConnection
                CloseNetworkConnection(\nClientConnection)
                debugMsg(sProcName, "CloseNetworkConnection(" + decodeHandle(\nClientConnection) + ")")
                freeHandle(\nClientConnection)
                \nClientConnection = 0
                debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nClientConnection=" + decodeHandle(\nClientConnection))
              EndIf
              \bNetworkDevInitialized = #False
              debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
              If \nNetworkProtocol = #SCS_NETWORK_PR_UDP
                nMode = #PB_Network_UDP
                sMode = "#PB_Network_UDP"
              Else
                nMode = #PB_Network_TCP
                sMode = "#PB_Network_TCP"
              EndIf
              debugMsg(sProcName, "calling OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", " + sMode +", " + \nOpenConnectionTimeout + ")")
              \nClientConnection = OpenNetworkConnection(\sRemoteHost, \nRemotePort, nMode, \nOpenConnectionTimeout)
              If \nClientConnection
                newHandle(#SCS_HANDLE_NETWORK_CLIENT, \nClientConnection)
                debugMsg(sProcName, "OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", " + sMode +", " + \nOpenConnectionTimeout + ") returned " + \nClientConnection + " (" + decodeHandle(\nClientConnection) + ")")
                \bNetworkDevInitialized = #True
                debugMsg(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
                \bClientConnectionLive = #True
                If \bClientConnectionNeedsReady
                  \bClientConnectionReady = #False
                Else
                  \bClientConnectionReady = #True
                EndIf
              Else
                debugMsg2(sProcName, "OpenNetworkConnection(" + \sRemoteHost + ", " + \nRemotePort + ", " + sMode +", " + \nOpenConnectionTimeout + ")", \nClientConnection)
              EndIf
            EndIf
            debugMsg(sProcName, "\bClientConnectionLive=" + strB(\bClientConnectionLive) + ", \bClientConnectionReady=" + strB(\bClientConnectionReady) + ", bIgnoreReadyState=" + strB(bIgnoreReadyState))
            If \bClientConnectionLive
              If (\bClientConnectionReady) Or (bIgnoreReadyState)
                If nBufferLen > 0
                  nBytesSent = formatAndSendNetworkData(\nClientConnection, *buffer, nBufferLen, nNetworkControlPtr)
                  debugMsg2(sProcName, "formatAndSendNetworkData(" + decodeHandle(\nClientConnection) + ", *buffer, " + nBufferLen + ", " + nNetworkControlPtr + ")", nBytesSent)
                  sMyConnection = \sRemoteHost + ":" + \nRemotePort
                EndIf
              Else
                If \nCountSendWhenReady > ArraySize(\aSendWhenReady())
                  REDIM_ARRAY(\aSendWhenReady, \nCountSendWhenReady, grSendWhenReadyDef, "\aSendWhenReady()")
                EndIf
                \aSendWhenReady(\nCountSendWhenReady)\nSWRSubPtr = pSubPtr
                \aSendWhenReady(\nCountSendWhenReady)\nSWRCtrlSendIndex = nCtrlSendIndex
                debugMsg(sProcName, "\aSendWhenReady(" + \nCountSendWhenReady + ")\nSWRSubPtr=" + getSubLabel(\aSendWhenReady(\nCountSendWhenReady)\nSWRSubPtr) +
                                    ", \nSWRCtrlSendIndex=" + \aSendWhenReady(\nCountSendWhenReady)\nSWRCtrlSendIndex)
                \nCountSendWhenReady + 1
                sMyConnection = \sRemoteHost + ":" + \nRemotePort
              EndIf
            Else
            EndIf
          EndIf
          
        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
          debugMsg(sProcName, "\nServerConnection=" + decodeHandle(\nServerConnection) + ", \nClientConnection=" + decodeHandle(\nClientConnection) + ", \sClientIP=" + \sClientIP + ", \nClientPort=" + \nClientPort)
          If \nServerConnection
            If \nClientConnection
              If nBufferLen > 0
                nBytesSent = formatAndSendNetworkData(\nClientConnection, *buffer, nBufferLen, nNetworkControlPtr)
                debugMsg2(sProcName, "formatAndSendNetworkData(" + decodeHandle(\nClientConnection) + ", *buffer, " + nBufferLen + ", " + nNetworkControlPtr + ")", nBytesSent)
                sMyConnection = \sClientIP + ":" + \nClientPort
              EndIf
            EndIf
          EndIf
          
      EndSelect
    EndIf
  EndWith

  debugMsg(sProcName, #SCS_END + ", returning " + sMyConnection)
  ProcedureReturn sMyConnection

EndProcedure

Procedure openNetworkConnectionIfReqd(*rCtrlSend.tyCtrlSend, bTrace=#True)
  PROCNAMEC()
  Protected n, nNetworkControlPtr, bInitResult
  
  debugMsgC(sProcName, #SCS_START)
  
  nNetworkControlPtr = -1
  For n = 0 To gnMaxNetworkControl
    If gaNetworkControl(n)\sLogicalDev = *rCtrlSend\sCSLogicalDev
      nNetworkControlPtr = n
      Break
    EndIf
  Next n
  ; debugMsg0(sProcName, "*rCtrlSend\sCSLogicalDev=" + *rCtrlSend\sCSLogicalDev + ", nNetworkControlPtr=" + nNetworkControlPtr)
  If nNetworkControlPtr >= 0
    With gaNetworkControl(nNetworkControlPtr)
      If \bNetworkDevInitialized = #False
        debugMsgC(sProcName, "calling openNetworkPortIfReqd(" + nNetworkControlPtr + ", #False, -1, " + strB(bTrace) + ")")
        bInitResult = openNetworkPortIfReqd(nNetworkControlPtr, #False, -1, bTrace)
        If bInitResult = #False Or bTrace
          debugMsg(sProcName, "openNetworkPortIfReqd(" + nNetworkControlPtr + ") returned " + strB(bInitResult))
        EndIf
        If bInitResult
          Select \nNetworkRole
            Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
              If \nClientConnection
                \bNetworkDevInitialized = #True
                debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
              EndIf
            Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
              If \nServerConnection
                \bNetworkDevInitialized = #True
                debugMsgC(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\bNetworkDevInitialized=" + strB(\bNetworkDevInitialized))
              EndIf
          EndSelect
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure populateOSCMessageDataIfReqd(nNetworkControlPtr)
  PROCNAMEC()
  ; NB nNetworkControlPtr is not necessarily the OSC APP's nNetworkControlPtr,
  ; eg for SCSRemote it is grRAI\nNetworkControlPtr2 but for OSC App it is grRAI\nNetworkControlPtr1
  Protected nMaxTagIndex, nTagIndex, nStringIndex, nLongindex, nFloatIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  If RAI_IsClientActive()
    If grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC
      With gaNetworkControl(nNetworkControlPtr)
        \nOSCVersion = grRAIOptions\nRAIOSCVersion
        \bOSCTextMsg = #False
        \bAddLF = #False
        grOSCMsgData = grOSCMsgDataDef
        grOSCMsgData\sOSCAddress = \sOSCPath
        grOSCMsgData\sTagString = \sOSCTagTypes
        grOSCMsgData\nTagCount = Len(\sOSCTagTypes)
        nMaxTagIndex = grOSCMsgData\nTagCount - 1
        If ArraySize(grOSCMsgData\aTagData()) < nMaxTagIndex
          ReDim grOSCMsgData\aTagData(nMaxTagIndex)
        EndIf
        For nTagIndex = 0 To nMaxTagIndex
          Select LCase(Mid(\sOSCTagTypes, (nTagIndex + 1), 1))
            Case "s"
              grOSCMsgData\aTagData(nTagIndex)\sString = \sOSCString(nStringIndex)
              nStringIndex + 1
            Case "i"
              grOSCMsgData\aTagData(nTagIndex)\nInteger = \nOSCLong(nLongindex)
              nLongindex + 1
            Case "f"
              grOSCMsgData\aTagData(nTagIndex)\fFloat= \fOSCFloat(nFloatIndex)
              nFloatIndex + 1
          EndSelect
        Next nTagIndex
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure getNetworkControlPtrForRAI(bIgnoreClientActiveState=#False)
  PROCNAMEC()
  Protected nNetworkControlPtr=-1
  
  If grRAIOptions\bRAIEnabled
    If grRAI\bRAIClientActive Or bIgnoreClientActiveState
      Select grRAIOptions\nRAIApp
        Case #SCS_RAI_APP_SCSREMOTE
          If grRAI\nClientConnection2 >= 0
            nNetworkControlPtr = grRAI\nNetworkControlPtr2
          EndIf
        Case #SCS_RAI_APP_OSC
          If grRAI\nClientConnection1 >= 0
            nNetworkControlPtr = grRAI\nNetworkControlPtr1
          EndIf
      EndSelect
    EndIf
  EndIf
  
  ProcedureReturn nNetworkControlPtr
  
EndProcedure

Procedure formatAndSendNetworkData(nClientID, *mBuffer, nSize, nNetworkControlPtr)
  PROCNAMEC()
  Static *mNetworkSendOSCBuffer
  Protected nReadPtr, nWritePtr, nBytesSent
  Protected aByte.a, nLength.l, nLengthEndian.l, bSendAsIs
  Protected bHideTracing = #True
  
  debugMsgN(sProcName, #SCS_START + ", nClientID=" + decodeHandle(nClientID) + ", nSize=" + nSize + ", nNetworkControlPtr=" + nNetworkControlPtr)
  
  With gaNetworkControl(nNetworkControlPtr)
    ; debugMsg0(sProcName, "gaNetworkControl(" + nNetworkControlPtr + ")\nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nOSCVersion=" + decodeOSCVersion(\nOSCVersion))
    If \bRAIDev And grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE
      bSendAsIs = #True
      
    ElseIf \bSCSBackupDev
      ; Functional Mode 'Primary' computer sending to the 'Backup' computer
      bSendAsIs= #True
      
    ElseIf \nNetworkProtocol <> #SCS_NETWORK_PR_TCP Or \nOSCVersion < 0
      ; OSC message formatting handled by this procedure is only required for TCP, and should not therefore be applied to UDP messages
      ; \nOSCVersion < 0 means this is not an OSC message
      bSendAsIs = #True
      
    Else
      ; Send a properly formatted OSC 1.0 or OSC 1.1 message
      If *mNetworkSendOSCBuffer = 0
        *mNetworkSendOSCBuffer = AllocateMemory(#SCS_MEM_SIZE_NETWORK_BUFFERS)
      EndIf
      
      Select \nOSCVersion
        Case #SCS_OSC_VER_1_0
          If PeekA(*mBuffer+3) = 0 And PeekA(*mBuffer+2) = 0
            ; Assume already formatted for OSC 1.0 because it looks like the first 4 bytes contain an int32 value,
            ; which is the requirement for the start of an OSC 1.0 packet under TCP
            bSendAsIs = #True
            debugMsg(sProcName, "bSendAsIs=" + strB(bSendAsIs))
          Else
            nLength = nSize ; nb nLength is a 4-byte long
            nLengthEndian = xchEndianL(nLength) ; nLengthEndian is also a 4-byte long
            ; debugMsg(sProcName, "nLength=" + nLength + ", nLengthEndian=$" + Hex(nLength, #PB_Long))
            PokeL(*mNetworkSendOSCBuffer, nLengthEndian)
            nWritePtr + 4
            CopyMemory(*mBuffer, *mNetworkSendOSCBuffer+nWritePtr, nSize)
            nWritePtr + nSize
          EndIf
          
        Case #SCS_OSC_VER_1_1
          If PeekA(*mBuffer) = $C0
            ; Assume already formatted for OSC 1.1
            bSendAsIs = #True
          Else
            PokeA(*mNetworkSendOSCBuffer+nWritePtr, $C0)
            nWritePtr + 1
            For nReadPtr = 0 To (nSize-1)
              aByte = PeekA(*mBuffer+nReadPtr)
              If aByte = $C0
                PokeA(*mNetworkSendOSCBuffer+nWritePtr, $DB)
                nWritePtr + 1
                PokeA(*mNetworkSendOSCBuffer+nWritePtr, $DC)
                nWritePtr + 1
              ElseIf aByte = $DB
                PokeA(*mNetworkSendOSCBuffer+nWritePtr, $DB)
                nWritePtr + 1
                PokeA(*mNetworkSendOSCBuffer+nWritePtr, $DD)
                nWritePtr + 1
              Else
                PokeA(*mNetworkSendOSCBuffer+nWritePtr, aByte)
                nWritePtr + 1
              EndIf
            Next nReadPtr
            PokeA(*mNetworkSendOSCBuffer+nWritePtr, $C0)
            nWritePtr + 1
          EndIf
          
      EndSelect
      
      If nWritePtr > 0
        debugMsgN(sProcName, "(OSC) sending " + nWritePtr + " bytes, HEX: " + bufferToHexString(*mNetworkSendOSCBuffer, nWritePtr, " "))
        nBytesSent = SendNetworkData(nClientID, *mNetworkSendOSCBuffer, nWritePtr)
        debugMsgN(sProcName, "SendNetworkData(" + decodeHandle(nClientID) + ", *mNetworkSendOSCBuffer, " + nWritePtr + ") returned nBytesSent=" + nBytesSent)
      EndIf
      
    EndIf ; EndIf nOSCVersion < 0 / Else
  EndWith
  
  If bSendAsIs
    debugMsgN(sProcName, "sending " + nSize + " bytes, HEX: " + bufferToHexString(*mBuffer, nSize, " "))
    nBytesSent = SendNetworkData(nClientID, *mBuffer, nSize)
    debugMsgN(sProcName, "SendNetworkData(" + decodeHandle(nClientID) + ", *mBuffer, " + nSize + ") returned nBytesSent=" + nBytesSent)
  EndIf
  
  debugMsgN(sProcName, #SCS_END + ", returning " + nBytesSent)
  ProcedureReturn nBytesSent
EndProcedure

; EOF