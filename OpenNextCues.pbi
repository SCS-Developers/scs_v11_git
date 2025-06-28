; File: OpenNextCues.pbi

EnableExplicit

; INFO: Prior to SCS 11.8.3rc3, the code in almost all the Procedures in this file (except loadDependentCues) was included in the single Procedure openNextCues() in aaMmain.pbi.
; INFO: This was not only unmanagable, but it also contained unnecessary code (probably due to the complexity of the Procedure) and also at least one bug.
; INFO: This file (OpenNextCues.pbi) was created to contain all the necessary coding for openNextCues(), and to separate the main logic into discrete Procedures.

Structure tyONC1
  ; OpenNextCues.pbi arrays that should NOT be redimensioned each call to ONC_openNextCues()
  Array aReqdVideoImageAudPtrs.i(0)
  Array aReqdAudioAudPtrs.i(0)
  Array aReqdMidiAudPtrs.i(1)
  Array aReqdLiveAudPtrs.i(1)
  Array bOpenAudCounted.i(0)
EndStructure
Global grONC1.tyONC1

Structure tyONC2
  ; OpenNextCues.pbi regular variables that should be cleared each call to ONC_openNextCues()
  nMyLoopStartCuePtr.i
  nMyLoopEndCuePtr.i
  nFilesOpenedThisCall.i
  nAudioFilesOpen.i
  nVideoImageFilesOpen.i
  nMidiFilesOpen.i
  bAudioFilePlaying.i
  bVideoFilePlaying.i
  bLiveInputPlaying.i
  bMidiFilePlaying.i
  nSMSPChanCountNonHK.i
  nSMSPChanCountHK.i
  nSMSPChansReqdHK.i
  nSMSPChansAvailableForNonHK.i
EndStructure
Global grONC2.tyONC2

