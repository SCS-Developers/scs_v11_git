; File: mmedia2.pbi

EnableExplicit

Procedure.s buildHandleProcName(pProcName.s, nHandle)
  If nHandle <> 0
    ProcedureReturn pProcName + "[" + decodeHandle(nHandle) + "]"
  Else
    ProcedureReturn pProcName
  EndIf
EndProcedure

Procedure setAudChannelAttributes(pAudPtr, nDev, fBVLevel.f, fPan.f)
  PROCNAMECA(pAudPtr)
  Protected nBassResult.l, nAudChannel.l, nAltAudChannel.l
  Protected n1, m1
  Protected n, m
  Protected fBassCurrentVol.f, fBassCurrentPan.f
  Protected sPXChanListLeft.s, sPXChanListRight.s
  Protected fBVLevelLeft.f, fBVLevelRight.f, fPanFactor.f
  Protected sLeft.s, sRight.s
  Protected sSetGainCommandString.s
  Protected fMyBVLevel.f, fMyPan.f
  
  fMyPan = fPan
  If fMyPan <> #SCS_NOPANCHANGE_SINGLE And fMyPan <> #SCS_PANCENTRE_SINGLE
    If aAud(pAudPtr)\nSelectedDeviceOutputs[nDev] <> 2
      fMyPan = #SCS_PANCENTRE_SINGLE
    EndIf
  EndIf
  
  fMyBVLevel = fBVLevel
  If fMyBVLevel <> #SCS_NOVOLCHANGE_SINGLE ; Test added 14Nov2022 11.9.7ae to fix bug reported by Simon Wicks
    If fMyBVLevel <= grLevels\fMinBVLevel
      ; debugMsg(sProcName, "setting fMyBVLevel=0.0 (was " + StrF(fMyBVLevel) + "), grLevels\fMinBVLevel=" + StrF(grLevels\fMinBVLevel))
      fMyBVLevel = 0.0
    EndIf
  EndIf
  
  If gbUseBASS  ; BASS
    nAudChannel = aAud(pAudPtr)\nBassChannel[nDev]
    nAltAudChannel = aAud(pAudPtr)\nBassAltChannel[nDev]
    
    If fMyBVLevel <> #SCS_NOVOLCHANGE_SINGLE
      nBassResult = BASS_ChannelGetAttribute(nAudChannel, #BASS_ATTRIB_VOL, @fBassCurrentVol)
      If fBassCurrentVol <> fMyBVLevel
        nBassResult = BASS_ChannelSetAttribute(nAudChannel, #BASS_ATTRIB_VOL, fMyBVLevel)
        CompilerIf #cTraceSetLevels
          debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nAudChannel) + ", BASS_ATTRIB_VOL, " + formatLevel(fMyBVLevel) + ")", nBassResult)
        CompilerEndIf
      EndIf
    EndIf
    
    If fMyPan <> #SCS_NOPANCHANGE_SINGLE
      If aAud(pAudPtr)\bUseMatrix[nDev] = #False
        nBassResult = BASS_ChannelGetAttribute(nAudChannel, #BASS_ATTRIB_PAN, @fBassCurrentPan)
        If fBassCurrentPan <> fMyPan
          nBassResult = BASS_ChannelSetAttribute(nAudChannel, #BASS_ATTRIB_PAN, fMyPan)
          CompilerIf #cTraceSetLevels
            debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nAudChannel) + ", #BASS_ATTRIB_PAN, " + tracePan(fMyPan) + ")", nBassResult)
          CompilerEndIf
          If nAltAudChannel <> 0
            nBassResult = BASS_ChannelSetAttribute(nAltAudChannel, #BASS_ATTRIB_PAN, fMyPan)
          EndIf
        EndIf
      Else
        With aAud(pAudPtr)
          n1 = \nMatrixOutputs[nDev]  ; matrix outputs
          m1 = \nNrOfInputChans       ; matrix inputs
          For n = \nMatrixOutputOffSet[nDev] To (\nMatrixOutputOffSet[nDev] + \nSelectedDeviceOutputs[nDev] - 1)
            If m1 = 1
              m = 0
              If fMyPan = 0       ; center
                \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev]
              ElseIf fMyPan < 0   ; pan left
                If (n = \nMatrixOutputOffSet[nDev])
                  \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev]                ; left at full volume
                Else
                  \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev] * (1 + fMyPan)  ; right attenuated
                EndIf
              Else                    ; pan right
                If (n = \nMatrixOutputOffSet[nDev])
                  \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev] * (1 - fMyPan)  ; left attenuated
                Else
                  \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev]                ; right at full volume
                EndIf
              EndIf
            Else
              For m = 0 To (m1 - 1)
                If m = (n - \nMatrixOutputOffSet[nDev])
                  If fMyPan = 0       ; center
                    \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev]
                  ElseIf fMyPan < 0   ; pan left
                    If (m % m1) = 0
                      \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev]                ; left at full volume
                    Else
                      \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev] * (1 + fMyPan)  ; right attenuated
                    EndIf
                  Else                    ; pan right
                    If (m % m1) = 0
                      \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev] * (1 - fMyPan)  ; left attenuated
                    Else
                      \aMixerMatrix[nDev]\aMatrix[(n * m1) + m] = \nMatrixFactor[nDev]                ; right at full volume
                    EndIf
                  EndIf
                EndIf
              Next m
            EndIf
          Next n
          nBassResult = BASS_Mixer_ChannelSetMatrix(\nBassChannel[nDev], @\aMixerMatrix[nDev]\aMatrix[0])
          If \nBassAltChannel[nDev] <> 0
            nBassResult = BASS_Mixer_ChannelSetMatrix(\nBassAltChannel[nDev], @\aMixerMatrix[nDev]\aMatrix[0])
          EndIf
        EndWith
      EndIf
    EndIf
    
  Else  ; SM-S
    If fMyPan = #SCS_PANCENTRE_SINGLE
      fBVLevelLeft = fMyBVLevel
      fBVLevelRight = fMyBVLevel
    ElseIf fMyPan < 0   ; pan left
      fBVLevelLeft = fMyBVLevel
      fPanFactor = 1 - (fMyPan * -1)
      fBVLevelRight = fMyBVLevel * fPanFactor
    Else              ; pan right
      fBVLevelRight = fMyBVLevel
      fPanFactor = 1 - fMyPan
      fBVLevelLeft = fMyBVLevel * fPanFactor
    EndIf
    
    sLeft = " gain " + makeSMSGainString(fBVLevelLeft)
    sRight = " gain " + makeSMSGainString(fBVLevelRight)
    
    With aAud(pAudPtr)
      sPXChanListLeft = \sDevPXChanListLeft[nDev]
      sPXChanListRight = \sDevPXChanListRight[nDev]
    EndWith
    
    If Len(sPXChanListLeft) > 0
      sSetGainCommandString + " " + sPXChanListLeft + sLeft
    EndIf
    If Len(sPXChanListRight) > 0
      sSetGainCommandString + " " + sPXChanListRight + sRight
    EndIf
    If Len(sSetGainCommandString) > 0
      sendSMSCommand("set" + sSetGainCommandString, #False)
    EndIf
    
  EndIf
EndProcedure

Procedure stopAud(pAudPtr, bKeepOpen=#False, bUseCas=#False, bHideVideo=#True, bForceCallSetCueState=#False)
  PROCNAMECA(pAudPtr)
  Protected h, nTmpAudPtr, bPLKeepOpen, bForceStopNotSlide
  Protected bCloseVideo
  Protected bCallSetCueState
  Protected bHoldAudIgnoreInStatusCheck
  Protected bHoldSubIgnoreInStatusCheck
  Protected nThisSubPtr
  Protected nReqdAudState
  Protected k
  Protected nBassResult.l
  
  debugMsg(sProcName, #SCS_START + ", bKeepOpen=" + strB(bKeepOpen) + ", bUseCas=" + strB(bUseCas) + ", bHideVideo=" + strB(bHideVideo))
  
  If pAudPtr < 0
    ProcedureReturn
  EndIf
  
  If aAud(pAudPtr)\nAudState > #SCS_CUE_COMPLETED
    ; possibly 'error'
    debugMsg(sProcName, "exiting because \nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState))
    ProcedureReturn
  EndIf
  
  If aAud(pAudPtr)\bAudTypeA
    If gnThreadNo > #SCS_THREAD_MAIN
      ; debugMsg3(sProcName, "transfer request to main thread")
      samAddRequest(#SCS_SAM_STOP_AUD, pAudPtr, 0, bKeepOpen)
      ProcedureReturn
    EndIf
  EndIf
  
  gbInStopAud = #True ; Added 17Jan2023 11.9.8ad
  nThisSubPtr = aAud(pAudPtr)\nSubIndex
  
  bHoldAudIgnoreInStatusCheck = aAud(pAudPtr)\bIgnoreInStatusCheck
  aAud(pAudPtr)\bIgnoreInStatusCheck = #True
  ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bIgnoreInStatusCheck=" + strB(aAud(pAudPtr)\bIgnoreInStatusCheck))
  bHoldSubIgnoreInStatusCheck = aSub(nThisSubPtr)\bIgnoreInStatusCheck
  aSub(nThisSubPtr)\bIgnoreInStatusCheck = #True
  ; debugMsg(sProcName, "aSub(" + getSubLabel(nThisSubPtr) + ")\bIgnoreInStatusCheck=" + strB(aSub(nThisSubPtr)\bIgnoreInStatusCheck))
  THR_waitForCueStatusChecksToEnd()
  debugMsg3(sProcName, "returned from THR_waitForCueStatusChecksToEnd()")
  
  For h = 0 To aAud(pAudPtr)\nMaxAudSetPtr2
    nTmpAudPtr = gaAudSet(pAudPtr, h)
    If nTmpAudPtr > 0
      With aAud(nTmpAudPtr)
        debugMsg(sProcName, "nTmpAudPtr=" + getAudLabel(nTmpAudPtr))
        
        bPLKeepOpen = #False
        If \bAudTypeAorP
          If (aSub(\nSubIndex)\bHotkey) Or (aSub(\nSubIndex)\bExtAct) ; Or (aSub(\nSubIndex)\bCallableCue) [blocked out callable cue test 28Feb2017 11.6.0 following bug report "SCS 11.6.0 RC3 Playlist as Callable Cue"]
            debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\bHotkey=" + strB(aSub(\nSubIndex)\bHotkey) + ", \bExtAct=" + strB(aSub(\nSubIndex)\bExtAct))
            bPLKeepOpen = #True
          ElseIf aSub(\nSubIndex)\bPLTerminating = #False
            ; If (aSub(\nSubIndex)\bPLRepeat) And (aSub(\nSubIndex)\nAudCount <= 2)
             ;  debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\bPLRepeat=" + strB(aSub(\nSubIndex)\bPLRepeat) + ", \nAudCount=" + aSub(\nSubIndex)\nAudCount)
            If (getPLRepeatActive(\nSubIndex)) And (aSub(\nSubIndex)\nAudCount <= 2)
              debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\bPLRepeat=" + strB(aSub(\nSubIndex)\bPLRepeat) + ", \bPLRepeatCancelled=" + strB(aSub(\nSubIndex)\bPLRepeatCancelled) + ", \nAudCount=" + aSub(\nSubIndex)\nAudCount)
              bPLKeepOpen = #True
            EndIf
          EndIf
        EndIf
        debugMsg(sProcName, "bPLKeepOpen=" + strB(bPLKeepOpen))
        
        If (bPLKeepOpen) Or (aSub(\nSubIndex)\bHotkey) Or (aSub(\nSubIndex)\bExtAct) Or (aSub(\nSubIndex)\bCallableCue) Or (\nAudState = #SCS_CUE_HIBERNATING) Or (\nAudState = #SCS_CUE_PAUSED)
          ; force StopOrFadeOutAudChannels to stop immediately because otherwise rewindAud will prevent the aud stopping.
          ; for hibernating playlists, force stop so that the whole playlist is not 'completed' when the slide finishes.
          bForceStopNotSlide = #True
        Else
          bForceStopNotSlide = #False
        EndIf
        
        If bKeepOpen
          bCloseVideo = #False
        Else
          bCloseVideo = #True
        EndIf
        
        If \nLinkedToAudPtr = -1 Or aSub(\nSubIndex)\bStartedInEditor
          debugMsg3(sProcName, "calling StopOrFadeOutAudChannels(" + getAudLabel(nTmpAudPtr) + ", " + strB(bForceStopNotSlide) + ", " + strB(bCloseVideo) + ", " + strB(bUseCas) + ", " + decodeVidPicTarget(\nAudVidPicTarget) + ", " + strB(bHideVideo) + ")")
          StopOrFadeOutAudChannels(nTmpAudPtr, bForceStopNotSlide, bCloseVideo, bUseCas, \nAudVidPicTarget, bHideVideo)
          debugMsg3(sProcName, "returned from StopOrFadeOutAudChannels()")
          ; Added 31Jan2022 11.9.0rc7
          If aSub(\nSubIndex)\bStartedInEditor
            debugMsg(sProcName, "calling removeAudChannelLoopSyncs(" + getAudLabel(nTmpAudPtr) + ")")
            removeAudChannelLoopSyncs(nTmpAudPtr)
          EndIf
          ; End added 31Jan2022 11.9.0rc7
        EndIf
        
        ; debugMsg0(sProcName, "bKeepOpen=" + strB(bKeepOpen) + ", bForceStopNotSlide=" + strB(bForceStopNotSlide) + ", " + getAudLabel(nTmpAudPtr) + "\nAudState=" +  decodeCueState(aAud(nTmpAudPtr)\nAudState) + ", \nPlayFromPos=" + \nPlayFromPos)
        If (bKeepOpen) And (\bAudTypeAorP Or \bAudTypeF)
          If bForceStopNotSlide
            If \nPlayFromPos > 0
              debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nTmpAudPtr) + ", " + \nPlayFromPos + ")")
              reposAuds(nTmpAudPtr, \nPlayFromPos)
            Else
              debugMsg(sProcName, "calling rewindAud(" + getAudLabel(nTmpAudPtr) + ")")
              rewindAud(nTmpAudPtr)
            EndIf
          Else
            If \nPlayFromPos > 0
              samAddRequest(#SCS_SAM_REPOS_AUDS, nTmpAudPtr, 0, \nPlayFromPos, "", ElapsedMilliseconds() + gnStopFadeTime)
            Else
              samAddRequest(#SCS_SAM_REWIND_AUD, nTmpAudPtr, 0, 0, "", ElapsedMilliseconds() + gnStopFadeTime)
            EndIf
          EndIf
          audSetState(nTmpAudPtr, #SCS_CUE_READY, 9)
        Else
          If bPLKeepOpen
            debugMsg(sProcName, "calling rewindAud(" + getAudLabel(nTmpAudPtr) + ")")
            rewindAud(nTmpAudPtr)
          EndIf
          nReqdAudState = #SCS_CUE_COMPLETED
          If aCue(\nCueIndex)\bNonLinearCue
            If \bAudTypeAorP
              If \nNextPlayIndex = -1
                ; last aud in play order
                ; If aSub(\nSubIndex)\bPLRepeat = #False ; Test added 17Mar2022 11.9.1ao following email from Jason Mai "Playlist Cue in Non-Linear mode can not repeat"
                If getPLRepeatActive(\nSubIndex) = #False ; Test added 17Mar2022 11.9.1ao following email from Jason Mai "Playlist Cue in Non-Linear mode can not repeat"
                  nReqdAudState = #SCS_CUE_NOT_LOADED
                EndIf
              EndIf
            Else
              nReqdAudState = #SCS_CUE_NOT_LOADED
            EndIf
          EndIf
          debugMsg(sProcName, "setting \nAudState (" + decodeCueState(\nAudState) + ") to " + decodeCueState(nReqdAudState))
          debugMsg(sProcName, "calling endOfAud(" + getAudLabel(nTmpAudPtr) + ", " + decodeCueState(nReqdAudState) + ")")
          endOfAud(nTmpAudPtr, nReqdAudState)
          If aCue(\nCueIndex)\bNonLinearCue
            If \bAudTypeAorP
              If nReqdAudState = #SCS_CUE_NOT_LOADED
                ; reset all 'completed' aud's in this playlist to 'not loaded'
                k = aSub(\nSubIndex)\nFirstPlayIndex
                While k >= 0
                  If aAud(k)\nAudState = #SCS_CUE_COMPLETED
                    aAud(k)\nAudState = #SCS_CUE_NOT_LOADED
                  EndIf
                  k = aAud(k)\nNextPlayIndex
                Wend
              EndIf
            EndIf
          EndIf
        EndIf
        gnCallOpenNextCues = 1
        debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
        
        \nLoopPassNo = 0
        
        bCallSetCueState = #True
        If bForceCallSetCueState = #False
          debugMsg(sProcName, "\bAudTypeP=" + strB(\bAudTypeP) + ", \bAudTypeAorP=" + strB(\bAudTypeAorP) + ", \nNextPlayIndex=" + \nNextPlayIndex)
          If \bAudTypeAorP
            ; If \nNextPlayIndex >= 0 Or aSub(\nSubIndex)\bPLRepeat
            If \nNextPlayIndex >= 0 Or getPLRepeatActive(\nSubIndex)
              bCallSetCueState = #False
            EndIf
          EndIf
        EndIf
        
        If bCallSetCueState
          debugMsg(sProcName, "calling setCueState(" + \nCueIndex + ")")
          setCueState(\nCueIndex)
          debugMsg(sProcName, "calling updateGrid(" + \nCueIndex + ")")
          updateGrid(\nCueIndex)
        EndIf
        
        If (bKeepOpen = #False) And (bPLKeepOpen = #False)
          debugMsg(sProcName, "calling closeAud(" + getAudLabel(nTmpAudPtr) + ") bStartedInEditor=" + strB(aSub(\nSubIndex)\bStartedInEditor) + ", bKeepOpen=" + strB(bKeepOpen) + ", bPLKeepOpen=" + strB(bPLKeepOpen))
          closeAud(nTmpAudPtr)
          \nCuePos = \nAbsEndAt
          sendRAICueSetPosIfReqd(nTmpAudPtr)
          \nRelFilePos = \nRelEndAt
        Else  ; keep open
          ; If \bAudTypeF
            ; reposAuds(nTmpAudPtr, \nAbsStartAt)
          ; EndIf
        EndIf
        If \bAudTypeAorP
          debugMsg(sProcName, "(20) setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
          debugMsg(sProcName, "calling setCueToGo()")
          setCueToGo()
          gbCallSetNavigateButtons = #True
        EndIf
        
        If \bAudTypeI
          If gbStoppingEverything = #False
            WCN_setLiveOnInds()
          EndIf
        EndIf
        
        \bStopCompleted = #True
      EndWith
    EndIf
  Next h

  If gbUseBASSMixer = #False
    samAddRequest(#SCS_SAM_BUILD_DEV_CHANNEL_LIST)
  EndIf
  
  aAud(pAudPtr)\bIgnoreInStatusCheck = bHoldAudIgnoreInStatusCheck
  aSub(nThisSubPtr)\bIgnoreInStatusCheck = bHoldSubIgnoreInStatusCheck
  
  If gnPlayingAudTypeForPPtr = pAudPtr
    gnPlayingAudTypeForPPtr = -1
    debugMsg(sProcName, "gnPlayingAudTypeForPPtr=" + getAudLabel(gnPlayingAudTypeForPPtr))
  EndIf
  
  gbInStopAud = #False ; Added 17Jan2023 11.9.8ad
  debugMsg(sProcName, #SCS_END + ", gnCallOpenNextCues=" + gnCallOpenNextCues)
  
EndProcedure

Procedure StopOrFadeOutAudChannels(pAudPtr, bForceStopNotSlide=#False, bCloseVideo=#False, bUseCas=#False, pVidPicTarget=#SCS_VID_PIC_TARGET_NONE, bHideVideo=#True)
  PROCNAMECA(pAudPtr)
  Protected nBassResult.l, d
  Protected nAudChannel.l, nAltAudChannel.l
  Protected nMixerStreamHandle.l, nFlags.l, fVolume.f, bFadeOut
  Protected rCasInfo.tyCasItem
  Protected sSetGainCommandString.s
  Protected nMyStopFadeTime
  Protected bUse2DDrawing
  
  debugMsg(sProcName, #SCS_START + ", bForceStopNotSlide=" + strB(bForceStopNotSlide) + ", bCloseVideo=" + strB(bCloseVideo) + ", bUseCas=" + strB(bUseCas) +
                      ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", bHideVideo=" + strB(bHideVideo))
  
  rCasInfo\nCasGroupId = -1
  
  With aAud(pAudPtr)
    debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", \nFileFormat=" + decodeFileFormat(\nFileFormat))
    If \nAudState > #SCS_CUE_COMPLETED
      ; possibly 'error'
      debugMsg(sProcName, "exiting because \nAudState=" + decodeCueState(\nAudState))
      ProcedureReturn
    EndIf
    
    ; Modified 17May2024 11.10.3aa following bug reported by Jason Mai where the logo image was not re-displayed after 'stop everything'
    ; This was because 2DDrawing was not made available by checkUse2DDrawing(), but when stoping everything then 2DDrawing is required
    ; if a logo image is to be displayed.
    If pVidPicTarget >= #SCS_VID_PIC_TARGET_F2 ; ">= #SCS_VID_PIC_TARGET_F2" test added 20May2023 11.10.3ac to prevent "grVidPicTarget(pVidPicTarget)\..." crashing when pVidPicTarget < 0
      If gbStoppingEverything And grVidPicTarget(pVidPicTarget)\nLogoImageNo
        bUse2DDrawing = #True
      Else
        bUse2DDrawing = checkUse2DDrawing(\nSubIndex)
      EndIf        
    Else
      bUse2DDrawing = checkUse2DDrawing(\nSubIndex)
    EndIf
    ; End modified 17May2024 11.10.3aa
    
    ; debugMsg(sProcName, "gbStoppingEverything=" + strB(gbStoppingEverything) + ", gbFadingEverything=" + strB(gbFadingEverything) + ", gnFadeEverythingTime=" + gnFadeEverythingTime)
    If gbStoppingEverything
      If gbFadingEverything
        nMyStopFadeTime = gnFadeEverythingTime
      Else
        nMyStopFadeTime = -1
      EndIf
      If nMyStopFadeTime < 0
        If (gnCurrAudioDriver = #SCS_DRV_BASS_DS) Or (gnCurrAudioDriver = #SCS_DRV_BASS_WASAPI)
          nMyStopFadeTime = 20
        Else
          nMyStopFadeTime = gnStopFadeTime
        EndIf
      EndIf
    Else
      nMyStopFadeTime = gnStopFadeTime
    EndIf
    ; debugMsg(sProcName, "nMyStopFadeTime=" + nMyStopFadeTime)
    
    If (\bAudTypeA) And (\nVideoSource = #SCS_VID_SRC_CAPTURE)
      ; debugMsg(sProcName, "calling stopVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + strB(bCloseVideo) + ", " + strB(bHideVideo) + ")")
      stopVideo(pAudPtr, pVidPicTarget, bCloseVideo, bHideVideo)
    Else
      Select \nFileFormat
        Case #SCS_FILEFORMAT_LIVE_INPUT
          stopLiveInput(pAudPtr, nMyStopFadeTime)
          
        Case #SCS_FILEFORMAT_MIDI
          stopMidiFile(pAudPtr)
          
        Case #SCS_FILEFORMAT_PICTURE
          If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
            ; debugMsg(sProcName, "calling stopVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + strB(bCloseVideo) + ", " + strB(bHideVideo) + ")")
            stopVideo(pAudPtr, pVidPicTarget, bCloseVideo, bHideVideo)
          ElseIf (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (bUse2DDrawing = #False)
            ; debugMsg(sProcName, "calling stopVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + strB(bCloseVideo) + ", " + strB(bHideVideo) + ")")
            stopVideo(pAudPtr, pVidPicTarget, bCloseVideo, bHideVideo)
          Else
            If pVidPicTarget <> #SCS_VID_PIC_TARGET_NONE
              debugMsg(sProcName, "calling hidePicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
              hidePicture(pAudPtr, pVidPicTarget)
            EndIf
          EndIf
          If \bBlending
            \bBlending = #False
            ; debugMsg(sProcName, "\bBlending=" + strB(\bBlending))
          EndIf
          
        Case #SCS_FILEFORMAT_VIDEO
          ; debugMsg(sProcName, "calling stopVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + strB(bCloseVideo) + ", " + strB(bHideVideo) + ")")
          stopVideo(pAudPtr, pVidPicTarget, bCloseVideo, bHideVideo)
          
        Case #SCS_FILEFORMAT_CAPTURE
          ; debugMsg(sProcName, "calling stopVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + strB(bCloseVideo) + ", " + strB(bHideVideo) + ")")
          stopVideo(pAudPtr, pVidPicTarget, bCloseVideo, bHideVideo)
          
        Case #SCS_FILEFORMAT_AUDIO
          If gbUseBASS  ; BASS
            ;{
            ; debugMsg(sProcName, "\nFirstSoundingDev=" + \nFirstSoundingDev + ", \nLastSoundingDev=" + \nLastSoundingDev)
            For d = \nFirstSoundingDev To \nLastSoundingDev ; do the loop of devices because whereas Stop will stop all linked files, Slide won't.
              
              If \bAudUseGaplessStream
                If d = \nFirstSoundingDev
                  nAudChannel = \nSourceChannel
                  If (nAudChannel <> 0) And (\nAudGaplessSeqPtr >= 0)
                    If gaGaplessSeqs(\nAudGaplessSeqPtr)\nCurrGaplessAudPtr = pAudPtr
                      nBassResult = BASS_Mixer_ChannelRemove(nAudChannel)
                      debugMsg2(sProcName, "BASS_Mixer_ChannelRemove(" + decodeHandle(nAudChannel) + ")", nBassResult)
                      If nBassResult = #BASSTRUE
                        gaGaplessSeqs(\nAudGaplessSeqPtr)\nCurrGaplessAudPtr = -1
                      Else
                        debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
                      EndIf
                    EndIf
                  EndIf
                Else
                  nAudChannel = 0
                EndIf
              Else
                debugMsg(sProcName, "\nBassChannel[" + d + "]=" + decodeHandle(\nBassChannel[d]))
                nAudChannel = \nBassChannel[d]
              EndIf
              
              debugMsg(sProcName, "d=" + d + ", \nFirstSoundingDev=" + \nFirstSoundingDev + ", nAudChannel=" + decodeHandle(nAudChannel) + ", \bAudUseGaplessStream=" + strB(\bAudUseGaplessStream) + ", \nAudGaplessSeqPtr=" + \nAudGaplessSeqPtr)
              If nAudChannel <> 0
                If (gbUseBASSMixer) And (\bAudUseGaplessStream = #False)
                  nMixerStreamHandle = gaMixerStreams(\nMixerStreamPtr[d])\nMixerStreamHandle
                  nBassResult = BASS_ChannelIsActive(nAudChannel)
                  debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(nAudChannel) + ")", nBassResult)
                  If (nBassResult = #BASS_ACTIVE_PLAYING) And (bForceStopNotSlide = #False)
                    \bStopping[d] = #True
                    If bUseCas
                      rCasInfo\nCasCueAction = #SCS_CAS_FADE_OUT
                      rCasInfo\nCasTime = nMyStopFadeTime
                      rCasInfo\nCasChannel = nAudChannel
                      rCasInfo\nCasMixerStream = nMixerStreamHandle
                      rCasInfo\sCasOriginProcName = sProcName
                      grCasItem = rCasInfo
                      casAddRequest()
                    Else
                      nBassResult = BASS_ChannelGetAttribute(nAudChannel, #BASS_ATTRIB_VOL, @fVolume)
                      debugMsg(sProcName, "BASS_ChannelGetAttribute(" + decodeHandle(nAudChannel) + ", #BASS_ATTRIB_VOL, @fVolume) returned " + nBassResult + ", fVolume=" + StrF(fVolume,4))
                      If nBassResult = #BASSTRUE
                        If fVolume <> #SCS_MINVOLUME_SINGLE
                          bFadeOut = #True
                        EndIf
                      Else
                        bFadeOut = #True
                      EndIf
                      If bFadeOut
                        CompilerIf 1=2 ; 31Jan2022 11.9.0rc7
                          nBassResult = BASS_ChannelSetAttribute(nAudChannel, #BASS_ATTRIB_VOL, fVolume)
                          debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nAudChannel) + ", #BASS_ATTRIB_VOL, " + StrF(fVolume) + ")", nBassResult)
                        CompilerElse
                          nBassResult = BASS_ChannelSlideAttribute(nAudChannel, #BASS_ATTRIB_VOL, 0, nMyStopFadeTime)
                          debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nAudChannel) + ", BASS_ATTRIB_VOL, 0, " + nMyStopFadeTime + ")", nBassResult)
                        CompilerEndIf
                      EndIf
                    EndIf
                  Else
                    If bUseCas
                      rCasInfo\nCasCueAction = #SCS_CAS_MIXER_PAUSE
                      rCasInfo\nCasChannel = nAudChannel
                      rCasInfo\nCasMixerStream = nMixerStreamHandle
                      rCasInfo\sCasOriginProcName = sProcName
                      grCasItem = rCasInfo
                      casAddRequest()
                    Else
                      If \bAudUseGaplessStream = #False
                        nBassResult = BASS_Mixer_ChannelFlags(nAudChannel, #BASS_MIXER_CHAN_PAUSE, #BASS_MIXER_CHAN_PAUSE) ; set the pause flag
                        debugMsg3(sProcName, "BASS_Mixer_ChannelFlags(" + decodeHandle(nAudChannel) + ", BASS_MIXER_CHAN_PAUSE, BASS_MIXER_CHAN_PAUSE) returned " + decodeMixerChannelFlags(nBassResult))
                      EndIf
                    EndIf
                    \bStopping[d] = #False
                  EndIf
                Else
                  nBassResult = BASS_ChannelIsActive(nAudChannel)
                  debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(nAudChannel) + ")", nBassResult)
                  If (nBassResult = #BASS_ACTIVE_PLAYING) And (bForceStopNotSlide = #False)
                    \bStopping[d] = #True
                    nBassResult = BASS_ChannelSlideAttribute(nAudChannel, #BASS_ATTRIB_VOL, -2, nMyStopFadeTime)
                    debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nAudChannel) + ", BASS_ATTRIB_VOL, -2, " + nMyStopFadeTime + ")", nBassResult)
                  Else
                    nBassResult = BASS_ChannelStop(nAudChannel)
                    debugMsg2(sProcName, "BASS_ChannelStop(" + decodeHandle(nAudChannel) + ")", nBassResult)
                    \bStopping[d] = #False
                  EndIf
                  ; Commented out the following 11Apr2025 11.10.8ay after email from Detlef Rosenthal about 'fade all' causing a jump and uneven fade.
                  ; On reproducing the error, it appears to be due to this call to BASS_Split_StreamReset().
;                   If (\bUsingSplitStream) And (\bAudUseGaplessStream = #False)
;                     If d = \nLastSoundingDev
;                       debugMsg(sProcName, "calling BASS_Split_StreamReset(" + decodeHandle(\nSourceChannel) + ")")
;                       nBassResult = BASS_Split_StreamReset(\nSourceChannel)
;                       debugMsg2(sProcName, "BASS_Split_StreamReset(" + decodeHandle(\nSourceChannel) + ")", nBassResult)
;                     EndIf
;                   EndIf
                EndIf
              EndIf
              
              nAltAudChannel = \nBassAltChannel[d]
              If nAltAudChannel <> 0
                If gbUseBASSMixer
                  nBassResult = BASS_ChannelIsActive(nAltAudChannel)
                  debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(nAltAudChannel) + ")", nBassResult)
                  If (nBassResult = #BASS_ACTIVE_PLAYING) And (bForceStopNotSlide = #False)
                    \bAltStopping[d] = #True
                    If bUseCas
                      rCasInfo\nCasCueAction = #SCS_CAS_FADE_OUT
                      rCasInfo\nCasTime = nMyStopFadeTime
                      rCasInfo\nCasChannel = nAltAudChannel
                      rCasInfo\sCasOriginProcName = sProcName
                      grCasItem = rCasInfo
                      casAddRequest()
                    Else
                      ; nBassResult = BASS_ChannelSlideAttribute(nAltAudChannel, #BASS_ATTRIB_VOL, -2, nMyStopFadeTime)
                      ; debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nAltAudChannel) + ", BASS_ATTRIB_VOL, -2, " + nMyStopFadeTime + ")", nBassResult)
                      ; fix 17Jan2019 11.8.0ad - changed -2 to 0 following test of loop with crossfade
                      ; - open cue file "Cross-Fade Test 2.scs11"; go directly to editor; play Q1 allowing it to reach end of loop (once); stop Q1
                      ; - close editor; play Q1 from main window; at end of loop playback stopped
                      ; that was because the -2 in BASS_ChannelSlideAttribute had caused the channel to be stopped at the end of the slide
                      nBassResult = BASS_ChannelSlideAttribute(nAltAudChannel, #BASS_ATTRIB_VOL, 0, nMyStopFadeTime)
                      debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nAltAudChannel) + ", BASS_ATTRIB_VOL, 0, " + nMyStopFadeTime + ")", nBassResult)
                    EndIf
                  Else
                    nBassResult = BASS_Mixer_ChannelFlags(nAltAudChannel, #BASS_MIXER_CHAN_PAUSE, #BASS_MIXER_CHAN_PAUSE) ; set the pause flag
                    debugMsg3(sProcName, "BASS_Mixer_ChannelFlags(" + decodeHandle(nAltAudChannel) + ", BASS_MIXER_CHAN_PAUSE, BASS_MIXER_CHAN_PAUSE) returned " + decodeMixerChannelFlags(nBassResult))
                    \bAltStopping[d] = #False
                  EndIf
                Else
                  nBassResult = BASS_ChannelIsActive(nAltAudChannel)
                  debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(nAltAudChannel) + ")", nBassResult)
                  If (nBassResult = #BASS_ACTIVE_PLAYING) And (bForceStopNotSlide = #False)
                    \bAltStopping[d] = #True
                    ; nBassResult = BASS_ChannelSlideAttribute(nAltAudChannel, #BASS_ATTRIB_VOL, -2, nMyStopFadeTime)
                    ; debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nAltAudChannel) + ", BASS_ATTRIB_VOL, -2, " + nMyStopFadeTime + ")", nBassResult)
                    ; fix 17Jan2019 11.8.0ad - changed -2 to 0 - see comments above
                    nBassResult = BASS_ChannelSlideAttribute(nAltAudChannel, #BASS_ATTRIB_VOL, 0, nMyStopFadeTime)
                    debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nAltAudChannel) + ", BASS_ATTRIB_VOL, 0, " + nMyStopFadeTime + ")", nBassResult)
                  Else
                    nBassResult = BASS_ChannelStop(nAltAudChannel)
                    debugMsg2(sProcName, "BASS_ChannelStop(" + decodeHandle(nAltAudChannel) + ")", nBassResult)
                    \bAltStopping[d] = #False
                  EndIf
                  ; Commented out the following 11Apr2025 11.10.8ay after email from Detlef Rosenthal about 'fade all' causing a jump and uneven fade.
                  ; See explanation for similar code earlier in this Procedure.
;                   If \bUsingSplitStream
;                     If d = \nLastSoundingDev
;                       debugMsg(sProcName, "calling BASS_Split_StreamReset(" + decodeHandle(\nSourceChannel) + ")")
;                       nBassResult = BASS_Split_StreamReset(\nSourceChannel)
;                       debugMsg2(sProcName, "BASS_Split_StreamReset(" + decodeHandle(\nSourceChannel) + ")", nBassResult)
;                     EndIf
;                   EndIf
                EndIf
              EndIf
              
            Next d
            ;}
          Else  ; SM-S
            ;{
            ; debugMsg0(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sSyncPChanList=" + \sSyncPChanList + ", aCue(" + getCueLabel(\nCueIndex) + ")\nActivationMethod=" + decodeActivationMethod(aCue(\nCueIndex)\nActivationMethod) + ", \nSMSGroup=" + aCue(\nCueIndex)\nSMSGroup)
            If \sSyncPChanList
              If aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_LTC And aCue(\nCueIndex)\nSMSGroup >= 0
                If pAudPtr = getFirstEnabledAudTypeForCue(\nCueIndex)
                  sendSMSCommand("stop g" + aCue(\nCueIndex)\nSMSGroup)
                  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPlayingPos=" + aAud(pAudPtr)\nPlayingPos + ", \nRelFilePos=" + aAud(pAudPtr)\nRelFilePos)
                  sendSMSCommand("rewind g" + aCue(\nCueIndex)\nSMSGroup)
                  getAndWaitForTrackTime(pAudPtr)
                  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPlayingPos=" + aAud(pAudPtr)\nPlayingPos + ", \nRelFilePos=" + aAud(pAudPtr)\nRelFilePos)
                EndIf
              EndIf
              If nMyStopFadeTime <= 0
;                 If aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_LTC And aCue(\nCueIndex)\nSMSGroup >= 0
;                   sendSMSCommand("stop g" + aCue(\nCueIndex)\nSMSGroup)
;                 Else
                  sendSMSCommand("stop " + \sSyncPChanList)
;                 EndIf
              EndIf
              ; clear entire sPStatusResponse field so status for all channels in \sSyncPChanList will be cleared (so will not be found to be playing)
              grSMS\sPStatusResponse = ""
              If \bSyncPChanListPlaying
                If \sSyncPXChanList
                  sSetGainCommandString = "set chan " + \sSyncPXChanList + " gain 0"
                  If nMyStopFadeTime > 0
                    sSetGainCommandString + " fadetime " + StrF(nMyStopFadeTime/1000,2) ; ",2 added to StrF() 22Nov2021 11.8.6cd to avoid getting fade times like 0.1000000015
                  EndIf
                  ; debugMsg(sProcName, "nMyStopFadeTime=" + nMyStopFadeTime + ", sSetGainCommandString=" + sSetGainCommandString)
                  sendSMSCommand(sSetGainCommandString)
                  \bSetLevelsWhenPlayAud = #True
                EndIf
                ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bSetLevelsWhenPlayAud=" + strB(\bSetLevelsWhenPlayAud))
                \bSyncPChanListPlaying = #False
              EndIf
            EndIf
            For d = \nFirstSoundingDev To \nLastSoundingDev
              \bStopping[d] = #False
            Next d
            
            ; rebuild getSMSCurrInfo() command strings
            If gbStoppingEverything = #False
              debugMsg(sProcName, "calling buildGetSMSCurrInfoCommandStrings")
              buildGetSMSCurrInfoCommandStrings()
            EndIf
            ;}
          EndIf
          
      EndSelect
    EndIf ; EndIf Else (\bAudTypeA) And (\nVideoSource = #SCS_VID_SRC_CAPTURE)
    
    \bAudChannelsStopped = #True
    \nManualOffset = 0
    ; added 14Jun2018 11.7.1rc3 to resolve issue reported by Declan Brennan associated with StopAll during image fades
    If \bBlending
      \bBlending = #False
      debugMsg(sProcName, "\bBlending=" + strB(\bBlending))
    EndIf
    ; end added 14Jun2018 11.7.1rc3
    
    If gnPlayingAudTypeForPPtr = pAudPtr
      gnPlayingAudTypeForPPtr = -1
      debugMsg(sProcName, "gnPlayingAudTypeForPPtr=" + getAudLabel(gnPlayingAudTypeForPPtr))
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure stopMidiFile(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nErrCode.l
  Protected sMciString.s
  Protected bDummyDev
  
  ; warning! all mciSendString calls must be from the same thread or mciSendString returns error 263 (not a registered device), so use main thread
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  With aAud(pAudPtr)
    If \nAudState = #SCS_CUE_ERROR
      ProcedureReturn
    EndIf
    If Len(\sMidiAlias) = 0
      ProcedureReturn
    EndIf
    bDummyDev = gaMidiOutDevice(\nMidiPhysicalDevPtr)\bDummy
    debugMsg(sProcName, "gaMidiOutDevice(" + \nMidiPhysicalDevPtr + ")\bDummy=" + strB(gaMidiOutDevice(\nMidiPhysicalDevPtr)\bDummy) + ", bDummyDev=" + strB(bDummyDev))
    If bDummyDev = #False
      sMciString = "stop " + \sMidiAlias
      nErrCode = mciSendString_(sMciString, #Null, 0, #Null)
      debugMsg2(sProcName, "mciSendString_(" + sMciString + ", #Null, 0, #Null)", nErrCode)
      If nErrCode <> 0
        displayMidiError(nErrCode, sMciString, sProcName)
        ProcedureReturn
      EndIf
      ; added 25Oct2018 11.7.1.4au Richard Borsey
      sMciString = "seek " + \sMidiAlias + " to start"
      nErrCode = mciSendString_(sMciString, #Null, 0, #Null)
      debugMsg2(sProcName, "mciSendString_(" + sMciString + ", #Null, 0, #Null)", nErrCode)
      If nErrCode <> 0
        displayMidiError(nErrCode, sMciString, sProcName)
        ProcedureReturn
      EndIf
      ; end added 25Oct2018 11.7.1.4au
    EndIf
  EndWith
  
EndProcedure

Procedure stopLiveInput(pAudPtr, pStopFadeTime=0)
  PROCNAMECA(pAudPtr)
  Protected sCmdDetail.s
  
  debugMsg(sProcName, #SCS_START + ", pStopFadeTime=" + pStopFadeTime)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \bAudTypeI = #False
        ; shouldn't happen
        ProcedureReturn
      EndIf
      sCmdDetail = \sAudXChanList
      If Len(sCmdDetail) > 0
        sCmdDetail + " gain 0"
        If pStopFadeTime > 0
          sCmdDetail + " fadetime " + makeSMSTimeString(pStopFadeTime)
        EndIf
        sendSMSCommand("set chan " + Trim(sCmdDetail))
      EndIf
      
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure analyzeWavFile(sFileName.s, nBassChannel.l, bTrace=#False)
  PROCNAMEC()
  Protected nFileNo
  Protected nChunkId.l, nChunkSize.l        ; longs
  Protected nSubChunkId.l, nSubChunkSize.l  ; longs
  Protected nRIFFSize.l, nFmtSize.l         ; longs
  Protected nCuePoints.l                    ; long
  Protected nDataChunkSize.l                ; long
  Protected wavFmt.WAVEFORMATEX
  Protected wavCue.WAVE_CUEPOINT
  Protected wavLabel.WAVE_LABEL
  Protected wavSampler.WAVE_SAMPLER
  Protected WavSamplerData.WAVE_SAMPLER_DATA
  Protected *mem, *m, n, p
  Protected rCuePoint.tyCuePoint
  Protected qSeekPoint.q, qHoldLoc.q
  Protected nSamplesPerSec  ; nb named nSampleRate generally throughout SCS, but nSamplesPerSec in the Microsoft structure WAVEFORMATEX
  Protected sCuePointKey.s
  Protected qTmp.q
  Protected nFirstCPIndex = -1
  Protected nLastCPIndex = -1
  Protected nTmp
  Protected bKillThis
  Protected qFileSize.q
  
  debugMsgC(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName))

  If FileExists(sFileName, #False) = #False
    debugMsgC(sProcName, "File does not exist: " + sFileName)
    ProcedureReturn
  EndIf
  
  If grLicInfo\bCueMarkersAvailable = #False
    debugMsgC(sProcName, "exiting because grLicInfo\bCueMarkersAvailable=#False")
    ProcedureReturn
  EndIf
  
  ; debugMsg(sProcName, "calling listCuePointArray()")
  ; listCuePointArray()
  
  ; clear any existing cue points for this file - in case the cue points have been changed
  ;For p = 0 To gnMaxCuePoint
  For p = 0 To ArraySize(gaCuePoint())
    With gaCuePoint(p)
      If LCase(\sFileName) = LCase(sFileName)
        \sFileName = "*"
        \sCuePointKey = "*"
      EndIf
    EndWith
  Next p
  
  nFileNo = ReadFile(#PB_Any, sFileName, #PB_File_SharedRead)
  debugMsgC(sProcName, "nFileNo=" + nFileNo)
  
  If nFileNo
    debugMsgC_AWF(sProcName, "Lof(" + nFileNo + ")=" + Lof(nFileNo))
    qFileSize = FileSize(sFileName)
    debugMsgC_AWF(sProcName, "qFileSize=" + qFileSize)
    While Eof(nFileNo) = #False
      qHoldLoc = Loc(nFileNo)
      debugMsgC_AWF(sProcName, "qHoldLoc=" + qHoldLoc)
      nChunkId = ReadLong(nFileNo)
      debugMsgC(sProcName, "nChunkId=$" + Hex(nChunkId,#PB_Long))
      Select nChunkId
        Case $46464952  ; 'FFIR' = RIFF  (can't use 'FFIR' because program is compiled in Unicode mode)
          debugMsgC_AWF(sProcName, "-- RIFF found")
          nRIFFSize = ReadLong(nFileNo)
          debugMsgC_AWF(sProcName, "nRIFFSize=" + nRIFFSize)
          ; check for the ASCII-String "WAVE" that identifies the RIFF-chunk as WAV-Format
          If ReadLong(nFileNo) <> $45564157 ; 'EVAW' = WAVE
            Break
          EndIf
          debugMsgC_AWF(sProcName, "WAVE found")
          
        Case $20746D66, $20544D46   ; ' tmf', ' TMF' = fmt chunk
          debugMsgC_AWF(sProcName, "-- fmt found")
          nFmtSize = ReadLong(nFileNo)
          debugMsgC_AWF(sProcName, "nFmtSize=" + nFmtSize)
          With wavFmt
            \wFormatTag = ReadWord(nFileNo)
            \nChannels = ReadWord(nFileNo)
            grInfoAboutFile\nFileChannels = \nChannels
            \nSamplesPerSec = ReadLong(nFileNo)
            nSamplesPerSec = \nSamplesPerSec
            \nAvgBytesPerSec = ReadLong(nFileNo)
            \nBlockAlign = ReadWord(nFileNo)
            \wBitsPerSample = ReadWord(nFileNo)
            If nFmtSize > 16
              \cbSize = ReadWord(nFileNo)
            Else
              \cbSize = 0
            EndIf
            debugMsgC_AWF(sProcName, "\wFormatTag=" + \wFormatTag)
            debugMsgC_AWF(sProcName, "\nChannels=" + \nChannels)
            debugMsgC_AWF(sProcName, "\nSamplesPerSec=" + \nSamplesPerSec)
            debugMsgC_AWF(sProcName, "\nAvgBytesPerSec=" + \nAvgBytesPerSec)
            debugMsgC_AWF(sProcName, "\nBlockAlign=" + \nBlockAlign)
            debugMsgC_AWF(sProcName, "\wBitsPerSample=" + \wBitsPerSample)
            debugMsgC_AWF(sProcName, "\cbSize=" + \cbSize)
          EndWith
          qSeekPoint = qHoldLoc + nFmtSize + 8   ; +4 for chunk id, and +4 for length word
          If qSeekPoint & 1
            debugMsgC_AWF(sProcName, "increase qSeekPoint by 1")
            qSeekPoint + 1
          EndIf
          If qSeekPoint > qFileSize
            debugMsgC(sProcName, "(fmt) break loop because qSeekPoint (" + qSeekPoint + ") > qFileSize ( " + qFileSize + ")")
            bKillThis = #True
            Break
          EndIf
          FileSeek(nFileNo, qSeekPoint)
          
        Case $61746164, $41544144   ; 'atad', 'ATAD' = data chunk
          debugMsgC_AWF(sProcName, "-- data found")
          nDataChunkSize = ReadLong(nFileNo)
          debugMsgC_AWF(sProcName, "nDataChunkSize=" + nDataChunkSize)
          CompilerIf 1=2  ; enable this if data is to be read, otherwise we just skip over the rest of the data chunk
            *mem = AllocateMemory(nDataChunkSize)
            ReadData(nFileNo, *mem, nDataChunkSize)
            ; do something with the data, then:
            FreeMemory(*mem)
          CompilerElse
            ; skip over the rest of the data chunk
            qSeekPoint = Loc(nFileNo) + nDataChunkSize
            debugMsgC(sProcName, "Loc(" + nFileNo + ")=" + Loc(nFileNo) + ", nDataChunkSize=" + nDataChunkSize + ", qSeekPoint=" + qSeekPoint)
            If qSeekPoint & 1
              debugMsgC_AWF(sProcName, "increase qSeekPoint by 1")
              qSeekPoint + 1
            EndIf
            If qSeekPoint > qFileSize
              debugMsgC(sProcName, "(data) break loop because qSeekPoint (" + qSeekPoint + ") > qFileSize ( " + qFileSize + ")")
              bKillThis = #True
              Break
            EndIf
            FileSeek(nFileNo, qSeekPoint)
          CompilerEndIf
          
        Case $20657563, $20455543   ; ' euc', ' EUC' = cue chunk (cue points)
          debugMsgC_AWF(sProcName, "-- cue found")
          nChunkSize = ReadLong(nFileNo)
          nCuePoints = ReadLong(nFileNo)
          debugMsgC_AWF(sProcName, "nChunkSize=" + nChunkSize + ", nCuePoints=" + nCuePoints)
          If nChunkSize <= 4
            ; something's wrong so kill this
            bKillThis = #True
            Break
          EndIf
          ; Debug sProcName + "AllocateMemory(" + Str(nChunkSize-4) + ")"
          *mem = AllocateMemory(nChunkSize-4)  ; -4 because we have already read 4 bytes (1 long) for cuepoints
          debugMsgC_AWF(sProcName, "(cue) AllocateMemory(" + Str(nChunkSize-4) + "), *mem=" + *mem)
          ReadData(nFileNo, *mem, nChunkSize-4)
          rCuePoint\sFileName = sFileName
          *m = *mem
          For n = 1 To nCuePoints
            debugMsgC_AWF(sProcName, "----------------- n=" + n)
            With wavCue
              \dwIdentifier = PeekL(*m)
              *m+4
              \dwPosition = PeekL(*m)
              *m+4
              \fccChunk = PeekL(*m)    ; fccChunk
              *m+4
              \dwChunkStart = PeekL(*m)
              *m+4
              \dwBlockStart = PeekL(*m)
              *m+4
              \dwSampleOffset = PeekL(*m)    ; byte offset of cue point sample
              debugMsgC_AWF(sProcName, "\fccChunk=$" + Hex(\fccChunk, #PB_Long) + ", \dwChunkStart=" + \dwChunkStart + ", \dwPosition=" + \dwPosition + ", \dwBlockStart=" + \dwBlockStart + ", \dwSampleOffset=" + \dwSampleOffset + ", nSamplesPerSec=" + nSamplesPerSec)
              *m+4
              If \fccChunk = $61746164 Or \fccChunk = $41544144 ; 'atad' or 'ATAD' = data
                If nSamplesPerSec > 0
                  rCuePoint\nIdentifier = \dwIdentifier
                  rCuePoint\qSamplePos = \dwSampleOffset
                  rCuePoint\dTimePos = \dwSampleOffset / nSamplesPerSec
                  debugMsgC_AWF(sProcName, "\dTimePos=" + StrD(rCuePoint\dTimePos, 5) + ", \qSamplePos=" + rCuePoint\qSamplePos)
                  rCuePoint\sName = ""   ; name not yet known but may be populated later from a 'list' chunk
                  rCuePoint\sCuePointKey = sFileName + "{" + \dwIdentifier + "}"
                  debugMsgC_AWF(sProcName, "(cue) sCuePointKey=" + rCuePoint\sCuePointKey)
                  gnMaxCuePoint + 1
                  debugMsgC_AWF(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint)
                  If gnMaxCuePoint > ArraySize(gaCuePoint())
                    ReDim gaCuePoint(gnMaxCuePoint+50)  ; if using cue points then there may be many files with cue points, hence the +50 increase in size
                  EndIf
                  gaCuePoint(gnMaxCuePoint) = rCuePoint
                EndIf
              EndIf
            EndWith
          Next n
          FreeMemory(*mem)
          debugMsgC_AWF(sProcName, "(cue) FreeMemory(" + *mem + ")")
          
        Case $7473696C, $5453494C ; 'tsil', 'TSIL' = list chunk
          debugMsgC_AWF(sProcName, "-- list found")
          debugMsgC_AWF(sProcName, "Loc(" + nFileNo + ")=" + Loc(nFileNo))
          nChunkSize = ReadLong(nFileNo)
          debugMsgC_AWF(sProcName, "nChunkSize=" + nChunkSize)
          If nChunkSize > 0
            *mem = AllocateMemory(nChunkSize)
            debugMsgC_AWF(sProcName, "(list) AllocateMemory(" + nChunkSize + "), *mem=" + *mem)
            debugMsgC_AWF(sProcName, "*mem=" + *mem + ", nChunkSize=" + nChunkSize)
            debugMsgC_AWF(sProcName, "Loc(nFileNo)=" + Loc(nFileNo))
            ReadData(nFileNo, *mem, nChunkSize)
            If PeekL(*mem) = $6C746461 Or PeekL(*mem) = $4C544441   ; 'ltda' or 'LTDA' = adtl - associated data list
              debugMsgC_AWF(sProcName, "ltda found")
              *m = *mem+4
              While *m < (*mem + nChunkSize)
                debugMsgC_AWF(sProcName, "*m=" + *m)
                debugMsgC_AWF(sProcName, #SCS_BLANK)
                nSubChunkId = PeekL(*m)
                debugMsgC_AWF(sProcName, "nSubChunkId=$" + Hex(nSubChunkId))
                *m+4
                nSubChunkSize = PeekL(*m)
                debugMsgC_AWF(sProcName, "nSubChunkSize=" + nSubChunkSize)
                *m+4
                Select nSubChunkId
                  Case $6C62616C, $4C42414C   ; 'lbal', 'LBAL' = labl subchunk
                    debugMsgC_AWF(sProcName, "lbal found")
                    With wavLabel
                      \dwIdentifier = PeekL(*m)
                      debugMsgC_AWF(sProcName, "\dwIdentifier=" + \dwIdentifier)
                      *m+4
                      \dwText = PeekS(*m, -1, #PB_Ascii)
                      debugMsgC_AWF(sProcName, "\dwText=" + \dwText)
                      *m + nSubChunkSize - 4
                      sCuePointKey = sFileName + "{" + \dwIdentifier + "}"
                      debugMsgC_AWF(sProcName, "(list) sCuePointKey=" + sCuePointKey)
                      For p = 0 To gnMaxCuePoint
                        If gaCuePoint(p)\sCuePointKey = sCuePointKey
                          gaCuePoint(p)\sName = Trim(\dwText)
                          Break
                        EndIf
                      Next p
                    EndWith
                    
                  Case $65746F6E, $45544F4E   ; 'note', 'NOTE' = note subchunk
                    debugMsgC_AWF(sProcName, "note found")
                    With wavLabel
                      \dwIdentifier = PeekL(*m)
                      debugMsgC_AWF(sProcName, "\dwIdentifier=" + \dwIdentifier)
                      *m+4
                      \dwText = PeekS(*m, -1, #PB_Ascii)
                      debugMsgC_AWF(sProcName, "\dwText=" + \dwText)
                      *m + nSubChunkSize - 4
                    EndWith
                    
                  Case $7478746C, $5456544C   ; 'ltxt', 'LTXT' = ltxt subchunk
                    debugMsgC_AWF(sProcName, "ltxt found")
                    With wavLabel
                      \dwIdentifier = PeekL(*m)
                      debugMsgC_AWF(sProcName, "\dwIdentifier=" + \dwIdentifier)
                      *m+4
                      nTmp = PeekL(*m)
                      debugMsgC_AWF(sProcName,"Sample Length=" + nTmp)
                      *m+16 ; skip purpose, country, language, dialect adn code page
                      \dwText = PeekS(*m, -1, #PB_Ascii)
                      debugMsgC_AWF(sProcName, "\dwText=" + \dwText)
                      *m + nSubChunkSize - 20
                    EndWith
                    
                  Default   ; other subchunk
                    *m + nSubChunkSize
                    
                EndSelect
                If nSubChunkSize & 1
                  debugMsgC_AWF(sProcName, "increase *m by 1")
                  *m + 1
                EndIf
              Wend
              debugMsgC_AWF(sProcName, "*m=" + *m)
            EndIf
            FreeMemory(*mem)
            debugMsgC_AWF(sProcName, "(list) FreeMemory(" + *mem + ")")
          EndIf
          
        Default
          Select nChunkId
            Case $74636166, $54434146   ; 'fact', 'FACT'
              debugMsgC_AWF(sProcName, "-- fact found")
            Case $6C706D73, $4C504D53   ; 'smpl', 'SMPL' = sampler chunk
              debugMsgC_AWF(sProcName, "-- smpl found")
            Case $74786562, $54584542   ; 'bext', 'BEXT' = broadcast extension
              debugMsgC_AWF(sProcName, "-- bext found")
            Default
              debugMsgC_AWF(sProcName, "-- chunkId unknown or not needed: $" + Hex(nChunkId))
          EndSelect
          If Eof(nFileNo) = #False
            nChunkSize = ReadLong(nFileNo)
            ; skip over the rest of this chunk
            debugMsgC_AWF(sProcName, "Loc(" + nFileNo + ")=" + Loc(nFileNo) + ", nChunkSize=" + nChunkSize)
            If nChunkSize <= 0
              bKillThis = #True
              Break
            EndIf
            qSeekPoint = Loc(nFileNo) + nChunkSize
            If qSeekPoint & 1
              debugMsgC_AWF(sProcName, "increase qSeekPoint by 1")
              qSeekPoint + 1
            EndIf
            debugMsgC_AWF(sProcName, "qSeekPoint=" + qSeekPoint)
            If qSeekPoint > qFileSize
              debugMsgC_AWF(sProcName, "!!!! qSeekPoint > qFileSize - ftreat as Eof()")
              Break
            EndIf
            FileSeek(nFileNo, qSeekPoint)
          EndIf
          
      EndSelect
      
    Wend
    
    CloseFile(nFileNo)
    
    If bKillThis
      debugMsgC_AWF(sProcName, "bKillThis=#True")
      nCuePoints = 0
    EndIf
    
    ; remove any cue points without names and compact array
    compactCuePointArray()
    
    debugMsgC_AWF(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint + ", nCuePoints=" + nCuePoints)
    If nCuePoints > 0
      debugMsgC_AWF(sProcName, "Cue Point List for " + GetFilePart(sFileName))
      For p = 0 To gnMaxCuePoint
        With gaCuePoint(p)
          If \sFileName = sFileName
            If nFirstCPIndex = -1
              nFirstCPIndex = p
            EndIf
            nLastCPIndex = p
            debugMsgC_AWF(sProcName, "gaCuePoint(" + p + ")\sFileName=" + GetFilePart(\sFileName) + "  \nIdentifier=" + \nIdentifier + ", \qSamplePos=" + \qSamplePos + ", \dTimePos=" + StrD(\dTimePos, 5) + ", sName=" + \sName)
          EndIf
        EndWith
      Next p
    EndIf
    
  EndIf
  
  With grInfoAboutFile
    \sFileName = sFileName
    ; added 5May2017 11.6.1rc1 so that \nFileDuration is set as normal, if possible
    If nBassChannel
      \nFileDuration = GetDuration(nBassChannel, bTrace)
    ; end added 5May2017 11.6.1rc1
    ElseIf nDataChunkSize > 0
      ; qTmp = Round((nDataChunkSize * 1000) / wavFmt\nAvgBytesPerSec, #PB_Round_Nearest)
      ; changed 5May2017 11.6.1rc1 to use IntQ instead of Round, for reason explained in GetDuration()
      ; made this change following bug report from Johanna Wendrich about some 'linked' files not playing
      qTmp = IntQ((nDataChunkSize * 1000) / wavFmt\nAvgBytesPerSec)
      debugMsgC(sProcName, "nDataChunkSize=" + nDataChunkSize + ", wavFmt\nAvgBytesPerSec=" + wavFmt\nAvgBytesPerSec + ", qTmp=" + qTmp)
      \nFileDuration = qTmp
    EndIf
    \sFileTitle = ""
    debugMsgC(sProcName, "grInfoAboutFile\sFileName=" + \sFileName)
    debugMsgC(sProcName, "nBassChannel=" + decodeHandle(nBassChannel) + ", grInfoAboutFile\nFileDuration=" + \nFileDuration)
  EndWith
  
  If bKillThis = #False
    updateAnalyzedFileArray(sFileName, nFirstCPIndex, nLastCPIndex)
  EndIf
  
  ; debugMsg(sProcName, "calling listCuePointArray()")
  ; listCuePointArray()
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure analyzeMrkFile(sFileName.s, nBassChannel.l, bTrace=#False)
  PROCNAMEC()
  ; populate the gaCuePoint() array for this file from Wavelab markers stored in a .mrk file
  ; return number of markers found, or -1 if no marker file found
  Protected nFileNo, sMrkFileName.s
  Protected nMarkers
  Protected sLine.s
  Protected nLineNo, nLevelNo
  Protected bMarkersHeaderFound, nMarkerLevel
  Protected sName.s, sSamplePos.s, sMarker.s
  Protected sField.s, sValue.s
  Protected nBassResult.l, rChannelInfo.BASS_CHANNELINFO
  Protected rCuePoint.tyCuePoint
  Protected p
  Protected nFirstCPIndex = -1
  Protected nLastCPIndex = -1
  
  ; debugMsgC(sProcName, #SCS_START)
  
  ; If grLicInfo\bMayUseCuePoints = #False
    ; debugMsgC(sProcName, "exiting because grLicInfo\bMayUseCuePoints = #False")
    ; ProcedureReturn -1
  ; EndIf
  
  If nBassChannel = 0
    debugMsgC(sProcName, "exiting because nBassChannel=0")
    ProcedureReturn -1
  EndIf
  
  sMrkFileName = ignoreExtension(sFileName) + ".mrk"
  If FileExists(sMrkFileName, #False) = #False
    ; debugMsgC(sProcName, "exiting because " + sMrkFileName + " not found")
    ProcedureReturn -1
  EndIf
  ; clear any existing cue points for this file - in case the cue points have been changed
  For p = 0 To gnMaxCuePoint
    With gaCuePoint(p)
      If LCase(\sFileName) = LCase(sFileName)
        \sFileName = "*"
        \sCuePointKey = "*"
      EndIf
    EndWith
  Next p

  nBassResult = BASS_ChannelGetInfo(nBassChannel, @rChannelInfo)
  debugMsgC2(sProcName, "BASS_ChannelGetInfo(" + decodeHandle(nBassChannel) + ", rChannelInfo)", nBassResult)
  debugMsgC(sProcName, "rChannelInfo\freq=" + rChannelInfo\freq)
  
  nFileNo = ReadFile(#PB_Any, sMrkFileName, #PB_File_SharedRead)
  
  If nFileNo
    
    nMarkers = 0
    While Eof(nFileNo) = #False
      sLine = Trim(ReplaceString(ReadString(nFileNo), Chr(9), " ")) ; replace tabs with spaces, and trim result
      nLineNo + 1
      debugMsgC_AWF(sProcName, "nLineNo=" + nLineNo + ", sLine=" + sLine)
      
      If bMarkersHeaderFound = #False
        If sLine = "Markers"      ; Markers
          bMarkersHeaderFound = #True
        EndIf
        Continue
      EndIf
      
      If sLine = "{"      ; {
        nLevelNo + 1
        Continue
      EndIf
      
      If sLine = "}"      ; }
        nLevelNo - 1
        If nLevelNo = nMarkerLevel And Len(sMarker) > 0
          ; end of marker entry - add to array
          nMarkers + 1
          With rCuePoint
            If rChannelInfo\freq > 0
              \sFileName = sFileName
              \nIdentifier = nMarkers
              If IsInteger(sSamplePos)
                \qSamplePos = Val(sSamplePos)
              Else
                ; invalid sSamplePos - ignore this 'cue point'
                nMarkers - 1
                Continue
              EndIf
              \dTimePos = \qSamplePos / rChannelInfo\freq
              ; INFO
;               \qBytePos = BASS_ChannelSeconds2Bytes(nBassChannel, \dTimePos)
;               debugMsgC_AWF(sProcName, "BASS_ChannelSeconds2Bytes(" + decodeHandle(nBassChannel) + ", " + StrD(\dTimePos,5) + ") returned " + \qBytePos)
;               debugMsgC_AWF(sProcName, "\dTimePos=" + StrD(\dTimePos, 5) + ", \qBytePos=" + \qBytePos + ", \qSamplePos=" + \qSamplePos)
              debugMsgC_AWF(sProcName, "\dTimePos=" + StrD(\dTimePos, 5) + ", \qSamplePos=" + \qSamplePos)
              ; INFO
              \sName = sName
              ; If Len(\sName) = 0
                ; If \qSamplePos = 0
                  ; ; start of file
                  ; \sName = Lang("MMedia", "StartOfFile")
                ; EndIf
              ; EndIf
              \sCuePointKey = sFileName + "{" + \nIdentifier + "}"
              debugMsgC_AWF(sProcName, "(cue) sCuePointKey=" + \sCuePointKey)
              gnMaxCuePoint + 1
              debugMsgC_AWF(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint)
              If gnMaxCuePoint > ArraySize(gaCuePoint())
                ; debugMsg(sProcName, "calling listCuePointArray()")
                ; listCuePointArray()
                ReDim gaCuePoint(gnMaxCuePoint+50)  ; if using cue points then there may be many files with cue points, hence the +50 increase in size
                ; debugMsg(sProcName, "calling listCuePointArray()")
                ; listCuePointArray()
              EndIf
              gaCuePoint(gnMaxCuePoint) = rCuePoint
            EndIf
          EndWith
          
        EndIf
        sMarker = ""  ; indicates end of processing for this marker
        Continue
      EndIf
      
      If Left(sLine,6) = "Marker" And sLine <> "Markers"    ; Marker# (eg Marker, Marker1, Marker2, etc)
        nMarkerLevel = nLevelNo
        sName = ""
        sSamplePos = ""
        sMarker = sLine
        Continue
      EndIf
      
      If FindString(sLine,"=") > 0
        ; attribute of a marker
        sField = Trim(StringField(sLine,1,"="))
        sValue = Trim(StringField(sLine,2,"="))
        If LCase(Left(sField,4)) = "name"
          sName = sValue
        ElseIf LCase(Left(sField,3)) = "pos"
          sSamplePos = sValue
        EndIf
        Continue
      EndIf
      
      ; other
      Continue
      
    Wend
    CloseFile(nFileNo)
    
  Else
    ProcedureReturn -1
    
  EndIf
  
  ; remove any cue points without names and compact array
  compactCuePointArray()
  
  debugMsgC_AWF(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint)
  debugMsgC_AWF(sProcName, "nMarkers=" + nMarkers)
  If nMarkers > 0
    debugMsgC_AWF(sProcName, "Cue Point List for " + GetFilePart(sFileName))
    For p = 0 To gnMaxCuePoint
      With gaCuePoint(p)
        If \sFileName = sFileName
          If nFirstCPIndex = -1
            nFirstCPIndex = p
          EndIf
          nLastCPIndex = p
          debugMsgC_AWF(sProcName, "gaCuePoint(" + p + ")\sFileName=" + GetFilePart(\sFileName) + "  \nIdentifier=" + \nIdentifier +
                                  ", \qSamplePos=" + \qSamplePos + ", \dTimePos=" + StrD(\dTimePos, 5) + ", sName=" + \sName)
        EndIf
      EndWith
    Next p
  EndIf
  
  updateAnalyzedFileArray(sFileName, nFirstCPIndex, nLastCPIndex)
  
  debugMsg(sProcName, "calling listCuePointArray()")
  listCuePointArray()
  
  ProcedureReturn nMarkers
EndProcedure

Procedure updateAnalyzedFileArray(sFileName.s, nFirstCPIndex=-1, nLastCPIndex=-1)
  PROCNAMEC()
  Protected n, p
  
  p = -1
  For n = 0 To gnMaxAnalyzedFile
    If gaAnalyzedFile(n)\sFileName = sFileName
      p = n
      Break
    EndIf
  Next n
  If p = -1
    gnMaxAnalyzedFile + 1
    If gnMaxAnalyzedFile > ArraySize(gaAnalyzedFile())
      ReDim gaAnalyzedFile(gnMaxAnalyzedFile+20)
    EndIf
    p = gnMaxAnalyzedFile
  EndIf
  With gaAnalyzedFile(p)
    \sFileName = sFileName
    \nFirstCPIndex = nFirstCPIndex
    \nLastCPIndex = nLastCPIndex
  EndWith
  
EndProcedure

Procedure loadAudCuePoints()
  PROCNAMEC()
  Protected i, j, k
  Protected n, p
  Protected sFileName.s
  
  n = -1
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeF
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            With aAud(k)
              If \bAudPlaceHolder = #False
                sFileName = \sFileName
                For p = 0 To gnMaxCuePoint
                  If gaCuePoint(p)\sFileName = sFileName
                    n + 1
                    If n > ArraySize(gaAudCuePoint())
                      ReDim gaAudCuePoint(n+5)
                    EndIf
                    gaAudCuePoint(n)\nAudPtr = k
                    gaAudCuePoint(n)\sCuePointKey = gaCuePoint(p)\sCuePointKey
                    gaAudCuePoint(n)\dTimePos = gaCuePoint(p)\dTimePos
                  EndIf
                Next p
              EndIf
            EndWith
          EndIf ; EndIf k >= 0
        EndIf ; EndIf aSub(j)\bSubTypeF
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bSubTypeF
  Next i
  gnMaxAudCuePoint = n
    
EndProcedure

Procedure setPLFades(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sCommand.s
  Protected k, d, nVidPicTarget
  Protected nPrevAudTransTime, nPrevTransType
  Protected nPrevActualFadeOutTime, bMyPLRepeat
  Protected nMyLastPlayIndex, nMyPrevPlayIndex
  Protected nMyCueDuration
  Protected bFirstTrack
  Protected nMyPLFadeInTime
  Protected nBassResult.l, fChannelVol.f
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aSub(pSubPtr)
    ; set fade-in, wait and fade-out times for playlist aud's
    \bPLFadingIn = #False
    \bPLFadingOut = #False
    nPrevAudTransTime = 0
    nPrevTransType = #SCS_TRANS_XFADE
    nPrevActualFadeOutTime = -1
    bMyPLRepeat = \bPLRepeat
    nMyLastPlayIndex = \nLastPlayIndex
    If bMyPLRepeat
      If \nLastPlayIndex >= 0
        nPrevActualFadeOutTime = aAud(\nLastPlayIndex)\nFadeOutTime
      EndIf
    EndIf
    ; debugMsg(sProcName, "\nSubState=" + decodeCueState(\nSubState))
    If (\nSubState <= #SCS_CUE_SUB_COUNTDOWN_TO_START) Or (\nSubState >= #SCS_CUE_STANDBY)
      bFirstTrack = #True
    EndIf
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", bFirstTrack=" + strB(bFirstTrack))
    ; nMyPLFadeInTime = \nPLFadeInTime
    nMyPLFadeInTime = \nPLCurrFadeInTime ; mod 13May2020 11.8.3rc4
    k = \nFirstPlayIndex
  EndWith
  
  While k >= 0
    With aAud(k)
;       debugMsg(sProcName, "aAud(" + \sAudLabel + ")\nPLTransType=" + decodeTransType(\nPLTransType) + ", \nPLTransTime=" + \nPLTransTime + ", \nPrevPlayIndex=" + getAudLabel(\nPrevPlayIndex) +
;                           ", \nCueDuration=" + \nCueDuration + ", \nFileDuration=" + \nFileDuration)
      nMyCueDuration = \nCueDuration
      If nMyCueDuration = 0
        nMyCueDuration = \nFileDuration
      EndIf
      nMyPrevPlayIndex = \nPrevPlayIndex
      If (nMyPrevPlayIndex = -1) And (bMyPLRepeat)
        If (aSub(pSubPtr)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(pSubPtr)\nSubState <= #SCS_CUE_FADING_OUT)
          nMyPrevPlayIndex = nMyLastPlayIndex
        EndIf
      EndIf
      
      ; debugMsg(sProcName, "nPrevTransType=" + decodeTransType(nPrevTransType) + ", nPrevActualFadeOutTime=" + nPrevActualFadeOutTime + ", nMyPrevPlayIndex=" + nMyPrevPlayIndex)
      Select nPrevTransType
        Case #SCS_TRANS_XFADE
          If nMyPrevPlayIndex = -1
            \nFadeInTime = 0
          Else
            \nFadeInTime = nPrevActualFadeOutTime
            ; debugMsg(sProcName, "\nFadeInTime=" + \nFadeInTime + ", nMyCueDuration=" + nMyCueDuration + ", \nPLTransTime=" + \nPLTransTime)
            If \nFadeInTime > (nMyCueDuration - \nPLTransTime)
              \nFadeInTime = nMyCueDuration - \nPLTransTime
              If \nFadeInTime < 0
                \nFadeInTime = 0
              EndIf
            EndIf
            If \nFadeInTime < nPrevActualFadeOutTime
              aAud(nMyPrevPlayIndex)\nFadeOutTime = \nFadeInTime
              nPrevActualFadeOutTime = \nFadeInTime
            EndIf
          EndIf
          \nPLDelayStartTime = 0
          
        Case #SCS_TRANS_WAIT
          \nFadeInTime = 0
          If nMyPrevPlayIndex = -1
            \nPLDelayStartTime = 0
          Else
            \nPLDelayStartTime = nPrevAudTransTime
          EndIf
          
        Default ; mix or none
          \nFadeInTime = 0
          \nPLDelayStartTime = 0
      EndSelect
      ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nFadeInTime=" + \nFadeInTime + ", \nFadeOutTime=" + \nFadeOutTime)
      
      ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sPLTransType=" + \sPLTransType)
      Select \nPLRunTimeTransType ; Changed 4Jul2023 (was \nPLTransType)
        Case #SCS_TRANS_XFADE
          If (\nNextPlayIndex = -1) And (bMyPLRepeat = #False)
            If aSub(pSubPtr)\nPLFadeOutTime > 0
              \nFadeOutTime = aSub(pSubPtr)\nPLFadeOutTime
            ; ElseIf \bAudTypeA
              ; \nFadeOutTime = \nPLTransTime
            Else
              \nFadeOutTime = 0
            EndIf
          Else
            \nFadeOutTime = \nPLTransTime
          EndIf
          ; debugMsg(sProcName, "aAud(" + \sAudLabel + ")\nPLTransTime=" + \nPLTransTime + ", \nFadeOutTime=" + \nFadeOutTime + ", nMyCueDuration=" + nMyCueDuration)
          If \nFadeOutTime > (nMyCueDuration - \nPLTransTime)
            \nFadeOutTime = nMyCueDuration - \nPLTransTime
            If \nFadeOutTime < 0
              \nFadeOutTime = 0
            EndIf
          EndIf
          ; debugMsg(sProcName, "aAud(" + \sAudLabel + ")\nFadeOutTime=" + \nFadeOutTime)
          
        Default   ; mix, wait or none
          If (\nNextPlayIndex = -1) And (bMyPLRepeat = #False) And (aSub(pSubPtr)\nPLFadeOutTime > 0)
            \nFadeOutTime = aSub(pSubPtr)\nPLFadeOutTime
          Else
            \nFadeOutTime = 0
          EndIf
      EndSelect
      
      If bFirstTrack
        ; first track of playlist
        \nCurrFadeInTime = nMyPLFadeInTime
      Else
        \nCurrFadeInTime = \nFadeInTime
      EndIf
      \nCurrFadeOutTime = \nFadeOutTime
      ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nCurrFadeInTime=" + \nCurrFadeInTime + ", \nCurrFadeOutTime=" + \nCurrFadeOutTime + ", bFirstTrack=" + strB(bFirstTrack))
      
      For d = \nFirstSoundingDev To \nLastSoundingDev
        ; removed check on \nBassChannel[d]<>0 so that procedure handles both BASS and SM-S
        If bFirstTrack
          ; first track of playlist
          If nMyPLFadeInTime > 0
            \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
          Else
            \fCueVolNow[d] = \fBVLevel[d]
          EndIf
        ElseIf \nFadeInTime > 0
          \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
        Else
          \fCueVolNow[d] = \fBVLevel[d]
        EndIf
        \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
        \fCueTotalVolNow[d] = \fCueVolNow[d]
        CompilerIf #cTraceCueTotalVolNow
          debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(k)\fCueTotalVolNow[d]))
        CompilerEndIf
      Next d
      
      ; Changed 4Jul2023 11.10.0bn
      If \bAudTypeP
        nPrevAudTransTime = \nPLRunTimeTransTime
        nPrevTransType = \nPLRunTimeTransType
      Else
        nPrevAudTransTime = \nPLTransTime
        nPrevTransType = \nPLTransType
      EndIf
      ; End changed 4Jul2023 11.10.0bn
      nPrevActualFadeOutTime = \nFadeOutTime
      ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nFadeOutTime=" + \nFadeOutTime + ", nPrevTransType=" + decodeTransType(nPrevTransType) + ", nPrevActualFadeOutTime=" + nPrevActualFadeOutTime)
      bFirstTrack = #False
      k = \nNextPlayIndex
    EndWith
  Wend
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      If aSub(pSubPtr)\bSubTypeA
        nVidPicTarget = getVidPicTargetForOutputScreen(aSub(pSubPtr)\nOutputScreen)
        k = aSub(pSubPtr)\nFirstPlayIndex
        If k >= 0
          With aAud(k)
            If \svMixInputKey
              d = 0
              debugMsg(sProcName, "calling setLevelsVideo(" + getAudLabel(k) + ", " + d + ", " + traceLevel(\fCueTotalVolNow[d]) + ", " + tracePan(\fCuePanNow[d]) + ", " + decodeVidPicTarget(nVidPicTarget) + ")")
              setLevelsVideo(k, d, \fCueTotalVolNow[d], \fCuePanNow[d], nVidPicTarget)
            EndIf
          EndWith
        EndIf
      EndIf
    EndIf
  CompilerEndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setPLLevels(pAudPtr, bSendSMSSetGainCommand=#True, bUseFadeIn=#False, bUseFadeOut=#False)
  PROCNAMECA(pAudPtr)
  Protected d, fBVLevel.f, fPan.f
  Protected nLCCtrlSubPtr, bUsePLPlayLevel
  Protected sDevPXChanListLeft.s, sDevPXChanListRight.s
  Protected sLevelInfo.s, sSetCommandItem.s
  Protected sAudSetGainCommandString.s
  Protected nFadeTime, nFadeType
  Protected nSubPtr, nMaxDev, sLogicalDev.s
  
  CompilerIf #cTraceSetLevels
    debugMsg(sProcName, #SCS_START + ", bSendSMSSetGainCommand=" + strB(bSendSMSSetGainCommand) + ", bUseFadeIn=" + strB(bUseFadeIn) + ", bUseFadeOut=" + strB(bUseFadeOut) + ", \nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState))
  CompilerEndIf
  
  With aAud(pAudPtr)
    
    nSubPtr = \nSubIndex
    If \bAudTypeA
      nMaxDev = 0
      sLogicalDev = aSub(nSubPtr)\sVidAudLogicalDev
    Else
      nMaxDev = grLicInfo\nMaxAudDevPerSub
    EndIf
    
    nLCCtrlSubPtr = aSub(nSubPtr)\nLCCtrlSubPtr
    If nLCCtrlSubPtr > 0
      If aSub(nLCCtrlSubPtr)\nSubState <> #SCS_CUE_CHANGING_LEVEL
        nLCCtrlSubPtr = -1
      EndIf
    EndIf
    
    If bUseFadeIn
      CompilerIf #cTraceSetLevels
        debugMsg(sProcName, "\nCurrFadeInTime=" + \nCurrFadeInTime + ", \nFadeInType=" + decodeFadeType(\nFadeInType))
      CompilerEndIf
      nFadeTime = \nCurrFadeInTime
      nFadeType = \nFadeInType
    ElseIf bUseFadeOut
      nFadeTime = \nCurrFadeOutTime
      nFadeType = \nFadeOutType
    EndIf
    
    For d = 0 To nMaxDev
      If \bAudTypeP
        sLogicalDev = aSub(nSubPtr)\sPLLogicalDev[d]
        If Len(sLogicalDev) = 0
          Continue
        EndIf
      EndIf
      
      If nLCCtrlSubPtr > 0
        If (aSub(nLCCtrlSubPtr)\bLCInclude[d] = #False) And (\nAudState <> #SCS_CUE_PL_READY)
          Continue
        Else
          bUsePLPlayLevel = #True
        EndIf
      EndIf
      
      CompilerIf #cTraceSetLevels
        debugMsg(sProcName, "\bCueVolManual[" + d + "]=" + strB(\bCueVolManual[d]))
        debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState) + ", \nAudState=" + decodeCueState(\nAudState))
      CompilerEndIf
      If (\bCueVolManual[d]) And ((aSub(nSubPtr)\nSubState > #SCS_CUE_TRANS_FADING_IN) And (aSub(nSubPtr)\nSubState < #SCS_CUE_TRANS_MIXING_OUT))
        fBVLevel = \fBVLevel[d]
      ElseIf (aSub(nSubPtr)\nSubState = #SCS_CUE_HIBERNATING) And (\nCurrFadeInTime > 0)  ; added 15Mar2019 11.8.0.2cd
        fBVLevel = #SCS_MINVOLUME_SINGLE ; added 15Mar2019 11.8.0.2cd
      Else
        If (gbUseSMS) And (\bAudTypeP) And (\nPrevPlayIndex = -1)
          fBVLevel = \fAudPlayBVLevel[d]
        Else
          fBVLevel = calcPLLevel(pAudPtr, d)
        EndIf
      EndIf
      If \bCuePanManual[d]
        fPan = \fPan[d]
      Else
        If \fAudPlayPan[d] = \fCuePanNow[d]
          fPan = #SCS_NOPANCHANGE_SINGLE
        Else
          fPan = \fAudPlayPan[d]
        EndIf
      EndIf
      CompilerIf #cTraceSetLevels
        debugMsg(sProcName, "fBVLevel=" + traceLevel(fBVLevel) + ", sLogicalDev=" + sLogicalDev)
      CompilerEndIf
      
      ; debugMsg(sProcName, "d=" + d + ", \nAudState=" + decodeCueState(\nAudState))
      If (\nAudState >= #SCS_CUE_READY) And (\nAudState < #SCS_CUE_COMPLETED)
        If \bAudTypeA
          CompilerIf #cTraceSetLevels
            debugMsg(sProcName, "calling setLevelsVideo(" + getAudLabel(pAudPtr) + ", " + d + ", [" + traceLevel(fBVLevel) + "], " + formatPan(fPan) + ", " + decodeVidPicTarget(\nAudVidPicTarget) + ")")
          CompilerEndIf
          setLevelsVideo(pAudPtr, d, fBVLevel, fPan, \nAudVidPicTarget)
          ; debugMsg3(sProcName, "returned from setLevelsVideo()")
        Else
          If gbUseBASS  ; BASS
            setLevelsBASS(pAudPtr, d, fBVLevel, fPan)
          Else  ; SM-S
            sDevPXChanListLeft = \sDevPXChanListLeft[d]
            sDevPXChanListRight = \sDevPXChanListRight[d]
            If Len(sDevPXChanListLeft) > 0
              sLevelInfo = setLevelsForSMSOutputDev(pAudPtr, d, fBVLevel, fPan, nFadeTime, nFadeType)
              CompilerIf #cTraceSetLevels
                debugMsg(sProcName, "d=" + d + ", sLevelInfo=" + sLevelInfo)
              CompilerEndIf
              If Len(sDevPXChanListRight) = 0
                sSetCommandItem = " chan " + sDevPXChanListLeft + " " + StringField(sLevelInfo, 1, "|")
              Else
                If fPan = #SCS_PANCENTRE_SINGLE
                  sSetCommandItem = " chan " + sDevPXChanListLeft + " " + sDevPXChanListRight + " " + StringField(sLevelInfo, 1, "|")
                Else
                  sSetCommandItem = " chan " + sDevPXChanListLeft + " " + StringField(sLevelInfo, 1, "|")
                  sSetCommandItem + " chan " + sDevPXChanListRight + " " + StringField(sLevelInfo, 2, "|")
                EndIf
              EndIf
              CompilerIf #cTraceSetLevels
                debugMsg(sProcName, "sSetCommandItem=" + sSetCommandItem)
              CompilerEndIf
              sAudSetGainCommandString + sSetCommandItem
            EndIf
          EndIf
        EndIf
      EndIf
      
    Next d
    
    If gbUseSMS ; SM-S
      If \bAudTypeP
        If Len(Trim(sAudSetGainCommandString)) > 0
          CompilerIf #cTraceSetLevels
            debugMsg(sProcName, "bSendSMSSetGainCommand=" + strB(bSendSMSSetGainCommand))
          CompilerEndIf
          If bSendSMSSetGainCommand
            If Trim(sAudSetGainCommandString) <> \sAudPrevSetGainCommandString
              sendSMSCommand("set " + Trim(sAudSetGainCommandString), #cTraceSetLevels)
              \sAudPrevSetGainCommandString = Trim(sAudSetGainCommandString)
            EndIf
          Else
            \sAudSetGainCommandString = Trim(sAudSetGainCommandString)
            CompilerIf #cTraceSetLevels
              debugMsg(sProcName, "\sAudSetGainCommandString=" + \sAudSetGainCommandString)
            CompilerEndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndWith
  
EndProcedure

Procedure setPLLevelsIfReqd(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bReqd, nState, nLCCtrlSubPtr
  
  nState = aAud(pAudPtr)\nAudState
  Select nState
    Case #SCS_CUE_FADING_IN, #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_IN, #SCS_CUE_TRANS_FADING_OUT
      bReqd = #True
    Default
      nLCCtrlSubPtr = aSub(aAud(pAudPtr)\nSubIndex)\nLCCtrlSubPtr
      If nLCCtrlSubPtr > 0
        nState = aSub(nLCCtrlSubPtr)\nSubState
        If nState = #SCS_CUE_CHANGING_LEVEL
          bReqd = #True
        EndIf
      EndIf
  EndSelect
  
  If bReqd
    setPLLevels(pAudPtr)
  EndIf
  
EndProcedure

Procedure blendPictures(nPrimaryVidPicTarget, nBlendFactor, bTrace=#False)
  PROCNAMEC()
  Protected nMonitorCanvasNo
  
  With grVidPicTarget(nPrimaryVidPicTarget)
    CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
      debugMsgC(sProcName, "nPrimaryVidPicTarget=" + decodeVidPicTarget(nPrimaryVidPicTarget) + ", \nTargetCanvasNo=" + getGadgetName(\nTargetCanvasNo) +
                           ", \nImage2=" + decodeHandle(\nImage2) + ", \nImage1=" + decodeHandle(\nImage1) +
                           ", \nBlendedImageNo=" + decodeHandle(\nBlendedImageNo) + ", ImageWidth()=" + ImageWidth(\nBlendedImageNo) + ", ImageHeight()=" + ImageHeight(\nBlendedImageNo) +
                           ", nBlendFactor=" + nBlendFactor +
                           ", \qBlendStartTime=" + traceTime(\qBlendStartTime) + ", \nBlendTime=" + \nBlendTime +
                           ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr)  + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
    CompilerEndIf
    If nBlendFactor <> \nPrevBlendFactor
      CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
        debugMsg(sProcName, "nPrimaryVidPicTarget=" + decodeVidPicTarget(nPrimaryVidPicTarget) + ", \nTargetCanvasNo=" + getGadgetName(\nTargetCanvasNo) +
                            ", \nImage2=" + decodeHandle(\nImage2) + ", \nImage1=" + decodeHandle(\nImage1) +
                            ", \nBlendedImageNo=" + decodeHandle(\nBlendedImageNo) +
                            ", nBlendFactor=" + nBlendFactor +
                            ", \qBlendStartTime=" + traceTime(\qBlendStartTime) + ", \nBlendTime=" + \nBlendTime +
                            ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr)  + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
      CompilerEndIf
      ; debugMsg(sProcName, "IsImage(\nImage1)=" + IsImage(\nImage1) + ", IsImage(\nImage2)=" + IsImage(\nImage2) + ", IsImage(\nBlendedImageNo)=" + IsImage(\nBlendedImageNo))
      If IsImage(\nImage1)
        If IsImage(\nImage2)
          If IsImage(\nBlendedImageNo)
            ; draw image, blending primary and secondary images according to nBlendFactor
            If StartDrawing(ImageOutput(\nBlendedImageNo))
              debugMsgDA(sProcName, "StartDrawing(ImageOutput(" + decodeHandle(\nBlendedImageNo) + ")), ImageWidth()=" + ImageWidth(\nBlendedImageNo))
              ; drawing \nImage2 using DrawAlphaImage() seems to give slightly less flicker than using DrawImage(), and is no slower
              DrawAlphaImage(ImageID(\nImage2), 0, 0, 255)
              debugMsgDA(sProcName, "DrawAlphaImage(ImageID(" + decodeHandle(\nImage2) + "), 0, 0, 255), ImageWidth()=" + ImageWidth(\nImage2))
              DrawAlphaImage(ImageID(\nImage1), 0, 0, nBlendFactor)
              debugMsgDA(sProcName, "DrawAlphaImage(ImageID(" + decodeHandle(\nImage1) + "), 0, 0, " + nBlendFactor + "), ImageWidth()=" + ImageWidth(\nImage1))
              StopDrawing()
              debugMsgDA(sProcName, "StopDrawing()")
            EndIf
            ; paint blended image on target canvas
            If StartDrawing(CanvasOutput(\nTargetCanvasNo))
              debugMsgDA(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(\nTargetCanvasNo) + ")), GadgetWidth()=" + GadgetWidth(\nTargetCanvasNo))
              DrawImage(ImageID(\nBlendedImageNo), 0, 0)
              debugMsgDA(sProcName, "DrawImage(ImageID(" + decodeHandle(\nBlendedImageNo) + "), 0, 0), ImageWidth()=" + ImageWidth(\nBlendedImageNo))
              StopDrawing()
              debugMsgDA(sProcName, "StopDrawing()")
            EndIf
            ; if a monitor window exists then paint the blended image on the monitor canvas
            nMonitorCanvasNo = \nCurrMonitorCanvasNo
            If IsGadget(nMonitorCanvasNo)
              If StartDrawing(CanvasOutput(nMonitorCanvasNo))
                debugMsgDA(sProcName, "(monitor) StartDrawing(CanvasOutput(" + getGadgetName(nMonitorCanvasNo) + ")), GadgetWidth()=" + GadgetWidth(nMonitorCanvasNo))
                DrawImage(ImageID(\nBlendedImageNo), 0, 0, OutputWidth(), OutputHeight())
                ; debugMsgDA(sProcName, "(monitor) DrawImage(ImageID(" + decodeHandle(\nBlendedImageNo) + "), 0, 0, " + OutputWidth() + ", " + OutputHeight() + ")")
                debugMsgDA(sProcName, "(monitor) DrawImage(ImageID(" + decodeHandle(\nBlendedImageNo) + "), 0, 0, " + OutputWidth() + ", " + OutputHeight() + "), ImageWidth()=" + ImageWidth(\nBlendedImageNo))
                StopDrawing()
                debugMsgDA(sProcName, "(monitor) StopDrawing()")
              EndIf
            EndIf
            \nPrevBlendFactor = nBlendFactor
          Else
            debugMsg(sProcName, "IsImage(\nBlendedImageNo) returned #False (\nBlendedImageNo=" + decodeHandle(\nBlendedImageNo) + ")")
          EndIf
        Else
          debugMsg(sProcName, "IsImage(\nImage2) returned #False (\nImage2=" + decodeHandle(\nImage2) + ")")
        EndIf
      Else
        debugMsg(sProcName, "IsImage(\nImage1) returned #False (\nImage1=" + decodeHandle(\nImage1) + ")")
      EndIf
      
    EndIf
  EndWith
  
EndProcedure

Procedure getImagePtrForAud(pAudPtr, pVidPicTarget)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected n, nImagePtr
  Protected sFileName.s
  Protected nRotate, nFlip
  Protected nXPos, nYPos, nSize, nAspectRatioType, nAspectRatioHVal
  Protected nTargetWidth, nTargetHeight
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START)
  
  nImagePtr = -1
  If pAudPtr >= 0
    If aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE
      With aAud(pAudPtr)
        sFileName = \sFileName
        nRotate = \nRotate
        nFlip = \nFlip
        ; added 28Oct2015 11.4.1.2c
        nXPos = \nXPos
        nYPos = \nYPos
        nSize = \nSize
        nAspectRatioType = \nAspectRatioType
        nAspectRatioHVal = \nAspectRatioHVal
        ; end of added 28Oct2015 11.4.1.2c
      EndWith
      debugMsgC(sProcName, "pVidPicTarget=" + pVidPicTarget + ", #SCS_VID_PIC_TARGET_F2=" + #SCS_VID_PIC_TARGET_F2 + ", grLicInfo\nLastVidPicTarget=" + grLicInfo\nLastVidPicTarget)
      If (pVidPicTarget >= #SCS_VID_PIC_TARGET_F2) And (pVidPicTarget <= grLicInfo\nLastVidPicTarget)
        With grVidPicTarget(pVidPicTarget)
          ; debugMsgC(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nTargetWidth=" + \nTargetWidth + ", \nTargetHeight=" + \nTargetHeight)
          nTargetWidth = \nTargetWidth
          nTargetHeight = \nTargetHeight
        EndWith
      EndIf
      ; debugMsgC(sProcName, "gnLastImageData=" + gnLastImageData)
      For n = 0 To gnLastImageData
        With gaImageData(n)
          ; debugMsgC(sProcName, "gaImageData(" + n + ")\sFileName=" + GetFilePart(\sFileName) + ", \nImageNo=" + decodeHandle(\nImageNo))
          If \sFileName = sFileName
            If (\nRotate = nRotate) And (\nFlip = nFlip)
              ; the next 5-item If test added 28Oct2015 11.4.1.2c
              If (\nXpos = nXPos) And (\nYPos = nYPos) And (\nSize = nSize) And (\nAspectRatioType = nAspectRatioType) And (\nAspectRatioHVal = nAspectRatioHVal)
                ; debugMsgC(sProcName, "\nTargetWidth=" + \nTargetWidth + ", nTargetWidth=" + nTargetWidth + ", \nTargetHeight=" + \nTargetHeight + ", nTargetHeight=" + nTargetHeight)
                If (\nTargetWidth = nTargetWidth) And (\nTargetHeight = nTargetHeight) ; nb doesn't have to be the same target as long as the target has the same dimensions
                  If IsImage(\nImageNo)
                    debugMsgC(sProcName, "found - gaImageData(" + n + ")\nImageNo=" + \nImageNo)
                    nImagePtr = n
                    Break
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
        EndWith
      Next n
    EndIf
  EndIf
  
  debugMsgC(sProcName, "returning " + nImagePtr)
  ProcedureReturn nImagePtr
EndProcedure

Procedure storeImageData(pAudPtr, pVidPicTarget, nImageNo)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected n, nImagePtr
  
  debugMsg(sProcName, #SCS_START + ", nImageNo=" + decodeHandle(nImageNo))
  
  nImagePtr = -1
  If pAudPtr >= 0
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        For n = 0 To gnLastImageData
          If gaImageData(n)\nImageOpenCount <= 0
            ; free slot found
            nImagePtr = n
            Break
          EndIf
        Next n
        
        If nImagePtr = -1
          gnLastImageData + 1
          If gnLastImageData > ArraySize(gaImageData())
            ReDim gaImageData(gnLastImageData+20)
          EndIf
          nImagePtr = gnLastImageData
        EndIf
        
        With gaImageData(nImagePtr)
          \sFileName = aAud(pAudPtr)\sFileName
          \nRotate = aAud(pAudPtr)\nRotate
          \nFlip = aAud(pAudPtr)\nFlip
          \nXpos = aAud(pAudPtr)\nXPos
          \nYPos = aAud(pAudPtr)\nYPos
          \nSize = aAud(pAudPtr)\nSize
          \nAspectRatioType = aAud(pAudPtr)\nAspectRatioType
          \nAspectRatioHVal = aAud(pAudPtr)\nAspectRatioHVal
          \nImageNo = nImageNo
          \nTargetWidth = grVidPicTarget(pVidPicTarget)\nTargetWidth
          \nTargetHeight = grVidPicTarget(pVidPicTarget)\nTargetHeight
          \nImageOpenCount = 1
          debugMsg(sProcName, "gaImageData(" + nImagePtr + ")\sFileName=" + GetFilePart(\sFileName) + ", \nImageNo=" + decodeHandle(\nImageNo) + ", \nImageOpenCount=" + \nImageOpenCount)
        EndWith
        
      Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_T
        debugMsg(sProcName, "calling saveImageDataToTempDatabase(" + getAudLabel(pAudPtr) + ", " + decodeHandle(nImageNo) + ")")
        saveImageDataToTempDatabase(pAudPtr, nImageNo)
        
    EndSelect
  EndIf
  
EndProcedure

Procedure loadImageIfReqd(pAudPtr, bTrace=#False)
  PROCNAMECA(pAudPtr)
  ; This procedure loads, if required, the still image or a video thumbnail.
  ; The original image/thumbnail is stored as a PB image, full-size, and the image number is stored in aAud(pAudPtr)\nLoadImage.
  ; The procedure then checks if flip or rotate are requested for this aAud(), and if so then calls rotateAndFlipImageIfReqd() which
  ; will store the rotated/flipped image full size as a PB image, and the image number is stored in aAud(pAudPtr)\nImageAfterRotateAndFlip.
  ; If no rotate/flip is required then \nImageAfterRotateAndFlip = \nLoadImage.
  ; So outside of this procedure, other code should use the image number \nImageAfterRotateAndFlip for displaying images or thumbnails,
  ; after making any necessary aspect, size and position adjustments.
  Protected bResult = #True
  Protected nSubPtr
  
  debugMsgC(sProcName, #SCS_START + ", bTrace=" + strB(bTrace))
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      
      nSubPtr = \nSubIndex
      If aSub(nSubPtr)\bSubUseGaplessStream
        If (aSub(nSubPtr)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(nSubPtr)\nSubState <= #SCS_CUE_FADING_OUT)
          ; prevents frame being built whilst playing a video mixer stream
          debugMsgC(sProcName, "exiting because aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState))
          ProcedureReturn #False
        EndIf
      EndIf
      
      If (\sFileName And FileExists(\sFileName, bTrace)) Or (\nVideoSource = #SCS_VID_SRC_CAPTURE)
        If \bReloadImage
          condFreeImage(\nLoadImageNo)
          \nLoadImageNo = 0
          condFreeImage(\nImageAfterRotateAndFlip)
          \nImageAfterRotateAndFlip = 0
          \bReRotateImage = #True
        EndIf
        Select \nFileFormat
          Case #SCS_FILEFORMAT_PICTURE
            debugMsgC(sProcName, "IsImage(" + \nLoadImageNo + ")=" + IsImage(\nLoadImageNo) + ", \bReloadImage=" + strB(\bReloadImage))
            If (IsImage(\nLoadImageNo) = #False) Or (\bReloadImage)
              \nImageFrameCount = grAudDef\nImageFrameCount
              \nLoadImageNo = scsLoadImage(\sFileName)
              debugMsg2(sProcName, "scsLoadImage(" + GetFilePart(\sFileName) + ")", \nLoadImageNo)
              debugMsgC(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo=" + \nLoadImageNo)
              ; debugMsgC(sProcName, "\nLoadImageNo=" + \nLoadImageNo)
              If \nLoadImageNo = 0
                If FileExists(\sFileName, #False)
                  ; probably out of memory so free some other images and try again
                  If freeSomeImages(pAudPtr)
                    ; try again
                    \nLoadImageNo = scsLoadImage(\sFileName)
                    debugMsg2(sProcName, "scsLoadImage(" + GetFilePart(\sFileName) + ")", \nLoadImageNo)
                    debugMsgC(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo=" + \nLoadImageNo)
                  EndIf
                EndIf
              EndIf
              If IsImage(\nLoadImageNo)
                logCreateImage(185, \nLoadImageNo, pAudPtr, #SCS_VID_PIC_TARGET_NONE, "\nLoadImageNo", getAudLabel(pAudPtr)+".Load")
                \nImageFrameCount = ImageFrameCount(\nLoadImageNo)
                If \nImageFrameCount > 1
                  debugMsg2(sProcName, "ImageFrameCount(" + decodeHandle(\nLoadImageNo) + ")", \nImageFrameCount)
                  \nSelectedFrameIndex = GetImageFrame(\nLoadImageNo)
                  If \nAnimatedImageTimer = grAudDef\nAnimatedImageTimer ; no need to assign a new timer number if this aAud() already has a timer number
                    \nAnimatedImageTimer = gnNextAnimatedTimer
                    If gnNextAnimatedTimer > ArraySize(grWMN\nAnimatedTimerAudPtr())
                      ReDim grWMN\nAnimatedTimerAudPtr(gnNextAnimatedTimer+5)
                    EndIf
                    grWMN\nAnimatedTimerAudPtr(gnNextAnimatedTimer) = pAudPtr
                    gnNextAnimatedTimer + 1
                  EndIf
                  \bCancelAudAnimation = #False
                  \bReRotateImage = #False
                Else
                  \bReRotateImage = #True
                EndIf
              EndIf
              \bReloadImage = #False
            EndIf
            
          Case #SCS_FILEFORMAT_VIDEO
            debugMsgC(sProcName, "IsImage(" + \nLoadImageNo + ")=" + IsImage(\nLoadImageNo) + ", \bReloadImage=" + strB(\bReloadImage))
            If (IsImage(\nLoadImageNo) = #False) Or (\bReloadImage)
              debugMsgC(sProcName, "calling loadFrame2(" + getAudLabel(pAudPtr) + ", " + \nAbsStartAt + ")")
              loadFrame2(pAudPtr, \nAbsStartAt)
              \bReloadImage = #False
              \bReRotateImage = #True
            EndIf
            
          Case #SCS_FILEFORMAT_CAPTURE  
            debugMsgC(sProcName, "Prior - hVideoCaptionLogo="+hVideoCaptionLogo)
            \nLoadImageNo = hVideoCaptionLogo
            debugMsgC(sProcName, "After - hVideoCaptionLogo="+hVideoCaptionLogo)
            \bReloadImage = #False
            \bReRotateImage = #True  
            
        EndSelect
        
        debugMsgC(sProcName, "IsImage(" + \nLoadImageNo + ")=" + IsImage(\nLoadImageNo) + ", \bReRotateImage=" + strB(\bReRotateImage))
        If IsImage(\nLoadImageNo)
          If \nImageFrameCount > 1
            ; cannot rotate and flip an animated image because the drawing process of doing so would only handle the current frame
            \nImageAfterRotateAndFlip = \nLoadImageNo
          Else
            If \nRotate <> 0 Or \nFlip <> 0
              If IsImage(\nImageAfterRotateAndFlip) = #False
                \bReRotateImage = #True
              EndIf
            EndIf
            If \bReRotateImage
              If \nImageAfterRotateAndFlip <> \nLoadImageNo
                condFreeImage(\nImageAfterRotateAndFlip)
              EndIf
              \nImageAfterRotateAndFlip = 0
              rotateAndFlipImageIfReqd_NEW(pAudPtr)
              If IsImage(\nImageAfterRotateAndFlip)
                \bReRotateImage = #False
              Else
                bResult = #False
              EndIf
            Else  ; no re-rotation required
              If \nRotate = 0 And \nFlip = 0
                \nImageAfterRotateAndFlip = \nLoadImageNo
              EndIf
            EndIf
          EndIf ; EndIf \nImageFrameCount > 1 / Else
        Else
          bResult = #False
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsgC(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure loadPosImageIfReqd(pAudPtr, pPos)
  PROCNAMECA(pAudPtr)
  ; outside of this procedure, other code should use the image number \nPosImageAfterRotateAndFlip for displaying images,
  ; after making any necessary aspect, size and position adjustments.
  Protected bResult = #True
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \sFileName
        If \nPosImagePos <> pPos
          condFreeImage(\nPosLoadImageNo)
          \nPosLoadImageNo = 0
          condFreeImage(\nPosImageAfterRotateAndFlip)
          \nPosImageAfterRotateAndFlip = 0
          \bReRotatePosImage = #True
        EndIf
        Select \nFileFormat
          Case #SCS_FILEFORMAT_PICTURE
            debugMsg(sProcName, "IsImage(" + \nPosLoadImageNo + ")=" + IsImage(\nPosLoadImageNo))
            If (IsImage(\nPosLoadImageNo) = 0) Or (\nPosImagePos <> pPos)
              \nPosLoadImageNo = scsLoadImage(\sFileName)
              debugMsg(sProcName, "\nPosLoadImageNo=" + \nPosLoadImageNo)
              debugMsg2(sProcName, "scsLoadImage(" + GetFilePart(\sFileName) + ")", \nPosLoadImageNo)
              If \nPosLoadImageNo = 0
                If FileExists(\sFileName)
                  ; probably out of memory so free some other images and try again
                  If freeSomeImages(pAudPtr)
                    ; try again
                    \nPosLoadImageNo = scsLoadImage(\sFileName)
                    debugMsg2(sProcName, "scsLoadImage(" + GetFilePart(\sFileName) + ")", \nPosLoadImageNo)
                  EndIf
                EndIf
              EndIf
              If IsImage(\nPosLoadImageNo)
                logCreateImage(187, \nPosLoadImageNo, pAudPtr, #SCS_VID_PIC_TARGET_NONE, "\nPosLoadImageNo")
              EndIf
              \bReRotatePosImage = #True
            EndIf
            
          Case #SCS_FILEFORMAT_VIDEO
            If (IsImage(\nPosLoadImageNo) = 0) Or (\nPosImagePos <> pPos)
              debugMsg(sProcName, "calling loadFrame2(" + getAudLabel(pAudPtr) + ", " + pPos + ")")
              loadFrame2(pAudPtr, pPos, #True)
              \bReRotatePosImage = #True
            EndIf
            
        EndSelect
        
        debugMsg(sProcName, "IsImage(" + \nPosLoadImageNo + ")=" + IsImage(\nPosLoadImageNo) + ", \bReRotatePosImage=" + strB(\bReRotatePosImage))
        If IsImage(\nPosLoadImageNo)
          If \nRotate <> 0 Or \nFlip <> 0
            If IsImage(\nPosImageAfterRotateAndFlip) = #False
              \bReRotatePosImage = #True
            EndIf
          EndIf
          If \bReRotatePosImage
            If \nPosImageAfterRotateAndFlip <> \nPosLoadImageNo
              condFreeImage(\nPosImageAfterRotateAndFlip)
            EndIf
            \nPosImageAfterRotateAndFlip = 0
            rotateAndFlipImageIfReqd_NEW(pAudPtr, #True) ; 2nd parameter #True means using 'position' image
            If IsImage(\nPosImageAfterRotateAndFlip)
              \bReRotatePosImage = #False
            Else
              bResult = #False
            EndIf
          Else  ; no re-rotation required
            If \nRotate = 0 And \nFlip = 0
              \nPosImageAfterRotateAndFlip = \nPosLoadImageNo
            EndIf
          EndIf
        Else
          bResult = #False
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure rotateAndFlipImageIfReqd_NEW(pAudPtr, bUsePosLoadImage=#False)
  PROCNAMECA(pAudPtr)
  Protected qTime.q
  Protected nOriginalImageNo, nLoadImageNo, nLoadImageWidth, nLoadImageHeight, nLoadImageDepth, nWorkImageNo
  Protected dReqdWidth.d, dReqdHeight.d, dReqdWidth2.d, dReqdHeight2.d, dCursorX.d, dCursorY.d
  Protected bRotated, nResult
  
  ; NOTE: This Procedure uses PureBasic Vector Drawing to rotate and/or flip the image.
  ; When SCS was first converted to PB, the Vector Drawing library didn't exist, so separate procedures in the file "RotateImage.pbi" were used.
  ; However, in tests in Apr2020 I found that the RotateImage() Procedure was very slow - typically taking 6-8 seconds to do a 90 degree rotation of an image taken using a camera,
  ; eg an image of 4608x2592 pixels. Experimenting with Vector Drawing, this same process typically takes less than a second - eg about 450ms.
  ; Some of the logic was difficult to get right, especially the setting of dCursorX and dCursorY. Testing was done using the test program "PB Test Files\VectorImageTest.pb".
  ; See also the example code in the PB Help Topic DrawVectorImage().
  
  debugMsg(sProcName, #SCS_START + ", bUsePosLoadImage=" + strB(bUsePosLoadImage))
  
  qTime = ElapsedMilliseconds()
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If bUsePosLoadImage
        nOriginalImageNo = \nPosLoadImageNo
      Else
        nOriginalImageNo = \nLoadImageNo
      EndIf
      nLoadImageNo = nOriginalImageNo
      nLoadImageWidth = ImageWidth(nLoadImageNo)
      nLoadImageHeight = ImageHeight(nLoadImageNo)
      nLoadImageDepth = ImageDepth(nLoadImageNo)
      debugMsg(sProcName, "nLoadImageNo=" + decodeHandle(nLoadImageNo) + ", nLoadImageWidth=" + nLoadImageWidth + ", nLoadImageHeight=" + nLoadImageHeight + ", nLoadImageDepth=" + nLoadImageDepth)
      nWorkImageNo = scsCreateImage(nLoadImageWidth, nLoadImageHeight, nLoadImageDepth)
      nResult = CopyImage(nLoadImageNo, nWorkImageNo)
      debugMsg2(sProcName, "CopyImage(" + decodeHandle(nLoadImageNo) + ", " + decodeHandle(nWorkImageNo) + ")", nResult)
      If IsImage(nWorkImageNo)
        If \nRotate = 90
          RotateRight90(nWorkImageNo)
          bRotated = #True
        ElseIf \nRotate = 180
          RotateRight90(nWorkImageNo)
          RotateRight90(nWorkImageNo)
          bRotated = #True
        ElseIf \nRotate = 270
          RotateLeft90(nWorkImageNo)
          bRotated = #True
        EndIf
        If bRotated
          If bUsePosLoadImage = #False
            WQA_updateCommonImageNo(nLoadImageNo, nWorkImageNo)
          EndIf
          debugMsg(sProcName, "\nRotate=" + \nRotate +
                              ", nOriginalImageNo=" + decodeHandle(nOriginalImageNo) + ", nLoadImageNo=" + decodeHandle(nLoadImageNo) + ", IsImage(nLoadImageNo)=" + IsImage(nLoadImageNo) + ", nWorkImageNo=" + decodeHandle(nWorkImageNo) + ", IsImage(nWorkImageNo)=" + IsImage(nWorkImageNo))
          nLoadImageNo = nWorkImageNo
        EndIf
        
        If \nFlip & #SCS_FLIPH
          ; flip horizontal (mirror)
          If StartVectorDrawing(ImageVectorOutput(nWorkImageNo))
            ; 1st calculation
            dReqdWidth = VectorOutputWidth()
            dReqdHeight = nLoadImageHeight / nLoadImageWidth * dReqdWidth
            ; 2nd calculation
            dReqdHeight2 = VectorOutputHeight()
            dReqdWidth2 = nLoadImageWidth / nLoadImageHeight * dReqdHeight2
            ; decide if we need to use the 1st or the 2nd calculation
            If dReqdWidth2 < dReqdWidth Or dReqdHeight2 < dReqdHeight
              dReqdWidth = dReqdWidth2
              dReqdHeight = dReqdHeight2
            EndIf
            ; calculate dCursorX as the left/right margin, plus the required width
            dCursorX = ((VectorOutputWidth() - dReqdWidth) / 2) + dReqdWidth
            ; calculate dCursorY as the top/bottom margin
            dCursorY = ((VectorOutputHeight() - dReqdHeight) / 2)
            MovePathCursor(dCursorX, dCursorY)
            FlipCoordinatesX(dCursorX)
            DrawVectorImage(ImageID(nLoadImageNo), 255, dReqdWidth, dReqdHeight)
            StopVectorDrawing()
            If bUsePosLoadImage = #False
              WQA_updateCommonImageNo(nLoadImageNo, nWorkImageNo)
            EndIf
            debugMsg(sProcName, "FlipH" +
                                ", nOriginalImageNo=" + nOriginalImageNo + ", nLoadImageNo=" + nLoadImageNo + ", IsImage(nLoadImageNo)=" + IsImage(nLoadImageNo) + ", nWorkImageNo=" + nWorkImageNo + ", IsImage(nWorkImageNo)=" + IsImage(nWorkImageNo))
            nLoadImageNo = nWorkImageNo
          EndIf
        EndIf ; EndIf \nFlip & #SCS_FLIPH
        
        If \nFlip & #SCS_FLIPV
          ; flip vertical
          If StartVectorDrawing(ImageVectorOutput(nWorkImageNo))
            ; 1st calculation
            dReqdWidth = VectorOutputWidth()
            dReqdHeight = nLoadImageHeight / nLoadImageWidth * dReqdWidth
            ; 2nd calculation
            dReqdHeight2 = VectorOutputHeight()
            dReqdWidth2 = nLoadImageWidth / nLoadImageHeight * dReqdHeight2
            ; decide if we need to use the 1st or the 2nd calculation
            If dReqdWidth2 < dReqdWidth Or dReqdHeight2 < dReqdHeight
              dReqdWidth = dReqdWidth2
              dReqdHeight = dReqdHeight2
            EndIf
            ; calculate dCursorX as the left margin
            dCursorX = ((VectorOutputWidth() - dReqdWidth) / 2)
            ; calculate dCursorY as the top/bottom margin, plus the required height
            dCursorY = ((VectorOutputHeight() - dReqdHeight) / 2) + dReqdHeight
            MovePathCursor(dCursorX, dCursorY)
            FlipCoordinatesY(dCursorY)
            DrawVectorImage(ImageID(nLoadImageNo), 255, dReqdWidth, dReqdHeight)
            StopVectorDrawing()
            If bUsePosLoadImage = #False
              WQA_updateCommonImageNo(nLoadImageNo, nWorkImageNo)
            EndIf
            debugMsg(sProcName, "FlipV" +
                                ", nOriginalImageNo=" + nOriginalImageNo + ", nLoadImageNo=" + nLoadImageNo + ", IsImage(nLoadImageNo)=" + IsImage(nLoadImageNo) + ", nWorkImageNo=" + nWorkImageNo + ", IsImage(nWorkImageNo)=" + IsImage(nWorkImageNo))
            nLoadImageNo = nWorkImageNo
          EndIf
        EndIf ; EndIf \nFlip & #SCS_FLIPV
      EndIf ; EndIf IsImage(nWorkImageNo)
      
      If bUsePosLoadImage
        If IsImage(\nPosImageAfterRotateAndFlip)
          If \nPosImageAfterRotateAndFlip <> \nPosLoadImageNo
            condFreeImage(\nPosImageAfterRotateAndFlip)
          EndIf
        EndIf
        \nPosImageAfterRotateAndFlip = nLoadImageNo
        debugMsg(sProcName, "\nPosLoadImageNo=" + decodeHandle(\nPosLoadImageNo) + ", \nPosImageAfterRotateAndFlip=" + decodeHandle(\nPosImageAfterRotateAndFlip) + ", IsImage(\nPosImageAfterRotateAndFlip)=" + IsImage(\nPosImageAfterRotateAndFlip))
      Else
        If IsImage(\nImageAfterRotateAndFlip)
          If \nImageAfterRotateAndFlip <> \nLoadImageNo
            condFreeImage(\nImageAfterRotateAndFlip)
          EndIf
        EndIf
        \nImageAfterRotateAndFlip = nLoadImageNo
        debugMsg(sProcName, "\nLoadImageNo=" + decodeHandle(\nLoadImageNo) + ", \nImageAfterRotateAndFlip=" + decodeHandle(\nImageAfterRotateAndFlip) + ", IsImage(\nImageAfterRotateAndFlip)=" + strB(IsImage(\nImageAfterRotateAndFlip)))
      EndIf
      
    EndWith
  EndIf
  
  qTime - ElapsedMilliseconds()
  debugMsg(sProcName, #SCS_END + ", time:" + Str(0-qTime) + "ms")
  
EndProcedure

Procedure rotateAndFlipImageIfReqd(pAudPtr, bUsePosLoadImage=#False)
  PROCNAMECA(pAudPtr)
  Protected qTime.q
  Protected nOriginalImageNo, nLoadImageNo, nLoadImageWidth, nLoadImageHeight, nLoadImageDepth, nWorkImageNo
  Protected dReqdWidth.d, dReqdHeight.d, dReqdWidth2.d, dReqdHeight2.d, dCursorX.d, dCursorY.d
  
  ; NOTE: This Procedure uses PureBasic Vector Drawing to rotate and/or flip the image.
  ; When SCS was first converted to PB, the Vector Drawing library didn't exist, so separate procedures in the file "RotateImage.pbi" were used.
  ; However, in tests in Apr2020 I found that the RotateImage() Procedure was very slow - typically taking 6-8 seconds to do a 90 degree rotation of an image taken using a camera,
  ; eg an image of 4608x2592 pixels. Experimenting with Vector Drawing, this same process typically takes less than a second - eg about 450ms.
  ; Some of the logic was difficult to get right, especially the setting of dCursorX and dCursorY. Testing was done using the test program "PB Test Files\VectorImageTest.pb".
  ; See also the example code in the PB Help Topic DrawVectorImage().
  
  debugMsg(sProcName, #SCS_START + ", bUsePosLoadImage=" + strB(bUsePosLoadImage))
  
  qTime = ElapsedMilliseconds()
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If bUsePosLoadImage
        nOriginalImageNo = \nPosLoadImageNo
      Else
        nOriginalImageNo = \nLoadImageNo
      EndIf
      nLoadImageNo = nOriginalImageNo
      nLoadImageWidth = ImageWidth(nLoadImageNo)
      nLoadImageHeight = ImageHeight(nLoadImageNo)
      nLoadImageDepth = ImageDepth(nLoadImageNo)
; debugMsg0(sProcName, "nLoadImageNo=" + nLoadImageNo + ", nLoadImageWidth=" + nLoadImageWidth + ", nLoadImageHeight=" + nLoadImageHeight + ", nLoadImageDepth=" + nLoadImageDepth)
      nWorkImageNo = scsCreateImage(nLoadImageWidth, nLoadImageHeight, nLoadImageDepth)
      If IsImage(nWorkImageNo)
        If \nRotate <> 0
          If StartVectorDrawing(ImageVectorOutput(nWorkImageNo))
            ; 1st calculation
            dReqdWidth = VectorOutputHeight() ; use Vector Output HEIGHT for the required WIDTH as we are going to rotate the image 90 degrees
            dReqdHeight = nLoadImageHeight / nLoadImageWidth * dReqdWidth
            ; 2nd calculation
            dReqdHeight2 = VectorOutputWidth() ; use Vector Output WIDTH for the required HEIGHT as we are going to rotate the image 90 degrees
            dReqdWidth2 = nLoadImageWidth / nLoadImageHeight * dReqdHeight2
            ; decide if we need to use the 1st or the 2nd calculation
            If dReqdWidth2 < dReqdWidth Or dReqdHeight2 < dReqdHeight
              dReqdWidth = dReqdWidth2
              dReqdHeight = dReqdHeight2
            EndIf
            ; calculate dCursorX as the left/right margin, plus the required HEIGHT (because we are going to rotate 90 degrees)
            dCursorX.d = ((VectorOutputWidth() - dReqdHeight) / 2) + dReqdHeight
            ; calculate dCursorY as the top/bottom margin
            dCursorY.d = ((VectorOutputHeight() - dReqdWidth) / 2)
            MovePathCursor(dCursorX, dCursorY)
            RotateCoordinates(dCursorX, 0, \nRotate)
            DrawVectorImage(ImageID(nLoadImageNo), 255, dReqdWidth, dReqdHeight)
            StopVectorDrawing()
            If bUsePosLoadImage = #False
              WQA_updateCommonImageNo(nLoadImageNo, nWorkImageNo)
            EndIf
            debugMsg(sProcName, "\nRotate=" + \nRotate +
                                ", nOriginalImageNo=" + nOriginalImageNo + ", nLoadImageNo=" + nLoadImageNo + ", IsImage(nLoadImageNo)=" + IsImage(nLoadImageNo) + ", nWorkImageNo=" + nWorkImageNo + ", IsImage(nWorkImageNo)=" + IsImage(nWorkImageNo))
            nLoadImageNo = nWorkImageNo
          EndIf
        EndIf ; EndIf \nRotate <> 0
        
        If \nFlip & #SCS_FLIPH
          ; flip horizontal (mirror)
          If StartVectorDrawing(ImageVectorOutput(nWorkImageNo))
            ; 1st calculation
            dReqdWidth = VectorOutputWidth()
            dReqdHeight = nLoadImageHeight / nLoadImageWidth * dReqdWidth
            ; 2nd calculation
            dReqdHeight2 = VectorOutputHeight()
            dReqdWidth2 = nLoadImageWidth / nLoadImageHeight * dReqdHeight2
            ; decide if we need to use the 1st or the 2nd calculation
            If dReqdWidth2 < dReqdWidth Or dReqdHeight2 < dReqdHeight
              dReqdWidth = dReqdWidth2
              dReqdHeight = dReqdHeight2
            EndIf
            ; calculate dCursorX as the left/right margin, plus the required width
            dCursorX = ((VectorOutputWidth() - dReqdWidth) / 2) + dReqdWidth
            ; calculate dCursorY as the top/bottom margin
            dCursorY = ((VectorOutputHeight() - dReqdHeight) / 2)
            MovePathCursor(dCursorX, dCursorY)
            FlipCoordinatesX(dCursorX)
            DrawVectorImage(ImageID(nLoadImageNo), 255, dReqdWidth, dReqdHeight)
            StopVectorDrawing()
            If bUsePosLoadImage = #False
              WQA_updateCommonImageNo(nLoadImageNo, nWorkImageNo)
            EndIf
            debugMsg(sProcName, "FlipH" +
                                ", nOriginalImageNo=" + nOriginalImageNo + ", nLoadImageNo=" + nLoadImageNo + ", IsImage(nLoadImageNo)=" + IsImage(nLoadImageNo) + ", nWorkImageNo=" + nWorkImageNo + ", IsImage(nWorkImageNo)=" + IsImage(nWorkImageNo))
            nLoadImageNo = nWorkImageNo
          EndIf
        EndIf ; EndIf \nFlip & #SCS_FLIPH
        
        If \nFlip & #SCS_FLIPV
          ; flip vertical
          If StartVectorDrawing(ImageVectorOutput(nWorkImageNo))
            ; 1st calculation
            dReqdWidth = VectorOutputWidth()
            dReqdHeight = nLoadImageHeight / nLoadImageWidth * dReqdWidth
            ; 2nd calculation
            dReqdHeight2 = VectorOutputHeight()
            dReqdWidth2 = nLoadImageWidth / nLoadImageHeight * dReqdHeight2
            ; decide if we need to use the 1st or the 2nd calculation
            If dReqdWidth2 < dReqdWidth Or dReqdHeight2 < dReqdHeight
              dReqdWidth = dReqdWidth2
              dReqdHeight = dReqdHeight2
            EndIf
            ; calculate dCursorX as the left margin
            dCursorX = ((VectorOutputWidth() - dReqdWidth) / 2)
            ; calculate dCursorY as the top/bottom margin, plus the required height
            dCursorY = ((VectorOutputHeight() - dReqdHeight) / 2) + dReqdHeight
            MovePathCursor(dCursorX, dCursorY)
            FlipCoordinatesY(dCursorY)
            DrawVectorImage(ImageID(nLoadImageNo), 255, dReqdWidth, dReqdHeight)
            StopVectorDrawing()
            If bUsePosLoadImage = #False
              WQA_updateCommonImageNo(nLoadImageNo, nWorkImageNo)
            EndIf
            debugMsg(sProcName, "FlipV" +
                                ", nOriginalImageNo=" + nOriginalImageNo + ", nLoadImageNo=" + nLoadImageNo + ", IsImage(nLoadImageNo)=" + IsImage(nLoadImageNo) + ", nWorkImageNo=" + nWorkImageNo + ", IsImage(nWorkImageNo)=" + IsImage(nWorkImageNo))
            nLoadImageNo = nWorkImageNo
          EndIf
        EndIf ; EndIf \nFlip & #SCS_FLIPV
      EndIf ; EndIf IsImage(nWorkImageNo)
      
      If bUsePosLoadImage
        If IsImage(\nPosImageAfterRotateAndFlip)
          If \nPosImageAfterRotateAndFlip <> \nPosLoadImageNo
            condFreeImage(\nPosImageAfterRotateAndFlip)
          EndIf
        EndIf
        \nPosImageAfterRotateAndFlip = nLoadImageNo
        debugMsg(sProcName, "\nPosLoadImageNo=" + \nPosLoadImageNo + ", \nPosImageAfterRotateAndFlip=" + \nPosImageAfterRotateAndFlip + ", IsImage(\nPosImageAfterRotateAndFlip)=" + IsImage(\nPosImageAfterRotateAndFlip))
      Else
        If IsImage(\nImageAfterRotateAndFlip)
          If \nImageAfterRotateAndFlip <> \nLoadImageNo
            condFreeImage(\nImageAfterRotateAndFlip)
          EndIf
        EndIf
        \nImageAfterRotateAndFlip = nLoadImageNo
        debugMsg(sProcName, "\nLoadImageNo=" + \nLoadImageNo + ", \nImageAfterRotateAndFlip=" + \nImageAfterRotateAndFlip + ", IsImage(\nImageAfterRotateAndFlip)=" + IsImage(\nImageAfterRotateAndFlip))
      EndIf
      
    EndWith
  EndIf
  
  qTime - ElapsedMilliseconds()
  debugMsg(sProcName, #SCS_END + ", time:" + Str(0-qTime) + "ms")
  
EndProcedure

Procedure createReqdVidPicTargetImages(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr, nVidPicTarget, nTargetWidth, nTargetHeight, nMainVidPicTarget
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  If aSub(nSubPtr)\bStartedInEditor = #False
    nMainVidPicTarget = getVidPicTargetForOutputScreen(aSub(nSubPtr)\nOutputScreen)
    With aAud(pAudPtr)
      For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        If nVidPicTarget <> nMainVidPicTarget
          ; no need to create a nVidPicTargetImageNo for nMainVidPicTarget as this image is already created as \nMainImageNo
          If aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
            If IsImage(\nVidPicTargetImageNo(nVidPicTarget)) = #False
              nTargetWidth = grVidPicTarget(nVidPicTarget)\nTargetWidth
              nTargetHeight = grVidPicTarget(nVidPicTarget)\nTargetHeight
              ; create \nMainImageNo the size of the target (eg the size of the canvas in #SCS_VID_PIC_TARGET_F2), and then 'paint' nOrigLoadImage into \nMainImageNo
              \nVidPicTargetImageNo(nVidPicTarget) = scsCreateImage(nTargetWidth, nTargetHeight)
              logCreateImage(109, \nVidPicTargetImageNo(nVidPicTarget), pAudPtr, nVidPicTarget, "\nVidPicTargetImageNo(" + decodeVidPicTarget(nVidPicTarget) + ")", getAudLabel(pAudPtr)+".VidPic"+decodeVidPicTarget(nVidPicTarget))
            EndIf
          EndIf
        EndIf
      Next nVidPicTarget
    EndWith
  EndIf
  
EndProcedure

Procedure loadAndFitAPicture(pAudPtr, pVidPicTarget)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nImageWidth, nImageHeight
  Protected nTargetWidth, nTargetHeight
  Protected sMyFileName.s
  Protected nOrigLoadImage
  Protected nOrigLoadImageWidth, nOrigLoadImageHeight
  Protected nTargetImage
  Protected n, nTmp
  Protected bLockedMutex
  Protected bNewImage, nMyImagePtr
  Protected bLoadImageResult
  
  sMyFileName = aAud(pAudPtr)\sFileName
  debugMsg(sProcName, #SCS_START + " \sFileName=" + GetFilePart(sMyFileName))
  
  If FileExists(sMyFileName) = #False
    debugMsg(sProcName, "exiting because file does not exist")
    ProcedureReturn #False
  EndIf
  
  With aAud(pAudPtr)
    
    Select \nAudState
      Case #SCS_CUE_ERROR
        debugMsg(sProcName, "exiting and returning #False because \nAudState=" + decodeCueState(\nAudState))
        ProcedureReturn #False
        
      Case #SCS_CUE_FADING_IN To #SCS_CUE_FADING_OUT
        If (pVidPicTarget = #SCS_VID_PIC_TARGET_P) And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)
          debugMsg(sProcName, "exiting and returning #False because \nAudState=" + decodeCueState(\nAudState) + " and \nFileFormat=" + decodeFileFormat(\nFileFormat))
          ProcedureReturn #False
        EndIf
    EndSelect
    
    If pVidPicTarget > gnMaxVidPicTargetSetup
      debugMsg(sProcName, "calling setVidPicTargets()")
      setVidPicTargets()
    Else
      debugMsg(sProcName, "calling assignCanvases(" + getSubLabel(\nSubIndex) + ", " + getAudLabel(pAudPtr) + ")")
      assignCanvases(\nSubIndex, pAudPtr)
    EndIf
    
    \bBlending = #False
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bBlending=" + strB(aAud(pAudPtr)))
    
    debugMsg(sProcName, "\bReloadMainImage=" + strB(\bReloadMainImage) + ", \nImagePtr=" + \nImagePtr)
    If \bReloadMainImage = #False
      If \nImagePtr = -1
        \nImagePtr = getImagePtrForAud(pAudPtr, pVidPicTarget)
        If \nImagePtr = -1 
          bNewImage = #True
        Else
          nMyImagePtr = \nImagePtr
          gaImageData(nMyImagePtr)\nImageOpenCount + 1
          If pVidPicTarget >= 0
            \nVidPicTargetImageNo(pVidPicTarget) = gaImageData(nMyImagePtr)\nImageNo
          EndIf
          debugMsg(sProcName, "gaImageData(" + nMyImagePtr + ")\sFileName=" + GetFilePart(gaImageData(nMyImagePtr)\sFileName) +
                              ", \nImageNo=" + gaImageData(nMyImagePtr)\nImageNo + ", \nImageOpenCount=" + gaImageData(nMyImagePtr)\nImageOpenCount)
          debugMsg3(sProcName, "\nLoadImageNo=" + decodeHandle(\nLoadImageNo) + ", \nImageAfterRotateAndFlip=" + decodeHandle(\nImageAfterRotateAndFlip) +
                               ", \nVidPicTargetImageNo(" + decodeVidPicTarget(pVidPicTarget) + ")=" + decodeHandle(\nVidPicTargetImageNo(pVidPicTarget)) +
                               ", nThumbnailImageNo=" + decodeHandle(\nThumbnailImageNo))
          ; Deleted 30Mar2022 11.9.1ax to assist in getting animated images to work, which requires seom of the subsequent processing in this procedure
          ; debugMsg(sProcName, "exiting because image already loaded")
          ; ProcedureReturn #True ; exit now as image already loaded
          ; End delete 30Mar2022 11.9.1ax
        EndIf
      EndIf
    EndIf
    
    LockImageMutex(230)
    debugMsg(sProcName, "calling loadImageIfReqd(" + getAudLabel(pAudPtr) + ")")
    bLoadImageResult = loadImageIfReqd(pAudPtr)
    debugMsg(sProcName, "bLoadImageResult=" + strB(bLoadImageResult) + ", \nLoadImageNo=" + decodeHandle(\nLoadImageNo) +
                        ", \nImageAfterRotateAndFlip=" + decodeHandle(\nImageAfterRotateAndFlip) +
                        ", \nVidPicTargetImageNo(" + decodeVidPicTarget(pVidPicTarget) + ")=" + decodeHandle(\nVidPicTargetImageNo(pVidPicTarget)) +
                        ", nThumbnailImageNo=" + decodeHandle(\nThumbnailImageNo))
    If bLoadImageResult = #False
      UnlockImageMutex()
      ProcedureReturn #False
    EndIf
    
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
        nOrigLoadImage = \nImageAfterRotateAndFlip
        nTargetWidth = grVidPicTarget(pVidPicTarget)\nTargetWidth
        nTargetHeight = grVidPicTarget(pVidPicTarget)\nTargetHeight
        
      Case #SCS_VID_PIC_TARGET_T
        nOrigLoadImage = \nImageAfterRotateAndFlip
        nTargetWidth = #SCS_QATIMELINE_IMAGE_WIDTH
        nTargetHeight = #SCS_QATIMELINE_IMAGE_HEIGHT
        
    EndSelect
    nOrigLoadImageWidth = ImageWidth(nOrigLoadImage)
    nOrigLoadImageHeight = ImageHeight(nOrigLoadImage)
    debugMsg(sProcName, "nOrigLoadImage=" + decodeHandle(nOrigLoadImage) + ", ImageWidth()=" + nOrigLoadImageWidth + ", ImageHeight()=" + nOrigLoadImageHeight + ", nTargetWidth=" + nTargetWidth + ", nTargetHeight=" + nTargetHeight)

    If ImageFrameCount(nOrigLoadImage) > 1
      \sFileType = grText\sTextAnimated + " " + UCase(GetExtensionPart(\sFileName))
    Else
      \sFileType = UCase(GetExtensionPart(\sFileName))
    EndIf
    If (nOrigLoadImageWidth > 0) And (nOrigLoadImageHeight > 0)
      \sFileType + " " + nOrigLoadImageWidth + "x" + nOrigLoadImageHeight
    EndIf
    debugMsg(sProcName, "\sFileType=" + \sFileType)
    
    \nSourceWidth = ImageWidth(nOrigLoadImage)
    \nSourceHeight = ImageHeight(nOrigLoadImage)
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
    
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        ; create \nVidPicTargetImageNo(pVidPicTarget) the size of the target (eg the size of the canvas in #SCS_VID_PIC_TARGET_F2), and then 'paint' nOrigLoadImage into \nVidPicTargetImageNo(pVidPicTarget)
        \nVidPicTargetImageNo(pVidPicTarget) = scsCreateImage(nTargetWidth, nTargetHeight)
        logCreateImage(101, \nVidPicTargetImageNo(pVidPicTarget), pAudPtr, pVidPicTarget, "\nVidPicTargetImageNo(" + decodeVidPicTarget(pVidPicTarget) + ")", getAudLabel(pAudPtr)+".VidPic"+decodeVidPicTarget(pVidPicTarget))
        debugMsg3(sProcName, "calling paintPictureAtPosAndSize(" + getAudLabel(pAudPtr) + ", " + decodeHandle(\nVidPicTargetImageNo(pVidPicTarget)) + ", " + decodeHandle(nOrigLoadImage) + ", #False)")
        paintPictureAtPosAndSize(pAudPtr, \nVidPicTargetImageNo(pVidPicTarget), nOrigLoadImage, #False)
        nTargetImage = \nVidPicTargetImageNo(pVidPicTarget)
        If pVidPicTarget = #SCS_VID_PIC_TARGET_P
          \nDisplayLeft(pVidPicTarget) = grDPS\nDisplayLeft
          \nDisplayTop(pVidPicTarget) = grDPS\nDisplayTop
          \nDisplayWidth(pVidPicTarget) = grDPS\nDisplayWidth
          \nDisplayHeight(pVidPicTarget) = grDPS\nDisplayHeight
        EndIf
        
      Case #SCS_VID_PIC_TARGET_T
        ; no action required
        
    EndSelect
    
    debugMsg(sProcName, "nTargetImage=" + decodeHandle(nTargetImage))
    storeImageData(pAudPtr, pVidPicTarget, nTargetImage)
    
    \bReloadMainImage = #False
    
    debugMsg3(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo=" + decodeHandle(\nLoadImageNo) + ", \nImageAfterRotateAndFlip=" + decodeHandle(\nImageAfterRotateAndFlip) +
                         ", \nVidPicTargetImageNo(" + decodeVidPicTarget(pVidPicTarget) + ")=" + decodeHandle(\nVidPicTargetImageNo(pVidPicTarget)) + ", nThumbnailImageNo=" + decodeHandle(\nThumbnailImageNo))
    
    UnlockImageMutex()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure loadAndFitPictureForAud(pAudPtr, bCalledFromEditor=#False)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr, nVidPicTarget, bProcessThisVidPicTarget
  Protected nImageWidth, nImageHeight
  Protected nTargetWidth, nTargetHeight
  Protected sMyFileName.s
  Protected nOrigLoadImage
  Protected nOrigLoadImageWidth, nOrigLoadImageHeight
  Protected nTargetImage
  Protected n, nTmp
  Protected bLockedMutex
  Protected bNewImage, nMyImagePtr
  Protected bLoadImageResult
  
  sMyFileName = aAud(pAudPtr)\sFileName
  debugMsg(sProcName, #SCS_START + ", bCalledFromEditor=" + strB(bCalledFromEditor) + ", aAud(" + getAudLabel(pAudPtr) + ")\sFileName=" + GetFilePart(sMyFileName))
  
  If FileExists(sMyFileName) = #False
    debugMsg(sProcName, "exiting because file does not exist")
    ProcedureReturn #False
  EndIf
  
  With aAud(pAudPtr)
    
    Select \nAudState
      Case #SCS_CUE_ERROR
        debugMsg(sProcName, "exiting and returning #False because \nAudState=" + decodeCueState(\nAudState))
        ProcedureReturn #False
        
      Case #SCS_CUE_FADING_IN To #SCS_CUE_FADING_OUT
        If \nFileFormat = #SCS_FILEFORMAT_VIDEO
          debugMsg(sProcName, "exiting and returning #False because \nAudState=" + decodeCueState(\nAudState) + " and \nFileFormat=" + decodeFileFormat(\nFileFormat))
          ProcedureReturn #False
        EndIf
    EndSelect
    
    nSubPtr = \nSubIndex
    For nVidPicTarget = #SCS_VID_PIC_TARGET_LAST To #SCS_VID_PIC_TARGET_F2 Step -1
      If aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
        If nVidPicTarget > gnMaxVidPicTargetSetup
          debugMsg(sProcName, "calling setVidPicTargets()")
          setVidPicTargets()
        EndIf
        Break
      EndIf
    Next nVidPicTarget
    
    debugMsg(sProcName, "calling assignCanvases(" + getSubLabel(nSubPtr) + ", " + getAudLabel(pAudPtr) + ")")
    assignCanvases(nSubPtr, pAudPtr)
    
    \bBlending = #False
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bBlending=" + strB(aAud(pAudPtr)))
    
    LockImageMutex(230)
    debugMsg(sProcName, "calling loadImageIfReqd(" + getAudLabel(pAudPtr) + ")")
    bLoadImageResult = loadImageIfReqd(pAudPtr)
    debugMsg(sProcName, "bLoadImageResult=" + strB(bLoadImageResult) + ", \nLoadImageNo=" + decodeHandle(\nLoadImageNo) +
                        ", \nImageAfterRotateAndFlip=" + decodeHandle(\nImageAfterRotateAndFlip) +
                        ", nThumbnailImageNo=" + decodeHandle(\nThumbnailImageNo))
    If bLoadImageResult = #False
      UnlockImageMutex()
      ProcedureReturn #False
    EndIf
    
    nOrigLoadImage = \nImageAfterRotateAndFlip
    nOrigLoadImageWidth = ImageWidth(nOrigLoadImage)
    nOrigLoadImageHeight = ImageHeight(nOrigLoadImage)
    ; debugMsg(sProcName, "nOrigLoadImage=" + decodeHandle(nOrigLoadImage) + ", ImageWidth()=" + nOrigLoadImageWidth + ", ImageHeight()=" + nOrigLoadImageHeight)
    If ImageFrameCount(nOrigLoadImage) > 1
      \sFileType = grText\sTextAnimated + " " + UCase(GetExtensionPart(\sFileName))
    Else
      \sFileType = UCase(GetExtensionPart(\sFileName))
    EndIf
    If (nOrigLoadImageWidth > 0) And (nOrigLoadImageHeight > 0)
      \sFileType + " " + nOrigLoadImageWidth + "x" + nOrigLoadImageHeight
    EndIf
    debugMsg(sProcName, "\sFileType=" + \sFileType)
    
    \nSourceWidth = ImageWidth(nOrigLoadImage)
    \nSourceHeight = ImageHeight(nOrigLoadImage)
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
    
    For nVidPicTarget = #SCS_VID_PIC_TARGET_T To #SCS_VID_PIC_TARGET_LAST
      bProcessThisVidPicTarget = #False
      If bCalledFromEditor
        If nVidPicTarget = #SCS_VID_PIC_TARGET_T
          nTargetWidth = #SCS_QATIMELINE_IMAGE_WIDTH
          nTargetHeight = #SCS_QATIMELINE_IMAGE_HEIGHT
          bProcessThisVidPicTarget = #True
        ElseIf nVidPicTarget = #SCS_VID_PIC_TARGET_P
          nTargetWidth = grVidPicTarget(nVidPicTarget)\nTargetWidth
          nTargetHeight = grVidPicTarget(nVidPicTarget)\nTargetHeight
          bProcessThisVidPicTarget = #True
        EndIf
      EndIf
      Select nVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          If aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
            nTargetWidth = grVidPicTarget(nVidPicTarget)\nTargetWidth
            nTargetHeight = grVidPicTarget(nVidPicTarget)\nTargetHeight
            bProcessThisVidPicTarget = #True
          EndIf
      EndSelect
      If bProcessThisVidPicTarget
        Select nVidPicTarget
          Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            ; create \nVidPicTargetImageNo(nVidPicTarget) the size of the target (eg the size of the canvas in #SCS_VID_PIC_TARGET_F2), and then 'paint' nOrigLoadImage into \nVidPicTargetImageNo(nVidPicTarget)
            \nVidPicTargetImageNo(nVidPicTarget) = scsCreateImage(nTargetWidth, nTargetHeight)
            logCreateImage(101, \nVidPicTargetImageNo(nVidPicTarget), pAudPtr, nVidPicTarget, "\nVidPicTargetImageNo(" + decodeVidPicTarget(nVidPicTarget) + ")", getAudLabel(pAudPtr)+".VidPic"+decodeVidPicTarget(nVidPicTarget))
            debugMsg3(sProcName, "calling paintPictureAtPosAndSize(" + getAudLabel(pAudPtr) + ", " + decodeHandle(\nVidPicTargetImageNo(nVidPicTarget)) + ", " + decodeHandle(nOrigLoadImage) + ", #False)")
            paintPictureAtPosAndSize(pAudPtr, \nVidPicTargetImageNo(nVidPicTarget), nOrigLoadImage, #False)
            nTargetImage = \nVidPicTargetImageNo(nVidPicTarget)
            
          Case #SCS_VID_PIC_TARGET_T
            ; no action required
            
        EndSelect
        
        debugMsg(sProcName, "nTargetImage=" + decodeHandle(nTargetImage))
        storeImageData(pAudPtr, nVidPicTarget, nTargetImage)
      EndIf ; EndIf bProcessThisVidPicTarget
    Next nVidPicTarget
    
    \bReloadMainImage = #False
    UnlockImageMutex()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure closePrevPrimaryAudIfReqd(nPrevPrimaryAudPtr, nThisAudPtr)
  PROCNAMECA(nPrevPrimaryAudPtr)
  
  debugMsg(sProcName, #SCS_START + ", nPrevPrimaryAudPtr=" + getAudLabel(nPrevPrimaryAudPtr) + ", nThisAudPtr=" + getAudLabel(nThisAudPtr))
  
  If nPrevPrimaryAudPtr >= 0
    With aAud(nPrevPrimaryAudPtr)
      If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
        If nThisAudPtr >= 0
          If (\nCueIndex > aAud(nThisAudPtr)\nCueIndex) And (grProd\nRunMode = #SCS_RUN_MODE_LINEAR)
            debugMsg(sProcName, "calling closeAud(" + getAudLabel(nPrevPrimaryAudPtr) + ", #True, #False)")
            closeAud(nPrevPrimaryAudPtr, #True, #False)
          Else
            debugMsg(sProcName, "calling closeAud(" + getAudLabel(nPrevPrimaryAudPtr) + ", #False, #True)")
            closeAud(nPrevPrimaryAudPtr, #False, #True)
          EndIf
        Else
          debugMsg(sProcName, "calling closeAud(" + getAudLabel(nPrevPrimaryAudPtr) + ", #False, #True)")
          closeAud(nPrevPrimaryAudPtr, #False, #True)
        EndIf
        debugMsg(sProcName, "calling setCueState(" + getCueLabel(\nCueIndex) + ")")
        setCueState(\nCueIndex)
        gnCallOpenNextCues = 1
        debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
        debugMsg(sProcName, "(21) setting gbCallLoadDispPanels=#True")
        gbCallLoadDispPanels = #True
        If \bAudTypeA
          freeAudImages(nPrevPrimaryAudPtr)
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closePrevPlayingSubIfReqd(nPrevPlayingSubPtr, nThisSubPtr)
  PROCNAMECS(nPrevPlayingSubPtr)
  Protected bSubClosed
  
  debugMsg(sProcName, #SCS_START + ", nPrevPlayingSubPtr=" + getSubLabel(nPrevPlayingSubPtr) + ", nThisSubPtr=" + getSubLabel(nThisSubPtr))
  
  If nPrevPlayingSubPtr >= 0
    With aSub(nPrevPlayingSubPtr)
      If \bSubTypeE
        If (\nSubState >= #SCS_CUE_FADING_IN) And (\nSubState <= #SCS_CUE_FADING_OUT)
          If nThisSubPtr >= 0
            If (\nCueIndex > aSub(nThisSubPtr)\nCueIndex) And (grProd\nRunMode = #SCS_RUN_MODE_LINEAR)
              debugMsg(sProcName, "(g1) setting aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState = #SCS_CUE_NOT_LOADED")
              \nSubState = #SCS_CUE_NOT_LOADED
            Else
              debugMsg(sProcName, "(g3) setting aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState = #SCS_CUE_COMPLETED")
              \nSubState = #SCS_CUE_COMPLETED
              debugMsg(sProcName, "(g4) aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
            EndIf
          Else
            debugMsg(sProcName, "(g5) setting aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState = #SCS_CUE_COMPLETED")
            \nSubState = #SCS_CUE_COMPLETED
            debugMsg(sProcName, "(g6) aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
          EndIf
          bSubClosed = #True
          debugMsg(sProcName, "calling setCueState(" + aCue(\nCueIndex)\sCue + ")")
          setCueState(\nCueIndex)
          gnCallOpenNextCues = 1
          debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
          debugMsg(sProcName, "(21) setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning bSubClosed=" + strB(bSubClosed))
  ProcedureReturn bSubClosed
  
EndProcedure

Procedure setMonitorCanvasVisible(pVidPicTarget, nMonitorCanvasNo, bVisible)
  PROCNAMEC()
  Protected nScreenNo
  Protected n
  Protected nCanvasNo
  Protected nMonitorWindowNo
  Protected nActiveWindow
  
  If IsGadget(nMonitorCanvasNo)
    debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", nMonitorCanvasNo=" + getGadgetName(nMonitorCanvasNo) + ", bVisible=" + strB(bVisible))
  Else
    debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", nMonitorCanvasNo=" + nMonitorCanvasNo + ", bVisible=" + strB(bVisible))
  EndIf
  
  nActiveWindow = GetActiveWindow()
  
  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      If bVisible
        nScreenNo = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
        ; debugMsg(sProcName, "ArraySize(WMO())=" + ArraySize(WMO()) + ", nScreenNo=" + nScreenNo)
        If nScreenNo > ArraySize(WMO())
          debugMsg(sProcName, "calling setVidPicTargets()")
          setVidPicTargets()
        EndIf
        ; debugMsg(sProcName, "ArraySize(WMO())=" + ArraySize(WMO()) + ", nScreenNo=" + nScreenNo)
        CheckSubInRange(nScreenNo, ArraySize(WMO()), "WMO()")
        For n = 0 To WMO(nScreenNo)\nMaxMonitorIndex
          With WMO(nScreenNo)\aMonitor(n)
            nCanvasNo = \cvsMonitorCanvas
            If nCanvasNo <> nMonitorCanvasNo
              If getVisible(nCanvasNo)
                setVisible(nCanvasNo, #False)
                debugMsgV(sProcName, "setVisible(WMO(" + nScreenNo + ")\aMonitor(" + n + ")\nCanvasNo, #False)")
              EndIf
            EndIf
          EndWith
        Next n
        drawMonitorDragBars()
        If IsGadget(nMonitorCanvasNo)
          If getVisible(nMonitorCanvasNo) = #False
            setVisible(nMonitorCanvasNo, #True)
            debugMsgV(sProcName, "setVisible(" + getGadgetName(nMonitorCanvasNo) + ", #True)")
          EndIf
        Else
          debugMsg(sProcName, "IsGadget(" + nMonitorCanvasNo + ") failed!!!!!!!!")
          scsMessageRequester(sProcName, "IsGadget(" + nMonitorCanvasNo + ") failed!!!!!!!!" + Chr(10) +
          "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", nMonitorCanvasNo=" + nMonitorCanvasNo + ", bVisible=" + strB(bVisible))
        EndIf
        nMonitorWindowNo = grVidPicTarget(pVidPicTarget)\nMonitorWindowNo
        debugMsg(sProcName, "nMonitorWindowNo=" + decodeWindow(nMonitorWindowNo))
        If getWindowVisible(nMonitorWindowNo) = #False
          setWindowVisible(nMonitorWindowNo, #True)
          debugMsgV(sProcName, "setWindowVisible(" + decodeWindow(nMonitorWindowNo) + ", #True)")
          setWindowSticky(nMonitorWindowNo, #True)
        EndIf
        If IsWindow(nMonitorWindowNo)
          UpdateWindow_(WindowID(nMonitorWindowNo))
        EndIf
        
      Else  ; bVisible = #False
        If getVisible(nMonitorCanvasNo)
          setVisible(nMonitorCanvasNo, #False)
          debugMsgV(sProcName, "setVisible(" + getGadgetName(nMonitorCanvasNo) + ", #False)")
        EndIf
      EndIf
  EndSelect
  
  If IsWindow(nActiveWindow)
    If GetActiveWindow() <> nActiveWindow
      SAW(nActiveWindow)
    EndIf
  EndIf
  
EndProcedure

Procedure setVideoCanvasVisible(pVidPicTarget, nVideoCanvasNo, bVisible)
  PROCNAMEC()
  Protected nScreenNo
  Protected n
  Protected nCanvasNo
  Protected nVideoWindowNo
  Protected nActiveWindow
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", nVideoCanvasNo=" + getGadgetName(nVideoCanvasNo) + ", bVisible=" + strB(bVisible))
  
  nActiveWindow = GetActiveWindow()
  
  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      If bVisible
        nScreenNo = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
        nVideoWindowNo = #WV2 + nScreenNo
        If IsWindow(nVideoWindowNo)
          For n = 0 To WVN(nScreenNo)\nMaxVideoIndex
            With WVN(nScreenNo)\aVideo(n)
              nCanvasNo = \cvsCanvas
              If nCanvasNo <> nVideoCanvasNo
                If getVisible(nCanvasNo)
                  setVisible(nCanvasNo, #False)
                  debugMsgV(sProcName, "setVisible(WVN(" + nScreenNo + ")\aVideo(" + n + ")\nCanvasNo, #False)")
                EndIf
              EndIf
            EndWith
          Next n
          If IsGadget(nVideoCanvasNo)
            If getVisible(nVideoCanvasNo) = #False
              setVisible(nVideoCanvasNo, #True)
              debugMsgV(sProcName, "setVisible(" + getGadgetName(nVideoCanvasNo) + ", #True)")
            EndIf
          EndIf
          If getWindowVisible(nVideoWindowNo) = #False
            setWindowVisible(nVideoWindowNo, #True)
            debugMsgV(sProcName, "setWindowVisible(" + decodeWindow(nVideoWindowNo) + ", #True)")
            setWindowSticky(nVideoWindowNo, #True)
          EndIf
        EndIf
        
      Else  ; bVisible = #False
        If IsGadget(nVideoCanvasNo)
          If getVisible(nVideoCanvasNo)
            setVisible(nVideoCanvasNo, #False)
            debugMsgV(sProcName, "setVisible(" + getGadgetName(nVideoCanvasNo) + ", #False)")
          EndIf
        EndIf
      EndIf
      
    Case #SCS_VID_PIC_TARGET_P
      If IsGadget(nVideoCanvasNo)
        If bVisible
          If getVisible(nVideoCanvasNo) = #False
            setVisible(nVideoCanvasNo, #True)
            debugMsgV(sProcName, "setVisible(" + getGadgetName(nVideoCanvasNo) + ", #True)")
          EndIf
        Else
          If getVisible(nVideoCanvasNo)
            setVisible(nVideoCanvasNo, #False)
            debugMsgV(sProcName, "setVisible(" + getGadgetName(nVideoCanvasNo) + ", #False)")
          EndIf
        EndIf
      EndIf
      
  EndSelect
  
  If IsWindow(nActiveWindow)
    If GetActiveWindow() <> nActiveWindow
      SAW(nActiveWindow)
    EndIf
  EndIf
  
EndProcedure

Procedure beginFadeAudPictureToPrimary(pAudPtr, pPrimaryVidPicTarget, nBlendTime)
  PROCNAMECA(pAudPtr)
  Protected bLockedMutex
  Protected nSubPtr, bSubStartedInEditor
  Protected nVidPicTarget, nMyPrimaryImageNo, nVideoCanvasNo, nMonitorCanvasNo
  Protected bDisplayMonitor
  Protected nVidPicImage, bCreateOrResumeBlenderThread
  Protected nMinVidPicTarget, nMaxVidPicTarget, bCheckScreenReqd, bDisplayOnThisVidPicTarget
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pPrimaryVidPicTarget))
  
  createReqdVidPicTargetImages(pAudPtr)
  
  nMyPrimaryImageNo = aAud(pAudPtr)\nVidPicTargetImageNo(pPrimaryVidPicTarget)
  If IsImage(nMyPrimaryImageNo) = #False
    loadAndFitAPicture(pAudPtr, pPrimaryVidPicTarget)
    nMyPrimaryImageNo = aAud(pAudPtr)\nVidPicTargetImageNo(pPrimaryVidPicTarget)
  EndIf
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  bSubStartedInEditor = aSub(nSubPtr)\bStartedInEditor
  With aSub(nSubPtr)
    If \bStartedInEditor
      If gbPreviewOnOutputScreen
        nMinVidPicTarget = gnPreviewOnOutputScreenNo
        nMaxVidPicTarget = gnPreviewOnOutputScreenNo
      Else
        nMinVidPicTarget = #SCS_VID_PIC_TARGET_P
        nMaxVidPicTarget = #SCS_VID_PIC_TARGET_P
      EndIf
    Else
      nMinVidPicTarget = \nOutputScreen
      nMaxVidPicTarget = \nSubMaxOutputScreen
      bCheckScreenReqd = #True
    EndIf
  EndWith
  
  For nVidPicTarget = nMinVidPicTarget To nMaxVidPicTarget
    bDisplayOnThisVidPicTarget = #False
    If bCheckScreenReqd
      If aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
        bDisplayOnThisVidPicTarget = #True
      EndIf
    Else
      bDisplayOnThisVidPicTarget = #True
    EndIf
    If bDisplayOnThisVidPicTarget
      With grVidPicTarget(nVidPicTarget)
        
        If gbVideosOnMainWindow = #False
          If IsWindow(\nMainWindowNo)
            If getWindowVisible(\nMainWindowNo) = #False
              setWindowVisible(\nMainWindowNo, #True)
            EndIf
          EndIf
        EndIf
        
        LockImageMutex(277)
        
        If nVidPicTarget = pPrimaryVidPicTarget
          If IsImage(nMyPrimaryImageNo) = #False
            debugMsg(sProcName, "calling loadAndFitAPicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ")")
            If loadAndFitAPicture(pAudPtr, nVidPicTarget) = #False
              debugMsg(sProcName, "loadAndFitAPicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ") returned #False")
              UnlockImageMutex()
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        
        If \nPrevPrimaryAudPtr <> \nPrimaryAudPtr
          \nPrevPrimaryAudPtr = \nPrimaryAudPtr
        EndIf
        If \nPrevPlayingSubPtr <> \nPlayingSubPtr
          \nPrevPlayingSubPtr = \nPlayingSubPtr
        EndIf
        \nPrimaryAudPtr = pAudPtr
        \nPlayingSubPtr = -1
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) + ", \nPrevPlayingSubPtr=" + getSubLabel(\nPrevPlayingSubPtr) +
                            ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
        \nPrimaryFileFormat = aAud(pAudPtr)\nFileFormat
        \sPrimaryFileName = aAud(pAudPtr)\sFileName
        \nPrimaryImageNo = nMyPrimaryImageNo
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\sPrimaryFileName=" + GetFilePart(\sPrimaryFileName) + ", \nPrimaryImageNo=" + decodeHandle(\nPrimaryImageNo) +
                            ", ImageWidth()=" + ImageWidth(\nPrimaryImageNo) + ", ImageHeight()=" + ImageHeight(\nPrimaryImageNo))
        If \bLogoCurrentlyDisplayed And \nPrimaryImageNo <> \nLogoImageNo 
          \bLogoCurrentlyDisplayed = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
        EndIf
        
        If nBlendTime > 0
          \nAudPtr2 = \nAudPtr1
          \nImage2 = \nImage1
        Else
          \nAudPtr2 = -1 ; indicates no cross-fade
          \nImage2 = 0
        EndIf
        \nAudPtr1 = pAudPtr
        \nImage1 = aAud(pAudPtr)\nVidPicTargetImageNo(nVidPicTarget)
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nAudPtr1=" + getAudLabel(\nAudPtr1) + ", \nImage1=" + decodeHandle(\nImage1) + ", \nAudPtr2=" + getAudLabel(\nAudPtr2) + ", \nImage2=" + decodeHandle(\nImage2))
        If nVidPicTarget = pPrimaryVidPicTarget
          If aAud(pAudPtr)\nImageFrameCount > 1
            startAnimatedImageTimer(pAudPtr)
          EndIf
        EndIf
        
        \nBlendTime = nBlendTime
        If nBlendTime > 0
          \qBlendStartTime = ElapsedMilliseconds()
          \bBlendingLogo = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\qBlendStartTime=" + traceTime(\qBlendStartTime) + ", \nBlendTime=" + \nBlendTime + ", \bBlendingLogo=" + strB(\bBlendingLogo))
          CompilerIf #c_include_tvg
            If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
              nSubPtr = aAud(pAudPtr)\nSubIndex
              If (aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO) Or (checkUse2DDrawing(nSubPtr) = #False)
                debugMsg(sProcName, "calling addAudToTVGFadeAudArray(" + getAudLabel(pAudPtr) + ")")
                addAudToTVGFadeAudArray(pAudPtr)
              EndIf
              ; Added 28Oct2022 11.9.6 because the monitor display was not loaded if this video/image cue had a fade-in time specified and if no earlier video/image cue had been played with no fade-in time
              If bSubStartedInEditor = #False
                Select nVidPicTarget
                  Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                    bDisplayMonitor = #True
                EndSelect
                If bDisplayMonitor
                  nMonitorCanvasNo = \nMonitorCanvasNo
                  If IsGadget(nMonitorCanvasNo)
                    debugMsg(sProcName, "calling setMonitorCanvasVisible(" + decodeVidPicTarget(nVidPicTarget) + ", " + getGadgetName(nMonitorCanvasNo) + ", #True)")
                    setMonitorCanvasVisible(nVidPicTarget, nMonitorCanvasNo, #True)
                    \nCurrMonitorCanvasNo = nMonitorCanvasNo
                    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nCurrMonitorCanvasNo=" + \nCurrMonitorCanvasNo + ", " + getGadgetName(\nCurrMonitorCanvasNo))
                    grVidPicTarget(nVidPicTarget)\bImageOnMonitor = #True
                  EndIf
                EndIf
              EndIf
              ; End added 28Oct2022 11.9.6
            EndIf
          CompilerEndIf
          \bInFadeStartProcess = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
          bCreateOrResumeBlenderThread = #True
        Else
          \bInFadeStartProcess = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
          Select aAud(pAudPtr)\nFileFormat
            Case #SCS_FILEFORMAT_PICTURE
              nVidPicImage = aAud(pAudPtr)\nVidPicTargetImageNo(nVidPicTarget)
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nTargetCanvasNo=" + getGadgetName(\nTargetCanvasNo) + ", nVidPicImage=" + decodeHandle(nVidPicImage))
              If IsImage(nVidPicImage)
                nVideoCanvasNo = \nTargetCanvasNo
                debugMsgV(sProcName, "calling StartDrawing(CanvasOutput(" + getGadgetName(nVideoCanvasNo) + "))")
                If StartDrawing(CanvasOutput(nVideoCanvasNo))
                  debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nVideoCanvasNo) + "))")
                  DrawImage(ImageID(nVidPicImage), 0, 0)
                  debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nVidPicImage) + "), 0, 0)")
                  StopDrawing()
                  debugMsgD(sProcName, "StopDrawing()")
                  If getVisible(nVideoCanvasNo) = #False
                    setVisible(nVideoCanvasNo, #True)
                  EndIf
                EndIf
                ; display monitor if required
                \nCurrMonitorCanvasNo = grVidPicTargetDef\nCurrMonitorCanvasNo
                If bSubStartedInEditor = #False
                  Select grVideoDriver\nVideoPlaybackLibrary
                    Case #SCS_VPL_TVG
                      If checkUse2DDrawing(nSubPtr)
                        Select nVidPicTarget
                          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                            bDisplayMonitor = #True
                        EndSelect
                      EndIf
                  EndSelect
                  If bDisplayMonitor
                    nMonitorCanvasNo = \nMonitorCanvasNo
                    If IsGadget(nMonitorCanvasNo)
                      If StartDrawing(CanvasOutput(nMonitorCanvasNo))
                        debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nMonitorCanvasNo) + "))")
                        Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)  ; clear monitor area
                        debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
                        DrawImage(ImageID(nVidPicImage), 0, 0, OutputWidth(), OutputHeight())
                        debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nVidPicImage) + "), 0, 0, " + OutputWidth() + ", " + OutputHeight() + ")")
                        StopDrawing()
                        debugMsgD(sProcName, "StopDrawing()")
                      EndIf
                      debugMsg(sProcName, "calling setMonitorCanvasVisible(" + decodeVidPicTarget(nVidPicTarget) + ", " + getGadgetName(nMonitorCanvasNo) + ", #True)")
                      setMonitorCanvasVisible(nVidPicTarget, nMonitorCanvasNo, #True)
                      \nCurrMonitorCanvasNo = nMonitorCanvasNo
                      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nCurrMonitorCanvasNo=" + \nCurrMonitorCanvasNo + ", " + getGadgetName(\nCurrMonitorCanvasNo))
                      grVidPicTarget(nVidPicTarget)\bImageOnMonitor = #True
                    EndIf
                  EndIf ; EndIf IsGadget(nMonitorCanvasNo)
                EndIf ; EndIf bSubStartedInEditor = #False
              EndIf ; Endif IsImage = 0
              
            Case #SCS_FILEFORMAT_VIDEO
              If nVidPicTarget = pPrimaryVidPicTarget
                showFrame(pAudPtr, nVidPicTarget)
              EndIf
              
            Case #SCS_FILEFORMAT_CAPTURE
              showFrame(pAudPtr, nVidPicTarget)
          EndSelect
          
        EndIf ; EndIf nBlendTime > 0 / Else
        
        Select nVidPicTarget
          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            debugMsg(sProcName, "calling makeVidPicVisible(" + decodeVidPicTarget(nVidPicTarget) + ", #True, " + getAudLabel(pAudPtr) + ")")
            makeVidPicVisible(nVidPicTarget, #True, pAudPtr)
        EndSelect
        
      EndWith ; EndWith grVidPicTarget(nVidPicTarget)
      
    EndIf ; EndIf bDisplayOnThisVidPicTarget
  Next nVidPicTarget
  
  If bCreateOrResumeBlenderThread
    THR_createOrResumeAThread(#SCS_THREAD_BLENDER)
  EndIf
  
  UnlockImageMutex()
  
  ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setCurrMonitorCanvasNo(pVidPicTarget)
  PROCNAMEC()
  Protected nScreenNo, nCanvasNo
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    ; test on \nMonitorSize added 30May2019 11.8.1.1ab following a test where this was 'none' and the screen was 3, and this threw a subscript error on WMO(nScreenNo)
    If grOperModeOptions(gnOperMode)\nMonitorSize = #SCS_MON_NONE
      \nCurrMonitorCanvasNo = 0
    Else
      nScreenNo = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
      debugMsg(sProcName, "nScreenNo=" + nScreenNo)
      If nScreenNo >= 0
        nCanvasNo = WMO(nScreenNo)\aMonitor(0)\cvsMonitorCanvas
        If IsGadget(nCanvasNo)
          \nCurrMonitorCanvasNo = nCanvasNo
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nCurrMonitorCanvasNo=" + \nCurrMonitorCanvasNo + ", " + getGadgetName(\nCurrMonitorCanvasNo))
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure beginFadeInLogo(pVidPicTarget)
  PROCNAMEC()
  Protected qWaitUntil.q
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
    If (\nLogoFadeInTime > 0) And (\bLogoCurrentlyDisplayed = #False)
      If IsImage(\nLogoImageNo)
        \bInFadeStartProcess = #True
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
        If \bInBlendThreadProcess
          qWaitUntil = ElapsedMilliseconds() + 200
          Delay(2)
          While (\bInBlendThreadProcess) And ((qWaitUntil - ElapsedMilliseconds()) > 0)
            Delay(2)
          Wend
        EndIf
        
        \nAudPtr2 = \nAudPtr1
        \nImage2 = \nImage1
        \nAudPtr1 = 0
        If IsImage(\nLogoImageNo)
          \nImage1 = \nLogoImageNo
        Else
          \nImage1 = \nBlackImageNo
        EndIf
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nImage1=" + decodeHandle(\nImage1) + ", \nImage2=" + decodeHandle(\nImage2))
        \nBlendTime = \nLogoFadeInTime
        \qBlendStartTime = ElapsedMilliseconds()
        \bBlendingLogo = #True
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\qBlendStartTime=" + traceTime(\qBlendStartTime) +
                            ", \nBlendTime=" + \nBlendTime + ", \bBlendingLogo=" + strB(\bBlendingLogo))
        debugMsg(sProcName, "\nCurrMonitorCanvasNo=" + \nCurrMonitorCanvasNo + ", " + getGadgetName(\nCurrMonitorCanvasNo))
        setCurrMonitorCanvasNo(pVidPicTarget)
        \bInFadeStartProcess = #False
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
        THR_createOrResumeAThread(#SCS_THREAD_BLENDER)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure makeVidPicVisible(pVidPicTarget, bMakeImageVisible, pAudPtr)
  PROCNAMEC()
  Protected n
  Protected nVideoPlaybackLibrary
  Protected nVideoCanvasNo
  Protected bOKtoProcess
  Protected nSubPtr, bUse2DDrawing
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_MAKE_VID_PIC_VISIBLE, pVidPicTarget, 0, bMakeImageVisible, "", 0, pAudPtr)
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", bMakeImageVisible=" + strB(bMakeImageVisible) + ", pAudPtr=" + getAudLabel(pAudPtr))
  
  If pAudPtr >= 0
    nSubPtr = aAud(pAudPtr)\nSubIndex
    bUse2DDrawing = checkUse2DDrawing(nSubPtr)
  EndIf

  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      n = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
      ; If pAudPtr >= 0 ; Commented out 1Dec2021 11.8.6cn because that test prevented an image being displayed on multiple targets, because the 2nd and subsequent canvases were made not visible later in this procedure
      ;   nVideoCanvasNo = aAud(pAudPtr)\nAudVideoCanvasNo
      ; Else
      nVideoCanvasNo = grVidPicTarget(pVidPicTarget)\nTargetCanvasNo
      ; EndIf
      With WVN(n)
        nVideoPlaybackLibrary = grVidPicTarget(pVidPicTarget)\nCurrVideoPlaybackLibrary
        Select nVideoPlaybackLibrary
          Case #SCS_VPL_NOT_SET, #SCS_VPL_IMAGE
            nVideoPlaybackLibrary = grVideoDriver\nVideoPlaybackLibrary
        EndSelect
        Select nVideoPlaybackLibrary
          Case #SCS_VPL_TVG
            If bUse2DDrawing
              bOKtoProcess = #True
            Else
              bOKtoProcess = #False
            EndIf
        EndSelect
        If bOKtoProcess
          If getVisible(\cntMainPicture) = #False
            setVisible(\cntMainPicture, #True)
          EndIf
          If IsGadget(nVideoCanvasNo)
            setVideoCanvasVisible(pVidPicTarget, nVideoCanvasNo, bMakeImageVisible)
          EndIf
        EndIf
      EndWith
      
    Case #SCS_VID_PIC_TARGET_P
      Select grVideoDriver\nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
          CompilerIf #c_vMix_in_video_cues
            vMix_DrawPreviewText(WQA\cvsPreview, pAudPtr)
          CompilerEndIf
        Default
          If aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO Or aAud(pAudPtr)\nVideoSource = #SCS_VID_SRC_CAPTURE
            ; blackout any previous image
            If StartDrawing(CanvasOutput(WQA\cvsPreview))
              debugMsgD(sProcName, "StartDrawing(CanvasOutput(WQA\cvsPreview))")
              Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
              debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
              StopDrawing()
              debugMsgD(sProcName, "StopDrawing()")
            EndIf
          EndIf
          setVisible(WQA\cvsPreview, #True)
      EndSelect
      
  EndSelect
  
  If gbVideosOnMainWindow = #False
    With grVidPicTarget(pVidPicTarget)
      If IsWindow(\nMainWindowNo)
        If getWindowVisible(\nMainWindowNo) = #False
          setWindowVisible(\nMainWindowNo, #True)
          checkMainHasFocus(9)
        EndIf
      EndIf
    EndWith  
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure clearPicture(pVidPicTarget, bUseBlankImage=#False, sTextForBlank.s="", nFrontColor=0, bClearPreview=#False)
  PROCNAMEC()
  Protected nImageNo
  Protected nCanvasNo
  Protected bFadeInImage
  Protected bIsLogo
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed) + ", \nBlankImageNo=" +decodeHandle(\nBlankImageNo) + ", \nLogoImageNo=" + decodeHandle(\nLogoImageNo))
    If \bLogoCurrentlyDisplayed
      debugMsg(sProcName, "exiting because \bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
      ProcedureReturn
    EndIf
    If bUseBlankImage
      nImageNo = \nBlankImageNo
    ElseIf IsImage(\nLogoImageNo)
      bIsLogo = #True
      nImageNo = \nLogoImageNo
      If \nLogoFadeInTime > 0
        bFadeInImage = #True
      EndIf
    Else
      nImageNo = \nBlackImageNo
    EndIf
    If (pVidPicTarget = #SCS_VID_PIC_TARGET_P) And (bClearPreview)
      nCanvasNo = WQA\cvsPreview
    Else
      nCanvasNo = \nTargetCanvasNo
    EndIf
    ; debugMsg(sProcName, "nCanvasNo=G" + nCanvasNo + ", " + getGadgetName(nCanvasNo) + ", bFadeInImage=" + strB(bFadeInImage))
    
    If IsGadget(nCanvasNo)  ; nb may be false if this VidPicTarget hasn't been used before
      If bFadeInImage
        debugMsg(sProcName, "calling beginFadeInLogo(" + decodeVidPicTarget(pVidPicTarget) + ")")
        beginFadeInLogo(pVidPicTarget)
        
      ElseIf StartDrawing(CanvasOutput(nCanvasNo))
        debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
        DrawingMode(#PB_2DDrawing_Default)
        debugMsgD(sProcName, "DrawingMode(#PB_2DDrawing_Default)")
        DrawImage(ImageID(nImageNo), 0, 0, OutputWidth(), OutputHeight())
        debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nImageNo) + "), 0, 0, " + OutputWidth() + ", " + OutputHeight() + ")")
        If sTextForBlank
          DrawingMode(#PB_2DDrawing_Transparent)
          debugMsgD(sProcName, "DrawingMode(#PB_2DDrawing_Transparent)")
          WrapTextLeft(8, 8, sTextForBlank, OutputWidth()-8, nFrontColor, #SCS_Black)
          debugMsgD(sProcName, "WrapTextLeft(8, 8, '" + sTextForBlank + "', " + Str(OutputWidth()-8) + ", nFrontColor, #SCS_Black)")
        EndIf
        StopDrawing()
        debugMsgD(sProcName, "StopDrawing()")
        
      EndIf
      If bIsLogo
        debugMsg(sProcName, "calling setVisible(" + getGadgetName(nCanvasNo) + ", #True)")
        setVisible(nCanvasNo, #True)
      EndIf
    EndIf
    
    \nAudPtr1 = -1
    \nImage1 = nImageNo
   
    debugMsgD(sProcName, "bIsLogo=" + strB(bIsLogo) + ", IsWindow(" + decodeWindow(\nMainWindowNo) + ")=" + IsWindow(\nMainWindowNo) + ", getVisible(\nMainWindowNo)=" + strB(getVisible(\nMainWindowNo)))
    If bIsLogo
      If IsWindow(\nMainWindowNo)
        If getVisible(\nMainWindowNo) = #False
          debugMsg(sProcName, "calling setWindowVisible(" + decodeWindow(\nMainWindowNo) + ", #True)")
          setWindowVisible(\nMainWindowNo, #True)
        EndIf
      EndIf
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure displayBlack(pVidPicTarget, bClearPreview=#False)
  PROCNAMEC()
  Protected nCanvasNo
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    If (pVidPicTarget = #SCS_VID_PIC_TARGET_P) And (bClearPreview)
      nCanvasNo = WQA\cvsPreview
    Else
      nCanvasNo = \nTargetCanvasNo
    EndIf
    debugMsg(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
    If StartDrawing(CanvasOutput(nCanvasNo))
      debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
      debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
      StopDrawing()
      debugMsgD(sProcName, "StopDrawing()")
    EndIf
    \nImage1 = \nBlackImageNo ; Added 4May2022 11.9.1
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nAudPtr1=" + getAudLabel(\nAudPtr1) + ", \nImage1=" + decodeHandle(\nImage1))
  EndWith
  
EndProcedure

Procedure clearVideoImage(pVidPicTarget)
  PROCNAMEC()
  Protected nCanvasNo
  
  ; debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nCanvasNo = \nVideoCanvasNo
        
      Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
        nCanvasNo = WQA\cvsPreview
        If getVisible(nCanvasNo)
          setVisible(nCanvasNo, #False)
          debugMsgV(sProcName, "setVisible(" + getGadgetName(nCanvasNo) + ", #False)")
        EndIf
        
    EndSelect
    
    If IsGadget(nCanvasNo)
      If StartDrawing(CanvasOutput(nCanvasNo))
        debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
        Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
        debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
        StopDrawing()
        debugMsgD(sProcName, "StopDrawing()")
      EndIf
    EndIf
    
    \nImage1 = \nBlackImageNo ; Added 4May2022 11.9.1
    ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nAudPtr1=" + getAudLabel(\nAudPtr1) + ", \nImage1=" + decodeHandle(\nImage1))
  EndWith
  
EndProcedure

Procedure beginFadeOutPrimary(pAudPtr, pPrimaryVidPicTarget, nBlendTime)
  PROCNAMECA(pAudPtr)
  Protected nHoldPrimaryAudPtr
  Protected qWaitUntil.q
  Protected nSubPtr, nVidPicTarget, nMaxVidPicTarget, bCreateOrResumeBlenderThread
  Protected Dim bOutputScreenReqd(#SCS_VID_PIC_TARGET_LAST)
  Protected nVidPicImage
  
  debugMsg(sProcName, #SCS_START + ", pPrimaryVidPicTarget=" + decodeVidPicTarget(pPrimaryVidPicTarget) + ", nBlendTime=" + nBlendTime)
  
  With grVidPicTarget(pPrimaryVidPicTarget)
    \bInFadeStartProcess = #True
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pPrimaryVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
    If \bInBlendThreadProcess
      qWaitUntil = ElapsedMilliseconds() + 200
      Delay(2)
      While (\bInBlendThreadProcess) And ((qWaitUntil - ElapsedMilliseconds()) > 0)
        Delay(2)
      Wend
    EndIf
  EndWith
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  nMaxVidPicTarget = aSub(nSubPtr)\nSubMaxOutputScreen
  Select pPrimaryVidPicTarget
    Case #SCS_VID_PIC_TARGET_P
      bOutputScreenReqd(#SCS_VID_PIC_TARGET_P) = #True
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To nMaxVidPicTarget
        bOutputScreenReqd(nVidPicTarget) = aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
      Next nVidPicTarget
  EndSelect
  
  For nVidPicTarget = #SCS_VID_PIC_TARGET_P To nMaxVidPicTarget
    If bOutputScreenReqd(nVidPicTarget)
      With grVidPicTarget(nVidPicTarget)
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nAudPtr1=" + getAudLabel(\nAudPtr1) + ", \nImage1=" + decodeHandle(\nImage1) + ", \nAudPtr2=" + getAudLabel(\nAudPtr2) + ", \nImage2=" + decodeHandle(\nImage2))
        debugMsg(sProcName, "\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
        nHoldPrimaryAudPtr = \nPrimaryAudPtr
        ; If pAudPtr = \nPrimaryAudPtr
        If pAudPtr = \nAudPtr1
          ; new image will be black image or logo image
          \nAudPtr2 = \nAudPtr1
          \nAudPtr1 = 0
          \nImage2 = \nImage1
          If IsImage(\nLogoImageNo)
            \nImage1 = \nLogoImageNo
          Else
            \nImage1 = \nBlackImageNo
          EndIf
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nImage1=" + decodeHandle(\nImage1) + ", \nImage2=" + decodeHandle(\nImage2))
          \nPrevBlendFactor = 0
          \nBlendTime = nBlendTime
          \nPrevPrimaryAudPtr = nHoldPrimaryAudPtr
          \nPrimaryAudPtr = -1
          ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
          \nPrimaryFileFormat = #SCS_FILEFORMAT_UNKNOWN
          \sPrimaryFileName = ""
          ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\sPrimaryFileName=" + GetFilePart(\sPrimaryFileName))
          If IsImage(\nLogoImageNo)
            \nPrimaryImageNo = \nLogoImageNo
          Else
            \nPrimaryImageNo = \nBlackImageNo
          EndIf
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryImageNo=" + decodeHandle(\nPrimaryImageNo) + ", ImageWidth()=" + ImageWidth(\nPrimaryImageNo) + ", ImageHeight()=" + ImageHeight(\nPrimaryImageNo))
          
          If \nPrevPrimaryAudPtr >= 0
            aAud(\nPrevPrimaryAudPtr)\bBlending = #True
            debugMsg(sProcName, "aAud(" + getAudLabel(\nPrevPrimaryAudPtr) + ")\bBlending=" + strB(aAud(\nPrevPrimaryAudPtr)))
          EndIf
          
          \qBlendStartTime = ElapsedMilliseconds()
          \bBlendingLogo = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\qBlendStartTime=" + traceTime(\qBlendStartTime) + ", \nBlendTime=" + \nBlendTime + ", \bBlendingLogo=" + strB(\bBlendingLogo))
          CompilerIf #c_include_tvg
            If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
              If (aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO) Or (checkUse2DDrawing(nSubPtr) = #False)
                debugMsg(sProcName, "calling addAudToTVGFadeAudArray(" + getAudLabel(pAudPtr) + ")")
                addAudToTVGFadeAudArray(pAudPtr)
              EndIf
            EndIf
          CompilerEndIf
          \bInFadeStartProcess = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
          bCreateOrResumeBlenderThread = #True
          
        Else
          \bInFadeStartProcess = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess))
          
        EndIf
      EndWith
    EndIf
  Next nVidPicTarget
  
  If bCreateOrResumeBlenderThread
    THR_createOrResumeAThread(#SCS_THREAD_BLENDER)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure displayPicture(pAudPtr, pVidPicTarget, bIgnoreFadein=#False)
  PROCNAMECA(pAudPtr)
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", bIgnoreFadein=" + strB(bIgnoreFadein))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    ; debugMsg3(sProcName, "transfer request to main thread")
    ; in the following call, set pCuePtrForRequestTime to prevent the control thread checking this cue until the SAM process has been actioned
    samAddRequest(#SCS_SAM_DISPLAY_PICTURE, pAudPtr, 0.0, pVidPicTarget, "", 0, bIgnoreFadein, aAud(pAudPtr)\nCueIndex)
    ProcedureReturn #True
  EndIf
  
  debugMsg(sProcName, "\nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState))
  If aAud(pAudPtr)\nAudState = #SCS_CUE_ERROR
    ProcedureReturn #False
  EndIf
  
  With aAud(pAudPtr)
    debugMsg(sProcName, "\nCurrFadeInTime=" + \nCurrFadeInTime + ", \bReloadMainImage=" + strB(\bReloadMainImage) + ", \nMaxScreenInfo=" + \nMaxScreenInfo)
    \bBlending = #False
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bBlending=" + strB(aAud(pAudPtr)))
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        If \bReloadMainImage
          ; If loadAndFitAPicture(pAudPtr, pVidPicTarget)
          If loadAndFitPictureForAud(pAudPtr)
            \bReloadMainImage = #False
          EndIf
        EndIf
        \nAudVidPicTarget = pVidPicTarget
        If (\nCurrFadeInTime <= 0) Or (bIgnoreFadein)
;           debugMsg(sProcName, "calling moveAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
;           moveAudPictureToPrimary(pAudPtr, pVidPicTarget)
;           ; debugMsg3(sProcName, "moveAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
          debugMsg(sProcName, "calling beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", 0)")
          beginFadeAudPictureToPrimary(pAudPtr, pVidPicTarget, 0)
          ; debugMsg3(sProcName, "beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", 0)")
        Else
          debugMsg(sProcName, "calling beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + \nCurrFadeInTime + ")")
          beginFadeAudPictureToPrimary(pAudPtr, pVidPicTarget, \nCurrFadeInTime)
          ; debugMsg3(sProcName, "beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + \nCurrFadeInTime + ")")
        EndIf
        
      Case #SCS_VID_PIC_TARGET_P
        If (\nCurrFadeInTime <= 0) Or (gbInDisplaySub) Or (bIgnoreFadein)
;           debugMsg(sProcName, "calling moveAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
;           moveAudPictureToPrimary(pAudPtr, pVidPicTarget)
;           ; debugMsg3(sProcName, "moveAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
          debugMsg(sProcName, "calling beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", 0)")
          beginFadeAudPictureToPrimary(pAudPtr, pVidPicTarget, 0)
          ; debugMsg3(sProcName, "beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", 0)")
        Else
          debugMsg(sProcName, "calling beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + \nCurrFadeInTime + ")")
          beginFadeAudPictureToPrimary(pAudPtr, pVidPicTarget, \nCurrFadeInTime)
          ; debugMsg3(sProcName, "beginFadeAudPictureToPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + \nCurrFadeInTime + ")")
        EndIf
        
      Default
        debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
        
    EndSelect
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure stopInactiveVideoImageSubs(nExcludeSubPtr, nCurrFadeInTime)
  ; Procedure added 5Feb2020 11.8.2.2ah
  ; Added nCurrFadeInTime 27Aug2021 11.8.6 following test of U3A "A Twist on Christmas VFX.scs11"
  PROCNAMEC()
  Protected nVidPicTarget, nPrimaryAudPtr, nPrimarySubPtr, nCurrentSubPtr
  Protected i, j, k, nScreen
  Protected bStopThisSub, bForceStopThisSub
  
debugMsg(sProcName, #SCS_START + ", nExcludeSubPtr=" + getSubLabel(nExcludeSubPtr) + ", nCurrFadeInTime=" + nCurrFadeInTime)
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeA
      If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          With aSub(j)
            If j <> nExcludeSubPtr
              If \bSubTypeA
                If (\nSubState >= #SCS_CUE_FADING_IN) And (\nSubState <= #SCS_CUE_FADING_OUT)
                  bStopThisSub = #True
                  If \bStartedInEditor
                    nCurrentSubPtr = grVidPicTarget(#SCS_VID_PIC_TARGET_P)\nCurrentSubPtr
                    If nCurrentSubPtr = j
                      bStopThisSub = #False
                    EndIf
                  Else
                    bForceStopThisSub = #False
                    If nExcludeSubPtr >= 0
                      For nScreen = 2 To ArraySize(aSub(j)\bOutputScreenReqd())
                        If \bOutputScreenReqd(nScreen) And aSub(nExcludeSubPtr)\bOutputScreenReqd(nScreen)
                          ; this output screen required by both the new sub and a currently-playing sub, so the currently playing sub must be stopped
                          bForceStopThisSub = #True
                          Break
                        EndIf
                      Next nScreen
                    EndIf
                    If bForceStopThisSub = #False
                      For nScreen = 2 To ArraySize(aSub(j)\bOutputScreenReqd())
                        If \bOutputScreenReqd(nScreen)
                          For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
; debugMsg(sProcName, "j=" + getSubLabel(j) + ", nScreen=" + nScreen + ", grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nCurrentSubPtr=" + getSubLabel(grVidPicTarget(nVidPicTarget)\nCurrentSubPtr))
                            nCurrentSubPtr = grVidPicTarget(nVidPicTarget)\nCurrentSubPtr
                            If nCurrentSubPtr = j
                              debugMsg(sProcName, "do not stop sub " + getSubLabel(j) + " as it is currently showing on screen " + nScreen)
                              bStopThisSub = #False
                              Break 2 ; Break nVidPicTarget, nScreen
                            EndIf
                          Next nVidPicTarget
                        EndIf
                      Next nScreen
                    EndIf ; EndIf bForceStopThisSub = #False
                  EndIf ; EndIf \bStartedInEditor / Else
                  debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState) + ", bStopThisSub=" + strB(bStopThisSub))
                  If bStopThisSub
                    ; Added 14May2020 11.8.3rc4 to avoid brief black image between consecutive image displays.
                    ; See also similar code in playNextAud().
                    If aSub(j)\nPLCurrFadeOutTime <= 0
                      aSub(j)\nPLCurrFadeOutTime = 500
                    EndIf
                    ; End added 14May2020 11.8.3rc4
                    ; Added 27Aug2021 11.8.6 following test of U3A "A Twist on Christmas VFX.scs11"
                    If nCurrFadeInTime > aSub(j)\nPLCurrFadeOutTime
                      aSub(j)\nPLCurrFadeOutTime = nCurrFadeInTime + 100 ; add 0.1 second to ensure fade in completed before closing the currently playing sub
                    EndIf
                    ; End added 27Aug2021 11.8.6 following test of U3A "A Twist on Christmas VFX.scs11"
                    aSub(j)\bPLTerminating = #True ; Added 7Oct2020 11.8.3.2bj
                    debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bPLTerminating=" + strB(aSub(j)\bPLTerminating))
                    debugMsg(sProcName, "calling fadeOutOneSub(" + getSubLabel(j) + ", #True)")
                    fadeOutOneSub(j, #True)
                  EndIf ; EndIf bStopThisSub
                EndIf ; EndIf (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
              EndIf ; EndIf aSub(j)\bSubTypeA
            EndIf ; EndIf j <> nExcludeSubPtr
            j = \nNextSubIndex
          EndWith
        Wend
      EndIf ; EndIf (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
    EndIf ; EndIf aCue(i)\bSubTypeA
  Next i
  
debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeWhatWasPlayingOnVidPicTarget(pVidPicTarget, pPrevPrimaryAudPtr, pPrevPlayingSubPtr)
  PROCNAMEC()
  Protected bHideMemo, bHidePicture
  Protected bStopPrevSub
  Protected nPrevSubPtr, bPrevSubUse2DDrawing
  Protected nHoldPrimaryAudPtr
  Protected nHoldPlayingSubPtr
  Protected nPrevPrimaryAudPtr, nPrevPlayingSubPtr
  Protected nPrevCanvasNo, nCurrCanvasNo
  Protected nPrevDisplayLeft, nPrevDisplayTop, nPrevDisplayRight, nPrevDisplayBottom
  Protected nCurrDisplayLeft, nCurrDisplayTop, nCurrDisplayRight, nCurrDisplayBottom
  Protected bClearCanvas
  Protected nCurrImageNo, nCurrAudState
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + pVidPicTarget)
  
  nPrevPrimaryAudPtr = pPrevPrimaryAudPtr
  nPrevPlayingSubPtr = pPrevPlayingSubPtr
  If nPrevPrimaryAudPtr >= 0
    With aAud(nPrevPrimaryAudPtr)
      debugMsg(sProcName, "aAud(" + getAudLabel(nPrevPrimaryAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT) Or (\nAudState = #SCS_CUE_HIBERNATING)
        nPrevPrimaryAudPtr = -1
      EndIf
    EndWith
  EndIf
  If nPrevPlayingSubPtr >= 0
    With aSub(nPrevPlayingSubPtr)
      debugMsg(sProcName, "aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
      If (\nSubState < #SCS_CUE_FADING_IN) Or (\nSubState > #SCS_CUE_FADING_OUT) Or (\nSubState = #SCS_CUE_HIBERNATING)
        nPrevPlayingSubPtr = -1
      EndIf
    EndWith
  EndIf
  
  With grVidPicTarget(pVidPicTarget)
    
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) +
                        ", pPrevPrimaryAudPtr=" + getAudLabel(pPrevPrimaryAudPtr) + ", nPrevPrimaryAudPtr=" + getAudLabel(nPrevPrimaryAudPtr))
    
    nHoldPrimaryAudPtr = \nPrimaryAudPtr
    nHoldPlayingSubPtr = \nPlayingSubPtr
    
    debugMsg(sProcName, "nPrevPrimaryAudPtr=" + getAudLabel(nPrevPrimaryAudPtr) + ", nPrevPlayingSubPtr=" + getSubLabel(nPrevPlayingSubPtr))
    debugMsg(sProcName, "\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr))
    If nPrevPrimaryAudPtr >= 0
      If nPrevPrimaryAudPtr <> \nPrimaryAudPtr
        nPrevSubPtr = aAud(nPrevPrimaryAudPtr)\nSubIndex
        bPrevSubUse2DDrawing = checkUse2DDrawing(nPrevSubPtr)
        nPrevCanvasNo = aAud(nPrevPrimaryAudPtr)\nAudVideoCanvasNo(pVidPicTarget)
        nPrevDisplayLeft = aAud(nPrevPrimaryAudPtr)\nDisplayLeft(pVidPicTarget)
        nPrevDisplayTop = aAud(nPrevPrimaryAudPtr)\nDisplayTop(pVidPicTarget)
        nPrevDisplayRight = nPrevDisplayLeft + aAud(nPrevPrimaryAudPtr)\nDisplayWidth(pVidPicTarget)
        nPrevDisplayBottom = nPrevDisplayTop + aAud(nPrevPrimaryAudPtr)\nDisplayHeight(pVidPicTarget)
        If nPrevDisplayLeft < 0
          nPrevDisplayLeft = 0
        EndIf
        If nPrevDisplayTop < 0
          nPrevDisplayTop = 0
        EndIf
        If nPrevDisplayRight > \nTargetWidth
          nPrevDisplayRight = \nTargetWidth
        EndIf
        If nPrevDisplayBottom > \nTargetHeight
          nPrevDisplayBottom = \nTargetHeight
        EndIf
        If \nPrimaryAudPtr >= 0
          nCurrCanvasNo = aAud(\nPrimaryAudPtr)\nAudVideoCanvasNo(pVidPicTarget)
          nCurrDisplayLeft = aAud(\nPrimaryAudPtr)\nDisplayLeft(pVidPicTarget)
          nCurrDisplayTop = aAud(\nPrimaryAudPtr)\nDisplayTop(pVidPicTarget)
          nCurrDisplayRight = nCurrDisplayLeft + aAud(\nPrimaryAudPtr)\nDisplayWidth(pVidPicTarget)
          nCurrDisplayBottom = nCurrDisplayTop + aAud(\nPrimaryAudPtr)\nDisplayHeight(pVidPicTarget)
          If nCurrDisplayLeft < 0
            nCurrDisplayLeft = 0
          EndIf
          If nCurrDisplayTop < 0
            nCurrDisplayTop = 0
          EndIf
          If nCurrDisplayRight > \nTargetWidth
            nCurrDisplayRight = \nTargetWidth
          EndIf
          If nCurrDisplayBottom > \nTargetHeight
            nCurrDisplayBottom = \nTargetHeight
          EndIf
          If nCurrDisplayLeft > nPrevDisplayLeft
            bClearCanvas = #True
          ElseIf nCurrDisplayTop > nPrevDisplayTop
            bClearCanvas = #True
          ElseIf nCurrDisplayRight < nPrevDisplayRight
            bClearCanvas = #True
          ElseIf nCurrDisplayBottom < nPrevDisplayBottom
            bClearCanvas = #True
          EndIf
          If aAud(\nPrimaryAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE
            nCurrImageNo = aAud(\nPrimaryAudPtr)\nVidPicTargetImageNo(pVidPicTarget)
            nCurrAudState = aAud(\nPrimaryAudPtr)\nAudState
          EndIf
          If aAud(\nPrimaryAudPtr)\nSubIndex <> nPrevSubPtr
            bStopPrevSub = #True
          EndIf
        Else
          bClearCanvas = #True
        EndIf
        If bStopPrevSub
          If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
            If (aAud(nPrevPrimaryAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (bPrevSubUse2DDrawing)
              debugMsg(sProcName, "calling stopSub(" + getSubLabel(nPrevSubPtr) + ", 'ALL', #True, #False)")
              stopSub(nPrevSubPtr, "ALL", #True, #False)
            Else
              debugMsg(sProcName, "calling fadeOutOneSub(" + getSubLabel(nPrevSubPtr) + ")")
              fadeOutOneSub(nPrevSubPtr)
            EndIf
          Else
            debugMsg(sProcName, "calling stopSub(" + getSubLabel(nPrevSubPtr) + ", 'ALL', #True, #False)")
            stopSub(nPrevSubPtr, "ALL", #True, #False)
          EndIf
        Else
          debugMsg(sProcName, "calling closePrevPrimaryAudIfReqd(" + getAudLabel(nPrevPrimaryAudPtr) + ", " + getAudLabel(\nPrimaryAudPtr) + ")")
          closePrevPrimaryAudIfReqd(nPrevPrimaryAudPtr, \nPrimaryAudPtr)
        EndIf
        If (grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG) Or
           ((grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (aAud(nPrevPrimaryAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (bPrevSubUse2DDrawing))
          If IsGadget(nPrevCanvasNo)
            If nPrevCanvasNo <> nCurrCanvasNo
              setVisible(nPrevCanvasNo, #False)
              debugMsgV(sProcName, "setVisible(" + getGadgetName(nPrevCanvasNo) + ", #False)")
            EndIf
            If (bClearCanvas) And (nPrevCanvasNo <> nCurrCanvasNo)
              If StartDrawing(CanvasOutput(nPrevCanvasNo))
                debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nPrevCanvasNo) + "))")
                Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
                debugMsgD(sProcName, "Box(0,0," + OutputWidth() + "," + OutputHeight() + ",#SCS_Black)")
                If IsImage(nCurrImageNo)
                  If nCurrAudState = #SCS_CUE_PLAYING
                    DrawImage(ImageID(nCurrImageNo), 0, 0)
                    debugMsgD(sProcName, "DrawImage(ImageID(" + nCurrImageNo + "), 0, 0)")
                  EndIf
                EndIf
                StopDrawing()
                debugMsgD(sProcName, "StopDrawing()")
              EndIf
            EndIf
          EndIf
        EndIf
        If grVideoMonitors\bDisplayMonitorWindows
          debugMsg(sProcName, "calling hideMonitorsNotInUse()")
          hideMonitorsNotInUse()
        EndIf
      EndIf
      
    EndIf
    
    If nPrevPlayingSubPtr >= 0
      If nPrevPlayingSubPtr <> \nPlayingSubPtr
        If aSub(nPrevPlayingSubPtr)\bSubTypeE
          debugMsg(sProcName, "calling closePrevPlayingSubIfReqd(" + getSubLabel(nPrevPlayingSubPtr) + ", " + getSubLabel(\nPlayingSubPtr) + ")")
          If closePrevPlayingSubIfReqd(nPrevPlayingSubPtr, \nPlayingSubPtr)
            bHideMemo = #True
            If \nPlayingSubPtr >= 0
              If aSub(\nPlayingSubPtr)\bSubTypeE
                ; another memo is now being displayed so don't hide the memo rich text box
                bHideMemo = #False
              EndIf
            EndIf
            If bHideMemo
              debugMsg(sProcName, "calling WEN_hideMemoOnSecondaryScreen(" + decodeVidPicTarget(pVidPicTarget) + ")")
              WEN_hideMemoOnSecondaryScreen(pVidPicTarget)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
    \nPrimaryAudPtr = nHoldPrimaryAudPtr
    ; \nPlayingAudPtr = nHoldPlayingAudPtr
    \nPlayingSubPtr = nHoldPlayingSubPtr
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure fadeOutOrStopWhatWasPlayingOnVidPicTarget(pVidPicTarget)
  PROCNAMEC()
  Protected nPrimaryAudPtr, nPrevPrimaryAudPtr, nPrevPlayingSubPtr
  Protected nPrimarySubPtr, nPrevPrimarySubPtr
  Protected nFadeOutTime
  
  debugMsg(sProcName, #SCS_START)
  
  With grVidPicTarget(pVidPicTarget)
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
    nPrimaryAudPtr = \nPrimaryAudPtr
    nPrevPrimaryAudPtr = \nPrevPrimaryAudPtr
    nPrevPlayingSubPtr = \nPrevPlayingSubPtr
  EndWith

  If nPrevPrimaryAudPtr >= 0
    With aAud(nPrevPrimaryAudPtr)
      debugMsg(sProcName, "aAud(" + getAudLabel(nPrevPrimaryAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
      If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT) Or (\nAudState = #SCS_CUE_HIBERNATING)
        nPrevPrimaryAudPtr = -1
      EndIf
    EndWith
  EndIf
  If nPrevPlayingSubPtr >= 0
    With aSub(nPrevPlayingSubPtr)
      debugMsg(sProcName, "aSub(" + getSubLabel(nPrevPlayingSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
      If (\nSubState < #SCS_CUE_FADING_IN) Or (\nSubState > #SCS_CUE_FADING_OUT) Or (\nSubState = #SCS_CUE_HIBERNATING)
        nPrevPlayingSubPtr = -1
      EndIf
    EndWith
  EndIf
  debugMsg(sProcName, "nPrevPlayingSubPtr=" + getSubLabel(nPrevPlayingSubPtr) + ", nPrevPrimaryAudPtr=" + getAudLabel(nPrevPrimaryAudPtr))
  
  If (nPrimaryAudPtr >= 0) And (nPrevPrimaryAudPtr >= 0)
    nPrimarySubPtr = aAud(nPrimaryAudPtr)\nSubIndex
    nPrevPrimarySubPtr = aAud(nPrevPrimaryAudPtr)\nSubIndex
    If nPrimarySubPtr <> nPrevPrimarySubPtr
      If nPrevPrimarySubPtr >= 0
        aSub(nPrevPrimarySubPtr)\bPLTerminating = #True
        debugMsg(sProcName, "aSub(" + getSubLabel(nPrevPrimarySubPtr) + ")\bPLTerminating=#True")
      EndIf
    EndIf
  EndIf
  
  If nPrevPrimaryAudPtr >= 0
    With aAud(nPrevPrimaryAudPtr)
      ; If (\nNextPlayIndex = -1) And (aSub(\nSubIndex)\bPLRepeat = #False)
      If (\nNextPlayIndex = -1) And (getPLRepeatActive(\nSubIndex) = #False)
        nFadeOutTime = aSub(\nSubIndex)\nPLFadeOutTime
        If nFadeOutTime <= 0
          nFadeOutTime = 200 ; 200 ms
          \nCurrFadeOutTime = nFadeOutTime
          aSub(\nSubIndex)\nPLCurrFadeOutTime = nFadeOutTime
          \bInForcedFadeOut = #True
        EndIf
      Else
        nFadeOutTime = \nFadeOutTime
      EndIf
      debugMsg(sProcName, "nFadeOutTime=" + nFadeOutTime)
      If nFadeOutTime > 0
        ; If (\nNextPlayIndex = -1) And (aSub(\nSubIndex)\bPLRepeat = #False)
        If (\nNextPlayIndex = -1) And (getPLRepeatActive(\nSubIndex) = #False)
          aSub(\nSubIndex)\bPLTerminating = #True
          debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\bPLTerminating=" + strB(aSub(\nSubIndex)\bPLTerminating))
        EndIf
        debugMsg(sProcName, "calling fadeOutOneAud(" + getAudLabel(nPrevPrimaryAudPtr) + ")")
        fadeOutOneAud(nPrevPrimaryAudPtr)
      Else
        debugMsg(sProcName, "calling stopAud(" + getAudLabel(nPrevPrimaryAudPtr) + ", #False, #False, #True, #True)")
        stopAud(nPrevPrimaryAudPtr, #False, #False, #True, #True)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure isVideoPlaying(pVidPicTarget, pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bRunning, nChannelState.l
  Protected nIndex
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If pAudPtr < 0
    ProcedureReturn #False
  EndIf
  
  If aAud(pAudPtr)\nFileFormat <> #SCS_FILEFORMAT_VIDEO
    ProcedureReturn #True
  EndIf
  
  If pVidPicTarget >= 0
    Select aAud(pAudPtr)\nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          nIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
          If nIndex >= 0
            If *gmVideoGrabber(nIndex)
              nChannelState = TVG_GetPlayerState(*gmVideoGrabber(nIndex))
              debugMsgT(sProcName, "TVG_GetPlayerState(" + decodeHandle(*gmVideoGrabber(nIndex)) + ") returned " + decodeTVGPlayerState(nChannelState))
              If nChannelState >= #tvc_ps_Playing
                ; see explanation of property PlayerState in the TVG documentation
                bRunning = #True
              EndIf
            EndIf
          Else
            debugMsg(sProcName, "getTVGIndexForAud(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(aAud(pAudPtr)\nAudVidPicTarget) + " returned " + nIndex)
          EndIf
        CompilerEndIf
        
    EndSelect
  EndIf
  
  ProcedureReturn bRunning
  
EndProcedure

Procedure checkIfMovie(nMovieNo, pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bIsMovie
  
  If pAudPtr >= 0
    Select aAud(pAudPtr)\nVideoPlaybackLibrary
      Case #SCS_VPL_TVG, #SCS_VPL_VMIX
        If nMovieNo <> 0
          bIsMovie = #True
        EndIf
    EndSelect
  EndIf
  ProcedureReturn bIsMovie
EndProcedure

Procedure checkMovieStopped(nMovieNo, pAudPtr)
  PROCNAMEC()
  Protected bMovieStopped
  Protected nIndex, nPlayerState, sState.s
  Protected nHandle.i, sHandle.s
  
  ; debugMsg(sProcName, #SCS_START + ", nMovieNp=" + nMovieNo)
  
  If (pAudPtr < 0) Or (gbClosingDown)
    ProcedureReturn #True
  EndIf
  
  Select aAud(pAudPtr)\nVideoPlaybackLibrary
    Case #SCS_VPL_VMIX
      CompilerIf #c_vMix_in_video_cues
        sState = vMix_GetState(pAudPtr)
        ; debugMsg(sProcName, "vMix_GetState(" + getAudLabel(pAudPtr) + ") returned " + sState)
        If sState = "Paused"
          bMovieStopped = #True
        EndIf
      CompilerEndIf
      
    Case #SCS_VPL_TVG
      CompilerIf #c_include_tvg
        nIndex = getTVGIndexForAud(pAudPtr, aAud(pAudPtr)\nAudVidPicTarget)
        If nIndex >= 0
          nHandle = *gmVideoGrabber(nIndex)
          ; sHandle = decodeHandle(nHandle)
          If nHandle
            nPlayerState = TVG_GetPlayerState(nHandle)
            ; debugMsg(sProcName, "TVG_GetPlayerState(" + sHandle + ") returned " + decodeTVGPlayerState(nPlayerState))
            If nPlayerState = #tvc_ps_Stopped
              bMovieStopped = #True
;             ElseIf nPlayerState = #tvc_ps_Paused
;               ; Added 9Jun2020 11.8.3ac following report from Dee Ireland that a video file stopped immediately when the Audio Driver as ASIO4ALL.
;               ; This make no logical sense because what was happening was that in Dee's logs it showed that 
;               If TVG_GetPlayerTimePosition(nHandle) > (TVG_GetPlayerDuration(nHandle) - 5000000)
;                 ; Player is 'paused' and position is within 0.5 second of the end, so treat as stopped.
;                 debugMsg(sProcName, "TVG_GetPlayerTimePosition(" + sHandle + ")=" + TVG_GetPlayerTimePosition(nHandle) + ", TVG_GetPlayerDuration(" + sHandle + ")=" + TVG_GetPlayerDuration(nHandle))
;                 bMovieStopped = #True
;               EndIf
            EndIf
          Else
            bMovieStopped = #True
          EndIf
        Else
          debugMsg(sProcName, "getTVGIndexForAud(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(aAud(pAudPtr)\nAudVidPicTarget) + " returned " + nIndex + ", nMovieNo=" + nMovieNo)
          bMovieStopped = #True
        EndIf
      CompilerEndIf
    
  EndSelect
  
;   If bMovieStopped
;     debugMsg3(sProcName, "pAudPtr=" + getAudLabel(pAudPtr) + ", nMovieNo=" + decodeHandle(nMovieNo) + ", bMovieStopped=" + strB(bMovieStopped))
;   EndIf
  ProcedureReturn bMovieStopped
EndProcedure

Procedure checkMoviesToBeCleared()
  PROCNAMEC()
  Protected bMovieStillPlaying, bThisMovieStillPlaying
  Protected n
  Protected nGadgetNo
  Protected qTimeNow.q
  Static qTimeOfLastProcess.q
  
  qTimeNow = ElapsedMilliseconds()
  If (qTimeNow - qTimeOfLastProcess) > 100
    ; Only process once every 100ms (this test added 17Oct2024 11.10.6aq to reduce processing load)
    qTimeOfLastProcess = qTimeNow
    If gbMoviePlaying
      For n = #SCS_VID_PIC_TARGET_F2 To gnMaxVidPicTargetSetup
        bThisMovieStillPlaying = #False
        With grVidPicTarget(n)
          ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nMoviePlaying=" + \nMoviePlaying + ", \nMovieNo=" + \nMovieNo)
          If \nMoviePlaying
            If \nMoviePlaying = \nMovieNo
              If checkIfMovie(\nMovieNo, \nPrimaryAudPtr)
                ; debugMsg(sProcName, "calling checkMovieStopped(" + \nMovieNo + ", " + getAudLabel(\nPrimaryAudPtr) + ")")
                If checkMovieStopped(\nMovieNo, \nPrimaryAudPtr)
                  If \nPrimaryAudPtr >= 0
                    If aAud(\nPrimaryAudPtr)\bMediaStarted = #False
                      ; movie file hasn't got going yet so treat as still playing
                      bThisMovieStillPlaying = #True
                    EndIf
                  EndIf
                  If bThisMovieStillPlaying = #False
                    ; movie has stopped
                    nGadgetNo = \nTargetCanvasNo
                    If StartDrawing(CanvasOutput(nGadgetNo))
                      debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nGadgetNo) + "))")
                      Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
                      debugMsgD(sProcName, "Box(0,0," + OutputWidth() + "," + OutputHeight() + ",#SCS_Black)")
                      StopDrawing()
                      debugMsgD(sProcName, "StopDrawing()")
                    EndIf
                    debugMsg3(sProcName, "cleared " + decodeVidPicTarget(n) + ", \nMovieNo=" + \nMovieNo)
                    \nMoviePlaying = 0
                    \bVideoRunning = #False
                    If \nPrimaryAudPtr >= 0
                      aAud(\nPrimaryAudPtr)\bMediaEnded = #True
                      debugMsg(sProcName, "aAud(" + getAudLabel(\nPrimaryAudPtr) + ")\bMediaEnded=" + strB(aAud(\nPrimaryAudPtr)\bMediaEnded))
                    EndIf
                  EndIf
                Else
                  bMovieStillPlaying = #True
                EndIf
              EndIf
            EndIf
          EndIf
        EndWith
      Next n
      gbMoviePlaying = bMovieStillPlaying
    EndIf
  EndIf
  
EndProcedure

Procedure closePicture(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bLockedMutex
  Protected bForceRemoveInput ; used for vMixRemoveInput()
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    LockImageMutex(240)
    With aAud(pAudPtr)
      \nFileState = grAudDef\nFileState
      debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileState=" + decodeFileState(\nFileState))
      If \nAudState < #SCS_CUE_COMPLETED
        \nAudState = #SCS_CUE_NOT_LOADED
        setCueState(\nCueIndex)
      EndIf
      Select grVideoDriver\nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
        CompilerIf #c_vMix_in_video_cues
          If \svMixInputKey
            If gbStoppingEverything Or gbInGoToCue
              bForceRemoveInput = #True
            EndIf
            debugMsg(sProcName, "calling vMix_RemoveInput(" + getAudLabel(pAudPtr) + ", " + strB(bForceRemoveInput) + ")")
            vMix_RemoveInput(pAudPtr, bForceRemoveInput)
          EndIf
        CompilerEndIf

        Default
          freeAudImages(pAudPtr)
          
      EndSelect
      debugMsg(sProcName, \sAudLabel + ", \nFileState=" + decodeFileState(\nFileState) + ", \nAudState=" + decodeCueState(\nAudState))
    EndWith
    UnlockImageMutex()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setVidPicTargets(bForceSetWindowPositions=#False, bForceSetMonitorPositions=#False)
  PROCNAMEC()
  Protected n, n2, n3
  Protected v
  Protected nVideoWindowNo, nMonitorWindowNo
  Protected nOutputsOnFinalMonitor
  Protected nDragBarHeight, nCanvasWidth
  Protected nTotalWidthOfWindows
  Protected bSetWindowPositions, bSetMonitorPositions, bResetTVGDisplayLocations
  Protected nTextWidth, sCaption.s
  Protected nLeft, nTop
  Protected nDefaultLeft, nDefaultTop   ; only used for #WV2 (or first WVN)
  Protected bFirstWVN
  Protected m
  Protected nScreens
  Protected nVideoCanvasNo
  Protected nWindowNo
  Protected sMsg.s
  Protected nDisplayMonitor
  Protected nScaledX.l, nScaledY.l, nScaledWidth.l, nScaledHeight.l
  Static bInSetVidPicTargets
  Protected nvMixInitResult
  
  debugMsg(sProcName, #SCS_START + ", bForceSetWindowPositions=" + strB(bForceSetWindowPositions) + ", bForceSetMonitorPositions=" + strB(bForceSetMonitorPositions))
  
;   If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
;     gbCallSetVidPicTargets = #False
;     debugMsg(sProcName, "returning because grVideoDriver\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(grVideoDriver\nVideoPlaybackLibrary))
;     ProcedureReturn
;   EndIf
  
  If bInSetVidPicTargets
    debugMsg(sProcName, "returning because bInSetVidPicTargets=" + strB(bInSetVidPicTargets))
    ProcedureReturn
  EndIf
  bInSetVidPicTargets = #True
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  gbCallSetVidPicTargets = #False
  
  ; determine max nOutputScreen used in subs in the current cue file
  gnMaxVidPicTargetSetup = #SCS_VID_PIC_TARGET_NONE
  setMaxAndMinOutputScreen()
  If grVideoMonitors\nOutputScreenCount = 0
    ; no video/image or memo cues requiring screen output subcues found
    ; debugMsg(sProcName, "no video/image or relevant memo subcues found")
    bInSetVidPicTargets = #False
    ProcedureReturn
  EndIf
  
  nScreens = gnScreens
  If nScreens = 1 ; only 1 screen available so video/image outputs have to share the screen with the main SCS window (#WMN)
    gbVideosOnMainWindow = #True
  Else
    gbVideosOnMainWindow = #False
  EndIf
  setDisplayMonitorWindows()  ; sets grVideoMonitors\bDisplayMonitorWindows = #True if screen windows are required, else #False
  
  debugMsg(sProcName, "grVideoMonitors\nMaxOutputScreen=" + grVideoMonitors\nMaxOutputScreen + ", \nMaxMonitorWindow=" + grVideoMonitors\nMaxMonitorWindow +
                      ", gbVideosOnMainWindow=" + strB(gbVideosOnMainWindow))
  
  ; create video and screen windows
  ; debugMsg(sProcName, "ArraySize(WVN())=" + ArraySize(WVN()) + ", grVideoMonitors\nMaxOutputScreen=" + grVideoMonitors\nMaxOutputScreen)
  If ArraySize(WVN()) < (grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen - 2)
    If grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen >= 2
      ReDim WVN(grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen - 2)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "ArraySize(WMO())=" + ArraySize(WMO()) + ", grVideoMonitors\nMaxMonitorWindow=" + grVideoMonitors\nMaxMonitorWindow)
  If ArraySize(WMO()) < (grVideoMonitors\nMaxMonitorWindow - 2)
    If grVideoMonitors\nMaxMonitorWindow >= 2
      If grVideoMonitors\bDisplayMonitorWindows
        ReDim WMO(grVideoMonitors\nMaxMonitorWindow - 2)
      EndIf
    EndIf
  EndIf
  
  
  ; debugMsg(sProcName, "calling createVideoWindows()")
  If createVideoWindows()
    bSetWindowPositions = #True
  ElseIf bForceSetWindowPositions
    bSetWindowPositions = #True
  EndIf
  
  If grVideoMonitors\bDisplayMonitorWindows
    For n = 2 To grVideoMonitors\nMaxMonitorWindow
      n2 = n - 2
      nMonitorWindowNo = #WM2 + n2
      If IsWindow(nMonitorWindowNo) = #False
        WMO_Form_Load(nMonitorWindowNo)
        bSetMonitorPositions = #True
      ElseIf IsGadget(grVidPicTarget(n)\nTargetCanvasNo) = #False
        bSetMonitorPositions = #True
      EndIf
    Next n
  EndIf
  If bForceSetMonitorPositions
    bSetMonitorPositions = #True
  EndIf
  
  ; debugMsg(sProcName, "calling setDisplayMonitorWindows()")
  setDisplayMonitorWindows()
  
  With grVidPicTarget(#SCS_VID_PIC_TARGET_F2)
    nDefaultLeft = \nMainWindowX
    nDefaultTop = \nMainWindowY
  EndWith
  
  For n = 2 To grVideoMonitors\nMaxOutputScreen ; nMaxOutputScreen is max output screen from aSub()\sScreens and aSub()\nMemoScreen from current cue file
    With grVidPicTarget(n)
      debugMsg(sProcName, "F" + n + " \nMainWindowX=" + \nMainWindowX + ", \nMainWindowY=" + \nMainWindowY +
                          ", \nMainWindowWidth=" + \nMainWindowWidth + ", \nMainWindowHeight=" + \nMainWindowHeight +
                          ", \sVideoDevice=" + \sVideoDevice)
    EndWith
  Next n
  
  ; secondary screens
  For n = 2 To grVideoMonitors\nMaxOutputScreen ; nMaxOutputScreen is max output screen from aSub()\sScreens and aSub()\nMemoScreen from current cue file
    With grVidPicTarget(n)
      n2 = n - 2
      nVideoWindowNo = #WV2 + n2
      \nMainWindowNo = nVideoWindowNo
      nDragBarHeight = 0
      If gbVideosOnMainWindow
        nTotalWidthOfWindows + \nMainWindowWidth
        debugMsg(sProcName, "nTotalWidthOfWindows=" + nTotalWidthOfWindows)
        If IsGadget(WVN(n2)\cvsDragBar)
          nDragBarHeight = GadgetHeight(WVN(n2)\cvsDragBar)
        EndIf
      EndIf
      If grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX
        StartDrawing(CanvasOutput(WVN(n2)\aVideo(0)\cvsCanvas))
        debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(WVN(n2)\aVideo(0)\cvsCanvas) + "))")
        Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
        debugMsgD(sProcName, "Box(0,0," + OutputWidth() + "," + OutputHeight() + ",#SCS_Black)")
        StopDrawing()
        debugMsgD(sProcName, "StopDrawing()")
      EndIf
      ResizeImage(WVN(n2)\imgMainPicture, \nMainWindowWidth, \nMainWindowHeight)
      debugMsg(sProcName, "ResizeImage(" + decodeHandle(WVN(n2)\imgMainPicture) + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight + ")")
      ResizeImage(WVN(n2)\imgMainBlack, \nMainWindowWidth, \nMainWindowHeight)
      debugMsg(sProcName, "ResizeImage(" + decodeHandle(WVN(n2)\imgMainBlack) + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight + ")")
      WVN(n2)\rchMemoObject\Resize(0,0,\nMainWindowWidth,\nMainWindowHeight)
      If IsImage(WVN(n2)\imgMainBlended)
        ResizeImage(WVN(n2)\imgMainBlended, \nMainWindowWidth, \nMainWindowHeight)
        debugMsg(sProcName, "ResizeImage(" + decodeHandle(WVN(n2)\imgMainBlended) + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight + ")")
      Else
        debugMsg(sProcName, "IsImage(" + WVN(n2)\imgMainBlended + ") returned #False")
      EndIf
      If (gbVideosOnMainWindow) ; And (grOperModeOptions(gnOperMode)\nMonitorSize = #SCS_MON_NONE)
        If IsGadget(WVN(n2)\cvsDragBar)
          ResizeGadget(WVN(n2)\cvsDragBar,#PB_Ignore,#PB_Ignore,\nMainWindowWidth,#PB_Ignore)
        EndIf
      EndIf
      \nImage1 = WVN(n2)\imgMainBlack
      
      \nVideoCanvasNo = WVN(n2)\aVideo(0)\cvsCanvas
      \nTargetCanvasNo = \nVideoCanvasNo
      CompilerIf #cTraceGadgets
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nVideoCanvasNo=G" + \nVideoCanvasNo + ", " + getGadgetName(\nVideoCanvasNo) +
                            ", \nTargetCanvasNo=G" + \nTargetCanvasNo + ", " + getGadgetName(\nTargetCanvasNo))
      CompilerEndIf
      \nTargetImageNo = WVN(n2)\imgMainPicture
      \nTargetWidth = GadgetWidth(\nTargetCanvasNo)
      \nTargetHeight = GadgetHeight(\nTargetCanvasNo)
      \nBlackImageNo = WVN(n2)\imgMainBlack
      \nBlendedImageNo = WVN(n2)\imgMainBlended
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nTargetWidth=" + \nTargetWidth + ", \nTargetHeight=" + \nTargetHeight + ", \nBlendedImageNo=" + decodeHandle(\nBlendedImageNo) +
                          ", ImageWidth(" + decodeHandle(\nBlendedImageNo) + ")=" + ImageWidth(\nBlendedImageNo) + ", ImageHeight(" + decodeHandle(\nBlendedImageNo) + ")=" + ImageHeight(\nBlendedImageNo))
      
      If nDragBarHeight > 0
        If IsGadget(WVN(n2)\cvsDragBar)
          If StartDrawing(CanvasOutput(WVN(n2)\cvsDragBar))
            debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(WVN(n2)\cvsDragBar) + "))")
            ; scsDrawingFont(#SCS_FONT_WMN_NORMAL)
            scsDrawingFont(#SCS_FONT_GEN_NORMAL)
            sCaption = Str(n)
            nTextWidth = TextWidth(sCaption)
            nCanvasWidth = GadgetWidth(WVN(n2)\cvsDragBar)
            If nTextWidth < nCanvasWidth
              nLeft = (nCanvasWidth - nTextWidth) >> 1
            EndIf
            debugMsg(sProcName, "sCaption=" + sCaption + ", nCanvasWidth=" + nCanvasWidth + ", nTextWidth=" + nTextWidth + ", nLeft=" + nLeft)
            Box(0,0,nCanvasWidth,nDragBarHeight,$303030)
            debugMsgD(sProcName, "Box(0,0," + nCanvasWidth + "," + nDragBarHeight + ",$303030)")
            DrawText(nLeft,0,sCaption,#SCS_Yellow,$303030)
            debugMsgD(sProcName, "DrawText(" + nLeft + ",0," + #DQUOTE$ + sCaption + #DQUOTE$ + ",#SCS_Yellow,$303030)")
            StopDrawing()
            debugMsgD(sProcName, "StopDrawing()")
          EndIf
        EndIf
      EndIf
      
    EndWith
    
  Next n
  
  gnMaxVidPicTargetSetup = grVideoMonitors\nMaxOutputScreen ; nMaxOutputScreen is max output screen from aSub()\sScreens and aSub()\nMemoScreen from current cue file
  ; debugMsg(sProcName, "gnMaxVidPicTargetSetup=" + gnMaxVidPicTargetSetup)
  
  debugMsg(sProcName, "bSetWindowPositions=" + strB(bSetWindowPositions) + ", gbVideosOnMainWindow=" + strB(gbVideosOnMainWindow))
  If bSetWindowPositions
    If gbVideosOnMainWindow
      positionVideoMonitorsOrWindows(#False)
      bResetTVGDisplayLocations = #True
    EndIf
  EndIf
  
  If IsWindow(#WMN)
    ensureWindowNotBehindVideoScreen(#WMN)
  EndIf
  
  debugMsg(sProcName, "grVideoMonitors\bDisplayMonitorWindows=" + strB(grVideoMonitors\bDisplayMonitorWindows) + ", bSetMonitorPositions=" + strB(bSetMonitorPositions))
  If grVideoMonitors\bDisplayMonitorWindows
    If bSetMonitorPositions
      debugMsg(sProcName, "calling positionVideoMonitorsOrWindows(#True)")
      positionVideoMonitorsOrWindows(#True)
      bResetTVGDisplayLocations = #True
    EndIf
  EndIf
  
  If bResetTVGDisplayLocations
    Select grVideoDriver\nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        debugMsg(sProcName, "calling resetTVGDisplayLocations()")
        resetTVGDisplayLocations()
    EndSelect
  EndIf
  
  ; For n = grVideoMonitors\nMinOutputScreen To grVideoMonitors\nMaxOutputScreen ; nMaxOutputScreen is max output screen from aSub()\sScreens and aSub()\nMemoScreen from current cue file
  For n = 2 To grVideoMonitors\nMaxOutputScreen ; nMaxOutputScreen is max output screen from aSub()\sScreens and aSub()\nMemoScreen from current cue file
    n2 = n - 2
    nVideoWindowNo = #WV2 + n2
    If IsWindow(nVideoWindowNo)
      If IsGadget(WVN(n2)\cvsDragBar)
        ResizeGadget(WVN(n2)\cvsDragBar,#PB_Ignore,#PB_Ignore,WindowWidth(nVideoWindowNo),#PB_Ignore)
        If StartDrawing(CanvasOutput(WVN(n2)\cvsDragBar))
          debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(WVN(n2)\cvsDragBar) + "))")
          ; scsDrawingFont(#SCS_FONT_WMN_NORMAL)
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          sCaption = Str(n)
          nTextWidth = TextWidth(sCaption)
          nCanvasWidth = GadgetWidth(WVN(n2)\cvsDragBar)
          If nTextWidth < nCanvasWidth
            nLeft = (nCanvasWidth - nTextWidth) >> 1
          EndIf
          debugMsg(sProcName, "sCaption=" + sCaption + ", nCanvasWidth=" + nCanvasWidth + ", nTextWidth=" + nTextWidth + ", nLeft=" + nLeft)
          Box(0,0,nCanvasWidth,nDragBarHeight,$303030)
          debugMsgD(sProcName, "Box(0,0," + nCanvasWidth + "," + nDragBarHeight + ",$303030)")
          DrawText(nLeft,0,sCaption,#SCS_Yellow,$303030)
          debugMsgD(sProcName, "DrawText(" + nLeft + ",0," + #DQUOTE$ + sCaption + #DQUOTE$ + ",#SCS_Yellow,$303030)")
          StopDrawing()
          debugMsgD(sProcName, "StopDrawing()")
        EndIf
      EndIf
    EndIf
  Next n
  
  ; debugMsg(sProcName, "calling assignCanvases()")
  assignCanvases()
  
  bInSetVidPicTargets = #False
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure showImageCentre(pReqdWidth, pReqdHeight)
  ; Procedure added 22May2020 11.5.3rc5b for testing purposes only.
  ; Draws a vertical yellow cross over the image to show the vertical and horizontal centres of the image.
  ; Must be called between StartDrawing and StopDrawing.
  Protected nLineColor = #SCS_Yellow
  
  LineXY(pReqdWidth/2, 0, pReqdWidth/2, pReqdHeight-1, nLineColor)
  LineXY(0, pReqdHeight/2, pReqdWidth-1, pReqdHeight/2, nLineColor)
  If pReqdWidth & 1 = 0
    ; pReqdWidth is even, so draw a second line for each axis
    LineXY((pReqdWidth/2)+1, 0, (pReqdWidth/2)+1, pReqdHeight-1, nLineColor)
    LineXY(0, (pReqdHeight/2)+1, pReqdWidth-1, (pReqdHeight/2)+1, nLineColor)
  EndIf
  
EndProcedure

Procedure loadFrame2(pAudPtr, pPos, pUsePosImage=#False)
  PROCNAMECA(pAudPtr)
  Protected sCommand.s
  Protected nPos
  Protected hBitmap.l
  Protected bFrameLoaded
  Protected sFileExt.s
  Protected nFramePos
  Protected nPosLoadImageNo
  Protected nSourceMode
  Protected bUsePositionSetTime
  Protected nFrameChannel.l
  Protected dPos.d
  Protected dCurrPos.d
  Protected qWaitStartTime.q
  Protected dVolume.d
  Protected nX, nY, bAllWhite
  Protected nThumbnailImageNo, nFlippedThumbnail
  Protected nImageNo
  Protected nLeft
  Protected nPreviewWidth, nPreviewHeight
  Protected nTVGIndex
  Protected sFileName.s
  Protected qStartPos.q, qEndPos.q, qCurrPos.q
  Protected nLongResult
  Protected nReqdWidth, nReqdHeight, nReqdLeft, nReqdTop
  Protected nHandle.i, sHandle.s, sForcedCodec.s
  Protected lRotation.l
  Protected nOutputScreen, nOutputWidth, nOutputHeight, nVidPicTargetForOutputScreen
  
  debugMsg(sProcName, #SCS_START + ", pPos=" + pPos)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      
      nPreviewWidth = GadgetWidth(WQA\cntPreview)
      nPreviewHeight = GadgetHeight(WQA\cntPreview)
      
      If pPos = 0
        nFramePos = 250    ; 1/4 second
      Else
        nFramePos = pPos
      EndIf
      
      If pUsePosImage
        condFreeImage(\nPosLoadImageNo)
        \nPosLoadImageNo = 0
      Else
        condFreeImage(\nLoadImageNo)
        \nLoadImageNo = 0
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo=" + \nLoadImageNo)
      EndIf
      
      Select grVideoDriver\nVideoPlaybackLibrary
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            If IsGadget(WQA\cntForCaptureFrame) And IsGadget(WQA\cntPreview)
              ; Deleted 10Jul2020 11.8.3.2aj (see 'added...' below)
              ; debugMsg(sProcName, "calling calcDisplayPosAndSize3(" + getAudLabel(pAudPtr) + ", " + \nSourceWidth + ", " + \nSourceHeight +
              ;                     ", " + nPreviewWidth+ ", " + nPreviewHeight + ", 0, 0, #False, #True)")
              ; calcDisplayPosAndSize3(pAudPtr, \nSourceWidth, \nSourceHeight, nPreviewWidth, nPreviewHeight, 0, 0, #False, #True)
              ; End deleted 10Jul2020 11.8.3.2aj
              
              ResizeGadget(WQA\cntForCaptureFrame,#PB_Ignore, #PB_Ignore, \nSourceWidth, \nSourceHeight)
              nTVGIndex = assignTVGControl(\nSubIndex, pAudPtr, #SCS_VID_PIC_TARGET_FRAME_CAPTURE)
              If nTVGIndex >= 0
                nHandle = *gmVideoGrabber(nTVGIndex)
                sHandle = decodeHandle(*gmVideoGrabber(nTVGIndex))
                
                ; Added 10Jul2020 11.8.3.2aj (see 'deleted...' above)
                nOutputScreen = aSub(\nSubIndex)\nOutputScreen
                nVidPicTargetForOutputScreen = getVidPicTargetForOutputScreen(nOutputScreen)
                nOutputWidth = grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopWidth
                nOutputHeight = grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopHeight
                debugMsg(sProcName, "calling calcDisplayPosAndSize3(" + getAudLabel(pAudPtr) + ", " + \nSourceWidth + ", " + \nSourceHeight +
                                    ", " + nPreviewWidth + ", " + nPreviewHeight + ", " + nOutputWidth + ", " + nOutputHeight + ")")
                calcDisplayPosAndSize3(pAudPtr, \nSourceWidth, \nSourceHeight, nPreviewWidth, nPreviewHeight, nOutputWidth, nOutputHeight)
                ; End added 10Jul2020 11.8.3.2aj
                
                sFileName = \sFileName
                TVG_SetPlayerFileName(nHandle, @sFileName)
                debugMsgT(sProcName, "TVG_SetPlayerFileName(" + sHandle + ", " + GetFilePart(sFileName) + ")")
                
                ; disable player auto-start
                TVG_SetAutoStartPlayer(nHandle, #tvc_false)
                debugMsgT(sProcName, "TVG_SetAutoStartPlayer(" + sHandle + ", #tvc_false)")
                
                ; mute audio
                TVG_SetMuteAudioRendering(nHandle, #tvc_true)
                debugMsgT(sProcName, "TVG_SetMuteAudioRendering(" + sHandle + ", #tvc_true)")
                
                ; video renderer
                TVG_SetVideoRenderer(nHandle, #tvc_vr_AutoSelect)
                debugMsgT(sProcName, "TVG_SetVideoRenderer(" + sHandle + ", #tvc_vr_AutoSelect)")
                
                ; aspect ratio
                TVG_SetDisplayAspectRatio(nHandle, 0, #tvc_ar_Box)
                debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 0, #tvc_ar_Box)")
                TVG_SetAspectRatioToUse(nHandle, grDPS\dAspectRatioToUse)
                debugMsgT(sProcName, "TVG_SetAspectRatioToUse(" + sHandle + ", " + StrD(grDPS\dAspectRatioToUse,4) + ")")
                
                TVG_SetFrameGrabber(nHandle, #tvc_fg_BothStreams)
                debugMsgT(sProcName, "TVG_SetFrameGrabber(" + sHandle + ", #tvc_fg_BothStreams)")
                
                Select \nVideoRotation
                  Case 90
                    lRotation = #tvc_rt_90_deg
                  Case 180
                    lRotation = #tvc_rt_180_deg
                  Case 270
                    lRotation = #tvc_rt_270_deg
                  Default
                    lRotation = #tvc_rt_0_deg
                EndSelect
                ; setting the rotation MUST be done before opening the player
                TVG_SetVideoProcessingRotation(nHandle, lRotation)
                debugMsgT(sProcName, "TVG_SetVideoProcessingRotation(" + sHandle + ", " + lRotation + ")")
                
                Select \nFlip
                  Case #SCS_FLIPH
                    TVG_SetVideoProcessingFlipHorizontal(nHandle, #tvc_true)
                    debugMsgT(sProcName, "TVG_SetVideoProcessingFlipHorizontal(" + sHandle + ", #tvc_true)")
                  Case #SCS_FLIPV
                    TVG_SetVideoProcessingFlipVertical(nHandle, #tvc_true)
                    debugMsgT(sProcName, "TVG_SetVideoProcessingFlipVertical(" + sHandle + ", #tvc_true)")
                EndSelect
                
                debugMsg(sProcName, "calling setTVGCroppingData(" + getAudLabel(nEditAudPtr) + ", " + nTVGIndex + ", #True)")
                setTVGCroppingData(nEditAudPtr, nTVGIndex, #True)
                
                debugMsg(sProcName, "calling setTVGDisplayLocation(" + nTVGIndex + ")")
                setTVGDisplayLocation(nTVGIndex)
                
                qStartPos = nFramePos * 10000
                qEndPos = qStartPos + (250 * 10000)
                gaTVG(nTVGIndex)\bClosePlayerRequested = #False
                gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying = #False
                nLongResult = TVG_OpenPlayerAtTimePositions(nHandle, qStartPos, qEndPos, -1, 0)
                debugMsgT2(sProcName, "TVG_OpenPlayerAtTimePositions(" + sHandle + ", " + qStartPos + ", " + qEndPos + ", -1, 0)", nLongResult)
                
                TVG_RunPlayer(nHandle)
                debugMsgT(sProcName, "TVG_RunPlayer(" + sHandle + ")")
                
                qWaitStartTime = ElapsedMilliseconds()
                While #True
                  qCurrPos = TVG_GetPlayerTimePosition(nHandle)
                  If qCurrPos > qStartPos
                    debugMsgT(sProcName, "TVG_GetPlayerTimePosition(" + sHandle + ") returned " + qCurrPos)
                    Break
                  EndIf
                  If (ElapsedMilliseconds() - qWaitStartTime) > 1500
                    ; time out after 1.5 seconds
                    Break
                  EndIf
                  Delay(50)
                Wend
                
                TVG_PausePlayer(nHandle)
                debugMsgT(sProcName, "TVG_PausePlayer(" + sHandle + ")")
                
                ; Changed 20May2020 11.8.3rc5b
                ; nReqdWidth = grDPS\nDisplayWidth
                ; nReqdHeight = grDPS\nDisplayHeight
                nReqdWidth = \nSourceWidth
                nReqdHeight = \nSourceHeight
                ; End changed 20May2020 11.8.3rc5b
                
                hBitmap = TVG_GetLastFrameAsHBITMAP(nHandle,0,0,0,0,0,0,nReqdWidth,nReqdHeight,0)
                debugMsgT2(sProcName, "TVG_GetLastFrameAsHBITMAP(" + sHandle + ",0,0,0,0,0,0," + nReqdWidth + "," + nReqdHeight + ",0)", hBitmap)
                
                debugMsgT(sProcName, "calling freeTVGControl(" + sHandle + ", #True)")
                freeTVGControl(nTVGIndex, #True)
                
                If pUsePosImage
                  \nPosLoadImageNo = scsCreateImage(nReqdWidth, nReqdHeight)
                  ; debugMsg(sProcName, "(d2) \nPosLoadImageNo=" + \nPosLoadImageNo)
                  debugMsg3(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPosLoadImageNo=" + \nPosLoadImageNo)
                  logCreateImage(1043, \nPosLoadImageNo, pAudPtr, #SCS_VID_PIC_TARGET_NONE, "\nPosLoadImageNo")
                Else
                  \nLoadImageNo = scsCreateImage(nReqdWidth, nReqdHeight)
                  ; debugMsg(sProcName, "(d3) \nLoadImageNo=" + \nLoadImageNo)
                  debugMsg3(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo=" + \nLoadImageNo)
                  logCreateImage(1044, \nLoadImageNo, pAudPtr, #SCS_VID_PIC_TARGET_NONE, "\nLoadImageNo")
                EndIf
                
                If hBitmap
                  If pUsePosImage
                    If StartDrawing(ImageOutput(\nPosLoadImageNo))
                      debugMsgD(sProcName, "StartDrawing(ImageOutput(" + \nPosLoadImageNo + ")) [aAud(" + getAudLabel(pAudPtr) + ")\nPosLoadImageNo]")
                      DrawImage(hBitmap, 0, 0, nReqdWidth, nReqdHeight)
                      debugMsgD(sProcName, "DrawImage(" + hBitmap + ", 0, 0, " + nReqdWidth + ", " + nReqdHeight + ")")
                      StopDrawing()
                      debugMsgD(sProcName, "StopDrawing()")
                    EndIf
                  Else
                    If StartDrawing(ImageOutput(\nLoadImageNo))
                      debugMsgD(sProcName, "StartDrawing(ImageOutput(" + \nLoadImageNo + ")) [aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo]")
                      DrawImage(hBitmap, 0, 0, nReqdWidth, nReqdHeight)
                      debugMsgD(sProcName, "DrawImage(" + hBitmap + ", 0, 0, " + nReqdWidth + ", " + nReqdHeight + ")")
                      StopDrawing()
                      debugMsgD(sProcName, "StopDrawing()")
                    EndIf
                  EndIf
                  nLongResult = DeleteObject_(hBitmap)
                  debugMsg2(sProcName, "DeleteObject_(hBitmap)", nLongResult)
                  \bUsingShellThumbnail = #False
                  
                Else ; hBitmap = 0
                     ; cannot successfully load image using TVG_GetLastFrameAsHBITMAP() so call GetShellThmbnail() instead
                  debugMsg3(sProcName, "(TVG) calling GetShellThumbnail(" + GetFilePart(\sFileName) + ", #PB_Any, " + nReqdWidth + ", " + nReqdHeight + ")")
                  nThumbnailImageNo = GetShellThumbnail(\sFileName, #PB_Any, nReqdWidth, nReqdHeight)
                  debugMsg2(sProcName, "GetShellThumbnail(" + GetFilePart(\sFileName) + ", #PB_Any, " + nReqdWidth + ", " + nReqdHeight + ")", nThumbnailImageNo)
                  debugMsg(sProcName, "(TVG) IsImage(" + nThumbnailImageNo + ")=" + IsImage(nThumbnailImageNo))
                  If IsImage(nThumbnailImageNo)
                    nImageNo = scsCreateImage(nPreviewWidth, nPreviewHeight)
                    debugMsgV(sProcName, "scsCreateImage(" + nPreviewWidth + ", " + nPreviewHeight + ") returned " + nImageNo)
                    debugMsg(sProcName, "calling paintPictureAtPosAndSize(" + getAudLabel(nEditAudPtr) + ", " + decodeHandle(nImageNo) + ", " + decodeHandle(\nImageAfterRotateAndFlip) + ", #False)")
                    paintPictureAtPosAndSize(pAudPtr, nImageNo, nThumbnailImageNo, #False)
                    If IsImage(nImageNo)
                      If pUsePosImage
                        If StartDrawing(ImageOutput(\nPosLoadImageNo))
                          debugMsgD(sProcName, "StartDrawing(ImageOutput(" + \nPosLoadImageNo + ")) [aAud(" + getAudLabel(pAudPtr) + ")\nPosLoadImageNo]")
                          DrawImage(ImageID(nImageNo), 0, 0, nReqdWidth, nReqdHeight)
                          debugMsgD(sProcName, "DrawImage(ImageID(" + nImageNo + "), 0, 0, " + nReqdWidth + ", " + nReqdHeight + ")")
                          ; showImageCentre(nReqdWidth, nReqdHeight) ; Added 22May2020 11.5.3rc5b
                          StopDrawing()
                          debugMsgD(sProcName, "StopDrawing()")
                        EndIf
                      Else
                        If StartDrawing(ImageOutput(\nLoadImageNo))
                          debugMsgD(sProcName, "StartDrawing(ImageOutput(" + \nLoadImageNo + ")) [aAud(" + getAudLabel(pAudPtr) + ")\nLoadImageNo]")
                          DrawImage(ImageID(nImageNo), 0, 0, nReqdWidth, nReqdHeight)
                          debugMsgD(sProcName, "DrawImage(ImageID(" + nImageNo + "), 0, 0, " + nReqdWidth + ", " + nReqdHeight + ")")
                          ; showImageCentre(nReqdWidth, nReqdHeight) ; Added 22May2020 11.5.3rc5b
                          StopDrawing()
                          debugMsgD(sProcName, "StopDrawing()")
                        EndIf
                      EndIf
                      condFreeImage(nImageNo)
                      \bUsingShellThumbnail = #True
                    EndIf
                    condFreeImage(nThumbnailImageNo)
                  EndIf
                EndIf
              EndIf
            EndIf
          CompilerEndIf
          
      EndSelect
      
    EndWith
  EndIf ; EndIf pAudPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openVideoFile(pAudPtr, pVidPicTarget)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nMousePointer
  Protected nMovieNo
  
  debugMsg(sProcName, #SCS_START)
  
  nMousePointer = getMouseCursor()
  setMouseCursorBusy()
  
  If pVidPicTarget > gnMaxVidPicTargetSetup
    debugMsg(sProcName, "calling setVidPicTargets()")
    setVidPicTargets()
  EndIf
  
  With aAud(pAudPtr)
;     \sFileType = ""    ; will be populated later  ; commented out 5Feb2016 11.4.3 as this leaves \sFileType blank if the file cannot be opened (eg because TVG ran out of space)
    getFileDetail(pAudPtr)
    \sFileTitle = grFileInfo\sFileTitle
    debugMsg(sProcName, "\sFileTitle=" + \sFileTitle)
    
    \nVideoPlaybackLibrary = grVideoDriver\nVideoPlaybackLibrary
    ; debugMsg(sProcName, "\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary))
    
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      CompilerIf #c_vMix_in_video_cues
        nMovieNo = vMix_AddInput(pAudPtr)
        debugMsg(sProcName, "vMix_AddInput(" + #DQUOTE$ + \sFileName + #DQUOTE$ + ") returned " + nMovieNo)
        If nMovieNo = 0 Or nMovieNo = -2
          \nAudState = #SCS_CUE_ERROR
          \sErrorMsg = "vMix failed to add this input"
        ElseIf nMovieNo > 0
          \nAudVidPicTarget = pVidPicTarget
          debugMsg(sProcName, "calling setDerivedAudFields")
          setDerivedAudFields(pAudPtr)
          \nFileState = #SCS_FILESTATE_OPEN
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileState=" + decodeFileState(\nFileState))
          setPlaylistTrackReadyState(pAudPtr)
          \sDriver = "VID"
          Select pVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              \nMainVideoNo = nMovieNo
            Case #SCS_VID_PIC_TARGET_P
              \nPreviewVideoNo = nMovieNo
              \nMainVideoNo = nMovieNo ; nb for vMix set \nMainVideoNo for target P as well
              grVidPicTarget(pVidPicTarget)\nMovieNo = nMovieNo
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nMovieNo=" + decodeHandle(grVidPicTarget(pVidPicTarget)\nMovieNo))
              grVidPicTarget(pVidPicTarget)\sMovieFileName = \sFileName
              grVidPicTarget(pVidPicTarget)\nMovieAudPtr = pAudPtr
              grVidPicTarget(pVidPicTarget)\nCurrMoviePos = 0
          EndSelect
          \nPlayVideoNo = nMovieNo
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nMainVideoNo=" + decodeHandle(\nMainVideoNo) + ", \nPreviewVideoNo=" + decodeHandle(\nPreviewVideoNo))
          If getVideoInfo(\sFileName)
            \nSourceWidth = grVideoInfo\nSourceWidth
            \nSourceHeight = grVideoInfo\nSourceHeight
          EndIf
          vMix_SetXYPosAndSize(pAudPtr, #SCS_PS_ALL, #False, #True)
        EndIf
      CompilerEndIf
      
    ElseIf grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
      CompilerIf #c_include_tvg
        debugMsg(sProcName, "calling openVideoFileForTVG(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
        nMovieNo = openVideoFileForTVG(pAudPtr, pVidPicTarget)
        debugMsg(sProcName, "openVideoFileForTVG() returned " + nMovieNo)
        If nMovieNo = 0
          \nAudState = #SCS_CUE_ERROR
          \sErrorMsg = "TVG failed to open this file"
        Else
          \nFileDuration = grVideoInfo\nLength
          If \nFileFormat = #SCS_FILEFORMAT_PICTURE
            \sFileType = getPictureInfoForAud(pAudPtr)
          Else
            \sFileType = grVideoInfo\sInfo
          EndIf
          debugMsg(sProcName, "\nFileDuration=" + \nFileDuration + ", \sFileType=" + \sFileType)
          \nSourceWidth = grVideoInfo\nSourceWidth
          \nSourceHeight = grVideoInfo\nSourceHeight
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
          \nAudVidPicTarget = pVidPicTarget
          debugMsg(sProcName, "calling setDerivedAudFields")
          setDerivedAudFields(pAudPtr)
          \nFileState = #SCS_FILESTATE_OPEN
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileState=" + decodeFileState(\nFileState))
          setPlaylistTrackReadyState(pAudPtr)
          \sDriver = "VID"
          Select pVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              \nMainVideoNo = nMovieNo
            Case #SCS_VID_PIC_TARGET_P
              \nPreviewVideoNo = nMovieNo
          EndSelect
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nMainVideoNo=" + decodeHandle(\nMainVideoNo) + ", \nPreviewVideoNo=" + decodeHandle(\nPreviewVideoNo))
          getVideoInfo(\sFileName)
        EndIf
        
      CompilerEndIf
      
    EndIf
    
    \fCueVolNow[0] = \fBVLevel[0]
    \fCuePanNow[0] = \fPan[0]
    ; debugMsg(sProcName, "\fCueVolNow[0]=" + formatLevel(\fCueVolNow[0]))
    
    debugMsg(sProcName, "\sFileName=" + GetFilePart(\sFileName) + ", \nFileDuration=" + \nFileDuration + ", \nAudState=" + decodeCueState(\nAudState) + ", \sFileType=" + \sFileType)
    
    If grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
          \bPrimeVideoReqd = #True
          \nPrimeVideoVidPicTarget = pVidPicTarget
          gbCheckForPrimeVideoReqd = #True
          debugMsg(sProcName, "\bPrimeVideoReqd=" + strB(\bPrimeVideoReqd) + ", \nPrimeVideoVidPicTarget=" + decodeVidPicTarget(\nPrimeVideoVidPicTarget) +
                              ", gbCheckForPrimeVideoReqd=" + strB(gbCheckForPrimeVideoReqd))
      EndSelect
    EndIf
    
  EndWith
  
  If getMouseCursor() <> nMousePointer
    setMouseCursor(nMousePointer)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + nMovieNo)
  ProcedureReturn nMovieNo
  
EndProcedure

Procedure getVideoInfo(sFileName.s, bForceGet=#False, bTrace=#False)
  PROCNAMEC()
  Protected rVideoInfo.tyVideoInfo
  ; variables for MediaInfo.dll function calls
  Protected hResult.l
  Protected nHandle.i
  Protected *sInform
  Protected *sItem
  Protected sParameter.s
  Protected sInfo.s
  Protected sWidth.s, sHeight.s, sDuration.s, sFrameRate.s, sRotation.s, bImageFile
  Protected sDebugMsg.s
  ; end of variables for MediaInfo.dll function calls
  
  debugMsgC(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName) + ", bForceGet=" + strB(bForceGet))
  
  grVideoInfo = rVideoInfo  ; initialise grVideoInfo with default values
  
  If FileExists(sFileName, #False) = #False
    debugMsgC(sProcName, "File does not exist: " + sFileName)
    ProcedureReturn #False
  EndIf
  
  With grVideoInfo
    CompilerIf #c_include_tvg
      ; debugMsgC(sProcName, "using MediaInfo.dll to obtain length, width and height")
      nHandle = MediaInfo_New()
      debugMsgC2(sProcName, "MediaInfo_New()", nHandle)
      If nHandle
        hResult = MediaInfo_Open(nHandle, @sFileName)
        debugMsgC2(sProcName, "MediaInfo_Open(" + nHandle + ", @" + sFileName + ")", hResult)
        If hResult
          \sFileName = sFileName
          CompilerIf #cTraceMediaInfoInform
            ; this info not required for running the program, but could be useful in log files for sorting out issues
            *sInform = MediaInfo_Inform(nHandle, 1200)
            If *sInform
              sInfo = PeekS(*sInform)
              sDebugMsg + ", sInfo=" + sInfo
              ; debugMsgC(sProcName, "sInfo=" + sInfo)
            EndIf
          CompilerEndIf
          
          ; duration
          sParameter = "Duration" ; get length in milliseconds
          *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Video, 0, @sParameter, #MediaInfo_Info_Text, 0)
          If *sItem
            sDuration = PeekS(*sItem)
            If sDuration
              sDebugMsg + ", (video)sDuration=" + sDuration
              ; debugMsgC(sProcName, "(video) sDuration=" + sDuration)
            EndIf
            \nLength = Val(sDuration)
          EndIf
          If \nLength <= 0
            *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_General, 0, @sParameter, #MediaInfo_Info_Text, 0)
            If *sItem
              sDuration = PeekS(*sItem)
              If sDuration
                sDebugMsg + ", (general)sDuration=" + sDuration
                ; debugMsgC(sProcName, "(general) sDuration=" + sDuration)
              EndIf
              \nLength = Val(sDuration)
            EndIf
          EndIf
          If \nLength <= 0
            *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Audio, 0, @sParameter, #MediaInfo_Info_Text, 0)
            If *sItem
              sDuration = PeekS(*sItem)
              If sDuration
                sDebugMsg + ", (audio)sDuration=" + sDuration
                ; debugMsgC(sProcName, "(audio) sDuration=" + sDuration)
              EndIf
              \nLength = Val(sDuration)
            EndIf
          EndIf
          
          ; width
          sParameter = "Width"  ; get width in pixels
          *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Video, 0, @sParameter, #MediaInfo_Info_Text, 0)
          ; debugMsgC2(sProcName, "MediaInfo_Get(" + nHandle + ", #MediaInfo_Stream_Video, 0, @" + sParameter + ", #MediaInfo_Info_Text, 0)", *sItem)
          If *sItem
            sWidth = PeekS(*sItem)
            If sWidth
              sDebugMsg + ", (video)sWidth=" + sWidth
              debugMsgC(sProcName, "(video) sWidth=" + sWidth)
            EndIf
            \nSourceWidth = Val(sWidth)
          EndIf
          If \nSourceWidth <= 0
            *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Image, 0, @sParameter, #MediaInfo_Info_Text, 0)
            ; debugMsgC2(sProcName, "MediaInfo_Get(" + nHandle + ", #MediaInfo_Stream_Video, 0, @" + sParameter + ", #MediaInfo_Info_Text, 0)", *sItem)
            If *sItem
              sWidth = PeekS(*sItem)
              If sWidth
                sDebugMsg + ", (image)sWidth=" + sWidth
                debugMsgC(sProcName, "(image) sWidth=" + sWidth)
              EndIf
              \nSourceWidth = Val(sWidth)
              bImageFile = #True
            EndIf
          EndIf
          
          ; height
          sParameter = "Height" ; get height in pixels
          *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Video, 0, @sParameter, #MediaInfo_Info_Text, 0)
          ; debugMsgC2(sProcName, "MediaInfo_Get(" + nHandle + ", #MediaInfo_Stream_Video, 0, @" + sParameter + ", #MediaInfo_Info_Text, 0)", *sItem)
          If *sItem
            sHeight = PeekS(*sItem)
            If sHeight
              sDebugMsg + ", (video)sHeight=" + sHeight
              ; debugMsgC(sProcName, "(video) sHeight=" + sHeight)
            EndIf
            \nSourceHeight = Val(sHeight)
          EndIf
          If \nSourceHeight <= 0
            *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Image, 0, @sParameter, #MediaInfo_Info_Text, 0)
            ; debugMsgC2(sProcName, "MediaInfo_Get(" + nHandle + ", #MediaInfo_Stream_Video, 0, @" + sParameter + ", #MediaInfo_Info_Text, 0)", *sItem)
            If *sItem
              sHeight = PeekS(*sItem)
              If sHeight
                sDebugMsg + ", (image)sHeight=" + sHeight
                ; debugMsgC(sProcName, "(image) sHeight=" + sHeight)
              EndIf
              \nSourceHeight = Val(sHeight)
            EndIf
          EndIf
          
          debugMsg(sProcName, "grVideoInfo\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)

          ; rotation
          sParameter = "Rotation"  ; get rotation in degrees, eg 90°
          *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Video, 0, @sParameter, #MediaInfo_Info_Text, 0)
          If *sItem
            sRotation = PeekS(*sItem)
            If sRotation
              sDebugMsg + ", (video)sRotation=" + sRotation
              ; debugMsgC(sProcName, "(video) sRotation=" + sRotation)
            EndIf
            \nRotation = Val(sRotation)
          Else
            *sItem = MediaInfo_Get(nHandle, #MediaInfo_Stream_Image, 0, @sParameter, #MediaInfo_Info_Text, 0)
            If *sItem
              sRotation = PeekS(*sItem)
              If sRotation
                sDebugMsg + ", (image)sRotation=" + sRotation
                ; debugMsgC(sProcName, "(image) sRotation=" + sRotation)
              EndIf
              \nRotation = Val(sRotation)
            EndIf
          EndIf
          
          If sDebugMsg
            debugMsgC(sProcName, Mid(sDebugMsg, 3))
          EndIf
        EndIf
      EndIf
      hResult = MediaInfo_Delete(nHandle)
      
      \sInfo = UCase(GetExtensionPart(sFileName))
      If (\nSourceWidth > 0) And (\nSourceHeight > 0)
        \sInfo + " " + \nSourceWidth + "x" + \nSourceHeight
      EndIf
      
      \sTitle = ignoreExtension(GetFilePart(sFileName))
    CompilerEndIf
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure getVideoInfoForAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nHandle.i, sHandle.s
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      Select \nVideoSource
        Case #SCS_VID_SRC_FILE
          ; debugMsg(sProcName, "calling getVideoInfo(" + GetFilePart(\sFileName) + ")")
          If getVideoInfo(\sFileName)
            \nFileDuration = grVideoInfo\nLength
            \nFileChannels = 1
            If getFileFormat(\sFileName) = #SCS_FILEFORMAT_PICTURE
              \sFileType = getPictureInfoForAud(pAudPtr)
            Else
              \sFileType = grVideoInfo\sInfo
            EndIf
            \nSourceWidth = grVideoInfo\nSourceWidth
            \nSourceHeight = grVideoInfo\nSourceHeight
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sFileType=" + \sFileType + ")\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight) ; Changed 25Jun2022 11.9.4
            \sFileTitle = grVideoInfo\sTitle
            \nVideoRotation = grVideoInfo\nRotation ; Added 7May2020 11.8.3rc3
            ; debugMsg(sProcName, "calling setDerivedAudFields(" + getAudLabel(pAudPtr) + ")")
            setDerivedAudFields(pAudPtr)
          Else
            debugMsg(sProcName, "getVideoInfo() returned false for " + \sFileName)
          EndIf
        Case #SCS_VID_SRC_CAPTURE
          If grTVGControl\nTVGWorkControlIndex >= 0
            nHandle = *gmVideoGrabber(grTVGControl\nTVGWorkControlIndex)
            sHandle = decodeHandle(nHandle)
          EndIf
      EndSelect
    EndWith
  EndIf
EndProcedure

Procedure.s getPictureInfoForAud(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  Protected sFileInfo.s, sFileExt.s
  Protected imfImageWork
  
  ; debugMsg(sProcName, #SCS_START + ", pAudPtr=" + pAudPtr)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      sFileExt = GetExtensionPart(\sFileName)
      sFileInfo = LCase(sFileExt)
      imfImageWork = LoadImage(#PB_Any, \sFileName)
      ; logCreateImage(50, imfImageWork, pAudPtr)
      If IsImage(imfImageWork)
        \nImageFrameCount = ImageFrameCount(imfImageWork)
        If \nImageFrameCount > 1
          sFileInfo = grText\sTextAnimated + " " + UCase(sFileExt)
        EndIf
        sFileInfo + " " + ImageWidth(imfImageWork) + "x" + ImageHeight(imfImageWork)
        FreeImage(imfImageWork)
        ; logFreeImage(50, imfImageWork)
      EndIf
    EndWith
  EndIf
  ProcedureReturn Trim(sFileInfo)
  
EndProcedure

Procedure getVideoPosition(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nCurrPos
  Protected nAbsFilePos
  Protected qPlayerPos.q
  
  With aAud(pAudPtr)
    If \nAudVidPicTarget = #SCS_VID_PIC_TARGET_NONE
      ; can occur in control thread if cue has just been stopped
      ProcedureReturn 0
    EndIf
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          If \bPlayEndSyncOccurred Or \nPlayTVGIndex < 0 ; Added "Or \nPlayTVGIndex < 0" 8Apr2020 11.8.2.3an
            nAbsFilePos = \nAbsEndAt
          Else
            qPlayerPos = TVG_GetPlayerTimePosition(*gmVideoGrabber(\nPlayTVGIndex))
            nAbsFilePos = qPlayerPos / 10000  ; convert 100ns units to milliseconds
          EndIf
          nCurrPos = nAbsFilePos - \nAbsMin
        CompilerEndIf
    EndSelect
  EndWith

  ProcedureReturn nCurrPos
  
EndProcedure

Procedure setVideoPosition(pAudPtr, pVidPicTarget, pPosition, bRestartIfStopped=#False, bAssumePlaying=#False, bCheckAudVFLoopProperty=#False)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nMovieNo, qSeekPos.q
  Protected bVideoPlaying
  Protected dSetPos.d
  Protected nDuration
  Protected nTVGIndex
  Protected nPlayerState
  
  debugMsg(sProcName, #SCS_START + ", pPosition=" + pPosition)
  
  With aAud(pAudPtr)
    
    If \nFileFormat <> #SCS_FILEFORMAT_VIDEO
      debugMsg(sProcName, "exiting because \nFileFormat=" + decodeFileFormat(\nFileFormat))
      ProcedureReturn
    EndIf
    
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
        ; continue
      Default
        debugMsg(sProcName, "exiting because pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
        ProcedureReturn
    EndSelect
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        ; no action here
        
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          qSeekPos = pPosition * 10000  ; convert milliseconds to 100ns units
          nTVGIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
        CompilerEndIf
        
    EndSelect
    
    If bAssumePlaying
      bVideoPlaying = #True
    ElseIf bRestartIfStopped
      bVideoPlaying = #True
    Else
      bVideoPlaying = isVideoPlaying(pVidPicTarget, pAudPtr)
    EndIf
    
    nMovieNo = grVidPicTarget(pVidPicTarget)\nMovieNo
    
    debugMsg(sProcName, "bVideoPlaying=" + strB(bVideoPlaying))
    If bVideoPlaying
      
      Select \nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
          CompilerIf #c_vMix_in_video_cues
            vMix_SetPosition(pAudPtr, pPosition)
          CompilerEndIf
          
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            If nTVGIndex >= 0
              TVG_SetPlayerTimePosition(*gmVideoGrabber(nTVGIndex), qSeekPos)
              debugMsgT(sProcName, "TVG_SetPlayerTimePosition(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", " + qSeekPos + ")")
            EndIf
          CompilerEndIf
          
      EndSelect
      
      grVidPicTarget(pVidPicTarget)\nCurrMoviePos = pPosition
      \bMediaStarted = #False
      \bMediaEnded = #False
      \bPlayEndSyncOccurred = #False
      
      If bRestartIfStopped
        Select \nVideoPlaybackLibrary
          Case #SCS_VPL_VMIX
            CompilerIf #c_vMix_in_video_cues
              ; debugMsg(sProcName, "calling checkMovieStopped(" + nMovieNo + ", " + getAudLabel(pAudPtr) + ")")
              If checkMovieStopped(nMovieNo, pAudPtr)
                ; currently stopped
                vMix_RestartInput(pAudPtr)
                logKeyEvent("vMix_RestartInput(" + getAudLabel(pAudPtr) + ")")
              EndIf
            CompilerEndIf
            
          Case #SCS_VPL_TVG
            CompilerIf #c_include_tvg
              If nTVGIndex >= 0
                nPlayerState = TVG_GetPlayerState(*gmVideoGrabber(nTVGIndex))
                debugMsgT(sProcName, "TVG_GetPlayerState(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ") returned " + decodeTVGPlayerState(nPlayerState))
                Select nPlayerState
                  Case #tvc_ps_Paused, #tvc_ps_Stopped
                    ; 5Apr2018 11.7.0.1: calling TVG_RunPlayer from the control thread can cause a deadlock
                    ; (reported by Lluís Vilarrasa and debugged using "\UserFiles\2018\Lluís Vilarrasa\2018_04_04\SCSVideo\VideoTests.scs11")
                    ; so use PostEvent if necessary
                    Select gnThreadNo
                      Case #SCS_THREAD_ZERO, #SCS_THREAD_MAIN
                        debugMsgT(sProcName, "calling TVG_RunPlayer(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
                        TVG_RunPlayer(*gmVideoGrabber(nTVGIndex))
                        debugMsgT(sProcName, "TVG_RunPlayer(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
                      Default
                        PostEvent(#SCS_Event_TVG_RunPlayer, #WMN, 0, 0, nTVGIndex)
                    EndSelect
                    ; Debug sProcName + ": TVG_RunPlayer(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")"
                EndSelect
              EndIf
            CompilerEndIf
            
        EndSelect
        
      EndIf ; EndIf bRestartIfStopped
      
    ElseIf (pVidPicTarget = #SCS_VID_PIC_TARGET_P) Or (pVidPicTarget = #SCS_VID_PIC_TARGET_T)
      debugMsg(sProcName, "calling showMyVideoFrame(" + getAudLabel(pAudPtr) + ", " + pPosition + ")")
      showMyVideoFrame(pAudPtr, pPosition)
      
    Else
      
      Select \nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
          CompilerIf #c_vMix_in_video_cues
            vMix_SetPosition(pAudPtr, pPosition)
          CompilerEndIf
          
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            If nTVGIndex >= 0
              TVG_SetPlayerTimePosition(*gmVideoGrabber(nTVGIndex), qSeekPos)
              debugMsgT(sProcName, "TVG_SetPlayerTimePosition(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", " + qSeekPos + ")")
            EndIf
          CompilerEndIf
          
      EndSelect
      
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure playVideo(pAudPtr, pVidPicTarget, bUseCas=#False, nCasGroupId=-1, bCheckProgSlider=#False)
  PROCNAMECA(pAudPtr)
  Protected rCasInfo.tyCasItem
  Protected nStopAudPtr, nStopSubPtr
  Protected nPrevPrimaryAudPtr
  Protected nPrevPlayingSubPtr
  Protected nCompletedCuePtr
  Protected nAbsRepositionAt = #SCS_PARAM_NOT_SET
  Protected bFadesAvailable
  Protected bRelockCueListMutex
  Protected bLockedMutex
  Protected nVideoNo, nVideoCanvasNo
  Protected bCloseWhatWasPlaying
  Protected nSubPtr, bUse2DDrawing
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) +
                      ", bUseCas=" + strB(bUseCas) + ", nCasGroupId=" + nCasGroupId + ", bCheckProgSlider=" + strB(bCheckProgSlider) +
                      ", \nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState))
  
  If pVidPicTarget = #SCS_VID_PIC_TARGET_NONE
    ProcedureReturn #False
  EndIf

  If aAud(pAudPtr)\nAudState = #SCS_CUE_ERROR
    ProcedureReturn #False
  EndIf
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  bUse2DDrawing = checkUse2DDrawing(nSubPtr)
  If (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (bUse2DDrawing)
    If gnThreadNo > #SCS_THREAD_MAIN
      samAddRequest(#SCS_SAM_PLAY_VIDEO, pAudPtr, 0.0, pVidPicTarget)
      ProcedureReturn #True
    EndIf
  EndIf
  
  ; added suspend control thread to prevent stopAud() starting up another Aud in the slideshow (via the control thread) if the entire sub-cue is to be stopped
  If gnThreadNo <> #SCS_THREAD_CONTROL
    ; the following test added 30May2019 11.8.1.1ab following test of cross-fading from a video to an image, and the 'doAudFades()' were all called while waiting for the control thread to be suspended
    If (aSub(nSubPtr)\nSubState >= #SCS_CUE_FADING_OUT) And (aAud(pAudPtr)\nNextPlayIndex >= 0)
      debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState))
      debugMsg(sProcName, "gnCueListMutexLockThread=" + gnCueListMutexLockThread)
      If (gnCueListMutexLockThread > 0) And (gnCueListMutexLockThread = gnThreadNo)
        bLockedMutex = #True
        debugMsg(sProcName, "calling UnlockCueListMutex()")
        UnlockCueListMutex()
        bRelockCueListMutex = #True
      EndIf
      debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
      THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
      debugMsg(sProcName, "returned from THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
      If bRelockCueListMutex
        debugMsg(sProcName, "calling LockCueListMutex(431)")
        LockCueListMutex(431)
      EndIf
      debugMsg(sProcName, "continuing")
    EndIf
  EndIf
  
  With aAud(pAudPtr)
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        bFadesAvailable = #True
      Case #SCS_VPL_TVG
        bFadesAvailable = #True
    EndSelect
    
    \nAudVidPicTarget = pVidPicTarget
    If pVidPicTarget = #SCS_VID_PIC_TARGET_P
      If bCheckProgSlider
        nAbsRepositionAt = SLD_getValue(WQA\sldProgress[0]) + \nAbsMin
        debugMsg(sProcName, "nAbsRepositionAt=" + nAbsRepositionAt + ", SLD_getValue(WQA\sldProgress[0])=" + SLD_getValue(WQA\sldProgress[0]))
      EndIf
    EndIf
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
;         Select pVidPicTarget
;           Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
;             \nPlayVideoNo = \nMainVideoNo
;           Case #SCS_VID_PIC_TARGET_P
;             \nPlayVideoNo = \nPreviewVideoNo
;         EndSelect
        \nPlayVideoNo = \nMainVideoNo
        debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", aAud(" + getAudLabel(pAudPtr) + ")\nPlayVideoNo=" + \nPlayVideoNo)
      Default
        ; NOT vMix
        Select pVidPicTarget
          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            \nPlayVideoNo = \nMainVideoNo
            \nPlayTVGIndex = \nMainTVGIndex
          Case #SCS_VID_PIC_TARGET_P
            \nPlayVideoNo = \nPreviewVideoNo
            \nPlayTVGIndex = \nPreviewTVGIndex
        EndSelect
        debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", aAud(" + getAudLabel(pAudPtr) + ")\nPlayVideoNo=" + \nPlayVideoNo + ", \nPlayTVGIndex=" + \nPlayTVGIndex)
    EndSelect
    nVideoNo = \nPlayVideoNo
    nVideoCanvasNo = grVidPicTarget(pVidPicTarget)\nVideoCanvasNo
    
    nStopAudPtr = -1
    nStopSubPtr = -1
    nCompletedCuePtr = -1
    \bPlayEndSyncOccurred = #False
    \bInForcedFadeOut = #False
    
    If \bPrimeVideoReqd
      debugMsg(sProcName, "calling primeVideoForTarget(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(\nPrimeVideoVidPicTarget) + ", #True)")
      primeVideoForTarget(pAudPtr, \nPrimeVideoVidPicTarget, #True)
    EndIf
  EndWith

  If (bUseCas) And (bFadesAvailable = #False)
    With rCasInfo
      \nCasCueAction = #SCS_CAS_PLAY_VIDEO
      \nCasVidPicTarget = pVidPicTarget
      \nCasAudPtr = pAudPtr
      \sCasOriginProcName = sProcName
      \nCasGroupId = nCasGroupId
      grCasItem = rCasInfo
      casAddRequest()
    EndWith
    
  Else
    
    With grVidPicTarget(pVidPicTarget)
      nPrevPrimaryAudPtr = \nPrimaryAudPtr
      nPrevPlayingSubPtr = \nPlayingSubPtr
      \nPrimaryAudPtr = pAudPtr
      \nPlayingSubPtr = -1
      If \bLogoCurrentlyDisplayed
        \bLogoCurrentlyDisplayed = #False
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
      EndIf
      \nPrimaryFileFormat = aAud(pAudPtr)\nFileFormat
      \sPrimaryFileName = aAud(pAudPtr)\sFileName
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) +
                          ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \sPrimaryFileName=" + GetFilePart(\sPrimaryFileName))
      
      If grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG
        If aAud(pAudPtr)\bAudUseGaplessStream = #False
          If IsGadget(nVideoCanvasNo)
            If getVisible(nVideoCanvasNo) = #False
              setVisible(nVideoCanvasNo, #True)
              debugMsgV(sProcName, "setVisible(" + getGadgetName(nVideoCanvasNo) + ", #True)")
            EndIf
          EndIf
        EndIf
      EndIf
      
      If (\nPrimaryAudPtr >= 0) And (\nPrimaryAudPtr <> pAudPtr)
        If bFadesAvailable
          If aAud(\nPrimaryAudPtr)\nFadeOutTime > 0
            debugMsg(sProcName, "calling fadeOutOneAud(" + getAudLabel(\nPrimaryAudPtr) + ")")
            fadeOutOneAud(\nPrimaryAudPtr)
          Else
            debugMsg(sProcName, "calling stopAud(" + getAudLabel(\nPrimaryAudPtr) + ")")
            stopAud(\nPrimaryAudPtr)
          EndIf
        Else
          If (aAud(\nPrimaryAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(\nPrimaryAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
            debugMsg(sProcName, "calling stopAud(" + getAudLabel(\nPrimaryAudPtr) + ")")
            stopAud(\nPrimaryAudPtr)
          EndIf
          debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
        EndIf
        debugMsg(sProcName, "nPrevPrimaryAudPtr=" + getAudLabel(nPrevPrimaryAudPtr) + ", pAudPtr=" + getAudLabel(pAudPtr))
        If aAud(nPrevPrimaryAudPtr)\nSubIndex <> aAud(pAudPtr)\nSubIndex
          nStopSubPtr = aAud(nPrevPrimaryAudPtr)\nSubIndex
        EndIf
        If aAud(nPrevPrimaryAudPtr)\nCueIndex <> aAud(pAudPtr)\nCueIndex
          nCompletedCuePtr = aAud(nPrevPrimaryAudPtr)\nCueIndex
        EndIf
        debugMsg(sProcName, "nCompletedCuePtr=" + getCueLabel(nCompletedCuePtr))
        
      ElseIf \nPlayingSubPtr >= 0
        If aSub(\nPlayingSubPtr)\bSubTypeE
          debugMsg(sProcName, "calling stopSub(" + getSubLabel(\nPlayingSubPtr) + ", 'ALL', #False)")
          stopSub(\nPlayingSubPtr, "ALL", #False, #False)
        EndIf
        
      EndIf
      \nPrevPrimaryAudPtr = nPrevPrimaryAudPtr
      \nPrimaryAudPtr = pAudPtr
      \nPlayingSubPtr = -1
      \nPrimaryFileFormat = aAud(pAudPtr)\nFileFormat
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) +
                          ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) +
                          ", aAud(" + getAudLabel(pAudPtr) + ")\nMainVideoNo=" + decodeHandle(aAud(pAudPtr)\nMainVideoNo) + ", \nPreviewVideoNo=" + decodeHandle(aAud(pAudPtr)\nPreviewVideoNo))
      
      Select aAud(pAudPtr)\nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
          CompilerIf #c_vMix_in_video_cues
            If nVideoNo <= 0
              debugMsg(sProcName, "calling openVideoFile(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
              nVideoNo = openVideoFile(pAudPtr, pVidPicTarget)
              If gbCloseCueFile Or gbCloseSCS
                ProcedureReturn
              EndIf
              aAud(pAudPtr)\nPlayVideoNo = aAud(pAudPtr)\nMainVideoNo
              debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", aAud(" + getAudLabel(pAudPtr) + ")\nPlayVideoNo=" + aAud(pAudPtr)\nPlayVideoNo)
            EndIf
          CompilerEndIf
          
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            If nVideoNo = 0
              debugMsg(sProcName, "calling openVideoFile(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
              nVideoNo = openVideoFile(pAudPtr, pVidPicTarget)
              ; aAud(pAudPtr)\nPlayVideoNo = nVideoNo
              Select pVidPicTarget
                Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                  aAud(pAudPtr)\nPlayVideoNo = aAud(pAudPtr)\nMainVideoNo
                  aAud(pAudPtr)\nPlayTVGIndex = aAud(pAudPtr)\nMainTVGIndex
                Case #SCS_VID_PIC_TARGET_P
                  aAud(pAudPtr)\nPlayVideoNo = aAud(pAudPtr)\nPreviewVideoNo
                  aAud(pAudPtr)\nPlayTVGIndex = aAud(pAudPtr)\nPreviewTVGIndex
              EndSelect
              debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", aAud(" + getAudLabel(pAudPtr) + ")\nPlayVideoNo=" + aAud(pAudPtr)\nPlayVideoNo + ", \nPlayTVGIndex=" + aAud(pAudPtr)\nPlayTVGIndex)
            EndIf
          CompilerEndIf
          
      EndSelect
      \nMovieNo = nVideoNo
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nMovieNo=" + decodeHandle(\nMovieNo))
      \sMovieFileName = aAud(pAudPtr)\sFileName
      \nMovieAudPtr = pAudPtr
      \nCurrMoviePos = 0
    EndWith
    
    playAVideo(pAudPtr, pVidPicTarget, nAbsRepositionAt)
    
  EndIf
  
  debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure pauseVideo(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nTVGIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_PAUSE_VIDEO, pAudPtr)
    ProcedureReturn
  EndIf
  
  With aAud(pAudPtr)
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        CompilerIf #c_vMix_in_video_cues
          debugMsg(sProcName, "calling vMix_PauseInput(" + getAudLabel(pAudPtr) + ")")
          vMix_PauseInput(pAudPtr)
        CompilerEndIf
        
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          nTVGIndex = getTVGIndexForAud(pAudPtr, \nAudVidPicTarget)
          If nTVGIndex >= 0
            TVG_PausePlayer(*gmVideoGrabber(nTVGIndex))
            debugMsgT(sProcName, "TVG_PausePlayer(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
          EndIf
        CompilerEndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure resumeVideo(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nTVGIndex
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        CompilerIf #c_vMix_in_video_cues
          debugMsg(sProcName, "calling vMix_ResumeInput(" + getAudLabel(pAudPtr) + ")")
          vMix_ResumeInput(pAudPtr)
        CompilerEndIf
        
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          nTVGIndex = getTVGIndexForAud(pAudPtr, \nAudVidPicTarget)
          If nTVGIndex >= 0
            TVG_RunPlayer(*gmVideoGrabber(nTVGIndex))
            debugMsgT(sProcName, "TVG_RunPlayer(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
          EndIf
        CompilerEndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure stopVideo(pAudPtr, pVidPicTarget, bCloseVideo, bHideVideo=#True)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nSubPtr
  Protected bHoldIgnoreInStatusCheck
  Protected nHoldPrimaryAudPtr
  Protected nGaplessSeqPtr
  Protected nLastGaplessAudPtr
  Protected bMyHideVideo
  Protected nTVGIndex
  Protected nHandle.i, sHandle.s
  Protected sBlankString.s = ""
  Protected nLongResult.l
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", bCloseVideo=" + strB(bCloseVideo) + ", bHideVideo=" + strB(bHideVideo))
  
  If aAud(pAudPtr)\nAudState = #SCS_CUE_ERROR
    ProcedureReturn
  EndIf

  bHoldIgnoreInStatusCheck = aAud(pAudPtr)\bIgnoreInStatusCheck
  If gbFadingEverything = #False ; Test added 4Jun2021 11.8.5
    aAud(pAudPtr)\bIgnoreInStatusCheck = #True
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bIgnoreInStatusCheck=" + strB(aAud(pAudPtr)\bIgnoreInStatusCheck))
  EndIf
  nSubPtr = aAud(pAudPtr)\nSubIndex
  THR_waitForCueStatusChecksToEnd()
  
  bMyHideVideo = bHideVideo
  nGaplessSeqPtr = aAud(pAudPtr)\nAudGaplessSeqPtr
  If nGaplessSeqPtr >= 0
    nLastGaplessAudPtr = gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr
    If bMyHideVideo
      If nLastGaplessAudPtr >= 0
        If pAudPtr <> nLastGaplessAudPtr
          bMyHideVideo = #False
        EndIf
      EndIf
    EndIf
  Else
    nLastGaplessAudPtr = -1
  EndIf
  
  If (bCloseVideo = #False) And (gbStoppingEverything = #False)
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
        Select aAud(pAudPtr)\nVideoPlaybackLibrary
          Case #SCS_VPL_VMIX
            CompilerIf #c_vMix_in_video_cues
              debugMsg(sProcName, "calling vMix_StopInput(" + getAudLabel(pAudPtr) + ")")
              vMix_StopInput(pAudPtr)
            CompilerEndIf
            
          Case #SCS_VPL_TVG
            CompilerIf #c_include_tvg
              nTVGIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
              If nTVGIndex >= 0
                If aAud(pAudPtr)\nVideoSource = #SCS_VID_SRC_CAPTURE
                  debugMsg(sProcName, "Stopping Video Capture TVG")
                  stopTVGCapture(nTVGIndex, #False)
                Else
                  stopTVGVideo(nTVGIndex, #False)
                EndIf
              EndIf
            CompilerEndIf
            
        EndSelect
    EndSelect
  EndIf
  
  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      With grVidPicTarget(pVidPicTarget)
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
        nHoldPrimaryAudPtr = \nPrimaryAudPtr
        If ((aSub(nSubPtr)\bStartedInEditor) Or (bCloseVideo = #False)) And (gbStoppingEverything = #False)
          ; no action
        Else
          Select grVideoDriver\nVideoPlaybackLibrary
            Case #SCS_VPL_VMIX
              CompilerIf #c_vMix_in_video_cues
                debugMsg(sProcName, "calling vMix_StopInput(" + getAudLabel(pAudPtr) + ")")
                vMix_StopInput(pAudPtr)
                debugMsg(sProcName, "calling vMix_RemoveInput(" + getAudLabel(pAudPtr) + ")")
                vMix_RemoveInput(pAudPtr)
              CompilerEndIf
              
            Case #SCS_VPL_TVG
              CompilerIf #c_include_tvg
                nTVGIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
                debugMsg(sProcName, "nTVGIndex=" + nTVGIndex)
                If nTVGIndex >= 0
                  nHandle = *gmVideoGrabber(nTVGIndex)
                  sHandle = decodeHandle(nHandle)
                  If aAud(pAudPtr)\nVideoSource = #SCS_VID_SRC_CAPTURE
                    debugMsg(sProcName, "Stopping Video Capture TVG")
                    stopTVGCapture(nTVGIndex, #False)
                  ElseIf aAud(pAudPtr)\bUsingMemoryImage
                    debugMsgT(sProcName, "calling TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(pAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true)")
                    nLongResult = TVG_SendImageToVideoFromBitmaps(nHandle, @sBlankString, ImageID(aAud(pAudPtr)\nMemoryImageNo), #tvc_true, #tvc_true)
                    debugMsgT2(sProcName, "TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(pAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true)", nLongResult)
                    debugMsgT(sProcName, "calling TVG_StopPreview(" + sHandle + ")")
                    TVG_StopPreview(nHandle)
                    debugMsgT(sProcName, "TVG_StopPreview(" + sHandle + ")")
                  Else
                    debugMsgT(sProcName, "calling TVG_PausePlayer(" + sHandle + ")")
                    TVG_PausePlayer(nHandle)
                    debugMsgT(sProcName, "TVG_PausePlayer(" + sHandle + ")")
                  EndIf
                  debugMsg(sProcName, "calling freeTVGControl(" + nTVGIndex + ")")
                  freeTVGControl(nTVGIndex)
                EndIf
              CompilerEndIf
              
          EndSelect
          If \nPrimaryAudPtr = pAudPtr
            \nMovieNo = 0
            debugMsg(sProcName, "\nMovieNo=0")
            \nMovieAudPtr = -1
            \nPrevPrimaryAudPtr = nHoldPrimaryAudPtr
            \nPrimaryAudPtr = -1
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
            \sPrimaryFileName = ""
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\sPrimaryFileName=" + GetFilePart(\sPrimaryFileName))
          EndIf
          debugMsg(sProcName, "setting aAud(" + getAudLabel(pAudPtr) + ")\nMainVideoNo=0, currently=" + decodeHandle(aAud(pAudPtr)\nMainVideoNo))
          aAud(pAudPtr)\nMainVideoNo = 0
          aAud(pAudPtr)\nAudVidPicTarget = #SCS_VID_PIC_TARGET_NONE
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudVidPicTarget=" + decodeVidPicTarget(aAud(pAudPtr)\nAudVidPicTarget))
          aAud(pAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileState=" + decodeFileState(aAud(pAudPtr)\nFileState))
        EndIf ; EndIf / Else ((aSub(nSubIndex)\bStartedInEditor) Or (bCloseVideo = #False)) And (gbStoppingEverything = #False)
        
        If \nPrimaryAudPtr = pAudPtr
          \nPlayingSubPtr = -1
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr))
        EndIf
      EndWith
      
    Case #SCS_VID_PIC_TARGET_P
      With grVidPicTarget(pVidPicTarget)
        \nPrimaryAudPtr = -1
        \nPlayingSubPtr = -1
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr))
;         debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bVideoRunning=" + strB(\bVideoRunning) + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
        Select grVideoDriver\nVideoPlaybackLibrary
          Case #SCS_VPL_TVG
            CompilerIf #c_include_tvg
              nTVGIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
              If nTVGIndex >= 0
                nHandle = *gmVideoGrabber(nTVGIndex)
                sHandle = decodeHandle(nHandle)
                debugMsg(sProcName, "calling TVG_StopPlayer(" + sHandle + ")")
                TVG_StopPlayer(nHandle)
                debugMsgT(sProcName, "TVG_StopPlayer(" + sHandle + ")")
                debugMsg(sProcName, "calling freeTVGControl(" + nTVGIndex + ")")
                freeTVGControl(nTVGIndex)
              EndIf
            CompilerEndIf
        EndSelect
      EndWith
      
  EndSelect
  
  With aAud(pAudPtr)
    If \nVideoPlaybackLibrary = #SCS_VPL_TVG And \nVideoSource = #SCS_VID_SRC_FILE
      debugMsg(sProcName, "calling adjustVidAudPlayingCount(" + getSubLabel(nSubPtr) + ", -1)")
      adjustVidAudPlayingCount(nSubPtr, -1)
    EndIf
    \bIgnoreInStatusCheck = bHoldIgnoreInStatusCheck
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure playAVideo(pAudPtr, pVidPicTarget, pAbsStartAt=#SCS_PARAM_NOT_SET)
  PROCNAMECA(pAudPtr)
  Protected dTmpDouble.d
  Protected nAbsCurrPos
  Protected nAbsStartAt
  Protected nSubPtr
  Protected bMonitorWindowExists
  Protected nVideoPlaybackLibrary
  Protected nStopAudPtr = -1
  Protected nVideoCanvasNo
  Protected nMonitorCanvasNo
  Protected qStartPos.q, qCurrPos.q
  Protected nIndex
  
  If pAbsStartAt = #SCS_PARAM_NOT_SET
    debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", pAbsStartAt=#SCS_PARAM_NOT_SET")
  Else
    debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", pAbsStartAt=" + pAbsStartAt)
  EndIf
  
  If pAudPtr < 0
    ProcedureReturn
  EndIf
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  
  CompilerIf #c_include_tvg
    nIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
  CompilerEndIf
  
  With grVidPicTarget(pVidPicTarget)
    
    If aSub(nSubPtr)\bStartedInEditor = #False
      nMonitorCanvasNo = \nMonitorCanvasNo
      nVideoCanvasNo = aAud(pAudPtr)\nAudVideoCanvasNo(pVidPicTarget)
    Else
      ; if started in editor then leave nMonitorCanvas at 0 which prevents the monitor window being made visible in this procedure
      If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
        ; NB The SCS cvsVideo canvas is not used by vMix, but the cvsPreview canvas has already been populated with the message "See preview in vMix Control Panel"
        nVideoCanvasNo = WQA\cvsPreview
      Else
        If gbPreviewOnOutputScreen
          nVideoCanvasNo = aAud(pAudPtr)\nAudVideoCanvasNo(pVidPicTarget)
        Else
          nVideoCanvasNo = WQA\cvsPreview
        EndIf
      EndIf
    EndIf
    
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(aAud(pAudPtr)\nVideoPlaybackLibrary))
    nVideoPlaybackLibrary = aAud(pAudPtr)\nVideoPlaybackLibrary
    Select nVideoPlaybackLibrary
      Case #SCS_VPL_NOT_SET, #SCS_VPL_IMAGE
        ; shouldn't get here
        nVideoPlaybackLibrary = grVideoDriver\nVideoPlaybackLibrary
        aAud(pAudPtr)\nVideoPlaybackLibrary = nVideoPlaybackLibrary
    EndSelect
    \nCurrVideoPlaybackLibrary = nVideoPlaybackLibrary
    
    If \nMovieNo = 0
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nMovieNo=0")
      ProcedureReturn
    EndIf
    
    If IsGadget(nMonitorCanvasNo)
      bMonitorWindowExists = #True
    EndIf
    ; debugMsg(sProcName, "nMonitorCanvasNo=" + getGadgetName(nMonitorCanvasNo) + ", bMonitorWindowExists=" + strB(bMonitorWindowExists))
    
    \bShowingPreviewImage = #False
    ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bShowingPreviewImage=" + strB(\bShowingPreviewImage))
    
    If \bVideoRunning
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bVideoRunning=" + strB(\bVideoRunning) + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
      If (\nPrimaryAudPtr >= 0) And (\nPrimaryAudPtr <> pAudPtr)
        nStopAudPtr = \nPrimaryAudPtr
      EndIf
    EndIf
    
    \bVideoRunning = #True
    \nPrimaryAudPtr = pAudPtr
    \nPlayingSubPtr = nSubPtr
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr))
    aAud(pAudPtr)\nAudVidPicTarget = pVidPicTarget
    
    \nCurrAudPtr = pAudPtr
    
    If aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO
      If pAbsStartAt = #SCS_PARAM_NOT_SET
        nAbsStartAt = aAud(pAudPtr)\nAbsStartAt + aAud(pAudPtr)\nManualOffset
        debugMsg(sProcName, "aAud("+ getAudLabel(pAudPtr) + ")\nAbsStartAt=" + aAud(pAudPtr)\nAbsStartAt + ", \nManualOffset=" + aAud(pAudPtr)\nManualOffset + ", nAbsStartAt=" + nAbsStartAt)
      Else
        nAbsStartAt = pAbsStartAt
      EndIf
      If nAbsStartAt > 0
        debugMsg3(sProcName, "nAbsStartAt=" + nAbsStartAt)
      EndIf
      
      ; set required level and pan
      If aSub(nSubPtr)\bMuteVideoAudio
        setLevelsVideo(pAudPtr, 0, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE, pVidPicTarget)
        debugMsg3(sProcName, "setLevelsVideo(" + getAudLabel(pAudPtr) + ", 0, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE, " + decodeVidPicTarget(pVidPicTarget) + ")")
      Else
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueVolNow[0]=" + formatLevel(aAud(pAudPtr)\fCueVolNow[0]))
        setLevelsVideo(pAudPtr, 0, aAud(pAudPtr)\fCueVolNow[0], aAud(pAudPtr)\fCuePanNow[0], pVidPicTarget)
        debugMsg3(sProcName, "setLevelsVideo(" + getAudLabel(pAudPtr) + ", 0, " + formatLevel(aAud(pAudPtr)\fCueVolNow[0]) +
                             ", " + formatPan(aAud(pAudPtr)\fCuePanNow[0]) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
      EndIf
    EndIf
    
    If IsImage(\nLogoImageNo)
      displayBlack(pVidPicTarget)
    EndIf
    
    If nAbsStartAt = 0  ; starting at beginning of file
      debugMsg(sProcName, ">>> starting at beginning of file")
      ; start playback
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          Select nVideoPlaybackLibrary
            Case #SCS_VPL_VMIX
              CompilerIf #c_vMix_in_video_cues
                debugMsg(sProcName, "calling vMix_PlayInput(" + getAudLabel(pAudPtr) + ")")
                vMix_PlayInput(pAudPtr)
              CompilerEndIf
            Case #SCS_VPL_TVG
              CompilerIf #c_include_tvg
                debugMsg(sProcName, "calling playTVGVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
                playTVGVideo(pAudPtr, pVidPicTarget)
                If bMonitorWindowExists
                  ; debugMsg(sProcName, "nMonitorCanvasNo=" + getGadgetName(nMonitorCanvasNo) + ", bMonitorWindowExists=" + strB(bMonitorWindowExists))
                  debugMsg(sProcName, "calling setMonitorCanvasVisible(" + decodeVidPicTarget(pVidPicTarget) + ", " + getGadgetName(nMonitorCanvasNo) + ", #True)")
                  setMonitorCanvasVisible(pVidPicTarget, nMonitorCanvasNo, #True)
                  \nCurrMonitorCanvasNo = nMonitorCanvasNo
                  ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nCurrMonitorCanvasNo=" + \nCurrMonitorCanvasNo + ", " + getGadgetName(\nCurrMonitorCanvasNo))
                EndIf
              CompilerEndIf
              
          EndSelect
          gbMoviePlaying = #True
          
        Case #SCS_VID_PIC_TARGET_P
          Select nVideoPlaybackLibrary
            Case #SCS_VPL_VMIX
              CompilerIf #c_vMix_in_video_cues
                debugMsg(sProcName, "calling vMix_PlayInput(" + getAudLabel(pAudPtr) + ")")
                vMix_PlayInput(pAudPtr)
              CompilerEndIf
              
            Case #SCS_VPL_TVG
              CompilerIf #c_include_tvg
                debugMsg(sProcName, "calling playTVGVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
                playTVGVideo(pAudPtr, pVidPicTarget)
              CompilerEndIf
              
          EndSelect
          
      EndSelect
      
    Else ; starting part-way thru the file
      debugMsg(sProcName, ">>> starting part-way thru the file")
      Select nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
          CompilerIf #c_vMix_in_video_cues
            vMix_SetPosition(pAudPtr, nAbsStartAt)
            nAbsCurrPos = nAbsStartAt
          CompilerEndIf
          
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            ; NOTE: Prior to 11.5.1 the following code was blocked out by the extra CompilerIf condition " And 1=2"
            ; but this resulted in starting playback in the editor ignoring the current slider position.
            ; This was reported by David Preece 1Jul2016
            ; Reinstating this code fixes the problem
            qStartPos = nAbsStartAt * 10000
            If nIndex >= 0 ; Added test 8Apr2020 11.8.2.3an
              qCurrPos = TVG_GetPlayerTimePosition(*gmVideoGrabber(nIndex))
              debugMsgT(sProcName, "TVG_GetPlayerTimePosition(" + decodeHandle(*gmVideoGrabber(nIndex)) + ") returned " + qCurrPos)
              If qStartPos <> qCurrPos
                TVG_SetPlayerTimePosition(*gmVideoGrabber(nIndex), qStartPos)
                debugMsgT(sProcName, "TVG_SetPlayerTimePosition(" + decodeHandle(*gmVideoGrabber(nIndex)) + ", " + qStartPos + ")")
              EndIf
            EndIf
            nAbsCurrPos = nAbsStartAt
          CompilerEndIf
          
      EndSelect
      
      Select nVideoPlaybackLibrary
        Case #SCS_VPL_VMIX
          CompilerIf #c_vMix_in_video_cues
            If aAud(pAudPtr)\nCurrFadeInTime > 0
              debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCurrFadeInTime=" + aAud(pAudPtr)\nCurrFadeInTime)
              setAlphaBlend(pAudPtr, 0)
              setLevelsVideo(pAudPtr, 0, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE, pVidPicTarget)
            EndIf
            ; start playback
            debugMsg(sProcName, "calling vMix_PlayInput(" + getAudLabel(pAudPtr) + ")")
            vMix_PlayInput(pAudPtr)
          CompilerEndIf
          
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            If aAud(pAudPtr)\nCurrFadeInTime > 0
              debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCurrFadeInTime=" + aAud(pAudPtr)\nCurrFadeInTime)
              setAlphaBlend(pAudPtr, 0)
              setLevelsVideo(pAudPtr, 0, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE, pVidPicTarget)
            EndIf
            If bMonitorWindowExists
              debugMsg(sProcName, "calling setMonitorCanvasVisible(" + decodeVidPicTarget(pVidPicTarget) + ", " + getGadgetName(nMonitorCanvasNo) + ", #True)")
              setMonitorCanvasVisible(pVidPicTarget, nMonitorCanvasNo, #True)
              \nCurrMonitorCanvasNo = nMonitorCanvasNo
            EndIf
            ; start playback
            debugMsg(sProcName, "calling playTVGVideo(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
            playTVGVideo(pAudPtr, pVidPicTarget)
          CompilerEndIf
          
      EndSelect
      
      ; seek to start point
      Select nVideoPlaybackLibrary
        Case #SCS_VPL_TVG
          ; no action because openVideoFileForTVG() opened the player at the required start position
          
        Case #SCS_VPL_VMIX
          If nAbsCurrPos <> nAbsStartAt
            setVideoPosition(pAudPtr, pVidPicTarget, nAbsStartAt, #False, #True)
          EndIf
          
        Default
          setVideoPosition(pAudPtr, pVidPicTarget, nAbsStartAt, #False, #True)
          
      EndSelect
      
    EndIf
    
    If nStopAudPtr >= 0
      debugMsg(sProcName, "calling stopAud(" + getAudLabel(nStopAudPtr) + ", #False, #False, #True)")
      stopAud(nStopAudPtr, #False, #False, #True)
    EndIf
    
    \nMoviePlaying = \nMovieNo
    ; \nPrevPrimaryAudPtr = \nPrimaryAudPtr ; commented out - already rolled over in playVideo()
    \nPrimaryAudPtr = pAudPtr
    \nPlayingSubPtr = -1
    \nPrimaryFileFormat = aAud(pAudPtr)\nFileFormat
    \sPrimaryFileName = aAud(pAudPtr)\sFileName
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) +
                        ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) +
                        ", \sPrimaryFileName=" + GetFilePart(\sPrimaryFileName))
    
    makeVidPicVisible(pVidPicTarget, #True, pAudPtr)
    
  EndWith
  
  With aAud(pAudPtr)
    If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
      If \nCurrFadeInTime > 0
        If \nPrevPlayIndex >= 0
          \nAudState = #SCS_CUE_TRANS_FADING_IN
        Else
          \nAudState = #SCS_CUE_FADING_IN
        EndIf
      Else
        \nAudState = #SCS_CUE_PLAYING
      EndIf
      setCueState(\nCueIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure showFrame(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected nImageWidth, nImageHeight
  Protected nTargetWidth, nTargetHeight
  Protected nDisplayWidth, nDisplayHeight, nXOffSet, nYOffSet
  Protected xRatio.f, yRatio.f
  Protected nImageNo
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_P
        nImageNo = aAud(pAudPtr)\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_P)
      Case #SCS_VID_PIC_TARGET_T
        nImageNo = aAud(pAudPtr)\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_T)
    EndSelect
    debugMsg(sProcName, "nImageNo=" + decodeHandle(nImageNo) + ", IsImage(" + decodeHandle(nImageNo) + ")=" + IsImage(nImageNo))
    If IsImage(nImageNo)
      
      nTargetWidth = \nTargetWidth
      nTargetHeight = \nTargetHeight
      nImageWidth = ImageWidth(nImageNo)
      nImageHeight = ImageHeight(nImageNo)
      
      ; resize image as required
      xRatio = nImageWidth / nTargetWidth
      yRatio = nImageHeight / nTargetHeight
      If xRatio >= yRatio
        nDisplayWidth = nImageWidth / xRatio
        nDisplayHeight = nImageHeight / xRatio
      Else
        nDisplayWidth = nImageWidth / yRatio
        nDisplayHeight = nImageHeight / yRatio
      EndIf
      
      nXOffSet = (nTargetWidth - nDisplayWidth) >> 1
      nYOffSet = (nTargetHeight - nDisplayHeight) >> 1
      debugMsg(sProcName, "nImageWidth=" + nImageWidth + ", nTargetWidth=" + nTargetWidth + ", xRatio=" + StrF(xRatio,2) + ", nDisplayWidth=" + nDisplayWidth + ", nXOffSet=" + nXOffSet)
      debugMsg(sProcName, "nImageHeight=" + nImageHeight + ", nTargetHeight=" + nTargetHeight + ", xRatio=" + StrF(xRatio,2) + ", nDisplayHeight=" + nDisplayHeight + ", nYOffSet=" + nYOffSet)
      
      debugMsg3(sProcName, "calling clearPicture(" + decodeVidPicTarget(pVidPicTarget) + ")")
      clearPicture(pVidPicTarget, #False, "", 0, #True)
      If StartDrawing(CanvasOutput(WQA\cvsPreview))
        debugMsgD(sProcName, "StartDrawing(CanvasOutput(WQA\cvsPreview))")
        Box(0,0,GadgetWidth(WQA\cvsPreview),GadgetHeight(WQA\cvsPreview),#SCS_Black)
        debugMsgD(sProcName, "Box(0,0," + GadgetWidth(WQA\cvsPreview) + "," + GadgetHeight(WQA\cvsPreview) + ",#SCS_Black)")
        debugMsg(sProcName, "calling DrawImage(" + ImageID(nImageNo) + ", " + nXOffSet + ", " + nYOffSet + ", " + nDisplayWidth + ", " + nDisplayHeight + ") (To WQA\cvsPreview)")
        DrawImage(ImageID(nImageNo), nXOffSet, nYOffSet, nDisplayWidth, nDisplayHeight)
        debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nImageNo) + "), " + nXOffSet + ", " + nYOffSet + ", " + nDisplayWidth + ", " + nDisplayHeight + ") (to WQA\cvsPreview)")
        StopDrawing()
        debugMsgD(sProcName, "StopDrawing()")
      EndIf
      
    Else
      debugMsg3(sProcName, "calling clearPicture(" + decodeVidPicTarget(pVidPicTarget) + ")")
      clearPicture(pVidPicTarget, #False, "", 0, #True)
      
    EndIf
    
  EndWith
  
EndProcedure

Procedure showMyVideoFrame(pAudPtr, nPos, bCalledBySAM=#False)
  ; PROCNAMECA(pAudPtr)
  
  ; debugMsg(sProcName, #SCS_START + ", \nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState) + ", nPos=" + nPos)
  
  If pAudPtr = nEditAudPtr
    If pAudPtr >= 0
      If aAud(pAudPtr)\nAudState <> #SCS_CUE_ERROR
        Select grVideoDriver\nVideoPlaybackLibrary
          Case #SCS_VPL_VMIX
            CompilerIf #c_vMix_in_video_cues
              ; debugMsg(sProcName, "calling vMix_SetPosition(" + getAudLabel(pAudPtr) + ", " + nPos + ")")
              vMix_SetPosition(pAudPtr, nPos)
            CompilerEndIf
          Default
            If nPos = aAud(pAudPtr)\nAbsStartAt
              WQA_drawPreviewImage2()
            Else
              WQA_drawPreviewPosImage2(nPos)
            EndIf
        EndSelect
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure playResFile(nDevNo, nResId, sResType.s, fBVLevel.f, fPan.f)
  ; Modified 4May2022 11.9.1 to support fPan
  PROCNAMEC()
  Protected nBassError.l, nResult.l, nBassResult.l
  Protected nMyDataPtr, nMyDataLength, nMyResChan.l, nMySpeaker
  Protected nMyResEndSync
  Protected nFlags
  Protected nDevMapDevPtr
  Protected sMyLogicalDev.s
  Protected nMixerStreamPtr = -2
  Protected nMixerStreamHandle.l, nMixerChannelFlags.l, nBassSpeaker.l
  
  nBassError = #BASS_OK
  
  sMyLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nDevNo)\sLogicalDev
  nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sMyLogicalDev)
  If nDevMapDevPtr < 0
    ProcedureReturn -100
  EndIf
  
  With grMapsForDevChgs\aDev(nDevMapDevPtr)
    If nResId = 1
      ; nMyDataPtr = nSilenceDataPtr
      ; nMyDataLength = nSilenceDataLength
      ; nMyResChan = \nSilenceChan
    ElseIf nResId = 3
      nMyDataPtr = ?sine_wave_test_tone_file                                    ; changed 3May2022pm 11.9.1
      nMyDataLength = ?sine_wave_test_tone_file_end - ?sine_wave_test_tone_file ; changed 3May2022pm 11.9.1
      nMyResChan = \nTestToneChan
    ElseIf nResId = 4 ; Added 3May2022pm 11.9.1
      nMyDataPtr = ?pink_noise_test_tone_file
      nMyDataLength = ?pink_noise_test_tone_file_end - ?pink_noise_test_tone_file
      nMyResChan = \nTestToneChan
    EndIf
    nMySpeaker = \nBassSpeakerFlags
    nResult = BASS_SetDevice(\nBassDevice)
    debugMsg2(sProcName, "BASS_SetDevice(" + \nBassDevice + ")", nResult)
    
    If (nMyDataLength = 0)
      ProcedureReturn -101
    EndIf
    
    ;free old stream (if any)
    If nMyResChan <> 0
      nResult = BASS_StreamFree(nMyResChan)
      debugMsg2(sProcName, "BASS_StreamFree(" + nMyResChan + ")", nResult)
      freeHandle(nMyResChan)
    EndIf
    
    If gbUseBASSMixer
      ;read data from memory location
      nFlags = #BASS_SAMPLE_LOOP | #BASS_STREAM_DECODE ; modified 4May2022 11.9.1
      nMyResChan = BASS_StreamCreateFile(#BASSTRUE, nMyDataPtr, 0, nMyDataLength, nFlags)
      newHandle(#SCS_HANDLE_SOURCE, nMyResChan)
      debugMsg2(sProcName, "BASS_StreamCreateFile(BASSTRUE, " + nMyDataPtr + ", 0, " + nMyDataLength + ", " + decodeStreamCreateFlags(nFlags) + ")", nMyResChan)
      If nMyResChan = 0
        nBassError = BASS_ErrorGetCode()
        ; don't display error as that will be displayed by calling sub or function
      Else
        ; Added 28Sep2022 11.9.6
        If fBVLevel <= grLevels\fMinBVLevel
          fBVLevel = 0.0
        EndIf
        ; End added 28Sep2022 11.9.6
        If fBVLevel <> 0.0
          nResult = BASS_ChannelSetAttribute(nMyResChan, #BASS_ATTRIB_VOL, fBVLevel)
          debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nMyResChan) + ", BASS_ATTRIB_VOL, " + traceLevel(fBVLevel) + ")", nResult)
        EndIf
        ; Added 4May2022 11.9.1
        nResult = BASS_ChannelSetAttribute(nMyResChan, #BASS_ATTRIB_PAN, fPan)
        debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nMyResChan) + ", BASS_ATTRIB_PAN, " + formatPan(fPan) + ")", nResult)
        ; End added 4May2022 11.9.1
        nMixerStreamPtr = getMixerStreamPtrForLogicalDev(sMyLogicalDev)
        If nMixerStreamPtr >= 0
          nMixerStreamHandle = gaMixerStreams(nMixerStreamPtr)\nMixerStreamHandle
          nMixerChannelFlags | #BASS_MIXER_CHAN_NORAMPIN | #BASS_MIXER_CHAN_BUFFER | nBassSpeaker
          nBassResult = BASS_Mixer_StreamAddChannel(nMixerStreamHandle, nMyResChan, nMixerChannelFlags)
          debugMsg2(sProcName, "BASS_Mixer_StreamAddChannel(" + decodeHandle(nMixerStreamHandle) + ", " + decodeHandle(nMyResChan) + ", " + decodeStreamCreateFlags(nMixerChannelFlags, #False, #True) + ")", nBassResult)
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
          nBassResult = BASS_ChannelUpdate(nMixerStreamHandle, 0)
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
          debugMsg2(sProcName, "BASS_ChannelUpdate(" + decodeHandle(nMixerStreamHandle) + ", 0)", nBassResult)
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
          nBassResult = BASS_Mixer_ChannelFlags(nMyResChan, 0, 0)
          debugMsg3(sProcName, "BASS_Mixer_ChannelFlags(" + decodeHandle(nMyResChan) + ", 0, 0) returned " + decodeMixerChannelFlags(nBassResult))
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
        EndIf
      EndIf
      
    Else ; gbUseBASSMixer = #False
      ;read data from memory location
      nFlags = nMySpeaker | #BASS_SAMPLE_LOOP
      nMyResChan = BASS_StreamCreateFile(#BASSTRUE, nMyDataPtr, 0, nMyDataLength, nFlags)
      newHandle(#SCS_HANDLE_SOURCE, nMyResChan)
      debugMsg2(sProcName, "BASS_StreamCreateFile(BASSTRUE, " + nMyDataPtr + ", 0, " + nMyDataLength + ", " + decodeStreamCreateFlags(nFlags) + ")", nMyResChan)
      If nMyResChan = 0
        nBassError = BASS_ErrorGetCode()
        ; don't display error as that will be displayed by calling sub or function
      Else
        ; Added 28Sep2022 11.9.6
        If fBVLevel <= grLevels\fMinBVLevel
          fBVLevel = 0.0
        EndIf
        ; End added 28Sep2022 11.9.6
        If fBVLevel <> 0.0
          nResult = BASS_ChannelSetAttribute(nMyResChan, #BASS_ATTRIB_VOL, fBVLevel)
          debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nMyResChan) + ", BASS_ATTRIB_VOL, " + traceLevel(fBVLevel) + ")", nResult)
        EndIf
        ; Added 4May2022 11.9.1
        nResult = BASS_ChannelSetAttribute(nMyResChan, #BASS_ATTRIB_PAN, fPan)
        debugMsg2(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nMyResChan) + ", BASS_ATTRIB_PAN, " + formatPan(fPan) + ")", nResult)
        ; End added 4May2022 11.9.1
        If \bNoDevice = #False
          nResult = BASS_ChannelPlay(nMyResChan, #BASSFALSE)
          debugMsg2(sProcName, "BASS_ChannelPlay(" + decodeHandle(nMyResChan) + ", BASSFALSE)", nResult)
        EndIf
      EndIf
    EndIf
    
    If nResId = 1
      ; \nSilenceChan = nMyResChan
    ElseIf nResId = 3 Or nResId = 4
      \nTestToneChan = nMyResChan
      debugMsg(sProcName, "changing gaDevForDevChgs(" + nDevMapDevPtr + ")\nMixerStreamPtr from " + \nMixerStreamPtr + " to " + nMixerStreamPtr)
      \nMixerStreamPtr = nMixerStreamPtr
    EndIf
  EndWith
  
  ProcedureReturn nBassError

EndProcedure

Procedure setLevelsVideo(pAudPtr, nDev, fBVLevel.f, fPan.f, pVidPicTarget)
  PROCNAMEC()
  Protected nChannel.l
  Protected nVideoLevel.l, nVideoPan.l, fVideoPan.f, fVideoLevelSingle.f
  Protected nMyVidPicTarget
  Protected nSubPtr
  Protected fDBLevel.f
  Protected bGaplessStream
  Protected nMaxVideoLevel, nMaxPanLeft, nMaxPanRight
  Protected nTVGIndex, nVidAudDevPtr
  Protected fOutputGain.f
  
  CompilerIf #cTraceSetLevels ; And 1=2
    debugMsg3(sProcName, #SCS_START + ", pAudPtr=" + getAudLabel(pAudPtr) + ", nDev=" + nDev + ", fBVLevel=" + traceLevel(fBVLevel) + ", fPan=" + formatPan(fPan) +
                         ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  CompilerEndIf
  
  If pVidPicTarget = #SCS_VID_PIC_TARGET_NONE
    ; may be caused by trying to set level of a video that has just been closed
    ProcedureReturn
  EndIf
  
  With aAud(pAudPtr)
    nSubPtr = \nSubIndex
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nTVGIndex = \nMainTVGIndex
      Case #SCS_VID_PIC_TARGET_P
        nTVGIndex = \nPreviewTVGIndex
      Default
        ; shouldn't get here
        nTVGIndex = -1
    EndSelect
;     debugMsg(sProcName, "\nMainTVGIndex=" + \nMainTVGIndex + ", \nPreviewTVGIndex=" + \nPreviewTVGIndex + ", nTVGIndex=" + nTVGIndex)
    
    If aSub(nSubPtr)\bMuteVideoAudio
      ; debugMsg(sProcName, "exiting because aSub(" + getSubLabel(nSubPtr) + ")\bMuteVideoAudio=" + strB(aSub(nSubPtr)\bMuteVideoAudio))
      ProcedureReturn
    EndIf
    
    nMyVidPicTarget = pVidPicTarget
    If nMyVidPicTarget = #SCS_VID_PIC_TARGET_UNKNOWN
      If aSub(nSubPtr)\bStartedInEditor
        nMyVidPicTarget = #SCS_VID_PIC_TARGET_P
      Else
        nMyVidPicTarget = \nAudVidPicTarget
      EndIf
    EndIf
    
    nChannel = getAudVideoChannelForTarget(pAudPtr, nMyVidPicTarget)
    bGaplessStream = \bAudUseGaplessStream
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        nMaxVideoLevel = 65535
        nMaxPanLeft = -32767
        nMaxPanRight = 32767
        fOutputGain = getOutputGainForDev(\nSubIndex)
      Default
        nMaxVideoLevel = 100
        nMaxPanLeft = -100
        nMaxPanRight = 100
        fOutputGain = 1.0
    EndSelect
    
    If fBVLevel <> #SCS_NOVOLCHANGE_SINGLE
      nVideoLevel = Round(fBVLevel * nMaxVideoLevel * grMasterLevel\fVideoVolumeFactor * fOutputGain, #PB_Round_Nearest)  ; grMasterLevel\fVideoVolumeFactor set from Master Fader
;       debugMsg3(sProcName, ">>> fBVLevel=" + traceLevel(fBVLevel) + ", grMasterLevel\fVideoVolumeFactor=" + StrF(grMasterLevel\fVideoVolumeFactor,4) + ", fOutputGain=" + StrF(fOutputGain,4) + ", nVideoLevel=" + nVideoLevel)
      
      \fCueVolNow[nDev] = fBVLevel  ; store fCueVolNow as getting volume and rescaling is not precise enough - level fader jumps around
      \fCueTotalVolNow[nDev] = fBVLevel
      ; debugMsg(sProcName, "(1) aAud(" + getAudLabel(pAudPtr) + ")\fCueVolNow[" + nDev + "]=" + formatLevel(\fCueVolNow[nDev]))
      If nVideoLevel < 0
        nVideoLevel = 0
      ElseIf nVideoLevel > nMaxVideoLevel
        nVideoLevel = nMaxVideoLevel
      EndIf
      If nMyVidPicTarget >= 0
        CheckSubInRange(nMyVidPicTarget, ArraySize(grVidPicTarget()), "grVidPicTarget() pAudPtr=" + getAudLabel(pAudPtr))
        grVidPicTarget(nMyVidPicTarget)\nVolume = nVideoLevel
      EndIf
    Else
      If nMyVidPicTarget >= 0
        nVideoLevel = grVidPicTarget(nMyVidPicTarget)\nVolume
      EndIf
    EndIf
    
    If fPan <> #SCS_NOPANCHANGE_SINGLE
      nVideoPan = Round(fPan * nMaxPanRight, #PB_Round_Nearest)
      \fCuePanNow[nDev] = fPan
      If nVideoPan < nMaxPanLeft
        nVideoPan = nMaxPanLeft
      ElseIf nVideoPan > nMaxPanRight
        nVideoPan = nMaxPanRight
      EndIf
      If nMyVidPicTarget >= 0
        grVidPicTarget(nMyVidPicTarget)\nBalance = nVideoPan
      EndIf
    Else
      If nMyVidPicTarget >= 0
        nVideoPan = grVidPicTarget(nMyVidPicTarget)\nBalance
      EndIf
    EndIf
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        CompilerIf #c_vMix_in_video_cues
          If fBVLevel <> #SCS_NOVOLCHANGE_SINGLE
            fVideoLevelSingle = (fBVLevel * grMasterLevel\fVideoVolumeFactor)  ; grMasterLevel\fVideoVolumeFactor set from Master Fader
            If fVideoLevelSingle < 0.0
              fVideoLevelSingle = 0.0
            ElseIf fVideoLevelSingle > 100.0
              fVideoLevelSingle = 100.0
            EndIf
            vMix_SetLevel(pAudPtr, fVideoLevelSingle)
          EndIf
          If fPan <> #SCS_NOPANCHANGE_SINGLE
            vMix_SetPan(pAudPtr, fPan)
          EndIf
        CompilerEndIf
        
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          If nMyVidPicTarget >= 0
            If nChannel > 0
              nVidAudDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_AUDIO, aSub(nSubPtr)\sVidAudLogicalDev)
              If fBVLevel <> #SCS_NOVOLCHANGE_SINGLE
                nVideoLevel = (fBVLevel * nMaxVideoLevel * grMasterLevel\fVideoVolumeFactor * fOutputGain)  ; grMasterLevel\fVideoVolumeFactor set from Master Fader
                If nVideoLevel < 0
                  nVideoLevel = 0
                ElseIf nVideoLevel > nMaxVideoLevel
                  nVideoLevel = nMaxVideoLevel
                EndIf
                If nTVGIndex >= 0
                  TVG_SetAudioVolume(*gmVideoGrabber(nTVGIndex), nVideoLevel)
                  CompilerIf #cTraceSetLevels
                    debugMsgT(sProcName, "TVG_SetAudioVolume(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", " + nVideoLevel + ")")
                  CompilerEndIf
                EndIf
              EndIf
              If fPan <> #SCS_NOPANCHANGE_SINGLE
                TVG_SetAudioBalance(*gmVideoGrabber(nTVGIndex), nVideoPan)
                CompilerIf #cTraceSetLevels
                  debugMsgT(sProcName, "TVG_SetAudioBalance(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", " + nVideoPan + ")")
                CompilerEndIf
              EndIf
            EndIf
          EndIf
        CompilerEndIf
        
   EndSelect
    
  EndWith
  
EndProcedure

Procedure setAlphaBlend(pAudPtr, pReqdAlphaBlend)
  PROCNAMEC()
  Protected nMyAlphaBlend.l
  Protected nTVGIndex, nHandle.i, nDisplayIndex.l
  
  ; AlphaBlend standard (as documented by Microsoft): 0 = the image is transparent; 255 = the image is opaque.
  ; In relation to fade-in and fade-out, 0 = black (image is transparent over a black background), and 255 = fully displayed.
  
  If (gbInSetAlphaBlend) Or (pAudPtr < 0)
    debugMsg(sProcName, "exiting: gbInSetAlphaBlend=" + strB(gbInSetAlphaBlend) + ", pAudPtr=" + getAudLabel(pAudPtr))
    ProcedureReturn
  EndIf
  gbInSetAlphaBlend = #True
  
  CompilerIf #cTraceAlphaBlend
    debugMsg(sProcName, #SCS_START + ", pAudPtr=" + getAudLabel(pAudPtr) + ", nReqdAlphaBlend=" + pReqdAlphaBlend)
  CompilerEndIf

  With aAud(pAudPtr)
    
    If (\nFileFormat = #SCS_FILEFORMAT_VIDEO) Or (\nFileFormat = #SCS_FILEFORMAT_PICTURE And grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG)
      
      Select \nVideoPlaybackLibrary
        Case #SCS_VPL_TVG
          CompilerIf #c_include_tvg
            nTVGIndex = getTVGIndexForAud(pAudPtr, \nAudVidPicTarget)
            ; debugMsg(sProcName, "getTVGIndexForAud(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(\nAudVidPicTarget) + ") returned " + nTVGIndex)
            If nTVGIndex >= 0
              CompilerIf #cTraceAlphaBlend
                debugMsg(sProcName, "gaTVG(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")\bTopMostWindowForTarget=" + strB(gaTVG(nTVGIndex)\bTopMostWindowForTarget) +
                                    ", aAud(" + getAudLabel(pAudPtr) + ")\bInForcedFadeOut=" + strB(\bInForcedFadeOut))
              CompilerEndIf
              If (gaTVG(nTVGIndex)\bTopMostWindowForTarget) Or (\bInForcedFadeOut)
                nMyAlphaBlend = pReqdAlphaBlend
                If nMyAlphaBlend < 0
                  nMyAlphaBlend = 0
                ElseIf nMyAlphaBlend > 255
                  nMyAlphaBlend = 255
                EndIf
                If nMyAlphaBlend <> \nAlphaBlend
                  nHandle = *gmVideoGrabber(nTVGIndex)
                  TVG_SetDisplayAlphaBlendValue(nHandle, 0, nMyAlphaBlend)
                  CompilerIf #cTraceAlphaBlend
                    debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + decodeHandle(nHandle) + ", 0, " + nMyAlphaBlend + "), delta=" + Str(nMyAlphaBlend - \nAlphaBlend))
                  CompilerEndIf
                  If gaTVG(nTVGIndex)\bDualDisplayActive
                    TVG_SetDisplayAlphaBlendValue(nHandle, 1, nMyAlphaBlend)
                    CompilerIf #cTraceAlphaBlend
                      debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + decodeHandle(nHandle) + ", 1, " + nMyAlphaBlend + ")")
                    CompilerEndIf
                  EndIf
                  For nDisplayIndex = 2 To 8
                    If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
                      TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, nMyAlphaBlend)
                      CompilerIf #cTraceAlphaBlend
                        debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + decodeHandle(nHandle) + ", " + nDisplayIndex + ", " + nMyAlphaBlend + ")")
                      CompilerEndIf
                    EndIf
                  Next nDisplayIndex
;                   CompilerIf (#cTraceAlphaBlend)
;                     debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + decodeHandle(nHandle) + ", 0, " + nMyAlphaBlend + "), delta=" + Str(nMyAlphaBlend - \nAlphaBlend))
;                   CompilerEndIf
                  \nAlphaBlend = pReqdAlphaBlend
                EndIf
              EndIf
            EndIf
          CompilerEndIf
          
      EndSelect
      
    EndIf ; EndIf \nFileFormat = #SCS_FILEFORMAT_VIDEO
    
  EndWith
  
  gbInSetAlphaBlend = #False
  
EndProcedure

Procedure closeVideo(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n, nMainVidPicTarget, nPreviewVidPicTarget
  Protected bLockedMutex
  Protected bSkipHidePicture
  Protected bForceFreeVideo ; used for vMixFreeVideo()
  Protected nActiveWindow
  Protected nMainTVGIndex, nPreviewTVGIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  nMainVidPicTarget = -1
  nPreviewVidPicTarget = -1
  
  LockImageMutex(255)
  
  nActiveWindow = GetActiveWindow()
  
  With aAud(pAudPtr)
    
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary) + ", \nAudVidPicTarget=" + decodeVidPicTarget(\nAudVidPicTarget) + ", \svMixInputKey=" + \svMixInputKey)
    
    ; debugMsg(sProcName, "\nMainVideoNo=" + \nMainVideoNo)
    ; debugMsg(sProcName, "ArraySize(grVidPicTarget())=" + ArraySize(grVidPicTarget()))
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_TVG, #SCS_VPL_VMIX
        debugMsg(sProcName, "\nMainVideoNo=" + decodeHandle(\nMainVideoNo) + ", \nPreviewVideoNo=" + decodeHandle(\nPreviewVideoNo))
        For n = 0 To ArraySize(grVidPicTarget())
          If \nMainVideoNo <> 0
            If grVidPicTarget(n)\nMovieNo = \nMainVideoNo
              debugMsg(sProcName, "\nMainVideoNo=" + decodeHandle(\nMainVideoNo) + ", grVidPicTarget(" + decodeVidPicTarget(n) + ")\nMovieNo=" + decodeHandle(grVidPicTarget(n)\nMovieNo))
              grVidPicTarget(n)\nMovieNo = 0
              ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nMovieNo=0")
              grVidPicTarget(n)\sMovieFileName = ""
              grVidPicTarget(n)\nMovieAudPtr = -1
              nMainVidPicTarget = n
            EndIf
          EndIf
          If \nPreviewVideoNo <> 0
            If grVidPicTarget(n)\nMovieNo = \nPreviewVideoNo
              debugMsg(sProcName, "\nPreviewVideoNo=" + decodeHandle(\nPreviewVideoNo) + ", grVidPicTarget(" + decodeVidPicTarget(n) + ")\nMovieNo=" + decodeHandle(grVidPicTarget(n)\nMovieNo))
              grVidPicTarget(n)\nMovieNo = 0
              ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nMovieNo=0")
              grVidPicTarget(n)\sMovieFileName = ""
              grVidPicTarget(n)\nMovieAudPtr = -1
              nPreviewVidPicTarget = #SCS_VID_PIC_TARGET_P
            EndIf
          EndIf
        Next n
        
    EndSelect
    ; debugMsg(sProcName, "nMainVidPicTarget=" + decodeVidPicTarget(nMainVidPicTarget) + ", nPreviewVidPicTarget=" + decodeVidPicTarget(nPreviewVidPicTarget))
    ; debugMsg(sProcName, "\nMainVideoNo=" + decodeHandle(\nMainVideoNo) + ", \nPreviewVideoNo=" + decodeHandle(\nPreviewVideoNo))
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_VMIX
        CompilerIf #c_vMix_in_video_cues
          If \svMixInputKey
            If gbStoppingEverything Or gbInGoToCue Or gbClosingDown
              bForceFreeVideo = #True
            EndIf
            ; debugMsg(sProcName, "calling vMix_RemoveInput(" + getAudLabel(pAudPtr) + ", " + strB(bForceFreeVideo) + ")")
            vMix_RemoveInput(pAudPtr, bForceFreeVideo)
          EndIf
        CompilerEndIf

      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          If nMainVidPicTarget = -1
            nMainVidPicTarget = \nAudVidPicTarget
          EndIf
          If nMainVidPicTarget >= 0
            nMainTVGIndex = getTVGIndexForAud(pAudPtr, nMainVidPicTarget)
            If nMainTVGIndex >= 0
              ; debugMsg(sProcName, "calling freeTVGControl(" + decodeHandle(*gmVideoGrabber(nMainTVGIndex)) + ")")
              freeTVGControl(nMainTVGIndex)
            EndIf
          EndIf
          If (gbClosingDown = #False) And (gbStoppingEverything = #False)
            ; debugMsg(sProcName, "calling hideMonitorsNotInUse()")
            hideMonitorsNotInUse()
          EndIf
        CompilerEndIf
        
    EndSelect
    \nMainVideoNo = 0
    If (nMainVidPicTarget >= 0) And (gbClosingDown = #False)
      If bSkipHidePicture = #False
        ; debugMsg(sProcName, "calling hidePicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nMainVidPicTarget) + ")")
        hidePicture(pAudPtr, nMainVidPicTarget)
      EndIf
    EndIf
    
    Select \nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          nPreviewVidPicTarget = #SCS_VID_PIC_TARGET_P
          nPreviewTVGIndex = getTVGIndexForAud(pAudPtr, nPreviewVidPicTarget)
          If nPreviewTVGIndex >= 0
            ; debugMsg(sProcName, "calling freeTVGControl(" + decodeHandle(*gmVideoGrabber(nPreviewTVGIndex)) + ")")
            freeTVGControl(nPreviewTVGIndex, #True)
          EndIf
        CompilerEndIf
    EndSelect
    \nPreviewVideoNo = 0
    ; debugMsg(sProcName, "\nPreviewVideoNo=" + \nPreviewVideoNo)
    If grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG
      If (nPreviewVidPicTarget >= 0) And (gbClosingDown = #False)
        ; debugMsg(sProcName, "calling hidePicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nPreviewVidPicTarget) + ")")
        hidePicture(pAudPtr, nPreviewVidPicTarget)
      EndIf
    EndIf
    
    aAud(pAudPtr)\nAudVidPicTarget = #SCS_VID_PIC_TARGET_NONE
    \nFileState = grAudDef\nFileState
    If \nAudState < #SCS_CUE_COMPLETED
      \nAudState = #SCS_CUE_NOT_LOADED
      setCueState(\nCueIndex)
    EndIf
    
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudVidPicTarget=" + decodeVidPicTarget(aAud(pAudPtr)\nAudVidPicTarget) + ", \nFileState=" + decodeFileState(\nFileState) + ", \nAudState=" + decodeCueState(\nAudState))
    
    If \bAudTypeA
      ; debugMsg(sProcName, "calling hideMonitorsNotInUse()")
      hideMonitorsNotInUse()
    EndIf
    
  EndWith
  
  UnlockImageMutex()

  If gbClosingDown = #False
    If IsWindow(nActiveWindow)
      SAW(nActiveWindow)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getFileFormat(sFileName.s, bTrace=#False)
  PROCNAMEC()
  Protected sFileExt.s, sStringToFind.s, sWorkString.s
  Protected nFileFormat
  Protected bIsVideoCapture
  
  debugMsgC(sProcName, #SCS_START + ", sFileName=" + sFileName)
  
  If sFileName = grText\sTextPlaceHolder
    nFileFormat = #SCS_FILEFORMAT_AUDIO
    debugMsgC(sProcName, "returning " + decodeFileFormat(nFileFormat))
    ProcedureReturn nFileFormat
  EndIf
  
  sFileExt = LCase(GetExtensionPart(sFileName))
  ; debugMsgC(sProcName, "sFileExt=" + sFileExt)
  sStringToFind = "," + sFileExt + ","
  ; debugMsgC(sProcName, "sFileName=" + GetFilePart(sFileName) + ", sFileExt=" + sFileExt + "; gsAudioFileTypes=" + gsAudioFileTypes + "; gsVideoImageFileTypes=" + gsVideoImageFileTypes)
  
  sWorkString = "," + LCase(gsAudioFileTypes) + ","
  If FindString(sWorkString, sStringToFind, 1) > 0
    nFileFormat = #SCS_FILEFORMAT_AUDIO
    debugMsgC(sProcName, "returning " + decodeFileFormat(nFileFormat))
    ProcedureReturn nFileFormat
  EndIf
  
  sWorkString = "," + LCase(gsMidiFileTypes) + ","
  If FindString(sWorkString, sStringToFind, 1) > 0
    nFileFormat = #SCS_FILEFORMAT_MIDI
    debugMsgC(sProcName, "returning " + decodeFileFormat(nFileFormat))
    ProcedureReturn nFileFormat
  EndIf
  
  sWorkString = "," + LCase(gsVideoImageFileTypes) + ","
  If FindString(sWorkString, sStringToFind, 1) > 0
    Select sFileExt
      ; see also setFileTypeList()
      Case "bmp", "jpg", "jpeg", "jp2", "jpx", "png", "gif"
        nFileFormat = #SCS_FILEFORMAT_PICTURE
      Default
        nFileFormat = #SCS_FILEFORMAT_VIDEO
    EndSelect
    debugMsgC(sProcName, "returning " + decodeFileFormat(nFileFormat))
    ProcedureReturn nFileFormat
  EndIf
  
  debugMsgC(sProcName, "returning " + decodeFileFormat(nFileFormat))
  ProcedureReturn #SCS_FILEFORMAT_UNKNOWN
EndProcedure

Procedure.s decodeFileFormat(nFileFormat)
  Protected sFileFormat.s
  
  Select nFileFormat
    Case #SCS_FILEFORMAT_UNKNOWN
      sFileFormat = "Unknown"
    Case #SCS_FILEFORMAT_AUDIO
      sFileFormat = "Audio"
    Case #SCS_FILEFORMAT_CAPTURE
      sFileFormat = "Capture"
    Case #SCS_FILEFORMAT_MIDI
      sFileFormat = "MIDI"
    Case #SCS_FILEFORMAT_VIDEO
      sFileFormat = "Video"
    Case #SCS_FILEFORMAT_PICTURE
      sFileFormat = "Picture"
    Case #SCS_FILEFORMAT_LIVE_INPUT
      sFileFormat = "Live Input"
    Default
      sFileFormat = Str(nFileFormat)
  EndSelect
  ProcedureReturn sFileFormat
EndProcedure

Procedure GetShellThumbnail(FileName$, Image, Width, Height, Depth = #PB_Image_DisplayFormat)
  PROCNAMEC()
  ; code supplied by Freak in PB Forum topic 'Get the Shell Thumbnail for files' dated 30 March 2006
  ; warning! code as supplied displays thumbnail upside down - will need to invert the images
  ; code modified for SCS, eg returning image number instead of return value from PB CreateImage()
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected result = 0, ImageResult
    Protected Desktop.IShellFolder, Folder.IShellFolder
    Protected Extract.IExtractImage
    Protected *pidlFolder.ITEMIDLIST, *pidlFile.ITEMIDLIST  
    Protected priority, flags, hBitmap = 0, size.SIZE
    Protected bm.BITMAP
    Protected nLeft, nTop
    
    debugMsg(sProcName, "FileName$=" + FileName$)
    CoInitialize_(0)
    If SHGetDesktopFolder_(@Desktop) >= 0
      If Desktop\ParseDisplayName(#Null, #Null, GetPathPart(FileName$), #Null, @*pidlFolder, #Null) = #S_OK
        If Desktop\BindToObject(*pidlFolder, #Null, ?IID_IShellFolder, @Folder) = #S_OK
          If Folder\ParseDisplayName(#Null, #Null, GetFilePart(FileName$) , #Null, @*pidlFile, #Null) = #S_OK
            If Folder\GetUIObjectOf(#Null, 1, @*pidlFile, ?IID_IExtractImage, 0, @Extract) = #S_OK
              ImageResult = CreateImage(Image, Width, Height, Depth)
              logCreateImage(3, Image, nEditAudPtr, #SCS_VID_PIC_TARGET_T, "thumbnail image")
              If ImageResult
                If Image = #PB_Any
                  Image = ImageResult
                EndIf   
                If Depth = #PB_Image_DisplayFormat 
                  Depth = ImageDepth(Image)
                EndIf
                
                size\cx = Width
                size\cy = Height
                
                If Extract\GetLocation(Space(#MAX_PATH), #MAX_PATH, @priority, @size, Depth, @flags) >= 0                
                  If (Extract\Extract(@hBitmap) >= 0) And (hBitmap)
                    GetObject_(hBitmap, SizeOf(BITMAP), @bm)
                    If bm\bmWidth < Width
                      nLeft = (Width - bm\bmWidth) >> 1
                    EndIf
                    If bm\bmHeight < Height
                      nTop = (Height - bm\bmHeight) >> 1
                    EndIf
                    debugMsg(sProcName, "FileName$=" + GetFilePart(FileName$) + ", Width=" + Width + ", bm\bmWidth=" + bm\bmWidth + ", nLeft=" + nLeft + ", Height=" + Height + ", bm\bmHeight=" + bm\bmHeight + ", nTop=" + nTop)
                    If StartDrawing(ImageOutput(Image))
                      DrawImage(hBitmap, nLeft, nTop)
                      StopDrawing()                    
                      result = ImageResult
                    EndIf
                    DeleteObject_(hBitmap)
                  EndIf
                EndIf                
                Extract\Release()
              EndIf
              
              If result = 0
                FreeImage(Image)
                debugMsg3(sProcName, "FreeImage(" + Image + ")")
                logFreeImage(3, Image)
              EndIf            
            EndIf
            
            CoTaskMemFree_(*pidlFile)
          EndIf                       
          Folder\Release()
        EndIf     
        CoTaskMemFree_(*pidlFolder)      
      EndIf    
      Desktop\Release()
    EndIf
    CoUninitialize_()
    
    ProcedureReturn result
    
    DataSection  
      IID_IShellFolder: ; {000214E6-0000-0000-C000-000000000046}
      Data.l $000214E6
      Data.w $0000, $0000
      Data.b $C0, $00, $00, $00, $00, $00, $00, $46
      
      IID_IExtractImage: ; {BB2E617C-0920-11D1-9A0B-00C04FC2D6C1}
      Data.l $BB2E617C
      Data.w $0920, $11D1
      Data.b $9A, $0B, $00, $C0, $4F, $C2, $D6, $C1
    EndDataSection  
  CompilerEndIf
EndProcedure

Procedure freeAudImages(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nVidPicTarget
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      condFreeImage(\nImageAfterRotateAndFlip, #PB_Compiler_Line)
      \nImageAfterRotateAndFlip = 0
      condFreeImage(\nLoadImageNo, #PB_Compiler_Line)
      \nLoadImageNo = 0
      If \bLogo = #False
        For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          condFreeImage(\nVidPicTargetImageNo(nVidPicTarget), #PB_Compiler_Line)
          \nVidPicTargetImageNo(nVidPicTarget) = 0
        Next nVidPicTarget
      EndIf
      condFreeImage(\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_T), #PB_Compiler_Line)
      \nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_T) = 0
      condFreeImage(\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_P), #PB_Compiler_Line)
      \nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_P) = 0
      condFreeImage(\nThumbnailImageNo, #PB_Compiler_Line)
      \nThumbnailImageNo = 0
      condFreeImage(\nPosImageAfterRotateAndFlip, #PB_Compiler_Line)
      \nPosImageAfterRotateAndFlip = 0
      condFreeImage(\nMemoryImageNo, #PB_Compiler_Line)
      \nMemoryImageNo = 0
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure logCreateImage(nCallPointForCreate, nImageNo, nAudPtr=-1, nVidPicTarget=#SCS_VID_PIC_TARGET_NONE, sComment.s="", sExtraInfo.s="")
  PROCNAMEC()
  Protected nArraySize
  
  gnMaxImageNo + 1
  nArraySize = ArraySize(gaImageLog())
  If gnMaxImageNo > nArraySize
    ReDim gaImageLog(gnMaxImageNo+100)
  EndIf
  With gaImageLog(gnMaxImageNo)
    \nImageNo = nImageNo
    \qCreated = ElapsedMilliseconds()
    \nCallPointForCreate = nCallPointForCreate
    \nAudPtr = nAudPtr
    \nVidPicTarget = nVidPicTarget
    \sComment = sComment
    If IsImage(nImageNo)
      \nImageId = ImageID(nImageNo)
      newHandle(#SCS_HANDLE_IMAGE, nImageNo, #False, sExtraInfo)
      debugMsg(sProcName, "(" + nCallPointForCreate + ", " + nImageNo + "[" + decodeHandle(nImageNo) + "]" +", Width=" + ImageWidth(nImageNo) + ", Height=" + ImageHeight(nImageNo) + ", " + getAudLabel(nAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ", " + sComment + ")")
    Else
      \nImageId = 0
      debugMsg(sProcName, "(" + nCallPointForCreate + ", " + nImageNo + ", " + getAudLabel(nAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ", " + sComment + ")")
    EndIf
  EndWith
  
EndProcedure

Procedure logFreeImage(nCallPointForFree, nImageNo)
  PROCNAMEC()
  Protected n, bFound
  
  debugMsg(sProcName, "(" + nCallPointForFree + ", " + decodeHandle(nImageNo) + ")")
  For n = 1 To gnMaxImageNo
    With gaImageLog(n)
      If (\nImageNo = nImageNo) And (\qFreed = 0)
        \qFreed = ElapsedMilliseconds()
        \nCallPointForFree = nCallPointForFree
        bFound = #True
        Break
      EndIf
    EndWith
  Next n
  If bFound = #False
    debugMsg(sProcName, "nImageNo not found: " + decodeHandle(nImageNo))
  EndIf
  
EndProcedure

Procedure listImageLog()
  PROCNAMEC()
  Protected sMsg.s, n
  Protected nFreeCount, nAssignedCount
  
  For n = 1 To gnMaxImageNo
    With gaImageLog(n)
      If \qFreed <> 0
        If nFreeCount = 0
          debugMsg(sProcName, "---------------- Freed Images ----------------")
        EndIf
        nFreeCount + 1
        sMsg = "\nImageNo(" + n + ")=" + decodeHandle(\nImageNo)
        sMsg + ", \nImageId=" + \nImageId
        sMsg + ", \qCreated=" + traceTime(\qCreated) + "(" + \nCallPointForCreate + ")"
        If \nAudPtr >= 0
          sMsg + ", \nAudPtr=" + getAudLabel(\nAudPtr)
        EndIf
        If \nVidPicTarget <> #SCS_VID_PIC_TARGET_NONE
          sMsg + ", \nVidPicTarget=" + decodeVidPicTarget(\nVidPicTarget)
        EndIf
        sMsg + ", \qFreed=" + traceTime(\qFreed) + "(" + \nCallPointForFree + ")" + " FREE"
        sMsg + ", IsImage()=" + strB(IsImage(\nImageNo))
        If \sComment
          sMsg + ", " + \sComment
        EndIf
        debugMsg(sProcName, sMsg)
      EndIf
    EndWith
  Next n
  
  For n = 1 To gnMaxImageNo
    With gaImageLog(n)
      If \qFreed = 0
        If nAssignedCount = 0
          debugMsg(sProcName, "---------------- Assigned Images ----------------")
        EndIf
        nAssignedCount + 1
        sMsg = "\nImageNo(" + n + ")=" + decodeHandle(\nImageNo)
        sMsg + ", \nImageId=" + Str(\nImageId)
        sMsg + ", \qCreated=" + traceTime(\qCreated) + "(" + Str(\nCallPointForCreate) + ")"
        If \nAudPtr >= 0
          sMsg + ", \nAudPtr=" + getAudLabel(\nAudPtr)
        EndIf
        If \nVidPicTarget <> #SCS_VID_PIC_TARGET_NONE
          sMsg + ", \nVidPicTarget=" + decodeVidPicTarget(\nVidPicTarget)
        EndIf
        sMsg + ", IsImage()=" + strB(IsImage(\nImageNo))
        If \sComment
          sMsg + ", " + \sComment
        EndIf
        debugMsg(sProcName, sMsg)
      EndIf
    EndWith
  Next n
EndProcedure

Procedure adjustLevelOfPlayingCues(nDirection, bLastPlayingAudioCueOnly=#False)
  PROCNAMEC()
  Protected i, j, k, d, n
  Protected nDispPanel
  Protected fDBLevel.f, fNewLevel.f
  Protected bLevelChanged
  Protected sLevelCaption.s
  Protected fDBIncrement.f
  Protected fNewRelLevel.f
  Protected nFromCue, nUpToCue
  
  debugMsg(sProcName, #SCS_START + ", nDirection=" + nDirection + ", bLastPlayingAudioCueOnly=" + strB(bLastPlayingAudioCueOnly))
  
  If bLastPlayingAudioCueOnly
    debugMsg(sProcName, "gnLastPlayingAudioCue=" + getCueLabel(gnLastPlayingAudioCue))
    If gnLastPlayingAudioCue < 0
      ProcedureReturn
    EndIf
    nFromCue = gnLastPlayingAudioCue
    nUpToCue = gnLastPlayingAudioCue
  Else
    nFromCue = 1
    nUpToCue = gnLastCue
  EndIf
  
  fDBIncrement = ValF(grGeneralOptions\sDBIncrement)
  
  For i = nFromCue To nUpToCue
    If (aCue(i)\nCueState = #SCS_CUE_PLAYING) Or (aCue(i)\nCueState = #SCS_CUE_PAUSED)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          If (aSub(j)\nSubState = #SCS_CUE_PLAYING) Or (aSub(j)\nSubState = #SCS_CUE_PAUSED)
            If aSub(j)\bSubTypeF
              nDispPanel = -1
              For n = 0 To ArraySize(gaDispPanel())
                If (gaDispPanel(n)\nDPCuePtr = i) And (gaDispPanel(n)\nDPSubPtr = j)
                  nDispPanel = n
                  Break
                EndIf
              Next n
              If nDispPanel >= 0
                k = aSub(j)\nFirstAudIndex
                If k >= 0
                  With aAud(k)
                    If \bIncDecLevelSet = #False
                      \fIncDecLevelDelta = (fDBIncrement * nDirection)
                    Else
                      \fIncDecLevelDelta + (fDBIncrement * nDirection)
                    EndIf
                    For d = \nFirstSoundingDev To \nLastSoundingDev
                      If (\sLogicalDev[d]) And (\bIgnoreDev[d] = #False)
                        If \bIncDecLevelSet = #False
                          ; \fIncDecLevelBase[d] = \fBVLevel[d]
                          ; nb must use \fCueTotalVolNow[d], not \fBVLevel[d], so that LCC changes are recognized (email from C.Peters 25/11/2014)
                          \fIncDecLevelBase[d] = \fCueTotalVolNow[d]
                        EndIf
                        If \fIncDecLevelBase[d] > #SCS_MINVOLUME_SINGLE
                          fDBLevel = convertBVLevelToDBLevel(\fIncDecLevelBase[d]) + \fIncDecLevelDelta
                          fNewLevel = convertDBLevelToBVLevel(fDBLevel)
                          If fNewLevel <= grLevels\fMinBVLevel
                            fNewLevel = #SCS_MINVOLUME_SINGLE
                          ElseIf fNewLevel > grLevels\fMaxBVLevel
                            fNewLevel = grLevels\fMaxBVLevel
                          EndIf
                          \bCueVolManual[d] = #True
                          \fBVLevel[d] = fNewLevel
                          setLevelsAny(k, d, fNewLevel, #SCS_NOPANCHANGE_SINGLE)
                          bLevelChanged = #True
                        EndIf
                      EndIf
                    Next d
                    If bLevelChanged
                      If \bAffectedByLevelChange
                        If \nLevelChangeSubPtr >= 0
                          If aSub(\nLevelChangeSubPtr)\nLCAction = #SCS_LC_ACTION_ABSOLUTE ; absolute level change, not relative level change
                            debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nLevelChangeSubPtr) + ")")
                            addToSaveSettings(\nLevelChangeSubPtr)
                            setSaveSettings()
                          EndIf
                        EndIf
                      Else
                        debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nSubIndex) + ")")
                        addToSaveSettings(\nSubIndex)
                        setSaveSettings()
                      EndIf
                    EndIf
                    \bIncDecLevelSet = #True
                  EndWith
                EndIf
              EndIf
              
            ElseIf aSub(j)\bSubTypeP
              k = aSub(j)\nCurrPlayIndex
              nDispPanel = -1
              For n = 0 To ArraySize(gaDispPanel())
                If (gaDispPanel(n)\nDPCuePtr = i) And (gaDispPanel(n)\nDPSubPtr = j) And (gaDispPanel(n)\nDPAudPtr = k)
                  nDispPanel = n
                  Break
                EndIf
              Next n
              If nDispPanel >= 0
                If k >= 0
                  With aAud(k)
                    If \bIncDecLevelSet = #False
                      \fIncDecLevelDelta = (fDBIncrement * nDirection)
                    Else
                      \fIncDecLevelDelta + (fDBIncrement * nDirection)
                    EndIf
                    For d = \nFirstSoundingDev To \nLastSoundingDev
                      If (\sLogicalDev[d]) And (\bIgnoreDev[d] = #False)
                        If \bIncDecLevelSet = #False
                          \fIncDecLevelBase[d] = \fBVLevel[d]
                        EndIf
                        If \fIncDecLevelBase[d] > #SCS_MINVOLUME_SINGLE
                          fDBLevel = convertBVLevelToDBLevel(\fIncDecLevelBase[d]) + \fIncDecLevelDelta
                          fNewLevel = convertDBLevelToBVLevel(fDBLevel)
                          If fNewLevel <= grLevels\fMinBVLevel
                            fNewLevel = #SCS_MINVOLUME_SINGLE
                          ElseIf fNewLevel > grLevels\fMaxBVLevel
                            fNewLevel = grLevels\fMaxBVLevel
                          EndIf
                          fNewRelLevel = fNewLevel * 100.0 / aSub(\nSubIndex)\fSubMastBVLevel[d]
                          debugMsg(sProcName, "aAud(" + getAudLabel(k) + ") fNewLevel=" + traceLevel(fNewLevel) +
                                              ", aSub(" + getSubLabel(\nSubIndex) + ")\fSubMastBVLevel[d]=" + traceLevel(aSub(\nSubIndex)\fSubMastBVLevel[d]) +
                                              ", fNewRelLevel=" + StrF(fNewRelLevel))
                          If fNewRelLevel <= 100.0
                            \bCueVolManual[d] = #True
                            \fBVLevel[d] = fNewLevel
                            setLevelsAny(k, d, fNewLevel, #SCS_NOPANCHANGE_SINGLE)
                            bLevelChanged = #True
                          EndIf
                        EndIf
                      EndIf
                    Next d
                    If bLevelChanged
                      If \bAffectedByLevelChange
                        If \nLevelChangeSubPtr >= 0
                          If aSub(\nLevelChangeSubPtr)\nLCAction = #SCS_LC_ACTION_ABSOLUTE ; absolute level change, not relative level change
                            debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nLevelChangeSubPtr) + ")")
                            addToSaveSettings(\nLevelChangeSubPtr)
                            setSaveSettings()
                          EndIf
                        EndIf
                      Else
                        debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nSubIndex) + ")")
                        addToSaveSettings(\nSubIndex)
                        setSaveSettings()
                      EndIf
                    EndIf
                    \bIncDecLevelSet = #True
                  EndWith
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
EndProcedure

Procedure setScreenWindowsVisible(nScreenNo, bVisible)
  PROCNAMEC()
  Protected nWindowNo
  
  If nScreenNo >= 2
    nWindowNo = #WV2 + (2 - nScreenNo)
    If IsWindow(nWindowNo)
      ; debugMsg(sProcName, "getWindowVisible(" + decodeWindow(nWindowNo) + ")=" + strB(getWindowVisible(nWindowNo)) + ", bVisible=" + strB(getWindowVisible(nWindowNo)))
      If getWindowVisible(nWindowNo) <> bVisible
        debugMsg(sProcName, "calling setWindowVisible(" + decodeWindow(nWindowNo) + ", " + strB(bVisible) + ")")
        setWindowVisible(nWindowNo, bVisible)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure checkFileChanged(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bChanged
  Protected nFileDataPtr
  Protected sFileName.s
  Protected sCurrentFileModified.s
  Protected qCurrentFileSize.q
  
  If pAudPtr >= 0
    nFileDataPtr = aAud(pAudPtr)\nFileDataPtr
    If nFileDataPtr >= 0
      sFileName = aAud(pAudPtr)\sFileName
      qCurrentFileSize = FileSize(sFileName)
      sCurrentFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
      If (sCurrentFileModified <> gaFileData(nFileDataPtr)\sFileModified) Or (qCurrentFileSize <> gaFileData(nFileDataPtr)\qFileSize)
        bChanged = #True
      EndIf
    EndIf
  EndIf
  ProcedureReturn bChanged
  
EndProcedure

Procedure lockAllMixerStreamsProc(pProcName.s, bLock, bForce=#False, bTrace=#False)
  PROCNAMEC()
  Protected n, nMixerStream.l, nBassResult.l, nErrorCode.l
  ; Static bAsioLockedByThisProc ; needs to be a static variable as separate calls are issued to lock and unlock all mixeer streams
  
  ; WARNING: debugMsgC's use parameter pProcName, not protected variable sProcName!
  debugMsgC(pProcName, "bLock=" + strB(bLock) + ", bForce=" + strB(bForce) + ", gnStreamLockLevel=" + gnStreamLockLevel)
  
  ; debugMsgC3("lockAllMixerStreamsProc", #SCS_START)
  
  If bLock  ; lock
    gnStreamLockLevel + 1
    If gnStreamLockLevel = 1 Or bForce
      If gnCurrAudioDriver = #SCS_DRV_BASS_ASIO And #c_enable_bass_asio_lock
        lockBassAsioIfReqd()
      Else
        For n = 0 To (gnMixerStreamCount-1)
          ; debugMsgC3("lockAllMixerStreamsProc", "n=" + n)
          nMixerStream = gaMixerStreams(n)\nMixerStreamHandle
          ; debugMsgC3("lockAllMixerStreamsProc", "nMixerStream=" + decodeHandle(nMixerStream))
          If nMixerStream <> 0
            debugMsg(pProcName, "calling BASS_ChannelLock(" + decodeHandle(nMixerStream) + ", BASSTRUE)")
            nBassResult = BASS_ChannelLock(nMixerStream, #BASSTRUE)
            debugMsg2(pProcName, "BASS_ChannelLock(" + decodeHandle(nMixerStream) + ", BASSTRUE)", nBassResult)
          EndIf
        Next n
      EndIf
      gnStreamLockLevel = 1 ; only significant if bForce=#True
    EndIf
    
  Else  ; unlock
    If gnStreamLockLevel = 1 Or bForce
      If gnCurrAudioDriver = #SCS_DRV_BASS_ASIO And #c_enable_bass_asio_lock
        unlockBassAsioIfReqd()
      Else
        For n = 0 To (gnMixerStreamCount-1)
          nMixerStream = gaMixerStreams(n)\nMixerStreamHandle
          If nMixerStream <> 0
            debugMsg(pProcName, "calling BASS_ChannelLock(" + decodeHandle(nMixerStream) + ", BASSFALSE)")
            nBassResult = BASS_ChannelLock(nMixerStream, #BASSFALSE)
            debugMsg2(pProcName, "BASS_ChannelLock(" + decodeHandle(nMixerStream) + ", BASSFALSE)", nBassResult)
          EndIf
        Next n
      EndIf
      gnStreamLockLevel = 1 ; only significant if bForce=#True
    EndIf
    gnStreamLockLevel - 1
  EndIf
  
  ; debugMsgC3("lockAllMixerStreamsProc", #SCS_END)
  
EndProcedure

Procedure findFirstLinkedAud()
  PROCNAMEC()
  Protected nFirstLinkedAud = -1
  Protected i, j, k
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeF
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            If aSub(j)\nAFLinkedToMTCSubPtr >= 0 Or aAud(k)\bLoopLinked
              nFirstLinkedAud = k
              Break 2 ; Break j, i
            EndIf
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  ProcedureReturn nFirstLinkedAud
EndProcedure

Procedure setAudioDriverGlobalFlags()
  PROCNAMEC()
  Protected nFirstLinkedAud, bUseBASS, bUseSMS, bUseBASSMixer
  
  debugMsg(sProcName, #SCS_START + ", gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
  
  Select gnCurrAudioDriver
    Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI
      bUseBASS = #True
      CompilerIf #cAlwaysUseMixerForBass  ; 28Dec2015
        bUseBASSMixer = #True
      CompilerElse
        bUseBASSMixer = grDriverSettings\bUseBASSMixer
        If bUseBASSMixer = #False
          nFirstLinkedAud = findFirstLinkedAud() ; checks if any 'loop linked' or 'MTC linked' aud's exist
          If nFirstLinkedAud >= 0
            bUseBASSMixer = #True
            If bUseBASSMixer <> gbUseBASSMixer
              debugMsg(sProcName, "setting gbUseBASSMixer=#True because findFirstLinkedAud() returned " + getAudLabel(nFirstLinkedAud))
            EndIf
          EndIf
        EndIf
      CompilerEndIf
      If bUseBASSMixer = #False
        If grVST\nMaxDevVSTPlugin >= 0
          bUseBASSMixer = #True
          If bUseBASSMixer <> gbUseBASSMixer
            debugMsg(sProcName, "setting gbUseBASSMixer=#True because grVST\nMaxDevVSTPlugin=" + grVST\nMaxDevVSTPlugin)
          EndIf
        EndIf
      EndIf
      If bUseBASSMixer = #False
        If isTempoEtcInUse()
          bUseBASSMixer = #True
          If bUseBASSMixer <> gbUseBASSMixer
            debugMsg(sProcName, "isTempoEtcInUse() returned #True, so setting gbUseBASSMixer=#True")
          EndIf
        EndIf
      EndIf
      
    Case #SCS_DRV_BASS_ASIO  ; BASS_ASIO
      bUseBASS = #True
      bUseBASSMixer = #True
      
    Case #SCS_DRV_SMS_ASIO ; SM-S
      bUseSMS = #True
      
  EndSelect
  
  gbUseBASS = bUseBASS
  gbUseSMS = bUseSMS
  gbUseBASSMixer = bUseBASSMixer
  
  debugMsg(sProcName, #SCS_END + ", gbUseBASSMixer=" + strB(gbUseBASSMixer))
  
EndProcedure

Procedure setCurrAudioDriver(nAudioDriver)
  PROCNAMEC()
  Protected i
  Protected n, nDevMapPtr, nValidDevMapPtr, sDevMap.s, sNewDevMapMsg.s
  
  debugMsg(sProcName, #SCS_START + ", nAudioDriver=" + decodeDriver(nAudioDriver))
  
  If nAudioDriver = gnCurrAudioDriver
    ; no change
    debugMsg(sProcName, "no change")
    gnPrevAudioDriver = gnCurrAudioDriver ; added 17Oct2016 11.5.2.3 as changing just the device (eg from speakers to Octa-Capture 1-2) bypassed re-creating mixer streams, etc
    ProcedureReturn
  EndIf
  gnPrevAudioDriver = gnCurrAudioDriver
  gnCurrAudioDriver = nAudioDriver
  
  setAudioDriverGlobalFlags()
  
  Select gnCurrAudioDriver
    Case #SCS_DRV_SMS_ASIO
      debugMsg0(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap))
      If grSMS\nSMSClientConnection = 0
        debugMsg0(sProcName, "calling primeAndInitSMS(#False)")
        primeAndInitSMS(#False)
      EndIf
  EndSelect
  
  If grLicInfo\bLTCAvailable
    If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO And grSMS\nSMSClientConnection
      gn_ScsLTCAllowed = #False
      CompilerIf #c_scsltc
        THR_suspendAThread(#SCS_THREAD_SCS_LTC)
      CompilerEndIf
    Else
      CompilerIf #c_scsltc
        gn_ScsLTCAllowed = #True
        THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)                ; No SMS server so enable internal LTC
      CompilerElse
        gn_ScsLTCAllowed = #False
        ;THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)                ; No SMS server so enable internal LTC, Modified by Dee 29-01-2025 to disable SCSLTC
      CompilerEndIf
    EndIf
  EndIf
  debugMsg(sProcName, "gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver) + ", gn_ScsLTCAllowed=" + strB(gn_ScsLTCAllowed))
  
  debugMsg(sProcName, "calling initBassForAudioDriver(" + decodeDriver(gnCurrAudioDriver) + ")")
  initBassForAudioDriver(gnCurrAudioDriver)
  
  ; reset fields like aCue(i)\bUseCasForThisCue
  For i = 1 To gnLastCue
    setDerivedCueFields(i, #False)
  Next i
  
  If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
    gbCallCheckUsingPlaybackRateChangeOnly = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
  
EndProcedure

Procedure getPrimaryPhysDevPtr(nAudioDriver)
  ; PROCNAMEC()
  Protected nPrimaryPhysDevPtr
  Protected n
  
  ; debugMsg(sProcName, #SCS_START + ", nAudioDriver=" + decodeDriver(nAudioDriver))
  
  nPrimaryPhysDevPtr = -1
  ; search for first device for this audio driver
  For n = 0 To (gnPhysicalAudDevs-1)
    With gaAudioDev(n)
      ; debugMsg(sProcName, "gaAudioDev(" + n + ")\sDesc=" + \sDesc + ", \nAudioDriver=" + decodeDriver(\nAudioDriver))
      If \nAudioDriver = nAudioDriver
        nPrimaryPhysDevPtr = n
        Break
      EndIf
    EndWith
  Next n
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nPrimaryPhysDevPtr)
  ProcedureReturn nPrimaryPhysDevPtr
  
EndProcedure

Procedure freeMixerStreams()
  PROCNAMEC()
  Protected n
  Protected nBassResult.l
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To (gnMixerStreamCount-1)
    With gaMixerStreams(n)
      If \nPushStreamHandle
        nBassResult = BASS_StreamFree(\nPushStreamHandle)
        debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(\nPushStreamHandle) + ")", nBassResult)
        If nBassResult = #BASSFALSE
          debugMsg3(sProcName, "error: " + getBassErrorDesc(BASS_ErrorGetCode()))
        EndIf
        freeHandle(\nPushStreamHandle)
        \nPushStreamHandle = 0
      EndIf
      If \nMixerStreamHandle
        nBassResult = BASS_StreamFree(\nMixerStreamHandle)
        debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(\nMixerStreamHandle) + ")", nBassResult)
        If nBassResult = #BASSFALSE
          debugMsg3(sProcName, "error: " + getBassErrorDesc(BASS_ErrorGetCode()))
        EndIf
        freeHandle(\nMixerStreamHandle)
        \nMixerStreamHandle = 0
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure.l initBassNoSoundDev()
  PROCNAMEC()
  Protected nBassResult.l, nBassInitFlags.l
  Protected nBassInitWindowHandle.l, sBassInitWindowHandle.s
  Protected nBassDevice.l, nBassInitErrorCode.l
  Protected nMyDSSampleRate.l
  
  nBassDevice = 0
  If gbBassNoSoundDevInitialised = #False
    
    If IsWindow(#WDU) = #False
      createfmDummy()
    EndIf
    If IsWindow(#WDU)
      nBassInitWindowHandle = WindowID(#WDU)
      sBassInitWindowHandle = "WindowID(#WDU)"
    ElseIf IsWindow(#WMN)
      nBassInitWindowHandle = WindowID(#WMN)
      sBassInitWindowHandle = "WindowID(#WMN)"
    ElseIf IsWindow(#WSP)
      nBassInitWindowHandle = WindowID(#WSP)
      sBassInitWindowHandle = "WindowID(#WSP)"
    EndIf
    
    ;initialize BASS - "no sound" device - need to initialize BASS or the program will crash on trying to create a mixer stream
    nBassInitFlags | #BASS_DEVICE_DSOUND  ; always initialize the "no sound" device using DirectSound - partly because gnCurrAudioDriver may not have been set yet
    nMyDSSampleRate = grDriverSettings\nDSSampleRate
    If nMyDSSampleRate = 0
      nMyDSSampleRate = 44100
    EndIf
    nBassResult = BASS_Init(nBassDevice, nMyDSSampleRate, nBassInitFlags, nBassInitWindowHandle, 0)
    debugMsg2(sProcName, "BASS_Init(" + nBassDevice + ", " + nMyDSSampleRate + ", " + decodeInitFlags(nBassInitFlags) + ", " + sBassInitWindowHandle + ", 0)", nBassResult)
    If nBassResult = #BASSFALSE
      nBassInitErrorCode = BASS_ErrorGetCode()
      debugMsg3(sProcName, "error: " + getBassErrorDesc(nBassInitErrorCode))
      If nBassInitErrorCode <> #BASS_ERROR_ALREADY
        nBassDevice = -999
      EndIf
    EndIf
    
    If nBassDevice <> -999
      gbBassNoSoundDevInitialised = #True
      nBassResult = BASS_Start()
      debugMsg2(sProcName, "BASS_Start() for device " + nBassDevice, nBassResult)
      If nBassResult = #BASSFALSE
        debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
      EndIf
    EndIf
    
  EndIf
  
  ProcedureReturn nBassDevice
  
EndProcedure

Procedure initBassForSession()
  PROCNAMEC()
  Protected nBassResult.l
  
  ; Regarding "BASS_SetConfig(#BASS_CONFIG_DEV_DEFAULT, ...)", the BASS documentation states "This option can only be set before BASS_GetDeviceInfo or BASS_Init has been called."
  nBassResult = BASS_SetConfig(#BASS_CONFIG_DEV_DEFAULT, #BASSTRUE)
  debugMsg2(sProcName, "BASS_SetConfig(#BASS_CONFIG_DEV_DEFAULT, #BASSTRUE)", nBassResult)
  
EndProcedure

Procedure initBassIfReqd()
  PROCNAMEC()
  Protected nBassDevice.l, nBassErrorCode.l
  
  nBassDevice = BASS_GetDevice()
  If nBassDevice = -1
    nBassErrorCode = BASS_ErrorGetCode()
    If nBassErrorCode = #BASS_ERROR_INIT
      debugMsg(sProcName, "calling initBassNoSoundDev()")
      initBassNoSoundDev()
    EndIf
  EndIf
EndProcedure

Procedure freeBassNoSoundDev()
  PROCNAMEC()
  Protected nBassResult.l
  
  If gbBassNoSoundDevInitialised
    nBassResult = BASS_SetDevice(0)
    debugMsg2(sProcName, "BASS_SetDevice(0)", nBassResult)
    If nBassResult = #BASSTRUE
      nBassResult = BASS_Free()
      debugMsg2(sProcName, "BASS_Free() for device 0", nBassResult)
    EndIf
    gbBassNoSoundDevInitialised = #False
  EndIf
  
EndProcedure

Procedure comparePhysDevDescs(sPhysDev1.s, sPhysDev2.s, nPass)
  PROCNAMEC()
  ; Procedure to compare device physical descriptions of audio interfaces.
  ; It appears that Windows has changed the structure of audio device names ('physical device names').
  ; Sometimes this seems to be affected by the USB port your USB sound interface is connected to.
  ; For example, the DirectSound device name for the first stereo pair on my UA-101 used to be named "1-2 (UA-101)" but Windows now names it "1-2 (2- UA-101)".
  ; Similar changes have been reported with other equipment. The result is that SCS can report that it cannot find a device named in a Device Map simply
  ; because of this name change. SCS 10.9.6 has been changed so that if an exact match is not found then it will 'try again' ignoring a pattern like "n- "
  ; immediately after the first "(", where "n" is any number. This 'try again' (nPass=2)comparison also ignores all spaces within names.
  Protected bResult
  Protected sMyPhysDev1.s, sMyPhysDev2.s, sTmp.s
  Protected sChar.s
  Protected n
  Protected nPos
  Protected nBracketPos, bSkipping
  Protected nLenPhysDev1, nLenPhysDev2, nMinLen
  
  ; debugMsg(sProcName, #SCS_START + ", sPhysDev1=" + sPhysDev1 + ", sPhysDev2=" + sPhysDev2 + ", nPass=" + nPass)
  bResult = #False
  If sPhysDev1 = sPhysDev2
    bResult = #True
    
  ElseIf nPass = 2
    CompilerIf 1=2 
      ; BLOCKED OUT 22Jun2022 11.9.4ab as should now be obsolete, and caused a problem reported by Dave Lawrence where DevMap had audio devices
      ; "SPDIF Interface (2- USB DAC)" and "SPDIF Interface (3- USB DAC)" but corresponding connected devices were "SPDIF Interface (7- USB DAC)" and "SPDIF Interface (9- USB DAC)".
      ; This procedure didn't find either "SPDIF Interface (2- USB DAC)" or "SPDIF Interface (3- USB DAC)" so matched them to the first 'matching' connected device which was "SPDIF Interface (7- USB DAC)".
    sMyPhysDev1 = sPhysDev1
    nBracketPos = FindString(sMyPhysDev1, "(")
    If nBracketPos > 0
      sTmp = Left(sMyPhysDev1, nBracketPos)
      n = nBracketPos + 1
      bSkipping = #True
      While n <= Len(sMyPhysDev1)
        sChar = Mid(sMyPhysDev1, n, 1)
        If bSkipping
          If FindString("0123456789- ", sChar) = 0
            bSkipping = #False
          EndIf
        EndIf
        If bSkipping = #False
          sTmp + sChar
        EndIf
        n + 1
      Wend
      sMyPhysDev1 = sTmp
    EndIf
    sMyPhysDev2 = sPhysDev2
    nBracketPos = FindString(sMyPhysDev2, "(")
    If nBracketPos > 0
      sTmp = Left(sMyPhysDev2, nBracketPos)
      n = nBracketPos + 1
      bSkipping = #True
      While n <= Len(sMyPhysDev2)
        sChar = Mid(sMyPhysDev2, n, 1)
        If bSkipping
          If FindString("0123456789- ", sChar) = 0
            bSkipping = #False
          EndIf
        EndIf
        If bSkipping = #False
          sTmp + sChar
        EndIf
        n + 1
      Wend
      sMyPhysDev2 = sTmp
    EndIf
    ; ignore all spaces when comparing results - found that some devices terminate with " )" instead of ")"
    sMyPhysDev1 = ReplaceString(sMyPhysDev1, " ", "")
    sMyPhysDev2 = ReplaceString(sMyPhysDev2, " ", "")
    If sMyPhysDev1 = sMyPhysDev2
      bResult = #True
    Else
      ; the following added 20June2016 11.5.0.120 following emails from Jorg Deitz
      ; the Dante Virtual Soundcard publishes it's name as "Dante Virtual Soundcard" in 32-bit Windows, but "Dante Virtual Soundcard (x64)" in 64-bit Windows.
      ; the following code is designed to allow differences like this to be ignored, ie to regard the two descriptions as an acceptable match
      nLenPhysDev1 = Len(sMyPhysDev1)
      nLenPhysDev2 = Len(sMyPhysDev2)
      If nLenPhysDev1 < nLenPhysDev2
        nMinLen = nLenPhysDev1
      Else
        nMinLen = nLenPhysDev2
      EndIf
      If nMinLen > 20
        ; must be of a reasonable length to satisfy this test
        If Left(sMyPhysDev1, nMinLen) = Left(sMyPhysDev2, nMinLen)
          bResult = #True
        EndIf
      EndIf
    EndIf
    CompilerEndIf
  EndIf
  ; debugMsg(sProcName,  #SCS_END + ", sPhysDev1=" + sPhysDev1 + ", sPhysDev2=" + sPhysDev2 + ", nPass=" + nPass + ", bResult=" + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure listCuePointArray()
  PROCNAMEC()
  Protected p
  
  For p = 0 To ArraySize(gaCuePoint()) ; gnMaxCuePoint
    With gaCuePoint(p)
      If \sFileName
        debugMsg(sProcName, "gaCuePoint(" + p + ")\sFileName=" + GetFilePart(\sFileName) + ", \sName=" + \sName + ", \dTimePos=" + StrD(\dTimePos, 5))
      EndIf
    EndWith
  Next p
EndProcedure

Procedure compactCuePointArray()
  PROCNAMEC()
  Protected p, p2
  Protected rCuePoint.tyCuePoint
  
  p2 = -1
  For p = 0 To gnMaxCuePoint
    If (gaCuePoint(p)\sName) And (gaCuePoint(p)\sCuePointKey <> "*")
      p2 + 1
      If p <> p2
        gaCuePoint(p2) = gaCuePoint(p)
      EndIf
    EndIf
  Next p
  gnMaxCuePoint = p2
  debugMsg(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint)
  
  For p = gnMaxCuePoint+1 To ArraySize(gaCuePoint())
    gaCuePoint(p) = rCuePoint
  Next p
  
EndProcedure

Procedure getCuePointIndex(sFileName.s, sName.s)
  PROCNAMEC()
  Protected nIndex = -1
  Protected p
  
  debugMsg(sProcName, #SCS_START)
  debugMsg(sProcName, "sFileName=" + sFileName)
  debugMsg(sProcName, "sName=" + sName)
  debugMsg(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint)
  
  For p = 0 To gnMaxCuePoint
    With gaCuePoint(p)
      If (\sFileName = sFileName) And (\sName = sName)
        nIndex = p
        Break
      EndIf
    EndWith
  Next p
  
  ProcedureReturn nIndex
EndProcedure

Procedure.d getCuePointTimePos(sFileName.s, sName.s)
  PROCNAMEC()
  Protected dTimePos.d
  Protected p
  
  debugMsg(sProcName, #SCS_START)
  debugMsg(sProcName, "sFileName=" + sFileName)
  debugMsg(sProcName, "sName=" + sName)
  
  dTimePos = grAudDef\dStartAtCPTime
  
  For p = 0 To gnMaxCuePoint
    With gaCuePoint(p)
      debugMsg(sProcName, "gaCuePoint(" + p + ")\sFileName=" + \sFileName + ", \sName=" + \sName)
      If (\sFileName = sFileName) And (\sName = sName)
        debugMsg(sProcName, "Found. gaCuePoint(p)\dTimePos=" + StrD(\dTimePos,5))
        dTimePos = \dTimePos
        Break
      EndIf
    EndWith
  Next p
  
  debugMsg(sProcName, "returning " + StrD(dTimePos,5))
  ProcedureReturn dTimePos
EndProcedure

Procedure getAnalyzedFileIndex(sFileName.s)
  PROCNAMEC()
  Protected n
  Protected nIndex = -1
  
  If sFileName
    For n = 0 To gnMaxAnalyzedFile
      With gaAnalyzedFile(n)
        If \sFileName = sFileName
          nIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nIndex
EndProcedure

Procedure isAudPlaying(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bChannelPlaying, nActiveState
  
  bChannelPlaying = #True
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \bAudTypeA
        bChannelPlaying = isVideoPlaying(\nAudVidPicTarget, pAudPtr)
      Else
        If \nFirstSoundingDev < 0
          bChannelPlaying = #False
        ElseIf gbUseBASS
          If gbUseBASSMixer
            ;debugMsg(sProcName, "BASS_Mixer_ChannelFlags(" + \nBassChannel(\nFirstSoundingDev) + ", 0, 0)=" + Hex(BASS_Mixer_ChannelFlags(\nBassChannel(\nFirstSoundingDev), 0, 0)))
            If BASS_Mixer_ChannelFlags(\nBassChannel[\nFirstSoundingDev], 0, 0) & #BASS_MIXER_CHAN_PAUSE ; = #BASS_MIXER_CHAN_PAUSE
              bChannelPlaying = #False
            EndIf
          Else
            nActiveState = BASS_ChannelIsActive(\nBassChannel[\nFirstSoundingDev])
            ; debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(\nBassChannel[\nFirstSoundingDev]) + ")", nActiveState)
            If nActiveState <> #BASS_ACTIVE_PLAYING
              bChannelPlaying = #False
            EndIf
          EndIf
        Else ; SM-S
          ;debugMsg(sProcName, "nLabel=" + nLabel + ", " + \sAudLabel + " calling extractSMSChanItem(grSMS\sPStatusResponse, \sPPrimaryChan)")
          If extractSMSChanItem(grSMS\sPStatusResponse, \sPPrimaryChan) = "STOP"
            ;debugMsg(sProcName, "grSMS\qStatusResponseReceived=" + traceTime(grSMS\qPStatusResponseReceived) + ", \qTimePlayOrReposIssued=" + traceTime(\qTimePlayOrReposIssued))
            If grSMS\qPStatusResponseReceived > \qTimePlayOrReposIssued
              bChannelPlaying = #False
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn bChannelPlaying
EndProcedure

Procedure reloadDevices(nAudioDriver)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling getAllPhysicalDevices()")
  getAllPhysicalDevices()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure copyPosSizeAndAspectToClipboard(pAudPtr)
  PROCNAMECA(pAudPtr)
  
  If pAudPtr >= 0
    With grPosSizeAndAspectClipboard
      \nXPos = aAud(pAudPtr)\nXPos
      \nYPos = aAud(pAudPtr)\nYPos
      \nSize = aAud(pAudPtr)\nSize
      \nAspectRatioType = aAud(pAudPtr)\nAspectRatioType
      \nAspectRatioHVal = aAud(pAudPtr)\nAspectRatioHVal
      \sCopyInfo = getAudLabel(pAudPtr) + " (" + GetFilePart(aAud(pAudPtr)\sFileName) + ")"
      \bPopulated = #True
    EndWith
  EndIf
EndProcedure

Procedure pastePosSizeAndAspectFromClipboard(pAudPtr)
  PROCNAMECA(pAudPtr)
  
  If pAudPtr >= 0
    With grPosSizeAndAspectClipboard
      If \bPopulated
        aAud(pAudPtr)\nXPos = \nXPos
        aAud(pAudPtr)\nYPos = \nYPos
        aAud(pAudPtr)\nSize = \nSize
        aAud(pAudPtr)\nAspectRatioType = \nAspectRatioType
        aAud(pAudPtr)\nAspectRatioHVal = \nAspectRatioHVal
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure paintPictureAtPosAndSize(pAudPtr, pTargetCanvasOrImage, pSourceImage, bTargetIsCanvas=#True, bForceTrace=#False)
  PROCNAMECA(pAudPtr)
  ; Paints the source image (pSourceImage) in the target canvas or image (pTargetCanvasOrImage) after calculating the required position within the target using calcDisplayPosAndSize3().
  ; This procedure does NOT update anything in aAud(pAudPtr).
  Protected nSourceWidth, nSourceHeight
  Protected nTargetWidth, nTargetHeight
  Protected nOutputID
  Protected sOutputID.s
  Protected nGadgetPropsIndex
  Protected nWindowNo
  Protected sGadgetName.s
  Protected bTrace
  
  If bForceTrace
    bTrace = #True
  Else
    bTrace = #cTraceVidPicDrawing
  EndIf
  
  debugMsgC(sProcName, #SCS_START + ", bTargetIsCanvas=" + strB(bTargetIsCanvas) + ", bTrace=" + strB(bTrace))
  
  If bTargetIsCanvas
    nTargetWidth = GadgetWidth(pTargetCanvasOrImage)
    nTargetHeight = GadgetHeight(pTargetCanvasOrImage)
    nOutputID = CanvasOutput(pTargetCanvasOrImage)
    nGadgetPropsIndex = getGadgetPropsIndex(pTargetCanvasOrImage)
    nWindowNo = gaGadgetProps(nGadgetPropsIndex)\nGWindowNo
    sGadgetName = getGadgetName(pTargetCanvasOrImage)
    sOutputID = "CanvasOutput(" + sGadgetName + ")"
  Else
    nTargetWidth = ImageWidth(pTargetCanvasOrImage)
    nTargetHeight = ImageHeight(pTargetCanvasOrImage)
    nOutputID = ImageOutput(pTargetCanvasOrImage)
    sOutputID = "ImageOutput(" + decodeHandle(pTargetCanvasOrImage) + ")"
  EndIf
  debugMsgC(sProcName, "sOutputID=" + sOutputID)
  
  nSourceWidth = ImageWidth(pSourceImage)
  nSourceHeight = ImageHeight(pSourceImage)
  debugMsgC(sProcName, "nSourceWidth=" + nSourceWidth + ", nSourceHeight=" + nSourceHeight + ", nTargetWidth=" + nTargetWidth + ", nTargetHeight=" + nTargetHeight)
  
  debugMsgC(sProcName, "(h target) calling calcDisplayPosAndSize3(" + getAudLabel(pAudPtr) + ", " + nSourceWidth + ", " + nSourceHeight + ", " + nTargetWidth + ", " + nTargetHeight + ", 0, 0, #False, #True)")
  calcDisplayPosAndSize3(pAudPtr, nSourceWidth, nSourceHeight, nTargetWidth, nTargetHeight, 0, 0, #False, #True)
  ; Setting bAllowCropping=#False in the above call is necessary so that results like grDPS\nDisplayLeft can be outside the target boundaries when drawn using DrawImage() - see below.
  ; This means the image will still retain the required aspect ratio, even if part of the image is not visible.
  With grDPS
    If StartDrawing(nOutputID)
      debugMsgD(sProcName, "StartDrawing(" + sOutputID + ")")
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)  ; clear target area
      debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
      DrawImage(ImageID(pSourceImage), \nDisplayLeft, \nDisplayTop, \nDisplayWidth, \nDisplayHeight)
      debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(pSourceImage) + "), " + \nDisplayLeft + ", " + \nDisplayTop + ", " + \nDisplayWidth + ", " + \nDisplayHeight + ")")
      StopDrawing()
      debugMsgD(sProcName, "StopDrawing()")
    EndIf
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure adjustVideoPosAndSize3(pAudPtr, pVidPicTarget, bTrace=#False)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nSourceWidth, nSourceHeight
  Protected nTargetWidth, nTargetHeight
  
  debugMsgC(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    If \nFileFormat = #SCS_FILEFORMAT_VIDEO
      If \nSourceWidth = 0
        getVideoInfoForAud(pAudPtr)
      EndIf
      nSourceWidth = \nSourceWidth
      nSourceHeight = \nSourceHeight
      nTargetWidth = grVidPicTarget(pVidPicTarget)\nTargetWidth
      nTargetHeight = grVidPicTarget(pVidPicTarget)\nTargetHeight
      debugMsgC(sProcName, "nSourceWidth=" + nSourceWidth + ", nSourceHeight=" + nSourceHeight + ", nTargetWidth=" + nTargetWidth + ", nTargetHeight=" + nTargetHeight)
      debugMsgC(sProcName, "(g target) calling calcDisplayPosAndSize3(" + getAudLabel(pAudPtr) + ", " + nSourceWidth + ", " + nSourceHeight + ", " + nTargetWidth + ", " + nTargetHeight + ")")
      calcDisplayPosAndSize3(pAudPtr, nSourceWidth, nSourceHeight, nTargetWidth, nTargetHeight, 0, 0)
      \nDisplayLeft(pVidPicTarget) = grDPS\nDisplayLeft
      \nDisplayTop(pVidPicTarget) = grDPS\nDisplayTop
      \nDisplayWidth(pVidPicTarget) = grDPS\nDisplayWidth
      \nDisplayHeight(pVidPicTarget) = grDPS\nDisplayHeight
    EndIf
  EndWith
  
EndProcedure

Procedure doTestLiveInput(nInputDevNo, nOutputDevNo)
  PROCNAMEC()
  Protected bInputDevInitialized, bOutputDevInitialized
  Protected sInputLogicalDev.s, sOutputLogicalDev.s
  Protected nInputDevMapDevPtr, nOutputDevMapDevPtr
  Protected nFirst0BasedInputChanAG, nFirst0BasedOutputChanAG
  Protected nNrOfInputChans, nNrOfOutputChans
  Protected sDfltDBLevel.s
  Protected sMsg.s
  Protected bResult
  Protected sSMSCommand.s, sSMSStartCommand.s, sSMSStopCommand.s
  Protected d, d2
  
  bResult = #True
  
  debugMsg(sProcName, #SCS_START + ", nInputDevNo=" + nInputDevNo + ", gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
  
  sInputLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(nInputDevNo)\sLogicalDev
  nInputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, sInputLogicalDev)
  debugMsg(sProcName, "sInputLogicalDev=" + sInputLogicalDev + ", nInputDevMapDevPtr=" + nInputDevMapDevPtr)
  grTestLiveInput\nInputDevMapDevPtr = nInputDevMapDevPtr
  
  sOutputLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nOutputDevNo)\sLogicalDev
  nOutputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sOutputLogicalDev)
  debugMsg(sProcName, "sOutputLogicalDev=" + sOutputLogicalDev + ", nOutputDevMapDevPtr=" + nOutputDevMapDevPtr)
  grTestLiveInput\nOutputDevMapDevPtr = nOutputDevMapDevPtr
  sDfltDBLevel = grProdForDevChgs\aAudioLogicalDevs(nOutputDevNo)\sDfltDBLevel
  
  If nInputDevMapDevPtr < 0 Or nOutputDevMapDevPtr < 0
    ProcedureReturn #False
  EndIf
  
  With grMapsForDevChgs\aDev(nInputDevMapDevPtr)
    ; live input device
    debugMsg(sProcName, "input \nPhysicalDevPtr=" + \nPhysicalDevPtr)
    If \nPhysicalDevPtr >= 0
      If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
        debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
        initDevice(\nPhysicalDevPtr)
      EndIf
      bInputDevInitialized = gaAudioDev(\nPhysicalDevPtr)\bInitialized
      nFirst0BasedInputChanAG = \nFirst0BasedInputChanAG
      nNrOfInputChans = \nNrOfInputChans
    EndIf
    debugMsg(sProcName, "bInputDevInitialized=" + strB(bInputDevInitialized) + ", nFirst0BasedInputChanAG=" + nFirst0BasedInputChanAG + ", nNrOfInputChans=" + nNrOfInputChans)
  EndWith
  
  With grMapsForDevChgs\aDev(nOutputDevMapDevPtr)
    ; audio output device
    debugMsg(sProcName, "output \nPhysicalDevPtr=" + \nPhysicalDevPtr)
    If \nPhysicalDevPtr >= 0
      If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
        debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
        initDevice(\nPhysicalDevPtr)
      EndIf
      bOutputDevInitialized = gaAudioDev(\nPhysicalDevPtr)\bInitialized
      nFirst0BasedOutputChanAG = \nFirst0BasedOutputChanAG
      nNrOfOutputChans = \nNrOfDevOutputChans
    EndIf
    debugMsg(sProcName, "bOutputDevInitialized=" + strB(bOutputDevInitialized) + ", nFirst0BasedOutputChanAG=" + nFirst0BasedOutputChanAG + ", nNrOfOutputChans=" + nNrOfOutputChans)
  EndWith
  
  If (bInputDevInitialized) And (bOutputDevInitialized)
    If gbUseSMS ; SM-S
      setInputGain(nInputDevNo, #True) ; Added 14Jun2021 11.8.5ai
      adjustLiveEQ(@grMapsForDevChgs\aDev(nInputDevMapDevPtr), #True) ; Added 14Jun2021 11.8.5ai
      sSMSCommand = "set chan"
      For d2 = 1 To nNrOfInputChans
        For d = 1 To nNrOfOutputChans
          sSMSCommand + " x" + Str(nFirst0BasedInputChanAG + d2 - 1) + "." + Str(nFirst0BasedOutputChanAG + d - 1)
        Next d
      Next d2
      sSMSStartCommand = sSMSCommand + " gaindb " + sDfltDBLevel + " fadetime 0.2; " + sProcName + "(" + sInputLogicalDev + ", " + sOutputLogicalDev + ")"
      sendSMSCommandNP(sSMSStartCommand)
      sSMSStopCommand = sSMSCommand + " gain 0 fadetime 0.2; $1(" + sInputLogicalDev + ", " + sOutputLogicalDev + ")"
      grTestLiveInput\bRunningTestLiveInput = #True
    EndIf
    grTestLiveInput\nTestLiveInputChan = nFirst0BasedInputChanAG
    grTestLiveInput\sSMSStopCommand = sSMSStopCommand
    grTestLiveInput\bRunningTestLiveInput = #True
    
    buildVUCommandString()
    samAddRequest(#SCS_SAM_BUILD_DEV_CHANNEL_LIST)
    startVUDisplayIfReqd()
    
  Else
    bResult = #False
    
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure adjustTestLiveInputLevel(nInputDevNo, nOutputDevNo)
  PROCNAMEC()
  ; nb this procedure not used (currently)
  ; it was intended to allow the live input test level to be adjusted by the default input level, but this is not currently implemented
  ; and if it does get implemented then this procedure will need to be updated as it doesn't currently look at the default input level
  Protected sInputLogicalDev.s, sOutputLogicalDev.s
  Protected nInputDevMapDevPtr, nOutputDevMapDevPtr
  Protected nFirst0BasedInputChanAG, nFirst0BasedOutputChanAG
  Protected nNrOfInputChans, nNrOfOutputChans
  Protected sDfltDBLevel.s
  Protected sSMSCommand.s
  Protected d, d2
  
  If grTestLiveInput\bRunningTestLiveInput
    
    sInputLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(nInputDevNo)\sLogicalDev
    nInputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, sInputLogicalDev)
    
    sOutputLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nOutputDevNo)\sLogicalDev
    nOutputDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sOutputLogicalDev)
    sDfltDBLevel = grProdForDevChgs\aAudioLogicalDevs(nOutputDevNo)\sDfltDBLevel
    
    If nInputDevMapDevPtr < 0 Or nOutputDevMapDevPtr < 0
      ; shouldn't happen
      ProcedureReturn
    EndIf
    
    With grMapsForDevChgs\aDev(grTestLiveInput\nInputDevMapDevPtr)
      ; live input device
      debugMsg(sProcName, "input \nPhysicalDevPtr=" + \nPhysicalDevPtr)
      If \nPhysicalDevPtr >= 0
        nFirst0BasedInputChanAG = \nFirst0BasedInputChanAG
        nNrOfInputChans = \nNrOfInputChans
      EndIf
    EndWith
    
    With grMapsForDevChgs\aDev(grTestLiveInput\nOutputDevMapDevPtr)
      ; audio output device
      debugMsg(sProcName, "output \nPhysicalDevPtr=" + \nPhysicalDevPtr)
      If \nPhysicalDevPtr >= 0
        nFirst0BasedOutputChanAG = \nFirst0BasedOutputChanAG
        nNrOfOutputChans = \nNrOfDevOutputChans
      EndIf
    EndWith
    
    If gbUseSMS ; SM-S
      sSMSCommand = "set chan"
      For d2 = 1 To nNrOfInputChans
        For d = 1 To nNrOfOutputChans
          sSMSCommand + " x" + Str(nFirst0BasedInputChanAG + d2 - 1) + "." + Str(nFirst0BasedOutputChanAG + d - 1)
        Next d
      Next d2
      sSMSCommand + " gaindb " + sDfltDBLevel + " fadetime 0.2; " + sProcName + "(" + sInputLogicalDev + ", " + sOutputLogicalDev + ")"
      sendSMSCommandNP(sSMSCommand)
    EndIf
    
  EndIf
  
EndProcedure

Procedure stopTestLiveInput()
  PROCNAMEC()
  Protected sSMSStopCommand.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grTestLiveInput
    
    If gbUseSMS  ; SM-S
      If \bRunningTestLiveInput
        sSMSStopCommand = ReplaceString(\sSMSStopCommand, "$1", sProcName)
        sendSMSCommandNP(sSMSStopCommand)
      EndIf
    EndIf
    
    clearTestLiveInputVUDisplay()
    
    \bRunningTestLiveInput = #False
    If IsGadget(WEP\btnTestLiveInputCancel)
      setVisible(WEP\btnTestLiveInputCancel, #False)
      setVisible(WEP\btnTestLiveInputStart, #True)
      WEP_setTestLiveInputButtonsEnabledState()
    EndIf
    buildVUCommandString()
    
  EndWith
  
EndProcedure

Procedure getDSDeviceCount()
  PROCNAMEC()
  Protected nDSDeviceCount
  Protected nDSDeviceNo.l
  Protected nBassResult.l
  Protected rDeviceInfo.BASS_DEVICEINFO
  
  nDSDeviceCount = 0  ; counts number of  devices, used or not
  nDSDeviceNo = 1   ; first BASS real device number (ignores device 0, the 'no sound' device)
  While #True
    debugMsg3(sProcName, "calling BASS_GetDeviceInfo(" + nDSDeviceNo + ", @rDeviceInfo)")
    nBassResult = BASS_GetDeviceInfo(nDSDeviceNo, @rDeviceInfo)
    debugMsg2(sProcName, "BASS_GetDeviceInfo(" + Str(nDSDeviceNo) + ", @rDeviceInfo)", nBassResult)
    If nBassResult = #BASSFALSE
      Break
    EndIf
    With rDeviceInfo
      debugMsg3(sProcName, "rDeviceInfo\name=" + Trim(VBStrFromAnsiPtr(\name)) + ", flags=" + \flags)
      If \flags & #BASS_DEVICE_ENABLED
        nDSDeviceCount + 1
        nDSDeviceNo + 1
      Else
        Break
      EndIf
    EndWith
  Wend
  debugMsg(sProcName, #SCS_END + ", returning " + Str(nDSDeviceCount))
  ProcedureReturn nDSDeviceCount
EndProcedure

Procedure getASIODeviceCount()
  PROCNAMEC()
  Protected nAsioDeviceCount
  Protected nAsioDeviceNo.l
  Protected nBassResult.l
  Protected rAsioDeviceInfo.BASS_ASIO_DEVICEINFO
  Protected sPhysicalDevDesc.s
  
  nAsioDeviceCount = 0  ; counts number of ASIO devices, used or not
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    nAsioDeviceNo = 0   ; first BASS ASIO device number
    While #True
      debugMsg3(sProcName, "calling BASS_ASIO_GetDeviceInfo(" + nAsioDeviceNo + ", @rAsioDeviceInfo)")
      nBassResult = BASS_ASIO_GetDeviceInfo(nAsioDeviceNo, @rAsioDeviceInfo)
      debugMsg2(sProcName, "BASS_ASIO_GetDeviceInfo(" + nAsioDeviceNo + ", @rAsioDeviceInfo)", nBassResult)
      If nBassResult = #BASSFALSE
        Break
      EndIf
      sPhysicalDevDesc = Trim(VBStrFromAnsiPtr(rAsioDeviceInfo\name))
      debugMsg3(sProcName, "rAsioDeviceInfo\name=" + sPhysicalDevDesc)
      nAsioDeviceCount + 1
      nAsioDeviceNo + 1
    Wend
  EndIf
  debugMsg(sProcName, #SCS_END + ", returning " + nAsioDeviceCount)
  ProcedureReturn nAsioDeviceCount
EndProcedure

Procedure freeDeadGaplessStreams()
  PROCNAMEC()
  Protected j, k, d
  Protected bFound
  Protected nGaplessSeqPtr
  Protected nBassResult.l
  
  ; debugMsg(sProcName, #SCS_START + ", gnGaplessSeqCount=" + gnGaplessSeqCount)
  
  For nGaplessSeqPtr = 0 To (gnGaplessSeqCount-1)
    With gaGaplessSeqs(nGaplessSeqPtr)
      debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nStreamType=" + \nStreamType + ", \nGaplessStream=" + decodeHandle(\nGaplessStream) + ", \nTimeLineChannel=" + decodeHandle(\nTimeLineChannel))
      If (\nGaplessStream <> grGaplessSeqDef\nGaplessStream) Or (\nTimeLineChannel <> grGaplessSeqDef\nTimeLineChannel)
        bFound = #False
        For k = 1 To gnLastAud
          If aAud(k)\nAudGaplessSeqPtr = nGaplessSeqPtr
            If aAud(k)\bExists
              debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudGaplessSeqPtr=" + aAud(k)\nAudGaplessSeqPtr + ", \nAudState=" + decodeCueState(aAud(k)\nAudState))
              If (aAud(k)\nAudState >= #SCS_CUE_READY) And (aAud(k)\nAudState < #SCS_CUE_COMPLETED)
                bFound = #True
                Break
              EndIf
            EndIf
          EndIf
        Next k
        debugMsg(sProcName, "bFound=" + strB(bFound))
        If bFound = #False
          Select \nStreamType
            Case #SCS_STREAM_AUDIO  ; Case #SCS_STREAM_AUDIO
              debugMsg(sProcName, "free audio gapless stream " + decodeHandle(\nGaplessStream))
              For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                If \nSplitterChannel[d] <> 0
                  nBassResult = BASS_StreamFree(\nSplitterChannel[d])
                  debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(\nSplitterChannel[d]) + ")", nBassResult)
                  \nSplitterChannel[d] = 0
                EndIf
              Next d
              nBassResult = BASS_StreamFree(\nGaplessStream)
              debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(\nGaplessStream) + ")", nBassResult)
              \nGaplessStream = grGaplessSeqDef\nGaplessStream
              
            Case #SCS_STREAM_VIDEO  ; #SCS_STREAM_VIDEO
              debugMsg(sProcName, "free video gapless stream " + decodeHandle(\nTimeLineChannel))
              ; For k = 1 To gnLastAud
                ; If aAud(k)\nAudGaplessSeqPtr = nGaplessSeqPtr
                  ; If aAud(k)\bExists
                    ; aAud(k)\nAudGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
                    ; j = aAud(k)\nSubIndex
                    ; aSub(j)\nSubGaplessSeqPtr = grSubDef\nSubGaplessSeqPtr
                  ; EndIf
                ; EndIf
              ; Next k
              \nTimeLineChannel = grGaplessSeqDef\nTimeLineChannel
              
          EndSelect
        EndIf
      EndIf
    EndWith
  Next nGaplessSeqPtr
  
EndProcedure

Procedure listStreamStatuses()
  PROCNAMEC()
  Protected d, n
  Protected nBassResult
  
  For n = 0 To (gnGaplessSeqCount-1)
    With gaGaplessSeqs(n)
      If \nGaplessStream > 0
        nBassResult = BASS_ChannelIsActive(\nGaplessStream)
        debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(\nGaplessStream) + ") - gaGaplessSeqs(" + n + ")\nGaplessStream", nBassResult)
        For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
          If \nSplitterChannel[d] <> 0
            nBassResult = BASS_ChannelIsActive(\nSplitterChannel[d])
            debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(\nSplitterChannel[d]) + ") - gaGaplessSeqs(" + n + ")\nSplitterChannel[" + d + "]", nBassResult)
          EndIf
        Next d
      EndIf
    EndWith
  Next n
  
  For n = 0 To (gnMixerStreamCount-1)
    With gaMixerStreams(n)
      If \nMixerStreamHandle <> 0
        nBassResult = BASS_ChannelIsActive(\nMixerStreamHandle)
        debugMsg2(sProcName, "BASS_ChannelIsActive(" + decodeHandle(\nMixerStreamHandle) + ") - gaMixerStreams(" + n + ")\nMixerStreamHandle", nBassResult)
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure calcAspectRatioType(nSourceWidth, nSourceHeight, nAspect)
  PROCNAMEC()
  Protected nNewWidth, nNewHeight
  Protected nAspectRatioType
  
  debugMsg(sProcName, #SCS_START + ", nSourceWidth=" + nSourceWidth + ", nSourceHeight=" + nSourceHeight + ", nAspect=" + nAspect)
  
  nNewWidth = nSourceWidth + (nSourceWidth * nAspect / 500)
  nNewHeight = nSourceHeight + (nSourceHeight * nAspect / 500)
  If nAspect = 0
    nAspectRatioType = #SCS_ART_ORIGINAL
  ElseIf (nNewWidth * 9) = (nNewHeight * 16)
    nAspectRatioType = #SCS_ART_16_9
  ElseIf (nNewWidth * 3) = (nNewHeight * 4)
    nAspectRatioType = #SCS_ART_16_9
  ElseIf (nNewWidth * 20) = (nNewHeight * 37)
    nAspectRatioType = #SCS_ART_185_1
  ElseIf (nNewWidth * 20) = (nNewHeight * 47)
    nAspectRatioType = #SCS_ART_235_1
  Else
    nAspectRatioType = #SCS_ART_CUSTOM
  EndIf
  debugMsg(sProcName, #SCS_END + ", nNewWidth=" + nNewWidth + ", nNewHeight=" + nNewHeight + ", nAspectRatioType=" + decodeAspectRatioType(nAspectRatioType))
  ProcedureReturn nAspectRatioType
  
EndProcedure

Procedure clearMonitor(pVidPicTarget)
  PROCNAMEC()
  Protected nScreenNo
  Protected n
  Protected nCanvasNo
  Protected bLogoExists
  Protected nImageNo
  Protected nLogoFadeInTime
  Protected nMonitorWindowNo
  Protected nVisibleCanvas
  Protected nLogoMonitorNo = 0
  Protected bTrace = #True
  
  debugMsgC(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  ; added 25Sep2017 11.7.0am following emails from Nigel Crook (bug apparent when only a single screen is connected)
  If grVideoMonitors\bDisplayMonitorWindows = #False
    debugMsgC(sProcName, "exiting because grVideoMonitors\bDisplayMonitorWindows=#False")
    ProcedureReturn
  EndIf
  ; end added 25Sep2017 11.7.0am
  
  If IsGadget(grVidPicTarget(pVidPicTarget)\nCurrMonitorCanvasNo) = 0
    debugMsgC(sProcName, "exiting because isGadget(grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nCurrMonitorCanvasNo)=0")
    ProcedureReturn
  EndIf
  
  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      nScreenNo = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
      With grVidPicTarget(pVidPicTarget)
        debugMsgC(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nLogoImageNo=" + decodeHandle(\nLogoImageNo) + ", \nMonitorWindowNo=" + decodeWindow(\nMonitorWidth) +
                             ", \nLogoFadeInTime=" + \nLogoFadeInTime + ", \bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
        If IsImage(\nLogoImageNo)
          bLogoExists = #True
          nImageNo = \nLogoImageNo
          nMonitorWindowNo = \nMonitorWindowNo
          nLogoFadeInTime = \nLogoFadeInTime
        Else
          nImageNo = \nBlackImageNo
        EndIf
      EndWith
      
      With WMO(nScreenNo)
        debugMsgC(sProcName, "WMO(" + nScreenNo + ")\nMaxMonitorIndex=" + \nMaxMonitorIndex)
        For n = 0 To \nMaxMonitorIndex
          CheckSubInRange(n, ArraySize(\aMonitor()), "WMO(" + nScreenNo + ")\aMonitor()")
          debugMsgC(sProcName, "WMO(" + nScreenNo + ")\aMonitor(" + n + ")\cvsMonitorCanvas=" + \aMonitor(n)\cvsMonitorCanvas)
          nCanvasNo = \aMonitor(n)\cvsMonitorCanvas
          If IsGadget(nCanvasNo)
            If getVisible(nCanvasNo)
              nVisibleCanvas = nCanvasNo
              If nLogoFadeInTime > 0
                grVidPicTarget(pVidPicTarget)\nCurrMonitorCanvasNo = nCanvasNo
                debugMsgC(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nCurrMonitorCanvasNo=" + grVidPicTarget(pVidPicTarget)\nCurrMonitorCanvasNo +
                                     ", " + getGadgetName(grVidPicTarget(pVidPicTarget)\nCurrMonitorCanvasNo))
              Else
                If StartDrawing(CanvasOutput(nCanvasNo))
                  debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
                  DrawingMode(#PB_2DDrawing_Default)
                  debugMsgD(sProcName, "DrawingMode(#PB_2DDrawing_Default)")
                  If n = nLogoMonitorNo
                    DrawImage(ImageID(nImageNo), 0, 0, OutputWidth(), OutputHeight())
                    debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nImageNo) + "), 0, 0, " + OutputWidth() + ", " + OutputHeight() + ")")
                  Else
                    Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
                    debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
                  EndIf
                  StopDrawing()
                  debugMsgD(sProcName, "StopDrawing()")
                EndIf
              EndIf
              If (bLogoExists) And (n <> nLogoMonitorNo)
                setVisible(nCanvasNo, #False)
              EndIf
            EndIf
          EndIf
        Next n
        
        debugMsgC(sProcName, "nVisibleCanvas=" + nVisibleCanvas)
        If bLogoExists
          If IsWindow(nMonitorWindowNo)
            If nVisibleCanvas = 0
              nCanvasNo = \aMonitor(0)\cvsMonitorCanvas
              If nLogoFadeInTime > 0
                setCurrMonitorCanvasNo(pVidPicTarget)
                debugMsgC(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nCurrMonitorCanvasNo=" + grVidPicTarget(pVidPicTarget)\nCurrMonitorCanvasNo +
                                     ", " + getGadgetName(grVidPicTarget(pVidPicTarget)\nCurrMonitorCanvasNo))
              Else
                If StartDrawing(CanvasOutput(nCanvasNo))
                  debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
                  DrawImage(ImageID(nImageNo),0,0,OutputWidth(),OutputHeight())
                  debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nImageNo) + "),0,0," + OutputWidth() + "," + OutputHeight() + ")")
                  StopDrawing()
                  debugMsgD(sProcName, "StopDrawing()")
                EndIf
              EndIf
              If getVisible(nCanvasNo) = #False
                setVisible(nCanvasNo, #True)
              EndIf
            EndIf
            debugMsgC(sProcName, "calling setWindowVisible(" + decodeWindow(nMonitorWindowNo) + ", #True)")
            setWindowVisible(nMonitorWindowNo, #True)
          EndIf
        EndIf
        
      EndWith
      
  EndSelect
EndProcedure

Procedure hideMonitorsNotInUse()
  PROCNAMEC()
  Protected i, j, k
  Protected Dim bMonitorInUse(#SCS_VID_PIC_TARGET_LAST)
  Protected nScreenNo
  Protected nVidPicTarget
  Protected nMonitorWindowNo
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    ; debugMsgC(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
    If (aCue(i)\nCueState >= #SCS_CUE_READY) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          ; debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(\nSubState))
          If (\nSubState >= #SCS_CUE_READY) And (\nSubState <= #SCS_CUE_FADING_OUT) And aSub(j)\bSubEnabled
            If \bStartedInEditor = #False
              nScreenNo = -1
              If \bSubTypeA
                nScreenNo = \nOutputScreen
              ElseIf \bSubTypeE
                nScreenNo = \nMemoScreen
              EndIf
              
              If \nSubState >= #SCS_CUE_FADING_IN
                If \bSubTypeA And grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX ; vMix test added 11Apr2020 11.8.2.3ar
                  For nScreenNo = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                    If \bOutputScreenReqd(nScreenNo)
                      bMonitorInUse(nScreenNo) = #True
                      debugMsgC(sProcName, "bMonitorInUse(" + nScreenNo + ")=#True")
                    EndIf
                  Next nScreenNo
                Else
                  Select nScreenNo
                    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                      bMonitorInUse(nScreenNo) = #True
                      debugMsgC(sProcName, "bMonitorInUse(" + nScreenNo + ")=#True")
                  EndSelect
                EndIf
                
              ElseIf \nSubState = #SCS_CUE_READY
                k = \nFirstAudIndex
                While k >= 0
                  If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
                    For nScreenNo = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                      If \bOutputScreenReqd(nScreenNo)
                        bMonitorInUse(nScreenNo) = #True
                        debugMsgC(sProcName, "bMonitorInUse(" + nScreenNo + ")=#True")
                      EndIf
                    Next nScreenNo
                  EndIf
                  k = aAud(k)\nNextAudIndex
                Wend
              EndIf
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  Next i
  
  For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To grLicInfo\nLastVidPicTarget
    nMonitorWindowNo = grVidPicTarget(nVidPicTarget)\nMonitorWindowNo
    If bMonitorInUse(nVidPicTarget) = #False
      If IsImage(grVidPicTarget(nVidPicTarget)\nLogoImageNo)
        debugMsgC(sProcName, "calling clearMonitor(" + decodeVidPicTarget(nVidPicTarget) + ")")
        clearMonitor(nVidPicTarget)
      ElseIf IsWindow(nMonitorWindowNo)
        If getWindowVisible(nMonitorWindowNo)
          setWindowVisible(nMonitorWindowNo, #False)
          debugMsgC(sProcName, "setWindowVisible(" + decodeWindow(nMonitorWindowNo) + ", #False)")
        EndIf
      EndIf
    Else
      If IsWindow(nMonitorWindowNo)
        If getWindowVisible(nMonitorWindowNo) = #False
          setWindowVisible(nMonitorWindowNo, #True)
          debugMsgC(sProcName, "setWindowVisible(" + decodeWindow(nMonitorWindowNo) + ", #True)")
        EndIf
      EndIf
    EndIf
  Next nVidPicTarget
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure hideVideoWindowIfNotInUse(pVidPicTarget)
  PROCNAMEC()
  Protected bWindowInUse
  Protected nMainWindowNo
  Protected nScreenNo, nSubScreenNo
  Protected nPrimarySubPtr
  Protected j
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If gbVideosOnMainWindow
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nScreenNo = pVidPicTarget - #SCS_VID_PIC_TARGET_F2 + 2
        
        With grVidPicTarget(pVidPicTarget)
          If \nPrimaryAudPtr >= 0
            nPrimarySubPtr = aAud(\nPrimaryAudPtr)\nSubIndex
          ElseIf \nPlayingSubPtr >= 0
            nPrimarySubPtr = \nPlayingSubPtr
          EndIf
        EndWith
        
        For j = 1 To gnLastSub
          With aSub(j)
            nSubScreenNo = 0
            If \bSubTypeA And grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX ; vMix test added 11Apr2020 11.8.2.3ar
              nSubScreenNo = \nOutputScreen
            ElseIf \bSubTypeE
              nSubScreenNo = \nMemoScreen
            EndIf
            If nSubScreenNo = nScreenNo
              If \bExists
                If ((\nSubState >= #SCS_CUE_FADING_IN) And (\nSubState <= #SCS_CUE_FADING_OUT)) ; Or (j = nPrimarySubPtr)
                  ; nb test (j = nPrimarySubPtr) is to handle calls to the procedure for a sub or aud that has been designated for playing
                  ; but where \nSubState has not yet been set to 'playing', etc
                  bWindowInUse = #True
                  debugMsg(sProcName, "screen " + Str(nScreenNo) + " currently used by aSub(" + getSubLabel(j) + ")")
                  Break
                EndIf
              EndIf
            EndIf
          EndWith
        Next j
        
        With grVidPicTarget(pVidPicTarget)
          If bWindowInUse = #False
            If IsImage(\nLogoImageNo)
              debugMsg(sProcName, "calling clearPicture(" + decodeVidPicTarget(pVidPicTarget) + ")")
              clearPicture(pVidPicTarget)
            Else
              nMainWindowNo = \nMainWindowNo
              If IsWindow(nMainWindowNo)
                If getWindowVisible(nMainWindowNo)
                  setWindowVisible(nMainWindowNo, #False)
                EndIf
              EndIf
            EndIf
          Else
            nMainWindowNo = \nMainWindowNo
            If IsWindow(nMainWindowNo)
              If getWindowVisible(nMainWindowNo) = #False
                setWindowVisible(nMainWindowNo, #True)
              EndIf
            EndIf
          EndIf
        EndWith
        
    EndSelect
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure hideVideoWindowsNotInUse()
  PROCNAMEC()
  Protected nVidPicTarget
  
  If gbVideosOnMainWindow
    For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To grLicInfo\nLastVidPicTarget
      debugMsg(sProcName, "calling hideVideoWindowIfNotInUse(" + decodeVidPicTarget(nVidPicTarget) + ")")
      hideVideoWindowIfNotInUse(nVidPicTarget)
    Next nVidPicTarget
  EndIf
EndProcedure

Procedure clearVideoCanvasIfNotInUse(pVidPicTarget)
  PROCNAMEC()
  Protected bWindowInUse
  Protected nScreenNo
  Protected i, j
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      nScreenNo = pVidPicTarget - #SCS_VID_PIC_TARGET_F2 + 2
      
      For i = 1 To gnLastCue
        If aCue(i)\bCueEnabled
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            With aSub(j)
              If \bSubEnabled
                If (\nSubState >= #SCS_CUE_FADING_IN And \nSubState <= #SCS_CUE_FADING_OUT) Or (j = nEditSubPtr And gbPreviewOnOutputScreen)
                  If \bSubTypeA
                    If \bOutputScreenReqd(pVidPicTarget)
                      bWindowInUse = #True
                      debugMsg(sProcName, "screen " + nScreenNo + " currently used by aSub(" + getSubLabel(j) + "), \nSubState=" + decodeCueState(\nSubState))
                      Break 2 ; Break j, i
                    EndIf
                  ElseIf \bSubTypeE
                    If \nMemoScreen = nScreenNo
                      bWindowInUse = #True
                      debugMsg(sProcName, "screen " + nScreenNo + " currently used by aSub(" + getSubLabel(j) + "), \nSubState=" + decodeCueState(\nSubState))
                      Break 2 ; Break j, i
                    EndIf
                  EndIf
                EndIf
              EndIf ; EndIf \bSubEnabled
              j = \nNextSubIndex
            EndWith
          Wend
        EndIf ; EndIf aCue(i)\bCueEnabled
      Next i
      
      If bWindowInUse = #False
        debugMsg(sProcName, "calling clearPicture(" + decodeVidPicTarget(pVidPicTarget) + ")")
        clearPicture(pVidPicTarget)
      EndIf
      
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setVideoRendererFlag(nVideoPlaybackLibrary)
  PROCNAMEC()
  Protected nXVRendererToUse
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grVideoDriver
    Select nVideoPlaybackLibrary
      Case #SCS_VPL_TVG
        CompilerIf #c_include_tvg
          Select \nTVGVideoRenderer
            Case #SCS_VR_AUTOSELECT
              \nTVGVideoRendererTVGValue = #tvc_vr_AutoSelect
            Case #SCS_VR_EVR
              \nTVGVideoRendererTVGValue = #tvc_vr_EVR
            Case #SCS_VR_VMR9
              \nTVGVideoRendererTVGValue = #tvc_vr_VMR9
            Case #SCS_VR_VMR7
              \nTVGVideoRendererTVGValue = #tvc_vr_VMR7
            Case #SCS_VR_STANDARD
              \nTVGVideoRendererTVGValue = #tvc_vr_StandardRenderer
            Case #SCS_VR_OVERLAY
              \nTVGVideoRendererTVGValue = #tvc_vr_OverlayRenderer
            Default
              \nTVGVideoRendererTVGValue = #tvc_vr_AutoSelect
          EndSelect
          ; debugMsg(sProcName, "\nTVGVideoRenderer=" + decodeVideoRenderer(\nTVGVideoRenderer, \nVideoPlaybackLibrary) + ", \nTVGVideoRendererTVGValue=" + Str(\nTVGVideoRendererTVGValue))
        CompilerEndIf
        
    EndSelect
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getVideoRendererForScreen(nScreenNo)
  ; PROCNAMEC()
  Protected n, nVideoRendererForScreen
  
  nVideoRendererForScreen = #SCS_VR_AUTOSELECT
  With grCurrScreenVideoRenderers
    ; debugMsg(sProcName, "grCurrScreenVideoRenderers\nMaxCurrScreenVideoRenderer=" + \nMaxCurrScreenVideoRenderer)
    For n = 0 To \nMaxCurrScreenVideoRenderer
      ; debugMsg(sProcName, "\aCurrScreenVideoRenderer(" + n + ")\nDisplayNo=" + \aCurrScreenVideoRenderer(n)\nDisplayNo + ", \nScreenVideoRenderer=" + decodeVideoRenderer(\aCurrScreenVideoRenderer(n)\nScreenVideoRenderer))
      If \aCurrScreenVideoRenderer(n)\nDisplayNo = nScreenNo
        nVideoRendererForScreen = \aCurrScreenVideoRenderer(n)\nScreenVideoRenderer
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nVideoRendererForScreen
  
EndProcedure

Procedure setTimeLineVidPicTargets(pSubPtr, pVidPicTarget)
  PROCNAMECS(pSubPtr)
  Protected k
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If pSubPtr >= 0
    k = aSub(pSubPtr)\nFirstPlayIndex
    While k >= 0
      aAud(k)\nAudVidPicTarget = pVidPicTarget
      k = aAud(k)\nNextPlayIndex
    Wend
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure reposAtNextAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nNextAudIndex
  Protected nSubIndex
  Protected nPos
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    nNextAudIndex = aAud(pAudPtr)\nNextPlayIndex
    If nNextAudIndex = -1
      nSubIndex = aAud(pAudPtr)\nSubIndex
      ; If aSub(nSubIndex)\bPLRepeat
      If getPLRepeatActive(nSubIndex)
        nNextAudIndex = aSub(nSubIndex)\nFirstPlayIndex
      EndIf
    EndIf
    If nNextAudIndex >= 0
      ; nPos = aAud(nNextAudIndex)\nTimelineInsertTime
      nPos = 0  ; reposAuds() already handles \nTimelineInsertTime so we just need to start at the beginning of the next aud
      If nPos >= 0
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nNextAudIndex) + ", " + Str(nPos) + ")")
        reposAuds(nNextAudIndex, nPos)
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setAudLevelsForSubAorP(pSubPtr)
  ; PROCNAMECS(pSubPtr)
  Protected d, k
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeAorP
        k = \nFirstAudIndex
        While k >= 0
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If aAud(k)\fPLRelLevel = 100.0
              aAud(k)\fAudPlayBVLevel[d] = \fSubMastBVLevel[d]
            Else
              aAud(k)\fAudPlayBVLevel[d] = \fSubMastBVLevel[d] * aAud(k)\fPLRelLevel / 100.0
            EndIf
            aAud(k)\fBVLevel[d] = aAud(k)\fAudPlayBVLevel[d]
            aAud(k)\fAudPlayPan[d] = \fPLPan[d]
            aAud(k)\fPan[d] = aAud(k)\fAudPlayPan[d]
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fAudPlayBVLevel(" + d + ")=" + formatLevel(aAud(k)\fAudPlayBVLevel[d]) + ", \fAudPlayPan(" + d + ")=" + formatPan(aAud(k)\fAudPlayPan[d]))
            aAud(k)\fSavedBVLevel[d] = aAud(k)\fBVLevel[d]
            aAud(k)\fSavedPan[d] = aAud(k)\fPan[d]
          Next d
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure setMMediaGaplessSeqPtr()
  PROCNAMEC()
  Protected i, j, k
  Protected nGaplessSeqPtr = -1
  
  ; debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \nSubGaplessSeqPtr >= 0 And aSub(j)\bSubEnabled
            If (\nSubState >= #SCS_CUE_READY) And (\nSubState < #SCS_CUE_COMPLETED)
              nGaplessSeqPtr = \nSubGaplessSeqPtr
              debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubGaplessSeqPtr=" + \nSubGaplessSeqPtr + ", \nSubState=" + decodeCueState(\nSubState))
              Break
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
      If nGaplessSeqPtr >= 0
        Break
      EndIf
    EndIf
  Next i
  grMMedia\nCurrGaplessSeqPtr = nGaplessSeqPtr
  If grMMedia\nCurrGaplessSeqPtr >= 0
    debugMsg(sProcName, "grMMedia\nCurrGaplessSeqPtr=" + grMMedia\nCurrGaplessSeqPtr)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkOKToOpenGaplessVideo(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nGaplessSeqPtr
  Protected bOKToOpen = #True
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    nGaplessSeqPtr = aAud(pAudPtr)\nAudGaplessSeqPtr
    If nGaplessSeqPtr >= 0
      If (grMMedia\nCurrGaplessSeqPtr >= 0) And (grMMedia\nCurrGaplessSeqPtr <> nGaplessSeqPtr)
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudGaplessSeqPtr=" + Str(aAud(pAudPtr)\nAudGaplessSeqPtr) + ", grMMedia\nCurrGaplessSeqPtr=" + Str(grMMedia\nCurrGaplessSeqPtr))
        bOKToOpen = #False
      Else
        grMMedia\nCurrGaplessSeqPtr = nGaplessSeqPtr
        debugMsg(sProcName, "grMMedia\nCurrGaplessSeqPtr=" + grMMedia\nCurrGaplessSeqPtr)
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bOKToOpen))
  ProcedureReturn bOKToOpen
  
EndProcedure

Procedure checkOKToOpenVideoFile(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nCheckOutputScreen, nVideoImageFilesOpen
  Protected i, j, k
  Protected bOKToOpen = #True
  
  With aAud(pAudPtr)
    If (\bAudTypeA) ; And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)
      If (aCue(\nCueIndex)\bHotkey = #False) And (aCue(\nCueIndex)\bExtAct = #False)
        nCheckOutputScreen = aSub(\nSubIndex)\nOutputScreen
        For i = 1 To gnLastCue
          If aCue(i)\bSubTypeA
            If (aCue(i)\nCueState >= #SCS_CUE_READY) And (aCue(i)\nCueState < #SCS_CUE_COMPLETED)
              If (aCue(i)\bHotkey = #False) And (aCue(i)\bExtAct = #False)
                j = aCue(i)\nFirstSubIndex
                While j >= 0
                  If aSub(j)\nOutputScreen = nCheckOutputScreen
                    k = aSub(j)\nFirstPlayIndex
                    While k >= 0
                      If k <> pAudPtr
                        If (aAud(k)\bAudPlaceHolder = #False) And (aAud(k)\nFileFormat = #SCS_FILEFORMAT_VIDEO)
                          If (aAud(k)\nAudState >= #SCS_CUE_READY) And (aAud(k)\nAudState < #SCS_CUE_COMPLETED)
                            nVideoImageFilesOpen + 1
                            If nVideoImageFilesOpen >= grGeneralOptions\nMaxPreOpenVideoImageFiles
                              bOKToOpen = #False
                              Break 3 ; Break k, j, i
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                      k = aAud(k)\nNextPlayIndex
                    Wend ; Wend While k >= 0
                  EndIf ; EndIf aSub(j)\nOutputScreen = nCheckOutputScreen
                  j = aSub(j)\nNextSubIndex
                Wend ; Wend While j >= 0
              EndIf ; EndIf (aCue(i)\bHotkey = #False) And (aCue(i)\bExtAct = #False)
            EndIf ; EndIf (aCue(i)\nCueState >= #SCS_CUE_READY) And (aCue(i)\nCueState < #SCS_CUE_COMPLETED)
          EndIf ; EndIf aCue(i)\bSubTypeA
        Next i
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn bOKToOpen
 
EndProcedure

Procedure freeSomeImages(pAudPtr, pMaxCuesToClose=5)
  PROCNAMECA(pAudPtr)
  Protected nCuePtr
  Protected i
  Protected nCuesClosed
  Protected nFirstCue, nLastCue, nStep
  
  debugMsg(sProcName, #SCS_START + ", pMaxCuesToClose=" + pMaxCuesToClose)
  
  If pAudPtr >= 0
    nCuePtr = aAud(pAudPtr)\nCueIndex
    If gbEditing
      nFirstCue = 1
      nLastCue = gnLastCue
      nStep = 1
    Else
      nFirstCue = gnLastCue
      nLastCue = 1
      nStep = -1
    EndIf
    debugMsg(sProcName, "nCuePtr=" + getCueLabel(nCuePtr) + ", nFirstCue=" + getCueLabel(nFirstCue) + ", nLastCue=" + getCueLabel(nLastCue) + ", nStep=" + Str(nStep))
    i = nFirstCue
    While #True
      If i <> nCuePtr
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bSubTypeA=" + strB(aCue(i)\bSubTypeA) + ", \nCueState=" + decodeCueState(aCue(i)\nCueState))
        If aCue(i)\bSubTypeA
          If aCue(i)\nCueState = #SCS_CUE_READY
            If (i < gnCueToGo) Or (i > gnCueToGo + 1)
              debugMsg(sProcName, "calling closeCue(" + getCueLabel(i) + ", #False, #False)")
              closeCue(i, #False, #False)
              nCuesClosed + 1
              If nCuesClosed >= pMaxCuesToClose
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      If i = nLastCue
        Break
      Else
        i + nStep
      EndIf
    Wend
  EndIf
  debugMsg(sProcName, #SCS_END + ", closed " + Str(nCuesClosed))
  ProcedureReturn nCuesClosed
EndProcedure

Procedure primeVideoForTarget(pAudPtr, pVidPicTarget, bClearStatusLineAfterPrime)
  PROCNAMECA(pAudPtr)
  Protected nChannel
  Protected nVideoCanvasNo
  Protected nMonitorWindowNo, nMonitorCanvasNo
  Protected nSourceWidth, nSourceHeight
  Protected nVideoWidth, nVideoHeight
  Protected nMonitorWidth, nMonitorHeight
  Protected nLeft, nTop, nWidth, nHeight
  Protected dSetPos.d
  Protected sVideoCanvas.s, sMonitorCanvas.s
  Protected sStatusMsg.s
  Protected nSubPtr
  Protected nLongResult.l
  Protected fAlpha.f
  Static sPriming.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If bStaticLoaded = #False
    sPriming = Lang("MMedia", "Priming")
    bStaticLoaded = #True
  EndIf
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      
      \bPrimeVideoReqd = #False
      debugMsg(sProcName, "\bPrimeVideoReqd=" + strB(\bPrimeVideoReqd))
      
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
          ; continue
        Default
          debugMsg(sProcName, "exiting because pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
          ProcedureReturn
      EndSelect

      If grVideoMonitors\bDisplayMonitorWindows
        sStatusMsg = ReplaceString(sPriming, "$1", \sAudLabel + " " + GetFilePart(\sFileName))
        WMN_setStatusField(sStatusMsg, #SCS_STATUS_WARN, 10000, #True)
      EndIf
      
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          nVideoCanvasNo = \nAudVideoCanvasNo(pVidPicTarget)
          If IsGadget(nVideoCanvasNo) = #False
            debugMsg(sProcName, "calling assignCanvases(" + getSubLabel(\nSubIndex) + ", " + getAudLabel(nEditAudPtr) + ")")
            assignCanvases(\nSubIndex)
            nVideoCanvasNo = \nAudVideoCanvasNo(pVidPicTarget)
          EndIf
          nMonitorCanvasNo = \nAudMonitorCanvasNo
          nMonitorWidth = grVidPicTarget(pVidPicTarget)\nMonitorWidth
          nMonitorHeight = grVidPicTarget(pVidPicTarget)\nMonitorHeight
          nChannel = \nMainVideoNo
        Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
          nVideoCanvasNo = WQA\cvsPreview
          nMonitorCanvasNo = 0
          nChannel = \nPreviewVideoNo
      EndSelect
      If grVideoMonitors\bDisplayMonitorWindows = #False
        nMonitorCanvasNo = 0
      EndIf
      
      If IsGadget(nVideoCanvasNo)
        sVideoCanvas = getGadgetName(nVideoCanvasNo)
      EndIf
      If IsGadget(nMonitorCanvasNo)
        sMonitorCanvas = getGadgetName(nMonitorCanvasNo)
      EndIf
      debugMsg(sProcName, "nChannel=" + decodeHandle(nChannel) + ", nVideoCanvasNo=" + sVideoCanvas + ", nMonitorCanvasNo=" + sMonitorCanvas)
      
      If grVideoMonitors\bDisplayMonitorWindows
        If bClearStatusLineAfterPrime
          debugMsg(sProcName, "clearing status field")
          WMN_setStatusField("", #SCS_STATUS_CLEAR)
        Else
          WMN_setStatusField(sStatusMsg, #SCS_STATUS_WARN, (2000 - #SCS_STATUS_DISPLAY_TIME)) ; force message to timeout after 2 seconds
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkForPrimeVideoReqd()
  PROCNAMEC()
  Protected i, j, k
  Protected bQuit
  Protected bVideoPrimed
  Protected bVideoPlaying
  Protected qTimeNow.q
  Static qLastTimeChecked,q
  Protected bPrimeVideoStillReqd
  
  debugMsg(sProcName, #SCS_START)
  
  If gbCheckForPrimeVideoReqd
    
    If gbClosingDown
      ; got here during a test by Felix Grimm - email 09/08/2013 log1.zip
      gbCheckForPrimeVideoReqd = #False
      ; debugMsg(sProcName, "gbCheckForPrimeVideoReqd=" + strB(gbCheckForPrimeVideoReqd))
      ProcedureReturn
    EndIf
    
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeA
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeA And aSub(j)\bSubEnabled
            If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
              bVideoPlaying = #True
              Break
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      If bVideoPlaying
        Break
      EndIf
    Next i
    
    ; debugMsg(sProcName, "bVideoPlaying=" + strB(bVideoPlaying) + ", gnCueToGo=" + getCueLabel(gnCueToGo))
    For i = 1 To gnLastCue
      If (bVideoPlaying = #False) Or (i = gnCueToGo)
        If aCue(i)\bSubTypeA
          j = aCue(i)\nFirstSubIndex
          While (j >= 0) And (bQuit = #False)
            If aSub(j)\bSubTypeA
              k = aSub(j)\nFirstAudIndex
              While (k >= 0) And (bQuit = #False)
                With aAud(k)
                  If \bPrimeVideoReqd
                    Select \nPrimeVideoVidPicTarget
                      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
                        debugMsg(sProcName, "calling primeVideoForTarget(" + getAudLabel(k) + ", " + decodeVidPicTarget(\nPrimeVideoVidPicTarget) + ", #False)")
                        primeVideoForTarget(k, \nPrimeVideoVidPicTarget, #False)
                        bQuit = #True
                        bVideoPrimed = #True
                        Break
                      Default
                        \bPrimeVideoReqd = #False
                    EndSelect
                  EndIf
                  k = \nNextAudIndex
                EndWith
              Wend
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
        If bQuit
          Break
        EndIf
      EndIf
    Next i
    
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeA
        j = aCue(i)\nFirstSubIndex
        While (j >= 0) And (bPrimeVideoStillReqd = #False)
          If aSub(j)\bSubTypeA
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              With aAud(k)
                If \bPrimeVideoReqd
                  ; debugMsg(sProcName, "(2) aAud(" + getAudLabel(k) + ")\bPrimeVideoReqd=" + strB(\bPrimeVideoReqd))
                  bPrimeVideoStillReqd = #True
                  Break
                EndIf
                k = \nNextAudIndex
              EndWith
            Wend
            If bPrimeVideoStillReqd
              Break
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      If bPrimeVideoStillReqd
        Break
      EndIf
    Next i
    If bPrimeVideoStillReqd = #False
      ; no more videos awaiting priming
      If bVideoPrimed
        debugMsg(sProcName, "clearing status field")
        WMN_setStatusField("", #SCS_STATUS_CLEAR)
      EndIf
      gbCheckForPrimeVideoReqd = #False
      debugMsg(sProcName, "gbCheckForPrimeVideoReqd=" + strB(gbCheckForPrimeVideoReqd))
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkManyFilesOK(nFileCount)
  PROCNAMEC()
  Protected sTitle.s, sMsg.s
  Protected nReply
  
  sTitle = Lang("Requesters", "FileSelector")
  sMsg = LangPars("Requesters", "ManyFiles", Str(nFileCount))
  nReply = scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_YesNo|#MB_ICONEXCLAMATION)
  If nReply = #PB_MessageRequester_Yes
    debugMsg(sProcName, sMsg + " [Reply=Yes]")
    ProcedureReturn #True
  Else
    debugMsg(sProcName, sMsg + " [Reply=No]")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure setLockMixerStreamInds(pCuePtr=-1)
  PROCNAMECQ(pCuePtr)
  Protected i, j, k, d
  Protected nFirstCue, nLastCue
  Protected bLockMixerStreamsOnPlayCue
  Protected bLockMixerStreamsOnPlaySub
  Protected nAudioSubCueCount, nAudioDevCount
  
  If pCuePtr = -1
    nFirstCue = 1
    nLastCue = gnLastCue
  Else
    nFirstCue = pCuePtr
    nLastCue = pCuePtr
  EndIf
  
  For i = nFirstCue To nLastCue
    bLockMixerStreamsOnPlayCue = #False
    nAudioSubCueCount = 0
    nAudioDevCount = 0
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If aSub(j)\bSubEnabled
          bLockMixerStreamsOnPlaySub = #False
          If gbUseBASSMixer
            If \bSubTypeForP
              nAudioSubCueCount + 1
              If \bSubTypeF
                k = \nFirstAudIndex
                If k >= 0
                  For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                    If aAud(k)\sLogicalDev[d]
                      nAudioDevCount + 1
                    EndIf
                  Next d
                EndIf
              ElseIf \bSubTypeP
                For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                  If \sPLLogicalDev[d]
                    nAudioDevCount + 1
                  EndIf
                Next d
              EndIf
              Select \nRelStartMode
                Case #SCS_RELSTART_DEFAULT
                  bLockMixerStreamsOnPlayCue = #True
                Case #SCS_RELSTART_AS_CUE, #SCS_RELSTART_AS_PREV_SUB
                  If \nRelStartTime <= 0
                    bLockMixerStreamsOnPlayCue = #True
                  EndIf
              EndSelect
              bLockMixerStreamsOnPlaySub = #True
            EndIf
          EndIf
          \bLockMixerStreamsOnPlaySub = bLockMixerStreamsOnPlaySub
        EndIf
        j = \nNextSubIndex
      EndWith
      
      If (nAudioSubCueCount < 2) And (nAudioDevCount < 2)
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          aSub(j)\bLockMixerStreamsOnPlaySub = #False
          j = aSub(j)\nNextSubIndex
        Wend
        bLockMixerStreamsOnPlayCue = #False ; nb may be reset #True if linked (see below)
      EndIf
        
    Wend
    
    With aCue(i)
      If gbUseBASSMixer
        If (\nLinkedToCuePtr >= 0) Or (\nCueLinkCount > 0)
          bLockMixerStreamsOnPlayCue = #True
        EndIf
      EndIf
      If \bSubTypeA
        If gnCurrAudioDriver = #SCS_DRV_BASS_ASIO
          bLockMixerStreamsOnPlayCue = #False
          ; aCue(i)\bLockMixerStreamsOnPlayCue = #False because if a cue contains a video sub-cue then locking the mixer streams for the whole cue
          ; can cause a glitch in audio playback when using BASSASIO. (reported by Sven Tegethoff, 8/7/14)
          ; note that playSubTypeF() will implement mixer stream locking if the cue also contains an audio file sub-cue.
        EndIf
      EndIf
      \bLockMixerStreamsOnPlayCue = bLockMixerStreamsOnPlayCue
    EndWith
    
  Next i
EndProcedure

Procedure setVideoChannelAssigned(pChannel.l, bAssigned)
  PROCNAMEC()
  Protected n, bFound
  
  debugMsg(sProcName, #SCS_START + ", pChannel=" + decodeHandle(pChannel) + ", bAssigned=" + strB(bAssigned))
  
  For n = 0 To gnMaxVideoChannel
    With gaVideoChannelInfo(n)
      If \nVideoChannel = pChannel
        bFound = #True
        \bChannelAssigned = bAssigned
      EndIf
    EndWith
  Next n
  If bFound = #False
    gnMaxVideoChannel + 1
    If gnMaxVideoChannel > ArraySize(gaVideoChannelInfo())
      ReDim gaVideoChannelInfo(gnMaxVideoChannel + 20)
    EndIf
    With gaVideoChannelInfo(gnMaxVideoChannel)
      \nVideoChannel = pChannel
      \bChannelAssigned = bAssigned
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", gnMaxVideoChannel=" + gnMaxVideoChannel)
  
EndProcedure

Procedure getVideoChannelAssigned(pChannel.l)
  PROCNAMEC()
  Protected bAssigned
  Protected n
  
  For n = 0 To gnMaxVideoChannel
    With gaVideoChannelInfo(n)
      If \nVideoChannel = pChannel
        bAssigned = \bChannelAssigned
        Break
      EndIf
    EndWith
  Next n
  ProcedureReturn bAssigned
EndProcedure

Procedure closeAudIfAllInputsOff(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bCloseAud
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      bCloseAud = #True
      For d = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
        If Len(\sInputLogicalDev[d]) > 0
          If \bInputCurrentlyOff[d] = #False
            bCloseAud = #False
            Break
          EndIf
        EndIf
      Next d
      If bCloseAud
        debugMsg(sProcName, "calling closeAud(" + getAudLabel(pAudPtr) + ", #False, #True)")
        closeAud(pAudPtr, #False, #True)
        setCueState(\nCueIndex)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure muteAllPlayingInputs(pExcludingAudPtr)
  PROCNAMEC()
  Protected i, j, k
  Protected bCallSetCueState
  
  For i = 1 To gnLastCue
    bCallSetCueState = #False
    If aCue(i)\bSubTypeI
      If aCue(i)\nCueState >= #SCS_CUE_FADING_IN And aCue(i)\nCueState <= #SCS_CUE_FADING_OUT
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeI And aSub(j)\bSubEnabled
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If k <> pExcludingAudPtr
                If aAud(k)\nAudState >= #SCS_CUE_FADING_IN And aAud(k)\nAudState <= #SCS_CUE_FADING_OUT
                  stopAud(k)
                  bCallSetCueState = #True
                EndIf
              EndIf
            Wend
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    EndIf
    If bCallSetCueState
      setCueState(i)
    EndIf
  Next i
EndProcedure

Procedure setInputOnOffCounts(pAudPtr, bPrimaryFile=#True)
  PROCNAMECA(pAudPtr)
  Protected nInputOnCount, nInputOffCount
  Protected d
  
  If pAudPtr >= 0
    If bPrimaryFile
      With aAud(pAudPtr)
        If \bAudTypeI
          For d = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
            If \sInputLogicalDev[d]
              If \bInputOff[d] : nInputOffCount + 1 : Else : nInputOnCount + 1 : EndIf
            EndIf
          Next d
        EndIf
        \nInputOnCount = nInputOnCount
        \nInputOffCount = nInputOffCount
      EndWith
    Else
      With a2ndAud(pAudPtr)
        If \bAudTypeI
          For d = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
            If \sInputLogicalDev[d]
              If \bInputOff[d] : nInputOffCount + 1 : Else : nInputOnCount + 1 : EndIf
            EndIf
          Next d
        EndIf
        \nInputOnCount = nInputOnCount
        \nInputOffCount = nInputOffCount
      EndWith
    EndIf
  EndIf
EndProcedure

Procedure processInputsOff(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d, d2, i, j, k
  Protected sInputLogicalDev.s
  Protected bCheckForCloseAud
  Protected nReqdFadeTime
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nInputOffCount > 0
        For d = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
          If Len(\sInputLogicalDev[d]) > 0
            If \bInputOff[d]
              sInputLogicalDev = \sInputLogicalDev[d]
              debugMsg(sProcName, "turn off " + sInputLogicalDev)
              For i = 1 To gnLastCue
                If aCue(i)\bSubTypeI
                  If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
                    j = aCue(i)\nFirstSubIndex
                    While j >= 0
                      If aSub(j)\bSubTypeI And aSub(j)\bSubEnabled
                        If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
                          k = aSub(j)\nFirstAudIndex
                          While k >= 0
                            bCheckForCloseAud = #False
                            If aAud(k)\nCurrFadeOutTime >= 0
                              nReqdFadeTime = aAud(k)\nCurrFadeOutTime
                            Else
                              nReqdFadeTime = 0
                            EndIf
                            For d2 = 0 To #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
                              If Len(aAud(k)\sInputLogicalDev[d2]) > 0
                                debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sInputLogicalDev[" + d2 + "]=" + aAud(k)\sInputLogicalDev[d2])
                              EndIf
                              If (aAud(k)\sInputLogicalDev[d2] = sInputLogicalDev) And (aAud(k)\bInputCurrentlyOff[d2] = #False)
                                debugMsg(sProcName, "setting aAud(" + getAudLabel(k) + ")\bInputCurrentlyOff[" + d2 + "] = #True")
                                aAud(k)\bInputCurrentlyOff[d2] = #True
                                setLevelsForSMSInputDev(k, d2, nReqdFadeTime)
                                bCheckForCloseAud = #True
                              EndIf
                            Next d2
                            If bCheckForCloseAud
                              closeAudIfAllInputsOff(k)
                            EndIf
                            k = aAud(k)\nNextAudIndex
                          Wend
                        EndIf
                      EndIf
                      j = aSub(j)\nNextSubIndex
                    Wend
                  EndIf
                EndIf
              Next i
            EndIf
          EndIf
        Next
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure IsScreenReqd(nScreenNo)
  PROCNAMEC()
  Protected i, j
  Protected bScreenReqd
  
  For i = 1 To gnLastCue
    If (aCue(i)\bSubTypeA) Or (aCue(i)\bSubTypeE)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If aSub(j)\bSubEnabled
            If \bSubTypeA
              If \nOutputScreen = nScreenNo
                bScreenReqd = #True
                Break
              EndIf
            EndIf
            If \bSubTypeE
              If \nMemoScreen = nScreenNo
                bScreenReqd = #True
                Break
              EndIf
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
      If bScreenReqd
        Break
      EndIf
    EndIf
  Next i
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bScreenReqd))
  ProcedureReturn bScreenReqd
EndProcedure

Procedure playNextAud(pThisAudPtr, pNextAudPtr)
  PROCNAMECA(pThisAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If pThisAudPtr >= 0
    If aAud(pThisAudPtr)\bPlayNextAudRequested
      ProcedureReturn
    EndIf
    If gnThreadNo > #SCS_THREAD_MAIN
      samAddRequest(#SCS_SAM_PLAY_NEXT_AUD, pThisAudPtr, 0, pNextAudPtr)
      ProcedureReturn
    EndIf
    
    aAud(pThisAudPtr)\bPlayNextAudRequested = #True
    
    If pNextAudPtr >= 0
      With aAud(pNextAudPtr)
        \qPLTimeTransStarted = gqTimeNow
        debugMsg(sProcName, "calling playAud(" + getAudLabel(pNextAudPtr) + ")")
        playAud(pNextAudPtr, #False, #False, -1, #True, #False)
        \qTimeAudStarted = gqTimeNow
        ; \nTimeAudEnded = 0
        \bTimeAudEndedSet = #False
        \qTimeAudRestarted = gqTimeNow
        debugMsg(sProcName, "aAud(" + getAudLabel(pNextAudPtr) + ")\qTimeAudRestarted=" + traceTime(\qTimeAudRestarted))
        \nTotalTimeOnPause = 0
        \nPreFadeInTimeOnPause = 0
        \nPreFadeOutTimeOnPause = 0
        aSub(\nSubIndex)\nCurrPlayIndex = pNextAudPtr
        debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\nCurrPlayIndex=" + getAudLabel(aSub(\nSubIndex)\nCurrPlayIndex))
        debugMsg(sProcName, "calling calcPLUnplayedFilesTime(" + getSubLabel(\nSubIndex) + ")")
        calcPLUnplayedFilesTime(\nSubIndex)
        If (gbEditing) And (nEditSubPtr = \nSubIndex)
          samAddRequest(#SCS_SAM_SET_CURR_QA_ITEM, WQA_getItemForAud(pNextAudPtr))
        EndIf
      EndWith
    EndIf
    
    ; Changed 14May2020 11.8.3rc4 to avoid brief black image between consecutive images within a 'slide show'
    ; See also similar code in stopInactiveVideoImageSubs().
    ; Old code:
    ; debugMsg(sProcName, "calling stopAud(" + getAudLabel(pThisAudPtr) + ")")
    ; stopAud(pThisAudPtr)
    ; New code:
    If aAud(pThisAudPtr)\nCurrFadeOutTime <= 0
      aAud(pThisAudPtr)\nCurrFadeOutTime = 500
    EndIf
    debugMsg(sProcName, "calling fadeOutOneAud(" + getAudLabel(pThisAudPtr) + ")")
    fadeOutOneAud(pThisAudPtr)
    ; End changed 14May2020 11.8.3rc4
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure assignCanvases(pSubPtr=-1, pAudPtr=-1, bTrace=#False)
  PROCNAMEC()
  Protected i, j, k, n
  Protected nFirstCuePtr, nLastCuePtr
  Protected bProcessThisSub
  Protected nVidPicTarget, nWindowIndex, sVidPicTarget.s
  Protected nVideoCanvasNo, nMonitorCanvasNo
  Protected nSourceWidth, nSourceHeight
  Protected nVideoWidth, nVideoHeight
  Protected nMonitorWidth, nMonitorHeight
  Protected nDPSDisplayLeft, nDPSDisplayTop, nDPSDisplayRight, nDPSDisplayBottom
  Protected nLeft, nTop, nWidth, nHeight
  Protected nVideoWindowNo, nMonitorWindowNo
  ; Protected bTrace = #True ; conditional tracing because this procedure may be called many times while moving X, Y and Size sliders in the editor
  
  debugMsgC(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr) + ", pAudPtr=" + getAudLabel(pAudPtr))
  
  If (pSubPtr = -1) And (pAudPtr = -1)
    For n = 0 To ArraySize(WMO())
      WMO(n)\nMaxMonitorIndex = 0
    Next n
  EndIf
  
  If pSubPtr >= 0
    nFirstCuePtr = aSub(pSubPtr)\nCueIndex
    nLastCuePtr = nFirstCuePtr
  Else
    nFirstCuePtr = 1
    nLastCuePtr = gnLastCue
  EndIf
  
  For i = nFirstCuePtr To nLastCuePtr
    If aCue(i)\bCueEnabled And aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If (pSubPtr >= 0) And (j <> pSubPtr)
          bProcessThisSub = #False
        Else
          bProcessThisSub = #True
        EndIf
        If aSub(j)\bSubEnabled = #False
          bProcessThisSub = #False
        EndIf
        If bProcessThisSub
          If aSub(j)\bSubTypeA
            For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To aSub(j)\nSubMaxOutputScreen
              If aSub(j)\bOutputScreenReqd(nVidPicTarget)
                sVidPicTarget = decodeVidPicTarget(nVidPicTarget)
                debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nOutputScreen=" + aSub(j)\nOutputScreen + ", nVidPicTarget=" + sVidPicTarget)
                nWindowIndex = nVidPicTarget - #SCS_VID_PIC_TARGET_F2
                With grVidPicTarget(nVidPicTarget)
                  debugMsgC(sProcName, "grVidPicTarget(" + sVidPicTarget + ")\nTargetWidth=" + \nTargetWidth + ", \nTargetHeight=" + \nTargetHeight)
                  nVideoWidth = \nTargetWidth
                  nVideoHeight = \nTargetHeight
                  nMonitorWidth = \nMonitorWidth
                  nMonitorHeight = \nMonitorHeight
                EndWith
                k = aSub(j)\nFirstAudIndex
                While k >= 0
                  With aAud(k)
                    If (pAudPtr = -1) Or (pAudPtr = k)
                      If (\nSourceWidth = 0) Or (\nSourceHeight = 0)
                        Select \nFileFormat
                          Case #SCS_FILEFORMAT_VIDEO
                            debugMsgC(sProcName, "calling getVideoInfoForAud(" + getAudLabel(k) + ")")
                            getVideoInfoForAud(k)
                          Case #SCS_FILEFORMAT_PICTURE
                            debugMsgC(sProcName, "calling getVideoInfoForAud(" + getAudLabel(k) + ")")
                            getVideoInfoForAud(k)
                          Case #SCS_FILEFORMAT_CAPTURE
                            debugMsgC(sProcName, "calling getVideoInfoForAud(" + getAudLabel(k) + ")")
                            getVideoInfoForAud(k)
                        EndSelect
                      EndIf
                      debugMsgC(sProcName, "aAud(" + getAudLabel(k) + ")\nFileFormat=" + decodeFileFormat(\nFileFormat) + ", \nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
                      If (\nSourceWidth > 0) And (\nSourceHeight > 0)
                        ; nb cannot assign video canvas yet if we haven't got the width and height - possibly because the video file doesn't exist
                        ; based on code from adjustVideoPosAndSize3()
                        nSourceWidth = \nSourceWidth
                        nSourceHeight = \nSourceHeight
                        ; debugMsgC(sProcName, "nSourceWidth=" + nSourceWidth + ", nSourceHeight=" + nSourceHeight + ", nVideoWidth=" + nVideoWidth + ", nVideoHeight=" + nVideoHeight)
                        debugMsgC(sProcName, "calling calcDisplayPosAndSize3(" + getAudLabel(k) + ", " + nSourceWidth + ", " + nSourceHeight + ", " + nVideoWidth + ", " + nVideoHeight + ", " + nMonitorWidth + ", " + nMonitorHeight + ")")
                        calcDisplayPosAndSize3(k, nSourceWidth, nSourceHeight, nVideoWidth, nVideoHeight, nMonitorWidth, nMonitorHeight)
                        nDPSDisplayLeft = grDPS\nDisplayLeft
                        nDPSDisplayTop = grDPS\nDisplayTop
                        nDPSDisplayRight = nDPSDisplayLeft + grDPS\nDisplayWidth
                        nDPSDisplayBottom = nDPSDisplayTop + grDPS\nDisplayHeight
                        nLeft = grDPS\nDisplayLeft
                        nTop = grDPS\nDisplayTop
                        nWidth = grDPS\nDisplayWidth
                        nHeight = grDPS\nDisplayHeight
                        nVideoWindowNo = #WV2 + nWindowIndex
                        If (\nAudGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr) Or (\nFileFormat <> #SCS_FILEFORMAT_VIDEO)
                          CheckSubInRange(nWindowIndex, ArraySize(WVN()), "WVN()")
                          nVideoCanvasNo = WVN(nWindowIndex)\aVideo(0)\cvsCanvas
                        Else
                          If k = aSub(j)\nFirstAudIndex
                            nVideoCanvasNo = getVideoCanvas(nVideoWindowNo, nLeft, nTop, nWidth, nHeight)
                          EndIf
                        EndIf
                        \nAudVideoCanvasNo(nVidPicTarget) = nVideoCanvasNo
                        \nDisplayLeft(nVidPicTarget) = nLeft
                        \nDisplayTop(nVidPicTarget) = nTop
                        \nDisplayWidth(nVidPicTarget) = nWidth
                        \nDisplayHeight(nVidPicTarget) = nHeight
                        debugMsgC(sProcName, "aAud(" + getAudLabel(k) + ")\nAudVideoCanvasNo(" + sVidPicTarget + ")=" + getGadgetName(\nAudVideoCanvasNo(nVidPicTarget)) +
                                             ", \nDisplayLeft(" + sVidPicTarget + ")=" + \nDisplayLeft(nVidPicTarget) + ", \nDisplayTop(" + sVidPicTarget + ")=" + \nDisplayTop(nVidPicTarget) +
                                             ", \nDisplayWidth(" + sVidPicTarget + ")=" + \nDisplayWidth(nVidPicTarget) + ", \nDisplayHeight(" + sVidPicTarget + ")=" + \nDisplayHeight(nVidPicTarget))
                        
                        If grVideoMonitors\bDisplayMonitorWindows = #False
                          \nAudMonitorCanvasNo = 0
                        Else
                          nLeft = nDPSDisplayLeft * nMonitorWidth / nVideoWidth
                          nTop = nDPSDisplayTop * nMonitorHeight / nVideoHeight
                          nWidth = (nDPSDisplayRight - nDPSDisplayLeft) * nMonitorWidth / nVideoWidth
                          nHeight = (nDPSDisplayBottom - nDPSDisplayTop) * nMonitorHeight / nVideoHeight
                          nMonitorWindowNo = #WM2 + nWindowIndex
                          debugMsgC(sProcName, "calling getMonitorCanvas(" + decodeWindow(nMonitorWindowNo) + ", " + nLeft + ", " + nTop + ", " + nWidth + ", " + nHeight + ")")
                          nMonitorCanvasNo = getMonitorCanvas(nMonitorWindowNo, nLeft, nTop, nWidth, nHeight)
                          \nAudMonitorCanvasNo = nMonitorCanvasNo
                          debugMsgC(sProcName, "aAud(" + getAudLabel(k) + ")\nAudMonitorCanvasNo=" + decodeWindow(nMonitorWindowNo,#True) + "\" + getGadgetName(\nAudMonitorCanvasNo))
                        EndIf
                        
                      EndIf ; EndIf (nSourceWidth > 0) And (nSourceHeight > 0)
                      
                    EndIf ; EndIf (pAudPtr = -1) Or (pAudPtr = k)
                    
                    k = \nNextAudIndex
                  EndWith
                Wend
              EndIf
            Next nVidPicTarget
          EndIf ; EndIf aSub(j)\bSubTypeA
        EndIf ; EndIf bProcessThisSub
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bCueEnabled And aCue(i)\bSubTypeA
  Next i
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure setNextCanvasesVisible(pFromCuePtr=-1)
  PROCNAMEC()
  Protected i, j, k
  Protected Dim aCanvasNo(#SCS_VID_PIC_TARGET_LAST)
  Protected nScreenNo
  
  If pFromCuePtr = -1
    i = gnCueToGo
  Else
    i = pFromCuePtr
  EndIf
  
  While i < gnLastCue
    i + 1
    If aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeA And aSub(j)\bSubEnabled
          nScreenNo = aSub(j)\nOutputScreen
          Select nScreenNo
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              If aCanvasNo(nScreenNo) = 0
                k = aSub(j)\nFirstPlayIndex
                If k >= 0
                  If IsGadget(aAud(k)\nAudVideoCanvasNo(nScreenNo))
                    aCanvasNo(nScreenNo) = aAud(k)\nAudVideoCanvasNo(nScreenNo)
                  EndIf
                EndIf
              EndIf
          EndSelect
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Wend
  
  For nScreenNo = #SCS_VID_PIC_TARGET_F2 To grLicInfo\nLastVidPicTarget
    If IsGadget(aCanvasNo(nScreenNo))
      If getVisible(aCanvasNo(nScreenNo)) = #False
        setVisible(aCanvasNo(nScreenNo), #True)
        debugMsgV(sProcName, "setVisible(" + getGadgetName(aCanvasNo(nScreenNo)) + ", #True)")
      EndIf
    EndIf
  Next nScreenNo
  
EndProcedure

Procedure checkVideoGaplessStreamPlaying()
  PROCNAMEC()
  Protected nPlayingAudPtr = -1
  Protected k
  
  For k = 1 To gnLastAud
    With aAud(k)
      If \bAudUseGaplessStream
        If \bAudTypeA
          If \bExists
            If (\nFileState = #SCS_FILESTATE_OPEN) And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)
              If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                debugMsg(sProcName, "playing gapless aud found: aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                nPlayingAudPtr = k
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next k
  ProcedureReturn nPlayingAudPtr
EndProcedure

Procedure unloadCurrVideoGaplessStreamIfNotPlaying()
  PROCNAMEC()
  Protected k
  Protected nSubPtr
  Protected nPlayingSubPtr = -1
  
  For k = 1 To gnLastAud
    With aAud(k)
      If \bAudUseGaplessStream
        If \bAudTypeA
          If \bExists
            If (\nFileState = #SCS_FILESTATE_OPEN) And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)
              nSubPtr = \nSubIndex
              If (aSub(nSubPtr)\nSubState >= #SCS_CUE_READY) And (aSub(nSubPtr)\nSubState < #SCS_CUE_FADING_IN)
                debugMsg(sProcName, "calling closeSub(" + getSubLabel(nSubPtr) + ", #True, #False)")
                closeSub(nSubPtr, #True, #False)
              Else
                nPlayingSubPtr = nSubPtr
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next k
  ProcedureReturn nPlayingSubPtr
EndProcedure

Procedure openVideoGaplessStreamForEditor(nPrimaryVidPicTarget)
  PROCNAMEC()
  Protected nPlayingAudPtr, nPlayingSubPtr
  Protected k
  
  debugMsg(sProcName, #SCS_START + ", nPrimaryVidPicTarget=" + decodeVidPicTarget(nPrimaryVidPicTarget) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr))
  
  If nEditSubPtr >= 0
    nPlayingAudPtr = checkVideoGaplessStreamPlaying()
    If nPlayingAudPtr >= 0
      scsMessageRequester(getSubLabel(nEditSubPtr), LangPars("MMedia", "StreamPlaying", getAudLabel(nPlayingAudPtr)))
      ProcedureReturn #False
    EndIf
    nPlayingSubPtr = unloadCurrVideoGaplessStreamIfNotPlaying()
    If nPlayingSubPtr >= 0
      scsMessageRequester(getSubLabel(nEditSubPtr), LangPars("MMedia", "StreamPlaying", getSubLabel(nPlayingSubPtr)))
      ProcedureReturn #False
    EndIf
    
    debugMsg(sProcName, "calling setSlideShowGaplessInfo(" + getSubLabel(nEditSubPtr) + ")")
    setSlideShowGaplessInfo(nEditSubPtr)
    
    k = aSub(nEditSubPtr)\nFirstAudIndex
    While k >= 0
      debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(k) + ", #False, " + decodeVidPicTarget(nPrimaryVidPicTarget) + ")")
      openMediaFile(k, #False, nPrimaryVidPicTarget)
      k = aAud(k)\nNextAudIndex
    Wend
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure getAudVideoChannelForTarget(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected nChannel
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          nChannel = \nMainVideoNo
        Case #SCS_VID_PIC_TARGET_P
          nChannel = \nPreviewVideoNo
      EndSelect
    EndWith
  EndIf
  ProcedureReturn nChannel
EndProcedure

Procedure openNextAudsForSubA(pSubPtr, pVidPicTarget)
  PROCNAMECS(pSubPtr)
  Protected nCurrPlayIndex, nNextPlayIndex
  Protected bStartedInEditor
  Protected nPass
  Protected k
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      debugMsg(sProcName, "\nFirstAudIndex=" + getAudLabel(\nFirstAudIndex) + ", \nFirstPlayIndex=" + getAudLabel(\nFirstPlayIndex) + ", \nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex))
      If (\nFirstPlayIndex = -1) And (\nFirstAudIndex >= 0)
        debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(pSubPtr) + ")")
        generatePlayOrder(pSubPtr)
        debugMsg(sProcName, "\nFirstAudIndex=" + getAudLabel(\nFirstAudIndex) + ", \nFirstPlayIndex=" + getAudLabel(\nFirstPlayIndex) + ", \nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex))
      EndIf
      bStartedInEditor = \bStartedInEditor
      nCurrPlayIndex = \nCurrPlayIndex
      If nCurrPlayIndex >= 0
        nNextPlayIndex = aAud(nCurrPlayIndex)\nNextPlayIndex
      Else
        nNextPlayIndex = -1
      EndIf
      debugMsg(sProcName, "bStartedInEditor=" + strB(bStartedInEditor) + ", nCurrPlayIndex=" + getAudLabel(nCurrPlayIndex) + ", nNextPlayIndex=" + getAudLabel(nNextPlayIndex))
      For nPass = 1 To 2
        If nPass = 1
          k = nCurrPlayIndex
        Else
          k = nNextPlayIndex
        EndIf
        If k >= 0
          debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(k) + ", #False, " + decodeVidPicTarget(pVidPicTarget) + ")")
          openMediaFile(k, #False, pVidPicTarget)
        EndIf
      Next nPass
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure doAudFade(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nReqdAlphaBlend
  Protected qTimeNow.q
  Protected bFading
  Protected nSubPtr
  Protected nMyFadeOutTime, nFadeOutPosition
  Protected bPrevInFadeImage
  
  bPrevInFadeImage = gbInFadeImage ; Added 10Aug2021 11.8.5rc2b
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
       ; Added 10Aug2021 11.8.5rc2b
      If \bAudTypeA And \nFileFormat = #SCS_FILEFORMAT_PICTURE
        gbInFadeImage = #True
      EndIf
      ; End added 10Aug2021 11.8.5rc2b
      nSubPtr = \nSubIndex
      ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState))
      qTimeNow = ElapsedMilliseconds()
      Select \nAudState
          
        Case #SCS_CUE_READY, #SCS_CUE_PL_READY
          bFading = #True ; keep blender thread active
          
        Case #SCS_CUE_FADING_IN, #SCS_CUE_TRANS_FADING_IN
          If \nCurrFadeInTime <= 0
            nReqdAlphaBlend = 255
          ElseIf ((\bTimeFadeInStartedSet) And (qTimeNow - \qTimeFadeInStarted) >= \nCurrFadeInTime) Or (\nAudState = #SCS_CUE_PLAYING)
            ; debugMsg(sProcName, "\nCuePos=" + Str(\nCuePos) + ", \nCurrFadeInTime=" + \nCurrFadeInTime + ", \nAudState=" + decodeCueState(\nAudState))
            nReqdAlphaBlend = 255
          Else
            If \bTimeFadeInStartedSet
              nReqdAlphaBlend = ((qTimeNow - \qTimeFadeInStarted) * 255) / \nCurrFadeInTime
            Else
              nReqdAlphaBlend = 0
            EndIf
          EndIf
          CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
            debugMsg(sProcName, "\bTimeFadeInStartedSet=" + strB(\bTimeFadeInStartedSet) +
                                ", qTimeNow=" + traceTime(qTimeNow) +
                                ", \qTimeFadeInStarted=" + traceTime(\qTimeFadeInStarted) + ", \nCurrFadeInTime=" + \nCurrFadeInTime +
                                ", \nAudState=" + decodeCueState(\nAudState) + ", nReqdAlphaBlend=" + nReqdAlphaBlend)
          CompilerEndIf
          setAlphaBlend(pAudPtr, nReqdAlphaBlend)
          If nReqdAlphaBlend >= 255
            If \bBlending
              \bBlending = #False
              debugMsg(sProcName, "nReqdAlphaBlend=" + nReqdAlphaBlend + ", \bBlending=" + strB(\bBlending))
              ; the following work-around added 4Sep2018 as a short fade-in time could result in the fade not taking effect (Dee Ireland)
              If \nCurrFadeInTime < 500
                Delay(100)
                setAlphaBlend(pAudPtr, nReqdAlphaBlend-1)
                debugMsg(sProcName, "setAlphaBlend(" + getAudLabel(pAudPtr) + ", " + Str(nReqdAlphaBlend-1) + ")")
                Delay(20)
                setAlphaBlend(pAudPtr, nReqdAlphaBlend)
                debugMsg(sProcName, "setAlphaBlend(" + getAudLabel(pAudPtr) + ", " + nReqdAlphaBlend + ")")
              EndIf
              ; end work-around added 4Sep2018
              ; Added 9Jan2025 11.10.6-b02 as part of the fix for logos not to be displayed using 2D Drawing if the sub's bUseNew2DDrawing=#False
              If \bLogo And aSub(\nSubIndex)\bUseNew2DDrawing = #False
                \nAudState = #SCS_CUE_COMPLETED
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", calling setCueState(" + getCueLabel(\nCueIndex) + ")")
                setCueState(\nCueIndex)
              EndIf
              ; End added 9Jan2025 11.10.6-b02
            EndIf
          Else
            bFading = #True
          EndIf
          
        Case #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_OUT
          If \bInForcedFadeOut
            nReqdAlphaBlend = 0
          Else
            If gbFadingEverything
              nMyFadeOutTime = gnFadeEverythingTime
            ElseIf (\bAudTypeAorP) And (\nAudState = #SCS_CUE_FADING_OUT) And (aSub(nSubPtr)\bPLTerminating)
              nMyFadeOutTime = aSub(nSubPtr)\nPLCurrFadeOutTime
            Else
              nMyFadeOutTime = \nCurrFadeOutTime
            EndIf
            ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", nMyFadeOutTime=" + nMyFadeOutTime + ", \nFinalFadeOutTime=" + \nFinalFadeOutTime)
            If nMyFadeOutTime < 0
              nMyFadeOutTime = 0
            EndIf
            If \bTimeFadeOutStartedSet
              nFadeOutPosition = (qTimeNow - \qTimeFadeOutStarted) - (\nTotalTimeOnPause - \nPreFadeOutTimeOnPause)
              ; debugMsg(sProcName, "nFadeOutPosition=" + nFadeOutPosition)
            Else
              ; shouldn't get here
              nFadeOutPosition = (0) - (\nTotalTimeOnPause - \nPreFadeOutTimeOnPause)
              ; debugMsg(sProcName, "nFadeOutPosition=" + nFadeOutPosition)
            EndIf
            If nMyFadeOutTime <= 0
              nReqdAlphaBlend = 255
            Else
              nReqdAlphaBlend = 255 - ((nFadeOutPosition * 255) / nMyFadeOutTime)
            EndIf
            CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
              debugMsg(sProcName, "\bTimeFadeOutStartedSet=" + strB(\bTimeFadeOutStartedSet) +
                                  ", qTimeNow=" + traceTime(qTimeNow) +
                                  ", \qTimeFadeOutStarted=" + traceTime(\qTimeFadeOutStarted) + ", \nCurrFadeOutTime=" + Str(\nCurrFadeOutTime) +
                                  ", \nAudState=" + decodeCueState(\nAudState) + ", nReqdAlphaBlend=" + Str(nReqdAlphaBlend))
            CompilerEndIf
          EndIf
          setAlphaBlend(pAudPtr, nReqdAlphaBlend)
          If nReqdAlphaBlend <= 0
            \bBlending = #False
            CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
              debugMsg(sProcName, "nReqdAlphaBlend=" + nReqdAlphaBlend + ", \bBlending=" + strB(\bBlending))
            CompilerEndIf
          Else
            bFading = #True
          EndIf

      EndSelect
    EndWith
  EndIf
  
  gbInFadeImage = bPrevInFadeImage
  
  CompilerIf #cTraceAlphaBlend
    debugMsg(sProcName, #SCS_END + ", aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState) + ", returning bFading=" + strB(bFading))
  CompilerEndIf
  ProcedureReturn bFading
  
EndProcedure

Procedure rewindAudsWithPlayFromPosSet()
  PROCNAMEC()
  Protected i, j, k
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeF
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            With aAud(k)
              If \nPlayFromPos > 0
                If k <> nEditAudPtr
                  If (\nAudState >= #SCS_CUE_READY) And (\nAudState < #SCS_CUE_COMPLETED)
                    \nPlayFromPos = grAudDef\nPlayFromPos
                    samAddRequest(#SCS_SAM_REWIND_AUD, k)
                  EndIf
                EndIf
              EndIf
            EndWith
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
EndProcedure

Procedure freeLogoImages()
  PROCNAMEC()
  Protected nVidPicTarget
  Protected bLogoFreed
  
  For nVidPicTarget = 0 To gnMaxVidPicTargetSetup
    With grVidPicTarget(nVidPicTarget)
      If IsImage(\nLogoImageNo)
        debugMsg(sProcName, "calling FreeImage(" + decodeHandle(\nLogoImageNo) + "), ImageID=" + Str(ImageID(\nLogoImageNo)))
        FreeImage(\nLogoImageNo)
        debugMsg3(sProcName, "FreeImage(" + decodeHandle(\nLogoImageNo) + ")")
        logFreeImage(90, \nLogoImageNo)
        \nLogoImageNo = 0
        \nLogoAudId = 0
        bLogoFreed = #True
      EndIf
    EndWith
  Next nVidPicTarget
  
  If bLogoFreed
    debugMsg(sProcName, "calling hideMonitorsNotInUse()")
    hideMonitorsNotInUse()
  EndIf
  
EndProcedure

Procedure freeLogoImagesIfRequired()
  PROCNAMEC()
  Protected nVidPicTarget
  Protected k, bFreeThis, bLogoFreed
  
  For nVidPicTarget = 0 To gnMaxVidPicTargetSetup
    With grVidPicTarget(nVidPicTarget)
      If (IsImage(\nLogoImageNo)) And (\nLogoAudId <> 0)
        bFreeThis = #True
        For k = 1 To gnLastAud
          If aAud(k)\nAudId = \nLogoAudId
            If aAud(k)\bExists
              bFreeThis = #False
            EndIf
            Break
          EndIf
        Next k
        If bFreeThis
          debugMsg(sProcName, "calling FreeImage(" + decodeHandle(\nLogoImageNo) + "), ImageID=" + Str(ImageID(\nLogoImageNo)))
          FreeImage(\nLogoImageNo)
          debugMsg3(sProcName, "FreeImage(" + decodeHandle(\nLogoImageNo) + ")")
          logFreeImage(91, \nLogoImageNo)
          \nLogoImageNo = 0
          \nLogoAudId = 0
          bLogoFreed = #True
        EndIf
      EndIf
    EndWith
  Next nVidPicTarget
  
  If bLogoFreed
    debugMsg(sProcName, "calling hideMonitorsNotInUse()")
    hideMonitorsNotInUse()
  EndIf
  
EndProcedure

Procedure buildAudDevMaskForCue(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  Protected nAudDevMask
  Protected j, k, d, d2
  Protected sLogicalDev.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pCuePtr >= 0
    If aCue(pCuePtr)\bSubTypeF
      j = aCue(pCuePtr)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            With aAud(k)
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                sLogicalDev = \sLogicalDev[d]
                If sLogicalDev
                  For d2 = 0 To grProd\nMaxAudioLogicalDev
                    If grProd\aAudioLogicalDevs(d2)\sLogicalDev = sLogicalDev
                      nAudDevMask | (1 << d2)
                      Break
                    EndIf
                  Next d2
                EndIf
              Next d
            EndWith
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nAudDevMask)
  ProcedureReturn nAudDevMask
EndProcedure

Procedure saveBlendedImage(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected bResult
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  With grVidPicTarget(pVidPicTarget)
    If IsImage(\nBlendedImageNo)
      If IsImage(\nSavedBlendedImageNo)
        FreeImage(\nSavedBlendedImageNo)
        freeHandle(\nSavedBlendedImageNo)
      EndIf
      gnNextImageNo + 1
      \nSavedBlendedImageNo = gnNextImageNo
      If CopyImage(\nBlendedImageNo, \nSavedBlendedImageNo)
        debugMsg(sProcName, "CopyImage(" + decodeHandle(\nBlendedImageNo) + ", " + decodeHandle(\nSavedBlendedImageNo) + ")")
        bResult = #True
        logCreateImage(1051, \nSavedBlendedImageNo, pAudPtr, pVidPicTarget, "\nSavedBlendedImageNo", decodeVidPicTarget(pVidPicTarget)+".SavedBlanded")
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure clearPtrsFromVidPicTargets()
  ; PROCNAMEC()
  Protected nVidPicTarget
  
  ; debugMsg(sProcName, #SCS_START)
  
  For nVidPicTarget = 0 To ArraySize(grVidPicTarget())
    With grVidPicTarget(nVidPicTarget)
      \nPlayingSubPtr = grVidPicTargetDef\nPlayingSubPtr
      \nPrevPlayingSubPtr = grVidPicTargetDef\nPrevPlayingSubPtr
      \nPrevPrimaryAudPtr = grVidPicTargetDef\nPrevPrimaryAudPtr
      \nPrimaryAudPtr = grVidPicTargetDef\nPrimaryAudPtr
      ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
    EndWith
  Next nVidPicTarget
  
EndProcedure

Procedure videoFileRequester(sRequesterTitle.s, bAllowMultiSelect=#False, nWindowNo=#WED)
  PROCNAMEC()
  Static lFilter
  Static strLastFile.s
  Static sInitDir.s
  Protected bShowPlaces
  Protected nFileCount
  Protected sFileName.s
  Protected nFlags
  
  debugMsg(sProcName, #SCS_START)
  
  bShowPlaces = #True
  If Len(Trim(strLastFile)) = 0
    If gsVideoFileDialogInitDir
      sInitDir = Trim(gsVideoFileDialogInitDir)
    EndIf
  EndIf
  
  If bAllowMultiSelect
    nFlags = #PB_Requester_MultiSelection
  EndIf
  debugMsg(sProcName, "gsVideoImageFilePattern=" + gsVideoImageFilePattern)
  sFileName = OpenFileRequester(sRequesterTitle, strLastFile, gsVideoImageFilePattern, gnVideoImageFilePatternPosition, nFlags)
  nFileCount = 0
  If sFileName
    gsSelectedDirectory = GetPathPart(sFileName)
    While sFileName
      If nFileCount > ArraySize(gsSelectedFile())
        doRedim(gsSelectedFile, (nFileCount+10), "gsSelectedFile()")
      EndIf
      gsSelectedFile(nFileCount) = GetFilePart(sFileName)
      nFileCount + 1
      sFileName = NextSelectedFileName()
    Wend
  EndIf
  gnSelectedFileCount = nFileCount
  
  If nFileCount = 0
    ; didn't select anything
    ProcedureReturn nFileCount
  EndIf
  
  gsVideoFileDialogInitDir = ""
  debugMsg(sProcName, "gsVideoFileDialogInitDir=" + gsVideoFileDialogInitDir)
  
  strLastFile = gsSelectedDirectory + gsSelectedFile(nFileCount-1)
  sInitDir = gsSelectedDirectory
  
  debugMsg(sProcName, #SCS_END + ", nFileCount=" + nFileCount)
  ProcedureReturn nFileCount
  
EndProcedure

Procedure startAnimatedImageTimer(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nLoadImageNo, nWindowTimer
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    nLoadImageNo = \nLoadImageNo
    nWindowTimer = \nAnimatedImageTimer
    RemoveWindowTimer(#WMN, nWindowTimer)
    \nSelectedFrameIndex = 0
    SetImageFrame(nLoadImageNo, 0)
    ; Each frame can have its own delay, so change the timer accordingly
    debugMsg(sProcName, "calling AddWindowTimer(" + decodeWindow(#WMN) + ", " + nWindowTimer + ", " + GetImageFrameDelay(nLoadImageNo) + ")")
    AddWindowTimer(#WMN, nWindowTimer, GetImageFrameDelay(nLoadImageNo))
  EndWith

EndProcedure

Procedure moveAudPictureToPrimary(pAudPtr, pPrimaryVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected bLockedMutex
  Protected nSubPtr, bSubStartedInEditor
  Protected nVidPicTarget, nMyPrimaryImageNo, nVideoCanvasNo, nMonitorCanvasNo
  Protected bDisplayMonitor
  Protected Dim bOutputScreenReqd(#SCS_VID_PIC_TARGET_LAST)
  Protected nTmpImage
  
  debugMsg(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pPrimaryVidPicTarget))
  
  nMyPrimaryImageNo = aAud(pAudPtr)\nVidPicTargetImageNo(pPrimaryVidPicTarget)
  If IsImage(nMyPrimaryImageNo) = #False
    loadAndFitAPicture(pAudPtr, pPrimaryVidPicTarget)
    nMyPrimaryImageNo = aAud(pAudPtr)\nVidPicTargetImageNo(pPrimaryVidPicTarget)
  EndIf
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  bSubStartedInEditor = aSub(nSubPtr)\bStartedInEditor
  Select pPrimaryVidPicTarget
    Case #SCS_VID_PIC_TARGET_P
      bOutputScreenReqd(#SCS_VID_PIC_TARGET_P) = #True
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        bOutputScreenReqd(nVidPicTarget) = aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
      Next nVidPicTarget
  EndSelect
  
  For nVidPicTarget = #SCS_VID_PIC_TARGET_P To #SCS_VID_PIC_TARGET_LAST
    If bOutputScreenReqd(nVidPicTarget)
      With grVidPicTarget(nVidPicTarget)
        
        If gbVideosOnMainWindow = #False
          If IsWindow(\nMainWindowNo)
            If getWindowVisible(\nMainWindowNo) = #False
              setWindowVisible(\nMainWindowNo, #True)
            EndIf
          EndIf
        EndIf
        
        LockImageMutex(277)
        
        If nVidPicTarget = pPrimaryVidPicTarget
          If IsImage(nMyPrimaryImageNo) = #False
            debugMsg(sProcName, "calling loadAndFitAPicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ")")
            If loadAndFitAPicture(pAudPtr, nVidPicTarget) = #False
              debugMsg(sProcName, "loadAndFitAPicture(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ") returned #False")
              UnlockImageMutex()
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        
        If \nPrevPrimaryAudPtr <> \nPrimaryAudPtr
          \nPrevPrimaryAudPtr = \nPrimaryAudPtr
        EndIf
        If \nPrevPlayingSubPtr <> \nPlayingSubPtr
          \nPrevPlayingSubPtr = \nPlayingSubPtr
        EndIf
        \nPrimaryAudPtr = pAudPtr
        \nPlayingSubPtr = -1
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) + ", \nPrevPlayingSubPtr=" + getSubLabel(\nPrevPlayingSubPtr) +
                            ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
        \nPrimaryFileFormat = aAud(pAudPtr)\nFileFormat
        \sPrimaryFileName = aAud(pAudPtr)\sFileName
        \nPrimaryImageNo = nMyPrimaryImageNo
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\sPrimaryFileName=" + GetFilePart(\sPrimaryFileName) + ", \nPrimaryImageNo=" + decodeHandle(\nPrimaryImageNo) +
                            ", ImageWidth()=" + ImageWidth(\nPrimaryImageNo) + ", ImageHeight()=" + ImageHeight(\nPrimaryImageNo))
        If \bLogoCurrentlyDisplayed And \nPrimaryImageNo <> \nLogoImageNo 
          \bLogoCurrentlyDisplayed = #False
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
        EndIf
        
        \nAudPtr2 = -1 ; indicates no cross-fade
        \nImage2 = 0
        \nAudPtr1 = pAudPtr
        \nImage1 = aAud(pAudPtr)\nVidPicTargetImageNo(nVidPicTarget)
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nAudPtr1=" + getAudLabel(\nAudPtr1) + ", \nImage1=" + decodeHandle(\nImage1) + ", \nAudPtr2=" + getAudLabel(\nAudPtr2) + ", \nImage2=" + decodeHandle(\nImage2))
        If nVidPicTarget = pPrimaryVidPicTarget
          If aAud(pAudPtr)\nImageFrameCount > 1
            startAnimatedImageTimer(pAudPtr)
          EndIf
        EndIf
        
        Select aAud(pAudPtr)\nFileFormat
          Case #SCS_FILEFORMAT_PICTURE
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nTargetCanvasNo=" + getGadgetName(\nTargetCanvasNo) + ", \nPrimaryImageNo=" + decodeHandle(\nPrimaryImageNo))
            debugMsg(sProcName, "IsImage(" + decodeHandle(\nPrimaryImageNo) + ")=" + strB(IsImage(\nPrimaryImageNo)))
            ;TODO - Scrutinise this change as at times it crashes for the DrawImage because IsImage = 0
            If IsImage(\nPrimaryImageNo) <> 0
              nVideoCanvasNo = \nTargetCanvasNo
              If nVidPicTarget = pPrimaryVidPicTarget ; Test added 4Apr2022 11.9.1az
                debugMsgV(sProcName, "calling StartDrawing(CanvasOutput(" + getGadgetName(nVideoCanvasNo) + "))")
                If StartDrawing(CanvasOutput(nVideoCanvasNo))
                  debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nVideoCanvasNo) + "))")
                  DrawImage(ImageID(\nPrimaryImageNo), 0, 0)
                  debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(\nPrimaryImageNo) + "), 0, 0)")
                  StopDrawing()
                  debugMsgD(sProcName, "StopDrawing()")
                  ; Added 31May2021 11.8.5ad following emails from David Preece
                  If getVisible(nVideoCanvasNo) = #False
                    setVisible(nVideoCanvasNo, #True)
                  EndIf
                  ; End added 31May2021 11.8.5ad
                Else
                  debugMsg(sProcName, "StartDrawing(CanvasOutput(" + nVideoCanvasNo + ")) returned #False")
                EndIf
              Else
                paintPictureAtPosAndSize(pAudPtr, nVideoCanvasNo, aAud(pAudPtr)\nLoadImageNo) ; Added 4Apr2022 11.9.1az
              EndIf
              ; display monitor if required
              \nCurrMonitorCanvasNo = grVidPicTargetDef\nCurrMonitorCanvasNo
              If bSubStartedInEditor = #False
                Select grVideoDriver\nVideoPlaybackLibrary
                  Case #SCS_VPL_TVG
                    If checkUse2DDrawing(nSubPtr)
                      Select nVidPicTarget
                        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                          bDisplayMonitor = #True
                      EndSelect
                    EndIf
                EndSelect
                If bDisplayMonitor
                  nMonitorCanvasNo = \nMonitorCanvasNo
                  If IsGadget(nMonitorCanvasNo)
                    If StartDrawing(CanvasOutput(nMonitorCanvasNo))
                      debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nMonitorCanvasNo) + "))")
                      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)  ; clear monitor area
                      debugMsgD(sProcName, "Box(0, 0, " + OutputWidth() + ", " + OutputHeight() + ", #SCS_Black)")
                      DrawImage(ImageID(\nPrimaryImageNo), 0, 0, OutputWidth(), OutputHeight())
                      debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(\nPrimaryImageNo) + "), 0, 0, " + OutputWidth() + ", " + OutputHeight() + ")")
                      StopDrawing()
                      debugMsgD(sProcName, "StopDrawing()")
                    EndIf
                    debugMsg(sProcName, "calling setMonitorCanvasVisible(" + decodeVidPicTarget(nVidPicTarget) + ", " + getGadgetName(nMonitorCanvasNo) + ", #True)")
                    setMonitorCanvasVisible(nVidPicTarget, nMonitorCanvasNo, #True)
                    \nCurrMonitorCanvasNo = nMonitorCanvasNo
                    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nCurrMonitorCanvasNo=" + \nCurrMonitorCanvasNo + ", " + getGadgetName(\nCurrMonitorCanvasNo))
                    grVidPicTarget(nVidPicTarget)\bImageOnMonitor = #True
                  EndIf
                EndIf ; EndIf IsGadget(nMonitorCanvasNo)
              EndIf ; EndIf bSubStartedInEditor = #False
            EndIf ; Endif IsImage = 0
            
          Case #SCS_FILEFORMAT_VIDEO
            If nVidPicTarget = pPrimaryVidPicTarget
              showFrame(pAudPtr, nVidPicTarget)
            EndIf
            
          Case #SCS_FILEFORMAT_CAPTURE
            showFrame(pAudPtr, nVidPicTarget)
            
            
        EndSelect
        
        Select nVidPicTarget
          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            debugMsg(sProcName, "calling makeVidPicVisible(" + decodeVidPicTarget(nVidPicTarget) + ", #True, " + getAudLabel(pAudPtr) + ")")
            makeVidPicVisible(nVidPicTarget, #True, pAudPtr)
        EndSelect
        
      EndWith ; EndWith grVidPicTarget(nVidPicTarget)
      
    EndIf ; EndIf bOutputScreenReqd(nVidPicTarget)
  Next nVidPicTarget

  UnlockImageMutex()
  
  ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure hidePicture(pAudPtr, pPrimaryVidPicTarget, bIgnoreDelayHide=#False)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr, nVidPicTarget
  Protected Dim bOutputScreenReqd(#SCS_VID_PIC_TARGET_LAST)
  Protected bDelayHide
  Protected nDelayTime = 500
  Protected n
  Protected bHideThis, bBlackWindow
  Protected nFileFormatForHide
  Protected nGadgetNo
  Protected nHoldPrimaryAudPtr
  
  debugMsg(sProcName, #SCS_START + ", pPrimaryVidPicTarget=" + decodeVidPicTarget(pPrimaryVidPicTarget) + ", bIgnoreDelayHide=" + strB(bIgnoreDelayHide))
  
  If (bIgnoreDelayHide = #False) And (gbClosingDown = #False) And (gbClosingDevices = #False)
    bDelayHide = aAud(pAudPtr)\bDelayHide
    ; debugMsg(sProcName, "bDelayHide=" + strB(bDelayHide))
  EndIf
  
  nSubPtr = aAud(pAudPtr)\nSubIndex
  Select pPrimaryVidPicTarget
    Case #SCS_VID_PIC_TARGET_P
      bOutputScreenReqd(#SCS_VID_PIC_TARGET_P) = #True
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      For nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        bOutputScreenReqd(nVidPicTarget) = aSub(nSubPtr)\bOutputScreenReqd(nVidPicTarget)
      Next nVidPicTarget
  EndSelect
  
  For nVidPicTarget = #SCS_VID_PIC_TARGET_P To #SCS_VID_PIC_TARGET_LAST
    ; debugMsg(sProcName, "--- bOutputScreenReqd(" + decodeVidPicTarget(nVidPicTarget) + ")=" + strB(bOutputScreenReqd(nVidPicTarget)))
    If bOutputScreenReqd(nVidPicTarget)
      Select nVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          n = nVidPicTarget - #SCS_VID_PIC_TARGET_F2
          With grVidPicTarget(nVidPicTarget)
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
            nHoldPrimaryAudPtr = \nPrimaryAudPtr
            ; debugMsg(sProcName, "nHoldPrimaryAudPtr=" + getAudLabel(nHoldPrimaryAudPtr))
            If \nPrimaryAudPtr = pAudPtr
              bHideThis = #True
              If \nPrimaryAudPtr >= 0
                nFileFormatForHide = aAud(\nPrimaryAudPtr)\nFileFormat
              EndIf
              debugMsg(sProcName, "bHideThis=" + strB(bHideThis) + ", nFileFormatForHide=" + decodeFileFormat(nFileFormatForHide))
              \nPrimaryAudPtr = grVidPicTargetDef\nPrimaryAudPtr  ; added 31Mar2019 11.8.0.2cb following emailed bug report from Martin Stevens "Image fade-in problem 11.8.0.1"
            ElseIf \nPrevPrimaryAudPtr = pAudPtr
              bHideThis = #True
              If \nPrevPrimaryAudPtr >= 0
                nFileFormatForHide = aAud(\nPrevPrimaryAudPtr)\nFileFormat
              EndIf
              debugMsg(sProcName, "bHideThis=" + strB(bHideThis) + ", grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) +
                                  ", nFileFormatForHide=" + decodeFileFormat(nFileFormatForHide))
              If (\nPrimaryAudPtr >= 0) And (\nPrevPrimaryAudPtr >= 0)
                debugMsg(sProcName, "aAud(\" + getAudLabel(\nPrimaryAudPtr) + ")\nFileFormat=" + decodeFileFormat(aAud(\nPrimaryAudPtr)\nFileFormat) + ", aAud(" + getAudLabel(\nPrevPrimaryAudPtr) +
                                    ")\nFileFormat=" + decodeFileFormat(aAud(\nPrevPrimaryAudPtr)\nFileFormat))
                If aAud(\nPrimaryAudPtr)\nFileFormat = aAud(\nPrevPrimaryAudPtr)\nFileFormat
                  bHideThis = #False
                Else
                  nDelayTime = 50
                  bBlackWindow = #True
                EndIf
              EndIf
            ElseIf \nPrimaryAudPtr < 0
              ; added 14Nov2019 11.8.2rc4 following bug report from Dan Virtue about SFR cue leaving an image on the main screen -
              ; bug caused by the change "added 31Mar2019 11.8.0.2cb" mentioned earlier in this Procedure!
              bHideThis = #True
              If pAudPtr >= 0
                nFileFormatForHide = aAud(pAudPtr)\nFileFormat
              EndIf
              ; debugMsg(sProcName, "bHideThis=" + strB(bHideThis) + ", nFileFormatForHide=" + decodeFileFormat(nFileFormatForHide))
              ; end added 14Nov2019 11.8.2rc4
            EndIf
            ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) + ", bHideThis=" + strB(bHideThis) + ", bDelayHide=" + strB(bDelayHide))
            If bHideThis
              If bDelayHide
                samAddRequest(#SCS_SAM_HIDE_PICTURE, pAudPtr, 0, nVidPicTarget, "", ElapsedMilliseconds() + nDelayTime)
                ; nb this will only occur once in this nVidPicTarget 'loop' due to the following ProcedureReturn
                ProcedureReturn
              EndIf
              Select nFileFormatForHide
                Case #SCS_FILEFORMAT_PICTURE
                  If bBlackWindow
                    displayBlack(nVidPicTarget)
                  Else
                    debugMsg(sProcName, "calling clearPicture(" + decodeVidPicTarget(nVidPicTarget) + ")")
                    clearPicture(nVidPicTarget)
                  EndIf
                  
                  Select grVideoDriver\nVideoPlaybackLibrary
                    Case #SCS_VPL_TVG
                      If grVideoMonitors\bDisplayMonitorWindows
                        If nVidPicTarget = pPrimaryVidPicTarget
                          debugMsg(sProcName, "calling clearMonitor(" + decodeVidPicTarget(nVidPicTarget) + ")")
                          clearMonitor(nVidPicTarget)
                        EndIf
                      EndIf
                      \bImageOnMonitor = #False
                  EndSelect
                  ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bImageOnMonitor=" + strB(\bImageOnMonitor))
                  
                Case #SCS_FILEFORMAT_VIDEO
                  ; no action
                  
              EndSelect
              If nHoldPrimaryAudPtr = pAudPtr
                \nPrevPrimaryAudPtr = grVidPicTargetDef\nPrevPrimaryAudPtr
              Else
                \nPrevPrimaryAudPtr = nHoldPrimaryAudPtr
              EndIf
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
            EndIf
            If grVideoMonitors\bDisplayMonitorWindows
              hideMonitorsNotInUse()
            EndIf
          EndWith
          
        Case #SCS_VID_PIC_TARGET_P
          ; no need to 'hide' preview image
          With grVidPicTarget(#SCS_VID_PIC_TARGET_P)
            CompilerIf 1=99 ; blocked out 27May2019 11.8.1 because this was causing cross-fades in images in the preview panel to flip back to the original image
                            ; this was due to the cross-fading occurring in \cvsVideo whereas the original image was in \cvsPreview
              If getVisible(WQA\cvsPreview) = #False
                setVisible(WQA\cvsPreview, #True)
              EndIf
              If getVisible(WQA\cvsVideo)
                setVisible(WQA\cvsVideo, #False)
              EndIf
            CompilerEndIf
            If \nPrimaryAudPtr = pAudPtr
              \nPrevPrimaryAudPtr = \nPrimaryAudPtr
              \nPrimaryAudPtr = -1
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(#SCS_VID_PIC_TARGET_P) + ")\nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr))
              \nPrimaryImageNo = 0
              debugMsg(sProcName, "grVidPicTargetP\nPrimaryImageNo=" + Str(\nPrimaryImageNo))
            EndIf
          EndWith
          
      EndSelect ; EndSelect nVidPicTarget
      
    EndIf ; EndIf bOutputScreenReqd(nVidPicTarget)
    
  Next nVidPicTarget
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure countReadyVideos(bExcludeHotkeysEtc=#True)
  PROCNAMEC()
  Protected i, j, bCheckThisCue, nCount
  Protected sCueList.s
  
  For i = 1 To gnLastCue
    With aCue(i)
      If (\bSubTypeA) And (\bCueEnabled)
        bCheckThisCue = #True
        If bExcludeHotkeysEtc
          If \bHotkey Or \bExtAct Or \nActivationMethod = #SCS_ACMETH_CALL_CUE
            bCheckThisCue = #False
          EndIf
        EndIf
        If bCheckThisCue
          j = \nFirstSubIndex
          While j >= 0
            If (aSub(j)\bSubTypeA) And (aSub(j)\bSubEnabled)
              If aSub(j)\nSubState = #SCS_CUE_READY
                If sCueList
                  sCueList + ", "
                EndIf
                sCueList + getSubLabel(j)
                nCount + 1
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      EndIf
    EndWith
  Next i
  debugMsg(sProcName, #SCS_END + ", returning nCount=" + nCount + ", sCueList=" + sCueList)
  ProcedureReturn nCount
EndProcedure

Procedure createVideoWindows()
  PROCNAMEC()
  Protected nVidPicTarget, n2, n3, nScreenNo
  Protected nOutputsOnFinalMonitor, nVideoWindowNo, bSetWindowPositions
  Protected sMsg.s, sLabel.s
  Protected nWinMidPointX, nWinMidPointY, nOtherWindow, bOverlaps
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grVideoMonitors\nMaxOutputScreen=" + grVideoMonitors\nMaxOutputScreen + ", grProd\nDefOutputScreen=" + grProd\nDefOutputScreen +
                      ", grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen=" + grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen + ", gnScreens=" + gnScreens)
  
  ; determine the positioning of the target windows
  If grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen <= gnScreens Or grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX ; nb vMix screens are quite independant of SCS screens, eg they could be NDI external outputs
    ; sufficient screens available
    For nVidPicTarget = 2 To grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen
      With grVidPicTarget(nVidPicTarget)
        \bShareScreen = #False
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bShareScreen=" + strB(\bShareScreen))
        If (gbSwapMonitors1and2) And (nVidPicTarget = gnSwapMonitor)
          nScreenNo = 1
        Else
          nScreenNo = nVidPicTarget
        EndIf
        debugMsg(sProcName, "gaScreen(" + nScreenNo + ")\nScreenLeft=" + gaScreen(nScreenNo)\nScreenLeft + ", \nScreenTop=" + gaScreen(nScreenNo)\nScreenTop + ", \nScreenWidth=" + gaScreen(nScreenNo)\nScreenWidth + ", \nScreenHeight=" + gaScreen(nScreenNo)\nScreenHeight)
        \nFullWindowX = gaScreen(nScreenNo)\nScreenLeft
        \nFullWindowY = gaScreen(nScreenNo)\nScreenTop
        \nFullWindowWidth = gaScreen(nScreenNo)\nScreenWidth
        \nFullWindowHeight = gaScreen(nScreenNo)\nScreenHeight
        \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft
        \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
        \nMainWindowWidth = gaScreen(nScreenNo)\nScreenWidth
        \nMainWindowHeight = gaScreen(nScreenNo)\nScreenHeight
        \nTVGDisplayMonitor = gaMonitors(nScreenNo)\nTVGDisplayMonitor
        \nMainWindowXWithinDisplayMonitor = 0
        \nMainWindowYWithinDisplayMonitor = 0
        \nDesktopWidth = gaMonitors(nScreenNo)\nDesktopWidth
        \nDesktopHeight = gaMonitors(nScreenNo)\nDesktopHeight
        \nDisplayScalingPercentage = gaMonitors(nScreenNo)\nDisplayScalingPercentage
        \sVideoDevice = Str(nVidPicTarget)
        \nMonitorArrayIndex = nScreenNo ; Added 25Oct2022 11.9.6
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nFullWindowX=" + \nFullWindowX + ", \nFullWindowY=" + \nFullWindowY + ", \nFullWindowWidth=" + \nFullWindowWidth + ", \nFullWindowHeight=" + \nFullWindowHeight +
                            ", \nMainWindowX=" + \nMainWindowX + ", \nMainWindowY=" + \nMainWindowY + ", \nMainWindowWidth=" + \nMainWindowWidth + ", \nMainWindowHeight=" + \nMainWindowHeight +
                            ", \nTVGDisplayMonitor=" + \nTVGDisplayMonitor + ", \nDesktopWidth=" + \nDesktopWidth + ", \nDesktopHeight=" + \nDesktopHeight + ", \nDisplayScalingPercentage=" + \nDisplayScalingPercentage +
                            ", \nMonitorArrayIndex=" + \nMonitorArrayIndex)
      EndWith
    Next nVidPicTarget
    
  Else
    ; not enough screens available so need to multi-fit windows on last available screen
    If gnScreens = 1 ; only 1 screen available so video/image outputs have to share the screen with the main SCS window (#WMN)
      For nVidPicTarget = 2 To grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen
        With grVidPicTarget(nVidPicTarget)
          \bShareScreen = #True
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bShareScreen=" + strB(\bShareScreen))
          nVideoWindowNo = #WV2 + (nVidPicTarget - 2)
          \nFullWindowX = gaScreen(1)\nScreenLeft
          \nFullWindowY = gaScreen(1)\nScreenTop
          \nFullWindowWidth = gaScreen(1)\nScreenWidth
          \nFullWindowHeight = gaScreen(1)\nScreenHeight
          \nMainWindowX = 0
          \nMainWindowY = 0
          If \nMainWindowWidth = grVidPicTargetDef\nMainWindowWidth ; Test added 29Jun2022 11.9.3ag
            \nMainWindowWidth = 320   ; may be changed in positionVideoMonitorsOrWindows()
            \nMainWindowHeight = 240  ; ditto
          EndIf
          \sVideoDevice = "1"
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nMainWindowX=" + \nMainWindowX + ", \nMainWindowY=" + \nMainWindowY + ", \nMainWindowWidth=" + \nMainWindowWidth + ", \nMainWindowHeight=" + \nMainWindowHeight)
        EndWith
      Next nVidPicTarget
      
    Else ; at least 2 screens available
      gbVideosOnMainWindow = #False
      If gbScreenNotPresentWarningDisplayed = #False
        With grVideoMonitors
          If grProd\nDefOutputScreen > grVideoMonitors\nMaxOutputScreen
            sLabel = Lang("WEP" ,"lblDefOutputScreen")
            sMsg = LangPars("Requesters", "ScreenNotPresent2", sLabel , Str(grProd\nDefOutputScreen), Str(gnScreens))
          Else
            sMsg = LangPars("Requesters", "ScreenNotPresent", getSubLabel(\nMaxOutputSubCuePtr), Str(\nMaxOutputScreen), Str(gnScreens))
          EndIf
        EndWith
        scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONWARNING)
        gbScreenNotPresentWarningDisplayed = #True
      EndIf
      For nVidPicTarget = 2 To grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen
        If nVidPicTarget < gnScreens
          ; screens before the final screen available for full screen displays
          With grVidPicTarget(nVidPicTarget)
            \bShareScreen = #False
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bShareScreen=" + strB(\bShareScreen))
            If (gbSwapMonitors1and2) And (nVidPicTarget = gnSwapMonitor)
              nScreenNo = 1
            Else
              nScreenNo = nVidPicTarget
            EndIf
            \nFullWindowX = gaScreen(nScreenNo)\nScreenLeft
            \nFullWindowY = gaScreen(nScreenNo)\nScreenTop
            \nFullWindowWidth = gaScreen(nScreenNo)\nScreenWidth
            \nFullWindowHeight = gaScreen(nScreenNo)\nScreenHeight
            If gbApplyDisplayScaling
              \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft
              \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
              \nMainWindowWidth = gaScreen(nScreenNo)\nScreenWidth
              \nMainWindowHeight = gaScreen(nScreenNo)\nScreenHeight
            Else
              \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft
              \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
              \nMainWindowWidth = gaScreen(nScreenNo)\nDesktopWidth
              \nMainWindowHeight = gaScreen(nScreenNo)\nDesktopHeight
            EndIf
            \sVideoDevice = Str(nVidPicTarget)
            \nTVGDisplayMonitor = gaMonitors(nScreenNo)\nTVGDisplayMonitor
            \nMainWindowXWithinDisplayMonitor = 0
            \nMainWindowYWithinDisplayMonitor = 0
            \nDesktopWidth = gaMonitors(nScreenNo)\nDesktopWidth
            \nDesktopHeight = gaMonitors(nScreenNo)\nDesktopHeight
            debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nMainWindowX=" + \nMainWindowX + ", \nMainWindowY=" + \nMainWindowY +
                                ", \nMainWindowWidth=" + \nMainWindowWidth + ", \nMainWindowHeight=" + \nMainWindowHeight +
                                ", \nTVGDisplayMonitor=" + \nTVGDisplayMonitor)
          EndWith
          
        ElseIf nVidPicTarget = gnScreens
          ; the final screen must be used for all remaining video/image outputs
          nOutputsOnFinalMonitor = grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen - gnScreens + 1
          debugMsg(sProcName, "grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen=" + grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen + ", gnScreens=" + gnScreens + ", nOutputsOnFinalMonitor=" + nOutputsOnFinalMonitor)
          n3 = 1
          For n2 = nVidPicTarget To grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen
            n3 + 1
            With grVidPicTarget(n2)
              \bShareScreen = #True
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n2) + ")\bShareScreen=" + strB(\bShareScreen))
              ; nb 'nVidPicTarget' points to the final available screen
              If (gbSwapMonitors1and2) And (nVidPicTarget = gnSwapMonitor)
                nScreenNo = 1
              Else
                nScreenNo = nVidPicTarget
              EndIf
              \nFullWindowX = gaScreen(nScreenNo)\nScreenLeft
              \nFullWindowY = gaScreen(nScreenNo)\nScreenTop
              \nFullWindowWidth = gaScreen(nScreenNo)\nScreenWidth
              \nFullWindowHeight = gaScreen(nScreenNo)\nScreenHeight
              \nTVGDisplayMonitor = gaMonitors(nScreenNo)\nTVGDisplayMonitor
              If gbApplyDisplayScaling
                If nOutputsOnFinalMonitor < 5
                  \nMainWindowWidth = (gaScreen(nScreenNo)\nScreenWidth >> 1)
                  \nMainWindowHeight = (gaScreen(nScreenNo)\nScreenHeight >> 1)
                Else
                  \nMainWindowWidth = (gaScreen(nScreenNo)\nScreenWidth >> 2)
                  \nMainWindowHeight = (gaScreen(nScreenNo)\nScreenHeight >> 2)
                EndIf
                Select n3
                  Case 2
                    \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft
                    If nOutputsOnFinalMonitor > 2
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
                    ElseIf nOutputsOnFinalMonitor < 5
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + (\nMainWindowHeight >> 1)
                    Else
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
                    EndIf
                    
                  Case 3
                    \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + \nMainWindowWidth
                    If nOutputsOnFinalMonitor > 2
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
                    ElseIf nOutputsOnFinalMonitor < 5
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + (\nMainWindowHeight >> 1)
                    Else
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
                    EndIf
                    
                  Case 4
                    If nOutputsOnFinalMonitor < 5
                      \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + \nMainWindowHeight
                    Else
                      \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + (\nMainWindowWidth * 2)
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
                    EndIf
                    
                  Case 5
                    If nOutputsOnFinalMonitor < 5
                      \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + \nMainWindowWidth
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + \nMainWindowHeight
                    Else
                      \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + (\nMainWindowWidth * 3)
                      \nMainWindowY = gaScreen(nScreenNo)\nScreenTop
                    EndIf
                    
                  Case 6
                    \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft
                    \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + \nMainWindowHeight
                    
                  Case 7
                    \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + \nMainWindowWidth
                    \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + \nMainWindowHeight
                    
                  Case 8
                    \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + (\nMainWindowWidth * 2)
                    \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + \nMainWindowHeight
                    
                  Case 9
                    \nMainWindowX = gaScreen(nScreenNo)\nScreenLeft + (\nMainWindowWidth * 3)
                    \nMainWindowY = gaScreen(nScreenNo)\nScreenTop + \nMainWindowHeight
                    
                EndSelect
              Else
                If nOutputsOnFinalMonitor < 5
                  \nMainWindowWidth = (gaScreen(nScreenNo)\nDesktopWidth >> 1)
                  \nMainWindowHeight = (gaScreen(nScreenNo)\nDesktopHeight >> 1)
                Else
                  \nMainWindowWidth = (gaScreen(nScreenNo)\nDesktopWidth >> 2)
                  \nMainWindowHeight = (gaScreen(nScreenNo)\nDesktopHeight >> 2)
                EndIf
                Select n3
                  Case 2
                    \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft
                    If nOutputsOnFinalMonitor > 2
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
                    ElseIf nOutputsOnFinalMonitor < 5
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + (\nMainWindowHeight >> 1)
                    Else
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
                    EndIf
                    
                  Case 3
                    \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + \nMainWindowWidth
                    If nOutputsOnFinalMonitor > 2
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
                    ElseIf nOutputsOnFinalMonitor < 5
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + (\nMainWindowHeight >> 1)
                    Else
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
                    EndIf
                    debugMsg(sProcName, "grVidPicTarget(" + n2 + ")\nMainWindowY=" + \nMainWindowY)
                    
                  Case 4
                    If nOutputsOnFinalMonitor < 5
                      \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + \nMainWindowHeight
                    Else
                      \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + (\nMainWindowWidth * 2)
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
                    EndIf
                    
                  Case 5
                    If nOutputsOnFinalMonitor < 5
                      \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + \nMainWindowWidth
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + \nMainWindowHeight
                    Else
                      \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + (\nMainWindowWidth * 3)
                      \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop
                    EndIf
                    
                  Case 6
                    \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft
                    \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + \nMainWindowHeight
                    
                  Case 7
                    \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + \nMainWindowWidth
                    \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + \nMainWindowHeight
                    
                  Case 8
                    \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + (\nMainWindowWidth * 2)
                    \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + \nMainWindowHeight
                    
                  Case 9
                    \nMainWindowX = gaScreen(nScreenNo)\nDesktopLeft + (\nMainWindowWidth * 3)
                    \nMainWindowY = gaScreen(nScreenNo)\nDesktopTop + \nMainWindowHeight
                    
                EndSelect
              EndIf
              \nMainWindowXWithinDisplayMonitor = \nMainWindowX - gaScreen(nScreenNo)\nDesktopLeft
              \nMainWindowYWithinDisplayMonitor = \nMainWindowY - gaScreen(nScreenNo)\nDesktopTop
              \sVideoDevice = Str(n2)
              debugMsg(sProcName, "gaScreen(" + nScreenNo + ")\nWidth=" + gaScreen(nScreenNo)\nDesktopWidth + ", gaScreen(" + nScreenNo + ")\nHeight=" + gaScreen(nScreenNo)\nDesktopHeight +
                                  ", grVidPicTarget(" + decodeVidPicTarget(n2) + ")\nMainWindowX=" + \nMainWindowX + ", \nMainWindowY=" + \nMainWindowY +
                                  ", \nMainWindowWidth=" + \nMainWindowWidth + ", \nMainWindowHeight=" + \nMainWindowHeight)
              debugMsg(sProcName, "gaScreen(" + nScreenNo + ")\nTVGDisplayMonitor=" + \nTVGDisplayMonitor +
                                  ", \nMainWindowXWithinDisplayMonitor=" + \nMainWindowYWithinDisplayMonitor + ", \nMainWindowXWithinDisplayMonitor=" + \nMainWindowYWithinDisplayMonitor)
            EndWith
          Next n2
          Break   ; remaining required screens set up on final available screen, so now break out of the grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen loop
        EndIf
      Next nVidPicTarget
    EndIf
    
  EndIf
  
  For nVidPicTarget = 2 To grVideoMonitors\nMaxOutputScreenIncludingDefaultScreen
    With grVidPicTarget(nVidPicTarget)
      n2 = nVidPicTarget - 2
      nVideoWindowNo = #WV2 + n2
      If IsWindow(nVideoWindowNo) = #False
        debugMsg(sProcName, "calling WVN_Form_Load(" + decodeWindow(nVideoWindowNo) + ", " + \nMainWindowX + ", " + \nMainWindowY + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight +
                            ", " + \nFullWindowX + ", " + \nFullWindowY + ", " + \nFullWindowWidth + ", " + \nFullWindowHeight + ")")
        WVN_Form_Load(nVideoWindowNo, \nMainWindowX, \nMainWindowY, \nMainWindowWidth, \nMainWindowHeight, \nFullWindowX, \nFullWindowY, \nFullWindowWidth, \nFullWindowHeight)
        bSetWindowPositions = #True
      Else
        ; see also WVN_Form_Load() regarding the following
        bOverlaps = #False
        If nVideoWindowNo > #WV2
          nWinMidPointX = WindowX(nVideoWindowNo) + (WindowWidth(nVideoWindowNo) >> 1)
          nWinMidPointY = WindowY(nVideoWindowNo) + (WindowHeight(nVideoWindowNo) >> 1)
          For nOtherWindow = #WV2 To (nVideoWindowNo - 1)
            If nWinMidPointX > WindowX(nOtherWindow) And nWinMidPointX < (WindowX(nOtherWindow) + WindowWidth(nOtherWindow))
              If nWinMidPointY > WindowY(nOtherWindow) And nWinMidPointY < (WindowY(nOtherWindow) + WindowHeight(nOtherWindow))
                bOverlaps = #True
                Break
              EndIf
            EndIf
          Next nOtherWindow
          If bOverlaps
            \nFullWindowX = \nMainWindowX
            \nFullWindowY = \nMainWindowY
            \nFullWindowWidth = \nMainWindowWidth
            \nFullWindowHeight = \nMainWindowHeight
          EndIf
        EndIf
        ; end of 'see also WVN_Form_Load()...'
        debugMsg(sProcName, "calling WVN_Form_Resize(" + decodeWindow(nVideoWindowNo) +
                            ", main: " + \nMainWindowX + ", " + \nMainWindowY + ", " + \nMainWindowWidth + ", " + \nMainWindowHeight +
                            ", full: " + \nFullWindowX + ", " + \nFullWindowY + ", " + \nFullWindowWidth + ", " + \nFullWindowHeight + ")")
        If WVN_Form_Resize(nVideoWindowNo, \nMainWindowX, \nMainWindowY, \nMainWindowWidth, \nMainWindowHeight, \nFullWindowX, \nFullWindowY, \nFullWindowWidth, \nFullWindowHeight)
          bSetWindowPositions = #True
        EndIf
      EndIf
      \bTargetExists = #True
    EndWith
  Next nVidPicTarget
  
  If gbVideosOnMainWindow = #False ; Test added 15Sep2020 11.8.3.2ay
    debugMsg(sProcName, "calling displayOrHideVideoWindows()")
    displayOrHideVideoWindows()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning bSetWindowPositions=" + strB(bSetWindowPositions))
  ProcedureReturn bSetWindowPositions
  
EndProcedure

Procedure displayOrHideVideoWindows()
  PROCNAMEC()
  Protected i, j, n, nWindowNo
  Protected bCurrVisible, bReqdVisible
  Protected Dim bOutputScreenReqd(#SCS_VID_PIC_TARGET_LAST)
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueEnabled
      If aCue(i)\bSubTypeA Or aCue(i)\bSubTypeE
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            If aSub(j)\bSubTypeA
              For n = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                If aSub(j)\bOutputScreenReqd(n)
                  bOutputScreenReqd(n) = #True
                EndIf
              Next n
            ElseIf aSub(j)\bSubTypeE
              n = aSub(j)\nMemoScreen
              If n >= 2
                bOutputScreenReqd(n) = #True
              EndIf
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    EndIf
  Next i
  For n = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
    If bOutputScreenReqd(n)
      debugMsg(sProcName, "bOutputScreenReqd(" + n + ")=" + strB(bOutputScreenReqd(n)))
    EndIf
    nWindowNo = #WV2 + n - 2
    If IsWindow(nWindowNo)
      bReqdVisible = bOutputScreenReqd(n)
      bCurrVisible = getWindowVisible(nWindowNo)
      If bReqdVisible <> bCurrVisible
        setWindowVisible(nWindowNo, bReqdVisible)
      EndIf
    EndIf
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure isVideoDisplayDefault(pAudPtr)
  Protected bIsDefault
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If (\nXPos = grAudDef\nXPos) And
         (\nYPos = grAudDef\nYPos) And
         (\nSize = grAudDef\nSize) And
         (\nAspect = grAudDef\nAspect) And
         (\nAspectRatioType = grAudDef\nAspectRatioType) And
         (\nAspectRatioHVal = grAudDef\nAspectRatioHVal)
        bIsDefault = #True
      EndIf
    EndWith
  EndIf
  ProcedureReturn bIsDefault

EndProcedure

Procedure isVideoPosAndSizeDefault(pAudPtr)
  Protected bIsDefault
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If (\nXPos = grAudDef\nXPos) And
         (\nYPos = grAudDef\nYPos) And
         (\nSize = grAudDef\nSize)
        bIsDefault = #True
      EndIf
    EndWith
  EndIf
  ProcedureReturn bIsDefault

EndProcedure

Procedure listVidPicTargets(nMinVidPicTarget=0, nMaxVidPicTarget=#SCS_VID_PIC_TARGET_LAST)
  PROCNAMEC()
  Protected nVidPicTarget
  
  For nVidPicTarget = nMinVidPicTarget To nMaxVidPicTarget
    With grVidPicTarget(nVidPicTarget)
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) +
                          ", \nPrevPlayingSubPtr=" + getSubLabel(\nPrevPlayingSubPtr) +
                          ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr))
    EndWith
  Next nVidPicTarget
  
EndProcedure

Procedure createMemoryImageForAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected bMemoryImageCreated
  Protected nOriginalImage, nImageWidth, nImageHeight
  Protected nOutputScreen, nVidPicTarget, nScreenWidth, nScreenHeight
  
  debugMsg(sProcName, #SCS_START)
  
  ; nb may need to modify for rotation
  
  With aAud(pAudPtr)
    If IsImage(\nMemoryImageNo)
      FreeImage(\nMemoryImageNo)
      \nMemoryImageNo = 0
    EndIf
    \bUsingMemoryImage = #False
    If FileExists(\sFileName)
      nOriginalImage = LoadImage(#PB_Any, \sFileName)
      If IsImage(nOriginalImage)
        nImageWidth = ImageWidth(nOriginalImage)
        nImageHeight = ImageHeight(nOriginalImage)
        debugMsg(sProcName, "\sFileName=" + GetFilePart(\sFileName) + ", nImageWidth=" + nImageWidth + ", nImageHeight=" + nImageHeight)
        nOutputScreen = aSub(\nSubIndex)\nOutputScreen
        nVidPicTarget = getVidPicTargetForOutputScreen(nOutputScreen)
        nScreenWidth = grVidPicTarget(nVidPicTarget)\nMainWindowWidth
        nScreenHeight = grVidPicTarget(nVidPicTarget)\nMainWindowHeight
        debugMsg(sProcName, "nOutputScreen=" + nOutputScreen + ", nScreenWidth=" + nScreenWidth + ", nScreenHeight=" + nScreenHeight)
        calcDisplayPosAndSize3(pAudPtr, nImageWidth, nImageHeight, nScreenWidth, nScreenHeight, 0, 0)
        \nMemoryImageNo = scsCreateImage(nScreenWidth, nScreenHeight)
        If IsImage(\nMemoryImageNo)
          paintPictureAtPosAndSize(pAudPtr, \nMemoryImageNo, nOriginalImage, #False)
          \bUsingMemoryImage = #True
          bMemoryImageCreated = #True
        EndIf
        FreeImage(nOriginalImage)
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning bMemoryImageCreated=" + strB(bMemoryImageCreated))
  ProcedureReturn bMemoryImageCreated
  
EndProcedure

Procedure checkVideoFadesExist()
  PROCNAMEC()
  Protected i, j, k, bVideoFadesExist
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueEnabled And aCue(i)\bSubTypeA
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled And aSub(j)\bSubTypeA And aSub(j)\bSubPlaceHolder = #False
          k = aSub(j)\nFirstPlayIndex
          While k >= 0
            With aAud(k)
              If \nFileFormat = #SCS_FILEFORMAT_VIDEO
                If \nPrevPlayIndex < 0 And aSub(j)\nPLFadeInTime > 0
                  bVideoFadesExist = #True
                  ; debugMsg0(sProcName, "bVideoFadesExist, j=" + getSubLabel(j))
                  Break 3 ; Break k, j, i
                Else
                  If \nPrevPlayIndex > 0
                    If aAud(\nPrevPlayIndex)\nPLTransType = #SCS_TRANS_XFADE Or aAud(\nPrevPlayIndex)\nPLTransType = #SCS_TRANS_MIX
                      If aAud(\nPrevPlayIndex)\nPLTransTime > 0
                        bVideoFadesExist = #True
                        ; debugMsg0(sProcName, "bVideoFadesExist, k=" + getAudLabel(k) + ", \nPrevPlayIndex=" + getAudLabel(\nPrevPlayIndex))
                        Break 3 ; Break k, j, i
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
              k = \nNextPlayIndex
            EndWith
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
;   If bVideoFadesExist = #False
;     debugMsg0(sProcName, #SCS_END + ", returning " + strB(bVideoFadesExist))
;   EndIf
  ProcedureReturn bVideoFadesExist
EndProcedure

Procedure setNew2DDrawingInd(pSubPtr)
  PROCNAMECS(pSubPtr)
  ; This procedure will set aSub(pSubPtr)\bUseNew2DDrawing #True under some very specific conditions - otherwise \bUseNew2DDrawing will set #False.
  ; This feature was added in 11.8.4 to improve crossfades between still images. Crossfades work quite well under TVG, but there is a slight glitch at
  ; the end of the crossfade when the TVG control of the faded-out image is closed. Using 2D Drawing provides a clean crossfade.
  ; The use of the 2D Drawing library was previously dropped in SCS 11.8.3 as using both TVG and the 2D Drawing Library doesn't support crossfades
  ; between still images (displayed using 2D Drawing) and videos (displayed using TVG).
  ; But since we can get better still image crossfades using the 2D Drawing Library, this Procedure attempts to assess whether or not 2D Drawing may be
  ; used for this sub-cue. Since it's not absolutely necessary to use 2D Drawing, the conditions are not all-encompasing, so if SCS considers there's
  ; any doubt about it then it sets aSub(pSubPtr)\bUseNew2DDrawing #False.
  ; The conditions required to set this #True are:
  ;   1. The sub-cue must have still images only, and more than one still image.
  ;   2. There must be no other video/image sub-cues in the cue.
  Protected bNew2DDrawing, nCuePtr, j, k
  
  With aSub(pSubPtr)
    If \bSubTypeA
      If \bSubEnabled And aCue(\nCueIndex)\bCueEnabled And \bSubPlaceHolder = #False And checkVideoFadesExist() = #False
        bNew2DDrawing = #True
        k = \nFirstAudIndex
        While k >= 0
          If aAud(k)\nFileFormat <> #SCS_FILEFORMAT_PICTURE
            bNew2DDrawing = #False
            Break
          EndIf
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      If bNew2DDrawing
        nCuePtr = \nCueIndex
        j = aCue(nCuePtr)\nFirstSubIndex
        While j >= 0
          If j <> pSubPtr
            If aSub(j)\bSubTypeA And aSub(j)\bSubEnabled And aSub(j)\bSubPlaceHolder = #False
              bNew2DDrawing = #False
              Break
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      If bNew2DDrawing <> \bUseNew2DDrawing
        \bUseNew2DDrawing = bNew2DDrawing
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bUseNew2DDrawing=" + strB(\bUseNew2DDrawing))
      EndIf
      ; debugMsg0(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bUseNew2DDrawing=" + strB(\bUseNew2DDrawing))
    EndIf
  EndWith
  
EndProcedure

Procedure checkUse2DDrawing(pSubPtr=-1)
  PROCNAMECS(pSubPtr)
  ; see comments in setNew2DDrawingInd() above
  Protected bUse2DDrawing
  
  If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
    If pSubPtr >= 0
      bUse2DDrawing = aSub(pSubPtr)\bUseNew2DDrawing
    EndIf
  EndIf
  ; debugMsg0(sProcName, #SCS_END + ", returning bUse2DDrawing=" + strB(bUse2DDrawing))
  ProcedureReturn bUse2DDrawing
EndProcedure

; Added 9Mar2022 11.9.1ai
; ---------------------------------------------------------------------------------------------------------------
; The following derived from code supplied by RASHAD for rotating images - see "PB Test Files\ImageRotateTest.pb"
; See also RASHAD's Forum reply at https://www.purebasic.fr/english/viewtopic.php?p=568113#p568113
; ---------------------------------------------------------------------------------------------------------------
EnumerationBinary 128
  #BS128
  #BS256
  #BS512
  #BS1024
  #BS2048
EndEnumeration
#BlockSize=#BS512; A BlockSize of 512x512 turned out to be the fastest way to rotate a big image 

Procedure RotateLeft90(nImage)
  PROCNAMECA(nEditAudPtr)
  Protected iw, ih, x, y, dc, nTmpImage1, nTmpImage2
  
  debugMsg(sProcName, #SCS_START + ", nImage=" + decodeHandle(nImage) + ", ImageWidth(" + decodeHandle(nImage) + ")=" + ImageWidth(nImage) + ", ImageHeight(" + decodeHandle(nImage) + ")=" + ImageHeight(nImage))
  iw=ImageWidth(nImage):ih=ImageHeight(nImage)
  ; nTmpImage1 = CreateImage(#PB_Any, ih, iw)
  nTmpImage1 = scsCreateImage(ih, iw)
  If nTmpImage1
    Dim p.point(2)
    For y=0 To ih Step #BlockSize
      For x=0 To iw Step #BlockSize
        nTmpImage2 = GrabImage(nImage, #PB_Any, x, y, #BlockSize, #BlockSize)
        If nTmpImage2
          p(0)\x=0
          p(0)\y=#BlockSize
          p(1)\x=0
          p(1)\y=0
          p(2)\x=#BlockSize
          p(2)\y=#BlockSize
          dc = StartDrawing(ImageOutput(nTmpImage2))
          If dc
            PlgBlt_(dc, p(), dc, 0, 0, #BlockSize, #BlockSize, 0, 0, 0)
            ; debugMsg(sProcName, "y=" + y + ", x=" + x)
          EndIf
          StopDrawing()
          If StartDrawing(ImageOutput(nTmpImage1))
            DrawImage(ImageID(nTmpImage2), y, iw-x-#BlockSize)
            StopDrawing()
          EndIf
        EndIf
      Next
    Next
    CopyImage(nTmpImage1, nImage)
    If IsImage(nTmpImage1) : FreeImage(nTmpImage1) : EndIf
    If IsImage(nTmpImage2) : FreeImage(nTmpImage2) : EndIf
  EndIf
  debugMsg(sProcName, #SCS_END + ", nImage=" + decodeHandle(nImage) + ", ImageWidth(" + decodeHandle(nImage) + ")=" + ImageWidth(nImage) + ", ImageHeight(" + decodeHandle(nImage) + ")=" + ImageHeight(nImage))
EndProcedure

Procedure RotateRight90(nImage)
  PROCNAMECA(nEditAudPtr)
  Protected iw, ih, x, y, dc, nTmpImage1, nTmpImage2
  
  debugMsg(sProcName, #SCS_START + ", nImage=" + decodeHandle(nImage) + ", ImageWidth(" + decodeHandle(nImage) + ")=" + ImageWidth(nImage) + ", ImageHeight(" + decodeHandle(nImage) + ")=" + ImageHeight(nImage))
  iw=ImageWidth(nImage):ih=ImageHeight(nImage)
  ; nTmpImage1 = CreateImage(#PB_Any, ih, iw)
  nTmpImage1 = scsCreateImage(ih, iw)
  If nTmpImage1
    Dim p.point(2)
    For y=0 To ih Step #BlockSize
      For x=0 To iw Step #BlockSize
        nTmpImage2 = GrabImage(nImage, #PB_Any, x, y, #BlockSize, #BlockSize)
        If nTmpImage2
          p(0)\x=#BlockSize
          p(0)\y=0
          p(1)\x=#BlockSize
          p(1)\y=#BlockSize
          p(2)\x=0
          p(2)\y=0
          dc = StartDrawing(ImageOutput(nTmpImage2))
          If dc
            PlgBlt_(dc, p(), dc, 0, 0, #BlockSize, #BlockSize, 0, 0, 0)
            ; debugMsg(sProcName, "y=" + y + ", x=" + x)
            StopDrawing()
          EndIf
          If StartDrawing(ImageOutput(nTmpImage1))
            DrawImage(ImageID(nTmpImage2), ih-y-#BlockSize, x)
            StopDrawing()
          EndIf
        EndIf
      Next
    Next
    CopyImage(nTmpImage1, nImage)
    If IsImage(nTmpImage1) : FreeImage(nTmpImage1) : EndIf
    If IsImage(nTmpImage2) : FreeImage(nTmpImage2) : EndIf
  EndIf
  debugMsg(sProcName, #SCS_END + ", nImage=" + decodeHandle(nImage) + ", ImageWidth(" + decodeHandle(nImage) + ")=" + ImageWidth(nImage) + ", ImageHeight(" + decodeHandle(nImage) + ")=" + ImageHeight(nImage))
EndProcedure

; --------------------------------------------------
; End of code supplied by RASHAD for rotating images
; --------------------------------------------------
; End added 9Mar2022 11.9.1ai

Procedure checkif_VidCapDevsDefined()
  ; Check if a video capture device is connected or setup in Production Properties
  Protected bResult, nDevMapPtr, d
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    d = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While d >= 0
      If grMaps\aDev(d)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
        bResult = #True
        Break
      EndIf
      d = grMaps\aDev(d)\nNextDevIndex
    Wend
  EndIf  
  
  ProcedureReturn bResult
EndProcedure

Procedure calcAudLoudness(pAudPtr, pNormalizationType)
  PROCNAMECA(pAudPtr)
  Protected nAbsMin, nAbsMax, qMinBytePos.q, qMaxBytePos.q
  Protected nDecoder.l, nLoudness.l, nBytesRead.l, nBassResult.l
  Protected Dim fBuf.f(10000)
  Protected nGetDataLength.l
  Protected nLoopIndex, sMsg.s
  Protected nLoudnessFlags.l
  
  If pNormalizationType & #SCS_NORMALIZE_LUFS      : nLoudnessFlags | #BASS_LOUDNESS_INTEGRATED : EndIf
  CompilerIf #c_include_peak
    If pNormalizationType & #SCS_NORMALIZE_PEAK      : nLoudnessFlags | #BASS_LOUDNESS_PEAK       : EndIf
  CompilerEndIf
  If pNormalizationType & #SCS_NORMALIZE_TRUE_PEAK : nLoudnessFlags | #BASS_LOUDNESS_TRUEPEAK   : EndIf
  
  With aAud(pAudPtr)
    ; debugMsg0(sProcName, "\bAudNormSet=" + strB(\bAudNormSet))
    While #True ; dummy loop so 'Break' can be used to skip to the end if an error is detected
      If \bAudNormSet = #False And  \bAudPlaceHolder = #False
        nAbsMin = \nAbsMin
        nAbsMax = \nAbsMax
        qMinBytePos = \qStartAtBytePos
        qMaxBytePos = \qEndAtBytePos
        If \bAudTypeAorF
          For nLoopIndex = 0 To \nMaxLoopInfo
            If \aLoopInfo(nLoopIndex)\qLoopStartBytePos < qMinBytePos : qMinBytePos = \aLoopInfo(nLoopIndex)\qLoopStartBytePos : EndIf
            If \aLoopInfo(nLoopIndex)\qLoopEndBytePos > qMaxBytePos   : qMaxBytePos = \aLoopInfo(nLoopIndex)\qLoopEndBytePos   : EndIf
          Next nLoopIndex
        EndIf
        nDecoder = BASS_StreamCreateFile(0, @\sFileName, 0, 0, #BASS_STREAM_DECODE | #BASS_SAMPLE_FLOAT | #BASS_UNICODE)
        debugMsg(sProcName, "BASS_StreamCreateFile(0, @" + #DQUOTE$ + \sFileName + #DQUOTE$ + ", 0, 0, #BASS_STREAM_DECODE | #BASS_SAMPLE_FLOAT | #BASS_UNICODE) returned nDecoder=" + nDecoder)
        If nDecoder = 0
          debugMsg(sProcName, "BASS_ErrorGetCode()=" + BASS_ErrorGetCode())
          Break
        EndIf
        If qMinBytePos > 0
          nBassResult = BASS_ChannelSetPosition(nDecoder, qMinBytePos, #BASS_POS_BYTE)
          debugMsg(sProcName, "BASS_ChannelSetPosition(nDecoder, " + qMinBytePos + ", #BASS_POS_BYTE) returned nBassResult=" + nBassResult)
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
        EndIf
        If qMaxBytePos > 0
          nBassResult = BASS_ChannelSetPosition(nDecoder, qMaxBytePos, #BASS_POS_END)
          debugMsg(sProcName, "BASS_ChannelSetPosition(nDecoder, " + qMaxBytePos + ", #BASS_POS_END) returned nBassResult=" + nBassResult)
          If nBassResult = #BASSFALSE
            debugMsg3(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
          EndIf
        EndIf
        nLoudness = BASS_LOUDNESS_Start(nDecoder, nLoudnessFlags | #BASS_LOUDNESS_AUTOFREE, 0)
        debugMsg(sProcName, "BASS_LOUDNESS_Start(nDecoder, " + Str(nLoudnessFlags | #BASS_LOUDNESS_AUTOFREE) + ", 0) returned nLoudness=" + nLoudness)
        If nLoudness = 0
          debugMsg(sProcName, "Can't start loudness measurement")
          Break
        EndIf
        nGetDataLength = (10000 * 4)
        While (#True)
          nBytesRead = BASS_ChannelGetData(nDecoder, @fBuf(0), nGetDataLength)
          ; debugMsg(sProcName, "BASS_ChannelGetData(nDecoder, @fBuf(0), " + nGetDataLength + ") returned nBytesRead=" + nBytesRead)
          If nBytesRead < 0 : Break : EndIf
        Wend
        If pNormalizationType & #SCS_NORMALIZE_LUFS      : BASS_Loudness_GetLevel(nLoudness, #BASS_LOUDNESS_INTEGRATED, @\fAudNormIntegrated) : EndIf
        CompilerIf #c_include_peak
          If pNormalizationType & #SCS_NORMALIZE_PEAK      : BASS_Loudness_GetLevel(nLoudness, #BASS_LOUDNESS_PEAK, @\fAudNormPeak)             : EndIf
        CompilerEndIf
        If pNormalizationType & #SCS_NORMALIZE_TRUE_PEAK : BASS_Loudness_GetLevel(nLoudness, #BASS_LOUDNESS_TRUEPEAK, @\fAudNormTruePeak)     : EndIf
        ; Free the decoder
        ; NB do not free the decode channel until AFTER all calls to BASS_Loudness_GetLevel() because BASS_LOUDNESS_Start() 
        ; includes the flag #BASS_LOUDNESS_AUTOFREE, which frees the loudness handle when the decoder channel is freed.
        nBassResult = BASS_ChannelFree(nDecoder)
        debugMsg(sProcName, "BASS_ChannelFree(nDecoder) returned nBassResult=" + nBassResult)
        \bAudNormSet = #True
        
        sMsg = ""
        If pNormalizationType & #SCS_NORMALIZE_LUFS
          If \fAudNormIntegrated = -Infinity() ; no loudness level available (too short or silent)
            sMsg + "Integrated: n/a"
          Else
            sMsg + "Integrated: " + StrF(\fAudNormIntegrated,2)
          EndIf
        EndIf
        CompilerIf #c_include_peak
          If pNormalizationType & #SCS_NORMALIZE_PEAK : sMsg + " Peak: " + StrF(\fAudNormPeak,3) : EndIf
        CompilerEndIf
        If pNormalizationType & #SCS_NORMALIZE_TRUE_PEAK : sMsg + " TruePeak: " + StrF(\fAudNormTruePeak,3) : EndIf
        debugMsg(sProcName, sMsg)
        
      EndIf
      Break
    Wend
  EndWith
  
EndProcedure

; EOF