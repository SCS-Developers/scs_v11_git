; File: BassChanInfo.pbi

EnableExplicit

Procedure GetPlayingPos(pAudPtr, pChannel.l, pCaller, bTrace=#cTracePosition)
  ; Returns absolute playing position in milliseconds of a stream, and places byte position in grBCI\qChannelBytePosition
  PROCNAMECA(pAudPtr)
  Protected dPlayingPosSec.d
  Protected nPlayingPos, nFileDuration
  Static nErrorAudPtr, nErrorChannel.l
  
  If gbUseBASSMixer
    grBCI\qChannelBytePosition = BASS_Mixer_ChannelGetPosition(pChannel, #BASS_POS_BYTE)
    debugMsgC2(sProcName, "BASS_Mixer_ChannelGetPosition(" + decodeHandle(pChannel) + ", BASS_POS_BYTE)", grBCI\qChannelBytePosition)
  Else
    grBCI\qChannelBytePosition = BASS_ChannelGetPosition(pChannel, #BASS_POS_BYTE)
    debugMsgC2(sProcName, "BASS_ChannelGetPosition(" + decodeHandle(pChannel) + ", BASS_POS_BYTE)", grBCI\qChannelBytePosition)
  EndIf
  ; Added 21Nov2022 11.9.7aj following email from Christian Peters (see also call to GetPlayingPos() in SendMTCQuarterFrames()
  If grBCI\qChannelBytePosition = -1
    If pAudPtr <> nErrorAudPtr Or pChannel <> nErrorChannel
      ; limit the number of debug messages for this error
      debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()) + ", pCaller=" + pCaller)
      nErrorAudPtr = pAudPtr
      nErrorChannel = pChannel
    EndIf
    grBCI\qChannelBytePosition = 0
  EndIf
  ; End added 21Nov2022 11.9.7aj
  dPlayingPosSec = BASS_ChannelBytes2Seconds(pChannel, grBCI\qChannelBytePosition)
  debugMsgC3(sProcName, "BASS_ChannelBytes2Seconds(" + decodeHandle(pChannel) + ", " + grBCI\qChannelBytePosition + ") returned " + StrD(dPlayingPosSec, 3))
  nPlayingPos = dPlayingPosSec * 1000.0
  nFileDuration = aAud(pAudPtr)\nFileDuration
  If (nFileDuration > 0) And (nPlayingPos >= nFileDuration)
    nPlayingPos = nFileDuration - 1
  EndIf
  debugMsgC(sProcName, #SCS_END + ", returning nPlayingPos=" + nPlayingPos)
  ProcedureReturn nPlayingPos
EndProcedure

Procedure SetPlayingPos(pAudPtr, pDevNo, pMainOrAlt, pAbsNewPos, pAbsNewBytePos.q=-2.0, bForceResetPos=#False, bCheckForMTC=#True)
  PROCNAMECA(pAudPtr)
  Protected nBassResult.l
  Protected nSourceChannel.l, nSplitterChannel.l, nMixerStream.l, nChannel.l
  Protected sSourceHandle.s, sSplitterHandle.s, sMixerHandle.s, sHandle.s
  Protected dAbsPos.d
  Protected qAbsBytePosition.q
  Protected qCurrAbsBytePosition.q
  Protected nMixerStreamPtr
  Protected nActiveState.l
  Protected nThisSubPtr, nMTCSubPtr, bCallBassChannelPlayForSplitter
  
  debugMsg(sProcName, #SCS_START + ", pDevNo=" + pDevNo + ", pMainOrAlt=" + pMainOrAlt + ", pAbsNewPos=" + pAbsNewPos + ", pAbsNewBytePos=" + pAbsNewBytePos)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      
      If pMainOrAlt = #SCS_CHAN_MAIN
        nSourceChannel = \nSourceChannel
        nSplitterChannel = \nBassChannel[pDevNo]
      Else
        nSourceChannel = \nSourceAltChannel
        nSplitterChannel = \nBassAltChannel[pDevNo]
      EndIf
      nMixerStreamPtr = \nMixerStreamPtr[pDevNo]
      If nMixerStreamPtr >= 0
        nMixerStream = gaMixerStreams(nMixerStreamPtr)\nMixerStreamHandle
      EndIf
      sSourceHandle = decodeHandle(nSourceChannel)
      sSplitterHandle = decodeHandle(nSplitterChannel)
      sMixerHandle = decodeHandle(nMixerStream)
      
      If pAbsNewBytePos >= 0.0
        qAbsBytePosition = pAbsNewBytePos
        ; debugMsg(sProcName, "qAbsBytePosition=" + qAbsBytePosition)
      Else
        dAbsPos = pAbsNewPos / 1000
        qAbsBytePosition = BASS_ChannelSeconds2Bytes(nSourceChannel, dAbsPos)
        If qAbsBytePosition = -1
          debugMsg2(sProcName,"BASS_ChannelSeconds2Bytes(" + sSourceHandle + ", " + StrD(dAbsPos, 3) + ")", qAbsBytePosition)
          Error_(sProcName, "BASS_ChannelSeconds2Bytes failed")
          ProcedureReturn
        EndIf
        ; debugMsg(sProcName, "qAbsBytePosition=" + qAbsBytePosition)
      EndIf
      
      ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState))
      If \nAudState < #SCS_CUE_FADING_IN  ; added 11.2.6d following error reported by Matthew Lebe
        If (\bUsingSplitStream) And (nSplitterChannel <> 0) And (gbUseBASSMixer)
          qCurrAbsBytePosition = BASS_Mixer_ChannelGetPosition(nSplitterChannel, #BASS_POS_BYTE)
          ; Added 25Nov2022 11.9.7am
          If qCurrAbsBytePosition = -1
            debugMsg(sProcName, "BASS_Mixer_ChannelGetPosition(" + decodeHandle(nSplitterChannel) + ", BASS_POS_BYTE) returned " + qCurrAbsBytePosition)
            debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            qCurrAbsBytePosition = 0
          EndIf
          ; End added 25Nov2022 11.9.7am
          If qAbsBytePosition <> qCurrAbsBytePosition
            debugMsg2(sProcName, "BASS_Mixer_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
          EndIf
          If (qAbsBytePosition <> qCurrAbsBytePosition) Or (bForceResetPos)
            nBassResult = BASS_Mixer_ChannelSetPosition(nSplitterChannel, qAbsBytePosition, #BASS_POS_BYTE)
            debugMsg2(sProcName, "BASS_Mixer_ChannelSetPosition(" + sSplitterHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
            If nBassResult = #BASSFALSE
              debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            EndIf
            nBassResult = BASS_Split_StreamReset(nSplitterChannel)  ; reset buffers of all the gapless stream's splitters
            debugMsg2(sProcName, "BASS_Split_StreamReset(" + sSplitterHandle + ")", nBassResult)
          EndIf
        Else
          ; added 2Feb2019 11.8.0.2af
          If gbUseBASSMixer
            qCurrAbsBytePosition = BASS_Mixer_ChannelGetPosition(nSplitterChannel, #BASS_POS_BYTE)
            ; Added 25Nov2022 11.9.7am
            If qCurrAbsBytePosition = -1
              debugMsg(sProcName, "BASS_Mixer_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE) returned " + qCurrAbsBytePosition)
              debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
              qCurrAbsBytePosition = 0
            EndIf
            ; End added 25Nov2022 11.9.7am
            If qAbsBytePosition <> qCurrAbsBytePosition
              debugMsg2(sProcName, "BASS_Mixer_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
            EndIf
            If (qAbsBytePosition <> qCurrAbsBytePosition) Or (bForceResetPos)
              nBassResult = BASS_Mixer_ChannelSetPosition(nSplitterChannel, qAbsBytePosition, #BASS_POS_BYTE)
              debugMsg2(sProcName, "BASS_Mixer_ChannelSetPosition(" + sSplitterHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
              If nBassResult = #BASSFALSE
                debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
              EndIf
            EndIf
          Else
          ; end added 2Feb2019 11.8.0.2af
            qCurrAbsBytePosition = BASS_ChannelGetPosition(nSourceChannel, #BASS_POS_BYTE)
            ; Added 25Nov2022 11.9.7am
            If qCurrAbsBytePosition = -1
              debugMsg(sProcName, "BASS_ChannelGetPosition(" + sSourceHandle + ", BASS_POS_BYTE) returned " + qCurrAbsBytePosition)
              debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
              qCurrAbsBytePosition = 0
            EndIf
            ; End added 25Nov2022 11.9.7am
            If qAbsBytePosition <> qCurrAbsBytePosition
              debugMsg2(sProcName, "BASS_ChannelGetPosition(" + sSourceHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
            EndIf
            If (qAbsBytePosition <> qCurrAbsBytePosition) Or (bForceResetPos)
              nBassResult = BASS_ChannelSetPosition(nSourceChannel, qAbsBytePosition, #BASS_POS_BYTE)
              debugMsg2(sProcName, "BASS_ChannelSetPosition(" + sSourceHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
              If nBassResult = #BASSFALSE
                debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
              EndIf
            EndIf
            If \bUsingSplitStream
              debugMsg(sProcName, "calling BASS_Split_StreamReset(" + sSourceHandle + ")")
              nBassResult = BASS_Split_StreamReset(nSourceChannel)  ; reset buffers of all the gapless stream's splitters
              debugMsg2(sProcName, "BASS_Split_StreamReset(" + sSourceHandle + ")", nBassResult)
            EndIf
          EndIf
        EndIf
        ; end of code added 11.2.6d (apart from changing the following line from 'If' to 'ElseIf')
      ElseIf gbUseBASSMixer
        If \bAudUseGaplessStream
          nBassResult = BASS_Mixer_ChannelSetPosition(nSourceChannel, qAbsBytePosition, #BASS_POS_BYTE)
          debugMsg2(sProcName, "BASS_Mixer_ChannelSetPosition(" + sSourceHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
          If \bUsingSplitStream
            nBassResult = BASS_Split_StreamReset(nSplitterChannel)  ; reset buffers of all the gapless stream's splitters
            debugMsg2(sProcName, "BASS_Split_StreamReset(" + sSplitterHandle + ")", nBassResult)
          EndIf
        Else
          If gaMixerStreams(nMixerStreamPtr)\bNoDevice = #False
            nBassResult = BASS_Mixer_ChannelSetPosition(nSplitterChannel, qAbsBytePosition, #BASS_POS_BYTE)
            debugMsg2(sProcName, "BASS_Mixer_ChannelSetPosition(" + sSplitterHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
            If nBassResult = #BASSFALSE
              debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            EndIf
          EndIf
          If \bUsingSplitStream
            nBassResult = BASS_Split_StreamReset(nSourceChannel)  ; reset buffers of all the source's splitters
            debugMsg2(sProcName, "BASS_Split_StreamReset(" + sSourceHandle + ")", nBassResult)
          EndIf
        EndIf
        
      Else
        If \bUsingSplitStream
          qCurrAbsBytePosition = BASS_ChannelGetPosition(nSplitterChannel, #BASS_POS_BYTE)
          ; Added 25Nov2022 11.9.7am
          If qCurrAbsBytePosition = -1
            debugMsg2(sProcName, "BASS_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
            debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            qCurrAbsBytePosition = 0
          EndIf
          ; End added 25Nov2022 11.9.7am
          If qAbsBytePosition <> qCurrAbsBytePosition
            debugMsg2(sProcName, "BASS_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
          EndIf
        Else
          qCurrAbsBytePosition = BASS_ChannelGetPosition(nSourceChannel, #BASS_POS_BYTE)
          ; Added 25Nov2022 11.9.7am
          If qCurrAbsBytePosition = -1
            debugMsg2(sProcName, "BASS_ChannelGetPosition(" + decodeHandle(nSourceChannel) + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
            debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            qCurrAbsBytePosition = 0
          EndIf
          ; End added 25Nov2022 11.9.7am
          If qAbsBytePosition <> qCurrAbsBytePosition
            debugMsg2(sProcName, "BASS_ChannelGetPosition(" + sSourceHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
          EndIf
        EndIf
        If (qAbsBytePosition <> qCurrAbsBytePosition) Or (bForceResetPos)
          If \bUsingSplitStream
            nActiveState = BASS_ChannelIsActive(nSplitterChannel)
            debugMsg2(sProcName, "BASS_ChannelIsActive(" + sSplitterHandle + ")", nActiveState)
            nBassResult = BASS_ChannelPause(nSplitterChannel) ; pause splitter streams (so that resumption following seek can be synchronized)
            debugMsg2(sProcName, "BASS_ChannelPause(" + sSplitterHandle + ")", nBassResult)
            If nBassResult = #BASSFALSE
              debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            EndIf
            nBassResult = BASS_ChannelSetPosition(nSourceChannel, qAbsBytePosition, #BASS_POS_BYTE)
            debugMsg2(sProcName, "BASS_ChannelSetPosition(" + sSourceHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
            If nBassResult = #BASSFALSE
              debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            EndIf
            nBassResult = BASS_Split_StreamReset(nSourceChannel)  ; reset buffers of all the source's splitters
            debugMsg2(sProcName, "BASS_Split_StreamReset(" + sSourceHandle + ")", nBassResult)
            ; Delay calling BASS_ChannelPlay() until possibly having to call MTC_setSyncTimeCode(nMTCSubPtr), so that
            ; the channel is not already playing when the 'set sync' is issued, as that may have resulted in the sync point already passed
            bCallBassChannelPlayForSplitter = #True
          Else
            nBassResult = BASS_ChannelSetPosition(nSourceChannel, qAbsBytePosition, #BASS_POS_BYTE)
            debugMsg2(sProcName, "BASS_ChannelSetPosition(" + sSourceHandle + ", " + qAbsBytePosition + ", BASS_POS_BYTE)", nBassResult)
            If nBassResult = #BASSFALSE
              debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
            EndIf
          EndIf
        EndIf
      EndIf
      
      If (pMainOrAlt = #SCS_CHAN_MAIN) And (pAbsNewBytePos < 0 Or pAbsNewPos > 0)
        nThisSubPtr = \nSubIndex
        If aSub(nThisSubPtr)\bStartedInEditor = #False And bCheckForMTC
          nMTCSubPtr = aSub(nThisSubPtr)\nAFLinkedToMTCSubPtr
          If nMTCSubPtr >= 0
            If \nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT And \nAudState <> #SCS_CUE_PAUSED
              debugMsg(sProcName, "calling pauseAudChannels(" + getAudLabel(pAudPtr) + ")")
              pauseAudChannels(pAudPtr)
              debugMsg(sProcName, "calling MTC_playOrResumeMTCAndLinkedAud(" + getSubLabel(nMTCSubPtr) + ", #False, #True)")
              MTC_playOrResumeMTCAndLinkedAud(nMTCSubPtr, #False, #True)
            Else
              debugMsg(sProcName, "calling MTC_playOrResumeMTCAndLinkedAud(" + getSubLabel(nMTCSubPtr) + ", #False, #False)")
              MTC_playOrResumeMTCAndLinkedAud(nMTCSubPtr, #False, #False)
            EndIf
;             If \bUsingSplitStream
;               nChannel = nSplitterChannel
;               sHandle = sSplitterHandle
;             Else
;               nChannel = nSourceChannel
;               sHandle = sSourceHandle
;             EndIf
;             nActiveState = BASS_ChannelIsActive(nChannel)
;             debugMsg2(sProcName, "BASS_ChannelIsActive(" + sHandle + ")", nActiveState)
;             If nActiveState = #BASS_ACTIVE_PLAYING
;               If nMixerStream <> 0
;                 nBassResult = BASS_ChannelPause(nMixerStream)
;                 debugMsg2(sProcName, "BASS_ChannelPause(" + sMixerHandle + ")", nBassResult)
;               Else
;                 nBassResult = BASS_ChannelPause(nChannel)
;                 debugMsg2(sProcName, "BASS_ChannelPause(" + sHandle + ")", nBassResult)
;               EndIf
;               If nBassResult = #BASSFALSE
;                 debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
;               EndIf
;             EndIf
;             qCurrAbsBytePosition = BASS_ChannelGetPosition(nSplitterChannel, #BASS_POS_BYTE)
;             debugMsg2(sProcName, "BASS_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
;             debugMsg(sProcName, "calling MTC_setSyncTimeCode(" + getSubLabel(nMTCSubPtr) + ")")
;             MTC_setSyncTimeCode(nMTCSubPtr)
;             resumeAudChannels(pAudPtr)
;             qCurrAbsBytePosition = BASS_ChannelGetPosition(nSplitterChannel, #BASS_POS_BYTE)
;             debugMsg2(sProcName, "BASS_ChannelGetPosition(" + sSplitterHandle + ", BASS_POS_BYTE)", qCurrAbsBytePosition)
;             If nActiveState = #BASS_ACTIVE_PLAYING
;               If nMixerStream <> 0
;                 nBassResult = BASS_ChannelPlay(nMixerStream, #BASSFALSE)
;                 debugMsg2(sProcName, "BASS_ChannelPlay(" + sMixerHandle + ", BASSFALSE)", nBassResult)
;               Else
;                 nBassResult = BASS_ChannelPlay(nChannel, #BASSFALSE)
;                 debugMsg2(sProcName, "BASS_ChannelPlay(" + sHandle + ", BASSFALSE)", nBassResult)
;               EndIf
;               bCallBassChannelPlayForSplitter = #False
;             EndIf
          EndIf
        EndIf
      EndIf
      
      If bCallBassChannelPlayForSplitter
        If nActiveState = #BASS_ACTIVE_PLAYING
          nBassResult = BASS_ChannelPlay(nSplitterChannel, #BASSFALSE)
          debugMsg2(sProcName, "BASS_ChannelPlay(" + sSplitterHandle + ", BASSFALSE)", nBassResult)
        EndIf
      EndIf
      
      ; Added 11Jan2025 11.10.6-b03
      If \nMaxCueMarker >= 0
        debugMsg(sProcName, "calling loadOCMCuesAfterAudPos(" + getAudLabel(pAudPtr) + ", " + pAbsNewPos + ")")
        loadOCMCuesAfterAudPos(pAudPtr, pAbsNewPos)
      EndIf
      ; End added 11Jan2025 11.10.6-b03
      
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure GetDuration(Handle.l, bTrace=#False)   ; Handle is long
  ; Returns duration in milliseconds of stream
  PROCNAMEC()
  Protected qBytes.q
  Protected dSeconds.d
  Protected nDuration

  qBytes = BASS_ChannelGetLength(Handle, #BASS_POS_BYTE)
  ; debugMsg2(sProcName, "BASS_ChannelGetLength(" + decodeHandle(Handle) + ", BASS_POS_BYTE)", qBytes)
  
  dSeconds = BASS_ChannelBytes2Seconds(Handle, qBytes)
  nDuration = Int(dSeconds * 1000.0)  ; Use Int() to ignore decimals, eg if dSeconds = 2.0666213152 then nDuration will be 2066.
                                      ; Without Int() it would be 2067 which can cause loops to stick, as reported by Clive Richards, 25Nov2016.
                                      ; Fix applied 25Nov2016 11.5.2.4
  debugMsgC(sProcName, "Handle=" + decodeHandle(Handle) + ", qBytes=" + qBytes + ", dSeconds=" + StrD(dSeconds) + ", nDuration=" + nDuration)

  ProcedureReturn nDuration
EndProcedure

Procedure.q getFileBytes(Handle.l)   ; Handle is long
  PROCNAMEC()
  Protected qBytes.q  ; quad

  qBytes = BASS_ChannelGetLength(Handle, #BASS_POS_BYTE)
  debugMsg2(sProcName, "BASS_ChannelGetLength(" + decodeHandle(Handle) + ", BASS_POS_BYTE)", qBytes)
  
  ProcedureReturn qBytes
EndProcedure

Procedure GetKiloBitsPerSecond(Handle.l, FileLength, bTrace=#False)
  ;Returns - Kilo Bits Per Second
  ; PROCNAMEC()
  Protected dBits.d, dMS.d, dBPS.d, dKBPS.d
  Protected nDuration.l
  Protected nKBPS
  
  dBits = FileLength * 8
  nDuration = GetDuration(Handle, bTrace)
  dMS = nDuration
  dBPS = dBits / (dMS / 1000)
  dKBPS = dBPS / 1000
  nKBPS = dKBPS
  ProcedureReturn nKBPS
EndProcedure

Procedure getFrequency(Handle.l)
  ;Returns - Sample Rate [Frequency]
  Protected fFreq.f, nFreq
  BASS_ChannelGetAttribute(Handle, #BASS_ATTRIB_FREQ, @fFreq)
  nFreq = fFreq
  ProcedureReturn nFreq
EndProcedure

Procedure GetChannels(Handle.l)
  BASS_ChannelGetInfo(Handle, @grBCI\chanInfo)
  ProcedureReturn grBCI\chanInfo\chans
EndProcedure

Procedure.s getFileInfo(chan.l, sFileName.s, bIncludeType, pAudPtr=-1, bTrace=#False)
  PROCNAMEC()
  Protected sFileInfo.s, nBits.b, nKBPS, sFileExt.s
  Protected sType.s, sMode.s, nFreq
  Protected nMyFileLen, nTmpFileHandle
  Protected d, nChans, nBassResult.l

  With grBCI\chanInfo
    
    debugMsgC(sProcName, #SCS_START + ", chan=" + decodeHandle(chan) + ", pAudPtr=" + getAudLabel(pAudPtr))
    
    ; populate nChans (includes at least one call to BASS_ChannelGetInfo() to populate grBCI\chanInfo, which is necessary for subsequent code)
    If pAudPtr >= 0
      nChans = 0
      For d = aAud(pAudPtr)\nFirstSoundingDev To aAud(pAudPtr)\nLastSoundingDev
        If aAud(pAudPtr)\nBassChannel[d] <> 0
          nBassResult = BASS_ChannelGetInfo(aAud(pAudPtr)\nBassChannel[d], @grBCI\chanInfo)
          ; debugMsgC2(sProcName, "BASS_ChannelGetInfo(" + decodeHandle(aAud(pAudPtr)\nBassChannel[d]) + ", @grBCI\chanInfo)", nBassResult)
          If \chans > nChans
            nChans = \chans
          EndIf
        EndIf
      Next d
    Else
      nBassResult = BASS_ChannelGetInfo(chan, @grBCI\chanInfo)
      ; debugMsgC2(sProcName, "BASS_ChannelGetInfo(" + decodeHandle(chan) + ", @grBCI\chanInfo)", nBassResult)
      nChans = \chans
    EndIf
    
    ; populate sType and grBCI\bOKForSMS
    sFileExt = GetExtensionPart(sFileName)
    grBCI\bOKForSMS = #False
    grBCI\bOKForAnalyzeFile = #False
    ; debugMsgC(sProcName, "sFileName=" + GetFilePart(sFileName) + ", \ctype=$" + Hex(\ctype))
    If \ctype & #BASS_CTYPE_STREAM_WAV
      sType = "WAV"
      If LOWORD(\ctype) = 1
        ; uncompressed WAV file
        grBCI\bOKForSMS = #True
        grBCI\bOKForAnalyzeFile = #True
      EndIf
      ; debugMsgC(sProcName, "sType=" + sType + ", grBCI\bOKForSMS=" + strB(grBCI\bOKForSMS) + ", grBCI\bOKForAnalyzeFile=" + strB(grBCI\bOKForAnalyzeFile))
    ElseIf \ctype = #BASS_CTYPE_STREAM_OGG
      sType = "OGG"
    ElseIf \ctype = #BASS_CTYPE_STREAM_MP1
      sType = "MP1"
    ElseIf \ctype = #BASS_CTYPE_STREAM_MP2
      sType = "MP2"
    ElseIf \ctype = #BASS_CTYPE_STREAM_MP3
      sType = "MP3"
    ElseIf \ctype = #BASS_CTYPE_STREAM_WMA
      sType = "WMA"
    ElseIf \ctype = #BASS_CTYPE_STREAM_AIFF
      sType = "AIFF"
      grBCI\bOKForSMS = #True
    Else
      sType = UCase(sFileExt)
    EndIf
    
    ; populate sMode
    Select \chans
      Case 0
        sMode = ""
      Case 1
        sMode = "mono"
      Case 2
        sMode = "stereo"
      Default
        sMode = Str(nChans) + " multichannel"
    EndSelect
    
    ; populate nBits
    nBits = \origres
    
    ; populate nFreq
    nFreq = getFrequency(chan)
    
    ; populate nKBPS
    nKBPS = 0
    If sType = "MP3" Or sType = "WMA"
      nMyFileLen = 0
      nTmpFileHandle = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
      If nTmpFileHandle <> 0
        nMyFileLen = Lof(nTmpFileHandle)
        CloseFile(nTmpFileHandle)
      EndIf
      If nMyFileLen > 0
        nKBPS = GetKiloBitsPerSecond(chan, nMyFileLen, bTrace)
      EndIf
    EndIf
    
    ; populate sFileInfo from previous fields
    If (bIncludeType = #False) And LCase(sType) = LCase(sFileExt)
      sFileInfo = ""
    Else
      sFileInfo = UCase(sType) + " "
    EndIf
    If sType = "MP3" And nKBPS > 0
      sFileInfo + nFreq + " Hz, " + nKBPS + " kbps, " + sMode
    ElseIf sType = "WMA" And nKBPS > 0
      sFileInfo + nFreq + " Hz, " + nKBPS + " kbps, " + sMode
    ElseIf nBits <> 0
      sFileInfo + nFreq + " Hz, " + nBits + " bits, " + sMode
    Else
      sFileInfo + nFreq + " Hz, " + sMode
    EndIf
    
  EndWith
  
  debugMsgC(sProcName, "sFileName=" + GetFilePart(sFileName) + ", grBCI\bOKForSMS=" + strB(grBCI\bOKForSMS) + ", grBCI\bOKForAnalyzeFile=" + strB(grBCI\bOKForAnalyzeFile) + ", sFileInfo=" + sFileInfo)
  ; return sFileInfo
  ProcedureReturn Trim(sFileInfo)
EndProcedure

Procedure GetTagsFromFile(sPathToFile.s)
  ; get tags from specified file (assumes BASS is present)
  PROCNAMEC()
  Protected sFileName.s
  Protected nStreamHold.l  ; long
  Protected nBassResult.l
  Protected qOffset.q, qLength.q
  Protected nFlags.l
  Protected rSongTags.tySongTags
  Protected sFmt.s, nTagReadPtr.i, sTitle.s
  
  grSongTags = rSongTags  ; initially clear grSongTags
  
  If FileExists(sPathToFile) = #False
    debugMsg(sProcName, "File does not exist: " + sPathToFile)
    ProcedureReturn
  EndIf
  
  sFileName = sPathToFile
  nFlags = #BASS_STREAM_DECODE | #SCS_BASS_UNICODE
  nStreamHold = BASS_StreamCreateFile(#BASSFALSE, @sFileName, qOffset, qLength, nFlags)
  ; debugMsg3(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ") returned " + nStreamHold)
  
  If nStreamHold = 0
    debugMsg3(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ") returned " + nStreamHold)
    debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
  Else
    With grSongTags
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        sFmt = "%TITL"
        ; debugMsg(sProcName, "calling TAGS_Read(" + nStreamHold + ", sFmt)")
        nTagReadPtr = TAGS_Read(nStreamHold, sFmt)
        ; debugMsg2(sProcName, "TAGS_Read(" + nStreamHold + ", sFmt)", nTagReadPtr)
        sTitle = PeekS(nTagReadPtr, -1, #PB_Ascii)
        ; debugMsg(sProcName, "sTitle=" + sTitle)
        \strTitle = sTitle
      CompilerElse
        \strTitle = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%TITL"))
      CompilerEndIf
      ; debugMsg(sProcName, "\strTitle=" + \strTitle)
      ; \strArtist = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%ARTI"))
      ; \strAlbum = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%ALBM"))
      ; \strYear = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%YEAR"))
      ; \strTrack = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%TRCK"))
      ; \strGenre = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%GNRE"))
      ; \strComment = VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%CMNT"))
    EndWith
    
    nBassResult = BASS_StreamFree(nStreamHold)
    ; debugMsg2(sProcName, "BASS_StreamFree(" + nStreamHold + ")", nBassResult)
  EndIf
  
EndProcedure

Procedure getInfoAboutFile(sPathToFile.s, bTrace=#False)
  PROCNAMEC()
  Protected nStreamHold.l   ; long
  Protected nBassResult.l   ; long
  Protected sFileName.s, sFileExt.s
  Protected qOffset.q, qLength.q
  Protected nFlags.l, nBassErrorCode.l
  Protected bResult
  Protected nMarkers
  Protected rInfoAboutFile.tyInfoAboutFile
  Protected rChanInfo.BASS_CHANNELINFO
  Protected qBytes.q
  Protected dTime.d
  Protected sFmt.s, nTagReadPtr.i, sTitle.s
  
  debugMsgC(sProcName, #SCS_START + ", sPathToFile=" + sPathToFile)
  
  bResult = #True
  
  initBassIfReqd()
  
  grInfoAboutFile = rInfoAboutFile  ; clear grInfoAboutFile
  sFileName = sPathToFile
  
  With grInfoAboutFile
    
    \sFileName = sFileName
    \nFileFormat = getFileFormat(\sFileName, bTrace)
    debugMsgC(sProcName, "\nFileFormat=" + decodeFileFormat(\nFileFormat))
    sFileExt = LCase(GetExtensionPart(\sFileName))
    ; debugMsgC(sProcName, "sFileExt=" + sFileExt)
    
    If sFileName = grText\sTextPlaceHolder
      \nFileDuration = 0
      \qFileBytes = 0
      \qFileBytesForTenSecs = 0
      \nFileChannels = 1
      \sFileTitle = removeNonPrintingChars(\sFileName)
      \sFileInfo = grText\sTextPlaceHolder
      \bOKForAnalyzeFile = #False
      \bOKForSMS = #False
    Else
      Select \nFileFormat
        Case #SCS_FILEFORMAT_AUDIO  ; #SCS_FILEFORMAT_AUDIO
          If FileExists(\sFileName, bTrace) = #False
            \sErrorMsg = RemoveString(Lang("Errors", "FileNotFound"), ": $1")
            debugMsgC(sProcName, "Error: " + \sErrorMsg)
            ProcedureReturn #False
          EndIf
          nFlags = #BASS_STREAM_DECODE | #BASS_SAMPLE_FLOAT | #SCS_BASS_UNICODE
          debugMsgC(sProcName, "calling BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ")")
          nStreamHold = BASS_StreamCreateFile(#BASSFALSE, @sFileName, qOffset, qLength, nFlags)
          debugMsgC2(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ")", nStreamHold)
          If nStreamHold = 0
            ; failed to open file
            nBassErrorCode = BASS_ErrorGetCode()
            debugMsgC2(sProcName, "BASS_ErrorGetCode()", nBassErrorCode)
            \sErrorMsg = getBassErrorDesc(nBassErrorCode)
            debugMsgC(sProcName, "Error: " + \sErrorMsg)
            ProcedureReturn #False
          EndIf
          ; opened ok
          
          ; debugMsgC(sProcName, "calling BASS_ChannelGetInfo(" + nStreamHold + ", @rChanInfo)")
          nBassResult = BASS_ChannelGetInfo(nStreamHold, @rChanInfo)
          ; debugMsgC2(sProcName, "BASS_ChannelGetInfo(" + nStreamHold + ", @rChanInfo)", nBassResult)
          ; calculate bytes per sample
          \nBytesPerSamplePos = rChanInfo\chans  ; start with channel count (1=mono, 2=stereo, etc)
          If rChanInfo\flags & #BASS_SAMPLE_FLOAT
            \nBytesPerSamplePos * 4    ; 32-bit floating point = 4 bytes
          ElseIf rChanInfo\flags & #BASS_SAMPLE_FLOAT = 0
            \nBytesPerSamplePos * 2    ; 16-bit = 2 bytes
          EndIf
          \nFileChannels = rChanInfo\chans
          
          ; debugMsgC(sProcName, "calling BASS_ChannelGetLength(" + nStreamHold + ", #BASS_POS_BYTE)")
          \qFileBytes = BASS_ChannelGetLength(nStreamHold, #BASS_POS_BYTE)
          ; debugMsgC(sProcName, "BASS_ChannelGetLength(" + nStreamHold + ", #BASS_POS_BYTE) returned " + \qFileBytes)
          \nFileDuration = GetDuration(nStreamHold, bTrace)
          debugMsgC(sProcName, "grInfoAboutFile\qFileBytes=" + \qFileBytes + ", \nFileDuration=" + \nFileDuration)
          If \nFileDuration = -1
            bResult = #False
          Else
            ; debugMsgC(sProcName, "calling getFileInfo")
            \sFileInfo = getFileInfo(nStreamHold, \sFileName, #True, -1, bTrace)
            \bOKForSMS = grBCI\bOKForSMS
            \bOKForAnalyzeFile = grBCI\bOKForAnalyzeFile
            debugMsgC(sProcName, "\bOKForSMS=" + strB(\bOKForSMS) + ", \bOKForAnalyzeFile=" + strB(\bOKForAnalyzeFile) + ", \sFileInfo=" + \sFileInfo)
            If (sFileExt <> "wav") And (sFileExt <> "mid") And (grEditingOptions\bIgnoreTitleTags = #False)
              CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
                sFmt = "%TITL"
                nTagReadPtr = TAGS_Read(nStreamHold, sFmt)
                sTitle = PeekS(nTagReadPtr, -1, #PB_Ascii)
                \sFileTitle = removeNonPrintingChars(sTitle)
              CompilerElse
                \sFileTitle = removeNonPrintingChars(VBStrFromAnsiPtr(TAGS_Read(nStreamHold, "%TITL")))
              CompilerEndIf
              debugMsgC(sProcName, "\sFileTitle=" + \sFileTitle)
            Else
              \sFileTitle = ""
            EndIf
            
            nMarkers = analyzeMrkFile(\sFileName, nStreamHold, bTrace) ; get cue points (markers) from Wavelab MRK file if present
            If nMarkers <= 0
              ; Wavelab MRK file not present, or no markers found
              If \bOKForAnalyzeFile
                ; debugMsgC(sProcName, "calling analyzeWavFile(" + GetFilePart(\sFileName) + ", " + nStreamHold + ", " + strB(bTrace) + ")")
                analyzeWavFile(\sFileName, nStreamHold, bTrace)  ; get cue points directly from the WAV file
              Else
                updateAnalyzedFileArray(\sFileName)
              EndIf
            EndIf
            
          EndIf
          dTime = 10.0
          \qFileBytesForTenSecs = BASS_ChannelSeconds2Bytes(nStreamHold, dTime)
          ; debugMsgC3(sProcName, "BASS_ChannelSeconds2Bytes(" + nStreamHold + ", " + StrD(dTime,1) + ") returned " + \qFileBytesForTenSecs)
          
          nBassResult = BASS_StreamFree(nStreamHold)
          ; debugMsgC2(sProcName, "BASS_StreamFree(" + nStreamHold + ")", nBassResult)
          
        Case #SCS_FILEFORMAT_MIDI   ; #SCS_FILEFORMAT_MIDI
          \sFileTitle = removeNonPrintingChars(ignoreExtension(GetFilePart(\sFileName)))
          \nFileDuration = getMidiFileLength(\sFileName)
          debugMsg(sProcName, "\nFileDuration=" + \nFileDuration)
          
        Case #SCS_FILEFORMAT_PICTURE  ; #SCS_FILEFORMAT_PICTURE
          \sFileTitle = removeNonPrintingChars(ignoreExtension(GetFilePart(\sFileName)))
          
        Case #SCS_FILEFORMAT_VIDEO  ; #SCS_FILEFORMAT_VIDEO
          ; debugMsgC(sProcName, "calling getVideoInfo(" + GetFilePart(\sFileName) + ", #False, " + strB(bTrace) + ")")
          If getVideoInfo(\sFileName, #False, bTrace)
            \nFileDuration = grVideoInfo\nLength
            debugMsgC(sProcName, "grInfoAboutFile\nFileDuration=" + \nFileDuration)
            \nFileChannels = 1
            \sFileTitle = grVideoInfo\sTitle
          Else
            bResult = #False
          EndIf
          
      EndSelect
    EndIf
    
  EndWith
  
  debugMsgC(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure SyncProcLinkPos(Handle.l, channel.l, nData.l, user.l)   ; all params long
  PROCNAME(#PB_Compiler_Procedure +" handle=" + decodeHandle(Handle) + ", channel=" + decodeHandle(channel) + ", user=" + user)
  Protected nBassResult.l, k, k2
  Protected nChannelCount
  Protected d, h, n
  Protected qBytePos.q              ; quad
  Protected dNewPos.d               ; double
  Protected Dim qNewBytePos.q(32)   ; quad
  Protected Dim aChannel.l(32)      ; long
  Protected Dim aSetPosResult.l(32) ; long
  Protected Dim fBVLevel.f(32)
  Protected Dim aLevelResult.l(32)  ; long
  Protected bFound
  Protected fAdjBVLevel.f, nDevMapDevPtr
  Protected fOutputGain.f
  
  ;========================================
  ; no system calls in callback procedures!
  ;========================================
  debugMsg3_S(sProcName, #SCS_START)
  
  k = user
  
  For h = 0 To aAud(k)\nMaxAudSetPtr2
    k2 = gaAudSet(k, h)
    If k2 > 0
      With aAud(k2)
        For d = \nFirstSoundingDev To \nLastSoundingDev
          If \nBassChannel[d] <> 0
            CheckSubInRange(nChannelCount, 32, "aChannel()")
            aChannel(nChannelCount) = \nBassChannel[d]
            If \nFadeInTime <= 0
              fAdjBVLevel = \fBVLevel[d]
              If gbUseBASSMixer = #False
                nDevMapDevPtr = \nOutputDevMapDevPtr[d]
                If nDevMapDevPtr >= 0
                  fOutputGain = grMaps\aDev(nDevMapDevPtr)\fDevOutputGain
                  If fOutputGain <> 1.0
                    fAdjBVLevel * fOutputGain
                  EndIf
                EndIf
              EndIf
              fBVLevel(nChannelCount) = fAdjBVLevel
            EndIf
            nChannelCount + 1
            If \nBassChannel[d] = channel
              dNewPos = (\nAbsStartAt + \nManualOffset) / 1000.0
              bFound = #True
            EndIf
          EndIf
        Next d
      EndWith
    EndIf
  Next h
  
  ; Added 28Sep2022 11.9.6
  For n = 0 To nChannelCount - 1
    If fBVLevel(n) <= grLevels\fMinBVLevel
      fBVLevel(n) = 0.0
    EndIf
  Next n
  ; End added 28Sep2022 11.9.6
  
  If gbUseBASSMixer
    If bFound = #False
      qBytePos = BASS_Mixer_ChannelGetPosition(channel, #BASS_POS_BYTE)
      ; Added 25Nov2022 11.9.7am
      If qBytePos = -1
        debugMsg(sProcName, "BASS_Mixer_ChannelGetPosition(" + decodeHandle(channel) + ", BASS_POS_BYTE) returned " + qBytePos)
        debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
        qBytePos = 0
      EndIf
      ; End added 25Nov2022 11.9.7am
      dNewPos = BASS_ChannelBytes2Seconds(channel, qBytePos)
    EndIf
    
    For n = 0 To nChannelCount - 1
      qNewBytePos(n) = IntQ(BASS_ChannelSeconds2Bytes(aChannel(n), dNewPos))
    Next n
    
    For n = 0 To nChannelCount - 1
      aSetPosResult(n) = BASS_Mixer_ChannelSetPosition(aChannel(n), qNewBytePos(n), #BASS_POS_BYTE)
    Next n
    
    For n = 0 To nChannelCount - 1
      aLevelResult(n) = BASS_ChannelSetAttribute(aChannel(n), #BASS_ATTRIB_VOL, fBVLevel(n))
    Next n
    
    If bFound = #False
      debugMsg2_S(sProcName, "BASS_Mixer_ChannelGetPosition(" + decodeHandle(channel) + ", BASS_POS_BYTE)", qBytePos)
    EndIf
    For n = 0 To nChannelCount - 1
      debugMsg2_S(sProcName, "BASS_ChannelSeconds2Bytes(" + decodeHandle(aChannel(n)) + ", " + StrD(dNewPos, 3) + ")", qNewBytePos(n))
    Next n
    For n = 0 To nChannelCount - 1
      debugMsg2_S(sProcName, "BASS_Mixer_ChannelSetPosition(" + decodeHandle(aChannel(n)) + ", " + qNewBytePos(n) + ", BASS_POS_BYTE)", aSetPosResult(n))
    Next n
    For n = 0 To nChannelCount - 1
      debugMsg2_S(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(aChannel(n)) + ", BASS_ATTRIB_VOL, " + formatLevel(fBVLevel(n)), aLevelResult(n))
    Next n
    
  Else
    
    If bFound = #False
      qBytePos = BASS_ChannelGetPosition(channel, #BASS_POS_BYTE)
      ; Added 25Nov2022 11.9.7am
      If qBytePos = -1
        debugMsg2(sProcName, "BASS_ChannelGetPosition(" + decodeHandle(channel) + ", BASS_POS_BYTE)", qBytePos)
        debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
        qBytePos = 0
      EndIf
      ; End added 25Nov2022 11.9.7am
      dNewPos = BASS_ChannelBytes2Seconds(channel, qBytePos)
    EndIf
    
    For n = 0 To (nChannelCount - 1)
      qNewBytePos(n) = IntQ(BASS_ChannelSeconds2Bytes(aChannel(n), dNewPos))
    Next n
    For n = 0 To (nChannelCount - 1)
      aSetPosResult(n) = BASS_ChannelSetPosition(aChannel(n), qNewBytePos(n), #BASS_POS_BYTE)
    Next n
    For n = 0 To (nChannelCount - 1)
      aLevelResult(n) = BASS_ChannelSetAttribute(aChannel(n), #BASS_ATTRIB_VOL, fBVLevel(n))
    Next n
    
    If bFound = #False
      debugMsg2_S(sProcName, "BASS_ChannelGetPosition(" + decodeHandle(channel) + ", BASS_POS_BYTE)", qBytePos)
    EndIf
    For n = 0 To (nChannelCount - 1)
      debugMsg2_S(sProcName, "BASS_ChannelSeconds2Bytes(" + decodeHandle(aChannel(n)) + ", " + StrD(dNewPos, 3) + ")", qNewBytePos(n))
    Next n
    For n = 0 To (nChannelCount - 1)
      debugMsg2_S(sProcName, "BASS_ChannelSetPosition(" + decodeHandle(aChannel(n)) + ", " + qNewBytePos(n) + ", BASS_POS_BYTE)", aSetPosResult(n))
    Next n
    For n = 0 To (nChannelCount - 1)
      debugMsg2_S(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(aChannel(n)) + ", BASS_ATTRIB_VOL, " + formatLevel(fBVLevel(n)), aLevelResult(n))
    Next n
    
  EndIf
  
  For h = 0 To aAud(k)\nMaxAudSetPtr2
    k2 = gaAudSet(k, h)
    If k2 > 0
      aAud(k2)\bWaitForLinkSyncPos = #False
    EndIf
  Next h
  
EndProcedure

Procedure GetSilenceLength(sFileName.s, fStartThresholdDB.f, fEndThresholdDB.f, *nStartMilliseconds.Long, *nEndMilliseconds.Long)
  ; nb 999 in either of the threshold parameters means 'do not calculate this item'
  ; -100 means absolute silence
  PROCNAMEC()
  Protected nBytesRead.l, nSamples.l, nBassResult.l
  Protected nFlags.l
  Protected Dim afBuf.f(25000)  ; 25000 floats, for reading 100000 bytes (in second part of this procedure)
  Protected a, c, qCount.q, qPos.q, nMillisecondsLength.l
  Protected dSeconds.d, nMilliseconds.l
  Protected fStartThreshold.f, fEndThreshold.f
  Static sStaticFileName.s, nStaticStream.l
  
  debugMsg(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName) + ", fStartThresholdDB=" + StrF(fStartThresholdDB) + ", fEndThresholdDB=" + StrF(fEndThresholdDB))
  
  If (sStaticFileName <> sFileName) Or (nStaticStream = 0)
    If nStaticStream <> 0
      BASS_StreamFree(nStaticStream)
    EndIf
    sStaticFileName = sFileName
    nFlags = #BASS_STREAM_DECODE | #SCS_BASS_UNICODE | #BASS_STREAM_PRESCAN | #BASS_SAMPLE_FLOAT
    nStaticStream = BASS_StreamCreateFile(#BASSFALSE, @sStaticFileName, 0, 0, nFlags)
    debugMsg3(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sStaticFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ") returned " + nStaticStream)
    If nStaticStream = 0
      debugMsg3(sProcName, "BASS_StreamCreateFile() Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
      ProcedureReturn
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "nStaticStream=" + nStaticStream)
  If nStaticStream <> 0
    If fStartThresholdDB <> 999
      If fStartThresholdDB <= -160 ; Changed 3Oct2022 11.9.6
        fStartThreshold = 0
      Else
        fStartThreshold = convertDBLevelToBVLevel(fStartThresholdDB)
      EndIf
      ; debugMsg(sProcName, "fStartThresholdDB=" + StrF(fStartThresholdDB,1) + ", fStartThreshold=" + fStartThreshold)
      qCount = 0
      nBassResult = BASS_ChannelSetPosition(nStaticStream, 0, #BASS_POS_BYTE)
      While (BASS_ChannelIsActive(nStaticStream))
        nBytesRead = BASS_ChannelGetData(nStaticStream, @afBuf(0), 20000 | #BASS_DATA_FLOAT) ; decode some data
        If nBytesRead > 0
          nSamples = nBytesRead >> 2
          a = 0
          ; count silent samples
          While (a < nSamples) And (afBuf(a) <= fStartThreshold)
            a + 1
          Wend
          qCount + (a*4) ; add number of silent bytes
          If a < nSamples; sound has begun!
            CompilerIf 1=2  ; nb replaced the following by (later in this procedure) just setting the start time back one millisecond to make sure any rounding doesn't clip the start of the sound
              ; move back to a quieter sample (to avoid "click")
              While (a > 0) And (afBuf(a) > (fStartThreshold/4))
                a - 1
                qCount - 4
              Wend
            CompilerEndIf
            Break
          EndIf
        EndIf
      Wend
      dSeconds = BASS_ChannelBytes2Seconds(nStaticStream, qCount)
      nMilliseconds = (dSeconds * 1000)
      ; debugMsg(sProcName, "qCount=" + qCount + ", dSeconds=" + StrD(dSeconds,3) + ", nMilliseconds=" + nMilliseconds)
      If nMilliseconds > 1
        ; step back one millisecond to make sure any rounding doesn't clip the start of the sound
        nMilliseconds - 1
      EndIf
      debugMsg(sProcName, "setting *nStartMilliseconds=" + nMilliseconds)
      PokeL(*nStartMilliseconds, nMilliseconds)
    EndIf
    
    If fEndThresholdDB <> 999
      If fEndThresholdDB <= -160 ; Changed 3Oct2022 11.9.6
        fEndThreshold = 0
      Else
        fEndThreshold = convertDBLevelToBVLevel(fEndThresholdDB)
      EndIf
      ; debugMsg(sProcName, "fEndThresholdDB=" + StrF(fEndThresholdDB,1) + ", fEndThreshold=" + fEndThreshold)
      qCount = 0
      qPos = BASS_ChannelGetLength(nStaticStream, #BASS_POS_BYTE)
      dSeconds = BASS_ChannelBytes2Seconds(nStaticStream, qPos)
      nMillisecondsLength = (dSeconds * 1000)
      ; debugMsg(sProcName, "qPos=" + qPos + ", dSeconds=" + StrD(dSeconds) + ", nMillisecondsLength=" + nMillisecondsLength)
      While qPos > qCount
        ; step back a bit
        If qPos < 100000
          qPos = 0
        Else
          qPos - 100000
        EndIf
        nBassResult = BASS_ChannelSetPosition(nStaticStream, qPos, #BASS_POS_BYTE)
        nBytesRead = BASS_ChannelGetData(nStaticStream, @afBuf(0), 100000) ; decode some data
        If nBytesRead > 0
          nSamples = nBytesRead >> 2
          c = nSamples
          ; count silent samples
          While (c > 0) And (afBuf(c-1) <= fEndThreshold)
            c - 1
          Wend
          If c > 0  ; sound has begun
            qCount = qPos + (c*4)
            Break
          EndIf
        EndIf
      Wend
      dSeconds = BASS_ChannelBytes2Seconds(nStaticStream, qCount)
      nMilliseconds = (dSeconds * 1000)
      ; debugMsg(sProcName, "qCount=" + qCount + ", dSeconds=" + StrD(dSeconds,3) + ", nMilliseconds=" + nMilliseconds)
      If nMilliseconds < (nMillisecondsLength - 2)
        ; step forward one millisecond to make sure any rounding doesn't clip the end of the sound
        nMilliseconds + 1
      EndIf
      debugMsg(sProcName, "setting *nEndMilliseconds=" + nMilliseconds)
      PokeL(*nEndMilliseconds, nMilliseconds)
    EndIf
    
    ; nb do NOT free BASS stream as the user may call this procedure several times for the same file, with different thresholds
    ; see test at start of procedure where BASS stream will be freed if necessary
    
  EndIf
EndProcedure

; EOF