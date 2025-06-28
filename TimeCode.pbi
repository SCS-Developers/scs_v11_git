; File TimeCode.pbi
; contains procedures for MTC and LTC processing

EnableExplicit

Procedure getDefaultMTCType()
  PROCNAMEC()
  Protected nDefaultMTCType, d, bDefaultSet
  
  nDefaultMTCType = grSubDef\nMTCType
  
  If grLicInfo\bLTCAvailable
    For d = 0 To grProd\nMaxAudioLogicalDev
      With grProd\aAudioLogicalDevs(d)
        If \sLogicalDev
          If \bForLTC
            nDefaultMTCType = #SCS_MTC_TYPE_LTC
            bDefaultSet = #True
            Break
          EndIf
        EndIf
      EndWith
    Next d
  EndIf
  
  If bDefaultSet = #False
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      With grProd\aCtrlSendLogicalDevs(d)
        If \sLogicalDev
          If \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
            If \bCtrlMidiForMTC
              nDefaultMTCType = #SCS_MTC_TYPE_MTC
              bDefaultSet = #True
              Break
            EndIf
          EndIf
        EndIf
      EndWith
    Next d
  EndIf
  
  ProcedureReturn nDefaultMTCType
EndProcedure

Procedure getMTCDevNo(*rProd.tyProd)
  PROCNAMEC()
  Protected nMTCDevNo, d
  
  nMTCDevNo = -1
  For d = 0 To *rProd\nMaxCtrlSendLogicalDev
    With *rProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        Select \nDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
            If \bCtrlMidiForMTC
              nMTCDevNo = d
              Break
            EndIf
        EndSelect
      EndIf
    EndWith
  Next d
  ProcedureReturn nMTCDevNo
EndProcedure

Procedure getLTCDevNo(*rProd.tyProd)
  PROCNAMEC()
  Protected nLTCDevNo, d
  
  nLTCDevNo = -1
  If grLicInfo\bLTCAvailable
    For d = 0 To *rProd\nMaxAudioLogicalDev
      With *rProd\aAudioLogicalDevs(d)
        If \sLogicalDev
          If \bForLTC
            nLTCDevNo = d
            Break
          EndIf
        EndIf
      EndWith
    Next d
  EndIf
  ProcedureReturn nLTCDevNo
EndProcedure

Procedure getFirstMTCCue()
  PROCNAMEC()
  ; get first MTC/LTC cue that has an Type of 'MTC'
  Protected i, j, nFirstMTCCue
  
  nFirstMTCCue = -1
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeU
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubTypeU
            If \nMTCType = #SCS_MTC_TYPE_MTC
              nFirstMTCCue = i
              Break 2 ; Break i
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  Next i
  ProcedureReturn nFirstMTCCue
EndProcedure

Procedure getFirstLTCCue()
  PROCNAMEC()
  ; get first MTC/LTC cue that has an Type of 'LTC'
  Protected i, j, nFirstLTCCue
  
  nFirstLTCCue = -1
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeU
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubTypeU
            If \nMTCType = #SCS_MTC_TYPE_LTC
              nFirstLTCCue = i
              Break 2 ; Break i
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  Next i
  ProcedureReturn nFirstLTCCue
EndProcedure

