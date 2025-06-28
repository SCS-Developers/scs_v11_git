; File: StatusCheck.pbi

EnableExplicit

Procedure SC_PlayAudForStatusCheck(pAudPtr, bEditing)
  PROCNAMECA(pAudPtr)
  
  If pAudPtr >= 0
    If gnThreadNo > #SCS_THREAD_MAIN
      samAddRequest(#SCS_SAM_PLAY_AUD_FOR_STATUS_CHECK, pAudPtr, 0, bEditing)
      ProcedureReturn
    EndIf
    
    With aAud(pAudPtr)
      \qPLTimeTransStarted = gqTimeNow
      ; debugMsg(sProcName, "nLabel=" + nLabel + ", calling setPLLevels(" + pAudPtr + ")")
      ; setPLLevels(pAudPtr)
      debugMsg(sProcName, "calling playAud(" + getAudLabel(pAudPtr) + ")")
      playAud(pAudPtr, #False, #False, -1, #True, #False)
      \qTimeAudStarted = gqTimeNow
      ; \nTimeAudEnded = 0
      \bTimeAudEndedSet = #False
      \qTimeAudRestarted = gqTimeNow
      debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\qTimeAudRestarted=" + traceTime(\qTimeAudRestarted))
      \nTotalTimeOnPause = 0
      \nPreFadeInTimeOnPause = 0
      \nPreFadeOutTimeOnPause = 0
      aSub(\nSubIndex)\nCurrPlayIndex = pAudPtr
      debugMsg(sProcName, "calling calcPLUnplayedFilesTime(" + getSubLabel(\nSubIndex) + ")")
      calcPLUnplayedFilesTime(\nSubIndex)
      If (bEditing) And (nEditSubPtr = \nSubIndex)
        samAddRequest(#SCS_SAM_SET_CURR_QA_ITEM, WQA_getItemForAud(pAudPtr))
      EndIf
    EndWith
  EndIf 
EndProcedure

Procedure SC_SubCompleteCommon(pSubPtr, bStopSub=#True)
  PROCNAMECS(pSubPtr)
  
  With aSub(pSubPtr)
    If bStopSub
      debugMsg(sProcName, "calling stopSub(" + getSubLabel(pSubPtr) + ", " + #DQUOTE$ + \sSubType + #DQUOTE$ + ", #True, #False)")
      stopSub(pSubPtr, \sSubType, #True, #False)
    EndIf
    If aCue(\nCueIndex)\bNonLinearCue And aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_TIME
      debugMsg(sProcName, " calling endOfSub(" + getSubLabel(pSubPtr) + ", #SCS_CUE_NOT_LOADED)")
      endOfSub(pSubPtr, #SCS_CUE_NOT_LOADED)
    Else
      If \nSubStart = #SCS_SUBSTART_OCM Or \nSubStart = #SCS_SUBSTART_REL_MTC
        debugMsg(sProcName, " calling endOfSub(" + getSubLabel(pSubPtr) + ", #SCS_CUE_COMPLETED)")
        endOfSub(pSubPtr, #SCS_CUE_COMPLETED)
      ElseIf aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_HK_STEP
        debugMsg(sProcName, " calling endOfSub(" + getSubLabel(pSubPtr) + ", #SCS_CUE_COMPLETED)")
        endOfSub(pSubPtr, #SCS_CUE_COMPLETED)
      ElseIf \bHotkey Or \bExtAct Or \bCallableCue
        debugMsg(sProcName, " calling endOfSub(" + getSubLabel(pSubPtr) + ", #SCS_CUE_READY), \bHotkey=" + strB(\bHotkey) + ", \bExtAct=" + strB(\bExtAct) + ", \bCallableCue=" + strB(\bCallableCue))
        endOfSub(pSubPtr, #SCS_CUE_READY)
      Else
        debugMsg(sProcName, " calling endOfSub(" + getSubLabel(pSubPtr) + ", #SCS_CUE_COMPLETED)")
        endOfSub(pSubPtr, #SCS_CUE_COMPLETED)
      EndIf
    EndIf
    debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(\nCueIndex) + ")")
    setCueStateAndUpdateGrid(\nCueIndex)
    If \bStartedInEditor = #False
      gnCallOpenNextCues = 1
      If getHideCueOpt(\nCueIndex) = #SCS_HIDE_NO  ; added test 19Jul2018 11.7.1.1ac to try to minimise screen refreshing when starting or completing a hidden auto-start cue
        gbCallLoadDispPanels = #True
      EndIf
    EndIf
  EndWith

EndProcedure

Procedure SC_SubTypeA(pAudPtr, nMyNextPlayIndex)
  ;- Process Video/Image
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, nSubPtr, bSubStartedInEditor, nLabel
  Protected d
  Protected nMySubState, nMyPrevPlayIndex, nPrevAudState, bStopSub, bDoFadeOut, bUse2DDrawing
  Protected nAudFadeInTime, nAudFadeOutTime, nReqdAlphaBlend, bChannelPlaying, nMovieNo, nPictureTarget
  
  With aAud(pAudPtr)
    nCuePtr = \nCueIndex
    nSubPtr = \nSubIndex
    nMySubState = aSub(nSubPtr)\nSubState
    bSubStartedInEditor = aSub(nSubPtr)\bStartedInEditor
    If \nPrevPlayIndex >= 0
      nMyPrevPlayIndex = \nPrevPlayIndex
    Else
      nMyPrevPlayIndex = aSub(\nSubIndex)\nLastPlayIndex
    EndIf
    nPrevAudState = aAud(nMyPrevPlayIndex)\nAudState
    
    If \nCurrFadeInTime > 0
      nAudFadeInTime = \nCurrFadeInTime
    EndIf
    If gbFadingEverything
      nAudFadeOutTime = gnFadeEverythingTime
    ElseIf \nCurrFadeOutTime > 0
      nAudFadeOutTime = \nCurrFadeOutTime
    EndIf
    
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState) +
    ;                     ", nPrevAudState=" + decodeCueState(nPrevAudState) + ", gbFadingEverything=" + strB(gbFadingEverything))
    If (\nAudState = #SCS_CUE_PL_READY) And (gbStoppingEverything = #False) ; And bSubStartedInEditor = #False
      ; nb cue_pl_ready only set for 2nd and subsequent aud's, or for the 1st aud if continuous and on 2nd or later pass
      If (bSubStartedInEditor = #False) And (aSub(nSubPtr)\nSubState <= #SCS_CUE_READY)
        ; do nothing
      ElseIf (nPrevAudState = #SCS_CUE_TRANS_FADING_OUT) Or (nPrevAudState = #SCS_CUE_COMPLETED)
        If GetActiveWindow() = #WED
          gbSetEditorWindowActive = #True
          debugMsg(sProcName, "gbSetEditorWindowActive=" + strB(gbSetEditorWindowActive))
        EndIf
        If aSub(nSubPtr)\bPLTerminating
          debugMsg(sProcName, " calling stopAud(" + \sAudLabel + ")")
          stopAud(pAudPtr)
        Else
          debugMsg(sProcName, "calling SC_PlayAudForStatusCheck(" + getAudLabel(pAudPtr) + ", " + strB(gbEditing) + ")")
          SC_PlayAudForStatusCheck(pAudPtr, gbEditing)
        EndIf
      EndIf
    EndIf
    
    If (\nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START) And (gbGlobalPause = #False)
      ;debugMsg(sProcName, "\nPrevPlayIndex=" + \nPrevPlayIndex)
      nMyPrevPlayIndex = \nPrevPlayIndex
      ; If (nMyPrevPlayIndex = -1) And (aSub(\nSubIndex)\bPLRepeat)
      If (nMyPrevPlayIndex = -1) And (getPLRepeatActive(\nSubIndex))
        nMyPrevPlayIndex = aSub(\nSubIndex)\nLastPlayIndex
      EndIf
      \nPLCountDownTimeLeft = aAud(nMyPrevPlayIndex)\nPLTransTime - (gqTimeNow - \qPLTimeTransStarted)
      If \nPLCountDownTimeLeft <= 0
        \nPLCountDownTimeLeft = 0
        If \nFileFormat = #SCS_FILEFORMAT_VIDEO
          setPLLevels(pAudPtr, #True, #True)
        EndIf
        debugMsg(sProcName, "calling playAud(" + pAudPtr + ")")
        playAud(pAudPtr, #False, #False, -1, #True)
        \qTimeAudStarted = gqTimeNow
        \bTimeAudEndedSet = #False
        \qTimeAudRestarted = gqTimeNow
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\qTimeAudRestarted=" + traceTime(\qTimeAudRestarted))
        \nTotalTimeOnPause = 0
        \nPreFadeInTimeOnPause = 0
        \nPreFadeOutTimeOnPause = 0
        aSub(\nSubIndex)\nCurrPlayIndex = pAudPtr
        debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\nCurrPlayIndex=" + getAudLabel(aSub(\nSubIndex)\nCurrPlayIndex))
        debugMsg(sProcName, "calling calcPLUnplayedFilesTime(" + getSubLabel(\nSubIndex) + ")")
        calcPLUnplayedFilesTime(\nSubIndex)
        If (gbEditing) And (nEditSubPtr = \nSubIndex)
          samAddRequest(#SCS_SAM_SET_CURR_QA_ITEM, WQA_getItemForAud(pAudPtr))
        EndIf
      EndIf
      
    ElseIf ((\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)) Or (\nAudState = #SCS_CUE_COMPLETED)
      If nPrevAudState = #SCS_CUE_COMPLETED
        ; If aSub(\nSubIndex)\bPLRepeat
        If getPLRepeatActive(nSubPtr)
          debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\bPLRepeat=" + strB(aSub(\nSubIndex)\bPLRepeat) +", \bPLRepeatCancelled=" + strB(aSub(\nSubIndex)\bPLRepeatCancelled))
          If aSub(\nSubIndex)\bPLTerminating = #False
            setPlaylistTrackReadyState(nMyPrevPlayIndex)
            debugMsg(sProcName, "calling rewindAud( " + aAud(nMyPrevPlayIndex)\sAudLabel + ")")
            rewindAud(nMyPrevPlayIndex)
          EndIf
        EndIf
      EndIf
      
    EndIf
    
    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
      gqTimeDiskActive = gqTimeNow
      ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
      calcCuePositionForAud(pAudPtr)
      
      If \nFileFormat = #SCS_FILEFORMAT_VIDEO
        Select \nAudState
          Case #SCS_CUE_FADING_IN, #SCS_CUE_TRANS_FADING_IN
            ; debugMsg3(sProcName, "aAud(" + getAudLabel(pAudPtr) + "\nAudState=" + decodeCueState(\nAudState) + ", calling setPLLevels(" + getAudLabel(pAudPtr) + ", #True, #True)")
            setPLLevels(pAudPtr, #True, #True)
          Case #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_OUT
            ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + "\nAudState=" + decodeCueState(\nAudState) + ", calling setPLLevels(" + getAudLabel(pAudPtr) + ", #True, #True)")
            setPLLevels(pAudPtr, #True, #False, #True)
            ; Default
            ; setPLLevels(pAudPtr)
        EndSelect
      EndIf
      
    ElseIf (\nAudState = #SCS_CUE_PL_READY) And ((nMySubState >= #SCS_CUE_FADING_IN) And (nMySubState <= #SCS_CUE_FADING_OUT))
      If \nFileFormat = #SCS_FILEFORMAT_VIDEO
        ; debugMsg(sProcName, "calling setPLLevelsIfReqd(" + getAudLabel(pAudPtr) + ")")
        setPLLevelsIfReqd(pAudPtr)
      EndIf
    EndIf
    
    If (\nAudState = #SCS_CUE_TRANS_FADING_IN) Or (\nAudState = #SCS_CUE_FADING_IN)
      getChannelAttributes(pAudPtr)
      If \nAudState = #SCS_CUE_TRANS_FADING_IN
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) +
        ;                     ", \nCuePos=" + \nCuePos + ", \nCurrFadeInTime=" + \nCurrFadeInTime + ", nAudFadeInTime=" + nAudFadeInTime + ", aAud(" + getAudLabel(pAudPtr) + ")\bBlending=" + strB(aAud(pAudPtr)\bBlending))
        If (\nCuePos >= nAudFadeInTime) And (\bBlending = #False)
          \nAudState = #SCS_CUE_PLAYING
          ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          CompilerIf #c_include_tvg
            If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG And \bAudTypeA
              removeAudFromTVGFadeAudArray(pAudPtr)
            EndIf
          CompilerEndIf
          ; debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
          setCueStateAndUpdateGrid(nCuePtr)
          If gnCallOpenNextCues = 0
            gnCallOpenNextCues = nCuePtr
            ; debugMsg(sProcName, "gnCallOpenNextCues=" + getCueLabel(gnCallOpenNextCues))
          EndIf
        EndIf
        
      Else ; #SCS_CUE_FADING_IN
        If aSub(\nSubIndex)\bPLFadingIn
          ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bTimeFadeInStartedSet=" + strB(\bTimeFadeInStartedSet) + ", \qTimeFadeInStarted=" + traceTime(\qTimeFadeInStarted) +
          ;                    ", aSub(" + getSubLabel(\nSubIndex) + ")\nPLCurrFadeInTime)=" + traceTime(aSub(\nSubIndex)\nPLCurrFadeInTime))
          If (\bTimeFadeInStartedSet) And ((gqTimeNow - \qTimeFadeInStarted) >= aSub(\nSubIndex)\nPLCurrFadeInTime)
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
            \nAudState = #SCS_CUE_PLAYING
            ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
            CompilerIf #c_include_tvg
              If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG And \bAudTypeA
                removeAudFromTVGFadeAudArray(pAudPtr)
              EndIf
            CompilerEndIf
            aSub(\nSubIndex)\bPLFadingIn = #False
            ; debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
            setCueStateAndUpdateGrid(nCuePtr)
            If gnCallOpenNextCues = 0
              gnCallOpenNextCues = nCuePtr
              ; debugMsg(sProcName, "gnCallOpenNextCues=" + getCueLabel(gnCallOpenNextCues))
            EndIf
          EndIf
        ElseIf (\bTimeFadeInStartedSet) And ((gqTimeNow - \qTimeFadeInStarted) >= nAudFadeInTime) And (\bBlending = #False)
          ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          \nAudState = #SCS_CUE_PLAYING
          CompilerIf #c_include_tvg
            If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG And \bAudTypeA
              removeAudFromTVGFadeAudArray(pAudPtr)
            EndIf
          CompilerEndIf
          ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          ; debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
          setCueStateAndUpdateGrid(nCuePtr)
          If gnCallOpenNextCues = 0
            gnCallOpenNextCues = nCuePtr
            ; debugMsg(sProcName, "gnCallOpenNextCues=" + getCueLabel(gnCallOpenNextCues))
          EndIf
        EndIf
      EndIf
      
      If grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG
        If nAudFadeInTime <= 0
          nReqdAlphaBlend = 255
        ElseIf ((\bTimeFadeInStartedSet) And (gqTimeNow - \qTimeFadeInStarted) >= nAudFadeInTime) Or (\nAudState = #SCS_CUE_PLAYING)
          nReqdAlphaBlend = 255
        Else
          If \bTimeFadeInStartedSet
            nReqdAlphaBlend = ((gqTimeNow - \qTimeFadeInStarted) * 255) / nAudFadeInTime
          Else
            nReqdAlphaBlend = 0
          EndIf
        EndIf
        CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bTimeFadeInStartedSet=" + strB(\bTimeFadeInStartedSet) +
                              ", gqTimeNow=" + traceTime(gqTimeNow) +
                              ", \qTimeFadeInStarted=" + traceTime(\qTimeFadeInStarted) +
                              ", nAudFadeInTime=" + nAudFadeInTime +
                              ", \nAudState=" + decodeCueState(\nAudState) + ", nReqdAlphaBlend=" + Str(nReqdAlphaBlend))
        CompilerEndIf
        setAlphaBlend(pAudPtr, nReqdAlphaBlend)
      EndIf
    EndIf
    
    If ((\nAudState = #SCS_CUE_PLAYING) Or (\nAudState = #SCS_CUE_FADING_OUT)) ; And (\nGaplessSeqPtr = -1) ; do NOT include #SCS_CUE_TRANS_FADING_OUT
      ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt + ", nMyNextPlayIndex=" + nMyNextPlayIndex)
      bChannelPlaying = #True
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE Or \nFileFormat = #SCS_FILEFORMAT_CAPTURE
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos ="+\nRelFilePos+" \nRelEndAt ="+\nRelEndAt)
        If (\nRelFilePos >= \nRelEndAt) And (\bDoContinuous = #False)
          bChannelPlaying = #False
          nLabel = 701
        EndIf
      ElseIf \nAudGaplessSeqPtr >= 0
        If (\nRelFilePos >= \nRelEndAt) Or (\bPlayEndSyncOccurred)
          bChannelPlaying = #False
          nLabel = 702
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt + ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred) + ", bChannelPlaying=" + strB(bChannelPlaying))
        EndIf
      ElseIf \bPlayEndSyncOccurred
        bChannelPlaying = #False
        nLabel = 703
      Else
        If \nRelFilePos >= (\nRelEndAt - 90000)
          ; debugMsg0(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt)
          ; Check bVideoRunning when we are getting near the end of the video.
          If \nAudVidPicTarget = #SCS_VID_PIC_TARGET_NONE ; Could occur if 'Fade All' is used and the video/image sub-cue ends before 'Fade All' is completed (test by Hans van Bemmelen 4Oct2022)
            bChannelPlaying = #False
          Else
            CheckSubInRange(\nAudVidPicTarget, ArraySize(grVidPicTarget()), "grVidPicTarget")
            If grVidPicTarget(\nAudVidPicTarget)\nMovieAudPtr = pAudPtr
              nMovieNo = grVidPicTarget(\nAudVidPicTarget)\nMovieNo
              ; debugMsg(sProcName, "calling checkMovieStopped(" + nMovieNo + ", " + getAudLabel(pAudPtr) + ")")
              If checkMovieStopped(nMovieNo, pAudPtr)
                bChannelPlaying = #False
                nLabel = 704
              ElseIf (\nRelFilePos >= (\nRelEndAt - 300)) And (\bDoContinuous) ; forces the restart slightly before the end to give a slightly smoother restart
                bChannelPlaying = #False
                nLabel = 705
              ElseIf (\nRelFilePos >= \nRelEndAt) And (\bDoContinuous = #False)
                bChannelPlaying = #False
                nLabel = 706
              Else
                bChannelPlaying = grVidPicTarget(\nAudVidPicTarget)\bVideoRunning
                nLabel = 707
              EndIf
              ; If bChannelPlaying = #False
              ;   debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt + ", bChannelPlaying=" + strB(bChannelPlaying) + ", nLabel=" + nLabel)
              ; EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      
      If bChannelPlaying = #False
        debugMsg(sProcName, "bChannelPlaying=" + strB(bChannelPlaying) + ", nLabel=" + nLabel + ", aAud(" + getAudLabel(pAudPtr) + ")\bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred) + ", \nAudState=" + decodeCueState(\nAudState))
        If nMyNextPlayIndex >= 0
          debugMsg(sProcName, "calling playNextAud(" + getAudLabel(pAudPtr) + ", " + getAudLabel(nMyNextPlayIndex) + ")")
          playNextAud(pAudPtr, nMyNextPlayIndex)
          
        ElseIf (aSub(nSubPtr)\bPauseAtEnd) And (aSub(nSubPtr)\bPLTerminating = #False)  ; 5Dec2016 11.5.2.5 added test on aSub(nSubPtr)\bPLTerminating
          If \bInForcedFadeOut = #False
            ; see also eventTVGOnPlayerEndOfStream()
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", calling pauseAud(" + getAudLabel(pAudPtr) + ")")
            pauseAud(pAudPtr)
            debugMsg0(sProcName, "call samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, " + getCueLabel(gnCueToGo) + ")")
            samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, gnCueToGo)
          EndIf
          
        ElseIf bSubStartedInEditor = #False
          If (\nFileFormat = #SCS_FILEFORMAT_VIDEO) And (\bDoContinuous) And (getPLRepeatActive(\nSubIndex))
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bDoContinuous=" + strB(\bDoContinuous) + ", getPLRepeatActive(" + getSubLabel(\nSubIndex) + ")=" + strB(getPLRepeatActive(\nSubIndex)))
            debugMsg(sProcName, "calling setVideoPosition(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(\nAudVidPicTarget) + ", " + \nAbsStartAt + ")")
            setVideoPosition(pAudPtr, \nAudVidPicTarget, \nAbsStartAt, #True, #False, #True)
          Else
            bStopSub = #False
            If (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (isAudInTVGFadeAudArray(pAudPtr) = #False)
              bStopSub = #True
            ElseIf (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX) And (isAudInTVGFadeAudArray(pAudPtr) = #False)
              bStopSub = #True
            EndIf
            If bStopSub
              debugMsg(sProcName, "calling stopSub(" + getSubLabel(nSubPtr) + ", 'A', #True, #False)")
              stopSub(nSubPtr, "A", #True, #False)
            EndIf
          EndIf
          
        Else
          debugMsg(sProcName, "calling editQAStop(" + getSubLabel(nSubPtr) + ")")
          editQAStop(nSubPtr)
          
        EndIf
        
        ; do not call setCueState yet as we may be in limbo between two files in the playlist
        
      ElseIf (nAudFadeOutTime > 0) And (\bInForcedFadeOut = #False)
        ; debugMsg(sProcName, " aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt + ", nAudFadeOutTime=" + nAudFadeOutTime)
        If (\nRelFilePos >= (\nRelEndAt - nAudFadeOutTime - \nFadeOutExtraTime)) And (\bDoContinuous = #False)
          ; 5Dec2016 11.5.2.5 added the following test to prevent a video fading out at the end if the user has specified 'pause at end'
          If \nAudState >= #SCS_CUE_FADING_OUT
            bDoFadeOut = #False
          Else
            bDoFadeOut = #True
            If (\bAudTypeA) And (\nNextPlayIndex = -1)
              ; debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\bPauseAtEnd=" + strB(aSub(nSubPtr)\bPauseAtEnd) + ", \bPLTerminating=" + strB(aSub(nSubPtr)\bPLTerminating))
              If (aSub(nSubPtr)\bPauseAtEnd) And (aSub(nSubPtr)\bPLTerminating = #False)
                bDoFadeOut = #False
              EndIf
            EndIf
          EndIf
          If bDoFadeOut
            \nCurrFadeOutTime = \nRelEndAt - \nRelFilePos - \nFadeOutExtraTime
            debugMsg(sProcName, "changing aAud(" + getAudLabel(pAudPtr) + ")\nAudState from " + decodeCueState(\nAudState) + " to " + decodeCueState(#SCS_CUE_TRANS_FADING_OUT))
            \nAudState = #SCS_CUE_TRANS_FADING_OUT
            debugMsg(sProcName, "" + \sAudLabel + ", calling setCueState(" + getCueLabel(nCuePtr) + ")")
            setCueState(nCuePtr)
            \qTimeFadeOutStarted = gqTimeNow
            \bTimeFadeOutStartedSet = #True
            \nPreFadeOutTimeOnPause = \nTotalTimeOnPause
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + "\nAudState=" + decodeCueState(\nAudState) +
                                ", \bTimeFadeOutStartedSet=" + strB(\bTimeFadeOutStartedSet) + ", \qTimeFadeOutStarted=" + traceTime(\qTimeFadeOutStarted) +
                                ", \nPreFadeOutTimeOnPause=" + \nPreFadeOutTimeOnPause)
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              \fBVLevelWhenFadeOutStarted[d] = \fCueTotalVolNow[d]
            Next d
            ; If (\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (\nFadeOutTime > 0) And (\nNextPlayIndex = -1) And (aSub(nSubPtr)\bPLRepeat = #False)
            If (\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (\nFadeOutTime > 0) And (\nNextPlayIndex = -1) And (getPLRepeatActive(nSubPtr) = #False)
              bUse2DDrawing = checkUse2DDrawing(nSubPtr)
              If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
                fadeOutOneAud(pAudPtr)
              ElseIf (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (bUse2DDrawing = #False)
                fadeOutOneAud(pAudPtr)
              Else
                If (aSub(nSubPtr)\bStartedInEditor) And (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (bUse2DDrawing)
                  nPictureTarget = getVidPicTargetForOutputScreen(aSub(nSubPtr)\nOutputScreen)
                ElseIf (aSub(nSubPtr)\bStartedInEditor)
                  nPictureTarget = #SCS_VID_PIC_TARGET_P
                Else
                  nPictureTarget = getVidPicTargetForOutputScreen(aSub(nSubPtr)\nOutputScreen)
                EndIf
                debugMsg(sProcName, "calling beginFadeOutPrimary(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(nPictureTarget) + ", " + \nFadeOutTime + ")")
                beginFadeOutPrimary(pAudPtr, nPictureTarget, \nFadeOutTime)
              EndIf
            ElseIf (\nFileFormat = #SCS_FILEFORMAT_VIDEO) And (\nFadeOutTime > 0)
              Select grVideoDriver\nVideoPlaybackLibrary
                Case #SCS_VPL_TVG, #SCS_VPL_VMIX
                  fadeOutOneAud(pAudPtr)
              EndSelect
            EndIf
            debugMsg(sProcName, "calling updateGrid(" + getCueLabel(nCuePtr) + ")")
            updateGrid(nCuePtr)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeE(pSubPtr)
  ;- Process Memo
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected bMemoComplete
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    bSubStartedInEditor = \bStartedInEditor
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gbGlobalPause=" + strB(gbGlobalPause))
    If (\nSubState = #SCS_CUE_PLAYING) And (gbGlobalPause = #False) And ((\bMemoContinuous = #False) And (\nMemoDisplayTime > 0))
      \nSubPosition = (gqTimeNow - \qAdjTimeSubStarted) - \nSubTotalTimeOnPause
      If \nSubPosition < 0
        \nSubPosition = 0
      ElseIf \nSubPosition > \nMemoDisplayTime
        \nSubPosition = \nMemoDisplayTime
      EndIf
      If \nSubPosition >= \nMemoDisplayTime
        bMemoComplete = #True
      EndIf
    EndIf
    
    If bMemoComplete
      SC_SubCompleteCommon(pSubPtr)
    EndIf
    
    If (\nSubState = #SCS_CUE_PAUSED)
      \nSubTotalTimeOnPause = (gqTimeNow - \qSubTimePauseStarted) + \nSubPriorTimeOnPause
    EndIf
    
  EndWith
  
EndProcedure

Procedure SC_SubTypeF_or_SubTypeM_MIDI(pAudPtr, bCalledFromLoadLevelPointRun=#False) ; bCalledFromLoadLevelPointRun added 10May2024 11.10.2co following bug reported by Christian Peters
  ;- Process Audio File, or Ctrl Send MIDI file
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, nSubPtr, nLabel
  Protected d, nAudLoopIndex
  Protected nFadeInPosition, bFadeComplete, bProcessed, bStopThisSub, nLinkedToAudPtr, nAudState
  Protected nBassResult.l
  Protected sMidiMode.s
  Protected nAudStartAt
  Static bLTCStoppedMsgLogged
  
  ; debugMsg(sProcName, #SCS_START + ", bCalledFromLoadLevelPointRun=" + strB(bCalledFromLoadLevelPointRun))
  
  With aAud(pAudPtr)
    nCuePtr = \nCueIndex
    nSubPtr = \nSubIndex
    nAudState = \nAudState
    If nAudState = #SCS_CUE_FADING_IN
      ;{
      gqTimeDiskActive = gqTimeNow
      ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bTimeForNextFadeCheckSet=" + strB(\bTimeForNextFadeCheckSet) + ", \qTimeForNextFadeCheck=" + traceTime(\qTimeForNextFadeCheck))
      If (\bTimeForNextFadeCheckSet = #False) Or ((\qTimeForNextFadeCheck - gqTimeNow) <= 0)
        ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
        calcCuePositionForAud(pAudPtr)
        getChannelAttributes(pAudPtr)
        ; Added 10May2024 11.10.2co
        nAudStartAt = \nStartAt
        If nAudStartAt < 0 ; probably -2
          nAudStartAt = 0
        EndIf
        ; End added 10May2024 11.10.2co
        nFadeInPosition = \nCuePos - \nCuePosAtFadeStart ; Moved here and changed 29Aug2024 11.10.3bp
        If \bAudTypeF And \nCuePosAtFadeStart <= nAudStartAt ; Changed 10May2024 11.10.2co
          ; nFadeInPosition = \nCuePos - \nCuePosAtFadeStart ; Changed 29Aug2024 11.10.3bp (added "- \nCuePosAtFadeStart")
          ; debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition + ", nAudStartAt=" + nAudStartAt + ", \nCuePos=" + \nCuePos + ", \nAbsMin=" + \nAbsMin + ", \nCuePosAtFadeStart=" + \nCuePosAtFadeStart + ", \nLoopPassNo=" + \nLoopPassNo)
        Else
          If \bTimeFadeInStartedSet
            nFadeInPosition = (gqTimeNow - \qTimeFadeInStarted) - (\nTotalTimeOnPause - \nPreFadeInTimeOnPause)
            ; debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition)
          Else
            ; shouldn't get here but did during a test - probably because control thread jumped in before \qTimeFadeInStarted had been set.
            ; have now added LockCueListMutex() to control thread and to playCue() to try to stop this happening
            nFadeInPosition = 0
            ; debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition)
          EndIf
        EndIf
        ; debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition + ", \nCurrFadeInTime=" + \nCurrFadeInTime + ", \nCuePos=" + \nCuePos + ", \nCuePosAtFadeStart=" + \nCuePosAtFadeStart + ", \nStartAt=" + \nStartAt +
        ;                     ", gqTimeNow=" + traceTime(gqTimeNow) + ", \qTimeFadeInStarted=" + traceTime(\qTimeFadeInStarted) +
        ;                     ", \nTotalTimeOnPause=" + \nTotalTimeOnPause + ", \nPreFadeInTimeOnPause=" + \nPreFadeInTimeOnPause + ", \bFinalSlide=" + strB(\bFinalSlide))
        If gbUseBASS  ; BASS
          If \bFinalSlide = #False
            If nFadeInPosition < (\nCurrFadeInTime + gnTimerInterval)
              ; this 'if' test (not the code within it) added for PB version to prevent channel slides being permanently called.
              ; appears to be due to a rounding issue on the floats.
              If nFadeInPosition <= (\nCuePos - \nCuePosAtFadeStart + 1000)
                ; debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(pAudPtr) + ", " + Str(\nCuePos - \nCuePosAtFadeStart) + ")")
                doLvlPtRun(pAudPtr, \nCuePos) ; - \nCuePosAtFadeStart))
              EndIf
            EndIf
          EndIf
          
          If nFadeInPosition >= \nCurrFadeInTime
            ; debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition + ", \nCurrFadeInTime=" + \nCurrFadeInTime)
            If bCalledFromLoadLevelPointRun ; Test added 10May2024 11.10.2co following bug reported by Christian Peters
              bFadeComplete = #True
              ; debugMsg(sProcName, "bFadeComplete=" + strB(bFadeComplete))
            Else
              If \nFirstSoundingDev >= 0
                nBassResult = BASS_ChannelIsSliding(\nBassChannel[\nFirstSoundingDev], #BASS_ATTRIB_VOL)
              Else
                nBassResult = #BASSFALSE
              EndIf
              ; debugMsg2(sProcName, "BASS_ChannelIsSliding(" + decodeHandle(\nBassChannel[\nFirstSoundingDev]) + ", #BASS_ATTRIB_VOL))", nBassResult)
              If nBassResult = #BASSFALSE
                bFadeComplete = #True
                ; debugMsg(sProcName, "bFadeComplete=" + strB(bFadeComplete))
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  If \nBassChannel[d] <> 0
                    ; debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(pAudPtr) + ", " + \nCuePos + ")")
                    If doLvlPtRun(pAudPtr, \nCuePos)
                      ; debugMsg(sProcName, "doLvlPtRun(" + getAudLabel(pAudPtr) + ", " + \nCuePos + ") returned #True")
                      bFadeComplete = #False
                    EndIf
                  EndIf
                Next d
              EndIf
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", bFadeComplete=" + strB(bFadeComplete) + ", nFadeInPosition=" + nFadeInPosition + ", \nCurrFadeInTime=" + \nCurrFadeInTime)
            If (bFadeComplete) Or (nFadeInPosition >= (\nCurrFadeInTime+500))
              debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", bFadeComplete=" + strB(bFadeComplete) + ", nFadeInPosition=" + nFadeInPosition + ", \nCurrFadeInTime=" + \nCurrFadeInTime)
              \nAudState = #SCS_CUE_PLAYING
              debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
              nAudStartAt = \nAudState
              \bFinalSlide = #False
              ; debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
              setCueStateAndUpdateGrid(nCuePtr)
              If WCN\nPlayingSubTypeF = \nSubIndex
                WCN\bRefreshAudioChannelFaders = #True
                ; debugMsg(sProcName, "WCN\bRefreshAudioChannelFaders=" + strB(WCN\bRefreshAudioChannelFaders))
              EndIf
            EndIf
          EndIf
          
        Else ; SM-S
          ;{
          If nFadeInPosition >= \nCurrFadeInTime
            debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition + ", \nCurrFadeInTime=" + \nCurrFadeInTime)
            debugMsg(sProcName, "\sAudFinalSetGainCommandString=" + Trim(\sAudFinalSetGainCommandString))
            If \sAudFinalSetGainCommandString
              nLabel = 102
              sendSMSCommandSC("set " + Trim(\sAudFinalSetGainCommandString), #cTraceSetLevels)
            EndIf
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
            \nAudState = #SCS_CUE_PLAYING
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
            ; debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
            setCueStateAndUpdateGrid(nCuePtr)
          EndIf
          ;}
          
        EndIf
        
        If (\nMaxLoopInfo >= 0) And (\rCurrLoopInfo\bLoopReleased = #False)
          If (\rCurrLoopInfo\nNumLoops > 1) And (\nLoopPassNo = 0) And (\nCuePos >= \rCurrLoopInfo\nRelLoopStart)
            \nLoopPassNo = 1
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCurrLoopInfoIndex=" + \nCurrLoopInfoIndex + ", \nLoopPassNo=" + \nLoopPassNo)
          EndIf
        EndIf
        
      EndIf ; EndIf \qTimeForNextFadeCheck <= gqTimeNow
      ;}
    EndIf ; EndIf \nAudState = #SCS_CUE_FADING_IN
    
    If nAudState = #SCS_CUE_PLAYING
      ;{
      If \bLiveInput = #False
        gqTimeDiskActive = gqTimeNow
        ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
        calcCuePositionForAud(pAudPtr)
        getChannelAttributes(pAudPtr)
        ; debugMsg(sProcName, "\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt + ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred))
        bProcessed = #False
        If \nFileFormat = #SCS_FILEFORMAT_MIDI
          If gnPositioningMidi = 0
            sMidiMode = getMidiMode(pAudPtr)
            ; debugMsg(sProcName, " sMidiMode=" + sMidiMode + ", \nEndAt=" + \nEndAt + ", \nAbsEndAt=" + \nAbsEndAt + ", \nRelFilePos=" + \nRelFilePos)
            If ((sMidiMode = "paused") Or (sMidiMode = "stopped")) And (\nRelFilePos > (\nAbsEndAt >> 1))
              debugMsg(sProcName, " sMidiMode=" + sMidiMode + ", \nEndAt=" + \nEndAt + ", \nAbsEndAt=" + \nAbsEndAt + ", \nRelFilePos=" + \nRelFilePos)
              debugMsg(sProcName, " calling stopSub")
              stopSub(nSubPtr, "M", #True, #False)
              debugMsg(sProcName, " calling endOfSub(" + getSubLabel(nSubPtr) + ", -1)")
              endOfSub(nSubPtr, -1)
            ElseIf (sMidiMode = "playing") And (\nEndAt > 1) And (\nRelFilePos >= \nEndAt)
              debugMsg(sProcName, " calling stopSub(" + getSubLabel(nSubPtr) + ", 'M', #True, #False")
              stopSub(nSubPtr, "M", #True, #False)
              debugMsg(sProcName, " calling endOfSub(" + getSubLabel(nSubPtr) + ", -1)")
              endOfSub(nSubPtr, -1)
            EndIf
          Else
            sMidiMode = getMidiMode(pAudPtr)
            debugMsg(sProcName, "gnPositioningMidi=" + gnPositioningMidi + " sMidiMode=" + sMidiMode)
          EndIf
          bProcessed = #True
        EndIf
        
        If bProcessed = #False
          If (\nMaxLoopInfo >= 0) And (\rCurrLoopInfo\bLoopReleased = #False)
            ; debugMsg(sProcName, "\rCurrLoopInfo\nNumLoops=" + \rCurrLoopInfo\nNumLoops + ", \nLoopPassNo=" + \nLoopPassNo +
            ;                     ", \nCuePos=" + \nCuePos + ", \nCuePosWhenLastChecked=" + \nCuePosWhenLastChecked + ", \rCurrLoopInfo\nRelLoopStart=" + \rCurrLoopInfo\nRelLoopStart)
            If (\rCurrLoopInfo\nNumLoops > 1) And (\nCuePos >= \rCurrLoopInfo\nRelLoopStart)
              If \nLoopPassNo = 0
                \nLoopPassNo = 1
                debugMsg(sProcName, "\rCurrLoopInfo\nNumLoops=" + \rCurrLoopInfo\nNumLoops + ", \nLoopPassNo=" + \nLoopPassNo + ", \nCuePos=" + \nCuePos + ", \rCurrLoopInfo\nRelLoopStart=" + \rCurrLoopInfo\nRelLoopStart)
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCurrLoopInfoIndex=" + \nCurrLoopInfoIndex + ", \nLoopPassNo=" + \nLoopPassNo)
              ElseIf \nCuePos < \nCuePosWhenLastChecked
                \nCuePosAtLoopStart + (\rCurrLoopInfo\nRelLoopEnd - \nRelPassStart)
                \nRelPassStart = \rCurrLoopInfo\nRelLoopStart
                \qTimePassStarted = gqTimeNow
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + "\qTimePassStarted=" + \qTimePassStarted)
                \qTimeAudRestarted = \qTimePassStarted
                ; debugMsg(sProcName, "\nCuePosAtLoopStart=" + \nCuePosAtLoopStart + ", \qTimeAudRestarted=" + traceTime(\qTimeAudRestarted))
                \nTotalTimeOnPause = 0
                \nPreFadeInTimeOnPause = 0
                \nPreFadeOutTimeOnPause = 0
                \nLoopPassNo + 1
                ; debugMsg0(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCurrLoopInfoIndex=" + \nCurrLoopInfoIndex + ", \nLoopPassNo=" + \nLoopPassNo)
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCurrLoopInfoIndex=" + \nCurrLoopInfoIndex + ", \nLoopPassNo=" + \nLoopPassNo)
                If \nLoopPassNo >= \rCurrLoopInfo\nNumLoops
                  \rCurrLoopInfo\bLoopReleased = #True
                  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\rCurrLoopInfo\bLoopReleased=" + strB(\rCurrLoopInfo\bLoopReleased))
                  If \bUsingBassLoop
                    nBassResult = BASS_ChannelFlags(\nSourceChannel, 0, #BASS_SAMPLE_LOOP) ; remove the loop flag
                    debugMsg2(sProcName, "BASS_ChannelFlags(" + decodeHandle(\nSourceChannel) + ", 0, #BASS_SAMPLE_LOOP)", nBassResult)
                    If nBassResult = #False : debugMsg(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode())) : EndIf
                    nBassResult = BASS_ChannelSetPosition(\nSourceChannel, \qBassPlayEndByte, #BASS_POS_END)
                    debugMsg2(sProcName, "BASS_ChannelSetPosition(" + decodeHandle(\nSourceChannel) + ", \qBassPlayEndByte, #BASS_POS_END)", nBassResult)
                    If nBassResult = #False : debugMsg(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode())) : EndIf
                  EndIf
                  ; debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_RELEASE_LOOP, " + getAudLabel(pAudPtr) + ")")
                  samAddRequest(#SCS_SAM_RELEASE_LOOP, pAudPtr) ; add request to formally release this loop
                EndIf
              EndIf
              \nCuePosWhenLastChecked = \nCuePos
            EndIf
            ; other actions deferred
            bProcessed = #True
          EndIf
        EndIf
        
        If bProcessed = #False  
          If (\nRelFilePos >= \nRelEndAt) Or (\bPlayEndSyncOccurred) Or ((\nRelFilePos > (\nRelEndAt - 250)) And (isAudPlaying(pAudPtr) = #False))
            bStopThisSub = #True
            nLinkedToAudPtr = \nLinkedToAudPtr
            If nLinkedToAudPtr >= 0
              For nAudLoopIndex = 0 To aAud(nLinkedToAudPtr)\nMaxLoopInfo
                If aAud(nLinkedToAudPtr)\aLoopInfo(nAudLoopIndex)\bLoopReleased = #False
                  bStopThisSub = #False
                  Break
                EndIf
              Next nAudLoopIndex
            EndIf
            If bStopThisSub
              ; debugMsg(sProcName, " aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt +
              ;                     ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred))
              ; samAddRequest(#SCS_SAM_STOP_SUB_FOR_STATUS_CHECK, nSubPtr, 0, #True, "F", 0, #False)
              ; added 1Sep2019 11.8.2ai to replace above SAM request by PostEvent to minimise the delay in stopping the sub-cue
              If aSub(nSubPtr)\bStopSubEventPosted = #False
                debugMsg(sProcName, " aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt +
                                    ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred))
                aSub(nSubPtr)\bStopSubEventPosted = #True
                gqPriorityPostEventWaiting = ElapsedMilliseconds()
                PostEvent(#SCS_Event_StopAndEndSub, #WMN, 0, 0, nSubPtr)
                debugMsg(sProcName, "PostEvent(#SCS_Event_StopAndEndSub, #WMN, 0, 0, " + getSubLabel(nSubPtr) + "), gqPriorityPostEventWaiting=" + traceTime(gqPriorityPostEventWaiting))
              EndIf
              ; end added 1Sep2019 11.8.2ai
            EndIf
            
          Else
            If \bIgnoreLevelEnvelope = #False
              ; debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(pAudPtr) + ", " + \nRelFilePos + "), bCalledFromLoadLevelPointRun=" + strB(bCalledFromLoadLevelPointRun))
              doLvlPtRun(pAudPtr, \nRelFilePos)
              If \nCurrFadeOutTime > 0
                If \nRelFilePos >= (\nRelEndAt - \nCurrFadeOutTime - \nFadeOutExtraTime)
                  \nCurrFadeOutTime = \nRelEndAt - \nRelFilePos - \nFadeOutExtraTime
                  debugMsg(sProcName, " calling fadeOutSub")
                  fadeOutSub(nSubPtr, #True)
                  ; debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
                  setCueStateAndUpdateGrid(nCuePtr)
                EndIf
              EndIf
            EndIf
            
          EndIf
        EndIf ; EndIf bProcessed = #False 
      EndIf
      ;}
    EndIf ; EndIf \nAudState = #SCS_CUE_PLAYING
    
    CompilerIf #c_lock_audio_to_ltc
      If bProcessed = #False  
        If gbUseSMS
          If nAudState = #SCS_CUE_READY
            If aCue(nCuePtr)\nActivationMethod = #SCS_ACMETH_LTC And aCue(nCuePtr)\nCueState = #SCS_CUE_READY
              ; Is pAudPtr the first enabled aud of this cue?
              If pAudPtr = getFirstEnabledAudTypeForCue(nCuePtr) ; And gbStoppingEverything = #False
                aCue(nCuePtr)\nFirstEnabledAudPtr = pAudPtr
                ; debugMsg(sProcName, "calling getAndWaitForTrackTime(" + getAudLabel(pAudPtr) + "), gbStoppingEverything=" + strB(gbStoppingEverything))
                getAndWaitForTrackTime(pAudPtr)
                If aAud(pAudPtr)\nPlayingPos > 0
                  PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, nCuePtr) ; Use PostEvent, not SAM, to provide faster action, and for the same reason call debugMsg() AFTER using PostEvent.
                  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPlayingPos=" + aAud(pAudPtr)\nPlayingPos + ", \nRelFilePos=" + aAud(pAudPtr)\nRelFilePos +
                                      ", called PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, " + getCueLabel(nCuePtr) + ")")
                  gbCallLoadDispPanels = #True
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      If gbUseSMS
        If aCue(nCuePtr)\nActivationMethod = #SCS_ACMETH_LTC
          If nAudState >= #SCS_CUE_FADING_IN And nAudState <= #SCS_CUE_FADING_OUT And nAudState <> #SCS_CUE_PAUSED And nAudState <> #SCS_CUE_HIBERNATING
            If pAudPtr = aCue(nCuePtr)\nFirstEnabledAudPtr
              If \nPlayingPos = \nPrevPlayingPos
                If aCue(nCuePtr)\bSMSTimeCodeLocked
                  unlockTimeCode(nCuePtr)
                  ; Call debugMsg() AFTER processing to unlockTimeCode() to provide faster action
                  debugMsg(sProcName, "called unlockTimeCode(" + getCueLabel(nCuePtr) + ")")
                  ProcedureReturn
                EndIf
              EndIf
              \nPrevPlayingPos = \nPlayingPos
            EndIf
          EndIf
        EndIf
      EndIf
    CompilerEndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SC_SubTypeI(pAudPtr)
  ;- Process Live Input
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, nSubPtr, nLabel
  Protected d
  Protected nFadeInPosition, fFadeInLevel.f
  
  With aAud(pAudPtr)
    nCuePtr = \nCueIndex
    nSubPtr = \nSubIndex
    If \nAudState = #SCS_CUE_FADING_IN
      gqTimeDiskActive = gqTimeNow
      ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
      calcCuePositionForAud(pAudPtr)
      getChannelAttributes(pAudPtr)
      ; debugMsg(sProcName, "" + \sAudLabel + ", \fCueVolNow[0]=" + traceLevel(\fCueVolNow[0]) + ", \fCuePanNow[0]=" + formatPan(\fCuePanNow[0]) + ", \fCueVolNow[1]=" + traceLevel(\fCueVolNow[1]) + ", \fCuePanNow[1]=" + formatPan(\fCuePanNow[1]))
      If \bTimeFadeInStartedSet
        nFadeInPosition = (gqTimeNow - \qTimeFadeInStarted) - (\nTotalTimeOnPause - \nPreFadeInTimeOnPause)
      Else
        ; shouldn't get here but did during a test - probably because control thread jumped in before \qTimeFadeInStarted had been set.
        ; have now added LockCueListMutex() to control thread and to playCue() to try to stop this happening
        nFadeInPosition = 0
      EndIf
      ; debugMsg3(sProcName, "nFadeInPosition=" + nFadeInPosition + ", gqTimeNow=" + gqTimeNow + ", \qTimeFadeInStarted=" + Str(\qTimeFadeInStarted) + ", \nTotalTimeOnPause=" + Str(\nTotalTimeOnPause) + ", \nPreFadeInTimeOnPause=" + Str(\nPreFadeInTimeOnPause) + ", \bFinalSlide=" + strB(\bFinalSlide))
      If gbUseSMS ; SM-S
        If nFadeInPosition < \nCurrFadeInTime
          For d = \nFirstDev To \nLastDev
            If \nOutputDevMapDevPtr[d] >= 0
              fFadeInLevel = calcBVLevel(\nFadeInType, \nCurrFadeInTime, nFadeInPosition, #SCS_MINVOLUME_SINGLE, \fBVLevel[d], \fTrimFactor[d])
              \fCueVolNow[d] = fFadeInLevel
              \fCueTotalVolNow[d] = \fCueVolNow[d]
              CompilerIf #cTraceCueTotalVolNow
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(pAudPtr)\fCueTotalVolNow[d]))
              CompilerEndIf
            EndIf
          Next d
        Else
          debugMsg(sProcName, "nFadeInPosition=" + nFadeInPosition + ", \nCurrFadeInTime=" + \nCurrFadeInTime)
          debugMsg(sProcName, "\sAudFinalSetGainCommandString=" + Trim(\sAudFinalSetGainCommandString))
          If \sAudFinalSetGainCommandString
            nLabel = 103
            sendSMSCommandSC("set " + Trim(\sAudFinalSetGainCommandString), #cTraceSetLevels)
          EndIf
          For d = \nFirstDev To \nLastDev
            If \nOutputDevMapDevPtr[d] >= 0
              \fCueVolNow[d] = \fBVLevel[d]
              \fCueTotalVolNow[d] = \fCueVolNow[d]
            EndIf
          Next d
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          \nAudState = #SCS_CUE_PLAYING
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
          setCueStateAndUpdateGrid(nCuePtr)
        EndIf
        
      EndIf
    EndIf
    
    If \nAudState = #SCS_CUE_PLAYING
      gqTimeDiskActive = gqTimeNow
      ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
      calcCuePositionForAud(pAudPtr)
      getChannelAttributes(pAudPtr)
      If isAudPlaying(pAudPtr) = #False
        debugMsg(sProcName, " aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos +
                            ", \nRelEndAt=" + \nRelEndAt + ", \bPlayEndSyncOccurred=" + strB(\bPlayEndSyncOccurred))
        debugMsg(sProcName, " calling stopSub(" + getSubLabel(nSubPtr) + ")")
        stopSub(nSubPtr, "I", #True, #False)
        debugMsg(sProcName, " calling endOfSub(" + getSubLabel(nSubPtr) + ", -1)")
        endOfSub(nSubPtr, -1)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeK(pSubPtr)
  ;- Process Lighting
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected bLightingSubComplete
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    bSubStartedInEditor = \bStartedInEditor
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gbGlobalPause=" + strB(gbGlobalPause))
    If (\nSubState = #SCS_CUE_PAUSED)
      \nSubTotalTimeOnPause = (gqTimeNow - \qSubTimePauseStarted) + \nSubPriorTimeOnPause
    ElseIf (\nSubState = #SCS_CUE_PLAYING) And (gbGlobalPause = #False)
      If gbInCalcCueStartValues
        If \nSubDuration > 0
          If \nSubPosition >= \nSubDuration
            \nSubPosition = \nSubDuration
            bLightingSubComplete = #True
          EndIf
        EndIf
      Else ; gbInCalcCueStartValues = #False
        \nSubPosition = (gqTimeNow - \qAdjTimeSubStarted) - \nSubTotalTimeOnPause
        ; debugMsg(sProcName, " aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition)
        If \nSubPosition < 0
          \nSubPosition = 0
        EndIf
        If \nSubDuration > 0
          If \nSubPosition >= \nSubDuration
; debugMsg(sProcName, " aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition + ", \nSubDuration=" + \nSubDuration)
            \nSubPosition = \nSubDuration
            bLightingSubComplete = #True
          EndIf
        EndIf
      EndIf
      
      If bLightingSubComplete
        Select aCue(nCuePtr)\nActivationMethod
          Case #SCS_ACMETH_HK_NOTE, #SCS_ACMETH_EXT_NOTE
            bLightingSubComplete = #False
        EndSelect
      EndIf
      
      If bLightingSubComplete
        SC_SubCompleteCommon(pSubPtr)
      EndIf
      
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeL(pSubPtr)
  ;- Process Level Change
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected nLabel
  Protected bCallSetPLLevels, bLCComplete
  Protected d, k
  Protected fLCBVLevel.f, fLCPan.f
  Protected nReqdTimerInterval
  Protected nTimePos
  Static nCount
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    bSubStartedInEditor = \bStartedInEditor
    
    Select \nLCAction
      Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
        If (\nSubState = #SCS_CUE_CHANGING_LEVEL) And (gbGlobalPause = #False Or grM2T\bProcessingApplyMoveToTime)
          If \bTimeSubStartedSet
            nTimePos = (gqTimeNow - aSub(pSubPtr)\qTimeSubStarted) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
          Else
            ; shouldn't get here
            nTimePos = (0) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
          EndIf
          If nTimePos < 0
            nTimePos = 0
          ElseIf nTimePos > \nLCActionTime
            nTimePos = \nLCActionTime
          EndIf
          \nLCPositionMax = nTimePos
          If nTimePos >= \nLCActionTime
            debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
            SC_SubCompleteCommon(pSubPtr, #False)
          EndIf
        EndIf
        ProcedureReturn
    EndSelect
    
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gbGlobalPause=" + strB(gbGlobalPause))
    If (\nSubState = #SCS_CUE_CHANGING_LEVEL) And (gbGlobalPause = #False Or grM2T\bProcessingApplyMoveToTime)
      If grM2T\bProcessingApplyMoveToTime
        nReqdTimerInterval = 0
      Else
        nReqdTimerInterval = gnTimerInterval
      EndIf
      If \bLCTargetIsA  ; level change target is A
        bCallSetPLLevels = #False
        \nLCPositionMax = 0
        d = 0
        If aSub(pSubPtr)\bTimeSubStartedSet
          \nLCPosition[d] = (gqTimeNow - aSub(pSubPtr)\qTimeSubStarted) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
        Else
          ; shouldn't get here
          \nLCPosition[d] = (0) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
        EndIf
        If \nLCPosition[d] < 0
          \nLCPosition[d] = 0
        ElseIf \nLCPosition[d] > \nLCTime[d]
          \nLCPosition[d] = \nLCTime[d]
        EndIf
        If \nLCPosition[d] > \nLCPositionMax
          \nLCPositionMax = \nLCPosition[d]
        EndIf
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCTime[" + d + "]=" + \nLCTime[d] + ", \nLCPosition[" + d + "]=" + \nLCPosition[d] + ", \nLCPositionMax=" + \nLCPositionMax)
        
        bCallSetPLLevels = #True
        If \nLCPosition[d] >= \nLCTime[d]
          fLCBVLevel = \fLCTargetBVLevel[d]
          fLCPan = \fLCReqdPan[d]
        Else
          fLCBVLevel = calcBVLevel(\nLCType, \nLCTime[d], \nLCPosition[d], \fLCBVLevelWhenStarted[d], \fLCTargetBVLevel[d], aSub(\nLCSubPtr)\fSubTrimFactor[d])
          fLCPan = aSub(\nLCSubPtr)\fSubPanNow[d]
        EndIf
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCTime[" + d + "]=" + \nLCTime[d] + ", \nLCPosition[" + d + "]=" + \nLCPosition[d] + ", \nLCPositionMax=" + \nLCPositionMax + ", fLCBVLevel=" + traceLevel(fLCBVLevel))
        
        If fLCBVLevel <= grLevels\fMinBVLevel
          fLCBVLevel = #SCS_MINVOLUME_SINGLE
        ElseIf fLCBVLevel > grLevels\fMaxBVLevel
          fLCBVLevel = grLevels\fMaxBVLevel
        EndIf
        
        If fLCPan < #SCS_MINPAN_SINGLE
          fLCPan = #SCS_MINPAN_SINGLE
        ElseIf fLCPan > #SCS_MAXPAN_SINGLE
          fLCPan = #SCS_MAXPAN_SINGLE
        EndIf
        
        aSub(\nLCSubPtr)\fSubBVLevelNow[d] = fLCBVLevel
        aSub(\nLCSubPtr)\fSubPanNow[d] = fLCPan
        ; debugMsg(sProcName, "aSub(" + \nLCSubPtr + ")\fSubBVLevelNow[" + d + "]=" + traceLevel(aSub(\nLCSubPtr)\fSubBVLevelNow[d]) + ", aSub(" + \nLCSubPtr + ")\fSubPanNow[" + d + "]=" + tracePan(aSub(\nLCSubPtr)\fSubPanNow[d]))
        
        k = aSub(\nLCSubPtr)\nFirstPlayIndex
        While k >= 0
          aAud(k)\fAudPlayBVLevel[d] = fLCBVLevel * aAud(k)\fPLRelLevel / 100.0
          aAud(k)\fAudPlayPan[d] = fLCPan
          If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
            aAud(k)\fCueVolNow[d] = aAud(k)\fAudPlayBVLevel[d]
            aAud(k)\fCueTotalVolNow[d] = aAud(k)\fAudPlayBVLevel[d]
            CompilerIf #cTraceCueTotalVolNow
              debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fAudPlayBVLevel[" + d + "]=" + traceLevel(aAud(k)\fAudPlayBVLevel[d]) + ", \fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(k)\fCueTotalVolNow[d]))
            CompilerEndIf
          EndIf
          k = aAud(k)\nNextPlayIndex
        Wend
        
        If bCallSetPLLevels
          k = aSub(\nLCSubPtr)\nFirstPlayIndex
          While k >= 0
            If aAud(k)\nAudState <= #SCS_CUE_PL_READY
              ; debugMsg(sProcName, "calling setPLLevels(" + getAudLabel(k) + ")")
              setPLLevels(k)
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
        
        bLCComplete = #False
        If aSub(\nLCSubPtr)\nSubState >= #SCS_CUE_STANDBY
          bLCComplete = #True
        Else
          bLCComplete = #True
          d = 0
          If \nLCPosition[d] < \nLCTime[d]
            bLCComplete = #False
          EndIf
        EndIf
        ; debugMsg(sProcName, "bLCComplete=" + strB(bLCComplete) + ", aSub(" + getSubLabel(\nLCSubPtr) + ")\nSubState=" + decodeCueState(aSub(\nLCSubPtr)\nSubState) + ", \nLCPosition[0]=" + Str(\nLCPosition[0]) + ", \nLCTime[0]=" + Str(\nLCTime[0]))
        
        If bLCComplete
          SC_SubCompleteCommon(pSubPtr, #False)
        EndIf
        
      ElseIf \bLCTargetIsF  ; level change target is F
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bSubTypeL=" + strB(\bSubTypeL) + ", aAud(" + getAudLabel(\nLCAudPtr) + ")\nAudState=" + decodeCueState(aAud(\nLCAudPtr)\nAudState))
        If aAud(\nLCAudPtr)\nAudState < #SCS_CUE_FADING_OUT
          If (aAud(\nLCAudPtr)\bTimeForNextFadeCheckSet = #False) Or ((aAud(\nLCAudPtr)\qTimeForNextFadeCheck - gqTimeNow) <= 0)
            \nLCPositionMax = 0
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If \bLCInclude[d]
                aAud(\nLCAudPtr)\aLvlPtRun[d]\bSuspendItemProc = #True
                If aAud(\nLCAudPtr)\sLogicalDev[d]
                  If aSub(pSubPtr)\bTimeSubStartedSet
                    \nLCPosition[d] = (gqTimeNow - aSub(pSubPtr)\qTimeSubStarted) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
                  Else
                    ; shouldn't get here
                    \nLCPosition[d] = (0) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
                  EndIf
                  ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCPosition[" + d + "]=" + \nLCPosition[d] + ", gqTimeNow=" + traceTime(gqTimeNow) + ", aSub(" + getSubLabel(pSubPtr) + ")\qTimeSubStarted=" + traceTime(aSub(pSubPtr)\qTimeSubStarted) +
                  ;                     ", \nTotalTimeOnGlobalPause=" + aSub(pSubPtr)\nTotalTimeOnGlobalPause)
                  If \nLCPosition[d] < 0
                    \nLCPosition[d] = 0
                  ElseIf \nLCPosition[d] > \nLCTime[d]
                    \nLCPosition[d] = \nLCTime[d]
                  EndIf
                  If \nLCPosition[d] > \nLCPositionMax
                    \nLCPositionMax = \nLCPosition[d]
                  EndIf
                  ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCTime[" + d + "]=" + \nLCTime[d] + ", \nLCPosition[" + d + "]=" + \nLCPosition[d] + ", \nLCPositionMax=" + \nLCPositionMax)
                  
                  If aAud(\nLCAudPtr)\nRequestedBySubPtr = pSubPtr Or \bStartedInEditor ; nRequestedBySubPtr test added 8Oct2024 11.10.6ah; bStartedInEditor test added 10Dec2024 11.10.6bu
                    ; debugMsg(sProcName, "\nLCType=" + decodeFadeType(\nLCType))
                    If (\nLCType = #SCS_FADE_STD) Or (\nLCType = #SCS_FADE_LOG) Or (aAud(\nLCAudPtr)\bUseMatrix[d])
                      If \nLCPosition[d] >= \nLCTime[d]
                        fLCBVLevel = \fLCTargetBVLevel[d]
                        fLCPan = \fLCReqdPan[d]
                        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCPosition[" + d + "]=" + \nLCPosition[d] + ", \nLCTime[" + d + "]=" + traceTime(\nLCTime[d]) + ", fLCBVLevel=" + traceLevel(fLCBVLevel))
                      Else
                        fLCBVLevel = calcBVLevel(\nLCType, \nLCTime[d], \nLCPosition[d], \fLCBVLevelWhenStarted[d], \fLCTargetBVLevel[d], aAud(\nLCAudPtr)\fTrimFactor[d])
                        fLCPan = calcPan(\nLCTime[d], \nLCPosition[d], \fLCPanWhenStarted[d], \fLCReqdPan[d])
                        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCPosition[" + d + "]=" + \nLCPosition[d] + ", \nLCTime[" + d + "]=" + traceTime(\nLCTime[d]) +
                        ;                     ", \fLCBVLevelWhenStarted[" + d + "]=" + traceLevel(\fLCBVLevelWhenStarted[d]) + ", \fLCTargetBVLevel[" + d + "]=" + traceLevel(\fLCTargetBVLevel[d]) +
                        ;                     ", aAud(" + getAudLabel(\nLCAudPtr) + ")\fTrimFactor[d]=" + formatTrim(aAud(\nLCAudPtr)\fTrimFactor[d]) + ", fLCBVLevel=" + traceLevel(fLCBVLevel))
                      EndIf
                      
                      If fLCBVLevel <= grLevels\fMinBVLevel
                        fLCBVLevel = #SCS_MINVOLUME_SINGLE
                      ElseIf fLCBVLevel > grLevels\fMaxBVLevel
                        fLCBVLevel = grLevels\fMaxBVLevel
                      EndIf
                      
                      If fLCPan < #SCS_MINPAN_SINGLE
                        fLCPan = #SCS_MINPAN_SINGLE
                      ElseIf fLCPan > #SCS_MAXPAN_SINGLE
                        fLCPan = #SCS_MAXPAN_SINGLE
                      EndIf
                      
                      If (aAud(\nLCAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(\nLCAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
                        ; debugMsg(sProcName, "aAud(" + getAudLabel(\nLCAudPtr) + ")\bFadeInProgress=" + strB(aAud(\nLCAudPtr)\bFadeInProgress) + ", \qTimeForNextFadeCheck=" + aAud(\nLCAudPtr)\qTimeForNextFadeCheck + ", gqTimeNow=" + gqTimeNow)
                        If aAud(\nLCAudPtr)\bFadeInProgress
                          If (gqTimeNow - aAud(\nLCAudPtr)\qTimeForNextFadeCheck) >= 0
                            CompilerIf #cTraceSetLevels
                              debugMsg(sProcName, "calling applyAudFade(" + getAudLabel(\nLCAudPtr) + ")")
                            CompilerEndIf
                            applyAudFade(\nLCAudPtr)
                          EndIf
                        Else
                          If aAud(\nLCAudPtr)\bCueVolManual[d]
                            fLCBVLevel = aAud(\nLCAudPtr)\fCueTotalVolNow[d]
                          EndIf
                          If gbUseSMS ; SM-S
                            If (fLCBVLevel <> aAud(\nLCAudPtr)\fCueTotalVolNow[d]) Or (fLCPan <> aAud(\nLCAudPtr)\fCuePanNow[d])
                              CompilerIf #cTraceSetLevels
                                debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(\nLCAudPtr) + ", " + d + ", " + traceLevel(fLCBVLevel) +
                                                    ", " + formatPan(fLCPan) + ", -1, " + nReqdTimerInterval + ")")
                              CompilerEndIf
                              setLevelsAny(\nLCAudPtr, d, fLCBVLevel, fLCPan, -1, nReqdTimerInterval)
                            EndIf
                          Else
                            If fLCBVLevel <> aAud(\nLCAudPtr)\fCueTotalVolNow[d]
                              CompilerIf #cTraceSetLevels
                                debugMsg(sProcName, " calling slideChannelAttributes for d=" + d + ", level " + traceLevel(fLCBVLevel) +
                                                    ", aAud(" + getAudLabel(\nLCAudPtr) + ")\nAudState=" + decodeCueState(aAud(\nLCAudPtr)\nAudState))
                              CompilerEndIf
                              slideChannelAttributes(\nLCAudPtr, d, fLCBVLevel, #SCS_NOPANCHANGE_SINGLE, nReqdTimerInterval)
                            Else
                              CompilerIf #cTraceCueTotalVolNow
                                debugMsg(sProcName, "aAud(" + getAudLabel(\nLCAudPtr) + ")\fAudPlayBVLevel[" + d + "]=" + traceLevel(aAud(\nLCAudPtr)\fAudPlayBVLevel[d]) +
                                                    ", \fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(\nLCAudPtr)\fCueTotalVolNow[d]) + ", fcLevel " + traceLevel(fLCBVLevel))
                              CompilerEndIf
                            EndIf
                            ;debugMsg(sProcName, "aAud(" + \nLCAudPtr + ")\fCuePanNow(" + d + ")=" + aAud(\nLCAudPtr)\fCuePanNow[d] + ", fLCPan=" + fLCPan)
                            If fLCPan <> aAud(\nLCAudPtr)\fCuePanNow[d]
                              If aAud(\nLCAudPtr)\bUseMatrix[d] = #False
                                ;debugMsg(sProcName, " calling slideChannelAttributes for pan " + formatLevel(fLCPan))
                                slideChannelAttributes(\nLCAudPtr, d, #SCS_NOVOLCHANGE_SINGLE, fLCPan, nReqdTimerInterval)
                              Else
                                CompilerIf #cTraceSetLevels
                                  debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(\nLCAudPtr) + ", " + d + ", #SCS_NOVOLCHANGE_SINGLE, " + formatPan(fLCPan) + ")")
                                CompilerEndIf
                                setLevelsAny(\nLCAudPtr, d, #SCS_NOVOLCHANGE_SINGLE, fLCPan)
                              EndIf
                            EndIf
                          EndIf ; EndIf gbUseSMS / Else
                        EndIf ; EndIf aAud(\nLCAudPtr)\bFadeInProgress / Else
                      EndIf ; EndIf (aAud(\nLCAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(\nLCAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
                    EndIf ; EndIf (\nLCType = #SCS_FADE_STD) Or (\nLCType = #SCS_FADE_LOG) Or (aAud(\nLCAudPtr)\bUseMatrix[d])
                  EndIf ; EndIf aAud(\nLCAudPtr)\nRequestedBySubPtr = pSubPtr ; Test added 8Oct2024 11.10.6ah
                EndIf ; EndIf aAud(\nLCAudPtr)\sLogicalDev[d]
              EndIf ; EndIf \bLCInclude[d]
            Next d
            
            Delay(nReqdTimerInterval+5)
            ; get level and pan of target cue
            getChannelAttributes(\nLCAudPtr)
            
          EndIf ; EndIf aAud(\nLCAudPtr)\qTimeForNextFadeCheck <= gqTimeNow
        EndIf ; EndIf aAud(\nLCAudPtr)\nAudState < #SCS_CUE_FADING_OUT
        
        bLCComplete = #False
        If aSub(\nLCSubPtr)\nSubState >= #SCS_CUE_STANDBY
          bLCComplete = #True
          debugMsg(sProcName, "aSub(" + getSubLabel(\nLCSubPtr) + ")\nSubState=" + decodeCueState(aSub(\nLCSubPtr)\nSubState) + ", bLCComplete=" + strB(bLCComplete))
        Else
          bLCComplete = #True
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \bLCInclude[d]
              If \nLCPosition[d] < \nLCTime[d]
                bLCComplete = #False
                Break
              EndIf
            EndIf
          Next d
        EndIf
        If (bLCComplete) And (\nLCAudPtr >= 0)
          debugMsg(sProcName, "bLCComplete=" + strB(bLCComplete) +
                              ", aAud(" + getAudLabel(\nLCAudPtr) + ")\bInLoopXFade=" + strB(aAud(\nLCAudPtr)\bInLoopXFade) + ", \fBVLevelAtLoopEnd[0]=" + traceLevel(aAud(\nLCAudPtr)\fBVLevelAtLoopEnd[0]) +
                              ", \qTimePassStarted=" + aAud(\nLCAudPtr)\qTimePassStarted + ", gqTimeNow=" + gqTimeNow + ", ElapsedMilliseconds()=" + ElapsedMilliseconds())
          If WCN\nPlayingSubTypeF = \nLCSubPtr
            WCN\bRefreshAudioChannelFaders = #True
            ; debugMsg(sProcName, "WCN\bRefreshAudioChannelFaders=" + strB(WCN\bRefreshAudioChannelFaders))
          EndIf
        EndIf
        
      ElseIf \bLCTargetIsI  ; level change target is I
        ; debugMsg(sProcName, "aAud(" + getAudLabel(\nLCAudPtr) + ")\nAudState=" + decodeCueState(aAud(\nLCAudPtr)\nAudState))
        If aAud(\nLCAudPtr)\nAudState < #SCS_CUE_FADING_OUT
          \nLCPositionMax = 0
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \bLCInclude[d]
              If \bTimeSubStartedSet
                \nLCPosition[d] = (gqTimeNow - \qTimeSubStarted) - \nTotalTimeOnGlobalPause
              Else
                ; shouldn't get here
                \nLCPosition[d] = (0) - \nTotalTimeOnGlobalPause
              EndIf
              If \nLCPosition[d] < 0
                \nLCPosition[d] = 0
              ElseIf \nLCPosition[d] > \nLCTime[d]
                \nLCPosition[d] = \nLCTime[d]
              EndIf
              If \nLCPosition[d] > \nLCPositionMax
                \nLCPositionMax = \nLCPosition[d]
              EndIf
            EndIf
          Next d
        EndIf
        
        bLCComplete = #False
        If aSub(\nLCSubPtr)\nSubState >= #SCS_CUE_STANDBY
          bLCComplete = #True
        Else
          bLCComplete = #True
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            ; debugMsg(sProcName, "aAud(" + getAudLabel(\nLCAudPtr) + ")\sLogicalDev[" + d + "]=" + aAud(\nLCAudPtr)\sLogicalDev[d] + ", \nLCPosition[d]=" + \nLCPosition[d] + ", \nLCTime[d]=" + traceTime(\nLCTime[d]))
            If \bLCInclude[d] ; Len(aAud(\nLCAudPtr)\sLogicalDev[d]) > 0
              If \nLCPosition[d] < \nLCTime[d]
                fLCBVLevel = calcBVLevel(\nLCType, \nLCTime[d], \nLCPosition[d], \fLCBVLevelWhenStarted[d], \fLCTargetBVLevel[d], aAud(\nLCAudPtr)\fTrimFactor[d])
                fLCPan = calcPan(\nLCTime[d], \nLCPosition[d], \fLCPanWhenStarted[d], \fLCReqdPan[d])
                bLCComplete = #False
              Else
                fLCBVLevel = \fLCTargetBVLevel[d]
                fLCPan = \fLCReqdPan[d]
              EndIf
              If fLCBVLevel <= grLevels\fMinBVLevel
                fLCBVLevel = #SCS_MINVOLUME_SINGLE
              ElseIf fLCBVLevel > grLevels\fMaxBVLevel
                fLCBVLevel = grLevels\fMaxBVLevel
              EndIf
              If fLCPan < #SCS_MINPAN_SINGLE
                fLCPan = #SCS_MINPAN_SINGLE
              ElseIf fLCPan > #SCS_MAXPAN_SINGLE
                fLCPan = #SCS_MAXPAN_SINGLE
              EndIf
              aAud(\nLCAudPtr)\fCueVolNow[d] = fLCBVLevel
              aAud(\nLCAudPtr)\fCueTotalVolNow[d] = aAud(\nLCAudPtr)\fCueVolNow[d]
              CompilerIf #cTraceCueTotalVolNow
                debugMsg(sProcName, "aAud(" + getAudLabel(\nLCAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(\nLCAudPtr)\fCueTotalVolNow[d]))
              CompilerEndIf
              aAud(\nLCAudPtr)\fCuePanNow[d] = fLCPan
            EndIf
          Next d
        EndIf
        ; debugMsg(sProcName, "bLCComplete=" + strB(bLCComplete))
        If bLCComplete
          debugMsg(sProcName, "\sSubFinalSetGainCommandString=" + Trim(\sSubFinalSetGainCommandString))
          If \sSubFinalSetGainCommandString
            nLabel = 101
            sendSMSCommandSC("set " + Trim(\sSubFinalSetGainCommandString), #cTraceSetLevels)
          EndIf
        EndIf
        
      ElseIf \bLCTargetIsP   ; level change target is P
        bCallSetPLLevels = #False
        \nLCPositionMax = 0
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \bLCInclude[d]
            If Len(aSub(\nLCSubPtr)\sPLLogicalDev[d]) > 0
              If aSub(pSubPtr)\bTimeSubStartedSet
                \nLCPosition[d] = (gqTimeNow - aSub(pSubPtr)\qTimeSubStarted) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
              Else
                ; shouldn't get here
                \nLCPosition[d] = (0) - aSub(pSubPtr)\nTotalTimeOnGlobalPause
              EndIf
              If \nLCPosition[d] < 0
                \nLCPosition[d] = 0
              ElseIf \nLCPosition[d] > \nLCTime[d]
                \nLCPosition[d] = \nLCTime[d]
              EndIf
              If \nLCPosition[d] > \nLCPositionMax
                \nLCPositionMax = \nLCPosition[d]
              EndIf
              ; debugMsg(sProcName, "\nLCPosition(" + d + ")=" + \nLCPosition[d] + ", \nLCPositionMax=" + \nLCPositionMax)
              ; debugMsg(sProcName, "aSub(" + getSubLabel(\nLCSubPtr) + ")\fSubBVLevelNow[" + d + "]=" + traceLevel(aSub(\nLCSubPtr)\fSubBVLevelNow[d])) ; + ", aSub(" + \nLCSubPtr + ")\fSubPanNow[" + d + "]=" + tracePan(aSub(\nLCSubPtr)\fSubPanNow[d]))
              bCallSetPLLevels = #True
              If \nLCPosition[d] >= \nLCTime[d]
                fLCBVLevel = \fLCTargetBVLevel[d]
                fLCPan = \fLCReqdPan[d]
              Else
                fLCBVLevel = calcBVLevel(\nLCType, \nLCTime[d], \nLCPosition[d], \fLCBVLevelWhenStarted[d], \fLCTargetBVLevel[d], \fSubTrimFactor[d])
                ; debugMsg(sProcName, "calcBVLevel(" + decodeLCCueType(\nLCType) + ", "+ \nLCTime[d]+ ", " + \nLCPosition[d] + ", " + \fLCBVLevelWhenStarted[d] + ", " + \fLCTargetBVLevel[d] + ", " + \fSubTrimFactor[d] + ") returned fLCBVLevel=" + traceLevel(fLCBVLevel))
                fLCPan = calcPan(\nLCTime[d], \nLCPosition[d], \fLCPanWhenStarted[d], \fLCReqdPan[d])
              EndIf
              ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLCTime[" + d + "]=" + \nLCTime[d] + ", \nLCPosition[" + d + "]=" + \nLCPosition[d] + ", \nLCPositionMax=" + \nLCPositionMax + ", fLCBVLevel=" + traceLevel(fLCBVLevel))
              If fLCBVLevel <= grLevels\fMinBVLevel
                fLCBVLevel = #SCS_MINVOLUME_SINGLE
              ElseIf fLCBVLevel > grLevels\fMaxBVLevel
                fLCBVLevel = grLevels\fMaxBVLevel
              EndIf
              
              If fLCPan < #SCS_MINPAN_SINGLE
                fLCPan = #SCS_MINPAN_SINGLE
              ElseIf fLCPan > #SCS_MAXPAN_SINGLE
                fLCPan = #SCS_MAXPAN_SINGLE
              EndIf
              
              aSub(\nLCSubPtr)\fSubBVLevelNow[d] = fLCBVLevel
              aSub(\nLCSubPtr)\fSubPanNow[d] = fLCPan
              ; debugMsg(sProcName, "aSub(" + getSubLabel(\nLCSubPtr) + ")\fSubBVLevelNow[" + d + "]=" + traceLevel(aSub(\nLCSubPtr)\fSubBVLevelNow[d])) ; + ", aSub(" + \nLCSubPtr + ")\fSubPanNow[" + d + "]=" + tracePan(aSub(\nLCSubPtr)\fSubPanNow[d]))
              
              k = aSub(\nLCSubPtr)\nFirstPlayIndex
              While k >= 0
                aAud(k)\fAudPlayBVLevel[d] = fLCBVLevel * aAud(k)\fPLRelLevel / 100.0
                aAud(k)\fAudPlayPan[d] = fLCPan
                If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
                  aAud(k)\fCueVolNow[d] = aAud(k)\fAudPlayBVLevel[d]
                  aAud(k)\fCueTotalVolNow[d] = aAud(k)\fAudPlayBVLevel[d]
                  CompilerIf #cTraceCueTotalVolNow
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(k)\fCueTotalVolNow[d]))
                  CompilerEndIf
                EndIf
                k = aAud(k)\nNextPlayIndex
              Wend
              
            EndIf
          EndIf
        Next d
        
        If bCallSetPLLevels
          k = aSub(\nLCSubPtr)\nFirstPlayIndex
          While k >= 0
            If aAud(k)\nAudState <= #SCS_CUE_PL_READY
              ; debugMsg(sProcName, "calling setPLLevels(" + getAudLabel(k) + ")")
              setPLLevels(k)
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
        
        bLCComplete = #False
        If aSub(\nLCSubPtr)\nSubState >= #SCS_CUE_STANDBY
          bLCComplete = #True
        Else
          bLCComplete = #True
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \bLCInclude[d]
              If \nLCPosition[d] < \nLCTime[d]
                bLCComplete = #False
                ; debugMsg(sProcName, " break")
                Break
              Else
                aSub(\nLCSubPtr)\fSubBVLevelNow[d] = \fLCTargetBVLevel[d]
                aSub(\nLCSubPtr)\fSubPanNow[d] = \fLCReqdPan[d]
                ; debugMsg(sProcName, "aSub(" + getSubLabel(\nLCSubPtr) + ")\fSubBVLevelNow[" + d + "]=" + traceLevel(aSub(\nLCSubPtr)\fSubBVLevelNow[d]) + ", aSub(" + \nLCSubPtr + ")\fSubPanNow[" + d + "]=" + tracePan(aSub(\nLCSubPtr)\fSubPanNow[d]))
              EndIf
            EndIf
          Next d
        EndIf
      EndIf
      
      If bLCComplete
        SC_SubCompleteCommon(pSubPtr, #False)
      EndIf
      
    EndIf
    
  EndWith
  
EndProcedure

Procedure SC_SubTypeM(pSubPtr)
  ;- Process Ctrl Send
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected bCtrlSendComplete
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    bSubStartedInEditor = \bStartedInEditor
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gbGlobalPause=" + strB(gbGlobalPause))
    If (\nSubState = #SCS_CUE_PAUSED)
      \nSubTotalTimeOnPause = (gqTimeNow - \qSubTimePauseStarted) + \nSubPriorTimeOnPause
      ; debugMsg(sProcName, " aSub(" + getSubLabel(pSubPtr) + ")\qSubTimePauseStarted=" + \qSubTimePauseStarted + ", \nSubPriorTimeOnPause=" + \nSubPriorTimeOnPause)
    ElseIf (\nSubState = #SCS_CUE_PLAYING) And (gbGlobalPause = #False)
      \nSubPosition = (gqTimeNow - \qAdjTimeSubStarted) - \nSubTotalTimeOnPause
      ; debugMsg(sProcName, " aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition + ", \nSubDuration=" + \nSubDuration +
      ;                     ", \qAdjTimeSubStarted=" + traceTime(\qAdjTimeSubStarted) + ", \nSubTotalTimeOnPause=" + \nSubTotalTimeOnPause)
      If \nSubPosition < 0
        \nSubPosition = 0
      EndIf
      If \nSubDuration > 0
        If \nSubPosition >= \nSubDuration
          \nSubPosition = \nSubDuration
          bCtrlSendComplete = #True
        EndIf
      EndIf
      
      If bCtrlSendComplete
        SC_SubCompleteCommon(pSubPtr)
      EndIf
      
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeP(pAudPtr, bReRandomizePlaylist, nMyNextPlayIndex)
  ;- Process Playlist
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, nSubPtr, bSubStartedInEditor, nLabel
  Protected d
  Protected nMySubState, nMyPrevPlayIndex, nPrevAudState, nPos, bChannelPlaying, sMySetGainCommandString.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    nCuePtr = \nCueIndex
    nSubPtr = \nSubIndex
    nMySubState = aSub(nSubPtr)\nSubState
    bSubStartedInEditor = aSub(nSubPtr)\bStartedInEditor
    If \nPrevPlayIndex >= 0
      nMyPrevPlayIndex = \nPrevPlayIndex
    Else
      nMyPrevPlayIndex = aSub(nSubPtr)\nLastPlayIndex
    EndIf
    nPrevAudState = aAud(nMyPrevPlayIndex)\nAudState
    
    ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", nPrevAudState=" + decodeCueState(nPrevAudState) + ", aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState))
    If (\nAudState = #SCS_CUE_PL_READY) And (gbStoppingEverything = #False) And ((bSubStartedInEditor = #False) Or (gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE))
      ; nb cue_pl_ready only set for 2nd and subsequent aud's, or for the 1st aud if continuous and on 2nd or later pass
      If (bSubStartedInEditor = #False) And (aSub(nSubPtr)\nSubState <= #SCS_CUE_READY)
        ; do nothing
      ElseIf (nPrevAudState = #SCS_CUE_TRANS_FADING_OUT) Or (nPrevAudState = #SCS_CUE_TRANS_MIXING_OUT) Or (nPrevAudState = #SCS_CUE_COMPLETED)
        If aSub(nSubPtr)\bPLTerminating
          debugMsg(sProcName, " calling stopAud(" + \sAudLabel + ")")
          stopAud(pAudPtr)
          
        ElseIf aAud(nMyPrevPlayIndex)\nPLTransType = #SCS_TRANS_WAIT
          \nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START
          \qPLTimeTransStarted = gqTimeNow
          debugMsg(sProcName, "calling rewindAud( " + aAud(pAudPtr)\sAudLabel + ")")
          rewindAud(pAudPtr)
          aSub(nSubPtr)\nCurrPlayIndex = pAudPtr
          debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(aSub(nSubPtr)\nCurrPlayIndex))
          \nPLCountDownTimeLeft = aAud(nMyPrevPlayIndex)\nPLTransTime
          debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
          setCueStateAndUpdateGrid(nCuePtr)
          
        Else
          \qPLTimeTransStarted = gqTimeNow
          debugMsg(sProcName, "calling playAud(" + getAudLabel(pAudPtr) + "), gnLabel=" + gnLabel + ", aSub(" + getSubLabel(nSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(aSub(nSubPtr)\nCurrPlayIndex))
          playAud(pAudPtr, #True, #False, -1, #True)
          \qTimeAudStarted = gqTimeNow
          ; \nTimeAudEnded = 0
          \bTimeAudEndedSet = #False
          \qTimeAudRestarted = gqTimeNow
          \nTotalTimeOnPause = 0
          \nPreFadeInTimeOnPause = 0
          \nPreFadeOutTimeOnPause = 0
          calcPLUnplayedFilesTime(nSubPtr)
          If (gbEditing) And (nEditSubPtr = nSubPtr)
            samAddRequest(#SCS_SAM_SET_CURR_PL_ROW, WQP_getRowForAud(pAudPtr))
          EndIf
          
        EndIf
        
      EndIf
    EndIf
    
    If (\nAudState = #SCS_CUE_PL_COUNTDOWN_TO_START) And (gbGlobalPause = #False)
      nMyPrevPlayIndex = \nPrevPlayIndex
      ; If (nMyPrevPlayIndex = -1) And (aSub(nSubPtr)\bPLRepeat)
      If (nMyPrevPlayIndex = -1) And (getPLRepeatActive(nSubPtr))
        nMyPrevPlayIndex = aSub(nSubPtr)\nLastPlayIndex
      EndIf
      \nPLCountDownTimeLeft = aAud(nMyPrevPlayIndex)\nPLTransTime - (gqTimeNow - \qPLTimeTransStarted)
      If \nPLCountDownTimeLeft <= 0
        \nPLCountDownTimeLeft = 0
        debugMsg(sProcName, "calling playAud(" + pAudPtr + ")")
        playAud(pAudPtr, #False, #False, -1, #True)
        \qTimeAudStarted = gqTimeNow
        ; \nTimeAudEnded = 0
        \bTimeAudEndedSet = #False
        \qTimeAudRestarted = gqTimeNow
        \nTotalTimeOnPause = 0
        \nPreFadeInTimeOnPause = 0
        \nPreFadeOutTimeOnPause = 0
        calcPLUnplayedFilesTime(nSubPtr)
        If (gbEditing) And (nEditSubPtr = nSubPtr)
          samAddRequest(#SCS_SAM_SET_CURR_PL_ROW, WQP_getRowForAud(pAudPtr))
        EndIf
      EndIf
      
    ElseIf ((\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)) Or (\nAudState = #SCS_CUE_COMPLETED)
      If nPrevAudState = #SCS_CUE_COMPLETED
        ; If aSub(nSubPtr)\bPLRepeat
        If getPLRepeatActive(nSubPtr)
          If (aSub(nSubPtr)\bPLTerminating = #False)
            setPlaylistTrackReadyState(nMyPrevPlayIndex)
            debugMsg(sProcName, "calling rewindAud(" + aAud(nMyPrevPlayIndex)\sAudLabel + ")")
            rewindAud(nMyPrevPlayIndex)
          EndIf
        EndIf
      EndIf
      
    EndIf
    
    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
      gqTimeDiskActive = gqTimeNow
      calcCuePositionForAud(pAudPtr)
      If bSubStartedInEditor
        If gnPLFirstAndLastTime > 0
          If (\nCuePos > gnPLFirstAndLastTime) And (\bPLSkipDone = #False)
            \bPLSkipDone = #True
            nPos = \nCueDuration - gnPLFirstAndLastTime
            If nPos > \nCuePos
              debugMsg(sProcName, "nPos=" + nPos + ", \nCuePos=" + \nCuePos + ", calling setAudChannelPositions(" + getAudLabel(pAudPtr) + ", " + ttszt(nPos + \nAbsStartAt) + ")")
              setAudChannelPositions(pAudPtr, (nPos + \nAbsStartAt))
              \qTimeAudStarted = gqTimeNow - nPos
              ; \nTimeAudEnded = 0
              \bTimeAudEndedSet = #False
              \qTimeAudRestarted = \qTimeAudStarted
              \nTotalTimeOnPause = 0
              calcCuePositionForAud(pAudPtr)
            EndIf
          EndIf
        EndIf
      EndIf
      If (\nPLTransType = #SCS_TRANS_MIX) And (\nAudState <> #SCS_CUE_TRANS_MIXING_OUT) And (\nAudState <> #SCS_CUE_FADING_OUT) And (\nAudState <> #SCS_CUE_HIBERNATING)
        If nMyNextPlayIndex >= 0
          If \nCuePos >= (\nCueDuration - \nPLTransTime)
            \nAudState = #SCS_CUE_TRANS_MIXING_OUT
            debugMsg(sProcName, "aAud(" + \sAudLabel + ")\nCuePos=" + \nCuePos + ", \nCueDuration=" + \nCueDuration + ", \nPLTransTime=" + \nPLTransTime + ", \nAudState=" + decodeCueState(\nAudState))
            debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
            setCueStateAndUpdateGrid(nCuePtr)
          EndIf
        EndIf
      EndIf
      
      If gbUseBASS  ; BASS
        setPLLevelsIfReqd(pAudPtr)
      Else ; SM-S
        ; not necessary to set PL Levels as a fadetime has already been nominated
      EndIf
      
    ElseIf (\nAudState = #SCS_CUE_PL_READY) And ((nMySubState >= #SCS_CUE_FADING_IN) And (nMySubState <= #SCS_CUE_FADING_OUT))
      If gbUseBASS  ; BASS
        setPLLevelsIfReqd(pAudPtr)
      Else ; SM-S
        ; not necessary to set PL Levels as a fadetime has already been nominated
      EndIf
    EndIf
    
    If \nAudState = #SCS_CUE_TRANS_FADING_IN Or \nAudState = #SCS_CUE_FADING_IN
      getChannelAttributes(pAudPtr)
      If \nAudState = #SCS_CUE_TRANS_FADING_IN
        If \nCuePos >= \nCurrFadeInTime
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          \nAudState = #SCS_CUE_PLAYING
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
          setCueStateAndUpdateGrid(nCuePtr)
        EndIf
      Else ; #SCS_CUE_FADING_IN
        If aSub(nSubPtr)\bPLFadingIn
          If (\bTimeFadeInStartedSet) And ((gqTimeNow - \qTimeFadeInStarted) >= aSub(nSubPtr)\nPLCurrFadeInTime)
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
            \nAudState = #SCS_CUE_PLAYING
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
            aSub(nSubPtr)\bPLFadingIn = #False
            debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
            setCueStateAndUpdateGrid(nCuePtr)
          EndIf
        ElseIf (\bTimeFadeInStartedSet) And ((gqTimeNow - \qTimeFadeInStarted) >= \nCurrFadeInTime)
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          \nAudState = #SCS_CUE_PLAYING
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
          debugMsg(sProcName, "calling setCueStateAndUpdateGrid(" + getCueLabel(nCuePtr) + ")")
          setCueStateAndUpdateGrid(nCuePtr)
        EndIf
      EndIf
    EndIf
    
    If (\nAudState = #SCS_CUE_PLAYING) Or (\nAudState = #SCS_CUE_TRANS_MIXING_OUT) Or (\nAudState = #SCS_CUE_FADING_OUT)
      getChannelAttributes(pAudPtr)
      
      If \bPlayEndSyncOccurred
        bChannelPlaying = #False
      Else
        bChannelPlaying = #True
        If \nRelFilePos >= (\nRelEndAt - 500)
          bChannelPlaying = isAudPlaying(pAudPtr)
        EndIf
      EndIf
      If bChannelPlaying = #False
        If \bWaitForGaplessEndSync
          ; hold back 'stop aud' processing if we are waiting for GaplessEndSync
          If \bTimeAudEndedSet = #False
            \qTimeAudEnded = gqTimeNow
            \bTimeAudEndedSet = #True
            bChannelPlaying = #True
          ElseIf (gqTimeNow - \qTimeAudEnded) < 250
            bChannelPlaying = #True
          EndIf
        EndIf
      EndIf
      If bChannelPlaying = #False
        If aSub(nSubPtr)\bPLTerminating
          If aSub(nSubPtr)\bHibernating
            debugMsg(sProcName, "calling pauseSub(" + getSubLabel(nSubPtr) + ", #True)")
            pauseSub(nSubPtr, #True)
          Else
            debugMsg(sProcName, "calling stopSub(" + getSubLabel(nSubPtr) + ", 'P', #True, #False)")
            stopSub(nSubPtr, "P", #True, #False)
          EndIf
        Else
          If (nMyNextPlayIndex >= 0) Or (bReRandomizePlaylist)
            If gbIgnoreSetCueState = #False
              debugMsg(sProcName, "setting gbIgnoreSetCueState=#True")
              gbIgnoreSetCueState = #True
            EndIf
            debugMsg(sProcName, "calling stopAud(" + getAudLabel(pAudPtr) + ")")
            stopAud(pAudPtr)
            If bReRandomizePlaylist
              debugMsg(sProcName, "bReRandomizePlaylist=" + strB(bReRandomizePlaylist) + ", calling generatePlayOrder(" + getSubLabel(nSubPtr) + ")")
              generatePlayOrder(nSubPtr)
              debugMsg(sProcName, "calling resetAndRestartSub(" + getSubLabel(nSubPtr) + ")")
              resetAndRestartSub(nSubPtr)
            EndIf
            
          ElseIf bSubStartedInEditor = #False
            debugMsg(sProcName, "calling stopSub(" + getSubLabel(nSubPtr) + ", 'P', #True, #False)")
            stopSub(nSubPtr, "P", #True, #False)
            
          ElseIf gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
            debugMsg(sProcName, "calling editPLStop(" + getSubLabel(nSubPtr) + ")")
            editPLStop(nSubPtr)
            
          Else
            debugMsg(sProcName, "calling stopAud(" + getAudLabel(pAudPtr) + ")")
            stopAud(pAudPtr)
          EndIf
        EndIf
        
        ; do not call setCueState yet as we may be in limbo between two files in the playlist
        ; debugMsg(sProcName, "calling setCueState(" + sCue + ")")
        ; setCueState(pCuePtr)
        ; updateGrid(pCuePtr)
        
      ElseIf \nCurrFadeOutTime > 0
        If \nRelFilePos >= (\nRelEndAt - \nCurrFadeOutTime - \nFadeOutExtraTime)
          \nCurrFadeOutTime = \nRelEndAt - \nRelFilePos - \nFadeOutExtraTime
          \nAudState = #SCS_CUE_TRANS_FADING_OUT
          debugMsg(sProcName, "calling setCueState(" + getCueLabel(nCuePtr) + ")")
          setCueState(nCuePtr)
          \qTimeFadeOutStarted = gqTimeNow
          \bTimeFadeOutStartedSet = #True
          \nPreFadeOutTimeOnPause = \nTotalTimeOnPause
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + "\nAudState=" + decodeCueState(\nAudState) +
                              ", \bTimeFadeOutStartedSet=" + strB(\bTimeFadeOutStartedSet) + ", \qTimeFadeOutStarted=" + traceTime(\qTimeFadeOutStarted) +
                              ", \nPreFadeOutTimeOnPause=" + \nPreFadeOutTimeOnPause)
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            \fBVLevelWhenFadeOutStarted[d] = \fCueTotalVolNow[d]
          Next d
          debugMsg(sProcName, "calling updateGrid(" + getCueLabel(nCuePtr) + ")")
          updateGrid(nCuePtr)
          If gbUseSMS
            If \nFadeOutType = #SCS_FADE_STD
              sMySetGainCommandString = "set chan " + \sSyncPXChanList + " gainmidi 0 fadetime " + makeSMSTimeString(\nCurrFadeOutTime)
            Else
              sMySetGainCommandString = "set chan " + \sSyncPXChanList + " gain 0 fadetime " + makeSMSTimeString(\nCurrFadeOutTime)
            EndIf
            nLabel = 104
            sendSMSCommandSC(sMySetGainCommandString, #cTraceSetLevels)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeQ(pSubPtr)
  ;- Process Call Cue
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected bCallCueCompleted
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    bSubStartedInEditor = \bStartedInEditor
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gbGlobalPause=" + strB(gbGlobalPause))
    bCallCueCompleted = #False
    If (\nSubState = #SCS_CUE_PLAYING) And (gbGlobalPause = #False)
      If \nCallCuePtr >= 0
; debugMsg(sProcName, "aCue(" + getCueLabel(\nCallCuePtr) + ")\bCueEnded=" + strB(aCue(\nCallCuePtr)\bCueEnded))
        If aCue(\nCallCuePtr)\bCueEnded
          bCallCueCompleted = #True
          debugMsg(sProcName, "bCallCueCompleted=" + strB(bCallCueCompleted) + ", aCue(" + getCueLabel(\nCallCuePtr) + ")\bCueEnded=" + strB(aCue(\nCallCuePtr)\bCueEnded))
        EndIf
      Else
        ; shouldn't get here
        bCallCueCompleted = #True
        debugMsg(sProcName, "bCallCueCompleted=" + strB(bCallCueCompleted) + ", \nCallCuePtr=" + \nCallCuePtr)
      EndIf
    EndIf
    If bCallCueCompleted
      SC_SubCompleteCommon(pSubPtr)
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeS(pSubPtr)
  ;- Process SFR
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected nMySubState
  Protected bSFRCompleted, nSFRCueType, sSFRCue.s, nSFRSubPtr, nSFRReleasedLoopInfoIndex, qSFRTimeStarted.q, nLastSFRCuePtr, bCheckThis, bExitFor, bWantThisSub, nLoopSubState
  Protected i, j, k, nAudLoopIndex, n
  Protected bAnyCues, bAudioOnly, bVideoOnly, bLiveOnly ; used in various macros, eg setWantThisSub()
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    nMySubState = \nSubState
    bSubStartedInEditor = \bStartedInEditor
    If (\nSubState = #SCS_CUE_RELEASING) Or (\nSubState = #SCS_CUE_STOPPING) Or (\nSubState = #SCS_CUE_FADING_IN) Or (\nSubState = #SCS_CUE_FADING_OUT)
      bSFRCompleted = #True
      nSFRCueType = \nSFRCueType[0]
      Select nSFRCueType
        Case #SCS_SFR_CUE_ALL_FIRST To #SCS_SFR_CUE_ALL_LAST, #SCS_SFR_CUE_PLAY_FIRST To #SCS_SFR_CUE_PLAY_LAST
          setProcSFRFlags2(nSFRCueType)
          qSFRTimeStarted = \qTimeSubStarted
          If (grProd\nRunMode = #SCS_RUN_MODE_LINEAR) And ((nSFRCueType >= #SCS_SFR_CUE_ALL_FIRST) And (nSFRCueType <= #SCS_SFR_CUE_ALL_LAST))
            nLastSFRCuePtr = nCuePtr - 1
          Else  ; nRunMode non-linear, or SFRCueType = "play"
            nLastSFRCuePtr = gnLastCue
          EndIf
          bExitFor = #False
          For i = 1 To nLastSFRCuePtr
            If bExitFor
              ; debugMsg(sProcName, " break")
              Break
            EndIf
            If i <> \nCueIndex  ; exclude the SFR cue itself from the testing
              If aCue(i)\nCueState < #SCS_CUE_ERROR
                j = aCue(i)\nFirstSubIndex
                While (j >= 0) And (bExitFor = #False)
                  setWantThisSub2(j)
                  If (bWantThisSub) And ((aSub(j)\qTimeSubStarted - qSFRTimeStarted) <= 0)
                    nLoopSubState = aSub(j)\nSubState
                    If nMySubState = #SCS_CUE_RELEASING
                      If ((aSub(j)\bSubTypeF) And (nLoopSubState > #SCS_CUE_READY) And (nLoopSubState <= #SCS_CUE_FADING_OUT))
                        k = aSub(j)\nFirstAudIndex
                        nAudLoopIndex = aAud(k)\nCurrLoopInfoIndex
                        If nAudLoopIndex >= 0
                          If ((aAud(k)\nRelFilePos < aAud(k)\aLoopInfo(nAudLoopIndex)\nRelLoopEnd) And (aAud(k)\nAudState > #SCS_CUE_READY) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT))
                            bSFRCompleted = #False
                            bExitFor = #True
                          EndIf
                        EndIf
                      EndIf
                      
                    ElseIf (nMySubState = #SCS_CUE_STOPPING) Or (nMySubState = #SCS_CUE_FADING_OUT)
                      ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubType=" + aSub(j)\sSubType + ", \nSubState=" + decodeCueState(nLoopSubState) + ", \bHotkey=" + strB(aSub(j)\bHotkey))
                      bCheckThis = #False
                      If (aSub(j)\bSubTypeA) And (nLoopSubState > #SCS_CUE_READY) And (nLoopSubState <= #SCS_CUE_FADING_OUT) And
                         (aSub(j)\bHotkey = #False) And (aSub(j)\bExtAct = #False) And (aSub(j)\bCallableCue = #False)
                        bCheckThis = #True
                      ElseIf (aSub(j)\bSubTypeA) And (nLoopSubState > #SCS_CUE_READY) And (aSub(j)\bHotkey Or aSub(j)\bCallableCue) And (aSub(j)\bExtAct = #False)
                        bCheckThis = #True
                        
                      ElseIf (aSub(j)\bSubTypeF) And (nLoopSubState > #SCS_CUE_READY) And (nLoopSubState <= #SCS_CUE_FADING_OUT) And
                             (aSub(j)\bHotkey = #False) And (aSub(j)\bExtAct = #False) And (aSub(j)\bCallableCue = #False)
                        bCheckThis = #True
                      ElseIf (aSub(j)\bSubTypeF) And (nLoopSubState > #SCS_CUE_READY) And (aSub(j)\bHotkey Or aSub(j)\bCallableCue) And (aSub(j)\bExtAct = #False)
                        bCheckThis = #True
                        
                      ElseIf (aSub(j)\bSubTypeI) And (nLoopSubState > #SCS_CUE_READY) And (nLoopSubState <= #SCS_CUE_FADING_OUT) And
                             (aSub(j)\bHotkey = #False) And (aSub(j)\bExtAct = #False) And (aSub(j)\bCallableCue = #False)
                        bCheckThis = #True
                      ElseIf (aSub(j)\bSubTypeI) And (nLoopSubState > #SCS_CUE_READY) And (aSub(j)\bHotkey Or aSub(j)\bCallableCue) And (aSub(j)\bExtAct = #False)
                        bCheckThis = #True
                        
                      ElseIf (aSub(j)\bSubTypeP) And (nLoopSubState > #SCS_CUE_READY) And (nLoopSubState <= #SCS_CUE_FADING_OUT)
                        bCheckThis = #True
                        
                      EndIf
                      If bCheckThis
                        If ((aSub(j)\bHotkey Or aSub(j)\bExtAct Or aSub(j)\bCallableCue) And (nLoopSubState = #SCS_CUE_READY)) Or (nLoopSubState = #SCS_CUE_HIBERNATING)
                          ; regard 'ready' hotkeys as 'completed', so do not set bSFRCompleted = False
                        Else
                          bSFRCompleted = #False
                          bExitFor = #True
                        EndIf
                      EndIf
                      ; debugMsg(sProcName, "bSFRCompleted=" + strB(bSFRCompleted) + ", bExitFor=" + strB(bExitFor))
                      
                    ElseIf nMySubState = #SCS_CUE_FADING_IN
                      If (aSub(j)\bSubTypeHasAuds) And (nLoopSubState = #SCS_CUE_FADING_IN)
                        bSFRCompleted = #False
                        bExitFor = #True
                      EndIf
                      
                    EndIf
                  EndIf
                  
                  j = aSub(j)\nNextSubIndex
                Wend
              EndIf
            EndIf
          Next i
          
        Case #SCS_SFR_CUE_SEL, #SCS_SFR_CUE_PREV
          ;debugMsg(sProcName, "bStopCompleted=" + bSFRCompleted)
          For n = 0 To #SCS_MAX_SFR
            sSFRCue = \sSFRCue[n]
            nSFRSubPtr = \nSFRSubPtr[n]
            nSFRReleasedLoopInfoIndex = \nSFRReleasedLoopInfoIndex[n]
            If sSFRCue
              bExitFor = #False
              For i = 1 To gnLastCue
                If bExitFor
                  Break
                EndIf
                
                If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED)
                  If aCue(i)\sCue = sSFRCue
                    j = aCue(i)\nFirstSubIndex
                    While (j >= 0) And (bExitFor = #False)
                    EndWith ; temp suspend With aSub(pSubPtr)
                    setWantThisSub2(j)  ; added 17Oct2016 11.5.2.3
                    If bWantThisSub     ; test added 17Oct2016 11.5.2.3
                      With aSub(j)
                        If (nSFRSubPtr = -1) Or (nSFRSubPtr = j)
                          If nMySubState = #SCS_CUE_RELEASING
                            If ((\bSubTypeF) And (\nSubState > #SCS_CUE_READY) And (\nSubState <= #SCS_CUE_FADING_OUT))
                              k = \nFirstAudIndex
                              nAudLoopIndex = nSFRReleasedLoopInfoIndex
                              If nAudLoopIndex >= 0
                                If ((aAud(k)\nRelFilePos < aAud(k)\aLoopInfo(nAudLoopIndex)\nRelLoopEnd) And (aAud(k)\nAudState > #SCS_CUE_READY) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT))
                                  bSFRCompleted = #False
                                  bExitFor = #True
                                EndIf
                              EndIf
                            EndIf
                            
                          ElseIf (nMySubState = #SCS_CUE_STOPPING) Or (nMySubState = #SCS_CUE_FADING_OUT)
                            bCheckThis = #False
                            If (\nSubState > #SCS_CUE_READY)
                              If (\nSubState <= #SCS_CUE_FADING_OUT)
                                If (\bSubTypeA Or \bSubTypeF Or \bSubTypeI) And (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
                                  bCheckThis = #True
                                ElseIf (\bSubTypeK Or \bSubTypeL Or \bSubTypeM Or \bSubTypeP Or \bSubTypeU)
                                  bCheckThis = #True
                                ElseIf (\bSubTypeS) And (j <> pSubPtr)
                                  bCheckThis = #True
                                EndIf
                              ElseIf (\bSubTypeA Or \bSubTypeF Or \bSubTypeI) And (\bHotkey Or \bExtAct Or \bCallableCue)
                                bCheckThis = #True
                              EndIf
                            EndIf
                            If bCheckThis
                              If ((\bHotkey Or \bExtAct Or \bCallableCue) And (\nSubState = #SCS_CUE_READY)) Or (\nSubState = #SCS_CUE_HIBERNATING)
                                ; regard 'ready' hotkeys as 'completed', so do not set bSFRCompleted = False
                              Else
                                bSFRCompleted = #False
                                bExitFor = #True
                              EndIf
                            EndIf
                            
                          ElseIf nMySubState = #SCS_CUE_FADING_IN
                            If (\bSubTypeHasAuds) And (\nSubState <= #SCS_CUE_FADING_IN)
                              ;debugMsg(sProcName, "" + \sSubLabel + ", \nSubState=" + \nSubState)
                              bSFRCompleted = #False
                              bExitFor = #True
                            EndIf
                            
                          EndIf
                        EndIf ; EndIf nSFRSubPtr = -1 Or nSFRSubPtr = j
                      EndIf
                      j = \nNextSubIndex
                    EndWith
                    ; reinstate previous 'with'
                    With aSub(pSubPtr)
                    Wend
                  EndIf
                EndIf
              Next i
            EndIf
          Next n
          
      EndSelect
      
      If bSFRCompleted
        SC_SubCompleteCommon(pSubPtr, #False)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SC_SubTypeU(pSubPtr)
  ;- Process MTC/LTC
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, bSubStartedInEditor
  Protected bMTCComplete
  
  With aSub(pSubPtr)
    nCuePtr = \nCueIndex
    bSubStartedInEditor = \bStartedInEditor
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gbGlobalPause=" + strB(gbGlobalPause))
    If (\nSubState = #SCS_CUE_PLAYING) And (gbGlobalPause = #False) ; And ((\nMTCDuration > 0) Or (\nMTCLinkedToAFSubPtr >= 0))
      \nSubPosition = (gqTimeNow - \qAdjTimeSubStarted) - \nSubTotalTimeOnPause
      If \nSubPosition < 0
        \nSubPosition = 0
      EndIf
      If \nMTCDuration > 0  ; nb not all MTC cues will have a 'duration'
        If \nSubPosition >= \nMTCDuration
          \nSubPosition = \nMTCDuration
          bMTCComplete = #True
        EndIf
      EndIf
      
      If \nMTCLinkedToAFSubPtr >= 0
        If aSub(\nMTCLinkedToAFSubPtr)\nSubState >= #SCS_CUE_STANDBY
          bMTCComplete = #True
        EndIf
      EndIf
      
      If bMTCComplete
        SC_SubCompleteCommon(pSubPtr)
      EndIf
      
    EndIf
    
    If (\nSubState = #SCS_CUE_PAUSED)
      \nSubTotalTimeOnPause = (gqTimeNow - \qSubTimePauseStarted) + \nSubPriorTimeOnPause
    EndIf
    
  EndWith
  
EndProcedure

Procedure SC_AudCommon(pAudPtr, nMyNextPlayIndex)
  ;- Common processing for Audio File, Playlist, Video/Image or Live Input
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, nSubPtr, bSubStartedInEditor; , nLabel
  Protected d, nAudLoopIndex
  Protected nMyFadeOutTime, nFadeOutPosition, nFadeOutTimeToGo, fFadeOutLevel.f, bFadeOutCompleted, nExtraTime
  Protected nBassResult.l, nBassChannel.l, nBassAltChannel.l, fBassLevel.f
  Protected nReqdAlphaBlend
  
  With aAud(pAudPtr)
    nCuePtr = \nCueIndex
    nSubPtr = \nSubIndex
    bSubStartedInEditor = aSub(nSubPtr)\bStartedInEditor
    
    If (\nAudState = #SCS_CUE_PAUSED) Or (\nAudState = #SCS_CUE_HIBERNATING)
      \nTotalTimeOnPause = (gqTimeNow - \qTimePauseStarted) + \nPriorTimeOnPause
    EndIf
    
    If (\nAudState = #SCS_CUE_FADING_OUT) Or (\nAudState = #SCS_CUE_TRANS_FADING_OUT)
      gqTimeDiskActive = gqTimeNow
      If (\bAudTypeAorP) And (\nAudState = #SCS_CUE_FADING_OUT) And (aSub(nSubPtr)\bPLTerminating)
        nMyFadeOutTime = aSub(nSubPtr)\nPLCurrFadeOutTime
      Else
        nMyFadeOutTime = \nCurrFadeOutTime
      EndIf
      ; debugMsg(sProcName, "" + \sAudLabel + ", \nAudState=" + decodeCueState(\nAudState) + ", nMyFadeOutTime=" + nMyFadeOutTime + ", \nFinalFadeOutTime=" + \nFinalFadeOutTime)
      If nMyFadeOutTime < 0
        nMyFadeOutTime = 0
      ElseIf \bAudTypeA And \nAudState = #SCS_CUE_TRANS_FADING_OUT
        If \bContinuous
          nExtraTime = 0 ; Added 7Dec2021 11.8.6ct because adding 250 to the 'continuous' end at would overflow in 32-bit mode (problem reported by Ian Harding)
        Else
          nExtraTime = 250 ; set to 250 8Oct2020 11.8.3.2bj to improve (slightly) image cross-fades in multi-image video/image cues, by waiting longer for the next image to fade in
        EndIf
        nMyFadeOutTime + nExtraTime ; Added 14May2020 11.8.3rc4a to ensure the faded out image remains present until after the next image has reached alpha blend 255
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", \nCurrFadeOutTime=" + \nCurrFadeOutTime + ", nMyFadeOutTime=" + nMyFadeOutTime)
      EndIf
      ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
      calcCuePositionForAud(pAudPtr)
      getChannelAttributes(pAudPtr)
      If \bTimeFadeOutStartedSet
        nFadeOutPosition = (gqTimeNow - \qTimeFadeOutStarted) - (\nTotalTimeOnPause - \nPreFadeOutTimeOnPause)
      Else
        ; shouldn't get here
        nFadeOutPosition = (0) - (\nTotalTimeOnPause - \nPreFadeOutTimeOnPause)
      EndIf
      ; debugMsg(sProcName, "" + \sAudLabel + ", nFadeOutPosition=" + nFadeOutPosition)
      If \bAudTypeI
        If nFadeOutPosition < (nMyFadeOutTime - \nFinalFadeOutTime)
          For d = \nFirstDev To \nLastDev
            If \nOutputDevMapDevPtr[d] >= 0
              fFadeOutLevel = calcBVLevel(\nFadeOutType, \nCurrFadeOutTime, nFadeOutPosition, \fBVLevelWhenFadeOutStarted[d], #SCS_MINVOLUME_SINGLE, \fTrimFactor[d])
              \fCueVolNow[d] = fFadeOutLevel
              \fCueTotalVolNow[d] = \fCueVolNow[d]
              CompilerIf #cTraceCueTotalVolNow
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(pAudPtr)\fCueTotalVolNow[d]))
              CompilerEndIf
            EndIf
          Next d
        Else
          For d = \nFirstDev To \nLastDev
            If \nOutputDevMapDevPtr[d] >= 0
              \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
              \fCueTotalVolNow[d] = \fCueVolNow[d]
              CompilerIf #cTraceCueTotalVolNow
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(pAudPtr)\fCueTotalVolNow[d]))
              CompilerEndIf
            EndIf
          Next d
          bFadeOutCompleted = #True
          ; debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted))
        EndIf
      Else
        If nFadeOutPosition >= (nMyFadeOutTime - \nFinalFadeOutTime)
          bFadeOutCompleted = #True
          ; debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted) + ", nMyFadeOutTime=" + nMyFadeOutTime + ", \nFinalFadeOutTime=" + \nFinalFadeOutTime)
        ElseIf (\nNextPlayIndex >= 0) Or (aSub(nSubPtr)\bPauseAtEnd = #False) ; added the test for fading out after 'pause at end' 20Jan2018 11.7.0rc5a following forum posting by Stas Ushomirsky
          If \bContinuous
            nExtraTime = 0 ; Added 7Dec2021 11.8.6ct because adding 250 to the 'continuous' end at would overflow in 32-bit mode (problem reported by Ian Harding)
          Else
            nExtraTime = 250 ; set to 250 8Oct2020 11.8.3.2bj to improve (slightly) image cross-fades in multi-image video/image cues, by waiting longer for the next image to fade in
          EndIf
          If \nRelFilePos >= (\nRelEndAt + nExtraTime) ; Added extra time to improve (slightly) image cross-fades in multi-image video/image cues, by waiting longer for the next image to fade in
            If \nMaxLoopInfo = grAudDef\nMaxLoopInfo
              bFadeOutCompleted = #True
              debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted) + ", aAud(" + getAudLabel(pAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nRelEndAt=" + \nRelEndAt +
                                  ", \nMaxLoopInfo=" + \nMaxLoopInfo + ", grAudDef\nMaxLoopInfo=" + grAudDef\nMaxLoopInfo)
            Else
              For nAudLoopIndex = 0 To \nMaxLoopInfo
                If (((\aLoopInfo(nAudLoopIndex)\nRelLoopEnd = -2) Or (\aLoopInfo(nAudLoopIndex)\nRelLoopEnd = 0)) And (\aLoopInfo(nAudLoopIndex)\bLoopReleased = #False))
                  bFadeOutCompleted = #True
                  debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted))
                EndIf
              Next nAudLoopIndex
            EndIf
          EndIf
        EndIf
      EndIf
      If bFadeOutCompleted
        CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
          debugMsg(sProcName, "" + \sAudLabel + ", nFadeOutPosition=" + nFadeOutPosition + ", \bBlending=" + strB(\bBlending) + ", \nFileFormat=" + decodeFileFormat(\nFileFormat))
        CompilerEndIf
        If \bAudTypeA
          If \nFileFormat = #SCS_FILEFORMAT_PICTURE
            If (\bBlending) And (nFadeOutPosition < nMyFadeOutTime + 1000)
              bFadeOutCompleted = #False
              ; debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted))
            EndIf
          Else
            d = 0
            If (\fCueTotalVolNow[d] = #SCS_MINVOLUME_SINGLE) Or (nFadeOutPosition > (nMyFadeOutTime + 1000))
              ; fadeout completed for this device
            Else
              ; else fadeout not completed for this device
              bFadeOutCompleted = #False
              ; debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted))
            EndIf
          EndIf
        ElseIf \bAudTypeM = #False
          If gbUseBASS
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              nBassChannel = \nBassChannel[d]
              If nBassChannel <> 0
                If BASS_ChannelIsSliding(nBassChannel, #BASS_ATTRIB_VOL) = #BASSTRUE
                  bFadeOutCompleted = #False
                  ; debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted))
                  ; ElseIf \fCueTotalVolNow[d] = #SCS_MINVOLUME_SINGLE Or (nFadeOutPosition > (nMyFadeOutTime + 1000))
                ElseIf \fCueTotalVolNow[d] = #SCS_MINVOLUME_SINGLE Or (nFadeOutPosition > (nMyFadeOutTime + 2))
                  ; fadeout completed for this device
                Else
                  ; else fadeout not completed for this device
                  bFadeOutCompleted = #False
                  nFadeOutTimeToGo = nMyFadeOutTime - nFadeOutPosition
                  debugMsg(sProcName, "bFadeOutCompleted=" + strB(bFadeOutCompleted) +
                                      ", \fAudPlayBVLevel[" + d + "]=" + traceLevel(\fAudPlayBVLevel[d]) +
                                      ", \fCueTotalVolNow[" + d + "]=" + traceLevel(\fCueTotalVolNow[d]) +
                                      ", nFadeOutPosition=" + nFadeOutPosition + ", nMyFadeOutTime=" + nMyFadeOutTime + ", nFadeOutTimeToGo=" + nFadeOutTimeToGo)
                  If nFadeOutTimeToGo > 0
                    nBassResult = BASS_ChannelGetAttribute(nBassChannel, #BASS_ATTRIB_VOL, @fBassLevel)
                    debugMsg(sProcName, "BASS_ChannelGetAttribute(" + decodeHandle(nBassChannel) + ", BASS_ATTRIB_VOL, @fBassLevel) returned " + nBassResult + ", fBassLevel=" + traceLevel(fBassLevel))
                    If fBassLevel > #SCS_MINVOLUME_SINGLE
                      nBassResult = BASS_ChannelSlideAttribute(nBassChannel, #BASS_ATTRIB_VOL, -2, nFadeOutTimeToGo)
                      debugMsg2(sProcName, "nBassResult = BASS_ChannelSlideAttribute(" + decodeHandle(nBassChannel) + ", #BASS_ATTRIB_VOL, -2, " + nFadeOutTimeToGo + ")", nBassResult)
                    EndIf
                    nBassAltChannel = \nBassAltChannel[d]
                    If nBassAltChannel <> 0
                      nBassResult = BASS_ChannelGetAttribute(nBassAltChannel, #BASS_ATTRIB_VOL, @fBassLevel)
                      debugMsg(sProcName, "BASS_ChannelGetAttribute(" + decodeHandle(nBassAltChannel) + ", BASS_ATTRIB_VOL, @fBassLevel) returned " + nBassResult + ", fBassLevel=" + traceLevel(fBassLevel))
                      If fBassLevel > #SCS_MINVOLUME_SINGLE
                        nBassResult = BASS_ChannelSlideAttribute(nBassAltChannel, #BASS_ATTRIB_VOL, -2, nFadeOutTimeToGo)
                        debugMsg2(sProcName, "nBassResult = BASS_ChannelSlideAttribute(" + decodeHandle(nBassAltChannel) + ", #BASS_ATTRIB_VOL, -2, " + nFadeOutTimeToGo + ")", nBassResult)
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
            Next d
          EndIf
        EndIf
        ; debugMsg(sProcName, "" + \sAudLabel + ", \nAudNo=" + \nAudNo + ", bFadeOutCompleted=" + strB(bFadeOutCompleted))
        
        If bFadeOutCompleted
          debugMsg(sProcName, "aAud(" + \sAudLabel + ")\nAudNo=" + \nAudNo + ", bFadeOutCompleted=" + strB(bFadeOutCompleted) +
                              ", aSub(" + getSubLabel(nSubPtr) + ")\bHibernating=" + strB(aSub(nSubPtr)\bHibernating) +
                              ", aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState) +
                              ", aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState))
          If aSub(nSubPtr)\bHibernating
            debugMsg(sProcName, "calling pauseSub(" + getSubLabel(nSubPtr) + ", #True)")
            pauseSub(nSubPtr, #True)
            
          ElseIf \bAudTypeF
            stopSub(nSubPtr, "F", #True, #False)
            
          ElseIf \bAudTypeI
            stopSub(nSubPtr, "I", #True, #False)
            
          ElseIf \bAudTypeM
            stopSub(nSubPtr, "M", #True, #False)
            
          ElseIf \bAudTypeAorP
            ; debugMsg(sProcName, "nMyNextPlayIndex=" + getAudLabel(nMyNextPlayIndex) + ", aSub(" + getSubLabel(nSubPtr) + ")\bPLTerminating=" + strB(aSub(nSubPtr)\bPLTerminating))
            If (nMyNextPlayIndex >= 0) And (aSub(nSubPtr)\bPLTerminating = #False)
              debugMsg(sProcName, "calling stopAud(" + getAudLabel(pAudPtr) + "), nMyNextPlayIndex=" + getAudLabel(nMyNextPlayIndex))
              stopAud(pAudPtr)
              
            ElseIf bSubStartedInEditor = #False
              If \bAudTypeA
                debugMsg(sProcName, "calling stopSub(" + getSubLabel(nSubPtr) + ", #False, #True), aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
                stopSub(nSubPtr, "A", #False, #True)
              Else ; \bAudTypeP
                If nMyNextPlayIndex < 0 And aSub(nSubPtr)\bPLRepeat
                  ; Added 4Jul2023 11.10.0bn
                  debugMsg(sProcName, "calling stopAud(" + getAudLabel(pAudPtr) + ")")
                  stopAud(pAudPtr)
                Else
                  debugMsg(sProcName, "calling stopSub(" + getSubLabel(nSubPtr) + ", #True, #False)")
                  stopSub(nSubPtr, "P", #True, #False)
                EndIf
              EndIf
              
            ElseIf \bAudTypeA
              debugMsg(sProcName, "calling editQAStop(" + getSubLabel(nSubPtr) + ")")
              editQAStop(nSubPtr)
              
            ElseIf (\bAudTypeP) And (gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE)
              debugMsg(sProcName, "calling editPLStop(" + getSubLabel(nSubPtr) + ")")
              editPLStop(nSubPtr)
              
            Else
              debugMsg(sProcName, "calling stopAud(" + pAudPtr + ")")
              stopAud(pAudPtr)
            EndIf
            
          EndIf
          
        ElseIf \bFinalFadeOut = #False
          If \bAudTypeForP
            \bFinalFadeOut = #True
            ; fade to nothing over .5 second
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If \nBassChannel[d] <> 0
                debugMsg(sProcName, "calling slideChannelAttributes(" + getAudLabel(pAudPtr) + ", " + d + ", #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE, " + Str(\nFinalFadeOutTime * 1.2) + ")")
                slideChannelAttributes(pAudPtr, d, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE, (\nFinalFadeOutTime * 1.2))
              EndIf
            Next d
            
          ElseIf \bAudTypeA
            d = 0
            If nMyFadeOutTime <= 0
              nReqdAlphaBlend = 255
            Else
              nReqdAlphaBlend = 255 - ((nFadeOutPosition * 255) / nMyFadeOutTime)
            EndIf
            CompilerIf (#cTraceAlphaBlend) And (#cTraceAlphaBlendFunctionCallsOnly = #False)
              debugMsg(sProcName, "nFadeOutPosition=" + Str(nFadeOutPosition) + ", nMyFadeOutTime=" + Str(nMyFadeOutTime) + ", nReqdAlphaBlend=" + Str(nReqdAlphaBlend))
            CompilerEndIf
            setAlphaBlend(pAudPtr, nReqdAlphaBlend)
            fFadeOutLevel = calcBVLevel(\nFadeOutType, \nCurrFadeOutTime, nFadeOutPosition, \fBVLevelWhenFadeOutStarted[d], #SCS_MINVOLUME_SINGLE, \fTrimFactor[d])
            If fFadeOutLevel <> \fCueTotalVolNow[d]
              CompilerIf #cTraceSetLevels
                debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(pAudPtr) + ", " + d + ", " + formatLevel(fFadeOutLevel) + ", #SCS_NOPANCHANGE_SINGLE")
              CompilerEndIf
              setLevelsAny(pAudPtr, d, fFadeOutLevel, #SCS_NOPANCHANGE_SINGLE)
            EndIf
          EndIf
        EndIf
        
      Else
        If  \bAudTypeF
          If (\bTimeForNextFadeCheckSet = #False) Or ((\qTimeForNextFadeCheck - gqTimeNow) <= 0)
            If \bFadeInProgress
              If (gqTimeNow - \qTimeForNextFadeCheck) >= 0
                CompilerIf #cTraceSetLevels
                  debugMsg(sProcName, "calling applyAudFade(" + getAudLabel(pAudPtr) + ")")
                CompilerEndIf
                applyAudFade(pAudPtr)
              EndIf
            ElseIf (\bInLoopXFade = #False) Or (\nFadeOutType = #SCS_FADE_LIN_SE) Or (\nFadeOutType = #SCS_FADE_LOG_SE)
              If (gbUseBASS) And (\nFadeOutType = #SCS_FADE_LIN)
                ; added 27May2017 11.6.2ak following bug report from Nigel Crook about 'jumpy fades'
                ; do not call slideChannelAttributes() here because fadeOutOneAud() issued a BASS_ChannelSlideAttribute() for the whole fade-out time
              Else
                For d = \nFirstSoundingDev To \nLastSoundingDev
                  If \nBassChannel[d] <> 0
                    Select \nFadeOutType
                      Case #SCS_FADE_LIN_SE, #SCS_FADE_LOG_SE
                        fFadeOutLevel = calcBVLevel(\nFadeOutType, \nMainFadeOutTime, nFadeOutPosition, \fBVLevelWhenFadeOutStarted[d], #SCS_MINVOLUME_SINGLE, \fTrimFactor[d])
                      Default
                        fFadeOutLevel = calcBVLevel(\nFadeOutType, \nCurrFadeOutTime, nFadeOutPosition, \fBVLevelWhenFadeOutStarted[d], #SCS_MINVOLUME_SINGLE, \fTrimFactor[d])
                    EndSelect
                    If fFadeOutLevel <> \fCueTotalVolNow[d]
                      CompilerIf #cTraceSetLevels
                        debugMsg(sProcName, "\nFadeOutType=" + decodeFadeType(\nFadeOutType) + ", \nCurrFadeOutTime=" + \nCurrFadeOutTime +
                                            ", fFadeOutLevel=" + formatLevel(fFadeOutLevel) + ", \fCueVolNow[" + d + "]=" + formatLevel(\fCueVolNow[d]))
                      CompilerEndIf
                      slideChannelAttributes(pAudPtr, d, fFadeOutLevel, #SCS_NOPANCHANGE_SINGLE, gnTimerInterval)
                    EndIf
                  EndIf
                Next d
              EndIf
            EndIf
          EndIf
          
        ElseIf \bAudTypeP
          If gbUseBASS  ; BASS
            ; debugMsg(sProcName, "calling setPLLevels(" + getAudLabel(pAudPtr) + ")")
            setPLLevels(pAudPtr)
          Else  ; SM-S
            ; not necessary to call setPLLevels()
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SC__RunStatusCheck(pCuePtr, pSubPtr, pAudPtr, nCaller)
  PROCNAMEC()
  Protected i, j, k
  Protected nState, nMySubState
  Protected nMyNextPlayIndex
  Protected nMyActivationMethodReqd
  Protected nAudLoopIndex
  Protected bAutoActivateCueStartedInEditor
  Protected bQuitStatusCheck
  Protected bThisSubHasAuds
  Protected bSetTimeToStart
  Protected nSubLength
  Protected bReRandomizePlaylist
  Protected qMyTimeToStartCue.q
  
  ; debugMsg(sProcName, #SCS_START + ", pCuePtr=" + getCueLabel(pCuePtr) + ", pSubPtr=" + getSubLabel(pSubPtr) + ", pAudPtr=" + getAudLabel(pAudPtr) + ", nCaller=" + nCaller)
  
  gnLabelStatusCheck = 1000
  gqTimeNow = ElapsedMilliseconds()
  
  If (pCuePtr < 1) Or (pCuePtr > gnLastCue)
    ProcedureReturn
  EndIf
  
  If pSubPtr > 0
    If aSub(pSubPtr)\bIgnoreInStatusCheck
      If aSub(pSubPtr)\bIgnoreInStatusCheckLogged = #False
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bIgnoreInStatusCheck=#True")
        aSub(pSubPtr)\bIgnoreInStatusCheckLogged = #True
      EndIf
      ; debugMsg(sProcName, " exiting because aSub(" + getSubLabel(pSubPtr) + ")\bIgnoreInStatusCheck=" + strB(aSub(pSubPtr)\bIgnoreInStatusCheck))
      ProcedureReturn
    Else
      aSub(pSubPtr)\bIgnoreInStatusCheckLogged = #False
    EndIf
    
    If aSub(pSubPtr)\bSubTypeHasAuds
      If pAudPtr > 0
        bThisSubHasAuds = #True
      ElseIf aSub(pSubPtr)\bSubTypeM = #False
        ; pAudPtr must be present if aSub(pSubPtr)\bSubTypeHasAuds except for control send cues, where Auds are optional
        debugMsg(sProcName, " exiting because pAudPtr=" + pAudPtr + " but aSub(" + getSubLabel(pSubPtr) + ")\bSubTypeM=#False")
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  If pAudPtr > 0
    If aAud(pAudPtr)\bIgnoreInStatusCheck
      If aAud(pAudPtr)\bIgnoreInStatusCheckLogged = #False
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bIgnoreInStatusCheck=#True")
        aAud(pAudPtr)\bIgnoreInStatusCheckLogged = #True
      EndIf
      ProcedureReturn
    Else
      aAud(pAudPtr)\bIgnoreInStatusCheckLogged = #False
    EndIf
  EndIf
  
  If gbIgnoreSetCueState
    ; debugMsg(sProcName, " setting gbIgnoreSetCueState=#False")
    gbIgnoreSetCueState = #False
  EndIf
  
  With aCue(pCuePtr)
    
    While #True
      
      nState = \nCueState
      bReRandomizePlaylist = #False
      If pAudPtr >= 0
        nState = aSub(pSubPtr)\nSubState
        ; if sub is on countdown to start, don't check the aud's
        If nState <> #SCS_CUE_SUB_COUNTDOWN_TO_START
          nState = aAud(pAudPtr)\nAudState
        EndIf
        nMyNextPlayIndex = aAud(pAudPtr)\nNextPlayIndex
        If nMyNextPlayIndex = -1
          ; If (aSub(pSubPtr)\bSubTypeAorP) And (aSub(pSubPtr)\bPLRepeat) And (aSub(pSubPtr)\nAudCount > 1)
          If (aSub(pSubPtr)\bSubTypeAorP) And (getPLRepeatActive(pSubPtr)) And (aSub(pSubPtr)\nAudCount > 1)
            If (aSub(pSubPtr)\bSubTypeP) And (aSub(pSubPtr)\bPLSavePos)
              bReRandomizePlaylist = #True
            Else
              nMyNextPlayIndex = aSub(pSubPtr)\nFirstPlayIndex
            EndIf
          EndIf
        EndIf
        ; debugMsg(sProcName, " aAud(" + getAudLabel(pAudPtr) + ")\nNextPlayIndex=" + aAud(pAudPtr)\nNextPlayIndex + ", nMyNextPlayIndex=" + nMyNextPlayIndex)
        
      ElseIf pSubPtr >= 0
        nState = aSub(pSubPtr)\nSubState
        
      EndIf
      
      ; debugMsg(sProcName, ">>>>> aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(\nCueState) + ", \bAutoStartLocked=" + strB(\bAutoStartLocked) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) + ", \nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr))
      
      If (\nCueState >= #SCS_CUE_STANDBY) ; commented out 01/10/2012: And ((gbEditHasFocus = #False) Or (gbEditHasFocus = #True And pCuePtr = nEditCuePtr))
        Break
      EndIf
      
      ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(\nCueState) + ", \bAutoStartLocked=" + strB(\bAutoStartLocked) + ", \nAutoActPosn=" + decodeAutoActPosn(\nAutoActPosn) + ", \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
      If (\nCueState <= #SCS_CUE_READY) And (\bAutoStartLocked = #False)
        nMyActivationMethodReqd = \nActivationMethodReqd
        If (nMyActivationMethodReqd = #SCS_ACMETH_MAN) Or
           (nMyActivationMethodReqd = #SCS_ACMETH_MAN_PLUS_CONF) Or
           ((nMyActivationMethodReqd & #SCS_ACMETH_HK_BIT) <> 0) Or
           (nMyActivationMethodReqd & #SCS_ACMETH_EXT_BIT) Or
           ((\bCueCompletedBeforeOpenedInEditor) And (pCuePtr = nEditCuePtr) And (gbEditHasFocus))
          Break
        EndIf
        If nMyActivationMethodReqd = #SCS_ACMETH_CALL_CUE
          Break
        EndIf
        If ((nMyActivationMethodReqd = #SCS_ACMETH_AUTO) Or (nMyActivationMethodReqd = #SCS_ACMETH_AUTO_PLUS_CONF)) And ((\nAutoActPosn = #SCS_ACPOSN_LOAD) Or (\nAutoActCuePtr > 0))
          
          If \nAutoActPosn <> #SCS_ACPOSN_LOAD
            ;{
            j = aCue(\nAutoActCuePtr)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bStartedInEditor
                bAutoActivateCueStartedInEditor = #True
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
            If bAutoActivateCueStartedInEditor
              Break
            EndIf
            ;}
          EndIf
          
          If \nAutoActPosn = #SCS_ACPOSN_AS  ; #SCS_ACPOSN_AS
            ;{
            ; debugMsg(sProcName, "aCue(" + getCueLabel(\nAutoActCuePtr) + ")\nCueState=" + decodeCueState(aCue(\nAutoActCuePtr)\nCueState) + ", \qTimeCueStarted=" + traceTime(aCue(\nAutoActCuePtr)\qTimeCueStarted) + ", \qTimeCueLastStarted=" + traceTime(aCue(\nAutoActCuePtr)\qTimeCueLastStarted) +
            ;                     ", \qTimeCueStopped=" + traceTime(aCue(\nAutoActCuePtr)\qTimeCueStopped))
            If (aCue(\nAutoActCuePtr)\nCueState < #SCS_CUE_FADING_IN) And (aCue(\nAutoActCuePtr)\bTimeCueStartedSet = #False) And (aCue(\nAutoActCuePtr)\qTimeCueLastStarted = 0) ; Added \qTimeCueLastStarted test 15Dec2022 11.10.0ac
              Break
            EndIf
            If aCue(\nAutoActCuePtr)\nCueState > #SCS_CUE_COMPLETED ; eg #SCS_CUE_ERROR, #SCS_CUE_NOT_LOADED, #SCS_CUE_IGNORED
              Break
            EndIf
            ; qMyTimeToStartCue = aCue(\nAutoActCuePtr)\qTimeCueStarted + \nAutoActTime
            qMyTimeToStartCue = aCue(\nAutoActCuePtr)\qTimeCueLastStarted + \nAutoActTime ; Changed \qTimeCueStarted to \qTimeCueLastStarted 15Dec2022 11.10.0ac
            ; If grProd\nRunMode = #SCS_RUN_MODE_LINEAR Or (gqTimeNow - qMyTimeToStartCue) >= 500 ; Commented out run mode test 19Aug2024 11.10.3bi following tests of Jason Mai's non-linear cue file
              \qTimeToStartCue = qMyTimeToStartCue
              \bTimeToStartCueSet = #True
              ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
              If grProd\nRunMode = #SCS_RUN_MODE_LINEAR And (gqTimeNow - \qTimeToStartCue) >= 2500
                ; should have started more than 2.5 seconds ago - assume we have just come back from the editor and controlling cue was completed ages ago
                \nActivationMethodReqd = #SCS_ACMETH_MAN
                ; debugMsg(sProcName, "aCue(" + \sCue + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd) +  ", aCue(" + getCueLabel(\nAutoActCuePtr) + ")\nCueState=" + decodeCueState(aCue(\nAutoActCuePtr)\nCueState))
                Break
              EndIf
            ; EndIf
            ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
            ;}
          ElseIf \nAutoActPosn = #SCS_ACPOSN_AE  ; #SCS_ACPOSN_AE
            ;{
            ; debugMsg(sProcName, "aCue(" + getCueLabel(\nAutoActCuePtr) + ")\nCueState=" + decodeCueState(aCue(\nAutoActCuePtr)\nCueState))
            If aCue(\nAutoActCuePtr)\nCueState = #SCS_CUE_NOT_LOADED
              If aCue(\nAutoActCuePtr)\bTimeCueStoppedSet = #False
                Break
              EndIf
            ElseIf (aCue(\nAutoActCuePtr)\nCueState < #SCS_CUE_STANDBY) Or (aCue(\nAutoActCuePtr)\nCueState > #SCS_CUE_COMPLETED)
              If aCue(\nAutoActCuePtr)\bTimeCueStoppedSet = #False Or aCue(\nAutoActCuePtr)\bCueEnded = #False
                Break
              EndIf
            EndIf
            If aCue(\nAutoActCuePtr)\bCueStoppedByStopEverything Or aCue(\nAutoActCuePtr)\bCueStoppedByGoToCue
              Break
            EndIf
            
            qMyTimeToStartCue = aCue(\nAutoActCuePtr)\qTimeCueStopped + \nAutoActTime
            ; If grProd\nRunMode = #SCS_RUN_MODE_LINEAR Or (gqTimeNow - qMyTimeToStartCue) >= 500 ; Commented out run mode test 19Aug2024 11.10.3bi following tests of Jason Mai's non-linear cue file
              \qTimeToStartCue = qMyTimeToStartCue
              \bTimeToStartCueSet = #True
              ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
              ; debugMsg(sProcName, "aCue(" + getCueLabel(\nAutoActCuePtr) + ")\qTimeCueStopped=" + traceTime(aCue(\nAutoActCuePtr)\qTimeCueStopped) + ", aCue(" + \sCue + ")\nAutoActTime=" + \nAutoActTime)
              ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\qTimeToStartCue=" + traceTime(\qTimeToStartCue) + ", \bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", gqTimeNow=" + traceTime(gqTimeNow))
              If grProd\nRunMode = #SCS_RUN_MODE_LINEAR And (gqTimeNow - \qTimeToStartCue) >= 2500
                ; should have started more than 2.5 seconds ago - assume we have just come back from the editor and controlling cue was completed ages ago
;                 debugMsg(sProcName, "aCue(" + \sCue + ")\qTimeToStartCue=" + traceTime(\qTimeToStartCue) +
;                                     ", \qTimeCueStarted=" + traceTime(\qTimeCueStarted) + ", \qTimeCueLastStarted=" + traceTime(\qTimeCueLastStarted) +
;                                     ", \qTimeCueStopped=" + traceTime(\qTimeCueStopped) + ", \bCueEnded=" + strB(\bCueEnded))
                If (\qTimeCueLastStarted <> 0) And ((\qTimeToStartCue - \qTimeCueLastStarted) > 0)
                  \nActivationMethodReqd = #SCS_ACMETH_MAN
                  debugMsg(sProcName, "\sCue=" + \sCue + " \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
                EndIf
                Break
              EndIf
            ; EndIf
            ;}
          ElseIf \nAutoActPosn = #SCS_ACPOSN_BE  ; #SCS_ACPOSN_BE
            ;{
            If aCue(\nAutoActCuePtr)\nCueState < #SCS_CUE_FADING_IN
              Break
            EndIf
            If aCue(\nAutoActCuePtr)\nCueState > #SCS_CUE_COMPLETED ; eg #SCS_CUE_ERROR
              Break
            EndIf
            If aCue(\nAutoActCuePtr)\bCueStoppedByStopEverything Or aCue(\nAutoActCuePtr)\bCueStoppedByGoToCue
              Break
            EndIf
            
            If aCue(\nAutoActCuePtr)\nCueState = #SCS_CUE_COMPLETED
              qMyTimeToStartCue = aCue(\nAutoActCuePtr)\qTimeCueStopped + \nAutoActTime
              ; If grProd\nRunMode = #SCS_RUN_MODE_LINEAR Or (gqTimeNow - qMyTimeToStartCue) >= 500 ; Commented out run mode test 19Aug2024 11.10.3bi following tests of Jason Mai's non-linear cue file
                \qTimeToStartCue = qMyTimeToStartCue
                \bTimeToStartCueSet = #True
                ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
                debugMsg(sProcName, "aCue(" + getCueLabel(\nAutoActCuePtr) + ")\qTimeCueStopped=" + traceTime(aCue(\nAutoActCuePtr)\qTimeCueStopped) +
                                    ", aCue(" + getCueLabel(pCuePtr) + ")\nAutoActTime=" + \nAutoActTime + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
                If grProd\nRunMode = #SCS_RUN_MODE_LINEAR And (gqTimeNow - \qTimeToStartCue) >= 2500
                  ; should have started more than 2.5 seconds ago - assume we have just come back from the editor and controlling cue was completed ages ago
                  \nActivationMethodReqd = #SCS_ACMETH_MAN
                  debugMsg(sProcName, "\sCue=" + \sCue + " \nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
                  Break
                EndIf
              ; EndIf
            EndIf
            
            j = aCue(\nAutoActCuePtr)\nFirstSubIndex
            bSetTimeToStart = #True
            While (j >= 0) And (bSetTimeToStart)
              If aSub(j)\bSubEnabled ; Test added 26Nov2024 11.10.6bq following investigation into issue reported by Ian Harding
                If aSub(j)\bSubTypeAorF
                  k = aSub(j)\nLastPlayIndex
                  If k = -1
                    k = aSub(j)\nFirstAudIndex
                  EndIf
                  ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nLastPlayIndex=" + getAudLabel(aSub(j)\nLastPlayIndex) + ", \nFirstAudIndex=" + getAudLabel(aSub(j)\nFirstAudIndex) + ", k=" + getAudLabel(k))
                  If k >= 0
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
                    If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
                      If (aAud(k)\qEndAtTime = grAudDef\qEndAtTime) Or (gqTimeNow - (aAud(k)\qEndAtTime - aCue(pCuePtr)\nAutoActTime + (aAud(k)\nTotalTimeOnPause - aAud(k)\nPreFadeOutTimeOnPause)) < 0)
                        If (aAud(k)\bIgnoreInStatusCheck = #False) And (aSub(j)\bIgnoreInStatusCheck = #False) ; nb if currently ignoring aAud(k) or aSub(j) in StatusCheck() then do not call calcCuePositionForAud(k) so \nRelFilePos is unchanged
                          calcCuePositionForAud(k)
                        EndIf
                        If aAud(k)\nRelFilePos < (aAud(k)\nRelEndAt - aCue(pCuePtr)\nAutoActTime)
                          bSetTimeToStart = #False
                        EndIf
                        For nAudLoopIndex = 0 To aAud(k)\nMaxLoopInfo
                          If aAud(k)\aLoopInfo(nAudLoopIndex)\bLoopReleased = #False
                            bSetTimeToStart = #False
                            Break
                          EndIf
                        Next nAudLoopIndex
                      EndIf
                    ElseIf aAud(k)\nAudState <> #SCS_CUE_COMPLETED ; Added "If aAud(k)\nAudState <> #SCS_CUE_COMPLETED" 29Apr2024 11.10.2ci following bug report from Van Bullock where some 'before end' cues were not started at all
                      ; Added 4Apr2023 11.10.0at following email from Peter Mount about a 'before end' starting too early
                      ; which was caused by the final image in a multi-image cue having the status 'not loaded'
                      bSetTimeToStart = #False
                    EndIf
                  Else
                    bSetTimeToStart = #False
                  EndIf
                Else
                  ; added 5Jan2016 11.4.2 following error reported by Christian Kuehne regarding an auto-start cue set to start 2 seconds before the end of an SFR fadeout cue actually started immediately the fadeout commenced
                  ; (see also code below label 195)
                  If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState <= #SCS_CUE_FADING_OUT)
                    nSubLength = getSubLength(j)
                    ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubPosition=" + aSub(j)\nSubPosition + ", nSubLength=" + nSubLength + ", \nAutoActTime=" + \nAutoActTime)
                    If aSub(j)\nSubPosition < (nSubLength - \nAutoActTime)
                      bSetTimeToStart = #False
                    EndIf
                  EndIf
                  ; end added 5Jan2016 11.4.2
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
            ; debugMsg(sProcName, " bSetTimeToStart=" + strB(bSetTimeToStart))
            If bSetTimeToStart = #False
              Break
            EndIf
            \qTimeToStartCue = gqTimeNow
            \bTimeToStartCueSet = #True
            debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
            ;}
          ElseIf \nAutoActPosn = #SCS_ACPOSN_LOAD ; #SCS_ACPOSN_LOAD
            ;{
            ; debugMsg(sProcName, "grProd\bTimeProdLoadedSet=" + strB(grProd\bTimeProdLoadedSet) + ", grProd\qTimeProdLoaded=" + traceTime(grProd\qTimeProdLoaded))
            If grProd\bTimeProdLoadedSet = #False
              Break
            EndIf
            \qTimeToStartCue = grProd\qTimeProdLoaded + \nAutoActTime
            \bTimeToStartCueSet = #True
            ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
            ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\qTimeToStartCue=" + traceTime(\qTimeToStartCue) + ", gqTimeNow=" + traceTime(gqTimeNow))
            ; debugMsg(sProcName, "pCuePtr=" + getCueLabel(pCuePtr) + ", pSubPtr=" + getSubLabel(pSubPtr) + ", \nCueState=" + decodeCueState(\nCueState) + ", aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(aSub(pSubPtr)\nSubState))
            If (gqTimeNow - \qTimeToStartCue) >= 5000
              ; should have started more than 5 seconds ago - assume we have just come back from the editor and cue file was loaded ages ago
              \nActivationMethodReqd = #SCS_ACMETH_MAN
              ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(\nActivationMethodReqd))
              Break
            EndIf
            ;}
          ElseIf \nAutoActPosn = #SCS_ACPOSN_OCM
            ;{
            \bTimeToStartCueSet = #False
            ;}
          EndIf
          
        ElseIf nMyActivationMethodReqd = #SCS_ACMETH_OCM
          \bTimeToStartCueSet = #False
          
        EndIf
        
        If gbStoppingEverything Or gbSamRequestUnderStoppingEverything
          If \bTimeToStartCueSet
            debugMsg(sProcName, "clearing aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet and \qTimeToStartCue (was " + traceTime(\qTimeToStartCue) + ")")
          EndIf
          \qTimeToStartCue = grCueDef\qTimeToStartCue
          \bTimeToStartCueSet = grCueDef\bTimeToStartCueSet
          ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
        EndIf
        
        ; debugMsg(sProcName, "nMyActivationMethodReqd=" + decodeActivationMethod(nMyActivationMethodReqd) + ", aCue(" + getCueLabel(pCuePtr) + ")\nSecondToStart=" + \nSecondToStart + ", \bTBCDone=" + strB(\bTBCDone))
        If (nMyActivationMethodReqd = #SCS_ACMETH_TIME) And (\nSecondToStart > 0) And (\bTBCDone = #False) And (grFMOptions\nFunctionalMode <> #SCS_FM_BACKUP)
          ; start countdown 1 min before 'time to start'
          ; debugMsg(sProcName, "\nSecondToStart=" + \nSecondToStart + ", Date()=" + Date())
          If (\nSecondToStart - Date()) >= 60
            ; debugMsg(sProcName, "(\nSecondToStart - Date())=" + Str(\nSecondToStart - Date()) + ", Break")
            Break
          ElseIf (Date() - \nSecondToStart) > 60
            ; added this test 4Jan2016 11.4.2 following log from Brian O'Connor which had a TBC continually being monitored over an hour after it would have been started and completed
            debugMsg(sProcName, "\nSecondToStart=" + \nSecondToStart + ", Date()=" + Date() + ", calling setTimeBasedCues(" + getCueLabel(pCuePtr) + ")" + ", \nCueState=" + decodeCueState(\nCueState))
            samAddRequest(#SCS_SAM_SET_TIME_BASED_CUES, pCuePtr)
            Break
          EndIf
          \qTimeToStartCue = ((\nSecondToStart - Date()) * 1000) + gqTimeNow
          \bTimeToStartCueSet = #True
          ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nSecondToStart=" + \nSecondToStart + ", Date()=" + Date() + ", gqTimeNow=" + gqTimeNow)
          ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
        EndIf
        
        If aSub(pSubPtr)\nSubState = #SCS_CUE_NOT_LOADED
          debugMsg(sProcName, "calling openFilesForCueIfReqd(" + getCueLabel(pCuePtr) + ")")
          If openFilesForCueIfReqd(pCuePtr) = #False
            bQuitStatusCheck = #True
            Break
          EndIf
        EndIf
        
        If \bTimeToStartCueSet And \qTimeToStartCue > \qTimeCueLastStarted ; 17Mar2022 11.9.1ao added "And \qTimeToStartCue > \qTimeCueLastStarted" following email from Jason Mai ("RS232 Control Send issue"). Turned out to be due to using non-linear runmode.
          debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\qTimeCueLastStarted=" + traceTime(\qTimeCueLastStarted) + ", \qTimeCueStarted=" + traceTime(\qTimeCueStarted) + ", \qTimeCueStopped=" + traceTime(\qTimeCueStopped) + ", \qTimeToStartCue=" + traceTime(\qTimeToStartCue))
          debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTimeToStartCueSet=" + strB(\bTimeToStartCueSet) + ", \nCueState=" + decodeCueState(\nCueState) +
                              ", aSub(" + getSubLabel(pSubPtr) + ")\bSubCompletedBeforeOpenedInEditor=" + strB(aSub(pSubPtr)\bSubCompletedBeforeOpenedInEditor) + ", gbEditHasFocus=" + strB(gbEditHasFocus))
          If (bThisSubHasAuds) And ((aSub(pSubPtr)\bSubCompletedBeforeOpenedInEditor = #False) Or (gbEditHasFocus = #False))
            ; 1Sep2017 mod to the following for SCS 11.7.0: only check the first play Aud() because playlists only have up to 2 files open at a time
            ; (bug reported by email from Randy Hammon)
            k = aSub(pSubPtr)\nFirstPlayIndexThisRun
            If k <= 0
              k = aSub(pSubPtr)\nFirstPlayIndex
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
            If aAud(k)\nAudState = #SCS_CUE_NOT_LOADED
              ; debugMsg(sProcName, "calling openFilesForCueIfReqd(" + getCueLabel(pCuePtr) + ")")
              If openFilesForCueIfReqd(pCuePtr) = #False
                bQuitStatusCheck = #True
                Break
              EndIf
            EndIf
            If aAud(k)\nAudState = #SCS_CUE_READY
              ; debugMsg(sProcName, "setting aAud(" + getAudLabel(k) + ")\nAudState=Countdown.  gqTimeNow=" + traceTime(gqTimeNow) +
              ;                     ", aCue(" + getCueLabel(aAud(k)\nCueIndex) + ")\qTimeToStartCue=" + traceTime(aCue(aAud(k)\nCueIndex)\qTimeToStartCue) + ", aCue(" + getCueLabel(pCuePtr) + ")\bTBCDone=" + strB(\bTBCDone))
              aAud(k)\nAudState = #SCS_CUE_COUNTDOWN_TO_START
              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
            EndIf
            If bQuitStatusCheck
              Break
            EndIf
            
          Else
            If \bTBCDone = #False ; Test added 11Jan2022 11.9af following test of playlist and following SFR cue, with time-based cues and non-linear run mode - previously the SFR cue would be processed repeatedly
              If (aSub(pSubPtr)\nSubState = #SCS_CUE_READY) And ((aSub(pSubPtr)\bSubCompletedBeforeOpenedInEditor = #False) Or (gbEditHasFocus = #False))
                debugMsg(sProcName, "setting aSub(" + getSubLabel(pSubPtr) + ")\nSubState=Countdown.  gqTimeNow=" + traceTime(gqTimeNow) +
                                    ", aCue(" + getCueLabel(aSub(pSubPtr)\nCueIndex) + ")\qTimeToStartCue=" + traceTime(aCue(aSub(pSubPtr)\nCueIndex)\qTimeToStartCue) + ", aCue(" + getCueLabel(pCuePtr) + ")\bTBCDone=" + strB(\bTBCDone))
                aSub(pSubPtr)\nSubState = #SCS_CUE_COUNTDOWN_TO_START
              EndIf
              ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(aSub(pSubPtr)\nSubState))
            EndIf
          EndIf
          
          samAddRequest(#SCS_SAM_LOAD_CUE_PANELS) ; Added 13Mar2025 11.10.8ah to ensure the now counting down cue is displayed in the cue panels
          
        EndIf
        ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(pCuePtr) + "), pSubPtr=" + getSubLabel(pSubPtr) + ", pAudPtr=" + getAudLabel(pAudPtr))
        setCueState(pCuePtr)
        
        If pAudPtr >= 0
          ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(aAud(pAudPtr)\nAudState))
          nState = aAud(pAudPtr)\nAudState
        ElseIf pSubPtr >= 0
          ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(aSub(pSubPtr)\nSubState))
          nState = aSub(pSubPtr)\nSubState
        Else
          ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(aCue(pCuePtr)\nCueState))
          nState = \nCueState
        EndIf
        
        ; debugMsg(sProcName, "calling updateGrid(" + sCue + ")" + ", aCue(" + \sCue + ")\nCueState=" + decodeCueState(\nCueState) + ", nState=" + decodeCueState(nState))
        updateGrid(pCuePtr)
        ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueState=" + decodeCueState(aCue(pCuePtr)\nCueState))
        
      EndIf
      Break
      
    Wend  ; bPreCheckState
    
  EndWith
  
  If bQuitStatusCheck
    debugMsg(sProcName, "exiting because bQuitStatusCheck=" + strB(bQuitStatusCheck))
    ProcedureReturn
  EndIf
  
  ; added 5Jan2016 11.4.2 following error reported by Christian Kuehne regarding an auto-start cue set to start 2 seconds before the end of an SFR fadeout cue actually started immediately the fadeout commenced
  ; (see also code below label 110)
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If (\nSubState >= #SCS_CUE_FADING_IN) And (\nSubState <= #SCS_CUE_FADING_OUT) And (gbGlobalPause = #False)
        \nSubPosition = (gqTimeNow - \qAdjTimeSubStarted) - \nSubTotalTimeOnPause
        If \nSubPosition < 0
          \nSubPosition = 0
        EndIf
      EndIf
    EndWith
  EndIf
  ; end added 5Jan2016

  ;- Check State
  gnLabelStatusCheck = #PB_Compiler_Line
  While #True
    
    With aCue(pCuePtr)
      If (nState = #SCS_CUE_COUNTDOWN_TO_START) And (gbGlobalPause = #False) And (\bCueCountDownPaused = #False) And (gbClosingDown = #False) ; Added gbClosingDown test 20Jan2023 11.9.8
        If \nHideCueOpt = #SCS_HIDE_NO
          \nCuePanelUpdateFlags | #SCS_CUEPNL_OTHER   ; ensure the 'running ind' (\lblRunningInd) in the cue panel gets updated with the count down
        EndIf
        If (\bCueCountDownFinished) And ((gqTimeNow - \qCueCountDownFinishedTime) <= 1000)
          ; debugMsg(sProcName, "gqTimeNow=" + traceTime(gqTimeNow) + ", aCue(" + getCueLabel(pCuePtr) + ")\qCueCountDownFinishedTime=" + traceTime(\qCueCountDownFinishedTime))
          ; currently processing this countdown expiry
          Break
        Else
          \nCueCountDownTimeLeft = \qTimeToStartCue - gqTimeNow
          If \nCueCountDownTimeLeft < -5000
            debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nCueCountDownTimeLeft=" + \nCueCountDownTimeLeft + ", \qTimeToStart=" + traceTime(\qTimeToStartCue) + ", \bTimeToStartCueSet=" + strB(\bTimeToStartCueSet))
          EndIf
          If \nCueCountDownTimeLeft <= 0 ; And \nCueCountDownTimeLeft >= -5000
            If \bPlayCueEventPosted = #False
              \nCueCountDownTimeLeft = 0
              \qCueCountDownFinishedTime = gqTimeNow
              \bCueCountDownFinished = #True
              ; If \nActivationMethod = #SCS_ACMETH_TIME
              If \nActivationMethodReqd = #SCS_ACMETH_TIME ; Changed 29Jan2022 11.9.0rc6a
                \bTBCDone = #True
                debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bTBCDone=" + strB(\bTBCDone))
              EndIf
              ; debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_PLAY_CUE, " + getCueLabel(pCuePtr) + ")")
              ; samAddRequest(#SCS_SAM_PLAY_CUE, pCuePtr) ; makes sure playCue() will be executed in main thread, which is necessary if cue contains MIDI
              ; 7Nov2018 11.8.0aq replaced above SAM request by PostEvent to minimise the delay in starting the cue; also added gqPriorityPostEventWaiting
              ; debugMsg(sProcName, "PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, " + getCueLabel(pCuePtr) + ")")
              \bPlayCueEventPosted = #True
              gqPriorityPostEventWaiting = ElapsedMilliseconds()
              PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, pCuePtr)
              debugMsg(sProcName, "PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, " + getCueLabel(pCuePtr) + "), gqPriorityPostEventWaiting=" + traceTime(gqPriorityPostEventWaiting))
              ; debugMsg(sProcName, "calling highlightLine(" + getCueLabel(gnHighlightedCue) + ")")
              highlightLine(gnHighlightedCue)
              gqMainThreadRequest | #SCS_MTH_SET_NAVIGATE_BUTTONS
            EndIf
            Break
          EndIf
        EndIf
      EndIf
    EndWith
    
    With aSub(pSubPtr)
      
      nMySubState = \nSubState
      ;debugMsg(sProcName, " " + \sSubLabel + ", \nSubState=" + decodeCueState(\nSubState) + ", \nRelStart=" + \nRelStart + ", \qTimeToStartSub=" + \qTimeToStartSub)
      
      If (nMySubState = #SCS_CUE_SUB_COUNTDOWN_TO_START) And (gbGlobalPause = #False) And (\bSubCountDownPaused = #False)
        \nSubCountDownTimeLeft = \qTimeToStartSub - gqTimeNow
        If \nSubCountDownTimeLeft <= 0
          \nSubCountDownTimeLeft = 0
          If \bPlaySubInMainThread = #False   ; test prevents unnecessary repeated processing
            \bPlaySubInMainThread = #True     ; makes sure playSub() will be executed in main thread, which is necessary if sub contains MIDI
            debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bPlaySubInMainThread=#True, \qTimeToStartSub=" + traceTime(\qTimeToStartSub) + ", gqTimeNow=" + traceTime(gqTimeNow))
            gqMainThreadRequest | #SCS_MTH_PLAY_SUB
            gqMainThreadRequest | #SCS_MTH_SET_NAVIGATE_BUTTONS
          EndIf
          Break
        EndIf
      EndIf
      
    EndWith
    
    If ((aSub(pSubPtr)\bSubTypeF) Or (aSub(pSubPtr)\bSubTypeM)) And (pAudPtr > 0)
      ; -------------------------------------------------- AUDIO FILE, or CTRL SEND with a MIDI file
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeF_or_SubTypeM_MIDI(pAudPtr)
      
    ElseIf (aSub(pSubPtr)\bSubTypeA) And (pAudPtr > 0)
      ; -------------------------------------------------- VIDEO / IMAGE
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeA(pAudPtr, nMyNextPlayIndex)
      
    ElseIf aSub(pSubPtr)\bSubTypeE
      ; -------------------------------------------------- MEMO
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeE(pSubPtr)
      
    ElseIf (aSub(pSubPtr)\bSubTypeI) And (pAudPtr > 0)
      ; -------------------------------------------------- LIVE INPUT
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeI(pAudPtr)
      
    ElseIf aSub(pSubPtr)\bSubTypeK
      ; -------------------------------------------------- LIGHTING
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeK(pSubPtr)
      
    ElseIf aSub(pSubPtr)\bSubTypeL
      ; -------------------------------------------------- LEVEL CHANGE
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeL(pSubPtr)
      
    ElseIf aSub(pSubPtr)\bSubTypeM
      ; -------------------------------------------------- CTRL SEND
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeM(pSubPtr)
      
    ElseIf (aSub(pSubPtr)\bSubTypeP) And (pAudPtr > 0)
      ; -------------------------------------------------- PLAYLIST
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeP(pAudPtr, bReRandomizePlaylist, nMyNextPlayIndex)
      
    ElseIf aSub(pSubPtr)\bSubTypeQ
      ; -------------------------------------------------- CALL CUE
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeQ(pSubPtr)
      
    ElseIf aSub(pSubPtr)\bSubTypeS
      ; -------------------------------------------------- SFR
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeS(pSubPtr)
      
    ElseIf aSub(pSubPtr)\bSubTypeU
      ; -------------------------------------------------- MTC/LTC
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_SubTypeU(pSubPtr)
      
    EndIf
    
    If bThisSubHasAuds
      ; -------------------------------------------------- AUDIO FILE or PLAYLIST or VIDEO FILE or STILL IMAGE FILE or LIVE INPUT
      gnLabelStatusCheck = #PB_Compiler_Line
      SC_AudCommon(pAudPtr, nMyNextPlayIndex)
    EndIf
    
    If gbCallEditUpdateDisplay Or (gbEditing And nEditSubPtr = pSubPtr)
      gnLabelStatusCheck = #PB_Compiler_Line
      gqMainThreadRequest | #SCS_MTH_EDIT_UPDATE_DISPLAY
    EndIf
    
    Break
  Wend  ; bMainLogic
  
  gnLabelStatusCheck = 9999
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF