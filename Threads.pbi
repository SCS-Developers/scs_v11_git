; File: Threads.pbi

EnableExplicit

; ThreadPriority info
; ===================
; Priority - The priority you want to assign to the thread.
;    The priority can be 0 (meaning not to change the priority) or range from 1 (lowest priority) to 32 (highest priority). 16 is normal priority. 
;    Windows doesn't support 32 different level of priority, here is the corresponding table: 
;       - 1: lowest
;       - between 2 And 15: below normal 
;       - 16:  normal
;       - between 17 And 30: above normal
;       - 31: highest
;       - 32: time-critical
;
; The default priority is 16 (normal)

Procedure THR_setThreadPriority(nThreadIndex)
  PROCNAMECT(nThreadIndex)
  Protected nPriority, nOldPriority
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaThread(nThreadIndex)
    Select nThreadIndex
      Case #SCS_THREAD_BLENDER
        ; nPriority = 31  ; highest
        nPriority = 24  ; above normal
        
      Case #SCS_THREAD_CONTROL
        nPriority = 16  ; normal
        
      Case #SCS_THREAD_SLIDER_FILE_LOADER
        nPriority = 8   ; below normal
        
      Case #SCS_THREAD_MTC_CUES
        nPriority = 32  ; time-critical
        
      Case #SCS_THREAD_NETWORK
        nPriority = 24  ; above normal
        
      Case #SCS_THREAD_RS232_RECEIVE
        nPriority = 24  ; above normal
        
      Case #SCS_THREAD_DMX_SEND
        nPriority = 31  ; highest (to provide smooth lighting fades)
        
      Case #SCS_THREAD_DMX_RECEIVE
        nPriority = 24  ; above normal
        
      Case #SCS_THREAD_HTTP_SEND
        nPriority = 24  ; above normal
        
      Case #SCS_THREAD_GET_FILE_STATS
        nPriority = 8   ; below normal
        
      Case #SCS_THREAD_SYSTEM_MONITOR
        nPriority = 8   ; below normal
        
      Case #SCS_THREAD_SCS_LTC
        ; nPriority = 30   ; High, real time audio
        nPriority = 32  ; time-critical ; Changed 7Jan2025 11.10.6ch
        
    EndSelect
    
    If nPriority > 0
      If nPriority <> \nThreadPriority
        nOldPriority = ThreadPriority(\hThread, nPriority)
        debugMsg(sProcName, "ThreadPriority(" + THR_decodeThreadIndex(nThreadIndex) + ", " + nPriority + "), nOldPriority=" + nOldPriority)
      EndIf
    EndIf
    \nThreadPriority = nPriority
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Macro setTraceLogging(nThreadIndex)
  Protected bTrace = #True
  Select nThreadIndex
    Case #SCS_THREAD_CONTROL, #SCS_THREAD_MTC_CUES ;, #SCS_THREAD_SCS_LTC ; Changed 20Nov2024 11.10.6bm
      If gaThread(nThreadIndex)\bThreadCreated
        bTrace = #False
      EndIf
  EndSelect
EndMacro

Procedure THR_createOrResumeAThread(nThreadIndex)
  PROCNAMECT(nThreadIndex)
  
  setTraceLogging(nThreadIndex)
  
  debugMsgC(sProcName, #SCS_START)
  
  With gaThread(nThreadIndex)
    ; added 2Sep2019 11.8.2aj - clear out any outstanding pause or stop MTC request
    If nThreadIndex = #SCS_THREAD_MTC_CUES Or nThreadIndex = #SCS_THREAD_SCS_LTC
      If grMTCSendControl\nMTCThreadRequest & #SCS_MTC_THR_PAUSE_MTC
        grMTCSendControl\nMTCThreadRequest ! #SCS_MTC_THR_PAUSE_MTC
      EndIf
      If grMTCSendControl\nMTCThreadRequest & #SCS_MTC_THR_STOP_MTC
        grMTCSendControl\nMTCThreadRequest ! #SCS_MTC_THR_STOP_MTC
      EndIf
      debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
      \bStopASAP = #False
      \bStopRequested = #False
      \bSuspendRequested = #False
      debugMsg(sProcName, "gaThread(" + nThreadIndex + ")\bStopRequested=" + strB(\bStopRequested) + ", \bSuspendRequested=" + StrB(\bSuspendRequested))
      grMTCSendControl\qLogQtrFramesStartTime = ElapsedMilliseconds()
    EndIf
    ; end added 2Sep2019 11.8.2aj
    
    If \bThreadCreated = #False
      \nThreadState = #SCS_THREAD_STATE_NOT_CREATED
      \nThreadPriority = 0
      ; moved to above 2Sep2019 11.8.2aj
      ; \bStopASAP = #False
      ; \bStopRequested = #False
      ; \bSuspendRequested = #False
      ; debugMsg(sProcName, "\bStopRequested=" + strB(\bStopRequested) + ", \bSuspendRequested=" + StrB(\bSuspendRequested))
      ; end moved to above 2Sep2019 11.8.2aj
      Select nThreadIndex
        Case #SCS_THREAD_BLENDER
          \hThread = CreateThread(@THR_runBlenderThread(), 0)
          
        Case #SCS_THREAD_CONTROL
          \hThread = CreateThread(@THR_runControlThread(), 0)
          
        Case #SCS_THREAD_SLIDER_FILE_LOADER
          \hThread = CreateThread(@THR_runSliderFileLoaderThread(), 0)
          
        Case #SCS_THREAD_MTC_CUES
          \hThread = CreateThread(@THR_runMTCCuesThread(), 0)
          
        Case #SCS_THREAD_NETWORK
          \hThread = CreateThread(@THR_runNetworkThread(), 0)
          
        Case #SCS_THREAD_RS232_RECEIVE
          \hThread = CreateThread(@runRS232ReceiveThread(), 0)
          
        Case #SCS_THREAD_CTRL_SEND
          \hThread = CreateThread(@THR_runCtrlSendThread(), 0)
          
        Case #SCS_THREAD_DMX_SEND
          \hThread = CreateThread(@THR_runDMXSendThread(), 0)
          
        Case #SCS_THREAD_DMX_RECEIVE
          \hThread = CreateThread(@THR_runDMXReceiveThread(), 0)
          
        Case #SCS_THREAD_HTTP_SEND
          \hThread = CreateThread(@THR_runHTTPSendThread(), 0)
          
        Case #SCS_THREAD_GET_FILE_STATS
          \hThread = CreateThread(@THR_runGetFileStatsThread(), 0)
          
        Case #SCS_THREAD_SYSTEM_MONITOR
          \hThread = CreateThread(@THR_runSystemMonitorThread(), 0)
          
        Case #SCS_THREAD_SCS_LTC
          CompilerIf #c_scsltc
            \hThread = CreateThread(@THR_scsLTC(), nThreadIndex)
          CompilerEndIf
          
        Default
          ; shouldn't get here
          debugMsg(sProcName, "unrecognised nThreadIndex (" + nThreadIndex + ")")
          \hThread = 0
          
      EndSelect
      debugMsg(sProcName, "IsThread(" + THR_decodeThread(\hThread) + ")=" + IsThread(gaThread(nThreadIndex)\hThread))
      
      If IsThread(\hThread)
        \bThreadCreated = #True
        THR_setThreadPriority(nThreadIndex)
      EndIf
      
      debugMsg(sProcName, "gaThread(" + nThreadIndex + ")\hThread=" + \hThread + ", \nThreadPriority=" + \nThreadPriority)
      
    Else
      ; thread already exists
      
      ; reset priority if necessary
      ; debugMsg(sProcName, "calling THR_setThreadPriority(" + THR_decodeThreadIndex(nThreadIndex) + ")")
      THR_setThreadPriority(nThreadIndex)
      
      ; resume thread
      debugMsgC(sProcName, "calling THR_resumeAThread(" + THR_decodeThreadIndex(nThreadIndex) + ")")
      THR_resumeAThread(nThreadIndex)
      
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure THR_resumeAThread(nThreadIndex)
  PROCNAMECT(nThreadIndex)
  
  setTraceLogging(nThreadIndex)
  
  debugMsgC(sProcName, #SCS_START)
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      ; If \nThreadState <> #SCS_THREAD_STATE_ACTIVE
      ; Deleted the above test 9Nov2020 11.8.3.3ad following tests of MTC cue with PauseAll/ResumeAll - sometimes the \bSuspendRequested seems to have been left set #True,
      ; probably due to some inter-thread timing issue, and that caused the thread to be re-suspended even though the current thread state was 'active'.
      ; By deleting this test, THR_resumeAThread() will ALWAYS clear \bSuspendRequest (and the other booleans).
        \nThreadState = #SCS_THREAD_STATE_ACTIVE
        \bStopASAP = #False
        \bStopRequested = #False
        If \bSuspendRequested
          \bSuspendRequested = #False
          ; debugMsg(sProcName, "\bStopRequested=" + strB(\bStopRequested) + ", \bSuspendRequested=" + StrB(\bSuspendRequested))
        EndIf
      ; EndIf
      debugMsgC(sProcName, #SCS_END + ", \nThreadState=" + THR_decodeThreadState(\nThreadState))
    Else
      debugMsg(sProcName, #SCS_END + ", \bThreadCreated=#False")
    EndIf
  EndWith

EndProcedure

Procedure THR_stopAThread(nThreadIndex)
  PROCNAMECT(nThreadIndex)

  setTraceLogging(nThreadIndex)
  
  debugMsgC(sProcName, #SCS_START)
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      If \nThreadState = #SCS_THREAD_STATE_ACTIVE
        \bStopRequested = #True
        ; debugMsg(sProcName, "\bStopRequested=" + strB(\bStopRequested))
      EndIf
      debugMsgC(sProcName, #SCS_END + ", \nThreadState=" + THR_decodeThreadState(\nThreadState))
    Else
      debugMsg(sProcName, #SCS_END + ", \bThreadCreated=#False")
    EndIf
  EndWith

EndProcedure

Procedure THR_suspendAThread(nThreadIndex)
  PROCNAMECT(nThreadIndex)
  
  setTraceLogging(nThreadIndex)
  
  debugMsgC(sProcName, #SCS_START)
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      If \nThreadState = #SCS_THREAD_STATE_ACTIVE
        \bSuspendRequested = #True
        ; debugMsg(sProcName, "\bSuspendRequested=" + StrB(\bSuspendRequested))
      EndIf
      ; debugMsg(sProcName, #SCS_END + ", \nThreadState=" + THR_decodeThreadState(\nThreadState))
    Else
      debugMsg(sProcName, #SCS_END + ", \bThreadCreated=#False")
    EndIf
  EndWith
EndProcedure


Procedure THR_suspendAThreadAndWait(nThreadIndex, nDelayTime=100, nTimeOut=4000)
  PROCNAMECT(nThreadIndex)
  Protected nThreadState
  
  setTraceLogging(nThreadIndex)
  
  debugMsgC(sProcName, #SCS_START + ", nDelayTime=" + nDelayTime + ", nTimeOut=" + nTimeOut)
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      debugMsgC(sProcName, "\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bSuspendRequested=" + strB(\bSuspendRequested))
      If (\nThreadState >= #SCS_THREAD_STATE_ACTIVE) And (\nThreadState < #SCS_THREAD_STATE_SUSPENDED)
        \bSuspendRequested = #True
        ; debugMsg(sProcName, "\bSuspendRequested=" + StrB(\bSuspendRequested))
        THR_waitForAThreadToSuspend(nThreadIndex, nDelayTime, nTimeOut)
      EndIf
      nThreadState = \nThreadState
    Else
      nThreadState = #SCS_THREAD_STATE_NOT_CREATED
    EndIf
  EndWith
  
  debugMsgC(sProcName, #SCS_END + ", returning nThreadState=" + THR_decodeThreadState(nThreadState))
  ProcedureReturn nThreadState
  
EndProcedure

Procedure THR_waitForAThreadToBeCreated(nThreadIndex, nTimeOut=1000)
  PROCNAMECT(nThreadIndex)
  Protected qInitialTime.q
  
  debugMsg(sProcName, #SCS_START + ", nTimeOut=" + nTimeOut)
  
  With gaThread(nThreadIndex)
    debugMsg(sProcName, "(a) \bThreadCreated=" + strB(\bThreadCreated) + ", \nThreadState=" + THR_decodeThreadState(\nThreadState))
    If \bThreadCreated = #False Or \nThreadState = #SCS_THREAD_STATE_NOT_CREATED
      qInitialTime = ElapsedMilliseconds()
      While ElapsedMilliseconds() - qInitialTime < nTimeOut
        If \bThreadCreated And \nThreadState <> #SCS_THREAD_STATE_NOT_CREATED
          Break
        EndIf
        Delay(50)
      Wend
    EndIf
    If \bThreadCreated = #False Or \nThreadState = #SCS_THREAD_STATE_NOT_CREATED
      debugMsg(sProcName, "Timed out. qInitialTime=" + traceTime(qInitialTime) + ", nTimeOut=" + nTimeOut)
    EndIf
    debugMsg(sProcName, "(z) \bThreadCreated=" + strB(\bThreadCreated) + ", \nThreadState=" + THR_decodeThreadState(\nThreadState))
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure THR_waitForAThreadToStop(nThreadIndex, nTimeOut=1000, bThrowAwayEvents=#False)
  PROCNAMECT(nThreadIndex)
  Protected nThreadState, qInitialTime.q, nWaitThreadResult
  Protected bStopRequested, nIsThreadResult
  
  setTraceLogging(nThreadIndex)
  
  ; debugMsgC(sProcName, #SCS_START + ", nTimeOut=" + nTimeOut) ; + ", bThrowAwayEvents=" + strB(bThrowAwayEvents))
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      If \nThreadState <> #SCS_THREAD_STATE_STOPPED
        \bStopRequested = #True
        ; debugMsg(sProcName, "\bStopRequested=" + strB(\bStopRequested))
      EndIf
      bStopRequested = \bStopRequested
      
      If bStopRequested
        qInitialTime = ElapsedMilliseconds()
        While (ElapsedMilliseconds() - qInitialTime) < nTimeOut
          Delay(50) ; WaitWindowEvent() can only be called from the main thread.
                    ; Also, WaitWindowEvent cannot be called from a 'binded' event callback, which can occur if PostEvent() is called from #WM_RBUTTONDOWN
          If (\nThreadState = #SCS_THREAD_STATE_STOPPED) Or (\bStopRequested = #False)
            Break
          EndIf
        Wend
      EndIf
      
      nIsThreadResult = IsThread(\hThread)
      nThreadState = \nThreadState
      bStopRequested = \bStopRequested
      
      ; debugMsgC(sProcName, #SCS_END + ", nIsThreadResult=" + nIsThreadResult + ", nThreadState=" + THR_decodeThreadState(nThreadState) + ", bStopRequested=" + strB(bStopRequested))
      
    Else
      debugMsg(sProcName, #SCS_END + ", \bThreadCreated=#False")
      
    EndIf
  EndWith
  
EndProcedure

Procedure THR_waitForAThreadToSuspend(nThreadIndex, nDelayTime=100, nTimeOut=6000)
  PROCNAMECT(nThreadIndex)
  Protected nThreadState, qInitialTime.q, nWaitThreadResult
  Protected bSuspendRequested, nIsThreadResult
  
  setTraceLogging(nThreadIndex)
  
  ; debugMsgC(sProcName, #SCS_START + ", nDelayTime=" + nDelayTime + ", nTimeOut=" + nTimeOut)
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      If \nThreadState <> #SCS_THREAD_STATE_SUSPENDED
        \bSuspendRequested = #True
        ; debugMsg(sProcName, "\bSuspendRequested=" + StrB(\bSuspendRequested))
      EndIf
      bSuspendRequested = \bSuspendRequested
      
      If bSuspendRequested
        qInitialTime = ElapsedMilliseconds()
        While (ElapsedMilliseconds() - qInitialTime) < nTimeOut
          Delay(nDelayTime)   ; WaitWindowEvent() can only be called from the main thread
                              ; Also, WaitWindowEvent cannot be called from a 'binded' event callback, which can occur if PostEvent() is called from #WM_RBUTTONDOWN
          If (\nThreadState = #SCS_THREAD_STATE_SUSPENDED) Or (\bSuspendRequested = #False)
            Break
          EndIf
        Wend
      EndIf
      
      nIsThreadResult = IsThread(\hThread)
      nThreadState = \nThreadState
      bSuspendRequested = \bSuspendRequested
      
      ; debugMsgC(sProcName, #SCS_END + ", nIsThreadResult=" + nIsThreadResult + ", nThreadState=" + THR_decodeThreadState(nThreadState) + ", bSuspendRequested=" + strB(bSuspendRequested))
      
    Else
      debugMsg(sProcName, #SCS_END + ", \bThreadCreated=#False")
      
    EndIf
  EndWith
  
EndProcedure

Procedure THR_getThreadState(nThreadIndex)
  Protected nThreadState
  
  With gaThread(nThreadIndex)
    If \bThreadCreated
      nThreadState = \nThreadState
    Else
      nThreadState = #SCS_THREAD_STATE_NOT_CREATED
    EndIf
  EndWith
  
  ProcedureReturn nThreadState
  
EndProcedure

Procedure.s THR_buildThreadProcName(pProcName.s, nThreadIndex)
  ProcedureReturn pProcName + "[" + THR_decodeThreadIndex(nThreadIndex) + "]"
EndProcedure

Procedure THR_checkForceOpenNextCues()
  PROCNAMEC()
  Protected bForceOpenNextCues
  Protected i, j, k
  Protected i2, j2, k2
  
  For i = 1 To gnLastCue
    If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If (aSub(j)\bSubTypeHasAuds) And (aSub(j)\bSubEnabled)
          k = aSub(j)\nFirstPlayIndex
          While k >= 0
            With aAud(k)
              Select \nAudState
                Case #SCS_CUE_PLAYING, #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_OUT, #SCS_CUE_TRANS_MIXING_OUT
                  k2 = \nNextPlayIndex
                  If k2 >= 0
                    If aAud(k2)\nAudState = #SCS_CUE_NOT_LOADED
                      bForceOpenNextCues = #True
                      debugMsg(sProcName, "bForceOpenNextCues=#True, k=" + getAudLabel(k) + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState) + ", aAud(" + getAudLabel(k2) + ")\nAudState=" + decodeCueState(aAud(k2)\nAudState))
                      Break
                    EndIf
                  Else
                    ; on last play aud for this sub so check next sub
                    j2 = aSub(j)\nNextSubIndex
                    If j2 >= 0
                      If aSub(j2)\nSubState = #SCS_CUE_NOT_LOADED
                        bForceOpenNextCues = #True
                        debugMsg(sProcName, "bForceOpenNextCues=#True, j=" + getSubLabel(j) + ", aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState) + ", aSub(" + getSubLabel(j2) + ")\nSubState=" + decodeCueState(aSub(j2)\nSubState))
                        Break
                      EndIf
                    Else
                      ; on last sub for this cue so check other cues
                      For i2 = (i+1) To gnLastCue
                        If (aCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO) Or (aCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
                          If aCue(i2)\nAutoActCuePtr = i
                            If aCue(i2)\nCueState = #SCS_CUE_NOT_LOADED
                              bForceOpenNextCues = #True
                              debugMsg(sProcName, "bForceOpenNextCues=#True, i=" + getCueLabel(i) + ", aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState) + ", aCue(" + getCueLabel(i2) + ")\nCueState=" + decodeCueState(aCue(i2)\nCueState))
                              Break
                            EndIf
                          EndIf
                        EndIf
                      Next i2
                    EndIf
                  EndIf
              EndSelect
              k = \nNextPlayIndex
            EndWith
          Wend
        EndIf
        If bForceOpenNextCues
          Break
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
      If bForceOpenNextCues
        Break
      EndIf
    EndIf
  Next i
  
  ProcedureReturn bForceOpenNextCues
EndProcedure

;- Control Thread
Procedure THR_runControlThread(*nThreadValue)
  PROCNAMEC()
  Protected i, j, k, k2, nPLAudCounter, n
  Protected sTmp.s, sTmp2.s
  Protected bCheckThisCue
  Protected bSubStartedInEditor ; added 3Feb2020 11.8.2.2af
  Protected nNetworkStateNow
  Protected nReply
  Protected nActiveWindow
  Protected bFadingCueFound
  Protected bForceOpenNextCues
  Protected qLastVUTime.q
  Protected sMsg.s
  Protected bOpenNextCues
  Protected nNodeKey
  Protected bIgnoringAuds
  Protected nPrevActiveWindow
  Protected nCuePtr
  Protected qTimeOfLastWakeup.q
  Protected nThisAudState
  Protected nCheckFocusInterval, nCheckPauseAllInterval
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  Protected nDayNow
  CompilerIf #c_next_day_in_resetTOD
    Protected nResetCount
  CompilerEndIf
  
  setThreadNo(#SCS_THREAD_CONTROL)  ; preferably set this before calling debugMsg()
  
  debugMsg(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_CONTROL)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  qLastVUTime = ElapsedMilliseconds() - 1000 ; set qLastVUTime at a meaningful time
  
  Repeat
    doThreadLoopStart(#SCS_THREAD_CONTROL, 100) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    If gbInSamProcess Or gbAdding Or gbInPaste Or grM2T\bProcessingApplyMoveToTime Or gbInCalcCueStartValues
      If grMain\bControlThreadWaiting = #False
        grMain\bControlThreadWaiting = #True
        grMain\qControlThreadWaitingTimeTrue = ElapsedMilliseconds()
      EndIf
      Delay(2)
      Continue
    Else
      If grMain\bControlThreadWaiting
        grMain\bControlThreadWaiting = #False
        grMain\qControlThreadWaitingTimeFalse = ElapsedMilliseconds()
      EndIf
    EndIf
    
    gnLabel = 1000
    ; Added 21Oct2023 11.10.0cn to prevent excessive logging of mutex waiting messages if the message requester (called from scsMessageRequester()) is active
    If gbInMessageRequester Or gbInOptionRequester ; Added gbInOptionRequester 17Nov2023 11.10.0-b03
      Delay(gnControlThreadDelay)
      Continue
    EndIf
    ; End added 21Oct2023 11.10.0cn
    
    ; Added 7Nov2023 11.10.0cq following email from Octavio Alcober where activating Stop All immediately after opending the cue file caused some cues to play
    If gbStoppingEverything
      Delay(gnControlThreadDelay)
      Continue
    EndIf
    ; End added 7Nov2023 11.10.0cq
    
    LockCueListMutex(23632)
    
    gbInCueStatusChecks = #True
    
    ; initialise protected variables
    bFadingCueFound = #False
    
    gqTimeNow = ElapsedMilliseconds()
    nDayNow = Day(Date())
    
    gnLabel = 2800
;     If (gqTimeNow - qLastVUTime) >= 20
;       If gbClosingDown = #False
        If gbVUDisplayRunning
          gbRefreshVUDisplay = #True
        EndIf
        ; debugMsg(sProcName, "gbRefreshVUDisplay=" + strB(gbRefreshVUDisplay) + ", gbVUDisplayRunning=" + strB(gbVUDisplayRunning) + ", qLastVUTime=" + traceTime(qLastVUTime))
;       EndIf
;       qLastVUTime = gqTimeNow
;     Else
;       gbRefreshVUDisplay = #False
;     EndIf
    
    If gbUseSMS ; SM-S
      getSMSCurrInfo(gbRefreshVUDisplay)
    EndIf
    
    If gbInMessageRequester = #False
      nActiveWindow = GetActiveWindow()
      If nActiveWindow = #WED
        gbEditHasFocus = #True
      Else
        gbEditHasFocus = #False
      EndIf
      If nActiveWindow <> nPrevActiveWindow
        ; debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(nActiveWindow) + ", nPrevActiveWindow=" + decodeWindow(nPrevActiveWindow) + ", gbEditHasFocus=" + strB(gbEditHasFocus))
        nPrevActiveWindow = nActiveWindow
      EndIf
    EndIf
    
    gnLabel = 3000
    If gbGoToProdPropDevices = #False
      For i = 1 To gnLastCue
        gnLabel = 300000 + i
        bCheckThisCue = #False
        ; added 3Feb2020 11.8.2.2af
        bSubStartedInEditor = #False
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bStartedInEditor
            bSubStartedInEditor = #True
            Break
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        ; end added 3Feb2020 11.8.2.2af
        
        If aCue(i)\nCueState <> #SCS_CUE_IGNORED
          If aCue(i)\bCueCurrentlyEnabled
            If aCue(i)\nCueState <> #SCS_CUE_COMPLETED
              bCheckThisCue = #True
            Else
              j = aCue(i)\nFirstSubIndex
              While (j >= 0) And (bCheckThisCue = #False)
                If (aSub(j)\bStartedInEditor) And (aSub(j)\bSubEnabled)
                  bCheckThisCue = #True
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            EndIf
          ; added 3Feb2020 11.8.2.2af
          ElseIf bSubStartedInEditor
            If aCue(i)\nCueState <> #SCS_CUE_COMPLETED
              bCheckThisCue = #True
            EndIf
          ; end added 3Feb2020 11.8.2.2af
          EndIf
        EndIf
        
        If bCheckThisCue
          If aCue(i)\qMainThreadRequestTime > 0
            If (ElapsedMilliseconds() - aCue(i)\qMainThreadRequestTime) < 500
              ; a main-thread request was added less than 0.5 second ago, so suspend checking this cue for now
              bCheckThisCue = #False
            Else
              ; the main-thread request was added more than 0.5 second ago, so cancel the suspension and check the cue
              debugMsg(sProcName, "cancelling main thread request time - aCue(" + getCueLabel(i) + ")\qMainThreadRequestTime=" + traceTime(aCue(i)\qMainThreadRequestTime))
              aCue(i)\qMainThreadRequestTime = 0
            EndIf
          EndIf
        EndIf
        
        gnLabel = 400000 + i
        If bCheckThisCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            gnLabel = 500000 + j
            If aSub(j)\bSubEnabled Or aSub(j)\bStartedInEditor ; mod 15Jan2020 11.8.2.2ab - added "Or aSub(j)\bStartedInEditor" so that progress slider in editor is updated
              If aSub(j)\nSubState <> #SCS_CUE_COMPLETED  
                If (aSub(j)\bSubTypeF) Or (aSub(j)\bSubTypeI)   ; subtypes F or I
                  k = aSub(j)\nFirstAudIndex
                  gnLabel = 510000 + k
                  If k >= 0
                    SC__RunStatusCheck(i, j, k, #PB_Compiler_Line)
                    If (aAud(k)\bAudTypeF) And (aAud(k)\nMaxCueMarker >= 0)
                      checkNextCueMarker(k)
                    EndIf
                  EndIf
                  gnLabel = 520000 + k
                  Select aSub(j)\nSubState
                    Case #SCS_CUE_FADING_IN, #SCS_CUE_FADING_OUT
                      bFadingCueFound = #True
                  EndSelect
                  
                ElseIf aSub(j)\bSubTypeAorP  ; subtypes A or P
                  ; Note added 29Apr2024 11.10.2cf following tests of cue markers in video cues by William Rohmer:
                  ; Do NOT check for and call checkNextCueMarker() for video files as this is now handled exclusively by eventTVGOnFrameProgress2() and MarkerTVGSyncProc()
;                   ; Added 23Sep2023 11.10.0
;                   If aSub(j)\bSubTypeA
;                     k = aSub(j)\nFirstAudIndex
;                     While k >= 0
;                       If aAud(k)\nMaxCueMarker >= 0
;                         ; debugMsg(sProcName, "calling checkNextCueMarker(" + getAudLabel(k) + ")")
;                         checkNextCueMarker(k)
;                       EndIf
;                       k = aAud(k)\nNextAudIndex
;                     Wend
;                   EndIf
;                   ; End added 23Sep2023 11.10.0
                  If (aSub(j)\bPLTerminating = #False) Or (gbFadingEverything) ; Added "Or (gbFadingEverything)" 7Jun2021 11.8.5ae
                    k = aSub(j)\nCurrPlayIndex
                    If k >= 0
                      k2 = aAud(k)\nPrevPlayIndex
                      If (k2 = -1) And (getPLRepeatActive(j))
                        k2 = aSub(j)\nLastPlayIndex
                      EndIf
                      If k2 >= 0
                        nThisAudState = aAud(k2)\nAudState
                        If (nThisAudState >= #SCS_CUE_FADING_IN) And (nThisAudState <= #SCS_CUE_FADING_OUT)
                          k = k2
                        EndIf
                      EndIf
                    EndIf
                    nPLAudCounter = 0
                    ; check status for up to two currently running files
                    While (k >= 0) And (nPLAudCounter < 2)
                      With aAud(k)
                        gnLabel = 530000 + k
                        If \nAudState < #SCS_CUE_COMPLETED
                          ; debugMsg(sProcName, "--- calling SC__RunStatusCheck(" + i + ", " + j + ", " + getAudLabel(k) + ", #PB_Compiler_Line), aSub(" + j + ")\nCurrPlayIndex=" + getAudLabel(aSub(j)\nCurrPlayIndex))
                          SC__RunStatusCheck(i, j, k, #PB_Compiler_Line)
                          Select \nAudState
                            Case #SCS_CUE_FADING_IN, #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_IN, #SCS_CUE_TRANS_FADING_OUT, #SCS_CUE_TRANS_MIXING_OUT
                              bFadingCueFound = #True
                          EndSelect
                        EndIf
                        gnLabel = 540000 + k
                        nPLAudCounter + 1
                        k = \nNextPlayIndex
                        If k = -1 
                          If (getPLRepeatActive(j)) And (aSub(j)\nAudCount > 1)
                            k = aSub(j)\nFirstPlayIndex
                          EndIf
                        EndIf
                      EndWith
                    Wend
                    
                  ElseIf (aSub(j)\bHibernating = #False) Or (aSub(j)\bFadingPreHibernating)
                    bIgnoringAuds = #True
                    k = aSub(j)\nFirstPlayIndex
                    While k >= 0
                      With aAud(k)
                        gnLabel = 550000 + k
                        If \nAudState < #SCS_CUE_COMPLETED
                          ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
                          If \bIgnoreInStatusCheck = #False
                            bIgnoringAuds = #False
                            SC__RunStatusCheck(i, j, k, #PB_Compiler_Line)
                          Else
                            If \bIgnoreInStatusCheckLogged = #False
                              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bIgnoreInStatusCheck=" + strB(\bIgnoreInStatusCheck))
                              \bIgnoreInStatusCheckLogged = #True
                            EndIf
                          EndIf
                          Select \nAudState
                            Case #SCS_CUE_FADING_IN, #SCS_CUE_FADING_OUT, #SCS_CUE_TRANS_FADING_IN, #SCS_CUE_TRANS_FADING_OUT, #SCS_CUE_TRANS_MIXING_OUT
                              bFadingCueFound = #True
                          EndSelect
                        EndIf
                        gnLabel = 560000 + k
                        k = \nNextPlayIndex
                      EndWith
                    Wend
                    If bIgnoringAuds = #False
                      ; debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
                      setCueState(i)
                    EndIf
                    If aSub(j)\bFadingPreHibernating
                      If bFadingCueFound = #False
                        aSub(j)\bFadingPreHibernating = #False
                      EndIf
                    EndIf
                  EndIf
                  
                  Select aSub(j)\nSubState
                    Case #SCS_CUE_FADING_IN, #SCS_CUE_FADING_OUT
                      bFadingCueFound = #True
                  EndSelect
                  
                ElseIf aSub(j)\bSubTypeM  ; bSubTypeM
                  k = aSub(j)\nFirstAudIndex  ; may be -1
                  SC__RunStatusCheck(i, j, k, #PB_Compiler_Line)
                  
                Else ; subtypes B, C, D, G, K, L, N, R, S, T, U
                  ; debugMsg(sProcName, "calling SC__RunStatusCheck(" + getCueLabel(i) + ", " + getSubLabel(j) + ", -1, #PB_Compiler_Line)")
                  SC__RunStatusCheck(i, j, -1, #PB_Compiler_Line)
                  
                EndIf
                
              Else  ; aSub(j)\nSubState = #SCS_CUE_COMPLETED
                If (aSub(j)\bSubTypeL) And (aSub(j)\bTestingLevelChange)
                  SC__RunStatusCheck(i, j, -1, #PB_Compiler_Line)
                EndIf
                
              EndIf
            EndIf ; EndIf aSub(j)\bSubEnabled
            gnLabel = 900000 + j
            j = aSub(j)\nNextSubIndex
          Wend
          gnLabel = 3456
          If aCue(i)\nCueState = #SCS_CUE_COUNTDOWN_TO_START
            ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", calling updateGrid(" + getCueLabel(i) + ")")
            updateGrid(i)
          EndIf
          gnLabel = 3459
        EndIf
      Next i
    EndIf ; EndIf gbGoToProdPropDevices = #False
    
    gnLabel = 5990
    ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", gbUseSMS=" + strB(gbUseSMS) + ", gnMaxSMSSyncPoint=" + gnMaxSMSSyncPoint + ", gbInReposAuds=" + strB(gbInReposAuds))
    If gbUseSMS
      If gnMaxSMSSyncPoint >= 0
        If (gbInReposAuds = #False) And (gbInReleaseAudLoop = #False)
          checkSMSSyncPoints()
        Else
          debugMsg(sProcName, "ignoring checkSMSSyncPoints() because gbInReposAuds=" + strB(gbInReposAuds) + ", gbInReleaseAudLoop=" + strB(gbInReleaseAudLoop))
        EndIf
      EndIf
    EndIf
    
    gqMainThreadRequest | #SCS_MTH_UPDATE_DISP_PANELS
    ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", gqMainThreadRequest | #SCS_MTH_UPDATE_DISP_PANELS")
    
    gnLabel = 7000
    If gbDisplayStatus
      ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", gbDisplayStatus=" + strB(gbDisplayStatus) + ", gqStatusDisplayed=" + gqStatusDisplayed + ", gqTimeNow=" + gqTimeNow)
      If (gqTimeNow - gqStatusDisplayed) > #SCS_STATUS_DISPLAY_TIME
        gqMainThreadRequest | #SCS_MTH_CLEAR_STATUS_FIELD
      EndIf
    EndIf
    
    gnLabel = 7100
    If gnPlayWhenReadyAudPtr > 0
      If aAud(gnPlayWhenReadyAudPtr)\nAudState >= #SCS_CUE_READY
        debugMsg(sProcName, "calling playAud(" + getAudLabel(gnPlayWhenReadyAudPtr) + ")")
        playAud(gnPlayWhenReadyAudPtr)
        gnPlayWhenReadyAudPtr = -1
        debugMsg(sProcName, "gnPlayWhenReadyAudPtr=" + getAudLabel(gnPlayWhenReadyAudPtr))
      EndIf
    EndIf
    
    gnLabel = 7200
    If bFadingCueFound
      If gnCallOpenNextCues > 0
        bForceOpenNextCues = THR_checkForceOpenNextCues()
      EndIf
    EndIf
    
    If (bForceOpenNextCues) Or ((bFadingCueFound = #False) And (gbPictureBlending = #False))
      
      If gbChangeTimeProfile
        gnLabel = 7205
        WTP_changeTimeProfile()
        gnLabel = 7206
      EndIf
      
      gnLabel = 7210
      If gnCallOpenNextCues > 0
        ; debugMsg(sProcName, "gnCallOpenNextCues=" + getCueLabel(gnCallOpenNextCues) + ", gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
        If gbGoToProdPropDevices = #False
          bOpenNextCues = #True
          
          ; added 18May2018 11.7.1an following info from Kevin Washburn where Q20 was opened when Q39 was started
          CompilerIf 1=2
            ; Blocked out 3Aug2018 11.7.1.1 following investigation of a problem reported by Richard Borsey 24Jul2018 where the second file in a gapless
            ; stream didn't play, which eventually was tracked down to the cue not being fully opened due to the code in this 18May2018 11.7.1an 'fix'.
            ; On retesting Kevin Washburn's cues, the problem of Q20 being opened when Q39 was started no longer exists (even without the code in this 'fix'),
            ; and that is probably because a later mod - also related to Kevin Washburn's requirements - added 'cue brackets'.
            ; As Q20 was in a different cue bracket to Q39, Q20 was (correctly) NOT opened on starting Q39.
            ; So it is now deemed safe (3Aug2018 11.7.1.1) to block out this 11.7.1an 'fix'.
            If bOpenNextCues
              If grProd\bPreLoadNextManualOnly
                If getFirstPlayingCue() < 0
                  bOpenNextCues = #False
                EndIf
              EndIf
            EndIf
          CompilerEndIf
          ; end added 18May2018 11.7.1an
          
          If bOpenNextCues
            nCuePtr = gnCallOpenNextCues
            If nCuePtr = 1
              If grProd\nRunMode = #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND
                debugMsg(sProcName, "grProd\nRunMode=" + grProd\nRunMode + ", gnCueToGo=" + gnCueToGo + "(" + getCueLabel(gnCueToGo) + ")")
                If gnCueToGo > 0
                  nCuePtr = gnCueToGo
                EndIf
              EndIf
            EndIf
            gnLabel = 7221
            debugMsg(sProcName, "calling samAddRequest(SCS_SAM_OPEN_NEXT_CUES, " + nCuePtr + "(" + getCueLabel(nCuePtr) + "))")
            samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, nCuePtr)
            gnLabel = 7222
            gnCallOpenNextCues = 0
            ; debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
          EndIf
        EndIf
      EndIf
      
      gnLabel = 7230
      If gbCallPopulateGrid
        gbCallPopulateGrid = #False
        gnLabel = 7231
        samAddRequest(#SCS_SAM_POPULATE_GRID)
        gnLabel = 7232
      EndIf
      
    EndIf
    
    gnLabel = 7240
    If gbCallSetCueToGo
      gbCallSetCueToGo = #False
      ; setCueToGo()
      ; setCueToGo() must be called from the main thread as the procedure may call loadOneCue(), and some cue types must be loaded from the main thread.
      ; also, delay this process at least one cycle so that a cue that starts after the end of another cue does not get ignored if the cue that has ended
      ; has just been re-loaded and so has a state of 'ready' or 'not loaded' instead of 'completed'. this can occur with non-linear run modes, as
      ; found in bug reported by Jens Jorgensen re SCS 11.5.0 vs 11.4.2.3.
      ; samAddRequest(#SCS_SAM_SET_CUE_TO_GO, #True, 0, -1, "", ElapsedMilliseconds()+200)
      samAddRequest(#SCS_SAM_SET_CUE_TO_GO, #True, 0, -1)
    EndIf
    
    ; process SGB before LDP as LDP relies on gnCueToGo which is set by SGB
    
    gnLabel = 7250
    If gbCallSetGoButton
      ; debugMsg(sProcName, "setting gbCallSetGoButton = #False")
      gbCallSetGoButton = #False
      samAddRequest(#SCS_SAM_SET_GO_BUTTON)
    EndIf
    
    gnLabel = 7260
    If gbCallLoadDispPanels
      gbCallLoadDispPanels = #False
      gbCallRefreshDispPanel = #False ; cancel any request to refresh a display panel as we are (re)loading them all
      ; debugMsg(sProcName, "gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
      samAddRequest(#SCS_SAM_LOAD_CUE_PANELS, 0, 0, 0, "", ElapsedMilliseconds()+500)
    EndIf
    
    gnLabel = 7270
    If gbCallRefreshDispPanel
      gbCallRefreshDispPanel = #False
      gqMainThreadRequest | #SCS_MTH_REFRESH_DISP_PANEL
    EndIf
    
    gnLabel = 7280
    If gbCallReloadDispPanel
      gbCallReloadDispPanel = #False
      gqMainThreadRequest | #SCS_MTH_RELOAD_DISP_PANEL
    EndIf
    
    gnLabel = 7300
    If gbCallLoadGridRowsWhereRequested
      gbCallLoadGridRowsWhereRequested = #False
      samAddRequest(#SCS_SAM_LOAD_GRID_ROW, -1, 0, 0, "", ElapsedMilliseconds()+500)
    EndIf
    
    gnLabel = 7400
    If gbCallSetNavigateButtons
      gbCallSetNavigateButtons = #False
      samAddRequest(#SCS_SAM_SET_NAVIGATE_BUTTONS)
    EndIf
    
    gnLabel = 7500
    If gbCallCheckUsingPlaybackRateChangeOnly
      gbCallCheckUsingPlaybackRateChangeOnly = #False
      samAddRequest(#SCS_SAM_CHECK_USING_PLAYBACK_RATE_CHANGE_ONLY)
    EndIf
    
    If grProd\nVisualWarningTime <> grProdDef\nVisualWarningTime
      gqMainThreadRequest | #SCS_MTH_DISP_VIS_WARN_IF_REQD
    EndIf
    
    gnLabel = 7600
    If gbMainSaveEnabled
      If (grMain\nCasRequestsWaiting = 0) And (grMain\nSamRequestsWaiting = 0)
        If (gqTimeNow - gqLastRecoveryTime) > 5000
          ; checks every 5 seconds if a recovery file is to be written
          writeXMLRecoveryFile()
        EndIf
      EndIf
    EndIf
    
    gnLabel = 7700
    If gnFreeStreamCount > 0
      If bFadingCueFound = #False
        ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", gnFreeStreamCount=" + gnFreeStreamCount + ", calling freeStreams()")
        freeStreams()
      EndIf
    EndIf
    
    gnLabel = 7800
    nCheckFocusInterval = gqTimeNow - grMain\qCheckFocusTime
    If nCheckFocusInterval >= 1000
      checkMainHasFocus(gnLabel)
      grMain\qCheckFocusTime = gqTimeNow
      CompilerIf 1=2
        ; blocked out 1Nov2018 11.8.0am as checkDevicesStillAvailable() seems to take more than 20ms (based on the time the mutex was locked)
        ; and this could be affecting DMX processing time (running chase test for Octavio Alcober)
        ; need to revist this later - maybe pass this to some low priority thread?
        If (gqTimeNow - grMain\qDeviceCheckTime) > 5000
          If gbUseBASS  ; checkDevicesStillAvailable() not applicable for SM-S as we cannot (easily?) check if an ASIO device has been disconnected
            If bFadingCueFound = #False
              gnLabel = 7830
              checkDevicesStillAvailable()
              gnLabel = 7840
            EndIf
          EndIf
          grMain\qDeviceCheckTime = gqTimeNow
        EndIf
      CompilerEndIf
    EndIf
    
    gnLabel = 7850
    If gbGlobalPause Or gbPauseAllDisplayed
      nCheckPauseAllInterval = gqTimeNow - grMain\qCheckPauseAllTime
      If nCheckPauseAllInterval >= 1000
        checkPauseAllActive(gnLabel)
        grMain\qCheckPauseAllTime = gqTimeNow
      EndIf
    EndIf
    
    gnLabel = 7900
    If (gqTimeNow - gqTimeDiskActive) > 300000
      ; no disk activity for 5 minutes (300 sec)
      stayAwake("cue to go: " + gnCueToGo)
      gqTimeDiskActive = gqTimeNow
    EndIf
    
    If gbCheckForResetTOD
      CompilerIf #c_next_day_in_resetTOD
        If nResetCount = 0
          If getTimeOfDayInSeconds() >= grProd\nResetTOD
            gnLastResetDay = nDayNow + 1
            debugMsg(sProcName, "time to reset TBC's and cue list")
            gbResetTOD = #True
            nResetCount + 1
          EndIf
        EndIf
      CompilerElse
        If nDayNow <> gnLastResetDay
          If getTimeOfDayInSeconds() >= grProd\nResetTOD
            gnLastResetDay = nDayNow
            debugMsg(sProcName, "time to reset TBC's and cue list")
            gbResetTOD = #True
          EndIf
        EndIf
      CompilerEndIf
    EndIf
    
    If gnClickThisNode >= 0
      nNodeKey = gnClickThisNode
      gnClickThisNode = -1
      WED_publicNodeClick(nNodeKey)
      gbSkipValidation = #False
    EndIf
    
    If gbSetEditorWindowActive
      If (gbEditing) And (GetActiveWindow() <> #WED)  ; added "And (GetActiveWindow() <> #WED)" 18Aug2017 11.7.0 to save unnecessary sam requests
        samAddRequest(#SCS_SAM_SET_EDIT_WINDOW_ACTIVE)
      EndIf
      gbSetEditorWindowActive = #False
    EndIf
    
    gbInCueStatusChecks = #False
    
    gnLabel = 9490
    ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", calling UnlockCueListMutex()")
    UnlockCueListMutex()
    ; debugMsg(sProcName, "gnLabel=" + gnLabel + ", CueListMutex unlocked")
    
    gnLabel = 9500
    ; debugMsg(sProcName, "gnLabel=" + gnLabel)
    
    If nDayNow <> gnCurrLogDay
      If bFadingCueFound = #False And gbPictureBlending = #False
        debugMsg(sProcName, "end of day: closing log file")
        closeLogFile()
        gsDebugFileDateTime = FormatDate("%yyyy%mm%dd_%hh%ii%ss", Date())
        openLogFile()
      EndIf
    EndIf
    
    ; yield to other processes before looping back to the start
    ; debugMsg(sProcName, "Delay(" + gnControlThreadDelay + ")")
    Delay(gnControlThreadDelay)
    
    gnLabel = 9600
    ; debugMsg(sProcName, "gnLabel=" + gnLabel)
  ForEver
  
  gnLabel = 9900
  ; exiting this procedure will stop the thread
  gaThread(#SCS_THREAD_CONTROL)\nThreadState = #SCS_THREAD_STATE_STOPPED
  ; gbControlThreadRunning=#False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

;- Blender Thread
Procedure THR_runBlenderThread(*nThreadValue)
  PROCNAMEC()
  Protected bLockedMutex
  Protected nBlendFactor, nBlendPosition, bBlending, bFading
  Protected n
  Protected nAudPtr, nSubPtr
  Protected nThreadState, bSuspendRequested, nLoopAction
  
  setThreadNo(#SCS_THREAD_BLENDER)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_BLENDER)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    If (gbClosingDown) Or ((gbStoppingEverything) And (gbFadingEverything = #False))
      ; quit blending
      debugMsg(sProcName, "quit because gbClosingDown=" + strB(gbClosingDown) + ", gbStoppingEverything=" + strB(gbStoppingEverything))
      Break
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_BLENDER) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    bBlending = #False
    
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
      ; debugMsg(sProcName, "grTVGControl\nFadeAudCount=" + grTVGControl\nFadeAudCount)
      For n = 0 To (grTVGControl\nFadeAudCount-1)
        ; debugMsg(sProcName, "grTVGControl\nFadeAudPtr(" + n + ")=" + getAudLabel(grTVGControl\nFadeAudPtr(n)))
        nAudPtr = grTVGControl\nFadeAudPtr(n)
        If nAudPtr >= 0
          bFading = doAudFade(nAudPtr)
          ; debugMsg(sProcName, "doAudFade(" + getAudLabel(nAudPtr) + ") returned " + strB(bFading))
          If bFading
            bBlending = #True
            CompilerIf 1=2 ; Blocked out 16Oct2024 11.10.6aq
              ; Added 7Jun2021 11.8.5ae
              If gbFadingEverything
                SC_SubTypeA(nAudPtr, -1)
              EndIf
              ; End added 7Jun2021 11.8.5ae
            CompilerEndIf
          EndIf
        EndIf
      Next n
    EndIf
    
    For n = #SCS_VID_PIC_TARGET_P To gnMaxVidPicTargetSetup
      ; See comments in WMN_processAnimatedImageTimer() regarding grMMedia\bInBlendPictures and grMMedia\bAnimationWaiting
      While grMMedia\bAnimationWaiting
        Delay(2)
      Wend
      With grVidPicTarget(n)
        ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\bInFadeStartProcess=" + strB(\bInFadeStartProcess) + ", \nImage2=" + decodeHandle(\nImage2))
        If \bInFadeStartProcess = #False
          \bInBlendThreadProcess = #True
          If \nImage2 <> 0
            grMMedia\bInBlendPictures = #True ; set this BEFORE locking the mutex - checked by WMN_processAnimatedImageTimer()
            LockImageMutex(225)
            nBlendPosition = ElapsedMilliseconds() - \qBlendStartTime
            If nBlendPosition < \nBlendTime
              nBlendFactor = (nBlendPosition * 255) / \nBlendTime
              bBlending = #True
            Else
              nBlendFactor = 255
            EndIf
            ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nBlendTime=" + \nBlendTime + ", \qBlendStartTime=" + traceTime(\qBlendStartTime) + ", nBlendPosition=" + nBlendPosition + ", nBlendFactor=" + nBlendFactor)
            blendPictures(\nVidPicTarget, nBlendFactor)
            If nBlendFactor >= 255
              \nImage2 = 0  ; indicates end of this blend (must set this AFTER calling blendPictures())
              If \nAudPtr2 >= 0
                If aAud(\nAudPtr2)\nAnimatedImageTimer
                  aAud(\nAudPtr2)\bCancelAudAnimation = #True
                  debugMsg(sProcName, "aAud(" + getAudLabel(\nAudPtr2) + ")\bCancelAudAnimation=" + strB(aAud(\nAudPtr2)\bCancelAudAnimation))
                EndIf
              EndIf
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\bBlendingLogo=" + strB(\bBlendingLogo) +
                                  ", \nPrimaryImageNo=" + decodeHandle(\nPrimaryImageNo) +
                                  ", \nImage2=" + decodeHandle(\nImage2) +
                                  ", \nImage1=" + decodeHandle(\nImage1) +
                                  ", \nLogoImageNo=" + decodeHandle(\nLogoImageNo))
              If \bBlendingLogo
                \nPrimaryImageNo = \nLogoImageNo
                ; \nImage1 = \nPrimaryImageNo
                ; debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\nImage2=" + decodeHandle(\nImage2))
              Else
                If \nPrimaryAudPtr >= 0
                  aAud(\nPrimaryAudPtr)\bBlending = #False
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(\nPrimaryAudPtr) + ")\bBlending=" + strB(aAud(\nPrimaryAudPtr)\bBlending))
                EndIf
                If \nPrevPrimaryAudPtr >= 0
                  aAud(\nPrevPrimaryAudPtr)\bBlending = #False
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(\nPrevPrimaryAudPtr) + ")\bBlending=" + strB(aAud(\nPrevPrimaryAudPtr)\bBlending))
                EndIf
              EndIf
              If \nPrimaryImageNo = \nLogoImageNo
                \bLogoCurrentlyDisplayed = #True
                debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(n) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
              EndIf
            ElseIf \nPrimaryImageNo <> 0
              nBlendFactor = 255 - nBlendFactor
            EndIf
            UnlockImageMutex()
            grMMedia\bInBlendPictures = #False
          EndIf
          \bInBlendThreadProcess = #False
        EndIf
      EndWith
    Next n
    
    gbPictureBlending = bBlending
    
    If bBlending = #False
      If gbInFadeImage = #False ; gbInFadeImage added 10Aug2021 11.8.5rc3
        ; debugMsg(sProcName, "bBlending=False and gbInFadeImage=False, so calling THR_suspendAThread(#SCS_THREAD_BLENDER), grTVGControl\nFadeAudCount=" + grTVGControl\nFadeAudCount)
        THR_suspendAThread(#SCS_THREAD_BLENDER)
        gnCallOpenNextCues = 1
        ; debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
      Else
        ; debugMsg(sProcName, "gbInFadeImage=True")
      EndIf
    EndIf
    
    ; yield to other processes before looping back to the start
    Delay(2)
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_BLENDER)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_BLENDER)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- Slider File Loader Thread
Procedure THR_runSliderFileLoaderThread(*nThreadValue)
  PROCNAMEC()
  Protected bFileLoading, bWaitingForMainThread, bDeferringLoad
  Protected nSldPtr, h
  Protected nAudPtr, nFileDataPtr, nPrevPlayIndex
  Protected bLoadFromFileResult
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  Protected nFileScanMaxLength, nFileScanMaxLengthMS
  
  setThreadNo(#SCS_THREAD_SLIDER_FILE_LOADER)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    If gbClosingDown Or gbStoppingEverything Or grWIM\bImportingCues
      ; quit loading
      Break
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_SLIDER_FILE_LOADER) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      debugMsg(sProcName, "nLoopAction = #SCS_LOOP_ACTION_BREAK")
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      ; debugMsg(sProcName, "nLoopAction = #SCS_LOOP_ACTION_CONTINUE")
      Continue
    EndIf
    
    ; thread is active
    If grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase
      ; nb if grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase = #True then we are waiting on the main thread to call and complete SaveMG34SlicePeakAndMinArraysToTempDatabase(),
      ; because this means that the grMG4 SlicePeakAndMinArray is 'locked'
      ; debugMsg(sProcName, "grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase=#True")
      Delay(25)
    Else
      bFileLoading = #False
      bWaitingForMainThread = #False
      bDeferringLoad = #False
      
      For nSldPtr = 1 To ArraySize(gaSlider())
        If gbClosingDown Or gbStoppingEverything Or grWIM\bImportingCues Or gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP
          debugMsg(sProcName, "gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP=#True")
          Break 2 ; quit loading
        EndIf
        If grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase
          ; debugMsg(sProcName, "grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase=#True")
          bWaitingForMainThread = #True
          Break ; already loaded data for one slider - must wait for main thread to save that data to the database before processing any more
        EndIf
        With gaSlider(nSldPtr)
          ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bLoadFileRequest=" + strB(\bLoadFileRequest))
          If \bLoadFileRequest
            nAudPtr = \m_AudPtr
            CompilerIf #c_suspend_slider_file_loader_thread_when_auds_playing
              If anyAudPlaying() >= 0
                ; at least one audio file is currently playing, so defer this process, unless...
                ; this aud is playing, or if this aud is in a playlist and is the next aud to be played (ie the prevplayindex aud is curretnly playing)
                bDeferringLoad = #True
                ; added 21May2018 11.7.1aq
                If nAudPtr >= 0
                  If aAud(nAudPtr)\nAudState >= #SCS_CUE_FADING_IN And aAud(nAudPtr)\nAudState <= #SCS_CUE_FADING_OUT
                    bDeferringLoad = #False
                  ElseIf aAud(nAudPtr)\bAudTypeAorP
                    nPrevPlayIndex = aAud(nAudPtr)\nPrevPlayIndex
                    If nPrevPlayIndex >= 0
                      If aAud(nPrevPlayIndex)\nAudState >= #SCS_CUE_FADING_IN And aAud(nPrevPlayIndex)\nAudState <= #SCS_CUE_FADING_OUT
                        bDeferringLoad = #False
                      EndIf
                    EndIf
                  EndIf
                EndIf
                ; end added 21May2018 11.7.1aq
                If bDeferringLoad
                  Delay(90)
                  Break ; quit nSldPtr loop
                EndIf
              EndIf
            CompilerEndIf
            ; debugMsg(sProcName, "--------------------------------------------------------------------------")
            debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\sName=" + \sName + ", \bLoadFileRequest=" + strB(\bLoadFileRequest) +
                                ", \m_AudPtr=" + getAudLabel(\m_AudPtr) + ", \bRedrawSldAfterLoad=" + strB(\bRedrawSldAfterLoad))
            \bLoadFileRequest = #False
            If nAudPtr >= 0
              nFileDataPtr = aAud(nAudPtr)\nFileDataPtr
              If nFileDataPtr >= 0
                bFileLoading = #True
                If aAud(nAudPtr)\bAudTypeA
                  nFileScanMaxLength = grEditingOptions\nFileScanMaxLengthVideo
                  nFileScanMaxLengthMS = grEditingOptions\nFileScanMaxLengthVideoMS
                Else
                  nFileScanMaxLength = grEditingOptions\nFileScanMaxLengthAudio
                  nFileScanMaxLengthMS = grEditingOptions\nFileScanMaxLengthAudioMS
                EndIf
                If (nFileScanMaxLength < 0) Or (aAud(nAudPtr)\nFileDuration <= nFileScanMaxLengthMS)
                  debugMsg(sProcName, "calling loadSamplesArrayFromFile(@grMG4, " + nFileDataPtr + ")")
                  bLoadFromFileResult = loadSamplesArrayFromFile(@grMG4, nFileDataPtr)
                  debugMsg(sProcName, "loadSamplesArrayFromFile(@grMG4, " + nFileDataPtr + ") returned " + strB(bLoadFromFileResult))
                Else
                  bLoadFromFileResult = #False
                EndIf
                If gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP
                  Break 2
                EndIf
                If bLoadFromFileResult
                  grMG4\nGraphChannels = gaFileData(nFileDataPtr)\nxFileChannels
                  ; Added 30Jul2024 11.10.3av
                  If grMG4\nGraphChannels > 2
                    ; In SCS, audio/video files that have more than 2 channels will have their audio graphs displayed as just two channels.
                    ; The 'left' channel will be the sum of channels 1, 3, 5, etc, and the 'right' channel will be the sum of channels 2, 4, 6, etc.
                    ; So the number of 'graph channels' for these files should be set to 2.
                    grMG4\nGraphChannels = 2
                  EndIf
                  ; End added 30Jul2024 11.10.3av
                  debugMsg(sProcName, "grMG4\nGraphChannels=" + grMG4\nGraphChannels + ", grMG4\nMGFileChannels=" + grMG4\nMGFileChannels + ", grMG4\nFileDuration=" + grMG4\nFileDuration)
                  debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(@grMG4, " + nFileDataPtr + ", " + \nAudioGraphWidth + ", " + getAudLabel(nAudPtr) + ", #True)")
                  loadSlicePeakAndMinArraysFromSamplesArray(@grMG4, nFileDataPtr, \nAudioGraphWidth, nAudPtr, #True)
                  If gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP
                    Break 2
                  EndIf
                  ; now save information applicable to the drawing of this audio graph
                  \nAudioGraphAudPtr = nAudPtr
                  \nAudioGraphFileDuration = aAud(nAudPtr)\nFileDuration
                  \nAudioGraphFileChannels = aAud(nAudPtr)\nFileChannels
                  \nAudioGraphAbsMin = aAud(nAudPtr)\nAbsMin
                  \nAudioGraphAbsMax = aAud(nAudPtr)\nAbsMax
                  \bAudioGraphImageReady = #True
                  If \bReloadThisSld = #False
                    \bReloadThisSld = #True
                    gnReloadSldCount + 1
                  EndIf
                  If \bRedrawSldAfterLoad
                    If \bRedrawThisSld = #False
                      \bRedrawThisSld = #True
                      gnRedrawSldCount + 1
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
            debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bLoadFileRequest=" + strB(\bLoadFileRequest) + ", \bRedrawSldAfterLoad=" + strB(\bRedrawSldAfterLoad) +
                                ", \bReloadThisSld=" + strB(\bReloadThisSld) + ", gnReloadSldCount=" + gnReloadSldCount + ", c=" + gnRedrawSldCount)
          EndIf
          
        EndWith
      Next nSldPtr
      
      CompilerIf #c_suspend_slider_file_loader_thread_when_auds_playing
        If bWaitingForMainThread = #False
          THR_suspendAThread(#SCS_THREAD_SLIDER_FILE_LOADER)
        EndIf
      CompilerElse
        If (bFileLoading = #False) And (bWaitingForMainThread = #False) And (bDeferringLoad = #False)
          THR_suspendAThread(#SCS_THREAD_SLIDER_FILE_LOADER)
        EndIf
      CompilerEndIf
      
      ; yield to other processes before looping back to the start
      Delay(10)
      
    EndIf ; EndIf grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase = #False
    
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- Get File Stats Thread
Procedure THR_runGetFileStatsThread(*nThreadValue)
  PROCNAMEC()
  Protected nAudPtr, nFileStatsPtr, nFileDataPtr, bProcessThisAud
  Protected bLoadFromFileResult
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  
  setThreadNo(#SCS_THREAD_GET_FILE_STATS)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_GET_FILE_STATS)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    If gbClosingDown Or gbStoppingEverything Or grWIM\bImportingCues
      ; quit loading
      Break
    EndIf
    
    ; Added 31May2024 11.10.3af following emails from Simon Wicks
    ; NB To fix the problem reported by Simon Wicks we just needed to check gbAdding, but found this full test in THR_runControlThread()
    ; so considered it beneficial to use this full test.
    If gbInSamProcess Or gbAdding Or gbInPaste Or grM2T\bProcessingApplyMoveToTime Or gbInCalcCueStartValues
      Delay(5)
      Continue
    EndIf
    ; End added 31May2024 11.10.3af following emails from Simon Wicks
    
    doThreadLoopStart(#SCS_THREAD_GET_FILE_STATS) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    bProcessThisAud = #False
    For nAudPtr = 1 To gnLastAud
      With aAud(nAudPtr)
        If (\bAudTypeForP) And (\bAudPlaceHolder = #False)
          nFileStatsPtr = \nFileStatsPtr
          If nFileStatsPtr = -2
            ; file to be excluded from getFileStats(), eg because file duration too long
          ElseIf nFileStatsPtr = -1
            bProcessThisAud = #True
            ; debugMsg(sProcName, "bProcessThisAud=" + strB(bProcessThisAud))
          ElseIf gaFileStats(nFileStatsPtr)\sFileName <> \sFileName
            bProcessThisAud = #True
            ; debugMsg(sProcName, "bProcessThisAud=" + strB(bProcessThisAud))
          Else
            nFileDataPtr = \nFileDataPtr
            If nFileDataPtr <> grAudDef\nFileDataPtr
              If gaFileStats(nFileStatsPtr)\sFileModified <> gaFileData(nFileDataPtr)\sFileModified
                bProcessThisAud = #True
;                 debugMsg(sProcName, "bProcessThisAud=" + strB(bProcessThisAud) +
;                                     ", gaFileStats(" + nFileStatsPtr + ")\sFileModified=" + gaFileStats(nFileStatsPtr)\sFileModified +
;                                     ", gaFileData(" + nFileDataPtr + ")\sFileModified=" + gaFileData(nFileDataPtr)\sFileModified)
              EndIf
            EndIf
          EndIf
          If bProcessThisAud
            ; debugMsg(sProcName, "calling getFileStats(" + getAudLabel(nAudPtr) + ")")
            getFileStats(nAudPtr)
            Break ; Break nAudPtr - only process one aAud() per iteration of the main loop
          EndIf
        EndIf ; EndIf (\bAudTypeForP) And (\bAudPlaceHolder = #False)
      EndWith
    Next nAudPtr
    If bProcessThisAud = #False
      ; no file stats need to be obtained
      THR_suspendAThread(#SCS_THREAD_GET_FILE_STATS)
    EndIf
    
    ; yield to other processes before looping back to the start
    Delay(10)
    
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_GET_FILE_STATS)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_GET_FILE_STATS)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- Network Thread
Procedure THR_runNetworkThread(*nThreadValue)
  ; includes support for remote access interface
  PROCNAMEC()
  Protected nNetworkControlPtr
  Protected qTimeNow.q
  Protected bLockReqd, bLockedMutex
  Protected nThreadState, bSuspendRequested, nLoopAction
  CompilerIf #cTraceNetworkMsgs
    Protected bHideTracing = #False ; bHideTracing usd by debugMsgN
  CompilerElse
    Protected bHideTracing = #True
  CompilerEndIf
  
  setThreadNo(#SCS_THREAD_NETWORK)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_NETWORK)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    ; do NOT abort thread during closedown or we will lose SMS responses to commands like 'set matrix off' etc
    doThreadLoopStart(#SCS_THREAD_NETWORK) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    With grSMS
      ; debugMsg(sProcName, "\nSMSClientConnection=" + \nSMSClientConnection)
      If \nSMSClientConnection = 0
        If (gnNetworkServersActive = 0) And (gnNetworkResponseCount = 0) And (gnNetworkClientsActive = 0)
          If grX32CueControl\bCueControlActive = #False
            THR_suspendAThread(#SCS_THREAD_NETWORK)
          EndIf
        EndIf
      Else ; If NetworkClientEvent(\nSMSClientConnection) = #PB_NetworkEvent_Data  ; nb this test now inside handleSMSInput()
        TryLockSMSNetworkMutex(359)
        ; debugMsg(sProcName, "bLockedMutex=" + strB(bLockedMutex))
        If (bLockReqd = #False) Or (bLockedMutex)
          ; debugMsg(sProcName, "calling handleSMSInput()")
          handleSMSInput()
          UnlockSMSNetworkMutex()
        EndIf
      EndIf
    EndWith
    
    With grX32CueControl
      If \nX32ClientConnection
        qTimeNow = ElapsedMilliseconds()
        If (qTimeNow - \qLastXRemoteTime) >= 9000
          PostEvent(#SCS_Event_Send_xremote_to_X32, #WMN, 0)
          \qLastXRemoteTime = qTimeNow
        EndIf
      EndIf
    EndWith
    
    If gnNetworkServersActive > 0
      CompilerIf 1=2
        gnServerEvent = NetworkServerEvent()
        ; debugMsg(sProcName, "NetworkServerEvent() returned " + gnServerEvent)
      CompilerElse
        gnServerEvent = #PB_NetworkEvent_None
        While #True ; Pseudo loop just to enable 'Break' when a network server event is detected
          ; NOTE: SCS Cue Control network device
          For nNetworkControlPtr = 0 To gnMaxNetworkControl
            With gaNetworkControl(nNetworkControlPtr)
              If \nServerConnection
                gnServerEvent = NetworkServerEvent(\nServerConnection) : If gnServerEvent <> #PB_NetworkEvent_None : Break 2 : EndIf
              EndIf
            EndWith
          Next nNetworkControlPtr
          ; NOTE: Remote App Interface server connections
          With grRAI
            If \nServerConnection1
              gnServerEvent = NetworkServerEvent(\nServerConnection1) : If gnServerEvent <> #PB_NetworkEvent_None : Break : EndIf
            EndIf
            If \nServerConnection2
              gnServerEvent = NetworkServerEvent(\nServerConnection2) : If gnServerEvent <> #PB_NetworkEvent_None : Break : EndIf
            EndIf
            If \nServerConnection3
              gnServerEvent = NetworkServerEvent(\nServerConnection3) : If gnServerEvent <> #PB_NetworkEvent_None : Break : EndIf
            EndIf
          EndWith
          ; NOTE: SCS backup computer listening for messages from the primary computer ('FM' = Functional Mode, which would be 'Backup' in this case)
          With grFMOptions
            If \nFMServerId
              gnServerEvent = NetworkServerEvent(\nFMServerId) : If gnServerEvent <> #PB_NetworkEvent_None : Break : EndIf
            EndIf
          EndWith
          Break
        Wend
      CompilerEndIf
      If gnServerEvent <> #PB_NetworkEvent_None
        processNetworkServerEvent()
      EndIf
    EndIf
    
    If gnNetworkClientsActive > 0
      For nNetworkControlPtr = 0 To gnMaxNetworkControl
        With gaNetworkControl(nNetworkControlPtr)
          If (\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN) Or
             (\nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And (\nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJLINK Or \nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJNET))
              If \nClientConnection And \bClientConnectionLive
                gnClientEvent = NetworkClientEvent(\nClientConnection)
                ; debugMsg(sProcName, "NetworkClientEvent(" + \nClientConnection + ") returned " + gnClientEvent)
                If gnClientEvent <> #PB_NetworkEvent_None
                  debugMsgN(sProcName, "calling processNetworkClientEvent(" + nNetworkControlPtr + ", " + strB(#cTraceNetworkMsgs) + ")")
                  processNetworkClientEvent(nNetworkControlPtr, #cTraceNetworkMsgs)
                EndIf
              EndIf
          EndIf
        EndWith
      Next nNetworkControlPtr
    EndIf
    
    ; Added 15Jan2024 11.10.0
    If grFMOptions\nFunctionalMode = #SCS_FM_PRIMARY
      If grFMOptions\qTimePollSent < (ElapsedMilliseconds() - 5000)
        ; send a poll message to the backup every 5 seconds
        CompilerIf #cTraceNetworkMsgs
          FMP_sendCommandIfReqd(#SCS_OSCINP_POLL, 0, 0, 0, "", #False)
        CompilerElse
          FMP_sendCommandIfReqd(#SCS_OSCINP_POLL, 0, 0, 0, "", #True)
        CompilerEndIf
        grFMOptions\qTimePollSent = ElapsedMilliseconds()
      EndIf
    EndIf
    ; End added 15Jan2024 11.10.0
    
    If grFMOptions\nFunctionalMode = #SCS_FM_BACKUP
      If grFMOptions\nFMClientId
        gnClientEvent = NetworkClientEvent(grFMOptions\nFMClientId)
        If gnClientEvent <> #PB_NetworkEvent_None
          debugMsgN(sProcName, "FMB gnClientEvent=" + gnClientEvent)
          nNetworkControlPtr = getNetworkControlPtrForServerAndClientConnection(0, grFMOptions\nFMClientId)
          If nNetworkControlPtr >= 0
            debugMsgN(sProcName, "calling processNetworkClientEvent(" + nNetworkControlPtr + ", " + strB(#cTraceNetworkMsgs) + ")")
            processNetworkClientEvent(nNetworkControlPtr, #cTraceNetworkMsgs)
          EndIf
        EndIf
      EndIf
    EndIf
    
    Delay(2)
    
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_NETWORK)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_NETWORK)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- MTC Cues Thread
Procedure THR_runMTCCuesThread(*nThreadValue)
  PROCNAMEC()
  Protected sMTCPortName.s
  Protected bLockedMutex
  Protected nThreadState, bSuspendRequested, nLoopAction ; required by macro doThreadLoopStart()
  
  setThreadNo(#SCS_THREAD_MTC_CUES)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_MTC_CUES)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  ; Added 4Jan2023 11.10.0ab
  If gnMTCSendMutex = 0
    gnMTCSendMutex = CreateMutex()
    debugMsg(sProcName, "gnMTCSendMutex=" + gnMTCSendMutex)
  EndIf
  ; End added 4Jan2023 11.10.0ab
  
  Repeat
    If gbClosingDown ; Or gbStoppingEverything
      ; quit
      Break
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_MTC_CUES) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    ; LockMTCSendMutex(700, #False) ; added 20Aug2019 11.8.2ae
    With grMTCSendControl
      
;       ; Added 3Jan2023 11.10.0ab
;       If \bMTCSuspendThreadUntilFullFrameSent And \bMTCCuesPortOpen
;         Delay(1)
;         Continue
;       EndIf
;       ; End added 3Jan2023 11.10.0ab
      
      If \nMTCThreadRequest = 0
        ; Added 3Jan2023 11.10.0ab
        If \bMTCSuspendThreadUntilFullFrameSent And \bMTCCuesPortOpen
          Delay(1)
          Continue
        EndIf
        ; End added 3Jan2023 11.10.0ab
        Select \nMTCSendState
          Case #SCS_MTC_STATE_RUNNING, #SCS_MTC_STATE_PRE_ROLL
            CompilerIf #cTraceMTCSend And 1=2
              debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState) + " calling SendMTCQuarterFrames()")
            CompilerEndIf
            SendMTCQuarterFrames()
            ; debugMsg(sProcName, "returned from SendMTCQuarterFrames()")
        EndSelect
        
      Else  ; \nMTCThreadRequest <> 0
        debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + \nMTCThreadRequest)
        If \nMTCThreadRequest & #SCS_MTC_THR_OPEN_MIDI
          debugMsg(sProcName, "Opening MTC MIDI Port")
          \nMTCThreadRequest ! #SCS_MTC_THR_OPEN_MIDI
          openMTCCuesPortIfReqd(\nMTCCuesPhysicalDevPtr)
        EndIf
        
        If \nMTCThreadRequest & #SCS_MTC_THR_READY_MTC
          debugMsg(sProcName, "Readying MTC")
          \nMTCThreadRequest ! #SCS_MTC_THR_READY_MTC
          If \nMTCCuesPhysicalDevPtr >= 0
            ; sMTCPortName = SendMTCFullFrame(\nMTCCuesPhysicalDevPtr, 127)
            ; debugMsg3(sProcName, "SendMTCFullFrame(" + \nMTCCuesPhysicalDevPtr + ", 127) returned '" + sMTCPortName + "'")
            sMTCPortName = SendMTCFullFrame()
            debugMsg3(sProcName, "SendMTCFullFrame() returned '" + sMTCPortName + "'")
            If sMTCPortName
              ; debugMsg(sProcName, "calling SendMTCQuarterFrames()")
              SendMTCQuarterFrames()
              ; debugMsg(sProcName, "returned from SendMTCQuarterFrames()")
            EndIf
            ; if a 'stop' request is also included, then clear the 'stop' request.
            ; that can happen if starting an MTC sub-cue kills another currently-playing MTC sub-cue
            If \nMTCThreadRequest & #SCS_MTC_THR_STOP_MTC
              \nMTCThreadRequest ! #SCS_MTC_THR_STOP_MTC
            EndIf
            ; added 24Aug2019 11.8.2ag - see also similar code added to playSubTypeU()
            If \nMTCThreadRequest & #SCS_MTC_THR_PAUSE_MTC
              \nMTCThreadRequest ! #SCS_MTC_THR_PAUSE_MTC
            EndIf
            ; end added 24Aug2019 11.8.2ag
          EndIf
        EndIf
        
        If \nMTCThreadRequest & #SCS_MTC_THR_PAUSE_MTC
          debugMsg(sProcName, "Pausing MTC")
          \nMTCThreadRequest ! #SCS_MTC_THR_PAUSE_MTC
          \nMTCSendState = #SCS_MTC_STATE_PAUSED
          debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
        EndIf
        
        If \nMTCThreadRequest & #SCS_MTC_THR_RESUME_MTC
          debugMsg(sProcName, "Resuming MTC")
          \nMTCThreadRequest ! #SCS_MTC_THR_RESUME_MTC
          resumeTimeCode(\nMTCSubPtr)
        EndIf
        
        If \nMTCThreadRequest & #SCS_MTC_THR_RESTART_MTC
          debugMsg(sProcName, "Restarting MTC")
          \nMTCThreadRequest ! #SCS_MTC_THR_RESTART_MTC
          debugMsg(sProcName, "calling SendMTCFullFrameForRepos(#False, #True)")
          sMTCPortName = SendMTCFullFrameForRepos(#False, #True)
          ; debugMsg(sProcName, "SendMTCFullFrameForRepos(#False, #True) returned '" + sMTCPortName + "'")
        EndIf
        
        If \nMTCThreadRequest & #SCS_MTC_THR_STOP_MTC
          debugMsg(sProcName, "Stopping MTC")
          \nMTCThreadRequest ! #SCS_MTC_THR_STOP_MTC
          \nMTCSendState = #SCS_MTC_STATE_STOPPED
          debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
          \nMTCPanelIndex = grMTCSendControlDef\nMTCPanelIndex
          debugMsg(sProcName, "(stop) grMTCSendControl\nMTCPanelIndex=" + Str(\nMTCPanelIndex))
          ; suspend thread on stopping MTC, to lower the processing overhead since there's no 'delay' in this main loop
          ; gaThread(#SCS_THREAD_MTC_CUES)\nThreadState = #SCS_THREAD_STATE_SUSPEND_REQUESTED
          gaThread(#SCS_THREAD_MTC_CUES)\bSuspendRequested = #True
          debugMsg(sProcName, "gaThread(#SCS_THREAD_MTC_CUES)\bSuspendRequested=" + StrB(gaThread(#SCS_THREAD_MTC_CUES)\bSuspendRequested))
        EndIf
        
        If \nMTCThreadRequest & #SCS_MTC_THR_CLOSE_MIDI
          debugMsg(sProcName, "Closing MTC MIDI Port")
          \nMTCThreadRequest ! #SCS_MTC_THR_CLOSE_MIDI
          closeMTCCuesPort(\nMTCCuesPhysicalDevPtr)
          \nMTCSendState = #SCS_MTC_STATE_IDLE
          debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
          \nMTCPanelIndex = grMTCSendControlDef\nMTCPanelIndex
          debugMsg(sProcName, "(close) grMTCSendControl\nMTCPanelIndex=" + Str(\nMTCPanelIndex))
          Break ; stop thread after closing MTC Cues port
        EndIf
        
      EndIf
      
    EndWith
    ; unlockMTCSendMutex(#False) ; added 20Aug2019 11.8.2ae
    
    ; yield to other processes before looping back to the start
    Delay(1)  ; added 17/10/2014 11.3.5 following email from Staatstheater Darmstadt 'Timecode gives us CPU load problems' (previously there was no Delay() at all)
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_MTC_CUES)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_MTC_CUES)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- Control Send Thread
Procedure THR_runCtrlSendThread(*nThreadValue)
  PROCNAMEC()
  Protected n
  Protected nMaxCtrlSendThreadItem
  Protected nCtrlSendThreadItemsActive
  Protected qTimeNow.q
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  
  setThreadNo(#SCS_THREAD_CTRL_SEND)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_CTRL_SEND)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    If (gbClosingDown) Or (gbStoppingEverything)
      ; quit
      Break
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_CTRL_SEND) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf    
    
    ; thread is active
    nCtrlSendThreadItemsActive = 0
    qTimeNow = ElapsedMilliseconds()
    nMaxCtrlSendThreadItem = gnMaxCtrlSendThreadItem
    For n = 0 To nMaxCtrlSendThreadItem
      With gaCtrlSendThreadItem(n)
        Select \nState
          Case #SCS_CSTI_READY
            If (\qNotBefore - qTimeNow) <= 0
              processCtrlSendThreadItem(n)
            EndIf
          Case #SCS_CSTI_RUNNING
            processCtrlSendThreadItem(n)
        EndSelect
        
        ; check \nState after above processing to count how many items are still active
        Select \nState
          Case #SCS_CSTI_READY, #SCS_CSTI_RUNNING
            nCtrlSendThreadItemsActive + 1
        EndSelect
        
      EndWith
    Next n
    
    If (nCtrlSendThreadItemsActive = 0) And (nMaxCtrlSendThreadItem = gnMaxCtrlSendThreadItem)
      THR_suspendAThread(#SCS_THREAD_CTRL_SEND)
    EndIf
    
    ; yield to other processes before looping back to the start
    Delay(2)
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_CTRL_SEND)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_CTRL_SEND)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- DMX Send Thread
Procedure THR_runDMXSendThread(*nThreadValue)
  PROCNAMEC()
  Protected bProcessCalled
  Protected qTimeNow.q
  Protected bDMXRefreshOnly
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  
  setThreadNo(#SCS_THREAD_DMX_SEND)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_DMX_SEND)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    If ((gbClosingDown) Or (gbStoppingEverything)) And (grDMX\bBlackOutOnCloseDown = #False)
      debugMsg(sProcName, "quitting: gbClosingDown=" + strB(gbClosingDown) + ", gbStoppingEverything=" + strB(gbStoppingEverything) + ", grDMX\bBlackOutOnCloseDown=" + strB(grDMX\bBlackOutOnCloseDown))
      ; quit
      Break
    EndIf
    
    If grDMX\bCaptureDMX Or gbInCalcCueStartValues
      ; Effectively suspend this thread during DMX Capture when editing a Lighting Cue (in fmEditK), or currently in CalcCueStartValues()
      Delay(100)
      Continue
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_DMX_SEND) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    bProcessCalled = #False
    ; debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend) + ", grWDD\bForceRedisplay=" + strB(grWDD\bForceRedisplay) + ", grWDD\bDMXDisplayActive=" + strB(grWDD\bDMXDisplayActive))
    If grDMXRefreshControl\bRefreshSet
      ; grDMXRefreshControl\bRefreshSet will be #True for Enttec OPEN DMX USB or equivalent because these devices do not auto-refresh DMX, which MUST be refreshed approx 40 times a second
      qTimeNow = ElapsedMilliseconds()
      If (qTimeNow - grDMXRefreshControl\qTimeLastSent) >= grDMXRefreshControl\nRefreshInterval
        ; only send DMX in time with the user-specified refresh rate (default 40fps)
        grDMXRefreshControl\qTimeLastSent = qTimeNow
        If grDMX\bDMXReadyToSend
          bDMXRefreshOnly = #False
        Else
          bDMXRefreshOnly = #True
        EndIf
        ; debugMsg(sProcName, "calling DMX_processDMXSendThread(" + strB(bDMXRefreshOnly) + ")")
        DMX_processDMXSendThread(bDMXRefreshOnly)
        bProcessCalled = #True
      EndIf
    Else
      ; grDMXRefreshControl\bRefreshSet will be #False for Enttec DMX USB PRO, DMX USB PRO MK2, or equivalent
      If grDMX\bDMXReadyToSend ; nb cleared inside DMX_processDMXSendThread() while gnDMXSendMutex is locked
        ; debugMsg(sProcName, "calling DMX_processDMXSendThread(#False)")
        DMX_processDMXSendThread(#False)
        If grWDD\bDMXDisplayActive
          grDMX\bCallDisplayDMXSendData = #True
        EndIf
        If WCN\nDimmerChanCtrls > 0
          WCN\bRefreshDimmerChannelFaders = #True
        EndIf
        bProcessCalled = #True
      EndIf
    EndIf
    
    If (bProcessCalled = #False) And (grWDD\bForceRedisplay)
      If grWDD\bDMXDisplayActive
        ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
        grDMX\bCallDisplayDMXSendData = #True
      EndIf
      grWDD\bForceRedisplay = #False
    EndIf
    
    ; yield to other processes before looping back to the start
    Delay(3)
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_DMX_SEND)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_DMX_SEND)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

;- DMX Receive Thread
Procedure THR_runDMXReceiveThread(*nThreadValue)
  CompilerIf #c_dmx_receive_in_main_thread = #False
    PROCNAMEC()
    Protected bProcessCalled
    Protected qTimeNow.q
    Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
    
    setThreadNo(#SCS_THREAD_DMX_RECEIVE)  ; preferably set this before calling debugMsg()
    
    debugMsg3(sProcName, #SCS_START)
    
    With gaThread(#SCS_THREAD_DMX_RECEIVE)
      \nThreadState = #SCS_THREAD_STATE_ACTIVE
      \bThreadCreated = #True
    EndWith
    
    Repeat
      If gbClosingDown Or gbStoppingEverything
        debugMsg(sProcName, "quitting: gbClosingDown=" + strB(gbClosingDown) + ", gbStoppingEverything=" + strB(gbStoppingEverything))
        ; quit
        Break
      EndIf
      
      doThreadLoopStart(#SCS_THREAD_DMX_RECEIVE) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
      If nLoopAction = #SCS_LOOP_ACTION_BREAK
        Break
      ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
        Continue
      EndIf
      
      ; thread is active
      DMX_processDMXReceiveThread()
      
      ; yield to other processes before looping back to the start
      Delay(2)
    ForEver
    
    ; exiting this procedure will stop the thread
    With gaThread(#SCS_THREAD_DMX_RECEIVE)
      \nThreadState = #SCS_THREAD_STATE_STOPPED
      \bThreadCreated = #False
      debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_DMX_RECEIVE)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
    EndWith
  CompilerEndIf
  
EndProcedure

;- HTTP Send Thread
Procedure THR_runHTTPSendThread(*nThreadValue)
  PROCNAMEC()
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  Protected nMsgIndex, nResult.i
  Protected sResponseString.s
  
  setThreadNo(#SCS_THREAD_HTTP_SEND)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_HTTP_SEND)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  Repeat
    If (gbClosingDown) Or (gbStoppingEverything)
      debugMsg(sProcName, "quitting: gbClosingDown=" + strB(gbClosingDown) + ", gbStoppingEverything=" + strB(gbStoppingEverything))
      ; quit
      Break
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_HTTP_SEND) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    With grHTTPControl
      If \nMaxHTTPSendMsg >= 0
        LockHTTPSendMutex(801)
        For nMsgIndex = 0 To \nMaxHTTPSendMsg
          If \aHTTPSendMessage(nMsgIndex)\bHTTPSendMsgSent = #False
            nResult = SimpleHTTP_GET(nMsgIndex)
            CompilerIf #cTraceHTTP
              debugMsg(sProcName, "SimpleHTTP_GET(" + #DQUOTE$ + ReplaceString(\aHTTPSendMessage(nMsgIndex)\sHTTPSendMsg, #CRLF$, "\r\n") + #DQUOTE$ + ", " + strB(#cTraceHTTP) + ") returned " + #DQUOTE$ + sResult + #DQUOTE$ + ", status=" + gnHTTPGetStatusCode)
            CompilerEndIf
            \aHTTPSendMessage(nMsgIndex)\bHTTPSendMsgSent = #True
            
            If \aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode <> 200
              WMN_setStatusField(getSubLabel(\aHTTPSendMessage(nMsgIndex)\nCueNumber) +
                ":- " + \aHTTPSendMessage(nMsgIndex)\sHTTPSendMsg + Lang("Errors", "HTTPERROR_1") +
                \aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode, #SCS_STATUS_WARN, 6000)
            EndIf
            
            If \aHTTPSendMessage(nMsgIndex)\pHTTPResponseBuffer And \aHTTPSendMessage(nMsgIndex)\nHTTPSendIsATest
              ClearGadgetItems(WQM\txtHttpresponse)
              AddGadgetItem(WQM\txtHttpresponse, -1, "HTTP Status code: " + Str(\aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode))
              AddGadgetItem(WQM\txtHttpresponse, -1, "HTTP GET Response: ")
              sResponseString = PeekS(\aHTTPSendMessage(nMsgIndex)\pHTTPResponseBuffer, MemoryStringLength(\aHTTPSendMessage(nMsgIndex)\pHTTPResponseBuffer), #PB_UTF8)
              AddGadgetItem(WQM\txtHttpresponse, -1, sResponseString)
              FreeMemory(\aHTTPSendMessage(nMsgIndex)\pHTTPResponseBuffer)
              \aHTTPSendMessage(nMsgIndex)\pHTTPResponseBuffer = 0
              \aHTTPSendMessage(nMsgIndex)\nHTTPSendIsATest = 0
              \aHTTPSendMessage(\nMaxHTTPSendMsg)\sHTTPSendMsg = ""
              \aHTTPSendMessage(nMsgIndex)\bHTTPSendMsgSent = #True
            EndIf
          EndIf
        Next nMsgIndex
        ; all messages sent whilst mutex locked, so can now clear the 'max' pointer
        \nMaxHTTPSendMsg = -1
        UnlockHTTPSendMutex()
      EndIf
    EndWith
    
    ; yield to other processes before looping back to the start
    Delay(3)
  ForEver
  
  ; exiting this procedure will stop the thread
  With gaThread(#SCS_THREAD_HTTP_SEND)
    \nThreadState = #SCS_THREAD_STATE_STOPPED
    \bThreadCreated = #False
    debugMsg(sProcName, #SCS_END + ", gaThread(#SCS_THREAD_HTTP_SEND)\nThreadState=" + THR_decodeThreadState(\nThreadState) + ", \bThreadCreated=" + strB(\bThreadCreated))
  EndWith
  
EndProcedure

Procedure THR_displayDeadlockInfo(nThreadNo, nMutexNo, sReason.s)
  PROCNAMEC()
  Protected sTitle.s, sLine.s, sMsg.s
  Protected t, m
  Static bMsgDisplayed
  
  debugMsg(sProcName, #SCS_START)
  
  If bMsgDisplayed = #False
    sTitle = sReason
    sMsg = "SCS Version: " + #SCS_VERSION + ", build: " + grProgVersion\sBuildDateTime
    sMsg + #CRLF$ + "Thread: " + THR_decodeThreadIndex(nThreadNo) + ", Mutex: " + decodeMutex(nMutexNo) + ", Reason: " + sReason
    For t = #SCS_THREAD_MONITOR_FIRST To #SCS_THREAD_MONITOR_LAST
      sLine = ""
      For m = #SCS_MUTEX_MONITOR_FIRST To #SCS_MUTEX_MONITOR_LAST
        With gaThreadMutexArray(t, m)
          If \nLockStatus > 0
            If Len(sLine) = 0
              sLine = THR_decodeThreadIndex(t) + ":"
            EndIf
            sLine + "  " + decodeMutex(m) + ":"
            Select \nLockStatus
              Case #SCS_THREADMUTEX_LOCK_REQUESTED
                sLine + "R" + \nLockNoForRequest + "@" + traceTime(\qRequestTime)
              Case #SCS_THREADMUTEX_LOCKED
                sLine + "L" + \nLockNoForLock + "@" + traceTime(\qLockTime)
            EndSelect
          EndIf
        EndWith
      Next m
      If sLine
        sMsg + #CRLF$ + sLine
      EndIf
    Next t
    debugMsg(sProcName, sTitle + #CRLF$ + sMsg)
    scsMessageRequester(sTitle, sMsg, #MB_ICONEXCLAMATION)
    bMsgDisplayed = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure THR_suspendMutexLockTimeoutChecks()
  PROCNAMEC()
  Protected nThreadNo, nMutexNo
  
  For nThreadNo = #SCS_THREAD_MONITOR_FIRST To #SCS_THREAD_MONITOR_LAST
    For nMutexNo = #SCS_MUTEX_MONITOR_FIRST To #SCS_MUTEX_MONITOR_LAST
      With gaThreadMutexArray(nThreadNo, nMutexNo)
        If \nLockStatus <> 0
          \bSuspendTimeoutCheck = #True
        EndIf
      EndWith
    Next nMutexNo
  Next nThreadNo
  
EndProcedure

;- System Monitor Thread
Procedure THR_runSystemMonitorThread(*nThreadValue)
  PROCNAMEC()
  Protected qTimeNow.q
  Protected nThreadState, bSuspendRequested, nLoopAction, bLockedMutex
  Protected gpuRresult.d
  Protected t2.q, t1.q
  Static fLastCPUUsage.f
  Protected st_PrevIdle.FILETIME, st_PrevKernel.FILETIME, st_PrevUser.FILETIME
  Protected st_CurrIdle.FILETIME, st_CurrKernel.FILETIME, st_CurrUser.FILETIME
  Protected qPrevIdleNano.q, qPrevKernelNano.q, qPrevUserNano.q
  Protected qCurrIdleNano.q, qCurrKernelNano.q, qCurrUserNano.q
  Protected fCpuUsage.f
  
  setThreadNo(#SCS_THREAD_SYSTEM_MONITOR)  ; preferably set this before calling debugMsg()
  
  debugMsg3(sProcName, #SCS_START)
  
  With gaThread(#SCS_THREAD_SYSTEM_MONITOR)
    \nThreadState = #SCS_THREAD_STATE_ACTIVE
    \bThreadCreated = #True
  EndWith
  
  If kernel32Lib = 0
    kernel32Lib = OpenLibrary(#PB_Any,"kernel32.dll")
  Else
    debugMsg3(sProcName, "kernel32.dll failed to load")
  EndIf
  
  If kernel32Lib
    GetSystemTimes.GetSystemTimes = GetFunction(kernel32Lib, "GetSystemTimes")  
    t1 = ElapsedMilliseconds()
    glib_GetGPUUsage = OpenLibrary(#PB_Any, "getGPUcounters.dll")
    
    If glib_GetGPUUsage
      gfn_GetGPUUsageActivate.activateGPUpercentage = GetFunction(glib_getGPUUsage, "activateGPUpercentage")          ; Activate the thread in the dll to read with it's internal timer
      gfn_GetGPUUsageDeactivate.deactivateGPUpercentage = GetFunction(glib_getGPUUsage, "deactivateGPUpercentage")    ; Deactivate
      gfn_GetGPUUsagePercentage.getGPUpercentage = GetFunction(glib_getGPUUsage, "getGPUpercentage")                  ; Read the stored percentage, don't read faster than every 0.5S
      gfn_GetGPUUsageActivate()
      LockMutex(CPUTimeMutex)
      
      If GetSystemTimes(@st_PrevIdle, @st_PrevKernel, @st_PrevUser) = 0
        Debugmsg(sProcName,  "GetSystemTimes failed (first snapshot): Error " + Str(GetLastError_()))
      EndIf     
      
      qPrevIdleNano = FileTimeToQuad(st_PrevIdle)
      qPrevKernelNano = FileTimeToQuad(st_PrevKernel)
      qPrevUserNano = FileTimeToQuad(st_PrevUser)
     
      UnlockMutex(CPUTimeMutex)
     Else
      debugMsg3(sProcName, "getGPUCounters.dll failed to load")
    EndIf
  EndIf
  
  Repeat
    If gbClosingDown
      ; quit
      Break
    EndIf
    
    doThreadLoopStart(#SCS_THREAD_SYSTEM_MONITOR) ; doThreadLoopStart() is a macro that will set nLoopAction and process some related code
    If nLoopAction = #SCS_LOOP_ACTION_BREAK
      Break
    ElseIf nLoopAction = #SCS_LOOP_ACTION_CONTINUE
      Continue
    EndIf
    
    ; thread is active
    qTimeNow = ElapsedMilliseconds()
    
    ; check VU meters and progress slider active when expected to be
    If gnPlayingAudTypeForPPtr >= 0
      monitorVU(qTimeNow)
    EndIf
    
    If glib_GetGPUUsage
      t2 = ElapsedMilliseconds()
      
      If t2 >= t1 + #CPU_GPU_METERING_DELAY
        gpuRresult = gfn_GetGPUUsagePercentage()
        logProcessorEvent("GPU usage: " + Left(StrD(gpuRresult), 5) + "%")
        ;Debug "GPU usage: " + Left(StrD(gpuRresult), 5) + "%"
        
        ;Read CPU meters
        LockMutex(CPUTimeMutex)
        
        If GetSystemTimes(@st_CurrIdle, @st_CurrKernel, @st_CurrUser)
          qCurrIdleNano = FileTimeToQuad(st_CurrIdle)
          qCurrKernelNano = FileTimeToQuad(st_CurrKernel)
          qCurrUserNano = FileTimeToQuad(st_CurrUser)
          
          ; Calculate CPU usage
          fCpuUsage = CalculateCPUUsage(qPrevIdleNano, qPrevKernelNano, qPrevUserNano, qCurrIdleNano, qCurrKernelNano, qCurrUserNano)
          
          ; Clamp to 0-100%
          If fCpuUsage < 0
            fCpuUsage = 0
          EndIf
          
          If fCpuUsage > 100
            fCpuUsage = 100
          EndIf
            
          ; Update previous values
          qPrevIdleNano = qCurrIdleNano
          qPrevKernelNano = qCurrKernelNano
          qPrevUserNano = qCurrUserNano
        Else
          logProcessorEvent("CPU Usage: Error, GetSystemTimes_() failed")
          Break
        EndIf
        
        ; Update times for the next iteration
        qIdletime1 = qIdletime2
        qKerneltime1 = qKerneltime2
        qUsertime1 = qUsertime2
        UnlockMutex(CPUTimeMutex)
        
        If fCpuUsage >= 0 And fCpuUsage <= 100                    ; there is a bug in GetSystemTimes where some of the values are wildly incorrect 
          logProcessorEvent("CPU Usage: " + StrF(fCpuUsage, 2) + "%")
          ;Debug "CPU Usage: " + StrF(fCpuUsage, 2) + "%"
          fLastCPUUsage = fCpuUsage
        Else
          logProcessorEvent("CPU usage: " + StrF(fLastCPUUsage, 2) + "%*")
          ;Debug "CPU usage: " + StrF(fCpuUsage, 2) + "%*"    ; Just display the last corect one
        EndIf
        
        gbLogProcessorEvents = #False
        t1 = t2
        UnlockMutex(mtx_ScsLTCMutex)
      EndIf
    EndIf
    
    Delay(10)                                                     ; delay moved by Dee 09/03/2025 so that there is always a delay if the gpu library fails to load.
  ForEver
  
  If glib_GetGPUUsage
    gfn_GetGPUUsageDeactivate()
    CloseLibrary(glib_GetGPUUsage)
  EndIf
  
  If kernel32Lib
    CloseLibrary(kernel32Lib)
  EndIf
  
  ; exiting this procedure will stop the thread
  gaThread(#SCS_THREAD_SYSTEM_MONITOR)\nThreadState = #SCS_THREAD_STATE_STOPPED
  
  debugMsg3(sProcName, #SCS_END)
  
EndProcedure

Procedure THR_stopAllTimersAndThreads()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WSP)
    RemoveWindowTimer(#WSP, #SCS_TIMER_SPLASH)
  EndIf
  If IsWindow(#WMN)
    RemoveWindowTimer(#WMN, #SCS_TIMER_DEMO)
  EndIf
  If IsWindow(#WCL)
    RemoveWindowTimer(#WCL, #SCS_TIMER_CLOCK)
  EndIf
  If IsWindow(#WED)
    RemoveWindowTimer(#WED, #SCS_TIMER_TEST_TONE)
  EndIf
  If IsWindow(#WMN)
    RemoveWindowTimer(#WMN, #SCS_TIMER_VU_METERS)
  EndIf
  
  cancelAllLoadRequests() ; nb includes "THR_waitForAThreadToStop(#SCS_THREAD_SLIDER_FILE_LOADER)"
  
  debugMsg(sProcName, "stopping spawned threads")
  THR_stopAThread(#SCS_THREAD_CONTROL)
  THR_stopAThread(#SCS_THREAD_BLENDER)
  THR_stopAThread(#SCS_THREAD_RS232_RECEIVE)
  THR_stopAThread(#SCS_THREAD_SLIDER_FILE_LOADER)
  THR_stopAThread(#SCS_THREAD_NETWORK)
  THR_stopAThread(#SCS_THREAD_SCS_LTC)
  THR_stopAThread(#SCS_THREAD_MTC_CUES)
  THR_stopAThread(#SCS_THREAD_CTRL_SEND)
  THR_stopAThread(#SCS_THREAD_DMX_SEND)
  CompilerIf #c_dmx_receive_in_main_thread = #False
    THR_stopAThread(#SCS_THREAD_DMX_RECEIVE)
  CompilerEndIf
  THR_stopAThread(#SCS_THREAD_GET_FILE_STATS)
  THR_stopAThread(#SCS_THREAD_SYSTEM_MONITOR)
  
  If gnBufferingThreadEvent
    SetEvent_(gnBufferingThreadEvent)
  EndIf
  
  debugMsg(sProcName, "wait for timers and threads to stop")
  THR_waitForAThreadToStop(#SCS_THREAD_CONTROL, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_BLENDER, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_RS232_RECEIVE, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_SLIDER_FILE_LOADER, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_NETWORK, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_MTC_CUES, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_CTRL_SEND, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_DMX_SEND, 1000, #True)
  CompilerIf #c_dmx_receive_in_main_thread = #False
    THR_waitForAThreadToStop(#SCS_THREAD_DMX_RECEIVE, 1000, #True)
  CompilerEndIf
  THR_waitForAThreadToStop(#SCS_THREAD_GET_FILE_STATS, 1000, #True)
  THR_waitForAThreadToStop(#SCS_THREAD_SYSTEM_MONITOR, 1000, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure THR_waitForCueStatusChecksToEnd(nMaxWaitTime=500)
  PROCNAMEC()
  Protected qInitialTime.q
  
  If gbInCueStatusChecks
    If gnThreadNo = #SCS_THREAD_CONTROL
      debugMsg(sProcName, "exiting because called from the control thread")
    Else
      qInitialTime = ElapsedMilliseconds()
      ; wait for cueStatusChecks to pause
      While gbInCueStatusChecks
        Delay(10)
        If (ElapsedMilliseconds() - qInitialTime) > nMaxWaitTime
          debugMsg(sProcName, "exiting due to timing out after " + nMaxWaitTime + " milliseconds")
          Break
        EndIf
      Wend
    EndIf
  EndIf
EndProcedure

Procedure.s THR_decodeThreadIndex(nThreadIndex)
  Protected sThread.s
  Select nThreadIndex
    Case #SCS_THREAD_MAIN
      sThread = "#SCS_THREAD_MAIN"
    Case #SCS_THREAD_CONTROL
      sThread = "#SCS_THREAD_CONTROL"
    Case #SCS_THREAD_BLENDER
      sThread = "#SCS_THREAD_BLENDER"
    Case #SCS_THREAD_RS232_RECEIVE
      sThread = "#SCS_THREAD_RS232_RECEIVE"
    Case #SCS_THREAD_SLIDER_FILE_LOADER
      sThread = "#SCS_THREAD_SLIDER_FILE_LOADER"
    Case #SCS_THREAD_NETWORK
      sThread = "#SCS_THREAD_NETWORK"
    Case #SCS_THREAD_MTC_CUES
      sThread = "#SCS_THREAD_MTC_CUES"
    Case #SCS_THREAD_CTRL_SEND
      sThread = "#SCS_THREAD_CTRL_SEND"
    Case #SCS_THREAD_DMX_SEND
      sThread = "#SCS_THREAD_DMX_SEND"
    Case #SCS_THREAD_DMX_RECEIVE
      sThread = "#SCS_THREAD_DMX_RECEIVE"
    Case #SCS_THREAD_COLLECT_FILES
      sThread = "#SCS_THREAD_COLLECT_FILES"
    Case #SCS_THREAD_GET_FILE_STATS
      sThread = "#SCS_THREAD_GET_FILE_STATS"
    Case #SCS_THREAD_SYSTEM_MONITOR
      sThread = "#SCS_THREAD_SYSTEM_MONITOR"
    Case #SCS_THREAD_SCS_LTC
      sThread = "#SCS_THREAD_SCS_LTC"
    Default
      sThread = Str(nThreadIndex)
  EndSelect
  ProcedureReturn sThread
EndProcedure

Procedure.s THR_decodeThread(hThread)
  Protected sThread.s, n, nThreadIndex
  
  nThreadIndex = -1
  If hThread <> 0
    For n = 0 To ArraySize(gaThread())
      If gaThread(n)\hThread = hThread
        nThreadIndex = n
        Break
      EndIf
    Next n
  EndIf
  If nThreadIndex >= 0
    sThread = THR_decodeThreadIndex(nThreadIndex)
  Else
    sThread = Str(hThread)
  EndIf
  ProcedureReturn sThread
  
EndProcedure

Procedure.s THR_decodeThreadState(nThreadState)
  Protected sThreadState.s
  Select nThreadState
    Case #SCS_THREAD_STATE_NOT_CREATED
      sThreadState = "#SCS_THREAD_STATE_NOT_CREATED"
    Case #SCS_THREAD_STATE_ACTIVE
      sThreadState = "#SCS_THREAD_STATE_ACTIVE"
    Case #SCS_THREAD_STATE_SUSPENDED
      sThreadState = "#SCS_THREAD_STATE_SUSPENDED"
    Case #SCS_THREAD_STATE_STOPPED
      sThreadState = "#SCS_THREAD_STATE_STOPPED"
    Default
      sThreadState = Str(nThreadState)
  EndSelect
  ProcedureReturn sThreadState
EndProcedure

Procedure THR_assertThreadProc(nReqdThreadNo, pProcName.s)
  ; Use to ensure a function is being called from an appropriate thread.
  ; Usually used for any activity that creates, resizes or move screen objects as these must happen in the main thread (#SCS_THREAD_MAIN).
  ; Throws a run-time error if the thread assertion fails, so hopefully this will always be caught and fixed during testing.
  PROCNAMEC()
  Protected sMsg.s
  
  If (nReqdThreadNo = #SCS_THREAD_MAIN) And (gnThreadNo = #SCS_THREAD_ZERO)
    ; ok - gnThreadNo = 0 may be due to ASSERT_THREAD being called (possibly indirectly) from a MIDI In process or similar,
    ; and #SCS_THREAD_MAIN is effectively the same thread
  ElseIf gnThreadNo <> nReqdThreadNo
    gbForceTracing = #True
    ; no language translation - we want this in English!
    sMsg = "SCS Thread assertion failed."
    sMsg + Chr(10) + Chr(10) + pProcName + " expected thread " + THR_decodeThreadIndex(nReqdThreadNo) + ", but current thread is " + THR_decodeThreadIndex(gnThreadNo) + "."
    sMsg + Chr(10) + Chr(10) + "SCS version: " + #SCS_VERSION + " (" + #SCS_PROCESSOR + ")"
    sMsg + Chr(10) + Chr(10) + "Please report this problem to " + #SCS_EMAIL_SUPPORT
    sMsg + Chr(10) + Chr(10) + "Program closing."
    debugMsg(sProcName, sMsg)
    scsMessageRequester("SCS Thread Assertion Failed", sMsg, #PB_MessageRequester_Error)
    Debug "THR_assertThreadProc: closeLogFile()"
    closeLogFile()
    Debug "THR_assertThreadProc: Delay(1000)"
    Delay(1000)
    Debug "THR_assertThreadProc: End"
    End
  EndIf
EndProcedure

; EOF