Procedure ONC_openNextCues(nLoopStartCuePtr=1, nLoopEndCuePtr=-1, nGoCue=-2, bIgnorePlayingState=#False, bSetCueToGo=#True, nReqdCuePtr=-1, bApplyDefaultGridClickAction=#False)
  ; INFO: Top-Level Procedure for 'open next cues'
  PROCNAMEC()
  Protected bLockedMutex
  Protected rONC2.tyONC2
  Protected i
  Protected qTimeStarted.q

  debugMsg(sProcName, #SCS_START + ", nLoopStartCuePtr=" + getCueLabel(nLoopStartCuePtr) + ", nLoopEndCuePtr=" + getCueLabel(nLoopEndCuePtr) + ", nGoCue=" + getCueLabel(nGoCue) +
                      ", bIgnorePlayingState=" + strB(bIgnorePlayingState) + ", bSetCueToGo=" + strB(bSetCueToGo) + ", nReqdCuePtr=" + getCueLabel(nReqdCuePtr) +
                      ", bApplyDefaultGridClickAction=" + strB(bApplyDefaultGridClickAction))
  
  qTimeStarted = ElapsedMilliseconds()
  
  gnCallOpenNextCues = 0
  ; debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  If gbInOpenNextCues
    ; nested call (eg from setCueToGo())
    debugMsg(sProcName, "exiting because gbInOpenNextCues=#True")
    ProcedureReturn
  EndIf
  
  If gbGoToProdPropDevices
    ; do not open cues yet
    debugMsg(sProcName, "exiting because gbGoToProdPropDevices=#True")
    ProcedureReturn
  EndIf
  
  gbInOpenNextCues = #True
  
  LockCueListMutex(311)
  
  grONC2 = rONC2 ; clear all variables in grONC2
  
  setMMediaGaplessSeqPtr()
  ONC_setMyLoopStartAndEndPtrs(nLoopStartCuePtr, nLoopEndCuePtr, nGoCue)
  resetLinks(grONC2\nMyLoopStartCuePtr)
  
  UnlockCueListMutex() ; unlocks 311
  
  ONC_loadReqdAudPtrArrays(nReqdCuePtr)
  ONC_setGaplessAudOpens()
  
  LockCueListMutex(32)
  
  ONC_closeFilesNotPlayingAndNotReqd()
  ONC_setPlayingIndsAndSMSChanCounts(bIgnorePlayingState)
  
  UnlockCueListMutex() ; unlocks 32
  
  ONC_setFileOpenCounts()
  ONC_openCues()
  
  LockCueListMutex(34)
  
  If gnDependencyCue > 0
    If (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND) Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND) And (aCue(gnDependencyCue)\bNonLinearCue))
      ONC_loadDependentCues(gnDependencyCue)
    EndIf
  EndIf
  
  If gbInSetCueToGo = #False
    If bSetCueToGo
      debugMsg(sProcName, "calling setCueToGo(#True, -1, #True, " + strB(bApplyDefaultGridClickAction) + ")")
      setCueToGo(#True, -1, #True, bApplyDefaultGridClickAction)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "calling setLinksForAudsWhereRequested()")
  setLinksForAudsWhereRequested()
  
  ; debugMsg(sProcName, "calling resetSubStatesForSFRsIfReqd()")
  resetSubStatesForSFRsIfReqd()
  
  For i = 1 To gnLastCue
    If aCue(i)\bStopOpenNextCuesHere
      debugMsg(sProcName, "clearing aCue(" + getCueLabel(i) + ")\bStopOpenNextCuesHere")
      aCue(i)\bStopOpenNextCuesHere = #False
    EndIf
  Next i
  
  gbInOpenNextCues = #False
  UnlockCueListMutex() ; unlocks 34

  debugMsg(sProcName, #SCS_END + ", Time in ONC_openNextCues(): " + Str(ElapsedMilliseconds() - qTimeStarted) + " milliseconds, grONC2\nFilesOpenedThisCall=" + grONC2\nFilesOpenedThisCall)
  
EndProcedure

Procedure ONC_setMyLoopStartAndEndPtrs(nLoopStartCuePtr, nLoopEndCuePtr, nGoCue)
  PROCNAMEC()
  Protected i, i2
  
  With grONC2
    If grProd\bPreLoadNextManualOnly
      ; if bPreLoadNextManualOnly then make sure all cues that auto-start directly or indirectly from this cue are included in the loop
      \nMyLoopStartCuePtr = nLoopStartCuePtr   ; changed from nCueToGo to nLoopStartCuePtr to catch any currently-playing playlist that may need the next track loaded
      If \nMyLoopStartCuePtr <= 0
        \nMyLoopStartCuePtr = 1
      EndIf
      If nGoCue = -2
        \nMyLoopEndCuePtr = gnCueToGo
      Else
        \nMyLoopEndCuePtr = nGoCue
      EndIf
      debugMsg(sProcName, "\nMyLoopStartCuePtr=" + \nMyLoopStartCuePtr + ", \nMyLoopEndCuePtr=" + \nMyLoopEndCuePtr + ", nGoCue=" + nGoCue + ", gnCueToGo=" + gnCueToGo)
      debugMsg(sProcName, "\nMyLoopStartCuePtr=" + getCueLabel(\nMyLoopStartCuePtr) + ", \nMyLoopEndCuePtr=" + getCueLabel(\nMyLoopEndCuePtr))
      For i = \nMyLoopStartCuePtr To \nMyLoopEndCuePtr
        If aCue(i)\bStopOpenNextCuesHere
          If aCue(i)\nCueState < #SCS_CUE_COMPLETED
            If \nMyLoopEndCuePtr <> i
              debugMsg(sProcName, "changing \nMyLoopEndCuePtr from " + \nMyLoopEndCuePtr + "(" + getCueLabel(\nMyLoopEndCuePtr) + ") To " + i + "(" + getCueLabel(i) +
                                  ") because aCue(" + getCueLabel(i) + ")\bStopOpenNextCuesHere=#True")
              \nMyLoopEndCuePtr = i
            EndIf
          EndIf
        EndIf
      Next i
      i2 = \nMyLoopStartCuePtr
      While i2 <= \nMyLoopEndCuePtr
        For i = i2 To gnLastCue
          If aCue(i)\nAutoActCueSelType = #SCS_ACCUESEL_PREV
            setCuePtrForAutoStartPrevCueType(i)
          EndIf
          If aCue(i)\nAutoActCuePtr = i2
            If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nActivationMethodReqd = #SCS_ACMETH_AUTO)
              If i > \nMyLoopEndCuePtr
                \nMyLoopEndCuePtr = i
              EndIf
            EndIf
          EndIf
        Next i
        i2 + 1
      Wend
      
    Else ; grProd\bPreLoadNextManualOnly = #False
      \nMyLoopStartCuePtr = nLoopStartCuePtr
      If \nMyLoopStartCuePtr <= 0
        \nMyLoopStartCuePtr = 1
      EndIf
      If nLoopEndCuePtr >= 0
        \nMyLoopEndCuePtr = nLoopEndCuePtr
      ElseIf (gbProcessingSubTypeG) And (nGoCue >= 0)
        \nMyLoopEndCuePtr = nGoCue
      Else
        \nMyLoopEndCuePtr = gnCueEnd - 1
      EndIf
      For i = \nMyLoopStartCuePtr To \nMyLoopEndCuePtr
        If aCue(i)\bStopOpenNextCuesHere
          If aCue(i)\nCueState < #SCS_CUE_COMPLETED
            If \nMyLoopEndCuePtr <> i
              \nMyLoopEndCuePtr = i
            EndIf
          EndIf
        EndIf
      Next i
    EndIf
    
  EndWith
  
EndProcedure

Procedure ONC_loadReqdAudPtrArrays(nReqdCuePtr)
  PROCNAMEC()
  Protected bLockedMutex
  Protected nReqdAudioIndex, nReqdLiveIndex, nReqdMidiIndex, nReqdVideoImageIndex
  Protected i, j, k, n
  Protected nPass, bCheckThis, bPreOpenThisCue, bPlayingAudFound, bPlayingMidiFound, nFirstPlayingPlaylistAudPtr
  Protected nAudPlaybackChannels, nPlaybackChannels, nMyMaxPlaybacks
  
  If gbUseSMS
    If grMMedia\nSMSMaxPlaybacks >= 12
      nMyMaxPlaybacks = grMMedia\nSMSMaxPlaybacks - 2
    Else
      nMyMaxPlaybacks = grMMedia\nSMSMaxPlaybacks
    EndIf
  Else  ; use BASS
    nMyMaxPlaybacks = 999
  EndIf

  With grONC1
    If ArraySize(\aReqdAudioAudPtrs()) < (grGeneralOptions\nMaxPreOpenAudioFiles - 1)
      ReDim \aReqdAudioAudPtrs(grGeneralOptions\nMaxPreOpenAudioFiles - 1)
    EndIf
    nReqdAudioIndex = -1
    For n = 0 To ArraySize(\aReqdAudioAudPtrs())
      \aReqdAudioAudPtrs(n) = -1
    Next n
    
    If ArraySize(\aReqdVideoImageAudPtrs()) < (grGeneralOptions\nMaxPreOpenVideoImageFiles - 1)
      ReDim \aReqdVideoImageAudPtrs(grGeneralOptions\nMaxPreOpenVideoImageFiles - 1)
    EndIf
    nReqdVideoImageIndex = -1
    For n = 0 To ArraySize(\aReqdVideoImageAudPtrs())
      \aReqdVideoImageAudPtrs(n) = -1
    Next n
    
    ; ReDim \aReqdMidiAudPtrs(1)
    nReqdMidiIndex = -1
    For n = 0 To ArraySize(\aReqdMidiAudPtrs())
      \aReqdMidiAudPtrs(n) = -1
    Next n
    
    ; ReDim \aReqdLiveAudPtrs(1)
    nReqdLiveIndex = -1
    For n = 0 To ArraySize(\aReqdLiveAudPtrs())
      \aReqdLiveAudPtrs(n) = -1
    Next n
    
  EndWith
  
  ; Build arrays aReqdAudioAudPtrs, aReqdVideoImageAudPtrs and aReqdMidiAudPtrs with nAudPtrs of files that should be open or opened.
  ; In first pass, check hotkey cues that are playing; in second pass check other cues
  For nPass = 1 To 2
    ; debugMsg(sProcName, "nPass=" + nPass + ", gnCueEnd=" + gnCueEnd)
    For i = 1 To gnLastCue
      ; debugMsg(sProcName, "i=" + getCueLabel(i))
      LockCueListMutex(31)
      ; debugMsg(sProcName, "CueListMutex locked")
      bCheckThis = #False
      If (nPass = 1) And (grProd\bPreOpenNonLinearCues) And (aCue(i)\bNonLinearCue)
        bPreOpenThisCue = #True
      ElseIf i = nReqdCuePtr
        bPreOpenThisCue = #True
      Else
        bPreOpenThisCue = #False
      EndIf
      If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED)
        If nPass = 1
          If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
            bCheckThis = #True
          EndIf
        Else
          If (aCue(i)\nCueState < #SCS_CUE_FADING_IN) Or (aCue(i)\nCueState > #SCS_CUE_FADING_OUT)
            bCheckThis = #True
          EndIf
        EndIf
      EndIf
      If (bCheckThis) Or (bPreOpenThisCue)
        bPlayingAudFound = #False
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            ; debugMsg(sProcName, "checking sub " + getSubLabel(j) + ", \nFirstAudIndex=" + getAudLabel(aSub(j)\nFirstAudIndex) + ", \nFirstPlayIndex=" + getAudLabel(aSub(j)\nFirstPlayIndex))
            If aSub(j)\bSubTypeA  ; \bSubTypeA
              k = aSub(j)\nFirstPlayIndex
              While k >= 0
                With aAud(k)
                  ; debugMsg(sProcName, "checking aud(A) " + getAudLabel(k) + ", \nAudState=" + decodeCueState(aAud(k)\nAudState) + ", bPlayingAudFound=" + strB(bPlayingAudFound))
                  If \nAudState < #SCS_CUE_COMPLETED
                    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT) And (\nAudState <> #SCS_CUE_PAUSED) ; Added paused test 18Feb2025 as a paused aud is not 'playing'
                      bPlayingAudFound = #True
                      If \nFileFormat = #SCS_FILEFORMAT_VIDEO
                        grONC2\bVideoFilePlaying = #True
                      EndIf
                    EndIf
                    If ((nPass = 1) And (bPlayingAudFound)) Or (nPass = 2) Or (bPreOpenThisCue)
                      If (\nFileFormat = #SCS_FILEFORMAT_PICTURE) Or (grONC2\bVideoFilePlaying = #False)
                        If nReqdVideoImageIndex < ArraySize(grONC1\aReqdVideoImageAudPtrs())
                          nReqdVideoImageIndex + 1
                          grONC1\aReqdVideoImageAudPtrs(nReqdVideoImageIndex) = k
                          ; debugMsg(sProcName, "added " + getAudLabel(k) + " to aReqdVideoImageAudPtrs()")
                        ElseIf i = gnCueToGo
                          nReqdVideoImageIndex + 1
                          If nReqdVideoImageIndex > ArraySize(grONC1\aReqdVideoImageAudPtrs())
                            ReDim grONC1\aReqdVideoImageAudPtrs(nReqdVideoImageIndex)
                          EndIf
                          grONC1\aReqdVideoImageAudPtrs(nReqdVideoImageIndex) = k
                          ; debugMsg(sProcName, "added " + getAudLabel(k) + " to aReqdVideoImageAudPtrs()")
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                  k = \nNextPlayIndex
                EndWith
              Wend
              
            ElseIf aSub(j)\bSubTypeF  ; \bSubTypeF
              k = aSub(j)\nFirstPlayIndex
              While k >= 0
                With aAud(k)
                  If (\nAudState < #SCS_CUE_COMPLETED) And (\bReOpenFile = #False)  ; nb if \bReOpenFile = #True then this aud is not to be added to aReqdAudioAudPtrs()
                    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                      bPlayingAudFound = #True
                    EndIf
                    nAudPlaybackChannels = \nFileChannels
                    If nAudPlaybackChannels = 0
                      nAudPlaybackChannels = 2
                    EndIf
                    If \nMaxLoopInfo >= 0 ; \bContainsLoop
                      nAudPlaybackChannels << 1
                    EndIf
                    If ((nPass = 1) And (bPlayingAudFound)) Or (nPass = 2) Or (bPreOpenThisCue)
                      If (\bAudTypeF) And (grONC2\bAudioFilePlaying = #False)
                        nPlaybackChannels + nAudPlaybackChannels
                        If nPlaybackChannels <= nMyMaxPlaybacks
                          If nReqdAudioIndex < ArraySize(grONC1\aReqdAudioAudPtrs())
                            nReqdAudioIndex + 1
                            grONC1\aReqdAudioAudPtrs(nReqdAudioIndex) = k
                          Else ; nReqdAudioIndex >= ArraySize(\aReqdAudioAudPtrs)
                            If \nLinkedToAudPtr > 0
                              For n = 0 To ArraySize(grONC1\aReqdAudioAudPtrs())
                                If grONC1\aReqdAudioAudPtrs(n) = \nLinkedToAudPtr
                                  nReqdAudioIndex + 1
                                  If nReqdAudioIndex > ArraySize(grONC1\aReqdAudioAudPtrs())
                                    ReDim grONC1\aReqdAudioAudPtrs(nReqdAudioIndex)
                                  EndIf
                                  grONC1\aReqdAudioAudPtrs(nReqdAudioIndex) = k
                                  Break
                                EndIf
                              Next n
                            ElseIf bPreOpenThisCue
                              nReqdAudioIndex + 1
                              If nReqdAudioIndex > ArraySize(grONC1\aReqdAudioAudPtrs())
                                ReDim grONC1\aReqdAudioAudPtrs(nReqdAudioIndex)
                              EndIf
                              grONC1\aReqdAudioAudPtrs(nReqdAudioIndex) = k
                              Break
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                  k = \nNextPlayIndex
                EndWith
              Wend
              
            ElseIf aSub(j)\bSubTypeI  ; \bSubTypeI
              k = aSub(j)\nFirstPlayIndex
              While k >= 0
                With aAud(k)
                  ; debugMsg(sProcName, "checking aud(I) " + getAudLabel(k) + ", \nAudState=" + decodeCueState(\nAudState) + ", bPlayingAudFound=" + strB(bPlayingAudFound))
                  If \nAudState < #SCS_CUE_COMPLETED
                    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                      bPlayingAudFound = #True
                    EndIf
                    If ((nPass = 1) And (bPlayingAudFound)) Or (nPass = 2) Or (bPreOpenThisCue)
                      If (\bAudTypeI) And (grONC2\bAudioFilePlaying = #False)
                        If nReqdLiveIndex < ArraySize(grONC1\aReqdLiveAudPtrs())
                          nReqdLiveIndex + 1
                          grONC1\aReqdLiveAudPtrs(nReqdLiveIndex) = k
                          ; debugMsg(sProcName, "aReqdLiveAudPtrs(" + nReqdLiveIndex + ")=" + k + "(" + getAudLabel(k) + ")")
                        Else ; nReqdLiveIndex >= ArraySize(\aReqdLiveAudPtrs)
                          If \nLinkedToAudPtr > 0
                            For n = 0 To ArraySize(grONC1\aReqdLiveAudPtrs())
                              If grONC1\aReqdLiveAudPtrs(n) = \nLinkedToAudPtr
                                nReqdLiveIndex + 1
                                If nReqdLiveIndex > ArraySize(grONC1\aReqdLiveAudPtrs())
                                  ReDim grONC1\aReqdLiveAudPtrs(nReqdLiveIndex)
                                EndIf
                                grONC1\aReqdLiveAudPtrs(nReqdLiveIndex) = k
                                ; debugMsg(sProcName, "aReqdLiveAudPtrs(" + nReqdLiveIndex + ")=" + k + "(" + getAudLabel(k) + ")")
                                Break
                              EndIf
                            Next n
                          ElseIf bPreOpenThisCue
                            nReqdLiveIndex + 1
                            If nReqdAudioIndex > ArraySize(grONC1\aReqdLiveAudPtrs())
                              ReDim grONC1\aReqdLiveAudPtrs(nReqdLiveIndex)
                            EndIf
                            grONC1\aReqdLiveAudPtrs(nReqdLiveIndex) = k
                            Break
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                  k = \nNextPlayIndex
                EndWith
              Wend
              
            ElseIf aSub(j)\bSubTypeM  ; \bSubTypeM
              k = aSub(j)\nFirstPlayIndex
              While k >= 0
                With aAud(k)
                  If \nAudState < #SCS_CUE_COMPLETED
                    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                      bPlayingAudFound = #True
                    EndIf
                    If ((nPass = 1) And (bPlayingMidiFound)) Or (nPass = 2) Or (bPreOpenThisCue)
                      If (\bAudTypeM) And (grONC2\bMidiFilePlaying = #False)
                        If nReqdMidiIndex < ArraySize(grONC1\aReqdMidiAudPtrs())
                          nReqdMidiIndex + 1
                          grONC1\aReqdMidiAudPtrs(nReqdMidiIndex) = k
                        Else ; nReqdMidiIndex >= ArraySize(\aReqdMidiAudPtrs)
                          If \nLinkedToAudPtr > 0
                            For n = 0 To ArraySize(grONC1\aReqdMidiAudPtrs())
                              If grONC1\aReqdMidiAudPtrs(n) = \nLinkedToAudPtr
                                nReqdMidiIndex + 1
                                If nReqdMidiIndex > ArraySize(grONC1\aReqdMidiAudPtrs())
                                  ReDim grONC1\aReqdMidiAudPtrs(nReqdMidiIndex)
                                EndIf
                                grONC1\aReqdMidiAudPtrs(nReqdMidiIndex) = k
                                Break
                              EndIf
                            Next n
                          ElseIf bPreOpenThisCue
                            nReqdMidiIndex + 1
                            If nReqdMidiIndex > ArraySize(grONC1\aReqdMidiAudPtrs())
                              ReDim grONC1\aReqdMidiAudPtrs(nReqdMidiIndex)
                            EndIf
                            grONC1\aReqdMidiAudPtrs(nReqdMidiIndex) = k
                            Break
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                  k = \nNextPlayIndex
                EndWith
              Wend
              
            ElseIf aSub(j)\bSubTypeP  ; \bSubTypeP
              nFirstPlayingPlaylistAudPtr = -1
              If aSub(j)\nFirstPlayIndexThisRun >= 0
                k = aSub(j)\nFirstPlayIndexThisRun
              Else
                k = aSub(j)\nFirstPlayIndex
              EndIf
              ; debugMsg(sProcName, "k=" + getAudLabel(k) + ", aSub(" + getSubLabel(j) + ")\nCurrPlayIndex=" + getAudLabel(aSub(j)\nCurrPlayIndex) +
              ;                     ", \nFirstPlayIndexThisRun=" + getAudLabel(aSub(j)\nFirstPlayIndexThisRun))
              While k >= 0
                With aAud(k)
                  If (\nAudState < #SCS_CUE_COMPLETED) And (\bReOpenFile = #False)  ; nb if \bReOpenFile = #True then this aud is not to be added to aReqdAudioAudPtrs()
                    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
                      bPlayingAudFound = #True
                      If nFirstPlayingPlaylistAudPtr = -1
                        nFirstPlayingPlaylistAudPtr = k
                      EndIf
                    EndIf
                    nAudPlaybackChannels = \nFileChannels
                    If nAudPlaybackChannels = 0
                      nAudPlaybackChannels = 2
                    EndIf
                    If ((nPass = 1) And (bPlayingAudFound)) Or (nPass = 2) Or (bPreOpenThisCue)
                      If nFirstPlayingPlaylistAudPtr < 0
                        If aSub(j)\nCurrPlayIndex < 0
                          nFirstPlayingPlaylistAudPtr = aSub(j)\nFirstPlayIndex
                        Else
                          nFirstPlayingPlaylistAudPtr = aSub(j)\nCurrPlayIndex
                        EndIf
                      EndIf
                      If nFirstPlayingPlaylistAudPtr >= 0
                        If k = nFirstPlayingPlaylistAudPtr Or \nPrevPlayIndex = nFirstPlayingPlaylistAudPtr
                          nPlaybackChannels + nAudPlaybackChannels
                          If nPlaybackChannels <= nMyMaxPlaybacks
                            If nReqdAudioIndex < ArraySize(grONC1\aReqdAudioAudPtrs())
                              nReqdAudioIndex + 1
                              grONC1\aReqdAudioAudPtrs(nReqdAudioIndex) = k
                            Else ; nReqdAudioIndex >= ArraySize(\aReqdAudioAudPtrs)
                              If \nLinkedToAudPtr > 0
                                For n = 0 To ArraySize(grONC1\aReqdAudioAudPtrs())
                                  If grONC1\aReqdAudioAudPtrs(n) = \nLinkedToAudPtr
                                    nReqdAudioIndex + 1
                                    If nReqdAudioIndex > ArraySize(grONC1\aReqdAudioAudPtrs())
                                      ReDim grONC1\aReqdAudioAudPtrs(nReqdAudioIndex)
                                    EndIf
                                    grONC1\aReqdAudioAudPtrs(nReqdAudioIndex) = k
                                    Break
                                  EndIf
                                Next n
                              EndIf
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                  k = \nNextPlayIndex
                EndWith
              Wend
            EndIf
          EndIf ; EndIf aSub(j)\bSubEnabled
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      UnlockCueListMutex()
    Next i
  Next nPass
  
  With grONC1
    CompilerIf #cTraceReqdPtrs
      For n = 0 To ArraySize(\aReqdAudioAudPtrs())
        If \aReqdAudioAudPtrs(n) >= 0
          debugMsg(sProcName, "aReqdAudioAudPtrs(" + n + ")=" + getAudLabel(\aReqdAudioAudPtrs(n)))
        EndIf
      Next n
      For n = 0 To ArraySize(\aReqdMidiAudPtrs())
        If \aReqdMidiAudPtrs(n) >= 0
          debugMsg(sProcName, "aReqdMidiAudPtrs(" + n + ")=" + getAudLabel(\aReqdMidiAudPtrs(n)))
        EndIf
      Next n
      For n = 0 To ArraySize(\aReqdVideoImageAudPtrs())
        If \aReqdVideoImageAudPtrs(n) >= 0
          debugMsg(sProcName, "aReqdVideoImageAudPtrs(" + n + ")=" + getAudLabel(\aReqdVideoImageAudPtrs(n)))
        EndIf
      Next n
      For n = 0 To ArraySize(\aReqdLiveAudPtrs())
        If \aReqdLiveAudPtrs(n) >= 0
          debugMsg(sProcName, "aReqdLiveAudPtrs(" + n + ")=" + getAudLabel(\aReqdLiveAudPtrs(n)))
        EndIf
      Next n
    CompilerEndIf
  EndWith

EndProcedure

Procedure ONC_setGaplessAudOpens()
  PROCNAMEC()
  Protected n, nAudPtr, nGaplessSeqPtr
  
  For n = 0 To gnGaplessSeqCount - 1
    gaGaplessSeqs(n)\bAtLeastOneAudOpenForGaplessSeq = #False
  Next n
  With grONC1
    For n = 0 To ArraySize(\aReqdAudioAudPtrs())
      nAudPtr = \aReqdAudioAudPtrs(n)
      If nAudPtr >= 0
        nGaplessSeqPtr = aAud(nAudPtr)\nAudGaplessSeqPtr
        If nGaplessSeqPtr >= 0
          gaGaplessSeqs(nGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq = #True
        EndIf
      EndIf
    Next n
    For n = 0 To ArraySize(\aReqdVideoImageAudPtrs())
      nAudPtr = \aReqdVideoImageAudPtrs(n)
      If nAudPtr >= 0
        nGaplessSeqPtr = aAud(nAudPtr)\nAudGaplessSeqPtr
        If nGaplessSeqPtr >= 0
          gaGaplessSeqs(nGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq = #True
        EndIf
      EndIf
    Next n
  EndWith
  
EndProcedure

Procedure ONC_closeFilesNotPlayingAndNotReqd()
  PROCNAMEC()
  Protected i, j, k, n, n2
  Protected nTmpAudPtr, nCurrEditAudPtr, bCloseThis
  Protected bTrace
  
  debugMsgC(sProcName, #SCS_START + ", gbEditing=" + strB(gbEditing) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  If gbEditing
    nCurrEditAudPtr = nEditAudPtr
  Else
    nCurrEditAudPtr = -1
  EndIf
  
  ; Now close any open video file that is not currently playing
  For n = 0 To ArraySize(grVidPicTarget())
    nTmpAudPtr = grVidPicTarget(n)\nPrimaryAudPtr
    If nTmpAudPtr > 0
      If aAud(nTmpAudPtr)\bLogo = #False ; Test added 9Jan2025 11.10.6-b02 as part of the fix for logos not to be displayed using 2D Drawing if the sub's bUseNew2DDrawing=#False
        If checkIfMovie(grVidPicTarget(n)\nMovieNo, nTmpAudPtr)
          If (aAud(nTmpAudPtr)\nAudState <= #SCS_CUE_READY) Or (aAud(nTmpAudPtr)\nAudState > #SCS_CUE_FADING_OUT)
            bCloseThis = #True
            For n2 = 0 To ArraySize(grONC1\aReqdVideoImageAudPtrs())
              If grONC1\aReqdVideoImageAudPtrs(n2) = nTmpAudPtr
                bCloseThis = #False
                Break
              EndIf
            Next n2
            If bCloseThis
              debugMsg(sProcName, "calling closeVideo(" + getAudLabel(nTmpAudPtr) + "), \nAudState=" + decodeCueState(aAud(nTmpAudPtr)\nAudState))
              closeVideo(nTmpAudPtr) ; nb includes a call to setCueState()
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  Next n
  
  ; Now close any open Audio file, live input or MIDI file where the aud is not 'required' and is not currently playing (except hotkeys)
  LABEL(2000)
  For i = 1 To gnLastCue
    bTrace = aCue(i)\bLogInONCCloseFilesNotReqd
    debugMsgC(sProcName, "aCue(" + getCueLabel(i) + ")\bKeepOpen=" + strB(aCue(i)\bKeepOpen) + ", \bCueContainsGapless=" + strB(aCue(i)\bCueContainsGapless))
    If aCue(i)\bKeepOpen = #False
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeHasAuds
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            With aAud(k)
              debugMsgC(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", \nFileState=" + decodeFileState(\nFileState))
              If (k <> nCurrEditAudPtr) And (\nFileState = #SCS_FILESTATE_OPEN)
                If (\nAudState <= #SCS_CUE_READY) Or (\nAudState > #SCS_CUE_FADING_OUT)
                  bCloseThis = #True
                  
                  If \bAudTypeForP
                    For n = 0 To ArraySize(grONC1\aReqdAudioAudPtrs())
                      If grONC1\aReqdAudioAudPtrs(n) = k
                        bCloseThis = #False
                        debugMsgC(sProcName, "bCloseThis=" + strB(bCloseThis) + " because grONC1\aReqdAudioAudPtrs(" + n + ")=" + getAudLabel(k))
                        Break
                      EndIf
                    Next n
                    
                  ElseIf \bAudTypeI
                    For n = 0 To ArraySize(grONC1\aReqdLiveAudPtrs())
                      If grONC1\aReqdLiveAudPtrs(n) = k
                        bCloseThis = #False
                        debugMsgC(sProcName, "bCloseThis=" + strB(bCloseThis) + " because grONC1\aReqdLiveAudPtrs(" + n + ")=" + getAudLabel(k))
                        Break
                      EndIf
                    Next n
                    
                  ElseIf \bAudTypeM
                    For n = 0 To ArraySize(grONC1\aReqdMidiAudPtrs())
                      If grONC1\aReqdMidiAudPtrs(n) = k
                        bCloseThis = #False
                        debugMsgC(sProcName, "bCloseThis=" + strB(bCloseThis) + " because grONC1\aReqdMidiAudPtrs(" + n + ")=" + getAudLabel(k))
                        Break
                      EndIf
                    Next n
                    
                  ElseIf \bAudTypeP
                    For n = 0 To ArraySize(grONC1\aReqdAudioAudPtrs())
                      If grONC1\aReqdAudioAudPtrs(n) = k
                        bCloseThis = #False
                        debugMsgC(sProcName, "bCloseThis=" + strB(bCloseThis) + " because grONC1\aReqdAudioAudPtrs(" + n + ")=" + getAudLabel(k))
                        Break
                      EndIf
                    Next n
                    
                  Else
                    ; eg \bAudTypeA
                    bCloseThis = #False
                    debugMsgC(sProcName, "bCloseThis=" + strB(bCloseThis))
                    
                  EndIf
                  
                  If bCloseThis
                    debugMsg(sProcName, "aCue(" + getCueLabel(\nCueIndex) + ")\nCueState=" + decodeCueState(aCue(\nCueIndex)\nCueState) + ", aSub(" + getSubLabel(\nSubIndex) + ")\nSubState" + decodeCueState(aSub(\nSubIndex)\nSubState) + ", \nSubStart=" + decodeSubStart(aSub(\nSubIndex)\nSubStart))
                    debugMsg(sProcName, "calling closeAud(" + getAudLabel(k) + ", #True), \nAudState=" + decodeCueState(aAud(k)\nAudState))
                    closeAud(k, #True)
                    setCueState(\nCueIndex)
                  EndIf
                  
                EndIf ; EndIf (\nAudState <= #SCS_CUE_READY) Or (\nAudState > #SCS_CUE_FADING_OUT)
              EndIf ; EndIf (k <> nCurrEditAudPtr) And (\nFileState = #SCS_FILESTATE_OPEN)
            EndWith
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf ; EndIf aSub(j)\bSubTypeHasAuds
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bKeepOpen = #False
  Next i

EndProcedure

Procedure ONC_setPlayingIndsAndSMSChanCounts(bIgnorePlayingState)
  PROCNAMEC()
  Protected i, j, k
  Protected nAudCount, bKeepOpen, nMaxSMSPChansReqd
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      nAudCount = 0
      nMaxSMSPChansReqd = 0
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          nAudCount + 1
          With aAud(k)
            If gbUseSMS
              bKeepOpen = aCue(i)\bKeepOpen
              If bKeepOpen
                If \nSMSPChansReqd > nMaxSMSPChansReqd
                  nMaxSMSPChansReqd = \nSMSPChansReqd
                EndIf
              EndIf
              If (\nFileState = #SCS_FILESTATE_OPEN)
                If \bAudTypeForP
                  If bKeepOpen
                    grONC2\nSMSPChanCountHK + \nSMSPChanCount
                  Else
                    grONC2\nSMSPChanCountNonHK + \nSMSPChanCount
                  EndIf
                EndIf
              EndIf
            EndIf
            
            If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
              If bIgnorePlayingState = #False
                ; do not check playlists or pictures
                If \bAudTypeF
                  grONC2\bAudioFilePlaying = #True
                ElseIf \bAudTypeA
                  If \nFileFormat = #SCS_FILEFORMAT_VIDEO And \nAudState <> #SCS_CUE_PAUSED ; Added paused test 18Feb2025 as a paused aud is not 'playing'
                    grONC2\bVideoFilePlaying = #True
                  EndIf
                ElseIf \bAudTypeI
                  grONC2\bLiveInputPlaying = #True
                ElseIf \bAudTypeM
                  grONC2\bMidiFilePlaying = #True
                EndIf
              EndIf
              
            ElseIf aCue(\nCueIndex)\nCueState = #SCS_CUE_COUNTDOWN_TO_START
              If bIgnorePlayingState = #False
                If (aCue(\nCueIndex)\qTimeToStartCue - gqTimeNow) < 1000
                  ; due to start within the next second, so treat as 'playing'
                  ; do not check playlists or pictures
                  If \bAudTypeF
                    grONC2\bAudioFilePlaying = #True
                  ElseIf \bAudTypeA
                    If \nFileFormat = #SCS_FILEFORMAT_VIDEO
                      grONC2\bVideoFilePlaying = #True
                    EndIf
                  ElseIf \bAudTypeI
                    grONC2\bLiveInputPlaying = #True
                  ElseIf \bAudTypeM
                    grONC2\bMidiFilePlaying = #True
                  EndIf
                EndIf
              EndIf
              
            ElseIf aSub(\nSubIndex)\nSubState = #SCS_CUE_SUB_COUNTDOWN_TO_START
              If bIgnorePlayingState = #False
                If (aSub(\nSubIndex)\qTimeToStartSub - gqTimeNow) < 1000
                  ; due to start within the next second, so treat as 'playing'
                  ; do not check playlists or pictures
                  If \bAudTypeF
                    grONC2\bAudioFilePlaying = #True
                  ElseIf \bAudTypeA
                    If \nFileFormat = #SCS_FILEFORMAT_VIDEO
                      grONC2\bVideoFilePlaying = #True
                    EndIf
                  ElseIf \bAudTypeI
                    grONC2\bLiveInputPlaying = #True
                  ElseIf \bAudTypeM
                    grONC2\bMidiFilePlaying = #True
                  EndIf
                EndIf
              EndIf
            EndIf
          EndWith
          k = aAud(k)\nNextAudIndex
        Wend
        If (aSub(j)\bSubTypeP) And (nAudCount > 1)
          grONC2\nSMSPChansReqdHK + (nMaxSMSPChansReqd + nMaxSMSPChansReqd)
        Else
          grONC2\nSMSPChansReqdHK + nMaxSMSPChansReqd
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  LABEL(2005)
  If gbUseSMS
    grONC2\nSMSPChansAvailableForNonHK = grMMedia\nSMSMaxPlaybacks - grONC2\nSMSPChansReqdHK
    If grONC2\nSMSPChansAvailableForNonHK < grDriverSettings\nMinPChansNonHK
      LABEL(2010)
      grONC2\nSMSPChansAvailableForNonHK = grDriverSettings\nMinPChansNonHK
      debugMsg(sProcName, "gnLabelOther=" + gnLabelOther + " grONC2\nSMSPChanCountNonHK=" + grONC2\nSMSPChanCountNonHK + " \nSMSPChanCountHK=" + grONC2\nSMSPChanCountHK +
                          ", \nSMSPChansReqdHK=" + grONC2\nSMSPChansReqdHK + ", 'nSMSPChansAvailableForNonHK=" + grONC2\nSMSPChansAvailableForNonHK)
      ; NOTE: may need to close at least one hotkey cue, so close all non-playing hotkey cues
      For i = 1 To gnLastCue
        If (aCue(i)\bHotkey) Or (aCue(i)\bExtAct) Or (aCue(i)\bCallableCue)
          If aCue(i)\nCueState = #SCS_CUE_READY
            If aCue(i)\bSubTypeForP Or aCue(i)\bSubTypeI
              debugMsg(sProcName, "gnLabelOther=" + gnLabelOther + " calling closeCue(" + getCueLabel(i) + ")")
              closeCue(i, #True)
            EndIf
          EndIf
        EndIf
      Next i
      ; re-calculate nSMSPChanCountHK and nSMSPChanCountNonHK
      grONC2\nSMSPChanCountHK = 0
      grONC2\nSMSPChanCountNonHK = 0
      For i = 1 To gnLastAud
        If aCue(i)\bSubTypeForP
          j = aCue(i)\nFirstSubIndex
          While J >= 0
            If aSub(j)\bSubTypeForP
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                With aAud(k)
                  If \nFileState = #SCS_FILESTATE_OPEN
                    If (aCue(\nCueIndex)\bHotkey) Or (aCue(\nCueIndex)\bExtAct) Or (aCue(\nCueIndex)\bCallableCue)
                      grONC2\nSMSPChanCountHK + \nSMSPChanCount
                    Else
                      grONC2\nSMSPChanCountNonHK + \nSMSPChanCount
                    EndIf
                  EndIf
                  k = \nNextAudIndex
                EndWith
              Wend
            EndIf ; EndIf aSub(j)\bSubTypeForP
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf ; EndIf aCue(i)\bSubTypeForP
      Next i
      LABEL(2015)
      debugMsg(sProcName, "gnLabelOther=" + gnLabelOther + " grONC2\nSMSPChanCountNonHK=" + grONC2\nSMSPChanCountNonHK + " \nSMSPChanCountHK=" + grONC2\nSMSPChanCountHK)
    Else
      LABEL(2020)
      debugMsg(sProcName, "gnLabelOther=" + gnLabelOther + " grONC2\nSMSPChanCountNonHK=" + grONC2\nSMSPChanCountNonHK + " \nSMSPChanCountHK=" + grONC2\nSMSPChanCountHK +
                          ", \nSMSPChansReqdHK=" + grONC2\nSMSPChansReqdHK + ", \nSMSPChansAvailableForNonHK=" + grONC2\nSMSPChansAvailableForNonHK)
    EndIf
  EndIf ; EndIf gbUseSMS
  
EndProcedure

Procedure ONC_setFileOpenCounts()
  PROCNAMEC()
  Protected i, j, k
  
  If gnLastAud > ArraySize(grONC1\bOpenAudCounted())
    ReDim grONC1\bOpenAudCounted(gnLastAud)
  EndIf
  For k = 0 To gnLastAud
    grONC1\bOpenAudCounted(k) = #False
  Next k
  
  ; Prime nAudioFilesOpen, nVideoImageFilesOpen and nMidiFilesOpen
  For i = 1 To gnLastCue
    If aCue(i)\nCueState >= #SCS_CUE_READY And aCue(i)\nCueState < #SCS_CUE_COMPLETED
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeHasAuds
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            If aAud(k)\nFileState = #SCS_FILESTATE_OPEN
              Select aAud(k)\nFileFormat
                Case #SCS_FILEFORMAT_AUDIO
                  grONC2\nAudioFilesOpen + 1
                  grONC1\bOpenAudCounted(k) = #True
                Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_VIDEO
                  grONC2\nVideoImageFilesOpen + 1
                  grONC1\bOpenAudCounted(k) = #True
                Case #SCS_FILEFORMAT_MIDI
                  grONC2\nMidiFilesOpen + 1
                  grONC1\bOpenAudCounted(k) = #True
              EndSelect
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  With grONC2
    If \nAudioFilesOpen > 0 Or \nVideoImageFilesOpen > 0 Or \nMidiFilesOpen > 0
      debugMsg(sProcName, "grONC2\nAudioFilesOpen=" + \nAudioFilesOpen + ", \nVideoImageFilesOpen=" + \nVideoImageFilesOpen + ", \nMidiFilesOpen=" + \nMidiFilesOpen)
    EndIf
  EndWith
  
EndProcedure

Procedure ONC_openCues()
  PROCNAMEC()
  Protected bLockedMutex
  Protected nPass
  Protected d, i, j, k, n
  Protected bCheckThis, bKeepOpen, bOpenThis
  Protected bSetLinksForCueCalled, bSubProcessed
  Protected nThisCueBracket, nFirstActiveCueBracket
  Protected bUpdateGrid, bAtLeastOneAudOpenForThisCue, bPlayingAudFound
  Protected nFilesOpenForThisPlaylist, nPlaylistPass
  Protected bPrevPlayAudOpen
  Protected bIncrementCounts
  Protected bTVG_OpenPlayerFailed
  Protected bOpenMediaResult, nVidPicTarget, nPhysicalDevPtr
  Protected bRunOutOfSMSPlaybacks
  Protected bResetMTCLinksForAllCues
  Protected sLogicalDev.s, nDevMapDevPtr, nFirst0BasedInputChan, sSMSCommand.s, sSMSPlaybackChans.s, nGroup, sTimeCode.s
  Static sOpening.s, bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sOpening = Lang("WLP", "Opening")
    bStaticLoaded = #True
  EndIf
  
  CompilerIf #c_vMix_in_video_cues
    grvMixInfo\bInputLimitReached = #False
  CompilerEndIf
  
  For nPass = 1 To 2
    ; debugMsg(sProcName, "nPass=" + nPass)
    For i = 1 To gnLastCue
      LockCueListMutex(33)
      bCheckThis = #False
      bSetLinksForCueCalled = #False
      If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED)
        If nPass = 1
          If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
            bCheckThis = #True
          EndIf
        Else
          bCheckThis = #True
        EndIf
      EndIf
      If bCheckThis
        If grProd\bPreLoadNextManualOnly
          nThisCueBracket = getCueBracket(i)
          nFirstActiveCueBracket = getFirstActiveCueBracket()
          ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", nThisCueBracket=" + nThisCueBracket + ", nFirstActiveCueBracket=" + nFirstActiveCueBracket)
          If (nThisCueBracket >= 0) And (nFirstActiveCueBracket >= 0)
            If nThisCueBracket <> nFirstActiveCueBracket
              ; debugMsg(sProcName, "setting bCheckThis=#False because nThisCueBracket=" + nThisCueBracket + " but nFirstActiveCueBracket=" + nFirstActiveCueBracket)
              bCheckThis = #False
            EndIf
          EndIf
        EndIf
      EndIf
      
      ; debugMsg(sProcName, "nPass=" + nPass + ", aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState) + ", bCheckThis=" + strB(bCheckThis))
      If bCheckThis
        bUpdateGrid = #False
        bAtLeastOneAudOpenForThisCue = #False
        bPlayingAudFound = #False
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          bSubProcessed = #False
          nFilesOpenForThisPlaylist = 0
          ; debugMsg(sProcName, getSubLabel(j) + ", nPass=" + nPass + ", nFilesOpenForThisPlaylist=" + nFilesOpenForThisPlaylist)
          nPlaylistPass = 1
          bPrevPlayAudOpen = #False
          bKeepOpen = aCue(i)\bKeepOpen
          CompilerIf #c_vMix_in_video_cues
            If (aSub(j)\bSubTypeA) And (aSub(j)\bSubEnabled)
              If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
                If aSub(j)\nAudCount > 1
                  vMixBuildVideoList(j)
                  bSubProcessed = #True
                EndIf
              EndIf
            EndIf
          CompilerEndIf
          If aSub(j)\bSubTypeA
            setNew2DDrawingInd(j)
          EndIf
          If (aSub(j)\bSubTypeHasAuds) And (aSub(j)\bSubEnabled) And (bSubProcessed = #False)
            If aSub(j)\bSubTypeAorP
              k = aSub(j)\nCurrPlayIndex
            Else
              k = aSub(j)\nFirstPlayIndex
            EndIf
            While k >= 0
              With aAud(k)
                bIncrementCounts = #True
                If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState < #SCS_CUE_FADING_OUT)
                  bPlayingAudFound = #True
                EndIf
                If \nFileState = #SCS_FILESTATE_CLOSED
                  ;{
                  If ((i >= (grONC2\nMyLoopStartCuePtr-1)) And (i <= grONC2\nMyLoopEndCuePtr)) Or (aCue(i)\bKeepOpen Or aCue(i)\bExtAct Or aCue(i)\bCallableCue)
                    If (\nAudState < #SCS_CUE_COMPLETED) Or (bKeepOpen) Or (grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL) Or ((grProd\nRunMode = #SCS_RUN_MODE_BOTH_PREOPEN_ALL) And (aCue(i)\bNonLinearCue))
                      bOpenThis = #False
                      If (nPass = 1 And bPlayingAudFound) Or (nPass = 2)
                        If \bAudTypeI
                          bOpenThis = #True
                        EndIf
                        If (\bAudTypeF) And (grONC2\nAudioFilesOpen < grGeneralOptions\nMaxPreOpenAudioFiles) And (grONC2\bAudioFilePlaying = #False)
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) +
                                              ", grONC2\nAudioFilesOpen=" + grONC2\nAudioFilesOpen + ", grGeneralOptions\nMaxPreOpenAudioFiles=" + grGeneralOptions\nMaxPreOpenAudioFiles)
                        EndIf
                        
                        ; Added 4Nov2024 11.10.6be following issue reported by André Grohmann about MTC not starting which was because an MTC sub-cue was linked to an Audio File sub-cue that had not been opened due to the file open limit reached
                        If \nCueIndex = gnCueToGo
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) +
                                              ", \nCueIndex=" + getCueLabel(\nCueIndex) + ", gnCueToGo=" + getCueLabel(gnCueToGo))
                        EndIf
                        ; End added 4Nov2024 11.10.6be
                          
                        If bOpenThis
                          ; Skip the remaining tests as we have already set bOpenThis=#True
                          
                        CompilerIf #c_vMix_in_video_cues
                        ElseIf \bAudTypeA And grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX And grvMixInfo\bInputLimitReached
                          bOpenThis = #False
                          If nPass = 2 ; nb test nPass to avoid logging this message in both passes
                            debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", grvMixInfo\bInputLimitReached=" + strB(grvMixInfo\bInputLimitReached))
                          EndIf
                        CompilerEndIf
                          
                        ElseIf ((\bAudTypeF) And (grONC2\nAudioFilesOpen < grGeneralOptions\nMaxPreOpenAudioFiles) And (grONC2\nAudioFilesOpen <= 2))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", grONC2\nAudioFilesOpen=" + grONC2\nAudioFilesOpen)
                          
                        ElseIf ((\bAudTypeM) And (grONC2\nMidiFilesOpen <= 5))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          
                        ElseIf ((\bAudTypeP) And (grONC2\nAudioFilesOpen < grGeneralOptions\nMaxPreOpenAudioFiles) And (nFilesOpenForThisPlaylist < 2))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", grONC2\nAudioFilesOpen=" + grONC2\nAudioFilesOpen)
                          
                        ElseIf ((bKeepOpen) And ((\bAudTypeF) Or (\bAudTypeM)))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          
                        ElseIf ((bKeepOpen) And (\bAudTypeAorP) And (nFilesOpenForThisPlaylist < 2))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          
                          ; Added 16Apr2020 11.8.2.3av following analysis of runs of 'BlastOff.scs11' from Theo Anderson (Scitech WA)
                        ElseIf (\bAudTypeA) And (nFilesOpenForThisPlaylist = 1)
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          ; End added 16Apr2020 11.8.2.3av
                          
                        ElseIf (\nFileFormat = #SCS_FILEFORMAT_CAPTURE) Or (\nVideoSource = #SCS_VID_SRC_CAPTURE)
                          ; Video Capture Section
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          
                        ElseIf (\nFileFormat = #SCS_FILEFORMAT_VIDEO) And
                               (checkOKToOpenVideoFile(k)) And
                               (nFilesOpenForThisPlaylist < 2) And
                               ((grONC2\bVideoFilePlaying = #False) Or (nPass = 2)) And
                               (gbPictureBlending = #False)
                          bOpenThis = #True
                          If (grONC2\bVideoFilePlaying) And (nPass = 2) And (countReadyVideos() > 0) And (grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX)
                            bOpenThis = #False
                          EndIf
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", grONC2\bVideoFilePlaying=" + strB(grONC2\bVideoFilePlaying) + ", nPass=" + nPass)
                          
                        ElseIf (\nFileFormat = #SCS_FILEFORMAT_PICTURE) And
                               (grONC2\nVideoImageFilesOpen < grGeneralOptions\nMaxPreOpenVideoImageFiles) And
                               (nFilesOpenForThisPlaylist < 2) And
                               (gbPictureBlending = #False) And
                               (bTVG_OpenPlayerFailed = #False)
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", grONC2\nVideoImageFilesOpen=" + grONC2\nVideoImageFilesOpen)
                          
                        ElseIf (\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (\bOpenWithPrevAud) And (bPrevPlayAudOpen) And (bTVG_OpenPlayerFailed = #False)
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", grONC2\nVideoImageFilesOpen=" + grONC2\nVideoImageFilesOpen)
                          
                        ElseIf ((\bAudTypeF) And (bAtLeastOneAudOpenForThisCue))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          
                        ElseIf ((\bAudTypeP) And (bAtLeastOneAudOpenForThisCue) And (nFilesOpenForThisPlaylist < 2))
                          bOpenThis = #True
                          debugMsg(sProcName, "bOpenThis=" + strB(bOpenThis) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          
                        EndIf
                      EndIf
                      
                      If aCue(i)\bNoPreLoad
                        bOpenThis = #False
                      EndIf
                      
                      If bOpenThis
                        If grWMI\bFormActive
                          WMI_displayInfoMsg2(ReplaceString(sOpening, "$1", getAudLabel(k)))
                        EndIf
                        If \bAudTypeA
                          If \bAudUseGaplessStream
                            If checkOKToOpenGaplessVideo(k) = #False
                              bOpenThis = #False
                            EndIf
                          EndIf
                        EndIf
                        If \bAudTypeForP
                          If gbUseSMS
                            If bRunOutOfSMSPlaybacks ; Added 27Dec2022 11.9.8aa
                              debugMsg(sProcName, "setting bOpenThis #False because bRunOutOfSMSPlaybacks") ; Added 27Dec2022 11.9.8aa
                              bOpenThis = #False ; Added 27Dec2022 11.9.8aa
                            ElseIf bKeepOpen
                              If (grONC2\nSMSPChanCountHK + grONC2\nSMSPChanCountNonHK + \nSMSPChansReqd) > grMMedia\nSMSMaxPlaybacks
                                debugMsg(sProcName, "setting bOpenThis #False due to insufficient remaining playbacks. grONC2\nSMSPChanCountHK=" + grONC2\nSMSPChanCountHK + "grONC2\nSMSPChanCountNonHK=" + grONC2\nSMSPChanCountNonHK +
                                                    ", aAud(" + getAudLabel(k) + ")\nSMSPChansReqd=" + \nSMSPChansReqd + ", grMMedia.nSMSMaxPlaybacks=" + grMMedia\nSMSMaxPlaybacks)
                                bOpenThis = #False
                              EndIf
                            Else
                              If (grONC2\nSMSPChanCountNonHK + \nSMSPChansReqd) > grONC2\nSMSPChansAvailableForNonHK
                                debugMsg(sProcName, "setting bOpenThis False due to insufficient remaining playbacks. grONC2\nSMSPChanCountNonHK=" + grONC2\nSMSPChanCountNonHK +
                                                    ", aAud(" + getAudLabel(k) + ")\nSMSPChansReqd=" + \nSMSPChansReqd + ", grONC2\nSMSPChansAvailableForNonHK=" + grONC2\nSMSPChansAvailableForNonHK)
                                bOpenThis = #False
                              EndIf
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                      
                      ; debugMsg(sProcName, \sAudLabel + " >>>>>>>>>>>>> bOpenThis=" + strB(bOpenThis))
                      If bOpenThis
                        If \bAudTypeI
                          bOpenMediaResult = openInputChannels(k)
                          debugMsg(sProcName, \sAudLabel + ", bOpenMediaResult=" + strB(bOpenMediaResult) + ", \nAudState=" + decodeCueState(\nAudState) + ", \nSubState=" + decodeCueState(aSub(\nSubIndex)\nSubState))
                          bUpdateGrid = #True
                          If bOpenMediaResult
                            bAtLeastOneAudOpenForThisCue = #True
                            debugMsg(sProcName, "bAtLeastOneAudOpenForThisCue=" + strB(bAtLeastOneAudOpenForThisCue))
                          EndIf
                          
                        ElseIf (\bAudTypeA) And (\nVideoSource = #SCS_VID_SRC_CAPTURE)
                          ; Here is where we handle opening the source capture device
                          nVidPicTarget = getVidPicTargetForOutputScreen(aSub(j)\nOutputScreen)
                          Select grVideoDriver\nVideoPlaybackLibrary
                            Case #SCS_VPL_TVG
                              ; Here is where we handle opening the source capture device
                              debugMsg(sProcName, "calling openVideoCaptureDevForTVG(" + getAudLabel(k) + ", " + decodeVidPicTarget(nVidPicTarget) + ")")
                              nPhysicalDevPtr = openVideoCaptureDevForTVG(k, nVidPicTarget)
                              debugMsg(sProcName, "openVideoCaptureDevForTVG(" + getAudLabel(k) + ", " + decodeVidPicTarget(nVidPicTarget) + ") returned nPhysicalDevPtr=" + nPhysicalDevPtr)
                            Case #SCS_VPL_VMIX
                              CompilerIf #c_vMix_in_video_cues
                                bOpenMediaResult = openMediaFile(k, #False, nVidPicTarget)
                              CompilerEndIf
                          EndSelect
                          
                        ElseIf Trim(\sFileName)
                          ; debugMsg(sProcName, "~~ " + \sAudLabel + ", calling openMediaFile(" + getAudLabel(k) + ") For " + \sStoredFileName)
                          If \bAudTypeA
                            nVidPicTarget = getVidPicTargetForOutputScreen(aSub(j)\nOutputScreen)
                            bOpenMediaResult = openMediaFile(k, #False, nVidPicTarget)
                            If bOpenMediaResult = #False
                              If \bTVG_OpenPlayerFailed
                                bTVG_OpenPlayerFailed = #True
                                debugMsg(sProcName, "k=" + getAudLabel(k) + ", bTVG_OpenPlayerFailed=" + strB(bTVG_OpenPlayerFailed))
                              EndIf
                            EndIf
                            
                          ElseIf \bAudTypeM
                            bOpenMediaResult = openMediaFile(k)
                            
                          Else
                            ; Commented out this test 21Oct2021 11.8.6bd - not sure why the test was here, and why the bRunOutOfSMSPlaybacks test was reversed.
                            ; ; If (gbUseSMS = #False) Or (gbUseSMS And bRunOutOfSMSPlaybacks = #False)
                            ; If (gbUseSMS = #False) Or (gbUseSMS And bRunOutOfSMSPlaybacks)
                              If bSetLinksForCueCalled = #False
                                setLinksForCue(i)
                                setLinksForAudsWithinSubsForCue(i)
                                buildAudSetArray()
                                bSetLinksForCueCalled = #True
                                bResetMTCLinksForAllCues = #True
                              EndIf
                              debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(k) + "), \nAudState=" + decodeCueState(\nAudState) +
                                                  ", \nSubState=" + decodeCueState(aSub(\nSubIndex)\nSubState) +
                                                  ", \nCueState=" + decodeCueState(aCue(\nCueIndex)\nCueState))
                              bOpenMediaResult = openMediaFile(k, #False, #SCS_VID_PIC_TARGET_NONE, #False, #True)
                              ; Else
                              ;   bOpenMediaResult = #False
                              ; EndIf
                            EndIf
                          debugMsg(sProcName, \sAudLabel + ", bOpenMediaResult=" + strB(bOpenMediaResult) + ", \nAudState=" + decodeCueState(\nAudState) +
                                              ", \nSubState=" + decodeCueState(aSub(\nSubIndex)\nSubState) +
                                              ", \nCueState=" + decodeCueState(aCue(\nCueIndex)\nCueState))
                          bUpdateGrid = #True
                          If bOpenMediaResult = #False
                            If \bInsufficientSMSPlaybacks
                              bRunOutOfSMSPlaybacks = #True
                            EndIf
                          Else
                            ; bAtLeastOneAudOpenForThisCue = #True ; deleted 14Aug2023 11.10.0by as this was causing SM-S commands to be sent a 2nd time (in pass 2)
                            If \bAudTypeF
                              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bAudTypeF=#True")
                              bIncrementCounts = #True
                              If \nAudGaplessSeqPtr >= 0
                                If gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq
                                  bIncrementCounts = #False
                                Else
                                  gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq = #True
                                EndIf
                              EndIf
                              If bIncrementCounts
                                If grONC1\bOpenAudCounted(k) = #False
                                  grONC2\nAudioFilesOpen + 1
                                  grONC1\bOpenAudCounted(k) = #True
                                EndIf
                              EndIf
                              If gbUseSMS
                                If bKeepOpen
                                  grONC2\nSMSPChanCountHK + \nSMSPChanCount
                                Else
                                  grONC2\nSMSPChanCountNonHK + \nSMSPChanCount
                                EndIf
                              EndIf
                              
                            ElseIf \bAudTypeM
                              If bKeepOpen = #False
                                ; this test so that we do not stop MIDI file opens if the only MIDI files currently open are for hotkey cues
                                If grONC1\bOpenAudCounted(k) = #False
                                  grONC2\nMidiFilesOpen + 1
                                  grONC1\bOpenAudCounted(k) = #True
                                EndIf
                              EndIf
                              
                            ElseIf \bAudTypeP
                              grONC2\nAudioFilesOpen + 1
                              nFilesOpenForThisPlaylist + 1
                              If gbUseSMS
                                If bKeepOpen
                                  grONC2\nSMSPChanCountHK + \nSMSPChanCount
                                Else
                                  grONC2\nSMSPChanCountNonHK + \nSMSPChanCount
                                EndIf
                              EndIf
                              
                            ElseIf \bAudTypeA
                              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bAudTypeA=#True")
                              bIncrementCounts = #True
                              If \nAudGaplessSeqPtr >= 0
                                If gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq
                                  bIncrementCounts = #False
                                Else
                                  gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq = #True
                                EndIf
                              EndIf
                              If grONC1\bOpenAudCounted(k) = #False
                                If bIncrementCounts
                                  grONC2\nVideoImageFilesOpen + 1
                                  grONC1\bOpenAudCounted(k) = #True
                                EndIf
                              EndIf
                              nFilesOpenForThisPlaylist + 1
                              
                            EndIf
                          EndIf
                        EndIf
                        
                        If aCue(\nCueIndex)\bNonLinearCue
                          resetRelatedCueActivationMethodReqd(\nCueIndex)
                        EndIf
                        
                        grONC2\nFilesOpenedThisCall + 1
                        
                      EndIf
                    EndIf
                  EndIf
                  ;}
                ElseIf \nFileState = #SCS_FILESTATE_OPEN
                  ;{
                  bAtLeastOneAudOpenForThisCue = #True
                  If (\nAudState <= #SCS_CUE_READY) And (bKeepOpen = #False)
                    If \bAudTypeF
                      bIncrementCounts = #True
                      If \nAudGaplessSeqPtr >= 0
                        If gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq
                          bIncrementCounts = #False
                        Else
                          gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq = #True
                        EndIf
                      EndIf
                      If bIncrementCounts
                        If grONC1\bOpenAudCounted(k) = #False
                          grONC2\nAudioFilesOpen + 1
                          grONC1\bOpenAudCounted(k) = #True
                        EndIf
                      EndIf
                      
                    ElseIf \bAudTypeP
                      If grONC1\bOpenAudCounted(k) = #False
                        grONC2\nAudioFilesOpen + 1
                        grONC1\bOpenAudCounted(k) = #True
                      EndIf
                      nFilesOpenForThisPlaylist + 1
                      
                    ElseIf \bAudTypeA
                      bIncrementCounts = #True
                      If \nAudGaplessSeqPtr >= 0
                        If gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq
                          bIncrementCounts = #False
                        Else
                          gaGaplessSeqs(\nAudGaplessSeqPtr)\bAtLeastOneAudOpenForGaplessSeq = #True
                        EndIf
                      EndIf
                      If bIncrementCounts
                        If grONC1\bOpenAudCounted(k) = #False
                          grONC2\nVideoImageFilesOpen + 1
                          grONC1\bOpenAudCounted(k) = #True
                        EndIf
                      EndIf
                      nFilesOpenForThisPlaylist + 1
                      
                    EndIf
                    
                  ElseIf (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_PL_READY)
                    nFilesOpenForThisPlaylist + 1
                  EndIf
                  ;}
                EndIf
                
                If gbEditHasFocus = #False
                  aSub(\nSubIndex)\nSubStateBeforeOpenedInEditor = aSub(\nSubIndex)\nSubState
                  aSub(\nSubIndex)\bSubCompletedBeforeOpenedInEditor = #False
                  aCue(\nCueIndex)\bCueCompletedBeforeOpenedInEditor = #False
                EndIf
                
                If \nFileState = #SCS_FILESTATE_OPEN
                  bPrevPlayAudOpen = #True
                Else
                  bPrevPlayAudOpen = #False
                EndIf
                
                k = \nNextPlayIndex
                If (k = -1) And (aSub(j)\bSubTypeAorP) And (aSub(j)\bPLRepeat) And (nPlaylistPass = 1) And (aSub(j)\bPLSavePos = #False)
                  k = aSub(j)\nFirstPlayIndex
                  nPlaylistPass + 1
                EndIf
              EndWith
            Wend ; Wend While k >= 0
            
            With aSub(j)
              If \bSubTypeAorP
                ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubTypeAorP=#True, \nSubState=" + decodeCueState(\nSubState))
                If \nSubState <= #SCS_CUE_READY ; \nSubState < #SCS_CUE_FADING_IN ; Changed 22Feb2021 11.8.4aj
                  \bPLTerminating = #False
                  \bPLFadingIn = #False
                  \bPLFadingOut = #False
                  If Len(\sPlayOrder) = 0
                    debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(j) + ")")
                    generatePlayOrder(j)
                  EndIf
                  ; debugMsg(sProcName, "calling setPLFades(" + getSubLabel(j) + ")")
                  setPLFades(j)
                  calcPLTotalTime(j)
                  bUpdateGrid = #True
                  For d = 0 To grLicInfo\nMaxAudDevPerSub
                    \fSubBVLevelNow[d] = \fSubMastBVLevel[d]
                    \fSubPanNow[d] = \fPLPan[d]
                  Next d
                EndIf
                \bIgnoreInStatusCheck = #False
                ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bIgnoreInStatusCheck=" + strB(aSub(j)\bIgnoreInStatusCheck))
                
              ElseIf \bSubTypeU
                ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubTypeU=#True" + ", \nSubState=" + decodeCueState(\nSubState))
                If \nMTCType = #SCS_MTC_TYPE_LTC
                  If \nSubState = #SCS_CUE_NOT_LOADED
                    If assignAndSetTimeCodeGeneratorForSub(j, #True)
                      debugMsg(sProcName, "assignAndSetTimeCodeGeneratorForSub(" + getSubLabel(j) + ", #True) returned #True")
                      \nSubState = #SCS_CUE_READY
                      ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
                      setCueState(\nCueIndex)
                      ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
                    EndIf
                  ElseIf \nTCGenIndex < 0
                    ; subcue is 'ready' but no timecode generator was available last time we checked, so try again
                    assignAndSetTimeCodeGeneratorForSub(j, #True)
                  EndIf
                EndIf
                
              EndIf
              
            EndWith
            
          EndIf ; EndIf (aSub(j)\bSubTypeHasAuds) And (aSub(j)\bSubEnabled) And (bSubProcessed = #False)
          
          j = aSub(j)\nNextSubIndex
          
        Wend ; Wend While j >= 0
        
        If nPass = 2
          If bAtLeastOneAudOpenForThisCue
            If gbUseSMS ; SM-S
              debugMsg(sProcName, "calling setSyncPChanListForCue(" + getCueLabel(i) + ")")
              setSyncPChanListForCue(i)
              CompilerIf #c_lock_audio_to_ltc
                If aCue(i)\nActivationMethod = #SCS_ACMETH_LTC
                  sLogicalDev = getLogicalDevForInputForLTCDev(@grProd)
                  If sLogicalDev
                    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
                    If nDevMapDevPtr >= 0
                      nFirst0BasedInputChan = grMaps\aDev(nDevMapDevPtr)\nFirst1BasedInputChan - 1
                      If nFirst0BasedInputChan >= 0
;                         If grSMS\nSMSTimeCodeChan < 1000
;                           grSMS\nSMSTimeCodeChan = 999
;                         EndIf
;                         grSMS\nSMSTimeCodeChan + 1
                        grSMS\nSMSTimeCodeChan = 1000
                        ; sSMSCommand = "set chan i" + nFirst0BasedInputChan + " x" + nFirst0BasedInputChan + ".1000 o1000 gain 1"
                        sSMSCommand = "set chan i" + nFirst0BasedInputChan + " x" + nFirst0BasedInputChan + "." + grSMS\nSMSTimeCodeChan + " o" + grSMS\nSMSTimeCodeChan + " gain 1"
                        ; determine the group for 'set group ...'
                        sendSMSCommand(sSMSCommand)
                        If aCue(i)\nSMSGroup < 0
                          If grSMS\nSMSGroup >= 127
                            grSMS\nSMSGroup = 0
                          EndIf
                          ; use group numbers in the range 1-127. SM-S should accept group numbers in the range 0-127 but a bug in SM-S 1.0.144 thows an error if you use group 0
                          grSMS\nSMSGroup + 1
                          aCue(i)\nSMSGroup = grSMS\nSMSGroup
                        EndIf
                        nGroup = aCue(i)\nSMSGroup
                        ; obtain the playback channels
                        sSMSPlaybackChans = ""
                        j = aCue(i)\nFirstSubIndex
                        While j >= 0
                          If aSub(j)\bSubTypeF And aSub(j)\bSubPlaceHolder = #False And aSub(j)\bSubEnabled
                            k = aSub(j)\nFirstAudIndex
                            If k >= 0
                              For n = 0 To ArraySize(gaPlayback())
                                If gaPlayback(n)\nAudPtr = k
                                  If gaPlayback(n)\sPChanListPrimary
                                    ; debugMsg0(sProcName, "gaPlayback(" + n + ")\sPChanListPrimary=" + gaPlayback(n)\sPChanListPrimary)
                                    sSMSPlaybackChans + " " + gaPlayback(n)\sPChanListPrimary
                                  EndIf
                                EndIf
                              Next n
                            EndIf
                          EndIf
                          j = aSub(j)\nNextSubIndex
                        Wend
                        ; obtain the time code
                        sTimeCode = decodeMTCTime(aCue(i)\nMTCStartTimeForCue)
                        ; build the SM-S 'set group ...' command
                        sSMSCommand = "set group g" + nGroup + " chans " + Trim(sSMSPlaybackChans) + " tc reader " + grSMS\nSMSTimeCodeChan + " lock tc " + sTimeCode
                        sendSMSCommand(sSMSCommand)
                        sSMSCommand = "play g" + nGroup
                        sendSMSCommand(sSMSCommand)
                        aCue(i)\bSMSTimeCodeLocked = #True
                      EndIf
                    EndIf
                  EndIf
                EndIf
              CompilerEndIf
            EndIf
          EndIf
        EndIf
        
        If bUpdateGrid
          ; debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(i) + ")")
          loadGridRow(i)
        EndIf
      EndIf ; EndIf bCheckThis
      UnlockCueListMutex()
    Next i
    
  Next nPass
  
  If bResetMTCLinksForAllCues
    setMTCLinksForAllCues()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ONC_loadDependentCues(pCuePtr)
  ; NB ONC_loadDependentCues() is recursive - it can call itself
  PROCNAMECQ(pCuePtr)
  Protected d, h, i, j, k, m, n
  Protected bLoadThisCue

  debugMsg(sProcName, #SCS_START)

  For i = 1 To gnCueEnd - 1
    bLoadThisCue = #False
    If (aCue(i)\bCueCurrentlyEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED)
      If aCue(i)\nCueState = #SCS_CUE_NOT_LOADED
        ; only interested in 'not loaded' cues
        
        If aCue(i)\nAutoActCuePtr = pCuePtr
          bLoadThisCue = #True
        Else
          j = aCue(i)\nFirstSubIndex
          While (j >= 0) And (bLoadThisCue = #False)
            With aSub(j)
              If aSub(j)\bSubEnabled
                If \bSubTypeL
                  If \nLCCuePtr = pCuePtr
                    bLoadThisCue = #True
                  EndIf
                ElseIf \bSubTypeS
                  For h = 0 To #SCS_MAX_SFR
                    If \nSFRCueType[h] = #SCS_SFR_CUE_SEL Or \nSFRCueType[h] = #SCS_SFR_CUE_PREV
                      If \nSFRCuePtr[h] = pCuePtr    ; nb no need to test for \nSFRCuePtr[h] >= 0
                        bLoadThisCue = #True
                        Break
                      EndIf
                    EndIf
                  Next h
                EndIf
              EndIf ; EndIf aSub(j)\bSubEnabled
              j = \nNextSubIndex
            EndWith
          Wend
        EndIf
        debugMsg(sProcName, aCue(i)\sCue + ", bLoadThisCue=" + strB(bLoadThisCue))
        
        If bLoadThisCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            With aSub(j)
              If aSub(j)\bSubEnabled
                If \bSubTypeHasAuds
                  k = \nFirstAudIndex
                  While k >= 0
                    If aAud(k)\nFileState = #SCS_FILESTATE_CLOSED
                      If aAud(k)\nAudState < #SCS_CUE_COMPLETED
                        If (aAud(k)\sFileName) Or (aAud(k)\bLiveInput)
                          debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(k) + ")")
                          openMediaFile(k)
                        EndIf
                      EndIf
                    EndIf
                    k = aAud(k)\nNextAudIndex
                  Wend
                  
                  If \bSubTypeAorP
                    If \nSubState < #SCS_CUE_FADING_IN
                      \bPLTerminating = #False
                      \bPLFadingIn = #False
                      \bPLFadingOut = #False
                      If Len(\sPlayOrder) = 0
                        debugMsg(sProcName, "calling generatePlayOrder(" + buildSubLabel(j) + ")")
                        generatePlayOrder(j)
                      EndIf
                      debugMsg(sProcName, "calling setPLFades(" + getSubLabel(j) + ")")
                      setPLFades(j)
                      calcPLTotalTime(j)
                      For d = 0 To grLicInfo\nMaxAudDevPerAud
                        \fSubBVLevelNow[d] = \fSubMastBVLevel[d]
;                         If d = 0
;                           debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\fSubBVLevelNow[" + d + "]=" + traceLevel(\fSubBVLevelNow[d]))
;                         EndIf
                        \fSubPanNow[d] = \fPLPan[d]
                      Next d
                    EndIf
                  EndIf
                  
                Else
                  \nSubState = #SCS_CUE_READY
                  
                EndIf
              EndIf ; EndIf aSub(j)\bSubEnabled
              j = \nNextSubIndex
            EndWith
            
            aCue(i)\qTimeCueStopped = grCueDef\qTimeCueStopped
            aCue(i)\bTimeCueStoppedSet = grCueDef\bTimeCueStoppedSet
            
          Wend
          
          setCueState(i)
          
          ONC_loadDependentCues(i)
          
        EndIf
      EndIf
    EndIf
  Next i
  
EndProcedure


; EOF