; File: fmEditQM.pbi

EnableExplicit

Procedure WQM_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n, nRowCount
  Protected nAudPtr, nMsgType
  Protected nFirstDevType = #SCS_DEVTYPE_NONE

  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQMCreated = #False
    WQM_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQM\lblSubCueType, pSubPtr)
  
  WQM_populateCboLogicalDev()
  ; WQM_populateCtrlSendComboBoxes()
  
  SGT(WQM\lblEditMidiInfo[0], "")
  SGT(WQM\lblEditMidiInfo[1], "")
  gbEditMidiInfoDisplayedSet = #False
  
  For n = 0 To ArraySize(gbNewCtrlSendItem())
    gbNewCtrlSendItem(n) = #False
  Next n
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "M", WQM)
  EndWith
  
  grWQM\nSelectedCtrlSendRow = -2
  ; debugMsg(sProcName, "populating grdCtrlSends")
  ClearGadgetItems(WQM\grdCtrlSends)
  For n = 0 To #SCS_MAX_CTRL_SEND
    With aSub(pSubPtr)\aCtrlSend[n]
      ; debugMsg(sProcName, "calling AddGadgetItem(WQM\grdCtrlSends, -1, " + Str(n+1) + " + Chr(10) + " + #DQUOTE$ + \sDisplayInfo + #DQUOTE$ + ")")
      AddGadgetItem(WQM\grdCtrlSends, -1, Str(n+1) + Chr(10) + \sDisplayInfo)
      If Trim(\sCSLogicalDev)
        If nFirstDevType = #SCS_DEVTYPE_NONE
          nFirstDevType = \nDevType
        EndIf
        grEditMem\sLastCtrlSendLogicalDev = \sCSLogicalDev
        grEditMem\nLastCtrlSendDevType = \nDevType
        Select \nDevType
          Case #SCS_DEVTYPE_CS_HTTP_REQUEST
            grEditMem\sLastHTItemDesc = \sCSItemDesc
          Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
            nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
            If nMsgType <> #SCS_MSGTYPE_SCRIBBLE_STRIP
              If nMsgType <> #SCS_MSGTYPE_NONE And nMsgType < #SCS_MSGTYPE_DUMMY_LAST
                grEditMem\nLastMsgType = nMsgType
                ; debugMsg0(sProcName, "grEditMem\nLastMsgType=" + decodeMsgType(grEditMem\nLastMsgType))
                grEditMem\aLastMsg(nMsgType)\sLastMSItemDesc = \sCSItemDesc
                grEditMem\aLastMsg(nMsgType)\nLastMSChannel = \nMSChannel
                grEditMem\aLastMsg(nMsgType)\nLastMSParam1 = \nMSParam1
                grEditMem\aLastMsg(nMsgType)\nLastMSParam2 = \nMSParam2
                grEditMem\aLastMsg(nMsgType)\nLastMSParam3 = \nMSParam3
                grEditMem\aLastMsg(nMsgType)\nLastMSParam4 = \nMSParam4
                grEditMem\aLastMsg(nMsgType)\sLastMSParam1Info = \sMSParam1Info
                grEditMem\aLastMsg(nMsgType)\sLastMSParam2Info = \sMSParam2Info
                grEditMem\aLastMsg(nMsgType)\sLastMSParam3Info = \sMSParam3Info
                grEditMem\aLastMsg(nMsgType)\sLastMSParam4Info = \sMSParam4Info
                ; debugMsg(sProcName, "nMsgType=" + decodeMsgType(nMsgType) + ", \nMSParam3=" + \nMSParam3 + ", \sMSParam3Info=" + \sMSParam3Info)
              ElseIf nMsgType > #SCS_MSGTYPE_DUMMY_LAST
                grEditMem\nLastRemDevMsgType = nMsgType
                ; debugMsg0(sProcName, "grEditMem\nLastRemDevMsgType=" + decodeMsgType(grEditMem\nLastRemDevMsgType))
                If LCase(Left(\sRemDevMsgType,4)) = "mute"
                  grEditMem\nLastRemDevMuteAction = \nRemDevMuteAction
                EndIf
              EndIf
            EndIf
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            grEditMem\sLastNWItemDesc = \sCSItemDesc
          Case #SCS_DEVTYPE_CS_RS232_OUT
            grEditMem\sLastRSItemDesc = \sCSItemDesc
        EndSelect
        If \bIsOSC
          grEditMem\nLastOSCCmdType = \nOSCCmdType
        EndIf
      EndIf
    EndWith
  Next n
  
  debugMsg(sProcName, "calling WQM_populateCboCtrlMidiRemoteDev(" + decodeDevType(nFirstDevType) + ")")
  WQM_populateCboCtrlMidiRemoteDev(nFirstDevType)
  
  SetGadgetState(WQM\grdCtrlSends, 0)
  
  nAudPtr = aSub(pSubPtr)\nFirstAudIndex
  If nAudPtr >= 0
    aAud(nAudPtr)\bCheckProgSlider = #False
  EndIf
  
  WQM_setCtrlSendTestButtons()
  ; debugMsg(sProcName, "calling editSetDisplayButtonsM")
  editSetDisplayButtonsM()
  gbCallEditUpdateDisplay = #True

  debugMsg(sProcName, #SCS_END)

EndProcedure

Macro WQM_macSetMSParamComboBox(pComboBox, pStringParam, pNumParam)
  nCboDataValue = calcMSParamValueForCallableCueParam(@aCue(nEditCuePtr), pStringParam, pNumParam)
  setComboBoxByData(pComboBox, nCboDataValue)
EndMacro

Procedure WQM_displayCtrlSendItem(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected m, n, nListIndex, nMsgType
  Protected nCtrlNetworkRemoteDev, nCtrlMidiRemoteDev
  Protected nDMXOutPref, nCboDataValue
  Protected nRemDevId, sRemDevName.s
  Protected nWorkDevType

  debugMsg(sProcName, #SCS_START)

  gbInDisplayCtrlSendItem = #True
  
  SGT(WQM\lblEditMidiInfo[0], "")
  SGT(WQM\lblEditMidiInfo[1], "")
  
  n = GGS(WQM\grdCtrlSends)
  ; debugMsg(sProcName, "GGS(WQM\grdCtrlSends)=" + n)
  If n < 0
    gbInDisplayCtrlSendItem = #False
    ProcedureReturn
  EndIf
  
  grWQM\nSelectedCtrlSendRow = n
  
  With aSub(pSubPtr)\aCtrlSend[n]
    
    nDMXOutPref = #SCS_DMX_NOTATION_PERCENT

    nListIndex = indexForComboBoxRow(WQM\cboLogicalDev, \sCSLogicalDev, -1)
    SGS(WQM\cboLogicalDev, nListIndex)
    WQM_fcLogicalDev()
    
    nWorkDevType = \nDevType
    If nWorkDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork
      nWorkDevType = #SCS_DEVTYPE_CS_MIDI_OUT
    EndIf
    
    ; debugMsg0(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\aCtrlSend[" + n + "]\nDevType=" + decodeDevType(\nDevType) + ", nWorkDevType=" + decodeDevType(nWorkDevType))
    Select nWorkDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        ;{
        If grLicInfo\bCSRDAvailable
          loadCurrScribbleStrip(nEditCuePtr, aSub(pSubPtr)\nSubNo, n)
          nRemDevId = CSRD_GetRemDevIdForLogicalDev(#SCS_DEVTYPE_CS_MIDI_OUT, \sCSLogicalDev)
          setComboBoxByData(WQM\cboCtrlMidiRemoteDev, nRemDevId)
          WQM_fcCtrlMidiRemoteDev(#False)
        EndIf
        
        nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
        ; debugMsg(sProcName, "\nMSMsgType=" + decodeMsgType(\nMSMsgType) + ", \nRemDevMsgType=" + decodeMsgType(\nRemDevMsgType) + ", nMsgType=" + decodeMsgType(nMsgType))
        nListIndex = indexForComboBoxData(WQM\cboMsgType, nMsgType, -1)
        ; debugMsg0(sProcName, "calling SGS(WQM\cboMsgType, " + nListIndex + ")")
        SGS(WQM\cboMsgType, nListIndex)
        ; debugMsg(sProcName, "GGS(WQM\cboMsgType)=" + GGS(WQM\cboMsgType) + " " + GGT(WQM\cboMsgType))
        WQM_fcCboMsgType()
        
        SGT(WQM\txtMSItemDesc, \sCSItemDesc)
        
        Select nMsgType
          Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF
            WQM_macSetMSParamComboBox(WQM\cboMSParam1, \sMSParam1, \nMSParam1)
          Case #SCS_MSGTYPE_MSC
            SGS(WQM\cboMSParam1, \nMSParam1 + 1)
        EndSelect
        
        Select nMsgType
          Case #SCS_MSGTYPE_CC, #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF
            WQM_macSetMSParamComboBox(WQM\cboMSParam2, \sMSParam2, \nMSParam2)
          Case #SCS_MSGTYPE_MSC
            SGS(WQM\cboMSParam2, \nMSParam2 + 1)
        EndSelect
        
        Select nMsgType
          Case #SCS_MSGTYPE_NRPN_GEN
            debugMsg(sProcName, "\aCtrlSend[" + n + "]\nMSParam1=" + \nMSParam1 + ", \nMSParam2=" + \nMSParam2 + ", \nMSParam3=" + \nMSParam3 + ", \nMSParam4=" + \nMSParam4)
            WQM_macSetMSParamComboBox(WQM\cboMSParam1, \sMSParam1, \nMSParam1) ; NRPN MSB
            WQM_macSetMSParamComboBox(WQM\cboMSParam2, \sMSParam2, \nMSParam2) ; NRPN LSB
            WQM_macSetMSParamComboBox(WQM\cboMSParam3, \sMSParam3, \nMSParam3) ; Data MSB
            WQM_macSetMSParamComboBox(WQM\cboMSParam4, \sMSParam4, \nMSParam4) ; Data LSB (nb optional field in NRPN so may be 0)
            SGT(WQM\txtMSParam1Info, \sMSParam1Info)
            SGT(WQM\txtMSParam2Info, \sMSParam2Info)
            SGT(WQM\txtMSParam3Info, \sMSParam3Info)
            SGT(WQM\txtMSParam4Info, \sMSParam4Info)
            
          Case #SCS_MSGTYPE_NRPN_YAM
            ; NOTE: param1 and param2 reversed, as Yamaha have reversed the order of NRPN MSB and NRPN LSB
            debugMsg(sProcName, "\aCtrlSend[" + n + "]\nMSParam2=" + \nMSParam2 + ", \nMSParam1=" + \nMSParam1 + ", \nMSParam3=" + \nMSParam3 + ", \nMSParam4=" + \nMSParam4)
            WQM_macSetMSParamComboBox(WQM\cboMSParam1, \sMSParam2, \nMSParam2) ; NRPN LSB
            WQM_macSetMSParamComboBox(WQM\cboMSParam2, \sMSParam1, \nMSParam1) ; NRPN MSB
            WQM_macSetMSParamComboBox(WQM\cboMSParam3, \sMSParam3, \nMSParam3) ; Data MSB
            WQM_macSetMSParamComboBox(WQM\cboMSParam4, \sMSParam4, \nMSParam4) ; Data LSB (nb optional field in NRPN so may be 0)
            SGT(WQM\txtMSParam1Info, \sMSParam2Info)
            SGT(WQM\txtMSParam2Info, \sMSParam1Info)
            SGT(WQM\txtMSParam3Info, \sMSParam3Info)
            SGT(WQM\txtMSParam4Info, \sMSParam4Info)
            
        EndSelect
        
        WQM_fcCboMsCommand()
        
        SetGadgetState(WQM\cboMSChannel, \nMSChannel)
        
        Select nMsgType
          Case #SCS_MSGTYPE_MSC
            debugMsg(sProcName, "MSC: \nMSParam1=" + \nMSParam1 + ", \nMSParam2=" + \nMSParam2 + ", \sMSQNumber=" + \sMSQNumber + ", \sMSQList=" + \sMSQList)
            Select \nMSParam2
              Case $1, $2, $3, $5, $B, $10
                ; commands with q_number, q_list and q_path
                SGT(WQM\txtQNumber, \sMSQNumber)
                SGT(WQM\txtQList, \sMSQList)
                SGT(WQM\txtQPath, \sMSQPath)
                
              Case $6
                ; set command uses q_number and q_list for control number and control value
                SGT(WQM\txtQNumber, \sMSQNumber)
                SGT(WQM\txtQList, \sMSQList)
                
              Case $7
                ; command with macro number
                SetGadgetState(WQM\cboMSMacro, \nMSMacro + 1)
                
              Case $1B, $1C
                SGT(WQM\txtQList, \sMSQList)
                
              Case $1D, $1E
                SGT(WQM\txtQPath, \sMSQPath)
                
              Default
                ; no extra info or unsupported
                
            EndSelect
            
          Case #SCS_MSGTYPE_FREE
            gbCapturingFreeFormatMidi = #False
            If gnMidiCapturePhysicalDevPtr >= 0
              MidiIn_Port("close", gnMidiCapturePhysicalDevPtr, "midicapture")
            EndIf
            SGT(WQM\lblMidiCaptureDone, "")
            SGT(WQM\btnMidiCapture, Lang("WQM", "CaptureNext"))
            
          Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
            gbCapturingNRPN = #False
            If gnNRPNCapturePhysicalDevPtr >= 0
              MidiIn_Port("close", gnNRPNCapturePhysicalDevPtr, "nrpncapture")
            EndIf
            SGT(WQM\txtNRPNCapture, "")
            SGT(WQM\btnNRPNCapture, Lang("WQM", "btnNRPNCapture"))
            
          Case #SCS_MSGTYPE_FILE
            debugMsg(sProcName, "\aCtrlSend[" + n + "]\nAudPtr=" + getAudLabel(\nAudPtr))
            If \nAudPtr >= 0
              SGT(WQM\txtMidiFile, GetFilePart(aAud(\nAudPtr)\sFileName))
              SGT(WQM\txtFileDuration, timeToStringBWZ(aAud(\nAudPtr)\nFileDuration, aAud(\nAudPtr)\nFileDuration))
              SGT(WQM\txtCueDuration, timeToStringBWZ(aAud(\nAudPtr)\nCueDuration, aAud(\nAudPtr)\nFileDuration))
              SGT(WQM\txtStartAt, timeToStringBWZ(aAud(\nAudPtr)\nStartAt, aAud(\nAudPtr)\nFileDuration))
              SGT(WQM\txtEndAt, timeToStringBWZ(aAud(\nAudPtr)\nEndAt, aAud(\nAudPtr)\nFileDuration))
            EndIf
            
        EndSelect
        ;}
      Case #SCS_DEVTYPE_CS_RS232_OUT
        ;{
        SGT(WQM\txtRSItemDesc, \sCSItemDesc)
        nListIndex = indexForComboBoxData(WQM\cboRSEntryMode, \nEntryMode, 0)
        SGS(WQM\cboRSEntryMode, nListIndex)
        WQM_fcEntryMode()
        setOwnState(WQM\chkRSAddCR, \bAddCR)
        setOwnState(WQM\chkRSAddLF, \bAddLF)
        SGT(WQM\txtRSEnteredString, \sEnteredString)
        ;}
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        ;{
        SGT(WQM\txtNWItemDesc, \sCSItemDesc)
        If \nCSPhysicalDevPtr < 0
          \nCSPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, \sCSLogicalDev)
        EndIf
        nCtrlNetworkRemoteDev = getCtrlNetworkRemoteDevForPhysicalDevPtr(\nCSPhysicalDevPtr)
        ; debugMsg0(sProcName, "\nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr + ", nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev))
        setComboBoxByData(WQM\cboCtrlNetworkRemoteDev, nCtrlNetworkRemoteDev)
        WQM_fcCtrlNetworkRemoteDev(#False)
        ; debugMsg0(sProcName, "\bIsOSC=" + strB(\bIsOSC))
        If \bIsOSC
          nListIndex = setComboBoxByData(WQM\cboOSCCmdType, \nOSCCmdType)
          If nListIndex < 0
            \nOSCCmdType = grCtrlSendDef\nOSCCmdType
          EndIf
debugMsg0(sProcName, "calling WQM_fcOSCCmdType()")
          WQM_fcOSCCmdType()
          Select nCtrlNetworkRemoteDev
            Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
              setVisible(WQM\btnX32Capture, #True)
            Default
              setVisible(WQM\btnX32Capture, #False)
          EndSelect
          setVisible(WQM\cntOther, #False)
          setVisible(WQM\cntOSC, #True)
        Else
;           WQM_fcCtrlNetworkRemoteDev(#False)
          nListIndex = indexForComboBoxData(WQM\cboNWEntryMode, \nEntryMode, 0)
          SGS(WQM\cboNWEntryMode, nListIndex)
          WQM_fcEntryMode()
          setOwnState(WQM\chkNWAddCR, \bAddCR)
          setOwnState(WQM\chkNWAddLF, \bAddLF)
          SGT(WQM\txtNWEnteredString, \sEnteredString)
          setVisible(WQM\cntOSC, #False)
          setVisible(WQM\cntOther, #True)
        EndIf
        ;}
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        ;{
        SGT(WQM\txtHTItemDesc, \sCSItemDesc)
        SGT(WQM\txtHTEnteredString, \sEnteredString)
        ;}
    EndSelect
    
    buildCtrlSendMessage()
    
    If nMsgType = #SCS_MSGTYPE_NRPN_GEN
      SGT(WQM\btnNRPNSave, LangPars("WQM", "btnNRPNSave", Str(n+1)))
    EndIf
    
  EndWith
  
  gbInDisplayCtrlSendItem = #False

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WQM_resetSubDescrIfReqd()
  PROCNAMECS(nEditSubPtr)
  Protected sOldSubDescr.s
  Protected bCueChanged, bSubChanged
  Protected u2
  Protected sSendType.s
  Protected bIsOSC, bIsMIDI
  
debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
debugMsg(sProcName, "\bDefaultSubDescrMayBeSet=" + strB(\bDefaultSubDescrMayBeSet))
      If \bDefaultSubDescrMayBeSet
        sOldSubDescr = \sSubDescr
        If \aCtrlSend[0]\bMIDISend
          sSendType = "MIDI"
          bIsMIDI = #True
        ElseIf \aCtrlSend[0]\bRS232Send
          sSendType = "RS232"
        ElseIf \aCtrlSend[0]\bNetworkSend
          sSendType = "Network"
          bIsOSC = \aCtrlSend[0]\bIsOSC
        ElseIf \aCtrlSend[0]\bHTTPSend
          sSendType = "HTTP"
        EndIf
        If sSendType
debugMsg(sProcName, "(a) \sSubDescr=" + \sSubDescr)
          \sSubDescr = Lang("WQM", "dfltDescr" + sSendType)
debugMsg(sProcName, "(b) \sSubDescr=" + \sSubDescr)
          If (bIsOSC) Or (bIsMIDI And (\aCtrlSend[0]\nRemDevMsgType > #SCS_MSGTYPE_DUMMY_LAST Or \aCtrlSend[0]\nMSMsgType = #SCS_MSGTYPE_SCRIBBLE_STRIP))
            If \aCtrlSend[0]\sDisplayInfo
              \sSubDescr = \aCtrlSend[0]\sDisplayInfo
debugMsg(sProcName, "(c) \sSubDescr=" + \sSubDescr)
            EndIf
          EndIf
          If GGT(WQM\txtSubDescr) <> \sSubDescr
            SGT(WQM\txtSubDescr, \sSubDescr)
            setSubDescrToolTip(WQM\txtSubDescr)
            WED_setSubNodeText(nEditSubPtr)
            bSubChanged = #True
            If \nPrevSubIndex = -1
              If aCue(\nCueIndex)\sCueDescr = sOldSubDescr
                u2 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, GGT(WQM\lblMsgType))
                aCue(nEditCuePtr)\sCueDescr = \sSubDescr
                bCueChanged = #True
                If GGT(WEC\txtDescr) <> aCue(nEditCuePtr)\sCueDescr
                  SGT(WEC\txtDescr, aCue(nEditCuePtr)\sCueDescr)
                  WED_setCueNodeText(nEditCuePtr)
                  aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
                EndIf
                postChangeCueS(u2, aCue(nEditCuePtr)\sCueDescr)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      
      If bCueChanged
        loadGridRow(nEditCuePtr)
      EndIf
      
      If bSubChanged
        If \nPrevSubIndex >= 0 Or \nNextSubIndex >= 0
          ; multiple sub-cues
          WED_setCueNodeText(nEditCuePtr)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQM_fcCboMsCommand()
  PROCNAMECS(nEditSubPtr)
  Protected nCommand, m, n, sTmp.s
  Protected nLeft, nTop, nWidth, nHeight
  Protected sHexValue.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  n = GGS(WQM\grdCtrlSends)
  
  With WQM
    setVisible(\lblQNumber, #False)
    setVisible(\txtQNumber, #False)
    setVisible(\lblQList, #False)
    setVisible(\txtQList, #False)
    setVisible(\lblQPath, #False)
    setVisible(\txtQPath, #False)
    setVisible(\lblMSMacro, #False)
    setVisible(\cboMSMacro, #False)
    
    If aSub(nEditSubPtr)\aCtrlSend[n]\nMSMsgType <> #SCS_MSGTYPE_MSC
      ProcedureReturn
    EndIf
    
    ; NOTE: As checked above, the following code only applies to MSC (MIDI Show Control) messages
    
    ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + n + "]\nMSParam2=" + aSub(nEditSubPtr)\aCtrlSend[n]\nMSParam2)
    nCommand = aSub(nEditSubPtr)\aCtrlSend[n]\nMSParam2
    debugMsg(sProcName, "nCommand=" + Hex(nCommand, #PB_Long))
    Select nCommand
      Case $1, $2, $3, $5, $B, $10
        ; commands with q_number, q_list and q_path
        ResizeGadget(\lblQNumber, #PB_Ignore, \nQFieldsTop+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQNumber, #PB_Ignore, \nQFieldsTop, #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQNumber, Lang("WQM", "lblQNumber1"))
        setVisible(\lblQNumber, #True)
        scsToolTip(\txtQNumber, Lang("WQM", "txtQNumber1TT"))
        setValidChars(\txtQNumber, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQNumber, #True)
        
        ResizeGadget(\lblQList, #PB_Ignore, \nQFieldsTop+\nQFieldsHeight+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQList, #PB_Ignore, \nQFieldsTop+\nQFieldsHeight, #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQList, Lang("WQM", "lblQList1"))
        setVisible(\lblQList, #True)
        scsToolTip(\txtQList, Lang("WQM", "txtQList1TT"))
        setValidChars(\txtQList, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQList, #True)
        
        ResizeGadget(\lblQPath, #PB_Ignore, \nQFieldsTop+(\nQFieldsHeight*2)+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQPath, #PB_Ignore, \nQFieldsTop+(\nQFieldsHeight*2), #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQPath, Lang("WQM", "lblQPath1"))
        setVisible(\lblQPath, #True)
        scsToolTip(\txtQPath, Lang("WQM", "txtQPath1TT"))
        setValidChars(\txtQPath, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQPath, #True)
        
      Case $6
        ; set command uses q_number and q_list fields for control number and control value
        ResizeGadget(\lblQNumber, #PB_Ignore, \nQFieldsTop+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQNumber, #PB_Ignore, \nQFieldsTop, #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQNumber, Lang("WQM", "lblQNumber6"))
        setVisible(\lblQNumber, #True)
        scsToolTip(\txtQNumber, Lang("WQM", "txtQNumber6TT"))
        setValidChars(\txtQNumber, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQNumber, #True)
        
        ResizeGadget(\lblQList, #PB_Ignore, \nQFieldsTop+\nQFieldsHeight+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQList, #PB_Ignore, \nQFieldsTop+\nQFieldsHeight, #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQList, Lang("WQM", "lblQList6"))
        setVisible(\lblQList, #True)
        scsToolTip(\txtQList, Lang("WQM", "txtQList6TT"))
        setValidChars(\txtQList, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQList, #True)
        
      Case $7
        ; command with macro number
        setVisible(\lblMSMacro, #True)
        setVisible(\cboMSMacro, #True)
        ClearGadgetItems(\cboMSMacro)
        AddGadgetItem(\cboMSMacro, -1, #SCS_BLANK_CBO_ENTRY)
        For m = 0 To 127
          sHexValue = Right("0" + Hex(m), 2)
          AddGadgetItem(\cboMSMacro, -1, Trim(Str(m) + "  (" + sHexValue + "H)"))
        Next m
        
      Case $1B, $1C
        ; $1B, $1C (load/close cue list) added 15Sep2016 11.5.2 (email from C.Peters)
        ResizeGadget(\lblQList, #PB_Ignore, \nQFieldsTop+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQList, #PB_Ignore, \nQFieldsTop, #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQList, Lang("WQM", "lblQList1"))
        setVisible(\lblQList, #True)
        scsToolTip(\txtQList, Lang("WQM", "txtQList1TT"))
        setValidChars(\txtQList, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQList, #True)
        
      Case $1D, $1E
        ; $1D, $1E (load/close cue path) added 15Sep2016 11.5.2
        ResizeGadget(\lblQPath, #PB_Ignore, \nQFieldsTop+\nQLblFieldsYOffset, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\txtQPath, #PB_Ignore, \nQFieldsTop, #PB_Ignore, #PB_Ignore)
        SetGadgetText(\lblQPath, Lang("WQM", "lblQPath1"))
        setVisible(\lblQPath, #True)
        scsToolTip(\txtQPath, Lang("WQM", "txtQPath1TT"))
        setValidChars(\txtQPath, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
        setVisible(\txtQPath, #True)
        
        
      Default
        ; no extra info or unsupported
        
    EndSelect
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Macro WQM_macPopulateMIDIChannelComboBox(pComboBox)
  If nMsgType <> nPrevMsgType ; Test added 2Mar2022 11.9.1ad
    ClearGadgetItems(pComboBox)
    ; add blank entry
    AddGadgetItem(pComboBox, -1, #SCS_BLANK_CBO_ENTRY)
    ; add MIDI channels (1-16)
    For m = 1 To 16
      AddGadgetItem(pComboBox, -1, Trim(Str(m)))
    Next m
  EndIf
  ; select required channel
  If aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSChannel <= 16
    SetGadgetState(pComboBox, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSChannel)
  EndIf
EndMacro

Macro WQM_macPopulateMIDIParamComboBox(pComboBox, pNumParam, pStringParam)
  If nMsgType <> nPrevMsgType ; Test added 2Mar2022 11.9.1ad
    If GadgetWidth(pComboBox) <> 80
      ResizeGadget(pComboBox, #PB_Ignore, #PB_Ignore, 80, #PB_Ignore)
    EndIf
    ClearGadgetItems(pComboBox)
    ; add blank entry
    addGadgetItemWithData(pComboBox, #SCS_BLANK_CBO_ENTRY, -1)
    ; add callable cue parameters
    For m = 0 To aCue(nEditCuePtr)\nMaxCallableCueParam
      addGadgetItemWithData(pComboBox, aCue(nEditCuePtr)\aCallableCueParam(m)\sCallableParamId, #SCS_MISC_WQM_COMBO_PARAM_BASE+m)
    Next m
    ; add MIDI values
    If nMsgType = #SCS_MSGTYPE_PC128
      For m = 1 To 128
        ; Changed 8Apr2022 11.9.1az following forum bug report from 'SchauSbg'
        sHexValue = Right("0" + Hex(m-1), 2)
        addGadgetItemWithData(pComboBox, Trim(Str(m) + "  (" + sHexValue + "H)"), m-1)
        ; End changed 8Apr2022 11.9.1az
      Next m
    Else
      For m = 0 To 127
        sHexValue = Right("0" + Hex(m), 2)
        addGadgetItemWithData(pComboBox, Trim(Str(m) + "  (" + sHexValue + "H)"), m)
      Next m
    EndIf
  EndIf
  ; select required item in combobox
  If pStringParam
    nParamIndex = getCallableCueParamIndex(@aCue(nEditCuePtr), pStringParam)
    If nParamIndex >= 0
      setGadgetItemByData(pComboBox, #SCS_MISC_WQM_COMBO_PARAM_BASE+nParamIndex)
    EndIf
  ElseIf pNumParam <= 127
    setGadgetItemByData(pComboBox, pNumParam)
  EndIf
EndMacro

Procedure WQM_fcCboMsgType()
  PROCNAMECS(nEditSubPtr)
  Protected nMsgType, sRemDevMsgType.s, nSelectionType, nMSMsgType
  Protected sHexValue.s, sNote.s, d, m, nCtrlSendIndex, nRow
  Protected sTmp.s
  Protected nListIndex, nParamIndex
  Protected nMyDevType
  Protected nDevMapPtr
  Protected bMidiStructuredVisible, bMidiFileVisible, bOSCOverMidiVisible, bMidiFreeFormatVisible, bNRPNCaptureVisible, bRemDevVisible
  Protected bChannelVisible, bParam1Visible, bParam2Visible, bParam3Visible, bParam4Visible, bInfoVisible, bHexMessageVisible
  Protected bRemDevActionVisible, bRemDevComboboxVisible, bRemDevGridVisible, bRemDevFaderVisible
  Protected bEditScribbleStripVisible
  Protected sRemDevMsgDesc.s, sRemDevValDesc.s, sRemDevValue.s, sRemDevFdrDesc.s, sRemDevValDescForGrid.s
  Protected nRemDevId, sRemDevValType.s, sRemDevFdrType.s
  Protected bValType2ReqdForGrid, sRemDevValType2.s
  Protected nLeft, nTop, nHeight
  Protected nCntMidiReqdHeight, nCntRemDevReqdHeight, nGrdRemDevReqdHeight
  Protected bTestSelectedEnabled, bTestAllEnabled
  Protected nOSCCmdType, sOSCText.s
  Static bStaticLoaded, sChannel.s
  Static nPrevMsgType = #SCS_MSGTYPE_NONE ; Added 2Mar2021 11.9.1ad - used for minimizing the re-populating of comboboxes
  
  debugMsg(sProcName, #SCS_START)
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    sChannel = Lang("WQM", "Channel")
    bStaticLoaded = #True
  EndIf
  
  nCtrlSendIndex = GGS(WQM\grdCtrlSends)
  With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
debugMsg(sProcName, "nMsgType=" + nMsgType + " (" + decodeMsgType(nMsgType) + ")")
    grWQM\nCurrentMsgType = nMsgType
  EndWith
debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]))
  
  With WQM
    
    bTestSelectedEnabled = #True
    bTestAllEnabled = #True
    
    setVisible(\lblMsgTypeEmphasis, #False)
    
    SGT(\txtMSItemDesc, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sCSItemDesc)
    
    If nMsgType = #SCS_MSGTYPE_SCRIBBLE_STRIP
      bRemDevVisible = #True
      bEditScribbleStripVisible = #True
      bTestSelectedEnabled = #False
      
    ElseIf nMsgType > #SCS_MSGTYPE_DUMMY_LAST
      bRemDevVisible = #True
      bHexMessageVisible = #True
      sRemDevMsgType = CSRD_DecodeRemDevMsgType(nMsgType)
      nSelectionType = CSRD_GetSelectionTypeForRemDevMsgType(nMsgType)
      sRemDevValue = Trim(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sRemDevValue)
      debugMsg(sProcName, "sRemDevMsgType=" + sRemDevMsgType + ", nSelectionType=" + nSelectionType + ", sRemDevValue=" + sRemDevValue)
      Select nSelectionType
        Case #SCS_SELTYPE_GRID
          bRemDevGridVisible = #True
        Case #SCS_SELTYPE_CBO
          bRemDevComboboxVisible = #True
        Case #SCS_SELTYPE_CBO_AND_GRID ; Added 5Sep2022 11.9.5.1ab
          bRemDevComboboxVisible = #True
          bRemDevGridVisible = #True
          bValType2ReqdForGrid = #True
        Case #SCS_SELTYPE_FADER
          bRemDevFaderVisible = #True
        Case #SCS_SELTYPE_FADER_AND_GRID
          bRemDevFaderVisible = #True
          bRemDevGridVisible = #True
        Case #SCS_SELTYPE_CBO_FADER_AND_GRID
          bRemDevComboboxVisible = #True
          bRemDevFaderVisible = #True
          bRemDevGridVisible = #True
          bValType2ReqdForGrid = #True
        Case #SCS_SELTYPE_NONE
          ; none of the above visible as message type alone is sufficient (eg for message type MuteLR where only LR can be muted/unmuted)
      EndSelect
      If LCase(Left(sRemDevMsgType, 4)) = "mute"
        WQM_drawRemDevMuteIndicator(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nRemDevMuteAction, #False)
        bRemDevActionVisible = #True
      EndIf
      sRemDevValDesc = CSRD_GetValDescForRemDevMsgType(nMsgType, 1)
      If bRemDevGridVisible
        If bValType2ReqdForGrid
          sRemDevValDescForGrid = CSRD_GetValDescForRemDevMsgType(nMsgType, 2)
        Else
          sRemDevValDescForGrid = sRemDevValDesc ; Added 8Sep2022
        EndIf
        SetGadgetItemText(\grdRemDevGrdItem, -1, sRemDevValDescForGrid)
debugMsg(sProcName, "SetGadgetItemText(\grdRemDevGrdItem, -1, " + sRemDevValDescForGrid + ")")
      EndIf
      If aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
        nRemDevId = CSRD_GetRemDevIdForLogicalDev(#SCS_DEVTYPE_CS_NETWORK_OUT, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev)
        nOSCCmdType = CSRD_GetOSCCmdTypeForRemDevMsgType(nMsgType)
        aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nOSCCmdType = nOSCCmdType
        debugMsg(sProcName, "(Network) nRemDevId=" + nRemDevId + ", nOSCCmdType=" + decodeOSCCmdType(nOSCCmdType))
        If nOSCCmdType <> #SCS_CS_OSC_NOT_SET
          sOSCText = CSRD_GetMsgDataForRemDevMsgType(nMsgType)
          debugMsg(sProcName, "sOSCText=" + #DQUOTE$ + sOSCText + #DQUOTE$)
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sOSCItemString = sOSCText
        EndIf
      Else
        nRemDevId = CSRD_GetRemDevIdForLogicalDev(#SCS_DEVTYPE_CS_MIDI_OUT, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev)
debugMsg(sProcName, "(MIDI) nRemDevId=" + nRemDevId)
      EndIf
      sRemDevValType = CSRD_GetValTypeForRemDevMsgType(nMsgType, 1)
      If bValType2ReqdForGrid
        sRemDevValType2 = CSRD_GetValTypeForRemDevMsgType(nMsgType, 2)
      EndIf
debugMsg(sProcName, "sRemDevValType=" + sRemDevValType + ", sRemDevValType2=" + sRemDevValType2)
      If bRemDevComboboxVisible
        SGT(WQM\lblRemDevCboItem, sRemDevValDesc)
        If bRemDevGridVisible
          WQM_populateCboRemDevCombobox(nRemDevId, sRemDevValType, #False) ; no blank row at start if a grid is also required, ie default to first entry, eg FXSnd1
        Else
          WQM_populateCboRemDevCombobox(nRemDevId, sRemDevValType, #True)
        EndIf
        WQM_setCboRemDevCombobox()
      EndIf
      If bRemDevGridVisible
debugMsg(sProcName, "bValType2ReqdForGrid=" + strB(bValType2ReqdForGrid) + ", sRemDevValType=" + sRemDevValType + ", sRemDevValType2=" + sRemDevValType2)
        If bValType2ReqdForGrid
          WQM_populateGrdRemDevGrdItem(nRemDevId, sRemDevValType2, 2)
          WQM_setGrdRemDevGrdItems(2)
        Else
          WQM_populateGrdRemDevGrdItem(nRemDevId, sRemDevValType, 1)
          WQM_setGrdRemDevGrdItems(1)
        EndIf
      EndIf
      If bRemDevFaderVisible
        sRemDevFdrDesc = CSRD_GetFdrDescForRemDevMsgType(nMsgType)
        SGT(WQM\lblRemDevFader, sRemDevFdrDesc)
        sRemDevFdrType = CSRD_GetFdrTypeForRemDevMsgType(nMsgType)
        WQM_populateFdrRemDevFader()
      EndIf
debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]))
    Else
      bHexMessageVisible = #True
      Select nMsgType
        Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128 ; NOTE: Program Change
          ;{
          bMidiStructuredVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          bChannelVisible = #True
          SetGadgetText(\lblChannel, sChannel)
          WQM_macPopulateMIDIChannelComboBox(\cboMSChannel)
          
          bParam1Visible = #True
          SetGadgetText(\lblParam1, Lang("WQM", "Program#"))
          WQM_macPopulateMIDIParamComboBox(\cboMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1)
          ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\nMSParam1=" + aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1 + ", GGT(\cboMSParam1)=" + GGT(\cboMSParam1) + ", GGS(\cboMSParam1)=" + GGS(\cboMSParam1))
          ClearGadgetItems(\cboMSParam2)
          ;}
        Case #SCS_MSGTYPE_CC ; NOTE: Control Change
          ;{
          bMidiStructuredVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          bChannelVisible = #True
          SetGadgetText(\lblChannel, sChannel)
          WQM_macPopulateMIDIChannelComboBox(\cboMSChannel)
          
          bParam1Visible = #True
          SetGadgetText(\lblParam1, Lang("WQM", "Control#"))
          WQM_macPopulateMIDIParamComboBox(\cboMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1)
          
          bParam2Visible = #True
          SetGadgetText(\lblParam2, Lang("WQM", "Value"))
          WQM_macPopulateMIDIParamComboBox(\cboMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2)
          ;}
        Case #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF ; NOTE: Note ON, Note OFF
          ;{
          bMidiStructuredVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          bChannelVisible = #True
          SetGadgetText(\lblChannel, sChannel)
          WQM_macPopulateMIDIChannelComboBox(\cboMSChannel)
          
          bParam1Visible = #True
          SetGadgetText(\lblParam1, Lang("WQM", "Note#"))
          WQM_macPopulateMIDIParamComboBox(\cboMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1)
          
          If nMsgType = #SCS_MSGTYPE_ON
            SetGadgetText(\lblMsgTypeEmphasis, "(" + Lang("WQM", "NoteON") + ")")
            SetGadgetColor(\lblMsgTypeEmphasis, #PB_Gadget_FrontColor, RGB(0,128,0))
          Else
            SetGadgetText(\lblMsgTypeEmphasis, "(" + Lang("WQM", "NoteOFF") + ")")
            SetGadgetColor(\lblMsgTypeEmphasis, #PB_Gadget_FrontColor, RGB(255,0,0))
          EndIf
          SetGadgetColor(\lblMsgTypeEmphasis, #PB_Gadget_BackColor, #SCS_White)
          setVisible(\lblMsgTypeEmphasis, #True)
          
          bParam2Visible = #True
          SetGadgetText(\lblParam2, "Velocity")
          ; set default velocity if required
          If Len(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2) = 0 And (aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2 < 0 Or aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2 > 127)
            If nMsgType = #SCS_MSGTYPE_ON
              aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2 = 127
            Else
              aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2 = 0
            EndIf
          EndIf
          WQM_macPopulateMIDIParamComboBox(\cboMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2)
          ;}
        Case #SCS_MSGTYPE_MSC ; NOTE: MSC
          ;{
          bMidiStructuredVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          bChannelVisible = #True
          SetGadgetText(\lblChannel, Lang("WQM", "DeviceId"))
          If nMsgType <> nPrevMsgType ; Test added 2Mar2022 11.9.1ad
            ClearGadgetItems(\cboMSChannel)
            AddGadgetItem(\cboMSChannel, -1, #SCS_BLANK_CBO_ENTRY)
            For m = 0 To 127
              sHexValue = Right("0" + Hex(m), 2)
              AddGadgetItem(\cboMSChannel, -1, (sHexValue + "H  "+ m))
            Next m
          EndIf
          If aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSChannel <= 127
            SetGadgetState(\cboMSChannel, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSChannel)
          EndIf
          
          bParam1Visible = #True
          SetGadgetText(\lblParam1, Lang("WQM", "CommandFormat"))
          If nMsgType <> nPrevMsgType ; Test added 2Mar2022 11.9.1ad
            ResizeGadget(\cboMSParam1,#PB_Ignore,#PB_Ignore,190,#PB_Ignore)
            ClearGadgetItems(\cboMSParam1)
            ; add param1 blank entry
            ; AddGadgetItem(\cboMSParam1, -1, #SCS_BLANK_CBO_ENTRY)
            addGadgetItemWithData(\cboMSParam1, #SCS_BLANK_CBO_ENTRY, -1) ; Changed 31Jul2022 11.9.3.1af
            For m = 0 To 127
              sTmp = Trim(Right("0" + Hex(m), 2) + "H  " + decodeCommandFormatL(m))
              ; AddGadgetItem(\cboMSParam1, -1, sTmp)
              addGadgetItemWithData(\cboMSParam1, sTmp, m) ; Changed 31Jul2022 11.9.3.1af
            Next m
          EndIf
          If aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1 <= 127
            SGS(\cboMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1 + 1)
          EndIf
          
          bParam2Visible = #True
          SetGadgetText(\lblParam2, Lang("WQM", "Command"))
          If nMsgType <> nPrevMsgType ; Test added 2Mar2022 11.9.1ad
            ResizeGadget(\cboMSParam2,#PB_Ignore,#PB_Ignore,190,#PB_Ignore)
            ClearGadgetItems(\cboMSParam2)
            ; add param2 blank entry
            addGadgetItemWithData(\cboMSParam2, #SCS_BLANK_CBO_ENTRY, -1) ; Changed 18Feb2022 11.9.1ab
            For m = 0 To $1E
              sTmp = Trim(Right("0" + Hex(m), 2) + "H  " + decodeMSCCommand(m))
              addGadgetItemWithData(\cboMSParam2, sTmp, m) ; Changed 18Feb2022 11.9.1ab
            Next m
          EndIf
          If aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2 <= $1E
            SGS(\cboMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2 + 1)
          EndIf
          ;}
        Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM ; NOTE: NRPN
          ;{
          bMidiStructuredVisible = #True
          bNRPNCaptureVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          bChannelVisible = #True
          SetGadgetText(\lblChannel, sChannel)
          WQM_macPopulateMIDIChannelComboBox(\cboMSChannel)
          
          bInfoVisible = #True
          
          Select nMsgType
            Case #SCS_MSGTYPE_NRPN_GEN
              ; order: NRPN MSB, NRPN LSB, Data MSB, Data LSB
              bParam1Visible = #True
              SetGadgetText(\lblParam1, "NRPN MSB")
              WQM_macPopulateMIDIParamComboBox(\cboMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1)
              SGT(\txtMSParam1Info, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1Info)
              
              bParam2Visible = #True
              SetGadgetText(\lblParam2, "NRPN LSB")
              WQM_macPopulateMIDIParamComboBox(\cboMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2)
              SGT(\txtMSParam2Info, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2Info)
              SGT(WQM\btnNRPNSave, LangPars("WQM", "btnNRPNSave", Str(nCtrlSendIndex+1))) ; Added 4Oct2021 11.8.6au
              
            Case #SCS_MSGTYPE_NRPN_YAM
              ; order: NRPN LSB, NRPN MSB, Data MSB, Data LSB
              bParam1Visible = #True
              SetGadgetText(\lblParam1, "NRPN LSB")
              ; In the following lines, use param2 from the ctrl send item as param2 contains the NRPN LSB for both standard and Yamaha NRPN formats
              WQM_macPopulateMIDIParamComboBox(\cboMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2)
              SGT(\txtMSParam1Info, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam2Info)
              
              bParam2Visible = #True
              SetGadgetText(\lblParam2, "NRPN MSB")
              ; In the following lines, use param1 from the ctrl send item as param1 contains the NRPN MSB for both standard and Yamaha NRPN formats
              WQM_macPopulateMIDIParamComboBox(\cboMSParam2, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam1, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1)
              SGT(\txtMSParam2Info, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam1Info)
              
          EndSelect
          
          bParam3Visible = #True
          SetGadgetText(\lblParam3, "Data MSB")
          WQM_macPopulateMIDIParamComboBox(\cboMSParam3, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam3, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam3)
          SGT(\txtMSParam3Info, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam3Info)
          
          bParam4Visible = #True
          SetGadgetText(\lblParam4, "Data LSB")
          WQM_macPopulateMIDIParamComboBox(\cboMSParam4, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSParam4, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam4)
          SGT(\txtMSParam4Info, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sMSParam4Info)
          ;}
        Case #SCS_MSGTYPE_FREE  ; MIDI Free Format
          ;{
          bMidiFreeFormatVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          nListIndex = indexForComboBoxData(\cboMFEntryMode, #SCS_ENTRYMODE_HEX)
          SGS(\cboMFEntryMode, nListIndex)
          setEnabled(\cboMFEntryMode, #False)
          SGT(\txtMFEnteredString, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sEnteredString)
          setUpperCase(\txtMFEnteredString, #True)
          setValidChars(\txtMFEnteredString, #SCS_HEX_VALID_CHARS + " ")
          ;}
        Case #SCS_MSGTYPE_OSC_OVER_MIDI  ; OSC Over MIDI SysEx
          ;{
          bOSCOverMidiVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          SGT(\txtOMEnteredString, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sEnteredString)
          ;}
        Case #SCS_MSGTYPE_FILE   ; MIDI File
          ;{
          bMidiFileVisible = #True
          aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend = #True
          setEditAudPtr(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nAudPtr)
          If nEditAudPtr >= 0
            SetGadgetText(WQM\txtMidiFile, aAud(nEditAudPtr)\sStoredFileName)
          Else
            SetGadgetText(WQM\txtMidiFile, "")
          EndIf
          ;}
      EndSelect
    EndIf
debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]))
    
    setVisible(\lblChannel, bChannelVisible)
    setVisible(\cboMSChannel, bChannelVisible)
    setVisible(\lblParam1, bParam1Visible)
    setVisible(\cboMSParam1, bParam1Visible)
    setVisible(\txtMSParam1Info, bInfoVisible)
    setVisible(\lblParam2, bParam2Visible)
    setVisible(\cboMSParam2, bParam2Visible)
    setVisible(\txtMSParam2Info, bInfoVisible)
    setVisible(\lblParam3, bParam3Visible)
    setVisible(\cboMSParam3, bParam3Visible)
    setVisible(\txtMSParam3Info, bInfoVisible)
    setVisible(\lblParam4, bParam4Visible)
    setVisible(\cboMSParam4, bParam4Visible)
    setVisible(\txtMSParam4Info, bInfoVisible)
    
    setVisible(\lblRemDevAction, bRemDevActionVisible)
    setVisible(\cvsRemDevMute, bRemDevActionVisible)
    setVisible(\lblRemDevCboItem, bRemDevComboboxVisible)
    setVisible(\cboRemDevCboItem, bRemDevComboboxVisible)
    If bRemDevFaderVisible
      If bRemDevComboboxVisible
        nTop = GadgetY(\cboRemDevCboItem) + 23
      Else
        nTop = GadgetY(\cboRemDevCboItem)
      EndIf
      ResizeGadget(\lblRemDevFader, #PB_Ignore, nTop+4, #PB_Ignore, #PB_Ignore)
      If SLD_gadgetY(\sldRemDevFader) <> nTop
        SLD_ResizeGadget(sProcName, \sldRemDevFader, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
        SLD_Resize(\sldRemDevFader, #False)
      EndIf
      ResizeGadget(\txtRemDevDBLevel, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    EndIf
    setVisible(\lblRemDevFader, bRemDevFaderVisible)
    SLD_setVisible(\sldRemDevFader, bRemDevFaderVisible)
    setVisible(\txtRemDevDBLevel, bRemDevFaderVisible)
    If bRemDevGridVisible
      If bRemDevFaderVisible
        nTop = SLD_gadgetY(\sldRemDevFader) + 23
      ElseIf bRemDevComboboxVisible
        nTop = GadgetY(\cboRemDevCboItem) + 23
      ElseIf bRemDevActionVisible
        nTop = GadgetY(\cvsRemDevMute) + 23
      EndIf
      nHeight = GadgetHeight(\cntRemDev) - nTop - 8
      ; ResizeGadget(\grdRemDevGrdItem, #PB_Ignore, nTop, #PB_Ignore, nHeight)
      resizeGridForRows(\grdRemDevGrdItem, -1, nHeight, nTop)
    EndIf
    setVisible(\grdRemDevGrdItem, bRemDevGridVisible)
    setVisible(\btnEditScribbleStrip, bEditScribbleStripVisible)
    
    setVisible(\cntNRPNCapture, bNRPNCaptureVisible)
    
    setVisible(\cntMidiStructured, bMidiStructuredVisible)
    setVisible(\cntMidiFile, bMidiFileVisible)
    setVisible(\cntOSCOverMidi, bOSCOverMidiVisible)
    setVisible(\cntMidiFreeFormat, bMidiFreeFormatVisible)
    setVisible(\cntRemDev, bRemDevVisible)
    
    If bRemDevVisible
      setEnabled(\btnTestCtrlSend[2], bTestSelectedEnabled)
      setEnabled(\btnTestCtrlSend[3], bTestAllEnabled)
      setVisible(\cntTest, #False)
      setVisible(\cntRemDevTest, #True)
      nCntMidiReqdHeight = GadgetHeight(\cntSubDetailM) - GadgetY(\cntMidi) ; GadgetY(\cntTest) - GadgetY(\cntMidi)
      nCntRemDevReqdHeight = grWQM\nCntRemDevOriginalHeight + (nCntMidiReqdHeight - grWQM\nCntMidiOriginalHeight)
      nGrdRemDevReqdHeight = grWQM\nGrdRemDevOriginalHeight + (nCntMidiReqdHeight - grWQM\nCntMidiOriginalHeight)
    Else
      setEnabled(\btnTestCtrlSend[0], bTestSelectedEnabled)
      setEnabled(\btnTestCtrlSend[1], bTestAllEnabled)
      setVisible(\cntTest, #True)
      setVisible(\cntRemDevTest, #False)
      nCntMidiReqdHeight = grWQM\nCntMidiOriginalHeight
      nCntRemDevReqdHeight = grWQM\nCntRemDevOriginalHeight
      nGrdRemDevReqdHeight = grWQM\nGrdRemDevOriginalHeight
    EndIf
    If GadgetHeight(\cntMidi) <> nCntMidiReqdHeight
      ResizeGadget(\cntMidi, #PB_Ignore, #PB_Ignore, #PB_Ignore, nCntMidiReqdHeight)
      ResizeGadget(\cntRemDev, #PB_Ignore, #PB_Ignore, #PB_Ignore, nCntRemDevReqdHeight)
      ; ResizeGadget(\grdRemDevGrdItem, #PB_Ignore, #PB_Ignore, #PB_Ignore, nGrdRemDevReqdHeight)
      resizeGridForRows(\grdRemDevGrdItem, -1, nCntRemDevReqdHeight)
    EndIf
    
    nPrevMsgType = nMsgType ; Added 2Mar2022 11.9.1ad
    
  EndWith
  
debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]))
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboMidiCapturePort_Click()
  PROCNAMEC()
  Protected nMidiCapturePhysicalDevPtr
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  nMidiCapturePhysicalDevPtr = getCurrentItemData(WQM\cboMidiCapturePort, -1)
  
  For n = 0 To (gnNumMidiInDevs-1)
    If n = nMidiCapturePhysicalDevPtr
      gaMidiInDevice(n)\bMidiCapture = #True
    Else
      gaMidiInDevice(n)\bMidiCapture = #False
    EndIf
    openMidiPorts() ; will close any previous port no longer required, and will open the nominated port if required
  Next n
  WQM_fcMidiCapturePort()
  
  If nMidiCapturePhysicalDevPtr >= 0
    gnMidiCapturePhysicalDevPtr = nMidiCapturePhysicalDevPtr
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboNRPNCapturePort_Click()
  PROCNAMEC()
  Protected nNRPNCapturePhysicalDevPtr
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  nNRPNCapturePhysicalDevPtr = getCurrentItemData(WQM\cboNRPNCapturePort, -1)
  
  For n = 0 To (gnNumMidiInDevs-1)
    If n = nNRPNCapturePhysicalDevPtr
      gaMidiInDevice(n)\bNRPNCapture = #True
    Else
      gaMidiInDevice(n)\bNRPNCapture = #False
    EndIf
    openMidiPorts() ; will close any previous port no longer required, and will open the nominated port if required
  Next n
  WQM_fcNRPNCapturePort()
  
  If nNRPNCapturePhysicalDevPtr >= 0
    gnNRPNCapturePhysicalDevPtr = nNRPNCapturePhysicalDevPtr
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboMSChannel_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType

  ; debugMsg(sProcName, #SCS_START)
  
  n = grWQM\nSelectedCtrlSendRow
  
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    u = preChangeSubL(\nMSChannel, GGT(WQM\lblChannel), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \nMSChannel = GGS(WQM\cboMSChannel)
    grEditMem\aLastMsg(nMsgType)\nLastMSChannel = \nMSChannel
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubL(u, \nMSChannel, -5, n)
  EndWith
  ; debugMsg0(sProcName, #SCS_END)
EndProcedure

Procedure WQM_cboMSChannel_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  Protected nActiveGadget

  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  nActiveGadget = GetActiveGadget()

  debugMsg(sProcName, "GGT(WQM\cboMSChannel)=" + GGT(WQM\cboMSChannel))
  nListIndex = validateCBOField(WQM\cboMSChannel, GGT(WQM\lblChannel))
  If nListIndex = #SCS_CBO_ENTRY_INVALID
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf

  If nListIndex >= 0
    If GGS(WQM\cboMSChannel) <> nListIndex
      SGS(WQM\cboMSChannel, nListIndex)
    EndIf
  EndIf
  WQM_cboMSChannel_Click()
  
  If IsGadget(nActiveGadget)
    If GetActiveGadget() <> nActiveGadget
      SAG(nActiveGadget)
    EndIf
  EndIf
  grWQM\bInValidate = #False
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQM_cboMSMacro_Click()
  PROCNAMEC()
  Protected u, n
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf

  n = grWQM\nSelectedCtrlSendRow
  
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubL(\nMSMacro, GGT(WQM\lblMSMacro), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \nMSMacro = GGS(WQM\cboMSMacro) - 1
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubL(u, \nMSMacro, -5, n)
  EndWith
EndProcedure

Procedure WQM_cboMSMacro_Validate()
  PROCNAMEC()
  Protected nListIndex
  Protected nActiveGadget

  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  nActiveGadget = GetActiveGadget()

  nListIndex = validateCBOField(WQM\cboMSMacro, GGT(WQM\lblMSMacro))
  If nListIndex = #SCS_CBO_ENTRY_INVALID
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf

  If nListIndex >= 0
    If GGS(WQM\cboMSMacro) <> nListIndex
      SGS(WQM\cboMSMacro, nListIndex)
    EndIf
  EndIf
  WQM_cboMSMacro_Click()
  
  If IsGadget(nActiveGadget)
    If GetActiveGadget() <> nActiveGadget
      SAG(nActiveGadget)
    EndIf
  EndIf
  grWQM\bInValidate = #False
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQM_cboMsgType_Click()
  PROCNAMECS(nEditSubPtr)
  ; NOTE: cboMsgType was originally used for built-in control send message types only, such as #SCS_MSGTYPE_CC (MIDI Control Change).
  ; NOTE: The combobox now also contains 'remote device' message types obtained from the external file scs_csrd.scsrd.
  ; NOTE: The message types are held in different mutually-exclusive fields: \nMsgType and \nRemDevMsgType.
  Protected u
  Protected nCtrlSendIndex, nNewMSMsgType, nNewRemDevMsgType, nOldMSMsgType, nOldRemDevMsgType
  Protected nNewMsgType, nOldMsgType ; msg types, irrespective of whether it's \nMsgType or \nRemDevMsgType, as the values across both are unique
  Protected n2, bMidiDev
  Protected nDevType, nGadgetNo

  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)
  
  grWQM\bInMsgTypeChange = #True
  ; debugMsg(sProcName, "grWQM\bInMsgTypeChange=" + strB(grWQM\bInMsgTypeChange))
  nCtrlSendIndex = grWQM\nSelectedCtrlSendRow
  
  nDevType = aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nDevType
  If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork = #False
    nGadgetNo = WQM\cboOSCCmdType
  Else
    nGadgetNo = WQM\cboMsgType
  EndIf
  debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo))
  
  nOldMSMsgType = aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nMSMsgType
  nOldRemDevMsgType = aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nRemDevMsgType
  nOldMsgType = getMsgType(nOldMSMsgType, nOldRemDevMsgType)
  
  nNewMsgType = getCurrentItemData(nGadgetNo)
  ; debugMsg0(sProcName, "getCurrentItemData(" + getGadgetName(nGadgetNo) + ") returned " + nNewMsgType + ", GetGadgetState(" + getGadgetName(nGadgetNo) + ")=" + GetGadgetState(nGadgetNo))
  If nNewMsgType <= #SCS_MSGTYPE_DUMMY_LAST
    nNewMSMsgType = nNewMsgType
  Else
    nNewRemDevMsgType = nNewMsgType
  EndIf
  debugMsg(sProcName, "nOldMsgType=" + decodeMsgType(nOldMsgType) + ", nNewMsgType=" + decodeMsgType(nNewMsgType))
  
  If nNewMsgType = #SCS_MSGTYPE_FILE
    For n2 = 0 To #SCS_MAX_CTRL_SEND
      If n2 <> nCtrlSendIndex
        If aSub(nEditSubPtr)\aCtrlSend[n2]\nMSMsgType = #SCS_MSGTYPE_FILE
          valErrMsg(nGadgetNo, Lang("WQM", "OnlyOneFile"))
          ; debugMsg(sProcName, "calling SGS(WQM\cboMsgType, 0)")
          SGS(nGadgetNo, 0)  ; set to the blank entry at the start of the list
          nNewMsgType = 0
          nNewMSMsgType = 0
          ; now fall through the remaining code to add the 'change' (albeit modified) to the undo list if necessary, and to re-populate the ctrl send grid entry
        EndIf
      EndIf
    Next
  EndIf
  
  With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
    u = preChangeSubL(nOldMsgType, GGT(WQM\lblMsgType), -5, #SCS_UNDO_ACTION_CHANGE, nCtrlSendIndex)
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        bMidiDev = #True
    EndSelect
    If nOldMsgType <> nNewMsgType
      If nOldMsgType = #SCS_MSGTYPE_ON Or nOldMsgType = #SCS_MSGTYPE_OFF
        \nMSParam2 = grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2
      EndIf
    EndIf
    \nMSMsgType = nNewMSMsgType
    \nRemDevMsgType = nNewRemDevMsgType
    ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\nMSMsgType=" + decodeMsgType(\nMSMsgType) + ", \nRemDevMsgType=" + decodeMsgType(\nRemDevMsgType))
    \sRemDevMsgType = CSRD_DecodeRemDevMsgType(\nRemDevMsgType) ; nb will return blank if this is not a 'remote device' message type
    If nNewMsgType <> #SCS_MSGTYPE_SCRIBBLE_STRIP
      If nNewMsgType <= #SCS_MSGTYPE_DUMMY_LAST
        grEditMem\nLastMsgType = nNewMsgType
        ; debugMsg0(sProcName, "grEditMem\nLastMsgType=" + decodeMsgType(grEditMem\nLastMsgType))
      Else
        grEditMem\nLastRemDevMsgType = nNewMsgType
        ; debugMsg0(sProcName, "grEditMem\nLastRemDevMsgType=" + decodeMsgType(grEditMem\nLastRemDevMsgType))
      EndIf
    EndIf
    If \nRemDevMsgType > 0
      ; debugMsg0(sProcName, "nNewMsgType=" + decodeMsgType(nNewMsgType) + ", nOldMsgType=" + decodeMsgType(nOldMsgType))
      If nNewMsgType <> nOldMsgType
        ; must execute the following BEFORE calling WQM_fcCboMsgType()
        ; debugMsg(sProcName, "calling CSRD_clearDataValueSelectedArrays()")
        CSRD_clearDataValueSelectedArray(1)
        CSRD_clearDataValueSelectedArray(2)
        Select CSRD_GetSelectionTypeForRemDevMsgType(\nRemDevMsgType)
          Case #SCS_SELTYPE_NONE, #SCS_SELTYPE_CBO_FADER_AND_GRID
            \sRemDevValue = "1"
          Default
            \sRemDevValue = ""
        EndSelect
        \sRemDevLevel = ""  ; Added 2Sep2022 11.9.5.1ab
        \sRemDevValue2 = "" ; Added 2Sep2022 11.9.5.1ab
      EndIf
    EndIf
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        bMidiDev = #True
        If nNewMsgType <> #SCS_MSGTYPE_NONE
          \sCSItemDesc = grEditMem\aLastMsg(nNewMsgType)\sLastMSItemDesc
          If nNewMsgType < #SCS_MSGTYPE_DUMMY_LAST And nNewMsgType <> #SCS_MSGTYPE_SCRIBBLE_STRIP
            \nMSChannel = grEditMem\aLastMsg(nNewMsgType)\nLastMSChannel
            \nMSParam1 = grEditMem\aLastMsg(nNewMsgType)\nLastMSParam1
            \nMSParam2 = grEditMem\aLastMsg(nNewMsgType)\nLastMSParam2
            \nMSParam3 = grEditMem\aLastMsg(nNewMsgType)\nLastMSParam3
            \nMSParam4 = grEditMem\aLastMsg(nNewMsgType)\nLastMSParam4
            \sMSParam1Info = grEditMem\aLastMsg(nNewMsgType)\sLastMSParam1Info
            \sMSParam2Info = grEditMem\aLastMsg(nNewMsgType)\sLastMSParam2Info
            \sMSParam3Info = grEditMem\aLastMsg(nNewMsgType)\sLastMSParam3Info
            \sMSParam4Info = grEditMem\aLastMsg(nNewMsgType)\sLastMSParam4Info
          EndIf
        EndIf
        
      Case #SCS_DEVTYPE_CS_RS232_OUT
        
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        
    EndSelect
    
    If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork = #False
      ; debugMsg(sProcName, "calling WQM_fcOSCCmdType")
      WQM_fcOSCCmdType()
    Else
      ; debugMsg(sProcName, "calling WQM_fcCboMsgType")
      WQM_fcCboMsgType()
    EndIf
    ; debugMsg(sProcName, "calling WQM_fcCboMsCommand()")
    WQM_fcCboMsCommand()
    ; debugMsg(sProcName, "calling buildCtrlSendMessage()")
    buildCtrlSendMessage()
    ; debugMsg0(sProcName, "\nRemDevMsgType=" + decodeMsgType(\nRemDevMsgType) + ", \sRemDevValue=" + \sRemDevValue)
    If \nRemDevMsgType > 0
      ; debugMsg0(sProcName, "calling CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(" + getSubLabel(nEditSubPtr) + "), " + nCtrlSendIndex + ")")
      CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(nEditSubPtr), nCtrlSendIndex)
    Else
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nCtrlSendIndex)
    EndIf
    If nCtrlSendIndex = 0
      WQM_resetSubDescrIfReqd()
    EndIf
    updateCtrlSendGrid(nCtrlSendIndex, #True)
    postChangeSubL(u, nNewMsgType, -5, nCtrlSendIndex)
  EndWith
  
  WQM_resetSubDescrIfReqd()
  
  WQM_setCtrlSendTestButtons()
  grWQM\bInMsgTypeChange = #False
  ; debugMsg(sProcName, "grWQM\bInMsgTypeChange=" + strB(grWQM\bInMsgTypeChange))
  
  If bMidiDev
    If nNewMsgType = #SCS_MSGTYPE_SCRIBBLE_STRIP
      WES_Form_Show(nEditSubPtr, nCtrlSendIndex, nOldMsgType)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WQM_cboMSParam1_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType, nValue, nMSParamValue=-1, sMSParamValue.s, sOldCombined.s, sNewCombined.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  If GGS(WQM\cboMSParam1) = -1
    debugMsg(sProcName, "nothing selected")
    ProcedureReturn
  EndIf
  
  nValue = getCurrentItemData(WQM\cboMSParam1)
  If nValue >= #SCS_MISC_WQM_COMBO_PARAM_BASE
    sMSParamValue = aCue(nEditCuePtr)\aCallableCueParam(nValue-#SCS_MISC_WQM_COMBO_PARAM_BASE)\sCallableParamId
  Else
    nMSParamValue = nValue
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    If nMsgType = #SCS_MSGTYPE_NRPN_YAM
      ; Important: Yamaha NRPN has LSB before MSB so cboMSParam1 will be stored in nMSParam2, etc
      sOldCombined = \sMSParam2 + "@" + \nMSParam2
      u = preChangeSubS(sOldCombined, GGT(WQM\lblParam1), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam2 = sMSParamValue
      \nMSParam2 = nMSParamValue
      If \nMSParam2 >= 0 : grEditMem\aLastMsg(nMsgType)\nLastMSParam2 = \nMSParam2 : EndIf
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      sNewCombined = \sMSParam2 + "@" + \nMSParam2
      postChangeSubS(u, sNewCombined, -5, n)
    Else
      sOldCombined = \sMSParam1 + "@" + \nMSParam1
      u = preChangeSubS(sOldCombined, GGT(WQM\lblParam1), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam1 = sMSParamValue
      \nMSParam1 = nMSParamValue
      ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + n + "]\sMSParam1=" + \sMSParam1 + ", \nMSParam1=" + \nMSParam1)
      If \nMSParam1 >= 0 : grEditMem\aLastMsg(nMsgType)\nLastMSParam1 = \nMSParam1 : EndIf
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      sNewCombined = \sMSParam1 + "@" + \nMSParam1
      postChangeSubS(u, sNewCombined, -5, n)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboMSParam1_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  Protected nActiveGadget

  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  nActiveGadget = GetActiveGadget()

  nListIndex = validateCBOField(WQM\cboMSParam1, GGT(WQM\lblParam1))
  If nListIndex = #SCS_CBO_ENTRY_INVALID
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf

  If nListIndex >= 0
    If GGS(WQM\cboMSParam1) <> nListIndex
      ; debugMsg(sProcName, "setting cboMSParam1.ListIndex=" + nListIndex)
      SGS(WQM\cboMSParam1, nListIndex)
    EndIf
  EndIf
  WQM_cboMSParam1_Click()
  
  If IsGadget(nActiveGadget)
    If GetActiveGadget() <> nActiveGadget
      SAG(nActiveGadget)
    EndIf
  EndIf
  grWQM\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQM_cboMSParam2_Click()
  PROCNAMEC()
  Protected u, n, nMsgType, nValue, nMSParamValue=-1, sMSParamValue.s, sOldCombined.s, sNewCombined.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  nValue = getCurrentItemData(WQM\cboMSParam2)
  If nValue >= #SCS_MISC_WQM_COMBO_PARAM_BASE
    sMSParamValue = aCue(nEditCuePtr)\aCallableCueParam(nValue-#SCS_MISC_WQM_COMBO_PARAM_BASE)\sCallableParamId
  Else
    nMSParamValue = nValue
  EndIf
  ; debugMsg(sProcName, "GGT(WQM\cboMSParam2)=" + GGT(WQM\cboMSParam2) + ", nValue=" + nValue + ", nMSParamValue=" + nMSParamValue)
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    If nMsgType = #SCS_MSGTYPE_NRPN_YAM
      ; Important: Yamaha NRPN has LSB before MSB so cboMSParam2 will be stored in nMSParam1, etc
      sOldCombined = \sMSParam1 + "@" + \nMSParam1
      u = preChangeSubS(sOldCombined, GGT(WQM\lblParam2), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam1 = sMSParamValue
      \nMSParam1 = nMSParamValue
      If \nMSParam1 >= 0 : grEditMem\aLastMsg(nMsgType)\nLastMSParam1 = \nMSParam1 : EndIf
      WQM_fcCboMsCommand()
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      sNewCombined = \sMSParam1 + "@" + \nMSParam1
      postChangeSubS(u, sNewCombined, -5, n)
    Else
      sOldCombined = \sMSParam2 + "@" + \nMSParam2
      u = preChangeSubS(sOldCombined, GGT(WQM\lblParam2), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam2 = sMSParamValue
      \nMSParam2 = nMSParamValue
      If \nMSParam2 >= 0 : grEditMem\aLastMsg(nMsgType)\nLastMSParam2 = \nMSParam2 : EndIf
      WQM_fcCboMsCommand()
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      sNewCombined = \sMSParam2 + "@" + \nMSParam2
      postChangeSubS(u, sNewCombined, -5, n)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboMSParam2_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  Protected nActiveGadget
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  nActiveGadget = GetActiveGadget()

  nListIndex = validateCBOField(WQM\cboMSParam2, GGT(WQM\lblParam2))
  If nListIndex = #SCS_CBO_ENTRY_INVALID
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf

  If nListIndex >= 0
    If GGS(WQM\cboMSParam2) <> nListIndex
      SGS(WQM\cboMSParam2, nListIndex)
    EndIf
  EndIf
  WQM_cboMSParam2_Click()
  
  If IsGadget(nActiveGadget)
    If GetActiveGadget() <> nActiveGadget
      SAG(nActiveGadget)
    EndIf
  EndIf
  grWQM\bInValidate = #False
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQM_cboMSParam3_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType, nValue, nMSParamValue=-1, sMSParamValue.s, sOldCombined.s, sNewCombined.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  If GGS(WQM\cboMSParam3) = -1
    debugMsg(sProcName, "nothing selected")
    ProcedureReturn
  EndIf
  
  nValue = getCurrentItemData(WQM\cboMSParam3)
  If nValue >= #SCS_MISC_WQM_COMBO_PARAM_BASE
    sMSParamValue = aCue(nEditCuePtr)\aCallableCueParam(nValue-#SCS_MISC_WQM_COMBO_PARAM_BASE)\sCallableParamId
  Else
    nMSParamValue = nValue
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    sOldCombined = \sMSParam3 + "@" + \nMSParam3
    u = preChangeSubS(sOldCombined, GGT(WQM\lblParam3), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSParam3 = sMSParamValue
    \nMSParam3 = nMSParamValue
    If \nMSParam3 >= 0 : grEditMem\aLastMsg(nMsgType)\nLastMSParam3 = \nMSParam3 : EndIf
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    sNewCombined = \sMSParam3 + "@" + \nMSParam3
    postChangeSubS(u, sNewCombined, -5, n)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboMSParam3_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  Protected nActiveGadget

  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  nActiveGadget = GetActiveGadget()

  nListIndex = validateCBOField(WQM\cboMSParam3, GGT(WQM\lblParam3))
  If nListIndex = #SCS_CBO_ENTRY_INVALID
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf

  If nListIndex >= 0
    If GGS(WQM\cboMSParam3) <> nListIndex
      ; debugMsg(sProcName, "setting cboMSParam3.ListIndex=" + nListIndex)
      SGS(WQM\cboMSParam3, nListIndex)
    EndIf
  EndIf
  WQM_cboMSParam3_Click()
  
  If IsGadget(nActiveGadget)
    If GetActiveGadget() <> nActiveGadget
      SAG(nActiveGadget)
    EndIf
  EndIf
  grWQM\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQM_cboMSParam4_Click()
  PROCNAMEC()
  Protected u, n, nMsgType, nValue, nMSParamValue=-1, sMSParamValue.s, sOldCombined.s, sNewCombined.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  nValue = getCurrentItemData(WQM\cboMSParam4)
  If nValue >= #SCS_MISC_WQM_COMBO_PARAM_BASE
    sMSParamValue = aCue(nEditCuePtr)\aCallableCueParam(nValue-#SCS_MISC_WQM_COMBO_PARAM_BASE)\sCallableParamId
  Else
    nMSParamValue = nValue
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    sOldCombined = \sMSParam4 + "@" + \nMSParam4
    u = preChangeSubS(sOldCombined, GGT(WQM\lblParam4), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSParam4 = sMSParamValue
    \nMSParam4 = nMSParamValue
    If \nMSParam4 >= 0 : grEditMem\aLastMsg(nMsgType)\nLastMSParam4 = \nMSParam4 : EndIf
    WQM_fcCboMsCommand()
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    sNewCombined = \sMSParam4 + "@" + \nMSParam4
    postChangeSubS(u, sNewCombined, -5, n)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboMSParam4_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nListIndex
  Protected nActiveGadget
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  nActiveGadget = GetActiveGadget()

  nListIndex = validateCBOField(WQM\cboMSParam4, GGT(WQM\lblParam4))
  If nListIndex = #SCS_CBO_ENTRY_INVALID
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf

  If nListIndex >= 0
    If GGS(WQM\cboMSParam4) <> nListIndex
      SGS(WQM\cboMSParam4, nListIndex)
    EndIf
  EndIf
  WQM_cboMSParam4_Click()
  
  If IsGadget(nActiveGadget)
    If GetActiveGadget() <> nActiveGadget
      SAG(nActiveGadget)
    EndIf
  EndIf
  grWQM\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtMSParam1Info_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    If nMsgType = #SCS_MSGTYPE_NRPN_YAM
      u = preChangeSubS(\sMSParam2Info, GGT(WQM\lblParam1), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam2Info = GGT(WQM\txtMSParam1Info) ; nb for Yamaha NRPN, param1 and param2 are reversed, so param1 is displayed against param2
      grEditMem\aLastMsg(nMsgType)\sLastMSParam2Info = \sMSParam2Info
      postChangeSubS(u, \sMSParam2Info, -5, n)
    Else
      u = preChangeSubS(\sMSParam1Info, GGT(WQM\lblParam1), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam1Info = GGT(WQM\txtMSParam1Info)
      grEditMem\aLastMsg(nMsgType)\sLastMSParam1Info = \sMSParam1Info
      postChangeSubS(u, \sMSParam1Info, -5, n)
    EndIf
  EndWith
  
  markValidationOK(WQM\txtMSParam1Info)
  ProcedureReturn #True
  
EndProcedure

Procedure WQM_txtMSParam2Info_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    If nMsgType = #SCS_MSGTYPE_NRPN_YAM
      u = preChangeSubS(\sMSParam1Info, GGT(WQM\lblParam2), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam1Info = GGT(WQM\txtMSParam2Info) ; nb for Yamaha NRPN, param1 and param2 are reversed, so param2 is displayed against param1
      grEditMem\aLastMsg(nMsgType)\sLastMSParam1Info = \sMSParam1Info
      postChangeSubS(u, \sMSParam1Info, -5, n)
    Else
      u = preChangeSubS(\sMSParam2Info, GGT(WQM\lblParam2), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sMSParam2Info = GGT(WQM\txtMSParam2Info)
      grEditMem\aLastMsg(nMsgType)\sLastMSParam2Info = \sMSParam2Info
      postChangeSubS(u, \sMSParam2Info, -5, n)
    EndIf
  EndWith
  
  markValidationOK(WQM\txtMSParam2Info)
  ProcedureReturn #True
  
EndProcedure

Procedure WQM_txtMSParam3Info_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    u = preChangeSubS(\sMSParam3Info, GGT(WQM\lblParam3), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSParam3Info = GGT(WQM\txtMSParam3Info)
    grEditMem\aLastMsg(nMsgType)\sLastMSParam3Info = \sMSParam3Info
    postChangeSubS(u, \sMSParam3Info, -5, n)
  EndWith
  
  markValidationOK(WQM\txtMSParam3Info)
  ProcedureReturn #True
  
EndProcedure

Procedure WQM_txtMSParam4Info_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nMsgType
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    u = preChangeSubS(\sMSParam4Info, GGT(WQM\lblParam4), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSParam4Info = GGT(WQM\txtMSParam4Info)
    grEditMem\aLastMsg(nMsgType)\sLastMSParam4Info = \sMSParam4Info
    postChangeSubS(u, \sMSParam4Info, -5, n)
  EndWith
  
  markValidationOK(WQM\txtMSParam4Info)
  ProcedureReturn #True
  
EndProcedure

Procedure WQM_drawForm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  colorEditorComponent(#WQM)

  ResizeGadget(WQM\lblMSMacro, GadgetX(WQM\lblQNumber), GadgetY(WQM\lblQNumber), GadgetWidth(WQM\lblQNumber), #PB_Ignore)
  ResizeGadget(WQM\cboMSMacro, GadgetX(WQM\txtQNumber), GadgetY(WQM\txtQNumber), #PB_Ignore, #PB_Ignore)

  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQM_cboRSDevice_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected n

  debugMsg(sProcName, #SCS_START)

  n = grWQM\nSelectedCtrlSendRow
  CompilerIf 1=2
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sLogicalDev, GGT(WQM\lblRSDevice), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sLogicalDev = Trim(GGT(WQM\cboRSDevice))
    sLastRS232LogicalDev = \sLogicalDev
    debugMsg(sProcName, "aSub(" + nEditSubPtr + ")\aCtrlSend[" + n + "]\sLogicalDev=" + \sLogicalDev)
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sLogicalDev, -5, n)
  EndWith
  CompilerEndIf

EndProcedure

Procedure WQM_fcCtrlMidiRemoteDev(bUseEditMemIfReqd)
  PROCNAMECS(nEditSubPtr)
  Protected n, nRemDevId
  Protected nWorkDevType
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    n = GGS(WQM\grdCtrlSends)
    If n >= 0
      With aSub(nEditSubPtr)\aCtrlSend[n]
        nWorkDevType = \nDevType
        If nWorkDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork
          nWorkDevType = #SCS_DEVTYPE_CS_MIDI_OUT
        EndIf
        Select nWorkDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            nRemDevId = CSRD_GetRemDevIdForLogicalDev(\nDevType, \sCSLogicalDev)
            setComboBoxByData(WQM\cboCtrlMidiRemoteDev, nRemDevId)
            debugMsg(sProcName, "setComboBoxByData(WQM\cboCtrlMidiRemoteDev, " + nRemDevId  + "), " + GGT(WQM\cboCtrlMidiRemoteDev))
        EndSelect
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure WQM_fcCtrlNetworkRemoteDev(bUseEditMemIfReqd)
  PROCNAMECS(nEditSubPtr)
  Protected n, nCtrlNetworkRemoteDev
  Protected nWorkDevType
  
  debugMsg(sProcName, #SCS_START + ", bUseEditMemIfReqd=" + strB(bUseEditMemIfReqd))
  
  If nEditSubPtr >= 0
    n = GGS(WQM\grdCtrlSends)
    If n >= 0
      With aSub(nEditSubPtr)\aCtrlSend[n]
        nWorkDevType = \nDevType
        If nWorkDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork
          nWorkDevType = #SCS_DEVTYPE_CS_MIDI_OUT
        EndIf
        Select nWorkDevType
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            nCtrlNetworkRemoteDev = getCtrlNetworkRemoteDevForPhysicalDevPtr(\nCSPhysicalDevPtr)
            WQM_populateCboOSCCmdType(nCtrlNetworkRemoteDev)
            ; debugMsg(sProcName, "calling WQM_fcOSCCmdType()")
            WQM_fcOSCCmdType()
            ; debugMsg(sProcName, "nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev))
            If nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_VMIX
              \nEntryMode = #SCS_ENTRYMODE_UTF8
              \bAddCR = #True
              \bAddLF = #True
              setEnabled(WQM\cboNWEntryMode, #False)
              setOwnEnabled(WQM\chkNWAddCR, #False)
              setOwnEnabled(WQM\chkNWAddLF, #False)
            Else
              If bUseEditMemIfReqd
                \nEntryMode = grEditMem\nLastEntryMode
                \bAddCR = grEditMem\bLastAddCR
                \bAddLF = grEditMem\bLastAddLF
              EndIf
              setEnabled(WQM\cboNWEntryMode, #True)
              setOwnEnabled(WQM\chkNWAddCR, #True)
              setOwnEnabled(WQM\chkNWAddLF, #True)
            EndIf
            ; debugMsg(sProcName, "bUseEditMemIfReqd=" + strB(bUseEditMemIfReqd) + ", nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev) +
            ;                     ", \nEntryMode=" + decodeEntryMode(\nEntryMode) + ", \bAddCR=" + strB(\bAddCR) + ", \bAddLF=" + strB(\bAddLF))
        EndSelect
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_fcEntryMode()
  PROCNAMECS(nEditSubPtr)
  Protected n, sOrigEnteredString.s
  
  If nEditSubPtr >= 0
    n = GGS(WQM\grdCtrlSends)
    If n >= 0
      With aSub(nEditSubPtr)\aCtrlSend[n]
        Select \nDevType
          Case #SCS_DEVTYPE_CS_RS232_OUT
            If \nEntryMode = #SCS_ENTRYMODE_HEX
              setUpperCase(WQM\txtRSEnteredString, #True)
              setValidChars(WQM\txtRSEnteredString, #SCS_HEX_VALID_CHARS + " ")
              sOrigEnteredString = \sEnteredString
              \sEnteredString = removeInvalidChars(\sEnteredString, #SCS_HEX_VALID_CHARS + " ")
              If \sEnteredString <> sOrigEnteredString
                SGT(WQM\txtRSEnteredString, \sEnteredString)
              EndIf
            Else
              setUpperCase(WQM\txtRSEnteredString, #False)
              setValidChars(WQM\txtRSEnteredString, "")
            EndIf
            
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            If \nEntryMode = #SCS_ENTRYMODE_HEX
              setUpperCase(WQM\txtNWEnteredString, #True)
              setValidChars(WQM\txtNWEnteredString, #SCS_HEX_VALID_CHARS + " ")
              sOrigEnteredString = \sEnteredString
              \sEnteredString = removeInvalidChars(\sEnteredString, #SCS_HEX_VALID_CHARS + " ")
              If \sEnteredString <> sOrigEnteredString
                SGT(WQM\txtNWEnteredString, \sEnteredString)
              EndIf
            Else
              setUpperCase(WQM\txtNWEnteredString, #False)
              setValidChars(WQM\txtNWEnteredString, "")
            EndIf
            
        EndSelect
      EndWith
    EndIf
  EndIf
EndProcedure

Procedure WQM_cboRSEntryMode_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected n

  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\nEntryMode, GGT(WQM\lblRSEntryMode), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \nEntryMode = getCurrentItemData(WQM\cboRSEntryMode)
      grEditMem\nLastEntryMode = \nEntryMode
      WQM_fcEntryMode()
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubL(u, \nEntryMode, -5, n)
    EndWith
  EndIf
EndProcedure

Procedure WQM_cboNWEntryMode_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\nEntryMode, GGT(WQM\lblNWEntryMode), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \nEntryMode = getCurrentItemData(WQM\cboNWEntryMode)
      grEditMem\nLastEntryMode = \nEntryMode
      WQM_fcEntryMode()
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubL(u, \nEntryMode, -5, n)
    EndWith
  EndIf
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQM_chkRSAddCR_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u

  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bAddCR, getOwnText(WQM\chkRSAddCR), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bAddCR = getOwnState(WQM\chkRSAddCR)
      grEditMem\bLastAddCR = \bAddCR
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubL(u, \bAddCR, -5, n)
    EndWith
  EndIf

EndProcedure

Procedure WQM_chkRSAddLF_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bAddLF, getOwnText(WQM\chkRSAddLF), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bAddLF = getOwnState(WQM\chkRSAddLF)
      grEditMem\bLastAddLF = \bAddLF
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubL(u, \bAddLF, -5, n)
    EndWith
  EndIf
  
EndProcedure

Procedure WQM_chkNWAddCR_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bAddCR, getOwnText(WQM\chkNWAddCR), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bAddCR = getOwnState(WQM\chkNWAddCR)
      grEditMem\bLastAddCR = \bAddCR
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubL(u, \bAddCR, -5, n)
    EndWith
  EndIf
  
EndProcedure

Procedure WQM_chkNWAddLF_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u
  
  If grWQM\bInMsgTypeChange
    ProcedureReturn
  EndIf
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bAddLF, getOwnText(WQM\chkNWAddLF), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bAddLF = getOwnState(WQM\chkNWAddLF)
      grEditMem\bLastAddLF = \bAddLF
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubL(u, \bAddLF, -5, n)
    EndWith
  EndIf
  
EndProcedure

Procedure WQM_btnTestCtrlSend_Click(nBtnIndex)
  PROCNAMEC()
  Protected nMsgResult
  Protected nMidiCount, nRS232Count, nNetworkCount, nHTTPCount
  Protected n, nCtrlSendIndex
  Protected nFromCtrlSendIndex, nUpToCtrlSendIndex
  Protected bResult

  debugMsg(sProcName, #SCS_START + ", nBtnIndex=" + nBtnIndex)

  If nBtnIndex = 0 Or nBtnIndex = 2
    ; test only selected message
    nCtrlSendIndex = GGS(WQM\grdCtrlSends)
    nFromCtrlSendIndex = nCtrlSendIndex
    nUpToCtrlSendIndex = nCtrlSendIndex
  Else
    nFromCtrlSendIndex = 0
    nUpToCtrlSendIndex = #SCS_MAX_CTRL_SEND
  EndIf

  For n = nFromCtrlSendIndex To nUpToCtrlSendIndex
    With aSub(nEditSubPtr)\aCtrlSend[n]
;       debugMsg(sProcName, "aSub(" + nEditSubPtr + ")\aCtrlSend[" + n + "]\bMIDISend=" + strB(\bMIDISend) + ", \bRS232Send=" + strB(\bRS232Send) + ", \bNetworkSend=" + strB(\bNetworkSend) + ", \bHTTPSend=" + strB(\bHTTPSend))
      If \bMIDISend
        nMidiCount + 1
      ElseIf \bRS232Send
        nRS232Count + 1
      ElseIf \bNetworkSend
        nNetworkCount + 1
      ElseIf \bHTTPSend
        nHTTPCount + 1
      EndIf
    EndWith
  Next n

  If nMidiCount > 0
    If grSession\nMidiOutEnabled = #SCS_DEVTYPE_DISABLED
      nMsgResult = scsMessageRequester(grText\sTextEditor, LangPars("Errors", "CurrentlyDisabled", "MIDI"), #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nMsgResult = #PB_MessageRequester_Yes
        grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nMidiOutEnabled=" + grSession\nMidiOutEnabled)
        setMidiEnabled()
      Else
        ProcedureReturn
      EndIf
    EndIf
  EndIf

  If nRS232Count > 0
    If grSession\nRS232OutEnabled = #SCS_DEVTYPE_DISABLED
      nMsgResult = scsMessageRequester(grText\sTextEditor, LangPars("Errors", "CurrentlyDisabled", "RS232"), #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nMsgResult = #PB_MessageRequester_Yes
        grSession\nRS232OutEnabled = #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nRS232OutEnabled=" + grSession\nRS232OutEnabled)
        setRS232Enabled()
      Else
        ProcedureReturn
      EndIf
    EndIf
    bResult = checkRS232DevsForCtrlSends()
    If bResult = #False
      ProcedureReturn
    EndIf
  EndIf
  
  If nNetworkCount > 0
    If grSession\nNetworkOutEnabled = #SCS_DEVTYPE_DISABLED
      nMsgResult = scsMessageRequester(grText\sTextEditor, LangPars("Errors", "CurrentlyDisabled", "Network"), #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nMsgResult = #PB_MessageRequester_Yes
        grSession\nNetworkOutEnabled = #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nNetworkOutEnabled=" + grSession\nNetworkOutEnabled)
        setNetworkEnabled()
      Else
        ProcedureReturn
      EndIf
    EndIf
    bResult = checkNetworkDevsForCtrlSends()
    If bResult = #False
      ProcedureReturn
    EndIf
  EndIf
  
  If nBtnIndex = 0 Or nBtnIndex = 2
    ; play only selected message
    editPlaySub(nCtrlSendIndex)
  Else
    ; play all messages
    editPlaySub()
  EndIf

  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WQM_btnEditPause_Click()
  PROCNAMEC()
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, aAud(nEditAudPtr)\sAudLabel)
  If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
    resumeAud(nEditAudPtr)
  Else
    debugMsg(sProcName, "calling pauseAud(" + nEditAudPtr + ")")
    pauseAud(nEditAudPtr)
  EndIf
  debugMsg(sProcName, "calling editSetDisplayButtonsM()")
  editSetDisplayButtonsM()
  gbCallEditUpdateDisplay = #True
  debugMsg(sProcName, #SCS_END)
  SAG(-1)
EndProcedure

Procedure WQM_btnEditPlay_Click()
  PROCNAMEC()
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, aAud(nEditAudPtr)\sAudLabel + " " + decodeCueState(aAud(nEditAudPtr)\nAudState))
  If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
    debugMsg(sProcName, "calling resumeAud(" + nEditAudPtr + ")")
    resumeAud(nEditAudPtr)
  ElseIf aAud(nEditAudPtr)\nAudState < #SCS_CUE_FADING_IN Or aAud(nEditAudPtr)\nAudState > #SCS_CUE_FADING_OUT
    debugMsg(sProcName, "calling editPlaySub")
    editPlaySub()
  Else
    debugMsg(sProcName, "calling restartAud(" + nEditAudPtr + ")")
    restartAud(nEditAudPtr)
  EndIf
  editSetDisplayButtonsM()
  gbCallEditUpdateDisplay = #True
  SAG(-1)
EndProcedure

Procedure WQM_btnEditRewind_Click()
  PROCNAMEC()
  Protected nState
  
  gqTimeNow = ElapsedMilliseconds()
  
  nState = aAud(nEditAudPtr)\nAudState
  If nState >= #SCS_CUE_FADING_IN And nState <= #SCS_CUE_FADING_OUT And nState <> #SCS_CUE_PAUSED
    pauseAud(nEditAudPtr)
    With aAud(nEditAudPtr)
      \nCuePosAtLoopStart = 0    ; must be cleared before calling reposAuds
      debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ")")
      reposAuds(nEditAudPtr, \nAbsStartAt)
      \qTimeAudStarted = gqTimeNow
      ; \qTimeAudEnded = 0
      \bTimeAudEndedSet = #False
      \qTimeAudRestarted = gqTimeNow
      \nTotalTimeOnPause = 0
      \nPriorTimeOnPause = 0
      \nPreFadeInTimeOnPause = 0
      \nPreFadeOutTimeOnPause = 0
      \nCuePosAtLoopStart = 0
    EndWith
    debugMsg(sProcName, "calling playAud(" + nEditAudPtr + ")")
    resumeAud(nEditAudPtr)
  Else
    With aAud(nEditAudPtr)
      \nCuePosAtLoopStart = 0    ; must be cleared before calling reposAuds
      debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ")")
      reposAuds(nEditAudPtr, \nAbsStartAt)
      If \nAudState = #SCS_CUE_PAUSED
        \nAudState = #SCS_CUE_READY
        setCueState(nEditCuePtr)
      EndIf
    EndWith
  EndIf
  editSetDisplayButtonsM()
  gbCallEditUpdateDisplay = #True
  SAG(-1)
EndProcedure

Procedure WQM_btnEditStop_Click()
  PROCNAMEC()
  
  gqTimeNow = ElapsedMilliseconds()
  stopAud(nEditAudPtr, #True)
  SAG(-1)
  
  With aAud(nEditAudPtr)
    \nCuePosAtLoopStart = 0
    debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ")")
    reposAuds(nEditAudPtr, \nAbsStartAt)
  EndWith
  editSetDisplayButtonsM()
  gbCallEditUpdateDisplay = #True
EndProcedure

Procedure WQM_Form_Load()
  PROCNAMEC()
  Protected n, nGridHeight
  Protected sHexValue.s
  Protected nListIndex

  debugMsg(sProcName, #SCS_START)
  
  createfmEditQM()
  SUB_loadOrResizeHeaderFields("M", #True)
  With grWQM
    \nCntMidiOriginalHeight = GadgetHeight(WQM\cntMidi)
    \nCntRemDevOriginalHeight = GadgetHeight(WQM\cntRemDev)
    \nGrdRemDevOriginalHeight = GadgetHeight(WQM\grdRemDevGrdItem)
    \bInValidate = #False
    \nSelectedCtrlSendRow = -2
    \sSelectedLogicalDev = ""
    \nSelectedDevType = #SCS_DEVTYPE_NONE
  EndWith

  WQM_drawForm()
  
  With WQM
    ClearGadgetItems(\grdCtrlSends)
    For n = 0 To #SCS_MAX_CTRL_SEND
      AddGadgetItem(\grdCtrlSends, -1, Str(n+1) + Chr(10) + "")
    Next n
    autoFitGridCol(\grdCtrlSends,1) ; autofit 2nd column
    
    ; side toolbar
    debugMsg(sProcName, "calling makeTBS")
    WQM_makeTBS()
    
    setVisible(\lblMsgTypeEmphasis, #False)
  
    ClearGadgetItems(\cboMSParam1)
    AddGadgetItem(\cboMSParam1, -1, #SCS_BLANK_CBO_ENTRY)
    For n = 0 To 127
      sHexValue = Right("0" + Hex(n), 2)
      AddGadgetItem(\cboMSParam1, -1, Trim(Str(n) + "  (" + sHexValue + "H)"))
    Next n
  
    ClearGadgetItems(\cboMSParam2)
    addGadgetItemWithData(\cboMSParam2, #SCS_BLANK_CBO_ENTRY, -1) ; Changed 18Feb2022 11.9.1ab
  
    SGT(\txtQNumber, "")
    SGT(\txtQList, "")
    SGT(\txtQPath, "")
    
    ClearGadgetItems(\cboMFEntryMode)
    addGadgetItemWithData(\cboMFEntryMode, decodeEntryMode(#SCS_ENTRYMODE_ASCII), #SCS_ENTRYMODE_ASCII)
    addGadgetItemWithData(\cboMFEntryMode, decodeEntryMode(#SCS_ENTRYMODE_HEX), #SCS_ENTRYMODE_HEX)
    addGadgetItemWithData(\cboMFEntryMode, decodeEntryMode(#SCS_ENTRYMODE_ASCII_PLUS_CTL), #SCS_ENTRYMODE_ASCII_PLUS_CTL)
    
    ClearGadgetItems(\cboRSEntryMode)
    addGadgetItemWithData(\cboRSEntryMode, decodeEntryMode(#SCS_ENTRYMODE_ASCII), #SCS_ENTRYMODE_ASCII)
    addGadgetItemWithData(\cboRSEntryMode, decodeEntryMode(#SCS_ENTRYMODE_HEX), #SCS_ENTRYMODE_HEX)
    addGadgetItemWithData(\cboRSEntryMode, decodeEntryMode(#SCS_ENTRYMODE_ASCII_PLUS_CTL), #SCS_ENTRYMODE_ASCII_PLUS_CTL)
    
    ClearGadgetItems(\cboNWEntryMode)
    addGadgetItemWithData(\cboNWEntryMode, decodeEntryMode(#SCS_ENTRYMODE_ASCII), #SCS_ENTRYMODE_ASCII)
    addGadgetItemWithData(\cboNWEntryMode, decodeEntryMode(#SCS_ENTRYMODE_HEX), #SCS_ENTRYMODE_HEX)
    addGadgetItemWithData(\cboNWEntryMode, decodeEntryMode(#SCS_ENTRYMODE_ASCII_PLUS_CTL), #SCS_ENTRYMODE_ASCII_PLUS_CTL)
    addGadgetItemWithData(\cboNWEntryMode, decodeEntryMode(#SCS_ENTRYMODE_UTF8), #SCS_ENTRYMODE_UTF8) ; added 14Apr2020 11.8.2.3ar
    
    ClearGadgetItems(\cboMidiCapturePort)
    addGadgetItemWithData(\cboMidiCapturePort, #SCS_BLANK_CBO_ENTRY, -1)
    For n = 0 To (gnNumMidiInDevs-1)
      addGadgetItemWithData(\cboMidiCapturePort, gaMidiInDevice(n)\sName, n)
    Next n
    nListIndex = indexForComboBoxData(\cboMidiCapturePort, gnMidiCapturePhysicalDevPtr, 0)
    SGS(\cboMidiCapturePort, nListIndex)
    WQM_fcMidiCapturePort()
    
    ClearGadgetItems(\cboNRPNCapturePort)
    addGadgetItemWithData(\cboNRPNCapturePort, #SCS_BLANK_CBO_ENTRY, -1)
    For n = 0 To (gnNumMidiInDevs-1)
      addGadgetItemWithData(\cboNRPNCapturePort, gaMidiInDevice(n)\sName, n)
    Next n
    nListIndex = indexForComboBoxData(\cboNRPNCapturePort, gnMidiCapturePhysicalDevPtr, 0)
    SGS(\cboNRPNCapturePort, nListIndex)
    WQM_fcNRPNCapturePort()
    
  EndWith

EndProcedure

Procedure WQM_grdCtrlSends_Change()
  PROCNAMECS(nEditSubPtr)
  Protected bRowCleared
  Protected u
  Protected nOldRow, nNewRow
  Protected nListIndex, nMsgType
  Protected n, bIgnoreLastMsgType
  Protected bOSCServer, nCtrlNetworkRemoteDev
  Protected m
  Protected nCtrlSendIndex
  Protected bValidationOK
  Protected nWorkDevType

  debugMsg(sProcName, #SCS_START + ", currentRow=" + GGS(WQM\grdCtrlSends))
  
  nNewRow = GGS(WQM\grdCtrlSends)
  nOldRow = grWQM\nSelectedCtrlSendRow
  ; debugMsg(sProcName, "nNewRow=" + nNewRow + ", nOldRow=" + nOldRow)
  If nNewRow = nOldRow
    ProcedureReturn
  EndIf
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQM_valGadget(gnValidateGadgetNo)
    If bValidationOK = #False
      If nOldRow >= 0
        SGS(WQM\grdCtrlSends, nOldRow)
      EndIf
      ProcedureReturn
    EndIf
  EndIf

  If nOldRow >= 0
    bRowCleared = #False
    u = preChangeSubL(bRowCleared, "Clear Control Message", -5, #SCS_UNDO_ACTION_CHANGE, nOldRow)
    bRowCleared = clearCtrlSendItemIfNotBuilt(nOldRow)
    ; debugMsg(sProcName, "clearCtrlSendItemIfNotBuilt(" + nOldRow + ") returned " + StrB(bRowCleared))
    ; note: if clearCtrlSendItemIfNotBuilt returned false to bRowCleared then no change will be recorded
    postChangeSubL(u, bRowCleared, -5, nOldRow)
    If bRowCleared = #False
      If valCtrlSendItem(nOldRow) = #False
        debugMsg(sProcName, "valCtrlSendItem(" + nOldRow + ") returned #False")
        ; validation failed so reset current row and exit now
        If nNewRow <> nOldRow
          ; debugMsg(sProcName, "nNewRow=" + nNewRow + ", nOldRow=" + nOldRow)
          ; debugMsg(sProcName, "issuing SGS(WQM\grdCtrlSends, " + nOldRow + ")")
          SGS(WQM\grdCtrlSends, nOldRow)
        EndIf
        ; debugMsg(sProcName, "exiting")
        ProcedureReturn
      EndIf
    EndIf
  EndIf

  If (nNewRow >= 0) And (nEditSubPtr >= 0)
    grWQM\nSelectedCtrlSendRow = nNewRow
    gbNewCtrlSendItem(nNewRow) = #False
    With aSub(nEditSubPtr)\aCtrlSend[nNewRow]
      If Len(Trim(\sDisplayInfo)) = 0
        debugMsg(sProcName, "New item")
        ; new entry
        u = preChangeSubL(#True, "Add Control Message", -5, #SCS_UNDO_ACTION_CHANGE, nNewRow)
        aSub(nEditSubPtr)\aCtrlSend[nNewRow] = grSubDef\aCtrlSend[nNewRow]   ; start with default values
        \nDevType = grEditMem\nLastCtrlSendDevType
        \sCSLogicalDev = grEditMem\sLastCtrlSendLogicalDev
        \nRemDevId = CSRD_GetRemDevIdForLogicalDev(\nDevType, \sCSLogicalDev)
        debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nNewRow + "]\sCSLogicalDev=" + \sCSLogicalDev + ", \nRemDevId=" + \nRemDevId)
        \nRemDevMuteAction = grEditMem\nLastRemDevMuteAction
        nListIndex = indexForComboBoxRow(WQM\cboLogicalDev, \sCSLogicalDev, 0)
        SGS(WQM\cboLogicalDev, nListIndex)
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nNewRow + "]\sRemDevMsgType=" + \sRemDevMsgType + ", \nRemDevMsgType=" + \nRemDevMsgType + ", \nMSMsgType=" + \nMSMsgType)
        ; WQM_cboLogicalDev_Click(#False)
        WQM_cboLogicalDev_Click(#True)
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nNewRow + "]\sRemDevMsgType=" + \sRemDevMsgType + ", \nRemDevMsgType=" + \nRemDevMsgType + ", \nMSMsgType=" + \nMSMsgType)
        nWorkDevType = \nDevType
        If nWorkDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork And 1=2
          nWorkDevType = #SCS_DEVTYPE_CS_MIDI_OUT
        EndIf
        debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", nWorkDevType=" + decodeDevType(nWorkDevType))
        Select nWorkDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
            ;{
            \bMIDISend = #True
            If grLicInfo\bCSRDAvailable
              WQM_fcCtrlMidiRemoteDev(#True)
            EndIf
            bIgnoreLastMsgType = #False
            ; debugMsg(sProcName, "grEditMem\nLastMsgType=" + grEditMem\nLastMsgType)
            If grEditMem\nLastMsgType = #SCS_MSGTYPE_FILE
              ; only one MIDI file allowed per ctrl send sub-cue, so don't default to MIDI file if there is currently a MIDI file entry in this sub-cue
              For n = 0 To #SCS_MAX_CTRL_SEND
                If n <> nNewRow
                  If aSub(nEditSubPtr)\aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FILE
                    bIgnoreLastMsgType = #True
                    ; debugMsg(sProcName, "bIgnoreLastMsgType=#True") 
                    Break
                  EndIf
                EndIf
              Next n
            ElseIf grEditMem\nLastMsgType > #SCS_MSGTYPE_DUMMY_LAST
              bIgnoreLastMsgType = #True
            EndIf
            If bIgnoreLastMsgType = #False
              ; If \nMSMsgType = #SCS_MSGTYPE_NONE And \nRemDevMsgType = 0
                If grEditMem\nLastMsgType <= #SCS_MSGTYPE_DUMMY_LAST
                  \nMSMsgType = grEditMem\nLastMsgType
                Else
                  \nRemDevMsgType = grEditMem\nLastRemDevMsgType
                EndIf
              ; EndIf
            EndIf
            ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nNewRow + "]\sRemDevMsgType=" + \sRemDevMsgType + ", \nRemDevMsgType=" + \nRemDevMsgType + ", \nMSMsgType=" + \nMSMsgType)
            If \nRemDevMsgType > 0
              \sCSItemDesc = grEditMem\aLastMsg(\nRemDevMsgType)\sLastMSItemDesc
            ElseIf \nMSMsgType > 0
              \sCSItemDesc = grEditMem\aLastMsg(\nMSMsgType)\sLastMSItemDesc
            Else
              \sCSItemDesc = ""
            EndIf
            SGT(WQM\txtMSItemDesc, \sCSItemDesc)
            nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
            ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nNewRow + "]\sRemDevMsgType=" + \sRemDevMsgType + ", \nRemDevMsgType=" + decodeMsgType(\nRemDevMsgType) + ", \nMSMsgType=" + decodeMsgType(\nMSMsgType) + ", nMsgType=" + decodeMsgType(nMsgType))
            Select nMsgType
              Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128, #SCS_MSGTYPE_CC
                \nMSChannel = grEditMem\aLastMsg(nMsgType)\nLastMSChannel
                
              Case #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF
                ; added 28Feb2020 11.8.2.2aw so that last note and velocity are used
                \nMSChannel = grEditMem\aLastMsg(nMsgType)\nLastMSChannel
                \nMSParam1 = grEditMem\aLastMsg(nMsgType)\nLastMSParam1
                \nMSParam2 = grEditMem\aLastMsg(nMsgType)\nLastMSParam2
                ; end added 28Feb2020 11.8.2.2aw
                
              Case #SCS_MSGTYPE_MSC
                \nMSChannel = grEditMem\aLastMsg(nMsgType)\nLastMSChannel
                \nMSParam1 = grEditMem\aLastMsg(nMsgType)\nLastMSParam1
                \nMSParam2 = grEditMem\aLastMsg(nMsgType)\nLastMSParam2
                If Len(grEditMem\sLastMSQNumber) > 0
                  If IsInteger(grEditMem\sLastMSQNumber)
                    \sMSQNumber = Str(Val(grEditMem\sLastMSQNumber) + 1)
                    grEditMem\sLastMSQNumber = \sMSQNumber  ; added 3Dec2015 11.4.1.2q to fix "Automatic Q numbers in control send cue" reported in bug reports forum by Brian Larsen
                  EndIf
                EndIf
                
              Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
                \nMSChannel = grEditMem\aLastMsg(nMsgType)\nLastMSChannel
                \nMSParam1 = grEditMem\aLastMsg(nMsgType)\nLastMSParam1
                \nMSParam2 = grEditMem\aLastMsg(nMsgType)\nLastMSParam2
                \nMSParam3 = grEditMem\aLastMsg(nMsgType)\nLastMSParam3
                \nMSParam4 = grEditMem\aLastMsg(nMsgType)\nLastMSParam4
                \sMSParam1Info = grEditMem\aLastMsg(nMsgType)\sLastMSParam1Info
                \sMSParam2Info = grEditMem\aLastMsg(nMsgType)\sLastMSParam2Info
                \sMSParam3Info = grEditMem\aLastMsg(nMsgType)\sLastMSParam3Info
                \sMSParam4Info = grEditMem\aLastMsg(nMsgType)\sLastMSParam4Info
                ; debugMsg(sProcName, "\nMSParam3=" + \nMSParam3 + ", \sMSParam3Info=" + \sMSParam3Info)
                
              Case #SCS_MSGTYPE_FREE
                \sEnteredString = ""
                
              Case #SCS_MSGTYPE_FILE
                ; no additional action required
                
            EndSelect
            ;}
          Case #SCS_DEVTYPE_CS_RS232_OUT   ; #SCS_DEVTYPE_CS_RS232_OUT
            ;{
            \bRS232Send = #True
            \sCSItemDesc = grEditMem\sLastRSItemDesc
            SGT(WQM\txtRSItemDesc, \sCSItemDesc)
            \nEntryMode = grEditMem\nLastEntryMode
            \sEnteredString = ""
            \bAddCR = grEditMem\bLastAddCR
            \bAddLF = grEditMem\bLastAddLF
            SGS(WQM\cboRSEntryMode, \nEntryMode)
            WQM_fcEntryMode()
            setOwnState(WQM\chkRSAddCR, \bAddCR)
            setOwnState(WQM\chkRSAddLF, \bAddLF)
            SGT(WQM\txtRSEnteredString, \sEnteredString)
            ;}
          Case #SCS_DEVTYPE_CS_NETWORK_OUT  ; #SCS_DEVTYPE_CS_NETWORK_OUT
            ;{
            \bNetworkSend = #True
            \sCSItemDesc = grEditMem\sLastNWItemDesc
            SGT(WQM\txtNWItemDesc, \sCSItemDesc)
            If \nCSPhysicalDevPtr >= 0
              bOSCServer = gaNetworkControl(\nCSPhysicalDevPtr)\bOSCServer
              nCtrlNetworkRemoteDev = gaNetworkControl(\nCSPhysicalDevPtr)\nCtrlNetworkRemoteDev
            Else
              bOSCServer = #False
              nCtrlNetworkRemoteDev = -1
            EndIf
            debugMsg(sProcName, "\nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr + ", nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev) + ", bOSCServer=" + strB(bOSCServer))
            setComboBoxByData(WQM\cboCtrlNetworkRemoteDev, nCtrlNetworkRemoteDev)
            If nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32TC
              \bIsOSC = #True
              \sEnteredString = ""
              nListIndex = setComboBoxByData(WQM\cboOSCCmdType, \nOSCCmdType)
              If nListIndex < 0
                \nOSCCmdType = grCtrlSendDef\nOSCCmdType
              EndIf
debugMsg0(sProcName, "calling WQM_fcOSCCmdType()")
              WQM_fcOSCCmdType()
              setVisible(WQM\cntOther, #False)
              setVisible(WQM\cntOSC, #True)
            ElseIf bOSCServer
              \bIsOSC = #True
              If nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32 Or nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                \bOSCReloadNamesGoCue = grEditMem\bLastOSCReloadNamesGoCue
                \bOSCReloadNamesGoScene = grEditMem\bLastOSCReloadNamesGoScene
                \bOSCReloadNamesGoSnippet = grEditMem\bLastOSCReloadNamesGoSnippet
              EndIf
              \nOSCCmdType = CSRD_GetOSCCmdTypeForRemDevMsgType(\nRemDevMsgType)
              ; debugMsg0(sProcName, "CSRD_GetOSCCmdTypeForRemDevMsgType(" + CSRD_DecodeRemDevMsgType(\nRemDevMsgType) + ") returned " + decodeOSCCmdType(\nOSCCmdType))
              If \nOSCCmdType = #SCS_CS_OSC_NOT_SET
                \nOSCCmdType = grEditMem\nLastOSCCmdType
              EndIf
              nListIndex = setComboBoxByData(WQM\cboOSCCmdType, \nOSCCmdType)
              If nListIndex < 0
                \nOSCCmdType = grCtrlSendDef\nOSCCmdType
              EndIf
              ; debugMsg0(sProcName, "calling WQM_fcOSCCmdType()")
              WQM_fcOSCCmdType()
              setVisible(WQM\cntOther, #False)
              setVisible(WQM\cntOSC, #True)
            Else
              \bIsOSC = #False
              \sEnteredString = ""
              WQM_fcCtrlNetworkRemoteDev(#True)
              SGS(WQM\cboNWEntryMode, \nEntryMode)
              WQM_fcEntryMode()
              setOwnState(WQM\chkNWAddCR, \bAddCR)
              setOwnState(WQM\chkNWAddLF, \bAddLF)
              SGT(WQM\txtNWEnteredString, \sEnteredString)
              setVisible(WQM\cntOSC, #False)
              setVisible(WQM\cntOther, #True)
            EndIf
            ;}
          Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
            ;{
            \bHTTPSend = #True
            \sCSItemDesc = grEditMem\sLastHTItemDesc
            SGT(WQM\txtHTItemDesc, \sCSItemDesc)
            \sEnteredString = ""
            SGT(WQM\txtHTEnteredString, \sEnteredString)
            ;}
        EndSelect
        buildCtrlSendMessage()
        buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nNewRow)
        updateCtrlSendGrid(nNewRow, #True)
        gaCtrlSendItemB4Change(nNewRow) = aSub(nEditSubPtr)\aCtrlSend[nNewRow]
        debugMsg(sProcName, "aSub(" + nEditSubPtr + ")\aCtrlSend[" + Str(nNewRow) + "]\sCSLogicalDev=" + \sCSLogicalDev + ", gaCtrlSendItemB4Change(" + nNewRow + ")\sCSLogicalDev=" + gaCtrlSendItemB4Change(nNewRow)\sCSLogicalDev)
        gbNewCtrlSendItem(nNewRow) = #True
        postChangeSubL(u, #False, -5, nNewRow)
        
      Else
        debugMsg(sProcName, "Existing item")
;         debugMsg(sProcName, "calling WQM_populateCboMsgTypeIfReqd(" + nNewRow + ")")
;         WQM_populateCboMsgTypeIfReqd(nNewRow)
        
      EndIf
    EndWith
    
    debugMsg(sProcName, "calling WQM_populateCboMsgTypeIfReqd(" + nNewRow + ")")
    WQM_populateCboMsgTypeIfReqd(nNewRow)
    debugMsg(sProcName, "calling WQM_displayCtrlSendItem(" + nEditSubPtr + ")")
    WQM_displayCtrlSendItem(nEditSubPtr)
    
    WQM_setTBSButtons(nNewRow)
  EndIf

  WQM_setCtrlSendTestButtons()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_imgButtonTBS_Click(nButtonId)
  PROCNAME(#PB_Compiler_Procedure + "(" + nButtonId + ")")
  Protected nCurrItemIndex, nNewItemIndex.w
  Protected u, sUndoDesc.s
  Protected rCtrlSendItem.tyCtrlSend
  Protected bMyNewCtrlSendItem
  Protected n
  Protected nGoToRow

  debugMsg(sProcName, #SCS_START)
  ; debugMsg(sProcName, #SCS_START + ", imgButtonTBS(" + Index + ").tag=" + Str(imgButtonTBS(Index))\tag)

  nCurrItemIndex = GGS(WQM\grdCtrlSends)
  If nEditSubPtr < 0 Or nCurrItemIndex < 0 Or nCurrItemIndex > #SCS_MAX_CTRL_SEND
    ; none of the above *should* happen
    ProcedureReturn
  EndIf
  
  Select nButtonId
    Case #SCS_STANDARD_BTN_MOVE_UP, #SCS_STANDARD_BTN_MOVE_DOWN, #SCS_STANDARD_BTN_PLUS
      If valCtrlSendItem(nCurrItemIndex) = #False
        ProcedureReturn
      EndIf
  EndSelect

  nGoToRow = 0
  
  With aSub(nEditSubPtr)
    
    Select nButtonId
        
      Case #SCS_STANDARD_BTN_MOVE_UP  ; move row up
        sUndoDesc = "Move Control Message"
        u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
        
        rCtrlSendItem = \aCtrlSend[nCurrItemIndex]
        \aCtrlSend[nCurrItemIndex] = \aCtrlSend[nCurrItemIndex-1]
        \aCtrlSend[nCurrItemIndex-1] = rCtrlSendItem
        
        rCtrlSendItem = gaCtrlSendItemB4Change(nCurrItemIndex)
        gaCtrlSendItemB4Change(nCurrItemIndex) = gaCtrlSendItemB4Change(nCurrItemIndex-1)
        gaCtrlSendItemB4Change(nCurrItemIndex-1) = rCtrlSendItem
        
        bMyNewCtrlSendItem = gbNewCtrlSendItem(nCurrItemIndex)
        gbNewCtrlSendItem(nCurrItemIndex) = gbNewCtrlSendItem(nCurrItemIndex-1)
        gbNewCtrlSendItem(nCurrItemIndex-1) = bMyNewCtrlSendItem
        
        nNewItemIndex = nCurrItemIndex - 1
        nGoToRow = GGS(WQM\grdCtrlSends) - 1
        
      Case #SCS_STANDARD_BTN_MOVE_DOWN  ; move row down
        sUndoDesc = "Move Control Message"
        u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
        
        rCtrlSendItem = \aCtrlSend[nCurrItemIndex]
        \aCtrlSend[nCurrItemIndex] = \aCtrlSend[nCurrItemIndex+1]
        \aCtrlSend[nCurrItemIndex+1] = rCtrlSendItem
        
        rCtrlSendItem = gaCtrlSendItemB4Change(nCurrItemIndex)
        gaCtrlSendItemB4Change(nCurrItemIndex) = gaCtrlSendItemB4Change(nCurrItemIndex+1)
        gaCtrlSendItemB4Change(nCurrItemIndex+1) = rCtrlSendItem
        
        bMyNewCtrlSendItem = gbNewCtrlSendItem(nCurrItemIndex)
        gbNewCtrlSendItem(nCurrItemIndex) = gbNewCtrlSendItem(nCurrItemIndex+1)
        gbNewCtrlSendItem(nCurrItemIndex+1) = bMyNewCtrlSendItem
        
        nNewItemIndex = nCurrItemIndex + 1
        nGoToRow = GGS(WQM\grdCtrlSends) + 1
        
      Case #SCS_STANDARD_BTN_PLUS  ; insert row
        sUndoDesc = "Insert Control Message"
        u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
        ; move this and following messages down one position
        For n = #SCS_MAX_CTRL_SEND To (nCurrItemIndex + 1) Step -1
          \aCtrlSend[n] = \aCtrlSend[n-1]
          gaCtrlSendItemB4Change(n) = gaCtrlSendItemB4Change(n-1)
          gbNewCtrlSendItem(n) = gbNewCtrlSendItem(n-1)
        Next n
        ; clear this message
        \aCtrlSend[nCurrItemIndex] = grSubDef\aCtrlSend[nCurrItemIndex]
        gaCtrlSendItemB4Change(nCurrItemIndex) = grSubDef\aCtrlSend[nCurrItemIndex]
        gbNewCtrlSendItem(nCurrItemIndex) = #False
        nGoToRow = nCurrItemIndex
        
      Case #SCS_STANDARD_BTN_MINUS  ; delete row
        sUndoDesc = "Remove Control Message"
        u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
        ; move following messages up one position
        For n = nCurrItemIndex To (#SCS_MAX_CTRL_SEND - 1)
          \aCtrlSend[n] = \aCtrlSend[n+1]
          gaCtrlSendItemB4Change(n) = gaCtrlSendItemB4Change(n+1)
          gbNewCtrlSendItem(n) = gbNewCtrlSendItem(n+1)
        Next n
        ; clear last message
        n = #SCS_MAX_CTRL_SEND
        \aCtrlSend[n] = grSubDef\aCtrlSend[n]
        gbNewCtrlSendItem(n) = #False
        nGoToRow = 0
        For n = nCurrItemIndex To 0 Step -1
          If Len(\aCtrlSend[n]\sDisplayInfo) > 0
            nGoToRow = n
            Break
          EndIf
        Next
        
    EndSelect
    
    For n = 0 To #SCS_MAX_CTRL_SEND
      SetGadgetItemText(WQM\grdCtrlSends, n, aSub(nEditSubPtr)\aCtrlSend[n]\sDisplayInfo, #SCS_GRDCTRLSENDS_INFO)
debugMsg(sProcName, "calling SetGadgetItemText(WQM\grdCtrlSends, " + n + ", " + #DQUOTE$ + aSub(nEditSubPtr)\aCtrlSend[n]\sDisplayInfo + #DQUOTE$ + ", #SCS_GRDCTRLSENDS_INFO)")
    Next n
    
    If nGoToRow >= 0 And nGoToRow < CountGadgetItems(WQM\grdCtrlSends)
      grWQM\nSelectedCtrlSendRow = -1  ; validation of 'old row' already done at start of this procedure, but force a difference so RHS gets re-populated
      SGS(WQM\grdCtrlSends, nGoToRow)
      WQM_grdCtrlSends_Change()
    EndIf
    
    debugMsg(sProcName, "calling WQM_displayCtrlSendItem(" + nEditSubPtr + ")")
    WQM_displayCtrlSendItem(nEditSubPtr)
    n = grWQM\nSelectedCtrlSendRow
    WQM_setTBSButtons(n)
    WQM_setCtrlSendTestButtons()
    
    postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", imgButtonTBS(" + Index + ").tag=" + Str(imgButtonTBS(Index))\tag)
  
EndProcedure

Procedure WQM_txtQList_Change()
  Protected u
  Protected n

  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sMSQList, GGT(WQM\lblQList), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSQList = Trim(GGT(WQM\txtQList))
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sMSQList, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtQList_Validate()
  markValidationOK(WQM\txtQList)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtQNumber_Change()
  PROCNAMEC()
  Protected u
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sMSQNumber, GGT(WQM\lblQNumber), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSQNumber = Trim(GGT(WQM\txtQNumber))
    grEditMem\sLastMSQNumber = \sMSQNumber
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sMSQNumber, -5, n)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_txtQNumber_Validate()
  markValidationOK(WQM\txtQNumber)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtQPath_Change()
  Protected u
  Protected n

  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sMSQPath, GGT(WQM\lblQPath), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sMSQPath = Trim(GGT(WQM\txtQPath))
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sMSQPath, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtQPath_Validate()
  markValidationOK(WQM\txtQPath)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtMFEnteredString_Change()
  PROCNAMECS(nEditSubPtr)
  Protected u, n
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sEnteredString, GGT(WQM\lblMFEnteredString), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sEnteredString = Trim(GGT(WQM\txtMFEnteredString))
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sEnteredString, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtMFEnteredString_Validate()
  PROCNAMECS(nEditSubPtr)
  
  ; WQM_txtMFEnteredString_Change()
  markValidationOK(WQM\txtMFEnteredString)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtRSEnteredString_Change()
  PROCNAMECS(nEditSubPtr)
  Protected u, n
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sEnteredString, GGT(WQM\lblRSEnteredString), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sEnteredString = Trim(GGT(WQM\txtRSEnteredString))
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sEnteredString, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtRSEnteredString_Validate()
  PROCNAMECS(nEditSubPtr)
  
  markValidationOK(WQM\txtRSEnteredString)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtNWEnteredString_Change()
  PROCNAMECS(nEditSubPtr)
  Protected u, n
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sEnteredString, GGT(WQM\lblNWEnteredString), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sEnteredString = Trim(GGT(WQM\txtNWEnteredString))
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sEnteredString, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtNWEnteredString_Validate()
  PROCNAMECS(nEditSubPtr)
  
  markValidationOK(WQM\txtNWEnteredString)
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtOSCEnteredString_Change()
  PROCNAMECS(nEditSubPtr)
  Protected bResult
  Protected u, n
  
  debugMsg(sProcName, "grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    bResult = unpackOSCEnteredString(GGT(WQM\txtOSCEnteredString))
    debugMsg(sProcName, "unpackOSCEnteredString(GGT(WQM\txtOSCEnteredString)) returned " + strB(bResult))
    If bResult ; Test added 20Jun2022 11.9.3aa
      u = preChangeSubS(\sEnteredString, GGT(WQM\lblOSCEnteredString), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sEnteredString = Trim(GGT(WQM\txtOSCEnteredString))
      \sOSCItemString = \sEnteredString
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubS(u, \sEnteredString, -5, n)
    EndIf
  EndWith
EndProcedure

Procedure WQM_txtOSCEnteredString_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected bResult
  Protected u, n
  
  debugMsg(sProcName, #SCS_START)
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    bResult = unpackOSCEnteredString(GGT(WQM\txtOSCEnteredString))
    debugMsg(sProcName, "unpackOSCEnteredString(GGT(WQM\txtOSCEnteredString)) returned " + strB(bResult))
    If bResult
      u = preChangeSubS(\sEnteredString, GGT(WQM\lblOSCEnteredString), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \sEnteredString = GGT(WQM\txtOSCEnteredString)
      \sOSCItemString = \sEnteredString
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
      updateCtrlSendGrid(n, #True)
      postChangeSubS(u, \sEnteredString, -5, n)
      markValidationOK(WQM\txtOSCEnteredString)
    Else
      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "OSCFFInvalid", "'" + GGT(WQM\txtOSCEnteredString) + "'"), #PB_MessageRequester_Error) ; Changed 20Jun2022 11.9.3aa
      grWQM\bInValidate = #False
      ProcedureReturn #False
    EndIf
  EndWith
  
  grWQM\bInValidate = #False
  ProcedureReturn bResult
EndProcedure

Procedure WQM_txtHTEnteredString_Change()
  PROCNAMECS(nEditSubPtr)
  Protected u, n
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sEnteredString, GGT(WQM\lblHTEnteredString), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sEnteredString = Trim(GGT(WQM\txtHTEnteredString))
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sEnteredString, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtHTEnteredString_Validate()
  PROCNAMECS(nEditSubPtr)
  
  markValidationOK(WQM\txtHTEnteredString)
  ProcedureReturn #True
EndProcedure

Procedure WQM_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnValidateGadgetNo <> 0
    ; Debug sProcName + ": calling WQM_valGadget(" + getGadgetName(gnValidateGadgetNo) + ")"
    bValidationOK = WQM_valGadget(gnValidateGadgetNo)
  EndIf
  
  ; debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WQM_makeTBS()
  PROCNAMEC()
  Protected n

  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To 3
    setEnabled(WQM\imgButtonTBS[n], #True)
  Next n

EndProcedure

Procedure WQM_enableTBSButton(nButtonType, bEnable, sToolTipText.s = "")
  PROCNAMEC()
  Protected nIndex
  
  nIndex = WQM_getTBSIndex(nButtonType)
  
  setEnabled(WQM\imgButtonTBS[nIndex], bEnable)
  If Len(sToolTipText) > 0
    scsToolTip(WQM\imgButtonTBS[nIndex], sToolTipText)
  EndIf
  
EndProcedure

Procedure WQM_getTBSIndex(nButtonType)
  Protected n, nIndex
  nIndex = -1
  For n = 0 To 3
    If getButtonType(WQM\imgButtonTBS[n]) = nButtonType
      nIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nIndex
EndProcedure

Procedure WQM_setTBSButtons(Index)
  PROCNAMEC()
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableInsMsg, sToolTipInsMsg.s
  Protected bEnableDelMsg, sToolTipDelMsg.s
  Protected nMsgNo, sDisplayInfo.s, bDisplayInfoPresent
  Protected nLastMsg
  Protected n

  If gbInDisplayCtrlSendItem
    ProcedureReturn
  EndIf

  nMsgNo = Index
  sDisplayInfo = Trim(aSub(nEditSubPtr)\aCtrlSend[Index]\sDisplayInfo)
  If Len(sDisplayInfo) > 0
    bDisplayInfoPresent = #True
  Else
    sDisplayInfo = "#" + Str((nMsgNo) + 1)
    bDisplayInfoPresent = #False
  EndIf

  For n = 0 To #SCS_MAX_CTRL_SEND
    If Len(Trim(aSub(nEditSubPtr)\aCtrlSend[n]\sDisplayInfo)) > 0
      nLastMsg = n
    EndIf
  Next n

  If (nMsgNo > 0) And (nMsgNo <= nLastMsg)
    bEnableMoveUp = #True
    sToolTipMoveUp = "Move up: " + sDisplayInfo
  EndIf
  If nMsgNo < nLastMsg
    bEnableMoveDown = #True
    sToolTipMoveDown = "Move down: " + sDisplayInfo
  EndIf
  If bDisplayInfoPresent
    If (nLastMsg < #SCS_MAX_CTRL_SEND)
      bEnableInsMsg = #True
      sToolTipInsMsg = "Insert a control message before: " + sDisplayInfo
    EndIf
  EndIf
  If (nLastMsg > 0) And (nMsgNo <= nLastMsg)
    bEnableDelMsg = #True
    sToolTipDelMsg = "Remove: " + sDisplayInfo
  EndIf

  WQM_enableTBSButton(#SCS_STANDARD_BTN_MOVE_UP, bEnableMoveUp, sToolTipMoveUp)
  WQM_enableTBSButton(#SCS_STANDARD_BTN_MOVE_DOWN, bEnableMoveDown, sToolTipMoveDown)
  WQM_enableTBSButton(#SCS_STANDARD_BTN_PLUS, bEnableInsMsg, sToolTipInsMsg)
  WQM_enableTBSButton(#SCS_STANDARD_BTN_MINUS, bEnableDelMsg, sToolTipDelMsg)

EndProcedure

Procedure WQM_setCtrlSendTestButtons()
  ; PROCNAMECS(nEditSubPtr)
  Protected n
  Protected bEnableSelected, bEnableAll
  Protected bMidiFile, nMidiFileLength

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      For n = 0 To #SCS_MAX_CTRL_SEND
        ; debugMsg(sProcName, "\aCtrlSend[" + n + "]\sCSLogicalDev=" + \aCtrlSend[n]\sCSLogicalDev + ", \aCtrlSend[" + n + "]\nMsgType=" + decodeMsgType(\aCtrlSend[n]\nMsgType))
        If Len(Trim(\aCtrlSend[n]\sCSLogicalDev)) > 0
          bEnableAll = #True
          If n = grWQM\nSelectedCtrlSendRow
            bEnableSelected = #True
          EndIf
          If \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FILE
            bMidiFile = #True
          EndIf
        EndIf
      Next n
      
      If bMidiFile
        If \nFirstAudIndex >= 0
          If aAud(\nFirstAudIndex)\sFileName
            nMidiFileLength = aAud(\nFirstAudIndex)\nCueDuration
          EndIf
        EndIf
      EndIf
      
    EndWith
    
  EndIf
  
  setEnabled(WQM\btnTestCtrlSend[0], bEnableSelected)
  setEnabled(WQM\btnTestCtrlSend[1], bEnableAll)
  
  ; debugMsg(sProcName, "bMidiFile=" + strB(bMidiFile) + ", nMidiFileLength=" + nMidiFileLength)
  If nMidiFileLength > 0
    SLD_setValue(WQM\sldProgress, 0)
    SLD_setMax(WQM\sldProgress, (nMidiFileLength-1))
    editSetDisplayButtonsM()
    setVisible(WQM\cntTestMidiFile, #True)
  Else
    setVisible(WQM\cntTestMidiFile, #False)
  EndIf
  
EndProcedure

Procedure WQM_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQM
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQM)
        
        ; detail gadgets
      Case \cboMSChannel
        ETVAL2(WQM_cboMSChannel_Validate())
        
      Case \cboMSMacro
        ETVAL2(WQM_cboMSMacro_Validate())
        
      Case \cboMSParam1
        ETVAL2(WQM_cboMSParam1_Validate())
        
      Case \cboMSParam2
        ETVAL2(WQM_cboMSParam2_Validate())
        
      Case \cboMSParam3
        ETVAL2(WQM_cboMSParam3_Validate())
        
      Case \cboMSParam4
        ETVAL2(WQM_cboMSParam4_Validate())
        
      Case \cboRemDevCboItem ; Added 3Sep2022 11.9.5.1ac
        ETVAL2(WQM_cboRemDevCboItem_Click())
        
      Case \cboRSEntryMode ; Added 3Sep2022 11.9.5.1ac
        ETVAL2(WQM_cboRSEntryMode_Click())
        
      Case \txtEndAt
        ETVAL2(WQM_txtEndAt_Validate())
        
      Case \txtHTEnteredString
        ETVAL2(WQM_txtHTEnteredString_Validate())
        
      Case \txtHTItemDesc, \txtMSItemDesc, \txtNWItemDesc, \txtRSItemDesc
        ETVAL2(WQM_txtItemDesc_Validate())
        
      Case \txtMFEnteredString
        ETVAL2(WQM_txtMFEnteredString_Validate())
        
      Case \txtMSParam1Info
        ETVAL2(WQM_txtMSParam1Info_Validate())
        
      Case \txtMSParam2Info
        ETVAL2(WQM_txtMSParam2Info_Validate())
        
      Case \txtMSParam3Info
        ETVAL2(WQM_txtMSParam3Info_Validate())
        
      Case \txtMSParam4Info
        ETVAL2(WQM_txtMSParam4Info_Validate())
        
      Case \txtNWEnteredString
        ETVAL2(WQM_txtNWEnteredString_Validate())
        
      Case \txtOSCEnteredString
        ETVAL2(WQM_txtOSCEnteredString_Validate())
        
      Case \txtOSCItemString
        ETVAL2(WQM_txtOSCItemString_Validate())
        
      Case \txtQList
        ETVAL2(WQM_txtQList_Validate())
        
      Case \txtQNumber
        ETVAL2(WQM_txtQNumber_Validate())
        
      Case \txtQPath
        ETVAL2(WQM_txtQPath_Validate())
        
      Case \txtRemDevDBLevel
        ETVAL2(WQM_txtRemDevDBLevel_Validate())
        
      Case \txtRSEnteredString
        ETVAL2(WQM_txtRSEnteredString_Validate())
        
      Case \txtStartAt
        ETVAL2(WQM_txtStartAt_Validate())
        
      Default
        bFound = #False
        
    EndSelect
  EndWith
  
  If bFound
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      debugMsg(sProcName, "returning #False")
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      debugMsg(sProcName, "returning #True (a)")
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    debugMsg(sProcName, "returning #True (b)")
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WQM_EventHandler()
  PROCNAMEC()
  Protected bFound
  
  With WQM
    
    If gnEventSliderNo > 0
      ; debugMsg(sProcName, "gnSliderEvent=" + gnSliderEvent + ", gnEventSliderNo=" + gnEventSliderNo)
      Select gnEventSliderNo
        Case \sldProgress
          ; no events currently processed for the subtype M progress slider
          bFound = #True
        Case \sldRemDevFader
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQM_fcSldRemDevFader()
          EndSelect
      EndSelect
      If bFound
        ProcedureReturn
      EndIf
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        If gnEventButtonId <> 0
          ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId)
          Select gnEventButtonId
              
            Case #SCS_STANDARD_BTN_PAUSE
              WQM_btnEditPause_Click()
              
            Case #SCS_STANDARD_BTN_PLAY
              WQM_btnEditPlay_Click()
              
            Case #SCS_STANDARD_BTN_STOP
              WQM_btnEditStop_Click()
              
            Case #SCS_STANDARD_BTN_REWIND
              WQM_btnEditRewind_Click()
              
            Case #SCS_STANDARD_BTN_MOVE_UP, #SCS_STANDARD_BTN_MOVE_DOWN, #SCS_STANDARD_BTN_PLUS, #SCS_STANDARD_BTN_MINUS
              WQM_imgButtonTBS_Click(gnEventButtonId)
              
          EndSelect
          
        Else
          
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQM)
              
              ; detail gadgets in alphabetical order
              
            Case \btnBrowse
              BTNCLICK(WQM_btnBrowse_Click())
              
            Case \btnEditScribbleStrip
              WQM_btnEditScribbleStrip_Click()
              
            Case \btnMidiCapture
              BTNCLICK(WQM_btnMidiCapture_Click())
              
            Case \btnNRPNCapture
              BTNCLICK(WQM_btnNRPNCapture_Click())
              
            Case \btnNRPNSave
              BTNCLICK(WQM_btnNRPNSave_Click())
              
            Case \btnTestCtrlSend[0]
              BTNCLICK(WQM_btnTestCtrlSend_Click(gnEventGadgetArrayIndex))
              
            Case \btnX32Capture
              WQM_btnX32Capture_Click()
            
            Case \cboLogicalDev
              CBOCHG(WQM_cboLogicalDev_Click())
              
            Case \cboMidiCapturePort
              CBOCHG(WQM_cboMidiCapturePort_Click())
              
            Case \cboMSChannel
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_cboMSChannel_Click() ; Added 1Jan2025 11.10.6cc
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_cboMSChannel_Validate())
              EndSelect
              
            Case \cboMSMacro
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_cboMSMacro_Click() ; Added 1Jan2025 11.10.6cc
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_cboMSMacro_Validate())
              EndSelect
              
            Case \cboMsgType
              CBOCHG(WQM_cboMsgType_Click())
              
            Case \cboMSParam1
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_cboMSParam1_Click() ; Added 1Jan2025 11.10.6cc
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_cboMSParam1_Validate())
              EndSelect
              
            Case \cboMSParam2
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_cboMSParam2_Click() ; Added 1Jan2025 11.10.6cc
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_cboMSParam2_Validate())
              EndSelect
              
            Case \cboMSParam3
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_cboMSParam3_Click() ; Added 1Jan2025 11.10.6cc
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_cboMSParam3_Validate())
              EndSelect
              
            Case \cboMSParam4
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_cboMSParam4_Click() ; Added 1Jan2025 11.10.6cc
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_cboMSParam4_Validate())
              EndSelect
              
            Case \cboNRPNCapturePort
              CBOCHG(WQM_cboNRPNCapturePort_Click())
              
            Case \cboOSCCmdType
              ; CBOCHG(WQM_cboOSCCmdType_Click())
              CBOCHG(WQM_cboMsgType_Click())
              
            Case \cboOSCItemSelect
              CBOCHG(WQM_cboOSCItemSelect_Click())
              
            Case \cboOSCParam1
              CBOCHG(WQM_cboOSCParam1_Click())
              
            Case \cboRSEntryMode
              CBOCHG(WQM_cboRSEntryMode_Click())
              
            Case \cboNWEntryMode
              CBOCHG(WQM_cboNWEntryMode_Click())
              
            Case \cboRemDevCboItem
              CBOCHG(WQM_cboRemDevCboItem_Click())
              
            Case \chkNWAddCR
              CHKOWNCHG(WQM_chkNWAddCR_Click())
              
            Case \chkNWAddLF
              CHKOWNCHG(WQM_chkNWAddLF_Click())
              
            Case \chkOSCReloadNamesGoCue
              CHKOWNCHG(WQM_chkOSCReloadNamesGoCue_Click())
              
            Case \chkOSCReloadNamesGoScene
              CHKOWNCHG(WQM_chkOSCReloadNamesGoScene_Click())
              
            Case \chkOSCReloadNamesGoSnippet
              CHKOWNCHG(WQM_chkOSCReloadNamesGoSnippet_Click())
              
            Case \chkRSAddCR
              CHKOWNCHG(WQM_chkRSAddCR_Click())
              
            Case \chkRSAddLF
              CHKOWNCHG(WQM_chkRSAddLF_Click())
              
            Case \cntMidi, \cntMidiCapture, \cntMidiFile, \cntMidiFreeFormat, \cntMidiMsg, \cntMidiStructured
              ; ignore events
              
            Case \cntRemDev
              ; ignore events
              
            Case \cntSubDetailM
              ; ignore events
              
            Case \cvsRemDevMute
              ; debugMsg(sProcName, "\cvsRemDevMute gnEventType=" + decodeEventType(\cvsRemDevMute))
              Select gnEventType
                Case #PB_EventType_LeftClick, #PB_EventType_MouseEnter, #PB_EventType_MouseLeave
                  WQM_cvsRemDevMute_Event(gnEventType)
              EndSelect
              
            Case \grdCtrlSends
              Select gnEventType
                Case #PB_EventType_Change, #PB_EventType_LeftClick
                  WQM_grdCtrlSends_Change()
              EndSelect
              
            Case \grdRemDevGrdItem
              ; debugMsg(sProcName, "\grdRemDevGrdItem gnEventType=" + decodeEventType(\grdRemDevGrdItem))
              If gnEventType = #PB_EventType_LeftClick
                WQM_GrdRemDevGrdItem_Click()
              EndIf
              
            Case \scaCtrlSend
              ; ignore events
              
            Case \txtEndAt  ; txtEndAt
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_txtEndAt_Validate())
              EndSelect
              
            Case \txtHTEnteredString
              If gnEventType = #PB_EventType_Change
                WQM_txtHTEnteredString_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtHTEnteredString_Validate())
              EndIf
              
            Case \txtHTTPMsg
              ; ignore events - not an enterable field
              
            Case \txtHTItemDesc, \txtMSItemDesc, \txtNWItemDesc, \txtRSItemDesc
              If gnEventType = #PB_EventType_Change
                WQM_txtItemDesc_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtItemDesc_Validate())
              EndIf
              
            Case \txtMFEnteredString
              If gnEventType = #PB_EventType_Change
                WQM_txtMFEnteredString_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtMFEnteredString_Validate())
              EndIf
              
            Case \txtMidiMsg
              ; ignore events - not an enterable field
              
            Case \txtMSParam1Info
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtMSParam1Info_Validate())
              EndIf
              
            Case \txtMSParam2Info
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtMSParam2Info_Validate())
              EndIf
              
            Case \txtMSParam3Info
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtMSParam3Info_Validate())
              EndIf
              
            Case \txtMSParam4Info
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtMSParam4Info_Validate())
              EndIf
              
            Case \txtOMEnteredString
              CompilerIf #c_osc_over_midi_sysex
                ; OSC over MIDI
                If gnEventType = #PB_EventType_Change
                  WQM_txtOMEnteredString_Change()
                ElseIf gnEventType = #PB_EventType_LostFocus
                  ETVAL(WQM_txtOMEnteredString_Validate())
                EndIf
              CompilerEndIf
              
            Case \txtOSCEnteredString
              ; OSC over Network
              If gnEventType = #PB_EventType_Change
                WQM_txtOSCEnteredString_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtOSCEnteredString_Validate())
              EndIf
              
            Case \txtOSCItemString
              ; OSC over Network
              Select gnEventType
                Case #PB_EventType_Change
                  WQM_txtOSCItemString_Change()
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_txtOSCItemString_Validate())
              EndSelect
              
            Case \txtOSCMsg
              ; OSC over Network
              ; ignore events - not an enterable field
              
            Case \txtQList
              If gnEventType = #PB_EventType_Change
                WQM_txtQList_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtQList_Validate())
              EndIf
              
            Case \txtQNumber
              If gnEventType = #PB_EventType_Change
                WQM_txtQNumber_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtQNumber_Validate())
              EndIf
              
            Case \txtQPath
              If gnEventType = #PB_EventType_Change
                WQM_txtQPath_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtQPath_Validate())
              EndIf
              
            Case \txtRemDevDBLevel
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtRemDevDBLevel_Validate())
              EndIf
              
            Case \txtRSEnteredString
              If gnEventType = #PB_EventType_Change
                WQM_txtRSEnteredString_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtRSEnteredString_Validate())
              EndIf
              
            Case \txtStartAt
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQM_txtStartAt_Validate())
              EndSelect
              
            Case \txtNWEnteredString
              If gnEventType = #PB_EventType_Change
                WQM_txtNWEnteredString_Change()
              ElseIf gnEventType = #PB_EventType_LostFocus
                ETVAL(WQM_txtNWEnteredString_Validate())
              EndIf
              
            Default
              debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
          EndSelect
          
        EndIf
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WQM_fcMidiCapturePort()
  PROCNAMEC()

  If Len(Trim(GGT(WQM\cboMidiCapturePort))) > 0
    setEnabled(WQM\btnMidiCapture, #True)
  Else
    setEnabled(WQM\btnMidiCapture, #False)
  EndIf
  
  SGT(WQM\lblMidiCaptureDone, "")
  
EndProcedure

Procedure WQM_fcNRPNCapturePort()
  PROCNAMEC()

  If Len(Trim(GGT(WQM\cboNRPNCapturePort))) > 0
    setEnabled(WQM\btnNRPNCapture, #True)
  Else
    setEnabled(WQM\btnNRPNCapture, #False)
  EndIf
  
  SGT(WQM\txtNRPNCapture, "")
  ; debugMsg0(sProcName, "calling setEnabled(WQM\btnNRPNSave, #False)")
  setEnabled(WQM\btnNRPNSave, #False)
  
EndProcedure

Procedure WQM_populateCboLogicalDev()
  PROCNAMEC()
  Protected d
  
  ; debugMsg(sProcName, #SCS_START)
  
  ClearGadgetItems(WQM\cboLogicalDev)
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    With grProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        If \nDevType <> #SCS_DEVTYPE_LT_DMX_OUT
          debugMsg(sProcName, "grProd\aCtrlSendLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev)
          addGadgetItemWithData(WQM\cboLogicalDev, \sLogicalDev, d)
        EndIf
      EndIf
    EndWith
  Next d
  
EndProcedure

Procedure WQM_populateCboMsgTypeIfReqd(nCtrlSendIndex)
  PROCNAMECS(nEditSubPtr)
  Protected nGadgetNo, nRemDevId, n, nCount, nSSValCount
  Protected nDevType, bIncludeMIDIExtras, bIncludeNetworkExtras
  Static nCurrRemDevId = -9999 ; Changed 2Mar2022 11.9.1ad, Was = -1, but -1 is the default value which meant code below "If nCurrRemDevId <> nRemDevId Or nRemDevId <= 0" was executed unnecessarily due to "Or nRemDevId <= 0"
  
  debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  nRemDevId = aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nRemDevId
  ; debugMsg0(sProcName, "nCurrRemDevId=" + nCurrRemDevId + ", nRemDevId=" + nRemDevId)
  If nCurrRemDevId <> nRemDevId
    ; debugMsg(sProcName, "nRemDevId=" + nRemDevId + ", nCurrRemDevId=" + nCurrRemDevId)
    nDevType = aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nDevType
    ; debugMsg0(sProcName, "nDevType=" + decodeDevType(nDevType))
    Select nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        bIncludeMIDIExtras = #True
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        bIncludeNetworkExtras = #True
    EndSelect
    
    nGadgetNo = WQM\cboMsgType
    ClearGadgetItems(nGadgetNo)
    addGadgetItemWithData(nGadgetNo, #SCS_BLANK_CBO_ENTRY, #SCS_MSGTYPE_NONE)
    If nRemDevId > 0
      nSSValCount = CSRD_GetSSValCountForRemDevId(nRemDevId)
      If nSSValCount > 0
        addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_SCRIBBLE_STRIP), #SCS_MSGTYPE_SCRIBBLE_STRIP)
      EndIf
      For n = 0 To grCSRD\nMaxRemDevMsgData
        With grCSRD\aRemDevMsgData(n)
          If \nCSRD_RemDevId = nRemDevId
            addGadgetItemWithData(nGadgetNo, \sCSRD_MsgDesc, \nCSRD_RemDevMsgType) ; nb these MsgTypes are all greater than #SCS_MSGTYPE_DUMMY_LAST
            nCount + 1
          EndIf
        EndWith
      Next n
    EndIf ; EndIf nRemDevId >= 0
    
    If bIncludeMIDIExtras
      If nCount > 0
        addGadgetItemWithData(nGadgetNo, "-", #SCS_MSGTYPE_NONE) ; just a separator
      EndIf
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_PC127), #SCS_MSGTYPE_PC127)
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_PC128), #SCS_MSGTYPE_PC128)
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_CC), #SCS_MSGTYPE_CC)         ; "MIDI Control Change"
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_ON), #SCS_MSGTYPE_ON)         ; "MIDI Note ON"
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_OFF), #SCS_MSGTYPE_OFF)       ; "MIDI Note OFF"
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_MSC), #SCS_MSGTYPE_MSC)       ; "MIDI Show Control (MSC))"
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_NRPN_GEN), #SCS_MSGTYPE_NRPN_GEN) ; "MIDI NRPN (Standard)" (non-registered parameter number)
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_NRPN_YAM), #SCS_MSGTYPE_NRPN_YAM) ; "MIDI NRPN (Yamaha)" (non-registered parameter number)
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_FREE), #SCS_MSGTYPE_FREE)         ; "MIDI Free Format"
      CompilerIf #c_osc_over_midi_sysex
        addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_OSC_OVER_MIDI), #SCS_MSGTYPE_OSC_OVER_MIDI) ; "OSC Over MIDI SysEx"
      CompilerEndIf
      addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_FILE), #SCS_MSGTYPE_FILE)
    EndIf
    
    If bIncludeNetworkExtras
      ; (no separator required as there is just one extra item)
      addGadgetItemWithData(nGadgetNo, decodeOSCCmdTypeL(#SCS_CS_OSC_FREEFORMAT), #SCS_CS_OSC_FREEFORMAT)
    EndIf
    
    nCurrRemDevId = nRemDevId
  EndIf ; EndIf nCurrRemDevId <> nRemDevId
  
EndProcedure

Procedure WQM_populateCtrlSendComboBoxes()
  PROCNAMEC()
  Protected n
  Static sAnyMidiDev.s, bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sAnyMidiDev = Lang("MIDI", "AnyDev")
    bStaticLoaded = #True
  EndIf
  
  If grWQMDevPopulated\bCboCtrlMidiRemote = #False
    If grLicInfo\bCSRDAvailable
      ClearGadgetItems(WQM\cboCtrlMidiRemoteDev)
      addGadgetItemWithData(WQM\cboCtrlMidiRemoteDev, sAnyMidiDev, -1)
      ; debugMsg(sProcName, "WQM\cboCtrlMidiRemoteDev," + n + "=" + GetGadgetItemText(WQM\cboCtrlMidiRemoteDev, n))
      For n = 0 To grCSRD\nMaxRemDev
        With grCSRD\aRemDev(n)
          If \nCSRD_DevType = #SCS_DEVTYPE_CS_MIDI_OUT
            addGadgetItemWithData(WQM\cboCtrlMidiRemoteDev, \sCSRD_DevName, \nCSRD_RemDevId)
            debugMsg(sProcName, "WQM\cboCtrlMidiRemoteDev," + n + "=" + GetGadgetItemText(WQM\cboCtrlMidiRemoteDev, n) + ", data=" + \nCSRD_RemDevId)
          EndIf
        EndWith
      Next n
    EndIf ; EndIf grLicInfo\bCSRDAvailable
    setComboBoxWidth(WQM\cboCtrlMidiRemoteDev, 80)
    grWQMDevPopulated\bCboCtrlMidiRemote = #True
  EndIf
  
  If grWQMDevPopulated\bCboCtrlNetworkRemoteDev = #False
    ClearGadgetItems(WQM\cboCtrlNetworkRemoteDev)
    If grLicInfo\bCSRDAvailable
      For n = 0 To #SCS_MAX_CS_NETWORK_REM_DEV
        addGadgetItemWithData(WQM\cboCtrlNetworkRemoteDev, decodeCtrlNetworkRemoteDevLShort(n), n)
        ; debugMsg(sProcName, "WQM\cboCtrlNetworkRemoteDev," + n + "=" + GetGadgetItemText(WQM\cboCtrlNetworkRemoteDev, n))
      Next n
    EndIf
    setComboBoxWidth(WQM\cboCtrlNetworkRemoteDev, 80)
    grWQMDevPopulated\bCboCtrlNetworkRemoteDev = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_populateCboCtrlMidiRemoteDev(nDevType)
  PROCNAMEC()
  Protected n
  Static nCurrDevType = #SCS_DEVTYPE_NONE
  Static sAnyMidiDev.s, bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", nDevType=" + decodeDevType(nDevType))
  
  If bStaticLoaded = #False
    sAnyMidiDev = Lang("MIDI", "AnyDev")
    bStaticLoaded = #True
  EndIf
  
  If nDevType <> nCurrDevType
    If grLicInfo\bCSRDAvailable
      ClearGadgetItems(WQM\cboCtrlMidiRemoteDev)
      If nDevType = #SCS_DEVTYPE_CS_MIDI_OUT Or nDevType = #SCS_DEVTYPE_CS_MIDI_THRU
        addGadgetItemWithData(WQM\cboCtrlMidiRemoteDev, sAnyMidiDev, -1)
      EndIf
      For n = 0 To grCSRD\nMaxRemDev
        With grCSRD\aRemDev(n)
          If \nCSRD_DevType = nDevType
            addGadgetItemWithData(WQM\cboCtrlMidiRemoteDev, \sCSRD_DevName, \nCSRD_RemDevId)
            debugMsg(sProcName, "WQM\cboCtrlMidiRemoteDev, item(" + n + ")=" + GetGadgetItemText(WQM\cboCtrlMidiRemoteDev, n) + ", data=" + \nCSRD_RemDevId)
          EndIf
        EndWith
      Next n
    EndIf ; EndIf grLicInfo\bCSRDAvailable
    setComboBoxWidth(WQM\cboCtrlMidiRemoteDev, 80)
    grWQMDevPopulated\bCboCtrlMidiRemote = #True
    nCurrDevType = nDevType
  EndIf
  
;   If grWQMDevPopulated\bCboCtrlNetworkRemoteDev = #False
;     ClearGadgetItems(WQM\cboCtrlNetworkRemoteDev)
;     If grLicInfo\bCSRDAvailable
;       For n = 0 To #SCS_MAX_CS_NETWORK_REM_DEV
;         addGadgetItemWithData(WQM\cboCtrlNetworkRemoteDev, decodeCtrlNetworkRemoteDevLShort(n), n)
;         ; debugMsg(sProcName, "WQM\cboCtrlNetworkRemoteDev," + n + "=" + GetGadgetItemText(WQM\cboCtrlNetworkRemoteDev, n))
;       Next n
;     EndIf
;     setComboBoxWidth(WQM\cboCtrlNetworkRemoteDev, 80)
;     grWQMDevPopulated\bCboCtrlNetworkRemoteDev = #True
;   EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_populateCboOSCCmdType(nCtrlNetworkRemoteDev)
  PROCNAMECS(nEditSubPtr)
  Protected nGadgetNo, nRemDevId, n, nSSValCount
  Static nCurrRemoteDev = -9999
  
  debugMsg(sProcName, #SCS_START + ", nCtrlNetworkRemoteDev=" + nCtrlNetworkRemoteDev)
  
  If nCtrlNetworkRemoteDev <> nCurrRemoteDev
    If grWQM\bUseMidiContainerForNetwork
      nGadgetNo = WQM\cboMsgType
    Else
      nGadgetNo = WQM\cboOSCCmdType
    EndIf
    ClearGadgetItems(nGadgetNo)
    addGadgetItemWithData(nGadgetNo, decodeOSCCmdTypeL(#SCS_CS_OSC_NOT_SET), #SCS_CS_OSC_NOT_SET)
    nRemDevId = CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_NETWORK_OUT, "OSC-X32")
    ; debugMsg0(sProcName, "nRemDevId=" + nRemDevId)
    If nRemDevId > 0
      nSSValCount = CSRD_GetSSValCountForRemDevId(nRemDevId)
      If nSSValCount > 0
        addGadgetItemWithData(nGadgetNo, decodeMsgTypeL(#SCS_MSGTYPE_SCRIBBLE_STRIP), #SCS_MSGTYPE_SCRIBBLE_STRIP)
      EndIf
      For n = 0 To grCSRD\nMaxRemDevMsgData
        With grCSRD\aRemDevMsgData(n)
          If \nCSRD_RemDevId = nRemDevId
            addGadgetItemWithData(nGadgetNo, \sCSRD_MsgDesc, \nCSRD_RemDevMsgType) ; nb these MsgTypes are all greater than #SCS_MSGTYPE_DUMMY_LAST
;             nCount + 1
          EndIf
        EndWith
      Next n
;       If nCount > 0
;         addGadgetItemWithData(nGadgetNo, "-", #SCS_MSGTYPE_NONE) ; just a separator
;       EndIf
    Else ; nRemDevId <= 0
      Select nCtrlNetworkRemoteDev
        Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
          For n = (#SCS_CS_OSC_DUMMY_FIRST + 1) To (#SCS_CS_OSC_DUMMY_LAST - 1)
            addGadgetItemWithData(nGadgetNo, decodeOSCCmdTypeL(n), n)
          Next n
        Case #SCS_CS_NETWORK_REM_OSC_X32TC
          For n = (#SCS_CS_OSC_TC_DUMMY_FIRST + 1) To (#SCS_CS_OSC_TC_DUMMY_LAST - 1)
            addGadgetItemWithData(nGadgetNo, decodeOSCCmdTypeL(n), n)
          Next n
      EndSelect
      addGadgetItemWithData(nGadgetNo, decodeOSCCmdTypeL(#SCS_CS_OSC_FREEFORMAT), #SCS_CS_OSC_FREEFORMAT)
    EndIf ; EndIf nRemDevId > 0 / Else
    setComboBoxWidth(nGadgetNo, 80)
    nCurrRemoteDev = nCtrlNetworkRemoteDev
  EndIf
  
EndProcedure

Procedure WQM_populateCboOSCItemSelect()
  PROCNAMECS(nEditSubPtr)
  Protected n
  Protected nOSCCmdType
  Protected nPhysicalDevPtr
  Protected sItemText.s, sItemId.s
  Protected nLeft
  Protected bOtherIsUsed
  Protected nLenPlaceHolder, nLenOther, nExtendLength
  Static sOther.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sOther = LangSpace("Common", "Other")
    nLenOther = Len(sOther)
    nLenPlaceHolder = Len(grText\sTextPlaceHolder)
    nExtendLength = nLenPlaceHolder - nLenOther
    If nExtendLength < 3
      nExtendLength = 3
    EndIf
    sOther + ReplaceString(Space(nExtendLength - 1), " ", "-") + ">"
    bStaticLoaded = #True
  EndIf
  
  ClearGadgetItems(WQM\cboOSCItemSelect)
  
  debugMsg(sProcName, "grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  If grWQM\nSelectedCtrlSendRow >= 0
    With aSub(nEditSubPtr)\aCtrlSend[grWQM\nSelectedCtrlSendRow]
      nPhysicalDevPtr = \nCSPhysicalDevPtr
      nOSCCmdType = \nOSCCmdType
    EndWith
    debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr + ", nOSCCmdType=" + decodeOSCCmdType(nOSCCmdType))
    
    If nPhysicalDevPtr >= 0
      With gaNetworkControl(nPhysicalDevPtr)
        Select nOSCCmdType
          Case #SCS_CS_OSC_GOCUE, #SCS_CS_OSC_GOSCENE, #SCS_CS_OSC_GOSNIPPET, #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX
            ; add a placeholder item at the START of the list
            addGadgetItemWithData(WQM\cboOSCItemSelect, grText\sTextPlaceHolder, -1)
        EndSelect
        
        Select nOSCCmdType
          Case #SCS_CS_OSC_MUTEAUXIN
            For n = 0 To \rX32NWData\nMaxAuxIn
              sItemText = Trim(\rX32NWData\sAuxIn(n))
              If sItemText
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_MUTEBUS
            For n = 0 To \rX32NWData\nMaxBus
              sItemText = Trim(\rX32NWData\sBus(n))
              If sItemText
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_MUTECHANNEL
            For n = 0 To \rX32NWData\nMaxChannel
              sItemText = Trim(\rX32NWData\sChannel(n))
              If sItemText
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_MUTEDCAGROUP
            For n = 0 To \rX32NWData\nMaxDCAGroup
              sItemText = Trim(\rX32NWData\sDCAGroup(n))
              If sItemText
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_MUTEFXRTN
            For n = 0 To \rX32NWData\nMaxFXReturn
              sItemText = Trim(\rX32NWData\sFXReturn(n))
              If sItemText
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
              EndIf
            Next n
            
;           Case #SCS_CS_OSC_MUTEMAINLR
;             sItemText = Trim(\rX32NWData\sMain(0))
;             If sItemText
;               addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
;             EndIf
;             
;           Case #SCS_CS_OSC_MUTEMAINMC
;             sItemText = Trim(\rX32NWData\sMain(1))
;             If sItemText
;               addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
;             EndIf
            
          Case #SCS_CS_OSC_MUTEMATRIX
            For n = 0 To \rX32NWData\nMaxMatrix
              sItemText = Trim(\rX32NWData\sMatrix(n))
              If sItemText
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n+1, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_MUTEMG
            For n = 0 To \rX32NWData\nMaxMuteGroup
              ; nb no 'name' available for mute groups
              addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemId(nOSCCmdType, n+1), n)
            Next n
            
          Case #SCS_CS_OSC_GOCUE
            For n = 0 To \rX32NWData\nMaxCue
              sItemText = Trim(\rX32NWData\sCue(n))
              sItemId = makeX32ItemId(nOSCCmdType, n)
              If sItemText <> sItemId
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_GOSCENE
            For n = 0 To \rX32NWData\nMaxScene
              sItemText = Trim(\rX32NWData\sScene(n))
              sItemId = makeX32ItemId(nOSCCmdType, n)
              If sItemText <> sItemId
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n, sItemText), n)
              EndIf
            Next n
            
          Case #SCS_CS_OSC_GOSNIPPET
            For n = 0 To \rX32NWData\nMaxSnippet
              sItemText = Trim(\rX32NWData\sSnippet(n))
              sItemId = makeX32ItemId(nOSCCmdType, n)
              If sItemText <> sItemId
                addGadgetItemWithData(WQM\cboOSCItemSelect, makeX32ItemInfo(nOSCCmdType, n, sItemText), n)
              EndIf
            Next n
            
        EndSelect
        
        Select nOSCCmdType
          Case #SCS_CS_OSC_GOCUE, #SCS_CS_OSC_GOSCENE, #SCS_CS_OSC_GOSNIPPET, #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN,
               #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEDCAGROUP ;, #SCS_CS_OSC_MUTEMAIN
            ; add 'Other ---->' at the END of the list
            addGadgetItemWithData(WQM\cboOSCItemSelect, sOther, -2)
            bOtherIsUsed = #True
        EndSelect
      EndWith
    EndIf
    
  EndIf
  
;   For n = 0 To CountGadgetItems(WQM\cboOSCItemSelect) - 1
;     debugMsg(sProcName, "GetGadgetItemText(WQM\cboOSCItemSelect, " + n + ")=" + GetGadgetItemText(WQM\cboOSCItemSelect, n) + ", GetGadgetItemData(WQM\cboOSCItemSelect, " + n + ")=" + GetGadgetItemData(WQM\cboOSCItemSelect, n))
;   Next n
  
  setComboBoxWidth(WQM\cboOSCItemSelect, 80)
  
  If bOtherIsUsed
    ; now reposition WQM\txtOSCItemString as it follows WQM\cboOSCItemSelect
    nLeft = GadgetX(WQM\cboOSCItemSelect) + GadgetWidth(WQM\cboOSCItemSelect) + gnGap
    If GadgetX(WQM\txtOSCItemString) <> nLeft
      ResizeGadget(WQM\txtOSCItemString, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      debugMsg(sProcName, "ResizeGadget(WQM\txtOSCItemString, " + nLeft + ", #PB_Ignore, #PB_Ignore, #PB_Ignore)")
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WQM_populateCboOSCParam1()
  PROCNAMECS(nEditSubPtr)
  Protected nOSCCmdType
  Protected bParam1IsMute
  
  debugMsg(sProcName, #SCS_START + ", grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  
  ClearGadgetItems(WQM\cboOSCParam1)
  
  If grWQM\nSelectedCtrlSendRow >= 0
    nOSCCmdType = aSub(nEditSubPtr)\aCtrlSend[grWQM\nSelectedCtrlSendRow]\nOSCCmdType
    
    Select nOSCCmdType
      Case #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG ;, #SCS_CS_OSC_MUTEMAIN
        addGadgetItemWithData(WQM\cboOSCParam1, decodeMuteActionL(#SCS_MUTE_ON), #SCS_MUTE_ON)
        addGadgetItemWithData(WQM\cboOSCParam1, decodeMuteActionL(#SCS_MUTE_OFF), #SCS_MUTE_OFF)
        setComboBoxWidth(WQM\cboOSCParam1, 50)
    EndSelect
        
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_fcOSCCmdType()
  PROCNAMECS(nEditSubPtr)
  Protected nCtrlSendIndex
  Protected nListIndex, nLeft
  Protected sItemText.s, sItemLabel.s
  Protected bUseOther
  Protected bParam1Visible
  Protected bReloadNamesGoCueVisible, bReloadNamesGoSceneVisible, bReloadNamesGoSnippetVisible
  Protected bItemVisible, bEnteredTextVisible, bTCItemVisible
  Protected nMsgType, nRemDevId
  Protected bTestSelectedEnabled, bTestAllEnabled, nSelectionType
  Protected bRemDevActionVisible, bRemDevComboboxVisible, bRemDevFaderVisible, bRemDevGridVisible, bRemDevVisible, bValType2ReqdForGrid
  Protected sRemDevMsgType.s, sRemDevValue.s, sRemDevValDesc.s, sRemDevValDescForGrid.s, sRemDevValType.s, sRemDevValType2.s
  Protected sRemDevFdrType.s, sRemDevFdrDesc.s
  
  debugMsg(sProcName, #SCS_START + ", grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  
  nCtrlSendIndex = GGS(WQM\grdCtrlSends)
  With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    ; debugMsg0(sProcName, "nMsgType=" + nMsgType + " (" + decodeMsgType(nMsgType) + ")")
    grWQM\nCurrentMsgType = nMsgType
  EndWith
  
  If grWQM\nSelectedCtrlSendRow >= 0
    nCtrlSendIndex = GGS(WQM\grdCtrlSends)
    With WQM
      bTestSelectedEnabled = #True
      bTestAllEnabled = #True
      If nMsgType > #SCS_CS_OSC_DUMMY_LAST
        bRemDevVisible = #True
        ; bHexMessageVisible = #True
        sRemDevMsgType = CSRD_DecodeRemDevMsgType(nMsgType)
        nSelectionType = CSRD_GetSelectionTypeForRemDevMsgType(nMsgType)
        sRemDevValue = Trim(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sRemDevValue)
        ; debugMsg(sProcName, "sRemDevMsgType=" + sRemDevMsgType + ", nSelectionType=" + nSelectionType + ", sRemDevValue=" + sRemDevValue)
        Select nSelectionType
          Case #SCS_SELTYPE_GRID
            bRemDevGridVisible = #True
          Case #SCS_SELTYPE_CBO
            bRemDevComboboxVisible = #True
          Case #SCS_SELTYPE_CBO_AND_GRID ; Added 5Sep2022 11.9.5.1ab
            bRemDevComboboxVisible = #True
            bRemDevGridVisible = #True
            bValType2ReqdForGrid = #True
          Case #SCS_SELTYPE_FADER
            bRemDevFaderVisible = #True
          Case #SCS_SELTYPE_FADER_AND_GRID
            bRemDevFaderVisible = #True
            bRemDevGridVisible = #True
          Case #SCS_SELTYPE_CBO_FADER_AND_GRID
            bRemDevComboboxVisible = #True
            bRemDevFaderVisible = #True
            bRemDevGridVisible = #True
            bValType2ReqdForGrid = #True
          Case #SCS_SELTYPE_NONE
            ; none of the above visible as message type alone is sufficient (eg for message type MuteLR where only LR can be muted/unmuted)
        EndSelect
        If LCase(Left(sRemDevMsgType, 4)) = "mute"
          WQM_drawRemDevMuteIndicator(aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\nRemDevMuteAction, #False)
          bRemDevActionVisible = #True
        EndIf
        sRemDevValDesc = CSRD_GetValDescForRemDevMsgType(nMsgType, 1)
        If bRemDevGridVisible
          If bValType2ReqdForGrid
            sRemDevValDescForGrid = CSRD_GetValDescForRemDevMsgType(nMsgType, 2)
          Else
            sRemDevValDescForGrid = sRemDevValDesc ; Added 8Sep2022
          EndIf
          SetGadgetItemText(\grdRemDevGrdItem, -1, sRemDevValDescForGrid)
          ; debugMsg(sProcName, "SetGadgetItemText(\grdRemDevGrdItem, -1, " + sRemDevValDescForGrid + ")")
        EndIf
        nRemDevId = CSRD_GetRemDevIdForLogicalDev(#SCS_DEVTYPE_CS_NETWORK_OUT, aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]\sCSLogicalDev)
        ; debugMsg0(sProcName, "nRemDevId=" + nRemDevId)
        sRemDevValType = CSRD_GetValTypeForRemDevMsgType(nMsgType, 1)
        If bValType2ReqdForGrid
          sRemDevValType2 = CSRD_GetValTypeForRemDevMsgType(nMsgType, 2)
        EndIf
        If bRemDevComboboxVisible
          SGT(WQM\lblRemDevCboItem, sRemDevValDesc)
          If bRemDevGridVisible
            WQM_populateCboRemDevCombobox(nRemDevId, sRemDevValType, #False) ; no blank row at start if a grid is also required, ie default to first entry, eg FXSnd1
          Else
            WQM_populateCboRemDevCombobox(nRemDevId, sRemDevValType, #True)
          EndIf
          WQM_setCboRemDevCombobox()
        EndIf
        If bRemDevGridVisible
          ; debugMsg0(sProcName, "bValType2ReqdForGrid=" + strB(bValType2ReqdForGrid) + ", sRemDevValType=" + sRemDevValType + ", sRemDevValType2=" + sRemDevValType2)
          If bValType2ReqdForGrid
            WQM_populateGrdRemDevGrdItem(nRemDevId, sRemDevValType2, 2)
            WQM_setGrdRemDevGrdItems(2)
          Else
            WQM_populateGrdRemDevGrdItem(nRemDevId, sRemDevValType, 1)
            WQM_setGrdRemDevGrdItems(1)
          EndIf
        EndIf
        If bRemDevFaderVisible
          sRemDevFdrDesc = CSRD_GetFdrDescForRemDevMsgType(nMsgType)
          SGT(WQM\lblRemDevFader, sRemDevFdrDesc)
          sRemDevFdrType = CSRD_GetFdrTypeForRemDevMsgType(nMsgType)
          WQM_populateFdrRemDevFader()
        EndIf
      Else
        Select nMsgType
          Case #SCS_CS_OSC_NOT_SET
            bItemVisible = #False
            bEnteredTextVisible = #False
          Case #SCS_CS_OSC_FREEFORMAT
            bItemVisible = #False
            bEnteredTextVisible = #True
          Case #SCS_CS_OSC_TC_GO, #SCS_CS_OSC_TC_BACK
            bItemVisible = #False
            bEnteredTextVisible = #False
          Case #SCS_CS_OSC_TC_JUMP
            bTCItemVisible = #True
            bEnteredTextVisible = #False
          Default
            bItemVisible = #True
            bEnteredTextVisible = #False
        EndSelect
        debugMsg(sProcName, "bItemVisible=" + strB(bItemVisible) + ", bTCItemVisible=" + strB(bTCItemVisible) + ", bEnteredTextVisible=" + strB(bEnteredTextVisible))
        
      EndIf
    EndWith
    
    With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
      If bItemVisible
        sItemLabel = getLabelForOSCCmdType(nMsgType)
        SGT(WQM\lblOSCItemSelect, sItemLabel)
        WQM_populateCboOSCItemSelect()
        sItemText = \sOSCItemString
        nListIndex = -1 ; default ListIndex
        If \bOSCItemPlaceHolder
          nListIndex = indexForComboBoxData(WQM\cboOSCItemSelect, -1)
        Else
          If \nOSCItemNr >= 0
            Select nMsgType
              Case #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG ;, #SCS_CS_OSC_MUTEMAIN
                If \nOSCItemNr >= 1
                  ; should be #True
                  nListIndex = indexForComboBoxData(WQM\cboOSCItemSelect, \nOSCItemNr-1) ; channel 1 = index 0 in array \sChannel()
                EndIf
              Default
                nListIndex = indexForComboBoxData(WQM\cboOSCItemSelect, \nOSCItemNr)
            EndSelect
          EndIf
          If nListIndex < 0
            If Len(sItemText) > 0
              nListIndex = indexForComboBoxRow(WQM\cboOSCItemSelect, sItemText)
              If nListIndex < 0
                nListIndex = indexForComboBoxData(WQM\cboOSCItemSelect, -2) ; item text not found in current list, so look for 'Other --->'
              EndIf
            EndIf
          EndIf
        EndIf
        SGS(WQM\cboOSCItemSelect, nListIndex)
        debugMsg(sProcName, "nListIndex=" + nListIndex + ", GGT(WQM\cboOSCItemSelect)=" + GGT(WQM\cboOSCItemSelect))
        SGT(WQM\txtOSCItemString, sItemText)
        WQM_fcCboOSCItemSelect()
        
        Select \nOSCCmdType
          Case #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG ;, #SCS_CS_OSC_MUTEMAIN
            SGT(WQM\lblOSCParam1, Lang("WQM", "Action"))
            WQM_populateCboOSCParam1()
            nListIndex = indexForComboBoxData(WQM\cboOSCParam1, \nOSCMuteAction, 0)
            SGS(WQM\cboOSCParam1, nListIndex)
            bParam1Visible = #True
            
          Case #SCS_CS_OSC_GOCUE
            setOwnState(WQM\chkOSCReloadNamesGoCue, \bOSCReloadNamesGoCue)
            bReloadNamesGoCueVisible = #True
            
          Case #SCS_CS_OSC_GOSCENE
            setOwnState(WQM\chkOSCReloadNamesGoScene, \bOSCReloadNamesGoScene)
            bReloadNamesGoSceneVisible = #True
            
          Case #SCS_CS_OSC_GOSNIPPET
            setOwnState(WQM\chkOSCReloadNamesGoSnippet, \bOSCReloadNamesGoSnippet)
            bReloadNamesGoSnippetVisible = #True
            
        EndSelect
        
      ElseIf bTCItemVisible
        sItemLabel = getLabelForOSCCmdType(\nOSCCmdType)
        ; debugMsg(sProcName, "sItemLabel=" + sItemLabel)
        SGT(WQM\lblOSCItemSelect, sItemLabel)
        sItemText = \sOSCItemString
        SGT(WQM\txtOSCItemString, sItemText)
        
      Else  ; bItemVisible = #False and bTCItemVisible = #False
        ; setVisible(WQM\txtOSCItemString, #False)  ; nb otherwise set by WQM_fcCboOSCItemSelect()
        
      EndIf
      
      ; debugMsg0(sProcName, "bEnteredTextVisible=" + strB(bEnteredTextVisible) + ", aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + grWQM\nSelectedCtrlSendRow + "]\sEnteredString=" + \sEnteredString)
      If bEnteredTextVisible
        debugMsg(sProcName, "\sEnteredString=" + \sEnteredString)
        SGT(WQM\txtOSCEnteredString, \sEnteredString)
      EndIf
      
    EndWith
    
    With WQM
      
      If bTCItemVisible
        nLeft = GadgetX(\cboOSCItemSelect)
      Else
        nLeft = GadgetX(\cboOSCItemSelect) +GadgetWidth(\cboOSCItemSelect) + gnGap
      EndIf
      If GadgetX(\txtOSCItemString) <> nLeft
        ResizeGadget(\txtOSCItemString, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        debugMsg(sProcName, "ResizeGadget(\txtOSCItemString, " + nLeft + ", #PB_Ignore, #PB_Ignore, #PB_Ignore)")
      EndIf
      
      setVisible(\lblOSCItemSelect, bItemVisible|bTCItemVisible)
      setVisible(\cboOSCItemSelect, bItemVisible)
      setVisible(\txtOSCItemString, bItemVisible|bTCItemVisible)
      setVisible(\lblOSCParam1, bParam1Visible)
      setVisible(\cboOSCParam1, bParam1Visible)
      setVisible(\chkOSCReloadNamesGoCue, bReloadNamesGoCueVisible)
      setVisible(\chkOSCReloadNamesGoScene, bReloadNamesGoSceneVisible)
      setVisible(\chkOSCReloadNamesGoSnippet, bReloadNamesGoSnippetVisible)
      setVisible(\lblOSCEnteredString, bEnteredTextVisible)
      setVisible(\txtOSCEnteredString, bEnteredTextVisible)
      
;       setVisible(\lblRemDevAction, bRemDevActionVisible)
;       setVisible(\cvsRemDevMute, bRemDevActionVisible)
;       setVisible(\lblRemDevCboItem, bRemDevComboboxVisible)
;       setVisible(\cboRemDevCboItem, bRemDevComboboxVisible)
;       If bRemDevFaderVisible
;         If bRemDevComboboxVisible
;           nTop = GadgetY(\cboRemDevCboItem) + 23
;         Else
;           nTop = GadgetY(\cboRemDevCboItem)
;         EndIf
;         ResizeGadget(\lblRemDevFader, #PB_Ignore, nTop+4, #PB_Ignore, #PB_Ignore)
;         If SLD_gadgetY(\sldRemDevFader) <> nTop
;           SLD_ResizeGadget(sProcName, \sldRemDevFader, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
;           SLD_Resize(\sldRemDevFader, #False)
;         EndIf
;         ResizeGadget(\txtRemDevDBLevel, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
;       EndIf
;       setVisible(\lblRemDevFader, bRemDevFaderVisible)
;       SLD_setVisible(\sldRemDevFader, bRemDevFaderVisible)
;       setVisible(\txtRemDevDBLevel, bRemDevFaderVisible)
;       If bRemDevGridVisible
;         If bRemDevFaderVisible
;           nTop = SLD_gadgetY(\sldRemDevFader) + 23
;         ElseIf bRemDevComboboxVisible
;           nTop = GadgetY(\cboRemDevCboItem) + 23
;         ElseIf bRemDevActionVisible
;           nTop = GadgetY(\cvsRemDevMute) + 23
;         EndIf
;         nHeight = GadgetHeight(\cntOSC) - nTop - 8
;         ResizeGadget(\grdOSCGrdItem, #PB_Ignore, nTop, #PB_Ignore, nHeight)
;       EndIf
      ; debugMsg(sProcName, "calling setVisible(\cntOSCFaderEtc, " + strB(bRemDevGridVisible) + ")")
      setVisible(\cntOSCFaderEtc, bRemDevGridVisible)
      setEnabled(\cntOSCFaderEtc, #True)
      ; debugMsg(sProcName, "calling setVisible(\grdOSCGrdItem, " + strB(bRemDevGridVisible) + ")")
      setVisible(\grdOSCGrdItem, bRemDevGridVisible)
      setEnabled(\grdOSCGrdItem, #True)
      setVisible(\cntMidi, #False)
;       setVisible(\btnEditScribbleStrip, bEditScribbleStripVisible)

    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_fcCboOSCItemSelect()
  PROCNAMECS(nEditSubPtr)
  Protected nItemData
  
  debugMsg(sProcName, #SCS_START + ", grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  
  If grWQM\nSelectedCtrlSendRow >= 0
    With aSub(nEditSubPtr)\aCtrlSend[grWQM\nSelectedCtrlSendRow]
      nItemData = getCurrentItemData(WQM\cboOSCItemSelect)
      If nItemData = -2
        debugMsg(sProcName, "\aCtrlSend[" + grWQM\nSelectedCtrlSendRow + "]\sOSCItemString=" + \sOSCItemString)
        SGT(WQM\txtOSCItemString, \sOSCItemString)
        setVisible(WQM\txtOSCItemString, #True)
      Else
        setVisible(WQM\txtOSCItemString, #False)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_fcLogicalDev()
  PROCNAMECS(nEditSubPtr)
  Protected nDevNo, nDevType, sMyLogicalDev.s
  
  nDevNo = getCurrentItemData(WQM\cboLogicalDev)
  If nDevNo >= 0
    nDevType = grProd\aCtrlSendLogicalDevs(nDevNo)\nDevType
    sMyLogicalDev = grProd\aCtrlSendLogicalDevs(nDevNo)\sLogicalDev
  Else
    nDevType = #SCS_DEVTYPE_NONE
    sMyLogicalDev = ""
  EndIf
  grWQM\nSelectedDevType = nDevType
  grWQM\sSelectedLogicalDev = sMyLogicalDev
  ; debugMsg(sProcName, "grWQM\sSelectedLogicalDev=" + grWQM\sSelectedLogicalDev + ", grWQM\nSelectedDevType=" + decodeDevType(grWQM\nSelectedDevType))
  
  If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And 1=1
    grWQM\bUseMidiContainerForNetwork = #True
    nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
  Else
    grWQM\bUseMidiContainerForNetwork = #False
  EndIf
  ; debugMsg0(sProcName, "grWQM\bUseMidiContainerForNetwork=" + strB(grWQM\bUseMidiContainerForNetwork))
  
  Select nDevType
    Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
      setVisible(WQM\cntRS232, #False)
      setVisible(WQM\cntNetwork, #False)
      setVisible(WQM\cntHTTP1, #False)
      setVisible(WQM\cntHTTP2, #False)
      setVisible(WQM\cntMidi, #True)
      
    Case #SCS_DEVTYPE_CS_RS232_OUT
      setVisible(WQM\cntMidi, #False)
      setVisible(WQM\cntNetwork, #False)
      setVisible(WQM\cntHTTP1, #False)
      setVisible(WQM\cntHTTP2, #False)
      setVisible(WQM\cntRS232, #True)
      
    Case #SCS_DEVTYPE_CS_NETWORK_OUT
      setVisible(WQM\cntMidi, #False)
      setVisible(WQM\cntRS232, #False)
      setVisible(WQM\cntHTTP1, #False)
      setVisible(WQM\cntHTTP2, #False)
      setVisible(WQM\cntNetwork, #True)
      
    Case #SCS_DEVTYPE_CS_HTTP_REQUEST
      setVisible(WQM\cntMidi, #False)
      setVisible(WQM\cntRS232, #False)
      setVisible(WQM\cntNetwork, #False)
      setVisible(WQM\cntHTTP1, #True)
      setVisible(WQM\cntHTTP2, #True)
      
  EndSelect
  
EndProcedure

Procedure WQM_cboLogicalDev_Click(bSetMidiMsgTypeIfReqd=#True)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nRow, d
  Protected n, bIgnoreLastMsgType, nMsgType, bUsingRemoteDev
  Protected bOSCServer, nCtrlNetworkRemoteDev, nCtrlMidiRemoteDev
  Protected m
  Protected nPrevDevType, sPrevCSLogicalDev.s
  Protected sNewEnteredString.s
  Protected nListIndex
  Protected nWorkDevType, nDevType

  debugMsg(sProcName, #SCS_START + ", bSetMidiMsgTypeIfReqd=" + strB(bSetMidiMsgTypeIfReqd))
  
  debugMsg(sProcName, "grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow + ", CountGadgetItems(WQM\grdCtrlSends)=" + CountGadgetItems(WQM\grdCtrlSends) + ", GGS(WQM\grdCtrlSends)=" + GGS(WQM\grdCtrlSends))
  
  nRow = grWQM\nSelectedCtrlSendRow
  If (nRow >= 0) And (nEditSubPtr >= 0)
    ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nRow]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nRow]))
    With aSub(nEditSubPtr)\aCtrlSend[nRow]
      nPrevDevType = \nDevType
      sPrevCSLogicalDev = \sCSLogicalDev
      u = preChangeSubS(\sCSLogicalDev, GGT(WQM\lblLogicalDev), -5, #SCS_UNDO_ACTION_CHANGE, nRow)
      \sCSLogicalDev = GGT(WQM\cboLogicalDev)
      d = getCurrentItemData(WQM\cboLogicalDev, -1)
      If d >= 0
        \nDevType = grProd\aCtrlSendLogicalDevs(d)\nDevType
      Else
        \nDevType = #SCS_DEVTYPE_NONE
      EndIf
      nDevType = \nDevType
      ; debugMsg(sProcName, "nRow=" + nRow + ", d=" + d + ", \sCSLogicalDev=" + \sCSLogicalDev + ", \nDevType=" + decodeDevType(\nDevType))
      grWQM\nSelectedDevType = nDevType
      grWQM\sSelectedLogicalDev = \sCSLogicalDev
      grEditMem\nLastCtrlSendDevType = nDevType
      grEditMem\sLastCtrlSendLogicalDev = \sCSLogicalDev
      
      \bMIDISend = #False
      \bRS232Send = #False
      \bNetworkSend = #False
      \bHTTPSend = #False
      
      \nMSMsgType = grCtrlSendDef\nMSMsgType
      \nRemDevMsgType = grCtrlSendDef\nRemDevMsgType
      
      debugMsg(sProcName, "calling WQM_populateCboCtrlMidiRemoteDev(" + decodeDevType(nDevType) + ")")
      WQM_populateCboCtrlMidiRemoteDev(nDevType)

      ; nDevTypeForInfoSelection = nWorkDevType
      If grLicInfo\bCSRDAvailable
        \nRemDevId = CSRD_GetRemDevIdForLogicalDev(nDevType, \sCSLogicalDev)
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\sCSLogicalDev=" + \sCSLogicalDev + ", \nRemDevId=" + \nRemDevId)
        If \nRemDevId > 0
          bUsingRemoteDev = #True
        EndIf
      Else
        \nRemDevId = 0
      EndIf
      ;   debugMsg0(sProcName, "grWQM\bUseMidiContainerForNetwork=" + strB(grWQM\bUseMidiContainerForNetwork))
      
      nWorkDevType = nDevType
      If nWorkDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And 1=2
        nWorkDevType = #SCS_DEVTYPE_CS_MIDI_OUT
        grWQM\bUseMidiContainerForNetwork = #True
      Else
        grWQM\bUseMidiContainerForNetwork = #False
      EndIf
      ; debugMsg0(sProcName, "grWQM\bUseMidiContainerForNetwork=" + strB(grWQM\bUseMidiContainerForNetwork))
      
      \nCSPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CTRL_SEND, \sCSLogicalDev)
      ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr)
      
      If nWorkDevType = nPrevDevType
        sNewEnteredString = \sEnteredString
      Else
        sNewEnteredString = ""
      EndIf
      If nWorkDevType <> nPrevDevType Or \sCSLogicalDev <> sPrevCSLogicalDev
        \nOSCCmdType = grCtrlSendDef\nOSCCmdType
        \sOSCItemString = grCtrlSendDef\sOSCItemString
        \sCSItemDesc = grCtrlSendDef\sCSItemDesc
      Else
        \sCSItemDesc = WQM_getLastItemDesc(nRow)
      EndIf
      
      ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\nDevType=" + decodeDevType(\nDevType) + ", nWorkDevType=" + decodeDevType(nWorkDevType))
      Select nWorkDevType
        Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
          If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
            \bNetworkSend = #True
          Else
            \bMIDISend = #True
          EndIf
          If \bNetworkSend
            If \nCSPhysicalDevPtr >= 0
              bOSCServer = gaNetworkControl(\nCSPhysicalDevPtr)\bOSCServer
              nCtrlNetworkRemoteDev = gaNetworkControl(\nCSPhysicalDevPtr)\nCtrlNetworkRemoteDev
            Else
              bOSCServer = #False
              nCtrlNetworkRemoteDev = -1
            EndIf
            debugMsg(sProcName, "\nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr + ", nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev) + ", bOSCServer=" + strB(bOSCServer))
            WQM_fcCtrlNetworkRemoteDev(#True)
            If bOSCServer Or nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32TC
              \bIsOSC = #True
            Else
              \bIsOSC = #False
            EndIf
            debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\bIsOSC=" + strB(\bIsOSC))
          EndIf
          SGT(WQM\txtMSItemDesc, \sCSItemDesc)
          If bUsingRemoteDev
            If IsGadget(WQM\cboCtrlMidiRemoteDev)
              setComboBoxByData(WQM\cboCtrlMidiRemoteDev, \nRemDevId)
              ; debugMsg(sProcName, "setComboBoxByData(WQM\cboCtrlMidiRemoteDev, " + \nRemDevId  + "),  "+ GGT(WQM\cboCtrlMidiRemoteDev))
              WQM_fcCtrlMidiRemoteDev(#False)
            EndIf
          EndIf
          If bSetMidiMsgTypeIfReqd ; Test added 4Oct2021 11.8.6au - see 
            debugMsg(sProcName, "calling WQM_populateCboMsgTypeIfReqd(" + nRow + ")")
            WQM_populateCboMsgTypeIfReqd(nRow)
            \sEnteredString = sNewEnteredString
            bIgnoreLastMsgType = #False
            ; debugMsg(sProcName, "grEditMem\nLastMsgType=" + grEditMem\nLastMsgType + ", grEditMem\nLastRemDevMsgType=" + grEditMem\nLastRemDevMsgType)
            If bUsingRemoteDev
              \nMSMsgType = #SCS_MSGTYPE_NONE
              If \nRemDevMsgType = 0
                If grEditMem\nLastRemDevMsgType > 0
                  \nRemDevMsgType = grEditMem\nLastRemDevMsgType
                EndIf
              EndIf
            Else
              \nRemDevMsgType = 0
              If grEditMem\nLastMsgType = #SCS_MSGTYPE_FILE
                ; only one MIDI file allowed per ctrl send sub-cue, so don't default to MIDI file if there is currently a MIDI file entry in this sub-cue
                For n = 0 To #SCS_MAX_CTRL_SEND
                  If n <> nRow
                    If aSub(nEditSubPtr)\aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FILE
                      bIgnoreLastMsgType = #True
                      ; debugMsg(sProcName, "bIgnoreLastMsgType=#True") 
                      Break
                    EndIf
                  EndIf
                Next n
              EndIf
              If \nMSMsgType = #SCS_MSGTYPE_NONE
                If grEditMem\nLastMsgType <= #SCS_MSGTYPE_DUMMY_LAST
                  \nMSMsgType = grEditMem\nLastMsgType
                EndIf
              EndIf
            EndIf
            ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\nMSMsgType=" + \nMSMsgType + ", \nRemDevMsgType=" + \nRemDevMsgType)
            nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
debugMsg(sProcName, "calling setComboBoxByData(WQM\cboMsgType, " + decodeMsgType(nMsgType) + ", 0)")
            setComboBoxByData(WQM\cboMsgType, nMsgType, 0)
            ; debugMsg(sProcName, "GGS(WQM\cboMsgType)=" + GGS(WQM\cboMsgType) + " " + GGT(WQM\cboMsgType))
            WQM_cboMsgType_Click()
          EndIf ; EndIf bSetMidiMsgTypeIfReqd
          
        Case #SCS_DEVTYPE_CS_RS232_OUT
          ;{
          \bRS232Send = #True
          SGT(WQM\txtRSItemDesc, \sCSItemDesc)
          \nEntryMode = grEditMem\nLastEntryMode
          \bAddCR = grEditMem\bLastAddCR
          \bAddLF = grEditMem\bLastAddLF
          \sEnteredString = sNewEnteredString
          SGS(WQM\cboRSEntryMode, \nEntryMode)
          WQM_fcEntryMode()
          setOwnState(WQM\chkRSAddCR, \bAddCR)
          setOwnState(WQM\chkRSAddLF, \bAddLF)
          SGT(WQM\txtRSEnteredString, \sEnteredString)
          ;}
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          \bNetworkSend = #True
          SGT(WQM\txtNWItemDesc, \sCSItemDesc)
          If \nCSPhysicalDevPtr >= 0
            bOSCServer = gaNetworkControl(\nCSPhysicalDevPtr)\bOSCServer
            nCtrlNetworkRemoteDev = gaNetworkControl(\nCSPhysicalDevPtr)\nCtrlNetworkRemoteDev
          Else
            bOSCServer = #False
            nCtrlNetworkRemoteDev = -1
          EndIf
          debugMsg(sProcName, "\nCSPhysicalDevPtr=" + \nCSPhysicalDevPtr + ", nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nCtrlNetworkRemoteDev) + ", bOSCServer=" + strB(bOSCServer))
          setComboBoxByData(WQM\cboCtrlNetworkRemoteDev, nCtrlNetworkRemoteDev)
          WQM_fcCtrlNetworkRemoteDev(#True)
          If bOSCServer Or nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32TC
            \bIsOSC = #True
          Else
            \bIsOSC = #False
          EndIf
          debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\bIsOSC=" + strB(\bIsOSC))
          If \bIsOSC
            \nOSCCmdType = grEditMem\nLastOSCCmdType
            If nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32 Or nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
              \bOSCReloadNamesGoCue = grEditMem\bLastOSCReloadNamesGoCue
              \bOSCReloadNamesGoScene = grEditMem\bLastOSCReloadNamesGoScene
              \bOSCReloadNamesGoSnippet = grEditMem\bLastOSCReloadNamesGoSnippet
            EndIf
            \sOSCItemString = ""
            debugMsg(sProcName, "\aCtrlSend[" + nRow + "]\sOSCItemString=" + \sOSCItemString)
            nListIndex = setComboBoxByData(WQM\cboOSCCmdType, \nOSCCmdType)
            If nListIndex < 0
              \nOSCCmdType = grCtrlSendDef\nOSCCmdType
            EndIf
; debugMsg0(sProcName, "calling WQM_fcOSCCmdType()")
            WQM_fcOSCCmdType()
            Select nCtrlNetworkRemoteDev
              Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                setVisible(WQM\btnX32Capture, #True)
              Default
                setVisible(WQM\btnX32Capture, #False)
            EndSelect
            setVisible(WQM\cntOther, #False)
            setVisible(WQM\cntOSC, #True)
          Else
;             WQM_fcCtrlNetworkRemoteDev(#True)
            \sEnteredString = sNewEnteredString
            SGS(WQM\cboNWEntryMode, \nEntryMode)
            WQM_fcEntryMode()
            setOwnState(WQM\chkNWAddCR, \bAddCR)
            setOwnState(WQM\chkNWAddLF, \bAddLF)
            SGT(WQM\txtNWEnteredString, \sEnteredString)
            setVisible(WQM\cntOSC, #False)
            setVisible(WQM\cntOther, #True)
          EndIf
          
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST
          \bHTTPSend = #True
          SGT(WQM\txtHTItemDesc, \sCSItemDesc)
          \sEnteredString = sNewEnteredString
          SGT(WQM\txtHTEnteredString, \sEnteredString)
          SAG(WQM\txtHTEnteredString)
          
      EndSelect
      
      ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nRow]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nRow]))
    EndIf
    ; debugMsg(sProcName, "calling buildCtrlSendMessage()")
    buildCtrlSendMessage()
    ; debugMsg(sProcName, "calling buildDisplayInfoForCtrlSend(@aSub(" + getSubLabel(nEditSubPtr) + "), " + nRow + ")")
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nRow)
    ; debugMsg(sProcName, "calling updateCtrlSendGrid(-1, #True)")
    updateCtrlSendGrid(-1, #True)
    postChangeSubS(u, \sCSLogicalDev, -5, nRow)
  EndWith
  
  ; debugMsg(sProcName, "calling WQM_fcLogicalDev()")
  WQM_fcLogicalDev()
  ; debugMsg(sProcName, "calling WQM_resetSubDescrIfReqd()")
  WQM_resetSubDescrIfReqd()
  ; debugMsg(sProcName, "calling WQM_setCtrlSendTestButtons()")
  WQM_setCtrlSendTestButtons()

  ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nRow + "]\bMIDISend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nRow]\bMIDISend) +", \bNetworkSend=" + strB(aSub(nEditSubPtr)\aCtrlSend[nRow]))
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_btnMidiCapture_Click()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If gnMidiCapturePhysicalDevPtr >= 0
    With gaMidiInDevice(gnMidiCapturePhysicalDevPtr)
      If gbCapturingFreeFormatMidi = #False
        \bMidiCapture = #True
        openMidiPorts() ; opens the port if necessary
        gbCapturingFreeFormatMidi = #True
        SGT(WQM\lblMidiCaptureDone, Lang("WQM", "Ready") + " ")   ; add space to end because of italic font losing a bit
        SGT(WQM\btnMidiCapture, LANG("WQM", "CancelCapture"))
        setEnabled(WQM\cboMidiCapturePort, #False)
      Else
        gbCapturingFreeFormatMidi = #False
        \bMidiCapture = #False
        ; cancelling midi capture so close the port unconditionally to clear any outstanding requests
        MidiIn_Port("close", gnMidiCapturePhysicalDevPtr, "midicapture", #True) ; final parameter (#True) forces close even if port also used for MIDI control
        ; now allow the port to be re-opened if it's required for other purposes
        openMidiPorts()
        SGT(WQM\lblMidiCaptureDone, Lang("WQM", "Canceled") + " ")   ; add space to end because of italic font losing a bit
        SGT(WQM\btnMidiCapture, LANG("WQM", "CaptureNext"))
        setEnabled(WQM\cboMidiCapturePort, #True)
        gqEditMidiInfoDisplayed = ElapsedMilliseconds()
        gbEditMidiInfoDisplayedSet = #True
      EndIf
    EndWith
  EndIf
  SAG(-1)
  
EndProcedure

Procedure WQM_btnNRPNCapture_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nRow
  
  debugMsg(sProcName, #SCS_START)
  
  If gnNRPNCapturePhysicalDevPtr >= 0
    nRow = grWQM\nSelectedCtrlSendRow
    If (nRow >= 0) And (nEditSubPtr >= 0)
      With gaMidiInDevice(gnNRPNCapturePhysicalDevPtr)
        If gbCapturingNRPN = #False
          \bNRPNCapture = #True
          openMidiPorts() ; opens the port if necessary
          gbCapturingNRPN = #True
          SGT(WQM\btnNRPNCapture, LANG("WQM", "CancelNRPNCapture"))
          setEnabled(WQM\cboNRPNCapturePort, #False)
        Else
          gbCapturingNRPN = #False
          \bNRPNCapture = #False
          ; cancelling nrpn capture so close the port unconditionally to clear any outstanding requests
          MidiIn_Port("close", gnNRPNCapturePhysicalDevPtr, "NRPNCapture", #True) ; final parameter (#True) forces close even if port also used for MIDI control
          ; now allow the port to be re-opened if it's required for other purposes
          openMidiPorts()
          SGT(WQM\btnNRPNCapture, LANG("WQM", "btnNRPNCapture"))
          setEnabled(WQM\cboNRPNCapturePort, #True)
          ; debugMsg0(sProcName, "calling setEnabled(WQM\btnNRPNSave, #False)")
          setEnabled(WQM\btnNRPNSave, #False)
          gqEditMidiInfoDisplayed = ElapsedMilliseconds()
          gbEditMidiInfoDisplayedSet = #True
        EndIf
      EndWith
    EndIf
  EndIf
  SAG(-1)
  
EndProcedure

Procedure WQM_btnNRPNSave_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u, nRow, nMsgType
  
  debugMsg(sProcName, #SCS_START)
  
  nRow = grWQM\nSelectedCtrlSendRow
  If (nRow >= 0) And (nEditSubPtr >= 0)
    With aSub(nEditSubPtr)\aCtrlSend[nRow]
      u = preChangeSubL(#True, GGT(WQM\btnNRPNSave), -5, #SCS_UNDO_ACTION_CHANGE, nRow)
      If grWQM\rNRPNCapture\bNRPN_Gen
        \nMSMsgType = #SCS_MSGTYPE_NRPN_GEN
        \nRemDevMsgType = 0
      ElseIf grWQM\rNRPNCapture\bNRPN_Yam
        \nMSMsgType = #SCS_MSGTYPE_NRPN_YAM
        \nRemDevMsgType = 0
      EndIf
      \nMSChannel = grWQM\rNRPNCapture\midiChannel
      \nMSParam1 = grWQM\rNRPNCapture\vv_NRPN_MSB
      \nMSParam2 = grWQM\rNRPNCapture\vv_NRPN_LSB
      \nMSParam3 = grWQM\rNRPNCapture\vv_Data_MSB
      If grWQM\rNRPNCapture\nNRPNPartsReceived = 4
        \nMSParam4 = grWQM\rNRPNCapture\vv_Data_LSB
      Else
        \nMSParam4 = -1
      EndIf
      postChangeSubL(u, #False, -5, nRow)
      
      If \nRemDevMsgType > #SCS_MSGTYPE_DUMMY_LAST
        grEditMem\nLastRemDevMsgType = \nRemDevMsgType
        ; debugMsg0(sProcName, "grEditMem\nLastRemDevMsgType=" + decodeMsgType(grEditMem\nLastRemDevMsgType))
      ElseIf \nMSMsgType <> #SCS_MSGTYPE_NONE And \nMSMsgType <> #SCS_MSGTYPE_SCRIBBLE_STRIP
        nMsgType = \nMSMsgType
        grEditMem\nLastMsgType = nMsgType
        ; debugMsg0(sProcName, "grEditMem\nLastMsgType=" + decodeMsgType(grEditMem\nLastMsgType))
        grEditMem\aLastMsg(nMsgType)\nLastMSChannel = \nMSChannel
        grEditMem\aLastMsg(nMsgType)\nLastMSParam1 = \nMSParam1
        grEditMem\aLastMsg(nMsgType)\nLastMSParam2 = \nMSParam2
        grEditMem\aLastMsg(nMsgType)\nLastMSParam3 = \nMSParam3
        grEditMem\aLastMsg(nMsgType)\nLastMSParam4 = \nMSParam4
      EndIf
      buildCtrlSendMessage()
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nRow)
      updateCtrlSendGrid(-1, #True)
    EndWith

    WQM_displayCtrlSendItem(nEditSubPtr)
    
    SGT(WQM\btnNRPNCapture, LANG("WQM", "btnNRPNCapture"))
    setEnabled(WQM\cboNRPNCapturePort, #True)
    ; debugMsg0(sProcName, "calling setEnabled(WQM\btnNRPNSave, #False)")
    setEnabled(WQM\btnNRPNSave, #False)
    SAG(-1)
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_btnBrowse_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected u4 = -1
  Protected nCtrlSendIndex
  Protected sTitle.s
  Protected sMidiFile.s
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  sTitle = Lang("Requesters", "OpenMidiFile")
  ; Open the file for reading
  sMidiFile = OpenFileRequester(sTitle, gsMidiDefaultFile, gsMidiFilePattern, 0)
  debugMsg(sProcName, "sMidiFile=" + sMidiFile)
  If Len(sMidiFile) = 0
    ; cancelled without selecting a file
    ProcedureReturn
  EndIf
  
  ; max length of path and filename must be less than 128 characters for mciSendString. Error found by Richard Borsey 1 June 2015.
  If Len(sMidiFile) > 127
    sMsg = LangPars("Errors", "FileNameTooLong", "127", Str(Len(sMidiFile)), #DQUOTE$ + sMidiFile + #DQUOTE$)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf
  
  gsMidiDefaultFile = GetPathPart(sMidiFile)
  
  nCtrlSendIndex = grWQM\nSelectedCtrlSendRow
  debugMsg(sProcName, "grWQM\nSelectedCtrlSendRow=" + Str(grWQM\nSelectedCtrlSendRow))
  
  u = preChangeSubL(#True, GGT(WQM\lblMidiFile), -5, #SCS_UNDO_ACTION_CHANGE, nCtrlSendIndex)

  With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nCtrlSendIndex + "]\nAudPtr=" + getAudLabel(\nAudPtr))
    setEditAudPtr(\nAudPtr)
    If nEditAudPtr < 0
      nEditCuePtr = aSub(nEditSubPtr)\nCueIndex
      u4 = addAudToSub(nEditCuePtr, nEditSubPtr, nCtrlSendIndex)  ; nb sets nEditAudPtr if successful, and sets aCtrlSend[n]\nAudPtr
    EndIf
  EndWith
  
  debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      \sFileName = sMidiFile
      \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
      SGT(WQM\txtMidiFile, GetFilePart(\sFileName))
      openMediaFile(nEditAudPtr, #True)
    EndWith
    If u4 >= 0
      postChangeAudL(u4, #False, -5, nCtrlSendIndex)
    EndIf
  EndIf
  
  buildCtrlSendMessage()
  buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nCtrlSendIndex)
  updateCtrlSendGrid(-1, #True)
  WQM_displayCtrlSendItem(nEditSubPtr)
  
  WQM_setCtrlSendTestButtons()
  
  postChangeSubL(u, #False, -5, nCtrlSendIndex)
  
  ; debugCuePtrs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_txtStartAt_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected nTime
  Protected u, l2
  Protected sMsg.s
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  
  debugMsg(sProcName, #SCS_START + ", txtStartAt=" + GGT(WQM\txtStartAt))
  debugMsg(sProcName, "GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
  
  If validateTimeField(GGT(WQM\txtStartAt), GGT(WQM\lblStartAt), #False, #False, stringToTime(GGT(WQM\txtFileDuration))) = #False
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf
  
  ; debugMsg(sProcName, "gsTmpString=" + gsTmpString)
  If GGT(WQM\txtStartAt) <> gsTmpString
    SGT(WQM\txtStartAt, gsTmpString)
  EndIf
  
  With aAud(nEditAudPtr)
    nTime = stringToTime(GGT(WQM\txtStartAt))
    
    If nTime >= 0
      If \nAbsEndAt >= 0 And nTime > \nAbsEndAt
        ; do not throw error if nTime = \nAbsEndAt as this prevents user altering field via graph
        sMsg = LangPars("Errors", "MustBeLessThan", GGT(WQM\lblStartAt) + "(" + ttszt(nTime) + ")", GGT(WQM\lblEndAt) + "(" + ttszt(\nAbsEndAt) + ")")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        grWQM\bInValidate = #False
        ProcedureReturn #False
      EndIf
    EndIf
    
    u = preChangeAudL(\nStartAt, GGT(WQM\lblStartAt))
    \nStartAt = nTime
    If \nStartAt = -2
      \nAbsStartAt = 0
    Else
      \nAbsStartAt = \nStartAt
    EndIf
    For l2 = 0 To \nMaxLoopInfo
      \aLoopInfo(l2)\nRelLoopStart = getRelTime(\aLoopInfo(l2)\nAbsLoopStart, \nAbsStartAt)
      \aLoopInfo(l2)\nRelLoopEnd = getRelTime(\aLoopInfo(l2)\nAbsLoopEnd, \nAbsStartAt)
    Next l2
    setDerivedAudFields(nEditAudPtr)
    
    SGT(WQM\txtCueDuration, timeToStringBWZ(\nCueDuration, \nFileDuration))
    SLD_setMax(WQM\sldProgress, (\nCueDuration-1))
    
    postChangeAudL(u, \nStartAt)
    
    debugMsg(sProcName, #SCS_END)
    
  EndWith
  
  grWQM\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQM_txtEndAt_Validate()
  PROCNAMEC()
  Protected nTime
  Protected u
  Protected sMsg.s
  
  If grWQM\bInValidate
    ProcedureReturn #True
  EndIf
  grWQM\bInValidate = #True
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeField(GGT(WQM\txtEndAt), GGT(WQM\lblEndAt), #False, #True, stringToTime(GGT(WQM\txtFileDuration))) = #False
    grWQM\bInValidate = #False
    ProcedureReturn #False
  EndIf
  
  If GGT(WQM\txtEndAt) <> gsTmpString
    SGT(WQM\txtEndAt, gsTmpString)
  EndIf
  
  With aAud(nEditAudPtr)
    nTime = stringToTime(GGT(WQM\txtEndAt))
    
    If nTime >= 0
      If \nAbsStartAt >= 0 And nTime < \nAbsStartAt
        ; do not throw error if nTime = \nAbsStartAt as this prevents user altering field via graph
        sMsg = LangPars("Errors", "MustBeGreaterThan", GGT(WQM\lblEndAt) + " (" + ttsz(nTime) + ")", GGT(WQM\lblStartAt) + " (" + ttsz(\nAbsStartAt) + ")")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        grWQM\bInValidate = #False
        ProcedureReturn #False
      EndIf
    EndIf
    
    u = preChangeAudL(\nEndAt, GGT(WQM\lblEndAt))
    \nEndAt = nTime
    If \nEndAt = -2 And \nFileDuration > 0
      \nAbsEndAt = \nFileDuration - 1
    Else
      \nAbsEndAt = \nEndAt
    EndIf
    debugMsg(sProcName, "calling setDerivedAudFields")
    setDerivedAudFields(nEditAudPtr)
    
    SGT(WQM\txtCueDuration, timeToStringBWZ(\nCueDuration, \nFileDuration))
    SLD_setMax(WQM\sldProgress, (\nCueDuration-1))
    
    debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nEndAt=" + Str(\nEndAt))
    postChangeAudL(u, \nEndAt)
    
    debugMsg(sProcName, #SCS_END)
    
  EndWith
  grWQM\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQM_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQM
    If IsGadget(\scaCtrlSend)
      ; \scaCtrlSend automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaCtrlSend) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaCtrlSend, #PB_ScrollArea_InnerHeight, nInnerHeight)
      ; adjust the height of \cntSubDetailM
      nHeight = nInnerHeight - GadgetY(\cntSubDetailM)
      ResizeGadget(\cntSubDetailM, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      ; debugMsg0(sProcName, "calling WQM_resizeContainers()")
      WQM_resizeContainers()
    EndIf
  EndWith
EndProcedure

Procedure WQM_cboOSCCmdType_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected n
  Protected nPrevOSCCmdType

  debugMsg(sProcName, #SCS_START)
  
  n = grWQM\nSelectedCtrlSendRow
  
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nPrevOSCCmdType = \nOSCCmdType
    u = preChangeSubL(\nOSCCmdType, GGT(WQM\lblOSCCmdType), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \nOSCCmdType = getCurrentItemData(WQM\cboOSCCmdType)
    grEditMem\nLastOSCCmdType = \nOSCCmdType
    If \nOSCCmdType <> nPrevOSCCmdType
      \sOSCItemString = grCtrlSendDef\sOSCItemString
      \nOSCItemNr = grCtrlSendDef\nOSCItemNr
    EndIf
debugMsg0(sProcName, "calling WQM_fcOSCCmdType()")
    WQM_fcOSCCmdType()
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    WQM_resetSubDescrIfReqd()
    postChangeSubL(u, \nOSCCmdType, -5, n)
    
    If \nOSCCmdType = #SCS_CS_OSC_FREEFORMAT
      If getVisible(WQM\txtOSCEnteredString)
        SAG(WQM\txtOSCEnteredString)
      EndIf
    EndIf
    
  EndWith
EndProcedure

Procedure WQM_cboOSCItemSelect_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nCtrlSendIndex
  Protected nItemData, sItemText.s
  Protected nNetworkControlPtr

  debugMsg(sProcName, #SCS_START + ", grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  
  nCtrlSendIndex = grWQM\nSelectedCtrlSendRow
  
  With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
    nNetworkControlPtr = \nCSPhysicalDevPtr
    u = preChangeSubS(\sOSCItemString, GGT(WQM\lblOSCItemSelect), -5, #SCS_UNDO_ACTION_CHANGE, nCtrlSendIndex)
    nItemData = getCurrentItemData(WQM\cboOSCItemSelect, -1)
    If nItemData >= 0
      Select \nOSCCmdType
        Case #SCS_CS_OSC_GOCUE, #SCS_CS_OSC_GOSCENE, #SCS_CS_OSC_GOSNIPPET
          \nOSCItemNr = nItemData
        Default
          \nOSCItemNr = nItemData + 1
      EndSelect
    Else
      \nOSCItemNr = grCtrlSendDef\nOSCItemNr
    EndIf
    Select nItemData
      Case -1 ; PlaceHolder
        \bOSCItemPlaceHolder = #True
        sItemText = ""
      Case -2 ; Other
        \bOSCItemPlaceHolder = #False
        sItemText = GGT(WQM\txtOSCItemString)
      Default
        \bOSCItemPlaceHolder = #False
        sItemText = getOSCItemString(nNetworkControlPtr, \nOSCCmdType, \nOSCItemNr)
        If Len(sItemText) = 0
          sItemText = GGT(WQM\cboOSCItemSelect)
        EndIf
    EndSelect
    \sOSCItemString = sItemText
    debugMsg(sProcName, "\aCtrlSend[" + nCtrlSendIndex + "]\nOSCItemNr=" + \nOSCItemNr + ", \sOSCItemString=" + \sOSCItemString)
    WQM_fcCboOSCItemSelect()
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nCtrlSendIndex)
    updateCtrlSendGrid(-1, #True)
    WQM_resetSubDescrIfReqd()
    postChangeSubS(u, \sOSCItemString, -5, nCtrlSendIndex)
    
    If (nItemData = -2) And (getVisible(WQM\txtOSCItemString))
      SAG(WQM\txtOSCItemString)
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQM_txtOSCItemString_Change()
  ; OSC over Network
  PROCNAMECS(nEditSubPtr)
  Protected u, n

  debugMsg(sProcName, #SCS_START + ", grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  
  n = grWQM\nSelectedCtrlSendRow
  
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sOSCItemString, GGT(WQM\lblOSCItemSelect), -5, #SCS_UNDO_ACTION_CHANGE, n)
    \sOSCItemString = GGT(WQM\txtOSCItemString)
    debugMsg(sProcName, "\aCtrlSend[" + n + "]\sOSCItemString=" + \sOSCItemString)
    buildCtrlSendMessage()
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    WQM_resetSubDescrIfReqd()
    postChangeSubS(u, \sOSCItemString, -5, n)
  EndWith
  
EndProcedure

Procedure WQM_txtOSCItemString_Validate()
  ; OSC over Network
  PROCNAMECS(nEditSubPtr)
  
  markValidationOK(WQM\txtOSCItemString)
  ProcedureReturn #True
EndProcedure

Procedure WQM_cboOSCParam1_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected n

  debugMsg(sProcName, #SCS_START)
  
  n = grWQM\nSelectedCtrlSendRow
  
  With aSub(nEditSubPtr)\aCtrlSend[n]
    Select \nOSCCmdType
      Case #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG; , #SCS_CS_OSC_MUTEMAIN
        u = preChangeSubL(\nOSCMuteAction, GGT(WQM\lblOSCParam1), -5, #SCS_UNDO_ACTION_CHANGE, n)
        \nOSCMuteAction = getCurrentItemData(WQM\cboOSCParam1,#SCS_MUTE_OFF)
        buildCtrlSendMessage()
        buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
        updateCtrlSendGrid(n, #True)
        WQM_resetSubDescrIfReqd()
        postChangeSubL(u, \nOSCMuteAction, -5, n)
    EndSelect
  EndWith
EndProcedure

Procedure WQM_chkOSCReloadNamesGoCue_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u

  debugMsg(sProcName, #SCS_START)
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bOSCReloadNamesGoCue, getOwnText(WQM\chkOSCReloadNamesGoCue), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bOSCReloadNamesGoCue = getOwnState(WQM\chkOSCReloadNamesGoCue)
      grEditMem\bLastOSCReloadNamesGoCue = \bOSCReloadNamesGoCue
      postChangeSubL(u, \bOSCReloadNamesGoCue, -5, n)
    EndWith
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_chkOSCReloadNamesGoScene_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u

  debugMsg(sProcName, #SCS_START)
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bOSCReloadNamesGoScene, getOwnText(WQM\chkOSCReloadNamesGoScene), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bOSCReloadNamesGoScene = getOwnState(WQM\chkOSCReloadNamesGoScene)
      grEditMem\bLastOSCReloadNamesGoScene = \bOSCReloadNamesGoScene
      postChangeSubL(u, \bOSCReloadNamesGoScene, -5, n)
    EndWith
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_chkOSCReloadNamesGoSnippet_Click()
  PROCNAMECS(nEditSubPtr)
  Protected n, u

  debugMsg(sProcName, #SCS_START)
  If nEditSubPtr >= 0
    n = grWQM\nSelectedCtrlSendRow
    With aSub(nEditSubPtr)\aCtrlSend[n]
      u = preChangeSubL(\bOSCReloadNamesGoSnippet, getOwnText(WQM\chkOSCReloadNamesGoSnippet), -5, #SCS_UNDO_ACTION_CHANGE, n)
      \bOSCReloadNamesGoSnippet = getOwnState(WQM\chkOSCReloadNamesGoSnippet)
      grEditMem\bLastOSCReloadNamesGoSnippet = \bOSCReloadNamesGoSnippet
      postChangeSubL(u, \bOSCReloadNamesGoSnippet, -5, n)
    EndWith
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_btnX32Capture_Click()
  PROCNAMEC()
  Protected sMsg.s, sButtons.s, sDontTellMeAgainText.s
  Protected nOption, bCancel
  Static bDontTellMeAgain
  
  debugMsg(sProcName, #SCS_START)
  
  If bDontTellMeAgain = #False
    sMsg = GGT(WQM\btnX32Capture) + "|" +
           Lang("WQM", "X32CaptureWarn") + "||" + Lang("Common", "OKToContinue") + "|"
    ; "WARNING! Using the OSC Capture feature will CLEAR and REPLACE any existing Control Send Items in this Sub-Cue.||OK to continue?|"
    sButtons = Lang("Btns", "Continue") + "|" +
               Lang("Btns", "Cancel")
    sDontTellMeAgainText = Lang("Common", "DontTellMeAgain") ; "Don't tell me this again during this SCS session."
    debugMsg(sProcName, sMsg)
    nOption = OptionRequester(0, 0, sMsg, sButtons, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
    debugMsg(sProcName, "nOption=$" + Hex(nOption, #PB_Long))
    If nOption & $10000
      ; user selected checkbox for "Don't tell me again..."
      bDontTellMeAgain = #True
    EndIf
    Select (nOption & $FFFF)
      Case 2
        bCancel = #True
    EndSelect
  EndIf
  
  If bCancel = #False
    WOC_Form_Show(#True)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_txtItemDesc_Change()
  PROCNAMECS(nEditSubPtr)
  Protected u, n
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    u = preChangeSubS(\sCSItemDesc, GGT(WQM\lblMSItemDesc), -5, #SCS_UNDO_ACTION_CHANGE, n)
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        \sCSItemDesc = GGT(WQM\txtMSItemDesc)
      Case #SCS_DEVTYPE_CS_RS232_OUT
        \sCSItemDesc = GGT(WQM\txtRSItemDesc)
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        \sCSItemDesc = GGT(WQM\txtNWItemDesc)
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        \sCSItemDesc = GGT(WQM\txtHTItemDesc)
    EndSelect
    buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), n)
    updateCtrlSendGrid(n, #True)
    postChangeSubS(u, \sCSItemDesc, -5, n)
  EndWith
EndProcedure

Procedure WQM_txtItemDesc_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected n, nDevType, nMsgType
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        markValidationOK(WQM\txtMSItemDesc)
        grEditMem\aLastMsg(nMsgType)\sLastMSItemDesc = \sCSItemDesc
      Case #SCS_DEVTYPE_CS_RS232_OUT
        markValidationOK(WQM\txtRSItemDesc)
        grEditMem\sLastRSItemDesc = \sCSItemDesc
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        markValidationOK(WQM\txtNWItemDesc)
        grEditMem\sLastNWItemDesc = \sCSItemDesc
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        markValidationOK(WQM\txtHTItemDesc)
        grEditMem\sLastHTItemDesc = \sCSItemDesc
    EndSelect
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure.s WQM_getLastItemDesc(nRowNo)
  PROCNAMECS(nEditSubPtr)
  Protected sLastItemDesc.s, nMsgType
  
  With aSub(nEditSubPtr)\aCtrlSend[nRowNo]
    nMsgType = getMsgType(\nMSMsgType, \nRemDevMsgType)
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        sLastItemDesc = grEditMem\aLastMsg(nMsgType)\sLastMSItemDesc
      Case #SCS_DEVTYPE_CS_RS232_OUT
        sLastItemDesc = grEditMem\sLastRSItemDesc
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        sLastItemDesc = grEditMem\sLastNWItemDesc
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        sLastItemDesc = grEditMem\sLastHTItemDesc
    EndSelect
  EndWith
  ProcedureReturn sLastItemDesc
  
EndProcedure

Procedure WQM_drawRemDevMuteIndicator(nRemDevMuteAction, bMouseOver)
  PROCNAMEC()
  Protected nBackColor, nTextColor, sText.s, nTextWidth, nTextHeight, nLeft, nTop, nBorderColor, nContainerBackColor
  
  If bMouseOver
    nBorderColor = RGB(128, 206, 255) ; light blue
  Else
    nBorderColor = RGB(173, 173, 173) ; grey
  EndIf
  
  If nRemDevMuteAction = #SCS_MUTE_ON
    sText = grText\sTextMute
    nBackColor = RGB(255, 64, 64) ; light red
    nTextColor = #SCS_White
  Else
    nBackColor = RGB(225, 225, 225)
    nTextColor = #SCS_Black
    sText = grText\sTextUnmute
  EndIf
  If StartDrawing(CanvasOutput(WQM\cvsRemDevMute))
    nContainerBackColor = getGadgetContainerBackColor(WQM\cvsRemDevMute)
    Box(0, 0, OutputWidth(), OutputHeight(), nContainerBackColor)
    RoundBox(1, 1, OutputWidth()-2, OutputHeight()-2, 2, 2, nBackColor)
    scsDrawingFont(#SCS_FONT_GEN_NORMAL)
    nTextWidth = TextWidth(sText)
    nTextHeight = TextHeight(sText)
    nLeft = (OutputWidth() - nTextWidth) >> 1
    nTop = (OutputHeight() - nTextHeight) >> 1
    DrawText(nLeft, nTop, sText, nTextColor, nBackColor)
    StopDrawing()
  EndIf
EndProcedure

Procedure WQM_cvsRemDevMute_Event(nEventType)
  PROCNAMECS(nEditSubPtr)
  Protected u, n, bMouseOver
  
  n = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[n]
    Select nEventType
      Case #PB_EventType_MouseEnter
        bMouseOver = #True
      Case #PB_EventType_MouseLeave
        bMouseOver = #False
      Case #PB_EventType_LeftClick
        u = preChangeSubL(\nRemDevMuteAction, GGT(WQM\lblRemDevAction), -5, #SCS_UNDO_ACTION_CHANGE, n)
        If \nRemDevMuteAction = #SCS_MUTE_ON
          \nRemDevMuteAction = #SCS_MUTE_OFF
        Else
          \nRemDevMuteAction = #SCS_MUTE_ON
        EndIf
        \nOSCMuteAction = \nRemDevMuteAction
        CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(nEditSubPtr), n)
        If n = 0
          WQM_resetSubDescrIfReqd()
        EndIf
        updateCtrlSendGrid(n, #True)
        grEditMem\nLastRemDevMuteAction = \nRemDevMuteAction
        postChangeSubL(u, \nRemDevMuteAction, -5, n)
    EndSelect
    WQM_drawRemDevMuteIndicator(\nRemDevMuteAction, bMouseOver)
  EndWith
EndProcedure

Procedure WQM_populateGrdRemDevGrdItem(nRemDevId, sValType.s, nValTypeNr)
  PROCNAMECS(nEditSubPtr)
  Protected n1, n2
  Protected nSelectedCtrlSendRow, nRemDevMsgType, nValBase, sGridItem.s, sItemName.s
  Protected nGadgetNo, nContainer, nRowCount, nMaxHeight
  
  debugMsg(sProcName, #SCS_START + ", nRemDevId=" + nRemDevId + ", sValType=" + sValType + ", nValTypeNr=" + nValTypeNr)
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  If nSelectedCtrlSendRow >= 0
    nRemDevMsgType = aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\nRemDevMsgType
    nValBase = CSRD_GetValBaseForRemDevMsgType(nRemDevMsgType, nValTypeNr)
    If aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork = #False
      nGadgetNo = WQM\grdOSCGrdItem
      nContainer = WQM\cntOSCFaderEtc
    Else
      nGadgetNo = WQM\grdRemDevGrdItem
      nContainer = WQM\cntRemDev
    EndIf
  Else
    ; shouldn't get here
    nValBase = 1
  EndIf
  debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo) +
                      ", nRemDevMsgType=" + nRemDevMsgType + ", aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nSelectedCtrlSendRow + "]\nOSCCmdType=" + aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\nOSCCmdType)
  ; debugMsg(sProcName, "calling loadCurrScribbleStrip(" + getCueLabel(nEditCuePtr) + ", " + aSub(nEditSubPtr)\nSubNo + ", " + nSelectedCtrlSendRow + ")")
  loadCurrScribbleStrip(nEditCuePtr, aSub(nEditSubPtr)\nSubNo, nSelectedCtrlSendRow)
  
  With grCSRD
    ClearGadgetItems(nGadgetNo)
    For n1 = 0 To \nMaxValidValue
      If \aValidValue(n1)\nCSRD_RemDevId = nRemDevId And \aValidValue(n1)\sCSRD_ValType = sValType
        For n2 = nValBase To \aValidValue(n1)\nCSRD_MaxValDataValue
          sGridItem = \aValidValue(n1)\sValDataValue(n2)
          sItemName = getScribbleStripItemName(@grCurrScribbleStrip, sValType, n2)
          ; debugMsg(sProcName, "getScribbleStripItemName(@grCurrScribbleStrip, " + sValType + ", " + n2 + ") returned " + sItemName)
          If sItemName
            addGadgetItemWithData(nGadgetNo, sGridItem + " - " + sItemName, n2)
            ; debugMsg(sProcName, "addGadgetItemWithData(" + getGadgetName(nGadgetNo) + ", " + sGridItem + " - " + sItemName + ", " + n2 + ")")
          Else
            addGadgetItemWithData(nGadgetNo, sGridItem, n2)
            ; debugMsg(sProcName, "addGadgetItemWithData(" + getGadgetName(nGadgetNo) + ", " + sGridItem + ", " + n2 + ")")
          EndIf
          nRowCount + 1
        Next n2
        Break
      EndIf
    Next n1
  EndWith
  
  If nRowCount > 0
    nMaxHeight = GadgetHeight(nContainer) - GadgetY(nGadgetNo)
    ; debugMsg0(sProcName, "calling resizeGridForRows(" + getGadgetName(nGadgetNo) + ", nRows=" + nRowCount + ", nMaxHeight=" + nMaxHeight + ")")
    resizeGridForRows(nGadgetNo, nRowCount, nMaxHeight)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_populateCboRemDevCombobox(nRemDevId, sValType.s, bIncludeBlankEntry=#True)
  PROCNAMECS(nEditSubPtr)
  ; Changed 26Nov2022 11.9.7an to handle scribble strip item names
  Protected n1, n2
  Protected nSelectedCtrlSendRow, nRemDevMsgType, nValBase, sListItem.s, sItemName.s
  
  debugMsg(sProcName, #SCS_START + ", nRemDevId=" + nRemDevId + ", sValType=" + sValType)
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  If nSelectedCtrlSendRow >= 0
    nRemDevMsgType = aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\nRemDevMsgType
    nValBase = CSRD_GetValBaseForRemDevMsgType(nRemDevMsgType, 1)
  Else
    ; shouldn't get here
    nValBase = 1
  EndIf
  
  With grCSRD
    ClearGadgetItems(WQM\cboRemDevCboItem)
    If bIncludeBlankEntry
      addGadgetItemWithData(WQM\cboRemDevCboItem, "", -1) ; blank entry at start
    EndIf
    For n1 = 0 To \nMaxValidValue
      If \aValidValue(n1)\nCSRD_RemDevId = nRemDevId And \aValidValue(n1)\sCSRD_ValType = sValType
        For n2 = nValBase To \aValidValue(n1)\nCSRD_MaxValDataValue
          sListItem = \aValidValue(n1)\sValDataValue(n2)
          sItemName = getScribbleStripItemName(@grCurrScribbleStrip, sValType, n2)
          If sItemName
            addGadgetItemWithData(WQM\cboRemDevCboItem, sListItem + " - " + sItemName, n2)
            ; debugMsg0(sProcName, "addGadgetItemWithData(WQM\cboRemDevCboItem, " + sListItem + " - " + sItemName + ", " + n2 + ")")
          Else
            addGadgetItemWithData(WQM\cboRemDevCboItem, sListItem, n2)
            ; debugMsg0(sProcName, "addGadgetItemWithData(WQM\cboRemDevCboItem, " + sListItem + ", " + n2 + ")")
          EndIf
        Next n2
        Break
      EndIf
    Next n1
  EndWith
  
EndProcedure

Procedure WQM_setGrdRemDevGrdItems(nValTypeNr)
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedCtrlSendRow, nDataValuesCount, nDataValueIndex, nDataValue, nGrdItemIndex, nGrdItemData, nMaxGrdItemIntemIndex, bFound, nMaxDataValueIndex
  Protected nFirstSelectedGridRow
  Protected nGadgetNo
  
  debugMsg(sProcName, #SCS_START + ", nValTypeNr=" + nValTypeNr)
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  If aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And grWQM\bUseMidiContainerForNetwork = #False
    nGadgetNo = WQM\grdOSCGrdItem
  Else
    nGadgetNo = WQM\grdRemDevGrdItem
  EndIf
  nDataValuesCount = CSRD_SelectDataValuesForCtrlSend(nEditSubPtr, nSelectedCtrlSendRow, nValTypeNr)
  If nDataValuesCount >= 0
    nMaxGrdItemIntemIndex = CountGadgetItems(nGadgetNo) - 1
    nFirstSelectedGridRow = -1
    ; debugMsg(sProcName, "nMaxGrdItemIntemIndex=" + nMaxGrdItemIntemIndex + ", grCSRD\nMaxDataValueIndex=" + grCSRD\nMaxDataValueIndex)
    If nValTypeNr = 1
      nMaxDataValueIndex = grCSRD\nMaxDataValueIndex
    Else
      nMaxDataValueIndex = grCSRD\nMaxDataValueIndex2
    EndIf
    For nDataValueIndex = 0 To nMaxDataValueIndex
      If (nValTypeNr = 1 And grCSRD\bDataValueSelected(nDataValueIndex)) Or (nValTypeNr = 2 And grCSRD\bDataValueSelected2(nDataValueIndex))
        bFound = #False
        nDataValue = nDataValueIndex
        For nGrdItemIndex = 0 To nMaxGrdItemIntemIndex
          nGrdItemData = GetGadgetItemData(nGadgetNo, nGrdItemIndex)
          ; debugMsg(sProcName, "GetGadgetItemData(" + getGadgetName(nGadgetNo) + ", " + nGrdItemIndex + ") returned nGrdItemData=" + nGrdItemData)
          If nGrdItemData = nDataValue
            ; debugMsg(sProcName, "calling SetGadgetItemState(" + getGadgetName(nGadgetNo) + ", " + nGrdItemIndex + ", #PB_ListIcon_Checked)")
            SetGadgetItemState(nGadgetNo, nGrdItemIndex, #PB_ListIcon_Checked)
            bFound = #True
            If nFirstSelectedGridRow = -1
              nFirstSelectedGridRow = nGrdItemIndex
            EndIf
            Break
          EndIf
        Next nGrdItemIndex
        If bFound = #False
          debugMsg(sProcName, "No " + getGadgetName(nGadgetNo) + " row found With Data=" + nDataValue)
        EndIf
      EndIf ; EndIf grCSRD\bDataValueSelected(nDataValueIndex)
    Next nDataValueIndex
    If nFirstSelectedGridRow >= 0
      ; Ensure first selected row (if any) is visible
      SendMessage_(GadgetID(nGadgetNo), #LVM_ENSUREVISIBLE, nFirstSelectedGridRow, 0)
    EndIf
  EndIf ; EndIf bDataValuesArrayValid
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_setCboRemDevCombobox()
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedCtrlSendRow, nDataValuesCount, nDataValueIndex, nDataValue
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  nDataValuesCount = CSRD_SelectDataValuesForCtrlSend(nEditSubPtr, nSelectedCtrlSendRow, 1) ; combobox always for nValTypeNr=1
  debugMsg(sProcName, "CSRD_SelectDataValuesForCtrlSend(" + getSubLabel(nEditSubPtr) + ", " + nSelectedCtrlSendRow + ", 1) returned nDataValuesCount=" + nDataValuesCount)
  If nDataValuesCount >= 0
    debugMsg(sProcName, "grCSRD\nMaxDataValueIndex=" + grCSRD\nMaxDataValueIndex)
    For nDataValueIndex = 0 To grCSRD\nMaxDataValueIndex
      If grCSRD\bDataValueSelected(nDataValueIndex)
        nDataValue = nDataValueIndex
        Break
      EndIf
    Next nDataValueIndex
  EndIf
  debugMsg(sProcName, "calling setComboBoxByData(WQM\cboRemDevCboItem, " + nDataValue + ", 0)")
  setComboBoxByData(WQM\cboRemDevCboItem, nDataValue, 0)
  
EndProcedure

Procedure WQM_grdRemDevGrdItem_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nRow, nMaxRow, nState, nData
  Protected nSelectedCtrlSendRow, nRemDevMsgType, nSelType, nValTypeNr
  Protected u, sOldRemDevValue.s, sNewRemDevValue.s
  Protected sItemNumbers.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  nRemDevMsgType = aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\nRemDevMsgType
  nSelType = CSRD_GetSelectionTypeForRemDevMsgType(nRemDevMsgType)
  Select nSelType
    Case #SCS_SELTYPE_CBO_FADER_AND_GRID, #SCS_SELTYPE_CBO_AND_GRID ; Changed 5Sep2022 11.9.5.1ab
      nValTypeNr = 2
      sOldRemDevValue = aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\sRemDevValue2
    Default
      nValTypeNr = 1
      sOldRemDevValue = aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\sRemDevValue
  EndSelect
debugMsg(sProcName, "nRemDevMsgType=" + decodeMsgType(nRemDevMsgType) + ", nSelType=" + nSelType + ", nValTypeNr=" + nValTypeNr)
  
  CSRD_clearDataValueSelectedArray(nValTypeNr)
  With WQM
    nMaxRow = CountGadgetItems(\grdRemDevGrdItem) - 1
    For nRow = 0 To nMaxRow
      nState = GetGadgetItemState(\grdRemDevGrdItem, nRow)
      If nState & #PB_ListIcon_Checked ; nb must use '&', not '=', because GetGadgetItemState() may return multiple states, eg #PB_ListIcon_Checked|#PB_ListIcon_Selected
        nData = GetGadgetItemData(\grdRemDevGrdItem, nRow)
        ; debugMsg(sProcName, "nRow=" + nRow + ", nData=" + nData)
        If nValTypeNr = 1
          grCSRD\bDataValueSelected(nData) = #True
        Else
          grCSRD\bDataValueSelected2(nData) = #True
          ; debugMsg(sProcName, "grCSRD\bDataValueSelected2(" + nData + ")=" + strB(grCSRD\bDataValueSelected2(nData)))
        EndIf
      EndIf
    Next nRow
  EndWith
  sNewRemDevValue =  CSRD_buildRemDevValue(nRemDevMsgType, nValTypeNr)
debugMsg(sProcName, "sNewRemDevValue=" + sNewRemDevValue + ", sOldRemDevValue=" + sOldRemDevValue)
  If sOldRemDevValue <> sNewRemDevValue
    u = preChangeSubS(sOldRemDevValue, GGT(WQM\cboMsgType), -5, #SCS_UNDO_ACTION_CHANGE, nSelectedCtrlSendRow)
    If nValTypeNr = 2
      aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\sRemDevValue2 = sNewRemDevValue
debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nSelectedCtrlSendRow + "]\sRemDevValue2=" + aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\sRemDevValue2)
    Else
      aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]\sRemDevValue = sNewRemDevValue
    EndIf
    debugMsg(sProcName, "calling CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(" + getSubLabel(nEditSubPtr) + "), " + nSelectedCtrlSendRow + ")")
    CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(nEditSubPtr), nSelectedCtrlSendRow)
    If nSelectedCtrlSendRow = 0
      WQM_resetSubDescrIfReqd()
    EndIf
    updateCtrlSendGrid(nSelectedCtrlSendRow, #True)
    postChangeSubS(u, sNewRemDevValue, -5, nSelectedCtrlSendRow)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQM_cboRemDevCboItem_Click(bIgnorePrePostChangeCalls=#False)
  ; Changed 8Sep2022
  ; bIgnorePrePostChangeCalls added for WQM_setCboRemDevCombobox()
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedCtrlSendRow, nData
  Protected u, sOldRemDevValue.s, sNewRemDevValue.s

  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]
    sOldRemDevValue = \sRemDevValue
    nData = getCurrentItemData(WQM\cboRemDevCboItem)
    If nData >= 0
      sNewRemDevValue = Str(nData)
    EndIf
    ; debugMsg0(sProcName, "nData=" + nData + ", sNewRemDevValue=" + sNewRemDevValue + ", sOldRemDevValue=" + sOldRemDevValue)
    If sOldRemDevValue <> sNewRemDevValue
      If bIgnorePrePostChangeCalls = #False
        u = preChangeSubS(sOldRemDevValue, GGT(WQM\cboMsgType), -5, #SCS_UNDO_ACTION_CHANGE, nSelectedCtrlSendRow)
      EndIf
      \sRemDevValue = sNewRemDevValue
      CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(nEditSubPtr), nSelectedCtrlSendRow)
      If nSelectedCtrlSendRow = 0
        WQM_resetSubDescrIfReqd()
      EndIf
      updateCtrlSendGrid(nSelectedCtrlSendRow, #True)
      If bIgnorePrePostChangeCalls = #False
        postChangeSubS(u, sNewRemDevValue, -5, nSelectedCtrlSendRow)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WQM_fcSldRemDevFader()
  PROCNAMECS(nEditSubPtr)
  Protected u, nSelectedCtrlSendRow
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]
    ; debugMsg0(sProcName, "\sRemDevLevel=" + \sRemDevLevel)
    u = preChangeSubS(\sRemDevLevel, GetGadgetText(WQM\lblRemDevFader))
    \fRemDevBVLevel = SLD_getLevel(WQM\sldRemDevFader)
    ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nSelectedCtrlSendRow + "]\fRemDevBVLevel=" + traceLevel(\fRemDevBVLevel))
    \sRemDevLevel = convertBVLevelToDBString(\fRemDevBVLevel, #False, #True, \nRemDevMsgType)
    ; debugMsg(sProcName, "\fRemDevBVLevel=" + traceLevel(\fRemDevBVLevel) + ", \sRemDevLevel=" + \sRemDevLevel)
    SetGadgetText(WQM\txtRemDevDBLevel, \sRemDevLevel)
    CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(nEditSubPtr), nSelectedCtrlSendRow)
    If nSelectedCtrlSendRow = 0
      WQM_resetSubDescrIfReqd()
    EndIf
    updateCtrlSendGrid(nSelectedCtrlSendRow, #True)
    postChangeSubSN(u, \sRemDevLevel)
    ; debugMsg0(sProcName, "\sRemDevLevel=" + \sRemDevLevel)
  EndWith
  
EndProcedure

Procedure WQM_populateFdrRemDevFader()
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedCtrlSendRow, sRemDevLevel.s
  
  ; debugMsg0(sProcName, "grWQM\nSelectedCtrlSendRow=" + grWQM\nSelectedCtrlSendRow)
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]
    SLD_populateCustomArrayForRemDevFader(WQM\sldRemDevFader, \nRemDevMsgType)
    SLD_setRemDevMsgType(WQM\sldRemDevFader, \nRemDevMsgType)
    ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nSelectedCtrlSendRow + "]\sRemDevLevel=" + \sRemDevLevel)
    ; debugMsg(sProcName, "calling SLD_setLevel(WQM\sldRemDevFader, " + \fRemDevBVLevel + ")")
    SLD_setLevel(WQM\sldRemDevFader, \fRemDevBVLevel)
    SLD_setBaseLevel(WQM\sldRemDevFader, #SCS_SLD_BASE_EQUALS_CURRENT)
    WQM_fcSldRemDevFader()
    sRemDevLevel = \sRemDevLevel
    If Len(sRemDevLevel) = 0
      sRemDevLevel = convertBVLevelToDBString(\fRemDevBVLevel)
    EndIf
    SGT(WQM\txtRemDevDBLevel, sRemDevLevel)
  EndWith
  
EndProcedure

Procedure WQM_txtRemDevDBLevel_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u, nSelectedCtrlSendRow, sRemDevLevel.s
  Static nMyRemDevMsgType, fMinFadeLevel_dB.f, nMinDBLevel, fMaxFadeLevel_dB.f, nMaxDBLevel
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQM\nSelectedCtrlSendRow < 0
    grWQM\nSelectedCtrlSendRow = 0
  EndIf
  nSelectedCtrlSendRow = grWQM\nSelectedCtrlSendRow
  With aSub(nEditSubPtr)\aCtrlSend[nSelectedCtrlSendRow]
    If nMyRemDevMsgType <> \nRemDevMsgType
      nMyRemDevMsgType = \nRemDevMsgType
      fMinFadeLevel_dB = CSRD_GetMinFaderLevelDBForRemDevMsgType(nMyRemDevMsgType)
      nMinDBLevel = fMinFadeLevel_dB
      fMaxFadeLevel_dB = CSRD_GetMaxFaderLevelDBForRemDevMsgType(nMyRemDevMsgType)
      nMaxDBLevel = fMaxFadeLevel_dB
      ; debugMsg(sProcName, "nMyRemDevMsgType=" + CSRD_DecodeRemDevMsgType(nMyRemDevMsgType) + ", fMinFadeLevel_dB=" + StrF(fMinFadeLevel_dB,2) + ", nMinDBLevel=" + nMinDBLevel + ", fMaxFadeLevel_dB=" + StrF(fMaxFadeLevel_dB,2) + ", nMaxDBLevel=" + nMaxDBLevel)
    EndIf
    
    If validateDbField(GGT(WQM\txtRemDevDBLevel), GGT(WQM\lblRemDevFader), #False, #True, nMyRemDevMsgType) = #False
      ProcedureReturn #False
    EndIf
    If GGT(WQM\txtRemDevDBLevel) <> gsTmpString
      debugMsg(sProcName, "setting WQM\txtRemDevDBLevel=" + gsTmpString)
      SGT(WQM\txtRemDevDBLevel, gsTmpString)
    EndIf
    
    ; debugMsg0(sProcName, "\sRemDevLevel=" + \sRemDevLevel)
    u = preChangeSubS(\sRemDevLevel, GetGadgetText(WQM\lblRemDevFader))
    \sRemDevLevel = Trim(GGT(WQM\txtRemDevDBLevel))
    If \sRemDevLevel
      \fRemDevBVLevel = convertDBStringToBVLevel(\sRemDevLevel, \nRemDevMsgType)
      \sRemDevLevel = convertBVLevelToDBString(\fRemDevBVLevel, #False, #True, \nRemDevMsgType) ; reformat if necessary, eg if user enters "+0.0" then reformat to "0.0"
    Else
      \fRemDevBVLevel = convertDBStringToBVLevel("0", \nRemDevMsgType) ; assume 0dB if field is blank
    EndIf
    ; debugMsg(sProcName, "calling SLD_setLevel(WQM\sldRemDevFader, " + \fRemDevBVLevel + ")")
    SLD_setLevel(WQM\sldRemDevFader, \fRemDevBVLevel)
    CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(nEditSubPtr), nSelectedCtrlSendRow)
    If nSelectedCtrlSendRow = 0
      WQM_resetSubDescrIfReqd()
    EndIf
    updateCtrlSendGrid(nSelectedCtrlSendRow, #True)
    postChangeSubSN(u, \sRemDevLevel)
    ; debugMsg0(sProcName, "\sRemDevLevel=" + \sRemDevLevel)
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WQM_btnEditScribbleStrip_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nCtrlSendIndex
  
  nCtrlSendIndex = grWQM\nSelectedCtrlSendRow
  WES_Form_Show(nEditSubPtr, nCtrlSendIndex)
  
EndProcedure

Procedure WQM_resizeContainers()
  PROCNAMECS(nEditSubPtr)
  Protected nSubDetailHeight, nTop, nHeight
  
  With WQM
    ; debugMsg0(sProcName, "GadgetHeight(\cntSubDetailM)=" + GadgetHeight(\cntSubDetailM))
    nSubDetailHeight = GadgetHeight(\cntSubDetailM)
    nTop = nSubDetailHeight - GadgetHeight(\cntTest) - 8
    ResizeGadget(\cntTest, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    nTop = nSubDetailHeight - GadgetHeight(\cntRemDevTest) - 8
    ResizeGadget(\cntRemDevTest, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    ; now call WQM_fcCboMsgType() because this contains code to resize gadgets like WQM\grdRemDevGrdItem
    WQM_fcCboMsgType()
  EndWith
  
EndProcedure

; EOF