Procedure checkOKToAddMTCCue()
  PROCNAMEC()
  Protected bOK, d, nReply
  
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    With grProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        If \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
          If \bCtrlMidiForMTC
            bOK = #True
            Break
          EndIf
        EndIf
      EndIf
    EndWith
  Next d
  
  If (bOK = #False) And (grLicInfo\bLTCAvailable)
    For d = 0 To grProd\nMaxAudioLogicalDev
      With grProd\aAudioLogicalDevs(d)
        If \sLogicalDev
          If \bForLTC
            bOK = #True
            Break
          EndIf
        EndIf
      EndWith
    Next d
  EndIf
  
  If bOK = #False
    If grLicInfo\bLTCAvailable
      nReply = scsMessageRequester(#SCS_TITLE, Lang("WQU", "CannotCreateMTCLTC"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      ; message asks if user wants to set up an MTC device now
      If nReply = #PB_MessageRequester_Yes
        grWEP\bDisplayAudioTab = #True
        samAddRequest(#SCS_SAM_EDITOR_NODE_CLICK, grProd\nNodeKey)
      EndIf
    Else
      nReply = scsMessageRequester(#SCS_TITLE, Lang("WQU", "CannotCreate"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      ; message asks if user wants to set up an MTC device now
      If nReply = #PB_MessageRequester_Yes
        grWEP\bDisplayCtrlSendTab = #True
        samAddRequest(#SCS_SAM_EDITOR_NODE_CLICK, grProd\nNodeKey)
      EndIf
    EndIf
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
  
EndProcedure

Procedure.s checkMTCLTCIntegrity(*rProd.tyProd)
  PROCNAMEC()
  Protected nCountCueControlMTC, nCountControlSendMTC
  Protected d, i, n
  Protected nFirstLTCCue, nFirstMTCCue, nMTCDevNo, nLTCDevNo
  Protected sErrorMsg.s
  Protected sCtrlMethod.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  For d = 0 To *rProd\nMaxCueCtrlLogicalDev
    If *rProd\aCueCtrlLogicalDevs(d)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
      If *rProd\aCueCtrlLogicalDevs(d)\nCtrlMethod = #SCS_CTRLMETHOD_MTC
        nCountCueControlMTC + 1
      EndIf
    EndIf
  Next d
  For d = 0 To *rProd\nMaxCtrlSendLogicalDev
    Select *rProd\aCtrlSendLogicalDevs(d)\nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        If *rProd\aCtrlSendLogicalDevs(d)\bCtrlMidiForMTC
          nCountControlSendMTC + 1
        EndIf
    EndSelect
  Next d
  
  nFirstLTCCue = getFirstLTCCue()
  nFirstMTCCue = getFirstMTCCue()
  nLTCDevNo = getLTCDevNo(*rProd)
  nMTCDevNo = getMTCDevNo(*rProd)
  
  If nCountControlSendMTC > 0 Or nCountCueControlMTC > 0
    debugMsg(sProcName, "nCountCueControlMTC=" + nCountCueControlMTC + ", nCountControlSendMTC=" + nCountControlSendMTC + ", nFirstMTCCue=" + getCueLabel(nFirstMTCCue) + ", nFirstLTCCue=" + getCueLabel(nFirstLTCCue))
  EndIf
  
  While #True
    If nCountCueControlMTC > 1
      sCtrlMethod = Lang("Ctrl", "MTC")
      sErrorMsg = LangPars("Errors", "OnlyOneCueCtrlMTC", sCtrlMethod)
      Break
    EndIf
    
    If nCountControlSendMTC > 1
      sErrorMsg = Lang("Errors", "OnlyOneCtrlSendMTC")
      Break
    EndIf
    
    If (nCountCueControlMTC > 0) And (nCountControlSendMTC > 0)
      sErrorMsg = Lang("Errors", "DuplicateMTC")
      Break
    EndIf
    
    If nFirstMTCCue >= 0
      If nCountCueControlMTC > 0
        sErrorMsg = LangPars("Errors", "MTCCuesAndCueCtrlMTCNotAllowed", getCueLabel(nFirstMTCCue))
        Break
      ElseIf nCountControlSendMTC = 0
        sErrorMsg = Lang("Errors", "CtrlSendMTCReqd")
        Break
      EndIf
    EndIf
    
    If nFirstLTCCue >= 0
      If nLTCDevNo < 0
        sErrorMsg = Lang("Errors", "LTCDevReqd")
        Break
      EndIf
    EndIf
    
    Break 
  Wend
  
  If sErrorMsg
    debugMsg(sProcName, #SCS_END + ", returning " + sErrorMsg)
  EndIf
  ProcedureReturn sErrorMsg
  
EndProcedure

Procedure SendMTCQuarterFrames()
  PROCNAMEC()
  Protected nMidiResult.l   ; long
  Protected qQPCTimeNow.q
  Protected qQPCElapsedTime.q
  Protected qElapsedMicroseconds.q
  Protected qElapsedFrames.q
  Protected qElapsedMilliseconds.q
  Protected bLockedMutex
  Protected midiMessage.l   ; long
  Protected end_code.a = #ENTTEC_DMX_END_CODE ; #ENTTEC_DMX_END_CODE = $E7
  Protected res.l = 0
  Protected bytes_written.l = 0
  Protected nDays
  Protected nTryCount, nMidiOutPhysicalDevPtr
  Protected nAbsFilePos
  Static rDMXHeader.Struct_Header
  Static bStaticLoaded

  ; IMPORTANT: The following information is from Wikipedia:
  ;
  ; Quarter-frame messages
  ; When the time is running continuously, the 32-bit time code is broken into 8 4-bit pieces, and one piece is transmitted each quarter frame.
  ; ie 96-120 times per second, depending on the frame rate.
  ; A quarter-frame messages consists of a status byte of 0xF1, followed by a single 7-bit data value: 3 bits to identify the piece, and 4 bits of partial time code.
  ; When time is running forward, the piece numbers increment from 0-7; with the time that piece 0 is transmitted is the coded instant, and the remaining pieces are transmitted later.
  
  If bStaticLoaded = #False
    rDMXHeader\Delim = #ENTTEC_DMX_START_CODE ; #ENTTEC_DMX_START_CODE = $7E
    rDMXHeader\byLabel = #ENTTEC_SEND_MIDI
    rDMXHeader\nLength = 4
    bStaticLoaded = #True
  EndIf

  ; debugMsg(sProcName, "calling LockMutex(gnMTCSendMutex)")
  LockMTCSendMutex(504, #False) ; do not trace quarter-frames
  
  QueryPerformanceCounter_(@qQPCTimeNow)
  
  With grMTCSendControl
    While #True
      Select \nMTCSendState
        Case #SCS_MTC_STATE_PRE_ROLL
          ; debugMsg(sProcName, "processing PRE-ROLL (\nMTCSendState=" + \nMTCSendState + ")")
          ; check if (still) needing to delay before starting quarter-frames
          If \nMTCPreRoll > 0
            qQPCElapsedTime = qQPCTimeNow - \qQPCTimeReady
            qElapsedMilliseconds = qQPCElapsedTime * grQPCInfo\dQPCPeriodMilliseconds
            ; debugMsg(sProcName, "grMTCSendControl\nMTCPreRoll=" + \nMTCPreRoll + ", qQPCTimeNow=" + qQPCTimeNow + ", \qQPCTimeReady=" + \qQPCTimeReady + ", qQPCElapsedTime=" + qQPCElapsedTime +
            ;                     ", grQPCInfo\dQPCPeriodMilliseconds=" + StrD(grQPCInfo\dQPCPeriodMilliseconds) + ", qElapsedMilliseconds=" + StrD(qElapsedMilliseconds))
            If qElapsedMilliseconds < \nMTCPreRoll
              ; delay time not yet expired
              Break
            EndIf
          EndIf
          ; start now
          \qQPCTimeStarted = qQPCTimeNow
          debugMsg(sProcName, "\qQPCTimeStarted=" + \qQPCTimeStarted)
          \qMinNextElapsedFrame = -1  ; forces first set of quarter frames to be sent
          ; debugMsg(sProcName, "grMTCSendControl\qMinNextElapsedFrame=" + \qMinNextElapsedFrame)
          If \nMTCSendState <> #SCS_MTC_STATE_RUNNING
            \nMTCSendState = #SCS_MTC_STATE_RUNNING
            debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
          EndIf
          ; debugMsg(sProcName, "start quarter-frames")
          
        Case #SCS_MTC_STATE_RUNNING
          ; debugMsg(sProcName, "processing RUNNING (grMTCSendControl\nMTCSendState=" + \nMTCSendState + ")")
          
        Default
          Break
          
      EndSelect
      
      ; debugMsg(sProcName, "qQPCTimeNow=" + qQPCTimeNow + ", grMTCSendControl\qQPCTimeStarted=" + \qQPCTimeStarted + ", grQPCInfo\qQPCFrequency=" + grQPCInfo\qQPCFrequency)
      qQPCElapsedTime = qQPCTimeNow - \qQPCTimeStarted
      qElapsedMicroseconds = qQPCElapsedTime * 1000000
      qElapsedMicroseconds / grQPCInfo\qQPCFrequency
      qElapsedMicroseconds + \qMTCStartTimeAsMicroseconds
      ; debugMsg(sProcName, "grMTCSendControl\qMTCStartTimeAsMicroseconds=" + \qMTCStartTimeAsMicroseconds + ", qElapsedMicroseconds=" + qElapsedMicroseconds)
      qElapsedFrames = qElapsedMicroseconds * \nMTCFrameRateX100 / 100000000  ; " / 100000000" = " / 100 / 1000000"
      ; debugMsg(sProcName, "grMTCSendControl\nMTCFrameRateX100=" + \nMTCFrameRateX100 + ", qElapsedFrames=" + qElapsedFrames)
      
      ; debugMsg(sProcName, "qElapsedFrames=" + qElapsedFrames + ", grMTCSendControl\qMinNextElapsedFrame=" + \qMinNextElapsedFrame + ", aSub(" + getSubLabel(\nMTCSubPtr) + ")\qTimeSubStarted)=" + aSub(\nMTCSubPtr)\qTimeSubStarted)
      If qElapsedFrames >= \qMinNextElapsedFrame
        ; debugMsg(sProcName, "qElapsedFrames=" + qElapsedFrames + ", grMTCSendControl\bSkipNextFrame=" + strB(\bSkipNextFrame))
        qElapsedMicroseconds % 86400000000 ; throw away 'days' - max timecode value is 23:59:59:ff  ; added 4Jun2018 11.7.1 post rc1
        \nHours = qElapsedMicroseconds / 3600000000
        qElapsedMicroseconds % 3600000000
        \nMinutes = qElapsedMicroseconds / 60000000
        qElapsedMicroseconds % 60000000
        \nSeconds = qElapsedMicroseconds / 1000000
        qElapsedMicroseconds % 1000000
        \nFrames = qElapsedMicroseconds * \nMTCFrameRateX100 / 100000000  ; " / 100000000" = " / 100 / 1000000"
        
        If \nMTCLinkedToAudPtr > 0 And \nMTCLinkedAudChannel <> 0 ; Added \nMTCLinkedAudChannel test 30Jan2025 11.10.6
;           aAud(\nMTCLinkedToAudPtr)\nPlayingPos = GetPlayingPos(\nMTCLinkedToAudPtr, \nMTCChannelNo) - aAud(\nMTCLinkedToAudPtr)\nAbsMin
          aAud(\nMTCLinkedToAudPtr)\nPlayingPos = GetPlayingPos(\nMTCLinkedToAudPtr, \nMTCLinkedAudChannel, 4) - aAud(\nMTCLinkedToAudPtr)\nAbsMin ; Changed 21Nov2022 11.9.7aj
          aAud(\nMTCLinkedToAudPtr)\nRelFilePos = aAud(\nMTCLinkedToAudPtr)\nPlayingPos
          CompilerIf #cTraceRelFilePos
            debugMsg(sProcName, "aAud(" + getAudLabel(\nMTCLinkedToAudPtr) + ")\nRelFilePos=" + ttszt(aAud(\nMTCLinkedToAudPtr)\nRelFilePos))
          CompilerEndIf
          aAud(\nMTCLinkedToAudPtr)\qChannelBytePosition = grBCI\qChannelBytePosition
        EndIf

        CompilerIf #cTraceMTCSend
          If \nMTCLinkedToAudPtr > 0 And \nMTCLinkedAudChannel <> 0 ; Added \nMTCLinkedAudChannel test 30Jan2025 11.10.6
            debugMsg(sProcName, getSubLabel(\nMTCSubPtr) + ", " + RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0") +
                                ", aAud(" + getAudLabel(\nMTCLinkedToAudPtr) + ") Pos=" + ttszt(aAud(\nMTCLinkedToAudPtr)\nRelFilePos))
          Else
            debugMsg(sProcName, getSubLabel(\nMTCSubPtr) + ", " + RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0"))
          EndIf
        CompilerElse
          If (ElapsedMilliseconds() - \qLogQtrFramesStartTime) < 1000
            ; log the first second of quarter-frames after start of sub-cue or after thread created or resumed (which can occur after a pause/resume sequence)
            If \nMTCLinkedToAudPtr > 0
              debugMsg(sProcName, getSubLabel(\nMTCSubPtr) + ", " + RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0") +
                                  ", aAud(" + getAudLabel(\nMTCLinkedToAudPtr) + ") Pos=" + ttszt(aAud(\nMTCLinkedToAudPtr)\nRelFilePos))
            Else
              debugMsg(sProcName, getSubLabel(\nMTCSubPtr) + ", " + RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0"))
            EndIf
          EndIf
        CompilerEndIf
        
        If (\hMTCMidiOut) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
          ; debugMsg(sProcName, "send quarter-frames: grMTCSendControl\nHours=" + \nHours + ", \nMinutes=" + \nMinutes + ", \nSeconds=" + \nSeconds + ", \nFrames=" + \nFrames)
          ; piece 0: frames low nibble (bits 0-3)
          For nTryCount = 1 To 2
            nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $00F1 + ((\nFrames & $F) << 8))
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              nMidiOutPhysicalDevPtr = \nMTCCuesPhysicalDevPtr
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPhysicalDevPtr + ")")
              closeAndReopenMidiOutPort(nMidiOutPhysicalDevPtr)
              Continue ; try again
            EndIf
            Break
          Next nTryCount
          Delay(\nMTCPieceDelayTime)
          ; piece 1: frames high nibble (bits 4-7)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $10F1 + ((\nFrames & $F0) << 4))
          Delay(\nMTCPieceDelayTime)
          ; piece 2: seconds low nibble (bits 0-3)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $20F1 + ((\nSeconds & $F) << 8))
          Delay(\nMTCPieceDelayTime)
          ; piece 3: seconds high nibble (bits 4-7)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $30F1 + ((\nSeconds & $F0) << 4))
          Delay(\nMTCPieceDelayTime)
          ; piece 4: minutes low nibble (bits 0-3)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $40F1 + ((\nMinutes & $F) << 8))
          Delay(\nMTCPieceDelayTime)
          ; piece 5: minutes high nibble (bits 4-7)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $50F1 + ((\nMinutes & $F0) << 4))
          Delay(\nMTCPieceDelayTime)
          ; piece 6: hours low nibble (bits 0-3)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $60F1 + ((\nHours & $F) << 8))
          Delay(\nMTCPieceDelayTime)
          ; piece 7: hours high nibble (bits 4-7)
          nMidiResult = CallFunctionFast(*gmMidiOutShortMsg, \hMTCMidiOut, $70F1 + (((\nHours & $F0) << 4) | \nSMPTEType))
          ; no need to perform another delay() here
          
          ; debugMsg(sProcName, "sent")
          
        ElseIf (\nMTCFTHandle) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
          ; debugMsg(sProcName, "send quarter-frames: grMTCSendControl\nHours=" + \nHours + ", \nMinutes=" + \nMinutes + ", \nSeconds=" + \nSeconds + ", \nFrames=" + \nFrames)
          ; piece 0: frames low nibble (bits 0-3)
          midiMessage = $00F1 + ((\nFrames & $F) << 8)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 1: frames high nibble (bits 4-7)
          midiMessage = $10F1 + ((\nFrames & $F0) << 4)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 2: seconds low nibble (bits 0-3)
          midiMessage = $20F1 + ((\nSeconds & $F) << 8)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 3: seconds high nibble (bits 4-7)
          midiMessage = $30F1 + ((\nSeconds & $F0) << 4)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 4: minutes low nibble (bits 0-3)
          midiMessage = $40F1 + ((\nMinutes & $F) << 8)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 5: minutes high nibble (bits 4-7)
          midiMessage = $50F1 + ((\nMinutes & $F0) << 4)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 6: hours low nibble (bits 0-3)
          midiMessage = $60F1 + ((\nHours & $F) << 8)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          Delay(\nMTCPieceDelayTime)
          ; piece 7: hours high nibble (bits 4-7)
          midiMessage = $70F1 + (((\nHours & $F0) << 4) | \nSMPTEType)
          res = FT_Write(\nMTCFTHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @midiMessage, 4, @bytes_written)
          res = FT_Write(\nMTCFTHandle, @end_code, 1, @bytes_written)
          ; DMX_FTDI_SendData(\nMTCFTHandle, #ENTTEC_SEND_MIDI, @midiMessage, 4)
          ; no need to perform another delay() here
          
        Else
          ; could be the 'dummy' port has been selected, or MIDI out disabled this session
          ; perform delays anyway
          Delay(\nMTCPieceDelayTime * 7)
          
        EndIf 
        
        \qMinNextElapsedFrame = qElapsedFrames + 2
        ; debugMsg(sProcName, "grMTCSendControl\qMinNextElapsedFrame=" + \qMinNextElapsedFrame)
        \bMTCSendRefreshDisplay = #True
        ; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay))
        
        ; need to unlock mutex BEFORE drawing to the screen
        If bLockedMutex
          ; debugMsg(sProcName, "calling UnlockMutex(gnMTCSendMutex)")
          UnlockMTCSendMutex(#False) ; do not trace quarter-frames
          bLockedMutex = #False
        EndIf
        
        If grMTCControl\nMaxCueOrSubForMTC >= 0
          grMTCControl\nTimeCode = buildMTCTime(\nHours, \nMinutes, \nSeconds, \nFrames)
          ; debugMsg(sProcName, "grMTCControl\nTimeCode=$" + Hex(grMTCControl\nTimeCode,#PB_Long))
        EndIf
        
      EndIf ; EndIf qElapsedFrames >= \qMinNextElapsedFrame
      Break
    Wend
  EndWith
  
  If bLockedMutex
    ; debugMsg(sProcName, "calling UnlockMutex(gnMTCSendMutex)")
    UnlockMTCSendMutex(#False) ; do not trace quarter-frames
  EndIf
  
EndProcedure

Procedure drawLTCSend(bCalledFromDrawVUDisplay=#False)
  PROCNAMEC()
  Protected sHHMMSS.s, sFrame.s, fFrame.f, nFrame
  Protected nTCPos
  Protected sRunningInd.s, sTempString.s, sLTCTime.s
  Protected bNoChange
  Static sPrevTcGenResponse.s
  Protected ltcSmpteEncoder.SMPTETimecode
  Protected nSubPtr, nMTCType
  
  nSubPtr = grMTCSendControl\nMTCSubPtr
  nMTCType = grMTCSendControl\nMTCType
  
  If bCalledFromDrawVUDisplay
    sLTCTime = decodeMTCType(nMTCType) + " "
  EndIf
  
  CompilerIf #c_scsltc
    ; debugMsg(sProcName, "grSMS\bLTCRunning=" + strB(grSMS\bLTCRunning) + ", \sTcGenResponse=" + grSMS\sTcGenResponse)
    If gn_ScsLTCAllowed ; And aSub(pSubPtr)\nMTCType = #SCS_MTC_TYPE_LTC
      ; We are using SCS internal LTC, request a position update
      If nSubPtr >= 0
        If aSub(nSubPtr)\nTCGenIndex >= 0
          sTempString = "p" + gaSMSTCGenerator(aSub(nSubPtr)\nTCGenIndex)\sTCChannel
          getLTCCurrentProgress(sTempString) ; Send request for p1000 timecode
                                             ; result is returned in the gLTCSmpteEncoder structure, 
          sLTCTime + RSet(Str(gLTCSmpteEncoder\hours), 2, "0") + ":" + RSet(Str(gLTCSmpteEncoder\mins), 2, "0") + ":" + 
                     RSet(Str(gLTCSmpteEncoder\secs), 2, "0") + ":" + RSet(Str(gLTCSmpteEncoder\frame), 2, "0")              ; extract hh:mm:ss:ff:
        Else
          ProcedureReturn
        EndIf
      Else
        ProcedureReturn
      EndIf
    EndIf  
  CompilerEndIf
  
  If nMTCType = #SCS_MTC_TYPE_LTC And gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
		nTCPos = FindString(grSMS\sTcGenResponse, "TC=")
		
		If (grSMS\bLTCRunning = #False) Or (nTCPos = 0)
      ProcedureReturn
    EndIf
    
    If grSMS\sTcGenResponse <> sPrevTcGenResponse
      ; note: as at SM-S 1.0.114.0, the timecode returned has the frame component in decimals, eg 00.99 for frame 1, 01.99 for frame 2, etc
      ; frame 0 is returned as 00.00
      ; examples (using smpte30drop):
      ;   TcGenerator P1001 TC=01:59:56:22.99 ;<CR>
      ;   TcGenerator P1001 TC=01:59:56:23.99 ;<CR>
      ;   TcGenerator P1001 TC=01:59:57:00.00 ;<CR>
      ;   TcGenerator P1001 TC=01:59:57:00.99 ;<CR>
      ;   TcGenerator P1001 TC=01:59:57:01.99 ;<CR>
      ;   TcGenerator P1001 TC=01:59:57:02.99 ;<CR>
      ; matter raised with Loren Wilton, 22Jun2018
      ; the following code extracts and rounds the frame component
      sHHMMSS = Mid(grSMS\sTcGenResponse, nTCPos+3, 9)  ; extract hh:mm:ss:
      sFrame = Mid(grSMS\sTcGenResponse, nTCPos+12, 5)  ; extract ff.dd
      fFrame = ValF(sFrame)
      nFrame = Round(fFrame, #PB_Round_Nearest)
      sLTCTime + sHHMMSS + RSet(Str(nFrame),2,"0")
      ; debugMsg(sProcName, "sLTCTime=" + sLTCTime)
    EndIf
    
    If gnThreadNo > #SCS_THREAD_MAIN
      ; debugMsg(sProcName, "calling PostEvent(#SCS_Event_DrawLTC, #WMN, 0, 0, " + bCalledFromDrawVUDisplay + ")")
      PostEvent(#SCS_Event_DrawLTC, #WMN, 0, 0, bCalledFromDrawVUDisplay)
      ProcedureReturn
    EndIf
  EndIf

;   grMTCSendControl\bMTCSendRefreshDisplay = #False
; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay))
  grMTCSendControl\bMTCSendRefreshDisplay = #True ; Changed 31Jan2025 to ensure LTC time display is updated
  ; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay))
  ; debugMsg(sProcName, "sLTCTime=" + sLTCTime + ", \nMTCPanelIndex=" + \nMTCPanelIndex + ", \nMTCSubPtr=" + getSubLabel(\nMTCSubPtr) + ", \nRunningIndGadgetNo=G" + \nRunningIndGadgetNo + ", \nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
  If grMTCSendControl\nMTCPanelIndex >= 0
    If gaDispPanel(grMTCSendControl\nMTCPanelIndex)\nDPSubPtr = grMTCSendControl\nMTCSubPtr
      sRunningInd = GetGadgetText(grMTCSendControl\nRunningIndGadgetNo)
      If sLTCTime <> sRunningInd
        If grMTCSendControl\nMTCSendState = #SCS_MTC_STATE_RUNNING
          SetGadgetText(grMTCSendControl\nRunningIndGadgetNo, sLTCTime)
          CompilerIf #cTraceRunningInd
            debugMsg(sProcName, "(z4) GGT(grMTCSendControl\nRunningIndGadgetNo)=" + GGT(grMTCSendControl\nRunningIndGadgetNo))
          CompilerEndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  If bCalledFromDrawVUDisplay
    If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
      DrawingMode(#PB_2DDrawing_Default)
      ; debugMsg(sProcName, "calling DrawText(" + Str(grMVUD\nSpecWidth-grMVUD\nMTCWidth) + ",0," + sLTCTime + ",#SCS_Yellow,#SCS_Black)")
      DrawText(grMVUD\nSpecWidth-grMVUD\nMTCWidth,0,sLTCTime,#SCS_Yellow,#SCS_Black)
    EndIf
    
  Else
    If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
      ; debugMsg(sProcName, "calling WTC_displayMTC(" + sLTCTime + ",..)")
      WTC_displayMTC(sLTCTime, grMTCSendControl\nMTCSubPtr, "")
    EndIf
    
  EndIf
    
EndProcedure

Procedure drawMTCSend(bCalledFromDrawVUDisplay=#False, bCalledFromSendMTCQuarterFrames=#False)
  PROCNAMEC()
  Protected sMTCTime.s
  Protected sPreRollText.s
  Protected nPreRollTimeRemaining
  Protected sRunningInd.s
  Protected nHours, nMinutes, nSeconds, nFrames
  Protected nData
  Protected nSubPtr, nMTCType
  
  nSubPtr = grMTCSendControl\nMTCSubPtr
  nMTCType = grMTCSendControl\nMTCType
  If bCalledFromDrawVUDisplay
    sMTCTime = decodeMTCType(nMTCType) + " "
  EndIf
  
  ; added 9Jan2017 11.5.3
  If gnThreadNo > #SCS_THREAD_MAIN
    If bCalledFromDrawVUDisplay
      nData | 1
    EndIf
    If bCalledFromSendMTCQuarterFrames
      nData | 2
    EndIf
    ; debugMsg(sProcName, "calling PostEvent(#SCS_Event_DrawMTC, #WMN, 0, 0, " + nData + ")")
    PostEvent(#SCS_Event_DrawMTC, #WMN, 0, 0, nData)
    ProcedureReturn
  EndIf
  ; end added 9Jan2017 11.5.3

  With grMTCSendControl
    ; debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
    If (\nMTCSendState > #SCS_MTC_STATE_IDLE) And (\nMTCSendState < #SCS_MTC_STATE_STOPPED)
      nHours = \nHours
      nMinutes = \nMinutes
      nSeconds = \nSeconds
      nFrames = \nFrames
      \bMTCSendRefreshDisplay = #False
      
      sMTCTime + RSet(Str(nHours),2,"0") + ":" + RSet(Str(nMinutes),2,"0") + ":" + RSet(Str(nSeconds),2,"0") + ":" + RSet(Str(nFrames),2,"0")
      ; debugMsg(sProcName, sMTCTime)
      
      If \nMTCPanelIndex >= 0
        If \nMTCSubPtr >= 0
          If aSub(\nMTCSubPtr)\nSubState <> #SCS_CUE_PAUSED
            If gaDispPanel(\nMTCPanelIndex)\nDPSubPtr = \nMTCSubPtr
              sRunningInd = GetGadgetText(\nRunningIndGadgetNo)
              If (\nMTCSendState = #SCS_MTC_STATE_PRE_ROLL) And (\nMTCPreRoll > 0)
                nPreRollTimeRemaining = \nMTCPreRoll - (gqTimeNow - aSub(\nMTCSubPtr)\qTimeSubRestarted)
                sPreRollText = timeToString(nPreRollTimeRemaining) + " " + grText\sTextPreRoll
                If sRunningInd <> sPreRollText
                  ; debugMsg(sProcName, "sPreRollText=" + sPreRollText + ", bCalledFromDrawVUDisplay=" + strB(bCalledFromDrawVUDisplay))
                  SetGadgetText(\nRunningIndGadgetNo, sPreRollText)
                  CompilerIf #cTraceRunningInd
                    debugMsg(sProcName, "GGT(\nRunningIndGadgetNo)=" + GGT(\nRunningIndGadgetNo))
                  CompilerEndIf
                EndIf
              ElseIf sMTCTime <> sRunningInd
                If \nMTCSendState = #SCS_MTC_STATE_RUNNING
                  SetGadgetText(\nRunningIndGadgetNo, sMTCTime)
                  CompilerIf #cTraceRunningInd
                    debugMsg(sProcName, "GGT(\nRunningIndGadgetNo)=" + GGT(\nRunningIndGadgetNo))
                  CompilerEndIf
                EndIf
              EndIf
            EndIf
          EndIf ; EndIf aSub(\nMTCSubPtr)\nSubState <> #SCS_CUE_PAUSED
        EndIf ; EndIf \nMTCSubPtr >= 0
      EndIf ; EndIf \nMTCPanelIndex >= 0
      
      If bCalledFromSendMTCQuarterFrames
        If grWTC\bFastDrawAvailable
          ; debugMsg(sProcName, "calling WTC_fastDrawMTC(" + sMTCTime + ")")
          WTC_fastDrawMTC(sMTCTime)
        Else
          \bMTCSendRefreshDisplay = #True ; indicates to be drawn by main thread
          ; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay))
        EndIf
        
      ElseIf bCalledFromDrawVUDisplay
        If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
          DrawingMode(#PB_2DDrawing_Default)
          ; debugMsg(sProcName, "calling DrawText(" + Str(grMVUD\nSpecWidth-grMVUD\nMTCWidth) + ",0," + sMTCTime + ",#SCS_Yellow,#SCS_Black)")
          DrawText(grMVUD\nSpecWidth-grMVUD\nMTCWidth,0,sMTCTime,#SCS_Yellow,#SCS_Black)
        EndIf
        
      Else
        If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
          ; debugMsg(sProcName, "calling WTC_displayMTC(" + sMTCTime + ",..)")
          WTC_displayMTC(sMTCTime, \nMTCSubPtr, sPreRollText)
        EndIf
        
      EndIf
      
    Else
      \bMTCSendRefreshDisplay = #False
      ; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay))
      
    EndIf
  EndWith
  
EndProcedure

Procedure drawMTCReceive(bCalledFromDrawVUDisplay)
  PROCNAMEC()
  Protected sMTCTime.s
  
  With grMTCControl
    If (\nTimeCode >= 0) And (\bTimeCodeStopped = #False) And (gbMidiTestWindow = #False) And (\bStoppedDuringTest = #False)
      sMTCTime = decodeMTCTime(\nTimeCode)
      If bCalledFromDrawVUDisplay
        If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
          DrawingMode(#PB_2DDrawing_Default)
          DrawText(grMVUD\nSpecWidth-grMVUD\nMTCWidth,0,sMTCTime,#SCS_Yellow,#SCS_Black)
        EndIf
      Else
        If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
          WTC_displayMTC(sMTCTime, -1, "")
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure.l buildMTCTime(nHours, nMinutes, nSeconds, nFrames)
  PROCNAMEC()
  ; nb 'rate' deliberately omitted as it is not included in our internal 'long' representations of MIDI Time Codes
  
  ProcedureReturn (nHours << 24) | (nMinutes << 16) | (nSeconds << 8) | nFrames
  
EndProcedure

Procedure encodeMTCTime(sMTCTime.s)
  ; Also used for LTC
  PROCNAMEC()
  ; sMTCTime must be in format 'hh:mm:ss:ff'
  ; decoded time will be ((time in seconds) * 100) + frames
  Protected nMTCTime
  Protected nHours, nMinutes, nSeconds, nFrames
  
  If CountString(sMTCTime, ":") = 3
    nHours = Val(StringField(sMTCTime, 1, ":"))
    nMinutes = Val(StringField(sMTCTime, 2, ":"))
    nSeconds = Val(StringField(sMTCTime, 3, ":"))
    nFrames = Val(StringField(sMTCTime, 4, ":"))
;     nMTCTime = (nHours * 360000) + (nMinutes * 6000) + (nSeconds * 100) + nFrames
    nMTCTime = (nHours << 24) | (nMinutes << 16) | (nSeconds << 8) | nFrames
  EndIf
  
  ; debugMsg(sProcName, "sMTCTime=" + sMTCTime + ", nHours=" + Str(nHours) + ", nMinutes=" + Str(nMinutes) + ", nSeconds=" + Str(nSeconds) + ", nFrames=" + Str(nFrames))
  ; debugMsg(sProcName, #SCS_END + ", returning $" + Hex(nMTCTime,#PB_Long))
  ProcedureReturn nMTCTime
  
EndProcedure

Procedure.s decodeMTCTime(nMTCTime, bTwoDigitParts=#True)
  ; Also used for LTC
  PROCNAMEC()
  Protected sMTCTime.s
  Protected nHours, nMinutes, nSeconds, nFrames
  
  nHours = (nMTCTime >> 24) & $1F
  nMinutes = (nMTCTime >> 16) & $3F
  nSeconds = (nMTCTime >> 8) & $3F
  nFrames = nMTCTime & $1F
  
;   debugMsg(sProcName, "nMTCTime=" + Hex(nMTCTime,#PB_Long))
;   debugMsg(sProcName, "nHours=" + Str(nHours) + ", nMinutes=" + Str(nMinutes) + ", nSeconds=" + Str(nSeconds) + ", nFrames=" + Str(nFrames))
  If bTwoDigitParts
    sMTCTime = RSet(Str(nHours),2,"0") + ":" + RSet(Str(nMinutes),2,"0") + ":" + RSet(Str(nSeconds),2,"0") + ":" + RSet(Str(nFrames),2,"0")
  Else
    sMTCTime = Str(nHours) + ":" + Str(nMinutes) + ":" + Str(nSeconds) + ":" + Str(nFrames)
  EndIf
  ; debugMsg(sProcName, #SCS_END + ", returning " + sMTCTime)
  ProcedureReturn sMTCTime
  
EndProcedure

Procedure adjustMTCBySeconds(nMTCTime, nAdjustSeconds)
  PROCNAMEC()
  ; nb nAdjustSeconds must be in the range (0 to 59) or (-1 to -59), but with initial usage of this procedure this would be just -1 or +2
  Protected nPrevMTCTime
  Protected nHours, nMinutes, nSeconds, nFrames
  
  nHours = (nMTCTime >> 24) & $1F
  nMinutes = (nMTCTime >> 16) & $3F
  nSeconds = (nMTCTime >> 8) & $3F
  nFrames = nMTCTime & $1F
  
  If nAdjustSeconds >= 0
    nSeconds + nAdjustSeconds
    If nSeconds >= 60
      nSeconds - 60
      nMinutes + 1
      If nMinutes >= 60
        nMinutes - 60
        nHours + 1
        If nHours >= 24
          ; hopefully will not get here in practice
          nHours - 24
        EndIf
      EndIf
    EndIf
  Else
    nSeconds - nAdjustSeconds
    If nSeconds < 0
      nSeconds = 59
      nMinutes - 1
      If nMinutes < 0
        nMinutes = 59
        nHours - 1
        If nHours < 0
          ; hopefully will not get here in practice
          nHours = 23
        EndIf
      EndIf
    EndIf
  EndIf
  nPrevMTCTime = (nHours << 24) | (nMinutes << 16) | (nSeconds << 8) | nFrames
  ProcedureReturn nPrevMTCTime
  
EndProcedure

Procedure getCurrMTCTimeInMilliseconds()
  PROCNAMEC()
  Protected nMilliSeconds
  
  With grMTCSendControl
    nMilliSeconds = (\nHours * 3600000) + (\nMinutes * 60000) + (\nSeconds * 1000)
    If \nFrames > 0
      If \nMTCMillisecondsPerFrame > 0
        nMilliSeconds + (\nFrames * \nMTCMillisecondsPerFrame)
      Else
        nMilliSeconds + (\nFrames * \dMTCMillisecondsPerFrame)
      EndIf
    EndIf
  EndWith
  ProcedureReturn nMilliSeconds
EndProcedure

Procedure convertMTCTimeToMilliseconds(nMTCTime, nMTCFrameRateX100)
  PROCNAMEC()
  Protected nHours, nMinutes, nSeconds, nFrames, dMTCMillisecondsPerFrame.d
  Protected nMilliSeconds
  
  nHours = (nMTCTime >> 24) & $1F
  nMinutes = (nMTCTime >> 16) & $3F
  nSeconds = (nMTCTime >> 8) & $3F
  nFrames = nMTCTime & $1F
  dMTCMillisecondsPerFrame = 100000.0 / nMTCFrameRateX100
  debugMsg(sProcName, "nMTCTime=" + nMTCTime + " (" + decodeMTCTime(nMTCTime) + "), nHours=" + nHours + ", nMinutes=" + nMinutes + ", nSeconds=" + nSeconds + ", nFrames=" + nFrames + ", dMTCMillisecondsPerFrame=" + StrD(dMTCMillisecondsPerFrame,2))
  nMilliSeconds = (nHours * 3600000) + (nMinutes * 60000) + (nSeconds * 1000)
  If nFrames > 0
    nMilliSeconds + (nFrames * dMTCMillisecondsPerFrame)
  EndIf
  ProcedureReturn nMilliSeconds
EndProcedure

Procedure convertMTCTimeToMilliseconds_OLD(nMTCTime)
  PROCNAMEC()
  Protected nHours, nMinutes, nSeconds, nFrames
  Protected nMilliSeconds
  
  nHours = (nMTCTime >> 24) & $1F
  nMinutes = (nMTCTime >> 16) & $3F
  nSeconds = (nMTCTime >> 8) & $3F
  nFrames = nMTCTime & $1F
  debugMsg(sProcName, "nMTCTime=" + nMTCTime + " (" + decodeMTCTime(nMTCTime) + "), nHours=" + nHours + ", nMinutes=" + nMinutes + ", nSeconds=" + nSeconds + ", nFrames=" + nFrames)
  
  With grMTCSendControl
    nMilliSeconds = (nHours * 3600000) + (nMinutes * 60000) + (nSeconds * 1000)
    If nFrames > 0
      If \nMTCMillisecondsPerFrame > 0
        nMilliSeconds + (nFrames * \nMTCMillisecondsPerFrame)
      Else
        nMilliSeconds + (nFrames * \dMTCMillisecondsPerFrame)
      EndIf
    EndIf
  EndWith
  ProcedureReturn nMilliSeconds
EndProcedure

Procedure.q convertMTCTimeToMicroseconds(nMTCTime)
  PROCNAMEC()
  Protected nHours, nMinutes, nSeconds, nFrames
  Protected qMicroSeconds.q
  
  nHours = (nMTCTime >> 24) & $1F
  nMinutes = (nMTCTime >> 16) & $3F
  nSeconds = (nMTCTime >> 8) & $3F
  nFrames = nMTCTime & $1F
  
  With grMTCSendControl
    qMicroSeconds = (nHours * 3600000000) + (nMinutes * 60000000) + (nSeconds * 1000000)
    qMicroSeconds + (1000000 * nFrames * 100 / \nMTCFrameRateX100)
  EndWith
  ProcedureReturn qMicroSeconds
EndProcedure

Procedure adjustMTCTimeByPrerollTime(nMTCTime, nPrerollTime)
  PROCNAMEC()
  ; adjust MTCTime backwards to allow for the preroll time, but ignore milliseconds (and therefore frames) in the specified preroll time
  Protected nHours, nMinutes, nSeconds, nFrames
  Protected nMTCSeconds, nPrerollSeconds
  Protected nNewMTCTime
  
  debugMsg(sProcName, #SCS_START + ", nMTCTime=" + decodeMTCTime(nMTCTime) + ", nPrerollTime=" + nPrerollTime)
  
  nHours = (nMTCTime >> 24) & $1F
  nMinutes = (nMTCTime >> 16) & $3F
  nSeconds = (nMTCTime >> 8) & $3F
  nFrames = nMTCTime & $1F
  debugMsg(sProcName, "nMTCTime=" + nMTCTime + ", nHours=" + nHours + ", nMinutes=" + nMinutes + ", nSeconds=" + nSeconds + ", nFrames=" + nFrames)
  
  nMTCSeconds = (nHours * 3600) + (nMinutes * 60) + nSeconds
  nPrerollSeconds = nPrerollTime / 1000
  nMTCSeconds - nPrerollSeconds
  
  If nMTCSeconds < 0                        ; fix for negative timecodes caused by preroll, 00:00:00:00 + preroll of 10 seconds now gives 23:59:50:00. Dee 09/10/24
    nMTCSeconds + 86400
  EndIf 
  
  nHours = nMTCSeconds / 3600
  nMTCSeconds % 3600
  nMinutes = nMTCSeconds / 60
  nMTCSeconds % 60
  nSeconds = nMTCSeconds
  nNewMTCTime = (nHours << 24) | (nMinutes << 16) | (nSeconds << 8) | nFrames
  debugMsg(sProcName, "nNewMTCTime=" + nNewMTCTime + ", nHours=" + nHours + ", nMinutes=" + nMinutes + ", nSeconds=" + nSeconds + ", nFrames=" + nFrames)
  
  debugMsg(sProcName, #SCS_END + ", returning " + decodeMTCTime(nNewMTCTime))
  ProcedureReturn nNewMTCTime
EndProcedure

Procedure validateMTCField(pField.s, pPrompt.s, nTimecodeType=#SCS_TIMECODE_MTC)
  PROCNAMEC()
  ; sMTCTime must be in format 'hh:mm:ss:ff'
  Protected sMTCTime.s
  Protected nValidationFailPoint
  Protected nHours, nMinutes, nSeconds, nFrames
  Protected nMTCTime
  Protected sMsg.s, sNotValid.s

  sMTCTime = Trim(pField)
  
  ; debugMsg(sProcName, "sMyString=" + sMyString)
  
  While #True
    If Len(sMTCTime) > 0
      If CountString(sMTCTime, ":") <> 3
        nValidationFailPoint = 1
        Break
      EndIf
      
      If checkValidChars(sMTCTime, "0123456789:") = #False
        nValidationFailPoint = 2
        Break
      EndIf
      
      nHours = Val(StringField(sMTCTime, 1, ":"))
      nMinutes = Val(StringField(sMTCTime, 2, ":"))
      nSeconds = Val(StringField(sMTCTime, 3, ":"))
      nFrames = Val(StringField(sMTCTime, 4, ":"))
      
      If nMinutes > 59
        nValidationFailPoint = 3
        Break
      ElseIf nSeconds > 59
        nValidationFailPoint = 4
        Break
      ElseIf nFrames >= 30
        nValidationFailPoint = 5
        Break
      EndIf
      
    EndIf
    Break
  Wend
  
  If nValidationFailPoint = 0
    ; debugMsg(sProcName, "sMTCTime=" + sMTCTime + ", sTime=" + sTime + ", sFrames=" + sFrames)
    ; debugMsg(sProcName, "nHours=" + Str(nHours) + ", nMinutes=" + Str(nMinutes) + ", nSeconds=" + Str(nSeconds) + ", nFrames=" + Str(nFrames))
    nMTCTime = (nHours << 24) | (nMinutes << 16) | (nSeconds << 8) | nFrames
    ; debugMsg(sProcName, "nMTCTime=" + Str(nMTCTime))
    gsTmpString = decodeMTCTime(nMTCTime)
    ProcedureReturn #True
  Else
    ensureSplashNotOnTop()
    If nTimecodeType = #SCS_TIMECODE_LTC
      sNotValid = Lang("Common", "NotValidForLTC")
    Else
      sNotValid = Lang("Common", "NotValidForMTC")
    EndIf
    sMsg = Lang("Common", "TheValueIn") + " '" + pPrompt + "' (" + pField + ") " + sNotValid
    debugMsg(sProcName, sMsg)
    debugMsg(sProcName, "nValidationFailPoint=" + nValidationFailPoint)
    scsMessageRequester(grText\sTextValErr,sMsg,#PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
EndProcedure

Procedure.s decodeMTCFrameRate(nMTCFrameRate)
  PROCNAMEC()
  Protected sMTCFrameRate.s
  
  Select nMTCFrameRate
    Case #SCS_MTC_FR_24
      sMTCFrameRate = "24"
    Case #SCS_MTC_FR_25
      sMTCFrameRate = "25"
    Case #SCS_MTC_FR_29_97
      sMTCFrameRate = "29.97"
    Case #SCS_MTC_FR_30
      sMTCFrameRate = "30"
    Default
      sMTCFrameRate = ""
  EndSelect
  ProcedureReturn sMTCFrameRate
EndProcedure

Procedure.s decodeMTCFrameRateL(nMTCFrameRate)
  PROCNAMEC()
  Protected sMTCFrameRate.s
  
  sMTCFrameRate = decodeMTCFrameRate(nMTCFrameRate)
  Select nMTCFrameRate
    Case #SCS_MTC_FR_NOT_SET
      sMTCFrameRate = ""
    Case #SCS_MTC_FR_29_97
      sMTCFrameRate + " fps " + Lang("MIDI", "DropFrame")
    Default
      sMTCFrameRate + " fps"
  EndSelect
  ProcedureReturn sMTCFrameRate
EndProcedure

Procedure encodeMTCFrameRate(sMTCFrameRate.s)
  PROCNAMEC()
  Protected nMTCFrameRate
  
  Select sMTCFrameRate
    Case "24"
      nMTCFrameRate = #SCS_MTC_FR_24
    Case "25"
      nMTCFrameRate = #SCS_MTC_FR_25
    Case "29.97"
      nMTCFrameRate = #SCS_MTC_FR_29_97
    Case "30"
      nMTCFrameRate = #SCS_MTC_FR_30
    Default
      nMTCFrameRate = #SCS_MTC_FR_NOT_SET
  EndSelect
  ProcedureReturn nMTCFrameRate
EndProcedure

Procedure setTimeCodeGeneratorForSub(pSubPtr, bApplyPreroll, pReqdStartTimeCode.s="")
  PROCNAMECS(pSubPtr)
  Protected sSMSCommand.s
  Protected nReqdLTCStartTime, sReqdStartTimeCode.s, nLTCDevNo, nDevMapDevPtr, nPhysicalDevPtr
  Protected n, nTCGenIndex, sTCChannel.s, sOutputChannel.s
  
  debugMsg(sProcName, #SCS_START)
  
  nTCGenIndex = aSub(pSubPtr)\nTCGenIndex
  If nTCGenIndex >= 0
    nLTCDevNo = getLTCDevNo(@grProd)
    ; debugMsgSMS(sProcName, "getLTCDevNo() returned " + nLTCDevNo)
    If nLTCDevNo >= 0
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, grProd\aAudioLogicalDevs(nLTCDevNo)\sLogicalDev)
      ; debugMsgSMS(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
      If nDevMapDevPtr >= 0
        sTCChannel = gaSMSTCGenerator(nTCGenIndex)\sTCChannel
        ; build and send the SM-S command to set the timecode generator
        sSMSCommand = "set tcgen p" + sTCChannel
        Select aSub(pSubPtr)\nMTCFrameRate
          Case #SCS_MTC_FR_24
            sSMSCommand + " code smpte24 "
          Case #SCS_MTC_FR_25
            sSMSCommand + " code smpte25 "
          Case #SCS_MTC_FR_29_97
            sSMSCommand + " code smpte30drop "
          Case #SCS_MTC_FR_30
            sSMSCommand + " code smpte30 "
        EndSelect
        If pReqdStartTimeCode
          sReqdStartTimeCode = pReqdStartTimeCode
        Else
          nReqdLTCStartTime = aSub(pSubPtr)\nMTCStartTime
          If (aSub(pSubPtr)\nMTCPreRoll > 0) And (bApplyPreroll)
            nReqdLTCStartTime = adjustMTCTimeByPrerollTime(nReqdLTCStartTime, aSub(pSubPtr)\nMTCPreRoll)
          EndIf
          sReqdStartTimeCode = decodeMTCTime(nReqdLTCStartTime, #False)
        EndIf
        
        sSMSCommand + "start tc " + sReqdStartTimeCode
        
        If gn_ScsLTCAllowed = #True
          CompilerIf #c_scsltc
            sendLTCCommand(sSMSCommand + " " + Str(pSubPtr))
          CompilerEndIf
        Else
          sendSMSCommand(sSMSCommand)
          
          ; build and send the SM-S command to define the timecode generator/output crosspoint
          If grMaps\aDev(nDevMapDevPtr)\bNoDevice = #False
            nPhysicalDevPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
            If nPhysicalDevPtr >= 0
              sOutputChannel = Str(grMaps\aDev(nDevMapDevPtr)\nFirst1BasedOutputChan - 1 + gaAudioDev(nPhysicalDevPtr)\nFirst0BasedOutputChanAG)
            Else
              sOutputChannel = "1000" ; output channel 1000 is a 'fake output channel'
            EndIf
            gaSMSTCGenerator(nTCGenIndex)\sTCGainCommand = "set chan px" + sTCChannel + "." + sOutputChannel + " gaindb 0"
            gaSMSTCGenerator(nTCGenIndex)\sTCMuteCommand = "set chan px" + sTCChannel + "." + sOutputChannel + " gain 0"
            sendSMSCommand(gaSMSTCGenerator(nTCGenIndex)\sTCGainCommand)
          EndIf
          gaSMSTCGenerator(nTCGenIndex)\sTCGainCommand = "set chan px" + sTCChannel + "." + sOutputChannel + " gaindb 0"
          gaSMSTCGenerator(nTCGenIndex)\sTCMuteCommand = "set chan px" + sTCChannel + "." + sOutputChannel + " gain 0"
          sendSMSCommand(gaSMSTCGenerator(nTCGenIndex)\sTCGainCommand)
        EndIf
      EndIf ; EndIf nDevMapDevPtr >= 0
    EndIf ; EndIf nLTCDevNo >= 0
  EndIf ; EndIf nTCGenIndex >= 0
  
EndProcedure

Procedure assignAndSetTimeCodeGeneratorForSub(pSubPtr, bApplyPreroll, bForceAssign=#False)
  PROCNAMECS(pSubPtr)
  Protected sSMSCommand.s
  Protected nReqdLTCStartTime, nLTCDevNo, nDevMapDevPtr, nPhysicalDevPtr
  Protected n, nTCGenIndex = -1, bTCGenAssigned
  Protected nMaxTCGenIndex, nGenSubPtr, nGenCuePtr
  Protected nSubOrderKey, nMaxSubOrderKey, nMaxSub
  
  debugMsg(sProcName, #SCS_START)
  
  aSub(pSubPtr)\nTCGenIndex = -1 ; will remain at -1 if not assigned in this procedure
  If (aSub(pSubPtr)\bSubTypeU) And (aSub(pSubPtr)\nMTCType = #SCS_MTC_TYPE_LTC)
    nLTCDevNo = getLTCDevNo(@grProd)
    ; debugMsgSMS(sProcName, "getLTCDevNo() returned " + nLTCDevNo)
    If nLTCDevNo >= 0
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, grProd\aAudioLogicalDevs(nLTCDevNo)\sLogicalDev)
      ; debugMsgSMS(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
      If nDevMapDevPtr >= 0
        ; find a free timecode generator
        nMaxTCGenIndex = ArraySize(gaSMSTCGenerator())
        For n = 0 To nMaxTCGenIndex
          ; debugMsgSMS(sProcName, "gaSMSTCGenerator(" + n + ")\sTCChannel=" + gaSMSTCGenerator(n)\sTCChannel + ", \nSubPtr=" + getSubLabel(gaSMSTCGenerator(n)\nSubPtr))
          If gaSMSTCGenerator(n)\nSubPtr < 0
            nTCGenIndex = n
            Break
          EndIf
        Next n
        If (nTCGenIndex < 0) And (bForceAssign)
          ; no free timecode generator, so try to free a generator
          nMaxSub = -1
          For n = 0 To nMaxTCGenIndex
            nGenSubPtr = gaSMSTCGenerator(n)\nSubPtr
            If nGenSubPtr >= 0
              If aSub(nGenSubPtr)\nSubState < #SCS_CUE_FADING_IN Or aSub(nGenSubPtr)\nSubState > #SCS_CUE_FADING_OUT
                nGenCuePtr = aSub(nGenSubPtr)\nCueIndex
                If aCue(nGenCuePtr)\nCueState < #SCS_CUE_FADING_IN Or aCue(nGenCuePtr)\nCueState > #SCS_CUE_FADING_OUT
                  nSubOrderKey = (nGenCuePtr << 8) + aSub(nGenSubPtr)\nSubNo
                  If nSubOrderKey > nMaxSubOrderKey
                    nMaxSubOrderKey = nSubOrderKey
                    nMaxSub = nGenSubPtr
                  EndIf
                EndIf
              EndIf
            EndIf
          Next n
          If nMaxSub >= 0
            ; grab the nTCGenIndex from this Sub
            nTCGenIndex = aSub(nMaxSub)\nTCGenIndex
            ; and de-allocate it from that Sub
            aSub(nMaxSub)\nTCGenIndex = grSubDef\nTCGenIndex
            gaSMSTCGenerator(nTCGenIndex)\nSubPtr = -1 ; -1 = this generator not currently assigned to a Sub
          EndIf
        EndIf ; EndIf (nTCGenIndex < 0) And (bForceAssign)
        
        ; debugMsgSMS(sProcName, "nTCGenIndex=" + nTCGenIndex)
        If nTCGenIndex >= 0
          ; free timecode generator found, so now assign to this sub
          aSub(pSubPtr)\nTCGenIndex = nTCGenIndex
          bTCGenAssigned = #True
          gaSMSTCGenerator(nTCGenIndex)\nSubPtr = pSubPtr
          setTimeCodeGeneratorForSub(pSubPtr, bApplyPreroll)
        EndIf ; EndIf nTCGenIndex >= 0
      EndIf ; EndIf nDevMapDevPtr >= 0
    EndIf ; EndIf nLTCDevNo >= 0
  EndIf ; EndIf (\bSubTypeU) And (\nMTCType = #SCS_MTC_TYPE_LTC)
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bTCGenAssigned))
  ProcedureReturn bTCGenAssigned
  
EndProcedure

Procedure pauseTimeCode(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nTCGenIndex
  Protected sSMSCommand.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(pSubPtr)
    Select \nMTCType
      Case #SCS_MTC_TYPE_LTC
        nTCGenIndex = \nTCGenIndex
        If nTCGenIndex >= 0
          sSMSCommand = "pause p" + gaSMSTCGenerator(nTCGenIndex)\sTCChannel
          
          If gn_ScsLTCAllowed = #True
            CompilerIf #c_scsltc
              sendLTCCommand(sSMSCommand)
            CompilerEndIf
          Else
            sendSMSCommand(sSMSCommand)
            sendSMSCommand(gaSMSTCGenerator(nTCGenIndex)\sTCMuteCommand)  ; seems necessary to mute the LTC output or some low level audio signal is still sent
          EndIf
          
          grSMS\bLTCRunning = #False
          debugMsg(sProcName, "grSMS\bLTCRunning=" + strB(grSMS\bLTCRunning))
        EndIf
        
      Case #SCS_MTC_TYPE_MTC
        grMTCSendControl\nMTCThreadRequest | #SCS_MTC_THR_PAUSE_MTC
        debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
        
    EndSelect
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure startTimeCode(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nTCGenIndex
  Protected sSMSCommand.s
  
  Select aSub(pSubPtr)\nMTCType
    Case #SCS_MTC_TYPE_LTC
      nTCGenIndex = aSub(pSubPtr)\nTCGenIndex
      If nTCGenIndex >= 0
        sSMSCommand = "play p" + gaSMSTCGenerator(nTCGenIndex)\sTCChannel
        
        If gn_ScsLTCAllowed = #True
          CompilerIf #c_scsltc
            sendLTCCommand(sSMSCommand)
          CompilerEndIf
        Else
         sendSMSCommand(gaSMSTCGenerator(nTCGenIndex)\sTCGainCommand)
          sendSMSCommand(sSMSCommand)
        EndIf

        grSMS\bLTCRunning = #True
        debugMsg(sProcName, "grSMS\bLTCRunning=" + strB(grSMS\bLTCRunning))
      EndIf
  EndSelect
EndProcedure

Procedure resumeTimeCode(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nTCGenIndex
  Protected sSMSCommand.s
  
  Select aSub(pSubPtr)\nMTCType
    Case #SCS_MTC_TYPE_LTC
      nTCGenIndex = aSub(pSubPtr)\nTCGenIndex
      If nTCGenIndex >= 0
        If gn_ScsLTCAllowed = #True
          CompilerIf #c_scsltc
            sSMSCommand = "resume p" + gaSMSTCGenerator(nTCGenIndex)\sTCChannel
            sendLTCCommand(sSMSCommand)
          CompilerEndIf
        Else
          sendSMSCommand(gaSMSTCGenerator(nTCGenIndex)\sTCGainCommand)
          sSMSCommand = "resume p" + gaSMSTCGenerator(nTCGenIndex)\sTCChannel
          sendSMSCommand(sSMSCommand)
        EndIf

        grSMS\bLTCRunning = #True
        debugMsg(sProcName, "grSMS\bLTCRunning=" + strB(grSMS\bLTCRunning))
      EndIf
      
    Case #SCS_MTC_TYPE_MTC
      With grMTCSendControl
        QueryPerformanceCounter_(@\qQPCTimeStarted.q)
        debugMsg(sProcName, "grMTCSendControl\qQPCTimeStarted=" + \qQPCTimeStarted)
        \qMTCStartTimeAsMicroseconds = (\nHours * 3600000000) + (\nMinutes * 60000000) + (\nSeconds * 1000000)
        \qMTCStartTimeAsMicroseconds + (1000000 * \nFrames * 100 / \nMTCFrameRateX100)
        debugMsg(sProcName, "\nHours=" + Str(\nHours) + ", nMinutes=" + Str(\nMinutes) + ", nSeconds=" + Str(\nSeconds) + ", nFrames=" + Str(\nFrames))
        debugMsg(sProcName, "\qMTCStartTimeAsMicroseconds=" + \qMTCStartTimeAsMicroseconds)
        debugMsg(sProcName, "MTC Time: " + RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0"))
        \qMinNextElapsedFrame = -1  ; forces first set of quarter frames to be sent
        debugMsg(sProcName, "grMTCSendControl\qMinNextElapsedFrame=" + grMTCSendControl\qMinNextElapsedFrame)
        \nMTCSendState = #SCS_MTC_STATE_RUNNING
        debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
      EndWith
  EndSelect
EndProcedure

Procedure stopTimeCode(pSubPtr, bFreeTCGenerator=#True)
  PROCNAMECS(pSubPtr)
  Protected nTCGenIndex
  Protected sSMSCommand.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(pSubPtr)
    Select \nMTCType
      Case #SCS_MTC_TYPE_LTC
        nTCGenIndex = \nTCGenIndex
        If nTCGenIndex >= 0
          sSMSCommand = "stop p" + gaSMSTCGenerator(nTCGenIndex)\sTCChannel
          
          If gn_ScsLTCAllowed = #True
            CompilerIf #c_scsltc  
              sendLTCCommand(sSMSCommand)
            CompilerEndIf
          Else
            sendSMSCommand(sSMSCommand)
            sendSMSCommand(gaSMSTCGenerator(nTCGenIndex)\sTCMuteCommand)  ; seems necessary to mute the LTC output or some low level audio signal is still sent
          EndIf
          
          grSMS\bLTCRunning = #False
          debugMsg(sProcName, "grSMS\bLTCRunning=" + strB(grSMS\bLTCRunning))
          If bFreeTCGenerator
            gaSMSTCGenerator(nTCGenIndex)\nSubPtr = -1
            \nTCGenIndex = grSubDef\nTCGenIndex
          EndIf
        EndIf
        
      Case #SCS_MTC_TYPE_MTC
        If grMTCSendControl\nMTCSubPtr = pSubPtr
          grMTCSendControl\nMTCThreadRequest | #SCS_MTC_THR_STOP_MTC
          debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
        EndIf
        
    EndSelect
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure stopAllTimeCodes()
  PROCNAMEC()
  Protected n, nTimeOut = 2500
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To ArraySize(gaSMSTCGenerator())
    With gaSMSTCGenerator(n)
      If \nSubPtr >= 0
        stopTimeCode(\nSubPtr)
      EndIf
    EndWith
  Next n
  
  debugMsg(sProcName, "THR_getThreadState(#SCS_THREAD_MTC_CUES) returned " + THR_decodeThreadState(THR_getThreadState(#SCS_THREAD_MTC_CUES)))
  If THR_getThreadState(#SCS_THREAD_MTC_CUES) = #SCS_THREAD_STATE_ACTIVE
    grMTCSendControl\nMTCThreadRequest | #SCS_MTC_THR_STOP_MTC
    debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
    debugMsg(sProcName, "calling THR_waitForAThreadToStop(#SCS_THREAD_MTC_CUES, " + nTimeOut + ", #True)")
    THR_waitForAThreadToStop(#SCS_THREAD_MTC_CUES, nTimeOut, #True)
    debugMsg(sProcName, "returned from THR_waitForAThreadToStop(#SCS_THREAD_MTC_CUES, " + nTimeOut + ", #True)")
    debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
  EndIf
  
  If gbClosingDown = #False
    If IsWindow(#WTC)
      setWindowVisible(#WTC, #False)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure reposTimeCode(pSubPtr, pReposAt, bMTCMutexAlreadyLocked=#False, bSendMTCNow=#True)
  PROCNAMECS(pSubPtr)
  Protected nSeconds, nFrames, nFrameMilliseconds
  Protected nReqdMillisecondTime, nReqdMTCTime, sReqdTimeCode.s
  Protected nTmpTime, nReqdPreroll
  Protected nMilliSeconds
  Protected dFrames.d
  Protected bChangedToReady
  Protected bSkipSendingFullFrame
  Protected bCurrentlyPaused
  Protected sPortName.s
  Protected bLockedMutex
  Protected nMTCType
  Protected nSubState
  
  debugMsg(sProcName, #SCS_START + ", pReposAt=" + pReposAt + ", bMTCMutexAlreadyLocked=" + strB(bMTCMutexAlreadyLocked) + ", bSendMTCNow=" + strB(bSendMTCNow))
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      nMTCType = \nMTCType
      nSubState = \nSubState
      \nSubPosition = pReposAt
      ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition)
      If \nSubPosition < 0
        \nSubPosition = 0
      ElseIf (\nMTCDuration > 0) And (\nSubPosition > \nMTCDuration)
        \nSubPosition = \nMTCDuration
      EndIf
      debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition)
      If (nSubState < #SCS_CUE_FADING_IN) Or (nSubState > #SCS_CUE_FADING_OUT)
        \bSubCheckProgSlider = #True
      Else
        \bSubCheckProgSlider = #False
      EndIf
    EndWith
    
    If bSendMTCNow
      With grMTCSendControl
        If \nMTCSubPtr = pSubPtr
          debugMsg(sProcName, "grMTCSendControl\nMTCSubPtr=" + getSubLabel(\nMTCSubPtr))
          
          If nMTCType = #SCS_MTC_TYPE_MTC
            If bMTCMutexAlreadyLocked = #False
              LockMTCSendMutex(503, #True)
            EndIf
          EndIf
          
          gqTimeNow = ElapsedMilliseconds()
          aSub(pSubPtr)\qAdjTimeSubStarted = gqTimeNow - pReposAt
          debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\qAdjTimeSubStarted=" + traceTime(aSub(pSubPtr)\qAdjTimeSubStarted) +
                              ", \nSubState=" + decodeCueState(nSubState) + ", \nSubPosition=" + aSub(pSubPtr)\nSubPosition)
          aSub(pSubPtr)\nSubTotalTimeOnPause = 0
          If nSubState = #SCS_CUE_PAUSED
            aSub(pSubPtr)\nSubPriorTimeOnPause = 0
            aSub(pSubPtr)\qSubTimePauseStarted = gqTimeNow
            debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + aSub(pSubPtr)\nSubPosition)
            If aSub(pSubPtr)\nSubPosition = 0
              aSub(pSubPtr)\nSubState = #SCS_CUE_READY
              nSubState = aSub(pSubPtr)\nSubState
              setCueState(aSub(pSubPtr)\nCueIndex)
              bChangedToReady = #True
              If (grMTCSendControl\nMTCSubPtr = pSubPtr) And (nMTCType = #SCS_MTC_TYPE_MTC)
                debugMsg0(sProcName, "calling THR_suspendAThread(#SCS_THREAD_MTC_CUES)")
                THR_suspendAThread(#SCS_THREAD_MTC_CUES)
              EndIf
              bSkipSendingFullFrame = #True
            EndIf
          EndIf
          
          ; debugMsg(sProcName, "\nMTCStartTime=" + decodeMTCTime(\nMTCStartTime) + ", \nMTCPreRoll=" + \nMTCPreRoll)
          If \nMTCPreRoll > 0
            nReqdPreroll = \nMTCPreRoll
          EndIf
          
          If pReposAt < nReqdPreroll
            nReqdMillisecondTime = convertMTCTimeToMilliseconds(\nMTCStartTime, \nMTCFrameRateX100)
          Else
            nReqdMillisecondTime = pReposAt + convertMTCTimeToMilliseconds(\nMTCStartTime, \nMTCFrameRateX100) - nReqdPreroll
          EndIf
          ; debugMsg(sProcName, "nReqdMillisecondTime=" + nReqdMillisecondTime)
          ; added 4Jun2018 11.7.1 post rc1 to allow for preroll taking the reqd time negative - the maxim time code is 23:59:59:ff, after which it cycles back to 00:00:00:00
          If nReqdMillisecondTime < 0
            nReqdMillisecondTime + 86400000 ; 86400000 = number of millisconds in a day
          EndIf
          nReqdMillisecondTime % 86400000 ; throw away any 'days' in the new required time
          ; end added 4Jun2018
          \nHours = nReqdMillisecondTime / 3600000
          nTmpTime = nReqdMillisecondTime - (\nHours * 3600000)
          \nMinutes = nTmpTime / 60000
          nTmpTime - (\nMinutes * 60000)
          \nSeconds = nTmpTime / 1000
          nMilliSeconds = nTmpTime - (\nSeconds * 1000)
          ; debugMsg(sProcName, "\nMTCMillisecondsPerFrame=" + \nMTCMillisecondsPerFrame + ", \dMTCMillisecondsPerFrame=" + StrD(\dMTCMillisecondsPerFrame,4) + ", \nMTCFrameRate=" + \nMTCFrameRate + ", \nMTCFrameRateX100=" + \nMTCFrameRateX100)
          If \nMTCMillisecondsPerFrame > 0
            \nFrames = nMilliSeconds / \nMTCMillisecondsPerFrame
          Else
            dFrames = Round(nMilliSeconds / \dMTCMillisecondsPerFrame, #PB_Round_Down)
            ; debugMsg(sProcName, "dFrames=" + StrD(dFrames,4) + ", nTmpTime=" + Str(nTmpTime) + ", \nSeconds=" + Str(\nSeconds) + ", nMilliSeconds=" + Str(nMilliSeconds))
            \nFrames = dFrames
          EndIf
          ; debugMsg(sProcName, "\nHours=" + \nHours + ", \nMinutes=" + \nMinutes + ", \nSeconds=" + \nSeconds + ", \nFrames=" + \nFrames)
          
          grMTCControl\bClearPrevTimeCodeProcessed = #True  ; added 29Oct2015 11.4.1.2e
          ; debugMsg(sProcName, "grMTCControl\bClearPrevTimeCodeProcessed=" + strB(grMTCControl\bClearPrevTimeCodeProcessed))
          
          Select nMTCType
            Case #SCS_MTC_TYPE_MTC
              debugMsg(sProcName, "nReqdMillisecondTime=" + nReqdMillisecondTime + ", \nHours=" + \nHours + ", nMinutes=" + \nMinutes + ", nSeconds=" + \nSeconds + ", nFrames=" + \nFrames + ", bSkipSendingFullFrame=" + strB(bSkipSendingFullFrame))
              If bSkipSendingFullFrame = #False
                If nSubState = #SCS_CUE_PAUSED
                  bCurrentlyPaused = #True
                EndIf
                If pReposAt < \nMTCPreRoll
                  debugMsg(sProcName, "calling SendMTCFullFrameForRepos(#True, #True, " + strB(bCurrentlyPaused) + ")")
                  sPortName = SendMTCFullFrameForRepos(#True, #True, bCurrentlyPaused)
                Else
                  debugMsg(sProcName, "calling SendMTCFullFrameForRepos(#True, #False, " + strB(bCurrentlyPaused) + ")")
                  sPortName = SendMTCFullFrameForRepos(#True, #False, bCurrentlyPaused)
                EndIf
              EndIf
            Case #SCS_MTC_TYPE_LTC
              sReqdTimeCode = Str(\nHours) + ":" + Str(\nMinutes) + ":" + Str(\nSeconds) + ":" + Str(\nFrames)
              stopTimeCode(pSubPtr, #False)
              setTimeCodeGeneratorForSub(pSubPtr, #False, sReqdTimeCode)
              startTimeCode(pSubPtr)
          EndSelect
          
          If bChangedToReady
            gqMainThreadRequest | #SCS_MTH_SET_CUE_TO_GO
          EndIf
          
          If nMTCType = #SCS_MTC_TYPE_MTC
            If bMTCMutexAlreadyLocked = #False
              UnlockMTCSendMutex(#True)
            EndIf
            If nSubState >= #SCS_CUE_FADING_IN And nSubState <= #SCS_CUE_FADING_OUT
              If nSubState <> #SCS_CUE_PAUSED And nSubState <> #SCS_CUE_HIBERNATING
                debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)")
                THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)
              EndIf
            EndIf 
          EndIf
          
        EndIf
      EndWith
    EndIf
    
    With aSub(pSubPtr)
      If \nSubState = #SCS_CUE_PAUSED
        \nSubPriorTimeOnPause = 0
        \qSubTimePauseStarted = gqTimeNow
      EndIf
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure MTC_getMTCSubForThisSub(pThisSubPtr)
  Protected i, j, nMTCSubPtr
  
  nMTCSubPtr = -1
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeU
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeU And aSub(j)\nMTCLinkedToAFSubPtr = pThisSubPtr
          nMTCSubPtr = j
          Break 2 ; Break j, i
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  ProcedureReturn nMTCSubPtr
EndProcedure

Procedure MTC_StartOrRestartTimeCodeForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nLinkedSubPtr, nLinkedAudPtr, nChannel.l, nAbsFilePos, nRelFilePos
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START)
  
  nLinkedSubPtr = aSub(pSubPtr)\nMTCLinkedToAFSubPtr
  If nLinkedSubPtr >= 0
    If aSub(nLinkedSubPtr)\bSubTypeAorF
      nLinkedAudPtr = aSub(nLinkedSubPtr)\nFirstAudIndex
      If nLinkedAudPtr >= 0
        LockMTCSendMutex(520, #True)
        If aAud(nLinkedAudPtr)\bAudTypeF
          nChannel = getBassChannelForAud(nLinkedAudPtr)
          If nChannel <> 0
            nAbsFilePos = GetPlayingPos(nLinkedAudPtr, nChannel, 5, #True)
            If nAbsFilePos >= 0
              nRelFilePos = nAbsFilePos - aAud(nLinkedAudPtr)\nAbsMin
              debugMsg(sProcName, "calling reposTimeCode(" + getSubLabel(pSubPtr) + ", " + ttszt(nRelFilePos) + ", #True, #False)")
              reposTimeCode(pSubPtr, nRelFilePos, #True) ;, #False) ; Changed 4Jan2023 11.10.0ab: added #False for bSendMTCNow
            EndIf
          EndIf
        ElseIf aAud(nLinkedAudPtr)\bAudTypeA
          debugMsg(sProcName, "aAud(" + getAudLabel(nLinkedAudPtr) + ")\nPlayTVGIndex=" + aAud(nLinkedAudPtr)\nPlayTVGIndex)
          If aAud(nLinkedAudPtr)\nPlayTVGIndex >= 0
            nRelFilePos = getVideoPosition(nLinkedAudPtr)
            debugMsg(sProcName, "calling reposTimeCode(" + getSubLabel(pSubPtr) + ", " + ttszt(nRelFilePos) + ", #True, #False)")
            reposTimeCode(pSubPtr, nRelFilePos, #True) ;, #False) ; Changed 4Jan2023 11.10.0ab: added #False for bSendMTCNow
          EndIf
        EndIf
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(aSub(pSubPtr)\nSubState))
        If aSub(pSubPtr)\nSubState = #SCS_CUE_PAUSED
          debugMsg(sProcName, "calling resumeSub(" + buildSubLabel(pSubPtr) + ")")
          resumeSub(pSubPtr)
        EndIf
        UnlockMTCSendMutex(#False)
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure MTC_syncTimeCode(pHandle.l, pChannel.l, pData, pUser)
  PROCNAME(#PB_Compiler_Procedure + " pHandle=" + decodeHandle(pHandle) + ", pChannel=" + decodeHandle(pChannel) + ", pUser=" + getSubLabel(pUser))

  ;========================================
  ; no system calls in callback procedures!
  ;========================================
  
  gqPriorityPostEventWaiting = ElapsedMilliseconds()
  PostEvent(#SCS_Event_StartOrRestartTimeCodeForSub, #WMN, 0, 0, pUser)
  debugMsg(sProcName, "PostEvent(#SCS_Event_StartOrRestartTimeCodeForSub, #WMN, 0, 0, " + getSubLabel(pUser) + "), gqPriorityPostEventWaiting=" + traceTime(gqPriorityPostEventWaiting))
  
EndProcedure

Procedure MTC_setSyncTimeCode(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nLinkedToSubPtr, nLinkedToAudPtr, nLinkedAudChannel.l, sLinkedAudHandle.s, nPosSyncType.l, sPosSyncType.s
  Protected qCurrBytePos.q, qReqdBytePos.q, dCurrTimePos.d, dReqdTimePos.d, dTimePos2.d
  Protected nVideoPos
  Protected bSetSync, nBassResult.l, bAudio, bVideo
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(pSubPtr)
    If \bSubTypeU
      nLinkedToSubPtr = \nMTCLinkedToAFSubPtr
      If nLinkedToSubPtr >= 0
        If aSub(nLinkedToSubPtr)\bSubTypeAorF
          nLinkedToAudPtr = aSub(nLinkedToSubPtr)\nFirstAudIndex
          If nLinkedToAudPtr >= 0
            If aAud(nLinkedToAudPtr)\bAudTypeA
              bVideo = #True
              bSetSync = #True
            Else
              bAudio = #True
              nLinkedAudChannel = getBassChannelForAud(nLinkedToAudPtr)
              If nLinkedAudChannel <> 0
                bSetSync = #True
                sLinkedAudHandle = decodeHandle(nLinkedAudChannel)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      
      If bSetSync
        If bAudio
          debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nMTCStartOrRestartTimeCodeSync=" + \nMTCStartOrRestartTimeCodeSync)
          If \nMTCStartOrRestartTimeCodeSync <> 0
            If gbUseBASSMixer
              nBassResult = BASS_Mixer_ChannelRemoveSync(nLinkedAudChannel, \nMTCStartOrRestartTimeCodeSync)
              debugMsg2(sProcName, "BASS_Mixer_ChannelRemoveSync(" + sLinkedAudHandle + ", " + decodeHandle(\nMTCStartOrRestartTimeCodeSync) + ")", nBassResult)
            Else
              nBassResult = BASS_ChannelRemoveSync(nLinkedAudChannel, \nMTCStartOrRestartTimeCodeSync)
              debugMsg2(sProcName, "BASS_ChannelRemoveSync(" + sLinkedAudHandle + ", " + decodeHandle(\nMTCStartOrRestartTimeCodeSync) + ")", nBassResult)
            EndIf
            \nMTCStartOrRestartTimeCodeSync = 0
          EndIf
          ; 25Mar2021 11.8.3g - moved to AFTER call to BASS_Split_StreamReset() as this affects the current position
          ;         qCurrBytePos = BASS_ChannelGetPosition(nLinkedAudChannel, #BASS_POS_BYTE)
          ;         debugMsg(sProcName, "BASS_ChannelGetPosition(" + sLinkedAudHandle + ", #BASS_POS_BYTE) returned " + qCurrBytePos)
          ;         qReqdBytePos = qCurrBytePos
          ;         dCurrTimePos = BASS_ChannelBytes2Seconds(nLinkedAudChannel, qCurrBytePos)
          ;         debugMsg(sProcName, "BASS_ChannelBytes2Seconds(" + sLinkedAudHandle + ", " + qCurrBytePos + ") returned " + StrD(dCurrTimePos,4))
          ;         dReqdTimePos = dCurrTimePos
          ;         While qReqdBytePos = qCurrBytePos
          ;           ; dReqdTimePos + 0.0005
          ;           dReqdTimePos + 0.001
          ;           ; dReqdTimePos + 0.01
          ;           qReqdBytePos = BASS_ChannelSeconds2Bytes(nLinkedAudChannel, dReqdTimePos)
          ;           debugMsg(sProcName, "BASS_ChannelSeconds2Bytes(" + sLinkedAudHandle + ", " + StrD(dReqdTimePos,4) + ") returned " + qReqdBytePos)
          ;         Wend
          ; 25Mar2021 11.8.3g - end of 'moved to AFTER call to BASS_Split_StreamReset()'
          If bAudio And aAud(nLinkedToAudPtr)\bUsingSplitStream
            nBassResult = BASS_Split_StreamReset(nLinkedAudChannel)
            debugMsg2(sProcName, "BASS_Split_StreamReset(" + sLinkedAudHandle + ")", nBassResult)
            ; Added 17Mar2025 11.10.8am
            nBassResult = BASS_ChannelSetPosition(nLinkedAudChannel, 0, #BASS_POS_BYTE)
            debugMsg2(sProcName, "BASS_ChannelSetPosition(" + sLinkedAudHandle + ", 0, #BASS_POS_BYTE)", nBassResult)
            ; End added 17Mar2025 11.10.8am
          EndIf
          ; 25Mar2021 11.8.3ag - moved here from above
          qCurrBytePos = BASS_ChannelGetPosition(nLinkedAudChannel, #BASS_POS_BYTE)
          debugMsg(sProcName, "BASS_ChannelGetPosition(" + sLinkedAudHandle + ", #BASS_POS_BYTE) returned " + qCurrBytePos)
          ; Added 25Nov2022 11.9.7am
          If qCurrBytePos = -1
            debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            qCurrBytePos = 0
          EndIf
          ; End added 25Nov2022 11.9.7am
          qReqdBytePos = qCurrBytePos
          dCurrTimePos = BASS_ChannelBytes2Seconds(nLinkedAudChannel, qCurrBytePos)
          debugMsg(sProcName, "BASS_ChannelBytes2Seconds(" + sLinkedAudHandle + ", " + qCurrBytePos + ") returned " + StrD(dCurrTimePos,4))
          dReqdTimePos = dCurrTimePos
          While qReqdBytePos = qCurrBytePos
            dReqdTimePos + 0.001
            qReqdBytePos = BASS_ChannelSeconds2Bytes(nLinkedAudChannel, dReqdTimePos)
            debugMsg(sProcName, "BASS_ChannelSeconds2Bytes(" + sLinkedAudHandle + ", " + StrD(dReqdTimePos,4) + ") returned " + qReqdBytePos)
          Wend
          ; 25Mar2021 11.8.3ag - end of 'moved here from above'
          
          ; Added 23Mar2022 11.9.1at
          ; Reset the channel. This is necessary because BASS_ChannelUpdate() has previously been called, and if we do not reset the channel then BASS_ChannelSetSync() for a position within the update period would not fire the synhc proc
          ; (Bug reported in email from Rémy Brean 13Mar2022)
          nBassResult = BASS_ChannelSetPosition(nLinkedAudChannel, 0, #BASS_POS_BYTE)
          debugMsg2(sProcName, "BASS_ChannelSetPosition(" + sLinkedAudHandle + ", 0, #BASS_POS_BYTE)", nBassResult)
          ; End added 23Mar2022 11.9.1at
          
          nPosSyncType = #BASS_SYNC_POS
          sPosSyncType = "BASS_SYNC_POS"
          If gbUseBASSMixer
            \nMTCStartOrRestartTimeCodeSync = BASS_Mixer_ChannelSetSync(nLinkedAudChannel, nPosSyncType, qReqdBytePos, @MTC_syncTimeCode(), pSubPtr)
            newHandle(#SCS_HANDLE_SYNC, \nMTCStartOrRestartTimeCodeSync)
            debugMsg2(sProcName, "BASS_Mixer_ChannelSetSync(" + sLinkedAudHandle + ", " + sPosSyncType + ", " + qReqdBytePos + ", @MTC_syncTimeCode(), " + getSubLabel(pSubPtr) + ")", \nMTCStartOrRestartTimeCodeSync)
          Else
            \nMTCStartOrRestartTimeCodeSync = BASS_ChannelSetSync(nLinkedAudChannel, nPosSyncType, qReqdBytePos, @MTC_syncTimeCode(), pSubPtr)
            newHandle(#SCS_HANDLE_SYNC, \nMTCStartOrRestartTimeCodeSync)
            debugMsg2(sProcName, "BASS_ChannelSetSync(" + sLinkedAudHandle + ", " + sPosSyncType + ", " + qReqdBytePos + ", @MTC_syncTimeCode(), " + getSubLabel(pSubPtr) + ")", \nMTCStartOrRestartTimeCodeSync)
          EndIf
          
          ; Added 23Mar2022 11.9.1at
          ; now reset the playback position
          nBassResult = BASS_ChannelSetPosition(nLinkedAudChannel, qCurrBytePos, #BASS_POS_BYTE)
          debugMsg2(sProcName, "BASS_ChannelSetPosition(" + sLinkedAudHandle + ", " + qCurrBytePos + ", #BASS_POS_BYTE)", nBassResult)
          ; End added 23Mar2022 11.9.1at
          
        ElseIf bVideo
          ; Added 28Aug2021 11.8.6ae
          ; nVideoPos = getVideoPosition(nLinkedToAudPtr) ; returns video position in milliseconds
          gqPriorityPostEventWaiting = ElapsedMilliseconds()
          PostEvent(#SCS_Event_StartOrRestartTimeCodeForSub, #WMN, 0, 0, pSubPtr)
          debugMsg(sProcName, "PostEvent(#SCS_Event_StartOrRestartTimeCodeForSub, #WMN, 0, 0, " + getSubLabel(pSubPtr) + "), gqPriorityPostEventWaiting=" + traceTime(gqPriorityPostEventWaiting))
          ; End added 28Aug2021 11.8.6ae
        EndIf
        
      EndIf ; EndIf bSetSync
    EndIf ; EndIf \bSubTypeU
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning bSetSync=" + strB(bSetSync))
  ProcedureReturn bSetSync
  
EndProcedure

Procedure MTC_checkMTCLinkedToAudPtrValid()
  PROCNAMEC()
  Protected bValid, nAudioFileSubPtr
  
  With grMTCSendControl
    If \nMTCLinkedToAudPtr >= 0
      nAudioFileSubPtr = aAud(\nMTCLinkedToAudPtr)\nSubIndex
      If aSub(nAudioFileSubPtr)\bSubTypeF And aSub(nAudioFileSubPtr)\bSubEnabled
        If \nMTCSubPtr >= 0
          If aSub(\nMTCSubPtr)\bSubTypeU And aSub(\nMTCSubPtr)\bSubEnabled
            bValid = #True
          EndIf
        EndIf
      EndIf
      If bValid = #False
        debugMsg(sProcName, "clearing grMTCSendControl\nMTCLinkedToAudPtr")
        \nMTCLinkedToAudPtr = grMTCSendControlDef\nMTCLinkedToAudPtr ; ie -1
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure MTC_playOrResumeMTCAndLinkedAud(pSubPtr, bPlay=#True, bResume=#False)
  PROCNAMECS(pSubPtr)
  Protected nLinkedSubPtr, nLinkedAudPtr, nChannel.l, bCallSetSync, bSetSync
  Static bInThisProcedure ; Added 23Mar2022 11.9.1at
  
  debugMsg(sProcName, #SCS_START + ", bPlay=" + strB(bPlay) + ", bResume=" + strB(bResume))
  
  ; Added 23Mar2022 11.9.1at
  If bInThisProcedure
    debugMsg(sProcName, "exiting - recursive call")
    ProcedureReturn
  EndIf
  bInThisProcedure = #True
  ; End added 23Mar2022 11.9.1at
  
  nLinkedSubPtr = aSub(pSubPtr)\nMTCLinkedToAFSubPtr
  If nLinkedSubPtr >= 0
    If aSub(nLinkedSubPtr)\bSubTypeAorF ; Changed 28Aug2021 11.8.6ae
      nLinkedAudPtr = aSub(nLinkedSubPtr)\nFirstAudIndex
      ; debugMsg(sProcName, "nLinkedAudPtr=" + getAudLabel(nLinkedAudPtr))
      If nLinkedAudPtr >= 0
        debugMsg(sProcName, "aAud(" + getAudLabel(nLinkedAudPtr) + ")\nAudState=" + decodeCueState(aAud(nLinkedAudPtr)\nAudState)) ; Added 5Jul2022 11.9.3.1ab
        If aAud(nLinkedAudPtr)\bAudTypeA  ; Added 28Aug2021 11.8.6ae
          bCallSetSync = #True            ; Added 28Aug2021 11.8.6ae
        ElseIf gbUseSMS
          bCallSetSync = #True
        Else
          nChannel = getBassChannelForAud(nLinkedAudPtr)
          debugMsg(sProcName, "getBassChannelForAud(" + getAudLabel(nLinkedAudPtr) + ") returned " + nChannel)
          If nChannel <> 0
            bCallSetSync = #True
          EndIf
        EndIf
        If bCallSetSync
          debugMsg(sProcName, "calling MTC_setSyncTimeCode(" + getSubLabel(pSubPtr) + ")")
          bSetSync = MTC_setSyncTimeCode(pSubPtr)
          If bSetSync
            If bPlay
              debugMsg(sProcName, "calling playAudChannels(" + getAudLabel(nLinkedAudPtr) + ")")
              playAudChannels(nLinkedAudPtr)
            ElseIf bResume
              debugMsg(sProcName, "calling resumeAudChannels(" + getAudLabel(nLinkedAudPtr) + ")")
              resumeAudChannels(nLinkedAudPtr)
            Else
              ; neither play nor resume
            EndIf
          EndIf ; EndIf bSetSync
        EndIf ; EndIf bCallSetSync
      EndIf ; EndIf nLinkedAudPtr >= 0
    EndIf ; EndIf aSub(nLinkedSubPtr)\bSubTypeF
  EndIf ; EndIf nLinkedSubPtr >= 0
  
  bInThisProcedure = #False ; Added 23Mar2022 11.9.1at
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF