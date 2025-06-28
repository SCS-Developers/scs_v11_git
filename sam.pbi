; File: sam.pbi

;- SAM - Special Action Manager

; -------------------------------------------------------------------------------------
; Please see the notes at the start of doMainThreadRequests() in WindowEventHandler.pbi
; -------------------------------------------------------------------------------------

; SAM requests are added using samAddRequest(). This Macro and it's associated Procedure accept a number of parameters of different types, eg integer, string, float.
; The request is placed in an array (gaSamArray()), and samAddRequest() calls can be made from any thread. The processing loop in the main thread checks gaSamArray()
; for any requests ready to be processed (some requests will have a time delay specified), and will call samProcess() for any request that is ready to be processed.
; Procedure samProcess() will then mark that entry in gaSamArray() as 'actioned'.
; Rather than collapse the array to remove 'actioned' entries, tow pointers are maintained - grMain\nSamReadPtr and grMain\nSamWritePtr. There's fairly complex code
; associated with maintaining these pointers correctly and reusing gaSamArray() entries, but it works! In hindsight, it may have been better to use a PureBasic List
; (also know as a linked list) so that 'actioned' entries can be removed using DeleteElement().

EnableExplicit

Procedure samInit()
  PROCNAMEC()
  Protected n
  Protected bLockedMutex
  Protected nSamRequestsWaiting
  Protected qEarliestTimeRequested.q
  Protected nEarliestSamPtr = -1
  
  debugMsg(sProcName, #SCS_START)
  
  gnCallOpenNextCues = 0
  debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
  gbCallPopulateGrid = #False
  gbCallLoadDispPanels = #False
  debugMsg(sProcName, "gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
  debugMsg(sProcName, "setting gbCallSetGoButton = #False")
  gbCallSetGoButton = #False
  gbCallSetNavigateButtons = #False
  gbCallRefreshDispPanel = #False
  
  With grMain
    If gbClosingDown = #False
      LockCueListMutex(41)
      If \nSamSize = 0
        \nSamSize = ArraySize(gaSamArray())
      EndIf
      For n = 0 To \nSamSize
        If (gaSamArray(n)\nSamRequest = #SCS_SAM_RAI_REQUEST) And (gaSamArray(n)\bActioned = #False)
          ; leave unactioned remote app requests in stack if not closing down, as these may be requests for info such as "/_info/finalcue"
          nSamRequestsWaiting + 1
          If nEarliestSamPtr = -1
            qEarliestTimeRequested = gaSamArray(n)\qTimeRequestAdded
            nEarliestSamPtr = n
          ElseIf (gaSamArray(n)\qTimeRequestAdded - qEarliestTimeRequested) < 0
            qEarliestTimeRequested = gaSamArray(n)\qTimeRequestAdded
            nEarliestSamPtr = n
          EndIf
        Else
          ; clear other requests
          gaSamArray(n)\nSamRequest = 0
          gaSamArray(n)\bActioned = #True
        EndIf
      Next n
      If nSamRequestsWaiting > 0
        \nSamRequestsWaiting = nSamRequestsWaiting
        \nSamReadPtr = nEarliestSamPtr
      Else
        \nSamReadPtr = 0
        \nSamWritePtr = 0
      EndIf
      UnlockCueListMutex()
    Else
      ; no need to lock cue list mutex if closing down
      \nSamReadPtr = 0
      \nSamWritePtr = 0
      \nSamRequestsWaiting = 0
      For n = 0 To \nSamSize
        gaSamArray(n)\nSamRequest = 0
        gaSamArray(n)\bActioned = #True
      Next n
    EndIf
  EndWith
  
  ;debugMsg(sProcName, "calling samListAllRequests()")
  ;samListAllRequests()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure samAddRequestProc(pProcName.s, pRequest, p1Long=0, p2Single.f=0, p3Long=0, p4String.s="", qNotBefore.q=0, p5Long=0, pCuePtrForRequestTime=-1, pReplaceNotBefore=#True, bFullDuplicateTest=#False, p6Quad.q=0, p7Long=0, p8String.s="")
  ; -------------------------------------------------------------------------------------
  ; Please see the notes at the start of doMainThreadRequests() in WindowEventHandler.pbi
  ; -------------------------------------------------------------------------------------
  ; see also Macro samAddRequest()
  PROCNAME(pProcName + ": samAddRequest")
  Protected n, bFound
  Protected nRequestsWaiting
  Protected bLockedMutex
  Protected bNewRequestAdded
  Protected nNewWritePtr, bNewSlotFound
  Protected nRequest, bLockMutexReqd
  
  ; debugMsg(sProcName, #SCS_START + ", pRequest=" + pRequest + ", p1Long=" + p1Long + ", p3Long=" + p3Long + ", p5Long=" + p5Long + ", p6Quad=" + p6Quad + ", p7Long=" + p7Long)
  
  nRequest = pRequest & $FFFF
  
  If nRequest = #SCS_SAM_LOAD_GRID_ROW
    If (p1Long >= 0) And (p1Long <= gnLastCue)
      If getHideCueOpt(p1Long) = #SCS_HIDE_ENTIRE_CUE
        ; ignore this request to load the grid row for this cue as the cue is to be hidden
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  If pRequest & $10000 = 0
    bLockMutexReqd = #True
  EndIf
  
  If bLockMutexReqd
    CompilerIf #cTraceMutexLocks ; Or 1=1
      ; macro expanded 07Jul2015 to try to locate actual line number of memory error reported by Sebastian Franke
      Protected nLockNo = 42
      If gnCueListMutexLockThread <> gnThreadNo
        If gnTraceMutexLocking > 0
          If gnCueListMutexLockThread > 0
            debugMsg3(sProcName, "calling LockMutex(gnCueListMutex), nLockNo=" + nLockNo + ", gnCueListMutexLockThread=" + gnCueListMutexLockThread +
                                 ", gnCueListMutexLockNo=" + gnCueListMutexLockNo + ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime))
          Else
            debugMsg3(sProcName, "calling LockMutex(gnCueListMutex), nLockNo=" + nLockNo + ", gnCueListMutexLockThread=" + gnCueListMutexLockThread)
          EndIf
        EndIf
        scsLockMutex(gnCueListMutex, #SCS_MUTEX_CUE_LIST, nLockNo)
        If gnTraceMutexLocking > 0
          debugMsg3(sProcName, "gnCueListMutex locked, nLockNo=" + nLockNo)
        EndIf
        gnCueListMutexLockThread = gnThreadNo
        gnCueListMutexLockNo = nLockNo
        gqCueListMutexLockTime = ElapsedMilliseconds()
      EndIf
    CompilerElse
      LockCueListMutex(42)
    CompilerEndIf
  EndIf
  
  With grMain
    
    ; debugMsg(sProcName, "nRequest=" + nRequest + ", \nSamRequestsWaiting=" + \nSamRequestsWaiting)
    
    If (gbEditing) And (gbSetEditorWindowActive = #False)
      If GetActiveWindow() = #WED
        If (nRequest <> #SCS_SAM_SET_EDIT_WINDOW_ACTIVE) And (nRequest <> #SCS_SAM_CLOSE_EDITOR)
          ; debugMsg(sProcName, "nRequest=" + nRequest + ", setting gbSetEditorWindowActive(" + strB(gbSetEditorWindowActive) + ")=#True")
          gbSetEditorWindowActive = #True   ; cause control thread to reactivate editor window if necessary (via SAM)
        EndIf
      EndIf
    EndIf
    
    If nRequest < 2000
      ; if nRequest < 2000, don't add this request if an identical request is already waiting
      If \nSamRequestsWaiting > 0
        For n = 0 To \nSamSize
          If (gaSamArray(n)\nSamRequest = nRequest) And (gaSamArray(n)\bActioned = #False) And (gaSamArray(n)\p1Long = p1Long)
            If (bFullDuplicateTest = #False) Or
               (gaSamArray(n)\p2Single = p2Single And gaSamArray(n)\p3Long = p3Long And gaSamArray(n)\p4String = p4String And gaSamArray(n)\p5Long = p5Long And gaSamArray(n)\p6Quad = p6Quad And gaSamArray(n)\p7Long = p7Long)
              If pReplaceNotBefore
                If (qNotBefore - gaSamArray(n)\qNotBefore) > 0
                  gaSamArray(n)\qNotBefore = qNotBefore
                EndIf
              EndIf
              Select nRequest
                Case #SCS_SAM_SET_SLD_BUTTON_POSITION, #SCS_SAM_UPDATE_GRID, #SCS_SAM_CHECK_MAIN_HAS_FOCUS, #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE, #SCS_SAM_SET_FOCUS_TO_SCS, #SCS_SAM_LOAD_NEXT_CUE_PANELS, #SCS_SAM_LOAD_GRID_ROW, #SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW
                  ; do not log
                Default
                  debugMsg(sProcName, "Request " + decodeSamRequest(nRequest, n) + "(" + p1Long + ") already in queue - ignored, \qNotBefore=" + traceTime(gaSamArray(n)\qNotBefore) +
                                      ", gqSamProcessLastStarted=" + traceTime(gqSamProcessLastStarted) + ", gqSamProcessLastEnded=" + traceTime(gqSamProcessLastEnded) +
                                      ", gqThreadMainLoopStarted=" + traceTime(gqThreadMainLoopStarted) + ", gqThreadMainEventStarted=" + traceTime(gqThreadMainEventStarted) +
                                      ", gqThreadMainLoopEnded=" + traceTime(gqThreadMainLoopEnded) + ", gqPriorityPostEventWaiting=" + traceTime(gqPriorityPostEventWaiting) + ", gnMainThreadContinueLine=" + gnMainThreadContinueLine)
                  debugMsg(sProcName, "... gnLabelOther=" + gnLabelOther + ", gnLabelThread=#" + gnLabelThread + ", gnLabel=" + gnLabel + ", gnLabelSAM=" + gnLabelSAM +
                                      ", gnLabelUpdDispPanels=" + gnLabelUpdDispPanels + ", gnLabelUpdDispPanel=" + gnLabelUpdDispPanel + ", gnLabelReposAuds=" + gnLabelReposAuds +
                                      ", gnLabelSlider=" + gnLabelSlider + ", gnLabelStatusCheck=" + gnLabelStatusCheck + ", gnMainThreadLabel=" + gnMainThreadLabel)
                  ; samListRequestsWaiting()
              EndSelect
              bFound = #True
              Break
            EndIf
          EndIf
        Next n
      EndIf
      
    ElseIf nRequest < 3000
      ; if nRequest in the range 2000-2999, if an identical unprocessed request is already waiting then replace it with the new request
      If \nSamRequestsWaiting > 0
        For n = 0 To \nSamSize
          If (gaSamArray(n)\nSamRequest = nRequest) And (gaSamArray(n)\bActioned = #False) And (gaSamArray(n)\p1Long = p1Long)
            If (bFullDuplicateTest = #False) Or
               (gaSamArray(n)\p2Single = p2Single And gaSamArray(n)\p3Long = p3Long And gaSamArray(n)\p4String = p4String And gaSamArray(n)\p5Long = p5Long And gaSamArray(n)\p6Quad = p6Quad And gaSamArray(n)\p7Long = p7Long)
              If pReplaceNotBefore
                If (qNotBefore - gaSamArray(n)\qNotBefore) > 0
                  gaSamArray(n)\qNotBefore = qNotBefore
                EndIf
              EndIf
              gaSamArray(n)\p2Single = p2Single
              gaSamArray(n)\p3Long = p3Long
              gaSamArray(n)\p4String = p4String
              gaSamArray(n)\p5Long = p5Long
              gaSamArray(n)\p6Quad = p6Quad
              gaSamArray(n)\p7Long = p7Long
              gaSamArray(n)\p8String = p8String
              gaSamArray(\nSamWritePtr)\bActioned = #True ; cancel new request as the old request has been updated with the new request's details
              Select nRequest
                Case #SCS_SAM_REPOS_SPLITTER
                  ; do not log
                Default
                  debugMsg(sProcName, "Request " + decodeSamRequest(nRequest, n) + "(" + p1Long + ") already in queue - replaced")
              EndSelect
              bFound = #True
              Break
            EndIf
          EndIf
        Next n
      EndIf
      
    ElseIf nRequest < 4000
      ; if nRequest in the range 3000-3999, same as 2000-2999 except that p3Long is also checked in the duplication test
      If \nSamRequestsWaiting > 0
        For n = 0 To \nSamSize
          If (gaSamArray(n)\nSamRequest = nRequest) And (gaSamArray(n)\bActioned = #False) And (gaSamArray(n)\p1Long = p1Long) And (gaSamArray(n)\p3Long = p3Long)
            If (bFullDuplicateTest = #False) Or
               (gaSamArray(n)\p2Single = p2Single And gaSamArray(n)\p4String = p4String And gaSamArray(n)\p5Long = p5Long And gaSamArray(n)\p6Quad = p6Quad And gaSamArray(n)\p7Long = p7Long)
              If pReplaceNotBefore
                If (qNotBefore - gaSamArray(n)\qNotBefore) > 0
                  gaSamArray(n)\qNotBefore = qNotBefore
                EndIf
              EndIf
              gaSamArray(n)\p2Single = p2Single
              gaSamArray(n)\p4String = p4String
              gaSamArray(n)\p5Long = p5Long
              gaSamArray(n)\p6Quad = p6Quad
              gaSamArray(n)\p7Long = p7Long
              gaSamArray(n)\p8String = p8String
              gaSamArray(\nSamWritePtr)\bActioned = #True ; cancel new request as the old request has been updated with the new request's details
              bFound = #True
              Break
            EndIf
          EndIf
        Next n
      EndIf
      
    ElseIf nRequest < 5000
      ; if nRequest in the range 4000-4999, process request even if a duplicate already exists
      ; no further action required here
      
    ElseIf nRequest < 6000
      ; if nRequest in the range 5000-5999, if an identical unprocessed request code, regardless of parameter values, is already waiting then replace it with the new request
      If \nSamRequestsWaiting > 0
        For n = 0 To \nSamSize
          If (gaSamArray(n)\nSamRequest = nRequest) And (gaSamArray(n)\bActioned = #False)
            If pReplaceNotBefore
              If (qNotBefore - gaSamArray(n)\qNotBefore) > 0
                gaSamArray(n)\qNotBefore = qNotBefore
              EndIf
            EndIf
            gaSamArray(n)\p1Long = p1Long
            gaSamArray(n)\p2Single = p2Single
            gaSamArray(n)\p3Long = p3Long
            gaSamArray(n)\p4String = p4String
            gaSamArray(n)\p5Long = p5Long
            gaSamArray(n)\p6Quad = p6Quad
            gaSamArray(n)\p7Long = p7Long
            gaSamArray(n)\p8String = p8String
            gaSamArray(\nSamWritePtr)\bActioned = #True ; cancel new request as the old request has been updated with the new request's details
            Select nRequest
              Case #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS
                ; do not log
              Default
                debugMsg(sProcName, "Request " + n + " replaced with " + decodeSamRequest(nRequest, n))
            EndSelect
            bFound = #True
            Break
          EndIf
        Next n
      EndIf
    EndIf
    
    If bFound = #False
      bNewRequestAdded = #True
      gaSamArray(\nSamWritePtr)\nSamRequest = nRequest
      ; debugMsg(sProcName, "gaSamArray(" + \nSamWritePtr + ")\nSamRequest=" + gaSamArray(\nSamWritePtr)\nSamRequest)
      gaSamArray(\nSamWritePtr)\bActioned = #False
      gaSamArray(\nSamWritePtr)\qNotBefore = qNotBefore
      gaSamArray(\nSamWritePtr)\qTimeRequestAdded = ElapsedMilliseconds()
      If gbStoppingEverything Or gbSamRequestUnderStoppingEverything
        gaSamArray(\nSamWritePtr)\bUnderStoppingEverything = #True
      Else
        gaSamArray(\nSamWritePtr)\bUnderStoppingEverything = #False
      EndIf
      If nRequest < 1000
        gaSamArray(\nSamWritePtr)\p1Long = 0
        gaSamArray(\nSamWritePtr)\p2Single = 0
        gaSamArray(\nSamWritePtr)\p3Long = 0
        gaSamArray(\nSamWritePtr)\p4String = ""
        gaSamArray(\nSamWritePtr)\p5Long = 0
        gaSamArray(\nSamWritePtr)\p6Quad = 0
        gaSamArray(\nSamWritePtr)\p7Long = 0
        gaSamArray(\nSamWritePtr)\p8String = ""
      Else
        gaSamArray(\nSamWritePtr)\p1Long = p1Long
        gaSamArray(\nSamWritePtr)\p2Single = p2Single
        gaSamArray(\nSamWritePtr)\p3Long = p3Long
        gaSamArray(\nSamWritePtr)\p4String = p4String
        gaSamArray(\nSamWritePtr)\p5Long = p5Long
        gaSamArray(\nSamWritePtr)\p6Quad = p6Quad
        gaSamArray(\nSamWritePtr)\p7Long = p7Long
        gaSamArray(\nSamWritePtr)\p8String = p8String
      EndIf
      
      Select nRequest
        Case #SCS_SAM_PLAY_SUB, #SCS_SAM_STOP_SUB, #SCS_SAM_SET_GO_BUTTON
          gaSamArray(\nSamWritePtr)\nSamPriority = #SCS_SAMPRIORITY_HIGH
        Case #SCS_SAM_LOAD_GRID_ROW
          gaSamArray(\nSamWritePtr)\nSamPriority = #SCS_SAMPRIORITY_LOW
        Default
          gaSamArray(\nSamWritePtr)\nSamPriority = #SCS_SAMPRIORITY_NORMAL
      EndSelect
      
      Select nRequest
        Case #SCS_SAM_UPDATE_GRID, #SCS_SAM_CHANNEL_SLIDE, #SCS_SAM_CHECK_MAIN_HAS_FOCUS, #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE, #SCS_SAM_SET_SLD_BUTTON_POSITION, #SCS_SAM_LOAD_NEXT_CUE_PANELS, #SCS_SAM_LOAD_GRID_ROW,
             #SCS_SAM_SET_GO_BUTTON, #SCS_SAM_SET_NAVIGATE_BUTTONS, #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS, #SCS_SAM_DRAW_GRAPH
          ; do not log
        Default
          If gbStoppingEverything Or gbSamRequestUnderStoppingEverything Or gaSamArray(\nSamWritePtr)\bUnderStoppingEverything
            debugMsg(sProcName, "nSamWritePtr=" + \nSamWritePtr + ", request " + decodeSamRequest(nRequest, \nSamWritePtr) +
                                ", gbStoppingEverything=" + strB(gbStoppingEverything) + ", gbSamRequestUnderStoppingEverything=" + strB(gbSamRequestUnderStoppingEverything) +
                                ", \bUnderStoppingEverything=" + strB(gaSamArray(\nSamWritePtr)\bUnderStoppingEverything))
          Else
            debugMsg(sProcName, "nSamWritePtr=" + \nSamWritePtr + ", request " + decodeSamRequest(nRequest, \nSamWritePtr))
          EndIf
      EndSelect
      
      gaSamArray(\nSamWritePtr)\nCuePtrForRequestTime = pCuePtrForRequestTime
      If pCuePtrForRequestTime > 0
        ; the following field is used to stop the control thread checking this cue until the request has been processed
        aCue(pCuePtrForRequestTime)\qMainThreadRequestTime = ElapsedMilliseconds()
      EndIf
      
      For n = 0 To \nSamSize
        If (gaSamArray(n)\bActioned = #False) And (gaSamArray(n)\nSamRequest <> 0)
          nRequestsWaiting + 1
        EndIf
      Next n
      \nSamRequestsWaiting = nRequestsWaiting
      
      bNewSlotFound = #False
      While #True
        nNewWritePtr = \nSamWritePtr
        For n = 0 To \nSamSize
          nNewWritePtr + 1
          If nNewWritePtr > \nSamSize
            nNewWritePtr = 0
          EndIf
          If (gaSamArray(nNewWritePtr)\nSamRequest = 0) Or (gaSamArray(nNewWritePtr)\bActioned)
            bNewSlotFound = #True
            Break
          EndIf
        Next n
        If bNewSlotFound
          Break
        Else
          ; sam array full, so extend it
          \nSamSize + 10
          ReDim gaSamArray(\nSamSize)
          ; nb no need to initialise the new entries in the array - see comment in samInit()
          debugMsg(sProcName, "gaSamArray() extended, new \nSamSize=" + \nSamSize)
        EndIf
      Wend
      \nSamWritePtr = nNewWritePtr
      
      ; debugMsg(sProcName, "\nSamRequestsWaiting=" + \nSamRequestsWaiting)
      
    EndIf
    
  EndWith
  
  If bLockMutexReqd
    ; UnlockMutex(gnSamMutex)
    UnlockCueListMutex()
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  ProcedureReturn bNewRequestAdded
  
EndProcedure

Procedure samCancelRequest(nRequest, p1Long=0)
  PROCNAMEC()
  Protected n, nRequestsWaiting
  ; Protected bLockedMutex
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; LockCueListMutex(422)
  
  For n = 0 To grMain\nSamSize
    With gaSamArray(n)
      If \nSamRequest = nRequest
        If p1Long = 0 Or \p1Long = p1Long
          If \bActioned = #False
            debugMsg(sProcName, "cancelling " + decodeSamRequest(nRequest, n))
            \bActioned = #True
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  For n = 0 To grMain\nSamSize
    If (gaSamArray(n)\bActioned = #False) And (gaSamArray(n)\nSamRequest <> 0)
      nRequestsWaiting + 1
    EndIf
  Next n
  grMain\nSamRequestsWaiting = nRequestsWaiting
  
  ; UnlockCueListMutex()
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure samProcess()
  ; -------------------------------------------------------------------------------------
  ; Please see the notes at the start of doMainThreadRequests() in WindowEventHandler.pbi
  ; -------------------------------------------------------------------------------------
  PROCNAMEC()
  Protected nThisRequest
  Protected bLeaveRequestInList, nLeaveCount
  Protected nNodeKey
  Protected nBassResult.l
  Protected nChannel.l, fLevel.f, nTime, qTime.q
  Protected nReadPtrFirstLeft
  Protected bBoolean
  Protected bLoadNextCuePanelsCalled
  ; flags for calls that must be executed in a set order
  Protected bSetCuePanels
  Protected bLoadDispPanels
  Protected nMyBassChannel.l
  Protected nAbsReposAt
  Protected p1, p2.f, p3, p4.s, p5, p6.q, p7, p8.s
  Protected fBVLevel.f, fPan.f
  Protected nCuePtrForRequestTime
  Protected bLockedMutex, bLockReqd
  Protected nLoopCount
  Protected n, nRequestsWaiting
  Static nLockFailedMsgCount, nLastLockFailedMsgTime
  Protected bTraceLockFailedMsg
  Protected nDMXControlPtr
  Protected nSamPriority, nStartReadPtr
  Protected bUsePriority = #False, nFirstPriority, nLastPriority
  Protected nDevMapDevPtr
  
  gqSamProcessLastStarted = ElapsedMilliseconds()
  
  If (gbClosingDown) Or (gbStoppingEverything) ; Or (gbInitialising)
    If gbClosingDown
      ; clear SAM stack (should already have been done but a timing issue could cause samProcess() to be called again, as per trace files from Stas Ushomirsky 29/11/2012)
      samInit()
    EndIf
    ; debugMsg(sProcName, "exiting - gbClosingDown=" + strB(gbClosingDown) + ", gbStoppingEverything=" + strB(gbStoppingEverything) + ", gbInitialising=" + strB(gbInitialising))
    ProcedureReturn
  EndIf
  
  LockCueListMutex(44)
  
  gbInSamProcess = #True
  nLeaveCount = 0
  nReadPtrFirstLeft = -1
  gnSamRequestsProcessed = 0
  
  gnLabelSAM = 10000
  gqTimeNow = ElapsedMilliseconds()
  nStartReadPtr = grMain\nSamReadPtr
  If bUsePriority
    nFirstPriority = #SCS_SAMPRIORITY_HIGH
    nLastPriority = #SCS_SAMPRIORITY_LOW
  EndIf
  For nSamPriority = nFirstPriority To nLastPriority
    grMain\nSamReadPtr = nStartReadPtr
    While (grMain\nSamRequestsWaiting - nLeaveCount) > 0
      
      gnLabelSAM = 11000
      
      ; debugMsg(sProcName, "gaSamArray(" + grMain\nSamReadPtr + ")\nSamRequest=" + decodeSamRequest(gaSamArray(grMain\nSamReadPtr)\nSamRequest, grMain\nSamReadPtr) +
      ;                     ", \bActioned=" + strB(gaSamArray(grMain\nSamReadPtr)\bActioned) +
      ;                     ", \qNotBefore=" + traceTime(gaSamArray(grMain\nSamReadPtr)\qNotBefore) + ", gqTimeNow=" + traceTime(gqTimeNow) +
      ;                     ", \nSamPriority=" + gaSamArray(grMain\nSamReadPtr)\nSamPriority + ", nSamPriority=" + nSamPriority)
      
      If gaSamArray(grMain\nSamReadPtr)\bActioned = #False
        
        If bUsePriority
          If gaSamArray(grMain\nSamReadPtr)\nSamPriority <> nSamPriority
            grMain\nSamReadPtr + 1
            If grMain\nSamReadPtr > grMain\nSamSize
              grMain\nSamReadPtr = 0
            EndIf
            Continue
          EndIf
        EndIf
        
        nThisRequest = gaSamArray(grMain\nSamReadPtr)\nSamRequest
        bLeaveRequestInList = #False
        If gaSamArray(grMain\nSamReadPtr)\qNotBefore <> 0
          If (gaSamArray(grMain\nSamReadPtr)\qNotBefore - gqTimeNow) > 0
            ; debugMsg(sProcName, "LEAVE IN LIST: gaSamArray(" + grMain\nSamReadPtr + ")\qNotBefore=" + traceTime(gaSamArray(grMain\nSamReadPtr)\qNotBefore) +
            ;                     ", gqTimeNow=" + traceTime(gqTimeNow) + ", nThisRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr))
            bLeaveRequestInList = #True
          EndIf
        EndIf
        If (gbPictureBlending) And (bLeaveRequestInList = #False)
          Select nThisRequest
            Case #SCS_SAM_LOAD_CUE_PANELS, #SCS_SAM_LOAD_GRID_ROW, #SCS_SAM_OPEN_NEXT_CUES, #SCS_SAM_OPEN_NEXT_CUES_ONE_CUE_ONLY, #SCS_SAM_SET_CUE_TO_GO
              ; leave the request in the list to help reduce video cross-fade stuttering
              bLeaveRequestInList = #True
            Case #SCS_SAM_START_NETWORK, #SCS_SAM_OPEN_RS232_PORTS
              If gbInitialising
                bLeaveRequestInList = #True
              EndIf
          EndSelect
        EndIf
        If bLeaveRequestInList
          nLeaveCount + 1
        Else
          If ((nThisRequest <> #SCS_SAM_CHANNEL_SLIDE) Or (#cTraceSetLevels))
            Select nThisRequest
              Case #SCS_SAM_UPDATE_GRID, #SCS_SAM_CHECK_MAIN_HAS_FOCUS, #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE, #SCS_SAM_SET_SLD_BUTTON_POSITION, #SCS_SAM_LOAD_NEXT_CUE_PANELS, #SCS_SAM_LOAD_GRID_ROW, #SCS_SAM_DRAW_GRAPH
                ; no trace
              Default
                If nSamPriority = #SCS_SAMPRIORITY_NORMAL
                  debugMsg(sProcName, "nSamReadPtr=" + grMain\nSamReadPtr + ", nSamRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr) + ", p1Long=" + gaSamArray(grMain\nSamReadPtr)\p1Long)
                Else
                  debugMsg(sProcName, "nSamReadPtr=" + grMain\nSamReadPtr + ", nSamRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr) + ", nSamPriority=" + decodeSamPriority(nSamPriority) + ", p1Long=" + gaSamArray(grMain\nSamReadPtr)\p1Long)
                EndIf
            EndSelect
          EndIf
          
          p1 = gaSamArray(grMain\nSamReadPtr)\p1Long
          
          gnLabelSAM = 20000 + nThisRequest
          
          If gbSamRequestUnderStoppingEverything <> gaSamArray(grMain\nSamReadPtr)\bUnderStoppingEverything
            gbSamRequestUnderStoppingEverything = gaSamArray(grMain\nSamReadPtr)\bUnderStoppingEverything
            debugMsg(sProcName, "nSamReadPtr=" + grMain\nSamReadPtr + ", nSamRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr) +
                                ", p1Long=" + gaSamArray(grMain\nSamReadPtr)\p1Long +
                                ", (a) gbSamRequestUnderStoppingEverything=" + strB(gbSamRequestUnderStoppingEverything))
          EndIf
          
          gqSamTimeLastRequestStarted = ElapsedMilliseconds()
          gnSamLastRequestProcessed = nThisRequest
          
          Select nThisRequest
              
            Case #SCS_SAM_BUILD_DEV_CHANNEL_LIST ; #SCS_SAM_BUILD_DEV_CHANNEL_LIST
              debugMsg(sProcName, "calling buildDevChannelList(" + p1 + ")")
              buildDevChannelList(p1)
              
            Case #SCS_SAM_CALL_MODRETURN_FUNCTION ; #SCS_SAM_CALL_MODRETURN_FUNCTION
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              Select p1
                Case #SCS_MODRETURN_IMPORT
                  WIM_displayOtherProdInfo()
                  
                Case #SCS_MODRETURN_IMPORT_DEVS
                  WID_displayOtherProdInfo()
                  
                Case #SCS_MODRETURN_F_OR_P
                  Select p3
                    Case 1
                      WED_importAudioFiles(#SCS_IMPORT_AUDIO_CUES)
                    Case 2
                      WED_importAudioFiles(#SCS_IMPORT_PLAYLIST)
                    Default
                      WED_importAudioFiles(#SCS_IMPORT_CANCEL)
                  EndSelect
                  
                Case #SCS_MODRETURN_CREATE_PROD_FOLDER, #SCS_MODRETURN_RESYNC_PROD_FOLDER
                  WED_mnuCreateOrResyncProdFolder_ModReturn(p3)
                  
                Case #SCS_MODRETURN_FILE_OPENER
                  WFO_ModReturn(p3)
                  
                Case #SCS_MODRETURN_FILE_RENAME
                  WFR_renameAudFileModReturn(p3)
                  
                Case #SCS_MODRETURN_LOADPROD
                  If IsWindow(#WLP) ; #WLP may have been closed before this SAM command is processed
                    WLP_refresh()
                  EndIf
                  
              EndSelect
              
            Case #SCS_SAM_CHANGE_TIME_PROFILE ; #SCS_SAM_CHANGE_TIME_PROFILE
              WTP_changeTimeProfile()
              
            Case #SCS_SAM_CHANNEL_SLIDE ; #SCS_SAM_CHANNEL_SLIDE
              ;debugMsg3(sProcName, "Channel_Slide")
              nChannel = p1
              fLevel = gaSamArray(grMain\nSamReadPtr)\p2Single
              nTime = gaSamArray(grMain\nSamReadPtr)\p3Long
              ; Added 28Sep2022 11.9.6
              If fLevel <= grLevels\fMinBVLevel
                fLevel = 0.0
              EndIf
              ; End added 28Sep2022 11.9.6
              nBassResult = BASS_ChannelSlideAttribute(nChannel, #BASS_ATTRIB_VOL, fLevel, nTime)
              CompilerIf #cTraceSetLevels Or 1=1
                debugMsg2(sProcName, "BASS_ChannelSlideAttribute(" + decodeHandle(nChannel) + ", #BASS_ATTRIB_VOL, " + formatLevel(fLevel) + ", " + nTime + ")", nBassResult)
              CompilerEndIf
              
            Case #SCS_SAM_CHECK_MAIN_HAS_FOCUS ; #SCS_SAM_CHECK_MAIN_HAS_FOCUS
              checkMainHasFocus(p1)
              
            Case #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE ; #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE
              checkPauseAllActive(p1)
              
            Case #SCS_SAM_CHECK_USING_PLAYBACK_RATE_CHANGE_ONLY
              checkUsingPlaybackRateChangeOnly()

            Case #SCS_SAM_CLEAR_POSITIONING_MIDI  ; SCS_SAM_CLEAR_POSITIONING_MIDI
              gnPositioningMidi - 1
              If gnPositioningMidi < 0
                ; shouldn't happen
                gnPositioningMidi = 0
              EndIf
              
            Case #SCS_SAM_CLEAR_VIDEO_CANVAS_IF_NOT_IN_USE ; #SCS_SAM_CLEAR_VIDEO_CANVAS_IF_NOT_IN_USE
              clearVideoCanvasIfNotInUse(p1)
              
            Case #SCS_SAM_CLOSE_EDITOR  ; #SCS_SAM_CLOSE_EDITOR
              debugMsg(sProcName, "calling WED_delayedCloseEditor()")
              WED_delayedCloseEditor()
              
            Case #SCS_SAM_CLOSE_NETWORK_CONNECTION
              debugMsg(sProcName, "calling closeANetworkConnection(" + p1 + ")")
              closeANetworkConnection(p1)
              
            Case #SCS_SAM_COMPLETE_AUD  ; #SCS_SAM_COMPLETE_AUD
              completeAud(p1)
              
            Case #SCS_SAM_CREATE_TVG_CONTROL  ; #SCS_SAM_CREATE_TVG_CONTROL
              CompilerIf #c_include_tvg
                p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
                createTVGControl(p1, p3)
              CompilerEndIf
              
            Case #SCS_SAM_DISPLAY_CLOCK_IF_REQD  ; #SCS_SAM_DISPLAY_CLOCK_IF_REQD ; Added 3Dec2022 11.9.7ar
              displayTimeOfDayClockIfReqd()
              
            Case #SCS_SAM_DISPLAY_DMX_DISPLAY  ; #SCS_SAM_DISPLAY_DMX_DISPLAY
              WDD_displayDMXDisplayWindowIfReqd()
              
            Case #SCS_SAM_DISPLAY_FADERS  ; #SCS_SAM_DISPLAY_FADERS
              WCN_displayFadersWindowIfReqd()
              
            Case #SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS ; #SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS
              WMN_displayOrHideHotkeys()
              
            Case #SCS_SAM_DISPLAY_PICTURE ; #SCS_SAM_DISPLAY_PICTURE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              debugMsg(sProcName, "calling displayPicture(" + getAudLabel(p1) + ", " + p3 + ", " + strB(p5) + ")")
              displayPicture(p1, p3, p5)
              
            Case #SCS_SAM_DISPLAY_TIMER ; #SCS_SAM_DISPLAY_TIMER
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              WTI_displayTimer(p4, p3)
              
            Case #SCS_SAM_DISPLAY_THUMBNAILS  ; #SCS_SAM_DISPLAY_THUMBNAILS
              WQA_displaySubThumbnails2(p1)
              
            Case #SCS_SAM_DMX_CAPTURE_COMPLETE ; #SCS_SAM_DMX_CAPTURE_COMPLETE
              debugMsg(sProcName, "calling WQK_processDMXCaptureComplete(" + decodeDMXAPILabel(p1) + ")")
              WQK_processDMXCaptureComplete(p1)

            Case #SCS_SAM_DRAW_GRAPH  ; #SCS_SAM_DRAW_GRAPH
              Select p1
                Case 2
                  ; debugMsg(sProcName, "calling calcViewStartAndEnd(@grMG2, " + getAudLabel(nEditAudPtr) +")")
                  calcViewStartAndEnd(@grMG2, nEditAudPtr)
                  ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysAndDrawGraph(@grMG2)")
                  loadSlicePeakAndMinArraysAndDrawGraph(@grMG2)
                Case 5
                  ; debugMsg(sProcName, "calling calcViewStartAndEnd(@grMG5, " + getAudLabel(nEditAudPtr) +")")
                  calcViewStartAndEnd(@grMG5, nEditAudPtr)
                  ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysAndDrawGraph(@grMG5)")
                  loadSlicePeakAndMinArraysAndDrawGraph(@grMG5)
              EndSelect
              
            Case #SCS_SAM_EDITOR_BTN_CLICK  ; #SCS_SAM_EDITOR_BTN_CLICK
              debugMsg(sProcName, "calling WED_tbEditor_ButtonClick(" + p1 + ")")
              WED_tbEditor_ButtonClick(p1)
              
            Case #SCS_SAM_EDITOR_NODE_CLICK ; #SCS_SAM_EDITOR_NODE_CLICK
              If gbInNodeClick
                gbKillNodeClick = #True   ; try to kill current node click asap
                bLeaveRequestInList = #True
                nLeaveCount + 1
              ElseIf IsWindow(#WED) ; if form loaded then process request, otherwise throw it away
                nNodeKey = p1
                debugMsg(sProcName, "calling WED_publicNodeClick(" + nNodeKey + ")") ; Changed 15Jul2022
                WED_publicNodeClick(nNodeKey)
              EndIf
              
            Case #SCS_SAM_FMB_FILE_OPEN ; #SCS_SAM_FMB_FILE_OPEN
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              p8 = gaSamArray(grMain\nSamReadPtr)\p8String
              debugMsg(sProcName, "calling FMB_openCueFile(" + #DQUOTE$ + p4 + #DQUOTE$ + ", " + #DQUOTE$ + p8 + #DQUOTE$ + ")")
              FMB_openCueFile(p4, p8)
              
            Case #SCS_SAM_FREE_TVG_CONTROL  ; #SCS_SAM_FREE_TVG_CONTROL
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling freeTVGControl(" + p1 + ", " + strB(p3) + ")")
              freeTVGControl(p1, p3)
              debugMsg(sProcName, "returned from freeTVGControl(" + p1 + ", " + strB(p3) + ")")
              
            Case #SCS_SAM_GO  ; #SCS_SAM_GO
              debugMsg(sProcName, "calling WMN_processGo(#False, " + strB(p1) + ")")
              WMN_processGo(#False, p1)
              
            Case #SCS_SAM_GO_REMOTE  ; #SCS_SAM_GO_REMOTE
              processGoRemote(p1)
              
            Case #SCS_SAM_GO_WITH_EXPECTED_CUE  ; #SCS_SAM_GO_WITH_EXPECTED_CUE
              WMN_processGoWithExpectedCue(p1)
              
            Case #SCS_SAM_GO_WHEN_OK  ; #SCS_SAM_GO_WHEN_OK
              If (aCue(p1)\nCueState = #SCS_CUE_READY) Or (getToolBarBtnEnabled(#SCS_TBMB_GO))
                qTime = gaSamArray(grMain\nSamReadPtr)\p6Quad
                If (qTime - ElapsedMilliseconds()) > 0
                  setCueToCountDown(p1, qTime)
                Else
                  debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(p1) + ")")
                  playCueViaCas(p1)
                  debugMsg(sProcName, "calling setCueToGo()")
                  setCueToGo()
                EndIf
              Else
                bLeaveRequestInList = #True
                nLeaveCount + 1
              EndIf
              
            Case #SCS_SAM_GOTO_CUE, #SCS_SAM_GOTO_CUE_LATEST_ONLY  ; #SCS_SAM_GOTO_CUE, #SCS_SAM_GOTO_CUE_LATEST_ONLY
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long ; Added 10Jan2022 11.9af for #SCS_SAM_GOTO_CUE_LATEST_ONLY which is called when up/down arrow used to navigate through cue list
              p7 = gaSamArray(grMain\nSamReadPtr)\p7Long ; Ditto
              If p1 < gnCueEnd
                debugMsg(sProcName, "calling GoToCue(" + getCueLabel(p1) + ", #True, " + strB(p5) + ", " + strB(p7) + ")")
                GoToCue(p1, #True, p5, p7)
                If p3
                  debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(p1) + ")")
                  calcCueStartValues(p1)
                EndIf
              EndIf
              
            Case #SCS_SAM_GOTO_CUELIST_FOR_SHORTCUT ; #SCS_SAM_GOTO_CUELIST_FOR_SHORTCUT
              WMN_gotoCueListForShortcut(p1)
              
            Case #SCS_SAM_GOTO_SPECIAL  ; #SCS_SAM_GOTO_SPECIAL
              Select p1
                Case #SCS_GOTO_TOP
                  debugMsg(sProcName, "calling WMN_TopCue()")
                  WMN_TopCue()
                Case #SCS_GOTO_PREV
                  debugMsg(sProcName, "calling WMN_PrevCue()")
                  WMN_PrevCue()
                Case #SCS_GOTO_NEXT
                  debugMsg(sProcName, "calling WMN_NextCue()")
                  WMN_NextCue()
                Case #SCS_GOTO_END
                  debugMsg(sProcName, "calling WMN_EndCue()")
                  WMN_EndCue()
              EndSelect
              
            Case #SCS_SAM_HIDE_MTC_WINDOW_IF_INACTIVE  ; #SCS_SAM_HIDE_MTC_WINDOW_IF_INACTIVE
              WTC_hideWindowIfInactive()
              
            Case #SCS_SAM_HIDE_MEMO_ON_SECONDARY_SCREEN ; #SCS_SAM_HIDE_MEMO_ON_SECONDARY_SCREEN
              debugMsg(sProcName, "calling WEN_hideMemoOnSecondaryScreen(" + decodeVidPicTarget(p1) + ")")
              WEN_hideMemoOnSecondaryScreen(p1)
              
            Case #SCS_SAM_HIDE_PICTURE  ; #SCS_SAM_HIDE_PICTURE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling hidePicture(" + getAudLabel(p1) + ", " + decodeVidPicTarget(p3) + ", #True)")
              hidePicture(p1, p3, #True)
              gnCallOpenNextCues = 1
              debugMsg(sProcName, "gnCallOpenNextCues=" + gnCallOpenNextCues)
              
            Case #SCS_SAM_HIDE_VIDEO_WINDOW_IF_NOT_IN_USE ; #SCS_SAM_HIDE_VIDEO_WINDOW_IF_NOT_IN_USE
              hideVideoWindowIfNotInUse(p1)
              
            Case #SCS_SAM_HIDE_WARNING_MSG  ; #SCS_SAM_HIDE_WARNING_MSG
              WMN_hideWarningMsg()
              
            Case #SCS_SAM_HIGHLIGHT_PLAYLIST_ROW  ; #SCS_SAM_HIGHLIGHT_PLAYLIST_ROW
              WQP_highlightPlayListRow()
              
            Case #SCS_SAM_HOTKEY  ; #SCS_SAM_HOTKEY
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              WMN_processHotkey(p1, p3)  ; parameter p1 is nHotkeyNr
              
            Case #SCS_SAM_INIT_FM
              FM_init(p1)
              
            Case #SCS_SAM_INIT_RAI
              debugMsg(sProcName, "calling RAI_Init()")
              RAI_Init()
              
            Case #SCS_SAM_LOAD_CUE_PANELS ; #SCS_SAM_LOAD_CUE_PANELS
              bLoadDispPanels = #True
              
            Case #SCS_SAM_LOAD_GRID_ROW ; #SCS_SAM_LOAD_GRID_ROW
              If p1 < 0
                loadGridRowsWhereRequested()
              ElseIf p1 < gnCueEnd
                loadGridRow(p1)
              EndIf
              
            Case #SCS_SAM_LOAD_MISSING_OSC_INFO ; #SCS_SAM_LOAD_MISSING_OSC_INFO
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              loadAnyMissingOSCItemInfo(p1, p3, p5)
              
            Case #SCS_SAM_LOAD_NEXT_CUE_PANELS ; #SCS_SAM_LOAD_NEXT_CUE_PANELS
              ; only allow one call per iteration of the SAM stack, thus enabling windows events to be processed between calls
              gnLabelSAM = 2000
              If bLoadNextCuePanelsCalled
                bLeaveRequestInList = #True
                nLeaveCount + 1
              Else
                gnLabelSAM = 2010
                PNL_loadNextCuePanels(p1)
                gnLabelSAM = 2020
                bLoadNextCuePanelsCalled = #True
              EndIf
              gnLabelSAM = 2030
              
            Case #SCS_SAM_LOAD_OCM_CUES
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling loadOCMCuesAfterAudPos(" + getAudLabel(p1) + ", " + p3 + ")")
              loadOCMCuesAfterAudPos(p1, p3)
              
            Case #SCS_SAM_LOAD_ONE_CUE ; #SCS_SAM_LOAD_ONE_CUE ; Added 3Jun2024 11.10.3ag
              debugMsg(sProcName, "calling loadOneCue(" + getCueLabel(p1) + ")")
              loadOneCue(p1)
              
            Case #SCS_SAM_LOAD_SCS_CUE_FILE ; #SCS_SAM_LOAD_SCS_CUE_FILE
              If p1 = 1 ; primary file
                debugMsg(sProcName, "calling loadCueFile()")
                loadCueFile()
                debugMsg(sProcName, "returned from loadCueFile()")
                p3 = gaSamArray(grMain\nSamReadPtr)\p3Long ; = 0 if editor not required, else the cueptr for the editor call
                debugMsg(sProcName, "p3=" + p3)
                If p3 <> 0
                  gnCallEditorCuePtr = p3
                  gbCallEditor = #True
                ElseIf gbGoToProdPropDevices
                  gnCallEditorCuePtr = -1
                  gbCallEditor = #True
                EndIf
                
              ElseIf p1 = 2     ; secondary file (import file)
                WIM_load2ndCueFile()
                
              EndIf
              
            Case #SCS_SAM_LOAD_SLIDER_AUDIO_FILE  ; #SCS_SAM_LOAD_SLIDER_AUDIO_FILE
              SLD_processOneLoadFileRequest()
              
            Case #SCS_SAM_MAKE_VID_PIC_VISIBLE  ; #SCS_SAM_MAKE_VID_PIC_VISIBLE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              makeVidPicVisible(p1, p3, p5)
              
            Case #SCS_SAM_NEW_CUE_FILE  ; #SCS_SAM_NEW_CUE_FILE
              gnLabelSAM = 3000
              newCueFile()
              gnLabelSAM = 3100
              gnCallEditorCuePtr = -1
              gbCallEditor = #True
              debugMsg(sProcName, "end of #SCS_SAM_NEW_CUE_FILE processing")
              
            Case #SCS_SAM_OPEN_DMX_DEVS ; #SCS_SAM_OPEN_DMX_DEVS
              DMX_openDMXDevs()
              
            Case #SCS_SAM_OPEN_FILES_FOR_CUE  ; #SCS_SAM_OPEN_FILES_FOR_CUE
              If p1 >= 0
                debugMsg(sProcName, "calling openFilesForCueIfReqd(" + getCueLabel(p1) + ")")
                openFilesForCueIfReqd(p1)
              EndIf
              
            Case #SCS_SAM_OPEN_MIDI_PORTS ; #SCS_SAM_OPEN_MIDI_PORTS
              debugMsg(sProcName, "calling loadMidiControl(" + strB(p1) + ")")
              loadMidiControl(p1)
              debugMsg(sProcName, "calling openMidiPorts()")
              openMidiPorts()
              debugMsg(sProcName, "calling setMidiEnabled()")
              setMidiEnabled()
              
            Case #SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD  ; #SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD
              debugMsg(sProcName, "calling openMTCCuesPortAndWaitIfReqd(" + strB(p1) + ")")
              openMTCCuesPortAndWaitIfReqd(p1)
              debugMsg(sProcName, "returned from openMTCCuesPortAndWaitIfReqd(" + strB(p1) + ")")
              
            Case #SCS_SAM_OPEN_NEXT_CUES  ; #SCS_SAM_OPEN_NEXT_CUES
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              If (p1 = 0) And (p3 = 0)
                ; debugMsg(sProcName, "calling ONC_openNextCues()")
                ; ONC_openNextCues()
                ; changed 17Mar2020 11.8.2.3aa to pass p5 as bApplyDefaultGridClickAction
                debugMsg(sProcName, "calling 1, -1, -2, #False, #True, -1, " + strB(p5) + ")")
                ONC_openNextCues(1, -1, -2, #False, #True, -1, p5)
              Else
                If (p1 > 1) And (aCue(p1)\bHotkey)
                  ; if p1 refers to a hotkey cue then call ONC_openNextCues for this cue only, unless p1 = 1 (see next comment)
                  debugMsg(sProcName, "calling ONC_openNextCues(" + getCueLabel(p1) + ", " + getCueLabel(p1) + ", -2, #False, #True, " + getCueLabel(p3) + ", " + strB(p5) + ")")
                  ONC_openNextCues(p1, p1, -2, #False, #True, p3, p5) ; changed 17Mar2020 11.8.2.3aa to pass p5 as bApplyDefaultGridClickAction
                Else
                  ; if p1 = 1 (the general default) or if not a hotkey cue, then set -1 as the loop end point
                  debugMsg(sProcName, "calling ONC_openNextCues(" + getCueLabel(p1) + ", -1, -2, #False, #True, " + getCueLabel(p3) + " , " + strB(p5) + ")")
                  ONC_openNextCues(p1, -1, -2, #False, #True, p3, p5) ; changed 17Mar2020 11.8.2.3aa to pass p5 as bApplyDefaultGridClickAction
                EndIf
              EndIf
              
            Case #SCS_SAM_OPEN_NEXT_CUES_ONE_CUE_ONLY  ; #SCS_SAM_OPEN_NEXT_CUES_ONE_CUE_ONLY
              ONC_openNextCues(p1, p1)
              
            Case #SCS_SAM_OPEN_RS232_PORTS  ; #SCS_SAM_OPEN_RS232_PORTS
              If gbInitialising
                ; hold back starting another thread
                bLeaveRequestInList = #True
                nLeaveCount + 1
              Else
                debugMsg(sProcName, "calling setRS232InOutInds()")
                setRS232InOutInds()
                debugMsg(sProcName, "calling setRS232Enabled()")
                setRS232Enabled()
                debugMsg(sProcName, "calling startRS232()")
                startRS232()
                debugMsg(sProcName, "calling checkRS232DevsForCtrlSends()")
                checkRS232DevsForCtrlSends()
              EndIf
              
            Case #SCS_SAM_PAUSE_RESUME_ALL  ; #SCS_SAM_PAUSE_RESUME_ALL
              processPauseResumeAll()
              
            Case #SCS_SAM_PAUSE_RESUME_CUE  ; #SCS_SAM_PAUSE_RESUME_CUE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              Select p3
                Case #SCS_MM_PAUSE
                  pauseCue(p1)
                Case #SCS_MM_RESUME
                  resumeCue(p1)
                Case #SCS_MM_PAUSE_OR_RESUME
                  PauseOrResumeCue(p1)
              EndSelect
              
            Case #SCS_SAM_PAUSE_VIDEO  ; #SCS_SAM_PAUSE_VIDEO
              pauseVideo(p1)
              
            Case #SCS_SAM_PLAY_AUD_FOR_STATUS_CHECK  ; #SCS_SAM_PLAY_AUD_FOR_STATUS_CHECK
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              SC_PlayAudForStatusCheck(p1, p3)
              
            Case #SCS_SAM_PLAY_CUE  ; #SCS_SAM_PLAY_CUE
              If p1 >= 0
                If (aCue(p1)\nCueState < #SCS_CUE_FADING_IN) Or (aCue(p1)\nCueState > #SCS_CUE_FADING_OUT)
                  debugMsg(sProcName, "calling playCueViaCas(" + getCueLabel(p1) + ")")
                  playCueViaCas(p1)
                Else
                  ; cue is already playing - could be due to an auto-start cue requested by statusCheck() for a cue that has already been started recursively from playCue()
                  debugMsg(sProcName, "SCS_SAM_PLAY_CUE(" + getCueLabel(p1) + ") ignored because cue status = " + decodeCueState(aCue(p1)\nCueState))
                EndIf
              EndIf
              
            Case #SCS_SAM_PLAY_MIDI_OR_DMX_CUE ; #SCS_SAM_PLAY_MIDI_OR_DMX_CUE
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              debugMsg(sProcName, "calling processMidiOrDMXPlayCueCmd(" + p1 + ", " + p4 + ")")
              processMidiOrDMXPlayCueCmd(p1, p4) ; nb p1 is midi port, or -1 if dmx; p4 (string) is MIDI/DMX Cue
              
            Case #SCS_SAM_PLAY_CTRL_SEND_ITEM_DELAYED ; #SCS_SAM_PLAY_CTRL_SEND_ITEM_DELAYED
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling playSubTypeM(" + getSubLabel(p1) + ", #False, " + p3 + ")")
              playSubTypeM(p1, #False, p3)
              
            Case #SCS_SAM_PLAY_NEXT_AUD  ; #SCS_SAM_PLAY_NEXT_AUD
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              playNextAud(p1, p3)
              
            Case #SCS_SAM_PLAY_SUB  ; #SCS_SAM_PLAY_SUB
              debugMsg(sProcName, "calling playSub(" + getSubLabel(p1) + ")")
              playSub(p1)
              
            Case #SCS_SAM_PLAY_VIDEO ; #SCS_SAM_PLAY_VIDEO
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling playVideo(" + getAudLabel(p1) + ", " + decodeAspectRatioValue(p3) + ")")
              playVideo(p1, p3)
              
            Case #SCS_SAM_POPULATE_GRID ; #SCS_SAM_POPULATE_GRID
              populateGrid()
              
            Case #SCS_SAM_PROCESS_WQA_SELECTED_ITEM ; #SCS_SAM_PROCESS_WQA_SELECTED_ITEM
              WQA_processItemSelected(p1)
              
            Case #SCS_SAM_RAI_REQUEST  ; #SCS_SAM_RAI_REQUEST
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              Select p3
                Case #SCS_OSCINP_STATUS
                  processOSCStatusRequest(p1)
                Default
                  processOSCInfoRequest(p1, p3, p5, p4)
              EndSelect
              
            Case #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS ; #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS
              WED_redrawTVGGadgets()
              
            Case #SCS_SAM_REFRESH_GRDCUES ; #SCS_SAM_REFRESH_GRDCUES
              gqMainThreadRequest | #SCS_MTH_REFRESH_GRDCUES
              
            Case #SCS_SAM_RELEASE_LOOP  ; #SCS_SAM_RELEASE_LOOP
              releaseAudLoop(p1)
              
            Case #SCS_SAM_REPOS_AUDS  ; #SCS_SAM_REPOS_AUDS
              nAbsReposAt = gaSamArray(grMain\nSamReadPtr)\p3Long
              If nAbsReposAt = -1
                If p1 >= 0
                  With aAud(p1)
                    If \nFirstSoundingDev >= 0
                      If \nFirstSoundingDev >= 0
                        If ((gbUseBASSMixer) And (\bAudUseGaplessStream = #False)) Or (\bUsingSplitStream)
                          nMyBassChannel = \nBassChannel[\nFirstSoundingDev]
                        Else
                          nMyBassChannel = \nSourceChannel
                        EndIf
                        nAbsReposAt = GetPlayingPos(p1, nMyBassChannel, 3)
                      EndIf
                    EndIf
                  EndWith
                EndIf
              EndIf
              debugMsg(sProcName, "calling reposAuds(" + getAudLabel(p1) + ", " + nAbsReposAt + ", #True")
              reposAuds(p1, nAbsReposAt, #True)
              
            Case #SCS_SAM_REPOS_CUE ; #SCS_SAM_RESPOS_CUE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              reposCue(p1, p3)
              
            Case #SCS_SAM_REPOS_SPLITTER  ; #SCS_SAM_REPOS_SPLITTER
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling WMN_processSplitterRepositioned(" + getGadgetName(p1) + ", " + "bEndOfMove=" + strB(p3) + ")")
              WMN_processSplitterRepositioned(p1, p3)
              
            Case #SCS_SAM_RESET_INITIAL_STATE_OF_CUE  ; #SCS_SAM_RESET_INITIAL_STATE_OF_CUE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling resetInitialStateOfCue(" + getCueLabel(p1) + ", " + getCueLabel(p3) + ")")
              resetInitialStateOfCue(p1, p3)
              
            Case #SCS_SAM_REWIND_AUD  ; #SCS_SAM_REWIND_AUD
              debugMsg(sProcName, "calling rewindAud(" + getAudLabel(p1) + ")")
              rewindAud(p1)
              If (gbEditing) And (p1 = nEditAudPtr)
                ; debugMsg(sProcName, "#SCS_SAM_REWIND_AUD  editUpdateDisplay(#True)")
                editUpdateDisplay(#True)
              EndIf
              
            Case #SCS_SAM_SET_AUD_DEV_LEVEL   ; #SCS_SAM_SET_AUD_DEV_LEVEL
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              fBVLevel = gaSamArray(grMain\nSamReadPtr)\p2Single
              debugMsg(sProcName, "nSamRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr) + ", calling setLevelsAny(" + getAudLabel(p1) + ", " + p3 + ", " + formatLevel(fBVLevel) + ", SCS_NOPANCHANGE_SINGLE)")
              setLevelsAny(p1, p3, fBVLevel, #SCS_NOPANCHANGE_SINGLE)
              
            Case #SCS_SAM_SET_AUD_DEV_PAN   ; #SCS_SAM_SET_AUD_DEV_PAN
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              fPan = gaSamArray(grMain\nSamReadPtr)\p2Single
              debugMsg(sProcName, "nSamRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr) + ", calling setLevelsAny(" + getAudLabel(p1) + ", " + p3 + ", SCS_NOVOLCHANGE_SINGLE, " + formatPan(fPan) + ")")
              setLevelsAny(p1, p3, #SCS_NOVOLCHANGE_SINGLE, fPan)
              
            Case #SCS_SAM_SET_AUD_INPUT_DEV_LEVEL   ; #SCS_SAM_SET_AUD_INPUT_DEV_LEVEL
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              ; fBVLevel = gaSamArray(grMain\nSamReadPtr)\p2Single
              debugMsg(sProcName, "nSamRequest=" + decodeSamRequest(nThisRequest, grMain\nSamReadPtr) + ", calling setLevelsForSMSInputDev(" + getAudLabel(p1) + ", " + p3 + ")")
              setLevelsForSMSInputDev(p1, p3)
              
            Case #SCS_SAM_SET_CUE_PANELS  ; #SCS_SAM_SET_CUE_PANELS
              bSetCuePanels = #True
              
            Case #SCS_SAM_SET_CUE_POSITION  ; #SCS_SAM_SET_CUE_POSITION
              setCuePosition(p1)
              
            Case #SCS_SAM_SET_CUE_TO_GO ; #SCS_SAM_SET_CUE_TO_GO
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              setCueToGo(p1, p3)
              
            Case #SCS_SAM_SET_CURR_PL_ROW ; #SCS_SAM_SET_CURR_PL_ROW
              WQP_setCurrentRow(p1)
              
            Case #SCS_SAM_SET_CURR_QA_ITEM  ; #SCS_SAM_SET_CURR_QA_ITEM
              WQA_processItemSelected(p1)
              
            Case #SCS_SAM_SET_DEVICE_FADER  ; SCS_SAM_SET_DEVICE_FADER
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              fBVLevel = gaSamArray(grMain\nSamReadPtr)\p2Single
              nDevMapDevPtr = getDevMapDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, p1)
              If grMaps\aDev(nDevMapDevPtr)\bUseFaderOutputGain
                grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain = fBVLevel
                grMaps\aDev(nDevMapDevPtr)\sDevFaderOutputGainDB = convertBVLevelToDBString(fBVLevel, #False, #True)
              EndIf
              grMaps\aDev(nDevMapDevPtr)\fDevOutputGain = fBVLevel
              grMaps\aDev(nDevMapDevPtr)\sDevOutputGainDB = convertBVLevelToDBString(fBVLevel, #False, #True)
              ; debugMsg0(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\fDevOutputGain=" + traceLevel(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain) + ", \sDevOutputGainDB=" + grMaps\aDev(nDevMapDevPtr)\sDevOutputGainDB +
              ;                                    ", calling setAudioDevOutputGain(" + p1 + ")")
              setAudioDevOutputGain(p1)
              displayLabels(#False) ; Call displayLabels() to force the channel's gain marker to be displayed
              If IsWindow(#WCN)
                WCN_setAudioOutputFader(grMaps\aDev(nDevMapDevPtr)\sLogicalDev, fBVLevel, #True)
              EndIf
              
            Case #SCS_SAM_SET_EDIT_WINDOW_ACTIVE  ; #SCS_SAM_SET_EDIT_WINDOW_ACTIVE
              If gbEditing
                If IsWindow(#WED)
                  debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(" + decodeWindow(#WED) + ")")
                  SAW(#WED)
                EndIf
              EndIf
              
            Case #SCS_SAM_SET_FOCUS_TO_SCS
              setFocusToSCS()
              
            Case #SCS_SAM_SET_GO_BUTTON ; #SCS_SAM_SET_GO_BUTTON
              debugMsg(sProcName, "calling setGoButton()")
              setGoButton()
              
            Case #SCS_SAM_SET_GRID_ROW  ; #SCS_SAM_SET_GRID_ROW
              setGridRow(p1)
              
            Case #SCS_SAM_SET_HOTKEY_BANK ; #SCS_SAM_SET_HOTKEY_BANK
              setHotkeyBank(p1)
              
            Case #SCS_SAM_SET_MASTER_FADER  ; SCS_SAM_SET_MASTER_FADER
              fBVLevel = gaSamArray(grMain\nSamReadPtr)\p2Single
              setMasterFader(fBVLevel)
              If gaSamArray(grMain\nSamReadPtr)\p3Long ; p3Long will be #True or #False
                SLD_setLevel(WMN\sldMasterFader, fBVLevel)
                setSaveSettings()
              EndIf
              
            Case #SCS_SAM_SET_MOUSE_CURSOR  ; #SCS_SAM_SET_MOUSE_CURSOR
              setMouseCursor(p1)
              
            Case #SCS_SAM_SET_NAVIGATE_BUTTONS  ; #SCS_SAM_SET_NAVIGATE_BUTTONS
              setNavigateButtons()
              
            Case #SCS_SAM_SET_PLAYORDER ; #SCS_SAM_SET_PLAYORDER
              If gbCueFileLoaded = #False
                bLeaveRequestInList = #True
                nLeaveCount + 1
              Else
                p1 = gaSamArray(grMain\nSamReadPtr)\p1Long    ; nSubNo
                p3 = gaSamArray(grMain\nSamReadPtr)\p3Long    ; nAudNo (nAudNo of \nFirstPlayIndexThisRun)
                p4 = gaSamArray(grMain\nSamReadPtr)\p4String  ; sCue
                p8 = gaSamArray(grMain\nSamReadPtr)\p8String  ; sPlayOrder
                processSamSetPlayOrder(p4, p1, p8, p3)
              EndIf
              
            Case #SCS_SAM_SET_SLD_BUTTON_POSITION ; #SCS_SAM_SET_SLD_BUTTON_POSITION
              SLD_setButtonPos(p1)
              
            Case #SCS_SAM_SET_TEST_TONE_LEVEL ; #SCS_SAM_SET_TEST_TONE_LEVEL
              setTestToneLevel()
              
            Case #SCS_SAM_SET_TIME_BASED_CUES ; #SCS_SAM_SET_TIME_BASED_CUES
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              setTimeBasedCues(p1, p3)
              
            Case #SCS_SAM_SET_WINDOW_VISIBLE  ; #SCS_SAM_SET_WINDOW_VISIBLE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              setWindowVisible(p1, p3)
              
            Case #SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW  ; #SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW
              If GetActiveWindow() <> #WMN
                debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(#WMN)")
                SAW(#WMN)
              EndIf
              
            Case #SCS_SAM_SETUP_AVAILABLE_MONITORS  ; #SCS_SAM_SETUP_AVAILABLE_MONITORS
              debugMsg(sProcName, "calling setupForAvailableMonitors()")
              setupForAvailableMonitors()
              
            Case #SCS_SAM_SHOW_VIDEO_FRAME  ; #SCS_SAM_SHOW_VIDEO_FRAME
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling showMyVideoFrame(" + getAudLabel(p1) + ", " + p3 + ", #True)")
              showMyVideoFrame(p1, p3, #True)
              
            Case #SCS_SAM_SPECIFIC_SMS_COMMAND  ; #SCS_SAM_SPECIFIC_SMS_COMMAND
              sendSMSCommand(gaSamArray(grMain\nSamReadPtr)\p4String, #False)
              
            Case #SCS_SAM_START_NETWORK  ; #SCS_SAM_START_NETWORK
              If gbInitialising
                ; hold back starting another thread
                bLeaveRequestInList = #True
                nLeaveCount + 1
              Else
                debugMsg(sProcName, "calling startNetwork()")
                If startNetwork()
                  setNetworkEnabled()
                Else
                  If gbCloseCueFile
                    debugMsg(sProcName, "calling closeCueFile()")
                    closeCueFile()
                    debugMsg(sProcName, "calling setCueDetailsInMain()")
                    setCueDetailsInMain()
                  EndIf
                EndIf
              EndIf
              
            Case #SCS_SAM_START_THREAD ; #SCS_SAM_START_THREAD
              If THR_getThreadState(p1) <> #SCS_THREAD_STATE_ACTIVE
                THR_createOrResumeAThread(p1)
              EndIf
              
            Case #SCS_SAM_START_VU_DISPLAY  ; #SCS_SAM_START_VU_DISPLAY
              startVUDisplayIfReqd(p1)
              
            Case #SCS_SAM_STOP_AUD  ; #SCS_SAM_STOP_AUD
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              debugMsg(sProcName, "calling stopAud(" + getAudLabel(p1) + ", " + strB(p3) + ")")
              stopAud(p1, p3)
              
            Case #SCS_SAM_STOP_CUE  ; #SCS_SAM_STOP_CUE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              debugMsg(sProcName, "calling stopCue(" + getCueLabel(p1) + ", " + #DQUOTE$ + p4 + #DQUOTE$ + ", " + strB(p3) + ")")
              stopCue(p1, p4, p3)
              
            Case #SCS_SAM_STOP_DMX_FADES_FOR_SUB  ; #SCS_SAM_STOP_DMX_FADES_FOR_SUB
              If grDMXFadeItems\nMaxFadeItem >= 0
                DMX_stopDMXFadesForSub(p1)
              EndIf
              
            Case #SCS_SAM_STOP_LC_SUB   ; #SCS_SAM_STOP_LC_SUB
              editStopLCSub(p1)
              
            Case #SCS_SAM_STOP_QA   ; #SCS_SAM_STOP_QA
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              editQAStop(p1, p3)
              
            Case #SCS_SAM_STOP_SUB  ; #SCS_SAM_STOP_SUB
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              stopSub(p1, p4, p3, p5)
              
            Case #SCS_SAM_STOP_SUB_FOR_STATUS_CHECK ; #SCS_SAM_STOP_SUB_FOR_STATUS_CHECK
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              p4 = gaSamArray(grMain\nSamReadPtr)\p4String
              p5 = gaSamArray(grMain\nSamReadPtr)\p5Long
              stopSub(p1, p4, p3, p5)
              endOfSub(p1, -1)
              
            Case #SCS_SAM_UNASSIGN_SMS_PLAYBACK_CHANNEL ; #SCS_SAM_UNASSIGN_SMS_PLAYBACK_CHANNEL
              ; Added 22Nov2021 11.8.6cd
              unassignPlaybackChannel(p1)
              
            Case #SCS_SAM_UPDATE_GRID ; #SCS_SAM_UPDATE_GRID
              If (p1 >= 0) And (p1 < gnCueEnd)
                updateGrid(p1)
              EndIf
              
            Case #SCS_SAM_UPDATE_SCREEN_FOR_CUE ; #SCS_SAM_UPDATE_SCREEN_FOR_CUE
              p3 = gaSamArray(grMain\nSamReadPtr)\p3Long
              If (p1 >= 0) And (p1 < gnCueEnd)
                updateScreenForCue(p1, p3)
              EndIf
              
            Case #SCS_SAM_WMN_RESIZED ; #SCS_SAM_WMN_RESIZED
              debugMsg(sProcName, "calling WMN_Form_Resize()")
              WMN_Form_Resize()
              
            Default
              debugMsg(sProcName, "unknown type: " + nThisRequest)
              
          EndSelect
          
          gqSamTimeLastRequestEnded = ElapsedMilliseconds()
          gnSamRequestsProcessed + 1
          
          If gbSamRequestUnderStoppingEverything
            debugMsg(sProcName, "gbSamRequestUnderStoppingEverything=" + strB(gbSamRequestUnderStoppingEverything))
            gbSamRequestUnderStoppingEverything = #False
          EndIf
          
        EndIf
        
        gnLabelSAM = 4000
        If bLeaveRequestInList
          If nReadPtrFirstLeft = -1
            nReadPtrFirstLeft = grMain\nSamReadPtr
          EndIf
        Else
          nCuePtrForRequestTime = gaSamArray(grMain\nSamReadPtr)\nCuePtrForRequestTime
          If (nCuePtrForRequestTime > 0) And (nCuePtrForRequestTime < gnCueEnd)
            debugMsg(sProcName, "clearing aCue(" + getCueLabel(nCuePtrForRequestTime) + ")\qMainThreadRequestTime")
            aCue(nCuePtrForRequestTime)\qMainThreadRequestTime = 0  ; clear this field to permit the control thread to check this cue
          EndIf
          gaSamArray(grMain\nSamReadPtr)\bActioned = #True
          grMain\nSamRequestsWaiting - 1
        EndIf
        
        gnLabelSAM = 5000
        grMain\nSamReadPtr + 1
        If grMain\nSamReadPtr > grMain\nSamSize
          grMain\nSamReadPtr = 0
        EndIf
        
      Else
        gnLabelSAM = 7000
        grMain\nSamReadPtr + 1
        If grMain\nSamReadPtr > grMain\nSamSize
          grMain\nSamReadPtr = 0
        EndIf
        
      EndIf
      gnLabelSAM = 8000
      
      nLoopCount + 1
      If nLoopCount > grMain\nSamSize
        ; could be something wrong with grMain\nSamRequestsWaiting, so recalculate and then quit
        For n = 0 To grMain\nSamSize
          If (gaSamArray(n)\bActioned = #False) And (gaSamArray(n)\nSamRequest <> 0)
            nRequestsWaiting + 1
          EndIf
        Next n
        grMain\nSamRequestsWaiting = nRequestsWaiting
        Break
      EndIf
      
    Wend
  Next nSamPriority
  gnLabelSAM = 9000
  
  If nReadPtrFirstLeft >= 0
    grMain\nSamReadPtr = nReadPtrFirstLeft
  EndIf

  ; calls that must be executed in a set order
  ; gnLabelSAM = 9100
  ; If bSetCuePanels
    ; bLoadDispPanels = #False ; clear this flag as setCuePanels will issue a request for PNL_loadDispPanels, so throw away any current request for PNL_loadDispPanels
    ; gnLabelSAM = 9200
    ; WMN_setCuePanels()
  ; EndIf
  gnLabelSAM = 9300
  If bLoadDispPanels
    gnLabelSAM = 9400
    ; debugMsg0(sProcName, "calling PNL_loadDispPanels()")
    PNL_loadDispPanels()
    gnLabelSAM = 9500
  EndIf
  
  UnlockCueListMutex()
  gbInSamProcess = #False
  gnLabelSAM = 9900
  gqSamProcessLastEnded = ElapsedMilliseconds()
  
EndProcedure

Procedure.s decodeSamPriority(nSamPriority)
  Protected sSamPriority.s
  
  Select nSamPriority
    Case #SCS_SAMPRIORITY_HIGH
      sSamPriority = "High"
    Case #SCS_SAMPRIORITY_NORMAL
      sSamPriority = ""
    Case #SCS_SAMPRIORITY_LOW
      sSamPriority = "Low"
  EndSelect
  ProcedureReturn sSamPriority
EndProcedure

Procedure.s decodeSamRequest(nRequest, nSamPtr)
  PROCNAMEC()
  Protected sRequest.s, sParam.s
  
  With gaSamArray(nSamPtr)
    Select nRequest
      Case #SCS_SAM_BUILD_DEV_CHANNEL_LIST
        sRequest = "SCS_SAM_BUILD_DEV_CHANNEL_LIST"
        
      Case #SCS_SAM_CALL_MODRETURN_FUNCTION
        sRequest = "SCS_SAM_CALL_MODRETURN_FUNCTION"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_CHANGE_TIME_PROFILE
        sRequest = "SCS_SAM_CHANGE_TIME_PROFILE"
        
      Case #SCS_SAM_CHANNEL_SLIDE
        sRequest = "SCS_SAM_CHANNEL_SLIDE"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_CHECK_MAIN_HAS_FOCUS
        sRequest = "SCS_SAM_CHECK_MAIN_HAS_FOCUS"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_CHECK_PAUSE_ALL_ACTIVE
        sRequest = "SCS_SAM_CHECK_PAUSE_ALL_ACTIVE"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_CHECK_USING_PLAYBACK_RATE_CHANGE_ONLY
        sRequest = "SCS_SAM_CHECK_USING_PLAYBACK_RATE_CHANGE_ONLY"
        
      Case #SCS_SAM_CLEAR_POSITIONING_MIDI
        sRequest = "SCS_SAM_CLEAR_POSITIONING_MIDI"
        
      Case #SCS_SAM_CLEAR_VIDEO_CANVAS_IF_NOT_IN_USE
        sRequest = "SCS_SAM_CLEAR_VIDEO_CANVAS_IF_NOT_IN_USE"
        sParam = decodeVidPicTarget(\p1Long)
        
      Case #SCS_SAM_CLOSE_EDITOR
        sRequest = "SCS_SAM_CLOSE_EDITOR"
        
      Case #SCS_SAM_CLOSE_NETWORK_CONNECTION
        sRequest = "SCS_SAM_CLOSE_NETWORK_CONNECTION"
        
      Case #SCS_SAM_COMPLETE_AUD
        sRequest = "SCS_SAM_COMPLETE_AUD"
        sParam = getAudLabel(\p1Long)
        
      Case #SCS_SAM_CREATE_TVG_CONTROL
        sRequest = "SCS_SAM_CREATE_TVG_CONTROL"
        sParam = decodeVidPicTarget(\p1Long)
        
      Case #SCS_SAM_DISPLAY_CLOCK_IF_REQD ; Added 3Dec2022 11.9.7ar
        sRequest = "SCS_SAM_DISPLAY_CLOCK_IF_REQD"
        
      Case #SCS_SAM_DISPLAY_DMX_DISPLAY
        sRequest = "SCS_SAM_DISPLAY_DMX_DISPLAY"
        
      Case #SCS_SAM_DISPLAY_FADERS
        sRequest = "SCS_SAM_DISPLAY_FADERS"
        
      Case #SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS
        sRequest = "SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS"
        
      Case #SCS_SAM_DISPLAY_PICTURE
        sRequest = "SCS_SAM_DISPLAY_PICTURE"
        sParam = getAudLabel(\p1Long) + ", p3=" + decodeVidPicTarget(\p3Long) + ", p5=" + strB(\p5Long) + ", p7=" + strB(\p7Long)
        
      Case #SCS_SAM_DISPLAY_TIMER
        sRequest = "SCS_SAM_DISPLAY_TIMER"
        sParam = "0, 0, " + strB(\p3Long) + ", " + \p4String
        
      Case #SCS_SAM_DISPLAY_THUMBNAILS
        sRequest = "SCS_SAM_DISPLAY_THUMBNAILS"
        sParam = getSubLabel(\p1Long)
        
      Case #SCS_SAM_DMX_CAPTURE_COMPLETE
        sRequest = "SCS_SAM_DMX_CAPTURE_COMPLETE"
        sParam = decodeDMXAPILabel(\p1Long)
        
      Case #SCS_SAM_DRAW_GRAPH
        sRequest = "SCS_SAM_DRAW_GRAPH"
        
      Case #SCS_SAM_EDITOR_BTN_CLICK
        sRequest = "SCS_SAM_EDITOR_BTN_CLICK"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_EDITOR_NODE_CLICK
        sRequest = "SCS_SAM_EDITOR_NODE_CLICK"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_FMB_FILE_OPEN
        sRequest = "SCS_SAM_FMB_FILE_OPEN"
        sParam = #DQUOTE$ + \p4String + #DQUOTE$
        If \p8String
          sParam + ", " + \p8String
        EndIf
        
      Case #SCS_SAM_FREE_TVG_CONTROL
        sRequest = "SCS_SAM_FREE_TVG_CONTROL"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_GO
        sRequest = "SCS_SAM_GO"
        
      Case #SCS_SAM_GO_REMOTE
        sRequest = "SCS_SAM_GO_REMOTE"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_GO_WITH_EXPECTED_CUE
        sRequest = "SCS_SAM_GO_WITH_EXPECTED_CUE"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_GO_WHEN_OK
        sRequest = "SCS_SAM_GO_WHEN_OK"
        sParam = getCueLabel(\p1Long) + ", 0, " + traceTime(\p3Long)
        
      Case #SCS_SAM_GOTO_CUE
        sRequest = "SCS_SAM_GOTO_CUE"
        sParam = getCueLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_GOTO_CUE_LATEST_ONLY
        sRequest = "SCS_SAM_GOTO_CUE_LATEST_ONLY"
        sParam = getCueLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_GOTO_CUELIST_FOR_SHORTCUT
        sRequest = "SCS_SAM_GOTO_CUELIST_FOR_SHORTCUT"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_GOTO_SPECIAL
        sRequest = "SCS_SAM_GOTO_SPECIAL"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_HIDE_MEMO_ON_SECONDARY_SCREEN
        sRequest = "SCS_SAM_HIDE_MEMO_ON_SECONDARY_SCREEN"
        sParam = decodeVidPicTarget(\p1Long)
        
      Case #SCS_SAM_HIDE_MTC_WINDOW_IF_INACTIVE
        sRequest = "SCS_SAM_HIDE_MTC_WINDOW_IF_INACTIVE"
        
      Case #SCS_SAM_HIDE_PICTURE
        sRequest = "SCS_SAM_HIDE_PICTURE"
        sParam = Str(\p1Long) + ", 0, " + decodeVidPicTarget(\p3Long)
        
      Case #SCS_SAM_HIDE_VIDEO_WINDOW_IF_NOT_IN_USE
        sRequest = "SCS_SAM_HIDE_VIDEO_WINDOW_IF_NOT_IN_USE"
        sParam = decodeVidPicTarget(\p1Long)
        
      Case #SCS_SAM_HIDE_WARNING_MSG
        sRequest = "SCS_SAM_HIDE_WARNING_MSG"
        
      Case #SCS_SAM_HIGHLIGHT_PLAYLIST_ROW
        sRequest = "SCS_SAM_HIGHLIGHT_PLAYLIST_ROW"
        
      Case #SCS_SAM_HOTKEY
        sRequest = "SCS_SAM_HOTKEY"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_INIT_FM
        sRequest = "SCS_SAM_INIT_FM"
        sParam = StrB(\p1Long)
        
      Case #SCS_SAM_INIT_RAI
        sRequest = "SCS_SAM_INIT_RAI"
        
      Case #SCS_SAM_LOAD_CUE_PANELS
        sRequest = "SCS_SAM_LOAD_CUE_PANELS"
        
      Case #SCS_SAM_LOAD_GRID_ROW
        sRequest = "SCS_SAM_LOAD_GRID_ROW"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_LOAD_MISSING_OSC_INFO
        sRequest = "SCS_SAM_LOAD_MISSING_OSC_INFO"
        sParam = Str(\p1Long) + ", 0, " + getCueLabel(\p3Long) + ", " + #DQUOTE$ + #DQUOTE$ + ", " + strB(\p5Long)
        
      Case #SCS_SAM_LOAD_NEXT_CUE_PANELS
        sRequest = "SCS_SAM_LOAD_NEXT_CUE_PANELS"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_PAUSE_RESUME_CUE
        sRequest = "SCS_SAM_PAUSE_RESUME_CUE"
        sParam = getCueLabel(\p1Long) + ", 0, " + \p3Long
        
      Case #SCS_SAM_LOAD_OCM_CUES ; Added 11Jan2025 11.10.6-b03
        sRequest = "SCS_SAM_LOAD_OCM_CUES"
        sParam = getAudLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_LOAD_SCS_CUE_FILE
        sRequest = "SCS_SAM_LOAD_SCS_CUE_FILE"
        sParam = Str(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_LOAD_SLIDER_AUDIO_FILE
        sRequest = "SCS_SAM_LOAD_SLIDER_AUDIO_FILE"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_MAKE_VID_PIC_VISIBLE
        sRequest = "SCS_SAM_MAKE_VID_PIC_VISIBLE"
        sParam = decodeVidPicTarget(\p1Long) + ", " + strB(\p3Long) + ", " + getAudLabel(\p5Long)
        
      Case #SCS_SAM_NEW_CUE_FILE
        sRequest = "SCS_SAM_NEW_CUE_FILE"
        
      Case #SCS_SAM_OPEN_DMX_DEVS
        sRequest = "SCS_SAM_OPEN_DMX_DEVS"
        
      Case #SCS_SAM_OPEN_FILES_FOR_CUE
        sRequest = "SCS_SAM_OPEN_FILES_FOR_CUE"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_OPEN_MIDI_PORTS
        sRequest = "SCS_SAM_OPEN_MIDI_PORTS"
        sParam = strB(\p1Long)
        
      Case #SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD
        sRequest = "SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD"
        sParam = strB(\p1Long)
        
      Case #SCS_SAM_OPEN_NEXT_CUES
        sRequest = "SCS_SAM_OPEN_NEXT_CUES"
        If \p1Long > 0
          sParam = getCueLabel(\p1Long)
        EndIf
        
      Case #SCS_SAM_OPEN_NEXT_CUES_ONE_CUE_ONLY
        sRequest = "SCS_SAM_OPEN_NEXT_CUES_ONE_CUE_ONLY"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_OPEN_RS232_PORTS
        sRequest = "SCS_SAM_OPEN_RS232_PORTS"
        sParam = \p4String
        
      Case #SCS_SAM_PAUSE_RESUME_ALL
        sRequest = "SCS_SAM_PAUSE_RESUME_ALL"
        
      Case #SCS_SAM_PAUSE_RESUME_CUE
        sRequest = "SCS_SAM_PAUSE_RESUME_CUE"
        sParam = getCueLabel(\p1Long) + ", 0, " + \p3Long
        
      Case #SCS_SAM_PAUSE_VIDEO
        sRequest = "SCS_SAM_PAUSE_VIDEO"
        sParam = getAudLabel(\p1Long)
        
      Case #SCS_SAM_PLAY_AUD_FOR_STATUS_CHECK
        sRequest = "SCS_SAM_PLAY_AUD_FOR_STATUS_CHECK"
        sParam = getAudLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_PLAY_CTRL_SEND_ITEM_DELAYED
        sRequest = "SCS_SAM_PLAY_CTRL_SEND_ITEM_DELAYED"
        sParam = getSubLabel(\p1Long) + ", 0, " + Str(\p3Long)
        
      Case #SCS_SAM_PLAY_CUE
        sRequest = "SCS_SAM_PLAY_CUE"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_PLAY_MIDI_OR_DMX_CUE
        sRequest = "SCS_SAM_PLAY_MIDI_OR_DMX_CUE"
        sParam = Str(\p1Long) + ", 0, 0, " + \p4String
        
      Case #SCS_SAM_PLAY_NEXT_AUD
        sRequest = "SCS_SAM_PLAY_NEXT_AUD"
        sParam = getAudLabel(\p1Long) + ", 0, " + getAudLabel(\p3Long)
        
      Case #SCS_SAM_PLAY_SUB
        sRequest = "SCS_SAM_PLAY_SUB"
        sParam = getSubLabel(\p1Long)
        
      Case #SCS_SAM_PLAY_VIDEO
        sRequest = "SCS_SAM_PLAY_VIDEO"
        sParam = getAudLabel(\p1Long) + ", 0, " + decodeVidPicTarget(\p3Long)
        
      Case #SCS_SAM_POPULATE_GRID
        sRequest = "SCS_SAM_POPULATE_GRID"
        
      Case #SCS_SAM_PROCESS_WQA_SELECTED_ITEM
        sRequest = "SCS_SAM_PROCESS_WQA_SELECTED_ITEM"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_RAI_REQUEST
        sRequest = "SCS_SAM_RAI_REQUEST"
        sParam = Str(\p1Long) + ", 0, " + \p3Long + ", " + #DQUOTE$ + \p4String + #DQUOTE$ + ", " + \p5Long
        
      Case #SCS_SAM_REDRAW_EDITOR_TVG_GADGETS
        sRequest = "SCS_SAM_REDRAW_EDITOR_TVG_GADGETS"
        
      Case #SCS_SAM_REFRESH_GRDCUES
        sRequest = "SCS_SAM_REFRESH_GRDCUES"
        
      Case #SCS_SAM_RELEASE_LOOP
        sRequest = "SCS_SAM_RELEASE_LOOP"
        sParam = getAudLabel(\p1Long)
        
      Case #SCS_SAM_REPOS_AUDS
        sRequest = "SCS_SAM_REPOS_AUDS"
        sParam = getAudLabel(\p1Long) + ", 0, " + \p3Long
        
      Case #SCS_SAM_REPOS_CUE
        sRequest = "SCS_SAM_REPOS_CUE"
        sParam = getCueLabel(\p1Long) + ", 0, " + \p3Long
        
      Case #SCS_SAM_REPOS_SPLITTER
        sRequest = "SCS_SAM_REPOS_SPLITTER"
        sParam = getGadgetName(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_RESET_INITIAL_STATE_OF_CUE
        sRequest = "SCS_SAM_RESET_INITIAL_STATE_OF_CUE"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_REWIND_AUD
        sRequest = "SCS_SAM_REWIND_AUD"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_SET_AUD_DEV_LEVEL
        sRequest = "SCS_SAM_SET_AUD_DEV_LEVEL"
        
      Case #SCS_SAM_SET_AUD_DEV_PAN
        sRequest = "SCS_SAM_SET_AUD_DEV_PAN"
        
      Case #SCS_SAM_SET_AUD_INPUT_DEV_LEVEL
        sRequest = "SCS_SAM_SET_AUD_INPUT_DEV_LEVEL"
        
      Case #SCS_SAM_SET_CUE_PANELS
        sRequest = "SCS_SAM_SET_CUE_PANELS"
        
      Case #SCS_SAM_SET_CUE_POSITION
        sRequest = "SCS_SAM_SET_CUE_POSITION"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_SET_CUE_TO_GO
        sRequest = "SCS_SAM_SET_CUE_TO_GO"
        sParam = strB(\p1Long) + ", 0, " + getCueLabel(\p3Long)
        
      Case #SCS_SAM_SET_CURR_PL_ROW
        sRequest = "SCS_SAM_SET_CURR_PL_ROW"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_SET_CURR_QA_ITEM
        sRequest = "SCS_SAM_SET_CURR_QA_ITEM"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_SET_DEVICE_FADER
        sRequest = "SCS_SAM_SET_DEVICE_FADER"
        sParam = Str(\p1Long) + ", " + StrF(\p2Single, 4) + ", " + strB(\p3Long)
        
      Case #SCS_SAM_SET_EDIT_WINDOW_ACTIVE
        sRequest = "SCS_SAM_SET_EDIT_WINDOW_ACTIVE"
        
      Case #SCS_SAM_SET_FOCUS_TO_SCS
        sRequest = "SCS_SAM_SET_FOCUS_TO_SCS"
        
      Case #SCS_SAM_SET_GO_BUTTON
        sRequest = "SCS_SAM_SET_GO_BUTTON"
        
      Case #SCS_SAM_SET_GRID_ROW
        sRequest = "SCS_SAM_SET_GRID_ROW"
        sParam = getCueLabel(\p1Long)
        
      Case #SCS_SAM_SET_HOTKEY_BANK
        sRequest = "SCS_SAM_SET_HOTKEY_BANK"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_SET_MASTER_FADER
        sRequest = "SCS_SAM_SET_MASTER_FADER"
        sParam = "0, " + StrF(\p2Single, 4)
        
      Case #SCS_SAM_SET_MOUSE_CURSOR
        sRequest = "SCS_SAM_SET_MOUSE_CURSOR"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_SET_NAVIGATE_BUTTONS
        sRequest = "SCS_SAM_SET_NAVIGATE_BUTTONS"
        
      Case #SCS_SAM_SET_PLAYORDER
        sRequest = "SCS_SAM_SET_PLAYORDER"
        ; nSubNo in \p1Long
        ; nAudNo in \p3Long (nAudNo of \nFirstPlayIndexThisRun)
        ; sCue in \p4String
        ; sPlayOrder in \p8String
        sParam = Str(\p1Long) + ", 0, " + \p3Long + ", " + #DQUOTE$ + \p4String + #DQUOTE$ + ", 0, 0, 0, " + #DQUOTE$ + \p8String + #DQUOTE$
        
      Case #SCS_SAM_SET_SLD_BUTTON_POSITION
        sRequest = "SCS_SAM_SET_SLD_BUTTON_POSITION"
        sParam = gaSlider(\p1Long)\sName
        
      Case #SCS_SAM_SET_TEST_TONE_LEVEL
        sRequest = "SCS_SAM_SET_TEST_TONE_LEVEL"
        
      Case #SCS_SAM_SET_TIME_BASED_CUES
        sRequest = "SCS_SAM_SET_TIME_BASED_CUES"
        sParam = getCueLabel(\p1Long) + ", " + strB(\p3Long)
        
      Case #SCS_SAM_SET_WINDOW_VISIBLE
        sRequest = "SCS_SAM_SET_WINDOW_VISIBLE"
        sParam = decodeWindow(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW
        sRequest = "SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW"
        
      Case #SCS_SAM_SETUP_AVAILABLE_MONITORS
        sRequest = "SCS_SAM_SETUP_AVAILABLE_MONITORS"
        
      Case #SCS_SAM_SHOW_VIDEO_FRAME
        sRequest = "SCS_SAM_SHOW_VIDEO_FRAME"
        sParam = getAudLabel(\p1Long) + ", 0, " + \p3Long
        
      Case #SCS_SAM_SPECIFIC_SMS_COMMAND
        sRequest = "SCS_SAM_SPECIFIC_SMS_COMMAND"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_START_NETWORK
        sRequest = "SCS_SAM_START_NETWORK"
        
      Case #SCS_SAM_START_THREAD
        sRequest = "SCS_SAM_START_THREAD"
        sParam = THR_decodeThreadIndex(\p1Long)
        
      Case #SCS_SAM_START_VU_DISPLAY
        sRequest = "SCS_SAM_START_VU_DISPLAY"
        
      Case #SCS_SAM_STOP_AUD
        sRequest = "SCS_SAM_STOP_AUD"
        sParam = getAudLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_STOP_CUE
        sRequest = "SCS_SAM_STOP_CUE"
        sParam = getCueLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_STOP_DMX_FADES_FOR_SUB
        sRequest = "SCS_SAM_STOP_DMX_FADES_FOR_SUB"
        sParam = getSubLabel(\p1Long)
        
      Case #SCS_SAM_STOP_LC_SUB
        sRequest = "SCS_SAM_STOP_LC_SUB"
        sParam = getSubLabel(\p1Long)
        
      Case #SCS_SAM_STOP_QA
        sRequest = "SCS_SAM_STOP_QA"
        sParam = strB(\p1Long)
        
      Case #SCS_SAM_STOP_SUB
        sRequest = "SCS_SAM_STOP_SUB"
        sParam = getSubLabel(\p1Long) + ", 0, " + strB(\p3Long) + ", " + #DQUOTE$ + \p4String + #DQUOTE$ + ", 0, " + strB(\p5Long)
        
      Case #SCS_SAM_STOP_SUB_FOR_STATUS_CHECK
        sRequest = "SCS_SAM_STOP_SUB_FOR_STATUS_CHECK"
        sParam = getSubLabel(\p1Long) + ", 0, " + strB(\p3Long) + ", " + #DQUOTE$ + \p4String + #DQUOTE$ + ", 0, " + strB(\p5Long)
        
      Case #SCS_SAM_UNASSIGN_SMS_PLAYBACK_CHANNEL
        sRequest = "SCS_SAM_UNASSIGN_SMS_PLAYBACK_CHANNEL"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_UPDATE_GRID
        sRequest = "SCS_SAM_UPDATE_GRID"
        sParam = Str(\p1Long)
        
      Case #SCS_SAM_UPDATE_SCREEN_FOR_CUE
        sRequest = "SCS_SAM_UPDATE_SCREEN_FOR_CUE"
        sParam = getCueLabel(\p1Long) + ", 0, " + strB(\p3Long)
        
      Case #SCS_SAM_WMN_RESIZED
        sRequest = "SCS_SAM_WMN_RESIZED"
        
      Default
        sRequest = Str(nRequest)
        
    EndSelect
  EndWith
  
  If Len(sParam) > 0
    ProcedureReturn sRequest + "(" + Trim(sParam) + ")"
  Else
    ProcedureReturn sRequest
  EndIf
  
EndProcedure

Procedure samListRequestsWaiting()
  PROCNAMEC()
  Protected n
  Protected nRequestsWaiting
  
  ; debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMain\nSamSize
    With gaSamArray(n)
      If (\bActioned = #False) And (\nSamRequest <> 0)
        nRequestsWaiting + 1
        debugMsg(sProcName, Str(nRequestsWaiting) + ": gaSamArray(" + n + ")\nSamRequest=" + decodeSamRequest(\nSamRequest, n) +
                            ", \qTimeRequestAdded=" + traceTime(\qTimeRequestAdded) + ", \qNotBefore=" + traceTime(\qNotBefore))
      EndIf
    EndWith
  Next n
  
  ; debugMsg(sProcName, #SCS_END + ", nRequestsWaiting=" + nRequestsWaiting)
  
EndProcedure

Procedure samListAllRequests()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMain\nSamSize
    With gaSamArray(n)
      debugMsg(sProcName, "gaSamArray(" + n + ")\nSamRequest=" + decodeSamRequest(\nSamRequest, n) +
                          ", \qTimeRequestAdded=" + traceTime(\qTimeRequestAdded) + ", \qNotBefore=" + traceTime(\qNotBefore) +
                          ", \bActioned=" + strB(\bActioned))
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF