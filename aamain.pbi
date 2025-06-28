; File: aamain.pbi

EnableExplicit

Procedure calcCuePositionForAud(pAudPtr)
  CompilerIf #cTracePosition
    PROCNAMECA(pAudPtr)
  CompilerEndIf
  Protected nAbsFilePos, nBytePosition, nChannel.l
  Protected dTmpDouble.d, qTmpQuad.q
  Protected dPos.d
  Protected nSubPtr
  Protected qPlayerPos.q
  Protected nMTCSubPtr, bCalcPosition

  If gbClosingDown
    ProcedureReturn
  EndIf
  
  With aAud(pAudPtr)
    ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", \nFileFormat=" + \nFileFormat) ; + ", \sFileName=" + GetFilePart(\sFileName))
    If \nAudState = #SCS_CUE_ERROR
      \nRelFilePos = 0
      \nRAIRelFilePos = 0
      \nCuePos = 0
      \qChannelBytePosition = 0
      
    ElseIf \nAudState = #SCS_CUE_NOT_LOADED
      ; no action
      
    ElseIf \nAudState = #SCS_CUE_PAUSED
      ; Paused therefore no change
      
    Else
      Select \nFileFormat
        Case #SCS_FILEFORMAT_LIVE_INPUT
          \nRelFilePos = (gqTimeNow - \qTimeAudRestarted) - \nTotalTimeOnPause
          \nCuePos = \nRelFilePos
          \qChannelBytePosition = \nCuePos
          
        Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
          \nRelFilePos = (gqTimeNow - \qTimeAudRestarted) - \nTotalTimeOnPause
          \nCuePos = \nRelFilePos
          \qChannelBytePosition = \nCuePos
          
        Case #SCS_FILEFORMAT_VIDEO
          nSubPtr = \nSubIndex
          Select \nVideoPlaybackLibrary
            Case #SCS_VPL_VMIX
              CompilerIf #c_vMix_in_video_cues
                If \bPlayEndSyncOccurred
                  nAbsFilePos = \nAbsEndAt
                Else
                  nAbsFilePos = vMix_GetPosition(pAudPtr)
                  CompilerIf #cTracePosition
                    debugMsgT2(sProcName, "vMix_GetPosition(" + getCueLabel(pAudPtr) + ")", nAbsFilePos)
                  CompilerEndIf
                EndIf
                \nRelFilePos = nAbsFilePos - \nAbsMin
              CompilerEndIf
              
            Case #SCS_VPL_TVG
              CompilerIf #c_include_tvg
                If \nPlayTVGIndex >= 0
                  If \bPlayEndSyncOccurred
                    nAbsFilePos = \nAbsEndAt
                  Else
                    qPlayerPos = TVG_GetPlayerTimePosition(*gmVideoGrabber(\nPlayTVGIndex))
                    CompilerIf #cTracePosition
                      debugMsgT2(sProcName, "TVG_GetPlayerTimePosition(" + decodeHandle(*gmVideoGrabber(\nPlayTVGIndex)) + ")", qPlayerPos)
                    CompilerEndIf
                    nAbsFilePos = qPlayerPos / 10000  ; convert 100ns units to milliseconds
                  EndIf
                  \nRelFilePos = nAbsFilePos - \nAbsMin
                EndIf
                CompilerIf #cTracePosition
                  debugMsg(sProcName, "\nPlayTVGIndex=" + \nPlayTVGIndex + ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred) + ", qPlayerPos=" + qPlayerPos + ", nAbsFilePos=" + nAbsFilePos + ", \nAbsMin=" + \nAbsMin + ", \nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt)
                CompilerEndIf
              CompilerEndIf
              
            Default
              If \bMediaEnded
                \nRelFilePos = \nRelEndAt
              Else
                ; debugMsg3(sProcName, "calling getVideoPosition(" + getAudLabel(pAudPtr) + ")")
                \nRelFilePos = getVideoPosition(pAudPtr)
              EndIf
              
          EndSelect
          \nCuePos = \nRelFilePos
          \qChannelBytePosition = \nCuePos
          
        Case #SCS_FILEFORMAT_MIDI
          \nRelFilePos = (gqTimeNow - \qTimeAudRestarted) - \nTotalTimeOnPause + \nRelPassStart
          ; debugMsg(sProcName, "\nRelFilePos=" + \nRelFilePos)
          \nCuePos = \nRelFilePos
          \qChannelBytePosition = \nCuePos
          
        Case #SCS_FILEFORMAT_AUDIO
          If \bPlayEndSyncOccurred
            nAbsFilePos = \nAbsEndAt
          Else
            If gbUseBASS  ; BASS
              If \nFirstSoundingDev >= 0
                ; Added 20Dec2024 11.10.6bx for LTC via DirectSound, etc,
                bCalcPosition = #True
                ; debugMsg(sProcName, "grMTCSendControl\nMTCLinkedToAudPtr=" + getAudLabel(grMTCSendControl\nMTCLinkedToAudPtr) + ", grMTCSendControl\nMTCSubPtr=" + getSubLabel(grMTCSendControl\nMTCSubPtr))
                If grMTCSendControl\nMTCLinkedToAudPtr = pAudPtr
                  bCalcPosition = #False
                  nMTCSubPtr = grMTCSendControl\nMTCSubPtr
                  If nMTCSubPtr >= 0
                    If aSub(nMTCSubPtr)\nMTCType = #SCS_MTC_TYPE_LTC And gnCurrAudioDriver <> #SCS_DRV_SMS_ASIO
                      bCalcPosition = #True
                    EndIf
                  EndIf
                EndIf
                ; Endadded 20Dec2024 11.10.6bx
                If bCalcPosition
                  nChannel = getBassChannelForAud(pAudPtr)
                  nAbsFilePos = GetPlayingPos(pAudPtr, nChannel, 1)
                  CompilerIf #cTracePosition And 1=2
                    debugMsg(sProcName, "GetPlayingPos(" + getAudLabel(pAudPtr) + ", " + decodeHandle(nChannel) + ", 1) returned nAbsFilePos=" + nAbsFilePos)
                  CompilerEndIf
                  \qChannelBytePosition = grBCI\qChannelBytePosition
                  \nRelFilePos = nAbsFilePos - \nAbsMin
                  \nPlayingPos = \nRelFilePos
                  CompilerIf #cTracePosition
                    debugMsg(sProcName, "nAbsFilePos=" + nAbsFilePos + ", \nAbsMin=" + \nAbsMin + ", \nRelFilePos=" + \nRelFilePos)
                  CompilerEndIf
                EndIf
              EndIf
            Else  ; SM-S
              CompilerIf 1=2
                If (grSMS\qPTimeResponseReceived - \qTimePlayOrReposIssued) >= 0
                  If \nSMSManualStartPos >= 0
                    nAbsFilePos = \nSMSManualStartPos
                    CompilerIf #cTracePosition And 1=1
                      debugMsg(sProcName, "SM-S nAbsFilePos=" + nAbsFilePos + ", \nSMSManualStartPos=" + \nSMSManualStartPos)
                    CompilerEndIf
                  Else
                    nAbsFilePos = getSMSTrackTimeInMS(\sPPrimaryChan)
                    CompilerIf #cTracePosition And 1=1
                      debugMsg(sProcName, "SM-S nAbsFilePos=" + nAbsFilePos + ", \sPPrimaryChan=" + \sPPrimaryChan)
                    CompilerEndIf
                  EndIf
                  \nSMSManualStartPos = grAudDef\nSMSManualStartPos
                  \nRelFilePos = nAbsFilePos - \nAbsMin
                  \nPlayingPos = \nRelFilePos
                EndIf
              CompilerElse
                If (grSMS\qPTimeResponseReceived - \qTimePlayOrReposIssued) >= 0
                  If \nSMSManualStartPos >= 0
                    nAbsFilePos = \nSMSManualStartPos
                    CompilerIf #cTracePosition And 1=1
                      debugMsg(sProcName, "SM-S nAbsFilePos=" + nAbsFilePos + ", \nSMSManualStartPos=" + \nSMSManualStartPos)
                    CompilerEndIf
                    \nRelFilePos = nAbsFilePos - \nAbsMin
                    \nPlayingPos = \nRelFilePos
                  EndIf
                  \nSMSManualStartPos = grAudDef\nSMSManualStartPos
                EndIf
              CompilerEndIf
            EndIf
          EndIf
          CompilerIf #cTracePosition
            debugMsg(sProcName, "\nRelFilePos=" + \nRelFilePos + ", \nRelPassEnd=" + \nRelPassEnd + ", \nRelEndAt=" + \nRelEndAt + ", \nRelStartAt=" + \nRelStartAt) ; + ", \bLoopReleased=" + strB(\bLoopReleased))
          CompilerEndIf
          If \nRelFilePos < 0
            \nRelFilePos = 0
            \nPlayingPos = \nRelFilePos
          ElseIf \nRelFilePos > \nRelPassEnd
            \nRelFilePos = \nRelPassEnd
            \nPlayingPos = \nRelFilePos
          EndIf
          CompilerIf #cTracePosition
            debugMsg(sProcName, "\nRelFilePos=" + \nRelFilePos)
          CompilerEndIf
          
          \nCuePos = \nRelFilePos
          If \bPlayEndSyncOccurred
            If gbUseBASS  ; BASS
              If \nFirstSoundingDev >= 0
                nChannel = \nSourceChannel
                dTmpDouble = (\nRelFilePos + \nAbsMin) / 1000.0
                qTmpQuad = BASS_ChannelSeconds2Bytes(nChannel, dTmpDouble)
                \qChannelBytePosition = qTmpQuad
                ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\qChannelBytePosition=" + \qChannelBytePosition +  ", \nAbsMin=" + \nAbsMin + ", \nRelFilePos=" + \nRelFilePos)
              EndIf
            EndIf
          EndIf
          
      EndSelect
      
      If (\bContinuous = #False) And (\nRelFilePos < \nCueDuration)
        If (\nRelFilePos < \nRAIRelFilePos) Or ((\nRelFilePos - \nRAIRelFilePos) >= 1000)
          If (\bRAISendProgressPosMsgs) And (\bRAISendSetPos = #False)
            If gbLoadingCueFile = #False
              \bRAISendSetPos = #True
              grRAI\nSendSetPosCount + 1
            EndIf
          EndIf
        EndIf
      EndIf
      
      ; Added 3Nov2020 11.8.3.3ac
      CompilerIf 1=2 ; CompilerIf added 16Feb2021 11.8.4af because MTC MUST be sent from the MTC thread to provide a regular feed (problem reported by CPeters)
        If grMTCSendControl\nMTCLinkedToAudPtr = pAudPtr
          SendMTCQuarterFrames(#True)
        EndIf
      CompilerEndIf
      ; End added 3Nov2020 11.8.3.3ac
      
    EndIf
    
    CompilerIf #cTracePosition And 1=2
      If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
        debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", \nSMSManualStartPos=" + \nSMSManualStartPos +
                            ", \nRelFilePos=" + \nRelFilePos + ", \nCuePos=" + \nCuePos + ", \qChannelBytePosition=" + \qChannelBytePosition +
                            ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred) + ", \bMediaEnded=" + strB(\bMediaEnded))
      EndIf
    CompilerEndIf
    
  EndWith
EndProcedure

Procedure calcPLPosition(pSubPtr)
  PROCNAMEC()
  Protected nPos, k, bCalc
  Protected nPrevDelayStartTime, nPrevCrossFadeTime
  Protected nLastRunningAud
  Protected nTestTime, nPLUnplayedFilesTime
  Protected nFileTestLength
  Protected nMyPrevPlayIndex
  
  If aSub(pSubPtr)\bSubTypeM
    ProcedureReturn
  EndIf
  
  nLastRunningAud = -1
  k = aSub(pSubPtr)\nCurrPlayIndex
  If k >= 0
    If (aAud(k)\nAudState > #SCS_CUE_READY) And (aAud(k)\nAudState <= #SCS_CUE_COMPLETED) And (aAud(k)\nAudState <> #SCS_CUE_PL_READY)
      nLastRunningAud = k
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(aSub(pSubPtr)\nCurrPlayIndex) + ", nLastRunningAud=" + getAudLabel(nLastRunningAud))
  nPos = 0
  If nLastRunningAud >= 0
    nTestTime = aSub(pSubPtr)\nPLTestTime
    nPLUnplayedFilesTime = aSub(pSubPtr)\nPLUnplayedFilesTime
    ; debugMsg(sProcName, "nTestTime=" + nTestTime + ", nPLUnplayedFilesTime=" + nPLUnplayedFilesTime)
    
    With aAud(nLastRunningAud)
      ; debugMsg(sProcName, \sAudLabel + ", \nAudState=" + decodeCueState(\nAudState))
      If \nAudState = #SCS_CUE_COMPLETED
        ; everything has been run
        nPos = nTestTime - nPLUnplayedFilesTime
        debugMsg(sProcName, "nTestTime=" + nTestTime + ", nPLUnplayedFilesTime=" + nPLUnplayedFilesTime + ", nPos=" + nPos)
        
      ElseIf \nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START
        If \nPrevPlayIndex >= 0
          nMyPrevPlayIndex = \nPrevPlayIndex
        Else
          nMyPrevPlayIndex = aSub(\nSubIndex)\nLastPlayIndex
        EndIf
        
        nPos = nTestTime - nPLUnplayedFilesTime + (aAud(nMyPrevPlayIndex)\nPLTransTime - \nPLCountDownTimeLeft)
        
      ElseIf \nAudState = #SCS_CUE_PAUSED
        ; paused therefore no change
        ; (do not recalc as millisecond differences can cause apparent
        ; changes in position when rounded to nearest 1/100 second)
        nPos = aSub(pSubPtr)\nPLCuePosition
        
      ElseIf (gnPLFirstAndLastTime < 0) Or (aSub(\nSubIndex)\bStartedInEditor = #False)
        nPos = nTestTime - nPLUnplayedFilesTime - \nCueDuration + \nCuePos
        ; debugMsg(sProcName, "nTestTime ="+nTestTime+", nPLUnplayedFilesTime="+nPLUnplayedFilesTime+", \nCueDuration="+\nCueDuration+", \nCuePos="+\nCuePos)
        
      Else
        If \nCueDuration > (gnPLFirstAndLastTime + gnPLFirstAndLastTime)
          nFileTestLength = gnPLFirstAndLastTime + gnPLFirstAndLastTime
          If \nCuePos <= gnPLFirstAndLastTime
            nPos = nTestTime - nPLUnplayedFilesTime - nFileTestLength + \nCuePos
          Else
            nPos = nTestTime - nPLUnplayedFilesTime - (\nCueDuration - \nCuePos)
          EndIf
        Else
          nPos = nTestTime - nPLUnplayedFilesTime - \nCueDuration + \nCuePos
        EndIf
        
      EndIf
      
    EndWith
  EndIf
  
  aSub(pSubPtr)\nPLCuePosition = nPos
  
EndProcedure

Procedure calcPLTotalTime(pSubPtr)
  ; See also M2T_calcAudRelStartTimes()
  ; PROCNAMECS(pSubPtr)
  Protected nTotalTime, nTmpTime, k
  Protected nPrevTransType, nPrevTransTime

  ; debugMsg(sProcName, #SCS_START)
  
  ; Added 6Nov2020 11.8.3.3ad as previously this was rounding \nSubDuration of type F subs, which could affect linking
  If aSub(pSubPtr)\bSubTypeAorP = #False
    ProcedureReturn
  EndIf
  ; End added 6Nov2020 11.8.3.3ad
  
  nTotalTime = 0
  nPrevTransType = #SCS_TRANS_NONE
  nPrevTransTime = 0
  
  k = aSub(pSubPtr)\nFirstPlayIndex
  While k >= 0
    With aAud(k)
      ; debugMsg(sProcName, \sAudLabel + ", \nFileDuration=" + \nFileDuration + ", \nCueDuration=" + \nCueDuration + ", \sFileState=" + decodeFileState(\nFileState) + ", \nAudState=" + decodeCueState(\nAudState))
      If \nCueDuration = #SCS_CONTINUOUS_LENGTH
        nTotalTime = #SCS_CONTINUOUS_LENGTH
        Break
      EndIf
      ; round duration to hundredths of seconds so times add up correctly
      nTmpTime = (Round(\nCueDuration / 10, #PB_Round_Nearest) * 10)
      nTotalTime + nTmpTime
      Select nPrevTransType
        Case #SCS_TRANS_XFADE
          nTotalTime - nPrevTransTime
        Case #SCS_TRANS_MIX
          nTotalTime - nPrevTransTime
        Case #SCS_TRANS_WAIT
          nTotalTime + nPrevTransTime
      EndSelect
      nPrevTransType = \nPLTransType
      nPrevTransTime = \nPLTransTime
      k = \nNextPlayIndex
    EndWith
  Wend
  
  If nTotalTime <> #SCS_CONTINUOUS_LENGTH
    If aSub(pSubPtr)\bPLRepeat
      Select nPrevTransType
        Case #SCS_TRANS_XFADE
          nTotalTime - nPrevTransTime
        Case #SCS_TRANS_MIX
          nTotalTime - nPrevTransTime
        Case #SCS_TRANS_WAIT
          nTotalTime + nPrevTransTime
      EndSelect
    EndIf
  EndIf
  
  aSub(pSubPtr)\nSubDuration = nTotalTime
  aSub(pSubPtr)\nPLTotalTime = nTotalTime
  aSub(pSubPtr)\nPLTestTime = nTotalTime
  If pSubPtr = nEditSubPtr
    calcPLTestTime(pSubPtr)
  EndIf
  
  ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubDuration=" + aSub(pSubPtr)\nSubDuration)
  
  ; debugMsg(sProcName, #SCS_END + ", nPLTotalTime=" + ttsz(nTotalTime))
EndProcedure

Procedure calcPLUnplayedFilesTime(pSubPtr)
  PROCNAMECS(pSubPtr)

  ; this sub is identical to calcPLTestTime except that only 'ready' files are considered

  Protected nUnplayedTime, nTmpTime, k
  Protected nPrevTransType
  Protected nPrevTransTime, nPrevFadeOutTime
  Protected bSubStartedInEditor
  
  If aSub(pSubPtr)\bSubTypeM
    ProcedureReturn
  EndIf
  
  bSubStartedInEditor = aSub(pSubPtr)\bStartedInEditor
  If (bSubStartedInEditor) And (gnPLTestMode = #SCS_PLTESTMODE_HIGHLIGHTED_FILE)
    If nEditAudPtr >= 0
      With aAud(nEditAudPtr)
        If \nAudState <= #SCS_CUE_READY Or \nAudState = #SCS_CUE_PL_READY
          nUnplayedTime = aAud(nEditAudPtr)\nCueDuration
        Else
          nUnplayedTime = 0
        EndIf
      EndWith
    EndIf
  Else
    If (aSub(pSubPtr)\nSubState >= #SCS_CUE_READY) And (aSub(pSubPtr)\nSubState <= #SCS_CUE_COMPLETED)
      ; debugMsg(sProcName, "\nCurrPlayIndex=" + getAudLabel(aSub(pSubPtr)\nCurrPlayIndex))
      k = aSub(pSubPtr)\nCurrPlayIndex
      While k >= 0
        With aAud(k)
          ; debugMsg(sProcName, "k=" + getAudLabel(k) + ", \nAudState=" + decodeCueState(\nAudState) + ", \nCueDuration=" + \nCueDuration)
          If \nAudState <= #SCS_CUE_READY Or \nAudState = #SCS_CUE_PL_READY Or k <> aSub(pSubPtr)\nCurrPlayIndex
            If \nCueDuration = #SCS_CONTINUOUS_LENGTH
              nUnplayedTime = #SCS_CONTINUOUS_LENGTH
              Break
            EndIf
            ; round duration to hundredths of seconds so times add up correctly
            nTmpTime = (Round(\nCueDuration / 10, #PB_Round_Nearest) * 10)
            ;debugMsg(sProcName, "nTmpTime=" & nTmpTime)
            If (gnPLFirstAndLastTime = -1) Or (bSubStartedInEditor = #False)
              nUnplayedTime + nTmpTime
            ElseIf nTmpTime > (gnPLFirstAndLastTime + gnPLFirstAndLastTime)
              nUnplayedTime + gnPLFirstAndLastTime + gnPLFirstAndLastTime
            Else
              nUnplayedTime + nTmpTime
            EndIf
            Select nPrevTransType
              Case #SCS_TRANS_XFADE
                nUnplayedTime - nPrevFadeOutTime
              Case #SCS_TRANS_MIX
                nUnplayedTime - nPrevTransTime
              Case #SCS_TRANS_WAIT
                nUnplayedTime + nPrevTransTime
            EndSelect
          EndIf
          nPrevTransType = \nPLTransType
          nPrevTransTime = \nPLTransTime
          nPrevFadeOutTime = \nFadeOutTime
          If (gnPLFirstAndLastTime <> -1) And (nPrevFadeOutTime > gnPLFirstAndLastTime)
            nPrevFadeOutTime = gnPLFirstAndLastTime
          EndIf
          k = \nNextPlayIndex
        EndWith
      Wend
      
      If nUnplayedTime <> #SCS_CONTINUOUS_LENGTH
        If aSub(pSubPtr)\bPLRepeat
          Select nPrevTransType
            Case #SCS_TRANS_XFADE
              nUnplayedTime - nPrevFadeOutTime
            Case #SCS_TRANS_MIX
              nUnplayedTime - nPrevTransTime
            Case #SCS_TRANS_WAIT
              nUnplayedTime + nPrevTransTime
          EndSelect
        EndIf
      EndIf
    EndIf
    
  EndIf

  aSub(pSubPtr)\nPLUnplayedFilesTime = nUnplayedTime
  debugMsg(sProcName, "nPLUnplayedFilesTime=" + ttsz(aSub(pSubPtr)\nPLUnplayedFilesTime))

EndProcedure

Procedure calcPLTimeToGo(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nTimeToGo, nTmpTime, k
  Protected nPrevTransType
  Protected nPrevTransTime, nPrevFadeOutTime
  
  If aSub(pSubPtr)\bSubTypeM
    ProcedureReturn
  EndIf
  
  nTimeToGo = 0
  nPrevTransType = #SCS_TRANS_NONE
  nPrevTransTime = 0
  nPrevFadeOutTime = 0
  
  If (aSub(pSubPtr)\nSubState >= #SCS_CUE_READY) And (aSub(pSubPtr)\nSubState <= #SCS_CUE_COMPLETED)
    k = aSub(pSubPtr)\nCurrPlayIndex
    While k >= 0
      With aAud(k)
        If \nAudState <= #SCS_CUE_READY Or \nAudState = #SCS_CUE_PL_READY Or k <> aSub(pSubPtr)\nCurrPlayIndex
          ; round duration to hundredths of seconds so times add up correctly
          nTmpTime = (Round(\nCueDuration / 10, #PB_Round_Nearest) * 10)
          ;Call debugMsg(sProcName, "nTmpTime=" & nTmpTime)
          nTimeToGo + nTmpTime
          Select nPrevTransType
            Case #SCS_TRANS_XFADE
              nTimeToGo - nPrevFadeOutTime
            Case #SCS_TRANS_MIX
              nTimeToGo - nPrevTransTime
            Case #SCS_TRANS_WAIT
              nTimeToGo + nPrevTransTime
          EndSelect
        ElseIf k = aSub(pSubPtr)\nCurrPlayIndex
          nTmpTime = \nCueDuration - \nCuePos
          nTimeToGo + nTmpTime
        EndIf
        nPrevTransType = \nPLTransType
        nPrevTransTime = \nPLTransTime
        nPrevFadeOutTime = \nFadeOutTime
        If (gnPLFirstAndLastTime <> -1) And (nPrevFadeOutTime > gnPLFirstAndLastTime)
          nPrevFadeOutTime = gnPLFirstAndLastTime
        EndIf
        k = \nNextPlayIndex
      EndWith
    Wend
    
    If aSub(pSubPtr)\bPLRepeat
      Select nPrevTransType
        Case #SCS_TRANS_XFADE
          nTimeToGo - nPrevFadeOutTime
        Case #SCS_TRANS_MIX
          nTimeToGo - nPrevTransTime
        Case #SCS_TRANS_WAIT
          nTimeToGo + nPrevTransTime
      EndSelect
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "nTimeToGo=" + nTimeToGo)
  ProcedureReturn nTimeToGo
EndProcedure

Procedure casAddRequest()
  PROCNAMEC()

  With grMain
    debugMsg(sProcName, "grCasItem\nCasCueAction=" + decodeCasAction(grCasItem\nCasCueAction) + ", \nCasGroupId=" + grCasItem\nCasGroupId +
                        ", \nCasMixerStream=" + decodeHandle(grCasItem\nCasMixerStream) + ", \nCasChannel=" + decodeHandle(grCasItem\nCasChannel))
    gaCasArray(\nCasWritePtr) = grCasItem
    gaCasArray(\nCasWritePtr)\bCasActioned = #False
    If grCasItem\nCasGroupId = -1
      gaCasArray(\nCasWritePtr)\bCasWaitForGroupReady = #False
    Else
      gaCasArray(\nCasWritePtr)\bCasWaitForGroupReady = #True
    EndIf
    \nCasRequestsWaiting + 1
    
    \nCasWritePtr = \nCasWritePtr + 1
    If \nCasWritePtr > ArraySize(gaCasArray())
      \nCasWritePtr = 0
    EndIf
  EndWith

EndProcedure

Procedure casInit()
  ; initialise CAS - the Cue Action Stack
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)

  ReDim gaCasArray(500)
  grMain\nCasReadPtr = 0
  grMain\nCasWritePtr = 0
  grMain\nCasRequestsWaiting = 0
  grMain\bCasProcessing = #False
  For n = 0 To ArraySize(gaCasArray())
    gaCasArray(n)\nCasCueAction = 0
    gaCasArray(n)\bCasActioned = #False
  Next n

  grMain\nCasGroupId = 100
  ReDim gaCasGroupArray(250)
  For n = 0 To ArraySize(gaCasGroupArray())
    gaCasGroupArray(n)\nCasGroupId = -1    ; indicates slot available
  Next n

EndProcedure

Procedure casNewGroup()
  PROCNAMEC()
  Protected n, nMyGroupId

  nMyGroupId = -1

  For n = 0 To ArraySize(gaCasGroupArray())
    If gaCasGroupArray(n)\nCasGroupId = -1
      ; spare slot found
      With gaCasGroupArray(n)
        grMain\nCasGroupId + 1
        \nCasGroupId = grMain\nCasGroupId
        \bCasGroupReady = #False
        \qCasTimeCreated = gqTimeNow
        nMyGroupId = \nCasGroupId
      EndWith
      Break
    EndIf
  Next n

  debugMsg(sProcName, "nMyGroupId=" + nMyGroupId)

  ; note: if no spare slot is found then SCS continues without grouping the related requests, becuse the nGroupId will be -1 (which means ungrouped)
  ProcedureReturn nMyGroupId
EndProcedure

Procedure casProcess()
  PROCNAMEC()
  Protected rThisCasItem.tyCasItem
  Protected nMciResult.l
  Protected nBassResult.l, nErrorCode.l
  Protected n
  Protected nMixerStream.l
  Protected bRefreshGridCues, bDoEvents
  Protected bLeaveRequestInList, nLeaveCount
  Protected nReadPtrFirstLeft
  Protected dblStartPos.d
  Protected bUseAsioLock ;, bAsioLockedByThisProc
  
  If (grMain\nCasRequestsWaiting = 0) Or (grMain\bCasProcessing)
    ProcedureReturn
  EndIf
  grMain\bCasProcessing = #True

  ; debugMsg(sProcName, SCS_START + ", nCasRequestsWaiting=" + nCasRequestsWaiting)

  ; first pass to process play midi (or similar) commands before others, to provide better syncing of midi-to-audio
  If grMain\nCasRequestsWaiting > 0
    For n = grMain\nCasReadPtr To (grMain\nCasReadPtr + grMain\nCasRequestsWaiting - 1)
      If n <= ArraySize(gaCasArray())
        rThisCasItem = gaCasArray(n)
        With rThisCasItem
          If (\bCasActioned = #False) And (\bCasWaitForGroupReady = #False)
            Select \nCasCueAction
              Case #SCS_CAS_MCI_STRING
                nMciResult = mciSendString_(\sCasMciString, #Null, 0, #Null)
                debugMsg2(sProcName, "mciSendString_(" + \sCasMciString + ", #Null, 0, #Null)", nMciResult)
                If nMciResult <> 0
                  displayMidiError(nMciResult, \sCasMciString, sProcName)
                EndIf
              Case #SCS_CAS_MIXER_PAUSE, #SCS_CAS_MIXER_UNPAUSE
                If gnCurrAudioDriver = #SCS_DRV_BASS_ASIO
                  bUseAsioLock = #True
                EndIf
            EndSelect
          EndIf
        EndWith
      EndIf
    Next n
  EndIf
  
  nLeaveCount = 0
  nReadPtrFirstLeft = -1
  
  setGlobalTimeNow()
  
  CompilerIf #c_enable_bass_asio_lock = #False
    bUseAsioLock = #False
  CompilerEndIf
  
  If bUseAsioLock
    lockBassAsioIfReqd()
  EndIf
  
  While (grMain\nCasRequestsWaiting - nLeaveCount) > 0
    
    If gaCasArray(grMain\nCasReadPtr)\bCasActioned = #False
      rThisCasItem = gaCasArray(grMain\nCasReadPtr)
      If rThisCasItem\bCasWaitForGroupReady
        bLeaveRequestInList = #True
        nLeaveCount + 1
      Else
        bLeaveRequestInList = #False
        With rThisCasItem
          Select \nCasCueAction
            
            Case #SCS_CAS_MIXER_UNPAUSE ; #SCS_CAS_MIXER_UNPAUSE
              nBassResult = BASS_Mixer_ChannelFlags(\nCasChannel, 0, #BASS_MIXER_CHAN_PAUSE) ; clear the pause flag
              debugMsg3(sProcName, "BASS_Mixer_ChannelFlags(" + decodeHandle(\nCasChannel) + ", 0, #BASS_MIXER_CHAN_PAUSE)" + " [" + \sCasOriginProcName + "] returned " + decodeMixerChannelFlags(nBassResult))
              
            Case #SCS_CAS_MIXER_PAUSE ; #SCS_CAS_MIXER_PAUSE
              nBassResult = BASS_Mixer_ChannelFlags(\nCasChannel, #BASS_MIXER_CHAN_PAUSE, #BASS_MIXER_CHAN_PAUSE) ; set the pause flag
              debugMsg3(sProcName, "BASS_Mixer_ChannelFlags(" + decodeHandle(\nCasChannel) + ", #BASS_MIXER_CHAN_PAUSE, #BASS_MIXER_CHAN_PAUSE)" + " [" + \sCasOriginProcName + "] returned " + decodeMixerChannelFlags(nBassResult))
              
            Case #SCS_CAS_FADE_OUT ; #SCS_CAS_FADE_OUT
              nBassResult = BASS_ChannelSlideAttribute(\nCasChannel, #BASS_ATTRIB_VOL, 0, \nCasTime)
              debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(\nCasChannel) + ", #BASS_ATTRIB_VOL, 0.0, " + \nCasTime + ") [" + \sCasOriginProcName + "]", nBassResult)
              
            Case #SCS_CAS_PLAY_AUD ; #SCS_CAS_PLAY_AUD
              nBassResult = BASS_ChannelPlay(\nCasChannel, #BASSFALSE)
              logKeyEvent("BASS_ChannelPlay(" + decodeHandle(\nCasChannel) + ", #BASSFALSE) [" + \sCasOriginProcName + "]")
              debugMsg2(sProcName, "BASS_ChannelPlay(" + decodeHandle(\nCasChannel) + ", #BASSFALSE) [" + \sCasOriginProcName + "]", nBassResult)
              If nBassResult = #BASSFALSE
                debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
              EndIf
              
            Case #SCS_CAS_MCI_STRING ; #SCS_CAS_MCI_STRING
              ; already processed (first pass), but need to keep the 'Case' statement to ensure item is marked as actioned
              
            Case #SCS_CAS_PLAY_VIDEO ; #SCS_CAS_PLAY_VIDEO
              playVideo(\nCasAudPtr, \nCasVidPicTarget)
              bDoEvents = #True
              
          EndSelect
          
        EndWith
        
      EndIf
      
      If bLeaveRequestInList
        If nReadPtrFirstLeft = -1
          nReadPtrFirstLeft = grMain\nCasReadPtr
        EndIf
      Else
        gaCasArray(grMain\nCasReadPtr)\bCasActioned = #True
        grMain\nCasRequestsWaiting - 1
      EndIf
      
      grMain\nCasReadPtr = grMain\nCasReadPtr + 1
      If grMain\nCasReadPtr > ArraySize(gaCasArray())
        grMain\nCasReadPtr = 0
      EndIf
      
    Else
      grMain\nCasReadPtr = grMain\nCasReadPtr + 1
      If grMain\nCasReadPtr > ArraySize(gaCasArray())
        grMain\nCasReadPtr = 0
      EndIf
      
    EndIf
    
  Wend

  If bUseAsioLock
    unlockBassAsioIfReqd()
  EndIf
  
  If nReadPtrFirstLeft >= 0
    grMain\nCasReadPtr = nReadPtrFirstLeft
  EndIf

  If bRefreshGridCues
    WMN_refreshGrdCues()     ; force refresh of grid so column headers are repainted
  EndIf

  grMain\bCasProcessing = #False

EndProcedure

Procedure casReadyGroup(nGroupId)
  PROCNAMEC()
  Protected n

  debugMsg(sProcName, "nGroupId=" + nGroupId)

  If nGroupId = -1
    ; group wasn't created
    ProcedureReturn
  EndIf

  For n = 0 To ArraySize(gaCasArray())
    If gaCasArray(n)\bCasActioned = #False
      If gaCasArray(n)\nCasGroupId = nGroupId
        gaCasArray(n)\bCasWaitForGroupReady = #False
      EndIf
    EndIf
  Next n

  For n = 0 To ArraySize(gaCasGroupArray())
    If gaCasGroupArray(n)\nCasGroupId = nGroupId
      gaCasGroupArray(n)\nCasGroupId = -1    ; make slot available again
      Break
    EndIf
  Next n

EndProcedure

Procedure checkCueToGoForWarning()
  PROCNAMECQ(gnCueToGo)
  Protected sThisCue.s
  Protected nDisplayWarning     ; 0 = not set, 1 = display warning, 2 = do not display warning
  Protected sMsg.s
  Protected nCuePtr, nSubPtr, sLabel.s
  Protected j, n
  Protected nTimeDiff
  Protected qTimeNow.q
  Static bNothingToDoDisplayed
  
  ; debugMsg(sProcName, #SCS_START + ", gnCueToGo=" + getCueLabel(gnCueToGo))
  
  If (gnCueToGo > 0) And (gnCueToGo < gnCueEnd)
    
    If (aCue(gnCueToGo)\bSubTypeS) Or (aCue(gnCueToGo)\bSubTypeL) Or (aCue(gnCueToGo)\bSubTypeT)
      
      j = aCue(gnCueToGo)\nFirstSubIndex
      While (j >= 0) And (nDisplayWarning <> 2) ; if flag is set to 2 (do not display warning) then exit loop so tha flag cannot be changed to 1
        With aSub(j)
          If \bSubTypeS
            For n = 0 To #SCS_MAX_SFR
              If \nSFRCueType[n] = #SCS_SFR_CUE_SEL
                nCuePtr = \nSFRCuePtr[n]
                If nCuePtr > 0
                  If aCue(nCuePtr)\nCueState >= #SCS_CUE_COMPLETED
                    nDisplayWarning = 1    ; display warning
                    sLabel = aCue(nCuePtr)\sCue
                  ElseIf aCue(nCuePtr)\nCueState >= #SCS_CUE_FADING_IN
                    ; at least one cue still playing, so clear bDisplayWarning and get out of loop
                    nDisplayWarning = 2    ; do not display warning
                    Break
                  EndIf
                EndIf
              EndIf
            Next n
            
          ElseIf \bSubTypeL
            nSubPtr = \nLCSubPtr
            If nSubPtr > 0
              If aSub(nSubPtr)\nSubState >= #SCS_CUE_COMPLETED
                nDisplayWarning = 1    ; display warning
                sLabel = aSub(nSubPtr)\sSubLabel
              Else
                nDisplayWarning = 2    ; do not display warning
              EndIf
            EndIf
            
          ElseIf \bSubTypeT
            nCuePtr = getCuePtr(\sSetPosCue)
            If nCuePtr >= 0
              If aCue(nCuePtr)\nCueState >= #SCS_CUE_COMPLETED
                nDisplayWarning = 1    ; display warning
                sLabel = aCue(nCuePtr)\sCue
              Else
                nDisplayWarning = 2    ; do not display warning
              EndIf
            EndIf
            
          Else
            nDisplayWarning = 2    ; at least one sub that requires action, so do not display warning
            
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
      
    EndIf
  EndIf

  If nDisplayWarning = 1
    sThisCue = aCue(gnCueToGo)\sCue
    sMsg = Lang("WMN", "NothingToDo")
    sMsg = ReplaceString(sMsg, "$1", sThisCue)
    sMsg = ReplaceString(sMsg, "$2", sLabel)
    WMN_setStatusField(sMsg, #SCS_STATUS_MAJOR_WARN)
    bNothingToDoDisplayed = #True
    
  ElseIf bNothingToDoDisplayed
    ; 2014/08/05 11.3.2: added bNothingToDoDisplayed and associated code following bug forum posting by Nicko "SFR warning" 
    debugMsg(sProcName, "clearing status field")
    WMN_setStatusField("", #SCS_STATUS_CLEAR)
    bNothingToDoDisplayed = #False
    
  ElseIf gbMajorWarnDisplayed
    qTimeNow = ElapsedMilliseconds()
    nTimeDiff = qTimeNow - gqTimeWarningMessageDisplayed
    debugMsg(sProcName, "qTimeNow=" + traceTime(qTimeNow) + ", gqTimeWarningMessageDisplayed=" + traceTime(gqTimeWarningMessageDisplayed) + ", nTimeDiff=" + nTimeDiff)
    If nTimeDiff > 2000
      debugMsg(sProcName, "clearing status field")
      WMN_setStatusField("", #SCS_STATUS_CLEAR)
    EndIf
    
  EndIf

EndProcedure

Procedure checkExclusiveCuePlaying()
  PROCNAMEC()
  Protected nPlayingExclusiveCuePtr
  Protected i

  nPlayingExclusiveCuePtr = -1
  
  For i = 1 To gnLastCue
    With aCue(i)
      If (\bCueCurrentlyEnabled) And (\nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nCueState <= #SCS_CUE_FADING_OUT)
        If \bExclusiveCue
          nPlayingExclusiveCuePtr = i
          Break
        EndIf
      EndIf
    EndWith
  Next i

  ProcedureReturn nPlayingExclusiveCuePtr

EndProcedure

Procedure ErrorHandler(pProcName.s, pErr.s, pInfo.s = "", bFatal = #True)
  Protected sErr.s, sMessage.s, nMsgReply
  
  sErr = pErr
  If Len(sErr) = 0
    sErr = getErrorInfo()
  EndIf
  
  sMessage = "Error: " + sErr + Chr(10) + Chr(10)
  sMessage + "SCS " + #SCS_VERSION + Chr(10)
  sMessage + "Time Now: " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", Date()) + Chr(10)
  sMessage + "Session Time: " + FormatUsingQ((ElapsedMilliseconds() - gqStartTime), "#####0.000") + Chr(10)
  sMessage + "ProcName: " + pProcName + Chr(10)
  If pInfo
    sMessage + pInfo + Chr(10)
  EndIf
  sMessage + "CueFile: " + gsCueFile
  debugMsg(pProcName, "-----------------------------")
  debugMsg(pProcName, sMessage)
  debugMsg(pProcName, "-----------------------------")
  setMouseCursorNormal()
  If gbCrashClose = #False     ; prevents MessageRequester being re-displayed if errors occur during a crash close
    ensureSplashNotOnTop()
    scsMessageRequester("SCS Error", sMessage, #PB_MessageRequester_Error)
    gbCrashClose = #True
    debugMsg(pProcName, "closing down")
    closeDown(#True)
    BASS_ASIO_Free()
    BASS_Free()
    End
  EndIf
EndProcedure

Procedure checkMaxAud(nAudPtr)
  PROCNAMEC()
  Protected nAudArraySize
  
  ; debugMsg(sProcName, #SCS_START)
  
  nAudArraySize = ArraySize(aAud())
  ; debugMsg(sProcName, "nAudPtr=" + nAudPtr + ", nAudArraySize=" + nAudArraySize)
  If nAudPtr > (nAudArraySize - 10)
    nAudArraySize = nAudPtr + 40
    REDIM_ARRAY(aAud, nAudArraySize, grAudDef, "aAud()")
    debugMsg(sProcName, "aAud Redim. new size = " + ArraySize(aAud()))
  EndIf
EndProcedure

Procedure checkMaxCue(nCuePtr)
  PROCNAMEC()
  Protected nCueArraySize, bModalDisplayed
  Protected sMsg.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  bModalDisplayed = gbModalDisplayed

  If gnMaxCueIndex >= 0
    If nCuePtr > gnMaxCueIndex
      ensureSplashNotOnTop()
      gbModalDisplayed = #True
      sMsg = Lang("WMN","TooManyCues")
      sMsg = ReplaceString(sMsg, "$1", Str(gnMaxCueIndex))
      sMsg = ReplaceString(sMsg, "$2", Str(nCuePtr))
      sMsg = ReplaceString(sMsg, "<br>", Chr(13))
      scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
      gbModalDisplayed = bModalDisplayed
      ProcedureReturn #False
    ElseIf nCuePtr > (gnMaxCueIndex - 3)
      If Not gbMaxCueWarningDisplayed
        ensureSplashNotOnTop()
        gbModalDisplayed = #True
        sMsg = Lang("WMN","ApproachingLimit")
        sMsg = ReplaceString(sMsg, "$1", Str(gnMaxCueIndex))
        scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONINFORMATION)
        gbModalDisplayed = bModalDisplayed
        gbMaxCueWarningDisplayed = #True
      EndIf
    EndIf
  EndIf

  nCueArraySize = ArraySize(aCue())
  ; debugMsg(sProcName, "nCuePtr=" + nCuePtr + ", nCueArraySize=" + nCueArraySize)
  If nCuePtr > (nCueArraySize - 5)
    nCueArraySize = nCuePtr + 25
    REDIM_ARRAY(aCue, nCueArraySize, grCueDef, "aCue()")
    debugMsg(sProcName, "aCue Redim. new size = " + ArraySize(aCue()))
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure checkMaxSub(nSubPtr, bPrimaryFile=#True)
  PROCNAMEC()
  Protected nSubArraySize
  
  ; debugMsg(sProcName, #SCS_START)

  If bPrimaryFile
    nSubArraySize = ArraySize(aSub())
    ; debugMsg(sProcName, "nSubPtr=" + nSubPtr + ", nSubArraySize=" + nSubArraySize)
    If nSubPtr > (nSubArraySize - 10)
      nSubArraySize = nSubPtr + 40
      ; REDIM_ARRAY(aSub, nSubArraySize, grSubDef)
      gnRedimIndex = ArraySize(aSub())
      ReDim aSub(nSubArraySize)
      If ArraySize(aSub()) < 0
        debugMsg(sProcName, "Out of bounds in function: " + #PB_Compiler_Procedure + " at line " + Str(#PB_Compiler_Line) + " in file " + #PB_Compiler_File) 
        setGlobalError(#SCS_ERROR_ARRAY_SIZE_INVALID, nSubArraySize, ArraySize(aSub()), "aSub()", sProcName)
        scsRaiseError()
      Else
        While gnRedimIndex < nSubArraySize
          gnRedimIndex + 1
          aSub(gnRedimIndex) = grSubDef
        Wend
        debugMsg(sProcName, "aSub Redim. new size = " + ArraySize(aSub()))
      EndIf
    EndIf
  Else
    nSubArraySize = ArraySize(a2ndSub())
    debugMsg(sProcName, "nSubPtr=" + nSubPtr + ", nSubArraySize=" + nSubArraySize)
    If nSubPtr > (nSubArraySize - 10)
      nSubArraySize = nSubPtr + 40
      REDIM_ARRAY(a2ndSub, nSubArraySize, grSubDef, "a2ndSub()")
      debugMsg(sProcName, "a2ndSub Redim. new size = " + ArraySize(a2ndSub()))
    EndIf
  EndIf
EndProcedure

Procedure closeDown(pCloseMain, bCallStopAllTimersAndThreads=#True)
  PROCNAMEC()
  Protected nBassResult.l, m
  Protected sTimeNow.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  logMsg(sProcName, #SCS_START)
  
  gbClosingDown = #True
  debugMsg(sProcName, "gbClosingDown=" + strB(gbClosingDown))
  
  ; exportGadgets()
  
  ; Warning! date() seems to return a different time to GetLocalTime (which is used in tracing). Seems strange.
  sTimeNow = FormatDate("%hh:%ii:%ss", Date())
  debugMsg(sProcName, "start closedown at " + sTimeNow + ", bCallStopAllTimersAndThreads=" + strB(bCallStopAllTimersAndThreads))
  
  gnSuspendGetCurrInfo = 99999999     ; set gnSuspendGetCurrInfo high to save having to check gbClosingDown in getSMSCurrInfo()
  gbRefreshVUDisplay = #False
  gbCheckForPrimeVideoReqd = #False
  
  ; gnSMSReceiveTimeOut = 500           ; reduce SMS Received timeout to 0.5 second
  
  If IsWindow(#WMN) = #False
    ; if fmMain isn't loaded then we crashed out very early, eg during checking device map
    Debug "END OF RUN (in closeDown())"
    End
  EndIf
  
  WMN_setStatusField(Lang("WMN", "ClosingSCS"), #SCS_STATUS_CLOSEDOWN)
  
  CompilerIf #c_no_blackout_on_start_or_closedown = #False
    If grDMX\bBlackOutOnCloseDown
      DMX_blackOutAll()
      Delay(100)  ; give thread time to execute this command
      grDMX\bBlackOutOnCloseDown = #False
    EndIf
  CompilerEndIf
  
  If bCallStopAllTimersAndThreads
    THR_stopAllTimersAndThreads()
  EndIf
  
  ; clear SAM stack
  samInit()
  
  If grPreview\nPreviewChannel <> 0
    nBassResult = BASS_StreamFree(grPreview\nPreviewChannel)
    debugMsg2(sProcName, "BASS_StreamFree(" + grPreview\nPreviewChannel + ")", nBassResult)
    freeHandle(grPreview\nPreviewChannel)
    grPreview\nPreviewChannel = 0
  EndIf
  
  debugMsg(sProcName, "calling closeAllDevices(#True, #True)")
  closeAllDevices(#True, #True) ; nb includes closing cues, eg audio and video cues that use devices
  
  nBassResult = BASS_PluginFree(0)
  debugMsg2(sProcName, "BASS_PluginFree(0)", nBassResult)
  
  ; close all MCI devices (eg midi files)
  debugMsg(sProcName, "calling closeAllMciDevices()")
  closeAllMciDevices()
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      vMix_Disconnect()
    EndIf
  CompilerEndIf
  
  If gbEditorAndOptionsLocked = #False
    debugMsg(sProcName, "saving preferences")
    savePreferences()
  EndIf
  
  If Len(grMain\sStayAwakeFile) <> 0
    If FileExists(grMain\sStayAwakeFile)
      DeleteFile(grMain\sStayAwakeFile)
    EndIf
  EndIf
  
  listImageLog()
  
  debugMsg(sProcName, "calling closeAllForms(" + StrB(pCloseMain) + ")")
  closeAllForms(pCloseMain)
  
  debugMsg(sProcName, "calling mmTerminate()")
  mmTerminate()
  
  If gbUseSMS
    ; close SMS connection and log file
; 22Feb2016 11.5.0 - don't try to display anything on the WMN status line because we have just closed #WMN so that status bar gadget is no longer valid
;     WMN_setStatusField(Lang("WMN", "ClosingSMS"), #SCS_STATUS_CLOSEDOWN)
;     debugMsg(sProcName, "calling closeSMSConnection()")
    closeSMSConnection()
;     WMN_setStatusField(Lang("WMN", "ClosingSCS"), #SCS_STATUS_CLOSEDOWN)
    ; closeSMSLog()
  EndIf
  
  debugMsg(sProcName, "calling closeTempDatabase()")
  closeTempDatabase()
  
  debugMsg(sProcName, "calling resetThreadExecutionState()")
  resetThreadExecutionState()
  
  If gnFTD2XXLibraryNo
    CloseLibrary(gnFTD2XXLibraryNo)
  EndIf
  
  If gnKernel32Library
    CloseLibrary(gnKernel32Library)
  EndIf
  
  closeWinmm()
  
  CompilerIf #c_include_tvg
    CompilerIf #TVG_VERSION <> "10.8.2.4" And 1=2 ; "And 1=2" added 17Feb2020 11.8.2.2an as CloseLibrary(gnTVGLibrary) sometimes hangs
      debugMsg(sProcName, "calling closeTVGLibrary()")
      closeTVGLibrary()
    CompilerEndIf
  CompilerEndIf
  
  debugMsg(sProcName, "calling setRunState(" + #DQUOTE$ + "C" + #DQUOTE$ + ")")
  setRunState("C")
  
  debugMsg(sProcName, "gnMaxGadgetNo=" + gnMaxGadgetNo + ", number of gadgets = " + Str(gnMaxGadgetNo - #SCS_GADGET_BASE_NO))
  ; debugMsg(sProcName, "gnTraceLine=" + gnTraceLine)
  
  CompilerIf 1=2 ; test added 17Feb2020 11.8.2.2an as CloseLibrary(#PB_All) sometimes hangs
    CloseLibrary(#PB_All)
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeAllForms(bCloseMain)
  PROCNAMEC()
  Protected n
  Protected bMainLoaded

  debugMsg(sProcName, #SCS_START + ", pCloseMain=" + strB(bCloseMain))
  
  For n = #WV2 To #WV_LAST
    If IsWindow(n)
      debugMsg(sProcName, "WindowX(" + decodeWindow(n) + ")=" + WindowX(n) + ", WindowY()=" + WindowY(n) + ", WindowWidth()=" + WindowWidth(n) + ", WindowHeight()=" + WindowHeight(n))
    EndIf
  Next n
  
  setMonitorPin()
  ; call Form_Unload() procedure for forms with window positions saved
  For n = 1 To (#WZZ-1)
    If IsWindow(n)
      Select n
        Case #WAC
          getFormPosition(#WAC, @grAGColorsWindow)
        Case #WBE
          getFormPosition(#WBE, @grBulkEditWindow)
        Case #WCD
          getFormPosition(#WCD, @grCountDownWindow, #True)
        Case #WCL
          getFormPosition(#WCL, @grClockWindow, #True)
        Case #WCM
          getFormPosition(#WCM, @grCtrlSetupWindow)
        Case #WCN
          getFormPosition(#WCN, @grControllersWindow)
        Case #WCP
          getFormPosition(#WCP, @grCopyPropsWindow)
        Case #WCS
          getFormPosition(#WCS, @grColorSchemeWindow)
        Case #WDD
          getFormPosition(#WDD, @grDMXDisplayWindow, #True)
        Case #WDT
          getFormPosition(#WDT, @grDMXTestWindow)
        Case #WE1
          getFormPosition(#WE1, @grMemoWindowMain, #True)
        Case #WE2
          getFormPosition(#WE2, @grMemoWindowPreview, #True)
        Case #WED
          getFormPosition(#WED, @grEditWindow, #True)
        Case #WEM
          getFormPosition(#WEM, @grEditModalWindow)
        Case #WES
          getFormPosition(#WES, @grScribbleStripWindow, #True)
        Case #WEX
          getFormPosition(#WEX, @grExportWindow)
        Case #WFF
          getFormPosition(#WFF, @grFavFilesWindow)
        Case #WFI
          getFormPosition(#WFI, @grFindWindow)
        Case #WFO
          getFormPosition(#WFO, @grFileOpenerWindow)
        Case #WFR
          getFormPosition(#WFR, @grFileRenameWindow)
        Case #WFS
          getFormPosition(#WFS, @grFavFileSelectorWindow)
        Case #WIC
          getFormPosition(#WIC, @grImportCSVWindow)
        Case #WID
          getFormPosition(#WID, @grImportDevsWindow)
        Case #WIM
          getFormPosition(#WIM, @grImportWindow)
        Case #WID
          getFormPosition(#WID, @grImportDevsWindow)
        Case #WLC
          getFormPosition(#WLC, @grLabelChangeWindow)
        Case #WLD
          getFormPosition(#WLD, @grLinkDevsWindow)
        Case #WMC
          getFormPosition(#WMC, @grMultiCueCopyEtcWindow)
        Case #WMN
          bMainLoaded = #True  ; leave fmMain until last
          Continue
        Case #WMT
          getFormPosition(#WMT, @grMidiTestWindow)
        Case #WNE
          getFormPosition(#WNE, @grNearEndWarningWindow, #True)
        Case #WOC
          getFormPosition(#WOC, @grOSCCaptureWindow)
        Case #WOP
          getFormPosition(#WOP, @grOptionsWindow)
        Case #WPR
          getFormPosition(#WPR, @grPrintCueListWindow)
        Case #WPF
          getFormPosition(#WPF, @grProdFolderWindow)
        Case #WPL
          getFormPosition(#WPL, @grVSTWindow)
        Case #WPT
          getFormPosition(#WPT, @grProdTimerWindow)
        Case #WTC
          getFormPosition(#WTC, @grMTCDisplayWindow, #True)
        Case #WTI
          getFormPosition(#WTI, @grTimerDisplayWindow, #True)
        Case #WTM
          getFormPosition(#WTM, @grTemplatesWindow)
        Case #WTP
          getFormPosition(#WTP, @grTimeProfileWindow)
        ; Case #WV2
          ; obsolete as at 11.3.0 - position of #WV2 etc now saved via setMonitorPin() when gbVideosOnMainWindow = #True
          ; If gbVideosOnMainWindow
            ; ; nb only save position of #WV2 - if any video windows are present then #WV2 will be present, and other #WVn window positions can be derived from #WV2
            ; getFormPosition(#WV2, @grVideoWindow)
          ; EndIf
        Case #WVP
          getFormPosition(#WVP, @grVSTPluginsWindow)
      EndSelect
      CloseWindow(n)
    EndIf
  Next n

  If (bMainLoaded) And (bCloseMain)
    debugMsg(sProcName, "unloading Form fmMain")
    CloseWindow(#WMN)
  EndIf

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure colorLine(pCuePtr, nHostWindow=#WMN)
  ; sets the background and text colors for the line in the main window's cue list for cue pCuePtr
  PROCNAMECQ(pCuePtr)
  Protected nColNo, nRowNo, nCueState
  Protected nBackColor, nTextColor
  Protected nMyBackColor.l, nMyTextColor.l  ; must be Longs
  Protected nItemIndex = -1
  Protected bAdjustable
  Protected nHighlightedCue
  Protected nRed, nGreen, nBlue, nDimPercentage
  Protected n

  ; debugMsg(sProcName, #SCS_START + ", nHostWindow=" + decodeWindow(nHostWindow))

  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_UPDATE_SCREEN_FOR_CUE, pCuePtr, 0, #False)
    ProcedureReturn
  EndIf
  
  Select nHostWindow
    Case #WMN
      If IsGadget(WMN\grdCues) = 0
        debugMsg(sProcName, "exiting - IsGadget(WMN\grdCues)=" + IsGadget(WMN\grdCues))
        ProcedureReturn
      EndIf
      nCueState = getCueStateForDisplayEtc(pCuePtr)
      nHighlightedCue = gnHighlightedCue
    Case #WED
      If IsGadget(WED\tvwProdTree) = 0
        debugMsg(sProcName, "exiting - IsGadget(WED\tvwProdTree)=" + IsGadget(WED\tvwProdTree))
        ProcedureReturn
      EndIf
      nCueState = #SCS_CUE_READY
      nHighlightedCue = -1
  EndSelect

  ; debugMsg(sProcName, "grColorScheme\sSchemeName=" + grColorScheme\sSchemeName)
  
  With aCue(pCuePtr)
    
    If pCuePtr = gnCueEnd
      nItemIndex = #SCS_COL_ITEM_EN
      
    ElseIf nCueState = #SCS_CUE_ERROR
      nBackColor = #SCS_Red   ; grColorScheme\nBackColorNotFound
      nTextColor = #SCS_White ; grColorScheme\nTextColorNotFound
      
    ElseIf \bHotkey Or \bExtAct
      nItemIndex = #SCS_COL_ITEM_HK
      bAdjustable = #True
      
    ElseIf \bCallableCue
      nItemIndex = #SCS_COL_ITEM_CC
      bAdjustable = #True
      
    Else
      nBackColor = \nBackColor
      nTextColor = \nTextColor
      bAdjustable = #True
      
    EndIf
    
    If (pCuePtr <> gnCueEnd) And (pCuePtr <> nHighlightedCue)
      If nCueState = #SCS_CUE_COMPLETED And \nActivationMethod = #SCS_ACMETH_HK_STEP
        nItemIndex = #SCS_COL_ITEM_CM
        bAdjustable = #False
        
      ElseIf (nCueState = #SCS_CUE_COMPLETED) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
        nItemIndex = #SCS_COL_ITEM_CM
        bAdjustable = #False
        
      ElseIf (nCueState >= #SCS_CUE_FADING_IN) And (nCueState <= #SCS_CUE_FADING_OUT) And (nCueState <> #SCS_CUE_HIBERNATING)
        nItemIndex = #SCS_COL_ITEM_RU
        bAdjustable = #False
        
      ElseIf (nCueState = #SCS_CUE_COUNTDOWN_TO_START) Or (nCueState = #SCS_CUE_SUB_COUNTDOWN_TO_START) Or (nCueState = #SCS_CUE_PL_COUNTDOWN_TO_START)
        nItemIndex = #SCS_COL_ITEM_CT
        bAdjustable = #False
      EndIf
    EndIf
    
    If nItemIndex >= 0
      nBackColor = grColorScheme\aItem[nItemIndex]\nBackColor
      nTextColor = grColorScheme\aItem[nItemIndex]\nTextColor
    EndIf
    
    If grM2T\bM2TCueListColoringReqd
      ; if M2T current then dim cues that are NOT part of this M2T request
      If aCue(pCuePtr)\bM2TCue = #False And aCue(pCuePtr)\nCueState < #SCS_CUE_COMPLETED ; nb do not dim 'completed' or 'error' cues
        nDimPercentage = 50
        ; dim back color
        nRed = (Red(nBackColor) * nDimPercentage) / 100
        nGreen = (Green(nBackColor) * nDimPercentage) / 100
        nBlue = (Blue(nBackColor) * nDimPercentage) / 100
        nBackColor = RGB(nRed, nGreen, nBlue)
        ; dim text color
        nRed = (Red(nTextColor) * nDimPercentage) / 100
        nGreen = (Green(nTextColor) * nDimPercentage) / 100
        nBlue = (Blue(nTextColor) * nDimPercentage) / 100
        nTextColor = RGB(nRed, nGreen, nBlue)
      EndIf
    EndIf
    
    If bAdjustable
      If pCuePtr = nHighlightedCue
        ; debugMsg(sProcName, "calling setColorsForNextManualCue()")
        setColorsForNextManualCue(nBackColor, nTextColor, @nBackColor, @nTextColor)
      Else
        ; debugMsg(sProcName, "calling setColorsForOtherCues()")
        setColorsForOtherCues(nBackColor, nTextColor, @nBackColor, @nTextColor)
      EndIf
    Else
      ; debugMsg(sProcName, "bAdjustable=" + strB(bAdjustable))
    EndIf
    
    Select nHostWindow
      Case #WMN
        nRowNo = \nGrdCuesRowNo
        If nRowNo >= 0
          CompilerIf #c_black_grey_scheme
            If bAdjustable And pCuePtr = nHighlightedCue
              ; leave nBackColor and nTextColor unchanged
            Else
              If nRowNo & 1
                ; odd row no.
                ; nBackColor = #SCS_Darker_Grey
                ; nTextColor = RGB(255,250,250)
                nBackColor = #SCS_GUI_BackColor2
              Else
                ; even row no. (nb row numbers start from 0, so first row displayed will be black)
                ; nBackColor = #SCS_Black
                ; nTextColor = RGB(255,250,250)
                nBackColor = #SCS_GUI_BackColor1
              EndIf
              nTextColor = #SCS_GUI_TextColor1
            EndIf
          CompilerEndIf
          ; set front and back colors of the row
          If nTextColor <> GetGadgetItemColor(WMN\grdCues, nRowNo, #PB_Gadget_FrontColor, 1)
            SetGadgetItemColor(WMN\grdCues, nRowNo, #PB_Gadget_FrontColor, nTextColor, -1)
          EndIf
          If nBackColor <> GetGadgetItemColor(WMN\grdCues, nRowNo, #PB_Gadget_BackColor, 1)
            SetGadgetItemColor(WMN\grdCues, nRowNo, #PB_Gadget_BackColor, nBackColor, -1)
          EndIf
        EndIf
      Case #WED
    EndSelect
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure colorCueListEntries()
  PROCNAMEC()
  Protected i
  
  For i = 1 To gnLastCue
    colorLine(i)
  Next i
  grM2T\bM2TCueListColoringApplied = grM2T\bM2TCueListColoringReqd
  
EndProcedure

Procedure debugProd(*rProd.tyProd)
  PROCNAMEC()
  Protected d, n
  Protected sMsg.s
  
  If *rProd\bTemplate
    debugMsg(sProcName, "*rProd\bTemplate=" + strB(*rProd\bTemplate))
  EndIf
  
  For d = 0 To *rProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
    With *rProd\aAudioLogicalDevs(d)
      If \sLogicalDev
        debugMsg(sProcName, "*rProd\aAudioLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \nDevType=" + decodeDevType(\nDevType) + ", \nDevId=" + \nDevId +
                            ", \sDfltDBLevel=" + \sDfltDBLevel + ", \bForLTC=" + strB(\bForLTC) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nBassDevice=" + \nBassDevice + ", \nBassASIODevice=" + \nBassASIODevice)
      EndIf
    EndWith
  Next d
  
  For d = 0 To *rProd\nMaxVidAudLogicalDev ; grLicInfo\nMaxVidAudDevPerProd
    With *rProd\aVidAudLogicalDevs(d)
      If \sVidAudLogicalDev
        debugMsg(sProcName, "*rProd\aVidAudLogicalDevs(" + d + ")\sVidAudLogicalDev=" + \sVidAudLogicalDev + ", \nDevType=" + decodeDevType(\nDevType) + ", \nDevId=" + \nDevId)
      EndIf
    EndWith
  Next d
  
  For d = 0 To *rProd\nMaxVidCapLogicalDev ; grLicInfo\nMaxVidCapDevPerProd
    With *rProd\aVidCapLogicalDevs(d)
      If \sLogicalDev
        debugMsg(sProcName, "*rProd\aVidCapLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \nDevType=" + decodeDevType(\nDevType) + ", \nDevId=" + \nDevId)
      EndIf
    EndWith
  Next d
  
  For d = 0 To *rProd\nMaxFixType ; grLicInfo\nMaxFixTypePerProd
    If d <= *rProd\nMaxFixType
      With *rProd\aFixTypes(d)
        debugMsg(sProcName, "*rProd\aFixTypes(" + d + ")\sFixTypeName=" + \sFixTypeName + ", \nFixTypeId=" + \nFixTypeId + ", \sFixTypeDesc=" + \sFixTypeDesc + ", \nTotalChans=" + \nTotalChans)
      EndWith
      For n = 0 To *rProd\aFixTypes(d)\nTotalChans - 1
        With *rProd\aFixTypes(d)\aFixTypeChan(n)
          debugMsg(sProcName, "..  \nChanNo=" + \nChanNo + ", \sChannelDesc=" + \sChannelDesc + ", \bDimmerChan=" + strB(\bDimmerChan) + ", \sDefault=" + \sDefault + ", \nDMXDefault=" + \nDMXDefault)
        EndWith
      Next n
    EndIf
  Next d
  
  For d = 0 To *rProd\nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
    With *rProd\aLightingLogicalDevs(d)
      If \sLogicalDev
        debugMsg(sProcName, "*rProd\aLightingLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \nDevType=" + decodeDevType(\nDevType))
        For n = 0 To *rProd\aLightingLogicalDevs(d)\nMaxFixture
          debugMsg(sProcName, ".. \aFixture(" + n + ")\sFixtureCode=" + \aFixture(n)\sFixtureCode + ", \sFixtureDesc=" + \aFixture(n)\sFixtureDesc + ", \nDefaultDMXStartChannel=" + \aFixture(n)\nDefaultDMXStartChannel)
        Next n
      EndIf
    EndWith
  Next d
  
  ; debugMsg0(sProcName, "ArraySize(*rProd\aCtrlSendLogicalDevs())=" + ArraySize(*rProd\aCtrlSendLogicalDevs()))
  For d = 0 To *rProd\nMaxCtrlSendLogicalDev
    With *rProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        debugMsg(sProcName, "*rProd\aCtrlSendLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \nDevType=" + decodeDevType(\nDevType))
        Select \nDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            ; no further action
            
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            CompilerIf #c_csrd_network_available
              debugMsg(sProcName, "..  \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole) + ", \sCtrlNetworkRemoteDevCode=" + \sCtrlNetworkRemoteDevCode)
            CompilerElse
              debugMsg(sProcName, "..  \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
            CompilerEndIf
            
          Case #SCS_DEVTYPE_CS_RS232_OUT
            debugMsg(sProcName, "..  \nRS232BaudRate=" + \nRS232BaudRate + ", \nRS232DataBits=" + \nRS232DataBits + ", \fRS232StopBits=" + StrF(\fRS232StopBits,1) + ", \nRS232Parity=" + \nRS232Parity)
            
        EndSelect
      EndIf
    EndWith
  Next d
  
  For d = 0 To *rProd\nMaxCueCtrlLogicalDev ; grLicInfo\nMaxCueCtrlDev
    With *rProd\aCueCtrlLogicalDevs(d)
      If \nDevType <> #SCS_DEVTYPE_NONE
        debugMsg(sProcName, "*rProd\aCueCtrlLogicalDevs(" + d + ")\sCueCtrlLogicalDev=" + \sCueCtrlLogicalDev + ", \nDevType=" + decodeDevType(\nDevType) + ", \nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev))
        Select \nDevType
          Case #SCS_DEVTYPE_CC_DMX_IN
            ; no further action
            
          Case #SCS_DEVTYPE_CC_MIDI_IN
            debugMsg(sProcName, ".. \nCtrlMethod=" + decodeCtrlMethod(\nCtrlMethod) + ", \nMidiChannel=" + \nMidiChannel)
            For n = 0 To gnMaxMidiCommand
              If \aMidiCommand[n]\nCmd >= 0
                debugMsg(sProcName, ".. aMidiCommand[" + n + "]\nCmd=$" + Hex(\aMidiCommand[n]\nCmd) + ", \nCC=" + \aMidiCommand[n]\nCC + ", \nVV=" + \aMidiCommand[n]\nVV)
              EndIf
            Next n
            
          Case #SCS_DEVTYPE_CC_NETWORK_IN
            debugMsg(sProcName, "..  \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
            
          Case #SCS_DEVTYPE_CC_RS232_IN
            debugMsg(sProcName, "..  \nRS232BaudRate=" + \nRS232BaudRate + ", \nRS232DataBits=" + \nRS232DataBits + ", \fRS232StopBits=" + StrF(\fRS232StopBits,1) + ", \nRS232Parity=" + \nRS232Parity)
            
        EndSelect
      EndIf
    EndWith
  Next d
EndProcedure

Procedure debugCuePtrs(pCuePtr=-1)
  PROCNAMEC()
  Protected i, j, k, n, n2
  Protected sTypes.s, sFades.s
  Protected nFromCuePtr, nUptoCuePtr
  Protected nChaseStepIndex, nFixtureIndex, sFixtures.s, nMaxChaseStepIndex, nTotalChans, nChanIndex, sChanValues.s
  Protected sMsg.s
  
  If pCuePtr = -1
    nFromCuePtr = 1
    nUptoCuePtr = gnLastCue
  Else
    sProcName = buildCueProcName(#PB_Compiler_Procedure, pCuePtr)
    nFromCuePtr = pCuePtr
    nUptoCuePtr = pCuePtr
  EndIf
  
  For i = nFromCuePtr To nUptoCuePtr
    With aCue(i)
      sTypes = debugCueTypes(i)
      sMsg = "i=" + i + ", \sCue=" + \sCue + ", \nCueId=" + \nCueId + ", \nNodeKey=" + \nNodeKey + ", bSubType*=" + sTypes +
             ", \nFirstSubIndex=" + \nFirstSubIndex + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod)
      If \nActivationMethodReqd <> \nActivationMethod
        sMsg + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd)
      EndIf
      Select \nActivationMethod
        Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
          sMsg + ", \nAutoActCueSelType=" + decodeAutoActCueSelType(\nAutoActCueSelType) + ", \nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) + ", \nAutoActPosn=" + decodeAutoActPosn(\nAutoActPosn)
        Case #SCS_ACMETH_OCM
          sMsg + ", \nAutoActCueMarkerId=" + \nAutoActCueMarkerId
        Case #SCS_ACMETH_MTC
          sMsg + ", \sAutoActCueMarkerName=" + \sAutoActCueMarkerName
        Case #SCS_ACMETH_CALL_CUE
          If \sCallableCueParams
            sMsg + ", \sCallableCueParams=" + #DQUOTE$ + \sCallableCueParams + #DQUOTE$
          EndIf
      EndSelect
      sMsg + ", \nCueState=" + decodeCueState(\nCueState) + ", \bAutoStartLocked=" + strB(\bAutoStartLocked)
      debugMsg(sProcName, sMsg)
      j = \nFirstSubIndex
    EndWith
    While j >= 0
      With aSub(j)
        sTypes = debugSubTypes(j)
        sMsg = "..j=" + j + ", \sSubLabel=" + \sSubLabel + ", \nCueIndex=" + \nCueIndex + ", \nSubNo=" + \nSubNo + ", \nSubId=" + \nSubId +
               ", \nNodeKey=" + \nNodeKey + ", \bSubType=" + sTypes + ", \bExists=" + strB(\bExists) +
               ", \nPrevSubIndex=" + \nPrevSubIndex + ", \nNextSubIndex=" + \nNextSubIndex + ", \nSubRef=" + \nSubRef +
               ", \nSubState=" + decodeCueState(\nSubState)
        If \bSubPlaceHolder
          sMsg + ", \bSubPlaceHolder=" + strB(\bSubPlaceHolder)
        EndIf
        If \nFirstAudIndex >= 0
          sMsg + ", \nFirstAudIndex=" + \nFirstAudIndex
        EndIf
        If \nSubStart <> #SCS_SUBSTART_REL_TIME
          sMsg + ", \nSubStart=" + decodeSubStart(\nSubStart)
        EndIf
        Select \nSubStart
          Case #SCS_SUBSTART_REL_TIME
          Case #SCS_SUBSTART_REL_MTC
            sMsg + ", \nRelMTCStartTimeForSub=" + decodeMTCTime(\nRelMTCStartTimeForSub)
          Case #SCS_SUBSTART_OCM
            sMsg + ", \sSubCueMarkerName=" + \sSubCueMarkerName
        EndSelect
        debugMsg(sProcName, sMsg)
        
        If \bSubTypeA
          debugMsg(sProcName, ".. \sVidAudLogicalDev=" + \sVidAudLogicalDev + ", \sScreens=" + \sScreens)
          If \nPLCurrFadeInTime <> grSubDef\nPLCurrFadeInTime Or \nPLCurrFadeOutTime <> grSubDef\nPLCurrFadeOutTime
            debugMsg(sProcName, ".. \nPLCurrFadeInTime=" + \nPLCurrFadeInTime + ", \nPLCurrFadeOutTime=" + \nPLCurrFadeOutTime)
          EndIf
        EndIf
        
        If \bSubTypeJ
          For n = 0 To #SCS_MAX_ENABLE_DISABLE
            If \aEnableDisable[n]\sFirstCue
              debugMsg(sProcName, ".. \aEnableDisable[" + n + "]\sFirstCue=" + \aEnableDisable[n]\sFirstCue + ", \sLastCue=" + \aEnableDisable[n]\sLastCue + ", \nAction=" + decodeEnaDisAction(\aEnableDisable[n]\nAction))
            EndIf
          Next n
        EndIf
        
        If \bSubTypeK
          debugMsg(sProcName, ".. \sLTLogicalDev=" + \sLTLogicalDev + ", \nLTDevType=" + decodeDevType(\nLTDevType) + ", \nLTEntryType=" + decodeLTEntryType(\nLTEntryType) + ", \bChase=" + strB(\bChase) + ", \nChaseSteps=" + \nChaseSteps +
                              ", \sDMXSendString=" + \sDMXSendString + ", \sLTDisplayInfo=" + \sLTDisplayInfo)
          sFades = ""
          Select \nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              sFades = "Fade Up: " + decodeDMXFadeActionFI(\nLTFIFadeUpAction)
              If \nLTFIFadeUpUserTime >= 0 Or \sLTFIFadeUpUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTFIFadeUpUserTime, \nLTFIFadeUpAction) + ")" : EndIf
              sFades + ", Fade Down: " + decodeDMXFadeActionFI(\nLTFIFadeDownAction)
              If \nLTFIFadeDownUserTime >= 0 Or \sLTFIFadeDownUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime) + ")" : EndIf
              sFades + ", Fade Others: " + decodeDMXFadeActionFI(\nLTFIFadeOutOthersAction)
              If \nLTFIFadeOutOthersUserTime >= 0 Or \sLTFIFadeOutOthersUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime) + ")" : EndIf
              debugMsg(sProcName, "..  " + sFades)
              sFixtures = ""
              For nFixtureIndex = 0 To \nMaxFixture
                sFixtures + ", " + \aLTFixture(nFixtureIndex)\sLTFixtureCode
              Next nFixtureIndex
              If sFixtures
                debugMsg(sProcName, "..  sFixtures=" + Mid(sFixtures,3))
              EndIf
              If \bChase
                nMaxChaseStepIndex = \nMaxChaseStepIndex
              Else
                nMaxChaseStepIndex = 0
              EndIf
              For nChaseStepIndex = 0 To nMaxChaseStepIndex
                For nFixtureIndex = 0 To \nMaxFixture
                  If \aLTFixture(nFixtureIndex)\sLTFixtureCode
                    nTotalChans = getTotalChansForFixture(@grProd, @aSub(j), \aLTFixture(nFixtureIndex)\sLTFixtureCode)
                    If nTotalChans > 0
                      sChanValues = ""
                      For nChanIndex = 0 To nTotalChans-1
                        sChanValues + ", " + \aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\sDMXDisplayValue +
                                      "[d" + \aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nDMXAbsValue + "]"
                      Next nChanIndex
                      If sChanValues
                        debugMsg(sProcName, ".... \aChaseStep(" + nChaseStepIndex + ")\aFixtureItem(" + nFixtureIndex + ")\sChanValues=" + Mid(sChanValues,3))
                      EndIf
                    EndIf
                  EndIf
                Next nFixtureIndex
              Next nChaseStepIndex
              
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
              sFades = "Fade Up: " + decodeDMXFadeActionDI(\nLTDIFadeUpAction)
              If \nLTDIFadeUpUserTime >= 0 Or \sLTDIFadeUpUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime) + ")" : EndIf
              sFades + ", Fade Down: " + decodeDMXFadeActionDI(\nLTDIFadeDownAction)
              If \nLTDIFadeDownUserTime >= 0 Or \sLTDIFadeDownUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime) + ")" : EndIf
              sFades + ", Fade Others: " + decodeDMXFadeActionDI(\nLTDIFadeOutOthersAction)
              If \nLTDIFadeOutOthersUserTime >= 0 Or \sLTDIFadeOutOthersUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime) + ")" : EndIf
              debugMsg(sProcName, "..  " + sFades)
              
            Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
              sFades = "Fade Up: " + decodeDMXFadeActionDC(\nLTDCFadeUpAction)
              If \nLTDCFadeUpUserTime >= 0 Or \sLTDCFadeUpUserTime : sFades + "(" + makeDisplayTimeValueD(\sLTDCFadeUpUserTime, \nLTDCFadeUpUserTime) + ")" : EndIf
              sFades + " Fade Down: " + decodeDMXFadeActionDC(\nLTDCFadeDownAction)
              If \nLTDCFadeDownUserTime >= 0 Or \sLTDCFadeDownUserTime: sFades + "(" + makeDisplayTimeValueD(\sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime) + ")" : EndIf
              debugMsg(sProcName, "..  " + sFades)
              
          EndSelect
        EndIf
        
        If \bSubTypeL
          sMsg = ".. \nLCCuePtr=" + \nLCCuePtr + ", \nLCSubPtr=" + \nLCSubPtr + ", \nLCAudPtr=" + \nLCAudPtr + ", \nLCSubNo=" + \nLCSubNo + ", \nLCSubRef=" + \nLCSubRef
          sMsg + ", \nLCAction=" + \nLCAction + " " + decodeLCAction(\nLCAction)
          debugMsg(sProcName, sMsg)
        EndIf
        
        If \bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            ; debugMsg(sProcName, ".. \aCtrlSend[" + n + "]\bIsOSC=" + strB(\aCtrlSend[n]\bIsOSC) + ", \nMSMsgType=" + decodeMsgType(\aCtrlSend[n]\nMSMsgType) + ", nRemDevMsgType=" + CSRD_DecodeRemDevMsgType(\aCtrlSend[n]\nRemDevMsgType))
            If \aCtrlSend[n]\bIsOSC
              debugMsg(sProcName, ".. \aCtrlSend[" + n + "]\bIsOSC=" + strB(\aCtrlSend[n]\bIsOSC) + ", \nMSMsgType=" + \aCtrlSend[n]\nMSMsgType + ", \nOSCCmdType=" + decodeOSCCmdType(\aCtrlSend[n]\nOSCCmdType) +
                                  ", \nOSCItemNr=" + \aCtrlSend[n]\nOSCItemNr + ", \sOSCItemString=" + \aCtrlSend[n]\sOSCItemString)
            ElseIf \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_SCRIBBLE_STRIP
              debugMsg(sProcName, ".. \aCtrlSend[" + n + "]\nMSMsgType=" + decodeMsgType(\aCtrlSend[n]\nMSMsgType) + ", \nDevType=" + decodeDevType(\aCtrlSend[n]\nDevType) + ", \sCSLogicalDev=" + \aCtrlSend[n]\sCSLogicalDev +
                                  ", \nMaxScribbleStripItem=" + \aCtrlSend[n]\nMaxScribbleStripItem)
              For n2 = 0 To \aCtrlSend[n]\nMaxScribbleStripItem
                debugMsg(sProcName, ".... \aScribbleStripItem(" + n2 + ")\sSSValType=" + \aCtrlSend[n]\aScribbleStripItem(n2)\sSSValType +
                                    ", \nSSDataValue=" + \aCtrlSend[n]\aScribbleStripItem(n2)\nSSDataValue + ", \sSSItemName=" + \aCtrlSend[n]\aScribbleStripItem(n2)\sSSItemName)
              Next n2
            ElseIf \aCtrlSend[n]\nMSMsgType <> #SCS_MSGTYPE_NONE
              debugMsg(sProcName,
                       ".. \aCtrlSend[" + n + "]\nMSMsgType=" + decodeMsgType(\aCtrlSend[n]\nMSMsgType) + ", \nDevType=" + decodeDevType(\aCtrlSend[n]\nDevType) + ", \nRemDevId=" + \aCtrlSend[n]\nRemDevId +
                       ", \sEnteredString=" + \aCtrlSend[n]\sEnteredString + ", \sCSLogicalDev=" + \aCtrlSend[n]\sCSLogicalDev)
              debugMsg(sProcName,
                       ".. \nMSParam1=" + \aCtrlSend[n]\nMSParam1 + ", \sMSParam1=" + \aCtrlSend[n]\sMSParam1 + ", \nMSParam2=" + \aCtrlSend[n]\nMSParam2 + ", \sMSParam2=" + \aCtrlSend[n]\sMSParam2 +
                       ", \nMSParam3=" + \aCtrlSend[n]\nMSParam3 + ", \sMSParam3=" + \aCtrlSend[n]\sMSParam3 + ", \nMSParam4=" + \aCtrlSend[n]\nMSParam4 + ", \sMSParam4=" + \aCtrlSend[n]\sMSParam4)
            EndIf
            If \aCtrlSend[n]\nRemDevMsgType <> 0
              sMsg = ".. \aCtrlSend[" + n + "]\nRemDevMsgType=" + CSRD_DecodeRemDevMsgType(\aCtrlSend[n]\nRemDevMsgType) + ", \nRemDevId=" + \aCtrlSend[n]\nRemDevId +
                     ", \nRemDevMuteAction=" + \aCtrlSend[n]\nRemDevMuteAction + ", \sRemDevValue=" + \aCtrlSend[n]\sRemDevValue
              If \aCtrlSend[n]\sRemDevValue2
                sMsg + ", \sRemDevValue2=" + \aCtrlSend[n]\sRemDevValue2
              EndIf
              debugMsg(sProcName, sMsg)
            EndIf
            If \aCtrlSend[n]\sDisplayInfo
              debugMsg(sProcName,
                       ".. \aCtrlSend[" + n + "]\sDisplayInfo=" + \aCtrlSend[n]\sDisplayInfo)
            EndIf
          Next n
        EndIf
        
        If \bSubTypeP
          debugMsg(sProcName, ".. \sPLLogicalDev[0]=" + \sPLLogicalDev[0] + ", \bPLRepeat=" + strB(\bPLRepeat) + ", \bPLRandom=" + strB(\bPLRandom) + ", \bPLSavePos=" + strB(\bPLSavePos))
          debugMsg(sProcName, ".. \nFirstPlayIndex=" + getAudLabel(\nFirstPlayIndex) + ", \nFirstPlayIndexThisRun=" + getAudLabel(\nFirstPlayIndexThisRun) + ", \nLastPlayIndex=" + getAudLabel(\nLastPlayIndex) +
                              ", \nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex) + ", \nPLFadeInTime=" + \nPLFadeInTime + ", \nPLFadeOutTime=" + \nPLFadeOutTime)
          If \nPLCurrFadeInTime <> grSubDef\nPLCurrFadeInTime Or \nPLCurrFadeOutTime <> grSubDef\nPLCurrFadeOutTime
            debugMsg(sProcName, ".. \nPLCurrFadeInTime=" + \nPLCurrFadeInTime + ", \nPLCurrFadeOutTime=" + \nPLCurrFadeOutTime)
          EndIf
        EndIf
        
        If \bSubTypeQ
          If \nCallCueAction = #SCS_QQ_CALLCUE
            debugMsg(sProcName, ".. \nCallCueAction=" + decodeCallCueAction(\nCallCueAction) + ", \sCallCue=" + \sCallCue + ", \sCallCueParams=" + #DQUOTE$ + \sCallCueParams + #DQUOTE$)
          ElseIf \nCallCueAction = #SCS_QQ_SELHKBANK
            debugMsg(sProcName, ".. \nCallCueAction=" + decodeCallCueAction(\nCallCueAction) + ", \nSelHKBank=" + \nSelHKBank)
          EndIf
        EndIf
        
        If \bSubTypeR
          debugMsg(sProcName, ".. \sRPFileName=" + \sRPFileName + ", \sRPParams=" + \sRPParams)
          debugMsg(sProcName, ".. \bRPHideSCS=" + strB(\bRPHideSCS) + ", \bRPInvisible=" + strB(\bRPInvisible))
        EndIf
        
        If \bSubTypeS
          debugMsg(sProcName,
                   ".. \nSFRAction[0]=" + decodeSFRAction(\nSFRAction[0]) + ", \nSFRCueType[0]=" + decodeSFRCueType(\nSFRCueType[0]) +
                   ", \sSFRCue[0]=" + \sSFRCue[0] + ", \nSFRCuePtr[0]=" + \nSFRCuePtr[0] +
                   ", \nSFRSubNo[0]=" + \nSFRSubNo[0] + ", \nSFRSubPtr[0]=" + \nSFRSubPtr[0] + ", \nSFRLoopNo[0]=" + \nSFRLoopNo[0])
        EndIf
        
        If \bSubTypeHasAuds
          k = \nFirstAudIndex
          While k >= 0
            debugMsg(sProcName,
                     "....k=" + k + ", \sAudLabel=" + aAud(k)\sAudLabel + ", \nCueIndex=" + aAud(k)\nCueIndex + ", \nSubIndex=" + aAud(k)\nSubIndex + ", \nSubNo=" + aAud(k)\nSubNo +
                     ", \nAudNo=" + aAud(k)\nAudNo + ", \nAudId=" + aAud(k)\nAudId + ", \nLinkedToAudPtr=" + aAud(k)\nLinkedToAudPtr +
                     ", \bExists=" + strB(aAud(k)\bExists) + ", \nNextAudIndex=" + aAud(k)\nNextAudIndex +
                     ", \nFileDataPtr=" + aAud(k)\nFileDataPtr + ", \nFileStatsPtr=" + aAud(k)\nFileStatsPtr + ", \nAudState=" + decodeCueState(aAud(k)\nAudState))
            If \bSubTypeP
              debugMsg(sProcName, "......\nPrevPlayIndex=" + getAudLabel(aAud(k)\nPrevPlayIndex) + ", \nNextPlayIndex=" + getAudLabel(aAud(k)\nNextPlayIndex))
            EndIf
            If (\bSubTypeA) And (aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE)
              debugMsg(sProcName, "......\nVideoSource=" + decodeVideoSource(aAud(k)\nVideoSource) + ", \sVideoCaptureLogicalDevice=" + aAud(k)\sVideoCaptureLogicalDevice +
                                  ", \nEndAt=" + aAud(k)\nEndAt +
                                  ", \bContinuous=" + strB(aAud(k)\bContinuous))
            Else
              debugMsg(sProcName, "......\sStoredFileName=" + aAud(k)\sStoredFileName + ", \nFileFormat=" + decodeFileFormat(aAud(k)\nFileFormat))
              debugMsg(sProcName, "......\nFadeInTime=" + aAud(k)\nFadeInTime + ", \nFadeOutTime=" + aAud(k)\nFadeOutTime +
                                  ", \nFadeInType=" + decodeFadeType(aAud(k)\nFadeInType) + ", \nFadeOutType=" + decodeFadeType(aAud(k)\nFadeOutType) +
                                  ", \nStartAt=" + aAud(k)\nStartAt + ", \nEndAt=" + aAud(k)\nEndAt + ", \nCueDuration=" + aAud(k)\nCueDuration +
                                  ", \nLvlPtLvlSel=" + decodeLvlPtLvlSel(aAud(k)\nLvlPtLvlSel) + ", \nLvlPtPanSel=" + decodeLvlPtPanSel(aAud(k)\nLvlPtPanSel) +
                                  ", \fBVLevel[0]=" + traceLevel(aAud(k)\fBVLevel[0]) + ", \fSavedBVLevel[0]=" + traceLevel(aAud(k)\fSavedBVLevel[0]))
              If aAud(k)\nCurrFadeInTime <> grAudDef\nCurrFadeInTime Or aAud(k)\nCurrFadeOutTime <> grAudDef\nCurrFadeOutTime
                debugMsg(sProcName, "......\nCurrFadeInTime=" + aAud(k)\nCurrFadeInTime + ", \nCurrFadeOutTime=" + aAud(k)\nCurrFadeOutTime)
              EndIf
            EndIf
            If \bSubTypeA
              debugMsg(sProcName,  "......\fCueVolNow[0]=" + traceLevel(aAud(k)\fCueVolNow[0]))
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  debugMsg(sProcName, "--- CUE LINKS ---")
  For i = nFromCuePtr To nUptoCuePtr
    With aCue(i)
      If \nCueLinkCount > 0
        debugMsg(sProcName, "i=" + i + ", Q=" + \sCue + ", \nCueLinkCount=" + \nCueLinkCount + ", \nFirstCueLink=" + \nFirstCueLink + ", \nLinkedToCuePtr=" + \nLinkedToCuePtr)
      EndIf
    EndWith
  Next i
  
  debugMsg(sProcName, "--- SUB LINKS ---")
  For i = nFromCuePtr To nUptoCuePtr
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bSubTypeU And \nMTCLinkedToAFSubPtr >= 0
          debugMsg(sProcName, "j=" + j + ", \sSubLabel=" + \sSubLabel + ", \bSubTypeU, \nMTCLinkedToAFSubPtr=" + getSubLabel(\nMTCLinkedToAFSubPtr))
        ElseIf \bSubTypeF And \nAFLinkedToMTCSubPtr >= 0
          debugMsg(sProcName, "j=" + j + ", \sSubLabel=" + \sSubLabel + ", \bSubTypeF, \nAFLinkedToMTCSubPtr=" +  getSubLabel(\nAFLinkedToMTCSubPtr))
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  debugMsg(sProcName, "--- AUD LINKS ---")
  For i = nFromCuePtr To nUptoCuePtr
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          With aAud(k)
            If \nAudLinkCount > 0
              debugMsg(sProcName, "k=" + k + ", \sAudLabel=" + \sAudLabel + ", \nAudLinkCount=" + \nAudLinkCount + ", \nFirstAudLink=" + \nFirstAudLink + ", \nLinkedToAudPtr=" + \nLinkedToAudPtr)
            EndIf
            k = \nNextAudIndex
          EndWith
        Wend
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  debugMsg(sProcName, "ArraySize(aCue())=" + ArraySize(aCue()) + ", ArraySize(aSub())=" + ArraySize(aSub()) + ", ArraySize(aAud())=" + ArraySize(aAud()))
EndProcedure

Procedure debugCuePtrs2()
  PROCNAMEC()
  Protected i, j, k, n
  Protected sTypes.s
  
  For i = 1 To gn2ndLastCue
    With a2ndCue(i)
      sTypes = debugCueTypes2(i)
      debugMsg(sProcName, "i=" + i + ", Q=" + \sCue + ", bSubType*=" + sTypes + ", \nFirstSubIndex=" + \nFirstSubIndex + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod))
      j = \nFirstSubIndex
    EndWith
    While j >= 0
      With a2ndSub(j)
        sTypes = debugSubTypes2(j)
        debugMsg(sProcName, "..j=" + j + ", \nCueIndex=" + \nCueIndex + ", \nSubNo=" + \nSubNo + ", \sSubLabel=" + \sSubLabel + ", \bSubType*=" + sTypes +
                            ", \bExists=" + strB(\bExists) + ", \nPrevSubIndex=" + \nPrevSubIndex + ", \nNextSubIndex=" + \nNextSubIndex + ", \nSubRef=" + \nSubRef +
                            ", \nFirstAudIndex=" + \nFirstAudIndex + ", \nAudCount=" + \nAudCount + ", \nFirstPlayIndex=" + \nFirstPlayIndex)
        If \bSubTypeHasAuds
          k = \nFirstAudIndex
          While k >= 0
            debugMsg(sProcName, "....k=" + k + ", \nCueIndex=" + a2ndAud(k)\nCueIndex + ", \nSubIndex=" + a2ndAud(k)\nSubIndex + ", \nAudNo=" + a2ndAud(k)\nAudNo +
                                ", \nLinkedToAudPtr=" + a2ndAud(k)\nLinkedToAudPtr + ", .sAudLabel=" + a2ndAud(k)\sAudLabel +
                                ", \bExists=" + strB(a2ndAud(k)\bExists) + ", \nNextAudIndex=" + a2ndAud(k)\nNextAudIndex + ", \nFileDataPtr=" + a2ndAud(k)\nFileDataPtr)
            k = a2ndAud(k)\nNextAudIndex
          Wend
        EndIf
        If \bSubTypeL
          debugMsg(sProcName, ".. \nLCCuePtr=" + \nLCCuePtr + ", \nLCSubPtr=" + \nLCSubPtr + ", \nLCAudPtr=" + \nLCAudPtr)
          debugMsg(sProcName, ".. \nLCSubNo=" + \nLCSubNo + ", \nLCSubRef=" + \nLCSubRef)
        EndIf
        If \bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            If Len(a2ndSub(j)\aCtrlSend[n]\sDisplayInfo) <> 0
              debugMsg(sProcName, ".. .aCtrlSend[" + n + "].sDisplayInfo=" + a2ndSub(j)\aCtrlSend[n]\sDisplayInfo)
            EndIf
          Next n
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  debugMsg(sProcName, "--- CUE LINKS ---")
  For i = 1 To gn2ndLastCue
    With a2ndCue(i)
      If \nCueLinkCount > 0
        debugMsg(sProcName, "i=" + i + ", Q=" + \sCue + ", \nCueLinkCount=" + \nCueLinkCount + ", \nFirstCueLink=" + \nFirstCueLink + ", \nLinkedToCuePtr=" + \nLinkedToCuePtr)
      EndIf
    EndWith
  Next i
  
  debugMsg(sProcName, "--- AUD LINKS ---")
  For k = 1 To gn2ndLastAud
    With a2ndAud(k)
      If (\bExists) And (\nAudLinkCount > 0)
        debugMsg(sProcName, "k=" + k + ", A=" + \sAudLabel + ", \nAudLinkCount=" + \nAudLinkCount + ", \nFirstAudLink=" + \nFirstAudLink + ", \nLinkedToAudPtr=" + \nLinkedToAudPtr)
      EndIf
    EndWith
  Next k
  
  debugMsg(sProcName, "ArraySize(a2ndCue())=" + ArraySize(a2ndCue()) + ", ArraySize(a2ndSub())=" + ArraySize(a2ndSub()) + ", ArraySize(a2ndAud())=" + ArraySize(a2ndAud()))
  
EndProcedure

Procedure displayDemoCount()
  PROCNAMEC()
  Protected sMsg.s, nBackColor
  Protected nWidth
  
  With WMN
    If gbDemoMode
      debugMsg(sProcName, "gnDemoTimeCount=" + gnDemoTimeCount)
      If gnDemoTimeCount < 1
        sMsg = Lang("WMN","DemoTimeExpired")    ; Demo session time limit expired
        nBackColor = #SCS_Red
      ElseIf gnDemoTimeCount = 1
        sMsg = Lang("WMN","DemoTimeOneMinute")  ; Demo time remaining: 1 minute
        nBackColor = #SCS_Red
      Else
        sMsg = LangPars("WMN","DemoTimeRemaining", Str(gnDemoTimeCount))  ; Demo time remaining: $1 minutes
        nBackColor = $80FF
      EndIf
      nWidth = GadgetX(\lblDemo) - GadgetX(\cntGoInfo)
      If GadgetWidth(\cntGoInfo) <> nWidth
        ResizeGadget(\cntGoInfo,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
      EndIf
      debugMsg(sProcName, "sMsg=" + sMsg)
      SetGadgetText(\lblDemo, sMsg)
      SetGadgetColor(\lblDemo, #PB_Gadget_BackColor, nBackColor)
      setVisible(\lblDemo, #True)
    Else
      setVisible(\lblDemo, #False)
    EndIf
  EndWith
  
EndProcedure

Procedure setAudDescrsForAorP(pSubPtr, bPrimaryFile=#True)
  PROCNAMECS(pSubPtr, bPrimaryFile)
  Protected k, nPlayNo, nTrackCount
  
  If pSubPtr >= 0
    If bPrimaryFile
      With aSub(pSubPtr)
        If \bSubTypeAorP
          k = \nFirstPlayIndex
          ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\sSubDescr=" + aSub(pSubPtr)\sSubDescr)
          While k >= 0
            If \nAudCount = 1
              If (aAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
                aAud(k)\sAudDescr = aAud(k)\sFileTitle
              Else
                aAud(k)\sAudDescr = ignoreExtension(GetFilePart(aAud(k)\sFileName))
              EndIf
            Else
              aAud(k)\sAudDescr = aSub(pSubPtr)\sSubDescr
              If aSub(pSubPtr)\nAudCount > 1
                aAud(k)\sAudDescr + " " + aAud(k)\nPlayNo + "/" + aSub(pSubPtr)\nAudCount
              EndIf
              Select aAud(k)\nVideoSource
                Case #SCS_VID_SRC_FILE
                  If aAud(k)\sFileTitle
                    aAud(k)\sAudDescr + ": " + Trim(aAud(k)\sFileTitle)
                  Else
                    aAud(k)\sAudDescr + ": " + ignoreExtension(GetFilePart(aAud(k)\sFileName))
                  EndIf
                Case #SCS_VID_SRC_CAPTURE
                  aAud(k)\sAudDescr + ": " + aAud(k)\sVideoCaptureLogicalDevice
              EndSelect
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPrevAudIndex=" + aAud(k)\nPrevAudIndex + ", \nNextAudIndex=" + aAud(k)\nNextAudIndex + ", \sAudDescr=" + aAud(k)\sAudDescr)
            k = aAud(k)\nNextPlayIndex
          Wend
          
        ElseIf \bSubTypeF
          k = \nFirstAudIndex
          If k >= 0
            If (aAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
              aAud(k)\sAudDescr = aAud(k)\sFileTitle
            Else
              aAud(k)\sAudDescr = ignoreExtension(GetFilePart(aAud(k)\sFileName))
            EndIf
          EndIf
          
        EndIf
      EndWith
    Else
      With a2ndSub(pSubPtr)
        If \bSubTypeAorP
          k = \nFirstPlayIndex
          While k >= 0
            If \nAudCount = 1
              If (a2ndAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
                a2ndAud(k)\sAudDescr = a2ndAud(k)\sFileTitle
              Else
                a2ndAud(k)\sAudDescr = ignoreExtension(GetFilePart(a2ndAud(k)\sFileName))
              EndIf
            Else
              a2ndAud(k)\sAudDescr = a2ndSub(pSubPtr)\sSubDescr
              If a2ndSub(pSubPtr)\nAudCount > 1
                a2ndAud(k)\sAudDescr + " " + a2ndAud(k)\nPlayNo + "/" + a2ndSub(pSubPtr)\nAudCount
              EndIf
              Select a2ndAud(k)\nVideoSource
                Case #SCS_VID_SRC_FILE
                  If a2ndAud(k)\sFileTitle
                    a2ndAud(k)\sAudDescr + ": " + Trim(a2ndAud(k)\sFileTitle)
                  Else
                    a2ndAud(k)\sAudDescr + ": " + ignoreExtension(GetFilePart(a2ndAud(k)\sFileName))
                  EndIf
                Case #SCS_VID_SRC_CAPTURE
                  a2ndAud(k)\sAudDescr + ": " + a2ndAud(k)\sVideoCaptureLogicalDevice
              EndSelect
            EndIf
            debugMsg(sProcName, "a2ndAud(" + getAudLabel2(k) + ")\nPrevAudIndex=" + a2ndAud(k)\nPrevAudIndex + ", \nNextAudIndex=" + a2ndAud(k)\nNextAudIndex + ", \sAudDescr=" + a2ndAud(k)\sAudDescr)
            k = a2ndAud(k)\nNextPlayIndex
          Wend
          
        ElseIf \bSubTypeF
          k = \nFirstAudIndex
          If k >= 0
            If (a2ndAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
              a2ndAud(k)\sAudDescr = a2ndAud(k)\sFileTitle
            Else
              a2ndAud(k)\sAudDescr = ignoreExtension(GetFilePart(a2ndAud(k)\sFileName))
            EndIf
          EndIf
          
        EndIf
      EndWith
    EndIf
  EndIf
EndProcedure

Procedure setPlayIndexesFromPlayOrder(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sPlayOrder.s, n, nAudCount, sField.s, nAudNo, k, nPlayNo
  Protected nPrevPlayIndex
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\sPlayOrder=" + #DQUOTE$ + \sPlayOrder + #DQUOTE$)
      \nFirstPlayIndex = -1
      \nLastPlayIndex = -1
      sPlayOrder = \sPlayOrder
      nAudCount = CountString(sPlayOrder, ",") + 1
      nPrevPlayIndex = -1
      For n = 1 To nAudCount
        sField = Trim(StringField(sPlayOrder, n, ","))
        nAudNo = Val(sField)
        ; debugMsg(sProcName, "n=" + n + ", nAudNo=" + nAudNo + ", nAudCount=" + nAudCount)
        k = \nFirstAudIndex
        While k >= 0
          If aAud(k)\nAudNo = nAudNo
            If nPrevPlayIndex >= 0
              aAud(nPrevPlayIndex)\nNextPlayIndex = k
              ; debugMsg(sProcName, "aAud(" + getAudLabel(nPrevPlayIndex) + ")\nNextPlayIndex=" + getAudLabel(aAud(nPrevPlayIndex)\nNextPlayIndex))
            Else ; nPrevPlayIndex = -1
              \nFirstPlayIndex = k
              ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nFirstPlayIndex=" + getAudLabel(\nFirstPlayIndex))
            EndIf
            aAud(k)\nPrevPlayIndex = nPrevPlayIndex
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPrevPlayIndex=" + getAudLabel(aAud(k)\nPrevPlayIndex))
            nPlayNo + 1
            aAud(k)\nPlayNo = nPlayNo
            aAud(k)\sAudDescr = \sSubDescr
            If \nAudCount > 1
              aAud(k)\sAudDescr + " " + aAud(k)\nPlayNo + "/" + \nAudCount
            EndIf
            nPrevPlayIndex = k
            Break
          EndIf
          k = aAud(k)\nNextAudIndex
        Wend
      Next n
      If nPrevPlayIndex >= 0
        aAud(nPrevPlayIndex)\nNextPlayIndex = -1
        \nLastPlayIndex = nPrevPlayIndex
        ; debugMsg(sProcName, "aAud(" + getAudLabel(nPrevPlayIndex) + ")\nNextPlayIndex=" + getAudLabel(aAud(nPrevPlayIndex)\nNextPlayIndex))
      EndIf
      aCue(\nCueIndex)\bCallLoadGridRow = #True
      gbCallLoadGridRowsWhereRequested = #True
      
      CompilerIf 1=1
        k = \nFirstPlayIndex
        While k >= 0
          sMsg + Str(aAud(k)\nAudNo) + ", "
          k = aAud(k)\nNextPlayIndex
        Wend
        debugMsg(sProcName, "sMsg=" + sMsg)
      CompilerEndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processSamSetPlayOrder(sCue.s, nSubNo, sPlayOrder.s, nFirstPlayAudNoThisRun)
  PROCNAMEC()
  Protected nCuePtr, nSubPtr=-1, nFirstPlayAudPtrThisRun=-1, j, k
  
  ; locally derived pointers
  nCuePtr = getCuePtr(sCue)
  debugMsg(sProcName, "nCuePtr=" + nCuePtr)
  If nCuePtr >= 0
    ; should be #True
    j = aCue(nCuePtr)\nFirstSubIndex
    debugMsg(sProcName, "aCue(" + nCuePtr + ")\nFirstSubIndex=" + aCue(nCuePtr)\nFirstSubIndex)
    While j >= 0
      debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubNo=" + aSub(j)\nSubNo)
      If aSub(j)\nSubNo = nSubNo
        nSubPtr = j
        Break
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    debugMsg(sProcName, "nSubPtr=" + nSubPtr)
    If nSubPtr >= 0
      ; should be #True
      With aSub(nSubPtr)
        debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\bSubTypeP=" + strB(\bSubTypeP))
        If \bSubTypeP
          ; should be #True
          \sPlayOrder = sPlayOrder
          setPlayIndexesFromPlayOrder(nSubPtr)
          \bPLPlayOrderSyncedWithPrimary = #True
          k = \nFirstAudIndex
          While k >= 0
            If aAud(k)\nAudNo = nFirstPlayAudNoThisRun
              nFirstPlayAudPtrThisRun = k
              Break
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
          If nFirstPlayAudPtrThisRun >= 0
            \nFirstPlayIndexThisRun = nFirstPlayAudPtrThisRun
          EndIf
          debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\sPlayOrder=" + #DQUOTE$ + \sPlayOrder + #DQUOTE$ + ", \nFirstPlayIndexThisRun=" + getAudLabel(\nFirstPlayIndexThisRun) + ", \bPLPlayOrderSyncedWithPrimary=" + strB(\bPLPlayOrderSyncedWithPrimary))
          \nCurrPlayIndex = \nFirstPlayIndex
          debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex))
          debugMsg(sProcName, "calling ONC_openNextCues(" + getCueLabel(\nCueIndex) + ", " + getCueLabel(\nCueIndex) + ")")
          ONC_openNextCues(\nCueIndex, \nCueIndex)
          gbForceReloadAllDispPanels = #True
          debugMsg(sProcName, "calling PNL_loadDispPanels()")
          PNL_loadDispPanels()
        EndWith
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure generatePlayOrder(pSubPtr, bPrimaryFile=#True, bRetainPlayOrderIfPossible=#False, bUseInitialSettingsIfRelevant=#False)
  PROCNAMECS(pSubPtr, bPrimaryFile)
  Protected n, k, nPlayNo, nTrackCount, nOrigTrackCount
  Protected nCounter, nNextTrack, nThisTrack, nRandomMax, nRandomNo
  Protected bRandom, bPLRepeat, bCheckMinGap, nMinRepeatGap
  Protected nPrevAudIndex, bFound
  Protected sPlayOrder.s, nTester
  Protected bEditing
  Protected bContinuous
  Protected Dim aPlayAud.tyPlayAud(0)
  Protected Dim aCurrPlayAudPtrs(0), Dim aCurrPlayAudSeq(0)
  Protected bRetainPlayOrder, bUsePosFromDatabase
  Protected sListOrderWork.s, sPlayNoWork.s, nWorkIndex, sListOrderToSave.s
  Protected nThisPlayIndex, nPrevPlayIndex, nNextPlayIndex
  Protected sTmp.s, sQualifier.s
  
  ; debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile) + ", bRetainPlayOrderIfPossible=" + strB(bRetainPlayOrderIfPossible) + ", bUseInitialSettingsIfRelevant=" + strB(bUseInitialSettingsIfRelevant))
  
  If pSubPtr < 0
    ; shouldn't happen
    ProcedureReturn
  EndIf
  
  If pSubPtr = nEditSubPtr
    bEditing = #True
  EndIf
  
  If bPrimaryFile
    With aSub(pSubPtr)
      ; Added 4Jul2023 11.10.0bn
      If \bSubTypeP
        k = \nFirstAudIndex
        While k >= 0
          aAud(k)\nPLRunTimeTransType = aAud(k)\nPLTransType
          aAud(k)\nPLRunTimeTransTime = aAud(k)\nPLTransTime
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      ; End added 4Jul2023 11.10.0bn
      
      ; added 20Nov2019 11.8.2rc5
      ; debugMsg(sProcName, "grLicInfo\bFMAvailable=" + strB(grLicInfo\bFMAvailable) + ", grFMOptions\nFunctionalMode=" + decodeFunctionalMode(grFMOptions\nFunctionalMode) +
      ;                     ", aSub(" + getSubLabel(pSubPtr) + ")\bPLPlayOrderSyncedWithPrimary=" + strB(\bPLPlayOrderSyncedWithPrimary))
      If grLicInfo\bFMAvailable
        If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
          If \bPLPlayOrderSyncedWithPrimary
            ; if in backup mode then the primary should have sent the primary's play order to the backup and we need to use that play order, not generate a separate play order, so exit now
            debugMsg(sProcName, "exiting because \bPLPlayOrderSyncedWithPrimary=" + strB(\bPLPlayOrderSyncedWithPrimary))
            ProcedureReturn
          EndIf
        EndIf
      EndIf
      ; end added 20Nov2019 11.8.2rc5
      
      nTrackCount = 0
      If \bSubTypeF
        nTrackCount = 1
        bRandom = #False
        bPLRepeat = #False
      ElseIf \bSubTypeAorP
        nTrackCount = \nAudCount
        bRandom = \bPLRandom
        bPLRepeat = \bPLRepeat
        debugMsg(sProcName, "nTrackCount=" + nTrackCount + ", bPLRepeat=" + strB(bPLRepeat) + ", bRandom=" + strB(bRandom))
        If (\bSubTypeP) And (bPLRepeat) And (nTrackCount > 4) And (\nFirstPlayIndex >= 0) ; And (\bPLSavePos)
          bCheckMinGap = #True
          debugMsg(sProcName, "bCheckMinGap=" + strB(bCheckMinGap))
          ; debugCuePtrs(\nCueIndex)
          ReDim aCurrPlayAudPtrs(nTrackCount-1)
          ReDim aCurrPlayAudSeq(nTrackCount-1)
          For n = 0 To nTrackCount-1
            aCurrPlayAudPtrs(n) = -1
            aCurrPlayAudSeq(n) = -1
          Next n
          k = \nFirstPlayIndex
          n = -1
          While k >= 0
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bExists=" + strB(aAud(k)\bExists))
            If aAud(k)\bExists
              nOrigTrackCount + 1
              n + 1
              aCurrPlayAudPtrs(n) = k
              aCurrPlayAudSeq(n) = -1
              ; debugMsg(sProcName, "aCurrPlayAudPtrs(" + n + ")=" + getAudLabel(aCurrPlayAudPtrs(n)))
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
          ; debugMsg(sProcName, "nOrigTrackCount=" + nOrigTrackCount)
          ; added 14May2018 11.7.1ak to fix an error that can occur when importing a playlist cue from another cue file
          ; bug reported by Stas Ushomirsky 11May2018 - importing a playlist crashed with a memory error due to new values in aCurrPlayAudPtrs() not being set (ie being left at -1)
          ; setting bCheckMinGap = #False avoids the issue as aCurrPlayAudPtrs() is not used if bCheckMinGap = #False
          If nTrackCount <> nOrigTrackCount
            bCheckMinGap = #False
          EndIf
          ; end of added 14May2018 11.7.1ak
        EndIf
      EndIf
      
      If \bSubTypeP
        If (\bPLSavePos) And (nTrackCount > 1)
          If \bPLDatabaseInfoLoaded = #False
            loadPlaylistOrderFromDatabase(pSubPtr)
          EndIf
          If bUseInitialSettingsIfRelevant
            bUsePosFromDatabase = #True
          EndIf
        EndIf
      EndIf
      
      If (bRetainPlayOrderIfPossible) Or (bUsePosFromDatabase)
        If (bRandom) And (nTrackCount > 1)
          
          If bUsePosFromDatabase
            If \sPLListOrder
              sListOrderWork = "," + \sPLListOrder + ","
              ReDim aPlayAud(nTrackCount-1)
              k = \nFirstAudIndex
              n = -1
              nPlayNo = 0
              ; debugMsg(sProcName, "sListOrderWork=" + #DQUOTE$ + sListOrderWork + #DQUOTE$)
              While k >= 0
                If aAud(k)\bExists
                  n + 1
                  nPlayNo + 1
                  sPlayNoWork = "," + Trim(Str(nPlayNo)) + ","
                  aPlayAud(n)\nAudPtr = k
                  nWorkIndex = FindString(sListOrderWork, sPlayNoWork)
                  If nWorkIndex > 0
                    sTmp = Left(sListOrderWork, nWorkIndex)
                    aPlayAud(n)\nPlayNo = CountString(sTmp, ",")
                  EndIf
                  ; debugMsg(sProcName, "sPlayNoWork=" + #DQUOTE$ + sPlayNoWork + #DQUOTE$ + ", nWorkIndex=" + nWorkIndex + ", sTmp=" + #DQUOTE$ + sTmp + #DQUOTE$ + ", aPlayAud(" + n + ")\nPlayNo=" + aPlayAud(n)\nPlayNo)
                EndIf
                k = aAud(k)\nNextAudIndex
              Wend
              ReDim aPlayAud(n)
            EndIf
          Else
            ReDim aPlayAud(nTrackCount-1)
            k = \nFirstAudIndex
            n = -1
            While k >= 0
              If aAud(k)\bExists
                n + 1
                aPlayAud(n)\nAudPtr = k
                aPlayAud(n)\nPlayNo = aAud(k)\nPlayNo
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
            ReDim aPlayAud(n)
          EndIf
          
          SortStructuredArray(aPlayAud(), #PB_Sort_Ascending, OffsetOf(tyPlayAud\nPlayNo), TypeOf(tyPlayAud\nPlayNo))
          bRetainPlayOrder = #True
          For n = 0 To ArraySize(aPlayAud())
            If aPlayAud(n)\nPlayNo <= 0
              ; playno not yet assigned
              debugMsg(sProcName, "playno not yet assigned: aPlayAud(" + n + ")\nPlayNo=" + aPlayAud(n)\nPlayNo)
              bRetainPlayOrder = #False
              bCheckMinGap = #False
              Break
            ElseIf n > 0
              If aPlayAud(n)\nPlayNo = aPlayAud(n-1)\nPlayNo
                ; duplicate playno
                bRetainPlayOrder = #False
                debugMsg(sProcName, "duplicate playno: aPlayAud(" + n + ")\nPlayNo=" + aPlayAud(n)\nPlayNo + ", aPlayAud(" + Str(n-1) + ")\nPlayNo=" + aPlayAud(n-1)\nPlayNo)
                Break
              EndIf
            EndIf
          Next n
          
          If bRetainPlayOrder
            nThisPlayIndex = aPlayAud(0)\nAudPtr
            \nFirstPlayIndex = nThisPlayIndex
            nPrevPlayIndex = -1
            For n = 0 To ArraySize(aPlayAud())
              nThisPlayIndex = aPlayAud(n)\nAudPtr
              If n < ArraySize(aPlayAud())
                nNextPlayIndex = aPlayAud(n+1)\nAudPtr
              Else
                nNextPlayIndex = -1
              EndIf
              aAud(nThisPlayIndex)\nPrevPlayIndex = nPrevPlayIndex
              aAud(nThisPlayIndex)\nNextPlayIndex = nNextPlayIndex
              aAud(nThisPlayIndex)\nPlayNo = aPlayAud(n)\nPlayNo
              If n = 0
                sPlayOrder = Str(aAud(nThisPlayIndex)\nAudNo)
              Else
                sPlayOrder + ", " + aAud(nThisPlayIndex)\nAudNo
              EndIf
              nPrevPlayIndex = nThisPlayIndex
            Next n
          EndIf ; EndIf bRetainPlayOrder
        EndIf ; EndIf (bRandom) And (nTrackCount > 1)
      EndIf ; EndIf bRetainPlayOrderIfPossible
      
      ; debugMsg(sProcName, "bRetainPlayOrder=" + strB(bRetainPlayOrder) + ", nTrackCount=" + nTrackCount + ", bRandom=" + strB(bRandom))
      
      If bRetainPlayOrder = #False  ; nb will be #True if the above code has been processed to reset the play indexes, etc
        If (nTrackCount = 1) Or (bRandom = #False)
          ; debugMsg(sProcName, \sSubLabel + ", \nFirstAudIndex=" + \nFirstAudIndex) 
          k = \nFirstAudIndex
          nPrevAudIndex = -1
          nPlayNo = 0
          While k >= 0
            nPlayNo + 1
            aAud(k)\nPlayNo = nPlayNo
            If nPrevAudIndex = -1
              aSub(pSubPtr)\nFirstPlayIndex = k
            Else
              aAud(nPrevAudIndex)\nNextPlayIndex = k
            EndIf
            aAud(k)\nPrevPlayIndex = nPrevAudIndex
            nPrevAudIndex = k
            k = aAud(k)\nNextAudIndex
          Wend
          If nPrevAudIndex >= 0
            aAud(nPrevAudIndex)\nNextPlayIndex = -1
          EndIf
          If nPlayNo = 1
            sPlayOrder = "1"
          Else
            sPlayOrder = "1-" + nPlayNo
          EndIf
          ; debugMsg(sProcName, "sPlayOrder=" + sPlayOrder)
          
        ElseIf nTrackCount > 1
          ; clear existing nPlayNo's
          k = \nFirstAudIndex
          While k >= 0
            aAud(k)\nPlayNo = 0
            k = aAud(k)\nNextAudIndex
          Wend
          
          If bCheckMinGap
            nMinRepeatGap = nTrackCount / 2
            debugMsg(sProcName, "nTrackCount=" + nTrackCount + ", nMinRepeatGap=" + nMinRepeatGap + ", ArraySize(aCurrPlayAudSeq())=" + ArraySize(aCurrPlayAudSeq()))
;             For n = 0 To ArraySize(aCurrPlayAudSeq())
;               debugMsg(sProcName, "aCurrPlayAudSeq(" + n + ")=" + aCurrPlayAudSeq(n))
;             Next n
            nPlayNo = 1
            While nPlayNo <= nTrackCount
              If nPlayNo <= nMinRepeatGap
                nRandomMax = nTrackCount - nMinRepeatGap ; + 1
              Else
                nRandomMax = nTrackCount - nPlayNo + 1
              EndIf
              nRandomNo = Random(nRandomMax, 1)
              ; debugMsg(sProcName, "nPlayNo=" + nPlayNo + ", nRandomMax=" + nRandomMax + ", nRandomNo=" + nRandomNo)
              nCounter = 0
              For n = 0 To ArraySize(aCurrPlayAudSeq())
                If aCurrPlayAudSeq(n) < 0
                  nCounter + 1
                  If nCounter = nRandomNo
                    aCurrPlayAudSeq(n) = nPlayNo
                    nPlayNo + 1
                    Break
                  EndIf
                EndIf
              Next n
            Wend
            nPrevPlayIndex = -1
            For nPlayNo = 1 To nTrackCount
              For n = 0 To ArraySize(aCurrPlayAudSeq())
                If aCurrPlayAudSeq(n) = nPlayNo
                  k = aCurrPlayAudPtrs(n)
                  aAud(k)\nPlayNo = nPlayNo
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPlayNo=" + aAud(k)\nPlayNo)
                  If nPlayNo = 1
                    aSub(pSubPtr)\nFirstPlayIndex = k
                    sPlayOrder = Str(aAud(k)\nAudNo)
                  Else
                    CheckSubInRange(nPrevAudIndex, ArraySize(aAud()), "aAud()")
                    aAud(nPrevAudIndex)\nNextPlayIndex = k
                    sPlayOrder + ", " + aAud(k)\nAudNo
                  EndIf
                  aAud(k)\nPrevPlayIndex = nPrevAudIndex
                  nPrevAudIndex = k
                  Break ; Break n
                EndIf
              Next n
            Next nPlayNo

          Else
            ; randomly assign the play order
            nPrevAudIndex = -1
            nCounter = nTrackCount
            nPlayNo = 0
            While nCounter > 0
              nNextTrack = Random(nCounter, 1)
              nPlayNo + 1
              ; debugMsg(sProcName, "nCounter=" + nCounter + ", nNextTrack=" + nNextTrack + ", nPlayNo=" + nPlayNo)
              k = \nFirstAudIndex
              nThisTrack = 0
              bFound = #False
              While (k >= 0) And (bFound = #False)
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPlayNo=" + aAud(k)\nPlayNo)
                If aAud(k)\nPlayNo = 0
                  ; this track not yet assigned
                  nThisTrack + 1
                  If nThisTrack = nNextTrack
                    ; found the next track to be assigned
                    aAud(k)\nPlayNo = nPlayNo
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPlayNo=" + aAud(k)\nPlayNo)
                    If nPlayNo = 1
                      aSub(pSubPtr)\nFirstPlayIndex = k
                      sPlayOrder = Str(aAud(k)\nAudNo)
                    Else
                      CheckSubInRange(nPrevAudIndex, ArraySize(aAud()), "aAud()")
                      aAud(nPrevAudIndex)\nNextPlayIndex = k
                      sPlayOrder + ", " + aAud(k)\nAudNo
                    EndIf
                    aAud(k)\nPrevPlayIndex = nPrevAudIndex
                    nPrevAudIndex = k
                    bFound = #True
                  EndIf
                EndIf
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nNextAudIndex=" + getAudLabel(aAud(k)\nNextAudIndex))
                k = aAud(k)\nNextAudIndex
              Wend
              nCounter - 1
            Wend
          EndIf
          
          If nPrevAudIndex >= 0
            aAud(nPrevAudIndex)\nNextPlayIndex = -1
          EndIf
        EndIf
      EndIf ; EndIf bRetainPlayOrder = #False
      
      If \bSubTypeP
        If (\bPLSavePos) And (nTrackCount > 1) And (bRandom)
          sListOrderToSave = RemoveString(sPlayOrder, " ")
        EndIf
        If \sPLListOrder <> sListOrderToSave
          gbUnsavedPlaylistOrderInfo = #True
        EndIf
      EndIf
      
      If \bSubTypeAorP
        If bEditing
          ; may need to reset the sub descr, esp if going from 1 file to more than 1 file
          ; debugMsg(sProcName, "calling setDefaultSubDescr(" + getSubLabel(pSubPtr) + ", #False)")
          setDefaultSubDescr(pSubPtr, #False)
        EndIf
        
        ; set nAudState using play order
        k = \nFirstPlayIndex
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\sSubDescr=" + aSub(pSubPtr)\sSubDescr)
        While k >= 0
          \nLastPlayIndex = k
          If (aAud(k)\nAudState = #SCS_CUE_READY) Or (aAud(k)\nAudState = #SCS_CUE_PL_READY)
            setPlaylistTrackReadyState(k)
          EndIf
          If \nAudCount = 1
            Select aAud(k)\nFileFormat
              Case #SCS_FILEFORMAT_CAPTURE
                aAud(k)\sAudDescr = aAud(k)\sVideoCaptureLogicalDevice
              Default
                If (aAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
                  aAud(k)\sAudDescr = aAud(k)\sFileTitle
                Else
                  aAud(k)\sAudDescr = ignoreExtension(GetFilePart(aAud(k)\sFileName))
                EndIf
            EndSelect
            If \bDefaultSubDescrMayBeSet
              ; change sub descr if only one aud for this sub
              \sSubDescr = aAud(k)\sAudDescr
            EndIf
          Else
            aAud(k)\sAudDescr = aSub(pSubPtr)\sSubDescr
            If aSub(pSubPtr)\nAudCount > 1
              aAud(k)\sAudDescr + " " + aAud(k)\nPlayNo + "/" + aSub(pSubPtr)\nAudCount
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileTitle=" + aAud(k)\sFileTitle)
            Select aAud(k)\nVideoSource
              Case #SCS_VID_SRC_FILE
                If aAud(k)\sFileTitle
                  aAud(k)\sAudDescr + ": " + Trim(aAud(k)\sFileTitle)
                Else
                  aAud(k)\sAudDescr + ": " + ignoreExtension(GetFilePart(aAud(k)\sFileName))
                EndIf
              Case #SCS_VID_SRC_CAPTURE
                aAud(k)\sAudDescr + ": " + aAud(k)\sVideoCaptureLogicalDevice
            EndSelect
          EndIf
          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPrevAudIndex=" + aAud(k)\nPrevAudIndex + ", \nNextAudIndex=" + aAud(k)\nNextAudIndex + ", \sAudDescr=" + aAud(k)\sAudDescr)
          k = aAud(k)\nNextPlayIndex
        Wend
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLastPlayIndex=" + getAudLabel(\nLastPlayIndex))
        
        sQualifier = ""
        If \bPLRepeat
          If \nLastPlayIndex >= 0
            If aAud(\nLastPlayIndex)\nFileFormat = #SCS_FILEFORMAT_PICTURE
              bContinuous = aAud(\nLastPlayIndex)\bContinuous
            EndIf
          EndIf
          If bContinuous = #False
            sQualifier = LCase(grText\sTextRepeat)
          EndIf
        EndIf
        If \bPLSavePos
          If sQualifier
            sQualifier + ", "
          EndIf
          sQualifier + LCase(Lang("Common", "Save"))
        EndIf
        If sQualifier
          sPlayOrder + " (" + sQualifier + ")"
        EndIf
        
        If bEditing
          ; may need to reset the sub descr again, esp if going from more than 1 file to only 1 file
          ; debugMsg(sProcName, "calling setDefaultSubDescr(" + getSubLabel(pSubPtr) + ", #False)")
          setDefaultSubDescr(pSubPtr, #False)
          ; debugMsg(sProcName, "calling setDefaultCueDescr(" + getCueLabel(\nCueIndex) + ", " + getSubLabel(pSubPtr) + ")")
          setDefaultCueDescr(\nCueIndex, pSubPtr)
        EndIf
        
        If nTrackCount > 1
          debugMsg(sProcName, "(prim) \sSubType=" + \sSubType + ", Play Order: " + sPlayOrder)
        EndIf
        ; logListEvent(sProcName, "(prim) \sSubType=" + \sSubType + ", Play Order: " + sPlayOrder)
        
      EndIf ; EndIf \bSubTypeAorP
      
      \nLastPlayIndex = -1
      k = \nFirstPlayIndex
      While k >= 0
        ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPrevPlayIndex=" + getAudLabel(aAud(k)\nPrevPlayIndex) + ", \nNextPlayIndex=" + getAudLabel(aAud(k)\nNextPlayIndex))
        \nLastPlayIndex = k
        k = aAud(k)\nNextPlayIndex
      Wend
      ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLastPlayIndex=" + getAudLabel(\nLastPlayIndex))
      
      CompilerIf 1=2
        k = \nFirstPlayIndex
        While k >= 0
          debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPrevPlayIndex=" + getAudLabel(aAud(k)\nPrevPlayIndex) + ", \nNextPlayIndex=" + getAudLabel(aAud(k)\nNextPlayIndex))
          k = aAud(k)\nNextPlayIndex
        Wend
      CompilerEndIf
      
      \sPlayOrder = sPlayOrder
      setFirstPlayIndexThisRun(pSubPtr, bUsePosFromDatabase)
      \nCurrPlayIndex = \nFirstPlayIndexThisRun
      ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex))
      If (gbInPaste = #False) And (gbWaitForDispPanels = #False)
        If \bSubTypeAorP
          ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
        Else
          gnRefreshCuePtr = \nCueIndex
          gnRefreshSubPtr = pSubPtr
          gnRefreshAudPtr = \nFirstPlayIndex
          gbCallRefreshDispPanel = #True
          ; debugMsg(sProcName, "gbCallRefreshDispPanel=" + strB(gbCallRefreshDispPanel) + ", gnRefreshCuePtr=" + getCueLabel(gnRefreshCuePtr) +
          ;                     ", gnRefreshSubPtr=" + getSubLabel(gnRefreshSubPtr) + ", gnRefreshAudPtr=" + getAudLabel(gnRefreshAudPtr))
        EndIf
      EndIf
      
      If \bSubTypeP
        If \bPLRandom Or \bPLSavePos
          If \nFirstPlayIndex >= 0 ; Test added 21Apr2020 11.8.2.3ax following email from Lloyd Grounds
            ; debugMsg(sProcName, "calling FMP_sendCommandIfReqd(#SCS_OSCINP_SET_PLAYORDER, " + getCueLabel(\nCueIndex) + ", " + \nSubNo + ", " + aAud(\nFirstPlayIndexThisRun)\nAudNo + ", " + #DQUOTE$ + \sPlayOrder + #DQUOTE$ + ")")
            FMP_sendCommandIfReqd(#SCS_OSCINP_SET_PLAYORDER, \nCueIndex, \nSubNo, aAud(\nFirstPlayIndexThisRun)\nAudNo, \sPlayOrder)
          EndIf
        EndIf
      EndIf
      
      ; Added 4Jul2023 11.10.0bn
      If \bSubTypeP
        ; If a playlist is set to random, repeat and save, and if the last transition is not 'none'
        ; then we must set that last transition to none or the playlist will terminate and not repeat.
        ; The reason for cancelling (temporarily) the last file's transition is to enable SCS to re-randomize the order before
        ; the next iteration of the playlist.
        ; See also the 'limitation' comment in the Help under Editor / Playlist Cues / Save Playback Position.
        If \bPLRandom And \bPLRepeat And \bPLSavePos
          If \nLastPlayIndex >= 0
            If aAud(\nLastPlayIndex)\nPLRunTimeTransType <> #SCS_TRANS_NONE
              debugMsg(sProcName, "setting aAud(" + getAudLabel(\nLastPlayIndex) + ")\nPLRunTimeTransType=none, was " + decodeTransType(aAud(\nLastPlayIndex)\nPLRunTimeTransType))
              aAud(\nLastPlayIndex)\nPLRunTimeTransType = #SCS_TRANS_NONE
              aAud(\nLastPlayIndex)\nPLRunTimeTransTime = grAudDef\nPLTransTime
            EndIf
          EndIf
        EndIf
      EndIf
      ; End added 4Jul2023 11.10.0bn
      
    EndWith
    
  Else ; bPrimaryFile = False
    With a2ndSub(pSubPtr)
      nTrackCount = 0
      If \bSubTypeF
        nTrackCount = 1
        bRandom = #False
        bPLRepeat = #False
      ElseIf \bSubTypeAorP
        nTrackCount = \nAudCount
        bRandom = \bPLRandom
        bPLRepeat = \bPLRepeat
      EndIf
      
      If (nTrackCount = 1) Or (bRandom = #False)
        k = \nFirstAudIndex
        nPrevAudIndex = -1
        nPlayNo = 0
        While k >= 0
          nPlayNo + 1
          a2ndAud(k)\nPlayNo = nPlayNo
          If nPrevAudIndex = -1
            a2ndSub(pSubPtr)\nFirstPlayIndex = k
          Else
            a2ndAud(nPrevAudIndex)\nNextPlayIndex = k
          EndIf
          a2ndAud(k)\nPrevPlayIndex = nPrevAudIndex
          nPrevAudIndex = k
          k = a2ndAud(k)\nNextAudIndex
        Wend
        If nPrevAudIndex >= 0
          a2ndAud(nPrevAudIndex)\nNextPlayIndex = -1
        EndIf
        If nPlayNo = 1
          sPlayOrder = "1"
        Else
          sPlayOrder = "1-" + nPlayNo
        EndIf
        
      ElseIf nTrackCount > 1
        ; clear existing nPlayNo's
        k = \nFirstAudIndex
        While k >= 0
          a2ndAud(k)\nPlayNo = 0
          k = a2ndAud(k)\nNextAudIndex
        Wend
        
        ; randomly assign the play order
        nPrevAudIndex = -1
        nCounter = nTrackCount
        While nCounter > 0
          nNextTrack = Random(nCounter, 1)
          nPlayNo + 1
          debugMsg(sProcName, "nCounter=" + nCounter + ", nNextTrack=" + nNextTrack + ", nPlayNo=" + nPlayNo)
          k = \nFirstAudIndex
          nThisTrack = 0
          bFound = #False
          While (k >= 0) And (bFound = #False)
            debugMsg(sProcName, "a2ndAud(" + getAudLabel2(k) + ")\nPlayNo=" + a2ndAud(k)\nPlayNo)
            If a2ndAud(k)\nPlayNo = 0
              ; this track not yet assigned
              nThisTrack + 1
              If nThisTrack = nNextTrack
                ; found the next track to be assigned
                a2ndAud(k)\nPlayNo = nPlayNo
                debugMsg(sProcName, "a2ndAud(" + getAudLabel2(k) + ")\nPlayNo=" + a2ndAud(k)\nPlayNo)
                If nPlayNo = 1
                  a2ndSub(pSubPtr)\nFirstPlayIndex = k
                  sPlayOrder = Str(a2ndAud(k)\nAudNo)
                Else
                  CheckSubInRange(nPrevAudIndex, ArraySize(a2ndAud()), "a2ndAud()")
                  a2ndAud(nPrevAudIndex)\nNextPlayIndex = k
                  sPlayOrder + ", " + a2ndAud(k)\nAudNo
                EndIf
                a2ndAud(k)\nPrevPlayIndex = nPrevAudIndex
                nPrevAudIndex = k
                bFound = #True
              EndIf
            EndIf
            debugMsg(sProcName, "a2ndAud(" + getAudLabel2(k) + ")\nNextAudIndex=" + getAudLabel2(a2ndAud(k)\nNextAudIndex))
            k = a2ndAud(k)\nNextAudIndex
          Wend
          nCounter - 1
        Wend
        
        If nPrevAudIndex >= 0
          a2ndAud(nPrevAudIndex)\nNextPlayIndex = -1
        EndIf
      EndIf
      
      If \bSubTypeAorP
        ; set nAudState using play order
        k = \nFirstPlayIndex
        sPlayOrder = ""
        While k >= 0
          If (a2ndAud(k)\nAudState = #SCS_CUE_READY) Or (a2ndAud(k)\nAudState = #SCS_CUE_PL_READY)
            If a2ndAud(k)\nPrevPlayIndex = -1
              a2ndAud(k)\nAudState = #SCS_CUE_READY
            Else
              a2ndAud(k)\nAudState = #SCS_CUE_PL_READY
            EndIf
          EndIf
          If a2ndAud(k)\nPrevPlayIndex = -1
            sPlayOrder = Str(a2ndAud(k)\nAudNo)
          Else
            sPlayOrder + ", " + a2ndAud(k)\nAudNo
          EndIf
          
          debugMsg(sProcName, "a2ndSub(" + getSubLabel2(pSubPtr) + ")\nAudCount=" + \nAudCount)
          If \nAudCount = 1
            If (a2ndAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
              a2ndAud(k)\sAudDescr = a2ndAud(k)\sFileTitle
            Else
              a2ndAud(k)\sAudDescr = ignoreExtension(GetFilePart(a2ndAud(k)\sFileName))
            EndIf
            If \bDefaultSubDescrMayBeSet
              ; change sub descr if only one aud for this sub
              \sSubDescr = a2ndAud(k)\sAudDescr
            EndIf
          Else
            a2ndAud(k)\sAudDescr = a2ndSub(pSubPtr)\sSubDescr
            If a2ndSub(pSubPtr)\nAudCount > 1
              a2ndAud(k)\sAudDescr + " " + a2ndAud(k)\nPlayNo + "/" + a2ndSub(pSubPtr)\nAudCount
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileTitle=" + a2ndAud(k)\sFileTitle)
            If a2ndAud(k)\sFileTitle
              a2ndAud(k)\sAudDescr + ": " + a2ndAud(k)\sFileTitle
            Else
              a2ndAud(k)\sAudDescr + ": " + ignoreExtension(GetFilePart(a2ndAud(k)\sFileName))
            EndIf
          EndIf
          ; debugMsg(sProcName, "a2ndAud(" + getAudLabel(k) + ")\nPrevAudIndex=" + aAud(k)\nPrevAudIndex + ", \nNextAudIndex=" + a2ndAud(k)\nNextAudIndex + ", \sAudDescr=" + aAud(k)\sAudDescr) 
          k = a2ndAud(k)\nNextPlayIndex 
        Wend
        
        If \bPLRepeat
          If \nLastPlayIndex >= 0
            If aAud(\nLastPlayIndex)\nFileFormat = #SCS_FILEFORMAT_PICTURE
              bContinuous = aAud(\nLastPlayIndex)\bContinuous
            EndIf
          EndIf
          If bContinuous = #False
            sPlayOrder + " (" + LCase(grText\sTextRepeat) + ")"
          EndIf
        EndIf
        
        If nTrackCount > 1
          debugMsg(sProcName, "(sec) \sSubType=" + \sSubType + ", Play Order: " + sPlayOrder)
        EndIf
        
      EndIf
      
      \nLastPlayIndex = -1
      k = \nFirstPlayIndex
      While k >= 0
        \nLastPlayIndex = k
        k = a2ndAud(k)\nNextPlayIndex
      Wend
      
      \sPlayOrder = sPlayOrder
      \nCurrPlayIndex = \nFirstPlayIndex
      debugMsg(sProcName, "\nCurrPlayIndex=" + getAudLabel2(\nCurrPlayIndex))
      ; (not required for secondary file) gbCallLoadDispPanels = True
      
    EndWith
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure goClicked(bMouseClick = #False)
  PROCNAMEC()
  Protected nReqdDoubleClickTime
  
  debugMsg(sProcName, #SCS_START + ", bMouseClick=" + strB(bMouseClick))
  
  If (bMouseClick) Or (grGeneralOptions\bApplyTimeoutToOtherGos)
    nReqdDoubleClickTime = grGeneralOptions\nDoubleClickTime
  EndIf
  
  setGlobalTimeNow()
  
  If (gqTimeNow - gqTimeMouseClicked) >= nReqdDoubleClickTime
    gqTimeMouseClicked = gqTimeNow
    If gbWaitForSetCueToGo
      debugMsg(sProcName, "gbWaitForSetCueToGo=" + strB(gbWaitForSetCueToGo))
      gbCallGoClicked = #True
    Else
      debugMsg(sProcName, "gnCueToGo=" + getCueLabel(gnCueToGo))
      If (gnCueToGo <= 0) Or (gnCueToGo >= gnCueEnd)
        debugMsg(sProcName, "exiting because gnCueToGo out of range")
        ProcedureReturn
      EndIf
      gbWaitForSetCueToGo = #True
      debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(gnCueToGo) + ")")
      playCueViaCas(gnCueToGo)
      gqMainThreadRequest | #SCS_MTH_SET_CUE_TO_GO
      debugMsg(sProcName, "gqMainThreadRequest | #SCS_MTH_SET_CUE_TO_GO")
      ; moved here 29Mar2019 11.8.0.2cj, from further down this Procedure, following email from Dave Korman "Loss of sync between Primary and Backup machines"
      If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
        FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_GO)
      EndIf
      gnCueToGoOverride = -1
      ; end moved here 29Mar2019 11.8.0.2cj
    EndIf
  Else
    debugMsg(sProcName, "ignoring due to time, nReqdDoubleClickTime=" + nReqdDoubleClickTime + ", gqTimeNow=" + traceTime(gqTimeNow) + ", gqTimeMouseClicked=" + traceTime(gqTimeMouseClicked))
  EndIf
  
  If gbEditHasFocus = #False
    SAG(-1)
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure goIfOK()
  PROCNAMEC()
  Static qLastGoTime.q
  
  ; tasks:
  ; - play cue to go
  ; - send GO command to backup computer if reqd
  ; - update grid and cue panel for cue
  ; - determine next manual cue
  ; - set GO button for next manual cue
  ; - update grid and cue panel for next manual cue
  ; - open next cues
  
  debugMsg(sProcName, #SCS_START)
  
  If getToolBarBtnEnabled(#SCS_TBMB_GO) = #False
    debugMsg(sProcName, "exiting because GO button disabled")
    ProcedureReturn #False
  EndIf
  
  ; debugMsg(sProcName, "bEnabled=" + strB(bEnabled))
  If gnThreadNo > #SCS_THREAD_MAIN
    PostEvent(#SCS_Event_GoButton, #WMN, 0)
    ProcedureReturn #True
  EndIf
  
  setGlobalTimeNow()
  If (gqTimeNow - qLastGoTime) >= grGeneralOptions\nDoubleClickTime
    qLastGoTime = gqTimeNow
    debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(gnCueToGo) + ")")
    playCueViaCas(gnCueToGo)
    debugMsg(sProcName, "calling setCueToGo()")
    setCueToGo()
    If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
      FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_GO)
    EndIf
  Else
    debugMsg(sProcName, "Go ignored - double-click")
    ProcedureReturn #False
  EndIf
  gnCueToGoOverride = -1
  
  If grM2T\bM2TCueListColoringApplied
    M2T_clearCueInds()
    colorCueListEntries()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure resetInitialStateOfCue(pThisCuePtr, pCurrentCuePtr)
  PROCNAMECQ(pThisCuePtr)
  Protected d, j, k
  Protected nRow
  Protected nGaplessSeqPtr
  Protected sActivation.s
  Protected bSkip, bCheckCueState

  ; debugMsg(sProcName, #SCS_START + ", pCurrentCuePtr=" + getCueLabel(pCurrentCuePtr))
  
  If pThisCuePtr >= 0
    With aCue(pThisCuePtr)
      If (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
        nRow = \nGrdCuesRowNo
        ; debugMsg(sProcName, "\nCueState=" + decodeCueState(\nCueState))
        If (\nCueState < #SCS_CUE_FADING_IN) Or (\nCueState > #SCS_CUE_FADING_OUT)
          ; debugMsg(sProcName, "\nCueState=" + decodeCueState(\nCueState))
          ; debugMsg(sProcName, "calling setInitCueStates(" + getCueLabel(pThisCuePtr) + ", " + getCueLabel(pCurrentCuePtr) + ", #True, #True, #True)")
          setInitCueStates(pThisCuePtr, pCurrentCuePtr, #True, #True, #True)
          Select \nActivationMethod
            Case #SCS_ACMETH_TIME
              If \nActivationMethodReqd = #SCS_ACMETH_MAN
                ; debugMsg(sProcName, "\bCueStoppedByStopEverything=" + strB(\bCueStoppedByStopEverything))
                If \bCueStoppedByStopEverything Or \bCueStoppedByGoToCue
                  bSkip = #True
                EndIf
              EndIf
          EndSelect
          If bSkip = #False
            If \nAutoActPosn = #SCS_ACPOSN_LOAD
              \nActivationMethodReqd = #SCS_ACMETH_MAN
              debugMsg(sProcName, "aCue(" + getCueLabel(pThisCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
            Else
              If \nAutoActCueSelType = #SCS_ACCUESEL_PREV
                setCuePtrForAutoStartPrevCueType(pThisCuePtr)
              EndIf
              ; debugMsg(sProcName, \sCue + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) +
              ;                     ", \nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) + ", pCurrentCuePtr=" + getCueLabel(pCurrentCuePtr))
              bCheckCueState = #True
              If (\nAutoActCuePtr >= 0)
                If aCue(\nAutoActCuePtr)\nCueState < #SCS_CUE_COMPLETED
                  \nActivationMethodReqd = \nActivationMethod
                  bCheckCueState = #False
                EndIf
              EndIf
              If bCheckCueState
                If (\nActivationMethod = #SCS_ACMETH_AUTO) And (\nAutoActCuePtr < pCurrentCuePtr)
                  \nActivationMethodReqd = #SCS_ACMETH_MAN
                ElseIf (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF) And (\nAutoActCuePtr < pCurrentCuePtr)
                  \nActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF
                ElseIf (\nActivationMethod = #SCS_ACMETH_OCM) And (\nAutoActCuePtr < pCurrentCuePtr) ; added 18Mar2020 11.8.2.3ab
                  \nActivationMethodReqd = #SCS_ACMETH_MAN
                Else
                  \nActivationMethodReqd = \nActivationMethod
                EndIf
              EndIf
            EndIf
          EndIf
          ; debugMsg(sProcName, "\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
          
          j = \nFirstSubIndex
          While j >= 0
            
            If aSub(j)\bSubTypeHasAuds
              aSub(j)\nSubPosition = 0
              If aSub(j)\bSubTypeA
                nGaplessSeqPtr = aSub(j)\nSubGaplessSeqPtr
              Else
                nGaplessSeqPtr = -1
              EndIf
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                aAud(k)\nRelFilePos = aAud(k)\nRelStartAt
                aAud(k)\nCuePos = 0
                aAud(k)\nTotalTimeOnPause = 0
                aAud(k)\nPriorTimeOnPause = 0
                aAud(k)\nPreFadeInTimeOnPause = 0
                aAud(k)\nPreFadeOutTimeOnPause = 0
                aAud(k)\nCuePosAtLoopStart = 0
                aAud(k)\nCuePosWhenLastChecked = 0
                k = aAud(k)\nNextAudIndex
              Wend
              If aSub(j)\bSubTypeAorP
                If aSub(j)\nFirstPlayIndexThisRun >= 0
                  aSub(j)\nCurrPlayIndex = aSub(j)\nFirstPlayIndexThisRun
                Else
                  aSub(j)\nCurrPlayIndex = aSub(j)\nFirstPlayIndex
                EndIf
                debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nCurrPlayIndex=" + getAudLabel(aSub(j)\nCurrPlayIndex) + ", \nFirstPlayIndexThisRun=" + getAudLabel(aSub(j)\nFirstPlayIndexThisRun))
                aSub(j)\bPLTerminating = #False
                ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bPLTerminating=" + strB(aSub(j)\bPLTerminating))
                aSub(j)\bPLFadingIn = #False
                aSub(j)\bPLFadingOut = #False
                aSub(j)\nPLAudPlayCount = 0
              EndIf
              
            ElseIf aSub(j)\bSubTypeE
              aSub(j)\nSubPosition = 0
              
            ElseIf aSub(j)\bSubTypeK
              aSub(j)\nSubPosition = 0
              
            ElseIf aSub(j)\bSubTypeL
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                aSub(j)\nLCPosition[d] = 0
              Next d
              aSub(j)\nLCPositionMax = 0
              
            ElseIf aSub(j)\bSubTypeM
              aSub(j)\nSubPosition = 0
              
            ElseIf aSub(j)\bSubTypeU
              aSub(j)\nSubPosition = 0
              
            EndIf
            
            ; aSub(j)\qTimeSubStarted = 0
            aSub(j)\bTimeSubStartedSet = #False
            aSub(j)\bPLRepeatCancelled = #False
            j = aSub(j)\nNextSubIndex
          Wend
          \qTimeCueStarted = 0
          \bTimeCueStartedSet = #False
          ; debugMsg(sProcName, "aCue(" + getCueLabel(pThisCuePtr) + ")\qTimeCueStarted=0, \bTimeCueStartSet=#False")
          ; If \nActivationMethod = #SCS_ACMETH_TIME
          If \nActivationMethodReqd = #SCS_ACMETH_TIME  ; modified 25Aug2016 11.5.2
            debugMsg(sProcName, "calling setTimeBasedCues(" + getCueLabel(pThisCuePtr) + ")")
            setTimeBasedCues(pThisCuePtr)
          Else
            \qTimeCueStopped = 0
            \bTimeCueStoppedSet = #False
            \bCueStoppedByStopEverything = #False
            \bCueStoppedByGoToCue = #False
            ; debugMsg(sProcName, "aCue(" + getCueLabel(pThisCuePtr) + ")\bTimeCueStoppedSet=" + strB(\bTimeCueStoppedSet))
          EndIf
          
          ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(pThisCuePtr) + ")")
          setCueState(pThisCuePtr)
          If gnThreadNo = #SCS_THREAD_MAIN
            If aCue(pThisCuePtr)\nHideCueOpt <> #SCS_HIDE_ENTIRE_CUE  ; test added 2Nov2018 11.8.0an
              sActivation = getCueActivationMethodForDisplay(pThisCuePtr)
              WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_AC, sActivation)
              ; debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRow + ", #SCS_GRDCUES_CS, " + getCueStateForGrid(pThisCuePtr) + ") for " + \sCue)
              WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_CS, getCueStateForGrid(pThisCuePtr))
            EndIf
          Else
            samAddRequest(#SCS_SAM_LOAD_GRID_ROW, pThisCuePtr)
          EndIf
          If \bResetInitialStateWhenCompleted
            debugMsg(sProcName, "setting \bResetInitialStateWhenCompleted=" + strB(grCueDef\bResetInitialStateWhenCompleted) + ", \nCurrentCuePtrForResetInitialState=" + getCueLabel(pCurrentCuePtr))
            \bResetInitialStateWhenCompleted = grCueDef\bResetInitialStateWhenCompleted
            \nCurrentCuePtrForResetInitialState = grCueDef\nCurrentCuePtrForResetInitialState
          EndIf
          
          ; Else ; cue currently playing    ; 4Jan2016 - modified to limit this to cues AFTER the current cue, following log from Brian O'Connor whereby a time-based playlist (Q2) was playing
          ;                                              and after being completed was reset and then continually monitored in statusCheck()
        ElseIf pThisCuePtr > pCurrentCuePtr ; cue currently playing
          debugMsg(sProcName, "setting \bResetInitialStateWhenCompleted=#True, \nCurrentCuePtrForResetInitialState=" + getCueLabel(pCurrentCuePtr))
          \bResetInitialStateWhenCompleted = #True
          \nCurrentCuePtrForResetInitialState = pCurrentCuePtr
          
        EndIf
        
      EndIf ; EndIf (\bHotkey = #False) and (\bExtAct = #False) And (\bCallableCue = #False)
    EndWith
  EndIf
  
EndProcedure

Procedure GoToCue(pCuePtr, bSetCueToGo=#True, bDisplayWarning=#False, bApplyDefaultGridClickAction=#False)
  PROCNAMECQ(pCuePtr)
  Protected d, i, j, k
  Protected bCompleteThis, nCueRow
  Protected bStandbyThis
  Protected nRow, sActivation.s
  Protected nPrevStandbyCuePtr
  Protected nCurrentVideoCuePtr, nCurrentVideoAudPtr
  Protected bRedrawState
  Protected bLockedMutex
  Protected nGaplessSeqPtr
  Protected bWarningDisplayed
  Protected bCloseThisSub, bCallResetCueState
  Protected bHideNetworkTracing

  debugMsg(sProcName, #SCS_START + ", bSetCueToGo=" + strB(bSetCueToGo) + ", bDisplayWarning=" + strB(bDisplayWarning) + ", bApplyDefaultGridClickAction=" + strB(bApplyDefaultGridClickAction))

  CheckSubInRange(pCuePtr, ArraySize(aCue()), "aCue(), gnLastCue="+Str(gnLastCue))
  If aCue(pCuePtr)\bNonLinearCue
    goToCueNonLinear(pCuePtr)
    ProcedureReturn
  Else
    gnNonLinearCue = -1 ; added 21Mar2017 11.6.0 following test of Martin Norris's cue file whereby I couldn't click back to Q1 after clicking on, say, cue 7
  EndIf
  
  LockCueListMutex(30)
  
  gbInGoToCue = #True
  
  If #cTraceNetworkMsgs = #False
    bHideNetworkTracing = #True
  EndIf
  
  If gnThreadNo = #SCS_THREAD_MAIN
    WMN_disableGoButtons()
    setMouseCursorBusy()
    ; turn off grdCues redrawing until 'GoToCue' has finished as several cues may be redrawn during this procedure
    bRedrawState = getGrdCuesRedrawState()
    setGrdCuesRedrawState(#False)
    If bDisplayWarning
      WMN_displayWarningMsg(grText\sTextRepositioning)
      bWarningDisplayed = #True
    EndIf
  EndIf
  
  gbForceGridReposition = #True
  
  debugMsg(sProcName, "pCuePtr=" + pCuePtr + "(" + getCueLabel(pCuePtr) + "), gnCueToGo=" + gnCueToGo + "(" + getCueLabel(gnCueToGo) + "), gnHighlightedCue=" + gnHighlightedCue + "(" + getCueLabel(gnHighlightedCue) + ")")
  
  CompilerIf #c_vMix_in_video_cues
    If pCuePtr < gnCueToGo
      If grvMixInfo\nMaxInputNoForEdition < 20
        ; Basic or Basic HD edition
        vMix_RemoveInputsNotPlaying()
      EndIf
    EndIf
  CompilerEndIf
  
  If bSetCueToGo
    gnHighlightedCue = -1
    gnHighlightedRow = -1
    ; debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow)
  EndIf
  nCueRow = aCue(pCuePtr)\nGrdCuesRowNo
  ; debugMsg(sProcName, "pCuePtr=" + pCuePtr + ", nCueRow=" + nCueRow)
  nPrevStandbyCuePtr = -1

  For i = 1 To (pCuePtr - 1)
    With aCue(i)
      If \bResetInitialStateWhenCompleted
        ; undo \bResetInitialStateWhenCompleted
        ; nb problem reported by Michel Winogradoff (24/08/2013):
        ; Q87 playing
        ; user clicks on earlier cue in cue list while Q87 still playing, so SCS set Q87 \bResetInitialStateWhenCompleted = #True
        ; while Q87 still playing, user clicks on later cue in cue list
        ; when Q87 ended it was reset to 'ready' because \bResetInitialStateWhenCompleted = #True
        ; but this should not have been done because the user subsequently clicked a later cue
        ; fix: in this 'GoToCue()' procedure clear \bResetInitialStateWhenCompleted for any cues that should be 'completed',
        ; ie for any cues earlier than pCuePtr.
        ; debugMsg(sProcName, "setting \bResetInitialStateWhenCompleted=#False")
        \bResetInitialStateWhenCompleted = #False
        \nCurrentCuePtrForResetInitialState = grCueDef\nCurrentCuePtrForResetInitialState
      EndIf
      
      If (\nCueState < #SCS_CUE_FADING_IN) Or (\nCueState > #SCS_CUE_FADING_OUT)
        
        nRow = \nGrdCuesRowNo
        bCompleteThis = #True
        bStandbyThis = #False
        nPrevStandbyCuePtr = gnStandbyCuePtr
        
        If \nStandby = #SCS_STANDBY_SET
          If (gnStandbyCuePtr < 0) Or (gnStandbyCuePtr <= i)
            bStandbyThis = #True
            bCompleteThis = #False
          EndIf
        EndIf
        If (\bHotkey) Or (\bExtAct) Or (\bCallableCue) Or (\nActivationMethodReqd = #SCS_ACMETH_TIME)
          bCompleteThis = #False
        EndIf
        
        If bStandbyThis
          gnStandbyCuePtr = i
          If (nPrevStandbyCuePtr >= 0) And (nPrevStandbyCuePtr < i)
            closeCue(nPrevStandbyCuePtr)
            setCueState(nPrevStandbyCuePtr)
            updateGrid(nPrevStandbyCuePtr)
          EndIf
          j = \nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubEnabled
              If aSub(j)\bSubTypeHasAuds
                k = aSub(j)\nFirstAudIndex
                While k >= 0
                  audSetState(k, #SCS_CUE_STANDBY, 21)
                  k = aAud(k)\nNextAudIndex
                Wend
              EndIf
              aSub(j)\nSubState = #SCS_CUE_STANDBY
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
          ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
          setCueState(i)
          updateScreenForCue(i, bStandbyThis)
        EndIf
        
        ; added 2Nov2018 11.8.0an
        If bCompleteThis
          ; 26Nov2018 11.8.0ay added test (\nCueState <> #SCS_CUE_ERROR) as without it clicking on a cue in the grid of the main cue would not go past an error cue
          If (\nCueState >= #SCS_CUE_COMPLETED) And (\nCueState <> #SCS_CUE_ERROR)
            bCompleteThis = #False
          EndIf
        EndIf
        ; end added 2Nov2018 11.8.0an
        
        If bCompleteThis
          ; debugMsg(sProcName, "bCompleteThis=#True, aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
          closeCue(i)
          j = \nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubEnabled
              If aSub(j)\bSubTypeHasAuds
                k = aSub(j)\nFirstAudIndex
                While k >= 0
                  ; debugMsg(sProcName, aAud(k)\sAudLabel + " setting \nAudState (" + decodeCueState(aAud(k)\nAudState) + ") to SCS_CUE_COMPLETED")
                  ; debugMsg(sProcName, "calling endOfAud(" + getAudLabel(k) + ", " + decodeCueState(#SCS_CUE_COMPLETED) + ")")
                  endOfAud(k, #SCS_CUE_COMPLETED)
                  k = aAud(k)\nNextAudIndex
                Wend
              EndIf
              ; debugMsg(sProcName, "calling endOfSub(" + getSubLabel(j) + ", #SCS_CUE_COMPLETED)")
              endOfSub(j, #SCS_CUE_COMPLETED)
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
          ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
          setCueState(i)
          updateScreenForCue(i)
        EndIf
        
      EndIf
    EndWith
  Next i

  ; close any later memo cues that are currently playing
  For i = pCuePtr+1 To gnLastCue
    With aCue(i)
      If ((\nActivationMethod & #SCS_ACMETH_EXT_BIT) = 0) And ((\nActivationMethod & #SCS_ACMETH_HK_BIT) = 0)
        ; added above test 20Sep2016 11.5.2.1 following report from Richard Borsey where a 'GoTo Cue' cancelled a displayed Memo Cue that had been triggered by external MIDI
        bCallResetCueState = #False
        If \bSubTypeE
          j = \nFirstSubIndex
          While j >= 0
            bCloseThisSub = #False
            If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
              If aSub(j)\bSubTypeE
                bCloseThisSub = #True
              EndIf
            EndIf
            If bCloseThisSub
              ; debugMsg(sProcName, "(memo) calling stopSub(" + getSubLabel(j) + ", 'E', #False, #False)")
              stopSub(j, "E", #False, #False)
              ; debugMsg(sProcName, "(memo) calling endOfSub(" + getSubLabel(j) + ", #SCS_CUE_NOT_LOADED)")
              endOfSub(j, #SCS_CUE_NOT_LOADED)
              bCallResetCueState = #True
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      EndIf
    EndWith
    If bCallResetCueState
      ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
      setCueState(i)
      updateScreenForCue(i)
    EndIf
  Next i
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      If grvMixInfo\nMaxInputKeyToRemoveWhenvMixIdle >= 0
        vMix_RemoveRequestedInputs(#False)
      EndIf
    EndIf
  CompilerEndIf
  
  ; 2May2017 11.6.1ax added test 'If gbInLoadCueFile = #False' following email from Lluis Vilarrasa 28Apr2017 regarding cues with activation method 'after load' not auto-starting if the cue
  ; file was not the first cue file loaded. This was due actions that occur inside this procedure (GoToCue()), which is not called during initialisation but is called in subsequent loads.
  ; The activation method 'after load' is changed to 'manual' in resetInitialStateOfCue(), so this must be bypassed when loading a new cue file.
  If gbInLoadCueFile = #False
    ; reset initial state of this and any later 'complete' cues
    For i = pCuePtr To gnLastCue
      If aCue(i)\nCueState <> #SCS_CUE_READY ; test added 2Nov2018 11.8.0an
        ; debugMsg(sProcName, "calling resetInitialStateOfCue(" + getCueLabel(i) + ", " + getCueLabel(pCuePtr) + "), \nCueState=" + decodeCueState(aCue(i)\nCueState))
        resetInitialStateOfCue(i, pCuePtr)
      EndIf
    Next i
    ; debugMsg(sProcName, "calling resetAllActivationMethodReqdEtc()")
    resetAllActivationMethodReqdEtc()
  EndIf
  
  ; added 23Mar2019 11.8.0.2ck to fix a problem in a test of Ryan Rohrer's cue file where clicking on Q9 cause Q8.5 to start because Q8.5 was set to auto-start after the end of Q8,
  ; where Q8 was before Q9 but Q8.5 was later in the cue list.
  For i = pCuePtr+1 To gnLastCue
    With aCue(i)
      If \bCueEnabled
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState) + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod))
        If (\nCueState <= #SCS_CUE_READY) And (\nActivationMethod = #SCS_ACMETH_AUTO)
          If \nAutoActCuePtr >= 0
            ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) + ", aCue(" + getCueLabel(\nAutoActCuePtr) + ")\nCueState=" + decodeCueState(aCue(\nAutoActCuePtr)\nCueState) +
            ;                     ", aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
            If aCue(\nAutoActCuePtr)\nCueState = #SCS_CUE_COMPLETED
              If \nActivationMethodReqd <> #SCS_ACMETH_MAN
                ; debugMsg(sProcName, "setting aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeCueState(#SCS_ACMETH_MAN))
                \nActivationMethodReqd = #SCS_ACMETH_MAN
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next i
  ; added 23Mar2019 11.8.0.2ck
  
  ; debugMsg(sProcName, "calling setTimeBasedCues()")
  setTimeBasedCues()

  If aCue(pCuePtr)\nActivationMethodReqd = #SCS_ACMETH_TIME ; modified 25Aug2016 11.5.2
    gqStopEverythingTime = 0
  EndIf
  
  ; debugMsg(sProcName, "calling resetGaplessFirstAudPtrsIfReqd()")
  resetGaplessFirstAudPtrsIfReqd()
  
  ; debugMsg(sProcName, "calling ONC_openNextCues(" + getCueLabel(pCuePtr) + ", -1, " + getCueLabel(pCuePtr) + ", #True, " + strB(bSetCueToGo) + ", -1, " + strB(bApplyDefaultGridClickAction) + ")")
  ONC_openNextCues(pCuePtr, -1, pCuePtr, #True, bSetCueToGo, -1, bApplyDefaultGridClickAction)
  
  If (pCuePtr > 0) And (pCuePtr <= gnLastCue)
    If (aCue(pCuePtr)\bHotkey = #False) And (aCue(pCuePtr)\bExtAct = #False) And (aCue(pCuePtr)\bCallableCue = #False)
      With grDispControl
        \nCuePtr = pCuePtr
        \nSubPtr = aCue(pCuePtr)\nFirstSubIndex
        \nAudPtr = -1
        \nSubNo = 0
        \nPlayNo = 0
        \bUseNext = #False
      EndWith
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  If bSetCueToGo
    ; debugMsg(sProcName, "calling setCueToGo(#True, -1, #False, " + strB(bApplyDefaultGridClickAction) + ")")
    setCueToGo(#True, -1, #False, bApplyDefaultGridClickAction)
    gnHighlightedCue = pCuePtr
    gnHighlightedRow = aCue(pCuePtr)\nGrdCuesRowNo
    ; debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow)
  Else
    ; debugMsg(sProcName, "calling setCueToGo(#False, -1, #False, " + strB(bApplyDefaultGridClickAction) + ")")
    setCueToGo(#False, -1, #False, bApplyDefaultGridClickAction)
  EndIf
  gbCallSetGoButton = #True
  
;   debugMsg(sProcName, "calling listCueStates(" + getCueLabel(pCuePtr) + ")")
;   listCueStates(pCuePtr)
  
  ; debugMsg(sProcName, "calling updateGrid(" + pCuePtr + ")")
  updateGrid(pCuePtr)
  
  ; debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue))

  If gnThreadNo = #SCS_THREAD_MAIN
    ; reinstate previous redraw state for grdCues
    setGrdCuesRedrawState(bRedrawState)
    setMouseCursorNormal()
    setGoButton()
    If gbLoadingCueFile = #False
      sendRAICurrCueAndNextCue(bHideNetworkTracing)
    EndIf
  EndIf
  
  If bWarningDisplayed
    samAddRequest(#SCS_SAM_HIDE_WARNING_MSG)  ; hide warning message
  EndIf
  
  grDMX\bLoadPreCueDMXValuesIfReqd = #True
  gbInGoToCue = #False
  
  UnlockCueListMutex()

  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    Select pCuePtr
      Case gnCueEnd
        FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_GO_TO_END)
      Default
        FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_GO_TO_CUE, pCuePtr)
    EndSelect
  EndIf
 
  If grM2T\bM2TCueListColoringApplied
    M2T_clearCueInds()
    colorCueListEntries()
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure callSubr(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected bLockedMutex

  debugMsg(sProcName, #SCS_START)

  LockCueListMutex(35)

  debugMsg(sProcName, "calling ONC_openNextCues(" + getCueLabel(pCuePtr) + ", -1, " + getCueLabel(pCuePtr) + ", #True)")
  ONC_openNextCues(pCuePtr, -1, pCuePtr, #True)
  
  If (pCuePtr > 0) And (pCuePtr <= gnLastCue)
    If (aCue(pCuePtr)\bHotkey = #False) And (aCue(pCuePtr)\bExtAct = #False) And (aCue(pCuePtr)\bCallableCue = #False)
      With grDispControl
        \nCuePtr = pCuePtr
        \nSubPtr = aCue(pCuePtr)\nFirstSubIndex
        \nAudPtr = -1
        \nSubNo = 0
        \nPlayNo = 0
        \bUseNext = #False
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
;   debugMsg(sProcName, "calling setCueToGo(#False)")
;   setCueToGo(#False)
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  gbCallSetGoButton = #True
  
  debugMsg(sProcName, "calling updateGrid(" + pCuePtr + ")")
  updateGrid(pCuePtr)
  
  debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue))

  UnlockCueListMutex()

;   debugMsg(sProcName, "calling listCueStates(" + getCueLabel(pCuePtr) + ")")
;   listCueStates(pCuePtr)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure resetRelatedCueActivationMethodReqd(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected i
  
  ; debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If i <> pCuePtr
      With aCue(i)
        If (\nActivationMethod = #SCS_ACMETH_AUTO) Or (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
          If \nAutoActPosn <> #SCS_ACPOSN_LOAD And \bCueEnabled ; Added \bCueEnabled 3Jun2024 11.10.3ag
            If \nAutoActCuePtr = pCuePtr
              If \nActivationMethodReqd <> \nActivationMethod
                debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\nActivationMethodReqd from " + decodeActivationMethod(\nActivationMethodReqd) + " to " + decodeActivationMethod(\nActivationMethod))
                \nActivationMethodReqd = \nActivationMethod
              EndIf
              debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bAutoStartLocked=" + strB(\bAutoStartLocked) + ", \bHoldAutoStart=" + strB(\bHoldAutoStart))
              If \bAutoStartLocked
                ; debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\bAutoStartLocked from #True to #False")
                \bAutoStartLocked = #False
                debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bAutoStartLocked=" + strB(\bAutoStartLocked))
                ; Added 3Jun2024 11.10.3ag
                If \nCueState >= #SCS_CUE_COMPLETED
                  samAddRequest(#SCS_SAM_LOAD_ONE_CUE, i)
                EndIf
                ; End added 3Jun2024 11.10.3ag
              EndIf
              If \bHoldAutoStart
                debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\bHoldAutoStart from #True to #False")
                \bHoldAutoStart = #False
              EndIf
            EndIf
          EndIf
        EndIf
      EndWith
    EndIf
  Next i
  
  With aCue(pCuePtr)
    If \nActivationMethodReqd <> \nActivationMethod
      If \nActivationMethod = #SCS_ACMETH_TIME
        debugMsg(sProcName, "calling setTimeBasedCues(" + getCueLabel(pCuePtr) + ")")
        setTimeBasedCues(pCuePtr)
      Else
        debugMsg(sProcName, "changing aCue(" + getCueLabel(pCuePtr) + ")\nActivationMethodReqd from " + decodeActivationMethod(\nActivationMethodReqd) + " to " + decodeActivationMethod(\nActivationMethod))
        \nActivationMethodReqd = \nActivationMethod
      EndIf
    EndIf
    If \bHoldAutoStart
      debugMsg(sProcName, "changing aCue(" + getCueLabel(pCuePtr) + ")\bHoldAutoStart from #True to #False")
      \bHoldAutoStart = #False
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure goToCueNonLinear(pCuePtr, bSetCueToGo=#True, bResettingStepHotkeys=#False)
  ; NOTE: Also called by resetStepHotkeys() as this needs identical processing (with bSetCueToGo=#False, bResettingStepHotkeys=#True)
  PROCNAMECQ(pCuePtr)
  Protected d, i, j, k
  Protected bCompleteThis, nCueRow
  Protected bStandbyThis
  Protected nRow, sActivation.s
  Protected bRedrawState
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START + ", bSetCueToGo=" + strB(bSetCueToGo) + ", bResettingStepHotkeys=" + strB(bResettingStepHotkeys))
  
  If bResettingStepHotkeys = #False
    gnNonLinearCue = pCuePtr
    gnDependencyCue = pCuePtr
  EndIf
  If pCuePtr <= 0
    ProcedureReturn
  EndIf
  
  LockCueListMutex(3101)
  
  WMN_disableGoButtons()
  setMouseCursorBusy()
  
  ; turn off grdCues redrawing until 'GoToCue' has finished as several cues may be redrawn during this procedure
  bRedrawState = getGrdCuesRedrawState()
  setGrdCuesRedrawState(#False)
  
  If bSetCueToGo
    gnHighlightedCue = -1
    gnHighlightedRow = -1
    debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow)
  EndIf
  nCueRow = aCue(pCuePtr)\nGrdCuesRowNo  

  If aCue(pCuePtr)\nCueState = #SCS_CUE_NOT_LOADED Or aCue(pCuePtr)\nCueState >= #SCS_CUE_COMPLETED
    debugMsg(sProcName, "calling loadOneCue(" + pCuePtr + ")")
    loadOneCue(pCuePtr)
  EndIf

  ; reset initial state of this cue
  i = pCuePtr
  
  With aCue(i)
    nRow = \nGrdCuesRowNo
    setInitCueStates(i, pCuePtr, #True, #True, #True)
    If (\nCueState < #SCS_CUE_FADING_IN) Or (\nCueState > #SCS_CUE_FADING_OUT)
      If \nAutoActPosn = #SCS_ACPOSN_LOAD
        ; \nActivationMethodReqd = \nActivationMethod
        \nActivationMethodReqd = #SCS_ACMETH_MAN
        debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
      Else
        If \nAutoActCueSelType = #SCS_ACCUESEL_PREV
          setCuePtrForAutoStartPrevCueType(i)
        EndIf
        If (\nActivationMethod = #SCS_ACMETH_AUTO) And (\nAutoActCuePtr < pCuePtr)
          \nActivationMethodReqd = #SCS_ACMETH_MAN
          debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
        ElseIf (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF) And (\nAutoActCuePtr < pCuePtr)
          \nActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF
        Else
          \nActivationMethodReqd = \nActivationMethod
        EndIf
      EndIf
      
      sActivation = getCueActivationMethodForDisplay(i)
      WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_AC, sActivation)
      
      j = \nFirstSubIndex
      While j >= 0
        
        If aSub(j)\bSubTypeHasAuds
          aSub(j)\nSubPosition = 0
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            aAud(k)\nRelFilePos = aAud(k)\nRelStartAt
            aAud(k)\nCuePos = 0
            aAud(k)\nTotalTimeOnPause = 0
            aAud(k)\nPriorTimeOnPause = 0
            aAud(k)\nPreFadeInTimeOnPause = 0
            aAud(k)\nPreFadeOutTimeOnPause = 0
            aAud(k)\nCuePosAtLoopStart = 0
            aAud(k)\nCuePosWhenLastChecked = 0
            k = aAud(k)\nNextAudIndex
            If aSub(j)\bSubTypeAorP
              If aSub(j)\nFirstPlayIndexThisRun >= 0
                aSub(j)\nCurrPlayIndex = aSub(j)\nFirstPlayIndexThisRun
              Else
                aSub(j)\nCurrPlayIndex = aSub(j)\nFirstPlayIndex
              EndIf
              debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nCurrPlayIndex=" + getAudLabel(aSub(j)\nCurrPlayIndex) + ", \nFirstPlayIndexThisRun=" + getAudLabel(aSub(j)\nFirstPlayIndexThisRun))
              aSub(j)\bPLTerminating = #False
              debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bPLTerminating=" + strB(aSub(j)\bPLTerminating))
              aSub(j)\bPLFadingIn = #False
              aSub(j)\bPLFadingOut = #False
            EndIf
          Wend
          
        ElseIf aSub(j)\bSubTypeE
          aSub(j)\nSubPosition = 0
          
        ElseIf aSub(j)\bSubTypeK
          aSub(j)\nSubPosition = 0
          
        ElseIf aSub(j)\bSubTypeL
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            aSub(j)\nLCPosition[d] = 0
          Next d
          aSub(j)\nLCPositionMax = 0
          
        ElseIf aSub(j)\bSubTypeM
          aSub(j)\nSubPosition = 0
          
        ElseIf aSub(j)\bSubTypeU
          aSub(j)\nSubPosition = 0
          
        EndIf
        
        aSub(j)\bTimeSubStartedSet = #False
        aSub(j)\bPLRepeatCancelled = #False
        j = aSub(j)\nNextSubIndex
      Wend
      \qTimeCueStarted = 0
      \bTimeCueStartedSet = #False
      \qTimeCueStopped = 0
      \bTimeCueStoppedSet = #False
      \bCueStoppedByStopEverything = #False
      \bCueStoppedByGoToCue = #False
      debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bTimeCueStoppedSet=" + strB(\bTimeCueStoppedSet))
      
    EndIf
    
    ; the following code from updateGrid
    setCueState(i)
    WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_CS, getCueStateForGrid(i))
    ; end of code from updateGrid
    
  EndWith

  resetRelatedCueActivationMethodReqd(pCuePtr)
  
  setTimeBasedCues()

  If aCue(pCuePtr)\nActivationMethodReqd = #SCS_ACMETH_TIME
    gqStopEverythingTime = 0
  EndIf

  ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  If bSetCueToGo
    debugMsg(sProcName, "calling setCueToGo()")
    setCueToGo()
    gnHighlightedCue = pCuePtr
    gnHighlightedRow = aCue(pCuePtr)\nGrdCuesRowNo
    debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow)
  EndIf
  updateGrid(pCuePtr)
  
  If bResettingStepHotkeys = #False
    gnDependencyCue = -1
  EndIf
  
  ; reinstate previous redraw state for grdCues
  setGrdCuesRedrawState(bRedrawState)
  
  setMouseCursorNormal()
  
  UnlockCueListMutex()
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure goToCueLabel(sCue.s, bSetCueToGo=#True)
  PROCNAMEC()
  Protected i, nCuePtr

  debugMsg(sProcName, #SCS_START)

  nCuePtr = -1
  For i = 1 To gnLastCue
    If (aCue(i)\sCue = sCue) And (aCue(i)\bCueCurrentlyEnabled)
      nCuePtr = i
      Break
    EndIf
  Next i

  If (nCuePtr > 0) And (nCuePtr <= gnLastCue)
    debugMsg(sProcName, "calling GoToCue(" + getCueLabel(nCuePtr) + ")")
    GoToCue(nCuePtr, bSetCueToGo)
  EndIf

  ProcedureReturn nCuePtr

EndProcedure

Procedure standbyGoClicked()
  PROCNAMECQ(gnStandbyCuePtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If gnStandbyCuePtr > 0
    setGlobalTimeNow()
    debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(gnStandbyCuePtr) + ")")
    playCueViaCas(gnStandbyCuePtr)
    debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
    gbCallLoadDispPanels = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure stayAwake(sMessage.s)
  ; PROCNAMEC()
  Protected nFile, nMyTime, sMyTime.s

  If Len(grMain\sStayAwakeFile) = 0
    grMain\sStayAwakeFile = GetTemporaryDirectory() + "scs_temp.txt"
    nFile = CreateFile(#PB_Any, grMain\sStayAwakeFile)
    
  ElseIf grMain\nStayAwakeLines > 2500
    grMain\nStayAwakeLines = 0
    nFile = CreateFile(#PB_Any, grMain\sStayAwakeFile)
    
  Else
    nFile = OpenFile(#PB_Any, grMain\sStayAwakeFile)
    If nFile <> 0
      FileSeek(nFile, Lof(nFile))
    EndIf
  EndIf
  grMain\nStayAwakeLines + 1
  nMyTime = gqTimeNow - gqStartTime
  sMyTime = Str(nMyTime)
  ; debugMsg(sProcName, "nFile=" + nFile + ", sMyTime=" + sMyTime)
  If nFile
    WriteStringN(nFile,sMyTime + "  " + sMessage)
    CloseFile(nFile)
  EndIf
EndProcedure

Procedure MouseDown(nMouseButton)
  PROCNAMEC()
  debugMsg(sProcName, "nMouseButton=" + nMouseButton)
  If (nMouseButton = 2) And (gbSystemLocked = #False)
    MouseRightClick()
  EndIf
EndProcedure

Procedure MouseRightClick()
  PROCNAMEC()
  Protected qTimeNow.q
  Protected nExclusiveCuePtr
  Protected sMsg.s
  Protected bGoEnabled
  
  debugMsg(sProcName, #SCS_START)
  
  ; bGoEnabled = getToolBarBtnEnabled(#SCS_TBMB_GO)
  bGoEnabled = WMN_isGoEnabled()
  debugMsg(sProcName, "bGoEnabled=" + strB(bGoEnabled))
  If bGoEnabled
    If grGeneralOptions\bDisableRightClickAsGo = #False
      qTimeNow = ElapsedMilliseconds()
      debugMsg(sProcName, "qTimeNow=" + traceTime(qTimeNow) + ", gqTimeMouseClicked=" + traceTime(gqTimeMouseClicked))
      If (qTimeNow - gqTimeMouseClicked) >= grGeneralOptions\nDoubleClickTime
        goClicked()
        gqTimeMouseClicked = qTimeNow ; do NOT update gqTimeMouseClicked before calling goClicked()
      Else
        sMsg = LangPars("WMN", "DoubleClick", StrF((gqTimeNow - gqTimeMouseClicked) / 1000, 3), StrF((grGeneralOptions\nDoubleClickTime) / 1000, 3))
        WMN_setStatusField(sMsg, #SCS_STATUS_WARN, 3000)
      EndIf
    EndIf
  Else
    If grGeneralOptions\bDisableRightClickAsGo = #False
      nExclusiveCuePtr = checkExclusiveCuePlaying()
      If nExclusiveCuePtr >= 0
        If grGeneralOptions\bCtrlOverridesExclCue
          sMsg = LangPars("WMN", "ExclCueRun3", aCue(nExclusiveCuePtr)\sCue)   ; "'Go' button disabled because exclusive cue $1 is currently playing, but..."
        Else
          sMsg = LangPars("WMN", "ExclCueRun2", aCue(nExclusiveCuePtr)\sCue)   ; "'Go' button disabled because exclusive cue $1 is currently playing"
        EndIf
        WMN_setStatusField(sMsg, #SCS_STATUS_ERROR)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure highlightLine(pCuePtr, pCallLine=0)
  PROCNAMECQ(pCuePtr)
  Protected sMsg.s
  Protected nRowNo
  
  If pCallLine
    debugMsg(sProcName, #SCS_START + ", pCallLine=" + pCallLine + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnPrevHighlightedCue=" + getCueLabel(gnPrevHighlightedCue))
  EndIf
  
  If gnThreadNo > #SCS_THREAD_MAIN
    gnCueToHighlight = pCuePtr
    gqMainThreadRequest | #SCS_MTH_HIGHLIGHT_LINE
    ProcedureReturn
  EndIf
  
  If pCuePtr < 0
    ; may be due to gnCueToHighlight having being 'cleared' before main thread request #SCS_MTH_HIGHLIGHT_LINE was processed (see comments below against "gnCueToHighlight = -1")
    ProcedureReturn
  EndIf
  
  gnCueToHighlight = -1 ; added 29Mar2022 11.9.1au: effectively clears any outstanding main thread request #SCS_MTH_HIGHLIGHT_LINE, in case highlightLine() is called directly before #SCS_MTH_HIGHLIGHT_LINE is processed (bug reported by Scott Seigwald)
  gnHighlightedCue = pCuePtr
  gnHighlightedRow = aCue(pCuePtr)\nGrdCuesRowNo
  ; debugMsg(sProcName, "gnHighlightedCue=" + getCueLabel(gnHighlightedCue) + ", gnHighlightedRow=" + gnHighlightedRow)
  If (gnHighlightedRow >= 0) And (gnHighlightedRow < CountGadgetItems(WMN\grdCues))
    If gnPrevHighlightedCue <> pCuePtr
      If (gnPrevHighlightedCue > 0) And (gnPrevHighlightedCue <= gnCueEnd)
        ; debugMsg(sProcName, "calling colorLine(" + getCueLabel(gnPrevHighlightedCue) + ")")
        colorLine(gnPrevHighlightedCue)
        If gnPrevHighlightedCue < gnCueEnd
          With aCue(gnPrevHighlightedCue)
            If \nCueState = #SCS_CUE_ERROR
              sMsg = \sCue + ": " + \sErrorMsg
              WMN_setStatusField(sMsg, #SCS_STATUS_ERROR, 0, #True)
            ElseIf \nCueState = #SCS_CUE_READY
              nRowNo = \nGrdCuesRowNo
              If (nRowNo >= 0) And (nRowNo < CountGadgetItems(WMN\grdCues))
                debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRowNo + ", #SCS_GRDCUES_CS, " + getCueStateForGrid(gnPrevHighlightedCue) + ") for " + \sCue)
                WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CS, getCueStateForGrid(gnPrevHighlightedCue))
              EndIf
            EndIf
          EndWith
        EndIf
      EndIf
    EndIf
  EndIf
  
  If grOperModeOptions(gnOperMode)\bHideCueList = #False
    getGridRowInfo(WMN\grdCues)
    
    WMN_setToolbarButtons()
    
    debugMsg(sProcName, "gnHighlightedRow=" + gnHighlightedRow + ", grGridRowInfo\nSelectedRow=" + grGridRowInfo\nSelectedRow + ", GGS(WMN\grdCues)=" + GGS(WMN\grdCues))
    If gnHighlightedRow <> grGridRowInfo\nSelectedRow
      ; row is not currently selected, so select this line
      SGS(WMN\grdCues, -1)
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, "calling colorLine(" + getCueLabel(pCuePtr) + ")")
  colorLine(pCuePtr)
  
  gnPrevHighlightedCue = pCuePtr
  gnPrevHighlightedRow = aCue(pCuePtr)\nGrdCuesRowNo
  
  If gnHighlightedCue < gnCueEnd
    With aCue(gnHighlightedCue)
      If \nCueState = #SCS_CUE_ERROR
        sMsg = \sCue + ": " + \sErrorMsg
        WMN_setStatusField(sMsg, #SCS_STATUS_ERROR, 0, #True)
      ElseIf \nCueState = #SCS_CUE_READY
        nRowNo = \nGrdCuesRowNo
        If (nRowNo >= 0) And (nRowNo < CountGadgetItems(WMN\grdCues))
          debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRowNo + ", #SCS_GRDCUES_CS, " + getCueStateForGrid(gnHighlightedCue) + ") for " + \sCue)
          WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CS, getCueStateForGrid(gnHighlightedCue))
        EndIf
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Macro updDeviceField()
  If sThisDev
    If Len(sDevice) = 0
      sDevice = sThisDev
    Else
      If sThisDev <> sDevice
        sPlus = "+"
      EndIf
    EndIf
  EndIf
EndMacro

Procedure loadGridRow(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected rCue.tyCue
  Protected sCue.s
  Protected sCueType.s, sActivation.s, sFileName.s
  Protected sLength.s, sFileType.s, sDevice.s, sLevel.s
  Protected bRedrawState, nSubPtr
  Protected nRowNo
  Protected d, j, k, n, nImageNo
  Protected sInputLogicalDev.s
  Protected sSuffix.s
  Protected bMute
  
  ; debugMsg(sProcName, #SCS_START)

  If gbInDisplayCue Or gbInDisplaySub Or gbClosingDown
    debugMsg(sProcName, "exiting - gbInDisplayCue=" + strB(gbInDisplayCue) + ", gbInDisplaySub=" + strB(gbInDisplaySub) + ", gbClosingDown=" + strB(gbClosingDown))
    ProcedureReturn
  EndIf
  
  ; ASSERT_THREAD(#SCS_THREAD_MAIN)
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_LOAD_GRID_ROW, pCuePtr)
    ProcedureReturn
  EndIf
  
  nRowNo = aCue(pCuePtr)\nGrdCuesRowNo
  If nRowNo < 0
    debugMsg(sProcName, "exiting - nRowNo=" + nRowNo)
    ProcedureReturn
  EndIf
  
  rCue = aCue(pCuePtr)
  
  ; debugMsg(sProcName, "\sCue=" + rCue\sCue + ", \nFirstSubIndex=" + rCue\nFirstSubIndex + ", \sCueDescr=" + rCue\sCueDescr)
  
  ; cue
  sCue = rCue\sCue
  nSubPtr = rCue\nFirstSubIndex
  
  ; Added 19Aug2024 11.10.3bi following test of "U3A 2024 RPAC Show.scs11" where the first sub-cue of Q3 was disabled
  While #True
    ; Look for first enabled sub-cue in this cue
    If nSubPtr >= 0
      If aSub(nSubPtr)\bSubEnabled
        Break
      EndIf
      nSubPtr = aSub(nSubPtr)\nNextSubIndex
    Else
      ; End of loop and no enabled subs found
      nSubPtr = rCue\nFirstSubIndex
      Break
    EndIf
  Wend
  ; End added 19Aug2024 11.10.3bi 
  
  If nSubPtr >= 0
    If aSub(nSubPtr)\nNextSubIndex >= 0
      sCue + "+"
    EndIf
    If rCue\bCueContainsGapless
      sCue + " " + #SCS_GAPLESS_MARKER
    EndIf
    If aSub(nSubPtr)\bSubTypeA
      bMute = aSub(nSubPtr)\bMuteVideoAudio
    EndIf
  EndIf
  
  ; cue type
  If nSubPtr >= 0
    sCueType = decodeSubTypeL(aSub(nSubPtr)\sSubType, nSubPtr)
    If rCue\bExclusiveCue
      sCueType + " *"
    EndIf
  EndIf
  
  ; activation method
  sActivation = getCueActivationMethodForDisplay(pCuePtr)
  ; debugMsg(sProcName, "sActivation=" + sActivation)
  
  ; file/info, ie file name or other info, such as lighting cue info
  sFileName = getSubFileNameForGrid(nSubPtr)
  ; added 24Mar2020 11.8.2.3af primarily for unsupported vMix VideoLists
  If rCue\nCueState = #SCS_CUE_ERROR And rCue\sErrorMsg
    If sFileName
      sFileName + " (" + rCue\sErrorMsg + ")"
    Else
      sFileName = rCue\sErrorMsg
    EndIf
  EndIf
  ; end added 24Mar2020 11.8.2.3af
  ; debugMsg(sProcName, "sFileName=" + sFileName)
  
  ; length
  sLength = getLengthForGrid(pCuePtr)
  ; debugMsg(sProcName, "sLength=" + sLength)
  
  ; file type
  sFileType = getSubFileTypeForGrid(nSubPtr)
  ; debugMsg(sProcName, "sFileType=" + sFileType)
  
  ; level
  sLevel = getSubDBLevelForGrid(nSubPtr)
  If sLevel
    sLevel + "dB"
  EndIf
  ; debugMsg(sProcName, "sLevel=" + sLevel)
  
  ; device
  sDevice = loadDevInfoForSub(nSubPtr, #True)
  
  With rCue
    ; debugMsg(sProcName, "nRow=" + nRowNo + ", sCue=" + sCue + ", \sCueDescr=" + \sCueDescr + ", \nCueState=" + decodeCueState(\nCueState) + ", sActivation=" + sActivation + ", sFileName=" + sFileName + ", sLength=" + sLength)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CU, sCue)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_PG, \sPageNo)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_DE, \sCueDescr)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CT, sCueType)
    ; debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRowNo + ", #SCS_GRDCUES_CS, " + getCueStateForGrid(pCuePtr) + ") for " + \sCue)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CS, getCueStateForGrid(pCuePtr))
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_AC, sActivation)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_FN, sFileName)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_DU, sLength)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_SD, sDevice)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_WR, \sWhenReqd)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_MC, \sMidiCue)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_FT, sFileType)
    WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_LV, sLevel)
  EndWith
  
  ; Show cue icon at the start of each row in the first cell
  CompilerIf #c_show_icon_in_cue_grid
    ; Note: The PB function SetGadgetItemImage() requires a 16x16 image - see PB Help on ListIconGadget - AddGadgetItem().
    ; Unfortunately that results in the text being hard up against the RHS of the image.
    If nSubPtr >= 0
      nImageNo = IMG_getSubTypeImageHandle(nSubPtr, 16)
      If IsImage(nImageNo)
        SetGadgetItemImage(WMN\grdCues, nRowNo, ImageID(nImageNo))
      EndIf
    EndIf    
  CompilerEndIf
  
  colorLine(pCuePtr)
  
  aCue(pCuePtr)\bCallLoadGridRow = #False
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadGridRowsWhereRequested()
  PROCNAMEC()
  Protected i
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\bCallLoadGridRow
      ; debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(i) + ")")
      loadGridRow(i)
    EndIf
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s getHotkeyFromHotkeyNr(nHotkeyNr)
  Protected sHotkey.s
  
  sHotkey = StringField(gsValidHotkeys, nHotkeyNr, ",")
  ProcedureReturn sHotkey

EndProcedure

Procedure getHotkeyBank(sHotkey.s)
  Protected nDotPtr, sHotkeyBank.s
  Protected nBankIndex
  
  nDotPtr = FindString(sHotkey, ".")
  
  If sHotkeyBank
    sHotkeyBank = Left(sHotkey, nDotPtr-1)
    nBankIndex = FindString("*ABDEFGHIJKLMNOPQRSTUVWXYZ", sHotkeyBank) - 1
  EndIf
  ProcedureReturn nBankIndex
EndProcedure

Procedure loadCurrHotkeys()
  PROCNAMEC()
  Protected n, sLine.s, bTrace
  
  debugMsgC(sProcName, #SCS_START + ", grProd\nCurrHotkeyBank=" + grProd\nCurrHotkeyBank)
  
  gnMaxCurrHotkey = -1
  For n = 0 To gnMaxHotkey
    If gaHotkeys(n)\nHotkeyBank = grProd\nCurrHotkeyBank
      If gaHotkeys(n)\nCuePtr >= 0
        gnMaxCurrHotkey + 1
        If gnMaxCurrHotkey > ArraySize(gaCurrHotkeys())
          ReDim gaCurrHotkeys(gnMaxCurrHotkey + 10)
        EndIf
        gaCurrHotkeys(gnMaxCurrHotkey) = gaHotkeys(n)
        If bTrace
          With gaCurrHotkeys(gnMaxCurrHotkey)
            sLine = "gaCurrHotkeys(" + gnMaxCurrHotkey + ")\sHotkey=" + \sHotkey + ", \nHKShortcut=" + \nHKShortcut + ", \nHKShortcutVK=" + \nHKShortcutVK + ", \nCuePtr=" + getCueLabel(\nCuePtr) + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod)
            sLine + ", \nHotkeyNr=" + \nHotkeyNr
            If \nActivationMethod = #SCS_ACMETH_HK_STEP
              sLine + ", \nHotkeyStepNo=" + \nHotkeyStepNo
            EndIf
            debugMsg(sProcName, sLine)
          EndWith
        EndIf
      EndIf
    EndIf
  Next n
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure saveCurrHotkeyInfo(nCurrHotkeyPtr)
  PROCNAMEC()
  Protected n, bFound
  
  debugMsg(sProcName, #SCS_START + ", nCurrHotkeyPtr=" + nCurrHotkeyPtr)
  
  If nCurrHotkeyPtr >= 0
    For n = 0 To gnMaxHotkey
      If gaHotkeys(n)\nHotkeyBank = grProd\nCurrHotkeyBank
        If gaHotkeys(n)\sHotkey = gaCurrHotkeys(nCurrHotkeyPtr)\sHotkey And gaHotkeys(n)\nHotkeyStepNo = gaCurrHotkeys(nCurrHotkeyPtr)\nHotkeyStepNo
          gaHotkeys(n) = gaCurrHotkeys(nCurrHotkeyPtr)
          debugMsg(sProcName, "gaCurrHotkeys(" + nCurrHotkeyPtr + ") saved To gaHotkeys(" + n + ")")
          bFound = #True
          Break
        EndIf
      EndIf
    Next n
    If bFound = #False
      gnMaxHotkey + 1
      If gnMaxHotkey > ArraySize(gaHotkeys())
        ReDim gaHotkeys(gnMaxHotkey + 10)
      EndIf
      gaHotkeys(gnMaxHotkey) = gaCurrHotkeys(nCurrHotkeyPtr)
      debugMsg(sProcName, "gaCurrHotkeys(" + nCurrHotkeyPtr + ") saved To gaHotkeys(" + gnMaxHotkey + ") (new entry)")
    EndIf
  EndIf
    
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setHotkeyBank(nSelectedBankIndex)
  PROCNAMEC()
  Protected n, nKeyIndex
  
  debugMsg(sProcName, #SCS_START + ", nSelectedBankIndex=" + nSelectedBankIndex)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_SET_HOTKEY_BANK, nSelectedBankIndex)
    ProcedureReturn
  EndIf

  For nKeyIndex = 0 To gnMaxCurrHotkey
    With gaCurrHotkeys(nKeyIndex)
      If \nCuePtr >= 0
        If (\nHotkeyBank > 0) And (\nHotkeyBank <> nSelectedBankIndex)
          Select \nActivationMethod
            Case #SCS_ACMETH_HK_TOGGLE
              If \nToggleState <> 0
                ; hotkey (toggle) activation method, so fade out / stop cue IF cue is currently playing
                \nToggleState ! 1   ; flip toggle state for this hotkey
                ; Debug sProcName + "gaCurrHotkeys(" + nKeyIndex + ")\nToggleState=" + gaCurrHotkeys(nKeyIndex)\nToggleState
                debugMsg(sProcName, "calling saveCurrHotkeyInfo(" + nKeyIndex + ")")
                saveCurrHotkeyInfo(nKeyIndex)
                If (aCue(\nCuePtr)\bSubTypeAorP) Or (aCue(\nCuePtr)\bSubTypeF) Or (aCue(\nCuePtr)\bSubTypeI)
                  fadeOutCue(\nCuePtr, #False)
                EndIf
              EndIf
              
            Case #SCS_ACMETH_HK_NOTE
              If (aCue(\nCuePtr)\nCueState < #SCS_CUE_FADING_IN) Or (aCue(\nCuePtr)\nCueState > #SCS_CUE_FADING_OUT)
                ; no action
              Else
                If (aCue(\nCuePtr)\bSubTypeAorP) Or (aCue(\nCuePtr)\bSubTypeF) Or (aCue(\nCuePtr)\bSubTypeI)
                  fadeOutCue(\nCuePtr, #False)
                EndIf
              EndIf
              
          EndSelect
        EndIf
      EndIf
    EndWith
  Next nKeyIndex

  gnNoteHotkeyCuesPlaying = countNoteHotkeysPlaying()
  
  grProd\nCurrHotkeyBank = nSelectedBankIndex
  
  WMN_displayOrHideHotkeys()  ; includes call to loadCurrHotkeys()
  
  If IsWindow(#WMN)
    WMN_setKeyboardShortcuts()
  EndIf
  
  If IsMenu(#WMN_mnuNavigate)
    ; nb menu item #WMN_mnuHB_00 (n=0) is always selected so is omitted from the following loop
    For n = 1 To grLicInfo\nMaxHotkeyBank
      If n = grProd\nCurrHotkeyBank
        SetMenuItemState(#WMN_mnuNavigate, #WMN_mnuHB_00 + n, #True)
      Else
        SetMenuItemState(#WMN_mnuNavigate, #WMN_mnuHB_00 + n, #False)
      EndIf
    Next n
  EndIf

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getHotkeyNrForHotkey(sHotkey.s)
  Protected n, nHotkeyNr
  
  For nHotkeyNr = 1 To CountString(gsValidHotkeys, ",") + 1
    If StringField(gsValidHotkeys, nHotkeyNr, ",") = sHotkey
      Break
    EndIf
  Next nHotkeyNr
  ProcedureReturn nHotkeyNr
EndProcedure

Procedure loadHotkeyArray()
  ; Changed 15Nov2022 11.9.7af
  PROCNAMEC()
  Protected i, bHotkeysInUse, sLine.s, nCountHotkeys

  debugMsg(sProcName, #SCS_START)
  
  loadHotkeyStepNos() ; must be called before the following (sets aCue(i)nHotkeyStepNo fields)
  
  For i = 1 To gnLastCue
    If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED)
      If aCue(i)\bHotkey
        nCountHotkeys + 1
      EndIf
    EndIf
  Next i
  If nCountHotkeys > ArraySize(gaHotkeys())
    ReDim gaHotkeys(nCountHotkeys + 10)
  EndIf

  gnMaxHotkey = -1
  
  For i = 1 To gnLastCue
    If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED)
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\sHotkey=" + aCue(i)\sHotkey + ", \sHotkeyLabel=" + aCue(i)\sHotkeyLabel + ", \bHotkey=" + StrB(aCue(i)\bHotkey))
      If aCue(i)\bHotkey And aCue(i)\sHotkey
        debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\sHotkey=" + aCue(i)\sHotkey + ", \sHotkeyLabel=" + aCue(i)\sHotkeyLabel + ", \bHotkey=" + StrB(aCue(i)\bHotkey))
        gnMaxHotkey + 1
        gaHotkeys(gnMaxHotkey) = grHotkeyDef
        With gaHotkeys(gnMaxHotkey)
          \sHotkey = aCue(i)\sHotkey
          \nHotkeyNr = getHotkeyNrForHotkey(\sHotkey)
          \nHotkeyStepNo = aCue(i)\nCueHotkeyStepNo
          \sHotkeyLabel = aCue(i)\sHotkeyLabel
          \nCuePtr = i
          \sCue = aCue(i)\sCue
          \nActivationMethod = aCue(i)\nActivationMethod
          \nHotkeyBank = aCue(i)\nHotkeyBank ; Changed 15Nov2022 11.9.7af
          \nHKShortcut = getShortcutForKey(\sHotkey)
          \nHKShortcutVK = getShortcutVK(\nHKShortcut, @\nHKShortcutNumPadVK)
          \nHKShortcutVKUsed = 0
          \nHKSortKey = (\nHotkeyBank << 20) | (\nHotkeyNr << 16) | \nHotkeyStepNo
          sLine = "gaHotkeys(" + gnMaxHotkey + ")\nHotkeyBank=" + \nHotkeyBank + ", \sHotkey=" + \sHotkey + ", \nHKShortcut=" + \nHKShortcut + ", \nHKShortcutVK=" + \nHKShortcutVK + ", \nCuePtr=" + getCueLabel(\nCuePtr) + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod)
          If \nActivationMethod = #SCS_ACMETH_HK_STEP
            sLine + ", \nHotkeyStepNo=" + \nHotkeyStepNo
          EndIf
          sLine + ", \nHKSortKey=" + \nHKSortKey
          debugMsg(sProcName, sLine)
        EndWith
      EndIf
    EndIf
  Next i
  gbHotkeysInUse = bHotkeysInUse
  ; debugMsg(sProcName, "gbHotkeysInUse=" + strB(gbHotkeysInUse) + ", gnMaxHotkey=" + gnMaxHotkey)
  
  If gnMaxHotkey > 0
    SortStructuredArray(gaHotkeys(), #PB_Sort_Ascending, OffsetOf(tyHotkeys\nHKSortKey), #PB_Integer, 0, gnMaxHotkey)
  EndIf
  
  loadCurrHotkeys()
  
  If IsWindow(#WMN)
    WMN_setKeyboardShortcuts()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getCurrHotkeyPtrForCuePtr(pCuePtr)
  ; PROCNAMEC()
  Protected n, nCurrHotkeyPtr
  
  nCurrHotkeyPtr = -1
  For n = 0 To gnMaxCurrHotkey
    If gaCurrHotkeys(n)\nCuePtr = pCuePtr
      nCurrHotkeyPtr = n
      Break
    EndIf
  Next n
  ProcedureReturn nCurrHotkeyPtr
  
EndProcedure

Procedure getHotkeyPtrForHotkey(pHotkey.s)
  ; PROCNAMEC()
  Protected nBankIndex, nKeyIndex, nHotkeyPtr
  
  nHotkeyPtr = -1
  nBankIndex = 0
  For nKeyIndex = 0 To gnMaxHotkey
    If gaHotkeys(nKeyIndex)\nHotkeyBank = 0 And UCase(gaHotkeys(nKeyIndex)\sHotKey) = UCase(pHotkey)
      nHotkeyPtr = nKeyIndex
      Break
    EndIf
  Next nKeyIndex
  ProcedureReturn nHotkeyPtr
  
EndProcedure

Procedure getCurrHotkeyPtrForHotkey(pHotkey.s)
  ; PROCNAMEC()
  Protected nKeyIndex, nCurrHotkeyPtr
  
  nCurrHotkeyPtr = -1
  For nKeyIndex = 0 To gnMaxCurrHotkey
    If UCase(gaCurrHotkeys(nKeyIndex)\sHotKey) = UCase(pHotkey)
      nCurrHotkeyPtr = nKeyIndex
      Break
    EndIf
  Next nKeyIndex
  ProcedureReturn nCurrHotkeyPtr
  
EndProcedure

Procedure getCurrHotkeyPtrForHotkeyNr(pHotkeyNr)
  ; PROCNAMEC()
  Protected sHotKey.s, nKeyIndex, nCurrHotkeyPtr
  
  sHotKey = getHotkeyFromHotkeyNr(pHotkeyNr)
  nCurrHotkeyPtr = -1
  For nKeyIndex = 0 To gnMaxCurrHotkey
    If UCase(gaCurrHotkeys(nKeyIndex)\sHotKey) = UCase(sHotkey)
      nCurrHotkeyPtr = nKeyIndex
      Break
    EndIf
  Next nKeyIndex
  ProcedureReturn nCurrHotkeyPtr
  
EndProcedure

Procedure getCurrHotkeyPtrForVK(nVirtualKey.l)
  ; PROCNAMEC()
  Protected n, nCurrHotkeyPtr
  
  nCurrHotkeyPtr = -1
  If nVirtualKey <> 0
    For n = 0 To gnMaxCurrHotkey
      If gaCurrHotkeys(n)\nHKShortcutVK = nVirtualKey
        gaCurrHotkeys(n)\nHKShortcutVKUsed = nVirtualKey
        nCurrHotkeyPtr = n
        Break
      ElseIf gaCurrHotkeys(n)\nHKShortcutNumPadVK = nVirtualKey
        gaCurrHotkeys(n)\nHKShortcutVKUsed = nVirtualKey
        nCurrHotkeyPtr = n
        Break
      EndIf
    Next n
  EndIf
  ; debugMsg(sProcName, "nVirtualKey=$" + Hex(nVirtualKey) + ", returning " + nCurrHotkeyPtr)
  ProcedureReturn nCurrHotkeyPtr
  
EndProcedure

Procedure countNoteHotkeysPlaying()
  PROCNAMEC()
  Protected n, nCuePtr, nCount
  
  For n = 0 To ArraySize(gaCurrHotkeys())
    With gaCurrHotkeys(n)
      If \nActivationMethod = #SCS_ACMETH_HK_NOTE
        nCuePtr = \nCuePtr
        If nCuePtr >= 0
          debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nCueState=" + decodeCueState(aCue(nCuePtr)\nCueState))
          If (aCue(nCuePtr)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(nCuePtr)\nCueState <= #SCS_CUE_FADING_OUT)
            nCount + 1
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  ProcedureReturn nCount
EndProcedure

Procedure checkForNoteHotkeysReleased()
  PROCNAMEC()
  Protected n, nCuePtr, nCueState
  Protected nKeyState
  Protected bCountPlaying
  
  For n = 0 To ArraySize(gaCurrHotkeys())
    With gaCurrHotkeys(n)
      If (\nActivationMethod = #SCS_ACMETH_HK_NOTE) And (\bExternallyTriggered = #False)
        nCuePtr = \nCuePtr
        If nCuePtr >= 0
          nCueState = aCue(nCuePtr)\nCueState
          If (nCueState >= #SCS_CUE_FADING_IN) And (nCueState <= #SCS_CUE_FADING_OUT)
            nKeyState = GetAsyncKeyState_(\nHKShortcutVK)
            ; debugMsg(sProcName, "GetAsyncKeyState_($" + Hex(\nHKShortcutVK) + ") returned $" + Hex(nKeyState))
            If (nKeyState & $8000) = 0
              If \nHKShortcutNumPadVK > 0
                nKeyState = GetAsyncKeyState_(\nHKShortcutNumPadVK)
                ; debugMsg(sProcName, "GetAsyncKeyState_($" + Hex(\nHKShortcutNumPadVK) + ") returned $" + Hex(nKeyState))
              EndIf
            EndIf
            If (nKeyState & $8000) = 0
              ; key has been released so fade/stop cue
              If gqMainVKTimeDown(\nHKShortcutVK) <> 0
                debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutVK))
                gqMainVKTimeDown(\nHKShortcut) = 0
              EndIf
              If \nHKShortcutNumPadVK
                If gqMainVKTimeDown(\nHKShortcutNumPadVK) <> 0
                  debugMsg(sProcName, "setting gqMainVKTimeDown(" + \nHKShortcutNumPadVK + ")=0, was " + gqMainVKTimeDown(\nHKShortcutNumPadVK))
                  gqMainVKTimeDown(\nHKShortcutNumPadVK) = 0
                EndIf
              EndIf
              If nCueState < #SCS_CUE_FADING_OUT
                debugMsg(sProcName, "calling fadeOutCue(" + aCue(nCuePtr)\sCue + ", #False, #True)")
                fadeOutCue(nCuePtr, #False, #True) ; Changed 23Nov2022 11.9.7ak
                ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
                gbCallLoadDispPanels = #True
              EndIf
              bCountPlaying = #True
              ; Added 30Jun2023
              If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
                debugMsg(sProcName, "calling FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_OFF, 0, 0, 0, " + aCue(nCuePtr)\sHotkey + ")")
                FMP_sendCommandIfReqd(#SCS_OSCINP_HKEY_OFF, 0, 0, 0, aCue(nCuePtr)\sHotkey)
              EndIf
              ; End added 30Jun2023
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  If bCountPlaying
    gnNoteHotkeyCuesPlaying = countNoteHotkeysPlaying()
  EndIf
  
EndProcedure

Procedure.s loadOtherInfoTextForAud(pAudPtr, pSubInfoText.s, bDisplayExclusive = #False)
  ; PROCNAMECA(pAudPtr)
  Protected sOtherInfoText.s, sTempoEtcInfo.s
  Protected nCuePtr, nSubPtr, nAudCount
  Protected nMyPrevPlayIndex
  Protected nMyFadeInTime, nMyFadeOutTime
  Protected nMyPLFadeInTime, nMyPLFadeOutTime
  Protected d
  Protected sInputLogicalDev.s
  Protected sInputsOff.s
  Static sPLRepeat.s, sWait.s, sLogo.s, sFadeIn.s, sFadeOut.s
  Static sLoops.s, sLoopReleased.s, sXFadeLoops.s, sMixNext.s
  Static sScreen.s, sScreens.s, sRepeatCanceled.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sPLRepeat = Lang("Common", "PLRepeat")
    sWait = LangSpace("Common", "Wait")
    sLogo = Lang("Common", "Logo")
    sFadeIn = Lang("OtherInfo", "FadeIn")
    sFadeOut = Lang("OtherInfo", "FadeOut")
    sLoops = Lang("OtherInfo", "Loops")
    sLoopReleased = Lang("OtherInfo", "LoopReleased")
    sXFadeLoops = Lang("OtherInfo", "XFadeLoops")
    sMixNext = Lang("OtherInfo", "MixNext")
    sScreen = LangSpace("Common", "Screen")
    sScreens = LangSpace("Common", "Screens")
    sRepeatCanceled = Lang("Common", "RepeatCanceled")
    bStaticLoaded = #True
  EndIf
  
  With aAud(pAudPtr)
    
    If (\nAudState = #SCS_CUE_ERROR) And (Trim(\sErrorMsg))
      ProcedureReturn Trim(\sErrorMsg)
    EndIf
    
    nCuePtr = \nCueIndex
    nSubPtr = \nSubIndex
    nAudCount = aSub(nSubPtr)\nAudCount
    
    If \nPrevPlayIndex = -1
      ; pSubInfoText may contain relative start time.
      ; include for first audio only
      sOtherInfoText = pSubInfoText
    EndIf
    
    If (\bAudTypeA) And (\bLogo)
      If sOtherInfoText
        sOtherInfoText + "   "
      EndIf
      sOtherInfoText + sLogo
    EndIf
    
    ; debugMsg(sProcName, "\nFadeInTime=" + \nFadeInTime + ", \nFadeOutTime=" + \nFadeOutTime)
    nMyFadeInTime = \nFadeInTime
    nMyFadeOutTime = \nFadeOutTime
    If \bAudTypeAorP
      If (\nPrevPlayIndex = -1) And (aSub(nSubPtr)\nPLAudPlayCount < 2)   ; \nPLAudPlayCount < 2 means we haven't played any files yet, or we are currently playing the first file
        nMyFadeInTime = aSub(nSubPtr)\nPLFadeInTime
      EndIf
      ; If (\nNextAudIndex = -1) And (aSub(nSubPtr)\bPLRepeat = #False)
      If (\nNextAudIndex = -1) And (getPLRepeatActive(nSubPtr) = #False)
        nMyFadeOutTime = aSub(nSubPtr)\nPLFadeOutTime
      EndIf
    ElseIf \bAudTypeI
      If \nInputOnCount = 0
        nMyFadeInTime = 0
        nMyFadeOutTime = 0
      EndIf
    EndIf
    
    If nMyFadeInTime > 0
      If sOtherInfoText
        sOtherInfoText + "   "
      EndIf
      sOtherInfoText + sFadeIn + " " + timeToStringBWZ(nMyFadeInTime)
    EndIf
    
    If (\rCurrLoopInfo\nRelLoopEnd <> 0) And (\rCurrLoopInfo\nRelLoopEnd <> -2)
      If sOtherInfoText
        sOtherInfoText + "   "
      EndIf
      If \rCurrLoopInfo\bLoopReleased
        sOtherInfoText + sLoopReleased
      Else
        If \rCurrLoopInfo\nLoopXFadeTime > 0
          sOtherInfoText + sXFadeLoops
        Else
          sOtherInfoText + sLoops
        EndIf
        If \rCurrLoopInfo\nNumLoops > 1
          If \nLoopPassNo <= 0
            sOtherInfoText + " (" + \rCurrLoopInfo\nNumLoops + ")"
          Else
            sOtherInfoText + " (" + \nLoopPassNo + "/" + \rCurrLoopInfo\nNumLoops + ")"
          EndIf
        EndIf
      EndIf
    EndIf
    
    If nMyFadeOutTime > 0
      If sOtherInfoText
        sOtherInfoText + "  "
      EndIf
      sOtherInfoText + sFadeOut + " " + timeToStringBWZ(nMyFadeOutTime)
    EndIf
    
    If \bAudTypeF
      sTempoEtcInfo = buildTempoEtcInfo(\nSubIndex)
      If sTempoEtcInfo
        If sOtherInfoText
          sOtherInfoText + "  "
        EndIf
        sOtherInfoText + sTempoEtcInfo
      EndIf
    EndIf
    
    If (\bAudTypeP) And (\nPLTransType = #SCS_TRANS_MIX) And ((\nNextPlayIndex >= 0) Or (aSub(nSubPtr)\bPLRepeat))
      If sOtherInfoText
        sOtherInfoText + "   "
      EndIf
      sOtherInfoText + sMixNext + " " + timeToString(\nPLTransTime)
    EndIf
    
    If \bAudTypeI
      For d = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
        If (\bInputOff[d] = #False) And (\bInputCurrentlyOff[d])
          sInputLogicalDev = \sInputLogicalDev[d]
          If sInputLogicalDev
            If sInputsOff
              sInputsOff + "+"
            EndIf
            sInputsOff + sInputLogicalDev
          EndIf
        EndIf
      Next d
      If sInputsOff
        If sOtherInfoText
          sOtherInfoText + "   "
        EndIf
        sOtherInfoText + sInputsOff + " " + grText\sTextOff
      EndIf
    EndIf
    
    If \bAudTypeF
      If (\sVSTPluginName) And (\bVSTBypass = #False) And (\nVSTHandle <> 0)
        If sOtherInfoText
          sOtherInfoText + "   "
        EndIf
        sOtherInfoText + "VST:" + \sVSTPluginName
      EndIf
    EndIf

  EndWith
  
  With aSub(nSubPtr)
    If (\nPrevSubIndex = -1) And (aCue(nCuePtr)\nStandby <> #SCS_STANDBY_NONE)
      If sOtherInfoText
        sOtherInfoText + "   "
      EndIf
      If (aCue(nCuePtr)\nStandby = #SCS_STANDBY_SET)
        sOtherInfoText + Lang("WEC", "StandbySetShort") ; "Set standby"
      Else
        sOtherInfoText + Lang("WEC", "StandbyCancelShort") ; "Cancel standby"
      EndIf
    EndIf
    
    ; If \nSubState < #SCS_CUE_PLAYING
      ; If \bSubTypeAorP And pAudPtr = \nFirstPlayIndex
        ; If \nPLFadeInTime > 0
          ; If aAud(pAudPtr)\nAudState < #SCS_CUE_PLAYING
            ; If Len(sOtherInfoText) > 0
              ; sOtherInfoText + "   "
            ; EndIf
            ; sOtherInfoText + "(P/L fade in " + timeToStringBWZ(\nPLFadeInTime) + ")"
          ; EndIf
        ; EndIf
      ; EndIf
    ; EndIf
    
    If \bSubTypeA
      If grVideoMonitors\nOutputScreenCount > 1
        If \sScreens
          If Len(\sScreens) = 1
            sOtherInfoText + "   " + sScreen + \sScreens
          Else
            sOtherInfoText + "   " + sScreens + \sScreens
          EndIf
        ElseIf \nOutputScreen
          sOtherInfoText + "   " + sScreen + \nOutputScreen
        EndIf
      EndIf
    EndIf
    
  EndWith
  
  With aAud(pAudPtr)
    If (\bAudTypeAorP) And (\nPLTransType = #SCS_TRANS_WAIT)
      nMyPrevPlayIndex = \nPrevPlayIndex
      If nMyPrevPlayIndex < 0
        If (aSub(nSubPtr)\bPLRepeat = #True) And (aSub(nSubPtr)\nPLAudPlayCount > 1)
          nMyPrevPlayIndex = aSub(nSubPtr)\nFirstPlayIndex
        EndIf
      EndIf
      If nMyPrevPlayIndex >= 0
        If sOtherInfoText
          sOtherInfoText + "   "
        EndIf
        sOtherInfoText + sWait + timeToString(aAud(nMyPrevPlayIndex)\nPLTransTime)
      EndIf
    EndIf
    
    If \bAudTypeAorP
      If \nNextPlayIndex = -1
        If aSub(nSubPtr)\bPLRepeat
          If getPLRepeatActive(nSubPtr) = #False
            If sOtherInfoText
              sOtherInfoText + "   "
            EndIf
            sOtherInfoText + sRepeatCanceled
          ElseIf \bDoContinuous = #False
            If sOtherInfoText
              sOtherInfoText + "   "
            EndIf
            sOtherInfoText + sPLRepeat
          EndIf
        EndIf
      EndIf
    EndIf
    
    If bDisplayExclusive
      If aCue(nCuePtr)\bExclusiveCue
        If sOtherInfoText
          sOtherInfoText + "   "
        EndIf
        sOtherInfoText + "Excl."
      EndIf
    EndIf
    
    Select aCue(\nCueIndex)\nProdTimerAction
      Case #SCS_PTA_NO_ACTION
        ; no action
      Case #SCS_PTA_START_S, #SCS_PTA_PAUSE_S, #SCS_PTA_RESUME_S
        If (aSub(\nSubIndex)\nPrevSubIndex = -1) And (\nPrevPlayIndex = -1)
          ; first sub and aud for this cue
          sOtherInfoText + "  " + decodeProdTimerActionAbbr(aCue(\nCueIndex)\nProdTimerAction)
        EndIf
      Case #SCS_PTA_START_E, #SCS_PTA_PAUSE_E, #SCS_PTA_RESUME_E
        If (aSub(\nSubIndex)\nNextSubIndex = -1) And (\nNextPlayIndex = -1)
          ; last sub and aud for this cue
          sOtherInfoText + "  " + decodeProdTimerActionAbbr(aCue(\nCueIndex)\nProdTimerAction)
        EndIf
    EndSelect
    ; debugMsg(sProcName, "aCue(" + getCueLabel(\nCueIndex) + ")\nProdTimerAction=" + decodeProdTimerAction(aCue(\nCueIndex)\nProdTimerAction) + ", sOtherInfoText=" + Trim(sOtherInfoText))
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + Trim(sOtherInfoText))
  ProcedureReturn Trim(sOtherInfoText)

EndProcedure

Procedure buildDisplayInfoForCtrlSend(*rSub.tySub, nIndex, bPrimaryFile=#True)
  PROCNAMEC()
  Protected sDisplayInfo.s, nCommand, sItemDesc.s, sSubLabel.s, n
  
  With *rSub\aCtrlSend[nIndex]
    If *rSub\sSubLabel
      sSubLabel = *rSub\sSubLabel
    Else
      sSubLabel = *rSub\sSubDescr
    EndIf
    If Trim(\sCSItemDesc)
      sItemDesc = " " + Trim(\sCSItemDesc)
    EndIf
    ; If \nDevType <> #SCS_DEVTYPE_NONE
    ;   debugMsg(sProcName, sSubLabel + ", \nDevType=" + decodeDevType(\nDevType) + ", \nMSMsgType=" + \nMSMsgType + ", \sRemDevMsgType=" + \sRemDevMsgType + ", \nRemDevMsgType=" + \nRemDevMsgType + ", \nRemDevMuteAction=" + \nRemDevMuteAction + ", \sRemDevValue=" + \sRemDevValue)
    ; EndIf
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT  ; #SCS_DEVTYPE_CS_MIDI_OUT
        If \nMSMsgType <> #SCS_MSGTYPE_NONE
          sDisplayInfo = decodeMsgTypeShortL(\nMSMsgType) + sItemDesc
          Select \nMSMsgType
            Case #SCS_MSGTYPE_PC127
              If \nMSChannel > 0
                sDisplayInfo + "  Ch " + \nMSChannel
              EndIf
              If \nMSParam1 >= 0
                sDisplayInfo + "  Prg " + \nMSParam1 + "(" + Right("0" + Hex(\nMSParam1), 2) + "H" + ")"
              EndIf
              
            Case #SCS_MSGTYPE_PC128
              If \nMSChannel > 0
                sDisplayInfo + "  Ch " + \nMSChannel
              EndIf
              If \nMSParam1 >= 0
                sDisplayInfo + "  Prg " + Str(\nMSParam1 + 1) + "(" + Right("0" + Hex(\nMSParam1), 2) + "H" + ")"
              EndIf
              
            Case #SCS_MSGTYPE_CC
              If \nMSChannel > 0
                sDisplayInfo + "  Ch " + \nMSChannel
              EndIf
              If \nMSParam1 >= 0
                sDisplayInfo + "  Ctrl " + \nMSParam1 + "(" + Right("0" + Hex(\nMSParam1), 2) + "H" + ")"
              EndIf
              If \nMSParam2 >= 0
                sDisplayInfo + "  Val " + \nMSParam2 + "(" + Right("0" + Hex(\nMSParam2), 2) + "H" + ")"
              EndIf
              
            Case #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF
              If \nMSChannel > 0
                sDisplayInfo + "  Ch " + \nMSChannel
              EndIf
              If \nMSParam1 >= 0
                sDisplayInfo + "  Note " + \nMSParam1 + "(" + Right("0" + Hex(\nMSParam1), 2) + "H)"
              EndIf
              If \nMSParam2 >= 0
                sDisplayInfo + "  Vel " + \nMSParam2 + "(" + Right("0" + Hex(\nMSParam2), 2) + "H" + ")"
              EndIf
              
            Case #SCS_MSGTYPE_MSC
              If \nMSChannel > 0
                sDisplayInfo + "  Dev " + Right("0" + Hex(\nMSChannel - 1), 2) + "H"
              EndIf
              If \nMSParam1 >= 0
                sDisplayInfo + "  Fmt " + Right("0" + Hex(\nMSParam1), 2) + "H"
              EndIf
              If \nMSParam2 >= 0
                sDisplayInfo + "  Cmd " + Right("0" + Hex(\nMSParam2), 2) + "H"
              EndIf
              nCommand = \nMSParam2
              Select nCommand
                Case $1, $2, $3, $5, $B, $10
                  ; commands with q_number, q_list and q_path
                  If \sMSQNumber Or \sMSQList Or \sMSQPath
                    sDisplayInfo + "  Data"
                  EndIf
                  If \sMSQNumber
                    sDisplayInfo + " " + \sMSQNumber
                  EndIf
                  If \sMSQList
                    sDisplayInfo + " " + \sMSQList
                  EndIf
                  If \sMSQPath
                    sDisplayInfo + " " + \sMSQPath
                  EndIf
                  
                Case $6
                  ; set command uses q_number and q_list for control number and control value
                  If \sMSQNumber Or \sMSQList
                    sDisplayInfo + "  Data"
                  EndIf
                  If \sMSQNumber
                    sDisplayInfo + " " + \sMSQNumber
                  EndIf
                  If \sMSQList
                    sDisplayInfo + " " + \sMSQList
                  EndIf
                  
                Case $7
                  ; command with macro number
                  If \nMSMacro >= 0
                    sDisplayInfo + "  Data " + \nMSMacro
                  EndIf
                  
                Case $1B, $1C
                  If \sMSQList
                    sDisplayInfo + "  Data " + \sMSQList
                  EndIf
                  
                Case $1D, $1E
                  If \sMSQPath
                    sDisplayInfo + "  Data " + \sMSQPath
                  EndIf
                  
                Default
                  ; no extra info or unsupported
                  
              EndSelect
              
            Case #SCS_MSGTYPE_MMC
              If \nMSChannel > 0
                sDisplayInfo + "  Dev " + Right("0" + Hex(\nMSChannel - 1), 2) + "H"
              EndIf
              If \nMSParam1 >= 0
                sDisplayInfo + "  Cmd " + Right("0" + Hex(\nMSParam1), 2) + "H"
              EndIf
              nCommand = \nMSParam1
              
            Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
              sDisplayInfo + "  " + buildNRPNDisplayInfo(*rSub\aCtrlSend[nIndex])
              
            Case #SCS_MSGTYPE_FREE
              sDisplayInfo + "  " + \sEnteredString
              
            Case #SCS_MSGTYPE_FILE
              If \nAudPtr >= 0
                If bPrimaryFile
                  sDisplayInfo + " " + GetFilePart(aAud(\nAudPtr)\sFileName)
                Else
                  sDisplayInfo + " " + GetFilePart(a2ndAud(\nAudPtr)\sFileName)
                EndIf
              EndIf
              
            Case #SCS_MSGTYPE_SCRIBBLE_STRIP
              For n = 0 To 2
                If n <= \nMaxScribbleStripItem
                  If n = 0
                    sDisplayInfo + " " + \aScribbleStripItem(n)\sSSItemName
                  Else
                    sDisplayInfo + ", " + \aScribbleStripItem(n)\sSSItemName
                  EndIf
                EndIf
              Next n
              If \nMaxScribbleStripItem > 2
                sDisplayInfo + ", ..."
              EndIf

          EndSelect
          
        ElseIf \sRemDevMsgType
          sDisplayInfo = \sDisplayInfo ; already populated
;           If LCase(Left(\sRemDevMsgType,4)) = "mute"
;             sDisplayInfo = decodeMsgTypeShortL(\nRemDevMsgType, \nRemDevMuteAction) + " " + CSRD_buildRemDisplayInfo(\nRemDevMsgType)
;           Else
;             sDisplayInfo = decodeMsgTypeShortL(\nRemDevMsgType) + sItemDesc
;           EndIf
;           sDisplayInfo + " " + \sRemDevValue
          
        EndIf ; EndIf \nMSMsgType <> #SCS_MSGTYPE_NONE / ElseIf \nRemDevMsgType <> 0
        
      Case #SCS_DEVTYPE_CS_RS232_OUT   ; #SCS_DEVTYPE_CS_RS232_OUT
        sDisplayInfo = \sCSLogicalDev + sItemDesc + " " + \sEnteredString
        
      Case #SCS_DEVTYPE_CS_NETWORK_OUT  ; #SCS_DEVTYPE_CS_NETWORK_OUT
        If \bIsOSC
          sDisplayInfo = \sCSLogicalDev + sItemDesc + " " + buildOSCDisplayInfo(*rSub, nIndex)
        Else
          sDisplayInfo = \sCSLogicalDev + sItemDesc + " " + \sEnteredString
        EndIf
        
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
        sDisplayInfo = \sCSLogicalDev + sItemDesc + " " + \sEnteredString
        
    EndSelect
    
    \sDisplayInfo = Trim(sDisplayInfo)
    CompilerIf 1=1
      If \sDisplayInfo
        debugMsg(sProcName, "*rSub(" + *rSub\sSubLabel + ")\aCtrlSend[" + nIndex + "]\nMSMsgType=" + decodeMsgType(\nMSMsgType) +
                            ", \nRemDevMsgType=" + \nRemDevMsgType + ", \sRemDevMsgType=" + \sRemDevMsgType +
                            ", \sDisplayInfo=" + \sDisplayInfo)
      EndIf
    CompilerEndIf
    
  EndWith
  
EndProcedure

Procedure loadOneCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected d, i, j, k, n
  Protected bUpdateGrid
  Protected bIgnoreOpen
  Protected nCurrGaplessAudPtr, nCurrGaplessSubPtr
  Protected nCueStatePrev
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gbGoToProdPropDevices
    ; do not load cue yet
    debugMsg(sProcName, "exiting because gbGoToProdPropDevices=#True")
    ProcedureReturn
  EndIf
  
  i = pCuePtr

  If aCue(i)\bCueCurrentlyEnabled = #False
    debugMsg(sProcName, "exiting because \bCueCurrentlyEnabled=False")
    ProcedureReturn
  EndIf
  If aCue(i)\nCueState = #SCS_CUE_IGNORED
    debugMsg(sProcName, "exiting because \nCueState=#SCS_CUE_IGNORED")
    ProcedureReturn
  EndIf
  
  nCueStatePrev = aCue(i)\nCueState
  aCue(i)\bUnloadWhenEnded = #False
  
  j = aCue(i)\nFirstSubIndex
  While j >= 0
    With aSub(j)
      If \bSubEnabled 
        If \bSubTypeHasAuds And \nFirstPlayIndex >= 0 ; Added \nFirstPlayIndex test 11Jan2025 11.10.6-b03
          k = \nFirstPlayIndex
          n = 0
          While (k >= 0) And (n < 2)
            debugMsg(sProcName, aAud(k)\sAudLabel + ", \nAudState=" + decodeCueState(aAud(k)\nAudState) + ", \nFileState=" + decodeFileState(aAud(k)\nFileState))
            ; debugMsg(sProcName, aAud(k)\sAudLabel + ", " + GetFilePart(aAud(k)\sFileName))
            If aAud(k)\nFileState = #SCS_FILESTATE_CLOSED
              If (aAud(k)\sFileName) Or (aAud(k)\bLiveInput)
                bIgnoreOpen = #False
                If \bSubTypeA
                  If \bSubUseGaplessStream
                    If (\nSubGaplessSeqPtr <> grMMedia\nCurrGaplessSeqPtr) And (grMMedia\nCurrGaplessSeqPtr >= 0)
                      nCurrGaplessAudPtr = gaGaplessSeqs(grMMedia\nCurrGaplessSeqPtr)\nFirstGaplessAudPtr
                      If nCurrGaplessAudPtr >= 0
                        nCurrGaplessSubPtr = aAud(nCurrGaplessAudPtr)\nSubIndex
                        If (aSub(nCurrGaplessSubPtr)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(nCurrGaplessSubPtr)\nSubState <= #SCS_CUE_FADING_OUT)
                          debugMsg(sProcName, "setting bIgnoreOpen=#True because aSub(" + getSubLabel(nCurrGaplessSubPtr) + ")\nSubState=" + decodeCueState(aSub(nCurrGaplessSubPtr)\nSubState))
                          bIgnoreOpen = #True
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                EndIf
                If bIgnoreOpen
                  Break
                EndIf
                debugMsg(sProcName, "~~ calling openMediaFile(" + getAudLabel(k) + ", #False, " + decodeVidPicTarget(getVidPicTargetForOutputScreen(\nOutputScreen)) + " for " + #DQUOTE$ + aAud(k)\sStoredFileName + #DQUOTE$)
                openMediaFile(k, #False, getVidPicTargetForOutputScreen(\nOutputScreen))
                bUpdateGrid = #True
                n + 1
              EndIf
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        Else
          \nSubState = #SCS_CUE_READY
        EndIf
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(\nSubState) + ", \bSubTypeHasAuds=" + strB(\bSubTypeHasAuds))
        
;         debugMsg(sProcName, "calling setCueState(" + getCueLabel(pCuePtr) + ")")
;         setCueState(pCuePtr)
        
      EndIf ; EndIf (\bSubEnabled) And (\bSubTypeHasAuds)
      j = \nNextSubIndex
    EndWith
  Wend
  
  ; Moved here from above 3Jun2024 11.10.3ag
  ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(pCuePtr) + ")")
  setCueState(pCuePtr)
  ; debugMsg0(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(aCue(pCuePtr)\nCueState))
  ; End moved here from above 3Jun2024 11.10.3ag
  
  If gbUseSMS ; SM-S
    debugMsg(sProcName, "calling setSyncPChanListForCue(" + getCueLabel(i) + ")")
    setSyncPChanListForCue(i)
  EndIf
  
  If bUpdateGrid
    debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(i) + ")")
    loadGridRow(i)
  EndIf
  
  If gnHighlightedCue = pCuePtr
    ; redo highlightLine in case cue status has been changed to SCS_CUE_ERROR
    highlightLine(gnHighlightedCue)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure unloadOneCue(pCuePtr)
  PROCNAMECQ(pCuePtr)

  If aCue(pCuePtr)\bHotkey Or aCue(pCuePtr)\bExtAct Or aCue(pCuePtr)\bCallableCue
    debugMsg(sProcName, "ignoring because this is a hotkey cue or a callable cue")
    ProcedureReturn
  EndIf

  If (aCue(pCuePtr)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(pCuePtr)\nCueState <= #SCS_CUE_FADING_OUT)
    ; don't close yet - cue is currently playing
    debugMsg(sProcName, "setting \bUnloadWhenEnded=True as \nCueState=" + decodeCueState(aCue(pCuePtr)\nCueState))
    aCue(pCuePtr)\bUnloadWhenEnded = #True
    ProcedureReturn
  EndIf
  
  closeCue(pCuePtr, #True)
  updateGrid(pCuePtr)
  samAddRequest(#SCS_SAM_LOAD_CUE_PANELS)

EndProcedure

Procedure populateGrid()
  PROCNAMEC()
  Protected i
  Protected bGrdVisible
  Protected rc.RECT, nRowHeight, nMinSize
  Static nCurrMinSize

  gbCallPopulateGrid = #False

  debugMsg(sProcName, #SCS_START + ", gnCueEnd=" + getCueLabel(gnCueEnd) + ", gnLastCue=" + getCueLabel(gnLastCue))

  bGrdVisible = getVisible(WMN\grdCues)
  setVisible(WMN\grdCues, #False)
  
  gnPrevHighlightedCue = -1
  gnPrevHighlightedRow = -1
  
  setGrdCuesRowNos()    ; set row nos for cues to be displayed (eg excludes disabled cues)
  
  ClearGadgetItems(WMN\grdCues)
  WMN_setCueListFontSize()
  
  ; populate the grid
  ; debugMsg(sProcName, "gnLastCue=" + gnLastCue)
  For i = 1 To gnLastCue
    ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nGrdCuesRowNo=" + aCue(i)\nGrdCuesRowNo)
    If aCue(i)\nGrdCuesRowNo >= 0
      AddGadgetItem(WMN\grdCues, -1, "")
      ; debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(i) + ")")
      loadGridRow(i)
      ; debugMsg(sProcName, "returned from loadGridRow(" + getCueLabel(i) + ")")
    EndIf
  Next i
  AddGadgetItem(WMN\grdCues, -1, grText\sTextEnd)
  ; debugMsg(sProcName, "calling colorLine(" + gnCueEnd + ")")
  colorLine(gnCueEnd)
  
  setVisible(WMN\grdCues, bGrdVisible)
  
  ; Added 21Oct2022 11.9.6 following Forum Feature Request from genel 15Oct2022 "Minimum cue list window height"
  ; Based on code posted in PBForum by srod 28Sep2010 entitled "ListIconGadget row height and scrollbar" (https://www.purebasic.fr/english/viewtopic.php?p=335199#p335199)
  rc\left = #LVIR_BOUNDS
  SendMessage_(GadgetID(WMN\grdCues), #LVM_GETITEMRECT, 0, rc)
  nRowHeight = rc\bottom - rc\top + 1
  ; End based on code by srod
  If nRowHeight > 1 ; nb will be 1 if no rows in grid
    If grOperModeOptions(gnOperMode)\bLimitMovementOfMainWindowSplitterBar
      nMinSize = nRowHeight * 3 ; to allow for header line and two cues - apply same minimum to the bottom so at least something can be seen of the cue panels
    Else
      nMinSize = 0 ; 'limit movement' test added 24Aug2023 11.10.0by to allow (if #False) cue panels or cue list to be hidden
    EndIf
    If nMinSize <> nCurrMinSize
      debugMsg(sProcName, "nRowHeight=" + nRowHeight + ", nMinSize=" + nMinSize)
      SetGadgetAttribute(WMN\splNorthSouth, #PB_Splitter_FirstMinimumSize, nMinSize)
      SetGadgetAttribute(WMN\splNorthSouth, #PB_Splitter_SecondMinimumSize, nMinSize)
      nCurrMinSize = GetGadgetAttribute(WMN\splNorthSouth, #PB_Splitter_FirstMinimumSize)
      ; debugMsg0(sProcName, "GetGadgetAttribute(WMN\splNorthSouth, #PB_Splitter_FirstMinimumSize)=" + nCurrMinSize)
    EndIf
  EndIf
  ; End added 21Oct2022 11.9.6
  
  gbGridLoaded = #True
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure resetAllActivationMethodReqdEtc()
  PROCNAMEC()
  Protected i, j, k
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \nActivationMethodReqd <> \nActivationMethod
        Select \nActivationMethodReqd
          Case #SCS_ACMETH_MAN, #SCS_ACMETH_MAN_PLUS_CONF
            Select \nActivationMethod
              Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF, #SCS_ACMETH_OCM ; added #SCS_ACMETH_OCM 18Mar2020 11.8.2.3ab
                If \nAutoActCuePtr >= 0
                  If aCue(\nAutoActCuePtr)\nCueState <= #SCS_CUE_READY
                    If \nActivationMethodReqd <> \nActivationMethod
                      debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\nActivationMethodReqd from " + decodeActivationMethod(\nActivationMethodReqd) + " to " + decodeActivationMethod(\nActivationMethod))
                      \nActivationMethodReqd = \nActivationMethod
                    EndIf
                    If \bAutoStartLocked <> grCueDef\bAutoStartLocked
                      ; debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\bAutoStartLocked from " + strB(\bAutoStartLocked) + " to " + strB(grCueDef\bAutoStartLocked))
                      \bAutoStartLocked = grCueDef\bAutoStartLocked
                      debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bAutoStartLocked=" + strB(\bAutoStartLocked))
                    EndIf
                    If \bHoldAutoStart <> grCueDef\bHoldAutoStart
                      debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\bHoldAutoStart from " + strB(\bHoldAutoStart) + " to " + strB(grCueDef\bHoldAutoStart))
                      \bHoldAutoStart = grCueDef\bHoldAutoStart
                    EndIf
                  EndIf
                EndIf
            EndSelect
        EndSelect
      EndIf
    EndWith
    
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bIgnoreInStatusCheck <> grSubDef\bIgnoreInStatusCheck
          debugMsg(sProcName, "changing aSub(" + getSubLabel(j) + ")\bIgnoreInStatusCheck from " + strB(\bIgnoreInStatusCheck) + " to " + strB(grSubDef\bIgnoreInStatusCheck))
          \bIgnoreInStatusCheck = grSubDef\bIgnoreInStatusCheck
        EndIf
      EndWith
      
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          With aAud(k)
            If \bIgnoreInStatusCheck <> grAudDef\bIgnoreInStatusCheck
              debugMsg(sProcName, "changing aAud(" + getAudLabel(k) + ")\bIgnoreInStatusCheck from " + strB(\bIgnoreInStatusCheck) + " to " + strB(grAudDef\bIgnoreInStatusCheck))
              \bIgnoreInStatusCheck = grAudDef\bIgnoreInStatusCheck
            EndIf
          EndWith
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      
      j = aSub(j)\nNextSubIndex
    Wend
    
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resetCueStates(pCuePtr, pSelectedCueOnly=#False)
  PROCNAMECQ(pCuePtr)
  Protected i, j, k, d
  Protected nRow, bRedrawState
  Protected nFirstCue, nLastCue
  Protected nRealPrevSubIndex
  Protected bKeepCueOpen, bKeepSubOpen ; Added 15Mar2025 11.10.8al

  debugMsg(sProcName, #SCS_START + ", pSelectedCueOnly=" + strB(pSelectedCueOnly))
  
  bRedrawState = getGrdCuesRedrawState()
  setGrdCuesRedrawState(#False)

  If pSelectedCueOnly
    nFirstCue = pCuePtr
    nLastCue = pCuePtr
  Else
    nFirstCue = 1
    nLastCue = gnLastCue
  EndIf
  
  For i = nFirstCue To nLastCue
    bKeepCueOpen = #False ; Added 15Mar2025 11.10.8al
    nRow = aCue(i)\nGrdCuesRowNo
    If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED) And (aCue(i)\nActivationMethodReqd <> #SCS_ACMETH_TIME Or gbStoppingEverything)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubEnabled
            bKeepSubOpen = #False ; Added 15Mar2025 11.10.8al
            If (gbStoppingEverything) And (aSub(j)\nSubState = #SCS_CUE_HIBERNATING)
              j = \nNextSubIndex
              Continue
            EndIf
            
            If (i < pCuePtr) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False) And (i <> gnStandbyCuePtr) And (aCue(i)\bNonLinearCue = #False)
              k = \nFirstAudIndex
              While k >= 0
                If aAud(k)\bLogo And k = gnLogoAudPtr ; Test and related code added 15Mar2025 11.10.8al
                  ; Keep aud, sub and cue open
                  bKeepSubOpen = #True
                  bKeepCueOpen = #True
                Else
                  ; debugMsg(sProcName, "calling endOfAud(" + getAudLabel(k) + ", " + decodeCueState(#SCS_CUE_COMPLETED) + ")")
                  endOfAud(k, #SCS_CUE_COMPLETED)
                EndIf
                k = aAud(k)\nNextAudIndex
              Wend
              If bKeepSubOpen = #False ; Test added 15Mar2025 11.10.8al
                                       ; debugMsg(sProcName, "calling endOfSub(" + getSubLabel(j) + ", #SCS_CUE_COMPLETED)")
                endOfSub(j, #SCS_CUE_COMPLETED)
                ; debugMsg(sProcName, "calling closeSub(" + getSubLabel(j) + ")")
                closeSub(j)
              EndIf
            Else
              nRealPrevSubIndex = calcRealPrevSubIndex(j)
              If nRealPrevSubIndex = -1
                ; debugMsg(sProcName, "calling setInitCueStates(" + getCueLabel(i) + ", " + getCueLabel(pCuePtr) + ")")
                setInitCueStates(i, pCuePtr)
                If aCue(i)\nAutoActPosn = #SCS_ACPOSN_LOAD
                  If gbStoppingEverything Or gbSamRequestUnderStoppingEverything
                    aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN
                    ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(i)\nActivationMethodReqd))
                  Else
                    aCue(i)\nActivationMethodReqd = aCue(i)\nActivationMethod
                  EndIf
                Else
                  If aCue(i)\nAutoActCueSelType = #SCS_ACCUESEL_PREV
                    setCuePtrForAutoStartPrevCueType(i)
                  EndIf
                  If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME And (gbResettingTODPart1 Or gbResettingTODPart2)
                    aCue(i)\nActivationMethodReqd = aCue(i)\nActivationMethod
                  ElseIf (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO) And (aCue(i)\nAutoActCuePtr < pCuePtr)
                    aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN
                    ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(i)\nActivationMethodReqd))
                  ElseIf (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF) And (aCue(i)\nAutoActCuePtr < pCuePtr)
                    aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF
                  ElseIf (aCue(i)\nActivationMethod = #SCS_ACMETH_TIME) And (aCue(i)\bCueStoppedByStopEverything)
                    aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN
                    debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(i)\nActivationMethodReqd) + ", gbResettingTODPart1=" + strB(gbResettingTODPart1) + ", gbResettingTODPart2=" + strB(gbResettingTODPart2))
                  ElseIf (aCue(i)\nActivationMethod = #SCS_ACMETH_TIME)
                    debugMsg(sProcName, "calling setTimeBasedCues(" + getCueLabel(i) + ")")
                    setTimeBasedCues(i) ; added 5Nov2019 11.8.2bq - sets aCue(i)\nActivationMethodReqd to time or manual according to currently-selected time profile
                  Else
                    aCue(i)\nActivationMethodReqd = aCue(i)\nActivationMethod
                  EndIf
                EndIf
                ; debugMsg(sProcName, aCue(i)\sCue + " \nActivationMethodReqd=" + decodeActivationMethod(aCue(i)\nActivationMethodReqd) + ", i=" + i)
              EndIf
              If \bSubTypeHasAuds
                \nSubPosition = 0
                k = \nFirstAudIndex
                While k >= 0
                  aAud(k)\nRelFilePos = aAud(k)\nRelStartAt
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nRelFilePos=" + aAud(k)\nRelFilePos)
                  aAud(k)\nCuePos = 0
                  aAud(k)\nTotalTimeOnPause = 0
                  aAud(k)\nPriorTimeOnPause = 0
                  aAud(k)\nPreFadeInTimeOnPause = 0
                  aAud(k)\nPreFadeOutTimeOnPause = 0
                  aAud(k)\nCuePosAtLoopStart = 0
                  aAud(k)\nCuePosWhenLastChecked = 0
                  k = aAud(k)\nNextAudIndex
                Wend
                
              ElseIf \bSubTypeE
                \nSubPosition = 0
                
              ElseIf \bSubTypeK
                \nSubPosition = 0
                
              ElseIf \bSubTypeL
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  \nLCPosition[d] = 0
                Next d
                \nLCPositionMax = 0
                
              ElseIf \bSubTypeM
                \nSubPosition = 0
                
              ElseIf \bSubTypeU
                \nSubPosition = 0
                
              EndIf
            EndIf
            ; \qTimeSubStarted = 0
            \bTimeSubStartedSet = #False
            \bPLRepeatCancelled = #False
          EndIf ; EndIf \bSubEnabled
          j = \nNextSubIndex
        EndWith
      Wend
      
      ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
      setCueState(i)
      
      With aCue(i)
        If bKeepCueOpen = #False ; Test added 15Mar2025 11.10.8al
          \qTimeCueStarted = 0
          \bTimeCueStartedSet = #False
          \qTimeCueLastStarted = 0 ; Added 2May2023 11.10.0ay following email fromm Dee Ireland advising that counting down cues were not stopped by 'Stop All' in SCS 11.10.0
          ; debugMsg(sProcName, "aCue(" + \sCue + ")\qTimeCueStarted=" + \qTimeCueStarted + ", \bTimeCueStartedSet=#False")
          \qTimeCueStopped = 0
          \bTimeCueStoppedSet = #False
          ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bTimeCueStoppedSet=" + strB(\bTimeCueStoppedSet))
          \bCueStoppedByStopEverything = #False
          \bCueStoppedByGoToCue = #False
          \bDisplayingWarningBeforeEnd = #False
          \qCueTimePauseStarted = 0
          \nCueTotalTimeOnPause = 0
        EndIf
        If (nRow >= 0) And (gbGridLoaded)
          ; debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRow + ", #SCS_GRDCUES_CS, " + getCueStateForGrid(i) + ") for " + \sCue)
          WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_CS, getCueStateForGrid(i))
          WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_AC, getCueActivationMethodForDisplay(i))
        EndIf
      EndWith
      ; debugMsg(sProcName, "calling colorLine(" + getCueLabel(i) + ")")
      colorLine(i)
    EndIf
  Next i
  
  setGrdCuesRedrawState(bRedrawState)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDelayHideInds()
  ; PROCNAMEC()
  Protected i, j, k
  Protected i2
  Protected sCue.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  For k = 1 To gnLastAud
    aAud(k)\bDelayHide = #False
  Next k
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      sCue = aCue(i)\sCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          If aSub(j)\bSubTypeA
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                ; picture found
                If (aAud(k)\nNextPlayIndex >= 0) Or (getPLRepeatActive(j))
                  aAud(k)\bDelayHide = #True
                  ; debugMsg(sProcName, aAud(k)\sAudLabel + " \bDelayHide=#True")
                Else
                  ; now look to see if another cue autostarts immediately after this cue
                  For i2 = 1 To gnLastCue
                    If (aCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO) Or (aCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
                      If aCue(i2)\nAutoActPosn <> #SCS_ACPOSN_LOAD
                        If aCue(i2)\sAutoActCue = sCue
                          If ((aCue(i2)\nAutoActPosn = #SCS_ACPOSN_AE) And (aCue(i2)\nAutoActTime = 0)) Or (aCue(i2)\nAutoActPosn = #SCS_ACPOSN_BE)
                            aAud(k)\bDelayHide = #True
                            ; debugMsg(sProcName, aAud(k)\sAudLabel + " \bDelayHide=#True")
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  Next i2
                EndIf
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure setCueBassDevsAndMidiPortNos(pSubPtr=-1)
  PROCNAMEC()
  Protected nFromSubPtr, nToSubPtr
  Protected j, k, d1, d2, d3, bFound, nBassDevice, nMidiPhysicalDevPtr
  Protected n
  Protected bASIO, nBassASIODevice
  Protected bCuesChanged
  Protected nCueLogicalDevCount
  Protected nDevMapPtr
  Protected bMidiFilePlayback
  Protected sMyLogicalDev.s
  Protected nAudioDriver
  
  debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr))
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf

  nAudioDriver = grMaps\aMap(nDevMapPtr)\nAudioDriver
  ; debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver))
  
  If pSubPtr = -1
    nFromSubPtr = 1
    nToSubPtr = gnLastSub
  Else
    nFromSubPtr = pSubPtr
    nToSubPtr = pSubPtr
  EndIf
  
  For j = nFromSubPtr To nToSubPtr
    With aSub(j)
      If (\bExists) And (\bSubEnabled)
        If \bSubTypeP ; \bSubTypeP
          For d1 = 0 To grLicInfo\nMaxAudDevPerSub
            If Len(\sPLLogicalDev[d1]) = 0
              bFound = #True
            Else
              bFound = #False
              For d2 = 1 To nCueLogicalDevCount
                If gaCueLogicalDevs(d2)\bMidiDev = #False
                  If gaCueLogicalDevs(d2)\sCueDev = \sPLLogicalDev[d1]
                    bFound = #True
                    Break
                  EndIf
                EndIf
              Next d2
            EndIf
            If bFound = #False
              nCueLogicalDevCount + 1
              If nCueLogicalDevCount > ArraySize(gaCueLogicalDevs())
                ReDim gaCueLogicalDevs(nCueLogicalDevCount+20)
              EndIf
              gaCueLogicalDevs(nCueLogicalDevCount)\sCueDev = \sPLLogicalDev[d1]
              gaCueLogicalDevs(nCueLogicalDevCount)\bMidiDev = #False
              gsSelectedDevice = \sPLLogicalDev[d1]
              nBassDevice = 1 ; use device 1 if logical device not found
              bASIO = #False
              nBassASIODevice = -1
              
              d2 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
              While d2 >= 0
                If \sPLLogicalDev[d1] = grMaps\aDev(d2)\sLogicalDev
                  nBassDevice = grMaps\aDev(d2)\nBassDevice
                  bASIO = grMaps\aDev(d2)\bBassASIO
                  nBassASIODevice = grMaps\aDev(d2)\nBassASIODevice
                  bFound = #True
                  Break
                EndIf
                d2 = grMaps\aDev(d2)\nNextDevIndex
              Wend
              If bFound
                gaCueLogicalDevs(nCueLogicalDevCount)\sActualDev = gsSelectedDevice
                gaCueLogicalDevs(nCueLogicalDevCount)\nBassDevice = nBassDevice
                gaCueLogicalDevs(nCueLogicalDevCount)\bASIO = bASIO
                gaCueLogicalDevs(nCueLogicalDevCount)\nBassASIODevice = nBassASIODevice
              EndIf
            EndIf
          Next d1
          
        ElseIf \bSubTypeM  ; \bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            If \aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FILE
              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n + "]\nMSMsgType=" + decodeMsgType(\aCtrlSend[n]\nMSMsgType))
              sMyLogicalDev = \aCtrlSend[n]\sCSLogicalDev
              ; debugMsg(sProcName, "sMyLogicalDev=" + sMyLogicalDev)
              If Len(sMyLogicalDev) = 0
                bFound = #True
              Else
                bFound = #False
                ; debugMsg(sProcName, "nCueLogicalDevCount=" + nCueLogicalDevCount)
                For d2 = 1 To nCueLogicalDevCount
                  ; debugMsg(sProcName, "gaCueLogicalDevs(" + d2 + ")\bMidiDev=" + strB(gaCueLogicalDevs(d2)\bMidiDev) + ", \sCueDev=" + gaCueLogicalDevs(d2)\sCueDev)
                  If gaCueLogicalDevs(d2)\bMidiDev = #True
                    If gaCueLogicalDevs(d2)\sCueDev = sMyLogicalDev
                      bFound = #True
                      Break
                    EndIf
                  EndIf
                Next d2
              EndIf
              ; debugMsg(sProcName, "bFound=" + strB(bFound))
              If bFound = #False
                nCueLogicalDevCount + 1
                If nCueLogicalDevCount > ArraySize(gaCueLogicalDevs())
                  ReDim gaCueLogicalDevs(nCueLogicalDevCount+20)
                EndIf
                gaCueLogicalDevs(nCueLogicalDevCount)\sCueDev = sMyLogicalDev
                gaCueLogicalDevs(nCueLogicalDevCount)\bMidiDev = #True
                gsSelectedDevice = \aCtrlSend[n]\sCSLogicalDev
                nMidiPhysicalDevPtr = 0
                
                d2 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
                While d2 >= 0
                  If sMyLogicalDev = grMaps\aDev(d2)\sLogicalDev
                    debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + grMaps\aDev(d2)\sLogicalDev + ", \nPhysicalDevPtr=" + grMaps\aDev(d2)\nPhysicalDevPtr)
                    nMidiPhysicalDevPtr = grMaps\aDev(d2)\nPhysicalDevPtr
                    bFound = #True
                    Break
                  EndIf
                  d2 = grMaps\aDev(d2)\nNextDevIndex
                Wend
                debugMsg(sProcName, "bFound=" + strB(bFound) + ", nMidiPhysicalDevPtr=" + nMidiPhysicalDevPtr)
                If bFound
                  gaCueLogicalDevs(nCueLogicalDevCount)\sActualDev = gsSelectedDevice
                  gaCueLogicalDevs(nCueLogicalDevCount)\nMidiPhysicalDevPtr = nMidiPhysicalDevPtr
                  debugMsg(sProcName, "gaCueLogicalDevs(" + nCueLogicalDevCount + ")\sActualDev=" + gaCueLogicalDevs(nCueLogicalDevCount)\sActualDev + ", \nMidiPhysicalDevPtr=" + gaCueLogicalDevs(nCueLogicalDevCount)\nMidiPhysicalDevPtr)
                EndIf
              EndIf
            EndIf
          Next n
        EndIf
      EndIf ; EndIf (\bExists) And (\bSubEnabled)
    EndWith
  Next j

  For j = 1 To gnLastSub
    With aSub(j)
      If (\bExists) And (\bSubEnabled) And (\bSubTypeP)
        For d1 = 0 To grLicInfo\nMaxAudDevPerSub
          If \sPLLogicalDev[d1]
            \nPLBassDevice[d1] = 1
            For d2 = 0 To nCueLogicalDevCount
              If gaCueLogicalDevs(d2)\bMidiDev = #False
                If \sPLLogicalDev[d1] = gaCueLogicalDevs(d2)\sCueDev
                  \nPLBassDevice[d1] = gaCueLogicalDevs(d2)\nBassDevice
                  \bPLASIO[d1] = gaCueLogicalDevs(d2)\bASIO
                  \nPLBassASIODevice[d1] = gaCueLogicalDevs(d2)\nBassASIODevice
                  If \sPLLogicalDev[d1] <> gaCueLogicalDevs(d2)\sActualDev
                    bCuesChanged = #True
                    \sPLLogicalDev[d1] = gaCueLogicalDevs(d2)\sActualDev
                  EndIf
                  Break
                EndIf
              EndIf
            Next d2
          EndIf
        Next d1
      EndIf
    EndWith
  Next j

  For k = 1 To gnLastAud
    With aAud(k)
      If (\bExists) And (\nFileFormat = #SCS_FILEFORMAT_AUDIO)
        For d1 = 0 To grLicInfo\nMaxAudDevPerAud
          If Len(\sLogicalDev[d1]) = 0
            bFound = #True
          Else
            bFound = #False
            For d2 = 1 To nCueLogicalDevCount
              If gaCueLogicalDevs(d2)\bMidiDev = #False
                If gaCueLogicalDevs(d2)\sCueDev = \sLogicalDev[d1]
                  bFound = #True
                  Break
                EndIf
              EndIf
            Next d2
          EndIf
          If bFound = #False
            nCueLogicalDevCount + 1
            If nCueLogicalDevCount > ArraySize(gaCueLogicalDevs())
              ReDim gaCueLogicalDevs(nCueLogicalDevCount+20)
            EndIf
            gaCueLogicalDevs(nCueLogicalDevCount)\sCueDev = \sLogicalDev[d1]
            gaCueLogicalDevs(nCueLogicalDevCount)\bMidiDev = #False
            gsSelectedDevice = \sLogicalDev[d1]
            nBassDevice = 1 ; use device 1 if logical device not found
            bASIO = #False
            nBassASIODevice = -1
            
            For d2 = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
              If grProd\aAudioLogicalDevs(d2)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
                d3 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
                While d3 >= 0
                  If \sLogicalDev[d1] = grMaps\aDev(d3)\sLogicalDev
                    nBassDevice = grMaps\aDev(d3)\nBassDevice
                    bASIO = grMaps\aDev(d3)\bBassASIO
                    nBassASIODevice = grMaps\aDev(d3)\nBassASIODevice
                    bFound = #True
                    Break 2
                  EndIf
                  d3 = grMaps\aDev(d3)\nNextDevIndex
                Wend
              EndIf
            Next d2
            If bFound
              gaCueLogicalDevs(nCueLogicalDevCount)\sActualDev = gsSelectedDevice
              gaCueLogicalDevs(nCueLogicalDevCount)\nBassDevice = nBassDevice
              gaCueLogicalDevs(nCueLogicalDevCount)\bASIO = bASIO
              gaCueLogicalDevs(nCueLogicalDevCount)\nBassASIODevice = nBassASIODevice
            EndIf
          EndIf
        Next d1
      EndIf
      
    EndWith
  Next k

  For k = 1 To gnLastAud
    With aAud(k)
      If (\bExists) And (\nFileFormat = #SCS_FILEFORMAT_AUDIO)
        For d1 = 0 To grLicInfo\nMaxAudDevPerAud
          If \sLogicalDev[d1]
            If grMMedia\nMaxBassDevice = 0
              \nBassDevice[d1] = 0
            Else
              \nBassDevice[d1] = 1
            EndIf
            \bASIO[d1] = #False
            \nBassASIODevice[d1] = -1
            For d2 = 0 To nCueLogicalDevCount
              If gaCueLogicalDevs(d2)\bMidiDev = #False
                If \sLogicalDev[d1] = gaCueLogicalDevs(d2)\sCueDev
                  \nBassDevice[d1] = gaCueLogicalDevs(d2)\nBassDevice
                  \bASIO[d1] = gaCueLogicalDevs(d2)\bASIO
                  \nBassASIODevice[d1] = gaCueLogicalDevs(d2)\nBassASIODevice
                  If \sLogicalDev[d1] <> gaCueLogicalDevs(d2)\sActualDev
                    bCuesChanged = #True
                    \sLogicalDev[d1] = gaCueLogicalDevs(d2)\sActualDev
                  EndIf
                  Break
                EndIf
              EndIf
            Next d2
          EndIf
        Next d1
      EndIf
      
      If (\bExists) And (\nFileFormat = #SCS_FILEFORMAT_MIDI)
        If \sLogicalDev
          \nMidiPhysicalDevPtr = 0
          For d2 = 0 To nCueLogicalDevCount
            ; debugMsg(sProcName, "gaCueLogicalDevs(" + d2 + ")\sCueDev=" + gaCueLogicalDevs(d2)\sCueDev + ", \bMidiDev=" + strB(gaCueLogicalDevs(d2)\bMidiDev))
            If gaCueLogicalDevs(d2)\bMidiDev = #True
              If \sLogicalDev = gaCueLogicalDevs(d2)\sCueDev
                ; debugMsg(sProcName, "gaCueLogicalDevs(" + d2 + ")\nMidiPhysicalDevPtr=" + gaCueLogicalDevs(d2)\nMidiPhysicalDevPtr)
                \nMidiPhysicalDevPtr = gaCueLogicalDevs(d2)\nMidiPhysicalDevPtr
                If \sLogicalDev <> gaCueLogicalDevs(d2)\sActualDev
                  bCuesChanged = #True
                  \sLogicalDev = gaCueLogicalDevs(d2)\sActualDev
                EndIf
                Break
              EndIf
            EndIf
          Next d2
          ; debugMsg(sProcName, \sAudLabel + " \sLogicalDev=" + \sLogicalDev + " \nMidiPhysicalDevPtr=" + \nMidiPhysicalDevPtr)
        EndIf
      EndIf
      
    EndWith
  Next k
  
  For n = 0 To (gnNumMidiOutDevs-1)
    bMidiFilePlayback = #False
    For k = 1 To gnLastAud
      With aAud(k)
        If \bAudTypeM
          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sLogicalDev=" + \sLogicalDev + ", \nMidiPhysicalDevPtr=" + \nMidiPhysicalDevPtr + ", n=" + n)
          If (\bExists) And \sLogicalDev
            If \nMidiPhysicalDevPtr = n
              bMidiFilePlayback = #True
              Break
            EndIf
          EndIf
        EndIf
      EndWith
    Next k
    ; debugMsg(sProcName, "gaMidiOutDevice(" + n + ")\bMidiFilePlayback=" + strB(gaMidiOutDevice(n)\bMidiFilePlayback) + ", \hMidiOut=" + gaMidiOutDevice(n)\hMidiOut)
    If bMidiFilePlayback
      If gaMidiOutDevice(n)\hMidiOut <> 0
        debugMsg(sProcName, "calling MidiOut_Port('close', " + n + ", 'ctrlsend')")
        MidiOut_Port("close", n, "ctrlsend")
      EndIf
    EndIf
    gaMidiOutDevice(n)\bMidiFilePlayback = bMidiFilePlayback
    If gaMidiOutDevice(n)\bMidiFilePlayback
      debugMsg(sProcName, "gaMidiOutDevice(" + n + ")\bMidiFilePlayback=" + strB(gaMidiOutDevice(n)\bMidiFilePlayback))
    EndIf
  Next n
  
  If bCuesChanged
    debugMsg(sProcName, "Cues changed")
  Else
    debugMsg(sProcName, "Cues not changed")
  EndIf

  debugMsg(sProcName, #SCS_END + ", returning " + strB(bCuesChanged))
  
  ProcedureReturn bCuesChanged

EndProcedure

Procedure setCuePosition(pCuePtr)
  PROCNAMECQ(pCuePtr)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_SET_CUE_POSITION, pCuePtr)
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)
  
  If (gbGridLoaded) And (gbStoppingEverything = #False)
    setGridRow(pCuePtr)
  EndIf

  debugMsg(sProcName, "calling resetCueStates(" + getCueLabel(pCuePtr) + ")")
  resetCueStates(pCuePtr)
  
  ; added 1Mar2019 11.8.0.2aw
  debugMsg(sProcName, "calling resetGaplessFirstAudPtrsIfReqd()")
  resetGaplessFirstAudPtrsIfReqd()
  ; end added 1Mar2019 11.8.0.2aw
  
  debugMsg(sProcName, "calling ONC_openNextCues(" + getCueLabel(pCuePtr) + ")")
  ONC_openNextCues(pCuePtr)
  
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  debugMsg(sProcName, "calling highlightLine(" + getCueLabel(pCuePtr) + ")")
  highlightLine(pCuePtr)
  gbCallSetNavigateButtons = #True
  If gbStoppingEverything = #False
    SAG(-1)
  EndIf
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure setCuePtrs(bFirstTime)
  PROCNAMEC()

  ; SEE ALSO setCuePtrs2nd, which is used for setting cue pointers in the secondary arrays when IMPORTING a cue file

  ; WARNING! If bFirstTime is True then the following indexes will be reset:
  ;   aCue(i)\nFirstSubIndex
  ;       aSub(j)\nCueIndex
  ;       aSub(j)\nPrevSubIndex
  ;       aSub(j)\nNextSubIndex
  ;  The sub indexes are based on the physical order of the subs in the array aSub,
  ;  so DO NOT set bFirstTime to True if the order of the subs has been changed by the user

  Protected h, i, i2, j, j2, k, k2, k3, nPrevIndex, n, d
  Protected bFirst, nMasterAud
  
  debugMsg(sProcName, #SCS_START)

  For i = 1 To gnLastCue
    With aCue(i)
      If \nAutoActCueSelType = #SCS_ACCUESEL_PREV
        setCuePtrForAutoStartPrevCueType(i)
      ElseIf \sAutoActCue
        For i2 = 1 To gnLastCue
          If aCue(i2)\sCue = \sAutoActCue
            \nAutoActCuePtr = i2
            Break
          EndIf
        Next i2
      EndIf
    EndWith
  Next i

  ; set nSubRef values where required
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists
        If \nSubRef = -1
          gnUniqueRef + 1
          \nSubRef = gnUniqueRef
          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubRef=" + \nSubRef)
        EndIf
      EndIf
    EndWith
  Next j

  ; set any necessary level change subno's (from version 8 file)
  For j = 1 To gnLastSub
    With aSub(j)
      If (\bExists) And (\bSubTypeL)
        If \nLCSubNo = -1
          For j2 = 1 To gnLastSub
            If aSub(j2)\bExists
              If aSub(j2)\sCue = \sLCCue
                If aSub(j2)\bSubTypeAorF
                  \nLCSubNo = aSub(j2)\nSubNo
                  Break
                EndIf
              EndIf
            EndIf
          Next j2
        EndIf
      EndIf
    EndWith
  Next j

  ; set sub parent and sibling indexes
  If bFirstTime
    For i = 1 To gnLastCue
      With aCue(i)
        bFirst = #True
        nPrevIndex = -1
        \nFirstSubIndex = -1
        For j = 1 To gnLastSub
          If aSub(j)\bExists
            If aSub(j)\sCue = \sCue
              aSub(j)\nCueIndex = i
              If bFirst
                \nFirstSubIndex = j
                bFirst = #False
              EndIf
              aSub(j)\nPrevSubIndex = nPrevIndex
              If nPrevIndex <> -1
                aSub(nPrevIndex)\nNextSubIndex = j
              EndIf
              nPrevIndex = j
            EndIf
          EndIf
        Next j
      EndWith
    Next i
    
    ; set aud parent and sibling indexes
    For j = 1 To gnLastSub
      With aSub(j)
        If \bExists
          bFirst = #True
          nPrevIndex = -1
          \nFirstAudIndex = -1
          ; debugMsg0(sProcName, "aSub(" + j + ")\bSubTypeHasAuds=" + strB(\bSubTypeHasAuds))
          ; debugMsg(sProcName, "aSub(" + j + ")\nFirstAudIndex=" + aSub(j)\nFirstAudIndex)
          If \bSubTypeHasAuds
            For k = 1 To gnLastAud
              If aAud(k)\bExists
                If (aAud(k)\sCue = \sCue) And (aAud(k)\nSubNo = \nSubNo)
                  aAud(k)\nCueIndex = \nCueIndex
                  aAud(k)\nSubIndex = j
                  If bFirst
                    \nFirstAudIndex = k
                    ; debugMsg0(sProcName, "aSub(" + j + ")\nFirstAudIndex=" + aSub(j)\nFirstAudIndex)
                    bFirst = #False
                  EndIf
                  aAud(k)\nPrevAudIndex = nPrevIndex
                  If nPrevIndex <> -1
                    aAud(nPrevIndex)\nNextAudIndex = k
                    ; debugMsg0(sProcName, "(@@a) aAud(" + getAudLabel(nPrevIndex) + ")\nNextAudIndex=" + getAudLabel(aAud(nPrevIndex)\nNextAudIndex))
                  EndIf
                  nPrevIndex = k
                  ; debugMsg0(sProcName, "aAud(" + k + ")\nCueIndex=" + aAud(k)\nCueIndex + ", \nSubIndex=" + aAud(k)\nSubIndex)
                EndIf
              EndIf
            Next k
          EndIf
          ; Added 26Aug2023 11.10.3bn following bug reported by Lloyd Grounds, where his cue file seems possibly corrupt as the Placeholder item was not set for a playlist sub-cue that had no audio files.
          ; So the following is a work-around
          If \bSubTypeP
            If \nFirstAudIndex = -1 And \bSubPlaceHolder = #False
              debugMsg(sProcName, "setting aSub(" + getSubLabel(j) + ")\bSubPlaceHolder = #True")
              \bSubPlaceHolder = #True
            EndIf
          EndIf
          ; End added 26Aug2023 11.10.3bn
        EndIf
      EndWith
    Next j
  Else    ; not first time - just reset \nCueIndex and \nSubIndex
    For i = 1 To gnLastCue
      With aCue(i)
        j = \nFirstSubIndex
        While j >= 0
          aSub(j)\nCueIndex = i
          If aSub(j)\bSubTypeHasAuds
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              aAud(k)\nCueIndex = i
              aAud(k)\nSubIndex = j
              ; debugMsg(sProcName, "aAud(" + k + ")\nCueIndex=" + aAud(k)\nCueIndex + ", \nSubIndex=" + aAud(k)\nSubIndex)
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndWith
    Next i
  EndIf

  ; set call cue ptrs
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists And \bSubTypeQ
        If \sCallCue
          For i = 1 To gnLastCue
            If aCue(i)\sCue = \sCallCue
              If \nCallCuePtr <> i
                ; debugMsg(sProcName, "setting aSub(" + j + ")\nCallCuePtr=" + i + ", was " + \nCallCuePtr)
                \nCallCuePtr = i
              EndIf
              Break
            EndIf
          Next i
        EndIf
      EndIf
    EndWith
  Next j
  
  ; must call setDerivedCueFields now to set \bSubType... fields
  For i = 1 To gnLastCue
    setDerivedCueFields(i, #False)
  Next i

  ; set aAud(k)\nVSTPluginSameAsSubRef values where required
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists
        If \bSubTypeF
          k = \nFirstAudIndex
          If k >= 0
            aAud(k)\nVSTPluginSameAsSubRef = grAudDef\nVSTPluginSameAsSubRef
            If aAud(k)\sVSTPluginSameAsCue
              i2 = getCuePtr(aAud(k)\sVSTPluginSameAsCue)
              j2 = getSubPtrForCueSubNo(i2, aAud(k)\nVSTPluginSameAsSubNo)
              If j2 >= 0
                aAud(k)\nVSTPluginSameAsSubRef = aSub(j2)\nSubRef
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) +")\nVSTPluginSameAsSubRef=" + aAud(k)\nVSTPluginSameAsSubRef)
              EndIf
            EndIf ; EndIf aAud(k)\sVSTPluginSameAsCue
          EndIf ; EndIf k >= 0
        EndIf ; EndIf \bSubTypeF
      EndIf ; EndIf \bExists
    EndWith
  Next j
  
  ; set nLCSubRef and nSetPosSubRef values where required
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists
        If \bSubTypeL
          If \nLCSubRef = -1
            For j2 = 1 To gnLastSub
              If aSub(j2)\bExists
                If aSub(j2)\bSubTypeHasAuds
                  If (aSub(j2)\sCue = \sLCCue) And (aSub(j2)\nSubNo = \nLCSubNo)
                    \nLCSubRef = aSub(j2)\nSubRef
                    ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nLCSubRef=" + \nLCSubRef)
                    Break
                  EndIf
                EndIf
              EndIf
            Next j2
          EndIf
        EndIf
      EndIf ; EndIf \bExists
    EndWith
  Next j
  
  ; set 'level change' and 'set position' cue and sub pointers
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists
        If \bSubTypeL
          For j2 = 1 To gnLastSub
            If aSub(j2)\bExists
              If (aSub(j2)\sCue = \sLCCue) And (aSub(j2)\nSubRef = \nLCSubRef)
                \nLCCuePtr = aSub(j2)\nCueIndex
                \nLCSubPtr = j2
                \nLCAudPtr = aSub(j2)\nFirstAudIndex
                Break
              EndIf
            EndIf
          Next j2
        EndIf
      EndIf ; EndIf \bExists
    EndWith
  Next j
  
  ; set nSFRSubRef[] values where required
  For j = 1 To gnLastSub
    With aSub(j)
      If (\bExists) And (\bSubTypeS)
        For h = 0 To #SCS_MAX_SFR
          If \nSFRSubNo[h] <= 0
            \nSFRSubRef[h] = -1
          ElseIf \nSFRSubRef[h] = -1
            For j2 = 1 To gnLastSub
              If (aSub(j2)\sCue = \sSFRCue[h]) And (aSub(j2)\nSubNo = \nSFRSubNo[h])
                \nSFRSubRef[h] = aSub(j2)\nSubRef
                ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSFRSubRef[" + h + "]=" + \nSFRSubRef[h])
                Break
              EndIf
            Next j2
          EndIf
        Next h
      EndIf
    EndWith
  Next j
  
  ; set SFR cue and sub pointers
  For j = 1 To gnLastSub
    With aSub(j)
      If (\bExists) And (\bSubTypeS)
        For h = 0 To #SCS_MAX_SFR
          If \nSFRCueType[h] = #SCS_SFR_CUE_PREV
            setCuePtrForSFRPrevCueType(j, h)
          Else
            \nSFRCuePtr[h] = -1
            \nSFRSubPtr[h] = -1
            If \nSFRCueType[h] = #SCS_SFR_CUE_SEL
              If \sSFRCue[h]
                For i = 1 To gnLastCue
                  If aCue(i)\sCue = \sSFRCue[h]
                    \nSFRCuePtr[h] = i
                    If \nSFRSubNo[h] > 0
                      j2 = aCue(i)\nFirstSubIndex
                      While j2 >= 0
                        If aSub(j2)\nSubRef = \nSFRSubRef[h]
                          \nSFRSubPtr[h] = j2
                          Break
                        EndIf
                        j2 = aSub(j2)\nNextSubIndex
                      Wend
                    EndIf
                    Break
                  EndIf
                Next i
              EndIf
            EndIf
          EndIf
        Next h
      EndIf
    EndWith
  Next j
  
;   ; set call cue
;   For j = 1 To gnLastSub
;     With aSub(j)
;       If \bExists And \bSubTypeQ
;         If \sCallCue
;           For i = 1 To gnLastCue
;             If aCue(i)\sCue = \sCallCue
;               If \nCallCuePtr <> i
;                 debugMsg(sProcName, "setting aSub(" + j + ")\nCallCuePtr=" + i + ", was " + \nCallCuePtr)
;                 \nCallCuePtr = i
;               EndIf
;               Break
;             EndIf
;           Next i
;         EndIf
;       EndIf
;     EndWith
;   Next j
  
;debugMsg(sProcName, "i")
  ; set linked pointers (nb link may be cancelled when files are opened if not the same duration)
  For i = 1 To gnLastCue
    With aCue(i)
      \nCueLinkCount = 0
      \nLinkedToCuePtr = -1
      \nFirstCueLink = -1
    EndWith
  Next i

;debugMsg(sProcName, "j")
  ; set playlist logical devices by propogating sub devices to aud's
  For k = 1 To gnLastAud
    With aAud(k)
      If \bExists
        \nAudLinkCount = 0
        \nLinkedToAudPtr = -1
        ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nLinkedToAudPtr=" + getAudLabel(\nLinkedToAudPtr))
        \nFirstAudLink = -1
        \nMaxAudSetPtr2 = -1
        \bAudTypeA = aSub(\nSubIndex)\bSubTypeA
        \bAudTypeF = aSub(\nSubIndex)\bSubTypeF
        \bAudTypeI = aSub(\nSubIndex)\bSubTypeI
        \bAudTypeP = aSub(\nSubIndex)\bSubTypeP
        \bAudTypeM = aSub(\nSubIndex)\bSubTypeM
        \bAudTypeAorF = aSub(\nSubIndex)\bSubTypeAorF
        \bAudTypeAorP = aSub(\nSubIndex)\bSubTypeAorP
        \bAudTypeForP = aSub(\nSubIndex)\bSubTypeForP
        \bLiveInput = aSub(\nSubIndex)\bLiveInput
        If \bAudTypeP
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If d <= grLicInfo\nMaxAudDevPerSub
              \sLogicalDev[d] = aSub(\nSubIndex)\sPLLogicalDev[d]
            Else
              \sLogicalDev[d] = ""
            EndIf
            ; debugMsg(sProcName, "aAud(" + k + ")\sLogicalDev[" + d + "]=" + \sLogicalDev[d])
          Next d
        EndIf
      EndIf
    EndWith
  Next k
  
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists
        If \bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            k = \aCtrlSend[n]\nAudPtr
            If k >= 0
              ; debugMsg(sProcName, "k=" + k + ", ArraySize(aAud())=" + ArraySize(aAud()) + ", n=" + n)
              aAud(k)\sLogicalDev[0] = \aCtrlSend[n]\sCSLogicalDev
            EndIf
          Next n
        EndIf
      EndIf
    EndWith
  Next j
  
  ; debugMsg(sProcName, "calling setLinksForCue() for each cue")
  For i = 1 To gnLastCue
    setLinksForCue(i)
  Next i

  ; set links for auds within each sub
  ; debugMsg(sProcName, "calling setLinksForAudsWithinSubsForCue() for each cue")
  For i = 1 To gnLastCue
    setLinksForAudsWithinSubsForCue(i)
  Next i
  
  setMTCLinksForAllCues()
  
  ; debugMsg(sProcName, "calling setLabels() for each cue")
  For i = 1 To gnLastCue
    setLabels(i)
  Next i
  
  setNonLinearCueFlags()
  
  ; debugMsg(sProcName, "calling buildAudSetArray()")
  buildAudSetArray()
  
  ; debugMsg(sProcName, "calling setGrdCuesRowNos()")
  setGrdCuesRowNos()
  
;   ; debugMsg(sProcName, "calling setAutoActCueMarkerSubAndAudNos()")
;   setAutoActCueMarkerSubAndAudNos()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setCuePtrs2nd(bFirstTime)
  PROCNAMEC()

  ; WARNING! If bFirstTime is True then the following indexes will be reset:
  ;   a2ndCue(i)\nFirstSubIndex
  ;       a2ndSub(j)\nCueIndex
  ;       a2ndSub(j)\nPrevSubIndex
  ;       a2ndSub(j)\nNextSubIndex
  ;  The sub indexes are based on the physical order of the subs in the array aSub,
  ;  so DO NOT set bFirstTime to True if the order of the subs has been changed by the user

  Protected h, i, i2, j, j2, k, k2, k3, nPrevIndex, n, d
  Protected bFirst, nMasterAud

  debugMsg(sProcName, #SCS_START + ", gn2ndLastCue=" + gn2ndLastCue + ", gn2ndLastSub=" + gn2ndLastSub + ", gn2ndLastAud=" + gn2ndLastAud)
  debugMsg(sProcName, "ArraySize(a2ndCue())=" + ArraySize(a2ndCue()) + ", ArraySize(a2ndSub())=" + ArraySize(a2ndSub()) + ", ArraySize(a2ndAud())=" + ArraySize(a2ndAud()))

  For i = 1 To gn2ndLastCue
    With a2ndCue(i)
      If \sAutoActCue
        For i2 = 1 To gn2ndLastCue
          If a2ndCue(i2)\sCue = \sAutoActCue
            \nAutoActCuePtr = i2
            Break
          EndIf
        Next i2
      EndIf
    EndWith
  Next i

  ; set nSubRef values where required
  For j = 1 To gn2ndLastSub
    With a2ndSub(j)
      If \bExists
        If \nSubRef = -1
          gnUniqueRef + 1
          \nSubRef = gnUniqueRef
        EndIf
      EndIf
    EndWith
  Next j

  ; set any necessary level change subno's (from version 8 file)
  For i = 1 To gn2ndLastSub
    With a2ndSub(i)
      If (\bExists) And (\bSubTypeL)
        If \nLCSubNo = -1
          For j = 1 To gn2ndLastSub
            If a2ndSub(j)\bExists
              If a2ndSub(j)\sCue = \sLCCue
                If a2ndSub(j)\bSubTypeAorF
                  \nLCSubNo = a2ndSub(j)\nSubNo
                  Break
                EndIf
              EndIf
            EndIf
          Next j
        EndIf
      EndIf
    EndWith
  Next i

  ; set sub parent and sibling indexes
  If bFirstTime
    For i = 1 To gn2ndLastCue
      With a2ndCue(i)
        bFirst = #True
        nPrevIndex = -1
        \nFirstSubIndex = -1
        For j = 1 To gn2ndLastSub
          If a2ndSub(j)\bExists
            If a2ndSub(j)\sCue = \sCue
              a2ndSub(j)\nCueIndex = i
              If bFirst
                \nFirstSubIndex = j
                bFirst = #False
              EndIf
              a2ndSub(j)\nPrevSubIndex = nPrevIndex
              If nPrevIndex <> -1
                a2ndSub(nPrevIndex)\nNextSubIndex = j
              EndIf
              nPrevIndex = j
            EndIf
          EndIf
        Next j
      EndWith
    Next i
    
    ; set aud parent and sibling indexes
    For j = 1 To gn2ndLastSub
      With a2ndSub(j)
        If \bExists
          bFirst = #True
          nPrevIndex = -1
          \nFirstAudIndex = -1
          ; debugMsg(sProcName, "a2ndSub(" + j + ")\nFirstAudIndex=" + a2ndSub(j)\nFirstAudIndex + ", \sCue=" + \sCue + ", \nSubNo=" + \nSubNo + ", \nCueIndex=" + \nCueIndex + ", gn2ndLastAud=" + gn2ndLastAud)
          For k = 1 To gn2ndLastAud
            ; debugMsg(sProcName, "a2ndAud(" + k + ")\bExists=" + strB(a2ndAud(k)\bExists) + ", \sCue=" + a2ndAud(k)\sCue + ", \nSubNo=" + a2ndAud(k)\nSubNo)
            If a2ndAud(k)\bExists
              If (a2ndAud(k)\sCue = \sCue) And (a2ndAud(k)\nSubNo = \nSubNo)
                a2ndAud(k)\nCueIndex = \nCueIndex
                a2ndAud(k)\nSubIndex = j
                If bFirst
                  \nFirstAudIndex = k
                  ; debugMsg(sProcName, "a2ndSub(" + j + ")\nFirstAudIndex=" + a2ndSub(j)\nFirstAudIndex)
                  bFirst = #False
                EndIf
                a2ndAud(k)\nPrevAudIndex = nPrevIndex
                If nPrevIndex <> -1
                  a2ndAud(nPrevIndex)\nNextAudIndex = k
                EndIf
                nPrevIndex = k
              EndIf
            EndIf
          Next k
        EndIf
      EndWith
    Next j
  Else    ; not first time - just reset \nCueIndex and \nSubIndex
    For i = 1 To gn2ndLastCue
      j = a2ndCue(i)\nFirstSubIndex
      While j >= 0
        With a2ndSub(j)
          \nCueIndex = i
          If \bSubTypeHasAuds
            k = \nFirstAudIndex
            While k >= 0
              a2ndAud(k)\nCueIndex = i
              a2ndAud(k)\nSubIndex = j
              k = a2ndAud(k)\nNextAudIndex
            Wend
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    Next i
  EndIf

  ; must call setDerivedCueFields now to set \bSubType... fields
  For i = 1 To gn2ndLastCue
    setDerivedCueFields2(i, #False)
  Next i
  
  ; set nLCSubRef and nSetPosSubRef values where required
  For j = 1 To gn2ndLastSub
    With a2ndSub(j)
      If \bExists
        If \bSubTypeL
          If \nLCSubRef = -1
            For j2 = 1 To gn2ndLastSub
              If a2ndSub(j2)\bSubTypeHasAuds
                If (a2ndSub(j2)\sCue = \sLCCue) And (a2ndSub(j2)\nSubNo = \nLCSubNo)
                  \nLCSubRef = a2ndSub(j2)\nSubRef
                  ; debugMsg(sProcName, "a2ndSub(" + getSubLabel(j) + ")\nLCSubRef=" + \nLCSubRef)
                  Break
                EndIf
              EndIf
            Next j2
          EndIf
        EndIf
      EndIf
    EndWith
  Next j
  
  ; set 'level change' and 'set position' cue and sub pointers
  For j = 1 To gn2ndLastSub
    With a2ndSub(j)
      If \bExists
        If \bSubTypeL
          For j2 = 1 To gn2ndLastSub
            If a2ndSub(j2)\bExists
              If (a2ndSub(j2)\sCue = \sLCCue) And (a2ndSub(j2)\nSubRef = \nLCSubRef)
                \nLCCuePtr = a2ndSub(j2)\nCueIndex
                \nLCSubPtr = j2
                \nLCAudPtr = a2ndSub(j2)\nFirstAudIndex
                Break
              EndIf
            EndIf
          Next j2
        EndIf
      EndIf
    EndWith
  Next j
  
  ; debugMsg(sProcName, "h")
  ; set sfr cue pointers
  For j = 1 To gn2ndLastSub
    With a2ndSub(j)
      If (\bExists) And (\bSubTypeS)
        For h = 0 To #SCS_MAX_SFR
          If \nSFRCueType[h] = #SCS_SFR_CUE_PREV
            setCuePtrForSFRPrevCueType2(j, h)
          Else
            \nSFRCuePtr[h] = -1
            If \nSFRCueType[h] = #SCS_SFR_CUE_SEL
              If \sSFRCue[h]
                For i = 1 To gn2ndLastCue
                  If a2ndCue(i)\sCue = \sSFRCue[h]
                    \nSFRCuePtr[h] = i
                    Break
                  EndIf
                Next i
              EndIf
            EndIf
          EndIf
        Next h
      EndIf
    EndWith
  Next j
  
  ; set linked pointers (nb link may be cancelled when files are opened if not the same duration)
  For i = 1 To gn2ndLastCue
    With a2ndCue(i)
      \nCueLinkCount = 0
      \nLinkedToCuePtr = -1
      \nFirstCueLink = -1
    EndWith
  Next i

  ; set playlist logical devices by propogating sub devices to aud's
  For k = 1 To gn2ndLastAud
    With a2ndAud(k)
      If \bExists
        \nAudLinkCount = 0
        \nLinkedToAudPtr = -1
        ; debugMsg(sProcName, "a2ndAud(" + getAudLabel(k) + ")\nLinkedToAudPtr=" + getAudLabel(\nLinkedToAudPtr))
        \nFirstAudLink = -1
        \nMaxAudSetPtr2 = -1
        \bAudTypeA = a2ndSub(\nSubIndex)\bSubTypeA
        \bAudTypeF = a2ndSub(\nSubIndex)\bSubTypeF
        \bAudTypeI = a2ndSub(\nSubIndex)\bSubTypeI
        \bAudTypeM = a2ndSub(\nSubIndex)\bSubTypeM
        \bAudTypeP = a2ndSub(\nSubIndex)\bSubTypeP
        \bAudTypeAorF = a2ndSub(\nSubIndex)\bSubTypeAorF
        \bAudTypeAorP = a2ndSub(\nSubIndex)\bSubTypeAorP
        \bAudTypeForP = a2ndSub(\nSubIndex)\bSubTypeForP
        \bLiveInput = a2ndSub(\nSubIndex)\bLiveInput
        If \bAudTypeP
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If d <= grLicInfo\nMaxAudDevPerAud
              \sLogicalDev[d] = a2ndSub(\nSubIndex)\sPLLogicalDev[d]
            Else
              \sLogicalDev[d] = ""
            EndIf
          Next d
        EndIf
      EndIf
    EndWith
  Next k
  
  For j = 1 To gn2ndLastSub
    With a2ndSub(j)
      If \bExists
        If \bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            k = \aCtrlSend[n]\nAudPtr
            If k >= 0
              a2ndAud(k)\sLogicalDev[0] = \aCtrlSend[n]\sCSLogicalDev
            EndIf
          Next n
        EndIf
      EndIf
    EndWith
  Next j
  
  
  For i = 1 To gn2ndLastCue
    set2ndLabels(i)
  Next i

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setCuePtrForSFRPrevCueType(pSubPtr, pSFRIndex)
  PROCNAMECS(pSubPtr)
  Protected nThisCuePtr, nPrevCuePtr
  Protected h, i
  
  With aSub(pSubPtr)
    nThisCuePtr = \nCueIndex
    nPrevCuePtr = -1
    For i = 1 To (nThisCuePtr - 1)
      If aCue(i)\bCueCurrentlyEnabled
        If (aCue(i)\bSubTypeA) Or (aCue(i)\bSubTypeE) Or (aCue(i)\bSubTypeF) Or (aCue(i)\bSubTypeI) Or (aCue(i)\bSubTypeK) Or (aCue(i)\bSubTypeM) Or (aCue(i)\bSubTypeP) Or (aCue(i)\bSubTypeU)
          nPrevCuePtr = i
        EndIf
      EndIf
    Next i
    ; nb nPrevCuePtr will be -1 if this SFR cue doesn't have any or a suitable 'previous cue'
    If nPrevCuePtr >= 0
      \nSFRCuePtr[pSFRIndex] = nPrevCuePtr
      \sSFRCue[pSFRIndex] = aCue(nPrevCuePtr)\sCue
      \nSFRSubNo[pSFRIndex] = -1
      \nSFRSubPtr[pSFRIndex] = -1
      \nSFRSubRef[pSFRIndex] = -1
    EndIf
  EndWith
  
EndProcedure

Procedure setCuePtrForSFRPrevCueType2(pSubPtr, pSFRIndex)
  PROCNAMECS(pSubPtr, #False)
  Protected nThisCuePtr, nPrevCuePtr
  Protected h, i
  
  With a2ndSub(pSubPtr)
    nThisCuePtr = \nCueIndex
    nPrevCuePtr = -1
    For i = 1 To nThisCuePtr - 1
      If a2ndCue(i)\bCueCurrentlyEnabled
        If (a2ndCue(i)\bSubTypeA) Or (a2ndCue(i)\bSubTypeE) Or (a2ndCue(i)\bSubTypeF) Or (a2ndCue(i)\bSubTypeI) Or (a2ndCue(i)\bSubTypeK) Or (a2ndCue(i)\bSubTypeM) Or (a2ndCue(i)\bSubTypeP) Or (a2ndCue(i)\bSubTypeU)
          nPrevCuePtr = i
        EndIf
      EndIf
    Next i
    \nSFRCuePtr[pSFRIndex] = nPrevCuePtr
    \sSFRCue[pSFRIndex] = a2ndCue(nPrevCuePtr)\sCue
    \nSFRSubNo[pSFRIndex] = -1
    \nSFRSubPtr[pSFRIndex] = -1
    \nSFRSubRef[pSFRIndex] = -1
  EndWith
  
EndProcedure

Procedure setCuePtrForAutoStartPrevCueType(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nPrevCuePtr
  Protected i
  
  nPrevCuePtr = -1
  For i = 1 To pCuePtr - 1
    If aCue(i)\bCueCurrentlyEnabled
      nPrevCuePtr = i
    EndIf
  Next i
  If nPrevCuePtr = -1
    ; will occur if all earlier cues are disabled
    nPrevCuePtr = pCuePtr - 1
  EndIf
  With aCue(pCuePtr)
    \nAutoActCuePtr = nPrevCuePtr
    If nPrevCuePtr >= 0
      \sAutoActCue = aCue(nPrevCuePtr)\sCue
    EndIf
  EndWith
  
EndProcedure

Procedure setCuePtrForAutoStartPrevCueType2(pCuePtr)
  PROCNAMECQ2(pCuePtr)
  Protected nPrevCuePtr
  Protected i
  
  nPrevCuePtr = -1
  For i = 1 To pCuePtr - 1
    If a2ndCue(i)\bCueCurrentlyEnabled
      nPrevCuePtr = i
    EndIf
  Next i
  If nPrevCuePtr = -1
    ; will occur if all earlier cues are disabled
    nPrevCuePtr = pCuePtr - 1
  EndIf
  With a2ndCue(pCuePtr)
    \nAutoActCuePtr = nPrevCuePtr
    If nPrevCuePtr >= 0
      \sAutoActCue = a2ndCue(nPrevCuePtr)\sCue
    EndIf
  EndWith
  
EndProcedure

Procedure clearCurrHotkeyToggleState(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nCurrHotkeyPtr
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      If \nActivationMethod = #SCS_ACMETH_HK_TOGGLE
        nCurrHotkeyPtr = getCurrHotkeyPtrForCuePtr(pCuePtr)
        If nCurrHotkeyPtr >= 0
          debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(\nCueState) + ", gaCurrHotkeys(" + nCurrHotkeyPtr + ")\nToggleState=" + gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState)
          If gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState <> 0
            gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState = 0
            debugMsg(sProcName, "gaCurrHotkeys(" + nCurrHotkeyPtr + ")\nToggleState=" + gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState)
            debugMsg(sProcName, "calling saveCurrHotkeyInfo(" + nCurrHotkeyPtr + ")")
            saveCurrHotkeyInfo(nCurrHotkeyPtr)
            gqMainThreadRequest | #SCS_MTH_DISPLAY_OR_HIDE_HOTKEYS
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure getCueStatePriority(nCueState)
  PROCNAMEC()
  ; Calculates a 'priority' for a cue state for determining what sub-cue state should be set based on the aud-states of the sub-cue's auds,
  ; and what cue state should be set based on the sub-states of the cue's subs.
  ; Designed for the Procedure setCueState().
  Protected nCueStatePriority ; Low numbers are higher priority, ie 0 is highest priority.
  
  Select nCueState
    Case #SCS_CUE_ERROR
      nCueStatePriority = 0
    Case #SCS_CUE_PLAYING
      nCueStatePriority = 1 ; This is the highest priority apart from 'ERROR'. EG, if at least one sub-cue in a cue is 'Playing' then that cue's state will also be set to 'Playing' by the Procedure setCueStateFast().
    Case #SCS_CUE_PAUSED
      nCueStatePriority = 2 ; Continuing the above example, if NONE of the sub-cues are playing but one sub-cue is currently 'Paused', then the cue will be marked as 'Paused'.
    Case #SCS_CUE_FADING_IN
      nCueStatePriority = 3 ; If NONE of the sub-cues are 'Playing' or 'Paused' but one is 'Fiding In', then the cue will be marked as 'Fading In'.
    Case #SCS_CUE_TRANS_FADING_IN
      nCueStatePriority = 4 ; ETC
    Case #SCS_CUE_CHANGING_LEVEL
      nCueStatePriority = 5
    Case #SCS_CUE_RELEASING
      nCueStatePriority = 6
    Case #SCS_CUE_STOPPING
      nCueStatePriority = 7
    Case #SCS_CUE_HIBERNATING
      nCueStatePriority = 8
    Case #SCS_CUE_TRANS_MIXING_OUT
      nCueStatePriority = 9
    Case #SCS_CUE_TRANS_FADING_OUT
      nCueStatePriority = 10
    Case #SCS_CUE_FADING_OUT
      nCueStatePriority = 11
    Case #SCS_CUE_COUNTDOWN_TO_START
      nCueStatePriority = 12
    Case #SCS_CUE_SUB_COUNTDOWN_TO_START
      nCueStatePriority = 13
    Case #SCS_CUE_PL_COUNTDOWN_TO_START
      nCueStatePriority = 14
    Case #SCS_CUE_WAITING_FOR_CONFIRM
      nCueStatePriority = 15
    Case #SCS_CUE_READY
      nCueStatePriority = 16
    Case #SCS_CUE_PL_READY
      nCueStatePriority = 17
    Case #SCS_CUE_STANDBY
      nCueStatePriority = 18
    Case #SCS_CUE_COMPLETED
      nCueStatePriority = 19
    Case #SCS_CUE_NOT_LOADED
      nCueStatePriority = 21
    Case #SCS_CUE_IGNORED
      nCueStatePriority = 22
    Case #SCS_CUE_STATE_NOT_SET
      nCueStatePriority = 23 ; Shouldn't get here
  EndSelect
  ProcedureReturn nCueStatePriority
EndProcedure

Procedure setCueState(pCuePtr, bIncludeSubCountDown=#False, bIgnoreStartedInEditor=#False, bForceLoadGridRow=#False)
  PROCNAMECQ(pCuePtr)
  Protected j, k, h, m, nLoopIndex, nVidPicTarget, nReqdState, nCurrHotkeyPtr
  Protected nNewCueState, nNewSubState, nNewAudState
  Protected nCurrCueState, nCurrSubState, nCurrAudState
  Protected sNewCueErrorMsg.s, sNewSubErrorMsg.s
  Protected bCueStartedInEditor, bSubStartedInEditor
  Protected nWorkPriority, nHighestSubStatePriority, nHighestCueStatePriority
  Protected bHideNetworkTracing
  
  If #cTraceNetworkMsgs = #False
    bHideNetworkTracing = #True
  EndIf
  
  aCue(pCuePtr)\bRedoCueState = #False
  
  nCurrCueState = aCue(pCuePtr)\nCueState
  nNewCueState = #SCS_CUE_STATE_NOT_SET
  sNewCueErrorMsg = ""
  nHighestCueStatePriority = 100 ; arbitrary 'low priority' outside the range of values returned by getCueStatePriority()
  
  bCueStartedInEditor = #True ; may be changed later in this procedure
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    With aSub(j)
      If \bSubEnabled ; \bSubEnabled test added 29Jul2020 11.8.3.2ap following test of "Dizzy Dames - Lighting.scs11" where the second sub-cue of LX-PRE was disabled, and the 'next manual cue' then constantly stayed on LX-PRE
        nCurrSubState = \nSubState
        nNewSubState = #SCS_CUE_STATE_NOT_SET
        sNewSubErrorMsg = ""
        nHighestSubStatePriority = 100 ; arbritary 'low priority' outside the range of values returned by getCueStatePriority()
        If bIgnoreStartedInEditor = #False
          If \bStartedInEditor
            bSubStartedInEditor = #True
          Else
            bSubStartedInEditor = #False
            bCueStartedInEditor = #False
          EndIf
        EndIf
        If \bSubTypeHasAuds And \nFirstAudIndex >= 0
          If (\nSubState <> #SCS_CUE_SUB_COUNTDOWN_TO_START) Or (bIncludeSubCountDown)
            If \nFirstPlayIndex = -1
              If gbInLoadCueFile
                ; debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(j) + ", #True, #False, #True)")
                generatePlayOrder(j, #True, #False, #True)
              Else
                ; debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(j) + ")")
                generatePlayOrder(j)
              EndIf
            EndIf
            k = \nFirstAudIndex
            While k >= 0
              nCurrAudState = aAud(k)\nAudState
              nNewAudState = #SCS_CUE_STATE_NOT_SET
              Select nCurrAudState
                Case #SCS_CUE_COMPLETED, #SCS_CUE_READY, #SCS_CUE_SUB_COUNTDOWN_TO_START
                  For nLoopIndex = 0 To aAud(k)\nMaxLoopInfo
                    aAud(k)\aLoopInfo(nLoopIndex)\bLoopReleased = #False
                  Next nLoopIndex
              EndSelect
              If nCurrAudState = #SCS_CUE_ERROR
                sNewSubErrorMsg = aAud(k)\sErrorMsg
              Else
                If (nCurrAudState < #SCS_CUE_FADING_IN) And ((nCurrSubState = #SCS_CUE_TRANS_FADING_IN) Or (nCurrSubState = #SCS_CUE_PLAYING) Or (nCurrSubState = #SCS_CUE_TRANS_FADING_OUT) Or (nCurrSubState = #SCS_CUE_TRANS_MIXING_OUT))
                  ; do nothing
                ElseIf (nCurrAudState = #SCS_CUE_NOT_LOADED) And (\bSubTypeAorP) And (\bPLTerminating) And (gbStoppingEverything = #False) And (\bHibernating = #False)
                  nNewAudState = #SCS_CUE_COMPLETED
                ElseIf (nCurrAudState = #SCS_CUE_NOT_LOADED) And (nCurrSubState = #SCS_CUE_COMPLETED)
                  ; do nothing
                ElseIf (nCurrAudState = #SCS_CUE_NOT_LOADED) And (\bSubTypeAorP)
                  ; do nothing
                ElseIf (nCurrSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START) And (nCurrAudState = #SCS_CUE_READY) And (k = \nFirstPlayIndex)
                  nNewAudState = #SCS_CUE_SUB_COUNTDOWN_TO_START
                EndIf
              EndIf
              If nNewAudState <> #SCS_CUE_STATE_NOT_SET
                aAud(k)\nAudState = nNewAudState
              EndIf
              nWorkPriority = getCueStatePriority(aAud(k)\nAudState)
              If nWorkPriority < nHighestSubStatePriority
                ; note: low numbers mean higher priority (see Procedure getCueStatePriority())
                nHighestSubStatePriority = nWorkPriority
                nNewSubState = aAud(k)\nAudState
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
            
            If \bSubTypeAorP
              If (\nAudCount = 0) And (nNewSubState = #SCS_CUE_STATE_NOT_SET)
                ; no files in playlist/slideshow
                nNewSubState = #SCS_CUE_COMPLETED
              EndIf
              If \nSubState = #SCS_CUE_PL_READY
                If (nCurrSubState >= #SCS_CUE_FADING_IN) And (nCurrSubState <= #SCS_CUE_FADING_OUT)
                  ; probably between images so leave nSubState unchanged
                  nNewSubState = nCurrSubState
                EndIf
              EndIf
            EndIf
            
            If nNewSubState <> #SCS_CUE_STATE_NOT_SET
              \nSubState = nNewSubState
              If nNewSubState = #SCS_CUE_ERROR
                If sNewSubErrorMsg
                  \sErrorMsg = sNewSubErrorMsg
                EndIf
              EndIf
            EndIf
            nNewSubState = \nSubState ; set nNewSubState for subsequent processing in this aSub(j) loop
            
            ; the following must be executed AFTER the setting of \nSubState above, because \nSubState may or may not have been changed in that code
            If \bSubTypeAorP And nNewSubState = #SCS_CUE_READY
              k = \nFirstPlayIndex
              If k >= 0
                If aAud(k)\nAudState = #SCS_CUE_PL_READY
                  aAud(k)\nAudState = #SCS_CUE_READY
                EndIf
              EndIf
            EndIf
            
            ;------------------------------
            If nNewSubState <> nCurrSubState
              If \bSubTypeA
                Select nNewSubState
                  Case #SCS_CUE_COMPLETED, #SCS_CUE_READY, #SCS_CUE_STANDBY
                    If \bStartedInEditor = #False
                      For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                        If grVidPicTarget(nVidPicTarget)\nCurrentSubPtr = j
                          debugMsg(sProcName, "changing grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nCurrentSubPtr from " + getSubLabel(grVidPicTarget(nVidPicTarget)\nCurrentSubPtr) +
                                              " to " + grVidPicTargetDef\nCurrentSubPtr)
                          grVidPicTarget(nVidPicTarget)\nCurrentSubPtr = grVidPicTargetDef\nCurrentSubPtr
                        EndIf
                      Next nVidPicTarget
                    EndIf
                EndSelect
              EndIf
            EndIf
            
          EndIf ; EndIf (\nSubState <> #SCS_CUE_SUB_COUNTDOWN_TO_START) Or (bIncludeSubCountDown)
          
        EndIf ; EndIf \bSubTypeHasAuds And \nFirstAudIndex >= 0
        
        If nNewSubState = #SCS_CUE_STATE_NOT_SET
          nNewSubState = \nSubState
        EndIf
        
        If \bSubTypeL
          If nNewSubState = #SCS_CUE_NOT_LOADED
            ; copied from setInitCueStates
            If \nLCSubPtr < 0
              nReqdState = #SCS_CUE_NOT_LOADED
            ElseIf (aSub(\nLCSubPtr)\nSubState = #SCS_CUE_NOT_LOADED) And
                   (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND) And (aCue(pCuePtr)\bNonLinearCue)))
              nReqdState = #SCS_CUE_NOT_LOADED
            Else
              nReqdState = #SCS_CUE_READY
            EndIf
            \nSubState = nReqdState
            nNewSubState = nReqdState
          EndIf
          
        ElseIf \bSubTypeS
          If nNewSubState = #SCS_CUE_NOT_LOADED
            ; copied from setInitCueStates
            nReqdState = #SCS_CUE_READY
            If (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND) Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND) And (aCue(pCuePtr)\bNonLinearCue))
              For h = 0 To #SCS_MAX_SFR
                If (\nSFRCueType[h] = #SCS_SFR_CUE_SEL) Or (\nSFRCueType[h] = #SCS_SFR_CUE_PREV)
                  m = \nSFRCuePtr[h]
                  If m >= 0
                    If aCue(m)\nCueState = #SCS_CUE_NOT_LOADED
                      nReqdState = #SCS_CUE_NOT_LOADED
                      Break
                    EndIf
                  EndIf
                EndIf
              Next h
            EndIf
            \nSubState = nReqdState
            nNewSubState = nReqdState
          EndIf
          
        ElseIf \bSubTypeE Or \bSubTypeG Or \bSubTypeI Or \bSubTypeJ Or \bSubTypeK Or \bSubTypeM Or \bSubTypeN Or \bSubTypeQ Or \bSubTypeT
          ; nb can get here for bSubTypeM if there are no MIDI files associated with the control send sub-cue
          If nNewSubState = #SCS_CUE_NOT_LOADED
            ; copied from setInitCueStates()
            \nSubState = #SCS_CUE_READY
            nNewSubState = \nSubState
          EndIf
          
        ElseIf aSub(j)\bSubTypeU
          If nNewSubState = #SCS_CUE_NOT_LOADED
            ; copied from setInitCueStates()
            Select \nMTCType
              Case #SCS_MTC_TYPE_MTC
                ; we can set \nSubState to 'ready' for MTC because SCS generates MTC
                \nSubState = #SCS_CUE_READY
                nNewSubState = \nSubState
              Case #SCS_MTC_TYPE_LTC
                ; do NOT set \nSubState to 'ready' for LTC because SM-S generates LTC and there are a limited number of SM-S TimeCode generators available
            EndSelect
          EndIf
          
        EndIf
        
        If nNewSubState = #SCS_CUE_STATE_NOT_SET
          \nSubState = #SCS_CUE_NOT_LOADED
          nNewSubState = \nSubState
        EndIf
        
        If \bTimeSubStartedSet
          If (nNewSubState <= #SCS_CUE_READY) Or ((nNewSubState >= #SCS_CUE_PL_READY) And (nNewSubState <> #SCS_CUE_COMPLETED))
            \bTimeSubStartedSet = #False
          EndIf
        EndIf
        
        If nNewSubState = #SCS_CUE_ERROR
          If aCue(pCuePtr)\nCueState <> #SCS_CUE_ERROR
            aCue(pCuePtr)\nCueState = #SCS_CUE_ERROR
            nNewCueState = aCue(pCuePtr)\nCueState
            sNewCueErrorMsg = \sErrorMsg
          EndIf
        EndIf
        
        If \bSubCountDownPaused
          If (\nSubState <= #SCS_CUE_READY) Or (\nSubState > #SCS_CUE_FADING_OUT)
            resetSubTimeToStart(j)
            \bSubCountDownPaused = #False
          EndIf
        EndIf
        
        If \bSubCountDownPaused
          If (nNewSubState <= #SCS_CUE_READY) Or (nNewSubState > #SCS_CUE_FADING_OUT)
            resetSubTimeToStart(j)
            \bSubCountDownPaused = #False
          EndIf
        EndIf
        
        If nNewSubState = #SCS_CUE_PAUSED
          If nCurrSubState <> #SCS_CUE_PAUSED
            ; \nSubState has been changed to #SCS_CUE_PAUSED
            ; see also similar code in pauseSub()
            \nSubPrepauseSubState = nCurrSubState
            \qSubTimePauseStarted = ElapsedMilliseconds()
            \nSubPriorTimeOnPause = \nSubTotalTimeOnPause
            \nSubTotalTimeOnPause = 0
            If \bSubTypeU
              grMTCSendControl\nMTCThreadRequest | #SCS_MTC_THR_PAUSE_MTC
            EndIf
          EndIf
        EndIf
        
        ; END OF PROCESSING FOR THIS SUB
        nWorkPriority = getCueStatePriority(\nSubState)
        If nWorkPriority < nHighestCueStatePriority
          ; note: low numbers mean higher priority (see Procedure getCueStatePriority())
          nHighestCueStatePriority = nWorkPriority
          nNewCueState = \nSubState
          ; debugMsg(sProcName, "nNewCueState=" + decodeCueState(nNewCueState) + ", aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(\nSubState))
        EndIf
        
      EndIf ; EndIf \bSubEnabled
      
      j = \nNextSubIndex
    EndWith
  Wend
  
  With aCue(pCuePtr)
    If nNewCueState <> #SCS_CUE_STATE_NOT_SET
      \nCueState = nNewCueState
      If nNewCueState = #SCS_CUE_ERROR
        If sNewCueErrorMsg
          \sErrorMsg = sNewCueErrorMsg
        EndIf
      EndIf
    EndIf
    If nNewCueState <> \nCueState
      nNewCueState = \nCueState ; set nNewSubState for subsequent processing in this aSub(j) loop
      debugMsg(sProcName, "nNewCueState=" + decodeCueState(nNewCueState) + ", aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(\nCueState))
    EndIf
    
    ; the following must be executed AFTER the setting of \nCueState above, because \nCueState may or may not have been changed in that code
    
    If bSubStartedInEditor = #False
      bCueStartedInEditor = #False
    EndIf
    \bRAICueSubStartedInEditor = bCueStartedInEditor
    
    If bCueStartedInEditor
;       If \bCueCompletedBeforeOpenedInEditor = #False
;         nNewCueState = nCurrCueState
;         If nNewCueState <= #SCS_CUE_READY
;           \qTimeCueStarted = 0
;           \bTimeCueStartedSet = #False
;         EndIf
;       EndIf
    Else
      If grM2T\bProcessingApplyMoveToTime = #False ; Test added 30Mar2021 11.8.4.1aj
        If (nNewCueState >= #SCS_CUE_FADING_IN) And (nNewCueState <= #SCS_CUE_FADING_OUT)
          If \bTimeCueStartedSet = #False
            \qTimeCueStarted = ElapsedMilliseconds()
            debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\qTimeCueStarted=" + traceTime(\qTimeCueStarted))
            \bTimeCueStartedSet = #True
            \qTimeCueLastStarted = \qTimeCueStarted
            gnCueStartedCount + 1
            \nCueStartedCount = gnCueStartedCount
          EndIf
          If (nNewCueState = #SCS_CUE_PAUSED) And (nCurrCueState <> #SCS_CUE_PAUSED)
            \qCueTimePauseStarted = ElapsedMilliseconds()
          ElseIf (nNewCueState <> #SCS_CUE_PAUSED) And (nCurrCueState = #SCS_CUE_PAUSED)
            If \qCueTimePauseStarted > 0
              \nCueTotalTimeOnPause + (ElapsedMilliseconds() - \qCueTimePauseStarted)
            EndIf
          EndIf
        EndIf
      EndIf ; EndIf grM2T\bProcessingApplyMoveToTime = #False
    EndIf
    
    If (nNewCueState = #SCS_CUE_COMPLETED) Or (nNewCueState = #SCS_CUE_STANDBY) Or 
      ((nNewCueState <= #SCS_CUE_READY) And (nCurrCueState >= #SCS_CUE_FADING_IN) And (nCurrCueState <> #SCS_CUE_NOT_LOADED) And (nCurrCueState <> #SCS_CUE_STATE_NOT_SET))
      If \bTimeCueStoppedSet = #False Or (nNewCueState = #SCS_CUE_COMPLETED Or nNewCueState = #SCS_CUE_STANDBY) ; nNewCueState tests added 15Oct2020 11.8.3.2bq following test of rewind followed by stop didn't auto-start next auto-start cue
        \qTimeCueStopped = ElapsedMilliseconds()
        \bTimeCueStoppedSet = #True
        \bCueStoppedByStopEverything = gbStoppingEverything
        \bCueStoppedByGoToCue = gbInGoToCue
      EndIf
      If \bCallClearLinksForCue
        clearLinksForCue(pCuePtr)
      EndIf
      If bSubStartedInEditor = #False
        If nNewCueState <> nCurrCueState
          If \nProdTimerAction <> #SCS_PTA_NO_ACTION
            processProdTimerAction(\nProdTimerAction, #SCS_PTW_WHEN_CUE_ENDS, pCuePtr)
          EndIf
        EndIf
        If (nNewCueState = #SCS_CUE_COMPLETED) Or (nNewCueState = #SCS_CUE_STANDBY) Or (nNewCueState <= #SCS_CUE_READY)
          If \bResetInitialStateWhenCompleted
            samAddRequest(#SCS_SAM_RESET_INITIAL_STATE_OF_CUE, pCuePtr, 0, \nCurrentCuePtrForResetInitialState)
          EndIf
        EndIf
        CompilerIf 1=2
          ; blocked out 21Jan2022 11.9.0rc3 following test for Davis Grantins where Q1 was set back to manual on playing the next time after resetTOD
          If nNewCueState = #SCS_CUE_COMPLETED
            If \nActivationMethod = #SCS_ACMETH_TIME
              \nActivationMethodReqd = #SCS_ACMETH_MAN
              debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
            EndIf
          EndIf
        CompilerEndIf
      EndIf
;       If nNewCueState <> nCurrCueState
;         debugMsg(sProcName, "nCurrCueState=" + decodeCueState(nCurrCueState) + ", nNewCueState=" + decodeCueState(nNewCueState))
;       EndIf
      If (nNewCueState = #SCS_CUE_COMPLETED) Or (nNewCueState = #SCS_CUE_STANDBY) ; Test added 14Oct2020 11.8.3.2bq so that 'rewinding' a playing cue will NOT set \bCueEnded (which could cause the auto-start an associated auto-start cue)
        \bCueEnded = #True
        ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bCueEnded=" + strB(\bCueEnded))
      EndIf
    EndIf
    
    If (nNewCueState <= #SCS_CUE_READY) Or ((nNewCueState >= #SCS_CUE_PL_READY) And (nNewCueState <> #SCS_CUE_COMPLETED))
      \qTimeCueStarted = 0
      \bTimeCueStartedSet = #False
      \bTimeToStartCueSet = #False ; Added 19Aug2024 following bug reported by Jason Mai 17Aug2024, related to using non-linear run mode
    EndIf
    
    CompilerIf 1=1
      ; Blocked out 14Oct2020 11.8.3.2bq - not sure why this is here, and if you 'rewind' a playing cue this code will set \bCueEnded which can auto-start an associated auto-start cue
      ; Reinstated 31Oct2020 11.8.3.3ab but with hotkey test added following bug report from Martin Stansfield where a 'start after end of previous cue' didn't auto-start if the previous cue was a hotkey cue
      If nNewCueState <= #SCS_CUE_READY
        If nCurrCueState > #SCS_CUE_READY And nCurrCueState <= #SCS_CUE_FADING_OUT
;           debugMsg(sProcName, "nCurrCueState=" + decodeCueState(nCurrCueState) + ", nNewCueState=" + decodeCueState(nNewCueState))
          If aCue(pCuePtr)\bHotkey Or aCue(pCuePtr)\bExtAct Or aCue(pCuePtr)\bCallableCue ; Added this test 31Oct2020 11.8.3.3ab - see 31Oct2020 comment above
            \bCueEnded = #True
            debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bCueEnded=" + strB(\bCueEnded))
          EndIf
        EndIf
      EndIf
    CompilerEndIf
    
    If (nCurrCueState <> nNewCueState) Or (bForceLoadGridRow)
      samAddRequest(#SCS_SAM_LOAD_GRID_ROW, pCuePtr)
      \nCuePanelUpdateFlags | #SCS_CUEPNL_OTHER
    EndIf
    
    If \bCueCountDownPaused
      If (nNewCueState <= #SCS_CUE_READY) Or (nNewCueState > #SCS_CUE_FADING_OUT)
        \bCueCountDownPaused = #False
      EndIf
    EndIf
    
    If bSubStartedInEditor = #False
      If \bCueEnded
        If (\nActivationMethod = #SCS_ACMETH_HK_TOGGLE) And (\bDoNotResetToggleStateAtCueEnd = #False) And (grMMedia\bInPlayCue = #False)
          nCurrHotkeyPtr = getCurrHotkeyPtrForCuePtr(pCuePtr)
          If nCurrHotkeyPtr >= 0
            If gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState <> 0
              gaCurrHotkeys(nCurrHotkeyPtr)\nToggleState = 0
              saveCurrHotkeyInfo(nCurrHotkeyPtr)
              samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
    If RAI_IsClientActive()
      If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
        If (nNewCueState <> nCurrCueState) Or (bSubStartedInEditor)
          sendRAICueStateIfReqd(pCuePtr, bHideNetworkTracing)
        EndIf
      EndIf
    EndIf
    
    If nNewCueState <> #SCS_CUE_STATE_NOT_SET
      If nNewCueState = #SCS_CUE_ERROR
        If sNewCueErrorMsg
          \sErrorMsg = sNewCueErrorMsg
        EndIf
      EndIf
      If \nCueState <> nNewCueState
        debugMsg(sProcName, "changing aCue(" + getCueLabel(pCuePtr) + "\nCueState from " + decodeCueState(\nCueState) + " to " + decodeCueState(nNewCueState))
        \nCueState = nNewCueState
        samAddRequest(#SCS_SAM_LOAD_GRID_ROW, pCuePtr)
        \nCuePanelUpdateFlags | #SCS_CUEPNL_OTHER
        If RAI_IsClientActive()
          If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
            sendRAICueStateIfReqd(pCuePtr, bHideNetworkTracing)
          EndIf
        EndIf
      EndIf
    EndIf
    
    If \bCueCountDownPaused
      If (\nCueState <= #SCS_CUE_READY) Or (\nCueState > #SCS_CUE_FADING_OUT)
        \bCueCountDownPaused = #False
      EndIf
    EndIf
    
    ; Added 19Oct2022 11.9.6, to replace "aCue(pCuePtr)\bPlayCueEventPosted = #False" in handleWindowEvents() after processing #SCS_Event_PlayCue
    If \bPlayCueEventPosted
      If (\nCueState <= #SCS_CUE_READY) Or (\nCueState > #SCS_CUE_FADING_OUT)
        \bPlayCueEventPosted = #False ; Deleted 19Oct2022 11.9.6
      EndIf
    EndIf
    ; End added 19Oct2022 11.9.6
    
  EndWith
  
EndProcedure

Procedure setCueLength(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  
  If pCuePtr >= 0
    aCue(pCuePtr)\nCueLength = getCueLength(pCuePtr)
    ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueLength=" + aCue(pCuePtr)\nCueLength)
  EndIf
  
EndProcedure

Procedure getAutoActStartCuePtr(pCuePtr)
  ; Added 30Dec2024 11.10.6bz
  PROCNAMECQ(pCuePtr)
  Protected nAutoActStartCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  nAutoActStartCuePtr = pCuePtr
  While #True
    If aCue(nAutoActStartCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO Or aCue(nAutoActStartCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
      ; debugMsg(sProcName, "aCue(" + getCueLabel(nAutoActStartCuePtr) + ")\nAutoActCueSelType=" + decodeAutoActCueSelType(aCue(nAutoActStartCuePtr)\nAutoActCueSelType))
      If aCue(nAutoActStartCuePtr)\nAutoActCueSelType = #SCS_ACCUESEL_PREV
        setCuePtrForAutoStartPrevCueType(nAutoActStartCuePtr)
      EndIf
      ; debugMsg(sProcName, "aCue(" + getCueLabel(nAutoActStartCuePtr) + ")\nAutoActCuePtr=" + getCueLabel(aCue(nAutoActStartCuePtr)\nAutoActCuePtr))
      nAutoActStartCuePtr = aCue(nAutoActStartCuePtr)\nAutoActCuePtr
      Continue
    EndIf
    Break
  Wend
  
  debugMsg(sProcName, #SCS_END + ", returning " + getCueLabel(nAutoActStartCuePtr))
  ProcedureReturn nAutoActStartCuePtr
  
EndProcedure

Procedure setInitCueStates(pCuePtr, pCurrentCuePtr, bLeavePlayingState=#False, bPrimaryFile=#True, bIgnoreStartedInEditor=#False)
  PROCNAMECQ(pCuePtr)
  Protected h, j, k, m, n, nReqdState
  Protected nReqdSubState, nReqdCueState
  Protected nAutoActStartCuePtr

  ; debugMsg(sProcName, #SCS_START + " pCuePtr=" + getCueLabel(pCuePtr) + ", pCurrentCuePtr=" + getCueLabel(pCurrentCuePtr) +
  ;                     ", bLeavePlayingState=" + strB(bLeavePlayingState) + ", bPrimaryFile=" + strB(bPrimaryFile) + ", bIgnoreStartedInEditor=" + strB(bIgnoreStartedInEditor))
  
  If (gnStandbyCuePtr = pCuePtr) And (pCuePtr >= pCurrentCuePtr)
    gnStandbyCuePtr = -1
    setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #False)
    setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, Lang("Menu", "mnuStandbyGo"))
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, #False)
    scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, Lang("Menu", "mnuStandbyGo"))
  EndIf
  
  If aCue(pCuePtr)\nActivationMethodReqd = #SCS_ACMETH_TIME
    If aCue(pCuePtr)\bTBCDone
      debugMsg(sProcName, "exiting because aCue(" + getCueLabel(pCuePtr) + ")\bTBCDone=#True")
      ProcedureReturn
    EndIf
  EndIf
  
  ; Added 30Dec2024 11.10.6bz
  If aCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO Or aCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
    If aCue(pCuePtr)\nAutoActPosn <> #SCS_ACPOSN_LOAD
      nAutoActStartCuePtr = getAutoActStartCuePtr(pCuePtr)
      If nAutoActStartCuePtr <> pCuePtr
        If nAutoActStartCuePtr >= 0
          If aCue(nAutoActStartCuePtr)\nActivationMethod = #SCS_ACMETH_TIME
            If aCue(nAutoActStartCuePtr)\bTBCDone
              debugMsg(sProcName, "exiting because aCue(" + getCueLabel(nAutoActStartCuePtr) + ")\bTBCDone=#True")
              ProcedureReturn
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  ; End added 30Dec2024 11.10.6bz
  
  If bLeavePlayingState
    If (aCue(pCuePtr)\nCueState > #SCS_CUE_READY) And (aCue(pCuePtr)\nCueState <= #SCS_CUE_FADING_OUT)
      ; if cue state is playing then do not touch sub-cues
      debugMsg(sProcName, "exiting because aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(aCue(pCuePtr)\nCueState))
      ProcedureReturn
    EndIf
  EndIf
  
  With aCue(pCuePtr)
    ; added 28Oct2015 11.4.1.2c to avoid issue reported by Jens Jorgensen re sub-cues unlinked that should be linked
    If \bCallClearLinksForCue
      \bCallClearLinksForCue = #False
      debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bCallClearLinksForCue=" + strB(aCue(pCuePtr)\bCallClearLinksForCue))
    EndIf
    ; end of added 28Oct2015
    \bDisplayingWarningBeforeEnd = #False
    \qCueTimePauseStarted = 0
    \nCueTotalTimeOnPause = 0
  EndWith
  
  nReqdCueState = #SCS_LAST_CUE_STATE
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    With aSub(j)
      \bPLTerminating = #False
      \bPLFadingIn = #False
      \bPLFadingOut = #False
      If \nFirstPlayIndexThisRun >= 0
        \nCurrPlayIndex = \nFirstPlayIndexThisRun
      Else
        \nCurrPlayIndex = \nFirstPlayIndex
      EndIf
      ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex) + ", \nFirstPlayIndexThisRun=" + getAudLabel(\nFirstPlayIndexThisRun))
      setDerivedSubFields(j, bPrimaryFile)
      If (\bSubTypeHasAuds) And (\nFirstAudIndex >= 0)
        nReqdSubState = #SCS_LAST_CUE_STATE
        k = \nFirstAudIndex
        While k >= 0
          aAud(k)\bPlayNextAudRequested = #False
          If \bSubTypeI   ; \bSubTypeI
            aAud(k)\nFileFormat = #SCS_FILEFORMAT_LIVE_INPUT
            If aAud(k)\nFileState = #SCS_FILESTATE_OPEN
              If (pCuePtr = gnStandbyCuePtr) And (aCue(pCuePtr)\nCueState = #SCS_CUE_STANDBY)
                ; do nothing
              Else
                audSetState(k, #SCS_CUE_READY, 16)
              EndIf
            Else
              audSetState(k, #SCS_CUE_NOT_LOADED, 17)
            EndIf
            If aAud(k)\nAudState < nReqdSubState
              nReqdSubState = aAud(k)\nAudState
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState) + ", \nFileState=" + decodeFileState(aAud(k)\nFileState) + ", \sErrorMsg=" + aAud(k)\sErrorMsg)
            
          Else  ; \bSubTypeA, \bSubTypeF, \bSubTypeM
            If (bLeavePlayingState = #False) Or ((bLeavePlayingState) And ((aAud(k)\nAudState < #SCS_CUE_FADING_IN) Or (aAud(k)\nAudState > #SCS_CUE_FADING_OUT) Or (aAud(k)\nAudState = #SCS_CUE_HIBERNATING)))
              If aAud(k)\nFileState = #SCS_FILESTATE_OPEN
                If (pCuePtr = gnStandbyCuePtr) And (aCue(pCuePtr)\nCueState = #SCS_CUE_STANDBY)
                  ; do nothing
                Else
                  setPlaylistTrackReadyState(k)
                EndIf
              Else
                If aAud(k)\bAudPlaceHolder
                  audSetState(k, #SCS_CUE_READY, 13)
                ElseIf aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE
                  audSetState(k, #SCS_CUE_NOT_LOADED, 141)
                ElseIf FileExists(aAud(k)\sFileName, #False)
                  audSetState(k, #SCS_CUE_NOT_LOADED, 14)
                Else
                  audSetState(k, #SCS_CUE_ERROR, 15)
                  aAud(k)\sErrorMsg = LangPars("Errors", "FileNotFound", aAud(k)\sFileName)
                EndIf
              EndIf
              If aAud(k)\nAudState < nReqdSubState
                nReqdSubState = aAud(k)\nAudState
              EndIf
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState) + ", \nFileState=" + decodeFileState(aAud(k)\nFileState) + ", \sErrorMsg=" + aAud(k)\sErrorMsg)
          EndIf
          k = aAud(k)\nNextAudIndex
        Wend
        \nSubState = nReqdSubState
        
      ElseIf \bSubTypeA   ; \bSubTypeA (with no aAud's)
        If \bSubPlaceHolder
          \nSubState = #SCS_CUE_READY
        EndIf
        
      ElseIf \bSubTypeE   ; \bSubTypeE
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeG   ; \bSubTypeG
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeI   ; \bSubTypeI
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeJ   ; \bSubTypeJ
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeK   ; \bSubTypeK
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeL   ; \bSubTypeL
        If \nLCSubPtr < 0
          \nSubState = #SCS_CUE_NOT_LOADED
        ElseIf (aSub(\nLCSubPtr)\nSubState = #SCS_CUE_NOT_LOADED) And (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND)
          \nSubState = #SCS_CUE_NOT_LOADED
        Else
          \nSubState = #SCS_CUE_READY
        EndIf
        setLCDevPresentInds(j)
        
      ElseIf \bSubTypeM   ; \bSubTypeM
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeN   ; \bSubTypeN
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeP   ; \bSubTypeP (with no aAud's)
        If \bSubPlaceHolder
          \nSubState = #SCS_CUE_READY
        EndIf
        
      ElseIf \bSubTypeQ   ; \bSubTypeQ
        \nSubState = #SCS_CUE_READY
      
      ElseIf \bSubTypeR   ; \bSubTypeR
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeS   ; \bSubTypeS
        nReqdState = #SCS_CUE_READY
        If (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND) Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND) And (aCue(pCuePtr)\bNonLinearCue))
          For h = 0 To #SCS_MAX_SFR
            If \nSFRCueType[h] = #SCS_SFR_CUE_SEL Or \nSFRCueType[h] = #SCS_SFR_CUE_PREV
              m = \nSFRCuePtr[h]
              If m >= 0
                If aCue(m)\nCueState = #SCS_CUE_NOT_LOADED
                  nReqdState = #SCS_CUE_NOT_LOADED
                  Break
                EndIf
              EndIf
            EndIf
          Next h
        EndIf
        \nSubState = nReqdState
        
      ElseIf \bSubTypeT   ; \bSubTypeT
        \nSubState = #SCS_CUE_READY
        
      ElseIf \bSubTypeU   ; \bSubTypeU
        \nSubState = #SCS_CUE_READY
        
      Else
        If (grProd\nRunMode = #SCS_RUN_MODE_LINEAR) Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND) And (aCue(pCuePtr)\bNonLinearCue))
          ; debugMsg(sProcName, "calling endOfSub(" + getSubLabel(j) + ", #SCS_CUE_COMPLETED)")
          endOfSub(j, #SCS_CUE_COMPLETED)
        Else
          ; debugMsg(sProcName, "calling endOfSub(" + getSubLabel(j) + ", #SCS_CUE_NOT_LOADED)")
          endOfSub(j, #SCS_CUE_NOT_LOADED)
        EndIf
        
      EndIf
      
      ; debugMsg(sProcName, "\sSubLabel=" + \sSubLabel + " \nSubNo=" + \nSubNo + ", \sSubType=" + \sSubType + ", \nSubState=" + decodeCueState(\nSubState))
      If \nSubState < nReqdCueState
        nReqdCueState = \nSubState
      EndIf
      
      j = \nNextSubIndex
    EndWith
  Wend
  
  If aCue(pCuePtr)\nCueState <> nReqdCueState
    ; debugMsg(sProcName, "setting aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(nReqdCueState) + ", was " + decodeCueState(aCue(pCuePtr)\nCueState))
    aCue(pCuePtr)\nCueState = nReqdCueState
  EndIf
  
  ; debugMsg(sProcName, "calling setTimeBasedCues(" + getCueLabel(pCuePtr) + ")")
  setTimeBasedCues(pCuePtr)
  
  ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(pCuePtr) + ", #False, " + strB(bIgnoreStartedInEditor) + ")")
  setCueState(pCuePtr, #False, bIgnoreStartedInEditor)
  
  With aCue(pCuePtr)
    If \nCueState <= #SCS_CUE_READY
      \bCueCountDownFinished = #False
    EndIf
  EndWith
  
  ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nFirstSubIndex=" + getSubLabel(aCue(pCuePtr)\nFirstSubIndex))
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    With aSub(j)
      If (\bSubTypeHasAuds) And (\bSubTypeM = #False) And (aSub(j)\bSubEnabled)
        ; debugMsg(sProcName, "calling calcPLTotalTime(" + getSubLabel(j) + ")")
        calcPLTotalTime(j)
      EndIf
      j = \nNextSubIndex
    EndWith
  Wend
  
  If aCue(pCuePtr)\bNonLinearCue
    debugMsg(sProcName, "calling resetRelatedCueActivationMethodReqd(" + getCueLabel(pCuePtr) + ")")
    resetRelatedCueActivationMethodReqd(pCuePtr)
  EndIf
  
  ; debugMsg(sProcName, "calling colorLine(" + getCueLabel(pCuePtr) + ")")
  colorLine(pCuePtr)
  
;   debugMsg(sProcName, "calling listCueStates()")
;   listCueStates()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resetSubStatesForSFRsIfReqd()
  PROCNAMEC()
  ; procedure added 29Oct2015 11.4.1.2e
  Protected i, j, h, m
  Protected nReqdState
  Protected bChangeAppliedInCue
  
  Select grProd\nRunMode
    Case #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND, #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND
      For i = 1 To gnLastCue
        If aCue(i)\bSubTypeS
          bChangeAppliedInCue = #False
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            With aSub(j)
              If \bSubTypeS And aSub(j)\bSubEnabled
                If \nSubState < #SCS_CUE_READY
                  nReqdState = #SCS_CUE_READY
                  If (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND) Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND) And (aCue(i)\bNonLinearCue))
                    For h = 0 To #SCS_MAX_SFR
                      If \nSFRCueType[h] = #SCS_SFR_CUE_SEL Or \nSFRCueType[h] = #SCS_SFR_CUE_PREV
                        m = \nSFRCuePtr[h]
                        If m >= 0
                          If aCue(m)\nCueState = #SCS_CUE_NOT_LOADED
                            nReqdState = #SCS_CUE_NOT_LOADED
                            Break
                          EndIf
                        EndIf
                      EndIf
                    Next h
                  EndIf
                  If nReqdState <> \nSubState
                    \nSubState = nReqdState
                    ; debugMsg0(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(\nSubState))
                    bChangeAppliedInCue = #True
                  EndIf
                EndIf ; EndIf \nSubState < #SCS_CUE_READY
              EndIf ; EndIf \bSubTypeS
              j = \nNextSubIndex
            EndWith
          Wend
          If bChangeAppliedInCue
            setCueState(i)
          EndIf
        EndIf ; EndIf aCue(i)\bSubTypeS
      Next i
  EndSelect
  
EndProcedure

Procedure setDefaults_PropogateProdDevs()
  PROCNAMEC()
  Protected d1, d2
  Protected bAutoIncludeFound
  
  debugMsg(sProcName, #SCS_START)
  
  d2 = -1
  For d1 = 0 To grProd\nMaxAudioLogicalDev
    With grProd\aAudioLogicalDevs(d1)
      If \bAutoInclude
        If d2 < grLicInfo\nMaxAudDevPerAud
          d2 + 1
          If d2 = 0
            grAudDef\sLogicalDev[d2] = \sLogicalDev
            grAudDef\nBassDevice[d2] = \nDfltBassDevice
            grAudDef\bASIO[d2] = \bDfltASIO
            grAudDef\nBassASIODevice[d2] = \nDfltBassASIODevice
            grAudDef\sDBTrim[d2] = \sDfltDBTrim
            grAudDef\fTrimFactor[d2] = \fDfltTrimFactor
            grAudDef\sDBLevel[d2] = \sDfltDBLevel
            grAudDef\fBVLevel[d2] = \fDfltBVLevel
            grAudDef\fPan[d2] = \fDfltPan
          EndIf
          grAudDefForAdd\sLogicalDev[d2] = \sLogicalDev
          grAudDefForAdd\nBassDevice[d2] = \nDfltBassDevice
          grAudDefForAdd\bASIO[d2] = \bDfltASIO
          grAudDefForAdd\nBassASIODevice[d2] = \nDfltBassASIODevice
          grAudDefForAdd\sDBTrim[d2] = \sDfltDBTrim
          grAudDefForAdd\fTrimFactor[d2] = \fDfltTrimFactor
          grAudDefForAdd\sDBLevel[d2] = \sDfltDBLevel
          grAudDefForAdd\fBVLevel[d2] = \fDfltBVLevel
          grAudDefForAdd\fSavedBVLevel[d2] = \fDfltBVLevel
          grAudDefForAdd\fPan[d2] = \fDfltPan
          grAudDefForAdd\fSavedPan[d2] = \fDfltPan
          If grAudDefForAdd\sLogicalDev[d2]
            debugMsg(sProcName, "grAudDefForAdd\sLogicalDev[" + d2 + "]=" + grAudDefForAdd\sLogicalDev[d2])
          EndIf
        EndIf
      EndIf
    EndWith
  Next d1

  While d2 < grLicInfo\nMaxAudDevPerAud
    d2 + 1
    With grAudioLogicalDevsDef
      grAudDefForAdd\sLogicalDev[d2] = \sLogicalDev
      grAudDefForAdd\nBassDevice[d2] = \nDfltBassDevice
      grAudDefForAdd\bASIO[d2] = \bDfltASIO
      grAudDefForAdd\nBassASIODevice[d2] = \nDfltBassASIODevice
      grAudDefForAdd\sDBTrim[d2] = \sDfltDBTrim
      grAudDefForAdd\fTrimFactor[d2] = \fDfltTrimFactor
      grAudDefForAdd\sDBLevel[d2] = \sDfltDBLevel
      grAudDefForAdd\fBVLevel[d2] = \fDfltBVLevel
      grAudDefForAdd\fSavedBVLevel[d2] = \fDfltBVLevel
      grAudDefForAdd\fPan[d2] = \fDfltPan
      grAudDefForAdd\fSavedPan[d2] = \fDfltPan
      If grAudDefForAdd\sLogicalDev[d2]
        debugMsg(sProcName, "grAudDefForAdd\sLogicalDev[" + d2 + "]=" + grAudDefForAdd\sLogicalDev[d2] + ", \sDBLevel[d2]=" + grAudDefForAdd\sDBLevel[d2])
      EndIf
    EndWith
  Wend
  
  ; nb live inputs do not have auto-include
  For d2 = 0 To grLicInfo\nMaxLiveDevPerAud
    With grLiveInputLogicalDevsDef
      grAudDefForAdd\sInputLogicalDev[d2] = \sLogicalDev
      grAudDefForAdd\sInputDBLevel[d2] = \sDfltInputDBLevel
      grAudDefForAdd\fInputLevel[d2] = \fDfltInputLevel
    EndWith
  Next d2
  
  d2 = -1
  For d1 = 0 To grProd\nMaxAudioLogicalDev
    With grProd\aAudioLogicalDevs(d1)
      If \bAutoInclude
        If d2 < grLicInfo\nMaxAudDevPerAud
          d2 + 1
          If d2 = 0
            grSubDef\sPLLogicalDev[d2] = \sLogicalDev
            grSubDef\nPLBassDevice[d2] = \nDfltBassDevice
            grSubDef\bPLASIO[d2] = \bDfltASIO
            grSubDef\nPLBassASIODevice[d2] = \nDfltBassASIODevice
            grSubDef\sPLDBTrim[d2] = \sDfltDBTrim
            grSubDef\fSubTrimFactor[d2] = \fDfltTrimFactor
            grSubDef\sPLMastDBLevel[d2] = \sDfltDBLevel
            grSubDef\fSubMastBVLevel[d2] = \fDfltBVLevel
            grSubDef\fPLPan[d2] = \fDfltPan
          EndIf
          grSubDefForAdd\sPLLogicalDev[d2] = \sLogicalDev
          grSubDefForAdd\nPLBassDevice[d2] = \nDfltBassDevice
          grSubDefForAdd\bPLASIO[d2] = \bDfltASIO
          grSubDefForAdd\nPLBassASIODevice[d2] = \nDfltBassASIODevice
          grSubDefForAdd\sPLDBTrim[d2] = \sDfltDBTrim
          grSubDefForAdd\fSubTrimFactor[d2] = \fDfltTrimFactor
          grSubDefForAdd\sPLMastDBLevel[d2] = \sDfltDBLevel
          grSubDefForAdd\fSubMastBVLevel[d2] = \fDfltBVLevel
          grSubDefForAdd\fPLPan[d2] = \fDfltPan
          If grSubDefForAdd\sPLLogicalDev[d2]
            debugMsg(sProcName, "grSubDefForAdd\sPLLogicalDev[" + d2 + "]=" + grSubDefForAdd\sPLLogicalDev[d2])
          EndIf
        EndIf
      EndIf
    EndWith
  Next d1

  While d2 < grLicInfo\nMaxAudDevPerAud
    d2 + 1
    With grAudioLogicalDevsDef
      grSubDefForAdd\sPLLogicalDev[d2] = \sLogicalDev
      grSubDefForAdd\nPLBassDevice[d2] = \nDfltBassDevice
      grSubDefForAdd\bPLASIO[d2] = \bDfltASIO
      grSubDefForAdd\nPLBassASIODevice[d2] = \nDfltBassASIODevice
      grSubDefForAdd\sPLDBTrim[d2] = \sDfltDBTrim
      grSubDefForAdd\fSubTrimFactor[d2] = \fDfltTrimFactor
      grSubDefForAdd\sPLMastDBLevel[d2] = \sDfltDBLevel
      grSubDefForAdd\fSubMastBVLevel[d2] = \fDfltBVLevel
      grSubDefForAdd\fPLPan[d2] = \fDfltPan
      If grSubDefForAdd\sPLLogicalDev[d2]
        debugMsg(sProcName, "grSubDefForAdd\sPLLogicalDev[" + d2 + "]=" + grSubDefForAdd\sPLLogicalDev[d2])
      EndIf
    EndWith
  Wend
  
  d2 = 0  ; only one audio output device for videos
  bAutoIncludeFound = #False
  For d1 = 0 To grProd\nMaxVidAudLogicalDev
    With grProd\aVidAudLogicalDevs(d1)
      If \bAutoInclude
        If bAutoIncludeFound = #False
          bAutoIncludeFound = #True
          If d2 = 0
            grSubDef\sVidAudLogicalDev = \sVidAudLogicalDev
            grSubDef\sPLDBTrim[d2] = \sDfltDBTrim
            grSubDef\fSubTrimFactor[d2] = \fDfltTrimFactor
            grSubDef\sPLMastDBLevel[d2] = \sDfltDBLevel
            grSubDef\fSubMastBVLevel[d2] = \fDfltBVLevel
            grSubDef\fPLPan[d2] = \fDfltPan
          EndIf
          grSubDefForAdd\sVidAudLogicalDev = \sVidAudLogicalDev
          grSubDefForAdd\sPLDBTrim[d2] = \sDfltDBTrim
          grSubDefForAdd\fSubTrimFactor[d2] = \fDfltTrimFactor
          grSubDefForAdd\sPLMastDBLevel[d2] = \sDfltDBLevel
          grSubDefForAdd\fSubMastBVLevel[d2] = \fDfltBVLevel
          grSubDefForAdd\fPLPan[d2] = \fDfltPan
        EndIf
      EndIf
    EndWith
  Next d1
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure thisSubrPlaying(nSubrCuePtr)
  PROCNAMEC()
  Protected bThisSubrPlaying
  
  If nSubrCuePtr >= 0
    If (aCue(nSubrCuePtr)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(nSubrCuePtr)\nCueState <= #SCS_CUE_FADING_OUT)
      bThisSubrPlaying = #True
    EndIf
  EndIf
  
  ProcedureReturn bThisSubrPlaying
EndProcedure

Procedure setCueToGo(bSetNextManualCue=#True, nReqdCuePtr=-1, bCalledFromOpenNextCues=#False, bApplyDefaultGridClickAction=#False)
  PROCNAMEC()
  Protected i, j
  Protected i2, j2
  Protected bLineForGoFound
  Protected bPlayingCueFound, bPlayingExclusiveCueFound
  Protected bEnableInSoloMode
  Protected bLoadThisCue
  Protected nCueToGoHold
  
  ; debugMsg(sProcName, #SCS_START + ", bSetNextManualCue=" + strB(bSetNextManualCue) + ", nReqdCuePtr=" + getCueLabel(nReqdCuePtr) + ", bCalledFromOpenNextCues=" + strB(bCalledFromOpenNextCues) +
  ;                     ", bApplyDefaultGridClickAction=" + strB(bApplyDefaultGridClickAction))
  
  gbInSetCueToGo = #True  ; prevents recursion from ONC_openNextCues()
  
  ; debugMsg(sProcName, "gnCueToGo at start = " + getCueLabel(gnCueToGo))
  bEnableInSoloMode = #True
  nCueToGoHold = gnCueToGo
  
  If (grProd\nGridClickAction = #SCS_GRDCLICK_SET_GO_BUTTON_ONLY) And (gnCueToGoOverride >= 0) And (bApplyDefaultGridClickAction = #False) ; added bApplyDefaultGridClickAction 17Mar2020 11.8.2.3aa
    ; debugMsg(sProcName, "gnCueToGoOverride=" + getCueLabel(gnCueToGoOverride))
    i = gnCueToGoOverride
    If i <= gnLastCue
      With aCue(i)
        bLineForGoFound = #True
        If gnCueToGo <> i
          gnCueToGo = i
          If gnCueToGo <> nCueToGoHold
            debugMsg(sProcName, "gnCueToGo=" + getCueLabel(gnCueToGo) + ", (was " + getCueLabel(nCueToGoHold) + ")")
          EndIf
        EndIf
        gbWaitForSetCueToGo = #False
        gnRowToGo = \nGrdCuesRowNo
      EndWith
    EndIf
    
  ElseIf (grProd\nRunMode <> #SCS_RUN_MODE_LINEAR) And (gnNonLinearCue > 0)
    ; debugMsg(sProcName, "grProd\nRunMode=" + decodeRunMode(grProd\nRunMode) + ", gnNonLinearCue=" + getCueLabel(gnNonLinearCue))
    i = gnNonLinearCue
    If i <= gnLastCue
      With aCue(i)
        If \nCueState < #SCS_CUE_FADING_IN Or \nCueState > #SCS_CUE_FADING_OUT  ; added test on \nCueState 30Oct2015 11.4.1.2f to enable correct coloring of playing cue in cue list (Jens Jorgensen)
          bLineForGoFound = #True
          If gnCueToGo <> i
            gnCueToGo = i
            If gnCueToGo <> nCueToGoHold
              debugMsg(sProcName, "gnCueToGo=" + getCueLabel(gnCueToGo) + ", (was " + getCueLabel(nCueToGoHold) + ")")
            EndIf
          EndIf
          gbWaitForSetCueToGo = #False
          gnRowToGo = \nGrdCuesRowNo
        EndIf
      EndWith
    EndIf
    
  Else
    
    bPlayingCueFound = #False
    bPlayingExclusiveCueFound = #False
    For i = 1 To gnLastCue
      With aCue(i)
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState))
        If (\bCueCurrentlyEnabled) And (\bCueSubsAllDisabled = #False) And ((\nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nCueState <= #SCS_CUE_FADING_OUT))
          bPlayingCueFound = #True
          ; debugMsg(sProcName, "bPlayingCueFound=" + strB(bPlayingCueFound) + ", aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState))
          If (\bExclusiveCue)
            bPlayingExclusiveCueFound = #True
            ; debugMsg(sProcName, "bPlayingExclusiveCueFound=" + strB(bPlayingExclusiveCueFound) + ", i=" + getCueLabel(i))
            Break
          EndIf
        EndIf
      EndWith
    Next i
    
    For i = 1 To gnLastCue
      With aCue(i)
;         debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState) + ", \bHoldAutoStart=" + strB(\bHoldAutoStart) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) +
;                             ", bLineForGoFound=" + strB(bLineForGoFound))
        If (\bCueCurrentlyEnabled) And (\bCueSubsAllDisabled = #False) And ((\nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nCueState <= #SCS_CUE_FADING_OUT))
          ; no action
        ElseIf (\bCueCurrentlyEnabled) And (\bCueSubsAllDisabled = #False) And (\nCueState <> #SCS_CUE_IGNORED) And (\bHoldAutoStart = #False)
          If (\nActivationMethodReqd = #SCS_ACMETH_MAN) Or (\nActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF)
            If \nCueState <= #SCS_CUE_READY
              ; debugMsg(sProcName, ".. \bHotkey=" + strB(\bHotkey) + ", \bExtAct=" + strB(\bExtAct) + ", \bCallableCue=" + strB(\bCallableCue))
              If (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
                If bLineForGoFound = #False
                  bLineForGoFound = #True
                  gnCueToGo = i
                  If gnCueToGo <> nCueToGoHold
                    debugMsg(sProcName, "gnCueToGo=" + getCueLabel(gnCueToGo) + ", (was " + getCueLabel(nCueToGoHold) + ")")
                    debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState) + ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod) +
                                        ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
                  EndIf
                  gbWaitForSetCueToGo = #False
                  gnRowToGo = \nGrdCuesRowNo
                EndIf
              EndIf
              If bLineForGoFound
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      EndWith
    Next i
    
  EndIf
  
  If bLineForGoFound
    ; debugMsg(sProcName, "gnCueToGo=" + getCueLabel(gnCueToGo) + ", \nCueState=" + decodeCueState(aCue(gnCueToGo)\nCueState) + ", bEnableInSoloMode=" + strB(bEnableInSoloMode))
    If bPlayingExclusiveCueFound
      j = aCue(gnCueToGo)\nFirstSubIndex
      While (j >= 0) And (bEnableInSoloMode)
        If aSub(j)\bSubEnabled
          If aSub(j)\bSubTypeForP Or aSub(j)\bSubTypeA
            bEnableInSoloMode = #False
          ElseIf aSub(j)\bSubTypeQ
            i2 = aSub(j)\nCallCuePtr ; Added 10Oct2022 11.9.6
            If i2 >= 0
              j2 = aCue(i2)\nFirstSubIndex
              While (j2 >= 0) And (bEnableInSoloMode)
                If aSub(j2)\bSubTypeForP Or aSub(j2)\bSubTypeA
                  bEnableInSoloMode = #False
                EndIf
                j2 = aSub(j2)\nNextSubIndex
              Wend
            EndIf
          EndIf
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
    
    ; debugMsg(sProcName, "aCue(" + getCueLabel(gnCueToGo) + ")\nCueState=" + decodeCueState(aCue(gnCueToGo)\nCueState) + ", bPlayingCueFound=" + strB(bPlayingCueFound))
    If aCue(gnCueToGo)\nCueState = #SCS_CUE_NOT_LOADED
      If (grProd\bPreLoadNextManualOnly) And (bPlayingCueFound)
        ; defer loading the cue
      Else
        j = aCue(gnCueToGo)\nFirstSubIndex
        While (j >= 0) And (bLoadThisCue = #False)
          If aSub(j)\bSubEnabled
            ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
            If aSub(j)\nSubState = #SCS_CUE_NOT_LOADED
              bLoadThisCue = #True
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If bLoadThisCue
          ; debugMsg(sProcName, "calling loadOneCue(" + getCueLabel(gnCueToGo) + ")")
          loadOneCue(gnCueToGo)
        EndIf
      EndIf
    EndIf
    
    ; debugMsg(sProcName, "gnCueToGoState=" + decodeCueToGoState(gnCueToGoState))
    If aCue(gnCueToGo)\nCueState = #SCS_CUE_NOT_LOADED
      gnCueToGoState = #SCS_Q2GO_DISABLED
    Else
      If (bPlayingExclusiveCueFound) And (bEnableInSoloMode = #False)
        If (grGeneralOptions\bCtrlOverridesExclCue) And (GetAsyncKeyState_(#VK_CONTROL) & 32768)
          gnCueToGoState = #SCS_Q2GO_ENABLED
        Else
          gnCueToGoState = #SCS_Q2GO_DISABLED
        EndIf
      Else
        gnCueToGoState = #SCS_Q2GO_ENABLED
      EndIf
      If gnCueToGoState = #SCS_Q2GO_ENABLED
        If gnCueToGo <> nCueToGoHold
          ; debugMsg(sProcName, "calling setInitCueStates(" + getCueLabel(gnCueToGo) + ", " + getCueLabel(gnCueToGo) + ", #True)")
          setInitCueStates(gnCueToGo, gnCueToGo, #True)
          If (bCalledFromOpenNextCues = #False) Or (aCue(gnCueToGo)\nCueState < #SCS_CUE_READY Or aCue(gnCueToGo)\nCueState > #SCS_CUE_FADING_OUT)
            samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, gnCueToGo, 0, nReqdCuePtr, "", ElapsedMilliseconds()+500, bApplyDefaultGridClickAction)
          EndIf
        EndIf
      EndIf
    EndIf
  Else
    gnCueToGoState = #SCS_Q2GO_END
    gnCueToGo = gnCueEnd
    If gnCueToGo <> nCueToGoHold
      debugMsg(sProcName, "gnCueToGo=" + getCueLabel(gnCueToGo) + ", (was " + getCueLabel(nCueToGoHold) + ")")
    EndIf
    gbWaitForSetCueToGo = #False
    gnRowToGo = gnRowEnd
  EndIf
  ; debugMsg(sProcName, "gnCueToGoState=" + decodeCueToGoState(gnCueToGoState))
  
  If gbCallGoClicked
    gbCallGoClicked = #False
    If gnCueToGoState = #SCS_Q2GO_ENABLED
      debugMsg(sProcName, "calling goClicked")
      goClicked()
    EndIf
  EndIf
  
  If gnCueToGo >= 0
    With aCue(gnCueToGo)
      If \bNonLinearCue
        If (\nActivationMethod <> #SCS_ACMETH_AUTO) And (\nActivationMethod <> #SCS_ACMETH_AUTO_PLUS_CONF)
          resetRelatedCueActivationMethodReqd(gnCueToGo)
        EndIf
      EndIf
    EndWith
  EndIf
  
  If bSetNextManualCue
    ; the following test (If gnCueToGo <> nCueToGoHold) added 19Jul2018 11.7.1.1ac to try to minimise screen updates after a hidden auto-start cue has been started
    ; modified 18Aug2018 11.7.1.3ad to include test on GO button enabled state following reports that GO button remained disabled after completing an exclusive cue
    If (gnCueToGo <> nCueToGoHold) Or (getToolBarBtnEnabled(#SCS_TBMB_GO) = #False)
      ; 'cue to go' has changed
      gbCallSetGoButton = #True
      gbCallSetNavigateButtons = #True
      ; debugMsg(sProcName, "gbCallSetGoButton=" + strB(gbCallSetGoButton) + ", gbCallSetNavigateButtons=" + strB(gbCallSetNavigateButtons))
    EndIf
  Else
    gnCueToGo = nCueToGoHold
    debugMsg(sProcName, "(reset) gnCueToGo=" + getCueLabel(gnCueToGo))
    If gnCueToGo = gnCueEnd
      gnCueToGoState = #SCS_Q2GO_END
      gnRowToGo = gnRowEnd
    Else
      If aCue(gnCueToGo)\nCueState = #SCS_CUE_NOT_LOADED
        gnCueToGoState = #SCS_Q2GO_DISABLED
      Else
        If (bPlayingExclusiveCueFound) And (bEnableInSoloMode = #False)
          gnCueToGoState = #SCS_Q2GO_DISABLED
        Else
          gnCueToGoState = #SCS_Q2GO_ENABLED
        EndIf
      EndIf
      gnRowToGo = aCue(gnCueToGo)\nGrdCuesRowNo
    EndIf
    gbWaitForSetCueToGo = #False
    gbCallSetNavigateButtons = #True
  EndIf
  
  ; Added 01Jan2020 11.8.2.1au following bug report and email dated 01Jan2019 from Peter Holmes:
  ; It appears to only be a problem if you go back over a running playlist Q. I had mentioned the Interval playlist as that is where we hit the problem, but it also happens at the start where Q5+// is a playlist.
  ; Sequence is:
  ;  Q1
  ;  Q5+//
  ;  Q10+ is correctly shown as Next Manual
  ;
  ; Click back on Q1 and run it.
  ; (Q5+// is still running)
  ; Q10+ is shown as Next Manual
  ; Execute Q10+
  ; Q5+ is now shown as Next Manual when it should be Q15.

  ; Error fixed by the following code:
  For i = 1 To gnCueToGo-1
    With aCue(i)
      If \bResetInitialStateWhenCompleted
        debugMsg(sProcName, "setting aCue(" + getCueLabel(i) + ")\bResetInitialStateWhenCompleted=#False because gnCueToGo (" + getCueLabel(gnCueToGo) + ") is later in the cue list")
        \bResetInitialStateWhenCompleted = #False
      EndIf
    EndWith
  Next i
  ; End added 01Jan2020 11.8.2.1au

  gbInSetCueToGo = #False
  
  ; debugMsg(sProcName, #SCS_END + ", gnCueToGo=" + getCueLabel(gnCueToGo))
  
EndProcedure

Procedure setLastPlayingCue(pCuePtr)
  PROCNAMEC()
  Protected nSubPtr, sLastPlayingText.s
  Protected nImageNo
  Protected nBackColor, nTextColor
  
  ; debugMsg(sProcName, #SCS_START + ", pCuePtr=" + getCueLabel(pCuePtr))
  
  If pCuePtr >= 0
    If aCue(pCuePtr)\nGrdCuesRowNo >= 0
      With aCue(pCuePtr)
        nSubPtr = \nFirstSubIndex
        If nSubPtr >= 0
          If FindString("AFIKMPQ", aSub(nSubPtr)\sSubType) = 0
            ; ignore if the first sub-cue is not one of the above sub-types
            ; debugMsg(sProcName, "exiting because aSub(" + getSubLabel(nSubPtr) + ")\sSubType=" + aSub(nSubPtr)\sSubType)
            ProcedureReturn
          EndIf
          ; commented out 6Sep2019 11.8.2am following test of Dizzy Dames - expected to see the 'call cue' cues shown in 'last playing cue'
          ; If (aSub(nSubPtr)\bSubTypeQ) And (aSub(nSubPtr)\nCallCueAction = #SCS_QQ_CALLCUE)
          ;   ; ignore 'call cue' as the called cue will or may have populated 'last playing cue', but accept 'select hotkey bank'
          ;   ; debugMsg(sProcName, "exiting")
          ;   ProcedureReturn
          ; EndIf
          ; end commented out 6Sep2019 11.8.2am
          ResizeGadget(WMN\imgLastPlayingType, #PB_Ignore, ((GadgetHeight(WMN\cntLastPlayingInfo) / 2) - (12 + 1)), #PB_Ignore, #PB_Ignore)
          nImageNo = IMG_getSubTypeImageHandle(nSubPtr)
        Else
          ; ignore if a note cue or if for any other reason there are no sub-cues
          ; debugMsg(sProcName, "exiting")
          ProcedureReturn
        EndIf
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_RU]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_RU]\nTextColor
        SetGadgetColor(WMN\cntLastPlayingInfo, #PB_Gadget_BackColor, nBackColor)
        SetGadgetColors(WMN\lblLastPlayingCue, nTextColor, nBackColor)
        SetGadgetColors(WMN\lblLastPlayingInfo, nTextColor, nBackColor)
        sLastPlayingText = \sCue
        If Trim(\sMidiCue)
          If grOperModeOptions(gnOperMode)\bShowMidiCueInNextManual
            sLastPlayingText + " [MIDI " + Trim(\sMidiCue) + "]"
          EndIf
        EndIf
        sLastPlayingText + " - "
        If \sPageNo
          sLastPlayingText + \sPageNo + "  "
        EndIf
        sLastPlayingText + \sCueDescr
      EndWith
      With WMN
        If IsImage(nImageNo)
          SetGadgetState(WMN\imgLastPlayingType, ImageID(nImageNo))
          setVisible(WMN\imgLastPlayingType, #True)
        Else
          setVisible(WMN\imgLastPlayingType, #False)
        EndIf
        SetGadgetText(\lblLastPlayingInfo, sLastPlayingText)
        setVisible(\lblLastPlayingInfo, #True)
        ; debugMsg(sProcName, "calling setVisible(WMN\cntLastPlayingInfo, #True)")
        setVisible(\cntLastPlayingInfo, #True)
      EndWith
      With grWMN
        \nLastPlayingCuePtr = pCuePtr
        \nLastPlayingSubPtr = nSubPtr  ; nb may be -1, especially for Note cues
        If nSubPtr >= 0
          \nLastPlayingState = aSub(nSubPtr)\nSubState
        Else
          \nLastPlayingState = aCue(pCuePtr)\nCueState
        EndIf
        \qLastPlayingTimeDisplayed = ElapsedMilliseconds()
        \qLastPlayingTimeEnded = 0
;         debugMsg(sProcName, "pCuePtr=" + getCueLabel(pCuePtr) + ", nSubPtr=" + getSubLabel(nSubPtr) + ", \qLastPlayingTimeEnded=" + traceTime(\qLastPlayingTimeEnded) +
;                             ", \nLastPlayingTimeOut=" + \nLastPlayingTimeOut)
      EndWith
    EndIf
    
  Else
    ; nb pCuePtr < 0 (eg -1) hides the area
    ; debugMsg(sProcName, "calling setVisible(WMN\cntLastPlayingInfo, #False)")
    setVisible(WMN\cntLastPlayingInfo, #False)
    grWMN\nLastPlayingCuePtr = -1
    grWMN\nLastPlayingSubPtr = -1
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkLastPlayingCue()
  PROCNAMEC()
  Protected i, j, qTimeNow.q
  Protected nSubState, nMinSubState
  Protected nPrevState, bPrevPlaying
  Protected nCurrState, bCurrPlaying
  Protected bSkipTimeCheck
  Protected bTracing ; Added 15Nov2024 11.10.6bk trying to work out why Willi Hartel sometimes gets a blue screen
  
  With grWMN
    If \nLastPlayingCuePtr >= 0
      ; implies 'last active cue' info currently displayed
      nPrevState = \nLastPlayingState
      If (nPrevState >= #SCS_CUE_FADING_IN) And (nPrevState <= #SCS_CUE_FADING_OUT) And (nPrevState <> #SCS_CUE_HIBERNATING)
        ; previously playing
        bPrevPlaying = #True
      EndIf
      i = \nLastPlayingCuePtr
      nCurrState = aCue(i)\nCueState
      If (nCurrState >= #SCS_CUE_FADING_IN) And (nCurrState <= #SCS_CUE_FADING_OUT) And (nCurrState <> #SCS_CUE_HIBERNATING)
        ; cue is currently playing - now check if at least one relevant subcue is playing or is yet to play
        nMinSubState = #SCS_LAST_CUE_STATE
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            If FindString("AFIKMPQ", aSub(j)\sSubType) > 0
              nSubState = aSub(j)\nSubState
              If nSubState < nMinSubState
                nMinSubState = nSubState
              EndIf
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If nMinSubState <= #SCS_CUE_FADING_OUT
          ; if at least one relevant subcue is playing or is yet to play then identify this cue as currently playing
          bCurrPlaying = #True
        Else
          ; no relevant sub-cue is playing or is yet to play, so treat the cue as not currently playing and set nCurrState to 'completed'
          nCurrState = #SCS_CUE_COMPLETED
        EndIf
      EndIf
      
      ; added 5Nov2018 11.8.0ap following run of 'Christmas Chaos' where it would have been useful to continue to see the lighting cue that was the 'last playing cue'
      ; If (bCurrPlaying = #False) And (bPrevPlaying)
      If aCue(i)\bSubTypeK
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            ; if the 'last playing cue' is no longer 'playing' but contains a lighting sub-cue, then treat the cue as still playing as the effect of that lighting cue is still visible
            ;bCurrPlaying = #True
            ;nCurrState = nPrevState
            bSkipTimeCheck = #True
            Break
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      ; EndIf
      ; end added 5Nov2018 11.8.0ap
      
      If bSkipTimeCheck = #False ; nb this test related to above code added 5Nov2018 11.8.0ap
        qTimeNow = ElapsedMilliseconds()
        If (bPrevPlaying) And (bCurrPlaying = #False)
          \qLastPlayingTimeEnded = qTimeNow
          ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", qTimeNow=" + traceTime(qTimeNow) + ", \qLastPlayingTimeEnded=" + traceTime(\qLastPlayingTimeEnded) + ", \nLastPlayingTimeOut=" + \nLastPlayingTimeOut)
        ElseIf \qLastPlayingTimeEnded = 0
          \qLastPlayingTimeEnded = qTimeNow
          debugMsg(sProcName, "i=" + getCueLabel(i) + ", qTimeNow=" + traceTime(qTimeNow) + ", \qLastPlayingTimeEnded=" + traceTime(\qLastPlayingTimeEnded) + ", \nLastPlayingTimeOut=" + \nLastPlayingTimeOut)
        EndIf
        If bCurrPlaying = #False
          If (qTimeNow - \qLastPlayingTimeEnded) > \nLastPlayingTimeOut
            ; hide the 'last active cue' field if the last active cue ended more than the specified timeout period ago (default 10 seconds)
            debugMsg(sProcName, "grWMN\nLastPlayingCuePtr=" + getCueLabel(\nLastPlayingCuePtr) + ", \nLastPlayingSubPtr=" + getSubLabel(\nLastPlayingSubPtr) + ", \nLastPlayingState=" + decodeCueState(\nLastPlayingState) +
                                ", nCurrState=" + decodeCueState(nCurrState))
            debugMsg(sProcName, "i=" + getCueLabel(i) + ", qTimeNow=" + traceTime(qTimeNow) + ", \qLastPlayingTimeEnded=" + traceTime(\qLastPlayingTimeEnded) + ", \nLastPlayingTimeOut=" + \nLastPlayingTimeOut)
            setLastPlayingCue(-1)
            debugMsg(sProcName, "returned from setLastPlayingCue(-1)")
            bTracing = #True
          EndIf
        EndIf
        \nLastPlayingState = nCurrState
      EndIf ; EndIf bSkipTimeCheck = #False
    EndIf
  EndWith
  
  ProcedureReturn bTracing ; See comment against 'Protected bTracing'
EndProcedure

Procedure setGoButton()
  PROCNAMEC()
  Protected i, j, sGoString.s, nIndex, sParam.s
  Protected sGoInfoText.s, nGoInfoLength, nMaxGoInfoLength
  Protected bLineToHighlightFound
  Protected nGoInfoWidth
  Protected bLoadThisCue
  Protected nCueToGoHold
  Protected nMainToolBarInfo, bMainMenuDisplayed
  Protected nImageNo
  Protected nBackColor.l, nTextColor.l
  Protected bGoEnabledByDefault

  debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  gbCallSetGoButton = #False
  If gbGlobalPause = #False
    bGoEnabledByDefault = #True
  EndIf
  
  If gbInOptionsWindow
    nMainToolBarInfo = mrOperModeOptions(gnOperMode)\nMainToolBarInfo
  Else
    nMainToolBarInfo = grOperModeOptions(gnOperMode)\nMainToolBarInfo
  EndIf
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
    bMainMenuDisplayed = #True
  EndIf
  
  Select gnCueToGoState
    Case #SCS_Q2GO_NOT_SET
      ; clear go button etc
      i = -1
    Case #SCS_Q2GO_ENABLED, #SCS_Q2GO_DISABLED
      i = gnCueToGo
    Case #SCS_Q2GO_END
      i = gnCueEnd
  EndSelect
  debugMsg(sProcName, "gnCueToGoState=" + decodeCueToGoState(gnCueToGoState) + ", i=" + getCueLabel(i) + ", gnCueToGo=" + getCueLabel(gnCueToGo))
  
  If (i >= 0) And (i <= gnLastCue)
    With aCue(i)
      
      nBackColor = \nBackColor
      nTextColor = \nTextColor
      setColorsForNextManualCue(nBackColor, nTextColor, @nBackColor, @nTextColor)
      
      sGoString = \sCue + " - " + grText\sTextGo + "!"
      sParam = decodeMainShortcutFunction(#SCS_WMNF_Go)
      If (Len(sParam) = 0) And (grGeneralOptions\bDisableRightClickAsGo = #False)
        sParam = grText\sTextRightClick
      EndIf
      If sParam
        sGoString + Chr(10) + "(" + sParam + ")"
      EndIf
      setToolBarBtnCaption(#SCS_TBMB_GO, sGoString)
      If bMainMenuDisplayed
        scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuGo, grText\sTextGo + " " + \sCue)
      EndIf
      SetGadgetColor(WMN\cntGoInfo, #PB_Gadget_BackColor, nBackColor)
      
      j = \nFirstSubIndex
      If j >= 0
        ResizeGadget(WMN\imgType, #PB_Ignore, ((GadgetHeight(WMN\cntGoInfo) / 2) - (12 + 1)), #PB_Ignore, #PB_Ignore)
        nImageNo = IMG_getSubTypeImageHandle(j)
        If IsImage(nImageNo)
          SetGadgetState(WMN\imgType, ImageID(nImageNo))
        EndIf
        setVisible(WMN\imgType, #True)
      Else
        setVisible(WMN\imgType, #False)
      EndIf
      
      SetGadgetColors(WMN\lblNextManualCue, nTextColor, nBackColor)
      SetGadgetColors(WMN\lblGoInfo, nTextColor, nBackColor)
      sGoInfoText = \sCue
      If Trim(\sMidiCue)
        If grOperModeOptions(gnOperMode)\bShowMidiCueInNextManual
          sGoInfoText + " [MIDI " + Trim(\sMidiCue) + "]"
        EndIf
      EndIf
      ; page number repositioned here 7May2022 11.9.1
      sGoInfoText + " - "
      If \sPageNo
        sGoInfoText + \sPageNo + " "
      EndIf
      If \sWhenReqd
        Select Left(\sWhenReqd, 1)
          Case "(", "[", "{"
            sGoInfoText + " " + \sWhenReqd + " "
          Default
            ; sGoInfoText + " (" + \sWhenReqd + ") "
            sGoInfoText + " [" + \sWhenReqd + "] "
        EndSelect
;       Else
;         sGoInfoText + " - "
      EndIf
;       If \sPageNo
;         sGoInfoText + \sPageNo + "  "
;       EndIf
      sGoInfoText + \sCueDescr + " "
      bLineToHighlightFound = #True
      ; debugMsg(sProcName, "calling highlightLine(" + getCueLabel(i) + ")")
      highlightLine(i)
      setNavigateButtons()
      gqMainThreadRequest | #SCS_MTH_SET_GRID_WINDOW
      gnRefreshCuePtr = i
      gnRefreshSubPtr = \nFirstSubIndex
      gnRefreshAudPtr = -1
      If gnRefreshSubPtr >= 0
        If aSub(gnRefreshSubPtr)\bSubTypeHasAuds
          gnRefreshAudPtr = aSub(gnRefreshSubPtr)\nFirstPlayIndex
        EndIf
      EndIf
      gbCallRefreshDispPanel = #True
      debugMsg(sProcName, "gbCallRefreshDispPanel=" + strB(gbCallRefreshDispPanel) + ", gnRefreshCuePtr=" + getCueLabel(gnRefreshCuePtr) +
                          ", gnRefreshSubPtr=" + getSubLabel(gnRefreshSubPtr) + ", gnRefreshAudPtr=" + getAudLabel(gnRefreshAudPtr))
      \nCuePanelUpdateFlags | #SCS_CUEPNL_OTHER
      debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(\nCueState) + ", \nCuePanelUpdateFlags=" + \nCuePanelUpdateFlags)
      
    EndWith
    
  Else
    setVisible(WMN\imgType, #False)
    sGoInfoText = ""
    
  EndIf
  
  ; debugMsg(sProcName, "sGoInfoText=" + sGoInfoText)
  If gbDemoMode
    nGoInfoWidth = GadgetX(WMN\lblDemo) - GadgetX(WMN\cntGoInfo)
  ElseIf grOperModeOptions(gnOperMode)\bShowMasterFader
    nGoInfoWidth = GadgetX(WMN\cntMasterFaders) - GadgetX(WMN\cntGoInfo)
  Else
    nGoInfoWidth = GadgetWidth(WMN\cntGoAndMaster) - GadgetX(WMN\cntGoInfo)
  EndIf
  If GadgetWidth(WMN\cntGoInfo) <> nGoInfoWidth
    ResizeGadget(WMN\cntGoInfo, #PB_Ignore, #PB_Ignore, nGoInfoWidth, #PB_Ignore)
  EndIf
  If GGT(WMN\lblGoInfo) <> sGoInfoText
    debugMsg(sProcName, "Setting 'Next Manual Cue' to " + sGoInfoText)
    SetGadgetText(WMN\lblGoInfo, sGoInfoText)
  EndIf
  setVisible(WMN\lblGoInfo, #True)
  
  ; debugMsg(sProcName, "gnCueToGoState=" + decodeCueToGoState(gnCueToGoState))
  Select gnCueToGoState
    Case #SCS_Q2GO_DISABLED, #SCS_Q2GO_NOT_SET
      ; debugMsg(sProcName, "calling setToolBarBtnEnabled(#SCS_TBMB_GO, #False)")
      setToolBarBtnEnabled(#SCS_TBMB_GO, #False)
      If bMainMenuDisplayed
        scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuGo, #False)
      EndIf
      scsSetGadgetFont(WMN\lblGoInfo, #SCS_FONT_CUE_ITALIC9)
      If (getVisible(WMN\cntGoInfo) = #False) And (grOperModeOptions(gnOperMode)\bShowNextManualCue)
        setVisible(WMN\cntGoInfo, #True)
      EndIf
      
    Case #SCS_Q2GO_ENABLED
      ; debugMsg(sProcName, "calling setToolBarBtnEnabled(#SCS_TBMB_GO, " + strB(bGoEnabledByDefault) + ")")
      setToolBarBtnEnabled(#SCS_TBMB_GO, bGoEnabledByDefault)
      If bMainMenuDisplayed
        scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuGo, bGoEnabledByDefault)
      EndIf
      scsSetGadgetFont(WMN\lblGoInfo, #SCS_FONT_CUE_ITALIC10)
      If (getVisible(WMN\cntGoInfo) = #False) And (grOperModeOptions(gnOperMode)\bShowNextManualCue)
        setVisible(WMN\cntGoInfo, #True)
      EndIf
      
    Case #SCS_Q2GO_END
      setToolBarBtnCaption(#SCS_TBMB_GO, "End")
      ; debugMsg(sProcName, "calling setToolBarBtnEnabled(#SCS_TBMB_GO, #False)")
      setToolBarBtnEnabled(#SCS_TBMB_GO, #False)
      If bMainMenuDisplayed
        scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuGo, "Go")
        scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuGo, #False)
      EndIf
      If getVisible(WMN\cntGoInfo)
        setVisible(WMN\cntGoInfo, #False)
      EndIf
      
  EndSelect
  
  If bLineToHighlightFound = #False
    highlightLine(gnCueEnd)
    setNavigateButtons()
    gqMainThreadRequest | #SCS_MTH_SET_GRID_WINDOW
  EndIf

  If gbDemoMode
    If (gnDemoTimeCount < 1) And (gbInitialising = #False)
      WMN_displayWarningMsg(Lang("WMN", "DemoTimeExpired"))
      setToolBarBtnEnabled(#SCS_TBMB_GO, #False)
      If bMainMenuDisplayed
        scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuGo, #False)
      EndIf
    EndIf
  EndIf
  
  setToolBarBtnEnabled(#SCS_TBMB_PAUSE_RESUME, #True)
  setToolBarBtnEnabled(#SCS_TBMB_STOP_ALL, #True)
  setToolBarBtnEnabled(#SCS_TBMB_FADE_ALL, #True)
  
  If bMainMenuDisplayed
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuPauseAll, #True)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStopAll, #True)
    scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuFadeAll, #True)
  EndIf
  
  If (gnCueToGo > 0) And (gnCueToGo < gnCueEnd)
    PNL_setPnlColorsForNextManualCue()
  EndIf

  checkCueToGoForWarning()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setGoButtonTip()
  PROCNAMEC()
  Protected bStaticLoaded
  Static sTip1.s, sTip2.s
  Protected sTip.s
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sTip1 = Lang("WMN", "GoTip1") ; "Activate cue by clicking this button"
    sTip2 = Lang("WMN", "GoTip2") ; ", or by a right mouse-click almost anywhere on the Run Screen"
    bStaticLoaded = #True
  EndIf

  sTip = sTip1 ; "Activate cue by clicking this button"
  With grGeneralOptions
    If \bDisableRightClickAsGo = #False
      sTip + sTip2  ; ", or by a right mouse-click almost anywhere on the Run Screen"
    EndIf
  EndWith
  setToolBarBtnToolTip(#SCS_TBMB_GO, sTip)
  
EndProcedure

Procedure setNavigateButtons()
  PROCNAMEC()
  Protected nThisCue
  Protected nMainToolBarInfo, nParentMenu

  debugMsg(sProcName, #SCS_START)
  
  gbCallSetNavigateButtons = #False
  nThisCue = gnHighlightedCue
  
  ; debugMsg(sProcName, "gnOperMode=" + decodeOperMode(gnOperMode))
  If gbInOptionsWindow
    nMainToolBarInfo = mrOperModeOptions(gnOperMode)\nMainToolBarInfo
  Else
    nMainToolBarInfo = grOperModeOptions(gnOperMode)\nMainToolBarInfo
  EndIf
  If nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
    nParentMenu = #WMN_mnuWindowMenu
  Else
    nParentMenu = #WMN_mnuNavigate
  EndIf
  ; debugMsg(sProcName, "nMainToolBarInfo=" + nMainToolBarInfo + ", nParentMenu=" + decodeMenuItem(nParentMenu))
  
  If nThisCue <= 1
    ; debugMsg(sProcName, "disable Top and Back")
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavTop, #False)
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavBack, #False)
  Else
    ; debugMsg(sProcName, "enable Top and Back")
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavTop, #True)
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavBack, #True)
  EndIf

  If nThisCue >= gnLastCue
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavNext, #False)
  Else
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavNext, #True)
  EndIf

  If nThisCue >= (gnLastCue + 1)
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavEnd, #False)
  Else
    scsEnableMenuItem(nParentMenu, #WMN_mnuNavEnd, #True)
  EndIf

  If gnStandbyCuePtr >= 0
    setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #True)
    scsEnableMenuItem(nParentMenu, #WMN_mnuStandbyGo, #True)
  Else
    setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #False)
    setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, Lang("Menu", "mnuStandbyGo"))
    scsEnableMenuItem(nParentMenu, #WMN_mnuStandbyGo, #False)
    scsSetMenuItemText(nParentMenu, #WMN_mnuStandbyGo, Lang("Menu", "mnuStandbyGo"))
  EndIf

  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure setLinksForAudsWithinSubsForCue(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  Protected nMasterAudPtr, nMasterAudDuration
  Protected j, k, k2, k3
  Protected h4, i4, j4
  Protected bBreakLink
  Protected bFirst
  Protected nFirstSubFRelStartTime
  Protected nThisRelStartTime
  Protected bOKToCheckForLinks  ; added 2Nov2015 11.4.1.2g
  Protected nCueDuration1, nCueDuration2
  Protected nAbsStartAt1, nAbsStartAt2  ; added 27Dec2019 11.8.2.1ap
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aCue(pCuePtr)
    
    j = \nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
        nFirstSubFRelStartTime = aSub(j)\nRelStartTime
        Break
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    If nFirstSubFRelStartTime < 0
      nFirstSubFRelStartTime = 0
    EndIf
    
    nMasterAudPtr = -1
    bFirst = #True
    j = \nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeAorF And aSub(j)\bSubEnabled
        nThisRelStartTime = aSub(j)\nRelStartTime
        If nThisRelStartTime < 0
          nThisRelStartTime = 0
        EndIf
        If (nThisRelStartTime = nFirstSubFRelStartTime) And (aSub(j)\nRelStartMode <> #SCS_RELSTART_AE_PREV_SUB) And (aSub(j)\nRelStartMode <> #SCS_RELSTART_BE_PREV_SUB)
          ; only link subs with same relative start as first subcue A or F
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            bOKToCheckForLinks = #False ; code related to bOKToCheckForLinks added 2Nov2015 11.4.1.2g
            If aAud(k)\nMaxLoopInfo = grAudDef\nMaxLoopInfo ; aAud(k)\bContainsLoop = #False
              bOKToCheckForLinks = #True
              ; ok to check if this cue does not contain a loop
            ElseIf (nMasterAudPtr = -1) And (aAud(k)\bLoopLinked)
              bOKToCheckForLinks = #True
              ; ok to check for links if the cue does contain a loop but is (or will be) also the primary file in the linked set AND if the user has allowed looped files to be linked
            EndIf
            If bOKToCheckForLinks
              k2 = aAud(k)\nLinkedToAudPtr
              If bFirst
                If k2 > 0
                  nMasterAudPtr = k2
                Else
                  nMasterAudPtr = k
                EndIf
                If nMasterAudPtr >= 0
                  nMasterAudDuration = aAud(nMasterAudPtr)\nCueDuration
                Else
                  nMasterAudDuration = 0
                EndIf
                bFirst = #False
              Else
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nCueDuration=" + aAud(k)\nCueDuration + ", \nFileFormat=" + decodeFileFormat(aAud(k)\nFileFormat))
                If (aAud(k)\nCueDuration > 0 And aAud(k)\nCueDuration = nMasterAudDuration)
                  If k2 <= 0
                    aAud(k)\nLinkedToAudPtr = nMasterAudPtr
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nLinkedToAudPtr=" + getAudLabel(aAud(k)\nLinkedToAudPtr))
                  EndIf
                  k3 = aAud(k)\nLinkedToAudPtr
                  If k3 > 0
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nCueDuration=" + aAud(k)\nCueDuration + ", aAud(" + getAudLabel(k3) + ")\nCueDuration=" + aAud(k3)\nCueDuration)
                    If (aAud(k)\nCueDuration > 0 And aAud(k)\nCueDuration = aAud(k3)\nCueDuration)
                      If (aAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO) Or (aAud(k3)\nFileFormat = #SCS_FILEFORMAT_VIDEO)
                        aAud(nMasterAudPtr)\nAudLinkCount + 1
                        If (aAud(nMasterAudPtr)\nFirstAudLink = -1) Or (aAud(nMasterAudPtr)\nFirstAudLink > k)
                          aAud(nMasterAudPtr)\nFirstAudLink = k
                        EndIf
                      Else
                        nCueDuration1 = aAud(k)\nCueDuration
                        nCueDuration2 = aAud(k3)\nCueDuration
                        nAbsStartAt1 = aAud(k)\nAbsStartAt
                        nAbsStartAt2 = aAud(k3)\nAbsStartAt
                        If (nCueDuration2 = nCueDuration1) And (nAbsStartAt2 = nAbsStartAt1)
                          aAud(nMasterAudPtr)\nAudLinkCount + 1
                          If (aAud(nMasterAudPtr)\nFirstAudLink = -1) Or (aAud(nMasterAudPtr)\nFirstAudLink > k)
                            aAud(nMasterAudPtr)\nFirstAudLink = k
                          EndIf
                        Else
                          aAud(k)\nLinkedToAudPtr = grAudDef\nLinkedToAudPtr
                        EndIf
                      EndIf
                      If aAud(k)\nLinkedToAudPtr >= 0
                        ; break link if there's an SFR cue acting on this sub-cue
                        bBreakLink = #False
                        For i4 = 1 To gnLastCue
                          If aCue(i4)\bSubTypeS And aCue(i4)\bCueEnabled ; Added \bCueEnabled test 8Jun2024 11.10.3ak
                            j4 = aCue(i4)\nFirstSubIndex
                            While (j4 >= 0) And (bBreakLink = #False)
                              If aSub(j4)\bSubTypeS And aSub(j4)\bSubEnabled ; Added \bSubEnabled test 8Jun2024 11.10.3ak
                                For h4 = 0 To #SCS_MAX_SFR
                                  If aSub(j4)\nSFRCueType[h4] = #SCS_SFR_CUE_SEL
                                    If (aSub(j4)\nSFRCuePtr[h4] = pCuePtr) And (aSub(j4)\nSFRSubPtr[h4] = j)
                                      ; debugMsg(sProcName, "break link aAud(" + getAudLabel(k) + ")\" + getAudLabel(aAud(k)\nLinkedToAudPtr) + " due to aSub(" + getSubLabel(j4) + ")")
                                      bBreakLink = #True
                                      Break
                                    EndIf
                                  EndIf
                                Next h4
                              EndIf
                              j4 = aSub(j4)\nNextSubIndex
                            Wend
                          EndIf
                          If bBreakLink
                            Break
                          EndIf
                        Next i4
                        If bBreakLink
                          aAud(k)\nLinkedToAudPtr = grAudDef\nLinkedToAudPtr
                          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nLinkedToAudPtr=" + getAudLabel(aAud(k)\nLinkedToAudPtr))
                        EndIf
                      EndIf ; EndIf aAud(k)\nLinkedToAudPtr
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setMTCLinksForAllCues()
  PROCNAMEC()
  Protected i, j, k
  Protected i2, j2, k2
  Protected i4, j4, h4
  Protected bCheckTheseSubs
  Protected nCueLength, bOKToLink
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \nMTCLinkedToAFSubPtr <> grSubDef\nMTCLinkedToAFSubPtr
          \nMTCLinkedToAFSubPtr = grSubDef\nMTCLinkedToAFSubPtr
          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nMTCLinkedToAFSubPtr=" + getSubLabel(\nMTCLinkedToAFSubPtr))
        EndIf
        If \nAFLinkedToMTCSubPtr <> grSubDef\nAFLinkedToMTCSubPtr
          \nAFLinkedToMTCSubPtr = grSubDef\nAFLinkedToMTCSubPtr
          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nAFLinkedToMTCSubPtr=" + getSubLabel(\nAFLinkedToMTCSubPtr))
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeU And aCue(i)\bCueEnabled
      nCueLength = getCueLengthForMTCLink(i)
      ; debugMsg(sProcName, "getCueLengthForMTCLink(" + getCueLabel(i) + ") returned " + ttszt(nCueLength))
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeU And aSub(j)\bSubEnabled And aSub(j)\nMTCLinkedToAFSubPtr = grSubDef\nMTCLinkedToAFSubPtr
          For i2 = 1 To gnLastCue
            If aCue(i2)\bSubTypeAorF And aCue(i2)\bCueEnabled
              j2 = aCue(i2)\nFirstSubIndex
              While j2 >= 0
                k2 = aSub(j2)\nFirstAudIndex
                If aSub(j2)\bSubEnabled And k2 >= 0
                  If aSub(j2)\bSubTypeA And (aSub(j2)\nAudCount > 1 Or aAud(k2)\nFileFormat <> #SCS_FILEFORMAT_VIDEO)
                    ; Do not link an MTC sub-cue to a video/image sub-cue if the video/image cue contains more than one file, or if that file is a still image
                    j2 = aSub(j2)\nNextSubIndex
                    Continue
                  EndIf
                  If aSub(j2)\bSubTypeAorF And aSub(j2)\nAFLinkedToMTCSubPtr = grSubDef\nAFLinkedToMTCSubPtr
                    ; possible candidate type A or F to be linked to this type U
                    bCheckTheseSubs = #False
                    If i2 = i
                      ; type AorF is in the same cue as type U
                      bCheckTheseSubs = #True
                    Else
                      ; type AorF is NOT in the same cue as type U
                      If (((aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO) Or (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)) And (aCue(i)\nAutoActPosn = #SCS_ACPOSN_AS) And (aCue(i)\nAutoActTime = 0) And aCue(i)\nAutoActCuePtr = i2) Or
                         (((aCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO) Or (aCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)) And (aCue(i2)\nAutoActPosn = #SCS_ACPOSN_AS) And (aCue(i2)\nAutoActTime = 0) And aCue(i2)\nAutoActCuePtr = i)
                        bCheckTheseSubs = #True
                      EndIf
                    EndIf ; EndIf i2 = i / Else
                    If bCheckTheseSubs
                      ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nRelStartMode=" + decodeRelStartMode(aSub(j)\nRelStartMode) + ", aSub(" + getSubLabel(j2) + ")\nRelStartMode=" + decodeRelStartMode(aSub(j2)\nRelStartMode) +
                      ;                     ", aSub(" + getSubLabel(j) + ")\nRelStartTime=" + aSub(j)\nRelStartTime + ", aSub(" + getSubLabel(j2) + ")\nRelStartTime=" + aSub(j2)\nRelStartTime)
                      If (aSub(j2)\nRelStartMode = aSub(j)\nRelStartMode) And (aSub(j2)\nRelStartTime = aSub(j)\nRelStartTime)
                        ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubDuration=" + aSub(j)\nSubDuration + ", aSub(" + getSubLabel(j2) + ")\nSubDuration=" + aSub(j2)\nSubDuration )
                        If (aSub(j)\nSubDuration <= 0) Or (Abs(aSub(j2)\nSubDuration - aSub(j)\nSubDuration) < 5)
                          ; No duration set for MTC sub-cue, or less than 5 milliseconds difference between durations
                          ; Note that 'no duration' is acceptable for linking - see the information about 'Duration' in the Help file topic 'MTC/LTC Cues' under 'The Editor'.
                          bOKToLink = #True
                          ; Deleted 11Nov2024 11.10.6b1, replaced by the code following this deletion. Bug reported by André Grohmann.
                          ; SCS was linking the audio/video sub-cue with the maximum duration to the MTC sub-cue, even if that audio/video sub-cue was LATER in the cue.
                          ; If aSub(j)\nSubDuration <= 0
                          ;   If (aSub(j2)\nSubDuration + aSub(j2)\nRelStartTime) < (nCueLength - 5)
                          ;     bOKToLink = #False
                          ;   EndIf
                          ; EndIf
                          ; End deleted 11Nov2024 11.10.6b1
                          ; Added 11Nov2024 11.10.6bi
                          ; Now changed (11.10.6bi) to only check audio/video sub-cues BEFORE the MTC sub-cue.
                          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubType=" + aSub(j)\sSubType + ", \nSubNo=" + aSub(j)\nSubNo + ", aSub(" + getSubLabel(j2) + ")\sSubType=" + aSub(j2)\sSubType + ", \nSubNo=" + aSub(j2)\nSubNo)
                          If aSub(j2)\nSubNo > aSub(j)\nSubNo
                            ; debugMsg(sProcName, "setting bOKToLink=#False")
                            bOKToLink = #False
                          EndIf
                          ; End added 11Nov2024 11.10.6bi
                          ; debugMsg(sProcName, "bOKToLink=" + strB(bOKToLink))
                          If bOKToLink
                            ; Added 8Jun2024 11.10.3ak
                            For i4 = 1 To gnLastCue
                              If aCue(i4)\bCueEnabled And aCue(i4)\bSubTypeS
                                j4 = aCue(i4)\nFirstSubIndex
                                While j4 >= 0
                                  If aSub(j4)\bSubEnabled And aSub(j4)\bSubTypeS
                                    For h4 = 0 To #SCS_MAX_SFR
                                      If aSub(j4)\nSFRAction[h4] = #SCS_SFR_ACT_STOPMTC
                                        bOKToLink = #False
                                        Break 3 ; Break h4, j4, i4
                                      EndIf
                                    Next h4
                                  EndIf
                                  j4 = aSub(j4)\nNextSubIndex
                                Wend
                              EndIf
                            Next i4
                            ; debugMsg(sProcName, "bOKToLink=" + strB(bOKToLink))
                            ; End added 8Jun2024 11.10.3ak
                            If bOKToLink
                              ; debugMsg(sProcName, "linking MTC sub-cue " + getSubLabel(j) + " to " + decodeSubTypeL(aSub(j2)\sSubType, j2) + " sub-cue " + getSubLabel(j2))
                              aSub(j)\nMTCLinkedToAFSubPtr = j2
                              aSub(j2)\nAFLinkedToMTCSubPtr = j
                              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nMTCLinkedToAFSubPtr=" + getSubLabel(aSub(j)\nMTCLinkedToAFSubPtr) +
                              ;                     ", aSub(" + getSubLabel(j2) + ")\nAFLinkedToMTCSubPtr=" + getSubLabel(aSub(j2)\nAFLinkedToMTCSubPtr))
                              Break 2 ; Break both j2 and j as only one link is permitted for any aSub(j)\bSubTypeU
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf ; EndIf aSub(j2)\bSubTypeAorF And aSub(j2)\nAFLinkedToMTCSubPtr = grSubDef\nAFLinkedToMTCSubPtr
                EndIf ; EndIf aSub(j2)\bSubEnabled
                j2 = aSub(j2)\nNextSubIndex
              Wend ; Wend J2 >= 0
            EndIf ; EndIf aCue(i2)\bSubTypeF And aCue(i2)\bCueEnabled
          Next i2
        EndIf ; EndIf aSub(j)\bSubTypeU And aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend ; Wend j >= 0
    EndIf ; EndIf aCue(i)\bSubTypeU And aCue(i)\bCueEnabled
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setLinksForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected k1, k2
  Protected nK1RelStartTime, nK2RelStartTime, nPrimaryLinkCuePtr

  ; debugMsg(sProcName, #SCS_START)

  With aCue(pCuePtr)
    If (\bSubTypeF) And
       ((\nActivationMethod = #SCS_ACMETH_AUTO) Or (\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)) And
       (\nAutoActPosn = #SCS_ACPOSN_AS) And
       (\nAutoActTime = 0) And
       (\nFirstSubIndex >= 0) And
       (\bCueEnabled) ; Added \bCueEnabled 13Aug2022 11.9.4
      ; Cue contains at least one type F sub (Audio File)
      ; debugMsg(sProcName, "\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nFirstSubIndex=" + \nFirstSubIndex + ", \nAutoActCuePtr=" + \nAutoActCuePtr)
      If aSub(\nFirstSubIndex)\nFirstAudIndex >= 0 And aSub(\nFirstSubIndex)\bSubEnabled ; Added \bSubEnabled 13Aug2022 11.9.4
        ; debugMsg(sProcName, "aSub(" + \nFirstSubIndex + ")\nFirstAudIndex=" + aSub(\nFirstSubIndex)\nFirstAudIndex)
        If (aCue(\nAutoActCuePtr)\bSubTypeF) And (aCue(\nAutoActCuePtr)\nFirstSubIndex >= 0)
          
          ; added 26Mar2020 11.8.2.3af
          nPrimaryLinkCuePtr = \nAutoActCuePtr
          If aCue(\nAutoActCuePtr)\nLinkedToCuePtr >= 0
            nPrimaryLinkCuePtr = aCue(\nAutoActCuePtr)\nLinkedToCuePtr
          EndIf
          ; end added 26Mar2020 11.8.2.3af, but following references to \nAutoActCuePtr changed to nPrimaryLinkCuePtr
          
          If aCue(nPrimaryLinkCuePtr)\nLinkedToCuePtr < 0
            
            If aCue(nPrimaryLinkCuePtr)\nCueState < #SCS_CUE_COMPLETED
              ; 21/08/2014 (11.3.3): added the above test on \nCueState following a test using a cue file supplied by John Hutchinson (see Test1.scs11)
              ; This cue file has two linked cues (310 linked to 306). If you click on 310, thus closing 306, the BASS links were removed by removeLinksOneAud()
              ; and clearLinksForCue(306) was called by setCueState() BUT this procedure (resetLinks(306)) was subsequently called
              ; which reinstated the SCS (not BASS) link of 310 to 306. This resulted in 310 not audibly playing, even though the progress counters etc indicated
              ; it was playing. So setLinksForCue(i) should NOT be called for completed cues.
              
              k1 = aSub(aCue(nPrimaryLinkCuePtr)\nFirstSubIndex)\nFirstAudIndex
              k2 = aSub(aCue(pCuePtr)\nFirstSubIndex)\nFirstAudIndex
              
              If (k1 >= 0) And (k2 >= 0)
                
                nK1RelStartTime = aSub(aCue(nPrimaryLinkCuePtr)\nFirstSubIndex)\nRelStartTime
                If nK1RelStartTime < 0
                  nK1RelStartTime = 0
                EndIf
                nK2RelStartTime = aSub(aCue(pCuePtr)\nFirstSubIndex)\nRelStartTime
                If nK2RelStartTime < 0
                  nK2RelStartTime = 0
                EndIf
                
                ; debugMsg(sProcName, "aAud(" + k1 + ")\nCueDuration=" + aAud(k1)\nCueDuration + ", aAud(" + k2 + ")\nCueDuration=" + aAud(k2)\nCueDuration)
                ; If (aAud(k1)\nCueDuration = aAud(k2)\nCueDuration) And (aAud(k1)\nCueDuration <> grAudDef\nCueDuration) And (nK1RelStartTime = nK2RelStartTime)
                If (Abs(aAud(k1)\nCueDuration - aAud(k2)\nCueDuration) < 5) And (aAud(k1)\nCueDuration <> grAudDef\nCueDuration) And (nK1RelStartTime = nK2RelStartTime)
                  ; less than 5 milliseconds difference between durations
                  If aCue(nPrimaryLinkCuePtr)\nFirstCueLink < 0
                    aCue(nPrimaryLinkCuePtr)\nFirstCueLink = pCuePtr
                  EndIf
                  
                  aCue(nPrimaryLinkCuePtr)\nCueLinkCount + 1
                  aCue(pCuePtr)\nLinkedToCuePtr = nPrimaryLinkCuePtr
                  
                  If aAud(k1)\nFirstAudLink < 0
                    If aAud(k1)\nLinkedToAudPtr < 0
                      aAud(k1)\nFirstAudLink = k2
                    EndIf
                  EndIf
                  
                  aAud(k1)\nAudLinkCount + 1
                  
                  If aAud(k2)\nLinkedToAudPtr <> k1
                    aAud(k2)\bCallSetLinksOneAud = #True
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k2) + ")\bCallSetLinksOneAud=" + strB(aAud(k2)\bCallSetLinksOneAud))
                    ; 21/08/2014 (11.3.3) added \bCallSetLinksOneAud = #True
                    aAud(k2)\nLinkedToAudPtr = k1
                    debugMsg(sProcName, "aAud(" + getAudLabel(k2) + ")\nLinkedToAudPtr=" + getAudLabel(aAud(k2)\nLinkedToAudPtr))
                  EndIf
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k2) + ")\nLinkedToAudPtr=" + getAudLabel(aAud(k2)\nLinkedToAudPtr))
                  
                Else
                  aAud(k1)\nAudLinkCount - 1
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k1) + ")\nAudLinkCount=" + aAud(k1)\nAudLinkCount)
                  
                  aAud(k2)\nLinkedToAudPtr = -1
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k2) + ")\nLinkedToAudPtr=" + getAudLabel(aAud(k2)\nLinkedToAudPtr))
                  
                EndIf
              EndIf ; EndIf (k1 >= 0) And (k2 >= 0)
              
            EndIf ; EndIf aCue(nPrimaryLinkCuePtr)\nCueState < #SCS_CUE_COMPLETED
          EndIf ; EndIf aCue(nPrimaryLinkCuePtr)\nLinkedToCuePtr < 0
        EndIf ; EndIf (aCue(\nAutoActCuePtr)\bSubTypeF) And (aCue(\nAutoActCuePtr)\nFirstSubIndex >= 0)
      EndIf ; EndIf aSub(\nFirstSubIndex)\nFirstAudIndex >= 0
    EndIf ; EndIf (\bSubTypeF) And (...)
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure clearLinksForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected i, j, k, k2
  Protected nAudLinkCount
  
  debugMsg(sProcName, #SCS_START)
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeHasAuds And aSub(j)\bSubEnabled
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          If aAud(k)\nAudLinkCount > 0 And aAud(k)\nLinkedToAudPtr = -1
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudLinkCount=" + aAud(k)\nAudLinkCount + ", \nFirstAudLink=" + getAudLabel(aAud(k)\nFirstAudLink))
            nAudLinkCount = aAud(k)\nAudLinkCount
            k2 = aAud(k)\nFirstAudLink
            While (nAudLinkCount > 0) And (k2 <= gnLastAud)
              If aAud(k2)\nLinkedToAudPtr = k
                aAud(k2)\nLinkedToAudPtr = -1
                debugMsg(sProcName, "aAud(" + getAudLabel(k2) + ")\nLinkedToAudPtr=" + getAudLabel(aAud(k2)\nLinkedToAudPtr))
              EndIf
              k2 + 1
            Wend
          EndIf
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    aCue(pCuePtr)\bCallClearLinksForCue = #False
    debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bCallClearLinksForCue=" + strB(aCue(pCuePtr)\bCallClearLinksForCue))
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setSaveSettings(bRefreshOnly=#False)
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", bRefreshOnly=" + strB(bRefreshOnly))
  If bRefreshOnly
    WMN_refreshMenu_SaveSettings()
  Else
    buildSaveSettingsMenu()
  EndIf
  setFileSave()
EndProcedure

Procedure resetTOD()
  ; reset time-of-day
  PROCNAMEC()
  Protected i, j
  Protected nDay
  
  debugMsg(sProcName, #SCS_START)
  
  gbResettingTODPart1 = #True
  
  debugMsg(sProcName, "calling processFadeAll()")
  processFadeAll()
  
  debugMsg(sProcName, "calling createProdDatabaseIfReqd()")
  createProdDatabaseIfReqd()
  With grProd
    If OpenDatabase(\nDatabaseNo, \sDatabaseFile, "", "")
      debugMsg(sProcName, "calling savePlaylistOrdersToProdDatabase()")
      savePlaylistOrdersToProdDatabase()  ; saved directly from aSub() etc, not from copied from the temp database
      CloseDatabase(\nDatabaseNo)
    EndIf
  EndWith
  
  logListEvent(sProcName, "calling setRandomSeed()")
  setRandomSeed() ; nb must be called BEFORE the following loop that re-generates play orders
  
  For i = 1 To gnLastCue
    If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
      aCue(i)\bTBCDone = #False
      aCue(i)\nActivationMethodReqd = aCue(i)\nActivationMethod
    EndIf
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeP And aSub(j)\bSubEnabled
        If aSub(j)\bPLRandom Or aSub(j)\bPLSavePos
          aSub(j)\sPlayOrder = ""     ; force playlist to be re-randomized
          aSub(j)\bPLDatabaseInfoLoaded = #False
          debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(j) + ", #True, #True, #True)")
          generatePlayOrder(j, #True, #True, #True)
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  ; reset time profile
  gsWhichTimeProfile = grProd\sDefaultTimeProfile
  nDay = DayOfWeek(Date())
  CompilerIf #c_next_day_in_resetTOD
    nDay + 1
    If nDay > 6
      nDay = 0
    EndIf
  CompilerEndIf
  If grProd\sDefaultTimeProfileForDay[nDay]
    gsWhichTimeProfile = grProd\sDefaultTimeProfileForDay[nDay]
  EndIf
  debugMsg(sProcName, "gsWhichTimeProfile=" + gsWhichTimeProfile + ", Len(gsWhichTimeProfile)=" + Len(gsWhichTimeProfile))
  
  debugMsg(sProcName, "calling setTimeBasedCues()")
  setTimeBasedCues()
  
  ; added 20Apr2016 11.5.0 following bug report on 'Time Based Cues' from squuk
  WMN_setWindowTitle()
  gbCallPopulateGrid = #True
  gbCallLoadDispPanels = #True
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues + ", gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
  ; end of added 20Apr2016

  ; samAddRequest(#SCS_SAM_GOTO_CUE, 1)
  debugMsg(sProcName, "calling GoToCue(getFirstEnabledCue())")
  GoToCue(getFirstEnabledCue())
  
  gbResettingTODPart1 = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure stopEverythingPart1(pCuePtr=-1, bResetAfterStop=#True, bResumeThreadsAfterStop=#True, bResettingTOD=#False)
  ; if pCuePtr > 0 then go to that cue after stopping everything (used by applyDevChanges())
  PROCNAMEC()
  Protected i, k
  Protected bAudStopped
  
  logMsg(sProcName, #SCS_START + ", pCuePtr=" + getCueLabel(pCuePtr) + ", bResetAfterStop=" + strB(bResetAfterStop) + ", bResumeThreadsAfterStop=" + strB(bResumeThreadsAfterStop) + ", bResettingTOD=" + strB(bResettingTOD))
  
  With grStopEverythingInfo
    \nCuePtr = pCuePtr
    \bResetAfterStop = bResetAfterStop
    \bResumeThreadsAfterStop = bResumeThreadsAfterStop
    \bCallStopEverythingPart2 = #False
    \nDelayTimeBeforePart2 = 0
    ; \bResettingTOD = bResettingTOD
  EndWith
  
  If gnThreadNo > #SCS_THREAD_MAIN
    ; can lock up system if not called from main thread, eg if called from within the control thread due to an incoming MIDI message
    gbStopEverything = #True
    ProcedureReturn
  EndIf
  
  gbStopEverything = #False
  gbStoppingEverything = #True
  debugMsg(sProcName, "gbStoppingEverything=" + strB(gbStoppingEverything))
  setGlobalTimeNow()
  gqStopEverythingTime = gqTimeNow
  
  THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)

  ; clear SAM stack unless currently loading a cue file
  If gbLoadingCueFile = #False
    samInit()
  EndIf
  gnCueToGoOverride = -1
  gnFirstCueStopped = -1  ; added 4Jan2020 11.8.2ax
  
  clearTVGFadeAudArray() ; added 14Jun2018 11.7.1rc3
  
  M2T_cancelMoveToTimeDisplayIfActive()
  
  For i = 1 To gnLastCue
    With aCue(i)
      \nStopEverythingCueState = \nCueState
    EndWith
  Next i
  
  If gnActiveAudPtr > 0
    ; stop most recently started Aud first
    With aAud(gnActiveAudPtr)
      If (\nAudState <> #SCS_CUE_HIBERNATING) Or (grProd\bStopAllInclHib)
        If \bAudTypeA
          debugMsg(sProcName, "calling fadeOutSub(" + getSubLabel(\nSubIndex) + ", #False, #True, #False, #True)")
          fadeOutSub(\nSubIndex, #False, #True, #False, #True)
        Else
          debugMsg(sProcName, "calling StopOrFadeOutAudChannels(" + getAudLabel(gnActiveAudPtr) + ")")
          StopOrFadeOutAudChannels(gnActiveAudPtr, #False, #False, #False, \nAudVidPicTarget)
        EndIf
        bAudStopped = #True
      EndIf
    EndWith
  EndIf
  
  ; stop other Aud's
  For k = 1 To ArraySize(aAud())
    If k <> gnActiveAudPtr
      If (aAud(k)\nAudState <> #SCS_CUE_HIBERNATING) Or (grProd\bStopAllInclHib)
        If aAud(k)\nAudState <> #SCS_CUE_NOT_LOADED
          If (aAud(k)\nAudState > #SCS_CUE_READY) And (aAud(k)\nAudState < #SCS_CUE_COMPLETED) And (aAud(k)\nAudState <> #SCS_CUE_PL_READY)
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState) + ", calling StopOrFadeOutAudChannels(" + getAudLabel(k) + ")")
            StopOrFadeOutAudChannels(k, #False, #False, #False, aAud(k)\nAudVidPicTarget)
            bAudStopped = #True
          EndIf
        EndIf
      EndIf
    EndIf
  Next k
  
  ; debugMsg(sProcName, "calling disableGoButtons")
  WMN_disableGoButtons()
  M2T_cancelMoveToTimeDisplayIfActive()
  setMouseCursorBusy()
  
  If gbFadingEverything
    WMN_displayWarningMsg(grText\sTextFadingEverything)
  Else
    WMN_displayWarningMsg(grText\sTextStoppingEverything)
  EndIf
  
  gbResettingTODPart2 = gbResettingTODPart1 ; required by stopEverythingPart2() whether called directly or via grStopEverythingInfo\bCallStopEverythingPart2 = #True
  
  If gbFadingEverything
    If (bAudStopped) And (gnFadeEverythingTime > 0)
      ; Delay(gnFadeEverythingTime)
      grStopEverythingInfo\nDelayTimeBeforePart2 = gnFadeEverythingTime
      grStopEverythingInfo\bCallStopEverythingPart2 = #True
      ProcedureReturn
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling stopEverythingPart2(" + getCueLabel(pCuePtr) + ", " + strB(bResetAfterStop) + ", " + strB(bResumeThreadsAfterStop) + ")")
  stopEverythingPart2(pCuePtr, bResetAfterStop, bResumeThreadsAfterStop)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure stopEverythingPart2(pCuePtr=-1, bResetAfterStop=#True, bResumeThreadsAfterStop=#True)
  PROCNAMEC()
  Protected d, i, k, n, nBassDevice, nBassResult.l
  Protected bASIO, nBassASIODevice.l
  Protected nBufLen.l
  
  logMsg(sProcName, #SCS_START + ", pCuePtr=" + getCueLabel(pCuePtr) + ", bResetAfterStop=" + strB(bResetAfterStop) + ", bResumeThreadsAfterStop=" + strB(bResumeThreadsAfterStop))
  
  With grStopEverythingInfo
    \bCallStopEverythingPart2 = #False
    \nDelayTimeBeforePart2 = 0
  EndWith
  
  ; stop all cues
  debugMsg(sProcName, "calling stopAll(#False, #True, " + strB(grProd\bStopAllInclHib) + ")")
  stopAll(#False, #True, grProd\bStopAllInclHib)
  
  If gbVideosOnMainWindow
    debugMsg(sProcName, "calling hideVideoWindowsNotInUse()")
    hideVideoWindowsNotInUse()
  Else
    debugMsg(sProcName, "calling hideMonitorsNotInUse()")
    hideMonitorsNotInUse()
  EndIf
  
  ; Added 30Aug2024 11.10.3bq
  For n = 0 To grLicInfo\nLastVidPicTarget
    Select n
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        If IsImage(grVidPicTarget(n)\nLogoImageNo) And grVidPicTarget(n)\bLogoCurrentlyDisplayed = #False
          debugMsg(sProcName, "calling clearPicture(" + decodeVidPicTarget(n) + ")")
          clearPicture(n)
        EndIf
    EndSelect
  Next n
  ; End added 30Aug2024 11.10.3bq

  If gbUseBASS
    If gbUseBASSMixer
      debugMsg(sProcName, "calling lockAllMixerStreams(#False)")
      lockAllMixerStreams(#False)
    EndIf
  EndIf
  
  For n = 0 To grLicInfo\nLastVidPicTarget
    With grVidPicTarget(n)
      \nPrimaryAudPtr = -1
      \nPrevPrimaryAudPtr = -1
      \nPlayingSubPtr = -1
      \nPrevPlayingSubPtr = -1
    EndWith
  Next n

  If grTVGControl\bCloseTVGsWaiting
    debugMsg(sProcName, "calling freeWaitingTVGControls()")
    freeWaitingTVGControls()
  EndIf
  
  If bResetAfterStop
    
    debugMsg(sProcName, "calling freeStreams(#True)")
    freeStreams(#True)
    
    debugMsg(sProcName, "calling setTimeBasedCues()")
    setTimeBasedCues()
    
    ; restart devices
    debugMsg(sProcName, "restart devices")
    For d = 0 To ArraySize(gaAudioDev())
      With gaAudioDev(d)
        If \bInitialized
          ; debugMsg3(sProcName, "gaAudioDev(" + d + ")\sDesc=" + \sDesc + ", \bASIO=" + strB(\bASIO) + ", \nBassASIODevice=" + \nBassASIODevice + ", \nBassDevice=" + \nBassDevice + ", \bInitialized=" + strB(\bInitialized))
          bASIO = \bASIO
          If bASIO  ; ASIO
            nBassASIODevice = \nDevBassASIODevice
            If nBassASIODevice > 0
              nBassResult = BASS_ASIO_SetDevice(nBassASIODevice)
              debugMsg2(sProcName, "BASS_ASIO_SetDevice(" + nBassASIODevice + ")", nBassResult)
              nBassResult = BASS_ASIO_IsStarted()
              debugMsg2(sProcName, "BASS_ASIO_IsStarted()", nBassResult)
              If nBassResult = #BASSFALSE
                CompilerIf #cEnableASIOBufLen
                  nBufLen = \nAsioBufLen
                CompilerElse
                  nBufLen = 0
                CompilerEndIf
                nBassResult = BASS_ASIO_Start(nBufLen, 0)
                debugMsg2(sProcName, "BASS_ASIO_Start(" + nBufLen + ", 0) for ASIO device " + nBassASIODevice, nBassResult)
                If nBassResult = #BASSFALSE
                  debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ASIO_ErrorGetCode()))
                EndIf
              EndIf
            EndIf
          Else
            nBassDevice = \nBassDevice
            If nBassDevice > 0
              nBassResult = BASS_SetDevice(nBassDevice)
              debugMsg2(sProcName, "BASS_SetDevice(" + nBassDevice + ")", nBassResult)
              nBassResult = BASS_Start()
              debugMsg2(sProcName, "BASS_Start for device " + nBassDevice, nBassResult)
            EndIf
          EndIf
        EndIf
      EndWith
    Next d
    
    If pCuePtr > 0
      debugMsg(sProcName, "calling goToCue(" + getCueLabel(pCuePtr) + ")")
      GoToCue(pCuePtr)
      If gbInExternalControl = #False
        SAG(-1)  ; will fail if current window is not fmMain
      EndIf
      
    ElseIf gnNonLinearCue > 0
      CompilerIf 1=1 ; mod 23Oct2018 11.7.1.4at for Richard Borsey as it seems that "GoToCue(gnNonLinearCue)" may leave some auto-start cues counting down instead of being reset to Ready.
        debugMsg(sProcName, "calling setCuePosition(" + getCueLabel(gnNonLinearCue) + ")")
        setCuePosition(gnNonLinearCue)
      CompilerElse
        debugMsg(sProcName, "calling goToCue(" + getCueLabel(gnNonLinearCue) + ")")
        GoToCue(gnNonLinearCue)
      CompilerEndIf
      If gbInExternalControl = #False
        SAG(-1)  ; will fail if current window is not fmMain
      EndIf
      
    ElseIf gnFirstCueStopped > 0
      debugMsg(sProcName, "calling setCuePosition(" + getCueLabel(gnFirstCueStopped) + ")")
      setCuePosition(gnFirstCueStopped)
      If gbInExternalControl = #False
        SAG(-1)  ; will fail if current window is not fmMain
      EndIf
      
    Else
      debugMsg(sProcName, "calling setGoButton")
      setGoButton()
      setNavigateButtons()
      
    EndIf
    
    If gbUseSMS
      ; rebuild getSMSCurrInfo() command strings
      buildGetSMSCurrInfoCommandStrings()
    EndIf
    
    WCN_setLiveOnInds()
    
  EndIf
  
  debugMsg(sProcName, "calling clearVUDisplay")
  clearVUDisplay()
  
  setLastPlayingCue(-1)  ; hides 'last active cue'
  
  If RAI_IsClientActive()
    If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
      debugMsg(sProcName, "calling sendRAIGlobalCommand(" + #DQUOTE$ + "stopall" + #DQUOTE$ + ")")
      sendRAIGlobalCommand("stopall")
    EndIf
  EndIf

  setToolBarCurrentImageIndex(#SCS_TBMB_PAUSE_RESUME, 0)
  gbGlobalPause = #False
  debugMsg(sProcName, "gbGlobalPause=" + strB(gbGlobalPause))
  
  ; restart timer
  If bResumeThreadsAfterStop
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
  EndIf

  gbStoppingEverything = #False
  debugMsg(sProcName, "gbStoppingEverything=" + strB(gbStoppingEverything))
  gbFadingEverything = #False
  
  If gbPictureBlending
    gbPictureBlending = #False
    debugMsg(sProcName, "gbPictureBlending=" + strB(gbPictureBlending))
  EndIf
  
  displayDemoCount()   ; redisplay demo count if necessary
  samAddRequest(#SCS_SAM_HIDE_WARNING_MSG)  ; hide warning message
  
  ; Blocked out 18Jan2024 11.10.0 as this 'stop all' command is also sent to the backup in processStopAll(), which is the logical place for this to be called.
  ; Discovered that the 'stop all' was being sent twice due to the code below.
  ;   If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
  ;     debugMsg(sProcName, "calling FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_STOP_ALL)")
  ;     FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_STOP_ALL)
  ;   EndIf
  ; End blocked out 18Jan2024 11.10.0
  
  setGoButton()
  
  gbResettingTODPart2 = #False
  
  setMouseCursorNormal()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure pauseAll()
  PROCNAMEC()
  Protected k, nMyAudState
  Protected i, j
  Protected nMySubState
  
  If gnThreadNo > #SCS_THREAD_MAIN
    gqMainThreadRequest | #SCS_MTH_PAUSE_ALL
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)
  
  setMouseCursorBusy()

  ; stop timer
  debugMsg(sProcName, "calling THR_suspendAThread(#SCS_THREAD_CONTROL)")
  THR_suspendAThread(#SCS_THREAD_CONTROL)

  gbInPauseAll = #True
  gbGlobalPause = #True
  debugMsg(sProcName, "gbGlobalPause=" + strB(gbGlobalPause))

  ; clear SAM stack
  samInit()

  setGlobalTimeNow()
  gqGlobalPauseTimeStarted = gqTimeNow
  
  If THR_getThreadState(#SCS_THREAD_MTC_CUES) = #SCS_THREAD_STATE_ACTIVE
    debugMsg(sProcName, "calling THR_suspendAThread(#SCS_THREAD_MTC_CUES)")
    THR_suspendAThread(#SCS_THREAD_MTC_CUES)
  EndIf
  
  If gnActiveAudPtr > 0
    ; pause most recently started Aud first
    nMyAudState = aAud(gnActiveAudPtr)\nAudState
    If (nMyAudState >= #SCS_CUE_FADING_IN) And (nMyAudState <= #SCS_CUE_FADING_OUT) And (nMyAudState <> #SCS_CUE_PAUSED)
      debugMsg(sProcName, "calling pauseAud(" + getAudLabel(gnActiveAudPtr) + ")")
      pauseAud(gnActiveAudPtr)
      aAud(gnActiveAudPtr)\bGloballyPaused = #True
      j = aAud(gnActiveAudPtr)\nSubIndex
      debugMsg(sProcName, "calling pauseSub(" + getSubLabel(j) + ")")
      pauseSub(j)
    Else
      aAud(gnActiveAudPtr)\bGloballyPaused = #False
    EndIf
  EndIf
  ; pause other Aud's
  For k = 1 To ArraySize(aAud())
    If k <> gnActiveAudPtr
      aAud(k)\bGloballyPaused = #False
      nMyAudState = aAud(k)\nAudState
      If (nMyAudState >= #SCS_CUE_FADING_IN) And (nMyAudState <= #SCS_CUE_FADING_OUT) And (nMyAudState <> #SCS_CUE_PAUSED)
        debugMsg(sProcName, "calling pauseAud(" + getAudLabel(k) + ")")
        pauseAud(k)
        aAud(k)\bGloballyPaused = #True
        j = aAud(k)\nSubIndex
        debugMsg(sProcName, "calling pauseSub(" + getSubLabel(j) + ")")
        pauseSub(j)
      EndIf
    EndIf
  Next k
  For i = 1 To gnLastCue
    ; pause sub types E, K, M and U
    If aCue(i)\bSubTypeE Or aCue(i)\bSubTypeK Or aCue(i)\bSubTypeM Or aCue(i)\bSubTypeU
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If aSub(j)\bSubEnabled
            If \bSubTypeE Or \bSubTypeK Or \bSubTypeM Or \bSubTypeP Or \bSubTypeU
              nMySubState = \nSubState
              If (nMySubState >= #SCS_CUE_FADING_IN) And (nMySubState <= #SCS_CUE_FADING_OUT) And (nMySubState <> #SCS_CUE_PAUSED)
                debugMsg(sProcName, "calling pauseSub(" + getSubLabel(j) + ")")
                pauseSub(j) ; nb sets aSub(j)\SubGloballyPaused and \qSubTimePauseStarted for these subtypes because gbInPauseAll is #True
              EndIf
            EndIf
          EndIf
        EndWith
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  setToolBarCurrentImageIndex(#SCS_TBMB_PAUSE_RESUME, 1)
  scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuPauseAll, Lang("Menu", "mnuResumeAll"))
  
  If RAI_IsClientActive()
    If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
      debugMsg(sProcName, "calling sendRAIGlobalCommand(" + #DQUOTE$ + "pauseall" + #DQUOTE$ + ")")
      sendRAIGlobalCommand("pauseall")
    EndIf
  EndIf
  
  setGoButton()
  
  gbInPauseAll = #False
  
  ; restart timer
  debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  setMouseCursorNormal()

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure resetSubTimeToStart(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nTimeOnPause
  Protected k
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubCountDownPaused
        nTimeOnPause = ElapsedMilliseconds() - \qTimeSubCountDownPaused
        If (\nSubState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nSubState <= #SCS_CUE_FADING_OUT)
          \nTotalTimeOnGlobalPause + nTimeOnPause
        EndIf
        If \nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
          \qTimeToStartSub + nTimeOnPause
        EndIf
        If \bSubTypeAorP
          k = \nFirstPlayIndex
          While k >= 0
            If aAud(k)\nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START
              aAud(k)\qPLTimeTransStarted + nTimeOnPause
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure resetCueTimeToStart(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nTimeOnPause
  Protected j, k
  
  debugMsg(sProcName, #SCS_START)
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      If \bCueCountDownPaused
        nTimeOnPause = ElapsedMilliseconds() - \qTimeCueCountDownPaused
        CompilerIf 1=2  ; 11.6.3ac - blocked out because resetSubTimeToStart() is always called when necessary after resetCueTimeToStart()
          j = \nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubEnabled
              If (aSub(j)\nSubState >= #SCS_CUE_COUNTDOWN_TO_START) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
                aSub(j)\nTotalTimeOnGlobalPause + nTimeOnPause
              EndIf
              If aSub(j)\nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
                aSub(j)\qTimeToStartSub + nTimeOnPause
                debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\qTimeToStartSub=" + aSub(j)\qTimeToStartSub)
              EndIf
              If aSub(j)\bSubTypeAorP
                k = aSub(j)\nFirstPlayIndex
                While k >= 0
                  If aAud(k)\nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START
                    aAud(k)\qPLTimeTransStarted + nTimeOnPause
                  EndIf
                  k = aAud(k)\nNextPlayIndex
                Wend
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        CompilerEndIf
        If \nCueState = #SCS_CUE_COUNTDOWN_TO_START
          \qTimeToStartCue + nTimeOnPause
          debugMsg(sProcName, "\qTimeToStartCue=" + traceTime(\qTimeToStartCue))
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure resumeAll()
  PROCNAMEC()
  Protected i, j, k, nTimeOnGlobalPause, bResumeAudioNow, nMTCSubPtr
  
  If gnThreadNo > #SCS_THREAD_MAIN
    gqMainThreadRequest | #SCS_MTH_RESUME_ALL
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)

  If gbGlobalPause = #False
    ProcedureReturn
  EndIf

  setGlobalTimeNow()
  nTimeOnGlobalPause = gqTimeNow - gqGlobalPauseTimeStarted

  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubEnabled
        If (aSub(j)\nSubState >= #SCS_CUE_COUNTDOWN_TO_START) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
          aSub(j)\nTotalTimeOnGlobalPause + nTimeOnGlobalPause
        EndIf
        If aSub(j)\nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
          aSub(j)\qTimeToStartSub + nTimeOnGlobalPause
        EndIf
        If aSub(j)\bSubTypeAorP
          k = aSub(j)\nFirstPlayIndex
          While k >= 0
            If aAud(k)\nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START
              aAud(k)\qPLTimeTransStarted = aAud(k)\qPLTimeTransStarted + nTimeOnGlobalPause
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    If aCue(i)\nCueState = #SCS_CUE_COUNTDOWN_TO_START
      aCue(i)\qTimeToStartCue + nTimeOnGlobalPause
      debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\qTimeToStartCue=" + traceTime(aCue(i)\qTimeToStartCue))
    EndIf
  Next i

;   ; resume globally paused Aud's
;   For k = 1 To ArraySize(aAud())
;     If aAud(k)\bGloballyPaused
;       debugMsg(sProcName, "calling resumeAud(" + getAudLabel(k) + ")")
;       resumeAud(k)
;       aAud(k)\bGloballyPaused = #False
;     EndIf
;   Next k
  ; resume globally paused Sub's (types E, K, M and U), and globally paused Aud's
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubType=" + \sSubType + ", \bSubGloballyPaused=" + strB(\bSubGloballyPaused) + ", \bSubEnabled=" + strB(\bSubEnabled) + ", \bSubTypeHasAuds=" + strB(\bSubTypeHasAuds))
        If \bSubTypeF
          k = \nFirstAudIndex
          If k >= 0
            If aAud(k)\bGloballyPaused
              bResumeAudioNow = #True
;               If aSub(j)\bStartedInEditor = #False
;                 debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nAFLinkedToMTCSubPtr=" + getSubLabel(\nAFLinkedToMTCSubPtr))
;                 nMTCSubPtr = \nAFLinkedToMTCSubPtr
;                 If nMTCSubPtr >= 0
;                   bResumeAudioNow = #False
;                   debugMsg(sProcName, "aSub(" + getSubLabel(nMTCSubPtr) + ")\nSubState=" + decodeCueState(aSub(nMTCSubPtr)\nSubState))
;                   If aSub(nMTCSubPtr)\nSubState >= #SCS_CUE_FADING_IN And aSub(nMTCSubPtr)\nSubState <= #SCS_CUE_FADING_OUT And aSub(nMTCSubPtr)\nSubState <> #SCS_CUE_PAUSED And aSub(nMTCSubPtr)\nSubState <> #SCS_CUE_HIBERNATING
;                     debugMsg(sProcName, "calling MTC_playOrResumeMTCAndLinkedAud(" + getSubLabel(j) + ", #False, #True)")
;                     MTC_playOrResumeMTCAndLinkedAud(j, #False, #True)
;                   EndIf
;                 EndIf
;               EndIf
              If bResumeAudioNow
                debugMsg(sProcName, "calling resumeAud(" + getAudLabel(k) + ")")
                resumeAud(k)
              EndIf
              aAud(k)\bGloballyPaused = #False
            EndIf
          EndIf

        ElseIf \bSubTypeHasAuds
          k = \nFirstAudIndex
          While k >= 0
            If aAud(k)\bGloballyPaused
              debugMsg(sProcName, "calling resumeAud(" + getAudLabel(k) + ")")
              resumeAud(k)
              aAud(k)\bGloballyPaused = #False
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        
        If \bSubGloballyPaused And \bSubEnabled
          If \bSubTypeE Or \bSubTypeK Or \bSubTypeM Or \bSubTypeU
            debugMsg(sProcName, "calling resumeSub(" + getSubLabel(j) + ")")
            resumeSub(j)
            \bSubGloballyPaused = #False
            debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubGloballyPaused=" + strB(\bSubGloballyPaused))
          EndIf
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  If RAI_IsClientActive()
    If (grRAIOptions\nRAIApp = #SCS_RAI_APP_SCSREMOTE And grRAI\nClientConnection2) Or (grRAIOptions\nRAIApp = #SCS_RAI_APP_OSC And grRAI\nClientConnection1)
      debugMsg(sProcName, "calling sendRAIGlobalCommand(" + #DQUOTE$ + "resumeall" + #DQUOTE$ + ")")
      sendRAIGlobalCommand("resumeall")
    EndIf
  EndIf

  setToolBarCurrentImageIndex(#SCS_TBMB_PAUSE_RESUME, 0)
  scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuPauseAll, Lang("Menu", "mnuPauseAll"))
  
  gbGlobalPause = #False
  debugMsg(sProcName, "gbGlobalPause=" + strB(gbGlobalPause))
  
  setGoButton()
  
  If grM2T\bM2TCueListColoringApplied
    M2T_clearCueInds()
    colorCueListEntries()
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure updateRFL(sThisCueFile.s="")
  PROCNAMEC()
  Protected n, m
  Protected sPrefKey.s, sPrefString.s, sTmpString.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  ; debugMsg(sProcName, #SCS_START + ", gnRecentFileCount=" + gnRecentFileCount + ", sThisCueFile=" + #DQUOTE$ + sThisCueFile + #DQUOTE$)
  
  If gsCueFile = gsRecoveryFile
    ProcedureReturn
  EndIf

  ; Update Recent File List
  For n = gnRecentFileCount To 1 Step -1
    gsRecentFile(n) = gsRecentFile(n - 1)
  Next n

  If sThisCueFile
    gsRecentFile(0) = sThisCueFile
  Else
    gsRecentFile(0) = gsCueFile
  EndIf
  gnRecentFileCount + 1
  If gnRecentFileCount > #SCS_MAXRFL_SAVED
    gnRecentFileCount = #SCS_MAXRFL_SAVED
  EndIf
  
  m = 1
  For n = 1 To gnRecentFileCount
    If gsRecentFile(n) <> gsRecentFile(0)
      gsRecentFile(m) = gsRecentFile(n)
      m + 1
    EndIf
  Next n
  gnRecentFileCount = m
  If gnRecentFileCount > #SCS_MAXRFL_SAVED
    gnRecentFileCount = #SCS_MAXRFL_SAVED
  EndIf

  If gbMainFormLoaded
    If IsMenu(#WMN_mnuWindowMenu)
      FreeMenu(#WMN_mnuWindowMenu)
      ; re-build the menu to re-populate the 'Open' sub-menu
      debugMsg(sProcName, "calling WMN_buildWindowMenu()")
      WMN_buildWindowMenu()
    EndIf
  EndIf

  COND_OPEN_PREFS("RecentFiles")
  For n = 1 To #SCS_MAXRFL_SAVED
    sPrefKey = "File" + LTrim(Str(n))
    sPrefString = Trim(gsRecentFile(n-1))
    If (sPrefString) And (n <= gnRecentFileCount)
      ; debugMsg(sProcName, "calling WritePreferenceString(" + #DQUOTE$ + sPrefKey + #DQUOTE$ + ", " + #DQUOTE$ + sPrefString + #DQUOTE$ + ")")
      WritePreferenceString(sPrefKey, sPrefString)
    Else
      sTmpString = ReadPreferenceString(sPrefKey, "")
      ; debugMsg(sProcName, "ReadPreferenceString(" + #DQUOTE$ + sPrefKey + ", " + #DQUOTE$ + #DQUOTE$ + ") returned " + #DQUOTE$ + sTmpString + #DQUOTE$)
      If sTmpString
        ; debugMsg(sProcName, "calling RemovePreferenceKey(" + #DQUOTE$ + sPrefKey + #DQUOTE$ + ")")
        RemovePreferenceKey(sPrefKey)
        sTmpString = ReadPreferenceString(sPrefKey, "")
        ; debugMsg(sProcName, "ReadPreferenceString(" + #DQUOTE$ + sPrefKey + ", " + #DQUOTE$ + #DQUOTE$ + ") returned " + #DQUOTE$ + sTmpString + #DQUOTE$)
      EndIf
    EndIf
  Next n
  COND_CLOSE_PREFS()

  ; debugMsg(sProcName, #SCS_END + ", gnRecentFileCount=" + gnRecentFileCount)
  
EndProcedure

Procedure deleteFromRFL(pCueFile.s)
  PROCNAMEC()
  Protected n, m
  Protected sPrefKey.s, sPrefString.s, sTmpString.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  ; debugMsg(sProcName, #SCS_START + ", gnRecentFileCount=" + gnRecentFileCount + ", pCueFile=" + #DQUOTE$ + pCueFile + #DQUOTE$)
  
  For n = 0 To gnRecentFileCount-1
    If gsRecentFile(n) <> pCueFile
      gsRecentFile(m) = gsRecentFile(n)
      m + 1
    EndIf
  Next n
  gnRecentFileCount = m
  
  COND_OPEN_PREFS("RecentFiles")
  For n = 1 To #SCS_MAXRFL_SAVED
    sPrefKey = "File" + LTrim(Str(n))
    sPrefString = Trim(gsRecentFile(n-1))
    If (sPrefString) And (n <= gnRecentFileCount)
      ; debugMsg(sProcName, "calling WritePreferenceString(" + #DQUOTE$ + sPrefKey + #DQUOTE$ + ", " + #DQUOTE$ + sPrefString + #DQUOTE$ + ")")
      WritePreferenceString(sPrefKey, sPrefString)
    Else
      sTmpString = ReadPreferenceString(sPrefKey, "")
      ; debugMsg(sProcName, "ReadPreferenceString(" + #DQUOTE$ + sPrefKey + ", " + #DQUOTE$ + #DQUOTE$ + ") returned " + #DQUOTE$ + sTmpString + #DQUOTE$)
      If sTmpString
        ; debugMsg(sProcName, "calling RemovePreferenceKey(" + #DQUOTE$ + sPrefKey + #DQUOTE$ + ")")
        RemovePreferenceKey(sPrefKey)
        sTmpString = ReadPreferenceString(sPrefKey, "")
        ; debugMsg(sProcName, "ReadPreferenceString(" + #DQUOTE$ + sPrefKey + ", " + #DQUOTE$ + #DQUOTE$ + ") returned " + #DQUOTE$ + sTmpString + #DQUOTE$)
      EndIf
    EndIf
  Next n
  COND_CLOSE_PREFS()
  
  ; debugMsg(sProcName, #SCS_END + ", gnRecentFileCount=" + gnRecentFileCount)
  
EndProcedure

Procedure savePreferences()
  PROCNAMEC()
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected sGroup.s
  Protected nOperMode
  Protected sTmp.s, sResult.s
  Protected n, nScreenNo, nScreenVideoRenderer
  Protected sPrefKey.s, sPrefString.s
  Protected nDateLastUsed, nPurgeDate, sPrefGroupName.s
  
  debugMsg(sProcName, #SCS_START)
  
  COND_OPEN_PREFS("Version")  ; COND_OPEN_PREFS("Version")
  WritePreferenceString("Version", #SCS_FILE_VERSION)
  WritePreferenceInteger("Build", grProgVersion\nBuildDate)
  
  OPEN_PREF_GROUP("OperMode")  ; OPEN_PREF_GROUP("OperMode")
  WritePreferenceString("OperMode", decodeOperMode(gnOperMode))
  
  OPEN_PREF_GROUP("GeneralOptions")  ; OPEN_PREF_GROUP("GeneralOptions")
  With grGeneralOptions
    If gsTipControl
      WritePreferenceString("TipControl", gsTipControl)
    Else
      RemovePreferenceKey("TipControl")
    EndIf
    If gbSwapMonitors1and2 = #False
      sTmp = ReadPreferenceString("PrevSwapSetting", "")
      If sTmp
        RemovePreferenceKey("PrevSwapSetting")
      EndIf
    Else
      WritePreferenceInteger("PrevSwapSetting", gbSwapMonitors1and2)
    EndIf
    If \nFaderAssignments = 0
      RemovePreferenceKey("FaderAssignments")
    Else
      WritePreferenceString("FaderAssignments", decodeFaderAssignments(\nFaderAssignments))
    EndIf
    WritePreferenceString("DBIncrement", \sDBIncrement)
  EndWith
  
  ; OPEN_PREF_GROUP("OM_Design") etc
  For nOperMode = 0 To #SCS_OPERMODE_LAST
    Select nOperMode
      Case #SCS_OPERMODE_DESIGN
        sGroup = "OM_Design"
      Case #SCS_OPERMODE_REHEARSAL
        sGroup = "OM_Rehearsal"
      Case #SCS_OPERMODE_PERFORMANCE
        sGroup = "OM_Performance"
    EndSelect
    debugMsg(sProcName, "sGroup=" + sGroup)
    OPEN_PREF_GROUP(sGroup)
    With grOperModeOptions(nOperMode)
      WritePreferenceString("ColorScheme", \sSchemeName)
      WritePreferenceString("CtrlPanelPos", decodeCtrlPanelPos(\nCtrlPanelPos))
      WritePreferenceString("MainToolbarInfo", decodeMainToolBarInfo(\nMainToolBarInfo))
      WritePreferenceInteger("ShowSubCues", \bShowSubCues)
      WritePreferenceInteger("ShowHiddenAutoStartCues", \bShowHiddenAutoStartCues)
      WritePreferenceInteger("CueListFontSize", \nCueListFontSize)
      WritePreferenceInteger("HideCueList", \bHideCueList)
      WritePreferenceInteger("CuePanelVerticalSizing", \nCuePanelVerticalSizing)
      WritePreferenceInteger("ShowHotkeyList", \bShowHotkeyList)
      WritePreferenceInteger("ShowHotkeyCuesInPanels", \bShowHotkeyCuesInPanels)
      WritePreferenceString("VisMode", decodeVisMode(\nVisMode))
      WritePreferenceString("PeakMode", decodePeakMode(\nPeakMode))
      WritePreferenceString("VUBarWidth", decodeVUBarWidth(\nVUBarWidth))
      WritePreferenceString("MonitorSize2", decodeMonitorSize(\nMonitorSize)) ; changed keyword at 11.3.0 when default value changed
      ; WritePreferenceInteger("MaxMonitor", \nMaxMonitor)  ; added 11.6.0 ; Deleted 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
      WritePreferenceString("MTCDispLocn", decodeMTCDispLocn(\nMTCDispLocn))
      WritePreferenceString("TimerDispLocn", decodeTimerDispLocn(\nTimerDispLocn))
      WritePreferenceInteger("ShowSubCues", \bShowSubCues)
      WritePreferenceInteger("ShowMasterFader", \bShowMasterFader)
      WritePreferenceInteger("ShowNextManualCue", \bShowNextManualCue)
      WritePreferenceInteger("ShowTransportControls", \bShowTransportControls)
      WritePreferenceInteger("ShowFaderAndPanControls", \bShowFaderAndPanControls)
      WritePreferenceInteger("AllowDisplayTimeout", \bAllowDisplayTimeout)
      WritePreferenceInteger("ShowToolTips", \bShowToolTips)
      WritePreferenceInteger("ShowLvlCurvesPrim", \bShowLvlCurvesPrim)
      WritePreferenceInteger("ShowLvlCurvesOther", \bShowLvlCurvesOther)
      WritePreferenceInteger("ShowPanCurvesPrim", \bShowPanCurvesPrim)
      WritePreferenceInteger("ShowPanCurvesOther", \bShowPanCurvesOther)
      WritePreferenceInteger("ShowAudioGraph", \bShowAudioGraph)
      WritePreferenceInteger("ShowCueMarkers", \bShowCueMarkers)
      WriteOrRemovePreferenceInteger("RequestConfirmCueClick", \bRequestConfirmCueClick, grOperModeOptionDefs(nOperMode)\bRequestConfirmCueClick)
      WriteOrRemovePreferenceInteger("ShowMidiCueInNextManual", \bShowMidiCueInNextManual, grOperModeOptionDefs(nOperMode)\bShowMidiCueInNextManual)
      WriteOrRemovePreferenceInteger("ShowMidiCueInCuePanels", \bShowMidiCueInCuePanels, grOperModeOptionDefs(nOperMode)\bShowMidiCueInCuePanels)
      WriteOrRemovePreferenceInteger("LimitMovementOfMainWindowSplitterBar", \bLimitMovementOfMainWindowSplitterBar, grOperModeOptionDefs(nOperMode)\bLimitMovementOfMainWindowSplitterBar)
      If \bDisplayAllMidiIn
        WritePreferenceInteger("DisplayAllMidiIn", \bDisplayAllMidiIn)
      Else
        RemovePreferenceKey("DisplayAllMidiIn")
      EndIf
      If \nMidiInDisplayTimeout <> grOperModeOptionDefs(nOperMode)\nMidiInDisplayTimeout
        WritePreferenceInteger("MidiInDisplayTimeout", \nMidiInDisplayTimeout)
      Else
        RemovePreferenceKey("MidiInDisplayTimeout")
      EndIf
      ; save main screen grid layout
      ; deleted 6Jun2019 11.8.1.1an - now handled from WMN_callback_cues() because "If gbClosingDown = #False" below was preventing the changes being recorded, and I don't recall why "If gbClosingDown = #False" was there anyway
      ;       If nOperMode = gnOperMode
      ;         If gbClosingDown = #False
      ;           debugMsg(sProcName, "calling updateGridInfoFromPhysicalLayout(@grOperModeOptions(" + nOperMode + ")\rGrdCuesInfo)")
      ;           updateGridInfoFromPhysicalLayout(@grOperModeOptions(nOperMode)\rGrdCuesInfo)
      ;         EndIf
      ;       EndIf
      ; end deleted 6Jun2019 11.8.1.1an
      WritePreferenceString("MainGridColLayout2", \rGrdCuesInfo\sLayoutString)
    EndWith
  Next nOperMode
  
  OPEN_PREF_GROUP("Windows_" + gsMonitorKey) ; OPEN_PREF_GROUP("Windows_" + gsMonitorKey) so that these settings are unique to a specific set of connected monitors
  With grWMN
    ; splitter positions - design mode
    WriteOrRemovePreferenceInteger("CuelistMemoSplitterPosD", \nCuelistMemoSplitterPosD, -1)
    WriteOrRemovePreferenceInteger("MainMemoSplitterPosD", \nMainMemoSplitterPosD, -1)
    WriteOrRemovePreferenceInteger("NorthSouthSplitterPosD", \nNorthSouthSplitterPosD, -1)
    WriteOrRemovePreferenceInteger("PanelsHotkeysSplitterEndPosD", \nPanelsHotkeysSplitterEndPosD, -1)
    ; splitter positions - rehearsal mode
    WriteOrRemovePreferenceInteger("CuelistMemoSplitterPosR", \nCuelistMemoSplitterPosR, -1)
    WriteOrRemovePreferenceInteger("MainMemoSplitterPosR", \nMainMemoSplitterPosR, -1)
    WriteOrRemovePreferenceInteger("NorthSouthSplitterPosR", \nNorthSouthSplitterPosR, -1)
    WriteOrRemovePreferenceInteger("PanelsHotkeysSplitterEndPosR", \nPanelsHotkeysSplitterEndPosR, -1)
    ; splitter positions - performance mode
    WriteOrRemovePreferenceInteger("CuelistMemoSplitterPosP", \nCuelistMemoSplitterPosP, -1)
    WriteOrRemovePreferenceInteger("MainMemoSplitterPosP", \nMainMemoSplitterPosP, -1)
    WriteOrRemovePreferenceInteger("NorthSouthSplitterPosP", \nNorthSouthSplitterPosP, -1)
    WriteOrRemovePreferenceInteger("PanelsHotkeysSplitterEndPosP", \nPanelsHotkeysSplitterEndPosP, -1)
  EndWith
  With grEditorPrefs
    ; splitter positions - editor
    WriteOrRemovePreferenceInteger("SplitterPosEditV", \nSplitterPosEditV, -1)
    WriteOrRemovePreferenceInteger("SplitterPosEditH", \nSplitterPosEditH, -1)
  EndWith
  If gbFadersDisplayed
    WritePreferenceInteger("FadersDisplayed", 1)
  Else
    RemovePreferenceKey("FadersDisplayed")
  EndIf
  If gbDMXDisplayDisplayed
    WritePreferenceInteger("DMXDisplayDisplayed", 1)
  Else
    RemovePreferenceKey("DMXDisplayDisplayed")
  EndIf
  CompilerIf #c_blackmagic_card_support
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      With grVideoDriver
        For n = 0 To \nSplitScreenArrayMax
          If \aSplitScreenInfo[n]\nCurrentMonitorIndex >= 0
            ; screen video renderer
            sPrefKey = "ScreenVideoRenderer_" + \aSplitScreenInfo[n]\nDisplayNo
            ; debugMsg(sProcName, "grVideoDriver\aSplitScreenInfo[" + n + "]\nCurrentMonitorIndex=" + \aSplitScreenInfo[n]\nCurrentMonitorIndex + ", sPrefKey=" + sPrefKey)
            nScreenVideoRenderer = getVideoRendererForScreen(\aSplitScreenInfo[n]\nDisplayNo)
            If nScreenVideoRenderer <> #SCS_VR_AUTOSELECT
              debugMsg(sProcName, "WritePreferenceString('" + sPrefKey + ", " + decodeVideoRenderer(nScreenVideoRenderer) + "')")
              WritePreferenceString(sPrefKey, decodeVideoRenderer(nScreenVideoRenderer))
            Else
              ; debugMsg(sProcName, "RemovePreferenceKey('" + sPrefKey + "')")
              RemovePreferenceKey(sPrefKey)
            EndIf
          EndIf
        Next n
      EndWith
    EndIf
  CompilerEndIf
  ; Added 27Aug2024 11.10.3bn
  ; Remove "Windows_..." preference groups that haven't been used for more than 90 days
  nPurgeDate = (Date() / (3600 * 24)) - 90
  ExaminePreferenceGroups()
  While NextPreferenceGroup() ; While group exists
    sPrefGroupName = PreferenceGroupName()
    If Left(sPrefGroupName, 8) = "Windows_"
      If sPrefGroupName <> "Windows_" + gsMonitorKey
        If PreferenceGroup(sPrefGroupName)
          nDateLastUsed = 0
          ExaminePreferenceKeys()
          While NextPreferenceKey()
            If PreferenceKeyName() = "DateLastUsed"
              nDateLastUsed = Val(PreferenceKeyValue())
              Break
            EndIf
          Wend
          ; debugMsg0(sProcName, "Preference group '" + sPrefGroupName + "' DateLastUsed=" + FormatDate("%yyyy-%mm-%dd", (nDateLastUsed * 3600 * 24)))
          If nDateLastUsed < nPurgeDate
            debugMsg0(sProcName, "Removing preference group '" + sPrefGroupName + "', DateLastUsed=" + FormatDate("%yyyy-%mm-%dd", (nDateLastUsed * 3600 * 24)))
            RemovePreferenceGroup(sPrefGroupName)
          EndIf
        EndIf
      EndIf
    EndIf
  Wend
  ; End added 27Aug2024 11.10.3bn
  
  ; Added by Dee 25/03/2025 to enable saving of user column headers "Page" and "When required"
  OPEN_PREF_GROUP("UserColumns")
  sResult = ""
  
  If IsGadget(WOP\txtUserColumn1)
    sResult = GetGadgetText(WOP\txtUserColumn1)
    
    If Len(sResult)
      Lang("common", "Page", "", sResult)
    EndIf
    
    WritePreferenceString("UserColumn1", sResult)
  EndIf
  
  sResult = ""
  
  If IsGadget(WOP\txtUserColumn2)
    sResult = GetGadgetText(WOP\txtUserColumn2)
    
    If Len(sResult)
      Lang("common", "WhenReqd", "", sResult)
    EndIf
    
    WritePreferenceString("UserColumn2", sResult)
  EndIf
    
  OPEN_PREF_GROUP("Editing")  ; OPEN_PREF_GROUP("Editing")
  With grEditingOptions
    If \sAudioEditor
      WritePreferenceString("AudioEditor", \sAudioEditor)
    EndIf
    If \sImageEditor
      WritePreferenceString("ImageEditor", \sImageEditor)
    EndIf
    If \sVideoEditor
      WritePreferenceString("VideoEditor", \sVideoEditor)
    EndIf
  EndWith
  
  OPEN_PREF_GROUP("Editor")  ; OPEN_PREF_GROUP("Editor")
  With grEditorPrefs
    WritePreferenceString("FavItems", \sFavItems)
    WritePreferenceInteger("SplitterPosEditV", \nSplitterPosEditV) ; vertical splitter
    WritePreferenceInteger("SplitterPosEditH", \nSplitterPosEditH) ; horizontal splitter
    WritePreferenceInteger("ShowFileFoldersInEditor", \bShowFileFoldersInEditor)
    WritePreferenceString("GraphDisplayMode", decodeGraphDisplayMode(\nGraphDisplayMode))
    WritePreferenceInteger("EditShowLvlCurvesSel", \bEditShowLvlCurvesSel)
    WritePreferenceInteger("EditShowPanCurvesSel", \bEditShowPanCurvesSel)
    WritePreferenceInteger("EditShowLvlCurvesOther", \bEditShowLvlCurvesOther)
    WritePreferenceInteger("EditShowPanCurvesOther", \bEditShowPanCurvesOther)
    WritePreferenceInteger("AutoScroll", \bAutoScroll)
  EndWith
  
  With grEditingOptions
    WritePreferenceInteger("FileScanMaxLength", \nFileScanMaxLengthAudio)
    WritePreferenceInteger("FileScanMaxLengthV", \nFileScanMaxLengthVideo)
    If \bSaveAlwaysOn
      WritePreferenceInteger("SaveAlwaysOn", \bSaveAlwaysOn)
    Else
      RemovePreferenceKey("SaveAlwaysOn")
    EndIf
    If \bIgnoreTitleTags
      WritePreferenceInteger("IgnoreTitleTags", \bIgnoreTitleTags)
    Else
      RemovePreferenceKey("IgnoreTitleTags")
    EndIf
    
    ; Code modified 23Mar2030 11.8.2.3af so that "AudioFileSelector" is ALWAYS saved.
    ; This change is because the default was changed in 11.8.2 but unfortunately code in this part of the program was not altered
    ; which meant that if a user chose the SCS audio file selector then that setting was not saved.
    WritePreferenceString("AudioFileSelector", decodeFileSelector(\nAudioFileSelector))
    
    ; CS - Adding Option for Include All Devices for Level Points
    If \bIncludeAllLevelPointDevices
      WritePreferenceInteger("IncludeAllLevelPointDevices", \bIncludeAllLevelPointDevices)
    Else
      RemovePreferenceKey("IncludeAllLevelPointDevices")
    EndIf
    
    If \bCheckMainLostFocusWhenEditorOpen
      WritePreferenceInteger("CheckMainLostFocusWhenEditorOpen", \bCheckMainLostFocusWhenEditorOpen)
    Else
      RemovePreferenceKey("CheckMainLostFocusWhenEditorOpen")
    EndIf
    
    If \bActivateOCMAutoStarts
      WritePreferenceInteger("ActivateOCMAutoStarts", \bActivateOCMAutoStarts)
    Else
      RemovePreferenceKey("ActivateOCMAutoStarts")
    EndIf
    
    If \nEditorCueListFontSize > 0 And \nEditorCueListFontSize <> 109
      ; 109 = 'font size 9 normal', which is the default, as from SCS 11.9
      ; See also WOP_Form_Show() and WED_setEditorCueListFontSize()
      WritePreferenceInteger("EditorCueListFontSize", \nEditorCueListFontSize)
    Else
      RemovePreferenceKey("EditorCueListFontSize")
    EndIf
    
  EndWith
  
  OPEN_PREF_GROUP("EditModal")
  With grWEM
    WriteOrRemovePreferenceString("CueMarkersUsageDim", \sCntCueMarkersUsageDim, "")
  EndWith
  
  OPEN_PREF_GROUP("GeneralOptions")  ; OPEN_PREF_GROUP("GeneralOptions")
  With grGeneralOptions
    If Len(\sInitDir) = 0
      RemovePreferenceKey("InitDir")
    Else
      WritePreferenceString("InitDir", \sInitDir)
    EndIf
    
    WritePreferenceString("Language", \sLangCode)
    If #cTranslator
      WritePreferenceInteger("DisplayLangIds", \bDisplayLangIds)
    EndIf
    If \sDfltFontName
      If (\sDfltFontName = gsSCSDfltFontName) And (\nDfltFontSize = gnSCSDfltFontSize)
        RemovePreferenceKey("DfltFontName")
        RemovePreferenceKey("DfltFontSize")
      Else
        WritePreferenceString("DfltFontName", \sDfltFontName)
        WritePreferenceInteger("DfltFontSize", \nDfltFontSize)
      EndIf
    Else
      RemovePreferenceKey("DfltFontName")
      RemovePreferenceKey("DfltFontSize")
    EndIf
    
    ; "VideoDriver" obsolete - see "VideoLibrary" in new group "VideoDriver"
    ; WritePreferenceString("VideoDriver", \sVideoDriver)
    sTmp = ReadPreferenceString("VideoDriver", "")
    If sTmp
      RemovePreferenceKey("VideoDriver")
    EndIf
    
    WriteOrRemovePreferenceInteger("SwapMonitors1and2", \bSwapMonitors1and2, #False)
    WriteOrRemovePreferenceInteger("SwapMonitor", \nSwapMonitor, 2)
    WritePreferenceInteger("DisableRightClickAsGo", \bDisableRightClickAsGo)
    WritePreferenceInteger("CtrlOverridesExclCue", \bCtrlOverridesExclCue)
    WritePreferenceInteger("HotkeysOverrideExclCue", \bHotkeysOverrideExclCue)
    WritePreferenceInteger("DoubleClickTime", \nDoubleClickTime)
    WritePreferenceInteger("FadeAllTime", \nFadeAllTime)
    WritePreferenceInteger("ApplyTimeout", \bApplyTimeoutToOtherGos)
    WritePreferenceInteger("MaxPreOpenFiles", \nMaxPreOpenAudioFiles)
    WritePreferenceInteger("MaxPreOpenVideoImageFiles", \nMaxPreOpenVideoImageFiles)
    WritePreferenceString("TimeFormat", \sTimeFormat)
    WriteOrRemovePreferenceInteger("EnableAutoCheckForUpdate", \bEnableAutoCheckForUpdate, #True) ; nb default is 'check for update', so only store setting if the user has turned off 'check for update'
    WriteOrRemovePreferenceInteger("DaysBetweenChecks", \nDaysBetweenChecks, #SCS_MISC_DFLT_DAYS_BETWEEN_CHECKS)
    ; remove any obsolete keys
    RemovePreferenceKey("MaxPreLoadFiles")  ; obsolete (replaced by MaxPreOpenFiles)
    RemovePreferenceKey("MaxPreOpenVideos") ; obsolete (replaced by MaxPreOpenVideoImageFiles)
    RemovePreferenceKey("MaxPreOpenImages") ; obsolete (replaced by MaxPreOpenVideoImageFiles)
  EndWith
  
  OPEN_PREF_GROUP("DTMA")  ; OPEN_PREF_GROUP("DTMA")
  With grDontTellMeAgain
    WriteOrRemovePreferenceInteger("VideoCodecs", \bVideoCodecs, #False)
  EndWith
  
  OPEN_PREF_GROUP("Memory")  ; OPEN_PREF_GROUP("Memory")
  With grMemoryPrefs
    WritePreferenceString("DMXDisplayPref", decodeDMXPref(\nDMXDisplayPref))
    WritePreferenceString("DMXGridType", decodeDMXGridType(\nDMXGridType))
    CompilerIf #c_dmx_display_drop_gridline_and_backcolor_choices = #False
      If \nDMXBackColor >= 0
        WritePreferenceInteger("DMXBackColor", \nDMXBackColor)
      Else
        RemovePreferenceKey("DMXBackColor")
      EndIf
      WritePreferenceInteger("DMXShowGridLines", \bDMXShowGridLines)
    CompilerEndIf
    WritePreferenceInteger("DMXFixtureDisplayData", \nDMXFixtureDisplayData)
    ; do NOT save (or remove) anything here from the 'don't ask me again today' preferences as these items are saved independently - see setDontAskToday() and the calls to that procedure
  EndWith
  
  OPEN_PREF_GROUP("RAIOptions")  ; OPEN_PREF_GROUP("RAIOptions")
  With grRAIOptions
    WritePreferenceInteger("RAIEnabled", \bRAIEnabled)
    WritePreferenceString("RAIApp", decodeRAIApp(\nRAIApp))
    If \nRAIOSCVersion >= 0
      ; Save OSC version even if the currently-selected app is not OSC, so that if the user previously selected OSC and now re-selects OSC then the previously-selected OSC version will be reinstated
      WritePreferenceString("RAIOSCVersion", decodeOSCVersion(\nRAIOSCVersion))
    Else
      RemovePreferenceKey("RAIOSCVersion")
    EndIf
    WritePreferenceString("NetworkProtocol", decodeNetworkProtocol(\nNetworkProtocol))
    If \sLocalIPAddr
      WritePreferenceString("LocalIPAddr", \sLocalIPAddr)
    Else
      RemovePreferenceKey("LocalIPAddr")
    EndIf
    WritePreferenceInteger("LocalPort", \nLocalPort)
  EndWith
  
  If grLicInfo\bFMAvailable
    With grFMOptions
      If (\nFunctionalMode = #SCS_FM_STAND_ALONE) And (Len(\sFMServerName) = 0) And (\bBackupIgnoreCSMIDI = #False) And (\bBackupIgnoreCSNetwork = #False) And (\bBackupIgnoreLightingDMX = #False) And (\bBackupIgnoreCCDevs = #False)
        ; none of the functional mode settings are required, so remove the group if it exists
        RemovePreferenceGroup("FMOptions")
      Else
        OPEN_PREF_GROUP("FMOptions")  ; OPEN_PREF_GROUP("FMOptions")
        WritePreferenceString("Mode", decodeFunctionalMode(\nFunctionalMode))
        If \sFMServerName
          WritePreferenceString("FMServerName", \sFMServerName)
        EndIf
        If \sFMLocalIPAddr
          WritePreferenceString("FMLocalIPAddr", \sFMLocalIPAddr)
        Else 
          RemovePreferenceKey("FMLocalIPAddr")
        EndIf
        If \bBackupIgnoreCSMIDI
          WritePreferenceInteger("B_IgnoreCSMIDI", \bBackupIgnoreCSMIDI)
        Else
          RemovePreferenceKey("B_IgnoreCSMIDI")
        EndIf
        If \bBackupIgnoreCSNetwork
          WritePreferenceInteger("B_IgnoreCSNetwork", \bBackupIgnoreCSNetwork)
        Else
          RemovePreferenceKey("B_IgnoreCSNetwork")
        EndIf
        If \bBackupIgnoreLightingDMX
          WritePreferenceInteger("B_IgnoreLightingDMX", \bBackupIgnoreLightingDMX)
        Else
          RemovePreferenceKey("B_IgnoreLightingDMX")
        EndIf
        If \bBackupIgnoreCCDevs
          WritePreferenceInteger("B_IgnoreCCDevs", \bBackupIgnoreCCDevs)
        Else
          RemovePreferenceKey("B_IgnoreCCDevs")
        EndIf
      EndIf
    EndWith
  EndIf
  
  OPEN_PREF_GROUP("AudioDriverBASS")  ; OPEN_PREF_GROUP("AudioDriverBASS")
  With grDriverSettings
    WritePreferenceInteger("NoFloat", \bNoFloatingPoint)
    WritePreferenceInteger("NoWASAPI", \bNoWASAPI)
    WritePreferenceInteger("Swap34with56", \bSwap34with56)
    WritePreferenceInteger("UseBASSMixer", \bUseBASSMixer)
    CompilerIf #cEnableASIOBufLen
      WritePreferenceInteger("ASIOBufLen", \nAsioBufLen)
    CompilerEndIf
    CompilerIf #cEnableFileBufLen
      WritePreferenceInteger("FileBufLen", \nFileBufLen)
    CompilerEndIf
    
    WritePreferenceString("PlaybackBufOption", \sPlaybackBufOption)
    If \sPlaybackBufOption = "User"
      WritePreferenceInteger("PlaybackBufLength", \nPlaybackBufLength)
    Else
      RemovePreferenceKey("PlaybackBufLength")
    EndIf
    
    WritePreferenceString("UpdatePeriodOption", \sUpdatePeriodOption)
    If \sUpdatePeriodOption = "User"
      WritePreferenceInteger("UpdatePeriodLength", \nUpdatePeriodLength)
    Else
      RemovePreferenceKey("UpdatePeriodLength")
    EndIf
    
    WritePreferenceInteger("SampleRate", \nDSSampleRate)
    WritePreferenceInteger("LinkSyncPoint", \nLinkSyncPoint)
    
  EndWith
  
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    OPEN_PREF_GROUP("VideoDriver")  ; OPEN_PREF_GROUP("VideoDriver")
    With grVideoDriver
      ; save different video playback library preferences for 64-bit and 32-bit as xVideo is only available in 32-bit
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        WritePreferenceString("VideoLibrary64", decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary))
      CompilerElse
        WritePreferenceString("VideoLibrary32", decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary))
      CompilerEndIf
      Select grVideoDriver\nVideoPlaybackLibrary
        Case #SCS_VPL_TVG
          WritePreferenceString("TVGVideoRenderer", decodeVideoRenderer(\nTVGVideoRenderer, #SCS_VPL_TVG))
          WritePreferenceInteger("TVGUse2DDrawingForImages", \bTVGUse2DDrawingForImages)
          If \nTVGPlayerHwAccel = #tvc_hw_None
            RemovePreferenceKey("TVGPlayerHwAccel")
          Else
            WritePreferenceString("TVGPlayerHwAccel", decodeTVGPlayerHwAccel(\nTVGPlayerHwAccel)) ; Added 18Apr2020 11.8.3aa
          EndIf
          If \bTVGDisplayVUMeters = #False
            RemovePreferenceKey("TVGDisplayVUMeters")
          Else
            WritePreferenceInteger("TVGDisplayVUMeters", \bTVGDisplayVUMeters)
          EndIf
      EndSelect
      
      For n = 0 To \nSplitScreenArrayMax
        If \aSplitScreenInfo[n]\nCurrentMonitorIndex >= 0
          ; a real screen, which means the info was changeable in fmOptions
          sPrefKey = "SplitScreenCount_" + \aSplitScreenInfo[n]\nDisplayNo + ":" + \aSplitScreenInfo[n]\sRealScreenSize
          debugMsg(sProcName, "grVideoDriver\aSplitScreenInfo[" + n + "]\nCurrentMonitorIndex=" + \aSplitScreenInfo[n]\nCurrentMonitorIndex + ", sPrefKey=" + sPrefKey + ", \nSplitScreenCount=" + \aSplitScreenInfo[n]\nSplitScreenCount)
          If \aSplitScreenInfo[n]\nSplitScreenCount > 1
            debugMsg(sProcName, "WritePreferenceInteger('" + sPrefKey + ", " + \aSplitScreenInfo[n]\nSplitScreenCount + "')")
            WritePreferenceInteger(sPrefKey, \aSplitScreenInfo[n]\nSplitScreenCount)
          Else
            RemovePreferenceKey(sPrefKey)
          EndIf
        EndIf
      Next n
      
      WritePreferenceInteger("DisableVideoWarningMessage", \bDisableVideoWarningMessage)
    EndWith
    
  EndIf
  
  If grLicInfo\bSMSAvailable
    OPEN_PREF_GROUP("AudioDriverSM-S")  ; OPEN_PREF_GROUP("AudioDriverSM-S")
    With grDriverSettings
      CompilerIf #cSMSOnThisMachineOnly = #False
        WritePreferenceInteger("SMSOnThisMachine", \bSMSOnThisMachine)
        WritePreferenceString("SMSHost", \sSMSHost)
        WritePreferenceString("AudioFilesRootFolder", \sAudioFilesRootFolder)
      CompilerEndIf
      WritePreferenceInteger("MinPChansNonHK", \nMinPChansNonHK)
    EndWith
  EndIf
  
  OPEN_PREF_GROUP("Shortcuts")  ; OPEN_PREF_GROUP("Shortcuts")
  For n = 0 To ArraySize(gaShortcutsMain())
    With gaShortcutsMain(n)
      If \sFunctionPrefKey
        If \sShortcutStr = \sDefaultShortcutStr
          RemovePreferenceKey(\sFunctionPrefKey)
        Else
          WritePreferenceString(\sFunctionPrefKey, \sShortcutStr)
        EndIf
      EndIf
    EndWith
  Next n
  
  OPEN_PREF_GROUP("ShortcutsEditor")  ; OPEN_PREF_GROUP("ShortcutsEditor")
  For n = 0 To ArraySize(gaShortcutsEditor())
    With gaShortcutsEditor(n)
      If \sFunctionPrefKey
        If \sShortcutStr = \sDefaultShortcutStr
          RemovePreferenceKey(\sFunctionPrefKey)
        Else
          WritePreferenceString(\sFunctionPrefKey, \sShortcutStr)
        EndIf
      EndIf
    EndWith
  Next n
  
  ; always save favorite file list as the preference group may have been destroyed by a factory reset (which deletes the whole file)
  savePreferencesForFavFiles()
  
;   ; OPEN_PREF_GROUP("Windows")  ; OPEN_PREF_GROUP("Windows")
;   OPEN_PREF_GROUP("Windows_" + gsMonitorKey)  ; OPEN_PREF_GROUP("Windows_...") so that these settings are unique to a specific set of connected monitors
;   If gbFadersDisplayed
;     debugMsg(sProcName, "calling WritePreferenceInteger('FadersDisplayed', 1)")
;     WritePreferenceInteger("FadersDisplayed", 1)
;   Else
;     debugMsg(sProcName, "calling RemovePreferenceKey('FadersDisplayed')")
;     RemovePreferenceKey("FadersDisplayed")
;   EndIf
;   
  OPEN_PREF_GROUP("LoadProd")   ; OPEN_PREF_GROUP("LoadProd")
  With grLoadProdPrefs
    If \bShowAtStart
      RemovePreferenceKey("ShowAtStart")
    Else
      WritePreferenceInteger("ShowAtStart", 0)
    EndIf
    If \nBlankCount = 0
      RemovePreferenceKey("BlankCount")
    Else
      WritePreferenceInteger("BlankCount", \nBlankCount)
    EndIf
    WritePreferenceString("AudioDriver", decodeDriver(\nAudioDriver))
    WritePreferenceString("AudPrimaryDev", \sAudPrimaryDev)
    WritePreferenceString("DevMapName", \sDevMapName)
  EndWith
  
  OPEN_PREF_GROUP("FileOpener")
  With grWFO
    WritePreferenceString("ExpListColLayout", \rExpListInfo\sLayoutString)
    WritePreferenceInteger("SplitterPosWFOV", \nSplitterPos)
  EndWith
  
  ; Added 3Dec2022 11.9.7ar
  OPEN_PREF_GROUP("Misc")
  With grMisc
    ; debugMsg0(sProcName, "grMisc\bClockDisplayed=" + strB(\bClockDisplayed))
    If \bClockDisplayed
      WritePreferenceInteger("ClockDisplayed", \bClockDisplayed)
    Else
      RemovePreferenceKey("ClockDisplayed")
    EndIf
  EndWith
  ; End added 3Dec2022 11.9.7ar
  
  COND_CLOSE_PREFS()
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure savePreferencesForFavFiles()
  PROCNAMEC()
  Protected n
  Protected sRegFile.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  debugMsg(sProcName, #SCS_START)
  
  COND_OPEN_PREFS("FavoriteFiles")  ; COND_OPEN_PREFS("FavoriteFiles")
  
  For n = 0 To #SCS_MAX_FAV_FILE
    With gaFavoriteFiles(n)
      sRegFile = "File" + Right("0" + Trim(Str(n+1)), 2)
      If Len(Trim(\sFileName)) = 0
        RemovePreferenceKey(sRegFile)
      Else
        WritePreferenceString(sRegFile, Trim(\sFileName))
      EndIf
    EndWith
  Next n
  
  COND_CLOSE_PREFS()
  
EndProcedure

Procedure updateGrid(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nRowNo
  Protected sCountDownTimeLeft.s

  If (gbClosingDown) Or (gbMainFormLoaded = #False)
    ProcedureReturn
  EndIf

  If gnThreadNo > #SCS_THREAD_MAIN
    aCue(pCuePtr)\bUpdateGrid = #True
    gqMainThreadRequest | #SCS_MTH_UPDATE_ALL_GRID
    ProcedureReturn
  EndIf
  
  aCue(pCuePtr)\bUpdateGrid = #False
  nRowNo = aCue(pCuePtr)\nGrdCuesRowNo
  ; debugMsg(sProcName, "nRow=" + nRowNo)
  
  If (nRowNo < 0) Or (nRowNo >= CountGadgetItems(WMN\grdCues))
    ; row is hidden if nGrdCuesRowNo = -1 (may be a disabled cue)
    ProcedureReturn
  EndIf

  If pCuePtr < gnCueEnd
    With aCue(pCuePtr)
      If \nCueState = #SCS_CUE_COUNTDOWN_TO_START
        sCountDownTimeLeft = timeToString(\nCueCountDownTimeLeft, \nAutoActTime)
        WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CS, sCountDownTimeLeft)
      Else
        WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_CS, getCueStateForGrid(pCuePtr))
        colorLine(pCuePtr)
      EndIf
    EndWith
  EndIf

  If (gnHighlightedCue >= 0) And (gnHighlightedCue <> gnPrevHighlightedCue)
    debugMsg(sProcName, "calling highlightLine(" + gnHighlightedCue + ")")
    highlightLine(gnHighlightedCue)
    setNavigateButtons()
  EndIf

  ; debugMsg(sProcName, SCS_END)
  
EndProcedure

Procedure updateAllGrid()
  PROCNAMEC()
  Protected i
  
  For i = 1 To gnLastCue
    If aCue(i)\bUpdateGrid
      updateGrid(i)
    EndIf
  Next i
  
EndProcedure

Procedure updateAllGridFileInfo()
  PROCNAMEC()
  Protected i, nSubPtr
  Protected sFileName.s
  Protected nRowNo
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    nRowNo = aCue(i)\nGrdCuesRowNo
    If (nRowNo < 0) Or (nRowNo >= CountGadgetItems(WMN\grdCues))
      ; row is hidden if nGrdCuesRowNo = -1 (may be a disabled cue)
      ProcedureReturn
    EndIf
    If i < gnCueEnd
      nSubPtr = aCue(i)\nFirstSubIndex
      If nSubPtr >= 0
        sFileName = getSubFileNameForGrid(nSubPtr)
        WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_FN, sFileName)
      EndIf
    EndIf
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getPanelIndexForAud(pAudPtr)
  PROCNAMEC()
  Protected nDisplayPanel, n

  nDisplayPanel = -1
  For n = 0 To ArraySize(gaDispPanel())
    If gaDispPanel(n)\nDPAudPtr = pAudPtr
      nDisplayPanel = n
      Break
    EndIf
  Next n
  ProcedureReturn nDisplayPanel

EndProcedure

Procedure clearSaveSettings()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  gnSaveSettingsCount = 0
  debugMsg(sProcName, "gnSaveSettingsCount=" + gnSaveSettingsCount) 
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resetSessionOptions(bInDevChgs=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", bInDevChgs=" + strB(bInDevChgs))
  
  setMidiEnabled(bInDevChgs)
  setRS232Enabled(bInDevChgs)
  setNetworkEnabled(bInDevChgs)
  debugMsg(sProcName, "calling setDMXEnabled(" + strB(bInDevChgs) + ")")
  setDMXEnabled(bInDevChgs)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addToSaveSettings(pSubPtr)
  ; PROCNAMECS(pSubPtr)
  Protected n, nSSIndex, d1, d2, j, k

  ; debugMsg(sProcName, #SCS_START)
  
  nSSIndex = -1
  For n = 0 To gnSaveSettingsCount - 1
    If gaSaveSettings(n)\nSSSubPtr = pSubPtr
      nSSIndex = n
      Break
    EndIf
  Next n
  If nSSIndex = -1
    ; this sub-cue not currently in the table
    If gnSaveSettingsCount > ArraySize(gaSaveSettings())
      ; table full - roll off oldest entry
      For n = 1 To gnSaveSettingsCount
        gaSaveSettings(n - 1) = gaSaveSettings(n)
      Next n
    Else
      gnSaveSettingsCount + 1
    EndIf
    nSSIndex = gnSaveSettingsCount - 1
  EndIf
  ; debugMsg(sProcName, "nSSIndex=" + nSSIndex)
  If nSSIndex >= 0
    ; should be #True
    With gaSaveSettings(nSSIndex)
      \nSSSubPtr = pSubPtr
      d2 = -1 ; device index for gaSaveSettings(nSSIndex), subsequently saved to \nSSMaxDev
      j = -1
      If aSub(pSubPtr)\bSubTypeF
        j = pSubPtr
      ElseIf aSub(pSubPtr)\bSubTypeL
        j = aSub(pSubPtr)\nLCSubPtr
      EndIf
      If j >= 0
        k = aSub(j)\nFirstAudIndex
        ; debugMsg(sProcName, "j=" + getSubLabel(j) + ", k=" + getAudLabel(k))
        If k >= 0
          For d1 = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
            If aAud(k)\sLogicalDev[d1]
              d2 + 1
              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fCueVolNow[" + d1 + "]=" + traceLevel(aAud(k)\fCueVolNow[d1]))
              \nSSDevIndex[d2] = d1
              \fSSBVLevel[d2] = aAud(k)\fCueVolNow[d1]
              \fSSPan[d2] = aAud(k)\fCuePanNow[d1]
              ; debugMsg(sProcName, "gaSaveSettings(" + nSSIndex + ")\nSSDevIndex[" + d2 + "]=" + \nSSDevIndex[d2] + ", \fSSBVLevel[" + d2 + "]=" + traceLevel(\fSSBVLevel[d2]))
            EndIf
          Next d1
        EndIf
      EndIf
      \nSSMaxDev = d2
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getSaveSettingsDevIndexForLogicalDevIndex(nSSIndex, nLogicalDevIndex)
  Protected d, nSSDevIndex
  
  nSSDevIndex = -1
  With gaSaveSettings(nSSIndex)
    For d = 0 To \nSSMaxDev
      If \nSSDevIndex[d] = nLogicalDevIndex
        nSSDevIndex = d
        Break
      EndIf
    Next d
  EndWith
  ProcedureReturn nSSDevIndex
  
EndProcedure

Procedure removeFromSaveSettings(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n, nCount
  
  debugMsg(sProcName, #SCS_START)

  nCount = 0
  For n = 1 To gnSaveSettingsCount
    If gaSaveSettings(n-1)\nSSSubPtr <> pSubPtr
      nCount + 1
      gaSaveSettings(nCount-1) = gaSaveSettings(n-1)
    EndIf
  Next n
  gnSaveSettingsCount = nCount
  debugMsg(sProcName, "gnSaveSettingsCount=" + gnSaveSettingsCount) 
EndProcedure

Procedure removeFromSaveSettingsIfReqd(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n, nCount
  Protected k, d
  Protected bRemove
  
  debugMsg(sProcName, #SCS_START)
  
  bRemove = #True
  If pSubPtr >= 0
    If aSub(pSubPtr)\bSubTypeHasAuds
      k = aSub(pSubPtr)\nFirstAudIndex
      While k >= 0
        With aAud(k)
          For d = \nFirstDev To \nLastDev
            If \bCueVolManual[d] Or \bCuePanManual[d]
              debugMsg(sProcName, "Leave in SaveSettings because aAud(" + getAudLabel(k) + ")\bCueVolManual[" + d + "]=" + strB(\bCueVolManual[d]) + 
                                  ", \bCuePanManual[" + d + "]=" + strB(\bCuePanManual[d]))
              bRemove = #False
              Break ; Break d
            EndIf
          Next d
          If bRemove = #False
            Break ; Break k
          EndIf
        EndWith
        k = aAud(k)\nNextAudIndex
      Wend
    EndIf
    If bRemove
      nCount = 0
      For n = 1 To gnSaveSettingsCount
        If gaSaveSettings(n-1)\nSSSubPtr <> pSubPtr
          nCount + 1
          gaSaveSettings(nCount-1) = gaSaveSettings(n-1)
        EndIf
      Next n
      gnSaveSettingsCount = nCount
      debugMsg(sProcName, "gnSaveSettingsCount=" + gnSaveSettingsCount) 
    EndIf
  EndIf
  
EndProcedure

Procedure buildSaveSettingsMenu()
  PROCNAMEC()
  ; debugMsg(sProcName, #SCS_START)
  
  If gbEditorAndOptionsLocked = #False
    WMN_buildPopupMenu_SaveSettings()
  EndIf

EndProcedure

Procedure inSaveSettings(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n, bFound
  
  For n = 1 To gnSaveSettingsCount
    If gaSaveSettings(n-1)\nSSSubPtr = pSubPtr
      bFound = #True
      Break
    EndIf
  Next n
  ProcedureReturn bFound
EndProcedure

Procedure displayReasonsForSave()
  PROCNAMEC()
  Protected sMsg.s

  sMsg = listReasonsForSave()
  
  debugMsg(sProcName, ReplaceString(sMsg, Chr(10), " "))
  scsMessageRequester(Lang("Main", "SaveCueFile"), sMsg, #MB_ICONINFORMATION)

EndProcedure

Procedure countReasonsForSave(bIgnoreUnsavedEditorGraphs=#False, bIgnoreUnsavedPlaylistOrderInfo=#False)
  PROCNAMEC()
  Protected nCount
  
  If gbUnsavedRecovery
    nCount + 1
  EndIf
  
  If gbAudioFileOrPathChanged
    nCount + 1
  EndIf
  
  If gbSCSVersionChanged
    nCount + 1
  EndIf
  
  If (gnUnsavedEditorGraphs > 0) And (bIgnoreUnsavedEditorGraphs = #False)
    nCount + 1
  EndIf
  
  If gbUnsavedVideoImageData
    nCount + 1
  EndIf
  
  If (gbUnsavedPlaylistOrderInfo) And (bIgnoreUnsavedPlaylistOrderInfo = #False)
    nCount + 1
  EndIf
  
  If gbImportedCues
    nCount + 1
  EndIf
  
  If grCtrlSetup\bDataChanged
    nCount + 1
  EndIf
  
  If WCN\bEQChanged
    nCount + 1
  EndIf
  
  If gbNewDevMapFileCreated
    nCount + 1
  EndIf
  
  If gbNewCueFile
    nCount + 1
  EndIf
  
  If grWVP\bReadyToSaveToCueFile
    nCount + 1
  EndIf
  
  If changedSinceLastSave()
    nCount + 1
  EndIf
  
  If grProd\nMidiFreeConvertedToNrpn > 0
    nCount + 1
  EndIf
  
  If grProd\nMidiCCsConvertedToNRPN > 0
    nCount + 1
  EndIf
  
  ProcedureReturn nCount
  
EndProcedure

Procedure.s listReasonsForSave(bSkipHeader=#False, bIgnoreUnsavedEditorGraphs=#False, bIgnoreUnsavedPlaylistOrderInfo=#False)
  PROCNAMEC()
  ; See also checkSaveToBeEnabled (in PreWindows.pbi)
  Protected sMsg.s
  Protected s2LF.s = Chr(10) + Chr(10)
  
  If bSkipHeader = #False
    sMsg = s2LF + Lang("Main", "SaveMsgHdr") ; "Reason 'Save' is enabled:"
  EndIf
  
  If gbUnsavedRecovery
    sMsg + s2LF + Lang("Main", "SaveMsg1") ; "You recovered from an earlier edit, and there are changes from that edit that have not yet been saved."
  EndIf
  
  If gbAudioFileOrPathChanged
    sMsg + s2LF + Lang("Main", "SaveMsg2") ; "One or more audio or video files had to be re-found, and the new location(s) have not yet been saved to the cue file."
  EndIf
  
  If gbSCSVersionChanged
    sMsg + s2LF + Lang("Main", "SaveMsg3") ; "The cue file needs to be saved in the format required by the current version of SCS."
  EndIf
  
  If (gnUnsavedEditorGraphs > 0) And (bIgnoreUnsavedEditorGraphs = #False)
    sMsg + s2LF + Lang("Main", "SaveMsg5A") ; "Some audio graph information has not yet been saved."
    sMsg + Chr(10) + gsUnsavedEditorGraphs
  EndIf
  
  If gbUnsavedVideoImageData
    sMsg + s2LF + Lang("Main", "SaveMsg9") ; "Some video/image data has not yet been saved."
  EndIf
  
  If gbImportedCues
    sMsg + s2LF + Lang("Main", "SaveMsg6") ; "Cues have been imported from another cue file."
  EndIf
  
  If grCtrlSetup\bDataChanged
    sMsg + s2LF + Lang("Main", "SaveMsg7") ; "You have set or changed your Control Surface device settings."
  EndIf
  
  If WCN\bEQChanged
    sMsg + s2LF + Lang("Main", "SaveMsg8") ; "EQ settings changed."
  EndIf
  
  If gbNewDevMapFileCreated
    sMsg + s2LF + Lang("Main", "SaveMsg10") ; "A new device map file has been created."
  EndIf
  
  If gbNewCueFile
    sMsg + s2LF + Lang("Main", "SaveMsg11") ; "A new cue file has been created."
  EndIf
  
  If (gbUnsavedPlaylistOrderInfo) And (bIgnoreUnsavedPlaylistOrderInfo = #False)
    sMsg + s2LF + Lang("Main", "SaveMsg12") ; "Some playlist order data needs to be saved."
  EndIf
  
  If grWVP\bReadyToSaveToCueFile
    sMsg + s2LF + Lang("Main", "SaveMsg13") ; "VST Plugins have been changed."
  EndIf
  
  If changedSinceLastSave()
    sMsg + s2LF + Lang("Main", "SaveMsg4") ; "Changes have been made since your last save."
    If grMUR\nUndoGroupPtr >= 0
      sMsg + s2LF + LangSpace("Main", "SaveMsg4A") + gaUndoGroup(grMUR\nUndoGroupPtr)\sPrimaryDescr   ; "Last change:"
    EndIf
  EndIf
  
  If grProd\nMidiFreeConvertedToNrpn > 0
    sMsg + s2LF + grProd\nMidiFreeConvertedToNrpn + " MIDI Free Format Control Send message type(s) converted to MIDI NRPN." ; not language-translated as not deemed to be required long term
  EndIf
  
  If grProd\nMidiCCsConvertedToNRPN > 0
    sMsg + s2LF + "Some MIDI CC's converted to " + grProd\nMidiCCsConvertedToNRPN + " NRPN commands" ; not language-translated as not deemed to be required long term
  EndIf
  
  If Len(sMsg) > Len(s2LF)
    ProcedureReturn Mid(sMsg, Len(s2LF)+1)
  Else
    ProcedureReturn sMsg
  EndIf
  
EndProcedure

Procedure endOfAud(pAudPtr, pReqdStatus)
  PROCNAMECA(pAudPtr)
  Protected d, j, j2, k, k2

  debugMsg(sProcName, #SCS_START + ", pReqdStatus=" + decodeCueState(pReqdStatus))
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE And \nImageFrameCount > 1
        If \nAnimatedImageTimer
          RemoveWindowTimer(#WMN, \nAnimatedImageTimer)
        EndIf
      EndIf
      debugMsg(sProcName, "gbInGoToCue=" + strB(gbInGoToCue) + ", gbInNodeClick=" + strB(gbInNodeClick) + ", aCue(" + getCueLabel(\nCueIndex) + ")\nCueState=" + decodeCueState(aCue(\nCueIndex)\nCueState))
      If pReqdStatus >= 0
        audSetState(pAudPtr, pReqdStatus, 20)
      EndIf
      \bAffectedByLevelChange = #False
      \nLevelChangeSubPtr = -1
      \bIncDecLevelSet = #False
      If (gbInGoToCue Or gbInNodeClick) ; added 9Nov2019 11.8.2bu
        ; no further processing
      Else
        k = aAud(pAudPtr)\nNextPlayIndex
        If k = -1
          ; last aud
          j = aAud(pAudPtr)\nSubIndex
          ; added 24/11/2014 11.3.6 to stop a sub that is counting down when an SFR cue tries to stop the sub-cue
          If pReqdStatus = #SCS_CUE_COMPLETED
            If aSub(j)\nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
              aSub(j)\nSubState = pReqdStatus
            EndIf
          EndIf
          ; end of added 24/11/2014 11.3.6
          If gbStoppingEverything = #False And gbFadingEverything = #False ; Test added 10May2021 11.8.4.2bb following email from Rainer Sch?n
            ; process NextSubIndex
            ; j2 = aSub(j)\nNextSubIndex
            j2 = getNextEnabledSub(j) ; Changed 11Aug2024 11.10.3bk
            If j2 >= 0
              If aSub(j2)\nRelStartMode = #SCS_RELSTART_AE_PREV_SUB
                If aSub(j2)\nSubState <= #SCS_CUE_READY
                  aSub(j2)\qTimeToStartSub = gqTimeNow + aSub(j2)\nRelStartTime
                  debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\qTimeToStartSub=" + traceTime(aSub(j)\qTimeToStartSub) + ", gqTimeNo=" + traceTime(gqTimeNow))
                  debugMsg(sProcName, "setting aSub(" + getSubLabel(j2) + ")\nSubState to #SCS_CUE_SUB_COUNTDOWN_TO_START (currently " + decodeCueState(aSub(j2)\nSubState) + ")")
                  aSub(j2)\nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
                  k2 = aSub(j2)\nFirstPlayIndex
                  If k2 >= 0
                    audSetState(k2, #SCS_CUE_SUB_COUNTDOWN_TO_START, 24)
                  EndIf
                  setCueState(\nCueIndex)
                  updateGrid(\nCueIndex)
                EndIf
              EndIf ; EndIf aSub(j2)\nRelStartMode = #SCS_RELSTART_AE_PREV_SUB
            EndIf ; EndIf j2 >= 0
          EndIf ; EndIf gbStoppingEverything = #False And gbFadingEverything = #False
        EndIf ; EndIf k = -1
      EndIf ; EndIf (gbInGoToCue Or gbInNodeClick) / Else
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure endOfSub(pSubPtr, pReqdStatus)
  PROCNAMECS(pSubPtr)
  Protected j2, k2, d
  Protected nLCSubPtr, nLCAudPtr
  
  debugMsg(sProcName, #SCS_START + ", pReqdStatus=" + decodeCueState(pReqdStatus))
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      ; debugMsg(sProcName, "gbInGoToCue=" + strB(gbInGoToCue) + ", gbInNodeClick=" + strB(gbInNodeClick) + ", aCue(" + getCueLabel(\nCueIndex) + ")\nCueState=" + decodeCueState(aCue(\nCueIndex)\nCueState))
      If pReqdStatus >= 0
        \nSubState = pReqdStatus
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
      EndIf
      If (gbInGoToCue Or gbInNodeClick) ; added 9Nov2019 11.8.2bu
        ; no further processing
      ElseIf \bCalculatingDMXStartValuesOnly ; Added 30Sep2024 11.10.6ad
        debugMsg(sProcName, "exiting because aSub(" + getSubLabel(pSubPtr) + ")\bCalculatingDMXStartValuesOnly=" + strB(\bCalculatingDMXStartValuesOnly))
        ; no further processing
      Else
        ; debugMsg(sProcName, "\bStartedInEditor=" + strB(\bStartedInEditor))
        If \bStartedInEditor = #False ; moved from further down this procedure 19Mar2019 11.8.0.2cf following bug report from Dave Korman 'Pre-viewing sub-cue in editor triggers the cue in the main window'
          ; j2 = aSub(pSubPtr)\nNextSubIndex
          j2 = getNextEnabledSub(pSubPtr) ; Changed 21Aug2024 11.10.3bk
          If j2 >= 0
            If aSub(j2)\nRelStartMode = #SCS_RELSTART_AE_PREV_SUB
              If aSub(j2)\nSubState <= #SCS_CUE_READY
                aSub(j2)\qTimeToStartSub = gqTimeNow + aSub(j2)\nRelStartTime
                debugMsg(sProcName, "aSub(" + getSubLabel(j2) + ")\qTimeToStartSub=" + traceTime(aSub(j2)\qTimeToStartSub) + ", gqTimeNo=" + traceTime(gqTimeNow))
                debugMsg(sProcName, "setting aSub(" + getSubLabel(j2) + ")\nSubState to #SCS_CUE_SUB_COUNTDOWN_TO_START")
                aSub(j2)\nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
                k2 = aSub(j2)\nFirstPlayIndex
                If k2 >= 0
                  audSetState(k2, #SCS_CUE_SUB_COUNTDOWN_TO_START, 25)
                EndIf
                setCueState(\nCueIndex)
                updateGrid(\nCueIndex)
              EndIf
            EndIf
          EndIf
          If \bSubTypeL
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              \nLCPosition[d] = 0
            Next d
            \nLCPositionMax = 0
            nLCSubPtr = \nLCSubPtr
            If nLCSubPtr >= 0
              nLCAudPtr = aSub(nLCSubPtr)\nFirstAudIndex
              While nLCAudPtr >= 0
                If aAud(nLCAudPtr)\bInLoopXFade
                  debugMsg(sProcName, "aAud(" + getAudLabel(nLCAudPtr) + ")\bInLoopXFade=" + strB(aAud(nLCAudPtr)\bInLoopXFade) + ", \bFadeInProgress=" + strB(aAud(nLCAudPtr)\bFadeInProgress))
                  ; Commented out the following test 10Dec2019 11.8.2.1 following report from Markku Tanskanen
                  ; If a level change interrupts a loop cross-fade and the level change ends before the cross-fade, then the BASS_ChannelSlideAttribute() commands for the cross-fade must be reset.
                  ; This was not happening because of the test "\bFadeInProgress = #False".
                  ; If aAud(nLCAudPtr)\bFadeInProgress = #False
                    For d = 0 To grLicInfo\nMaxAudDevPerAud
                      aAud(nLCAudPtr)\fBVLevelAtLoopEnd[d] = aAud(nLCAudPtr)\fLCBVLevel[d]
                    Next d
                    debugMsg(sProcName, "calling continueXfade(" + getAudLabel(nLCAudPtr) + ")")
                    continueXfade(nLCAudPtr)
                  ; EndIf
                EndIf
                nLCAudPtr = aAud(nLCAudPtr)\nNextAudIndex
              Wend
            EndIf
          Else
            \nSubPosition = 0
          EndIf
          \bTimeSubStartedSet = #False
          \bPLRepeatCancelled = #False
        EndIf
        
        If \bSubTypeU
          If grMTCSendControl\nMTCSubPtr = pSubPtr
            grMTCSendControl\nMTCSubPtr = grMTCSendControlDef\nMTCSubPtr  ; -1
            grMTCSendControl\bMTCSendControlActive = #False ; Added 30Jan2025 11.10.6
            debugMsg(sProcName, "grMTCSendControl\nMTCSubPtr=" + getSubLabel(grMTCSendControl\nMTCSubPtr))
            If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
              samAddRequest(#SCS_SAM_HIDE_MTC_WINDOW_IF_INACTIVE, 0, 0, 0, "", ElapsedMilliseconds()+3000)  ; close window after 3 seconds (unless allocated to another sub)
            EndIf
          EndIf
        EndIf
        
        If getHideCueOpt(\nCueIndex) = #SCS_HIDE_NO ; test changed 19Jul2018 11.7.1.1ac
          ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
        EndIf
        
        ; debugMsg(sProcName, "setting gbCallSetCueToGo=#True")
        gbCallSetCueToGo = #True
        
        ; moved from stopSub() 19Mar2019 11.8.0.2cf following bug report from Dave Korman 'Pre-viewing sub-cue in editor triggers the cue in the main window'
        If \bStartedInEditor
          \bStartedInEditor = #False
          ; debugMsg(sProcName, "\bStartedInEditor=" + strB(\bStartedInEditor))
        EndIf
        ; end moved from stopSub() 19Mar2019 11.8.0.2cf
        
      EndIf ; EndIf (gbInGoToCue Or gbInNodeClick) / Else
      
      \nTotalTimeOnGlobalPause = 0 ; Added 9Mar2024 11.10.2bd following tests of M2T - see email from CPeters 8Mar2024
      
      ; debugMsg(sProcName, #SCS_END + ", aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
    EndWith
  EndIf
  
EndProcedure

Procedure doUnloadMain()
  PROCNAMEC()
  Protected sButtons.s, sDontAskMeAgainText.s, nOption, bRaiseAskMessage
  Protected nResponse, bClosed, bCancel
  Protected sMsg.s

  debugMsg(sProcName, #SCS_START)
  
  If gbUnloadImmediate
    gbClosingDown = #True
    debugMsg(sProcName, "gbUnloadImmediate=" + strB(gbUnloadImmediate) + ", gbClosingDown=" + strB(gbClosingDown))
    ProcedureReturn
  EndIf
  
  WEN_closeMemoWindowsIfOpen()
  
;   ; Added 19Oct2020 11.8.3.2bx
;   debugMsg(sProcName, "calling stopAll(#False, #True, #True)")
;   stopAll(#False, #True, #True)
;   ; End added 19Oct2020 11.8.3.2bx
  
  debugMsg(sProcName, "calling checkDataChanged(#True, #True)")
  bCancel = checkDataChanged(#True, #True)
  debugMsg(sProcName, "checkDataChanged(#True, #True) returned " + strB(bCancel))
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation so do not close editor
    ProcedureReturn #False ; #False indicates abort unload processing
  EndIf
  
  If getDontAskTellToday(#SCS_DontAskCloseSCSDate) = #False
    bRaiseAskMessage = #True
    If grLicInfo\bFMAvailable And grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
      ; Added this test 12Jan2022 11.9ah so that the message is not displayed on the backup machine
      bRaiseAskMessage = #False
    EndIf
  EndIf
  If bRaiseAskMessage
    sMsg = Lang("WMN", "Closing") + "|" + Lang("WMN", "AreYouSure") + Space(8) ; added extra spacing to message to widen the OptionRequester message box, giving a better appearance
    sButtons = Lang("Common", "Yes") + "|" + Lang("Common", "No")
    sDontAskMeAgainText = Lang("Common", "DontAskMeAgainToday") ; "Don't ask me again today"
    nOption = OptionRequester(0, 0, sMsg, sButtons, 200, #IDI_QUESTION, 0, sDontAskMeAgainText, 80, 0, #PB_Default, #PB_Default, 0, 20)
    debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
    If nOption & $10000
      setDontAskTellToday(#SCS_DontAskCloseSCSDate)
    EndIf
    Select (nOption & $FFFF)
      Case 2, 0
        ; user clicked 'No' (2) or ESC (0)
        ProcedureReturn #False ; #False indicates abort unload processing
    EndSelect
  EndIf

  gbClosingDown = #True
  debugMsg(sProcName, "gbClosingDown=" + strB(gbClosingDown))
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  If IsWindow(#WMN)
    If gbInitialising = #False
      ; if not finished initialising then form may not yet have been resized
      getFormPosition(#WMN, @grMainWindow, #True)
      If grWMN\bNorthSouthSplitterInitialPosApplied
        If gnOperMode = #SCS_OPERMODE_DESIGN
          grWMN\nNorthSouthSplitterPosD = GetGadgetState(WMN\splNorthSouth)
        ElseIf gnOperMode = #SCS_OPERMODE_REHEARSAL
          grWMN\nNorthSouthSplitterPosR = GetGadgetState(WMN\splNorthSouth)
        Else
          grWMN\nNorthSouthSplitterPosP = GetGadgetState(WMN\splNorthSouth)
        EndIf
      EndIf
    EndIf
  EndIf
  
  If IsWindow(#WED)
    debugMsg(sProcName, "Hiding fmEditor")
    setWindowVisible(#WED, #False)
  EndIf
  
  gbDontChangeFocus = #True
  If gbDemoMode
    ensureSplashNotOnTop()
    CompilerIf #cAgent
      sMsg + LangPars("Main", "RegAgent", #SCS_AGENT_NAME, #SCS_REGISTER_URL_DISPLAY)
    CompilerElse
      sMsg + LangPars("Main", "RegOnline", #SCS_REGISTER_URL_DISPLAY)
    CompilerEndIf
    sMsg + Chr(10) + Chr(10)
    sMsg + Lang("Main", "RegNow")     ; "Do you want to go to the registration web page now?"
    nResponse = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    If nResponse = #PB_MessageRequester_Yes
      OpenURL(#SCS_REGISTER_URL_DISPLAY)
    ElseIf nResponse = #PB_MessageRequester_Cancel
      gbDontChangeFocus = #False
      debugMsg(sProcName, "closedown cancelled by user")
      ProcedureReturn #True
    EndIf
  EndIf
  
  closeDown(#False, #True)
  
  gbDontChangeFocus = #True
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True   ; #True indicates continue with unload processing

EndProcedure

Procedure.s getActiveWindowApplication()
  PROCNAMEC()
  ; based on PB Forum posting ".EXE name of topmost application" by bluenzl 6Nov2013
  Protected buffer.s{512}
  Protected max.i = 510 ; Len(buffer)-2
  Protected window_h.i
  Protected process_id.i
  Protected process_h.i
  Protected application_name.s, window_name.s
  Static K32GetModuleFileNameExW_
  Protected l
  Protected dwError.l
  
  If IsLibrary(gnKernel32Library) = #False
    gnKernel32Library = OpenLibrary(#PB_Any,"kernel32.dll")
    CompilerIf #cTraceGetActiveWindow
      debugMsg2(sProcName, "OpenLibrary(#PB_Any,'kernel32.dll')", gnKernel32Library)
    CompilerEndIf
  EndIf
  
  If gnKernel32Library
    window_h = GetForegroundWindow_()
    CompilerIf #cTraceGetActiveWindow
      debugMsg2(sProcName, "GetForegroundWindow_()", window_h)
    CompilerEndIf
    If window_h <> 0
      l = GetWindowText_(window_h,@buffer,max)
      CompilerIf #cTraceGetActiveWindow
        debugMsg2(sProcName, "GetWindowText_(" + window_h + ",@buffer," + max + ")",l)
      CompilerEndIf
      If l = 0
        ; implies GetWindowText failed or the window has no title
        dwError = GetLastError_()
        CompilerIf #cTraceGetActiveWindow
          debugMsg2(sProcName, "GetLastError_()", dwError)
        CompilerEndIf
      Else
        window_name = PeekS(@buffer,l)
        CompilerIf #cTraceGetActiveWindow
          debugMsg(sProcName, "PeekS(@buffer," + l + ") returned window_name=" + window_name)
        CompilerEndIf
      EndIf
      GetWindowThreadProcessId_(window_h,@process_id)
      CompilerIf #cTraceGetActiveWindow
        debugMsg(sProcName, "GetWindowThreadProcessId_(" + window_h + ",@process_id) set process_id=" + process_id)
      CompilerEndIf
      If process_id <> 0
        process_h = OpenProcess_(#PROCESS_QUERY_INFORMATION|#PROCESS_VM_READ , #False, process_id)
        CompilerIf #cTraceGetActiveWindow
          debugMsg2(sProcName, "OpenProcess_(#PROCESS_QUERY_INFORMATION|#PROCESS_VM_READ , #False, " + process_id + ")", process_h)
        CompilerEndIf
        If process_h <> 0
          If K32GetModuleFileNameExW_ = 0
            K32GetModuleFileNameExW_ = GetFunction(gnKernel32Library,"K32GetModuleFileNameExW")
            CompilerIf #cTraceGetActiveWindow
              debugMsg2(sProcName, "GetFunction(gnKernel32Library,'K32GetModuleFileNameExW')", K32GetModuleFileNameExW_)
            CompilerEndIf
          EndIf
          If K32GetModuleFileNameExW_
            l = CallFunctionFast(K32GetModuleFileNameExW_ ,process_h, 0, @buffer, max)
            CompilerIf #cTraceGetActiveWindow
              debugMsg2(sProcName, "CallFunctionFast(K32GetModuleFileNameExW_ ," + process_h + ", 0, @buffer, " + max + ")", l)
            CompilerEndIf
            If l = 0
              ; implies K32GetModuleFileNameExW failed
              dwError = GetLastError_()
              CompilerIf #cTraceGetActiveWindow
                debugMsg2(sProcName, "GetLastError_()", dwError)
              CompilerEndIf
            Else
              application_name = PeekS(@buffer,l)
              CompilerIf #cTraceGetActiveWindow
                debugMsg(sProcName, "PeekS(@buffer," + l + ") returned application_name=" + application_name)
              CompilerEndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  CompilerIf #cTraceGetActiveWindow
    debugMsg(sProcName, #SCS_END + ", returning " + application_name)
  CompilerEndIf
  ProcedureReturn application_name
  
EndProcedure

Procedure.s getActiveWindowTitle()
  PROCNAMEC()
  ; based on PB Forum posting ".EXE name of topmost application" by bluenzl 6Nov2013
  Protected buffer.s{512}
  Protected max.i = 510 ; Len(buffer)-2
  Protected window_h.i
  Protected window_name.s
  Protected l
  Protected dwError.l
  
  If IsLibrary(gnKernel32Library) = #False
    gnKernel32Library = OpenLibrary(#PB_Any,"kernel32.dll")
    debugMsg2(sProcName, "OpenLibrary(#PB_Any,'kernel32.dll')", gnKernel32Library)
  EndIf
  
  If gnKernel32Library
    window_h = GetForegroundWindow_()
    ; debugMsg2(sProcName, "GetForegroundWindow_()", window_h)
    If window_h <> 0
      l = GetWindowText_(window_h,@buffer,max)
      ; debugMsg2(sProcName, "GetWindowText_(" + window_h + ",@buffer," + max + ")",l)
      If l = 0
        ; implies GetWindowText failed or the window has no title
        dwError = GetLastError_()
        ; debugMsg2(sProcName, "GetLastError_()", dwError)
      Else
        window_name = PeekS(@buffer,l)
        ; debugMsg(sProcName, "PeekS(@buffer," + l + ") returned window_name=" + window_name)
        debugMsg(sProcName, "window_name=" + window_name)
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + window_name)
  ProcedureReturn window_name
  
EndProcedure

Procedure setFocusToSCS()
  ; Procedure added 6May2020 11.8.3rc2
  PROCNAMEC()
  
  If GetActiveWindow() = -1
    If gbEditing And IsWindow(#WED)
      ; debugMsg(sProcName, "calling SAW(#WED)")
      SAW(#WED)
    ElseIf IsWindow(#WMN)
      ; debugMsg(sProcName, "calling SAW(#WMN)")
      SAW(#WMN)
    ElseIf IsWindow(#WPL)
      SAW(#WPL)
    EndIf
  EndIf
  
EndProcedure

Procedure checkMainHasFocus(pCaller)
  ; added pCaller 17Aug2017 11.7.0 to assist in debugging
  PROCNAMEC()
  Static sLostFocus.s, sActiveWindow.s, sActiveWindowTitle.s, sActiveApp.s
  Static bStaticLoaded
  Protected nActiveWindow, bActiveWindowOK
  Protected sWindowApplication.s, sWindowTitle.s
  Protected bPrevLostFocusDisplayedState
  Static sPrevWindowApplication.s, sPrevWindowTitle.s
  Static bReverseColors
  Static sMessage.s
  
  ; debugMsg(sProcName, #SCS_START + ", pCaller=" + pCaller)
  
  CompilerIf #cSuppressLostFocusMsg
    ProcedureReturn
  CompilerEndIf
  
  If grProd\nLostFocusAction = #SCS_LOSTFOCUS_IGNORE
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    sLostFocus = Lang("Main", "LostFocus")
    sActiveWindow = " [" + Lang("Main", "ActiveWindow") + ": "
    sActiveWindowTitle = " [" + Lang("Main", "ActiveWindowTitle") + ": "
    sActiveApp = " [" + Lang("Main", "ActiveApp") + ": "
    bStaticLoaded = #True
  EndIf
  
  ; added 18Aug2017 11.7.0
  If (gbEditing) Or (grWVP\bWindowActive) ; added grWVP\bWindowActive 30Sep2019 11.8.2ap
    If grEditingOptions\bCheckMainLostFocusWhenEditorOpen = #False ; added this test 14Mar2019 11.8.0.2cc following request from Scott Siegwald, 6Mar2019
      ProcedureReturn
    EndIf
  EndIf
  ; end added 18Aug2017 11.7.0
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_CHECK_MAIN_HAS_FOCUS, pCaller)
    ProcedureReturn
  EndIf
  
  nActiveWindow = GetActiveWindow()
  ; debugMsg(sProcName, "nActiveWindow=" + decodeWindow(nActiveWindow))
  Select nActiveWindow
    Case #WMN, #WMT, #WDD, #WDT, #WFL, #WLP, #WNE, #WSP, #WTC, #WTI, #WCN, #WV2 To #WV_LAST, #WM2 To #WM9
      bActiveWindowOK = #True
  EndSelect
  
  bPrevLostFocusDisplayedState = gbLostFocusDisplayed
  
  ; debugMsg(sProcName, "pCaller=" + pCaller + ", nActiveWindow=" + decodeWindow(nActiveWindow) + ", gbCheckForLostFocus=" + strB(gbCheckForLostFocus) + ", gbLostFocusDisplayed=" + strB(gbLostFocusDisplayed) +
  ;                     ", gqTimeLostFocusDisplayed=" + traceTime(gqTimeLostFocusDisplayed) + ", grEditingOptions\bCheckMainLostFocusWhenEditorOpen=" + strB(grEditingOptions\bCheckMainLostFocusWhenEditorOpen))
  While #True
    If (gbInitialising = #False) And (gbClosingDown = #False) And (gbModalDisplayed = #False) And (gbLoadingCueFile = #False)
      If (gqTimeNow - gqStartTime) > 10000
        If gbCheckForLostFocus
          If nActiveWindow = -1
            sWindowApplication = getActiveWindowApplication()
            If sWindowApplication = ProgramFilename()
              ; can get here if the Help file is open, or if a TVG video capture window has been activated (although procedure playTVGCapture() now resets focus at the end of the procedure)
              Break ; skip all remaining processing in the procedure if (nActiveWindow = -1) AND (sWindowApplication = ProgramFilename())
            EndIf
            If LCase(GetFilePart(sWindowApplication)) = "rundll32.exe"
              ; rundll32.exe is a program that runs dll's as programs, and although that is fairly general it is used by the access control process when asking the user if it's OK to run this program (eg SCS).
              ; so, even though this isn't the only use of rundll32.exe, we accept this as OK when checking main has focus, to avoid an unnecessary display of the pop-up
             debugMsg(sProcName, "sWindowApplication=" + GetFilePart(sWindowApplication))
            EndIf
            If sWindowApplication
              If sWindowApplication <> sPrevWindowApplication
                gbLostFocusDisplayed = #False ; force re-display of message if the active window has changed
                sPrevWindowApplication = sWindowApplication
              EndIf
            Else
              sWindowTitle = getActiveWindowTitle()
              If sWindowTitle <> sPrevWindowTitle
                gbLostFocusDisplayed = #False ; force re-display of message if the active window title has changed
                sPrevWindowTitle = sWindowTitle
              EndIf
            EndIf
          EndIf
          If gbLostFocusDisplayed = #False
            bReverseColors = #False
            If (bActiveWindowOK = #False) And (gbIgnoreLostFocus = #False)
              debugMsg(sProcName, "nActiveWindow=" + decodeWindow(nActiveWindow))
              sMessage = sLostFocus
              If nActiveWindow = -1
                If sWindowApplication ; nb sWindowApplication may be blank if K32GetModuleFileNameExW failed, which could happen pre-Windows 7
                  sMessage + sActiveApp + GetFilePart(sWindowApplication) + "]"
                ElseIf sWindowTitle
                  sMessage + sActiveWindowTitle + sWindowTitle + "]"
                EndIf
              Else
                sWindowTitle = getActiveWindowTitle()
                If sWindowTitle
                  sMessage + sActiveWindowTitle + sWindowTitle + "]"
                Else
                  sMessage + sActiveWindow + decodeWindow(nActiveWindow) + "]"
                EndIf
              EndIf
              ; debugMsg(sProcName, "displaying main has lost focus")
              WMN_setStatusField(sMessage, #SCS_STATUS_MAJOR_WARN, 0, #True)
              gqTimeLostFocusDisplayed = gqTimeNow
              gbLostFocusDisplayed = #True
            EndIf
          Else
            If bActiveWindowOK
              gqMainThreadRequest | #SCS_MTH_CLEAR_STATUS_FIELD
              ; debugMsg(sProcName, "bActiveWindowOK=" + strB(bActiveWindowOK) + ", gqMainThreadRequest=" + gqMainThreadRequest)
              gbLostFocusDisplayed = #False
            EndIf
          EndIf
        EndIf ; EndIf gbCheckForLostFocus
        Select nActiveWindow
          Case #WV2 To #WV_LAST
            samAddRequest(#SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW)
        EndSelect
      EndIf ; EndIf (gqTimeNow - gqStartTime) > 10000
    EndIf ; EndIf (gbInitialising = #False) And (gbClosingDown = #False) And (gbModalDisplayed = #False) And (gbLoadingCueFile = #False)
    Break
  Wend
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkPauseAllActive(pCaller)
  PROCNAMEC()
  Static bReverseColors
  Static sMessage.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", pCaller=" + pCaller)
  
  If (gbGlobalPause = #False) And (gbPauseAllDisplayed = #False)
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    sMessage = Lang("Main", "PauseAllActive")
    bStaticLoaded = #True
  EndIf
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_CHECK_PAUSE_ALL_ACTIVE, pCaller)
    ProcedureReturn
  EndIf
  
  If gbPauseAllDisplayed = #False
    bReverseColors = #False
    WMN_setStatusField(sMessage, #SCS_STATUS_MAJOR_WARN, 0, #True)
    gbPauseAllDisplayed = #True
  Else
    If gbGlobalPause = #False
      gqMainThreadRequest | #SCS_MTH_CLEAR_STATUS_FIELD
      gbPauseAllDisplayed = #False
    Else
      If bReverseColors = #False
        bReverseColors = #True
        WMN_setStatusField(sMessage, #SCS_STATUS_MAJOR_WARN_REVERSE_COLORS, 0, #True)
      Else
        bReverseColors = #False
        WMN_setStatusField(sMessage, #SCS_STATUS_MAJOR_WARN_NORMAL_COLORS, 0, #True)
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure makeMainWindowActive()
  PROCNAMEC()
  
  If GetActiveWindow() <> #WMN
    debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(#WMN)")
    SAW(#WMN)
    checkMainHasFocus(1) ; call this to immediately turn off the warning message if displayed
  EndIf
EndProcedure

Procedure setGrdCuesRowNos()
  ; PROCNAMEC()
  Protected nRowNo, i
  
  ; debugMsg(sProcName, #SCS_START)
  
  nRowNo = -1
  For i = 1 To gnLastCue
    With aCue(i)
      If (\bCueCurrentlyEnabled) And  (\bCueSubsAllDisabled = #False) And (\nCueState <> #SCS_CUE_IGNORED) And (\nHideCueOpt <> #SCS_HIDE_ENTIRE_CUE)
        nRowNo + 1
        \nGrdCuesRowNo = nRowNo
      Else
;         debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bCueCurrentlyEnabled=" + strB(\bCueCurrentlyEnabled) +
;                             ", \bCueSubsAllDisabled=" + strB(\bCueSubsAllDisabled) +
;                             ", \nCueState=" + decodeCueState(\nCueState) +
;                             ", \nHideCueOpt=" + decodeHideCueOpt(\nHideCueOpt))
        \nGrdCuesRowNo = -1
      EndIf
    EndWith
  Next i
  ; also set nGrdCuesRowNo in the dummy 'end' cue as it occupies a row in WMN\grdCues
  nRowNo + 1
  aCue(gnCueEnd)\nGrdCuesRowNo = nRowNo
  gnRowEnd = nRowNo
  
EndProcedure

Procedure setGridRow(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nRowNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_SET_GRID_ROW, pCuePtr)
    ProcedureReturn
  EndIf
  
  If (pCuePtr > 0) And (pCuePtr <= gnCueEnd)
    nRowNo = aCue(pCuePtr)\nGrdCuesRowNo
    If (nRowNo >= 0) And (nRowNo < CountGadgetItems(WMN\grdCues))
      ; debugMsg(sProcName, "calling SGS(WMN\grdCues, " + nRowNo + ")")
      SGS(WMN\grdCues, nRowNo)
    EndIf
  EndIf
  
EndProcedure

Procedure setTimeProfileCount(*rProd.tyProd)
  ; PROCNAMEC()
  Protected n
  
  With *rProd
    \nTimeProfileCount = 0
    For n = 0 To #SCS_MAX_TIME_PROFILE
      If Trim(\sTimeProfile[n])
        \nTimeProfileCount + 1
      EndIf
    Next n
    ; debugMsg0(sProcName, "\nTimeProfileCount=" + \nTimeProfileCount)
  EndWith
  
EndProcedure

Procedure setTimeBasedCues(pCuePtr=-1, bChangingTimeProfile=#False)
  PROCNAMECQ(pCuePtr)
  Protected i, j, k, n, nMySecondToStart, nMyLatestSecondToStart
  Protected nReqdState, nSecondsNow, bEnabled
  Protected nTmp, nCurrCuePtr, bFound
  Protected nMyFirstCue, nMyLastCue
  Protected bActivationMethodReqdSet
  
  ; debugMsg0(sProcName, "grProd\nTimeProfileCount=" + grProd\nTimeProfileCount)
  
  ; added 17Mar2020 11.8.2.3aa to reduce unnecessary processing if no time profiles have been created
  ; code insert before #SCS_START debug message so no unnecessary logging either
  If grProd\nTimeProfileCount = 0
    ProcedureReturn
  EndIf
  ; end added 17Mar2020 11.8.2.3aa
  
  ; debugMsg(sProcName, #SCS_START + ", pCuePtr=" + getCueLabel(pCuePtr) + ", bChangingTimeProfile=" + strB(bChangingTimeProfile))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_SET_TIME_BASED_CUES, pCuePtr, 0, bChangingTimeProfile)
    ProcedureReturn
  EndIf
  
  nSecondsNow = Date()
  
  If pCuePtr = -1
    nMyFirstCue = 1
    nMyLastCue = gnLastCue
  Else
    nMyFirstCue = pCuePtr
    nMyLastCue = pCuePtr
  EndIf
  
  If pCuePtr = -1
    ; only adjust button and menu item if this is a full setTimeBasedCues() call
    If IsWindow(#WMN)
      bEnabled = #False
      For n = 0 To #SCS_MAX_TIME_PROFILE
        If grProd\sTimeProfile[n]
          bEnabled = #True
          Break
        EndIf
      Next n
      setToolBarBtnEnabled(#SCS_TBMB_TIME, bEnabled)
      scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuTimeProfile, bEnabled)
    EndIf
  EndIf
  
  ; check gsWhichTimeProfile
  bFound = #False
  If gsWhichTimeProfile
    For n = 0 To #SCS_MAX_TIME_PROFILE
      If gsWhichTimeProfile = grProd\sTimeProfile[n]
        bFound = #True
        Break
      EndIf
    Next n
  EndIf
  
  If bFound = #False
    gsWhichTimeProfile = grProd\sDefaultTimeProfile
  EndIf
  
  ; debugMsg(sProcName, "gsWhichTimeProfile=" + gsWhichTimeProfile)
  
  For i = nMyFirstCue To nMyLastCue
    bActivationMethodReqdSet = #False
    With aCue(i)
      If \nActivationMethod = #SCS_ACMETH_TIME
        debugMsg(sProcName, "gbStoppingEverything=" + strB(gbStoppingEverything) + ", gbSamRequestUnderStoppingEverything=" + strB(gbSamRequestUnderStoppingEverything) +
                            ", aCue(" + getCueLabel(i) + ")\bTBCDone=" + strB(\bTBCDone) +
                            ", \bTimeCueStoppedSet=" + strB(\bTimeCueStoppedSet) + ", \nStopEverythingCueState=" + decodeCueState(\nStopEverythingCueState) + ", \qTimeCueStopped=" + traceTime(\qTimeCueStopped))
        If (gbResettingTODPart1 = #False And gbResettingTODPart2 = #False) And (gbStoppingEverything Or gbSamRequestUnderStoppingEverything)
          Select \nStopEverythingCueState
            Case #SCS_CUE_COUNTDOWN_TO_START To #SCS_CUE_FADING_OUT
              \nActivationMethodReqd = #SCS_ACMETH_MAN
              bActivationMethodReqdSet = #True
              \bTBCDone = #False
              debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) +
                                  ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) + ", \bTBCDone=" + strB(\bTBCDone))
            Default
              If \bCueStoppedByStopEverything
                \nActivationMethodReqd = #SCS_ACMETH_MAN
                bActivationMethodReqdSet = #True
                \bTBCDone = #False
                debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) +
                                    ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) + ", \bTBCDone=" + strB(\bTBCDone))
              EndIf
          EndSelect
        EndIf
        
        If \bTBCDone = #False And \bCueCurrentlyEnabled And (\bTimeCueStoppedSet = #False Or (ElapsedMilliseconds() - \qTimeCueStopped) >= 2000 Or (gbResettingTODPart1 Or gbResettingTODPart2))
          ; ignores cues like GoTo that triggered this call to setTimeBasedCues()
          debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
          setCueState(i)  ; added in 11.2.1 because a cue type R may still be marked as 'not loaded' which would cause setTimeBasedCues() to ignore the cue
          If bActivationMethodReqdSet = #False
            \nActivationMethodReqd = \nActivationMethod   ; may be overriden later in this Procedure
            ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
          EndIf
          nMySecondToStart = -1
          nMyLatestSecondToStart = -1
          If gsWhichTimeProfile
            If (\nCueState <= #SCS_CUE_READY) Or (\nCueState >= #SCS_CUE_COMPLETED)
              For n = 0 To #SCS_MAX_TIME_PROFILE
                If \sTimeProfile[n] = gsWhichTimeProfile
                  \sTimeBasedStartReqd = \sTimeBasedStart[n]
                  \sTimeBasedLatestStartReqd = \sTimeBasedLatestStart[n]
                  If UCase(Left(\sTimeBasedStartReqd, 1)) = "M"
                    nMySecondToStart = -99
                    nMyLatestSecondToStart = -99
                  Else
                    nMySecondToStart = stringToDateSeconds(\sTimeBasedStartReqd)
                    nMyLatestSecondToStart = stringToDateSeconds(\sTimeBasedLatestStartReqd)
                  EndIf
                  Break
                EndIf
              Next n
            EndIf
          EndIf
          
          debugMsg(sProcName, "Q=" + \sCue + ", nMySecondToStart=" + nMySecondToStart + ", nMyLatestSecondToStart=" + nMyLatestSecondToStart + ", nSecondsNow=" + nSecondsNow + ", \nCueState=" + decodeCueState(\nCueState))
          If (\nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nCueState <= #SCS_CUE_FADING_OUT)
            ; do not change cue state if the cue is currently playing or on countdown to start
            ; (this may be because the user started the cue in the editor and then closed the editor while it was still playing)
            nReqdState = \nCueState
            
          ElseIf nMySecondToStart = -1
            ; no start time given for currently selected time profile
            nReqdState = #SCS_CUE_IGNORED
            
          ElseIf nMySecondToStart = -99 ; Manual
            nReqdState = \nCueState
            If \nCueState >= #SCS_CUE_COMPLETED
              nTmp = GetGadgetState(WMN\grdCues)
              nCurrCuePtr = WMN_getCuePtrForRowNo(nTmp)
              debugMsg(sProcName, "GetGadgetState(WMN\grdCues) returned " + nTmp + ", nCurrCuePtr=" + getCueLabel(nCurrCuePtr))
              If i < nCurrCuePtr
                nReqdState = #SCS_CUE_COMPLETED
              ElseIf i = nCurrCuePtr
                nReqdState = #SCS_CUE_NOT_LOADED
              EndIf
            EndIf
            If bActivationMethodReqdSet = #False
              \nActivationMethodReqd = #SCS_ACMETH_MAN
            EndIf
            debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
            
          ElseIf (nSecondsNow - nMySecondToStart) > 60
            debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bCueStoppedByStopEverything=" + strB(\bCueStoppedByStopEverything) +
                                ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) + ", gbStoppingEverything=" + strB(gbStoppingEverything))
            ; TBC Project Changes
            If (nMyLatestSecondToStart - nSecondsNow) > 0 ; TBC Latest time to start cue by time not yet reached so start cue
              nReqdState = \nCueState
              ; \nSecondToStart = nSecondsNow +2 ;2 seconds after starting SCS TBC for Late Start.
              \nSecondToStart = nSecondsNow ; Changed the above 1Oct2022 11.9.6 - don't know why it was necessary to add any time 'for late start'
            ElseIf (\bCueStoppedByStopEverything) And (\nActivationMethodReqd = #SCS_ACMETH_MAN)
              nReqdState = \nCueState
            ElseIf gbStoppingEverything
              nReqdState = \nCueState
            Else
              ; cue should have started more than 60 seconds ago - regard as completed
              nReqdState = #SCS_CUE_COMPLETED
              \nSecondToStart = nMySecondToStart
              \qTimeCueStopped = ElapsedMilliseconds() - 3000
              \bTimeCueStoppedSet = #True
              \bCueStoppedByStopEverything = gbStoppingEverything
              \bCueStoppedByGoToCue = gbInGoToCue
              debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bTimeCueStoppedSet=" + strB(\bTimeCueStoppedSet) +
                                  ", \qTimeCueStopped=" + traceTime(\qTimeCueStopped) + ", \bCueStoppedByStopEverything=" + strB(\bCueStoppedByStopEverything) +
                                  ", \bCueStoppedByGoToCue=" + strB(\bCueStoppedByGoToCue))
              ; Added 30Dec2024 11.10.6bz
              ; If should have started more than 60 seconds ago, etc, then also 'complete' any auto-start cues directly or indirectly auto-related to this cue
              debugMsg(sProcName, "calling completeAssocAutoStartCues(" + getCueLabel(i) + ")")
              completeAssocAutoStartCues(i)
              ; End added 30Dec2024 11.10.6bz
            EndIf
          ElseIf \nCueState >= #SCS_CUE_COMPLETED
            nReqdState = #SCS_CUE_NOT_LOADED
            \nSecondToStart = nMySecondToStart
          Else
            nReqdState = \nCueState
            \nSecondToStart = nMySecondToStart
          EndIf
          debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nSecondToStart=" + \nSecondToStart + ", \bTBCDone=" + strB(\bTBCDone) + ", nReqdState=" + decodeCueState(nReqdState))
          
          If (nReqdState = #SCS_CUE_IGNORED) Or (nReqdState = #SCS_CUE_COMPLETED) Or (nReqdState = #SCS_CUE_NOT_LOADED)
            closeCue(i)
            j = \nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeHasAuds
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    audSetState(k, nReqdState, 26)
                    k = aAud(k)\nNextAudIndex
                  Wend
                EndIf
                If nReqdState = #SCS_CUE_COMPLETED
                  debugMsg(sProcName, "calling endOfSub(" + getSubLabel(j) + ", #SCS_CUE_COMPLETED)")
                  endOfSub(j, nReqdState)
                Else
                  aSub(j)\nSubState = nReqdState
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
            ; \nCueState = nReqdState
            ; Added 4Dec2021 11.8.6cq
            If nReqdState = #SCS_CUE_COMPLETED
              If \nActivationMethodReqd = #SCS_ACMETH_TIME ; Test added 29Jan2022 11.9.0rc6a
                \bTBCDone = #True
                debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bTBCDone=" + strB(\bTBCDone))
              EndIf
            EndIf
            ; End added 4Dec2021 11.8.6cq
            setCueState(i)
          EndIf
          debugMsg(sProcName, "aCue(" + \sCue + ")\nCueState=" + decodeCueState(\nCueState) + ", \bTBCDone=" + strB(\bTBCDone))
          
        EndIf
        debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
        
        ; Added 31Dec2024 11.10.6ca
        If i = pCuePtr
          If \nCueState <= #SCS_CUE_READY And \bTBCDone = #False
            debugMsg(sProcName, "calling readyAssocAutoStartCues(" + getCueLabel(i) +")")
            readyAssocAutoStartCues(i)
          EndIf
        EndIf
        ; End added 31Dec2024 11.10.6ca
        
      EndIf ; EndIf \nActivationMethod = #SCS_ACMETH_TIME
    EndWith
  Next i
  
  If pCuePtr = -1
    setCheckForResetTOD()
  EndIf
  
  If bChangingTimeProfile
    ; initiated from WTP_changeTimeProfile()
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    gnCallOpenNextCues = 1
    debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues + ", gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
  EndIf

  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setCheckForResetTOD()
  PROCNAMEC()
  Protected i, n
  
  gbCheckForResetTOD = #False
  If grProd\nResetTOD >= 0
    If gsWhichTimeProfile
      For i = 1 To gnLastCue
        With aCue(i)
          If (\bCueCurrentlyEnabled) And (\nActivationMethod = #SCS_ACMETH_TIME)
            For n = 0 To #SCS_MAX_TIME_PROFILE
              If \sTimeProfile[n] = gsWhichTimeProfile
                If UCase(Left(\sTimeBasedStart[n], 1)) <> "M"
                  gbCheckForResetTOD = #True
                  debugMsg(sProcName, "gbCheckForResetTOD=" + strB(gbCheckForResetTOD) + ", i=" + getCueLabel(i))
                EndIf
                Break
              EndIf
            Next n
          EndIf
        EndWith
        If gbCheckForResetTOD
          Break
        EndIf
      Next i
    EndIf
  EndIf
EndProcedure

Procedure saveLastPicInfo(pAudPtr)
  PROCNAMECA(pAudPtr)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        grLastPicInfo\bLastPicContinuous = \bContinuous
        If (\nEndAt > 0) And (\bDoContinuous = #False)
          grLastPicInfo\nLastPicEndAt = \nEndAt
        EndIf
        grLastPicInfo\nLastPicTransType = \nPLTransType
        grLastPicInfo\nLastPicTransTime = \nPLTransTime
      EndIf
    EndWith
  EndIf
;   With grLastPicInfo
;     debugMsg(sProcName, "grLastPicInfo\bLastPicContinuous=" + strB(grLastPicInfo\bLastPicContinuous) +
;                         ", \nLastPicEndAt=" + \nLastPicEndAt +
;                         ", \nLastPicTransType=" + decodeTransType(\nLastPicTransType) +
;                         ", \nLastPicTransTime=" + \nLastPicTransTime)
;   EndWith
  
EndProcedure

Procedure calcCueTimeForRAI(pCuePtr)
  PROCNAMEC()
  Protected j, k
  Protected nCueTime, nSubTime, nAudTime
  Protected bSubTimeSet
  Protected bExitCue
  
  nCueTime = -99999
  If (aCue(pCuePtr)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(pCuePtr)\nCueState <= #SCS_CUE_FADING_OUT)
    If aCue(pCuePtr)\nCueState <> #SCS_CUE_HIBERNATING
      j = aCue(pCuePtr)\nFirstSubIndex
      While (j >= 0) And (bExitCue = #False)
        bSubTimeSet = #False
        nSubTime = -99999
        If aSub(j)\bSubTypeAorP
          If getPLRepeatActive(j) = #False
            If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
              nSubTime = aSub(j)\nPLCuePosition
              bSubTimeSet = #True
            EndIf
          EndIf
        ElseIf aSub(j)\bSubTypeHasAuds
          k = aSub(j)\nFirstPlayIndex
          If k >= 0
            With aAud(k)
              If (\bAudTypeF) Or ((\bAudTypeA) And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)) Or (\bAudTypeM)
                If \nAudState < #SCS_CUE_FADING_IN Or \nAudState = #SCS_CUE_PL_READY
                  ; the last aud in the play order hasn't been started yet so regard the whole sub
                  nSubTime = -99999
                  bExitCue = #True
                ElseIf (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                  If (\rCurrLoopInfo\bContainsLoop = #False) Or (\rCurrLoopInfo\bLoopReleased)
                    calcCuePositionForAud(k)
                    nAudTime = \nRelFilePos
                    If (nAudTime > nSubTime) And (nAudTime > 0)
                      nSubTime = nAudTime
                      bSubTimeSet = #True
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndWith
          EndIf
        EndIf
        If bSubTimeSet
          If (nSubTime > nCueTime) And (nSubTime > 0)
            nCueTime = nSubTime
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  EndIf
  
  ProcedureReturn nCueTime
  
EndProcedure

Procedure checkFileVisualWarningTimeAvailable(pCuePtr)
  ; Added 30Sep2022 11.9.6 following request from Masayuki Carvalho 22Sep2022
  PROCNAMEC()
  Protected bFileVisualWarningTimeAvailable, j, k
  
  If aCue(pCuePtr)\bSubTypeF
    bFileVisualWarningTimeAvailable = #True
  ElseIf aCue(pCuePtr)\bSubTypeA
    bFileVisualWarningTimeAvailable = #True
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bSubEnabled
          If \nAudCount > 1
            bFileVisualWarningTimeAvailable = #False
            Break
          Else
            k = \nFirstAudIndex
            If aAud(k)\nFileFormat <> #SCS_FILEFORMAT_VIDEO
              bFileVisualWarningTimeAvailable = #False
              Break
            EndIf
          EndIf
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  EndIf
  ProcedureReturn bFileVisualWarningTimeAvailable
EndProcedure

Procedure displayVisualWarningIfReqd()
  PROCNAMEC()
  Protected i, j, k, n
  Protected nVisualWarningCuePtr, nVisualWarningSubPtr
  Protected nCueTime, nSubTime, nAudTime, nAudPlayingPos
  Protected bSubTimeSet, bAudTimeSet
  Protected bExitCue
  Protected nProdVisualWarningTime, nCueVisualWarningTime
  Protected bCheckThisCue, bCheckThisAud
  Protected nActiveWindow
  Protected nCuePosTimeOffset = -2
  Protected bCountDown ; #True if count down, #False if count up (eg cue position or file position)
  Protected bFileVisualWarningTimeAvailable ; Added 30Sep2022 11.9.6
  
  ; debugMsg(sProcName, #SCS_START)
  
  If grProd\nVisualWarningTime > 0
    nProdVisualWarningTime = grProd\nVisualWarningTime                    ; > 0
    bCountDown = #True
    
  ElseIf grProd\nVisualWarningTime = #SCS_VWT_COUNT_DOWN_WHOLE_CUE      ; nb = -3
    nProdVisualWarningTime = 99999999
    bCountDown = #True
    
  ElseIf grProd\nVisualWarningTime = #SCS_VWT_CUEPOS                    ; nb = -4
    nProdVisualWarningTime = #SCS_VWT_CUEPOS
    
  ElseIf grProd\nVisualWarningTime = #SCS_VWT_FILEPOS                   ; nb = -5
    nProdVisualWarningTime = #SCS_VWT_FILEPOS
    
  ElseIf grProd\nVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET   ; nb = -6
    nProdVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
    
  EndIf
  
  If nProdVisualWarningTime <> 0
    ; debugMsg(sProcName, "nProdVisualWarningTime=" + nProdVisualWarningTime)
    nVisualWarningCuePtr = -1
    nVisualWarningSubPtr = -1
    For i = 1 To gnLastCue
      bExitCue = #False
      nCueTime = -99999
      bFileVisualWarningTimeAvailable = #False ; Added 30Sep2022 11.9.6
      If aCue(i)\bWarningBeforeEnd
        If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
          If aCue(i)\nCueState <> #SCS_CUE_HIBERNATING
            nCueVisualWarningTime = nProdVisualWarningTime
            If nProdVisualWarningTime = #SCS_VWT_FILEPOS Or nProdVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
              ; This visual warning time only available for cues with an audio file sub-cue, and then only if there is not also a video/image or playlist sub-cue.
              ; Otherwise, the warning time is changed to 'cue position'.
              ; Deleted 30Sep2022 11.9.6
              ; If aCue(i)\bSubTypeF = #False
              ;   nCueVisualWarningTime = #SCS_VWT_CUEPOS
              ; ElseIf aCue(i)\bSubTypeAorP
              ;   nCueVisualWarningTime = #SCS_VWT_CUEPOS
              ; EndIf
              ; End deleted 30Sep2022 11.9.6
              
              ; Added 30Sep2022 11.9.6 (replacing the above)
              bFileVisualWarningTimeAvailable = checkFileVisualWarningTimeAvailable(i)
              If bFileVisualWarningTimeAvailable = #False
                nCueVisualWarningTime = #SCS_VWT_CUEPOS
              EndIf
              ; End added 30Sep2022 11.9.6
              
            EndIf
            j = aCue(i)\nFirstSubIndex
            While (j >= 0) And (bExitCue = #False)
              bSubTimeSet = #False
              nSubTime = -99999
              If aSub(j)\bSubTypeAorP And bFileVisualWarningTimeAvailable = #False ; Changed 30Sep2022 11.9.6
                If getPLRepeatActive(j) = #False
                  If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
                    If bCountDown
                      nSubTime = calcPLTimeToGo(j)
                      bSubTimeSet = #True
                    Else
                      nSubTime = aSub(j)\nPLCuePosition
                      bSubTimeSet = #True
                    EndIf
                  EndIf
                EndIf
              ElseIf aSub(j)\bSubTypeHasAuds
                k = aSub(j)\nFirstPlayIndex
                If k >= 0
                  bAudTimeSet = #False
                  With aAud(k)
                    If (\bAudTypeF) Or
                       ((\bAudTypeA) And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)) Or
                       (\bAudTypeM)
                      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState = #SCS_CUE_PL_READY)
                        ; the last aud in the play order hasn't been started yet so regard the whole sub as not yet in the visual warning time
                        nSubTime = -99999
                        bExitCue = #True
                      ElseIf (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                        If grProd\nVisualWarningTime = #SCS_VWT_CUEPOS
                          If (\bAudTypeF) And (\nMaxLoopInfo >= 0)
                            nAudTime = (gqTimeNow - \qTimeAudRestarted) - \nTotalTimeOnPause
                            bAudTimeSet = #True
                          EndIf
                        EndIf
                        bCheckThisAud = #True
                        If bAudTimeSet = #False
                          Select grProd\nVisualWarningTime
                            Case #SCS_VWT_FILEPOS ; file position
                              ; no action here
                            Case #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET ; cue position plus optional time offset
                              ; no action here
                            Default
                              If (\bAudTypeF) And (\nMaxLoopInfo >= 0)
                                For n = 0 To \nMaxLoopInfo
                                  If \aLoopInfo(n)\bLoopReleased = #False
                                    bCheckThisAud = #False
                                    Break
                                  EndIf
                                Next n
                              EndIf
                          EndSelect
                        EndIf
                        If bCheckThisAud
                          If bAudTimeSet = #False
                            calcCuePositionForAud(k)
                            nAudPlayingPos = getAudPlayingPos(k)
                            If nCueVisualWarningTime = #SCS_VWT_CUEPOS
                              nAudTime = nAudPlayingPos
                              ; Added 4Nov2020 11.8.3.3ac - This was added so that the cue position displayed exactly matches the cue position of the first of the linked audio files
                              If \nLinkedToAudPtr >= 0
                                nAudTime = getAudPlayingPos(\nLinkedToAudPtr)
                              EndIf
                              ; End added 4Nov2020 11.8.3.3ac
                            ElseIf nCueVisualWarningTime = #SCS_VWT_FILEPOS
                              If \bAudTypeF
                                nAudTime = nAudPlayingPos + \nAbsMin
                              ElseIf \bAudTypeA
                                nAudTime = nAudPlayingPos + \nStartAt
                              Else
                                nAudTime = nAudPlayingPos
                              EndIf
                            ElseIf nCueVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
                              nAudTime = nAudPlayingPos
                              If \nCuePosTimeOffset > 0
                                nAudTime + \nCuePosTimeOffset
                                nCuePosTimeOffset = \nCuePosTimeOffset
                              EndIf
                            Else
                              nAudTime = \nCueDuration - nAudPlayingPos
                            EndIf
                            bAudTimeSet = #True ; not really necessary
                          EndIf
                          If nCueVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET Or nCueVisualWarningTime = #SCS_VWT_FILEPOS
                            nSubTime = nAudTime
                            bSubTimeSet = #True
                          ElseIf (nAudTime > nSubTime) And (nAudTime > 0) ; And (nCueVisualWarningTime <> -5)
                            nSubTime = nAudTime
                            bSubTimeSet = #True
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndWith
                EndIf
              EndIf
              If bSubTimeSet
                nVisualWarningSubPtr = j
                If nCueVisualWarningTime = #SCS_VWT_FILEPOS
                  nCueTime = nSubTime
                ElseIf nCueVisualWarningTime = #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
                  nCueTime = nSubTime
                ElseIf nCueVisualWarningTime = #SCS_VWT_CUEPOS
                  If (nSubTime > nCueTime) And (nSubTime > 0)
                    nCueTime = nSubTime
                  EndIf
                Else
                  If (nSubTime > nCueTime) And (nSubTime > 0)
                    nCueTime = nSubTime
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndIf
      EndIf
      If nCueTime >= 0
        If bCountDown
          If nCueTime <= nCueVisualWarningTime
            nVisualWarningCuePtr = i
            Break
          EndIf
        Else
          If nCueTime > 0
            nVisualWarningCuePtr = i
            Break
          EndIf
        EndIf
      EndIf
      ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", nCueTime=" + nCueTime)
    Next i
  EndIf
  
  ; debugMsg(sProcName, "nVisualWarningCuePtr=" + getCueLabel(nVisualWarningCuePtr))
  If nVisualWarningCuePtr > 0
    nActiveWindow = GetActiveWindow()
    If IsWindow(#WNE) = #False
      WNE_Form_Load(#True)
    EndIf
    If nCueVisualWarningTime <> #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET
      nCuePosTimeOffset = -2
    EndIf
    WNE_displayNearEndTime(nCueTime, nVisualWarningCuePtr, nVisualWarningSubPtr, nCuePosTimeOffset, bFileVisualWarningTimeAvailable) ; Changed 30Sep2022 11.9.6
    If getWindowVisible(#WNE) = #False
      setWindowVisible(#WNE, #True)
    EndIf
    If (nActiveWindow <> #WNE) And (IsWindow(nActiveWindow))
      ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(" + decodeWindow(nActiveWindow) + ")")
      SAW(nActiveWindow)
    EndIf
  Else
    If IsWindow(#WNE)
      If getWindowVisible(#WNE)
        setWindowVisible(#WNE, #False)
      EndIf
    EndIf
  EndIf

EndProcedure

Procedure startTimeOfDayClock()
  Protected bNewMenuItemState
  
  ; Start the Time of Day Clock
  
  ; Set the Menu Item
  If GetMenuItemState(#WMN_mnuView, #WMN_mnuViewClock) = 0
    bNewMenuItemState = #True
  Else
    bNewMenuItemState = #False
  EndIf
  SetMenuItemState(#WMN_mnuView, #WMN_mnuViewClock, bNewMenuItemState)
  If bNewMenuItemState
    If IsWindow(#WCL) = #False
      WCL_Form_Load(#True)
    EndIf
  Else
    If IsWindow(#WCL)
      WCL_Form_Unload()
    EndIf
  EndIf
  grMisc\bClockDisplayed = bNewMenuItemState ; Added 3Dec2022 11.9.7ar

EndProcedure

Procedure displayTimeOfDayClockIfReqd()
  ; Added 3Dec2022 11.9.7ar
  
  With grMisc
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewClock, \bClockDisplayed)
    If \bClockDisplayed
      If IsWindow(#WCL) = #False
        WCL_Form_Load(#True)
      EndIf
    Else
      If IsWindow(#WCL)
        WCL_Form_Unload()
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure clearCountdownClock()
  If GetMenuItemState(#WMN_mnuView, #WMN_mnuViewCountdown) <> 0
    SetMenuItemState(#WMN_mnuView, #WMN_mnuViewCountdown, #False)
  EndIf
  If IsWindow(#WCD)
    WCD_Form_Unload()
  EndIf
  gnCountDownSessionTime = 0 
  MessageRequester(Lang("TIMERS","CountDownTitle"), Lang("TIMERS", "CountdownCleared"), #PB_MessageRequester_Ok)
EndProcedure

Procedure startCountdownClock()
  Protected bNewMenuItemState
 
  ; Start the Countdown Clock
  If GetMenuItemState(#WMN_mnuView, #WMN_mnuViewCountdown) = 0
    bNewMenuItemState = #True
  Else
    bNewMenuItemState = #False
  EndIf
  SetMenuItemState(#WMN_mnuView, #WMN_mnuViewCountdown, bNewMenuItemState)
  If bNewMenuItemState
    If IsWindow(#WCD) = #False
      WCD_Form_Load(#True)
    EndIf
  Else
    If IsWindow(#WCD)
      WCD_Form_Unload()
    EndIf
  EndIf

EndProcedure

Procedure setDisplayPanFlags()
  PROCNAMEC()
  Protected d, i, j, k, n
  Protected sMyAudioLogicalDev.s
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeF
        k = aSub(j)\nFirstAudIndex
        If k >= 0
          With aAud(k)
            If \nFirstSoundingDev >= 0
              For d = \nFirstSoundingDev To \nLastSoundingDev
                \bDisplayPan[d] = #False
                sMyAudioLogicalDev = \sLogicalDev[d]
                If sMyAudioLogicalDev
                  For n = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
                    If grProd\aAudioLogicalDevs(n)\sLogicalDev = sMyAudioLogicalDev
                      If grProd\aAudioLogicalDevs(n)\nNrOfOutputChans = 2
                        \bDisplayPan[d] = #True
                      EndIf
                      Break
                    EndIf
                  Next n
                EndIf
              Next d
            EndIf
          EndWith
        EndIf
        
      ElseIf aSub(j)\bSubTypeAorP
        With aSub(j)
          For d = 0 To grLicInfo\nMaxAudDevPerSub
            \bSubDisplayPan[d] = #False
            sMyAudioLogicalDev = \sPLLogicalDev[d]
            If sMyAudioLogicalDev
              For n = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
                If grProd\aAudioLogicalDevs(n)\sLogicalDev = sMyAudioLogicalDev
                  If grProd\aAudioLogicalDevs(n)\nNrOfOutputChans = 2
                    \bSubDisplayPan[d] = #True
                  EndIf
                  Break
                EndIf
              Next n
            EndIf
          Next d
          k = \nFirstAudIndex
          While k >= 0
            For d = 0 To grLicInfo\nMaxAudDevPerSub
              aAud(k)\bDisplayPan[d] = \bSubDisplayPan[d]
            Next d
            k = aAud(k)\nNextAudIndex
          Wend
        EndWith
        
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
EndProcedure

Procedure listCueStates(pCuePtr=-1, bCuesOnly=#False)
  PROCNAMEC()
  Protected i, j, k
  Protected nFirstCue, nLastCue, sLine.s
  
  If gbDoDebug = #False
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, #SCS_BLANK)
  
  If pCuePtr = -1
    nFirstCue = 1
    nLastCue = gnLastCue
  Else
    nFirstCue = pCuePtr
    nLastCue = pCuePtr
  EndIf
  
  For i = nFirstCue To nLastCue
    
    With aCue(i)
      If aCue(i)\bTimeCueStoppedSet
        debugMsg(sProcName, aCue(i)\sCue + ", nCueState=" + decodeCueState(aCue(i)\nCueState) + ", \qTimeCueStopped=" + traceTime(aCue(i)\qTimeCueStopped) +
                            ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) +
                            ", \bCueEnded=" + strB(\bCueEnded))
      Else
        debugMsg(sProcName, aCue(i)\sCue + ", nCueState=" + decodeCueState(aCue(i)\nCueState) +
                            ", \nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) +
                            ", \bCueEnded=" + strB(\bCueEnded))
      EndIf
    EndWith
    
    If bCuesOnly = #False
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        sLine = "  " + aSub(j)\sSubLabel + ", nSubState=" + decodeCueState(aSub(j)\nSubState)
        If aSub(j)\bSubTypeU And aSub(j)\nMTCLinkedToAFSubPtr >= 0
          sLine + ", \nMTCLinkedToAFSubPtr=" + getSubLabel(aSub(j)\nMTCLinkedToAFSubPtr)
        EndIf
        debugMsg(sProcName, sLine)
        If aSub(j)\bSubTypeHasAuds
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            With aAud(k)
              debugMsg(sProcName, "    " + \sAudLabel + ", nAudState=" + decodeCueState(\nAudState) + ", nFileState=" + decodeFileState(\nFileState))
            EndWith
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  ; debugMsg(sProcName, "nMainBufferAudPtr=" + getAudLabel(nMainBufferAudPtr) + ", nMainSecondaryAudPtr=" + getAudLabel(nMainSecondaryAudPtr) + ", nMainPrimaryAudPtr=" + getAudLabel(nMainPrimaryAudPtr))
  ; debugMsg(sProcName, #SCS_BLANK)
  
EndProcedure

Procedure getNextManualCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected i, nNextManualCue
  
  nNextManualCue = -1
  Select grProd\nRunMode
    Case #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND, #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
      ; do not set next manual cue
    Default
      For i = (pCuePtr + 1) To gnLastCue
        If aCue(i)\bCueCurrentlyEnabled
          If (aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN) Or (aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF)
            nNextManualCue = i
            Break
          EndIf
        EndIf
      Next i
  EndSelect
  
  ProcedureReturn nNextManualCue
  
EndProcedure

Procedure getEarliestPlayingSubTypeF()
  ; Also checks that the cue will be displayed in the cue panels
  ; PROCNAMEC()
  Protected i, j, qEarliestTimeStarted.q, nEarliestPlayingSubPtr
  
  
  nEarliestPlayingSubPtr = -1
  For i = 1 To gnLastCue
    With aCue(i)
      ; If \bSubTypeAorF
      If \bSubTypeF ; continue with just type F until we have sorted out better how to handle a video audio fader
        If \nCueState >= #SCS_CUE_FADING_IN And \nCueState <= #SCS_CUE_FADING_OUT And \nCueState <> #SCS_CUE_HIBERNATING
          If \nHideCueOpt <> #SCS_HIDE_CUE_PANEL And \nHideCueOpt <> #SCS_HIDE_ENTIRE_CUE
            j = \nFirstSubIndex
            While j >= 0
              ; If aSub(j)\bSubTypeAorF And aSub(j)\bSubEnabled
              If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled ; continue with just type F until we have sorted out better how to handle a video audio fader
                If aSub(j)\nSubState >= #SCS_CUE_FADING_IN And aSub(j)\nSubState <= #SCS_CUE_FADING_OUT
                  If aSub(j)\qTimeSubStarted < qEarliestTimeStarted Or nEarliestPlayingSubPtr < 0
                    qEarliestTimeStarted = aSub(j)\qTimeSubStarted
                    nEarliestPlayingSubPtr = j
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndIf
      EndIf
    EndWith
  Next i
  
  ProcedureReturn nEarliestPlayingSubPtr ; will return -1 if no SubTypeF's currently playing
  
EndProcedure

Procedure setNonLinearCueFlags()
  PROCNAMEC()
  Protected i
  Protected bNonLinearCue
  
  For i = 1 To gnLastCue
    bNonLinearCue = #False
    Select grProd\nRunMode
      Case #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND, #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
        bNonLinearCue = #True
      Case #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND, #SCS_RUN_MODE_BOTH_PREOPEN_ALL
        If Trim(aCue(i)\sMidiCue)
          bNonLinearCue = #True
        EndIf
    EndSelect
    With aCue(i)
      \bNonLinearCue = bNonLinearCue
      If (\bHotkey And \nActivationMethod <> #SCS_ACMETH_HK_STEP) Or (\bExtAct) Or (\bCallableCue) Or ((bNonLinearCue) And (grProd\bPreOpenNonLinearCues) And (\nActivationMethod <> #SCS_ACMETH_TIME))
        \bKeepOpen = #True
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bKeepOpen=" + strB(aCue(i)\bKeepOpen) + ", \nCueState=" + decodeCueState(\nCueState))
        ; Added 27Dec2021 11.8.6dc as this was already in macSetDerivedCueFields()
        If grProd\bNoPreLoadVideoHotkeys
          If \bSubTypeA
            \bKeepOpen = #False
          EndIf
        EndIf
        ; End added 27Dec2021 11.8.6dc
      Else
        \bKeepOpen = #False
      EndIf
    EndWith
  Next i
  
EndProcedure

Procedure checkDevTypePresent(nDevGrp, nDevType, bInDevChgs)
  PROCNAMEC()
  Protected d
  Protected bDevTypePresent
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevType=" + decodeDevType(nDevType) + ", bInDevChgs=" + strB(bInDevChgs))
  
  If bInDevChgs
    Select nDevGrp
      Case #SCS_DEVGRP_LIGHTING
        For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
          If grProdForDevChgs\aLightingLogicalDevs(d)\nDevType = nDevType
            bDevTypePresent = #True
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CTRL_SEND
        For d = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
          If grProdForDevChgs\aCtrlSendLogicalDevs(d)\nDevType = nDevType
            bDevTypePresent = #True
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CUE_CTRL
        For d = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev ; grLicInfo\nMaxCueCtrlDev
          If grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDevType = nDevType
            bDevTypePresent = #True
            Break
          EndIf
        Next d
        
    EndSelect
    
  Else
    Select nDevGrp
      Case #SCS_DEVGRP_LIGHTING
        For d = 0 To grProd\nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
          If grProd\aLightingLogicalDevs(d)\nDevType = nDevType
            bDevTypePresent = #True
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CTRL_SEND
        For d = 0 To grProd\nMaxCtrlSendLogicalDev
          If grProd\aCtrlSendLogicalDevs(d)\nDevType = nDevType
            bDevTypePresent = #True
            Break
          EndIf
        Next d
        
      Case #SCS_DEVGRP_CUE_CTRL
        For d = 0 To grProd\nMaxCueCtrlLogicalDev ; grLicInfo\nMaxCueCtrlDev
          If grProd\aCueCtrlLogicalDevs(d)\nDevType = nDevType
            bDevTypePresent = #True
            Break
          EndIf
        Next d
        
    EndSelect
    
  EndIf
  
  If bDevTypePresent = #False
    If nDevType = #SCS_DEVTYPE_CC_MIDI_IN
      debugMsg(sProcName, "grCtrlSetup\sCtrlMidiInPort=" + grCtrlSetup\sCtrlMidiInPort)
      If grCtrlSetup\sCtrlMidiInPort
        bDevTypePresent = #True
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + strB(bDevTypePresent))
  ProcedureReturn bDevTypePresent

EndProcedure

Procedure setMidiEnabled(bInDevChgs=#False)
  PROCNAMEC()
  Protected nMidiInEnabled, nMidiOutEnabled

  debugMsg(sProcName, #SCS_START)
  
  If gbInOptionsWindow
    nMidiInEnabled = mrSession\nMidiInEnabled
    nMidiOutEnabled = mrSession\nMidiOutEnabled
  Else
    nMidiInEnabled = grSession\nMidiInEnabled
    nMidiOutEnabled = grSession\nMidiOutEnabled
  EndIf
  
  If checkDevTypePresent(#SCS_DEVGRP_CUE_CTRL, #SCS_DEVTYPE_CC_MIDI_IN, bInDevChgs)
    If nMidiInEnabled = #SCS_DEVTYPE_NOT_REQD
      nMidiInEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nMidiInEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If checkDevTypePresent(#SCS_DEVGRP_CTRL_SEND, #SCS_DEVTYPE_CS_MIDI_OUT, bInDevChgs)
    If nMidiOutEnabled = #SCS_DEVTYPE_NOT_REQD
      nMidiOutEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
    nMidiInEnabled = #SCS_DEVTYPE_ENABLED ; enable MidiIn if MidiOut enabled so that MIDI/NRPN capture is available - see also WOP_deviceEnabled_Click()
  Else
    nMidiOutEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If grLicInfo\bFMAvailable
    If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
      If grFMOptions\bBackupIgnoreCSMIDI
        nMidiOutEnabled = #SCS_DEVTYPE_NOT_REQD
      EndIf
      If grFMOptions\bBackupIgnoreCCDevs
        nMidiInEnabled = #SCS_DEVTYPE_NOT_REQD
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, "nMidiInEnabled=" + nMidiInEnabled + ", nMidiOutEnabled=" + nMidiOutEnabled)
  
  If gbInOptionsWindow
    mrSession\nMidiInEnabled = nMidiInEnabled
    mrSession\nMidiOutEnabled = nMidiOutEnabled
  Else
    grSession\nMidiInEnabled = nMidiInEnabled
    grSession\nMidiOutEnabled = nMidiOutEnabled
    WMN_setMidiEtcDisabledLabel()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setRS232Enabled(bInDevChgs=#False)
  PROCNAMEC()
  Protected nRS232InEnabled, nRS232OutEnabled
  
  debugMsg(sProcName, #SCS_START + ", bInDevChgs=" + strB(bInDevChgs) + ", gbInOptionsWindow=" + strB(gbInOptionsWindow))
  
  If gbInOptionsWindow
    nRS232InEnabled = mrSession\nRS232InEnabled
    nRS232OutEnabled = mrSession\nRS232OutEnabled
  Else
    nRS232InEnabled = grSession\nRS232InEnabled
    nRS232OutEnabled = grSession\nRS232OutEnabled
  EndIf
  
  ; debugMsg(sProcName, "nRS232InEnabled=" + nRS232InEnabled + ", nRS232OutEnabled=" + nRS232OutEnabled)
  
  If checkDevTypePresent(#SCS_DEVGRP_CUE_CTRL, #SCS_DEVTYPE_CC_RS232_IN, bInDevChgs)
    If nRS232InEnabled = #SCS_DEVTYPE_NOT_REQD
      nRS232InEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nRS232InEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf

  If checkDevTypePresent(#SCS_DEVGRP_CTRL_SEND, #SCS_DEVTYPE_CS_RS232_OUT, bInDevChgs)
    If nRS232OutEnabled = #SCS_DEVTYPE_NOT_REQD
      nRS232OutEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nRS232OutEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If grLicInfo\bFMAvailable
    If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
      If grFMOptions\bBackupIgnoreCCDevs
        nRS232InEnabled = #SCS_DEVTYPE_NOT_REQD
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, "nRS232InEnabled=" + nRS232InEnabled + ", nRS232OutEnabled=" + nRS232OutEnabled)
  
  If gbInOptionsWindow
    mrSession\nRS232InEnabled = nRS232InEnabled
    mrSession\nRS232OutEnabled = nRS232OutEnabled
  Else
    grSession\nRS232InEnabled = nRS232InEnabled
    grSession\nRS232OutEnabled = nRS232OutEnabled
    WMN_setMidiEtcDisabledLabel()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure setDMXEnabled(bInDevChgs=#False)
  PROCNAMEC()
  Protected nDMXInEnabled, nDMXOutEnabled
  
  debugMsg(sProcName, #SCS_START + ", bInDevChgs=" + strB(bInDevChgs))
  
  If gbInOptionsWindow
    nDMXInEnabled = mrSession\nDMXInEnabled
    nDMXOutEnabled = mrSession\nDMXOutEnabled
  Else
    nDMXInEnabled = grSession\nDMXInEnabled
    nDMXOutEnabled = grSession\nDMXOutEnabled
  EndIf
  debugMsg(sProcName, "nDMXInEnabled=" + nDMXInEnabled + ", nDMXOutEnabled=" + nDMXOutEnabled)
  
  If checkDevTypePresent(#SCS_DEVGRP_CUE_CTRL, #SCS_DEVTYPE_CC_DMX_IN, bInDevChgs)
    If nDMXInEnabled = #SCS_DEVTYPE_NOT_REQD
      nDMXInEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nDMXInEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If checkDevTypePresent(#SCS_DEVGRP_LIGHTING, #SCS_DEVTYPE_LT_DMX_OUT, bInDevChgs)
    If nDMXOutEnabled = #SCS_DEVTYPE_NOT_REQD
      nDMXOutEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nDMXOutEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If grLicInfo\bFMAvailable
    If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
      If grFMOptions\bBackupIgnoreLightingDMX
        nDMXOutEnabled = #SCS_DEVTYPE_NOT_REQD
      EndIf
      If grFMOptions\bBackupIgnoreCCDevs
        nDMXInEnabled = #SCS_DEVTYPE_NOT_REQD
      EndIf
    EndIf
  EndIf
  
  If gbInOptionsWindow
    mrSession\nDMXInEnabled = nDMXInEnabled
    mrSession\nDMXOutEnabled = nDMXOutEnabled
  Else
    grSession\nDMXInEnabled = nDMXInEnabled
    grSession\nDMXOutEnabled = nDMXOutEnabled
    WMN_setMidiEtcDisabledLabel()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grSession\nDMXInEnabled=" + grSession\nDMXInEnabled + ", grSession\nDMXOutEnabled=" + grSession\nDMXOutEnabled)
  
EndProcedure

Procedure setNetworkEnabled(bInDevChgs=#False)
  PROCNAMEC()
  Protected nNetworkInEnabled, nNetworkOutEnabled
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gbInOptionsWindow
    nNetworkInEnabled = mrSession\nNetworkInEnabled
    nNetworkOutEnabled = mrSession\nNetworkOutEnabled
  Else
    nNetworkInEnabled = grSession\nNetworkInEnabled
    nNetworkOutEnabled = grSession\nNetworkOutEnabled
  EndIf
  
  If checkDevTypePresent(#SCS_DEVGRP_CUE_CTRL, #SCS_DEVTYPE_CC_NETWORK_IN, bInDevChgs)
    If nNetworkInEnabled = #SCS_DEVTYPE_NOT_REQD
      nNetworkInEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nNetworkInEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If checkDevTypePresent(#SCS_DEVGRP_CTRL_SEND, #SCS_DEVTYPE_CS_NETWORK_OUT, bInDevChgs)
    If nNetworkOutEnabled = #SCS_DEVTYPE_NOT_REQD
      nNetworkOutEnabled = #SCS_DEVTYPE_ENABLED
    EndIf
  Else
    nNetworkOutEnabled = #SCS_DEVTYPE_NOT_REQD
  EndIf
  
  If grLicInfo\bFMAvailable
    If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
      If grFMOptions\bBackupIgnoreCSNetwork
        nNetworkOutEnabled = #SCS_DEVTYPE_NOT_REQD
      EndIf
    EndIf
    ; NB do not test here for grFMOptions\bBackupIgnoreCCDevs as NetworkIn MUST be enabled to receive commands from the Primary computer
  EndIf
  
  If gbInOptionsWindow
    mrSession\nNetworkInEnabled = nNetworkInEnabled
    mrSession\nNetworkOutEnabled = nNetworkOutEnabled
  Else
    grSession\nNetworkInEnabled = nNetworkInEnabled
    grSession\nNetworkOutEnabled = nNetworkOutEnabled
    WMN_setMidiEtcDisabledLabel()
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure.s getSubFileNameForGrid(pSubPtr)
  ; Loads filename or other info for cue list in main window. 'Other info' is for non-file cue types, such as lighting.
  PROCNAMEC()
  Protected sFileName.s
  Protected sFullFileName.s, sDriveRootFolder.s, sTempoEtcInfo.s
  Protected nDriveType
  Protected bDoContinuous, bContinuous, sQualifier.s
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      ; debugMsg(sProcName, "\sSubType=" + \sSubType + ", \bSubTypeF=" + strB(\bSubTypeF) + ", \bSubTypeA=" + strB(\bSubTypeA) + ", \nFirstAudIndex=" + \nFirstAudIndex)
      If \bSubTypeA
        If \bSubPlaceHolder
          sFileName = grText\sTextPlaceHolder
        ElseIf (\nAudCount = 1) And (\nFirstAudIndex >= 0)
          sFullFileName = aAud(\nFirstAudIndex)\sFileName
          sDriveRootFolder = getDriveRootFolder(sFullFileName)
          nDriveType = getDriveType(sDriveRootFolder)
          Select nDriveType
            Case #DRIVE_REMOTE, #DRIVE_CDROM, #DRIVE_REMOVABLE
              sFileName = sDriveRootFolder + "...\" + GetFilePart(sFullFileName)
            Default
              sFileName = GetFilePart(sFullFileName)
          EndSelect
        Else
          sFileName = Str(\nAudCount) + " files"
        EndIf
        If \nLastPlayIndex >= 0
          If aAud(\nLastPlayIndex)\nFileFormat = #SCS_FILEFORMAT_PICTURE
            bDoContinuous = aAud(\nLastPlayIndex)\bDoContinuous
          EndIf
        EndIf
        If (getPLRepeatActive(pSubPtr)) And (bDoContinuous = #False)
          sFileName + " (" + LCase(grText\sTextRepeat) + ")"
        EndIf
        ; debugMsg(sProcName, "sFileName=" + sFileName)
        
      ElseIf \bSubTypeF
        If \nFirstAudIndex >= 0
          sFullFileName = aAud(\nFirstAudIndex)\sFileName
          sDriveRootFolder = getDriveRootFolder(sFullFileName)
          nDriveType = getDriveType(sDriveRootFolder)
          Select nDriveType
            Case #DRIVE_REMOTE, #DRIVE_CDROM, #DRIVE_REMOVABLE
              sFileName = sDriveRootFolder + "...\" + GetFilePart(sFullFileName)
            Default
              sFileName = GetFilePart(sFullFileName)
          EndSelect
          sTempoEtcInfo = buildTempoEtcInfo(pSubPtr)
          If sTempoEtcInfo
            sFileName + " (" + sTempoEtcInfo + ")"
          EndIf
        EndIf
        
      ElseIf \bSubTypeG
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeI
        If \nFirstAudIndex >= 0
          sFileName = buildLiveInputDescr(pSubPtr)
        EndIf
        
      ElseIf \bSubTypeJ
        sFileName = WQJ_buildEnableDisableDesc(pSubPtr)
        
      ElseIf \bSubTypeK
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeL
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeM
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeP
        If \bSubPlaceHolder
          sFileName = grText\sTextPlaceHolder
        ElseIf (\nAudCount = 1) And (\nFirstAudIndex >= 0)
          sFullFileName = aAud(\nFirstAudIndex)\sFileName
          sDriveRootFolder = getDriveRootFolder(sFullFileName)
          nDriveType = getDriveType(sDriveRootFolder)
          Select nDriveType
            Case #DRIVE_REMOTE, #DRIVE_CDROM, #DRIVE_REMOVABLE
              sFileName = sDriveRootFolder + "...\" + GetFilePart(sFullFileName)
            Default
              sFileName = GetFilePart(sFullFileName)
          EndSelect
        Else
          sFileName = Str(\nAudCount) + " tracks"
        EndIf
        If (\bPLRandom) And (\nAudCount > 1)
          sFileName + ": " + \sPlayOrder
        Else
          sQualifier = ""
          If \bPLRepeat
            If \nLastPlayIndex >= 0
              If aAud(\nLastPlayIndex)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                bContinuous = aAud(\nLastPlayIndex)\bContinuous
              EndIf
            EndIf
            If bContinuous = #False
              sQualifier = LCase(grText\sTextRepeat)
            EndIf
          EndIf
          If \bPLSavePos
            If sQualifier
              sQualifier + ", "
            EndIf
            sQualifier + LCase(Lang("Common", "Save"))
          EndIf
          If sQualifier
            sFileName + " (" + sQualifier + ")"
          EndIf
        EndIf
        
      ElseIf \bSubTypeQ
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeR
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeS
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeT
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      ElseIf \bSubTypeU
        sFileName = loadOtherInfoTextForSub(pSubPtr)
        
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn sFileName
  
EndProcedure

Procedure.s getSubFileTypeForGrid(pSubPtr)
  PROCNAMEC()
  Protected sFileType.s
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeHasAuds
        If \nFirstAudIndex >= 0
          sFileType = aAud(\nFirstAudIndex)\sFileType
        EndIf
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn sFileType
  
EndProcedure

Procedure.s getSubDBLevelForGrid(pSubPtr)
  PROCNAMEC()
  Protected sDBLevel.s
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeHasAuds
        If \nFirstAudIndex >= 0
          ; sDBLevel = aAud(\nFirstAudIndex)\sDBLevel[0]  ; commenetd out because for video cues this incorrectly shows -INF
          sDBLevel = convertBVLevelToDBString(aAud(\nFirstAudIndex)\fSavedBVLevel[0])
        EndIf
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn sDBLevel
  
EndProcedure

Procedure getSubLength(pSubPtr, bIgnoreContinuous=#False, pCallCueSubPtr=-1)
PROCNAMECS(pSubPtr)
  Protected bDoContinuous, nLength, nFadeTime, nDelayTime
  Protected i, j, k
  Protected h, m, n
  Protected nDMXSubLength, nFadeOutOthersTime
  
  ; debugMsg(sProcName, #SCS_START + ", bIgnoreContinuous=" + strB(bIgnoreContinuous) + ", pCallCueSubPtr=" + getSubLabel(pCallCueSubPtr))
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      ; debugMsg(sProcName, "\sSubType=" + \sSubType)
      If \bSubTypeA
        If \nPLTotalTime = 0
          calcPLTotalTime(pSubPtr)
        EndIf
        nLength = \nPLTotalTime
        If \nLastPlayIndex >= 0
          bDoContinuous = aAud(\nLastPlayIndex)\bDoContinuous
        EndIf
        
      ElseIf \bSubTypeE
        If (\bMemoContinuous = #False) And (\nMemoDisplayTime > 0)
          nLength = \nMemoDisplayTime
        EndIf
        
      ElseIf \bSubTypeF
        If \nFirstAudIndex >= 0
          nLength = aAud(\nFirstAudIndex)\nCueDuration
          ; debugMsg(sProcName, "aAud(" + getAudLabel(\nFirstAudIndex) + ")\nCueDuration=" + aAud(\nFirstAudIndex)\nCueDuration)
        EndIf
        
      ElseIf \bSubTypeK
        If aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_EXT_FADER
          nLength = 0
        Else
          nDMXSubLength = DMX_getSubLength(@aSub(pSubPtr), @grProd, pCallCueSubPtr)
          If \bChase
            bDoContinuous = #True
          Else
            Select \nLTEntryType
              Case #SCS_LT_ENTRY_TYPE_BLACKOUT
                nLength = nDMXSubLength
                
              Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                n = 0
                For m = 0 To (\aChaseStep(n)\nDMXSendItemCount - 1)
                  If \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
                    nDelayTime = \aChaseStep(n)\aDMXSendItem(m)\nDMXDelayTime
                  EndIf
                  nFadeTime = \aChaseStep(n)\aDMXSendItem(m)\nDMXFadeTime
                  If nFadeTime = -2
                    nFadeTime = nDMXSubLength
                  EndIf
                  If (nDelayTime + nFadeTime) > nLength
                    nLength = nDelayTime + nFadeTime
                  EndIf
                Next m
                
              Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                If \nMaxFixture >= 0
                  nLength = nDMXSubLength
                EndIf
            EndSelect
            Select \nLTEntryType
              Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                nFadeOutOthersTime = DMX_getFadeOutOthersTimeForSub(@aSub(pSubPtr), @grProd)
                If nFadeOutOthersTime > nLength
                  nLength = nFadeOutOthersTime
                EndIf
            EndSelect
          EndIf
        EndIf
;         If \bSubEnabled And aCue(\nCueIndex)\bCueEnabled
;           debugMsg0(sProcName, "\nLTEntryType=" + decodeLTEntryType(\nLTEntryType) + ", nLength=" + nLength)
;         EndIf
        
      ElseIf \bSubTypeL
        Select \nLCAction
          Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
            nLength = \nLCActionTime
          Default
            If \nLCTimeMax >= 0
              nLength = \nLCTimeMax
            EndIf
        EndSelect
        
      ElseIf \bSubTypeM
        If \nFirstAudIndex >= 0
          nLength = aAud(\nFirstAudIndex)\nCueDuration
        EndIf
        
      ElseIf \bSubTypeP
        If \nPLTotalTime = 0
          calcPLTotalTime(pSubPtr)
        EndIf
        nLength = \nPLTotalTime
        
      ElseIf \bSubTypeQ
        If \nCallCueAction = #SCS_QQ_CALLCUE
          ; debugMsg(sProcName, "\sCallCue=" + \sCallCue + ", getCuePtr(" + \sCallCue + ")=" + getCuePtr(\sCallCue) + ", \nCallCuePtr=" + \nCallCuePtr)
          If \nCallCuePtr >= 0
            nLength = getCueLength(\nCallCuePtr, pSubPtr)
          EndIf
        EndIf
            
      ElseIf \bSubTypeS
        If \nSFRTimeOverride > 0
          nLength = \nSFRTimeOverride
        Else
          For h = 0 To #SCS_MAX_SFR
            Select \nSFRAction[h]
              Case #SCS_SFR_ACT_FADEOUT, #SCS_SFR_ACT_FADEOUTHIB
                Select \nSFRCueType[h]
                  Case #SCS_SFR_CUE_SEL
                    i = \nSFRCuePtr[h]
                    If i >= 0
                      j = aCue(i)\nFirstSubIndex
                      While j >= 0
                        If aSub(j)\bSubTypeHasAuds And aSub(j)\bSubEnabled
                          If aSub(j)\bSubTypeAorP And aSub(j)\nPLFadeOutTime >= 0
                            nLength = aSub(j)\nPLFadeOutTime
                          Else ; includes all subtypes that have Auds, including A and P
                            k = aSub(j)\nFirstAudIndex
                            While k >= 0
                              If (aAud(k)\bAudPlaceHolder = #False) And (aAud(k)\nFadeOutTime > nLength)
                                nLength = aAud(k)\nFadeOutTime
                              EndIf
                              k = aAud(k)\nNextAudIndex
                            Wend
                          EndIf
                        EndIf
                        j = aSub(j)\nNextSubIndex
                      Wend
                    EndIf
                EndSelect
              Case #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT
                Select \nSFRCueType[h]
                  Case #SCS_SFR_CUE_SEL
                    i = \nSFRCuePtr[h]
                    If i >= 0
                      j = aCue(i)\nFirstSubIndex
                      While j >= 0
                        If aSub(j)\bSubTypeHasAuds And aSub(j)\bSubEnabled
                          If aSub(j)\bSubTypeAorP And aSub(j)\nPLFadeInTime >= 0
                            nLength = aSub(j)\nPLFadeInTime
                          Else ; includes all subtypes that have Auds, including A and P
                            k = aSub(j)\nFirstAudIndex
                            While k >= 0
                              If (aAud(k)\bAudPlaceHolder = #False) And (aAud(k)\nFadeInTime > nLength)
                                nLength = aAud(k)\nFadeInTime
                              EndIf
                              k = aAud(k)\nNextAudIndex
                            Wend
                          EndIf
                        EndIf
                        j = aSub(j)\nNextSubIndex
                      Wend
                    EndIf
                EndSelect
            EndSelect
          Next h
        EndIf
        
      ElseIf \bSubTypeU
        If \nMTCDuration > 0
          nLength = \nMTCDuration
        EndIf
        
      EndIf
      
      If bIgnoreContinuous = #False
        If bDoContinuous
          nLength = 0
        EndIf
      EndIf
      ; debugMsg(sProcName, "returning nLength=" + nLength + ", bDoContinuous=" + strB(bDoContinuous))
    EndWith
  EndIf
  
  ProcedureReturn nLength
  
EndProcedure

Procedure.s getSubLengthForGrid(pSubPtr)
  PROCNAMEC()
  Protected bDoContinuous, nLength, sLength.s
  Protected nDelayTime, nFadeTime
  Protected i, j, k
  Protected h, m, n
  Protected nDMXSubLength, nFadeOutOthersTime
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeA
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nPLTotalTime=" + \nPLTotalTime + ", #SCS_CONTINUOUS_LENGTH=" + #SCS_CONTINUOUS_LENGTH)
        nLength = \nPLTotalTime
        If \nFirstAudIndex >= 0
          bDoContinuous = aAud(\nFirstAudIndex)\bDoContinuous
        EndIf
        
      ElseIf \bSubTypeE
        If (\bMemoContinuous = #False) And (\nMemoDisplayTime > 0)
          nLength = \nMemoDisplayTime
        EndIf
        
      ElseIf \bSubTypeF
        If \nFirstAudIndex >= 0
          nLength = aAud(\nFirstAudIndex)\nCueDuration
        EndIf
        
      ElseIf \bSubTypeK
        nDMXSubLength = DMX_getSubLength(@aSub(pSubPtr), @grProd)
        If \bChase
          bDoContinuous = #True
        Else
          Select \nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
              For n = 0 To \nMaxChaseStepIndex
                For m = 0 To (\aChaseStep(n)\nDMXSendItemCount - 1)
                  If \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
                    nDelayTime = \aChaseStep(n)\aDMXSendItem(m)\nDMXDelayTime
                  Else
                    nDelayTime = 0
                  EndIf
                  nFadeTime = \aChaseStep(n)\aDMXSendItem(m)\nDMXFadeTime
                  If nFadeTime = -2
                    nFadeTime = nDMXSubLength
                  EndIf
                  If (nDelayTime + nFadeTime) > nLength
                    nLength = nDelayTime + nFadeTime
                  EndIf
                Next m
              Next n
            Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
              nLength = nDMXSubLength
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS, #SCS_LT_ENTRY_TYPE_BLACKOUT
              If \nMaxFixture >= 0
                nLength = nDMXSubLength
              EndIf
          EndSelect
          nFadeOutOthersTime = DMX_getFadeOutOthersTimeForSub(@aSub(pSubPtr), @grProd)
          If nFadeOutOthersTime > nLength
            nLength = nFadeOutOthersTime
          EndIf
        EndIf

      ElseIf \bSubTypeL
        Select \nLCAction
          Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
            nLength = \nLCActionTime
          Default
            If \nLCTimeMax >= 0
              nLength = \nLCTimeMax
            EndIf
        EndSelect
        
      ElseIf \bSubTypeM
        If \nFirstAudIndex >= 0
          nLength = aAud(\nFirstAudIndex)\nCueDuration
        EndIf
        
      ElseIf \bSubTypeP
        nLength = \nPLTotalTime
        
      ElseIf \bSubTypeS
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bSubTypeS=" + strB(\bSubTypeS) + ", \nSFRTimeOverride=" + \nSFRTimeOverride)
        If \nSFRTimeOverride > 0
          nLength = \nSFRTimeOverride
        Else
          For h = 0 To #SCS_MAX_SFR
            Select \nSFRAction[h]
              Case #SCS_SFR_ACT_FADEOUT, #SCS_SFR_ACT_FADEOUTHIB
                Select \nSFRCueType[h]
                  Case #SCS_SFR_CUE_SEL
                    i = \nSFRCuePtr[h]
                    If i >= 0
                      j = aCue(i)\nFirstSubIndex
                      While j >= 0
                        If aSub(j)\bSubTypeHasAuds And aSub(j)\bSubEnabled
                          k = aSub(j)\nFirstAudIndex
                          While k >= 0
                            If (aAud(k)\bAudPlaceHolder = #False) And (aAud(k)\nFadeOutTime > nLength)
                              nLength = aAud(k)\nFadeOutTime
                            EndIf
                            k = aAud(k)\nNextAudIndex
                          Wend
                        EndIf
                        j = aSub(j)\nNextSubIndex
                      Wend
                    EndIf
                EndSelect
            EndSelect
          Next h
        EndIf
        
      ElseIf \bSubTypeU
        If \nMTCDuration > 0
          nLength = \nMTCDuration
        EndIf
        
      EndIf
      
      If bDoContinuous
        sLength = ""
      Else
        sLength = timeToStringBWZ(nLength, nLength)
      EndIf
      ; debugMsg(sProcName, "nLength=" + nLength + ", bDoContinuous=" + strB(bDoContinuous) + ", sLength=" + sLength)
    EndWith
  EndIf
  
  ProcedureReturn sLength
  
EndProcedure

Procedure getCueLength(pCuePtr, pCallCueSubPtr=-1)
  ; PROCNAMECQ(pCuePtr)
  Protected nCueLength, nSubLength, nSubRelStartTime, nRelStartTime
  Protected nPrevSubStartTime, nPrevSubEndTime
  Protected j, k
  
  ; debugMsg(sProcName, #SCS_START + ", pCallCueSubPtr=" + getSubLabel(pCallCueSubPtr))
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If aSub(j)\bSubEnabled
          ; debugMsg(sProcName, "j=" + getSubLabel(j) + ", nPrevSubStartTime=" + nPrevSubStartTime + ", nPrevSubEndTime=" + nPrevSubEndTime)
          nSubLength = getSubLength(j, #False, pCallCueSubPtr)
          nSubRelStartTime = \nRelStartTime
          If nSubRelStartTime < 0
            nSubRelStartTime = 0
          EndIf
          nRelStartTime = 0
          If nSubRelStartTime >= 0
            Select \nRelStartMode
              Case #SCS_RELSTART_AS_CUE, #SCS_RELSTART_DEFAULT
                ; debugMsg(sProcName, "#SCS_RELSTART_AS_CUE, nSubRelStartTime=" + nSubRelStartTime)
                nRelStartTime = nSubRelStartTime
              Case #SCS_RELSTART_AS_PREV_SUB
                ; debugMsg(sProcName, "#SCS_RELSTART_AS_PREV_SUB, nPrevSubStartTime=" + nPrevSubStartTime + ", nSubRelStartTime=" + nSubRelStartTime)
                nRelStartTime = nPrevSubStartTime + nSubRelStartTime
              Case #SCS_RELSTART_AE_PREV_SUB
                ; debugMsg(sProcName, "#SCS_RELSTART_AE_PREV_SUB, nPrevSubEndTime=" + nPrevSubEndTime + ", nSubRelStartTime=" + nSubRelStartTime)
                nRelStartTime = nPrevSubEndTime + nSubRelStartTime
              Case #SCS_RELSTART_BE_PREV_SUB
                ; debugMsg(sProcName, "#SCS_RELSTART_BE_PREV_SUB, nPrevSubEndTime=" + nPrevSubEndTime + ", nSubRelStartTime=" + nSubRelStartTime)
                nRelStartTime = nPrevSubEndTime - nSubRelStartTime
            EndSelect
          EndIf
          If (nSubLength + nRelStartTime) > nCueLength
            nCueLength = nSubLength + nRelStartTime
          EndIf
          nPrevSubStartTime = nRelStartTime
          If nSubLength > 0
            nPrevSubEndTime = nRelStartTime + nSubLength - 1
          Else
            nPrevSubEndTime = nRelStartTime
          EndIf
          ; debugMsg(sProcName, "j=" + getSubLabel(j) + ", nRelStartTime=" + nRelStartTime + ", nSubLength=" + nSubLength + ", nCueLength=" + nCueLength)
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  EndIf
  ; debugMsg(sProcName, #SCS_END + ", returning " + nCueLength)
  ProcedureReturn nCueLength
EndProcedure

Procedure getCueLengthForMTCLink(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  Protected nCueLength, nSubLength
  Protected j, k
  
  ; debugMsg(sProcName, #SCS_START + ", pCallCueSubPtr=" + getSubLabel(pCallCueSubPtr))
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        k = aSub(j)\nFirstAudIndex
        If aSub(j)\bSubEnabled And aSub(j)\bSubTypeAorF And aSub(j)\nAudCount = 1 And k >= 0
          If aSub(j)\bSubTypeA And aAud(k)\nFileFormat <> #SCS_FILEFORMAT_VIDEO
            j = \nNextSubIndex
            Continue
          EndIf
          If \nRelStartMode <> #SCS_RELSTART_DEFAULT Or \nRelStartTime > 0
            j = \nNextSubIndex
            Continue
          EndIf
          nSubLength = getSubLength(j)
          If nSubLength > nCueLength
            nCueLength = nSubLength
          EndIf
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  EndIf
  ; debugMsg(sProcName, #SCS_END + ", returning " + nCueLength)
  ProcedureReturn nCueLength
EndProcedure

Procedure.s getLengthForGrid(pCuePtr)
  PROCNAMEC()
  Protected sLength.s
  
  sLength = timeToStringBWZ(getCueLength(pCuePtr))
  ProcedureReturn sLength
  
EndProcedure

Procedure updateScreenForCue(pCuePtr, bStandBy=#False)
  PROCNAMECQ(pCuePtr)
  Protected nRow
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_UPDATE_SCREEN_FOR_CUE, pCuePtr, 0, bStandBy)
    ProcedureReturn
  EndIf
  
  If (pCuePtr > 0) And (pCuePtr <= gnCueEnd)
    
    With aCue(pCuePtr)
      
      ; debugMsg(sProcName, "calling colorLine(" + getCueLabel(pCuePtr) + ")")
      colorLine(pCuePtr)
      
      nRow = \nGrdCuesRowNo
      ; debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRow + ", #SCS_GRDCUES_CS, " + getCueStateForGrid(pCuePtr) + ") for " + \sCue)
      WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_CS, getCueStateForGrid(pCuePtr))
      ; debugMsg(sProcName, "calling WMN_setGrdCuesCellValue(" + nRow + ", #SCS_GRDCUES_AC, getCueActivationMethodForDisplay(pCuePtr))")
      WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_AC, getCueActivationMethodForDisplay(pCuePtr))
      
      If bStandBy
        setToolBarBtnEnabled(#SCS_TBMB_STANDBY_GO, #True)
        ; setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, "Standby" + Chr(10) + \sCue + " - Go!")
        setToolBarBtnCaption(#SCS_TBMB_STANDBY_GO, LangPars("Menu", "mnuStandbyCueGo", \sCue))
        scsEnableMenuItem(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, #True)
        ; scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, "Standby " + \sCue + " - Go!")
        scsSetMenuItemText(#WMN_mnuWindowMenu, #WMN_mnuStandbyGo, ReplaceString(LangPars("Menu", "mnuStandbyCueGo", \sCue), Chr(10), " "))
      EndIf
      
    EndWith
  EndIf
EndProcedure

Procedure countCuePointCues()
  PROCNAMEC()
  Protected i, j, k, l2
  Protected nCuePointCues
  Protected bUsingCuePoints
  
  For i = 1 To gnLastCue
    bUsingCuePoints = #False
    If aCue(i)\bSubTypeF
      j = aCue(i)\nFirstSubIndex
      While (j >= 0) And (bUsingCuePoints = #False)
        If aSub(j)\bSubTypeF
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            If (aAud(k)\qStartAtSamplePos >= 0) Or (aAud(k)\qEndAtSamplePos >= 0)
              bUsingCuePoints = #True
              Break
            EndIf
            If aAud(k)\nMaxLoopInfo >= 0
              For l2 = 0 To aAud(k)\nMaxLoopInfo
                If (aAud(k)\aLoopInfo(l2)\qLoopStartSamplePos >= 0) Or (aAud(k)\aLoopInfo(l2)\qLoopEndSamplePos >= 0)
                  bUsingCuePoints = #True
                  Break 2
                EndIf
              Next l2
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
    aCue(i)\bUsingCuePoints = bUsingCuePoints
    If bUsingCuePoints
      nCuePointCues + 1
    EndIf
  Next i
  
  ProcedureReturn nCuePointCues
  
EndProcedure

Procedure processProdTimerAction(nProdTimerAction, nProdTimerWhen, pCuePtr)
  PROCNAMEC()
  Protected bStart, bPause, bResume, bShowTimer, bHideTimer, bShowClock, bHideClock
  Protected bAddHistoryEntry, nHistAction
  Protected sRAICommand.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grProdTimer
    Select nProdTimerWhen
      Case #SCS_PTW_WHEN_CUE_STARTS
        Select nProdTimerAction
          Case #SCS_PTA_START_S
            bStart = #True
            bShowTimer = #True
          Case #SCS_PTA_PAUSE_S
            bPause = #True
          Case #SCS_PTA_RESUME_S
            bResume = #True
          CompilerIf #c_prod_timer_extra_actions
            Case #SCS_PTA_SHOW_TIMER
              bShowTimer = #True
            Case #SCS_PTA_HIDE_TIMER
              bHideTimer = #True
            Case #SCS_PTA_SHOW_CLOCK
              bShowClock = #True
            Case #SCS_PTA_HIDE_CLOCK
              bHideClock = #True
          CompilerEndIf
        EndSelect
        
      Case #SCS_PTW_WHEN_CUE_ENDS
        Select nProdTimerAction
          Case #SCS_PTA_START_E
            bStart = #True
          Case #SCS_PTA_PAUSE_E
            bPause = #True
          Case #SCS_PTA_RESUME_E
            bResume = #True
        EndSelect
        
    EndSelect
    
    If bStart
      debugMsg(sProcName, "Start timer")
      ; clear the display to clear any leading digits
      ; (eg clear the "4" from "43:56" before setting the timer to "0:00", otherwise it would be displayed as "40:00")
      debugMsg(sProcName, "calling WMN_clearProdTimer(#False)")
      WMN_clearProdTimer(#False)
      \qPTStartTime = ElapsedMilliseconds()
      \qPTTimePaused = 0
      \nPTTotalTimeOnPause = 0
      \nPTState = #SCS_PTS_RUNNING
      \bPTForceRedisplay = #True
      bAddHistoryEntry = #True
      nHistAction = #SCS_PTHA_STARTED
      sRAICommand = "start"
      
    ElseIf bPause
      debugMsg(sProcName, "Pause timer")
      If \nPTState = #SCS_PTS_RUNNING
        \qPTTimePaused = ElapsedMilliseconds()
        \nPTState = #SCS_PTS_PAUSED
        bAddHistoryEntry = #True
        nHistAction = #SCS_PTHA_PAUSED
        sRAICommand = "pause"
      EndIf
      
    ElseIf bResume
      debugMsg(sProcName, "Resume timer")
      If \nPTState = #SCS_PTS_PAUSED
        \nPTTotalTimeOnPause + (ElapsedMilliseconds() - \qPTTimePaused)
        \nPTState = #SCS_PTS_RUNNING
        bAddHistoryEntry = #True
        nHistAction = #SCS_PTHA_RESUMED
        sRAICommand = "resume"
      EndIf
      
    EndIf
    
    If sRAICommand
      If RAI_IsClientActive()
        If grRAI\nClientConnection2
          debugMsg(sProcName, "calling sendRAIProdTimerCommand(" + #DQUOTE$ + sRAICommand + #DQUOTE$ + ")")
          sendRAIProdTimerCommand(sRAICommand)
        EndIf
      EndIf
    EndIf
    
    If bAddHistoryEntry
      gnProdTimerHistoryPtr + 1
      If gnProdTimerHistoryPtr > ArraySize(gaProdTimerHistory())
        ReDim gaProdTimerHistory(gnProdTimerHistoryPtr + 20)
      EndIf
      gaProdTimerHistory(gnProdTimerHistoryPtr)\nDateTime = Date()
      gaProdTimerHistory(gnProdTimerHistoryPtr)\nHistAction = nHistAction
      If nHistAction <> #SCS_PTHA_STARTED
        gaProdTimerHistory(gnProdTimerHistoryPtr)\nTimeInSecs = gnProdTimerTimeInSecs
      EndIf
      If pCuePtr >= 0
        gaProdTimerHistory(gnProdTimerHistoryPtr)\sCue = aCue(pCuePtr)\sCue
        gaProdTimerHistory(gnProdTimerHistoryPtr)\sCueDescr = aCue(pCuePtr)\sCueDescr
      EndIf
      gaProdTimerHistory(gnProdTimerHistoryPtr)\nProdTimerAction = nProdTimerAction
    EndIf
    
  EndWith
EndProcedure

Procedure setOpenWithPrevAudInds(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k
  Protected nPrevPlayPtr
  Protected nPrevAudDisplayTime
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    If aSub(pSubPtr)\bSubTypeA
      nPrevPlayPtr = -1
      k = aSub(pSubPtr)\nFirstPlayIndex
      While k >= 0
        aAud(k)\bOpenWithPrevAud = #False
        If nPrevPlayPtr >= 0
          If aAud(nPrevPlayPtr)\bDoContinuous
            nPrevAudDisplayTime = 999999999
          Else
            nPrevAudDisplayTime = aAud(nPrevPlayPtr)\nCueDuration
            Select aAud(nPrevPlayPtr)\nPLTransType
              Case #SCS_TRANS_XFADE, #SCS_TRANS_MIX
                If aAud(nPrevPlayPtr)\nPLTransTime > 0
                  nPrevAudDisplayTime - aAud(nPrevPlayPtr)\nPLTransTime
                EndIf
            EndSelect
          EndIf
          If nPrevAudDisplayTime < 3000   ; arbitrarily chose 3 seconds as min time for delayed file opens
            aAud(k)\bOpenWithPrevAud = #True
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bOpenWithPrevAud=" + strB(aAud(k)\bOpenWithPrevAud) + ", nPrevPlayPtr=" + getAudLabel(nPrevPlayPtr))
          EndIf
        EndIf
        nPrevPlayPtr = k
        k = aAud(k)\nNextPlayIndex
      Wend
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listSplitScreenArray()
  PROCNAMEC()
  Protected n
  Protected sMsg.s
  
  ; debugMsg(sProcName, #SCS_START + ", grVideoDriver\nSplitScreenArrayMax=" + grVideoDriver\nSplitScreenArrayMax)
  
  For n = 0 To grVideoDriver\nSplitScreenArrayMax
    With grVideoDriver\aSplitScreenInfo[n]
      sMsg = "grVideoDriver\aSplitScreenInfo[" + n + "]"
      sMsg + "\nDisplayNo=" + \nDisplayNo
      sMsg + ", \sRealScreenSize=" + \sRealScreenSize
      sMsg + ", \nSplitScreenCount=" + \nSplitScreenCount
      sMsg + ", \nCurrentMonitorIndex=" + \nCurrentMonitorIndex
      debugMsg(sProcName, sMsg)
    EndWith
  Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure populateScreenArray()
  PROCNAMEC()
  ; If the user does not split any screens (see 'Split Screen Settings' under 'Video Driver Settings') then the screen array will contain a row for each connected monitor.
  ; However, if the user has some 'split screens' (ie more than one SCS output screen to be displayed on the same monitor) then
  Protected nScreenNo
  Protected nMonitorNo
  Protected nSplitScreenIndex, nMonitorIndex
  Protected n
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nScreenNo = 0
  For nMonitorNo = 1 To gnMonitors
    debugMsg(sProcName, "nMonitorNo=" + nMonitorNo)
    For nSplitScreenIndex = 0 To grVideoDriver\nSplitScreenArrayMax
      ; debugMsg(sProcName, "..nSplitScreenIndex=" + nSplitScreenIndex)
      With grVideoDriver\aSplitScreenInfo[nSplitScreenIndex]
        debugMsg(sProcName, "..grVideoDriver\aSplitScreenInfo[" + nSplitScreenIndex + "]\nCurrentMonitorIndex=" + \nCurrentMonitorIndex + ", \nDisplayNo=" + \nDisplayNo + ", \nSplitScreenCount=" + \nSplitScreenCount)
        If \nCurrentMonitorIndex >= 0
          If \nDisplayNo = nMonitorNo
            nMonitorIndex = \nCurrentMonitorIndex
            For n = 0 To (\nSplitScreenCount - 1)
              nScreenNo + 1
              If nScreenNo > ArraySize(gaScreen())
                ReDim gaScreen(nScreenNo+5)
              EndIf
              gaScreen(nScreenNo)\nDisplayNo = nMonitorNo
              gaScreen(nScreenNo)\nOutputNo = n + 1
              If gbApplyDisplayScaling
                gaScreen(nScreenNo)\nScreenLeft = gaMonitors(nMonitorIndex)\nDesktopLeft + (n * gaMonitors(nMonitorIndex)\nDeskTopWidth / \nSplitScreenCount)
                gaScreen(nScreenNo)\nScreenTop = gaMonitors(nMonitorIndex)\nDesktopTop
                gaScreen(nScreenNo)\nScreenWidth = gaMonitors(nMonitorIndex)\nDeskTopWidth / \nSplitScreenCount
                gaScreen(nScreenNo)\nScreenHeight = gaMonitors(nMonitorIndex)\nDeskTopHeight
              Else
                gaScreen(nScreenNo)\nScreenLeft = gaMonitors(nMonitorIndex)\nMonitorBoundsLeft + (n * gaMonitors(nMonitorIndex)\nMonitorBoundsWidth / \nSplitScreenCount)
                gaScreen(nScreenNo)\nScreenTop = gaMonitors(nMonitorIndex)\nMonitorBoundsTop
                gaScreen(nScreenNo)\nScreenWidth = gaMonitors(nMonitorIndex)\nMonitorBoundsWidth / \nSplitScreenCount
                gaScreen(nScreenNo)\nScreenHeight = gaMonitors(nMonitorIndex)\nMonitorBoundsHeight
              EndIf
              debugMsg(sProcName, "..gaScreen(" + nScreenNo + ")\nScreenWidth=" + gaScreen(nScreenNo)\nScreenWidth + ", gaScreen(" + nScreenNo + ")\nScreenHeight=" + gaScreen(nScreenNo)\nScreenHeight)
              gaScreen(nScreenNo)\nDesktopLeft = gaMonitors(nMonitorIndex)\nDesktopLeft + (n * gaMonitors(nMonitorIndex)\nDeskTopWidth / \nSplitScreenCount)
              gaScreen(nScreenNo)\nDesktopTop = gaMonitors(nMonitorIndex)\nDesktopTop
              gaScreen(nScreenNo)\nDesktopWidth = gaMonitors(nMonitorIndex)\nDeskTopWidth / \nSplitScreenCount
              gaScreen(nScreenNo)\nDesktopHeight = gaMonitors(nMonitorIndex)\nDeskTopHeight
              debugMsg(sProcName, "..gaScreen(" + nScreenNo + ")\nDesktopWidth=" + gaScreen(nScreenNo)\nDesktopWidth + ", gaScreen(" + nScreenNo + ")\nDesktopHeight=" + gaScreen(nScreenNo)\nDesktopHeight)
            Next n
          EndIf
        EndIf
      EndWith
    Next nSplitScreenIndex
  Next nMonitorNo
  gnScreens = nScreenNo
  debugMsg(sProcName, "gnScreens=" + gnScreens)
  
  For nScreenNo = 1 To gnScreens
    With gaScreen(nScreenNo)
      sMsg = "gaScreen(" + nScreenNo + ")\nDisplayNo=" + \nDisplayNo +
             ", \nOutputNo=" + \nOutputNo +
             ", \nScreenLeft=" + \nScreenLeft +
             ", \nScreenTop=" + \nScreenTop +
             ", \nScreenWidth=" + \nScreenWidth +
             ", \nScreenHeight=" + \nScreenHeight
      debugMsg(sProcName, sMsg)
    EndWith
  Next nScreenNo
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getScreenNo(nDisplayNo, nOutputNo)
  PROCNAMEC()
  Protected n, nScreenNo
  
  nScreenNo = -1
  For n = 1 To gnScreens
    With gaScreen(n)
      If (\nDisplayNo = nDisplayNo) And (\nOutputNo = nOutputNo)
        nScreenNo = n
        Break
      EndIf
    EndWith
  Next n
  ProcedureReturn nScreenNo
EndProcedure

Procedure findFirstNonVideoMonitor()
  PROCNAMEC()
  Protected nVideoCentreX, nVideoCentreY
  Protected nMonitorNo, nVideoScreenNo
  Protected bMonitorHasVideo
  Protected nAvailableMonitorNo
  
  nAvailableMonitorNo = -1
  For nMonitorNo = 1 To gnMonitors
    bMonitorHasVideo = #False
    With gaMonitors(nMonitorNo)
      For nVideoScreenNo = #WV2 To grLicInfo\nLastVideoWindowNo
        If IsWindow(nVideoScreenNo)
          nVideoCentreX = (WindowX(nVideoScreenNo) + WindowWidth(nVideoScreenNo)) >> 1
          nVideoCentreY = (WindowY(nVideoScreenNo) + WindowHeight(nVideoScreenNo)) >> 1
          If (nVideoCentreX >= \nDesktopLeft) And (nVideoCentreX <= (\nDesktopLeft + \nDeskTopWidth))
            If (nVideoCentreY >= \nDesktopTop) And (nVideoCentreY <= (\nDesktopTop + \nDeskTopHeight))
              bMonitorHasVideo = #True
              Break
            EndIf
          EndIf
        EndIf
      Next nVideoScreenNo
    EndWith
    If bMonitorHasVideo = #False
      nAvailableMonitorNo = nMonitorNo
      Break
    EndIf
  Next nMonitorNo
  ProcedureReturn nAvailableMonitorNo
  
EndProcedure

Procedure ensureWindowNotBehindVideoScreen(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected nWindowCentreX, nWindowCentreY
  Protected nVideoLeft, nVideoRight, nVideoTop, nVideoBottom
  Protected nVideoScreenNo
  Protected bWindowOverlaps
  Protected nAvailableMonitorNo
  Protected nNewLeft, nNewTop, nNewWidth, nNewHeight
  Protected nCurrLeft, nCurrTop, nCurrWidth, nCurrHeight
  Protected sWindow.s
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(nWindowNo)
    sWindow = decodeWindow(nWindowNo)
    nWindowCentreX = WindowX(nWindowNo) + (WindowWidth(nWindowNo) >> 1)
    nWindowCentreY = WindowY(nWindowNo) + (WindowHeight(nWindowNo) >> 1)
    For nVideoScreenNo = #WV2 To grLicInfo\nLastVideoWindowNo
      If IsWindow(nVideoScreenNo)
        nVideoLeft = WindowX(nVideoScreenNo)
        nVideoTop = WindowY(nVideoScreenNo)
        nVideoRight = nVideoLeft + WindowWidth(nVideoScreenNo) - 1
        nVideoBottom = nVideoTop + WindowHeight(nVideoScreenNo) - 1
        If (nWindowCentreX >= nVideoLeft) And (nWindowCentreX <= nVideoRight)
          If (nWindowCentreY >= nVideoTop) And (nWindowCentreY <= nVideoBottom)
            bWindowOverlaps = #True
            debugMsg(sProcName, "WindowX(" + sWindow + ")=" + WindowX(nWindowNo) + ", WindowY(" + sWindow + ")=" + WindowY(nWindowNo) +
                                ", WindowWidth(" + sWindow + ")=" + WindowWidth(nWindowNo) + ", WindowHeight(" + sWindow + ")=" + WindowHeight(nWindowNo) +
                                ", nWindowCentreX=" + nWindowCentreX + ", nWindowCentreY=" + nWindowCentreY)
            debugMsg(sProcName, "nVideoScreenNo=" + decodeWindow(nVideoScreenNo) + ", nVideoLeft=" + nVideoLeft + ", nVideoTop=" + nVideoTop +
                                ", nVideoRight=" + nVideoRight + ", nVideoBottom=" + nVideoBottom)
            Break
          EndIf
        EndIf
      EndIf
    Next nVideoScreenNo
    debugMsg(sProcName, "bWindowOverlaps=" + strB(bWindowOverlaps))
    If bWindowOverlaps
      nAvailableMonitorNo = findFirstNonVideoMonitor()
      debugMsg(sProcName, "nAvailableMonitorNo=" + nAvailableMonitorNo)
      If nAvailableMonitorNo >= 1
        With gaMonitors(nAvailableMonitorNo)
          nCurrLeft = WindowX(nWindowNo)
          nCurrTop = WindowY(nWindowNo)
          nCurrWidth = WindowWidth(nWindowNo)
          nCurrHeight = WindowHeight(nWindowNo)
          If WindowWidth(nWindowNo) <= \nDesktopWidth
            nNewLeft = \nDesktopLeft + ((\nDesktopWidth - WindowWidth(nWindowNo)) >> 1)
          Else
            nNewLeft = \nDesktopLeft
          EndIf
          If WindowHeight(nWindowNo) <= \nDesktopHeight
            nNewTop = \nDesktopTop + ((\nDesktopHeight - WindowHeight(nWindowNo)) >> 1)
          Else
            nNewTop = \nDesktopTop
          EndIf
          If WindowWidth(nWindowNo) > \nDesktopWidth
            nNewWidth = \nDesktopWidth
          Else
            nNewWidth = #PB_Ignore
            nCurrWidth = #PB_Ignore
          EndIf
          If WindowHeight(nWindowNo) > \nDesktopHeight
            nNewHeight = \nDesktopHeight
          Else
            nNewHeight = #PB_Ignore
            nCurrHeight = #PB_Ignore
          EndIf
          If nNewLeft <> nCurrLeft Or nNewTop <> nCurrTop Or nNewWidth <> nCurrWidth Or nNewHeight <> nCurrHeight
            debugMsg(sProcName, "nCurrLeft=" + nCurrLeft + ", nNewLeft=" + nNewLeft + ", nCurrTop=" + nCurrTop + ", nNewTop=" + nNewTop +
                                ", nCurrWidth=" + nCurrWidth + ", nNewWidth=" + nNewWidth + ", nCurrHeight=" + nCurrHeight + ", nNewHeight=" + nNewHeight)
            debugMsg(sProcName, "WindowX(" + decodeWindow(nWindowNo) + ")=" + WindowX(nWindowNo) + ", WindowY(" + decodeWindow(nWindowNo) + ")=" + WindowY(nWindowNo) +
                                ", WindowWidth(" + decodeWindow(nWindowNo) + ")=" + WindowWidth(nWindowNo) + ", WindowHeight(" + decodeWindow(nWindowNo) + ")=" + WindowHeight(nWindowNo))
            ResizeWindow(nWindowNo, nNewLeft, nNewTop, nNewWidth, nNewHeight)
            debugMsg(sProcName, "ResizeWindow(" + decodeWindow(nWindowNo) + ", " + nNewLeft + ", " + nNewTop + ", " + nNewWidth + ", " + nNewHeight + ")")
            debugMsg(sProcName, "calling WMN_Form_Resize()")
            WMN_Form_Resize()
          EndIf
        EndWith
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s loadDevInfoForSub(pSubPtr, bAndFollowingSubs=#False)
  PROCNAMECS(pSubPtr)
  Protected sDevice.s, sThisDev.s, sPlus.s
  Protected d, j, k, n
  
  If pSubPtr >= 0
    j = pSubPtr
    While j >= 0
      With aSub(j)
        ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubType=" + \sSubType + ", \bSubTypeHasAuds=" + strB(\bSubTypeHasAuds) + ", j=" + j + ", \nNextSubIndex=" + \nNextSubIndex)
        If \bSubTypeK
          sThisDev = \sLTLogicalDev
          updDeviceField()
          ; debugMsg(sProcName, "\bSubTypeK, sThisDev=" + sThisDev + ", sDevice=" + sDevice)
        ElseIf \bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            If \aCtrlSend[n]\nDevType <> #SCS_DEVTYPE_NONE
              sThisDev = \aCtrlSend[n]\sCSLogicalDev
              updDeviceField()
            EndIf
          Next n
          ; debugMsg(sProcName, "\bSubTypeM, sThisDev=" + sThisDev + ", sDevice=" + sDevice)
        EndIf
        If \bSubTypeHasAuds
          If \bSubTypeP
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              sThisDev = VST_adjustLogicalDevForVST(\sPLLogicalDev[d])
              updDeviceField()
            Next d
          Else
            k = \nFirstAudIndex
            While k >= 0
              sThisDev = ""
              Select aAud(k)\nFileFormat
                Case #SCS_FILEFORMAT_AUDIO, #SCS_FILEFORMAT_LIVE_INPUT
                  If aAud(k)\nFirstSoundingDev >= 0
                    sThisDev = VST_adjustLogicalDevForVST(aAud(k)\sLogicalDev[aAud(k)\nFirstSoundingDev])
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sLogicalDev[" + Str(aAud(k)\nFirstDev) + "]=" + sThisDev)
                    If aAud(k)\nLastSoundingDev > aAud(k)\nFirstSoundingDev
                      sPlus = "+"
                    EndIf
                  EndIf
                Case #SCS_FILEFORMAT_MIDI
                  sThisDev = aAud(k)\sLogicalDev[0]
                Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_VIDEO, #SCS_FILEFORMAT_CAPTURE
                  If \sScreens
                    sThisDev = "v:" + \sScreens
                  Else
                    sThisDev = "v:" + \nOutputScreen
                  EndIf
                  Select aAud(k)\nFileFormat
                    Case #SCS_FILEFORMAT_VIDEO
                      If \bMuteVideoAudio
                        sThisDev + " a:" + grText\sTextMute
                      Else
                        sThisDev + " a:" + \sVidAudLogicalDev
                      EndIf
                    Case #SCS_FILEFORMAT_CAPTURE
                      sThisDev + " c:" + aAud(k)\sVideoCaptureLogicalDevice
                  EndSelect
              EndSelect
              updDeviceField()
              ; debugMsg(sProcName, "sThisDev=" + sThisDev + ", sPlus=" + sPlus + ", sDevice=" + sDevice)
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          
        EndIf
        If bAndFollowingSubs
          j = \nNextSubIndex
        Else
          Break
        EndIf
      EndWith
    Wend
  EndIf
  
  ProcedureReturn Trim(sDevice + sPlus)
  
EndProcedure

Procedure EnableDisableCues(bEnable, pFirstCuePtr, pLastCuePtr=-1, pCallingCuePtr=-1)
  PROCNAMEC()
  Protected nFirstCuePtr, nLastCuePtr
  Protected i
  Protected nCuesChanged
  
  ; called from playSubTypeJ(), or from the old-style 'note' cue starting with $enable or $disable
  
  debugMsg(sProcName, #SCS_START + ", bEnable=" + strB(bEnable) + ", pFirstCuePtr=" + getCueLabel(pFirstCuePtr) + ", pLastCuePtr=" + getCueLabel(pLastCuePtr) + ", pCallingCuePtr=" + getCueLabel(pCallingCuePtr))
  
  nFirstCuePtr = pFirstCuePtr
  nLastCuePtr = pLastCuePtr
  If nLastCuePtr = -1
    nLastCuePtr = nFirstCuePtr
  EndIf
  
  For i = nFirstCuePtr To nLastCuePtr
    If i <> pCallingCuePtr ; if a range of cues spans the calling cue then omit the calling cue (not likely to occur in practice)
      With aCue(i)
        If \bCueCurrentlyEnabled
          If bEnable = #False
            debugMsg(sProcName, "disabling " + getCueLabel(i))
            \bCueCurrentlyEnabled = #False
            setGoOkIfExclPlaying(i)
            nCuesChanged + 1
          EndIf
        Else  ; \bCueCurrentlyEnabled = #False
          If bEnable
            debugMsg(sProcName, "enabling " + getCueLabel(i))
            \bCueCurrentlyEnabled = #True
            setGoOkIfExclPlaying(i)
            nCuesChanged + 1
          EndIf
        EndIf
        setCueSubsAllDisabledFlag(i)
      EndWith
    EndIf
  Next i
  
  ; Deleted 1Feb2021 11.8.3.5 - now handled by calling procedure by returning nCuesChanged
  ;   If nCuesChanged > 0
  ;     debugMsg(sProcName, "calling setCueDetailsInMain()")
  ;     setCueDetailsInMain()
  ;     debugMsg(sProcName, "calling ONC_openNextCues()")
  ;     ONC_openNextCues()
  ;   EndIf
  ; End deleted 1Feb2021 11.8.3.5
  
  debugMsg(sProcName, #SCS_END + ", returning nCuesChanged=" + nCuesChanged)
  ProcedureReturn nCuesChanged
  
EndProcedure

Procedure clearInitializingState()
  PROCNAMEC()
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  debugMsg(sProcName, #SCS_START)
  
  COND_OPEN_PREFS("Init")
  WritePreferenceInteger("Initializing", #False) ; indicates end of initialization
  COND_CLOSE_PREFS()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setRunState(sRunState.s, bSetSessionId=#False)
  PROCNAMEC()
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  ; sRunState values:
  ;   C = Closed (ie SCS properly closed down)
  ;   I = Initializing
  ;   R = Running
  
  debugMsg(sProcName, #SCS_START + ", sRunState=" + sRunState)
  
  COND_OPEN_PREFS("Init")
  WritePreferenceString("RunState", sRunState)
  If bSetSessionId
    WritePreferenceInteger("SessionId", gnSessionId)
    RemovePreferenceKey("Initializing") ; obsolete since the introduction of "RunState"
  EndIf
  COND_CLOSE_PREFS()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s getRunState()
  PROCNAMEC()
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected sRunState.s
  
  debugMsg(sProcName, #SCS_START)
  
  COND_OPEN_PREFS("Init")
  sRunState = ReadPreferenceString("RunState", "C") ; 'C' = closed
  COND_CLOSE_PREFS()
  
  debugMsg(sProcName, #SCS_END + ", returning " + sRunState)
  ProcedureReturn sRunState
  
EndProcedure

Procedure earlyCloseDown()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  ; clearInitializingState()
  setRunState("C")
  
  End ; program close!!!
  
EndProcedure

Procedure setGoOkIfExclPlaying(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected bGoOkIfExclPlaying
  Protected j
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      If \bCueCurrentlyEnabled
        bGoOkIfExclPlaying = #True
        If \bHotkey = #False
          j = \nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubEnabled
              If aSub(j)\bSubTypeForP Or aSub(j)\bSubTypeA
                bGoOkIfExclPlaying = #False
                Break
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      EndIf
      If \bGoOkIfExclPlaying <> bGoOkIfExclPlaying
        \bGoOkIfExclPlaying = bGoOkIfExclPlaying
        ; debugMsg(sProcName, "\bGoOkIfExclPlaying=" + strB(\bGoOkIfExclPlaying))
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure resetThreadExecutionState()
  PROCNAMEC()
  Protected nResult
  
  debugMsg(sProcName, #SCS_START)
  
  ; reinstate initial thread execution state
  If gnInitialThreadExecutionState <> -1
    nResult = SetThreadExecutionState_(gnInitialThreadExecutionState)
    debugMsg(sProcName, "SetThreadExecutionState_($" + Hex(gnInitialThreadExecutionState,#PB_Long) + ") returned $" + Hex(nResult,#PB_Long))
    ; repeat the action so we can confirm the action really did happen, because nResult should = gnInitialThreadExecutionState
    nResult = SetThreadExecutionState_(gnInitialThreadExecutionState)
    debugMsg(sProcName, "SetThreadExecutionState_($" + Hex(gnInitialThreadExecutionState,#PB_Long) + ") returned $" + Hex(nResult,#PB_Long))
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure applyThreadExecutionState()
  PROCNAMEC()
  ; The Windows SetThreadExecutionState() function enables an application to inform the system that it is in use,
  ; thereby preventing the system from entering sleep or turning off the display while the application is running.
  Protected nResult
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnInitialThreadExecutionState <> -1
    resetThreadExecutionState()
  EndIf
  
  debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\bAllowDisplayTimeout=" + strB(grOperModeOptions(gnOperMode)\bAllowDisplayTimeout))
  
  If grOperModeOptions(gnOperMode)\bAllowDisplayTimeout
    ; stop computer going to sleep, but DON'T keep display active - save initial 'thread execution state' so this can be reinstated at closedown (although not sure if it is really necessary to reinstate it)
    gnInitialThreadExecutionState = SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS)
    debugMsg(sProcName, "SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS) returned $" + Hex(gnInitialThreadExecutionState,#PB_Long))
    ; repeat the action so we can confirm the action really did happen, because nResult should show $80000041 (#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS)
    nResult = SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS)
    debugMsg(sProcName, "SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS) returned $" + Hex(nResult,#PB_Long))
  Else
    ; stop computer going to sleep, and keep display active - save initial 'thread execution state' so this can be reinstated at closedown (although not sure if it is really necessary to reinstate it)
    gnInitialThreadExecutionState = SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS | #ES_DISPLAY_REQUIRED)
    debugMsg(sProcName, "SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS | #ES_DISPLAY_REQUIRED) returned $" + Hex(gnInitialThreadExecutionState,#PB_Long))
    ; repeat the action so we can confirm the action really did happen, because nResult should show $80000043 (#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS | #ES_DISPLAY_REQUIRED)
    nResult = SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS | #ES_DISPLAY_REQUIRED)
    debugMsg(sProcName, "SetThreadExecutionState_(#ES_AWAYMODE_REQUIRED | #ES_SYSTEM_REQUIRED | #ES_CONTINUOUS | #ES_DISPLAY_REQUIRED) returned $" + Hex(nResult,#PB_Long))
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure drawMultiLineText(x, y, nMaxWidth, nMaxHeight, sText.s, FrontColor=-1, BackColor=-1)
  PROCNAMEC()
  Protected nLineHeight
  Protected sLine.s, nLineWidth
  Protected nThisY
  Protected sPartLine.s, nPos
  Protected nDrawHeight
  
  nLineHeight = TextHeight("yY")
  sLine = RTrim(sText)
  nThisY = y
  
  While (sLine) And ((nThisY + nLineHeight) <= (y + nMaxHeight))
    nLineWidth = TextWidth(sLine)
    If nLineWidth <= nMaxWidth
      DrawText(x, nThisY, sLine, FrontColor, BackColor)
      nDrawHeight + nLineHeight
      Break
    EndIf
    nPos = Len(sLine)
    While #True
      While (nPos > 1) And (Mid(sLine, nPos, 1) <> " ")
        nPos - 1
      Wend
      sPartLine = RTrim(Left(sLine, nPos))
      If TextWidth(sPartLine) <= nMaxWidth
        Break
      EndIf
      nPos - 1
    Wend
    sLine = Trim(Mid(sLine, nPos + 1))
    DrawText(x, nThisY, sPartLine, FrontColor, BackColor)
    nDrawHeight + nLineHeight
    nThisY + nLineHeight
  Wend
  
  ProcedureReturn nDrawHeight
EndProcedure

Procedure createBlankProd()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbLoadingCueFile = #True
  grRAI\bNewCueFile = #True
  debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile) + ", grRAI\bNewCueFile=" + strB(grRAI\bNewCueFile))
  
  With grProd
    \sTitle = grAction\sTitle
  EndWith
  
  gbLoadingCueFile = #False
  debugMsg(sProcName, "gbLoadingCueFile=" + strB(gbLoadingCueFile))
  
  debugMsg(sProcName, "calling WMN_Form_Load")
  WMN_Form_Load()
  
  debugMsg(sProcName, "calling setGoButtonTip")
  setGoButtonTip()
  
  gnCallOpenNextCues = 1
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  loadCueBrackets()
  gbCallSetNavigateButtons = #True
  gnCallEditorCuePtr = -1
  gbCallEditor = #True
  gbNewCueFile = #True
  gbNoWait = #False
  gbGoToProdPropDevices = #True
  debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processAction()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    \bProcessingAction = #True  ; may be used within common procedures
    
    Select \nAction
      Case #SCS_ACTION_CANCEL
        debugMsg(sProcName, "grAction\nAction = Cancel")
        gbNewCueFile = #False
        gbOpenRecentFile = #True
        WSP_loadMostRecentFile()
        
      Case #SCS_ACTION_CLOSE_SCS
        debugMsg(sProcName, "grAction\nAction = Close SCS")
        gqMainThreadRequest = #SCS_MTH_CLOSE_DOWN ; use =, not |, so any existing main thread requests are wiped
        
      Case #SCS_ACTION_OPEN_FILE
        debugMsg(sProcName, "grAction\nAction = Open File")
        gbNewCueFile = #False
        WSP_loadSelectedFile(\sSelectedFileName, #False)
        If getWindowVisible(#WMI)
          debugMsg(sProcName, "calling WMI_Form_Unload()")
          WMI_Form_Unload()
        EndIf
        
      Case #SCS_ACTION_CREATE
        debugMsg(sProcName, "grAction\nAction = Create New Cue File")
        gbNewCueFile = #True
        WSP_loadSelectedFile("")
        createBlankProd()
        
      Case #SCS_ACTION_CREATE_FROM_TEMPLATE
        debugMsg(sProcName, "grAction\nAction = Create From Template")
        gbNewCueFile = #True
        WSP_loadSelectedFile(\sSelectedFileName, #True)
        
      Case #SCS_ACTION_CREATE_TEMPLATE_FROM_CUEFILE
        debugMsg(sProcName, "grAction\nAction = Create Template")
        WTM_createTemplateFromCueFile(\sSelectedFileName, \sTitle)
        
      Case #SCS_ACTION_SAVE_AS_TEMPLATE
        debugMsg(sProcName, "grAction\nAction = Save As Template")
        WTM_saveAsTemplate(\sSelectedFileName, \sTitle)
        
      Case #SCS_ACTION_EDIT_TEMPLATE
        debugMsg(sProcName, "grAction\nAction = Edit Template")
        gbNewCueFile = #False
        WSP_loadSelectedFile(\sSelectedFileName, #False, #True)
        
      Default
        debugMsg(sProcName, "grAction\nAction = " + grAction\nAction)
    EndSelect
    
    ; call any required form unload procedure NOW, not earlier in this procedure,
    ; to avoid the possibility of having no windows at all displayed briefly while SCS sets up the cue file for the main window
    Select \nParentWindow
      Case #WLP
        WLP_Form_Unload(#True)
        
      Case #WTM
        Select \nAction
          Case #SCS_ACTION_CREATE_TEMPLATE_FROM_CUEFILE, #SCS_ACTION_SAVE_AS_TEMPLATE
            ; leave WTM loaded
            
          Default
            WTM_Form_Unload()
            Select grWTM\nParentWindow
              Case #WLP
                WLP_Form_Unload(#True)
            EndSelect
        EndSelect
        
    EndSelect
    
    \bProcessingAction = #False
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processStopAll()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbFadingEverything = #False
  setGlobalTimeNow()
  stopEverythingPart1()
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    debugMsg(sProcName, "calling FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_STOP_ALL)")
    FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_STOP_ALL)
  EndIf
  
  If grM2T\bM2TCueListColoringApplied
    M2T_clearCueInds()
    colorCueListEntries()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processStopMTC()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  setGlobalTimeNow()
  stopMTC()
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_STOP_MTC)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processFadeAll()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbFadingEverything = #True
  ; gbFadingEverythingDelayCompleted = #False
  setGlobalTimeNow()
  gnFadeEverythingTime = grGeneralOptions\nFadeAllTime
  debugMsg(sProcName, "gnFadeEverythingTime=" + gnFadeEverythingTime)
  stopEverythingPart1()
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_FADE_ALL)
  EndIf
  
  If grM2T\bM2TCueListColoringApplied
    M2T_clearCueInds()
    colorCueListEntries()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processPauseResumeAll()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If gbStoppingEverything = #False
    If gbGlobalPause = #False
      pauseAll()
    Else
      resumeAll()
    EndIf
  EndIf
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_CTRL_PAUSE_RESUME_ALL)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setRandomSeed()
  PROCNAMEC()
  ; setting RandomSeed was added 25Nov2017 11.7.0ba following reports from Randy Hammond that 'random' playlists were often played in the same order
  ; even though the playlist orders should have been re-generated. this code is in conjunction with logListEvent() which maintains a separate log of
  ; the playlist orders and maybe a few other events.
  Protected nDate, nSeedYear, nCode, sCode.s
  
  nDate = Date()
  nSeedYear = Year(nDate) - 25
  nCode = nDate - Date(nSeedYear,1,1,0,0,0)   ; adjust date downwards to ensure the reversed nCode and ultimately nRandomSeed will be accepatble in a 32-bit environment
  sCode = ReverseString(Str(nCode))
  gnRandomSeed = Val(sCode)
  RandomSeed(gnRandomSeed)
  debugMsg(sProcName, "nDate=" + nDate + ", nCode=" + nCode + ", sCode=" + sCode + ", gnRandomSeed=" + gnRandomSeed)
  logListEvent(sProcName, "RandomSeed=" + gnRandomSeed, #True)
  
EndProcedure

Procedure setFirstPlayIndexThisRun(pSubPtr, bUsePosFromDatabase)
  PROCNAMECS(pSubPtr)
  Protected k
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aSub(pSubPtr)
    \nFirstPlayIndexThisRun = \nFirstPlayIndex  ; default setting
    If bUsePosFromDatabase
      If (\bSubTypeP) And (\bPLSavePos)
        If \nAudCount > 1
          If \nPLAudNoLastPlayed > 0
            k = \nFirstPlayIndex
            While k >= 0
              If aAud(k)\nAudNo = \nPLAudNoLastPlayed
                k = aAud(k)\nNextPlayIndex
                If k >= 0
                  \nFirstPlayIndexThisRun = k
                EndIf
                Break
              EndIf
              k = aAud(k)\nNextPlayIndex
            Wend
          EndIf
        EndIf
      EndIf
    EndIf
    If \nFirstPlayIndexThisRun >= 0
      \nPLFirstPlayNoThisPass = aAud(\nFirstPlayIndexThisRun)\nAudNo
      If \bSubTypeP
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nFirstPlayIndexThisRun=" + getAudLabel(\nFirstPlayIndexThisRun) + ", \nPLFirstPlayNoThisPass=" + \nPLFirstPlayNoThisPass)
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setPlaylistTrackReadyState(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr
  Protected nReqdAudState = #SCS_CUE_PL_READY
  
  With aAud(pAudPtr)
    nSubPtr = \nSubIndex
    If (aSub(nSubPtr)\nSubState <= #SCS_CUE_FADING_IN) Or (aSub(nSubPtr)\nSubState > #SCS_CUE_FADING_OUT)
      If (\bAudTypeP) And (aSub(nSubPtr)\bPLSavePos)
        If pAudPtr = aSub(nSubPtr)\nFirstPlayIndexThisRun
          nReqdAudState = #SCS_CUE_READY
        EndIf
      Else
        If \nPrevPlayIndex < 0
          nReqdAudState = #SCS_CUE_READY
        EndIf
      EndIf
    EndIf
    audSetState(pAudPtr, nReqdAudState, 27)
  EndWith
  
EndProcedure

Procedure setMemoScreen1InUseInd()
  PROCNAMEC()
  Protected i, j, bMemoScreen1InUse
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeE And aCue(i)\bCueEnabled
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeE And aSub(j)\bSubEnabled And aSub(j)\nMemoScreen = 1
          bMemoScreen1InUse = #True
          Break 2
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  grWMN\bMemoScreen1InUse = bMemoScreen1InUse
  debugMsg(sProcName, "grWMN\bMemoScreen1InUse=" + strB(grWMN\bMemoScreen1InUse))
  
EndProcedure

Procedure WriteOrRemovePreferenceInteger(sKey.s, nValue.i, nRemoveValue.i)
  If nValue = nRemoveValue
    RemovePreferenceKey(sKey)
  Else
    WritePreferenceInteger(sKey, nValue)
  EndIf
EndProcedure

Procedure WriteOrRemovePreferenceString(sKey.s, sString.s, sRemoveString.s)
  If sString = sRemoveString
    RemovePreferenceKey(sKey)
  Else
    WritePreferenceString(sKey, sString)
  EndIf
EndProcedure

Procedure getDontAskTellToday(sPrefKey.s)
  ; sPrefKey must be one of the #SCS_DontAsk... or #SCS_DontTell... constants
  PROCNAMEC()
  Protected sDateToday.s, sPrefDate.s
  
  With grMemoryPrefs
    sDateToday = FormatDate("%yyyy%mm%dd", Date())
    Select sPrefKey
      Case #SCS_DontAskCloseSCSDate
        sPrefDate = \sDontAskCloseSCSDate
      Case #SCS_DontTellDMXChannelLimitDate
        sPrefDate = \sDontTellDMXChannelLimitDate
    EndSelect
  EndWith
  
  debugMsg(sProcName, "sPrefKey=" + sPrefKey + ", sDateToday=" + sDateToday + ", sPrefDate=" + sPrefDate)
  If sPrefDate = sDateToday
    debugMsg(sProcName, "returning #True")
    ProcedureReturn #True ; Don't ask/tell again today
  Else
    debugMsg(sProcName, "returning #False")
    ProcedureReturn #False ; Ask/Tell
  EndIf
  
EndProcedure

Procedure setDontAskTellToday(sPrefKey.s)
  ; sPrefKey must be one of the #SCS_DontAsk... or #SCS_DontTell... constants
  PROCNAMEC()
  Protected sDateToday.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  With grMemoryPrefs
    sDateToday = FormatDate("%yyyy%mm%dd", Date())
    Select sPrefKey
      Case #SCS_DontAskCloseSCSDate
        \sDontAskCloseSCSDate = sDateToday
      Case #SCS_DontTellDMXChannelLimitDate
        \sDontTellDMXChannelLimitDate = sDateToday
    EndSelect
  EndWith
  
  COND_OPEN_PREFS("Memory")
  WritePreferenceString(sPrefKey, sDateToday)
  COND_CLOSE_PREFS()
  
EndProcedure

Procedure setCueStateAndUpdateGrid(pCuePtr)
  setCueState(pCuePtr)
  updateGrid(pCuePtr)
EndProcedure

Procedure completeAssocAutoStartCues(pCuePtr, pExcludingCuePtr=-1)
  PROCNAMECQ(pCuePtr)
  Protected i
  Static nLevel
  
  nLevel + 1
  debugMsg(sProcName, #SCS_START + ", nLevel=" + nLevel)
  
  If nLevel = 1
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
    THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
  EndIf
  
  For i = 1 To gnLastCue
    If i <> pExcludingCuePtr
      If aCue(i)\nAutoActCuePtr = pCuePtr
        If (aCue(i)\nCueState <> #SCS_CUE_COMPLETED) And (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO Or aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
          debugMsg(sProcName, "calling stopCue(" + getCueLabel(i) + ")")
          stopCue(i, "ALL", #False)
          debugMsg(sProcName, "calling closeCue(" + getCueLabel(i) + ")")
          closeCue(i, #False, #True)
          debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
          setCueState(i)
          updateGrid(i)
          samCancelRequest(#SCS_SAM_PLAY_CUE, i)
          completeAssocAutoStartCues(i)
        EndIf
      EndIf
    EndIf
  Next i
  
  If nLevel = 1
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", nLevel=" + nLevel)
  nlevel - 1
  
EndProcedure

Procedure readyAssocAutoStartCues(pCuePtr, pExcludingCuePtr=-1)
  PROCNAMECQ(pCuePtr)
  Protected i
  Static nLevel
  
  nLevel + 1
  debugMsg(sProcName, #SCS_START + ", nLevel=" + nLevel)
  
  If nLevel = 1
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
    THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
  EndIf
  
  For i = 1 To gnLastCue
    If i <> pExcludingCuePtr
      With aCue(i)
        If \nAutoActCuePtr = pCuePtr
          If (\nCueState <> #SCS_CUE_READY) And (\nActivationMethod = #SCS_ACMETH_AUTO Or \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
            debugMsg(sProcName, "calling resetCueStates(" + getCueLabel(i) + ", #True)")
            resetCueStates(i, #True)
            samCancelRequest(#SCS_SAM_PLAY_CUE, i)
            readyAssocAutoStartCues(i)
          EndIf
        EndIf
      EndWith
    EndIf
  Next i
  
  If nLevel = 1
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", nLevel=" + nLevel)
  nlevel - 1
  
EndProcedure

Procedure holdAssocAutoStartCues(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected i
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\nAutoActCuePtr = pCuePtr
      If (aCue(i)\nCueState <> #SCS_CUE_COMPLETED) And (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO Or aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
        If aCue(i)\nCueState < #SCS_CUE_FADING_IN
          If aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO
            aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN
          Else
            aCue(i)\nActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF
          EndIf
          aCue(i)\bHoldAutoStart = #True
          debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(i)\nActivationMethodReqd))
        EndIf
        samCancelRequest(#SCS_SAM_PLAY_CUE, i)
      EndIf
    EndIf
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setSubToCountDown(pSubPtr, qTimeToStart.q)
  PROCNAMECS(pSubPtr)
  Protected k
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubEnabled
        \qTimeToStartSub = qTimeToStart
        \bTimeSubStartedSet = #True
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\qTimeToStartSub=" + traceTime(\qTimeToStartSub))
        If \bSubTypeHasAuds
          k = \nFirstPlayIndex
          If k >= 0
            debugMsg(sProcName, "setting aAud(" + getAudLabel(k) + ")\nAudState (" + decodeCueState(aAud(k)\nAudState) + ") to #SCS_CUE_SUB_COUNTDOWN_TO_START")
            aAud(k)\nAudState = #SCS_CUE_SUB_COUNTDOWN_TO_START
          EndIf
        EndIf
        debugMsg(sProcName, "setting aSub(" + getSubLabel(pSubPtr) + ")\nSubState (" + decodeCueState(\nSubState) + ") to #SCS_CUE_SUB_COUNTDOWN_TO_START")
        \nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
        \nSubCountDownTimeLeft = \qTimeToStartSub - gqTimeNow
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubCountDownTimeLeft=" + \nSubCountDownTimeLeft)
        debugMsg(sProcName, "calling setCueState(" + getCueLabel(\nCueIndex) + ")")
        setCueState(\nCueIndex, #False, #False, #True)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure setCueToCountDown(pCuePtr, qTimeToStart.q)
  PROCNAMECQ(pCuePtr)
  Protected j, k
  
  debugMsg(sProcName, #SCS_START)
  
  If pCuePtr >= 0
    aCue(pCuePtr)\qTimeToStartCue = qTimeToStart
    aCue(pCuePtr)\bTimeToStartCueSet = #True
    debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")bTimeToStartCueSet=" + strB(aCue(pCuePtr)\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(aCue(pCuePtr)\qTimeToStartCue))
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubEnabled
        If aSub(j)\bSubTypeHasAuds
          k = aSub(j)\nFirstPlayIndex
          If k >= 0
            debugMsg(sProcName, "setting aAud(" + getAudLabel(k) + ")\nAudState (" + decodeCueState(aAud(k)\nAudState) + ") to " + decodeCueState(#SCS_CUE_COUNTDOWN_TO_START))
            aAud(k)\nAudState = #SCS_CUE_COUNTDOWN_TO_START
          EndIf
        EndIf
        debugMsg(sProcName, "setting aSub(" + getSubLabel(j) + ")\nSubState (" + decodeCueState(aSub(j)\nSubState) + ") to " + decodeCueState(#SCS_CUE_COUNTDOWN_TO_START))
        aSub(j)\nSubState = #SCS_CUE_COUNTDOWN_TO_START
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    ; commented out 6Apr2020 11.8.2.3am as \nCueState will be set in setCueState(), which will also then reload the grid row, etc
    ; debugMsg(sProcName, "setting aCue(" + getCueLabel(pCuePtr) + ")\nCueState (" + decodeCueState(aCue(pCuePtr)\nCueState) + ") To CountDown")
    ; aCue(pCuePtr)\nCueState = #SCS_CUE_COUNTDOWN_TO_START
    ; end commented out 6Apr2020 11.8.2.3am
    debugMsg(sProcName, "calling setCueState(" + getCueLabel(pCuePtr) + ")")
    setCueState(pCuePtr, #False, #False, #True)
    ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\qTimeToStart=" + traceTime(aCue(pCuePtr)\qTimeToStart))
  EndIf
  
EndProcedure

Procedure clearManualOffsets(pPrimaryAudPtr)
  PROCNAMECA(pPrimaryAudPtr)
  Protected i, j, k
  Protected nCuePtr
  Protected bWantThisCue
  
  If pPrimaryAudPtr >= 0
    nCuePtr = aAud(pPrimaryAudPtr)\nCueIndex
  Else
    ProcedureReturn
  EndIf
  
  For i = 1 To gnLastCue
    bWantThisCue = #False
    If i = nCuePtr
      bWantThisCue = #True  ; want to look for non-linked aud's in this cue
      
    ElseIf aCue(i)\nActivationMethodReqd = #SCS_ACMETH_AUTO
      If aCue(i)\nAutoActCuePtr = nCuePtr
        bWantThisCue = #True  ; an auto-start cue based on the primary cue, and which is currently playing
      EndIf
    EndIf
    
    If bWantThisCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeHasAuds And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstPlayIndex
          While k >= 0
            If k <> pPrimaryAudPtr
              If aAud(k)\nLinkedToAudPtr <> pPrimaryAudPtr
                aAud(k)\nManualOffset = 0
                debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState) + ", \nManualOffset=" + Str(aAud(k)\nManualOffset))
              EndIf
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i

EndProcedure

Procedure resetLinks(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  Protected i
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling setLinksForCue() for each cue")
  For i = pCuePtr To gnLastCue
    setLinksForCue(i)
  Next i
  
  ; set links for auds within each sub
  ; debugMsg(sProcName, "calling setLinksForAudsWithinSubsForCue() for each cue")
  For i = pCuePtr To gnLastCue
    setLinksForAudsWithinSubsForCue(i)
  Next i
  
  setMTCLinksForAllCues()
  
  ; debugMsg(sProcName, "calling buildAudSetArray()")
  buildAudSetArray()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s getSubTypeForAud(pAudPtr)
  Protected nSubIndex
  
  nSubIndex = aAud(pAudPtr)\nSubIndex
  ProcedureReturn aSub(nSubIndex)\sSubType
EndProcedure

Procedure getFileScanMaxLength(sSubType.s)
  If sSubType = "A"
    ProcedureReturn grEditingOptions\nFileScanMaxLengthVideo
  Else
    ProcedureReturn grEditingOptions\nFileScanMaxLengthAudio
  EndIf
EndProcedure

Procedure getFileScanMaxLengthMS(sSubType.s)
  If sSubType = "A"
    ProcedureReturn grEditingOptions\nFileScanMaxLengthVideoMS
  Else
    ProcedureReturn grEditingOptions\nFileScanMaxLengthAudioMS
  EndIf
EndProcedure

; EOF