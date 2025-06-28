; File: CuePanelControl.pbi

; 'Cue Panels' are the panels in the lower part of the main window that show details of cues or sub-cues in this production.
; See this topic in the Help: 'The Main Window / Cue Panels', at https://www.showcuesystems.com/scs11help/topics/cue-panels.htm

EnableExplicit

Procedure PNL_New(h, sName.s, pParentContainer, pOffsetX, pOffsetY, pWidth, pHeight)
  PROCNAME(#PB_Compiler_Procedure + "(" + sName + ")")
  
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, #SCS_START + ", h=" + h + ", pParentContainer=G" + pParentContainer + ", pOffsetX=" + pOffsetX + ", pOffsetY=" + pOffsetY + ", pWidth=" + pWidth + ", pHeight=" + pHeight)
  CompilerEndIf
  
  If h > ArraySize(gaPnlVars())
    ReDim gaPnlVars.tyPnlVars(h+20)
  EndIf
  If ArraySize(gaDispPanel()) < ArraySize(gaPnlVars())
    ReDim gaDispPanel.tyDispPanel(ArraySize(gaPnlVars()))
  EndIf
  
  With gaPnlVars(h)
    \bSlidersInitialised = #False
    \bInUse = #True
    \sName = sName
    \bShowTransportControls = grOperModeOptions(gnOperMode)\bShowTransportControls
    \bShowFaderAndPanControls = grOperModeOptions(gnOperMode)\bShowFaderAndPanControls
  EndWith
  
  PNL_createCuePanelGadgets(h, pParentContainer, pOffsetX, pOffsetY, pWidth, pHeight, #True)
  
  PNL_UserControl_Initialize(h)
  
  ; debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure PNL_btnFadeOut_Click(h)
  PROCNAMECP(h)
  Protected nEndAt

  debugMsg(sProcName, #SCS_START)
  
  setGlobalTimeNow()
  With gaDispPanel(h)
    
    If \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
      fadeOutCue(\nDPCuePtr, #True)
      
    ElseIf \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB
      fadeOutSub(\nDPSubPtr, #True)
      
    Else
      If (\sDPSubType = "P") And ((aAud(\nDPAudPtr)\nNextPlayIndex >= 0) Or ((aSub(\nDPSubPtr)\bPLRepeat) And (aSub(\nDPSubPtr)\nAudCount > 1)))
        debugMsg(sProcName, "calling fadeOutOneAud(" + getAudLabel(\nDPAudPtr) + ")")
        fadeOutOneAud(\nDPAudPtr)
        ; ; use stopAud(), not fadeOutOneAud(), as stopAud() has the required effect but fadeOutOneAud() doesn't seem to work
        ; ; properly with playlists and slideshows
        ; debugMsg(sProcName, "calling stopAud(" + getAudLabel(\nAudPtr) + ")")
        ; stopAud(\nAudPtr)
;       ElseIf (\sSubType = "A") And ((aAud(\nAudPtr)\nNextPlayIndex >= 0) Or (aSub(\nSubPtr)\bPLRepeat))
      ElseIf (\sDPSubType = "A") And (aAud(\nDPAudPtr)\nNextPlayIndex >= 0) ; 27Nov2015 11.4.1.2p: removed check on \bPLRepeat
        ; debugMsg(sProcName, "calling fadeOutOneAud(" + getAudLabel(\nAudPtr) + ")")
        ; fadeOutOneAud(\nAudPtr)
        ; use stopAud(), not fadeOutOneAud(), as stopAud() has the required effect but fadeOutOneAud() doesn't seem to work
        ; properly with playlists and slideshows
        debugMsg(sProcName, "calling stopAud(" + getAudLabel(\nDPAudPtr) + ")")
        stopAud(\nDPAudPtr)
      Else
        If (\sDPSubType = "P") Or (\sDPSubType = "A")
          If aAud(\nDPAudPtr)\nNextPlayIndex = -1
            If aSub(\nDPSubPtr)\bPLRepeat = #False
              aSub(\nDPSubPtr)\bPLTerminating = #True
              debugMsg(sProcName, "aSub(" + getSubLabel(\nDPSubPtr) + ")\bPLTerminating=" + strB(aSub(\nDPSubPtr)\bPLTerminating))
            EndIf
          EndIf
        EndIf
        debugMsg(sProcName, "calling fadeOutSub(" + getSubLabel(\nDPSubPtr) + ", #True)")
        fadeOutSub(\nDPSubPtr, #True)
        If \nDPAudPtr >= 0
          calcCuePositionForAud(\nDPAudPtr)
          nEndAt = getAudPlayingPos(\nDPAudPtr) + aAud(\nDPAudPtr)\nFadeOutTime
          If nEndAt < aAud(\nDPAudPtr)\nRelEndAt
            aAud(\nDPAudPtr)\nRelEndAt = nEndAt
          EndIf
        EndIf
      EndIf
    EndIf
    \bEnableFadeOut = #False
    PNL_setDisplayButtons(h, aAud(\nDPAudPtr)\nAudState, aAud(\nDPAudPtr)\nLinkedToAudPtr)
  EndWith

  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "fadeout")
  EndIf
  
  SAG(-1)

EndProcedure

Procedure PNL_btnPause_Click(h)
  PROCNAMECP(h)
  Protected bCountDownPaused
  
  debugMsg(sProcName, #SCS_START)
  
  setGlobalTimeNow()
  
  With gaDispPanel(h)
    
    If aCue(\nDPCuePtr)\bCueCountDownPaused Or aSub(\nDPSubPtr)\bSubCountDownPaused
      bCountDownPaused = #True
      debugMsg(sProcName, "bCountDownPaused=" + strB(bCountDownPaused))
    EndIf
    
    Select \nTransportSwitchCode
      Case #SCS_TRANSPORT_SWITCH_CUE
        debugMsg(sProcName, "aCue(" + getCueLabel(\nDPCuePtr) + "\nCueState=" + decodeCueState(aCue(\nDPCuePtr)\nCueState))
        If aCue(\nDPCuePtr)\nCueState = #SCS_CUE_PAUSED Or bCountDownPaused
          resumeCue(\nDPCuePtr)
        Else
          pauseCue(\nDPCuePtr)
        EndIf
        
      Case #SCS_TRANSPORT_SWITCH_SUB
        debugMsg(sProcName, "aSub(" + getSubLabel(\nDPSubPtr) + "\nSubState=" + decodeCueState(aSub(\nDPSubPtr)\nSubState))
        If aSub(\nDPSubPtr) = #SCS_CUE_PAUSED Or bCountDownPaused
          resumeSub(\nDPSubPtr)
        Else
          pauseSub(\nDPSubPtr)
        EndIf
        
      Default
        If aSub(\nDPSubPtr)\bSubTypeHasAuds
          debugMsg(sProcName, "aAud(" + getAudLabel(\nDPAudPtr) + ")\nAudState=" + decodeCueState(aAud(\nDPAudPtr)\nAudState))
          If aAud(\nDPAudPtr)\nAudState = #SCS_CUE_PAUSED Or bCountDownPaused
            debugMsg(sProcName, "calling resumeAud(" + getAudLabel(\nDPAudPtr) + ")")
            resumeAud(\nDPAudPtr)
          Else
            debugMsg(sProcName, "calling pauseAud(" + getAudLabel(\nDPAudPtr) + ")")
            pauseAud(\nDPAudPtr)
          EndIf
        Else
          debugMsg(sProcName, "aSub(" + getSubLabel(\nDPSubPtr) + "\nSubState=" + decodeCueState(aSub(\nDPSubPtr)\nSubState))
          If aSub(\nDPSubPtr) = #SCS_CUE_PAUSED Or bCountDownPaused
            resumeSub(\nDPSubPtr)
          Else
            pauseSub(\nDPSubPtr)
          EndIf
        EndIf
        
    EndSelect
  EndWith
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "pause")
  EndIf
  
  SAG(-1)

EndProcedure

Procedure PNL_btnPlay_Click(h)
  PROCNAMECP(h)
  Protected nCuePtr, nSubPtr, nAudPtr, nAudState
  Protected bUseGoButton, bPlayCue
  
  debugMsg(sProcName, #SCS_START)
  
  setGlobalTimeNow()

  nCuePtr = gaDispPanel(h)\nDPCuePtr
  nSubPtr = gaDispPanel(h)\nDPSubPtr
  nAudPtr = gaDispPanel(h)\nDPAudPtr
  If nAudPtr >= 0
    nAudState = aAud(nAudPtr)\nAudState
  EndIf
  
  If nCuePtr = gnCueToGo
    If aCue(nCuePtr)\bSubTypeN
      bUseGoButton = #True
    ElseIf nSubPtr >= 0
      ; debugMsg(sProcName, "nSubPtr=" + getSubLabel(nSubPtr) + ", aCue(" + getCueLabel(nCuePtr) + ")\nFirstSubIndex=" + getSubLabel(aCue(nCuePtr)\nFirstSubIndex))
      If nSubPtr = aCue(nCuePtr)\nFirstSubIndex
        If aSub(nSubPtr)\bSubTypeAorP
          If nAudPtr >= 0
            If nAudPtr = aSub(nSubPtr)\nFirstPlayIndex
              bUseGoButton = #True
            EndIf
          EndIf
        Else
          bUseGoButton = #True
        EndIf
      EndIf
    EndIf
    If bUseGoButton
      If nAudPtr >= 0
        If (nAudState >= #SCS_CUE_FADING_IN) And (nAudState <= #SCS_CUE_FADING_OUT)
          ; primarily to handle scenario of non-linear cue have being paused and resumed via the display panels
          bUseGoButton = #False
        EndIf
      EndIf
    EndIf
    If nAudPtr >= 0
      debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", nAudState=" + decodeCueState(nAudState) + ", bUseGoButton=" + strB(bUseGoButton))
    Else
      debugMsg(sProcName, "nSubPtr=" + getSubLabel(nSubPtr) + ", bUseGoButton=" + strB(bUseGoButton))
    EndIf
    If bUseGoButton
      WMN_processGo(#True)
      ProcedureReturn
    EndIf
    
  Else
    ; Added 28Jan2021 11.8.3.5
    If nSubPtr >= 0
      If aSub(nSubPtr)\nPrevSubIndex < 0 And aSub(nSubPtr)\nNextSubIndex < 0
        ; nSubPtr is the only sub-cue in the cue
        If aSub(nSubPtr)\nSubState < #SCS_CUE_FADING_IN Or aSub(nSubPtr)\nSubState = #SCS_CUE_STANDBY ; Added this test 28Aug2021 11.8.6ae because without this test a paused cue would restart from the beginning
          bPlayCue = #True
        EndIf
      EndIf
    EndIf
    ; End added 28Jan2021 11.8.3.5

  EndIf
  
  With gaDispPanel(h)
    If \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE Or bPlayCue ; Mod 28Jan2021 11.8.3.5 added "Or bPlayCue"
      debugMsg(sProcName, "calling playCue(" + getCueLabel(\nDPCuePtr) + ")")
      playCue(\nDPCuePtr)
      
      ; blocked out the following 13Mar2017 11.6.0 after testing "Harold Fernandes\mm2017 - without dmx in.scs11"
      ; running a cue containing an audio file sub-cue and an MTC sub-cue, and then pausing and resuming the audio file sub-cue caused the audio file
      ; sub-cue to restart from the beginning instead of resuming from where it was pasued. that was because the following test issued 'playSub()'.
      ; blocking out this code allows the procedure to fall through to the next set of tests that correctly handle resuming paused sub-cues.
;     ElseIf (\nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB) And (aSub(nSubPtr)\bSubTypeAorP = #False)
;       debugMsg(sProcName, "calling playSub(" + getSubLabel(nSubPtr) + ")")
;       playSub(nSubPtr, 0, #False, #False, -1, -1, -1, #True)
      
    Else
      If ((aSub(nSubPtr)\bSubTypeF) Or (aSub(nSubPtr)\bSubTypeI) Or (aSub(nSubPtr)\bSubTypeM)) And (nAudPtr >= 0) ; \bSubTypeF, \bSubTypeI, \bSubTypeM
        debugMsg(sProcName, aAud(nAudPtr)\sAudLabel + ", \nAudState=" + decodeCueState(nAudState))
        If nAudState = #SCS_CUE_PAUSED
          debugMsg(sProcName, "calling resumeAud(" + getAudLabel(nAudPtr) + ")")
          resumeAud(nAudPtr)
          
        ElseIf (nAudState < #SCS_CUE_FADING_IN) Or (nAudState = #SCS_CUE_STANDBY)
          debugMsg(sProcName, "calling playSub(" + getSubLabel(nSubPtr) + ")")
          playSub(nSubPtr, 0, #False, #False, -1, -1, -1, #True)
          
        Else
          debugMsg(sProcName, "calling restartAud(" + getAudLabel(nAudPtr) + ")")
          restartAud(nAudPtr)
        EndIf
        
      ElseIf (aSub(nSubPtr)\bSubTypeAorP) And (nAudPtr >= 0)  ; \bSubTypeAorP
        If nAudState = #SCS_CUE_PAUSED
          debugMsg(sProcName, "calling resumeAud(" + getAudLabel(nAudPtr) + ")")
          resumeAud(nAudPtr)
          
        ElseIf ((nAudState < #SCS_CUE_FADING_IN) Or (nAudState = #SCS_CUE_STANDBY)) And (aAud(nAudPtr)\nPrevPlayIndex = -1)
          debugMsg(sProcName, "calling playSub(" + getSubLabel(nSubPtr) + ")")
          playSub(nSubPtr, 0, #False, #False, -1, -1, -1, #True)
          
        ElseIf (nAudState = #SCS_CUE_PL_READY) Or (nAudState < #SCS_CUE_FADING_IN) Or (nAudState = #SCS_CUE_STANDBY)
          debugMsg(sProcName, "calling playAud(" + getAudLabel(nAudPtr) + ")")
          playAud(nAudPtr)
          
        Else
          debugMsg(sProcName, "calling restartAud(" + getAudLabel(nAudPtr) + ")")
          restartAud(nAudPtr)
        EndIf
        
      ElseIf (aSub(nSubPtr)\bSubTypeE) Or (aSub(nSubPtr)\bSubTypeU)  ; \bSubTypeE, \bSubTypeU
;         Select aSub(nSubPtr)\nSubState
;           Case #SCS_CUE_PAUSED
;             resumeSub(nSubPtr)
;           Case #SCS_CUE_READY
;             debugMsg(sProcName, "calling playSub(" + getSubLabel(nSubPtr) + ")")
;             playSub(nSubPtr, 0, #False, #False, -1, -1, -1, #True)
;         EndSelect
        ; changed the above 27Dec2018 11.8.0cm so that a counting down sub may be activated by the play button
        If aSub(nSubPtr)\nSubState = #SCS_CUE_PAUSED
          resumeSub(nSubPtr)
        ElseIf aSub(nSubPtr)\nSubState < #SCS_CUE_FADING_IN
          debugMsg(sProcName, "calling playSub(" + getSubLabel(nSubPtr) + ")")
          playSub(nSubPtr, 0, #False, #False, -1, -1, -1, #True)
        EndIf
        
      Else  ; anything else
        debugMsg(sProcName, "calling playSub(" + getSubLabel(nSubPtr) + ")")
        playSub(nSubPtr, 0, #False, #False, -1, -1, -1, #True)
        
      EndIf
    EndIf
  EndWith
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "play")
  EndIf
  
  SAG(-1)
  
EndProcedure

Procedure PNL_btnRelease_Click(h)
  PROCNAMECP(h)
  
  debugMsg(sProcName, #SCS_START)
  
  With gaDispPanel(h)
    If \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
      releaseCueLoop(\nDPCuePtr)
    ElseIf \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB
      releaseSubLoop(\nDPSubPtr)
    Else
      releaseAudLoop(\nDPAudPtr)
    EndIf
  EndWith
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "release")
  EndIf
  
  SAG(-1)
  
EndProcedure

Procedure PNL_btnRewind_Click(h)
  PROCNAMECP(h)
  Protected nAudPtr, nState, d
  Protected nSubPtr
  
  debugMsg(sProcName, #SCS_START)
  
  setGlobalTimeNow()
  nSubPtr = gaDispPanel(h)\nDPSubPtr 
  If aSub(nSubPtr)\bSubTypeHasAuds
    nAudPtr = gaDispPanel(h)\nDPAudPtr
    With aAud(nAudPtr)
      If \bAudTypeAorF Or \bAudTypeM
        clearManualOffsets(nAudPtr)
        nState = \nAudState
        If (nState >= #SCS_CUE_FADING_IN) And (nState <= #SCS_CUE_FADING_OUT) And ((nState <> #SCS_CUE_PAUSED) Or (\nPrevPlayIndex >= 0))
          If gbUseBASS
            pauseAud(nAudPtr)
          EndIf
          debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + \nAbsStartAt + ", #True, #True)")
          reposAuds(nAudPtr, \nAbsStartAt, #True, #True)
          \qTimeAudStarted = gqTimeNow
          \bTimeAudEndedSet = #False
          \qTimeAudRestarted = gqTimeNow
          debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\qTimeAudRestarted=" + traceTime(\qTimeAudRestarted))
          \nTotalTimeOnPause = 0
          \nPriorTimeOnPause = 0
          \nPreFadeInTimeOnPause = 0
          \nPreFadeOutTimeOnPause = 0
          \nCuePosAtLoopStart = 0
          \nRelEndAt = \nAbsEndAt - \nAbsMin
          setRelCheckForEnd(nAudPtr)
          If nState <> #SCS_CUE_PAUSED
            If gbUseBASS
              resumeAud(nAudPtr)
            EndIf
          EndIf
        Else
          debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + \nAbsStartAt + ", #True, #True)")
          reposAuds(nAudPtr, \nAbsStartAt, #True, #True)
          If \nCurrFadeInTime > 0
            For d = \nFirstSoundingDev To \nLastSoundingDev
              If \bCueVolManual[d] = #False
                \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
              EndIf
            Next d
          EndIf
        EndIf
      Else
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + \nAbsStartAt + ", #True, #True)")
        reposAuds(nAudPtr, \nAbsStartAt, #True, #True)
      EndIf
    EndWith
    
    With aSub(nSubPtr)
      \qTimeSubStarted = gqTimeNow
      \qAdjTimeSubStarted = gqTimeNow
      \bTimeSubStartedSet = #True
      \qTimeSubRestarted = gqTimeNow
      \nSubTotalTimeOnPause = 0
      \nSubPriorTimeOnPause = 0
    EndWith
    
  Else
    With aSub(nSubPtr)
      If \bSubTypeU
        debugMsg(sProcName, "calling reposTimeCode(" + getSubLabel(nSubPtr) + ", 0)")
        reposTimeCode(nSubPtr, 0)
        \qTimeSubStarted = gqTimeNow
        \qAdjTimeSubStarted = gqTimeNow
        \bTimeSubStartedSet = #True
        \qTimeSubRestarted = gqTimeNow
        \nSubTotalTimeOnPause = 0
        \nSubPriorTimeOnPause = 0
        
      ElseIf \bSubTypeE
        debugMsg(sProcName, "calling WQE_reposMemo(" + getSubLabel(nSubPtr) + ", 0)")
        WQE_reposMemo(nSubPtr, 0)
        \qTimeSubStarted = gqTimeNow
        \qAdjTimeSubStarted = gqTimeNow
        \bTimeSubStartedSet = #True
        \qTimeSubRestarted = gqTimeNow
        \nSubTotalTimeOnPause = 0
        \nSubPriorTimeOnPause = 0
        
      EndIf
    EndWith
  EndIf
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "rewind")
  EndIf
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_btnShuffle_Click(h)
  PROCNAMECP(h)
  
  debugMsg(sProcName, #SCS_START)
  
  With gaDispPanel(h)
    generatePlayOrder(\nDPSubPtr, #True)
    ONC_openNextCues(\nDPCuePtr, \nDPCuePtr)   ; ensure at least first two files in play order are open (this cue only)
    setPLFades(\nDPSubPtr)
    calcPLTotalTime(\nDPSubPtr)
    loadGridRow(\nDPCuePtr)
  EndWith
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "shuffle")
  EndIf
  
  SAG(-1)
  
EndProcedure

Procedure PNL_btnFirst_Click(h)
  PROCNAMECP(h)
  
  debugMsg(sProcName, #SCS_START)
  
  With gaDispPanel(h)
    setFirstPlayIndexThisRun(\nDPSubPtr, #False)
    debugMsg(sProcName, "setting aSub(" + getSubLabel(\nDPSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(aSub(\nDPSubPtr)\nFirstPlayIndex) + ", (was " + getAudLabel(aSub(\nDPSubPtr)\nCurrPlayIndex) + ")")
    aSub(\nDPSubPtr)\nCurrPlayIndex = aSub(\nDPSubPtr)\nFirstPlayIndex
    ONC_openNextCues(\nDPCuePtr, \nDPCuePtr)   ; ensure at least first two files in play order are open (this cue only)
    setPLFades(\nDPSubPtr)
    calcPLTotalTime(\nDPSubPtr)
    loadGridRow(\nDPCuePtr)
    gbCallLoadDispPanels = #True
  EndWith
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "first")
  EndIf
  
  SAG(-1)
  
EndProcedure

Procedure PNL_btnStop_Click(h)
  PROCNAMECP(h)
  Protected bStopAud
  
  debugMsg(sProcName, #SCS_START)
  
  setGlobalTimeNow()
  
  With gaDispPanel(h)
    If \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
      debugMsg(sProcName, "calling stopCue(" + getCueLabel(\nDPCuePtr) + ", 'ALL', #True)")
      stopCue(\nDPCuePtr, "ALL", #True)
    ElseIf \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB
      debugMsg(sProcName, "calling stopSub(" + getSubLabel(\nDPSubPtr) + ", 'ALL', #True, #False)")
      stopSub(\nDPSubPtr, "ALL", #True, #False)
    Else
      If (\sDPSubType = "P") Or (\sDPSubType = "A")
        If aAud(\nDPAudPtr)\nNextPlayIndex >= 0
          bStopAud = #True
        ; ElseIf aSub(\nDPSubPtr)\bPLRepeat
        ElseIf getPLRepeatActive(\nDPSubPtr)
          If (aAud(\nDPAudPtr)\nPrevPlayIndex >= 0) Or (aAud(\nDPAudPtr)\nNextPlayIndex >= 0)
            ; more than one Aud in this Sub
            bStopAud = #True
          EndIf
        EndIf
      EndIf
      If bStopAud
        debugMsg(sProcName, "calling StopAud(" + getAudLabel(\nDPAudPtr) + ")")
        stopAud(\nDPAudPtr)
        If \sDPSubType = "A"
          If aSub(\nDPSubPtr)\bSubUseGaplessStream
            debugMsg(sProcName, "calling reposAtNextAud(" + getAudLabel(\nDPAudPtr) + ")")
            reposAtNextAud(\nDPAudPtr)
          EndIf
        EndIf
      Else
        debugMsg(sProcName, "calling stopSub(" + getSubLabel(\nDPSubPtr) + ", 'ALL', #True, #False)")
        stopSub(\nDPSubPtr, "ALL", #True, #False)
      EndIf
    EndIf
  EndWith
  
  If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
    FMP_sendCommandIfReqd(#SCS_OSCINP_PNL_BTN_CLICK, 0, h, 0, "stop")
  EndIf
  
  SAG(-1)
  
EndProcedure

Procedure PNL_cvsSwitch_Click(h)
  PROCNAMECP(h)
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling PNL_createSwitchMenu(" + h + ")")
  PNL_createSwitchMenu(h)
  
  debugMsg(sProcName, "IsMenu(#PNL_mnu_switch_popup)=" + IsMenu(#PNL_mnu_switch_popup))
  If IsMenu(#PNL_mnu_switch_popup)
    DisplayPopupMenu(#PNL_mnu_switch_popup, WindowID(#WMN))
  EndIf
  
EndProcedure

Procedure PNL_processSwitchMenuItem()
  PROCNAMEC()
  Protected h
  
  debugMsg(sProcName, #SCS_START)
  
  h = grMain\nSwitchMenuHostPanel
  If h >= 0
    With gaDispPanel(h)
      Select gnEventMenu
        Case #PNL_mnu_switch_cue
          \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
        Case #PNL_mnu_switch_sub
          \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB
        Case #PNL_mnu_switch_file
          \nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_FILE
          debugMsg(sProcName, "gaDispPanel(" + h + ")\nTransportSwitchCode=" + gaDispPanel(h)\nTransportSwitchCode)
      EndSelect
      
      If ((\sDPSubType = "P") Or (\sDPSubType = "A")) And (\nDPAudPtr >= 0)
        aAud(\nDPAudPtr)\nTransportSwitchIndex = \nTransportSwitchIndex
        aAud(\nDPAudPtr)\nTransportSwitchCode = \nTransportSwitchCode
        PNL_setDisplayButtons(h, aAud(\nDPAudPtr)\nAudState, aAud(\nDPAudPtr)\nLinkedToAudPtr)
        
      ElseIf \nDPSubPtr >= 0
        aSub(\nDPSubPtr)\nTransportSwitchIndex = \nTransportSwitchIndex
        aSub(\nDPSubPtr)\nTransportSwitchCode = \nTransportSwitchCode
        PNL_setDisplayButtons(h, aSub(\nDPSubPtr)\nSubState, -1)
        
      EndIf
    EndWith
    
    PNL_drawSwitch(h)
    
    SAG(-1)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_imgType_LeftClick(h)
  GoToCue(gaDispPanel(h)\nDPCuePtr)
EndProcedure

Procedure PNL_sldPnlProgress_Common(h, nSliderEventType)
  PROCNAMEC()
  Protected nSliderHandle
  Protected nAudPtr, nAbsReposAt, nTimeValue
  Protected nSubPtr
  Protected bReposition, bSetSync
  Protected bLockedMixerStreams
  Protected l2
  Protected bTrace = #False
  
  If nSliderEventType = #SCS_SLD_EVENT_SCROLL
    bTrace = #False
  EndIf
  
  nAudPtr = gaDispPanel(h)\nDPAudPtr
  nSubPtr = gaDispPanel(h)\nDPSubPtr
  
  If nAudPtr >= 0
    With aAud(nAudPtr)
      
      debugMsgC(sProcName, "nSliderEventType=" + SLD_decodeEvent(nSliderEventType) + ", aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
      
      Select nSliderEventType
        Case #SCS_SLD_EVENT_MOUSE_UP, #SCS_SLD_EVENT_SCROLL
          bReposition = #True
          \bResetFilePosToStartAtInMain = #False
          debugMsgC(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\bResetFilePosToStartAtInMain=" + strB(aAud(nAudPtr)\bResetFilePosToStartAtInMain))
      EndSelect
      
      If bReposition
;         debugMsgC(sProcName, "nSliderEventType=" + SLD_decodeEvent(nSliderEventType) + ", aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
        setGlobalTimeNow()
        nSliderHandle = gaPnlVars(h)\sldPnlProgress
        
        If (\bAudTypeA) And (\bAudUseGaplessStream) And (\nAudGaplessSeqPtr >= 0)
          nAbsReposAt = SLD_getValue(nSliderHandle)
          ; debugMsg(sProcName, "calling setVideoPosition(" + getAudLabel(nAudPtr) + ", " + decodeVidPicTarget(\nVidPicTarget) + ", " + nAbsReposAt + ")")
          ; setVideoPosition(nAudPtr, \nVidPicTarget, nAbsReposAt)
          debugMsgC(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + nAbsReposAt + ", #True, #True, #SCS_VID_PIC_TARGET_NONE, " + strb(bTrace) + ")")
          reposAuds(nAudPtr, nAbsReposAt, #True, #True, #SCS_VID_PIC_TARGET_NONE, bTrace)
          
        Else
          nTimeValue = SLD_getValue(nSliderHandle)
          nAbsReposAt = nTimeValue + \nAbsMin
          
          If gaDispPanel(h)\bM2T_Active
            If grM2T\nM2TPrimaryAudPtr = nAudPtr
              M2T_displayMoveToTimeValueIfActive(h, nTimeValue)
            EndIf
          EndIf
          
          If (gbUseBASS) And (gbUseBASSMixer) And (\bAudTypeForP)
            lockAllMixerStreams(#True, #False, bTrace)
            bLockedMixerStreams = #True
          EndIf
          
          debugMsgC(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + nAbsReposAt + ", #True, #True, #SCS_VID_PIC_TARGET_NONE, " + strB(bTrace) + ")")
          reposAuds(nAudPtr, nAbsReposAt, #True, #True, #SCS_VID_PIC_TARGET_NONE, bTrace)
          
          If bLockedMixerStreams
            lockAllMixerStreams(#False, #False, bTrace)
          EndIf
          
          If \bAudTypeF
            l2 = \nCurrLoopInfoIndex
            If l2 >= 0
              If nAbsReposAt < \rCurrLoopInfo\nAbsLoopStart
                ; added 2Feb2022 11.9.0rc7
                \aLoopInfo(l2)\bLoopReleased = #False
                \rCurrLoopInfo\bLoopReleased = #False
              ElseIf nAbsReposAt < \rCurrLoopInfo\nAbsLoopEnd
                ; no action (changed 2Feb2022 11.9.0rc7)
                ; \aLoopInfo(l2)\bLoopReleased = #False
                ; \rCurrLoopInfo\bLoopReleased = #False
              Else
                \aLoopInfo(l2)\bLoopReleased = #True
                \rCurrLoopInfo\bLoopReleased = #True
              EndIf
            EndIf
            debugMsgC(sProcName, "calling PNL_setReleaseBtnState(" + h + ")")
            PNL_setReleaseBtnState(h)
            
            ; Added 13Jan2025 11.10.6-b03
            If \nMaxCueMarker >= 0
              debugMsg(sProcName, "calling loadOCMCuesAfterAudPos(" + getAudLabel(nAudPtr) + ", " + nAbsReposAt+ ")")
              loadOCMCuesAfterAudPos(nAudPtr, nAbsReposAt)
            EndIf
            ; End added 13Jan2025 11.10.6-b03
            
          EndIf
          
        EndIf
        
      EndIf
    EndWith
    
  ElseIf nSubPtr >= 0
    With aSub(nSubPtr)
      If (\bSubTypeE) Or (\bSubTypeU)
        Select nSliderEventType
          Case #SCS_SLD_EVENT_MOUSE_UP, #SCS_SLD_EVENT_SCROLL
            bReposition = #True
        EndSelect
        
        If bReposition
          debugMsgC(sProcName, "nSliderEventType=" + SLD_decodeEvent(nSliderEventType) + ", aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(\nSubState))
          setGlobalTimeNow()
          nSliderHandle = gaPnlVars(h)\sldPnlProgress
          nAbsReposAt =  SLD_getValue(nSliderHandle)
          If \bSubTypeE
            debugMsgC(sProcName, "calling WQE_reposMemo(" + getSubLabel(nSubPtr) + ", " + ttszt(nAbsReposAt) + ")")
            WQE_reposMemo(nSubPtr, nAbsReposAt)
          ElseIf \bSubTypeU
            debugMsgC(sProcName, "calling MTC_setSyncTimeCode(" + getSubLabel(nSubPtr) + ")")
            bSetSync = MTC_setSyncTimeCode(nSubPtr)
            If bSetSync = #False
              If \nSubState >= #SCS_CUE_FADING_IN And \nSubState <= #SCS_CUE_FADING_OUT And \nSubState <> #SCS_CUE_PAUSED And \nSubState <> #SCS_CUE_HIBERNATING
                debugMsgC(sProcName, "calling reposTimeCode(" + getSubLabel(nSubPtr) + ", " + ttszt(nAbsReposAt) + ")")
                reposTimeCode(nSubPtr, nAbsReposAt)
              Else
                debugMsgC(sProcName, "calling reposTimeCode(" + getSubLabel(nSubPtr) + ", " + ttszt(nAbsReposAt) + ", #False, #False)")
                reposTimeCode(nSubPtr, nAbsReposAt, #False, #False)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
    
  EndIf
  
EndProcedure

Procedure PNL_sldPnlProgress_SetBackColor(h, nState)
  ; PROCNAMEC()
  
  If (nState >= #SCS_CUE_FADING_IN) And (nState <= #SCS_CUE_FADING_OUT) And (nState <> #SCS_CUE_HIBERNATING)
    SLD_setGtrAreaBackColor(gaPnlVars(h)\sldPnlProgress, grColorScheme\rColorAudioGraph\nLeftColorPlay)
  Else
    SLD_setGtrAreaBackColor(gaPnlVars(h)\sldPnlProgress, #SCS_SLD_BACKCOLOR)
  EndIf
  
EndProcedure

Procedure PNL_InUse(h)
  ProcedureReturn gaPnlVars(h)\bInUse
EndProcedure

Procedure.s PNL_Get_Name(h)
  ; return name of cue panel
  ProcedureReturn gaPnlVars(h)\sName
EndProcedure

Procedure PNL_UserControl_Initialize(h)
  PROCNAMEC()
  Protected d
  Protected nLeft, nTop, nWidth, nHeight
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  ; debugMsg(sProcName, #SCS_START)
  With gaPnlVars(h)
    ; identify sliders and set slider background colors
    If \bSlidersInitialised = #False
      SLD_setMax(\sldPnlProgress, 1000)
      For d = 0 To grCuePanels\nMaxDevLineNo
        SLD_setMax(\sldCueVol[d], #SCS_MAXVOLUME_SLD)
      Next d
    EndIf
    
    setVisible(\cvsLinked, #False)
    nLeft = GadgetX(\cvsRewind)
    nTop = GadgetY(\cvsSwitch)
    nWidth = GadgetX(\cvsSwitch) + GadgetWidth(\cvsSwitch) - GadgetX(\cvsRewind)
    nHeight = GadgetHeight(\cvsSwitch)
    ResizeGadget(\cvsLinked, nLeft, nTop, nWidth, nHeight)
    
  EndWith
  
  ; debugMsg(sProcName, "calling PNL_setPosTops")
  PNL_setPosTops(h)
  ; debugMsg(sProcName, "calling PNL_setOrigDisplaySettings")
  PNL_setOrigDisplaySettings(h)
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure PNL_createCuePanelGadgets(h, pParentContainer, pOffsetX, pOffsetY, pWidth, pHeight, pUseMainScaling=#True)
  PROCNAME(#PB_Compiler_Procedure + "(" + h + ")")
  ; this procedure must be called when the cue panel is created or resized
  Protected fMyXFactor.f = 1.0
  Protected fMyYFactor.f = 1.0
  Protected fReqdFont8Size.f
  Protected fReqdFont10Size.f
  Protected n, sNr.s
  Protected nSldYOffSet
  Protected sUCName.s
  Protected nLeft, nTop, nHeight, nWidth
  Protected nProgressSldHeight, nButtonWidth, nButtonHeight, nBorderColor, nRunningIndLeft, nM2TButtonWidth
  Static sM2T.s, sTrackM2T.s, sApply.s, sCancel.s, bStaticLoaded
  Static nM2TPrimaryWidth, nM2TWidth
  
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, #SCS_START + ", pParentContainer=G" + pParentContainer + ", pOffsetX=" + pOffsetX + ", pOffsetY=" + pOffsetY +
                        ", pWidth=" + pWidth + ", pHeight=" + pHeight + ", pUseMainScaling=" + strB(pUseMainScaling))
  CompilerEndIf
  gnCurrentCuePanelNo = h
  
  If bStaticLoaded = #False
    sM2T = " " + Lang("Main", "txtM2T") + ":"
    sTrackM2T = " " + Lang("Main", "txtTrackM2T") + " "
    sApply = Lang("Btns", "Apply")
    sCancel = Lang("Btns", "Cancel")
    bStaticLoaded = #True
  EndIf
  
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, "calling scsOpenGadgetList(G" + pParentContainer + ")")
  CompilerEndIf
  scsOpenGadgetList(pParentContainer)
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_CUE_NORMAL)
    
    With gaPnlVars(h)
      
      sUCName = \sName + "\"
      nRunningIndLeft = 272
      
      \nContainerX = pOffsetX * fMyXFactor
      \nContainerY = pOffsetY * fMyYFactor
      \nContainerWidth = pWidth * fMyXFactor
      \nContainerHeight = pHeight * fMyYFactor
; debugMsg(sProcName, "pHeight=" + pHeight + ", fMyYFactor=" + StrF(fMyYFactor,4) + ", \nContainerHeight=" + \nContainerHeight)
      
      ; free any existing gadgets
      \lnTopBorder=condFreeGadget(\lnTopBorder)
      If grLicInfo\bM2TAvailable
        \cntMoveToTimePrimary=condFreeGadget(\cntMoveToTimePrimary)
        \lblMoveToTimePrimary=condFreeGadget(\lblMoveToTimePrimary)
        \txtMoveToTime=condFreeGadget(\txtMoveToTime)
        \btnMoveToTimeApply=condFreeGadget(\btnMoveToTimeApply)
        \btnMoveToTimeCancel=condFreeGadget(\btnMoveToTimeCancel)
        \lblMoveToTimeSecondary=condFreeGadget(\lblMoveToTimeSecondary)
      EndIf
      \cvsShuffle=condFreeGadget(\cvsShuffle)
      \cvsFirst=condFreeGadget(\cvsFirst)
      \cvsRewind=condFreeGadget(\cvsRewind)
      \cvsPause=condFreeGadget(\cvsPause)
      \cvsPlay=condFreeGadget(\cvsPlay)
      \cvsRelease=condFreeGadget(\cvsRelease)
      \cvsFadeOut=condFreeGadget(\cvsFadeOut)
      \cvsStop=condFreeGadget(\cvsStop)
      \cvsSwitch=condFreeGadget(\cvsSwitch)
      \cvsLinked=condFreeGadget(\cvsLinked)
      \cvsPnlOtherInfo=condFreeGadget(\cvsPnlOtherInfo)
      \sldPnlProgress=SLD_Release(\sldPnlProgress)
      For n = 0 To grCuePanels\nMaxDevLineNo
        CompilerIf #c_cuepanel_multi_dev_select
        \cvsDevice[n]=condFreeGadget(\cvsDevice[n])
        CompilerElse
        \lblDevice[n]=condFreeGadget(\lblDevice[n])
        CompilerEndIf
        \sldCueVol[n]=SLD_Release(\sldCueVol[n])
        \sldCuePan[n]=SLD_Release(\sldCuePan[n])
      Next n
      \lblSoundCue=condFreeGadget(\lblSoundCue)
      \lblDescriptionA=condFreeGadget(\lblDescriptionA)
      \lblDescriptionB=condFreeGadget(\lblDescriptionB)
      \lblRunningInd=condFreeGadget(\lblRunningInd)
      \imgType=condFreeGadget(\imgType)
      \cntTransportCtls=condFreeGadget(\cntTransportCtls)
      \cntFaderAndPanCtls=condFreeGadget(\cntFaderAndPanCtls)
      \cntCuePanel=condFreeGadget(\cntCuePanel)
      \lnBottomBorder=condFreeGadget(\lnBottomBorder)
      
      ; create gadgets
      ; nb tried creating the container with flag #PB_Container_Raised but that cuts back the available height within the container and this
      ; caused the 4th level/pan sliders to be partially obscured. would need to make some compensating adjustment if 'Raised' is re-introduced.
      ; \cntCuePanel=scsContainerGadget(\nContainerX, \nContainerY, \nContainerWidth, \nContainerHeight, #PB_Container_Flat, sUCName+"cntCuePanel")
      \cntCuePanel=scsContainerGadget(\nContainerX, \nContainerY, \nContainerWidth, \nContainerHeight, 0, sUCName+"cntCuePanel")
        \nFirstGadgetId = \cntCuePanel
        
        \lnTopBorder=scsLineGadget(0,0,\nContainerWidth,1,#SCS_Grey,0,sUCName+"lnTopBorder")
        nTop = 1
        \lblSoundCue=scsTextGadget(0, nTop, 80, 20, "", #PB_Text_Center, sUCName+"lblSoundCue")
        \imgType=scsImageGadget(2, nTop+2, 16, 16, 0,0,sUCName+"imgType")
        \lblDescriptionA=scsTextGadget(81, nTop, 302, 20, "", 0, sUCName+"lblDescriptionA")
        \lblDescriptionB=scsTextGadget(81, nTop, 302, 20, "", #PB_Text_Center, sUCName+"lblDescriptionB")
        setVisible(\lblDescriptionB, #False)
        
        nTop + 20
        nProgressSldHeight = 16
        ; make odd
        nProgressSldHeight >> 1
        nProgressSldHeight << 1
        nProgressSldHeight + 1
        \sldPnlProgress=SLD_New(sUCName+"CP_Progress", \cntCuePanel, 0, 0, nTop, 271, nProgressSldHeight, #SCS_ST_PROGRESS, 0, 1000, 0, #SCS_SLD_NO_BASE, #True, #True, #True, "", "", #False, h)
        
        nTop + nProgressSldHeight
        \cntTransportCtls=scsContainerGadget(0,nTop,158,16,0,sUCName+"cntTransportCtls")
          nButtonWidth = 20
          nButtonHeight = 14
          \cvsShuffle=scsStandardCanvasButton(0, 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_SHUFFLE, sUCName+"cvsShuffle")
          \cvsFirst=scsStandardCanvasButton(GadgetX(\cvsShuffle), 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_FIRST, sUCName+"cvsFirst")  ; 'Shuffle' and 'First' are mutually exclusive
          setVisible(\cvsFirst, #False)
          \cvsRewind=scsStandardCanvasButton(gnNextX, 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_REWIND, sUCName+"cvsRewind")
          \cvsPlay=scsStandardCanvasButton(gnNextX, 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_PLAY, sUCName+"cvsPlay")
          \cvsPause=scsStandardCanvasButton(GadgetX(\cvsPlay), 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_PAUSE, sUCName+"cvsPause") ; 'Play' and 'Pause' are mutually exclusive
          setVisible(\cvsPause, #False)
          \cvsRelease=scsStandardCanvasButton(gnNextX, 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_RELEASE, sUCName+"cvsRelease")
          \cvsFadeOut=scsStandardCanvasButton(gnNextX, 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_FADEOUT, sUCName+"cvsFadeOut")
          \cvsStop=scsStandardCanvasButton(gnNextX, 0, nButtonWidth, nButtonHeight, #SCS_STANDARD_BTN_STOP, sUCName+"cvsStop")
          \cvsSwitch=scsCanvasGadget(gnNextX+1, 0, 38, nButtonHeight, 0, sUCName+"cvsSwitch")
          \cvsLinked=scsCanvasGadget(0, 0, (GadgetX(\cvsSwitch) + GadgetWidth(\cvsSwitch)), nButtonHeight, 0, sUCName+"cvsLinked")
          setVisible(\cvsLinked, #False)
        scsCloseGadgetList()
        
        If grLicInfo\bM2TAvailable
          nLeft = GadgetX(\cntTransportCtls)
          nTop = GadgetY(\cntTransportCtls)
          nHeight = GadgetHeight(\cntTransportCtls)
          ; nb all of the following will be resized in PNL_Resize()
          ; If h = 0 ; Commented out 13Feb2022 11.9.0rc7h following email from Jason Mai that pointed out that in non-linear run mode, only the first cue in the cue panels would accept M2T
          nWidth = nRunningIndLeft
          nM2TButtonWidth = 30
          \cntMoveToTimePrimary=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0, sUCName+"cntMoveToTimePrimary")
            If nM2TPrimaryWidth = 0
              \lblMoveToTimePrimary=scsTextGadget(0, 1, 50, 15, sM2T, 0, sUCName+"lblMoveToTimePrimary")
              setGadgetWidth(\lblMoveToTimePrimary, -1, #True)
              nM2TPrimaryWidth = GadgetWidth(\lblMoveToTimePrimary)
              \txtMoveToTime=scsStringGadget(gnNextX+gnGap, 0, 40, 16, "12:34.567", 0, sUCName+"txtMoveToTime")
              setGadgetWidth(\txtMoveToTime, 20, #True)
              SGT(\txtMoveToTime, "")
              nM2TWidth = GadgetWidth(\txtMoveToTime)
            Else
              \lblMoveToTimePrimary=scsTextGadget(0, 1, nM2TPrimaryWidth, 15, sM2T, 0, sUCName+"lblMoveToTimePrimary")
              \txtMoveToTime=scsStringGadget(gnNextX+gnGap, 0, nM2TWidth, 16, "", 0, sUCName+"txtMoveToTime")
            EndIf
            nWidth = GadgetWidth(\cntMoveToTimePrimary) - gnNextX - ((nM2TButtonWidth + 2) * 2)
            \sldMoveToTimePosition=SLD_New(sUCName+"CP_M2T", \cntMoveToTimePrimary, 0, gnNextX, 1, nWidth, 15, #SCS_ST_POSITION, 0, 1000, 0, #SCS_SLD_NO_BASE, #True, #True, #True)
            ; debugMsg(sProcName, "SLD_gadgetY(\sldMoveToTimePosition)=" + SLD_gadgetY(\sldMoveToTimePosition))
            \btnMoveToTimeApply=scsButtonGadget(gnNextX+2, 0, nM2TButtonWidth, 15, sApply, #PB_Button_Default, sUCName+"btnMoveToTimeApply")
            \btnMoveToTimeCancel=scsButtonGadget(gnNextX+2, 0, nM2TButtonWidth, 15, sCancel, 0, sUCName+"btnMoveToTimeCancel")
          scsCloseGadgetList()
          ResizeGadget(\cntMoveToTimePrimary, #PB_Ignore, #PB_Ignore, gnNextX+2, #PB_Ignore)
          setVisible(\cntMoveToTimePrimary, #False)
          ; Else ; Commented out 13Feb2022 11.9.0rc7h (see info above)
          nWidth = 50
          \lblMoveToTimeSecondary=scsTextGadget(nLeft, nTop, nWidth, nHeight, sTrackM2T, 0, sUCName+"lblMoveToTimeSecondary")
          SetGadgetColor(\lblMoveToTimeSecondary, #PB_Gadget_FrontColor, #SCS_Grey)
          setVisible(\lblMoveToTimeSecondary, #False)
          ; EndIf ; Commented out 13Feb2022 11.9.0rc7h (see info above)
        EndIf
        
        nTop = GadgetY(\lblSoundCue)
        \cntFaderAndPanCtls=scsContainerGadget(384,nTop,306,56,0,sUCName+"cntFaderAndPanCtls")
          \nSliderOrigVerticalSpace = 14
          nSldYOffSet = 0
          For n = 0 To grCuePanels\nMaxDevLineNo ; was 3
            If n < 10
              sNr = "[0" + n + "]"
            Else
              sNr = "[" + n + "]"
            EndIf
            CompilerIf #c_cuepanel_multi_dev_select
              \cvsDevice[n]=scsCanvasGadget(0, nSldYOffSet, 67, 13, 0, sUCName+"cvsDevice"+sNr)
            CompilerElse
              \lblDevice[n]=scsTextGadget(0, nSldYOffSet, 67, 13, "", #PB_Text_Right, sUCName+"lblDevice"+sNr)
            CompilerEndIf
            \sldCueVol[n]=SLD_New(sUCName+"sldCueVol"+sNr, \cntFaderAndPanCtls, 0, 70, nSldYOffSet, 117, 13, #SCS_ST_HLEVELRUN, 0, 1000, 0, #SCS_SLD_NO_BASE, #True, #True, #True, "", "", #False, h, n)
            \sldCuePan[n]=SLD_New(sUCName+"sldCuePan"+sNr, \cntFaderAndPanCtls, 0, 189, nSldYOffSet, 117, 13, #SCS_ST_PAN, 0, 1000, 500, #SCS_SLD_NO_BASE, #True, #True, #True, "", "", #False, h, n)
            nSldYOffSet + \nSliderOrigVerticalSpace
          Next n
          
        scsCloseGadgetList()
        \nCntFaderAndPanCtlsStdHeight = GadgetHeight(\cntFaderAndPanCtls)
        
        nTop = GadgetY(\lblSoundCue) + 20
        \lblRunningInd=scsTextGadget(nRunningIndLeft, nTop, 111, 16, "", #PB_Text_Center, sUCName+"lblRunningInd")
        If grMain\nRunningIndDesignWidth = 0
          grMain\nRunningIndDesignWidth = GadgetWidth(\lblRunningInd)
          ; debugMsg(sProcName, "grMain\nRunningIndDesignWidth=" + grMain\nRunningIndDesignWidth)
        EndIf
        nLeft = GadgetX(\cntTransportCtls) + GadgetWidth(\cntTransportCtls) + gnGap2
        nTop = GadgetY(\cntTransportCtls) + GadgetY(\cvsLinked)
        nHeight = GadgetHeight(\cvsLinked)
        \cvsPnlOtherInfo=scsCanvasGadget(nLeft, nTop, 219, nHeight, 0, sUCName+"cvsPnlOtherInfo")
        If grColorScheme\sSchemeName = #SCS_COL_DEF_SCHEME_NAME And #c_color_scheme_classic
          nBorderColor = changeColorBrightness(grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor, 0.2)
        Else
          nBorderColor = #SCS_Grey
        EndIf
        \lnBottomBorder=scsLineGadget(0, \nContainerHeight-1, \nContainerWidth, 1, nBorderColor, 0, sUCName+"lnBottomBorder")
        
        \nLastGadgetId = \lnBottomBorder
        
      scsCloseGadgetList()
      
      scsSetGadgetFont(\lblSoundCue, #SCS_FONT_CUE_NORMAL10)
      scsSetGadgetFont(\lblDescriptionA, #SCS_FONT_CUE_NORMAL10)
      scsSetGadgetFont(\lblDescriptionB, #SCS_FONT_CUE_NORMAL10)
      For n = 0 To grCuePanels\nMaxDevLineNo
        CompilerIf #c_cuepanel_multi_dev_select
        setVisible(\cvsDevice[n], #False)
        CompilerElse
        setVisible(\lblDevice[n], #False)
        CompilerEndIf
        SLD_setVisible(\sldCueVol[n], #False)
        SLD_setVisible(\sldCuePan[n], #False)
      Next n
      
    EndWith
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
  scsCloseGadgetList()
  
  gnCurrentCuePanelNo = -1
  
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, #SCS_END)
  CompilerEndIf
  
EndProcedure

Procedure PNL_arrangeSliders(h)
  PROCNAMECP(h)
  Protected n

  ; debugMsg(sProcName, #SCS_START)
  ; Debug sProcName
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  With gaPnlVars(h)
    For n = 0 To grCuePanels\nMaxDevLineNo
      ; debugMsg(sProcName, "\nPosTop[" + n +"]=" + Str(\nPosTop[n]))
      CompilerIf #c_cuepanel_multi_dev_select
      ResizeGadget(\cvsDevice[n], #PB_Ignore, \nPosTop[n], #PB_Ignore, #PB_Ignore)
      CompilerElse
      ResizeGadget(\lblDevice[n], #PB_Ignore, \nPosTop[n], #PB_Ignore, #PB_Ignore)
      CompilerEndIf
      SLD_ResizeGadget(sProcName, \sldCueVol[n], #PB_Ignore, \nPosTop[n], #PB_Ignore, #PB_Ignore)
      SLD_Resize(\sldCueVol[n], #False)
      SLD_ResizeGadget(sProcName, \sldCuePan[n], #PB_Ignore, \nPosTop[n], #PB_Ignore, #PB_Ignore)
      SLD_Resize(\sldCuePan[n], #False)
    Next n
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_sldCuePan_Common(h, nDevNo, nValue)
  PROCNAMEC()
  Protected nAudPtr, fPan.f
  Protected sText.s

  nAudPtr = gaDispPanel(h)\nDPAudPtr
  If nAudPtr >= 0
    ; nAudPtr may be negative if display panel changed during scroll
    With aAud(nAudPtr)
      fPan = panSliderValToSingle(nValue)
      ; debugMsg(sProcName, "nValue=" + nValue + ", fPan=" + StrF(fPan,4))
      \bCuePanManual[nDevNo] = #True
      \fPan[nDevNo] = fPan
      \fCuePanNow[nDevNo] = fPan
      If \bAudTypeF Or \bAudTypeP Or \bAudTypeI
        If gbUseBASS
          CompilerIf #cTraceSetLevels
            debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nAudPtr) + ", " + nDevNo + ", #SCS_NOVOLCHANGE_SINGLE, fPan)")
          CompilerEndIf
          setLevelsAny(nAudPtr, nDevNo, #SCS_NOVOLCHANGE_SINGLE, fPan)
        Else ; SM-S
          samAddRequest(#SCS_SAM_SET_AUD_DEV_PAN, nAudPtr, fPan, nDevNo)
        EndIf
      ElseIf \bAudTypeA
        setLevelsVideo(nAudPtr, nDevNo, #SCS_NOVOLCHANGE_SINGLE, fPan, \nAudVidPicTarget)
      EndIf
      
      If \bAudTypeForP
        If \bAffectedByLevelChange
          If \nLevelChangeSubPtr >= 0
            If aSub(\nLevelChangeSubPtr)\nLCAction = #SCS_LC_ACTION_ABSOLUTE  ; absolute level change, not relative level change
              ; debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nLevelChangeSubPtr) + ")")
              addToSaveSettings(\nLevelChangeSubPtr)
              setSaveSettings()
            EndIf
          Else
            ; debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nSubIndex) + ")")
            addToSaveSettings(\nSubIndex)
            setSaveSettings()
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure PNL_sldCueVol_Common(h, nDevNo, fBVLevel.f)
  PROCNAMECP(h)
  Protected nAudPtr, sLevelCaption.s, fBVLevelForSMS.f
  
  ; debugMsg(sProcName, #SCS_START + ", h=" + h + ", nDevNo=" + nDevNo + ", fBVLevel=" + formatLevel(fBVLevel))
  
  nAudPtr = gaDispPanel(h)\nDPAudPtr
  If nAudPtr >= 0
    ; nAudPtr may be negative if display panel changed during scroll
    With aAud(nAudPtr)
      \bCueVolManual[nDevNo] = #True
      \fBVLevel[nDevNo] = fBVLevel
      \fCueVolNow[nDevNo] = fBVLevel
      \fCueTotalVolNow[nDevNo] = \fCueVolNow[nDevNo]
      CompilerIf #cTraceCueTotalVolNow
        debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\fAudPlayBVLevel[" + nDevNo + "]=" + traceLevel(\fAudPlayBVLevel[nDevNo]) +
                            ", \fCueTotalVolNow[" + nDevNo + "]=" + traceLevel(\fCueTotalVolNow[nDevNo]))
      CompilerEndIf
      If (\bAudTypeF) Or (\bAudTypeP) Or (\bAudTypeI) ; \bAudTypeF Or \bAudTypeP Or \bAudTypeI
        If gbUseBASS
          CompilerIf #cTraceSetLevels
            debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nAudPtr) + ", " + nDevNo + ", " + traceLevel(fBVLevel) + ", #SCS_NOPANCHANGE_SINGLE)")
          CompilerEndIf
          setLevelsAny(nAudPtr, nDevNo, fBVLevel, #SCS_NOPANCHANGE_SINGLE)
        Else ; SM-S
          fBVLevelForSMS = fBVLevel
          ; debugMsg(sProcName, "fBVLevel=" + formatLevel(fBVLevel) + ", fBVLevelForSMS=" + formatLevel(fBVLevelForSMS))
          ; debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, " + getAudLabel(nAudPtr) + ", " + formatLevel(fBVLevelForSMS) + ", " + nDevNo + ")")
          samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, nAudPtr, fBVLevelForSMS, nDevNo)
        EndIf
      ElseIf \bAudTypeA   ; \bAudTypeA
        setLevelsVideo(nAudPtr, nDevNo, fBVLevel, #SCS_NOPANCHANGE_SINGLE, \nAudVidPicTarget)
      EndIf
      
      Select \nAudState
        Case #SCS_CUE_FADING_IN, #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_IN, #SCS_CUE_TRANS_FADING_OUT, #SCS_CUE_TRANS_MIXING_OUT
          \nAudState = #SCS_CUE_PLAYING
          setCueState(\nCueIndex)
      EndSelect
      
      If \bAudTypeAorF Or \bAudTypeP
        If \nLevelChangeSubPtr >= 0
          If aSub(\nLevelChangeSubPtr)\nLCAction = #SCS_LC_ACTION_ABSOLUTE  ; absolute level change, not relative level change
            ; debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nLevelChangeSubPtr) + ")")
            addToSaveSettings(\nLevelChangeSubPtr)
            setSaveSettings()
          EndIf
        Else
          ; debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(\nSubIndex) + ")")
          addToSaveSettings(\nSubIndex)
          setSaveSettings()
        EndIf
        \bIncDecLevelSet = #False
      EndIf
      
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_setSliderSizes(h)
  ; PROCNAMECP(h)
  Protected nAdj, nHotkeyAdj

  ; debugMsg(sProcName, #SCS_START)
  
  With gaPnlVars(h)
    If getVisible(WMN\treHotkeys) = #False
      nHotkeyAdj = GadgetWidth(WMN\treHotkeys)
    EndIf
    
    ; the 'B' settings are used if there are up to 4 devices
    \nSldVolLeftB = (\nSldCueVolOrigLeft * gfMainPnlXFactor) + nHotkeyAdj
    \nSldVolWidthB = (\nSldCueVolOrigWidth * gfMainPnlXFactor)
    \nSldPanLeftB = (\nSldCuePanOrigLeft * gfMainPnlXFactor) + nHotkeyAdj
    \nSldPanWidthB = (\nSldCuePanOrigWidth * gfMainPnlXFactor)
    
    ; the 'A' settings are used if there are 5 or more devices
    nAdj = \nSldVolWidthB / 4
    \nSldVolLeftA = \nSldVolLeftB
    \nSldVolWidthA = \nSldVolWidthB + nAdj
    \nSldPanLeftA = \nSldPanLeftB + nAdj
    \nSldPanWidthA = \nSldPanWidthB - nAdj
    
  EndWith

EndProcedure

Procedure PNL_adjustRunningIndSizeIfReqd(h)
  PROCNAMECP(h)
  ; This procedure was created 4Jul2018 11.7.1 following an email from Christian Peters regarding the content of the 'running ind' overflowing
  ; with an 'on cue marker' setting, eg 'ocm Q123 MK1a (14.50 as Q100)', especially when the option 'cue panel height' is set to 120%.
  ; The procedure allows \lblRunningInd to be expanded up to 50% if necessary (capped at 50% increase), and should be called after setting
  ; text in \lblRunningInd (although not necessary for timecode updates etc)
  Protected nGadgetNo, nWidth, nReqdWidth, nThisReqdWidth
  
  nGadgetNo = gaPnlVars(h)\lblRunningInd
  nWidth = GadgetWidth(nGadgetNo)
  nReqdWidth = GadgetWidth(nGadgetNo, #PB_Gadget_RequiredSize)
  ; debugMsg(sProcName, "GGT(nGadgetNo)=" + GGT(nGadgetNo) + ", nWidth=" + nWidth + ", nReqdWidth=" + nReqdWidth + ", grMain\nRunningIndDesignWidth=" + grMain\nRunningIndDesignWidth)
  If nReqdWidth <= grMain\nRunningIndDesignWidth
    If nWidth > grMain\nRunningIndDesignWidth
      nThisReqdWidth = grMain\nRunningIndDesignWidth
    EndIf
  ElseIf nReqdWidth < (grMain\nRunningIndDesignWidth * 1.5)
    nThisReqdWidth = nReqdWidth
  Else
    nThisReqdWidth = (grMain\nRunningIndDesignWidth * 1.5)
  EndIf
  If nThisReqdWidth
    ResizeGadget(nGadgetNo, #PB_Ignore, #PB_Ignore, nThisReqdWidth, #PB_Ignore)
    CompilerIf #cTraceGadgets
      debugMsg(sProcName, "ResizeGadget(" + getGadgetName(nGadgetNo) + ", #PB_Ignore, #PB_Ignore, " + nThisReqdWidth + ", #PB_Ignore)")
    CompilerEndIf
  EndIf
  
EndProcedure

Procedure PNL_adjustSliderSizes(h, fReqdYFactor.f=0)
  PROCNAMECP(h)
  Protected d
  Protected nLeft
  Protected nCntWidth

  ; debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  With gaPnlVars(h)
    ; debugMsg(sProcName, "gaDispPanel(" + h + ")\sSubType=" + gaDispPanel(h)\sSubType + ", gaPnlVars(" + h +")\nSldVolLeftA=" + Str(\nSldVolLeftA))
    nCntWidth = \nSldPanLeftB + \nSldPanWidthB
    ResizeGadget(\cntFaderAndPanCtls, #PB_Ignore, #PB_Ignore, nCntWidth, #PB_Ignore)
    ; debugMsg(sProcName, "GadgetWidth(\cntCuePanel)=" + GadgetWidth(\cntCuePanel) + ", GadgetWidth(\cntFaderAndPanCtls)=" + GadgetWidth(\cntFaderAndPanCtls))
    If gaDispPanel(h)\nMaxDev <= (grCuePanels\nMaxDevLineNo)
      CompilerIf #c_cuepanel_multi_dev_select
        nLeft = \nSldVolLeftA - GadgetWidth(\cvsDevice[0]) - 4
      CompilerElse
        nLeft = \nSldVolLeftA - GadgetWidth(\lblDevice[0]) - 4
      CompilerEndIf
      ; debugMsg(sProcName, "\nSldVolLeftA=" + \nSldVolLeftA + ", GadgetWidth(\lblDevice[0])=" + GadgetWidth(\lblDevice[0]) + ", nLeft for \lblDevice[]=" + nLeft)
      For d = 0 To grCuePanels\nMaxDevLineNo
        CompilerIf #c_cuepanel_multi_dev_select
          ResizeGadget(\cvsDevice[d], nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        CompilerElse
          ResizeGadget(\lblDevice[d], nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        CompilerEndIf
        SLD_ResizeGadget(sProcName, \sldCuePan[d], \nSldPanLeftA, #PB_Ignore, \nSldPanWidthA, #PB_Ignore)
        ; debugMsg(sProcName, "SLD_ResizeGadget(sProcName, \sldCuePan[" + d + "], " + \nSldPanLeftA + ", #PB_Ignore, " + \nSldPanWidthA + ", #PB_Ignore)")
        SLD_Resize(\sldCuePan[d], #False, fReqdYFactor)
        SLD_ResizeGadget(sProcName, \sldCueVol[d], \nSldVolLeftA, #PB_Ignore, \nSldVolWidthA, #PB_Ignore)
        ; debugMsg(sProcName, "SLD_ResizeGadget(sProcName, \sldCueVol[" + d + "], " + \nSldVolLeftA + ", #PB_Ignore, " + \nSldVolWidthA + ", #PB_Ignore)")
        SLD_Resize(\sldCueVol[d], #False, fReqdYFactor)
      Next d
    Else
      CompilerIf #c_cuepanel_multi_dev_select
      nLeft = \nSldVolLeftB - GadgetWidth(\cvsDevice[0]) - 4
      CompilerElse
      nLeft = \nSldVolLeftB - GadgetWidth(\lblDevice[0]) - 4
      CompilerEndIf
      ; debugMsg(sProcName, "nLeft for \lblDevice[]=" + nLeft)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If d < grCuePanels\nMaxDevLines
          CompilerIf #c_cuepanel_multi_dev_select
            ResizeGadget(\cvsDevice[d], nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          CompilerElse
            ResizeGadget(\lblDevice[d], nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          CompilerEndIf
          SLD_ResizeGadget(sProcName, \sldCueVol[d], \nSldVolLeftB, #PB_Ignore, \nSldVolWidthB, #PB_Ignore)
          SLD_Resize(\sldCueVol[d], #False, fReqdYFactor)
        ElseIf d < grCuePanels\nTwiceDevLines
          SLD_ResizeGadget(sProcName, \sldCuePan[d - grCuePanels\nMaxDevLines], \nSldPanLeftB, #PB_Ignore, \nSldPanWidthB, #PB_Ignore)
          SLD_Resize(\sldCuePan[d - grCuePanels\nMaxDevLines], #False, fReqdYFactor)
        EndIf
      Next d
    EndIf
    ; debugMsg0(sProcName, "gaPnlVars(" + h + ")\sldMoveToTimePosition=" + \sldMoveToTimePosition)
    If SLD_isSlider(\sldMoveToTimePosition)
      SLD_Resize(\sldMoveToTimePosition, #False, fReqdYFactor, 0, #False, #True, #False) ; nb bChangeTop set #False to keep top margin at 1 pixel
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_colorCueAndDescription(h, nSubPtr)
  PROCNAMECS(nSubPtr)
  Protected nCueTextColor, nCueBackColor
  Protected nDescrTextColor, nDescrBackColor
  Protected nCuePtr
  
  With gaPnlVars(h)
    ; cue color
    nCueTextColor = \nTextColor
    nCueBackColor = \nBackColor
    If \bNextManualCue
      setColorsForNextManualCue(nCueBackColor, nCueTextColor, @nCueBackColor, @nCueTextColor)
    Else
      If nSubPtr >= 0
        nCuePtr = aSub(nSubPtr)\nCueIndex
        If nCuePtr >= 0
          If aCue(nCuePtr)\bCallableCue
            nCueTextColor = getTextColorFromColorScheme(#SCS_COL_ITEM_CC)
            nCueBackColor = getBackColorFromColorScheme(#SCS_COL_ITEM_CC)
          EndIf
        EndIf
      EndIf
      setColorsForOtherCues(nCueBackColor, nCueTextColor, @nCueBackColor, @nCueTextColor)
    EndIf
    
    ; description color
    If nSubPtr < 0
      nDescrTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
      nDescrBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
    Else
      If aSub(nSubPtr)\bSubTypeN
        nDescrTextColor = \nTextColor
        nDescrBackColor = \nBackColor
      Else
        If \bActiveOrComplete
          nDescrBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
          nDescrTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
        Else
          nDescrBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
          nDescrTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
        EndIf
      EndIf
    EndIf
    
    SetGadgetColors(\lblSoundCue, nCueTextColor, nCueBackColor)
    SetGadgetColors(gaPnlVars(h)\lblDescriptionA, nDescrTextColor, nDescrBackColor)
    SetGadgetColors(gaPnlVars(h)\lblDescriptionB, nDescrTextColor, nDescrBackColor)
    ; refresh image as it may have been cleared by SetGadgetColor()
    ; debugMsg(sProcName, "h=" + h + ", \bNextManualCue=" + strB(\bNextManualCue) + ", \nImageHandle=" + Str(\nImageHandle))
    If IsImage(\nImageHandle)
      ; debugMsg(sProcName, "calling SetGadgetState(" + \imgType + ", ImageID(\nImageHandle))")
      SetGadgetState(\imgType, ImageID(\nImageHandle))
    EndIf
    
  EndWith
  
EndProcedure

Procedure PNL_setShuffleAndFirstButtons(h, *pbShuffleVisible.Integer, *pbShuffleEnabled.Integer, *pbFirstVisible.Integer, *pbFirstEnabled.Integer)
  PROCNAMECP(h)
  Protected nSubPtr, nAudPtr
  Protected bShuffleVisible, bShuffleEnabled, bFirstVisible, bFirstEnabled
  Protected bPlaying
  
  With gaDispPanel(h)
    nSubPtr = \nDPSubPtr
    nAudPtr = \nDPAudPtr
  EndWith
  
  bShuffleVisible = #False
  bShuffleEnabled = #False
  bFirstVisible = #False
  bFirstEnabled = #False
  
  If (nSubPtr >= 0) And (nAudPtr >= 0)
    If aSub(nSubPtr)\bSubTypeP
      bShuffleVisible = #True
      With aAud(nAudPtr)
        If (\nPlayNo = 1) And (aSub(nSubPtr)\bPLRandom)
          If (\nAudState <= #SCS_CUE_READY) Or (\nAudState = #SCS_CUE_PL_READY) Or (\nAudState = #SCS_CUE_STANDBY)
            bShuffleEnabled = #True
          EndIf
        ElseIf (nAudPtr = aSub(nSubPtr)\nFirstPlayIndexThisRun) And (aSub(nSubPtr)\bPLSavePos)
          If (\nAudState <= #SCS_CUE_READY) Or (\nAudState = #SCS_CUE_PL_READY) Or (\nAudState = #SCS_CUE_STANDBY)
            If \nAudNo > 1
              bFirstEnabled = #True
            EndIf
          EndIf
          bFirstVisible = #True
          bShuffleVisible = #False
        EndIf
      EndWith
    EndIf
  EndIf
  setVisible(gaPnlVars(h)\cvsShuffle, bShuffleVisible)
  setEnabled(gaPnlVars(h)\cvsShuffle, bShuffleEnabled)
  setVisible(gaPnlVars(h)\cvsFirst, bFirstVisible)
  setEnabled(gaPnlVars(h)\cvsFirst, bFirstEnabled)
  
  PokeI(*pbShuffleVisible, bShuffleVisible)
  PokeI(*pbShuffleEnabled, bShuffleEnabled)
  PokeI(*pbFirstVisible, bFirstVisible)
  PokeI(*pbFirstEnabled, bFirstEnabled)

EndProcedure

Procedure PNL_setDisplayButtons(h, pPanelState, pLinkedToAudPtr, pLinkedToSubPtr=-1)
  PROCNAMECP(h)
  Protected bLiveInput
  Protected nCuePtr, nSubPtr, sSubType.s, nAudPtr
  Protected nCueState
  Protected nTransportSwitchCode
  Protected j, k, l2
  Protected bRewindVisible, bPlayVisible, bPauseVisible, bReleaseVisible, bStopVisible, bSwitchVisible
  Protected bRewindEnabled, bPlayEnabled, bPauseEnabled, bReleaseEnabled, bStopEnabled, bSwitchEnabled
  Protected bShuffleVisible, bShuffleEnabled, bFirstVisible, bFirstEnabled
  Protected bLinkedVisible, bFadeOutVisible, bFadeOutEnabled
  Protected bPicture, bDoContinuous
  Protected bPrevNextManualCue, bPrevPlaying
  Protected nBackColor, nTextColor
  Protected bMemoContinuous
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  ; debugMsg(sProcName, #SCS_START + ", pPanelState=" + decodeCueState(pPanelState) + ", pLinkedToAudPtr=" + getAudLabel(pLinkedToAudPtr) + ", pLinkedToSubPtr=" + getSubLabel(pLinkedToSubPtr))
  
  With gaDispPanel(h)
    ; debugMsg(sProcName, "gaDispPanel(" + h + ")\nDPCuePtr=" + getCueLabel(\nDPCuePtr) + ", \nDPSubPtr=" + getSubLabel(\nDPSubPtr) + ", \sDPSubType=" + \sDPSubType + ", \nDPAudPtr=" + getAudLabel(\nDPAudPtr) +
    ;                     ", \nTransportSwitchCode=" + \nTransportSwitchCode)
    nCuePtr = \nDPCuePtr
    nSubPtr = \nDPSubPtr
    sSubType = \sDPSubType
    nAudPtr = \nDPAudPtr
    nTransportSwitchCode = \nTransportSwitchCode
  EndWith
  ; debugMsg(sProcName, "nSubPtr=" + getSubLabel(nSubPtr) + ", sSubType=" + sSubType + ", nAudPtr=" + getAudLabel(nAudPtr))
  
  If nSubPtr = -1
    ProcedureReturn
  EndIf
  
  sProcName + "[" + aSub(nSubPtr)\sSubLabel + "]"
  
  If (nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE) And (nCuePtr >= 0)
    nCueState = aCue(nCuePtr)\nCueState
  ElseIf (nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB) And (nSubPtr >= 0)
    nCueState = aSub(nSubPtr)\nSubState
  ElseIf (nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_FILE) And (nAudPtr >= 0)
    nCueState = aAud(nAudPtr)\nAudState
  Else
    nCueState = pPanelState
  EndIf
  ; debugMsg(sProcName, "nCueState=" + decodeCueState(nCueState))
  
  bShuffleVisible = #False
  bFirstVisible = #False
  bRewindVisible = #False
  bPlayVisible = #False
  bPauseVisible = #False
  bReleaseVisible = #False
  bStopVisible = #False
  bSwitchVisible = #False
  
  bShuffleEnabled = #False
  bFirstEnabled = #False
  bRewindEnabled = #False
  bPlayEnabled = #False
  bPauseEnabled = #False
  bReleaseEnabled = #False
  bStopEnabled = #False
  bSwitchEnabled = #False
  
  If sSubType = "P"
    PNL_setShuffleAndFirstButtons(h, @bShuffleVisible, @bShuffleEnabled, @bFirstVisible, @bFirstEnabled)
  ElseIf sSubType = "E"
    If nSubPtr >= 0
      With aSub(nSubPtr)
        If (\bMemoContinuous) Or (\nMemoDisplayTime <= 0)
          bMemoContinuous = #True
        Else
          bMemoContinuous = #False
        EndIf
      EndWith
    EndIf
  EndIf
  
  With gaPnlVars(h)
    
    If (FindString("AIFP", sSubType) > 0) Or ((sSubType = "M") And (nAudPtr >= 0)) ; AUDIO FILE, LIVE INPUT, PLAYLIST, VIDEO OR STILL IMAGE, or CTRL SEND with a MIDI File
      If nAudPtr = -1
        ProcedureReturn
      EndIf
      If aAud(nAudPtr)\bAudTypeI
        bLiveInput = #True
      EndIf
      Select aAud(nAudPtr)\nFileFormat
        Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
          bDoContinuous = aAud(nAudPtr)\bDoContinuous
      EndSelect
      If pLinkedToAudPtr >= 0
        PNL_drawLinked(h, Lang("WMN", "LinkedTo") + " " + aAud(pLinkedToAudPtr)\sAudLabel)
        bLinkedVisible = #True
      Else
        setVisible(\cvsLinked, #False)
        bRewindVisible = #True
        bReleaseVisible = #True
        bFadeOutVisible = #True
        bStopVisible = #True
        
        If nCueState = #SCS_CUE_ERROR
          bPlayVisible = #True
          
        ; ElseIf (nCueState <= #SCS_CUE_READY) Or (nCueState >= #SCS_CUE_STANDBY) Or (nCueState = #SCS_CUE_PL_READY)
        ; fix 27Dec2018 11.8.0cm changed "nCueState <= #SCS_CUE_READY" to "nCueState < #SCS_CUE_FADING_IN" so that countdown state is not regarded as playing for the purpose of setting transport control buttons
        ElseIf (nCueState < #SCS_CUE_FADING_IN) Or (nCueState >= #SCS_CUE_STANDBY) Or (nCueState = #SCS_CUE_PL_READY)
          If (aAud(nAudPtr)\nAudState = #SCS_CUE_READY) And (getAudPlayingPos(nAudPtr) > 0) And (bLiveInput = #False) And (bDoContinuous = #False)
            bRewindEnabled = #True
          EndIf
          bPlayVisible = #True
          bPlayEnabled = #True
          
        Else
          If (bLiveInput = #False) And (bDoContinuous = #False)
            bRewindEnabled = #True
          EndIf
          If nCueState = #SCS_CUE_PAUSED
            bPlayVisible = #True
            bPlayEnabled = #True
          Else
            bPauseVisible = #True
            If bDoContinuous = #False
              bPauseEnabled = #True
            EndIf
          EndIf
          If bLiveInput = #False
            l2 = aAud(nAudPtr)\nCurrLoopInfoIndex
            If l2 >= 0
              If aAud(nAudPtr)\aLoopInfo(l2)\bLoopReleased = #False
                bReleaseEnabled = gaDispPanel(h)\bEnableRelease
              EndIf
            EndIf
          EndIf
          If nCueState = #SCS_CUE_PAUSED Or nCueState = #SCS_CUE_FADING_OUT
            ; no action
          Else
            bFadeOutEnabled = gaDispPanel(h)\bEnableFadeOut
          EndIf
          bStopEnabled = #True
          bStopEnabled = #True
        EndIf
        bRewindVisible = #True
        bReleaseVisible = #True
        bFadeOutVisible = #True
        bStopVisible = #True
      EndIf
      
    ElseIf sSubType = "E"
      ;SetGadgetText(\lblLinked, "")
      If nCueState = #SCS_CUE_PLAYING
        If bMemoContinuous = #False
          bPauseVisible = #True
          bPauseEnabled = #True
          ; bRewindVisible = #True
          bRewindEnabled = #True
        EndIf
        bStopEnabled = #True
      ElseIf nCueState = #SCS_CUE_PAUSED
        bPlayVisible = #True
        bPlayEnabled = #True
        bRewindVisible = #True
        bRewindEnabled = #True
        bStopEnabled = #True
      Else
        bPlayVisible = #True
        bPlayEnabled = #True
      EndIf
      If bMemoContinuous = #False
        bRewindVisible = #True
        ; bRewindEnabled = #True  ; commented out 27Dec2018 11.8.0cm - Memo rewind button should not be enabled if the sub-cue is not playing
      EndIf
      bStopVisible = #True
      If nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
        bReleaseVisible = #True
        bFadeOutVisible = #True
      Else
        bShuffleVisible - #False
        bFirstVisible = #False
        bReleaseVisible = #False
        bFadeOutVisible = #False
      EndIf
      
    ElseIf sSubType = "U"
      If pLinkedToSubPtr >= 0
        PNL_drawLinked(h, Lang("WMN", "LinkedTo") + " " + getSubLabel(pLinkedToSubPtr))
        bLinkedVisible = #True
      Else
        ; SetGadgetText(\lblLinked, "")
        If (nCueState < #SCS_CUE_FADING_IN)
          bPlayVisible = #True
          bPlayEnabled = #True
        ElseIf (nCueState = #SCS_CUE_PAUSED)
          bPlayVisible = #True
          bPlayEnabled = #True
          bRewindEnabled = #True
          bRewindEnabled = #True
        ElseIf (nCueState > #SCS_CUE_FADING_OUT)
          bPlayVisible = #True
        Else
          bPauseVisible = #True
          bPauseEnabled = #True
          bRewindEnabled = #True
          bStopEnabled = #True
        EndIf
        bRewindVisible = #True
        bStopVisible = #True
        If nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
          bReleaseVisible = #True
          bFadeOutVisible = #True
        Else
          bShuffleVisible - #False
          bFirstVisible = #False
          bReleaseVisible = #False
          bFadeOutVisible = #False
        EndIf
      EndIf
      
    Else  ; If FindString("KLMNS", sSubType, 1) > 0    ; LIGHTING, LEVEL CHANGE, CONTROL SEND, NOTE OR SFR
      ; If nCueState <= #SCS_CUE_READY
      ; fix 27Dec2018 11.8.0cm changed "nCueState <= #SCS_CUE_READY" to "nCueState < #SCS_CUE_FADING_IN" so that countdown state is not regarded as playing for the purpose of setting transport control buttons
      If nCueState < #SCS_CUE_FADING_IN
        bPlayVisible = #True
        bPlayEnabled = #True
      Else
        bPlayVisible = #True
        setEnabled(\cvsPlay, #False)
      EndIf
      If nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE
        bRewindVisible = #True
        bReleaseVisible = #True
        bFadeOutVisible = #True
        bStopVisible = #True
      Else
        bShuffleVisible = #False
        bFirstVisible = #False
      EndIf
    EndIf
    
    If (nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE) Or (nTransportSwitchCode = 0)   ; modifed 21Aug2017 11.7.0
      bShuffleEnabled = #False
      j = aCue(nCuePtr)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled ; Test added 2Oct2021 11.8.6at following email from David Preece
          If aSub(j)\bSubTypeP
            If aSub(j)\bSubPlaceHolder = #False ; added place holder test 11Feb2019 11.8.0.2ap following bug report from Paul Carpenter
              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nFirstPlayIndex=" + aSub(j)\nFirstPlayIndex + ", \nFirstAudIndex=" + aSub(j)\nFirstAudIndex)
              If aAud(aSub(j)\nFirstPlayIndex)\nAudState <= #SCS_CUE_READY
                bShuffleEnabled = #True
              EndIf
            EndIf
          EndIf
          If aSub(j)\bSubTypeHasAuds
            If aSub(j)\bSubPlaceHolder = #False ; added place holder test 11Feb2019 11.8.0.2ap following bug report from Paul Carpenter
              k = aSub(j)\nFirstPlayIndex
              While k >= 0
                If aAud(k)\nLinkedToAudPtr = -1
                  If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
                    bRewindEnabled = #True
                    bStopEnabled = #True
                    If (aAud(k)\nMaxLoopInfo >= 0) And (aAud(k)\rCurrLoopInfo\bLoopReleased = #False)
                      bReleaseEnabled = #True
                    EndIf
                  EndIf
                EndIf
                k = aAud(k)\nNextPlayIndex
              Wend
            EndIf
          EndIf ; EndIf aSub(j)\bSubTypeHasAuds
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf (nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE) Or (nTransportSwitchCode = 0)
    
    setVisible(\cvsLinked, bLinkedVisible)
    setVisible(\cvsShuffle, bShuffleVisible)
    setVisible(\cvsFirst, bFirstVisible)
    setVisible(\cvsRewind, bRewindVisible)
    setVisible(\cvsPlay, bPlayVisible)
    setVisible(\cvsPause, bPauseVisible)
    setVisible(\cvsRelease, bReleaseVisible)
    setVisible(\cvsFadeOut, bFadeOutVisible)
    setVisible(\cvsStop, bStopVisible)
    setVisible(\cvsSwitch, bSwitchVisible)
    
    setEnabled(\cvsShuffle, bShuffleEnabled)
    setEnabled(\cvsFirst, bFirstEnabled)
    setEnabled(\cvsRewind, bRewindEnabled)
    setEnabled(\cvsPlay, bPlayEnabled)
    setEnabled(\cvsPause, bPauseEnabled)
    setEnabled(\cvsRelease, bReleaseEnabled)
    setEnabled(\cvsFadeOut, bFadeOutEnabled)
    setEnabled(\cvsStop, bStopEnabled)
    setEnabled(\cvsSwitch, bSwitchEnabled)
    
    redrawCvsBtn(\cvsFadeOut)
    redrawCvsBtn(\cvsFirst)
    redrawCvsBtn(\cvsPause)
    redrawCvsBtn(\cvsPlay)
    redrawCvsBtn(\cvsRelease)
    redrawCvsBtn(\cvsFadeOut)
    redrawCvsBtn(\cvsRewind)
    redrawCvsBtn(\cvsShuffle)
    redrawCvsBtn(\cvsStop)
    
    bPrevNextManualCue = \bNextManualCue
    ; debugMsg(sProcName, "gaPnlVars(" + h + ")\bNextManualCue=" + strB(\bNextManualCue))
    bPrevPlaying = \bPlaying
    PNL_setRunningInd(h, pPanelState)   ; nb use pPanelState, not nCueState as RunningInd is not affected by cboSwitch
    If (\bNextManualCue <> bPrevNextManualCue) ; Or (\bPlaying <> bPrevPlaying)
      PNL_colorCueAndDescription(h, nSubPtr)
    EndIf
    
  EndWith
  
EndProcedure

Procedure PNL_setReleaseBtnState(h)
  ; PROCNAMECP(h)
  Protected nCuePtr, nSubPtr, nAudPtr
  Protected nTransportSwitchCode
  Protected j, k, l2
  Protected bReleaseEnabled
  
  ; ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  With gaDispPanel(h)
    nCuePtr = \nDPCuePtr
    nSubPtr = \nDPSubPtr
    nAudPtr = \nDPAudPtr
    nTransportSwitchCode = \nTransportSwitchCode
    ; debugMsg(sProcName, "nCuePtr=" + getCueLabel(nCuePtr) + ", nSubPtr=" + getSubLabel(nSubPtr) + ", nAudPtr=" + getAudLabel(nAudPtr) +
    ;                     ", nTransportSwitchCode=" + nTransportSwitchCode + ", #SCS_TRANSPORT_SWITCH_CUE=" + #SCS_TRANSPORT_SWITCH_CUE)
  EndWith
  
  If nSubPtr = -1
    ProcedureReturn
  EndIf
  
  With gaPnlVars(h)
    ; If (nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_CUE) Or (nTransportSwitchCode = 0)   ; commented out 25Aug2017 11.7.0 - not sure why this test is here
      j = aCue(nCuePtr)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeHasAuds
          k = aSub(j)\nFirstPlayIndex
          While k >= 0
            If aAud(k)\nLinkedToAudPtr = -1
              If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nCurrLoopInfoIndex=" + aAud(k)\nCurrLoopInfoIndex +
                ;                     ", aAud(" + getAudLabel(k) + ")\rCurrLoopInfo\bLoopReleased=" + strB(aAud(k)\rCurrLoopInfo\bLoopReleased))
                If (aAud(k)\nMaxLoopInfo >= 0) And (aAud(k)\rCurrLoopInfo\bLoopReleased = #False)
                  bReleaseEnabled = #True
                EndIf
              EndIf
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
      ; debugMsg(sProcName, "bReleaseEnabled=" + strB(bReleaseEnabled))
      setEnabled(\cvsRelease, bReleaseEnabled)
    ; EndIf
  EndWith

EndProcedure

Procedure PNL_setActiveOrComplete(h, pPanelState)
  PROCNAMECP(h)
  
  With gaPnlVars(h)
    Select pPanelState
      Case #SCS_CUE_COUNTDOWN_TO_START To #SCS_CUE_FADING_OUT, #SCS_CUE_COMPLETED
        \bActiveOrComplete = #True
      Default
        \bActiveOrComplete = #False
    EndSelect
  EndWith
  
EndProcedure

Procedure PNL_setRunningInd(h, pPanelState)
  PROCNAMECP(h)
  Protected sText.s
  Protected nBackColor, nTextColor, bColorsSet
  Protected bNextManualCue, bPlaying
  Protected nCuePtr, nSubPtr
  Static bStaticLoaded
  Static sStopping.s, nLenStopping
  Static sFadingOut.s, nLenFadingOut
  Static sReady.s
  Static sNextManualCue.s
  
  If bStaticLoaded = #False
    sStopping = Trim(decodeCueStateL(#SCS_CUE_STOPPING))
    nLenStopping = Len(sStopping)
    sFadingOut = Trim(decodeCueStateL(#SCS_CUE_FADING_OUT))
    nLenFadingOut = Len(sFadingOut)
    sReady = Trim(decodeCueStateL(#SCS_CUE_READY))
    sNextManualCue = grText\sTextNextManualCue
    bStaticLoaded = #True
  EndIf
  
  With gaPnlVars(h)
    ; debugMsg(sProcName, #SCS_START + ", gaPnlVars(" + h + ")\lblSoundCue=" + Trim(GGT(\lblSoundCue)) + ", \lblRunningInd=" + GGT(\lblRunningInd))
    
    ; debugMsg(sProcName, "pPanelState=" + decodeCueState(pPanelState) + ", lblRunningInd=" + sText + ", \m_nCuePtr=" + getCueLabel(\m_nCuePtr) + ", gnCueToGo=" + getCueLabel(gnCueToGo))
    
    PNL_setActiveOrComplete(h, pPanelState)
    
    Select pPanelState
      Case #SCS_CUE_FADING_IN To #SCS_CUE_FADING_OUT
        bPlaying = #True
        If gaDispPanel(h)\nDPSubPtr >= 0
          If aSub(gaDispPanel(h)\nDPSubPtr)\bSubTypeU
            grMTCSendControl\nMTCPanelIndex = h
            grMTCSendControl\nRunningIndGadgetNo = \lblRunningInd
          EndIf
        EndIf
        
      Case #SCS_CUE_COUNTDOWN_TO_START, #SCS_CUE_SUB_COUNTDOWN_TO_START, #SCS_CUE_PL_COUNTDOWN_TO_START
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_CT]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_CT]\nTextColor
        bColorsSet = #True
        
      Case #SCS_CUE_NOT_LOADED
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
        bColorsSet = #True
        
      Case #SCS_CUE_COMPLETED
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_CM]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_CM]\nTextColor
        bColorsSet = #True
        
      Case #SCS_CUE_ERROR
        nBackColor = #SCS_Red
        nTextColor = #SCS_White
        bColorsSet = #True
        
      Case #SCS_CUE_READY
        If \m_nCuePtr = gnCueToGo
          If \m_nSubPtr = -1
            bNextManualCue = #True
          Else
            If aSub(\m_nSubPtr)\nPrevSubIndex = -1
              bNextManualCue = #True
            EndIf
          EndIf
        EndIf
        If bNextManualCue
          nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_NX]\nBackColor
          nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_NX]\nTextColor
          bColorsSet = #True
          nCuePtr = gaDispPanel(h)\nDPCuePtr
          If nCuePtr >= 0
            nBackColor = aCue(nCuePtr)\nBackColor
            nTextColor = aCue(nCuePtr)\nTextColor
            bColorsSet = #True
            setColorsForNextManualCue(nBackColor, nTextColor, @nBackColor, @nTextColor)
          EndIf
          SGT(\lblRunningInd, sNextManualCue)
          CompilerIf #cTraceRunningInd
            debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
          CompilerEndIf
          PNL_adjustRunningIndSizeIfReqd(h)
          ; debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd) + ", \m_nCuePtr=" + getCueLabel(\m_nCuePtr))
        Else
          nBackColor = $C0FFFF
          nTextColor = $777777
          bColorsSet = #True
          nCuePtr = gaDispPanel(h)\nDPCuePtr
          If nCuePtr >= 0
            nSubPtr = gaDispPanel(h)\nDPSubPtr
            Select aCue(nCuePtr)\nActivationMethod
              Case #SCS_ACMETH_TIME
                If nSubPtr = aCue(nCuePtr)\nFirstSubIndex
                  If aCue(nCuePtr)\sTimeBasedStartReqd
                    If UCase(Left(aCue(nCuePtr)\sTimeBasedStartReqd, 1)) <> "M"
                      If (aCue(nCuePtr)\sTimeBasedStartReqd = aCue(nCuePtr)\sTimeBasedLatestStartReqd) Or (Len(aCue(nCuePtr)\sTimeBasedLatestStartReqd) = 0) ; Or (stringToDateSeconds(aCue(nCuePtr)\sTimeBasedStartReqd) > Date()+10)
                        SGT(\lblRunningInd, aCue(nCuePtr)\sTimeBasedStartReqd)
                      Else
                        SGT(\lblRunningInd, aCue(nCuePtr)\sTimeBasedStartReqd + "-" + aCue(nCuePtr)\sTimeBasedLatestStartReqd)
                      EndIf
                      CompilerIf #cTraceRunningInd
                        debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
                      CompilerEndIf
                      PNL_adjustRunningIndSizeIfReqd(h)
                    EndIf
                  EndIf
                EndIf
              Case #SCS_ACMETH_MTC
                If nSubPtr = aCue(nCuePtr)\nFirstSubIndex
                  If aCue(nCuePtr)\nMTCStartTimeForCue
                    SGT(\lblRunningInd, "MTC " + decodeMTCTime(aCue(nCuePtr)\nMTCStartTimeForCue))
                  EndIf
                ElseIf aSub(nSubPtr)\nSubStart = #SCS_SUBSTART_REL_MTC
                  If aSub(nSubPtr)\nCalcMTCStartTimeForSub
                    SGT(\lblRunningInd, "MTC " + decodeMTCTime(aSub(nSubPtr)\nCalcMTCStartTimeForSub))
                  EndIf
                EndIf
            EndSelect
          EndIf
        EndIf
        
      Default
        nBackColor = $C0FFFF
        nTextColor = $777777
        bColorsSet = #True
      
    EndSelect
    
    If bColorsSet = #False
      sText = GetGadgetText(\lblRunningInd)
      If (Left(sText, nLenStopping) = sStopping) Or (Left(sText, nLenFadingOut) = sFadingOut)
        nBackColor = #SCS_Stopping_Color
        nTextColor = #SCS_White
      Else
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_RU]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_RU]\nTextColor
      EndIf
      bColorsSet = #True
    EndIf
      
    ; debugMsg(sProcName, GGT(\lblSoundCue) + ", sText=" + sText + ", pPanelState=" + decodeCueState(pPanelState) + ", nCueState=" + decodeCueState(aCue(\m_nCuePtr)\nCueState))
    If (nBackColor <> GetGadgetColor(\lblRunningInd, #PB_Gadget_BackColor)) Or (nTextColor <> GetGadgetColor(\lblRunningInd, #PB_Gadget_FrontColor))
      ; debugMsg(sProcName, Trim(GGT(\lblSoundCue)) + ", sText=" + sText + ", pPanelState=" + decodeCueState(pPanelState) + ", nCueState=" + decodeCueState(aCue(\m_nCuePtr)\nCueState) +
      ;                     ", nBackColor=$" + hex6(nBackColor))
      SetGadgetColor(\lblRunningInd, #PB_Gadget_BackColor, nBackColor)
      SetGadgetColor(\lblRunningInd, #PB_Gadget_FrontColor, nTextColor)
      nCuePtr = gaDispPanel(h)\nDPCuePtr
      If nCuePtr >= 0
        ; debugMsg(sProcName, "calling colorLine(" + aCue(nCuePtr)\sCue + ")")
        colorLine(nCuePtr) ; set or change color of 'marker' in WMN\grdCues
      EndIf
      PNL_drawPanelGradient(h)
    EndIf
    
    \bNextManualCue = bNextManualCue
    ; debugMsg(sProcName, "gaPnlVars(" + h + ")\bNextManualCue=" + strB(\bNextManualCue))
    \bPlaying = bPlaying  ; not yet implemented !!!!!!!!!!!
    
    ; debugMsg(sProcName, #SCS_END + ", gaPnlVars(" + h + ")\lblSoundCue=" + Trim(GGT(\lblSoundCue)) + ", \lblRunningInd=" + GGT(\lblRunningInd) + ", \bNextManualCue=" + strB(\bNextManualCue))
    
  EndWith
  
EndProcedure

Procedure PNL_loadOneDispPanel(h, pSubPtr, pAudPtr, bRefreshPanel=#False)
  PROCNAMECP(h)
  Protected nBackColor, nTextColor
  Protected sCueState.s, sOtherInfoText.s
  Protected d, d2, d3, j, nSFRCueCount, nSFRCuePtr, nDevNoForDrawDeviceText
  Protected bDisplayThisPanel, sDescr.s, sLevelCaption.s, sPanCaption.s
  Protected sPageAndDescr.s
  Protected bVisible
  Protected bShuffleVisible, bShuffleEnabled, bFirstVisible, bFirstEnabled
  Protected kCueLeftSpacer.s = "  " ; forces cue label slightly right to allow for display of icon
  Protected n, nMidColor
  Protected bRelativeLevel
  Protected bTargetIsPlaylist
  Protected nImageHandle, nDevGadgetNo, sDevice.s
  Protected nTop
  Protected rSub.tySub
  Protected sTmp.s
  Protected fBVLevelNow.f, fPanNow.f
  Protected fBaseLevel.f, fBasePan.f, fTrimFactor.f
  Protected sThisRunningInd.s, nThisItemState
  Protected nCuePtr
  Protected bRedrawProgressSlider
  Protected nPanelState
  Protected hSwitch
  Protected bErrorState
  Protected bColorsSet
  Protected sCueText.s, sMidiCueText.s
  Protected bMuteAudio
  Protected bMemoContinuous
  Protected l2, nLineCount
  Protected nRealPrevSubIndex
  Protected bLoadAudioGraphResult = #True
  Protected bWantThis, bLinked
  Protected nPlayingPos
  Protected nSldPtr
  Static sTextLinked.s, sTextRelStart.s, bStaticLoaded
  
  ; debugMsg0(sProcName, #SCS_START + ", h=" + h + ", pSubPtr=" + getSubLabel(pSubPtr) + ", pAudPtr=" + getAudLabel(pAudPtr) + ", bRefreshPanel=" + strB(bRefreshPanel))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If bStaticLoaded = #False
    sTextLinked = " (" + Lang("Common", "Linked") + ")"
    sTextRelStart = Lang("OtherInfo", "RelStart") + " "
    bStaticLoaded = #True
  EndIf
  
  CheckSubInRange(h, ArraySize(gaPnlVars()), "gaPnlVars")
  gaPnlVars(h)\bInLoadingDisplay = #True
  gaPnlVars(h)\m_nSubPtr = pSubPtr
  
  ; reset Y position of panel to correct rounding issues associated with the resizing of the form
  ; (this rounding issue could cause the gaps between panels to vary by a pixel, which doesn't look good)
  nTop = h * (grCuePanels\nCuePanelHeightStdPlusGap)
  ; debugMsg(sProcName, "nTop=" + nTop + ", grCuePanels\nCuePanelHeight=" + Str(grCuePanels\nCuePanelHeight) + ", grCuePanels\nCuePanelGap=" + Str(grCuePanels\nCuePanelGap))
  If nTop <> GadgetY(gaPnlVars(h)\cntCuePanel)
    ResizeGadget(gaPnlVars(h)\cntCuePanel, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    ; debugMsg(sProcName, "cntCuePanel GadgetY=" + GadgetY(gaPnlVars(h)\cntCuePanel) + ", GadgetHeight=" + GadgetHeight(gaPnlVars(h)\cntCuePanel))
  EndIf
  
  CheckSubInRange(pSubPtr, ArraySize(aSub()), "aSub()")
  rSub = aSub(pSubPtr)
  
  With rSub
    nCuePtr = \nCueIndex
    CheckSubInRange(nCuePtr, ArraySize(aCue()), "aCue()")
    
    If (\bSubTypeHasAuds) And (pAudPtr >= 0)
      sProcName = buildAudProcName(sProcName, pAudPtr)
    Else
      sProcName = buildSubProcName(sProcName, pSubPtr)
    EndIf
    
    ; Added 1Jan2022 11.9aa to handle Lighting Cues with parameter settings for fade times,
    ; but do not check specifically for \bSubTypeK as this test may be required later for other sub types, eg \bSubTypeM
    If \nSubDuration <= 0
      \nSubDuration = getSubLength(pSubPtr)
      ; debugMsg(sProcName, \sSubLabel + " \nSubDuration=" + \nSubDuration)
    EndIf
    ; End added 1Jan2022 11.9aa
    
    ; debugMsg(sProcName, "\sCue=" + \sCue + ", pSubPtr=" + pSubPtr + ", pAudPtr=" + pAudPtr + ", nSubNo=" + \nSubNo + ", \sSubType=" + \sSubType)
    bDisplayThisPanel = #False
    
    nRealPrevSubIndex = calcRealPrevSubIndex(pSubPtr)
    
    If \bSubTypeA
      bMuteAudio = \bMuteVideoAudio
    EndIf
    
    If (gaDispPanel(h)\bGradientDrawn = #False) Or (gbRedrawPanelGradients)
      PNL_drawPanelGradient(h)
    EndIf
    
    ; default info for running ind (may be changed later in this procedure)
    If (pAudPtr > 0) And ((\bSubTypeAorP) Or (\bSubTypeI))
      CheckSubInRange(pAudPtr, ArraySize(aAud()), "aAud()")
      nThisItemState = aAud(pAudPtr)\nAudState
    Else
      nThisItemState = \nSubState
    EndIf
    PNL_sldPnlProgress_SetBackColor(h, nThisItemState)
    sThisRunningInd = decodeCueStateL(nThisItemState, \bLiveInput)
    If \nSubState <= #SCS_CUE_READY Or \nSubState = #SCS_CUE_PAUSED ; Added "Or \nSubState = #SCS_CUE_PAUSED" 6Nov2020 11.8.3.3ad
      bWantThis = #False  ; bWantThis added 31Oct2019 11.8.2bk to simplify understanding of the following logic
      If nRealPrevSubIndex >= 0
        bWantThis = #True
      ElseIf nRealPrevSubIndex = -1
        Select aCue(nCuePtr)\nActivationMethod
          Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF, #SCS_ACMETH_OCM
            bWantThis = #True
        EndSelect
      EndIf
      If bWantThis
        bLinked = #False
        If (\bSubTypeU) And (\nMTCLinkedToAFSubPtr >= 0)
          bLinked = #True
        ElseIf (\bSubTypeF) And (\nFirstAudIndex >= 0)
          If aAud(\nFirstAudIndex)\nLinkedToAudPtr >= 0
            bLinked = #True
          EndIf
        EndIf
        If bLinked
          sThisRunningInd + sTextLinked
        ElseIf (\nSubState = #SCS_CUE_READY) And (nRealPrevSubIndex= -1)
          sThisRunningInd = getCueActivationMethodForDisplay(nCuePtr)
        ElseIf \nSubStart = #SCS_SUBSTART_REL_MTC And \nCalcMTCStartTimeForSub
          sThisRunningInd = "MTC " + decodeMTCTime(\nCalcMTCStartTimeForSub)
        ElseIf \nSubStart = #SCS_SUBSTART_OCM And \sSubCueMarkerName
          sThisRunningInd = "OCM " + getCueMarkerDisplayInfo(\nSubCueMarkerId, #True)
        Else
          sThisRunningInd + " (auto)"
        EndIf
      EndIf
    EndIf
    
    PNL_setActiveOrComplete(h, nThisItemState)
    
    If \bSubTypeL
      If \nLCAction = #SCS_LC_ACTION_RELATIVE
        bRelativeLevel = #True
        If \nLCSubPtr >= 0
          If aSub(\nLCSubPtr)\bSubTypeAorP
            bTargetIsPlaylist = #True
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndWith
  
  If bRefreshPanel
    ; debugMsg(sProcName, "return")
    ProcedureReturn
  EndIf
  
  With gaPnlVars(h)
    
    \sOtherInfoText = " " ; nb set a value in \sOtherInfoText to force PNL_setOtherInfoText() to populate the gadget even if it's to be blank
    ; SetGadgetText(\lblLinked, "")
    setVisible(\cvsLinked, #False)
    nImageHandle = IMG_getSubTypeImageHandle(pSubPtr)
    ; debugMsg(sProcName, "nImageHandle=" + nImageHandle)
    If nImageHandle <> 0
      nTop = GadgetY(\lblSoundCue) + (GadgetHeight(\lblSoundCue) >> 1) - 12
      ; debugMsg(sProcName, "nTop=" + nTop + ", GadgetY(\lblSoundCue)=" + GadgetY(\lblSoundCue) + ", GadgetHeight(\lblSoundCue)=" + GadgetHeight(\lblSoundCue))
      ResizeGadget(\imgType, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      SetGadgetState(\imgType, ImageID(nImageHandle))
    EndIf
    \nImageHandle = nImageHandle
    
  EndWith
  
  With gaDispPanel(h)
    \bAwaitingLoad = #False
    If nCuePtr >= 0
      \qDPTimeCueLastEdited = aCue(nCuePtr)\qTimeCueLastEdited
    EndIf
    If pSubPtr >= 0
      \qDPTimeSubLastEdited = aSub(pSubPtr)\qTimeSubLastEdited
    EndIf
    If pAudPtr >= 0
      \qDPTimeAudLastEdited = aAud(pAudPtr)\qTimeAudLastEdited
    EndIf
    \sDPSubType = rSub\sSubType
    \bPicture = #False
    \sLinked = ""
    \bEnableRelease = #False
    \bEnableFadeOut = #False
    \nVisualWarningState = 0
    \bAtLeastOnePanDisplayed = #False
    \nMaxDev = -1
    If ((\sDPSubType = "P") Or (\sDPSubType = "A")) And (\nDPAudPtr >= 0)
      \nTransportSwitchIndex = aAud(\nDPAudPtr)\nTransportSwitchIndex
      \nTransportSwitchCode = aAud(\nDPAudPtr)\nTransportSwitchCode
    ElseIf \nDPSubPtr >= 0
      \nTransportSwitchIndex = aSub(\nDPSubPtr)\nTransportSwitchIndex
      \nTransportSwitchCode = aSub(\nDPSubPtr)\nTransportSwitchCode
    Else
      \nTransportSwitchIndex = 0
      \nTransportSwitchCode = 0
    EndIf
    ; debugMsg(sProcName, "gaDispPanel(" + h + ")\nDPCuePtr=" + getCueLabel(\nDPCuePtr) + ", \nDPSubPtr=" + getSubLabel(\nDPSubPtr) + ", \sDPSubType=" + \sDPSubType + ", \nDPAudPtr=" + getAudLabel(\nDPAudPtr) +
    ;                     ", \nTransportSwitchIndex=" + \nTransportSwitchIndex + ", \nTransportSwitchCode=" + \nTransportSwitchCode)
    \qVisualWarningLastChangeTime = gqTimeNow ; set at a meaningful time
  EndWith
  
  With rSub
    
    If ((\nRelStartTime > 0) Or (\nRelStartMode > #SCS_RELSTART_AS_CUE)) And (\nSubState < #SCS_CUE_FADING_IN)
      sOtherInfoText = sTextRelStart + RelStartToString(\nRelStartTime, \nRelStartMode)
    EndIf
    
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      gaDispPanel(h)\bDeviceAssigned[d] = #False
      gaDispPanel(h)\bNoDevice[d] = #False
      gaDispPanel(h)\bIgnoreDev[d] = #False
      If bMuteAudio
        gaDispPanel(h)\bEnableVolAndPan[d] = #False
      Else
        gaDispPanel(h)\bEnableVolAndPan[d] = #True
      EndIf
    Next d
    
    For d = 0 To grCuePanels\nMaxDevLineNo
      gaDispPanel(h)\sDevices[d] = ""
    Next d
    
  EndWith
  
  If (rSub\bSubTypeHasAuds) And (pAudPtr >= 0) ; \bSubTypeHasAuds
    With aAud(pAudPtr)
      Select \nFileFormat
        Case #SCS_FILEFORMAT_AUDIO, #SCS_FILEFORMAT_LIVE_INPUT
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If Len(\sLogicalDev[d]) = 0
              gaDispPanel(h)\bDeviceAssigned[d] = #False
            Else
              gaDispPanel(h)\bDeviceAssigned[d] = #True
            EndIf
            If \bAudTypeI
              If \nInputOnCount = 0
                gaDispPanel(h)\bDeviceAssigned[d] = #False
              EndIf
            EndIf
            ; debugMsg(sProcName, "\bDeviceAssigned[" + d + "]=" + strB(gaDispPanel(h)\bDeviceAssigned[d]) + ", \sLogicalDev[" + d + "]=" + \sLogicalDev[d])
            gaDispPanel(h)\bDisplayPan[d] = \bDisplayPan[d]
            If \bDisplayPan[d]
              gaDispPanel(h)\bAtLeastOnePanDisplayed = #True
            EndIf
            gaDispPanel(h)\bNoDevice[d] = #False
            If \bAudTypeF
              If gbUseBASS
                If \bASIO[d] = #False
                  If \nBassDevice[d] = 0
                    gaDispPanel(h)\bNoDevice[d] = #True
                  EndIf
                EndIf
              EndIf
            EndIf
            gaDispPanel(h)\bIgnoreDev[d] = \bIgnoreDev[d]
            If gaDispPanel(h)\bDeviceAssigned[d]
              gaDispPanel(h)\nMaxDev = d
            EndIf
          Next d
          
        Case #SCS_FILEFORMAT_MIDI
          
        Case #SCS_FILEFORMAT_PICTURE
          gaDispPanel(h)\bPicture = #True
          
        Case #SCS_FILEFORMAT_VIDEO
          gaDispPanel(h)\bPicture = #False
          d = 0
          gaDispPanel(h)\bDeviceAssigned[d] = #True
          gaDispPanel(h)\bDisplayPan[d] = \bDisplayPan[d]
          If \bDisplayPan[d]
            gaDispPanel(h)\bAtLeastOnePanDisplayed = #True
          EndIf
          gaDispPanel(h)\nMaxDev = d
          
        Case #SCS_FILEFORMAT_CAPTURE
          gaDispPanel(h)\bPicture = #True
          
      EndSelect
    EndWith
    
  ElseIf rSub\bSubTypeL ; \bSubTypeL
    If (rSub\bLCTargetIsA) And (rSub\nLCSubPtr >= 0)
      d = 0
      gaDispPanel(h)\bDeviceAssigned[d] = #True
      gaDispPanel(h)\bDisplayPan[d] = aSub(rSub\nLCSubPtr)\bSubDisplayPan[d]
      If gaDispPanel(h)\bDisplayPan[d]
        gaDispPanel(h)\bAtLeastOnePanDisplayed = #True
      EndIf
      gaDispPanel(h)\nMaxDev = d
      
    ElseIf ((rSub\bLCTargetIsF) Or (rSub\bLCTargetIsI)) And (rSub\nLCAudPtr >= 0)
      With aAud(rSub\nLCAudPtr)
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If rSub\bLCInclude[d]
            If \sLogicalDev[d]
              gaDispPanel(h)\bDeviceAssigned[d] = #True
            Else
              gaDispPanel(h)\bDeviceAssigned[d] = #False
            EndIf
            gaDispPanel(h)\bNoDevice[d] = #False
            If gbUseBASS
              If \bASIO[d] = #False
                If \nBassDevice[d] = 0
                  gaDispPanel(h)\bNoDevice[d] = #True
                EndIf
              EndIf
            EndIf
            gaDispPanel(h)\bIgnoreDev[d] = \bIgnoreDev[d]
          EndIf
          ; count ALL devices for nMaxDev, not just included devices
          If \sLogicalDev[d]
            gaDispPanel(h)\nMaxDev = d
          EndIf
          gaDispPanel(h)\bDisplayPan[d] = \bDisplayPan[d]
          If \bDisplayPan[d]
            gaDispPanel(h)\bAtLeastOnePanDisplayed = #True
          EndIf
        Next d
      EndWith
      
    ElseIf (rSub\bLCTargetIsP) And (rSub\nLCSubPtr >= 0)
      With aSub(rSub\nLCSubPtr)
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If rSub\bLCInclude[d]
            If Len(\sPLLogicalDev[d]) > 0
              gaDispPanel(h)\bDeviceAssigned[d] = #True
            Else
              gaDispPanel(h)\bDeviceAssigned[d] = #False
            EndIf
            gaDispPanel(h)\bNoDevice[d] = #False
            If gbUseBASS
              If \bPLASIO[d] = #False
                If \nPLBassDevice[d] = 0
                  gaDispPanel(h)\bNoDevice[d] = #True
                EndIf
              EndIf
            EndIf
          EndIf
          ; count ALL devices for nMaxDev, not just included devices
          If \sPLLogicalDev[d]
            gaDispPanel(h)\nMaxDev = d
          EndIf
          gaDispPanel(h)\bDisplayPan[d] = \bSubDisplayPan[d]
          If \bSubDisplayPan[d]
            gaDispPanel(h)\bAtLeastOnePanDisplayed = #True
          EndIf
        Next d
      EndWith
    EndIf
    
  ElseIf rSub\bSubTypeN ; \bSubTypeN (Note)
    ; no action
  EndIf
  
  For d = 0 To #SCS_MAX_AUDIO_DEV_PER_DISP_PANEL
    If gaDispPanel(h)\bDeviceAssigned[d]
      If (gaDispPanel(h)\bNoDevice[d]) Or (gaDispPanel(h)\bIgnoreDev[d]) Or (bMuteAudio)
        gaDispPanel(h)\bEnableVolAndPan[d] = #False
        debugMsg(sProcName, "gaDispPanel(" + h + ")\bEnableVolAndPan[" + d + "]=#False because \bNoDevice[" + d + "]=" + strB(gaDispPanel(h)\bNoDevice[d]) +
                            " or \bIgnoreDev[" + d + "]=" + strB(gaDispPanel(h)\bIgnoreDev[d]) + " or " + ", bMuteAudio=" + strB(bMuteAudio) +
                            ", rSub\sSubLabel=" + rSub\sSubLabel + " \sSubType=" + rSub\sSubType + ", \bSubTypeA=" + strB(rSub\bSubTypeA) + ", \bSubTypeF=" + strB(rSub\bSubTypeF))
      Else
        gaDispPanel(h)\bEnableVolAndPan[d] = #True
      EndIf
    EndIf
  Next d
  
  If gaDispPanel(h)\nMaxDev < grCuePanels\nMaxDevLines ; was < 4
    
    If (rSub\bSubTypeHasAuds) And (pAudPtr >= 0)
      With aAud(pAudPtr)
        Select \nFileFormat
          Case #SCS_FILEFORMAT_AUDIO
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If \sLogicalDev[d]
                gaDispPanel(h)\sDevices[d] = VST_adjustLogicalDevForVST(\sLogicalDev[d])
              EndIf
            Next d
            
          Case #SCS_FILEFORMAT_LIVE_INPUT
            If \nInputOnCount > 0
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If \sLogicalDev[d]
                  gaDispPanel(h)\sDevices[d] = \sLogicalDev[d]
                EndIf
              Next d
            EndIf
            
            Case #SCS_FILEFORMAT_MIDI
            d = 0
            If \sLogicalDev
              gaDispPanel(h)\sDevices[d] = \sLogicalDev
            EndIf
            
          Case #SCS_FILEFORMAT_VIDEO
            d = 0
            If bMuteAudio
              gaDispPanel(h)\sDevices[d] = grText\sTextMuteAudio
            Else
              gaDispPanel(h)\sDevices[d] = rSub\sVidAudLogicalDev
            EndIf
            ; debugMsg0(sProcName, "gaDispPanel(" + h + ")\sDevices[" + d + "]=" + gaDispPanel(h)\sDevices[d])
            
        EndSelect
      EndWith
      
    ElseIf rSub\bSubTypeL
      If (rSub\bLCTargetIsA) And (rSub\nLCSubPtr >= 0)
        With aSub(rSub\nLCSubPtr)
          d = 0
          If \bMuteVideoAudio
            ; shouldn't get here as Level Change Cues not valid on muted videos
            gaDispPanel(h)\sDevices[d] = grText\sTextMuteAudio
          Else
            gaDispPanel(h)\sDevices[d] = \sVidAudLogicalDev
          EndIf
        EndWith
        
      ElseIf ((rSub\bLCTargetIsF) Or (rSub\bLCTargetIsI)) And (rSub\nLCAudPtr >= 0)
        With aAud(rSub\nLCAudPtr)
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \sLogicalDev[d]
              gaDispPanel(h)\sDevices[d] = VST_adjustLogicalDevForVST(\sLogicalDev[d])
            EndIf
          Next d
        EndWith
        
      ElseIf (rSub\bLCTargetIsP) And (rSub\nLCSubPtr >= 0)
        With aSub(rSub\nLCSubPtr)
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \sPLLogicalDev[d]
              gaDispPanel(h)\sDevices[d] = VST_adjustLogicalDevForVST(\sPLLogicalDev[d])
            EndIf
          Next d
        EndWith
      EndIf
    EndIf
    
  Else
    If (rSub\bSubTypeHasAuds) And (pAudPtr >= 0)
      With aAud(pAudPtr)
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If d <= grCuePanels\nMaxDevLineNo
            d2 = d
            d3 = 0
          ElseIf d < grCuePanels\nTwiceDevLines ; was d < 8
            d2 = d - grCuePanels\nMaxDevLines   ; was d - 4
            d3 = 1
          Else
            Break
          EndIf
          If \sLogicalDev[d]
            CheckSubInRange(h, ArraySize(gaDispPanel()), "gaDispPanel()")
            CheckSubInRange(d2, grCuePanels\nMaxDevLineNo, "sDevices[]")
            CheckSubInRange(d, #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB, "\sLogicalDev[]")
            If d3 = 0
              gaDispPanel(h)\sDevices[d2] = VST_adjustLogicalDevForVST(\sLogicalDev[d])
            Else
              gaDispPanel(h)\sDevices[d2] + " / " + VST_adjustLogicalDevForVST(\sLogicalDev[d])
            EndIf
            ; debugMsg0(sProcName, "gaDispPanel(" + h + ")\sDevices[" + d2 + "]=" + gaDispPanel(h)\sDevices[d2])
          EndIf
        Next d
      EndWith
      
    ElseIf rSub\bSubTypeL
      If (rSub\bLCTargetIsA) And (rSub\nLCSubPtr >= 0)
        With aSub(rSub\nLCSubPtr)
          d = 0
          If \bMuteVideoAudio
            ; shouldn't get here as Level Change Cues not valid on muted videos
            gaDispPanel(h)\sDevices[d] = grText\sTextMuteAudio
          Else
            gaDispPanel(h)\sDevices[d] = \sVidAudLogicalDev
          EndIf
        EndWith
        
      ElseIf ((rSub\bLCTargetIsF) Or (rSub\bLCTargetIsI)) And (rSub\nLCAudPtr >= 0)
        With aAud(rSub\nLCAudPtr)
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If d < grCuePanels\nMaxDevLines ; was d < 4
              d2 = d
              d3 = 0
            ElseIf d < grCuePanels\nTwiceDevLines ; was d < 8
              d2 = d - grCuePanels\nMaxDevLines   ; was d - 4
              d3 = 1
            Else
              Break
            EndIf
            If \sLogicalDev[d]
              If d3 = 0
                gaDispPanel(h)\sDevices[d2] = VST_adjustLogicalDevForVST(\sLogicalDev[d])
              Else
                gaDispPanel(h)\sDevices[d2] + " / " + VST_adjustLogicalDevForVST(\sLogicalDev[d])
              EndIf
              ; debugMsg0(sProcName, "gaDispPanel(" + h + ")\sDevices[" + d2 + "]=" + gaDispPanel(h)\sDevices[d2])
            EndIf
          Next d
        EndWith
        
      ElseIf (rSub\bLCTargetIsP) And (rSub\nLCSubPtr >= 0)
        With aSub(rSub\nLCSubPtr)
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If d > grCuePanels\nMaxDevLineNo
              Break
            EndIf
            If \sPLLogicalDev[d]
              gaDispPanel(h)\sDevices[d] = VST_adjustLogicalDevForVST(\sPLLogicalDev[d])
            EndIf
          Next d
        EndWith
      EndIf
    EndIf
  EndIf
  
  ; debugMsg0(sProcName, "rSub\sSubLabel=" + rSub\sSubLabel + ", \sSubType=" + rSub\sSubType + ", \bSubTypeHasDevs=" + strB(rSub\bSubTypeHasDevs) + ", \bSubTypeHasAuds=" + strB(rSub\bSubTypeHasAuds))
  If rSub\bSubTypeHasDevs
    For d = 0 To grCuePanels\nMaxDevLineNo
      sDevice = gaDispPanel(h)\sDevices[d]
      CompilerIf #c_cuepanel_multi_dev_select
      nDevGadgetNo = gaPnlVars(h)\cvsDevice[d]
      CompilerElse
      nDevGadgetNo = gaPnlVars(h)\lblDevice[d]
      CompilerEndIf
      If (Len(Trim(sDevice)) = 0) Or (gaDispPanel(h)\bPicture)
        setVisible(nDevGadgetNo, #False)
      Else
        CompilerIf #c_cuepanel_multi_dev_select
          nDevNoForDrawDeviceText = PNL_calcDevNoForDrawDeviceText(h, d)
          ; debugMsg(sProcName, "calling PNL_drawDeviceText(" + h + ", " + nDevNoForDrawDeviceText + ")")
          PNL_drawDeviceText(h, nDevNoForDrawDeviceText)
        CompilerElse
          SetGadgetText(nDevGadgetNo, sDevice)
        CompilerEndIf
        setEnabled(nDevGadgetNo, #True)
        setVisible(nDevGadgetNo, #True)
      EndIf
    Next d
    
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      CheckSubInRange(h, ArraySize(gaDispPanel()), "gaDispPanel(h)")
      If gaDispPanel(h)\nMaxDev < grCuePanels\nMaxDevLines
        If d < grCuePanels\nMaxDevLines
          nSldPtr = gaPnlVars(h)\sldCueVol[d]
          gaSlider(nSldPtr)\nDevNo = d
          gaSlider(nSldPtr)\m_AudPtr = pAudPtr ; Added 23Apr2024 11.10.2cc
          If bRelativeLevel
            If bTargetIsPlaylist
              SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELCHANGERUNPL)
            Else
              SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELCHANGERUN)
            EndIf
          Else
            SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELRUN)
          EndIf
          SLD_setVisible(nSldPtr, gaDispPanel(h)\bDeviceAssigned[d])
          SLD_setEnabled(nSldPtr, gaDispPanel(h)\bEnableVolAndPan[d])
          If gaDispPanel(h)\bDisplayPan[d]
            nSldPtr = gaPnlVars(h)\sldCuePan[d]
            gaSlider(nSldPtr)\nDevNo = d
            gaSlider(nSldPtr)\m_AudPtr = pAudPtr ; Added 23Apr2024 11.10.2cc
            SLD_setSliderType(nSldPtr, #SCS_ST_PAN)
            If SLD_getMax(nSldPtr) <> #SCS_MAXPAN_SLD
              SLD_setMax(nSldPtr, #SCS_MAXPAN_SLD)
            EndIf
            SLD_setVisible(nSldPtr, gaDispPanel(h)\bDeviceAssigned[d])
            SLD_setEnabled(nSldPtr, gaDispPanel(h)\bEnableVolAndPan[d])
          Else
            nSldPtr = gaPnlVars(h)\sldCuePan[d]
            SLD_setVisible(nSldPtr, #False)
          EndIf
        EndIf
      Else
        If d < grCuePanels\nMaxDevLines  ; was d < 4
          nSldPtr = gaPnlVars(h)\sldCueVol[d]
          gaSlider(nSldPtr)\nDevNo = d
          gaSlider(nSldPtr)\m_AudPtr = pAudPtr ; Added 23Apr2024 11.10.2cc
          If bRelativeLevel
            If bTargetIsPlaylist
              SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELCHANGERUNPL)
            Else
              SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELCHANGERUN)
            EndIf
          Else
            SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELRUN)
          EndIf
          SLD_setVisible(nSldPtr, gaDispPanel(h)\bDeviceAssigned[d])
          SLD_setEnabled(nSldPtr, gaDispPanel(h)\bEnableVolAndPan[d])
          
        ElseIf d < grCuePanels\nTwiceDevLines ; was d < 8
          nSldPtr = gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines]
          gaSlider(nSldPtr)\nDevNo = d
          gaSlider(nSldPtr)\m_AudPtr = pAudPtr ; Added 23Apr2024 11.10.2cc
          If bRelativeLevel
            If bTargetIsPlaylist
              SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELCHANGERUNPL)
            Else
              SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELCHANGERUN)
            EndIf
          Else
            SLD_setSliderType(nSldPtr, #SCS_ST_HLEVELRUN)
          EndIf
          If SLD_getMax(nSldPtr) <> #SCS_MAXVOLUME_SLD
            SLD_setMax(nSldPtr, #SCS_MAXVOLUME_SLD)
          EndIf
          SLD_setVisible(nSldPtr, gaDispPanel(h)\bDeviceAssigned[d])
          SLD_setEnabled(nSldPtr, gaDispPanel(h)\bEnableVolAndPan[d])
        EndIf
      EndIf
    Next d
    
  Else  ; rSub\bSubTypeHasDevs = #False
    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    
  EndIf
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \nMTCLinkedToAFSubPtr >= 0
        gaDispPanel(h)\sLinked = sTextLinked
        debugMsg(sProcName, "gaDispPanel(" + h + ")\sLinked=" + Trim(gaDispPanel(h)\sLinked))
      EndIf
    EndWith
  EndIf
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nLinkedToAudPtr >= 0
        gaDispPanel(h)\sLinked = sTextLinked
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nLinkedToAudPtr=" + getAudLabel(\nLinkedToAudPtr) + ", gaDispPanel(" + h + ")\sLinked=" + Trim(gaDispPanel(h)\sLinked))
      EndIf
      
      If (\bAudTypeF) Or (\bAudTypeI)
        If (\nFadeOutTime > 0) And (\nAudState < #SCS_CUE_FADING_OUT)
          gaDispPanel(h)\bEnableFadeOut = #True
        EndIf
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bAudTypeI=" + strB(\bAudTypeI) + ", gaDispPanel(" + h + ")\bEnableFadeOut=" + strB(gaDispPanel(h)\bEnableFadeOut))
        
      ElseIf \bAudTypeAorP
        ; If (\nNextPlayIndex = -1) And (rSub\bPLRepeat = #False)
        If (\nNextPlayIndex = -1) And (getPLRepeatActive(pSubPtr) = #False)
          If (rSub\nPLFadeOutTime > 0) And (\nAudState < #SCS_CUE_TRANS_MIXING_OUT)
            gaDispPanel(h)\bEnableFadeOut = #True
          EndIf
        Else
          If (\nFadeOutTime > 0) And (\nAudState < #SCS_CUE_TRANS_MIXING_OUT)
            gaDispPanel(h)\bEnableFadeOut = #True
          EndIf
        EndIf
        
      EndIf
      
      If \bAudTypeF
        If \rCurrLoopInfo\nAbsLoopEnd > 0
          If \rCurrLoopInfo\bLoopReleased = #False
            gaDispPanel(h)\bEnableRelease = #True
          EndIf
        EndIf
      EndIf
      
      If \bAudTypeM = #False
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          gaDispPanel(h)\fDispCueVolNow[d] = \fCueVolNow[d]
          gaDispPanel(h)\fDispCuePanNow[d] = \fCuePanNow[d]
        Next d
      EndIf
    EndWith
  EndIf
  
  gaDispPanel(h)\nDispCountDownTimeLeft = 0
  sCueText = rSub\sCue
  If (rSub\nPrevSubIndex <> -1) Or (rSub\nNextSubIndex <> -1) Or (rSub\nAudCount > 1)
    ; If \nPrevSubIndex <> -1 or \nNextSubIndex <> -1 then there must be more than one sub
    sCueText + " <" + rSub\nSubNo
    If rSub\nAudCount > 1
      sCueText + "." + aAud(pAudPtr)\nAudNo
    EndIf
    sCueText + ">"
  EndIf
  If rSub\bSubContainsGapless
    sCueText + " " + #SCS_GAPLESS_MARKER
  EndIf
  SetGadgetText(gaPnlVars(h)\lblSoundCue, kCueLeftSpacer + sCueText)
  ; debugMsg(sProcName,"GetGadgetText(gaPnlVars(" + h + ")\lblSoundCue)=" + Trim(GetGadgetText(gaPnlVars(h)\lblSoundCue)))
  
  sTmp = "Go To Cue " + rSub\sCue
  scsToolTip(gaPnlVars(h)\lblSoundCue, sTmp)
  scsToolTip(gaPnlVars(h)\imgType, sTmp)
  gaPnlVars(h)\m_nCuePtr = nCuePtr
  ; debugMsg(sProcName, "gaPnlVars(" + h + ")\m_nCuePtr=" + getCueLabel(gaPnlVars(h)\m_nCuePtr))
  
  sMidiCueText = ""
  If Trim(aCue(nCuePtr)\sMidiCue)
    If grOperModeOptions(gnOperMode)\bShowMidiCueInCuePanels
      sMidiCueText = "[MIDI " + Trim(aCue(nCuePtr)\sMidiCue) + "] "
    EndIf
  EndIf
  
  sDescr = ""
  If (rSub\bSubTypeAorP) And (rSub\nAudCount > 1)
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sAudDescr=" + aAud(pAudPtr)\sAudDescr)
    sDescr = aAud(pAudPtr)\sAudDescr    ; see also generatePlayOrder() and openMediaFile() where sAudDescr is set with the play order
    
  ElseIf (rSub\bSubTypeM) And (pAudPtr >= 0)
    sDescr = Trim(rSub\sSubDescr) + ": " + GetFilePart(aAud(pAudPtr)\sFileName)
    
  ElseIf (nRealPrevSubIndex = -1) And (aCue(nCuePtr)\sWhenReqd)
    Select Left(aCue(nCuePtr)\sWhenReqd, 1)
      Case "(", "[", "{"
        sDescr = Trim(rSub\sSubDescr + "  " + aCue(nCuePtr)\sWhenReqd)
      Default
        sDescr = Trim(rSub\sSubDescr + "  (" + Trim(aCue(nCuePtr)\sWhenReqd)) + ")"
    EndSelect
    
  Else
    sDescr = rSub\sSubDescr
    
  EndIf
  
  If (Len(sDescr) = 0) Or (rSub\bSubTypeN)
    ; if no sub-cue description or if note cue then use cue description
    If (nRealPrevSubIndex = -1) And (aCue(nCuePtr)\sWhenReqd)
      Select Left(aCue(nCuePtr)\sWhenReqd, 1)
        Case "(", "[", "{"
          sDescr = Trim(aCue(nCuePtr)\sCueDescr + "  " + aCue(nCuePtr)\sWhenReqd)
        Default
          sDescr = Trim(aCue(nCuePtr)\sCueDescr + "  (" + Trim(aCue(nCuePtr)\sWhenReqd)) + ")"
      EndSelect
    Else
      sDescr = aCue(nCuePtr)\sCueDescr
    EndIf
  EndIf
  
  sPageAndDescr = aCue(rSub\nCueIndex)\sPageNo
  If sPageAndDescr
    sPageAndDescr + "  " + sDescr
    sDescr = sPageAndDescr
  EndIf
  
  ; debugMsg(sProcName, "gaPnlVars(" + h + ")\lblSoundCue=" + Trim(GGT(gaPnlVars(h)\lblSoundCue)) + ", sDescr=" + sDescr)
  If rSub\bSubTypeN
    compactLabel(gaPnlVars(h)\lblDescriptionB, sDescr)
    setVisible(gaPnlVars(h)\lblDescriptionA, #False)
    setVisible(gaPnlVars(h)\lblDescriptionB, #True)
  Else
    compactLabel(gaPnlVars(h)\lblDescriptionA, " " + sMidiCueText + sDescr) ; nb sMidiCueText may be blank
    setVisible(gaPnlVars(h)\lblDescriptionB, #False)
    setVisible(gaPnlVars(h)\lblDescriptionA, #True)
  EndIf
  
  ; sldPnlProgress
  SLD_clearLvlPts(gaPnlVars(h)\sldPnlProgress)  ; level points may be set later in this procedure
  ; debugMsg(sProcName, "rSub\sSubType=" + rSub\sSubType)
  If FindString("AEFKLPMSU", rSub\sSubType, 1) > 0
    bVisible = #True
    If rSub\bSubTypeA
      Select aAud(pAudPtr)\nFileFormat
        Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
        ; If rSub\bPLRepeat
        If getPLRepeatActive(pSubPtr)
          If (aAud(pAudPtr)\nPrevAudIndex = -1) And (aAud(pAudPtr)\nNextAudIndex = -1)
            ; only one aud in this continuous slideshow, and that aud is a still image
            bVisible = #False
          EndIf
        EndIf
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nCueDuration=" + Str(aAud(pAudPtr)\nCueDuration))
        If (aAud(pAudPtr)\nCueDuration <= 0) Or (aAud(pAudPtr)\nCueDuration = #SCS_CONTINUOUS_LENGTH)
          bVisible = #False
        EndIf
      EndSelect
    ElseIf rSub\bSubTypeE
      If (rSub\bMemoContinuous) Or (rSub\nMemoDisplayTime <= 0)
        bVisible = #False
        bMemoContinuous = #True
      Else
        bMemoContinuous = #False
      EndIf
    ElseIf rSub\bSubTypeK
      ; debugMsg(sProcName, "rSub\bSubTypeK=" + strB(rSub\bSubTypeK) + ", rSub\nSubDuration=" + rSub\nSubDuration)
      If rSub\nSubDuration <= 0
        bVisible = #False
      EndIf
    ElseIf rSub\bSubTypeL
      If rSub\nLCTimeMax = 0
        bVisible = #False
      EndIf
    ElseIf rSub\bSubTypeM
      If (pAudPtr < 0) And (rSub\nSubDuration <= 0)
        bVisible = #False
      EndIf
    ElseIf rSub\bSubTypeS
      If rSub\nSubDuration <= 0
        bVisible = #False
      EndIf
    ElseIf rSub\bSubTypeU
      ; debugMsg(sProcName, "rSub\nMTCDuration=" + rSub\nMTCDuration)
      If rSub\nMTCDuration <= 0 Or rSub\nMTCLinkedToAFSubPtr >= 0
        bVisible = #False
      EndIf
    EndIf
    
    SLD_setAudPtr(gaPnlVars(h)\sldPnlProgress, pAudPtr)
    If (rSub\bSubTypeForP Or (rSub\bSubTypeA And aAud(pAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO)) And (pAudPtr >= 0) ; Changed 25Apr2022 11.9.1bd to include video files
      If (aAud(pAudPtr)\bAudPlaceHolder) Or (grOperModeOptions(gnOperMode)\bShowAudioGraph = #False) Or
         (aAud(pAudPtr)\nFileDuration > getFileScanMaxLengthMS(rSub\sSubType) And getFileScanMaxLength(rSub\sSubType) > 0) Or
         (rSub\bSubTypeA And rSub\bMuteVideoAudio)
        SLD_setAudioGraph(gaPnlVars(h)\sldPnlProgress, #False)
      Else
        SLD_setAudioGraph(gaPnlVars(h)\sldPnlProgress, #True)
        If rSub\bSubTypeF
          SLD_loadLvlPts(gaPnlVars(h)\sldPnlProgress)  ; nb must set format BEFORE calling SLD_loadLvlPts() so that correct audio graph width is used
        EndIf
        ; debugMsg(sProcName, "calling sldLoadAudioGraph(gaPnlVars(" + h + ")\sldPnlProgress, #True)")
        bLoadAudioGraphResult = SLD_loadAudioGraph(gaPnlVars(h)\sldPnlProgress, #True)
        ; debugMsg(sProcName, "sldLoadAudioGraph(gaPnlVars(" + h + ")\sldPnlProgress, #True) returned " + strB(bLoadAudioGraphResult))
      EndIf
    Else
      SLD_setAudioGraph(gaPnlVars(h)\sldPnlProgress, #False)
    EndIf
  Else
    SLD_setAudioGraph(gaPnlVars(h)\sldPnlProgress, #False)
    SLD_setAudPtr(gaPnlVars(h)\sldPnlProgress, pAudPtr)
    bVisible = #False
  EndIf
  ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, " + strB(bVisible) + ")")
  SLD_setVisible(gaPnlVars(h)\sldPnlProgress, bVisible)
  If bVisible
    bRedrawProgressSlider = #True ; indicates slider to be redrawn at end of procedure, which ensures line loop positions etc are correctly drawn
  EndIf
  ; debugMsg(sProcName, "bRedrawProgressSlider=" + strB(bRedrawProgressSlider) + ", bLoadAudioGraphResult=" + strB(bLoadAudioGraphResult))
  
  If grM2T\nM2TPrimaryAudPtr = -1 Or grM2T\nM2TPrimaryAudPtr <> gaDispPanel(h)\nDPAudPtr
    setVisible(gaPnlVars(h)\cntTransportCtls, gaPnlVars(h)\bShowTransportControls)
  EndIf
  setVisible(gaPnlVars(h)\cntFaderAndPanCtls, gaPnlVars(h)\bShowFaderAndPanControls)
  
  gaDispPanel(h)\nDPLinkedToAudPtr = -1 ; Added 2May2022 11.9.1
  gaDispPanel(h)\nDPAudLinkCount = 0    ; Added 2May2022 11.9.1
  
  If (rSub\bSubTypeHasAuds) And (pAudPtr >= 0)   ; INFO bSubTypeHasAuds
    ;{
    With aAud(pAudPtr)
      bDisplayThisPanel = #True
      If gaDispPanel(h)\nDPSubState <> \nAudState ; changed 2May2022pm 11.9.1
        gaDispPanel(h)\nDPPrevSubState = gaDispPanel(h)\nDPSubState
        gaDispPanel(h)\nDPSubState = \nAudState
        debugMsg(sProcName, "gaDispPanel(" + h + ")\nDPPrevSubState=" + decodeCueState(gaDispPanel(h)\nDPPrevSubState) + ", \nDPSubState=" + decodeCueState(gaDispPanel(h)\nDPSubState))
      EndIf
      gaDispPanel(h)\nDPLinkedToAudPtr = \nLinkedToAudPtr ; Added 2May2022 11.9.1
      gaDispPanel(h)\nDPAudLinkCount = \nAudLinkCount     ; Added 2May2022 11.9.1
      nBackColor = getSubBackColor(pSubPtr, #True)
      nTextColor = getSubTextColor(pSubPtr, #True)
      
      If \bAudTypeI = #False
        ; debugMsg(sProcName, ">> \nFileState=" + decodeFileState(\nFileState) + ", \nCueDuration=" + \nCueDuration)
        If (\nFileState = #SCS_FILESTATE_OPEN) Or (\nCueDuration > 0)
          If \nCueDuration > 0
            SLD_setMax(gaPnlVars(h)\sldPnlProgress, (\nCueDuration-1))
          Else
            SLD_setMax(gaPnlVars(h)\sldPnlProgress, 0)
          EndIf
          nPlayingPos = getAudPlayingPos(pAudPtr)
          If (nPlayingPos >= 0) And (nPlayingPos <= SLD_getMax(gaPnlVars(h)\sldPnlProgress))
            CompilerIf #cTracePosition
              debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + nPlayingPos + ")")
            CompilerEndIf
            SLD_setValue(gaPnlVars(h)\sldPnlProgress, nPlayingPos)
          EndIf
          
          nLineCount = 0
          If (\bAudTypeF) And (\nMaxLoopInfo >= 0)
            For l2 = 0 To \nMaxLoopInfo
              SLD_setLinePos(gaPnlVars(h)\sldPnlProgress, nLineCount, \aLoopInfo(l2)\nAbsLoopStart - \nAbsMin, #SCS_SLD_LT_LOOP_START)
              SLD_setLinePos(gaPnlVars(h)\sldPnlProgress, nLineCount+1, \aLoopInfo(l2)\nAbsLoopEnd - \nAbsMin, #SCS_SLD_LT_LOOP_END)
              nLineCount + 2
            Next l2
          EndIf
          If (\bAudTypeAorF) And (\nMaxCueMarker >= 0)  
            If grOperModeOptions(gnOperMode)\bShowCueMarkers
              For l2 = 0 To \nMaxCueMarker
                If (\aCueMarker(l2)\nCueMarkerPosition >= \nAbsMin) And (\aCueMarker(l2)\nCueMarkerPosition <= \nAbsMax)
                  SLD_setLinePos(gaPnlVars(h)\sldPnlProgress, nLineCount, \aCueMarker(l2)\nCueMarkerPosition - \nAbsMin, #SCS_SLD_LT_CUE_MARKER)
                  nLineCount + 1
                EndIf
              Next l2
            EndIf
          EndIf
          SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, nLineCount)
        EndIf
      EndIf
      
      If \nAudNo = 1 And aSub(\nSubIndex)\nSubStart = #SCS_SUBSTART_OCM And aSub(\nSubIndex)\nSubState = #SCS_CUE_READY
        ; no action here as sThisRunningInd has already been set with the required text
      Else
        If (\bLiveInput) And (\nAudState = #SCS_CUE_PLAYING)
          sCueState = grText\sTextLive
        Else
          sCueState = gaCueState(\nAudState)
          ; debugMsg(sProcName, "sCueState=" + sCueState)
        EndIf
        If \nAudState <= #SCS_CUE_READY
          If ((nRealPrevSubIndex = -1) And ((aCue(nCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO) Or (aCue(nCuePtr)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF))) Or
             (nRealPrevSubIndex >= 0)
            bLinked = #False
            If rSub\nFirstAudIndex >= 0
              If aAud(rSub\nFirstAudIndex)\nLinkedToAudPtr > 0
                bLinked = #True
              EndIf
            EndIf
            If bLinked
              sCueState + sTextLinked
            ElseIf (\nAudState = #SCS_CUE_READY) And (nRealPrevSubIndex = -1)
              sCueState = getCueActivationMethodForDisplay(nCuePtr)
              ; debugMsg(sProcName, "sCueState=" + sCueState)
            Else
              sCueState + " (auto)"
            EndIf
          EndIf
        ElseIf (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
          sCueState + gaDispPanel(h)\sLinked
        EndIf
        If sCueState
          sThisRunningInd = sCueState
        EndIf
      EndIf
      
      ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", \sErrorMsg=" + \sErrorMsg)
      If (\nAudState = #SCS_CUE_ERROR) And (\sErrorMsg)
        sOtherInfoText = \sErrorMsg
        bErrorState = #True
      Else
        sOtherInfoText = loadOtherInfoTextForAud(pAudPtr, sOtherInfoText, #True)
      EndIf
      PNL_setOtherInfoText(h, sOtherInfoText, bErrorState)
      
      If gaDispPanel(h)\nMaxDev < grCuePanels\nMaxDevLines ; was < 4
        For d = 0 To grCuePanels\nMaxDevLineNo
          If gaDispPanel(h)\bDeviceAssigned[d]
            fBVLevelNow = \fCueTotalVolNow[d]
            fPanNow = \fCuePanNow[d]
            If \bAudTypeAorP
              If (\nAudState = #SCS_CUE_PL_READY) Or (\nAudState < #SCS_CUE_FADING_IN)
                fBVLevelNow = \fAudPlayBVLevel[d]
                fPanNow = \fAudPlayPan[d]
              EndIf
            EndIf
            If bMuteAudio
              fBVLevelNow = #SCS_MINVOLUME_SINGLE
              fPanNow = #SCS_PANCENTRE_SINGLE
              fBaseLevel = #SCS_MINVOLUME_SINGLE
              fBasePan = #SCS_PANCENTRE_SINGLE
              fTrimFactor = grSubDef\fSubTrimFactor[d]
            Else
              fBaseLevel = \fSavedBVLevel[d]
              fBasePan = \fSavedPan[d]
              fTrimFactor = \fTrimFactor[d]
            EndIf
            SLD_setLevel(gaPnlVars(h)\sldCueVol[d], fBVLevelNow, fTrimFactor)
            CompilerIf #cTraceCueTotalVolNow
              debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(fBaseLevel) + ", " + StrF(fTrimFactor,4) + ")")
            CompilerEndIf
            SLD_setBaseLevel(gaPnlVars(h)\sldCueVol[d], fBaseLevel, fTrimFactor)
            SLD_drawSlider(gaPnlVars(h)\sldCueVol[d])
            If gaDispPanel(h)\bDisplayPan[d]
              SLD_setValue(gaPnlVars(h)\sldCuePan[d], panToSliderValue(fPanNow))
              SLD_setBaseValue(gaPnlVars(h)\sldCuePan[d], panToSliderValue(fBasePan))
              SLD_drawSlider(gaPnlVars(h)\sldCuePan[d])
            EndIf
          EndIf
        Next d
        
        Select \nFileFormat
          Case #SCS_FILEFORMAT_AUDIO
            For d = 0 To grCuePanels\nMaxDevLineNo
              CompilerIf #c_cuepanel_multi_dev_select
                nDevNoForDrawDeviceText = PNL_calcDevNoForDrawDeviceText(h, d)
;                 ; debugMsg(sProcName, "calling PNL_drawDeviceText(" + h + ", " + Str(d + grCuePanels\nMaxDevLines) + ")")
;                 PNL_drawDeviceText(h, d + grCuePanels\nMaxDevLines) ; nb will draw text for both 'd' and 'd + \nMaxDevLines', eg for both 'd' and 'd+4'. Handles absent device names OK, eg if no 'd+4' device assigned.
                ; debugMsg(sProcName, "calling PNL_drawDeviceText(" + h + ", " + nDevNoForDrawDeviceText + ")")
                PNL_drawDeviceText(h, nDevNoForDrawDeviceText)
              CompilerElse
                sTmp = VST_adjustLogicalDevForVST(\sLogicalDev[d])
                nDevGadgetNo = gaPnlVars(h)\lblDevice[d]
                SetGadgetText(nDevGadgetNo, sTmp)
                If Len(Trim(sTmp)) = 0
                  setVisible(nDevGadgetNo, #False)
                Else
                  setVisible(nDevGadgetNo, #True)
                EndIf
              CompilerEndIf
            Next d
            
          Case #SCS_FILEFORMAT_LIVE_INPUT
            For d = 0 To grCuePanels\nMaxDevLineNo
              If \nInputOnCount = 0
                sTmp = ""
              Else
                sTmp = \sLogicalDev[d]
              EndIf
              CompilerIf #c_cuepanel_multi_dev_select
                PNL_drawDeviceTextWithThisDevName(h, d, sTmp)
              CompilerElse
                SetGadgetText(gaPnlVars(h)\lblDevice[d], sTmp)
                If Len(Trim(sTmp)) = 0
                  setVisible(gaPnlVars(h)\lblDevice[d], #False)
                Else
                  setVisible(gaPnlVars(h)\lblDevice[d], #True)
                EndIf
              CompilerEndIf
            Next d
            
          Case #SCS_FILEFORMAT_MIDI
            CompilerIf #c_cuepanel_multi_dev_select
              PNL_drawDeviceTextWithThisDevName(h, 0, \sLogicalDev[0])
            CompilerElse
              SetGadgetText(gaPnlVars(h)\lblDevice[0], \sLogicalDev[0])
              setVisible(gaPnlVars(h)\lblDevice[0], #True)
            CompilerEndIf
            
          Case #SCS_FILEFORMAT_VIDEO
            CompilerIf #c_cuepanel_multi_dev_select
              If bMuteAudio
                PNL_drawDeviceTextWithThisDevName(h, 0, grText\sTextMute)
              Else
                PNL_drawDeviceTextWithThisDevName(h, 0, rSub\sVidAudLogicalDev)
              EndIf
            CompilerElse
              If bMuteAudio
                SetGadgetText(gaPnlVars(h)\lblDevice[0], grText\sTextMute)
              Else
                SetGadgetText(gaPnlVars(h)\lblDevice[0], rSub\sVidAudLogicalDev)
              EndIf
              setVisible(gaPnlVars(h)\lblDevice[0], #True)
            CompilerEndIf
            
        EndSelect
        
      Else    ; gaDispPanel(h)\nMaxDev >= 4
        
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          ; debugMsg(sProcName, "\bDeviceAssigned[" + d + "]=" + strB(gaDispPanel(h)\bDeviceAssigned[d]))
          If gaDispPanel(h)\bDeviceAssigned[d]
            If d < grCuePanels\nMaxDevLines ; was d < 4
              SLD_setLevel(gaPnlVars(h)\sldCueVol[d], \fCueVolNow[d], \fTrimFactor[d])
              If \bDeviceInitialTotalVolWorksSet = #False ;;;;;;;;;;;; ??????????????????? 23Apr2024
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(\fCueVolNow[d]) + ", " + StrF(\fTrimFactor[d],4) + ")")
                CompilerEndIf
                SLD_setBaseLevel(gaPnlVars(h)\sldCueVol[d], \fBVLevel[d], \fTrimFactor[d])
              EndIf
              SLD_drawSlider(gaPnlVars(h)\sldCueVol[d])
            ElseIf d < grCuePanels\nTwiceDevLines ; was d < 8
              SLD_setLevel(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], \fCueVolNow[d], \fTrimFactor[d])
              CompilerIf #cTraceCueTotalVolNow
                debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(\fCueVolNow[d]) + ", " + StrF(\fTrimFactor[d],4) + ")")
              CompilerEndIf
              ; If \bDeviceInitialTotalVolWorksSet = #False
                SLD_setBaseLevel(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], \fBVLevel[d], \fTrimFactor[d])
              ; EndIf
              SLD_drawSlider(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines])
            EndIf
          EndIf
        Next d
        
      EndIf
      
      If grLicInfo\sLicType = "D"
        If \nFileFormat = #SCS_FILEFORMAT_MIDI
          SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
          SLD_setEnabled(gaPnlVars(h)\sldCueVol[0], #False)
          SLD_setEnabled(gaPnlVars(h)\sldCuePan[0], #False)
        Else
          If (\nFileState = #SCS_FILESTATE_OPEN) And (\bAudTypeI = #False)
            SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #True)
          Else
            SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
          EndIf
          For d = 0 To grCuePanels\nMaxDevLineNo
            SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], gaDispPanel(h)\bEnableVolAndPan[d])
            SLD_setEnabled(gaPnlVars(h)\sldCuePan[d], gaDispPanel(h)\bEnableVolAndPan[d])
          Next d
        EndIf
      Else
        If \nFileFormat = #SCS_FILEFORMAT_MIDI
          SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
          SLD_setEnabled(gaPnlVars(h)\sldCueVol[0], #False)
          SLD_setEnabled(gaPnlVars(h)\sldCuePan[0], #False)
        Else
          If (\nFileState = #SCS_FILESTATE_OPEN) And (\bAudTypeI = #False)
            SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #True)
          Else
            SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
          EndIf
          If bMuteAudio = #False
            If grLicInfo\nLicLevel = #SCS_LIC_LITE
              For d = 0 To grCuePanels\nMaxDevLineNo
                SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], #False)
                SLD_setEnabled(gaPnlVars(h)\sldCuePan[d], #False)
              Next d
              
            ElseIf grLicInfo\nLicLevel = #SCS_LIC_STD
              For d = 0 To grCuePanels\nMaxDevLineNo
                If d < 2
                  SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], gaDispPanel(h)\bEnableVolAndPan[d])
                  SLD_setEnabled(gaPnlVars(h)\sldCuePan[d], gaDispPanel(h)\bEnableVolAndPan[d])
                Else
                  SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], #False)
                  SLD_setEnabled(gaPnlVars(h)\sldCuePan[d], #False)
                EndIf
              Next d
              
            Else ; #SCS_LIC_PRO or higher
              For d = 0 To grCuePanels\nMaxDevLineNo
                If gaDispPanel(h)\nMaxDev < grCuePanels\nMaxDevLines ; was < 4
                  If d < grCuePanels\nMaxDevLines ; was d < 4
                    SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], gaDispPanel(h)\bEnableVolAndPan[d])
                    SLD_setEnabled(gaPnlVars(h)\sldCuePan[d], gaDispPanel(h)\bEnableVolAndPan[d])
                  EndIf
                Else
                  If d < grCuePanels\nMaxDevLines ; was d < 4
                    SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], gaDispPanel(h)\bEnableVolAndPan[d])
                  ElseIf d < grCuePanels\nTwiceDevLines ; was d < 8
                    SLD_setEnabled(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], gaDispPanel(h)\bEnableVolAndPan[d])
                  EndIf
                EndIf
              Next d
            EndIf
          EndIf
        EndIf
      EndIf
      
      If (\bAudTypeI = #False) And (\nFileFormat <> #SCS_FILEFORMAT_MIDI)
        If (\nLinkedToAudPtr < 0) And (\nFileState = #SCS_FILESTATE_OPEN)
          SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #True)
        Else
          SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
        EndIf
      EndIf
      
      setVisible(gaPnlVars(h)\cvsRewind, #True)
      setVisible(gaPnlVars(h)\cvsPlay, #True)
      setVisible(gaPnlVars(h)\cvsPause, #True)
      setVisible(gaPnlVars(h)\cvsRelease, #True)
      setVisible(gaPnlVars(h)\cvsFadeOut, #True)
      setVisible(gaPnlVars(h)\cvsStop, #True)
      ; debugMsg(sProcName, "calling PNL_setDisplayButtons(" + h + ", " + decodeCueState(\nAudState) + ", " + getAudLabel(\nLinkedToAudPtr) + ")")
      PNL_setDisplayButtons(h, \nAudState, \nLinkedToAudPtr)
      nPanelState = \nAudState
    EndWith
    ;}
  ElseIf rSub\bSubTypeE ; INFO bSubTypeE (Memo)
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    If bMemoContinuous
      setVisible(gaPnlVars(h)\cvsRewind, #False)
      setVisible(gaPnlVars(h)\cvsPause, #False)
    Else
      setVisible(gaPnlVars(h)\cvsRewind, #True)
      setVisible(gaPnlVars(h)\cvsPause, #True)
    EndIf
    setVisible(gaPnlVars(h)\cvsPlay, #True)
    setVisible(gaPnlVars(h)\cvsRelease, #False)
    setVisible(gaPnlVars(h)\cvsFadeOut, #False)
    setVisible(gaPnlVars(h)\cvsStop, #True)
    PNL_setDisplayButtons(h, rSub\nSubState, -1)
    nPanelState = rSub\nSubState
    
    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    If bMemoContinuous
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #False)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #False)
      bRedrawProgressSlider = #False
    Else
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #True)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #True)
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, (rSub\nMemoDisplayTime-1))
      SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, 0)
    EndIf
    ;}
  ElseIf rSub\bSubTypeK ; INFO bSubTypeK (Lighting)
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    setVisible(gaPnlVars(h)\cvsRewind, #False)
    setVisible(gaPnlVars(h)\cvsPlay, #True)
    setVisible(gaPnlVars(h)\cvsPause, #False)
    setVisible(gaPnlVars(h)\cvsRelease, #False)
    setVisible(gaPnlVars(h)\cvsFadeOut, #False)
    setVisible(gaPnlVars(h)\cvsStop, #False)
    PNL_setDisplayButtons(h, rSub\nSubState, -1)
    nPanelState = rSub\nSubState
    
    ; debugMsg(sProcName, rSub\sSubLabel + ", \nSubDuration=" + rSub\nSubDuration)
    If rSub\nSubDuration > 0
      SLD_setValue(gaPnlVars(h)\sldPnlProgress, 0)
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #True)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #True)
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, (rSub\nSubDuration-1))
      SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, 0)
      SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
    EndIf

    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    ;}
  ElseIf rSub\bSubTypeL ; INFO bSubTypeL (Level Change)
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    
    If rSub\nLCTimeMax > 0
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, rSub\nLCTimeMax)
    Else
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, 0)
    EndIf
    SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, 0)
    SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
    
    If (rSub\nLCPositionMax >= 0) And (rSub\nLCPositionMax <= SLD_getMax(gaPnlVars(h)\sldPnlProgress))
      CompilerIf #cTracePosition
        debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(rSub\nLCPositionMax) + ")")
      CompilerEndIf
      SLD_setValue(gaPnlVars(h)\sldPnlProgress, rSub\nLCPositionMax)
    EndIf
    
    If rSub\nSubState = #SCS_CUE_CHANGING_LEVEL
      sThisRunningInd = "Chg.Lvl of " + rSub\sLCCue
    EndIf
    
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    ; debugMsg(sProcName, rSub\sSubLabel + ", \nLCAudPtr=" + Str(rSub\nLCAudPtr))
    If gaDispPanel(h)\nMaxDev < grCuePanels\nMaxDevLines ; was < 4
      For d = 0 To grCuePanels\nMaxDevLineNo
        If gaDispPanel(h)\bDeviceAssigned[d]
          If rSub\nLCAction = #SCS_LC_ACTION_ABSOLUTE
            If rSub\bLCTargetIsP Or rSub\bLCTargetIsA
              SLD_setLevel(gaPnlVars(h)\sldCueVol[d], rSub\fLCReqdBVLevel[d], aSub(rSub\nLCSubPtr)\fSubTrimFactor[d])
            Else
              SLD_setLevel(gaPnlVars(h)\sldCueVol[d], rSub\fLCReqdBVLevel[d], aAud(rSub\nLCAudPtr)\fTrimFactor[d])
              CompilerIf #cTraceCueTotalVolNow
                debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(rSub\fLCReqdBVLevel[d]) + ", " + StrF(aAud(rSub\nLCAudPtr)\fTrimFactor[d],4) + ")")
              CompilerEndIf
            EndIf
          EndIf
          SLD_setLevel(gaPnlVars(h)\sldCueVol[d], rSub\fLCReqdBVLevel[d])
          CompilerIf #cTraceCueTotalVolNow
            debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(rSub\fLCReqdBVLevel[d]) + ")")
          CompilerEndIf
          SLD_setBaseLevel(gaPnlVars(h)\sldCueVol[d], #SCS_SLD_NO_BASE)
          SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], #False)
          SLD_drawSlider(gaPnlVars(h)\sldCueVol[d])
          If gaDispPanel(h)\bDisplayPan[d]
            SLD_setValue(gaPnlVars(h)\sldCuePan[d], panToSliderValue(rSub\fLCReqdPan[d]))
            SLD_setBaseValue(gaPnlVars(h)\sldCuePan[d], #SCS_SLD_NO_BASE)
            SLD_setEnabled(gaPnlVars(h)\sldCuePan[d], #False)
            SLD_drawSlider(gaPnlVars(h)\sldCuePan[d])
          EndIf
        EndIf
      Next d
    Else
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If d < grCuePanels\nMaxDevLines ; was d < 4
          If gaDispPanel(h)\bDeviceAssigned[d]
            If rSub\nLCAction = #SCS_LC_ACTION_ABSOLUTE
              If rSub\bLCTargetIsP Or rSub\bLCTargetIsA
                SLD_setLevel(gaPnlVars(h)\sldCueVol[d], rSub\fLCReqdBVLevel[d], aSub(rSub\nLCSubPtr)\fSubTrimFactor[d])
              Else
                SLD_setLevel(gaPnlVars(h)\sldCueVol[d], rSub\fLCReqdBVLevel[d], aAud(rSub\nLCAudPtr)\fTrimFactor[d])
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(rSub\fLCReqdBVLevel[d]) + ", " + StrF(aAud(rSub\nLCAudPtr)\fTrimFactor[d],4) + ")")
                CompilerEndIf
              EndIf
            EndIf
            SLD_setLevel(gaPnlVars(h)\sldCueVol[d], rSub\fLCReqdBVLevel[d])
            CompilerIf #cTraceCueTotalVolNow
              debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(rSub\fLCReqdBVLevel[d]) + ")")
            CompilerEndIf
            SLD_setBaseLevel(gaPnlVars(h)\sldCueVol[d], #SCS_SLD_NO_BASE)
            SLD_setEnabled(gaPnlVars(h)\sldCueVol[d], #False)
            SLD_drawSlider(gaPnlVars(h)\sldCueVol[d])
          EndIf
        ElseIf d < grCuePanels\nTwiceDevLines ; was d < 8
          If gaDispPanel(h)\bDeviceAssigned[d]
            If rSub\nLCAction = #SCS_LC_ACTION_ABSOLUTE
              If rSub\bLCTargetIsP Or rSub\bLCTargetIsA
                SLD_setLevel(gaPnlVars(h)\sldCueVol[d-grCuePanels\nMaxDevLines], rSub\fLCReqdBVLevel[d], aSub(rSub\nLCSubPtr)\fSubTrimFactor[d])
              Else
                SLD_setLevel(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], rSub\fLCReqdBVLevel[d], aAud(rSub\nLCAudPtr)\fTrimFactor[d])
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(rSub\fLCReqdBVLevel[d]) + ", " + StrF(aAud(rSub\nLCAudPtr)\fTrimFactor[d],4) + ")")
                CompilerEndIf
              EndIf
            EndIf
            SLD_setLevel(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], rSub\fLCReqdBVLevel[d])
            CompilerIf #cTraceCueTotalVolNow
              debugMsg(sProcName, "SLD_setBaseLevel(gaPnlVars(" + h + ")\sldCueVol[" + Str(d-grCuePanels\nMaxDevLines) + "], " + traceLevel(rSub\fLCReqdBVLevel[d]) + ")")
            CompilerEndIf
            SLD_setBaseLevel(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], #SCS_SLD_NO_BASE)
            SLD_setEnabled(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], #False)
            SLD_drawSlider(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines])
          EndIf
        EndIf
      Next d
    EndIf
    
    If gaDispPanel(h)\nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB
      setVisible(gaPnlVars(h)\cvsRewind, #False)
      setVisible(gaPnlVars(h)\cvsPlay, #True)
      setVisible(gaPnlVars(h)\cvsPause, #False)
      setVisible(gaPnlVars(h)\cvsRelease, #False)
      setVisible(gaPnlVars(h)\cvsFadeOut, #False)
      setVisible(gaPnlVars(h)\cvsStop, #False)
    Else
      setVisible(gaPnlVars(h)\cvsRewind, #True)
      setVisible(gaPnlVars(h)\cvsPlay, #True)
      setVisible(gaPnlVars(h)\cvsPause, #False)
      setVisible(gaPnlVars(h)\cvsRelease, #True)
      setVisible(gaPnlVars(h)\cvsFadeOut, #True)
      setVisible(gaPnlVars(h)\cvsStop, #True)
    EndIf
    ; debugMsg(sProcName, "calling PNL_setDisplayButtons(" + h + ", " + decodeCueState(rSub\nSubState) + ", -1)")
    PNL_setDisplayButtons(h, rSub\nSubState, -1)
    nPanelState = rSub\nSubState
    ;}
  ElseIf rSub\bSubTypeM ; INFO bSubTypeM (Control Send)
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    setVisible(gaPnlVars(h)\cvsRewind, #False)
    setVisible(gaPnlVars(h)\cvsPlay, #True)
    setVisible(gaPnlVars(h)\cvsPause, #False)
    setVisible(gaPnlVars(h)\cvsRelease, #False)
    setVisible(gaPnlVars(h)\cvsFadeOut, #False)
    setVisible(gaPnlVars(h)\cvsStop, #False)
    PNL_setDisplayButtons(h, rSub\nSubState, -1)
    nPanelState = rSub\nSubState
    
    ; debugMsg(sProcName, "M: rSub\nSubDuration=" + rSub\nSubDuration)
    If rSub\nSubDuration > 0
      SLD_setValue(gaPnlVars(h)\sldPnlProgress, 0)
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #True)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #True)
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, (rSub\nSubDuration-1))
      SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, 0)
    EndIf

    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    ;}
  ElseIf rSub\bSubTypeS ; INFO bSubTypeS (SFR)
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    setVisible(gaPnlVars(h)\cvsRewind, #False)
    setVisible(gaPnlVars(h)\cvsPlay, #True)
    setVisible(gaPnlVars(h)\cvsPause, #False)
    setVisible(gaPnlVars(h)\cvsRelease, #False)
    setVisible(gaPnlVars(h)\cvsFadeOut, #False)
    setVisible(gaPnlVars(h)\cvsStop, #False)
    PNL_setDisplayButtons(h, rSub\nSubState, -1)
    nPanelState = rSub\nSubState
    
    ; debugMsg(sProcName, "rSub\nSubDuration=" + rSub\nSubDuration)
    If rSub\nSubDuration > 0
      ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, 0)")
      SLD_setValue(gaPnlVars(h)\sldPnlProgress, 0)
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #True)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #True)
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, (rSub\nSubDuration-1))
      SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, 0)
      SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
    EndIf
    
    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    ;}
  ElseIf rSub\bSubTypeU ; INFO bSubTypeU (LTC/MTC)
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    
    If rSub\nMTCDuration > 0
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, (rSub\nMTCDuration-1))
    Else
      SLD_setMax(gaPnlVars(h)\sldPnlProgress, 0)
    EndIf
    SLD_setLineCount(gaPnlVars(h)\sldPnlProgress, 0)
    SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
    
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    setVisible(gaPnlVars(h)\cvsRewind, #True)
    setVisible(gaPnlVars(h)\cvsPlay, #True)
    setVisible(gaPnlVars(h)\cvsPause, #True)
    setVisible(gaPnlVars(h)\cvsRelease, #False)
    setVisible(gaPnlVars(h)\cvsFadeOut, #False)
    setVisible(gaPnlVars(h)\cvsStop, #True)
    ; debugMsg(sProcName, "calling PNL_setDisplayButtons(" + h + ", " + decodeCueState(rSub\nSubState) + ", -1, " + getSubLabel(rSub\nMTCLinkedToAFSubPtr) + ")")
    PNL_setDisplayButtons(h, rSub\nSubState, -1, rSub\nMTCLinkedToAFSubPtr)
    nPanelState = rSub\nSubState
    
    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    
    If rSub\nMTCDuration <= 0 Or rSub\nMTCLinkedToAFSubPtr >= 0
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #False)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #False)
      bRedrawProgressSlider = #False
    Else
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #True)")
      SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #True)
      If rSub\nMTCLinkedToAFSubPtr >= 0
        SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #False)
      Else
        SLD_setEnabled(gaPnlVars(h)\sldPnlProgress, #True)
      EndIf
      bRedrawProgressSlider = #True
    EndIf
    ;}
  Else
    ;{
    bDisplayThisPanel = #True
    gaDispPanel(h)\nDPSubState = rSub\nSubState
    nBackColor = getSubBackColor(pSubPtr, #True)
    nTextColor = getSubTextColor(pSubPtr, #True)
    If sOtherInfoText
      sOtherInfoText + "   "
    EndIf
    sOtherInfoText + loadOtherInfoTextForSub(pSubPtr)
    PNL_setOtherInfoText(h, sOtherInfoText, #False)
    
    setVisible(gaPnlVars(h)\cvsRewind, #False)
    setVisible(gaPnlVars(h)\cvsPlay, #True)
    setVisible(gaPnlVars(h)\cvsPause, #False)
    setVisible(gaPnlVars(h)\cvsRelease, #False)
    setVisible(gaPnlVars(h)\cvsFadeOut, #False)
    setVisible(gaPnlVars(h)\cvsStop, #False)
    PNL_setDisplayButtons(h, rSub\nSubState, -1)
    nPanelState = rSub\nSubState
    
    ; setVisible(gaPnlVars(h)\lblCueLevel, #False)
    ; setVisible(gaPnlVars(h)\lblCuePan, #False)
    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
      setVisible(gaPnlVars(h)\cvsDevice[d], #False)
      CompilerElse
      setVisible(gaPnlVars(h)\lblDevice[d], #False)
      CompilerEndIf
      SLD_setVisible(gaPnlVars(h)\sldCueVol[d], #False)
      SLD_setVisible(gaPnlVars(h)\sldCuePan[d], #False)
    Next d
    ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #False)")
    SLD_setVisible(gaPnlVars(h)\sldPnlProgress, #False)
    bRedrawProgressSlider = #False
    ;}
  EndIf
  
  With gaPnlVars(h)
    \nBackColor = nBackColor
    \nTextColor = nTextColor
    \bNextManualCue = #False
    ; debugMsg(sProcName, "gaPnlVars(" + h + ")\bNextManualCue=" + strB(\bNextManualCue))
    \bPlaying = #False
  EndWith
  ; if panel is to be displayed, set the backcolors and then make the panel visible
  
  If h > gnMaxDispPanel
    bDisplayThisPanel = #False
  EndIf
  
  ; debugMsg(sProcName, "h=" + h + ", gnMaxDispPanel=" + gnMaxDispPanel + ", bDisplayThisPanel=" + strB(bDisplayThisPanel))
  ; debugMsg(sProcName, "nLabel=" + Str(nLabel) + ", nTextColor=" + Str(nTextColor) + ", nBackColor=" + Str(nBackColor))
  
  ; debugMsg(sProcName, "bDisplayThisPanel=" + strB(bDisplayThisPanel) + ", nThisItemState=" + decodeCueState(nThisItemState) + ", sThisRunningInd=" + sThisRunningInd)
  If bDisplayThisPanel
    
    ; do not 'load' lblRunningInd if item is currently counting down as this would show a glitch in the countdown populated by PNL_updateDisplayPanel()
    If (nThisItemState < #SCS_CUE_COUNTDOWN_TO_START) Or (nThisItemState > #SCS_CUE_PL_COUNTDOWN_TO_START) Or (nThisItemState = #SCS_CUE_PAUSED) ; Added "Or (nThisItemState = #SCS_CUE_PAUSED)" 6Nov2020 11.8.3.3ad
      If GGT(gaPnlVars(h)\lblRunningInd) <> sThisRunningInd
        SGT(gaPnlVars(h)\lblRunningInd, sThisRunningInd)
        CompilerIf #cTraceRunningInd
          debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
        CompilerEndIf
        PNL_adjustRunningIndSizeIfReqd(h)
        ; debugMsg(sProcName, "sThisRunningInd=" + sThisRunningInd + ", \lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd) + ", nPanelState=" + decodeCueState(nPanelState))
        PNL_setRunningInd(h, nPanelState) ; may need to re-colour the running ind
      EndIf
      ; debugMsg(sProcName, "\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
    ElseIf rSub\bSubTypeU
      If aSub(pSubPtr)\nMTCType = #SCS_MTC_TYPE_MTC
        With grMTCSendControl
          If (\nMTCSendState > #SCS_MTC_STATE_IDLE) And (\nMTCSendState < #SCS_MTC_STATE_STOPPED)
            \nMTCPanelIndex = h
            \nRunningIndGadgetNo = gaPnlVars(h)\lblRunningInd
            ; debugMsg(sProcName, "rSub=" + rSub\sSubLabel + ", grMTCSendControl\nMTCPanelIndex=" + Str(\nMTCPanelIndex) + ", \nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
            If \nMTCSendState = #SCS_MTC_STATE_PRE_ROLL
              If GetGadgetText(\nRunningIndGadgetNo) <> grText\sTextPreRoll
                SGT(\nRunningIndGadgetNo, grText\sTextPreRoll)
                CompilerIf #cTraceRunningInd
                  debugMsg(sProcName, "GGT(\nRunningIndGadgetNo)=" + GGT(\nRunningIndGadgetNo))
                CompilerEndIf
              EndIf
            Else
              SGT(gaPnlVars(h)\lblRunningInd, RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0"))
              CompilerIf #cTraceRunningInd
                debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
              CompilerEndIf
            EndIf
          EndIf
        EndWith
      ElseIf aSub(pSubPtr)\nMTCType = #SCS_MTC_TYPE_LTC
        With grMTCSendControl
          SGT(gaPnlVars(h)\lblRunningInd, RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0"))
          CompilerIf #cTraceRunningInd
            debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
          CompilerEndIf
        EndWith
      EndIf
    EndIf
    
    PNL_colorCueAndDescription(h, pSubPtr)
    
    CompilerIf #c_cuepanel_multi_dev_select = #False
      If gaPnlVars(h)\bActiveOrComplete
        ; debugMsg(sProcName, "color ActiveOrComplete")
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
      Else
        ; debugMsg(sProcName, "color Inactive")
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
      EndIf
      For d = 0 To grCuePanels\nMaxDevLineNo
        SetGadgetColors(gaPnlVars(h)\lblDevice[d], nTextColor, nBackColor)
      Next d
    CompilerEndIf
    
    If getVisible(gaPnlVars(h)\cvsLinked) = #False
      If rSub\bSubTypeAorP
        gaDispPanel(h)\nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_FILE
        ; debugMsg(sProcName, "gaDispPanel(" + h + ")\nTransportSwitchCode=" + gaDispPanel(h)\nTransportSwitchCode)
      ElseIf (rSub\nPrevSubIndex >= 0) Or (rSub\nNextSubIndex >= 0)
        ; cue has more than one sub-cue
        gaDispPanel(h)\nTransportSwitchCode = #SCS_TRANSPORT_SWITCH_SUB
      Else
        gaDispPanel(h)\nTransportSwitchCode = 0
      EndIf
      PNL_createSwitchMenu(h, #True)
      PNL_drawSwitch(h)
    EndIf
    
    PNL_setShuffleAndFirstButtons(h, @bShuffleVisible, @bShuffleEnabled, @bFirstVisible, @bFirstEnabled)
    
    setVisible(gaPnlVars(h)\cntCuePanel, #True)
    
    If bRedrawProgressSlider
      ; debugMsg(sProcName, "calling SLD_drawSlider(" + gaPnlVars(h)\sldPnlProgress + "), SLD_getWidth()=" + SLD_getWidth(gaPnlVars(h)\sldPnlProgress))
      SLD_drawSlider(gaPnlVars(h)\sldPnlProgress)
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, "calling PNL_adjustSliderSizes(" + h + ")")
  PNL_adjustSliderSizes(h)
  ; debugMsg(sProcName, "calling PNL_arrangeSliders(" + h + ")")
  PNL_arrangeSliders(h)
  
  With gaPnlVars(h)
    If IsImage(\nImageHandle)
      ; debugMsg(sProcName, "calling SetGadgetState(" + Str(\imgType) + ", ImageID(\nImageHandle))")
      SetGadgetState(\imgType, ImageID(\nImageHandle))
    EndIf
    \bInLoadingDisplay = #False
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_drawPanelGradient(h)
  PROCNAMECP(h)
  Protected nTextColor, nBackColor
  Protected d, nDevNoForDrawDeviceText
  
  ; debugMsg(sProcName, #SCS_START)

  With gaPnlVars(h)
    If \bActiveOrComplete
      ; debugMsg(sProcName, "color ActiveOrComplete")
      nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
      nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
    Else
      ; debugMsg(sProcName, "color Inactive")
      nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
      nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
    EndIf
    SetGadgetColor(\cntCuePanel, #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(\cntCuePanel, #PB_Gadget_FrontColor, nTextColor)
    SetGadgetColor(\cntTransportCtls, #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(\cntFaderAndPanCtls, #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(\lblDescriptionA, #PB_Gadget_BackColor, nBackColor)
    SetGadgetColor(\lblDescriptionA, #PB_Gadget_FrontColor, nTextColor)
    ; SetGadgetColor(gaPnlVars(h)\lblDescriptionB, #PB_Gadget_BackColor, nBackColor)
    ; If \sOtherInfoText ; removed test 4May2019 11.8.1aj as we always need to draw the 'other info' canvas
    PNL_drawOtherInfoText(h)
    ; EndIf
    
    For d = 0 To grCuePanels\nMaxDevLineNo
      CompilerIf #c_cuepanel_multi_dev_select
        nDevNoForDrawDeviceText = PNL_calcDevNoForDrawDeviceText(h, d)
        ; debugMsg(sProcName, "calling PNL_drawDeviceText(" + h + ", " + nDevNoForDrawDeviceText + ")")
        PNL_drawDeviceText(h, nDevNoForDrawDeviceText)
      CompilerElse
        SetGadgetColor(\lblDevice[d], #PB_Gadget_BackColor, nBackColor)
        SetGadgetColor(\lblDevice[d], #PB_Gadget_FrontColor, nTextColor)
      CompilerEndIf
      SLD_drawSlider(\sldCueVol[d])
      SLD_drawSlider(\sldCuePan[d])
    Next d
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure PNL_updateDisplayPanel(h, pCuePtr, pSubPtr, pAudPtr, pCuePanelUpdateFlags)
  PROCNAMECP(h)
  If (aSub(pSubPtr)\bSubTypeHasAuds) And (pAudPtr >= 0)
    sProcName = buildAudProcName(sProcName, pAudPtr)
  Else
    sProcName = buildSubProcName(sProcName, pSubPtr)
  EndIf
  Protected d, nMyCountDownTimeLeft, sCountDownTimeLeft.s
  Protected sTmp.s, sCueState.s, nLinkedAudPtr
  Protected sOtherInfoText.s, nPLTimeRemaining
  Protected sOtherInfoText2.s, bDisplayCountDown
  Protected fBVLevelNow.f, fPanNow.f
  Protected fReqdDBLevel.f
  Protected nReqdTextColor
  Protected nTimeRemaining
  Protected nTimeValue
  Protected nLabel
  Protected bProcessSubStateChange
  Protected sRunningIndText.s, bSkipSetRunningIndText, sMidiCueText.s
  Protected nReqdState
  Protected nPlayingPos
  Static sPLRemain.s, sRelStart.s, sTextLinked.s, bStaticLoaded

  If gbClosingDown
    ProcedureReturn
  EndIf

  If gnThreadNo > #SCS_THREAD_MAIN
    debugMsg(sProcName, #SCS_START)
  EndIf
  
  nLabel = 100
  
  If bStaticLoaded = #False
    sPLRemain = "  " + Lang("OtherInfo", "PLRemain") + " "
    sRelStart = Lang("OtherInfo", "RelStart") + " "
    sTextLinked = " (" + Lang("Common", "Linked") + ")"
    bStaticLoaded = #True
  EndIf
  
  With aSub(pSubPtr)
    If ((\nRelStartTime > 0) Or (\nRelStartMode > #SCS_RELSTART_AS_CUE)) And (\nSubState < #SCS_CUE_FADING_IN)
      sOtherInfoText = sRelStart + RelStartToString(\nRelStartTime, \nRelStartMode)
    EndIf
  EndWith
  
  ; added 26Nov2018 11.7.1.4ay
  ; gaDispPanel(h)\nDPCuePtr etc are populated for ALL gaDispPanel() entries in PNL_loadDispPanels() to identify the cue etc to be displayed in each cue panel.
  ; However, the gaPnlVars(h) entry is not reloaded until PNL_loadOneDispPanel(h) is called, which may have been deferred for performance reasons.
  With gaPnlVars(h)
    If pCuePtr <> \m_nCuePtr
      ; debugMsg(sProcName, "exiting because pCuePtr=" + getCueLabel(pCuePtr) + " but gaPnlVars(" + h + ")\m_nCuePtr=" + getCueLabel(\m_nCuePtr) + ", gnLabelUpdDispPanels=" + gnLabelUpdDispPanels)
      ProcedureReturn
    EndIf
    If pSubPtr <> \m_nSubPtr
      ; debugMsg(sProcName, "exiting because pSubPtr=" + getSubLabel(pSubPtr) + " but gaPnlVars(" + h + ")\m_nSubPtr=" + getSubLabel(\m_nSubPtr) + ", gnLabelUpdDispPanels=" + gnLabelUpdDispPanels)
      ProcedureReturn
    EndIf
  EndWith
  ; end added 26Nov2018 11.7.1.4ay
  
  If Trim(aCue(pCuePtr)\sMidiCue)
    If grOperModeOptions(gnOperMode)\bShowMidiCueInCuePanels
      sMidiCueText = "[MIDI " + Trim(aCue(pCuePtr)\sMidiCue) + "] "
    EndIf
  EndIf
  
  gaDispPanel(h)\nDPLinkedToAudPtr = -1 ; Added 2May2022 11.9.1
  gaDispPanel(h)\nDPAudLinkCount = 0    ; Added 2May2022 11.9.1
  
  If (aSub(pSubPtr)\bSubTypeHasAuds) And (pAudPtr >= 0)   ; INFO set display panel for bSubTypeHasAuds And pAudPtr >= 0
    With aAud(pAudPtr)
      gaDispPanel(h)\nDPLinkedToAudPtr = \nLinkedToAudPtr ; Added 2May2022 11.9.1
      gaDispPanel(h)\nDPAudLinkCount = \nAudLinkCount     ; Added 2May2022 11.9.1
;       debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", \nRelFilePos=" + \nRelFilePos + ", \nPlayingPos=" + \nPlayingPos +
;                           ", \nLinkedToAudPtr=" + getAudLabel(\nLinkedToAudPtr) +
;                           ", SLD_getValue(gaPnlVars(" + h + ")\sldPnlProgress)=" + SLD_getValue(gaPnlVars(h)\sldPnlProgress) +
;                           ", SLD_getMax(gaPnlVars(" + h + ")\sldPnlProgress)=" + SLD_getMax(gaPnlVars(h)\sldPnlProgress))
      nPlayingPos = getAudPlayingPos(pAudPtr)
      ; debugMsg(sProcName, "getAudPlayingPos(" + getAudLabel(pAudPtr) + ") returned nPlayingPos=" + nPlayingPos)
      If ((\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)) Or (nPlayingPos <> SLD_getValue(gaPnlVars(h)\sldPnlProgress))
        gnLabelUpdDispPanel = 80010
        If \bAudTypeI = #False
          If nPlayingPos > SLD_getMax(gaPnlVars(h)\sldPnlProgress)
            nTimeValue = SLD_getMax(gaPnlVars(h)\sldPnlProgress)
            If SLD_getValue(gaPnlVars(h)\sldPnlProgress) <> nTimeValue ; Test added 21Oct2024 11.10.6as to avoid unnecessary processing after 'pause at end' on videos
              CompilerIf #cTracePosition
                debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + nTimeValue + ")")
              CompilerEndIf
              SLD_setValue(gaPnlVars(h)\sldPnlProgress, nTimeValue)
              PNL_setDisplayButtons(h, \nAudState, \nLinkedToAudPtr)
              If gaDispPanel(h)\bM2T_Active
                M2T_displayMoveToTimeValueIfActive(h, nTimeValue)
              EndIf
            EndIf
          Else
            nTimeValue = nPlayingPos
            ; Added 3Nov2020 11.8.3.3ac - This was added so that the cue position displayed exactly matches the cue position of the first of the linked audio files
            If \nLinkedToAudPtr >= 0
              nTimeValue = getAudPlayingPos(\nLinkedToAudPtr)
            EndIf
            ; End added 3Nov2020 11.8.3.3ac
            CompilerIf #cTracePosition ;;;; TEMP 16Mar2023 !!!!!!!!!!!
              debugMsg(sProcName, "\nLinkedToAudPtr=" + getAudLabel(\nLinkedToAudPtr) + ", nTimeValue=" + nTimeValue + ", SLD_getMax(gaPnlVars(" + h + ")\sldPnlProgress)=" + SLD_getMax(gaPnlVars(h)\sldPnlProgress))
            CompilerEndIf
            If (nTimeValue >= 0) And (nTimeValue <= SLD_getMax(gaPnlVars(h)\sldPnlProgress))
              If SLD_getValue(gaPnlVars(h)\sldPnlProgress) <> nTimeValue
                CompilerIf #cTracePosition
                  debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + nTimeValue + ")")
                CompilerEndIf
                SLD_setValue(gaPnlVars(h)\sldPnlProgress, nTimeValue)
                CompilerIf #cTracePosition
                  debugMsg(sProcName, "returned from SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + nTimeValue + ")")
                CompilerEndIf
                If gaDispPanel(h)\bM2T_Active
                  M2T_displayMoveToTimeValueIfActive(h, nTimeValue)
                EndIf
              EndIf
            EndIf
            If pCuePanelUpdateFlags & #SCS_CUEPNL_TRANSPORT
              ; debugMsg(sProcName, "calling PNL_setDisplayButtons(" + h + ", " + decodeCueState(\nAudState) + ", " + getAudLabel(\nLinkedToAudPtr) + ")")
              PNL_setDisplayButtons(h, \nAudState, \nLinkedToAudPtr)
            EndIf
          EndIf
          
          gnLabelUpdDispPanel = 80030
          If grProd\nVisualWarningTime > 0
            If aCue(pCuePtr)\bWarningBeforeEnd And aCue(pCuePtr)\bDisplayingWarningBeforeEnd
              If ((\nMaxLoopInfo < 0) Or (\aLoopInfo(\nMaxLoopInfo)\bLoopReleased)) And (\nCueDuration > 0)
                nTimeRemaining = \nCueDuration - nPlayingPos
                If nTimeRemaining <= grProd\nVisualWarningTime
                  gaDispPanel(h)\nVisualWarningTimeRemaining = nTimeRemaining
                  nReqdTextColor = GetGadgetColor(gaPnlVars(h)\lblDescriptionA, #PB_Gadget_FrontColor)
                  If gaDispPanel(h)\nVisualWarningState = 0
                    gaDispPanel(h)\nVisualWarningState = 2
                    nReqdTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
                  ElseIf (gaDispPanel(h)\nVisualWarningState = 1) And ((gqTimeNow - gaDispPanel(h)\qVisualWarningLastChangeTime) >= 500)
                    gaDispPanel(h)\nVisualWarningState = 2
                    nReqdTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
                  ElseIf (gaDispPanel(h)\nVisualWarningState = 2) And ((gqTimeNow - gaDispPanel(h)\qVisualWarningLastChangeTime) >= 200)
                    gaDispPanel(h)\nVisualWarningState = 1
                    nReqdTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
                  EndIf
                  If GetGadgetColor(gaPnlVars(h)\lblDescriptionA, #PB_Gadget_FrontColor) <> nReqdTextColor
                    SetGadgetColor(gaPnlVars(h)\lblDescriptionA, #PB_Gadget_FrontColor, nReqdTextColor)
                    gaDispPanel(h)\qVisualWarningLastChangeTime = gqTimeNow
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
          
        EndIf
        
        gnLabelUpdDispPanel = 80110
        If \bAudTypeAorP  
          ; debugMsg(sProcName, "calling calcPLPosition(" + getSubLabel(pSubPtr) + ")")
          calcPLPosition(pSubPtr)
          If aSub(pSubPtr)\nPLTotalTime = #SCS_CONTINUOUS_LENGTH
            nPLTimeRemaining = #SCS_CONTINUOUS_LENGTH
          Else
            If aSub(pSubPtr)\bPLTerminating
              nPLTimeRemaining = (\nCueDuration - nPlayingPos)
            Else
              nPLTimeRemaining = (aSub(pSubPtr)\nPLTotalTime - aSub(pSubPtr)\nPLCuePosition)
            EndIf
          EndIf
        EndIf
        
      ElseIf \nAudState = #SCS_CUE_READY
        If \bAudTypeAorP
          nPLTimeRemaining = aSub(pSubPtr)\nPLTotalTime
        EndIf
      EndIf
      
      gnLabelUpdDispPanel = 80200
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If gaDispPanel(h)\nMaxDev < grCuePanels\nMaxDevLines ; was < 4
          If gaDispPanel(h)\bDeviceAssigned[d]
            fBVLevelNow = \fCueTotalVolNow[d]
            If \bAudTypeAorP
              If (\nAudState = #SCS_CUE_PL_READY) Or (\nAudState < #SCS_CUE_FADING_IN)
                If \bCueVolManual[d]
                  fBVLevelNow = \fBVLevel[d]
                Else
                  fBVLevelNow = \fAudPlayBVLevel[d]
                EndIf
              EndIf
            EndIf
;             If gbUseSMS
;               If \sDevPXDownMix[d] = "DM"
;                 macSMSLevelPlus6dB(fBVLevelNow)
;               EndIf
;             EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + StrF(\fCueTotalVolNow[d]) + ", \fBVLevel[" + d + "]=" + StrF(\fBVLevel[d]) +
            ;                     ", gaDispPanel(" + h + ")\fDispCueVolNow[" + d + "]=" + StrF(gaDispPanel(h)\fDispCueVolNow[d]) + ", fBVLevelNow=" + StrF(fBVLevelNow))
            If gaDispPanel(h)\fDispCueVolNow[d] <> fBVLevelNow
              ; debugMsg(sProcName, "gaDispPanel(" + h + ")\fDispCueVolNow[" + d + "]=" + StrF(gaDispPanel(h)\fDispCueVolNow[d]) + ", fBVLevelNow=" + StrF(fBVLevelNow))
              gaDispPanel(h)\fDispCueVolNow[d] = fBVLevelNow
              If d < grCuePanels\nMaxDevLines ; was d <= 3
                SLD_setLevel(gaPnlVars(h)\sldCueVol[d], fBVLevelNow, \fTrimFactor[d])
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "SLD_setLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(fBVLevelNow) + ", " + StrF(\fTrimFactor[d],4) + ")")
                CompilerEndIf
              EndIf
            EndIf
          EndIf
          
          If gaDispPanel(h)\bDisplayPan[d]
            If gaDispPanel(h)\fDispCuePanNow[d] <> \fCuePanNow[d]
              gaDispPanel(h)\fDispCuePanNow[d] = \fCuePanNow[d]
              If d < grCuePanels\nMaxDevLines ; was d <= 3
                ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldCuePan[" + d + "], " + Str(panToSliderValue(\fCuePanNow[d])) + ")")
                SLD_setValue(gaPnlVars(h)\sldCuePan[d], panToSliderValue(\fCuePanNow[d]))
              EndIf
            EndIf
          EndIf
          
        Else
          
          If gaDispPanel(h)\bDeviceAssigned[d]
            ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + formatLevel(\fCueTotalVolNow[d]))
            fBVLevelNow = \fCueTotalVolNow[d]
            If \bAudTypeAorP
              If (\nAudState = #SCS_CUE_PL_READY) Or (\nAudState < #SCS_CUE_FADING_IN)
                fBVLevelNow = \fAudPlayBVLevel[d]
              EndIf
            EndIf
            ; debugMsg(sProcName, "gaDispPanel(" + h + ")\fDispCueVolNow[" + d + "]=" + formatLevel(gaDispPanel(h)\fDispCueVolNow[d]))
            If gaDispPanel(h)\fDispCueVolNow[d] <> fBVLevelNow
              gaDispPanel(h)\fDispCueVolNow[d] = fBVLevelNow
              If d < grCuePanels\nMaxDevLines ; was d <= 3
                SLD_setLevel(gaPnlVars(h)\sldCueVol[d], fBVLevelNow, \fTrimFactor[d])
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "SLD_setLevel(gaPnlVars(" + h + ")\sldCueVol[" + d + "], " + traceLevel(fBVLevelNow) + ", " + StrF(\fTrimFactor[d],4) + ")")
                CompilerEndIf
              ElseIf d < grCuePanels\nTwiceDevLines ; was d <= 7
                SLD_setLevel(gaPnlVars(h)\sldCuePan[d-grCuePanels\nMaxDevLines], fBVLevelNow, \fTrimFactor[d])
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "SLD_setLevel(gaPnlVars(" + h + ")\sldCueVol[" + Str(d-grCuePanels\nMaxDevLines) + "], " + traceLevel(fBVLevelNow) + ", " + StrF(\fTrimFactor[d],4) + ")")
                CompilerEndIf
              EndIf
            EndIf
          EndIf
          
        EndIf
      Next d
      
      gnLabelUpdDispPanel = 80300
      nLabel = 1200
      If gaDispPanel(h)\nDPSubState <> \nAudState
        If gaDispPanel(h)\nDPSubState <> \nAudState
          gaDispPanel(h)\nDPPrevSubState = gaDispPanel(h)\nDPSubState
          gaDispPanel(h)\nDPSubState = \nAudState
          debugMsg(sProcName, "gaDispPanel(" + h + ")\nDPPrevSubState=" + decodeCueState(gaDispPanel(h)\nDPPrevSubState) + ", \nDPSubState=" + decodeCueState(gaDispPanel(h)\nDPSubState))
        EndIf
        If (\bLiveInput) And (\nAudState = #SCS_CUE_PLAYING)
          sCueState = grText\sTextLive
        Else
          sCueState = gaCueState(\nAudState)
        EndIf
        If \nAudState < #SCS_CUE_COMPLETED
          sCueState + gaDispPanel(h)\sLinked
        Else
          ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
        EndIf
        ; bPrevNextManualCue = gaPnlVars(h)\bNextManualCue
        sRunningIndText = sCueState
        PNL_sldPnlProgress_SetBackColor(h, \nAudState)
        ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
        If (aSub(pSubPtr)\bSubTypeAorP) And (aSub(pSubPtr)\nAudCount > 1)
          ; added test \nAudCount > 1 following email from Peter Jackson 19/09/2014
          If pAudPtr >= 0
            compactLabel(gaPnlVars(h)\lblDescriptionA, " " + sMidiCueText + aAud(pAudPtr)\sAudDescr) ; nb sMidiCueText may be blank
          EndIf
        EndIf
        ; debugMsg(sProcName, "calling PNL_setDisplayButtons(" + h + ", " + decodeCueState(\nAudState) + ", " + getAudLabel(\nLinkedToAudPtr) + ")")
        PNL_setDisplayButtons(h, \nAudState, \nLinkedToAudPtr)
      EndIf
      
      ; debugMsg(sProcName, "calling loadOtherInfoTextForAud(" + getAudLabel(pAudPtr) + ",...)")
      sOtherInfoText = loadOtherInfoTextForAud(pAudPtr, sOtherInfoText, #True)
      
      If (nPLTimeRemaining > 0) And (nPLTimeRemaining < #SCS_CONTINUOUS_END_AT)
        If aSub(pSubPtr)\nAudCount > 1
          sOtherInfoText + sPLRemain + timeToString(nPLTimeRemaining)
        EndIf
      EndIf
      gnLabelUpdDispPanel = 80600
      PNL_setOtherInfoText(h, sOtherInfoText, #False)
      gnLabelUpdDispPanel = 80800
      
    EndWith
    
  ElseIf aSub(pSubPtr)\bSubTypeE  ; INFO set display panel for cue type E (memo)
    With aSub(pSubPtr)
      If (\bMemoContinuous = #False) And (\nMemoDisplayTime > 0)
        If \nSubPosition > SLD_getMax(gaPnlVars(h)\sldPnlProgress)
          ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(SLD_getMax(gaPnlVars(h)\sldPnlProgress)) + ")")
          SLD_setValue(gaPnlVars(h)\sldPnlProgress, SLD_getMax(gaPnlVars(h)\sldPnlProgress))
        Else
          If \nSubPosition <= SLD_getMax(gaPnlVars(h)\sldPnlProgress)
            If \nSubPosition <> SLD_getValue(gaPnlVars(h)\sldPnlProgress)
              ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(\nSubPosition) + ")")
              SLD_setValue(gaPnlVars(h)\sldPnlProgress, \nSubPosition)
            EndIf
          EndIf
        EndIf
      EndIf
      bProcessSubStateChange = #True
    EndWith
    
  ElseIf aSub(pSubPtr)\bSubTypeG  ; INFO set display panel for cue type G (go to cue)
    bProcessSubStateChange = #True
    
  ElseIf aSub(pSubPtr)\bSubTypeJ  ; INFO set display panel for cue type J (enable/disable cues)
    bProcessSubStateChange = #True
    
  ElseIf aSub(pSubPtr)\bSubTypeK  ; INFO set display panel for cue type K (lighting)
    ; bProcessSubStateChange = #True
    With aSub(pSubPtr)
      ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubDuration=" + \nSubDuration)
      If \nSubDuration > 0
        If \nSubPosition > SLD_getMax(gaPnlVars(h)\sldPnlProgress)
          ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(SLD_getMax(gaPnlVars(h)\sldPnlProgress)) + ")")
          SLD_setValue(gaPnlVars(h)\sldPnlProgress, SLD_getMax(gaPnlVars(h)\sldPnlProgress))
        Else
          If \nSubPosition <= SLD_getMax(gaPnlVars(h)\sldPnlProgress)
            If \nSubPosition <> SLD_getValue(gaPnlVars(h)\sldPnlProgress)
              ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(\nSubPosition) + ")")
              SLD_setValue(gaPnlVars(h)\sldPnlProgress, \nSubPosition)
            EndIf
          EndIf
        EndIf
      EndIf
      sRunningIndText = gaCueState(\nSubState)
      PNL_sldPnlProgress_SetBackColor(h, \nSubState)
      PNL_setDisplayButtons(h, \nSubState, -1)
    EndWith
    
  ElseIf aSub(pSubPtr)\bSubTypeL  ; INFO set display panel for cue type L (level change)
    With aSub(pSubPtr)
      If \nLCPositionMax > SLD_getMax(gaPnlVars(h)\sldPnlProgress)
        CompilerIf #cTracePosition
          debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + SLD_getMax(gaPnlVars(h)\sldPnlProgress) + ")")
        CompilerEndIf
        SLD_setValue(gaPnlVars(h)\sldPnlProgress, SLD_getMax(gaPnlVars(h)\sldPnlProgress))
      Else
        If (\nLCPositionMax >= 0) And (\nLCPositionMax <= SLD_getMax(gaPnlVars(h)\sldPnlProgress))
          If \nLCPositionMax <> SLD_getValue(gaPnlVars(h)\sldPnlProgress)
            CompilerIf #cTracePosition
              debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + \nLCPositionMax + ")")
            CompilerEndIf
            SLD_setValue(gaPnlVars(h)\sldPnlProgress, \nLCPositionMax)
          EndIf
        EndIf
      EndIf
      
      If gaDispPanel(h)\nDPSubState <> \nSubState
        gaDispPanel(h)\nDPSubState = \nSubState
        If \nSubState = #SCS_CUE_CHANGING_LEVEL
          sRunningIndText = "Chg.Lvl of " + \sLCCue
        Else
          sRunningIndText = gaCueState(\nSubState)
        EndIf
        ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
        PNL_setDisplayButtons(h, \nSubState, -1)
      EndIf
      PNL_sldPnlProgress_SetBackColor(h, \nSubState)
    EndWith
    
  ElseIf aSub(pSubPtr)\bSubTypeM  ; INFO set display panel for cue type M (control send)
    ; bProcessSubStateChange = #True
    With aSub(pSubPtr)
      If \nSubDuration > 0
        If \nSubPosition > SLD_getMax(gaPnlVars(h)\sldPnlProgress)
          ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(SLD_getMax(gaPnlVars(h)\sldPnlProgress)) + ")")
          SLD_setValue(gaPnlVars(h)\sldPnlProgress, SLD_getMax(gaPnlVars(h)\sldPnlProgress))
        Else
          If \nSubPosition <= SLD_getMax(gaPnlVars(h)\sldPnlProgress)
            If \nSubPosition <> SLD_getValue(gaPnlVars(h)\sldPnlProgress)
              ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + Str(\nSubPosition) + ")")
              SLD_setValue(gaPnlVars(h)\sldPnlProgress, \nSubPosition)
            EndIf
          EndIf
        EndIf
      EndIf
      sRunningIndText = gaCueState(\nSubState)
      PNL_sldPnlProgress_SetBackColor(h, \nSubState)
      PNL_setDisplayButtons(h, \nSubState, -1)
    EndWith
    
  ElseIf aSub(pSubPtr)\bSubTypeN  ; INFO set display panel for cue type N (note)
    bProcessSubStateChange = #True
    
  ElseIf aSub(pSubPtr)\bSubTypeQ  ; INFO set display panel for cue type Q (call cue)
    bProcessSubStateChange = #True
    
  ElseIf aSub(pSubPtr)\bSubTypeR  ; INFO set display panel for cue type R (run external program)
    bProcessSubStateChange = #True
    
  ElseIf aSub(pSubPtr)\bSubTypeS  ; INFO set display panel for cue type S (SFR)
    ; bProcessSubStateChange = #True
    With aSub(pSubPtr)
      ; debugMsg0(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition)
      If \nSubPosition <= SLD_getMax(gaPnlVars(h)\sldPnlProgress)
        If \nSubPosition <> SLD_getValue(gaPnlVars(h)\sldPnlProgress)
          ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + \nSubPosition + ")")
          SLD_setValue(gaPnlVars(h)\sldPnlProgress, \nSubPosition)
        EndIf
      EndIf
      bProcessSubStateChange = #True
    EndWith
    
  ElseIf aSub(pSubPtr)\bSubTypeT  ; INFO set display panel for cue type T (set position)
    bProcessSubStateChange = #True
    
  ElseIf aSub(pSubPtr)\bSubTypeU  ; INFO set display panel for cue type U (LTC/MTC)
    With aSub(pSubPtr)
      ; debugMsg(sProcName, "TYPE U aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", gaDispPanel(" + h + ")\nDPSubState=" + decodeCueState(gaDispPanel(h)\nDPSubState) + ", \nMTCDuration=" + \nMTCDuration)
      nLinkedAudPtr = -1
      If \nMTCDuration > 0
        nTimeValue = \nSubPosition
        ; Added 3Nov2020 11.8.3.3ac - This was added so that the cue position displayed exactly matches the cue position of the first of the linked audio files
        If \nMTCLinkedToAFSubPtr >= 0
          If aSub(\nMTCLinkedToAFSubPtr)\bSubTypeF
            nLinkedAudPtr = aSub(\nMTCLinkedToAFSubPtr)\nFirstAudIndex
            nTimeValue = getAudPlayingPos(nLinkedAudPtr)
          EndIf
        EndIf
        ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + \nSubPosition + ", nTimeValue=" + nTimeValue)
        ; End added 3Nov2020 11.8.3.3ac
        If nTimeValue > SLD_getMax(gaPnlVars(h)\sldPnlProgress)
          ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + SLD_getMax(gaPnlVars(h)\sldPnlProgress) + ")")
          SLD_setValue(gaPnlVars(h)\sldPnlProgress, SLD_getMax(gaPnlVars(h)\sldPnlProgress))
        Else
          If nTimeValue <= SLD_getMax(gaPnlVars(h)\sldPnlProgress)
            If nTimeValue <> SLD_getValue(gaPnlVars(h)\sldPnlProgress)
              ; debugMsg(sProcName, "calling SLD_setValue(gaPnlVars(" + h + ")\sldPnlProgress, " + nTimeValue + ")")
              SLD_setValue(gaPnlVars(h)\sldPnlProgress, nTimeValue)
            EndIf
          EndIf
        EndIf
        If gaDispPanel(h)\nDPSubState <> \nSubState
          ; gaDispPanel(h)\nDPSubState = \nSubState
          If \nSubState = #SCS_CUE_PLAYING
            If grMTCSendControl\nMTCPanelIndex <> h
              grMTCSendControl\nMTCPanelIndex = h
              grMTCSendControl\nRunningIndGadgetNo = gaPnlVars(h)\lblRunningInd
              ; debugMsg(sProcName, "pSubPtr=" + getSubLabel(pSubPtr) + ", grMTCSendControl\nMTCPanelIndex=" + grMTCSendControl\nMTCPanelIndex)
            EndIf
          EndIf
        EndIf
      EndIf
      Select \nSubState
        Case #SCS_CUE_PLAYING
          bSkipSetRunningIndText = #True ; do not set running ind to 'Playing' because for MTC/LTC cues running ind is set to a timecode in drawMTCSend() or drawLTCSend()
        Default
          sRunningIndText = gaCueState(\nSubState)
          ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
      EndSelect
      ; debugMsg(sProcName, "\nSubState=" + decodeCueState(\nSubState) + ", gaDispPanel(" + h + ")\nDPSubState=" + decodeCueState(gaDispPanel(h)\nDPSubState))
      bProcessSubStateChange = #True
      If \nSubState = #SCS_CUE_PAUSED
        If nLinkedAudPtr >= 0
          sRunningIndText + sTextLinked
        EndIf
      EndIf
    EndWith
    
  EndIf
  
  With aSub(pSubPtr)
    If \nSubStart = #SCS_SUBSTART_OCM And  \nSubState = #SCS_CUE_READY
      If sRunningIndText = gaCueState(#SCS_CUE_READY) And \sSubCueMarkerName
        sRunningIndText = "OCM " + getCueMarkerDisplayInfo(\nSubCueMarkerId, #True)
      EndIf
    EndIf
  EndWith
  
  If aSub(pSubPtr)\bSubTypeHasAuds And pAudPtr >= 0
    nReqdState = aAud(pAudPtr)\nAudState
  Else
    nReqdState = aSub(pSubPtr)\nSubState
  EndIf
  If bProcessSubStateChange
    If gaDispPanel(h)\nDPSubState <> nReqdState
      ;;;;;;;;; gaDispPanel(h)\nDPSubState = nReqdState
      If gaDispPanel(h)\nDPSubState <> nReqdState   ; changed 2May2022pm 11.9.1
        gaDispPanel(h)\nDPPrevSubState = gaDispPanel(h)\nDPSubState
        gaDispPanel(h)\nDPSubState = nReqdState
        debugMsg(sProcName, "gaDispPanel(" + h + ")\nDPPrevSubState=" + decodeCueState(gaDispPanel(h)\nDPPrevSubState) + ", \nDPSubState=" + decodeCueState(gaDispPanel(h)\nDPSubState))
      EndIf
      If (aSub(pSubPtr)\bLiveInput) And (nReqdState = #SCS_CUE_PLAYING)
        sRunningIndText = grText\sTextLive
      Else
        sRunningIndText = gaCueState(nReqdState)
        ; Added 6Nov2020 11.8.3.3ad
        If nReqdState = #SCS_CUE_PAUSED
          If nLinkedAudPtr >= 0
            sRunningIndText + sTextLinked
          EndIf
        EndIf
        ; End added 6Nov2020 11.8.3.3ad
      EndIf
      ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
      PNL_sldPnlProgress_SetBackColor(h, nReqdState)
      debugMsg(sProcName, "pSubPtr=" + getSubLabel(pSubPtr) + ", calling PNL_setDisplayButtons(" + h + ", " + decodeCueState(nReqdState) + ", -1, " + getSubLabel(aSub(pSubPtr)\nMTCLinkedToAFSubPtr) + ")")
      PNL_setDisplayButtons(h, nReqdState, -1, aSub(pSubPtr)\nMTCLinkedToAFSubPtr)
    EndIf
  EndIf
  
  gnLabelUpdDispPanel = 81000
  With aSub(pSubPtr)
    ; debugMsg(sProcName, "gnLabelUpdDispPanel=" + gnLabelUpdDispPanel + ", aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", nReqdState=" + decodeCueState(nReqdState))
    If nReqdState = #SCS_CUE_COUNTDOWN_TO_START
      bDisplayCountDown = #True
      If (\bSubTypeAorP) And (pAudPtr <> \nFirstPlayIndex)
        bDisplayCountDown = #False
      EndIf
      If bDisplayCountDown
        nMyCountDownTimeLeft = aCue(\nCueIndex)\nCueCountDownTimeLeft
          sCountDownTimeLeft = timeToString(nMyCountDownTimeLeft, aCue(\nCueIndex)\nAutoActTime)
          sRunningIndText = sCountDownTimeLeft
          ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
        gaDispPanel(h)\nDispCountDownTimeLeft = nMyCountDownTimeLeft
      EndIf
      
    ElseIf nReqdState = #SCS_CUE_SUB_COUNTDOWN_TO_START
      bDisplayCountDown = #True
      If (\bSubTypeAorP) And (pAudPtr <> \nFirstPlayIndex)
        bDisplayCountDown = #False
      EndIf
      ; debugMsg(sProcName, "gnLabelUpdDispPanel=" + gnLabelUpdDispPanel + ", aSub(" + getSubLabel(pSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) +
      ;                     ", bDisplayCountDown=" + strB(bDisplayCountDown) + ", \nSubCountDownTimeLeft=" + \nSubCountDownTimeLeft)
      If bDisplayCountDown
        nMyCountDownTimeLeft = \nSubCountDownTimeLeft
          sRunningIndText = timeToString(nMyCountDownTimeLeft)
          ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
        gaDispPanel(h)\nDispCountDownTimeLeft = nMyCountDownTimeLeft
      EndIf
      
    ElseIf nReqdState = #SCS_CUE_PL_COUNTDOWN_TO_START
      nMyCountDownTimeLeft = aAud(pAudPtr)\nPLCountDownTimeLeft
        sRunningIndText = timeToString(nMyCountDownTimeLeft)
        ; debugMsg(sProcName, "sRunningIndText=" + sRunningIndText)
      gaDispPanel(h)\nDispCountDownTimeLeft = nMyCountDownTimeLeft
    EndIf
    
    If (\nCueIndex = gnCueToGo) And (nReqdState <= #SCS_CUE_READY)
      PNL_setRunningInd(h, nReqdState)
      
    ElseIf sRunningIndText
      If bSkipSetRunningIndText = #False
        If sRunningIndText <> GGT(gaPnlVars(h)\lblRunningInd)
          SGT(gaPnlVars(h)\lblRunningInd, sRunningIndText)
          CompilerIf #cTraceRunningInd
            debugMsg(sProcName, "gaPnlVars(" + h + ")\lblRunningInd=" + GGT(gaPnlVars(h)\lblRunningInd))
          CompilerEndIf
          PNL_adjustRunningIndSizeIfReqd(h)
          PNL_setRunningInd(h, nReqdState)  ; added call this 14Feb2017 11.6.0 to set the correct colors in \lblRunningInd
        EndIf
      EndIf
      
    EndIf
    
  EndWith
  
  gnLabelUpdDispPanel = 89000
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_setPosTops(h, fReqdYFactor.f=0)
  PROCNAMECP(h)
  Protected n, nSliderVerticalSpace
  Protected fMyYFactor.f
  
  ; debugMsg(sProcName, #SCS_START)
  
  If fReqdYFactor = 0
    fMyYFactor = gfMainOrigYFactor
  Else
    fMyYFactor = fReqdYFactor
  EndIf
  
  With gaPnlVars(h)
    nSliderVerticalSpace = \nSliderOrigVerticalSpace * fMyYFactor
    ; debugMsg(sProcName, "nSliderVerticalSpace=" + Str(nSliderVerticalSpace) + ", \nSliderOrigVerticalSpace=" + Str(\nSliderOrigVerticalSpace) + ", fMyYFactor=" + StrF(fMyYFactor,4))
    For n = 0 To grCuePanels\nMaxDevLineNo
      \nPosTop[n] = nSliderVerticalSpace * n
    Next n
  EndWith

EndProcedure

Procedure PNL_Resize(h, fReqdYFactor.f=0, fReqdXFactor.f=0)
  PROCNAMECP(h)
  Protected n
  Protected bCntVisible, bSldProgressVisible
  Protected Dim bSldLvlVisible(0)
  Protected Dim bSldPanVisible(0)
  Protected nWindowNo, nToolBarHeight
  Protected nLeft, nTop, nWidth, nHeight, nTemp
  Protected nSoundCueHeight
  Protected nGadgetPropsIndex
  Protected nCuePanelHeightStd
  Protected nTransportCtlsTop
  Protected nProgressSliderTop, nProgressSliderHeight
  Protected bTrace
  Static nTrBtnImageWidth, nTrBtnImageHeight
  Static sApply.s, sCancel.s, bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START  + ", fReqdYFactor=" + StrF(fReqdYFactor,4) + ", fReqdXFactor=" + StrF(fReqdXFactor,4))
  
  ; debugMsg(sProcName, "gaPnlVars(" + h + ")\cntCuePanel=G" + gaPnlVars(h)\cntCuePanel + ", fReqdYFactor=" + StrF(fReqdYFactor,4))
  If IsGadget(gaPnlVars(h)\cntCuePanel) = #False
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    sApply = Lang("Btns", "Apply")
    sCancel = Lang("Btns", "Cancel")
    bStaticLoaded = #True
  EndIf
  
  CompilerIf #cTraceGadgets
    If h = 0
      bTrace = #True
    EndIf
  CompilerEndIf
  
  With gaPnlVars(h)
    If IsGadget(\cntCuePanel)
      bCntVisible = getVisible(\cntCuePanel)
      setVisible(\cntCuePanel, #False)
      nWindowNo = getWindowNo(\cntCuePanel)
      nToolBarHeight = 0
      
      ; resize the container first
      ; debugMsg(sProcName, "IsGadget(WMN\scaCuePanels)=" + Str(IsGadget(WMN\scaCuePanels)))
      ; debugMsg(sProcName, "GadgetWidth(WMN\scaCuePanels)=" + GadgetWidth(WMN\scaCuePanels) + ", GadgetWidth(WMN\splPanelsHotkeys)=" + GadgetWidth(WMN\splPanelsHotkeys) + ", GadgetWidth(WMN\cntSouth)=" + GadgetWidth(WMN\cntSouth))
      ; debugMsg(sProcName, "GetGadgetAttribute(WMN\scaCuePanels, #PB_ScrollArea_InnerWidth)=" + Str(GetGadgetAttribute(WMN\scaCuePanels, #PB_ScrollArea_InnerWidth)))
      resizeControl(\cntCuePanel, nToolBarHeight, fReqdYFactor, GetGadgetAttribute(WMN\scaCuePanels, #PB_ScrollArea_InnerWidth), bTrace, fReqdXFactor)
      ; debugMsg(sProcName, "GadgetWidth(\cntCuePanel)=" + GadgetWidth(\cntCuePanel))
      ; may need to reset grCuePanels\nCuePanelHeightStd so that PNL_loadDispPanels() provides the correct vertical spacing of the cue panels
      If h = 0
        nCuePanelHeightStd = GadgetHeight(\cntCuePanel)
        If grCuePanels\nCuePanelHeightStd <> nCuePanelHeightStd
          ; debugMsg(sProcName, "nToolBarHeight=" + Str(nToolBarHeight) + ", fReqdYFactor=" + StrF(fReqdYFactor,2))
          ; debugMsg(sProcName, "changing grCuePanels\nCuePanelHeightStd from " + grCuePanels\nCuePanelHeightStd + " to " + nCuePanelHeightStd)
          grCuePanels\nCuePanelHeightStd = nCuePanelHeightStd
          grCuePanels\nCuePanelHeightStdPlusGap = grCuePanels\nCuePanelHeightStd + grCuePanels\nCuePanelGap
        EndIf
      EndIf
      
      For n = (#SCS_GADGET_BASE_NO+1) To gnMaxGadgetNo
        nGadgetPropsIndex = n - #SCS_GADGET_BASE_NO
        If gaGadgetProps(nGadgetPropsIndex)\nGWindowNo = nWindowNo
          If (gaGadgetProps(nGadgetPropsIndex)\nCuePanelNo = h) And (gaGadgetProps(nGadgetPropsIndex)\nSliderNo = -1)
            If n <> \cntCuePanel
              If gaGadgetProps(nGadgetPropsIndex)\bSlider = #False   ; ignore sliders and gadgets within sliders
                resizeControl(n, nToolBarHeight, fReqdYFactor, -1, bTrace, fReqdXFactor)
                If gaGadgetProps(nGadgetPropsIndex)\bStandardCanvasButton
                  If GadgetWidth(n) <> nTrBtnImageWidth Or GadgetHeight(n) <> nTrBtnImageHeight
                    nTrBtnImageWidth = GadgetWidth(n)
                    nTrBtnImageHeight = GadgetHeight(n)
                    ; debugMsg(sProcName, "n=" + n + ", calling IMG_drawTrBtnImages13(" + nTrBtnImageWidth + ", " + nTrBtnImageHeight + ")")
                    IMG_drawTrBtnImages13(nTrBtnImageWidth, nTrBtnImageHeight)
                  EndIf
                  redrawCvsBtn(n)
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      Next n
      
      ; reposition transport buttons to remove any single-pixel gaps between controls, which can be caused by rounding of the xFactor
      ResizeGadget(\cvsRewind, GadgetX(\cvsShuffle)+GadgetWidth(\cvsShuffle), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cvsPlay, GadgetX(\cvsRewind)+GadgetWidth(\cvsRewind), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cvsPause, GadgetX(\cvsRewind)+GadgetWidth(\cvsRewind), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cvsRelease, GadgetX(\cvsPlay)+GadgetWidth(\cvsPlay), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cvsFadeOut, GadgetX(\cvsRelease)+GadgetWidth(\cvsRelease), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cvsStop, GadgetX(\cvsFadeOut)+GadgetWidth(\cvsFadeOut), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ; add 1-pixel gap before switch
      ResizeGadget(\cvsSwitch, GadgetX(\cvsStop)+GadgetWidth(\cvsStop)+1, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ; resize Linked field last
      nLeft = GadgetX(\cvsShuffle)
      nTop = GadgetY(\cvsSwitch)
      nWidth = (GadgetX(\cvsSwitch) + GadgetWidth(\cvsSwitch) - GadgetX(\cvsRewind))
      nHeight = GadgetHeight(\cvsSwitch)
      ResizeGadget(\cvsLinked, nLeft, nTop, nWidth, nHeight)
      ; reset 'top' of \cntTransportCtls
      nTransportCtlsTop = GadgetHeight(\cntCuePanel) - GadgetHeight(\cntTransportCtls)
      ResizeGadget(\cntTransportCtls, #PB_Ignore, nTransportCtlsTop, #PB_Ignore, #PB_Ignore)
      If IsGadget(\cntMoveToTimePrimary)
        ResizeGadget(\cntMoveToTimePrimary, #PB_Ignore, nTransportCtlsTop, #PB_Ignore, #PB_Ignore)
      EndIf
      If IsGadget(\lblMoveToTimeSecondary)
        ResizeGadget(\lblMoveToTimeSecondary, #PB_Ignore, nTransportCtlsTop, #PB_Ignore, #PB_Ignore)
      EndIf
      
      ; resize level and pan sliders (progress slider handled later in this procedure)
      ReDim bSldLvlVisible(grCuePanels\nMaxDevLineNo)
      ReDim bSldPanVisible(grCuePanels\nMaxDevLineNo)
      For n = 0 To grCuePanels\nMaxDevLineNo
        bSldLvlVisible(n) = SLD_getVisible(\sldCueVol[n])
        bSldPanVisible(n) = SLD_getVisible(\sldCuePan[n])
        SLD_setVisible(\sldCueVol[n], #False)
        SLD_setVisible(\sldCuePan[n], #False)
      Next n
      resizeControl(\cntFaderAndPanCtls, nToolBarHeight, fReqdYFactor, -1, #False, fReqdXFactor)
      \nCntFaderAndPanCtlsStdHeight = GadgetHeight(\cntFaderAndPanCtls)
      For n = 0 To grCuePanels\nMaxDevLineNo
        SLD_Resize(\sldCueVol[n], #True, fReqdYFactor, fReqdXFactor)
        SLD_Resize(\sldCuePan[n], #True, fReqdYFactor, fReqdXFactor)
      Next n
      For n = 0 To grCuePanels\nMaxDevLineNo
        ; debugMsg0(sProcName, "\sName=" + \sName + ", calling SLD_setVisible(\sldCueVol[" + n + "], " + strB(bSldLvlVisible(n)) + ")")
        SLD_setVisible(\sldCueVol[n], bSldLvlVisible(n))
        SLD_setVisible(\sldCuePan[n], bSldPanVisible(n))
      Next n
      
      If SLD_isSlider(\sldMoveToTimePosition)
        SLD_Resize(\sldMoveToTimePosition, #True, fReqdYFactor, fReqdXFactor, #False, #True, #False) ; nb bChangeTop set #False to keep top margin at 1 pixel
      EndIf
      
      setVisible(\cntCuePanel, bCntVisible)
      
      ; position other Info field after the transport controls, with the top and width of the 'linked' canvas
      nLeft = GadgetX(\cntTransportCtls) + GadgetWidth(\cntTransportCtls) + gnGap2
      nTop = GadgetY(\cntTransportCtls) + GadgetY(\cvsLinked)
      nHeight = GadgetHeight(\cvsLinked)
      ResizeGadget(\cvsPnlOtherInfo, nLeft, nTop, #PB_Ignore, nHeight)
      
      ; calculate reqd height of sound cue and description fields
      nSoundCueHeight = GadgetY(\lblRunningInd) - GadgetY(\lblSoundCue) - 1
      ResizeGadget(\lblSoundCue, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSoundCueHeight)
      
      ; resize progress slider
      nProgressSliderTop = GadgetY(\lblSoundCue) + GadgetHeight(\lblSoundCue) + 1
      nProgressSliderHeight = nTransportCtlsTop - nProgressSliderTop
      bSldProgressVisible = SLD_getVisible(\sldPnlProgress)
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, #False)")
      SLD_setVisible(\sldPnlProgress, #False)
      SLD_ResizeGadget(sProcName, \sldPnlProgress, #PB_Ignore, nProgressSliderTop, #PB_Ignore, nProgressSliderHeight)
      SLD_Resize(\sldPnlProgress, #True, 0.0, fReqdXFactor, #False, #False, #False, #True, #False)
      ; debugMsg(sProcName, "calling SLD_setVisible(gaPnlVars(" + h + ")\sldPnlProgress, " + strB(bSldProgressVisible) + ")")
      SLD_setVisible(\sldPnlProgress, bSldProgressVisible)
      
      ; position running ind 1 pixel after progress slider
      nLeft = SLD_gadgetX(\sldPnlProgress) + SLD_gadgetWidth(\sldPnlProgress) + 1
      ResizeGadget(\lblRunningInd, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      
      ; position description fields 1 pixel after the cue label, with a width that right-aligns to the right-hand end of the running ind, and set to the same height as the cue label
      nLeft = GadgetX(\lblSoundCue) + GadgetWidth(\lblSoundCue) + 1
      nWidth = GadgetX(\lblRunningInd) + GadgetWidth(\lblRunningInd) - nLeft
      ResizeGadget(\lblDescriptionA, nLeft, #PB_Ignore, nWidth, nSoundCueHeight)
      ResizeGadget(\lblDescriptionB, nLeft, #PB_Ignore, nWidth, nSoundCueHeight)
      
      If grLicInfo\bM2TAvailable
        If IsGadget(\cntMoveToTimePrimary)
          setGadgetWidth(\lblMoveToTimePrimary)
          ResizeGadget(\txtMoveToTime, GadgetX(\lblMoveToTimePrimary)+GadgetWidth(\lblMoveToTimePrimary)+gnGap, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          nLeft = GadgetX(\txtMoveToTime) + GadgetWidth(\txtMoveToTime) + 2
          nWidth = GadgetX(\lblRunningInd) - nLeft - (GadgetWidth(\btnMoveToTimeApply) + 2) - (GadgetWidth(\btnMoveToTimeCancel) + 2)
          ; debugMsg(sProcName, "GadgetX(\txtMoveToTime)=" + GadgetX(\txtMoveToTime) + ", GadgetWidth(\txtMoveToTime)=" + GadgetWidth(\txtMoveToTime))
          ; debugMsg(sProcName, "calling SLD_ResizeGadget(" + sProcName + ", \sldMoveToTimePosition, " + nLeft + ", #PB_Ignore, " + nWidth + ", #PB_Ignore)")
          SLD_ResizeGadget(sProcName, \sldMoveToTimePosition, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
          SLD_Resize(\sldMoveToTimePosition, #False)
          ResizeGadget(\btnMoveToTimeApply, SLD_gadgetX(\sldMoveToTimePosition)+SLD_gadgetWidth(\sldMoveToTimePosition)+2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(\btnMoveToTimeCancel, GadgetX(\btnMoveToTimeApply)+GadgetWidth(\btnMoveToTimeApply)+2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(\cntMoveToTimePrimary, #PB_Ignore, #PB_Ignore, GadgetX(\btnMoveToTimeCancel)+GadgetWidth(\btnMoveToTimeCancel)+2, #PB_Ignore)
        EndIf
        If IsGadget(\lblMoveToTimeSecondary)
          setGadgetWidth(\lblMoveToTimeSecondary)
        EndIf
      EndIf
      
      If GadgetWidth(\cntCuePanel) > 0
        ResizeGadget(\lnTopBorder, #PB_Ignore, #PB_Ignore, GadgetWidth(\cntCuePanel), #PB_Ignore)
        ResizeGadget(\lnBottomBorder, #PB_Ignore, GadgetHeight(\cntCuePanel)-1, GadgetWidth(\cntCuePanel), #PB_Ignore)
      EndIf
      
      PNL_drawSwitch(h)
      
    EndIf
  EndWith
  
  ; debugMsg(sProcName, "calling PNL_setPosTops")
  PNL_setPosTops(h, fReqdYFactor)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_setSliderScalingFactors(h, fYFactor.f, fXFactor.f)
  Protected d, bScalingChanged

  If (SLD_getYFactor(gaPnlVars(h)\sldPnlProgress) = fYFactor) And (SLD_getXFactor(gaPnlVars(h)\sldPnlProgress) = fXFactor)
    bScalingChanged = #False
  Else
    bScalingChanged = #True
    SLD_setYFactor(gaPnlVars(h)\sldPnlProgress, fYFactor)
    SLD_setXFactor(gaPnlVars(h)\sldPnlProgress, fXFactor)
    For d = 0 To grCuePanels\nMaxDevLineNo
      SLD_setYFactor(gaPnlVars(h)\sldCueVol[d], fYFactor)
      SLD_setXFactor(gaPnlVars(h)\sldCueVol[d], fXFactor)
      SLD_setYFactor(gaPnlVars(h)\sldCuePan[d], fYFactor)
      SLD_setXFactor(gaPnlVars(h)\sldCuePan[d], fXFactor)
    Next d
  EndIf
  ProcedureReturn bScalingChanged
EndProcedure

Procedure PNL_setTransportControlsVisible(h, bVisible, bSuppressGadgetChange=#False)
  PROCNAMECP(h)
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  With gaPnlVars(h)
    If \bShowTransportControls <> bVisible
      \bShowTransportControls = bVisible
      If bSuppressGadgetChange = #False
        If gaDispPanel(h)\bM2T_Active = #False
          setVisible(\cntTransportCtls, bVisible)
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure PNL_setFaderAndPanControlsVisible(h, bVisible, bSuppressGadgetChange=#False)
  PROCNAMECP(h)
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  With gaPnlVars(h)
    If \bShowFaderAndPanControls <> bVisible
      \bShowFaderAndPanControls = bVisible
      If bSuppressGadgetChange = #False
        setVisible(\cntFaderAndPanCtls, bVisible)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure PNL_setOrigDisplaySettings(h)
  PROCNAMECP(h)

  If gbClosingDown
    ProcedureReturn
  EndIf
  
  With gaPnlVars(h)
    \nSldCueVolOrigLeft = SLD_gadgetX(\sldCueVol[0])
    \nSldCueVolOrigWidth = SLD_gadgetWidth(\sldCueVol[0])
    \nSldCuePanOrigLeft = SLD_gadgetX(\sldCuePan[0])
    \nSldCuePanOrigWidth = SLD_gadgetWidth(\sldCuePan[0])
  EndWith
  
EndProcedure

Procedure PNL_ResizeGadget(sProcName.s, h, nLeft, nTop, nWidth, nHeight)
  With gaPnlVars(h)
    ResizeGadget(\cntCuePanel, nLeft, nTop, nWidth, nHeight)
    CompilerIf #cTraceGadgets
      debugMsg(sProcName, "ResizeGadget(" + getGadgetName(\cntCuePanel) + ", " + nLeft + ", " + nTop + ", " + nWidth + ", " + nHeight + ")")
    CompilerEndIf
    If GadgetWidth(\cntCuePanel) > 0
      ResizeGadget(\lnTopBorder,#PB_Ignore,#PB_Ignore,GadgetWidth(\cntCuePanel),#PB_Ignore)
      ResizeGadget(\lnBottomBorder,#PB_Ignore,GadgetHeight(\cntCuePanel)-1,GadgetWidth(\cntCuePanel),#PB_Ignore)
    EndIf
  EndWith
EndProcedure

Procedure PNL_SetVisible(h, bVisible)
  ; PROCNAMECP(h)
  ; debugMsg(sProcName, #SCS_START + ", gaPnlVars(" + h + ")\cntCuePanel=" + Str(gaPnlVars(h)\cntCuePanel))
  setVisible(gaPnlVars(h)\cntCuePanel, bVisible)
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure PNL_GetVisible(h)
  ; PROCNAMECP(h)
  ProcedureReturn getVisible(gaPnlVars(h)\cntCuePanel)
EndProcedure

Procedure PNL_GadgetX(h)
  PROCNAMEC()
  ProcedureReturn GadgetX(gaPnlVars(h)\cntCuePanel)
EndProcedure

Procedure PNL_GadgetY(h)
  PROCNAMEC()
  ProcedureReturn GadgetY(gaPnlVars(h)\cntCuePanel)
EndProcedure

Procedure PNL_GadgetWidth(h)
  PROCNAMEC()
  ProcedureReturn GadgetWidth(gaPnlVars(h)\cntCuePanel)
EndProcedure

Procedure PNL_GadgetHeight(h)
  PROCNAMEC()
  ProcedureReturn GadgetHeight(gaPnlVars(h)\cntCuePanel)
EndProcedure

Procedure PNL_EventHandler(h)
  PROCNAMEC()
  Protected nPropsIndex
  Protected nAltPropsIndex = -1
  
  If PNL_GetVisible(h)
    ; debugMsg0(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventGadgetNo=G" + GadgetNoAndName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", gnWindowEvent=" + decodeEvent(gnWindowEvent))
    If gnEventButtonId <> 0
      nPropsIndex = getGadgetPropsIndex(gnEventGadgetNo)
      With gaGadgetProps(nPropsIndex)
        If (\bEnabled) And (\bVisible)
          If gnEventGadgetNoForEvHdlr = gaPnlVars(h)\cvsPlay
            nAltPropsIndex = getGadgetPropsIndex(gaPnlVars(h)\cvsPause)
          ElseIf gnEventGadgetNoForEvHdlr = gaPnlVars(h)\cvsPause
            nAltPropsIndex = getGadgetPropsIndex(gaPnlVars(h)\cvsPlay)
          EndIf
          Select gnEventType
            Case #PB_EventType_MouseEnter
              \bMouseOver = #True
              If nAltPropsIndex >= 0
                gaGadgetProps(nAltPropsIndex)\bMouseOver = #True
              EndIf
              redrawCvsBtn(gnEventGadgetNo)
              
            Case #PB_EventType_MouseLeave
              \bMouseOver = #False
              If nAltPropsIndex >= 0
                gaGadgetProps(nAltPropsIndex)\bMouseOver = #False
              EndIf
              redrawCvsBtn(gnEventGadgetNo)
              
            Case #PB_EventType_LeftClick
              Select gnEventButtonId
                Case #SCS_STANDARD_BTN_FADEOUT
                  PNL_btnFadeOut_Click(h)
                Case #SCS_STANDARD_BTN_PAUSE
                  PNL_btnPause_Click(h)
                Case #SCS_STANDARD_BTN_PLAY
                  PNL_btnPlay_Click(h)
                Case #SCS_STANDARD_BTN_STOP
                  PNL_btnStop_Click(h)
                Case #SCS_STANDARD_BTN_RELEASE
                  PNL_btnRelease_Click(h)
                Case #SCS_STANDARD_BTN_REWIND
                  PNL_btnRewind_Click(h)
                Case #SCS_STANDARD_BTN_SHUFFLE
                  PNL_btnShuffle_Click(h)
                Case #SCS_STANDARD_BTN_FIRST
                  PNL_btnFirst_Click(h)
              EndSelect
          EndSelect                  
        EndIf ; EndIf (\bEnabled) And (\bVisible)
      EndWith
      
    Else
      
      With gaPnlVars(h)
        Select gnWindowEvent
          Case #PB_Event_Menu
            Select gnEventMenu
              Case #PNL_mnu_switch_cue, #PNL_mnu_switch_sub, #PNL_mnu_switch_file
                PNL_processSwitchMenuItem()
            EndSelect
            
          Case #PB_Event_Gadget
            Select gnEventGadgetNoForEvHdlr
                
              Case \btnMoveToTimeApply
                M2T_btnMoveToTimeApply_Click(h)
                
              Case \btnMoveToTimeCancel
                M2T_btnMoveToTimeCancel_Click(h)
                
              Case \cvsSwitch
                ; debugMsg(sProcName, "gnEventGadgetNo=G" + GadgetNoAndName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", gnWindowEvent=" + decodeEvent(gnWindowEvent))
                nPropsIndex = getGadgetPropsIndex(gnEventGadgetNo)
                If (gaGadgetProps(nPropsIndex)\bEnabled) And (gaGadgetProps(nPropsIndex)\bVisible)
                  Select gnEventType
                    Case #PB_EventType_MouseEnter
                      gaGadgetProps(nPropsIndex)\bMouseOver = #True
                      PNL_drawSwitch(h)
                    Case #PB_EventType_MouseLeave
                      gaGadgetProps(nPropsIndex)\bMouseOver = #False
                      PNL_drawSwitch(h)
                    Case #PB_EventType_LeftClick
                      PNL_cvsSwitch_Click(h)
                  EndSelect
                EndIf
                
              Case \imgType
                If gnEventType = #PB_EventType_LeftClick
                  PNL_imgType_LeftClick(h)
                EndIf
                
              Case \txtMoveToTime
                Select gnEventType
                  Case #PB_EventType_Focus
                    ; On gaining focus, we need to remove keyboard shortcuts because in the main window SCS will have set up shortcuts for number keys (0, 1, etc),
                    ; so if we don't remove these shortcuts then number keys will not appear in \txtMoveToTime.
                    ; However, retain all 'Ctrl' keyboard shortcuts primarily so that a second call of Ctrl+M will be recognized for cancelling 'move to time'.
                    WMN_removeKeyboardShortcuts(#WMN, #True, #cTraceKeyboardShortcuts)
                    
                  Case #PB_EventType_LostFocus
                    ETVAL(M2T_txtMoveToTime_Validate(h))
                    debugMsg(sProcName, "gbLastVALResult=" + strB(gbLastVALResult))
                    If gbLastVALResult
                      ; Validation was successful, so as have now lost focus on \txtMoveToTime we now need to reinstate the keyboard shortcuts
                      WMN_setKeyboardShortcuts(#WMN, #cTraceKeyboardShortcuts)
                    EndIf
                EndSelect
                
              CompilerIf #c_cuepanel_multi_dev_select
              Case \cvsDevice[0]
                If gnEventType = #PB_EventType_LeftClick
                  If grLicInfo\bDevLinkAvailable
                    ; debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventGadgetArrayIndex=" + gnEventGadgetArrayIndex)
                    PNL_cvsDevice_leftClick(h, gnEventGadgetArrayIndex)
                  EndIf
                EndIf
              CompilerEndIf
            EndSelect
        EndSelect
      EndWith
      
    EndIf
    
  EndIf ; EndIf PNL_GetVisible(h)
  
EndProcedure

Procedure PNL_adjustSelectedDevicesLevels(h, nDevNo, fBVLevel.f)
  PROCNAMECP(h)
  
  ; NOTE: See also WQF_adjustSelectedDevicesLevels()
  ; NOTE: ------------------------------------------
  
  Protected fCurrBVLevel.f, fCurrDBLevel.f, fDBLevel.f, fDBChange.f, d, d2
  Protected fDevBVLevel.f, fDevDBLevel.f, fTrimFactor.f
  Protected nAudPtr
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", h=" + h + ", nDevNo=" + nDevNo + ", fBVLevel=" + traceLevel(fBVLevel))
  
  nAudPtr = gaDispPanel(h)\nDPAudPtr
;   With aAud(nAudPtr)
;     For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
;       If \sLogicalDev[d]
;         debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\sLogicalDev[" + d + "]=" + \sLogicalDev[d] + ", \fBVLevel[" + d + "]=" + traceLevel(\fBVLevel[d]) + ", \fSavedBVLevel[" + d + "]=" + traceLevel(\fSavedBVLevel[d]) +
;                             ", \fAudPlayBVLevel[" + d + "]=" + traceLevel(\fAudPlayBVLevel[d]) + ", \fCueTotalVolNow[" + d +"]=" + traceLevel(\fCueTotalVolNow[d]) + ", \fDeviceTotalVolWork[" + d + "]=" + traceLevel(\fDeviceTotalVolWork[d]))
;       EndIf
;     Next d
;   EndWith

  With gaPnlVars(h)
    fCurrBVLevel = aAud(nAudPtr)\fDeviceTotalVolWork[nDevNo]
    fCurrDBLevel = convertBVLevelToDBLevel(fCurrBVLevel)
    If fBVLevel > grLevels\fMinBVLevel
      fDBLevel = convertBVLevelToDBLevel(fBVLevel)
    Else
      fDBLevel = grLevels\nMinDBLevel
    EndIf
    fDBChange = fDBLevel - fCurrDBLevel
    
 debugMsgC(sProcName, ">>>> gnSliderEvent=" + gnSliderEvent + ", nDevNo=" + nDevNo + ", fDBLevel=" + StrF(fDBLevel,2) + ", fCurrDBLevel=" + StrF(fCurrDBLevel,2) + ", fDBChange=" + StrF(fDBChange,2))
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      If aAud(nAudPtr)\bDeviceSelected[d]
        If aAud(nAudPtr)\sLogicalDev[d] 
          ; should be #True
          ; NOTE: The purpose of fDeviceTotalVolWork[d] is to enable level increases to be capped at the maximum (eg 0.0dB) whilst increases continue for other devices
          ; NOTE: that are currently set at lower levels, but then to retain the original gap when the level of the devices is lowered.
          fCurrBVLevel = aAud(nAudPtr)\fDeviceTotalVolWork[d]
          fCurrDBLevel = convertBVLevelToDBLevel(fCurrBVLevel)
 debugMsgC(sProcName, "fCurrBVLevel=" + traceLevel(fCurrBVLevel) + ", fCurrDBLevel=" + StrF(fCurrDBLevel,2))
          fDevDBLevel = fCurrDBLevel + fDBChange
          fDevBVLevel = convertDBLevelToBVLevel(fDevDBLevel)
          aAud(nAudPtr)\fDeviceTotalVolWork[d] = fDevBVLevel
 debugMsgC(sProcName, "::::::: aAud(" + getAudLabel(nAudPtr) + ")\fDeviceTotalVolWork[" + d + "]=" + traceLevel(aAud(nAudPtr)\fDeviceTotalVolWork[d]) + ", fDevBVLevel=" + traceLevel(fDevBVLevel))
          If fDevBVLevel > grLevels\fMaxBVLevel
 debugMsgC(sProcName, "------- nDevNo=" + nDevNo + ", fDevBVLevel greater than grLevels\fMaxBVLevel, aAud(" + getAudLabel(nAudPtr) + ")\fDeviceTotalVolWork[" + d + "]=" + traceLevel(aAud(nAudPtr)\fDeviceTotalVolWork[d]) +
                     ", \fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(nAudPtr)\fCueTotalVolNow[d]))
            fDevBVLevel = grLevels\fMaxBVLevel
          ElseIf fDevDBLevel <= grLevels\nMinDBLevel
            fDevBVLevel = grLevels\fSilentBVLevel ; BASS Volume 'silent'
          EndIf
 debugMsgC(sProcName, "d=" + d + ", fDevDBLevel=" + StrF(fDevDBLevel,2) + ", fCurrDBLevel=" + StrF(fCurrDBLevel,2) + ", grLevels\fMinBVLevel=" + traceLevel(grLevels\fMinBVLevel))
          If d = nDevNo
 debugMsgC(sProcName, "calling PNL_sldCueVol_Common(h=" + h + ", d=" + d + ", fDevBVLevel=" + traceLevel(fDevBVLevel))
            PNL_sldCueVol_Common(h, d, fDevBVLevel)
            
          ElseIf d < grCuePanels\nMaxDevLines
            ; NOTE: Level slider in LHS, using sldCueVol
            SLD_setLevel(gaPnlVars(h)\sldCueVol[d], fDevBVLevel, fTrimFactor)
            ; SLD_setBaseLevel(gaPnlVars(h)\sldCueVol[d], fBaseLevel, fTrimFactor)
            SLD_drawSlider(gaPnlVars(h)\sldCueVol[d])
 debugMsgC(sProcName, "calling PNL_sldCueVol_Common(h=" + h + ", d=" + d + ", fDevBVLevel=" + traceLevel(fDevBVLevel))
            PNL_sldCueVol_Common(h, d, fDevBVLevel)
            
          ElseIf d < grCuePanels\nTwiceDevLines
            ; NOTE: Level slider in RHS, using sldCuePan
            d2 = d - grCuePanels\nMaxDevLines
            SLD_setLevel(gaPnlVars(h)\sldCuePan[d2], fDevBVLevel, fTrimFactor)
            ; SLD_setBaseLevel(gaPnlVars(h)\sldCuePan[d2], fBaseLevel, fTrimFactor)
            SLD_drawSlider(gaPnlVars(h)\sldCuePan[d2])
 debugMsgC(sProcName, "calling PNL_sldCueVol_Common(h=" + h + ", d=" + d + ", fDevBVLevel=" + traceLevel(fDevBVLevel))
            PNL_sldCueVol_Common(h, d, fDevBVLevel)
          
          Else ; d >= grCuePanels\nTwiceDevLines
            ; NOTE: OK to call PNL_sldCueVol_Common() even though there's no sldCueVol displayed for this device number, as PNL_sldCueVol_Common() just applies the level change via BASS, etc.
 debugMsgC(sProcName, "calling PNL_sldCueVol_Common(h=" + h + ", d=" + d + ", fDevBVLevel=" + traceLevel(fDevBVLevel))
            PNL_sldCueVol_Common(h, d, fDevBVLevel)
            
          EndIf
        EndIf
      EndIf
    Next d
  EndWith
  
; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_SliderEventHandler(h)
  PROCNAMECP(h)
  Protected nSliderCntGadgetNo
  Protected nDevNo, nValue, fBVLevel.f
  Protected nSliderHandle
  Protected nAudPtr, n
  
  ; debugMsg(sProcName, #SCS_START + ", h=" + h + ", gnEventSliderNo=G" + gnEventSliderNo + ", gnEventGadgetArrayIndex=" + gnEventGadgetArrayIndex + ", gnSliderEvent=" + SLD_decodeEvent(gnSliderEvent))
  
  nSliderCntGadgetNo = SLD_getContainerNo(gnEventSliderNo)
  
  ; debugMsg(sProcName, "GadgetX(G" + nSliderCntGadgetNo + ")=" + GadgetX(nSliderCntGadgetNo) + ", GadgetWidth(G" + nSliderCntGadgetNo + ")=" + GadgetWidth(nSliderCntGadgetNo))
  ; debugMsg(sProcName, "GadgetY(G" + nSliderCntGadgetNo + ")=" + GadgetY(nSliderCntGadgetNo) + ", GadgetHeight(G" + nSliderCntGadgetNo + ")=" + GadgetHeight(nSliderCntGadgetNo))
  
  With gaPnlVars(h)
    
    ; debugMsg(sProcName, "gnEventSliderNo=G" + gnEventSliderNo + ", \sldCueVol[0]=G" + \sldCueVol[0] + ", \sldCuePan[0]=G" + \sldCuePan[0])
    
    Select gnEventSliderNo
        
      Case \sldPnlProgress
        ; debugMsg(sProcName, "\sldPnlProgress, gnSliderEvent=" + SLD_decodeEvent(gnSliderEvent))
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            PNL_sldPnlProgress_Common(h, gnSliderEvent)
          Default
            ; ignore other slider events
        EndSelect
        
      Case \sldCueVol[0], \sldCueVol[1], \sldCueVol[2], \sldCueVol[3]
        ; debugMsg(sProcName, "\sldCueVol[n], gnSliderEvent=" + SLD_decodeEvent(gnSliderEvent))
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            nDevNo = gnEventGadgetArrayIndex
            fBVLevel = SLD_getLevel(gaPnlVars(h)\sldCueVol[nDevNo])
            ; Added 26Apr2024 11.10.2cf
            If fBVLevel < grLevels\fMinBVLevel
              fBVLevel = grLevels\fMinBVLevel
            EndIf
            ; End added 26Apr2024 11.10.2cf
            nAudPtr = gaDispPanel(h)\nDPAudPtr
            If nAudPtr >= 0
              ; Should be #True
; debugMsg(sProcName, "fBVLevel=" + traceLevel(fBVLevel) + ", aAud(" + getAudLabel(nAudPtr) + ")\fBVLevel[nDevNo]=" + traceLevel(aAud(nAudPtr)\fBVLevel[nDevNo]) +
;                     ", \bDeviceSelected[" + nDevNo + "]=" + strB(aAud(nAudPtr)\bDeviceSelected[nDevNo]))
              If grLicInfo\bDevLinkAvailable And fBVLevel <> aAud(nAudPtr)\fBVLevel[nDevNo] And aAud(nAudPtr)\bDeviceSelected[nDevNo] = #False
                PNL_sldCueVol_Common(h, nDevNo, fBVLevel)
                aAud(nAudPtr)\fDeviceTotalVolWork[nDevNo] = aAud(nAudPtr)\fCueTotalVolNow[nDevNo]
; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\fDeviceTotalVolWork[" + nDevNo + "]=" + traceLevel(aAud(nAudPtr)\fDeviceTotalVolWork[nDevNo]))
              ElseIf grLicInfo\bDevLinkAvailable And aAud(nAudPtr)\bDeviceSelected[nDevNo]
                PNL_adjustSelectedDevicesLevels(h, nDevNo, fBVLevel)
              Else
                PNL_sldCueVol_Common(h, nDevNo, fBVLevel)
              EndIf
            Else
              ; Shouldn't get here
              PNL_sldCueVol_Common(h, nDevNo, fBVLevel)
            EndIf
          Default
            ; ignore other slider events
        EndSelect
        
      Case \sldCuePan[0], \sldCuePan[1], \sldCuePan[2], \sldCuePan[3]
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            nSliderHandle = gaPnlVars(h)\sldCuePan[gnEventGadgetArrayIndex]
            If SLD_getSliderType(nSliderHandle) = #SCS_ST_PAN
              nDevNo = gnEventGadgetArrayIndex
              nValue = SLD_getValue(gaPnlVars(h)\sldCuePan[gnEventGadgetArrayIndex])
              PNL_sldCuePan_Common(h, nDevNo, nValue)
            Else
              nDevNo = gnEventGadgetArrayIndex + grCuePanels\nMaxDevLines
              fBVLevel = SLD_getLevel(gaPnlVars(h)\sldCuePan[gnEventGadgetArrayIndex])
              ; Added 26Apr2024 11.10.2cf
              If fBVLevel < grLevels\fMinBVLevel
                fBVLevel = grLevels\fMinBVLevel
              EndIf
              ; End added 26Apr2024 11.10.2cf
              nAudPtr = gaDispPanel(h)\nDPAudPtr
              If nAudPtr >= 0
                ; Should be #True
                If grLicInfo\bDevLinkAvailable And fBVLevel <> aAud(nAudPtr)\fBVLevel[nDevNo] And aAud(nAudPtr)\bDeviceSelected[nDevNo] = #False
                  PNL_sldCueVol_Common(h, nDevNo, fBVLevel)
                  aAud(nAudPtr)\fDeviceTotalVolWork[nDevNo] = aAud(nAudPtr)\fCueTotalVolNow[nDevNo]
                ElseIf grLicInfo\bDevLinkAvailable And aAud(nAudPtr)\bDeviceSelected[nDevNo]
                  PNL_adjustSelectedDevicesLevels(h, nDevNo, fBVLevel)
                Else
                  PNL_sldCueVol_Common(h, nDevNo, fBVLevel)
                EndIf
              Else
                ; Shouldn't get here
                PNL_sldCueVol_Common(h, nDevNo, fBVLevel)
              EndIf
            EndIf
          Default
            ; ignore other slider events
        EndSelect
        
      Case \sldMoveToTimePosition
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            M2T_sldMoveToTimePosition_Common(h, gnSliderEvent)
          Default
            ; ignore other slider events
        EndSelect
        
      Default
        ; debugMsg(sProcName, "unhandled gadget")
        
    EndSelect
  EndWith
  
EndProcedure

Procedure PNL_drawOtherInfoText(h)
  ; PROCNAMECP(h)
  Protected nTextColor, nBackColor
  
  With gaPnlVars(h)
    ; debugMsg(sProcName, "\m_nSubPtr=" + getSubLabel(\m_nSubPtr) + ", \sOtherInfoText=" + \sOtherInfoText)
    If \bActiveOrComplete
      ; debugMsg(sProcName, "color ActiveOrComplete")
      nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
      nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
    Else
      ; debugMsg(sProcName, "color Inactive")
      nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
      nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
    EndIf
    If StartDrawing(CanvasOutput(\cvsPnlOtherInfo))
      Box(0, 0, OutputWidth(), OutputHeight(), nBackColor)
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_CUE_NORMAL)
      If \sOtherInfoText
        DrawText(0, 0, \sOtherInfoText, nTextColor)
      EndIf
      StopDrawing()
    EndIf
    ; debugMsg(sProcName, "\sOtherInfoText=" + \sOtherInfoText)
  EndWith
  
EndProcedure

Procedure PNL_setOtherInfoText(h, sText.s, bErrorState=#False)
  PROCNAMECP(h)
  Protected nWidth, nTextWidth
  Protected nCntHeight
  Protected sMyText.s
  
  ; debugMsg(sProcName, #SCS_START + ", bErrorState=" + strB(bErrorState) + ", sText=" + sText)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  With gaPnlVars(h)
    nWidth = GadgetX(\cntFaderAndPanCtls) - GadgetX(\cvsPnlOtherInfo)
    nCntHeight = \nCntFaderAndPanCtlsStdHeight
    If bErrorState
      sMyText = " " + sText + " "
      nTextWidth = GetTextWidth(sMyText, #SCS_FONT_CUE_NORMAL)
      ; debugMsg(sProcName, "nTextWidth=" + nTextWidth + ", nWidth=" + nWidth)
      If nTextWidth > nWidth
        nWidth = nTextWidth
        nCntHeight = GadgetY(\cvsPnlOtherInfo) - GadgetY(\cntFaderAndPanCtls)
      EndIf
    Else
      sMyText = sText
    EndIf
    If GadgetHeight(\cntFaderAndPanCtls) <> nCntHeight
      ResizeGadget(\cntFaderAndPanCtls, #PB_Ignore, #PB_Ignore, #PB_Ignore, nCntHeight)
      ; debugMsg(sProcName, "ResizeGadget(\cntFaderAndPanCtls, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + Str(nCntHeight) + ")")
    EndIf
    If GadgetWidth(\cvsPnlOtherInfo) <> nWidth
      ResizeGadget(\cvsPnlOtherInfo, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
      ; debugMsg(sProcName, "ResizeGadget(\cvsPnlOtherInfo, #PB_Ignore, #PB_Ignore, " + nWidth + ", #PB_Ignore)")
    EndIf
    ; If sMyText <> \sOtherInfoText ; removed test 4May2019 11.8.1aj as we always need to draw the 'other info' canvas
      ; debugMsg(sProcName, "\sOtherInfoText=" + #DQUOTE$ + \sOtherInfoText + #DQUOTE$ + ", sMyText=" + #DQUOTE$ + sMyText + #DQUOTE$)
      \sOtherInfoText = sMyText
      PNL_drawOtherInfoText(h)
      ; call PNL_setReleaseBtnState(h) because a new loop may now be current
      PNL_setReleaseBtnState(h)
    ; EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_initCuePanels(nMaxDevLines=4)
  PROCNAMEC()
  Protected nMyMaxDevLines
  
  nMyMaxDevLines = nMaxDevLines
  If nMyMaxDevLines < 4
    nMyMaxDevLines = 4
  EndIf
  With grCuePanels
    If \nMaxDevLines <> nMyMaxDevLines
      \nMaxDevLines = nMyMaxDevLines
      \nMaxDevLineNo = \nMaxDevLines - 1
      \nTwiceDevLines = \nMaxDevLines << 1
      \bCreatePanelsReqd = #True
    EndIf
  EndWith
EndProcedure

Procedure PNL_clearAllDispPanelInfo()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To ArraySize(gaDispPanel())
    gaDispPanel(n) = grDispPanelDef
  Next n
  ; nb do NOT clear array gaPnlVars() as that contains gadget numbers
  gnMaxDispPanel = -1
  debugMsg(sProcName, "gnMaxDispPanel=" + gnMaxDispPanel)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_setDisplayOrder()
  ; Changed 5Oct2022 11.9.6
  PROCNAMEC()
  ; function returns pointer to gaDisplayablePanels for first item to be displayed
  Protected n, p
  Protected nMyCuePtr, nMyCueState
  Protected nFirstItemPtr
  Protected bTrace = #False

  debugMsgC(sProcName, #SCS_START)
  If bTrace
    debugMsg(sProcName, "calling listCueStates()")
    listCueStates()
  EndIf
  
  nFirstItemPtr = -1
  
  For n = 0 To ArraySize(gaDisplayable())
    gaDisplayable(n)\nDispPanelPtr = -1
  Next n
  
  ; In the following loops, note that because nSubState is saved in the gaDisplayable array, for playlist panels both panels will record the same nSubState, so both will be included in the "running cues" or both will be excluded
  
  ; Select running cues first, selected in cue order
  p = -1
  For n = 0 To gnMaxDisplayablePanel
    With gaDisplayable(n)
      If \bDisplayThisPanel
        debugMsgC(sProcName, "p=" + p + ", gaDisplayable(" + n + ")\nDASubPtr=" + getSubLabel(\nDASubPtr) + ", \nSubState=" + decodeCueState(\nSubState))
        ; Changed 7Oct2022 11.9.6 so that all the sub-cue displays for a cue are kept together
        ; Note that any completed sub-cues will not be in the array gaDisplayable(), which is populated by PNL_loadDispPanels()
        nMyCuePtr = \nDACuePtr
        nMyCueState = aCue(nMyCuePtr)\nCueState
        Select nMyCueState
          Case #SCS_CUE_FADING_IN To #SCS_CUE_FADING_OUT, #SCS_CUE_COUNTDOWN_TO_START, #SCS_CUE_SUB_COUNTDOWN_TO_START, #SCS_CUE_PL_COUNTDOWN_TO_START
            p + 1
            \nDispPanelPtr = p
            If nFirstItemPtr = -1
              nFirstItemPtr = n
            EndIf
        EndSelect
      EndIf
    EndWith
  Next n
  
  ; now select other cues
  debugMsgC(sProcName, "now select other cues")
  For n = 0 To gnMaxDisplayablePanel
    With gaDisplayable(n)
      If \nDispPanelPtr = -1 ; only check items not yet counted
        If \bDisplayThisPanel
          p + 1
          \nDispPanelPtr = p
          If nFirstItemPtr = -1
            nFirstItemPtr = n
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  If p < gnMaxCuePanelAvailable
    gnMaxDispPanel = p
  Else
    gnMaxDispPanel = gnMaxCuePanelAvailable
  EndIf
  
  debugMsgC(sProcName, #SCS_END + ", p=" + p + ", gnMaxDispPanel=" + gnMaxDispPanel + ", returning nFirstItemPtr=" + nFirstItemPtr)
  ProcedureReturn nFirstItemPtr

EndProcedure

Procedure PNL_setPnlColorsForNextManualCue()
  PROCNAMEC()
  Protected h
  
  If (gnCueToGo > 0) And (gnCueToGo < gnCueEnd)
    For h = 0 To ArraySize(gaPnlVars())
      If gaPnlVars(h)\m_nCuePtr = gnCueToGo
        gaPnlVars(h)\bNextManualCue = #True
        ; debugMsg(sProcName, "gaPnlVars(" + h + ")\bNextManualCue=" + strB(gaPnlVars(h)\bNextManualCue))
        PNL_colorCueAndDescription(h, gaPnlVars(h)\m_nSubPtr)
      EndIf
    Next h
  EndIf
  
EndProcedure

Procedure PNL_createSwitchMenu(h, bInLoadOneDispPanel=#False)
  PROCNAMEC()
  Protected hSwitch, nSubPtr, nTransportSwitchCode
  
  hSwitch = gaPnlVars(h)\cvsSwitch
  nSubPtr = gaPnlVars(h)\m_nSubPtr
  nTransportSwitchCode = gaDispPanel(h)\nTransportSwitchCode
  If nSubPtr >= 0
    If IsMenu(#PNL_mnu_switch_popup)
      FreeMenu(#PNL_mnu_switch_popup)
    EndIf
    If aSub(nSubPtr)\bSubTypeAorP
      If scsCreatePopupMenu(#PNL_mnu_switch_popup)
        scsMenuItemFast(#PNL_mnu_switch_file, grtext\sTextFile)
        If (aSub(nSubPtr)\nPrevSubIndex >= 0) Or (aSub(nSubPtr)\nNextSubIndex >= 0)
          scsMenuItemFast(#PNL_mnu_switch_sub, grText\sTextSub)
        EndIf
        scsMenuItemFast(#PNL_mnu_switch_cue, grText\sTextCue)
      EndIf
      ; SetGadgetState(hSwitch, gaDispPanel(h)\nTransportSwitchIndex)
      If bInLoadOneDispPanel
        setEnabled(hSwitch, #True)
        setVisible(hSwitch, #True)
      EndIf
      
    ElseIf (aSub(nSubPtr)\nPrevSubIndex >= 0) Or (aSub(nSubPtr)\nNextSubIndex >= 0)
      ; cue has more than one sub-cue
      If scsCreatePopupMenu(#PNL_mnu_switch_popup)
        scsMenuItemFast(#PNL_mnu_switch_sub, grText\sTextSub)
        scsMenuItemFast(#PNL_mnu_switch_cue, grText\sTextCue)
      EndIf
      ; SetGadgetState(hSwitch, gaDispPanel(h)\nTransportSwitchIndex)
      If bInLoadOneDispPanel
        setEnabled(hSwitch, #True)
        setVisible(hSwitch, #True)
      EndIf
      
    Else
      ; cue has only one sub-cue, and this is not a playlist
      ; ClearGadgetItems(hSwitch)
      If bInLoadOneDispPanel
        setEnabled(hSwitch, #False)
        setVisible(hSwitch, #False)
      EndIf
    EndIf
    
    If IsMenu(#PNL_mnu_switch_popup)
      Select gaDispPanel(h)\nTransportSwitchCode
        Case #SCS_TRANSPORT_SWITCH_CUE
          SetMenuItemState(#PNL_mnu_switch_popup, #PNL_mnu_switch_cue, 1)
        Case #SCS_TRANSPORT_SWITCH_SUB
          SetMenuItemState(#PNL_mnu_switch_popup, #PNL_mnu_switch_sub, 1)
        Case #SCS_TRANSPORT_SWITCH_FILE
          SetMenuItemState(#PNL_mnu_switch_popup, #PNL_mnu_switch_file, 1)
      EndSelect
    EndIf
    
  Else ; nSubPtr < 0
    If bInLoadOneDispPanel
      setEnabled(hSwitch, #False)
      setVisible(hSwitch, #False)
    EndIf
  EndIf
  
  grMain\nSwitchMenuHostPanel = h ; used by menu event processing
  
EndProcedure

Procedure PNL_drawSwitch(h)
  PROCNAMEC()
  Protected nPropsIndex
  Protected nLeft, nTop
  
  With gaPnlVars(h)
    If StartDrawing(CanvasOutput(\cvsSwitch))
      ; background gradient must be same as adjacent transport control buttons
      ; see IMG_mac_drawTrBtnBackground() and IMG_drawTrBtnImages13() in Images.pbi
      DrawingMode(#PB_2DDrawing_Gradient)
      nPropsIndex = getGadgetPropsIndex(\cvsSwitch)
      If (gaGadgetProps(nPropsIndex)\bEnabled) And (gaGadgetProps(nPropsIndex)\bMouseOver)
        BackColor(RGB(223,251,255))
        FrontColor(RGB(199,246,255))
      Else
        BackColor(RGB(246,246,246))
        FrontColor(RGB(205,205,205))
      EndIf
      LinearGradient(0, 0, 0, OutputHeight())    
      Box(0,0,OutputWidth(),OutputHeight())
      ; end of background gradient drawing
      FrontColor(#SCS_Dark_Grey)
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_CUE_NORMAL)
      DrawText(0,0," " + decodeLTransportSwitch(gaDispPanel(h)\nTransportSwitchCode)) ; space at start for padding
      nLeft = OutputWidth() - 12
      nTop = (OutputHeight() >> 1) - 3
      LineXY(nLeft, nTop, nLeft+8, nTop)
      LineXY(nLeft+1, nTop+1, nLeft+7, nTop+1)
      LineXY(nLeft+2, nTop+2, nLeft+6, nTop+2)
      LineXY(nLeft+3, nTop+3, nLeft+5, nTop+3)
      Plot(nLeft+4, nTop+4)
      StopDrawing()
    EndIf
  EndWith
EndProcedure

Procedure PNL_drawTextButton(nCanvasGadget, sButtonText.s)
  PROCNAMEC()
  Protected nPropsIndex
  Protected nTextWidth, nTextHeight, nLeft, nTop
  
  If StartDrawing(CanvasOutput(nCanvasGadget))
    ; background gradient must be same as transport control buttons
    ; see IMG_mac_drawTrBtnBackground() and IMG_drawTrBtnImages13() in Images.pbi
    DrawingMode(#PB_2DDrawing_Gradient)
    nPropsIndex = getGadgetPropsIndex(nCanvasGadget)
    If nPropsIndex >= 0
      If (gaGadgetProps(nPropsIndex)\bEnabled) And (gaGadgetProps(nPropsIndex)\bMouseOver)
        BackColor(RGB(223,251,255))
        FrontColor(RGB(199,246,255))
      Else
        BackColor(RGB(246,246,246))
        FrontColor(RGB(205,205,205))
      EndIf
      LinearGradient(0, 0, 0, OutputHeight())    
      Box(0, 0, OutputWidth(), OutputHeight())
      ; end of background gradient drawing
      DrawingMode(#PB_2DDrawing_Outlined)
      RoundBox(0, 0, OutputWidth(), OutputHeight(), 4, 4, #SCS_Dark_Grey)
      FrontColor(#SCS_Dark_Grey)
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_CUE_NORMAL)
      nTextWidth = TextWidth(sButtonText)
      If nTextWidth < OutputWidth()
        nLeft = (OutputWidth() - nTextWidth) >> 1
      EndIf
      nTextHeight = TextHeight("gG") ; ensure same text height for all text buttons
      If nTextHeight < OutputHeight()
        nTop = (OutputHeight() - nTextHeight) >> 1
      EndIf
      DrawText(nLeft, nTop, sButtonText)
      StopDrawing()
    EndIf
  EndIf

EndProcedure

Procedure PNL_drawLinked(h, sText.s)
  PROCNAMEC()
  Protected nPropsIndex
  Protected nLeft
  Protected nTextWidth
  
  With gaPnlVars(h)
    If StartDrawing(CanvasOutput(\cvsLinked))
      ; background gradient must be same as adjacent transport control buttons
      ; see IMG_mac_drawTrBtnBackground() and IMG_drawTrBtnImages13() in Images.pbi
      DrawingMode(#PB_2DDrawing_Gradient)
      nPropsIndex = getGadgetPropsIndex(\cvsLinked)
      If (gaGadgetProps(nPropsIndex)\bEnabled) And (gaGadgetProps(nPropsIndex)\bMouseOver)
        BackColor(RGB(223,251,255))
        FrontColor(RGB(199,246,255))
      Else
        BackColor(RGB(246,246,246))
        FrontColor(RGB(205,205,205))
      EndIf
      LinearGradient(0, 0, 0, OutputHeight())    
      Box(0,0,OutputWidth(),OutputHeight())
      ; end of background gradient drawing
      FrontColor(#SCS_Dark_Grey)
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_CUE_NORMAL)
      nTextWidth = TextWidth(sText)
      If nTextWidth < OutputWidth()
        nLeft = (OutputWidth() - nTextWidth) >> 1
      EndIf
      DrawText(nLeft,0,sText)
      ; debugMsg(sProcName, "DrawText(" + nLeft + ",0," + #DQUOTE$ + sText + #DQUOTE$ + ")")
      ; debugMsg(sProcName, "getVisible(\cvsLinked)=" + getVisible(\cvsLinked) + ", GadgetX(\cvsLinked)=" + GadgetX(\cvsLinked) + ", GadgetY(\cvsLinked)=" + GadgetY(\cvsLinked))
      StopDrawing()
    EndIf
  EndWith
EndProcedure

Procedure PNL_processOSCPanlBtnClick(sBtn.s, sCue.s, nSubNo, nAudNo)
  PROCNAMEC()
  Protected n, h
  Protected i, j, k
  Protected nCuePtr = -1, nSubPtr = -1, nAudPtr = -1
  
  debugMsg(sProcName, #SCS_START + ", sBtn=" + sBtn + ", sCue=" + sCue + ", nSubNo=" + nSubNo + ", nAudNo=" + nAudNo)
  
  For i = 1 To gnLastCue
    If aCue(i)\sCue = sCue
      nCuePtr = i
      If nSubNo >= 0
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\nSubNo = nSubNo
            nSubPtr = j
            If (nAudNo >= 0) And (aSub(j)\bSubTypeHasAuds)
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                If aAud(k)\nAudNo = nAudNo
                  nAudPtr = k
                  Break 3
                EndIf
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
            Break 2
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      Break
    EndIf
  Next i
  
  h = -1
  For n = 0 To ArraySize(gaDispPanel())
    With gaDispPanel(n)
      If \nDPCuePtr = nCuePtr
        If (\nDPSubPtr = nSubPtr) Or (nSubPtr = -1)
          If (\nDPAudPtr = nAudPtr) Or (nAudPtr = -1)
            h = n
            Break
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  debugMsg(sProcName, "h=" + h)
  
  If h >= 0
    Select sBtn
      Case "fadeout"
        PNL_btnFadeOut_Click(h)
      Case "first"
        PNL_btnFirst_Click(h)
      Case "pause"
        PNL_btnPause_Click(h)
      Case "play"
        PNL_btnPlay_Click(h)
      Case "release"
        PNL_btnRelease_Click(h)
      Case "rewind"
        PNL_btnRewind_Click(h)
      Case "shuffle"
        PNL_btnShuffle_Click(h)
      Case "stop"
        PNL_btnStop_Click(h)
    EndSelect
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_loadDispPanels()
  PROCNAMEC()
  Protected i, j, k, k2, n, p, p2
  Protected nPLCounter, nPLCountMax
  Protected bThisCueDisplayed
  Protected bThisCuePlaying
  Protected nThisCuePtr
  Protected nDisplayableMax
  Protected nScrollBarMax, nMyScrollBarValue
  Protected nFirstItemPtr
  Protected nScrollPanelPos
  Protected nCuePtr, nSubNo, nPlayNo
  Protected nInnerHeight
  Protected nScrollYPos
  Protected qTimeThisCueStarted.q, bTimeThisCueStartedSet
  Protected bCallLoadOneCuePanel
  Protected bLockReqd, bLockedMutex
  Protected bDisplayThisPanel
  Protected nActiveWindow
  Protected nSubrCuePtr, bSubrCuePlaying
  Protected qTimeStarted.q, qTimeNow.q ;, bWaitDisplayed
  Protected nWaitMessageTime = 0 ; 500 ; 2000
  Static sWaitMessage.s
  Static bStaticLoaded
  Static Dim aCurrDispPanelKeyInfo.tyDispPanelKeyInfo(0)  ; static to minimise frequency of ReDim commands
  Protected nCurrMaxDispPanel
  Protected bDispPanelChangeFound
  Protected nThisCueState, nThisSubState ; Added 6Oct2022
  Protected rOperModeOptions.tyOperModeOptions ; Added 6Oct2022
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sWaitMessage = LangEllipsis("WMI", "LoadingPanels")
    bStaticLoaded = #True
  EndIf
  
  gbCallLoadDispPanels = #False
  ; debugMsg(sProcName, "gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
  
  If gbInitialising
    ProcedureReturn
  EndIf
  gbInLoadDispPanels = #True
  
  PNL_calcMaxCuePanelAvailable()
  
  ; MUST be called from the main thread or the procedure can lock up on
  ;    SetGadgetAttribute(WMN\scaCuePanels, #PB_ScrollArea_InnerHeight, nInnerHeight)
  ; ASSERT_THREAD(#SCS_THREAD_MAIN)
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_LOAD_CUE_PANELS)
    gbInLoadDispPanels = #False ; added 9Nov2015 11.4.1.2h
    ProcedureReturn
  EndIf
  
  qTimeStarted = ElapsedMilliseconds()
  
  TryLockCueListMutex(813)
  If (bLockReqd) And (bLockedMutex = #False)
    ; can't lock gnCueListMutex so throw request back to SAM
    debugMsg(sProcName, "can't lock gnCueListMutex. gnCueListMutexLockThread=" + gnCueListMutexLockThread + ", gnThreadNo=" + gnThreadNo +
                        ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime) + ", gnCueListMutexLockNo=" + gnCueListMutexLockNo +
                        ", gnLabel=" + gnLabel + ", gnLabelSAM=" + gnLabelSAM +
                        ", gnLabelUpdDispPanel=" + gnLabelUpdDispPanel + ", gnLabelReposAuds=" + gnLabelReposAuds + ", gnLabelOther=" + gnLabelOther)
    samAddRequest(#SCS_SAM_LOAD_CUE_PANELS,0,0,0,"",ElapsedMilliseconds()+100)
    gbInLoadDispPanels = #False
    ProcedureReturn
  EndIf
  
  nActiveWindow = GetActiveWindow()
  ; debugMsg0(sProcName, "GetActiveWindow()=" + decodeWindow(nActiveWindow))
  
  rOperModeOptions = grOperModeOptions(gnOperMode)
  
  nCurrMaxDispPanel = gnMaxDispPanel
  If nCurrMaxDispPanel >= 0
    If ArraySize(aCurrDispPanelKeyInfo()) < nCurrMaxDispPanel
      ReDim aCurrDispPanelKeyInfo(nCurrMaxDispPanel)
    EndIf
    For n = 0 To nCurrMaxDispPanel
      With aCurrDispPanelKeyInfo(n)
        \nDPK_CuePtr = gaDispPanel(n)\nDPCuePtr
        \nDPK_SubPtr = gaDispPanel(n)\nDPSubPtr
        \nDPK_AudPtr = gaDispPanel(n)\nDPAudPtr
        If \nDPK_CuePtr >= 0
          \qDPK_TimeCueLastEdited = aCue(\nDPK_CuePtr)\qTimeCueLastEdited
        EndIf
        If \nDPK_SubPtr >= 0
          \qDPK_TimeSubLastEdited = aSub(\nDPK_SubPtr)\qTimeSubLastEdited
        EndIf
        If \nDPK_AudPtr >= 0
          \qDPK_TimeAudLastEdited = aAud(\nDPK_AudPtr)\qTimeAudLastEdited
        EndIf
        \nDPK_SubState = gaDispPanel(n)\nDPSubState
        \nDPK_LinkedToAudPtr = gaDispPanel(n)\nDPLinkedToAudPtr ; Added 2May2022 11.9.1
        \nDPK_AudLinkCount = gaDispPanel(n)\nDPAudLinkCount     ; Added 2May2022 11.9.1
      EndWith
    Next n
  EndIf
  
  ; debugMsg(sProcName, "gnMaxDispPanel=" + gnMaxDispPanel + ", gnLastCue=" + getCueLabel(gnLastCue) + ", gnLastSub=" + getSubLabel(gnLastSub) + ", gnCueToGo=" + getCueLabel(gnCueToGo))
  ; note: nDisplayableMax doesn't have to be accurate provided it is AT LEAST as high as the maximum possible value
  nDisplayableMax = 1
  For j = 1 To gnLastSub
    nDisplayableMax + 1
    If aSub(j)\bSubTypeAorP
      nDisplayableMax + 1
    EndIf
  Next j
  ; debugMsg(sProcName, "nDisplayableMax=" + nDisplayableMax)
  If ArraySize(gaDisplayable()) < nDisplayableMax
    ReDim gaDisplayable(nDisplayableMax)
  EndIf
  
  For n = 0 To ArraySize(gaDisplayable())
    gaDisplayable(n)\nDispPanelPtr = -1
    gaDisplayable(n)\nScrollBarValue = -1
  Next n
  
  ; Moved and changed 6Oct2022 11.9.6
  If gbCuePanelLoadingMessageDisplayed = #False And gnLastCue > 1
    qTimeNow = ElapsedMilliseconds()
    If (qTimeNow - qTimeStarted) > nWaitMessageTime
      ; debugMsg0(sProcName, "calling WMI_displayInfoMsg1(sWaitMessage, " + gnLastCue + ")")
      WMI_displayInfoMsg1(sWaitMessage, gnLastCue) ; gnLastCue added 14Feb2022 11.9.0
      gbCuePanelLoadingMessageDisplayed = #True
    EndIf
  EndIf
  ; End moved and changed 6Oct2022 11.9.6
  
  n = 0
  nScrollBarMax = -1
  nMyScrollBarValue = -1
  For i = 1 To gnLastCue
    ; debugMsg0(sProcName, "i=" + i + ", " + getCueLabel(i) + ", n=" + n + ", nDisplayableMax=" + nDisplayableMax)
    bThisCueDisplayed = #False
    bThisCuePlaying = #False
    bSubrCuePlaying = #False
    nSubrCuePtr = -1
    nThisCueState = aCue(i)\nCueState ; Added 6Oct2022 11.9.6
    If (aCue(i)\bCueCurrentlyEnabled) And
       (nThisCueState <> #SCS_CUE_IGNORED) And
       ((aCue(i)\nHideCueOpt <> #SCS_HIDE_ENTIRE_CUE) Or (rOperModeOptions\bShowHiddenAutoStartCues)) And
       (aCue(i)\nHideCueOpt <> #SCS_HIDE_CUE_PANEL) And
       (((aCue(i)\bHotkey = #False) And (aCue(i)\bExtAct = #False) And (aCue(i)\bCallableCue = #False)) Or (rOperModeOptions\bShowHotkeyCuesInPanels))
      
      ; Added 13Mar2025 11.10.8ah
      If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
        If nThisCueState <= #SCS_CUE_READY
          ; If TBC and cue is not yet started then do not display it in the cue panels
          Continue
        EndIf
      EndIf
      ; End added 13Mar2025 11.10.8ah
      
      If (nThisCueState >= #SCS_CUE_FADING_IN) And (nThisCueState <= #SCS_CUE_FADING_OUT) And (nThisCueState <> #SCS_CUE_HIBERNATING) ; Added hibernating test 3Oct2022 11.9.6
        bThisCuePlaying = #True
      EndIf
      
      If aCue(i)\nActivationMethod = #SCS_ACMETH_CALL_CUE
        nSubrCuePtr = i
        If (nThisCueState > #SCS_CUE_READY) And (nThisCueState <= #SCS_CUE_FADING_OUT)
          ; the above test modified 31Dec2021 11.9aa following test of Q4 and CC3 in "Call Cue Parameters.scs11" where previously CC3<2> was not displayed in the cue panels even though CC3<2> was counting down and eventually playing
          bSubrCuePlaying = #True
        EndIf
      EndIf
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(aCue(i)\nActivationMethod) + ", \nCueState=" + decodeCueState(nThisCueState)
      
      ; Added 3Oct2022 11.9.6
      If aCue(i)\nCueState = #SCS_CUE_HIBERNATING
        ; If this cue is hibernating then do not display it in the cue panels
        Continue
      EndIf
      ; End added 3Oct2022 11.9.6
      
      qTimeThisCueStarted = aCue(i)\qTimeCueStarted
      bTimeThisCueStartedSet = aCue(i)\bTimeCueStartedSet
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If aSub(j)\bSubEnabled
            If (rOperModeOptions\bShowSubCues) Or (bThisCueDisplayed = #False)
              nThisSubState = \nSubState
              ; debugMsg(sProcName, "aSub(" + \sSubLabel + ")\nSubState=" + decodeCueState(nThisSubState) + ", \bHotkey=" + strB(\bHotkey) + ", \bExtAct=" + strB(\bExtAct) + ", \bCallableCue=" + strB(\bCallableCue))
              CheckSubInRange(n, ArraySize(gaDisplayable()), "gaDisplayable()")
              If ((nThisSubState < #SCS_CUE_COMPLETED) And (nThisSubState <> #SCS_CUE_HIBERNATING) And
                  (((\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)) Or ((nThisSubState >= #SCS_CUE_FADING_IN) And (nThisSubState <= #SCS_CUE_FADING_OUT))))
                bDisplayThisPanel = #True
                ; debugMsg(sProcName, "n=" + n + ", bDisplayThisPanel=" + strB(bDisplayThisPanel))
              ElseIf ((aCue(i)\nCueState > #SCS_CUE_READY) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)) And
                     (\bHotkey Or \bExtAct Or \bCallableCue) And (nThisSubState <= #SCS_CUE_FADING_OUT)
                bDisplayThisPanel = #True
                ; debugMsg(sProcName, "n=" + n + ", bDisplayThisPanel=" + strB(bDisplayThisPanel))
              ElseIf nThisSubState = #SCS_CUE_ERROR
                bDisplayThisPanel = #True
                ; debugMsg(sProcName, "n=" + n + ", bDisplayThisPanel=" + strB(bDisplayThisPanel))
              Else
                bDisplayThisPanel = #False
                ; debugMsg(sProcName, "n=" + n + ", bDisplayThisPanel=" + strB(bDisplayThisPanel))
              EndIf
              
              ; Added 3Oct2022 11.9.6
              If \bSubTypeQ ; 'Call Cue' sub-cue type
                If \nCallCuePtr >= 0
                  If aCue(\nCallCuePtr)\nCueState = #SCS_CUE_HIBERNATING
                    ; For a 'Call Cue' sub-cue, if the called cue is hibernating then do not display the 'Call Cue' in the display panels
                    bDisplayThisPanel = #False
                    ; debugMsg(sProcName, "n=" + n + ", bDisplayThisPanel=" + strB(bDisplayThisPanel))
                  EndIf
                EndIf
              EndIf
              ; End added 3Oct2022 11.9.6
              
              ; Added 6Oct2022 11.9.6
              If \bSubTypeE ; 'Memo' sub-cue type
                If nThisSubState >= #SCS_CUE_FADING_IN
                  ; Following testing of the new demo cue file (provided by Dee) it was decided that any Memo sub-cue currently playing should NOT be shown in the cue panels
                  bDisplayThisPanel = #False
                EndIf
              EndIf
              ; End added 6Oct2022 11.9.6
              
              If bDisplayThisPanel
                If (nSubrCuePtr >= 0) And (bSubrCuePlaying = #False)
                  bDisplayThisPanel = #False
                  ; debugMsg(sProcName, "n=" + n + ", bDisplayThisPanel=" + strB(bDisplayThisPanel) + ", nSubrCuePtr=" + getSubLabel(nSubrCuePtr) + ", aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
                EndIf
              EndIf
              
              If bDisplayThisPanel
                gaDisplayable(n)\bDisplayThisPanel = #True
                If \bSubTypeAorP
                  nPLCounter = 0
                  k = \nCurrPlayIndex
                  If k >= 0
                    k2 = aAud(k)\nPrevPlayIndex
                    If (k2 = -1) And (getPLRepeatActive(j)) And (aSub(j)\bPLSavePos = #False)
                      k2 = aSub(j)\nLastPlayIndex
                    EndIf
                    If k2 >= 0
                      If (aAud(k2)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k2)\nAudState <= #SCS_CUE_FADING_OUT)
                        k = k2
                      EndIf
                    EndIf
                  EndIf
                  ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nCurrPlayIndex=" + getAudLabel(\nCurrPlayIndex) + ", \nAudCount=" + \nAudCount)
                  nPLCountMax = \nAudCount
                  While (k >= 0) And (nPLCounter < 2) And (nPLCountMax > 0)
                    CheckSubInRange(n, ArraySize(gaDisplayable()), "gaDisplayable()")
                    If nPLCounter > 0
                      gaDisplayable(n)\bDisplayThisPanel = gaDisplayable(n-1)\bDisplayThisPanel
                    EndIf
                    nPLCountMax - 1
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
                    nPLCounter + 1
                    gaDisplayable(n)\nDACuePtr = i
                    gaDisplayable(n)\nDASubPtr = j
                    gaDisplayable(n)\nSubNo = aSub(j)\nSubNo
                    gaDisplayable(n)\nDAAudPtr = k
                    gaDisplayable(n)\nPlayNo = aAud(k)\nPlayNo
                    gaDisplayable(n)\nSubState = nThisSubState ; aAud(k)\nAudState ; Changed 6Oct2022 11.9.6 - don't know why this was aAud(k)\nAudState - presumably a mistake
                    gaDisplayable(n)\nAudState = aAud(k)\nAudState
                    gaDisplayable(n)\bHotkey = aSub(j)\bHotkey
                    gaDisplayable(n)\bExtAct = aSub(j)\bExtAct
                    gaDisplayable(n)\bCallableCue = aSub(j)\bCallableCue
                    gaDisplayable(n)\qDATimeStarted = aAud(k)\qTimeAudStarted
                    gaDisplayable(n)\qDATimeCueStarted = qTimeThisCueStarted
                    ; debugMsg(sProcName, "gaDisplayable(" + n + ")\qDATimeCueStarted=" + traceTime(gaDisplayable(n)\qDATimeCueStarted))
                    If (aSub(j)\nPrevSubIndex <> -1) Or (aSub(j)\nNextSubIndex <> -1)
                      ; if either or both are not -1 then there must be more than one sub
                      gaDisplayable(n)\sLabel = aAud(k)\sCue + " <" + aAud(k)\nSubNo + "> (" + aAud(k)\nAudNo + ")"
                    Else
                      gaDisplayable(n)\sLabel = \sCue + " (" + aAud(k)\nAudNo + ")"
                    EndIf
                    If (aSub(j)\bHotkey = #False) And (aSub(j)\bExtAct = #False) And (aSub(j)\bCallableCue = #False)
                      nMyScrollBarValue + 1
                      gaDisplayable(n)\nScrollBarValue = nMyScrollBarValue
                      gaDisplayable(n)\nGadgetY = nMyScrollBarValue * grCuePanels\nCuePanelHeightStdPlusGap
                      nScrollBarMax = nScrollBarMax + 1
                    EndIf
;                     debugMsg(sProcName, "gaDisplayable(" + n + ")\nDACuePtr=" + getCueLabel(gaDisplayable(n)\nDACuePtr) + ", \nDASubPtr=" + getSubLabel(gaDisplayable(n)\nDASubPtr) +
;                                         ", \nDAAudPtr=" + getAudLabel(gaDisplayable(n)\nDAAudPtr) + ", \sLabel=" + gaDisplayable(n)\sLabel +
;                                         ", aSub(" + getSubLabel(j) + ")\sSubType=" + \sSubType + ", \nSubState=" + decodeCueState(\nSubState) +
;                                         ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
                    bThisCueDisplayed = gaDisplayable(n)\bDisplayThisPanel
                    n + 1
                    
                    k = aAud(k)\nNextPlayIndex
                    ; If (k = -1) And (\bPLRepeat) And (\nAudCount > 1) And (\bPLSavePos = #False) ; removed \bPLSavePos test 4Jul2023 11.10.0bn as this stopped the first file in the loop being displayed
                    If (k = -1) And (getPLRepeatActive(j)) And (\nAudCount > 1) And (\bPLSavePos = #False) ; removed \bPLSavePos test 4Jul2023 11.10.0bn as this stopped the first file in the loop being displayed
                      k = \nFirstPlayIndex
                    EndIf
                  Wend
                  
                Else  ; other subtypes
                  CheckSubInRange(n, ArraySize(gaDisplayable()), "gaDisplayable()")
                  gaDisplayable(n)\nDACuePtr = i
                  gaDisplayable(n)\nDASubPtr = j
                  gaDisplayable(n)\nSubNo = \nSubNo
                  gaDisplayable(n)\nDAAudPtr = \nFirstAudIndex
                  gaDisplayable(n)\nPlayNo = 0
                  gaDisplayable(n)\nSubState = nThisSubState
                  gaDisplayable(n)\bHotkey = \bHotkey
                  gaDisplayable(n)\bExtAct = \bExtAct
                  gaDisplayable(n)\bCallableCue = \bCallableCue
                  gaDisplayable(n)\qDATimeStarted = \qTimeSubStarted
                  gaDisplayable(n)\qDATimeCueStarted = qTimeThisCueStarted
                  If (\nPrevSubIndex <> -1) Or (\nNextSubIndex <> -1)
                    ; if either or both are not -1 then there must be more than one sub
                    gaDisplayable(n)\sLabel = \sCue + " <" + \nSubNo + ">"
                  Else
                    gaDisplayable(n)\sLabel = \sCue
                  EndIf
                  If (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
                    nMyScrollBarValue + 1
                    gaDisplayable(n)\nScrollBarValue = nMyScrollBarValue
                    gaDisplayable(n)\nGadgetY = nMyScrollBarValue * grCuePanels\nCuePanelHeightStdPlusGap
                    nScrollBarMax + 1
                  EndIf
                  ; debugMsg(sProcName, "gaDisplayable(" + n + ")\nDACuePtr=" + getCueLabel(gaDisplayable(n)\nDACuePtr) + ", \nDASubPtr=" + getSubLabel(gaDisplayable(n)\nDASubPtr) +
                  ;                     ", \nDAAudPtr=" + getAudLabel(gaDisplayable(n)\nDAAudPtr))
                  ; debugMsg(sProcName, "\sSubType=" + \sSubType + ", gaDisplayable(" + n + ").sLabel=" + gaDisplayable(n)\sLabel + ", \nSubState=" + decodeCueState(\nSubState))
                  bThisCueDisplayed = gaDisplayable(n)\bDisplayThisPanel
                  n + 1
                  
                EndIf
                
              EndIf ; EndIf bDisplayThisPanel
              
            EndIf
          EndIf ; EndIf aSub(j)\bSubEnabled
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  Next i
  gnMaxDisplayablePanel = n - 1
  
  ; create any necessary additional cue panels
  ; debugMsg(sProcName, "gnMaxDisplayablePanel=" + gnMaxDisplayablePanel + ", gnMaxCuePanelCreated=" + gnMaxCuePanelCreated)
  n = gnMaxCuePanelCreated + 1
  While n <= gnMaxDisplayablePanel
    If n > gnMaxCuePanelAvailable
      Break
    EndIf
    WMN_createCuePanel(n, #True)
    WMN_resizeOneCuePanel(n)
    n + 1
  Wend
  ; debugMsg(sProcName, "gnMaxCuePanelCreated=" + gnMaxCuePanelCreated)
  
  ; debugMsg(sProcName, "gnLastCue=" + gnLastCue + ", gnLastSub=" + gnLastSub + ", gnMaxDisplayablePanel=" + gnMaxDisplayablePanel)
  
  ; ====================
  ; call PNL_setDisplayOrder
  ; ====================
  ; debugMsg(sProcName, "calling PNL_setDisplayOrder")
  nFirstItemPtr = PNL_setDisplayOrder()
  
  With grDispControl
    If nFirstItemPtr >= 0
      \nCuePtr = gaDisplayable(nFirstItemPtr)\nDACuePtr
      \nSubPtr = gaDisplayable(nFirstItemPtr)\nDASubPtr
      \nAudPtr = gaDisplayable(nFirstItemPtr)\nDAAudPtr
      \nSubNo = gaDisplayable(nFirstItemPtr)\nSubNo
      \nPlayNo = gaDisplayable(nFirstItemPtr)\nPlayNo
      \bUseNext = #False
    EndIf
  EndWith
  
  ; =============================
  ; populate the gaDispPanel array
  ; =============================
  ; initialise all items as 'not displayed'
  For p = 0 To ArraySize(gaDispPanel())
    With gaDispPanel(p)
      \nDPCuePtr = -1
      \nDPSubPtr = -1
      \nDPAudPtr = -1
      \nDPSubState = #SCS_CUE_STATE_NOT_SET
      \nDPLinkedToAudPtr = -1 ; Added 2May2022 11.9.1
      \nDPAudLinkCount = 0    ; Added 2May2022 11.9.1
      ; do NOT clear \qDPTimeCueLastEdited, etc
    EndWith
  Next p
  
  ; now populate displayed items from the gaDisplayable array
  For n = 0 To gnMaxDisplayablePanel
    If gbCuePanelLoadingMessageDisplayed = #False
      qTimeNow = ElapsedMilliseconds()
      If (qTimeNow - qTimeStarted) > nWaitMessageTime
        WMI_displayInfoMsg1(sWaitMessage)
        gbCuePanelLoadingMessageDisplayed = #True
      EndIf
    EndIf
    CheckSubInRange(n, ArraySize(gaDisplayable()), "gaDisplayable()")
    p = gaDisplayable(n)\nDispPanelPtr
    If (p >= 0) And (p <= gnMaxCuePanelAvailable)
      CheckSubInRange(p, ArraySize(gaDispPanel()), "gaDispPanel()")
      With gaDispPanel(p)
        \nDPCuePtr = gaDisplayable(n)\nDACuePtr
        \nDPSubPtr = gaDisplayable(n)\nDASubPtr
        \nDPAudPtr = gaDisplayable(n)\nDAAudPtr
        If \nDPSubPtr >= 0
          \sDPSubType = aSub(\nDPSubPtr)\sSubType
          ; debugMsg(sProcName, "p=" + p + ", aSub(" + getSubLabel(\nDPSubPtr) + ")\nSubState=" + decodeCueState(aSub(\nDPSubPtr)\nSubState))
        Else
          \sDPSubType = ""
        EndIf
        ;;;;;;;; \nDPSubState = gaDisplayable(n)\nSubState
        If \nDPSubState <> gaDisplayable(n)\nSubState ; changed 2May2022pm 11.9.1
          \nDPPrevSubState = \nDPSubState
          \nDPSubState = gaDisplayable(n)\nSubState
          ; debugMsg(sProcName, "gaDispPanel(" + p + ")\nDPPrevSubState=" + decodeCueState(\nDPPrevSubState) + ", \nDPSubState=" + decodeCueState(\nDPSubState))
        EndIf
        ; do NOT set \qDPTimeCueLastEdited, etc
        ; debugMsg(sProcName, "gaDispPanel(" + p + ")\nDPSubPtr=" + getSubLabel(\nDPSubPtr) + ", \nDPSubState=" + decodeCueState(\nDPSubState))
      EndWith
    EndIf
  Next n
  
  ; ==================================================
  ; now check if we NEED to display the selected items
  ; ==================================================
  bDispPanelChangeFound = #False
  ; debugMsg(sProcName, "gnMaxDispPanel=" + gnMaxDispPanel + ", nCurrMaxDispPanel=" + nCurrMaxDispPanel)
  If gnMaxDispPanel <> nCurrMaxDispPanel
    n = 0
    bDispPanelChangeFound = #True
  Else
    For n = 0 To gnMaxDispPanel
      With aCurrDispPanelKeyInfo(n)
        If \nDPK_CuePtr <> gaDispPanel(n)\nDPCuePtr Or
           \nDPK_SubPtr <> gaDispPanel(n)\nDPSubPtr Or
           \nDPK_AudPtr <> gaDispPanel(n)\nDPAudPtr Or
           \qDPK_TimeCueLastEdited <> gaDispPanel(n)\qDPTimeCueLastEdited Or
           \qDPK_TimeSubLastEdited <> gaDispPanel(n)\qDPTimeSubLastEdited Or
           \qDPK_TimeAudLastEdited <> gaDispPanel(n)\qDPTimeAudLastEdited Or
           \nDPK_SubState <> gaDispPanel(n)\nDPSubState Or
           gaDispPanel(n)\nDPSubState <> gaDispPanel(n)\nDPPrevSubState Or ; added 2May2022pm 11.9.1
           \nDPK_LinkedToAudPtr <> gaDispPanel(n)\nDPLinkedToAudPtr Or
           \nDPK_AudLinkCount <> gaDispPanel(n)\nDPAudLinkCount ; modified 2May2022 11.9.1
;           debugMsg(sProcName, "change found in gaDispPanel(" + n + ")")
;           debugMsg(sProcName, "..aCurrDispPanelKeyInfo(" + n + ")\nDPK_CuePtr=" + getCueLabel(\nDPK_CuePtr) + ", gaDispPanel(" + n + ")\nDPCuePtr=" + getCueLabel(gaDispPanel(n)\nDPCuePtr))
;           debugMsg(sProcName, "..aCurrDispPanelKeyInfo(" + n + ")\nDPK_SubPtr=" + getSubLabel(\nDPK_SubPtr) + ", gaDispPanel(" + n + ")\nDPSubPtr=" + getSubLabel(gaDispPanel(n)\nDPSubPtr))
;           debugMsg(sProcName, "..aCurrDispPanelKeyInfo(" + n + ")\nDPK_AudPtr=" + getAudLabel(\nDPK_AudPtr) + ", gaDispPanel(" + n + ")\nDPAudPtr=" + getAudLabel(gaDispPanel(n)\nDPAudPtr))
;           debugMsg(sProcName, "..aCurrDispPanelKeyInfo(" + n + ")\nDPK_SubState=" + decodeCueState(\nDPK_SubState) + ", gaDispPanel(" + n + ")\nDPSubState=" + decodeCueState(gaDispPanel(n)\nDPSubState) +
;                               ", gaDispPanel(" + n + ")\nDPPrevSubState=" + decodeCueState(gaDispPanel(n)\nDPPrevSubState))
;           debugMsg(sProcName, "..aCurrDispPanelKeyInfo(" + n + ")\nDPK_LinkedToAudPtr=" + getAudLabel(\nDPK_LinkedToAudPtr) + ", gaDispPanel(" + n + ")\nDPLinkedToAudPtr=" + getAudLabel(gaDispPanel(n)\nDPLinkedToAudPtr))
;           debugMsg(sProcName, "..aCurrDispPanelKeyInfo(" + n + ")\nDPK_AudLinkCount=" + \nDPK_AudLinkCount + ", gaDispPanel(" + n + ")\nDPAudLinkCount=" + gaDispPanel(n)\nDPAudLinkCount)
          bDispPanelChangeFound = #True
          Break
        EndIf
      EndWith
    Next n
  EndIf
  
  If (bDispPanelChangeFound = #False) And (gnMaxDispPanel >= 0) And (gbForceReloadAllDispPanels = #False)
;     debugMsg(sProcName, "no change found in display panel keys")
    
  Else ; bDispPanelChangeFound
    ; ==============================
    ; now display the selected items
    ; ==============================
    nInnerHeight = (gnMaxDispPanel + 1) * grCuePanels\nCuePanelHeightStdPlusGap
    ; debugMsg(sProcName, "nInnerHeight=" + nInnerHeight)
    ; debugMsg(sProcName, "calling SetGadgetAttribute(G" + WMN\scaCuePanels + ", #PB_ScrollArea_InnerHeight, " + nInnerHeight + "), gnThreadNo=" + gnThreadNo)
    SetGadgetAttribute(WMN\scaCuePanels, #PB_ScrollArea_InnerHeight, nInnerHeight)
    
    nScrollYPos = GetGadgetAttribute(WMN\scaCuePanels, #PB_ScrollArea_Y)
    ; debugMsg(sProcName, "nScrollYPos=" + nScrollYPos)
    nScrollPanelPos = Round(nScrollYPos / grCuePanels\nCuePanelHeightStdPlusGap, #PB_Round_Down)
    ; debugMsg(sProcName, "nInnerHeight=" + nInnerHeight + ", nScrollYPos=" + nScrollYPos + ", nScrollPanelPos=" + nScrollPanelPos)
    ; debugMsg(sProcName, "grCuePanels\nCuePanelHeight=" + grCuePanels\nCuePanelHeight + ", grCuePanels\nCuePanelGap=" + grCuePanels\nCuePanelGap)
    
    For p = 0 To gnMaxDispPanel
      If p > gnMaxCuePanelAvailable
        Break
      EndIf
      If gbCuePanelLoadingMessageDisplayed = #False
        qTimeNow = ElapsedMilliseconds()
        If (qTimeNow - qTimeStarted) > nWaitMessageTime
          WMI_displayInfoMsg1(sWaitMessage)
          gbCuePanelLoadingMessageDisplayed = #True
        EndIf
      EndIf
      CheckSubInRange(p, ArraySize(gaDispPanel()), "gaDispPanel()")
      With gaDispPanel(p)
        ; debugMsg(sProcName, "gaDispPanel(" + p + ")\nDPCuePtr=" + \nDPCuePtr + ", \nDPSubPtr=" + \nDPSubPtr + ", \nDPAudPtr=" + \nDPAudPtr)
        \bAwaitingLoad = #True
        If \nDPCuePtr >= 0
          If (p < 3) Or (gbWaitForDispPanels)
            PNL_SetVisible(p, #False)
            ; debugMsg(sProcName, "calling PNL_loadOneDispPanel(" + p + ", " + getSubLabel(\nDPSubPtr) + ", " + getAudLabel(\nDPAudPtr) + ")")
            PNL_loadOneDispPanel(p, \nDPSubPtr, \nDPAudPtr)
            PNL_SetVisible(p, #True)
          Else
            bCallLoadOneCuePanel = #True  ; will call SAM recursively to load next cue panels
          EndIf
        Else
          PNL_SetVisible(p, #False)
        EndIf
      EndWith
    Next p
    ; debugMsg(sProcName, "panels loaded")  ; trace this trying to find cause of crash reported by Tom Shipman 21/01/12
    
  EndIf ; EndIf/Else bDispPanelChangeFound
  
  gbRedrawPanelGradients = #False
  gbForceReloadAllDispPanels = #False
  
  ; debugMsg(sProcName, "calling WMN_displayTemplateInfoIfReqd()")
  WMN_displayTemplateInfoIfReqd()
  
  If gnFocusSliderNo <> 0
    SAG(-1)
  EndIf

  gnHibernatedCueResumed = -1
  
  If bCallLoadOneCuePanel
    samAddRequest(#SCS_SAM_LOAD_NEXT_CUE_PANELS, 1)
    gnWaitWindowEventTimeout = 2  ; minimise delay before next SAM call
  Else
    gbWaitForDispPanels = #False
    ; gbInLoadDispPanels = #False ; del 9Nov2015 11.4.1.2h (moved below, to outside this condition test)
    gbDispPanelsLoaded = #True
  EndIf
  gbInLoadDispPanels = #False ; added 9Nov2015 11.4.1.2h
  
  UnlockCueListMutex()
  
  If getWindowVisible(#WMI)
    debugMsg(sProcName, "calling WMI_Form_Unload()")
    WMI_Form_Unload()
  EndIf
  
  ; reinstate active window in case it was changed by the above
  If IsWindow(nActiveWindow)
    If GetActiveWindow() <> nActiveWindow
      SAW(nActiveWindow)
    EndIf
  EndIf
  ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_loadNextCuePanels(pCallNumber)
  PROCNAMEC()
  Protected bCallLoadOneCuePanel
  Protected p
  Protected nLoadDoneCount
  ; Added 22Nov2021 11.8.6ce
  Protected qTimeStart.q, nTimeInProcedure, sMsg.s, n
  Protected Dim aDPSubPtr(3)
  ; End added 22Nov2021 11.8.6ce
  
  ; debugMsg(sProcName, #SCS_START + ", pCallNumber=" + pCallNumber)
  
  qTimeStart = ElapsedMilliseconds()
  
  For p = 0 To gnMaxDispPanel
    If p > gnMaxCuePanelAvailable
      Break
    EndIf
    With gaDispPanel(p)
      If \bAwaitingLoad
        If nLoadDoneCount < 3
          PNL_SetVisible(p, #False)
          ; debugMsg(sProcName, "calling PNL_loadOneDispPanel(" + p + ", " + getSubLabel(\nDPSubPtr) + ", " + getAudLabel(\nDPAudPtr) + ")")
          PNL_loadOneDispPanel(p, \nDPSubPtr, \nDPAudPtr)
          PNL_SetVisible(p, #True)
          aDPSubPtr(nLoadDoneCount) = \nDPSubPtr ; Added 22Nov2021 11.8.6ce
          nLoadDoneCount + 1
        Else
          bCallLoadOneCuePanel = #True
          Break
        EndIf
      EndIf
    EndWith
  Next p
  
  If bCallLoadOneCuePanel
    samAddRequest(#SCS_SAM_LOAD_NEXT_CUE_PANELS, pCallNumber+1)
    gnWaitWindowEventTimeout = 2  ; minimise delay before next SAM call
  Else
    gbWaitForDispPanels = #False
    gbInLoadDispPanels = #False
    gbDispPanelsLoaded = #True
  EndIf
  
  ; Added 22Nov2021 11.8.6ce
  nTimeInProcedure = ElapsedMilliseconds() - qTimeStart
  If nTimeInProcedure > 100
    sMsg = "nTimeInProcedure=" + nTimeInProcedure + ", pCallNumber=" + pCallNumber + ", nLoadDoneCount=" + nLoadDoneCount
    For n = 0 To nLoadDoneCount - 1
      sMsg + " " + getSubLabel(aDPSubPtr(n))
    Next n
  EndIf
  ; End added 22Nov2021 11.8.6ce
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_reloadDispPanelForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected p
  
  debugMsg(sProcName, #SCS_START)
  
  For p = 0 To gnMaxDispPanel
    If p > gnMaxCuePanelAvailable
      Break
    EndIf
    With gaDispPanel(p)
      If \nDPSubPtr = pSubPtr
        ; debugMsg(sProcName, "calling PNL_loadOneDispPanel(" + p + ", " + getSubLabel(\nDPSubPtr) + ", " + getAudLabel(\nDPAudPtr) + ")")
        PNL_loadOneDispPanel(p, \nDPSubPtr, \nDPAudPtr)
        ; do not Break as there may be more than one disp panel for this sub (for playlists and slideshows)
      EndIf
    EndWith
  Next p
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_setDispPanelsTransportControlsVisible(bShowTransportControls, bSuppressGadgetChange=#False)
  PROCNAMEC()
  Protected p
  
  ; debugMsg(sProcName, #SCS_START + ", bShowTransportControls=" + strB(bShowTransportControls) + ", bSuppressGadgetChange=" + strB(bSuppressGadgetChange) + ", gnMaxDispPanel=" + gnMaxDispPanel)
  For p = 0 To gnMaxDispPanel
    PNL_setTransportControlsVisible(p, bShowTransportControls, bSuppressGadgetChange)
  Next p
  
EndProcedure

Procedure PNL_setDispPanelsFaderAndPanControlsVisible(bShowFaderAndPanControls, bSuppressGadgetChange=#False)
  PROCNAMEC()
  Protected p
  
  ; debugMsg(sProcName, #SCS_START + ", bShowFaderAndPanControls=" + strB(bShowFaderAndPanControls) + ", bSuppressGadgetChange=" + strB(bSuppressGadgetChange) + ", gnMaxDispPanel=" + gnMaxDispPanel)
  For p = 0 To gnMaxDispPanel
    PNL_setFaderAndPanControlsVisible(p, bShowFaderAndPanControls, bSuppressGadgetChange)
  Next p
  
EndProcedure

Procedure PNL_refreshDispPanel(pCuePtr, pSubPtr, pAudPtr=-1, bReloadPanel=#False)
  PROCNAMEC()
  Protected p, bRefreshThis, bReloadThis
  ; Modified 14Dec2018 11.8.0rc3 to force reloading of any display panel that is currently shown as the next manual cue.
  ; This was because activating Stop All would leave the previously-displayed 'next manual cue' still showing 'next manual cue'.
  ; Forcing a reload will reset the 'running ind'
  
  ; debugMsg(sProcName, #SCS_START + ", pCuePtr=" + getCueLabel(pCuePtr) + ", pSubPtr=" + getSubLabel(pSubPtr) + ", pAudPtr=" + getAudLabel(pAudPtr) + ", bReloadPanel=" + strB(bReloadPanel))
  
  If (gbDispPanelsLoaded = #False) Or (gbClosingDown)
    ; debugMsg(sProcName, "exiting")
    ProcedureReturn
  EndIf
  
  If (gbInDisplayCue) Or (gbInDisplaySub)
    ; debugMsg(sProcName, "exiting")
    ProcedureReturn
  EndIf
  
  If pCuePtr >= 0
    Select aCue(pCuePtr)\nHideCueOpt
      Case #SCS_HIDE_ENTIRE_CUE, #SCS_HIDE_CUE_PANEL
        ; debugMsg(sProcName, "exiting")
        ProcedureReturn
    EndSelect
  EndIf
  
  ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  For p = 0 To gnMaxDispPanel
    bRefreshThis = #False
    bReloadThis = bReloadPanel
    If gaPnlVars(p)\bNextManualCue
      ; always reload any cue panel currently displayed as 'next manual cue' 
      bRefreshThis = #True
      bReloadThis = #True
    EndIf
    With gaDispPanel(p)
      If bRefreshThis = #False
        If \nDPCuePtr = pCuePtr
          If \nDPSubPtr = pSubPtr
            If \sDPSubType <> "P"
              bRefreshThis = #True
            ElseIf \nDPAudPtr = pAudPtr
              bRefreshThis = #True
            EndIf
          EndIf
        EndIf
      EndIf
      ; debugMsg(sProcName, "gaDispPanel(" + p + ")\nDPCuePtr=" + getCueLabel(\nDPCuePtr) + ", \nDPSubPtr=" + getSubLabel(\nDPSubPtr) + ", \nDPAudPtr=" + getAudLabel(\nDPAudPtr) +
      ;                     ", bRefreshThis=" + strB(bRefreshThis) + ", bReloadThis=" + strB(bReloadThis))
      If bRefreshThis
        If bReloadThis
          ; debugMsg(sProcName, "calling PNL_loadOneDispPanel(" + p + ", " + getSubLabel(\nDPSubPtr) + ", " + getAudLabel(\nDPAudPtr) + ", #False)")
          PNL_loadOneDispPanel(p, \nDPSubPtr, \nDPAudPtr, #False)
        Else
          ; debugMsg(sProcName, "calling PNL_loadOneDispPanel(" + p + ", " + getSubLabel(\nDPSubPtr) + ", " + getAudLabel(\nDPAudPtr) + ", #True)")
          PNL_loadOneDispPanel(p, \nDPSubPtr, \nDPAudPtr, #True)
        EndIf
        ; Break
      EndIf
    EndWith
  Next p
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_updateDispPanels()
  PROCNAMEC()
  Protected i, j, k, k2, n
  Protected nDispPanel, nPLAudCounter
  Protected bVisualWarningReqd, nVisualWarningTimeRemaining
  Protected sTmp.s, sTmp2.s
  Protected nMyCuePanelUpdateFlags
  Protected bSubPlaying
  
  ; debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  gnLabelUpdDispPanels = 4000
  For i = 1 To gnLastCue
    ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCuePanelUpdateFlags=" + aCue(i)\nCuePanelUpdateFlags + ", \nCueState=" + decodeCueState(aCue(i)\nCueState))
    nMyCuePanelUpdateFlags = aCue(i)\nCuePanelUpdateFlags
    If nMyCuePanelUpdateFlags
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCuePanelUpdateFlags=" + aCue(i)\nCuePanelUpdateFlags + ", \nCueState=" + decodeCueState(aCue(i)\nCueState))
      aCue(i)\nCuePanelUpdateFlags ! nMyCuePanelUpdateFlags
      bSubPlaying = #False  ; will be set #True if at least one sub in this cue is playing
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          nDispPanel = -1
          For n = 0 To ArraySize(gaDispPanel())
            If (gaDispPanel(n)\nDPCuePtr = i) And (gaDispPanel(n)\nDPSubPtr = j)
              nDispPanel = n
              Break
            EndIf
          Next n
          If nDispPanel >= 0
            ; debugMsg(sProcName, "gaDispPanel(" + nDispPanel + ")\nDPSubState=" + decodeCueState(gaDispPanel(nDispPanel)\nDPSubState))
            If (\bSubTypeF) Or ((\bSubTypeM) And (\nFirstAudIndex >= 0 Or \nSubDuration > 0)) ; bSubTypeF or bSubTypeM with a MIDI file
              gnLabelUpdDispPanels = 4110
              ; debugMsg(sProcName, "calling PNL_updateDisplayPanel(" + nDispPanel + ", " + getCueLabel(i) + ", " + getSubLabel(j) + ", " + getAudLabel(\nFirstAudIndex) + ", " + nMyCuePanelUpdateFlags + ")")
              PNL_updateDisplayPanel(nDispPanel, i, j, \nFirstAudIndex, nMyCuePanelUpdateFlags)
              gnLabelUpdDispPanels = 4115
              If gaDispPanel(nDispPanel)\nVisualWarningState > 0
                bVisualWarningReqd = #True
                nVisualWarningTimeRemaining = gaDispPanel(nDispPanel)\nVisualWarningTimeRemaining
              EndIf
              
            ElseIf \bSubTypeI   ; bSubTypeI
              gnLabelUpdDispPanels = 4120
              PNL_updateDisplayPanel(nDispPanel, i, j, \nFirstAudIndex, nMyCuePanelUpdateFlags)
              gnLabelUpdDispPanels = 4121
              
            ElseIf \bSubTypeAorP = #False  ; not bSubTypeAorP
              gnLabelUpdDispPanels = 4125
              PNL_updateDisplayPanel(nDispPanel, i, j, -1, nMyCuePanelUpdateFlags)
              gnLabelUpdDispPanels = 4126
            EndIf
          EndIf
          
          If \bSubTypeAorP ; bSubTypeAorP
            gnLabelUpdDispPanels = 4130
            k = \nCurrPlayIndex
            If k >= 0
              k2 = aAud(k)\nPrevPlayIndex
              If (k2 = -1) And (getPLRepeatActive(j))
                k2 = aSub(j)\nLastPlayIndex
              EndIf
              If k2 >= 0
                If (aAud(k2)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k2)\nAudState <= #SCS_CUE_FADING_OUT)
                  k = k2
                EndIf
              EndIf
            EndIf
            gnLabelUpdDispPanels = 4140
            nPLAudCounter = 0
            ; PNL_updateDisplayPanel for up to two currently running audio files
            While (k >= 0) And (nPLAudCounter < 2)
              gnLabelUpdDispPanels = 4145
              nDispPanel = -1
              For n = 0 To ArraySize(gaDispPanel())
                If (gaDispPanel(n)\nDPCuePtr = i) And (gaDispPanel(n)\nDPSubPtr = j) And (gaDispPanel(n)\nDPAudPtr = k)
                  nDispPanel = n
                  Break
                EndIf
              Next n
              If nDispPanel >= 0
                gnLabelUpdDispPanels = 4150
                ; debugMsg(sProcName, "call PNL_updateDisplayPanel()")
                PNL_updateDisplayPanel(nDispPanel, i, j, k, nMyCuePanelUpdateFlags)
                gnLabelUpdDispPanels = 4151
              EndIf
              gnLabelUpdDispPanels = 4160
              nPLAudCounter + 1
              k = aAud(k)\nNextPlayIndex
              ; If (k = -1) And (\bPLRepeat) And (\nAudCount > 1)
              If (k = -1) And (getPLRepeatActive(j)) And (\nAudCount > 1)
                k = \nFirstPlayIndex
              EndIf
            Wend
          EndIf
          If (\nSubState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nSubState <= #SCS_CUE_FADING_OUT)
            bSubPlaying = #True
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
      With aCue(i)
        If (bSubPlaying) Or (\nCueState >= #SCS_CUE_COUNTDOWN_TO_START And (\nCueState <= #SCS_CUE_FADING_OUT))
          \nCuePanelUpdateFlags | #SCS_CUEPNL_PROGRESS
          ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCuePanelUpdateFlags=" + \nCuePanelUpdateFlags)
        EndIf
      EndWith
    EndIf
  Next i
  
  ; the following moved to THR_runControlThread() as GetOpenWavFileName() etc do not return to handleWindowEvents() until the user has completed the dialog,
  ; which means THIS procedure (PNL_updateDispPanels()) will not be called while the dialog is open.
  ; gnLabelUpdDispPanels = 6000
  ; If gbPreviewPlaying
    ; debugMsg(sProcName, "nLabel=" + nLabel + " calling updatePreviewProgressTrackbar()")
    ; updatePreviewProgressTrackbar()
  ; EndIf
  
  gnLabelUpdDispPanels = 9999
 
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_calcMaxCuePanelAvailable()
  PROCNAMEC()
  Protected nCuePanelsVisible, nScrollAreaHeight, nReqdCuePanelsAvailable, nOriginalMax
  
  nOriginalMax = gnMaxCuePanelAvailable
  gnMaxCuePanelAvailable = 9
  If IsGadget(WMN\scaCuePanels)
    nScrollAreaHeight = GadgetHeight(WMN\scaCuePanels)
    nCuePanelsVisible = Round(nScrollAreaHeight / grCuePanels\nCuePanelHeightStdPlusGap, #PB_Round_Up)
    nReqdCuePanelsAvailable = Round(nCuePanelsVisible * 1.5, #PB_Round_Up)
    If nReqdCuePanelsAvailable > gnMaxCuePanelAvailable
      gnMaxCuePanelAvailable = nReqdCuePanelsAvailable
    EndIf
  EndIf
  If gnMaxCuePanelAvailable <> nOriginalMax
    debugMsg(sProcName, "gnMaxCuePanelAvailable=" + gnMaxCuePanelAvailable)
  EndIf
EndProcedure

Procedure PNL_drawDeviceText(h, d)
  PROCNAMECP(h)
  Protected nSubPtr, nAudPtr, nLCAudPtr, d1, d2, nDevIndex, nTextColor, nBackColor, nThisTextColor
  Protected sDevName1.s, sDevName2.s, nDevGadgetNo
  Protected bDevSelected1, bDevSelected2
  Protected nPass, nPassDevNo, sPassDevName.s, nPass1TextWidth, bPassDevSelected
  Protected nTextWidth, nTextHeight, nLeft, nTop
  Protected sSlash.s, nSlashWidth
  Protected nSldPtr, nSldPtr1, nSldPtr2
  
  nSubPtr = gaDispPanel(h)\nDPSubPtr
  nAudPtr = gaDispPanel(h)\nDPAudPtr
  
;   With gaDispPanel(h)
;     debugMsg(sProcName, "gaDispPanel(" + h + ")\nDPSubPtr=" + getSubLabel(\nDPSubPtr) + ", \nMaxDev=" + \nMaxDev)
;   EndWith
  
  With gaPnlVars(h)
    If d < grCuePanels\nMaxDevLines
      d1 = d
      d2 = -1
    ElseIf d < grCuePanels\nTwiceDevLines
      d1 = d - grCuePanels\nMaxDevLines
      d2 = d
    Else
      ProcedureReturn
    EndIf
    nDevGadgetNo = gaPnlVars(h)\cvsDevice[d1]
    If IsGadget(nDevGadgetNo) And nSubPtr >= 0
      If aSub(nSubPtr)\bSubTypeF And nAudPtr >= 0
        ; NOTE: SubTypeF
        sDevName1 = VST_adjustLogicalDevForVST(aAud(nAudPtr)\sLogicalDev[d1])
        bDevSelected1 = aAud(nAudPtr)\bDeviceSelected[d1]
        nSldPtr1 = \sldCueVol[d1]
        If d2 >= 0
          If aAud(nAudPtr)\sLogicalDev[d2]
            sDevName2 = VST_adjustLogicalDevForVST(aAud(nAudPtr)\sLogicalDev[d2])
            bDevSelected2 = aAud(nAudPtr)\bDeviceSelected[d2]
            nSldPtr2 = \sldCuePan[d1]
            gaDispPanel(h)\sPrevDevNames2 = sDevName2
            ; debugMsg(sProcName, "gaDispPanel(" + h + ")\sPrevDevNames2=" + gaDispPanel(h)\sPrevDevNames2)
          EndIf
        EndIf
        
      ElseIf aSub(nSubPtr)\bSubTypeA And nAudPtr >= 0
        ; NOTE: SubTypeA
        If d = 0 ; only one audio device for video cues
          If aAud(nAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO
            sDevName1 = aSub(nSubPtr)\sVidAudLogicalDev
            nSldPtr1 = \sldCueVol[d1]
          EndIf
        EndIf
        ; debugMsg0(sProcName, "d=" + d + ", aAud(nAudPtr)\nFileFormat=" + decodeFileFormat(aAud(nAudPtr)\nFileFormat))
        gaDispPanel(h)\sPrevDevNames2 = sDevName2
        
      ElseIf aSub(nSubPtr)\bSubTypeL
        ; NOTE: SubTypeL
        Select aSub(nSubPtr)\nLCAction
          Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
            nLCAudPtr = aSub(nSubPtr)\nLCAudPtr
            If nLCAudPtr >= 0
              sDevName1 = aAud(nLCAudPtr)\sLogicalDev[d1]
              bDevSelected1 = aAud(nLCAudPtr)\bDeviceSelected[d1]
              If d2 >= 0
                If aAud(nLCAudPtr)\sLogicalDev[d2]
                  sDevName2 = aAud(nLCAudPtr)\sLogicalDev[d2]
                  bDevSelected2 = aAud(nLCAudPtr)\bDeviceSelected[d2]
                  nSldPtr2 = \sldCuePan[d1]
                  ; sPrevDevNames2 = sDevName2
                  gaDispPanel(h)\sPrevDevNames2 = sDevName2
                Else
                  sDevName2 = " "
                EndIf
              EndIf
            EndIf
        EndSelect
        
      ElseIf aSub(nSubPtr)\bSubTypeP
        ; NOTE: SubTypeP
        sDevName1 = aSub(nSubPtr)\sPLLogicalDev[d1]
        nSldPtr1 = \sldCueVol[d1]
        If d2 >= 0
          If aSub(nSubPtr)\sPLLogicalDev[d2]
            sDevName2 = aSub(nSubPtr)\sPLLogicalDev[d2]
            nSldPtr2 = \sldCuePan[d1]
            gaDispPanel(h)\sPrevDevNames2 = sDevName2
          EndIf
        EndIf

      EndIf
      ; debugMsg(sProcName, "nSubPtr=" + getSubLabel(nSubPtr) + ", nLCAudPtr=" + getAudLabel(nLCAudPtr) + ", sDevName1=" + #DQUOTE$ + sDevName1 + #DQUOTE$)
      
      If \bActiveOrComplete
        ; debugMsg(sProcName, "color ActiveOrComplete")
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
      Else
        ; debugMsg(sProcName, "color Inactive")
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
      EndIf
      If StartDrawing(CanvasOutput(nDevGadgetNo))
        ; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", StartDrawing(CanvasOutput(" + getGadgetName(nDevGadgetNo) + "))")
        Box(0, 0, OutputWidth(), OutputHeight(), nBackColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_CUE_NORMAL)
        nTextHeight = TextHeight("gG") ; constant to provide same height for all device names, regardless of content
        nTop = (OutputHeight() - nTextHeight) >> 1
        For nPass = 1 To 2
          If nPass = 1
            nPassDevNo = d2
            sPassDevName = sDevName2
            bPassDevSelected = bDevSelected2
            nSldPtr = nSldPtr2
          Else
            nPassDevNo = d1
            sPassDevName = sDevName1
            bPassDevSelected = bDevSelected1
            nSldPtr = nSldPtr1
          EndIf
          If (d1 >= 0 Or d2 >= 0) And nPassDevNo <= #SCS_MAX_AUDIO_DEV_PER_DISP_PANEL
            ; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", nPass=" + nPass + ", nPassDevNo=" + nPassDevNo + ", d1=" + d1 + ", sDevName1=" + sDevName1 + ", d2=" + d2 + ", sDevName2=" + sDevName2)
            If nPass = 2 And (Trim(sDevName2) Or Trim(gaDispPanel(h)\sPrevDevNames2))
              scsDrawingFont(#SCS_FONT_CUE_NORMAL)
              sSlash = " / "
              nSlashWidth = TextWidth(sSlash)
              nLeft = OutputWidth() - nPass1TextWidth - nSlashWidth
              DrawText(nLeft, nTop, sSlash, nTextColor)
              ; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", DrawText(" + nLeft + ", " + nTop + ", " + sSlash + ", nTextColor)")
            EndIf              
            If bPassDevSelected
              nThisTextColor = #SCS_Black
              scsDrawingFont(#SCS_FONT_CUE_BOLD) ; Bold if selected
            Else
              nThisTextColor = nTextColor
              scsDrawingFont(#SCS_FONT_CUE_NORMAL) ; Otherwise 'normal'
            EndIf
            If Trim(sPassDevName)
              nTextWidth = TextWidth(sPassDevName)
            Else
              nTextWidth = TextWidth(gaDispPanel(h)\sPrevDevNames2)
            EndIf
            ; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", nTextWidth=" + nTextWidth)
            If nTextWidth > 0
              If nPass = 1
                nPass1TextWidth = nTextWidth
                nLeft = OutputWidth() - nTextWidth
              Else
                nLeft = OutputWidth() - nPass1TextWidth - nSlashWidth - nTextWidth
              EndIf
              If nAudPtr >= 0 And nTextWidth > 0
                aAud(nAudPtr)\nDeviceMinX[nPassDevNo] = nLeft
                aAud(nAudPtr)\nDeviceMaxX[nPassDevNo] = nLeft + nTextWidth - 1
                ; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nDeviceMinX[" + nPassDevNo + "]=" + aAud(nAudPtr)\nDeviceMinX[nPassDevNo] +
                ;                     ", aAud(" + getAudLabel(nAudPtr) + ")\nDeviceMaxX[" + nPassDevNo + "]=" + aAud(nAudPtr)\nDeviceMaxX[nPassDevNo])
              EndIf
              If Trim(sPassDevName)
                DrawText(nLeft, nTop, sPassDevName, nThisTextColor)
                ; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", DrawText(" + nLeft + ", " + nTop + ", " + sPassDevName + ", nTextColor)")
              EndIf
            EndIf ; EndIf nTextWidth > 0
          EndIf
          ; debugMsg(sProcName, "nSldPtr=" + nSldPtr + ", h=" + h + ", nPassDevNo=" + nPassDevNo)
          If nSldPtr >= 0 And nPassDevNo >= 0 And nPassDevNo <= #SCS_MAX_AUDIO_DEV_PER_DISP_PANEL
            If bPassDevSelected
              SLD_setBtnColor1(nSldPtr, #Cyan)
            Else
              SLD_setBtnColor1(nSldPtr, -1)
            EndIf
          EndIf
        Next nPass
        StopDrawing()
        ; debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr) + ", StopDrawing()")
        If nSldPtr1
          ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr1 + ")")
          SLD_drawButton(nSldPtr1)
        EndIf
        If nSldPtr2
          ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr2 + ")")
          SLD_drawButton(nSldPtr2)
        EndIf
      Else
        If sDevName1
          debugMsg0(sProcName, "StartDrawing FAILED, sDevName1=" + #DQUOTE$ + sDevName1 + #DQUOTE$)
        EndIf
      EndIf ; EndIf StartDrawing(CanvasOutput(nDevGadgetNo))
    EndIf ; EndIf IsGadget(nDevGadgetNo)
    If Len(Trim(sDevName1)) = 0 And Len(Trim(sDevName2)) = 0
      setVisible(nDevGadgetNo, #False)
    Else
      setVisible(nDevGadgetNo, #True)
    EndIf
  EndWith
  
EndProcedure

Procedure PNL_drawDeviceTextWithThisDevName(h, d, sDevName.s)
  PROCNAMECP(h)
  Protected nDevGadgetNo
  Protected nTextColor, nBackColor, nTextWidth, nTextHeight, nLeft, nTop
  
  With gaPnlVars(h)
    If d >= grCuePanels\nMaxDevLines
      ProcedureReturn
    EndIf
    nDevGadgetNo = gaPnlVars(h)\cvsDevice[d]
    If IsGadget(nDevGadgetNo)
      If \bActiveOrComplete
        ; debugMsg(sProcName, "color ActiveOrComplete")
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DA]\nTextColor
      Else
        ; debugMsg(sProcName, "color Inactive")
        nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
        nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_DP]\nTextColor
      EndIf
      If StartDrawing(CanvasOutput(nDevGadgetNo))
        Box(0, 0, OutputWidth(), OutputHeight(), nBackColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_CUE_NORMAL)
        nTextHeight = TextHeight("gG") ; constant to provide same height for all device names, regardless of content
        nTextWidth = TextWidth(sDevName)
        If nTextWidth > 0
          nLeft = OutputWidth() - nTextWidth
          DrawText(nLeft, nTop, sDevName, nTextColor)
        EndIf
        StopDrawing()
      Else
        debugMsg0(sProcName, "StartDrawing FAILED, sDevName=" + #DQUOTE$ + sDevName + #DQUOTE$)
      EndIf ; EndIf StartDrawing(CanvasOutput(nDevGadgetNo))
    EndIf ; EndIf IsGadget(nDevGadgetNo)
    If Len(Trim(sDevName)) = 0
      setVisible(nDevGadgetNo, #False)
    Else
      setVisible(nDevGadgetNo, #True)
    EndIf
  EndWith
  
EndProcedure

Procedure PNL_cvsDevice_leftClick(h, d)
  PROCNAMECP(h)
  Protected nGadgetNo, nMouseX, d1, d2, nAudPtr, nDevNo, nSldPtr
  Protected bCtrlKeyDown, bShiftKeyDown, nFirstSelectedDev, nLastSelectedDev, n
  Protected Dim bDevRedraw.i(#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB), nDevRedrawCount
  Static nEarliestSelectedShiftDev, nPrevAudPtr
  
  debugMsg(sProcName, #SCS_START + ", d=" + d)
  
  nAudPtr = gaDispPanel(h)\nDPAudPtr
  If nAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nAudPtr)
    If \bAudTypeF = #False
      ; Currently 'link audio device levels' only supported for Aud Type F
      ProcedureReturn
    EndIf
    
    nGadgetNo = gnEventGadgetNo
    nMouseX = GetGadgetAttribute(nGadgetNo, #PB_Canvas_MouseX)
    ; debugMsg(sProcName, "GetGadgetAttribute(" + getGadgetName(nGadgetNo) + ", #PB_Canvas_MouseX) returned " + nMouseX)
    d1 = d
    d2 = d + grCuePanels\nMaxDevLines
    If nMouseX >= \nDeviceMinX[d1] And nMouseX <= \nDeviceMaxX[d1]
      nDevNo = d1
    ElseIf nMouseX >= \nDeviceMinX[d2] And nMouseX <= \nDeviceMaxX[d2]
      nDevNo = d2
    Else
      nDevNo = -1
    EndIf
    If nDevNo >= 0 And nDevNo <= #SCS_MAX_AUDIO_DEV_PER_DISP_PANEL
      bCtrlKeyDown = isCtrlKeyDown()
      bShiftKeyDown = isShiftKeyDown()
      If bShiftKeyDown = #False Or nAudPtr <> nPrevAudPtr
        nEarliestSelectedShiftDev = -1
      EndIf
      
      If bCtrlKeyDown ; NOTE: Ctrl key down
        \bDeviceSelected[nDevNo] ! 1 ; flip selected state
        bDevRedraw(nDevNo) = #True
        
      ElseIf bShiftKeyDown ; NOTE Shift key down
        If nEarliestSelectedShiftDev = -1
          nEarliestSelectedShiftDev = nDevNo
        EndIf
        If nEarliestSelectedShiftDev <= nDevNo
          nFirstSelectedDev = nEarliestSelectedShiftDev
          nLastSelectedDev = nDevNo
        Else
          nFirstSelectedDev = nDevNo
          nLastSelectedDev = nEarliestSelectedShiftDev
          nEarliestSelectedShiftDev = nDevNo
        EndIf
        ; debugMsg(sProcName, "nDevNo=" + nDevNo + ", nEarliestSelectedShiftDev=" + nEarliestSelectedShiftDev + ", nFirstSelectedDev=" + nFirstSelectedDev + ", nLastSelectedDev=" + nLastSelectedDev)
        For n = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
          If n < nFirstSelectedDev Or n > nLastSelectedDev
            If \bDeviceSelected[n]
              \bDeviceSelected[n] = #False
              bDevRedraw(n) = #True
            EndIf
          Else
            If \bDeviceSelected[n] = #False
              \bDeviceSelected[n] = #True
              bDevRedraw(n) = #True
            EndIf
          EndIf
        Next n
        
      Else ; NOTE: Neither Shift nor Ctrl down
        \bDeviceSelected[nDevNo] ! 1 ; flip selected state
        bDevRedraw(nDevNo) = #True
        ; clear all others
        For n = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
          If n <> nDevNo
            If \bDeviceSelected[n]
              \bDeviceSelected[n] = 0
              bDevRedraw(n) = #True
            EndIf
          EndIf
        Next n
        If \bDeviceSelected[nDevNo]
          nEarliestSelectedShiftDev = nDevNo
        Else
          nEarliestSelectedShiftDev = -1
        EndIf
        
      EndIf
      
      setDeviceInitialTotalVolWorksIfReqd(nAudPtr)

      For nDevNo = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
        If bDevRedraw(nDevNo)
          nDevRedrawCount + 1
          ; debugMsg(sProcName, "bDevRedraw(" + nDevNo + ")=" + strB(bDevRedraw(nDevNo)))
          If nDevNo < grCuePanels\nMaxDevLines
            d1 = nDevNo
            nSldPtr = gaPnlVars(h)\sldCueVol[d1]
          Else
            d1 = nDevNo - grCuePanels\nMaxDevLines
            nSldPtr = gaPnlVars(h)\sldCuePan[d1] ; 'pan' control, adjusted for levels, used for levels of devices displayed in the RHS
          EndIf
          d2 = PNL_calcDevNoForDrawDeviceText(h, nDevNo)
          ; debugMsg(sProcName, "calling PNL_drawDeviceText(" + h + ", " + d2 + ")")
          PNL_drawDeviceText(h, d2)
          If nSldPtr >= 0
            If \bDeviceSelected[nDevNo]
              SLD_setBtnColor1(nSldPtr, #Cyan)
            Else
              SLD_setBtnColor1(nSldPtr, -1)
            EndIf
            SLD_drawButton(nSldPtr)
          EndIf
        EndIf
      Next nDevNo
      
      If nDevRedrawCount > 0
        listLinkedDevsForAud(nAudPtr)
        If \bAudTypeF
          If gbEditorFormLoaded And grCED\sDisplayedSubType = "F" And nAudPtr = nEditAudPtr
            ; resync linked devices in the editor window if this aud is current in the editor
            debugMsg(sProcName, "calling WQF_displaySub(" + getSubLabel(\nSubIndex) + ")")
            WQF_displaySub(\nSubIndex)
          EndIf
        EndIf
      EndIf
      
      nPrevAudPtr = nAudPtr
      
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PNL_clearDeviceSelectedFlags(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d, bChanged, h
  
  For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
    If aAud(pAudPtr)\bDeviceSelected[d]
      aAud(pAudPtr)\bDeviceSelected[d] = #False
      bChanged = #True
    EndIf
  Next d
  
  If bChanged
    For h = 0 To ArraySize(gaDispPanel())
      If gaDispPanel(h)\nDPAudPtr = pAudPtr
        PNL_drawPanelGradient(h)
        Break
      EndIf
    Next h
  EndIf
  
EndProcedure

Procedure PNL_calcDevNoForDrawDeviceText(h, nDevNo)
  Protected nCalcDevNo
  
  Select gaDispPanel(h)\sDPSubType
    Case "F", "P", "L"
      If nDevNo < grCuePanels\nMaxDevLines
        nCalcDevNo = nDevNo + grCuePanels\nMaxDevLines
        ; nb will cause PNL_drawDeviceText() to draw text for both 'nDevNo' and 'nDevNo+\nMaxDevLines', eg for both 'nDevNo' and 'nDevNo+4'.
        ; Handles absent device names OK, eg if no 'nDevNo+4' device assigned.
      Else
        nCalcDevNo = nDevNo
      EndIf
    Default
      nCalcDevNo = nDevNo
  EndSelect
  ProcedureReturn nCalcDevNo
  
EndProcedure

; EOF